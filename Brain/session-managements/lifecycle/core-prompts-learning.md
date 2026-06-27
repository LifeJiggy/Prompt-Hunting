# Session Lifecycle: Core Prompts Learning Domain

> Session lifecycle management for learner progress tracking, educational module progression, and skill development across all 50 Core-Prompts-Learning modules.

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | `core-prompts-learning` |
| Source Directory | `Core-Prompts-Learning/` |
| Module Count | 50 |
| Session Type | `learning-session` |
| State Complexity | Medium — tracks learner progress, module completion, and skill assessment |
| Parent System | Session Lifecycle Manager |

## Overview

This document defines the complete session lifecycle for the Core Prompts Learning domain. Learning sessions manage the educational journey of a researcher through structured vulnerability learning modules. Each session tracks which learning modules are loaded, the current learning phase, module completion status, knowledge assessments, and skill progression.

Learning sessions are educational in nature. They guide researchers through understanding vulnerability classes, detection techniques, exploitation methods, and mitigation strategies. The lifecycle tracks progression through modules, knowledge retention, and practical skill development.

## Session State Machine

```
┌─────────┐     activate      ┌──────────┐
│ created │ ─────────────────→│  active   │
└─────────┘                   └────┬─────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │enrolling │              │studying  │              │practicing│
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │assessing │              │reviewing │              │advanced  │
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       └──────────────────────────┼──────────────────────────┘
                                  ▼
                           ┌──────────┐
                           │graduated │
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
| `created` | Session initialized; learning path defined |
| `active` | Session running; learning workflow active |
| `enrolling` | Enrolling in learning modules |
| `studying` | Active study of module content |
| `practicing` | Practical exercises and lab work |
| `assessing` | Knowledge assessment and testing |
| `reviewing` | Reviewing completed material |
| `advanced` | Advanced topics and specializations |
| `graduated` | Learning objectives achieved |
| `closed` | Session terminated and progress archived |

## Session Creation

### `create_learning_session()`

Creates a new session for a learning workflow.

**Parameters:**
- `name` (str): Human-readable session identifier
- `learner_id` (str): Learner identifier
- `learning_path` (str): Prescribed learning path
- `modules` (list[str]): Learning modules to load
- `skill_level` (str): Current skill level (beginner, intermediate, advanced)
- `learning_goals` (list[str]): Specific learning objectives
- `max_duration` (int): Maximum session lifetime in seconds (default: `43200` — 12 hours)
- `auto_checkpoint` (bool): Enable automatic state checkpointing (default: `True`)

**Returns:** `Session` object with unique ID, learning path, and initial skill level.

**Validation:**
- Session name must be unique
- Learner ID must be valid
- Module references must exist in the directory
- Skill level must be from recognized set

**Initialization Steps:**
1. Generate session ID: `learn_ses_<40-char-hex>`
2. Validate learning path and modules
3. Create session directory: `sessions/<session_id>/`
4. Initialize progress tracker
5. Register session in the active learning session registry
6. Emit `session.created` event

## Session Close

### `close_learning_session(session_id)`

Gracefully terminates a learning session.

**Pre-close Checks:**
1. Verify all module progress is saved
2. Check if learning goals are met
3. Ensure assessment results are recorded

**Close Process:**
1. Transition state to `closing`
2. Generate learning progress report
3. Archive module completion status
4. Save assessment results
5. Update learner skill profile
6. Remove session from active registry
7. Transition state to `closed`
8. Emit `session.closed` event

## Session Suspend

### `suspend_learning_session(session_id)`

Pauses an active learning session.

**Suspend Process:**
1. Complete current study unit
2. Serialize learning state including:
   - Current module and position
   - Completed modules and scores
   - Pending assessments
   - Notes and bookmarks
3. Save learning progress
4. Transition state to `suspended`

## Session Resume

### `resume_learning_session(session_id)`

Restores a suspended learning session.

**Resume Process:**
1. Load serialized learning state
2. Verify state integrity
3. Restore module position
4. Resume study from last position
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

### Learning-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `learner_id` | str | Learner identifier |
| `learning_path` str | Prescribed learning path |
| `skill_level` | str | Current skill level |
| `modules_loaded` | list[str] | Learning modules loaded |
| `current_module` | str | Currently active module |
| `current_position` | int | Position within current module |
| `modules_completed` | list[str] | Completed modules |
| `module_scores` | dict[str, int] | Assessment scores per module |
| `total_study_time` | int | Total study time in seconds |
| `learning_goals` | list[str] | Learning objectives |
| `goals_met` | list[str] | Achieved learning goals |
| `notes` | list[dict] | Learner notes and bookmarks |
| `skill_assessment` | dict | Current skill assessment results |
| `practical_exercises` | list[dict] | Completed practical exercises |

## Session Lookup

### `find_learning_sessions()`

Search for learning sessions by criteria.

**Search Parameters:**
- `state` (str): Filter by session state
- `learner_id` (str): Filter by learner
- `skill_level` | Filter by skill level
- `module` (str): Filter by loaded module
- `completed` (bool): Filter by completion status

**Examples:**
```python
# Find all active learning sessions
sessions = find_learning_sessions(state="active")

