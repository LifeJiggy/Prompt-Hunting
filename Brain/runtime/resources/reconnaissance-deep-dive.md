# Resource Monitoring: Reconnaissance-Deep-Dive

## Domain: Reconnaissance-Deep-Dive (50 Files)

---

## Title
Resource Monitoring Specification for Reconnaissance-Deep-Dive Domain

## Overview
This document defines comprehensive resource monitoring for the Reconnaissance-Deep-Dive domain, covering all 50 files in the Reconnaissance-Deep-Dive/ directory. Resource monitoring focuses on network bandwidth for enumeration operations, DNS query rates, HTTP request throughput, and stealth resource management during reconnaissance activities.

## Domain Mapping

| Metric Category | Primary Use Case | Recon Focus |
|----------------|-----------------|------------|
| CPU | Recon tool execution | TOOL EXECUTION |
| Memory | Recon state and results | RECON MEMORY |
| Network | Enumeration traffic | BANDWIDTH TRACKING |
| Disk | Recon output storage | OUTPUT STORAGE |
| Time | Recon session duration | RECON EFFICIENCY |

## File Reference Index (50 Files)

### Recon Framework Files (1-10)
1. `reconnaissance-deep-dive/00-recon-overview.md` — Master recon resource architecture
2. `reconnaissance-deep-dive/01-recon-methodology.md` — Methodology resources
3. `reconnaissance-deep-dive/02-passive-recon.md` — Passive recon resources
4. `reconnaissance-deep-dive/03-active-recon.md` — Active recon resources
5. `reconnaissance-deep-dive/04-stealth-recon.md` — Stealth recon resources
6. `reconnaissance-deep-dive/05-recon-automation.md` — Automation resources
7. `reconnaissance-deep-dive/06-recon-workflow.md` — Workflow resources
8. `reconnaissance-deep-dive/07-recon-prioritization.md` — Prioritization resources
9. `reconnaissance-deep-dive/08-recon-validation.md` — Validation resources
10. `reconnaissance-deep-dive/09-recon-reporting.md` — Reporting resources

### Subdomain Enumeration Files (11-20)
11. `reconnaissance-deep-dive/10-subdomain-enumeration.md` — Subdomain enum resources
12. `reconnaissance-deep-dive/11-dns-enum-techniques.md` — DNS enum resources
13. `reconnaissance-deep-dive/12-subdomain-bruteforce.md` — Brute force resources
14. `reconnaissance-deep-dive/13-subdomain-takeover-check.md` — Takeover check resources
15. `reconnaissance-deep-dive/14-dns-zone-transfer.md` — Zone transfer resources
16. `reconnaissance-deep-dive/15-dns-record-analysis.md` — Record analysis resources
17. `reconnaissance-deep-dive/16-certificate-transparency.md` — CT log resources
18. `reconnaissance-deep-dive/17-web-archive-recon.md` — Wayback recon resources
19. `reconnaissance-deep-dive/18-search-engine-dorking.md` — Dorking resources
20. `reconnaissance-deep-dive/19-github-recon.md` — GitHub recon resources

### Network Reconnaissance Files (21-30)
21. `reconnaissance-deep-dive/20-port-scanning.md` — Port scan resources
22. `reconnaissance-deep-dive/21-service-detection.md` — Service detection resources
23. `reconnaissance-deep-dive/22-os-fingerprinting.md` — OS fingerprint resources
24. `reconnaissance-deep-dive/23-version-detection.md` — Version detection resources
25. `reconnaissance-deep-dive/24-network-mapping.md` — Network mapping resources
26. `reconnaissance-deep-dive/25-vulnerability-scanning.md` — Vuln scan resources
27. `reconnaissance-deep-dive/26-ssl-tls-recon.md` — SSL/TLS recon resources
28. `reconnaissance-deep-dive/27-waf-detection.md` — WAF detection resources
29. `reconnaissance-deep-dive/28-load-balancer-detection.md` — LB detection resources
30. `reconnaissance-deep-dive/29-cdn-detection.md` — CDN detection resources

