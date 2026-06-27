# State Persistence: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Overview

State persistence for specialized target testing stores category-specific assessment state — detected category, loaded methodology, deployed tools, testing progress, findings, and compliance mapping.

## Persistence Schema

```yaml
specialized_persistence:
  session_id: "sses_{uuid}"
  target_id: "tgt_{uuid}"
  storage_format: "json"
  storage_path: "./brain_sessions/specialized_{session_id}.json"

  state:
    category: "iot"
    methodology: "method_iot_01"
    tools_deployed: ["binwalk", "jtag", "uart"]
    current_phase: "firmware_analysis"
    tests_run: 15
    findings: { critical: 1, high: 2, medium: 3, low: 1, info: 0 }
    compliance: { frameworks: [], mapped: [], gaps: [] }

  triggers:
    - event: "category_detected"
      action: "save_checkpoint"
    - event: "finding_discovered"
      action: "save_incremental"
    - event: "phase_completed"
      action: "save_checkpoint"
```

## Operations

```python
def save_specialized_state(persistence, session):
    persistence.write(session.storage_path, session.state, format="json")

def restore_specialized_state(persistence, session_id):
    path = f"./brain_sessions/specialized_{session_id}.json"
    return persistence.read(path, format="json")
```

## Domain File References

All 50 files in `Specialized-Targets/` persist category-specific assessment state across IoT, mobile, cloud, blockchain, finance, healthcare, enterprise, education, e-commerce, industrial, emerging tech, and institutional categories.
