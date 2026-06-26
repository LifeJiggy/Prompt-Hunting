# Brain Memory

**Component:** Memory Subsystem

Provides short-term working memory and long-term persistent storage for agent knowledge. Memory enables agents to learn from past interactions, maintain context across sessions, and build accumulating knowledge bases.

---

## Purpose

The memory subsystem solves a fundamental agent limitation: statelessness. Without memory, an agent forgets everything between interactions. Memory provides:

- **Working memory** — Fast, ephemeral storage for current task context
- **Persistent storage** — Long-term knowledge that survives across sessions
- **Knowledge indexing** — Efficient retrieval of relevant past information
- **Conversation buffers** — Chat history and context preservation
- **Knowledge graphs** — Relational connections between concepts
- **Memory consolidation** — Promoting important working memory to long-term storage

---

## Memory Architecture

```
┌─────────────────────────────────────────────┐
│                MEMORY SYSTEM                │
├─────────────┬──────────────┬────────────────┤
│   WORKING   │  PERSISTENT  │  KNOWLEDGE     │
│   MEMORY    │  STORAGE     │  GRAPH         │
│             │              │                │
│ Current     │ Historical   │ Relationships  │
│ context     │ data         │ between data   │
│ Session     │ File-backed  │ Semantic       │
│ scoped      │ permanent    │ connections    │
│ Ephemeral   │ Indexed      │ Queryable      │
│ Fast        │ Searchable   │ Traversable    │
└─────────────┴──────────────┴────────────────┘
```

---

## Working Memory

Short-term, high-speed storage for the current task:

### Characteristics
- **Capacity**: Configurable (default 10,000 tokens)
- **Lifetime**: Current session only
- **Speed**: In-memory, microsecond access
- **Scope**: Single agent or shared across agents

### Contents
| Entry Type | Purpose | Example |
|-----------|---------|---------|
| **Task context** | Current task details | Target domain, scope rules |
| **Intermediate results** | Partial findings | Discovered subdomains, live hosts |
| **Scratch space** | Temporary calculations | Wordlist processing state |
| **Conversation buffer** | Recent chat turns | Last 10 user messages |
| **Agent state** | Current agent mode | Scanning vs reporting |

### Working Memory Operations

```python
# Write to working memory
memory.working.write("subdomains", discovered_list)
memory.working.write("current_target", "target.com")

# Read from working memory
subdomains = memory.working.read("subdomains")

# Query working memory
results = memory.working.search("target.com related data")

# Clear working memory
memory.working.clear()
```

---

## Persistent Storage

Long-term, durable knowledge storage:

### Storage Layers

| Layer | Backend | Speed | Capacity | Use Case |
|-------|---------|-------|----------|----------|
| **Hot** | In-memory cache | Microseconds | Limited | Frequently accessed data |
| **Warm** | SQLite/JSON files | Milliseconds | Moderate | Recent findings, active targets |
| **Cold** | File system | Milliseconds | Unlimited | Archived results, historical data |

### Storage Schema

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
    created: "2025-01-15T10:30:00Z"
    updated: "2025-01-15T11:45:00Z"
    source: "nuclei_scan"
    ttl: 86400
  tags: ["xss", "web", "target.com"]
```

### Persistent Operations

```python
# Store findings
memory.persistent.write(
    key="target.com_findings",
    value=findings_data,
    tags=["xss", "web"]
)

# Retrieve by key
data = memory.persistent.read("target.com_findings")

# Search by tags
results = memory.persistent.search(tags=["xss"])

# List all entries
entries = memory.persistent.list(type="findings")

# Delete entry
memory.persistent.delete("old_scan_results")
```

---

## Knowledge Indexing

Efficient retrieval through structured indexing:

### Index Types

| Index | Structure | Query Type |
|-------|----------|------------|
| **Keyword** | Inverted index | Exact term matching |
| **Semantic** | Vector embeddings | Meaning-based similarity |
| **Temporal** | Time-sorted | Recent/old queries |
| **Relational** | Graph edges | Relationship traversal |
| **Hierarchical** | Tree structure | Category drill-down |

### Indexing Process

```
New Memory Entry
      │
      ▼
