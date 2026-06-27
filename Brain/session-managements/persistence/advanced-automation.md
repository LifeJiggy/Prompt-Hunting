# State Persistence: Advanced Automation Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Advanced Automation |
| **Directory** | `Advanced-Automation/` |
| **File Count** | 50 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/advanced-automation.md` |
| **Serialization** | JSON (primary), MessagePack (hot path), Protobuf (cross-session) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the Advanced Automation domain. Every scanning pipeline, scan result, tool execution, and workflow orchestration event must be serializable, recoverable, and auditable. The persistence layer ensures that interrupted scans resume from checkpoints, scan results survive session boundaries, and pipeline state is consistent across concurrent executions.

The Advanced Automation domain encompasses 50 specialized automation modules covering subdomain enumeration, port scanning, vulnerability detection, JavaScript analysis, API discovery, fuzzing, directory brute-forcing, and full workflow orchestration. Each module generates ephemeral state that must be captured at defined persistence triggers.

---

## 2. Domain File Registry

All 50 domain files are tracked in the persistence index. Each file maps to a stateful pipeline component:

### Reconnaissance Automation
| # | File | State Category | Persistence Priority |
|---|------|---------------|---------------------|
| 01 | `01-Subdomain-Enumeration-Automation.md` | Asset enumeration state | HIGH |
| 02 | `02-Port-Scanning-Automation.md` | Scan progress and open ports | HIGH |
| 03 | `03-Vulnerability-Scanning-Automation.md` | Vuln scan results queue | CRITICAL |
| 04 | `04-JavaScript-Analysis-Automation.md` | JS endpoint extraction state | MEDIUM |
| 05 | `05-API-Endpoint-Discovery.md` | Discovered API catalog | HIGH |
| 06 | `06-Parameter-Fuzzing-Automation.md` | Fuzzing queue and results | HIGH |
| 07 | `07-Directory-Brute-Forcing.md` | Discovery progress tracker | MEDIUM |
| 09 | `09-Authentication-Testing-Automation.md` | Auth test state machine | HIGH |
| 10 | `10-Session-Management-Testing.md` | Session state capture | MEDIUM |

### Vulnerability Detection Automation
| # | File | State Category | Persistence Priority |
|---|------|---------------|---------------------|
| 11 | `11-IDOR-Detection-Automation.md` | IDOR parameter map | HIGH |
| 12 | `12-SQL-Injection-Automation.md` | SQLi payload results | CRITICAL |
| 13 | `13-XSS-Detection-Automation.md` | XSS reflection points | CRITICAL |
| 14 | `14-SSRF-Testing-Automation.md` | SSRF callback state | HIGH |
| 15 | `15-CSRF-Testing-Automation.md` | CSRF token inventory | HIGH |
| 16 | `16-Command-Injection-Automation.md` | Command injection results | CRITICAL |
| 17 | `17-XXE-Testing-Automation.md` | XXE test outcomes | HIGH |
| 18 | `18-SSTI-Testing-Automation.md` | Template engine detection | HIGH |
| 19 | `19-JWT-Testing-Automation.md` | JWT analysis results | HIGH |
| 20 | `20-Deserialization-Testing.md` | Deserialization vectors | HIGH |

### Output and Reporting Automation
| # | File | State Category | Persistence Priority |
|---|------|---------------|---------------------|
| 21 | `21-Report-Generation-Automation.md` | Report template state | MEDIUM |
| 22 | `22-PoC-Development-Automation.md` | PoC generation queue | MEDIUM |

### Reconnaissance Support Automation
| # | File | State Category | Persistence Priority |
|---|------|---------------|---------------------|
| 23 | `23-Target-Scouting-Automation.md` | Target profile cache | MEDIUM |
| 24 | `24-Scope-Validation-Automation.md` | Scope verification state | HIGH |
| 25 | `25-Asset-Tracking-Automation.md` | Asset inventory delta | HIGH |
| 26 | `26-Change-Monitoring-Automation.md` | Change detection baseline | MEDIUM |
| 27 | `27-Notification-Alerting-Automation.md` | Alert queue and cooldowns | LOW |
| 28 | `28-Data-Collection-Automation.md` | Collection pipeline state | MEDIUM |
| 29 | `29-Result-Analysis-Automation.md` | Analysis aggregation state | MEDIUM |
| 30 | `30-Tool-Chaining-Automation.md` | Chain execution state | HIGH |

### Integration Automation
| # | File | State Category | Persistence Priority |
|---|------|---------------|---------------------|
| 31 | `31-Proxy-Integration-Automation.md` | Proxy session state | MEDIUM |
| 32 | `32-Browser-Automation-Workflows.md` | Browser session cookies | HIGH |
| 33 | `33-Headless-Browser-Scripting.md` | Script execution state | MEDIUM |
| 34 | `34-Regex-Pattern-Automation.md` | Pattern match database | LOW |
| 35 | `35-Response-Analysis-Automation.md` | Response fingerprint cache | LOW |
| 36 | `36-Header-Injection-Testing.md` | Header injection results | MEDIUM |
| 37 | `37-CORS-Testing-Automation.md` | CORS origin map | MEDIUM |
| 38 | `38-WebSocket-Testing-Automation.md` | WebSocket endpoint map | MEDIUM |
| 39 | `39-GraphQL-Testing-Automation.md` | GraphQL schema cache | MEDIUM |

### Infrastructure Automation
| # | File | State Category | Persistence Priority |
|---|------|---------------|---------------------|
| 40 | `40-Cloud-Service-Enumeration.md` | Cloud asset inventory | HIGH |
| 41 | `41-DNS-Data-Extraction-Automation.md` | DNS record cache | MEDIUM |
| 42 | `42-Email-Recon-Automation.md` | Email address database | MEDIUM |
| 43 | `43-Social-Media-OSINT-Automation.md` | Social profile cache | LOW |
| 44 | `44-Framework-Detection-Automation.md` | Framework fingerprint DB | MEDIUM |
| 45 | `45-Technology-Stack-Identification.md` | Tech stack profiles | MEDIUM |
| 46 | `46-Endpoint-Mapping-Automation.md` | Endpoint topology graph | HIGH |
| 47 | `47-Content-Discovery-Automation.md` | Content inventory | MEDIUM |
| 48 | `48-Version-Detection-Automation.md` | Version fingerprint cache | LOW |
| 49 | `49-Compliance-Checking-Automation.md` | Compliance check results | MEDIUM |
| 50 | `50-Workflow-Orchestration-Automation.md` | Master orchestration state | CRITICAL |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Interoperability)

JSON is the default serialization format for all persistence operations. It provides human readability, tool compatibility, and debuggability.

```json
{
  "schema_version": "2.1.0",
  "domain": "advanced-automation",
  "session_id": "sess_a1b2c3d4e5f6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "pipeline_state": {
    "pipeline_id": "pipe_subenum_001",
    "module": "01-Subdomain-Enumeration-Automation",
    "phase": "enumeration",
    "progress": {
      "total_targets": 5,
      "completed_targets": 3,
      "current_target": "example.com",
      "percent_complete": 60.0
    },
    "intermediate_results": {
      "subdomains_found": 347,
      "unique_ips": 89,
      "nameservers": ["ns1.example.com", "ns2.example.com"]
    }
  },
  "scan_results": {
    "scan_id": "scan_x9y8z7",
    "target": "example.com",
    "findings": [],
    "metadata": {
      "tool": "subfinder",
      "duration_ms": 12400,
      "requests_made": 3500
    }
  },
  "checksum": "sha256:a1b2c3d4e5f6..."
}
```

### 3.2 MessagePack (Hot Path — High-Throughput Scanning)

MessagePack is used for high-throughput scan result ingestion where JSON serialization overhead becomes a bottleneck. Commonly used in real-time port scanning, fuzzing, and concurrent vulnerability detection pipelines.

```python
import msgpack

