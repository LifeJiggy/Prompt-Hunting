# CHECKPOINT MANAGEMENT — Advanced Chaining Techniques

## Title

Checkpoint Management for Advanced Chaining Techniques Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `advanced-chaining-techniques` |
| Domain Path | `Advanced-Chaining-Techniques/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/advanced-chaining-techniques/` |
| Session Scope | Chain state, exploit progression, multi-step attack state |
| Auto-Checkpoint Interval | Every chain link completion or 10 minutes |
| Manual Checkpoint Trigger | `/checkpoint save advanced-chaining-techniques [label]` |
| Max Checkpoints Retained | 30 per session |
| Checkpoint TTL | 96 hours (configurable) |
| Restore Command | `/checkpoint restore advanced-chaining-techniques [id]` |

## Overview

This checkpoint management system governs the state of vulnerability chaining workflows defined across the 49 numbered files and the master framework in `Advanced-Chaining-Techniques/`. Chaining attacks involves connecting multiple vulnerabilities to escalate impact — for example, chaining an information disclosure to gain credentials, then using those credentials for privilege escalation, then chaining to RCE. These chains are stateful: each link depends on the output of the previous link. Losing chain state mid-exploitation forces complete re-execution, which may trigger security monitoring or waste significant time.

The checkpoint system captures chain progression state, individual link results, collected artifacts (credentials, tokens, session data), and the current exploitation graph. It supports both linear chains (A → B → C) and branching chains (A → B → C or D), enabling partial chain recovery when individual links fail.

## Auto-Checkpoint Configuration

### Trigger Conditions

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: chain_link_complete
      description: "Checkpoint after each chain link successfully completes"
      always_checkpoint: true
    - type: chain_link_failed
      description: "Checkpoint when a chain link fails for alternate path selection"
      always_checkpoint: true
    - type: artifact_collected
      description: "Checkpoint when a credential, token, or secret is collected"
      events:
        - credential_extracted
        - session_token_captured
        - api_key_discovered
        - password_harvested
        - cookie_stolen
    - type: chain_branch
      description: "Checkpoint at chain branch points"
      events:
        - branch_point_reached
        - alternate_path_selected
        - path_convergence
    - type: time_interval
      description: "Checkpoint every 10 minutes during active chaining"
      interval_minutes: 10
    - type: chain_completion
      description: "Checkpoint when full chain completes"
      always_checkpoint: true
      include_full_results: true
```

### Chain State Serialization

```
chain_state_serialization:
  format: "JSON with base64-encoded binary artifacts"
  artifact_storage:
    inline_threshold_bytes: 1024
    external_file_threshold_bytes: 10240
    external_file_path: "checkpoints/advanced-chaining-techniques/artifacts/"
    artifact_compression: "gzip"
  chain_graph:
    serialization: "adjacency list with node/link metadata"
    include_failed_paths: true
    include_alternate_paths: true
```

## Manual Checkpoint

### Save Command

```
/checkpoint save advanced-chaining-techniques [optional-label]
```

### Manual Checkpoint with Annotations

```
/checkpoint annotate advanced-chaining-techniques [checkpoint-id] "notes about current chain state"
```

### Chain Snapshot Command

```
/chain snapshot [chain-id]
  --include-artifacts    Include collected credentials/tokens
  --include-requests     Include raw HTTP requests/responses
  --include-screenshots  Include captured screenshots
  --minimal              Chain state only, no artifacts
```

## Checkpoint Format Schema

### Chain Checkpoint Structure

```
chain_checkpoint:
  envelope:
    magic: "CHKP-CHAIN-V1"
    version: "1.0"
    domain: "advanced-chaining-techniques"
  sections:
    - section_id: "chain_graph"
      description: "Complete chain execution graph"
      fields:
        - chain_id: "unique chain identifier"
        - chain_type: "linear | branching | recursive"
        - total_links: "integer"
        - completed_links: "integer"
        - current_link_index: "integer"
        - chain_definition: "original chain plan"
        - execution_path: "actual path taken through chain"
    - section_id: "link_states"
      description: "State of each chain link"
      fields:
        - links:
          - link_index: "integer"
            link_name: "descriptive name"
            vuln_class: "vulnerability class used"
            entry_point: "initial input point"
            technique: "exploitation technique applied"
            status: "pending | in_progress | completed | failed | skipped"
            result: "link output (credential, access level, etc.)"
            artifacts: "list of collected artifacts"
            execution_log: "detailed execution history"
            error_info: "failure reason if failed"
            retry_count: "number of retries attempted"
            execution_time: "duration"
    - section_id: "artifacts"
      description: "Collected credentials, tokens, and secrets"
      fields:
        - credentials:
          - type: "username_password | api_key | token | cookie | cert"
            source: "where the credential was obtained"
            target: "what the credential grants access to"
            value_encrypted: "encrypted credential value"
            expiry: "credential expiration time"
            validity_verified: "boolean"
        - sessions:
          - session_id: "captured session identifier"
            session_token: "encrypted session token"
            associated_user: "user context"
            access_level: "privilege level obtained"
    - section_id: "exploitation_graph"
      description: "Visual representation of attack path"
      fields:
        - nodes: "array of exploitation nodes"
        - edges: "array of transitions between nodes"
        - current_position: "current node in graph"
        - visited_nodes: "set of already-visited nodes"
        - dead_ends: "set of exhausted paths"
    - section_id: "checksum"
      description: "Integrity verification"
      fields:
        - payload_hash: "SHA-256"
        - artifact_hashes: "per-artifact SHA-256"
