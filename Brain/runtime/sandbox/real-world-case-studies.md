# Real-World Case Studies — Sandboxed Execution Framework

## Domain Overview

This file defines the sandboxed execution environment for the **Real-World-Case-Studies** domain, covering all 50 disclosed vulnerability case study modules. The sandbox enforces read-only isolation for disclosed vulnerability analysis, exploitation pattern study, and defensive technique evaluation.

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain Name | Real-World-Case-Studies |
| Sandbox Type | Read-Only Analysis Sandbox |
| Primary Purpose | Isolated analysis of disclosed vulnerability case studies |
| Risk Level | LOW — read-only analytical operations |
| Isolation Requirement | Read-only, no exploitation execution |
| Total Domain Files | 50 |
| Sandbox Version | 2.0 |

---

## Isolation Levels

### Level 1 — Document Reading (Safe)

Read-only access to case study documentation and reports.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | DENIED |
| Process Spawn | DENIED |
| Time Limit | 300 seconds |
| Memory Limit | 256 MB |
| CPU Limit | 1 core |

### Level 2 — Vulnerability Analysis (Controlled)

Analysis of vulnerability patterns and exploitation techniques.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | LIMITED (max 3) |
| Time Limit | 600 seconds |
| Memory Limit | 512 MB |
| CPU Limit | 2 cores |

### Level 3 — Exploitation Pattern Study (Elevated)

Study of exploitation patterns with safe simulation.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | MONITORED (max 5) |
| Time Limit | 900 seconds |
| Memory Limit | 1 GB |
| CPU Limit | 4 cores |

### Level 4 — Comprehensive Case Study (Maximum)

Full case study analysis with cross-referencing and pattern matching.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | FULLY MONITORED (max 8) |
| Time Limit | 1800 seconds |
| Memory Limit | 2 GB |
| CPU Limit | 8 cores |

---

## Sandbox Policies

### Filesystem Policy

```yaml
filesystem:
  root: /sandbox/real-world-case-studies/
  writable_paths:
    - /sandbox/real-world-case-studies/output/
    - /sandbox/real-world-case-studies/temp/
    - /sandbox/real-world-case-studies/analysis/
    - /sandbox/real-world-case-studies/reports/
  read_only_paths:
    - /sandbox/real-world-case-studies/config/
    - /sandbox/real-world-case-studies/case-studies/
    - /sandbox/real-world-case-studies/disclosures/
    - /sandbox/real-world-case-studies/references/
    - /sandbox/real-world-case-studies/templates/
  denied_paths:
    - /etc/
    - /root/
    - /home/
    - /proc/
    - /sys/
  max_file_size: 50MB
  max_total_storage: 3GB
  allowed_extensions:
    - .txt
    - .json
    - .csv
    - .xml
    - .yaml
    - .yml
    - .md
    - .html
    - .pdf
    - .png
    - .jpg
    - .svg
```

### Network Policy

```yaml
network:
  mode: disabled
  default_action: deny
  rules:
    - action: deny
      destination: all
      log: false
  description: >
    Network access is completely disabled. All case study materials
    are pre-loaded into the sandbox.
```

### Process Policy

```yaml
process:
  max_children: 8
  max_total_processes: 10
  allowed_binaries:
    - /sandbox/bin/analyzer
    - /sandbox/bin/pattern-matcher
    - /sandbox/bin/reporter
    - /sandbox/bin/searcher
  resource_limits:
    cpu_percent: 60
    memory_mb: 2048
    open_files: 512
    processes: 10
    threads: 32
  execution:
    timeout: 1800s
    kill_on_timeout: true
    restart_allowed: true
    max_restarts: 2
  user:
    run_as: sandbox-user
    uid: 1009
    gid: 1009
    no_sudo: true
```

---

## Policy Enforcement

| Rule ID | Condition | Action | Severity |
|---------|-----------|--------|----------|
| RW-001 | Write attempt to non-sandbox path | BLOCK + LOG | MEDIUM |
| RW-002 | Process exceeds resource limit | KILL + LOG | MEDIUM |
| RW-003 | Execution time exceeds timeout | KILL + LOG | MEDIUM |
| RW-004 | Unauthorized binary execution | BLOCK + LOG | MEDIUM |
| RW-005 | Output contains sensitive patterns | REDACT + LOG | MEDIUM |
| RW-006 | Memory usage exceeds 80% | WARN + LOG | LOW |
| RW-007 | CPU usage exceeds 80% for 60s | THROTTLE + LOG | LOW |
| RW-008 | Output validation fails | REJECT + LOG | LOW |
| RW-009 | Audit trail gap detected | LOG + CONTINUE | LOW |
| RW-010 | Case study access outside scope | BLOCK + LOG | MEDIUM |

---

## Output Capture

