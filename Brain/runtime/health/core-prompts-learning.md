# Core Prompts Learning — Health Check System

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | Core-Prompts-Learning |
| Directory | `Core-Prompts-Learning/` |
| File Count | 50 files |
| Health Profile | Content Delivery Health |
| Worker Type | Content Delivery Workers |
| Check Interval | 45 seconds |
| Recovery Mode | Automatic with content cache rebuild |

---

## Overview

This health check system monitors the Core-Prompts-Learning domain which encompasses 50 specialized learning prompt modules covering educational content, training materials, vulnerability learning paths, and skill development frameworks. The health system ensures content delivery workers remain operational, learning materials are accessible, and educational pipelines provide consistent learning experiences.

### Domain File Registry

All 50 files within Core-Prompts-Learning/ are tracked as content-dependent components:

| # | File | Content Category | Criticality |
|---|------|-----------------|-------------|
| 01 | Reconnaissance-and-Asset-Discovery-Learning.md | recon-learning | HIGH |
| 02 | JavaScript-Analysis-and-Deobfuscation-Learning.md | js-learning | HIGH |
| 03 | API-Endpoint-Analysis-Learning.md | api-learning | HIGH |
| 04 | Authentication-and-Session-Management-Learning.md | auth-learning | CRITICAL |
| 05 | Authorization-and-Access-Control-Learning.md | authz-learning | CRITICAL |
| 06 | Input-Validation-and-Sanitization-Learning.md | input-learning | HIGH |
| 07 | Business-Logic-Flaws-Learning.md | logic-learning | HIGH |
| 08 | Client-Side-Storage-Security-Learning.md | client-learning | MEDIUM |
| 09 | Cryptography-and-Data-Protection-Learning.md | crypto-learning | HIGH |
| 10 | Error-Handling-and-Information-Disclosure-Learning.md | error-learning | HIGH |
| 11 | File-Upload-and-Processing-Learning.md | upload-learning | HIGH |
| 12 | Server-Side-Request-Forgery-SSRF-Learning.md | ssrf-learning | CRITICAL |
| 13 | Cross-Site-Request-Forgery-CSRF-Learning.md | csrf-learning | HIGH |
| 14 | Cross-Origin-Resource-Sharing-CORS-Learning.md | cors-learning | HIGH |
| 15 | Race-Conditions-and-Concurrency-Issues-Learning.md | race-learning | HIGH |
| 16 | Third-Party-Component-Analysis-Learning.md | component-learning | MEDIUM |
| 17 | Configuration-and-Misconfiguration-Hunting-Learning.md | config-learning | HIGH |
| 18 | Network-and-Infrastructure-Security-Learning.md | network-learning | HIGH |
| 19 | Mobile-and-API-Specific-Vulnerabilities-Learning.md | mobile-learning | HIGH |
| 20 | Reporting-and-Proof-of-Concept-Development-Learning.md | report-learning | MEDIUM |
| 21 | Web-Application-Firewall-WAF-Bypass-Learning.md | waf-learning | HIGH |
| 22 | HTTP-Request-Smuggling-Learning.md | smuggle-learning | HIGH |
| 23 | Subdomain-Takeover-Learning.md | subdomain-learning | HIGH |
| 24 | Host-Header-Injection-Learning.md | host-learning | MEDIUM |
| 25 | XML-External-Entity-XXE-Injection-Learning.md | xxe-learning | HIGH |
| 26 | Insecure-Deserialization-Learning.md | deser-learning | HIGH |
| 27 | Command-Injection-Learning.md | cmdi-learning | CRITICAL |
| 28 | NoSQL-Injection-Learning.md | nosql-learning | HIGH |
| 29 | GraphQL-Vulnerabilities-Learning.md | graphql-learning | HIGH |
| 30 | WebSocket-Security-Learning.md | ws-learning | MEDIUM |
| 31 | Server-Side-Template-Injection-SSTI-Learning.md | ssti-learning | CRITICAL |
| 32 | JSON-Web-Token-JWT-Vulnerabilities-Learning.md | jwt-learning | HIGH |
| 33 | Content-Security-Policy-CSP-Bypass-Learning.md | csp-learning | MEDIUM |
| 34 | Clickjacking-and-UI-Redressing-Learning.md | clickjack-learning | MEDIUM |
| 35 | HTTP-Parameter-Pollution-Learning.md | hpp-learning | MEDIUM |
| 36 | LDAP-Injection-Learning.md | ldap-learning | HIGH |
| 37 | Session-Puzzling-and-Fixation-Learning.md | session-learning | HIGH |
| 38 | Insecure-File-Handling-Learning.md | file-learning | HIGH |
| 39 | Advanced-Client-Side-Attacks-Learning.md | client-adv-learning | HIGH |
| 40 | Cloud-Security-and-Misconfigurations-Learning.md | cloud-learning | HIGH |
| 41 | Third-Party-Integration-Security-Learning.md | integration-learning | HIGH |
| 42 | Mobile-Application-Security-Learning.md | mobile-sec-learning | HIGH |
| 43 | IoT-and-Embedded-Device-Security-Learning.md | iot-learning | MEDIUM |
| 44 | API-Security-and-GraphQL-Learning.md | api-sec-learning | HIGH |
| 45 | WebAssembly-and-Modern-Web-Technologies-Learning.md | wasm-learning | MEDIUM |
| 46 | Blockchain-and-Cryptocurrency-Security-Learning.md | blockchain-learning | MEDIUM |
| 47 | Automation-and-Tool-Development-Learning.md | automation-learning | HIGH |
| 48 | Advanced-Reverse-Engineering-Learning.md | reverse-learning | HIGH |
| 49 | Compliance-and-Regulatory-Security-Learning.md | compliance-learning | MEDIUM |
| 50 | Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md | threat-learning | HIGH |

