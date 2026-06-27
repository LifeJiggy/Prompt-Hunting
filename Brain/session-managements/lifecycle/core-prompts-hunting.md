# Session Lifecycle: Core Prompts Hunting Domain

> Session lifecycle management for vulnerability hunting workflows, prompt-guided scanning, and hunting progress tracking across all 50 Core-Prompts-hunting modules.

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | `core-prompts-hunting` |
| Source Directory | `Core-Prompts-hunting/` |
| Module Count | 50 |
| Session Type | `hunting-session` |
| State Complexity | High — tracks hunting progress, vulnerability discoveries, and methodology adherence |
| Parent System | Session Lifecycle Manager |

## Overview

This document defines the complete session lifecycle for the Core Prompts Hunting domain. Hunting sessions manage the process of actively searching for vulnerabilities using prompt-guided methodologies. Each session tracks which hunting modules are loaded, the current hunting phase, targets being tested, vulnerabilities discovered, and methodology adherence.

Hunting sessions are the primary operational sessions for bug bounty researchers. They represent active vulnerability hunting work, from reconnaissance through exploitation and reporting. The lifecycle tracks the complete journey from initial target engagement through finding discovery and validation.

## Session State Machine

```
┌─────────┐     activate      ┌──────────┐
│ created │ ─────────────────→│  active   │
└─────────┘                   └────┬─────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │recon     │              │testing   │              │exploiting│
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │enumerating│             │analyzing │              │validating│
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       └──────────────────────────┼──────────────────────────┘
                                  ▼
                           ┌──────────┐
                           │reporting │
                           └────┬─────┘
                                │
                                ▼
                           ┌──────────┐
                           │completed │
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
| `created` | Session initialized; target and scope defined |
| `active` | Session running; hunting workflow active |
| `recon` | Reconnaissance and asset discovery phase |
| `enumerating` | Enumerating endpoints, parameters, and attack surface |
| `testing` | Active vulnerability testing in progress |
| `analyzing` | Analyzing test results for potential findings |
| `exploiting` | Exploitation of confirmed vulnerabilities |
| `validating` | Validating findings with proof-of-concept |
| `reporting` | Preparing vulnerability reports |
| `completed` | Hunting session objectives met |
| `closed` | Session terminated and results archived |

## Session Creation

### `create_hunting_session()`

Creates a new session for a vulnerability hunting workflow.

**Parameters:**
- `name` (str): Human-readable session identifier
- `target` (str): Primary hunting target
- `scope` (dict): Scope boundaries for the hunt
- `modules` (list[str]): Hunting modules to load
- `hunting_focus` (list[str]): Vulnerability classes to focus on
- `methodology` (str): Hunting methodology to follow
- `max_duration` (int): Maximum session lifetime in seconds (default: `14400` — 4 hours)
- `auto_checkpoint` (bool): Enable automatic state checkpointing (default: `True`)

**Returns:** `Session` object with unique ID, target, and hunting configuration.

**Validation:**
- Session name must be unique
- Target must be within authorized scope
- Module references must exist in the directory
- Hunting focus must be from recognized vulnerability classes

**Initialization Steps:**
1. Generate session ID: `hunt_ses_<40-char-hex>`
2. Validate target and scope
3. Create session directory: `sessions/<session_id>/`
4. Initialize hunting progress tracker
5. Register session in the active hunting session registry
6. Emit `session.created` event

## Session Close

### `close_hunting_session(session_id)`

Gracefully terminates a hunting session.

**Pre-close Checks:**
1. Verify all findings are saved
2. Check for unreported vulnerabilities
3. Ensure methodology compliance is recorded

**Close Process:**
1. Transition state to `closing`
2. Generate hunting summary with findings count
3. Archive all test results and findings
4. Save methodology compliance report
5. Release target connections
6. Remove session from active registry
7. Transition state to `closed`
8. Emit `session.closed` event with findings summary

## Session Suspend

### `suspend_hunting_session(session_id)`

Pauses an active hunting session.

**Suspend Process:**
1. Complete current testing step
2. Serialize hunting state including:
   - Current hunting phase
   - Endpoints discovered
   - Tests performed
   - Findings so far
   - Pending test queue
3. Release active connections
4. Transition state to `suspended`

## Session Resume

### `resume_hunting_session(session_id)`

Restores a suspended hunting session.

**Resume Process:**
1. Load serialized hunting state
2. Verify state integrity
3. Reestablish target connections
4. Restore test queue
5. Transition state to `active`
6. Resume from last hunting phase
7. Emit `session.resumed` event

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
| `target` | str | Primary hunting target |

### Hunting-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `scope` | dict | Scope boundaries |
| `modules_loaded` | list[str] | Hunting modules loaded |
| `hunting_focus` | list[str] | Vulnerability classes targeted |
| `current_phase` | str | Current hunting phase |
| `endpoints_discovered` | int | Endpoints found |
| `tests_performed` | int | Tests executed |
| `findings_count` | int | Vulnerabilities discovered |
| `findings_by_severity` | dict | Findings grouped by severity |
| `methodology` | str | Hunting methodology used |
| `methodology_compliance` | dict | Compliance with methodology |
| `test_coverage` | dict | Coverage of attack surface |
| `pending_tests` | list[dict] | Tests queued for execution |

## Session Lookup

### `find_hunting_sessions()`

Search for hunting sessions by criteria.

**Search Parameters:**
- `state` (str): Filter by session state
- `target` (str): Filter by target
- `hunting_focus` (str): Filter by vulnerability class
- `has_findings` (bool): Filter by findings presence

**Examples:**
```python
# Find all active hunting sessions
sessions = find_hunting_sessions(state="active")

