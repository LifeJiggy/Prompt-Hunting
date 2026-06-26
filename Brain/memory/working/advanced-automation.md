# Working Memory: Advanced Automation Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `ADV-AUTO-001` |
| Root Folder | `Advanced-Automation/` |
| Total Files | 50 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict + optional JSON snapshot |
| Typical Lifetime | Single scan pipeline run |
| Eviction Trigger | Pipeline completion or 24h TTL |

---

## Overview

Working memory for automated scanning pipelines captures the ephemeral state of every
active scan, from subdomain enumeration through workflow orchestration. This is the
"scratchpad" that each pipeline stage reads from and writes to — it holds intermediate
results, tool outputs, dedup hashes, and pipeline coordination state that is never
persisted to disk except for optional debug snapshots.

The automation domain spans 50 distinct modules covering the full lifecycle of
automated security assessments. Working memory must support:

- **Multi-stage pipeline state**: Track which stage (1–50) each pipeline is at,
  whether it succeeded, failed, or is waiting on dependencies.
- **Tool output buffering**: Capture stdout/stderr from subfinder, httpx, nmap,
  nuclei, and custom scripts before downstream consumers process them.
- **Deduplication**: Prevent the same asset, URL, or finding from being processed
  multiple times across parallel pipeline forks.
- **Rate-limit coordination**: Share token-bucket counters across concurrent tool
  invocations to respect target rate limits.
- **Error accumulation**: Collect transient errors for retry logic without halting
  the entire pipeline.
- **Progress tracking**: Expose per-pipeline progress percentages for UI dashboards.

Working memory is volatile by design. If the process crashes, all state is lost —
this is intentional. Pipelines are idempotent and can be restarted from any completed
stage using the persistent snapshot layer (Long-Term Memory) as the source of truth.

---

## Data Schema (YAML)

```yaml
working_memory_advanced_automation:
  version: "2.1"
  scope: "pipeline-run"
  ttl_seconds: 86400

  pipeline_state:
    pipeline_id: "string (uuid4)"
    pipeline_name: "string"
    started_at: "ISO8601"
    updated_at: "ISO8601"
    status: "enum(pending|running|paused|completed|failed|cancelled)"
    current_stage: "integer (1-50)"
    total_stages: "integer"
    progress_pct: "float (0.0-100.0)"
    target_domain: "string"
    scope_regex: "string (compiled)"

  stage_results:
    stage_id: "integer (1-50)"
    stage_name: "string"
    status: "enum(pending|running|completed|failed|skipped|retrying)"
    started_at: "ISO8601"
    completed_at: "ISO8601"
    duration_ms: "integer"
    tool_name: "string"
    tool_version: "string"
    stdout: "string (truncated at 1MB)"
    stderr: "string (truncated at 256KB)"
    exit_code: "integer"
    output_count: "integer"
    output_hashes: "list[string] (sha256 of each output item)"

  dedup_store:
    key_type: "enum(subdomain|url|ip|port|hash)"
    key_value: "string"
    first_seen_at: "ISO8601"
    pipeline_id: "string"
    stage_id: "integer"

  rate_limit_counters:
    target_host: "string"
    window_start: "ISO8601"
    request_count: "integer"
    max_requests: "integer"
    window_seconds: "integer"
    retry_after: "ISO8601 (nullable)"

  error_accumulator:
    error_id: "string (uuid4)"
    pipeline_id: "string"
    stage_id: "integer"
    error_type: "enum(timeout|connection_refused|dns_failure|rate_limit|auth_error|unknown)"
    error_message: "string"
    retry_count: "integer"
    max_retries: "integer (default 3)"
    next_retry_at: "ISO8601"
    is_fatal: "boolean"

  tool_outputs:
    output_id: "string (uuid4)"
    pipeline_id: "string"
    stage_id: "integer"
    tool: "string"
    output_type: "enum(subdomains|urls|ports|services|vulnerabilities|screenshots)"
    data: "list[string]"
    metadata: "map[string]string"
    consumed_by: "list[integer] (downstream stage IDs)"
```

---

## Read/Write Operations

