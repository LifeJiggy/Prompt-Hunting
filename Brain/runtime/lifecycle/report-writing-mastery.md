# Report Writing Mastery — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `report-writing-mastery` |
| Domain Path | `Report-Writing-Mastery/` |
| File Count | 54 prompt files |
| Registry | `Report-Writing-Mastery/registry.json` |
| Category | Report Writers |
| Lifecycle Scope | Draft writers, QA checkers, template engines, submission preparers |

## Overview

This document defines the complete process lifecycle management for the Report Writing Mastery domain. The domain encompasses 54 prompt files focused on creating high-quality bug bounty reports, from initial structure through peer review and submission. The lifecycle manages report writing processes that draft, review, revise, and prepare reports for submission to bug bounty programs.

Report writing processes are critical pipeline stages that transform raw vulnerability findings into polished, submission-ready reports. The lifecycle includes states for drafting, peer review, quality assurance, revision, and submission preparation.

## Process State Machine

```
                    +------------------+
                    |                  |
            +------>|    CREATED       |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   INITIALIZING   |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |    DRAFTING      |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   REVIEWING      |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   REVISING       |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   QA_CHECK       |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |  PREPARING       |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            +-------+    COMPLETED     |
            |       |                  |
            |       +------------------+
            |
            | (any) --error--> +-----------+
            |                  |   FAILED  |
            |                  +-----------+
            |                       |
            | (any) --signal--> +---+--------+
            |                   |  STOPPING  |
            |                   +------------+
            |                        |
            |                        v
            +-------------------+----+------+
                                |  STOPPED   |
                                +------------+
```

## State Definitions

### CREATED

Process entry allocated. Report specification loaded.

**Internal data:**
- Process ID assigned
- Vulnerability finding input loaded
- Report template selected
- All 54 file references loaded:
  - `01-Report-Structure-Optimization.md`
  - `02-Technical-Writing-Standards.md`
  - `03-Private-Program-Case-Study.md`
  - `04-Proof-of-Concept-Development.md`
  - `05-Vulnerability-Severity-Assessment.md`
  - `06-Remediation-Recommendations.md`
  - `07-Executive-Summary-Crafting.md`
  - `08-Technical-Detail-Balancing.md`
  - `09-Visual-Aid-Integration.md`
  - `10-Code-Sample-Formatting.md`
  - `11-Timeline-Documentation.md`
  - `12-Collaboration-Crediting.md`
  - `13-Program-Specific-Formatting.md`
  - `14-Language-and-Tone-Optimization.md`
  - `15-Attachment-Management.md`
  - `16-Follow-up-Communication.md`
  - `17-Rejection-Analysis-and-Improvement.md`
  - `18-Reward-Negotiation-Preparation.md`
  - `19-Report-Template-Development.md`
  - `20-Quality-Assurance-Process.md`
  - `21-Grammar-and-Style-Standards.md`
  - `22-Technical-Accuracy-Verification.md`
  - `23-Impact-Quantification.md`
  - `24-Business-Context-Integration.md`
  - `25-Compliance-Documentation.md`
  - `26-International-Standard-Adherence.md`
  - `27-Audience-Analysis.md`
  - `28-Information-Hierarchy.md`
  - `29-Actionable-Recommendations.md`
  - `30-Report-Review-Process.md`
  - `31-Common-Pitfalls-Avoidance.md`
  - `32-Advanced-Formatting-Techniques.md`
  - `33-Multimedia-Integration.md`
  - `34-Interactive-Report-Elements.md`
  - `35-Cross-Platform-Compatibility.md`
  - `36-Version-Control-for-Reports.md`
  - `37-Report-Analytics-and-Metrics.md`
  - `38-Peer-Review-Optimization.md`
  - `39-Program-Feedback-Incorporation.md`
  - `40-Continuous-Improvement.md`
  - `41-Report-Personalization.md`
  - `42-Contextual-Intelligence.md`
  - `43-Technical-Depth-Calibration.md`
  - `44-Impact-Visualization.md`
  - `45-Report-Archiving-Strategy.md`
  - `46-Collaboration-Report-Standards.md`
  - `47-Advanced-Proof-of-Concept.md`
  - `48-Report-Automation-Tools.md`
  - `49-Quality-Metrics-Development.md`
  - `50-Master-Report-Writing-Framework.md`
  - `Bugcrowd-Finding-Dissection.md`
  - `HackerOne-Report-Analysis.md`
  - `High-Severity-Vulnerability-Analysis.md`
  - `Impact-Communication.md`
  - `README.md`

