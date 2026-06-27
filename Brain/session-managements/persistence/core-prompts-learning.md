# State Persistence: Core Prompts Learning Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Core Prompts Learning |
| **Directory** | `Core-Prompts-Learning/` |
| **File Count** | 50 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/core-prompts-learning.md` |
| **Serialization** | JSON (primary), MessagePack (score stream), Protobuf (progress archive) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the Core Prompts Learning domain. This domain tracks the educational progression of a security researcher across 50 specialized learning modules. The persistence layer captures learning progress, assessment scores, knowledge retention metrics, and skill competency mapping.

Unlike the hunting domain (which tracks active vulnerability findings), the learning domain tracks **researcher growth** — which vulnerability classes have been mastered, where knowledge gaps exist, and what areas need further study.

---

## 2. Domain File Registry

All 50 domain files organized by learning category:

### Foundation Learning
| # | File | Learning Area | Competency Level |
|---|------|--------------|-----------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery-Learning.md` | Reconnaissance | Foundation |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | JS Analysis | Foundation |
| 03 | `3-API-Endpoint-Analysis-Learning.md` | API Analysis | Foundation |
| 04 | `4-Authentication-and-Session-Management-Learning.md` | Authentication | Foundation |
| 05 | `5-Authorization-and-Access-Control-Learning.md` | Authorization | Foundation |
| 06 | `6-Input-Validation-and-Sanitization-Learning.md` | Input Validation | Foundation |
| 07 | `7-Business-Logic-Flaws-Learning.md` | Business Logic | Foundation |
| 08 | `8-Client-Side-Storage-Security-Learning.md` | Client Storage | Foundation |
| 09 | `9-Cryptography-and-Data-Protection-Learning.md` | Cryptography | Foundation |

### Intermediate Learning
| # | File | Learning Area | Competency Level |
|---|------|--------------|-----------------|
| 10 | `10-Error-Handling-and-Information-Disclosure-Learning.md` | Info Disclosure | Intermediate |
| 11 | `11-File-Upload-and-Processing-Learning.md` | File Upload | Intermediate |
| 12 | `12-Server-Side-Request-Forgery-SSRF-Learning.md` | SSRF | Intermediate |
| 13 | `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | CSRF | Intermediate |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | CORS | Intermediate |
| 15 | `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | Race Conditions | Intermediate |
| 16 | `16-Third-Party-Component-Analysis-Learning.md` | 3P Components | Intermediate |
| 17 | `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | Misconfiguration | Intermediate |
| 18 | `18-Network-and-Infrastructure-Security-Learning.md` | Network Security | Intermediate |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | Mobile/API | Intermediate |
| 20 | `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | Reporting | Intermediate |

### Advanced Learning
| # | File | Learning Area | Competency Level |
|---|------|--------------|-----------------|
| 21 | `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | WAF Bypass | Advanced |
| 22 | `22-HTTP-Request-Smuggling-Learning.md` | HTTP Smuggling | Advanced |
| 23 | `23-Subdomain-Takeover-Learning.md` | Subdomain Takeover | Advanced |
| 24 | `24-Host-Header-Injection-Learning.md` | Host Header Injection | Advanced |
| 25 | `25-XML-External-Entity-XXE-Injection-Learning.md` | XXE | Advanced |
| 26 | `26-Insecure-Deserialization-Learning.md` | Deserialization | Advanced |
| 27 | `27-Command-Injection-Learning.md` | Command Injection | Advanced |
| 28 | `28-NoSQL-Injection-Learning.md` | NoSQL Injection | Advanced |
| 29 | `29-GraphQL-Vulnerabilities-Learning.md` | GraphQL | Advanced |
| 30 | `30-WebSocket-Security-Learning.md` | WebSocket | Advanced |
| 31 | `31-Server-Side-Template-Injection-SSTI-Learning.md` | SSTI | Advanced |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | JWT | Advanced |
| 33 | `33-Content-Security-Policy-CSP-Bypass-Learning.md` | CSP Bypass | Advanced |
| 34 | `34-Clickjacking-and-UI-Redressing-Learning.md` | Clickjacking | Advanced |
| 35 | `35-HTTP-Parameter-Pollution-Learning.md` | HPP | Advanced |
| 36 | `36-LDAP-Injection-Learning.md` | LDAP Injection | Advanced |
| 37 | `37-Session-Puzzling-and-Fixation-Learning.md` | Session Attacks | Advanced |

### Specialized Learning
| # | File | Learning Area | Competency Level |
|---|------|--------------|-----------------|
| 38 | `38-Insecure-File-Handling-Learning.md` | File Handling | Specialized |
| 39 | `39-Advanced-Client-Side-Attacks-Learning.md` | Client-Side Attacks | Specialized |
| 40 | `40-Cloud-Security-and-Misconfigurations-Learning.md` | Cloud Security | Specialized |
| 41 | `41-Third-Party-Integration-Security-Learning.md` | 3P Integration | Specialized |
| 42 | `42-Mobile-Application-Security-Learning.md` | Mobile Security | Specialized |
| 43 | `43-IoT-and-Embedded-Device-Security-Learning.md` | IoT Security | Specialized |
| 44 | `44-API-Security-and-GraphQL-Learning.md` | API Security | Specialized |
| 45 | `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | WebAssembly | Specialized |
| 46 | `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | Blockchain | Specialized |
| 47 | `47-Automation-and-Tool-Development-Learning.md` | Automation | Specialized |
| 48 | `48-Advanced-Reverse-Engineering-Learning.md` | Reverse Engineering | Specialized |
| 49 | `49-Compliance-and-Regulatory-Security-Learning.md` | Compliance | Specialized |
| 50 | `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | Threat Modeling | Specialized |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Progress State)

