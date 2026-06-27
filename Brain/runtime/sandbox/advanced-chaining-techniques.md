# Advanced Chaining Techniques — Sandboxed Execution Framework

## Domain Overview

This file defines the sandboxed execution environment for the **Advanced-Chaining-Techniques** domain, covering all 49 chain execution modules. The sandbox enforces step-by-step isolation, inter-step data validation, exploitation boundary enforcement, and full chain execution recording.

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain Name | Advanced-Chaining-Techniques |
| Sandbox Type | Chain Execution Sandbox |
| Primary Purpose | Isolated execution of multi-step exploitation chains |
| Risk Level | CRITICAL — chains combine multiple attack primitives |
| Isolation Requirement | Step-isolated, inter-step validated |
| Total Domain Files | 49 |
| Sandbox Version | 2.0 |

---

## Isolation Levels

### Level 1 — Chain Analysis (Safe)

Read-only analysis of chain definitions and logic without execution.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | DENIED |
| Process Spawn | DENIED |
| Chain Execution | DRY-RUN ONLY |
| Time Limit | 120 seconds |
| Memory Limit | 256 MB |
| CPU Limit | 1 core |

### Level 2 — Chain Simulation (Controlled)

Simulated chain execution with mocked responses.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED (mocked responses) |
| Filesystem Write | SANDBOXED TEMP ONLY |
| Process Spawn | LIMITED (max 3 per step) |
| Chain Execution | SIMULATED |
| Time Limit | 300 seconds |
| Memory Limit | 512 MB |
| CPU Limit | 2 cores |

### Level 3 — Chain Execution (Isolated)

Live chain execution with strict step isolation.

| Property | Configuration |
|----------|---------------|
| Network Access | RATE-LIMITED (5 req/s) |
| Filesystem Write | PER-STEP ISOLATED DIRECTORIES |
| Process Spawn | MONITORED (max 5 per step) |
| Chain Execution | LIVE (step-isolated) |
| Time Limit | 900 seconds |
| Memory Limit | 1 GB |
| CPU Limit | 4 cores |

### Level 4 — Chain Execution (Maximum Isolation)

Full chain execution with maximum isolation between steps.

| Property | Configuration |
|----------|---------------|
| Network Access | VNET-ISOLATED (per-step network namespaces) |
| Filesystem Write | FULL SANDBOX with per-step isolation |
| Process Spawn | FULLY MONITORED (max 10 per step) |
| Chain Execution | LIVE (full isolation) |
| Time Limit | 1800 seconds |
| Memory Limit | 2 GB |
| CPU Limit | 4 cores |

---

## Chain Execution Model

### Step Isolation Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   CHAIN ORCHESTRATOR                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐             │
│  │ Step 1  │───▶│ Step 2  │───▶│ Step 3  │───▶ ...     │
│  │Sandbox  │    │Sandbox  │    │Sandbox  │              │
│  │  (ns1)  │    │  (ns2)  │    │  (ns3)  │              │
│  └────┬────┘    └────┬────┘    └────┬────┘              │
│       │              │              │                    │
│       ▼              ▼              ▼                    │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐             │
│  │ Output  │───▶│ Input   │───▶│ Input   │             │
│  │ Valid.  │    │ Valid.  │    │ Valid.  │              │
│  └─────────┘    └─────────┘    └─────────┘             │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │           INTER-STEP VALIDATION ENGINE           │    │
│  │  • Output sanitization                          │    │
│  │  • Schema validation                            │    │
│  │  • Boundary enforcement                         │    │
│  │  • Data leakage prevention                      │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### Inter-Step Data Flow Policy

