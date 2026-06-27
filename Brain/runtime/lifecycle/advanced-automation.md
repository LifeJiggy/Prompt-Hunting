# Advanced Automation — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `advanced-automation` |
| Domain Path | `Advanced-Automation/` |
| File Count | 50 prompt files |
| Registry | `Advanced-Automation/registry.json` |
| Category | Automated Scanning Pipelines |
| Lifecycle Scope | Pipeline runners, tool workers, report generators, orchestrators |

## Overview

This document defines the complete process lifecycle management for the Advanced Automation domain. The domain encompasses 50 prompt files that collectively define automated scanning pipelines, from subdomain enumeration through workflow orchestration. Every automated scanning operation, tool execution, result aggregation, and report generation follows the lifecycle states defined herein.

The lifecycle manager governs how pipeline processes transition between states, how they respond to signals, how resources are allocated and reclaimed, and how graceful shutdown is achieved without data loss. The pipeline runner is the primary process; tool workers are child processes spawned per-task; report generators are terminal-state workers that produce final output.

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
            |       +--------+---------+    timeout/error    +-----------+
            |       |                  +-------------------->|           |
            |       |    STARTING      |                     |  FAILED   |
            |       |                  |<--------------------+           |
            |       +--------+---------+    retry            +-----------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            +-------+    RUNNING       |
            |       |                  |
            |       +--+----+----+-----+
            |          |    |    |
            |    pause |    |    | complete
            |          v    |    v
            |    +-----+--+ |  +-----------+
            |    |        | |  |           |
            |    |PAUSED  | |  |COMPLETED  |
            |    |        | |  |           |
            |    +---+----+ |  +-----------+
            |        |      |
            | resume |      | error/fail
            |        v      v
            |       +------+------+
            |       |             |
            +-------+  STOPPING   |
                    |             |
                    +------+------+ 
                           |
                           v
                    +------+------+
                    |             |
                    |   STOPPED   |
                    |             |
                    +-------------+

Signal-Triggered Transitions:
  SIGTERM --> STOPPING (graceful)
  SIGINT  --> STOPPING (graceful)
  SIGHUP  --> RELOADING (config reload)
  SIGUSR1 --> RELOADING (hot-reload prompts)
  SIGKILL --> STOPPED (immediate, no cleanup)
