# Report Writing Mastery — Sandboxed Execution Framework

## Domain Overview

This file defines the sandboxed execution environment for the **Report-Writing-Mastery** domain, covering all 54 report writing and documentation modules. The sandbox enforces file-system isolation for report generation, template management, and documentation operations.

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain Name | Report-Writing-Mastery |
| Sandbox Type | File-System Sandbox |
| Primary Purpose | Isolated execution of report generation and documentation |
| Risk Level | LOW — documentation and writing operations |
| Isolation Requirement | File-system focused isolation |
| Total Domain Files | 54 |
| Sandbox Version | 2.0 |

---

## Isolation Levels

### Level 1 — Template Reading (Safe)

Read-only access to report templates and style guides.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | DENIED |
| Process Spawn | DENIED |
| Time Limit | 120 seconds |
| Memory Limit | 256 MB |
| CPU Limit | 1 core |

### Level 2 — Content Generation (Moderate)

Content generation with template-based output.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | SANDBOXED OUTPUT ONLY |
| Process Spawn | LIMITED (max 3) |
| Time Limit | 300 seconds |
| Memory Limit | 512 MB |
| CPU Limit | 2 cores |

### Level 3 — Report Assembly (Elevated)

Full report assembly with multiple sections and formatting.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | FULL SANDBOX ACCESS |
| Process Spawn | MONITORED (max 5) |
| Time Limit | 600 seconds |
| Memory Limit | 1 GB |
| CPU Limit | 4 cores |

### Level 4 — Document Production (Maximum)

Complete document production with multiple output formats.

| Property | Configuration |
|----------|---------------|
| Network Access | DENIED |
| Filesystem Write | FULL SANDBOX ACCESS |
| Process Spawn | FULLY MONITORED (max 8) |
| Time Limit | 900 seconds |
| Memory Limit | 2 GB |
| CPU Limit | 8 cores |

---

## Sandbox Policies

### Filesystem Policy

```yaml
filesystem:
  root: /sandbox/report-writing/
  writable_paths:
    - /sandbox/report-writing/output/
    - /sandbox/report-writing/temp/
    - /sandbox/report-writing/drafts/
    - /sandbox/report-writing/reports/
    - /sandbox/report-writing/exports/
  read_only_paths:
    - /sandbox/report-writing/config/
    - /sandbox/report-writing/templates/
    - /sandbox/report-writing/style-guides/
    - /sandbox/report-writing/reference/
    - /sandbox/report-writing/examples/
  denied_paths:
    - /etc/
    - /root/
    - /home/
    - /proc/
    - /sys/
  max_file_size: 100MB
  max_total_storage: 5GB
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
    - .docx
    - .tex
    - .rst
  template_management:
    enabled: true
    template_path: /sandbox/report-writing/templates/
    output_path: /sandbox/report-writing/output/
    draft_path: /sandbox/report-writing/drafts/
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
    Network access is completely disabled for report writing operations.
    All templates and resources are pre-loaded.
```

### Process Policy

```yaml
process:
  max_children: 8
  max_total_processes: 10
  allowed_binaries:
    - /sandbox/bin/report-writer
    - /sandbox/bin/template-engine
    - /sandbox/bin/formatter
    - /sandbox/bin/exporter
    - /sandbox/bin/validator
  resource_limits:
    cpu_percent: 60
    memory_mb: 2048
    open_files: 1024
    processes: 10
    threads: 32
  execution:
    timeout: 900s
    kill_on_timeout: true
    restart_allowed: true
    max_restarts: 3
  user:
    run_as: sandbox-user
    uid: 1011
    gid: 1011
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
| RW-008 | Template validation fails | REJECT + LOG | LOW |
| RW-009 | Output format validation fails | REJECT + LOG | LOW |
| RW-010 | Audit trail gap detected | LOG + CONTINUE | LOW |

---

## Output Capture

```yaml
output_capture:
  enabled: true
  formats:
    - json
    - markdown
    - docx
    - pdf
  destinations:
    drafts:
      path: /sandbox/report-writing/drafts/{report_id}/
      format: markdown
      retention: 30d
    final_reports:
      path: /sandbox/report-writing/reports/
      format: [markdown, pdf, docx]
      retention: 365d
    exports:
      path: /sandbox/report-writing/exports/{report_id}/
      format: [json, html]
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
  size_limits:
    max_output_per_report: 50MB
    max_total_output: 5GB
  compression:
    enabled: true
    algorithm: gzip
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
      report_result: true
      duration: true
      file_count: true
    standard:
      timestamps: true
      report_result: true
      duration: true
      file_count: true
      resource_usage: true
      sections_generated: true
    verbose:
      timestamps: true
      report_result: true
      duration: true
      file_count: true
      resource_usage: true
      sections_generated: true
      template_used: true
      formatting_applied: true
      validation_results: true
  storage:
    path: /sandbox/report-writing/recordings/
    format: jsonl
    compression: gzip
    retention: 90d
    max_size: 2GB
  integrity:
    hash_algorithm: sha256
    chain_verification: true
