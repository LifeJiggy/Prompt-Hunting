# State Persistence

> Serialization formats, storage backends, snapshots, and persistence triggers.

## Overview

State persistence ensures that session data survives process restarts, suspensions, and failures. The persistence layer handles serialization of complex session state into storable formats, manages storage backend lifecycles, and triggers saves at appropriate moments.

## Core Concepts

### SessionStore

The `SessionStore` is the persistence interface. It abstracts storage backends and serialization format selection.

```python
from session_managements import SessionStore

store = SessionStore(
    backend="filesystem",
    path="/data/sessions",
    format="json",
    compression="gzip"
)

# Save state
store.save(session_id, session_state)

# Load state
state = store.load(session_id)

# List stored sessions
sessions = store.list()
```

## Serialization Formats

### JSON

The default serialization format. Human-readable and widely supported.

**Advantages:**
- Debuggable: state files can be read and edited manually
- Universal support across all platforms and tools
- No external dependencies
- Safe for sensitive data (no code execution on deserialize)

**Disadvantages:**
- Larger file sizes than binary formats
- Slower serialization for large state trees
- Limited type fidelity (no datetime, bytes, or set types natively)

**Configuration:**
```python
store = SessionStore(format="json", indent=2, sort_keys=True)
```

### MessagePack

Binary serialization format. Compact and fast.

**Advantages:**
- 30-50% smaller than JSON for typical session state
- 2-5x faster serialization/deserialization
- Preserves binary data (bytes objects) without base64 encoding
- Streaming support for large state trees

**Disadvantages:**
- Not human-readable
- Requires `msgpack` library
- Binary format makes manual inspection difficult
- Version migration requires explicit handling

**Configuration:**
```python
store = SessionStore(format="msgpack", use_bin_type=True)
```

### Format Selection Guide

| Criterion | JSON | MessagePack |
|-----------|------|-------------|
| Debugging | Excellent | Poor |
| Performance | Baseline | 2-5x faster |
| File size | Baseline | 30-50% smaller |
| Dependencies | None | msgpack |
| Security | Safer | Requires trusted input |
| Streaming | Limited | Native |

## State Snapshots

Snapshots capture the complete state of a session at a point in time. They are the fundamental unit of persistence.

### Snapshot Contents

```json
{
  "snapshot_id": "snap_abc123",
  "session_id": "ses_xyz789",
  "version": 3,
  "created_at": "2026-06-26T10:30:00Z",
  "state": {
    "conversation_history": [...],
    "task_tree": {...},
    "active_task": "T5",
    "metadata": {...},
    "context_window": [...]
  },
  "checksum": "sha256:abcdef...",
  "dependencies": ["snap_abc122"]
}
```

### Snapshot Versioning

Each snapshot has a monotonically increasing version number. Version increments:

- After each message exchange
- After task state changes
- After metadata updates
- After explicit `snapshot()` calls

Versions enable incremental loading — resuming from an older snapshot and replaying newer changes.

### Snapshot Dependencies

Snapshots form a directed acyclic graph (DAG):

```
snap_001 → snap_002 → snap_003 → snap_004 (latest)
                ↘ snap_002b → snap_003b
```

Branches occur when concurrent writes are possible (rare). The dependency graph enables:
- Partial state recovery (load only needed snapshots)
- Deduplication of shared base state
- Efficient delta computation between versions

## Storage Backends

### Filesystem

Default backend. Stores snapshots as files on disk.

```python
store = SessionStore(
    backend="filesystem",
    path="/data/sessions",
    max_files_per_session=100
)
```

**Layout:**
```
/data/sessions/
  ses_xyz789/
    metadata.json
    snap_001.json
    snap_002.json
    snap_003.json
    latest.json → snap_003.json
```

**Advantages:** Simple, no external dependencies, direct file access.
**Disadvantages:** No concurrent access safety, no built-in replication.

### Database

SQL or document database backend. Suitable for multi-process deployments.

```python
store = SessionStore(
    backend="database",
    url="postgresql://host/db",
    table="session_snapshots"
)
```

**Advantages:** Concurrent access, querying, transactions, replication.
**Disadvantages:** External dependency, connection management, schema migration.

### Memory

In-memory backend. Ephemeral storage for testing and development.

```python
store = SessionStore(backend="memory")
```

**Advantages:** Fastest possible access. Zero persistence cost.
**Disadvantages:** Lost on process termination. No disk persistence.

### Cloud Object Storage

S3-compatible backend. For long-term archival and cross-region access.

```python
store = SessionStore(
    backend="s3",
    bucket="session-snapshots",
    prefix="prod/",
    region="us-east-1"
)
```

## Compression

Snapshots can be compressed to reduce storage costs and transfer times.

| Algorithm | Speed | Ratio | CPU Usage |
|-----------|-------|-------|-----------|
| none | Fastest | Baseline | Minimal |
| gzip | Fast | 3-5x | Low |
| lz4 | Very fast | 2-3x | Low |
| zstd | Fast | 5-7x | Medium |
| brotli | Slow | 6-8x | High |

**Recommendation:** Use `gzip` for general workloads, `lz4` for high-throughput scenarios, `zstd` for archival.

## Persistence Triggers

Persistence occurs at specific moments to balance data safety with performance:

### Automatic Triggers

| Trigger | Description |
|---------|-------------|
| Message exchange | After each user/assistant turn |
| Task transition | When tasks change state |
| Suspend | Before session enters suspended state |
| Close | Before session is terminated |
| Duration interval | Every N minutes (configurable) |
| Size threshold | When state exceeds N bytes since last save |
| Subagent completion | When a background subagent finishes |

### Manual Triggers

```python
# Force an immediate snapshot
store.snapshot(session_id)

# Save specific component
store.save_component(session_id, "conversation_history")

# Flush all pending writes
store.flush()
```

### Coalescing

To prevent excessive writes during rapid state changes, persistence uses coalescing:

- Write operations within a configurable window (default: 5s) are batched
- Only the final state in the window is persisted
- Coalescing is bypassed for critical triggers (suspend, close)

## Integrity Verification

### Checksums

Every snapshot includes a SHA-256 checksum of its serialized content.

**Verification process:**
1. Load serialized bytes from storage
2. Compute SHA-256 hash
3. Compare with stored checksum
4. Reject snapshot on mismatch

### Corruption Detection

| Signal | Action |
|--------|--------|
| Checksum mismatch | Reject snapshot, attempt load from previous version |
| Parse error | Reject snapshot, log corruption, attempt recovery |
| Missing snapshot | Skip in dependency chain, load next available |
| Truncated file | Reject snapshot, attempt partial recovery |

## Configuration Reference

| Parameter | Default | Description |
|-----------|---------|-------------|
| `format` | `json` | Serialization format |
| `backend` | `filesystem` | Storage backend |
| `compression` | `none` | Compression algorithm |
| `auto_save_interval` | 300s | Interval between auto-saves |
| `max_snapshot_size` | 50MB | Maximum single snapshot size |
| `retention_count` | 50 | Snapshots per session to retain |
| `checksum_enabled` | true | Enable integrity verification |
| `coalesce_window` | 5s | Write coalescing window |
