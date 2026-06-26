# Brain Runtime — Process Lifecycle Management

**Component:** RuntimeManager — Agent Process Lifecycle Control

Manages the complete lifecycle of agent processes from creation through shutdown. The RuntimeManager provides deterministic state transitions, graceful shutdown, signal handling, and process monitoring to ensure agents run reliably within the Brain infrastructure.

---

## Purpose

The lifecycle subsystem is responsible for:

- **Process state management** — Tracking and enforcing valid state transitions
- **Start/stop/restart** — Controlling agent process execution
- **Graceful shutdown** — Ensuring clean resource release on termination
- **Signal handling** — Responding to OS signals (SIGTERM, SIGINT, SIGHUP)
- **Process monitoring** — Detecting crashes, hangs, and resource exhaustion
- **State persistence** — Surviving system restarts through state serialization

---

## Process States

Every agent process moves through a defined state machine:

```
         ┌──────────┐
    ┌───▶│ CREATED  │
    │    └────┬─────┘
    │         │ start()
    │    ┌────▼─────┐
    │    │ RUNNING  │◀──────────┐
    │    └────┬─────┘           │
    │         │ pause()         │ resume()
    │    ┌────▼─────┐           │
    ├───▶│ PAUSED   │───────────┘
    │    └────┬─────┘
    │         │ stop()
    │    ┌────▼─────┐
    │    │ STOPPED  │
    │    └──────────┘
    │
    │    ┌──────────┐    ┌──────────────┐
    └───▶│  ERROR   │───▶│ RESTARTING   │
         └──────────┘    └──────────────┘
```

### State Definitions

| State | Description | Entry Conditions | Allowed Transitions |
|-------|-------------|------------------|---------------------|
| **CREATED** | Process allocated but not started | Initial state after creation | → RUNNING |
| **RUNNING** | Actively executing agent code | start() called successfully | → PAUSED, → STOPPED, → ERROR |
| **PAUSED** | Suspended, resources held | pause() called while RUNNING | → RUNNING (resume), → STOPPED |
| **STOPPED** | Terminated cleanly | stop() called or self-terminate | → CREATED (restart) |
| **ERROR** | Unhandled exception or crash | Exception during execution | → RESTARTING, → STOPPED |
| **RESTARTING** | Recovering from error state | auto-recovery triggered | → RUNNING, → STOPPED (final) |

### Invalid Transitions

Attempting an invalid transition raises a `StateTransitionError`:

```
CREATED → STOPPED     (must start first)
PAUSED  → ERROR       (must resume before stopping)
STOPPED → RUNNING     (must create/restart first)
```

---

## RuntimeManager

### Initialization

```python
manager = RuntimeManager(
    config=RuntimeConfig(
        max_concurrent=5,
        shutdown_timeout=30,
        health_check_interval=60,
        auto_restart=true,
        max_restart_attempts=3
    ),
    event_bus=event_bus
)
```

### Creating Processes

```python
process = manager.create(
    name="recon_agent",
    agent_class=ReconAgent,
    config=AgentConfig(
        model="gpt-4",
        tools=["subfinder", "httpx"],
        sandbox="namespace"
    ),
    metadata={
        "session_id": "ses_abc123",
        "task_id": "T1",
        "priority": "high"
    }
)

# Process is in CREATED state
print(process.state)       # "created"
print(process.pid)         # None (not yet started)
print(process.created_at)  # timestamp
```

### Starting Processes

```python
process.start()

# Process transitions: CREATED → RUNNING
print(process.state)   # "running"
print(process.pid)     # 12345
print(process.started_at)  # timestamp
```

### Pausing and Resuming

```python
# Pause a running process
process.pause()
# RUNNING → PAUSED
print(process.state)   # "paused"

# Resume a paused process
process.resume()
# PAUSED → RUNNING
print(process.state)   # "running"
```

### Stopping Processes

```python
# Clean stop — waits for current operation to complete
process.stop(timeout=30)
# RUNNING/PAUSED → STOPPED

# Force stop — terminates immediately
process.kill()
# Any → STOPPED (force)
```

### Restarting Processes

```python
# Restart — stop then create fresh
process.restart()
# STOPPED → CREATED → RUNNING

# Restart with new config
process.restart(
    config=AgentConfig(model="gpt-4-turbo")
)
```

---

## Graceful Shutdown

The RuntimeManager implements a multi-phase shutdown to prevent data loss:

### Shutdown Phases

```
Phase 1: Notify (0-5s)
├── Send SIGTERM to child processes
├── Fire "shutdown.initiated" event
└── Allow in-flight operations to complete

Phase 2: Drain (5-30s)
├── Stop accepting new tasks
├── Complete active tasks (with timeout)
├── Flush pending logs and metrics
└── Checkpoint session state

Phase 3: Cleanup (30-60s)
├── Release system resources
├── Close network connections
├── Delete temporary files
└── Write final state to disk

Phase 4: Terminate (last resort)
├── Send SIGKILL to remaining processes
└── Exit with appropriate code
```

