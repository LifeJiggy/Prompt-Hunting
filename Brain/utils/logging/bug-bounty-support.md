# Logging: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Overview

Reference-focused logging tracks framework loads, methodology applications, and template usage.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "support_loader"
  domain: "bug-bounty-support"
  message: "Framework loaded"
  data:
    framework_id: "advanced_hunting"
    version: "2.1"
    load_time_ms: 150
```

## Domain File References

Logging applies to all 23 files in `bug-bounty-support/` — framework loads, methodology selections, and template applications are logged.
