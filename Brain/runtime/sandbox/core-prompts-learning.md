# Core Prompts Learning — Sandboxed Execution Framework

## Domain Overview

This file defines the sandboxed execution environment for the **Core-Prompts-Learning** domain, covering all 50 learning and exercise modules. The sandbox enforces safe isolation for educational exercises, skill development, and knowledge testing operations.

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain Name | Core-Prompts-Learning |
| Sandbox Type | Safe Learning Sandbox |
| Primary Purpose | Isolated execution of learning exercises and skill tests |
| Risk Level | LOW — educational and training operations |
| Isolation Requirement | Safe, controlled environment for learning |
| Total Domain Files | 50 |
| Sandbox Version | 2.0 |

---

## Isolation Levels

### Level 1 — Content Reading (Safe)

Read-only access to learning materials and documentation.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | DENIED |
| Process Spawn | DENIED |
| Time Limit | 600 seconds |
| Memory Limit | 256 MB |
| CPU Limit | 1 core |

### Level 2 — Quiz/Exercise (Safe)

Interactive quizzes and exercises with local validation.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | LIMITED (max 2) |
| Time Limit | 900 seconds |
| Memory Limit | 512 MB |
| CPU Limit | 2 cores |

### Level 3 — Lab Environment (Controlled)

Simulated lab environments for hands-on practice.

| Property | Configuration |
|----------|---------------|
| Network Access | INTERNAL ONLY (lab network) |
| Filesystem Write | FULL SANDBOX ACCESS |
| Process Spawn | MONITORED (max 5) |
| Time Limit | 1800 seconds |
| Memory Limit | 1 GB |
| CPU Limit | 4 cores |

### Level 4 — Advanced Lab (Maximum)

Complex lab environments with multiple components.

| Property | Configuration |
|----------|---------------|
| Network Access | INTERNAL ONLY (multi-host lab) |
| Filesystem Write | FULL SANDBOX ACCESS |
| Process Spawn | FULLY MONITORED (max 10) |
| Time Limit | 3600 seconds |
| Memory Limit | 2 GB |
| CPU Limit | 8 cores |

---

## Sandbox Policies

### Filesystem Policy

```yaml
filesystem:
  root: /sandbox/core-prompts-learning/
  writable_paths:
    - /sandbox/core-prompts-learning/output/
    - /sandbox/core-prompts-learning/temp/
    - /sandbox/core-prompts-learning/exercises/
    - /sandbox/core-prompts-learning/solutions/
    - /sandbox/core-prompts-learning/labs/
  read_only_paths:
    - /sandbox/core-prompts-learning/config/
    - /sandbox/core-prompts-learning/materials/
    - /sandbox/core-prompts-learning/references/
    - /sandbox/core-prompts-learning/templates/
  denied_paths:
    - /etc/
    - /root/
    - /home/
    - /proc/
    - /sys/
  max_file_size: 50MB
  max_total_storage: 2GB
  allowed_extensions:
    - .txt
    - .json
    - .csv
    - .xml
    - .yaml
    - .yml
    - .md
    - .html
    - .py
    - .js
    - .sh
    - .sql
```

### Network Policy

```yaml
network:
  mode: internal_only
  default_action: deny
  rules:
    - action: allow
      destination: lab_network
      ports: [80, 443, 8080, 8443, 3306, 5432, 6379, 27017]
      rate_limit: 50/s
      protocol: tcp
    - action: deny
      destination: external
      log: true
  lab_network:
    enabled: true
    subnet: 172.28.0.0/16
    hosts:
      - name: lab-web
        ip: 172.28.0.10
        ports: [80, 443]
      - name: lab-db
        ip: 172.28.0.20
        ports: [3306, 5432]
      - name: lab-cache
        ip: 172.28.0.30
        ports: [6379]
  dns:
    resolver: lab-dns.internal
    logging: full
  proxy:
    enabled: false
```

### Process Policy

