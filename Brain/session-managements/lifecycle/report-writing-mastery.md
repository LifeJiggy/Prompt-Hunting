# Session Lifecycle: Report Writing Mastery Domain

> Session lifecycle management for vulnerability report drafting, quality assurance, and submission preparation across all 54 Report-Writing-Mastery modules.

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | `report-writing` |
| Source Directory | `Report-Writing-Mastery/` |
| Module Count | 54 |
| Session Type | `report-session` |
| State Complexity | High — tracks report drafts, review cycles, and submission readiness |
| Parent System | Session Lifecycle Manager |

## Overview

This document defines the complete session lifecycle for the Report Writing Mastery domain. Report sessions manage the process of drafting, reviewing, and finalizing vulnerability reports for submission to bug bounty programs. Each session tracks which report writing modules are loaded, the current draft phase, review comments, and submission readiness.

Report sessions are critical for converting findings into accepted reports. They manage the full lifecycle from initial draft through multiple review cycles to final submission. The lifecycle tracks report quality metrics, reviewer feedback, and program-specific formatting requirements.

## Session State Machine

```
┌─────────┐     activate      ┌──────────┐
│ created │ ─────────────────→│  active   │
└─────────┘                   └────┬─────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │drafting  │              │reviewing │              │revising  │
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │formatting│              │polishing │              │submitting│
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       └──────────────────────────┼──────────────────────────┘
                                  ▼
                           ┌──────────┐
                           │submitted │
                           └────┬─────┘
                                │
                                ▼
                           ┌──────────┐
                           │  closed  │
                           └──────────┘
```

### State Definitions

| State | Description |
|-------|-------------|
| `created` | Session initialized; finding and target defined |
| `active` | Session running; report writing workflow active |
| `drafting` | Initial report draft being written |
| `reviewing` | Report being reviewed for quality and accuracy |
| `revising` | Report being revised based on review feedback |
| `formatting` | Report being formatted for program submission |
| `polishing` | Final polish and proofreading |
| `submitting` | Report being prepared for submission |
| `submitted` | Report submitted to bug bounty program |
| `closed` | Session terminated and results archived |

## Session Creation

### `create_report_session()`

Creates a new session for a report writing workflow.

**Parameters:**
- `name` (str): Human-readable session identifier
- `finding` (dict): Vulnerability finding to report
- `program` (str): Target bug bounty program
- `report_type` (str): Type of report (disclosure, bug bounty, advisory)
- `modules` (list[str]): Report writing modules to load
- `max_duration` (int): Maximum session lifetime in seconds (default: `14400` — 4 hours)
- `auto_checkpoint` (bool): Enable automatic state checkpointing (default: `True`)

**Returns:** `Session` object with unique ID, finding details, and report configuration.

**Validation:**
- Session name must be unique
- Finding must have required fields (title, severity, description)
- Module references must exist in the directory

**Initialization Steps:**
1. Generate session ID: `report_ses_<40-char-hex>`
2. Validate finding and program
3. Create session directory: `sessions/<session_id>/`
4. Initialize report draft tracker
5. Register session in the active report session registry
6. Emit `session.created` event

## Session Close

### `close_report_session(session_id)`

Gracefully terminates a report session.

**Pre-close Checks:**
1. Verify report draft is saved
2. Check if submission is complete
3. Ensure all review feedback is addressed

**Close Process:**
1. Transition state to `closing`
2. Archive final report draft
3. Save submission confirmation
4. Record program response (if available)
5. Archive review comments and revisions
6. Remove session from active registry
7. Transition state to `closed`
8. Emit `session.closed` event

## Session Suspend

### `suspend_report_session(session_id)`

Pauses an active report session.

**Suspend Process:**
1. Save current draft version
2. Serialize report state including:
   - Current draft content
   - Review comments pending
   - Revision history
   - Formatting configuration
3. Save progress
4. Transition state to `suspended`

## Session Resume

### `resume_report_session(session_id)`

Restores a suspended report session.

**Resume Process:**
1. Load serialized report state
2. Verify state integrity
3. Restore draft content
4. Resume from last phase
5. Transition state to `active`
6. Emit `session.resumed` event

## Session Metadata Schema

### Standard Fields

| Field | Type | Description |
|-------|------|-------------|
| `session_id` | str | Unique session identifier |
| `name` | str | Human-readable name |
| `state` | str | Current lifecycle state |
| `created_at` | ISO 8601 | Creation timestamp |
| `updated_at` | ISO 8601 | Last update timestamp |
| `suspended_at` | ISO 8601 | Last suspension timestamp |
| `closed_at` | ISO 8601 | Closure timestamp |

### Report-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `finding` | dict | Vulnerability finding details |
| `program` | str | Target bug bounty program |
| `report_type` | str | Type of report |
| `modules_loaded` | list[str] | Report writing modules loaded |
| `current_phase` | str | Current writing phase |
| `draft_versions` | list[dict] | Draft version history |
| `current_draft` | str | Current draft content |
| `review_comments` | list[dict] | Review feedback |
| `revision_history` | list[dict] | Revision history |
| `quality_metrics` | dict | Report quality scores |
| `formatting_config` | dict | Program-specific formatting |
| `submission_status` | str | Submission status |
| `program_response` | dict | Program response (if any) |

