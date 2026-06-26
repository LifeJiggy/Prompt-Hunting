# Planning: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Execution Plan Design

Plans for progressive learning — module delivery, assessment, difficulty progression, and knowledge gap remediation.

## Plan Template

```yaml
plan:
  name: "learn_{module_id}"
  domain: "core-learning"
  trigger: "learn.module.started"
  steps:
    - id: step_1
      action: "load_prerequisites"
      description: "Ensure prerequisite modules completed"
      timeout: 10
    - id: step_2
      action: "deliver_content"
      description: "Present learning material"
      timeout: 300
    - id: step_3
      action: "run_exercises"
      description: "Hands-on practice exercises"
      timeout: 600
    - id: step_4
      action: "assess_knowledge"
      description: "Quiz and assessment"
      timeout: 300
    - id: step_5
      action: "evaluate_progress"
      description: "Score assessment, determine advancement"
      timeout: 30
  max_concurrent_steps: 1
  total_timeout: 1800
  on_failure: "best_effort"
```

## Learning Paths

| Path | Modules | Duration | Goal |
|------|---------|----------|------|
| Complete Beginner | 01-20 | 3-6 months | First valid report |
| Experienced Hunter | 21-35 | 2-4 months | Increase quality/volume |
| Offensive Specialist | 36-50 | 2-3 months | Master advanced exploitation |

## Plan Files Reference

All 50 files in `Core-Prompts-Learning/` map to learning plans — each module follows the content → exercise → assessment → progression pattern.
