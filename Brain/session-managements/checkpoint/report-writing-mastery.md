# CHECKPOINT MANAGEMENT — Report Writing Mastery

## Title

Checkpoint Management for Report Writing Mastery Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `report-writing-mastery` |
| Domain Path | `Report-Writing-Mastery/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/report-writing-mastery/` |
| Session Scope | Draft state, template usage, report generation progress |
| Auto-Checkpoint Interval | Every report draft save or 12 minutes |
| Manual Checkpoint Trigger | `/checkpoint save report-writing-mastery [label]` |
| Max Checkpoints Retained | 20 per session |
| Checkpoint TTL | 96 hours (configurable) |
| Restore Command | `/checkpoint restore report-writing-mastery [id]` |

## Overview

This checkpoint management system governs the state of all report writing workflows defined across the 54 files in `Report-Writing-Mastery/`. This domain encompasses the complete report lifecycle — from initial structure through final submission, including technical writing standards, proof-of-concept development, severity assessment, and program-specific formatting. Checkpoints here capture draft state, template configurations, writing progress, and the cumulative report writing knowledge.

Report writing is often the most critical phase of bug bounty hunting — a perfectly found vulnerability with a poorly written report may be rejected or downgraded. The checkpoint system ensures that report drafts, template configurations, and writing progress are preserved across sessions. This is particularly important for reports that require extensive documentation, proof-of-concept development, or multi-day writing effort.

## Auto-Checkpoint Configuration

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: report_draft_saved
      description: "Checkpoint when a report draft is saved"
      events:
        - draft_section_completed
        - draft_revised
        - draft_reviewed
        - draft_approved
    - type: template_event
      description: "Checkpoint on template usage events"
      events:
        - template_loaded
        - template_applied
        - template_modified
        - template_version_changed
    - type: writing_milestone
      description: "Checkpoint at writing milestones"
      events:
        - executive_summary_completed
        - technical_details_completed
        - poc_section_completed
        - remediation_section_completed
        - impact_section_completed
        - report_structure_finalized
    - type: review_event
      description: "Checkpoint during review process"
      events:
        - self_review_completed
        - peer_review_requested
        - peer_review_completed
        - revision_completed
    - type: submission_event
      description: "Checkpoint at submission stages"
      events:
        - report_submitted
        - report_accepted
        - report_rejected
        - report_downgraded
        - report_upgraded
        - reward_received
    - type: time_interval
      description: "Checkpoint every 12 minutes during active writing"
      interval_minutes: 12
```

## Manual Checkpoint

```
manual_checkpoint:
  save_command: "/checkpoint save report-writing-mastery [label]"
  options:
    - include_draft_state: true
    - include_template_config: true
    - include_writing_progress: true
    - include_review_history: true
    - minimal: "draft state only, skip review history"
  special_commands:
    - "/report snapshot": "Capture full report writing state"
    - "/report draft": "Save current draft and checkpoint"
    - "/report review": "Review and checkpoint report state"
    - "/report submit": "Submit report and checkpoint submission state"