┌─────────────┐
│  EXTRACT    │ ← Pull keywords, entities, timestamps
│  FEATURES   │
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  UPDATE     │ ← Add to keyword, semantic, temporal indexes
│  INDEXES    │
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  PROPAGATE  │ ← Update knowledge graph edges
│  GRAPH      │
└─────────────┘
```

---

## Conversation Buffers

Maintaining chat context across interactions:

### Buffer Types

| Buffer | Scope | Capacity | Persistence |
|--------|-------|----------|-------------|
| **Session** | Current session | Configurable | Ephemeral |
| **Agent** | Per-agent lifetime | Configurable | Agent-scoped |
| **Global** | All sessions | Configurable | Persistent |

### Buffer Management

```python
# Add message to buffer
memory.conversation.add(
    role="user",
    content="Find XSS vulnerabilities in target.com"
)

# Get conversation context
context = memory.conversation.get_context(last_n=10)

# Summarize old messages to save space
memory.conversation.summarize(older_than=50)

# Export conversation
history = memory.conversation.export(format="markdown")
```

---

## Knowledge Graph

Relational connections between concepts:

### Graph Structure

```
    [target.com]
         │
    ┌────┴────┐
    │         │
[subdomains] [vulns]
    │         │
 ┌──┴──┐   ┌──┴──┐
 │     │   │     │
[api] [admin] [xss] [sqli]
         │         │
      [endpoint] [parameter]
```

### Graph Operations

```python
# Add node
memory.graph.add_node("target.com", type="domain")

# Add relationship
memory.graph.add_edge("target.com", "subdomains", relation="has")

# Traverse graph
related = memory.graph.traverse("target.com", depth=3)

# Find paths
path = memory.graph.find_path("target.com", "xss_vuln")

# Query by pattern
results = memory.graph.query(pattern="domain -> has -> vuln -> affects -> endpoint")
```

---

## Memory Consolidation

Promoting important working memory to long-term storage:

### Consolidation Rules

| Rule | Trigger | Action |
|------|---------|--------|
| **Importance** | Finding classified as High/Critical | Promote to persistent |
| **Frequency** | Data accessed >N times | Promote to persistent |
| **Recency** | Data accessed in last M minutes | Keep in working |
| **Relevance** | Data related to active task | Keep in working |
| **Staleness** | Data not accessed for >K hours | Archive or delete |

### Consolidation Process

```
Working Memory Entry
        │
        ▼
┌───────────────┐
│ SCORE ENTRY   │ ← Importance, frequency, relevance
└───────┬───────┘
        │
   Score > Threshold?
   ├── Yes → Promote to Persistent
   │         Update indexes
   │         Update knowledge graph
   └── No  → Keep in working memory
             Check for eviction on capacity
```

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | MemoryEntry, ReadQuery, WriteRequest types |
| `executions/` | Store execution logs, retrieve past results for decisions |
| `session-managements/` | Checkpoint memory state, restore on session resume |
| `tools/` | Tools write findings to memory, read past scan results |
| `runtime/` | Memory resource monitoring, storage health |
| `utils/` | Serialization, compression, encryption |

---

## Configuration

```yaml
memory:
  working:
    max_entries: 10000
    max_tokens: 50000
    eviction_policy: "lru"
  persistent:
    backend: "sqlite"
    storage_path: "./brain_memory.db"
    max_size_mb: 1000
    compression: true
    encryption: false
  indexing:
    keyword_index: true
    semantic_index: true
    semantic_model: "all-MiniLM-L6-v2"
    temporal_index: true
  consolidation:
    auto_consolidate: true
    importance_threshold: 0.7
    frequency_threshold: 3
    consolidation_interval: 300
  conversation:
    max_buffer_size: 100
    auto_summarize: true
    summary_threshold: 50
```

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
