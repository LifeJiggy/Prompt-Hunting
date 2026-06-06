# 37 — Automation Security Assessment

## 1. Introduction

Automation pipelines handle sensitive data: vulnerability findings, host inventories, credentials, and internal network topology. If the automation stack itself becomes an attack vector, the organization faces findings leakage, lateral movement, and compliance violations. This document defines a security assessment framework for automation infrastructure, covering scope boundaries, output scanning, privilege boundaries, periodic exposure checks, and credential leakage detection.

---

## 2. Scope Boundary Verification

Every automation tool must operate within a well-defined scope. Scope drift — where a scanner probes assets outside the authorized boundary — creates legal, contractual, and reputational risk. Scope enforcement must be both preventive (pre-flight checks) and detective (post-run audits).

```python
import ipaddress
import re
from urllib.parse import urlparse
from dataclasses import dataclass
from typing import List, Set, Optional

@dataclass
class ScopePolicy:
    allowed_cidrs: List[str]
    allowed_domains: List[str]
    blocked_cidrs: List[str] = None
    blocked_domains: List[str] = None
    require_tls: bool = True

    def __post_init__(self):
        self.allowed_cidrs = [ipaddress.ip_network(c) for c in (self.allowed_cidrs or [])]
        self.blocked_cidrs = [ipaddress.ip_network(c) for c in (self.blocked_cidrs or [])]
        self._allowed_domains = set(d.lower() for d in (self.allowed_domains or []))
        self._blocked_domains = set(d.lower() for d in (self.blocked_domains or []))

    def is_in_scope(self, target: str) -> tuple[bool, str]:
        parsed = urlparse(target)
        host = parsed.hostname or target
        try:
            ip = ipaddress.ip_address(host)
            for blocked in self.blocked_cidrs:
                if ip in blocked:
                    return False, f"blocked CIDR: {blocked}"
            for allowed in self.allowed_cidrs:
                if ip in allowed:
                    return True, "allowed CIDR"
            return False, "no matching allowed CIDR"
        except ValueError:
            host_lower = host.lower()
            for bd in self._blocked_domains:
                if host_lower == bd or host_lower.endswith("." + bd):
                    return False, f"blocked domain: {bd}"
            for ad in self._allowed_domains:
                if host_lower == ad or host_lower.endswith("." + ad):
                    return True, "allowed domain"
            return False, "no matching allowed domain"

def enforce_scope(targets: List[str], policy: ScopePolicy) -> dict:
    allowed = []
    blocked = []
    for t in targets:
        in_scope, reason = policy.is_in_scope(t)
        (allowed if in_scope else blocked).append({"target": t, "reason": reason})
    return {"allowed": allowed, "blocked": blocked, "total": len(targets)}
```

**Scope policy structure:**
- `allowed_cidrs`: In-scope IPv4/IPv6 networks.
- `allowed_domains`: In-scope hostnames (wildcards permitted via suffix matching).
- `blocked_cidrs` / `blocked_domains`: Explicit denylist (government, partner, internal infra).
- `require_tls`: Reject plaintext targets if only HTTPS is authorized.

**Pre-flight enforcement:**
```python
def pre_flight_scope_check(targets: List[str], policy: ScopePolicy) -> None:
    result = enforce_scope(targets, policy)
    if result["blocked"]:
        raise ScopeViolationError(
            f"{len(result['blocked'])} of {result['total']} targets are out of scope. "
            f"First violation: {result['blocked'][0]}"
        )
    print(f"Scope check passed: {len(result['allowed'])} targets authorized.")
```

**Post-run audit:**
- Capture all resolved IPs for every hostname contacted.
- Cross-reference resolved IPs against the CIDR allowlist.
- Log any DNS resolution that returned a blocked IP, even if the hostname was in-scope.

---

## 3. Tool Output Sensitive-Data Scanning

Automation tools emit findings that may contain secrets, PII, or internal topology. A mandatory output-scanning gate must inspect every finding before it is stored or forwarded.