---

## Health Check Types

### 1. Heartbeat Monitoring

```yaml
heartbeat:
  enabled: true
  interval_seconds: 45
  timeout_seconds: 12
  max_missed_beats: 3
  protocol: internal-ipc
  response_format: json
  fields:
    - worker_id
    - timestamp
    - content_loaded
    - active_sessions
    - delivery_latency
    - cache_hit_rate
```

**Content Delivery Worker Heartbeat Groups:**

| Group | Workers | Priority |
|-------|---------|----------|
| core-learning | 04, 05, 12, 27, 31 | CRITICAL |
| injection-learning | 13, 25, 26, 28, 36 | HIGH |
| auth-learning | 04, 05, 32, 37 | CRITICAL |
| api-learning | 03, 19, 29, 30, 44 | HIGH |
| web-learning | 02, 14, 21, 33, 34 | HIGH |
| network-learning | 18, 22, 40 | HIGH |
| advanced-learning | 39, 45, 46, 47, 48 | HIGH |
| compliance-learning | 49, 50 | MEDIUM |
| iot-learning | 43 | MEDIUM |
| report-learning | 20 | MEDIUM |

### 2. Resource Monitoring

```yaml
resource_checks:
  cpu:
    warning_threshold: 65%
    critical_threshold: 85%
    check_interval: 30s
  memory:
    warning_threshold: 70%
    critical_threshold: 90%
    check_interval: 30s
    content_cache_overhead: 30%
  disk:
    warning_threshold: 75%
    critical_threshold: 92%
    check_interval: 60s
  content_cache:
    warning_threshold: 80%
    critical_threshold: 95%
    check_interval: 30s
  delivery_pool:
    min_idle_workers: 2
    max_concurrent_deliveries: 100
    check_interval: 10s
```

### 3. Dependency Health Checks

```yaml
dependencies:
  internal:
    - name: content-store
      type: storage
      health_endpoint: /health/content
      timeout: 3s
      critical: true
    - name: learning-engine
      type: service
      health_endpoint: /health/learning
      timeout: 5s
      critical: true
    - name: session-manager
      type: service
      health_endpoint: /health/sessions
      timeout: 5s
      critical: true
    - name: progress-tracker
      type: service
      health_endpoint: /health/progress
      timeout: 5s
      critical: false
  external:
    - name: api-service
      type: external
      health_endpoint: /health/api
      timeout: 10s
      critical: false
```

### 4. Integrity Checks

```yaml
integrity:
  content_files:
    enabled: true
    check_interval: 3600s
    validate_all_50_files: true
    algorithm: sha256
  content_accuracy:
    enabled: true
    check_interval: 86400s
    validate_technical_accuracy: true
  learning_paths:
    enabled: true
    check_interval: 3600s
    validate_path_completeness: true
```

### 5. Self-Test Procedures

```yaml
self_test:
  enabled: true
  interval: 300s
  procedures:
    - name: content_delivery
      description: Verify content can be delivered
      expected_result: content_delivered_successfully
    - name: learning_path_validation
      description: Verify learning paths are complete
      expected_result: all_paths_valid
    - name: session_tracking
      description: Verify session tracking works
      expected_result: sessions_tracked_correctly
    - name: content_accuracy
      description: Verify content technical accuracy
      expected_result: accuracy_above_threshold
```

