# Brain Runtime — Resource Monitoring

**Component:** ResourceMonitor — System Resource Tracking and Enforcement

Tracks CPU, memory, disk, and network usage across all agent processes. The ResourceMonitor enforces quotas, detects resource exhaustion, and provides historical metrics to support capacity planning and performance optimization.

---

## Purpose

The resource monitoring subsystem provides:

- **Real-time tracking** — CPU, memory, disk, network, and process-level metrics
- **Quota enforcement** — Per-agent and global resource limits with hard/soft thresholds
- **Usage alerts** — Early warning when resources approach limits
- **Resource reporting** — Aggregated metrics for dashboards and alerting
- **Historical metrics** — Time-series storage for trend analysis and capacity planning
- **Resource governance** — Throttle or kill processes exceeding their allocations

---

## ResourceMonitor Architecture

```
┌─────────────────────────────────────────────┐
│            RESOURCE MONITOR                 │
├──────────┬──────────┬──────────┬────────────┤
│   CPU    │ MEMORY   │  DISK    │  NETWORK   │
│ TRACKER  │ TRACKER  │ TRACKER  │  TRACKER   │
│          │          │          │            │
│ Usage %  │ RSS/Heap │ I/O Rate │ Bandwidth  │
│ Load Avg │ Swap     │ Free/Used│ Packets    │
│ Per-Core │ CGroups  │ IOPS     │ Connections│
├──────────┴──────────┴──────────┴────────────┤
│              QUOTA ENGINE                   │
│         Check / Allocate / Release          │
├─────────────────────────────────────────────┤
│           HISTORICAL STORE                  │
│       Time-Series Metrics Database          │
└─────────────────────────────────────────────┘
```

---

## Monitored Resources

### CPU

| Metric | Description | Unit |
|--------|-------------|------|
| `cpu.usage_percent` | Total CPU utilization | % |
| `cpu.per_core` | Per-core utilization | % |
| `cpu.load_1m` | 1-minute load average | float |
| `cpu.load_5m` | 5-minute load average | float |
| `cpu.load_15m` | 15-minute load average | float |
| `cpu.iowait` | Time waiting for I/O | % |
| `cpu.user_time` | Time in user mode | seconds |
| `cpu.system_time` | Time in kernel mode | seconds |

### Memory

| Metric | Description | Unit |
|--------|-------------|------|
| `memory.rss` | Resident Set Size | MB |
| `memory.vms` | Virtual Memory Size | MB |
| `memory.heap` | Heap allocation | MB |
| `memory.swap` | Swap usage | MB |
| `memory.available` | Available system memory | MB |
| `memory.cache` | File system cache | MB |
| `memory.buffer` | Buffer memory | MB |
| `memory.gc_collections` | Garbage collection runs | count |

### Disk

| Metric | Description | Unit |
|--------|-------------|------|
| `disk.read_bytes` | Total bytes read | bytes |
| `disk.write_bytes` | Total bytes written | bytes |
| `disk.read_iops` | Read operations per second | count |
| `disk.write_iops` | Write operations per second | count |
| `disk.free` | Free disk space | MB |
| `disk.used` | Used disk space | MB |
| `disk.total` | Total disk space | MB |
| `disk.usage_percent` | Disk utilization | % |

### Network

| Metric | Description | Unit |
|--------|-------------|------|
| `network.bytes_sent` | Total bytes transmitted | bytes |
| `network.bytes_recv` | Total bytes received | bytes |
| `network.packets_sent` | Total packets transmitted | count |
| `network.packets_recv` | Total packets received | count |
| `network.connections_active` | Active TCP connections | count |
| `network.connections_established` | Established connections | count |
| `network.bandwidth_mbps` | Current bandwidth usage | Mbps |
| `network.errors` | Network error count | count |

---

## Quota System

### Quota Definitions

