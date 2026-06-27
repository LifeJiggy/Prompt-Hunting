# Advanced Automation — Tool Execution Domain

**Component:** Tool Executor for Scanning Automation  
**Domain:** `advanced-automation`  
**Registry:** `Advanced-Automation/registry.json`  
**File Count:** 50 prompt files  
**Execution Mode:** Automated scanner orchestration with timeout and retry

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `advanced-automation` |
| Domain Path | `Advanced-Automation/` |
| Category | `scanning` |
| Execution Profile | `scanner` |
| Default Timeout | 300s |
| Max Timeout | 3600s |
| Default Retries | 3 |
| Concurrency Limit | 5 |
| Stealth Level | `medium` |
| Rate Limit | 10 req/s |

---

## Overview

The Advanced Automation executor manages tool execution for the complete scanning automation workflow. This domain covers 50 prompt files spanning subdomain enumeration, port scanning, vulnerability scanning, JavaScript analysis, API endpoint discovery, parameter fuzzing, directory brute-forcing, authentication testing, session management, IDOR detection, SQL injection automation, XSS detection, SSRF testing, CSRF testing, command injection, XXE testing, SSTI testing, JWT testing, deserialization testing, report generation, PoC development, target scouting, scope validation, asset tracking, change monitoring, notification alerting, data collection, result analysis, tool chaining, proxy integration, browser automation, headless browser scripting, regex pattern automation, response analysis, header injection, CORS testing, WebSocket testing, GraphQL testing, cloud service enumeration, DNS extraction, email recon, social media OSINT, framework detection, technology stack identification, endpoint mapping, content discovery, version detection, compliance checking, and workflow orchestration.

This executor spawns scanner processes, enforces timeouts, captures structured output, handles retries on transient failures, and logs every invocation for audit purposes.

---

## Execution Schema

### ToolInvocation (Input)

```json
{
  "tool": "string — registered tool name",
  "input": {
    "targets": ["string — target URLs or domains"],
    "templates": ["string — scan templates or modules"],
    "severity": ["string — severity filter levels"],
    "options": {
      "rate_limit": "number — requests per second",
      "timeout": "number — per-tool timeout override in seconds",
      "retries": "number — max retry attempts",
      "threads": "number — concurrent thread count",
      "output_format": "string — json|text|csv"
    }
  },
  "config": {
    "timeout": "number — execution timeout",
    "retries": "number — retry count",
    "priority": "string — low|normal|high",
    "stealth": "boolean — enable stealth mode"
  },
  "context": {
    "session_id": "string — session identifier",
    "agent_id": "string — invoking agent",
    "chain_id": "string — chain execution context"
  }
}
```

### ToolResult (Output)

```json
{
  "status": "string — success|error|timeout|policy_denied|validation_error",
  "exit_code": "number — process exit code",
  "stdout": "string — captured standard output",
  "stderr": "string — captured standard error",
  "findings": ["object — parsed vulnerability findings"],
  "duration_ms": "number — wall clock execution time",
  "retry_count": "number — retries attempted",
  "resources": {
    "peak_memory_mb": "number",
    "cpu_time_s": "number",
    "io_read_bytes": "number",
    "io_write_bytes": "number"
  },
  "invocation_id": "string — unique execution ID"
}
```

---

## Run Operations

### Primary Scanner Execution

```python
def run_scanner(
    self,
    tool: str,
    targets: list[str],
    templates: list[str] = None,
    severity: list[str] = None,
    config: dict = None
) -> ToolResult:
    """
    Execute a scanner tool against specified targets.
    
    Flow:
    1. Validate tool exists in registry
    2. Check execution policy (allowed, rate limit)
    3. Build command-line arguments from input schema
    4. Launch process with timeout enforcement
    5. Capture stdout/stderr in real-time
    6. Parse findings from structured output
    7. Return ToolResult with parsed findings
    8. Log invocation to audit trail
    """
```

**Execution Steps:**

1. **Lookup Tool**: Resolve tool name to registered binary path and arguments
2. **Validate Input**: Check targets are in-scope, templates exist, severity is valid
3. **Build Command**: Construct CLI command with all arguments and flags
4. **Apply Rate Limit**: Enforce per-tool request rate via throttling wrapper
5. **Launch Process**: Start subprocess with configured timeout
6. **Stream Output**: Read stdout/stderr line-by-line for real-time capture
7. **Parse Findings**: Extract structured vulnerability data from tool output
8. **Format Result**: Package into standardized ToolResult format
9. **Log Execution**: Write invocation record to execution log

