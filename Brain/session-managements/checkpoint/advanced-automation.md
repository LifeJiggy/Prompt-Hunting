# CHECKPOINT MANAGEMENT — Advanced Automation

## Title

Checkpoint Management for Advanced Automation Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `advanced-automation` |
| Domain Path | `Advanced-Automation/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/advanced-automation/` |
| Session Scope | Scanning pipeline state, tool configurations, scan progress |
| Auto-Checkpoint Interval | Every 5 scan steps or 15 minutes, whichever comes first |
| Manual Checkpoint Trigger | `/checkpoint save advanced-automation [label]` |
| Max Checkpoints Retained | 25 per session |
| Checkpoint TTL | 72 hours (configurable) |
| Restore Command | `/checkpoint restore advanced-automation [id]` |

## Overview

This checkpoint management system governs the state of all automated scanning workflows defined across the 50 files in the `Advanced-Automation/` directory. It ensures that multi-step scanning pipelines can be paused, resumed, and recovered without losing intermediate results. Each checkpoint captures the current scan pipeline state, which tools have been executed, their results, pending operations, rate-limit counters, and configuration snapshots. The system is designed for long-running scan operations that may span multiple sessions or encounter interruptions such as network failures, tool crashes, or operator pauses.

Checkpoint management for this domain is critical because scanning automation involves chaining multiple tools together — subdomain enumeration feeds port scanning, which feeds vulnerability scanning, which feeds report generation. Losing state at any point forces re-execution of upstream steps, wasting time and risking rate-limit triggers. The checkpoint system prevents this by serializing pipeline state to disk at well-defined intervals.

## Auto-Checkpoint Configuration

### Trigger Conditions

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: step_completion
      description: "Checkpoint after every 5 completed scan steps"
      step_threshold: 5
    - type: time_interval
      description: "Checkpoint every 15 minutes during active scanning"
      interval_minutes: 15
    - type: tool_transition
      description: "Checkpoint when switching between major tools"
      events:
        - subdomain_enum_to_port_scan
        - port_scan_to_vuln_scan
        - vuln_scan_to_report_generation
        - proxy_to_browser_automation
        - any_to_proxy
    - type: error_recovery
      description: "Checkpoint before and after error recovery"
      events:
        - pre_error_handling
        - post_error_recovery
    - type: result_milestone
      description: "Checkpoint when significant results are found"
      events:
        - new_vulnerability_discovered
        - critical_finding_confirmed
        - scan_completion_percentage_25
        - scan_completion_percentage_50
        - scan_completion_percentage_75
        - scan_completion_percentage_100
```

### Checkpoint Storage Configuration

```
checkpoint_storage:
  base_path: "Brain/session-managements/checkpoint/advanced-automation/"
  naming_convention: "auto-{domain}-{timestamp}-{step_count}.cp"
  compression: enabled
  encryption: optional
  max_size_mb: 50
  cleanup_policy: "rotate_oldest"
  retention_count: 25
  ttl_hours: 72
  backup_to_memory: true
```

### Auto-Checkpoint Payload Schema

```
auto_checkpoint_payload:
  header:
    checkpoint_id: "uuid-v4"
    domain: "advanced-automation"
    created_at: "ISO-8601 timestamp"
    session_id: "active session identifier"
    checkpoint_type: "auto"
    trigger: "step_completion | time_interval | tool_transition | error_recovery | result_milestone"
  pipeline_state:
    current_step: "integer"
    total_steps: "integer"
    completion_percentage: "float 0-100"
    active_tool: "current tool name"
    tool_queue: "list of pending tools"
  tool_results:
    completed_tools:
      - tool_name: "string"
        execution_time: "duration"
        result_summary: "brief summary"
        result_file: "path to full results"
        status: "success | partial | failed"
    pending_tools:
      - tool_name: "string"
        configuration: "tool-specific config snapshot"
        estimated_time: "duration"
  scan_config:
    target_scope: "list of targets"
    excluded_hosts: "list"
    rate_limits: "current rate-limit state per tool"
    proxy_state: "active proxy configuration"
    browser_state: "headless browser session state"
  metrics:
    requests_made: "integer"
    requests_failed: "integer"
    findings_count: "integer"
    findings_by_severity:
      critical: "integer"
      high: "integer"
      medium: "integer"
      low: "integer"
      informational: "integer"
    scan_duration: "duration"
    estimated_remaining: "duration"
  validation:
    checksum: "SHA-256 of serialized state"
    integrity_verified: "boolean"
