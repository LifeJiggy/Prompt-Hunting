# Core Prompts Hunting — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `core-prompts-hunting` |
| Domain Path | `Core-Prompts-hunting/` |
| File Count | 50 prompt files |
| Registry | `Core-Prompts-hunting/registry.json` |
| Category | Hunting Processes |
| Lifecycle Scope | Scanner workers, exploitation runners, vulnerability analyzers, report drafters |

## Overview

This document defines the complete process lifecycle management for the Core Prompts Hunting domain. The domain encompasses 50 prompt files that define the core vulnerability hunting methodology, from reconnaissance and asset discovery through reporting and proof-of-concept development. The lifecycle manages the execution of hunting processes that systematically discover, validate, and report vulnerabilities.

Hunting processes are the primary workhorses of the bug bounty operation. They combine reconnaissance, analysis, exploitation, and reporting into end-to-end hunting workflows. The lifecycle ensures that hunting processes can be started, monitored, paused, and stopped gracefully while maintaining state consistency across multi-step hunting operations.

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
            |       |    RECONNAISSANCE |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |    ANALYSIS      |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |    SCANNING      |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   EXPLOITATION   |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   REPORTING      |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   VALIDATING     |
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
            | (any state) --error--> +-----------+
            |                        |   FAILED  |
            |                        +-----------+
            |                             |
            | (any state) --signal--> +---+--------+
            |                         |  STOPPING  |
            |                         +------------+
            |                              |
            |                              v
            +------------------------+------+------+
                                     |   STOPPED   |
                                     +-------------+
