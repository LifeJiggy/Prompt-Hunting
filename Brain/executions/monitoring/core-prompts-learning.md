# Monitoring: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Execution Monitoring Configuration

How learning progress is monitored — module completion, assessment scores, difficulty progression, and streak tracking.

## Metrics Tracked

| Metric | Type | Alert Threshold | Description |
|--------|------|-----------------|-------------|
| `learn.modules_completed` | gauge | — | Total modules done |
| `learn.assessment_score` | histogram | — | Score distribution |
| `learn.current_level` | gauge | — | Current difficulty level |
| `learn.streak_days` | gauge | — | Consecutive learning days |
| `learn.time_spent_minutes` | counter | — | Total learning time |
| `learn.knowledge_gaps` | gauge | >5 | Identified weak areas |

## Monitoring Dashboard

```yaml
monitoring:
  panels:
    - name: "Progress"
      type: "progress_bar"
      metrics: ["learn.modules_completed"]
      total: 50
    - name: "Assessment Scores"
      type: "time_series"
      metrics: ["learn.assessment_score"]
    - name: "Learning Streak"
      type: "counter"
      metrics: ["learn.streak_days"]
```

## Monitoring Files Reference

Monitoring applies to all 50 files in `Core-Prompts-Learning/` — learning progress and knowledge gaps are tracked.
