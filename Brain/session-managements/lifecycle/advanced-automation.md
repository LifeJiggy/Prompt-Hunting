# Session Lifecycle: Advanced Automation Domain

> Session lifecycle management for automated scanning, tool orchestration, and pipeline execution across all 50 Advanced-Automation modules.

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | `advanced-automation` |
| Source Directory | `Advanced-Automation/` |
| Module Count | 50 |
| Session Type | `automation-pipeline` |
| State Complexity | High — tracks pipeline stage, tool status, output accumulation |
| Parent System | Session Lifecycle Manager |

## Overview

This document defines the complete session lifecycle for the Advanced Automation domain. Sessions in this domain encapsulate automated scanning pipelines, tool chains, and orchestrated workflows. Each session tracks which automation modules are loaded, the current pipeline execution state, intermediate results, and final outputs. The lifecycle governs how sessions are created when a user initiates an automation workflow, how they transition through scanning stages, how they can be suspended mid-pipeline and resumed later, and how they are closed upon completion or cancellation.

Automation sessions are resource-intensive — they may spawn subagents, maintain connections to external services, hold file locks on output directories, and accumulate large volumes of scan data. The lifecycle manager enforces strict limits on concurrent automation sessions, total runtime, and state serialization size to prevent resource exhaustion.

## Session State Machine

```
┌─────────┐     activate      ┌──────────┐
│ created │ ─────────────────→│  active   │
└─────────┘                   └────┬─────┘
                                   │
                    ┌──────────────┼──────────────┐
                    ▼              ▼              ▼
              ┌──────────┐  ┌──────────┐   ┌──────────┐
              │ scanning │  │paused    │   │error     │
              └────┬─────┘  └────┬─────┘   └────┬─────┘
                   │              │              │
                   ▼              ▼              ▼
              ┌──────────┐  ┌──────────┐   ┌──────────┐
              │complete  │  │scanning  │   │retryable │
              └────┬─────┘  └────┬─────┘   └────┬─────┘
                   │              │              │
                   └──────────────┼──────────────┘
                                  ▼
                           ┌──────────┐
                           │  closed  │
                           └──────────┘
```

### State Definitions

| State | Description |
|-------|-------------|
| `created` | Session initialized, automation modules not yet loaded |
| `active` | Session running, accepting pipeline commands |
| `scanning` | Pipeline actively executing tool chain |
| `paused` | Pipeline paused by user or system; intermediate state preserved |
| `error` | Pipeline encountered a non-fatal error; may be retried |
| `retryable` | Error recovered; session ready to resume from last checkpoint |
| `complete` | All pipeline stages finished; results available |
| `closed` | Session terminated and resources released |

## Session Creation

### `create_automation_session()`

Creates a new session for an advanced automation workflow.

**Parameters:**
- `name` (str): Human-readable session identifier
- `target` (str): Primary target for the automation pipeline
- `modules` (list[str]): Automation modules to load (references to files in `Advanced-Automation/`)
- `pipeline_config` (dict): Pipeline execution configuration
- `auto_checkpoint` (bool): Enable automatic state checkpointing (default: `True`)
- `max_duration` (int): Maximum session lifetime in seconds (default: `3600`)
- `max_modules` (int): Maximum concurrent modules (default: `10`)

**Returns:** `Session` object with unique ID, module list, and initial state.

**Validation:**
- Session name must be unique within the active automation session namespace
- All module references must exist in the `Advanced-Automation/` directory
- Pipeline config must include at minimum `target`, `scope`, and `output_format`
- Module list must not exceed `max_modules` limit

**Initialization Steps:**
1. Generate session ID: `auto_ses_<40-char-hex>`
2. Validate all module references against the filesystem
3. Create session directory: `sessions/<session_id>/`
4. Initialize pipeline state tracker
5. Register session in the active automation session registry
6. Emit `session.created` event with module count

### Module Loading

When modules are loaded into a session, each module reference is resolved to its full file path:

| Module | File Reference |
|--------|---------------|
| Subdomain Enumeration Automation | `Advanced-Automation/01-Subdomain-Enumeration-Automation.md` |
| Port Scanning Automation | `Advanced-Automation/02-Port-Scanning-Automation.md` |
| Vulnerability Scanning Automation | `Advanced-Automation/03-Vulnerability-Scanning-Automation.md` |
| JavaScript Analysis Automation | `Advanced-Automation/04-JavaScript-Analysis-Automation.md` |
| API Endpoint Discovery | `Advanced-Automation/05-API-Endpoint-Discovery.md` |
| Parameter Fuzzing Automation | `Advanced-Automation/06-Parameter-Fuzzing-Automation.md` |
| Directory Brute-Forcing | `Advanced-Automation/07-Directory-Brute-Forcing.md` |
| Authentication Testing Automation | `Advanced-Automation/09-Authentication-Testing-Automation.md` |
| Session Management Testing | `Advanced-Automation/10-Session-Management-Testing.md` |
| IDOR Detection Automation | `Advanced-Automation/11-IDOR-Detection-Automation.md` |
| SQL Injection Automation | `Advanced-Automation/12-SQL-Injection-Automation.md` |
| XSS Detection Automation | `Advanced-Automation/13-XSS-Detection-Automation.md` |
| SSRF Testing Automation | `Advanced-Automation/14-SSRF-Testing-Automation.md` |
| CSRF Testing Automation | `Advanced-Automation/15-CSRF-Testing-Automation.md` |
| Command Injection Automation | `Advanced-Automation/16-Command-Injection-Automation.md` |
| XXE Testing Automation | `Advanced-Automation/17-XXE-Testing-Automation.md` |
| SSTI Testing Automation | `Advanced-Automation/18-SSTI-Testing-Automation.md` |
| JWT Testing Automation | `Advanced-Automation/19-JWT-Testing-Automation.md` |
| Deserialization Testing | `Advanced-Automation/20-Deserialization-Testing.md` |
| Report Generation Automation | `Advanced-Automation/21-Report-Generation-Automation.md` |
| PoC Development Automation | `Advanced-Automation/22-PoC-Development-Automation.md` |
| Target Scouting Automation | `Advanced-Automation/23-Target-Scouting-Automation.md` |
| Scope Validation Automation | `Advanced-Automation/24-Scope-Validation-Automation.md` |
| Asset Tracking Automation | `Advanced-Automation/25-Asset-Tracking-Automation.md` |
| Change Monitoring Automation | `Advanced-Automation/26-Change-Monitoring-Automation.md` |
| Notification Alerting Automation | `Advanced-Automation/27-Notification-Alerting-Automation.md` |
| Data Collection Automation | `Advanced-Automation/28-Data-Collection-Automation.md` |
| Result Analysis Automation | `Advanced-Automation/29-Result-Analysis-Automation.md` |
| Tool Chaining Automation | `Advanced-Automation/30-Tool-Chaining-Automation.md` |
| Proxy Integration Automation | `Advanced-Automation/31-Proxy-Integration-Automation.md` |
| Browser Automation Workflows | `Advanced-Automation/32-Browser-Automation-Workflows.md` |
| Headless Browser Scripting | `Advanced-Automation/33-Headless-Browser-Scripting.md` |
| Regex Pattern Automation | `Advanced-Automation/34-Regex-Pattern-Automation.md` |
| Response Analysis Automation | `Advanced-Automation/35-Response-Analysis-Automation.md` |
| Header Injection Testing | `Advanced-Automation/36-Header-Injection-Testing.md` |
| CORS Testing Automation | `Advanced-Automation/37-CORS-Testing-Automation.md` |
| WebSocket Testing Automation | `Advanced-Automation/38-WebSocket-Testing-Automation.md` |
| GraphQL Testing Automation | `Advanced-Automation/39-GraphQL-Testing-Automation.md` |
| Cloud Service Enumeration | `Advanced-Automation/40-Cloud-Service-Enumeration.md` |
| DNS Data Extraction Automation | `Advanced-Automation/41-DNS-Data-Extraction-Automation.md` |
| Email Recon Automation | `Advanced-Automation/42-Email-Recon-Automation.md` |
| Social Media OSINT Automation | `Advanced-Automation/43-Social-Media-OSINT-Automation.md` |
| Framework Detection Automation | `Advanced-Automation/44-Framework-Detection-Automation.md` |
| Technology Stack Identification | `Advanced-Automation/45-Technology-Stack-Identification.md` |
| Endpoint Mapping Automation | `Advanced-Automation/46-Endpoint-Mapping-Automation.md` |
| Content Discovery Automation | `Advanced-Automation/47-Content-Discovery-Automation.md` |
| Version Detection Automation | `Advanced-Automation/48-Version-Detection-Automation.md` |
| Compliance Checking Automation | `Advanced-Automation/49-Compliance-Checking-Automation.md` |
| Workflow Orchestration Automation | `Advanced-Automation/50-Workflow-Orchestration-Automation.md` |