```python
import re
import json
from pathlib import Path
from dataclasses import dataclass
from typing import List, Pattern

@dataclass
class SensitivePattern:
    name: str
    pattern: Pattern
    severity: str  # "critical" | "high" | "medium"
    action: str    # "redact" | "reject" | "alert"

SENSITIVE_PATTERNS: List[SensitivePattern] = [
    SensitivePattern(
        name="AWS Access Key",
        pattern=re.compile(r"AKIA[0-9A-Z]{16}"),
        severity="critical",
        action="redact",
    ),
    SensitivePattern(
        name="GitHub Token",
        pattern=re.compile(r"ghp_[A-Za-z0-9_]{36,}"),
        severity="critical",
        action="redact",
    ),
    SensitivePattern(
        name="JWT",
        pattern=re.compile(r"eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+"),
        severity="high",
        action="alert",
    ),
    SensitivePattern(
        name="Private Key Block",
        pattern=re.compile(r"-----BEGIN (?:RSA )?PRIVATE KEY-----"),
        severity="critical",
        action="reject",
    ),
    SensitivePattern(
        name="Slack Token",
        pattern=re.compile(r"xox[baprs]-[0-9a-zA-Z-]+"),
        severity="high",
        action="redact",
    ),
    SensitivePattern(
        name="Email Address",
        pattern=re.compile(r"[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}"),
        severity="medium",
        action="alert",
    ),
    SensitivePattern(
        name="Internal Hostname",
        pattern=re.compile(r"\b(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+internal\b"),
        severity="medium",
        action="alert",
    ),
]

def scan_output_for_secrets(findings: List[dict]) -> List[dict]:
    hits = []
    for finding in findings:
        text = json.dumps(finding)
        for sp in SENSITIVE_PATTERNS:
            matches = sp.pattern.findall(text)
            if matches:
                hits.append({
                    "finding_id": finding.get("id", "unknown"),
                    "pattern": sp.name,
                    "severity": sp.severity,
                    "action": sp.action,
                    "match_count": len(matches),
                })
                if sp.action == "redact":
                    finding["_redacted"] = True
                    finding["raw_output"] = sp.pattern.sub("[REDACTED]", text)
                elif sp.action == "reject":
                    raise SecretLeakError(f"Rejected: {sp.name} in finding {finding.get('id')}")
    return hits

def output_quality_gate(findings: List[dict]) -> List[dict]:
    hits = scan_output_for_secrets(findings)
    critical_hits = [h for h in hits if h["severity"] == "critical"]
    if critical_hits:
        raise OutputSecurityError(
            f"Critical secret patterns detected in tool output: {critical_hits}"
        )
    return findings
```

**Output scanning rules:**
- Run `output_quality_gate` on every batch of findings before storage.
- Critical matches (private keys, AWS keys) block the run and trigger an incident.
- High/medium matches are logged and attached to the finding as metadata.
- Maintain a versioned pattern library; review new patterns quarterly.

---

## 4. Privilege Boundary Testing for Automation Accounts

Automation runs under service accounts, API keys, or cloud IAM roles. These accounts must operate under the principle of least privilege. Privilege boundary testing verifies that the automation account cannot exceed its authorized scope.

```python
import boto3
from botocore.exceptions import ClientError

class AWSAutomationPrivilegeTester:
    def __init__(self, role_arn: str, session_name: str = "automation-test"):
        sts = boto3.client("sts")
        assumed = sts.assume_role(
            RoleArn=role_arn,
            RoleSessionName=session_name,
            DurationSeconds=900,
        )
        creds = assumed["Credentials"]
        self.session = boto3.Session(
            aws_access_key_id=creds["AccessKeyId"],
            aws_secret_access_key=creds["SecretAccessKey"],
            aws_session_token=creds["SessionToken"],
        )

    def assert_denied(self, service: str, action: str, **kwargs):
        client = self.session.client(service)
        method = getattr(client, action.lower().replace("-", "_"))
        try:
            method(**kwargs)
        except ClientError as e:
            code = e.response["Error"]["Code"]
            if code in ("AccessDenied", "AccessDeniedException", "Forbidden"):
                print(f"[PASS] {service}:{action} correctly denied")
                return True
            raise
        except Exception:
            return True
        raise AssertionError(f"[FAIL] {service}:{action} was NOT denied — privilege boundary breach!")

    def assert_allowed(self, service: str, action: str, **kwargs):
        client = self.session.client(service)
        method = getattr(client, action.lower().replace("-", "_"))
        try:
            method(**kwargs)
            print(f"[PASS] {service}:{action} correctly allowed")
        except ClientError as e:
            code = e.response["Error"]["Code"]
            raise AssertionError(f"[FAIL] {service}:{action} denied: {code}")

# Usage
tester = AWSAutomationPrivilegeTester(role_arn="arn:aws:iam::123456789012:role/automation-scanner")
tester.assert_denied("s3", "DeleteObject", Bucket="sensitive-bucket", Key="data.csv")
tester.assert_allowed("s3", "ListBucket", Bucket="in-scope-bucket")
```

