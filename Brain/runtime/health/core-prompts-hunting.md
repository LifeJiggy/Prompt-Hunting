# Core Prompts Hunting — Health Check System

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | Core-Prompts-hunting |
| Directory | `Core-Prompts-hunting/` |
| File Count | 50 files |
| Health Profile | Hunting Scanner Health |
| Worker Type | Scanner Processes |
| Check Interval | 30 seconds |
| Recovery Mode | Automatic with scanner pool management |

---

## Overview

This health check system monitors the Core-Prompts-hunting domain which encompasses 50 specialized hunting prompt modules covering reconnaissance, vulnerability detection, exploitation techniques, and security assessment across the full spectrum of web application security. The health system ensures all scanner processes remain operational, prompt templates are valid, and hunting pipelines deliver consistent coverage.

### Domain File Registry

All 50 files within Core-Prompts-hunting/ are tracked as scanner-dependent components:

| # | File | Scanner Category | Criticality |
|---|------|-----------------|-------------|
| 01 | Reconnaissance-and-Asset-Discovery.md | recon-scanner | CRITICAL |
| 02 | JavaScript-Analysis-and-Deobfuscation.md | js-scanner | HIGH |
| 03 | API-Endpoint-Analysis.md | api-scanner | CRITICAL |
| 04 | Authentication-and-Session-Management.md | auth-scanner | CRITICAL |
| 05 | Authorization-and-Access-Control.md | authz-scanner | CRITICAL |
| 06 | Input-Validation-and-Sanitization.md | input-scanner | HIGH |
| 07 | Business-Logic-Flaws.md | logic-scanner | HIGH |
| 08 | Client-Side-Storage-Security.md | client-scanner | MEDIUM |
| 09 | Cryptography-and-Data-Protection.md | crypto-scanner | HIGH |
| 10 | Error-Handling-and-Information-Disclosure.md | error-scanner | HIGH |
| 11 | File-Upload-and-Processing.md | upload-scanner | HIGH |
| 12 | Server-Side-Request-Forgery-SSRF.md | ssrf-scanner | CRITICAL |
| 13 | Cross-Site-Request-Forgery-CSRF.md | csrf-scanner | HIGH |
| 14 | Cross-Origin-Resource-Sharing-CORS.md | cors-scanner | HIGH |
| 15 | Race-Conditions-and-Concurrency-Issues.md | race-scanner | HIGH |
| 16 | Third-Party-Component-Analysis.md | component-scanner | MEDIUM |
| 17 | Configuration-and-Misconfiguration-Hunting.md | config-scanner | HIGH |
| 18 | Network-and-Infrastructure-Security.md | network-scanner | HIGH |
| 19 | Mobile-and-API-Specific-Vulnerabilities.md | mobile-scanner | HIGH |
| 20 | Reporting-and-Proof-of-Concept-Development.md | report-scanner | MEDIUM |
| 21 | Web-Application-Firewall-WAF-Bypass.md | waf-scanner | HIGH |
| 22 | HTTP-Request-Smuggling.md | smuggle-scanner | HIGH |
| 23 | Subdomain-Takeover.md | subdomain-scanner | HIGH |
| 24 | Host-Header-Injection.md | host-scanner | MEDIUM |
| 25 | XML-External-Entity-XXE-Injection.md | xxe-scanner | HIGH |
| 26 | Insecure-Deserialization.md | deser-scanner | HIGH |
| 27 | Command-Injection.md | cmdi-scanner | CRITICAL |
| 28 | NoSQL-Injection.md | nosql-scanner | HIGH |
| 29 | GraphQL-Vulnerabilities.md | graphql-scanner | HIGH |
| 30 | WebSocket-Security.md | ws-scanner | MEDIUM |
| 31 | Server-Side-Template-Injection.md | ssti-scanner | CRITICAL |
| 32 | JSON-Web-Token-JWT-Vulnerabilities.md | jwt-scanner | HIGH |
| 33 | Content-Security-Policy-CSP-Bypass.md | csp-scanner | MEDIUM |
| 34 | Clickjacking-and-UI-Redressing.md | clickjack-scanner | MEDIUM |
| 35 | HTTP-Parameter-Pollution.md | hpp-scanner | MEDIUM |
| 36 | LDAP-Injection.md | ldap-scanner | HIGH |
| 37 | Session-Puzzling-and-Fixation.md | session-scanner | HIGH |
| 38 | Insecure-File-Handling.md | file-scanner | HIGH |
| 39 | Cross-Site-Script-Inclusion-XSSI.md | xssi-scanner | MEDIUM |
| 40 | Prototype-Pollution.md | proto-scanner | HIGH |
| 41 | HTTP-Response-Splitting.md | splitting-scanner | MEDIUM |
| 42 | XPath-Injection.md | xpath-scanner | HIGH |
| 43 | Cross-Site-Request-Forgery-CSRF.md | csrf-scanner | HIGH |
| 44 | Cross-Origin-Resource-Sharing-CORS.md | cors-scanner | HIGH |
| 45 | Race-Conditions-and-Concurrency-Issues.md | race-scanner | HIGH |
| 46 | Third-Party-Component-Analysis.md | component-scanner | MEDIUM |
| 47 | Configuration-and-Misconfiguration-Hunting.md | config-scanner | HIGH |
| 48 | Network-and-Infrastructure-Security.md | network-scanner | HIGH |
| 49 | Mobile-and-API-Specific-Vulnerabilities.md | mobile-scanner | HIGH |
| 50 | Reporting-and-Proof-of-Concept-Development.md | report-scanner | MEDIUM |

