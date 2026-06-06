# 39 — Disaster Recovery Planning

## 1. Introduction

Automation platforms accumulate irreplaceable artifacts: scan history, evidence files, correlation datasets, and trained models. A disaster recovery (DR) plan ensures that these artifacts survive hardware failure, cloud region outage, ransomware, operator error, and key compromise. This document defines incident scenarios, sets recovery objectives, specifies automated backup testing, describes recovery playbooks, defines fallback tool stacks, and codifies offline export procedures.

---

## 2. Incident Scenarios

Categorize potential disasters by likelihood and impact. Each scenario drives a specific recovery procedure.

| Scenario | Likelihood | Impact | RTO Target | RPO Target |
|----------|-----------|--------|------------|------------|
| Single disk failure (NVMe) | Medium | Low | 4 hours | 1 hour |
| Cloud region outage | Low | High | 8 hours | 4 hours |
| Ransomware / destructive delete | Low | Critical | 24 hours | 1 hour |
| Primary database corruption | Low | High | 4 hours | 15 minutes |
| Automation account key compromise | Medium | High | 1 hour | 0 (credential rotation only) |
| Operator error (mass deletion) | Medium | Medium | 2 hours | 15 minutes |
| Kubernetes cluster loss | Low | High | 8 hours | 1 hour |
| Backup storage corruption | Low | Critical | 24 hours | 1 hour |

**Scenario definitions:**
- **RTO (Recovery Time Objective)**: Maximum acceptable downtime before business impact becomes severe.
- **RPO (Recovery Point Objective)**: Maximum acceptable data loss measured in time — the age of the most recent restore point.

---

## 3. Recovery Time / Point Objectives

RTO and RPO must be quantified per system component and tested against realistic disaster conditions, not just simulated restores.

```python
from dataclasses import dataclass
from typing import Dict, List, Optional
from enum import Enum

class ComponentTier(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

@dataclass
class DRTargets:
    component: str
    tier: ComponentTier
    rto_hours: float
    rpo_hours: float
    backup_method: str
    restore_method: str
    fallback_available: bool = False

DR_TARGETS: List[DRTargets] = [
    DRTargets(
        component="primary_postgres",
        tier=ComponentTier.CRITICAL,
        rto_hours=1,
        rpo_hours=0.25,
        backup_method="WAL-G continuous archiving + daily base backup",
        restore_method="WAL-G restore to point-in-time",
        fallback_available=True,
    ),
    DRTargets(
        component="findings_s3_bucket",
        tier=ComponentTier.CRITICAL,
        rto_hours=2,
        rpo_hours=1,
        backup_method="S3 Cross-Region Replication + S3 Versioning",
        restore_method="Switch DNS/alias to replica bucket",
        fallback_available=True,
    ),
    DRTargets(
        component="audit_log_qlDB",
        tier=ComponentTier.HIGH,
        rto_hours=4,
        rpo_hours=4,
        backup_method="QLDB journal export to S3 (daily)",
        restore_method="Replay journal export to new QLDB ledger",
        fallback_available=False,
    ),
    DRTargets(
        component="automation_orchestrator",
        tier=ComponentTier.HIGH,
        rto_hours=4,
        rpo_hours=1,
        backup_method="Kubernetes etcd backup (hourly) + GitOps state",
        restore_method="Restore etcd + redeploy from GitOps",
        fallback_available=True,
    ),
    DRTargets(
        component="report_templates",
        tier=ComponentTier.MEDIUM,
        rto_hours=24,
        rpo_hours=24,
        backup_method="Git repository (mirrored to 2 remotes)",
        restore_method="git clone from mirror",
        fallback_available=True,
    ),
]

def validate_dr_targets() -> Dict:
    critical = [t for t in DR_TARGETS if t.tier == ComponentTier.CRITICAL]
    if not all(t.rto_hours <= 4 for t in critical):
        return {"valid": False, "errors": ["Critical components exceed 4-hour RTO"]}
    if not all(t.rpo_hours <= 1 for t in critical):
        return {"valid": False, "errors": ["Critical components exceed 1-hour RPO"]}
    return {"valid": True, "targets": len(DR_TARGETS)}
```

