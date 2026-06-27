# Core Prompts Hunting — Tool Execution Domain

**Component:** Tool Executor for Security Hunting  
**Domain:** `core-prompts-hunting`  
**Registry:** `Core-Prompts-hunting/registry.json`  
**File Count:** 50 prompt files  
**Execution Mode:** Security tool execution with rate limiting

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `core-prompts-hunting` |
| Domain Path | `Core-Prompts-hunting/` |
| Category | `hunting` |
| Execution Profile | `security-scanner` |
| Default Timeout | 300s |
| Max Timeout | 3600s |
| Default Retries | 2 |
| Concurrency Limit | 5 |
| Stealth Level | `medium` |
| Rate Limit | 10 req/s |

---

## Overview

The Core Prompts Hunting executor manages tool execution for security vulnerability hunting operations. This domain covers 50 prompt files spanning reconnaissance and asset discovery, JavaScript analysis and deobfuscation, API endpoint analysis, authentication and session management, authorization and access control, input validation and sanitization, business logic flaws, client-side storage security, cryptography and data protection, error handling and information disclosure, file upload and processing, SSRF, CSRF, CORS, race conditions and concurrency issues, third-party component analysis, configuration and misconfiguration hunting, network and infrastructure security, mobile and API-specific vulnerabilities, reporting and PoC development, WAF bypass, HTTP request smuggling, subdomain takeover, host header injection, XXE injection, insecure deserialization, command injection, NoSQL injection, GraphQL vulnerabilities, WebSocket security, SSTI, JWT vulnerabilities, CSP bypass, clickjacking and UI redressing, HTTP parameter pollution, LDAP injection, session puzzling and fixation, insecure file handling, cross-site script inclusion, prototype pollution, HTTP response splitting, XPath injection, CSRF (variant), CORS (variant), race conditions (variant), third-party component analysis (variant), configuration hunting (variant), network security (variant), mobile and API vulnerabilities (variant), and reporting (variant).

This executor runs security tools with aggressive rate limiting to avoid detection while maximizing coverage across vulnerability classes.

---

## Execution Schema

### HuntingInvocation (Input)

```json
{
  "tool": "string — security tool name",
  "vuln_class": "string — target vulnerability class",
  "input": {
    "target": "string — target URL or system",
    "endpoints": ["string — specific endpoints to test"],
    "payloads": ["string — attack payloads"],
    "options": {
      "depth": "number — scan depth",
      "threads": "number — concurrent threads",
      "rate_limit": "number — requests per second",
      "follow_redirects": "boolean",
      "verify_ssl": "boolean"
    }
  },
  "config": {
    "timeout": "number",
    "retries": "number",
    "stealth": "boolean",
    "waf_bypass": "boolean"
  }
}
```

### HuntingResult (Output)

```json
{
  "status": "string",
  "vuln_class": "string",
  "findings": [
    {
      "type": "string — vulnerability type",
      "severity": "string — critical|high|medium|low|info",
      "url": "string — affected URL",
      "parameter": "string — affected parameter",
      "payload": "string — working payload",
      "evidence": "string — proof of vulnerability",
      "cvss": "number — CVSS score"
    }
  ],
  "endpoints_tested": "number",
  "requests_made": "number",
  "duration_ms": "number",
  "rate_limited": "boolean"
}
```

---

## Run Operations

### Security Tool Execution

```python
def run_hunting(
    self,
    tool: str,
    vuln_class: str,
    input_data: dict,
    config: dict = None
) -> HuntingResult:
    """
    Execute a security hunting tool.
    
    Flow:
    1. Validate target is in-scope
    2. Check rate limit status
    3. Apply WAF bypass techniques if configured
    4. Execute security tool with rate limiting
    5. Capture and parse findings
    6. Classify findings by severity
    7. Return structured results
    8. Log invocation for audit
    """
```

### Rate-Limited Execution

```python
def _rate_limited_execute(
    self,
    tool: str,
    input_data: dict
) -> HuntingResult:
    """Execute with rate limiting to avoid detection."""
    rate_limit = self._get_rate_limit(tool)
    
    while True:
        if self._rate_limiter.can_proceed(tool):
            self._rate_limiter.consume(tool)
            return self._execute_tool(tool, input_data)
        else:
            wait_time = self._rate_limiter.time_until_available(tool)
            time.sleep(wait_time)
```

### WAF Bypass Execution

