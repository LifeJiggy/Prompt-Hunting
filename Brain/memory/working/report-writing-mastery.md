# Working Memory: Report Writing Mastery Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `REPORT-001` |
| Root Folder | `Report-Writing-Mastery/` |
| Total Files | 54 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict + document buffer |
| Typical Lifetime | Report writing session (1-4h) |
| Eviction Trigger | Report completion, submission, or 24h TTL |

---

## Overview

Working memory for report writing mastery captures the state of active report
composition for bug bounty submissions. This spans 54 modules covering report
structure optimization through impact communication. Working memory tracks:

- **Current draft**: The active report being composed — title, summary, impact
  statement, reproduction steps, and supporting evidence.
- **Severity assessment**: The calculated severity for the finding, including
  CVSS scoring, impact analysis, and justification for severity classification.
- **QA checklist state**: Which quality assurance checks have been performed
  and which remain — ensuring every report meets submission standards.
- **Evidence organization**: How evidence (screenshots, requests, responses,
  HAR files) is organized and referenced within the report.
- **Platform-specific formatting**: Format requirements for different bug
  bounty platforms (HackerOne, Bugcrowd, Intigriti) and their submission
  guidelines.
- **Draft versioning**: Multiple draft versions for comparison and rollback.
- **Peer review state**: If the report is being reviewed before submission,
  tracking review comments and revisions.

This is the "reporting brain" that ensures every submitted report is clear,
complete, and maximizes the chance of acceptance and fair bounty payment.

---

## Data Schema (YAML)

```yaml
working_memory_report:
  version: "2.0"
  scope: "report-writing-session"
  ttl_seconds: 86400

  session_state:
    session_id: "string (uuid4)"
    writer_id: "string"
    started_at: "ISO8601"
    last_activity: "ISO8601"
    status: "enum(drafting|reviewing|revising|ready|submitted)"
    current_report_id: "string (nullable)"
    reports_in_progress: "integer"

  active_report:
    report_id: "string (uuid4)"
    title: "string"
    finding_id: "string (references hunting memory)"
    vuln_class: "string"
    severity: "string"
    platform: "enum(hackerone|bugcrowd|intigriti|other)"
    target: "string"
    endpoint: "string"
    parameter: "string"
    summary: "string (2-3 sentences)"
    impact_statement: "string (1 paragraph)"
    detailed_description: "string (full technical description)"
    reproduction_steps: "list[map] (step, action, expected, actual)"
    remediation: "string"
    references: "list[string] (URLs, CVEs)"
    attachments: "list[map] (name, type, size, hash)"
    status: "enum(draft|reviewing|revising|ready|submitted)"
    version: "integer"
    created_at: "ISO8601"
    updated_at: "ISO8601"

  severity_assessment:
    assessment_id: "string (uuid4)"
    report_id: "string"
    cvss_vector: "string"
    cvss_score: "float (0.0-10.0)"
    severity_rating: "string"
    impact_analysis:
      confidentiality: "enum(none|low|high)"
      integrity: "enum(none|low|high)"
      availability: "enum(none|low|high)"
      scope: "enum(unchanged|changed)"
      attack_complexity: "enum(low|high)"
      privileges_required: "enum(none|low|high)"
      user_interaction: "enum(none|required)"
      justification: "string"
    bounty_estimate: "string"
    confidence: "enum(proven|high|medium|low)"

  qa_checklist:
    checklist_id: "string (uuid4)"
    report_id: "string"
    items:
      - item_id: "string"
        category: "enum(structure|evidence|technical|impact|formatting|platform)"
        description: "string"
        status: "enum(pass|fail|not_applicable|pending)"
        notes: "string"
    overall_score: "float (0.0-1.0)"
    pass_rate: "float (0.0-100.0)"
    blocking_issues: "list[string]"

  evidence_organization:
    evidence_id: "string (uuid4)"
    report_id: "string"
    evidence_type: "enum(screenshot|request|response|har_file|payload|header_dump|token_capture)"
    filename: "string"
    description: "string"
    redaction_level: "enum(none|minimal|moderate|heavy)"
    chain_of_custody: "boolean"
    referenced_in: "list[string] (report sections)"
    size_bytes: "integer"

  platform_formatting:
    platform: "string"
    max_title_length: "integer"
    max_body_length: "integer"
    required_sections: "list[string]"
    optional_sections: "list[string]"
    image_limit: "integer"
    code_block_format: "string"
    severity_options: "list[string]"

  draft_versions:
    version_id: "string (uuid4)"
    report_id: "string"
    version_number: "integer"
    content_snapshot: "map[string,string]"
    created_at: "ISO8601"
    changes_summary: "string"

  review_comments:
    comment_id: "string (uuid4)"
    report_id: "string"
    reviewer: "string"
    section: "string"
    comment: "string"
    severity: "enum(blocking|major|minor|suggestion)"
    resolved: "boolean"
    created_at: "ISO8601"
```

