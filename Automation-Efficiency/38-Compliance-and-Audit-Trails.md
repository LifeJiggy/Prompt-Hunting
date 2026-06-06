# 38 — Compliance and Audit Trails

## 1. Introduction

Automated security scanning platforms process data that is subject to regulatory frameworks including GDPR, CCPA, HIPAA, SOC 2, and ISO 27001. Compliance is not a one-time certification — it is a continuous operational discipline enforced through data handling policies, evidence retention, chain-of-custody procedures, immutable audit logs, privacy-by-design architecture, and access controls. This document provides actionable patterns for each of these controls.

---

## 2. GDPR / CCPA Data Handling Rules

Security findings contain personal data: names, email addresses, IP addresses, employee IDs, and device fingerprints. Under GDPR (Article 5) and CCPA (Section 1798.100), this data must be processed lawfully, fairly, transparently, and for limited purposes.

**Lawful basis for processing:**
- **Legitimate interest** (GDPR Article 6(1)(f)): Vulnerability scanning is a legitimate interest for security management. Document this basis in the Records of Processing Activities (RoPA).
- **Legal obligation** (GDPR Article 6(1)(c)): Certain regulated industries (finance, healthcare) require vulnerability management as a statutory duty.
- **Consent**: Not typically applicable for internal security scanning of company-owned assets.

**Data minimization rules:**
```python
from dataclasses import dataclass
from typing import Any, Dict, List, Optional

MINIMIZATION_RULES = {
    "email": {"retain": False, "hash_for_correlation": True, "anonymize": "sha256"},
    "ip_address": {"retain": False, "hash_for_correlation": True, "anonymize": "sha256"},
    "name": {"retain": False, "hash_for_correlation": True, "anonymize": "sha256"},
    "employee_id": {"retain": False, "hash_for_correlation": True, "anonymize": "sha256"},
    "hostname": {"retain": True, "pseudonymize": True, "note": "hostnames are asset identifiers"},
    "url": {"retain": True, "redact_params": ["token", "key", "secret", "password", "auth"]},
    "finding_description": {"retain": True, "scan_for_pii": True},
    "request_body": {"retain": False, "retain_redacted": True},
    "response_body": {"retain": False, "retain_redacted": True},
    "screenshot": {"retain": True, "blur_faces": True, "redact_pii_overlay": True},
}

def minimize_finding(finding: Dict[str, Any]) -> Dict[str, Any]:
    minimized = {}
    for key, value in finding.items():
        rule = MINIMIZATION_RULES.get(key, {"retain": True})
        if not rule.get("retain", True):
            if rule.get("hash_for_correlation"):
                import hashlib, os
                salt = os.environ.get("PII_SALT", "default-salt-change-me")
                minimized[key] = hashlib.sha256(f"{value}{salt}".encode()).hexdigest()[:16]
            elif rule.get("anonymize") == "sha256":
                import hashlib
                minimized[key] = hashlib.sha256(str(value).encode()).hexdigest()[:16]
            else:
                minimized[key] = None
        else:
            if isinstance(value, str):
                minimized[key] = redact_pii_fields(value, rule)
            elif isinstance(value, dict):
                minimized[key] = minimize_finding(value)
            else:
                minimized[key] = value
    return minimized

def redact_pii_fields(text: str, rule: Dict) -> str:
    import re
    if rule.get("redact_params"):
        for param in rule["redact_params"]:
            pattern = re.compile(
                r'([?&])(' + re.escape(param) + r')=([^&\s]+)',
                re.IGNORECASE
            )
            text = pattern.sub(rf'\1\2=[REDACTED]', text)
    return text
```

**CCPA-specific considerations:**
- Do Not Sell / Share: Security scanning data is not "sold" under CCPA, but confirm with legal counsel if findings are shared with third-party MSSPs.
- Deletion requests: If a data subject exercises their right to erasure, delete all pseudonymized hashes and any linked correlation records. Note that deletion may break audit trail continuity — document the break with a legal-hold reference.

