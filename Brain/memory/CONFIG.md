# Memory Configuration Reference

All configuration options for the Brain memory subsystem.

---

## Configuration File

Memory configuration lives under the `memory` key in `brain.config.yaml`:

```yaml
memory:
  working:
    # ... working memory options
  persistent:
    # ... persistent storage options
  indexing:
    # ... index options
  consolidation:
    # ... consolidation options
```

---

## Working Memory

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `working.max_entries` | `int` | `10000` | Maximum entries before eviction triggers |
| `working.max_tokens` | `int` | `50000` | Maximum total token count across all entries |
| `working.eviction_policy` | `str` | `"lru"` | Eviction strategy: `lru`, `lfu`, `fifo`, `priority` |
| `working.eviction_threshold` | `float` | `0.8` | Eviction triggers at this utilization ratio |
| `working.tokenizer` | `str` | `"simple"` | Token counter: `simple`, `tiktoken`, `whitespace` |
| `working.default_priority` | `float` | `0.5` | Default priority for entries without explicit priority |

---

## Persistent Storage

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `persistent.backend` | `str` | `"sqlite"` | Storage backend: `sqlite`, `file` |
| `persistent.storage_path` | `str` | `"./brain_memory.db"` | Path to storage file or directory |
| `persistent.max_size_mb` | `int` | `1000` | Maximum storage size in megabytes |
| `persistent.compression` | `bool` | `True` | Enable zlib compression for entry content |
| `persistent.compression_level` | `int` | `6` | Zlib compression level (1-9) |
| `persistent.encryption` | `bool` | `False` | Enable AES-256-GCM encryption at rest |
| `persistent.encryption_key` | `str` | `""` | Encryption master key (or env var reference) |
| `persistent.wal_mode` | `bool` | `True` | Enable SQLite WAL mode for concurrent reads |
| `persistent.cache_size` | `int` | `2000` | SQLite page cache size (pages) |

### TTL Defaults

| Tier | Seconds | Description |
|------|---------|-------------|
| `ephemeral` | `300` | 5 minutes |
| `short` | `3600` | 1 hour |
| `medium` | `86400` | 24 hours |
| `long` | `604800` | 7 days |
| `permanent` | `null` | Never expires |

---

## Indexing

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `indexing.keyword_enabled` | `bool` | `True` | Enable keyword inverted index |
| `indexing.stemmer` | `str` | `"porter"` | Stemming algorithm: `porter`, `snowball`, `none` |
| `indexing.min_token_length` | `int` | `2` | Ignore tokens shorter than this |
| `indexing.stop_words` | `str/list` | `"english"` | Stop word list |
| `indexing.semantic_enabled` | `bool` | `True` | Enable vector embedding index |
| `indexing.semantic_model` | `str` | `"all-MiniLM-L6-v2"` | Embedding model name |
| `indexing.semantic_dimensions` | `int` | `384` | Embedding vector dimensions |
| `indexing.batch_size` | `int` | `64` | Embedding batch processing size |
| `indexing.similarity_threshold` | `float` | `0.5` | Minimum cosine similarity for results |
| `indexing.use_gpu` | `bool` | `False` | GPU acceleration for embeddings |
| `indexing.temporal_enabled` | `bool` | `True` | Enable time-based index |
| `indexing.recent_window_hours` | `int` | `24` | Default window for `recent()` queries |
| `indexing.rebuild_on_start` | `bool` | `False` | Rebuild all indexes on startup |

---

## Consolidation

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `consolidation.auto_consolidate` | `bool` | `True` | Enable automatic periodic consolidation |
| `consolidation.consolidation_interval` | `int` | `300` | Seconds between consolidation cycles |
| `consolidation.importance_threshold` | `float` | `0.7` | Minimum score for promotion to long-term |
| `consolidation.frequency_threshold` | `int` | `3` | Minimum access count for promotion |
| `consolidation.pruning_strategy` | `str` | `"staleness"` | Pruning method: `staleness`, `random`, `score` |
| `consolidation.max_promotions_per_cycle` | `int` | `50` | Cap on entries promoted per cycle |
| `consolidation.dry_run` | `bool` | `False` | Preview mode — no changes applied |

### Importance Weights

| Factor | Weight Key | Default | Description |
|--------|-----------|---------|-------------|
| Access frequency | `w_access_frequency` | `0.25` | How often the entry has been read |
| Recency | `w_recency` | `0.20` | Time since last access |
| Priority | `w_priority` | `0.30` | Explicit priority set by agent |
| Type relevance | `w_type` | `0.15` | Entry type importance score |
| Source credibility | `w_source` | `0.10` | Reliability of entry source |

### Query Weights

| Index | Weight Key | Default | Description |
|-------|-----------|---------|-------------|
| Keyword | `w_keyword` | `0.4` | Weight for keyword match score |
| Semantic | `w_semantic` | `0.4` | Weight for semantic similarity score |
| Temporal | `w_temporal` | `0.2` | Weight for recency score |

---

## Environment Variables

| Variable | Maps To | Description |
|----------|---------|-------------|
| `BRAIN_MEMORY_DIR` | `persistent.storage_path` | Directory for persistent storage |
| `BRAIN_MEMORY_ENCRYPTION_KEY` | `persistent.encryption_key` | Encryption master key |
| `BRAIN_MEMORY_LOG_LEVEL` | — | Logging verbosity for memory operations |

---

## Example Configuration

```yaml
memory:
  working:
    max_entries: 10000
    max_tokens: 50000
    eviction_policy: "lru"
    eviction_threshold: 0.8
    tokenizer: "tiktoken"
    default_priority: 0.5

  persistent:
    backend: "sqlite"
    storage_path: "./brain_memory.db"
    max_size_mb: 1000
    compression: true
    compression_level: 6
    encryption: false
    wal_mode: true

  indexing:
    keyword_enabled: true
    semantic_enabled: true
    semantic_model: "all-MiniLM-L6-v2"
    temporal_enabled: true
    similarity_threshold: 0.5
    rebuild_on_start: false

  consolidation:
    auto_consolidate: true
    consolidation_interval: 300
    importance_threshold: 0.7
    frequency_threshold: 3
    pruning_strategy: "staleness"
    max_promotions_per_cycle: 50
```

---

*Part of the Brain memory subsystem.*
