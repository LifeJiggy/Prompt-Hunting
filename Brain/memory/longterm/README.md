# Long-Term Memory

**Component:** Persistent Memory Storage

Durable, indexed storage for agent knowledge that persists across sessions. Long-term memory survives process restarts and enables agents to build accumulating expertise over time.

---

## LongTermMemory Class

```python
memory = LongTermMemory(
    backend="sqlite",
    storage_path="./brain_memory.db",
    max_size_mb=1000,
    compression=True,
    encryption=False
)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `backend` | `str` | `"sqlite"` | Storage backend: `sqlite`, `file` |
| `storage_path` | `str` | `"./brain_memory.db"` | Path to storage file |
| `max_size_mb` | `int` | `1000` | Maximum storage size in MB |
| `compression` | `bool` | `True` | Enable zlib compression for entries |
| `encryption` | `bool` | `False` | Enable AES-256 encryption at rest |

---

## Storage Backends

### SQLite Backend

The default backend. Provides ACID transactions, concurrent read access, and efficient querying via SQL.

```
brain_memory.db
├── entries          (main storage table)
├── tags             (tag index table)
├── metadata         (entry metadata table)
└── fts_entries      (full-text search virtual table)
```

**Advantages:** Transactional consistency, SQL-based queries, single-file storage, concurrent readers.

### File-Based Backend

Stores each entry as a separate JSON file in a directory tree organized by type and date.

```
memory_store/
├── findings/
│   ├── 2026-05-21/
│   │   ├── a1b2c3d4.json.gz
│   │   └── e5f6a7b8.json.gz
│   └── 2026-05-22/
│       └── ...
├── recon/
│   └── ...
└── index.json       (in-memory index, rebuilt on startup)
```

**Advantages:** Simple debugging, filesystem-level backup, no database dependency. **Tradeoff:** Slower queries, index rebuild required on startup.

---

## CRUD Operations

### Create

```python
# Store a new entry
entry_id = memory.store(
    key="xss_findings_target.com",
    content={
        "vulns": [
            {"type": "reflected_xss", "endpoint": "/search", "param": "q"},
            {"type": "stored_xss", "endpoint": "/comments", "param": "body"}
        ]
    },
    type="findings",
    tags=["xss", "target.com", "critical"],
    ttl=86400  # 24 hours
)
# Returns: "ltm_f47ac10b-58cc-4372-a567-0e02b2c3d479"
```

### Read

```python
# Retrieve by ID
entry = memory.retrieve("ltm_f47ac10b-58cc-4372-a567-0e02b2c3d479")

# Retrieve by key
entry = memory.get_by_key("xss_findings_target.com")

# Retrieve with metadata
entry = memory.retrieve(entry_id, include_metadata=True)
```

### Update

```python
# Full replace
memory.update(
    entry_id,
    content=updated_content,
    tags=["xss", "target.com", "critical", "verified"]
)

# Partial update (merge)
memory.patch(entry_id, fields={
    "tags": ["xss", "verified"],
    "metadata.priority": 0.95
})
```

### Delete

```python
# Delete by ID
memory.delete("ltm_f47ac10b-58cc-4372-a567-0e02b2c3d479")

# Delete by key
memory.delete_by_key("xss_findings_target.com")

# Bulk delete by type
memory.delete_by_type("temp_results")

# Delete expired entries (TTL-based)
purged = memory.purge_expired()
```

---

## TTL Support

Every entry can have a time-to-live. Expired entries are not returned by queries and are cleaned up during periodic maintenance.

```python
# Store with TTL (seconds)
memory.store(key="session_cache", value=data, ttl=3600)  # 1 hour

# Check expiry
entry = memory.retrieve("session_cache")
# Returns None if expired

# Manual purge
expired_count = memory.purge_expired()

# TTL tiers
# "ephemeral"  — 5 minutes (4200s)
# "short"      — 1 hour (3600s)
# "medium"     — 24 hours (86400s)
# "long"       — 7 days (604800s)
# "permanent"  — None (never expires)
```

---

## Compression

Entries are compressed using zlib before storage when `compression=True`. Compression ratio depends on content type — JSON text compresses well (~60-80% reduction), binary data less so.

```python
# Enable compression (default)
memory = LongTermMemory(compression=True)

# Stats include compression metrics
stats = memory.stats()
# {
#     "total_entries": 1247,
#     "raw_size_bytes": 15728640,
#     "compressed_size_bytes": 4718592,
#     "compression_ratio": 0.30,
#     "storage_used_mb": 4.5
# }
```

Compression is transparent — entries are decompressed automatically on retrieval. The compression method and level are stored in the entry header for forward compatibility.

---

## Encryption at Rest

When `encryption=True`, entries are encrypted using AES-256-GCM before writing to disk. The encryption key is derived from a master key using PBKDF2 with a per-entry salt.

```python
# Enable encryption
memory = LongTermMemory(
    encryption=True,
    encryption_key="master-key-from-env-or-vault"
)
```

**Security properties:**
- AES-256-GCM provides authenticated encryption (confidentiality + integrity)
- Per-entry salts prevent rainbow table attacks
- Key derivation uses PBKDF2-HMAC-SHA256 with 600,000 iterations
- Encryption key never stored on disk — must be provided at initialization

**Tradeoffs:**
- ~15-30% write overhead for encryption
- ~10-20% read overhead for decryption
- Indexes are stored in plaintext for query performance
- Entry keys and tags are unencrypted; content body is encrypted

---

## Storage Schema

```yaml
persistent_entry:
  id: "uuid"
  key: "target.com_findings"
  type: "findings"
  content:
    subdomains: ["api.target.com", "admin.target.com"]
    vulnerabilities:
      - type: "xss"
        endpoint: "/search"
        severity: "medium"
  metadata:
    created: "2026-05-21T10:30:00Z"
    updated: "2026-05-21T11:45:00Z"
    source: "nuclei_scan"
    ttl: 86400
    priority: 0.8
    compressed: true
    encrypted: false
  tags: ["xss", "web", "target.com"]
```

---

## Storage Layer Summary

| Layer | Backend | Speed | Capacity | Use Case |
|-------|---------|-------|----------|----------|
| **Hot** | In-memory cache | Microseconds | Limited | Frequently accessed data |
| **Warm** | SQLite/JSON files | Milliseconds | Moderate | Recent findings, active targets |
| **Cold** | File system | Milliseconds | Unlimited | Archived results, historical data |

---

## Maintenance

```python
# Get storage statistics
stats = memory.stats()

# Compact storage (reclaim space from deleted entries)
memory.compact()

# Validate integrity
issues = memory.validate()

# Backup
memory.backup("./backups/memory_backup_2026-05-21.db")

# Restore
memory.restore("./backups/memory_backup_2026-05-21.db")
```

---

## Integration Points

| Component | Interaction |
|-----------|-------------|
| `working/` | Receives promoted entries from consolidation |
| `index/` | Syncs entries to keyword/semantic/temporal indexes |
| `consolidation/` | Reads for archival, pruning, and deduplication |
| `session-managements/` | Persists session-critical state on checkpoint |

---

*Part of the Brain memory subsystem.*