# Serialization
state = {
    "scan_id": "scan_x9y8z7",
    "results": scan_results,
    "timestamp": time.time()
}
packed = msgpack.packb(state, use_bin_type=True)

# Deserialization
restored = msgpack.unpackb(packed, raw=False)
```

**When to use MessagePack:**
- Real-time port scan result streams (file 02)
- Concurrent fuzzing result ingestion (file 06)
- WebSocket test result aggregation (file 38)
- High-frequency change monitoring (file 26)

### 3.3 Protobuf (Cross-Session — Schema Evolution)

Protocol Buffers are used for long-term storage and cross-session state transfer where schema evolution and compact binary encoding are required.

```protobuf
syntax = "proto3";
package advanced_automation;

message PipelineState {
  string schema_version = 1;
  string domain = 2;
  string session_id = 3;
  int64 timestamp = 4;
  PipelineProgress progress = 5;
  repeated Finding findings = 6;
  map<string, string> metadata = 7;
}

message PipelineProgress {
  string pipeline_id = 1;
  string module = 2;
  string phase = 3;
  int32 total_targets = 4;
  int32 completed_targets = 5;
  string current_target = 6;
  float percent_complete = 7;
}

message Finding {
  string finding_id = 1;
  string severity = 2;
  string category = 3;
  string title = 4;
  string description = 5;
  map<string, string> evidence = 6;
  int64 discovered_at = 7;
}

