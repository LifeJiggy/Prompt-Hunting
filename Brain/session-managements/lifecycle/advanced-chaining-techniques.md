# Session Lifecycle: Advanced Chaining Techniques Domain

> Session lifecycle management for vulnerability chaining, multi-stage exploitation, and cross-vulnerability attack orchestration across all 49 Advanced-Chaining-Techniques modules.

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | `advanced-chaining` |
| Source Directory | `Advanced-Chaining-Techniques/` |
| Module Count | 49 |
| Session Type | `chaining-pipeline` |
| State Complexity | Very High — tracks chain graph, stage dependencies, exploitation state |
| Parent System | Session Lifecycle Manager |

## Overview

This document defines the complete session lifecycle for the Advanced Chaining Techniques domain. Chaining sessions manage the orchestration of multi-vulnerability exploitation chains — where one vulnerability feeds into another to escalate impact. Each session holds a directed graph of chain stages, tracks the execution state of each primitive, and maintains intermediate exploitation data as the chain progresses.

Chaining sessions are among the most complex session types. They require tracking of exploitation primitives (XSS, SSRF, IDOR, etc.), the relationships between them, data flow between chain stages, and the cumulative impact of the chain. A single chaining session may involve dozens of intermediate steps across multiple vulnerability classes.

## Session State Machine

```
┌─────────┐     activate      ┌──────────┐
│ created │ ─────────────────→│  active   │
└─────────┘                   └────┬─────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
        ┌──────────┐        ┌──────────┐         ┌──────────┐
        │planning  │        │executing │         │paused    │
        └────┬─────┘        └────┬─────┘         └────┬─────┘
             │                    │                    │
             ▼                    ▼                    ▼
        ┌──────────┐        ┌──────────┐         ┌──────────┐
        │executing │        │evaluating│         │planning  │
        └────┬─────┘        └────┬─────┘         └──────────┘
             │                    │
             ▼                    ▼
        ┌──────────┐        ┌──────────┐
        │chained   │        │complete  │
        └────┬─────┘        └────┬─────┘
             │                    │
             └────────────────────┘
                              ▼
                       ┌──────────┐
                       │  closed  │
                       └──────────┘
```

### State Definitions

| State | Description |
|-------|-------------|
| `created` | Session initialized, chain graph not yet built |
| `active` | Session running, chain graph loaded |
| `planning` | Chain graph being constructed or modified |
| `executing` | Chain primitives actively being exploited |
| `evaluating` | Assessing chain stage output before proceeding |
| `paused` | Chain execution paused; state preserved |
| `chained` | All chain stages completed; impact assessed |
| `complete` | Final results compiled and available |
| `closed` | Session terminated and resources released |

## Session Creation

### `create_chaining_session()`

Creates a new session for a vulnerability chaining workflow.

**Parameters:**
- `name` (str): Human-readable session identifier
- `target` (str): Primary target for the chain
- `chain_type` (str): Type of chain (e.g., "xss-to-ato", "ssrf-to-rce", "idor-to-data-exfil")
- `initial_primitive` (str): The starting vulnerability class
- `scope` (dict): Scope boundaries for the chain
- `auto_checkpoint` (bool): Enable automatic state checkpointing (default: `True`)
- `max_chain_depth` (int): Maximum chain stages (default: `10`)
- `max_duration` (int): Maximum session lifetime in seconds (default: `7200`)

**Returns:** `Session` object with unique ID, chain graph skeleton, and initial state.

**Validation:**
- Session name must be unique within the active chaining session namespace
- `chain_type` must map to a known chain pattern
- `initial_primitive` must be a recognized vulnerability class
- Scope must define clear boundaries for exploitation

**Initialization Steps:**
1. Generate session ID: `chain_ses_<40-char-hex>`
2. Validate chain type against known patterns
3. Create session directory: `sessions/<session_id>/`
4. Initialize chain graph data structure
5. Register session in the active chaining session registry
6. Emit `session.created` event

## Session Close

### `close_chaining_session(session_id)`

Gracefully terminates a chaining session.

**Pre-close Checks:**
1. Verify no chain primitive is mid-exploitation
2. Check for unsaved chain state; checkpoint if needed
3. Terminate any active exploitation subagents
4. Release proxy connections and tool sessions

