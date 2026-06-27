# Tool Validators: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Overview

Input validators for report writing tools ensure valid report content, severity assessments, and submission parameters.

## Validation Schemas

```yaml
report_validator:
  input:
    title: { type: "string", minLength: 10, maxLength: 80, required: true }
    summary: { type: "string", minLength: 20, maxLength: 500, required: true }
    severity: { type: "string", enum: ["info", "low", "medium", "high", "critical"], required: true }
    description: { type: "string", minLength: 50, required: true }
    impact: { type: "string", minLength: 20, required: true }
    steps: { type: "array", items: { type: "string" }, minItems: 1, required: true }
    remediation: { type: "string", minLength: 20, required: true }

cvss_validator:
  input:
    vector: { type: "string", pattern: "^AV:[NALP]/AC:[LH]/PR:[NLH]/UI:[NR]/S:[UC]/C:[NLH]/I:[NLH]/A:[NLH]$", required: true }
    score: { type: "number", min: 0.0, max: 10.0 }

submission_validator:
  input:
    platform: { type: "string", enum: ["hackerone", "bugcrowd", "intigriti", "immunefi"], required: true }
    program_id: { type: "string", required: true }
    report_id: { type: "string", required: true }
    attachments: { type: "array", maxItems: 20 }
```

## Domain File References

All 54 files in `Report-Writing-Mastery/` have validation schemas for report content validation.