---

## Health States

### HEALTHY

All content delivery workers are operational, learning materials are accessible, and delivery is performing well.

```
State: HEALTHY
├── All 50 learning files accessible
├── All content workers responding
├── Delivery latency < 200ms
├── Cache hit rate > 85%
├── All dependencies available
└── Self-test: all passed
```

### DEGRADED

Some content workers are slow, or cache hit rates have dropped.

```
State: DEGRADED
├── Some workers responding slowly
├── Delivery latency 200-500ms
├── Cache hit rate 70-85%
├── Non-critical dependency unavailable
└── Recovery actions initiated
```

### UNHEALTHY

Multiple content workers are down, or content delivery is failing.

```
State: UNHEALTHY
├── Multiple workers unresponsive
├── Delivery latency > 500ms
├── Cache hit rate < 70%
├── Critical dependency unavailable
└── Manual intervention needed
```

### CRITICAL

Content delivery system failure, content corruption, or complete system breakdown.

```
State: CRITICAL
├── Majority of workers down
├── Content corruption detected
├── Complete delivery failure
└── Immediate intervention required
```

---

## Recovery Actions

| Action | Trigger | Procedure | Timeout |
|--------|---------|-----------|---------|
| Worker Restart | Heartbeat timeout 3x | Restart content worker | 45s |
| Cache Rebuild | Cache corruption | Rebuild content cache | 300s |
| Content Reload | Content corruption | Reload content from source | 120s |
| Session Recovery | Session data loss | Recover session state | 60s |
| Pool Scale | All workers busy | Spin up additional workers | 60s |
| Config Reload | Config drift | Reload delivery config | 10s |

---

## Health Metrics

| Metric | Description | Type | Unit |
|--------|-------------|------|------|
| learning.workers.active | Active content workers | Gauge | count |
| learning.content.loaded | Loaded content files | Gauge | count |
| learning.sessions.active | Active learning sessions | Gauge | count |
| learning.sessions.total | Total sessions | Counter | count |
| learning.delivery.latency | Delivery latency | Histogram | milliseconds |
| learning.delivery.throughput | Delivery throughput | Gauge | items/sec |
| learning.cache.hit_rate | Cache hit rate | Gauge | percent |
| learning.cache.size | Cache size | Gauge | entries |
| learning.progress.completed | Completed learning paths | Counter | count |
| learning.progress.avg_score | Average score | Gauge | percent |
| learning.cpu.usage | CPU usage | Gauge | percent |
| learning.memory.usage | Memory usage | Gauge | percent |

---

## Alerting Configuration

```yaml
alerting:
  rules:
    - name: worker_down
      condition: heartbeat_missed >= 3
      severity: warning
      cooldown: 180s

    - name: delivery_latency_high
      condition: avg_latency > 500ms
      severity: warning
      cooldown: 300s

    - name: cache_hit_rate_low
      condition: cache_hit_rate < 70%
      severity: warning
      cooldown: 300s

    - name: content_corruption
      condition: content_integrity_check_failed
      severity: critical
      cooldown: 60s

    - name: session_data_loss
      condition: session_integrity_failed
      severity: warning
      cooldown: 300s
```

---

## Health History

| Data Type | Retention | Storage |
|-----------|-----------|---------|
| Worker heartbeat logs | 30 days | Local |
| Content delivery logs | 90 days | Local |
| Session logs | 90 days | Local |
| Recovery actions | 90 days | Local |
| Metric snapshots | 7 days | Local |
| Aggregated metrics | 365 days | Local |

---

## Integration Points

| Integration | Type | Health Endpoint | Critical |
|-------------|------|----------------|----------|
| content-store | storage | /health/content | YES |
| learning-engine | service | /health/learning | YES |
| session-manager | service | /health/sessions | YES |
| progress-tracker | service | /health/progress | NO |
| api-service | external | /health/api | NO |

---

## Content Delivery Configuration

