# Brain Utils

**Component:** Common Utility Functions and Helpers

Shared utility functions and helper classes used across the entire Brain domain. Utils provides the foundational building blocks that all other components rely on — logging, serialization, schema validation, timing, path handling, and data transformation.

---

## Purpose

Utils eliminates code duplication by providing common functionality in one place. Every Brain component uses utils for:

- **Structured logging** — Consistent, queryable log output
- **Data serialization** — Converting between formats (JSON, YAML, binary)
- **Schema validation** — Validating data against defined schemas
- **Timing utilities** — Measuring execution time and scheduling delays
- **Path handling** — Cross-platform file path operations
- **Data transformation** — Converting between data representations

---

## Component Map

```
┌─────────────────────────────────────────────┐
│                 UTILS                       │
├──────────┬──────────┬──────────┬────────────┤
│ LOGGING  │ SERIALIZE│ VALIDATE │  TIMING    │
│          │          │          │            │
│ Structured│ JSON     │ Schema   │ Stopwatch  │
│ Levels   │ YAML     │ Types    │ Scheduling │
│ Context  │ Binary   │ Custom   │ Retry      │
│ Output   │ Compress │ Error    │ Deadline   │
└──────────┴──────────┴──────────┴────────────┘
```

---

## Structured Logging

### Log Levels

| Level | Purpose | Output |
|-------|---------|--------|
| **DEBUG** | Detailed diagnostic info | Full variable states, trace info |
| **INFO** | Normal operation messages | Task start/end, findings discovered |
| **WARN** | Unexpected but handled | Rate limit approached, fallback used |
| **ERROR** | Operation failed | Tool failed, connection lost |
| **FATAL** | System cannot continue | Out of memory, disk full |

### Log Entry Format

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "executions"
  agent: "agent_scanner"
  session: "ses_abc123"
  message: "Nuclei scan completed"
  data:
    targets: 50
    findings: 3
    duration_s: 45.2
  context:
    plan_id: "plan_001"
    step_id: "step_3"
```

### Usage

```python
from brain.utils.logging import get_logger

logger = get_logger("executions")

# Basic logging
logger.info("Task started", task="nuclei_scan")

# Structured logging with context
logger.info(
    "Scan completed",
    targets=50,
    findings=3,
    duration_s=45.2
)

# Error logging with exception
try:
    run_scan()
except Exception as e:
    logger.error("Scan failed", error=str(e), exc_info=True)
```

### Log Output Destinations

| Destination | Format | Use Case |
|-------------|--------|----------|
| **Console** | Colored text | Development, debugging |
| **File** | JSON lines | Production logging |
| **Syslog** | Syslog format | System integration |
| **HTTP** | JSON POST | Centralized logging |
| **Custom** | User-defined | Special requirements |

---

## Data Serialization

### Supported Formats

| Format | Extension | Use Case | Strengths |
|--------|-----------|----------|-----------|
| **JSON** | `.json` | API data, configs | Human-readable, universal |
| **YAML** | `.yaml` | Configuration | Readable, supports comments |
| **MessagePack** | `.msgpack` | High-performance | Compact, fast |
| **Protobuf** | `.proto` | Structured data | Typed, efficient |
| **CSV** | `.csv` | Tabular data | Simple, spreadsheet-compatible |

### Serialization Operations

```python
from brain.utils.serialize import Serializer

# Serialize to JSON
data = {"findings": [...], "metadata": {...}}
json_str = Serializer.to_json(data, indent=2)

# Deserialize from JSON
data = Serializer.from_json(json_str)

# Serialize to YAML
yaml_str = Serializer.to_yaml(data)

# Serialize to binary (MessagePack)
binary = Serializer.to_msgpack(data)

# Auto-detect format
data = Serializer.auto_load("findings.json")
```

### Compression

```python
from brain.utils.serialize import compress, decompress

# Compress large data
compressed = compress(data, algorithm="gzip")

# Decompress
original = decompress(compressed, algorithm="gzip")
```

---

## Schema Validation

### Validation Types

| Type | Description | Example |
|------|-------------|---------|
| **Type** | Correct data type | String, integer, array |
| **Range** | Within bounds | 0-100, min_length=1 |
| **Pattern** | Matches regex | Email, URL, IP |
| **Enum** | Allowed values | ["low", "medium", "high"] |
| **Custom** | User-defined rules | Business logic validation |

### Validation Usage

```python
from brain.utils.validate import Schema, validate

# Define schema
target_schema = Schema({
    "domain": {"type": "string", "pattern": r"^[a-z0-9.-]+\.[a-z]{2,}$"},
    "ports": {"type": "array", "items": {"type": "integer", "min": 1, "max": 65535}},
    "severity": {"type": "string", "enum": ["low", "medium", "high", "critical"]}
})

# Validate data
result = validate(target_schema, {
    "domain": "target.com",
    "ports": [80, 443, 8080],
    "severity": "high"
})

if result.valid:
    print("Data is valid")
else:
    print("Validation errors:", result.errors)
```

### Custom Validators

```python
from brain.utils.validate import validator

