# Brain Runtime — Health Checking

**Component:** HealthChecker — System Health Monitoring and Auto-Recovery

Monitors agent health through heartbeat signals, resource checks, dependency verification, and integrity validation. The HealthChecker detects degraded states early, triggers auto-recovery, and provides health metrics for dashboards and alerting.

---

## Purpose

The health checking subsystem provides:

- **Heartbeat monitoring** — Detecting unresponsive or crashed processes
- **Health state management** — Classifying system health into actionable states
- **Auto-recovery** — Restarting failed processes and restoring service
- **Health metrics** — Time-series health data for dashboards
- **Alerting** — Notifying operators of degraded or critical conditions
- **Dependency checks** — Verifying external services remain available

---

## Health States

Every monitored component reports one of four health states:

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ HEALTHY  │────▶│ DEGRADED │────▶│UNHEALTHY │────▶│ CRITICAL │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
     ▲               │                │                  │
     │               ▼                ▼                  ▼
     └───────────────┴────────────────┴──────────────────┘
                          (auto-recovery)
```

### State Definitions

| State | Meaning | Auto-Recovery | Alert |
|-------|---------|---------------|-------|
| **HEALTHY** | All checks passing | No action needed | None |
| **DEGRADED** | Some checks failing, service operational | Reduce workload | Warning |
| **UNHEALTHY** | Critical checks failing, service impaired | Restart process | Error |
| **CRITICAL** | Service non-functional | Kill and escalate | Critical |

### State Transitions

| From | To | Trigger |
|------|----|---------|
| HEALTHY → DEGRADED | Non-critical check fails or resource warning |
| DEGRADED → HEALTHY | All checks pass again |
| DEGRADED → UNHEALTHY | Critical check fails or error threshold exceeded |
| UNHEALTHY → DEGRADED | Recovery attempt partially successful |
| UNHEALTHY → CRITICAL | Recovery fails or process unresponsive |
| CRITICAL → UNHEALTHY | Successful restart, checks partially passing |
| CRITICAL → DEGRADED | Successful restart, most checks passing |
| CRITICAL → HEALTHY | Full recovery, all checks passing |

---

## Heartbeat Monitoring

### Heartbeat Protocol

Agents send periodic heartbeat signals to confirm they are alive and responsive:

```
Agent Process                    HealthChecker
     │                               │
     │──── heartbeat (seq=1) ───────▶│
     │                               │
     │◀─── ack (seq=1) ─────────────│
     │                               │
     │──── heartbeat (seq=2) ───────▶│
     │                               │
     │     (agent hangs)             │
     │                               │
     │   (timeout: 30s)              │
     │                               │
     │               ──▶ heartbeat_missed (count=1)
     │                               │
     │   (timeout: 60s)              │
     │                               │
     │               ──▶ heartbeat_missed (count=2)
     │                               │
     │   (timeout: 90s)              │
     │                               │
     │               ──▶ trigger_recovery
```

### Heartbeat Configuration

```yaml
heartbeat:
  enabled: true
  interval_seconds: 5
  timeout_seconds: 30
  missed_threshold: 3
  action: "restart"  # restart | alert | kill
  max_missed_before_kill: 10
```

### Heartbeat Implementation

```python
health = HealthChecker(
    config=HealthConfig(
        heartbeat_interval=5,
        heartbeat_timeout=30,
        missed_threshold=3,
        auto_recovery=True,
        recovery_max_attempts=3,
        health_check_interval=60
    ),
    event_bus=event_bus
)

# Register a process for monitoring
health.register(
    process_id="proc_001",
    agent_name="recon_agent",
    heartbeat_timeout=30
)

# Agent sends heartbeats
@agent.heartbeat
async def send_heartbeat():
    await health.heartbeat(
        process_id="proc_001",
        seq=agent.heartbeat_seq,
        state=agent.current_state
    )
```

---

## Health Checks

### Check Types

| Check | Interval | What It Verifies | Failure Impact |
|-------|----------|-----------------|----------------|
| **Heartbeat** | 5s | Process is responsive | DEGRADED → UNHEALTHY |
| **Resource** | 30s | CPU/memory within limits | HEALTHY → DEGRADED |
| **Dependency** | 60s | External services available | DEGRADED → UNHEALTHY |
| **Integrity** | 300s | System state is consistent | UNHEALTHY → CRITICAL |
| **Self-test** | 3600s | Agent can execute correctly | UNHEALTHY → CRITICAL |

### Dependency Checks

```yaml
dependencies:
  - name: "llm_api"
    type: "http"
    url: "https://api.openai.com/health"
    timeout: 10
    expected_status: 200
    critical: true

  - name: "vector_db"
    type: "tcp"
    host: "localhost"
    port: 5432
    timeout: 5
    critical: true

  - name: "redis_cache"
    type: "tcp"
    host: "localhost"
    port: 6379
    timeout: 3
    critical: false

  - name: "file_system"
    type: "path"
    path: "/workspace"
    writable: true
    critical: true
```

### Custom Health Checks

```python
@health.check("custom_validation")
async def custom_check(process_id):
    agent = get_agent(process_id)

    # Verify agent state is consistent
    if agent.memory.size > agent.config.max_memory:
        return CheckResult(
            status="fail",
            message=f"Memory exceeded: {agent.memory.size}/{agent.config.max_memory}"
        )

    # Verify agent can perform basic operations
    try:
        await agent.think("Hello")
    except Exception as e:
        return CheckResult(
            status="fail",
            message=f"Agent think failed: {e}"
        )

    return CheckResult(status="pass", message="All checks OK")
