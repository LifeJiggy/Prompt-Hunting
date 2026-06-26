# Errors: Automation-Efficiency

**Domain Mapping:** `Automation-Efficiency/`

## Error Definitions

Errors specific to workflow optimization, caching, and resource management.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `EFF_CACHE_FULL` | Cache Full | Cache reached maximum capacity | Evict oldest entries |
| `EFF_CACHE_CORRUPT` | Cache Corrupt | Cached data is corrupted | Invalidate and recompute |
| `EFF_DEDUP_FAILED` | Deduplication Failed | Could not compare content hashes | Force recomputation |
| `EFF_RESOURCE_EXHAUSTED` | Resource Exhausted | CPU/memory/disk limit reached | Scale up or throttle |
| `EFF_WORKER_CRASHED` | Worker Crashed | Parallel worker process died | Restart worker, requeue task |
| `EFF_QUEUE_OVERFLOW` | Queue Overflow | Task queue exceeded capacity | Drop lowest priority tasks |
| `EFF_METRICS_LOST` | Metrics Lost | Could not persist metrics data | Buffer locally, retry |
| `EFF_SCALING_FAILED` | Scaling Failed | Auto-scaling could not add resources | Manual intervention |

## Error Hierarchy

```
EfficiencyError (base)
├── EFF_CACHE_FULL
├── EFF_CACHE_CORRUPT
├── EFF_DEDUP_FAILED
├── EFF_RESOURCE_EXHAUSTED
├── EFF_WORKER_CRASHED
├── EFF_QUEUE_OVERFLOW
├── EFF_METRICS_LOST
└── EFF_SCALING_FAILED
```
