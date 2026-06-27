# Real-World Case Studies — Tool Execution Domain

**Component:** Tool Executor for Disclosed Vulnerability Patterns  
**Domain:** `real-world-case-studies`  
**Registry:** `Real-World-Case-Studies/registry.json`  
**File Count:** 50 prompt files  
**Execution Mode:** Pattern tool execution for vulnerability analysis

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `real-world-case-studies` |
| Domain Path | `Real-World-Case-Studies/` |
| Category | `disclosed` |
| Execution Profile | `pattern-analyzer` |
| Default Timeout | 120s |
| Max Timeout | 600s |
| Default Retries | 2 |
| Concurrency Limit | 8 |
| Stealth Level | `none` |
| Rate Limit | 30 req/s |

---

## Overview

The Real-World Case Studies executor manages tool execution for disclosed vulnerability pattern analysis. This domain covers 50 prompt files spanning IDOR account takeover cases, stored XSS persistent attacks, SQL injection data breaches, SSRF internal network access, CSRF state-changing attacks, command injection RCE, deserialization RCE, file upload arbitrary upload, XXE attacks, SSTI, JWT token manipulation, authentication bypass, privilege escalation, business logic flaws, information disclosure, memory corruption heap overflow, Java deserialization, PHP unserialize, Python pickle, race conditions, host header injection, DNS rebinding attacks, WebSocket security issues, GraphQL introspection attacks, CSP bypass techniques, clickjacking UI redressing, HTTP response splitting, LDAP injection attacks, XPath injection attacks, NoSQL injection MongoDB, prototype pollution JavaScript, subdomain takeover, open redirect phishing, content spoofing attacks, webcache poisoning, HTTP request smuggling, WebSocket hijacking, CORS misconfiguration, token leakage URL parameters, sensitive data exposure, weak encryption algorithms, insecure cryptographic storage, path traversal file inclusion, local file inclusion, remote file inclusion, SSRF (variant), client-side request forgery, mobile API security issues, cloud misconfiguration AWS, and API authentication bypass.

This executor runs pattern analysis tools that extract exploitation techniques, detection signatures, and remediation guidance from disclosed vulnerability cases.

---

## Execution Schema

### PatternInvocation (Input)

```json
{
  "tool": "string — pattern analysis tool",
  "pattern_type": "string — exploitation|detection|remediation|comparison",
  "input": {
    "vuln_class": "string — vulnerability class",
    "case_id": "string — specific case identifier",
    "extraction": ["string — what to extract"],
    "comparison_target": "string — compare against"
  },
  "config": {
    "timeout": "number",
    "retries": "number",
    "detail_level": "string — brief|standard|detailed"
  }
}
```

### PatternResult (Output)

```json
{
  "status": "string",
  "pattern": {
    "type": "string",
    "vuln_class": "string",
    "exploitation": {
      "technique": "string",
      "payloads": ["string"],
      "conditions": ["string"],
      "impact": "string"
    },
    "detection": {
      "signatures": ["string"],
      "indicators": ["string"],
      "tools": ["string"]
    },
    "remediation": {
      "fix": "string",
      "prevention": ["string"],
      "references": ["string"]
    }
  },
  "cases_referenced": "number",
  "duration_ms": "number"
}
```

---

## Run Operations

### Pattern Analysis

```python
def run_pattern_analysis(
    self,
    tool: str,
    pattern_type: str,
    input_data: dict,
    config: dict = None
) -> PatternResult:
    """
    Execute a pattern analysis tool.
    
    Flow:
    1. Load case study data
    2. Apply pattern extraction algorithm
    3. Generate exploitation techniques
    4. Create detection signatures
    5. Formulate remediation guidance
    6. Return structured pattern
    """
```

### Exploitation Pattern Extraction

```python
def extract_exploitation_pattern(
    self,
    vuln_class: str
) -> PatternResult:
    """
    Extract exploitation patterns for a vulnerability class.
    Returns payloads, conditions, and impact analysis.
    """
```

### Detection Pattern Generation

```python
def generate_detection_pattern(
    self,
    vuln_class: str
) -> PatternResult:
    """
    Generate detection patterns for a vulnerability class.
    Returns signatures, indicators, and tool recommendations.
    """
```

---

## Stop Operations

### Pattern Stop

```python
def stop_pattern_analysis(
    self,
    invocation_id: str
) -> StopResult:
    """Stop a running pattern analysis."""
```

---

## Retry Operations

### Pattern Retry Configuration

```python
@dataclass
class PatternRetryConfig:
    max_retries: int = 2
    backoff_base: float = 1.0
    retry_on_parse_error: bool = True
    retry_on_timeout: bool = True
```

---

