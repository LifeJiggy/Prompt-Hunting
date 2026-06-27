# Session Lifecycle: Real-World Case Studies Domain

> Session lifecycle management for disclosed vulnerability analysis, pattern extraction, and exploit technique documentation across all 50 Real-World-Case-Studies modules.

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | `real-world-cases` |
| Source Directory | `Real-World-Case-Studies/` |
| Module Count | 50 |
| Session Type | `disclosed-session` |
| State Complexity | High — tracks pattern extraction, exploit documentation, and learning outcomes |
| Parent System | Session Lifecycle Manager |

## Overview

This document defines the complete session lifecycle for the Real-World Case Studies domain. Disclosed case study sessions manage the systematic analysis of publicly disclosed vulnerabilities, their exploitation techniques, and the lessons learned. Each session tracks which case study modules are loaded, the current analysis phase, patterns extracted from disclosed reports, and knowledge gained.

Real-world case study sessions are distinct from high-level case studies in their focus on specific, detailed vulnerability disclosures. They analyze individual CVEs, bug bounty reports, and security advisories to extract actionable intelligence for future hunting.

## Session State Machine

```
┌─────────┐     activate      ┌──────────┐
│ created │ ─────────────────→│  active   │
└─────────┘                   └────┬─────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │selecting │              │researching│             │analyzing │
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │documenting│             │extracting│              │classifying│
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       └──────────────────────────┼──────────────────────────┘
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
| `created` | Session initialized; case study criteria defined |
| `active` | Session running; analysis workflow active |
| `selecting` | Selecting disclosed cases for analysis |
| `researching` | Deep research into disclosed vulnerability details |
| `analyzing` | Analyzing exploitation techniques and impact |
| `extracting` | Extracting reusable patterns and techniques |
| `documenting` | Documenting findings for future reference |
| `classifying` | Classifying patterns by vulnerability class |
| `completed` | Analysis objectives achieved |
| `closed` | Session terminated and results archived |

## Session Creation

### `create_disclosed_session()`

Creates a new session for disclosed case study analysis.

**Parameters:**
- `name` (str): Human-readable session identifier
- `disclosure_filter` (dict): Criteria for selecting disclosures
- `extraction_focus` (list[str]): Focus areas for pattern extraction
- `modules` (list[str]): Case study modules to load
- `max_duration` (int): Maximum session lifetime in seconds (default: `14400` — 4 hours)
- `auto_checkpoint` (bool): Enable automatic state checkpointing (default: `True`)

**Returns:** `Session` object with unique ID, filter criteria, and extraction focus.

**Validation:**
- Session name must be unique
- Module references must exist in the directory
- Extraction focus must be from recognized set

**Initialization Steps:**
1. Generate session ID: `disc_ses_<40-char-hex>`
2. Validate module references
3. Create session directory: `sessions/<session_id>/`
4. Initialize disclosure analysis tracker
5. Register session in the active disclosed session registry
6. Emit `session.created` event

## Session Close

### `close_disclosed_session(session_id)`

Gracefully terminates a disclosed case study session.

**Pre-close Checks:**
1. Verify all case analyses are saved
2. Check if pattern extraction is complete
3. Ensure documentation is finalized

**Close Process:**
1. Transition state to `closing`
2. Generate analysis summary report
3. Archive extracted patterns by vulnerability class
4. Save documentation for future reference
5. Update pattern library with new entries
6. Remove session from active registry
7. Transition state to `closed`
8. Emit `session.closed` event

## Session Suspend

### `suspend_disclosed_session(session_id)`

Pauses an active disclosed case study session.

**Suspend Process:**
1. Complete current case analysis step
2. Serialize analysis state including:
   - Current disclosure being analyzed
   - Patterns extracted so far
   - Documentation progress
   - Classification status
3. Save progress
4. Transition state to `suspended`

## Session Resume

### `resume_disclosed_session(session_id)`

Restores a suspended disclosed case study session.

**Resume Process:**
1. Load serialized analysis state
2. Verify state integrity
3. Restore analysis position
4. Resume from last phase
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

### Disclosed Case-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `disclosure_filter` | dict | Criteria for disclosure selection |
| `extraction_focus` | list[str] | Pattern extraction focus areas |
| `modules_loaded` | list[str] | Case study modules loaded |
| `current_disclosure` | str | Currently analyzed disclosure |
| `disclosures_analyzed` | list[str] | Completed case analyses |
| `patterns_by_class` | dict[str, list] | Patterns grouped by vulnerability class |
| `exploit_techniques` | list[dict] | Exploitation techniques documented |
| `mitigation_patterns` | list[dict] | Mitigation strategies identified |
| `detection_signatures` | list[dict] | Detection patterns identified |
| `documentation_entries` | list[dict] | Documentation entries created |
| `knowledge_gained` | list[str] | Key knowledge items |

## Session Lookup

### `find_disclosed_sessions()`

Search for disclosed case study sessions by criteria.

**Search Parameters:**
- `state` (str): Filter by session state
- `extraction_focus` (str): Filter by focus area
- `vulnerability_class` (str): Filter by vulnerability class analyzed
- `completed` (bool): Filter by completion status

**Examples:**
```python
# Find all active disclosed sessions
sessions = find_disclosed_sessions(state="active")