---

## 3. Evidence Retention Policies

Evidence retention defines how long scan results, raw logs, screenshots, and reports are kept. Retention periods must balance regulatory requirements, legal hold obligations, and storage costs.

| Data Type | Retention Period | Legal Basis | Storage Tier |
|-----------|-----------------|-------------|--------------|
| Raw scan logs | 90 days | Operational necessity | Hot (frequent query) |
| Sanitized findings | 3 years | Regulatory (SOC 2, ISO 27001) | Warm |
| Full findings with PII | 1 year (or legal hold) | Legal hold / DPO directive | Cold / encrypted |
| Screenshots with PII | 1 year | Legal hold | Cold / encrypted |
| Audit logs | 7 years | Regulatory (SOX, GDPR accountability) | Immutable / WORM |
| Correlation hashes | 3 years | Statistical / trend analysis | Warm |
| Exploit PoC artifacts | 90 days | Operational necessity | Hot (delete after disclosure) |

**Retention enforcement code:**
```python
import boto3
from datetime import datetime, timezone, timedelta
from typing import Dict

class RetentionEnforcer:
    def __init__(self, s3_bucket: str, dynamo_table: str):
        self.s3 = boto3.client("s3")
        self.dynamo = boto3.resource("dynamo").Table(dynamo_table)

    def get_retention_days(self, data_type: str) -> int:
        policy = {
            "raw_scan_logs": 90,
            "sanitized_findings": 365 * 3,
            "full_findings_pii": 365,
            "screenshots": 365,
            "audit_logs": 365 * 7,
            "correlation_hashes": 365 * 3,
            "poc_artifacts": 90,
        }
        return policy.get(data_type, 365)

    def mark_for_deletion(self, object_key: str, data_type: str):
        retention_days = self.get_retention_days(data_type)
        expires = datetime.now(timezone.utc) + timedelta(days=retention_days)
        self.s3.put_object_tagging(
            Bucket=self.s3.meta.bucket_name,
            Key=object_key,
            Tagging={"TagSet": [
                {"Key": "expires-at", "Value": expires.isoformat()},
                {"Key": "data-type", "Value": data_type},
                {"Key": "legal-hold", "Value": "false"},
            ]},
        )

    def enforce_retention(self):
        paginator = self.s3.get_paginator("list_objects_v2")
        now = datetime.now(timezone.utc)
        legal_hold_keys = set()
        for page in paginator.paginate(Bucket=self.s3.meta.bucket_name):
            for obj in page.get("Contents", []):
                tags = self.s3.get_object_tagging(
                    Bucket=self.s3.meta.bucket_name, Key=obj["Key"]
                )["TagSet"]
                tag_map = {t["Key"]: t["Value"] for t in tags}
                if tag_map.get("legal-hold", "false") == "true":
                    legal_hold_keys.add(obj["Key"])
                    continue
                expires = datetime.fromisoformat(tag_map.get("expires-at", ""))
                if now > expires and obj["Key"] not in legal_hold_keys:
                    self.s3.delete_object(
                        Bucket=self.s3.meta.bucket_name, Key=obj["Key"]
                    )
                    print(f"Deleted expired object: {obj['Key']}")
```

---

## 4. Chain-of-Custody for Findings

Chain-of-custody (CoC) ensures that every finding can be traced from discovery through triage, remediation, and disclosure. A broken chain undermines the evidentiary value of the finding and may violate regulatory requirements.

