# Checkpoint Management

> Auto-checkpoints, manual checkpoints, pruning, validation, and format specification.

## Overview

Checkpoints are timed snapshots of session state created during active sessions. They enable recovery from failures, support session resumption after suspension, and provide an audit trail of session progress. The `CheckpointManager` orchestrates checkpoint creation, validation, pruning, and lifecycle management.

## Core Concepts

### CheckpointManager

The `CheckpointManager` handles all checkpoint operations for a session.

```python
from session_managements import CheckpointManager

cpm = CheckpointManager(session_id, config)

# Create a manual checkpoint
checkpoint = cpm.create(label="after-recon-phase")

# List checkpoints
checkpoints = cpm.list()

# Load a specific checkpoint
state = cpm.load(checkpoint.id)

# Prune old checkpoints
cpm.prune(keep_latest=10)
```

## Auto-Checkpoints

Auto-checkpoints are created automatically at configured intervals or state-change thresholds.

### Time-Based Auto-Checkpoint

```python
cpm = CheckpointManager(
    session_id,
    auto_checkpoint_interval=300  # Every 5 minutes
)
```

**Trigger conditions:**
- Time elapsed since last checkpoint exceeds `auto_checkpoint_interval`
- Session state has changed since last checkpoint
- No checkpoint is currently in progress (prevents overlap)

### Event-Based Auto-Checkpoint

Auto-checkpoints can also trigger on specific events:

| Event | Description |
|-------|-------------|
| `task.completed` | A task finished |
| `task.failed` | A task encountered an error |
| `phase.transition` | Workflow phase changed |
| `message.threshold` | Message count reached N |
| `context.overflow` | Context window exceeded limit |

### Auto-Checkpoint Lifecycle

```
1. Event triggers checkpoint
2. Serialize current session state
3. Compute checksum
4. Write to storage backend
5. Update checkpoint index
6. Verify write integrity
7. Emit checkpoint.created event
8. Update last_checkpoint_time
```

### Adaptive Intervals

The checkpoint manager can adjust intervals based on session activity:

- **High activity** (rapid message exchange): Checkpoint more frequently
- **Low activity** (idle sessions): Checkpoint less frequently
- **Error-prone sessions** (recent failures): Checkpoint more frequently

Configuration:
```python
cpm = CheckpointManager(
    session_id,
    adaptive_checkpoint=True,
    min_interval=60,    # Never faster than 1 minute
    max_interval=1800   # Never slower than 30 minutes
)
```

## Manual Checkpoints

Manual checkpoints allow explicit state capture at user-defined points.

### Creating Manual Checkpoints

```python
checkpoint = cpm.create(
    label="pre-deployment",
    metadata={"reason": "About to run deployment workflow"},
    prune_policy="keep"
)
```

**Parameters:**
- `label` (str): Human-readable description
- `metadata` (dict): Additional context about the checkpoint
- `prune_policy` (str): `keep` (never prune), `normal` (standard pruning), `first` (keep as base)

### Checkpoint Labels

Labels help identify checkpoints during recovery:

| Label Pattern | Use Case |
|---------------|----------|
| `phase:<name>` | Workflow phase transitions |
| `pre-<action>` | Before significant operations |
| `post-<action>` | After significant operations |
| `milestone:<name>` | Project milestones |
| `manual` | Generic manual checkpoint |

## Checkpoint Pruning

Pruning removes old checkpoints to manage storage usage while maintaining recovery capability.

### Pruning Policies

| Policy | Behavior |
|--------|----------|
| `keep_latest:N` | Keep N most recent checkpoints |
| `keep_hours:H` | Keep checkpoints from last H hours |
| `keep_size:S` | Keep checkpoints totaling S bytes |
| `keep_if(label)` | Keep checkpoints matching label pattern |

### Pruning Execution

```python
# Keep latest 10 checkpoints
cpm.prune(keep_latest=10)

# Keep last 24 hours of checkpoints
cpm.prune(keep_hours=24)

# Keep checkpoints labeled "milestone:*" always
cpm.prune(keep_latest=10, protect=["milestone:*"])

# Dry run — show what would be pruned
cpm.prune(keep_latest=10, dry_run=True)
```

### Protected Checkpoints

