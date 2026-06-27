# Reconnaissance Deep Dive — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `reconnaissance-deep-dive` |
| Domain Path | `Reconnaissance-Deep-Dive/` |
| File Count | 50 prompt files |
| Registry | `Reconnaissance-Deep-Dive/registry.json` |
| Category | Reconnaissance Processes |
| Lifecycle Scope | Enum workers, fingerprint workers, OSINT workers, asset discovery workers |

## Overview

This document defines the complete process lifecycle management for the Reconnaissance Deep Dive domain. The domain encompasses 50 prompt files covering comprehensive reconnaissance techniques from subdomain enumeration through advanced reconnaissance strategies. The lifecycle manages the execution of reconnaissance processes that discover, enumerate, fingerprint, and map target infrastructure.

Reconnaissance processes are typically the first phase of any hunting operation. They must be highly parallel, handling hundreds or thousands of assets simultaneously while maintaining accuracy and completeness. The lifecycle includes states for different reconnaissance phases and handles the transition between passive and active reconnaissance.

## Process State Machine

```
                    +------------------+
                    |                  |
            +------>|    CREATED       |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   INITIALIZING   |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |  PASSIVE_RECON   |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |  ACTIVE_RECON    |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |  FINGERPRINTING  |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |  ENRICHMENT      |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            +-------+    COMPLETED     |
            |       |                  |
            |       +------------------+
            |
            | (any) --error--> +-----------+
            |                  |   FAILED  |
            |                  +-----------+
            |                       |
            | (any) --signal--> +---+--------+
            |                   |  STOPPING  |
            |                   +------------+
            |                        |
            |                        v
            +-------------------+----+------+
                                |  STOPPED   |
                                +------------+
```

## State Definitions

### CREATED

Process entry allocated. Reconnaissance scope and target defined.

**Internal data:**
- Process ID assigned
- Target scope and boundaries loaded
- All 50 file references loaded:
  - `01-Advanced-Subdomain-Enumeration.md`
  - `02-Passive-OSINT-Collection.md`
  - `03-Active-Asset-Discovery.md`
  - `04-Technology-Stack-Fingerprinting.md`
  - `05-Cloud-Resource-Enumeration.md`
  - `06-API-Endpoint-Discovery.md`
  - `07-JavaScript-Source-Analysis.md`
  - `08-Configuration-File-Extraction.md`
  - `09-Version-Detection-Techniques.md`
  - `10-Content-Discovery-Automation.md`
  - `11-Directory-Brute-Forcing.md`
  - `12-File-Type-Detection.md`
  - `13-Backup-File-Discovery.md`
  - `14-Source-Code-Leak-Detection.md`
  - `15-Git-Repository-Analysis.md`
  - `16-DNS-Enumeration-Advanced.md`
  - `17-Certificate-Transparency-Logs.md`
  - `18-Historical-Data-Analysis.md`
  - `19-Social-Media-OSINT.md`
  - `20-Employee-Linked-Assets.md`
  - `21-Third-Party-Integration-Discovery.md`
  - `22-Web-Archive-Analysis.md`
  - `23-Pastebin-and-Leak-Searching.md`
  - `24-Code-Repository-Mining.md`
  - `25-Container-Registry-Enumeration.md`
  - `26-IoT-Device-Discovery.md`
  - `27-Mobile-App-Analysis.md`
  - `28-API-Documentation-Extraction.md`
  - `29-WebSocket-Endpoint-Discovery.md`
  - `30-GraphQL-Introspection.md`
  - `31-XML-RPC-and-SOAP-Discovery.md`
  - `32-Email-Address-Harvesting.md`
  - `33-Phone-Number-Enumeration.md`
  - `34-Physical-Location-Intelligence.md`
  - `35-Supply-Chain-Asset-Mapping.md`
  - `36-Competitor-Analysis.md`
  - `37-Partner-Network-Discovery.md`
  - `38-Acquisition-Target-Analysis.md`
  - `39-Subsidiary-Asset-Mapping.md`
  - `40-Regional-Infrastructure-Mapping.md`
  - `41-Content-Management-System-Detection.md`
  - `42-Framework-and-Library-Identification.md`
  - `43-Server-Configuration-Analysis.md`
  - `44-SSL-TLS-Certificate-Analysis.md`
  - `45-HTTP-Header-Intelligence.md`
  - `46-Cookie-Analysis-and-Session-Management.md`
  - `47-Error-Page-Analysis.md`
  - `48-Debug-Endpoint-Discovery.md`
  - `49-Staging-Environment-Detection.md`
  - `50-Advanced-Reconnaissance-Strategy.md`
  - `README.md`

**Exit:** CREATED -> INITIALIZING

### INITIALIZING

Loading recon configuration, initializing enumeration engines, setting up passive/active pipelines.

