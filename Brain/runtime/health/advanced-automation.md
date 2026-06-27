# Advanced Automation — Health Check System

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | Advanced-Automation |
| Directory | `Advanced-Automation/` |
| File Count | 50 files |
| Health Profile | Scanning Pipeline Health |
| Worker Type | Pipeline Workers |
| Check Interval | 30 seconds |
| Recovery Mode | Automatic with fallback |

---

## Overview

This health check system monitors the Advanced Automation domain which encompasses 50 specialized automation modules covering scanning pipelines, vulnerability detection automation, tool chaining, browser automation, and workflow orchestration. The health system ensures all pipeline workers remain operational, detects degradation early, and triggers automatic recovery when components fail.

### Domain File Registry

All 50 files within Advanced-Automation/ are tracked as health-dependent components:

| # | File | Health Group | Criticality |
|---|------|-------------|-------------|
| 01 | Subdomain-Enumeration-Automation.md | recon-pipeline | HIGH |
| 02 | Port-Scanning-Automation.md | recon-pipeline | HIGH |
| 03 | Vulnerability-Scanning-Automation.md | scan-pipeline | CRITICAL |
| 04 | JavaScript-Analysis-Automation.md | analysis-pipeline | MEDIUM |
| 05 | API-Endpoint-Discovery.md | recon-pipeline | HIGH |
| 06 | Parameter-Fuzzing-Automation.md | fuzz-pipeline | HIGH |
| 07 | Directory-Brute-Forcing.md | fuzz-pipeline | MEDIUM |
| 09 | Authentication-Testing-Automation.md | auth-pipeline | HIGH |
| 10 | Session-Management-Testing.md | auth-pipeline | HIGH |
| 11 | IDOR-Detection-Automation.md | vuln-pipeline | HIGH |
| 12 | SQL-Injection-Automation.md | vuln-pipeline | CRITICAL |
| 13 | XSS-Detection-Automation.md | vuln-pipeline | CRITICAL |
| 14 | SSRF-Testing-Automation.md | vuln-pipeline | CRITICAL |
| 15 | CSRF-Testing-Automation.md | vuln-pipeline | HIGH |
| 16 | Command-Injection-Automation.md | vuln-pipeline | CRITICAL |
| 17 | XXE-Testing-Automation.md | vuln-pipeline | HIGH |
| 18 | SSTI-Testing-Automation.md | vuln-pipeline | HIGH |
| 19 | JWT-Testing-Automation.md | auth-pipeline | HIGH |
| 20 | Deserialization-Testing.md | vuln-pipeline | HIGH |
| 21 | Report-Generation-Automation.md | report-pipeline | MEDIUM |
| 22 | PoC-Development-Automation.md | report-pipeline | MEDIUM |
| 23 | Target-Scouting-Automation.md | recon-pipeline | HIGH |
| 24 | Scope-Validation-Automation.md | scope-pipeline | HIGH |
| 25 | Asset-Tracking-Automation.md | asset-pipeline | MEDIUM |
| 26 | Change-Monitoring-Automation.md | monitor-pipeline | HIGH |
| 27 | Notification-Alerting-Automation.md | alert-pipeline | HIGH |
| 28 | Data-Collection-Automation.md | data-pipeline | HIGH |
| 29 | Result-Analysis-Automation.md | analysis-pipeline | HIGH |
| 30 | Tool-Chaining-Automation.md | chain-pipeline | CRITICAL |
| 31 | Proxy-Integration-Automation.md | proxy-pipeline | HIGH |
| 32 | Browser-Automation-Workflows.md | browser-pipeline | HIGH |
| 33 | Headless-Browser-Scripting.md | browser-pipeline | HIGH |
| 34 | Regex-Pattern-Automation.md | pattern-pipeline | MEDIUM |
| 35 | Response-Analysis-Automation.md | analysis-pipeline | HIGH |
| 36 | Header-Injection-Testing.md | vuln-pipeline | MEDIUM |
| 37 | CORS-Testing-Automation.md | vuln-pipeline | MEDIUM |
| 38 | WebSocket-Testing-Automation.md | vuln-pipeline | MEDIUM |
| 39 | GraphQL-Testing-Automation.md | vuln-pipeline | MEDIUM |
| 40 | Cloud-Service-Enumeration.md | cloud-pipeline | HIGH |
| 41 | DNS-Data-Extraction-Automation.md | recon-pipeline | MEDIUM |
| 42 | Email-Recon-Automation.md | recon-pipeline | MEDIUM |
| 43 | Social-Media-OSINT-Automation.md | osint-pipeline | MEDIUM |
| 44 | Framework-Detection-Automation.md | fingerprint-pipeline | MEDIUM |
| 45 | Technology-Stack-Identification.md | fingerprint-pipeline | MEDIUM |
| 46 | Endpoint-Mapping-Automation.md | recon-pipeline | HIGH |
| 47 | Content-Discovery-Automation.md | fuzz-pipeline | MEDIUM |
| 48 | Version-Detection-Automation.md | fingerprint-pipeline | MEDIUM |
| 49 | Compliance-Checking-Automation.md | compliance-pipeline | LOW |
| 50 | Workflow-Orchestration-Automation.md | orchestration-pipeline | CRITICAL |

