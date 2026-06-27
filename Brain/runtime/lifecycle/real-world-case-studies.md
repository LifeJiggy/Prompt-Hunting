# Real-World Case Studies — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `real-world-case-studies` |
| Domain Path | `Real-World-Case-Studies/` |
| File Count | 50 prompt files |
| Registry | `Real-World-Case-Studies/registry.json` |
| Category | Disclosed Vulnerability Analysis |
| Lifecycle Scope | Pattern extraction workers, vulnerability analyzers, trend detectors, intelligence generators |

## Overview

This document defines the complete process lifecycle management for the Real-World Case Studies domain. The domain encompasses 50 prompt files analyzing disclosed vulnerability case studies across all major vulnerability classes, from IDOR to API authentication bypass. The lifecycle manages analysis processes that extract exploitation patterns, identify trends, build knowledge bases, and generate actionable intelligence from real-world disclosed vulnerabilities.

Real-world case study analysis differs from high-level case studies in its focus on specific vulnerability classes and exploitation techniques. Each file provides detailed analysis of how a particular vulnerability class manifests in real-world scenarios, providing practical intelligence for hunting operations.

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
            +-------+    RUNNING       |
            |       |                  |
            |       +--+----+----+-----+
            |          |    |    |
            | pause    |    |    | complete
            |          v    |    v
            |    +-----+--+ |  +-----------+
            |    |        | |  |           |
            |    |PAUSED  | |  |COMPLETED  |
            |    |        | |  |           |
            |    +---+----+ |  +-----------+
            |        |      |
            | resume |      | error
            |        v      v
            +-------+------+------+
                           |
                           v
                    +------+------+
                    |             |
                    |  STOPPING   |
                    |             |
                    +------+------+
                           |
                           v
                    +------+------+
                    |             |
                    |   STOPPED   |
                    |             |
                    +-------------+