```

## Checkpoint Format Schema

```
report_checkpoint:
  envelope:
    magic: "CHKP-REPORT-V1"
    version: "1.0"
    domain: "report-writing-mastery"
  sections:
    - section_id: "report_drafts"
      description: "Active report drafts"
      fields:
        - active_drafts:
          - draft_id: "identifier"
            report_title: "report title"
            vuln_class: "vulnerability class"
            severity: "critical | high | medium | low | informational"
            target: "affected endpoint or component"
            status: "drafting | reviewing | submitted | accepted | rejected"
            created_at: "ISO-8601"
            last_modified: "ISO-8601"
            word_count: "integer"
            sections:
              - section_name: "string"
                status: "not_started | in_progress | completed | reviewed"
                content_summary: "brief summary of section content"
                word_count: "integer"
                last_modified: "ISO-8601"
            template_used: "template_id if applicable"
            poc_status: "not_started | in_progress | completed"
            poc_file: "path to PoC file if exists"
            attachments: "list of attachment paths"
            submission_target: "platform and program"
            submission_status: "not_submitted | submitted | triaging | accepted | rejected"
            submission_date: "ISO-8601 or null"
            triager_feedback: "feedback from triager if any"
            reward_amount: "reward amount if accepted"
    - section_id: "templates"
      description: "Report templates and configurations"
      fields:
        - templates:
          - template_id: "identifier"
            template_name: "string"
            template_type: "bugcrowd | hackerone | intigriti | immunefi | custom"
            source_file: "relative path"
            version: "string"
            last_used: "ISO-8601"
            usage_count: "integer"
            success_rate: "float"
            sections:
              - section_name: "string"
                section_order: "integer"
                required: "boolean"
                default_content: "default section content"
                formatting_rules: "section-specific formatting"
        - active_template: "currently selected template_id"
    - section_id: "writing_knowledge"
      description: "Accumulated writing knowledge and patterns"
      fields:
        - effective_patterns:
          - pattern_id: "identifier"
            pattern_type: "structure | tone | formatting | impact"
            description: "what works well"
            examples: "list of examples"
            success_correlation: "float 0-1"
        - rejection_patterns:
          - pattern_id: "identifier"
            rejection_reason: "why reports get rejected"
            prevention_strategy: "how to avoid this rejection"
            frequency: "how common this rejection is"
        - best_practices:
          - practice_id: "identifier"
            practice: "string"
            context: "when to apply"
            impact_on_quality: "float 0-10"
    - section_id: "writing_progress"
      description: "Overall writing progress metrics"
      fields:
        - total_reports_written: "integer"
        - reports_submitted: "integer"
        - reports_accepted: "integer"
        - acceptance_rate: "float"
        - average_reward: "float"
        - average_word_count: "float"
        - average_writing_time_hours: "float"
        - total_earnings: "float"
    - section_id: "checksum"
      fields:
        - payload_hash: "SHA-256"
        - section_hashes: "per-section SHA-256"
```

## Validation

```
validation_rules:
  pre_checkpoint:
    - rule: "draft_content_coherent"
      description: "Report draft sections are coherent"
      action_on_fail: "reconcile_draft_sections"
    - rule: "template_valid"
      description: "Active template is valid and accessible"
      action_on_fail: "validate_template"
    - rule: "severity_justified"
      description: "Report severity matches impact description"
      action_on_fail: "reassess_severity"
    - rule: "poc_complete"
      description: "Proof-of-concept section is complete if required"
      action_on_fail: "flag_incomplete_poc"
  post_restore:
    - rule: "draft_files_available"
      description: "All draft files are accessible"
      action_on_fail: "restore_missing_drafts"
    - rule: "template_compatible"
      description: "Template is compatible with current platform"
      action_on_fail: "update_template"
    - rule: "submission_deadline_valid"
      description: "Submission deadlines are still valid"
      action_on_fail: "update_deadlines"
```

## Pruning Strategy

```
pruning_strategy:
  retention_policy:
    max_checkpoints: 20
    ttl_hours: 96
    preserve_active_drafts: true
    preserve_submitted_reports: true
    preserve_writing_knowledge: true
  pruning_priority:
    1: "time_interval_checkpoints — routine saves"
    2: "review_event_checkpoints — review records"
    3: "template_event_checkpoints — template changes"
    4: "writing_milestone_checkpoints — milestone records"
    5: "report_draft_saved_checkpoints — draft saves"
    6: "submission_event_checkpoints — submission records"
  special_rules:
    - "Never prune accepted report checkpoints"
    - "Always preserve writing knowledge updates"
    - "Keep submission history for full TTL"
    - "Archive rejected reports after 48 hours"
```

## Checkpoint Index

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "report-writing-mastery"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "user label"
        active_drafts: "integer"
        writing_progress: "float"
        file_path: "relative path"
        checksum: "SHA-256 prefix"
    report_history:
      - report_title: "string"
        vuln_class: "string"
        severity: "string"
        status: "string"
        submitted_at: "ISO-8601 or null"
        accepted: "boolean"
        reward: "float or null"
        checkpoint_id: "reference"
    template_usage:
      - template_name: "string"
        usage_count: "integer"
        success_rate: "float"
        last_used: "ISO-8601"
```