Checkpoints can be marked as protected to prevent pruning:

```python
# Mark checkpoint as protected
cpm.protect(checkpoint.id)

# Unprotect
cpm.unprotect(checkpoint.id)
```

**Auto-protection rules:**
- First checkpoint of a session (base state)
- Checkpoints with `prune_policy="keep"`
- Checkpoints created during error recovery
- Most recent checkpoint before suspension

### Pruning Schedule

Pruning runs automatically:
- After each new checkpoint creation (if enabled)
- On session resume
- On explicit `prune()` call
- Periodically via background task (configurable)

## Checkpoint Validation

Every checkpoint undergoes validation before it is used for recovery.

### Validation Checks

| Check | Description | Severity |
|-------|-------------|----------|
| `checksum` | SHA-256 matches serialized content | Critical |
| `schema` | State conforms to expected schema | Critical |
| `completeness` | Required fields are present | Critical |
| `dependencies` | Referenced parent checkpoints exist | High |
| `freshness` | Checkpoint age is within acceptable range | Medium |
| `size` | State size is within configured limits | Low |

### Validation Process

```
1. Load checkpoint bytes from storage
2. Verify file is not truncated (size check)
3. Parse serialized content
4. Validate against schema
5. Compute and compare checksum
6. Check dependency chain integrity
7. Record validation result
8. Mark checkpoint as valid or invalid
```

### Handling Invalid Checkpoints

| Scenario | Action |
|----------|--------|
| Checksum mismatch | Mark invalid, attempt load from previous checkpoint |
| Schema violation | Mark invalid, log details, skip during recovery |
| Missing dependencies | Attempt to repair chain, or mark dependent checkpoints invalid |
| Parse error | Mark invalid, log corruption details |

## Checkpoint Format

### Standard Checkpoint Structure

```json
{
  "checkpoint_id": "cp_abc123def456",
  "session_id": "ses_xyz789",
  "version": 1,
  "created_at": "2026-06-26T14:30:00Z",
  "label": "post-recon",
  "metadata": {
    "reason": "Recon phase completed",
    "subagent_count": 3
  },
  "state": {
    "conversation": [...],
    "tasks": {...},
    "context": {...},
    "memory": {...}
  },
  "checksum": "sha256:abcdef1234567890...",
  "size_bytes": 1048576,
  "parent_checkpoint": "cp_abc123def455",
  "prune_policy": "normal"
}
```

### Checkpoint ID Format

Format: `cp_<32-char-hex>`

- 128-bit random identifier
- Collision probability: < 2^-60 for 1 billion checkpoints
- Immutable once assigned

### State Serialization

The `state` field contains the complete session state at checkpoint time:

| Component | Contents |
|-----------|----------|
| `conversation` | Full message history |
| `tasks` | Task tree with all states |
| `context` | Active context window |
| `memory` | Session-scoped memory entries |
| `metadata` | Session metadata snapshot |

All components are optional depending on session configuration and state size.

## Checkpoint Events

| Event | Description |
|-------|-------------|
| `checkpoint.created` | New checkpoint written |
| `checkpoint.validated` | Checkpoint passed validation |
| `checkpoint.invalid` | Checkpoint failed validation |
| `checkpoint.pruned` | Checkpoint removed by pruning |
| `checkpoint.loaded` | Checkpoint loaded for recovery |
| `checkpoint.protected` | Checkpoint marked as protected |
| `checkpoint.unprotected` | Checkpoint protection removed |

## Configuration Reference

| Parameter | Default | Description |
|-----------|---------|-------------|
| `auto_checkpoint` | true | Enable auto-checkpoints |
| `auto_checkpoint_interval` | 300s | Time between auto-checkpoints |
| `adaptive_checkpoint` | false | Enable adaptive intervals |
| `min_interval` | 60s | Minimum checkpoint interval |
| `max_interval` | 1800s | Maximum checkpoint interval |
| `max_checkpoints` | 50 | Maximum checkpoints per session |
| `validate_on_create` | true | Validate immediately after creation |
| `validate_on_load` | true | Validate before loading |
| `prune_on_create` | true | Run pruning after new checkpoint |
| `compression` | none | Compression algorithm for checkpoints |
