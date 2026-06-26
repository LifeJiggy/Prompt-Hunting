# Scheduling: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Task Scheduling Configuration

How recon tasks are scheduled — parallel source enumeration, rate-limited probing, and phased execution.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **Parallel Sources** | Multiple OSINT sources | Query simultaneously |
| **Rate Limit** | Source throttling | Back off, try next source |
| **Phase Gating** | Passive before active | Complete passive first |
| **Live Verification** | After enumeration | Probe before deep analysis |
| **Deduplication** | Same asset found twice | Merge results |

## Queue Configuration

```yaml
scheduling:
  queue_type: "phase_gated"
  parallel_sources: true
  max_parallel_queries: 10
  rate_limit_rps: 10
  phases: ["passive", "active", "deep", "synthesis"]
  dedup_on_results: true
```

## Schedule Files Reference

Scheduling rules apply to all 50 files in `Reconnaissance-Deep-Dive/` — recon phases execute in order with parallelism within phases.
