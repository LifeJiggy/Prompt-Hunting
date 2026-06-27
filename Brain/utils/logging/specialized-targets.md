# Logging: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Overview

Category-focused logging tracks target categorization, methodology loading, tool deployment, and category-specific test results.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "specialized_engine"
  domain: "specialized-targets"
  message: "Category test completed"
  data:
    category: "iot"
    target: "smart_camera_01"
    tools_used: ["binwalk", "jtag"]
    findings: { critical: 1, high: 2 }
    duration_s: 3600
```

## Domain File References

Logging applies to all 50 files in `Specialized-Targets/` — category detection, tool deployment, and test outcomes are logged.