## Session Close

### `close_automation_session(session_id)`

Gracefully terminates an automation session.

**Pre-close Checks:**
1. Verify no critical pipeline stage is mid-execution
2. Check if unsaved results exist; prompt for checkpoint if needed
3. Signal any active subagents to complete current work item
4. Release external service connections (API keys, proxy connections)

**Close Process:**
1. Transition state to `closing`
2. Flush final checkpoint with complete pipeline state
3. Archive all intermediate and final results
4. Release file locks on output directories
5. Terminate any lingering subagent processes
6. Remove session from active registry
7. Transition state to `closed`
8. Emit `session.closed` event with duration and result count

**Force Close:**
- If a session is stuck in `scanning` state beyond timeout, a force close is triggered
- Force close terminates all subagents immediately
- Intermediate results are preserved but may be inconsistent
- Session metadata records `terminated_reason: timeout` or `terminated_reason: force`

## Session Suspend

### `suspend_automation_session(session_id)`

Pauses an active automation session, preserving pipeline state.

**Suspend Process:**
1. Signal pipeline to pause after current tool completes
2. Wait for current tool to finish (max wait: 30 seconds)
3. Serialize pipeline state including:
   - Current stage index
   - Completed tool results
   - Pending tool queue
   - Accumulated findings
4. Release active resources (subagents, connections, file handles)
5. Transition state to `suspended`
6. Record `suspended_at` timestamp and reason in metadata

**Suspend Reasons:**
| Reason | Description |
|--------|-------------|
| `user_initiated` | User explicitly paused the session |
| `resource_limit` | System resource budget exceeded |
| `maintenance` | System maintenance window approaching |
| `quota_exceeded` | API rate limit or tool quota exhausted |
| `checkpoint_required` | State size approaching serialization limit |

## Session Resume

### `resume_automation_session(session_id)`

Restores a suspended automation session.

**Resume Process:**
1. Load serialized pipeline state from session store
2. Verify state integrity via checksum
3. Re-resolve all module references against filesystem
4. Reinitialize tool connections and proxies
5. Rebuild pending tool queue from saved state
6. Transition state to `active`
7. Resume pipeline from last completed stage
8. Emit `session.resumed` event with checkpoint age

**Resume Validation:**
- Module files must still exist at referenced paths
- External service connections must be re-establishable
- Pipeline state must pass checksum verification
- Session store must be accessible

## Session Metadata Schema

### Standard Fields

| Field | Type | Description |
|-------|------|-------------|
| `session_id` | str | Unique session identifier |
| `name` | str | Human-readable name |
| `state` | str | Current lifecycle state |
| `created_at` | ISO 8601 | Creation timestamp |
| `updated_at` | ISO 8601 | Last update timestamp |
| `suspended_at` | ISO 8601 | Last suspension timestamp |
| `closed_at` | ISO 8601 | Closure timestamp |
| `target` | str | Primary scan target |
| `modules_loaded` | list[str] | Loaded automation modules |
| `pipeline_stage` | int | Current pipeline stage index |
| `total_stages` | int | Total pipeline stages |
| `results_count` | int | Accumulated findings count |
| `duration_seconds` | int | Total active duration |
| `subagents_spawned` | int | Number of subagents created |
| `checkpoint_count` | int | Number of checkpoints saved |

### Automation-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `pipeline_config` | dict | Pipeline execution configuration |
| `tool_status` | dict[str, str] | Status of each tool in the chain |
| `output_directory` | str | Path to session output directory |
| `findings_summary` | dict | Aggregated findings by severity |
| `error_log` | list[dict] | Errors encountered during execution |
| `api_quota_remaining` | dict | Remaining API quotas per service |
| `proxy_config` | dict | Proxy configuration if used |
| `scope_definition` | dict | Validated scope boundaries |