# Find sessions analyzing SQL injection cases
sessions = find_disclosed_sessions(vulnerability_class="sqli")
```

## Session Limits

### Disclosed-Specific Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_disclosed_sessions` | 5 | Concurrent disclosed sessions |
| `max_disclosures_per_session` | 30 | Disclosures analyzed per session |
| `max_session_duration` | 14400s (4h) | Maximum analysis runtime |
| `max_modules_per_session` | 10 | Case study modules per session |
| `max_patterns_per_session` | 150 | Patterns extracted per session |
| `max_documentation_entries` | 100 | Documentation entries per session |
| `max_state_size` | 30MB | Serialized state size limit |

## Session Isolation

### File System Isolation

```
sessions/<session_id>/
├── state/
│   ├── disclosed-state.json    # Analysis phase tracker
│   ├── case-analyses/          # Individual case analyses
│   ├── extracted-patterns/     # Patterns by vulnerability class
│   └── checkpoints/            # Serialized checkpoints
├── output/
│   ├── patterns-by-class.json  # Patterns grouped by class
│   ├── exploit-techniques.md   # Documented exploit techniques
│   ├── detection-signatures.md # Detection patterns
│   ├── documentation/          # Detailed documentation
│   └── knowledge-base/         # Knowledge items
├── config/
│   ├── disclosed-config.json   # Session configuration
│   ├── filter.json             # Disclosure selection criteria
│   └── focus.json              # Extraction focus areas
└── metadata.json               # Session metadata
```

## Module References for Real-World Case Studies

| Module | File Reference |
|--------|---------------|
| IDOR Account Takeover Case Studies | `Real-World-Case-Studies/01-IDOR-Account-Takeover-Case-Studies.md` |
| XSS Stored Persistent Attacks | `Real-World-Case-Studies/02-XSS-Stored-Persistent-Attacks.md` |
| SQL Injection Data Breaches | `Real-World-Case-Studies/03-SQL-Injection-Data-Breaches.md` |
| SSRF Internal Network Access | `Real-World-Case-Studies/04-SSRF-Internal-Network-Access.md` |
| CSRF State Changing Attacks | `Real-World-Case-Studies/05-CSRF-State-Changing-Attacks.md` |
| Command Injection RCE | `Real-World-Case-Studies/06-Command-Injection-RCE.md` |
| Deserialization Remote Code Execution | `Real-World-Case-Studies/07-Deserialization-Remote-Code-Execution.md` |
| File Upload Arbitrary Upload | `Real-World-Case-Studies/08-File-Upload-Arbitrary-Upload.md` |
| XXE XML External Entity Attacks | `Real-World-Case-Studies/09-XXE-XML-External-Entity-Attacks.md` |
| SSTI Server-Side Template Injection | `Real-World-Case-Studies/10-SSTI-Server-Side-Template-Injection.md` |
| JWT Token Manipulation | `Real-World-Case-Studies/11-JWT-Token-Manipulation.md` |
| Authentication Bypass | `Real-World-Case-Studies/12-Authentication-Bypass.md` |
| Privilege Escalation | `Real-World-Case-Studies/13-Privilege-Escalation.md` |
| Business Logic Flaws | `Real-World-Case-Studies/14-Business-Logic-Flaws.md` |
| Information Disclosure | `Real-World-Case-Studies/15-Information-Disclosure.md` |
| Memory Corruption Heap Overflow | `Real-World-Case-Studies/16-Memory-Corruption-Heap-Overflow.md` |
| Deserialization Java Deserialization | `Real-World-Case-Studies/17-Deserialization-Java-Deserialization.md` |
| Deserialization PHP Unserialize | `Real-World-Case-Studies/18-Deserialization-PHP-Unserialize.md` |
| Deserialization Python Pickle | `Real-World-Case-Studies/19-Deserialization-Python-Pickle.md` |
| Race Condition Time of Check | `Real-World-Case-Studies/20-Race-Condition-Time-of-Check.md` |
| Host Header Injection | `Real-World-Case-Studies/21-Host-Header-Injection.md` |
| DNS Rebinding Attacks | `Real-World-Case-Studies/22-DNS-Rebinding-Attacks.md` |
| WebSocket Security Issues | `Real-World-Case-Studies/23-WebSocket-Security-Issues.md` |
| GraphQL Introspection Attacks | `Real-World-Case-Studies/24-GraphQL-Introspection-Attacks.md` |
| CSP Bypass Techniques | `Real-World-Case-Studies/25-CSP-Bypass-Techniques.md` |
| Clickjacking UI Redressing | `Real-World-Case-Studies/26-Clickjacking-UI-Redressing.md` |
| HTTP Response Splitting | `Real-World-Case-Studies/27-HTTP-Response-Splitting.md` |
| LDAP Injection Attacks | `Real-World-Case-Studies/28-LDAP-Injection-Attacks.md` |
| XPath Injection Attacks | `Real-World-Case-Studies/29-XPath-Injection-Attacks.md` |
| NoSQL Injection MongoDB | `Real-World-Case-Studies/30-NoSQL-Injection-MongoDB.md` |
| Prototype Pollution JavaScript | `Real-World-Case-Studies/31-Prototype-Pollution-JavaScript.md` |
| Subdomain Takeover | `Real-World-Case-Studies/32-Subdomain-Takeover.md` |
| Open Redirect Phishing | `Real-World-Case-Studies/33-Open-Redirect-Phishing.md` |
| Content Spoofing Attacks | `Real-World-Case-Studies/34-Content-Spoofing-Attacks.md` |
| WebCache Poisoning | `Real-World-Case-Studies/35-WebCache-Poisoning.md` |
| HTTP Request Smuggling | `Real-World-Case-Studies/36-HTTP-Request-Smuggling.md` |
| WebSocket Hijacking | `Real-World-Case-Studies/37-WebSocket-Hijacking.md` |
| CORS Misconfiguration | `Real-World-Case-Studies/38-CORS-Misconfiguration.md` |
| Token Leakage URL Parameters | `Real-World-Case-Studies/39-Token-Leakage-URL-Parameters.md` |
| Sensitive Data Exposure | `Real-World-Case-Studies/40-Sensitive-Data-Exposure.md` |
| Weak Encryption Algorithms | `Real-World-Case-Studies/41-Weak-Encryption-Algorithms.md` |
| Insecure Cryptographic Storage | `Real-World-Case-Studies/42-Insecure-Cryptographic-Storage.md` |
| Path Traversal File Inclusion | `Real-World-Case-Studies/43-Path-Traversal-File-Inclusion.md` |
| Local File Inclusion LFI | `Real-World-Case-Studies/44-Local-File-Inclusion-LFI.md` |
| Remote File Inclusion RFI | `Real-World-Case-Studies/45-Remote-File-Inclusion-RFI.md` |
| Server-Side Request Forgery | `Real-World-Case-Studies/46-Server-Side-Request-Forgery.md` |
| Client-Side Request Forgery | `Real-World-Case-Studies/47-Client-Side-Request-Forgery.md` |
| Mobile API Security Issues | `Real-World-Case-Studies/48-Mobile-API-Security-Issues.md` |
| Cloud Misconfiguration AWS | `Real-World-Case-Studies/49-Cloud-Misconfiguration-AWS.md` |
| API Authentication Bypass | `Real-World-Case-Studies/50-API-Authentication-Bypass.md` |

