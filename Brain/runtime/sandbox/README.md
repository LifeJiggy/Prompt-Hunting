# Brain Runtime — Sandboxed Execution

**Component:** SandboxRunner — Isolated Code Execution Engine

Provides secure, isolated execution environments for running untrusted code and tools. The SandboxRunner enforces resource limits, captures I/O, applies security policies, and records execution traces to ensure agent operations remain safe and auditable.

---

## Purpose

The sandbox subsystem ensures safe execution by:

- **Process isolation** — Preventing untrusted code from affecting the host system
- **Resource enforcement** — CPU, memory, disk, and network limits per execution
- **I/O capture** — Recording stdout, stderr, filesystem changes, and network activity
- **Policy enforcement** — Blocking restricted operations before they execute
- **Execution recording** — Creating auditable traces of all sandboxed operations
- **Cleanup** — Removing temporary files and connections after execution

---

## Sandbox Architecture

```
┌─────────────────────────────────────────────────┐
│                 HOST SYSTEM                      │
├─────────────────────────────────────────────────┤
│              SANDBOX BOUNDARY                    │
├──────────┬──────────┬──────────┬────────────────┤
│ FILESYSTEM│ NETWORK │ PROCESS  │   RESOURCE     │
│ VIRTUAL   │ FILTERED│ MONITORED│   ENFORCED     │
│           │         │          │                │
│ Read-only │ DNS     │ PID     │ CPU limit      │
│ layers    │ filter  │ namespc │ Memory cap     │
│ Writable  │ IP      │ Signal  │ Disk quota     │
│ tmpdir    │ allow   │ block   │ Network BW     │
├──────────┴──────────┴──────────┴────────────────┤
│               AGENT CODE / TOOL                  │
│         (untrusted execution context)            │
└─────────────────────────────────────────────────┘
```

---

## Isolation Levels

The SandboxRunner supports four isolation levels, each offering a different security vs. performance tradeoff:

### None

Shared host environment. Used only for fully trusted internal code.

| Aspect | Configuration |
|--------|--------------|
| **Filesystem** | Full host access |
| **Network** | Unrestricted |
| **Process** | Same namespace |
| **Resource limits** | None enforced |
| **Use case** | Trusted internal agents |

### Namespace

Process-level isolation using Linux namespaces (or equivalent). Standard for agent operations.

| Aspect | Configuration |
|--------|--------------|
| **Filesystem** | OverlayFS with read-only base + writable tmpdir |
| **Network** | Filtered via iptables/nftables rules |
| **Process** | Separate PID namespace |
| **Resource limits** | cgroups v2 enforcement |
| **Use case** | Standard agent operations |

### Container

Full container isolation via Docker/Podman. Used for untrusted tool execution.

| Aspect | Configuration |
|--------|--------------|
| **Filesystem** | Container image with volume mounts |
| **Network** | Bridge network with egress filtering |
| **Process** | Full container isolation |
| **Resource limits** | Container resource constraints |
| **Use case** | Untrusted code execution |

### VM

Virtual machine isolation for maximum security. Used for critical or high-risk operations.

| Aspect | Configuration |
|--------|--------------|
| **Filesystem** | Dedicated VM disk image |
| **Network** | Virtual NIC with host firewall |
| **Process** | Separate kernel |
| **Resource limits** | VM resource allocation |
| **Use case** | Maximum isolation, zero-trust execution |

### Isolation Selection

```
Code Trust Level
      │
      ▼
┌───────────────┐
│ IS TRUSTED?   │
└───────┬───────┘
        │
   Fully Trusted?
   ├── Yes → None (shared)
   └── No
        │
        ▼
┌───────────────┐
│ NEEDS NETWORK?│
└───────┬───────┘
        │
   Network Required?
   ├── No  → Namespace (lightweight)
   ├── Yes → Container (full isolation)
   └── Critical → VM (maximum isolation)
```

---

## SandboxRunner

### Initialization

```python
sandbox = SandboxRunner(
    config=SandboxConfig(
        default_isolation="namespace",
        container_runtime="docker",
        tmp_dir="/tmp/brain-sandbox",
        max_execution_time=300,
        capture_output=True,
        capture_filesystem=True,
        capture_network=True,
        cleanup_on_exit=True
    ),
    event_bus=event_bus
)
```

### Executing Code

