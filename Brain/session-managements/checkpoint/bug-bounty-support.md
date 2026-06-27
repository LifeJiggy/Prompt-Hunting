# CHECKPOINT MANAGEMENT — Bug Bounty Support

## Title

Checkpoint Management for Bug Bounty Support Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `bug-bounty-support` |
| Domain Path | `bug-bounty-support/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/bug-bounty-support/` |
| Session Scope | Loaded frameworks, support tools state, vulnerability class coverage |
| Auto-Checkpoint Interval | Every framework load/unload or 10 minutes |
| Manual Checkpoint Trigger | `/checkpoint save bug-bounty-support [label]` |
| Max Checkpoints Retained | 18 per session |
| Checkpoint TTL | 60 hours (configurable) |
| Restore Command | `/checkpoint restore bug-bounty-support [id]` |

## Overview

This checkpoint management system governs the state of all support workflows defined across the 23 files in `bug-bounty-support/`. This domain provides the foundational support infrastructure for bug bounty hunting — reconnaissance frameworks, vulnerability detection patterns, exploitation techniques, reporting templates, and tool integrations. Checkpoints here capture which frameworks are loaded, their configuration state, and the cumulative knowledge gathered during support operations.

The checkpoint system ensures that when a session is interrupted, the next session can restore exactly which frameworks were active, what patterns were being used, and what support state was accumulated. This is particularly important for multi-session hunting where support state builds up over time.

## Auto-Checkpoint Configuration

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: framework_load
      description: "Checkpoint when a support framework is loaded or unloaded"
      events:
        - framework_loaded
        - framework_unloaded
        - framework_reconfigured
        - framework_updated
    - type: pattern_update
      description: "Checkpoint when detection patterns are updated"
      events:
        - new_pattern_added
        - pattern_refined
        - pattern_disabled
        - false_positive_pattern_updated
    - type: tool_integration
      description: "Checkpoint when tool integrations change"
      events:
        - tool_connected
        - tool_disconnected
        - tool_configured
        - tool_version_changed
    - type: knowledge_update
      description: "Checkpoint when support knowledge base is updated"
      events:
        - new_technique_added
        - technique_refined
        - best_practice_updated
        - lesson_learned_recorded
    - type: time_interval
      description: "Checkpoint every 10 minutes during active support operations"
      interval_minutes: 10
```

## Manual Checkpoint

```
manual_checkpoint:
  save_command: "/checkpoint save bug-bounty-support [label]"
  options:
    - include_loaded_frameworks: true
    - include_pattern_library: true
    - include_tool_configs: true
    - include_knowledge_base: true
    - minimal: "framework state only, skip patterns"
  special_commands:
    - "/support snapshot": "Capture full support state"
    - "/support inventory": "List all loaded frameworks and checkpoint"
    - "/support audit": "Audit framework usage and checkpoint"
