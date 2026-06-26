# Planning: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Execution Plan Design

Plans for comprehensive attack surface mapping — multi-source enumeration, OSINT, fingerprinting, and asset discovery.

## Plan Template

```yaml
plan:
  name: "recon_{target}"
  domain: "recon-deep-dive"
  trigger: "automation.pipeline.started"
  steps:
    - id: step_1
      action: "subdomain_enum"
      description: "Multi-source subdomain enumeration"
      timeout: 300
    - id: step_2
      action: "osint_collect"
      description: "Passive intelligence gathering"
      timeout: 300
      parallel_with: [step_1]
    - id: step_3
      action: "live_probe"
      description: "Verify which subdomains are live"
      timeout: 120
      depends_on: [step_1]
    - id: step_4
      action: "fingerprint"
      description: "Technology stack identification"
      timeout: 180
      depends_on: [step_3]
    - id: step_5
      action: "api_discover"
      description: "API endpoint enumeration"
      timeout: 180
      depends_on: [step_3]
    - id: step_6
      action: "cloud_enum"
      description: "Cloud resource discovery"
      timeout: 120
      parallel_with: [step_4, step_5]
    - id: step_7
      action: "js_analysis"
      description: "JavaScript source analysis"
      timeout: 180
      parallel_with: [step_4, step_5]
    - id: step_8
      action: "build_asset_graph"
      description: "Construct asset relationship graph"
      timeout: 60
      depends_on: [step_4, step_5, step_6, step_7]
  max_concurrent_steps: 4
  total_timeout: 900
  on_failure: "best_effort"
```

## Recon Phases

| Phase | Steps | Duration | Output |
|-------|-------|----------|--------|
| Passive | 1-2 | 10 min | Subdomains, OSINT data |
| Active | 3-4 | 5 min | Live hosts, technologies |
| Deep | 5-7 | 10 min | APIs, cloud, JS endpoints |
| Synthesis | 8 | 1 min | Asset graph |

## Plan Files Reference

All 50 files in `Reconnaissance-Deep-Dive/` map to recon plans — each methodology is a step or sub-step in the recon pipeline.
