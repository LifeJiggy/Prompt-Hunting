# State Persistence: Report Writing Mastery Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Report Writing Mastery |
| **Directory** | `Report-Writing-Mastery/` |
| **File Count** | 54 files (50 numbered + 4 special) + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/report-writing-mastery.md` |
| **Serialization** | JSON (primary), MessagePack (draft stream), Protobuf (report archive) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the Report Writing Mastery domain. This domain contains 54 specialized report-writing modules covering every aspect of bug bounty report creation — from structure and severity assessment through PoC development, technical writing, program-specific formatting, and submission optimization.

The persistence layer captures draft states, report versioning, template usage, quality metrics, submission history, and feedback analysis. Report persistence is critical because reports are the primary deliverable — they directly determine reward outcomes.

---

## 2. Domain File Registry

All 54 domain files organized by report category:

### Report Structure and Foundation
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 01 | `01-Report-Structure-Optimization.md` | Structure | Persistent |
| 02 | `02-Technical-Writing-Standards.md` | Writing standards | Reference |
| 03 | `03-Private-Program-Case-Study.md` | Private program | Reference |

### PoC and Severity
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 04 | `04-Proof-of-Concept-Development.md` | PoC dev | Runtime |
| 05 | `05-Vulnerability-Severity-Assessment.md` | Severity assessment | Runtime |
| 06 | `06-Remediation-Recommendations.md` | Remediation | Runtime |

### Report Sections
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 07 | `07-Executive-Summary-Crafting.md` | Executive summary | Runtime |
| 08 | `08-Technical-Detail-Balancing.md` | Technical detail | Runtime |
| 09 | `09-Visual-Aid-Integration.md` | Visual aids | Runtime |
| 10 | `10-Code-Sample-Formatting.md` | Code samples | Runtime |
| 11 | `11-Timeline-Documentation.md` | Timeline | Runtime |
| 12 | `12-Collaboration-Crediting.md` | Credits | Runtime |
| 13 | `13-Program-Specific-Formatting.md` | Program formatting | Runtime |

### Language and Communication
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 14 | `14-Language-and-Tone-Optimization.md` | Language/tone | Runtime |
| 15 | `15-Attachment-Management.md` | Attachments | Runtime |
| 16 | `16-Follow-up-Communication.md` | Follow-up | Runtime |

### Quality and Improvement
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 17 | `17-Rejection-Analysis-and-Improvement.md` | Rejection analysis | Persistent |
| 18 | `18-Reward-Negotiation-Preparation.md` | Negotiation | Runtime |
| 19 | `19-Report-Template-Development.md` | Templates | Persistent |
| 20 | `20-Quality-Assurance-Process.md` | QA process | Runtime |

### Standards and Compliance
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 21 | `21-Grammar-and-Style-Standards.md` | Grammar/style | Reference |
| 22 | `22-Technical-Accuracy-Verification.md` | Accuracy check | Runtime |
| 23 | `23-Impact-Quantification.md` | Impact metrics | Runtime |
| 24 | `24-Business-Context-Integration.md` | Business context | Runtime |
| 25 | `25-Compliance-Documentation.md` | Compliance | Runtime |
| 26 | `26-International-Standard-Adherence.md` | Int'l standards | Reference |

### Audience and Communication
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 27 | `27-Audience-Analysis.md` | Audience analysis | Runtime |
| 28 | `28-Information-Hierarchy.md` | Info hierarchy | Runtime |
| 29 | `29-Actionable-Recommendations.md` | Recommendations | Runtime |
| 30 | `30-Report-Review-Process.md` | Review process | Runtime |
| 31 | `31-Common-Pitfalls-Avoidance.md` | Pitfall avoidance | Reference |

### Advanced Formatting
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 32 | `32-Advanced-Formatting-Techniques.md` | Formatting | Runtime |
| 33 | `33-Multimedia-Integration.md` | Multimedia | Runtime |
| 34 | `34-Interactive-Report-Elements.md` | Interactive elements | Runtime |
| 35 | `35-Cross-Platform-Compatibility.md` | Compatibility | Runtime |
| 36 | `36-Version-Control-for-Reports.md` | Version control | Persistent |

### Analytics and Metrics
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 37 | `37-Report-Analytics-and-Metrics.md` | Analytics | Persistent |
| 38 | `38-Peer-Review-Optimization.md` | Peer review | Runtime |
| 39 | `39-Program-Feedback-Incorporation.md` | Feedback | Persistent |
| 40 | `40-Continuous-Improvement.md` | Improvement | Persistent |

### Personalization and Context
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 41 | `41-Report-Personalization.md` | Personalization | Runtime |
| 42 | `42-Contextual-Intelligence.md` | Context intelligence | Runtime |
| 43 | `43-Technical-Depth-Calibration.md` | Depth calibration | Runtime |
| 44 | `44-Impact-Visualization.md` | Impact viz | Runtime |

### Archive and Collaboration
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| 45 | `45-Report-Archiving-Strategy.md` | Archive strategy | Persistent |
| 46 | `46-Collaboration-Report-Standards.md` | Collab standards | Reference |
| 47 | `47-Advanced-Proof-of-Concept.md` | Advanced PoC | Runtime |
| 48 | `48-Report-Automation-Tools.md` | Automation tools | Runtime |
| 49 | `49-Quality-Metrics-Development.md` | Quality metrics | Persistent |
| 50 | `50-Master-Report-Writing-Framework.md` | Master framework | Persistent |

### Special Analysis Files
| # | File | Report Category | State Type |
|---|------|----------------|-----------|
| — | `Bugcrowd-Finding-Dissection.md` | Bugcrowd analysis | Reference |
| — | `HackerOne-Report-Analysis.md` | HackerOne analysis | Reference |
| — | `High-Severity-Vulnerability-Analysis.md` | High severity | Reference |
| — | `Impact-Communication.md` | Impact communication | Reference |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Draft State)

```json
{
  "schema_version": "1.0.0",
  "domain": "report-writing-mastery",
  "session_id": "sess_w1w2x3y4z5",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "active_drafts": {
    "draft_001": {
      "finding_id": "f_001",
      "title": "Stored XSS in User Profile Bio Field",
      "platform": "hackerone",
      "program": "Example Corp",
      "severity": "HIGH",
      "status": "drafting",
      "version": 3,
      "created_at": "2026-06-25T10:00:00.000Z",
      "updated_at": "2026-06-26T11:00:00.000Z",
      "sections": {
        "title": {"status": "complete", "content": "Stored XSS in User Profile Bio Field"},
        "severity": {"status": "complete", "content": "HIGH"},
        "summary": {"status": "complete", "content": "A stored XSS vulnerability..."},
        "description": {"status": "complete", "content": "When a user updates..."},
        "impact": {"status": "in_progress", "content": ""},
        "poc": {"status": "complete", "content": "1. Login as user A..."},
        "remediation": {"status": "pending", "content": ""},
        "timeline": {"status": "complete", "content": "2026-06-25: Discovery..."}
      },
      "completeness_percent": 75.0,
      "quality_score": null,
      "attachments": [
        {
          "type": "screenshot",
          "filename": "xss_proof.png",
          "description": "XSS alert dialog in browser"
        },
        {
          "type": "har",
          "filename": "request_har.har",
          "description": "HTTP request/response showing payload"
        }
      ]
    }
  },
  "submission_history": {
    "total_submitted": 45,
    "by_status": {
      "triaging": 3,
      "triaged": 5,
      "resolved": 32,
      "informative": 3,
      "duplicate": 1,
      "not_applicable": 1
    },
    "by_severity_submitted": {
      "CRITICAL": 2,
      "HIGH": 15,
      "MEDIUM": 22,
      "LOW": 6
    },
    "by_severity_paid": {
      "CRITICAL": 2,
      "HIGH": 12,
      "MEDIUM": 15,
      "LOW": 3
    },
    "total_reward": 32500,
    "avg_reward": 722.22,
    "acceptance_rate": 0.844,
    "avg_triage_time_days": 5.2,
    "avg_fix_time_days": 21.4
  },
  "feedback_analysis": {
    "positive_patterns": [
      "Clear step-by-step reproduction",
      "Detailed impact assessment",
      "Screenshots with annotations"
    ],
    "improvement_areas": [
      "Add more context about business impact",
      "Include remediation recommendations"
    ],
    "rejection_reasons": {
      "duplicate": 1,
      "informative": 3,
      "not_applicable": 1
    }
  },
  "template_usage": {
    "templates_used": ["standard_xss", "standard_sqli", "chain_report"],
    "custom_templates": 2,
    "template_effectiveness": {
      "standard_xss": {"submitted": 12, "paid": 10, "rate": 0.833},
      "standard_sqli": {"submitted": 8, "paid": 7, "rate": 0.875}
    }
  },
  "quality_metrics": {
    "avg_report_length_words": 850,
    "avg_sections_complete": 7.5,
    "avg_time_to_write_min": 45,
    "avg_revision_count": 2.3,
    "quality_trend": "improving"
  }
}
```

### 3.2 MessagePack (Draft Stream)

```python
import msgpack