**Privilege boundary test matrix:**
- **Allowed actions**: Minimum set required for the automation's stated purpose.
- **Denied actions**: Everything else, especially destructive operations (Delete*, Terminate*, Drop*).
- **Escalation paths**: Verify the account cannot call `iam:PassRole`, `sts:AssumeRole` on privileged roles, or create new IAM entities.
- **Network egress**: Confirm the account cannot modify security groups, NACLs, or route tables to widen access.

---

## 5. Periodic Exposure Checks on Stored Data

Automation platforms accumulate large datasets: scan results, asset inventories, vulnerability details. Periodic exposure scans verify that stored data is not inadvertently accessible to unauthorized principals.

```python
import boto3
from typing import List, Dict

class S3ExposureChecker:
    def __init__(self, bucket: str):
        self.s3 = boto3.client("s3")
        self.bucket = bucket

    def check_bucket_policy(self) -> List[Dict]:
        try:
            policy = self.s3.get_bucket_policy(Bucket=self.bucket)
            import json
            p = json.loads(policy["Policy"])
            findings = []
            for stmt in p.get("Statement", []):
                principal = stmt.get("Principal", {})
                if principal == "*" or (isinstance(principal, dict) and principal.get("*") == "*"):
                    if stmt.get("Effect") == "Allow":
                        findings.append({
                            "issue": "public-bucket-policy",
                            "statement": stmt,
                            "severity": "critical",
                        })
            return findings
        except self.s3.exceptions.NoSuchBucketPolicy:
            return []

    def check_acl(self) -> List[Dict]:
        acl = self.s3.get_bucket_acl(Bucket=self.bucket)
        findings = []
        for grant in acl.get("Grants", []):
            grantee = grant.get("Grantee", {})
            if grantee.get("URI") == "http://acs.amazonaws.com/groups/global/AllUsers":
                findings.append({
                    "issue": "public-acl",
                    "permission": grant["Permission"],
                    "severity": "critical",
                })
        return findings

    def check_public_access_block(self) -> List[Dict]:
        try:
            config = self.s3.get_public_access_block(Bucket=self.bucket)
            settings = config["PublicAccessBlockConfiguration"]
            checks = {
                "BlockPublicAcls": settings.get("BlockPublicAcls", False),
                "IgnorePublicAcls": settings.get("IgnorePublicAcls", False),
                "BlockPublicPolicy": settings.get("BlockPublicPolicy", False),
                "RestrictPublicBuckets": settings.get("RestrictPublicBuckets", False),
            }
            findings = []
            for k, v in checks.items():
                if not v:
                    findings.append({"issue": f"public-access-block-{k}", "enabled": False, "severity": "high"})
            return findings
        except self.s3.exceptions.NoSuchPublicAccessBlockConfiguration:
            return [{"issue": "no-public-access-block", "severity": "critical"}]

    def full_exposure_report(self) -> Dict:
        return {
            "bucket": self.bucket,
            "policy_findings": self.check_bucket_policy(),
            "acl_findings": self.check_acl(),
            "public_access_findings": self.check_public_access_block(),
        }
```

**Exposure check schedule:**
- **Real-time**: Block on any `public-access-block` misconfiguration before writing data.
- **Daily**: Automated scan of all storage buckets for policy/ACL drift.
- **Weekly**: Full audit of object-level ACLs and cross-account access patterns.
- **Monthly**: Review of access logs for unauthorized principals.

---

## 6. Credential Leakage Scanning in Findings

Security findings themselves can leak credentials: a scanner might capture a `Set-Cookie` header, a full HTTP request with an `Authorization` header, or a database connection string in a stack trace. Automated post-processing must strip or mask these fields.

