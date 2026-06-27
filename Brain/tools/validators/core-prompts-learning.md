# Tool Validators: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Overview

Input validators for learning tools ensure that assessment answers, module selections, and progress updates are valid.

## Validation Schemas

```yaml
module_selector:
  input:
    module_id: { type: "integer", min: 1, max: 50, required: true }
    difficulty: { type: "string", enum: ["beginner", "intermediate", "advanced", "expert"] }

assessment_submitter:
  input:
    module_id: { type: "integer", min: 1, max: 50, required: true }
    answers: { type: "array", items: { type: "object" }, minItems: 1, maxItems: 20 }
    time_taken_seconds: { type: "integer", min: 0, max: 7200 }

progress_update:
  input:
    module_id: { type: "integer", min: 1, max: 50 }
    score: { type: "number", min: 0.0, max: 1.0 }
    status: { type: "string", enum: ["started", "in_progress", "completed", "failed"] }
```

## Domain File References

All 50 files in `Core-Prompts-Learning/` have validation schemas for their module inputs.