```

## State Definitions

### CREATED

Process entry allocated. Hunting target and scope defined.

**Internal data:**
- Process ID assigned
- Target scope loaded from hunting specification
- All 50 file references loaded:
  - `1-Reconnaissance-and-Asset-Discovery.md`
  - `2-JavaScript-Analysis-and-Deobfuscation.md`
  - `3-API-Endpoint-Analysis.md`
  - `4-Authentication-and-Session-Management.md`
  - `5-Authorization-and-Access-Control.md`
  - `6-Input-Validation-and-Sanitization.md`
  - `7-Business-Logic-Flaws.md`
  - `8-Client-Side-Storage-Security.md`
  - `9-Cryptography-and-Data-Protection.md`
  - `10-Error-Handling-and-Information-Disclosure.md`
  - `11-File-Upload-and-Processing.md`
  - `12-Server-Side-Request-Forgery-SSRF.md`
  - `13-Cross-Site-Request-Forgery-CSRF.md`
  - `14-Cross-Origin-Resource-Sharing-CORS.md`
  - `15-Race-Conditions-and-Concurrency-Issues.md`
  - `16-Third-Party-Component-Analysis.md`
  - `17-Configuration-and-Misconfiguration-Hunting.md`
  - `18-Network-and-Infrastructure-Security.md`
  - `19-Mobile-and-API-Specific-Vulnerabilities.md`
  - `20-Reporting-and-Proof-of-Concept-Development.md`
  - `21-Web-Application-Firewall-WAF-Bypass.md`
  - `22-HTTP-Request-Smuggling.md`
  - `23-Subdomain-Takeover.md`
  - `24-Host-Header-Injection.md`
  - `25-XML-External-Entity-XXE-Injection.md`
  - `26-Insecure-Deserialization.md`
  - `27-Command-Injection.md`
  - `28-NoSQL-Injection.md`
  - `29-GraphQL-Vulnerabilities.md`
  - `30-WebSocket-Security.md`
  - `31-Server-Side-Template-Injection.md`
  - `32-JSON-Web-Token-JWT-Vulnerabilities.md`
  - `33-Content-Security-Policy-CSP-Bypass.md`
  - `34-Clickjacking-and-UI-Redressing.md`
  - `35-HTTP-Parameter-Pollution.md`
  - `36-LDAP-Injection.md`
  - `37-Session-Puzzling-and-Fixation.md`
  - `38-Insecure-File-Handling.md`
  - `39-Cross-Site-Script-Inclusion-XSSI.md`
  - `40-Prototype-Pollution.md`
  - `41-HTTP-Response-Splitting.md`
  - `42-XPath-Injection.md`
  - `43-Cross-Site-Request-Forgery-CSRF.md`
  - `44-Cross-Origin-Resource-Sharing-CORS.md`
  - `45-Race-Conditions-and-Concurrency-Issues.md`
  - `46-Third-Party-Component-Analysis.md`
  - `47-Configuration-and-Misconfiguration-Hunting.md`
  - `48-Network-and-Infrastructure-Security.md`
  - `49-Mobile-and-API-Specific-Vulnerabilities.md`
  - `50-Reporting-and-Proof-of-Concept-Development.md`
  - `README.md`

**Exit:** CREATED -> INITIALIZING

### INITIALIZING

Loading hunting configuration, initializing scanner components, preparing exploitation toolkit.

**Sub-steps:**
1. Load `Core-Prompts-hunting/registry.json`
2. Initialize reconnaissance engine: `1-Reconnaissance-and-Asset-Discovery.md`
3. Load vulnerability patterns for target type
4. Initialize scanner workers per vuln class
5. Prepare exploitation toolkit
6. Configure reporting templates: `20-Reporting-and-Proof-of-Concept-Development.md`
7. Validate scope boundaries

**Exit:** INITIALIZING -> RECONNAISSANCE | INITIALIZING -> FAILED

### RECONNAISSANCE

Active reconnaissance phase. Gathering target information, mapping attack surface.

**Active workers:**
- Subdomain discovery
- Port scanning
- Technology fingerprinting
- API endpoint enumeration
- JavaScript analysis: `2-JavaScript-Analysis-and-Deobfuscation.md`
- Cloud resource enumeration: `18-Network-and-Infrastructure-Security.md`

**Exit:** RECONNAISSANCE -> ANALYSIS (recon complete) | RECONNAISSANCE -> FAILED

### ANALYSIS

Analyzing discovered assets for potential vulnerabilities. Mapping attack vectors.

**Active workers:**
- Authentication analysis: `4-Authentication-and-Session-Management.md`
- Authorization analysis: `5-Authorization-and-Access-Control.md`
- Business logic analysis: `7-Business-Logic-Flaws.md`
- Configuration analysis: `17-Configuration-and-Misconfiguration-Hunting.md`
- Third-party component analysis: `16-Third-Party-Component-Analysis.md`
- API endpoint analysis: `3-API-Endpoint-Analysis.md`

**Exit:** ANALYSIS -> SCANNING (analysis complete) | ANALYSIS -> FAILED

### SCANNING

Active vulnerability scanning against discovered attack surface.

**Active scanners (per vulnerability class):**
- Input validation: `6-Input-Validation-and-Sanitization.md`
- SSRF: `12-Server-Side-Request-Forgery-SSRF.md`
- CSRF: `13-Cross-Site-Request-Forgery-CSRF.md`
- CORS: `14-Cross-Origin-Resource-Sharing-CORS.md`
- Race conditions: `15-Race-Conditions-and-Concurrency-Issues.md`
- File upload: `11-File-Upload-and-Processing.md`
- Error handling: `10-Error-Handling-and-Information-Disclosure.md`
- WAF bypass: `21-Web-Application-Firewall-WAF-Bypass.md`
- HTTP smuggling: `22-HTTP-Request-Smuggling.md`
- Subdomain takeover: `23-Subdomain-Takeover.md`
- Host header injection: `24-Host-Header-Injection.md`
- XXE: `25-XML-External-Entity-XXE-Injection.md`
- Deserialization: `26-Insecure-Deserialization.md`
- Command injection: `27-Command-Injection.md`
- NoSQL injection: `28-NoSQL-Injection.md`
- GraphQL: `29-GraphQL-Vulnerabilities.md`
- WebSocket: `30-WebSocket-Security.md`
- SSTI: `31-Server-Side-Template-Injection.md`
- JWT: `32-JSON-Web-Token-JWT-Vulnerabilities.md`
- CSP bypass: `33-Content-Security-Policy-CSP-Bypass.md`
- Clickjacking: `34-Clickjacking-and-UI-Redressing.md`
- HPP: `35-HTTP-Parameter-Pollution.md`
- LDAP injection: `36-LDAP-Injection.md`
- Session puzzling: `37-Session-Puzzling-and-Fixation.md`
- Insecure file handling: `38-Insecure-File-Handling.md`
- XSSI: `39-Cross-Site-Script-Inclusion-XSSI.md`
- Prototype pollution: `40-Prototype-Pollution.md`
- Response splitting: `41-HTTP-Response-Splitting.md`
- XPath injection: `42-XPath-Injection.md`
- Mobile/API specific: `19-Mobile-and-API-Specific-Vulnerabilities.md`

**Exit:** SCANNING -> EXPLOITATION (vulns found) | SCANNING -> REPORTING (no vulns) | SCANNING -> FAILED

### EXPLOITATION

Actively exploiting discovered vulnerabilities to validate impact.

**Active workers:**
- Vulnerability validation
- Impact demonstration
- Proof-of-concept development: `20-Reporting-and-Proof-of-Concept-Development.md`
- Client-side storage analysis: `8-Client-Side-Storage-Security.md`
- Cryptography analysis: `9-Cryptography-and-Data-Protection.md`

**Exit:** EXPLOITATION -> REPORTING (exploitation complete) | EXPLOITATION -> FAILED

### REPORTING

Generating vulnerability reports and proof-of-concept demonstrations.

**Active workers:**
- Report drafting
- PoC development
- Impact quantification
- Remediation recommendations

**Exit:** REPORTING -> VALIDATING (report draft complete) | REPORTING -> FAILED

### VALIDATING

Quality assurance on generated reports. Verifying accuracy, completeness, and submission readiness.

**Validation checks:**
- Technical accuracy verification
- Impact statement validation
- PoC reproducibility check
- Scope compliance verification
- Ethical guideline compliance: `Ethical-Guidelines.md` (from bug-bounty-support)

**Exit:** VALIDATING -> COMPLETED (passed) | VALIDATING -> REPORTING (needs revision) | VALIDATING -> FAILED

### COMPLETED

Hunting process finished. Reports ready for submission.

**Exit:** COMPLETED -> STOPPED (cleanup)

### STOPPING

Graceful shutdown. Hunting state preserved for potential resume.

**Exit:** STOPPING -> STOPPED

### STOPPED

Terminal state. All hunting workers terminated.

## Start Operations

### Hunting Start Sequence

```
1. Receive hunt command with target specification
2. Transition: CREATED -> INITIALIZING
3. Load target scope and boundaries
4. Initialize hunting components
5. Transition: INITIALIZING -> RECONNAISSANCE
6. Execute reconnaissance phase
7. Transition: RECONNAISSANCE -> ANALYSIS
8. Analyze discovered assets
9. Transition: ANALYSIS -> SCANNING
10. Scan for vulnerabilities
11. Transition: SCANNING -> EXPLOITATION
12. Exploit discovered vulnerabilities
13. Transition: EXPLOITATION -> REPORTING
14. Generate reports
15. Transition: REPORTING -> VALIDATING
16. Validate reports
17. Transition: VALIDATING -> COMPLETED
18. Reports ready for submission
```

## Stop Operations

### Graceful Stop

```
1. Receive stop signal
2. Transition: CURRENT_STATE -> STOPPING
3. Save current hunting state
4. Complete in-progress operations where possible
5. Release scanner resources
6. Persist partial results
7. Transition: STOPPING -> STOPPED
```

## Graceful Shutdown Protocol

### Phase 1: State Snapshot (0-10s)
- Save current phase and progress
- Capture partial scan results
- Record discovered assets

### Phase 2: Worker Drain (10-60s)
- Allow in-progress scans to complete
- Stop accepting new scan tasks
- Flush result buffers

### Phase 3: Resource Release (60-90s)
- Release scanner connections
- Close browser instances
- Free exploitation toolkit
- Write final state file

## Signal Handling

| Signal | Handler | Action |
|--------|---------|--------|
| `SIGTERM` | `handle_graceful_shutdown()` | Save state, drain, shutdown |
| `SIGINT` | `handle_graceful_shutdown()` | Same as SIGTERM |
| `SIGHUP` | `handle_target_reload()` | Reload target scope |
| `SIGUSR1` | `handle_state_dump()` | Dump current hunting state |
| `SIGUSR2` | `handle_phase_skip()` | Skip to next phase (debug) |
| `SIGKILL` | (OS default) | Immediate termination |

## Health Monitoring

| Metric | Description | Alert |
|--------|-------------|-------|
| `current_phase` | Active hunting phase | N/A (info) |
| `assets_discovered` | Total assets found | N/A (info) |
| `vulns_found` | Vulnerabilities discovered | N/A (info) |
| `vulns_validated` | Validated vulnerabilities | N/A (info) |
| `reports_generated` | Reports created | N/A (info) |
| `scanner_active_count` | Active scanners | < expected |
| `exploitation_success_rate` | Exploitation success % | N/A (info) |
| `phase_duration_seconds` | Time in current phase | > 3600 |
| `memory_usage_mb` | Process memory | > 2048 |
| `error_rate` | Error rate per phase | > 10% |

## Resource Limits

| Resource | Limit | Action |
|----------|-------|--------|
| Total memory | 2048 MB | Kill least-critical scanners |
| Scanner workers | 20 concurrent | Queue excess |
| Browser instances | 5 concurrent | Kill idle browsers |
| Network connections | 200 total | Rate limit |
| Disk for results | 2 GB | Rotate old results |
| Phase timeout | 7200s | Force phase transition |

## Cleanup Procedures

### Normal Cleanup

```
1. Archive hunting results
2. Save final state report
3. Release all scanner connections
4. Close browser instances
5. Remove temp scan files
6. Update hunting registry
```

### Emergency Cleanup

```
1. Force-stop all scanners
2. Save partial results
3. Release all resources
4. Log failure context
```

## Domain File References

### Reconnaissance Phase

| File | Purpose | Worker Role |
|------|---------|-------------|
| `1-Reconnaissance-and-Asset-Discovery.md` | Reconnaissance methodology | Recon Worker |
| `2-JavaScript-Analysis-and-Deobfuscation.md` | JS analysis | Analysis Worker |
| `3-API-Endpoint-Analysis.md` | API discovery | Enum Worker |
| `18-Network-and-Infrastructure-Security.md` | Network recon | Recon Worker |
| `48-Network-and-Infrastructure-Security.md` | Network security | Recon Worker |

### Analysis Phase

| File | Purpose | Worker Role |
|------|---------|-------------|
| `4-Authentication-and-Session-Management.md` | Auth analysis | Analysis Worker |
| `5-Authorization-and-Access-Control.md` | Authz analysis | Analysis Worker |
| `6-Input-Validation-and-Sanitization.md` | Input validation | Analysis Worker |
| `7-Business-Logic-Flaws.md` | Business logic | Analysis Worker |
| `8-Client-Side-Storage-Security.md` | Client storage | Analysis Worker |
| `9-Cryptography-and-Data-Protection.md` | Crypto analysis | Analysis Worker |
| `10-Error-Handling-and-Information-Disclosure.md` | Error handling | Analysis Worker |
| `16-Third-Party-Component-Analysis.md` | 3rd party analysis | Analysis Worker |
| `17-Configuration-and-Misconfiguration-Hunting.md` | Config analysis | Analysis Worker |
| `47-Configuration-and-Misconfiguration-Hunting.md` | Config hunting | Analysis Worker |

### Scanning Phase

| File | Purpose | Worker Role |
|------|---------|-------------|
| `11-File-Upload-and-Processing.md` | File upload scanning | Scanner Worker |
| `12-Server-Side-Request-Forgery-SSRF.md` | SSRF scanning | Scanner Worker |
| `13-Cross-Site-Request-Forgery-CSRF.md` | CSRF scanning | Scanner Worker |
| `14-Cross-Origin-Resource-Sharing-CORS.md` | CORS scanning | Scanner Worker |
| `15-Race-Conditions-and-Concurrency-Issues.md` | Race condition scanning | Scanner Worker |
| `19-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile/API scanning | Scanner Worker |
| `21-Web-Application-Firewall-WAF-Bypass.md` | WAF bypass | Scanner Worker |
| `22-HTTP-Request-Smuggling.md` | HTTP smuggling | Scanner Worker |
| `23-Subdomain-Takeover.md` | Subdomain takeover | Scanner Worker |
| `24-Host-Header-Injection.md` | Host header injection | Scanner Worker |
| `25-XML-External-Entity-XXE-Injection.md` | XXE scanning | Scanner Worker |
| `26-Insecure-Deserialization.md` | Deserialization scanning | Scanner Worker |
| `27-Command-Injection.md` | Command injection | Scanner Worker |
| `28-NoSQL-Injection.md` | NoSQL injection | Scanner Worker |
| `29-GraphQL-Vulnerabilities.md` | GraphQL scanning | Scanner Worker |
| `30-WebSocket-Security.md` | WebSocket scanning | Scanner Worker |
| `31-Server-Side-Template-Injection.md` | SSTI scanning | Scanner Worker |
| `32-JSON-Web-Token-JWT-Vulnerabilities.md` | JWT scanning | Scanner Worker |
| `33-Content-Security-Policy-CSP-Bypass.md` | CSP bypass | Scanner Worker |
| `34-Clickjacking-and-UI-Redressing.md` | Clickjacking | Scanner Worker |
| `35-HTTP-Parameter-Pollution.md` | HPP scanning | Scanner Worker |
| `36-LDAP-Injection.md` | LDAP injection | Scanner Worker |
| `37-Session-Puzzling-and-Fixation.md` | Session issues | Scanner Worker |
| `38-Insecure-File-Handling.md` | File handling | Scanner Worker |
| `39-Cross-Site-Script-Inclusion-XSSI.md` | XSSI scanning | Scanner Worker |
| `40-Prototype-Pollution.md` | Prototype pollution | Scanner Worker |
| `41-HTTP-Response-Splitting.md` | Response splitting | Scanner Worker |
| `42-XPath-Injection.md` | XPath injection | Scanner Worker |
| `43-Cross-Site-Request-Forgery-CSRF.md` | CSRF scanning | Scanner Worker |
| `44-Cross-Origin-Resource-Sharing-CORS.md` | CORS scanning | Scanner Worker |
| `45-Race-Conditions-and-Concurrency-Issues.md` | Race conditions | Scanner Worker |
| `46-Third-Party-Component-Analysis.md` | 3rd party scanning | Scanner Worker |
| `49-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile/API scanning | Scanner Worker |

### Reporting Phase

| File | Purpose | Worker Role |
|------|---------|-------------|
| `20-Reporting-and-Proof-of-Concept-Development.md` | Report generation | Report Worker |
| `50-Reporting-and-Proof-of-Concept-Development.md` | Report generation | Report Worker |

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Hunting Runner
        |
        +-- Recon Workers
        |     +-- Subdomain Discovery
        |     +-- Port Scanner
        |     +-- Tech Fingerprinter
        |     +-- API Discoverer
        |
        +-- Analysis Workers
        |     +-- Auth Analyzer
        |     +-- Authz Analyzer
        |     +-- Logic Analyzer
        |     +-- Config Analyzer
        |
        +-- Scanner Workers (one per vuln class)
        |     +-- SSRF Scanner
        |     +-- XSS Scanner
        |     +-- SQLi Scanner
        |     +-- CSRF Scanner
        |     +-- ... (20+ scanners)
        |
        +-- Exploitation Workers
        |     +-- Vuln Validator
        |     +-- Impact Demonstrator
        |     +-- PoC Developer
        |
        +-- Report Workers
              +-- Report Drafter
              +-- PoC Developer
              +-- QA Checker
```

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `hunt.phase_timeout` | 7200 | Phase timeout (seconds) |
| `hunt.max_scanners` | 20 | Max concurrent scanners |
| `hunt.max_browsers` | 5 | Max browser instances |
| `hunt.memory_limit_mb` | 2048 | Memory limit |
| `hunt.disk_limit_gb` | 2 | Result disk limit |
| `hunt.report_autogenerate` | true | Auto-generate reports |
| `hunt.validation_enabled` | true | Enable report validation |
| `hunt.concurrency` | 10 | Task concurrency |