```yaml
output_capture:
  enabled: true
  formats:
    - json
    - markdown
    - analysis_report
  destinations:
    analysis:
      path: /sandbox/real-world-case-studies/analysis/{study_id}/
      format: json
      retention: 90d
    reports:
      path: /sandbox/real-world-case-studies/reports/
      format: markdown
      retention: 180d
  sanitization:
    enabled: true
    rules:
      - pattern: 'password\s*[:=]\s*\S+'
        action: redact
      - pattern: 'api[_-]?key\s*[:=]\s*\S+'
        action: redact
  size_limits:
    max_output_per_analysis: 20MB
    max_total_output: 1GB
  compression:
    enabled: true
    algorithm: gzip
  encryption:
    enabled: true
    algorithm: AES-256-GCM
```

---

## Execution Recording

```yaml
execution_recording:
  enabled: true
  levels:
    minimal:
      timestamps: true
      analysis_result: true
      duration: true
    standard:
      timestamps: true
      analysis_result: true
      duration: true
      resource_usage: true
      findings: true
    verbose:
      timestamps: true
      analysis_result: true
      duration: true
      resource_usage: true
      findings: true
      patterns_matched: true
      exploitation_techniques: true
      defensive_measures: true
  storage:
    path: /sandbox/real-world-case-studies/recordings/
    format: jsonl
    compression: gzip
    retention: 180d
    max_size: 2GB
  integrity:
    hash_algorithm: sha256
    chain_verification: true
```

---

## Domain File References

| # | File | Module | Sandbox Level | Description |
|---|------|--------|---------------|-------------|
| 1 | cve-2021-44228-log4j.md | Log4j | Level 2 | Log4Shell CVE-2021-44228 |
| 2 | cve-2021-26855-proxylogon.md | ProxyLogon | Level 2 | Exchange ProxyLogon |
| 3 | cve-2021-27065-proxyshell.md | ProxyShell | Level 2 | Exchange ProxyShell |
| 4 | cve-2021-21972-vrealize.md | vRealize | Level 2 | VMware vRealize RCE |
| 5 | cve-2021-21985-vsan.md | vSAN | Level 2 | VMware vSAN RCE |
| 6 | cve-2022-22954-workspace.md | Workspace | Level 2 | Workspace ONE SSTI |
| 7 | cve-2023-20887-aria.md | Aria | Level 2 | Aria Operations RCE |
| 8 | cve-2024-37085-esxi.md | ESXi | Level 2 | ESXi AD bypass |
| 9 | cve-2024-22273-aria-ssrf.md | Aria SSRF | Level 2 | Aria Operations SSRF |
| 10 | cve-2023-44487-http2.md | HTTP/2 | Level 2 | HTTP/2 rapid reset |
| 11 | cve-2023-4966-citrix.md | Citrix | Level 2 | Citrix NetScaler breach |
| 12 | cve-2023-27997-fortigate.md | FortiGate | Level 2 | FortiGate SSL-VPN RCE |
| 13 | cve-2023-20198-cisco.md | Cisco | Level 2 | Cisco IOS XE WLC |
| 14 | cve-2023-46805-ivanti.md | Ivanti | Level 2 | Ivanti Connect Secure |
| 15 | cve-2024-21887-ivanti.md | Ivanti 2 | Level 2 | Ivanti command injection |
| 16 | cve-2023-44228-log4j2.md | Log4j 2 | Level 2 | Log4Shell analysis |
| 17 | cve-2022-0543-snapmirror.md | SnapMirror | Level 2 | NetApp SnapMirror |
| 18 | cve-2022-1388-f5.md | F5 | Level 2 | F5 BIG-IP iControl |
| 19 | cve-2022-22965-spring4shell.md | Spring4Shell | Level 2 | Spring Framework RCE |
| 20 | cve-2022-26134-confluence.md | Confluence | Level 2 | Confluence OGNL injection |
| 21 | cve-2022-40684-fortios.md | FortiOS | Level 2 | FortiOS auth bypass |
| 22 | cve-2023-23397-outlook.md | Outlook | Level 2 | Outlook privilege escalation |
| 23 | cve-2023-22515-confluence.md | Confluence 2 | Level 2 | Confluence privilege escalation |
| 24 | cve-2023-34362-moveit.md | MOVEit | Level 2 | MOVEit SQL injection |
| 25 | cve-2023-27350-papercut.md | PaperCut | Level 2 | PaperCut RCE |
| 26 | cve-2023-29357-sharepoint.md | SharePoint | Level 2 | SharePoint privilege escalation |
| 27 | cve-2023-36884-office.md | Office | Level 2 | Office HTML RCE |
| 28 | cve-2023-38831-winrar.md | WinRAR | Level 2 | WinRAR code execution |
| 29 | cve-2023-46747-f5.md | F5 2 | Level 2 | F5 BIG-IP auth bypass |
| 30 | cve-2023-4911-loony-tunables.md | Loony | Level 2 | glibc Loony Tunables |
| 31 | cve-2024-1709-connectwise.md | ConnectWise | Level 2 | ConnectWise ScreenConnect |
| 32 | cve-2024-20353-cisco.md | Cisco 2 | Level 2 | Cisco ASA/FTD DoS |
| 33 | cve-2024-21413-outlook.md | Outlook 2 | Level 2 | Outlook RCE |
| 34 | cve-2024-23897-jenkins.md | Jenkins | Level 2 | Jenkins arbitrary file read |
| 35 | cve-2024-28986-solarwinds.md | SolarWinds | Level 2 | SolarWinds RCE |
| 36 | cve-2024-3094-xz.md | XZ Utils | Level 2 | XZ backdoor |
| 37 | cve-2024-6387-openssh.md | OpenSSH | Level 2 | OpenSSH regreSSHion |
| 38 | cve-2024-21893-ivanti.md | Ivanti 3 | Level 2 | Ivanti SSRF |
| 39 | cve-2024-23899-papercut.md | PaperCut 2 | Level 2 | PaperCut information disclosure |
| 40 | cve-2024-27198-jetbrains.md | JetBrains | Level 2 | JetBrains TeamCity bypass |
| 41 | cve-2024-4577-php.md | PHP | Level 2 | PHP CGI argument injection |
| 42 | cve-2024-5274-chrome.md | Chrome | Level 2 | Chrome V8 type confusion |
| 43 | cve-2024-38063-windows.md | Windows | Level 2 | Windows TCP/IP RCE |
| 44 | cve-2024-47176-cups.md | CUPS | Level 2 | CUPS printing RCE |
| 45 | cve-2024-53677-struts.md | Struts | Level 2 | Apache Struts file upload |
| 46 | cve-2024-43451-windows.md | Windows 2 | Level 2 | Windows MSHTML spoofing |
| 47 | case-study-h1-reports.md | H1 Reports | Level 2 | HackerOne disclosed reports |
| 48 | case-study-bugcrowd.md | Bugcrowd | Level 2 | Bugcrowd disclosed reports |
| 49 | case-study-intigriti.md | Intigriti | Level 2 | Intigriti disclosed reports |
| 50 | case-study-framework.md | Framework | Level 1 | Case study framework |