### Shutdown Example

```python
# Initiate graceful shutdown
await manager.shutdown(timeout=60)

# Or with a callback
await manager.shutdown(
    timeout=60,
    on_phase=lambda phase, progress: print(f"Phase {phase}: {progress}%")
)

# Check if shutdown completed cleanly
if manager.shutdown_complete:
    print("All processes stopped cleanly")
else:
    print(f"Forced termination: {manager.forced_count} processes")
```

### Shutdown Hooks

Register custom cleanup logic:

```python
@manager.on_shutdown
async def cleanup_connections():
    await db_pool.close()
    await redis_client.close()

@manager.on_shutdown(priority=1)  # Higher priority runs first
async def save_final_state():
    await session_store.flush()
```

---

## Signal Handling

The RuntimeManager catches OS signals and routes them to appropriate handlers:

| Signal | Default Action | Configurable |
|--------|---------------|--------------|
| **SIGTERM** | Initiate graceful shutdown | Yes |
| **SIGINT** | Initiate graceful shutdown | Yes |
| **SIGHUP** | Reload configuration | Yes |
| **SIGUSR1** | Dump diagnostic state | Yes |
| **SIGUSR2** | Toggle debug logging | Yes |
| **SIGKILL** | Immediate termination (uncatchable) | No |

### Signal Configuration

```yaml
signals:
  SIGTERM: "graceful_shutdown"
  SIGINT: "graceful_shutdown"
  SIGHUP: "reload_config"
  SIGUSR1: "dump_state"
  SIGUSR2: "toggle_debug"
  custom:
    - signal: "SIGUSR1"
      handler: "custom_handler"
      description: "Custom diagnostic dump"
```

### Custom Signal Handlers

```python
@manager.on_signal("SIGUSR1")
async def custom_diagnostics(signum, frame):
    state = manager.dump_state()
    await write_to_file("/tmp/brain_state.json", state)
```

---

## Process Monitoring

### Monitoring Loop

The RuntimeManager runs a background monitoring loop that checks:

- **Heartbeat** — Is the process responding?
- **Resource usage** — Is the process within limits?
- **Error rate** — Are errors accumulating?
- **Log volume** — Is the process producing output?

### Monitoring Configuration

```yaml
monitoring:
  enabled: true
  interval_seconds: 10
  heartbeat:
    enabled: true
    timeout_seconds: 30
    action: "restart"  # restart | alert | kill
  resource_check:
    enabled: true
    interval_seconds: 30
    cpu_threshold: 90
    memory_threshold: 90
    action: "alert"
  error_tracking:
    enabled: true
    window_seconds: 300
    max_errors: 10
    action: "restart"
```

### Monitoring Events

| Event | Payload | Trigger |
|-------|---------|---------|
| `process.heartbeat_missed` | process_id, count | Heartbeat not received |
| `process.resource_warning` | process_id, resource, value | Resource near threshold |
| `process.resource_critical` | process_id, resource, value | Resource at critical level |
| `process.error_threshold` | process_id, error_count, window | Too many errors |
| `process.state_changed` | process_id, old_state, new_state | Any state transition |
| `process.restarted` | process_id, attempt, reason | Auto-restart triggered |

---

## Auto-Recovery

When a process enters the ERROR state, the RuntimeManager can automatically attempt recovery:

### Recovery Strategy

```
Error detected
      │
      ▼
┌───────────────┐
│ CHECK RETRIES │ ← Have we exceeded max_restart_attempts?
└───────┬───────┘
        │
   Within Limit?
   ├── Yes → Exponential backoff wait
   │         Restart process
   │         Reset error counter
   └── No  → Mark as STOPPED
             Fire "process.recovery_failed" event
             Alert operator
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
  reset_after:
    success_minutes: 30
  escalate_after:
    attempts: 3
    action: "alert_operator"
```

---

## Process Monitoring Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `process_state` | gauge | Current state (0=created, 1=running, ...) |
| `process_uptime_seconds` | counter | Time in RUNNING state |
| `process_restarts_total` | counter | Number of restarts |
| `process_errors_total` | counter | Number of error transitions |
| `process_cpu_percent` | gauge | Current CPU usage |
| `process_memory_mb` | gauge | Current memory usage |
| `process_threads` | gauge | Active thread count |
| `process_open_files` | gauge | Open file descriptors |

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | ProcessState, ProcessConfig, ProcessEvent types |
| `resources/` | CPU/memory limits, resource monitoring |
| `sandbox/` | Process isolation for untrusted code |
| `health/` | Health status drives restart decisions |
| `executions/` | Process lifecycle for task execution |
| `session-managements/` | Session checkpoint on shutdown |

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
