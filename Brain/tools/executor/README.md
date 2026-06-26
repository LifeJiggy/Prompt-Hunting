# Tool Executor

**Component:** Safe Tool Execution Engine

Executes tool invocations with timeout enforcement, output capture, retry logic, and resource monitoring. The executor is the runtime layer that turns a tool invocation request into a standardized `ToolResult`.

---

## Overview

The `ToolExecutor` sits between the agent and external tool binaries. It enforces safety policies (timeouts, sandboxing), captures output streams, handles retries on transient failures, and produces structured results for downstream consumption.

---

## Core Class: ToolExecutor

```python
class ToolExecutor:
    """
    Executes tool invocations with safety controls and monitoring.
    
    Manages the full lifecycle of a tool call: policy check,
    process launch, output capture, timeout enforcement, and
    result formatting.
    """
    
    def __init__(self, config: ExecutorConfig = None):
        self._registry = None       # ToolRegistry reference
        self._validator = None      # ToolValidator reference
        self._policies = {}         # Tool-specific policies
        self._rate_limiters = {}    # Per-tool rate limiters
        self._execution_log = []    # Audit trail
```

---

## Execution Methods

### run()

Execute a single tool invocation.

```python
def run(
    self,
    tool: str,
    input: dict,
    config: dict = None,
    context: dict = None
) -> ToolResult:
    """
    Execute a tool with the given input.
    
    Execution flow:
    1. Look up tool in registry
    2. Validate input against tool's schema
    3. Check execution policies (allowed, rate limit, approval)
    4. Launch process with timeout
    5. Capture stdout, stderr, exit code
    6. Parse output against output schema
    7. Format and return standardized ToolResult
    8. Log invocation to audit trail
    
    Args:
        tool: Tool name or registration ID
        input: Tool input parameters
        config: Execution-specific overrides (timeout, retries)
        context: Execution context (session ID, agent ID, etc.)
    
    Returns:
        ToolResult with status, output, and metadata
    """
```

**Example:**

```python
result = executor.run(
    tool="nuclei",
    input={
        "targets": ["https://target.com"],
        "templates": ["cves/"],
        "severity": ["high", "critical"]
    },
    config={"timeout": 300, "retries": 2},
    context={"session_id": "ses_abc123", "agent_id": "agent_scanner"}
)

print(result.status)        # "success"
print(result.exit_code)     # 0
print(result.stdout)        # Raw output
print(result.findings)      # Parsed findings
print(result.duration_ms)   # 45200
```

### run_batch()

Execute multiple tool calls, optionally in parallel.

```python
def run_batch(
    self,
    invocations: list[ToolInvocation],
    parallel: bool = False,
    max_concurrent: int = 5
) -> list[ToolResult]:
    """
    Execute multiple tool invocations.
    
    Args:
        invocations: List of {tool, input, config} dicts
        parallel: If True, run independent invocations concurrently
        max_concurrent: Max parallel executions (ignored if parallel=False)
    
    Returns:
        List of ToolResult objects in invocation order
    """
```

**Example:**

```python
results = executor.run_batch(
    invocations=[
        {"tool": "subfinder", "input": {"domain": "target.com"}},
        {"tool": "httpx", "input": {"targets": ["target.com"]}},
        {"tool": "nmap", "input": {"target": "target.com", "ports": "1-1000"}}
    ],
    parallel=True,
    max_concurrent=3
)
```

---

## Timeout Enforcement

Each tool execution is bounded by a configurable timeout:

```python
@dataclass
class TimeoutConfig:
    # Default timeout for all tools (seconds)
    default: int = 60
    
    # Per-tool timeout overrides
    overrides: dict[str, int] = field(default_factory=lambda: {
        "nuclei": 300,
        "sqlmap": 1800,
        "subfinder": 120,
        "httpx": 60
    })
    
    # Hard maximum (cannot be overridden per-tool)
    maximum: int = 3600
```

When a timeout occurs:

1. The executor sends `SIGTERM` to the process
2. Waits 5 seconds for graceful shutdown
3. If still running, sends `SIGKILL`
4. Returns a `ToolResult` with `status="timeout"`
5. Logs the timeout event for audit

```python
result = executor.run(
    tool="sqlmap",
    input={"target": "https://slow-target.com/api"},
    config={"timeout": 10}  # Override to 10 seconds
)

if result.status == "timeout":
    print(f"Tool timed out after {result.timeout_s}s")
    print(f"Partial output: {result.stdout[:500]}")
```

---

## Output Capture

The executor captures three output streams from tool execution:

```python
@dataclass
class CapturedOutput:
    stdout: str          # Standard output (may be truncated)
    stderr: str          # Standard error
    exit_code: int       # Process exit code
    stdout_truncated: bool  # True if stdout exceeded max size
    stdout_size_bytes: int  # Total stdout bytes before truncation
```

**Truncation policy:**

| Stream | Max Size | Behavior |
|--------|----------|----------|
| stdout | 10 MB | Truncated, `stdout_truncated=True` |
| stderr | 1 MB | Truncated silently |
| findings | Unlimited | Parsed from stdout before truncation |

Findings are extracted before stdout truncation, so parsed results are always complete even when raw output is cut.

---

## Retry Logic

Transient failures trigger automatic retries with exponential backoff:

```python
@dataclass
class RetryConfig:
    max_retries: int = 2
    backoff_base: float = 1.0     # Initial backoff in seconds
    backoff_multiplier: float = 2.0
    retry_on_exit_codes: list[int] = field(default_factory=lambda: [1, 2])
    retry_on_timeout: bool = False  # Don't retry timeouts by default
```

