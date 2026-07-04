# CHECKPOINT MANAGEMENT — Specialized Targets

## Title

Checkpoint Management for Specialized Targets Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `specialized-targets` |
| Domain Path | `Specialized-Targets/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/specialized-targets/` |
| Session Scope | Category testing state, specialized vulnerability coverage |
| Auto-Checkpoint Interval | Every target category tested or 15 minutes |
| Manual Checkpoint Trigger | `/checkpoint save specialized-targets [label]` |
| Max Checkpoints Retained | 25 per session |
| Checkpoint TTL | 72 hours (configurable) |
| Restore Command | `/checkpoint restore specialized-targets [id]` |

## Overview

This checkpoint management system governs the state of all specialized target testing workflows defined across the 50 files in `Specialized-Targets/`. This domain covers unique and specialized attack surfaces — IoT devices, mobile applications, cloud infrastructure, containers, Kubernetes, blockchain, DeFi protocols, healthcare systems, financial institutions, government systems, and more. Checkpoints here capture category-specific testing progress, specialized vulnerability findings, and the unique tool configurations required for each target category.

Specialized targets require unique testing approaches, tools, and knowledge. The checkpoint system ensures that specialized testing state — including tool configurations, target-specific findings, and testing progress — is preserved across sessions. Each target category has distinct requirements, and the checkpoint system tracks these independently.

## Auto-Checkpoint Configuration

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: category_test_complete
      description: "Checkpoint when a target category test completes"
      events:
        - iot_device_test_complete
        - mobile_app_test_complete
        - cloud_infrastructure_test_complete
        - container_test_complete
        - kubernetes_test_complete
        - blockchain_smart_contract_test_complete
        - defi_protocol_test_complete
        - nft_marketplace_test_complete
        - web3_application_test_complete
        - crypto_exchange_test_complete
        - traditional_finance_test_complete
        - healthcare_system_test_complete
        - financial_institution_test_complete
        - government_system_test_complete
        - education_platform_test_complete
        - ecommerce_platform_test_complete
        - social_media_platform_test_complete
        - cms_test_complete
        - lms_test_complete
        - hr_system_test_complete
        - supply_chain_system_test_complete
        - manufacturing_ics_test_complete
        - smart_building_test_complete
        - connected_vehicle_test_complete
        - autonomous_system_test_complete
        - ics_test_complete
        - medical_device_test_complete
        - wearable_tech_test_complete
        - smart_home_test_complete
        - embedded_system_test_complete
        - rtos_test_complete
        - firmware_test_complete
        - network_device_test_complete
        - telecom_system_test_complete
        - satellite_comm_test_complete
        - air_traffic_control_test_complete
        - power_grid_test_complete
        - water_treatment_test_complete
        - transportation_test_complete
        - energy_management_test_complete
        - research_institution_test_complete
        - nonprofit_test_complete
        - startup_test_complete
        - enterprise_corporate_test_complete
        - fortune_500_test_complete
        - open_source_project_test_complete
        - academic_research_test_complete
        - international_org_test_complete
        - developing_country_infra_test_complete
        - global_scale_system_test_complete
    - type: specialized_finding
      description: "Checkpoint when a specialized finding is discovered"
      events:
        - iot_finding
        - mobile_finding
        - cloud_finding
        - container_finding
        - kubernetes_finding
        - blockchain_finding
        - defi_finding
        - healthcare_finding
        - financial_finding
        - government_finding
        - ics_finding
        - firmware_finding
    - type: category_tool_configured
      description: "Checkpoint when specialized tools are configured"
      events:
        - specialized_tool_installed
        - specialized_tool_configured
        - specialized_tool_used
    - type: time_interval
      description: "Checkpoint every 15 minutes during active testing"
      interval_minutes: 15
```

### Checkpoint Storage Configuration

```
checkpoint_storage:
  base_path: "Brain/session-managements/checkpoint/specialized-targets/"
  naming_convention: "specialized-{category}-{timestamp}.cp"
  compression: enabled
  encryption: optional
  max_size_mb: 40
  cleanup_policy: "rotate_oldest"
  retention_count: 25
  ttl_hours: 72
  backup_to_memory: true
  per_category_subdirs: true