### Web Reconnaissance Files (31-40)
31. `reconnaissance-deep-dive/30-web-crawling.md` — Web crawl resources
32. `reconnaissance-deep-dive/31-directory-discovery.md` — Directory discovery resources
33. `reconnaissance-deep-dive/32-file-discovery.md` — File discovery resources
34. `reconnaissance-deep-dive/33-parameter-discovery.md` — Parameter discovery resources
35. `reconnaissance-deep-dive/34-api-discovery.md` — API discovery resources
36. `reconnaissance-deep-dive/35-technology-fingerprinting.md` — Tech fingerprint resources
37. `reconnaissance-deep-dive/36-cms-detection.md` — CMS detection resources
38. `reconnaissance-deep-dive/37-waf-fingerprinting.md` — WAF fingerprint resources
39. `reconnaissance-deep-dive/38-web-server-fingerprinting.md` — Web server fingerprint
40. `reconnaissance-deep-dive/39-application-mapping.md` — Application mapping resources

### Specialized Reconnaissance Files (41-50)
41. `reconnaissance-deep-dive/40-cloud-reconnaissance.md` — Cloud recon resources
42. `reconnaissance-deep-dive/41-container-reconnaissance.md` — Container recon resources
43. `reconnaissance-deep-dive/42-kubernetes-reconnaissance.md` — K8s recon resources
44. `reconnaissance-deep-dive/43-api-reconnaissance.md` — API recon resources
45. `reconnaissance-deep-dive/44-mobile-reconnaissance.md` — Mobile recon resources
46. `reconnaissance-deep-dive/45-email-reconnaissance.md` — Email recon resources
47. `reconnaissance-deep-dive/46-social-reconnaissance.md` — Social recon resources
48. `reconnaissance-deep-dive/47-infrastructure-reconnaissance.md` — Infrastructure recon
49. `reconnaissance-deep-dive/48-personnel-reconnaissance.md` — Personnel recon resources
50. `reconnaissance-deep-dive/49-recon-intelligence.md` — Intelligence gathering resources

---

## Resource Metrics

### CPU Metrics (Recon Tools)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `recon.cpu.tool.init` | Tool initialization CPU | ms | per init |
| `recon.cpu.tool.exec` | Tool execution CPU | ms | per exec |
| `recon.cpu.dns.enum` | DNS enumeration CPU | ms | per enum |
| `recon.cpu.port.scan` | Port scan CPU | ms | per scan |
| `recon.cpu.web.crawl` | Web crawl CPU | ms | per crawl |
| `recon.cpu.dir.fuzz` | Directory fuzz CPU | ms | per fuzz |
| `recon.cpu.api.discover` | API discovery CPU | ms | per discover |
| `recon.cpu.fingerprint` | Fingerprint CPU | ms | per fingerprint |
| `recon.cpu.analysis` | Analysis CPU | ms | per analysis |
| `recon.cpu.total` | Total recon CPU | ms | per session |

### Memory Metrics (Recon State)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `recon.mem.target.list` | Target list memory | MB | 5min |
| `recon.mem.result.buffer` | Result buffer | MB | 1s |
| `recon.mem.dns.cache` | DNS cache | MB | 5min |
| `recon.mem.scan.state` | Scan state | MB | 5s |
| `recon.mem.temp.data` | Temporary data | MB | 5s |
| `recon.mem.total` | Total recon memory | MB | 1min |
| `recon.mem.peak` | Peak memory | MB | per session |
| `recon.mem.findings` | Findings memory | MB | 1min |
| `recon.mem.correlation` | Correlation data | MB | 5min |
| `recon.mem.efficiency` | Memory efficiency | ratio | per session |

### Network Metrics (Enumeration Bandwidth)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `recon.net.dns.queries` | DNS queries made | count | 1s |
| `recon.net.dns.bytes` | DNS query bytes | bytes | 5s |
| `recon.net.http.requests` | HTTP requests | count | 1s |
| `recon.net.http.bytes` | HTTP request bytes | bytes | 1s |
| `recon.net.port.probes` | Port probes | count | 1s |
| `recon.net.port.bytes` | Port probe bytes | bytes | 1s |
| `recon.net.total.bandwidth` | Total bandwidth | Mbps | 1s |
| `recon.net.peak.bandwidth` | Peak bandwidth | Mbps | 5s |
| `recon.net.connections.active` | Active connections | count | 1s |
| `recon.net.connections.total` | Total connections | count | 1min |