```json
{
  "schema_version": "1.0.0",
  "domain": "core-prompts-learning",
  "session_id": "sess_l1l2m3n4o5p6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "learning_progress": {
    "researcher_id": "r_researcher_001",
    "overall_progress": {
      "modules_started": 15,
      "modules_completed": 8,
      "modules_mastered": 3,
      "total_modules": 50,
      "completion_percent": 16.0,
      "mastery_percent": 6.0
    },
    "competency_map": {
      "foundation": {
        "modules_total": 9,
        "modules_completed": 7,
        "modules_mastered": 2,
        "avg_score": 82.5
      },
      "intermediate": {
        "modules_total": 11,
        "modules_completed": 5,
        "modules_mastered": 1,
        "avg_score": 75.0
      },
      "advanced": {
        "modules_total": 17,
        "modules_completed": 3,
        "modules_mastered": 0,
        "avg_score": 68.0
      },
      "specialized": {
        "modules_total": 13,
        "modules_completed": 0,
        "modules_mastered": 0,
        "avg_score": 0
      }
    }
  },
  "module_scores": {
    "01-Recon": {
      "status": "mastered",
      "scores": [85, 90, 92],
      "avg_score": 89.0,
      "assessments_taken": 3,
      "last_assessment": "2026-06-25T10:00:00.000Z",
      "knowledge_areas": {
        "subdomain_enum": 95,
        "port_scanning": 88,
        "service_detection": 85,
        "osint": 80
      }
    },
    "12-SSRF": {
      "status": "in_progress",
      "scores": [65, 72],
      "avg_score": 68.5,
      "assessments_taken": 2,
      "last_assessment": "2026-06-24T15:00:00.000Z",
      "knowledge_areas": {
        "basic_ssrf": 80,
        "bypass_techniques": 60,
        "cloud_metadata": 55,
        "internal_network": 50
      }
    }
  },
  "knowledge_gaps": [
    {
      "module": "12-SSRF",
      "area": "cloud_metadata",
      "current_score": 55,
      "target_score": 80,
      "priority": "HIGH",
      "recommended_resources": ["Advanced-Persistence-Exploitation/22-Cloud-Instance-Persistence.md"]
    }
  ],
  "learning_streak": {
    "current_days": 5,
    "longest_days": 12,
    "total_study_hours": 87.5,
    "hours_this_week": 12.0
  }
}
```

### 3.2 MessagePack (Score Stream)

```python
import msgpack

# Assessment score event
score_event = {
    "event": "assessment_completed",
    "module": "12-SSRF",
    "score": 72,
    "questions_total": 20,
    "questions_correct": 14,
    "duration_seconds": 1800,
    "timestamp": time.time()
}
packed = msgpack.packb(score_event, use_bin_type=True)
```

### 3.3 Protobuf (Progress Archive Schema)

