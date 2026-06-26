# Working Memory: Core Prompts — Vulnerability Hunting Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `CORE-HUNT-001` |
| Root Folder | `Core-Prompts-hunting/` |
| Total Files | 50 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict + event stream |
| Typical Lifetime | Single vulnerability hunting session (4-8h) |
| Eviction Trigger | Session end, vuln class switch, or 24h TTL |

---

## Overview

Working memory for vulnerability hunting captures the real-time state of an active
hunting session. This spans 50 core modules covering the complete lifecycle from
reconnaissance through proof-of-concept development. Working memory tracks:

- **Current vulnerability class**: Which class of vulnerability is being actively
  hunted (XSS, SSRF, IDOR, SQLi, etc.) and the state of each test.
- **Test results**: Outcomes of individual test cases — passed, failed, inconclusive,
  or blocked by WAF/controls.
- **Findings**: Confirmed or suspected vulnerabilities with their evidence,
  severity assessment, and exploitation state.
- **Bypass attempts**: Techniques tried to bypass security controls, their outcomes,
  and remaining bypass options.
- **Target state**: Current understanding of the target's security posture — known
  technologies, defense mechanisms, and attack surface.
- **Progress tracking**: Which modules have been applied, what coverage exists,
  and what gaps remain.
- **Evidence chain**: Collected evidence (requests, responses, screenshots)
  organized by finding for report generation.

This is the "hunting brain" that maintains context across hundreds of individual
tests, ensuring nothing is missed and findings are properly documented.

---

## Data Schema (YAML)

```yaml
working_memory_hunting:
  version: "2.0"
  scope: "hunting-session"
  ttl_seconds: 86400

  session_state:
    session_id: "string (uuid4)"
    target: "string (primary target domain)"
    started_at: "ISO8601"
    last_activity: "ISO8601"
    status: "enum(active|paused|completed)"
    current_vuln_class: "string"
    coverage_pct: "float (0.0-100.0)"

  vuln_class_tracking:
    vuln_class_id: "string (uuid4)"
    class_name: "enum(xss|ssrf|idor|ssti|lfi|rfi|csrf|sql_injection|xxe|auth_bypass|race_condition|file_upload|open_redirect|subdomain_takeover|misconfiguration|information_disclosure|graphql|websocket|api_misconfig|llm_ai)"
    status: "enum(pending|in_progress|completed|deferred)"
    tests_run: "integer"
    tests_passed: "integer"
    tests_failed: "integer"
    tests_inconclusive: "integer"
    findings_count: "integer"
    bypass_attempts: "list[map]"
    notes: "list[string]"
    started_at: "ISO8601"
    completed_at: "ISO8601 (nullable)"

  test_results:
    test_id: "string (uuid4)"
    vuln_class_id: "string"
    test_name: "string"
    test_type: "enum(automated|manual|hybrid)"
    endpoint: "string"
    method: "string"
    payload: "string"
    parameter: "string"
    status: "enum(passed|failed|inconclusive|blocked|error)"
    response_code: "integer"
    response_time_ms: "integer"
    response_snippet: "string (truncated at 2KB)"
    analysis: "string"
    confidence: "float (0.0-1.0)"
    timestamp: "ISO8601"

  findings:
    finding_id: "string (uuid4)"
    vuln_class: "string"
    title: "string"
    severity: "enum(critical|high|medium|low|informational)"
    confidence: "enum(proven|high|medium|low|speculative)"
    endpoint: "string"
    parameter: "string"
    description: "string"
    impact: "string"
    remediation: "string"
    cvss_estimate: "float (0.0-10.0)"
    evidence_ids: "list[string]"
    status: "enum(draft|validated|ready_to_submit|submitted)"
    created_at: "ISO8601"
    updated_at: "ISO8601"

  bypass_attempts:
    attempt_id: "string (uuid4)"
    vuln_class_id: "string"
    technique: "string"
    description: "string"
    payload_used: "string"
    outcome: "enum(success|partial|failure|blocked)"
    response_diff: "string"
    notes: "string"
    timestamp: "ISO8601"

  target_intel:
    target_id: "string (uuid4)"
    domain: "string"
    technologies: "list[string]"
    cms: "string (nullable)"
    frameworks: "list[string]"
    languages: "list[string]"
    waf: "string (nullable)"
    cdn: "string (nullable)"
    server: "string"
    interesting_paths: "list[string]"
    api_endpoints: "list[map]"
    auth_mechanism: "string"

  evidence_chain:
    evidence_id: "string (uuid4)"
    finding_id: "string (nullable)"
    evidence_type: "enum(request|response|screenshot|header|token|payload)"
    data: "string or binary reference"
    redacted: "boolean"
    captured_at: "ISO8601"
    chain_position: "integer"
```

