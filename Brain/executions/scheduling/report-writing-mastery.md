# Scheduling: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Task Scheduling Configuration

How report writing tasks are scheduled — draft → review → QA → submit pipeline with platform-specific timing.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **Sequential Draft** | Writing phases | Complete before QA |
| **QA Gate** | Before submission | Must pass checklist |
| **Platform Timing** | Submission time | Avoid weekends/holidays |
| **Follow-up Cadence** | After submission | 7-day follow-up |
| **Negotiation Window** | After downgrade | 14-day response window |

## Queue Configuration

```yaml
scheduling:
  queue_type: "pipeline"
  draft_phases: ["structure", "content", "poc", "evidence"]
  qa_before_submit: true
  avoid_weekend_submission: true
  followup_delay_days: 7
  negotiation_window_days: 14
```

## Schedule Files Reference

Scheduling rules apply to all 54 files in `Report-Writing-Mastery/` — report creation follows a phased pipeline.