```

## Validation

### Chain Integrity Validation

```
chain_validation:
  pre_checkpoint:
    - rule: "chain_state_coherent"
      description: "Verify all link states are consistent"
      check: "no link marked complete if prerequisites not met"
      action_on_fail: "rebuild_chain_state"
    - rule: "artifacts_encrypted"
      description: "Verify sensitive artifacts are encrypted"
      check: "all credential/token values are encrypted"
      action_on_fail: "encrypt_artifacts"
    - rule: "chain_links_ordered"
      description: "Verify link execution order matches dependency graph"
      check: "topological sort of link dependencies"
      action_on_fail: "reorder_links"
  post_restore:
    - rule: "chain_continuable"
      description: "Verify chain can be continued from checkpoint"
      check: "current link has valid entry point"
      action_on_fail: "find_resume_point"
    - rule: "artifacts_still_valid"
      description: "Verify collected credentials/tokens are still valid"
      check: "test each credential against target"
      action_on_fail: "invalidate_stale_artifacts"
    - rule: "target_state_unchanged"
      description: "Verify target hasn't changed since checkpoint"
      check: "compare target fingerprint to checkpoint"
      action_on_fail: "re_fingerprint_target"
```

## Pruning Strategy

```
pruning_strategy:
  retention_policy:
    max_checkpoints: 30
    ttl_hours: 96
    preserve_completed_chains: true
    preserve_manual_checkpoints: true
    preserve_artifact_checkpoints: true
  pruning_priority:
    1: "failed_chain_checkpoints — prune first"
    2: "partial_chain_checkpoints with no artifacts — prune second"
    3: "time_interval_checkpoints — routine saves"
    4: "chain_link_checkpoints — granular saves"
    5: "chain_completion_checkpoints — keep longest"
    6: "artifact_checkpoints — preserve until artifacts consumed"
  artifact_cleanup:
    expired_artifacts: "remove after credential expiry + 24h"
    used_artifacts: "mark as consumed, archive after 48h"
    unused_artifacts: "keep for full TTL period"
```

## Checkpoint Index

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "advanced-chaining-techniques"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "user label"
        chain_id: "chain identifier"
        chain_type: "linear | branching | recursive"
        links_completed: "integer / total"
        artifacts_collected: "integer"
        status: "active | completed | failed"
        file_path: "relative path"
        checksum: "SHA-256 prefix"
    chain_history:
      - chain_id: "string"
        chain_name: "descriptive name"
        total_checkpoints: "integer"
        final_status: "completed | abandoned | in_progress"
        total_artifacts: "integer"
        total_duration: "duration"
```

## Restore from Checkpoint

```
restore_procedure:
  steps:
    1: "Load checkpoint index for advanced-chaining-techniques"
    2: "Identify chain checkpoint by id, chain_id, or label"
    3: "Validate chain checkpoint integrity"
    4: "Check artifact validity (are credentials still fresh?)"
    5: "Restore chain graph state"
    6: "Restore link states and results"
    7: "Restore artifacts (decrypt credential values)"
    8: "Restore exploitation graph position"
    9: "Re-validate target accessibility"
    10: "Resume chain from current link"
    11: "Log restoration event"
  resume_strategies:
    - from_current_link: "Resume from exact checkpoint position"
    - from_last_success: "Resume from last successful link, re-execute current"
    - from_branch_point: "Go back to last branch point, try alternate path"
    - full_replay: "Re-execute entire chain from beginning, using checkpoint artifacts"
```

## Domain File References