## Timeout Handling

### Pattern Timeout Configuration

```python
@dataclass
class PatternTimeoutConfig:
    default: int = 120
    overrides: dict[str, int] = field(default_factory=lambda: {
        "exploitation_pattern": 180,
        "detection_pattern": 120,
        "remediation_generation": 60,
        "case_comparison": 300,
        "technique_extraction": 120,
        "payload_generation": 180
    })
    hard_maximum: int = 600
```

---

## Output Capture

### Pattern Output Capture

```python
@dataclass
class PatternCapturedOutput:
    pattern: dict
    cases_referenced: int
    payloads_extracted: int
    detection_signatures: int
    duration_ms: int
```

---

## Stderr Handling

### Pattern Stderr Processing

```python
def _process_stderr(self, stderr: str) -> StderrResult:
    """Process pattern analysis stderr."""
    return StderrResult(
        raw=stderr,
        classification="pattern_error",
        retryable=True
    )
```

---

## Exit Code Handling

### Pattern Exit Code Processing

```python
def _process_exit_code(self, exit_code: int) -> ExitCodeResult:
    """Process pattern exit code."""
    if exit_code == 0:
        return ExitCodeResult(status="success", action="return_pattern")
    return ExitCodeResult(status="error", action="retry")
```

---

## Concurrent Execution

### Pattern Concurrency Configuration

```python
@dataclass
class PatternConcurrencyConfig:
    max_concurrent: int = 8
    max_per_vuln_class: int = 4
    parallel_patterns: bool = True
```

---

## Execution Logging

### Pattern Execution Log

```python
@dataclass
class PatternExecutionLog:
    invocation_id: str
    tool: str
    pattern_type: str
    vuln_class: str
    cases_referenced: int
    duration_ms: int
    timestamp: str
```

---

## Full Domain File References

### Category: IDOR

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 01 | `01-IDOR-Account-Takeover-Case-Studies.md` | IDOR Account Takeover Case Studies | exploitation | critical |

### Category: XSS

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 02 | `02-XSS-Stored-Persistent-Attacks.md` | XSS Stored Persistent Attacks | exploitation | high |

### Category: SQL Injection

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 03 | `03-SQL-Injection-Data-Breaches.md` | SQL Injection Data Breaches | exploitation | critical |

### Category: SSRF

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 04 | `04-SSRF-Internal-Network-Access.md` | SSRF Internal Network Access | exploitation | high |

### Category: CSRF

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 05 | `05-CSRF-State-Changing-Attacks.md` | CSRF State-Changing Attacks | exploitation | high |

### Category: Command Injection

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 06 | `06-Command-Injection-RCE.md` | Command Injection RCE | exploitation | critical |

### Category: Deserialization

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 07 | `07-Deserialization-Remote-Code-Execution.md` | Deserialization Remote Code Execution | exploitation | critical |
| 17 | `17-Deserialization-Java-Deserialization.md` | Deserialization Java Deserialization | exploitation | critical |
| 18 | `18-Deserialization-PHP-Unserialize.md` | Deserialization PHP Unserialize | exploitation | critical |
| 19 | `19-Deserialization-Python-Pickle.md` | Deserialization Python Pickle | exploitation | critical |

### Category: File Upload

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 08 | `08-File-Upload-Arbitrary-Upload.md` | File Upload Arbitrary Upload | exploitation | high |

### Category: XXE

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 09 | `09-XXE-XML-External-Entity-Attacks.md` | XXE XML External Entity Attacks | exploitation | high |

### Category: SSTI

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 10 | `10-SSTI-Server-Side-Template-Injection.md` | SSTI Server-Side Template Injection | exploitation | critical |

### Category: JWT

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 11 | `11-JWT-Token-Manipulation.md` | JWT Token Manipulation | exploitation | high |

### Category: Authentication

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 12 | `12-Authentication-Bypass.md` | Authentication Bypass | exploitation | critical |

### Category: Privilege Escalation

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 13 | `13-Privilege-Escalation.md` | Privilege Escalation | exploitation | critical |

### Category: Business Logic

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 14 | `14-Business-Logic-Flaws.md` | Business Logic Flaws | exploitation | high |

### Category: Information Disclosure

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 15 | `15-Information-Disclosure.md` | Information Disclosure | exploitation | medium |

### Category: Memory Corruption

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 16 | `16-Memory-Corruption-Heap-Overflow.md` | Memory Corruption Heap Overflow | exploitation | critical |

### Category: Race Conditions

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 20 | `20-Race-Condition-Time-of-Check.md` | Race Condition Time-of-Check | exploitation | high |

### Category: Host Header

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 21 | `21-Host-Header-Injection.md` | Host Header Injection | exploitation | medium |