**Close Process:**
1. Transition state to `closing`
2. Save final chain graph with completion status
3. Archive all exploitation results and intermediate data
4. Generate chain impact summary
5. Release all resources
6. Remove session from active registry
7. Transition state to `closed`
8. Emit `session.closed` event with chain summary

## Session Suspend

### `suspend_chaining_session(session_id)`

Pauses an active chaining session.

**Suspend Process:**
1. Signal all active chain primitives to pause
2. Wait for current exploitation step to complete
3. Serialize chain graph including:
   - Graph topology (nodes and edges)
   - Completed primitive outputs
   - Pending primitive queue
   - Exploitation data collected so far
   - Chain impact assessment so far
4. Release active resources
5. Transition state to `suspended`
6. Record suspension metadata

**Suspend Reasons:**
| Reason | Description |
|--------|-------------|
| `user_initiated` | User explicitly paused the chain |
| `primitive_timeout` | Chain stage exceeded time limit |
| `scope_boundary` | Chain approaching scope boundary |
| `resource_limit` | System resources exhausted |
| `evaluation_needed` | Manual review required before proceeding |

## Session Resume

### `resume_chaining_session(session_id)`

Restores a suspended chaining session.

**Resume Process:**
1. Load serialized chain graph from session store
2. Verify graph integrity via checksum
3. Re-resolve all primitive tool dependencies
4. Reinitialize exploitation subagents
5. Restore intermediate exploitation data
6. Transition state to `active`
7. Resume chain from last completed stage
8. Emit `session.resumed` event

**Resume Validation:**
- Chain graph must pass integrity check
- Target accessibility must be confirmed
- Tool dependencies must be available
- Scope boundaries must still be valid

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
| `target` | str | Primary chain target |

### Chaining-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `chain_type` | str | Chain classification |
| `chain_graph` | dict | Directed graph of chain stages |
| `initial_primitive` | str | Starting vulnerability class |
| `current_stage` | int | Current execution stage |
| `completed_stages` | list[int] | Completed stage indices |
| `failed_stages` | list[int] | Failed stage indices |
| `primitive_results` | dict | Output from each primitive |
| `chain_impact` | str | Assessed impact level |
| `cumulative_findings` | list[dict] | All findings from chain |
| `exploitation_data` | dict | Data collected during exploitation |
| `scope_compliance` | bool | Whether chain stayed within scope |
| `chain_depth` | int | Current depth of chain |

## Session Lookup

### `find_chaining_sessions()`

Search for chaining sessions by criteria.

**Search Parameters:**
- `state` (str): Filter by session state
- `target` (str): Filter by chain target
- `chain_type` (str): Filter by chain type
- `initial_primitive` (str): Filter by starting vulnerability
- `completed` (bool): Filter by completion status

**Examples:**
```python
# Find all active chaining sessions
sessions = find_chaining_sessions(state="active")

# Find completed XSS-to-ATO chains
sessions = find_chaining_sessions(
    chain_type="xss-to-ato",
    completed=True
)

# Find sessions targeting a specific domain
sessions = find_chaining_sessions(target="example.com")
```

## Session Limits

### Chaining-Specific Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_chaining_sessions` | 3 | Concurrent chaining sessions |
| `max_chain_depth` | 10 | Maximum chain stages |
| `max_primitives_per_chain` | 15 | Total primitives in chain graph |
| `max_session_duration` | 7200s (2h) | Maximum chain execution time |
| `max_exploitation_data` | 100MB | Data collected during exploitation |
| `max_subagents_per_session` | 8 | Subagents for parallel exploitation |
| `max_intermediate_findings` | 5000 | Findings before auto-checkpoint |
| `max_state_size` | 50MB | Serialized state size limit |
| `max_checkpoint_age` | 120s (2min) | Time between auto-checkpoints |
| `max_scope_violations` | 0 | Scope violations before auto-suspend |

## Session Isolation

### File System Isolation

```
sessions/<session_id>/
├── state/
│   ├── chain-graph.json       # Chain topology and execution state
│   ├── primitive-results/     # Output from each primitive
│   │   ├── primitive-01/
│   │   ├── primitive-02/
│   │   └── ...
│   ├── exploitation-data/     # Data collected during exploitation
│   └── checkpoints/           # Serialized checkpoints
├── output/
│   ├── chain-findings.json    # Aggregated chain findings
│   ├── impact-assessment.md   # Chain impact summary
│   └── artifacts/             # Exploitation artifacts
├── config/
│   ├── chain-config.json      # Session configuration
│   └── scope-boundaries.json  # Scope definitions
└── metadata.json              # Session metadata
```