```protobuf
syntax = "proto3";
package learning;

message LearningProgress {
  string session_id = 1;
  string researcher_id = 2;
  OverallProgress overall = 3;
  map<string, ModuleScore> module_scores = 4;
  repeated KnowledgeGap knowledge_gaps = 5;
  LearningStreak streak = 6;
}

message OverallProgress {
  int32 modules_started = 1;
  int32 modules_completed = 2;
  int32 modules_mastered = 3;
  int32 total_modules = 4;
  double completion_percent = 5;
  double mastery_percent = 6;
  CompetencyByLevel by_level = 7;
}

message CompetencyByLevel {
  CompetencyLevel foundation = 1;
  CompetencyLevel intermediate = 2;
  CompetencyLevel advanced = 3;
  CompetencyLevel specialized = 4;
}

message CompetencyLevel {
  int32 modules_total = 1;
  int32 modules_completed = 2;
  int32 modules_mastered = 3;
  double avg_score = 4;
}

message ModuleScore {
  string status = 1;
  repeated int32 scores = 2;
  double avg_score = 3;
  int32 assessments_taken = 4;
  int64 last_assessment = 5;
  map<string, int32> knowledge_areas = 6;
}

message KnowledgeGap {
  string module = 1;
  string area = 2;
  int32 current_score = 3;
  int32 target_score = 4;
  string priority = 5;
  repeated string recommended_resources = 6;
}

message LearningStreak {
  int32 current_days = 1;
  int32 longest_days = 2;
  double total_study_hours = 3;
  double hours_this_week = 4;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── core-prompts-learning/
        ├── {session_id}/
        │   ├── learning_progress.json
        │   ├── module_scores.json
        │   ├── assessments/
        │   │   ├── assess_001.json
        │   │   ├── assess_002.json
        │   │   └── ...
        │   ├── knowledge_gaps.json
        │   └── checkpoints/
        │       ├── cp_001.msgpack
        │       └── cp_latest.msgpack
        └── shared/
            ├── global_progress.json
            ├── score_history.json
            ├── competency_matrix.json
            ├── learning_resources.json
            └── assessment_templates.json
```

### 4.2 SQLite WAL

```sql
CREATE TABLE module_scores (
    module_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    status TEXT NOT NULL,
    avg_score REAL NOT NULL,
    assessments_taken INTEGER NOT NULL,
    last_assessment INTEGER,
    knowledge_areas_blob BLOB NOT NULL,
    updated_at INTEGER NOT NULL,
    checksum TEXT NOT NULL
);

CREATE TABLE assessments (
    assessment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    module_id TEXT NOT NULL,
    score INTEGER NOT NULL,
    questions_total INTEGER NOT NULL,
    questions_correct INTEGER NOT NULL,
    duration_seconds INTEGER NOT NULL,
    completed_at INTEGER NOT NULL,
    FOREIGN KEY (module_id) REFERENCES module_scores(module_id)
);

CREATE TABLE knowledge_gaps (
    gap_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    module_id TEXT NOT NULL,
    area TEXT NOT NULL,
    current_score INTEGER NOT NULL,
    target_score INTEGER NOT NULL,
    priority TEXT NOT NULL,
    identified_at INTEGER NOT NULL,
    resolved INTEGER DEFAULT 0
);

CREATE INDEX idx_assessments_module ON assessments(module_id);
CREATE INDEX idx_assessments_date ON assessments(completed_at);
CREATE INDEX idx_gaps_priority ON knowledge_gaps(priority);
CREATE INDEX idx_gaps_module ON knowledge_gaps(module_id);
```

---

## 5. State Snapshot Schema

### 5.1 Progress Snapshot

```json
{
  "snapshot_type": "learning_progress",
  "session_id": "sess_l1l2m3n4o5p6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "progress_delta": {
    "modules_completed_this_session": 1,
    "score_improvement_avg": 5.2,
    "new_masteries": [],
    "knowledge_gaps_resolved": 1,
    "new_knowledge_gaps": 0
  },
  "cumulative": {
    "total_assessments": 45,
    "total_study_hours": 87.5,
    "avg_score_all": 78.3,
    "improvement_trend": "improving"
  }
}
```

### 5.2 Competency Snapshot

