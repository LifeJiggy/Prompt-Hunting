# Tool Validators: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Overview

Input validators for case study analysis tools ensure valid case selection, MITRE mapping, and pattern extraction inputs.

## Validation Schemas

```yaml
case_selector:
  input:
    case_id: { type: "string", pattern: "^case_\\d+$", required: true }
    category: { type: "string", optional: true }
    target_similarity: { type: "number", min: 0.0, max: 1.0, optional: true }

mitre_mapper:
  input:
    ttps: { type: "array", items: { type: "string", pattern: "^T\\d{4}$" }, minItems: 1 }
    case_id: { type: "string", required: true }

pattern_extractor:
  input:
    case_id: { type: "string", required: true }
    extraction_depth: { type: "string", enum: ["shallow", "deep", "comprehensive"], default: "deep" }
    min_confidence: { type: "number", min: 0.0, max: 1.0, default: 0.6 }
```

## Domain File References

All 46 files in `High-Level-World-Case-Studies/` have validation schemas for case analysis inputs.
