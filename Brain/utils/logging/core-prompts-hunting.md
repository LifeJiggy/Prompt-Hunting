# Logging: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Overview

Hunting-focused logging captures test execution, finding discovery, bypass attempts, and exploitation results across 50 vulnerability classes.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "hunt_engine"
  domain: "core-hunting"
  message: "Vulnerability confirmed"
  data:
    vuln_class: "xss_stored"
    endpoint: "/profile"
    severity: "high"
    tool: "burp_suite"
    bypass_used: false
    exploitation_method: "session_hijack"
```

## Domain File References

Logging applies to all 50 files in `Core-Prompts-hunting/` — each vulnerability class test is logged with results.