```yaml
content_config:
  version: "2.0"
  domain: "core-prompts-learning"
  enabled: true

  global:
    health_check_interval: 45s
    recovery_enabled: true
    max_concurrent_sessions: 100
    session_timeout_seconds: 7200

  core_learning:
    workers: [04, 05, 12, 27, 31]
    health_check_interval: 30s
    heartbeat_timeout: 5s
    max_missed_beats: 3
    recovery_strategy: restart
    priority: CRITICAL
    content_freshness: 7d

  injection_learning:
    workers: [13, 25, 26, 28, 36]
    health_check_interval: 45s
    heartbeat_timeout: 10s
    max_missed_beats: 3
    recovery_strategy: restart
    priority: HIGH
    content_freshness: 14d

  auth_learning:
    workers: [04, 05, 32, 37]
    health_check_interval: 30s
    heartbeat_timeout: 5s
    max_missed_beats: 3
    recovery_strategy: restart
    priority: CRITICAL
    content_freshness: 14d

  api_learning:
    workers: [03, 19, 29, 30, 44]
    health_check_interval: 45s
    heartbeat_timeout: 10s
    max_missed_beats: 3
    recovery_strategy: restart
    priority: HIGH
    content_freshness: 14d

  advanced_learning:
    workers: [39, 45, 46, 47, 48]
    health_check_interval: 60s
    heartbeat_timeout: 15s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: HIGH
    content_freshness: 30d

  compliance_learning:
    workers: [49, 50]
    health_check_interval: 120s
    heartbeat_timeout: 20s
    max_missed_beats: 5
    recovery_strategy: restart
    priority: MEDIUM
    content_freshness: 30d
```

---

## Learning Session Health

```yaml
session_health:
  max_active_sessions: 100
  session_timeout: 7200s
  session_cleanup_interval: 300s
  session_data_integrity_check: true
  session_backup_enabled: true
  session_backup_interval: 600s

  session_states:
    - active: Session is currently in use
    - idle: Session has no activity for 300s
    - expired: Session has exceeded timeout
    - corrupted: Session data integrity failed
    - recovered: Session recovered from backup

  session_recovery:
    auto_recovery: true
    max_recovery_attempts: 3
    recovery_timeout: 60s
    backup_retention: 24h
```

---

## Content Quality Configuration

```yaml
content_quality:
  enabled: true
  check_interval: 3600s

  quality_metrics:
    - name: technical_accuracy
      target: 95%
      warning: 90%
      critical: 80%
    - name: content_freshness
      target: 7d
      warning: 14d
      critical: 30d
    - name: completeness
      target: 100%
      warning: 95%
      critical: 90%
    - name: learning_path_coverage
      target: 100%
      warning: 95%
      critical: 90%

  quality_checks:
    - name: accuracy_review
      frequency: weekly
      reviewer: automated
    - name: content_audit
      frequency: monthly
      reviewer: automated
    - name: learning_path_validation
      frequency: weekly
      reviewer: automated
```

---

## Learning Dashboard

| Dashboard Section | Description | Update Frequency |
|-------------------|-------------|-----------------|
| Worker Status | Content worker health | Every heartbeat |
| Session Status | Active learning sessions | Real-time |
| Content Status | Content availability | Every 60s |
| Delivery Metrics | Delivery latency, throughput | Every 30s |
| Cache Status | Content cache hit rates | Every 30s |
| Progress Metrics | Learning progress | Every 60s |
| Quality Metrics | Content quality scores | Every hour |
| Trend Charts | Learning trends | Every 3600s |

---

## Learning Logging

```yaml
logging:
  content_health:
    level: info
    destination: /var/log/learning-health.log
    rotation: daily
    retention: 30d

  session_logs:
    level: info
    destination: /var/log/learning-sessions.log
    rotation: daily
    retention: 90d

  delivery_logs:
    level: debug
    destination: /var/log/learning-delivery.log
    rotation: daily
    retention: 30d

  content_quality:
    level: info
    destination: /var/log/learning-quality.log
    rotation: daily
    retention: 90d

  recovery_actions:
    level: warn
    destination: /var/log/learning-recovery.log
    rotation: daily
    retention: 90d

  progress_tracking:
    level: info
    destination: /var/log/learning-progress.log
    rotation: daily
    retention: 365d
```

---

## Learning Performance Baselines

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| Content delivery latency | < 200ms | > 500ms | > 1000ms |
| Cache hit rate | > 85% | < 70% | < 50% |
| Session creation time | < 1s | > 5s | > 10s |
| Content accuracy | > 95% | < 90% | < 80% |
| Learning path completion | > 80% | < 60% | < 40% |
| Average score | > 75% | < 60% | < 50% |
| Worker error rate | < 1% | > 5% | > 10% |
| Content freshness | < 7d | > 14d | > 30d |