```json
{
  "snapshot_type": "competency",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "strengths": [
    {"module": "01-Recon", "avg_score": 89.0, "level": "mastered"},
    {"module": "04-Auth", "avg_score": 85.0, "level": "mastered"},
    {"module": "07-Business-Logic", "avg_score": 82.0, "level": "completed"}
  ],
  "weaknesses": [
    {"module": "12-SSRF", "avg_score": 68.5, "level": "in_progress"},
    {"module": "22-Smuggling", "avg_score": 45.0, "level": "started"},
    {"module": "31-SSTI", "avg_score": 52.0, "level": "started"}
  ],
  "recommendations": [
    {
      "action": "focus_study",
      "module": "12-SSRF",
      "reason": "below competency threshold",
      "target_hours": 8
    }
  ]
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Assessment completed | module_scores | HIGH |
| Module completed | learning_progress | HIGH |
| Module mastered | learning_progress | HIGH |
| Knowledge gap identified | knowledge_gaps | MEDIUM |
| Knowledge gap resolved | knowledge_gaps | MEDIUM |
| Study session end | learning_progress | MEDIUM |
| Score improvement > 10% | module_scores | HIGH |
| Streak milestone (7/30/90 days) | learning_streak | LOW |
| Session end | All state | HIGH |

---

## 7. Restore Operations

### 7.1 Progress Restore

```python
def restore_learning_progress(session_id):
    state = load_latest_snapshot(session_id, "learning_progress")
    
    # Recalculate from DB
    scores = query_db(
        "SELECT module_id, AVG(score) as avg, COUNT(*) as count "
        "FROM assessments WHERE session_id = ? GROUP BY module_id",
        (session_id,)
    )
    
    for s in scores:
        state["module_scores"][s["module_id"]]["avg_score"] = s["avg"]
        state["module_scores"][s["module_id"]]["assessments_taken"] = s["count"]
    
    # Update overall progress
    state["learning_progress"]["overall_progress"] = recalculate_overall(state["module_scores"])
    
    return state
```

### 7.2 Competency Matrix Restore

```python
def restore_competency_matrix(session_id=None):
    if session_id:
        return load_latest_snapshot(session_id, "competency")
    
    # Build from all historical data
    all_scores = load_shared("score_history.json")
    return build_competency_matrix(all_scores)
```

---

## 8. Compression

| Data Type | Algorithm | Threshold |
|-----------|-----------|-----------|
| Learning progress | None | N/A |
| Assessment details | None | N/A |
| Score history (archive) | gzip | > 100KB |
| Competency matrix | None | N/A |
| Checkpoint blobs | LZ4 | > 10KB |

---

## 9. Encryption

| Data Classification | Required |
|--------------------|----------|
| Learning progress | No |
| Assessment scores | No |
| Knowledge gaps | No |
| Competency matrix | No |

---

## 10. Mastery Calculation

### 10.1 Mastery Criteria

```python
class MasteryCalculator:
    MASTERY_THRESHOLD = 90
    MIN_ASSESSMENTS = 3
    CONSISTENCY_WINDOW = 30  # days

    def calculate_module_status(self, module_id, scores):
        if len(scores) < self.MIN_ASSESSMENTS:
            return "started"
        
        recent_scores = self.get_recent_scores(module_id, self.CONSISTENCY_WINDOW)
        avg_score = sum(recent_scores) / len(recent_scores)
        
        if avg_score >= self.MASTERY_THRESHOLD:
            return "mastered"
        elif avg_score >= 70:
            return "completed"
        elif avg_score >= 40:
            return "in_progress"
        return "started"
```

### 10.2 Knowledge Gap Detection

```python
class KnowledgeGapDetector:
    GAP_THRESHOLD = 20  # gap between current and target
    MIN_AREA_SCORE = 70

    def detect_gaps(self, module_scores):
        gaps = []
        for module_id, scores in module_scores.items():
            for area, score in scores["knowledge_areas"].items():
                target = self.get_target_score(module_id, area)
                if target - score > self.GAP_THRESHOLD:
                    gaps.append(KnowledgeGap(
                        module=module_id,
                        area=area,
                        current=score,
                        target=target,
                        priority=self.calculate_priority(score, target)
                    ))
        return gaps
