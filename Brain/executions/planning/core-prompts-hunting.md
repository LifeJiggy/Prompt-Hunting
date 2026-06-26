# Planning: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Execution Plan Design

Plans for systematic vulnerability hunting across 50 vulnerability classes with tool configurations and exploitation steps.

## Plan Template

```yaml
plan:
  name: "hunt_{vuln_class}_{target}"
  domain: "core-hunting"
  trigger: "recon.asset.discovered"
  steps:
    - id: step_1
      action: "select_vuln_class"
      description: "Choose vulnerability class based on attack surface"
      timeout: 10
    - id: step_2
      action: "configure_tools"
      description: "Set up tools for this vulnerability class"
      timeout: 30
    - id: step_3
      action: "run_tests"
      description: "Execute hunting methodology"
      timeout: 300
    - id: step_4
      action: "apply_bypass"
      description: "If WAF detected, apply bypass techniques"
      timeout: 120
      conditional: "waf_detected == true"
    - id: step_5
      action: "exploit"
      description: "Demonstrate vulnerability exploitation"
      timeout: 120
    - id: step_6
      action: "document"
      description: "Create finding report with PoC"
      timeout: 60
  max_concurrent_steps: 3
  total_timeout: 900
  on_failure: "best_effort"
```

## Hunting Priority Order

| Priority | Vuln Class | Files | Expected Impact |
|----------|-----------|-------|-----------------|
| 1 | Authentication Bypass | 04 | Critical |
| 2 | Authorization Flaws | 05 | Critical |
| 3 | SSRF | 12 | High-Critical |
| 4 | Command Injection | 27 | Critical |
| 5 | SQL Injection | (via tool) | Critical |
| 6 | Deserialization | 26 | Critical |
| 7 | SSTI | 31 | Critical |
| 8 | Business Logic | 07 | Medium-High |
| 9 | File Upload | 11 | High |
| 10 | CSRF | 13 | Medium |

## Plan Files Reference

All 50 files in `Core-Prompts-hunting/` map to hunting plans — each file provides the methodology, tool configs, and exploitation steps for its vulnerability class.
