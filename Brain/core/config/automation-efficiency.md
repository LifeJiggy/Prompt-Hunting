# Config: Automation-Efficiency

**Domain Mapping:** `Automation-Efficiency/`

## Configuration Schema

Configuration for workflow optimization, caching, deduplication, and resource management.

```yaml
efficiency:
  # Caching
  cache:
    enabled: true
    backend: "memory"  # memory, redis, filesystem
    default_ttl: 3600
    max_entries: 10000
    eviction_policy: "lru"
    compression: true
    storage_path: "./cache"

  # Deduplication
  deduplication:
    enabled: true
    strategy: "content_hash"  # content_hash, url_fingerprint, semantic
    hash_algorithm: "sha256"
    cross_session: true
    persistence: true

  # Parallel Processing
  parallel:
    max_workers: 10
    worker_pool_size: 20
    task_queue_size: 1000
    load_balancing: "least_loaded"

  # Resource Management
  resources:
    cpu_limit_percent: 80
    memory_limit_mb: 4096
    disk_limit_mb: 10240
    network_limit_mbps: 100
    auto_scale: true
    scale_threshold: 0.7

  # Metrics
  metrics:
    collection_interval: 60
    retention_days: 30
    export_format: "prometheus"
    dashboard_enabled: true

  # False Positive Reduction
  false_positive:
    enabled: true
    ml_filter: false
    rule_based_filter: true
    confidence_threshold: 0.8
    min_occurrences: 2
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_EFF_CACHE_TTL` | 3600 | Cache entry TTL seconds |
| `BRAIN_EFF_MAX_WORKERS` | 10 | Maximum parallel workers |
| `BRAIN_EFF_CPU_LIMIT` | 80 | CPU usage limit percent |
| `BRAIN_EFF_METRICS_INTERVAL` | 60 | Metrics collection interval |