**CoC record schema:**
```json
{
  "finding_id": "VULN-2024-1128",
  "chain_of_custody": [
    {
      "event": "discovered",
      "timestamp": "2024-11-28T14:32:01Z",
      "actor": "automation-scanner-v3.2.1",
      "action": "scan_completed",
      "source_run_id": "run-abc123",
      "location": "s3://findings-raw/run-abc123/findings.jsonl",
      "hash_sha256": "e3b0c44298fc1c149afbf4c8996fb924...",
      "evidence_ref": "s3://evidence/run-abc123/response.bin"
    },
    {
      "event": "triaged",
      "timestamp": "2024-11-28T15:10:44Z",
      "actor": "analyst-jdoe",
      "action": "confirmed_valid",
      "previous_hash": "e3b0c44298fc1c149afbf4c8996fb924...",
      "notes": "Confirmed exploitable in staging environment"
    },
    {
      "event": "remediated",
      "timestamp": "2024-12-05T09:22:18Z",
      "actor": "devops-team",
      "action": "patch_applied",
      "commit_sha": "a1b2c3d4",
      "verification_scan_id": "run-xyz789"
    }
  ]
}
```

**Chain integrity verification:**
```python
import hashlib
import json
from typing import List, Dict

class ChainOfCustody:
    def __init__(self, custody_record: Dict):
        self.record = custody_record

    def verify_chain(self) -> bool:
        chain = self.record.get("chain_of_custody", [])
        if not chain:
            return False
        prev_hash = None
        for entry in chain:
            if "previous_hash" in entry and prev_hash is not None:
                if entry["previous_hash"] != prev_hash:
                    print(f"Chain break at {entry['event']}: hash mismatch")
                    return False
            entry_json = json.dumps(entry, sort_keys=True, default=str)
            prev_hash = hashlib.sha256(entry_json.encode()).hexdigest()
        return True

    def append_event(self, event: Dict):
        chain = self.record.setdefault("chain_of_custody", [])
        if chain:
            last_entry = chain[-1]
            event["previous_hash"] = hashlib.sha256(
                json.dumps(last_entry, sort_keys=True, default=str).encode()
            ).hexdigest()
        chain.append(event)
        self.record["chain_hash"] = hashlib.sha256(
            json.dumps(chain, sort_keys=True, default=str).encode()
        ).hexdigest()
```

**CoC rules:**
- Every custody event is an immutable append; no edits or deletes.
- Each entry links to the previous entry via SHA-256 hash.
- The final `chain_hash` is stored in an immutable log store (see Section 5).
- If any link is broken (hash mismatch, missing entry), the entire chain is flagged as potentially compromised.

---

## 5. Audit Log Design

Audit logs record every action taken within the automation platform: who did what, when, from where, and on which data. Log design must balance completeness with storage efficiency.

**Audit log schema:**
```json
{
  "log_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "timestamp": "2024-11-28T14:32:01.123456Z",
  "event_type": "finding.updated",
  "actor": {
    "type": "service_account",
    "id": "svc-automation-scanner",
    "ip_address": "10.0.1.42",
    "user_agent": "automation-scanner/3.2.1"
  },
  "target": {
    "type": "finding",
    "id": "VULN-2024-1128"
  },
  "action": {
    "type": "status_change",
    "from": "new",
    "to": "triaged"
  },
  "context": {
    "run_id": "run-abc123",
    "tool": "nuclei",
    "tool_version": "3.2.1",
    "scan_profile": "full-external"
  },
  "result": {
    "status": "success",
    "duration_ms": 145
  },
  "integrity": {
    "hash": "sha256:abc123...",
    "prev_log_hash": "sha256:prev123..."
  }
}
```

**Log design principles:**
- **Structured**: Use JSON with a fixed schema. No free-text event descriptions.
- **Immutable**: Each log entry references the previous entry's hash, forming a blockchain-like chain.
- **Timestamped**: Use UTC with microsecond precision. Reject backdated entries.
- **Attributed**: Every event must have an `actor` — either a human user ID or a service account ID.
- **Complete**: Log all state transitions, not just errors. A missing event is as suspicious as a wrong event.

---

## 6. Immutable Log Storage

Immutable storage prevents log tampering, a key requirement for GDPR accountability (Article 5(2)) and many compliance frameworks.