### Basic Chaining (01-10)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `01-Basic-Vulnerability-Chaining.md` | Stores basic chain state, simple A→B progress |
| 02 | `02-Information-Disclosure-to-RCE.md` | Stores info leak results, extracted credentials, RCE progression |
| 03 | `03-XSS-to-Account-Takeover.md` | Stores XSS payload delivery, session capture, ATO state |
| 04 | `04-IDOR-to-Mass-Data-Extraction.md` | Stores IDOR parameters, data extraction progress |
| 05 | `05-SQL-Injection-to-Shell-Access.md` | Stores SQLi injection points, data extraction, shell state |
| 06 | `06-SSRF-to-Internal-Network-Compromise.md` | Stores SSRF endpoints, internal hosts discovered, pivot state |
| 07 | `07-CORS-Misconfiguration-Chains.md` | Stores CORS origin analysis, cross-origin request state |
| 08 | `08-CSRF-to-Privilege-Escalation.md` | Stores CSRF tokens, privilege escalation progress |
| 09 | `09-File-Upload-to-Web-Shell.md` | Stores upload endpoints, shell deployment state |
| 10 | `10-XXE-to-Sensitive-Data-Access.md` | Stores XXE injection points, extracted data paths |

### Intermediate Chaining (11-20)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 11 | `11-Deserialization-to-RCE.md` | Stores gadget chains, serialized payloads, RCE state |
| 12 | `12-JWT-Manipulation-Chains.md` | Stores JWT analysis, algorithm manipulation state |
| 13 | `13-SSTI-to-Complete-Compromise.md` | Stores template injection state, RCE progression |
| 15 | `15-NoSQL-Injection-to-Data-Breach.md` | Stores NoSQL injection state, data extraction progress |
| 16 | `16-GraphQL-Abuse-Chains.md` | Stores GraphQL schema abuse, introspection results |
| 17 | `17-WebSocket-Security-Chains.md` | Stores WebSocket hijacking state, message capture |
| 18 | `18-Prototype-Pollution-Exploitation.md` | Stores prototype pollution sinks, exploitation state |
| 19 | `19-HTTP-Request-Smuggling-Chains.md` | Stores smuggling state, request queue manipulation |
| 20 | `20-Host-Header-Injection-Chains.md` | Stores host header injection state, poisoning results |

### Advanced Chaining (21-30)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 21 | `21-DNS-Rebinding-Attacks.md` | Stores DNS rebinding state, race condition timing |
| 22 | `22-Race-Condition-Exploitation.md` | Stores race condition state, thread synchronization |
| 23 | `23-Subdomain-Takeover-Chains.md` | Stores subdomain takeover state, DNS configuration |
| 24 | `24-Open-Redirect-to-Phishing.md` | Stores redirect chains, phishing URL state |
| 25 | `25-Content-Spoofing-Chains.md` | Stores content spoofing state, injection points |
| 26 | `26-WebCache-Poisoning-Chains.md` | Stores cache poisoning state, cache keys |
| 27 | `27-Clickjacking-to-Account-Compromise.md` | Stores clickjacking state, UI overlay progress |
| 28 | `28-Parameter-Pollution-Attacks.md` | Stores parameter pollution state, parsing conflicts |
| 29 | `29-LDAP-Injection-Chains.md` | Stores LDAP injection state, directory access |
| 30 | `30-XPath-Injection-Exploitation.md` | Stores XPath injection state, XML document access |

### Expert Chaining (31-40)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 31 | `31-Session-Puzzling-Techniques.md` | Stores session puzzling state, variable scope manipulation |
| 32 | `32-Insecure-File-Handling-Chains.md` | Stores file handling state, path traversal chains |
| 33 | `33-Cross-Site-Script-Inclusion.md` | Stores XSSI state, script inclusion vectors |
| 34 | `34-HTTP-Response-Splitting.md` | Stores response splitting state, header injection |
| 35 | `35-Client-Side-Storage-Abuse.md` | Stores client storage abuse state, localStorage/cookie manipulation |
| 36 | `36-Cryptography-Weakness-Chains.md` | Stores crypto analysis state, key recovery progress |
| 37 | `37-Third-Party-Component-Chains.md` | Stores component vulnerability state, dependency chains |
| 38 | `38-Configuration-Misconfiguration-Chains.md` | Stores config misconfiguration state, privilege chains |
| 39 | `39-Network-Infrastructure-Chains.md` | Stores network layer attack state, infrastructure pivot |
| 40 | `40-Mobile-API-Chains.md` | Stores mobile API chain state, app-level exploitation |

