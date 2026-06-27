# Core Prompts Learning — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `core-prompts-learning` |
| Domain Path | `Core-Prompts-Learning/` |
| File Count | 50 prompt files |
| Registry | `Core-Prompts-Learning/registry.json` |
| Category | Learning Sessions |
| Lifecycle Scope | Content delivery workers, assessment runners, progress trackers, knowledge validators |

## Overview

This document defines the complete process lifecycle management for the Core Prompts Learning domain. The domain encompasses 50 prompt files focused on educational content delivery for bug bounty hunting, covering each vulnerability class from reconnaissance through advanced threats. The lifecycle manages learning session processes that deliver content, track progress, run assessments, and validate knowledge acquisition.

Learning processes differ from hunting processes in their emphasis on content delivery, progressive disclosure, and knowledge assessment. The lifecycle includes states for content preparation, delivery, assessment, and knowledge validation.

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
            |       |  PREPARING       |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            +-------+    DELIVERING    |
            |       |                  |
            |       +--+----+----+-----+
            |          |    |    |
            | pause    |    |    | content_complete
            |          v    |    v
            |    +-----+--+ |  +-----------+
            |    |        | |  |           |
            |    |PAUSED  | |  |ASSESSING  |
            |    |        | |  |           |
            |    +---+----+ |  +-----+-----+
            |        |      |        |
            | resume |      |   assessment_complete
            |        v      |        |
            |       +------+    +----v--------+
            |       |         |             |
            |       |         | VALIDATING  |
            |       |         |             |
            |       |         +------+------+
            |       |                |
            |       |                v
            |       |         +------+------+
            |       |         |             |
            |       |         | COMPLETED   |
            |       |         |             |
            |       |         +------+------+
            |       |                |
            +---+---+                |
            |                       |
            | (any state) --error--> +-----------+
            |                        |   FAILED  |
            |                        +-----+-----+
            |                              |
            | (any) --signal--> +----------+-------+
            |                   |    STOPPING      |
            |                   +------------------+
            |                          |
            |                          v
            +---------------------+----+------+
                                  |  STOPPED   |
                                  +------------+
