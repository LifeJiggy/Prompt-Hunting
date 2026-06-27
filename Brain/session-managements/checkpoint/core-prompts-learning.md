# CHECKPOINT MANAGEMENT — Core Prompts Learning

## Title

Checkpoint Management for Core Prompts Learning Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `core-prompts-learning` |
| Domain Path | `Core-Prompts-Learning/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/core-prompts-learning/` |
| Session Scope | Learning progress, skill acquisition, knowledge state |
| Auto-Checkpoint Interval | Every learning module completion or 15 minutes |
| Manual Checkpoint Trigger | `/checkpoint save core-prompts-learning [label]` |
| Max Checkpoints Retained | 25 per session |
| Checkpoint TTL | 96 hours (configurable) |
| Restore Command | `/checkpoint restore core-prompts-learning [id]` |

## Overview

This checkpoint management system governs the state of all learning workflows defined across the 50 files in `Core-Prompts-Learning/`. This domain focuses on structured learning and skill acquisition — each file represents a vulnerability class or security domain that can be studied, practiced, and mastered. Checkpoints here capture learning progress, mastery levels, practice exercise completion, knowledge retention scores, and learning path state.

The checkpoint system ensures that learning progress is preserved across sessions, enabling continuous skill development. Unlike hunting checkpoints that capture transient test state, learning checkpoints capture durable knowledge state that compounds over time. The system tracks not just what has been studied, but how well it has been learned and what areas need reinforcement.

## Auto-Checkpoint Configuration

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: learning_module_complete
      description: "Checkpoint when a learning module is completed"
      events:
        - recon_learning_complete
        - js_analysis_learning_complete
        - api_analysis_learning_complete
        - auth_learning_complete
        - authz_learning_complete
        - input_validation_learning_complete
        - business_logic_learning_complete
        - client_storage_learning_complete
        - crypto_learning_complete
        - error_handling_learning_complete
        - file_upload_learning_complete
        - ssrf_learning_complete
        - csrf_learning_complete
        - cors_learning_complete
        - race_condition_learning_complete
        - third_party_learning_complete
        - config_misconfig_learning_complete
        - network_infra_learning_complete
        - mobile_api_learning_complete
        - reporting_learning_complete
        - waf_bypass_learning_complete
        - http_smuggling_learning_complete
        - subdomain_takeover_learning_complete
        - host_header_learning_complete
        - xxe_learning_complete
        - deserialization_learning_complete
        - command_injection_learning_complete
        - nosql_injection_learning_complete
        - graphql_learning_complete
        - websocket_learning_complete
        - ssti_learning_complete
        - jwt_learning_complete
        - csp_bypass_learning_complete
        - clickjacking_learning_complete
        - hpp_learning_complete
        - ldap_injection_learning_complete
        - session_puzzling_learning_complete
        - insecure_file_handling_learning_complete
        - xssi_learning_complete
        - prototype_pollution_learning_complete
        - response_splitting_learning_complete
        - xpath_injection_learning_complete
        - advanced_client_side_learning_complete
        - cloud_security_learning_complete
        - third_party_integration_learning_complete
        - mobile_app_security_learning_complete
        - iot_embedded_learning_complete
        - api_security_graphql_learning_complete
        - webassembly_learning_complete
        - blockchain_crypto_learning_complete
        - automation_tool_learning_complete
        - reverse_engineering_learning_complete
        - compliance_regulatory_learning_complete
        - threat_modeling_learning_complete
    - type: mastery_level_change
      description: "Checkpoint when mastery level changes"
      events:
        - mastery_improved
        - mastery_regressed
        - mastery_milestone_reached
    - type: exercise_complete
      description: "Checkpoint when a practice exercise is completed"
      events:
        - exercise_passed
        - exercise_failed
        - exercise_reviewed
    - type: time_interval
      description: "Checkpoint every 15 minutes during active learning"
      interval_minutes: 15
```

## Manual Checkpoint

```
manual_checkpoint:
  save_command: "/checkpoint save core-prompts-learning [label]"
  options:
    - include_mastery_levels: true
    - include_practice_results: true
    - include_learning_path: true
    - include_knowledge_retention: true
    - minimal: "mastery levels only, skip exercises"
  special_commands:
    - "/learning snapshot": "Capture full learning state"
    - "/learning progress": "Generate progress report and checkpoint"
    - "/learning mastery": "Show mastery levels across all modules"
    - "/learning review [module]": "Review and checkpoint specific module"