```

## Manual Checkpoint

### Save Command

```
/checkpoint save advanced-automation [optional-label]
```

### Manual Checkpoint Options

```
manual_checkpoint:
  save_options:
    - label: "user-defined label for easy identification"
    - snapshot: "take full snapshot including tool outputs"
    - minimal: "save only pipeline state, skip tool outputs"
    - annotated: "add user notes to checkpoint"
  save_format:
    include_metadata: true
    include_tool_configs: true
    include_scan_results: true
    include_rate_limit_state: true
    include_proxy_state: true
    include_browser_cookies: false
    include_environment_vars: false
```

### List Checkpoints

```
/checkpoint list advanced-automation [--filter label|date|size] [--sort asc|desc]
```

### Delete Checkpoint

```
/checkpoint delete advanced-automation [checkpoint-id]
```

## Checkpoint Format Schema

### Checkpoint File Structure

```
checkpoint_file:
  envelope:
    magic: "CHKP-ADV-AUTO-V1"
    version: "1.0"
    encoding: "UTF-8"
    compression: "gzip"
  sections:
    - section_id: "pipeline"
      description: "Current pipeline execution state"
      fields:
        - pipeline_id: "string"
        - current_step_index: "integer"
        - total_steps: "integer"
        - step_states: "array of step state objects"
        - pipeline_config: "original pipeline definition"
    - section_id: "tools"
      description: "Tool execution state and results"
      fields:
        - completed: "array of completed tool results"
        - running: "currently executing tool state"
        - queued: "array of pending tool configurations"
        - failed: "array of failed tool states with error info"
    - section_id: "findings"
      description: "Discovered findings and vulnerabilities"
      fields:
        - findings: "array of finding objects"
        - false_positives: "array of dismissed findings"
        - pending_review: "array of findings needing validation"
    - section_id: "state"
      description: "Session and environment state"
      fields:
        - session_id: "string"
        - start_time: "ISO-8601"
        - last_checkpoint_time: "ISO-8601"
        - total_runtime: "duration"
        - rate_limit_state: "per-tool rate limit counters"
        - proxy_state: "active proxy configuration"
        - authentication_state: "current auth tokens/cookies"
    - section_id: "checksum"
      description: "Integrity verification"
      fields:
        - payload_hash: "SHA-256"
        - section_hashes: "per-section SHA-256"
        - verified_at: "ISO-8601"
```

## Validation

### Pre-Restore Validation

```
validation_rules:
  pre_restore:
    - rule: "checksum_match"
      description: "Verify checkpoint file integrity"
      action_on_fail: "abort_restore"
    - rule: "version_compatible"
      description: "Check checkpoint version matches current system"
      action_on_fail: "attempt_migration"
    - rule: "session_expired"
      description: "Check if original session is still active"
      action_on_fail: "warn_user"
    - rule: "target_scope_valid"
      description: "Verify target scope still in scope"
      action_on_fail: "abort_restore"
    - rule: "tool_versions_compatible"
      description: "Verify tool versions match checkpoint expectations"
      action_on_fail: "warn_user_allow_proceed"
    - rule: "rate_limit_state_valid"
      description: "Verify rate limit counters are still accurate"
      action_on_fail: "reset_rate_limits"
```

### Post-Restore Validation

```
validation_rules:
  post_restore:
    - rule: "pipeline_state_coherent"
      description: "Verify pipeline state is internally consistent"
      action_on_fail: "rebuild_state"
    - rule: "tool_connectivity"
      description: "Verify all external tools are reachable"
      action_on_fail: "mark_unavailable_tools"
    - rule: "findings_deduplication"
      description: "Check for duplicate findings from restored state"
      action_on_fail: "deduplicate_findings"
    - rule: "scan_resume_feasible"
      description: "Verify scan can actually resume from checkpoint"
      action_on_fail: "suggest_earlier_checkpoint"
    - rule: "memory_sufficient"
      description: "Verify system has enough memory for restored state"
      action_on_fail: "unload_nonessential_state"
