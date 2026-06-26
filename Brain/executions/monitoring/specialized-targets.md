# Monitoring: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Execution Monitoring Configuration

How category-specific testing is monitored — category detection accuracy, tool deployment status, and compliance mapping progress.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `target.category_detected` | counter | — | Targets categorized |
| `target.category_accuracy` | gauge | <80% | Detection accuracy |
| `target.tools_deployed` | counter | — | Specialized tools used |
| `target.findings_by_category` | histogram | — | Findings per category |
| `target.compliance_mapped` | counter | — | Compliance frameworks mapped |
| `target.safety_blocks` | counter | >0 | Safety-related test blocks |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Category Distribution"
      type: "pie_chart"
      metrics: ["target.category_detected"]
    - name: "Findings by Category"
      type: "bar_chart"
      metrics: ["target.findings_by_category"]
    - name: "Compliance Coverage"
      type: "progress_bar"
      metrics: ["target.compliance_mapped"]
  alerts:
    - name: "Safety Block"
      metric: "target.safety_blocks"
      threshold: 0
      severity: "warning"
      action: "review_safety_protocol"
```

## Monitoring Files Reference

Monitoring applies to all 50 files in `Specialized-Targets/` — category-specific testing progress and safety compliance are tracked.