**Exit:** CREATED -> INITIALIZING

### INITIALIZING

Loading report templates, initializing writing engines, preparing QA checklists.

**Sub-steps:**
1. Load `Report-Writing-Mastery/registry.json`
2. Load report structure template: `01-Report-Structure-Optimization.md`
3. Load writing standards: `02-Technical-Writing-Standards.md`
4. Load severity assessment rules: `05-Vulnerability-Severity-Assessment.md`
5. Load remediation templates: `06-Remediation-Recommendations.md`
6. Load QA checklist: `20-Quality-Assurance-Process.md`
7. Load program-specific formatting: `13-Program-Specific-Formatting.md`
8. Initialize PoC development engine: `04-Proof-of-Concept-Development.md`
9. Load platform-specific templates:
   - `Bugcrowd-Finding-Dissection.md` — Bugcrowd format
   - `HackerOne-Report-Analysis.md` — HackerOne format
10. Load impact communication guide: `Impact-Communication.md`
11. Load severity analysis guide: `High-Severity-Vulnerability-Analysis.md`
12. Initialize version control for reports: `36-Version-Control-for-Reports.md`

**Exit:** INITIALIZING -> DRAFTING | INITIALIZING -> FAILED

### DRAFTING

Actively writing report content. Multiple sections drafted in parallel.

**Drafting activities:**
- Title formulation (per formula from `01-Report-Structure-Optimization.md`)
- Executive summary: `07-Executive-Summary-Crafting.md`
- Technical description (balanced per `08-Technical-Detail-Balancing.md`)
- Impact statement: `Impact-Communication.md`, `23-Impact-Quantification.md`
- PoC development: `04-Proof-of-Concept-Development.md`, `47-Advanced-Proof-of-Concept.md`
- Remediation recommendations: `06-Remediation-Recommendations.md`, `29-Actionable-Recommendations.md`
- Code sample formatting: `10-Code-Sample-Formatting.md`
- Visual aid integration: `09-Visual-Aid-Integration.md`, `44-Impact-Visualization.md`
- Timeline documentation: `11-Timeline-Documentation.md`
- Business context: `24-Business-Context-Integration.md`
- Audience analysis: `27-Audience-Analysis.md`
- Information hierarchy: `28-Information-Hierarchy.md`
- Language and tone: `14-Language-and-Tone-Optimization.md`
- Grammar and style: `21-Grammar-and-Style-Standards.md`
- Advanced formatting: `32-Advanced-Formatting-Techniques.md`
- Multimedia integration: `33-Multimedia-Integration.md`
- Interactive elements: `34-Interactive-Report-Elements.md`
- Cross-platform compat: `35-Cross-Platform-Compatibility.md`
- Report personalization: `41-Report-Personalization.md`
- Contextual intelligence: `42-Contextual-Intelligence.md`
- Technical depth calibration: `43-Technical-Depth-Calibration.md`

**Exit:** DRAFTING -> REVIEWING (draft complete) | DRAFTING -> FAILED

### REVIEWING

Peer review of draft report. Multiple reviewers assess different aspects.

**Review aspects:**
- Technical accuracy: `22-Technical-Accuracy-Verification.md`
- Grammar and style: `21-Grammar-and-Style-Standards.md`
- Impact communication: `Impact-Communication.md`
- Severity assessment: `High-Severity-Vulnerability-Analysis.md`
- Common pitfalls: `31-Common-Pitfalls-Avoidance.md`
- Peer review optimization: `38-Peer-Review-Optimization.md`
- Report review process: `30-Report-Review-Process.md`

**Exit:** REVIEWING -> REVISING (review complete) | REVIEWING -> FAILED

### REVISING

Incorporating review feedback into report. Addressing identified issues.

**Revision activities:**
- Fix technical inaccuracies
- Improve language and tone
- Strengthen impact statements
- Add missing details
- Remove unnecessary content
- Improve formatting
- Address reviewer comments

**Exit:** REVISING -> QA_CHECK (revision complete) | REVISING -> REVIEWING (needs another review) | REVISING -> FAILED

### QA_CHECK

Final quality assurance check before submission preparation.