### Scanner-Specific Operations

```python
# Subdomain enumeration scanner
result = executor.run_scanner(
    tool="subfinder",
    targets=["example.com"],
    config={"timeout": 120, "retries": 2}
)

# Port scanning scanner
result = executor.run_scanner(
    tool="nmap",
    targets=["192.168.1.0/24"],
    templates=["top-1000"],
    config={"timeout": 600, "threads": 100}
)

# Vulnerability scanner
result = executor.run_scanner(
    tool="nuclei",
    targets=["https://target.com"],
    templates=["cves/", "misconfigurations/"],
    severity=["high", "critical"],
    config={"timeout": 1800}
)
```

---

## Stop Operations

### Graceful Stop

```python
def stop(
    self,
    invocation_id: str,
    reason: str = "user_request"
) -> StopResult:
    """
    Gracefully stop a running tool execution.
    
    Sends SIGTERM, waits up to 10 seconds for graceful shutdown,
    then SIGKILL if still running. Captures any partial output.
    """
```

**Stop Flow:**

1. **Identify Process**: Look up invocation ID to find running process
2. **Send SIGTERM**: Allow graceful shutdown (10s window)
3. **Monitor Exit**: Wait for process to exit cleanly
4. **Force Kill**: If still running after 10s, send SIGKILL
5. **Capture Partial**: Save any partial stdout/stderr captured
6. **Log Stop**: Record stop event with reason in audit trail
7. **Release Resources**: Free concurrency slot and update counters

### Batch Stop

```python
def stop_batch(
    self,
    invocation_ids: list[str],
    reason: str = "batch_cancel"
) -> list[StopResult]:
    """
    Stop multiple running tool executions simultaneously.
    Sends SIGTERM to all, then SIGKILL to stragglers.
    """
```

### Emergency Stop

```python
def emergency_stop(self) -> None:
    """
    Immediately terminate ALL running tool executions.
    Sends SIGKILL to all processes. Use only when system
    integrity is at risk.
    """
```

---

## Retry Operations

### Retry Configuration

```python
@dataclass
class AutomationRetryConfig:
    max_retries: int = 3
    backoff_base: float = 2.0
    backoff_multiplier: float = 2.0
    max_backoff: float = 60.0
    retry_on_exit_codes: list[int] = field(
        default_factory=lambda: [1, 2, 137, 143]
    )
    retry_on_timeout: bool = False
    retry_on_stderr_patterns: list[str] = field(
        default_factory=lambda: [
            "connection reset",
            "connection refused",
            "temporary failure",
            "network unreachable",
            "rate limit"
        ]
    )
```

### Retry Decision Matrix

| Condition | Retry? | Backoff |
|-----------|--------|---------|
| Exit code 1 (general error) | Yes | Exponential |
| Exit code 2 (usage error) | Yes | Exponential |
| Exit code 137 (SIGKILL) | Yes | Exponential |
| Exit code 143 (SIGTERM) | Yes | Exponential |
| Timeout exceeded | No | — |
| Validation error | No | — |
| Policy denied | No | — |
| Rate limit hit | Yes | 30s fixed |
| Connection reset | Yes | Exponential |
| Connection refused | Yes | Exponential |

### Retry Flow

```
Attempt 1 → Failure
  │
  ▼
Wait backoff_base (2s)
  │
  ▼
Attempt 2 → Failure
  │
  ▼
Wait backoff_base × multiplier (4s)
  │
  ▼
Attempt 3 → Failure
  │
  ▼
Wait backoff_base × multiplier² (8s)
  │
  ▼
Attempt 4 (final) → Failure
  │
  ▼
Return ToolResult(status="error", retry_count=3)
```

---

## Timeout Handling

### Timeout Configuration

```python
@dataclass
class AutomationTimeoutConfig:
    default: int = 300
    overrides: dict[str, int] = field(default_factory=lambda: {
        "subfinder": 120,
        "httpx": 60,
        "nmap": 600,
        "nuclei": 1800,
        "ffuf": 600,
        "sqlmap": 3600,
        "nuclei": 1800,
        "katana": 600,
        "waybackurls": 120,
        "gau": 120
    })
    hard_maximum: int = 3600
    warning_threshold: float = 0.8
```

