# CHECKPOINT MANAGEMENT — Reconnaissance Deep Dive

## Title

Checkpoint Management for Reconnaissance Deep Dive Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `reconnaissance-deep-dive` |
| Domain Path | `Reconnaissance-Deep-Dive/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/reconnaissance-deep-dive/` |
| Session Scope | Discovered assets, recon pipeline state, intelligence gathering |
| Auto-Checkpoint Interval | Every recon phase completion or 10 minutes |
| Manual Checkpoint Trigger | `/checkpoint save reconnaissance-deep-dive [label]` |
| Max Checkpoints Retained | 30 per session |
| Checkpoint TTL | 72 hours (configurable) |
| Restore Command | `/checkpoint restore reconnaissance-deep-dive [id]` |

## Overview

This checkpoint management system governs the state of all reconnaissance workflows defined across the 50 files in `Reconnaissance-Deep-Dive/`. Reconnaissance is the foundation of bug bounty hunting — discovering subdomains, identifying technologies, mapping attack surfaces, and gathering intelligence. Checkpoints here capture the complete reconnaissance state: discovered assets, technology fingerprints, API endpoints, configuration findings, and the overall attack surface map.

Reconnaissance is typically the most time-consuming phase of bug bounty hunting, often spanning hours or days. The checkpoint system ensures that recon progress is preserved and can be resumed without re-executing time-consuming enumeration and discovery operations. This is critical because many recon tools have rate limits and re-executing them wastes both time and quota.

## Auto-Checkpoint Configuration

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: recon_phase_complete
      description: "Checkpoint when a reconnaissance phase completes"
      events:
        - subdomain_enumeration_complete
        - passive_osint_complete
        - active_asset_discovery_complete
        - tech_fingerprinting_complete
        - cloud_resource_enum_complete
        - api_endpoint_discovery_complete
        - js_source_analysis_complete
        - config_file_extraction_complete
        - version_detection_complete
        - content_discovery_complete
        - directory_brute_force_complete
        - file_type_detection_complete
        - backup_file_discovery_complete
        - source_code_leak_complete
        - git_repo_analysis_complete
        - dns_enum_complete
        - cert_transparency_complete
        - historical_data_complete
        - social_media_osint_complete
        - employee_asset_complete
        - third_party_integration_complete
        - web_archive_complete
        - pastebin_leak_complete
        - code_repo_mining_complete
        - container_registry_complete
        - iot_device_discovery_complete
        - mobile_app_analysis_complete
        - api_doc_extraction_complete
        - websocket_endpoint_complete
        - graphql_introspection_complete
        - xml_rpc_soap_complete
        - email_harvesting_complete
        - phone_enum_complete
        - physical_location_complete
        - supply_chain_mapping_complete
        - competitor_analysis_complete
        - partner_network_complete
        - acquisition_analysis_complete
        - subsidiary_mapping_complete
        - regional_infra_complete
        - cms_detection_complete
        - framework_library_id_complete
        - server_config_analysis_complete
        - ssl_tls_analysis_complete
        - http_header_intelligence_complete
        - cookie_analysis_complete
        - error_page_analysis_complete
        - debug_endpoint_complete
        - staging_env_detection_complete
        - advanced_recon_strategy_complete
    - type: new_asset_discovered
      description: "Checkpoint when a new asset is discovered"
      events:
        - new_subdomain_found
        - new_api_endpoint_found
        - new_technology_identified
        - new_configuration_found
        - new_leak_detected
    - type: recon_milestone
      description: "Checkpoint at recon milestones"
      events:
        - asset_count_milestone_100
        - asset_count_milestone_500
        - asset_count_milestone_1000
        - critical_asset_found
        - high_value_target_identified
    - type: time_interval
      description: "Checkpoint every 10 minutes during active reconnaissance"
      interval_minutes: 10
```

## Manual Checkpoint

```
manual_checkpoint:
  save_command: "/checkpoint save reconnaissance-deep-dive [label]"
  options:
    - include_discovered_assets: true
    - include_tech_fingerprints: true
    - include_api_endpoints: true
    - include_recon_state: true
    - minimal: "asset counts only, skip detailed data"
  special_commands:
    - "/recon snapshot": "Capture full recon state"
    - "/recon assets": "Export discovered assets and checkpoint"
    - "/recon report": "Generate recon report and checkpoint"
    - "/recon resume [phase]": "Restore and resume specific recon phase"
