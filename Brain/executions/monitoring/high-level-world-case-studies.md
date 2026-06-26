# Monitoring: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Execution Monitoring Configuration

How case study analysis is monitored — cases analyzed, patterns extracted, and MITRE coverage.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `casestudy.analyzed` | counter | — | Cases fully analyzed |
| `casestudy.patterns_extracted` | counter | — | TTPs identified |
| `casestudy.mitre_coverage` | gauge | — | ATT&CK technique coverage |
| `casestudy.defenses_generated` | counter | — | Defensive recommendations |
| `casestudy.avg_analysis_time` | histogram | — | Time per case study |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Cases Analyzed"
      type: "counter"
      metrics: ["casestudy.analyzed"]
    - name: "MITRE Coverage"
      type: "gauge"
      metrics: ["casestudy.mitre_coverage"]
    - name: "Pattern Library"
      type: "counter"
      metrics: ["casestudy.patterns_extracted"]
```

## Monitoring Files Reference

Monitoring applies to all 46 files in `High-Level-World-Case-Studies/` — case analysis progress and pattern extraction are tracked.