## Session Lookup

### `find_automation_sessions()`

Search for automation sessions by various criteria.

**Search Parameters:**
- `state` (str): Filter by session state
- `target` (str): Filter by scan target
- `modules` (list[str]): Filter by loaded modules
- `created_after` (ISO 8601): Filter by creation time
- `min_results` (int): Filter by minimum result count

**Examples:**
```python
# Find all active automation sessions
sessions = find_automation_sessions(state="active")

# Find sessions targeting a specific domain
sessions = find_automation_sessions(target="example.com")

# Find sessions with specific modules loaded
sessions = find_automation_sessions(modules=["12-SQL-Injection-Automation.md"])

# Find recently created sessions with findings
sessions = find_automation_sessions(
    created_after="2025-01-01T00:00:00Z",
    min_results=1
)
```

**Search Behavior:**
- Filters are AND-ed together
- Results sorted by `created_at` descending
- Default result limit: 100
- Search includes both active and archived sessions

## Session Limits

### Automation-Specific Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_automation_sessions` | 5 | Concurrent automation sessions |
| `max_modules_per_session` | 10 | Modules loaded per session |
| `max_session_duration` | 3600s (1h) | Maximum pipeline runtime |
| `max_tool_chain_depth` | 8 | Maximum sequential tool stages |
| `max_subagents_per_session` | 5 | Subagents spawned per session |
| `max_results_per_session` | 10000 | Findings before auto-checkpoint |
| `max_state_size` | 50MB | Serialized state size limit |
| `max_output_directory_size` | 500MB | Total output size limit |
| `max_api_calls_per_session` | 5000 | External API calls per session |
| `max_checkpoint_age` | 300s (5min) | Time between auto-checkpoints |

### Limit Enforcement

- Concurrent session limit enforced at creation time
- Module count validated during session creation
- Duration checked on each pipeline stage transition
- API quota checked before each external call
- State size checked before each checkpoint
- Output directory size checked after each tool run
- When limits are hit: pause → checkpoint → notify user

## Session Isolation

### File System Isolation

Each automation session operates within its own directory structure:

```
sessions/<session_id>/
├── state/
│   ├── pipeline.json          # Pipeline execution state
│   ├── tool-results/          # Individual tool outputs
│   │   ├── stage-01/
│   │   ├── stage-02/
│   │   └── ...
│   └── checkpoints/           # Serialized checkpoints
├── output/
│   ├── findings.json          # Aggregated findings
│   ├── reports/               # Generated reports
│   └── artifacts/             # Tool artifacts
├── config/
│   ├── pipeline-config.json   # Session configuration
│   └── module-manifest.json   # Loaded modules list
└── metadata.json              # Session metadata
```

### Network Isolation

- Each session maintains its own proxy configuration
- API keys are session-scoped and not shared
- External connections are tracked and cleaned up on close
- Rate limiting is applied per-session, not globally

### Memory Isolation

- Session state is serialized to disk, not held in shared memory
- Subagent memory is scoped to the spawning session
- No cross-session data leakage through shared state

### Concurrency Control

- File locks prevent concurrent writes to the same session directory
- Pipeline state is updated atomically via write-to-temp-then-rename
- Checkpoint creation is serialized per session

## Pipeline Execution Tracking

### Stage Tracking

Each automation session tracks pipeline execution as an ordered sequence of stages:

```json
{
  "pipeline": {
    "stages": [
      {
        "index": 0,
        "module": "01-Subdomain-Enumeration-Automation.md",
        "status": "complete",
        "started_at": "2025-01-15T10:00:00Z",
        "completed_at": "2025-01-15T10:02:30Z",
        "result_count": 45
      },
      {
        "index": 1,
        "module": "02-Port-Scanning-Automation.md",
        "status": "running",
        "started_at": "2025-01-15T10:02:30Z",
        "completed_at": null,
        "result_count": 0
      }
    ],
    "current_stage": 1,
    "total_stages": 8
  }
}
```

