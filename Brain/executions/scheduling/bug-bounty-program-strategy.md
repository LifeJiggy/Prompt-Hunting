# Scheduling: Bug-Bounty-Program-Strategy

**Domain Mapping:** `Bug-Bounty-Program-Strategy/`

## Task Scheduling Configuration

How strategy tasks are scheduled — weekly reviews, daily check-ins, and time-boxed hunting sessions.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **Weekly Review** | Every Monday | Score programs, allocate time |
| **Daily Check-in** | Every morning | Check submissions, follow up |
| **Time Box** | Per-program allocation | Stop when time budget reached |
| **Urgent Follow-up** | Pending > 7 days | Send follow-up message |
| **Monthly Deep Dive** | First of month | Full ROI analysis |

## Queue Configuration

```yaml
scheduling:
  queue_type: "scheduled"
  weekly_review: "monday 09:00"
  daily_checkin: "08:00"
  time_box_per_program_hours: 4
  followup_threshold_days: 7
  monthly_deep_dive: "1st 10:00"
```

## Schedule Files Reference

Scheduling rules apply to all 50 files in `Bug-Bounty-Program-Strategy/` — strategy tasks follow a cadenced schedule.