```

## Manual Checkpoint

```
manual_checkpoint:
  save_command: "/checkpoint save specialized-targets [label]"
  options:
    - include_test_progress: true
    - include_category_findings: true
    - include_tool_configs: true
    - include_target_inventory: true
    - minimal: "progress only, skip detailed findings"
  special_commands:
    - "/specialized snapshot": "Capture full specialized testing state"
    - "/specialized progress": "Generate progress report and checkpoint"
    - "/specialized findings": "Export findings summary and checkpoint"
    - "/specialized resume [category]": "Restore and resume specific category"
    - "/specialized tools": "Show specialized tool status and checkpoint"
    - "/specialized inventory": "Export target inventory and checkpoint"
```

## Checkpoint Format Schema

```
specialized_checkpoint:
  envelope:
    magic: "CHKP-SPECIALIZED-V1"
    version: "1.0"
    domain: "specialized-targets"
    encoding: "UTF-8"
    compression: "gzip"
  sections:
    - section_id: "category_progress"
      description: "Testing progress across all target categories"
      fields:
        - total_categories: "integer"
        - tested_categories: "integer"
        - in_progress_category: "current category or null"
        - overall_progress: "float 0-100"
        - categories:
          - category_id: "identifier"
            category_name: "target category name"
            source_file: "relative path"
            status: "not_tested | in_progress | completed | skipped"
            started_at: "ISO-8601 or null"
            completed_at: "ISO-8601 or null"
            findings_count: "integer"
            tests_performed: "integer"
            coverage_score: "float 0-100"
            tools_used: "list of specialized tools"
            unique_challenges: "list of category-specific challenges"
            notes: "testing notes"
    - section_id: "category_findings"
      description: "Findings organized by target category"
      fields:
        - findings_by_category:
          - category_name: "string"
            findings:
              - finding_id: "identifier"
                title: "finding title"
                severity: "critical | high | medium | low | informational"
                confidence: "confirmed | probable | possible"
                target: "affected component"
                category_specific_context: "context unique to this category"
                description: "detailed description"
                evidence: "supporting evidence references"
                remediation: "category-specific remediation"
                created_at: "ISO-8601"
                status: "new | validated | submitted | rejected"
        - findings_summary:
          total_findings: "integer"
          by_category:
            - category_name: "string"
              finding_count: "integer"
              average_severity: "float"
          by_severity:
            critical: "integer"
            high: "integer"
            medium: "integer"
            low: "integer"
            informational: "integer"
    - section_id: "tool_configurations"
      description: "Specialized tool configurations by category"
      fields:
        - tool_configs:
          - category: "target category"
            tools:
              - tool_name: "string"
                tool_version: "string"
                configuration: "tool-specific config"
                status: "ready | configured | error"
                last_used: "ISO-8601"
                specialized_for: "what this tool is specialized for"
                config_hash: "SHA-256 of configuration"
    - section_id: "target_inventory"
      description: "Inventory of specialized targets tested"
      fields:
        - targets:
          - target_id: "identifier"
            target_name: "string"
            category: "target category"
            target_type: "specific type within category"
            ip_address: "IP if applicable"
            url: "URL if applicable"
            technologies: "list of technologies"
            first_tested: "ISO-8601"
            last_tested: "ISO-8601"
            findings_count: "integer"
            risk_level: "low | medium | high | critical"
            status: "active | archived"
    - section_id: "checksum"
      fields:
        - payload_hash: "SHA-256"
        - section_hashes: "per-section SHA-256"
        - verified_at: "ISO-8601"
```

## Validation

```
validation_rules:
  pre_checkpoint:
    - rule: "category_progress_coherent"
      description: "Category progress states are consistent"
      action_on_fail: "reconcile_progress"
    - rule: "findings_linked_to_categories"
      description: "All findings are linked to a valid category"
      action_on_fail: "link_orphaned_findings"
    - rule: "tool_configs_valid"
      description: "All tool configurations are valid"
      action_on_fail: "validate_tool_configs"
    - rule: "target_inventory_current"
      description: "Target inventory is up-to-date"
      action_on_fail: "refresh_target_inventory"
    - rule: "checksum_valid"
      description: "Checkpoint file integrity is verified"
      action_on_fail: "recompute_checksum"
    - rule: "severity_justified"
      description: "Severity ratings match impact descriptions"
      action_on_fail: "reassess_severity"
  post_restore:
    - rule: "targets_accessible"
      description: "Specialized targets are still accessible"
      action_on_fail: "reverify_targets"
    - rule: "tools_available"
      description: "Specialized tools are available"
      action_on_fail: "reinstall_tools"
    - rule: "category_scope_valid"
      description: "Target categories are still in scope"
      action_on_fail: "refresh_scope"
    - rule: "findings_still_relevant"
      description: "Previously found findings are still relevant"
      action_on_fail: "revalidate_findings"
    - rule: "dependencies_met"
      description: "All testing dependencies are met"
      action_on_fail: "restore_dependencies"
