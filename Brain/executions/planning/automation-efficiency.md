# Planning: Automation-Efficiency

**Domain Mapping:** `Automation-Efficiency/`

## Execution Plan Design

Plans for optimizing workflows — deduplication, caching, parallelization, and resource management across automation pipelines.

## Plan Template

```yaml
plan:
  name: "optimize_{pipeline_id}"
  domain: "automation-efficiency"
  trigger: "efficiency.bottleneck.detected"
  steps:
    - id: step_1
      action: "analyze_bottleneck"
      description: "Identify slow step and root cause"
      timeout: 30
    - id: step_2
      action: "check_cache"
      description: "Determine if result can be cached or retrieved"
      timeout: 10
    - id: step_3
      action: "deduplicate"
      description: "Remove redundant work items"
      timeout: 30
    - id: step_4
      action: "parallelize"
      description: "Split independent tasks for concurrent execution"
      timeout: 30
    - id: step_5
      action: "rebalance_resources"
      description: "Redistribute resources to bottleneck"
      timeout: 30
    - id: step_6
      action: "measure_improvement"
      description: "Compare before/after metrics"
      timeout: 60
  max_concurrent_steps: 3
  total_timeout: 200
  on_failure: "best_effort"
```

## Optimization Patterns

| Pattern | Trigger | Steps | Expected Improvement |
|---------|---------|-------|---------------------|
| Cache Hit | Duplicate request | 1 | 90%+ time savings |
| Deduplication | Redundant results | 2 | 30-50% time savings |
| Parallelization | Independent tasks | 3 | 50-80% time savings |
| Resource Rebalance | Uneven load | 4 | 20-40% throughput |
| Tool Fallback | Tool unavailable | 2 | Continuity |

## Plan Files Reference

All 50 files in `Automation-Efficiency/` map to optimization plans:
- Files 01-10: Workflow design and change detection
- Files 11-20: Target management, dedup, parallel processing
- Files 21-30: Configuration, version control, data storage
- Files 31-40: Maintenance, benchmarking, compliance
- Files 41-50: Optimization frameworks, cloud, containers