```

## Checkpoint Format Schema

```
recon_checkpoint:
  envelope:
    magic: "CHKP-RECON-V1"
    version: "1.0"
    domain: "reconnaissance-deep-dive"
  sections:
    - section_id: "recon_progress"
      description: "Reconnaissance phase progress"
      fields:
        - total_phases: "integer"
        - completed_phases: "integer"
        - in_progress_phase: "current phase or null"
        - overall_progress: "float 0-100"
        - phases:
          - phase_id: "identifier"
            phase_name: "recon phase name"
            source_file: "relative path"
            status: "pending | in_progress | completed | skipped"
            started_at: "ISO-8601 or null"
            completed_at: "ISO-8601 or null"
            assets_discovered: "integer"
            duration: "duration"
            tools_used: "list of tools"
            notes: "phase notes"
    - section_id: "discovered_assets"
      description: "Complete discovered asset inventory"
      fields:
        - subdomains:
          - subdomain: "full subdomain"
            ip_addresses: "list of IPs"
            first_discovered: "ISO-8601"
            last_verified: "ISO-8601"
            status: "alive | dead | unknown"
            source: "discovery method"
            ports: "list of open ports"
            technologies: "list of identified technologies"
        - api_endpoints:
          - endpoint: "full URL"
            method: "HTTP method"
            parameters: "list of parameters"
            authentication: "required | optional | none"
            documentation_url: "API documentation URL"
            first_discovered: "ISO-8601"
            source: "discovery method"
        - technologies:
          - technology: "name"
            version: "version string"
            category: "cms | framework | language | server | library"
            confidence: "float 0-100"
            source: "detection method"
            affected_assets: "list of subdomains"
        - configurations:
          - config_type: "string"
            config_path: "URL or file path"
            contains_secrets: "boolean"
            risk_level: "low | medium | high | critical"
            source: "discovery method"
        - leaks:
          - leak_type: "source_code | credentials | api_keys | tokens"
            leak_source: "where found"
            leak_content_summary: "summary without actual secrets"
            risk_level: "critical | high | medium | low"
            first_discovered: "ISO-8601"
        - assets_summary:
          total_subdomains: "integer"
          alive_subdomains: "integer"
          total_api_endpoints: "integer"
          total_technologies: "integer"
          total_configurations: "integer"
          total_leaks: "integer"
          critical_assets: "integer"
          high_value_assets: "integer"
    - section_id: "attack_surface_map"
      description: "Mapped attack surface from recon"
      fields:
        - attack_surface:
          - asset_category: "string"
            asset_count: "integer"
            attack_vectors: "list of potential vectors"
            risk_level: "low | medium | high | critical"
            coverage: "float 0-100"
        - prioritized_targets:
          - target: "asset or subdomain"
            priority: "critical | high | medium | low"
            reasoning: "why this is prioritized"
            estimated_effort: "hours"
            potential_impact: "low | medium | high | critical"
        - attack_surface_score: "float 0-100"
        - surface_coverage: "float 0-100"
    - section_id: "recon_state"
      description: "Current reconnaissance session state"
      fields:
        - session_start: "ISO-8601"
        - total_duration: "duration"
        - tools_executed:
          - tool_name: "string"
            execution_count: "integer"
            total_duration: "duration"
            success_rate: "float"
            rate_limit_state: "current rate limit status"
        - proxy_state: "active proxy configuration"
        - auth_state: "authentication state if applicable"
        - error_log:
          - errors: "list of errors encountered"
            recovery_actions: "list of recovery actions taken"
    - section_id: "checksum"
      fields:
        - payload_hash: "SHA-256"
        - section_hashes: "per-section SHA-256"
```

## Validation

```
validation_rules:
  pre_checkpoint:
    - rule: "asset_data_consistent"
      description: "Asset data is internally consistent"
      action_on_fail: "reconcile_asset_data"
    - rule: "no_duplicate_assets"
      description: "No duplicate entries in asset inventory"
      action_on_fail: "deduplicate_assets"
    - rule: "phase_progress_valid"
      description: "Phase progress states are consistent"
      action_on_fail: "reconcile_progress"
    - rule: "tech_fingerprints_fresh"
      description: "Technology fingerprints are recent"
      action_on_fail: "refresh_fingerprints"
  post_restore:
    - rule: "targets_still_alive"
      description: "Discovered targets are still accessible"
      action_on_fail: "reverify_targets"
    - rule: "assets_still_in_scope"
      description: "Discovered assets are still in scope"
      action_on_fail: "refresh_scope"
    - rule: "recon_tools_available"
      description: "All recon tools are available"
      action_on_fail: "reinstall_tools"
    - rule: "rate_limits_reset"
      description: "Rate limits are properly reset for new session"
      action_on_fail: "reset_rate_limits"
