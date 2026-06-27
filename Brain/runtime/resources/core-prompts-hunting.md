# Resource Monitoring: Core-Prompts-Hunting

## Domain: Core-Prompts-Hunting (50 Files)

---

## Title
Resource Monitoring Specification for Core-Prompts-Hunting Domain

## Overview
This document defines comprehensive resource monitoring for the Core-Prompts-Hunting domain, covering all 50 files in the Core-Prompts-hunting/ directory. Resource monitoring focuses on per-tool resource consumption during vulnerability hunting, tracking CPU and memory usage for different hunting techniques, and measuring the efficiency of prompt-driven hunting workflows.

## Domain Mapping

| Metric Category | Primary Use Case | Hunting Focus |
|----------------|-----------------|---------------|
| CPU | Tool execution and analysis | PER-TOOL COST |
| Memory | Pattern matching and results | HUNTING MEMORY |
| Network | Scanning and probing | PROBE BANDWIDTH |
| Disk | Results and evidence storage | HUNTING STORAGE |
| Time | Hunting session duration | EFFICIENCY TRACKING |

## File Reference Index (50 Files)

### Core Hunting Prompts (1-10)
1. `core-prompts-hunting/00-hunting-overview.md` — Master hunting resource architecture
2. `core-prompts-hunting/01-reconnaissance-prompt.md` — Recon resource requirements
3. `core-prompts-hunting/02-subdomain-discovery.md` — Subdomain enum resources
4. `core-prompts-hunting/03-port-scanning.md` — Port scan CPU/network
5. `core-prompts-hunting/04-service-detection.md` — Service detection resources
6. `core-prompts-hunting/05-web-crawling.md` — Web crawl resources
7. `core-prompts-hunting/06-directory-fuzzing.md` — Fuzzing CPU/disk
8. `core-prompts-hunting/07-parameter-discovery.md` — Parameter discovery resources
9. `core-prompts-hunting/08-technology-fingerprinting.md` — Tech fingerprint resources
10. `core-prompts-hunting/09-attack-surface-mapping.md` — Surface mapping resources

### Vulnerability-Specific Prompts (11-20)
11. `core-prompts-hunting/10-xss-hunting.md` — XSS hunting CPU/patterns
12. `core-prompts-hunting/11-sqli-hunting.md` — SQLi hunting network/CPU
13. `core-prompts-hunting/12-ssrf-hunting.md` — SSRF hunting network
14. `core-prompts-hunting/13-idor-hunting.md` — IDOR hunting CPU/memory
15. `core-prompts-hunting/14-auth-bypass-hunting.md` — Auth bypass CPU
16. `core-prompts-hunting/15-file-upload-hunting.md` — File upload disk/CPU
17. `core-prompts-hunting/16-xxe-hunting.md` — XXE hunting network
18. `core-prompts-hunting/17-ssti-hunting.md` — SSTI hunting CPU
19. `core-prompts-hunting/18-rce-hunting.md` — RCE hunting CPU/network
20. `core-prompts-hunting/19-csrf-hunting.md` — CSRF hunting CPU

### Advanced Hunting Prompts (21-30)
21. `core-prompts-hunting/20-graphql-hunting.md` — GraphQL hunting resources
22. `core-prompts-hunting/21-api-hunting.md` — API hunting resources
23. `core-prompts-hunting/22-oauth-hunting.md` — OAuth hunting CPU
24. `core-prompts-hunting/23-jwt-hunting.md` — JWT hunting CPU
25. `core-prompts-hunting/24-websocket-hunting.md` — WebSocket network
26. `core-prompts-hunting/25-subdomain-takeover.md` — Subdomain takeover resources
27. `core-prompts-hunting/26-cloud-misconfig.md` — Cloud misconfig resources
28. `core-prompts-hunting/27-cors-misconfig.md` — CORS hunting CPU
29. `core-prompts-hunting/28-open-redirect.md` — Open redirect CPU
30. `core-prompts-hunting/29-information-disclosure.md` — Info disclosure CPU