### Timeout Enforcement

When a timeout is detected:

1. **SIGTERM**: Send termination signal to process
2. **Wait Period**: 5 seconds for graceful shutdown
3. **SIGKILL**: Force-kill if process still running
4. **Partial Capture**: Save all stdout/stderr captured before timeout
5. **Result**: Return ToolResult with `status="timeout"` and partial output

### Timeout Monitoring

```python
def _monitor_timeout(self, process, timeout_s: int) -> None:
    """Monitor process for timeout with warning threshold."""
    warning_at = int(timeout_s * self._timeout_config.warning_threshold)
    deadline = time.time() + timeout_s
    
    while process.poll() is None:
        elapsed = time.time() + timeout_s - deadline
        if elapsed >= warning_at:
            self._log_warning(
                f"Tool approaching timeout: {elapsed:.1f}s / {timeout_s}s"
            )
        if time.time() >= deadline:
            self._enforce_timeout(process)
            return
        time.sleep(0.1)
```

---

## Output Capture

### Capture Configuration

```python
@dataclass
class CaptureConfig:
    max_stdout_bytes: int = 10 * 1024 * 1024  # 10 MB
    max_stderr_bytes: int = 1 * 1024 * 1024   # 1 MB
    buffer_size: int = 8192
    encoding: str = "utf-8"
    errors: str = "replace"
    capture_findings_before_truncation: bool = True
```

### Capture Streams

```python
@dataclass
class CapturedOutput:
    stdout: str                    # Standard output (may be truncated)
    stderr: str                    # Standard error
    exit_code: int                 # Process exit code
    stdout_truncated: bool         # True if exceeded max size
    stdout_size_bytes: int         # Total bytes before truncation
    stderr_truncated: bool         # True if stderr exceeded max
    findings: list[dict]           # Parsed findings (pre-truncation)
    raw_output_path: str           # Path to full output file on disk
```

### Real-Time Capture

```python
def _capture_output(self, process) -> CapturedOutput:
    """Capture stdout and stderr in real-time with buffering."""
    stdout_chunks = []
    stderr_chunks = []
    stdout_size = 0
    stderr_size = 0
    findings = []
    
    while process.poll() is None:
        # Read stdout
        chunk = process.stdout.read(self._capture_config.buffer_size)
        if chunk:
            stdout_chunks.append(chunk)
            stdout_size += len(chunk)
            # Parse findings before truncation
            if self._capture_config.capture_findings_before_truncation:
                findings.extend(self._parse_findings(chunk))
            if stdout_size > self._capture_config.max_stdout_bytes:
                break
        
        # Read stderr
        err_chunk = process.stderr.read(self._capture_config.buffer_size)
        if err_chunk:
            stderr_chunks.append(err_chunk)
            stderr_size += len(err_chunk)
            if stderr_size > self._capture_config.max_stderr_bytes:
                break
    
    return CapturedOutput(
        stdout=self._decode(stdout_chunks),
        stderr=self._decode(stderr_chunks),
        exit_code=process.wait(),
        stdout_truncated=stdout_size > self._capture_config.max_stdout_bytes,
        stdout_size_bytes=stdout_size,
        stderr_truncated=stderr_size > self._capture_config.max_stderr_bytes,
        findings=findings,
        raw_output_path=self._write_raw_output(stdout_chunks)
    )
```

---

## Stderr Handling

### Stderr Classification

| Pattern | Classification | Action |
|---------|---------------|--------|
| `connection refused` | Transient network | Retry |
| `connection reset` | Transient network | Retry |
| `rate limit` | Rate limited | Retry with backoff |
| `permission denied` | Access error | Log and report |
| `not found` | Target error | Log and report |
| `invalid argument` | Input error | Log and report |
| `segmentation fault` | Crash | Retry (different config) |
| `out of memory` | Resource error | Increase memory limit |
| `timeout` | Timeout | Report as timeout |

### Stderr Processing