### Network Isolation

- Each session maintains its own exploitation infrastructure
- Proxy configurations are session-scoped
- Tool sessions are not shared across chaining sessions
- External connections are tracked per-session

### Exploitation Isolation

- Chain primitives execute in isolated subagent contexts
- Intermediate exploitation data is session-scoped
- No cross-session data leakage between chains
- Scope boundaries are enforced per-session

## Chain Graph Management

### Graph Structure

The chain graph is a directed acyclic graph (DAG) where:

- **Nodes** represent exploitation primitives (individual vulnerabilities being exploited)
- **Edges** represent data flow between primitives (output of one feeds input of next)
- **Root nodes** are entry points (initial attack vectors)
- **Leaf nodes** are terminal impacts (data exfiltration, account takeover, etc.)

```json
{
  "graph": {
    "nodes": [
      {
        "id": "primitive-01",
        "type": "xss",
        "status": "complete",
        "target_endpoint": "/search?q=",
        "output_data": "session_token_captured"
      },
      {
        "id": "primitive-02",
        "type": "session-hijacking",
        "status": "running",
        "depends_on": ["primitive-01"],
        "input_data": "session_token_captured"
      }
    ],
    "edges": [
      {"from": "primitive-01", "to": "primitive-02"}
    ]
  }
}
```

### Graph Evolution

The chain graph evolves as the session progresses:

1. **Planning Phase**: Skeleton graph created with known vulnerability classes
2. **Execution Phase**: Nodes are populated with actual exploitation data
3. **Evaluation Phase**: Graph is assessed for completeness and impact
4. **Completion Phase**: Final graph represents the full exploitation chain

### Graph Validation

Before each stage execution:
- Verify all dependencies are satisfied
- Check that input data from upstream primitives is available
- Validate that the next primitive is within scope
- Ensure exploitation tools are available

## Chain Pattern Registry

### Known Chain Patterns

| Pattern | Description | Typical Modules |
|---------|-------------|-----------------|
| `xss-to-ato` | XSS leads to account takeover | 03-XSS-to-Account-Takeover |
| `idor-to-data-exfil` | IDOR leads to mass data extraction | 04-IDOR-to-Mass-Data-Extraction |
| `ssrf-to-rce` | SSRF leads to remote code execution | 06-SSRF-to-Internal-Network-Compromise |
| `sqli-to-shell` | SQL injection leads to shell access | 05-SQL-Injection-to-Shell-Access |
| `upload-to-webshell` | File upload leads to web shell | 09-File-Upload-to-Web-Shell |
| `jwt-to-escalation` | JWT manipulation leads to privilege escalation | 12-JWT-Manipulation-Chains |
| `ssti-to-compromise` | SSTI leads to full compromise | 13-SSTI-to-Complete-Compromise |
| `deserialization-to-rce` | Deserialization leads to RCE | 11-Deserialization-to-RCE |
| `cors-to-data-theft` | CORS misconfiguration leads to data theft | 07-CORS-Misconfiguration-Chains |
| `csrf-to-escalation` | CSRF leads to privilege escalation | 08-CSRF-to-Privilege-Escalation |

### Module References for Chaining