### Automation and Efficiency Prompts (31-40)
31. `core-prompts-hunting/30-automated-scanning.md` — Auto-scan resources
32. `core-prompts-hunting/31-manual-testing.md` — Manual test resources
33. `core-prompts-hunting/32-hybrid-approach.md` — Hybrid approach resources
34. `core-prompts-hunting/33-workflow-optimization.md` — Workflow efficiency
35. `core-prompts-hunting/34-tool-chaining.md` — Tool chain resources
36. `core-prompts-hunting/35-result-correlation.md` — Correlation CPU/memory
37. `core-prompts-hunting/36-false-positive-filtering.md` — FP filtering CPU
38. `core-prompts-hunting/37-severity-assessment.md` — Severity scoring CPU
39. `core-prompts-hunting/38-priority-ranking.md` — Priority ranking CPU
40. `core-prompts-hunting/39-hunting-report.md` — Report generation CPU

### Specialized Hunting Prompts (41-50)
41. `core-prompts-hunting/40-mobile-hunting.md` — Mobile hunting resources
42. `core-prompts-hunting/41-iot-hunting.md` — IoT hunting resources
43. `core-prompts-hunting/42-cloud-native-hunting.md` — Cloud-native resources
44. `core-prompts-hunting/43-container-hunting.md` — Container hunting resources
45. `core-prompts-hunting/44-kubernetes-hunting.md` — K8s hunting resources
46. `core-prompts-hunting/45-database-hunting.md` — Database hunting resources
47. `core-prompts-hunting/46-email-hunting.md` — Email hunting resources
48. `core-prompts-hunting/47-dns-hunting.md` — DNS hunting network
49. `core-prompts-hunting/48-wireless-hunting.md` — Wireless hunting resources
50. `core-prompts-hunting/49-hunting-sessions.md` — Session management resources

---

## Resource Metrics

### CPU Metrics (Per-Tool)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `hunt.cpu.recon.total` | Recon CPU total | ms | per session |
| `hunt.cpu.scanner.total` | Scanner CPU total | ms | per session |
| `hunt.cpu.fuzzer.total` | Fuzzer CPU total | ms | per session |
| `hunt.cpu.analyzer.total` | Analyzer CPU total | ms | per session |
| `hunt.cpu.tool.init` | Tool initialization CPU | ms | per init |
| `hunt.cpu.tool.exec` | Tool execution CPU | ms | per exec |
| `hunt.cpu.pattern.match` | Pattern matching CPU | ms | per match |
| `hunt.cpu.result.filter` | Result filtering CPU | ms | per filter |
| `hunt.cpu.correlation` | Correlation CPU | ms | per correlation |
| `hunt.cpu.total` | Total hunting CPU | ms | per session |

### Memory Metrics (Hunting)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `hunt.mem.pattern.db` | Pattern database | MB | 5min |
| `hunt.mem.result.buffer` | Result buffer | MB | 1s |
| `hunt.mem.target.cache` | Target cache | MB | 5min |
| `hunt.mem.scan.state` | Scan state data | MB | 5s |
| `hunt.mem.correlation` | Correlation data | MB | 5min |
| `hunt.mem.findings.store` | Findings store | MB | 1min |
| `hunt.mem.temp.data` | Temporary data | MB | 5s |
| `hunt.mem.total` | Total hunting memory | MB | 1min |
| `hunt.mem.peak` | Peak memory usage | MB | per session |
| `hunt.mem.efficiency` | Memory efficiency | ratio | per session |

### Network Metrics (Hunting)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `hunt.net.recon.bytes` | Recon data transferred | bytes | per session |
| `hunt.net.scan.bytes` | Scan data transferred | bytes | per session |
| `hunt.net.probe.count` | Probe requests made | count | 1s |
| `hunt.net.probe.success` | Successful probes | count | 1s |
| `hunt.net.probe.fail` | Failed probes | count | 1s |
| `hunt.net.dns.lookups` | DNS lookups | count | 5s |
| `hunt.net.http.requests` | HTTP requests | count | 1s |
| `hunt.net.http.responses` | HTTP responses | count | 1s |
| `hunt.net.total.bandwidth` | Total bandwidth | MB | per session |
| `hunt.net.effective.bw` | Effective bandwidth | Mbps | 5s |

### Disk Metrics (Hunting)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `hunt.disk.results.size` | Results data size | MB | per scan |
| `hunt.disk.evidence.size` | Evidence size | MB | per finding |
| `hunt.disk.temp.size` | Temp file size | MB | 5min |
| `hunt.disk.log.size` | Log file size | MB | 1h |
| `hunt.disk.cache.size` | Cache size | MB | 5min |
| `hunt.disk.total` | Total disk usage | GB | daily |
| `hunt.disk.write.iops` | Write operations | ops/s | 5s |
| `hunt.disk.read.iops` | Read operations | ops/s | 5s |
| `hunt.disk.latency` | Disk latency | ms | 5s |
| `hunt.disk.utilization` | Disk utilization | % | 10s |

