# Core Prompts Hunting — Sandboxed Execution Framework

## Domain Overview

This file defines the sandboxed execution environment for the **Core-Prompts-Hunting** domain, covering all 50 hunting tool and scanner modules. The sandbox enforces security-focused isolation for vulnerability scanning, exploitation testing, and security assessment operations.

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain Name | Core-Prompts-Hunting |
| Sandbox Type | Security Scanner Sandbox |
| Primary Purpose | Isolated execution of security scanning and hunting tools |
| Risk Level | HIGH — active security testing operations |
| Isolation Requirement | Network-restricted, process-monitored |
| Total Domain Files | 50 |
| Sandbox Version | 2.0 |

---

## Isolation Levels

### Level 1 — Passive Analysis (Safe)

Read-only analysis of target configurations and documentation.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | DENIED |
| Process Spawn | DENIED |
| Time Limit | 120 seconds |
| Memory Limit | 256 MB |
| CPU Limit | 1 core |

### Level 2 — Passive Reconnaissance (Moderate)

Passive information gathering without direct target interaction.

| Property | Configuration |
|----------|---------------|
| Network Access | READ-ONLY (public sources only) |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | LIMITED (max 3) |
| Time Limit | 300 seconds |
| Memory Limit | 512 MB |
| CPU Limit | 2 cores |

### Level 3 — Active Scanning (Elevated)

Active vulnerability scanning with target interaction.

| Property | Configuration |
|----------|---------------|
| Network Access | RATE-LIMITED (10 req/s) |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | MONITORED (max 8) |
| Time Limit | 600 seconds |
| Memory Limit | 1 GB |
| CPU Limit | 4 cores |

### Level 4 — Exploitation Testing (Maximum)

Controlled exploitation testing with maximum monitoring.

| Property | Configuration |
|----------|---------------|
| Network Access | CONTROLLED (whitelist-based) |
| Filesystem Write | FULL SANDBOX ACCESS |
| Process Spawn | FULLY MONITORED (max 12) |
| Time Limit | 1200 seconds |
| Memory Limit | 2 GB |
| CPU Limit | 8 cores |

---

## Sandbox Policies

### Filesystem Policy

```yaml
filesystem:
  root: /sandbox/core-prompts-hunting/
  writable_paths:
    - /sandbox/core-prompts-hunting/output/
    - /sandbox/core-prompts-hunting/temp/
    - /sandbox/core-prompts-hunting/findings/
    - /sandbox/core-prompts-hunting/reports/
  read_only_paths:
    - /sandbox/core-prompts-hunting/config/
    - /sandbox/core-prompts-hunting/templates/
    - /sandbox/core-prompts-hunting/wordlists/
    - /sandbox/core-prompts-hunting/payloads/
  denied_paths:
    - /etc/
    - /root/
    - /home/
    - /proc/
    - /sys/
  max_file_size: 100MB
  max_total_storage: 4GB
  allowed_extensions:
    - .txt
    - .json
    - .csv
    - .xml
    - .yaml
    - .yml
    - .md
    - .html
    - .poc
    - .finding
```

### Network Policy

```yaml
network:
  mode: restricted
  default_action: deny
  rules:
    - action: allow
      destination: target_scope
      ports: [80, 443, 8080, 8443]
      rate_limit: 10/s
      protocol: tcp
    - action: allow
      destination: passive_sources
      ports: [443]
      rate_limit: 5/s
      protocol: tcp
    - action: deny
      destination: all
      log: true
  dns:
    resolver: sandbox-dns.internal
    allowed_domains:
      - *.target-scope.com
      - crt.sh
      - dns.bufferover.run
      - hackertarget.com
  proxy:
    enabled: true
    type: http
    address: sandbox-proxy.internal:8080
    logging: full
  vpn:
    enabled: false
```

### Process Policy

```yaml
process:
  max_children: 12
  max_total_processes: 15
  allowed_binaries:
    - /sandbox/bin/scanner
    - /sandbox/bin/hunter
    - /sandbox/bin/tester
    - /sandbox/bin/analyzer
    - /sandbox/bin/reporter
  denied_binaries:
    - /bin/bash
    - /bin/sh
    - /usr/bin/curl
    - /usr/bin/wget
    - /usr/bin/nc
  resource_limits:
    cpu_percent: 80
    memory_mb: 2048
    open_files: 1024
    processes: 15
    threads: 64
  execution:
    timeout: 1200s
    kill_on_timeout: true
    restart_allowed: true
    max_restarts: 2
  user:
    run_as: sandbox-user
    uid: 1006
    gid: 1006
    no_sudo: true
```