```python
result = await sandbox.execute(
    code="""
import subprocess
import json

# Run a security scanner
proc = subprocess.run(
    ['nuclei', '-version'],
    capture_output=True,
    text=True
)
print(json.dumps({
    "tool": "nuclei",
    "version": proc.stdout.strip(),
    "status": "ok"
}))
""",
    config=ExecutionConfig(
        isolation="container",
        timeout=60,
        memory_limit_mb=512,
        cpu_limit_percent=50,
        policy="standard"
    )
)
```

### Running Binaries

```python
result = await sandbox.run_binary(
    binary="/usr/local/bin/subfinder",
    args=["-dL", "targets.txt", "-silent"],
    cwd="/workspace",
    env={"PATH": "/usr/local/bin"},
    config=ExecutionConfig(
        isolation="namespace",
        timeout=300,
        memory_limit_mb=1024
    )
)
```

---

## Input/Output Capture

The SandboxRunner captures all I/O for analysis, debugging, and audit:

### Capture Types

| Capture | What It Records | Storage |
|---------|----------------|---------|
| **stdout** | Standard output stream | In-memory buffer |
| **stderr** | Standard error stream | In-memory buffer |
| **filesystem** | File create/modify/delete | Change list |
| **network** | Connections, DNS, HTTP requests | Request log |
| **process** | Spawned child processes | Process tree |
| **env** | Environment variable access | Access log |
| **signals** | Signals sent/received | Signal log |

### Capture Configuration

```yaml
capture:
  stdout:
    enabled: true
    max_size_mb: 100
    truncate: true
  stderr:
    enabled: true
    max_size_mb: 100
    truncate: true
  filesystem:
    enabled: true
    track_reads: true
    track_writes: true
    track_deletes: true
    max_events: 10000
  network:
    enabled: true
    track_dns: true
    track_tcp: true
    track_http: true
    max_events: 10000
  process:
    enabled: true
    track_spawn: true
    track_signals: true
    max_depth: 5
```

### Result Structure

```python
# ExecutionResult contains all captured I/O
result = await sandbox.execute(...)

print(result.stdout)           # "Hello, World!\n"
print(result.stderr)           # ""
print(result.exit_code)        # 0
print(result.duration_ms)      # 1234

# Filesystem changes
for change in result.filesystem_changes:
    print(f"{change.type}: {change.path}")
    # "create: /tmp/output.json"
    # "modify: /workspace/data.csv"

# Network activity
for req in result.network_requests:
    print(f"{req.method} {req.url} → {req.status}")
    # "GET https://api.example.com → 200"

# Process tree
for proc in result.process_tree:
    print(f"PID {proc.pid}: {proc.command} (exit {proc.exit_code})")
```

---

## Policy Enforcement

Policies define what operations are allowed or blocked within the sandbox:

### Built-in Policies

| Policy | Description | Restriction Level |
|--------|-------------|-------------------|
| **minimal** | Only basic I/O | Very restrictive |
| **standard** | Normal agent operations | Balanced |
| **permissive** | Extended capabilities | Relaxed |
| **custom** | User-defined rules | Configurable |

### Policy Rules

```yaml
policies:
  standard:
    filesystem:
      readable:
        - "/workspace"
        - "/usr/local/lib"
        - "/etc/ssl"
      writable:
        - "/tmp/sandbox"
        - "/workspace/output"
      blocked:
        - "/etc/passwd"
        - "/etc/shadow"
        - "/root"
        - "/home/*/.ssh"

    network:
      outbound:
        allowed:
          - "*.target.com:443"
          - "api.github.com:443"
          - "registry.npmjs.org:443"
        blocked:
          - "*.internal:80"
          - "169.254.169.254:*"  # Cloud metadata
          - "metadata.google.internal:*"
      inbound:
        blocked:
          - "*"  # No inbound connections

    process:
      allowed_binaries:
        - "/usr/local/bin/nuclei"
        - "/usr/local/bin/subfinder"
        - "/usr/local/bin/httpx"
        - "/usr/local/bin/ffuf"
        - "/usr/bin/python3"
      blocked_binaries:
        - "/usr/bin/sudo"
        - "/usr/sbin/iptables"
      max_children: 10
      allowed_signals:
        - "SIGTERM"
        - "SIGINT"

    env:
      readable:
        - "PATH"
        - "HOME"
        - "LANG"
      blocked:
        - "AWS_SECRET_ACCESS_KEY"
        - "DATABASE_URL"
        - "API_KEY"
```

### Custom Policy Definition