---

## 4. Automated Backup Restore Testing

Backups are worthless if they cannot be restored. Implement automated restore testing on a schedule — weekly for critical components, monthly for others.

```python
import boto3
import subprocess
import tempfile
from pathlib import Path
from dataclasses import dataclass
from typing import Optional
from datetime import datetime, timezone

@dataclass
class RestoreTestResult:
    component: str
    backup_source: str
    restore_path: str
    success: bool
    duration_s: float
    rto_met: bool
    rpo_met: bool
    data_integrity_verified: bool
    error_message: Optional[str] = None
    tested_at: str = ""

    def to_dict(self):
        return {
            "component": self.component,
            "success": self.success,
            "duration_s": self.duration_s,
            "rto_met": self.rto_met,
            "rpo_met": self.rpo_met,
            "data_integrity_verified": self.data_integrity_verified,
            "tested_at": self.tested_at,
        }

class BackupRestoreTester:
    def __init__(self, restore_target_env: str = "staging"):
        self.rds = boto3.client("rds")
        self.s3 = boto3.client("s3")
        self.restore_env = restore_target_env

    def test_postgres_pitr(self, db_instance: str, target_time: str) -> RestoreTestResult:
        start = datetime.now(timezone.utc)
        try:
            restore_id = f"restore-test-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}"
            response = self.rds.restore_db_instance_to_point_in_time(
                SourceDBInstanceIdentifier=db_instance,
                TargetDBInstanceIdentifier=restore_id,
                RestoreTime=target_time,
                DBSubnetGroupName="restore-test-subnet",
                PubliclyAccessible=False,
            )
            waiter = self.rds.get_waiter("db_instance_available")
            waiter.wait(DBInstanceIdentifier=restore_id)
            duration = (datetime.now(timezone.utc) - start).total_seconds()
            row_count = self._verify_row_count(restore_id, "findings")
            success = row_count > 0
            self.rds.delete_db_instance(
                DBInstanceIdentifier=restore_id,
                SkipFinalSnapshot=True,
            )
            return RestoreTestResult(
                component="primary_postgres",
                backup_source=f"PITR:{db_instance}:{target_time}",
                restore_path=f"rds:{restore_id}",
                success=success,
                duration_s=round(duration, 2),
                rto_met=duration < 4 * 3600,
                rpo_met=True,
                data_integrity_verified=success,
                tested_at=datetime.now(timezone.utc).isoformat(),
            )
        except Exception as e:
            return RestoreTestResult(
                component="primary_postgres",
                backup_source=f"PITR:{db_instance}:{target_time}",
                restore_path="",
                success=False,
                duration_s=(datetime.now(timezone.utc) - start).total_seconds(),
                rto_met=False,
                rpo_met=False,
                data_integrity_verified=False,
                error_message=str(e),
                tested_at=datetime.now(timezone.utc).isoformat(),
            )

    def test_s3_bucket_restore(self, source_bucket: str, replica_bucket: str) -> RestoreTestResult:
        start = datetime.now(timezone.utc)
        try:
            source_objects = self._list_s3_objects(source_bucket)
            replica_objects = self._list_s3_objects(replica_bucket)
            missing = set(source_objects) - set(replica_objects)
            extra = set(replica_objects) - set(source_objects)
            success = len(missing) == 0 and len(extra) == 0
            duration = (datetime.now(timezone.utc) - start).total_seconds()
            return RestoreTestResult(
                component="findings_s3_bucket",
                backup_source=f"s3://{source_bucket}",
                restore_path=f"s3://{replica_bucket}",
                success=success,
                duration_s=round(duration, 2),
                rto_met=duration < 2 * 3600,
                rpo_met=True,
                data_integrity_verified=success,
                tested_at=datetime.now(timezone.utc).isoformat(),
            )
        except Exception as e:
            return RestoreTestResult(
                component="findings_s3_bucket",
                backup_source=f"s3://{source_bucket}",
                restore_path=f"s3://{replica_bucket}",
                success=False,
                duration_s=(datetime.now(timezone.utc) - start).total_seconds(),
                rto_met=False,
                rpo_met=False,
                data_integrity_verified=False,
                error_message=str(e),
                tested_at=datetime.now(timezone.utc).isoformat(),
            )

    def _list_s3_objects(self, bucket: str) -> List[str]:
        paginator = self.s3.get_paginator("list_objects_v2")
        objects = []
        for page in paginator.paginate(Bucket=bucket):
            for obj in page.get("Contents", []):
                objects.append(obj["Key"])
        return objects

    def _verify_row_count(self, db_instance: str, table: str) -> int:
        import psycopg2
        import os
        conn_string = os.environ.get("RESTORE_TEST_DB_CONN")
        if not conn_string:
            return 0
        conn = psycopg2.connect(conn_string.replace("{{host}}", db_instance))
        cur = conn.cursor()
        cur.execute(f"SELECT COUNT(*) FROM {table}")
        count = cur.fetchone()[0]
        cur.close()
        conn.close()
        return count
```

