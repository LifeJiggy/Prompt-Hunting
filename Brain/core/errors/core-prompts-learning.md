# Errors: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Error Definitions

Errors specific to the educational subsystem.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `LEARN_MODULE_NOT_FOUND` | Module Missing | Requested learning module not available | Check module ID |
| `LEARN_ASSESSMENT_FAILED` | Assessment Failed | Learner did not pass assessment | Retry with review |
| `LEARN_LEVEL_REGRESSION` | Level Regression | Performance dropped below threshold | Provide remediation content |
| `LEARN_CONTENT_CORRUPT` | Content Corrupt | Module content is malformed | Reload from source |
| `LEARN_PROGRESS_LOST` | Progress Lost | Learner progress data corrupted | Restore from backup |
| `LEARN_PREREQUISITE_MISSING` | Prerequisite Missing | Required prior module not completed | Complete prerequisite first |

## Error Hierarchy

```
LearningError (base)
├── LEARN_MODULE_NOT_FOUND
├── LEARN_ASSESSMENT_FAILED
├── LEARN_LEVEL_REGRESSION
├── LEARN_CONTENT_CORRUPT
├── LEARN_PROGRESS_LOST
└── LEARN_PREREQUISITE_MISSING
```
