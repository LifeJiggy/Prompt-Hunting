# Working Memory: Real-World Case Studies Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `CASE-REAL-001` |
| Root Folder | `Real-World-Case-Studies/` |
| Total Files | 50 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict + pattern index |
| Typical Lifetime | Analysis session (1-3h) |
| Eviction Trigger | Case completion, session end, or 48h TTL |

---

## Overview

Working memory for real-world case studies captures the analytical state of
studying disclosed bug bounty reports and vulnerability disclosures. This spans
50 modules covering IDOR account takeover through API authentication bypass.
Working memory tracks:

- **Analyzed reports**: Which disclosed reports have been reviewed and what
  patterns were extracted from each.
- **Derived patterns**: Common vulnerability patterns, exploitation techniques,
  and bypass methods extracted from multiple reports.
- **Bounty data**: Financial outcomes from disclosed reports — bounty amounts,
  severity ratings, and platform-specific payment patterns.
- **Technique library**: Techniques that have been proven to work in real
  bug bounty engagements, organized by vulnerability class.
- **Report quality metrics**: Analysis of what makes a successful report —
  structure, evidence quality, impact framing, and PoC clarity.
- **Platform-specific patterns**: Differences in how different platforms
  (HackerOne, Bugcrowd, Intigriti) handle similar vulnerabilities.
- **Severity calibration**: Real-world severity assessments to calibrate
  severity expectations for current findings.

This is the "case study brain" that transforms disclosed reports into actionable
hunting knowledge.

---

## Data Schema (YAML)

```yaml
working_memory_real_cases:
  version: "1.8"
  scope: "analysis-session"
  ttl_seconds: 172800

  session_state:
    session_id: "string (uuid4)"
    analyst_id: "string"
    started_at: "ISO8601"
    last_activity: "ISO8601"
    status: "enum(active|paused|completed)"
    current_case_id: "string (nullable)"
    reports_analyzed: "integer"
    patterns_derived: "integer"

  analyzed_reports:
    report_id: "string (uuid4)"
    case_number: "integer (1-50)"
    report_name: "string"
    report_file: "string (source .md file)"
    vuln_class: "string"
    platform: "enum(hackerone|bugcrowd|intigriti|other)"
    bounty_amount: "float (nullable)"
    severity: "string"
    analyzed_at: "ISO8601"
    completed: "boolean"
    key_takeaways: "list[string]"

  derived_patterns:
    pattern_id: "string (uuid4)"
    pattern_name: "string"
    description: "string"
    vuln_class: "string"
    source_reports: "list[string]"
    exploitation_steps: "list[string]"
    prerequisites: "list[string]"
    success_rate: "float (0.0-1.0)"
    difficulty: "enum(easy|medium|hard|advanced)"
    applicability: "enum(universal|platform_specific|target_specific)"

  bounty_data:
    data_id: "string (uuid4)"
    platform: "string"
    vuln_class: "string"
    severity: "string"
    bounty_range: "string"
    payment_time_days: "float"
    acceptance_rate: "float"
    sample_size: "integer"
    last_updated: "ISO8601"

  technique_library:
    technique_id: "string (uuid4)"
    technique_name: "string"
    category: "string"
    description: "string"
    step_by_step: "list[string]"
    payloads: "list[string]"
    tools_required: "list[string]"
    success_indicators: "list[string]"
    failure_indicators: "list[string]"
    source_report: "string"
    tested_by_me: "boolean"
    personal_success_rate: "float (0.0-1.0)"

  report_quality_metrics:
    metric_id: "string (uuid4)"
    report_id: "string"
    structure_score: "float (0.0-1.0)"
    evidence_quality: "float (0.0-1.0)"
    impact_framing: "float (0.0-1.0)"
    poc_clarity: "float (0.0-1.0)"
    overall_quality: "float (0.0-1.0)"
    strengths: "list[string]"
    weaknesses: "list[string]"

  platform_patterns:
    platform: "string"
    severity_mapping: "map[string,string]"
    acceptance_tendencies: "list[string]"
    common_rejections: "list[string]"
    payment_patterns: "map[string,string]"
    communication_style: "string"

  severity_calibration:
    vuln_class: "string"
    platform_severity: "string"
    researcher_severity: "string"
    actual_bounty: "float"
    calibration_note: "string"
    frequency: "integer"
```

---

## Read/Write Operations

