# Working Memory: Core Prompts — Learning Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `CORE-LEARN-001` |
| Root Folder | `Core-Prompts-Learning/` |
| Total Files | 50 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict + progress tracker |
| Typical Lifetime | Learning session (1-4h) |
| Eviction Trigger | Module completion, session end, or 48h TTL |

---

## Overview

Working memory for the learning domain captures the state of active security
learning sessions. This spans 50 educational modules covering reconnaissance
through advanced threat modeling and risk assessment. Working memory must track:

- **Current module**: Which educational module is currently being studied and
  how far through it the learner has progressed.
- **Assessment scores**: Scores on quizzes, practical exercises, and skill
  assessments for each module.
- **Progress tracking**: Overall learning progress across all 50 modules,
  including completion status and time invested.
- **Learning streaks**: Consecutive days of learning activity for motivation
  and habit tracking.
- **Knowledge gaps**: Identified areas where the learner needs more practice
  or study, based on assessment performance.
- **Practical exercise state**: State of hands-on exercises — which targets
  are being practiced on, what tools are being used, and what results were achieved.
- **Reference links**: Connections between learning modules — prerequisite
  knowledge, related topics, and advanced follow-ups.
- **Retention tracking**: Spaced repetition intervals for key concepts to
  optimize long-term retention.

This is the "learning brain" that ensures structured, effective security education
by tracking what has been learned, what needs review, and what to study next.

---

## Data Schema (YAML)

```yaml
working_memory_learning:
  version: "1.8"
  scope: "learning-session"
  ttl_seconds: 172800

  session_state:
    session_id: "string (uuid4)"
    learner_id: "string"
    started_at: "ISO8601"
    last_activity: "ISO8601"
    status: "enum(active|paused|completed)"
    current_module_id: "string (nullable)"
    session_goal: "string"
    time_budget_minutes: "integer"
    time_spent_minutes: "float"

  module_progress:
    module_id: "string (uuid4)"
    module_number: "integer (1-50)"
    module_name: "string"
    module_file: "string (source .md file)"
    category: "enum(recon|vuln_hunting|exploitation|reporting|advanced|threat_modeling)"
    status: "enum(not_started|in_progress|completed|review_needed)"
    started_at: "ISO8601"
    completed_at: "ISO8601 (nullable)"
    time_spent_minutes: "float"
    sections_completed: "list[string]"
    sections_remaining: "list[string]"
    notes: "list[string]"

  assessment_scores:
    assessment_id: "string (uuid4)"
    module_id: "string"
    assessment_type: "enum(quiz|practical|conceptual|peer_review)"
    question_count: "integer"
    correct_count: "integer"
    score_pct: "float (0.0-100.0)"
    time_taken_seconds: "integer"
    attempted_at: "ISO8601"
    feedback: "list[map] (question, correct_answer, learner_answer)"

  learning_streaks:
    streak_id: "string (uuid4)"
    learner_id: "string"
    current_streak_days: "integer"
    longest_streak_days: "integer"
    last_activity_date: "string (YYYY-MM-DD)"
    streak_history: "list[string] (YYYY-MM-DD entries)"

  knowledge_gaps:
    gap_id: "string (uuid4)"
    module_id: "string"
    topic: "string"
    gap_type: "enum(conceptual|practical|tool_specific|methodology)"
    severity: "enum(critical|major|minor)"
    identified_at: "ISO8601"
    addressed: "boolean"
    practice_completed: "integer"
    practice_target: "integer"

  practical_exercises:
    exercise_id: "string (uuid4)"
    module_id: "string"
    exercise_name: "string"
    target_system: "string"
    tools_used: "list[string]"
    objectives: "list[string]"
    completed_objectives: "list[string]"
    results: "list[map]"
    started_at: "ISO8601"
    completed_at: "ISO8601 (nullable)"
    score: "float (0.0-1.0) (nullable)"

  reference_links:
    link_id: "string (uuid4)"
    source_module: "string"
    target_module: "string"
    link_type: "enum(prerequisite|related|advanced|alternative)"
    strength: "float (0.0-1.0)"

  retention_schedule:
    item_id: "string (uuid4)"
    concept: "string"
    module_id: "string"
    ease_factor: "float (default 2.5)"
    interval_days: "integer (default 1)"
    repetitions: "integer"
    next_review: "ISO8601"
    last_review: "ISO8601"
```

