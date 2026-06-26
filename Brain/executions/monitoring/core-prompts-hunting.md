# Monitoring: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Execution Monitoring Configuration

How vulnerability hunting is monitored — class coverage, test completion, findings per class, and bypass success rates.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `hunt.classes_tested` | gauge | — | Vulnerability classes covered |
| `hunt.tests_completed` | counter | — | Individual tests run |
| `hunt.findings_per_class` | histogram | — | Findings distribution |
| `hunt.bypass.success_rate` | gauge | <30% | WAF bypass effectiveness |
| `hunt.false_positive_rate` | gauge | >20% | False positive ratio |
| `hunt.time_per_class` | histogram | — | Time investment per class |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Class Coverage"
      type: "progress_bar"
      metrics: ["hunt.classes_tested"]
      total: 50
    - name: "Findings Distribution"
      type: "heatmap"
      metrics: ["hunt.findings_per_class"]
    - name: "Bypass Success"
      type: "gauge"
      metrics: ["hunt.bypass.success_rate"]
```

## Monitoring Files Reference

Monitoring applies to all 50 files in `Core-Prompts-hunting/` — hunting progress across all vulnerability classes is tracked.
