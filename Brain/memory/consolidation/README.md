# Memory Consolidation

**Component:** Memory Consolidation Engine

Evaluates working memory entries, scores their importance, and promotes valuable entries to long-term storage while pruning stale or irrelevant data. Consolidation runs on a schedule or can be triggered manually.

---

## MemoryConsolidator Class

```python
consolidator = MemoryConsolidator(
    working_memory=working_mem,
    longterm_memory=longterm_mem,
    index=memory_index,
    importance_threshold=0.7,
    frequency_threshold=3,
    pruning_strategy="staleness"
)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `working_memory` | `WorkingMemory` | required | Source memory to consolidate from |
| `longterm_memory` | `LongTermMemory` | required | Destination for promoted entries |
| `index` | `MemoryIndex` | required | Index to update after promotion |
| `importance_threshold` | `float` | `0.7` | Minimum score for promotion |
| `frequency_threshold` | `int` | `3` | Minimum access count for promotion |
| `pruning_strategy` | `str` | `"staleness"` | Pruning method: `staleness`, `random`, `score` |

---

## Importance Scoring

Each entry receives an importance score between 0.0 and 1.0 based on multiple weighted factors.

### Scoring Formula

```
score = (
    w_access_frequency * frequency_score +
    w_recency * recency_score +
    w_priority * priority_score +
    w_type * type_score +
    w_source * source_score
)
```

### Scoring Factors

| Factor | Weight | Range | Description |
|--------|--------|-------|-------------|
| `access_frequency` | 0.25 | [0, 1] | How often the entry has been read |
| `recency` | 0.20 | [0, 1] | Time since last access (newer = higher) |
| `priority` | 0.30 | [0, 1] | Explicit priority set by the agent |
| `type` | 0.15 | [0, 1] | Entry type relevance (`findings` > `scratch`) |
| `source` | 0.10 | [0, 1] | Source credibility (verified tool > manual) |

### Frequency Score

```python
def frequency_score(access_count):
    # Logarithmic scale: 1 access = 0.2, 5 = 0.7, 10+ = 1.0
    return min(1.0, math.log(access_count + 1) / math.log(11))
```

### Recency Score

```python
def recency_score(last_access_time, now):
    hours = (now - last_access_time).total_seconds() / 3600
    # Exponential decay: 0h = 1.0, 1h = 0.82, 24h = 0.13, 72h = 0.0
    return max(0.0, math.exp(-hours / 24))
```

### Type Scores

| Type | Score | Reasoning |
|------|-------|-----------|
| `finding` | 1.0 | High-value security findings |
| `result` | 0.8 | Scan results and tool outputs |
| `context` | 0.6 | Task context and configuration |
| `list` | 0.5 | Enumeration data (subdomains, hosts) |
| `scratch` | 0.2 | Temporary calculations |

---

## Promotion Rules

Entries are promoted from working memory to long-term storage when they meet the promotion criteria.

### Promotion Criteria

An entry is promoted when:

1. **Importance score** >= `importance_threshold` (default 0.7)
2. **Access count** >= `frequency_threshold` (default 3)
3. **Entry is not expired** (TTL check passes)
4. **Long-term storage has capacity** (below `max_size_mb`)

### Promotion Process

```
Working Memory Entry
        │
        ▼
┌───────────────┐
│ SCORE ENTRY   │ ← Compute importance from weighted factors
└───────┬───────┘
        │
        ▼
   Score >= Threshold?
   ├── Yes ─────────────────────────────────┐
   │                                         ▼
   │                              ┌──────────────────┐
   │                              │ CHECK CAPACITY   │
   │                              └────────┬─────────┘
   │                                       │
   │                                  Has room?
   │                                  ├── Yes ─────────────┐
   │                                  │                    ▼
   │                                  │          ┌────────────────┐
   │                                  │          │ PROMOTE ENTRY  │
   │                                  │          │ → LongTerm     │
   │                                  │          │ → Update Index │
   │                                  │          └────────────────┘
   │                                  └── No → Evict lowest-score LTM
   │
   └── No → Keep in working memory