---

## Health Check Types

### 1. Heartbeat Monitoring

```yaml
heartbeat:
  enabled: true
  interval_seconds: 30
  timeout_seconds: 10
  max_missed_beats: 3
  protocol: internal-ipc
  response_format: json
  fields:
    - scanner_id
    - timestamp
    - active_scans
    - prompts_loaded
    - scan_accuracy
    - false_positive_rate
```

**Scanner Process Heartbeat Groups:**

| Group | Scanners | Priority |
|-------|----------|----------|
| injection-scanners | 12, 25, 27, 28, 31, 36, 40, 42 | CRITICAL |
| auth-scanners | 04, 05, 32, 37 | CRITICAL |
| recon-scanners | 01, 03, 23 | CRITICAL |
| logic-scanners | 07, 15, 34, 35, 39, 45 | HIGH |
| config-scanners | 14, 17, 21, 33, 44, 47 | HIGH |
| data-scanners | 08, 09, 10, 11, 26, 38 | HIGH |
| network-scanners | 18, 22, 48 | HIGH |
| js-scanners | 02, 40 | HIGH |
| api-scanners | 03, 19, 29, 30, 49 | HIGH |
| report-scanners | 20, 50 | MEDIUM |

### 2. Resource Monitoring

```yaml
resource_checks:
  cpu:
    warning_threshold: 70%
    critical_threshold: 90%
    check_interval: 15s
  memory:
    warning_threshold: 75%
    critical_threshold: 92%
    check_interval: 15s
    prompt_template_overhead: 25%
  disk:
    warning_threshold: 80%
    critical_threshold: 95%
    check_interval: 60s
  scan_pool:
    min_idle_scanners: 3
    max_concurrent_scans: 50
    check_interval: 5s
```

### 3. Dependency Health Checks

```yaml
dependencies:
  internal:
    - name: prompt-store
      type: storage
      health_endpoint: /health/prompts
      timeout: 3s
      critical: true
    - name: scanner-pool
      type: pool
      health_endpoint: /health/pool
      timeout: 5s
      critical: true
    - name: result-aggregator
      type: service
      health_endpoint: /health/results
      timeout: 5s
      critical: true
    - name: target-queue
      type: queue
      health_endpoint: /health/targets
      timeout: 5s
      critical: true
  external:
    - name: proxy-service
      type: proxy
      health_endpoint: /health/proxy
      timeout: 10s
      critical: false
```

### 4. Integrity Checks

```yaml
integrity:
  prompt_templates:
    enabled: true
    check_interval: 3600s
    validate_all_50_files: true
    algorithm: sha256
  scanner_binaries:
    enabled: true
    check_interval: 86400s
    algorithm: sha512
  result_integrity:
    enabled: true
    check_interval: 300s
    validate_result_format: true
```

### 5. Self-Test Procedures

```yaml
self_test:
  enabled: true
  interval: 300s
  procedures:
    - name: scanner_functionality
      description: Run test scan against dummy target
      expected_result: scan_completes_successfully
    - name: prompt_validation
      description: Verify all prompt templates are valid
      expected_result: all_prompts_valid
    - name: result_accuracy
      description: Verify result format and accuracy
      expected_result: results_within_accuracy_threshold
    - name: pool_management
      description: Verify scanner pool scaling works
      expected_result: pool_scales_correctly
```

---

## Health States

### HEALTHY

All scanner processes are operational, prompt templates are valid, and scan accuracy is within thresholds.

