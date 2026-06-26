# Common Helper Functions

## Overview

The `utils/helpers` module provides cross-platform utilities for path resolution, hashing, timing, data transformation, and string manipulation. Each helper is stateless and independently importable.

## PathResolver

Cross-platform path handling that works on Windows, Linux, and macOS:

```python
from Brain.utils.helpers import PathResolver

resolver = PathResolver(base="/app/data")

# Resolve relative to base
resolver.resolve("config/settings.json")
# Linux:   /app/data/config/settings.json
# Windows: C:\app\data\config\settings.json

# Normalize mixed separators
resolver.normalize("config\\subdir/../file.txt")
# → "config/file.txt"

# Ensure directory exists
resolver.ensure_dir("output/reports/2026")
# Creates nested dirs if needed, returns Path object
```

### Key Methods

```python
resolver.expand("~/.config/app")        # Expands ~ to home directory
resolver.relative_to("/app/data/logs")  # "logs"
resolver.sibling("other_file.txt")      # /app/data/other_file.txt
resolver.with_suffix(".json")           # Replace file extension
resolver.parent(n=2)                    # Go up N levels
```

### Platform Detection

```python
resolver.is_windows    # True on Windows
resolver.is_linux      # True on Linux
resolver.is_macos      # True on macOS
resolver.sep           # "/" or "\\" depending on platform
```

## HashGenerator

Deterministic hashing for content addressing, caching, and deduplication:

```python
from Brain.utils.helpers import HashGenerator

hg = HashGenerator()

# SHA-256 of string
hash = hg.sha256("Hello, world!")
# "315f5bdb76d078c43b8ac0064e4a0164612b1fce77c869345bfc94c75894edd3"

# Hash a file (streaming, memory-efficient)
file_hash = hg.sha256_file("/path/to/large.bin")

# MD5 (when speed matters over security)
hash = hg.md5("quick checksum")

# HMAC for authenticated hashing
signed = hg.hmac_sha256("secret_key", "message to sign")
```

### Batch Operations

```python
# Hash multiple files
hashes = hg.sha256_files([
    "file1.txt",
    "file2.txt",
    "file3.txt"
])
# Returns dict: {"file1.txt": "abc...", "file2.txt": "def...", ...}

# Content-addressed storage key
key = hg.content_key(b"file contents")
# Deterministic: same bytes → same key always
```

### Algorithm Selection

| Method | Use Case |
|--------|----------|
| `sha256()` | General purpose, security-sensitive |
| `md5()` | Checksums, non-security dedup |
| `hmac_sha256()` | Authenticated hashing, signatures |
| `xxhash()` | High-speed hashing for large datasets |

## Timer

Stopwatch, retry logic, and deadline enforcement:

```python
from Brain.utils.helpers import Timer

# Basic stopwatch
timer = Timer("db.query")
timer.start()
results = db.execute(query)
elapsed = timer.stop()
# Returns timedelta, also logs if logger attached

# Context manager
with Timer("api.call") as t:
    response = http.get(url)
print(t.elapsed_ms)  # 142.3
```

### Retry

```python
from Brain.utils.helpers import Retry

retry = Retry(
    max_attempts=3,
    backoff="exponential",     # "linear" | "exponential" | "fixed"
    base_delay=0.5,            # Seconds
    max_delay=10.0,
    retry_on=(ConnectionError, TimeoutError),
    on_retry=lambda attempt, err: print(f"Retry {attempt}: {err}")
)

@retry
def fetch_data(url):
    return http.get(url)

result = fetch_data("https://api.example.com/data")
# Retries up to 3 times on connection/timeout errors
```

### Deadline

```python
from Brain.utils.helpers import Deadline

# Fail if operation takes too long
deadline = Deadline(timeout=30.0)  # 30 seconds

while processing:
    if deadline.expired:
        raise TimeoutError("Processing deadline exceeded")
    process_next_batch()

# Or as context manager
with Deadline(timeout=5.0):
    quick_operation()
# Raises TimeoutError if exceeded
```

## DataTransformers

Utilities for reshaping collections:

```python
from Brain.utils.helpers import DataTransformers

dt = DataTransformers()

# Flatten nested dict
nested = {"a": {"b": 1, "c": {"d": 2}}, "e": 3}
flat = dt.flatten(nested)
# {"a.b": 1, "a.c.d": 2, "e": 3}

# Unflatten back
dt.unflatten(flat)  # ≈ original (key order may differ)
```

### Chunking

```python
# Split list into fixed-size chunks
items = list(range(10))
chunks = dt.chunk(items, size=3)
# [[0,1,2], [3,4,5], [6,7,8], [9]]

# Chunk by key function
records = [
    {"type": "a", "val": 1},
    {"type": "b", "val": 2},
    {"type": "a", "val": 3},
    {"type": "b", "val": 4}
]
grouped = dt.group_by(records, key=lambda r: r["type"])
# {"a": [{"type":"a","val":1}, {"type":"a","val":3}],
#  "b": [{"type":"b","val":2}, {"type":"b","val":4}]}
```

### Merge & Diff

```python
# Deep merge dicts (right overrides left)
base = {"a": 1, "b": {"c": 2, "d": 3}}
override = {"b": {"c": 99}, "e": 5}
merged = dt.merge(base, override)
# {"a": 1, "b": {"c": 99, "d": 3}, "e": 5}

# Diff two dicts
diff = dt.diff(base, override)
# {"b.c": {"old": 2, "new": 99}, "e": {"old": MISSING, "new": 5}}
```

### Other Transformers

```python
dt.compact(nested)          # Remove None/empty values from nested dict
dt.pick(data, ["a", "c"])   # Extract subset of keys
dt.omit(data, ["b"])         # Remove specified keys
dt.invert({"a": 1, "b": 2}) # {1: "a", 2: "b"}
dt.zip_lists([1,2,3], ["a","b","c"])  # [(1,"a"), (2,"b"), (3,"c")]
```

## StringHelpers

Common string operations for data normalization and display:

```python
from Brain.utils.helpers import StringHelpers

sh = StringHelpers()

# Slugify
sh.slugify("Hello World!")              # "hello-world"
sh.slugify("Über Cool", locale="de")    # "uber-cool"
sh.slugify("Already-Slug")              # "already-slug" (no double dashes)

# Truncate
sh.truncate("This is a long string", max_length=15)
# "This is a lo..."
sh.truncate("Short", max_length=50)
# "Short" (no truncation needed)
sh.truncate("Almost ten", max_length=10, suffix="…")
# "Almost te…"
```

### Template Rendering

```python
# Simple variable substitution
sh.template("Hello {name}, you have {count} messages", name="Alice", count=5)
# "Hello Alice, you have 5 messages"

# With defaults
sh.template("Value: {key}", key=None, defaults={"key": "N/A"})
# "Value: N/A"

# Conditional sections
sh.template(
    "{#if admin}Admin panel{#endif}{#if user}User panel{#endif}",
    admin=True, user=False
)
# "Admin panel"
```

### Other String Utilities

```python
sh.wrap("Long text here", width=40)      # Word-wrapped string
sh.clean("  extra   spaces  ")           # "extra spaces"
sh.starts_with("Hello World", "Hello")   # True (case-insensitive option)
sh.contains("Hello World", "world", case_insensitive=True)  # True
sh.pluralize("item", count=3)            # "items"
sh.pluralize("item", count=1)            # "item"
sh.roman_encode(42)                      # "XLII"
sh.roman_decode("XLII")                  # 42
```