### Category: DNS Rebinding

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 22 | `22-DNS-Rebinding-Attacks.md` | DNS Rebinding Attacks | exploitation | high |

### Category: WebSocket

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 23 | `23-WebSocket-Security-Issues.md` | WebSocket Security Issues | exploitation | medium |
| 37 | `37-WebSocket-Hijacking.md` | WebSocket Hijacking | exploitation | high |

### Category: GraphQL

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 24 | `24-GraphQL-Introspection-Attacks.md` | GraphQL Introspection Attacks | exploitation | medium |

### Category: CSP Bypass

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 25 | `25-CSP-Bypass-Techniques.md` | CSP Bypass Techniques | exploitation | medium |

### Category: Clickjacking

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 26 | `26-Clickjacking-UI-Redressing.md` | Clickjacking UI Redressing | exploitation | medium |

### Category: Response Splitting

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 27 | `27-HTTP-Response-Splitting.md` | HTTP Response Splitting | exploitation | medium |

### Category: Injection (Various)

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 28 | `28-LDAP-Injection-Attacks.md` | LDAP Injection Attacks | exploitation | high |
| 29 | `29-XPath-Injection-Attacks.md` | XPath Injection Attacks | exploitation | high |
| 30 | `30-NoSQL-Injection-MongoDB.md` | NoSQL Injection MongoDB | exploitation | high |

### Category: Prototype Pollution

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 31 | `31-Prototype-Pollution-JavaScript.md` | Prototype Pollution JavaScript | exploitation | high |

### Category: Subdomain Takeover

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 32 | `32-Subdomain-Takeover.md` | Subdomain Takeover | exploitation | high |

### Category: Open Redirect

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 33 | `33-Open-Redirect-Phishing.md` | Open Redirect Phishing | exploitation | medium |

### Category: Content Spoofing

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 34 | `34-Content-Spoofing-Attacks.md` | Content Spoofing Attacks | exploitation | medium |

### Category: WebCache Poisoning

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 35 | `35-WebCache-Poisoning.md` | WebCache Poisoning | exploitation | high |

### Category: HTTP Smuggling

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 36 | `36-HTTP-Request-Smuggling.md` | HTTP Request Smuggling | exploitation | high |

### Category: CORS

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 38 | `38-CORS-Misconfiguration.md` | CORS Misconfiguration | exploitation | medium |

### Category: Token Leakage

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 39 | `39-Token-Leakage-URL-Parameters.md` | Token Leakage URL Parameters | exploitation | medium |

### Category: Data Exposure

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 40 | `40-Sensitive-Data-Exposure.md` | Sensitive Data Exposure | exploitation | high |

### Category: Cryptography

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 41 | `41-Weak-Encryption-Algorithms.md` | Weak Encryption Algorithms | exploitation | high |
| 42 | `42-Insecure-Cryptographic-Storage.md` | Insecure Cryptographic Storage | exploitation | high |

### Category: File Inclusion

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 43 | `43-Path-Traversal-File-Inclusion.md` | Path Traversal File Inclusion | exploitation | high |
| 44 | `44-Local-File-Inclusion-LFI.md` | Local File Inclusion (LFI) | exploitation | high |
| 45 | `45-Remote-File-Inclusion-RFI.md` | Remote File Inclusion (RFI) | exploitation | critical |

### Category: SSRF Variant

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 46 | `46-Server-Side-Request-Forgery.md` | Server-Side Request Forgery | exploitation | high |

### Category: Client-Side

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 47 | `47-Client-Side-Request-Forgery.md` | Client-Side Request Forgery | exploitation | medium |

### Category: Mobile and Cloud

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 48 | `48-Mobile-API-Security-Issues.md` | Mobile API Security Issues | exploitation | high |
| 49 | `49-Cloud-Misconfiguration-AWS.md` | Cloud Misconfiguration AWS | exploitation | high |

### Category: API Authentication

| ID | File | Title | Pattern Type | Severity |
|----|------|-------|--------------|----------|
| 50 | `50-API-Authentication-Bypass.md` | API Authentication Bypass | exploitation | critical |

---

## Vulnerability Class Summary

| Vuln Class | File Count | Avg Severity | Pattern Complexity |
|------------|------------|--------------|-------------------|
| Injection (SQL/NoSQL/LDAP/XPath/Command) | 8 | critical | high |
| Deserialization | 4 | critical | high |
| Authentication/Authorization | 3 | critical | medium |
| SSRF | 2 | high | medium |
| XSS | 1 | high | medium |
| File Inclusion | 3 | high | medium |
| Configuration | 4 | medium | low |
| Cryptography | 2 | high | medium |

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