```

## Pruning Strategy

```
pruning_strategy:
  retention_policy:
    max_checkpoints: 30
    ttl_hours: 72
    preserve_asset_inventory: true
    preserve_attack_surface_map: true
    preserve_critical_assets: true
  pruning_priority:
    1: "time_interval_checkpoints — routine saves"
    2: "recon_milestone_checkpoints — milestone records"
    3: "new_asset_discovered_checkpoints — discovery records"
    4: "recon_phase_complete_checkpoints — phase completion"
  special_rules:
    - "Never prune asset inventory checkpoints"
    - "Never prune attack surface maps"
    - "Always preserve critical/high-value asset discoveries"
    - "Archive phase completion data after TTL"
    - "Keep at least 3 checkpoints with full asset data"
```

## Checkpoint Index

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "reconnaissance-deep-dive"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "user label"
        phases_completed: "integer / total"
        total_assets: "integer"
        attack_surface_score: "float"
        file_path: "relative path"
        checksum: "SHA-256 prefix"
    asset_history:
      - date: "ISO-8601"
        total_assets: "integer"
        new_assets: "integer"
        checkpoint_id: "reference"
    phase_history:
      - phase_name: "string"
        completed_at: "ISO-8601"
        assets_discovered: "integer"
        checkpoint_id: "reference"
```

## Restore from Checkpoint

```
restore_procedure:
  steps:
    1: "Load checkpoint index"
    2: "Select target checkpoint"
    3: "Validate asset inventory integrity"
    4: "Restore recon progress"
    5: "Restore discovered assets"
    6: "Restore attack surface map"
    7: "Restore recon session state"
    8: "Re-verify target accessibility"
    9: "Resume reconnaissance from checkpoint"
    10: "Log restoration event"
  restore_modes:
    - full: "Restore complete recon state"
    - assets_only: "Restore asset inventory only"
    - progress_only: "Restore phase progress only"
    - from_phase: "Restore and resume from specific phase"
    - attack_surface_only: "Restore attack surface map only"
```

## Domain File References

### Subdomain and Enumeration (01-10)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `01-Advanced-Subdomain-Enumeration.md` | Stores subdomain enumeration state, discovered subdomains |
| 02 | `02-Passive-OSINT-Collection.md` | Stores passive OSINT state, intelligence gathered |
| 03 | `03-Active-Asset-Discovery.md` | Stores active discovery state, alive hosts |
| 04 | `04-Technology-Stack-Fingerprinting.md` | Stores tech stack fingerprints, technology map |
| 05 | `05-Cloud-Resource-Enumeration.md` | Stores cloud resource state, provider assets |
| 06 | `06-API-Endpoint-Discovery.md` | Stores API endpoint discovery state, endpoints found |
| 07 | `07-JavaScript-Source-Analysis.md` | Stores JS analysis state, endpoint extraction |
| 08 | `08-Configuration-File-Extraction.md` | Stores config extraction state, found configurations |
| 09 | `09-Version-Detection-Techniques.md` | Stores version detection state, detected versions |
| 10 | `10-Content-Discovery-Automation.md` | Stores content discovery state, hidden content |

### Deep Enumeration (11-20)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 11 | `11-Directory-Brute-Forcing.md` | Stores directory brute-force state, discovered paths |
| 12 | `12-File-Type-Detection.md` | Stores file type detection state, file inventory |
| 13 | `13-Backup-File-Discovery.md` | Stores backup file discovery state, backup files |
| 14 | `14-Source-Code-Leak-Detection.md` | Stores source code leak state, leaked code |
| 15 | `15-Git-Repository-Analysis.md` | Stores git repo analysis state, repo findings |
| 16 | `16-DNS-Enumeration-Advanced.md` | Stores advanced DNS state, DNS records |
| 17 | `17-Certificate-Transparency-Logs.md` | Stores CT log state, certificate findings |
| 18 | `18-Historical-Data-Analysis.md` | Stores historical data state, trend findings |
| 19 | `19-Social-Media-OSINT.md` | Stores social media OSINT state, profile findings |
| 20 | `20-Employee-Linked-Assets.md` | Stores employee asset state, linked assets |

