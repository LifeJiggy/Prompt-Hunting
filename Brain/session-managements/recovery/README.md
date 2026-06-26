# State Recovery

> Recovery from checkpoints, strategies, partial recovery, validation, and testing.

## Overview

Recovery restores a session to a usable state after failure, suspension, or interruption. The recovery subsystem reads checkpoints, validates their integrity, applies recovery strategies based on the failure mode, and reconstructs session state. The `ResumeHandler` orchestrates the complete recovery process.

## Core Concepts

### ResumeHandler

The `ResumeHandler` manages session restoration from any recovery source.

```python
from session_managements import ResumeHandler

handler = ResumeHandler(config)

# Resume from latest checkpoint
session = handler.resume("ses_xyz789")

# Resume from specific checkpoint
session = handler.resume("ses_xyz789", checkpoint_id="cp_abc123")

# Resume with a specific strategy
session = handler.resume("ses_xyz789", strategy="conservative")
```

## Recovery Sources

| Source | Description | Reliability |
|--------|-------------|-------------|
| Latest checkpoint | Most recent saved state | High |
| Specific checkpoint | User-selected checkpoint by ID | High |
| Auto-checkpoint | System-created periodic snapshot | High |
| Manual checkpoint | User-created labeled snapshot | High |
| Partial state | Recovered fragments from multiple sources | Medium |
| Metadata only | Session metadata without full state | Low |

## Recovery Strategies

### Strategy Selection

The recovery strategy determines how aggressively to attempt restoration:

| Strategy | Description | Use Case |
|----------|-------------|----------|
| `latest` | Load most recent valid checkpoint | Normal resume |
| `conservative` | Load latest valid checkpoint with full validation | Critical sessions |
| `aggressive` | Attempt partial recovery from any available state | Data loss prevention |
| `manual` | User selects specific checkpoint | Troubleshooting |

### Latest Strategy

Default recovery strategy. Loads the most recent valid checkpoint.

**Process:**
1. Query checkpoint index for latest checkpoint
2. Validate checkpoint integrity
3. Load state from validated checkpoint
4. Reconstruct session context
5. Resume active operations

**Behavior:**
- Skips invalid checkpoints automatically
- Falls back to previous valid checkpoint on failure
- Logs all skipped checkpoints for audit

### Conservative Strategy

Full validation before any state restoration.

**Process:**
1. Load latest valid checkpoint
2. Run full validation suite (checksum, schema, dependencies)
3. Verify all subagent states can be restored
4. Confirm task tree integrity
5. Validate memory consistency
6. Only proceed if all checks pass

**Use case:** Sessions with critical state that cannot tolerate corruption.

### Aggressive Strategy

Attempts maximum recovery from any available state.

**Process:**
1. Scan all checkpoints for session
2. Attempt to load each, starting from newest
3. Merge state from multiple checkpoints if partial data found
4. Reconstruct missing state from metadata and logs
5. Mark recovery as partial if full state unavailable
6. Return recovered state with warnings

**Use case:** After storage failures, corruption events, or emergency recovery.

### Manual Strategy

User specifies which checkpoint to restore from.

**Process:**
1. Accept checkpoint ID from user
2. Validate specified checkpoint
3. Load and restore from that specific point
4. User confirms recovery success

**Use case:** When you know exactly which state you want to restore.

## Partial Recovery

When full recovery is impossible, the system attempts partial recovery.

### Partial Recovery Sources

| Fragment | Recovery Chance | Notes |
|----------|----------------|-------|
| Conversation history | High | Messages are append-only |
| Task tree | Medium | May miss in-flight tasks |
| Active task state | Low | Requires recent checkpoint |
| Memory entries | Medium | May be incomplete |
| Metadata | High | Always persisted early |

### Partial Recovery Process

```
1. Identify which state components are available
2. Load each available component independently
3. Attempt to reconstruct missing components:
   a. From metadata hints
   b. From checkpoint dependency chains
   c. From log files
4. Merge available state into a coherent session
5. Mark session as partially recovered
6. Log all missing components and recovery gaps
```

