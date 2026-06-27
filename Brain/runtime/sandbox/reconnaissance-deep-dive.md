# Reconnaissance Deep Dive — Sandboxed Execution Framework

## Domain Overview

This file defines the sandboxed execution environment for the **Reconnaissance-Deep-Dive** domain, covering all 50 reconnaissance and information gathering modules. The sandbox enforces network-restricted isolation for reconnaissance operations, ensuring controlled target interaction and comprehensive audit recording.

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain Name | Reconnaissance-Deep-Dive |
| Sandbox Type | Network-Restricted Sandbox |
| Primary Purpose | Isolated execution of reconnaissance and OSINT operations |
| Risk Level | MEDIUM — network interaction with external targets |
| Isolation Requirement | Network-restricted, rate-limited, monitored |
| Total Domain Files | 50 |
| Sandbox Version | 2.0 |

---

## Isolation Levels

### Level 1 — Passive Reconnaissance (Safe)

Read-only analysis of pre-gathered intelligence data.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | DENIED |
| Process Spawn | DENIED |
| Time Limit | 120 seconds |
| Memory Limit | 256 MB |
| CPU Limit | 1 core |

### Level 2 — OSINT Collection (Moderate)

Open-source intelligence gathering from public sources.

| Property | Configuration |
|----------|---------------|
| Network Access | READ-ONLY (public sources) |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | LIMITED (max 3) |
| Time Limit | 300 seconds |
| Memory Limit | 512 MB |
| CPU Limit | 2 cores |

### Level 3 — Active Reconnaissance (Elevated)

Active information gathering with target interaction.

| Property | Configuration |
|----------|---------------|
| Network Access | RATE-LIMITED (5 req/s) |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | MONITORED (max 8) |
| Time Limit | 600 seconds |
| Memory Limit | 1 GB |
| CPU Limit | 4 cores |

### Level 4 — Deep Reconnaissance (Maximum)

Comprehensive reconnaissance with multi-source correlation.