# Find sessions hunting for XSS
sessions = find_hunting_sessions(hunting_focus="xss")
```

## Session Limits

### Hunting-Specific Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_hunting_sessions` | 5 | Concurrent hunting sessions |
| `max_modules_per_session` | 10 | Hunting modules per session |
| `max_session_duration` | 14400s (4h) | Maximum hunting runtime |
| `max_endpoints_per_session` | 5000 | Endpoints tracked per session |
| `max_tests_per_session` | 10000 | Tests executed per session |
| `max_findings_per_session` | 100 | Findings per session |
| `max_state_size` | 50MB | Serialized state size limit |

## Session Isolation

### File System Isolation

```
sessions/<session_id>/
├── state/
│   ├── hunting-state.json      # Hunting phase tracker
│   ├── endpoints/              # Discovered endpoints
│   ├── test-results/           # Test execution results
│   ├── findings/               # Confirmed vulnerabilities
│   └── checkpoints/            # Serialized checkpoints
├── output/
│   ├── findings.json           # Aggregated findings
│   ├── reports/                # Generated reports
│   ├── poc/                    # Proof-of-concept artifacts
│   └── evidence/               # Evidence collected
├── config/
│   ├── hunting-config.json     # Session configuration
│   ├── scope.json              # Scope boundaries
│   └── methodology.json        # Methodology steps
└── metadata.json               # Session metadata
```

## Module References for Core Prompts Hunting