message ScanResult {
  string scan_id = 1;
  string target = 2;
  string tool = 3;
  int64 started_at = 4;
  int64 completed_at = 5;
  repeated Finding findings = 6;
  map<string, string> metadata = 7;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem (Primary)

```
session-managements/
├── persistence/
│   └── advanced-automation.md          # This document
├── state/
│   └── advanced-automation/
│       ├── {session_id}/
│       │   ├── pipeline_state.json     # Current pipeline state
│       │   ├── scan_results.json       # Accumulated scan results
│       │   ├── checkpoint/             # Periodic checkpoints
│       │   │   ├── cp_001.msgpack
│       │   │   ├── cp_002.msgpack
│       │   │   └── cp_latest.msgpack
│       │   └── logs/
│       │       ├── execution.log
│       │       └── errors.log
│       └── shared/
│           ├── target_cache.json       # Cross-session target cache
│           ├── tool_registry.json      # Tool availability state
│           └── findings_index.json     # Aggregate findings index
```

### 4.2 SQLite WAL (Concurrent Access)

For concurrent pipeline execution, SQLite in WAL mode provides transactional consistency without locking contention.

```sql
CREATE TABLE pipeline_state (
    session_id TEXT NOT NULL,
    pipeline_id TEXT NOT NULL,
    module TEXT NOT NULL,
    phase TEXT NOT NULL,
    state_blob BLOB NOT NULL,
    updated_at INTEGER NOT NULL,
    checksum TEXT NOT NULL,
    PRIMARY KEY (session_id, pipeline_id)
) WITHOUT ROWID;

CREATE TABLE scan_results (
    scan_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    target TEXT NOT NULL,
    results_msgpack BLOB NOT NULL,
    created_at INTEGER NOT NULL,
    checksum TEXT NOT NULL
);

CREATE TABLE findings_index (
    finding_id TEXT PRIMARY KEY,
    scan_id TEXT NOT NULL,
    severity TEXT NOT NULL,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    discovered_at INTEGER NOT NULL
);

CREATE INDEX idx_findings_severity ON findings_index(severity);
CREATE INDEX idx_findings_category ON findings_index(category);
CREATE INDEX idx_scan_results_target ON scan_results(target);
```

### 4.3 Redis (Distributed — Optional)

For distributed scanning across multiple nodes, Redis provides shared state with pub/sub for pipeline coordination.

```
Keys:
  aa:pipeline:{session_id}:{pipeline_id}  → Hash (pipeline state)
  aa:results:{scan_id}                     → List (result chunks)
  aa:findings:{session_id}                 → Sorted Set (by severity score)
  aa:locks:{pipeline_id}                   → String (distributed lock)
  aa:checkpoints:{session_id}              → Stream (checkpoint log)
```

---

## 5. State Snapshot Schema

### 5.1 Full Pipeline State Snapshot

```json
{
  "snapshot_type": "full",
  "schema_version": "2.1.0",
  "domain": "advanced-automation",
  "session_id": "sess_a1b2c3d4e5f6",
  "snapshot_id": "snap_full_001",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "pipeline_registry": {
    "active_pipelines": ["pipe_001", "pipe_002"],
    "completed_pipelines": ["pipe_prev_001"],
    "failed_pipelines": []
  },
  "module_states": {
    "01-Subdomain-Enumeration-Automation": {
      "status": "completed",
      "last_checkpoint": "2026-06-26T11:55:00.000Z",
      "result_count": 347,
      "state_blob_ref": "blob_a1"
    },
    "02-Port-Scanning-Automation": {
      "status": "running",
      "last_checkpoint": "2026-06-26T11:59:30.000Z",
      "progress_percent": 45.2,
      "state_blob_ref": "blob_b2"
    },
    "12-SQL-Injection-Automation": {
      "status": "pending",
      "last_checkpoint": null,
      "result_count": 0
    }
  },
  "shared_state": {
    "target_cache": {
      "total_targets": 156,
      "cache_version": 3,
      "last_refresh": "2026-06-26T10:00:00.000Z"
    },
    "tool_availability": {
      "nmap": true,
      "nuclei": true,
      "subfinder": true,
      "ffuf": true,
      "sqlmap": true
    },
    "rate_limits": {
      "global_rps": 100,
      "per_target_rps": 10,
      "backoff_until": null
    }
  },
  "integrity": {
    "checksum": "sha256:...",
    "byte_size": 24576,
    "compression": "none",
    "encryption": "none"
  }
}
```

### 5.2 Incremental Delta Snapshot

```json
{
  "snapshot_type": "delta",
  "schema_version": "2.1.0",
  "session_id": "sess_a1b2c3d4e5f6",
  "snapshot_id": "snap_delta_003",
  "base_snapshot_id": "snap_full_001",
  "timestamp": "2026-06-26T12:05:00.000Z",
  "deltas": [
    {
      "module": "02-Port-Scanning-Automation",
      "field": "progress_percent",
      "old_value": 45.2,
      "new_value": 67.8
    },
    {
      "module": "02-Port-Scanning-Automation",
      "field": "state_blob_ref",
      "old_value": "blob_b2",
      "new_value": "blob_b3"
    }
  ],
  "new_findings": [
    {
      "finding_id": "f_001",
      "source_module": "13-XSS-Detection-Automation",
      "severity": "HIGH",
      "title": "Reflected XSS in search parameter"
    }
  ],
  "integrity": {
    "checksum": "sha256:...",
    "parent_checksum": "sha256:..."
  }
}
```

### 5.3 Scan Result Snapshot

```json
{
  "snapshot_type": "scan_result",
  "schema_version": "2.1.0",
  "scan_id": "scan_x9y8z7",
  "session_id": "sess_a1b2c3d4e5f6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "module_source": "12-SQL-Injection-Automation",
  "target": "https://example.com/api",
  "tool": "sqlmap",
  "tool_version": "1.7.12",
  "execution": {
    "started_at": "2026-06-26T11:50:00.000Z",
    "completed_at": "2026-06-26T12:00:00.000Z",
    "duration_ms": 600000,
    "exit_code": 0
  },
  "results": {
    "vulnerable": true,
    "injection_type": "time-based blind",
    "database": "MySQL",
    "injected_parameter": "id",
    "evidence": {
      "payload": "id=1 AND SLEEP(5)",
      "response_time_ms": 5023,
      "baseline_time_ms": 120
    },
    "extracted_data_sample": []
  },
  "artifacts": [
    {
      "type": "log",
      "path": "logs/sqlmap_scan_x9y8z7.log",
      "size_bytes": 45678
    }
  ]
}
```

---

## 6. Persistence Triggers

Persistence operations are triggered by specific events in the pipeline lifecycle:

| Trigger Event | Snapshot Type | Frequency | Priority |
|---------------|--------------|-----------|----------|
| Pipeline start | Full | Once per pipeline | HIGH |
| Phase transition | Delta | On each phase change | HIGH |
| Checkpoint timer | Full | Every 5 minutes | MEDIUM |
| Finding discovery | Scan result | Per finding | CRITICAL |
| Pipeline completion | Full | Once per pipeline | CRITICAL |
| Pipeline failure | Full | On error | CRITICAL |
| Tool execution complete | Scan result | Per tool run | MEDIUM |
| Target switch | Delta | Per target change | MEDIUM |
| Rate limit hit | Delta | Per rate limit event | LOW |
| Session end | Full | Once per session | CRITICAL |
| Memory threshold | Full | When memory > 512MB | HIGH |
| Crash recovery | Full | On restart after crash | CRITICAL |

### 6.1 Trigger Implementation

```python
class AutomationPersistenceManager:
    TRIGGER_THRESHOLDS = {
        "checkpoint_interval_sec": 300,
        "memory_limit_mb": 512,
        "findings_per_flush": 10,
        "delta_accumulation_limit": 50
    }

    def on_pipeline_start(self, pipeline_id, module):
        self.save_full_snapshot(pipeline_id, module, reason="pipeline_start")

    def on_phase_transition(self, pipeline_id, old_phase, new_phase):
        self.save_delta_snapshot(pipeline_id, {
            "field": "phase",
            "old_value": old_phase,
            "new_value": new_phase
        })

    def on_finding_discovered(self, finding):
        self.save_scan_result(finding)
        self.incremental_finding_count += 1
        if self.incremental_finding_count >= self.TRIGGER_THRESHOLDS["findings_per_flush"]:
            self.flush_findings_index()
            self.incremental_finding_count = 0

    def on_checkpoint_timer(self):
        self.save_full_snapshot(reason="periodic_checkpoint")

    def on_memory_threshold(self):
        self.flush_in_memory_state()
        self.save_full_snapshot(reason="memory_pressure")

    def on_error(self, pipeline_id, error):
        self.save_full_snapshot(pipeline_id, reason="error", error_context=error)
```

---

## 7. Restore Operations

### 7.1 Full Restore

Reconstructs the complete pipeline state from a full snapshot:

```python
def restore_full_pipeline(session_id, pipeline_id=None):
    snapshot = load_latest_full_snapshot(session_id, pipeline_id)
    validate_checksum(snapshot)
    
    # Restore pipeline registry
    state.pipeline_registry = snapshot["pipeline_registry"]
    
    # Restore each module state
    for module_name, module_state in snapshot["module_states"].items():
        state.module_states[module_name] = module_state
        if module_state.get("state_blob_ref"):
            blob = load_state_blob(module_state["state_blob_ref"])
            state.module_blobs[module_name] = deserialize(blob)
    
    # Restore shared state
    state.shared = snapshot["shared_state"]
    
    # Apply any pending deltas
    pending_deltas = load_pending_deltas(session_id, snapshot["snapshot_id"])
    for delta in pending_deltas:
        apply_delta(state, delta)
    
    return state
```

### 7.2 Incremental Restore

Applies deltas on top of the last known full snapshot:

```python
def restore_incremental(session_id, target_snapshot_id=None):
    base_snapshot = find_nearest_full_snapshot(session_id, target_snapshot_id)
    state = restore_full_from(base_snapshot)
    
    deltas = load_deltas_after(session_id, base_snapshot["snapshot_id"])
    for delta in deltas:
        apply_delta(state, delta)
    
    return state
```

### 7.3 Scan Result Restore

Reconstructs scan results from persisted scan result snapshots:

```python
def restore_scan_results(session_id, scan_id=None):
    if scan_id:
        return load_scan_result(session_id, scan_id)
    
    all_results = load_all_scan_results(session_id)
    return AggregateScanResults(
        total_scans=len(all_results),
        findings=[f for r in all_results for f in r.results],
        metadata=merge_metadata(all_results)
    )
```

### 7.4 Crash Recovery

```python
def crash_recovery(session_id):
    # Find last known good snapshot
    last_snapshot = find_latest_snapshot(session_id)
    
    # Check for incomplete pipelines
    incomplete = [
        p for p in last_snapshot["pipeline_registry"]["active_pipelines"]
        if not is_pipeline_complete(session_id, p)
    ]
    
    # Restore and mark incomplete pipelines for retry
    state = restore_full_from(last_snapshot)
    for pipeline_id in incomplete:
        state.mark_for_retry(pipeline_id, reason="crash_recovery")
    
    return state
```

---

## 8. Compression

### 8.1 Compression Strategy

| Data Type | Default Compression | Threshold | Algorithm |
|-----------|-------------------|-----------|-----------|
| Full snapshots | zlib level 6 | > 10KB | zlib |
| Delta snapshots | None | N/A | Raw JSON |
| Scan results (MessagePack) | LZ4 | > 50KB | LZ4 |
| Protobuf blobs | None | N/A | Raw binary |
| Checkpoint streams | zstd level 3 | > 100KB | Zstandard |
| Log files | gzip | Always | gzip |

### 8.2 Compression Implementation

```python
import zlib
import lz4.frame
import zstandard as zstd

class CompressionManager:
    def compress(self, data: bytes, algorithm: str, level: int = None) -> bytes:
        if algorithm == "zlib":
            return zlib.compress(data, level or 6)
        elif algorithm == "lz4":
            return lz4.frame.compress(data)
        elif algorithm == "zstd":
            ctx = zstd.ZstdCompressor(level=level or 3)
            return ctx.compress(data)
        elif algorithm == "gzip":
            return zlib.compress(data, level or 6)
        return data

    def decompress(self, data: bytes, algorithm: str) -> bytes:
        if algorithm == "zlib":
            return zlib.decompress(data)
        elif algorithm == "lz4":
            return lz4.frame.decompress(data)
        elif algorithm == "zstd":
            ctx = zstd.ZstdDecompressor()
            return ctx.decompress(data)
        elif algorithm == "gzip":
            return zlib.decompress(data)
        return data

    def choose_algorithm(self, data_size: int, data_type: str) -> str:
        if data_type == "scan_result_msgpack" and data_size > 50000:
            return "lz4"
        elif data_type == "checkpoint_stream" and data_size > 100000:
            return "zstd"
        elif data_type == "full_snapshot" and data_size > 10000:
            return "zlib"
        return "none"
```

---

## 9. Encryption

### 9.1 Encryption Requirements

Sensitive scan results and findings may contain vulnerability details that must be protected at rest.

| Data Classification | Encryption Required | Algorithm | Key Management |
|--------------------|--------------------|-----------|----|
| Pipeline state | Optional | AES-256-GCM | Session key |
| Scan results | Conditional | AES-256-GCM | Session key |
| Findings (CRITICAL/HIGH) | Required | AES-256-GCM | Per-finding key |
| Credentials/tokens | Required | AES-256-GCM | HSM-backed |
| Shared state cache | Optional | AES-256-CBC | Shared key |

### 9.2 Encryption Implementation

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

class PersistenceEncryption:
    def __init__(self, master_key: bytes):
        self.master_key = master_key

    def derive_session_key(self, session_id: str) -> bytes:
        return HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=f"aa-persistence-{session_id}".encode()
        ).derive(self.master_key)

    def encrypt_state(self, plaintext: bytes, session_id: str) -> dict:
        key = self.derive_session_key(session_id)
        nonce = os.urandom(12)
        aesgcm = AESGCM(key)
        ciphertext = aesgcm.encrypt(nonce, plaintext, None)
        return {
            "ciphertext": ciphertext.hex(),
            "nonce": nonce.hex(),
            "algorithm": "AES-256-GCM",
            "key_derivation": "HKDF-SHA256"
        }

    def decrypt_state(self, encrypted: dict, session_id: str) -> bytes:
        key = self.derive_session_key(session_id)
        nonce = bytes.fromhex(encrypted["nonce"])
        ciphertext = bytes.fromhex(encrypted["ciphertext"])
        aesgcm = AESGCM(key)
        return aesgcm.decrypt(nonce, ciphertext, None)