# Report editing event
edit_event = {
    "event": "section_updated",
    "draft_id": "draft_001",
    "section": "impact",
    "version": 3,
    "word_count": 234,
    "timestamp": time.time()
}
packed = msgpack.packb(edit_event, use_bin_type=True)
```

### 3.3 Protobuf (Report Archive Schema)

```protobuf
syntax = "proto3";
package reporting;

message ActiveDraft {
  string draft_id = 1;
  string finding_id = 2;
  string title = 3;
  string platform = 4;
  string program = 5;
  string severity = 6;
  string status = 7;
  int32 version = 8;
  int64 created_at = 9;
  int64 updated_at = 10;
  map<string, Section> sections = 11;
  double completeness_percent = 12;
  repeated Attachment attachments = 13;
}

message Section {
  string status = 1;
  string content = 2;
  int32 word_count = 3;
  int64 last_updated = 4;
}

message Attachment {
  string type = 1;
  string filename = 2;
  string description = 3;
  int64 uploaded_at = 4;
}

message SubmissionHistory {
  int32 total_submitted = 1;
  map<string, int32> by_status = 2;
  map<string, int32> by_severity_submitted = 3;
  map<string, int32> by_severity_paid = 4;
  double total_reward = 5;
  double avg_reward = 6;
  double acceptance_rate = 7;
  double avg_triage_time_days = 8;
  double avg_fix_time_days = 9;
}