```

## State Definitions

### CREATED

Process entry allocated. Analysis scope determined.

**Internal data:**
- Process ID assigned
- Analysis type: vuln_class_analysis, exploitation_pattern, trend_detection
- All 50 file references loaded:
  - `01-IDOR-Account-Takeover-Case-Studies.md`
  - `02-XSS-Stored-Persistent-Attacks.md`
  - `03-SQL-Injection-Data-Breaches.md`
  - `04-SSRF-Internal-Network-Access.md`
  - `05-CSRF-State-Changing-Attacks.md`
  - `06-Command-Injection-RCE.md`
  - `07-Deserialization-Remote-Code-Execution.md`
  - `08-File-Upload-Arbitrary-Upload.md`
  - `09-XXE-XML-External-Entity-Attacks.md`
  - `10-SSTI-Server-Side-Template-Injection.md`
  - `11-JWT-Token-Manipulation.md`
  - `12-Authentication-Bypass.md`
  - `13-Privilege-Escalation.md`
  - `14-Business-Logic-Flaws.md`
  - `15-Information-Disclosure.md`
  - `16-Memory-Corruption-Heap-Overflow.md`
  - `17-Deserialization-Java-Deserialization.md`
  - `18-Deserialization-PHP-Unserialize.md`
  - `19-Deserialization-Python-Pickle.md`
  - `20-Race-Condition-Time-of-Check.md`
  - `21-Host-Header-Injection.md`
  - `22-DNS-Rebinding-Attacks.md`
  - `23-WebSocket-Security-Issues.md`
  - `24-GraphQL-Introspection-Attacks.md`
  - `25-CSP-Bypass-Techniques.md`
  - `26-Clickjacking-UI-Redressing.md`
  - `27-HTTP-Response-Splitting.md`
  - `28-LDAP-Injection-Attacks.md`
  - `29-XPath-Injection-Attacks.md`
  - `30-NoSQL-Injection-MongoDB.md`
  - `31-Prototype-Pollution-JavaScript.md`
  - `32-Subdomain-Takeover.md`
  - `33-Open-Redirect-Phishing.md`
  - `34-Content-Spoofing-Attacks.md`
  - `35-WebCache-Poisoning.md`
  - `36-HTTP-Request-Smuggling.md`
  - `37-WebSocket-Hijacking.md`
  - `38-CORS-Misconfiguration.md`
  - `39-Token-Leakage-URL-Parameters.md`
  - `40-Sensitive-Data-Exposure.md`
  - `41-Weak-Encryption-Algorithms.md`
  - `42-Insecure-Cryptographic-Storage.md`
  - `43-Path-Traversal-File-Inclusion.md`
  - `44-Local-File-Inclusion-LFI.md`
  - `45-Remote-File-Inclusion-RFI.md`
  - `46-Server-Side-Request-Forgery.md`
  - `47-Client-Side-Request-Forgery.md`
  - `48-Mobile-API-Security-Issues.md`
  - `49-Cloud-Misconfiguration-AWS.md`
  - `50-API-Authentication-Bypass.md`
  - `README.md`

**Exit:** CREATED -> INITIALIZING

### INITIALIZING

Loading case study data, building vulnerability class index, initializing extraction engines.

**Sub-steps:**
1. Load `Real-World-Case-Studies/registry.json`
2. Build vulnerability class index from all 50 files
3. Initialize pattern extraction engine
4. Initialize trend detection engine
5. Load historical exploitation patterns
6. Configure analysis parameters per vuln class

**Exit:** INITIALIZING -> RUNNING | INITIALIZING -> FAILED

### RUNNING

Case analysis actively processing. Workers analyzing vulnerability classes in parallel.

**Analysis activities per vulnerability class:**

*Injection Vulnerabilities:*
- `03-SQL-Injection-Data-Breaches.md` — SQLi pattern extraction
- `06-Command-Injection-RCE.md` — Command injection patterns
- `09-XXE-XML-External-Entity-Attacks.md` — XXE patterns
- `10-SSTI-Server-Side-Template-Injection.md` — SSTI patterns
- `28-LDAP-Injection-Attacks.md` — LDAP injection patterns
- `29-XPath-Injection-Attacks.md` — XPath injection patterns
- `30-NoSQL-Injection-MongoDB.md` — NoSQL injection patterns

*Authentication and Session:*
- `12-Authentication-Bypass.md` — Auth bypass patterns
- `11-JWT-Token-Manipulation.md` — JWT attack patterns
- `39-Token-Leakage-URL-Parameters.md` — Token leakage patterns
- `50-API-Authentication-Bypass.md` — API auth bypass patterns
- `37-WebSocket-Hijacking.md` — WebSocket hijacking patterns

*Authorization:*
- `01-IDOR-Account-Takeover-Case-Studies.md` — IDOR patterns
- `13-Privilege-Escalation.md` — Privesc patterns

*Cross-Site Attacks:*
- `02-XSS-Stored-Persistent-Attacks.md` — XSS patterns
- `05-CSRF-State-Changing-Attacks.md` — CSRF patterns
- `25-CSP-Bypass-Techniques.md` — CSP bypass patterns
- `26-Clickjacking-UI-Redressing.md` — Clickjacking patterns
- `31-Prototype-Pollution-JavaScript.md` — Prototype pollution patterns

*Server-Side Attacks:*
- `04-SSRF-Internal-Network-Access.md` — SSRF patterns
- `46-Server-Side-Request-Forgery.md` — SSRF patterns
- `47-Client-Side-Request-Forgery.md` — CSRF patterns
- `21-Host-Header-Injection.md` — Host header patterns
- `27-HTTP-Response-Splitting.md` — Response splitting patterns
- `36-HTTP-Request-Smuggling.md` — HTTP smuggling patterns

*Deserialization:*
- `07-Deserialization-Remote-Code-Execution.md` — General deser patterns
- `17-Deserialization-Java-Deserialization.md` — Java deser patterns
- `18-Deserialization-PHP-Unserialize.md` — PHP deser patterns
- `19-Deserialization-Python-Pickle.md` — Python deser patterns
- `16-Memory-Corruption-Heap-Overflow.md` — Memory corruption patterns

*File and Path:*
- `08-File-Upload-Arbitrary-Upload.md` — File upload patterns
- `43-Path-Traversal-File-Inclusion.md` — Path traversal patterns
- `44-Local-File-Inclusion-LFI.md` — LFI patterns
- `45-Remote-File-Inclusion-RFI.md` — RFI patterns

*Information and Configuration:*
- `14-Business-Logic-Flaws.md` — Business logic patterns
- `15-Information-Disclosure.md` — Info disclosure patterns
- `40-Sensitive-Data-Exposure.md` — Data exposure patterns
- `41-Weak-Encryption-Algorithms.md` — Weak crypto patterns
- `42-Insecure-Cryptographic-Storage.md` — Crypto storage patterns

*Infrastructure:*
- `22-DNS-Rebinding-Attacks.md` — DNS rebinding patterns
- `24-GraphQL-Introspection-Attacks.md` — GraphQL patterns
- `32-Subdomain-Takeover.md` — Subdomain takeover patterns
- `33-Open-Redirect-Phishing.md` — Open redirect patterns
- `34-Content-Spoofing-Attacks.md` — Content spoofing patterns
- `35-WebCache-Poisoning.md` — Cache poisoning patterns
- `38-CORS-Misconfiguration.md` — CORS patterns

*Platform-Specific:*
- `23-WebSocket-Security-Issues.md` — WebSocket security patterns
- `48-Mobile-API-Security-Issues.md` — Mobile API patterns
- `49-Cloud-Misconfiguration-AWS.md` — AWS misconfig patterns
- `20-Race-Condition-Time-of-Check.md` — Race condition patterns

**Exit:** RUNNING -> PAUSED | RUNNING -> COMPLETED | RUNNING -> STOPPING | RUNNING -> FAILED

### PAUSED

Analysis suspended. Extracted patterns retained.

**Exit:** PAUSED -> RUNNING | PAUSED -> STOPPING

### COMPLETED

All 50 case studies analyzed. Final intelligence report generated.

**Exit:** COMPLETED -> STOPPED

### STOPPING

Graceful shutdown. Pattern database updated.

**Exit:** STOPPING -> STOPPED

### STOPPED

Terminal state. All workers terminated.

## Start Operations

```
1. Receive start command
2. Transition: CREATED -> INITIALIZING
3. Load case study data for all 50 files
4. Build vulnerability class index
5. Initialize extraction engines
6. Transition: INITIALIZING -> RUNNING
7. Analyze each vulnerability class
8. Extract exploitation patterns
9. Detect trends across classes
10. Generate intelligence report
11. Transition: RUNNING -> COMPLETED
```

## Stop Operations

```
1. Receive stop signal
2. Transition: RUNNING -> STOPPING
3. Complete current class analysis
4. Persist extracted patterns
5. Update pattern database
6. Write final intelligence report
7. Transition: STOPPING -> STOPPED
```

## Graceful Shutdown Protocol

### Phase 1: Analysis Completion (0-60s)
- Finish current vulnerability class analysis
- Complete pattern extraction for in-progress files

### Phase 2: Pattern Database Update (60-120s)
- Merge new patterns with existing database
- Update trend indices
- Recalculate pattern frequencies

### Phase 3: State Persistence (120-150s)
- Save updated pattern database
- Write intelligence summary
- Update case study index

### Phase 4: Resource Release (150-180s)
- Release analysis engine resources
- Close database connections
- Write shutdown log

## Signal Handling

| Signal | Handler | Action |
|--------|---------|--------|
| `SIGTERM` | `handle_graceful_shutdown()` | Complete analysis, persist, shutdown |
| `SIGINT` | `handle_graceful_shutdown()` | Same as SIGTERM |
| `SIGHUP` | `handle_data_refresh()` | Reload case study data |
| `SIGUSR1` | `handle_pattern_dump()` | Dump current patterns to log |
| `SIGUSR2` | `handle_trend_recalc()` | Force trend recalculation |
| `SIGKILL` | (OS default) | Immediate termination |

## Health Monitoring

| Metric | Description | Alert |
|--------|-------------|-------|
| `cases_analyzed` | Cases processed | N/A (info) |
| `patterns_per_class` | Patterns per vuln class | N/A (info) |
| `total_patterns` | Total extracted patterns | N/A (info) |
| `trend_changes_detected` | New trends found | N/A (info) |
| `analysis_cycle_time` | Time per cycle | > 1800 |
| `memory_usage_mb` | Process memory | > 1024 MB |
| `pattern_db_size` | Pattern DB entries | > 100000 |

## Resource Limits

| Resource | Limit | Action |
|----------|-------|--------|
| Memory | 1024 MB | Evict old patterns |
| CPU | 2 cores | Throttle analysis |
| Pattern database | 100000 entries | LRU eviction |
| Case study cache | 50 files | Load on demand |
| Report files | 100 MB | Rotate old reports |

## Domain File References

All 50 files serve as discrete analysis units. See the RUNNING state definition for the complete organized listing of all 50 files grouped by vulnerability class.

## Inter-Process Communication

### Message Types

| Message | Producer | Consumer | Description |
|---------|----------|----------|-------------|
| `case.analyzed` | Analysis Worker | Pattern DB | Case done |
| `pattern.new` | Pattern Extractor | Trend Detector | New pattern |
| `pattern.updated` | Pattern Extractor | Trend Detector | Pattern updated |
| `trend.detected` | Trend Detector | Intel Generator | Trend found |
| `class.complete` | Analysis Worker | Manager | Class done |
| `intelligence.request` | External | Intel Generator | Request report |

### Vulnerability Class Groupings

| Group | Files | Worker Type |
|-------|-------|-------------|
| Injection | 03, 06, 09, 10, 28, 29, 30 | Injection Pattern Worker |
| Auth/Session | 11, 12, 37, 39, 50 | Auth Pattern Worker |
| Authorization | 01, 13 | Authz Pattern Worker |
| Cross-Site | 02, 05, 25, 26, 31 | XSS Pattern Worker |
| Server-Side | 04, 21, 27, 36, 46, 47 | SSRF Pattern Worker |
| Deserialization | 07, 16, 17, 18, 19 | Deser Pattern Worker |
| File/Path | 08, 43, 44, 45 | File Pattern Worker |
| Info/Crypto | 14, 15, 40, 41, 42 | Crypto Pattern Worker |
| Infrastructure | 20, 22, 24, 32-35, 38 | Infra Pattern Worker |
| Platform | 23, 48, 49 | Platform Pattern Worker |

### Pattern Database Schema

| Field | Type | Description |
|-------|------|-------------|
| `pattern_id` | string | Unique identifier |
| `vuln_class` | string | Vulnerability class |
| `pattern_type` | enum | exploitation, detection, prevention |
| `frequency` | int | Occurrence count |
| `severity_range` | [enum] | Severity range |
| `first_seen` | datetime | First occurrence |
| `last_seen` | datetime | Most recent |
| `affected_platforms` | [string] | Platforms affected |
| `exploitation_techniques` | [string] | Exploitation methods |
| `confidence_score` | float | Confidence (0-1) |

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Case Study Analysis Manager
        |
        +-- Pattern Extraction Workers (one per vuln class)
        |     +-- Injection Pattern Worker (03, 06, 09, 10, 28, 29, 30)
        |     +-- Auth Pattern Worker (11, 12, 37, 39, 50)
        |     +-- Authz Pattern Worker (01, 13)
        |     +-- XSS Pattern Worker (02, 05, 25, 26, 31)
        |     +-- SSRF Pattern Worker (04, 21, 27, 36, 46, 47)
        |     +-- Deser Pattern Worker (07, 16, 17, 18, 19)
        |     +-- File Pattern Worker (08, 43, 44, 45)
        |     +-- Crypto Pattern Worker (14, 15, 40, 41, 42)
        |     +-- Infra Pattern Worker (20, 22, 24, 32-35, 38)
        |     +-- Platform Pattern Worker (23, 48, 49)
        |
        +-- Trend Detection Worker
        |     +-- Cross-Class Trend Analyzer
        |     +-- Temporal Trend Analyzer
        |     +-- Emerging Threat Detector
        |
        +-- Intelligence Generator
        |     +-- Pattern Summarizer
        |     +-- Recommendation Engine
        |     +-- Report Writer
        |     +-- Alert Generator
        |
        +-- Pattern Database Manager
              +-- DB Reader
              +-- DB Writer
              +-- DB Optimizer
              +-- DB Indexer
```

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `analysis.cycle_interval` | 86400 | Analysis cycle (seconds) |
| `analysis.max_classes_per_cycle` | 50 | Max classes per cycle |
| `pattern.min_occurrences` | 3 | Min occurrences for pattern |
| `pattern.max_database_size` | 100000 | Max pattern DB entries |
| `trend.detection_window_days` | 90 | Trend detection window |
| `trend.min_change_threshold` | 0.1 | Min trend change threshold |
| `intelligence.auto_generate` | true | Auto-generate reports |
| `intelligence.report_format` | markdown | Report output format |
| `intelligence.alert_threshold` | 0.8 | Alert confidence threshold |
| `intelligence.max_patterns_per_report` | 50 | Max patterns in report |
| `pattern.confidence_decay_rate` | 0.95 | Confidence decay per day |
| `pattern.max_age_days` | 365 | Max pattern age before archival |
