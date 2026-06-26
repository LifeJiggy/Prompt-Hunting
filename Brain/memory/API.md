# Memory API Reference

Complete API reference for all public methods across the Brain memory subsystem.

---

## WorkingMemory

Short-term, session-scoped memory with capacity limits and eviction.

### Constructor

```python
WorkingMemory(
    max_entries: int = 10000,
    max_tokens: int = 50000,
    eviction_policy: str = "lru"
)
```

### Methods

#### `write(key, value, priority=0.5, tags=None) -> str`

Write an entry to working memory.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `key` | `str` | required | Unique lookup key |
| `value` | `Any` | required | Content to store (must be serializable) |
| `priority` | `float` | `0.5` | Eviction priority (0.0-1.0) |
| `tags` | `list[str]` | `None` | Tags for filtering |

**Returns:** Entry ID (`str`)

```python
entry_id = memory.working.write("subdomains", ["api.t.com"], priority=0.8, tags=["recon"])
```

#### `write_many(entries) -> list[str]`

Bulk write multiple entries.

| Parameter | Type | Description |
|-----------|------|-------------|
| `entries` | `dict[str, Any]` | `{key: value}` mapping |

**Returns:** List of entry IDs

```python
ids = memory.working.write_many({"a": data1, "b": data2})
```

#### `read(key, default=None) -> Any`

Read an entry by key. Returns `default` if not found.

```python
data = memory.working.read("subdomains")
data = memory.working.read("missing", default=[])
```

#### `has(key) -> bool`

Check if a key exists.

```python
if memory.working.has("scan_results"):
    process(memory.working.read("scan_results"))
```

#### `search(query, tags=None, type=None, min_priority=0.0) -> list[dict]`

Search entries by keyword query with optional filters.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | `str` | required | Search query |
| `tags` | `list[str]` | `None` | Filter by tags (AND logic) |
| `type` | `str` | `None` | Filter by entry type |
| `min_priority` | `float` | `0.0` | Minimum priority threshold |

**Returns:** List of `{"key", "score", "content"}` dicts, sorted by relevance

```python
results = memory.working.search("xss target.com", tags=["recon"], min_priority=0.5)
```

#### `context_window(max_tokens=4096, include_metadata=False) -> list[dict]`