```

---

## Auto-Recovery

### Recovery Strategy

When a process becomes unhealthy, the HealthChecker attempts automatic recovery:

```
Health Degraded
      │
      ▼
┌───────────────┐
│ DIAGNOSE      │ ← What check failed? What's the severity?
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ SELECT ACTION │ ← Based on severity and failure type
└───────┬───────┘
        │
   Action?
   ├── Reduce workload (DEGRADED)
   │   └── Pause non-critical tasks
   │       Alert operator
   │
   ├── Restart process (UNHEALTHY)
   │   └── Graceful stop → Wait → Start fresh
   │       Restore from last checkpoint
   │       Alert operator
   │
   └── Kill and escalate (CRITICAL)
       └── Force-terminate process
           Alert operator
           Create incident
```

### Recovery Configuration

```yaml
recovery:
  enabled: true
  max_attempts: 3
  backoff:
    initial_seconds: 5
    multiplier: 2
    max_seconds: 120
  actions:
    degraded:
      - "reduce_workload"
      - "alert_warning"
    unhealthy:
      - "restart_process"
      - "restore_checkpoint"
      - "alert_error"
    critical:
      - "kill_process"
      - "alert_critical"
      - "create_incident"
  escalation:
    after_attempts: 3
    action: "page_operator"
```

### Recovery Events

| Event | Payload | Description |
|-------|---------|-------------|
| `health.recovery.started` | process_id, reason | Recovery attempt begins |
| `health.recovery.attempt` | process_id, attempt, action | Specific recovery action |
| `health.recovery.success` | process_id, duration_ms | Recovery completed |
| `health.recovery.failed` | process_id, attempt, error | Recovery attempt failed |
| `health.recovery.escalated` | process_id, reason | All attempts exhausted |

---

## Health Metrics

### Collected Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `health.status` | gauge | Current health state (0=healthy, 1=degraded, 2=unhealthy, 3=critical) |
| `health.uptime_seconds` | counter | Time since last restart |
| `health.heartbeat_misses` | counter | Total missed heartbeats |
| `health.checks_passed` | counter | Total successful checks |
| `health.checks_failed` | counter | Total failed checks |
| `health.recovery_attempts` | counter | Total recovery attempts |
| `health.recovery_successes` | counter | Successful recoveries |
| `health.dependencies_up` | gauge | Number of available dependencies |
| `health.dependencies_down` | gauge | Number of unavailable dependencies |

### Health Dashboard

```python
# Get current health status
status = health.status(process_id="proc_001")
print(status.state)          # "healthy"
print(status.uptime)         # "2h 30m"
print(status.last_heartbeat) # "2025-01-15T11:45:00Z"
print(status.checks)         # {"heartbeat": "pass", "memory": "pass", ...}

# Get system-wide health
system = health.system_status()
print(system.overall)        # "healthy"
print(system.processes)      # 8
print(system.healthy)        # 7
print(system.degraded)       # 1

# Get health history
history = health.history(
    process_id="proc_001",
    start="2025-01-15",
    end="2025-01-16",
    granularity="5m"
)
```

### Health History

```yaml
health_history:
  - timestamp: "2025-01-15T09:15:00Z"
    status: "healthy"
    uptime: "0s"
  - timestamp: "2025-01-15T10:30:00Z"
    status: "degraded"
    reason: "CPU usage at 85%"
    checks:
      heartbeat: "pass"
      cpu: "warn"
      memory: "pass"
  - timestamp: "2025-01-15T10:45:00Z"
    status: "healthy"
    reason: "Auto-recovered"
  - timestamp: "2025-01-15T14:20:00Z"
    status: "unhealthy"
    reason: "Heartbeat missed 5 times"
    recovery:
      action: "restart"
      success: true
      duration_ms: 12000
```

---

## Alerting

### Alert Rules

```yaml
alerts:
  - name: "process_unhealthy"
    condition: "health.status >= 2"
    severity: "error"
    channels: ["slack", "email"]

  - name: "process_critical"
    condition: "health.status == 3"
    severity: "critical"
    channels: ["slack", "email", "pager"]
    repeat_interval: "5m"

  - name: "heartbeat_missed"
    condition: "health.heartbeat_misses > 3"
    severity: "warning"
    channels: ["slack"]

  - name: "dependency_down"
    condition: "health.dependencies_down > 0"
    severity: "warning"
    channels: ["slack"]
    for: "5m"

  - name: "recovery_failed"
    condition: "health.recovery.failed"
    severity: "critical"
    channels: ["slack", "email", "pager"]
```

### Alert Channels

| Channel | Use Case | Response Time |
|---------|----------|---------------|
| **Slack** | Operational alerts | Monitor channel |
| **Email** | Non-urgent notifications | Check periodically |
| **Pager** | Critical issues requiring immediate action | Immediate |
| **Webhook** | Custom integrations | Real-time |

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | HealthStatus, HealthCheck, HealthEvent types |
| `lifecycle/` | Process state drives health assessments |
| `resources/` | Resource metrics feed health checks |
| `sandbox/` | Sandbox health, cleanup verification |
| `executions/` | Task health, execution success rates |
| `session-managements/` | Session health for checkpoint timing |
| `utils/` | Logging, metrics formatting, time helpers |

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