| Property | Configuration |
|----------|---------------|
| Network Access | CONTROLLED (whitelist-based, 10 req/s) |
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
  root: /sandbox/recon-deep-dive/
  writable_paths:
    - /sandbox/recon-deep-dive/output/
    - /sandbox/recon-deep-dive/temp/
    - /sandbox/recon-deep-dive/intelligence/
    - /sandbox/recon-deep-dive/reports/
  read_only_paths:
    - /sandbox/recon-deep-dive/config/
    - /sandbox/recon-deep-dive/templates/
    - /sandbox/recon-deep-dive/wordlists/
    - /sandbox/recon-deep-dive/reference/
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
    - .gz
    - .zip
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
      rate_limit: 5/s
      protocol: tcp
    - action: allow
      destination: osint_sources
      ports: [443]
      rate_limit: 10/s
      protocol: tcp
    - action: allow
      destination: dns_servers
      ports: [53]
      protocol: udp
    - action: deny
      destination: all
      log: true
  osint_sources:
    allowed:
      - crt.sh
      - hackertarget.com
      - dns.bufferover.run
      - api.hackertarget.com
      - viewdns.info
      - securitytrails.com
      - shodan.io
      - censys.io
      - github.com
      - gitlab.com
      - bitbucket.org
      - pastebin.com
  blocked:
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
    - /sandbox/bin/recon-tool
    - /sandbox/bin/enumerator
    - /sandbox/bin/crawler
    - /sandbox/bin/analyzer
    - /sandbox/bin/correlator
    - /sandbox/bin/reporter
  denied_binaries:
    - /bin/bash
    - /bin/sh
    - /usr/bin/nc
    - /usr/bin/python3
  resource_limits:
    cpu_percent: 70
    memory_mb: 2048
    open_files: 1024
    processes: 15
    threads: 64
  execution:
    timeout: 1200s
    kill_on_timeout: true
    restart_allowed: true
    max_restarts: 3
  user:
    run_as: sandbox-user
    uid: 1010
    gid: 1010
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
    - RECON_ID
    - LOG_LEVEL
    - USER_AGENT
    - API_KEY
  blocked_variables:
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - DATABASE_URL
    - PRIVATE_KEY
    - SSH_KEY
  overrides:
    HOME: /sandbox/home
    TEMP: /sandbox/recon-deep-dive/temp
    PATH: /sandbox/bin:/usr/local/bin:/usr/bin:/bin
    LOG_LEVEL: INFO
    USER_AGENT: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```

---

## Policy Enforcement

| Rule ID | Condition | Action | Severity |
|---------|-----------|--------|----------|
| RD-001 | Network request to blocked domain | BLOCK + ALERT | HIGH |
| RD-002 | Rate limit exceeded | THROTTLE + QUEUE | MEDIUM |
| RD-003 | Process spawn exceeds limit | KILL NEWEST | MEDIUM |
| RD-004 | Memory usage exceeds limit | KILL PROCESS | HIGH |
| RD-005 | CPU usage exceeds 70% for 60s | THROTTLE | MEDIUM |
| RD-006 | Execution time exceeds timeout | KILL ALL | HIGH |
| RD-007 | File write to denied path | BLOCK + LOG | HIGH |
| RD-008 | Environment variable leak detected | BLOCK + AUDIT | CRITICAL |
| RD-009 | Output contains sensitive patterns | REDACT + LOG | HIGH |
| RD-010 | Private IP range accessed | BLOCK + ALERT | HIGH |

---

## Output Capture

```yaml
output_capture:
  enabled: true
  formats:
    - json
    - structured
    - intelligence_report
  destinations:
    recon_results:
      path: /sandbox/recon-deep-dive/output/{recon_id}/
      format: json
      retention: 60d
    intelligence:
      path: /sandbox/recon-deep-dive/intelligence/{recon_id}/
      format: structured
      retention: 90d
    reports:
      path: /sandbox/recon-deep-dive/reports/
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
      - pattern: '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
        action: partial_redact
  size_limits:
    max_output_per_recon: 100MB
    max_total_output: 4GB
  compression:
    enabled: true
    algorithm: zstd
    level: 3
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
      recon_result: true
      duration: true
      assets_found: true
    standard:
      timestamps: true
      recon_result: true
      duration: true
      assets_found: true
      resource_usage: true
      network_activity: true
    verbose:
      timestamps: true
      recon_result: true
      duration: true
      assets_found: true
      resource_usage: true
      network_activity: true
      dns_queries: true
      http_requests: true
      file_operations: true
  storage:
    path: /sandbox/recon-deep-dive/recordings/
    format: jsonl
    compression: zstd
    retention: 90d
    max_size: 10GB
  integrity:
    hash_algorithm: sha256
    chain_verification: true
    tamper_detection: true