```python
import uuid
import hashlib
import time
from datetime import datetime, timezone, timedelta
from typing import Optional
from enum import Enum


class PipelineStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    PAUSED = "paused"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class StageStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    SKIPPED = "skipped"
    RETRYING = "retrying"


class AdvancedAutomationWorkingMemory:
    """
    In-memory working state for automated scanning pipelines.
    Covers all 50 stages from Subdomain Enumeration through Workflow Orchestration.
    """

    def __init__(self, pipeline_id: Optional[str] = None, ttl_seconds: int = 86400):
        self.pipeline_id = pipeline_id or str(uuid.uuid4())
        self.ttl_seconds = ttl_seconds
        self.created_at = datetime.now(timezone.utc)

        self.pipelines: dict[str, dict] = {}
        self.stage_results: dict[str, dict[int, dict]] = {}
        self.dedup_store: dict[str, set[str]] = {}
        self.rate_limit_counters: dict[str, dict] = {}
        self.error_accumulator: dict[str, list[dict]] = {}
        self.tool_outputs: dict[str, dict[int, dict]] = {}

    def create_pipeline(
        self,
        pipeline_name: str,
        target_domain: str,
        total_stages: int = 50,
        scope_regex: str = "",
    ) -> str:
        """Create a new pipeline run and initialize its working memory."""
        pid = self.pipeline_id
        now = datetime.now(timezone.utc).isoformat()

        self.pipelines[pid] = {
            "pipeline_id": pid,
            "pipeline_name": pipeline_name,
            "started_at": now,
            "updated_at": now,
            "status": PipelineStatus.PENDING.value,
            "current_stage": 0,
            "total_stages": total_stages,
            "progress_pct": 0.0,
            "target_domain": target_domain,
            "scope_regex": scope_regex,
        }

        self.stage_results[pid] = {}
        self.error_accumulator[pid] = []
        self.tool_outputs[pid] = {}
        self.dedup_store[pid] = set()

        for stage_id in range(1, total_stages + 1):
            self.stage_results[pid][stage_id] = {
                "stage_id": stage_id,
                "stage_name": "",
                "status": StageStatus.PENDING.value,
                "started_at": None,
                "completed_at": None,
                "duration_ms": 0,
                "tool_name": "",
                "tool_version": "",
                "stdout": "",
                "stderr": "",
                "exit_code": None,
                "output_count": 0,
                "output_hashes": [],
            }

        return pid

    def begin_stage(self, pipeline_id: str, stage_id: int, stage_name: str,
                    tool_name: str, tool_version: str = "") -> None:
        """Mark a stage as running and record start time."""
        if stage_id not in self.stage_results.get(pipeline_id, {}):
            raise ValueError(f"Stage {stage_id} not found for pipeline {pipeline_id}")

        now = datetime.now(timezone.utc).isoformat()
        self.stage_results[pipeline_id][stage_id].update({
            "stage_name": stage_name,
            "status": StageStatus.RUNNING.value,
            "started_at": now,
            "tool_name": tool_name,
            "tool_version": tool_version,
        })

        self.pipelines[pipeline_id]["status"] = PipelineStatus.RUNNING.value
        self.pipelines[pipeline_id]["current_stage"] = stage_id
        self.pipelines[pipeline_id]["updated_at"] = now
        self.pipelines[pipeline_id]["progress_pct"] = (
            (stage_id - 1) / self.pipelines[pipeline_id]["total_stages"] * 100
        )

    def complete_stage(self, pipeline_id: str, stage_id: int, exit_code: int,
                       stdout: str = "", stderr: str = "") -> None:
        """Mark a stage as completed and store its output."""
        now = datetime.now(timezone.utc).isoformat()
        stage = self.stage_results[pipeline_id][stage_id]
        started = datetime.fromisoformat(stage["started_at"])

        stage.update({
            "status": StageStatus.COMPLETED.value,
            "completed_at": now,
            "duration_ms": int((datetime.now(timezone.utc) - started).total_seconds() * 1000),
            "exit_code": exit_code,
            "stdout": stdout[:1_048_576],
            "stderr": stderr[:262_144],
        })

        total = self.pipelines[pipeline_id]["total_stages"]
        self.pipelines[pipeline_id]["progress_pct"] = (stage_id / total) * 100
        self.pipelines[pipeline_id]["updated_at"] = now

    def fail_stage(self, pipeline_id: str, stage_id: int, error_type: str,
                   error_message: str, is_fatal: bool = False,
                   max_retries: int = 3) -> None:
        """Mark a stage as failed and record the error."""
        stage = self.stage_results[pipeline_id][stage_id]
        stage["status"] = StageStatus.FAILED.value

        error = {
            "error_id": str(uuid.uuid4()),
            "pipeline_id": pipeline_id,
            "stage_id": stage_id,
            "error_type": error_type,
            "error_message": error_message,
            "retry_count": 0,
            "max_retries": max_retries,
            "next_retry_at": None,
            "is_fatal": is_fatal,
        }

        self.error_accumulator[pipeline_id].append(error)

        if is_fatal:
            self.pipelines[pipeline_id]["status"] = PipelineStatus.FAILED.value

    def check_dedup(self, pipeline_id: str, key_type: str, key_value: str) -> bool:
        """Check if an item has already been seen. Returns True if duplicate."""
        composite = f"{key_type}:{key_value}"
        if composite in self.dedup_store.get(pipeline_id, set()):
            return True
        self.dedup_store[pipeline_id].add(composite)
        return False

    def batch_check_dedup(self, pipeline_id: str, key_type: str,
                          values: list[str]) -> tuple[list[str], list[str]]:
        """Check multiple items for dedup. Returns (new_items, duplicates)."""
        new_items = []
        duplicates = []
        for v in values:
            if self.check_dedup(pipeline_id, key_type, v):
                duplicates.append(v)
            else:
                new_items.append(v)
        return new_items, duplicates

    def store_tool_output(self, pipeline_id: str, stage_id: int, tool: str,
                          output_type: str, data: list[str],
                          metadata: Optional[dict] = None) -> str:
        """Store tool output in working memory, return output_id."""
        output_id = str(uuid.uuid4())
        hashes = [hashlib.sha256(item.encode()).hexdigest()[:16] for item in data]

        self.tool_outputs[pipeline_id][stage_id] = {
            "output_id": output_id,
            "pipeline_id": pipeline_id,
            "stage_id": stage_id,
            "tool": tool,
            "output_type": output_type,
            "data": data,
            "metadata": metadata or {},
            "consumed_by": [],
        }

        self.stage_results[pipeline_id][stage_id]["output_count"] = len(data)
        self.stage_results[pipeline_id][stage_id]["output_hashes"] = hashes

        return output_id

    def consume_output(self, pipeline_id: str, producer_stage: int,
                       consumer_stage: int) -> Optional[list[str]]:
        """Read output from a producer stage and mark it as consumed."""
        if producer_stage not in self.tool_outputs.get(pipeline_id, {}):
            return None

        output = self.tool_outputs[pipeline_id][producer_stage]
        output["consumed_by"].append(consumer_stage)
        return output["data"]

    def check_rate_limit(self, target_host: str, max_requests: int = 10,
                         window_seconds: int = 60) -> tuple[bool, Optional[int]]:
        """Check rate limit. Returns (allowed, retry_after_seconds)."""
        now = time.time()
        counter = self.rate_limit_counters.get(target_host, {})

        if not counter or (now - counter.get("window_start", 0)) > window_seconds:
            self.rate_limit_counters[target_host] = {
                "window_start": now,
                "request_count": 1,
                "max_requests": max_requests,
                "window_seconds": window_seconds,
            }
            return True, None

        if counter["request_count"] >= max_requests:
            retry_after = int(window_seconds - (now - counter["window_start"]))
            return False, max(retry_after, 1)

        counter["request_count"] += 1
        return True, None

    def get_pipeline_progress(self, pipeline_id: str) -> dict:
        """Return current pipeline progress summary."""
        pipeline = self.pipelines.get(pipeline_id, {})
        stages = self.stage_results.get(pipeline_id, {})

        completed = sum(1 for s in stages.values()
                       if s["status"] == StageStatus.COMPLETED.value)
        failed = sum(1 for s in stages.values()
                    if s["status"] == StageStatus.FAILED.value)
        total = pipeline.get("total_stages", 0)

        return {
            "pipeline_id": pipeline_id,
            "status": pipeline.get("status"),
            "progress_pct": pipeline.get("progress_pct", 0),
            "stages_completed": completed,
            "stages_failed": failed,
            "stages_total": total,
            "errors": len(self.error_accumulator.get(pipeline_id, [])),
        }

    def cleanup_expired(self) -> int:
        """Remove pipelines that exceeded their TTL. Returns count removed."""
        now = datetime.now(timezone.utc)
        expired = []
        for pid, pipeline in self.pipelines.items():
            updated = datetime.fromisoformat(pipeline["updated_at"])
            if (now - updated).total_seconds() > self.ttl_seconds:
                expired.append(pid)

        for pid in expired:
            del self.pipelines[pid]
            self.stage_results.pop(pid, None)
            self.dedup_store.pop(pid, None)
            self.error_accumulator.pop(pid, None)
            self.tool_outputs.pop(pid, None)

        return len(expired)

    def snapshot(self, pipeline_id: str) -> dict:
        """Create a JSON-serializable snapshot for debug/restore."""
        return {
            "pipeline": self.pipelines.get(pipeline_id, {}),
            "stages": {
                str(k): v for k, v in self.stage_results.get(pipeline_id, {}).items()
            },
            "errors": self.error_accumulator.get(pipeline_id, []),
            "dedup_count": len(self.dedup_store.get(pipeline_id, set())),
        }
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Active pipelines | 16 | Oldest idle pipeline evicted | Configurable via `max_pipelines` |
| Stage results per pipeline | 50 | Pipeline eviction only | One entry per stage |
| Dedup store per pipeline | 100,000 entries | LRU eviction when full | Prevents memory bloat on large targets |
| Tool output buffer per stage | 1 MB stdout, 256 KB stderr | Truncation on write | Excess data goes to persistent storage |
| Error accumulator per pipeline | 200 entries | FIFO eviction | Keeps most recent errors |
| Rate limit counters | 1,000 hosts | TTL-based expiry (2x window) | Auto-cleanup on access |
| Total working memory | 512 MB soft cap | Pipeline eviction + dedup LRU | Monitored via `memory_usage_bytes` |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Every pipeline has a TTL (default 24h).
  - `cleanup_expired()` removes all state for expired pipelines.
  - Called lazily on each new operation.

Priority 2: LRU Dedup Eviction
  - When dedup store exceeds 100K entries per pipeline, evict oldest 10%.
  - Only affects dedup tracking — re-discovered items are treated as new.

Priority 3: Pipeline Count Limit
  - When active pipelines exceed 16, the oldest idle (not running) pipeline
    is evicted entirely.
  - Running pipelines are never evicted.

Priority 4: Output Truncation
  - Stdout capped at 1 MB, stderr at 256 KB per stage.
  - Full output should be written to persistent storage by the pipeline stage.
```