### Master Level (41-50)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 41 | `41-Cloud-Misconfiguration-Chains.md` | Stores cloud misconfiguration state, cross-service chains |
| 42 | `42-Container-Escape-Chains.md` | Stores container escape state, host access progression |
| 43 | `43-Kubernetes-Attack-Chains.md` | Stores K8s attack state, cluster compromise progression |
| 44 | `44-Blockchain-Exploit-Chains.md` | Stores blockchain exploit state, smart contract chains |
| 45 | `45-IoT-Device-Compromise-Chains.md` | Stores IoT compromise state, device chain progression |
| 46 | `46-Supply-Chain-Attack-Chains.md` | Stores supply chain attack state, dependency compromise |
| 47 | `47-Zero-Day-Chaining-Strategies.md` | Stores zero-day chain state, novel attack progression |
| 48 | `48-Multi-Platform-Attack-Chains.md` | Stores cross-platform chain state, platform pivot |
| 49 | `49-Advanced-Persistent-Threat-Chains.md` | Stores APT chain state, long-term persistence |
| 50 | `50-Master-Chaining-Framework.md` | Stores master chain orchestration, framework state |

## Chain State Machine

```
chain_states:
  - INITIALIZED: "Chain defined, no links executed"
  - IN_PROGRESS: "Chain actively being executed"
  - PAUSED: "Chain paused by user or system"
  - BLOCKED: "Chain blocked by failed link, awaiting decision"
  - BRANCHING: "Chain at branch point, multiple paths available"
  - CONVERGING: "Multiple chain paths converging"
  - COMPLETED: "All chain links successfully executed"
  - FAILED: "Chain failed, cannot continue"
  - ABANDONED: "Chain abandoned by user"

state_transitions:
  INITIALIZED -> IN_PROGRESS: "chain_execution_start"
  IN_PROGRESS -> PAUSED: "user_pause or system_pause"
  IN_PROGRESS -> BLOCKED: "link_failure"
  IN_PROGRESS -> BRANCHING: "branch_point_reached"
  IN_PROGRESS -> COMPLETED: "all_links_done"
  IN_PROGRESS -> FAILED: "unrecoverable_error"
  PAUSED -> IN_PROGRESS: "user_resume"
  BLOCKED -> IN_PROGRESS: "link_retry_success or alternate_path_selected"
  BLOCKED -> FAILED: "max_retries_exceeded"
  BRANCHING -> IN_PROGRESS: "path_selected"
  BRANCHING -> COMPLETED: "all_alternatives_exhausted_or_target_reached"
  FAILED -> INITIALIZED: "chain_reset"
  ABANDONED -> INITIALIZED: "chain_restart"
```

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `advanced-automation` | Scan results feed chain initiation |
| `advanced-persistence-exploitation` | Chain end-state feeds persistence setup |
| `core-prompts-hunting` | Chain findings inform hunting strategy |
| `real-world-case-studies` | Historical chains inform current chain design |
| `report-writing-mastery` | Chain results feed report generation |

## Checkpoint Recovery for Chain-Specific Scenarios

### Scenario 1: Chain Link Time-Out

```
recovery_scenario: link_timeout
  detection: "link execution exceeds timeout threshold"
  checkpoint_behavior:
    save_incomplete_link: true
    save_partial_artifacts: true
    mark_link_status: "timeout"
  restore_behavior:
    retry_link: true
    adjust_timeout: "increase by 50%"
    fallback_technique: "try alternate exploitation method"
```

### Scenario 2: Credential Expiry During Chain

```
recovery_scenario: credential_expired
  detection: "authentication with collected credential fails"
  checkpoint_behavior:
    save_current_chain_position: true
    mark_credential_as_expired: true
    save_last_valid_credential_state: true
  restore_behavior:
    re_collect_credential: true
    find_alternate_credential_source: true
    resume_from_credential_collection: true
```

### Scenario 3: Target Detection

```
recovery_scenario: target_detected_activity
  detection: "WAF block, rate limit, or security alert"
  checkpoint_behavior:
    save_immediate_state: true
    record_detection_indicator: true
    mark_chain_as_detected: true
  restore_behavior:
    wait_period: "configurable cooldown"
    switch_persona: true
    resume_with_stealth: true
```

### Scenario 4: Branch Path Exploration

```
recovery_scenario: branch_exploration
  detection: "chain reaches branch point"
  checkpoint_behavior:
    save_branch_point_state: true
    enumerate_alternate_paths: true
    checkpoint_per_path: true
  restore_behavior:
    select_path: "user chooses or auto-select"
    rollback_to_branch: true
    execute_selected_path: true
```