```

## Checkpoint Format Schema

```
support_checkpoint:
  envelope:
    magic: "CHKP-SUPPORT-V1"
    version: "1.0"
    domain: "bug-bounty-support"
  sections:
    - section_id: "loaded_frameworks"
      description: "Currently loaded support frameworks"
      fields:
        - frameworks:
          - framework_id: "identifier"
            framework_name: "descriptive name"
            source_file: "relative path to framework file"
            loaded_at: "ISO-8601"
            version: "framework version"
            config_hash: "SHA-256 of configuration"
            status: "active | inactive | error"
            usage_count: "integer"
            last_used: "ISO-8601"
            performance_score: "float 0-10"
    - section_id: "vulnerability_patterns"
      description: "Detection patterns library"
      fields:
        - patterns:
          - pattern_id: "identifier"
            vuln_class: "vulnerability class"
            pattern_type: "regex | semantic | behavioral | heuristic"
            pattern_definition: "pattern string or rule"
            source_framework: "framework_id"
            true_positive_rate: "float"
            false_positive_rate: "float"
            last_updated: "ISO-8601"
            status: "active | disabled | deprecated"
        - pattern_statistics:
          total_patterns: "integer"
          active_patterns: "integer"
          average_accuracy: "float"
          coverage_percentage: "float"
    - section_id: "tool_state"
      description: "Integrated tool configurations"
      fields:
        - tools:
          - tool_id: "identifier"
            tool_name: "string"
            tool_type: "scanner | crawler | fuzzer | proxy | manual"
            version: "string"
            config: "tool-specific configuration"
            status: "ready | busy | error | offline"
            last_used: "ISO-8601"
            findings_generated: "integer"
    - section_id: "knowledge_base"
      description: "Accumulated support knowledge"
      fields:
        - techniques:
          - technique_id: "identifier"
            technique_name: "string"
            vulnerability_class: "string"
            complexity: "low | medium | high"
            success_rate: "float"
            source: "reference or experience"
            last_applied: "ISO-8601"
        - lessons_learned:
          - lesson_id: "identifier"
            lesson: "string"
            context: "when this lesson applies"
            recorded_at: "ISO-8601"
            application_count: "integer"
        - best_practices:
          - practice_id: "identifier"
            practice: "string"
            vulnerability_class: "string"
            effectiveness_score: "float"
    - section_id: "checksum"
      fields:
        - payload_hash: "SHA-256"
        - section_hashes: "per-section SHA-256"
```

## Validation

```
validation_rules:
  pre_checkpoint:
    - rule: "frameworks_consistent"
      description: "All loaded frameworks are accessible and consistent"
      action_on_fail: "revalidate_frameworks"
    - rule: "patterns_valid"
      description: "All patterns are syntactically valid"
      action_on_fail: "validate_patterns"
    - rule: "tools_connected"
      description: "All configured tools are reachable"
      action_on_fail: "reconnect_tools"
  post_restore:
    - rule: "frameworks_available"
      description: "All restored frameworks are available"
      action_on_fail: "reinstall_missing_frameworks"
    - rule: "patterns_compatible"
      description: "Restored patterns work with current target"
      action_on_fail: "adapt_patterns"
    - rule: "tool_versions_compatible"
      description: "Tool versions match expectations"
      action_on_fail: "update_tools"
```

## Pruning Strategy

```
pruning_strategy:
  retention_policy:
    max_checkpoints: 18
    ttl_hours: 60
    preserve_framework_loads: true
    preserve_knowledge_updates: true
    preserve_pattern_library: true
  pruning_priority:
    1: "time_interval_checkpoints — routine saves"
    2: "tool_integration_checkpoints — tool state changes"
    3: "pattern_update_checkpoints — pattern changes"
    4: "framework_load_checkpoints — framework state changes"
    5: "knowledge_update_checkpoints — learning events"
  special_rules:
    - "Always preserve pattern library state"
    - "Keep at least 2 framework load checkpoints"
    - "Archive knowledge base updates permanently"
```

## Checkpoint Index

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "bug-bounty-support"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "user label"
        loaded_frameworks: "integer"
        active_patterns: "integer"
        connected_tools: "integer"
        knowledge_items: "integer"
        file_path: "relative path"
        checksum: "SHA-256 prefix"
    framework_history:
      - framework_name: "string"
        first_loaded: "ISO-8601"
        last_used: "ISO-8601"
        total_loads: "integer"
        average_usage_duration: "duration"
```

## Restore from Checkpoint

```
restore_procedure:
  steps:
    1: "Load checkpoint index"
    2: "Select target checkpoint"
    3: "Validate framework availability"
    4: "Restore loaded frameworks state"
    5: "Restore pattern library"
    6: "Restore tool configurations"
    7: "Restore knowledge base"
    8: "Re-validate all components"
    9: "Resume support operations"
    10: "Log restoration event"
  restore_modes:
    - full: "Restore complete support state"
    - frameworks_only: "Restore framework states only"
    - patterns_only: "Restore pattern library only"
    - knowledge_only: "Restore knowledge base only"
```

