# Logging: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Overview

Asset-focused logging tracks subdomain discovery, live host verification, technology fingerprinting, and cloud resource enumeration.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "recon_engine"
  domain: "recon-deep-dive"
  message: "Assets discovered"
  data:
    source: "crt.sh"
    domain: "target.com"
    assets_found: 245
    new_assets: 38
    duration_ms: 12000
```

## Domain File References

Logging applies to all 50 files in `Reconnaissance-Deep-Dive/` — each enumeration source and discovery method is logged.
