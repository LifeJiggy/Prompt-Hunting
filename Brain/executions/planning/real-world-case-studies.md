# Planning: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Execution Plan Design

Plans for analyzing disclosed reports — pattern extraction, technique cataloging, and hunt prompt generation from 50 real-world findings.

## Plan Template

```yaml
plan:
  name: "disclosed_{case_id}"
  domain: "real-world-cases"
  trigger: "disclosed.study.selected"
  steps:
    - id: step_1
      action: "analyze_report"
      description: "Read and understand disclosed report"
      timeout: 120
    - id: step_2
      action: "extract_root_cause"
      description: "Identify vulnerability root cause"
      timeout: 60
    - id: step_3
      action: "document_technique"
      description: "Record exploitation technique"
      timeout: 60
    - id: step_4
      action: "derive_pattern"
      description: "Create reusable hunting pattern"
      timeout: 90
    - id: step_5
      action: "generate_hunt_prompt"
      description: "Create automated hunt prompt"
      timeout: 60
  max_concurrent_steps: 1
  total_timeout: 400
  on_failure: "best_effort"
```

## Plan Files Reference

All 50 files in `Real-World-Case-Studies/` map to disclosed analysis plans — each report follows the analyze → root cause → technique → pattern → hunt prompt pipeline.