### Partial Recovery Limitations

- Active subagent state cannot be partially recovered (binary state)
- In-flight tool outputs may be lost
- Context window reconstruction may be incomplete
- Memory entries beyond the checkpoint may be unavailable

## Recovery Validation

After recovery, the system validates the restored state.

### Validation Steps

| Step | Check | Action on Failure |
|------|-------|-------------------|
| 1 | Checksum integrity | Skip to previous checkpoint |
| 2 | Schema conformance | Log warning, proceed |
| 3 | Task tree consistency | Mark inconsistent tasks as blocked |
| 4 | Conversation continuity | Mark gap in history |
| 5 | Memory availability | Note missing memory entries |
| 6 | Subagent status | Mark stale subagents as failed |
| 7 | Resource availability | Release unavailable resources |

### Recovery Health Score

Each recovery produces a health score from 0 to 100:

| Score | Meaning |
|-------|---------|
| 90-100 | Full recovery, all state intact |
| 70-89 | Minor gaps, session fully functional |
| 50-69 | Partial recovery, some features degraded |
| 30-49 | Significant loss, core state intact |
| 0-29 | Critical loss, session may need restart |

### Health Score Calculation

```
health_score = (
    conversation_completeness * 0.3 +
    task_tree_integrity * 0.25 +
    memory_availability * 0.2 +
    metadata_completeness * 0.15 +
    subagent_status * 0.1
) * 100
```

## Recovery Testing

Recovery testing validates that the recovery system works correctly.

### Test Scenarios

| Scenario | Expected Outcome |
|----------|------------------|
| Clean checkpoint load | Full recovery, score 100 |
| Corrupted checkpoint | Skip to previous valid checkpoint |
| Missing checkpoint | Partial recovery from available state |
| Stale checkpoint | Recovery with age warning |
| Corrupted metadata | Recovery with metadata reconstructed |
| Storage unavailable | Retry with backoff, then fail gracefully |

### Running Recovery Tests

```python
from session_managements import RecoveryTestSuite

suite = RecoveryTestSuite()

# Run all recovery tests
results = suite.run_all()

# Run specific test scenario
result = suite.run("corrupted_checkpoint")

# Generate recovery test report
report = suite.report()
```

### Chaos Testing

For production validation, chaos testing simulates failures:

```python
suite.chaos_test(
    session_id="ses_test",
    failure_modes=["checkpoint_corruption", "storage_dropout", "partial_write"],
    iterations=100,
    success_threshold=0.95  # 95% recovery success rate
)
```

## Recovery Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `strategy` | `latest` | Default recovery strategy |
| `validation_level` | `full` | Validation depth (`full`, `quick`, `none`) |
| `max_recovery_attempts` | 3 | Retry count for failed recovery |
| `recovery_timeout` | 60s | Maximum time for recovery |
| `partial_recovery_enabled` | true | Allow partial state recovery |
| `health_threshold` | 50 | Minimum health score to proceed |
| `fallback_strategy` | `conservative` | Strategy if primary fails |

## Error Handling

| Error | Recovery |
|-------|----------|
| `NoValidCheckpointError` | Attempt partial recovery, then create fresh session |
| `RecoveryTimeoutError` | Retry with backoff, then fail with diagnostic |
| `StateCorruptionError` | Try previous checkpoint, log corruption details |
| `DependencyChainBrokenError` | Skip broken branch, recover from alternative |
| `PartialRecoveryIncompleteError` | Return partial state with health score |
| `StorageAccessError` | Retry with exponential backoff |

## Recovery Events

| Event | Description |
|-------|-------------|
| `recovery.started` | Recovery process initiated |
| `recovery.checkpoint_loaded` | Checkpoint loaded successfully |
| `recovery.checkpoint_skipped` | Invalid checkpoint skipped |
| `recovery.partial` | Partial recovery in progress |
| `recovery.completed` | Recovery finished successfully |
| `recovery.failed` | Recovery failed after all attempts |
| `recovery.health_report` | Health score calculated |