## Session Lookup

### `find_report_sessions()`

Search for report sessions by criteria.

**Search Parameters:**
- `state` (str): Filter by session state
- `program` (str): Filter by target program
- `report_type` (str): Filter by report type
- `submitted` (bool): Filter by submission status

**Examples:**
```python
# Find all active report sessions
sessions = find_report_sessions(state="active")

# Find reports for a specific program
sessions = find_report_sessions(program="hackerone-example")
```

## Session Limits

### Report-Specific Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_report_sessions` | 5 | Concurrent report sessions |
| `max_modules_per_session` | 10 | Report writing modules per session |
| `max_session_duration` | 14400s (4h) | Maximum writing runtime |
| `max_draft_versions` | 20 | Draft versions per session |
| `max_review_comments` | 100 | Review comments per session |
| `max_revision_cycles` | 10 | Revision cycles per session |
| `max_state_size` | 20MB | Serialized state size limit |

## Session Isolation

### File System Isolation

```
sessions/<session_id>/
├── state/
│   ├── report-state.json       # Report writing phase tracker
│   ├── drafts/                 # Draft versions
│   │   ├── v1.md
│   │   ├── v2.md
│   │   └── ...
│   ├── reviews/                # Review comments
│   ├── revisions/              # Revision history
│   └── checkpoints/            # Serialized checkpoints
├── output/
│   ├── final-report.md         # Final report for submission
│   ├── submission-log.json     # Submission history
│   ├── program-response.json   # Program response
│   └── artifacts/              # Screenshots, PoCs, etc.
├── config/
│   ├── report-config.json      # Session configuration
│   ├── finding.json            # Finding details
│   ├── program.json            # Program requirements
│   └── formatting.json         # Formatting configuration
└── metadata.json               # Session metadata
```

## Module References for Report Writing Mastery