```python
import boto3
from datetime import datetime, timezone

class ImmutableLogStore:
    def __init__(self, bucket: str):
        self.s3 = boto3.client("s3")
        self.bucket = bucket

    def append_log(self, log_entry: Dict) -> str:
        log_entry["timestamp"] = datetime.now(timezone.utc).isoformat()
        log_entry_bytes = json.dumps(log_entry, sort_keys=True, default=str).encode()
        log_id = hashlib.sha256(log_entry_bytes).hexdigest()[:16]
        key = f"audit/{datetime.now(timezone.utc).strftime('%Y/%m/%d')}/{log_id}.jsonl"
        self.s3.put_object(
            Bucket=self.bucket,
            Key=key,
            Body=log_entry_bytes,
            ContentType="application/json",
            ObjectLockMode="GOVERNANCE",
            ObjectLockRetainUntilDate=datetime.now(timezone.utc).replace(year=datetime.now().year + 7),
        )
        return key

    def verify_immutability(self, key: str) -> Dict:
        try:
            head = self.s3.head_object(Bucket=self.bucket, Key=key)
            lock = head.get("ObjectLockMode")
            retain_until = head.get("ObjectLockRetainUntilDate")
            return {
                "key": key,
                "lock_mode": lock,
                "retain_until": retain_until.isoformat() if retain_until else None,
                "immutable": lock in ("GOVERNANCE", "COMPLIANCE"),
            }
        except Exception as e:
            return {"key": key, "error": str(e), "immutable": False}
```

**Immutable storage options:**
- **S3 Object Lock**: `GOVERNANCE` mode (admin can delete with special permission) or `COMPLIANCE` mode (no one can delete until retention expires).
- **AWS QLDB**: Provides a cryptographically verifiable, immutable transaction log with a journal.
- **Azure Immutable Blob Storage**: Time-based retention policies with legal hold support.
- **On-premises**: WORM (Write Once Read Many) storage or append-only filesystems with `chattr +a`.

---

## 7. Privacy-by-Design in Collection

Privacy-by-design (PbD) principles require that data collection is limited to what is necessary, that data is pseudonymized at the point of collection, and that data subjects are informed.

**Pseudonymization at ingestion:**
```python
import hashlib
import os
from typing import Dict, Any

class PrivacyLayer:
    def __init__(self, salt: str = None):
        self.salt = salt or os.environ.get("PSEUDONYM_SALT", "")
        if not self.salt:
            raise ValueError("PSEUDONYM_SALT environment variable must be set")

    def pseudonymize(self, value: str, context: str) -> str:
        combined = f"{context}:{value}:{self.salt}"
        return hashlib.sha256(combined.encode()).hexdigest()[:24]

    def ingest_finding(self, raw_finding: Dict[str, Any]) -> Dict[str, Any]:
        pii_fields = {"email", "ip_address", "name", "employee_id", "phone", "username"}
        finding = {}
        for key, value in raw_finding.items():
            if key.lower() in pii_fields:
                finding[f"{key}_pseudo"] = self.pseudonymize(str(value), key)
                finding[key] = None
            elif key.lower() in {"request_headers", "response_headers", "request_body", "response_body"}:
                finding[key] = self.redact_headers(value)
            else:
                finding[key] = value
        return finding

    def redact_headers(self, headers: Dict[str, str]) -> Dict[str, str]:
        sensitive = {"authorization", "cookie", "set-cookie", "x-api-key", "x-auth-token"}
        return {
            k: "[REDACTED]" if k.lower() in sensitive else v
            for k, v in headers.items()
        }
```

**Informed data processing notice (template):**
```
This automated security scanning system processes:
- Network hostnames and IP addresses for vulnerability assessment
- Email addresses associated with asset ownership records
- HTTP request/response samples for vulnerability reproduction

Data is pseudonymized at ingestion. Raw samples containing personal data
are retained for 90 days for debugging purposes only. Data subjects may
request deletion by contacting security@company.com.
```

