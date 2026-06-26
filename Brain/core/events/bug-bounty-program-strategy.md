# Events: Bug-Bounty-Program-Strategy

**Domain Mapping:** `Bug-Bounty-Program-Strategy/`

## Event Definitions

Events for program selection, ROI tracking, reward analysis, and strategic planning across bug bounty platforms.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `strategy.program.discovered` | `{program_id, platform, name}` | New program identified |
| `strategy.program.scored` | `{program_id, score, rank}` | Program ROI scored |
| `strategy.program.joined` | `{program_id, timestamp}` | Hunter joined program |
| `strategy.program.exited` | `{program_id, reason}` | Hunter left program |
| `strategy.submission.accepted` | `{program_id, bounty, severity}` | Report accepted |
| `strategy.submission.rejected` | `{program_id, reason}` | Report rejected |
| `strategy.submission.downgraded` | `{program_id, from_severity, to_severity}` | Severity reduced |
| `strategy.bounty.received` | `{program_id, amount, currency}` | Payment processed |
| `strategy.time.logged` | `{program_id, hours, activity}` | Time investment tracked |
| `strategy.competition.detected` | `{program_id, hunter_count, activity}` | Competitor activity spotted |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `automation.pipeline.completed` | Automation | Log time investment per program |
| `report.submitted` | Report Writing | Track submission outcomes |

## Event Flow

```
strategy.program.discovered
        │
        ▼
strategy.program.scored
        │
        ▼
strategy.program.joined
        │
   ┌────┴────┐
   │         │
submission.accepted  submission.rejected
   │         │
   ▼         ▼
bounty.received  submission.downgraded
   │
   ▼
strategy.time.logged
```