---

## Read/Write Operations

```python
import uuid
import hashlib
from datetime import datetime, timezone, timedelta
from typing import Optional
from enum import Enum


class VulnClassStatus(Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    DEFERRED = "deferred"


class TestStatus(Enum):
    PASSED = "passed"
    FAILED = "failed"
    INCONCLUSIVE = "inconclusive"
    BLOCKED = "blocked"
    ERROR = "error"


class FindingSeverity(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFORMATIONAL = "informational"


class CoreHuntingWorkingMemory:
    """
    In-memory working state for vulnerability hunting.
    Covers all 50 modules from Reconnaissance through PoC Development.
    """

    def __init__(self, target: str = ""):
        self.session_id = str(uuid.uuid4())
        self.target = target
        self.created_at = datetime.now(timezone.utc)

        self.session_state = {
            "session_id": self.session_id,
            "target": target,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "last_activity": datetime.now(timezone.utc).isoformat(),
            "status": "active",
            "current_vuln_class": "",
            "coverage_pct": 0.0,
        }

        self.vuln_class_tracking: dict[str, dict] = {}
        self.test_results: list[dict] = []
        self.findings: dict[str, dict] = {}
        self.bypass_attempts: list[dict] = []
        self.target_intel: dict = {}
        self.evidence_chain: dict[str, dict] = {}

    def start_vuln_class(self, class_name: str) -> str:
        """Begin hunting a specific vulnerability class."""
        vuln_class_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.vuln_class_tracking[vuln_class_id] = {
            "vuln_class_id": vuln_class_id,
            "class_name": class_name,
            "status": VulnClassStatus.IN_PROGRESS.value,
            "tests_run": 0,
            "tests_passed": 0,
            "tests_failed": 0,
            "tests_inconclusive": 0,
            "findings_count": 0,
            "bypass_attempts": [],
            "notes": [],
            "started_at": now,
            "completed_at": None,
        }

        self.session_state["current_vuln_class"] = class_name
        return vuln_class_id

    def record_test(self, vuln_class_id: str, test_name: str,
                    endpoint: str, method: str, payload: str,
                    parameter: str = "", status: str = "failed",
                    response_code: int = 0, response_time_ms: int = 0,
                    response_snippet: str = "", analysis: str = "",
                    confidence: float = 0.0) -> str:
        """Record a test result."""
        test_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        test = {
            "test_id": test_id,
            "vuln_class_id": vuln_class_id,
            "test_name": test_name,
            "test_type": "manual",
            "endpoint": endpoint,
            "method": method,
            "payload": payload,
            "parameter": parameter,
            "status": status,
            "response_code": response_code,
            "response_time_ms": response_time_ms,
            "response_snippet": response_snippet[:2048],
            "analysis": analysis,
            "confidence": confidence,
            "timestamp": now,
        }

        self.test_results.append(test)

        if vuln_class_id in self.vuln_class_tracking:
            vc = self.vuln_class_tracking[vuln_class_id]
            vc["tests_run"] += 1
            if status == "passed":
                vc["tests_passed"] += 1
            elif status == "failed":
                vc["tests_failed"] += 1
            elif status == "inconclusive":
                vc["tests_inconclusive"] += 1

        return test_id

    def create_finding(self, vuln_class: str, title: str, severity: str,
                       endpoint: str, parameter: str = "",
                       description: str = "", impact: str = "",
                       remediation: str = "", cvss_estimate: float = 0) -> str:
        """Create a new finding."""
        finding_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.findings[finding_id] = {
            "finding_id": finding_id,
            "vuln_class": vuln_class,
            "title": title,
            "severity": severity,
            "confidence": "medium",
            "endpoint": endpoint,
            "parameter": parameter,
            "description": description,
            "impact": impact,
            "remediation": remediation,
            "cvss_estimate": cvss_estimate,
            "evidence_ids": [],
            "status": "draft",
            "created_at": now,
            "updated_at": now,
        }

        for vc in self.vuln_class_tracking.values():
            if vc["class_name"] == vuln_class:
                vc["findings_count"] += 1
                break

        return finding_id

    def add_evidence_to_finding(self, finding_id: str,
                                 evidence_type: str, data: str,
                                 redacted: bool = False) -> str:
        """Add evidence to a finding."""
        evidence_id = str(uuid.uuid4())
        chain_pos = len(self.evidence_chain)

        self.evidence_chain[evidence_id] = {
            "evidence_id": evidence_id,
            "finding_id": finding_id,
            "evidence_type": evidence_type,
            "data": data[:1_048_576],
            "redacted": redacted,
            "captured_at": datetime.now(timezone.utc).isoformat(),
            "chain_position": chain_pos,
        }

        self.findings[finding_id]["evidence_ids"].append(evidence_id)
        return evidence_id

    def record_bypass_attempt(self, vuln_class_id: str, technique: str,
                               description: str, payload: str,
                               outcome: str = "failure") -> str:
        """Record a bypass attempt against security controls."""
        attempt_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        attempt = {
            "attempt_id": attempt_id,
            "vuln_class_id": vuln_class_id,
            "technique": technique,
            "description": description,
            "payload_used": payload,
            "outcome": outcome,
            "response_diff": "",
            "notes": "",
            "timestamp": now,
        }

        self.bypass_attempts.append(attempt)

        if vuln_class_id in self.vuln_class_tracking:
            self.vuln_class_tracking[vuln_class_id]["bypass_attempts"].append(attempt)

        return attempt_id

    def complete_vuln_class(self, vuln_class_id: str) -> None:
        """Mark a vulnerability class as completed."""
        vc = self.vuln_class_tracking[vuln_class_id]
        vc["status"] = VulnClassStatus.COMPLETED.value
        vc["completed_at"] = datetime.now(timezone.utc).isoformat()
        self._update_coverage()

    def set_target_intel(self, domain: str, technologies: list[str],
                         cms: str = "", frameworks: Optional[list[str]] = None,
                         waf: str = "", cdn: str = "",
                         server: str = "") -> None:
        """Set target intelligence gathered during recon."""
        self.target_intel = {
            "target_id": str(uuid.uuid4()),
            "domain": domain,
            "technologies": technologies,
            "cms": cms,
            "frameworks": frameworks or [],
            "languages": [],
            "waf": waf,
            "cdn": cdn,
            "server": server,
            "interesting_paths": [],
            "api_endpoints": [],
            "auth_mechanism": "",
        }

    def get_findings_summary(self) -> dict:
        """Get summary of all findings."""
        severity_counts = {"critical": 0, "high": 0, "medium": 0, "low": 0, "informational": 0}
        for f in self.findings.values():
            sev = f["severity"]
            if sev in severity_counts:
                severity_counts[sev] += 1

        return {
            "total_findings": len(self.findings),
            "by_severity": severity_counts,
            "statuses": {
                "draft": sum(1 for f in self.findings.values() if f["status"] == "draft"),
                "validated": sum(1 for f in self.findings.values() if f["status"] == "validated"),
                "ready_to_submit": sum(1 for f in self.findings.values() if f["status"] == "ready_to_submit"),
            },
        }

    def get_hunting_progress(self) -> dict:
        """Get overall hunting progress."""
        total_classes = len(self.vuln_class_tracking)
        completed = sum(1 for vc in self.vuln_class_tracking.values()
                       if vc["status"] == VulnClassStatus.COMPLETED.value)
        total_tests = sum(vc["tests_run"] for vc in self.vuln_class_tracking.values())
        passed_tests = sum(vc["tests_passed"] for vc in self.vuln_class_tracking.values())

        return {
            "session_id": self.session_id,
            "target": self.target,
            "vuln_classes_total": total_classes,
            "vuln_classes_completed": completed,
            "coverage_pct": self.session_state["coverage_pct"],
            "total_tests": total_tests,
            "tests_passed": passed_tests,
            "pass_rate": (passed_tests / max(total_tests, 1)) * 100,
            "findings": len(self.findings),
            "bypass_attempts": len(self.bypass_attempts),
        }

    def get_top_findings(self, limit: int = 5) -> list[dict]:
        """Get top findings by severity and confidence."""
        severity_order = {"critical": 0, "high": 1, "medium": 2, "low": 3, "informational": 4}

        sorted_findings = sorted(
            self.findings.values(),
            key=lambda f: (
                severity_order.get(f["severity"], 5),
                -f["cvss_estimate"]
            )
        )

        return sorted_findings[:limit]

    def _update_coverage(self) -> None:
        """Update overall coverage percentage."""
        total = len(self.vuln_class_tracking)
        if total == 0:
            self.session_state["coverage_pct"] = 0
            return

        completed = sum(1 for vc in self.vuln_class_tracking.values()
                       if vc["status"] in ["completed", "deferred"])
        self.session_state["coverage_pct"] = (completed / total) * 100

    def export_for_report(self) -> dict:
        """Export all data needed for report generation."""
        return {
            "session": self.session_state,
            "target_intel": self.target_intel,
            "findings": list(self.findings.values()),
            "evidence": list(self.evidence_chain.values()),
            "bypass_attempts": self.bypass_attempts,
            "test_summary": {
                vc["class_name"]: {
                    "tests_run": vc["tests_run"],
                    "tests_passed": vc["tests_passed"],
                    "findings": vc["findings_count"],
                }
                for vc in self.vuln_class_tracking.values()
            },
        }

    def cleanup_expired(self) -> int:
        """Remove session data older than TTL."""
        now = datetime.now(timezone.utc)
        started = datetime.fromisoformat(self.session_state["started_at"])
        if (now - started).total_seconds() > 86400:
            self.vuln_class_tracking.clear()
            self.test_results.clear()
            self.findings.clear()
            self.bypass_attempts.clear()
            self.evidence_chain.clear()
            return 1
        return 0
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Vulnerability classes | 25 | FIFO eviction | All major classes covered |
| Test results per session | 50,000 | FIFO truncation | Rolling window |
| Findings | 500 | LRU eviction | Keep highest severity |
| Bypass attempts | 1,000 | FIFO eviction | Per-vuln-class limits |
| Evidence items | 2,000 | LRU eviction | Linked to findings |
| Target intel | 1 | Singleton | Single target per session |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Session expires after 24h.
  - All data wiped except exported findings.

Priority 2: Test Result FIFO
  - When test results exceed 50K, oldest 10% removed.
  - Passed tests preserved longer than failed.

Priority 3: Finding Priority
  - Draft findings with low severity evicted first when at capacity.
  - Validated/ready_to_submit findings never evicted.

Priority 4: Evidence Linked to Evicted Findings
  - Evidence for evicted findings removed cascade-style.
```