## Restore from Checkpoint

```
restore_procedure:
  steps:
    1: "Load checkpoint index"
    2: "Select target checkpoint"
    3: "Validate draft file availability"
    4: "Restore active report drafts"
    5: "Restore template configurations"
    6: "Restore writing knowledge"
    7: "Restore writing progress metrics"
    8: "Validate draft coherence"
    9: "Resume report writing"
    10: "Log restoration event"
  restore_modes:
    - full: "Restore complete report writing state"
    - drafts_only: "Restore active drafts only"
    - templates_only: "Restore template configurations"
    - knowledge_only: "Restore writing knowledge"
    - from_draft: "Restore specific report draft"
```

## Domain File References

### Report Structure and Writing (01-10)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `01-Report-Structure-Optimization.md` | Stores report structure templates, optimization state |
| 02 | `02-Technical-Writing-Standards.md` | Stores writing standards, style guide state |
| 03 | `03-Private-Program-Case-Study.md` | Stores private program report patterns, case studies |
| 04 | `04-Proof-of-Concept-Development.md` | Stores PoC development state, test case results |
| 05 | `05-Vulnerability-Severity-Assessment.md` | Stores severity assessment models, scoring state |
| 06 | `06-Remediation-Recommendations.md` | Stores remediation templates, recommendation patterns |
| 07 | `07-Executive-Summary-Crafting.md` | Stores executive summary templates, drafting state |
| 08 | `08-Technical-Detail-Balancing.md` | Stores detail balancing rules, audience state |
| 09 | `09-Visual-Aid-Integration.md` | Stores visual aid templates, screenshot state |
| 10 | `10-Code-Sample-Formatting.md` | Stores code formatting rules, formatting state |

### Documentation and Communication (11-20)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 11 | `11-Timeline-Documentation.md` | Stores timeline templates, documentation state |
| 12 | `12-Collaboration-Crediting.md` | Stores crediting rules, collaboration state |
| 13 | `13-Program-Specific-Formatting.md` | Stores program-specific formats, platform state |
| 14 | `14-Language-and-Tone-Optimization.md` | Stores tone guidelines, language optimization state |
| 15 | `15-Attachment-Management.md` | Stores attachment rules, file management state |
| 16 | `16-Follow-up-Communication.md` | Stores follow-up templates, communication state |
| 17 | `17-Rejection-Analysis-and-Improvement.md` | Stores rejection analysis, improvement tracking |
| 18 | `18-Reward-Negotiation-Preparation.md` | Stores negotiation templates, preparation state |
| 19 | `19-Report-Template-Development.md` | Stores custom template development, template state |
| 20 | `20-Quality-Assurance-Process.md` | Stores QA checklists, review process state |

### Quality and Standards (21-30)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 21 | `21-Grammar-and-Style-Standards.md` | Stores grammar rules, style standards state |
| 22 | `22-Technical-Accuracy-Verification.md` | Stores accuracy verification rules, verification state |
| 23 | `23-Impact-Quantification.md` | Stores impact quantification models, scoring state |
| 24 | `24-Business-Context-Integration.md` | Stores business context templates, integration state |
| 25 | `25-Compliance-Documentation.md` | Stores compliance templates, documentation state |
| 26 | `26-International-Standard-Adherence.md` | Stores international standards, adherence state |
| 27 | `27-Audience-Analysis.md` | Stores audience analysis models, targeting state |
| 28 | `28-Information-Hierarchy.md` | Stores information hierarchy rules, structuring state |
| 29 | `29-Actionable-Recommendations.md` | Stores recommendation templates, actionability state |
| 30 | `30-Report-Review-Process.md` | Stores review process, peer review state |