### Disk Metrics (Recon Output)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `recon.disk.results.size` | Results size | MB | per scan |
| `recon.disk.temp.size` | Temp file size | MB | 5min |
| `recon.disk.log.size` | Log file size | MB | 1h |
| `recon.disk.cache.size` | Cache size | MB | 5min |
| `recon.disk.total` | Total disk usage | GB | daily |
| `recon.disk.write.iops` | Write operations | ops/s | 5s |
| `recon.disk.read.iops` | Read operations | ops/s | 5s |
| `recon.disk.latency` | Disk latency | ms | 5s |
| `recon.disk.findings.size` | Findings storage | MB | per session |
| `recon.disk.evidence.size` | Evidence storage | MB | per finding |

### Time Metrics (Recon Session)

| Metric | Description | Unit | Collection Interval |
|--------|-------------|------|-------------------|
| `recon.time.passive` | Passive recon time | min | per session |
| `recon.time.active` | Active recon time | min | per session |
| `recon.time.dns` | DNS recon time | min | per session |
| `recon.time.port` | Port scan time | min | per session |
| `recon.time.web` | Web recon time | min | per session |
| `recon.time.analysis` | Analysis time | min | per session |
| `recon.time.total` | Total recon time | min | per session |
| `recon.time.efficiency` | Time efficiency | ratio | per session |
| `recon.time.idle` | Idle time | min | per session |
| `recon.time.productive` | Productive time | min | per session |

---

## Quota Tables

### CPU Quotas by Recon Type

| Recon Type | Max CPU % | Max Duration | Max Concurrent | Priority |
|-----------|----------|--------------|----------------|----------|
| Passive Recon | 20% | 60 min | 2 | LOW |
| Active Recon | 50% | 120 min | 1 | HIGH |
| DNS Enumeration | 30% | 30 min | 2 | NORMAL |
| Port Scanning | 60% | 60 min | 1 | HIGH |
| Web Crawling | 40% | 120 min | 1 | NORMAL |
| Directory Fuzz | 50% | 60 min | 1 | HIGH |
| API Discovery | 35% | 45 min | 1 | NORMAL |
| Fingerprinting | 25% | 20 min | 2 | LOW |
| Vulnerability Scan | 45% | 60 min | 1 | HIGH |
| Total Recon | 80% | 240 min | N/A | HIGH |

### Memory Quotas (Recon State)

| Component | Min Memory | Max Memory | Budget | Eviction |
|-----------|-----------|------------|--------|----------|
| Target List | 16 MB | 256 MB | 128 MB | LRU |
| Result Buffer | 64 MB | 1 GB | 512 MB | LRU |
| DNS Cache | 32 MB | 512 MB | 256 MB | LRU |
| Scan State | 32 MB | 256 MB | 128 MB | LRU |
| Temp Data | 32 MB | 512 MB | 256 MB | Immediate |
| Findings | 32 MB | 256 MB | 128 MB | LRU |
| Correlation | 64 MB | 512 MB | 256 MB | LRU |
| Total Recon | 128 MB | 2 GB | 1 GB | N/A |

### Network Quotas (Enumeration Bandwidth)

| Recon Type | Max Bandwidth | Max Queries | Max Connections | Timeout |
|-----------|--------------|-------------|-----------------|---------|
| DNS Enumeration | 5 Mbps | 5000/hour | 30 | 15s |
| Port Scanning | 50 Mbps | 100000/hour | 500 | 5s |
| Web Crawling | 20 Mbps | 5000/hour | 50 | 10s |
| Directory Fuzz | 30 Mbps | 50000/hour | 100 | 8s |
| API Discovery | 10 Mbps | 1000/hour | 20 | 10s |
| Passive Recon | 1 Mbps | 500/hour | 5 | 30s |
| Active Recon | 100 Mbps | 200000/hour | 1000 | 5s |
| Stealth Recon | 2 Mbps | 500/hour | 10 | 60s |
| Vulnerability Scan | 20 Mbps | 5000/hour | 50 | 10s |
| Total Recon | 150 Mbps | 500000/hour | 2000 | N/A |