| Module | File Reference |
|--------|---------------|
| Report Structure Optimization | `Report-Writing-Mastery/01-Report-Structure-Optimization.md` |
| Technical Writing Standards | `Report-Writing-Mastery/02-Technical-Writing-Standards.md` |
| Private Program Case Study | `Report-Writing-Mastery/03-Private-Program-Case-Study.md` |
| Proof-of-Concept Development | `Report-Writing-Mastery/04-Proof-of-Concept-Development.md` |
| Vulnerability Severity Assessment | `Report-Writing-Mastery/05-Vulnerability-Severity-Assessment.md` |
| Remediation Recommendations | `Report-Writing-Mastery/06-Remediation-Recommendations.md` |
| Executive Summary Crafting | `Report-Writing-Mastery/07-Executive-Summary-Crafting.md` |
| Technical Detail Balancing | `Report-Writing-Mastery/08-Technical-Detail-Balancing.md` |
| Visual Aid Integration | `Report-Writing-Mastery/09-Visual-Aid-Integration.md` |
| Code Sample Formatting | `Report-Writing-Mastery/10-Code-Sample-Formatting.md` |
| Timeline Documentation | `Report-Writing-Mastery/11-Timeline-Documentation.md` |
| Collaboration Crediting | `Report-Writing-Mastery/12-Collaboration-Crediting.md` |
| Program-Specific Formatting | `Report-Writing-Mastery/13-Program-Specific-Formatting.md` |
| Language and Tone Optimization | `Report-Writing-Mastery/14-Language-and-Tone-Optimization.md` |
| Attachment Management | `Report-Writing-Mastery/15-Attachment-Management.md` |
| Follow-up Communication | `Report-Writing-Mastery/16-Follow-up-Communication.md` |
| Rejection Analysis and Improvement | `Report-Writing-Mastery/17-Rejection-Analysis-and-Improvement.md` |
| Reward Negotiation Preparation | `Report-Writing-Mastery/18-Reward-Negotiation-Preparation.md` |
| Report Template Development | `Report-Writing-Mastery/19-Report-Template-Development.md` |
| Quality Assurance Process | `Report-Writing-Mastery/20-Quality-Assurance-Process.md` |
| Grammar and Style Standards | `Report-Writing-Mastery/21-Grammar-and-Style-Standards.md` |
| Technical Accuracy Verification | `Report-Writing-Mastery/22-Technical-Accuracy-Verification.md` |
| Impact Quantification | `Report-Writing-Mastery/23-Impact-Quantification.md` |
| Business Context Integration | `Report-Writing-Mastery/24-Business-Context-Integration.md` |
| Compliance Documentation | `Report-Writing-Mastery/25-Compliance-Documentation.md` |
| International Standard Adherence | `Report-Writing-Mastery/26-International-Standard-Adherence.md` |
| Audience Analysis | `Report-Writing-Mastery/27-Audience-Analysis.md` |
| Information Hierarchy | `Report-Writing-Mastery/28-Information-Hierarchy.md` |
| Actionable Recommendations | `Report-Writing-Mastery/29-Actionable-Recommendations.md` |
| Report Review Process | `Report-Writing-Mastery/30-Report-Review-Process.md` |
| Common Pitfalls Avoidance | `Report-Writing-Mastery/31-Common-Pitfalls-Avoidance.md` |
| Advanced Formatting Techniques | `Report-Writing-Mastery/32-Advanced-Formatting-Techniques.md` |
| Multimedia Integration | `Report-Writing-Mastery/33-Multimedia-Integration.md` |
| Interactive Report Elements | `Report-Writing-Mastery/34-Interactive-Report-Elements.md` |
| Cross-Platform Compatibility | `Report-Writing-Mastery/35-Cross-Platform-Compatibility.md` |
| Version Control for Reports | `Report-Writing-Mastery/36-Version-Control-for-Reports.md` |
| Report Analytics and Metrics | `Report-Writing-Mastery/37-Report-Analytics-and-Metrics.md` |
| Peer Review Optimization | `Report-Writing-Mastery/38-Peer-Review-Optimization.md` |
| Program Feedback Incorporation | `Report-Writing-Mastery/39-Program-Feedback-Incorporation.md` |
| Continuous Improvement | `Report-Writing-Mastery/40-Continuous-Improvement.md` |
| Report Personalization | `Report-Writing-Mastery/41-Report-Personalization.md` |
| Contextual Intelligence | `Report-Writing-Mastery/42-Contextual-Intelligence.md` |
| Technical Depth Calibration | `Report-Writing-Mastery/43-Technical-Depth-Calibration.md` |
| Impact Visualization | `Report-Writing-Mastery/44-Impact-Visualization.md` |
| Report Archiving Strategy | `Report-Writing-Mastery/45-Report-Archiving-Strategy.md` |
| Collaboration Report Standards | `Report-Writing-Mastery/46-Collaboration-Report-Standards.md` |
| Advanced Proof-of-Concept | `Report-Writing-Mastery/47-Advanced-Proof-of-Concept.md` |
| Report Automation Tools | `Report-Writing-Mastery/48-Report-Automation-Tools.md` |
| Quality Metrics Development | `Report-Writing-Mastery/49-Quality-Metrics-Development.md` |
| Master Report Writing Framework | `Report-Writing-Mastery/50-Master-Report-Writing-Framework.md` |
| Bugcrowd Finding Dissection | `Report-Writing-Mastery/Bugcrowd-Finding-Dissection.md` |
| HackerOne Report Analysis | `Report-Writing-Mastery/HackerOne-Report-Analysis.md` |
| High Severity Vulnerability Analysis | `Report-Writing-Mastery/High-Severity-Vulnerability-Analysis.md` |
| Impact Communication | `Report-Writing-Mastery/Impact-Communication.md` |

## Events

### Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `report.session.created` | session_id, finding_title | New report session created |
| `report.draft.created` | session_id, version | New draft version created |
| `report.draft.updated` | session_id, version | Draft updated |
| `report.review.started` | session_id | Review phase started |
| `report.review.comment` | session_id, comment | Review comment added |
| `report.revision.started` | session_id, revision | Revision started |
| `report.revision.completed` | session_id, revision | Revision completed |
| `report.formatting.applied` | session_id, format | Formatting applied |
| `report.quality.scored` | session_id, scores | Quality assessment completed |
| `report.submitted` | session_id, program | Report submitted |
| `report.program.response` | session_id, response | Program response received |
| `report.session.suspended` | session_id, reason | Session suspended |
| `report.session.resumed` | session_id | Session resumed |
| `report.session.closed` | session_id | Session closed |

## Error Recovery

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| Draft Corruption | File write failure | Restore from last version |
| Review Conflict | Conflicting comments | Prioritize by severity |
| Format Incompatibility | Markdown render issue | Use fallback format |
| State Corruption | Checksum mismatch | Restore from checkpoint |

## Usage Examples

### Creating a Report Session

```python
session = create_report_session(
    name="report-xss-example.com",
    finding={
        "title": "Stored XSS in User Profile",
        "severity": "high",
        "description": "Cross-site scripting vulnerability in...",
        "poc": "steps to reproduce..."
    },
    program="hackerone-example",
    report_type="bug_bounty",
    modules=[
        "01-Report-Structure-Optimization.md",
        "04-Proof-of-Concept-Development.md",
        "07-Executive-Summary-Crafting.md",
        "13-Program-Specific-Formatting.md"
    ]
)
```

### Querying Report Status

```python
sessions = find_report_sessions(
    state="submitted",
    program="hackerone-example"
)
for s in sessions:
    print(f"Finding: {s.finding['title']}, "
          f"Versions: {len(s.draft_versions)}, "
          f"Status: {s.submission_status}")
```
