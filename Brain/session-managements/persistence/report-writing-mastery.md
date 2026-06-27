# State Persistence: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Overview

State persistence for report writing stores the multi-phase report creation state — draft content, severity assessment, evidence, QA results, and submission status. Report drafts are the most state-intensive data in the system.

## Persistence Schema

```yaml
report_persistence:
  session_id: "wses_{uuid}"
  report_id: "rpt_{uuid}"
  storage_format: "json"
  storage_path: "./brain_sessions/report_{session_id}.json"

  state:
    current_state: "draft"
    draft: { title: "...", summary: "...", severity: "critical", sections: 5 }
    severity: { cvss: "9.1", vector: "AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:N" }
    evidence: { screenshots: 12, videos: 1, curl: 5 }
    qa: { passed: false, issues: 2 }
    submission: null

  triggers:
    - event: "section_written"
      action: "save_incremental"
    - event: "evidence_attached"
      action: "save_checkpoint"
    - event: "qa_completed"
      action: "save_full"
    - event: "submitted"
      action: "save_final"
```

## Operations

```python
def save_report_state(persistence, session):
    persistence.write(session.storage_path, {
        "state": session.current_state,
        "draft": session.draft,
        "severity": session.severity,
        "evidence": session.evidence,
        "qa": session.qa
    }, format="json")
```

## Domain File References

All 54 files in `Report-Writing-Mastery/` persist report creation state across structure, content, technical, impact, evidence, triage, quality, platform, and operations categories.