## Domain File References

### Core Support (01-05)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `Advanced-Bug-Bounty-Prompt.md` | Stores advanced prompt templates, prompt state |
| 02 | `Advanced-Bug-Security-Hunting-Prompt.md` | Stores security hunting prompt configs, usage state |
| 03 | `Advanced-Information-Disclosure-Analysis-Prompt.md` | Stores info disclosure prompt configs, pattern state |
| 04 | `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` | Stores JS analysis prompt configs, detection state |
| 05 | `Advanced-Techniques.md` | Stores advanced technique library, application state |

### Tool and Method Support (06-10)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 06 | `Burp-AI.md` | Stores Burp Suite AI integration state, analysis results |
| 07 | `Chaining.md` | Stores chaining support configs, chain templates |
| 08 | `Core-Aspects-for-Bug-Security-Hunting.md` | Stores core hunting aspects, coverage checklist |
| 09 | `debuging-using-browser-console-and-vscode-for-hunting.md` | Stores debugging workflows, breakpoint state |
| 10 | `Ethical-Guidelines.md` | Stores ethical guideline state, compliance checks |

### Exploitation and Reporting (11-15)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 11 | `Exploitation.md` | Stores exploitation support configs, technique library |
| 12 | `JavaScript-Identification-Deobfuscation.md` | Stores JS identification rules, deobfuscation state |
| 13 | `manual-testing-scope.md` | Stores manual testing scope, test plan state |
| 14 | `parameters.md` | Stores parameter analysis configs, parameter library |
| 15 | `PoC-Development.md` | Stores PoC development templates, test case state |

### Recon and Detection (16-20)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 16 | `Reconnaissance.md` | Stores recon support configs, recon workflow state |
| 17 | `Reporting.md` | Stores reporting templates, report generation state |
| 18 | `Specific-Vulnerabilities-Hunting.md` | Stores vuln-specific hunting configs, hunting state |
| 19 | `static-and-dynamic-testing.md` | Stores static/dynamic testing configs, test state |
| 20 | `to-identify-injection-and-reflected-point-during-testing.md` | Stores injection identification rules, detection state |

### Detection and Integration (21-23)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 21 | `Tools-Integration.md` | Stores tool integration configs, connection state |
| 22 | `user-functionality.md` | Stores user functionality analysis, feature mapping |
| 23 | `Vulnerability-Detection.md` | Stores vulnerability detection configs, detection state |

## Framework Loading State Machine

```
framework_states:
  - UNLOADED: "Framework not loaded into session"
  - LOADING: "Framework being loaded"
  - LOADED: "Framework loaded and ready"
  - ACTIVE: "Framework actively being used"
  - IDLE: "Framework loaded but not currently in use"
  - ERROR: "Framework encountered an error"
  - UNLOADING: "Framework being unloaded"

state_transitions:
  UNLOADED -> LOADING: "load_request"
  LOADING -> LOADED: "load_complete"
  LOADING -> ERROR: "load_failed"
  LOADED -> ACTIVE: "usage_started"
  ACTIVE -> IDLE: "usage_paused"
  IDLE -> ACTIVE: "usage_resumed"
  IDLE -> UNLOADING: "unload_request"
  ACTIVE -> UNLOADING: "unload_request"
  LOADED -> UNLOADING: "unload_request"
  ERROR -> UNLOADING: "unload_request"
  UNLOADING -> UNLOADED: "unload_complete"
  ERROR -> LOADING: "retry_load"
```

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `bug-bounty-program-strategy` | Strategy data informs framework selection |
| `core-prompts-hunting` | Hunting prompts feed support framework usage |
| `core-prompts-learning` | Learning prompts enhance support knowledge |
| `report-writing-mastery` | Report templates inform reporting support |
| `advanced-automation` | Automation tools feed tool integration state |