---

## Health Check Types

### 1. Heartbeat Monitoring

Heartbeat checks verify that each pipeline worker process is alive and responsive.

```yaml
heartbeat:
  enabled: true
  interval_seconds: 30
  timeout_seconds: 10
  max_missed_beats: 3
  protocol: internal-ipc
  response_format: json
  fields:
    - worker_id
    - timestamp
    - uptime_seconds
    - tasks_completed
    - tasks_in_queue
    - memory_usage_mb
    - cpu_usage_percent
```

**Heartbeat Check Procedures:**

- Each pipeline worker registers a heartbeat endpoint at startup
- The health monitor sends heartbeat probes every 30 seconds
- Workers must respond within 10 seconds or be flagged as unresponsive
- After 3 consecutive missed beats, the worker is marked DEGRADED
- After 5 consecutive missed beats, the worker is marked UNHEALTHY
- Recovery is triggered automatically after UNHEALTHY state persists for 60 seconds

**Pipeline Worker Heartbeat Groups:**

| Group | Workers | Heartbeat Priority |
|-------|---------|-------------------|
| scan-pipeline | 03, 12, 13, 14, 16 | CRITICAL |
| recon-pipeline | 01, 02, 05, 23, 41, 42, 46 | HIGH |
| vuln-pipeline | 11, 15, 17, 18, 19, 20, 36, 37, 38, 39 | HIGH |
| auth-pipeline | 09, 10, 19 | HIGH |
| fuzz-pipeline | 06, 07, 47 | MEDIUM |
| analysis-pipeline | 04, 29, 35 | MEDIUM |
| browser-pipeline | 32, 33 | MEDIUM |
| chain-pipeline | 30 | CRITICAL |
| report-pipeline | 21, 22 | LOW |
| orchestration-pipeline | 50 | CRITICAL |

### 2. Resource Monitoring

Resource checks ensure pipeline workers have adequate system resources.

```yaml
resource_checks:
  cpu:
    warning_threshold: 70%
    critical_threshold: 90%
    check_interval: 15s
  memory:
    warning_threshold: 75%
    critical_threshold: 90%
    check_interval: 15s
  disk:
    warning_threshold: 80%
    critical_threshold: 95%
    check_interval: 60s
  network:
    max_bandwidth_usage: 80%
    connection_pool_threshold: 90%
    check_interval: 30s
  file_descriptors:
    warning_threshold: 80%
    critical_threshold: 95%
    check_interval: 60s
```

**Resource Profiles per Pipeline:**