```yaml
process:
  max_children: 10
  max_total_processes: 12
  allowed_binaries:
    - /sandbox/bin/exercise-runner
    - /sandbox/bin/lab-manager
    - /sandbox/bin/validator
    - /sandbox/bin/evaluator
    - /sandbox/bin/python3
    - /sandbox/bin/node
  resource_limits:
    cpu_percent: 70
    memory_mb: 2048
    open_files: 512
    processes: 12
    threads: 64
  execution:
    timeout: 3600s
    kill_on_timeout: true
    restart_allowed: true
    max_restarts: 5
  user:
    run_as: sandbox-user
    uid: 1007
    gid: 1007
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
    - EXERCISE_ID
    - LAB_ID
    - LOG_LEVEL
    - PYTHONPATH
    - NODE_PATH
  blocked_variables:
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - DATABASE_URL
    - PRIVATE_KEY
    - SSH_KEY
  overrides:
    HOME: /sandbox/home
    TEMP: /sandbox/core-prompts-learning/temp
    PATH: /sandbox/bin:/usr/local/bin:/usr/bin:/bin
    LOG_LEVEL: INFO
    PYTHONPATH: /sandbox/lib/python3
    NODE_PATH: /sandbox/lib/node
```

---

## Policy Enforcement

| Rule ID | Condition | Action | Severity |
|---------|-----------|--------|----------|
| CL-001 | External network request attempted | BLOCK + LOG | MEDIUM |
| CL-002 | File write to denied path | BLOCK + LOG | MEDIUM |
| CL-003 | Process spawn exceeds limit | KILL NEWEST | LOW |
| CL-004 | Memory usage exceeds limit | KILL PROCESS | MEDIUM |
| CL-005 | Execution time exceeds timeout | KILL + LOG | LOW |
| CL-006 | Blocked binary execution | BLOCK + LOG | MEDIUM |
| CL-007 | Lab host unreachable | RETRY + LOG | LOW |
| CL-008 | Output contains sensitive patterns | REDACT + LOG | MEDIUM |
| CL-009 | Exercise validation fails | LOG + CONTINUE | LOW |
| CL-010 | Resource usage spike | THROTTLE + LOG | LOW |

---

## Output Capture

```yaml
output_capture:
  enabled: true
  formats:
    - json
    - markdown
    - progress_report
  destinations:
    exercise_results:
      path: /sandbox/core-prompts-learning/output/{exercise_id}/
      format: json
      retention: 30d
    lab_results:
      path: /sandbox/core-prompts-learning/output/labs/{lab_id}/
      format: json
      retention: 60d
    progress:
      path: /sandbox/core-prompts-learning/output/progress/
      format: json
      retention: 90d
  sanitization:
    enabled: true
    rules:
      - pattern: 'password\s*[:=]\s*\S+'
        action: redact
  size_limits:
    max_output_per_exercise: 20MB
    max_total_output: 1GB
  compression:
    enabled: true
    algorithm: gzip
  encryption:
    enabled: false
```

---

## Execution Recording

```yaml
execution_recording:
  enabled: true
  levels:
    minimal:
      timestamps: true
      exercise_result: true
      score: true
      duration: true
    standard:
      timestamps: true
      exercise_result: true
      score: true
      duration: true
      resource_usage: true
      attempts: true
    verbose:
      timestamps: true
      exercise_result: true
      score: true
      duration: true
      resource_usage: true
      attempts: true
      input_commands: true
      output_results: true
      learning_path: true
  storage:
    path: /sandbox/core-prompts-learning/recordings/
    format: jsonl
    compression: gzip
    retention: 90d
    max_size: 2GB
  integrity:
    hash_algorithm: sha256
    chain_verification: false
```

---

## Domain File References

