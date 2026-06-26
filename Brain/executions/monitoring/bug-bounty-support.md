# Monitoring: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Execution Monitoring Configuration

How support framework usage is monitored — framework load frequency, methodology effectiveness, and template utilization.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `framework.load_count` | counter | — | Frameworks loaded |
| `methodology.applied` | counter | — | Methodologies used |
| `template.used` | counter | — | Templates applied |
| `scope.parse_success` | gauge | <90% | Scope parsing success rate |
| `tool.recommended` | counter | — | Tool suggestions made |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Framework Usage"
      type: "counter"
      metrics: ["framework.load_count"]
    - name: "Methodology Effectiveness"
      type: "bar_chart"
      metrics: ["methodology.applied"]
    - name: "Template Utilization"
      type: "pie_chart"
      metrics: ["template.used"]
```

## Monitoring Files Reference

Monitoring applies to all 23 files in `bug-bounty-support/` — framework and methodology usage is tracked for optimization.
