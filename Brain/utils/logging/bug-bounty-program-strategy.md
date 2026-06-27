# Logging: Bug-Bounty-Program-Strategy

**Domain Mapping:** `Bug-Bounty-Program-Strategy/`

## Overview

Strategy-focused logging tracks program selection decisions, time allocation, bounty outcomes, and competition analysis.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "strategy_engine"
  domain: "bug-bounty-strategy"
  message: "Program scored"
  data:
    program_id: "prog_001"
    program_name: "Target Corp"
    score: 0.85
    rank: 3
    platform: "hackerone"
```

## Domain File References

Logging applies to all 50 files in `Bug-Bounty-Program-Strategy/` — program scores, time investments, and bounty outcomes are logged.