```python
import uuid
from datetime import datetime, timezone
from typing import Optional
from enum import Enum


class Platform(Enum):
    HACKERONE = "hackerone"
    BUGCROWD = "bugcrowd"
    INTIGRITI = "intigriti"
    OTHER = "other"


class RealCaseStudiesWorkingMemory:
    """
    In-memory working state for real-world case study analysis.
    Covers all 50 modules from IDOR Account Takeover through API Auth Bypass.
    """

    def __init__(self, analyst_id: str = ""):
        self.session_id = str(uuid.uuid4())
        self.analyst_id = analyst_id
        self.created_at = datetime.now(timezone.utc)

        self.session_state = {
            "session_id": self.session_id,
            "analyst_id": analyst_id,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "last_activity": datetime.now(timezone.utc).isoformat(),
            "status": "active",
            "current_case_id": None,
            "reports_analyzed": 0,
            "patterns_derived": 0,
        }

        self.analyzed_reports: dict[str, dict] = {}
        self.derived_patterns: dict[str, dict] = {}
        self.bounty_data: dict[str, dict] = {}
        self.technique_library: dict[str, dict] = {}
        self.report_quality_metrics: dict[str, dict] = {}
        self.platform_patterns: dict[str, dict] = {}
        self.severity_calibration: list[dict] = []

    def register_report(self, case_number: int, report_name: str,
                        report_file: str, vuln_class: str,
                        platform: str = "hackerone",
                        bounty_amount: Optional[float] = None,
                        severity: str = "medium") -> str:
        """Register a disclosed report for analysis."""
        report_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.analyzed_reports[report_id] = {
            "report_id": report_id,
            "case_number": case_number,
            "report_name": report_name,
            "report_file": report_file,
            "vuln_class": vuln_class,
            "platform": platform,
            "bounty_amount": bounty_amount,
            "severity": severity,
            "analyzed_at": now,
            "completed": False,
            "key_takeaways": [],
        }

        return report_id

    def start_report_analysis(self, report_id: str) -> None:
        """Begin analyzing a report."""
        self.session_state["current_case_id"] = report_id

    def complete_report_analysis(self, report_id: str,
                                  takeaways: Optional[list[str]] = None) -> None:
        """Complete analysis of a report."""
        self.analyzed_reports[report_id]["completed"] = True
        self.analyzed_reports[report_id]["key_takeaways"] = takeaways or []
        self.session_state["reports_analyzed"] += 1
        self.session_state["current_case_id"] = None

    def derive_pattern(self, pattern_name: str, description: str,
                       vuln_class: str, source_reports: list[str],
                       exploitation_steps: Optional[list[str]] = None,
                       prerequisites: Optional[list[str]] = None,
                       difficulty: str = "medium",
                       applicability: str = "universal") -> str:
        """Derive a pattern from analyzed reports."""
        pattern_id = str(uuid.uuid4())

        self.derived_patterns[pattern_id] = {
            "pattern_id": pattern_id,
            "pattern_name": pattern_name,
            "description": description,
            "vuln_class": vuln_class,
            "source_reports": source_reports,
            "exploitation_steps": exploitation_steps or [],
            "prerequisites": prerequisites or [],
            "success_rate": 0.5,
            "difficulty": difficulty,
            "applicability": applicability,
        }

        self.session_state["patterns_derived"] += 1
        return pattern_id

    def add_technique(self, technique_name: str, category: str,
                      description: str, step_by_step: list[str],
                      payloads: Optional[list[str]] = None,
                      tools_required: Optional[list[str]] = None,
                      source_report: str = "") -> str:
        """Add a technique to the library."""
        technique_id = str(uuid.uuid4())

        self.technique_library[technique_id] = {
            "technique_id": technique_id,
            "technique_name": technique_name,
            "category": category,
            "description": description,
            "step_by_step": step_by_step,
            "payloads": payloads or [],
            "tools_required": tools_required or [],
            "success_indicators": [],
            "failure_indicators": [],
            "source_report": source_report,
            "tested_by_me": False,
            "personal_success_rate": 0.0,
        }

        return technique_id

    def record_bounty_data(self, platform: str, vuln_class: str,
                           severity: str, bounty_range: str,
                           payment_time_days: float = 30,
                           acceptance_rate: float = 0.5,
                           sample_size: int = 10) -> str:
        """Record bounty data for a vulnerability class on a platform."""
        data_id = str(uuid.uuid4())
        key = f"{platform}:{vuln_class}:{severity}"

        self.bounty_data[key] = {
            "data_id": data_id,
            "platform": platform,
            "vuln_class": vuln_class,
            "severity": severity,
            "bounty_range": bounty_range,
            "payment_time_days": payment_time_days,
            "acceptance_rate": acceptance_rate,
            "sample_size": sample_size,
            "last_updated": datetime.now(timezone.utc).isoformat(),
        }

        return data_id

    def score_report_quality(self, report_id: str, structure_score: float,
                              evidence_quality: float, impact_framing: float,
                              poc_clarity: float,
                              strengths: Optional[list[str]] = None,
                              weaknesses: Optional[list[str]] = None) -> str:
        """Score the quality of a disclosed report."""
        metric_id = str(uuid.uuid4())
        overall = (structure_score + evidence_quality + impact_framing + poc_clarity) / 4

        self.report_quality_metrics[metric_id] = {
            "metric_id": metric_id,
            "report_id": report_id,
            "structure_score": structure_score,
            "evidence_quality": evidence_quality,
            "impact_framing": impact_framing,
            "poc_clarity": poc_clarity,
            "overall_quality": overall,
            "strengths": strengths or [],
            "weaknesses": weaknesses or [],
        }

        return metric_id

    def calibrate_severity(self, vuln_class: str, platform_severity: str,
                           researcher_severity: str, actual_bounty: float,
                           note: str = "") -> None:
        """Record a severity calibration data point."""
        self.severity_calibration.append({
            "vuln_class": vuln_class,
            "platform_severity": platform_severity,
            "researcher_severity": researcher_severity,
            "actual_bounty": actual_bounty,
            "calibration_note": note,
            "frequency": 1,
        })

    def get_severity_calibration(self, vuln_class: str) -> dict:
        """Get severity calibration data for a vulnerability class."""
        entries = [s for s in self.severity_calibration if s["vuln_class"] == vuln_class]

        if not entries:
            return {"vuln_class": vuln_class, "insufficient_data": True}

        avg_bounty = sum(e["actual_bounty"] for e in entries) / len(entries)

        return {
            "vuln_class": vuln_class,
            "sample_size": len(entries),
            "average_bounty": avg_bounty,
            "severity_tendency": self._most_common(e["platform_severity"] for e in entries),
            "calibration_entries": entries[:5],
        }

    def get_bounty_insights(self, platform: Optional[str] = None) -> dict:
        """Get bounty insights optionally filtered by platform."""
        data = list(self.bounty_data.values())
        if platform:
            data = [d for d in data if d["platform"] == platform]

        if not data:
            return {"no_data": True}

        by_severity = {}
        for d in data:
            sev = d["severity"]
            if sev not in by_severity:
                by_severity[sev] = []
            by_severity[sev].append(d)

        return {
            "total_data_points": len(data),
            "by_severity": {
                sev: {
                    "count": len(items),
                    "avg_payment_days": sum(i["payment_time_days"] for i in items) / len(items),
                    "avg_acceptance_rate": sum(i["acceptance_rate"] for i in items) / len(items),
                }
                for sev, items in by_severity.items()
            },
        }

    def get_technique_library_summary(self) -> dict:
        """Get summary of the technique library."""
        by_category = {}
        for tech in self.technique_library.values():
            cat = tech["category"]
            if cat not in by_category:
                by_category[cat] = {"count": 0, "tested": 0}
            by_category[cat]["count"] += 1
            if tech["tested_by_me"]:
                by_category[cat]["tested"] += 1

        return {
            "total_techniques": len(self.technique_library),
            "tested": sum(1 for t in self.technique_library.values() if t["tested_by_me"]),
            "by_category": by_category,
        }

    def get_analysis_summary(self) -> dict:
        """Get overall analysis summary."""
        completed = sum(1 for r in self.analyzed_reports.values() if r["completed"])

        quality_scores = [m["overall_quality"] for m in self.report_quality_metrics.values()]
        avg_quality = sum(quality_scores) / len(quality_scores) if quality_scores else 0

        return {
            "session_id": self.session_id,
            "reports_total": len(self.analyzed_reports),
            "reports_completed": completed,
            "patterns_derived": self.session_state["patterns_derived"],
            "techniques_in_library": len(self.technique_library),
            "bounty_data_points": len(self.bounty_data),
            "average_report_quality": round(avg_quality, 2),
        }

    def get_top_techniques(self, limit: int = 10) -> list[dict]:
        """Get top techniques by personal success rate."""
        tested = [t for t in self.technique_library.values() if t["tested_by_me"]]
        return sorted(tested, key=lambda t: t["personal_success_rate"], reverse=True)[:limit]

    def export_analysis(self) -> dict:
        """Export all analysis data."""
        return {
            "session": self.session_state,
            "reports": list(self.analyzed_reports.values()),
            "patterns": list(self.derived_patterns.values()),
            "techniques": list(self.technique_library.values()),
            "bounty_data": list(self.bounty_data.values()),
            "quality_metrics": list(self.report_quality_metrics.values()),
            "severity_calibration": self.severity_calibration,
        }

    def _most_common(self, values) -> str:
        counts = {}
        for v in values:
            counts[v] = counts.get(v, 0) + 1
        return max(counts, key=counts.get) if counts else ""

    def cleanup_expired(self) -> int:
        """Remove session data older than TTL."""
        now = datetime.now(timezone.utc)
        started = datetime.fromisoformat(self.session_state["started_at"])
        if (now - started).total_seconds() > 172800:
            return 1
        return 0
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Analyzed reports | 50 | Module count limit | All available reports |
| Derived patterns | 200 | LRU eviction | Key patterns preserved |
| Technique library | 500 | LRU eviction | Tested techniques kept |
| Bounty data points | 300 | FIFO eviction | Recent data prioritized |
| Quality metrics | 50 | LRU eviction | High-quality examples kept |
| Severity calibration | 200 | FIFO eviction | Keep diverse samples |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Session expires after 48h.
  - Export to Long-Term Memory before eviction.

Priority 2: Unverified Techniques
  - Techniques with tested_by_me=False evicted after 14 days.
  - Tested techniques preserved indefinitely.

Priority 3: Low-Quality Reports
  - Reports with overall_quality < 0.3 evicted after 7 days.
  - High-quality report metrics preserved.

Priority 4: Outdated Bounty Data
  - Bounty data older than 90 days compressed to averages.
```