| Pipeline | Min CPU Cores | Min Memory (GB) | Min Disk (GB) | Network Req |
|----------|--------------|-----------------|---------------|-------------|
| scan-pipeline | 4 | 8 | 100 | HIGH |
| recon-pipeline | 2 | 4 | 50 | HIGH |
| vuln-pipeline | 4 | 8 | 100 | MEDIUM |
| auth-pipeline | 2 | 4 | 50 | MEDIUM |
| fuzz-pipeline | 4 | 16 | 200 | HIGH |
| analysis-pipeline | 2 | 8 | 50 | LOW |
| browser-pipeline | 2 | 4 | 20 | HIGH |
| chain-pipeline | 4 | 8 | 100 | HIGH |
| report-pipeline | 1 | 2 | 20 | LOW |
| orchestration-pipeline | 2 | 4 | 50 | MEDIUM |

### 3. Dependency Health Checks

Dependency checks verify that all external and internal dependencies are available.

```yaml
dependencies:
  internal:
    - name: task-queue
      type: message-queue
      health_endpoint: /health/queue
      timeout: 5s
      critical: true
    - name: result-store
      type: database
      health_endpoint: /health/db
      timeout: 5s
      critical: true
    - name: config-service
      type: config
      health_endpoint: /health/config
      timeout: 3s
      critical: true
    - name: logging-service
      type: logging
      health_endpoint: /health/log
      timeout: 3s
      critical: false
  external:
    - name: target-api
      type: external-api
      health_endpoint: /health/ping
      timeout: 10s
      critical: false
      retry_count: 3
    - name: proxy-pool
      type: proxy
      health_endpoint: /health/proxy
      timeout: 5s
      critical: false
```

**Dependency Matrix per Pipeline:**

| Pipeline | Required Dependencies | Optional Dependencies |
|----------|----------------------|----------------------|
| scan-pipeline | task-queue, result-store, config-service | proxy-pool |
| recon-pipeline | task-queue, result-store | proxy-pool, target-api |
| vuln-pipeline | task-queue, result-store, config-service | proxy-pool |
| auth-pipeline | task-queue, result-store | none |
| fuzz-pipeline | task-queue, result-store, config-service | proxy-pool |
| analysis-pipeline | result-store | logging-service |
| browser-pipeline | task-queue | proxy-pool |
| chain-pipeline | task-queue, result-store, config-service | proxy-pool |
| report-pipeline | result-store | logging-service |
| orchestration-pipeline | task-queue, result-store, config-service | logging-service |

### 4. Integrity Checks

Integrity checks verify that pipeline components and configurations have not been corrupted or tampered with.

```yaml
integrity:
  checksum_verification:
    enabled: true
    algorithm: sha256
    files:
      - path: "Advanced-Automation/*.md"
        expected_hash_file: ".integrity/automation-hashes.json"
        check_interval: 3600s
  configuration_drift:
    enabled: true
    baseline_file: ".integrity/automation-config-baseline.json"
    check_interval: 300s
    alert_on_drift: true
  worker_binary_integrity:
    enabled: true
    check_interval: 86400s
    algorithm: sha512
```

**Integrity Check Scope:**

| Check Type | Coverage | Frequency | Action on Failure |
|-----------|----------|-----------|-------------------|
| File checksums | All 50 automation files | Hourly | Alert + quarantine |
| Config drift | All pipeline configs | Every 5 min | Alert + auto-rollback |
| Binary integrity | Worker executables | Daily | Alert + manual review |
| Dependency integrity | Third-party libs | On deploy | Block deployment |

### 5. Self-Test Procedures

Self-tests validate that the health check system itself is functioning correctly.

```yaml
self_test:
  enabled: true
  interval: 300s
  procedures:
    - name: heartbeat_echo
      description: Verify heartbeat monitoring is operational
      expected_result: all_workers_respond
    - name: alert_delivery
      description: Send test alert and verify delivery
      expected_result: alert_received_within_30s
    - name: recovery_simulation
      description: Simulate worker failure and verify recovery
      expected_result: worker_recovered_within_120s
    - name: metric_collection
      description: Verify all metrics are being collected
      expected_result: all_metrics_populated
    - name: dependency_check
      description: Verify dependency health checks are running
      expected_result: all_dependencies_checked
```

