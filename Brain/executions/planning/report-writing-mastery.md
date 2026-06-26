# Planning: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Execution Plan Design

Plans for report creation — structure, content, QA, submission, and follow-up across all platforms.

## Plan Template

```yaml
plan:
  name: "report_{vuln_id}"
  domain: "report-writing"
  trigger: "hunt.vuln.confirmed"
  steps:
    - id: step_1
      action: "assess_severity"
      description: "Calculate CVSS score and justification"
      timeout: 30
    - id: step_2
      action: "draft_structure"
      description: "Create report skeleton with all sections"
      timeout: 60
    - id: step_3
      action: "write_impact"
      description: "Frame business impact"
      timeout: 60
    - id: step_4
      action: "document_steps"
      description: "Write reproduction steps"
      timeout: 120
    - id: step_5
      action: "create_poc"
      description: "Build proof of concept"
      timeout: 180
    - id: step_6
      action: "capture_evidence"
      description: "Screenshot and annotate findings"
      timeout: 120
    - id: step_7
      action: "qa_review"
      description: "Quality assurance checklist"
      timeout: 60
    - id: step_8
      action: "format_platform"
      description: "Adapt for target platform"
      timeout: 30
    - id: step_9
      action: "submit"
      description: "Submit to platform"
      timeout: 30
  max_concurrent_steps: 1
  total_timeout: 600
  on_failure: "fail_fast"
```

## Plan Files Reference

All 54 files in `Report-Writing-Mastery/` map to report writing plans — each file provides guidance for a specific aspect of the report creation pipeline.
