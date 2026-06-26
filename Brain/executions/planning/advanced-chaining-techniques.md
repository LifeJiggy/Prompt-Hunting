# Planning: Advanced-Chaining-Techniques

**Domain Mapping:** `Advanced-Chaining-Techniques/`

## Execution Plan Design

Plans for executing multi-step vulnerability chains — from primitive discovery through chain assembly and impact demonstration.

## Plan Template

```yaml
plan:
  name: "chain_{chain_id}"
  domain: "advanced-chaining"
  trigger: "chain.discovered"
  steps:
    - id: step_1
      action: "verify_primitive_a"
      description: "Confirm first vulnerability primitive works"
      timeout: 60
      depends_on: []
    - id: step_2
      action: "verify_primitive_b"
      description: "Confirm second vulnerability primitive works"
      timeout: 60
      depends_on: []
    - id: step_3
      action: "assemble_chain"
      description: "Connect primitives into exploitation path"
      timeout: 30
      depends_on: [step_1, step_2]
    - id: step_4
      action: "execute_chain"
      description: "Run full chain end-to-end"
      timeout: 120
      depends_on: [step_3]
    - id: step_5
      action: "demonstrate_impact"
      description: "Document impact with evidence"
      timeout: 60
      depends_on: [step_4]
  max_concurrent_steps: 2
  total_timeout: 300
  on_failure: "fail_fast"
```

## Chain Types and Plans

| Chain Type | Primitives | Example Plan |
|-----------|------------|--------------|
| XSS → ATO | XSS + session theft | 5-step, 4 min |
| IDOR → Admin | IDOR + privilege escalation | 4-step, 3 min |
| SSRF → RCE | SSRF + internal service exploit | 6-step, 5 min |
| Open Redirect → OAuth | Redirect + token theft | 5-step, 4 min |
| Info Leak → Creds → RCE | Disclosure + credential + shell | 7-step, 8 min |

## Plan Files Reference

All 49 chain files in `Advanced-Chaining-Techniques/` map to chain execution plans:
- Files 01-13: Injection and client-side chains
- Files 15-30: Protocol and authentication chains
- Files 31-50: Infrastructure, cloud, and advanced chains
