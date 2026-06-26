# Monitoring: Advanced-Automation

**Domain Mapping:** `Advanced-Automation/`

## Execution Monitoring Configuration

How automated pipeline execution is monitored — progress tracking, metrics collection, and alert thresholds.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `pipeline.active` | gauge | >10 | Currently running pipelines |
| `pipeline.completed` | counter | — | Total completed pipelines |
| `pipeline.failed` | counter | >5/hour | Failed pipelines |
| `step.duration` | histogram | >300s | Step execution time |
| `tool.invocations` | counter | — | Total tool calls |
| `findings.discovered` | counter | — | Vulnerabilities found |
| `error.rate` | gauge | >10% | Pipeline error rate |

## Monitoring Dashboard

```yaml
monitoring:
  refresh_interval: 30
  panels:
    - name: "Pipeline Status"
      type: "status_grid"
      show: ["active", "completed", "failed"]
    - name: "Step Duration"
      type: "time_series"
      metrics: ["step.duration"]
    - name: "Findings Rate"
      type: "counter"
      metrics: ["findings.discovered"]
    - name: "Error Rate"
      type: "gauge"
      metrics: ["error.rate"]
      alert_threshold: 0.1
```

## Monitoring Files Reference

Monitoring applies to all 50 files in `Advanced-Automation/` — every pipeline step emits metrics tracked here.