```

## Pruning Strategy

### Automatic Pruning Rules

```
pruning_strategy:
  triggers:
    - condition: "checkpoint_count > max_retained"
      action: "remove_oldest_checkpoints"
      keep_minimum: 5
      preserve_labeled: true
      preserve_critical_milestones: true
    - condition: "checkpoint_age > ttl_hours"
      action: "remove_expired_checkpoints"
      grace_period_hours: 12
    - condition: "disk_usage > max_storage_mb"
      action: "prune_largest_checkpoints_first"
      target_free_mb: 100
    - condition: "session_completed"
      action: "archive_checkpoints"
      archive_after_hours: 24
      archive_location: "Brain/session-managements/checkpoint/archive/"
  priority_order:
    1: "error_recovery_checkpoints — always preserved longest"
    2: "manual_checkpoints — user-created, highest value"
    3: "tool_transition_checkpoints — natural break points"
    4: "result_milestone_checkpoints — discovery markers"
    5: "time_interval_checkpoints — routine saves"
    6: "step_completion_checkpoints — most granular, prune first"
```

### Pruning Schedule

```
pruning_schedule:
  - cron: "0 */6 * * *"
    description: "Run pruning every 6 hours"
    checks:
      - expired_checkpoints
      - over_limit_checkpoints
      - oversized_checkpoints
  - on_event: "session_start"
    description: "Prune at session start"
    checks:
      - orphaned_checkpoints
      - corrupted_checkpoints
  - on_event: "checkpoint_create"
    description: "Check limits after creating new checkpoint"
    checks:
      - count_limit
      - disk_limit
```

## Checkpoint Index

### Index Schema

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "advanced-automation"
    total_checkpoints: "integer"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "optional user label"
        type: "auto | manual"
        trigger: "trigger description"
        size_bytes: "integer"
        pipeline_step: "integer / total"
        completion_percentage: "float"
        findings_count: "integer"
        file_path: "relative path to checkpoint file"
        checksum: "SHA-256 first 16 chars"
        status: "valid | corrupt | archived"
    metadata:
      first_checkpoint: "ISO-8601"
      last_checkpoint: "ISO-8601"
      most_recent_valid: "checkpoint_id"
      total_size_bytes: "integer"
      pruning_last_run: "ISO-8601"
```

### Index Update Rules

```
index_update_rules:
  - event: "checkpoint_created"
    action: "add entry to index"
  - event: "checkpoint_restored"
    action: "update restore_count and last_restored"
  - event: "checkpoint_deleted"
    action: "remove entry from index"
  - event: "checkpoint_corrupted"
    action: "mark status as corrupt"
  - event: "checkpoint_archived"
    action: "move to archived section"
```

## Restore from Checkpoint

### Restore Procedure

```
restore_procedure:
  steps:
    1: "Load checkpoint index"
    2: "Identify target checkpoint by id or label"
    3: "Run pre-restore validation"
    4: "If validation passes, proceed; if fails, try next valid checkpoint"
    5: "Deserialize checkpoint payload"
    6: "Restore pipeline state"
    7: "Restore tool configurations"
    8: "Restore rate limit counters"
    9: "Restore proxy state"
    10: "Run post-restore validation"
    11: "Resume pipeline execution"
    12: "Log restore event in checkpoint index"
```

### Restore Options

```
restore_options:
  - full: "Restore complete state including all tool outputs"
  - state_only: "Restore pipeline state only, re-execute tools"
  - from_step: "Restore and begin from specific step number"
  - dry_run: "Validate restore without actually restoring"
  - merge: "Merge checkpoint state with current state"
```

## Domain File References

