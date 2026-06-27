# Helpers: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Overview

Helper functions for learning — scoring, progress tracking, spaced repetition scheduling, and difficulty calculation.

## ScoreCalculator

```python
class ScoreCalculator:
    @staticmethod
    def calculate(answers, correct):
        if not answers:
            return 0.0
        correct_count = sum(1 for a, c in zip(answers, correct) if a == c)
        return correct_count / len(correct)

    @staticmethod
    def level_advance(score, current_level):
        thresholds = {"beginner": 0.8, "intermediate": 0.85, "advanced": 0.9}
        if score >= thresholds.get(current_level, 0.8):
            levels = ["beginner", "intermediate", "advanced", "expert"]
            idx = levels.index(current_level)
            return levels[min(idx + 1, 3)]
        return current_level
```

## SpacedRepetition

```python
class SpacedRepetition:
    INTERVALS = [1, 3, 7, 14, 30]  # days

    @staticmethod
    def next_review(review_count, last_score):
        base_interval = SpacedRepetition.INTERVALS[min(review_count, 4)]
        if last_score >= 0.8:
            return base_interval * 1.5
        return base_interval * 0.5

    @staticmethod
    def is_due(next_review_date):
        return datetime.now() >= next_review_date
```

## ProgressTracker

```python
class ProgressTracker:
    def __init__(self):
        self.completed = set()
        self.scores = {}

    def complete_module(self, module_id, score):
        self.completed.add(module_id)
        self.scores[module_id] = score

    def completion_rate(self, total_modules=50):
        return len(self.completed) / total_modules

    def average_score(self):
        if not self.scores:
            return 0.0
        return sum(self.scores.values()) / len(self.scores)
```

## Domain File References

All 50 files in `Core-Prompts-Learning/` use scoring, spaced repetition, and progress tracking helpers.
