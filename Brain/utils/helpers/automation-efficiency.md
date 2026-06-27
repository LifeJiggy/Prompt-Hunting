# Helpers: Automation-Efficiency

**Domain Mapping:** `Automation-Efficiency/`

## Overview

Helper functions for optimization — cache key generation, deduplication hashing, metric aggregation, and resource monitoring.

## CacheKeyGenerator

```python
class CacheKeyGenerator:
    @staticmethod
    def for_scan(tool, target, params=None):
        base = f"{tool}:{target}"
        if params:
            param_hash = hash_json(params)
            return f"{base}:{param_hash}"
        return base

    @staticmethod
    def for_finding(finding):
        return hash_json({
            "endpoint": finding["endpoint"],
            "type": finding["type"],
            "param": finding.get("param"),
            "payload": finding.get("payload")
        })
```

## DeduplicationEngine

```python
class DeduplicationEngine:
    def __init__(self):
        self.content_hashes = set()

    def is_new(self, content):
        h = hashlib.sha256(content.encode()).hexdigest()
        if h in self.content_hashes:
            return False
        self.content_hashes.add(h)
        return True

    def deduplicate_list(self, items):
        seen = set()
        unique = []
        for item in items:
            key = hash_json(item)
            if key not in seen:
                seen.add(key)
                unique.append(item)
        return unique
```

## ResourceMonitor

```python
class ResourceMonitor:
    def get_usage(self):
        return {
            "cpu_percent": psutil.cpu_percent(),
            "memory_percent": psutil.virtual_memory().percent,
            "disk_percent": psutil.disk_usage('/').percent
        }

    def is_overloaded(self, threshold=80):
        usage = self.get_usage()
        return any(v > threshold for v in usage.values())
```

## Domain File References

All 50 files in `Automation-Efficiency/` use cache keys, deduplication, and resource monitoring helpers.