```

## State Definitions

### CREATED

The process entry point has been allocated but no initialization has occurred. Memory is reserved, configuration references are loaded, but no I/O resources or tool connections exist.

**Entry conditions:**
- Process spawn requested by orchestrator
- Domain configuration file located in `Advanced-Automation/registry.json`
- Parent process (orchestrator) is in RUNNING state

**Internal data:**
- Process ID assigned
- Domain reference bound to `Advanced-Automation/`
- All 50 file references stored in process context:
  - `01-Subdomain-Enumeration-Automation.md`
  - `02-Port-Scanning-Automation.md`
  - `03-Vulnerability-Scanning-Automation.md`
  - `04-JavaScript-Analysis-Automation.md`
  - `05-API-Endpoint-Discovery.md`
  - `06-Parameter-Fuzzing-Automation.md`
  - `07-Directory-Brute-Forcing.md`
  - `09-Authentication-Testing-Automation.md`
  - `10-Session-Management-Testing.md`
  - `11-IDOR-Detection-Automation.md`
  - `12-SQL-Injection-Automation.md`
  - `13-XSS-Detection-Automation.md`
  - `14-SSRF-Testing-Automation.md`
  - `15-CSRF-Testing-Automation.md`
  - `16-Command-Injection-Automation.md`
  - `17-XXE-Testing-Automation.md`
  - `18-SSTI-Testing-Automation.md`
  - `19-JWT-Testing-Automation.md`
  - `20-Deserialization-Testing.md`
  - `21-Report-Generation-Automation.md`
  - `22-PoC-Development-Automation.md`
  - `23-Target-Scouting-Automation.md`
  - `24-Scope-Validation-Automation.md`
  - `25-Asset-Tracking-Automation.md`
  - `26-Change-Monitoring-Automation.md`
  - `27-Notification-Alerting-Automation.md`
  - `28-Data-Collection-Automation.md`
  - `29-Result-Analysis-Automation.md`
  - `30-Tool-Chaining-Automation.md`
  - `31-Proxy-Integration-Automation.md`
  - `32-Browser-Automation-Workflows.md`
  - `33-Headless-Browser-Scripting.md`
  - `34-Regex-Pattern-Automation.md`
  - `35-Response-Analysis-Automation.md`
  - `36-Header-Injection-Testing.md`
  - `37-CORS-Testing-Automation.md`
  - `38-WebSocket-Testing-Automation.md`
  - `39-GraphQL-Testing-Automation.md`
  - `40-Cloud-Service-Enumeration.md`
  - `41-DNS-Data-Extraction-Automation.md`
  - `42-Email-Recon-Automation.md`
  - `43-Social-Media-OSINT-Automation.md`
  - `44-Framework-Detection-Automation.md`
  - `45-Technology-Stack-Identification.md`
  - `46-Endpoint-Mapping-Automation.md`
  - `47-Content-Discovery-Automation.md`
  - `48-Version-Detection-Automation.md`
  - `49-Compliance-Checking-Automation.md`
  - `50-Workflow-Orchestration-Automation.md`
  - `README.md`

**Exit transitions:** CREATED -> INITIALIZING (on init request)

### INITIALIZING

The process loads its domain configuration, validates file references against the 50 expected prompt files, establishes connections to dependent services (proxy, browser engines, tool binaries), and prepares the pipeline DAG.

**Sub-steps:**
1. Load `Advanced-Automation/registry.json`
2. Validate all 50 prompt file hashes
3. Initialize tool worker pool (subfinder, httpx, katana, ffuf, nmap)
4. Establish proxy connections for automated traffic routing
5. Initialize headless browser pool (Playwright/Puppeteer)
6. Load pipeline template from `50-Workflow-Orchestration-Automation.md`
7. Allocate result storage buffers

**Exit transitions:** INITIALIZING -> STARTING (success) | INITIALIZING -> FAILED (error)

### STARTING

All initialization completed. The process is now launching pipeline workers in dependency order. Tool workers are being spawned as child processes.

**Sub-states:**
- `STARTING_TOOL_WORKERS` — spawning nmap, subfinder, httpx workers
- `STARTING_SCANNER_WORKERS` — spawning vuln scanner, SQLi, XSS workers
- `STARTING_REPORT_WORKERS` — spawning report generator, PoC developer workers

**Exit transitions:** STARTING -> RUNNING (all workers healthy) | STARTING -> FAILED (worker crash)

### RUNNING

The pipeline is actively executing. Tool workers are processing targets, scanners are analyzing results, and the pipeline DAG is advancing through stages.

**Process types active:**
- **Pipeline Runner**: Orchestrates stage execution, manages dependencies between `30-Tool-Chaining-Automation.md` stages
- **Tool Workers**: Individual tool executors (one per tool type)
- **Report Generators**: Active during partial result collection

**Health metrics collected:**
- Worker count (active/idle/failed)
- Task queue depth
- Memory utilization per worker
- Network I/O throughput
- Error rate per tool type

**Exit transitions:** RUNNING -> STOPPING (graceful) | RUNNING -> PAUSED (operator request) | RUNNING -> FAILED (critical error)

### PAUSED

Pipeline execution is suspended. Tool workers are held in a drain state — they finish current in-flight operations but accept no new tasks. Result buffers are preserved.

**Exit transitions:** PAUSED -> RUNNING (resume) | PAUSED -> STOPPING (abort)

### COMPLETED

All pipeline stages finished successfully. Final reports have been generated. The process is in a terminal success state awaiting resource cleanup.

**Exit transitions:** COMPLETED -> STOPPED (cleanup complete)

### STOPPING

Graceful shutdown in progress. The process is:
1. Sending SIGTERM to all child tool workers
2. Waiting for in-flight operations to complete (configurable timeout)
3. Flushing result buffers to persistent storage
4. Writing final pipeline status to registry
5. Releasing proxy connections and browser instances

**Timeout behavior:** If any worker does not terminate within the configured grace period (default 30s), it receives SIGKILL.

**Exit transitions:** STOPPING -> STOPPED (cleanup complete)

### STOPPED

Terminal state. All resources released, all child processes terminated, all buffers flushed.

### FAILED

Error terminal state. Contains error context, failed worker IDs, partial results if any.

## Start Operations

### Pipeline Start Sequence

```
1. Receive start command from orchestrator
2. Transition: CREATED -> INITIALIZING
3. Load domain configuration:
   - Read Advanced-Automation/registry.json
   - Validate 50 file references
   - Check tool binary availability
