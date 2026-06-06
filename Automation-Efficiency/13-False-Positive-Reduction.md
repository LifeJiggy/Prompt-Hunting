# 13 — False Positive Reduction

## 1. Why FP Reduction Is Not Optional

False positives consume the most expensive resource in any assessment pipeline: human attention. A typical nuclei run produces hundreds of matches; 60–80% are false positives. Automated triage and FP filtering are the difference between a 3-day assessment and an 18-day assessment. Every stage of the pipeline—scanner → enricher → deduplicator → triager → reporter—needs a checkbox to reduce noise.

---

## 2. Confidence Scoring Heuristics

A confidence score (0.0–1.0) replaces binary pass/fail with a graded signal. Score adjustments are additive:

```python
from dataclasses import dataclass, field

@dataclass
class ConfidenceScore:
    raw: float = 0.5
    components: dict = field(default_factory=dict)

    def apply(self, name: str, delta: float):
        self.raw = max(0.0, min(1.0, self.raw + delta))
        self.components[name] = self.components.get(name, 0.0) + delta

    def label(self) -> str:
        if self.raw >= 0.80: return "Very High"
        if self.raw >= 0.60: return "High"
        if self.raw >= 0.35: return "Medium"
        return "Low"
```

### Applying Heuristics

```python
def score_finding(finding: dict, ctx: dict) -> ConfidenceScore:
    score = ConfidenceScore()
    body = ctx.get("response_body", b"")
    status = ctx.get("status_code", 200)
    tool = ctx.get("tool", "")

    if tool == "manual":                  score.apply("tool_manual", 0.25)
    elif tool == "nuclei_verified":       score.apply("tool_verified", 0.30)
    elif tool == "ffuf":                  score.apply("tool_auto", -0.15)
    if status >= 500:                     score.apply("server_error", -0.20)

    FP_STRINGS = [
        b"Cannot GET", b"Cannot POST",
        b"The requested URL was not found",
        b"JBWEB000124", b"No such file",
    ]
    if any(sig in body for sig in FP_STRINGS):
        score.apply("generic_error_sig", -0.30)

    if ctx.get("param_reflected"):        score.apply("reflected", 0.20)
    if ctx.get("tool_count", 1) >= 2:     score.apply("multi_tool", 0.35)
    baseline = ctx.get("baseline_size", 0)
    if baseline and abs(len(body) - baseline) > baseline * 0.05:
        score.apply("non_baseline_size", 0.10)
    return score
```

---

## 3. Context-Aware Filtering

### Auth Context

```python
from dataclasses import dataclass

@dataclass
class AuthContext:
    has_session_cookie: bool = False
    is_admin_role: bool = False
    is_csrf_token_valid: bool = False

    def authenticated(self) -> bool: return self.has_session_cookie
```

### Context-Aware Predicate

```python
def is_contextually_valid(finding: dict, ctx: AuthContext) -> bool:
    vt = finding.get("vuln_type", "").lower()
    if "idor" in vt and not ctx.has_session_cookie:
        return False
    if "csrf" in vt and not ctx.is_csrf_token_valid:
        return False
    return True
```

---

## 4. Historical FP Pattern Libraries

FP patterns from past sessions are the strongest predictor for future FPs. Persist and query them on every new finding.

```python
from dataclasses import dataclass, field
from pathlib import Path
import json, hashlib

@dataclass
class FPPattern:
    pattern_type: str     # response_hash | response_substring | status_code
    value: str
    vuln_types: list[str]
    tool: str = ""
    auto_added: bool = False
    match_count: int = 0

def load_fp_patterns(path: str = "fp_patterns.jsonl") -> list[FPPattern]:
    patterns: list[FPPattern] = []
    p = Path(path)
    if not p.exists(): return patterns
    for line in p.read_text(encoding="utf-8").splitlines():
        if line.strip(): patterns.append(FPPattern(**json.loads(line)))
    return patterns

def apply_fp_patterns(score: ConfidenceScore, finding: dict,
                      body: bytes, patterns: list[FPPattern]):
    body_hash = hashlib.md5(body).hexdigest()[:12]
    vt = finding.get("vuln_type", "").lower()
    for pat in patterns:
        if not any(v.lower() in vt for v in pat.vuln_types):
            continue
        if pat.pattern_type == "response_hash" and pat.value == body_hash:
            score.apply(f"fp_hash_{pat.value}", -0.40)
        elif pat.pattern_type == "response_substring" and pat.value.encode() in body:
            score.apply(f"fp_sub_{pat.value[:30]}", -0.35)
```

---

## 5. Response Pattern Whitelisting

Whitelisted patterns are suppressed before they reach the triage queue.