### Disk Quotas (Recon Output)

| Output Type | Max Size | Max Files | Rotation | Retention |
|-------------|----------|-----------|----------|-----------|
| Raw Results | 1 GB | 5000 | Yes | 7 days |
| Filtered Findings | 200 MB | 1000 | Yes | 30 days |
| Evidence Files | 500 MB | 500 | Yes | 30 days |
| Reports | 50 MB | 50 | Yes | 90 days |
| Logs | 200 MB | 200 | Yes | 7 days |
| Temp Data | 1 GB | 5000 | Yes | 1 day |
| Cache | 500 MB | 2000 | Yes | 1 day |
| Total Recon | 3 GB | 15000 | Mixed | Mixed |

---

## Alert Thresholds

### Critical Alerts (Recon Failure)

| Alert ID | Condition | Threshold | Action |
|----------|-----------|-----------|--------|
| `RECON-CPU-001` | CPU > 90% for 60s | 90% | Pause lowest scan |
| `RECON-MEM-001` | Memory > 90% | 90% | Flush result buffer |
| `RECON-NET-001` | Bandwidth > 150 Mbps | 150 Mbps | Throttle all scans |
| `RECON-DISK-001` | Disk > 95% | 95% | Emergency cleanup |
| `RECON-CPU-002` | Tool crash | Crash | Auto-restart tool |
| `RECON-MEM-002` | OOM kill | OOM | Restart recon |
| `RECON-NET-002` | Network failure > 50% | 50% | Pause recon |
| `RECON-DISK-002` | Write failure | Failure | Switch storage |

### Warning Alerts (Recon Degradation)

| Alert ID | Condition | Threshold | Action |
|----------|-----------|-----------|--------|
| `RECON-CPU-010` | CPU > 70% for 5min | 70% | Reduce parallelism |
| `RECON-MEM-010` | Memory > 80% | 80% | Optimize usage |
| `RECON-NET-010` | Bandwidth > 80% | 80% | Throttle traffic |
| `RECON-DISK-010` | Disk > 80% | 80% | Start rotation |
| `RECON-CPU-011` | Tool efficiency < 70% | 70% | Switch tool |
| `RECON-MEM-011` | Fragmentation > 40% | 40% | Compact memory |
| `RECON-NET-011` | Latency > 500ms | 500ms | Switch target |
| `RECON-DISK-011` | IOPS > 80% | 80% | Queue operations |

### Informational Alerts (Recon Tracking)

| Alert ID | Condition | Threshold | Action |
|----------|-----------|-----------|--------|
| `RECON-CPU-020` | CPU > 50% | 50% | Log usage |
| `RECON-MEM-020` | Memory > 50% | 50% | Log usage |
| `RECON-NET-020` | Bandwidth > 50% | 50% | Log usage |
| `RECON-DISK-020` | Disk > 50% | 50% | Log usage |
| `RECON-CPU-021` | New finding | Any | Log finding |
| `RECON-MEM-021` | Peak memory | Any peak | Log peak |

---

## Monitoring Dashboard Configuration

### Recon Dashboard Layout

```yaml
dashboard:
  name: "Reconnaissance Deep Dive Monitor"
  refresh_interval: 5s
  layout:
    row_1:
      - panel: "Recon CPU Usage"
        type: timeseries
        metrics: [recon.cpu.total, recon.cpu.tool.exec]
      - panel: "Recon Memory"
        type: gauge
        metrics: [recon.mem.total, recon.mem.peak]
        thresholds: [512, 1024, 2048]
      - panel: "Recon Bandwidth"
        type: timeseries
        metrics: [recon.net.total.bandwidth, recon.net.peak.bandwidth]
      - panel: "Recon Disk"
        type: gauge
        metrics: [recon.disk.total]
        thresholds: [1, 2, 3]
    
    row_2:
      - panel: "DNS Queries"
        type: timeseries
        metrics: [recon.net.dns.queries]
      - panel: "HTTP Requests"
        type: timeseries
        metrics: [recon.net.http.requests]
      - panel: "Port Probes"
        type: timeseries
        metrics: [recon.net.port.probes]
      - panel: "Active Connections"
        type: stat
        metrics: [recon.net.connections.active]
    
    row_3:
      - panel: "Resource Quotas"
        type: table
        columns: [tool, cpu_used, cpu_limit, net_used, net_limit, status]
      - panel: "Recon Timeline"
        type: timeline
        description: "Active recon phases"
      - panel: "Recon Alerts"
        type: table
        columns: [alert_id, severity, tool, triggered_at]
```