```

## Pruning Strategy

```
pruning_strategy:
  retention_policy:
    max_checkpoints: 25
    ttl_hours: 72
    preserve_findings: true
    preserve_tool_configs: true
    preserve_target_inventory: true
  pruning_priority:
    1: "time_interval_checkpoints — routine saves, prune first"
    2: "category_tool_configured_checkpoints — tool changes"
    3: "specialized_finding_checkpoints — finding records"
    4: "category_test_complete_checkpoints — completion records"
  special_rules:
    - "Never prune findings checkpoints"
    - "Always preserve tool configurations for active categories"
    - "Keep target inventory for full TTL period"
    - "Archive completed category checkpoints after TTL"
    - "Preserve at least 3 checkpoints per active category"
    - "Keep checkpoints containing critical findings indefinitely"
  cleanup_schedule:
    - cron: "0 */8 * * *"
      description: "Run pruning every 8 hours"
      checks:
        - expired_checkpoints
        - over_limit_checkpoints
        - orphaned_findings
    - on_event: "session_start"
      description: "Prune at session start"
      checks:
        - corrupted_checkpoints
        - stale_tool_configs
```

## Checkpoint Index

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "specialized-targets"
    total_checkpoints: "integer"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "user label"
        type: "auto | manual"
        trigger: "trigger description"
        categories_tested: "integer / total"
        total_findings: "integer"
        overall_progress: "float"
        size_bytes: "integer"
        file_path: "relative path"
        checksum: "SHA-256 prefix"
        status: "valid | corrupt | archived"
    category_history:
      - category_name: "string"
        first_tested: "ISO-8601"
        last_tested: "ISO-8601"
        total_findings: "integer"
        status: "string"
        checkpoint_ids: "list of checkpoint references"
    findings_index:
      - finding_id: "string"
        category: "string"
        severity: "string"
        status: "string"
        checkpoint_id: "reference"
    metadata:
      first_checkpoint: "ISO-8601"
      last_checkpoint: "ISO-8601"
      most_recent_valid: "checkpoint_id"
      total_size_bytes: "integer"
      pruning_last_run: "ISO-8601"
```

## Restore from Checkpoint

```
restore_procedure:
  steps:
    1: "Load checkpoint index"
    2: "Identify target checkpoint by id or category"
    3: "Run pre-restore validation"
    4: "Deserialize checkpoint payload"
    5: "Restore category test progress"
    6: "Restore findings data"
    7: "Restore tool configurations"
    8: "Restore target inventory"
    9: "Re-validate specialized tools"
    10: "Re-verify target accessibility"
    11: "Resume category testing from checkpoint"
    12: "Log restoration event in index"
  restore_options:
    - full: "Restore complete specialized testing state"
    - progress_only: "Restore test progress, skip findings"
    - findings_only: "Restore findings for reporting"
    - tools_only: "Restore tool configurations"
    - from_category: "Restore and resume from specific category"
    - dry_run: "Validate restore without actually restoring"
  resume_strategies:
    - from_current_phase: "Resume from exact checkpoint position"
    - from_last_success: "Resume from last completed phase"
    - from_category_start: "Restart specific category from beginning"
    - full_replay: "Re-execute all tests from beginning"
```

## Domain File References