**QA checks (from `20-Quality-Assurance-Process.md`):**
- Completeness check (all sections present)
- Accuracy check (all claims verifiable)
- Consistency check (terminology, formatting)
- Compliance check (program requirements)
- Severity check (appropriate rating)
- Impact check (demonstrated, not theoretical)
- PoC check (reproducible steps)
- Remediation check (actionable recommendations)
- Platform-specific check:
  - Bugcrowd: `Bugcrowd-Finding-Dissection.md`
  - HackerOne: `HackerOne-Report-Analysis.md`
- Quality metrics: `49-Quality-Metrics-Development.md`
- Standards adherence: `26-International-Standard-Adherence.md`
- Compliance documentation: `25-Compliance-Documentation.md`

**Exit:** QA_CHECK -> PREPARING (passed) | QA_CHECK -> REVISING (issues found) | QA_CHECK -> FAILED

### PREPARING

Final preparation for submission. Packaging, formatting, and submission readiness.

**Preparation activities:**
- Final formatting: `32-Advanced-Formatting-Techniques.md`
- Attachment management: `15-Attachment-Management.md`
- Version control: `36-Version-Control-for-Reports.md`
- Submission checklist verification
- Collaboration crediting: `12-Collaboration-Crediting.md`
- Program-specific adjustments: `13-Program-Specific-Formatting.md`
- Report archiving: `45-Report-Archiving-Strategy.md`
- Follow-up preparation: `16-Follow-up-Communication.md`
- Reward negotiation prep: `18-Reward-Negotiation-Preparation.md`
- Rejection handling prep: `17-Rejection-Analysis-and-Improvement.md`
- Program feedback integration: `39-Program-Feedback-Incorporation.md`

**Exit:** PREPARING -> COMPLETED (ready for submission) | PREPARING -> FAILED

### COMPLETED

Report ready for submission. All QA checks passed, all formatting complete.

**Exit:** COMPLETED -> STOPPED

### STOPPING

Graceful shutdown. Report state preserved.

**Exit:** STOPPING -> STOPPED

### STOPPED

Terminal state. All report workers terminated.

## Start Operations

```
1. Receive report writing command with vulnerability finding
2. Transition: CREATED -> INITIALIZING
3. Load templates and standards
4. Initialize writing engines
5. Transition: INITIALIZING -> DRAFTING
6. Draft report sections
7. Transition: DRAFTING -> REVIEWING
8. Peer review
9. Transition: REVIEWING -> REVISING
10. Revise based on feedback
11. Transition: REVISING -> QA_CHECK
12. Final QA check
13. Transition: QA_CHECK -> PREPARING
14. Prepare for submission
15. Transition: PREPARING -> COMPLETED
```

## Stop Operations

```
1. Receive stop signal
2. Transition: CURRENT_STATE -> STOPPING
3. Save current draft
4. Preserve review comments
5. Write progress report
6. Transition: STOPPING -> STOPPED
```

## Graceful Shutdown Protocol

### Phase 1: Draft Save (0-10s)
- Save current draft version
- Preserve all review comments
- Save in-progress sections

### Phase 2: State Persistence (10-30s)
- Write draft to version control
- Save QA checklist progress
- Preserve reviewer feedback

### Phase 3: Resource Release (30-45s)
- Release writing engine resources
- Close collaboration channels
- Write shutdown log

## Signal Handling

| Signal | Handler | Action |
|--------|---------|--------|
| `SIGTERM` | `handle_graceful_shutdown()` | Save draft, release, shutdown |
| `SIGINT` | `handle_graceful_shutdown()` | Same as SIGTERM |
| `SIGHUP` | `handle_template_reload()` | Reload report templates |
| `SIGUSR1` | `handle_draft_dump()` | Dump current draft to log |
| `SIGUSR2` | `handle_qa_force()` | Force QA check on current draft |
| `SIGKILL` | (OS default) | Immediate termination |

## Health Monitoring

| Metric | Description | Alert |
|--------|-------------|-------|
| `current_state` | Report writing state | N/A (info) |
| `draft_sections_complete` | Sections drafted | N/A (info) |
| `review_comments_count` | Review comments | N/A (info) |
| `qa_checks_passed` | QA checks passed | N/A (info) |
| `qa_checks_failed` | QA checks failed | > 0 |
| `revision_count` | Revision cycles | > 3 |
| `memory_usage_mb` | Process memory | > 256 MB |
| `draft_size_kb` | Draft document size | > 500 KB |

## Resource Limits

| Resource | Limit | Action |
|----------|-------|--------|
| Memory | 256 MB | Evict old drafts |
| CPU | 0.5 cores | Throttle rendering |
| Draft file size | 500 KB | Split or compress |
| Review comments | 100 | Archive old comments |
| Version history | 20 versions | Archive old versions |
| Attachment size | 10 MB | Compress or link |