```python
def _process_stderr(self, stderr: str) -> StderrResult:
    """Classify and process stderr output."""
    classifications = []
    
    for pattern, classification in self._stderr_patterns.items():
        if re.search(pattern, stderr, re.IGNORECASE):
            classifications.append(classification)
    
    # Determine if retryable
    retryable = any(
        c.action == "retry" for c in classifications
    )
    
    # Extract meaningful error messages
    errors = self._extract_error_messages(stderr)
    
    return StderrResult(
        raw=stderr,
        classifications=classifications,
        retryable=retryable,
        errors=errors,
        summary=self._summarize_stderr(classifications, errors)
    )
```

---

## Exit Code Handling

### Exit Code Map

| Exit Code | Meaning | Action |
|-----------|---------|--------|
| 0 | Success | Process output |
| 1 | General error | Retry |
| 2 | Usage error | Log and report |
| 3 | Runtime error | Retry |
| 4 | Resource error | Increase limits and retry |
| 126 | Permission denied | Log and report |
| 127 | Command not found | Log and report |
| 130 | SIGINT (Ctrl+C) | Retry |
| 137 | SIGKILL | Retry |
| 143 | SIGTERM | Retry |

### Exit Code Processing

```python
def _process_exit_code(self, exit_code: int) -> ExitCodeResult:
    """Process exit code and determine next action."""
    if exit_code == 0:
        return ExitCodeResult(
            status="success",
            action="process_output",
            retryable=False
        )
    
    if exit_code in self._retry_config.retry_on_exit_codes:
        return ExitCodeResult(
            status="error",
            action="retry",
            retryable=True,
            message=f"Non-zero exit code: {exit_code}"
        )
    
    return ExitCodeResult(
        status="error",
        action="report",
        retryable=False,
        message=f"Fatal exit code: {exit_code}"
    )
```

---

## Concurrent Execution

### Concurrency Configuration

```python
@dataclass
class AutomationConcurrencyConfig:
    max_concurrent: int = 5
    max_per_tool: dict[str, int] = field(default_factory=lambda: {
        "subfinder": 3,
        "httpx": 5,
        "nmap": 2,
        "nuclei": 2,
        "ffuf": 3,
        "katana": 3,
        "gau": 5,
        "waybackurls": 5
    })
    queue_size: int = 100
    queue_timeout: int = 60
    process_priority: str = "normal"
```

### Concurrent Execution Flow

```
Tool Invocation Request
        │
        ▼
┌───────────────┐
│ CHECK SLOTS   │ ← Available concurrency slots?
└───────┬───────┘
        │
   Slots Available?
   ├── Yes → Acquire slot, launch process
   └── No → Queue invocation
                │
                ▼
        ┌───────────────┐
        │ WAIT IN QUEUE │ ← FIFO with priority
        └───────┬───────┘
                │
           Queue Timeout?
           ├── Yes → Return queue_timeout error
           └── No → Slot freed, acquire and launch
```

### Parallel Batch Execution

```python
def run_batch_parallel(
    self,
    invocations: list[ToolInvocation],
    max_concurrent: int = 5
) -> list[ToolResult]:
    """
    Execute multiple scanner invocations in parallel.
    Respects per-tool concurrency limits.
    Uses asyncio for efficient I/O multiplexing.
    """
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def _run_with_limit(invocation):
        async with semaphore:
            return await self._run_async(invocation)
    
    tasks = [_run_with_limit(inv) for inv in invocations]
    return await asyncio.gather(*tasks)
```

---

## Execution Logging

### Log Schema

```python
@dataclass
class AutomationExecutionLog:
    invocation_id: str
    tool: str
    agent_id: str
    session_id: str
    timestamp_start: str
    timestamp_end: str
    duration_ms: int
    status: str
    exit_code: int
    input_hash: str
    output_size_bytes: int
    findings_count: int
    retry_count: int
    timeout_configured: int
    timeout_actual: int
    resources: ResourceUsage
    error_message: str = None
    chain_id: str = None
```

### Log Entry Creation