**Sub-steps:**
1. Load `Reconnaissance-Deep-Dive/registry.json`
2. Initialize passive recon pipeline: `02-Passive-OSINT-Collection.md`
3. Initialize active recon pipeline: `03-Active-Asset-Discovery.md`
4. Initialize fingerprinting engine: `04-Technology-Stack-Fingerprinting.md`
5. Initialize DNS enumeration: `16-DNS-Enumeration-Advanced.md`
6. Initialize CT log parser: `17-Certificate-Transparency-Logs.md`
7. Set up rate limiting for active scanning
8. Configure proxy/VPN for anonymization
9. Load target scope boundaries

**Exit:** INITIALIZING -> PASSIVE_RECON | INITIALIZING -> FAILED

### PASSIVE_RECON

Gathering information without direct interaction with target.

**Active workers:**
- CT log analysis: `17-Certificate-Transparency-Logs.md`
- Historical data analysis: `18-Historical-Data-Analysis.md`
- Social media OSINT: `19-Social-Media-OSINT.md`
- Employee asset discovery: `20-Employee-Linked-Assets.md`
- Code repository mining: `24-Code-Repository-Mining.md`
- Web archive analysis: `22-Web-Archive-Analysis.md`
- Pastebin/leak searching: `23-Pastebin-and-Leak-Searching.md`
- Email harvesting: `32-Email-Address-Harvesting.md`
- Phone enumeration: `33-Phone-Number-Enumeration.md`
- Physical location intel: `34-Physical-Location-Intelligence.md`
- Supply chain mapping: `35-Supply-Chain-Asset-Mapping.md`
- Competitor analysis: `36-Competitor-Analysis.md`
- Partner network discovery: `37-Partner-Network-Discovery.md`
- Acquisition target analysis: `38-Acquisition-Target-Analysis.md`
- Subsidiary asset mapping: `39-Subsidiary-Asset-Mapping.md`

**Exit:** PASSIVE_RECON -> ACTIVE_RECON (passive complete) | PASSIVE_RECON -> FAILED

### ACTIVE_RECON

Direct interaction with target infrastructure for discovery.

**Active workers:**
- Subdomain enumeration: `01-Advanced-Subdomain-Enumeration.md`
- Active asset discovery: `03-Active-Asset-Discovery.md`
- DNS enumeration: `16-DNS-Enumeration-Advanced.md`
- API endpoint discovery: `06-API-Endpoint-Discovery.md`
- WebSocket discovery: `29-WebSocket-Endpoint-Discovery.md`
- GraphQL introspection: `30-GraphQL-Introspection.md`
- XML-RPC/SOAP discovery: `31-XML-RPC-and-SOAP-Discovery.md`
- Directory brute forcing: `11-Directory-Brute-Forcing.md`
- Content discovery: `10-Content-Discovery-Automation.md`
- Backup file discovery: `13-Backup-File-Discovery.md`
- Debug endpoint discovery: `48-Debug-Endpoint-Discovery.md`
- Staging environment detection: `49-Staging-Environment-Detection.md`
- Cloud resource enumeration: `05-Cloud-Resource-Enumeration.md`
- Container registry enum: `25-Container-Registry-Enumeration.md`
- IoT device discovery: `26-IoT-Device-Discovery.md`
- Mobile app analysis: `27-Mobile-App-Analysis.md`
- Regional infrastructure mapping: `40-Regional-Infrastructure-Mapping.md`

**Exit:** ACTIVE_RECON -> FINGERPRINTING (active complete) | ACTIVE_RECON -> FAILED

### FINGERPRINTING

Identifying technologies, versions, and configurations on discovered assets.

**Active workers:**
- Technology stack fingerprinting: `04-Technology-Stack-Fingerprinting.md`
- CMS detection: `41-Content-Management-System-Detection.md`
- Framework/library identification: `42-Framework-and-Library-Identification.md`
- Server configuration analysis: `43-Server-Configuration-Analysis.md`
- SSL/TLS certificate analysis: `44-SSL-TLS-Certificate-Analysis.md`
- HTTP header intelligence: `45-HTTP-Header-Intelligence.md`
- Cookie analysis: `46-Cookie-Analysis-and-Session-Management.md`
- Error page analysis: `47-Error-Page-Analysis.md`
- Version detection: `09-Version-Detection-Techniques.md`
- File type detection: `12-File-Type-Detection.md`
- Configuration file extraction: `08-Configuration-File-Extraction.md`

**Exit:** FINGERPRINTING -> ENRICHMENT (fingerprinting complete) | FINGERPRINTING -> FAILED

### ENRICHMENT

Enriching discovered data with additional context and relationships.