```python
def _apply_waf_bypass(
    self,
    input_data: dict,
    waf_type: str = None
) -> dict:
    """Apply WAF bypass techniques to input data."""
    bypassed = input_data.copy()
    
    # URL encoding bypass
    if waf_type == "url_encoding":
        bypassed = self._url_encode_bypass(bypassed)
    
    # Double encoding bypass
    if waf_type == "double_encoding":
        bypassed = self._double_encode_bypass(bypassed)
    
    # Case variation bypass
    if waf_type == "case_variation":
        bypassed = self._case_variation_bypass(bypassed)
    
    # Unicode bypass
    if waf_type == "unicode":
        bypassed = self._unicode_bypass(bypassed)
    
    return bypassed
```

---

## Stop Operations

### Hunting Stop

```python
def stop_hunting(
    self,
    invocation_id: str,
    save_partial: bool = True
) -> StopResult:
    """
    Stop a running hunting operation.
    Optionally saves partial findings.
    """
```

### Emergency Stop

```python
def emergency_stop(self) -> None:
    """
    Emergency stop all hunting operations.
    Used when detection is suspected.
    """
    self._stop_all = True
    for process in self._running_processes:
        process.kill()
```

---

## Retry Operations

### Hunting Retry Configuration

```python
@dataclass
class HuntingRetryConfig:
    max_retries: int = 2
    backoff_base: float = 5.0
    backoff_multiplier: float = 2.0
    max_backoff: float = 60.0
    retry_on_waf_block: bool = True
    retry_on_rate_limit: bool = True
    retry_on_timeout: bool = False
    waf_bypass_on_retry: bool = True
```

### WAF-Aware Retry

```python
def _retry_with_waf_bypass(
    self,
    invocation: HuntingInvocation,
    failure_reason: str
) -> HuntingResult:
    """Retry with WAF bypass techniques."""
    if failure_reason == "waf_blocked":
        # Try different bypass technique
        bypass_type = self._select_bypass_type(invocation)
        adjusted = self._apply_waf_bypass(invocation, bypass_type)
        return self.run_hunting(**adjusted)
    elif failure_reason == "rate_limited":
        # Wait and retry with lower rate
        time.sleep(30)
        adjusted = self._reduce_rate(invocation)
        return self.run_hunting(**adjusted)
```

---

## Timeout Handling

### Hunting Timeout Configuration

```python
@dataclass
class HuntingTimeoutConfig:
    default: int = 300
    overrides: dict[str, int] = field(default_factory=lambda: {
        "xss_scanner": 600,
        "sqli_scanner": 1800,
        "ssrf_scanner": 600,
        "csrf_tester": 300,
        "ssrf_tester": 600,
        "xxe_tester": 300,
        "ssti_tester": 300,
        "idor_tester": 600,
        "command_injection": 600,
        "jwt_tester": 300,
        "graphql_tester": 600,
        "websocket_tester": 300,
        "race_condition": 600,
        "subdomain_takeover": 600
    })
    hard_maximum: int = 3600
```

---

## Output Capture

### Hunting Output Capture

```python
@dataclass
class HuntingCapturedOutput:
    findings: list[dict]
    endpoints_tested: int
    requests_made: int
    waf_blocks: int
    rate_limited: boolean
    partial: boolean
    raw_output: str
```

---

## Stderr Handling

### Hunting Stderr Processing

```python
def _process_stderr(self, stderr: str) -> StderrResult:
    """Process hunting stderr with detection awareness."""
    classifications = []
    
    # Check for WAF detection
    if "403" in stderr or "blocked" in stderr.lower():
        classifications.append("waf_blocked")
    
    # Check for rate limiting
    if "429" in stderr or "rate limit" in stderr.lower():
        classifications.append("rate_limited")
    
    # Check for connection issues
    if "connection refused" in stderr.lower():
        classifications.append("connection_error")
    
    return StderrResult(
        raw=stderr,
        classifications=classifications,
        retryable=any(c in ["waf_blocked", "rate_limited"] for c in classifications)
    )
```

---

## Exit Code Handling

### Hunting Exit Code Processing

```python
def _process_exit_code(self, exit_code: int) -> ExitCodeResult:
    """Process hunting tool exit code."""
    if exit_code == 0:
        return ExitCodeResult(status="success", action="process_findings")
    elif exit_code == 1:
        return ExitCodeResult(status="findings_found", action="process_findings")
    elif exit_code == 2:
        return ExitCodeResult(status="error", action="retry")
    else:
        return ExitCodeResult(status="error", action="log_and_report")
```

---

## Concurrent Execution

### Hunting Concurrency Configuration

```python
@dataclass
class HuntingConcurrencyConfig:
    max_concurrent: int = 5
    max_per_vuln_class: int = 2
    max_per_target: int = 3
    sequential_waf_bypass: bool = True
```