```python
import re

@dataclass
class WhitelistEntry:
    whitelist_type: str   # response_regex | status_code | url_suffix | header_value
    value: str
    applies_to: list[str] = field(default_factory=list)
    reason: str = ""

def apply_whitelist(finding: dict, whitelist: list[WhitelistEntry],
                    program_id: str) -> bool:
    body = finding.get("response_body", b"").decode("utf-8", errors="replace")
    status = finding.get("status_code", 200)
    url = finding.get("url", "").lower()
    vt = finding.get("vuln_type", "").lower()

    for entry in whitelist:
        if entry.applies_to and not any(v.lower() in vt for v in entry.applies_to):
            continue
        match entry.whitelist_type:
            case "response_regex":
                if re.search(entry.value, body, re.I): return False
            case "status_code":
                if str(status) == entry.value: return False
            case "url_suffix":
                if url.endswith(entry.value.lower()): return False
    return True
```

---

## 6. CDN/WAF Noise Detection

CDN error pages and WAF challenge pages are a major FP source. Identify them by header and body signatures.

```python
CDN_FP = {
    "cloudflare": {
        "headers": [("server", "cloudflare")],
        "body_signatures": [b"Cloudflare Ray ID", b"Just a moment"],
    },
    "aws_waf": {
        "headers": [("server", "awselb")],
        "body_signatures": [b"403 Forbidden"],
    },
}

@dataclass
class CDNFPResult:
    cdn: str | None
    is_challenge_page: bool
    evidence: list[str]

def detect_cdn_fp(headers: dict, body: bytes) -> CDNFPResult:
    hl = {k.lower(): v.lower() for k, v in headers.items()}
    for cdn, sigs in CDN_FP.items():
        if all(hl.get(k, "") == v for k, v in sigs["headers"]):
            is_challenge = any(s in body for s in [b"verify you are human", b"Just a moment"])
            return CDNFPResult(cdn=cdn, is_challenge_page=is_challenge, evidence=sigs["body_signatures"])
    return CDNFPResult(None, False, [])
```

---

## 7. Auto-Dismissal Rules

Auto-dismissal must be conservative: never dismiss High or Critical findings.

```python
from enum import Enum

class DismissalTrigger(Enum):
    FP_PATTERN_MATCH = "fp_pattern_match"
    CDN_FP = "cdn_fp"
    CONFIDENCE_BELOW = "confidence_below"

class AutoDismissalRule:
    def __init__(self, trigger: DismissalTrigger, threshold: float | None,
                 vuln_types: list[str], max_severity: str):
        self.trigger = trigger
        self.threshold = threshold
        self.vuln_types = vuln_types
        self.mx_sev = max_severity

    def applies(self, finding: dict, score: ConfidenceScore) -> bool:
        sev = {"info":0,"low":1,"medium":2,"high":3,"critical":4}[finding.get("severity","info")]
        if sev > {"info":0,"low":1,"medium":2,"high":3,"critical":4}[self.mx_sev]: return False
        if self.vuln_types and not any(v.lower() in finding.get("vuln_type","").lower() for v in self.vuln_types):
            return False
        match self.trigger:
            case DismissalTrigger.FP_PATTERN_MATCH if finding.get("fp_matched"): return True
            case DismissalTrigger.CDN_FP if finding.get("cdn_fp",{}).get("is_challenge_page"): return True
            case DismissalTrigger.CONFIDENCE_BELOW if score.raw < self.threshold: return True
        return False

DEFAULT_RULES = [
    AutoDismissalRule(DismissalTrigger.CONFIDENCE_BELOW, 0.15, [], "low"),
    AutoDismissalRule(DismissalTrigger.FP_PATTERN_MATCH, None, [], "low"),
    AutoDismissalRule(DismissalTrigger.CDN_FP, None, [], "low"),
]
```

---

## 8. Manual Triage Integration

Dismissed findings go to a triage queue, not oblivion. Queue sorted by priority score.

```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass
class TriageQueueEntry:
    finding_id: str
    program_id: str
    finding: dict
    score: ConfidenceScore
    status: str = "pending"    # pending | confirmed_fp | dismissed_fp | escalated
    dismissal_rule: str = ""
    triaged_by: str = ""
    priority_score: float = 0.0

    def compute_priority(self):
        sr = {"info":0,"low":1,"medium":2,"high":3,"critical":4}
        sev = sr.get(self.finding.get("severity","info"), 0) / 4.0
        self.priority_score = self.score.raw * 0.6 + sev * 0.4

class TriageQueue:
    def __init__(self):
        self._queue: list[TriageQueueEntry] = []

    def enqueue(self, finding: dict, program_id: str, score: ConfidenceScore, rule: str = ""):
        e = TriageQueueEntry(
            finding_id=finding["id"], program_id=program_id, finding=finding, score=score, dismissal_rule=rule
        )
        e.compute_priority()
        self._queue.append(e)
        self._queue.sort(key=lambda x: x.priority_score, reverse=True)

    def pending(self) -> list[TriageQueueEntry]:
        return [e for e in self._queue if e.status == "pending"]
```