### Environment Policy

```yaml
environment:
  inherit: false
  allowed_variables:
    - PATH
    - HOME
    - USER
    - LANG
    - TEMP
    - TMP
    - SANDBOX_ID
    - TARGET_SCOPE
    - SCAN_ID
    - LOG_LEVEL
  blocked_variables:
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - DATABASE_URL
    - PRIVATE_KEY
    - SSH_KEY
  overrides:
    HOME: /sandbox/home
    TEMP: /sandbox/core-prompts-hunting/temp
    PATH: /sandbox/bin:/usr/local/bin:/usr/bin:/bin
    LOG_LEVEL: INFO
```

---

## Policy Enforcement

| Rule ID | Condition | Action | Severity |
|---------|-----------|--------|----------|
| CH-001 | Network request to blocked domain | BLOCK + ALERT | CRITICAL |
| CH-002 | File write to denied path | BLOCK + LOG | HIGH |
| CH-003 | Process spawn exceeds limit | KILL NEWEST | MEDIUM |
| CH-004 | Memory usage exceeds limit | KILL PROCESS | HIGH |
| CH-005 | CPU usage exceeds 80% for 60s | THROTTLE | MEDIUM |
| CH-006 | Execution time exceeds timeout | KILL ALL | HIGH |
| CH-007 | Blocked binary execution attempted | BLOCK + ALERT | CRITICAL |
| CH-008 | Environment variable leak detected | BLOCK + AUDIT | CRITICAL |
| CH-009 | Output contains sensitive patterns | REDACT + LOG | HIGH |
| CH-010 | Rate limit exceeded | THROTTLE + QUEUE | MEDIUM |

---

## Output Capture

```yaml
output_capture:
  enabled: true
  formats:
    - json
    - structured
    - finding_report
  destinations:
    scan_results:
      path: /sandbox/core-prompts-hunting/output/{scan_id}/
      format: json
      retention: 60d
    findings:
      path: /sandbox/core-prompts-hunting/findings/{scan_id}/
      format: json
      retention: 90d
    reports:
      path: /sandbox/core-prompts-hunting/reports/
      format: markdown
      retention: 180d
  sanitization:
    enabled: true
    rules:
      - pattern: 'password\s*[:=]\s*\S+'
        action: redact
      - pattern: 'api[_-]?key\s*[:=]\s*\S+'
        action: redact
      - pattern: 'Bearer\s+[A-Za-z0-9\-._~+/]+=*'
        action: redact
  size_limits:
    max_output_per_scan: 100MB
    max_total_output: 2GB
  compression:
    enabled: true
    algorithm: zstd
  encryption:
    enabled: true
    algorithm: AES-256-GCM
    key_rotation: 24h
```

---

## Execution Recording

```yaml
execution_recording:
  enabled: true
  levels:
    minimal:
      timestamps: true
      scan_result: true
      duration: true
      findings_count: true
    standard:
      timestamps: true
      scan_result: true
      duration: true
      findings_count: true
      resource_usage: true
      network_activity: true
    verbose:
      timestamps: true
      scan_result: true
      duration: true
      findings_count: true
      resource_usage: true
      network_activity: true
      file_operations: true
      process_tree: true
  storage:
    path: /sandbox/core-prompts-hunting/recordings/
    format: jsonl
    compression: zstd
    retention: 90d
    max_size: 5GB
  integrity:
    hash_algorithm: sha256
    chain_verification: true
    tamper_detection: true
```

---

## Domain File References