### Phase 1: Enumeration and Discovery

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `01-Subdomain-Enumeration-Automation.md` | Stores enumerated subdomains, DNS resolution results, wildcard detection state |
| 02 | `02-Port-Scanning-Automation.md` | Stores port scan progress, discovered services, scan timing state |
| 03 | `03-Vulnerability-Scanning-Automation.md` | Stores vulnerability scan progress, detected CVEs, false-positive filter state |
| 04 | `04-JavaScript-Analysis-Automation.md` | Stores JS endpoint extraction progress, deobfuscation state |
| 05 | `05-API-Endpoint-Discovery.md` | Stores discovered API endpoints, documentation extraction state |
| 06 | `06-Parameter-Fuzzing-Automation.md` | Stores fuzzing progress, parameter lists, payload state |
| 07 | `07-Directory-Brute-Forcing.md` | Stores directory brute-force progress, discovered paths |
| 09 | `09-Authentication-Testing-Automation.md` | Stores auth testing state, credential state, session tokens |
| 10 | `10-Session-Management-Testing.md` | Stores session testing progress, cookie analysis state |
| 11 | `11-IDOR-Detection-Automation.md` | Stores IDOR detection state, parameter mapping |
| 12 | `12-SQL-Injection-Automation.md` | Stores SQLi scan progress, injection point mapping |
| 13 | `13-XSS-Detection-Automation.md` | Stores XSS detection state, reflected/stored XSS findings |
| 14 | `14-SSRF-Testing-Automation.md` | Stores SSRF testing state, internal network probe results |
| 15 | `15-CSRF-Testing-Automation.md` | Stores CSRF testing state, token analysis |
| 16 | `16-Command-Injection-Automation.md` | Stores command injection test state, payload results |
| 17 | `17-XXE-Testing-Automation.md` | Stores XXE testing state, XML entity map |
| 18 | `18-SSTI-Testing-Automation.md` | Stores SSTI testing state, template detection results |
| 19 | `19-JWT-Testing-Automation.md` | Stores JWT analysis state, algorithm confusion tests |
| 20 | `20-Deserialization-Testing.md` | Stores deserialization testing state, gadget chain mapping |

### Phase 2: Analysis and Reporting

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 21 | `21-Report-Generation-Automation.md` | Stores report generation state, template selection, draft progress |
| 22 | `22-PoC-Development-Automation.md` | Stores PoC development state, test case results |
| 23 | `23-Target-Scouting-Automation.md` | Stores target reconnaissance state, scope mapping |
| 24 | `24-Scope-Validation-Automation.md` | Stores scope validation results, boundary checks |
| 25 | `25-Asset-Tracking-Automation.md` | Stores asset inventory, tracking state |
| 26 | `26-Change-Monitoring-Automation.md` | Stores baseline state, change detection results |
| 27 | `27-Notification-Alerting-Systems.md` | Stores alerting configuration, notification state |
| 28 | `28-Data-Collection-Automation.md` | Stores data collection progress, raw data cache |
| 29 | `29-Result-Analysis-Automation.md` | Stores analysis state, correlation results |
| 30 | `30-Tool-Chaining-Automation.md` | Stores tool chain state, execution graph |

### Phase 3: Integration and Orchestration

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 31 | `31-Proxy-Integration-Automation.md` | Stores proxy configuration, intercepted traffic state |
| 32 | `32-Browser-Automation-Workflows.md` | Stores browser session state, page navigation history |
| 33 | `33-Headless-Browser-Scripting.md` | Stores headless browser state, script execution progress |
| 34 | `34-Regex-Pattern-Automation.md` | Stores compiled regex patterns, match state |
| 35 | `35-Response-Analysis-Automation.md` | Stores response analysis state, anomaly detection results |
| 36 | `36-Header-Injection-Testing.md` | Stores header injection test state, header manipulation results |
| 37 | `37-CORS-Testing-Automation.md` | Stores CORS testing state, origin analysis results |
| 38 | `38-WebSocket-Testing-Automation.md` | Stores WebSocket connection state, message capture results |
| 39 | `39-GraphQL-Testing-Automation.md` | Stores GraphQL schema state, introspection results |
| 40 | `40-Cloud-Service-Enumeration.md` | Stores cloud service discovery state, provider-specific results |

### Phase 4: OSINT and Intelligence

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 41 | `41-DNS-Data-Extraction-Automation.md` | Stores DNS record extraction state, zone transfer results |
| 42 | `42-Email-Recon-Automation.md` | Stores email harvesting state, address validation results |
| 43 | `43-Social-Media-OSINT-Automation.md` | Stores social media OSINT state, profile mapping |
| 44 | `44-Framework-Detection-Automation.md` | Stores framework fingerprint results, version detection |
| 45 | `45-Technology-Stack-Identification.md` | Stores tech stack identification state, library mapping |
| 46 | `46-Endpoint-Mapping-Automation.md` | Stores endpoint map, URL hierarchy |
| 47 | `47-Content-Discovery-Automation.md` | Stores content discovery state, hidden content map |
| 48 | `48-Version-Detection-Automation.md` | Stores version detection results, update status |
| 49 | `49-Compliance-Checking-Automation.md` | Stores compliance check state, finding categories |
| 50 | `50-Workflow-Orchestration-Automation.md` | Stores orchestration state, workflow execution graph |

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `advanced-chaining-techniques` | Vulnerability findings fed into chaining pipelines |
| `automation-efficiency` | Performance metrics, optimization state |
| `reconnaissance-deep-dive` | Recon results feed enumeration automation |
| `core-prompts-hunting` | Test progress feeds hunting prompts |
| `report-writing-mastery` | Findings feed report generation |