**Retry conditions:**

| Condition | Retry? |
|-----------|--------|
| Exit code in `retry_on_exit_codes` | Yes |
| Process killed by signal | Yes |
| Network timeout (connection refused) | Yes |
| Execution timeout | No (by default) |
| Validation error | No |
| Policy violation | No |

**Backoff schedule:**

```
Attempt 1: Immediate
Attempt 2: Wait 1s
Attempt 3: Wait 2s
Attempt 4: Wait 4s
```

```python
result = executor.run(
    tool="httpx",
    input={"targets": ["https://target.com"]},
    config={"retries": 3}
)

# If attempt 1 fails with exit code 1,
# executor waits 1s, tries again (attempt 2),
# waits 2s, tries again (attempt 3).
# Returns ToolResult with retry_count=2.
```

---

## Execution Logging

Every invocation produces a detailed audit log entry:

```python
@dataclass
class ExecutionLog:
    invocation_id: str        # Unique execution ID
    tool: str                 # Tool name
    agent_id: str             # Invoking agent
    session_id: str           # Session context
    timestamp_start: str      # ISO 8601 start time
    timestamp_end: str        # ISO 8601 end time
    duration_ms: int          # Wall clock duration
    status: str               # "success" | "error" | "timeout" | "policy_denied"
    exit_code: int            # Process exit code
    input_hash: str           # SHA-256 of input parameters
    output_size_bytes: int    # Size of captured output
    retry_count: int          # Number of retry attempts
    resources: ResourceUsage  # CPU/memory consumption
```

**Querying the log:**

```python
# Get recent executions
recent = executor.get_log(limit=50)

# Filter by tool
nuclei_runs = executor.get_log(tool="nuclei", limit=20)

# Filter by status
failures = executor.get_log(status="error")

# Get execution by ID
entry = executor.get_log(invocation_id="inv_abc123")
```

---

## Concurrent Execution

The executor manages concurrent tool calls with resource limits:

```python
@dataclass
class ConcurrencyConfig:
    max_concurrent: int = 5       # Max simultaneous tool processes
    max_per_tool: int = 2         # Max concurrent per tool name
    queue_size: int = 100         # Max queued invocations
    process_priority: str = "normal"  # "low" | "normal" | "high"
```

**Concurrency behavior:**

- Invocations exceeding `max_concurrent` are queued
- Queue is FIFO with optional priority override
- Each tool respects its `max_per_tool` limit
- Queued invocations timeout after 60 seconds if not started

```python
# Execute 20 tools with concurrency limit of 5
results = executor.run_batch(
    invocations=[...20 items...],
    parallel=True,
    max_concurrent=5
)

# Check queue status
queue_status = executor.get_queue_status()
print(queue_status.running)    # 5
print(queue_status.queued)     # 15
print(queue_status.completed)  # 0
```

---

## Resource Monitoring

The executor tracks resource consumption per invocation:

```python
@dataclass
class ResourceUsage:
    peak_memory_mb: float      # Peak memory usage
    cpu_time_s: float          # CPU time consumed
    wall_time_s: float         # Real elapsed time
    io_read_bytes: int         # Disk I/O read
    io_write_bytes: int        # Disk I/O write
```

Resource limits are enforced by the runtime sandbox:

| Resource | Default Limit | Action on Exceed |
|----------|---------------|------------------|
| Memory | 512 MB | Process killed |
| CPU time | 300s | Process killed |
| Wall time | Configured timeout | Timeout error |
| Disk I/O | 1 GB | Warning logged |

---

## Execution Flow Diagram

```
Tool Invocation Request
        │
        ▼
┌───────────────┐
│ LOOKUP TOOL   │ ← Find in ToolRegistry
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ VALIDATE INPUT│ ← ToolValidator checks schema
└───────┬───────┘
        │
   Valid?
   ├── No → Return ToolResult(status="validation_error")
   └── Yes
        │
        ▼
┌───────────────┐
│ CHECK POLICY  │ ← Is tool allowed? Rate limit?
└───────┬───────┘
        │
   Allowed?
   ├── No → Return ToolResult(status="policy_denied")
   └── Yes
        │
        ▼
┌───────────────┐
│ ACQUIRE SLOT  │ ← Concurrency limit check
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ LAUNCH PROCESS│ ← Start with timeout
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ CAPTURE OUTPUT│ ← stdout, stderr, exit code
└───────┬───────┘
        │
  Failed?
  ├── Yes + retries left → Wait backoff, retry
  └── No / retries exhausted
        │
        ▼
┌───────────────┐
│ PARSE OUTPUT  │ ← Extract findings from stdout
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ FORMAT RESULT │ ← Standardized ToolResult
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ LOG & RELEASE │ ← Audit trail + free concurrency slot
└───────────────┘
```

---

## Error Handling

| Error Type | Result Status | Retryable |
|------------|---------------|-----------|
| Tool not found | `tool_not_found` | No |
| Validation failed | `validation_error` | No |
| Policy denied | `policy_denied` | No |
| Process timeout | `timeout` | Configurable |
| Non-zero exit | `error` | Configurable |
| Parse error | `parse_error` | No |
| Resource limit | `resource_exceeded` | No |
| Internal error | `internal_error` | No |

---

*Part of the Brain tools subsystem — Prompt-Hunting.*