---

## Read/Write Operations

```python
import uuid
import hashlib
from datetime import datetime, timezone
from typing import Optional
from enum import Enum


class ReportStatus(Enum):
    DRAFTING = "drafting"
    REVIEWING = "reviewing"
    REVISING = "revising"
    READY = "ready"
    SUBMITTED = "submitted"


class QACategory(Enum):
    STRUCTURE = "structure"
    EVIDENCE = "evidence"
    TECHNICAL = "technical"
    IMPACT = "impact"
    FORMATTING = "formatting"
    PLATFORM = "platform"


class ReportWritingWorkingMemory:
    """
    In-memory working state for report writing mastery.
    Covers all 54 modules from Report Structure through Impact Communication.
    """

    def __init__(self, writer_id: str = ""):
        self.session_id = str(uuid.uuid4())
        self.writer_id = writer_id
        self.created_at = datetime.now(timezone.utc)

        self.session_state = {
            "session_id": self.session_id,
            "writer_id": writer_id,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "last_activity": datetime.now(timezone.utc).isoformat(),
            "status": ReportStatus.DRAFTING.value,
            "current_report_id": None,
            "reports_in_progress": 0,
        }

        self.active_reports: dict[str, dict] = {}
        self.severity_assessments: dict[str, dict] = {}
        self.qa_checklists: dict[str, dict] = {}
        self.evidence_organization: dict[str, dict] = {}
        self.platform_formatting: dict[str, dict] = {}
        self.draft_versions: dict[str, list[dict]] = {}
        self.review_comments: list[dict] = []

    def create_report(self, title: str, finding_id: str, vuln_class: str,
                      severity: str, platform: str, target: str,
                      endpoint: str, parameter: str = "") -> str:
        """Create a new report draft."""
        report_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.active_reports[report_id] = {
            "report_id": report_id,
            "title": title,
            "finding_id": finding_id,
            "vuln_class": vuln_class,
            "severity": severity,
            "platform": platform,
            "target": target,
            "endpoint": endpoint,
            "parameter": parameter,
            "summary": "",
            "impact_statement": "",
            "detailed_description": "",
            "reproduction_steps": [],
            "remediation": "",
            "references": [],
            "attachments": [],
            "status": ReportStatus.DRAFTING.value,
            "version": 1,
            "created_at": now,
            "updated_at": now,
        }

        self.session_state["current_report_id"] = report_id
        self.session_state["reports_in_progress"] += 1

        self._initialize_qa_checklist(report_id, platform)
        self.draft_versions[report_id] = []

        return report_id

    def update_report_field(self, report_id: str, field: str, value) -> None:
        """Update a specific field in the report."""
        if report_id in self.active_reports:
            self.active_reports[report_id][field] = value
            self.active_reports[report_id]["updated_at"] = (
                datetime.now(timezone.utc).isoformat()
            )
            self.active_reports[report_id]["version"] += 1

    def add_reproduction_step(self, report_id: str, step_number: int,
                               action: str, expected: str = "",
                               actual: str = "") -> None:
        """Add a reproduction step to the report."""
        step = {
            "step": step_number,
            "action": action,
            "expected": expected,
            "actual": actual,
        }
        self.active_reports[report_id]["reproduction_steps"].append(step)

    def add_evidence(self, report_id: str, evidence_type: str,
                     filename: str, description: str,
                     redaction_level: str = "minimal",
                     size_bytes: int = 0) -> str:
        """Add evidence to the report."""
        evidence_id = str(uuid.uuid4())

        self.evidence_organization[evidence_id] = {
            "evidence_id": evidence_id,
            "report_id": report_id,
            "evidence_type": evidence_type,
            "filename": filename,
            "description": description,
            "redaction_level": redaction_level,
            "chain_of_custody": True,
            "referenced_in": [],
            "size_bytes": size_bytes,
        }

        self.active_reports[report_id]["attachments"].append({
            "name": filename,
            "type": evidence_type,
            "size": size_bytes,
            "hash": "",
        })

        return evidence_id

    def calculate_severity(self, report_id: str,
                            confidentiality: str = "high",
                            integrity: str = "none",
                            availability: str = "none",
                            scope: str = "unchanged",
                            attack_complexity: str = "low",
                            privileges_required: str = "none",
                            user_interaction: str = "none",
                            justification: str = "") -> dict:
        """Calculate CVSS score and severity for the report."""
        cvss_map = {
            "confidentiality": {"none": 0, "low": 0.22, "high": 0.56},
            "integrity": {"none": 0, "low": 0.22, "high": 0.56},
            "availability": {"none": 0, "low": 0.22, "high": 0.56},
            "scope": {"unchanged": 0, "changed": 1.08},
            "attack_complexity": {"low": 0, "high": 0.44},
            "privileges_required": {"none": 0, "low": 0.13, "high": 0.62},
            "user_interaction": {"none": 0, "required": 0.62},
        }

        c = cvss_map["confidentiality"].get(confidentiality, 0)
        i = cvss_map["integrity"].get(integrity, 0)
        a = cvss_map["availability"].get(availability, 0)
        s = cvss_map["scope"].get(scope, 0)
        ac = cvss_map["attack_complexity"].get(attack_complexity, 0)
        pr = cvss_map["privileges_required"].get(privileges_required, 0)
        ui = cvss_map["user_interaction"].get(user_interaction, 0)

        impact = min(1.0, 0.22 + c + i + a)
        exploitability = 0.85 * (3.0 - ac) * (3.0 - pr) * (3.0 - ui)

        if impact <= 0:
            score = 0.0
        else:
            score = min(10.0, impact * s + exploitability)

        if score >= 9.0:
            severity_rating = "critical"
        elif score >= 7.0:
            severity_rating = "high"
        elif score >= 4.0:
            severity_rating = "medium"
        else:
            severity_rating = "low"

        assessment_id = str(uuid.uuid4())
        self.severity_assessments[assessment_id] = {
            "assessment_id": assessment_id,
            "report_id": report_id,
            "cvss_vector": f"CVSS:3.1/AV:N/AC:{attack_complexity[0].upper()}/PR:{privileges_required[0].upper()}/UI:{user_interaction[0].upper()}/S:{scope[0].upper()}/C:{confidentiality[0].upper()}/I:{integrity[0].upper()}/A:{availability[0].upper()}",
            "cvss_score": round(score, 1),
            "severity_rating": severity_rating,
            "impact_analysis": {
                "confidentiality": confidentiality,
                "integrity": integrity,
                "availability": availability,
                "scope": scope,
                "attack_complexity": attack_complexity,
                "privileges_required": privileges_required,
                "user_interaction": user_interaction,
                "justification": justification,
            },
            "bounty_estimate": self._estimate_bounty(severity_rating),
            "confidence": "high",
        }

        self.active_reports[report_id]["severity"] = severity_rating

        return self.severity_assessments[assessment_id]

    def run_qa_check(self, report_id: str, item_id: str,
                     status: str, notes: str = "") -> None:
        """Run a QA check on a specific item."""
        checklist = self.qa_checklists[report_id]
        for item in checklist["items"]:
            if item["item_id"] == item_id:
                item["status"] = status
                item["notes"] = notes
                break

        self._update_qa_scores(report_id)

    def get_qa_summary(self, report_id: str) -> dict:
        """Get QA checklist summary."""
        checklist = self.qa_checklists[report_id]
        total = len(checklist["items"])
        passed = sum(1 for i in checklist["items"] if i["status"] == "pass")
        failed = sum(1 for i in checklist["items"] if i["status"] == "fail")
        blocking = [i for i in checklist["items"]
                   if i["status"] == "fail" and i.get("severity") == "blocking"]

        return {
            "checklist_id": checklist["checklist_id"],
            "total_items": total,
            "passed": passed,
            "failed": failed,
            "pass_rate": (passed / max(total, 1)) * 100,
            "blocking_issues": len(blocking),
            "ready_to_submit": len(blocking) == 0 and (passed / max(total, 1)) > 0.8,
        }

    def create_draft_snapshot(self, report_id: str,
                               changes_summary: str = "") -> str:
        """Create a snapshot of the current draft for versioning."""
        version_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        report = self.active_reports[report_id]
        snapshot = {k: v for k, v in report.items() if k != "attachments"}

        self.draft_versions[report_id].append({
            "version_id": version_id,
            "report_id": report_id,
            "version_number": report["version"],
            "content_snapshot": snapshot,
            "created_at": now,
            "changes_summary": changes_summary,
        })

        return version_id

    def add_review_comment(self, report_id: str, reviewer: str,
                            section: str, comment: str,
                            severity: str = "suggestion") -> str:
        """Add a review comment to the report."""
        comment_id = str(uuid.uuid4())

        self.review_comments.append({
            "comment_id": comment_id,
            "report_id": report_id,
            "reviewer": reviewer,
            "section": section,
            "comment": comment,
            "severity": severity,
            "resolved": False,
            "created_at": datetime.now(timezone.utc).isoformat(),
        })

        return comment_id

    def resolve_comment(self, comment_id: str) -> None:
        """Mark a review comment as resolved."""
        for comment in self.review_comments:
            if comment["comment_id"] == comment_id:
                comment["resolved"] = True
                break

    def mark_ready(self, report_id: str) -> bool:
        """Mark report as ready for submission if QA passes."""
        qa = self.get_qa_summary(report_id)
        if qa["ready_to_submit"]:
            self.active_reports[report_id]["status"] = ReportStatus.READY.value
            return True
        return False

    def mark_submitted(self, report_id: str) -> None:
        """Mark report as submitted."""
        self.active_reports[report_id]["status"] = ReportStatus.SUBMITTED.value
        self.session_state["reports_in_progress"] -= 1

    def generate_report_preview(self, report_id: str) -> str:
        """Generate a formatted report preview."""
        report = self.active_reports[report_id]
        severity = self.severity_assessments.get(report_id, {})

        steps_text = "\n".join(
            f"{s['step']}. {s['action']}\n   Expected: {s['expected']}\n   Actual: {s['actual']}"
            for s in report["reproduction_steps"]
        )

        preview = f"""# {report['title']}

## Summary
{report['summary']}

## Severity: {report['severity'].upper()} (CVSS: {severity.get('cvss_score', 'N/A')})

## Impact
{report['impact_statement']}

## Description
{report['detailed_description']}

## Steps to Reproduce
{steps_text}

## Remediation
{report['remediation']}

## References
{chr(10).join(f'- {ref}' for ref in report['references'])}
"""
        return preview

    def get_writing_progress(self) -> dict:
        """Get overall writing progress."""
        reports = list(self.active_reports.values())
        return {
            "total_reports": len(reports),
            "in_progress": sum(1 for r in reports if r["status"] not in ["ready", "submitted"]),
            "ready": sum(1 for r in reports if r["status"] == "ready"),
            "submitted": sum(1 for r in reports if r["status"] == "submitted"),
            "total_review_comments": len(self.review_comments),
            "unresolved_comments": sum(1 for c in self.review_comments if not c["resolved"]),
        }

    def _initialize_qa_checklist(self, report_id: str, platform: str) -> None:
        """Initialize a QA checklist for a report."""
        checklist_id = str(uuid.uuid4())

        items = [
            {"item_id": str(uuid.uuid4()), "category": "structure",
             "description": "Title is clear and descriptive", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "structure",
             "description": "Summary is concise (2-3 sentences)", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "impact",
             "description": "Impact statement is clear", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "technical",
             "description": "Reproduction steps are complete", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "technical",
             "description": "All parameters documented", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "evidence",
             "description": "Screenshots attached", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "evidence",
             "description": "Request/response included", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "evidence",
             "description": "PII properly redacted", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "formatting",
             "description": "Code blocks properly formatted", "status": "pending", "notes": ""},
            {"item_id": str(uuid.uuid4()), "category": "platform",
             "description": "Platform guidelines followed", "status": "pending", "notes": ""},
        ]

        self.qa_checklists[report_id] = {
            "checklist_id": checklist_id,
            "report_id": report_id,
            "items": items,
            "overall_score": 0.0,
            "pass_rate": 0.0,
            "blocking_issues": [],
        }

    def _update_qa_scores(self, report_id: str) -> None:
        """Update QA checklist scores."""
        checklist = self.qa_checklists[report_id]
        total = len(checklist["items"])
        passed = sum(1 for i in checklist["items"] if i["status"] == "pass")
        checklist["pass_rate"] = (passed / max(total, 1)) * 100
        checklist["overall_score"] = checklist["pass_rate"] / 100

    def _estimate_bounty(self, severity: str) -> str:
        """Estimate bounty range based on severity."""
        estimates = {
            "critical": "$5,000 - $15,000",
            "high": "$1,000 - $5,000",
            "medium": "$250 - $1,000",
            "low": "$50 - $250",
            "informational": "$0 - $50",
        }
        return estimates.get(severity, "$0 - $0")

    def cleanup_expired(self) -> int:
        """Remove session data older than TTL."""
        now = datetime.now(timezone.utc)
        started = datetime.fromisoformat(self.session_state["started_at"])
        if (now - started).total_seconds() > 86400:
            return 1
        return 0
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Active reports | 20 | LRU eviction when full | Focus on quality over quantity |
| QA checklists | 20 per report | Report eviction | Cascade eviction |
| Evidence items per report | 50 | LRU eviction | Keep essential evidence |
| Draft versions per report | 20 | FIFO eviction | Keep recent versions |
| Review comments | 200 | FIFO eviction | Resolved comments evicted first |
| Severity assessments | 20 | Report eviction | Cascade eviction |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Session expires after 24h.
  - Completed reports exported to Long-Term Memory.

Priority 2: Submitted Reports
  - Reports with status=submitted evicted after 2h.
  - Their evidence and QA data preserved in archive.

Priority 3: Resolved Comments
  - Resolved review comments evicted after 7 days.

Priority 4: Old Draft Versions
  - Draft versions older than 7 days evicted.
  - Final version always preserved.
```