```

## State Definitions

### CREATED

Process entry allocated. Learning session configuration loaded.

**Internal data:**
- Process ID assigned
- Session type: full_course, topic_specific, assessment_only
- Learner profile loaded
- All 50 file references loaded:
  - `1-Reconnaissance-and-Asset-Discovery-Learning.md`
  - `2-JavaScript-Analysis-and-Deobfuscation-Learning.md`
  - `3-API-Endpoint-Analysis-Learning.md`
  - `4-Authentication-and-Session-Management-Learning.md`
  - `5-Authorization-and-Access-Control-Learning.md`
  - `6-Input-Validation-and-Sanitization-Learning.md`
  - `7-Business-Logic-Flaws-Learning.md`
  - `8-Client-Side-Storage-Security-Learning.md`
  - `9-Cryptography-and-Data-Protection-Learning.md`
  - `10-Error-Handling-and-Information-Disclosure-Learning.md`
  - `11-File-Upload-and-Processing-Learning.md`
  - `12-Server-Side-Request-Forgery-SSRF-Learning.md`
  - `13-Cross-Site-Request-Forgery-CSRF-Learning.md`
  - `14-Cross-Origin-Resource-Sharing-CORS-Learning.md`
  - `15-Race-Conditions-and-Concurrency-Issues-Learning.md`
  - `16-Third-Party-Component-Analysis-Learning.md`
  - `17-Configuration-and-Misconfiguration-Hunting-Learning.md`
  - `18-Network-and-Infrastructure-Security-Learning.md`
  - `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md`
  - `20-Reporting-and-Proof-of-Concept-Development-Learning.md`
  - `21-Web-Application-Firewall-WAF-Bypass-Learning.md`
  - `22-HTTP-Request-Smuggling-Learning.md`
  - `23-Subdomain-Takeover-Learning.md`
  - `24-Host-Header-Injection-Learning.md`
  - `25-XML-External-Entity-XXE-Injection-Learning.md`
  - `26-Insecure-Deserialization-Learning.md`
  - `27-Command-Injection-Learning.md`
  - `28-NoSQL-Injection-Learning.md`
  - `29-GraphQL-Vulnerabilities-Learning.md`
  - `30-WebSocket-Security-Learning.md`
  - `31-Server-Side-Template-Injection-SSTI-Learning.md`
  - `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md`
  - `33-Content-Security-Policy-CSP-Bypass-Learning.md`
  - `34-Clickjacking-and-UI-Redressing-Learning.md`
  - `35-HTTP-Parameter-Pollution-Learning.md`
  - `36-LDAP-Injection-Learning.md`
  - `37-Session-Puzzling-and-Fixation-Learning.md`
  - `38-Insecure-File-Handling-Learning.md`
  - `39-Advanced-Client-Side-Attacks-Learning.md`
  - `40-Cloud-Security-and-Misconfigurations-Learning.md`
  - `41-Third-Party-Integration-Security-Learning.md`
  - `42-Mobile-Application-Security-Learning.md`
  - `43-IoT-and-Embedded-Device-Security-Learning.md`
  - `44-API-Security-and-GraphQL-Learning.md`
  - `45-WebAssembly-and-Modern-Web-Technologies-Learning.md`
  - `46-Blockchain-and-Cryptocurrency-Security-Learning.md`
  - `47-Automation-and-Tool-Development-Learning.md`
  - `48-Advanced-Reverse-Engineering-Learning.md`
  - `49-Compliance-and-Regulatory-Security-Learning.md`
  - `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md`
  - `README.md`

**Exit:** CREATED -> INITIALIZING

### INITIALIZING

Loading learning content, building content index, initializing assessment engine.

**Sub-steps:**
1. Load `Core-Prompts-Learning/registry.json`
2. Build content index from all 50 learning files
3. Load prerequisite graph (topic dependencies)
4. Initialize assessment engine
5. Initialize progress tracker
6. Load learner profile and history
7. Determine learning path based on profile

**Exit:** INITIALIZING -> PREPARING | INITIALIZING -> FAILED

### PREPARING

Preparing content for current learning module. Building interactive elements, loading examples, preparing exercises.

**Sub-states:**
- `PREPARING_CONTENT` — loading and formatting educational content
- `PREPARING_EXERCISES` — building practice exercises
- `PREPARING_ASSESSMENTS` — building quiz/test questions
- `PREPARING_EXAMPLES` — loading real-world examples

**Exit:** PREPARING -> DELIVERING (content ready) | PREPARING -> FAILED

### DELIVERING

Actively delivering educational content to the learner.

**Delivery activities:**
- Content presentation (structured learning material)
- Interactive examples walkthrough
- Guided practice exercises
- Real-world case study discussion
- Tool demonstration (if applicable)

**Content modules (organized by topic):**

*Reconnaissance and Discovery:*
- `1-Reconnaissance-and-Asset-Discovery-Learning.md`
- `3-API-Endpoint-Analysis-Learning.md`
- `18-Network-and-Infrastructure-Security-Learning.md`

*Client-Side Security:*
- `2-JavaScript-Analysis-and-Deobfuscation-Learning.md`
- `8-Client-Side-Storage-Security-Learning.md`
- `33-Content-Security-Policy-CSP-Bypass-Learning.md`
- `34-Clickjacking-and-UI-Redressing-Learning.md`
- `39-Advanced-Client-Side-Attacks-Learning.md`
- `45-WebAssembly-and-Modern-Web-Technologies-Learning.md`

*Authentication and Session:*
- `4-Authentication-and-Session-Management-Learning.md`
- `5-Authorization-and-Access-Control-Learning.md`
- `37-Session-Puzzling-and-Fixation-Learning.md`

*Input-Based Vulnerabilities:*
- `6-Input-Validation-and-Sanitization-Learning.md`
- `11-File-Upload-and-Processing-Learning.md`
- `25-XML-External-Entity-XXE-Injection-Learning.md`
- `27-Command-Injection-Learning.md`
- `28-NoSQL-Injection-Learning.md`
- `31-Server-Side-Template-Injection-SSTI-Learning.md`
- `35-HTTP-Parameter-Pollution-Learning.md`
- `36-LDAP-Injection-Learning.md`
- `38-Insecure-File-Handling-Learning.md`
- `42-XPath-Injection-Learning.md` (via 42-Mobile-Application-Security)

*Business Logic:*
- `7-Business-Logic-Flaws-Learning.md`
- `15-Race-Conditions-and-Concurrency-Issues-Learning.md`

*Web Infrastructure:*
- `9-Cryptography-and-Data-Protection-Learning.md`
- `10-Error-Handling-and-Information-Disclosure-Learning.md`
- `12-Server-Side-Request-Forgery-SSRF-Learning.md`
- `13-Cross-Site-Request-Forgery-CSRF-Learning.md`
- `14-Cross-Origin-Resource-Sharing-CORS-Learning.md`
- `16-Third-Party-Component-Analysis-Learning.md`
- `17-Configuration-and-Misconfiguration-Hunting-Learning.md`
- `21-Web-Application-Firewall-WAF-Bypass-Learning.md`
- `22-HTTP-Request-Smuggling-Learning.md`
- `23-Subdomain-Takeover-Learning.md`
- `24-Host-Header-Injection-Learning.md`
- `26-Insecure-Deserialization-Learning.md`
- `29-GraphQL-Vulnerabilities-Learning.md`
- `30-WebSocket-Security-Learning.md`
- `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md`
- `41-Third-Party-Integration-Security-Learning.md`

*Advanced Topics:*
- `39-Advanced-Client-Side-Attacks-Learning.md`
- `40-Cloud-Security-and-Misconfigurations-Learning.md`
- `43-IoT-and-Embedded-Device-Security-Learning.md`
- `44-API-Security-and-GraphQL-Learning.md`
- `46-Blockchain-and-Cryptocurrency-Security-Learning.md`
- `47-Automation-and-Tool-Development-Learning.md`
- `48-Advanced-Reverse-Engineering-Learning.md`
- `49-Compliance-and-Regulatory-Security-Learning.md`
- `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md`

*Reporting:*
- `20-Reporting-and-Proof-of-Concept-Development-Learning.md`

**Exit:** DELIVERING -> ASSESSING (content complete) | DELIVERING -> PAUSED | DELIVERING -> FAILED

### PAUSED

Learning session paused. Progress saved. Content state preserved.

**Exit:** PAUSED -> DELIVERING (resume) | PAUSED -> STOPPING

### ASSESSING

Running assessment to evaluate knowledge acquisition.

**Assessment types:**
- Knowledge quiz (conceptual understanding)
- Practical exercise (hands-on skill)
- Code review exercise (analysis skill)
- Report writing exercise (communication skill)
- Scenario-based assessment (applied knowledge)

**Exit:** ASSESSING -> VALIDATING (assessment complete) | ASSESSING -> FAILED

### VALIDATING

Validating assessment results and knowledge acquisition.

**Validation checks:**
- Score threshold met (default: 70%)
- All required topics covered
- Practical skills demonstrated
- Knowledge gaps identified
- Learning path recommendation generated

**Exit:** VALIDATING -> COMPLETED (passed) | VALIDATING -> DELIVERING (needs review) | VALIDATING -> FAILED

### COMPLETED

Learning session finished. Knowledge validated. Progress updated.

**Exit:** COMPLETED -> STOPPED

### STOPPING

Graceful shutdown. Learning progress saved, assessment results persisted.

**Exit:** STOPPING -> STOPPED

### STOPPED

Terminal state. All learning workers terminated.

## Start Operations

```
1. Receive start command with learner profile
2. Transition: CREATED -> INITIALIZING
3. Load learner profile and history
4. Determine learning path
5. Transition: INITIALIZING -> PREPARING
6. Prepare first module content
7. Transition: PREPARING -> DELIVERING
8. Deliver content
9. Transition: DELIVERING -> ASSESSING
10. Run assessment
11. Transition: ASSESSING -> VALIDATING
12. Validate results
13. Transition: VALIDATING -> COMPLETED
```

## Stop Operations

```
1. Receive stop signal
2. Transition: CURRENT_STATE -> STOPPING
3. Save learning progress
4. Save assessment results
5. Release content caches
6. Transition: STOPPING -> STOPPED
```

## Graceful Shutdown Protocol

### Phase 1: Progress Save (0-10s)
- Save current module progress
- Save quiz/assessment state
- Record time spent

### Phase 2: Content Release (10-30s)
- Release loaded content buffers
- Clear content caches
- Release media resources

### Phase 3: State Persistence (30-45s)
- Write final progress to learner profile
- Save assessment scores
- Update knowledge graph
- Write session summary

## Signal Handling

| Signal | Handler | Action |
|--------|---------|--------|
| `SIGTERM` | `handle_graceful_shutdown()` | Save progress, release, shutdown |
| `SIGINT` | `handle_graceful_shutdown()` | Same as SIGTERM |
| `SIGHUP` | `handle_content_refresh()` | Reload current module content |
| `SIGUSR1` | `handle_progress_dump()` | Dump current progress to log |
| `SIGUSR2` | `handle_module_skip()` | Skip to next module (debug) |
| `SIGKILL` | (OS default) | Immediate termination |

## Health Monitoring

| Metric | Description | Alert |
|--------|-------------|-------|
| `current_module` | Active learning module | N/A (info) |
| `modules_completed` | Modules finished | N/A (info) |
| `assessment_score` | Current assessment score | N/A (info) |
| `content_delivery_rate` | Content items/minute | < 1 |
| `assessment_completion_rate` | Assessment completion % | N/A (info) |
| `memory_usage_mb` | Process memory | > 512 MB |
| `session_duration_minutes` | Time in session | > 480 (8h) |

## Resource Limits

| Resource | Limit | Action |
|----------|-------|--------|
| Memory | 512 MB | Release completed module content |
| CPU | 0.5 cores | Throttle content rendering |
| Content cache | 256 MB | Evict old modules |
| Assessment buffer | 64 MB | Flush completed assessments |
| Session timeout | 28800s (8h) | Auto-save and pause |

## Domain File References

All 50 learning files serve as content modules for the delivery engine. Each file is loaded on-demand when the learner reaches that module. The registry maps file dependencies and prerequisite relationships.

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Learning Manager
        |
        +-- Content Delivery Worker
        |     +-- Content Loader
        |     +-- Content Renderer
        |     +-- Media Handler
        |
        +-- Assessment Runner
        |     +-- Quiz Engine
        |     +-- Practical Exercise Engine
        |     +-- Code Review Engine
        |
        +-- Progress Tracker
        |     +-- Module Progress
        |     +-- Score Tracker
        |     +-- Knowledge Graph
        |
        +-- Knowledge Validator
              +-- Score Validator
              +-- Gap Analyzer
              +-- Path Recommender
```