### Target-Based Scheduling

```python
def _schedule_by_target(
    self,
    invocations: list[HuntingInvocation]
) -> list[list[HuntingInvocation]]:
    """Group invocations by target for sequential execution."""
    by_target = defaultdict(list)
    for inv in invocations:
        by_target[inv.target].append(inv)
    return list(by_target.values())
```

---

## Execution Logging

### Hunting Execution Log

```python
@dataclass
class HuntingExecutionLog:
    invocation_id: str
    tool: str
    vuln_class: str
    target: str
    status: str
    findings_count: int
    endpoints_tested: int
    requests_made: int
    waf_blocks: int
    rate_limited: boolean
    duration_ms: int
    timestamp_start: str
    timestamp_end: str
```

---

## Full Domain File References

### Category: Reconnaissance and Discovery

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 01 | `1-Reconnaissance-and-Asset-Discovery.md` | Reconnaissance and Asset Discovery | recon | 600s |

### Category: Client-Side Analysis

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 02 | `2-JavaScript-Analysis-and-Deobfuscation.md` | JavaScript Analysis and Deobfuscation | xss | 300s |

### Category: API Analysis

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 03 | `3-API-Endpoint-Analysis.md` | API Endpoint Analysis | api | 300s |

### Category: Authentication

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 04 | `4-Authentication-and-Session-Management.md` | Authentication and Session Management | auth | 600s |

### Category: Authorization

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 05 | `5-Authorization-and-Access-Control.md` | Authorization and Access Control | authz | 600s |

### Category: Input Validation

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 06 | `6-Input-Validation-and-Sanitization.md` | Input Validation and Sanitization | injection | 300s |

### Category: Business Logic

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 07 | `7-Business-Logic-Flaws.md` | Business Logic Flaws | logic | 600s |

### Category: Client-Side Storage

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 08 | `8-Client-Side-Storage-Security.md` | Client-Side Storage Security | client | 300s |

### Category: Cryptography

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 09 | `9-Cryptography-and-Data-Protection.md` | Cryptography and Data Protection | crypto | 300s |

### Category: Error Handling

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 10 | `10-Error-Handling-and-Information-Disclosure.md` | Error Handling and Information Disclosure | info-disclosure | 300s |

### Category: File Upload

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 11 | `11-File-Upload-and-Processing.md` | File Upload and Processing | file-upload | 600s |

### Category: SSRF

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 12 | `12-Server-Side-Request-Forgery-SSRF.md` | Server-Side Request Forgery (SSRF) | ssrf | 600s |

### Category: CSRF

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 13 | `13-Cross-Site-Request-Forgery-CSRF.md` | Cross-Site Request Forgery (CSRF) | csrf | 300s |

### Category: CORS

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 14 | `14-Cross-Origin-Resource-Sharing-CORS.md` | Cross-Origin Resource Sharing (CORS) | cors | 300s |

### Category: Race Conditions

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 15 | `15-Race-Conditions-and-Concurrency-Issues.md` | Race Conditions and Concurrency Issues | race | 600s |

### Category: Third-Party Components

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 16 | `16-Third-Party-Component-Analysis.md` | Third-Party Component Analysis | third-party | 300s |

### Category: Configuration

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 17 | `17-Configuration-and-Misconfiguration-Hunting.md` | Configuration and Misconfiguration Hunting | misconfig | 300s |

### Category: Network Security

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 18 | `18-Network-and-Infrastructure-Security.md` | Network and Infrastructure Security | network | 600s |

### Category: Mobile and API

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile and API-Specific Vulnerabilities | mobile | 600s |

### Category: Reporting

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 20 | `20-Reporting-and-Proof-of-Concept-Development.md` | Reporting and Proof-of-Concept Development | reporting | 120s |

### Category: WAF Bypass

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 21 | `21-Web-Application-Firewall-WAF-Bypass.md` | Web Application Firewall (WAF) Bypass | waf-bypass | 300s |

### Category: HTTP Smuggling

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 22 | `22-HTTP-Request-Smuggling.md` | HTTP Request Smuggling | smuggling | 600s |

### Category: Subdomain Takeover

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 23 | `23-Subdomain-Takeover.md` | Subdomain Takeover | subdomain | 300s |

### Category: Host Header Injection

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 24 | `24-Host-Header-Injection.md` | Host Header Injection | host-header | 300s |

### Category: XXE

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 25 | `25-XML-External-Entity-XXE-Injection.md` | XML External Entity (XXE) Injection | xxe | 300s |