```python
policy = Policy(
    name="recon_only",
    filesystem=FilesystemPolicy(
        readable=["/workspace", "/usr/local/bin"],
        writable=["/tmp/sandbox"],
        blocked=["/etc", "/var", "/proc"]
    ),
    network=NetworkPolicy(
        outbound_allow=["*.target.com:443"],
        outbound_block=["169.254.169.254:*"],
        inbound_block=["*"]
    ),
    process=ProcessPolicy(
        allowed_binaries=["nuclei", "subfinder", "httpx"],
        max_children=5
    )
)

sandbox.register_policy("recon_only", policy)
```

### Policy Violation Handling

```python
@sandbox.on_policy_violation
async def handle_violation(violation):
    print(f"Policy violation: {violation.rule}")
    print(f"Operation: {violation.operation}")
    print(f"Resource: {violation.resource}")

    # Options: block, log_only, escalate
    if violation.severity == "critical":
        return Action.BLOCK_AND_ALERT
    else:
        return Action.LOG_ONLY
```

---

## Execution Recording

Every sandboxed execution creates an immutable audit record:

### Execution Record

```yaml
execution_record:
  id: "exec_abc123"
  sandbox_id: "sbx_001"
  agent: "recon_agent"
  session: "ses_xyz789"
  started_at: "2025-01-15T10:30:00Z"
  completed_at: "2025-01-15T10:30:45Z"
  duration_ms: 45200
  isolation: "container"
  policy: "standard"

  code_hash: "sha256:def456..."
  exit_code: 0

  resources:
    peak_cpu_percent: 35.2
    peak_memory_mb: 256.8
    disk_read_mb: 12.4
    disk_write_mb: 8.2
    network_sent_mb: 1.2
    network_recv_mb: 45.6

  stdout: "[captured output]"
  stderr: ""

  filesystem_changes:
    - type: "create"
      path: "/tmp/output.json"
      size: 2048
    - type: "modify"
      path: "/workspace/results.csv"
      size: 4096

  network_requests:
    - method: "GET"
      url: "https://api.target.com/v1/health"
      status: 200
      duration_ms: 120

  process_tree:
    - pid: 1
      command: "nuclei -l targets.txt"
      exit_code: 0
    - pid: 12
      command: "python3 parse_results.py"
      exit_code: 0

  policy_violations: []
```

### Recording Query

```python
# Query execution records
records = sandbox.query_records(
    agent="recon_agent",
    start="2025-01-15",
    end="2025-01-16",
    policy="standard",
    min_duration_ms=1000
)

# Get execution statistics
stats = sandbox.stats(
    agent="recon_agent",
    period="7d"
)
print(f"Total executions: {stats.total}")
print(f"Average duration: {stats.avg_duration_ms}ms")
print(f"Success rate: {stats.success_rate}%")
print(f"Policy violations: {stats.violations}")
```

---

## Sandbox Lifecycle

### Execution Lifecycle

```
Sandbox Request
      │
      ▼
┌───────────────┐
│ SELECT LEVEL  │ ← Based on trust and config
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ CREATE ENV    │ ← Allocate isolation resources
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ APPLY POLICY  │ ← Set filesystem/network/process rules
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ EXECUTE CODE  │ ← Run with monitoring
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ CAPTURE I/O   │ ← Collect stdout, stderr, changes
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ RECORD        │ ← Create execution record
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ CLEANUP       │ ← Remove temp files, release resources
└───────────────┘
```

### Cleanup Guarantees

The sandbox guarantees cleanup even on unexpected termination:

```python
# Cleanup runs automatically on:
# - Normal execution completion
# - Timeout exceeded
# - Policy violation detected
# - Signal received (SIGTERM, SIGINT)
# - Unhandled exception

# Manual cleanup
await sandbox.cleanup(execution_id="exec_abc123")

# Verify cleanup
status = sandbox.verify_cleanup(execution_id="exec_abc123")
print(status.temp_files_removed)    # True
print(status.connections_closed)    # True
print(status.resources_released)    # True
```

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | ExecutionResult, SandboxPolicy, IsolationLevel types |
| `lifecycle/` | Sandbox process lifecycle management |
| `resources/` | Per-sandbox resource quotas and monitoring |
| `health/` | Sandbox health status, cleanup verification |
| `executions/` | Task execution within sandboxed context |
| `tools/` | Tool execution isolation, policy enforcement |
| `session-managements/` | Execution records for session audit |

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