Get the current context window — entries that fit within a token budget, ordered by relevance.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_tokens` | `int` | `4096` | Token budget for the window |
| `include_metadata` | `bool` | `False` | Include entry metadata |

**Returns:** List of entries fitting the token budget

```python
window = memory.working.context_window(max_tokens=8192, include_metadata=True)
```

#### `clear(exclude_tags=None) -> int`

Remove all entries, optionally preserving entries with specified tags.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `exclude_tags` | `list[str]` | `None` | Tags to preserve |

**Returns:** Number of entries removed

```python
removed = memory.working.clear()
removed = memory.working.clear(exclude_tags=["pinned"])
```

#### `stats() -> dict`

Get capacity and utilization statistics.

**Returns:** `{"entry_count", "total_tokens", "max_entries", "max_tokens", "utilization"}`

```python
stats = memory.working.stats()
```

---

## LongTermMemory

Persistent, durable memory storage with multiple backends.

### Constructor

```python
LongTermMemory(
    backend: str = "sqlite",
    storage_path: str = "./brain_memory.db",
    max_size_mb: int = 1000,
    compression: bool = True,
    encryption: bool = False,
    encryption_key: str = None
)
```

### Methods

#### `store(key, content, type="generic", tags=None, ttl=None) -> str`

Store a new entry in long-term memory.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `key` | `str` | required | Unique lookup key |
| `content` | `Any` | required | Content to store |
| `type` | `str` | `"generic"` | Entry type classification |
| `tags` | `list[str]` | `None` | Tags for indexing |
| `ttl` | `int` | `None` | Time-to-live in seconds |

**Returns:** Entry ID (`str`)

```python
entry_id = memory.longterm.store(
    key="xss_findings",
    content={"vulns": [...]},
    type="findings",
    tags=["xss", "target.com"],
    ttl=86400
)
```

#### `retrieve(entry_id, include_metadata=True) -> dict | None`

Retrieve an entry by ID. Returns `None` if not found or expired.

```python
entry = memory.longterm.retrieve("ltm_f47ac10b")
entry = memory.longterm.retrieve("ltm_f47ac10b", include_metadata=False)
```

#### `get_by_key(key) -> dict | None`

Retrieve an entry by its lookup key.

```python
entry = memory.longterm.get_by_key("xss_findings")
```

#### `update(entry_id, content=None, tags=None, ttl=None) -> bool`

Full update of an entry. Only specified fields are changed.

| Parameter | Type | Description |
|-----------|------|-------------|
| `entry_id` | `str` | Entry to update |
| `content` | `Any` | New content (replaces existing) |
| `tags` | `list[str]` | New tags (replaces existing) |
| `ttl` | `int` | New TTL |

**Returns:** `True` if updated, `False` if not found

```python
memory.longterm.update("ltm_001", tags=["verified", "critical"])
```

#### `patch(entry_id, fields) -> bool`

Partial update — merges `fields` into existing entry.

```python
memory.longterm.patch("ltm_001", {"tags": ["xss", "verified"], "ttl": 604800})
```

#### `delete(entry_id) -> bool`

Delete an entry by ID.

```python
memory.longterm.delete("ltm_001")
```

#### `delete_by_key(key) -> bool`

Delete an entry by key.

```python
memory.longterm.delete_by_key("old_results")
```

#### `delete_by_type(type) -> int`

Delete all entries of a given type.

**Returns:** Number of entries deleted

```python
removed = memory.longterm.delete_by_type("temp_results")
```

#### `list_all(type=None, tags=None, limit=100) -> list[dict]`

List stored entries with optional filters.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `type` | `str` | `None` | Filter by type |
| `tags` | `list[str]` | `None` | Filter by tags (AND logic) |
| `limit` | `int` | `100` | Maximum entries returned |

**Returns:** List of entry summaries

```python
entries = memory.longterm.list_all(type="findings", tags=["xss"])
```

#### `search(query, filters=None, top_k=10) -> list[dict]`

Full-text search across all entries.

```python
results = memory.longterm.search("xss vulnerability", filters={"type": "findings"})
```

#### `purge_expired() -> int`

Remove all entries that have exceeded their TTL.

**Returns:** Number of entries purged

```python
purged = memory.longterm.purge_expired()
```

#### `compact() -> None`

Reclaim storage space from deleted entries (SQLite vacuum / file cleanup).

```python
memory.longterm.compact()
```

#### `validate() -> list[str]`

Check storage integrity.

**Returns:** List of issues found

```python
issues = memory.longterm.validate()
```

#### `backup(path) -> None`

Create a backup of the storage.

```python
memory.longterm.backup("./backups/backup_2026-05-21.db")
```

#### `restore(path) -> None`

Restore storage from a backup.

```python
memory.longterm.restore("./backups/backup_2026-05-21.db")
```

#### `stats() -> dict`

Get storage statistics.

**Returns:** `{"total_entries", "raw_size_bytes", "compressed_size_bytes", "compression_ratio", "storage_used_mb"}`

---

## MemoryIndex

Unified indexing and retrieval across keyword, semantic, and temporal dimensions.

### Constructor

```python
MemoryIndex(
    keyword_enabled: bool = True,
    semantic_enabled: bool = True,
    semantic_model: str = "all-MiniLM-L6-v2",
    temporal_enabled: bool = True
)
```

### Methods

#### `add(entry_id, text, timestamp=None, tags=None) -> None`

Add an entry to all enabled indexes.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `entry_id` | `str` | required | Entry to index |
| `text` | `str` | required | Text content for indexing |
| `timestamp` | `str` | `None` | ISO timestamp (defaults to now) |
| `tags` | `list[str]` | `None` | Tags for keyword index |

```python
index.add("ltm_001", text="XSS found in /search", timestamp="2026-05-21T10:00:00Z")
```

#### `remove(entry_id) -> None`

Remove an entry from all indexes.

```python
index.remove("ltm_001")
```

#### `query(query, filters=None, weights=None, top_k=10) -> list[dict]`

Unified multi-index query.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | `str` | required | Search query |
| `filters` | `dict` | `None` | `{"tags": [...], "type": "...", "after": "..."}` |
| `weights` | `dict` | `None` | `{"keyword": 0.4, "semantic": 0.4, "temporal": 0.2}` |
| `top_k` | `int` | `10` | Maximum results |

**Returns:** Ranked list of `{"entry_id", "score", "sources"}`

```python
results = index.query(
    "xss vulnerability",
    filters={"tags": ["web"], "after": "2026-05-01T00:00:00Z"},
    top_k=20
)
```

#### `search_keyword(query, mode="match", max_results=100) -> list[dict]`

Search the keyword index directly.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | `str` | required | Search term or boolean expression |
| `mode` | `str` | `"match"` | `match`, `prefix`, `boolean` |
| `max_results` | `int` | `100` | Maximum results |

#### `search_semantic(query, top_k=10, threshold=0.5) -> list[dict]`

Search the semantic index by meaning.

```python
results = index.search_semantic("web application security flaw", top_k=10)
```

#### `find_similar(entry_id, top_k=5) -> list[dict]`

Find entries similar to a given entry.

```python
similar = index.find_similar("ltm_001", top_k=5)
```

#### `recent(hours=24, limit=50) -> list[dict]`

Get entries from the last N hours.

```python
recent = index.recent(hours=12, limit=20)
```

#### `rebuild(entries, reembed=True) -> None`

Full rebuild of all indexes from provided entries.

```python
index.rebuild(entries=longterm.list_all(), reembed=True)
```

#### `sync(entries) -> int`

Incremental sync — add entries not yet indexed.

**Returns:** Number of entries added

```python
added = index.sync(longterm.list_all())
```

#### `validate() -> list[str]`

Check index integrity.

```python
issues = index.validate()
```

#### `optimize() -> None`

Rebuild and compact index storage.

```python
index.optimize()
```

---

## MemoryConsolidator

Scores, promotes, and prunes memory entries.

### Constructor

```python
MemoryConsolidator(
    working_memory: WorkingMemory,
    longterm_memory: LongTermMemory,
    index: MemoryIndex,
    importance_threshold: float = 0.7,
    frequency_threshold: int = 3,
    pruning_strategy: str = "staleness"
)
```

### Methods

#### `consolidate(importance_threshold=None, filter_keys=None) -> dict`

Run a consolidation cycle.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `importance_threshold` | `float` | `None` | Override default threshold |
| `filter_keys` | `list[str]` | `None` | Only process these keys |

**Returns:** `{"promoted", "pruned", "skipped", "errors", "duration_ms"}`

```python
result = consolidator.consolidate()
result = consolidator.consolidate(importance_threshold=0.5, filter_keys=["xss_results"])
```

#### `preview(dry_run=True) -> list[dict]`

Preview consolidation actions without executing.

```python
actions = consolidator.preview(dry_run=True)
# [{"key": "xss_findings", "score": 0.92, "action": "promote"}, ...]
```

#### `score_entry(entry) -> float`

Compute importance score for a single entry.

```python
score = consolidator.score_entry(entry)
```

#### `metrics() -> dict`

Get consolidation performance metrics.

```python
metrics = consolidator.metrics()
```

---

*Part of the Brain memory subsystem.*