@validator("target_list")
def validate_targets(value):
    """Ensure target list has no duplicates and valid formats."""
    seen = set()
    errors = []
    for target in value:
        if target in seen:
            errors.append(f"Duplicate target: {target}")
        if not re.match(r"^[a-z0-9.-]+\.[a-z]{2,}$", target):
            errors.append(f"Invalid domain: {target}")
        seen.add(target)
    return errors
```

---

## Timing Utilities

### Stopwatch

```python
from brain.utils.timing import Stopwatch

# Measure execution time
sw = Stopwatch()
sw.start()

result = run_scan()

sw.stop()
print(f"Scan took {sw.elapsed_s:.1f} seconds")
print(f"Started at {sw.started_at}")
print(f"Ended at {sw.ended_at}")
```

### Retry with Backoff

```python
from brain.utils.timing import retry

# Retry with exponential backoff
@retry(max_attempts=3, backoff="exponential", base_delay=1.0)
def call_api(url):
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    return response.json()

# Retry with custom condition
@retry(max_attempts=5, retry_on=ValueError)
def parse_data(raw):
    return json.loads(raw)
```

### Scheduling

```python
from brain.utils.timing import scheduler

# Schedule a task
scheduler.schedule(
    task=cleanup_old_sessions,
    interval=3600,  # Every hour
    name="session_cleanup"
)

# Schedule one-time task
scheduler.schedule_once(
    task=send_report,
    delay=300,  # 5 minutes from now
    name="delayed_report"
)

# Cancel scheduled task
scheduler.cancel("session_cleanup")
```

### Deadline

```python
from brain.utils.timing import Deadline

# Set a deadline for an operation
deadline = Deadline(timeout_s=300)

while not deadline.expired:
    result = process_batch()
    if result.complete:
        break
    remaining = deadline.remaining_s
    print(f"{remaining:.1f}s remaining")

if deadline.expired:
    print("Operation timed out")
```

---

## Path Handling

### Cross-Platform Paths

```python
from brain.utils.paths import Path

# Create paths cross-platform
config_path = Path("brain", "config", "settings.yaml")
print(config_path)  # "brain/config/settings.yaml" (Linux)
                    # "brain\config\settings.yaml" (Windows)

# Resolve relative to project root
workspace = Path.workspace()
log_dir = workspace / "logs" / "2025"
log_dir.mkdir(parents=True, exist_ok=True)

# Find project root
root = Path.find_root()
print(root)  # "/home/user/Prompt-Hunting"
```

### Path Operations

```python
from brain.utils.paths import ensure_dir, safe_filename, temp_path

# Ensure directory exists
ensure_dir("/workspace/output/scans")

# Create safe filename from string
name = safe_filename("target.com:8080/api/v1")
print(name)  # "target.com_8080_api_v1"

# Create temporary path
tmp = temp_path(prefix="scan_", suffix=".json")
print(tmp)  # "/tmp/scan_abc123.json"
```

---

## Data Transformation

### Common Transformers

| Transformer | Input | Output |
|------------|-------|--------|
| **flatten** | Nested dict | Flat dict with dot notation |
| **unflatten** | Flat dict | Nested dict |
| **deduplicate** | List | Unique list |
| **chunk** | Large list | List of smaller lists |
| **merge** | Multiple dicts | Single merged dict |
| **diff** | Two objects | Changes between them |

### Usage

```python
from brain.utils.data import flatten, chunk, merge, diff

# Flatten nested dict
nested = {"a": {"b": {"c": 1}}}
flat = flatten(nested)
print(flat)  # {"a.b.c": 1}

# Chunk large list
targets = list(range(100))
batches = chunk(targets, size=10)
print(len(batches))  # 10 batches of 10

# Merge configs (right overrides left)
base = {"timeout": 30, "retries": 2}
override = {"timeout": 60}
merged = merge(base, override)
print(merged)  # {"timeout": 60, "retries": 2}

# Diff two states
old = {"a": 1, "b": 2}
new = {"a": 1, "b": 3, "c": 4}
changes = diff(old, new)
print(changes)  # {"b": {"old": 2, "new": 3}, "c": {"new": 4}}
```

---

## Integration Points

| Connected Component | Uses Utils For |
|--------------------|----------------|
| `core/` | Logging, validation, serialization |
| `executions/` | Timing, retry, logging, data transformation |
| `memory/` | Serialization, compression, path handling |
| `runtime/` | Logging, metrics formatting, timing |
| `session-managements/` | Serialization, compression, path handling |
| `tools/` | Validation, logging, serialization |

---

## Configuration

```yaml
utils:
  logging:
    level: "INFO"
    format: "json"
    output: "file"
    file_path: "./logs/brain.log"
    max_size_mb: 100
    backup_count: 5
  serialization:
    default_format: "json"
    compression: "gzip"
    indent: 2
  validation:
    strict_mode: true
    error_on_unknown: false
  timing:
    default_timeout: 30
    retry_base_delay: 1.0
    retry_max_delay: 60.0
  paths:
    workspace: "."
    temp_dir: "/tmp/brain"
    log_dir: "./logs"
```

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