```

### Promotion Code

```python
# Run consolidation cycle
result = consolidator.consolidate()
# {
#     "promoted": 12,
#     "pruned": 5,
#     "skipped": 3,
#     "errors": 0,
#     "duration_ms": 234
# }

# Check what would be promoted (dry run)
preview = consolidator.preview(dry_run=True)
# [
#     {"key": "xss_findings", "score": 0.92, "action": "promote"},
#     {"key": "temp_data", "score": 0.15, "action": "prune"},
#     ...
# ]
```

---

## Pruning Strategies

Entries that do not meet promotion criteria or exceed capacity are pruned according to the configured strategy.

### Strategy: Staleness

Prunes entries with the oldest last-access times first. This is the default and most predictable strategy.

```python
consolidator = MemoryConsolidator(pruning_strategy="staleness")
```

### Strategy: Random

Randomly selects entries for pruning. Useful when all entries have similar importance and you want to avoid systematic bias.

```python
consolidator = MemoryConsolidator(pruning_strategy="random")
```

### Strategy: Score

Prunes entries with the lowest importance scores first. Most aggressive but preserves highest-value data.

```python
consolidator = MemoryConsolidator(pruning_strategy="score")
```

### Pruning Behavior

| Strategy | Predictable | Data Loss Risk | Best For |
|----------|-------------|----------------|----------|
| `staleness` | High | Low | General use |
| `random` | Low | Medium | Uniform data |
| `score` | High | Higher | Value-sensitive workloads |

---

## Scheduled Consolidation

Consolidation runs automatically on a configurable interval and can also be triggered manually.

### Automatic Schedule

```python
# Configure in memory config
consolidation:
  auto_consolidate: true
  consolidation_interval: 300  # seconds (5 minutes)
```

The consolidation scheduler:

1. Waits for `consolidation_interval` seconds
2. Runs `consolidator.consolidate()`
3. Logs metrics (promoted, pruned, errors)
4. Emits consolidation events on the event bus
5. Reschedules itself

### Manual Trigger

```python
# Immediate consolidation
consolidator.consolidate()

# Consolidate with custom threshold override
consolidator.consolidate(importance_threshold=0.5)

# Consolidate specific entries only
consolidator.consolidate(filter_keys=["xss_results", "scan_output"])
```

### Event Emissions

```python
# The consolidator emits events on the Brain event bus
# event: "memory.consolidation.started"
# event: "memory.consolidation.promoted"  {entry_id, score}
# event: "memory.consolidation.pruned"    {entry_id, reason}
# event: "memory.consolidation.completed" {metrics}
# event: "memory.consolidation.failed"    {error}
```

---

## Consolidation Metrics

The consolidator tracks performance metrics for monitoring and debugging.

```python
metrics = consolidator.metrics()
# {
#     "total_cycles": 147,
#     "last_run": "2026-05-21T11:30:00Z",
#     "last_duration_ms": 234,
#     "avg_duration_ms": 198,
#     "total_promoted": 892,
#     "total_pruned": 1203,
#     "total_errors": 2,
#     "error_rate": 0.0015,
#     "working_memory_utilization": 0.42,
#     "longterm_storage_mb": 12.7,
#     "longterm_entry_count": 892
# }
```

### Key Metrics

| Metric | Description |
|--------|-------------|
| `total_cycles` | Number of consolidation runs completed |
| `last_duration_ms` | Time taken for the most recent cycle |
| `avg_duration_ms` | Rolling average cycle duration |
| `total_promoted` | Cumulative entries promoted to long-term |
| `total_pruned` | Cumulative entries removed from working memory |
| `error_rate` | Fraction of entries that failed processing |
| `working_memory_utilization` | Current working memory usage (0.0-1.0) |
| `longterm_storage_mb` | Current long-term storage size |

---

## Integration Points

| Component | Interaction |
|-----------|-------------|
| `working/` | Reads entries for scoring, prunes low-value entries |
| `longterm/` | Writes promoted entries, reads for deduplication |
| `index/` | Updates indexes after promotion and pruning |
| `core/` | Emits consolidation events on the event bus |
| `runtime/` | Reports consolidation metrics for monitoring |

---

*Part of the Brain memory subsystem.*
