# Events: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Event Definitions

Events for the educational subsystem — tracking module delivery, assessment completion, and learner progression across 50 security topics.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `learn.module.started` | `{module_id, difficulty, learner_id}` | Learning module began |
| `learn.module.completed` | `{module_id, score, duration}` | Module finished |
| `learn.assessment.started` | `{assessment_id, module_id}` | Assessment began |
| `learn.assessment.completed` | `{assessment_id, score, passed}` | Assessment graded |
| `learn.level.advanced` | `{from_level, to_level, modules_completed}` | Difficulty increased |
| `learn.level.regressed` | `{from_level, to_level, reason}` | Difficulty decreased |
| `learn.streak.maintained` | `{streak_count, topic}` | Consecutive completions |
| `learn.streak.broken` | `{topic, expected, actual}` | Streak interrupted |
| `learn.knowledge_gap.detected` | `{topic, gap_area}` | Weak area identified |
| `learn.curriculum.completed` | `{total_modules, avg_score}` | Full curriculum done |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `session.created` | Session Mgmt | Initialize learner profile |
| `session.resumed` | Session Mgmt | Restore learning progress |

## Event Flow

```
session.created
        │
        ▼
learn.module.started
        │
   ┌────┴────┐
   │         │
learn.assessment.started  (exercises within module)
   │
   ▼
learn.assessment.completed
   │
   ▼
learn.module.completed
   │
   ▼
learn.level.advanced (if threshold met)
   │
   ▼
learn.knowledge_gap.detected (if weak)
   │
   ▼
learn.curriculum.completed
```
