# Monitoring: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Execution Monitoring Configuration

How disclosed report analysis is monitored — reports analyzed, patterns derived, and hunt prompt generation.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `disclosed.analyzed` | counter | — | Reports analyzed |
| `disclosed.patterns_derived` | counter | — | Hunting patterns created |
| `disclosed.hunt_prompts_generated` | counter | — | Automated prompts created |
| `disclosed.avg_bounty` | gauge | — | Average bounty of analyzed reports |
| `disclosed.platform_distribution` | histogram | — | Reports per platform |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Reports Analyzed"
      type: "counter"
      metrics: ["disclosed.analyzed"]
    - name: "Pattern Library Growth"
      type: "time_series"
      metrics: ["disclosed.patterns_derived"]
    - name: "Bounty Correlation"
      type: "scatter"
      metrics: ["disclosed.avg_bounty"]
```

## Monitoring Files Reference

Monitoring applies to all 50 files in `Real-World-Case-Studies/` — disclosed analysis progress and pattern generation are tracked.
