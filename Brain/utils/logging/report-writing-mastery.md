# Logging: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Overview

Submission-focused logging tracks report creation, QA outcomes, platform submissions, and acceptance/rejection decisions.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "report_engine"
  domain: "report-writing"
  message: "Report submitted"
  data:
    report_id: "rpt_001"
    platform: "hackerone"
    vuln_class: "idor"
    severity: "critical"
    qa_score: 0.95
    submission_time_s: 120
```

## Domain File References

Logging applies to all 54 files in `Report-Writing-Mastery/` — report lifecycle events are logged from draft to acceptance.