---

## Read/Write Operations

```python
import uuid
from datetime import datetime, timezone, timedelta
from typing import Optional
from enum import Enum


class ModuleStatus(Enum):
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    REVIEW_NEEDED = "review_needed"


class GapType(Enum):
    CONCEPTUAL = "conceptual"
    PRACTICAL = "practical"
    TOOL_SPECIFIC = "tool_specific"
    METHODOLOGY = "methodology"


class CoreLearningWorkingMemory:
    """
    In-memory working state for learning sessions.
    Covers all 50 modules from Recon Learning through Advanced Threat Modeling.
    """

    def __init__(self, learner_id: str = ""):
        self.session_id = str(uuid.uuid4())
        self.learner_id = learner_id
        self.created_at = datetime.now(timezone.utc)

        self.session_state = {
            "session_id": self.session_id,
            "learner_id": learner_id,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "last_activity": datetime.now(timezone.utc).isoformat(),
            "status": "active",
            "current_module_id": None,
            "session_goal": "",
            "time_budget_minutes": 120,
            "time_spent_minutes": 0,
        }

        self.module_progress: dict[str, dict] = {}
        self.assessment_scores: list[dict] = []
        self.learning_streaks: dict = {
            "current_streak_days": 0,
            "longest_streak_days": 0,
            "last_activity_date": "",
            "streak_history": [],
        }
        self.knowledge_gaps: dict[str, dict] = {}
        self.practical_exercises: dict[str, dict] = {}
        self.reference_links: list[dict] = []
        self.retention_schedule: dict[str, dict] = {}

    def register_module(self, module_number: int, module_name: str,
                        module_file: str, category: str = "recon") -> str:
        """Register a learning module."""
        module_id = str(uuid.uuid4())

        self.module_progress[module_id] = {
            "module_id": module_id,
            "module_number": module_number,
            "module_name": module_name,
            "module_file": module_file,
            "category": category,
            "status": ModuleStatus.NOT_STARTED.value,
            "started_at": None,
            "completed_at": None,
            "time_spent_minutes": 0,
            "sections_completed": [],
            "sections_remaining": [],
            "notes": [],
        }

        return module_id

    def start_module(self, module_id: str) -> None:
        """Begin working on a module."""
        self.module_progress[module_id]["status"] = ModuleStatus.IN_PROGRESS.value
        self.module_progress[module_id]["started_at"] = (
            datetime.now(timezone.utc).isoformat()
        )
        self.session_state["current_module_id"] = module_id

    def complete_section(self, module_id: str, section_name: str) -> None:
        """Mark a section as completed within a module."""
        mp = self.module_progress[module_id]
        if section_name not in mp["sections_completed"]:
            mp["sections_completed"].append(section_name)

    def complete_module(self, module_id: str) -> None:
        """Mark a module as completed."""
        mp = self.module_progress[module_id]
        mp["status"] = ModuleStatus.COMPLETED.value
        mp["completed_at"] = datetime.now(timezone.utc).isoformat()
        self.session_state["current_module_id"] = None

    def record_assessment(self, module_id: str, assessment_type: str,
                          question_count: int, correct_count: int,
                          time_taken_seconds: int = 0,
                          feedback: Optional[list[dict]] = None) -> str:
        """Record an assessment score."""
        assessment_id = str(uuid.uuid4())
        score_pct = (correct_count / max(question_count, 1)) * 100

        self.assessment_scores.append({
            "assessment_id": assessment_id,
            "module_id": module_id,
            "assessment_type": assessment_type,
            "question_count": question_count,
            "correct_count": correct_count,
            "score_pct": score_pct,
            "time_taken_seconds": time_taken_seconds,
            "attempted_at": datetime.now(timezone.utc).isoformat(),
            "feedback": feedback or [],
        })

        if score_pct < 70:
            self.identify_knowledge_gap(module_id, "Low assessment score",
                                        "conceptual", "major")

        return assessment_id

    def record_practical_exercise(self, module_id: str, exercise_name: str,
                                   target_system: str,
                                   objectives: list[str],
                                   tools_used: Optional[list[str]] = None) -> str:
        """Record a practical exercise."""
        exercise_id = str(uuid.uuid4())

        self.practical_exercises[exercise_id] = {
            "exercise_id": exercise_id,
            "module_id": module_id,
            "exercise_name": exercise_name,
            "target_system": target_system,
            "tools_used": tools_used or [],
            "objectives": objectives,
            "completed_objectives": [],
            "results": [],
            "started_at": datetime.now(timezone.utc).isoformat(),
            "completed_at": None,
            "score": None,
        }

        return exercise_id

    def complete_exercise_objective(self, exercise_id: str,
                                     objective: str,
                                     result: Optional[dict] = None) -> None:
        """Mark an exercise objective as completed."""
        ex = self.practical_exercises[exercise_id]
        if objective not in ex["completed_objectives"]:
            ex["completed_objectives"].appendobjective]
        if result:
            ex["results"].append(result)

        if len(ex["completed_objectives"]) == len(ex["objectives"]):
            ex["completed_at"] = datetime.now(timezone.utc).isoformat()
            ex["score"] = 1.0

    def identify_knowledge_gap(self, module_id: str, topic: str,
                                gap_type: str = "conceptual",
                                severity: str = "minor") -> str:
        """Identify and record a knowledge gap."""
        gap_id = str(uuid.uuid4())

        self.knowledge_gaps[gap_id] = {
            "gap_id": gap_id,
            "module_id": module_id,
            "topic": topic,
            "gap_type": gap_type,
            "severity": severity,
            "identified_at": datetime.now(timezone.utc).isoformat(),
            "addressed": False,
            "practice_completed": 0,
            "practice_target": 5,
        }

        return gap_id

    def update_streak(self) -> None:
        """Update the learning streak based on today's activity."""
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        streak = self.learning_streaks

        if streak["last_activity_date"] == today:
            return

        yesterday = (datetime.now(timezone.utc) - timedelta(days=1)).strftime("%Y-%m-%d")

        if streak["last_activity_date"] == yesterday:
            streak["current_streak_days"] += 1
        elif streak["last_activity_date"] != today:
            streak["current_streak_days"] = 1

        streak["last_activity_date"] = today
        streak["streak_history"].append(today)

        if streak["current_streak_days"] > streak["longest_streak_days"]:
            streak["longest_streak_days"] = streak["current_streak_days"]

    def schedule_retention(self, concept: str, module_id: str,
                            initial_interval_days: int = 1) -> str:
        """Schedule a concept for spaced repetition review."""
        item_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc)

        self.retention_schedule[item_id] = {
            "item_id": item_id,
            "concept": concept,
            "module_id": module_id,
            "ease_factor": 2.5,
            "interval_days": initial_interval_days,
            "repetitions": 0,
            "next_review": (now + timedelta(days=initial_interval_days)).isoformat(),
            "last_review": now.isoformat(),
        }

        return item_id

    def review_retention_item(self, item_id: str, quality: int) -> None:
        """Update retention schedule after review (quality 0-5)."""
        item = self.retention_schedule[item_id]
        now = datetime.now(timezone.utc)

        if quality >= 3:
            if item["repetitions"] == 0:
                item["interval_days"] = 1
            elif item["repetitions"] == 1:
                item["interval_days"] = 6
            else:
                item["interval_days"] = int(item["interval_days"] * item["ease_factor"])
            item["repetitions"] += 1
        else:
            item["repetitions"] = 0
            item["interval_days"] = 1

        item["ease_factor"] = max(1.3,
            item["ease_factor"] + 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))

        item["next_review"] = (now + timedelta(days=item["interval_days"])).isoformat()
        item["last_review"] = now.isoformat()

    def get_due_reviews(self) -> list[dict]:
        """Get concepts due for review."""
        now = datetime.now(timezone.utc)
        due = []
        for item in self.retention_schedule.values():
            if datetime.fromisoformat(item["next_review"]) <= now:
                due.append(item)
        return sorted(due, key=lambda x: x["next_review"])

    def get_learning_progress(self) -> dict:
        """Get overall learning progress."""
        total = len(self.module_progress)
        completed = sum(1 for m in self.module_progress.values()
                       if m["status"] == ModuleStatus.COMPLETED.value)
        in_progress = sum(1 for m in self.module_progress.values()
                         if m["status"] == ModuleStatus.IN_PROGRESS.value)
        total_time = sum(m["time_spent_minutes"] for m in self.module_progress.values())

        avg_score = 0
        if self.assessment_scores:
            avg_score = sum(s["score_pct"] for s in self.assessment_scores) / len(self.assessment_scores)

        return {
            "session_id": self.session_id,
            "learner_id": self.learner_id,
            "modules_total": total,
            "modules_completed": completed,
            "modules_in_progress": in_progress,
            "completion_pct": (completed / max(total, 1)) * 100,
            "total_time_minutes": round(total_time, 1),
            "average_score": round(avg_score, 1),
            "current_streak": self.learning_streaks["current_streak_days"],
            "longest_streak": self.learning_streaks["longest_streak_days"],
            "knowledge_gaps": sum(1 for g in self.knowledge_gaps.values() if not g["addressed"]),
            "due_reviews": len(self.get_due_reviews()),
        }

    def get_module_summary(self, module_id: str) -> dict:
        """Get detailed summary of a module."""
        mp = self.module_progress[module_id]
        module_assessments = [
            a for a in self.assessment_scores if a["module_id"] == module_id
        ]
        module_exercises = [
            e for e in self.practical_exercises.values() if e["module_id"] == module_id
        ]

        return {
            "module": mp,
            "assessments_taken": len(module_assessments),
            "average_score": (
                sum(a["score_pct"] for a in module_assessments) / len(module_assessments)
                if module_assessments else 0
            ),
            "exercises_completed": sum(1 for e in module_exercises if e["completed_at"]),
            "exercises_total": len(module_exercises),
        }

    def record_time(self, module_id: str, minutes: float) -> None:
        """Record time spent on a module."""
        self.module_progress[module_id]["time_spent_minutes"] += minutes
        self.session_state["time_spent_minutes"] += minutes

    def add_note(self, module_id: str, note: str) -> None:
        """Add a learning note to a module."""
        self.module_progress[module_id]["notes"].append(note)

    def add_reference_link(self, source_module: str, target_module: str,
                           link_type: str = "related") -> None:
        """Add a reference link between modules."""
        self.reference_links.append({
            "link_id": str(uuid.uuid4()),
            "source_module": source_module,
            "target_module": target_module,
            "link_type": link_type,
            "strength": 0.5,
        })

    def get_next_recommendation(self) -> dict:
        """Recommend the next module or activity."""
        due_reviews = self.get_due_reviews()
        if due_reviews:
            return {"type": "review", "item": due_reviews[0]}

        gaps = [g for g in self.knowledge_gaps.values() if not g["addressed"]]
        if gaps:
            return {"type": "practice_gap", "gap": gaps[0]}

        not_started = [
            m for m in self.module_progress.values()
            if m["status"] == ModuleStatus.NOT_STARTED.value
        ]
        if not_started:
            not_started.sort(key=lambda m: m["module_number"])
            return {"type": "new_module", "module": not_started[0]}

        in_progress = [
            m for m in self.module_progress.values()
            if m["status"] == ModuleStatus.IN_PROGRESS.value
        ]
        if in_progress:
            return {"type": "continue_module", "module": in_progress[0]}

        return {"type": "all_complete", "message": "All modules completed!"}

    def cleanup_expired(self) -> int:
        """Remove session data older than TTL."""
        now = datetime.now(timezone.utc)
        started = datetime.fromisoformat(self.session_state["started_at"])
        if (now - started).total_seconds() > 172800:
            return 1
        return 0
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Module progress entries | 50 | Module count limit | One per module |
| Assessment scores | 500 | FIFO eviction | Keep recent assessments |
| Knowledge gaps | 200 | FIFO eviction when addressed | Addressed gaps removed |
| Practical exercises | 100 | LRU eviction | Completed exercises removed first |
| Retention schedule items | 1,000 | LRU eviction | Keep active items |
| Session notes | 200 per module | FIFO eviction | Key notes preserved |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Session expires after 48h.
  - Module progress and scores preserved to Long-Term Memory first.

Priority 2: Addressed Gaps
  - Knowledge gaps marked as addressed are evicted after 7 days.

Priority 3: Completed Exercises
  - Practical exercises with score=1.0 evicted after 14 days.

Priority 4: Low-Priority Retention Items
  - Items with ease_factor > 3.0 (easy items) have longer intervals.
  - Items with repetitions > 10 are candidates for eviction.
```