## Checkpoint Recovery Scenarios

### Scenario 1: Tool Crash Recovery

```
recovery_scenario: tool_crash
  detected_by: "exit_code != 0 or signal_received"
  checkpoint_behavior:
    pre_crash: "save state immediately before crash handler runs"
    post_crash: "log crash details, mark tool as failed"
  restore_behavior:
    skip_failed_tool: false
    retry_failed_tool: true
    max_retries: 3
    retry_delay_seconds: 30
```

### Scenario 2: Network Interruption Recovery

```
recovery_scenario: network_interruption
  detected_by: "connection_timeout or dns_resolution_failure"
  checkpoint_behavior:
    pre_interruption: "save all in-flight state"
    during_interruption: "queue operations, save periodically"
    post_interruption: "validate state, resume from last checkpoint"
  restore_behavior:
    reconnect: true
    retry_pending_requests: true
    timeout_before_retry: 60
```

### Scenario 3: Session Timeout Recovery

```
recovery_scenario: session_timeout
  detected_by: "idle_timeout exceeded or explicit logout"
  checkpoint_behavior:
    pre_timeout: "save complete state at timeout boundary"
    auth_state: "preserve authentication tokens if valid"
  restore_behavior:
    re_authenticate: true
    preserve_scan_progress: true
    skip_completed_steps: true
```

### Scenario 4: Rate Limit Recovery

```
recovery_scenario: rate_limit_hit
  detected_by: "HTTP 429 or rate_limit_response_detected"
  checkpoint_behavior:
    pre_limit: "save current rate limit counters"
    during_cooldown: "save cooldown state, estimated_resume_time"
  restore_behavior:
    resume_after_cooldown: true
    adjust_rate_limits: true
    spread_requests: true
```

## Checkpoint Metrics and Monitoring

```
metrics:
  - checkpoint_create_latency_ms: "time to create checkpoint"
  - checkpoint_restore_latency_ms: "time to restore from checkpoint"
  - checkpoint_size_bytes: "size of checkpoint file"
  - checkpoint_frequency: "checkpoints per hour during active scanning"
  - restoration_success_rate: "percentage of successful restores"
  - data_loss_events: "number of data loss events prevented by checkpoints"
  - average_pipeline_step_time: "average time per pipeline step"
  - checkpoint_overhead_percentage: "percentage of scan time spent on checkpointing"
```

## Integration with Memory System

```
memory_integration:
  session_checkpoint: "Auto-save checkpoint metadata to session checkpoint.md"
  task_progress: "Write scan progress to task-specific progress.md"
  project_memory: "Store scan configurations and learnings to MEMORY.md"
  notes: "Log checkpoint-related observations to notes.md"
  persistence: "Ensure checkpoint data survives session boundaries"
```

## Advanced Configuration

### Parallel Scan Checkpointing

```
parallel_scan_checkpoint:
  enabled: true
  per_thread_checkpoints: true
  merge_strategy: "combine results at synchronization barriers"
  thread_count: "number of parallel scan threads"
  sync_checkpoint_interval: "checkpoint at every thread synchronization point"
```

### Incremental Checkpointing

```
incremental_checkpoint:
  enabled: true
  delta_from: "reference checkpoint id"
  delta_fields: "only changed fields since reference"
  merge_method: "field-level merge with conflict resolution"
  full_checkpoint_every_n: 10
  compression_ratio_target: 0.3
```

### Distributed Scan Checkpointing

```
distributed_checkpoint:
  enabled: false
  shared_store: "network path or database"
  coordination: "leader-election for checkpoint writes"
  conflict_resolution: "last-writer-wins with timestamp"
  consistency_level: "eventual"
```