---

## Health States

### HEALTHY

All pipeline workers are responsive, resources are within normal bounds, and all dependencies are available.

```
State: HEALTHY
├── All 50 automation files accessible
├── All pipeline workers responding to heartbeat
├── CPU usage < 70%
├── Memory usage < 75%
├── All critical dependencies available
├── Integrity checks passing
└── Self-test: all passed
```

**Transition conditions:**
- All heartbeat responses received within timeout
- Resource usage within thresholds
- All critical dependencies responding
- No integrity violations detected

### DEGRADED

One or more non-critical components are failing, or resource usage is elevated but not critical.

```
State: DEGRADED
├── Some pipeline workers responding slowly
├── CPU usage 70-90%
├── Memory usage 75-90%
├── Non-critical dependencies unavailable
├── OR: 1-2 workers missed heartbeat
└── Self-test: minor failures
```

**Transition conditions:**
- From HEALTHY: any non-critical component fails or resources exceed warning thresholds
- From UNHEALTHY: some recovery achieved but not fully restored
- Auto-recovery actions are initiated in this state

**Recovery actions:**
- Restart affected worker processes
- Scale up resources if available
- Route traffic away from degraded workers
- Log detailed diagnostic information

### UNHEALTHY

Multiple critical components are failing, or a single critical component is completely unresponsive.

```
State: UNHEALTHY
├── Multiple pipeline workers unresponsive
├── CPU usage > 90%
├── Memory usage > 90%
├── Critical dependency unavailable
├── Integrity violations detected
├── 3+ consecutive heartbeat failures
└── Self-test: critical failures
```

**Transition conditions:**
- From DEGRADED: condition worsens despite recovery attempts
- From CRITICAL: partial recovery achieved
- Manual intervention may be required

**Recovery actions:**
- Force restart all affected workers
- Activate standby workers
- Redirect pipeline tasks to backup workers
- Alert operations team
- Begin incident documentation

### CRITICAL

System-wide failure or security compromise detected.

```
State: CRITICAL
├── Majority of workers unresponsive
├── System resources exhausted
├── Multiple critical dependencies failed
├── Security integrity violation detected
├── Data corruption suspected
└── Self-test: complete failure
```

**Transition conditions:**
- From UNHEALTHY: cascading failure spreads
- Direct from HEALTHY: sudden catastrophic failure or security event
- Requires immediate human intervention

**Recovery actions:**
- Emergency shutdown of all non-essential workers
- Activate disaster recovery procedures
- Isolate affected systems
- Notify all stakeholders immediately
- Begin forensic data collection

---

## Recovery Actions

### Automatic Recovery Procedures

| Action | Trigger | Procedure | Timeout |
|--------|---------|-----------|---------|
| Worker Restart | Heartbeat timeout > 3x | Kill and restart worker process | 60s |
| Resource Cleanup | Memory > 90% | Flush caches, terminate idle connections | 30s |
| Dependency Failover | Critical dep unavailable | Switch to standby instance | 15s |
| Queue Drain | Queue backlog > 1000 | Pause intake, drain existing tasks | 120s |
| Config Rollback | Config drift detected | Restore last known good config | 10s |
| Pipeline Failover | Primary pipeline down | Switch to backup pipeline | 30s |

### Manual Recovery Procedures

| Action | Trigger | Procedure | Owner |
|--------|---------|-----------|-------|
| System Restart | Automatic recovery failed | Full system restart | DevOps |
| Data Recovery | Data corruption detected | Restore from backup | Data Team |
| Security Response | Integrity violation | Incident response procedure | Security |
| Capacity Scaling | Resource exhaustion | Add compute resources | Infrastructure |

### Recovery Priorities

