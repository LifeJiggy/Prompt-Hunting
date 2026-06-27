# Validation: Automation-Efficiency

**Domain Mapping:** `Automation-Efficiency/`

## Overview

Schema validation for optimization tools ensures pipeline configurations, cache settings, and parallelization parameters are valid.

## Validation Schemas

```yaml
cache_config:
  input:
    backend: { type: "string", enum: ["memory", "redis", "filesystem"], required: true }
    ttl: { type: "integer", min: 60, max: 86400, default: 3600 }
    max_entries: { type: "integer", min: 100, max: 100000, default: 10000 }
    eviction: { type: "string", enum: ["lru", "lfu", "fifo"], default: "lru" }

parallel_config:
  input:
    max_workers: { type: "integer", min: 1, max: 100, default: 10 }
    queue_size: { type: "integer", min: 100, max: 10000, default: 1000 }
    load_balancing: { type: "string", enum: ["round_robin", "least_loaded", "random"], default: "least_loaded" }
```

## Domain File References

All 50 files in `Automation-Efficiency/` have validation schemas for optimization configurations.