```

---

## Domain File References

| # | File | Module | Sandbox Level | Description |
|---|------|--------|---------------|-------------|
| 1 | report-structure.md | Structure | Level 1 | Report structure guidelines |
| 2 | title-formulation.md | Title | Level 1 | Title formulation guide |
| 3 | impact-statement.md | Impact | Level 1 | Impact statement writing |
| 4 | vulnerability-description.md | Description | Level 1 | Vulnerability description guide |
| 5 | poc-documentation.md | PoC | Level 1 | Proof of concept documentation |
| 6 | reproduction-steps.md | Repro Steps | Level 1 | Reproduction step writing |
| 7 | remediation-guidance.md | Remediation | Level 1 | Remediation guidance writing |
| 8 | cvss-scoring.md | CVSS | Level 1 | CVSS scoring guide |
| 9 | severity-justification.md | Severity | Level 1 | Severity justification writing |
| 10 | executive-summary.md | Executive | Level 1 | Executive summary writing |
| 11 | technical-summary.md | Technical | Level 1 | Technical summary writing |
| 12 | methodology-section.md | Methodology | Level 1 | Methodology section writing |
| 13 | findings-section.md | Findings | Level 1 | Findings section writing |
| 14 | recommendations-section.md | Recommendations | Level 1 | Recommendations section |
| 15 | appendix-writing.md | Appendix | Level 1 | Appendix writing guide |
| 16 | references-section.md | References | Level 1 | References section guide |
| 17 | terminology-guide.md | Terminology | Level 1 | Terminology guide |
| 18 | style-guide.md | Style | Level 1 | Writing style guide |
| 19 | formatting-guide.md | Formatting | Level 1 | Formatting guide |
| 20 | screenshot-guidelines.md | Screenshots | Level 1 | Screenshot guidelines |
| 21 | evidence-capture.md | Evidence | Level 1 | Evidence capture guide |
| 22 | redaction-techniques.md | Redaction | Level 1 | Data redaction techniques |
| 23 | har-sanitization.md | HAR | Level 1 | HAR file sanitization |
| 24 | burp-screenshot.md | Burp | Level 1 | Burp Suite screenshot guide |
| 25 | devtools-poc.md | DevTools | Level 1 | DevTools PoC guide |
| 26 | console-poc.md | Console | Level 1 | Console PoC guide |
| 27 | report-templates.md | Templates | Level 1 | Report templates library |
| 28 | h1-report-template.md | H1 Template | Level 1 | HackerOne report template |
| 29 | bugcrowd-template.md | Bugcrowd | Level 1 | Bugcrowd report template |
| 30 | intigriti-template.md | Intigriti | Level 1 | Intigriti report template |
| 31 | immunefi-template.md | Immunefi | Level 1 | Immunefi report template |
| 32 | redteam-report-template.md | Red Team | Level 1 | Red team report template |
| 33 | pentest-report-template.md | Pentest | Level 1 | Pentest report template |
| 34 | assessment-report-template.md | Assessment | Level 1 | Assessment report template |
| 35 | finding-templates.md | Finding | Level 1 | Finding-specific templates |
| 36 | xss-report-template.md | XSS | Level 1 | XSS report template |
| 37 | sqli-report-template.md | SQLi | Level 1 | SQLi report template |
| 38 | ssrf-report-template.md | SSRF | Level 1 | SSRF report template |
| 39 | idor-report-template.md | IDOR | Level 1 | IDOR report template |
| 40 | rce-report-template.md | RCE | Level 1 | RCE report template |
| 41 | auth-bypass-template.md | Auth Bypass | Level 1 | Auth bypass report template |
| 42 | file-upload-template.md | File Upload | Level 1 | File upload report template |
| 43 | ssti-report-template.md | SSTI | Level 1 | SSTI report template |
| 44 | xxe-report-template.md | XXE | Level 1 | XXE report template |
| 45 | csrf-report-template.md | CSRF | Level 1 | CSRF report template |
| 46 | race-condition-template.md | Race | Level 1 | Race condition report template |
| 47 | business-logic-template.md | Logic | Level 1 | Business logic report template |
| 48 | info-disclosure-template.md | Info Leak | Level 1 | Info disclosure report template |
| 49 | misconfiguration-template.md | Misconfig | Level 1 | Misconfiguration report template |
| 50 | submission-checklist.md | Checklist | Level 1 | Pre-submission checklist |
| 51 | report-review.md | Review | Level 1 | Report review process |
| 52 | report-iteration.md | Iterate | Level 1 | Report iteration guide |
| 53 | report-archiving.md | Archive | Level 1 | Report archiving guide |
| 54 | report-framework.md | Framework | Level 1 | Report writing framework |

---

## Configuration YAML — Full Sandbox Definition

```yaml
sandbox:
  name: report-writing-sandbox
  version: "2.0"
  domain: report-writing-mastery
  description: >
    File-system sandbox for report generation and documentation.
    No network access, focused on content creation and formatting.

  container:
    image: sandbox/report-writing:2.0
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
        - mount_template_resources
        - mount_style_guides
        - initialize_logging
    - name: policy_loading
      timeout: 15s
      steps:
        - load_filesystem_policy
        - load_process_policy
        - validate_policy_syntax
        - enable_enforcement
    - name: template_preparation
      timeout: 30s
      steps:
        - load_all_templates
        - validate_template_syntax
        - index_template_content
        - prepare_output_directories
    - name: recording_initialization
      timeout: 10s
      steps:
        - initialize_recording_streams
        - configure_audit_trail
    - name: readiness_check
      timeout: 5s
      steps:
        - verify_all_policies_loaded
        - verify_templates_loaded
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
    max_retries: 3
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
  error_categories:
    transient:
      - file_not_found
      - permission_error
      action: retry
    permanent:
      - invalid_configuration
      - template_not_found
      action: alert_and_stop
    recoverable:
      - output_format_error
      - validation_failure
      action: log_and_continue
```