---

## Lifecycle

```
1. SESSION INITIALIZATION
   set_target_intel() → start_vuln_class() × N

2. ACTIVE HUNTING
   For each vuln class:
     record_test() × N → analyze results
     If suspicious: create_finding() → add_evidence_to_finding()
     If blocked: record_bypass_attempt()
   complete_vuln_class() → move to next

3. FINDING VALIDATION
   Review findings → set confidence → set severity
   add_evidence_to_finding() for proof

4. REPORT PREPARATION
   get_findings_summary() → export_for_report()

5. SESSION END
   cleanup_expired() → data wiped
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Advanced Automation | Read | Automated scan results for test input |
| Advanced Chaining | Write | Chain primitives from confirmed findings |
| Recon Deep Dive | Read | Target intel for hunting context |
| Bug Bounty Strategy | Write | Findings for submission decisions |
| Report Writing | Write | Validated findings for report generation |

---

## Domain File References (Core-Prompts-hunting/)

### 1-Reconnaissance-and-Asset-Discovery
Reconnaissance methodology and asset discovery prompts.
Working memory stores: recon results, asset inventory, discovery methods.

### 2-Subdomain-Enumeration
Subdomain enumeration techniques and tool orchestration.
Working memory stores: subdomain lists, resolution results, wildcard detection.

### 3-Technology-Fingerprinting
Technology stack identification and fingerprinting.
Working memory stores: tech signatures, version detection, CMS identification.

### 4-Directory-and-File-Discovery
Directory and file discovery methodology.
Working memory stores: discovered paths, response patterns, interesting files.

### 5-Parameter-Discovery-and-Analysis
Parameter discovery and analysis methodology.
Working memory stores: parameter lists, type analysis, value patterns.

### 6-Authentication-Testing
Authentication mechanism testing methodology.
Working memory stores: auth flows, bypass attempts, session analysis.

### 7-Session-Management-Testing
Session management security testing.
Working memory stores: session tokens, cookie analysis, fixation tests.

### 8-Access-Control-Testing
Access control and authorization testing.
Working memory stores: role mappings, IDOR patterns, privilege boundaries.

### 9-Input-Validation-Testing
Input validation and injection testing methodology.
Working memory stores: injection points, filter analysis, bypass techniques.

### 10-XSS-Testing
Cross-site scripting vulnerability testing.
Working memory stores: XSS payloads, context analysis, filter bypasses.

### 11-SQL-Injection-Testing
SQL injection vulnerability testing methodology.
Working memory stores: injection points, database type, extraction methods.

### 12-SSRF-Testing
Server-side request forgery testing methodology.
Working memory stores: SSRF endpoints, internal targets, filter analysis.

### 13-XXE-Testing
XML external entity injection testing.
Working memory stores: XML inputs, file read payloads, SSRF escalation.

### 14-SSTI-Testing
Server-side template injection testing methodology.
Working memory stores: template engines, sandbox analysis, RCE paths.

### 15-File-Inclusion-Testing
Local and remote file inclusion testing.
Working memory stores: LFI/RFI paths, filter bypasses, log poisoning.

### 16-Command-Injection-Testing
OS command injection testing methodology.
Working memory stores: injection points, command separators, filter analysis.

### 17-File-Upload-Testing
File upload vulnerability testing methodology.
Working memory stores: upload restrictions, bypass techniques, RCE vectors.

### 18-CSRF-Testing
Cross-site request forgery testing methodology.
Working memory stores: CSRF tokens, state changes, protection analysis.

### 19-Open-Redirect-Testing
Open redirect vulnerability testing.
Working memory stores: redirect endpoints, filter bypasses, OAuth abuse.

### 20-Misconfiguration-Testing
Security misconfiguration testing methodology.
Working memory stores: misconfigs found, default creds, debug modes.

### 21-API-Security-Testing
REST and GraphQL API security testing.
Working memory stores: API endpoints, auth mechanisms, data exposure.

### 22-Mobile-API-Testing
Mobile API security testing methodology.
Working memory stores: mobile endpoints, TLS pinning, certificate analysis.

### 23-WebSocket-Testing
WebSocket security testing methodology.
Working memory stores: WS endpoints, message injection, auth gaps.

### 24-GraphQL-Security-Testing
GraphQL-specific security testing methodology.
Working memory stores: schema, introspection, authorization gaps.

### 25-CORS-Misconfiguration-Testing
CORS misconfiguration testing methodology.
Working memory stores: origin reflections, credentialed CORS, preflight results.

### 26-Security-Header-Analysis
Security header analysis methodology.
Working memory stores: header values, missing headers, CSP analysis.

### 27-SSL-TLS-Analysis
SSL/TLS configuration analysis.
Working memory stores: cipher suites, protocols, certificate issues.

### 28-DNS-Security-Analysis
DNS security analysis methodology.
Working memory stores: DNS records, zone transfer results, DNSSEC status.

### 29-Cloud-Security-Testing
Cloud infrastructure security testing.
Working memory stores: cloud configs, bucket access, metadata endpoints.

### 30-IoT-Security-Testing
IoT device security testing methodology.
Working memory stores: device protocols, firmware analysis, hardcoded creds.

### 31-Blockchain-Smart-Contract-Testing
Smart contract security testing methodology.
Working memory stores: contract analysis, vulnerability patterns, exploit paths.

### 32-AI-ML-Security-Testing
AI/ML system security testing methodology.
Working memory stores: model analysis, adversarial inputs, data poisoning.

### 33-Race-Condition-Testing
Race condition testing methodology.
Working memory stores: timing analysis, concurrent requests, state manipulation.

### 34-Logic-Flaw-Testing
Business logic flaw testing methodology.
Working memory stores: business rules, workflow analysis, manipulation points.

### 35-Deserialization-Testing
Insecure deserialization testing methodology.
Working memory stores: serialization formats, gadget chains, RCE paths.

### 36-Prototype-Pollution-Testing
JavaScript prototype pollution testing.
Working memory stores: merge sinks, gadget chains, XSS/RCE paths.

### 37-HTTP-Smuggling-Testing
HTTP request smuggling testing methodology.
Working memory stores: parser discrepancies, smuggling payloads, cache effects.

### 38-Cache-Poisoning-Testing
Web cache poisoning testing methodology.
Working memory stores: poisonable headers, cache keys, victim impact.

### 39-Host-Header-Injection-Testing
Host header injection testing methodology.
Working memory stores: injectable headers, password reset abuse, cache poisoning.

### 40-Content-Injection-Testing
Content injection and response splitting testing.
Working memory stores: injection points, header injection, content manipulation.

### 41-WebSocket-Hijacking-Testing
Cross-site WebSocket hijacking testing.
Working memory stores: WS handshakes, origin checks, message authentication.

### 42-Security-Misconfiguration-Audit
Comprehensive security misconfiguration audit.
Working memory stores: misconfig categories, severity mapping, remediation.

### 43-Vulnerability-Validation
Vulnerability validation and confirmation methodology.
Working memory stores: validation steps, false positive analysis, evidence requirements.

### 44-Exploitation-Techniques
Exploitation techniques for confirmed vulnerabilities.
Working memory stores: exploitation methods, payload development, impact demonstration.

### 45-Chaining-Primitives
Identifying and developing chaining primitives.
Working memory stores: primitive types, dependency graphs, chain potential.

### 46-Impact-Assessment
Impact assessment methodology for vulnerabilities.
Working memory stores: impact scenarios, data sensitivity, user exposure.

### 47-Remediation-Verification
Remediation verification testing methodology.
Working memory stores: fix verification, regression testing, bypass checks.

### 48-Continuous-Monitoring-Setup
Continuous monitoring setup for long-term targets.
Working memory stores: monitoring rules, alert thresholds, update detection.

### 49-Reporting-and-Documentation
Reporting and documentation methodology.
Working memory stores: report templates, documentation standards, severity frameworks.

### 50-Reporting-and-Proof-of-Concept-Development
Final reporting and PoC development methodology.
Working memory stores: PoC templates, reproduction steps, impact proof.