4. Transition: INITIALIZING -> STARTING
5. Spawn pipeline runner (parent process)
6. Spawn tool workers in dependency order:
   a. Phase 1: Subdomain Enum (01-Subdomain-Enumeration-Automation.md)
   b. Phase 2: Port Scanning (02-Port-Scanning-Automation.md)
   c. Phase 3: Tech Fingerprinting (44, 45)
   d. Phase 4: Content Discovery (07, 47)
   e. Phase 5: Vulnerability Scanning (03, 11-20)
   f. Phase 6: Analysis (29, 35)
   g. Phase 7: Report Generation (21, 22)
7. Verify all workers healthy
8. Transition: STARTING -> RUNNING
```

### Individual Worker Start

Each tool worker follows:
1. Load its prompt file from `Advanced-Automation/`
2. Initialize tool-specific configuration
3. Connect to pipeline message bus
4. Register health check endpoint
5. Signal ready state to pipeline runner

## Stop Operations

### Graceful Stop (SIGTERM / stop command)

```
1. Pipeline runner receives stop signal
2. Transition: RUNNING -> STOPPING
3. Notify all workers to stop accepting new tasks
4. Wait for in-flight tasks to complete:
   - Tool workers: finish current scan, flush results
   - Report workers: finish current report section
   - Browser workers: close pages, release contexts
5. Flush all result buffers to disk
6. Write pipeline completion status
7. Release proxy connections
8. Release browser pool resources
9. Worker processes exit
10. Pipeline runner exits
11. Transition: STOPPING -> STOPPED
```

### Immediate Stop (SIGKILL)

```
1. All processes terminated immediately
2. No cleanup performed
3. Result buffers may be corrupted
4. Manual recovery required from last checkpoint
```

### Domain-Specific Stop Hooks

For Advanced Automation, stop hooks include:
- `on_stop_flush_subfinder_cache()` — persist partial subdomain results
- `on_stop_save_scan_state()` — checkpoint current scan progress
- `on_stop_close_browser_pool()` — close all Playwright contexts
- `on_stop_release_proxy()` — disconnect from proxy chain
- `on_stop_write_final_report()` — generate partial report if configured

## Restart Operations

### Full Restart

```
1. Execute graceful stop (all steps)
2. Verify STOPPED state
3. Reinitialize from scratch
4. Execute start sequence (all steps)
```

### Hot Reload (SIGHUP / reload command)

```
1. Receive reload signal
2. Transition: RUNNING -> RELOADING
3. Reload domain configuration from registry.json
4. Validate updated prompt file references
5. For each worker:
   a. If config changed: stop worker, reinitialize with new config
   b. If config unchanged: continue running
6. Transition: RELOADING -> RUNNING
```

### Worker Restart (individual)

```
1. Pipeline runner detects worker failure
2. Capture worker error state and partial results
3. Terminate failed worker process
4. Spawn new worker with same configuration
5. Replay unprocessed tasks from message bus
6. Resume normal operation
```

## Graceful Shutdown Protocol

### Phase 1: Signal Reception (0-100ms)
- Process receives SIGTERM from orchestrator or operator
- Signal handler sets `shutdown_requested` flag
- Main event loop acknowledges signal

### Phase 2: Task Drain (100ms-30s configurable)
- Workers stop accepting new tasks from the queue
- In-flight tasks continue to completion
- Pipeline runner monitors worker completion

### Phase 3: Resource Release (30s-60s)
- Browser instances closed: `browser_pool.close_all()`
- Proxy connections released: `proxy_pool.disconnect()`
- Network sockets closed
- Temp files cleaned from workspace
- Child process reaped

### Phase 4: State Persistence (60s-90s)
- All partial results written to disk
- Pipeline state serialized to checkpoint file
- Registry updated with completion status
- Worker metrics flushed to monitoring

### Phase 5: Final Termination (90s)
- Pipeline runner process exits with code 0
- Parent orchestrator notified of clean shutdown
- PID file removed

## Signal Handling

| Signal | Handler | Action | Graceful |
|--------|---------|--------|----------|
| `SIGTERM` | `handle_sigterm()` | Initiate graceful shutdown | Yes |
| `SIGINT` | `handle_sigint()` | Initiate graceful shutdown (human Ctrl+C) | Yes |
| `SIGHUP` | `handle_sighup()` | Reload configuration from registry.json | Yes |
| `SIGUSR1` | `handle_sigusr1()` | Hot-reload prompt files from Advanced-Automation/ | Yes |
| `SIGUSR2` | `handle_sigusr2()` | Toggle debug logging | Yes |
| `SIGKILL` | (OS default) | Immediate termination | No |
| `SIGPIPE` | `SIG_IGN` | Ignore broken pipe | N/A |
| `SIGCHLD` | `handle_sigchld()` | Reap child tool worker processes | N/A |

### Signal Handler Implementation Notes

```python
# Signal handler for Advanced Automation pipeline
SIGNAL_MAP = {
    'SIGTERM': 'graceful_shutdown',
    'SIGINT':  'graceful_shutdown',
    'SIGHUP':  'config_reload',
    'SIGUSR1': 'hot_reload_prompts',
    'SIGUSR2': 'toggle_debug',
    'SIGCHLD': 'reap_children',
}

