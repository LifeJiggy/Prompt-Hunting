# Working Memory

**Component:** Short-Term Working Memory

Fast, ephemeral storage for the current agent session. Working memory holds the active context window — the information immediately relevant to the task at hand. It is scoped to a single session and discarded on completion.

---

## WorkingMemory Class

The `WorkingMemory` class manages in-memory, session-scoped storage with capacity limits and automatic eviction. It serves as the agent's "scratchpad" during task execution.

### Construction

```python
memory = WorkingMemory(
    max_entries=10000,
    max_tokens=50000,
    eviction_policy="lru"
)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_entries` | `int` | `10000` | Maximum number of entries before eviction |
| `max_tokens` | `int` | `50000` | Maximum total token count across all entries |
| `eviction_policy` | `str` | `"lru"` | Eviction strategy: `lru`, `lfu`, `fifo`, `priority` |

---

## Capacity Management

Working memory enforces both entry count and token budget limits. When either limit is exceeded, the eviction policy determines which entries are removed.

### Token Counting

Each entry's token count is estimated using a configurable tokenizer. The system tracks cumulative token usage across all entries and rejects writes that would exceed `max_tokens` without first evicting lower-priority entries.

```python
# Current capacity usage
stats = memory.stats()
# {
#     "entry_count": 342,
#     "total_tokens": 18750,
#     "max_entries": 10000,
#     "max_tokens": 50000,
#     "utilization": 0.375
# }
```

### Eviction Policies

| Policy | Strategy | When to Use |
|--------|----------|-------------|
| `lru` | Least Recently Used | General-purpose default |
| `lfu` | Least Frequently Used | When access patterns are stable |
| `fifo` | First In, First Out | When recency is irrelevant |
| `priority` | Lowest priority first | When entries carry explicit priority weights |

When eviction triggers, the policy selects entries for removal until capacity drops below the high-water mark (80% of `max_entries` or `max_tokens`). Evicted entries are logged as events for debugging.

---

## Context Window Management

Working memory tracks the "active window" — the subset of entries currently relevant to the agent's focus. The context window is a sliding view over all entries, ordered by recency and relevance.

```python
# Get current context window
window = memory.context_window(
    max_tokens=4096,
    include_metadata=True
)
# Returns entries that fit within the token budget, ordered by relevance
```

The context window respects a secondary token budget (`max_tokens` parameter in the method) independent of the overall working memory capacity. This allows agents to request a smaller window than the full buffer for LLM prompts.

---

## Memory Entry Structure

Every working memory entry follows a standardized schema:

```python
entry = {
    "id": "wm_a1b2c3d4",           # Auto-generated unique ID
    "key": "discovered_subdomains",  # Human-readable lookup key
    "content": ["api.target.com", "admin.target.com"],
    "type": "list",                  # Content type hint
    "metadata": {
        "created": "2026-05-21T10:30:00Z",
        "accessed": "2026-05-21T10:32:15Z",
        "access_count": 3,
        "token_count": 45,
        "priority": 0.8,             # 0.0 (low) to 1.0 (critical)
        "source": "subfinder_scan"
    },
    "tags": ["subdomains", "recon"]
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | `str` | Unique identifier, auto-generated |
| `key` | `str` | Lookup key for read/write operations |
| `content` | `Any` | The stored data (serializable) |
| `type` | `str` | Type hint: `str`, `list`, `dict`, `result`, `context` |
| `metadata.created` | `datetime` | When the entry was written |
| `metadata.accessed` | `datetime` | Last access timestamp |
| `metadata.access_count` | `int` | Number of times read |
| `metadata.token_count` | `int` | Estimated tokens in content |
| `metadata.priority` | `float` | Eviction priority (higher = harder to evict) |
| `metadata.source` | `str` | Origin of the data (tool name, agent, etc.) |
| `tags` | `list[str]` | Arbitrary tags for filtering |

---

## Read / Write / Search Operations

### Write

```python
# Simple write
memory.write("current_target", "target.com")

# Write with metadata
memory.write(
    key="scan_results",
    value=results,
    priority=0.9,
    tags=["nuclei", "high-severity"]
)

# Bulk write
memory.write_many({
    "subdomains": subdomain_list,
    "live_hosts": live_hosts,
    "ports": open_ports
})
```

### Read

```python
# Read by key
target = memory.read("current_target")
# Returns None if not found

# Read with default
target = memory.read("current_target", default="unknown")

# Check existence
if memory.has("scan_results"):
    process(memory.read("scan_results"))
```

### Search

```python
# Keyword search across all entries
results = memory.search("xss vulnerability")

# Search with filters
results = memory.search(
    query="target.com",
    tags=["recon"],
    type="result",
    min_priority=0.5
)

# Returns list of matching entries, sorted by relevance score
# [
#     {"key": "subdomains", "score": 0.92, "content": [...]},
#     {"key": "live_hosts", "score": 0.78, "content": [...]}
# ]
```

---

## Lifecycle

1. **Creation** — `WorkingMemory()` initializes empty buffers
2. **Population** — Agents write entries during task execution
3. **Access** — Entries are read and searched during reasoning
4. **Eviction** — Capacity triggers remove low-value entries
5. **Consolidation** — Important entries are promoted to long-term storage
6. **Clear** — Session ends, all entries are discarded

```python
# Manual clear
memory.clear()

# Clear with preservation
memory.clear(exclude_tags=["pinned"])
```

---

## Integration Points

| Component | Interaction |
|-----------|-------------|
| `executions/` | Read context before each step, write results after |
| `session-managements/` | Snapshot working memory during checkpoints |
| `consolidation/` | Read entries for promotion scoring |
| `index/` | Sync entries to keyword and semantic indexes |

---

*Part of the Brain memory subsystem.*
