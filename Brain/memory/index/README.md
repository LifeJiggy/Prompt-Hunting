# Memory Indexing

**Component:** Memory Index and Retrieval

Provides fast lookup structures for memory entries across keyword, semantic, and temporal dimensions. Indexes are maintained incrementally and support composite queries that combine multiple search strategies.

---

## MemoryIndex Class

The `MemoryIndex` orchestrates all index types and provides a unified query interface.

```python
index = MemoryIndex(
    keyword_enabled=True,
    semantic_enabled=True,
    semantic_model="all-MiniLM-L6-v2",
    temporal_enabled=True
)
```

---

## Keyword Index

An inverted index mapping terms to entry IDs. Supports exact term matching, prefix search, and boolean queries.

### Structure

```
term → [(entry_id, frequency, field), ...]

"target.com" → [("ltm_001", 3, "key"), ("ltm_002", 1, "content")]
"xss"        → [("ltm_002", 2, "tags"), ("ltm_005", 1, "content")]
"subdomain"  → [("ltm_001", 5, "content")]
```

### Operations

```python
# Add entry to keyword index
index.keyword.add(entry_id, text="subdomains for target.com include api.target.com")

# Exact match
results = index.keyword.search("target.com")
# Returns: [("ltm_001", score=1.0), ("ltm_002", score=0.7)]

# Prefix search
results = index.keyword.search("target*", mode="prefix")

# Boolean query
results = index.keyword.search("target.com AND xss", mode="boolean")

# Remove entry from index
index.keyword.remove("ltm_001")
```

### Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `stemmer` | `"porter"` | Stemming algorithm: `porter`, `snowball`, `none` |
| `min_token_length` | `2` | Ignore tokens shorter than this |
| `stop_words` | `"english"` | Stop word list: `english`, `none`, custom list |
| `max_results` | `100` | Maximum results per query |

---

## Semantic Index

Stores vector embeddings of memory entries for similarity-based retrieval. Uses cosine similarity to find entries with related meaning, not just matching keywords.

### Structure

```
entry_id → embedding_vector[384]

"ltm_001" → [0.023, -0.156, 0.089, ..., 0.012]  # 384-dimensional
"ltm_002" → [0.045, -0.098, 0.234, ..., -0.034]
```

### Operations

```python
# Index an entry
embedding = index.semantic.embed("XSS vulnerability found in /search endpoint")
index.semantic.add("ltm_002", embedding)

# Similarity search
results = index.semantic.search("web application security flaw", top_k=10)
# Returns: [("ltm_002", similarity=0.89), ("ltm_007", similarity=0.82), ...]

# Find similar entries
similar = index.semantic.find_similar("ltm_002", top_k=5)

# Remove entry
index.semantic.remove("ltm_002")

# Rebuild embeddings (e.g., after model change)
index.semantic.rebuild(entries=all_entries, model="all-MiniLM-L6-v2")
```

### Model Options

| Model | Dimensions | Speed | Quality |
|-------|-----------|-------|---------|
| `all-MiniLM-L6-v2` | 384 | Fast | Good |
| `all-mpnet-base-v2` | 768 | Moderate | Better |
| `all-MiniLM-L12-v2` | 384 | Moderate | Good+ |

### Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `model` | `"all-MiniLM-L6-v2"` | Embedding model name |
| `batch_size` | `64` | Embedding batch size |
| `similarity_threshold` | `0.5` | Minimum similarity score |
| `use_gpu` | `False` | GPU acceleration for embedding |

---

## Temporal Index

Orders entries by creation time and supports range queries for "recent", "old", or time-window-based retrieval.

### Structure

```
sorted by timestamp → [entry_id, ...]

[("ltm_005", "2026-05-21T10:00:00Z"),
 ("ltm_002", "2026-05-21T10:05:00Z"),
 ("ltm_001", "2026-05-21T10:30:00Z"),
 ("ltm_003", "2026-05-21T11:00:00Z")]
```

### Operations

```python
# Add entry with timestamp
index.temporal.add("ltm_001", timestamp="2026-05-21T10:30:00Z")

# Get recent entries
recent = index.temporal.recent(hours=2)

# Get old entries
old = index.temporal.before("2026-05-20T00:00:00Z")

# Range query
entries = index.temporal.range(
    start="2026-05-21T00:00:00Z",
    end="2026-05-21T12:00:00Z"
)

# Remove entry
index.temporal.remove("ltm_001")
```

### Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `recent_window_hours` | `24` | Default window for `recent()` |
| `max_results` | `500` | Maximum results per query |

---

## Composite Queries

The unified query interface combines results from multiple index types with configurable weighting.

```python
# Multi-index query
results = index.query(
    query="xss vulnerability in target.com",
    filters={
        "tags": ["web"],
        "type": "findings",
        "after": "2026-05-01T00:00:00Z"
    },
    weights={
        "keyword": 0.4,
        "semantic": 0.4,
        "temporal": 0.2
    },
    top_k=10
)
# Returns ranked results combining keyword relevance, semantic similarity, and recency
```

### Query Processing

```
Query: "xss vulnerability in target.com"
         │
    ┌────┴────┬────────────┐
    ▼         ▼            ▼
 Keyword   Semantic    Temporal
 Index     Index       Index
    │         │            │
    ▼         ▼            ▼
 Results   Results     Results
 (ranked)  (ranked)    (ranked)
    │         │            │
    └────┬────┴────────────┘
         ▼
    Score Fusion
    (weighted combine)
         │
         ▼
    Filter & Rank
         │
         ▼
    Top-K Results
```

### Score Fusion

Results from each index are normalized to [0, 1] and combined using the configured weights. Ties are broken by entry priority, then by recency.

```python
final_score = (
    weights["keyword"] * keyword_score +
    weights["semantic"] * semantic_score +
    weights["temporal"] * temporal_score
)
```

---

## Index Rebuilding

Indexes can be fully rebuilt from stored entries. This is useful after model changes, configuration updates, or corruption recovery.

```python
# Full rebuild from long-term storage
index.rebuild(
    entries=longterm_memory.list_all(),
    reembed=True  # Regenerate semantic embeddings
)

# Incremental update (add missing entries only)
index.sync(longterm_memory.list_all())

# Validate index integrity
issues = index.validate()
# Returns list of issues: missing entries, orphaned IDs, stale timestamps

# Optimize index storage
index.optimize()
```

---

## Integration Points

| Component | Interaction |
|-----------|-------------|
| `working/` | Index entries on write, remove on clear |
| `longterm/` | Sync index on store/update/delete |
| `consolidation/` | Query indexes to evaluate entry importance |
| `tools/` | Query indexes during search operations |

---

*Part of the Brain memory subsystem.*
