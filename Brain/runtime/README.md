# Brain Runtime

**Component:** Execution Environment Management

Manages the safe and efficient execution environment for agent operations. Runtime handles process lifecycle, resource monitoring, sandboxed code execution, health checking, and metrics collection. It is the foundation that keeps agents running reliably.

---

## Purpose

Runtime provides the operational environment where agents execute. It handles:

- **Process lifecycle** — Starting, stopping, and monitoring agent processes
- **Resource monitoring** — CPU, memory, disk, and network usage tracking
- **Sandboxed execution** — Running untrusted code safely
- **Health checking** — Detecting and recovering from unhealthy states
- **Metrics collection** — Gathering performance and operational data
- **Environment isolation** — Preventing cross-contamination between agents

---

## Runtime Architecture

```
┌─────────────────────────────────────────────┐
│                RUNTIME                      │
├──────────┬──────────┬──────────┬────────────┤
│ PROCESS  │ RESOURCE │ SANDBOX  │  HEALTH    │
│ MANAGER  │ MONITOR  │ ENGINE   │  CHECKER   │
│          │          │          │            │
│ Lifecycle│ CPU/RAM  │ Isolation│ Heartbeat  │
│ Start    │ Disk/Net │ Timeout  │ Status     │
│ Stop     │ Limits   │ Output   │ Recovery   │
│ Restart  │ Quotas   │ Capture  │ Alerting   │
└──────────┴──────────┴──────────┴────────────┘
```

---

## Process Management

### Process States

```
         ┌──────────┐
    ┌───▶│ CREATED  │
    │    └────┬─────┘
    │         │ start()
    │    ┌────▼─────┐
    │    │ RUNNING  │◀──┐
    │    └────┬─────┘   │ restart()
    │         │         │
    │    ┌────▼─────┐   │
    ├───▶│ PAUSED   │───┘
    │    └────┬─────┘
    │         │ stop()
    │    ┌────▼─────┐
    │    │ STOPPED  │
    │    └──────────┘
    │
    │    ┌──────────┐
    └───▶│  ERROR   │
         └──────────┘
```

### Process Operations

```python
# Create and start a process
proc = runtime.process.create(
    name="nuclei_scanner",
    command="nuclei -l targets.txt -t critical/",
    cwd="/workspace",
    env={"PATH": "/usr/local/bin"}
)
proc.start()

# Monitor process
status = proc.status()  # running, stopped, error
logs = proc.logs(last_n=100)
metrics = proc.metrics()

# Control process
proc.pause()
proc.resume()
proc.stop()
proc.restart()

# Cleanup
proc.destroy()
```

### Process Isolation

Each agent process runs in isolation:

| Isolation Level | Description | Use Case |
|----------------|-------------|----------|
| **None** | Shared environment | Trusted internal agents |
| **Namespace** | Separate process namespace | Standard agent operations |
| **Container** | Docker/Podman container | Untrusted tool execution |
| **VM** | Virtual machine | Maximum isolation |

---

## Resource Monitoring

### Monitored Resources

| Resource | Metric | Warning Threshold | Critical Threshold |
|----------|--------|-------------------|-------------------|
| **CPU** | Usage % | 70% | 90% |
| **Memory** | Usage MB | 80% of limit | 95% of limit |
| **Disk** | Usage % | 75% | 90% |
| **Network** | Bandwidth | 80% of cap | 95% of cap |
| **Files** | Open count | 80% of limit | 95% of limit |
| **Threads** | Count | 80% of limit | 95% of limit |

### Resource Quotas

```yaml
resource_quotas:
  agent:
    max_cpu_percent: 50
    max_memory_mb: 2048
    max_disk_mb: 10240
    max_network_mbps: 100
    max_open_files: 1024
    max_threads: 64
  global:
    total_cpu_percent: 80
    total_memory_mb: 8192
    total_disk_mb: 51200
    total_network_mbps: 500
```

### Resource Enforcement

```
Resource Request
      │
      ▼
┌───────────────┐
│ CHECK QUOTA   │ ← Is resource within limits?
└───────┬───────┘
        │
   Within Limits?
   ├── Yes → Allocate resource
   │         Start/continue process
   └── No  → Reject request
             Throttle process
             Or kill if critical
```

---

## Sandboxed Execution

Running untrusted code safely:

### Sandbox Layers

