# High-Level World Case Studies — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `high-level-world-case-studies` |
| Domain Path | `High-Level-World-Case-Studies/` |
| File Count | 46 prompt files |
| Registry | `High-Level-World-Case-Studies/registry.json` |
| Category | Case Analysis |
| Lifecycle Scope | Analysis workers, pattern extractors, timeline builders, impact assessors |

## Overview

This document defines the complete process lifecycle management for the High-Level World Case Studies domain. The domain encompasses 46 prompt files that analyze significant real-world security incidents, from critical infrastructure breaches to post-mortem analyses. The lifecycle manages case analysis processes that extract patterns, build timelines, assess impacts, and generate intelligence from disclosed incidents.

Case analysis processes are typically analytical, running periodically to update pattern databases, refresh trend analysis, and generate actionable intelligence for hunting operations. They consume case study data and produce structured intelligence outputs.

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

Process entry allocated. Case analysis scope determined.

**Internal data:**
- Process ID assigned
- Analysis type: incident_analysis, pattern_extraction, trend_analysis, impact_assessment
- All 46 file references loaded:
  - `05-Critical-Infrastructure-Breach.md`
  - `06-Zero-Day-Exploitation-Case.md`
  - `07-Chain-of-Vulnerabilities.md`
  - `08-Real-World-Impact-Assessment.md`
  - `09-Timeline-from-Discovery-to-Fix.md`
  - `10-Reward-Maximization-Strategies.md`
  - `11-Report-Quality-Analysis.md`
  - `12-Triage-Process-Understanding.md`
  - `13-Program-Response-Analysis.md`
  - `14-Disclosure-Timeline-Study.md`
  - `15-Collaborative-Hunting-Case.md`
  - `16-Cross-Program-Vulnerability-Patterns.md`
  - `17-Industry-Specific-Findings.md`
  - `18-Mobile-App-Vulnerability-Case.md`
  - `19-Web-Application-Security-Case.md`
  - `20-API-Security-Breach-Analysis.md`
  - `21-Cloud-Configuration-Error.md`
  - `22-Container-Escape-Case-Study.md`
  - `23-IoT-Device-Compromise.md`
  - `24-Blockchain-Smart-Contract-Bug.md`
  - `25-Cryptocurrency-Exchange-Hack.md`
  - `26-Social-Engineering-Success.md`
  - `27-Physical-Security-Bypass.md`
  - `28-Network-Infrastructure-Attack.md`
  - `29-Database-Compromise-Case.md`
  - `30-File-System-Attack-Analysis.md`
  - `31-Authentication-Bypass-Case.md`
  - `32-Authorization-Flaw-Study.md`
  - `33-Session-Management-Issue.md`
  - `34-Input-Validation-Failure.md`
  - `35-Business-Logic-Flaw-Analysis.md`
  - `36-Information-Disclosure-Case.md`
  - `37-Weak-Cryptography-Example.md`
  - `38-Insecure-Communication-Study.md`
  - `39-Third-Party-Component-Vulnerability.md`
  - `40-Supply-Chain-Attack-Case.md`
  - `41-Zero-Trust-Bypass-Analysis.md`
  - `42-Multi-Factor-Authentication-Bypass.md`
  - `43-Privilege-Escalation-Case.md`
  - `44-Lateral-Movement-Study.md`
  - `45-Data-Exfiltration-Method.md`
  - `46-Persistence-Mechanism-Analysis.md`
  - `47-Anti-Forensic-Technique-Study.md`
  - `48-Incident-Response-Failure.md`
  - `49-Compliance-Violation-Case.md`
  - `50-Post-Mortem-Analysis.md`
  - `README.md`

**Exit:** CREATED -> INITIALIZING

### INITIALIZING

Loading case study data, building analysis framework, initializing pattern extraction.

**Sub-steps:**
1. Load `High-Level-World-Case-Studies/registry.json`
2. Load case study index
3. Initialize pattern extraction engine
4. Initialize timeline builder
5. Initialize impact assessor
6. Load historical pattern database
7. Configure analysis parameters

**Exit:** INITIALIZING -> RUNNING | INITIALIZING -> FAILED

### RUNNING

Case analysis actively processing. Multiple analysis workers operating in parallel.

**Analysis activities:**
- Incident pattern extraction
- Timeline construction and analysis
- Impact assessment and quantification
- Vulnerability pattern identification
- Attack technique mapping
- Defense gap analysis
- Trend identification
- Intelligence generation