```

## Checkpoint Format Schema

```
learning_checkpoint:
  envelope:
    magic: "CHKP-LEARNING-V1"
    version: "1.0"
    domain: "core-prompts-learning"
  sections:
    - section_id: "learning_progress"
      description: "Overall learning progress across all modules"
      fields:
        - total_modules: "integer"
        - completed_modules: "integer"
        - in_progress_module: "current module or null"
        - overall_progress: "float 0-100"
        - overall_mastery: "float 0-100"
        - modules:
          - module_id: "identifier"
            module_name: "vulnerability class name"
            source_file: "relative path to learning file"
            status: "not_started | in_progress | completed | reviewing"
            started_at: "ISO-8601 or null"
            completed_at: "ISO-8601 or null"
            mastery_level: "novice | beginner | intermediate | advanced | expert"
            mastery_score: "float 0-100"
            practice_exercises_completed: "integer"
            practice_exercises_total: "integer"
            average_exercise_score: "float 0-100"
            knowledge_retention: "float 0-100"
            last_reviewed: "ISO-8601"
            review_count: "integer"
            notes: "learning notes"
    - section_id: "mastery_tracking"
      description: "Detailed mastery tracking across all domains"
      fields:
        - mastery_by_domain:
          - domain_name: "string"
            current_mastery: "float 0-100"
            target_mastery: "float 0-100"
            mastery_trend: "improving | stable | declining"
            last_assessment: "ISO-8601"
            assessment_history:
              - date: "ISO-8601"
                score: "float"
                assessment_type: "practice | exam | application"
        - mastery_milestones:
          - milestone_id: "identifier"
            milestone_name: "string"
            achieved_at: "ISO-8601"
            module: "associated module"
            description: "what was achieved"
        - skill_gaps:
          - gap_id: "identifier"
            skill_area: "string"
            current_level: "string"
            target_level: "string"
            recommended_actions: "list of actions"
            priority: "high | medium | low"
    - section_id: "practice_exercises"
      description: "Practice exercise results and history"
      fields:
        - exercises:
          - exercise_id: "identifier"
            exercise_name: "string"
            module: "associated module"
            exercise_type: "theory | practical | chain | report"
            attempted_at: "ISO-8601"
            score: "float 0-100"
            time_spent_minutes: "float"
            feedback: "exercise feedback"
            strengths: "list of strengths demonstrated"
            weaknesses: "list of areas needing improvement"
        - exercise_statistics:
          total_attempted: "integer"
          average_score: "float"
          improvement_rate: "float"
          time_invested_hours: "float"
    - section_id: "learning_path"
      description: "Current learning path and recommendations"
      fields:
        - current_path:
          - path_name: "string"
            current_step: "integer"
            total_steps: "integer"
            estimated_completion: "ISO-8601"
            steps:
              - step_number: "integer"
                module: "module name"
                status: "completed | current | upcoming"
                priority: "high | medium | low"
        - recommendations:
          - recommendation_id: "identifier"
            type: "study | practice | review | apply"
            module: "module name"
            reason: "why this is recommended"
            estimated_time_minutes: "float"
            expected_outcome: "what to expect"
    - section_id: "checksum"
      fields:
        - payload_hash: "SHA-256"
        - section_hashes: "per-section SHA-256"
```

## Validation

```
validation_rules:
  pre_checkpoint:
    - rule: "mastery_scores_consistent"
      description: "Mastery scores are internally consistent"
      action_on_fail: "recalculate_mastery"
    - rule: "exercise_scores_valid"
      description: "Exercise scores are within valid range"
      action_on_fail: "validate_scores"
    - rule: "learning_path_coherent"
      description: "Learning path is coherent and achievable"
      action_on_fail: "rebuild_learning_path"
    - rule: "retention_scores_current"
      description: "Knowledge retention scores are up-to-date"
      action_on_fail: "update_retention_scores"
  post_restore:
    - rule: "modules_available"
      description: "All learning modules are accessible"
      action_on_fail: "restore_missing_modules"
    - rule: "progress_coherent"
      description: "Restored progress is internally consistent"
      action_on_fail: "reconcile_progress"
    - rule: "mastery_reflects_knowledge"
      description: "Mastery levels reflect actual knowledge"
      action_on_fail: "reassess_mastery"