### Intelligence Gathering (21-30)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 21 | `21-Third-Party-Integration-Discovery.md` | Stores third-party integration state, integration map |
| 22 | `22-Web-Archive-Analysis.md` | Stores web archive state, archive findings |
| 23 | `23-Pastebin-and-Leak-Searching.md` | Stores leak search state, leak findings |
| 24 | `24-Code-Repository-Mining.md` | Stores code repo mining state, repo findings |
| 25 | `25-Container-Registry-Enumeration.md` | Stores container registry state, image findings |
| 26 | `26-IoT-Device-Discovery.md` | Stores IoT device state, device findings |
| 27 | `27-Mobile-App-Analysis.md` | Stores mobile app analysis state, app findings |
| 28 | `28-API-Documentation-Extraction.md` | Stores API doc extraction state, doc findings |
| 29 | `29-WebSocket-Endpoint-Discovery.md` | Stores WebSocket endpoint state, endpoint findings |
| 30 | `30-GraphQL-Introspection.md` | Stores GraphQL introspection state, schema findings |

### Advanced Recon (31-40)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 31 | `31-XML-RPC-and-SOAP-Discovery.md` | Stores XML-RPC/SOAP state, endpoint findings |
| 32 | `32-Email-Address-Harvesting.md` | Stores email harvesting state, email findings |
| 33 | `33-Phone-Number-Enumeration.md` | Stores phone enum state, phone findings |
| 34 | `34-Physical-Location-Intelligence.md` | Stores physical location state, location findings |
| 35 | `35-Supply-Chain-Asset-Mapping.md` | Stores supply chain mapping state, dependency map |
| 36 | `36-Competitor-Analysis.md` | Stores competitor analysis state, competitor findings |
| 37 | `37-Partner-Network-Discovery.md` | Stores partner network state, partner findings |
| 38 | `38-Acquisition-Target-Analysis.md` | Stores acquisition analysis state, target findings |
| 39 | `39-Subsidiary-Asset-Mapping.md` | Stores subsidiary mapping state, subsidiary findings |
| 40 | `40-Regional-Infrastructure-Mapping.md` | Stores regional infra state, regional findings |

### Intelligence and Analysis (41-50)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 41 | `41-Content-Management-System-Detection.md` | Stores CMS detection state, CMS findings |
| 42 | `42-Framework-and-Library-Identification.md` | Stores framework identification state, framework findings |
| 43 | `43-Server-Configuration-Analysis.md` | Stores server config state, config findings |
| 44 | `44-SSL-TLS-Certificate-Analysis.md` | Stores SSL/TLS analysis state, cert findings |
| 45 | `45-HTTP-Header-Intelligence.md` | Stores HTTP header state, header findings |
| 46 | `46-Cookie-Analysis-and-Session-Management.md` | Stores cookie analysis state, cookie findings |
| 47 | `47-Error-Page-Analysis.md` | Stores error page state, error findings |
| 48 | `48-Debug-Endpoint-Discovery.md` | Stores debug endpoint state, debug findings |
| 49 | `49-Staging-Environment-Detection.md` | Stores staging env state, staging findings |
| 50 | `50-Advanced-Reconnaissance-Strategy.md` | Stores advanced recon strategy, strategy state |

## Reconnaissance State Machine

```
recon_states:
  - IDLE: "No reconnaissance active"
  - PLANNING: "Planning recon strategy"
  - ENUMERATING: "Active enumeration in progress"
  - ANALYZING: "Analyzing discovered assets"
  - FINGERPRINTING: "Fingerprinting technologies and versions"
  - DISCOVERING: "Content and endpoint discovery"
  - INTELLIGENCE: "Gathering intelligence and OSINT"
  - MAPPING: "Mapping attack surface"
  - PRIORITIZING: "Prioritizing targets for testing"
  - COMPLETE: "Reconnaissance phase complete"

state_transitions:
  IDLE -> PLANNING: "recon_initiated"
  PLANNING -> ENUMERATING: "plan_finalized"
  ENUMERATING -> ANALYZING: "enumeration_complete"
  ANALYZING -> FINGERPRINTING: "analysis_complete"
  FINGERPRINTING -> DISCOVERING: "fingerprinting_complete"
  DISCOVERING -> INTELLIGENCE: "discovery_complete"
  INTELLIGENCE -> MAPPING: "intelligence_gathered"
  MAPPING -> PRIORITIZING: "surface_mapped"
  PRIORITIZING -> COMPLETE: "targets_prioritized"
  ANY -> ENUMERATING: "new_target_added"
```

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `advanced-automation` | Recon results feed automation pipelines |
| `core-prompts-hunting` | Recon findings inform hunting targets |
| `bug-bounty-program-strategy` | Recon scope informs program selection |
| `specialized-targets` | Recon identifies specialized target types |
| `report-writing-mastery` | Recon findings feed report generation |