---

## 9. FP Feedback Loop

When a human marks a finding as FP, the decision immediately reinforces the FP filter.

```python
class FPFeedbackLoop:
    def __init__(self, patterns_path: str, whitelist_path: str):
        self.patterns_path = Path(patterns_path)
        self.whitelist_path = Path(whitelist_path)

    def record_fp(self, finding: dict, body: bytes, headers: dict, triager: str):
        body_hash = hashlib.md5(body).hexdigest()[:12]
        self._append("fp_patterns.jsonl", {
            "pattern_type": "response_hash",
            "value": body_hash,
            "vuln_types": [finding.get("vuln_type", "")],
            "tool": finding.get("tool", "unknown"),
            "reviewed_by": triager, "auto_added": True,
            "created_at": datetime.utcnow().isoformat(),
        })
        first_line = next((l for l in body[:2048].decode("utf-8", errors="replace").splitlines()
                           if l.strip() and not l.lstrip().startswith("<")), "")
        if first_line:
            self._append("fp_patterns.jsonl", {
                "pattern_type": "response_substring",
                "value": first_line[:120],
                "vuln_types": [finding.get("vuln_type", "")],
                "tool": finding.get("tool", "unknown"),
                "reviewed_by": triager, "auto_added": True,
                "created_at": datetime.utcnow().isoformat(),
            })

    def _append(self, filepath: str, record: dict):
        with open(filepath, "a", encoding="utf-8") as f:
            f.write(json.dumps(record) + "\n")
```

---

## 10. Platform-Specific FP Patterns

Each server emits highly specific false positive signals.

### Python / Django
```
"Please enter a correct username and password"  # generic auth fail, not info leak
"CSRF verification failed. Request aborted."    # generic CSRF error
```

### Node.js / Express
```
"Cannot GET"  # Express default 404 — not RCE
"Cannot POST" # Express default 405
```

### PHP
```
"The requested URL was not found on this server"  # generic Apache 404
"No input file specified."                         # PHP-FPM blackhole
"A PHP Error was encountered"                      # CodeIgniter debug
```

### ASP.NET / IIS
```
"The resource cannot be found"  # ASP.NET generic 404
"Runtime Error"                 # ASP.NET unhandled exception
```

### Serverless / Lambda
```
"InternalServerErrorException"  # Lambda default error
"Task timed out after"           # Lambda timeout signal
```

---

## 11. FP Database Schema

```sql
CREATE TABLE fp_patterns (
    id            SERIAL PRIMARY KEY,
    pattern_type  TEXT NOT NULL,
    value         TEXT NOT NULL,
    tool          TEXT NOT NULL,
    vuln_types    TEXT[] NOT NULL,
    auto_added    BOOLEAN DEFAULT FALSE,
    reviewed_by   TEXT,
    created_at    TIMESTAMP DEFAULT NOW(),
    last_matched  TIMESTAMP,
    match_count   INTEGER DEFAULT 0
);

CREATE TABLE auto_dismissal_log (
    finding_id    TEXT NOT NULL,
    program_id    TEXT NOT NULL,
    dismissal_rule TEXT NOT NULL,
    dismissed_at  TIMESTAMP DEFAULT NOW(),
    reviewed_by   TEXT,
    notes         TEXT
);
```

---

## 12. Quick-Reference Checklist

- [ ] `ConfidenceScore` starts at 0.5 with additive delta modifiers
- [ ] `score_finding()` applies tool weight, status-code penalty, and generic-error signature checks
- [ ] `is_contextually_valid()` gates IDOR on auth state and CSRF on token validity
- [ ] `apply_fp_patterns()` queries `fp_patterns.jsonl` before triage
- [ ] `apply_whitelist()` suppresses known-safe response patterns entirely
- [ ] `detect_cdn_fp()` classifies Cloudflare/AWS WAF challenge pages
- [ ] `AutoDismissalRule` never dismisses findings above configured `max_severity`
- [ ] `TriageQueue` holds dismissed findings in priority-sorted queue for human review
- [ ] `FPFeedbackLoop.write_fp()` immediately appends new patterns on human-confirmed FP
- [ ] Platform registry (django, express, php, aspnet, lambda) loaded at scan startup