---

## Configuration YAML — Full Sandbox Definition

```yaml
sandbox:
  name: real-world-case-studies-sandbox
  version: "2.0"
  domain: real-world-case-studies
  description: >
    Read-only sandbox for disclosed vulnerability case study analysis.
    No network access, all materials pre-loaded.

  container:
    image: sandbox/real-world-case-studies:2.0
    base: alpine-3.18
    runtime: runc
    security:
      seccomp_profile: default
      capabilities: [CHOWN, SETGID, SETUID]
      read_only_rootfs: false
      no_new_privileges: true

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
      bandwidth: 0
      connections: 0
      sockets: 0

  monitoring:
    metrics:
      interval: 60s
      exporters:
        - json_file
    alerts:
      channels:
        - type: log
          level: WARNING
```

---

## Sandbox Startup Sequence

```yaml
startup:
  phases:
    - name: environment_preparation
      timeout: 60s
      steps:
        - verify_sandbox_images
        - mount_read_only_resources
        - initialize_logging
        - start_monitoring_agents
    - name: policy_loading
      timeout: 15s
      steps:
        - load_filesystem_policy
        - load_process_policy
        - validate_policy_syntax
        - enable_enforcement
    - name: recording_initialization
      timeout: 10s
      steps:
        - initialize_recording_streams
        - setup_integrity_checks
        - configure_audit_trail
    - name: readiness_check
      timeout: 5s
      steps:
        - verify_all_policies_loaded
        - verify_enforcement_active
        - report_sandbox_ready
```

---

## Sandbox Teardown Sequence

```yaml
teardown:
  phases:
    - name: graceful_shutdown
      timeout: 30s
      steps:
        - signal_all_processes
        - wait_for_completion
        - flush_output_buffers
        - finalize_recordings
    - name: data_collection
      timeout: 60s
      steps:
        - collect_all_outputs
        - collect_all_logs
        - compress_artifacts
        - generate_summary
    - name: cleanup
      timeout: 30s
      steps:
        - remove_temp_files
        - clear_environment
        - destroy_container
    - name: verification
      timeout: 10s
      steps:
        - verify_data_integrity
        - verify_audit_trail_complete
        - report_teardown_complete
```

---

## Error Handling

```yaml
error_handling:
  retry_policy:
    max_retries: 2
    backoff_multiplier: 2
    initial_delay: 1s
    max_delay: 15s
  circuit_breaker:
    enabled: true
    failure_threshold: 3
    recovery_timeout: 30s
  fallback_strategy:
    enabled: true
    fallback_action: log_and_continue
    alert_on_fallback: true
  error_categories:
    transient:
      - file_not_found
      - permission_error
      action: retry
    permanent:
      - invalid_configuration
      action: alert_and_stop
    recoverable:
      - data_validation_failure
      - output_format_error
      action: log_and_continue
```
