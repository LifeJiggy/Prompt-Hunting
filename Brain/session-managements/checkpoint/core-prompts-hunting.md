# CHECKPOINT MANAGEMENT — Core Prompts Hunting

## Title

Checkpoint Management for Core Prompts Hunting Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `core-prompts-hunting` |
| Domain Path | `Core-Prompts-hunting/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/core-prompts-hunting/` |
| Session Scope | Hunting test progress, vulnerability class coverage, prompt state |
| Auto-Checkpoint Interval | Every vulnerability class tested or 15 minutes |
| Manual Checkpoint Trigger | `/checkpoint save core-prompts-hunting [label]` |
| Max Checkpoints Retained | 25 per session |
| Checkpoint TTL | 72 hours (configurable) |
| Restore Command | `/checkpoint restore core-prompts-hunting [id]` |

## Overview

This checkpoint management system governs the state of all hunting workflows defined across the 50 files in `Core-Prompts-hunting/`. This domain encompasses the core vulnerability hunting prompts and techniques — from reconnaissance through reporting. Checkpoints here capture hunting test progress, which vulnerability classes have been tested, what results were found, prompt configurations, and the overall test coverage state.

The checkpoint system ensures that multi-class vulnerability testing can be interrupted and resumed without losing test progress. Each vulnerability class test is tracked independently, allowing partial progress preservation when sessions are interrupted between vulnerability class tests.

## Auto-Checkpoint Configuration

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: vulnerability_class_complete
      description: "Checkpoint when a vulnerability class test completes"
      events:
        - recon_test_complete
        - js_analysis_test_complete
        - api_analysis_test_complete
        - auth_test_complete
        - authz_test_complete
        - input_validation_test_complete
        - business_logic_test_complete
        - client_storage_test_complete
        - crypto_test_complete
        - error_handling_test_complete
        - file_upload_test_complete
        - ssrf_test_complete
        - csrf_test_complete
        - cors_test_complete
        - race_condition_test_complete
        - third_party_test_complete
        - config_misconfig_test_complete
        - network_infra_test_complete
        - mobile_api_test_complete
        - reporting_test_complete
    - type: finding_discovered
      description: "Checkpoint when a new finding is identified"
      events:
        - new_vulnerability_found
        - false_positive_confirmed
        - finding_validated
        - finding_rejected
    - type: prompt_state_change
      description: "Checkpoint when hunting prompt state changes"
      events:
        - prompt_loaded
        - prompt_modified
        - prompt_reconfigured
        - prompt_version_changed
    - type: time_interval
      description: "Checkpoint every 15 minutes during active hunting"
      interval_minutes: 15
```

## Manual Checkpoint

```
manual_checkpoint:
  save_command: "/checkpoint save core-prompts-hunting [label]"
  options:
    - include_test_progress: true
    - include_findings: true
    - include_prompt_state: true
    - include_coverage_map: true
    - minimal: "progress only, skip findings"
  special_commands:
    - "/hunting snapshot": "Capture full hunting state"
    - "/hunting coverage": "Generate coverage report and checkpoint"
    - "/hunting findings": "Checkpoint findings summary"
    - "/hunting resume [class]": "Restore and resume specific vulnerability class"
```

## Checkpoint Format Schema

```
hunting_checkpoint:
  envelope:
    magic: "CHKP-HUNTING-V1"
    version: "1.0"
    domain: "core-prompts-hunting"
  sections:
    - section_id: "test_progress"
      description: "Vulnerability class testing progress"
      fields:
        - total_classes: "integer"
        - completed_classes: "integer"
        - in_progress_class: "current class being tested or null"
        - classes:
          - class_id: "identifier"
            class_name: "vulnerability class name"
            source_file: "relative path to prompt file"
            status: "pending | in_progress | completed | skipped"
            started_at: "ISO-8601 or null"
            completed_at: "ISO-8601 or null"
            findings_count: "integer"
            tests_performed: "integer"
            coverage_score: "float 0-100"
            notes: "testing notes"
    - section_id: "findings"
      description: "All discovered findings"
      fields:
        - findings:
          - finding_id: "identifier"
            vuln_class: "vulnerability class"
            title: "finding title"
            severity: "critical | high | medium | low | informational"
            confidence: "confirmed | probable | possible"
            target: "affected endpoint or component"
            description: "detailed description"
            evidence: "supporting evidence references"
            created_at: "ISO-8601"
            status: "new | validated | submitted | rejected"
        - findings_summary:
          total: "integer"
          by_severity:
            critical: "integer"
            high: "integer"
            medium: "integer"
            low: "integer"
            informational: "integer"
          by_status:
            new: "integer"
            validated: "integer"
            submitted: "integer"
            rejected: "integer"
    - section_id: "prompt_state"
      description: "Hunting prompt configurations"
      fields:
        - active_prompts:
          - prompt_id: "identifier"
            prompt_file: "relative path"
            version: "string"
            loaded_at: "ISO-8601"
            usage_count: "integer"
            last_used: "ISO-8601"
            effectiveness_score: "float"
        - prompt_parameters:
          - parameter_name: "string"
            current_value: "value"
            default_value: "value"
            description: "parameter description"
    - section_id: "coverage_map"
      description: "Overall vulnerability class coverage"
      fields:
        - overall_coverage: "float 0-100"
        - class_coverage:
          - class_name: "string"
            coverage: "float 0-100"
            tests_performed: "integer"
            findings_per_test: "float"
            last_tested: "ISO-8601"
        - coverage_gaps:
          - class_name: "string"
            reason: "why coverage is low"
            recommendation: "how to improve"
    - section_id: "checksum"
      fields:
        - payload_hash: "SHA-256"
        - section_hashes: "per-section SHA-256"