```
State: HEALTHY
├── All 50 prompt files accessible
├── All scanner processes responding
├── Scan accuracy > 85%
├── False positive rate < 15%
├── All dependencies available
└── Self-test: all passed
```

### DEGRADED

Some scanners are slow, or scan accuracy has dropped.

```
State: DEGRADED
├── Some scanners responding slowly
├── Scan accuracy 75-85%
├── False positive rate 15-25%
├── Non-critical dependency unavailable
└── Recovery actions initiated
```

### UNHEALTHY

Multiple critical scanners are down, or scan accuracy is poor.

```
State: UNHEALTHY
├── Multiple critical scanners down
├── Scan accuracy < 75%
├── False positive rate > 25%
├── Critical dependency unavailable
└── Manual intervention needed
```

### CRITICAL

Scanner framework failure, prompt corruption, or complete system breakdown.

```
State: CRITICAL
├── Majority of scanners down
├── Prompt template corruption
├── Complete scanning failure
└── Immediate intervention required
```

---

## Recovery Actions

| Action | Trigger | Procedure | Timeout |
|--------|---------|-----------|---------|
| Scanner Restart | Heartbeat timeout 3x | Restart scanner process | 45s |
| Prompt Reload | Template corruption | Reload prompt templates | 30s |
| Pool Scale Up | All scanners busy | Spin up additional scanners | 60s |
| Pool Scale Down | Excess idle scanners | Terminate idle scanners | 30s |
| Result Flush | Result store full | Flush old results | 60s |
| Config Reload | Config drift | Reload scanner config | 10s |
| Accuracy Reset | FP rate too high | Reset scanner filters | 30s |

---

## Health Metrics

| Metric | Description | Type | Unit |
|--------|-------------|------|------|
| hunting.scanners.active | Active scanners | Gauge | count |
| hunting.scanners.total | Total scanners | Gauge | count |
| hunting.scans.active | Active scans | Gauge | count |
| hunting.scans.completed | Completed scans | Counter | count |
| hunting.scans.failed | Failed scans | Counter | count |
| hunting.scans.avg_duration | Average scan duration | Histogram | seconds |
| hunting.prompts.loaded | Loaded prompts | Gauge | count |
| hunting.prompts.valid | Valid prompts | Gauge | count |
| hunting.accuracy.scan | Scan accuracy | Gauge | percent |
| hunting.accuracy.fp_rate | False positive rate | Gauge | percent |
| hunting.vulns.found | Vulnerabilities found | Counter | count |
| hunting.vulns.severity.critical | Critical vulns | Counter | count |
| hunting.vulns.severity.high | High vulns | Counter | count |
| hunting.cpu.usage | CPU usage | Gauge | percent |
| hunting.memory.usage | Memory usage | Gauge | percent |

---

## Alerting Configuration

```yaml
alerting:
  rules:
    - name: scanner_down
      condition: heartbeat_missed >= 3
      severity: warning
      cooldown: 120s

    - name: scanner_critical_down
      condition: critical_scanner_heartbeat_missed >= 3
      severity: critical
      cooldown: 60s

    - name: scan_accuracy_low
      condition: scan_accuracy < 75%
      severity: warning
      cooldown: 300s

    - name: fp_rate_high
      condition: fp_rate > 25%
      severity: warning
      cooldown: 300s

    - name: prompt_corruption
      condition: prompt_integrity_check_failed
      severity: critical
      cooldown: 60s

    - name: scan_pool_exhausted
      condition: active_scanners == max_scanners
      severity: warning
      cooldown: 120s
```

---

## Health History

| Data Type | Retention | Storage |
|-----------|-----------|---------|
| Scanner heartbeat logs | 30 days | Local |
| Scan results | 90 days | Local |
| Prompt validation logs | 30 days | Local |
| Recovery actions | 90 days | Local |
| Metric snapshots | 7 days | Local |
| Aggregated metrics | 365 days | Local |

---

## Integration Points

| Integration | Type | Health Endpoint | Critical |
|-------------|------|----------------|----------|
| prompt-store | storage | /health/prompts | YES |
| scanner-pool | pool | /health/pool | YES |
| result-aggregator | service | /health/results | YES |
| target-queue | queue | /health/targets | YES |
| proxy-service | proxy | /health/proxy | NO |

---

## Scanner Pool Configuration