---

## Lifecycle

```
1. INITIALIZATION
   Pipeline starts → create_pipeline() → all stage slots created (status=pending)

2. EXECUTION
   For each stage 1..50:
     begin_stage() → tool runs → complete_stage() or fail_stage()
     Output stored via store_tool_output()
     Dedup checked via check_dedup()
     Rate limits enforced via check_rate_limit()

3. INTER-STAGE COORDINATION
   Downstream stages consume upstream outputs via consume_output()
   Dedup prevents duplicate processing across parallel forks

4. COMPLETION / FAILURE
   Pipeline reaches status=completed or status=failed
   Snapshot created for persistent storage
   Working memory remains available for post-run analysis

5. EVICTION
   TTL expires → cleanup_expired() removes all state
   Or: memory pressure → LRU eviction on dedup stores
   Or: pipeline count limit → oldest idle pipeline evicted
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Long-Term Memory | Write | Completed stage results, final findings |
| Short-Term Memory | Read/Write | Current pipeline context, active targets |
| Session Memory | Read | Authentication tokens, API keys |
| Cross-Session Memory | Read | Previous scan results for dedup seeding |

---

## Domain File References (Advanced-Automation/)

### 01-Subdomain-Enumeration-Automation
Automated subdomain discovery using subfinder, amass, and DNS brute-force.
Working memory stores: discovered subdomains, DNS resolution results, wildcard detection state.

### 02-HTTP-Probing-Automation
Automated HTTP service discovery and fingerprinting via httpx.
Working memory stores: live hosts, response codes, technology signatures, content lengths.

### 03-Port-Scanning-Automation
Automated port scanning with nmap/masscan orchestration.
Working memory stores: open ports, service versions, scan timing, rate-limit state.

### 04-Technology-Detection-Automation
Automated technology stack identification from HTTP responses.
Working memory stores: tech fingerprints, version strings, CMS detection results.

### 05-Directory-Discovery-Automation
Automated directory and file brute-forcing with ffuf/gobuster.
Working memory stores: discovered paths, response code distribution, size-based filtering state.

### 06-Parameter-Discovery-Automation
Automated parameter discovery using Arjun/paramspider.
Working memory stores: discovered parameters, parameter types, value patterns.

### 07-Secret-Scanning-Automation
Automated secret detection in source code and JS bundles.
Working memory stores: API keys, tokens, credentials patterns, file locations.

### 08-Cloud-Storage-Discovery-Automation
Automated discovery of S3/GCS/Azure Blob storage.
Working memory stores: bucket names, access states, region mappings.

### 09-API-Endpoint-Discovery-Automation
Automated REST/GraphQL endpoint enumeration.
Working memory stores: endpoint paths, methods, parameters, response schemas.

### 10-JavaScript-Analysis-Automation
Automated JS bundle analysis for endpoints and secrets.
Working memory stores: extracted URLs, function calls, obfuscation patterns.

### 11-Certificate-Transparency-Automation
Automated CT log monitoring for subdomain discovery.
Working memory stores: certificate entries, issuer mappings, temporal patterns.

### 12-DNS-Zone-Transfer-Automation
Automated zone transfer attempts across nameservers.
Working memory stores: zone data, nameserver configs, transfer results.

### 13-WAF-Detection-Automation
Automated WAF/CDN identification and fingerprinting.
Working memory stores: WAF signatures, bypass attempts, header patterns.

### 14-Redirect-Chain-Automation
Automated redirect chain analysis and origin discovery.
Working memory stores: redirect hops, final URLs, cookie behaviors.

### 15-Screenshot-Automation
Automated visual reconnaissance with GoVisual/EyeWitness.
Working memory stores: screenshot paths, page titles, visual hashes.

### 16-Security-Header-Automation
Automated security header audit across all live hosts.
Working memory stores: header values, missing headers, CSP analysis.

### 17-Cookie-Analysis-Automation
Automated cookie attribute audit (Secure, HttpOnly, SameSite).
Working memory stores: cookie names, attributes, scope, flags.

### 18-CORS-Misconfiguration-Automation
Automated CORS policy testing.
Working memory stores: origin reflections, credentialed CORS, preflight results.

### 19-Subdomain-Takeover-Automation
Automated subdomain takeover detection via dangling CNAME.
Working memory stores: CNAME chains, unclaimed services, takeover feasibility.

### 20-Email-Harvesting-Automation
Automated email address discovery from public sources.
Working memory stores: email addresses, source domains, format patterns.

### 21-Technology-Version-Exploitation-Automation
Automated CVE matching for detected technology versions.
Working memory stores: version-to-CVE mappings, exploit availability, risk scores.

### 22-Web-Fingerprinting-Automation
Advanced web application fingerprinting beyond basic tech detection.
Working memory stores: framework versions, patch levels, deployment patterns.

### 23-Content-Discovery-Automation
Automated content discovery beyond simple directory brute-forcing.
Working memory stores: virtual hosts, API documentation, hidden content.

### 24-Authentication-Bypass-Automation
Automated testing for common authentication bypass patterns.
Working memory stores: bypass attempts, response differentials, auth state.

### 25-Session-Management-Automation
Automated session handling analysis.
Working memory stores: session tokens, entropy analysis, fixation tests.

### 26-Rate-Limiting-Analysis-Automation
Automated rate limit detection and characterization.
Working memory stores: rate limit thresholds, window sizes, bypass methods.

### 27-GraphQL-Discovery-Automation
Automated GraphQL endpoint discovery and introspection.
Working memory stores: schema, queries, mutations, types.

### 28-WebSocket-Discovery-Automation
Automated WebSocket endpoint discovery and message analysis.
Working memory stores: WS URLs, message formats, auth mechanisms.

### 29-Mobile-API-Discovery-Automation
Automated mobile API endpoint extraction from APK/IPA.
Working memory stores: API base URLs, endpoints, auth headers.

### 30-Infrastructure-Mapping-Automation
Automated infrastructure topology mapping.
Working memory stores: IP ranges, ASN data, hosting relationships.

### 31-DNS-Record-Analysis-Automation
Comprehensive DNS record analysis (MX, TXT, SPF, DKIM, DMARC).
Working memory stores: record types, values, misconfigurations.

### 32-SSL-TLS-Analysis-Automation
Automated SSL/TLS configuration audit.
Working memory stores: cipher suites, protocol versions, certificate chain issues.

### 33-Load-Balancer-Detection-Automation
Automated load balancer identification and fingerprinting.
Working memory stores: LB type, sticky sessions, backend detection.

### 34-CDN-Detection-Automation
Automated CDN identification and origin IP discovery.
Working memory stores: CDN signatures, origin IPs, bypass methods.

### 35-Virtual-Host-Discovery-Automation
Automated virtual host enumeration on shared infrastructure.
Working memory stores: vhost names, response differences, IP mappings.

### 36-Web-Server-Configuration-Automation
Automated web server configuration analysis.
Working memory stores: server versions, modules, directory listings.

### 37-Error-Page-Analysis-Automation
Automated error page fingerprinting for info disclosure.
Working memory stores: error patterns, stack traces, debug info.

### 38-Input-Vector-Discovery-Automation
Automated identification of all user input vectors.
Working memory stores: forms, parameters, headers, file uploads.

### 39-Response-Analysis-Automation
Automated HTTP response analysis for anomalies.
Working memory stores: response patterns, timing data, size distributions.

### 40-Concurrent-Pipeline-Management
Orchestration of multiple parallel scanning pipelines.
Working memory stores: pipeline dependencies, resource allocation, scheduling.

### 41-Resource-Pool-Management
Resource allocation and pooling for scanning tools.
Working memory stores: available resources, utilization, allocation decisions.

### 42-Task-Queue-Optimization
Priority-based task queue for scan operations.
Working memory stores: queue state, priorities, worker availability.

### 43-Distributed-Scanning-Coordination
Coordination of distributed scanning across multiple workers.
Working memory stores: worker states, work distribution, result aggregation.

### 44-Scan-Scheduling-Management
Time-based scan scheduling and cron management.
Working memory stores: schedule definitions, next-run times, dependencies.

### 45-Pipeline-Dependency-Resolution
DAG-based dependency resolution for pipeline stages.
Working memory stores: dependency graph, execution order, parallelization.

### 46-Output-Format-Management
Standardized output format conversion between tools.
Working memory stores: format mappings, conversion state, output targets.

### 47-Notification-Integration
Alert and notification integration for pipeline events.
Working memory stores: notification channels, templates, delivery state.

### 48-Logging-Standardization
Standardized logging across all automation stages.
Working memory stores: log buffers, severity filters, aggregation state.

### 49-Performance-Metrics-Collection
Automated collection of performance and efficiency metrics.
Working memory stores: timing data, throughput counts, resource usage.

### 50-Workflow-Orchestration-Automation
End-to-end workflow orchestration with conditional logic.
Working memory stores: workflow definitions, execution state, branching decisions.