| Module | File Reference |
|--------|---------------|
| Reconnaissance and Asset Discovery | `Core-Prompts-hunting/1-Reconnaissance-and-Asset-Discovery.md` |
| JavaScript Analysis and Deobfuscation | `Core-Prompts-hunting/2-JavaScript-Analysis-and-Deobfuscation.md` |
| API Endpoint Analysis | `Core-Prompts-hunting/3-API-Endpoint-Analysis.md` |
| Authentication and Session Management | `Core-Prompts-hunting/4-Authentication-and-Session-Management.md` |
| Authorization and Access Control | `Core-Prompts-hunting/5-Authorization-and-Access-Control.md` |
| Input Validation and Sanitization | `Core-Prompts-hunting/6-Input-Validation-and-Sanitization.md` |
| Business Logic Flaws | `Core-Prompts-hunting/7-Business-Logic-Flaws.md` |
| Client-Side Storage Security | `Core-Prompts-hunting/8-Client-Side-Storage-Security.md` |
| Cryptography and Data Protection | `Core-Prompts-hunting/9-Cryptography-and-Data-Protection.md` |
| Error Handling and Information Disclosure | `Core-Prompts-hunting/10-Error-Handling-and-Information-Disclosure.md` |
| File Upload and Processing | `Core-Prompts-hunting/11-File-Upload-and-Processing.md` |
| Server-Side Request Forgery (SSRF) | `Core-Prompts-hunting/12-Server-Side-Request-Forgery-SSRF.md` |
| Cross-Site Request Forgery (CSRF) | `Core-Prompts-hunting/13-Cross-Site-Request-Forgery-CSRF.md` |
| Cross-Origin Resource Sharing (CORS) | `Core-Prompts-hunting/14-Cross-Origin-Resource-Sharing-CORS.md` |
| Race Conditions and Concurrency Issues | `Core-Prompts-hunting/15-Race-Conditions-and-Concurrency-Issues.md` |
| Third-Party Component Analysis | `Core-Prompts-hunting/16-Third-Party-Component-Analysis.md` |
| Configuration and Misconfiguration Hunting | `Core-Prompts-hunting/17-Configuration-and-Misconfiguration-Hunting.md` |
| Network and Infrastructure Security | `Core-Prompts-hunting/18-Network-and-Infrastructure-Security.md` |
| Mobile and API-Specific Vulnerabilities | `Core-Prompts-hunting/19-Mobile-and-API-Specific-Vulnerabilities.md` |
| Reporting and Proof-of-Concept Development | `Core-Prompts-hunting/20-Reporting-and-Proof-of-Concept-Development.md` |
| Web Application Firewall (WAF) Bypass | `Core-Prompts-hunting/21-Web-Application-Firewall-WAF-Bypass.md` |
| HTTP Request Smuggling | `Core-Prompts-hunting/22-HTTP-Request-Smuggling.md` |
| Subdomain Takeover | `Core-Prompts-hunting/23-Subdomain-Takeover.md` |
| Host Header Injection | `Core-Prompts-hunting/24-Host-Header-Injection.md` |
| XML External Entity (XXE) Injection | `Core-Prompts-hunting/25-XML-External-Entity-XXE-Injection.md` |
| Insecure Deserialization | `Core-Prompts-hunting/26-Insecure-Deserialization.md` |
| Command Injection | `Core-Prompts-hunting/27-Command-Injection.md` |
| NoSQL Injection | `Core-Prompts-hunting/28-NoSQL-Injection.md` |
| GraphQL Vulnerabilities | `Core-Prompts-hunting/29-GraphQL-Vulnerabilities.md` |
| WebSocket Security | `Core-Prompts-hunting/30-WebSocket-Security.md` |
| Server-Side Template Injection | `Core-Prompts-hunting/31-Server-Side-Template-Injection.md` |
| JSON Web Token (JWT) Vulnerabilities | `Core-Prompts-hunting/32-JSON-Web-Token-JWT-Vulnerabilities.md` |
| Content Security Policy (CSP) Bypass | `Core-Prompts-hunting/33-Content-Security-Policy-CSP-Bypass.md` |
| Clickjacking and UI Redressing | `Core-Prompts-hunting/34-Clickjacking-and-UI-Redressing.md` |
| HTTP Parameter Pollution | `Core-Prompts-hunting/35-HTTP-Parameter-Pollution.md` |
| LDAP Injection | `Core-Prompts-hunting/36-LDAP-Injection.md` |
| Session Puzzling and Fixation | `Core-Prompts-hunting/37-Session-Puzzling-and-Fixation.md` |
| Insecure File Handling | `Core-Prompts-hunting/38-Insecure-File-Handling.md` |
| Cross-Site Script Inclusion (XSSI) | `Core-Prompts-hunting/39-Cross-Site-Script-Inclusion-XSSI.md` |
| Prototype Pollution | `Core-Prompts-hunting/40-Prototype-Pollution.md` |
| HTTP Response Splitting | `Core-Prompts-hunting/41-HTTP-Response-Splitting.md` |
| XPath Injection | `Core-Prompts-hunting/42-XPath-Injection.md` |
| Cross-Site Request Forgery (CSRF) Advanced | `Core-Prompts-hunting/43-Cross-Site-Request-Forgery-CSRF.md` |
| Cross-Origin Resource Sharing (CORS) Advanced | `Core-Prompts-hunting/44-Cross-Origin-Resource-Sharing-CORS.md` |
| Race Conditions and Concurrency Issues Advanced | `Core-Prompts-hunting/45-Race-Conditions-and-Concurrency-Issues.md` |
| Third-Party Component Analysis Advanced | `Core-Prompts-hunting/46-Third-Party-Component-Analysis.md` |
| Configuration and Misconfiguration Hunting Advanced | `Core-Prompts-hunting/47-Configuration-and-Misconfiguration-Hunting.md` |
| Network and Infrastructure Security Advanced | `Core-Prompts-hunting/48-Network-and-Infrastructure-Security.md` |
| Mobile and API-Specific Vulnerabilities Advanced | `Core-Prompts-hunting/49-Mobile-and-API-Specific-Vulnerabilities.md` |
| Reporting and Proof-of-Concept Development Advanced | `Core-Prompts-hunting/50-Reporting-and-Proof-of-Concept-Development.md` |

## Events

### Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `hunting.session.created` | session_id, target | New hunting session created |
| `hunting.phase.started` | session_id, phase | Hunting phase started |
| `hunting.phase.completed` | session_id, phase | Hunting phase completed |
| `hunting.endpoint.discovered` | session_id, endpoint | New endpoint discovered |
| `hunting.test.performed` | session_id, test_id, result | Test performed |
| `hunting.finding.discovered` | session_id, finding | New vulnerability found |
| `hunting.finding.validated` | session_id, finding_id | Finding validated |
| `hunting.methodology.step` | session_id, step, status | Methodology step tracked |
| `hunting.session.suspended` | session_id, reason | Session suspended |
| `hunting.session.resumed` | session_id | Session resumed |
| `hunting.session.completed` | session_id, findings_count | Session completed |
| `hunting.session.closed` | session_id | Session closed |

## Error Recovery

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| Target Unreachable | Connection refused | Retry with backoff |
| Test Failure | Payload error | Retry with alternative payload |
| State Corruption | Checksum mismatch | Restore from checkpoint |
| Scope Violation | Target out of scope | Suspend and alert |

## Usage Examples

### Creating a Hunting Session

```python
session = create_hunting_session(
    name="hunt-xss-example.com",
    target="example.com",
    scope={"domains": ["example.com"], "paths": ["/api", "/web"]},
    modules=[
        "6-Input-Validation-and-Sanitization.md",
        "31-Server-Side-Template-Injection.md",
        "33-Content-Security-Policy-CSP-Bypass.md"
    ],
    hunting_focus=["xss", "ssti"],
    methodology="owasp-top10"
)
```

### Querying Hunting Results

```python
sessions = find_hunting_sessions(
    completed=True,
    has_findings=True
)
for s in sessions:
    print(f"Target: {s.target}, "
          f"Findings: {s.findings_count}, "
          f"By severity: {s.findings_by_severity}")
```