| Priority | Pipeline | Recovery Time Objective | Recovery Time Actual |
|----------|----------|------------------------|---------------------|
| P0 | scan-pipeline | 5 minutes | < 2 minutes |
| P0 | orchestration-pipeline | 5 minutes | < 3 minutes |
| P0 | chain-pipeline | 5 minutes | < 2 minutes |
| P1 | recon-pipeline | 15 minutes | < 10 minutes |
| P1 | vuln-pipeline | 15 minutes | < 10 minutes |
| P1 | auth-pipeline | 15 minutes | < 10 minutes |
| P2 | fuzz-pipeline | 30 minutes | < 20 minutes |
| P2 | browser-pipeline | 30 minutes | < 15 minutes |
| P3 | analysis-pipeline | 60 minutes | < 30 minutes |
| P3 | report-pipeline | 60 minutes | < 30 minutes |

---

## Health Metrics

### Core Metrics

| Metric | Description | Type | Unit |
|--------|-------------|------|------|
| pipeline.uptime | Total uptime of pipeline | Gauge | seconds |
| pipeline.workers.active | Number of active workers | Gauge | count |
| pipeline.workers.total | Total registered workers | Gauge | count |
| pipeline.tasks.completed | Tasks completed since start | Counter | count |
| pipeline.tasks.failed | Tasks failed since start | Counter | count |
| pipeline.tasks.queued | Tasks currently in queue | Gauge | count |
| pipeline.tasks.avg_duration | Average task duration | Histogram | milliseconds |
| pipeline.cpu.usage | CPU usage across workers | Gauge | percent |
| pipeline.memory.usage | Memory usage across workers | Gauge | percent |
| pipeline.disk.usage | Disk usage for results | Gauge | percent |
| pipeline.network.bytes_sent | Network bytes transmitted | Counter | bytes |
| pipeline.network.bytes_recv | Network bytes received | Counter | bytes |
| pipeline.errors.total | Total errors encountered | Counter | count |
| pipeline.recovery.attempts | Recovery action attempts | Counter | count |
| pipeline.recovery.successes | Successful recoveries | Counter | count |
| pipeline.health.state | Current health state | Enum | state |
| pipeline.health.last_check | Last health check timestamp | Gauge | unix_ts |
| pipeline.health.check_duration | Health check duration | Histogram | milliseconds |

### Pipeline-Specific Metrics

| Pipeline | Metric | Description |
|----------|--------|-------------|
| scan-pipeline | scan.targets_scanned | Total targets scanned |
| scan-pipeline | scan.vulns_found | Vulnerabilities discovered |
| scan-pipeline | scan.false_positives | False positives filtered |
| recon-pipeline | recon.subdomains_found | Subdomains discovered |
| recon-pipeline | recon.endpoints_found | Endpoints discovered |
| recon-pipeline | recon.tech_stack_hits | Technology fingerprints matched |
| vuln-pipeline | vuln.tested | Vulnerability tests executed |
| vuln-pipeline | vuln.confirmed | Confirmed vulnerabilities |
| fuzz-pipeline | fuzz.requests_sent | Fuzzing requests sent |
| fuzz-pipeline | fuzz.unique_responses | Unique response codes |
| chain-pipeline | chain.chains_executed | Attack chains executed |
| chain-pipeline | chain.chains_successful | Successful chain completions |
| browser-pipeline | browser.pages_visited | Pages visited |
| browser-pipeline | browser.js_executed | JS scripts executed |
| report-pipeline | report.generated | Reports generated |
| report-pipeline | report.avg_time | Average report generation time |

---

## Alerting Configuration

### Alert Rules