```

---

## 11. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `modules_mastered_count` | Gauge | N/A (milestone) |
| `overall_completion_percent` | Gauge | Stalled > 7d |
| `avg_score_trend` | Gauge | Declining |
| `knowledge_gaps_count` | Gauge | > 20 |
| `study_hours_this_week` | Gauge | < 5h |
| `assessment_frequency` | Gauge | < 2/week |

---

## Appendix A: Complete File Reference

All 50 domain files:

1. `1-Reconnaissance-and-Asset-Discovery-Learning.md` → Recon learning progress, assessment scores
2. `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` → JS analysis learning state
3. `3-API-Endpoint-Analysis-Learning.md` → API analysis learning state
4. `4-Authentication-and-Session-Management-Learning.md` → Auth learning progress
5. `5-Authorization-and-Access-Control-Learning.md` → Authorization learning progress
6. `6-Input-Validation-and-Sanitization-Learning.md` → Input validation learning state
7. `7-Business-Logic-Flaws-Learning.md` → Business logic learning state
8. `8-Client-Side-Storage-Security-Learning.md` → Client storage learning state
9. `9-Cryptography-and-Data-Protection-Learning.md` → Crypto learning progress
10. `10-Error-Handling-and-Information-Disclosure-Learning.md` → Info disclosure learning
11. `11-File-Upload-and-Processing-Learning.md` → File upload learning state
12. `12-Server-Side-Request-Forgery-SSRF-Learning.md` → SSRF learning progress
13. `13-Cross-Site-Request-Forgery-CSRF-Learning.md` → CSRF learning state
14. `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` → CORS learning state
15. `15-Race-Conditions-and-Concurrency-Issues-Learning.md` → Race learning progress
16. `16-Third-Party-Component-Analysis-Learning.md` → 3P learning state
17. `17-Configuration-and-Misconfiguration-Hunting-Learning.md` → Config learning state
18. `18-Network-and-Infrastructure-Security-Learning.md` → Network learning progress
19. `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` → Mobile/API learning
20. `20-Reporting-and-Proof-of-Concept-Development-Learning.md` → Reporting learning
21. `21-Web-Application-Firewall-WAF-Bypass-Learning.md` → WAF bypass learning
22. `22-HTTP-Request-Smuggling-Learning.md` → HTTP smuggling learning
23. `23-Subdomain-Takeover-Learning.md` → Subdomain takeover learning
24. `24-Host-Header-Injection-Learning.md` → Host header learning
25. `25-XML-External-Entity-XXE-Injection-Learning.md` → XXE learning
26. `26-Insecure-Deserialization-Learning.md` → Deserialization learning
27. `27-Command-Injection-Learning.md` → Command injection learning
28. `28-NoSQL-Injection-Learning.md` → NoSQLi learning
29. `29-GraphQL-Vulnerabilities-Learning.md` → GraphQL learning
30. `30-WebSocket-Security-Learning.md` → WebSocket learning
31. `31-Server-Side-Template-Injection-SSTI-Learning.md` → SSTI learning
32. `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` → JWT learning
33. `33-Content-Security-Policy-CSP-Bypass-Learning.md` → CSP bypass learning
34. `34-Clickjacking-and-UI-Redressing-Learning.md` → Clickjacking learning
35. `35-HTTP-Parameter-Pollution-Learning.md` → HPP learning
36. `36-LDAP-Injection-Learning.md` → LDAP injection learning
37. `37-Session-Puzzling-and-Fixation-Learning.md` → Session attack learning
38. `38-Insecure-File-Handling-Learning.md` → File handling learning
39. `39-Advanced-Client-Side-Attacks-Learning.md` → Client-side attacks learning
40. `40-Cloud-Security-and-Misconfigurations-Learning.md` → Cloud security learning
41. `41-Third-Party-Integration-Security-Learning.md` → 3P integration learning
42. `42-Mobile-Application-Security-Learning.md` → Mobile app security learning
43. `43-IoT-and-Embedded-Device-Security-Learning.md` → IoT security learning
44. `44-API-Security-and-GraphQL-Learning.md` → API security learning
45. `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` → WebAssembly learning
46. `46-Blockchain-and-Cryptocurrency-Security-Learning.md` → Blockchain learning
47. `47-Automation-and-Tool-Development-Learning.md` → Automation learning
48. `48-Advanced-Reverse-Engineering-Learning.md` → Reverse engineering learning
49. `49-Compliance-and-Regulatory-Security-Learning.md` → Compliance learning
50. `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` → Threat modeling learning