```yaml
resource_quotas:
  per_agent:
    cpu:
      soft_percent: 50      # Warning threshold
      hard_percent: 80      # Throttle threshold
      kill_percent: 95      # Kill threshold
    memory:
      soft_mb: 1024
      hard_mb: 2048
      kill_mb: 3072
    disk:
      soft_mb: 5120
      hard_mb: 10240
      kill_mb: 15360
    network:
      soft_mbps: 50
      hard_mbps: 100
      kill_mbps: 150
    open_files:
      soft: 256
      hard: 512
      kill: 1024
    threads:
      soft: 16
      hard: 32
      kill: 64

  global:
    total_cpu_percent: 80
    total_memory_mb: 8192
    total_disk_mb: 51200
    total_network_mbps: 500
    total_open_files: 4096
```

### Threshold Levels

| Level | Action | Description |
|-------|--------|-------------|
| **Soft** | Log warning | Alert operator, no enforcement |
| **Hard** | Throttle process | Reduce priority, slow execution |
| **Kill** | Terminate process | Force-kill the process |

### Quota Enforcement Flow

```
Resource Request
      │
      ▼
┌───────────────┐
│ CHECK SOFT    │ ← Within soft limit?
└───────┬───────┘
        │
   Within Soft?
   ├── No → Log warning event
   └── Yes (or warning logged)
        │
        ▼
┌───────────────┐
│ CHECK HARD    │ ← Within hard limit?
└───────┬───────┘
        │
   Within Hard?
   ├── No → Throttle process
   │         Log throttle event
   └── Yes
        │
        ▼
┌───────────────┐
│ CHECK KILL    │ ← Within kill limit?
└───────┬───────┘
        │
   Within Kill?
   ├── No → Kill process
   │         Log kill event
   └── Yes → Allow resource allocation
```

---

## Resource Tracking

### Initialization

```python
monitor = ResourceMonitor(
    config=ResourceConfig(
        tracking_interval=5,
        history_retention_days=30,
        export_format="prometheus",
        alert_thresholds={
            "cpu_soft": 70,
            "cpu_hard": 90,
            "memory_soft": 80,
            "memory_hard": 95
        }
    ),
    event_bus=event_bus
)

# Start monitoring
monitor.start()
```

### Per-Process Tracking

```python
# Attach tracker to a process
tracker = monitor.track(
    process_id="proc_001",
    agent_name="recon_agent",
    quotas=QuotaSet(
        cpu_percent=50,
        memory_mb=2048,
        disk_mb=10240
    )
)

# Get current usage
usage = tracker.current()
print(usage.cpu_percent)    # 23.5
print(usage.memory_mb)      # 512.3
print(usage.disk_read_mbps) # 12.8

# Get usage over time
history = tracker.history(
    start="2025-01-15T00:00:00Z",
    end="2025-01-15T23:59:59Z",
    interval="1m"
)
```

### Aggregated Metrics

```python
# Get system-wide resource usage
system = monitor.system_summary()
print(system.total_cpu_percent)    # 45.2
print(system.total_memory_mb)      # 6144
print(system.active_processes)     # 8

# Get per-agent breakdown
agents = monitor.agent_breakdown()
for agent in agents:
    print(f"{agent.name}: CPU={agent.cpu_percent}%, MEM={agent.memory_mb}MB")
```

---

## Usage Alerts

### Alert Rules

```yaml
alert_rules:
  - name: "high_cpu"
    metric: "cpu.usage_percent"
    threshold: 80
    duration: "5m"
    severity: "warning"
    action: "notify"

  - name: "critical_cpu"
    metric: "cpu.usage_percent"
    threshold: 95
    duration: "1m"
    severity: "critical"
    action: "throttle"

  - name: "memory_pressure"
    metric: "memory.usage_percent"
    threshold: 90
    duration: "2m"
    severity: "warning"
    action: "notify"

  - name: "disk_low"
    metric: "disk.free_mb"
    threshold: 1024
    duration: "0m"
    severity: "critical"
    action: "alert"

  - name: "network_saturated"
    metric: "network.bandwidth_mbps"
    threshold: 90
    duration: "10m"
    severity: "warning"
    action: "notify"
```