## Inter-Process Communication

### Message Types

| Message | Producer | Consumer | Description |
|---------|----------|----------|-------------|
| `content.request` | Learning Manager | Content Delivery | Request content |
| `assessment.start` | Content Delivery | Assessment Runner | Begin assessment |
| `assessment.complete` | Assessment Runner | Validator | Assessment done |
| `progress.update` | All Workers | Progress Tracker | State update |
| `knowledge.gap` | Knowledge Validator | Content Delivery | Gap identified |
| `module.complete` | Knowledge Validator | Manager | Module done |
| `session.pause` | Learning Manager | All Workers | Session paused |
| `session.resume` | Learning Manager | All Workers | Session resumed |

### Content Module Dependencies

```
Foundation Modules (no prerequisites):
  1-Reconnaissance-and-Asset-Discovery-Learning.md
  6-Input-Validation-and-Sanitization-Learning.md
  9-Cryptography-and-Data-Protection-Learning.md

Intermediate Modules (require foundation):
  2-JavaScript-Analysis-and-Deobfuscation-Learning.md (requires 1)
  3-API-Endpoint-Analysis-Learning.md (requires 1)
  4-Authentication-and-Session-Management-Learning.md (requires 6)
  5-Authorization-and-Access-Control-Learning.md (requires 4)
  7-Business-Logic-Flaws-Learning.md (requires 4, 5)

Advanced Modules (require intermediate):
  12-Server-Side-Request-Forgery-SSRF-Learning.md (requires 3)
  25-XML-External-Entity-XXE-Injection-Learning.md (requires 6)
  27-Command-Injection-Learning.md (requires 6)
  31-Server-Side-Template-Injection-SSTI-Learning.md (requires 6)
  40-Cloud-Security-and-Misconfigurations-Learning.md (requires 3, 5)

Expert Modules (require advanced):
  21-Web-Application-Firewall-WAF-Bypass-Learning.md (requires 12, 25)
  22-HTTP-Request-Smuggling-Learning.md (requires 12)
  39-Advanced-Client-Side-Attacks-Learning.md (requires 2, 8)
  48-Advanced-Reverse-Engineering-Learning.md (requires 9, 30)
  50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md (all advanced)
```

### Assessment Question Types

| Type | Weight | Description |
|------|--------|-------------|
| Multiple Choice | 0.2 | Conceptual understanding |
| Code Review | 0.3 | Analysis skill |
| Practical Exercise | 0.3 | Hands-on skill |
| Report Writing | 0.1 | Communication skill |
| Scenario-Based | 0.1 | Applied knowledge |

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `learning.session_timeout` | 28800 | Session timeout (seconds) |
| `learning.pass_threshold` | 0.7 | Minimum assessment score |
| `learning.content_cache_mb` | 256 | Content cache size |
| `learning.auto_advance` | true | Auto-advance on pass |
| `learning.retry_on_fail` | true | Allow retry on fail |
| `learning.max_retries` | 3 | Max retries per module |
| `learning.track_time` | true | Track time per module |
| `learning.feedback_detail` | high | Assessment feedback level |
| `learning.prerequisite_enforcement` | strict | Prerequisite enforcement |
| `learning.progress_persistence` | true | Persist across sessions |
| `learning.assessment_randomization` | true | Randomize questions |
