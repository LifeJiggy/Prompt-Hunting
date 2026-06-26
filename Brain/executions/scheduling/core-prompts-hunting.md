# Scheduling: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Task Scheduling Configuration

How vulnerability hunting tasks are scheduled across 50 classes — priority ordering, parallel class testing, and resource allocation.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **Priority Order** | Multiple classes available | Test highest-impact first |
| **Parallel Classes** | Independent endpoints | Test up to 3 classes simultaneously |
| **Time Budget** | Per-class limit | Move to next class when exceeded |
| **WAF Detection** | WAF triggered | Pause, apply bypass, resume |
| **Exhaustion** | All tests complete | Move to next class |

## Queue Configuration

```yaml
scheduling:
  queue_type: "priority_weighted"
  max_parallel_classes: 3
  time_per_class_seconds: 600
  priority_classes: [4, 5, 12, 27, 25, 26, 31]
  waf_pause_on_detect: true
```

## Schedule Files Reference

Scheduling rules apply to all 50 files in `Core-Prompts-hunting/` — each vulnerability class is scheduled by priority and resource availability.