---

## 8. Access Control on Stored Records

Stored findings and evidence must be accessible only to authorized principals. Implement attribute-based access control (ABAC) or role-based access control (RBAC) at the storage layer.

```python
import boto3
import json
from typing import Dict, List, Optional

class FindingAccessControl:
    def __init__(self, findings_bucket: str, kms_key_id: str):
        self.s3 = boto3.client("s3")
        self.findings_bucket = findings_bucket
        self.kms_key_id = kms_key_id

    def store_finding(self, finding: Dict, classification: str, allowed_roles: List[str]):
        encrypted = self._encrypt_finding(finding)
        key = f"findings/{classification}/{finding['id']}.json.enc"
        self.s3.put_object(
            Bucket=self.findings_bucket,
            Key=key,
            Body=encrypted,
            ServerSideEncryption="aws:kms",
            SSEKMSKeyId=self.kms_key_id,
            Metadata={
                "classification": classification,
                "allowed_roles": json.dumps(allowed_roles),
                "pii_level": finding.get("pii_level", "none"),
            },
        )
        self._apply_bucket_policy(key, classification, allowed_roles)

    def _encrypt_finding(self, finding: Dict) -> bytes:
        import base64
        from cryptography.fernet import Fernet
        key = os.environ.get("FINDING_ENCRYPTION_KEY")
        if not key:
            raise ValueError("FINDING_ENCRYPTION_KEY not set")
        f = Fernet(key)
        return f.encrypt(json.dumps(finding).encode())

    def _apply_bucket_policy(self, key: str, classification: str, allowed_roles: List[str]):
        # In practice, manage this via AWS Organizations SCPs or bucket policies
        pass  # Policy management is infrastructure-as-code, see below

    def authorize_access(self, principal_arn: str, principal_roles: List[str], finding: Dict) -> bool:
        required = finding.get("allowed_roles", [])
        classification = finding.get("classification", "internal")
        if classification == "public":
            return True
        return any(role in required for role in principal_roles)
```