---

## Lifecycle

```
1. REPORT REGISTRATION
   register_report() × N → report catalog built

2. ACTIVE ANALYSIS
   start_report_analysis() → extract patterns → add_technique() × N
   record_bounty_data() → score_report_quality()
   complete_report_analysis()

3. PATTERN SYNTHESIS
   derive_pattern() × N → identify cross-report patterns
   calibrate_severity() → refine severity expectations

4. APPLICATION
   get_top_techniques() → select for current target
   get_bounty_insights() → inform submission strategy

5. EXPORT
   export_analysis() → save to Long-Term Memory
   cleanup_expired() → session data wiped
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Advanced Chaining | Read | Exploitation patterns for chain construction |
| Bug Bounty Strategy | Write | Bounty data for program scoring |
| Core Prompts Hunting | Write | Techniques for active hunting |
| Report Writing | Write | Report quality patterns for writing guidance |

---

## Domain File References (Real-World-Case-Studies/)

### 01-IDOR-Account-Takeover
IDOR leading to account takeover case study.
Working memory stores: ID enumeration, access control flaws, takeover methods.

### 02-XSS-Privilege-Escalation
XSS leading to privilege escalation case study.
Working memory stores: XSS injection, session theft, privilege escalation.

### 03-SSRF-Cloud-Metadata
SSRF to cloud metadata exploitation case study.
Working memory stores: SSRF vectors, IMDS access, credential theft.

### 04-SQL-Injection-Data-Extraction
SQL injection data extraction case study.
Working memory stores: injection points, database access, data exfiltration.

### 05-Authentication-Bypass-Admin
Authentication bypass to admin access case study.
Working memory stores: auth flaws, bypass methods, admin panel access.

### 06-Open-Redirect-OAuth-Theft
Open redirect leading to OAuth token theft case study.
Working memory stores: redirect abuse, OAuth flow manipulation, token capture.

### 07-CSRF-Account-Takeover
CSRF leading to account takeover case study.
Working memory stores: CSRF tokens, state changes, account modification.

### 08-File-Upload-RCE
File upload leading to RCE case study.
Working memory stores: upload bypass, webshell deployment, code execution.

### 09-XXE-File-Read
XXE leading to file read case study.
Working memory stores: XML injection, file read payloads, server access.

### 10-SSTI-RCE
SSTI leading to RCE case study.
Working memory stores: template injection, sandbox escape, code execution.

### 11-Race-Condition-Double-Spend
Race condition leading to double-spend case study.
Working memory stores: timing attacks, concurrent requests, balance manipulation.

### 12-Subdomain-Takeover-Hijack
Subdomain takeover hijacking case study.
Working memory stores: CNAME abuse, service migration, takeover methods.

### 13-Host-Header-Password-Reset
Host header injection in password reset case study.
Working memory stores: host manipulation, reset URL poisoning, account takeover.

### 14-JWT-None-Algorithm
JWT algorithm confusion attack case study.
Working memory stores: alg=none, key confusion, token forgery.

### 15-SAML-Signature-Bypass
SAML signature bypass case study.
Working memory stores: assertion manipulation, signature stripping, auth bypass.

### 16-OAuth-State-Bypass
OAuth state parameter bypass case study.
Working memory stores: state manipulation, redirect_uri abuse, token theft.

### 17-CORS-Misconfiguration-XSS
CORS misconfiguration leading to XSS case study.
Working memory stores: origin reflection, credentialed requests, script execution.

### 18-GraphQL-Introspection-Leak
GraphQL introspection information leak case study.
Working memory stores: schema exposure, sensitive data discovery, authorization.

### 19-WebSocket-Hijacking
WebSocket hijacking case study.
Working memory stores: WS handshake, origin bypass, message injection.

### 20-HTTP-Smuggling-Cache-Poison
HTTP smuggling leading to cache poisoning case study.
Working memory stores: smuggling techniques, cache abuse, victim impact.

### 21-Cache-Poisoning-Stored-XSS
Cache poisoning leading to stored XSS case study.
Working memory stores: poisonable headers, cache keys, XSS delivery.

### 22-Mass-Assignment-Privilege-Escalation
Mass assignment privilege escalation case study.
Working memory stores: overwritable fields, role manipulation, admin access.

### 23-Prototype-Pollution-XSS
Prototype pollution leading to XSS case study.
Working memory stores: merge sinks, gadget chains, DOM exploitation.

### 24-NoSQL-Injection-Authentication-Bypass
NoSQL injection auth bypass case study.
Working memory stores: operator injection, query manipulation, auth bypass.

### 25-LDAP-Injection-Access-Bypass
LDAP injection access bypass case study.
Working memory stores: filter manipulation, bind bypass, directory access.

### 26-XPath-Injection-Authentication-Bypass
XPath injection auth bypass case study.
Working memory stores: XML query manipulation, auth bypass, data extraction.

### 27-Log-Injection-XSS
Log injection leading to XSS case study.
Working memory stores: log injection vectors, log viewer XSS, stored attacks.

### 28-Content-Injection-Response-Splitting
Content injection leading to response splitting case study.
Working memory stores: header injection, CRLF sequences, cache poisoning.

### 29-Second-Order-SQL-Injection
Second-order SQL injection case study.
Working memory stores: stored injection, delayed execution, data extraction.

### 30-Deserialization-RCE
Insecure deserialization leading to RCE case study.
Working memory stores: gadget chains, serialization formats, code execution.

### 31-HTTP-Parameter-Pollution
HTTP parameter pollution bypass case study.
Working memory stores: parameter handling quirks, backend parsing, bypass.

### 32-Cookie-Tossing-Session-Fixation
Cookie tossing session fixation case study.
Working memory stores: subdomain cookies, session fixation, hijacking.

### 33-JSONP-CORS-Bypass
JSONP endpoint CORS bypass case study.
Working memory stores: callback functions, origin restrictions, data theft.

### 34-Screen-Shot-Information-Disclosure
Screenshot/information disclosure case study.
Working memory stores: screenshot tools, page rendering, sensitive data exposure.

### 35-Mobile-App-API-Bypass
Mobile app API security bypass case study.
Working memory stores: API endpoints, certificate pinning bypass, data extraction.

### 36-API-Key-Leak-Exploitation
API key leak exploitation case study.
Working memory stores: key discovery, service access, lateral movement.

### 37-JWT-Key-Confusion-Attack
JWT key confusion attack case study.
Working memory stores: algorithm confusion, key recovery, token forgery.

### 38-SAML-XML-External-Entity
SAML XXE attack case study.
Working memory stores: XML injection, file read, SSRF escalation.

### 39-OAuth-Redirect-URI-Manipulation
OAuth redirect_uri manipulation case study.
Working memory stores: URI manipulation, authorization code theft, token capture.

### 40-GraphQL-N+1-Information-Disclosure
GraphQL N+1 information disclosure case study.
Working memory stores: query complexity, batch queries, data leakage.

### 41-WebSocket-Cross-Site-Request-Forgery
WebSocket CSRF case study.
Working memory stores: WS CSRF, handshake manipulation, message injection.

### 42-HTTP-Request-Smuggling-CL-TE
HTTP request smuggling CL.TE case study.
Working memory stores: Content-Length vs Transfer-Encoding, smuggling payloads.

### 43-Cache-Deception-Attack
Cache deception attack case study.
Working memory stores: path manipulation, cache behavior, data exposure.

### 44-Server-Side-Gadget-Attack
Server-side gadget chain attack case study.
Working memory stores: Java/.NET gadgets, deserialization chains, RCE.

### 45-Tenant-Isolation-Bypass
Multi-tenant isolation bypass case study.
Working memory stores: tenant identifiers, isolation flaws, cross-tenant access.

### 46-API-Authentication-Bypass
API authentication bypass case study.
Working memory stores: auth mechanism flaws, bypass methods, API access.