```python
import re
import json
from dataclasses import dataclass
from typing import Any, Dict, List

REDACTION_PATTERNS = {
    "authorization_header": re.compile(r'(?i)["\']?Authorization["\']?\s*[:=]\s*["\']?[A-Za-z0-9_\-\.]+=["\']?'),
    "set_cookie": re.compile(r'(?i)Set-Cookie:\s*[^\n]+'),
    "cookie_header": re.compile(r'(?i)Cookie:\s*[^\n]+'),
    "bearer_token": re.compile(r'Bearer\s+[A-Za-z0-9_\-\.]+'),
    "basic_auth": re.compile(r'Basic\s+[A-Za-z0-9+/=]+'),
    "api_key_query": re.compile(r'([?&])(api[_-]?key|apikey|access[_-]?token)=([A-Za-z0-9_\-]+)'),
    "connection_string": re.compile(r'(?i)(jdbc:|mongodb:|postgresql:|mysql:|redis:)[^\s]+'),
    "slack_webhook": re.compile(r'https://hooks\.slack\.com/services/T[A-Za-z0-9_]+/B[A-Za-z0-9_]+/[A-Za-z0-9_]+'),
    "private_key": re.compile(r'-----BEGIN (?:RSA )?PRIVATE KEY-----[^-]+-----END (?:RSA )?PRIVATE KEY-----', re.DOTALL),
    "aws_key": re.compile(r'AKIA[0-9A-Z]{16}'),
}

def redact_finding(finding: Dict[str, Any]) -> Dict[str, Any]:
    redacted = json.loads(json.dumps(finding))  # deep copy
    def _redact_value(obj):
        if isinstance(obj, str):
            for name, pattern in REDACTION_PATTERNS.items():
                obj = pattern.sub(f"[REDACTED:{name.upper()}]", obj)
            return obj
        elif isinstance(obj, dict):
            return {k: _redact_value(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [_redact_value(i) for i in obj]
        return obj
    return _redact_value(redacted)

def redact_findings_batch(findings: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    return [redact_finding(f) for f in findings]

def validate_redaction(findings: List[Dict[str, Any]]) -> List[Dict]:
    hits = []
    for f in findings:
        raw = json.dumps(f)
        for name, pattern in REDACTION_PATTERNS.items():
            if pattern.search(raw):
                hits.append({"finding_id": f.get("id"), "pattern_missed": name})
    return hits
```

**Redaction policy:**
- Run `redact_findings_batch` on all findings before any external transmission.
- Run `validate_redaction` as a quality gate; any miss is a bug in the redaction layer.
- Store raw (unredacted) findings in a separate, tightly access-controlled vault for legal-hold purposes only.
- Redaction patterns must be reviewed when new scanners or output formats are added.

---

## 7. Pipeline Security Audit Checklist

Use this checklist for every automation pipeline release:

- [ ] Scope policy is versioned and enforced pre-flight on all targets.
- [ ] Output quality gate runs on every batch of findings.
- [ ] Automation account IAM role has been tested with privilege boundary matrix.
- [ ] Stored data exposure checks pass (S3 ACLs, bucket policies, public-access-block).
- [ ] Findings are redacted before any external API call or email dispatch.
- [ ] Secrets in findings are scanned with the current pattern library.
- [ ] Pipeline logs do not contain raw `Authorization` or `Cookie` headers.
- [ ] Webhook/notification URLs are verified against an allowlist.
- [ ] All third-party tool invocations are sandboxed (container with network restrictions).
- [ ] Incident response contacts are defined for automation-specific breaches.

---

## 8. Incident Response for Automation Breaches

If the automation platform itself is compromised or leaks data:

1. **Isolate**: Revoke the automation account's credentials and API keys immediately.
2. **Assess**: Determine what data was accessible during the compromise window. Query access logs for the service account's principal ID.
3. **Contain**: Rotate all secrets that passed through the pipeline during the window. Assume all stored findings are compromised.
4. **Notify**: Inform the data protection officer (DPO) and affected asset owners per GDPR/CCPA obligations.
5. **Remediate**: Patch the vulnerability that enabled the breach (e.g., unpatched container, overly permissive IAM role, exfiltration via findings output).
6. **Review**: Conduct a post-incident review within 5 business days. Update scope policies, privilege boundaries, and output scanning patterns based on findings.

---

## 9. Summary

Automation security assessment is a continuous process: verify scope boundaries before every run, scan outputs for secrets, enforce least-privilege on automation accounts, periodically audit stored data exposure, and treat the pipeline itself as a high-value target. Each control is both a technical safeguard and evidence of due diligence for auditors and regulators.