**Analysis categories:**

*Infrastructure Attacks:*
- `05-Critical-Infrastructure-Breach.md`
- `28-Network-Infrastructure-Attack.md`
- `29-Database-Compromise-Case.md`
- `30-File-System-Attack-Analysis.md`

*Zero-Day and Advanced:*
- `06-Zero-Day-Exploitation-Case.md`
- `07-Chain-of-Vulnerabilities.md`
- `41-Zero-Trust-Bypass-Analysis.md`
- `47-Anti-Forensic-Technique-Study.md`

*Application Security:*
- `18-Mobile-App-Vulnerability-Case.md`
- `19-Web-Application-Security-Case.md`
- `20-API-Security-Breach-Analysis.md`
- `21-Cloud-Configuration-Error.md`
- `22-Container-Escape-Case-Study.md`
- `31-Authentication-Bypass-Case.md`
- `32-Authorization-Flaw-Study.md`
- `33-Session-Management-Issue.md`
- `34-Input-Validation-Failure.md`
- `35-Business-Logic-Flaw-Analysis.md`
- `36-Information-Disclosure-Case.md`
- `37-Weak-Cryptography-Example.md`
- `38-Insecure-Communication-Study.md`
- `39-Third-Party-Component-Vulnerability.md`

*Emerging Technology:*
- `23-IoT-Device-Compromise.md`
- `24-Blockchain-Smart-Contract-Bug.md`
- `25-Cryptocurrency-Exchange-Hack.md`

*Social and Physical:*
- `26-Social-Engineering-Success.md`
- `27-Physical-Security-Bypass.md`

*Post-Compromise:*
- `42-Multi-Factor-Authentication-Bypass.md`
- `43-Privilege-Escalation-Case.md`
- `44-Lateral-Movement-Study.md`
- `45-Data-Exfiltration-Method.md`
- `46-Persistence-Mechanism-Analysis.md`
- `40-Supply-Chain-Attack-Case.md`

*Process and Response:*
- `08-Real-World-Impact-Assessment.md`
- `09-Timeline-from-Discovery-to-Fix.md`
- `10-Reward-Maximization-Strategies.md`
- `11-Report-Quality-Analysis.md`
- `12-Triage-Process-Understanding.md`
- `13-Program-Response-Analysis.md`
- `14-Disclosure-Timeline-Study.md`
- `15-Collaborative-Hunting-Case.md`
- `16-Cross-Program-Vulnerability-Patterns.md`
- `17-Industry-Specific-Findings.md`
- `48-Incident-Response-Failure.md`
- `49-Compliance-Violation-Case.md`
- `50-Post-Mortem-Analysis.md`

**Exit:** RUNNING -> PAUSED | RUNNING -> COMPLETED | RUNNING -> STOPPING | RUNNING -> FAILED

### PAUSED

Analysis suspended. Extracted patterns retained.

**Exit:** PAUSED -> RUNNING | PAUSED -> STOPPING

### COMPLETED

All case studies analyzed. Final intelligence report generated.

**Exit:** COMPLETED -> STOPPED

### STOPPING

Graceful shutdown. Analysis state persisted.

**Exit:** STOPPING -> STOPPED

### STOPPED

Terminal state. All analysis workers terminated.

## Start Operations

```
1. Receive start command
2. Transition: CREATED -> INITIALIZING
3. Load case study data
4. Initialize analysis engines
5. Transition: INITIALIZING -> RUNNING
6. Begin parallel case analysis
7. Aggregate results
8. Transition: RUNNING -> COMPLETED
```

## Stop Operations

```
1. Receive stop signal
2. Transition: RUNNING -> STOPPING
3. Complete current analysis
4. Persist extracted patterns
5. Write final intelligence report
6. Release analysis resources
7. Transition: STOPPING -> STOPPED
```

## Graceful Shutdown Protocol

### Phase 1: Analysis Completion (0-30s)
- Finish current case analysis
- Complete pattern extraction for in-progress cases

### Phase 2: State Persistence (30-60s)
- Save extracted patterns to database
- Persist timeline data
- Write intelligence summary

### Phase 3: Resource Release (60-90s)
- Release analysis engine resources
- Close database connections
- Write shutdown log

## Signal Handling