## Events

### Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `disclosed.session.created` | session_id | New disclosed session created |
| `disclosed.case.selected` | session_id, case_name | Case selected for analysis |
| `disclosed.case.started` | session_id, case_name | Case analysis started |
| `disclosed.case.completed` | session_id, case_name | Case analysis completed |
| `disclosed.pattern.extracted` | session_id, pattern, vuln_class | Pattern extracted |
| `disclosed.technique.documented` | session_id, technique | Exploit technique documented |
| `disclosed.classification.updated` | session_id, vuln_class, count | Classification updated |
| `disclosed.session.suspended` | session_id, reason | Session suspended |
| `disclosed.session.resumed` | session_id | Session resumed |
| `disclosed.session.completed` | session_id | Analysis completed |
| `disclosed.session.closed` | session_id | Session closed |

## Error Recovery

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| Disclosure Unavailable | Report removed | Skip; find alternative source |
| Analysis Timeout | Deep analysis too slow | Reduce depth; summarize |
| State Corruption | Checksum mismatch | Restore from checkpoint |
| Classification Error | Wrong class assigned | Re-classify manually |

## Usage Examples

### Creating a Disclosed Session

```python
session = create_disclosed_session(
    name="extract-xss-patterns",
    disclosure_filter={"vulnerability_class": "xss", "severity": "high"},
    extraction_focus=["exploitation", "detection", "mitigation"],
    modules=[
        "02-XSS-Stored-Persistent-Attacks.md",
        "25-CSP-Bypass-Techniques.md",
        "26-Clickjacking-UI-Redressing.md"
    ]
)
```

### Querying Pattern Extraction Results

```python
sessions = find_disclosed_sessions(
    completed=True,
    vulnerability_class="xss"
)
for s in sessions:
    print(f"Disclosures analyzed: {len(s.disclosures_analyzed)}, "
          f"Patterns: {sum(len(v) for v in s.patterns_by_class.values())}")
```