```yaml
inter_step_data:
  mode: validated_passthrough
  rules:
    - name: output_sanitization
      description: >
        All output from a step is sanitized before being
        passed to the next step.
      sanitizers:
        - type: credential_removal
          patterns:
            - password
            - api_key
            - secret
            - token
            - auth
        - type: internal_ip_removal
          patterns:
            - 10.0.0.0/8
            - 172.16.0.0/12
            - 192.168.0.0/16
        - type: sensitive_data_masking
          patterns:
            - 'SSN: \d{3}-\d{2}-\d{4}'
            - 'Credit Card: \d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}'
    - name: schema_validation
      description: >
        Output must conform to expected schema before
        being passed to the next step.
      validation:
        enabled: true
        strict_mode: false
        max_output_size: 10MB
    - name: boundary_enforcement
      description: >
        Data crossing step boundaries is validated against
        the chain's permitted data types.
      allowed_types:
        - string
        - number
        - boolean
        - array
        - object
      denied_patterns:
        - 'exec('
        - 'eval('
        - '__import__'
        - 'subprocess'
        - 'os.system'
        - 'shell_exec'
    - name: data_leakage_prevention
      description: >
        Prevent any data from leaking between chain steps
        that could compromise isolation.
      checks:
        - no_process_environment_leak
        - no_filesystem_path_leak
        - no_network_credential_leak
        - no_memory_address_leak
```

---

## Sandbox Policies

### Filesystem Policy

```yaml
filesystem:
  root: /sandbox/advanced-chaining/
  step_isolation: true
  structure:
    root: /sandbox/advanced-chaining/
    chains: /sandbox/advanced-chaining/chains/{chain_id}/
    steps: /sandbox/advanced-chaining/chains/{chain_id}/steps/{step_number}/
    shared: /sandbox/advanced-chaining/shared/{chain_id}/
    output: /sandbox/advanced-chaining/output/{chain_id}/
    logs: /sandbox/advanced-chaining/logs/{chain_id}/
  writable_paths:
    - /sandbox/advanced-chaining/chains/{chain_id}/steps/{step_number}/output/
    - /sandbox/advanced-chaining/shared/{chain_id}/
    - /sandbox/advanced-chaining/output/{chain_id}/
    - /sandbox/advanced-chaining/temp/{chain_id}/
  read_only_paths:
    - /sandbox/advanced-chaining/templates/
    - /sandbox/advanced-chaining/config/
    - /sandbox/advanced-chaining/wordlists/
  denied_paths:
    - /sandbox/advanced-chaining/chains/{chain_id}/steps/{step_number}/../
    - /etc/
    - /root/
    - /home/
    - /var/
    - /proc/
    - /sys/
  step_isolation_rules:
    - step_cannot_read_other_steps_output
    - step_cannot_write_to_other_steps_directories
    - step_can_read_shared_directory_only
    - shared_directory_is_cleared_between_chains
  max_file_size: 50MB
  max_total_storage: 4GB
  allowed_extensions:
    - .txt
    - .json
    - .csv
    - .xml
    - .html
    - .yaml
    - .yml
    - .log
    - .md
    - .poc
    - .chain
  denied_extensions:
    - .exe
    - .dll
    - .so
    - .sh
    - .bat
    - .ps1
```

### Network Policy

```yaml
network:
  mode: step_isolated
  default_action: deny
  per_step_network: true
  steps:
    step_1:
      allowed_destinations:
        - target-scope.com
      allowed_ports: [80, 443]
      rate_limit: 5/s
    step_2:
      allowed_destinations:
        - target-scope.com
        - internal-validation
      allowed_ports: [80, 443, 8080]
      rate_limit: 5/s
    step_3:
      allowed_destinations:
        - target-scope.com
      allowed_ports: [80, 443, 8080, 8443]
      rate_limit: 10/s
  inter_step_network:
    enabled: false
    description: >
      Steps cannot communicate over the network.
      Data passes only through validated data channels.
  chain_wide_network:
    allowed_destinations:
      - target-scope.com
    blocked_destinations:
      - 169.254.169.254
      - metadata.google.internal
      - *.internal.corp
      - 10.0.0.0/8
      - 172.16.0.0/12
      - 192.168.0.0/16
    dns:
      resolver: sandbox-dns.internal
      logging: full
    proxy:
      enabled: true
      type: http
      address: sandbox-proxy.internal:8080
      chain_logging: true
```

### Process Policy

