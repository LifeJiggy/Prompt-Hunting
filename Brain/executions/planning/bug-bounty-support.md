# Planning: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Execution Plan Design

Plans for loading and applying master frameworks, vulnerability detection guidance, and reporting templates.

## Plan Template

```yaml
plan:
  name: "support_{task_type}"
  domain: "bug-bounty-support"
  trigger: "support.methodology.suggested"
  steps:
    - id: step_1
      action: "load_framework"
      description: "Load relevant master framework"
      timeout: 30
    - id: step_2
      action: "analyze_scope"
      description: "Parse program scope and rules"
      timeout: 60
    - id: step_3
      action: "select_methodology"
      description: "Choose hunting methodology for target"
      timeout: 30
    - id: step_4
      action: "configure_tools"
      description: "Set up tools per methodology requirements"
      timeout: 60
    - id: step_5
      action: "apply_template"
      description: "Load report template for vulnerability class"
      timeout: 15
  max_concurrent_steps: 1
  total_timeout: 200
  on_failure: "best_effort"
```

## Plan Files Reference

All 23 files in `bug-bounty-support/` map to support plans:
- Core frameworks: Advanced-Bug-Bounty-Prompt, Advanced-Bug-Security-Hunting-Prompt, Core-Aspects
- Methodology: Reconnaissance, Exploitation, Chaining, Advanced-Techniques
- Tools: Burp-AI, Tools-Integration, JavaScript-Identification
- Reporting: Reporting, PoC-Development