```

---

## 10. Cross-Session State Transfer

### 10.1 Session Boundary Protocol

When a session ends and a new session begins, state is transferred via a handoff manifest:

```json
{
  "handoff_type": "session_transfer",
  "source_session": "sess_a1b2c3d4e5f6",
  "target_session": "sess_g7h8i9j0k1l2",
  "timestamp": "2026-06-26T13:00:00.000Z",
  "domain": "advanced-automation",
  "transferred_state": {
    "pipeline_registry": "ref:snap_full_001",
    "findings_count": 47,
    "active_scans": 2,
    "shared_cache_version": 4
  },
  "integrity": {
    "source_checksum": "sha256:...",
    "transfer_checksum": "sha256:..."
  }
}
```

### 10.2 Compatibility Matrix

| Source Format | Target Format | Conversion | Loss |
|---------------|--------------|------------|------|
| JSON | JSON | Direct | None |
| JSON | MessagePack | Serialize | Comments stripped |
| JSON | Protobuf | Schema mapping | Extra fields dropped |
| MessagePack | JSON | Deserialize | Binary → base64 |
| Protobuf | JSON | Reflection | Field names lowercased |

---

## 11. Error Handling and Recovery

### 11.1 Persistence Failure Modes

| Failure Mode | Detection | Recovery Action |
|--------------|-----------|----------------|
| Disk full | Write error | Flush to alternate path, alert |
| Checksum mismatch | Validation error | Revert to previous checkpoint |
| Schema version mismatch | Parse error | Run migration pipeline |
| Corrupt blob | Decompression error | Skip blob, log warning |
| Stale snapshot | Timestamp check | Force full re-snapshot |
| Lock timeout | Acquisition failure | Exponential backoff retry |
| Encryption key mismatch | Decrypt error | Re-derive key, retry |

### 11.2 Integrity Verification

```python
class IntegrityChecker:
    def verify_snapshot(self, snapshot: dict) -> bool:
        stored_checksum = snapshot["integrity"]["checksum"]
        computed_checksum = self.compute_checksum(snapshot)
        
        if stored_checksum != computed_checksum:
            self.log_integrity_failure(snapshot["snapshot_id"], stored_checksum, computed_checksum)
            return False
        return True

    def verify_chain(self, session_id: str) -> bool:
        snapshots = load_snapshot_chain(session_id)
        prev_checksum = None
        
        for snap in snapshots:
            if not self.verify_snapshot(snap):
                return False
            if prev_checksum and snap.get("base_checksum") != prev_checksum:
                self.log_chain_break(snap["snapshot_id"])
                return False
            prev_checksum = snap["integrity"]["checksum"]
        
        return True