### Time Metrics (Hunting)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `hunt.time.recon` | Recon duration | s | per session |
| `hunt.time.scanning` | Scanning duration | s | per session |
| `hunt.time.analysis` | Analysis duration | s | per session |
| `hunt.time.reporting` | Reporting duration | s | per session |
| `hunt.time.per.finding` | Time per finding | s | per finding |
| `hunt.time.per.target` | Time per target | s | per target |
| `hunt.time.efficiency` | Time efficiency | ratio | per session |
| `hunt.time.wasted` | Wasted time | s | per session |
| `hunt.time.idle` | Idle time | s | per session |
| `hunt.time.productive` | Productive time | s | per session |

---

## Quota Tables

### CPU Quotas by Hunting Tool

| Tool Category | Max CPU % | Max Duration | Max Concurrent | Priority |
|--------------|----------|--------------|----------------|----------|
| Subdomain Enum | 30% | 30 min | 2 | NORMAL |
| Port Scanner | 50% | 60 min | 1 | HIGH |
| Web Crawler | 40% | 120 min | 1 | NORMAL |
| Directory Fuzzer | 60% | 60 min | 1 | HIGH |
| Parameter Fuzzer | 50% | 45 min | 1 | HIGH |
| XSS Scanner | 30% | 30 min | 2 | NORMAL |
| SQLi Scanner | 40% | 45 min | 1 | HIGH |
| SSRF Scanner | 20% | 30 min | 2 | LOW |
| IDOR Scanner | 25% | 60 min | 1 | NORMAL |
| API Scanner | 35% | 45 min | 1 | NORMAL |

### Memory Quotas by Hunting Phase

| Phase | Min Memory | Max Memory | Buffer | OOM Policy |
|-------|-----------|------------|--------|------------|
| Reconnaissance | 64 MB | 512 MB | 128 MB | Kill |
| Scanning | 128 MB | 1 GB | 256 MB | Flush |
| Analysis | 256 MB | 2 GB | 512 MB | Flush |
| Correlation | 512 MB | 4 GB | 1 GB | No Kill |
| Reporting | 128 MB | 1 GB | 256 MB | Flush |
| Evidence Capture | 64 MB | 512 MB | 128 MB | Kill |
| Pattern Matching | 128 MB | 1 GB | 256 MB | Flush |
| Result Filtering | 64 MB | 512 MB | 128 MB | Kill |
| Temp Processing | 64 MB | 256 MB | 64 MB | Kill |
| Session State | 32 MB | 256 MB | 64 MB | Kill |

### Network Quotas by Hunting Type

| Hunting Type | Max Bandwidth | Max Requests | Max Connections | Timeout |
|-------------|--------------|--------------|-----------------|---------|
| Passive Recon | 1 Mbps | 100/hour | 5 | 30s |
| Active Recon | 10 Mbps | 1000/hour | 20 | 15s |
| Port Scanning | 50 Mbps | 5000/hour | 100 | 5s |
| Web Crawling | 20 Mbps | 2000/hour | 30 | 10s |
| Directory Fuzz | 30 Mbps | 10000/hour | 50 | 8s |
| Vulnerability Scan | 10 Mbps | 500/hour | 20 | 10s |
| API Testing | 5 Mbps | 500/hour | 10 | 10s |
| DNS Enumeration | 5 Mbps | 5000/hour | 30 | 15s |
| SSL/TLS Scan | 2 Mbps | 100/hour | 10 | 20s |
| Total Hunting | 100 Mbps | 20000/hour | 200 | N/A |

### Disk Quotas by Hunting Output

| Output Type | Max Size | Max Files | Rotation | Retention |
|-------------|----------|-----------|----------|-----------|
| Raw Scan Results | 500 MB | 1000 | Yes | 7 days |
| Filtered Findings | 100 MB | 500 | Yes | 30 days |
| Evidence Files | 200 MB | 200 | Yes | 30 days |
| Reports | 50 MB | 50 | Yes | 90 days |
| Logs | 200 MB | 100 | Yes | 7 days |
| Temp Data | 500 MB | 2000 | Yes | 1 day |
| Cache | 100 MB | 500 | Yes | 1 day |
| Pattern DB | 50 MB | 10 | No | 90 days |
| Session Data | 50 MB | 100 | Yes | 7 days |
| Total Hunting | 2 GB | 5000 | Mixed | Mixed |