### IoT and Embedded (01-10)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `01-IoT-Device-Security.md` | Stores IoT device test state, firmware analysis, device findings |
| 02 | `02-Mobile-Application-Testing.md` | Stores mobile app test state, APK analysis, app findings |
| 03 | `03-Cloud-Infrastructure-Security.md` | Stores cloud infra test state, IAM analysis, cloud findings |
| 04 | `04-Container-Security.md` | Stores container test state, image analysis, container findings |
| 05 | `05-Kubernetes-Cluster-Security.md` | Stores K8s test state, cluster analysis, K8s findings |
| 06 | `06-Blockchain-Smart-Contracts.md` | Stores blockchain test state, contract audit, blockchain findings |
| 07 | `07-DeFi-Protocol-Security.md` | Stores DeFi test state, protocol analysis, DeFi findings |
| 08 | `08-NFT-Marketplace-Security.md` | Stores NFT marketplace test state, marketplace findings |
| 09 | `09-Web3-Application-Security.md` | Stores Web3 app test state, dApp analysis, Web3 findings |
| 10 | `10-Cryptocurrency-Exchange-Security.md` | Stores crypto exchange test state, exchange findings |

### Financial and Healthcare (11-20)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 11 | `11-Traditional-Finance-API-Security.md` | Stores finance API test state, API analysis, finance findings |
| 12 | `12-Healthcare-System-Security.md` | Stores healthcare test state, HIPAA analysis, healthcare findings |
| 13 | `13-Financial-Institution-Security.md` | Stores financial institution test state, PCI analysis, findings |
| 14 | `14-Government-System-Security.md` | Stores government system test state, compliance analysis, findings |
| 15 | `15-Education-Platform-Security.md` | Stores education platform test state, FERPA analysis, findings |
| 16 | `16-E-commerce-Platform-Security.md` | Stores ecommerce test state, payment analysis, ecommerce findings |
| 17 | `17-Social-Media-Platform-Security.md` | Stores social media test state, privacy analysis, social findings |
| 18 | `18-Content-Management-System-Security.md` | Stores CMS test state, plugin analysis, CMS findings |
| 19 | `19-Learning-Management-System-Security.md` | Stores LMS test state, SCORM analysis, LMS findings |
| 20 | `20-Human-Resources-System-Security.md` | Stores HR system test state, PII analysis, HR findings |

### Industrial and Infrastructure (21-30)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 21 | `21-Supply-Chain-Management-Security.md` | Stores supply chain test state, logistics analysis, findings |
| 22 | `22-Manufacturing-Control-System-Security.md` | Stores manufacturing test state, SCADA analysis, findings |
| 23 | `23-Smart-Building-Automation.md` | Stores smart building test state, BMS analysis, building findings |
| 24 | `24-Connected-Vehicle-Security.md` | Stores connected vehicle test state, CAN bus analysis, findings |
| 25 | `25-Autonomous-System-Security.md` | Stores autonomous system test state, sensor analysis, findings |
| 26 | `26-Industrial-Control-System-Security.md` | Stores ICS test state, PLC analysis, ICS findings |
| 27 | `27-Medical-Device-Security.md` | Stores medical device test state, FDA analysis, device findings |
| 28 | `28-Wearable-Technology-Security.md` | Stores wearable tech test state, BLE analysis, wearable findings |
| 29 | `29-Smart-Home-Device-Security.md` | Stores smart home test state, Zigbee analysis, smart home findings |
| 30 | `30-Embedded-System-Security.md` | Stores embedded system test state, JTAG analysis, embedded findings |

### Critical Infrastructure (31-40)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 31 | `31-Real-Time-Operating-System-Security.md` | Stores RTOS test state, kernel analysis, RTOS findings |
| 32 | `32-Firmware-Security-Analysis.md` | Stores firmware analysis state, binary analysis, firmware findings |
| 33 | `33-Network-Device-Security.md` | Stores network device test state, SNMP analysis, device findings |
| 34 | `34-Telecommunication-System-Security.md` | Stores telecom test state, SS7 analysis, telecom findings |
| 35 | `35-Satellite-Communication-Security.md` | Stores satellite comm test state, DVB analysis, satellite findings |
| 36 | `36-Air-Traffic-Control-System-Security.md` | Stores ATC test state, ADS-B analysis, ATC findings |
| 37 | `37-Power-Grid-Security.md` | Stores power grid test state, IEC-61850 analysis, grid findings |
| 38 | `38-Water-Treatment-Facility-Security.md` | Stores water treatment test state, SCADA analysis, findings |
| 39 | `39-Transportation-System-Security.md` | Stores transportation test state, V2X analysis, transport findings |
| 40 | `40-Energy-Management-System-Security.md` | Stores energy management test state, BMS analysis, energy findings |