**Active workers:**
- JavaScript source analysis: `07-JavaScript-Source-Analysis.md`
- Source code leak detection: `14-Source-Code-Leak-Detection.md`
- Git repository analysis: `15-Git-Repository-Analysis.md`
- API documentation extraction: `28-API-Documentation-Extraction.md`
- Third-party integration discovery: `21-Third-Party-Integration-Discovery.md`
- Advanced recon strategy: `50-Advanced-Reconnaissance-Strategy.md`

**Exit:** ENRICHMENT -> COMPLETED (enrichment complete) | ENRICHMENT -> FAILED

### COMPLETED

Reconnaissance complete. All assets discovered, fingerprinted, and enriched.

**Exit:** COMPLETED -> STOPPED

### STOPPING

Graceful shutdown. Recon state preserved.

**Exit:** STOPPING -> STOPPED

### STOPPED

Terminal state. All recon workers terminated.

## Start Operations

### Recon Start Sequence

```
1. Receive recon command with target
2. Transition: CREATED -> INITIALIZING
3. Load target scope
4. Initialize recon engines
5. Transition: INITIALIZING -> PASSIVE_RECON
6. Execute passive recon (OSINT, CT logs, historical)
7. Transition: PASSIVE_RECON -> ACTIVE_RECON
8. Execute active recon (scanning, enumeration)
9. Transition: ACTIVE_RECON -> FINGERPRINTING
10. Fingerprint discovered assets
11. Transition: FINGERPRINTING -> ENRICHMENT
12. Enrich discovered data
13. Transition: ENRICHMENT -> COMPLETED
14. Deliver recon results
```

## Stop Operations

### Graceful Stop

```
1. Receive stop signal
2. Transition: CURRENT_STATE -> STOPPING
3. Save current recon state
4. Allow in-progress scans to complete
5. Preserve discovered assets
6. Write recon summary
7. Transition: STOPPING -> STOPPED
```

## Graceful Shutdown Protocol

### Phase 1: Scan Drain (0-60s)
- Allow in-progress scans to complete
- Stop accepting new scan tasks
- Flush result buffers

### Phase 2: State Persistence (60-120s)
- Save discovered assets to database
- Persist fingerprint data
- Save enrichment results
- Write recon checkpoint

### Phase 3: Resource Release (120-150s)
- Release scanner connections
- Close proxy connections
- Free enumeration engines
- Write shutdown log

## Signal Handling

| Signal | Handler | Action |
|--------|---------|--------|
| `SIGTERM` | `handle_graceful_shutdown()` | Drain scans, persist, shutdown |
| `SIGINT` | `handle_graceful_shutdown()` | Same as SIGTERM |
| `SIGHUP` | `handle_scope_reload()` | Reload target scope |
| `SIGUSR1` | `handle_recon_dump()` | Dump current recon results |
| `SIGUSR2` | `handle_phase_skip()` | Skip to next recon phase (debug) |
| `SIGKILL` | (OS default) | Immediate termination |

## Health Monitoring

| Metric | Description | Alert |
|--------|-------------|-------|
| `current_phase` | Active recon phase | N/A (info) |
| `assets_discovered` | Total assets found | N/A (info) |
| `subdomains_found` | Subdomains discovered | N/A (info) |
| `endpoints_found` | Endpoints discovered | N/A (info) |
| `fingerprints_identified` | Tech fingerprints | N/A (info) |
| `scan_rate_per_second` | Scans/second | < 10 |
| `error_rate` | Scan error rate | > 5% |
| `memory_usage_mb` | Process memory | > 2048 MB |
| `network_bandwidth_mbps` | Network usage | > 50 |

## Resource Limits

| Resource | Limit | Action |
|----------|-------|--------|
| Memory | 2048 MB | Evict old results |
| CPU | 4 cores | Throttle scanning |
| Network bandwidth | 50 Mbps | Rate limit |
| Concurrent scans | 100 | Queue excess |
| DNS queries/sec | 1000 | Rate limit |
| HTTP requests/sec | 500 | Rate limit |
| Result storage | 5 GB | Rotate old results |
| Asset database | 100000 entries | Archive old entries |

## Cleanup Procedures

### Normal Cleanup

```
1. Archive discovered assets
2. Save fingerprint database
3. Preserve enrichment data
4. Write final recon report
5. Release scanner connections
6. Clean temp scan files
```

### Emergency Cleanup

```
1. Force-stop all scanners
2. Save partial asset list
3. Release all connections
4. Log failure context
```

## Domain File References

All 50 files serve as recon module configurations. See the state definitions for the complete organized listing grouped by recon phase.

## Inter-Process Communication

### Message Types