```yaml
process:
  per_step_isolation: true
  steps:
    step_1:
      max_children: 5
      allowed_binaries:
        - /sandbox/bin/recon-tool
        - /sandbox/bin/processor
    step_2:
      max_children: 5
      allowed_binaries:
        - /sandbox/bin/validator
        - /sandbox/bin/scanner
    step_3:
      max_children: 5
      allowed_binaries:
        - /sandbox/bin/exploiter
        - /sandbox/bin/verifier
  chain_wide_limits:
    max_total_processes: 20
    max_concurrent_steps: 1
    sequential_execution: true
    step_timeout: 300s
    chain_timeout: 1800s
  resource_limits:
    cpu_percent_per_step: 40
    memory_mb_per_step: 512
    open_files_per_step: 512
  execution:
    kill_on_step_failure: true
    continue_on_non_critical_failure: false
    restart_allowed: false
  user:
    run_as: sandbox-user
    uid: 1001
    gid: 1001
    no_sudo: true
```

---

## Policy Enforcement

### Enforcement Architecture

```
┌─────────────────────────────────────────────────────────┐
│            CHAIN ENFORCEMENT ENGINE                      │
├─────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌───────────────────────────────┐  │
│  │ Pre-Chain     │  │ Step Boundary Validator       │  │
│  │ Validator     │◄─┤ (data flow enforcement)       │  │
│  └───────┬───────┘  └───────────────────────────────┘  │
│          │                                              │
│  ┌───────▼───────┐  ┌───────────────────────────────┐  │
│  │ Step          │  │ Inter-Step Data Sanitizer      │  │
│  │ Isolator      │◄─┤ (credential removal, etc.)     │  │
│  └───────┬───────┘  └───────────────────────────────┘  │
│          │                                              │
│  ┌───────▼───────┐  ┌───────────────────────────────┐  │
│  │ Resource      │  │ Chain State Machine            │  │
│  │ Monitor       │◄─┤ (step progression tracking)    │  │
│  └───────┬───────┘  └───────────────────────────────┘  │
│          │                                              │
│  ┌───────▼───────┐  ┌───────────────────────────────┐  │
│  │ Violation     │  │ Execution Recorder            │  │
│  │ Handler       │◄─┤ (full chain audit)             │  │
│  └───────────────┘  └───────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Enforcement Rules

| Rule ID | Condition | Action | Severity |
|---------|-----------|--------|----------|
| AC-001 | Step output exceeds size limit | TRUNCATE + WARN | MEDIUM |
| AC-002 | Credential detected in inter-step data | REDACT + ALERT | CRITICAL |
| AC-003 | Step attempts to read other step's output | BLOCK + ALERT | HIGH |
| AC-004 | Step attempts cross-step network communication | BLOCK + ALERT | CRITICAL |
| AC-005 | Chain step exceeds time limit | KILL STEP + ABORT CHAIN | HIGH |
| AC-006 | Total chain time exceeds limit | KILL ALL + LOG | HIGH |
| AC-007 | Step output fails schema validation | REJECT + RETRY (max 2) | MEDIUM |
| AC-008 | Sensitive data detected in output | REDACT + LOG | HIGH |
| AC-009 | Step process exceeds resource limit | KILL STEP | HIGH |
| AC-010 | Chain state corruption detected | ABORT + ALERT | CRITICAL |

---

## Output Capture

### Chain Output Configuration

```yaml
output_capture:
  enabled: true
  per_step_capture: true
  formats:
    - json
    - structured
    - chain_diagram
  destinations:
    per_step:
      path: /sandbox/advanced-chaining/output/{chain_id}/steps/{step_number}/
      format: json
      retention: 60d
    chain_summary:
      path: /sandbox/advanced-chaining/output/{chain_id}/summary/
      format: structured
      retention: 90d
    chain_diagram:
      path: /sandbox/advanced-chaining/output/{chain_id}/diagrams/
      format: mermaid
      retention: 90d
  sanitization:
    enabled: true
    rules:
      - pattern: 'password\s*[:=]\s*\S+'
        action: redact
      - pattern: 'api[_-]?key\s*[:=]\s*\S+'
        action: redact
      - pattern: 'Bearer\s+[A-Za-z0-9\-._~+/]+=*'
        action: redact
      - pattern: '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
        action: partial_redact
  size_limits:
    max_output_per_step: 50MB
    max_output_per_chain: 200MB
    max_lines_per_step: 500000
    max_lines_per_chain: 2000000
  compression:
    enabled: true
    algorithm: zstd
    level: 3
    threshold: 5MB
  encryption:
    enabled: true
    algorithm: AES-256-GCM
    key_rotation: 12h