### Organizational (41-50)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 41 | `41-Research-Institution-Security.md` | Stores research institution test state, data analysis, findings |
| 42 | `42-Non-Profit-Organization-Security.md` | Stores nonprofit test state, donation analysis, nonprofit findings |
| 43 | `43-Startup-Company-Security.md` | Stores startup test state, MVP analysis, startup findings |
| 44 | `44-Enterprise-Corporate-Security.md` | Stores enterprise test state, AD analysis, enterprise findings |
| 45 | `45-Fortune-500-Company-Security.md` | Stores Fortune 500 test state, compliance analysis, findings |
| 46 | `46-Open-Source-Project-Security.md` | Stores open source test state, dependency analysis, OSS findings |
| 47 | `47-Academic-Research-Security.md` | Stores academic research test state, IRB analysis, findings |
| 48 | `48-International-Organization-Security.md` | Stores international org test state, diplomacy analysis, findings |
| 49 | `49-Developing-Country-Infrastructure.md` | Stores developing country test state, infra analysis, findings |
| 50 | `50-Global-Scale-System-Security.md` | Stores global system test state, distributed analysis, findings |

## Specialized Target State Machine

```
specialized_states:
  - UNTESTED: "Category not yet tested"
  - RECONNAISSANCE: "Gathering category-specific recon"
  - CONFIGURING: "Setting up specialized tools"
  - TESTING: "Actively testing for category-specific vulnerabilities"
  - ANALYZING: "Analyzing category-specific results"
  - REPORTING: "Generating category-specific reports"
  - COMPLETE: "Category testing complete"

state_transitions:
  UNTESTED -> RECONNAISSANCE: "category_selected"
  RECONNAISSANCE -> CONFIGURING: "recon_complete"
  CONFIGURING -> TESTING: "tools_configured"
  TESTING -> ANALYZING: "tests_complete"
  ANALYZING -> REPORTING: "analysis_complete"
  REPORTING -> COMPLETE: "reports_generated"
  REPORTING -> TESTING: "additional_testing_needed"
  ANY -> UNTESTED: "category_reset"
```

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `advanced-automation` | Automation feeds specialized testing execution |
| `reconnaissance-deep-dive` | Recon identifies specialized targets |
| `core-prompts-hunting` | Hunting techniques inform specialized testing |
| `advanced-chaining-techniques` | Chain techniques apply to specialized targets |
| `report-writing-mastery` | Specialized findings feed report generation |

## Recovery Scenarios

### Scenario 1: Specialized Tool Crash

```
recovery_scenario: tool_crash
  detected_by: "exit_code != 0 or signal_received"
  checkpoint_behavior:
    pre_crash: "save tool state immediately"
    post_crash: "log crash details, mark tool as failed"
  restore_behavior:
    skip_failed_tool: false
    retry_failed_tool: true
    max_retries: 3
    fallback_tool: "use alternative tool if available"
```

### Scenario 2: Target Becomes Unreachable

```
recovery_scenario: target_unreachable
  detected_by: "connection_timeout or host_unreachable"
  checkpoint_behavior:
    pre_timeout: "save all in-flight test state"
    mark_target: "target_unreachable"
  restore_behavior:
    retry_target: true
    wait_period: "configurable cooldown"
    skip_if_permanently_down: true
```

### Scenario 3: Category Scope Change

```
recovery_scenario: scope_change
  detected_by: "scope_update_detected or new_rules_published"
  checkpoint_behavior:
    save_current_state: true
    mark_scope_changed: true
    record_change_details: "what changed"
  restore_behavior:
    revalidate_scope: true
    discard_out_of_scope_findings: true
    resume_within_new_scope: true
```

### Scenario 4: Resource Exhaustion

```
recovery_scenario: resource_exhaustion
  detected_by: "memory_threshold or disk_threshold or cpu_threshold"
  checkpoint_behavior:
    emergency_checkpoint: true
    save_minimal_state: true
    release_resources: true
  restore_behavior:
    check_resources: true
    load_minimal_state: true
    resume_when_resources_available: true
```