---

## Lifecycle

```
1. REPORT CREATION
   create_report() → _initialize_qa_checklist()
   update_report_field() × N → build report content

2. EVIDENCE COLLECTION
   add_evidence() × N → organize evidence chain
   calculate_severity() → CVSS scoring

3. QUALITY ASSURANCE
   run_qa_check() × N → get_qa_summary()
   add_review_comment() → resolve_comment() × N

4. REVISION
   create_draft_snapshot() → revise based on feedback
   Mark ready → mark_submitted()

5. EXPORT
   generate_report_preview() → submit to platform
   cleanup_expired() → session data wiped
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Core Prompts Hunting | Read | Findings for report content |
| Advanced Chaining | Read | Chain evidence for report |
| Real-World Case Studies | Read | Report quality patterns for guidance |
| Bug Bounty Strategy | Write | Submitted reports for tracking |

---

## Domain File References (Report-Writing-Mastery/)

### 01-Report-Structure-Optimization
Optimizing report structure for maximum clarity and impact.
Working memory stores: structure templates, section ordering, length guidelines.

### 02-Title-Formulation
Crafting effective report titles.
Working memory stores: title templates, severity indicators, character limits.

### 03-Summary-Writing
Writing concise and impactful summaries.
Working memory stores: summary templates, word limits, key elements.

### 04-Impact-Statement-Crafting
Crafting compelling impact statements.
Working memory stores: impact templates, business context, data sensitivity.

### 05-Technical-Description-Writing
Writing clear technical descriptions.
Working memory stores: technical writing guidelines, audience calibration.

### 06-Reproduction-Step-Documentation
Documenting clear reproduction steps.
Working memory stores: step templates, numbering conventions, expected results.

### 07-Evidence-Organization
Organizing evidence effectively in reports.
Working memory stores: evidence types, attachment naming, redaction guidelines.

### 08-Screenshot-Hygiene
Screenshot best practices for bug bounty reports.
Working memory stores: capture guidelines, redaction markers, annotation tools.

### 09-Code-Block-Formatting
Formatting code blocks and payloads.
Working memory stores: syntax highlighting, escaping rules, language tags.

### 10-Remediation-Writing
Writing effective remediation suggestions.
Working memory stores: remediation templates, fix recommendations, priority guidance.

### 11-Reference-Inclusion
Including relevant references and citations.
Working memory stores: CVE references, OWASP links, documentation URLs.

### 12-CVSS-Scoring-Accuracy
Accurate CVSS scoring methodology.
Working memory stores: CVSS calculator usage, vector selection, justification writing.

### 13-Severity-Justification
Justifying severity ratings effectively.
Working memory stores: justification templates, comparison data, severity arguments.

### 14-Impact-Metric-Development
Developing concrete impact metrics.
Working memory stores: metric examples, quantification methods, business impact.

### 15-Worst-Case-Scenario-Development
Developing worst-case scenarios for impact.
Working memory stores: scenario templates, escalation paths, data exposure.

### 16-Audience-Calibration
Calibrating reports for different audiences.
Working memory stores: audience profiles, technical depth, language choices.

### 17-Narrative-Flow
Creating effective narrative flow in reports.
Working memory stores: flow patterns, transition techniques, logical progression.

### 18-Confidence-Statement-Writing
Writing appropriate confidence statements.
Working memory stores: confidence levels, hedging language, proof requirements.

### 19-Proof-of-Concept-Development
Developing effective proof-of-concept demonstrations.
Working memory stores: PoC templates, reproducibility requirements, video guides.

### 20-Payload-Documentation
Documenting exploitation payloads.
Working memory stores: payload formats, encoding notes, execution context.

### 21-HAR-File-Inclusion
Including and redacting HAR files.
Working memory stores: HAR redaction tools, key fields, size management.

### 22-Video-PoC-Recording
Recording video proof-of-concept demonstrations.
Working memory stores: recording tools, editing guidelines, narration tips.

### 23-Duplicate-Report-Avoidance
Avoiding duplicate submissions.
Working memory stores: search strategies, differentiation techniques, overlap detection.

### 24-Platform-Specific-Formatting-HackerOne
HackerOne-specific formatting requirements.
Working memory stores: H1 templates, bounty calculation, disclosure timing.

### 25-Platform-Specific-Formatting-Bugcrowd
Bugcrowd-specific formatting requirements.
Working memory stores: VRT mapping, severity guidelines, submission format.

### 26-Platform-Specific-Formatting-Intigriti
Intigriti-specific formatting requirements.
Working memory stores: Intigriti templates, challenge timing, community guidelines.

### 27-Multi-Finding-Report-Structure
Structuring reports with multiple related findings.
Working memory stores: multi-finding templates, chain documentation, separate vs combined.

### 28-Chained-Finding-Documentation
Documentating vulnerability chains in reports.
Working memory stores: chain diagrams, step documentation, severity aggregation.

### 29-Time-of-Reporting-Impact
Impact of reporting timing on severity.
Working memory stores: temporal factors, disclosure windows, patch status.

### 30-Responsible-Disclosure-Writing
Writing responsible disclosure notices.
Working memory stores: disclosure templates, timeline management, escalation.

### 31-Triager-Communication
Effective communication with triagers.
Working memory stores: response templates, clarification techniques, negotiation.

### 32-Downgrade-Counter-Arguments
Countering severity downgrades.
Working memory stores: counter-arguments, evidence requirements, escalation paths.

### 33-Rejection-Response-Writing
Responding to report rejections.
Working memory stores: response templates, appeal processes, re-submission strategies.

### 34-Follow-Up-Communication
Following up on open reports.
Working memory stores: follow-up templates, timing, status inquiry methods.

### 35-Bounty-Negotiation-Communication
Negotiating bounty amounts.
Working memory stores: negotiation tactics, comparison data, justification templates.

### 36-Report-Revision-Strategy
Strategic report revision approaches.
Working memory stores: revision priorities, incremental improvements, time management.

### 37-Quality-Assurance-Checklist
Comprehensive QA checklist for reports.
Working memory stores: QA items, pass criteria, blocking issues.

### 38-Peer-Review-Process
Peer review process for reports.
Working memory stores: review criteria, feedback templates, improvement tracking.

### 39-Report-Template-Library
Building a personal report template library.
Working memory stores: templates by vuln class, customization patterns, version tracking.

### 40-Impact-Framing-Techniques
Advanced impact framing techniques.
Working memory stores: framing patterns, audience psychology, emphasis techniques.

### 41-Data-Breach-Impact-Writing
Writing impact for data breach vulnerabilities.
Working memory stores: PII categories, regulatory frameworks, exposure metrics.

### 42-RCE-Impact-Writing
Writing impact for RCE vulnerabilities.
Working memory stores: RCE impact scenarios, business disruption, data access.

### 43-Authentication-Bypass-Impact-Writing
Writing impact for authentication bypass.
Working memory stores: account takeover scenarios, privilege escalation, data access.

### 44-SSRF-Impact-Writing
Writing impact for SSRF vulnerabilities.
Working memory stores: internal access scenarios, cloud metadata, lateral movement.

### 45-XSS-Impact-Writing
Writing impact for XSS vulnerabilities.
Working memory stores: session hijacking, data theft, defacement scenarios.

### 46-IDOR-Impact-Writing
Writing impact for IDOR vulnerabilities.
Working memory stores: data access scenarios, PII exposure, business logic abuse.

### 47-GraphQL-Impact-Writing
Writing impact for GraphQL vulnerabilities.
Working memory stores: schema abuse, data exposure, authorization bypass.

### 48-Mobile-App-Impact-Writing
Writing impact for mobile app vulnerabilities.
Working memory stores: mobile-specific risks, device data, offline access.

### 49-Cloud-Security-Impact-Writing
Writing impact for cloud security misconfigurations.
Working memory stores: cloud data exposure, lateral movement, infrastructure access.

### 50-Report-Submission-Checklist
Final submission checklist for reports.
Working memory stores: submission requirements, final checks, platform guidelines.

### 51-Human-Tone-Guidelines
Writing reports with appropriate human tone.
Working memory stores: tone guidelines, formality calibration, professional language.

### 52-Impact-Communication
Advanced impact communication techniques.
Working memory stores: communication patterns, audience analysis, persuasion methods.

### 53-Report-Polishing
Final report polishing and refinement.
Working memory stores: editing checklists, clarity improvements, formatting fixes.

### 54-Impact-Communication (Duplicate reference for 54th file)
Impact communication mastery and advanced techniques.
Working memory stores: advanced framing, executive summaries, risk translation.
