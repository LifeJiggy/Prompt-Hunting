# Validation: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Overview

Schema validation for disclosed report analysis ensures pattern extraction, technique cataloging, and hunt prompt generation inputs are valid.

## Validation Schemas

```yaml
report_analyzer:
  input:
    case_id: { type: "string", pattern: "^\\d{2}$", required: true }
    vuln_class: { type: "string", required: true }
    platform: { type: "string", enum: ["hackerone", "bugcrowd", "intigriti", "other"] }

pattern_generator:
  input:
    case_id: { type: "string", required: true }
    technique: { type: "string", required: true }
    min_confidence: { type: "number", min: 0, max: 1, default: 0.6 }
    include_bypass: { type: "boolean", default: true }
```

## Domain File References

All 50 files in `Real-World-Case-Studies/` have validation schemas for disclosed analysis inputs.