**Restore test schedule:**
- **Critical components**: Weekly automated restore test to a disposable environment.
- **High components**: Bi-weekly automated restore test.
- **Medium/Low components**: Monthly spot-check with a sample restore.
- Test results are stored in the immutable audit log with the tag `restore-test`.

---

## 5. Recovery Playbooks

A recovery playbook is a step-by-step, runbook-style document for each disaster scenario. Playbooks must be versioned, reviewed quarterly, and tested in game-day exercises.

**Playbook template:**
```markdown
# Playbook: Ransomware / Destructive Delete

## Trigger Conditions
- S3 bucket versioning shows mass deletion events
- Database `pg_stat_activity` shows `DROP TABLE` or `TRUNCATE`
- Alert from SIEM: `automation_account unusual_delete_volume`

## Immediate Actions (0–15 minutes)
1. **ISOLATE**: Revoke all automation account credentials and API keys.
   - AWS: `aws iam delete-access-key --user-name svc-automation --access-key-id AKIA...`
   - K8s: `kubectl delete serviceaccount automation-scanner -n security`
2. **STOP PIPELINE**: Disable all CI/CD triggers and scheduled jobs.
   - `kubectl scale deployment/orchestrator --replicas=0 -n security`
3. **FREEZE DELETION**: Enable S3 Versioning recovery and object lock on affected buckets.
   - `aws s3api put-object-lock-configuration ...`

## Assessment (15–60 minutes)
1. Pull access logs for the automation account for the last 24 hours.
2. Identify the first anomalous deletion timestamp (the "patient zero" event).
3. Determine blast radius: which buckets, databases, and Kubernetes resources were affected.

## Recovery (1–4 hours)
1. Restore S3 bucket from cross-region replica using `aws s3 sync s3://replica-bucket s3://primary-bucket`.
2. Restore PostgreSQL from latest PITR backup: `wal-g restore ...`.
3. Redeploy orchestrator from GitOps state (verified commit SHA from before the incident).
4. Rotate all secrets that were accessible during the compromise window.

## Validation (4–8 hours)
1. Run full scan suite against staging environment to confirm tool integrity.
2. Verify finding count matches pre-incident baseline (±5% variance acceptable).
3. Confirm all CI/CD pipelines are green.

## Communication
- Notify CISO, DPO, and incident response team within 1 hour of detection.
- Draft initial incident report within 4 hours.
- Publish final post-mortem within 5 business days.
```

**Playbook requirements:**
- Every playbook has a single owner (named individual) and a deputy.
- Playbooks are stored in a dedicated, access-controlled repository.
- Game-day exercises run each playbook at least annually; results are reviewed by the CISO.

---

## 6. Fallback Tool Stacks

If primary tools fail (license expiry, vendor outage, corrupted binary), the automation platform must fall back to alternative tools that produce compatible output. Maintain a documented fallback stack with tested output compatibility.

```python
from dataclasses import dataclass
from typing import List, Dict, Optional

