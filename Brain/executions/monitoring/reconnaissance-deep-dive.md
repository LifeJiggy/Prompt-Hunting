# Monitoring: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Execution Monitoring Configuration

How reconnaissance is monitored — asset discovery rates, source effectiveness, and coverage metrics.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `recon.assets_discovered` | counter | — | Total assets found |
| `recon.subdomains_found` | counter | — | Subdomains enumerated |
| `recon.live_hosts` | counter | — | Live hosts confirmed |
| `recon.source.effectiveness` | gauge | — | Findings per source |
| `recon.coverage` | gauge | <70% | Asset coverage estimate |
| `recon.rate_limit_hits` | counter | >10/hour | Rate limit events |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Asset Discovery"
      type: "counter"
      metrics: ["recon.assets_discovered", "recon.subdomains_found"]
    - name: "Source Effectiveness"
      type: "bar_chart"
      metrics: ["recon.source.effectiveness"]
    - name: "Coverage"
      type: "gauge"
      metrics: ["recon.coverage"]
```

## Monitoring Files Reference

Monitoring applies to all 50 files in `Reconnaissance-Deep-Dive/` — recon progress and asset coverage are tracked.