**RBAC policy template (AWS S3 Bucket Policy):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SecurityAnalystsReadInternal",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789012:role/security-analyst"},
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::findings-bucket/findings/internal/*",
        "arn:aws:s3:::findings-bucket"
      ],
      "Condition": {"StringEquals": {"s3:ExistingObjectTag/classification": "internal"}}
    },
    {
      "Sid": "DenyUnencryptedAccess",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::findings-bucket/*",
      "Condition": {"StringNotEquals": {"s3:x-amz-server-side-encryption": "aws:kms"}}
    }
  ]
}
```

---

## 9. Legal Hold

Legal hold suspends normal data retention and deletion when litigation, regulatory investigation, or audit is anticipated. Automation platforms must support legal hold on specific findings, scan runs, or entire date ranges.

```python
import boto3
from datetime import datetime, timezone
from typing import Optional

class LegalHoldManager:
    def __init__(self, findings_bucket: str, hold_table: str):
        self.s3 = boto3.client("s3")
        self.dynamo = boto3.resource("dynamo").Table(hold_table)

    def place_hold(self, scope: str, scope_value: str, reason: str, issuer: str, case_ref: str):
        now = datetime.now(timezone.utc).isoformat()
        item = {
            "hold_id": f"hold-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}",
            "scope": scope,
            "scope_value": scope_value,
            "reason": reason,
            "issuer": issuer,
            "case_ref": case_ref,
            "placed_at": now,
            "active": True,
        }
        self.dynamo.put_item(Item=item)
        if scope == "finding_id":
            self._tag_finding(scope_value, legal_hold="true", hold_id=item["hold_id"])
        elif scope == "run_id":
            self._tag_run(scope_value, legal_hold="true", hold_id=item["hold_id"])
        return item["hold_id"]

    def release_hold(self, hold_id: str, released_by: str, reason: str):
        now = datetime.now(timezone.utc).isoformat()
        self.dynamo.update_item(
            Key={"hold_id": hold_id},
            UpdateExpression="SET active = :a, released_at = :r, released_by = :u, release_reason = :n",
            ExpressionAttributeValues={
                ":a": False,
                ":r": now,
                ":u": released_by,
                ":n": reason,
            },
        )

    def _tag_finding(self, finding_id: str, **tags):
        existing = self.s3.get_object_tagging(
            Bucket=self.s3.meta.bucket_name,
            Key=f"findings/{finding_id}.json.enc",
        )
        tag_set = existing.get("TagSet", [])
        tag_set.extend([{"Key": k, "Value": v} for k, v in tags.items()])
        self.s3.put_object_tagging(
            Bucket=self.s3.meta.bucket_name,
            Key=f"findings/{finding_id}.json.enc",
            Tagging={"TagSet": tag_set},
        )
```

**Legal hold policy:**
- Legal hold supersedes all retention schedules. Deletion is blocked while `legal-hold=true` tag is present.
- Hold records include `case_ref`, `issuer`, `reason`, and `active` flag for audit.
- Release requires dual authorization (legal + security officer).
- All hold/release events are appended to the immutable audit log.

---

## 10. Compliance Dashboard Queries

Operationalize compliance with automated queries against the audit and retention infrastructure:

```sql
-- Findings retention compliance: count of findings past retention date without legal hold
SELECT 
    data_type,
    COUNT(*) as expired_count,
    MIN(created_at) as oldest_expired
FROM stored_findings
WHERE expires_at < NOW()
  AND legal_hold = FALSE
GROUP BY data_type;

-- Chain-of-custody integrity: findings with broken custody chains
SELECT 
    finding_id,
    COUNT(*) as broken_links
FROM chain_of_custody_events
WHERE hash_verified = FALSE
GROUP BY finding_id;

-- Access control violations: unauthorized access attempts
SELECT 
    principal_id,
    COUNT(*) as denied_count,
    MAX(timestamp) as last_attempt
FROM access_audit_log
WHERE allowed = FALSE
GROUP BY principal_id
ORDER BY denied_count DESC;

-- PII exposure trend: findings with unmasked PII over time
SELECT 
    DATE_TRUNC('week', timestamp) as week,
    COUNT(*) as pii_findings,
    SUM(CASE WHEN pattern = 'email' THEN 1 ELSE 0 END) as email_leaks,
    SUM(CASE WHEN pattern = 'ip_address' THEN 1 ELSE 0 END) as ip_leaks
FROM pii_scan_results
GROUP BY week
ORDER BY week DESC;
```

---

## 11. GDPR Article 30 RoPA Entry

Maintain a formal Record of Processing Activities for the automation platform:

```
Processing Activity: Automated Vulnerability Scanning and Findings Management
Controller: [Organization Name], DPO: [Name and Contact]
Purpose: Identify and remediate security vulnerabilities in [in-scope assets]
Data Categories: Asset hostnames, IP addresses, email addresses (asset owners), vulnerability findings, HTTP request/response samples
Data Subjects: Employees, contractors, customers (indirectly via asset ownership)
Retention Periods: Raw logs 90 days, sanitized findings 3 years, full findings with PII 1 year or legal hold
International Transfers: None (data stored in EU region)
Security Measures: AES-256 encryption at rest, TLS 1.3 in transit, RBAC, immutable audit logs, privacy-by-design pseudonymization
DPIA Conducted: Yes, date: [date], outcome: Low residual risk with controls in place
```

---

## 12. Summary

Compliance is operationalized through specific, measurable controls: data minimization at ingestion, versioned retention policies, hash-chained custody records, immutable audit logs, privacy-preserving collection architecture, fine-grained access control, and legal-hold procedures. Each control produces artifacts that demonstrate accountability to regulators, auditors, and data subjects. Treat compliance not as a checkbox but as an integral quality attribute of the automation platform.