```

---

## 12. Performance Considerations

### 12.1 Write Performance Budget

| Operation | Max Latency | Batch Size | Async |
|-----------|------------|------------|-------|
| Delta snapshot | 50ms | Per event | No |
| Full snapshot | 200ms | Per trigger | Yes |
| Scan result flush | 100ms | 10 results | Yes |
| Checkpoint write | 500ms | Full state | Yes |
| Findings index update | 30ms | Per finding | No |
| Integrity check | 1000ms | Full snapshot | No |

### 12.2 Read Performance Budget

| Operation | Max Latency | Cache Strategy |
|-----------|------------|---------------|
| State lookup | 10ms | In-memory LRU |
| Findings query | 50ms | SQLite index |
| Full restore | 2000ms | Snapshot + deltas |
| Cross-session query | 500ms | Pre-computed index |

### 12.3 Storage Budget

| Data Category | Retention | Max Size Per Session |
|---------------|-----------|---------------------|
| Full snapshots | 7 days | 50MB |
| Delta snapshots | 7 days | 10MB |
| Scan results | 30 days | 100MB |
| Checkpoints | 7 days | 30MB |
| Logs | 14 days | 20MB |
| **Total per session** | — | **~210MB** |

---

## 13. Migration and Versioning

### 13.1 Schema Version Protocol

```
MAJOR.MINOR.PATCH