## Domain File References

All 54 files serve as report writing modules. See the state definitions for the complete organized listing.

## Inter-Process Communication

### Message Types

| Message | Producer | Consumer | Description |
|---------|----------|----------|-------------|
| `draft.section` | Draft Writer | Review Workers | Section drafted |
| `review.comment` | Review Workers | Draft Writer | Review feedback |
| `revision.complete` | Draft Writer | QA Checker | Revision done |
| `qa.result` | QA Checker | Draft Writer | QA result |
| `submission.ready` | Preparer | External | Report ready |
| `feedback.received` | External | Feedback Analyzer | Program feedback |

### Report Sections

| Section | Source Files | Writer |
|---------|-------------|--------|
| Title | 01, 13, 14 | Title Formulator |
| Executive Summary | 07, 23, 24 | Summary Writer |
| Technical Description | 02, 08, 22, 43 | Technical Writer |
| Impact Statement | 23, 24, 44 | Impact Writer |
| Proof of Concept | 04, 47 | PoC Developer |
| Remediation | 06, 29 | Remediation Writer |
| Timeline | 11 | Timeline Writer |
| References | 10, 32, 33 | Reference Formatter |

### Report Quality Metrics

| Metric | Target | Description |
|--------|--------|-------------|
| `completeness_score` | > 0.95 | All sections present |
| `technical_accuracy` | > 0.90 | Claims verifiable |
| `impact_demonstration` | > 0.85 | Impact demonstrated |
| `grammar_score` | > 0.95 | Grammar quality |
| `formatting_score` | > 0.90 | Formatting consistency |
| `reproducibility_score` | > 0.95 | PoC reproducible |
| `overall_score` | > 0.90 | Weighted overall |

### Version Control Schema

| Field | Type | Description |
|-------|------|-------------|
| `version_id` | string | Version identifier |
| `report_id` | string | Parent report ID |
| `created_at` | datetime | Creation timestamp |
| `state` | enum | drafting, reviewing, completed |
| `sections` | json | Section content hashes |
| `review_comments` | [json] | Review comments |
| `qa_results` | json | QA check results |

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Report Writing Manager
        |
        +-- Draft Writer
        |     +-- Title Formulator (01, 13, 14)
        |     +-- Executive Summary Writer (07, 23, 24)
        |     +-- Technical Writer (02, 08, 22, 43)
        |     +-- Impact Writer (23, 24, 44)
        |     +-- Remediation Writer (06, 29)
        |     +-- PoC Developer (04, 47)
        |     +-- Timeline Writer (11)
        |     +-- Reference Formatter (10, 32, 33)
        |
        +-- Review Workers
        |     +-- Technical Reviewer (22)
        |     +-- Grammar Reviewer (21)
        |     +-- Impact Reviewer
        |     +-- Severity Reviewer (05)
        |     +-- Peer Reviewer (30, 38)
        |
        +-- QA Checker
        |     +-- Completeness Checker (20)
        |     +-- Accuracy Checker (22)
        |     +-- Compliance Checker (25, 26)
        |     +-- Platform Checker (Bugcrowd, HackerOne)
        |     +-- Quality Metrics Checker (49)
        |
        +-- Submission Preparer
        |     +-- Formatter (32, 34, 35)
        |     +-- Attachment Manager (15)
        |     +-- Version Controller (36)
        |     +-- Archive Manager (45)
        |
        +-- Continuous Improvement
              +-- Feedback Analyzer (17, 39, 40)
              +-- Metrics Collector (37)
              +-- Template Updater (19)
              +-- Personalization Engine (41, 42)
```

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `report.max_revision_cycles` | 3 | Max revision rounds |
| `report.qa_pass_threshold` | 0.9 | QA pass threshold |
| `report.max_draft_size_kb` | 500 | Max draft size |
| `report.auto_format` | true | Auto-format output |
| `report.version_control` | true | Enable version control |
| `report.platform_format` | auto | Platform-specific formatting |
| `report.peer_review_enabled` | true | Enable peer review |
| `report.archiving_enabled` | true | Enable archiving |
| `report.auto_title` | true | Auto-generate title |
| `report.auto_summary` | true | Auto-generate summary |
| `report.max_attachments` | 10 | Max attachments per report |
| `report.attachment_max_size_mb` | 10 | Max attachment size |