```yaml
alerting:
  enabled: true
  channels:
    - type: log
      level: info
      destination: /var/log/automation-health.log
    - type: webhook
      url: ${ALERT_WEBHOOK_URL}
      method: POST
      retry: 3
    - type: email
      recipients:
        - ${OPS_TEAM_EMAIL}
      subject_prefix: "[Automation Health]"
    - type: slack
      webhook_url: ${SLACK_WEBHOOK_URL}
      channel: "#automation-alerts"

  rules:
    - name: worker_down
      condition: heartbeat_missed >= 3
      severity: warning
      channels: [log, webhook]
      cooldown: 300s

    - name: worker_critical
      condition: heartbeat_missed >= 5
      severity: critical
      channels: [log, webhook, email, slack]
      cooldown: 60s

    - name: resource_warning
      condition: cpu_usage > 70 OR memory_usage > 75
      severity: warning
      channels: [log, webhook]
      cooldown: 300s

    - name: resource_critical
      condition: cpu_usage > 90 OR memory_usage > 90
      severity: critical
      channels: [log, webhook, email, slack]
      cooldown: 60s

    - name: dependency_failure
      condition: critical_dependency_unavailable
      severity: critical
      channels: [log, webhook, email, slack]
      cooldown: 120s

    - name: integrity_violation
      condition: integrity_check_failed
      severity: critical
      channels: [log, webhook, email, slack]
      cooldown: 0s

    - name: pipeline_error_spike
      condition: error_rate > 10% over 5m
      severity: warning
      channels: [log, webhook]
      cooldown: 300s

    - name: recovery_failed
      condition: recovery_attempt_failed
      severity: critical
      channels: [log, webhook, email, slack]
      cooldown: 60s
```

### Severity Levels

| Level | Description | Response Time | Escalation |
|-------|-------------|---------------|------------|
| info | Normal operational events | N/A | None |
| warning | Degraded performance or non-critical failure | 15 minutes | Team lead |
| error | Significant failure affecting operations | 5 minutes | Engineering |
| critical | System-wide failure or security event | Immediate | All stakeholders |

### Alert Aggregation

```yaml
aggregation:
  window_size: 5m
  min_alerts: 3
  strategy: grouped
  group_by: [pipeline, severity]
  suppress_duplicates: true
  escalation_after: 15m
```

---

## Health History

### History Retention

| Data Type | Retention Period | Storage | Compression |
|-----------|-----------------|---------|-------------|
| Heartbeat logs | 30 days | Local | gzip |
| Health state changes | 90 days | Local | gzip |
| Alert history | 180 days | Local | gzip |
| Recovery actions | 180 days | Local | gzip |
| Metric snapshots | 7 days | Local | none |
| Aggregated metrics | 365 days | Local | gzip |

### History Queries

```yaml
history_queries:
  - name: state_transitions
    description: Query health state changes over time
    time_range: configurable
    output: timeline

  - name: recovery_effectiveness
    description: Analyze recovery action success rates
    time_range: 30d
    output: statistics

  - name: uptime_report
    description: Generate uptime report for each pipeline
    time_range: configurable
    output: report

  - name: incident_timeline
    description: Reconstruct timeline of an incident
    time_range: around_incident
    output: timeline
```

### Historical State Machine

```
HEALTHY ←→ DEGRADED ←→ UNHEALTHY ←→ CRITICAL
  ↓            ↓            ↓            ↓
  └── direct ──┘            │            │
       transition           │            │
                            └────direct──┘
                             transition
```

---

## Pipeline Worker Health Profiles

### Scan Pipeline Workers (CRITICAL)

| Worker | File | Check Interval | Timeout | Max Failures |
|--------|------|---------------|---------|--------------|
| vuln-scanner | 03-Vulnerability-Scanning-Automation.md | 15s | 5s | 3 |
| sqli-worker | 12-SQL-Injection-Automation.md | 15s | 5s | 3 |
| xss-worker | 13-XSS-Detection-Automation.md | 15s | 5s | 3 |
| ssrf-worker | 14-SSRF-Testing-Automation.md | 15s | 5s | 3 |
| cmdi-worker | 16-Command-Injection-Automation.md | 15s | 5s | 3 |

### Recon Pipeline Workers (HIGH)