| Module | File Reference |
|--------|---------------|
| Basic Vulnerability Chaining | `Advanced-Chaining-Techniques/01-Basic-Vulnerability-Chaining.md` |
| Information Disclosure to RCE | `Advanced-Chaining-Techniques/02-Information-Disclosure-to-RCE.md` |
| XSS to Account Takeover | `Advanced-Chaining-Techniques/03-XSS-to-Account-Takeover.md` |
| IDOR to Mass Data Extraction | `Advanced-Chaining-Techniques/04-IDOR-to-Mass-Data-Extraction.md` |
| SQL Injection to Shell Access | `Advanced-Chaining-Techniques/05-SQL-Injection-to-Shell-Access.md` |
| SSRF to Internal Network Compromise | `Advanced-Chaining-Techniques/06-SSRF-to-Internal-Network-Compromise.md` |
| CORS Misconfiguration Chains | `Advanced-Chaining-Techniques/07-CORS-Misconfiguration-Chains.md` |
| CSRF to Privilege Escalation | `Advanced-Chaining-Techniques/08-CSRF-to-Privilege-Escalation.md` |
| File Upload to Web Shell | `Advanced-Chaining-Techniques/09-File-Upload-to-Web-Shell.md` |
| XXE to Sensitive Data Access | `Advanced-Chaining-Techniques/10-XXE-to-Sensitive-Data-Access.md` |
| Deserialization to RCE | `Advanced-Chaining-Techniques/11-Deserialization-to-RCE.md` |
| JWT Manipulation Chains | `Advanced-Chaining-Techniques/12-JWT-Manipulation-Chains.md` |
| SSTI to Complete Compromise | `Advanced-Chaining-Techniques/13-SSTI-to-Complete-Compromise.md` |
| NoSQL Injection to Data Breach | `Advanced-Chaining-Techniques/15-NoSQL-Injection-to-Data-Breach.md` |
| GraphQL Abuse Chains | `Advanced-Chaining-Techniques/16-GraphQL-Abuse-Chains.md` |
| WebSocket Security Chains | `Advanced-Chaining-Techniques/17-WebSocket-Security-Chains.md` |
| Prototype Pollution Exploitation | `Advanced-Chaining-Techniques/18-Prototype-Pollution-Exploitation.md` |
| HTTP Request Smuggling Chains | `Advanced-Chaining-Techniques/19-HTTP-Request-Smuggling-Chains.md` |
| Host Header Injection Chains | `Advanced-Chaining-Techniques/20-Host-Header-Injection-Chains.md` |
| DNS Rebinding Attacks | `Advanced-Chaining-Techniques/21-DNS-Rebinding-Attacks.md` |
| Race Condition Exploitation | `Advanced-Chaining-Techniques/22-Race-Condition-Exploitation.md` |
| Subdomain Takeover Chains | `Advanced-Chaining-Techniques/23-Subdomain-Takeover-Chains.md` |
| Open Redirect to Phishing | `Advanced-Chaining-Techniques/24-Open-Redirect-to-Phishing.md` |
| Content Spoofing Chains | `Advanced-Chaining-Techniques/25-Content-Spoofing-Chains.md` |
| WebCache Poisoning Chains | `Advanced-Chaining-Techniques/26-WebCache-Poisoning-Chains.md` |
| Clickjacking to Account Compromise | `Advanced-Chaining-Techniques/27-Clickjacking-to-Account-Compromise.md` |
| Parameter Pollution Attacks | `Advanced-Chaining-Techniques/28-Parameter-Pollution-Attacks.md` |
| LDAP Injection Chains | `Advanced-Chaining-Techniques/29-LDAP-Injection-Chains.md` |
| XPath Injection Exploitation | `Advanced-Chaining-Techniques/30-XPath-Injection-Exploitation.md` |
| Session Puzzling Techniques | `Advanced-Chaining-Techniques/31-Session-Puzzling-Techniques.md` |
| Insecure File Handling Chains | `Advanced-Chaining-Techniques/32-Insecure-File-Handling-Chains.md` |
| Cross-Site Script Inclusion | `Advanced-Chaining-Techniques/33-Cross-Site-Script-Inclusion.md` |
| HTTP Response Splitting | `Advanced-Chaining-Techniques/34-HTTP-Response-Splitting.md` |
| Client-Side Storage Abuse | `Advanced-Chaining-Techniques/35-Client-Side-Storage-Abuse.md` |
| Cryptography Weakness Chains | `Advanced-Chaining-Techniques/36-Cryptography-Weakness-Chains.md` |
| Third-Party Component Chains | `Advanced-Chaining-Techniques/37-Third-Party-Component-Chains.md` |
| Configuration Misconfiguration Chains | `Advanced-Chaining-Techniques/38-Configuration-Misconfiguration-Chains.md` |
| Network Infrastructure Chains | `Advanced-Chaining-Techniques/39-Network-Infrastructure-Chains.md` |
| Mobile API Chains | `Advanced-Chaining-Techniques/40-Mobile-API-Chains.md` |
| Cloud Misconfiguration Chains | `Advanced-Chaining-Techniques/41-Cloud-Misconfiguration-Chains.md` |
| Container Escape Chains | `Advanced-Chaining-Techniques/42-Container-Escape-Chains.md` |
| Kubernetes Attack Chains | `Advanced-Chaining-Techniques/43-Kubernetes-Attack-Chains.md` |
| Blockchain Exploit Chains | `Advanced-Chaining-Techniques/44-Blockchain-Exploit-Chains.md` |
| IoT Device Compromise Chains | `Advanced-Chaining-Techniques/45-IoT-Device-Compromise-Chains.md` |
| Supply Chain Attack Chains | `Advanced-Chaining-Techniques/46-Supply-Chain-Attack-Chains.md` |
| Zero-Day Chaining Strategies | `Advanced-Chaining-Techniques/47-Zero-Day-Chaining-Strategies.md` |
| Multi-Platform Attack Chains | `Advanced-Chaining-Techniques/48-Multi-Platform-Attack-Chains.md` |
| Advanced Persistent Threat Chains | `Advanced-Chaining-Techniques/49-Advanced-Persistent-Threat-Chains.md` |
| Master Chaining Framework | `Advanced-Chaining-Techniques/50-Master-Chaining-Framework.md` |

