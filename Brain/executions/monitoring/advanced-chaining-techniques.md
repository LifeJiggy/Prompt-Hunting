# Monitoring: Advanced-Chaining-Techniques

**Domain Mapping:** `Advanced-Chaining-Techniques/`

## Execution Monitoring Configuration

How chain execution is monitored — chain completion rates, step success/failure, and impact demonstration tracking.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `chain.active` | gauge | — | Chains being executed |
| `chain.completed` | counter | — | Successfully completed chains |
| `chain.failed` | counter | >3/hour | Failed chain executions |
| `chain.impact_demonstrated` | counter | — | Chains with proven impact |
| `chain.step.success_rate` | gauge | <80% | Per-step success rate |
| `chain.severity_amplified` | counter | — | Chains that elevated severity |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Chain Pipeline"
      type: "flow_diagram"
      show: ["discovery", "design", "execution", "impact"]
    - name: "Impact Rate"
      type: "gauge"
      metrics: ["chain.impact_demonstrated"]
    - name: "Step Success"
      type: "time_series"
      metrics: ["chain.step.success_rate"]
```

## Monitoring Files Reference

Monitoring applies to all 49 files in `Advanced-Chaining-Techniques/` — chain execution progress and impact are tracked.
