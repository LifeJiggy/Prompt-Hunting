# Helpers: Advanced-Automation

**Domain Mapping:** `Advanced-Automation/`

## Overview

Common utility functions for automated scanning — path resolution for scan outputs, hash generation for deduplication, timing for pipeline measurements, and data transformation for result aggregation.

## PathResolver

```python
class AutomationPathResolver:
    def __init__(self, workspace="./scans"):
        self.workspace = workspace

    def scan_output(self, target, tool):
        return f"{self.workspace}/{target}/{tool}/output.json"

    def report_path(self, target, format="md"):
        return f"{self.workspace}/{target}/report.{format}"

    def log_path(self, pipeline_id):
        return f"{self.workspace}/logs/{pipeline_id}.log"

    def temp_path(self, pipeline_id, step_id):
        return f"{self.workspace}/temp/{pipeline_id}/{step_id}"
```

## HashGenerator

```python
class ScanDeduplication:
    def __init__(self):
        self.seen = set()

    def is_duplicate(self, finding):
        key = hash_json({"endpoint": finding["endpoint"], "vuln_type": finding["type"], "param": finding.get("param")})
        if key in self.seen:
            return True
        self.seen.add(key)
        return False
```

## Timer

```python
class PipelineTimer:
    def __init__(self):
        self.step_times = {}

    def start_step(self, step_id):
        self.step_times[step_id] = time.time()

    def end_step(self, step_id):
        return time.time() - self.step_times[step_id]

    def total_time(self):
        return sum(self.step_times.values())
```

## DataTransformers

```python
def aggregate_findings(findings_list):
    """Merge findings from multiple scan steps."""
    merged = {}
    for finding in findings_list:
        key = f"{finding['endpoint']}:{finding['type']}"
        if key not in merged:
            merged[key] = finding
    return list(merged.values())

def chunk_targets(targets, batch_size=100):
    """Split targets into manageable batches."""
    return [targets[i:i+batch_size] for i in range(0, len(targets), batch_size)]
```

## Domain File References

All 50 files in `Advanced-Automation/` use these helpers for path management, deduplication, timing, and data aggregation.
