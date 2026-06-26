# Errors: Bug-Bounty-Program-Strategy

**Domain Mapping:** `Bug-Bounty-Program-Strategy/`

## Error Definitions

Errors specific to program selection, ROI tracking, and strategic planning.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `STRAT_PROGRAM_NOT_FOUND` | Program Not Found | Referenced program does not exist | Discover program again |
| `STRAT_SCOPE_CHANGED` | Scope Changed | Program scope modified since last check | Re-evaluate program |
| `STRAT_BOUNTY_UNPAID` | Bounty Unpaid | Expected payment not received | Follow up with program |
| `STRAT_DUPLICATE_SUBMISSION` | Duplicate Submission | Finding already reported | Check existing reports first |
| `STRAT_TIME_BUDGET_EXCEEDED` | Time Budget Exceeded | Spent more time than allocated | Reallocate from other programs |
| `STRAT_SCORE_OUTDATED` | Score Outdated | Program score based on stale data | Rescore program |
| `STRAT_PROGRAM_PAUSED` | Program Paused | Program temporarily not accepting reports | Monitor for reactivation |
| `STRAT_NEGOTIATION_FAILED` | Negotiation Failed | Bounty negotiation unsuccessful | Accept current offer |

## Error Hierarchy

```
StrategyError (base)
├── STRAT_PROGRAM_NOT_FOUND
├── STRAT_SCOPE_CHANGED
├── STRAT_BOUNTY_UNPAID
├── STRAT_DUPLICATE_SUBMISSION
├── STRAT_TIME_BUDGET_EXCEEDED
├── STRAT_SCORE_OUTDATED
├── STRAT_PROGRAM_PAUSED
└── STRAT_NEGOTIATION_FAILED
```
