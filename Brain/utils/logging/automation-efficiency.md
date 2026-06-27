# Logging: Automation-Efficiency

**Domain Mapping:** `Automation-Efficiency/`

## Overview

Metrics-focused logging for optimization tracks cache hits, deduplication, parallelization, and resource savings.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "efficiency_monitor"
  domain: "automation-efficiency"
  message: "Cache hit recorded"
  data:
    cache_key: "nuclei_target.com"
    hit_rate: 0.85
    saved_time_ms: 45000
    source: "memory_cache"
```

## Domain File References

Logging applies to all 50 files in `Automation-Efficiency/` — optimization metrics, cache performance, and efficiency gains are logged for analysis.
