# Scheduling: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Task Scheduling Configuration

How support framework loading and methodology application are scheduled.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **On-Demand Load** | Methodology requested | Load immediately |
| **Cache Frameworks** | After first load | Keep in working memory |
| **Periodic Refresh** | Daily | Update knowledge base |
| **Context-Aware** | Target profile available | Select relevant methodology |

## Queue Configuration

```yaml
scheduling:
  queue_type: "on_demand"
  cache_frameworks: true
  refresh_interval: 86400
  context_aware_selection: true
```

## Schedule Files Reference

Scheduling rules apply to all 23 files in `bug-bounty-support/` — frameworks load on demand and cache for reuse.