```python
def _create_log_entry(
    self,
    invocation: ToolInvocation,
    result: ToolResult,
    start_time: float
) -> AutomationExecutionLog:
    """Create detailed audit log entry."""
    return AutomationExecutionLog(
        invocation_id=result.invocation_id,
        tool=invocation.tool,
        agent_id=invocation.context.get("agent_id", "unknown"),
        session_id=invocation.context.get("session_id", "unknown"),
        timestamp_start=datetime.fromtimestamp(start_time).isoformat(),
        timestamp_end=datetime.now().isoformat(),
        duration_ms=int((time.time() - start_time) * 1000),
        status=result.status,
        exit_code=result.exit_code,
        input_hash=hashlib.sha256(
            json.dumps(invocation.input).encode()
        ).hexdigest(),
        output_size_bytes=len(result.stdout.encode()),
        findings_count=len(result.findings),
        retry_count=result.retry_count,
        timeout_configured=invocation.config.get("timeout", self._timeout_config.default),
        timeout_actual=result.duration_ms // 1000,
        resources=result.resources,
        error_message=result.stderr[:500] if result.status != "success" else None,
        chain_id=invocation.context.get("chain_id")
    )
```

### Log Query Interface

```python
# Recent executions
logs = executor.get_log(limit=50)

# Filter by tool
logs = executor.get_log(tool="nuclei", limit=20)

# Filter by status
logs = executor.get_log(status="error")

# Filter by time range
logs = executor.get_log(
    time_range=("2026-06-26T00:00:00", "2026-06-26T23:59:59")
)

# Filter by agent
logs = executor.get_log(agent_id="agent_scanner_01")

# Get specific invocation
log = executor.get_log(invocation_id="inv_abc123")
```

---

## Full Domain File References

### Category: Recon Automation

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 01 | `01-Subdomain-Enumeration-Automation.md` | Subdomain Enumeration Automation | 120s | 2 |
| 02 | `02-Port-Scanning-Automation.md` | Port Scanning Automation | 600s | 2 |
| 03 | `03-Vulnerability-Scanning-Automation.md` | Vulnerability Scanning Automation | 1800s | 3 |
| 04 | `04-JavaScript-Analysis-Automation.md` | JavaScript Analysis Automation | 300s | 2 |
| 05 | `05-API-Endpoint-Discovery.md` | API Endpoint Discovery | 300s | 2 |
| 06 | `06-Parameter-Fuzzing-Automation.md` | Parameter Fuzzing Automation | 600s | 3 |
| 07 | `07-Directory-Brute-Forcing.md` | Directory Brute-Forcing | 600s | 2 |

### Category: Exploit Automation

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 08 | `09-Authentication-Testing-Automation.md` | Authentication Testing Automation | 300s | 2 |
| 09 | `10-Session-Management-Testing.md` | Session Management Testing | 300s | 2 |
| 10 | `11-IDOR-Detection-Automation.md` | IDOR Detection Automation | 600s | 3 |
| 11 | `12-SQL-Injection-Automation.md` | SQL Injection Automation | 1800s | 3 |
| 12 | `13-XSS-Detection-Automation.md` | XSS Detection Automation | 600s | 3 |
| 13 | `14-SSRF-Testing-Automation.md` | SSRF Testing Automation | 600s | 2 |
| 14 | `15-CSRF-Testing-Automation.md` | CSRF Testing Automation | 300s | 2 |
| 15 | `16-Command-Injection-Automation.md` | Command Injection Automation | 600s | 3 |
| 16 | `17-XXE-Testing-Automation.md` | XXE Testing Automation | 300s | 2 |
| 17 | `18-SSTI-Testing-Automation.md` | SSTI Testing Automation | 300s | 2 |
| 18 | `19-JWT-Testing-Automation.md` | JWT Testing Automation | 300s | 2 |
| 19 | `20-Deserialization-Testing.md` | Deserialization Testing | 600s | 2 |

### Category: Reporting

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 20 | `21-Report-Generation-Automation.md` | Report Generation Automation | 120s | 1 |
| 21 | `22-PoC-Development-Automation.md` | PoC Development Automation | 300s | 2 |

### Category: Target Management

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 22 | `23-Target-Scouting-Automation.md` | Target Scouting Automation | 300s | 2 |
| 23 | `24-Scope-Validation-Automation.md` | Scope Validation Automation | 60s | 1 |
| 24 | `25-Asset-Tracking-Automation.md` | Asset Tracking Automation | 120s | 1 |
| 25 | `26-Change-Monitoring-Automation.md` | Change Monitoring Automation | 300s | 2 |
| 26 | `27-Notification-Alerting-Automation.md` | Notification Alerting Automation | 30s | 1 |