---

## Enforcement Strategies

### CPU Enforcement (Recon Tools)

| Strategy | Trigger | Action | Recovery |
|----------|---------|--------|----------|
| Tool Throttling | CPU > 80% | Reduce tool threads | Auto-recover |
| Scan Suspension | CPU > 95% | Pause lowest priority scan | Manual resume |
| Tool Rotation | Tool inefficient | Switch to alternative | Auto-select |
| Parallel Limit | CPU saturated | Queue new tools | Auto-dequeue |
| Budget Cap | CPU > budget | Stop recon | Next session |

### Memory Enforcement (Recon State)

| Strategy | Trigger | Action | Recovery |
|----------|---------|--------|----------|
| Result Limiting | Buffer > limit | Drop oldest results | Auto-reset |
| DNS Cache | Cache > limit | LRU eviction | Auto-repopulate |
| State Compression | State > limit | Compress state | Auto-decompress |
| Memory Pool | Pool > limit | Reclaim idle pools | Auto-allocate |
| Emergency Release | Memory > 95% | Release non-essentials | Auto-reallocate |

### Network Enforcement (Enumeration)

| Strategy | Trigger | Action | Recovery |
|----------|---------|--------|----------|
| Bandwidth Throttle | Usage > limit | Rate limit probes | Auto-recover |
| Connection Pool | Active > max | Queue connections | Auto-dequeue |
| DNS Cache | Queries > threshold | Cache DNS results | TTL expiry |
| Timeout Reduction | Latency > threshold | Decrease timeout | Auto-restore |
| Target Rotation | Failures > threshold | Switch target | Auto-select |

### Disk Enforcement (Recon Output)

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
  
  recon_tracking:
    track_by_type: true
    track_by_tool: true
    track_bandwidth: true
    track_discovery: true
  
  storage:
    engine: prometheus
    compression: snappy
```

### Key Performance Indicators

| KPI | Description | Target | Measurement |
|-----|-------------|--------|-------------|
| Recon Coverage | Targets covered | > 90% | Per session |
| Discovery Rate | New findings / hour | > 50 | Per session |
| DNS Efficiency | DNS queries / subdomain | < 3 | Per session |
| Port Scan Speed | Ports scanned / minute | > 1000 | Per session |
| Web Crawl Coverage | Pages crawled / site | > 80% | Per session |
| Network Efficiency | Successful / total probes | > 90% | Per session |
| Time Efficiency | Recon time / target | < 30 min | Weekly |
| Stealth Score | Detection avoidance | > 90% | Per session |
| Tool Reliability | Tool uptime | > 95% | Daily |
| Resource Cost | Cost per recon | < $10 | Per session |

---

## Reference Summary

This resource monitoring specification for the Reconnaissance-Deep-Dive domain provides:
- **50 file references** covering recon framework, subdomain enumeration, network recon, web recon, and specialized recon
- **50+ CPU, memory, network, disk, and time metrics** for enumeration bandwidth
- **4 quota tables** covering recon type CPU, recon state memory, enumeration bandwidth network, and recon output disk
- **24 alert thresholds** for recon failure, degradation, and tracking
- **Complete recon dashboard** with DNS, HTTP, and port probe monitoring
- **4 enforcement strategies** for CPU, memory, network, and disk in recon context
- **Historical metrics** with recon tracking and discovery rate KPIs

---

*Document Version: 1.0*
*Last Updated: 2025-01-15*
*Domain: Reconnaissance-Deep-Dive*
*Total Files Referenced: 50*