# Find sessions for a specific learner
sessions = find_learning_sessions(learner_id="researcher-01")
```

## Session Limits

### Learning-Specific Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_learning_sessions` | 3 | Concurrent learning sessions |
| `max_modules_per_session` | 10 | Learning modules per session |
| `max_session_duration` | 43200s (12h) | Maximum learning runtime |
| `max_assessments_per_session` | 50 | Assessments per session |
| `max_notes_per_session` | 200 | Notes per session |
| `max_practical_exercises` | 30 | Practical exercises per session |
| `max_state_size` | 20MB | Serialized state size limit |

## Session Isolation

### File System Isolation

```
sessions/<session_id>/
├── state/
│   ├── learning-state.json     # Learning phase tracker
│   ├── module-progress/        # Per-module progress
│   ├── assessments/            # Assessment results
│   └── checkpoints/            # Serialized checkpoints
├── output/
│   ├── progress-report.json    # Learning progress report
│   ├── skill-assessment.json   # Skill assessment results
│   ├── notes/                  # Learner notes
│   └── certificates/           # Module completion certificates
├── config/
│   ├── learning-config.json    # Session configuration
│   ├── learning-path.json      # Prescribed learning path
│   └── goals.json              # Learning goals
└── metadata.json               # Session metadata
```

## Module References for Core Prompts Learning

| Module | File Reference |
|--------|---------------|
| Reconnaissance and Asset Discovery Learning | `Core-Prompts-Learning/1-Reconnaissance-and-Asset-Discovery-Learning.md` |
| JavaScript Analysis and Deobfuscation Learning | `Core-Prompts-Learning/2-JavaScript-Analysis-and-Deobfuscation-Learning.md` |
| API Endpoint Analysis Learning | `Core-Prompts-Learning/3-API-Endpoint-Analysis-Learning.md` |
| Authentication and Session Management Learning | `Core-Prompts-Learning/4-Authentication-and-Session-Management-Learning.md` |
| Authorization and Access Control Learning | `Core-Prompts-Learning/5-Authorization-and-Access-Control-Learning.md` |
| Input Validation and Sanitization Learning | `Core-Prompts-Learning/6-Input-Validation-and-Sanitization-Learning.md` |
| Business Logic Flaws Learning | `Core-Prompts-Learning/7-Business-Logic-Flaws-Learning.md` |
| Client-Side Storage Security Learning | `Core-Prompts-Learning/8-Client-Side-Storage-Security-Learning.md` |
| Cryptography and Data Protection Learning | `Core-Prompts-Learning/9-Cryptography-and-Data-Protection-Learning.md` |
| Error Handling and Information Disclosure Learning | `Core-Prompts-Learning/10-Error-Handling-and-Information-Disclosure-Learning.md` |
| File Upload and Processing Learning | `Core-Prompts-Learning/11-File-Upload-and-Processing-Learning.md` |
| Server-Side Request Forgery (SSRF) Learning | `Core-Prompts-Learning/12-Server-Side-Request-Forgery-SSRF-Learning.md` |
| Cross-Site Request Forgery (CSRF) Learning | `Core-Prompts-Learning/13-Cross-Site-Request-Forgery-CSRF-Learning.md` |
| Cross-Origin Resource Sharing (CORS) Learning | `Core-Prompts-Learning/14-Cross-Origin-Resource-Sharing-CORS-Learning.md` |
| Race Conditions and Concurrency Issues Learning | `Core-Prompts-Learning/15-Race-Conditions-and-Concurrency-Issues-Learning.md` |
| Third-Party Component Analysis Learning | `Core-Prompts-Learning/16-Third-Party-Component-Analysis-Learning.md` |
| Configuration and Misconfiguration Hunting Learning | `Core-Prompts-Learning/17-Configuration-and-Misconfiguration-Hunting-Learning.md` |
| Network and Infrastructure Security Learning | `Core-Prompts-Learning/18-Network-and-Infrastructure-Security-Learning.md` |
| Mobile and API-Specific Vulnerabilities Learning | `Core-Prompts-Learning/19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` |
| Reporting and Proof-of-Concept Development Learning | `Core-Prompts-Learning/20-Reporting-and-Proof-of-Concept-Development-Learning.md` |
| Web Application Firewall (WAF) Bypass Learning | `Core-Prompts-Learning/21-Web-Application-Firewall-WAF-Bypass-Learning.md` |
| HTTP Request Smuggling Learning | `Core-Prompts-Learning/22-HTTP-Request-Smuggling-Learning.md` |
| Subdomain Takeover Learning | `Core-Prompts-Learning/23-Subdomain-Takeover-Learning.md` |
| Host Header Injection Learning | `Core-Prompts-Learning/24-Host-Header-Injection-Learning.md` |
| XML External Entity (XXE) Injection Learning | `Core-Prompts-Learning/25-XML-External-Entity-XXE-Injection-Learning.md` |
| Insecure Deserialization Learning | `Core-Prompts-Learning/26-Insecure-Deserialization-Learning.md` |
| Command Injection Learning | `Core-Prompts-Learning/27-Command-Injection-Learning.md` |
| NoSQL Injection Learning | `Core-Prompts-Learning/28-NoSQL-Injection-Learning.md` |
| GraphQL Vulnerabilities Learning | `Core-Prompts-Learning/29-GraphQL-Vulnerabilities-Learning.md` |
| WebSocket Security Learning | `Core-Prompts-Learning/30-WebSocket-Security-Learning.md` |
| Server-Side Template Injection (SSTI) Learning | `Core-Prompts-Learning/31-Server-Side-Template-Injection-SSTI-Learning.md` |
| JSON Web Token (JWT) Vulnerabilities Learning | `Core-Prompts-Learning/32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` |
| Content Security Policy (CSP) Bypass Learning | `Core-Prompts-Learning/33-Content-Security-Policy-CSP-Bypass-Learning.md` |
| Clickjacking and UI Redressing Learning | `Core-Prompts-Learning/34-Clickjacking-and-UI-Redressing-Learning.md` |
| HTTP Parameter Pollution Learning | `Core-Prompts-Learning/35-HTTP-Parameter-Pollution-Learning.md` |
| LDAP Injection Learning | `Core-Prompts-Learning/36-LDAP-Injection-Learning.md` |
| Session Puzzling and Fixation Learning | `Core-Prompts-Learning/37-Session-Puzzling-and-Fixation-Learning.md` |
| Insecure File Handling Learning | `Core-Prompts-Learning/38-Insecure-File-Handling-Learning.md` |
| Advanced Client-Side Attacks Learning | `Core-Prompts-Learning/39-Advanced-Client-Side-Attacks-Learning.md` |
| Cloud Security and Misconfigurations Learning | `Core-Prompts-Learning/40-Cloud-Security-and-Misconfigurations-Learning.md` |
| Third-Party Integration Security Learning | `Core-Prompts-Learning/41-Third-Party-Integration-Security-Learning.md` |
| Mobile Application Security Learning | `Core-Prompts-Learning/42-Mobile-Application-Security-Learning.md` |
| IoT and Embedded Device Security Learning | `Core-Prompts-Learning/43-IoT-and-Embedded-Device-Security-Learning.md` |
| API Security and GraphQL Learning | `Core-Prompts-Learning/44-API-Security-and-GraphQL-Learning.md` |
| WebAssembly and Modern Web Technologies Learning | `Core-Prompts-Learning/45-WebAssembly-and-Modern-Web-Technologies-Learning.md` |
| Blockchain and Cryptocurrency Security Learning | `Core-Prompts-Learning/46-Blockchain-and-Cryptocurrency-Security-Learning.md` |
| Automation and Tool Development Learning | `Core-Prompts-Learning/47-Automation-and-Tool-Development-Learning.md` |
| Advanced Reverse Engineering Learning | `Core-Prompts-Learning/48-Advanced-Reverse-Engineering-Learning.md` |
| Compliance and Regulatory Security Learning | `Core-Prompts-Learning/49-Compliance-and-Regulatory-Security-Learning.md` |
| Advanced Threat Modeling and Risk Assessment Learning | `Core-Prompts-Learning/50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` |