```

### Chain Execution Recording

```yaml
chain_recording:
  enabled: true
  levels:
    minimal:
      timestamps: true
      step_results: true
      chain_result: true
      duration: true
    standard:
      timestamps: true
      step_results: true
      step_inputs: true
      step_outputs: true
      inter_step_data: true
      chain_result: true
      duration: true
      resource_usage: true
    verbose:
      timestamps: true
      step_results: true
      step_inputs: true
      step_outputs: true
      step_environment: true
      inter_step_data: true
      inter_step_validation: true
      chain_result: true
      duration: true
      resource_usage: true
      network_activity: true
      file_operations: true
      process_tree: true
  storage:
    path: /sandbox/advanced-chaining/recordings/
    format: jsonl
    compression: zstd
    retention: 90d
    max_size: 10GB
  integrity:
    hash_algorithm: sha256
    chain_verification: true
    tamper_detection: true
    merkle_tree: true
```

---

## Domain File References

| # | File | Module | Sandbox Level | Description |
|---|------|--------|---------------|-------------|
| 1 | recon-to-exploit.md | Recon Chain | Level 2 | Reconnaissance to exploitation chain |
| 2 | sqli-to-data-exfil.md | SQLi Chain | Level 4 | SQL injection to data exfiltration |
| 3 | xss-to-session-hijack.md | XSS Chain | Level 3 | XSS to session hijacking |
| 4 | ssrf-to-rce.md | SSRF Chain | Level 4 | SSRF to remote code execution |
| 5 | idor-to-privilege-escalation.md | IDOR Chain | Level 3 | IDOR to privilege escalation |
| 6 | open-redirect-to-oauth.md | OAuth Chain | Level 3 | Open redirect to OAuth token theft |
| 7 | csrf-to-account-takeover.md | CSRF Chain | Level 3 | CSRF to account takeover |
| 8 | race-condition-chain.md | Race Chain | Level 3 | Race condition exploitation chain |
| 9 | file-upload-to-rce.md | Upload Chain | Level 4 | File upload to RCE |
| 10 | ssti-to-rce.md | SSTI Chain | Level 4 | Server-side template injection to RCE |
| 11 | xxe-to-ssrf.md | XXE Chain | Level 4 | XXE to SSRF |
| 12 | nosql-injection-chain.md | NoSQL Chain | Level 3 | NoSQL injection exploitation |
| 13 | graphql-introspection.md | GraphQL Chain | Level 3 | GraphQL introspection chain |
| 14 | api-mass-assignment.md | Mass Assign | Level 3 | Mass assignment exploitation |
| 15 | jwt-attack-chain.md | JWT Chain | Level 3 | JWT vulnerability chain |
| 16 | oauth-token-theft.md | OAuth Theft | Level 3 | OAuth token theft chain |
| 17 | saml-attack-chain.md | SAML Chain | Level 4 | SAML attack chain |
| 18 | mfa-bypass-chain.md | MFA Chain | Level 3 | MFA bypass chain |
| 19 | session-fixation-chain.md | Session Chain | Level 3 | Session fixation chain |
| 20 | password-reset-chain.md | Password Chain | Level 3 | Password reset exploitation chain |
| 21 | subdomain-takeover-chain.md | Subdomain Chain | Level 3 | Subdomain takeover chain |
| 22 | dns-rebinding-chain.md | DNS Chain | Level 3 | DNS rebinding attack chain |
| 23 | cache-poisoning-chain.md | Cache Chain | Level 3 | Cache poisoning chain |
| 24 | http-smuggling-chain.md | Smuggle Chain | Level 4 | HTTP smuggling chain |
| 25 | websocket-hijack.md | WebSocket Chain | Level 3 | WebSocket hijacking chain |
| 26 | postmessage-xss.md | PostMessage Chain | Level 3 | PostMessage XSS chain |
| 27 | prototype-pollution.md | Prototype Chain | Level 3 | Prototype pollution chain |
| 28 | deserialization-chain.md | Deser Chain | Level 4 | Deserialization attack chain |
| 29 | ldap-injection-chain.md | LDAP Chain | Level 3 | LDAP injection chain |
| 30 | xpath-injection-chain.md | XPath Chain | Level 3 | XPath injection chain |
| 31 | header-injection-chain.md | Header Chain | Level 3 | HTTP header injection chain |
| 32 | host-header-chain.md | Host Chain | Level 3 | Host header injection chain |
| 33 | log-injection-chain.md | Log Chain | Level 3 | Log injection chain |
| 34 | email-injection-chain.md | Email Chain | Level 3 | Email header injection chain |
| 35 | csv-injection-chain.md | CSV Chain | Level 3 | CSV injection chain |
| 36 | formula-injection-chain.md | Formula Chain | Level 3 | Formula injection chain |
| 37 | template-injection-chain.md | Template Chain | Level 3 | Template injection chain |
| 38 | expression-language.md | EL Chain | Level 3 | Expression language injection |
| 39 | regex-dos-chain.md | ReDoS Chain | Level 3 | Regular expression DoS chain |
| 40 | billion-laughs-chain.md | XML Bomb | Level 3 | Billion laughs / XML bomb chain |
| 41 | zip-slip-chain.md | ZIP Slip | Level 3 | ZIP path traversal chain |
| 42 | deserialization-rce.md | Deser RCE | Level 4 | Deserialization to RCE |
| 43 | unsafe-eval-chain.md | Eval Chain | Level 4 | Unsafe eval exploitation |
| 44 | command-injection-chain.md | Cmdi Chain | Level 4 | Command injection chain |
| 45 | prompt-injection-chain.md | Prompt Chain | Level 3 | Prompt injection chain |
| 46 | idn-homograph-chain.md | IDN Chain | Level 3 | IDN homograph attack chain |
| 47 | redirect-chain-bypass.md | Redirect Chain | Level 3 | Redirect chain bypass |
| 48 | chained-idor-rce.md | IDOR-RCE | Level 4 | Chained IDOR to RCE |
| 49 | full-kill-chain.md | Kill Chain | Level 4 | Complete kill chain orchestration |

---

## Configuration YAML — Full Sandbox Definition

```yaml
sandbox:
  name: advanced-chaining-sandbox
  version: "2.0"
  domain: advanced-chaining-techniques
  description: >
    Sandboxed execution environment for multi-step exploitation chains.
    Enforces step isolation, inter-step data validation, and full chain recording.

  container:
    image: sandbox/advanced-chaining:2.0
    base: alpine-3.18
    runtime: gvisor
    security:
      seccomp_profile: strict
      capabilities: []
      read_only_rootfs: true
      no_new_privileges: true
      user_namespace: true
      apparmor_profile: sandbox-chain-aa

  resource_limits:
    cpu:
      shares: 1024
      quota: 400000
      period: 100000
      max_cores: 4
    memory:
      limit: 4Gi
      swap_limit: 0
      oom_kill_disable: false
    disk:
      limit: 40Gi
      read_limit: 100MB/s
      write_limit: 50MB/s
    network:
      bandwidth: 50Mbps
      connections: 50
      sockets: 256

  chain_orchestration:
    max_concurrent_chains: 1
    max_steps_per_chain: 20
    max_parallel_steps: 1
    step_validation: strict
    inter_step_timeout: 300s
    chain_timeout: 1800s

  monitoring:
    metrics:
      interval: 5s
      exporters:
        - prometheus
        - json_file
    alerts:
      channels:
        - type: webhook
          url: https://alerts.internal/sandbox
        - type: log
          level: WARNING
    tracing:
      enabled: true
      sampling_rate: 1.0
      exporter: jaeger
```
