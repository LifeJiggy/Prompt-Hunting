# Monitoring: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Execution Monitoring Configuration

How report writing is monitored — draft progress, QA pass rates, submission outcomes, and bounty correlation.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `report.drafts_created` | counter | — | Reports drafted |
| `report.qa_pass_rate` | gauge | <80% | QA checklist pass rate |
| `report.submitted` | counter | — | Reports submitted |
| `report.accepted` | counter | — | Reports accepted |
| `report.rejected` | counter | — | Reports rejected |
| `report.avg_bounty` | gauge | — | Average bounty received |
| `report.severity_retention` | gauge | <70% | Severity maintained after triage |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Report Pipeline"
      type: "funnel"
      metrics: ["drafts_created", "qa_pass_rate", "submitted", "accepted"]
    - name: "Acceptance Rate"
      type: "gauge"
      metrics: ["report.accepted"]
    - name: "Bounty Tracker"
      type: "counter"
      metrics: ["report.avg_bounty"]
    - name: "Severity Retention"
      type: "gauge"
      metrics: ["report.severity_retention"]
```

## Monitoring Files Reference

Monitoring applies to all 54 files in `Report-Writing-Mastery/` — report quality and submission outcomes are tracked.