### Status Transitions per Stage

```
pending → queued → running → complete
                        ↓
                    failed → retryable → running
                        ↓
                    skipped
```

### Result Accumulation

Results from each stage are accumulated in the session state:

- Each tool output is stored as a separate file under `state/tool-results/`
- Findings are extracted and deduplicated across stages
- Severity classification is applied to each finding
- Cross-stage correlation is performed when applicable

## Events

### Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `automation.session.created` | session_id, module_count | New automation session created |
| `automation.session.activated` | session_id | Session transitioned to active |
| `automation.session.scanning_started` | session_id, target | Pipeline execution began |
| `automation.session.stage_started` | session_id, stage_index, module | Tool stage started |
| `automation.session.stage_completed` | session_id, stage_index, result_count | Tool stage completed |
| `automation.session.stage_failed` | session_id, stage_index, error | Tool stage failed |
| `automation.session.finding` | session_id, finding | New finding detected |
| `automation.session.suspended` | session_id, reason | Session suspended |
| `automation.session.resumed` | session_id, checkpoint_age | Session resumed |
| `automation.session.completed` | session_id, total_findings | Pipeline finished |
| `automation.session.closed` | session_id, duration | Session closed |
| `automation.session.quota_warning` | session_id, service, remaining | API quota low |
| `automation.session.checkpoint` | session_id, checkpoint_id | State checkpoint saved |

### Event Subscription

```python
subscribe("automation.session.finding", handler)
subscribe("automation.session.stage_failed", error_handler)
subscribe("automation.session.quota_warning", quota_handler)
```

## Error Recovery

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| Tool Failure | Port scanner crash, fuzzing timeout | Retry with exponential backoff |
| API Limit | Rate limit hit, quota exhausted | Pause and wait for reset |
| Network Error | Connection refused, DNS failure | Retry with alternative endpoint |
| State Corruption | Checksum mismatch, parse error | Restore from last valid checkpoint |
| Resource Exhaustion | Memory limit, disk full | Suspend and notify user |
| Scope Violation | Target out of scope | Stop current stage, log warning |

### Recovery Flow

```
error detected → classify error → check retry count
    → if retryable and retries remaining → backoff → retry
    → if non-retryable or retries exhausted → checkpoint → suspend → notify
```

### Checkpoint Recovery

When a session is resumed after an error:
1. Load the last valid checkpoint
2. Identify which stages need to be re-executed
3. Preserve results from completed stages
4. Resume pipeline from the failed stage
5. Log the recovery event with error history

## Integration Points

### With Checkpoint System

- Automation sessions integrate with the checkpoint subsystem
- Checkpoints are created automatically at configurable intervals
- Manual checkpoints can be triggered at any time
- Checkpoint data includes full pipeline state, not just metadata

### With Persistence System

- Session state is persisted via the session persistence layer
- Output files are managed by the session directory structure
- Metadata is indexed for search and retrieval

### With Recovery System

- Failed sessions can be recovered from the latest checkpoint
- Recovery preserves all intermediate results
- Recovery handles module file changes gracefully

### With Memory System

- Automation sessions can access the working memory system
- Findings are stored in session-scoped memory
- Cross-session learning is supported via the long-term memory system

## Usage Examples

### Creating a Full Scan Pipeline

```python
session = create_automation_session(
    name="full-scan-example.com",
    target="example.com",
    modules=[
        "01-Subdomain-Enumeration-Automation.md",
        "02-Port-Scanning-Automation.md",
        "03-Vulnerability-Scanning-Automation.md",
        "05-API-Endpoint-Discovery.md",
        "07-Directory-Brute-Forcing.md"
    ],
    pipeline_config={
        "scope": "web",
        "output_format": "json",
        "aggression_level": "normal"
    }
)
```

### Suspending and Resuming

```python
# Suspend mid-pipeline
suspend_automation_session(session.session_id)

# Resume later
resume_automation_session(session.session_id)
# Pipeline continues from last completed stage
```

### Querying Session Results

```python
sessions = find_automation_sessions(
    target="example.com",
    state="complete"
)
for s in sessions:
    print(f"Found {s.results_count} findings in {s.duration_seconds}s")
```
