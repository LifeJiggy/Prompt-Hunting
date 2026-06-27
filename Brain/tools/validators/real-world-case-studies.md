# Tool Validators: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Overview

Input validators for disclosed report analysis ensure valid pattern extraction, technique cataloging, and hunt prompt generation inputs.

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
    min_confidence: { type: "number", min: 0.0, max: 1.0, default: 0.6 }
    include_bypass: { type: "boolean", default: true }

hunt_prompt_generator:
  input:
    pattern_id: { type: "string", required: true }
    target_type: { type: "string", enum: ["web", "api", "mobile", "cloud"], required: true }
    format: { type: "string", enum: ["structured", "narrative", "checklist"], default: "structured" }
```

## Domain File References

All 50 files in `Real-World-Case-Studies/` have validation schemas for disclosed analysis inputs.