```

---

## Domain File References

| # | File | Module | Sandbox Level | Description |
|---|------|--------|---------------|-------------|
| 1 | subdomain-enum.md | Subdomain | Level 3 | Subdomain enumeration |
| 2 | dns-enum.md | DNS | Level 3 | DNS enumeration |
| 3 | passive-recon.md | Passive | Level 2 | Passive reconnaissance |
| 4 | active-recon.md | Active | Level 3 | Active reconnaissance |
| 5 | osint-collection.md | OSINT | Level 2 | OSINT data collection |
| 6 | email-harvesting.md | Email | Level 3 | Email address harvesting |
| 7 | social-media-recon.md | Social Media | Level 2 | Social media reconnaissance |
| 8 | github-recon.md | GitHub | Level 2 | GitHub reconnaissance |
| 9 | gitlab-recon.md | GitLab | Level 2 | GitLab reconnaissance |
| 10 | pastebin-recon.md | Pastebin | Level 2 | Pastebin reconnaissance |
| 11 | whois-lookup.md | WHOIS | Level 2 | WHOIS lookup |
| 12 | ip-intelligence.md | IP Intel | Level 2 | IP address intelligence |
| 13 | asn-enumeration.md | ASN | Level 2 | ASN enumeration |
| 14 | cidr-mapping.md | CIDR | Level 2 | CIDR range mapping |
| 15 | technology-fingerprint.md | Fingerprint | Level 3 | Technology fingerprinting |
| 16 | waf-detection.md | WAF | Level 3 | WAF detection |
| 17 | cdn-detection.md | CDN | Level 2 | CDN detection |
| 18 | hosting-detection.md | Hosting | Level 2 | Hosting provider detection |
| 19 | ssl-tls-analysis.md | SSL/TLS | Level 2 | SSL/TLS certificate analysis |
| 20 | certificate-transparency.md | CT | Level 2 | Certificate transparency logs |
| 21 | port-scanning.md | Ports | Level 3 | Port scanning |
| 22 | service-detection.md | Services | Level 3 | Service version detection |
| 23 | banner-grabbing.md | Banner | Level 3 | Banner grabbing |
| 24 | web-crawling.md | Crawl | Level 3 | Web crawling |
| 25 | url-discovery.md | URLs | Level 2 | URL discovery |
| 26 | parameter-discovery.md | Params | Level 2 | Parameter discovery |
| 27 | api-discovery.md | API | Level 2 | API endpoint discovery |
| 28 | swagger-discovery.md | Swagger | Level 2 | Swagger/OpenAPI discovery |
| 29 | graphql-discovery.md | GraphQL | Level 2 | GraphQL endpoint discovery |
| 30 | js-analysis.md | JavaScript | Level 2 | JavaScript file analysis |
| 31 | source-code-recon.md | Source | Level 2 | Source code reconnaissance |
| 32 | dependency-analysis.md | Dependencies | Level 2 | Dependency analysis |
| 33 | cloud-storage.md | Cloud | Level 2 | Cloud storage discovery |
| 34 | s3-bucket-enum.md | S3 | Level 3 | S3 bucket enumeration |
| 35 | gcs-bucket-enum.md | GCS | Level 3 | GCS bucket enumeration |
| 36 | azure-blob-enum.md | Azure Blob | Level 3 | Azure blob enumeration |
| 37 | kubernetes-enum.md | Kubernetes | Level 3 | Kubernetes enumeration |
| 38 | docker-enum.md | Docker | Level 3 | Docker enumeration |
| 39 | ci-cd-discovery.md | CI/CD | Level 2 | CI/CD pipeline discovery |
| 40 | credential-leak.md | Credentials | Level 2 | Credential leak detection |
| 41 | breach-database.md | Breaches | Level 2 | Breach database lookup |
| 42 | dark-web-recon.md | Dark Web | Level 2 | Dark web reconnaissance |
| 43 | threat-intelligence.md | Threat Intel | Level 2 | Threat intelligence gathering |
| 44 | ioc-collection.md | IOCs | Level 2 | IOC collection |
| 45 | attack-surface.md | Surface | Level 2 | Attack surface mapping |
| 46 | asset-correlation.md | Correlate | Level 2 | Asset correlation |
| 47 | vulnerability-mapping.md | Vuln Map | Level 3 | Vulnerability mapping |
| 48 | risk-scoring.md | Risk Score | Level 2 | Risk scoring |
| 49 | recon-report.md | Report | Level 2 | Reconnaissance reporting |
| 50 | recon-framework.md | Framework | Level 1 | Reconnaissance framework |

---

## Configuration YAML — Full Sandbox Definition

```yaml
sandbox:
  name: recon-deep-dive-sandbox
  version: "2.0"
  domain: reconnaissance-deep-dive
  description: >
    Network-restricted sandbox for reconnaissance and OSINT operations.
    Controlled target interaction, rate-limited, full audit recording.

  container:
    image: sandbox/recon-deep-dive:2.0
    base: alpine-3.18
    runtime: gvisor
    security:
      seccomp_profile: strict
      capabilities: []
      read_only_rootfs: true
      no_new_privileges: true
      user_namespace: true
      apparmor_profile: sandbox-recon-aa

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