### Advanced Techniques (31-40)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 31 | `31-Common-Pitfalls-Avoidance.md` | Stores pitfall database, avoidance rules state |
| 32 | `32-Advanced-Formatting-Techniques.md` | Stores advanced formatting, formatting state |
| 33 | `33-Multimedia-Integration.md` | Stores multimedia templates, integration state |
| 34 | `34-Interactive-Report-Elements.md` | Stores interactive elements, element state |
| 35 | `35-Cross-Platform-Compatibility.md` | Stores cross-platform rules, compatibility state |
| 36 | `36-Version-Control-for-Reports.md` | Stores version control, report versioning state |
| 37 | `37-Report-Analytics-and-Metrics.md` | Stores analytics tracking, metrics state |
| 38 | `38-Peer-Review-Optimization.md` | Stores peer review optimization, review state |
| 39 | `39-Program-Feedback-Incorporation.md` | Stores feedback integration, incorporation state |
| 40 | `40-Continuous-Improvement.md` | Stores improvement tracking, continuous state |

### Mastery and Framework (41-50)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 41 | `41-Report-Personalization.md` | Stores personalization rules, customization state |
| 42 | `42-Contextual-Intelligence.md` | Stores contextual intelligence, context state |
| 43 | `43-Technical-Depth-Calibration.md` | Stores depth calibration, audience state |
| 44 | `44-Impact-Visualization.md` | Stores impact visualization, chart state |
| 45 | `45-Report-Archiving-Strategy.md` | Stores archiving rules, archive state |
| 46 | `46-Collaboration-Report-Standards.md` | Stores collaboration standards, teamwork state |
| 47 | `47-Advanced-Proof-of-Concept.md` | Stores advanced PoC state, complex test cases |
| 48 | `48-Report-Automation-Tools.md` | Stores automation tool configs, tool state |
| 49 | `49-Quality-Metrics-Development.md` | Stores quality metrics, metric development state |
| 50 | `50-Master-Report-Writing-Framework.md` | Stores master framework, overall writing state |

### Platform-Specific (51-54)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 51 | `Bugcrowd-Finding-Dissection.md` | Stores Bugcrowd-specific patterns, VRT alignment state |
| 52 | `HackerOne-Report-Analysis.md` | Stores HackerOne-specific patterns, report analysis state |
| 53 | `High-Severity-Vulnerability-Analysis.md` | Stores high-severity patterns, severity analysis state |
| 54 | `Impact-Communication.md` | Stores impact communication patterns, messaging state |

## Report Writing State Machine

```
writing_states:
  - NOT_STARTED: "No report draft exists"
  - OUTLINING: "Creating report outline"
  - DRAFTING: "Writing initial draft"
  - REVISING: "Revising draft content"
  - REVIEWING: "Self-review or peer review"
  - POLISHING: "Final polish and formatting"
  - SUBMITTED: "Report submitted to platform"
  - TRIAGING: "Under triage review"
  - ACCEPTED: "Report accepted"
  - REJECTED: "Report rejected"
  - DOWNGRADED: "Severity downgraded"
  - REWARDED: "Reward received"

state_transitions:
  NOT_STARTED -> OUTLINING: "report_initiated"
  OUTLINING -> DRAFTING: "outline_complete"
  DRAFTING -> REVISING: "first_draft_complete"
  REVISING -> REVIEWING: "revision_complete"
  REVIEWING -> POLISHING: "review_approved"
  REVIEWING -> REVISING: "review_feedback_received"
  POLISHING -> SUBMITTED: "final_polish_complete"
  SUBMITTED -> TRIAGING: "platform_received"
  TRIAGING -> ACCEPTED: "triage_approved"
  TRIAGING -> REJECTED: "triage_rejected"
  TRIAGING -> DOWNGRADED: "severity_adjusted"
  ACCEPTED -> REWARDED: "reward_issued"
```

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `core-prompts-hunting` | Findings feed report generation |
| `advanced-chaining-techniques` | Chain results feed report content |
| `real-world-case-studies` | Case patterns inform report structure |
| `bug-bounty-program-strategy` | Program requirements inform report format |
| `high-level-world-case-studies` | Case intelligence informs impact analysis |
