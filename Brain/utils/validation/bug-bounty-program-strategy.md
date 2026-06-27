# Validation: Bug-Bounty-Program-Strategy

**Domain Mapping:** `Bug-Bounty-Program-Strategy/`

## Overview

Schema validation for strategy tools ensures program data, scoring weights, and time allocation parameters are valid.

## Validation Schemas

```yaml
program_scoring:
  input:
    program_id: { type: "string", required: true }
    weights:
      bounty_range: { type: "number", min: 0, max: 1 }
      response_time: { type: "number", min: 0, max: 1 }
      competition: { type: "number", min: 0, max: 1 }
      scope_clarity: { type: "number", min: 0, max: 1 }

time_allocation:
  input:
    max_hours_weekly: { type: "number", min: 1, max: 100 }
    programs: { type: "array", minItems: 1, maxItems: 20 }
    strategy: { type: "string", enum: ["roi_weighted", "equal", "priority_based"] }
```

## Domain File References

All 50 files in `Bug-Bounty-Program-Strategy/` have validation schemas for strategy parameters.
