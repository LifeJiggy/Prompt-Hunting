# Brain Session Managements

**Component:** Session Lifecycle Management

Manages agent session creation, state persistence, checkpoint management, session isolation, and checkpoint-based recovery. Sessions provide the continuity layer that lets agents resume work after interruptions.

---

## Purpose

Sessions solve the problem of agent continuity. Without session management, agents lose all context when interrupted. Sessions provide:

- **Session creation** — Initialize new agent sessions with unique identities
- **State persistence** — Save agent state to survive process restarts
- **Checkpoint management** — Regular state snapshots for recovery
- **Session isolation** — Prevent cross-session data leakage
- **Recovery** — Resume from last checkpoint after failure
- **History** — Track session lifecycle for debugging

---

## Session Lifecycle

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  CREATE  │───▶│  ACTIVE  │───▶│ CHECKPOINT│───▶│  ACTIVE  │
└──────────┘    └────┬─────┘    └──────────┘    └────┬─────┘
                     │                               │
                     ▼                               ▼
                ┌──────────┐                   ┌──────────┐
                │ SUSPEND  │──────────────────▶│ RESUME   │
                └────┬─────┘                   └──────────┘
                     │
                     ▼
                ┌──────────┐
                │  CLOSE   │
                └──────────┘
```

---

## Core Concepts

### Session

A session represents a continuous unit of agent work:

```yaml
session:
  id: "ses_abc123"
  agent_id: "agent_planner"
  created: "2025-01-15T10:00:00Z"
  status: "active"
  state:
    current_task: "scan_target.com"
    working_memory:
      subdomains: ["api.target.com", "admin.target.com"]
      findings_count: 3
    execution_plan:
      current_step: 2
      completed_steps: [1]
  checkpoints:
    - id: "cp_001"
      timestamp: "2025-01-15T10:05:00Z"
      state_hash: "abc123..."
    - id: "cp_002"
      timestamp: "2025-01-15T10:10:00Z"
      state_hash: "def456..."
```

### Checkpoint

A checkpoint is a snapshot of session state at a point in time:

| Checkpoint Type | Trigger | Contents |
|----------------|---------|----------|
| **Auto** | Time interval | Full state snapshot |
| **Manual** | Agent request | Full state snapshot |
| **Pre-step** | Before each step | Incremental delta |
| **Post-step** | After each step | Incremental delta |
| **Emergency** | Error/crash | Minimal critical state |

### Session Isolation

Each session operates in strict isolation:

```
┌─────────────────────────────────────────┐
│              SESSION A                  │
│  ┌─────────┐  ┌──────────┐  ┌────────┐ │
│  │ Memory  │  │ State    │  │ Tools  │ │
│  │ Private │  │ Private  │  │ Scoped │ │
│  └─────────┘  └──────────┘  └────────┘ │
├─────────────────────────────────────────┤
│              SESSION B                  │
│  ┌─────────┐  ┌──────────┐  ┌────────┐ │
│  │ Memory  │  │ State    │  │ Tools  │ │
│  │ Private │  │ Private  │  │ Scoped │ │
│  └─────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────┘
```

Isolation rules:
- Session A cannot read Session B's memory
- Session A cannot modify Session B's state
- Each session has its own working memory space
- Persistent storage is keyed by session ID

---

## Session Operations

### Create Session

```python
session = session_manager.create(
    agent_id="agent_planner",
    config={
        "checkpoint_interval": 300,
        "max_history": 1000,
        "isolation": "strict"
    }
)
print(session.id)  # "ses_abc123"
```

### Save State

```python
# Save current state to checkpoint
session.save_state({
    "current_task": "scan_target.com",
    "progress": {"subdomains": 42, "vulns": 3},
    "next_step": "nuclei_scan"
})
```

### Restore State

```python
# Restore from last checkpoint
state = session.restore_state()
print(state["current_task"])  # "scan_target.com"
print(state["progress"])      # {"subdomains": 42, "vulns": 3}
```

### List Sessions

```python
# List all active sessions
active = session_manager.list(status="active")