## Events

### Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `learning.session.created` | session_id, learner_id | New learning session created |
| `learning.module.started` | session_id, module_name | Module study started |
| `learning.module.completed` | session_id, module_name, score | Module completed |
| `learning.unit.completed` | session_id, unit, position | Study unit completed |
| `learning.assessment.taken` | session_id, assessment_id | Assessment taken |
| `learning.assessment.passed` | session_id, assessment_id, score | Assessment passed |
| `learning.exercise.completed` | session_id, exercise_id | Practical exercise completed |
| `learning.note.added` | session_id, note | Note added |
| `learning.skill.upgraded` | session_id, skill, level | Skill level upgraded |
| `learning.session.suspended` | session_id, reason | Session suspended |
| `learning.session.resumed` | session_id | Session resumed |
| `learning.session.graduated` | session_id, goals_met | Learning goals achieved |
| `learning.session.closed` | session_id | Session closed |

## Error Recovery

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| Module Load Failure | Incompatible module | Skip module; suggest alternative |
| Assessment Error | Scoring system failure | Retry assessment |
| Progress Loss | Checkpoint corruption | Restore from backup |
| State Corruption | Checksum mismatch | Restore from last valid checkpoint |

## Usage Examples

### Creating a Learning Session

```python
session = create_learning_session(
    name="learn-web-security",
    learner_id="researcher-01",
    learning_path="web-security-fundamentals",
    modules=[
        "6-Input-Validation-and-Sanitization-Learning.md",
        "7-Business-Logic-Flaws-Learning.md",
        "12-Server-Side-Request-Forgery-SSRF-Learning.md"
    ],
    skill_level="beginner",
    learning_goals=["understand_sqli", "master_xss_detection"]
)
```

### Querying Learning Progress

```python
sessions = find_learning_sessions(
    learner_id="researcher-01",
    completed=True
)
for s in sessions:
    print(f"Path: {s.learning_path}, "
          f"Completed: {len(s.modules_completed)}, "
          f"Goals met: {s.goals_met}")
```