```

## Pruning Strategy

```
pruning_strategy:
  retention_policy:
    max_checkpoints: 25
    ttl_hours: 96
    preserve_mastery_levels: true
    preserve_exercise_history: true
    preserve_learning_paths: true
  pruning_priority:
    1: "time_interval_checkpoints — routine saves"
    2: "exercise_complete_checkpoints — exercise results"
    3: "mastery_level_change_checkpoints — level changes"
    4: "learning_module_complete_checkpoints — module completion"
  special_rules:
    - "Never prune milestone achievements"
    - "Keep exercise history for full retention period"
    - "Archive completed learning paths after TTL"
    - "Always preserve current learning path"
```

## Checkpoint Index

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "core-prompts-learning"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "user label"
        modules_completed: "integer / total"
        overall_mastery: "float"
        overall_progress: "float"
        file_path: "relative path"
        checksum: "SHA-256 prefix"
    module_history:
      - module_name: "string"
        first_studied: "ISO-8601"
        last_reviewed: "ISO-8601"
        current_mastery: "float"
        total_study_hours: "float"
    mastery_history:
      - date: "ISO-8601"
        overall_mastery: "float"
        checkpoint_id: "reference"
```

## Restore from Checkpoint

```
restore_procedure:
  steps:
    1: "Load checkpoint index"
    2: "Select target checkpoint"
    3: "Validate learning module availability"
    4: "Restore learning progress"
    5: "Restore mastery tracking"
    6: "Restore practice exercise history"
    7: "Restore learning path"
    8: "Recalculate overall progress and mastery"
    9: "Resume learning from checkpoint"
    10: "Log restoration event"
  restore_modes:
    - full: "Restore complete learning state"
    - progress_only: "Restore progress, skip exercise history"
    - mastery_only: "Restore mastery levels only"
    - path_only: "Restore learning path only"
```

## Domain File References

### Core Learning (01-05)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery-Learning.md` | Stores recon learning progress, mastery state |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | Stores JS learning progress, deobfuscation mastery |
| 03 | `3-API-Endpoint-Analysis-Learning.md` | Stores API learning progress, endpoint analysis mastery |
| 04 | `4-Authentication-and-Session-Management-Learning.md` | Stores auth learning progress, session mastery |
| 05 | `5-Authorization-and-Access-Control-Learning.md` | Stores authz learning progress, access control mastery |

### Fundamental Learning (06-15)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 06 | `6-Input-Validation-and-Sanitization-Learning.md` | Stores input validation learning, sanitization mastery |
| 07 | `7-Business-Logic-Flaws-Learning.md` | Stores business logic learning, logic analysis mastery |
| 08 | `8-Client-Side-Storage-Security-Learning.md` | Stores client storage learning, storage security mastery |
| 09 | `9-Cryptography-and-Data-Protection-Learning.md` | Stores crypto learning, encryption analysis mastery |
| 10 | `10-Error-Handling-and-Information-Disclosure-Learning.md` | Stores error handling learning, disclosure mastery |
| 11 | `11-File-Upload-and-Processing-Learning.md` | Stores file upload learning, upload security mastery |
| 12 | `12-Server-Side-Request-Forgery-SSRF-Learning.md` | Stores SSRF learning, internal network mastery |
| 13 | `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | Stores CSRF learning, token analysis mastery |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | Stores CORS learning, origin analysis mastery |
| 15 | `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | Stores race condition learning, timing mastery |