## Events

### Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `chain.session.created` | session_id, chain_type | New chaining session created |
| `chain.session.graph_built` | session_id, node_count, edge_count | Chain graph constructed |
| `chain.session.primitive_started` | session_id, primitive_id, type | Exploitation primitive started |
| `chain.session.primitive_completed` | session_id, primitive_id, output_data | Primitive completed |
| `chain.session.primitive_failed` | session_id, primitive_id, error | Primitive failed |
| `chain.session.stage_evaluated` | session_id, stage, assessment | Stage evaluation complete |
| `chain.session.chain_extended` | session_id, new_node | New primitive added to chain |
| `chain.session.impact_assessed` | session_id, impact_level | Chain impact assessed |
| `chain.session.scope_warning` | session_id, boundary | Approaching scope boundary |
| `chain.session.suspended` | session_id, reason | Session suspended |
| `chain.session.resumed` | session_id | Session resumed |
| `chain.session.completed` | session_id, chain_depth, impact | Chain completed |
| `chain.session.closed` | session_id | Session closed |

## Error Recovery

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| Primitive Failure | XSS payload blocked, SSRF filtered | Try alternative payload; log failure |
| Dependency Unmet | Upstream primitive output unavailable | Pause chain; seek alternative input |
| Scope Violation | Chain approaching out-of-scope target | Suspend; alert user; adjust scope |
| Tool Unavailable | Required tool not installed | Pause; notify; wait for tool setup |
| State Corruption | Chain graph checksum mismatch | Restore from last valid checkpoint |
| Target Unreachable | Target went offline | Retry with backoff; suspend on timeout |

### Recovery Flow

```
error → classify → if primitive_failure:
    try_alternative_payload → if success: continue
    → if exhausted: mark_primitive_failed → evaluate_chain_viability
→ if dependency_issue:
    seek_alternative_input → if found: continue
    → if not found: suspend_and_notify
→ if scope_violation:
    suspend → alert_user → await_replanning
```

## Integration Points

### With Vulnerability Modules

Chaining sessions reference specific vulnerability modules from `Advanced-Chaining-Techniques/`:
- Module 01 provides the basic chaining framework
- Modules 02-50 provide specialized chain patterns
- The Master Chaining Framework (Module 50) provides cross-cutting orchestration

### With Advanced Automation

Chaining sessions can invoke automation modules for:
- Reconnaissance stages (subdomain enum, port scanning)
- Vulnerability detection (SQLi, XSS, SSRF scanning)
- Result analysis and reporting

### With Reconnaissance Deep Dive

Chaining sessions use recon modules for:
- Target discovery and enumeration
- Technology stack identification
- Attack surface mapping

## Usage Examples

### Creating an XSS-to-ATO Chain

```python
session = create_chaining_session(
    name="xss-ato-example.com",
    target="example.com",
    chain_type="xss-to-ato",
    initial_primitive="xss",
    scope={"domains": ["example.com"], "methods": ["web"]},
    max_chain_depth=5
)
```

### Extending a Chain

```python
# Add a new primitive to the chain
extend_chain(
    session_id=session.session_id,
    primitive_type="session-hijacking",
    depends_on=["primitive-01"],
    target_endpoint="/admin/profile"
)
```

### Querying Chain Impact

```python
sessions = find_chaining_sessions(
    chain_type="xss-to-ato",
    completed=True
)
for s in sessions:
    print(f"Chain impact: {s.chain_impact}, depth: {s.chain_depth}")
```