```

## Validation

```
validation_rules:
  pre_checkpoint:
    - rule: "test_progress_coherent"
      description: "Test progress states are internally consistent"
      action_on_fail: "reconcile_progress"
    - rule: "findings_linked_to_classes"
      description: "All findings are linked to a vulnerability class"
      action_on_fail: "link_orphaned_findings"
    - rule: "coverage_calculable"
      description: "Coverage scores can be calculated from test data"
      action_on_fail: "recalculate_coverage"
    - rule: "prompt_versions_valid"
      description: "All prompt versions are available"
      action_on_fail: "revalidate_prompts"
  post_restore:
    - rule: "target_still_in_scope"
      description: "Hunting targets are still in scope"
      action_on_fail: "refresh_target_scope"
    - rule: "findings_still_relevant"
      description: "Previously found findings are still relevant"
      action_on_fail: "revalidate_findings"
    - rule: "test_coverage_accurate"
      description: "Restored coverage map reflects current state"
      action_on_fail: "recalculate_coverage"
```

## Pruning Strategy

```
pruning_strategy:
  retention_policy:
    max_checkpoints: 25
    ttl_hours: 72
    preserve_findings: true
    preserve_coverage_maps: true
    preserve_test_results: true
  pruning_priority:
    1: "time_interval_checkpoints — routine saves"
    2: "prompt_state_change_checkpoints — config changes"
    3: "finding_discovered_checkpoints — discovery markers"
    4: "vulnerability_class_complete_checkpoints — class completion records"
  special_rules:
    - "Never prune checkpoints containing new findings"
    - "Always preserve coverage map history"
    - "Archive completed vulnerability class checkpoints after TTL"
```

## Checkpoint Index

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "core-prompts-hunting"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "user label"
        classes_completed: "integer / total"
        findings_count: "integer"
        overall_coverage: "float"
        file_path: "relative path"
        checksum: "SHA-256 prefix"
    findings_index:
      - finding_id: "string"
        vuln_class: "string"
        severity: "string"
        status: "string"
        checkpoint_id: "reference"
    coverage_history:
      - date: "ISO-8601"
        coverage: "float"
        classes_completed: "integer"
        checkpoint_id: "reference"
```

## Restore from Checkpoint

```
restore_procedure:
  steps:
    1: "Load checkpoint index"
    2: "Select target checkpoint"
    3: "Validate test progress state"
    4: "Restore vulnerability class test progress"
    5: "Restore findings data"
    6: "Restore prompt configurations"
    7: "Restore coverage map"
    8: "Re-validate target scope"
    9: "Resume hunting from checkpoint"
    10: "Log restoration event"
  restore_modes:
    - full: "Restore complete hunting state"
    - progress_only: "Restore test progress, skip findings"
    - findings_only: "Restore findings for report generation"
    - from_class: "Restore and resume from specific vulnerability class"
```

## Domain File References

### Reconnaissance and Analysis (01-05)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery.md` | Stores recon test progress, discovered assets |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation.md` | Stores JS analysis state, deobfuscation results |
| 03 | `3-API-Endpoint-Analysis.md` | Stores API analysis progress, endpoint mapping |
| 04 | `4-Authentication-and-Session-Management.md` | Stores auth testing state, session analysis |
| 05 | `5-Authorization-and-Access-Control.md` | Stores authz testing state, access control mapping |

### Core Vulnerability Classes (06-15)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 06 | `6-Input-Validation-and-Sanitization.md` | Stores input validation test state, injection points |
| 07 | `7-Business-Logic-Flaws.md` | Stores business logic test state, logic flaw findings |
| 08 | `8-Client-Side-Storage-Security.md` | Stores client storage test state, storage analysis |
| 09 | `9-Cryptography-and-Data-Protection.md` | Stores crypto test state, weakness findings |
| 10 | `10-Error-Handling-and-Information-Disclosure.md` | Stores error handling test state, disclosure findings |
| 11 | `11-File-Upload-and-Processing.md` | Stores file upload test state, upload vulnerability findings |
| 12 | `12-Server-Side-Request-Forgery-SSRF.md` | Stores SSRF test state, internal network findings |
| 13 | `13-Cross-Site-Request-Forgery-CSRF.md` | Stores CSRF test state, token analysis |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS.md` | Stores CORS test state, origin analysis |
| 15 | `15-Race-Conditions-and-Concurrency-Issues.md` | Stores race condition test state, timing analysis |

### Advanced Classes (16-25)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 16 | `16-Third-Party-Component-Analysis.md` | Stores component analysis state, dependency mapping |
| 17 | `17-Configuration-and-Misconfiguration-Hunting.md` | Stores config hunting state, misconfig findings |
| 18 | `18-Network-and-Infrastructure-Security.md` | Stores network test state, infrastructure findings |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities.md` | Stores mobile/API test state, platform findings |
| 20 | `20-Reporting-and-Proof-of-Concept-Development.md` | Stores report generation state, PoC development |
| 21 | `21-Web-Application-Firewall-WAF-Bypass.md` | Stores WAF bypass test state, bypass technique results |
| 22 | `22-HTTP-Request-Smuggling.md` | Stores smuggling test state, request queue analysis |
| 23 | `23-Subdomain-Takeover.md` | Stores subdomain takeover state, DNS analysis |
| 24 | `24-Host-Header-Injection.md` | Stores host header test state, injection results |
| 25 | `25-XML-External-Entity-XXE-Injection.md` | Stores XXE test state, entity injection results |

