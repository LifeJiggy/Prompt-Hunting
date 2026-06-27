# Tool Validators: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Overview

Input validators for reconnaissance tools ensure valid targets, enumeration parameters, and rate limit configurations.

## Validation Schemas

```yaml
subdomain_enum:
  input:
    domain: { type: "string", pattern: "^[a-z0-9.-]+\\.[a-z]{2,}$", required: true }
    sources: { type: "array", items: { type: "string" }, optional: true }
    brute_force: { type: "boolean", default: false }
    wordlist: { type: "string", optional: true }

http_probe:
  input:
    targets: { type: "array", items: { type: "string" }, minItems: 1, maxItems: 100000 }
    threads: { type: "integer", min: 1, max: 200, default: 50 }
    follow_redirects: { type: "boolean", default: true }
    timeout: { type: "integer", min: 1, max: 60, default: 10 }

port_scan:
  input:
    targets: { type: "array", items: { type: "string" }, minItems: 1 }
    ports: { type: "string", default: "top-1000" }
    rate: { type: "integer", min: 1, max: 10000, default: 1000 }

js_analysis:
  input:
    urls: { type: "array", items: { type: "string", format: "url" }, minItems: 1 }
    extract_endpoints: { type: "boolean", default: true }
    extract_secrets: { type: "boolean", default: true }
```

## Domain File References

All 50 files in `Reconnaissance-Deep-Dive/` have validation schemas for their recon tool inputs.