---

## Alert Thresholds

### Critical Alerts (Hunting Failure)

| Alert ID | Condition | Threshold | Action |
|----------|-----------|-----------|--------|
| `HUNT-CPU-001` | CPU > 90% for 60s | 90% | Pause lowest scan |
| `HUNT-MEM-001` | Memory > 90% | 90% | Flush result buffer |
| `HUNT-NET-001` | Network > 100 Mbps | 100 Mbps | Throttle probes |
| `HUNT-DISK-001` | Disk > 95% | 95% | Emergency cleanup |
| `HUNT-CPU-002` | Tool crash | Crash | Auto-restart tool |
| `HUNT-MEM-002` | OOM kill | OOM | Restart session |
| `HUNT-NET-002` | Network failure > 50% | 50% | Pause hunting |
| `HUNT-DISK-002` | Write failure | Failure | Switch storage |

### Warning Alerts (Hunting Degradation)

| Alert ID | Condition | Threshold | Action |
|----------|-----------|-----------|--------|
| `HUNT-CPU-010` | CPU > 70% for 5min | 70% | Reduce parallelism |
| `HUNT-MEM-010` | Memory > 80% | 80% | Optimize usage |
| `HUNT-NET-010` | Bandwidth > 80% | 80% | Throttle traffic |
| `HUNT-DISK-010` | Disk > 80% | 80% | Start rotation |
| `HUNT-CPU-011` | Tool efficiency < 70% | 70% | Switch tool |
| `HUNT-MEM-011` | Fragmentation > 40% | 40% | Compact memory |
| `HUNT-NET-011` | Latency > 500ms | 500ms | Switch target |
| `HUNT-DISK-011` | IOPS > 80% | 80% | Queue operations |

### Informational Alerts (Hunting Tracking)

| Alert ID | Condition | Threshold | Action |
|----------|-----------|-----------|--------|
| `HUNT-CPU-020` | CPU > 50% | 50% | Log usage |
| `HUNT-MEM-020` | Memory > 50% | 50% | Log usage |
| `HUNT-NET-020` | Bandwidth > 50% | 50% | Log usage |
| `HUNT-DISK-020` | Disk > 50% | 50% | Log usage |
| `HUNT-CPU-021` | New finding | Any | Log finding |
| `HUNT-MEM-021` | Peak memory | Any peak | Log peak |

---

## Monitoring Dashboard Configuration

### Hunting Dashboard Layout

```yaml
dashboard:
  name: "Core Hunting Resource Monitor"
  refresh_interval: 5s
  layout:
    row_1:
      - panel: "Hunting CPU Usage"
        type: timeseries
        metrics: [hunt.cpu.total, hunt.cpu.tool.exec]
      - panel: "Hunting Memory"
        type: gauge
        metrics: [hunt.mem.total, hunt.mem.peak]
        thresholds: [512, 1024, 2048]
      - panel: "Hunting Network"
        type: timeseries
        metrics: [hunt.net.total.bandwidth, hunt.net.probe.count]
      - panel: "Hunting Disk"
        type: gauge
        metrics: [hunt.disk.total]
        thresholds: [1, 1.5, 2]
    
    row_2:
      - panel: "Per-Tool CPU"
        type: bar-chart
        metrics: [hunt.cpu.recon.total, hunt.cpu.scanner.total, hunt.cpu.fuzzer.total]
      - panel: "Per-Tool Memory"
        type: bar-chart
        metrics: [hunt.mem.pattern.db, hunt.mem.result.buffer, hunt.mem.target.cache]
      - panel: "Network Probes"
        type: timeseries
        metrics: [hunt.net.probe.success, hunt.net.probe.fail]
      - panel: "Hunting Timeline"
        type: timeline
        description: "Active hunting phases"
    
    row_3:
      - panel: "Resource Quotas"
        type: table
        columns: [tool, cpu_used, cpu_limit, mem_used, mem_limit, status]
      - panel: "Findings Rate"
        type: timeseries
        metrics: [hunt.time.per.finding]
      - panel: "Hunting Alerts"
        type: table
        columns: [alert_id, severity, tool, triggered_at]
```

