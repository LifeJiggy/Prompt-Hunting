# Scheduling: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Task Scheduling Configuration

How case study analyses are scheduled — similarity-based selection, batch analysis, and pattern update cadence.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **Similarity Match** | Current target matches case | Prioritize that case |
| **Batch Analysis** | Multiple cases selected | Process sequentially |
| **Pattern Update** | After each analysis | Update pattern database |
| **Session Limit** | Per-session cap | Max 5 cases per session |

## Queue Configuration

```yaml
scheduling:
  queue_type: "similarity_weighted"
  similarity_matching: true
  max_cases_per_session: 5
  pattern_update_after_analysis: true
  batch_size: 3
```

## Schedule Files Reference

Scheduling rules apply to all 46 files in `High-Level-World-Case-Studies/` — cases are selected by relevance to current target.
