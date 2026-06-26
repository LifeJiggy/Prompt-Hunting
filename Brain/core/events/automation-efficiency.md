# Events: Automation-Efficiency

**Domain Mapping:** `Automation-Efficiency/`

## Event Definitions

Events for workflow optimization, deduplication, caching, and resource management across the automation stack.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `efficiency.bottleneck.detected` | `{pipeline_id, step_id, duration, threshold}` | Pipeline step is slow |
| `efficiency.dedup.eliminated` | `{duplicate_count, saved_time}` | Redundant work removed |
| `efficiency.cache.hit` | `{key, source, latency_ms}` | Cached result used |
| `efficiency.cache.miss` | `{key, will_store}` | Cache miss, computing |
| `efficiency.cache.expired` | `{key, age_s}` | Cached entry stale |
| `efficiency.parallel.optimized` | `{group_id, old_serial, new_parallel}` | Parallelization applied |
| `efficiency.resource节约` | `{resource, before, after}` | Resource usage reduced |
| `efficiency.metrics.reported` | `{throughput, latency_p95, error_rate}` | Periodic metrics snapshot |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `automation.step.completed` | Automation | Analyze step duration for optimization |
| `runtime.resource.warning` | Runtime | Trigger resource rebalancing |
| `executions.queue.depth` | Executions | Adjust concurrency limits |

## Event Flow

```
automation.step.completed
        │
        ▼
efficiency.bottleneck.detected? ──Yes──▶ Optimization Applied
        │ No
        ▼
efficiency.dedup.eliminated?
        │ Yes
        ▼
efficiency.cache.hit ──▶ Skip computation
        │ Miss
        ▼
efficiency.cache.miss ──▶ Compute & Store
        │
        ▼
efficiency.metrics.reported
```