### Category: Analysis

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 27 | `28-Data-Collection-Automation.md` | Data Collection Automation | 600s | 2 |
| 28 | `29-Result-Analysis-Automation.md` | Result Analysis Automation | 300s | 1 |
| 29 | `30-Tool-Chaining-Automation.md` | Tool Chaining Automation | 1200s | 3 |

### Category: Browser Automation

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 30 | `31-Proxy-Integration-Automation.md` | Proxy Integration Automation | 300s | 2 |
| 31 | `32-Browser-Automation-Workflows.md` | Browser Automation Workflows | 600s | 2 |
| 32 | `33-Headless-Browser-Scripting.md` | Headless Browser Scripting | 600s | 2 |

### Category: Advanced Testing

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 33 | `34-Regex-Pattern-Automation.md` | Regex Pattern Automation | 120s | 1 |
| 34 | `35-Response-Analysis-Automation.md` | Response Analysis Automation | 300s | 2 |
| 35 | `36-Header-Injection-Testing.md` | Header Injection Testing | 300s | 2 |
| 36 | `37-CORS-Testing-Automation.md` | CORS Testing Automation | 300s | 2 |
| 37 | `38-WebSocket-Testing-Automation.md` | WebSocket Testing Automation | 300s | 2 |
| 38 | `39-GraphQL-Testing-Automation.md` | GraphQL Testing Automation | 600s | 3 |

### Category: Advanced Recon

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 39 | `40-Cloud-Service-Enumeration.md` | Cloud Service Enumeration | 600s | 2 |
| 40 | `41-DNS-Data-Extraction-Automation.md` | DNS Data Extraction Automation | 120s | 2 |
| 41 | `42-Email-Recon-Automation.md` | Email Recon Automation | 300s | 2 |
| 42 | `43-Social-Media-OSINT-Automation.md` | Social Media OSINT Automation | 300s | 2 |

### Category: Fingerprinting

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 43 | `44-Framework-Detection-Automation.md` | Framework Detection Automation | 120s | 1 |
| 44 | `45-Technology-Stack-Identification.md` | Technology Stack Identification | 120s | 1 |
| 45 | `46-Endpoint-Mapping-Automation.md` | Endpoint Mapping Automation | 300s | 2 |
| 46 | `47-Content-Discovery-Automation.md` | Content Discovery Automation | 600s | 2 |
| 47 | `48-Version-Detection-Automation.md` | Version Detection Automation | 120s | 1 |
| 48 | `49-Compliance-Checking-Automation.md` | Compliance Checking Automation | 300s | 1 |
| 49 | `50-Workflow-Orchestration-Automation.md` | Workflow Orchestration Automation | 1200s | 3 |

---

## Error Recovery Matrix

| Error Source | Recovery Strategy | Max Recovery Time |
|-------------|-------------------|-------------------|
| Scanner crash | Restart with same config | 10s |
| Network timeout | Retry with exponential backoff | 60s |
| Rate limit hit | Wait and retry | 30s |
| Memory exceeded | Increase limit and retry | 15s |
| Disk full | Flush output and retry | 10s |
| Permission error | Report and skip | 5s |
| Invalid target | Log and skip | 1s |
| Parse error | Log partial output | 1s |

---

## Integration Points

### With Registry

```python
tool_info = self._registry.get("nuclei")
# Returns: binary_path, default_args, timeout, allowed
```

### With Validator

```python
validation = self._validator.validate("nuclei", input_data)
# Returns: is_valid, errors, warnings
```

### With Session Manager

```python
session = self._session_manager.get(context["session_id"])
# Returns: session context, rate limits, history
```

### With Chain Executor

```python
chain_result = self._chain_executor.run_step(
    step_id="step_01",
    tool="subfinder",
    input={"domain": "example.com"}
)
# Returns: ToolResult for chain pipeline
```

---

## Performance Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Avg execution time | < 60s | > 120s |
| Success rate | > 95% | < 90% |
| Retry rate | < 5% | > 15% |
| Timeout rate | < 2% | > 5% |
| Queue wait time | < 5s | > 30s |
| Memory usage | < 512MB | > 1GB |
| Findings per scan | — | Log for trending |

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
