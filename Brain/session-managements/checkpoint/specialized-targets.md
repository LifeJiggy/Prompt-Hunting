# Checkpoint: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Overview

Checkpoint management for specialized target testing saves category-specific assessment state at phase boundaries. Checkpoints enable resumption of interrupted testing sessions without losing discovered findings or methodology progress.

## Checkpoint Schema

```yaml
specialized_checkpoint:
  checkpoint_id: "ckpt_{uuid}"
  session_id: "sses_{uuid}"
  timestamp: "2025-01-15T11:30:00Z"
  trigger: "phase_completed"

  # Checkpointed State
  state:
    category: "iot"
    phase_completed: "firmware_analysis"
    findings_snapshot: { critical: 1, high: 2, medium: 3 }
    tools_status: { binwalk: "idle", jtag: "idle" }
    tests_completed: 15
    tests_pending: 25

  # Checkpoint Metadata
  metadata:
    size_bytes: 45000
    compressed: true
    checksum: "sha256:abc123..."
```

## Auto-Checkpoint Rules

| Trigger | Condition | Action |
|---------|-----------|--------|
| Phase complete | Testing phase finishes | Auto checkpoint |
| Finding discovered | New finding found | Incremental save |
| Time interval | Every 5 minutes | Periodic checkpoint |
| Resource threshold | Memory > 80% | Emergency checkpoint |

## Checkpoint Validation

```python
def validate_specialized_checkpoint(checkpoint):
    """Validate specialized checkpoint integrity."""
    errors = []
    if not checkpoint.state.get("category"):
        errors.append("Missing category")
    if not checkpoint.state.get("phase_completed"):
        errors.append("No completed phase")
    if checkpoint.metadata.get("checksum"):
        if not verify_checksum(checkpoint):
            errors.append("Checksum mismatch")
    return len(errors) == 0
```

## Domain File References

All 50 files in `Specialized-Targets/` have checkpoints at phase boundaries:
- IoT (01, 23-32): Firmware, network, cloud, mobile app phase checkpoints
- Mobile (02): App analysis, API testing phase checkpoints
- Cloud (03-05): IAM, storage, container phase checkpoints
- Blockchain (06-10): Contract audit, protocol testing phase checkpoints
- All other categories: Methodology-specific phase checkpoints