| # | File | Module | Sandbox Level | Description |
|---|------|--------|---------------|-------------|
| 1 | xss-hunting.md | XSS | Level 3 | Cross-site scripting hunting |
| 2 | sqli-hunting.md | SQLi | Level 3 | SQL injection hunting |
| 3 | ssrf-hunting.md | SSRF | Level 3 | Server-side request forgery hunting |
| 4 | idor-hunting.md | IDOR | Level 3 | Insecure direct object reference hunting |
| 5 | auth-bypass-hunting.md | Auth Bypass | Level 4 | Authentication bypass hunting |
| 6 | csrf-hunting.md | CSRF | Level 3 | Cross-site request forgery hunting |
| 7 | rce-hunting.md | RCE | Level 4 | Remote code execution hunting |
| 8 | lfi-hunting.md | LFI | Level 3 | Local file inclusion hunting |
| 9 | ssti-hunting.md | SSTI | Level 4 | Server-side template injection hunting |
| 10 | xxe-hunting.md | XXE | Level 3 | XML external entity hunting |
| 11 | nosql-hunting.md | NoSQL | Level 3 | NoSQL injection hunting |
| 12 | command-injection.md | Cmdi | Level 4 | Command injection hunting |
| 13 | path-traversal.md | Path Traversal | Level 3 | Path traversal hunting |
| 14 | file-upload.md | File Upload | Level 3 | File upload vulnerability hunting |
| 15 | open-redirect.md | Open Redirect | Level 3 | Open redirect hunting |
| 16 | information-disclosure.md | Info Leak | Level 2 | Information disclosure hunting |
| 17 | error-disclosure.md | Error Leak | Level 2 | Error message disclosure hunting |
| 18 | debug-endpoints.md | Debug | Level 2 | Debug endpoint hunting |
| 19 | default-credentials.md | Defaults | Level 3 | Default credential hunting |
| 20 | api-security.md | API | Level 3 | API security hunting |
| 21 | graphql-hunting.md | GraphQL | Level 3 | GraphQL vulnerability hunting |
| 22 | websocket-hunting.md | WebSocket | Level 3 | WebSocket vulnerability hunting |
| 23 | cors-misconfig.md | CORS | Level 2 | CORS misconfiguration hunting |
| 24 | header-injection.md | Headers | Level 3 | HTTP header injection hunting |
| 25 | cache-poisoning.md | Cache | Level 3 | Cache poisoning hunting |
| 26 | http-smuggling.md | Smuggling | Level 4 | HTTP request smuggling hunting |
| 27 | host-header.md | Host Header | Level 3 | Host header injection hunting |
| 28 | jwt-hunting.md | JWT | Level 3 | JWT vulnerability hunting |
| 29 | oauth-hunting.md | OAuth | Level 3 | OAuth vulnerability hunting |
| 30 | saml-hunting.md | SAML | Level 4 | SAML vulnerability hunting |
| 31 | session-hijack.md | Session | Level 3 | Session hijacking hunting |
| 32 | session-fixation.md | Session Fix | Level 3 | Session fixation hunting |
| 33 | clickjacking.md | Clickjack | Level 2 | Clickjacking hunting |
| 34 | subdomain-takeover.md | Subdomain | Level 3 | Subdomain takeover hunting |
| 35 | dns-rebinding.md | DNS Rebind | Level 3 | DNS rebinding hunting |
| 36 | race-condition.md | Race | Level 3 | Race condition hunting |
| 37 | business-logic.md | Logic | Level 3 | Business logic hunting |
| 38 | privilege-escalation.md | Priv Esc | Level 4 | Privilege escalation hunting |
| 39 | mass-assignment.md | Mass Assign | Level 3 | Mass assignment hunting |
| 40 | prototype-pollution.md | Prototype | Level 3 | Prototype pollution hunting |
| 41 | deserialization.md | Deser | Level 4 | Deserialization hunting |
| 42 | nosql-injection.md | NoSQLi | Level 3 | NoSQL injection hunting |
| 43 | ldap-injection.md | LDAP | Level 3 | LDAP injection hunting |
| 44 | xpath-injection.md | XPath | Level 3 | XPath injection hunting |
| 45 | regex-dos.md | ReDoS | Level 2 | Regular expression DoS hunting |
| 46 | xml-bomb.md | XML Bomb | Level 2 | XML bomb hunting |
| 47 | zip-slip.md | ZIP Slip | Level 3 | ZIP path traversal hunting |
| 48 | csv-injection.md | CSV | Level 3 | CSV injection hunting |
| 49 | formula-injection.md | Formula | Level 3 | Formula injection hunting |
| 50 | hunting-framework.md | Framework | Level 1 | Hunting framework overview |

---

## Configuration YAML — Full Sandbox Definition

```yaml
sandbox:
  name: core-prompts-hunting-sandbox
  version: "2.0"
  domain: core-prompts-hunting
  description: >
    Security scanner sandbox for vulnerability hunting tools.
    Network-restricted, process-monitored, full audit recording.

  container:
    image: sandbox/core-prompts-hunting:2.0
    base: alpine-3.18
    runtime: gvisor
    security:
      seccomp_profile: strict
      capabilities: []
      read_only_rootfs: true
      no_new_privileges: true
      user_namespace: true
      apparmor_profile: sandbox-hunting-aa

  resource_limits:
    cpu:
      shares: 1024
      quota: 400000
      period: 100000
      max_cores: 8
    memory:
      limit: 4Gi
      swap_limit: 0
      oom_kill_disable: false
    disk:
      limit: 20Gi
      read_limit: 100MB/s
      write_limit: 50MB/s
    network:
      bandwidth: 100Mbps
      connections: 100
      sockets: 512

  monitoring:
    metrics:
      interval: 10s
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