| Message | Producer | Consumer | Description |
|---------|----------|----------|-------------|
| `asset.discovered` | Recon Workers | Asset DB | New asset found |
| `asset.fingerprinted` | Fingerprint Workers | Asset DB | Asset fingerprinted |
| `asset.enriched` | Enrichment Workers | Asset DB | Asset enriched |
| `phase.complete` | Phase Workers | Recon Manager | Phase finished |
| `scan.progress` | Active Workers | Recon Manager | Scan progress |
| `rate.limit.hit` | Rate Limiter | Active Workers | Rate limit reached |
| `scope.violation` | Scope Checker | All Workers | Out-of-scope target |

### Asset Types Tracked

| Asset Type | Discovery Method | Examples |
|------------|-----------------|----------|
| Subdomain | 01, 16, 17 | *.target.com |
| IP Address | 01, 03 | 192.168.1.0/24 |
| URL | 06, 10, 11 | /api/v1/users |
| Port | 03 | 443, 8080 |
| Technology | 04, 41, 42 | nginx, React |
| Email | 32 | user@target.com |
| Certificate | 17, 44 | *.target.com cert |
| API Endpoint | 06, 28, 29, 30 | /graphql |
| Source Code | 14, 15, 24 | GitHub repos |
| Cloud Resource | 05, 25 | S3, EC2 |
| Employee | 20, 32, 33 | LinkedIn profiles |
| Backup | 13 | /backup/, /.git/ |
| Debug | 48 | /debug, /actuator |

### Rate Limiting Configuration

| Scanner Type | Rate Limit | Burst | Timeout |
|-------------|-----------|-------|---------|
| DNS Enumeration | 1000/sec | 2000 | 30s |
| HTTP Scanning | 500/sec | 1000 | 30s |
| Directory Brute | 200/sec | 400 | 60s |
| Port Scanning | 100/sec | 200 | 120s |
| API Probing | 300/sec | 600 | 30s |

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Recon Manager
        |
        +-- Passive Recon Workers
        |     +-- CT Log Worker (17)
        |     +-- OSINT Worker (19, 20, 32, 33, 34)
        |     +-- Historical Worker (18, 22)
        |     +-- Code Mining Worker (24, 14, 15)
        |     +-- Leak Search Worker (23)
        |     +-- Supply Chain Worker (35-39)
        |
        +-- Active Recon Workers
        |     +-- Subdomain Enum Worker (01, 16)
        |     +-- Port Scanner Worker (03)
        |     +-- Directory Buster Worker (11, 13)
        |     +-- API Discoverer Worker (06, 28-31)
        |     +-- Cloud Enum Worker (05, 25-27)
        |     +-- Content Discovery Worker (10, 49)
        |
        +-- Fingerprint Workers
        |     +-- Tech Stack Worker (04, 42)
        |     +-- CMS Detector Worker (41)
        |     +-- Version Detector Worker (09, 12)
        |     +-- SSL Analyzer Worker (44)
        |     +-- Header Analyzer Worker (45)
        |     +-- Cookie Analyzer Worker (46)
        |     +-- Error Analyzer Worker (47)
        |     +-- Config Extractor Worker (08)
        |     +-- Debug Detector Worker (48)
        |
        +-- Enrichment Workers
        |     +-- JS Analyzer Worker (07)
        |     +-- Source Leak Worker (14)
        |     +-- Git Analyzer Worker (15)
        |     +-- API Doc Worker (28)
        |     +-- Integration Mapper Worker (21)
        |     +-- Advanced Strategy Worker (50)
        |     +-- Regional Mapper Worker (40)
        |
        +-- Asset Database Manager
        |     +-- DB Writer
        |     +-- DB Reader
        |     +-- DB Optimizer
        |     +-- DB Indexer
        |
        +-- Rate Limiter
              +-- DNS Rate Controller
              +-- HTTP Rate Controller
              +-- Scan Rate Controller
```

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `recon.phase_timeout` | 3600 | Phase timeout (seconds) |
| `recon.max_concurrent_scans` | 100 | Max parallel scans |
| `recon.dns_rate_limit` | 1000 | DNS queries/sec |
| `recon.http_rate_limit` | 500 | HTTP requests/sec |
| `recon.passive_only` | false | Passive-only mode |
| `recon.asset_db_limit` | 100000 | Max assets in DB |
| `recon.result_storage_gb` | 5 | Result storage limit |
| `recon.fingerprint_depth` | full | Fingerprint depth |
| `recon.enrichment_enabled` | true | Enable enrichment phase |
| `recon.scope_enforcement` | strict | Scope enforcement mode |
| `recon.proxy_enabled` | false | Enable proxy for scans |
| `recon.threads_per_worker` | 4 | Threads per scan worker |
| `recon.timeout_per_host` | 30 | Timeout per host (seconds) |
| `recon.retry_count` | 3 | Retries per failed scan |
| `recon.output_format` | json | Result output format |
