# Tool Validators: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Overview

Input validators for support tools ensure that framework loading, methodology selection, and template application receive valid inputs.

## Validation Schemas

```yaml
framework_loader:
  input:
    framework_id: { type: "string", pattern: "^[a-z_-]+$", required: true }
    version: { type: "string", optional: true }

methodology_selector:
  input:
    vuln_class: { type: "string", enum: ["xss", "sqli", "ssrf", "csrf", "idor", "rce", "xxe", "ssti", "auth", "logic"], required: true }
    target_type: { type: "string", enum: ["web", "api", "mobile", "cloud"], required: true }

template_applier:
  input:
    template_id: { type: "string", required: true }
    platform: { type: "string", enum: ["hackerone", "bugcrowd", "intigriti"], required: true }
    vuln_class: { type: "string", required: true }
```

## Custom Validators

```python
@validator("scope_analyzer")
def validate_scope_input(value):
    errors = []
    if not value.get("scope_text"):
        errors.append("scope_text is required")
    if value.get("scope_text") and len(value["scope_text"]) > 10000:
        errors.append("scope_text exceeds maximum length")
    return errors
```

## Domain File References

All 23 files in `bug-bounty-support/` have matching validation schemas.