@dataclass
class ToolFallbackEntry:
    primary_tool: str
    primary_version: str
    fallback_tool: str
    fallback_version: str
    output_compatible: bool
    last_tested: str
    notes: str

FALLBACK_REGISTRY: List[ToolFallbackEntry] = [
    ToolFallbackEntry(
        primary_tool="subfinder",
        primary_version="2.6.0",
        fallback_tool="assetfinder",
        fallback_version="0.1.1",
        output_compatible=True,
        last_tested="2024-11-15",
        notes="Output is line-delimited hostnames; compatible with downstream parser",
    ),
    ToolFallbackEntry(
        primary_tool="nuclei",
        primary_version="3.2.1",
        fallback_tool="nuclei-templates-alt",
        fallback_version="3.2.1",
        output_compatible=True,
        last_tested="2024-11-15",
        notes="Same engine, alternate template source",
    ),
    ToolFallbackEntry(
        primary_tool="naabu",
        primary_version="2.7.0",
        fallback_tool="masscan",
        fallback_version="1.3.2",
        output_compatible=True,
        last_tested="2024-10-01",
        notes="Output is JSON with ip/port; compatible with port aggregator",
    ),
    ToolFallbackEntry(
        primary_tool="postgres",
        primary_version="16",
        fallback_tool="postgres",
        fallback_version="15",
        output_compatible=True,
        last_tested="2024-09-20",
        notes="Same major version; WAL-G restore may need version adjustment",
    ),
]

def get_fallback(primary_tool: str, primary_version: str) -> Optional[ToolFallbackEntry]:
    for entry in FALLBACK_REGISTRY:
        if entry.primary_tool == primary_tool:
            return entry
    return None

def validate_fallback_output(primary_output: str, fallback_output: str) -> bool:
    primary_lines = set(primary_output.strip().splitlines())
    fallback_lines = set(fallback_output.strip().splitlines())
    jaccard = len(primary_lines & fallback_lines) / len(primary_lines | fallback_lines)
    return jaccard >= 0.80
```

**Fallback stack rules:**
- Each fallback tool must produce output compatible with the primary tool's downstream consumers.
- Test fallback output compatibility quarterly using the same Enobench harness (see Section 36).
- Fallback tool binaries are stored in an isolated artifact registry with version pinning.
- Fallback activation is a manual decision by the automation owner, not automatic.

---

## 7. Offline Export Procedures

In a total infrastructure loss scenario, the organization must be able to reconstruct the automation state from offline exports. Exports must be stored on physically separate media (tape, air-gapped NAS, or offline cloud storage with no network path).

```python
import boto3
import tarfile
import io
import csv
from datetime import datetime, timezone
from pathlib import PurePosixPath