### Alert Events

| Event | Severity | Trigger |
|-------|----------|---------|
| `resource.warning` | warning | Soft threshold exceeded |
| `resource.throttle` | warning | Hard threshold exceeded |
| `resource.kill` | critical | Kill threshold exceeded |
| `resource.recovered` | info | Usage dropped below threshold |
| `resource.quota_exceeded` | error | Agent exceeded quota allocation |

---

## Historical Metrics

### Time-Series Storage

All metrics are stored in a time-series format for trend analysis:

```python
# Query historical data
metrics = monitor.query(
    metric="cpu.usage_percent",
    process_id="proc_001",
    start="2025-01-01",
    end="2025-01-31",
    granularity="1h",
    aggregation="avg"
)

# Aggregate across processes
system_avg = monitor.query(
    metric="memory.rss",
    start="2025-01-15",
    end="2025-01-16",
    granularity="5m",
    aggregation="max",
    group_by="agent_name"
)
```

### Retention Policies

```yaml
retention:
  raw_metrics:
    granularity: "5s"
    retention_days: 7
  hourly_aggregates:
    granularity: "1h"
    retention_days: 30
  daily_aggregates:
    granularity: "1d"
    retention_days: 365
  summary_stats:
    granularity: "7d"
    retention_days: "unlimited"
```

### Capacity Planning

```python
# Predict resource needs
forecast = monitor.forecast(
    metric="memory.rss",
    horizon_days=30,
    confidence=0.95
)

print(f"Predicted peak memory: {forecast.peak_mb}MB")
print(f"Growth rate: {forecast.growth_percent_per_day}%")
print(f"Projected exhaustion: {forecast.exhaustion_date}")
```

---

## Resource Reporting

### Report Types

| Report | Contents | Use Case |
|--------|----------|----------|
| **Current** | Live resource snapshot | Real-time dashboards |
| **Hourly** | Averages, peaks, totals | Operational monitoring |
| **Daily** | Trends, top consumers | Capacity planning |
| **Weekly** | Aggregated stats, anomalies | Executive reporting |
| **Custom** | User-defined queries | Ad-hoc analysis |

### Report Generation

```python
# Generate a daily report
report = monitor.report(
    type="daily",
    date="2025-01-15",
    sections=["cpu", "memory", "disk", "network"],
    format="json"
)

# Export to monitoring system
monitor.export(
    format="prometheus",
    endpoint="http://prometheus:9090/metrics/job/brain"
)

# Export to file
monitor.export(
    format="json",
    path="/var/log/brain/metrics/2025-01-15.json"
)
```

### Metric Format (Prometheus)

```
# HELP brain_cpu_usage_percent Current CPU usage
# TYPE brain_cpu_usage_percent gauge
brain_cpu_usage_percent{agent="recon_agent",process="proc_001"} 23.5
brain_cpu_usage_percent{agent="scanner_agent",process="proc_002"} 45.2

# HELP brain_memory_rss_mb Current RSS memory
# TYPE brain_memory_rss_mb gauge
brain_memory_rss_mb{agent="recon_agent",process="proc_001"} 512.3
brain_memory_rss_mb{agent="scanner_agent",process="proc_002"} 1024.8

# HELP brain_process_restarts_total Total process restarts
# TYPE brain_process_restarts_total counter
brain_process_restarts_total{agent="recon_agent",process="proc_001"} 2
```

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | ResourceLimits, MetricsReport, AlertEvent types |
| `lifecycle/` | Process state drives tracking attachment/detachment |
| `sandbox/` | Per-sandbox resource quotas |
| `health/` | Resource metrics feed health assessments |
| `executions/` | Task resource requirements, pre-flight checks |
| `utils/` | Logging, metrics formatting, time-series helpers |

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