### Advanced Learning (16-25)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 16 | `16-Third-Party-Component-Analysis-Learning.md` | Stores component analysis learning, dependency mastery |
| 17 | `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | Stores config hunting learning, misconfiguration mastery |
| 18 | `18-Network-and-Infrastructure-Security-Learning.md` | Stores network security learning, infra mastery |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | Stores mobile/API learning, platform mastery |
| 20 | `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | Stores reporting learning, PoC mastery |
| 21 | `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | Stores WAF bypass learning, bypass technique mastery |
| 22 | `22-HTTP-Request-Smuggling-Learning.md` | Stores smuggling learning, protocol mastery |
| 23 | `23-Subdomain-Takeover-Learning.md` | Stores subdomain takeover learning, DNS mastery |
| 24 | `24-Host-Header-Injection-Learning.md` | Stores host header learning, injection mastery |
| 25 | `25-XML-External-Entity-XXE-Injection-Learning.md` | Stores XXE learning, XML entity mastery |

### Specialized Learning (26-35)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 26 | `26-Insecure-Deserialization-Learning.md` | Stores deserialization learning, gadget chain mastery |
| 27 | `27-Command-Injection-Learning.md` | Stores command injection learning, payload mastery |
| 28 | `28-NoSQL-Injection-Learning.md` | Stores NoSQL injection learning, query mastery |
| 29 | `29-GraphQL-Vulnerabilities-Learning.md` | Stores GraphQL learning, schema mastery |
| 30 | `30-WebSocket-Security-Learning.md` | Stores WebSocket learning, protocol mastery |
| 31 | `31-Server-Side-Template-Injection-SSTI-Learning.md` | Stores SSTI learning, template mastery |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | Stores JWT learning, token mastery |
| 33 | `33-Content-Security-Policy-CSP-Bypass-Learning.md` | Stores CSP bypass learning, bypass mastery |
| 34 | `34-Clickjacking-and-UI-Redressing-Learning.md` | Stores clickjacking learning, UI mastery |
| 35 | `35-HTTP-Parameter-Pollution-Learning.md` | Stores HPP learning, parameter mastery |

### Advanced Specialized (36-45)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 36 | `36-LDAP-Injection-Learning.md` | Stores LDAP injection learning, directory mastery |
| 37 | `37-Session-Puzzling-and-Fixation-Learning.md` | Stores session puzzling learning, session mastery |
| 38 | `38-Insecure-File-Handling-Learning.md` | Stores file handling learning, path mastery |
| 39 | `39-Advanced-Client-Side-Attacks-Learning.md` | Stores advanced client-side learning, attack mastery |
| 40 | `40-Cloud-Security-and-Misconfigurations-Learning.md` | Stores cloud security learning, cloud mastery |
| 41 | `41-Third-Party-Integration-Security-Learning.md` | Stores third-party integration learning, integration mastery |
| 42 | `42-Mobile-Application-Security-Learning.md` | Stores mobile app security learning, mobile mastery |
| 43 | `43-IoT-and-Embedded-Device-Security-Learning.md` | Stores IoT/embedded learning, device mastery |
| 44 | `44-API-Security-and-GraphQL-Learning.md` | Stores API security learning, API mastery |
| 45 | `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | Stores WebAssembly learning, modern web mastery |

### Mastery Level (46-50)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 46 | `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | Stores blockchain learning, crypto security mastery |
| 47 | `47-Automation-and-Tool-Development-Learning.md` | Stores automation learning, tool development mastery |
| 48 | `48-Advanced-Reverse-Engineering-Learning.md` | Stores reverse engineering learning, RE mastery |
| 49 | `49-Compliance-and-Regulatory-Security-Learning.md` | Stores compliance learning, regulatory mastery |
| 50 | `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | Stores threat modeling learning, risk assessment mastery |

## Learning Mastery State Machine

```
mastery_states:
  - NOVICE: "No knowledge of this domain"
  - BEGINNER: "Basic understanding, can identify with guidance"
  - INTERMEDIATE: "Solid understanding, can identify independently"
  - ADVANCED: "Deep understanding, can identify and exploit"
  - EXPERT: "Comprehensive mastery, can teach and innovate"

state_transitions:
  NOVICE -> BEGINNER: "study_complete_and_exercise_passed"
  BEGINNER -> INTERMEDIATE: "practice_demonstrated_competence"
  INTERMEDIATE -> ADVANCED: "real_world_application_successful"
  ADVANCED -> EXPERT: "teaching_and_innovation_demonstrated"
  BEGINNER -> NOVICE: "knowledge_forgotten_no_review"
  INTERMEDIATE -> BEGINNER: "significant_knowledge_gap_identified"
  ADVANCED -> INTERMEDIATE: "skill_regression_detected"
  EXPERT -> ADVANCED: "domain_changed_significantly"
```

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `core-prompts-hunting` | Learning progress informs hunting readiness |
| `bug-bounty-support` | Support frameworks enhance learning materials |
| `real-world-case-studies` | Case studies provide learning examples |
| `advanced-automation` | Automation knowledge informs learning path |
| `report-writing-mastery` | Reporting skills inform learning outcomes |
