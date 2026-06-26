# Config: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Configuration Schema

Configuration for the educational subsystem — difficulty progression, assessment, and curriculum management.

```yaml
learning:
  # Curriculum
  curriculum:
    total_modules: 50
    difficulty_levels: ["beginner", "intermediate", "advanced", "expert"]
    modules_per_level: [10, 10, 12, 18]
    sequential_prerequisite: true
    allow_skip: false

  # Assessment
  assessment:
    questions_per_module: 10
    passing_score: 0.8
    max_attempts: 3
    time_limit_minutes: 30
    question_types: ["multiple_choice", "hands_on", "code_review"]
    adaptive_difficulty: true

  # Progress Tracking
  progress:
    track_completion: true
    track_scores: true
    track_time_spent: true
    spaced_repetition: true
    review_interval_days: [1, 3, 7, 14, 30]
    streak_tracking: true

  # Difficulty Progression
  progression:
    auto_advance: true
    advance_threshold: 0.85
    regress_threshold: 0.5
    min_modules_before_advance: 3
    cooldown_after_regress: 86400

  # Content Delivery
  delivery:
    max_content_tokens: 10000
    include_exercises: true
    include_assessments: true
    include_real_world: true
    language: "en"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_LEARN_PASS_SCORE` | 0.8 | Assessment passing score |
| `BRAIN_LEARN_MAX_ATTEMPTS` | 3 | Max assessment attempts |
| `BRAIN_LEARN_SPACED_REP` | true | Enable spaced repetition |
