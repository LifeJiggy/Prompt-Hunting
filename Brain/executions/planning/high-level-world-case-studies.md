# Planning: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Execution Plan Design

Plans for analyzing major breaches — case selection, pattern extraction, MITRE mapping, and defensive recommendation generation.

## Plan Template

```yaml
plan:
  name: "casestudy_{case_id}"
  domain: "high-level-cases"
  trigger: "casestudy.selected"
  steps:
    - id: step_1
      action: "gather_sources"
      description: "Collect all public information about incident"
      timeout: 120
    - id: step_2
      action: "reconstruct_timeline"
      description: "Build attack timeline from sources"
      timeout: 180
    - id: step_3
      action: "extract_ttps"
      description: "Identify tactics, techniques, procedures"
      timeout: 120
    - id: step_4
      action: "map_mitre"
      description: "Map to MITRE ATT&CK framework"
      timeout: 60
    - id: step_5
      action: "assess_impact"
      description: "Quantify business and operational impact"
      timeout: 60
    - id: step_6
      action: "generate_defenses"
      description: "Create defensive recommendations"
      timeout: 60
  max_concurrent_steps: 1
  total_timeout: 600
  on_failure: "best_effort"
```

## Plan Files Reference

All 46 files in `High-Level-World-Case-Studies/` map to case study analysis plans — each case follows the sources → timeline → TTPs → MITRE → impact → defenses pattern.