| Signal | Handler | Action |
|--------|---------|--------|
| `SIGTERM` | `handle_graceful_shutdown()` | Complete analysis, persist, shutdown |
| `SIGINT` | `handle_graceful_shutdown()` | Same as SIGTERM |
| `SIGHUP` | `handle_data_refresh()` | Refresh case study data |
| `SIGUSR1` | `handle_report_generate()` | Generate immediate intelligence report |
| `SIGUSR2` | `handle_analysis_reset()` | Reset analysis state |
| `SIGKILL` | (OS default) | Immediate termination |

## Health Monitoring

| Metric | Description | Alert |
|--------|-------------|-------|
| `cases_analyzed` | Cases processed | N/A (info) |
| `patterns_extracted` | Patterns found | N/A (info) |
| `analysis_cycle_time` | Time per cycle | > 600 |
| `pattern_database_size` | DB size | > 1M entries |
| `memory_usage_mb` | Process memory | > 512 MB |
| `intelligence_freshness_hours` | Age of newest intel | > 168 |

## Resource Limits

| Resource | Limit | Action |
|----------|-------|--------|
| Memory | 512 MB | Evict old patterns |
| CPU | 1 core | Throttle analysis |
| Pattern database | 100000 entries | LRU eviction |
| Timeline cache | 1000 timelines | Evict old timelines |
| Report files | 50 MB | Rotate old reports |

## Domain File References

Each of the 46 case study files is a discrete analysis unit. The analysis worker loads each file, extracts structured data, and feeds it to the pattern extraction engine. See the State Definitions section for the complete organized listing of all 46 files.

## Inter-Process Communication

### Message Types

| Message | Producer | Consumer | Description |
|---------|----------|----------|-------------|
| `case.loaded` | Manager | Pattern Extractor | Case ready |
| `pattern.extracted` | Pattern Extractor | Intel Generator | Pattern found |
| `timeline.built` | Timeline Builder | Impact Assessor | Timeline ready |
| `impact.assessed` | Impact Assessor | Intel Generator | Impact done |
| `intelligence.ready` | Intel Generator | All consumers | Report ready |
| `trend.detected` | Pattern Extractor | Intel Generator | Trend found |

### Pattern Categories

| Category | Cases | Description |
|----------|-------|-------------|
| Infrastructure Attack | 05, 28, 29, 30 | Network/system patterns |
| Zero-Day Exploitation | 06, 07, 41, 47 | Advanced exploitation |
| Application Vulnerability | 18-20, 31-38 | Web app vuln patterns |
| Emerging Technology | 23-25 | IoT, blockchain, crypto |
| Social Engineering | 26, 27 | Human-based attacks |
| Post-Compromise | 40, 42-46 | Post-exploitation |
| Process and Response | 08-17, 48-50 | Incident response |

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Case Analysis Manager
        |
        +-- Pattern Extractor
        |     +-- Vulnerability Pattern Worker
        |     +-- Attack Technique Worker
        |     +-- Defense Gap Worker
        |     +-- Supply Chain Pattern Worker
        |
        +-- Timeline Builder
        |     +-- Incident Timeline Worker
        |     +-- Disclosure Timeline Worker
        |     +-- Attack Chain Timeline Worker
        |
        +-- Impact Assessor
        |     +-- Financial Impact Worker
        |     +-- Operational Impact Worker
        |     +-- Reputational Impact Worker
        |     +-- Regulatory Impact Worker
        |
        +-- Intelligence Generator
        |     +-- Trend Analyzer
        |     +-- Report Writer
        |     +-- Recommendation Engine
        |     +-- Alert Generator
        |
        +-- Case Database Manager
              +-- DB Reader
              +-- DB Writer
              +-- DB Indexer
```

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `analysis.cycle_interval` | 86400 | Analysis cycle (seconds) |
| `analysis.max_cases_per_cycle` | 46 | Max cases per cycle |
| `pattern.extraction_threshold` | 3 | Min occurrences for pattern |
| `timeline.max_depth` | 10 | Max timeline events |
| `intelligence.freshness_hours` | 168 | Intel freshness threshold |
| `report.auto_generate` | true | Auto-generate reports |
| `memory.pattern_cache_mb` | 256 | Pattern cache size |
| `intelligence.alert_on_critical` | true | Alert on critical patterns |
| `intelligence.trend_window_days` | 90 | Trend detection window |
| `intelligence.min_pattern_confidence` | 0.7 | Min confidence for pattern |
| `case.max_analysis_time` | 300 | Max time per case (seconds) |
| `case.batch_size` | 10 | Cases per batch |
