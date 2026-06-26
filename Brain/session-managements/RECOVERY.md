# Session Recovery Reference

> Complete reference for all recovery scenarios, commands, configuration, and troubleshooting.

## Recovery Scenarios

### Scenario 1: Normal Resume

**Trigger:** Session was suspended intentionally and is being resumed.

**Process:**
1. Locate session by ID in session store
2. Verify session state is `suspended`
3. Load latest checkpoint
4. Validate checkpoint integrity
5. Restore session state
6. Reconnect resources (file handles, caches)
7. Transition state to `active`

**Expected health score:** 95-100

**Command:**
```bash
session recover ses_xyz789 --strategy latest
```

### Scenario 2: Crash Recovery

**Trigger:** Process terminated unexpectedly during an active session.

**Process:**
1. Detect incomplete session (state is `active` but process is gone)
2. Scan for available checkpoints
3. Load most recent valid checkpoint
4. Reconcile any partial writes
5. Mark in-flight subagents as failed
6. Resume session from checkpoint

**Expected health score:** 80-95

**Command:**
```bash
session recover ses_xyz789 --strategy latest --force
```

### Scenario 3: Storage Failure

**Trigger:** Storage backend became unavailable or corrupted.

**Process:**
1. Detect storage access failure
2. Attempt recovery from backup storage (if configured)
3. Try alternative backends (filesystem → database → memory)
4. If no storage available, create session from metadata only
5. Log all recovery attempts and failures

**Expected health score:** 50-80

**Command:**
```bash
session recover ses_xyz789 --strategy aggressive --fallback-backend memory
```

### Scenario 4: Checkpoint Corruption

**Trigger:** Latest checkpoint file is corrupted or unreadable.

**Process:**
1. Attempt to load latest checkpoint
2. Detect checksum mismatch or parse error
3. Skip corrupted checkpoint
4. Attempt load from previous valid checkpoint
5. If no valid checkpoints, attempt partial recovery
6. Log corruption details for investigation

**Expected health score:** 85-100 (from previous valid checkpoint)

**Command:**
```bash
session recover ses_xyz789 --strategy conservative
```

### Scenario 5: Partial Recovery

**Trigger:** Only fragments of session state are available.

**Process:**
1. Inventory available state components
2. Load each available component
3. Reconstruct missing components from hints
4. Merge into coherent session state
5. Calculate health score
6. If health score < threshold, prompt for fresh session

**Expected health score:** 30-70

**Command:**
```bash
session recover ses_xyz789 --strategy aggressive --partial-ok
```

### Scenario 6: Cross-Machine Recovery

**Trigger:** Session needs to resume on a different machine.

**Process:**
1. Export session state from source machine
2. Transfer state file to target machine
3. Import into local session store
4. Validate checkpoint on target
5. Adjust resource paths for target environment
6. Resume session

**Command:**
```bash
# Export
session export ses_xyz789 --output ses_transfer.json

# Import
session import ses_transfer.json

# Recover
session recover ses_xyz789 --strategy latest
```

## Recovery Commands

### `session recover`

Main recovery command. Restores a session from checkpoint.

**Syntax:**
```bash
session recover <session_id> [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--strategy <strategy>` | Recovery strategy: `latest`, `conservative`, `aggressive`, `manual` |
| `--checkpoint <cp_id>` | Specific checkpoint to recover from |
| `--force` | Skip safety checks |
| `--partial-ok` | Allow partial recovery |
| `--health-threshold <N>` | Minimum health score (default: 50) |
| `--dry-run` | Show what recovery would do without executing |
| `--verbose` | Detailed recovery output |

### `session export`

Exports session state to a portable file.

**Syntax:**
```bash
session export <session_id> --output <file>
```

### `session import`

Imports session state from a file.

**Syntax:**
```bash
session import <file>
```

### `session verify`

Verifies checkpoint integrity without recovery.

**Syntax:**
```bash
session verify <session_id> [--checkpoint <cp_id>]
```

### `session health`

Shows health status of stored sessions.

**Syntax:**
```bash
session health [--session <session_id>] [--all]
```

### `session repair`

Attempts to repair corrupted or inconsistent state.

**Syntax:**
```bash
session repair <session_id> [--fix] [--verbose]
```

## Recovery Configuration

### Configuration File

Recovery behavior is configured in `session_config.yaml`:

