# Validation: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Overview

Schema validation for case study analysis ensures case selection, MITRE mapping, and pattern extraction inputs are valid.

## Validation Schemas

```yaml
case_selector:
  input:
    case_id: { type: "string", pattern: "^case_\\d+$", required: true }
    category: { type: "string", optional: true }
    min_severity: { type: "string", enum: ["info", "low", "medium", "high", "critical"], default: "high" }

mitre_mapper:
  input:
    ttps: { type: "array", items: { type: "string", pattern: "^T\\d{4}$" }, minItems: 1 }
    case_id: { type: "string", required: true }
    mitre_version: { type: "string", default: "14.1" }

pattern_extractor:
  input:
    case_id: { type: "string", required: true }
    min_confidence: { type: "number", min: 0, max: 1, default: 0.6 }
    depth: { type: "string", enum: ["shallow", "deep", "comprehensive"], default: "deep" }
```

## Domain File References

All 46 files in `High-Level-World-Case-Studies/` have validation schemas for analysis inputs.