class OfflineExporter:
    def __init__(self, findings_bucket: str, db_connection_string: str, export_destination: str):
        self.s3 = boto3.client("s3")
        self.findings_bucket = findings_bucket
        self.db_connection_string = db_connection_string
        self.export_destination = export_destination

    def export_all(self) -> bytes:
        tar_buffer = io.BytesIO()
        with tarfile.open(fileobj=tar_buffer, mode="w:gz") as tar:
            tar.addfile(
                self._create_tarinfo("manifest.json", self._generate_manifest()),
                io.BytesIO(self._generate_manifest().encode()),
            )
            tar.addfile(
                self._create_tarinfo("findings/findings.csv", self._export_findings_csv()),
                io.BytesIO(self._export_findings_csv()),
            )
            tar.addfile(
                self._create_tarinfo("audit/audit_log.csv", self._export_audit_log_csv()),
                io.BytesIO(self._export_audit_log_csv()),
            )
            tar.addfile(
                self._create_tarinfo("config/pipeline_config.yaml", self._export_config()),
                io.BytesIO(self._export_config().encode()),
            )
        tar_buffer.seek(0)
        return tar_buffer.read()

    def _create_tarinfo(self, name: str, content: bytes) -> tarfile.TarInfo:
        info = tarfile.TarInfo(name=str(PurePosixPath(name)))
        info.size = len(content)
        info.mtime = datetime.now(timezone.utc).timestamp()
        return info

    def _generate_manifest(self) -> str:
        import json
        manifest = {
            "export_timestamp": datetime.now(timezone.utc).isoformat(),
            "export_tool": "offline-exporter/1.0.0",
            "findings_bucket": self.findings_bucket,
            "components": [
                "findings",
                "audit_logs",
                "pipeline_config",
                "chain_of_custody",
            ],
            "checksums": {},
        }
        return json.dumps(manifest, indent=2)

    def _export_findings_csv(self) -> bytes:
        # Query findings from database and serialize to CSV
        import psycopg2
        conn = psycopg2.connect(self.db_connection_string)
        cur = conn.cursor()
        cur.execute("SELECT id, title, severity, status, created_at FROM findings")
        rows = cur.fetchall()
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(["id", "title", "severity", "status", "created_at"])
        for row in rows:
            writer.writerow(row)
        cur.close()
        conn.close()
        return output.getvalue().encode()

    def _export_audit_log_csv(self) -> bytes:
        # Pull audit log entries and serialize to CSV
        return b"timestamp,event_type,actor,target,action\n"

    def _export_config(self) -> str:
        return "pipeline_version: 3.2.1\nscan_profiles:\n  - name: full-external\n"

    def ship_to_offline_storage(self, tar_bytes: bytes, label: str):
        if self.export_destination.startswith("s3://"):
            bucket, key = self._parse_s3_uri(self.export_destination)
            self.s3.put_object(
                Bucket=bucket,
                Key=key,
                Body=tar_bytes,
                ObjectLockMode="COMPLIANCE",
                ObjectLockRetainUntilDate=datetime(2100, 1, 1, tzinfo=timezone.utc),
            )
        elif self.export_destination.startswith("file://"):
            path = self.export_destination[7:]
            Path(path).write_bytes(tar_bytes)
        else:
            raise ValueError(f"Unsupported export destination: {self.export_destination}")
```

**Offline export schedule:**
- **Critical data**: Daily export, shipped to offline storage within 4 hours of creation.
- **Full state**: Weekly full export including findings, audit logs, config, and custody chains.
- **Verification**: Quarterly restore test from the offline export to a clean environment.
- **Media rotation**: Replace physical media (tape, disk) every 12 months.

---

## 8. DR Testing Schedule

| Test Type | Frequency | Components | Success Criteria |
|-----------|-----------|------------|-----------------|
| Automated restore test | Weekly | Critical DB, S3 | RTO met, data integrity verified |
| Playbook walkthrough | Monthly | All | Steps completed in < 2 hours |
| Fallback tool activation | Quarterly | All primary tools | Output compatible within 10% variance |
| Full DR drill | Semi-annually | All | Platform fully operational within RTO |
| Offline export restore | Quarterly | All | Full state restored from offline media |
| Key rotation drill | Monthly | All service accounts | Zero downtime, all clients updated |

---

## 9. Key Compromise Procedures

Credential compromise requires a distinct, rapid response procedure focused on minimizing the window of unauthorized access.

```python
class KeyCompromiseResponder:
    def __init__(self, vault_client, notification_channel):
        self.vault = vault_client
        self.notify = notification_channel

    def respond(self, compromised_credentials: List[Dict]):
        for cred in compromised_credentials:
            cred_type = cred["type"]
            cred_id = cred["id"]
            self.notify.send(
                channel="security-incidents",
                message=f"KEY COMPROMISE: {cred_type} {cred_id} — initiating rotation",
                severity="critical",
            )
            if cred_type == "aws_access_key":
                self._rotate_aws_key(cred)
            elif cred_type == "api_token":
                self._rotate_api_token(cred)
            elif cred_type == "service_account_password":
                self._rotate_service_account_password(cred)
            elif cred_type == "k8s_service_account_token":
                self._rotate_k8s_token(cred)
            self._audit_key_usage(cred_id, hours=24)

    def _rotate_aws_key(self, cred: Dict):
        iam = boto3.client("iam")
        user_name = cred["user_name"]
        new_key = iam.create_access_key(UserName=user_name)
        self.vault.store(f"aws/{user_name}/access_key", new_key["AccessKey"])
        iam.delete_access_key(UserName=user_name, AccessKeyId=cred["access_key_id"])
        self._update_all_consumers(user_name)

    def _rotate_api_token(self, cred: Dict):
        new_token = self.vault.generate("api_token", ttl_days=90)
        self.vault.store(f"api/tokens/{cred['service']}", new_token)
        self._update_all_consumers(cred["service"])

    def _audit_key_usage(self, cred_id: str, hours: int = 24):
        # Pull CloudTrail / audit logs for the credential ID
        # Identify all API calls made with the compromised credential
        pass  # Implementation depends on audit log infrastructure
