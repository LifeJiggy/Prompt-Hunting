# Events: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Event Definitions

Events for report creation, quality assurance, submission, and follow-up across all bug bounty platforms.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `report.draft.created` | `{report_id, vuln_id, platform}` | Report draft initiated |
| `report.structure.validated` | `{report_id, sections_present}` | Structure check passed |
| `report.severity.assessed` | `{report_id, cvss_vector, score}` | Severity assigned |
| `report.poc.attached` | `{report_id, poc_type, file_count}` | PoC evidence added |
| `report.impact.framed` | `{report_id, business_impact}` | Impact statement written |
| `report.qa.passed` | `{report_id, checklist_score}` | QA review completed |
| `report.submitted` | `{report_id, platform, program_id}` | Report submitted |
| `report.accepted` | `{report_id, bounty, severity}` | Report accepted |
| `report.rejected` | `{report_id, reason, category}` | Report rejected |
| `report.downgraded` | `{report_id, from_severity, to_severity}` | Severity reduced |
| `report.followup.sent` | `{report_id, message_type}` | Follow-up communicated |
| `report.negotiation.started` | `{report_id, disputed_severity}` | Bounty negotiation begun |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `hunt.vuln.confirmed` | Hunting | Trigger report creation |
| `chain.impact.confirmed` | Chaining | Create chained finding report |
| `strategy.submission.accepted` | Strategy | Record outcome |
| `strategy.submission.rejected` | Strategy | Analyze rejection |

## Event Flow

```
hunt.vuln.confirmed
        │
        ▼
report.draft.created
        │
        ▼
report.structure.validated
        │
   ┌────┼────┐
   │    │    │
   ▼    ▼    ▼
severity.assessed  poc.attached  impact.framed
   │    │    │
   └────┼────┘
        │
        ▼
report.qa.passed
        │
        ▼
report.submitted
        │
   ┌────┴────┐
   │         │
report.accepted  report.rejected
   │         │
   ▼         ▼
(none)  report.downgraded → report.negotiation.started
```