### Category: Deserialization

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 26 | `26-Insecure-Deserialization.md` | Insecure Deserialization | deserialization | 600s |

### Category: Command Injection

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 27 | `27-Command-Injection.md` | Command Injection | command-injection | 600s |

### Category: NoSQL Injection

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 28 | `28-NoSQL-Injection.md` | NoSQL Injection | nosql | 300s |

### Category: GraphQL

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 29 | `29-GraphQL-Vulnerabilities.md` | GraphQL Vulnerabilities | graphql | 600s |

### Category: WebSocket

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 30 | `30-WebSocket-Security.md` | WebSocket Security | websocket | 300s |

### Category: SSTI

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 31 | `31-Server-Side-Template-Injection.md` | Server-Side Template Injection | ssti | 300s |

### Category: JWT

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | JSON Web Token (JWT) Vulnerabilities | jwt | 300s |

### Category: CSP Bypass

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 33 | `33-Content-Security-Policy-CSP-Bypass.md` | Content Security Policy (CSP) Bypass | csp | 300s |

### Category: Clickjacking

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 34 | `34-Clickjacking-and-UI-Redressing.md` | Clickjacking and UI Redressing | clickjacking | 120s |

### Category: HTTP Parameter Pollution

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 35 | `35-HTTP-Parameter-Pollution.md` | HTTP Parameter Pollution | hpp | 300s |

### Category: LDAP Injection

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 36 | `36-LDAP-Injection.md` | LDAP Injection | ldap | 300s |

### Category: Session Puzzling

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 37 | `37-Session-Puzzling-and-Fixation.md` | Session Puzzling and Fixation | session | 300s |

### Category: File Handling

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 38 | `38-Insecure-File-Handling.md` | Insecure File Handling | file | 300s |

### Category: XSSI

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 39 | `39-Cross-Site-Script-Inclusion-XSSI.md` | Cross-Site Script Inclusion (XSSI) | xssi | 300s |

### Category: Prototype Pollution

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 40 | `40-Prototype-Pollution.md` | Prototype Pollution | prototype-pollution | 300s |

### Category: Response Splitting

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 41 | `41-HTTP-Response-Splitting.md` | HTTP Response Splitting | response-splitting | 300s |

### Category: XPath Injection

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 42 | `42-XPath-Injection.md` | XPath Injection | xpath | 300s |

### Category: CSRF Variant

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 43 | `43-Cross-Site-Request-Forgery-CSRF.md` | Cross-Site Request Forgery (CSRF) | csrf | 300s |

### Category: CORS Variant

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 44 | `44-Cross-Origin-Resource-Sharing-CORS.md` | Cross-Origin Resource Sharing (CORS) | cors | 300s |

### Category: Race Conditions Variant

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 45 | `45-Race-Conditions-and-Concurrency-Issues.md` | Race Conditions and Concurrency Issues | race | 600s |

### Category: Third-Party Component Variant

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 46 | `46-Third-Party-Component-Analysis.md` | Third-Party Component Analysis | third-party | 300s |

### Category: Configuration Variant

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 47 | `47-Configuration-and-Misconfiguration-Hunting.md` | Configuration and Misconfiguration Hunting | misconfig | 300s |

### Category: Network Security Variant

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 48 | `48-Network-and-Infrastructure-Security.md` | Network and Infrastructure Security | network | 600s |

### Category: Mobile and API Variant

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 49 | `49-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile and API-Specific Vulnerabilities | mobile | 600s |

### Category: Reporting Variant

| ID | File | Title | Vuln Class | Timeout |
|----|------|-------|------------|---------|
| 50 | `50-Reporting-and-Proof-of-Concept-Development.md` | Reporting and Proof-of-Concept Development | reporting | 120s |

---

## Rate Limiting Matrix

| Tool Type | Default Rate | Burst Rate | Cooldown |
|-----------|-------------|------------|----------|
| XSS Scanner | 10 req/s | 20 req/s | 30s |
| SQLi Scanner | 5 req/s | 10 req/s | 60s |
| SSRF Tester | 10 req/s | 15 req/s | 30s |
| CSRF Tester | 15 req/s | 30 req/s | 15s |
| IDOR Tester | 10 req/s | 20 req/s | 30s |
| XXE Tester | 10 req/s | 15 req/s | 30s |
| SSTI Tester | 10 req/s | 15 req/s | 30s |
| Command Injection | 5 req/s | 10 req/s | 60s |
| JWT Tester | 20 req/s | 40 req/s | 10s |
| GraphQL Tester | 10 req/s | 20 req/s | 30s |

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