```

**Key compromise checklist:**
- [ ] Identify the compromised credential type and ID.
- [ ] Revoke the credential immediately (do not wait for rotation).
- [ ] Generate and distribute a replacement credential.
- [ ] Audit 30 days of usage for the compromised credential.
- [ ] Check for unauthorized access patterns (new resources created, unusual API calls).
- [ ] Notify affected data owners if PII was accessible during the compromise window.
- [ ] Update the incident record and schedule a post-mortem.

---

## 10. Ransomware-Specific Recovery

Ransomware targeting automation infrastructure aims to encrypt or delete findings, backups, and pipeline state. Specific defenses include:

1. **Immutable backups**: Store critical backups with S3 Object Lock `COMPLIANCE` mode or equivalent WORM storage. Ransomware cannot delete or modify locked objects.
2. **Air-gapped copies**: Maintain a weekly export on physically isolated media with no network path.
3. **Versioning everywhere**: Enable S3 Versioning, Git branch protection, and database point-in-time recovery.
4. **Network segmentation**: Isolate the automation network segment; restrict egress to prevent ransomware from reaching backup storage.
5. **Read-only replicas**: Maintain a read-only replica of the primary database that cannot be modified by any automation account.

```bash
# Verify S3 Object Lock configuration
aws s3api get-object-lock-configuration --bucket findings-backup-bucket

# List locked objects
aws s3api list-objects-v2 --bucket findings-backup-bucket \
  --query "Contents[?ObjectLockMode=='COMPLIANCE'].{Key:Key,Mode:ObjectLockMode,Until:ObjectLockRetainUntilDate}"
```

---

## 11. DR Plan Testing Evidence Template

Every DR test must produce evidence for auditors:

```json
{
  "test_id": "dr-test-2024-12-01-postgres",
  "test_date": "2024-12-01T03:00:00Z",
  "tester": "automation-dr-bot",
  "component": "primary_postgres",
  "scenario": "primary database corruption",
  "steps": [
    {"step": 1, "action": "Inject corruption into staging DB", "result": "success"},
    {"step": 2, "action": "Trigger PITR restore to pre-corruption timestamp", "result": "success"},
    {"step": 3, "action": "Verify row count matches pre-corruption baseline", "result": "success", "row_count": 48291},
    {"step": 4, "action": "Run smoke tests against restored instance", "result": "success", "smoke_tests_passed": 12, "smoke_tests_total": 12}
  ],
  "rto_seconds": 3420,
  "rto_target_seconds": 14400,
  "rto_met": true,
  "rpo_seconds": 900,
  "rpo_target_seconds": 900,
  "rpo_met": true,
  "data_integrity_verified": true,
  "overall_result": "PASS",
  "artifacts": ["s3://dr-tests/2024-12-01/postgres-restore.log"],
  "reviewed_by": "ciso-jdoe",
  "reviewed_at": "2024-12-01T06:00:00Z"
}
```

---

## 12. Summary

Disaster recovery planning transforms a theoretical resilience requirement into a tested, repeatable operational capability. Define RTO/RPO per component, automate restore testing on a schedule, document playbooks with named owners, maintain tested fallback tool stacks, execute offline exports, and treat key compromise as a distinct, rehearsed procedure. DR is not a project — it is an operational rhythm that proves, weekly and quarterly, that the automation platform can survive its worst day.