---

## Enforcement Strategies

### CPU Enforcement (Per-Tool)

| Strategy | Trigger | Action | Recovery |
|----------|---------|--------|----------|
| Tool Throttling | CPU > 80% | Reduce tool threads | Auto-recover |
| Scan Suspension | CPU > 95% | Pause lowest priority scan | Manual resume |
| Tool Rotation | Tool inefficient | Switch to alternative | Auto-select |
| Parallel Limit | CPU saturated | Queue new tools | Auto-dequeue |
| Budget Cap | CPU > budget | Stop hunting | Next session |

### Memory Enforcement (Hunting)

| Strategy | Trigger | Action | Recovery |
|----------|---------|--------|----------|
| Result Limiting | Buffer > limit | Drop oldest results | Auto-reset |
| Pattern Cache | Cache > limit | LRU eviction | Auto-repopulate |
| State Compression | State > limit | Compress state | Auto-decompress |
| Memory Pool | Pool > limit | Reclaim idle pools | Auto-allocate |
| Emergency Release | Memory > 95% | Release non-essentials | Auto-reallocate |

### Network Enforcement (Hunting)

| Strategy | Trigger | Action | Recovery |
|----------|---------|--------|----------|
| Bandwidth Throttle | Usage > limit | Rate limit probes | Auto-recover |
| Connection Pool | Active > max | Queue connections | Auto-dequeue |
| DNS Cache | Lookups > threshold | Cache DNS results | TTL expiry |
| Timeout Reduction | Latency > threshold | Decrease timeout | Auto-restore |
| Target Rotation | Failures > threshold | Switch target | Auto-select |

### Disk Enforcement (Hunting)

| Strategy | Trigger | Action | Recovery |
|----------|---------|--------|----------|
| Result Rotation | Size > limit | Rotate results | Automatic |
| Temp Cleanup | Temp > limit | Delete temp files | N/A |
| Evidence Compression | Size > 80% | Compress evidence | Auto-decompress |
| Log Rotation | Size > limit | Rotate logs | Automatic |
| Emergency Purge | Size > 95% | Delete non-essential | Manual restore |

---

## Historical Metrics

### Collection Configuration

```yaml
historical_metrics:
  retention:
    raw_metrics: 24h
    aggregated_5min: 7d
    aggregated_1h: 30d
    aggregated_1d: 365d
  
  aggregation:
    - type: 5min
      functions: [avg, max, p95]
    - type: 1h
      functions: [avg, max]
    - type: 1d
      functions: [sum, avg, max]
  
  per_tool_tracking:
    enabled: true
    tools: [subfinder, nmap, httpx, ffuf, nuclei, gobuster, sqlmap, xsstrike]
  
  storage:
    engine: prometheus
    compression: snappy
```

### Key Performance Indicators

| KPI | Description | Target | Measurement |
|-----|-------------|--------|-------------|
| Hunting Efficiency | Findings per hour | > 2 | Per session |
| Tool Utilization | Active tool time / total | > 70% | Per session |
| CPU Efficiency | Useful work / total CPU | > 60% | Per session |
| Memory Efficiency | Peak / allocated ratio | < 80% | Per session |
| Network Efficiency | Successful / total probes | > 90% | Per session |
| Discovery Rate | New findings / session | > 3 | Per session |
| Time to Finding | Average time per finding | < 2 hours | Weekly |
| Tool Reliability | Tool uptime / total time | > 95% | Daily |
| Scan Coverage | Targets scanned / available | > 80% | Weekly |
| False Positive Rate | FP / total findings | < 5% | Weekly |

---

## Reference Summary

This resource monitoring specification for the Core-Prompts-Hunting domain provides:
- **50 file references** covering core hunting, vulnerability-specific, advanced, automation, and specialized prompts
- **50+ per-tool CPU, memory, network, disk, and time metrics** with collection intervals
- **4 quota tables** covering tool CPU, hunting phase memory, hunting type network, and output disk
- **24 alert thresholds** for hunting failure, degradation, and tracking
- **Complete hunting dashboard** with per-tool resource visualization
- **4 enforcement strategies** for CPU, memory, network, and disk per hunting tool
- **Historical metrics** with per-tool tracking and hunting efficiency KPIs

---

*Document Version: 1.0*
*Last Updated: 2025-01-15*
*Domain: Core-Prompts-Hunting*
*Total Files Referenced: 50*