# List all sessions for an agent
agent_sessions = session_manager.list(agent_id="agent_planner")

# List sessions with checkpoints
 checkpointed = session_manager.list(has_checkpoints=True)
```

### Close Session

```python
# Graceful close — saves final state
session_manager.close(session.id)

# Force close — discards unsaved state
session_manager.close(session.id, force=True)
```

---

## Checkpoint Management

### Checkpoint Strategy

```yaml
checkpoint:
  auto_checkpoint: true
  interval_seconds: 300
  max_checkpoints: 10
  retention_days: 30
  compression: true
  encryption: false
```

### Checkpoint Lifecycle

```
Session Active
      │
      ▼
Checkpoint Interval Elapsed?
├── Yes → Create Auto-Checkpoint
│         Save full state
│         Update checkpoint index
│         Prune old checkpoints (keep last N)
└── No  → Continue
```

### Checkpoint Recovery

```
Session Resume Request
      │
      ▼
Find Latest Checkpoint
      │
      ▼
Validate Checkpoint Integrity
      │
   Valid?
   ├── Yes → Load state from checkpoint
   │         Restore working memory
   │         Resume execution
   └── No  → Find next-latest checkpoint
             If none → Start fresh session
```

---

## Session History

Tracking session lifecycle for debugging and analytics:

```yaml
history:
  - event: "created"
    timestamp: "2025-01-15T10:00:00Z"
  - event: "checkpoint"
    timestamp: "2025-01-15T10:05:00Z"
    checkpoint_id: "cp_001"
  - event: "task_started"
    timestamp: "2025-01-15T10:06:00Z"
    task: "nuclei_scan"
  - event: "checkpoint"
    timestamp: "2025-01-15T10:10:00Z"
    checkpoint_id: "cp_002"
  - event: "task_completed"
    timestamp: "2025-01-15T10:15:00Z"
    task: "nuclei_scan"
    result: "5 findings"
  - event: "closed"
    timestamp: "2025-01-15T10:20:00Z"
    reason: "normal"
```

---

## Session Recovery Scenarios

### Scenario 1: Process Crash

```
Agent Process Running
        │
        ▼
   Process Crashes
        │
        ▼
Runtime Detects Crash
        │
        ▼
Find Latest Checkpoint
        │
        ▼
Spawn New Process
        │
        ▼
Restore Session State
        │
        ▼
Resume From Checkpoint
```

### Scenario 2: Planned Restart

```
Restart Requested
        │
        ▼
Create Final Checkpoint
        │
        ▼
Save Session Metadata
        │
        ▼
Shutdown Current Process
        │
        ▼
Start New Process
        │
        ▼
Restore Session
        │
        ▼
Resume Operations
```

### Scenario 3: Session Migration

```
Migration Request
        │
        ▼
Export Session State
        │
        ▼
Transfer to New Host
        │
        ▼
Import Session State
        │
        ▼
Validate Integrity
        │
        ▼
Resume on New Host
```

---

## Configuration

```yaml
session:
  creation:
    auto_id: true
    id_prefix: "ses"
    default_isolation: "strict"
  persistence:
    backend: "filesystem"
    storage_path: "./brain_sessions"
    format: "json"
    compression: true
  checkpoints:
    auto_checkpoint: true
    interval_seconds: 300
    max_checkpoints: 10
    pre_step_checkpoint: false
    post_step_checkpoint: true
  recovery:
    auto_recover: true
    max_recovery_attempts: 3
    recovery_timeout: 60
  history:
    enabled: true
    max_events: 1000
    retention_days: 90
```

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | SessionState, Checkpoint types |
| `executions/` | Checkpoint execution state for recovery |
| `memory/` | Checkpoint memory state, restore working memory |
| `runtime/` | Process state for session lifecycle |
| `tools/` | Tool session state for resuming tool operations |
| `utils/` | Serialization, compression, hashing |

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