```
┌──────────────────────────────────┐
│          HOST SYSTEM             │
├──────────────────────────────────┤
│       SANDBOX BOUNDARY          │
├──────────┬──────────┬────────────┤
│ FILESYSTEM│ NETWORK │ PROCESS    │
│ RESTRICTED│ FILTERED│ MONITORED  │
├──────────┴──────────┴────────────┤
│         AGENT CODE               │
└──────────────────────────────────┘
```

### Sandbox Policies

| Policy | Restriction |
|--------|-------------|
| **filesystem.read** | Whitelist of readable paths |
| **filesystem.write** | Whitelist of writable paths |
| **network.outbound** | Allowed destinations and ports |
| **network.inbound** | Blocked inbound connections |
| **process.spawn** | Allowed executable paths |
| **process.signal** | Blocked signals (SIGKILL, etc.) |
| **env.read** | Allowed environment variables |
| **env.write** | Blocked environment modification |

### Execution Capture

```python
# Run code in sandbox
result = runtime.sandbox.execute(
    code="""
import subprocess
result = subprocess.run(['nuclei', '-version'], capture_output=True)
print(result.stdout)
""",
    timeout=30,
    policy="standard",
    capture={
        "stdout": True,
        "stderr": True,
        "filesystem_changes": True,
        "network_requests": True,
        "process_tree": True
    }
)

# Inspect results
print(result.stdout)
print(result.stderr)
print(result.filesystem_changes)
print(result.network_requests)
```

---

## Health Checking

### Health Check Types

| Check | Interval | What It Verifies |
|-------|----------|-----------------|
| **Heartbeat** | 5s | Process is responsive |
| **Resource** | 30s | Resources within limits |
| **Dependency** | 60s | Required services available |
| **Integrity** | 300s | System state is consistent |
| **Self-test** | 3600s | Agent can execute correctly |

### Health Status

```yaml
health:
  status: "healthy"
  uptime: "2h 30m"
  last_heartbeat: "2025-01-15T11:45:00Z"
  checks:
    heartbeat: "pass"
    memory: "pass"
    cpu: "warn"  # 72% usage
    disk: "pass"
    network: "pass"
    dependencies: "pass"
  history:
    - timestamp: "2025-01-15T09:15:00Z"
      status: "healthy"
    - timestamp: "2025-01-15T10:30:00Z"
      status: "degraded"  # High CPU
    - timestamp: "2025-01-15T10:45:00Z"
      status: "healthy"   # Auto-recovered
```

### Recovery Actions

| Health State | Action |
|-------------|--------|
| **Healthy** | No action needed |
| **Degraded** | Alert, reduce workload |
| **Unhealthy** | Restart process, alert |
| **Critical** | Kill process, alert, escalate |

---

## Metrics Collection

### Collected Metrics

| Category | Metrics |
|----------|---------|
| **Performance** | Task completion time, throughput, latency |
| **Resource** | CPU usage, memory usage, disk I/O, network I/O |
| **Reliability** | Error rate, retry rate, uptime |
| **Operational** | Tasks completed, tasks failed, queue depth |
| **Business** | Findings discovered, reports generated |

### Metrics Export

```python
# Get current metrics
metrics = runtime.metrics.collect()

# Export to monitoring system
runtime.metrics.export(
    format="prometheus",
    endpoint="http://prometheus:9090/metrics"
)

# Query historical metrics
history = runtime.metrics.query(
    metric="task_completion_time",
    start="2025-01-15T00:00:00Z",
    end="2025-01-15T23:59:59Z",
    aggregation="avg"
)
```

---

## Environment Management

### Environment Types

| Type | Purpose | Isolation |
|------|---------|-----------|
| **Development** | Testing and debugging | Low |
| **Staging** | Pre-production validation | Medium |
| **Production** | Live agent operations | High |
| **Sandbox** | Untrusted code execution | Maximum |

### Environment Configuration

```yaml
environment:
  type: "production"
  workspace: "/opt/brain/workspace"
  temp_dir: "/tmp/brain"
  log_dir: "/var/log/brain"
  max_concurrent_agents: 10
  graceful_shutdown_timeout: 30
```

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | HealthStatus, MetricsReport, ResourceLimits types |
| `executions/` | Process resources for task execution |
| `memory/` | Memory resource monitoring, storage health |
| `session-managements/` | Process state for session checkpointing |
| `tools/` | Sandboxed tool execution, resource limits |
| `utils/` | Logging, metrics formatting |

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