| # | File | Module | Sandbox Level | Description |
|---|------|--------|---------------|-------------|
| 1 | web-security-basics.md | Web Basics | Level 1 | Web security fundamentals |
| 2 | owasp-top10.md | OWASP | Level 1 | OWASP Top 10 learning |
| 3 | xss-exercises.md | XSS | Level 3 | XSS practical exercises |
| 4 | sqli-exercises.md | SQLi | Level 3 | SQL injection exercises |
| 5 | ssrf-exercises.md | SSRF | Level 3 | SSRF practical exercises |
| 6 | idor-exercises.md | IDOR | Level 3 | IDOR practical exercises |
| 7 | auth-exercises.md | Auth | Level 3 | Authentication security exercises |
| 8 | api-security-basics.md | API | Level 1 | API security fundamentals |
| 9 | cryptography-basics.md | Crypto | Level 1 | Cryptography fundamentals |
| 10 | network-security.md | Network | Level 1 | Network security basics |
| 11 | linux-privilege-escalation.md | Linux PrivEsc | Level 3 | Linux privilege escalation exercises |
| 12 | windows-privilege-escalation.md | Windows PrivEsc | Level 3 | Windows privilege escalation exercises |
| 13 | web-application-testing.md | Web App | Level 3 | Web application testing exercises |
| 14 | mobile-security.md | Mobile | Level 3 | Mobile security exercises |
| 15 | cloud-security.md | Cloud | Level 3 | Cloud security exercises |
| 16 | container-security.md | Container | Level 3 | Container security exercises |
| 17 | kubernetes-security.md | K8s | Level 3 | Kubernetes security exercises |
| 18 | dns-security.md | DNS | Level 1 | DNS security fundamentals |
| 19 | tls-ssl-basics.md | TLS/SSL | Level 1 | TLS/SSL security fundamentals |
| 20 | http-security.md | HTTP | Level 1 | HTTP security fundamentals |
| 21 | browser-security.md | Browser | Level 1 | Browser security fundamentals |
| 22 | session-management.md | Session | Level 1 | Session management learning |
| 23 | cookie-security.md | Cookie | Level 1 | Cookie security learning |
| 24 | header-security.md | Headers | Level 1 | HTTP header security |
| 25 | cors-learning.md | CORS | Level 1 | CORS security learning |
| 26 | csrf-learning.md | CSRF | Level 1 | CSRF security learning |
| 27 | clickjacking-learning.md | Clickjack | Level 1 | Clickjacking security learning |
| 28 | redirect-security.md | Redirect | Level 1 | Redirect security learning |
| 29 | file-upload-security.md | Upload | Level 1 | File upload security learning |
| 30 | input-validation.md | Validation | Level 1 | Input validation learning |
| 31 | output-encoding.md | Encoding | Level 1 | Output encoding learning |
| 32 | sql-prevention.md | SQL Prevent | Level 1 | SQL injection prevention |
| 33 | xss-prevention.md | XSS Prevent | Level 1 | XSS prevention techniques |
| 34 | ssrf-prevention.md | SSRF Prevent | Level 1 | SSRF prevention techniques |
| 35 | command-injection-prevention.md | Cmdi Prevent | Level 1 | Command injection prevention |
| 36 | path-traversal-prevention.md | Path Prevent | Level 1 | Path traversal prevention |
| 37 | deserialization-security.md | Deser | Level 1 | Deserialization security learning |
| 38 | xml-security.md | XML | Level 1 | XML security learning |
| 39 | json-security.md | JSON | Level 1 | JSON security learning |
| 40 | yaml-security.md | YAML | Level | YAML security learning |
| 41 | regex-security.md | Regex | Level 1 | Regex security learning |
| 42 | logging-security.md | Logging | Level 1 | Security logging learning |
| 43 | monitoring-security.md | Monitoring | Level 1 | Security monitoring learning |
| 44 | incident-response.md | IR | Level 1 | Incident response learning |
| 45 | forensics-basics.md | Forensics | Level 1 | Digital forensics learning |
| 46 | malware-analysis.md | Malware | Level 1 | Malware analysis learning |
| 47 | reverse-engineering.md | RE | Level 1 | Reverse engineering learning |
| 48 | binary-exploitation.md | Binary | Level 1 | Binary exploitation learning |
| 49 | web-security-advanced.md | Web Advanced | Level 1 | Advanced web security |
| 50 | learning-framework.md | Framework | Level 1 | Learning framework overview |

---

## Configuration YAML — Full Sandbox Definition

```yaml
sandbox:
  name: core-prompts-learning-sandbox
  version: "2.0"
  domain: core-prompts-learning
  description: >
    Safe learning sandbox for educational exercises and skill development.
    Internal lab network, controlled process execution, full progress tracking.

  container:
    image: sandbox/core-prompts-learning:2.0
    base: alpine-3.18
    runtime: gvisor
    security:
      seccomp_profile: default
      capabilities: [CHOWN, SETGID, SETUID]
      read_only_rootfs: false
      no_new_privileges: true
      user_namespace: true

  resource_limits:
    cpu:
      shares: 1024
      quota: 400000
      period: 100000
      max_cores: 8
    memory:
      limit: 4Gi
      swap_limit: 1Gi
      oom_kill_disable: false
    disk:
      limit: 20Gi
      read_limit: 100MB/s
      write_limit: 50MB/s
    network:
      bandwidth: 100Mbps
      connections: 100
      sockets: 256

  lab_environment:
    enabled: true
    max_hosts: 5
    host_images:
      - lab-web:latest
      - lab-db:latest
      - lab-cache:latest
    network_mode: bridge
    persistence: none

  monitoring:
    metrics:
      interval: 30s
      exporters:
        - prometheus
        - json_file
    alerts:
      channels:
        - type: log
          level: WARNING
    progress_tracking:
      enabled: true
      granularity: per_exercise
      export: true
```