SHUTDOWN_TIMEOUT = 30  # seconds before SIGKILL
DRAIN_TIMEOUT = 15     # seconds for task drain
FLUSH_TIMEOUT = 10     # seconds for buffer flush
```

## Health Monitoring

### Health Check Endpoints

Each process exposes a health check at `{process_id}/health`:

```json
{
  "process_id": "aa-pipeline-001",
  "state": "RUNNING",
  "uptime_seconds": 3420,
  "workers": {
    "total": 12,
    "active": 8,
    "idle": 3,
    "failed": 1
  },
  "memory_mb": 512,
  "cpu_percent": 34.2,
  "tasks_completed": 156,
  "tasks_failed": 3,
  "last_heartbeat": "2026-06-26T12:00:00Z"
}
```

### Health Check Schedule

- **Heartbeat interval**: 5 seconds (workers -> pipeline runner)
- **Health probe interval**: 10 seconds (orchestrator -> pipeline runner)
- **Stale threshold**: 30 seconds (no heartbeat = unhealthy)
- **Restart threshold**: 3 consecutive failures

### Worker Health States

| State | Meaning | Action |
|-------|---------|--------|
| HEALTHY | Responding to heartbeats, CPU < 80%, memory < 80% | Continue |
| DEGRADED | Responding but high resource usage or slow responses | Alert, monitor |
| UNHEALTHY | Not responding to heartbeats or failing tasks | Restart worker |
| DEAD | Process terminated or unresponsive for > 60s | Kill, respawn |

### Monitoring Metrics

| Metric | Source | Alert Threshold |
|--------|--------|-----------------|
| `pipeline_worker_count` | Pipeline runner | < expected count |
| `pipeline_task_queue_depth` | Message bus | > 1000 |
| `pipeline_error_rate` | Task results | > 5% |
| `pipeline_memory_usage_mb` | Process metrics | > 2048 |
| `pipeline_cpu_percent` | Process metrics | > 90% |
| `pipeline_disk_usage_mb` | Filesystem | > 10240 |
| `pipeline_network_bytes` | Network I/O | Anomaly detection |

## Resource Limits

### Memory Limits

| Process Type | Soft Limit | Hard Limit | OOM Action |
|-------------|-----------|-----------|------------|
| Pipeline Runner | 1024 MB | 2048 MB | Log, alert, graceful shutdown |
| Tool Worker (scanner) | 512 MB | 1024 MB | Restart worker |
| Tool Worker (browser) | 2048 MB | 4096 MB | Kill browser, restart |
| Report Generator | 256 MB | 512 MB | Flush partial report, restart |
| Result Analyzer | 512 MB | 1024 MB | Restart worker |

### CPU Limits

| Process Type | CPU Quota | Throttle Action |
|-------------|-----------|-----------------|
| Pipeline Runner | 2 cores | Queue excess |
| Tool Worker | 1 core | Throttle to 50% |
| Browser Worker | 2 cores | Kill long-running tabs |

### File Descriptor Limits

| Process Type | Soft Limit | Hard Limit |
|-------------|-----------|-----------|
| Pipeline Runner | 1024 | 4096 |
| Tool Worker | 256 | 1024 |
| Browser Worker | 512 | 2048 |

### Network Limits

| Metric | Limit | Action |
|--------|-------|--------|
| Concurrent connections | 100 per worker | Queue excess |
| Bandwidth | 10 MB/s per worker | Rate limit |
| Connection timeout | 30 seconds | Close, retry |

### Disk Limits

| Metric | Limit | Action |
|--------|-------|--------|
| Result storage | 5 GB per pipeline run | Rotate old results |
| Temp files | 1 GB per worker | Cleanup on completion |
| Log files | 100 MB per worker | Rotate at 100MB |

## Cleanup Procedures

### Normal Cleanup (on COMPLETED/STOPPED)

```
1. Remove temp files from workspace
   - rm -rf /tmp/aa-pipeline-{pid}/*
   - rm -rf /tmp/aa-browser-{pid}/*
2. Close database connections
3. Release file locks
4. Archive result files to persistent storage
5. Update registry.json with final status
6. Remove PID file
7. Log cleanup completion
```

### Emergency Cleanup (on FAILED)

```
1. Capture core dump if enabled
2. Save partial results
3. Kill any orphaned child processes
4. Release all held resources
5. Write failure report to logs
6. Notify orchestrator of failure
```

### Resource Leak Prevention

- Open file descriptors tracked in process context
- Network sockets registered with cleanup handler
- Child process PIDs tracked for SIGKILL on emergency shutdown
- Temp directory ownership tracked for recursive deletion

## Domain File References

### Phase 1: Reconnaissance Automation

| File | Purpose | Worker Type |
|------|---------|-------------|
| `01-Subdomain-Enumeration-Automation.md` | Automated subdomain discovery pipeline | Enum Worker |
| `02-Port-Scanning-Automation.md` | Automated port scanning with nmap/masscan | Scan Worker |
| `03-Vulnerability-Scanning-Automation.md` | Automated vulnerability scanner integration | Scan Worker |
| `40-Cloud-Service-Enumeration.md` | Cloud asset discovery automation | Enum Worker |
| `41-DNS-Data-Extraction-Automation.md` | DNS record extraction automation | Enum Worker |
| `42-Email-Recon-Automation.md` | Email address discovery automation | Enum Worker |
| `43-Social-Media-OSINT-Automation.md` | Social media intelligence gathering | Enum Worker |
| `50-Workflow-Orchestration-Automation.md` | Master workflow orchestration | Pipeline Runner |

### Phase 2: Discovery Automation

| File | Purpose | Worker Type |
|------|---------|-------------|
| `04-JavaScript-Analysis-Automation.md` | Automated JS bundle analysis | Analysis Worker |
| `05-API-Endpoint-Discovery.md` | Automated API endpoint discovery | Discovery Worker |
| `06-Parameter-Fuzzing-Automation.md` | Automated parameter fuzzing | Fuzz Worker |
| `07-Directory-Brute-Forcing.md` | Directory/file brute forcing | Fuzz Worker |
| `44-Framework-Detection-Automation.md` | Framework fingerprinting | Analysis Worker |
| `45-Technology-Stack-Identification.md` | Tech stack identification | Analysis Worker |
| `46-Endpoint-Mapping-Automation.md` | Endpoint mapping automation | Discovery Worker |
| `47-Content-Discovery-Automation.md` | Content discovery automation | Discovery Worker |
| `48-Version-Detection-Automation.md` | Version detection automation | Analysis Worker |

### Phase 3: Vulnerability Scanning

| File | Purpose | Worker Type |
|------|---------|-------------|
| `09-Authentication-Testing-Automation.md` | Auth testing automation | Vuln Worker |
| `10-Session-Management-Testing.md` | Session management testing | Vuln Worker |
| `11-IDOR-Detection-Automation.md` | IDOR detection automation | Vuln Worker |
| `12-SQL-Injection-Automation.md` | SQL injection automation | Vuln Worker |
| `13-XSS-Detection-Automation.md` | XSS detection automation | Vuln Worker |
| `14-SSRF-Testing-Automation.md` | SSRF testing automation | Vuln Worker |
| `15-CSRF-Testing-Automation.md` | CSRF testing automation | Vuln Worker |
| `16-Command-Injection-Automation.md` | Command injection testing | Vuln Worker |
| `17-XXE-Testing-Automation.md` | XXE testing automation | Vuln Worker |
| `18-SSTI-Testing-Automation.md` | SSTI testing automation | Vuln Worker |
| `19-JWT-Testing-Automation.md` | JWT testing automation | Vuln Worker |
| `20-Deserialization-Testing.md` | Deserialization testing | Vuln Worker |
| `36-Header-Injection-Testing.md` | Header injection testing | Vuln Worker |
| `37-CORS-Testing-Automation.md` | CORS testing automation | Vuln Worker |
| `38-WebSocket-Testing-Automation.md` | WebSocket testing | Vuln Worker |
| `39-GraphQL-Testing-Automation.md` | GraphQL testing automation | Vuln Worker |

### Phase 4: Integration and Testing

| File | Purpose | Worker Type |
|------|---------|-------------|
| `23-Target-Scouting-Automation.md` | Target scouting automation | Scouting Worker |
| `24-Scope-Validation-Automation.md` | Scope validation automation | Validation Worker |
| `25-Asset-Tracking-Automation.md` | Asset tracking automation | Tracking Worker |
| `26-Change-Monitoring-Automation.md` | Change detection automation | Monitor Worker |
| `27-Notification-Alerting-Automation.md` | Alerting automation | Alert Worker |
| `28-Data-Collection-Automation.md` | Data collection automation | Collection Worker |
| `29-Result-Analysis-Automation.md` | Result analysis automation | Analysis Worker |
| `30-Tool-Chaining-Automation.md` | Tool chaining orchestration | Pipeline Runner |
| `31-Proxy-Integration-Automation.md` | Proxy integration automation | Proxy Worker |
| `32-Browser-Automation-Workflows.md` | Browser automation workflows | Browser Worker |
| `33-Headless-Browser-Scripting.md` | Headless browser scripting | Browser Worker |
| `34-Regex-Pattern-Automation.md` | Regex pattern automation | Analysis Worker |
| `35-Response-Analysis-Automation.md` | Response analysis automation | Analysis Worker |
| `49-Compliance-Checking-Automation.md` | Compliance checking automation | Compliance Worker |

### Phase 5: Output Generation

| File | Purpose | Worker Type |
|------|---------|-------------|
| `21-Report-Generation-Automation.md` | Automated report generation | Report Generator |
| `22-PoC-Development-Automation.md` | Automated PoC development | PoC Worker |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | Domain registry and metadata |

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Pipeline Runner (Advanced-Automation)
        |
        +-- Enum Workers (01, 40, 41, 42, 43)
        +-- Scan Workers (02, 03)
        +-- Discovery Workers (05, 46, 47)
        +-- Fuzz Workers (06, 07)
        +-- Analysis Workers (04, 29, 34, 35, 44, 45, 48)
        +-- Vuln Workers (09-20, 36-39)
        +-- Browser Workers (32, 33)
        +-- Proxy Worker (31)
        +-- Report Generators (21, 22)
        +-- Monitor Workers (25, 26, 27)
        +-- Compliance Worker (49)
```

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `pipeline.max_workers` | 12 | Maximum concurrent workers |
| `pipeline.graceful_timeout` | 30 | Seconds before SIGKILL |
| `pipeline.drain_timeout` | 15 | Seconds for task drain |
| `pipeline.flush_timeout` | 10 | Seconds for buffer flush |
| `pipeline.heartbeat_interval` | 5 | Seconds between heartbeats |
| `pipeline.health_probe_interval` | 10 | Seconds between health checks |
| `pipeline.stale_threshold` | 30 | Seconds before marking unhealthy |
| `pipeline.restart_threshold` | 3 | Consecutive failures before restart |
| `memory.soft_limit_mb` | 1024 | Soft memory limit |
| `memory.hard_limit_mb` | 2048 | Hard memory limit (OOM kill) |
| `disk.result_limit_gb` | 5 | Max result storage per run |
| `disk.temp_limit_gb` | 1 | Max temp files per worker |
| `network.max_connections` | 100 | Per-worker connection limit |
| `network.bandwidth_mbps` | 10 | Per-worker bandwidth limit |

## Logging

### Log Levels by Process Type

| Process Type | Default Level | Debug Override |
|-------------|---------------|----------------|
| Pipeline Runner | INFO | DEBUG |
| Tool Worker | WARNING | INFO |
| Report Generator | INFO | DEBUG |
| Browser Worker | WARNING | DEBUG |

### Log Rotation

- Max file size: 10 MB
- Max files: 10 (rotate and compress)
- Log directory: `/var/log/prompt-hunting/advanced-automation/`
- Structured JSON format with correlation IDs

## Recovery Procedures

### Pipeline Recovery

1. On worker crash: Pipeline runner captures error, restarts worker, replays tasks
2. On pipeline crash: Orchestrator detects via heartbeat timeout, restarts pipeline from last checkpoint
3. On system reboot: Orchestrator reads checkpoint, resumes or restarts pipelines

### Data Recovery

1. Partial results preserved in checkpoint files
2. Transaction log enables replay from last committed state
3. Corrupted buffers detected via checksums, discarded with warning

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-26 | Initial lifecycle definition for Advanced Automation domain |