```yaml
recovery:
  strategy: latest
  validation:
    level: full          # full | quick | none
    checksum: true
    schema: true
    dependencies: true
  timeout: 60s
  retries:
    max_attempts: 3
    backoff: exponential
    initial_delay: 1s
    max_delay: 30s
  partial_recovery:
    enabled: true
    health_threshold: 50
  fallback:
    strategy: conservative
    backend: memory
  chaos_testing:
    enabled: false
    failure_modes: [checkpoint_corruption, storage_dropout]
    iterations: 100
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `SESSION_RECOVERY_STRATEGY` | Default recovery strategy |
| `SESSION_RECOVERY_TIMEOUT` | Recovery timeout in seconds |
| `SESSION_RECOVERY_RETRIES` | Maximum retry attempts |
| `SESSION_CHECKPOINT_DIR` | Checkpoint storage directory |
| `SESSION_VALIDATION_LEVEL` | Validation depth |

## Troubleshooting Recovery Failures

### Checksum Mismatch

**Symptom:** `StateCorruptionError: Checksum mismatch for checkpoint cp_abc123`

**Causes:**
- Disk corruption during write
- Concurrent writes to same checkpoint
- Storage hardware failure

**Resolution:**
```bash
# Check disk health
session verify ses_xyz789 --verbose

# Attempt recovery from previous checkpoint
session recover ses_xyz789 --strategy conservative

# If all checkpoints corrupt, attempt partial recovery
session recover ses_xyz789 --strategy aggressive --partial-ok
```

### Missing Checkpoint Dependencies

**Symptom:** `DependencyChainBrokenError: Parent checkpoint cp_abc122 not found`

**Causes:**
- Checkpoint pruned while dependency still referenced
- Storage migration incomplete
- Manual file deletion

**Resolution:**
```bash
# Check available checkpoints
session health --session ses_xyz789

# Recover from available checkpoint (skip broken chain)
session recover ses_xyz789 --checkpoint cp_abc124

# If no valid chain, use aggressive strategy
session recover ses_xyz789 --strategy aggressive
```

### Storage Unavailable

**Symptom:** `StorageAccessError: Cannot connect to storage backend`

**Causes:**
- Network connectivity issue
- Storage service down
- Authentication expired
- Disk full

**Resolution:**
```bash
# Check storage connectivity
session health --session ses_xyz789

# Try alternative backend
session recover ses_xyz789 --fallback-backend memory

# Export from last known good state
session export ses_xyz789 --output recovery_export.json
```

### Recovery Timeout

**Symptom:** `RecoveryTimeoutError: Recovery exceeded 60s timeout`

**Causes:**
- Very large session state
- Slow storage backend
- Network latency
- Too many checkpoints to scan

**Resolution:**
```bash
# Increase timeout
session recover ses_xyz789 --timeout 300s

# Use specific checkpoint (skip scanning)
session recover ses_xyz789 --checkpoint cp_abc123

# Quick validation (skip full validation)
session recover ses_xyz789 --validation-level quick
```

### Partial Recovery Below Threshold

**Symptom:** `PartialRecoveryError: Health score 35 below threshold 50`

**Causes:**
- Most checkpoints corrupted or missing
- Large time gap between available checkpoints
- Critical state components not persisted

**Resolution:**
```bash
# Lower threshold (accept degraded session)
session recover ses_xyz789 --health-threshold 30

# Create fresh session and import what's available
session create --name recovery-from-failure
session import recovery_fragments.json
```

### Schema Validation Failure

**Symptom:** `ValidationError: State does not match expected schema v3`

**Causes:**
- Session state was written by older version
- Schema migration incomplete
- Manual state modification

**Resolution:**
```bash
# Try with older schema version
session recover ses_xyz789 --schema-version 2

# Repair schema
session repair ses_xyz789 --fix --verbose

# Manual recovery with schema skip
session recover ses_xyz789 --validation-level quick
```

## Recovery Monitoring

### Metrics

| Metric | Description |
|--------|-------------|
| `recovery.attempts_total` | Total recovery attempts |
| `recovery.success_total` | Successful recoveries |
| `recovery.failure_total` | Failed recoveries |
| `recovery.duration_seconds` | Recovery duration |
| `recovery.health_score` | Recovery health score |
| `recovery.checkpoints_scanned` | Checkpoints evaluated |

### Health Dashboard

```bash
# View all session health
session health --all

# View specific session details
session health --session ses_xyz789 --verbose

# Export health report
session health --all --output health_report.json
```

## Best Practices

1. **Always enable auto-checkpointing** for sessions longer than 5 minutes
2. **Use conservative strategy** for sessions with critical state
3. **Test recovery periodically** with chaos testing
4. **Monitor checkpoint health** with regular `session health` checks
5. **Keep backup exports** for high-value sessions
6. **Set appropriate health thresholds** based on session criticality
7. **Log all recovery attempts** for audit and debugging