MAJOR: Breaking change — requires migration script
MINOR:  Backward-compatible addition
PATCH: Bug fix, no schema change
```

### 13.2 Migration Pipeline

```python
SCHEMA_MIGRATIONS = {
    "1.0.0 -> 1.1.0": "add_rate_limit_fields",
    "1.1.0 -> 2.0.0": "restructure_module_states",
    "2.0.0 -> 2.1.0": "add_integrity_chain_verification"
}

def migrate_snapshot(snapshot, target_version="2.1.0"):
    current_version = snapshot["schema_version"]
    
    while current_version != target_version:
        migration_key = f"{current_version} -> {next_version(target_version, current_version)}"
        migration_fn = SCHEMA_MIGRATIONS.get(migration_key)
        
        if not migration_fn:
            raise MigrationError(f"No migration path: {migration_key}")
        
        snapshot = globals()[migration_fn](snapshot)
        current_version = snapshot["schema_version"]
    
    return snapshot
```

---

## 14. Monitoring and Observability

### 14.1 Persistence Metrics

| Metric | Type | Alert Threshold |
|--------|------|----------------|
| `persistence_write_latency_ms` | Histogram | p99 > 500ms |
| `persistence_read_latency_ms` | Histogram | p99 > 1000ms |
| `persistence_error_rate` | Counter | > 1% per minute |
| `snapshot_size_bytes` | Gauge | > 100MB |
| `snapshot_chain_valid` | Gauge | 0 = alert |
| `compression_ratio` | Gauge | < 0.5 = investigate |
| `encryption_operations` | Counter | N/A (audit) |
| `restore_duration_ms` | Histogram | p99 > 5000ms |

### 14.2 Audit Trail

Every persistence operation is logged for audit:

```json
{
  "audit_event": "snapshot_created",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "session_id": "sess_a1b2c3d4e5f6",
  "snapshot_id": "snap_full_001",
  "snapshot_type": "full",
  "trigger": "periodic_checkpoint",
  "size_bytes": 24576,
  "compressed": true,
  "encrypted": false,
  "checksum": "sha256:...",
  "duration_ms": 145
}
```

---

## 15. Integration Points

### 15.1 Upstream Consumers

| Consumer | Protocol | Data Consumed |
|----------|----------|--------------|
| Session Manager | File read | Full snapshots |
| Pipeline Orchestrator | SQLite query | Pipeline state |
| Findings Aggregator | File read | Scan results |
| Reporting Module | File read | Findings index |
| Crash Recovery | File read | Checkpoints |

### 15.2 Downstream Producers

| Producer | Protocol | Data Produced |
|----------|----------|--------------|
| Scanning Pipelines | File write | Scan results |
| Checkpoint Timer | File write | Full snapshots |
| Delta Accumulator | File write | Delta snapshots |
| Findings Tracker | SQLite write | Finding records |

---

## 16. Testing Strategy

### 16.1 Persistence Unit Tests

| Test Case | Description | Expected |
|-----------|-------------|----------|
| `test_full_save_restore` | Save and restore full snapshot | State matches |
| `test_delta_apply` | Apply delta to base snapshot | Fields updated |
| `test_checksum_verify` | Tamper with snapshot, verify | Integrity failure |
| `test_schema_migration` | Restore v1.0 snapshot in v2.1 | Migration succeeds |
| `test_crash_recovery` | Kill mid-pipeline, recover | Incomplete pipelines found |
| `test_compression_roundtrip` | Compress/decompress cycle | Data matches |
| `test_encryption_roundtrip` | Encrypt/decrypt cycle | Plaintext matches |
| `test_concurrent_write` | Two pipelines write simultaneously | No data corruption |

---

## Appendix A: File Reference Complete Index

All 50 domain files referenced in this persistence layer:

1. `01-Subdomain-Enumeration-Automation.md` → Pipeline state, enumeration results, DNS cache
2. `02-Port-Scanning-Automation.md` → Scan progress, open port map, service banners
3. `03-Vulnerability-Scanning-Automation.md` → Vuln scan queue, results, severity distribution
4. `04-JavaScript-Analysis-Automation.md` → JS endpoints, deobfuscation state, URL patterns
5. `05-API-Endpoint-Discovery.md` → API catalog, method inventory, parameter map
6. `06-Parameter-Fuzzing-Automation.md` → Fuzzing queue, payload results, anomaly list
7. `07-Directory-Brute-Forcing.md` → Discovery progress, found paths, response codes
8. `09-Authentication-Testing-Automation.md` → Auth state machine, credential inventory
9. `10-Session-Management-Testing.md` → Session tokens, cookie inventory, fixation state
10. `11-IDOR-Detection-Automation.md` → IDOR parameter map, access control matrix
11. `12-SQL-Injection-Automation.md` → SQLi results, database fingerprints, payload map
12. `13-XSS-Detection-Automation.md` → Reflection points, context map, DOM sink inventory
13. `14-SSRF-Testing-Automation.md` → SSRF callbacks, internal endpoint map, protocol state
14. `15-CSRF-Testing-Automation.md` → CSRF tokens, state-changing endpoint map
15. `16-Command-Injection-Automation.md` → Command injection results, filter bypass state
16. `17-XXE-Testing-Automation.md` → XXE test outcomes, parser fingerprint map
17. `18-SSTI-Testing-Automation.md` → Template engine detection, payload effectiveness
18. `19-JWT-Testing-Automation.md` → JWT analysis, algorithm confusion state, key inventory
19. `20-Deserialization-Testing.md` → Deserialization vectors, gadget chain inventory
20. `21-Report-Generation-Automation.md` → Report templates, generation queue, output state
21. `22-PoC-Development-Automation.md` → PoC generation queue, template state
22. `23-Target-Scouting-Automation.md` → Target profiles, tech stack cache
23. `24-Scope-Validation-Automation.md` → Scope verification state, boundary map
24. `25-Asset-Tracking-Automation.md` → Asset inventory, delta tracking, ownership map
25. `26-Change-Monitoring-Automation.md` → Change detection baseline, diff state
26. `27-Notification-Alerting-Automation.md` → Alert queue, cooldown timers, delivery state
27. `28-Data-Collection-Automation.md` → Collection pipeline state, data lake references
28. `29-Result-Analysis-Automation.md` → Analysis aggregation, correlation state
29. `30-Tool-Chaining-Automation.md` → Chain execution state, tool dependency graph
30. `31-Proxy-Integration-Automation.md` → Proxy session state, request/response cache
31. `32-Browser-Automation-Workflows.md` → Browser cookies, page state, interaction log
32. `33-Headless-Browser-Scripting.md` → Script execution state, DOM snapshot queue
33. `34-Regex-Pattern-Automation.md` → Pattern match database, compiled regex cache
34. `35-Response-Analysis-Automation.md` → Response fingerprints, anomaly baseline
35. `36-Header-Injection-Testing.md` → Header injection results, filter state
36. `37-CORS-Testing-Automation.md` → CORS origin map, preflight analysis state
37. `38-WebSocket-Testing-Automation.md` → WebSocket endpoint map, message state
38. `39-GraphQL-Testing-Automation.md` → GraphQL schema cache, query analysis state
39. `40-Cloud-Service-Enumeration.md` → Cloud asset inventory, provider state
40. `41-DNS-Data-Extraction-Automation.md` → DNS record cache, zone transfer state
41. `42-Email-Recon-Automation.md` → Email database, verification state
42. `43-Social-Media-OSINT-Automation.md` → Social profile cache, platform state
43. `44-Framework-Detection-Automation.md` → Framework fingerprint database, detection state
44. `45-Technology-Stack-Identification.md` → Tech stack profiles, version state
45. `46-Endpoint-Mapping-Automation.md` → Endpoint topology graph, node state
46. `47-Content-Discovery-Automation.md` → Content inventory, discovery progress
47. `48-Version-Detection-Automation.md` → Version fingerprint cache, comparison state
48. `49-Compliance-Checking-Automation.md` → Compliance results, standard mapping
49. `50-Workflow-Orchestration-Automation.md` → Master orchestration state, dependency graph
50. `README.md` → Domain documentation index
51. `registry.json` → File metadata and index

---

## Appendix B: State Dependency Graph

```
50-Workflow-Orchestration-Automation (MASTER)
├── 01-Subdomain-Enumeration-Automation
├── 02-Port-Scanning-Automation
├── 03-Vulnerability-Scanning-Automation
├── 04-JavaScript-Analysis-Automation
├── 05-API-Endpoint-Discovery
├── 06-Parameter-Fuzzing-Automation
├── 07-Directory-Brute-Forcing
├── 09-Authentication-Testing-Automation
├── 10-Session-Management-Testing
├── 11-IDOR-Detection-Automation
├── 12-SQL-Injection-Automation
├── 13-XSS-Detection-Automation
├── 14-SSRF-Testing-Automation
├── 15-CSRF-Testing-Automation
├── 16-Command-Injection-Automation
├── 17-XXE-Testing-Automation
├── 18-SSTI-Testing-Automation
├── 19-JWT-Testing-Automation
├── 20-Deserialization-Testing
├── 21-Report-Generation-Automation
├── 22-PoC-Development-Automation
├── 23-Target-Scouting-Automation
├── 24-Scope-Validation-Automation
├── 25-Asset-Tracking-Automation
├── 26-Change-Monitoring-Automation
├── 27-Notification-Alerting-Automation
├── 28-Data-Collection-Automation
├── 29-Result-Analysis-Automation
├── 30-Tool-Chaining-Automation
├── 31-Proxy-Integration-Automation
├── 32-Browser-Automation-Workflows
├── 33-Headless-Browser-Scripting
├── 34-Regex-Pattern-Automation
├── 35-Response-Analysis-Automation
├── 36-Header-Injection-Testing
├── 37-CORS-Testing-Automation
├── 38-WebSocket-Testing-Automation
├── 39-GraphQL-Testing-Automation
├── 40-Cloud-Service-Enumeration
├── 41-DNS-Data-Extraction-Automation
├── 42-Email-Recon-Automation
├── 43-Social-Media-OSINT-Automation
├── 44-Framework-Detection-Automation
├── 45-Technology-Stack-Identification
├── 46-Endpoint-Mapping-Automation
├── 47-Content-Discovery-Automation
├── 48-Version-Detection-Automation
├── 49-Compliance-Checking-Automation
└── 30-Tool-Chaining-Automation (shared)
```
