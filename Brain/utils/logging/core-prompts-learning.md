# Logging: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Overview

Learning-focused logging tracks module completion, assessment scores, difficulty progression, and knowledge gaps.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "learning_engine"
  domain: "core-learning"
  message: "Module completed"
  data:
    module_id: 12
    module_name: "SSRF Learning"
    score: 0.9
    duration_minutes: 45
    difficulty: "intermediate"
    passed: true
```

## Domain File References

Logging applies to all 50 files in `Core-Prompts-Learning/` — module progress, assessment outcomes, and learning metrics are logged.