message FeedbackAnalysis {
  repeated string positive_patterns = 1;
  repeated string improvement_areas = 2;
  map<string, int32> rejection_reasons = 3;
}

message QualityMetrics {
  double avg_report_length_words = 1;
  double avg_sections_complete = 2;
  double avg_time_to_write_min = 3;
  double avg_revision_count = 4;
  string quality_trend = 5;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── report-writing/
        ├── {session_id}/
        │   ├── active_drafts.json
        │   ├── submission_history.json
        │   ├── feedback_analysis.json
        │   ├── quality_metrics.json
        │   ├── drafts/
        │   │   ├── draft_001/
        │   │   │   ├── v1.md
        │   │   │   ├── v2.md
        │   │   │   ├── v3.md
        │   │   │   └── metadata.json
        │   │   └── ...
        │   ├── templates/
        │   │   ├── custom_template_001.md
        │   │   └── ...
        │   ├── attachments/
        │   │   ├── draft_001/
        │   │   │   ├── xss_proof.png
        │   │   │   └── request_har.har
        │   │   └── ...
        │   └── checkpoints/
        │       ├── cp_001.msgpack
        │       └── cp_latest.msgpack
        └── shared/
            ├── global_submission_history.json
            ├── template_library.json
            ├── quality_benchmarks.json
            └── platform_format_rules.json
```

### 4.2 SQLite WAL

```sql
CREATE TABLE active_drafts (
    draft_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    finding_id TEXT NOT NULL,
    title TEXT NOT NULL,
    platform TEXT NOT NULL,
    program TEXT NOT NULL,
    severity TEXT NOT NULL,
    status TEXT NOT NULL,
    version INTEGER NOT NULL,
    completeness_percent REAL NOT NULL,
    quality_score REAL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    draft_blob BLOB NOT NULL,
    checksum TEXT NOT NULL
);

CREATE TABLE draft_versions (
    version_id INTEGER PRIMARY KEY AUTOINCREMENT,
    draft_id TEXT NOT NULL,
    version INTEGER NOT NULL,
    content TEXT NOT NULL,
    word_count INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (draft_id) REFERENCES active_drafts(draft_id)
);

CREATE TABLE submissions (
    submission_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    draft_id TEXT NOT NULL,
    finding_id TEXT NOT NULL,
    platform TEXT NOT NULL,
    program TEXT NOT NULL,
    severity TEXT NOT NULL,
    submitted_at INTEGER NOT NULL,
    status TEXT NOT NULL,
    reward REAL,
    triage_time_days REAL,
    fix_time_days REAL,
    feedback TEXT,
    FOREIGN KEY (draft_id) REFERENCES active_drafts(draft_id)
);

CREATE TABLE quality_assessments (
    assessment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    draft_id TEXT NOT NULL,
    assessed_at INTEGER NOT NULL,
    clarity_score REAL,
    completeness_score REAL,
    impact_score REAL,
    poc_quality_score REAL,
    overall_score REAL,
    FOREIGN KEY (draft_id) REFERENCES active_drafts(draft_id)
);

CREATE INDEX idx_drafts_status ON active_drafts(status);
CREATE INDEX idx_drafts_severity ON active_drafts(severity);
CREATE INDEX idx_submissions_status ON submissions(status);
CREATE INDEX idx_submissions_program ON submissions(program);
```

---

## 5. State Snapshot Schema

### 5.1 Draft Progress Snapshot

```json
{
  "snapshot_type": "draft_progress",
  "session_id": "sess_w1w2x3y4z5",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "drafts_in_progress": 2,
  "drafts_ready_for_review": 1,
  "avg_completeness": 65.0,
  "time_spent_writing_min": 120,
  "sections_most_lagging": ["remediation", "business_impact"]
}
```

### 5.2 Submission Performance Snapshot

```json
{
  "snapshot_type": "submission_performance",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "recent_submissions": [
    {
      "program": "Example Corp",
      "severity": "HIGH",
      "status": "triaged",
      "reward": 1000,
      "triage_days": 3
    }
  ],
  "performance_trends": {
    "acceptance_rate_30d": 0.88,
    "avg_reward_30d": 850,
    "avg_triage_time_30d": 4.5,
    "improvement_areas": ["remediation detail", "business impact"]
  }
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Draft created | draft_progress | MEDIUM |
| Draft section updated | draft_progress | LOW |
| Draft version created | draft_progress | MEDIUM |
| Draft completed | draft_progress | HIGH |
| Report submitted | submission_performance | HIGH |
| Feedback received | feedback_analysis | HIGH |
| Quality assessment | quality_metrics | MEDIUM |
| Template created/modified | template_library | LOW |
| Session end | All state | HIGH |

---

## 7. Restore Operations

```python
def restore_report_state(session_id):
    drafts = load_latest_snapshot(session_id, "active_drafts")
    submissions = load_submission_history(session_id)
    quality = load_quality_metrics(session_id)
    
    # Restore draft files
    for draft_id, draft in drafts.items():
        draft["versions"] = load_draft_versions(session_id, draft_id)
        draft["attachments"] = list_attachments(session_id, draft_id)
    
    return ReportState(drafts=drafts, submissions=submissions, quality=quality)

def restore_template_library(session_id=None):
    if session_id:
        return load_local_templates(session_id)
    return load_shared("template_library.json")
```

---

## 8. Compression

| Data Type | Algorithm | Threshold |
|-----------|-----------|-----------|
| Draft content (Markdown) | None | N/A (human readable) |
| Submission history | None | N/A |
| Attachments (screenshots) | None | Already compressed |
| HAR files | gzip | > 100KB |
| Quality metrics archive | gzip | > 50KB |

---

## 9. Encryption

| Data Classification | Required |
|--------------------|----------|
| Draft content | Optional (contains vuln details pre-submission) |
| Submission history | No |
| Attachments | No |
| Feedback analysis | No |
| Quality metrics | No |

---

## 10. Report Quality Engine

### 10.1 Quality Scoring

```python
class ReportQualityScorer:
    def score_report(self, draft):
        scores = {
            "clarity": self.score_clarity(draft),
            "completeness": self.score_completeness(draft),
            "impact": self.score_impact(draft),
            "poc_quality": self.score_poc(draft),
            "remediation": self.score_remediation(draft)
        }
        
        overall = sum(scores.values()) / len(scores)
        return overall, scores

    def score_completeness(self, draft):
        required_sections = ["title", "severity", "summary", "description", "impact", "poc", "remediation"]
        complete = sum(1 for s in required_sections if draft["sections"].get(s, {}).get("status") == "complete")
        return complete / len(required_sections) * 100
```

### 10.2 Template Selection

```python
class TemplateSelector:
    def select_template(self, finding):
        vuln_class = finding["vuln_class"]
        severity = finding["severity"]
        platform = finding["platform"]
        
        # Match by vuln class
        template = self.find_template_by_vuln_class(vuln_class)
        if not template:
            template = self.get_default_template(severity)
        
        # Apply platform-specific formatting
        template = self.apply_platform_format(template, platform)
        
        return template
```

---

## 11. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `drafts_in_progress` | Gauge | > 5 (bottleneck) |
| `avg_completeness_percent` | Gauge | < 50% after 1h |
| `submission_acceptance_rate` | Gauge | < 70% |
| `avg_reward_per_submission` | Gauge | Declining trend |
| `avg_triage_time_days` | Gauge | > 10 days |
| `quality_score_avg` | Gauge | < 70 |
| `time_to_write_avg_min` | Histogram | > 60min |

---

## Appendix A: Complete File Reference

All 54 domain files:

1. `01-Report-Structure-Optimization.md` → Report structure state, section completeness
2. `02-Technical-Writing-Standards.md` → Writing standards reference, style guide
3. `03-Private-Program-Case-Study.md` → Private program analysis, format reference
4. `04-Proof-of-Concept-Development.md` → PoC development state, draft progress
5. `05-Vulnerability-Severity-Assessment.md` → Severity assessment state, CVSS calculation
6. `06-Remediation-Recommendations.md` → Remediation state, recommendation draft
7. `07-Executive-Summary-Crafting.md` → Executive summary state, summary draft
8. `08-Technical-Detail-Balancing.md` → Detail calibration state, depth setting
9. `09-Visual-Aid-Integration.md` → Visual aid state, screenshot inventory
10. `10-Code-Sample-Formatting.md` → Code sample state, formatting state
11. `11-Timeline-Documentation.md` → Timeline state, timeline draft
12. `12-Collaboration-Crediting.md` → Credit state, collaborator list
13. `13-Program-Specific-Formatting.md` → Program format state, format compliance
14. `14-Language-and-Tone-Optimization.md` → Language state, tone analysis
15. `15-Attachment-Management.md` → Attachment state, file inventory
16. `16-Follow-up-Communication.md` → Follow-up state, communication log
17. `17-Rejection-Analysis-and-Improvement.md` → Rejection analysis, improvement tracking
18. `18-Reward-Negotiation-Preparation.md` → Negotiation state, argument preparation
19. `19-Report-Template-Development.md` → Template development state
20. `20-Quality-Assurance-Process.md` → QA state, checklist completion
21. `21-Grammar-and-Style-Standards.md` → Grammar standards reference
22. `22-Technical-Accuracy-Verification.md` → Accuracy check state, verification log
23. `23-Impact-Quantification.md` → Impact metrics state, quantification draft
24. `24-Business-Context-Integration.md` → Business context state, context draft
25. `25-Compliance-Documentation.md` → Compliance state, compliance check
26. `26-International-Standard-Adherence.md` → Standards reference, adherence check
27. `27-Audience-Analysis.md` → Audience analysis state, reader profile
28. `28-Information-Hierarchy.md` → Hierarchy state, section ordering
29. `29-Actionable-Recommendations.md` → Recommendation state, action items
30. `30-Report-Review-Process.md` → Review state, review checklist
31. `31-Common-Pitfalls-Avoidance.md` → Pitfall avoidance reference, checklist
32. `32-Advanced-Formatting-Techniques.md` → Formatting state, format settings
33. `33-Multimedia-Integration.md` → Multimedia state, media inventory
34. `34-Interactive-Report-Elements.md` → Interactive element state
35. `35-Cross-Platform-Compatibility.md` → Compatibility state, platform checks
36. `36-Version-Control-for-Reports.md` → Version control state, version history
37. `37-Report-Analytics-and-Metrics.md` → Analytics state, metric calculations
38. `38-Peer-Review-Optimization.md` → Peer review state, review feedback
39. `39-Program-Feedback-Incorporation.md` → Feedback state, improvement tracking
40. `40-Continuous-Improvement.md` → Improvement state, trend analysis
41. `41-Report-Personalization.md` → Personalization state, customization settings
42. `42-Contextual-Intelligence.md` → Context intelligence state, context data
43. `43-Technical-Depth-Calibration.md` → Depth calibration state, depth setting
44. `44-Impact-Visualization.md` → Impact viz state, visualization assets
45. `45-Report-Archiving-Strategy.md` → Archive state, archive configuration
46. `46-Collaboration-Report-Standards.md` → Collab standards reference
47. `47-Advanced-Proof-of-Concept.md` → Advanced PoC state, complex PoC drafts
48. `48-Report-Automation-Tools.md` → Automation state, tool configuration
49. `49-Quality-Metrics-Development.md` → Quality metrics state, benchmark data
50. `50-Master-Report-Writing-Framework.md` → Master framework state, all templates
51. `Bugcrowd-Finding-Dissection.md` → Bugcrowd format reference, VRT mapping
52. `HackerOne-Report-Analysis.md` → HackerOne format reference, submission guide
53. `High-Severity-Vulnerability-Analysis.md` → High severity writing guide
54. `Impact-Communication.md` → Impact communication reference, phrasing guide
