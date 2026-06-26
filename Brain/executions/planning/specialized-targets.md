# Planning: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Execution Plan Design

Plans for category-specific testing — methodology selection, tool deployment, and compliance mapping for 50 target types.

## Plan Template

```yaml
plan:
  name: "specialized_{category}_{target}"
  domain: "specialized-targets"
  trigger: "target.category.detected"
  steps:
    - id: step_1
      action: "load_methodology"
      description: "Load category-specific testing methodology"
      timeout: 30
    - id: step_2
      action: "deploy_tools"
      description: "Set up category-specific tools"
      timeout: 60
    - id: step_3
      action: "run_tests"
      description: "Execute category-specific tests"
      timeout: 600
    - id: step_4
      action: "map_compliance"
      description: "Map findings to regulatory frameworks"
      timeout: 60
    - id: step_5
      action: "contextualize_impact"
      description: "Frame impact in domain-specific terms"
      timeout: 60
  max_concurrent_steps: 1
  total_timeout: 900
  on_failure: "best_effort"
```

## Category Plan Variants

| Category | Special Steps | Tools | Compliance |
|----------|--------------|-------|------------|
| IoT | Firmware extract, hardware interface | binwalk, jtag | None |
| Mobile | App decompile, cert pin bypass | frida, apktool | OWASP MASVS |
| Cloud | IAM enum, bucket list | pacu, prowler | CIS Benchmarks |
| Blockchain | Contract audit, flash loan | slither, mythril | None |
| ICS/SCADA | Protocol test, safety check | modbus-client | NIST SP 800-82 |
| Healthcare | DICOM, HL7, HIPAA | custom | HIPAA |

## Plan Files Reference

All 50 files in `Specialized-Targets/` map to specialized testing plans — each target category has its own methodology, tools, and compliance requirements.