| Worker | File | Check Interval | Timeout | Max Failures |
|--------|------|---------------|---------|--------------|
| subdomain-worker | 01-Subdomain-Enumeration-Automation.md | 30s | 10s | 5 |
| portscan-worker | 02-Port-Scanning-Automation.md | 30s | 10s | 5 |
| api-discovery | 05-API-Endpoint-Discovery.md | 30s | 10s | 5 |
| target-scout | 23-Target-Scouting-Automation.md | 30s | 10s | 5 |
| dns-worker | 41-DNS-Data-Extraction-Automation.md | 30s | 10s | 5 |
| email-recon | 42-Email-Recon-Automation.md | 30s | 15s | 5 |
| endpoint-map | 46-Endpoint-Mapping-Automation.md | 30s | 10s | 5 |

### Orchestration Pipeline (CRITICAL)

| Worker | File | Check Interval | Timeout | Max Failures |
|--------|------|---------------|---------|--------------|
| orchestrator | 50-Workflow-Orchestration-Automation.md | 10s | 3s | 2 |
| chain-runner | 30-Tool-Chaining-Automation.md | 15s | 5s | 3 |

---

## Configuration

### Health Check Configuration

```yaml
health_config:
  version: "2.0"
  domain: "advanced-automation"
  enabled: true
  
  global:
    check_interval: 30s
    recovery_enabled: true
    max_concurrent_recoveries: 3
    history_retention_days: 90
    
  pipeline_config:
    scan_pipeline:
      health_check_interval: 15s
      heartbeat_timeout: 5s
      max_missed_beats: 3
      recovery_strategy: restart
      priority: CRITICAL
      
    recon_pipeline:
      health_check_interval: 30s
      heartbeat_timeout: 10s
      max_missed_beats: 5
      recovery_strategy: restart
      priority: HIGH
      
    vuln_pipeline:
      health_check_interval: 15s
      heartbeat_timeout: 5s
      max_missed_beats: 3
      recovery_strategy: restart
      priority: HIGH
      
    orchestration_pipeline:
      health_check_interval: 10s
      heartbeat_timeout: 3s
      max_missed_beats: 2
      recovery_strategy: failover
      priority: CRITICAL
```

### Logging Configuration

```yaml
logging:
  health_checks:
    level: debug
    destination: /var/log/automation-health-checks.log
    rotation: daily
    retention: 30d
    
  state_changes:
    level: info
    destination: /var/log/automation-state-changes.log
    rotation: daily
    retention: 90d
    
  recovery_actions:
    level: warn
    destination: /var/log/automation-recovery.log
    rotation: daily
    retention: 180d
```

---

## Health Dashboard Metrics

The health dashboard displays real-time status for all 50 automation files organized by pipeline group. Each file's health status is determined by the aggregate status of its associated worker process.

### Dashboard Sections

| Section | Description | Update Frequency |
|---------|-------------|-----------------|
| Overall Status | Aggregate health of all pipelines | Real-time |
| Pipeline Status | Individual pipeline health states | Every 5 seconds |
| Worker Status | Individual worker heartbeat status | Every heartbeat |
| Resource Usage | CPU, memory, disk, network | Every 15 seconds |
| Alert Feed | Recent alerts and notifications | Real-time |
| Recovery Log | Recent recovery actions and outcomes | Every 30 seconds |
| Trend Charts | Historical metrics and trends | Every 60 seconds |
| Dependency Map | Dependency health and connections | Every 30 seconds |

---

## Integration Points

### Upstream Dependencies

- **Configuration Service**: Provides pipeline configuration and parameters
- **Task Queue**: Receives scanning tasks from the orchestrator
- **Target Registry**: Provides target information for scanning

### Downstream Consumers

- **Result Store**: Receives scan results and findings
- **Alert System**: Receives health alerts and notifications
- **Report Generator**: Consumes scan results for reporting
- **Dashboard**: Displays real-time health information

### Integration Health Checks

```yaml
integrations:
  - name: config-service
    health_check: /health/config
    timeout: 3s
    retry: 2
    fallback: use-cached-config
    
  - name: task-queue
    health_check: /health/queue
    timeout: 5s
    retry: 3
    fallback: local-queue
    
  - name: result-store
    health_check: /health/db
    timeout: 5s
    retry: 3
    fallback: local-storage
```