```yaml
scanner_pool:
  version: "2.0"
  domain: "core-prompts-hunting"
  enabled: true

  global:
    health_check_interval: 30s
    recovery_enabled: true
    max_concurrent_scans: 50
    scan_timeout_seconds: 3600

  injection_scanners:
    scanners: [12, 25, 27, 28, 31, 36, 40, 42]
    health_check_interval: 15s
    heartbeat_timeout: 5s
    max_missed_beats: 3
    recovery_strategy: restart
    priority: CRITICAL
    max_instances: 10

  auth_scanners:
    scanners: [04, 05, 32, 37]
    health_check_interval: 15s
    heartbeat_timeout: 5s
    max_missed_beats: 3
    recovery_strategy: restart
    priority: CRITICAL
    max_instances: 8

  recon_scanners:
    scanners: [01, 03, 23]
    health_check_interval: 30s
    heartbeat_timeout: 10s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: CRITICAL
    max_instances: 5

  logic_scanners:
    scanners: [07, 15, 34, 35, 39, 45]
    health_check_interval: 30s
    heartbeat_timeout: 10s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: HIGH
    max_instances: 10

  config_scanners:
    scanners: [14, 17, 21, 33, 44, 47]
    health_check_interval: 30s
    heartbeat_timeout: 10s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: HIGH
    max_instances: 8

  data_scanners:
    scanners: [08, 09, 10, 11, 26, 38]
    health_check_interval: 30s
    heartbeat_timeout: 10s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: HIGH
    max_instances: 10

  network_scanners:
    scanners: [18, 22, 48]
    health_check_interval: 30s
    heartbeat_timeout: 10s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: HIGH
    max_instances: 5

  js_scanners:
    scanners: [02, 40]
    health_check_interval: 30s
    heartbeat_timeout: 10s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: HIGH
    max_instances: 5

  api_scanners:
    scanners: [03, 19, 29, 30, 49]
    health_check_interval: 30s
    heartbeat_timeout: 10s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: HIGH
    max_instances: 8
```

---

## Scanner Performance Configuration

```yaml
scanner_performance:
  scan_limits:
    max_scan_duration: 3600s
    max_requests_per_scan: 10000
    max_concurrent_requests: 20
    request_timeout: 10s
    retry_count: 3
    retry_delay: 2s

  accuracy_thresholds:
    scan_accuracy_warning: 75%
    scan_accuracy_critical: 60%
    fp_rate_warning: 20%
    fp_rate_critical: 30%
    fn_rate_warning: 15%
    fn_rate_critical: 25%

  pool_management:
    min_idle_scanners: 3
    max_idle_time: 300s
    scale_up_threshold: 80%
    scale_down_threshold: 20%
    cooldown_period: 60s
```

---

## Scanner Dashboard

| Dashboard Section | Description | Update Frequency |
|-------------------|-------------|-----------------|
| Pool Status | Scanner pool status | Every heartbeat |
| Active Scans | Currently running scans | Real-time |
| Scan History | Recently completed scans | Every 30s |
| Prompt Status | Prompt template status | Every 60s |
| Accuracy Metrics | Scan accuracy metrics | Every 60s |
| Vulnerability Feed | Newly found vulns | Real-time |
| Resource Usage | CPU, memory, network | Every 15s |
| Error Feed | Scanner errors | Real-time |

---

## Scanner Logging

```yaml
logging:
  scanner_health:
    level: info
    destination: /var/log/hunting-health.log
    rotation: daily
    retention: 30d

  scan_results:
    level: info
    destination: /var/log/hunting-scans.log
    rotation: daily
    retention: 90d

  prompt_operations:
    level: debug
    destination: /var/log/hunting-prompts.log
    rotation: daily
    retention: 30d

  accuracy_metrics:
    level: info
    destination: /var/log/hunting-accuracy.log
    rotation: daily
    retention: 30d

  recovery_actions:
    level: warn
    destination: /var/log/hunting-recovery.log
    rotation: daily
    retention: 90d

  vulnerability_discovery:
    level: info
    destination: /var/log/hunting-vulns.log
    rotation: daily
    retention: 365d
```

---

## Scanner Performance Baselines

| Scanner Type | Avg Scan Time | Success Rate | Accuracy | FP Rate |
|-------------|---------------|--------------|----------|---------|
| injection | 300s | > 90% | > 85% | < 15% |
| auth | 180s | > 95% | > 90% | < 10% |
| recon | 600s | > 85% | > 80% | < 15% |
| logic | 420s | > 85% | > 80% | < 15% |
| config | 120s | > 95% | > 90% | < 10% |
| data | 300s | > 90% | > 85% | < 15% |
| network | 600s | > 85% | > 80% | < 15% |
| js | 240s | > 90% | > 85% | < 15% |
| api | 300s | > 90% | > 85% | < 15% |
