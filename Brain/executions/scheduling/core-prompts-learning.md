# Scheduling: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Task Scheduling Configuration

How learning modules are scheduled — sequential progression, assessment timing, and spaced repetition.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **Sequential** | Prerequisite exists | Complete before advancing |
| **Assessment Gate** | After module complete | Require passing score |
| **Spaced Repetition** | After N days | Review previous modules |
| **Streak Tracking** | Daily completion | Maintain streak奖励 |
| **Remediation** | Score below threshold | Return to practice |

## Queue Configuration

```yaml
scheduling:
  queue_type: "sequential_progressive"
  prerequisite_enforcement: true
  assessment_passing_score: 0.8
  spaced_repetition_intervals: [1, 3, 7, 14, 30]
  streak_required_days: 5
  remediation_threshold: 0.5
```

## Schedule Files Reference

Scheduling rules apply to all 50 files in `Core-Prompts-Learning/` — modules progress sequentially with assessment gates.