### Specialized Classes (26-35)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 26 | `26-Insecure-Deserialization.md` | Stores deserialization test state, gadget chain mapping |
| 27 | `27-Command-Injection.md` | Stores command injection test state, payload results |
| 28 | `28-NoSQL-Injection.md` | Stores NoSQL injection test state, query manipulation |
| 29 | `29-GraphQL-Vulnerabilities.md` | Stores GraphQL test state, schema analysis |
| 30 | `30-WebSocket-Security.md` | Stores WebSocket test state, protocol analysis |
| 31 | `31-Server-Side-Template-Injection.md` | Stores SSTI test state, template analysis |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | Stores JWT test state, algorithm analysis |
| 33 | `33-Content-Security-Policy-CSP-Bypass.md` | Stores CSP test state, bypass technique results |
| 34 | `34-Clickjacking-and-UI-Redressing.md` | Stores clickjacking test state, UI analysis |
| 35 | `35-HTTP-Parameter-Pollution.md` | Stores HPP test state, parameter analysis |

### Advanced Specialized (36-45)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 36 | `36-LDAP-Injection.md` | Stores LDAP injection test state, directory analysis |
| 37 | `37-Session-Puzzling-and-Fixation.md` | Stores session puzzling state, session analysis |
| 38 | `38-Insecure-File-Handling.md` | Stores file handling test state, path analysis |
| 39 | `39-Cross-Site-Script-Inclusion-XSSI.md` | Stores XSSI test state, script inclusion analysis |
| 40 | `40-Prototype-Pollution.md` | Stores prototype pollution test state, sink analysis |
| 41 | `41-HTTP-Response-Splitting.md` | Stores response splitting test state, header analysis |
| 42 | `42-XPath-Injection.md` | Stores XPath injection test state, XML analysis |
| 43 | `43-Cross-Site-Request-Forgery-CSRF.md` | Stores CSRF analysis state, token testing |
| 44 | `44-Cross-Origin-Resource-Sharing-CORS.md` | Stores CORS analysis state, origin testing |
| 45 | `45-Race-Conditions-and-Concurrency-Issues.md` | Stores race condition analysis, timing testing |

### Reporting and Integration (46-50)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 46 | `46-Third-Party-Component-Analysis.md` | Stores third-party analysis state, dependency tracking |
| 47 | `47-Configuration-and-Misconfiguration-Hunting.md` | Stores config hunting state, misconfiguration tracking |
| 48 | `48-Network-and-Infrastructure-Security.md` | Stores network security state, infra analysis |
| 49 | `49-Mobile-and-API-Specific-Vulnerabilities.md` | Stores mobile/API test state, platform analysis |
| 50 | `50-Reporting-and-Proof-of-Concept-Development.md` | Stores reporting state, PoC development progress |

## Hunting Coverage State Machine

```
hunting_states:
  - NOT_STARTED: "No testing initiated"
  - RECONNAISSANCE: "Reconnaissance and asset discovery phase"
  - ANALYSIS: "Analyzing targets and endpoints"
  - TESTING: "Actively testing vulnerability classes"
  - VALIDATION: "Validating discovered findings"
  - REPORTING: "Generating reports for valid findings"
  - COMPLETE: "All planned testing completed"

state_transitions:
  NOT_STARTED -> RECONNAISSANCE: "hunting_initiated"
  RECONNAISSANCE -> ANALYSIS: "assets_discovered"
  ANALYSIS -> TESTING: "analysis_complete"
  TESTING -> TESTING: "next_vulnerability_class"
  TESTING -> VALIDATION: "findings_to_validate"
  VALIDATION -> TESTING: "validation_complete_more_testing"
  VALIDATION -> REPORTING: "all_findings_validated"
  REPORTING -> COMPLETE: "reports_submitted"
  REPORTING -> TESTING: "additional_testing_needed"
```

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `core-prompts-learning` | Learning prompts enhance hunting techniques |
| `advanced-automation` | Automation feeds test execution |
| `reconnaissance-deep-dive` | Recon results feed hunting targets |
| `real-world-case-studies` | Case studies inform hunting strategy |
| `report-writing-mastery` | Findings feed report generation |