---

## Lifecycle

```
1. SESSION START
   register_module() × N → set session goal

2. ACTIVE LEARNING
   start_module() → complete_section() × N → record_assessment()
   complete_module() → identify_knowledge_gap() if needed
   record_practical_exercise() → complete_exercise_objective() × N

3. REVIEW CYCLE
   get_due_reviews() → review_retention_item() × N
   update_streak() on each activity day

4. PROGRESS TRACKING
   get_learning_progress() → check coverage → get_next_recommendation()

5. SESSION END
   Export progress to Long-Term Memory → cleanup_expired()
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Advanced Automation | Read | Tool outputs for practical exercises |
| Core Prompts Hunting | Read | Hunting results for practical exercises |
| Long-Term Memory | Write | Module completions, scores, streaks |
| Report Writing | Read | Learning progress for skill assessment |

---

## Domain File References (Core-Prompts-Learning/)

### 1-Reconnaissance-and-Asset-Discovery-Learning
Learning module for reconnaissance and asset discovery.
Working memory stores: recon concepts, tool proficiency, practical results.

### 2-Subdomain-Enumeration-Learning
Learning module for subdomain enumeration techniques.
Working memory stores: enumeration methods, tool usage, practice outcomes.

### 3-HTTP-Probing-Learning
Learning module for HTTP probing and service discovery.
Working memory stores: probing techniques, analysis skills, exercise results.

### 4-Technology-Fingerprinting-Learning
Learning module for technology stack identification.
Working memory stores: fingerprint patterns, tool usage, assessment scores.

### 5-Directory-Discovery-Learning
Learning module for directory and file discovery.
Working memory stores: discovery techniques, wordlist usage, practice results.

### 6-Parameter-Discovery-Learning
Learning module for parameter discovery and analysis.
Working memory stores: parameter types, analysis methods, exercise outcomes.

### 7-Secret-Discovery-Learning
Learning module for secret and credential discovery.
Working memory stores: secret patterns, detection tools, practical skills.

### 8-Cloud-Storage-Discovery-Learning
Learning module for cloud storage discovery.
Working memory stores: bucket enumeration, access testing, exercise results.

### 9-API-Discovery-Learning
Learning module for API endpoint discovery.
Working memory stores: API patterns, tool usage, practical outcomes.

### 10-JavaScript-Analysis-Learning
Learning module for JavaScript bundle analysis.
Working memory stores: JS analysis techniques, endpoint extraction, skills.

### 11-Certificate-Transparency-Learning
Learning module for CT log analysis.
Working memory stores: CT tools, log analysis, subdomain discovery skills.

### 12-DNS-Analysis-Learning
Learning module for DNS record analysis.
Working memory stores: DNS record types, analysis techniques, exercise results.

### 13-WAF-Detection-Learning
Learning module for WAF/CDN detection and fingerprinting.
Working memory stores: WAF signatures, detection tools, bypass concepts.

### 14-Redirect-Analysis-Learning
Learning module for redirect chain analysis.
Working memory stores: redirect patterns, origin discovery, practical skills.

### 15-Screenshot-Analysis-Learning
Learning module for visual reconnaissance.
Working memory stores: screenshot tools, visual analysis, page categorization.

### 16-Header-Analysis-Learning
Learning module for security header analysis.
Working memory stores: header values, security implications, audit skills.

### 17-Cookie-Analysis-Learning
Learning module for cookie attribute analysis.
Working memory stores: cookie flags, security implications, testing methods.

### 18-CORS-Analysis-Learning
Learning module for CORS misconfiguration detection.
Working memory stores: CORS policies, testing techniques, bypass methods.

### 19-Subdomain-Takeover-Learning
Learning module for subdomain takeover detection.
Working memory stores: CNAME analysis, service fingerprinting, takeover methods.

### 20-Email-Analysis-Learning
Learning module for email-related security analysis.
Working memory stores: email protocols, SPF/DKIM/DMARC, phishing patterns.

### 21-XSS-Learning
Comprehensive XSS vulnerability learning module.
Working memory stores: XSS types, contexts, payloads, filter bypasses.

### 22-SQL-Injection-Learning
SQL injection vulnerability learning module.
Working memory stores: injection types, databases, extraction methods.

### 23-SSRF-Learning
Server-side request forgery learning module.
Working memory stores: SSRF types, filter bypasses, internal access.

### 24-SSTI-Learning
Server-side template injection learning module.
Working memory stores: template engines, sandbox escapes, RCE paths.

### 25-File-Inclusion-Learning
File inclusion vulnerability learning module.
Working memory stores: LFI/RFI techniques, filter bypasses, exploitation.

### 26-Command-Injection-Learning
Command injection vulnerability learning module.
Working memory stores: injection types, separators, filter analysis.

### 27-File-Upload-Learning
File upload vulnerability learning module.
Working memory stores: bypass techniques, webshell types, detection evasion.

### 28-CSRF-Learning
CSRF vulnerability learning module.
Working memory stores: CSRF types, token analysis, protection methods.

### 29-Access-Control-Learning
Access control vulnerability learning module.
Working memory stores: IDOR patterns, authorization flaws, privilege escalation.

### 30-Authentication-Learning
Authentication vulnerability learning module.
Working memory stores: auth flaws, bypass methods, session management.

### 31-Session-Management-Learning
Session management security learning module.
Working memory stores: session tokens, fixation, hijacking techniques.

### 32-API-Security-Learning
API security vulnerability learning module.
Working memory stores: API patterns, common flaws, testing methods.

### 33-GraphQL-Learning
GraphQL security learning module.
Working memory stores: GraphQL schema, query patterns, authorization.

### 34-Mobile-Security-Learning
Mobile application security learning module.
Working memory stores: mobile platforms, common flaws, testing tools.

### 35-Cloud-Security-Learning
Cloud infrastructure security learning module.
Working memory stores: cloud providers, misconfigurations, testing methods.

### 36-IoT-Security-Learning
IoT device security learning module.
Working memory stores: IoT protocols, firmware analysis, common flaws.

### 37-Blockchain-Learning
Blockchain and smart contract security learning module.
Working memory stores: contract vulnerabilities, exploitation techniques.

### 38-AI-ML-Security-Learning
AI/ML system security learning module.
Working memory stores: adversarial ML, data poisoning, model theft.

### 39-Race-Condition-Learning
Race condition vulnerability learning module.
Working memory stores: timing attacks, concurrency flaws, exploitation.

### 40-Logic-Flaw-Learning
Business logic flaw learning module.
Working memory stores: logic patterns, manipulation techniques, impact.

### 41-Deserialization-Learning
Insecure deserialization learning module.
Working memory stores: serialization formats, gadget chains, RCE methods.

### 42-Prototype-Pollution-Learning
Prototype pollution vulnerability learning module.
Working memory stores: pollution sinks, gadget chains, exploitation.

### 43-HTTP-Smuggling-Learning
HTTP request smuggling learning module.
Working memory stores: smuggling types, detection methods, exploitation.

### 44-Cache-Poisoning-Learning
Web cache poisoning learning module.
Working memory stores: poisonable headers, cache mechanics, exploitation.

### 45-Host-Header-Learning
Host header injection learning module.
Working memory stores: injection techniques, abuse scenarios, testing methods.

### 46-Advanced-Exploitation-Learning
Advanced exploitation techniques learning module.
Working memory stores: exploitation chains, post-exploitation, impact.

### 47-Advanced-Reporting-Learning
Advanced report writing learning module.
Working memory stores: report templates, severity assessment, communication.

### 48-Advanced-Threat-Modeling-Learning
Threat modeling methodology learning module.
Working memory stores: threat models, attack trees, risk assessment.

### 49-Advanced-Risk-Assessment-Learning
Advanced risk assessment learning module.
Working memory stores: risk frameworks, scoring methods, mitigation.

### 50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning
Comprehensive advanced threat modeling and risk assessment.
Working memory stores: advanced frameworks, enterprise modeling, risk quantification.
