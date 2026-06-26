# Monitoring: Automation-Efficiency

**Domain Mapping:** `Automation-Efficiency/`

## Execution Monitoring Configuration

How optimization effectiveness is monitored — cache hit rates, dedup savings, resource utilization, and throughput improvements.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `cache.hit_rate` | gauge | <50% | Cache effectiveness |
| `cache.size` | gauge | >80% capacity | Cache utilization |
| `dedup.eliminated` | counter | — | Duplicate tasks removed |
| `parallel.efficiency` | gauge | <60% | Parallelization benefit |
| `resource.cpu` | gauge | >80% | CPU utilization |
| `resource.memory` | gauge | >80% | Memory utilization |
| `throughput.tasks_per_min` | gauge | <10 | Processing rate |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Cache Performance"
      type: "gauge"
      metrics: ["cache.hit_rate", "cache.size"]
    - name: "Resource Usage"
      type: "time_series"
      metrics: ["resource.cpu", "resource.memory"]
    - name: "Throughput"
      type: "rate"
      metrics: ["throughput.tasks_per_min"]
```

## Monitoring Files Reference

Monitoring applies to all 50 files in `Automation-Efficiency/` — optimization metrics track efficiency gains.
