# Automation-Efficiency 41: Workflow Optimization

## 1. Expert Role

You are an **Elite Workflow Optimization Architect** specializing in automating bug bounty reconnaissance and vulnerability hunting pipelines. Your expertise spans parallel task orchestration, intelligent caching, bottleneck identification, and end-to-end pipeline automation. You operate at the intersection of offensive security and DevOps engineering, building systems that compress weeks of manual recon into hours of automated execution.

Core identity:
- **Primary Domain**: Bug bounty workflow automation and pipeline engineering
- **Secondary Domain**: Performance engineering for security toolchains
- **Mindset**: Measure twice, automate once. Every manual重复 is a candidate for elimination.
- **Ethics Boundary**: All automation runs within authorized scope only. Rate limits are non-negotiable.

---

## 2. Core Concepts

### 2.1 Pipeline Architecture

A bug bounty pipeline is a directed acyclic graph (DAG) of tasks where outputs of one stage feed inputs of the next. The fundamental stages are:

```
Seed Discovery → Asset Enumeration → Service Discovery → Vulnerability Scanning → Validation → Reporting
```

Each stage has:
- **Inputs**: Data from previous stages (domains, IPs, URLs, technologies)
- **Processing**: Tool execution, filtering, deduplication
- **Outputs**: Structured data consumed by downstream stages
- **Side effects**: Network traffic, disk I/O, API rate limit consumption

### 2.2 The Bottleneck Hierarchy

Most bug bounty workflows suffer from bottlenecks in this priority order:

1. **I/O Bound**: Network requests to targets (slowest, most common)
2. **CPU Bound**: Tool computation (hashing, parsing, pattern matching)
3. **Memory Bound**: Large dataset processing ( millions of URLs, subdomains)
4. **Human Bound**: Manual review, decision-making, validation
5. **Storage Bound**: Writing/reading large result files

### 2.3 Parallelization Models

| Model | Use Case | Python Tool | Throughput Gain |
|-------|----------|-------------|-----------------|
| Embarrassingly Parallel | Independent targets | `multiprocessing.Pool` | N× (N = cores) |
| Async I/O | Network-bound tasks | `asyncio` + `aiohttp` | 10-50× |
| Producer-Consumer | Variable-rate stages | `queue.Queue` + threads | 3-10× |
| DAG Scheduler | Complex pipelines | `airflow` / custom | 5-20× |
| Batch Processing | Bulk operations | `pandas` chunked | 2-5× |

### 2.4 Caching Strategies

| Strategy | Implementation | Invalidity Check | Use Case |
|----------|---------------|-----------------|----------|
| Content-hash | SHA256 of response body | Hash mismatch | Static asset dedup |
| ETag/Last-Modified | HTTP conditional requests | Server-side | API responses |
| Time-based TTL | File mtime comparison | Age threshold | DNS records, certificates |
| State-file | JSON checkpoint | Process restart | Pipeline resume |
| Database | SQLite/PostgreSQL | Manual invalidation | Historical comparison |

### 2.5 Deduplication Layers

Deduplication must occur at multiple levels:
- **URL level**: Normalize scheme, trailing slash, case, query param order
- **Content level**: Hash body, ignore dynamic tokens
- **Semantic level**: Two different URLs pointing to the same content
- **Finding level**: Same vulnerability class on same endpoint = one finding

---

## 3. Prerequisites

### 3.1 Required Tools

```bash
# Core recon tools
pip install httpx aiohttp beautifulsoup4 lxml dnspython

# Task orchestration
pip install asyncio subprocess32 rich click pyyaml

# Data processing
pip install pandas orjson pydantic

# Caching and storage
pip install diskcache shelve dbm

# Monitoring and logging
pip install structlog prometheus-client psutil

# Pipeline orchestration (optional, for complex workflows)
pip install networkx pydot
```

### 3.2 System Requirements

```python
# system_check.py
import os
import shutil
import subprocess
import json

def check_prerequisites():
    """Validate system meets minimum requirements for workflow automation."""
    requirements = {
        "cpu_cores": os.cpu_count() or 1,
        "memory_gb": psutil.virtual_memory().total / (1024**3),
        "disk_free_gb": shutil.disk_usage("/").free / (1024**3),
        "python_version": f"{sys.version_info.major}.{sys.version_info.minor}",
    }

    checks = {
        "cpu_cores": requirements["cpu_cores"] >= 2,
        "memory_gb": requirements["memory_gb"] >= 4,
        "disk_free_gb": requirements["disk_free_gb"] >= 10,
        "python_version": requirements["python_version"] >= "3.8",
    }

    # Check required tools
    required_tools = ["subfinder", "httpx", "katana", "nuclei"]
    for tool in required_tools:
        checks[f"tool_{tool}"] = shutil.which(tool) is not None

    return {"requirements": requirements, "checks": checks, "all_pass": all(checks.values())}

if __name__ == "__main__":
    import psutil
    import sys
    result = check_prerequisites()
    print(json.dumps(result, indent=2))
    if not result["all_pass"]:
        failing = [k for k, v in result["checks"].items() if not v]
        print(f"Failing checks: {', '.join(failing)}")
```

### 3.3 Configuration Template

```yaml
# workflow_config.yaml
pipeline:
  name: "target-recon-pipeline"
  version: "1.0"

targets:
  domains:
    - "test-target.example.com"
    - "api.test-target.example.com"
  exclude:
    - "*.cdn.example.com"
    - "*.static.example.com"

stages:
  subdomain_enum:
    tool: subfinder
    timeout: 300
    retries: 2
    parallelism: 4

  http_probe:
    tool: httpx
    threads: 50
    timeout: 10
    follow_redirects: true
    status_codes: [200, 301, 302, 403]

  url_crawl:
    tool: katana
    depth: 3
    scope: "domain"
    parallelism: 8

  dir_fuzz:
    tool: ffuf
    wordlist: "/path/to/common.txt"
    threads: 40
    rate_limit: 100

  vuln_scan:
    tool: nuclei
    severity: [medium, high, critical]
    rate_limit: 150

caching:
  enabled: true
  backend: "diskcache"
  directory: ".cache/pipeline"
  ttl_hours: 24
  max_size_gb: 5

logging:
  level: "INFO"
  file: "pipeline.log"
  format: "json"

reporting:
  output_dir: "reports"
  format: ["json", "markdown"]
  include_raw: false
```

---

## 4. Methodology (Step-by-Step)

### Step 1: Baseline Measurement

Before optimizing, measure current performance:

```python
# baseline_measurement.py
import time
import json
import os
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Dict, List

@dataclass
class StageMetrics:
    name: str
    duration_seconds: float
    items_processed: int
    items_emitted: int
    cpu_percent: float
    memory_mb: float
    network_bytes: int
    errors: int
    cache_hits: int = 0
    cache_misses: int = 0

class PipelineProfiler:
    def __init__(self, output_dir: str = "profiles"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        self.metrics: List[StageMetrics] = []

    def profile_stage(self, stage_name: str):
        """Context manager to profile a pipeline stage."""
        import psutil
        process = psutil.Process()
        start_time = time.monotonic()
        start_memory = process.memory_info().rss
        start_cpu = process.cpu_percent()
        start_net = psutil.net_io_counters()

        class StageContext:
            def __init__(self):
                self.items_in = 0
                self.items_out = 0
                self.errors = 0
                self.cache_hits = 0
                self.cache_misses = 0

            def __enter__(self):
                return self

            def __exit__(self, exc_type, exc_val, exc_tb):
                end_time = time.monotonic()
                end_memory = process.memory_info().rss
                end_cpu = process.cpu_percent()
                end_net = psutil.net_io_counters()

                metrics = StageMetrics(
                    name=stage_name,
                    duration_seconds=end_time - start_time,
                    items_processed=self.items_in,
                    items_emitted=self.items_out,
                    cpu_percent=(start_cpu + end_cpu) / 2,
                    memory_mb=(start_memory + end_memory) / (2 * 1024 * 1024),
                    network_bytes=(end_net.bytes_sent + end_net.bytes_recv) -
                                   (start_net.bytes_sent + start_net.bytes_recv),
                    errors=self.errors,
                    cache_hits=self.cache_hits,
                    cache_misses=self.cache_misses,
                )
                self.metrics.append(metrics)
                return False  # Don't suppress exceptions

        return StageContext()

    def generate_report(self) -> Dict:
        """Generate bottleneck analysis report."""
        if not self.metrics:
            return {"error": "No metrics collected"}

        total_time = sum(m.duration_seconds for m in self.metrics)
        report = {
            "total_duration_seconds": total_time,
            "stages": [asdict(m) for m in self.metrics],
            "bottlenecks": [],
            "recommendations": [],
        }

        # Identify bottlenecks (stages taking >30% of total time)
        for m in self.metrics:
            pct = (m.duration_seconds / total_time) * 100
            if pct > 30:
                report["bottlenecks"].append({
                    "stage": m.name,
                    "percentage": round(pct, 1),
                    "duration": round(m.duration_seconds, 2),
                })
                # Generate recommendation
                if m.network_bytes > 10_000_000:
                    report["recommendations"].append(
                        f"{m.name}: Network-bound. Consider async I/O or connection pooling."
                    )
                elif m.cpu_percent > 80:
                    report["recommendations"].append(
                        f"{m.name}: CPU-bound. Consider multiprocessing or vectorized operations."
                    )
                elif m.errors > 0:
                    report["recommendations"].append(
                        f"{m.name}: {m.errors} errors detected. Review error handling."
                    )

        # Save report
        report_path = self.output_dir / f"profile_{int(time.time())}.json"
        with open(report_path, "w") as f:
            json.dump(report, f, indent=2)

        return report

# Usage
profiler = PipelineProfiler()

with profiler.profile_stage("subdomain_enum") as ctx:
    # Run subdomain enumeration
    ctx.items_in = 100
    ctx.items_out = 85

with profiler.profile_stage("http_probe") as ctx:
    # Run HTTP probing
    ctx.items_in = 85
    ctx.items_out = 42

report = profiler.generate_report()
print(f"Total time: {report['total_duration_seconds']}s")
print(f"Bottlenecks: {len(report['bottlenecks'])}")
```

### Step 2: Implement Caching Layer

```python
# cache_manager.py
import hashlib
import json
import os
import time
from pathlib import Path
from typing import Any, Optional
import sqlite3
from functools import wraps

class CacheManager:
    """Multi-strategy cache for pipeline data."""

    def __init__(self, cache_dir: str = ".cache", ttl_hours: int = 24):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.ttl_seconds = ttl_hours * 3600
        self.db_path = self.cache_dir / "cache.db"
        self._init_db()

    def _init_db(self):
        """Initialize SQLite cache database."""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS cache (
                    key TEXT PRIMARY KEY,
                    value BLOB,
                    created_at REAL,
                    expires_at REAL,
                    hit_count INTEGER DEFAULT 0,
                    last_accessed REAL
                )
            """)
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_expires
                ON cache(expires_at)
            """)

    def _make_key(self, namespace: str, identifier: str) -> str:
        """Create deterministic cache key."""
        raw = f"{namespace}:{identifier}"
        return hashlib.sha256(raw.encode()).hexdigest()

    def get(self, namespace: str, identifier: str) -> Optional[Any]:
        """Retrieve cached value if valid."""
        key = self._make_key(namespace, identifier)
        now = time.time()

        with sqlite3.connect(self.db_path) as conn:
            row = conn.execute(
                "SELECT value, expires_at FROM cache WHERE key = ?",
                (key,)
            ).fetchone()

            if row is None:
                return None

            value_blob, expires_at = row
            if expires_at < now:
                # Expired
                conn.execute("DELETE FROM cache WHERE key = ?", (key,))
                return None

            # Update access stats
            conn.execute(
                "UPDATE cache SET hit_count = hit_count + 1, last_accessed = ? WHERE key = ?",
                (now, key)
            )

            return json.loads(value_blob.decode())

    def set(self, namespace: str, identifier: str, value: Any, ttl_override: Optional[int] = None):
        """Store value in cache."""
        key = self._make_key(namespace, identifier)
        now = time.time()
        ttl = ttl_override or self.ttl_seconds
        expires = now + ttl
        value_blob = json.dumps(value).encode()

        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                "INSERT OR REPLACE INTO cache (key, value, created_at, expires_at, last_accessed) VALUES (?, ?, ?, ?, ?)",
                (key, value_blob, now, expires, now)
            )

    def invalidate(self, namespace: Optional[str] = None):
        """Invalidate cache entries by namespace or all."""
        with sqlite3.connect(self.db_path) as conn:
            if namespace:
                # Hash all keys and delete matching ones
                namespace_hash = hashlib.sha256(f"{namespace}:".encode()).hexdigest()[:16]
                conn.execute(
                    "DELETE FROM cache WHERE key LIKE ?",
                    (f"{namespace_hash}%",)
                )
            else:
                conn.execute("DELETE FROM cache")

    def stats(self) -> Dict:
        """Get cache statistics."""
        with sqlite3.connect(self.db_path) as conn:
            total = conn.execute("SELECT COUNT(*) FROM cache").fetchone()[0]
            valid = conn.execute(
                "SELECT COUNT(*) FROM cache WHERE expires_at > ?",
                (time.time(),)
            ).fetchone()[0]
            avg_hits = conn.execute(
                "SELECT AVG(hit_count) FROM cache WHERE hit_count > 0"
            ).fetchone()[0] or 0

        return {
            "total_entries": total,
            "valid_entries": valid,
            "expired_entries": total - valid,
            "avg_hit_count": round(avg_hits, 1),
        }

    def cached(self, namespace: str, ttl_override: Optional[int] = None):
        """Decorator for caching function results."""
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                # Create identifier from function args
                identifier = hashlib.sha256(
                    json.dumps({"args": args, "kwargs": kwargs}, default=str).encode()
                ).hexdigest()

                # Check cache
                result = self.get(namespace, identifier)
                if result is not None:
                    return result

                # Execute function
                result = func(*args, **kwargs)

                # Store in cache
                self.set(namespace, identifier, result, ttl_override)

                return result
            return wrapper
        return decorator

# Usage example
cache = CacheManager(cache_dir=".cache/pipeline", ttl_hours=24)

@cache.cached("subdomains", ttl_override=3600)
def enumerate_subdomains(domain: str) -> list:
    """Enumerate subdomains with caching."""
    # This function result will be cached for 1 hour
    import subprocess
    result = subprocess.run(
        ["subfinder", "-d", domain, "-silent"],
        capture_output=True, text=True
    )
    return result.stdout.strip().split("\n")
```

### Step 3: Implement Parallel Execution Engine

```python
# parallel_engine.py
import asyncio
import subprocess
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor, as_completed
from typing import Callable, List, Any, Optional
from dataclasses import dataclass
import queue
import threading

@dataclass
class TaskResult:
    task_id: str
    success: bool
    data: Any
    error: Optional[str] = None
    duration: float = 0.0

class ParallelEngine:
    """Unified parallel execution engine for pipeline stages."""

    def __init__(self, max_workers: int = None, use_processes: bool = False):
        self.max_workers = max_workers or min(32, (os.cpu_count() or 1) + 4)
        self.use_processes = use_processes
        self._executor_class = ProcessPoolExecutor if use_processes else ThreadPoolExecutor

    def run_parallel_map(self, func: Callable, items: List[Any],
                         task_id_func: Optional[Callable] = None) -> List[TaskResult]:
        """Map function over items in parallel."""
        results = []
        with self._executor_class(max_workers=self.max_workers) as executor:
            futures = {}
            for item in items:
                task_id = task_id_func(item) if task_id_func else str(item)
                future = executor.submit(func, item)
                futures[future] = task_id

            for future in as_completed(futures):
                task_id = futures[future]
                start = time.monotonic()
                try:
                    data = future.result(timeout=300)
                    results.append(TaskResult(
                        task_id=task_id,
                        success=True,
                        data=data,
                        duration=time.monotonic() - start
                    ))
                except Exception as e:
                    results.append(TaskResult(
                        task_id=task_id,
                        success=False,
                        data=None,
                        error=str(e),
                        duration=time.monotonic() - start
                    ))
        return results

    async def run_async_map(self, func: Callable, items: List[Any],
                            concurrency: int = 50) -> List[TaskResult]:
        """Async map with concurrency limit."""
        semaphore = asyncio.Semaphore(concurrency)
        results = []

        async def bounded_func(item):
            async with semaphore:
                if asyncio.iscoroutinefunction(func):
                    return await func(item)
                else:
                    loop = asyncio.get_event_loop()
                    return await loop.run_in_executor(None, func, item)

        tasks = [bounded_func(item) for item in items]
        completed = await asyncio.gather(*tasks, return_exceptions=True)

        for item, result in zip(items, completed):
            if isinstance(result, Exception):
                results.append(TaskResult(
                    task_id=str(item),
                    success=False,
                    data=None,
                    error=str(result)
                ))
            else:
                results.append(TaskResult(
                    task_id=str(item),
                    success=True,
                    data=result
                ))
        return results

    def producer_consumer_pipeline(self, producer: Callable, consumer: Callable,
                                    items: List[Any], queue_size: int = 100) -> List[TaskResult]:
        """Producer-consumer pattern for variable-rate stages."""
        task_queue = queue.Queue(maxsize=queue_size)
        results = []
        results_lock = threading.Lock()

        def producer_thread():
            for item in items:
                task_queue.put(item)
            # Signal completion
            for _ in range(self.max_workers):
                task_queue.put(None)

        def consumer_thread(worker_id):
            while True:
                item = task_queue.get()
                if item is None:
                    break
                try:
                    start = time.monotonic()
                    result = consumer(item)
                    duration = time.monotonic() - start
                    with results_lock:
                        results.append(TaskResult(
                            task_id=f"worker_{worker_id}_{item}",
                            success=True,
                            data=result,
                            duration=duration
                        ))
                except Exception as e:
                    with results_lock:
                        results.append(TaskResult(
                            task_id=f"worker_{worker_id}_{item}",
                            success=False,
                            error=str(e)
                        ))
                finally:
                    task_queue.task_done()

        # Start producer
        producer_t = threading.Thread(target=producer_thread)
        producer_t.start()

        # Start consumers
        consumers = []
        for i in range(self.max_workers):
            t = threading.Thread(target=consumer_thread, args=(i,))
            t.start()
            consumers.append(t)

        # Wait for completion
        producer_t.join()
        for t in consumers:
            t.join()

        return results

# Usage
engine = ParallelEngine(max_workers=20)

# Example: parallel HTTP probing
def probe_url(url: str) -> dict:
    import httpx
    try:
        resp = httpx.get(url, timeout=10, follow_redirects=True)
        return {"url": url, "status": resp.status_code, "length": len(resp.content)}
    except Exception as e:
        return {"url": url, "error": str(e)}

urls = ["http://test-target.example.com", "http://api.test-target.example.com"]
results = engine.run_parallel_map(probe_url, urls)
print(f"Probed {len(results)} URLs, {sum(1 for r in results if r.success)} successful")
```

### Step 4: Build the DAG Scheduler

```python
# dag_scheduler.py
import json
from typing import Dict, List, Set, Callable, Any
from collections import defaultdict, deque
from dataclasses import dataclass, field
import time

@dataclass
class PipelineNode:
    name: str
    func: Callable
    dependencies: List[str] = field(default_factory=list)
    config: Dict = field(default_factory=dict)

class DAGScheduler:
    """Direct Acyclic Graph scheduler for pipeline orchestration."""

    def __init__(self):
        self.nodes: Dict[str, PipelineNode] = {}
        self.results: Dict[str, Any] = {}

    def add_node(self, name: str, func: Callable, dependencies: List[str] = None, config: Dict = None):
        """Add a node to the DAG."""
        self.nodes[name] = PipelineNode(
            name=name,
            func=func,
            dependencies=dependencies or [],
            config=config or {}
        )

    def validate_dag(self) -> List[str]:
        """Validate DAG has no cycles and all dependencies exist."""
        errors = []

        # Check all dependencies exist
        for name, node in self.nodes.items():
            for dep in node.dependencies:
                if dep not in self.nodes:
                    errors.append(f"Node '{name}' depends on unknown node '{dep}'")

        # Check for cycles using Kahn's algorithm
        in_degree = defaultdict(int)
        graph = defaultdict(list)
        for name, node in self.nodes.items():
            for dep in node.dependencies:
                graph[dep].append(name)
                in_degree[name] += 1

        queue = deque([n for n in self.nodes if in_degree[n] == 0])
        visited = 0
        while queue:
            current = queue.popleft()
            visited += 1
            for neighbor in graph[current]:
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0:
                    queue.append(neighbor)

        if visited != len(self.nodes):
            errors.append("Cycle detected in DAG")

        return errors

    def get_execution_order(self) -> List[List[str]]:
        """Get topological sort with level grouping for parallel execution."""
        in_degree = defaultdict(int)
        graph = defaultdict(list)
        for name, node in self.nodes.items():
            for dep in node.dependencies:
                graph[dep].append(name)
                in_degree[name] += 1

        levels = []
        current_level = [n for n in self.nodes if in_degree[n] == 0]

        while current_level:
            levels.append(current_level)
            next_level = []
            for node_name in current_level:
                for neighbor in graph[node_name]:
                    in_degree[neighbor] -= 1
                    if in_degree[neighbor] == 0:
                        next_level.append(neighbor)
            current_level = next_level

        return levels

    def execute(self, input_data: Any = None) -> Dict[str, Any]:
        """Execute the entire DAG."""
        errors = self.validate_dag()
        if errors:
            raise ValueError(f"DAG validation failed: {errors}")

        levels = self.get_execution_order()
        self.results = {"__input__": input_data}

        for level_idx, level in enumerate(levels):
            print(f"Executing level {level_idx}: {level}")
            # Nodes in same level can run in parallel
            # For simplicity, running sequentially here
            # Use ParallelEngine for true parallelism
            for node_name in level:
                node = self.nodes[node_name]
                # Gather inputs from dependencies
                dep_results = {dep: self.results[dep] for dep in node.dependencies}

                start = time.monotonic()
                try:
                    if node.dependencies:
                        result = node.func(dep_results, **node.config)
                    else:
                        result = node.func(input_data, **node.config)
                    self.results[node_name] = {
                        "success": True,
                        "data": result,
                        "duration": time.monotonic() - start
                    }
                except Exception as e:
                    self.results[node_name] = {
                        "success": False,
                        "error": str(e),
                        "duration": time.monotonic() - start
                    }
                    print(f"  ERROR in {node_name}: {e}")

        return self.results

# Example pipeline
def subdomain_enum(input_data):
    """Enumerate subdomains."""
    # Simulate subfinder output
    return ["www.test-target.example.com", "api.test-target.example.com"]

def http_probe(dep_results, threads=50):
    """Probe discovered subdomains."""
    subs = dep_results.get("subdomains", {}).get("data", [])
    return [{"url": f"http://{s}", "status": 200} for s in subs]

def url_crawl(dep_results, depth=3):
    """Crawl discovered URLs."""
    probed = dep_results.get("http_probe", {}).get("data", [])
    return [f"{p['url']}/page{i}" for i, p in enumerate(probed)]

def vuln_scan(dep_results, severity="high"):
    """Scan for vulnerabilities."""
    urls = dep_results.get("url_crawl", {}).get("data", [])
    return [{"url": u, "vuln": "none"} for u in urls]

# Build and execute pipeline
scheduler = DAGScheduler()
scheduler.add_node("subdomains", subdomain_enum)
scheduler.add_node("http_probe", http_probe, dependencies=["subdomains"])
scheduler.add_node("url_crawl", url_crawl, dependencies=["http_probe"])
scheduler.add_node("vuln_scan", vuln_scan, dependencies=["url_crawl"])

results = scheduler.execute(input_data={"domain": "test-target.example.com"})
```

### Step 5: Implement State Management for Resume Capability

```python
# state_manager.py
import json
import time
from pathlib import Path
from typing import Dict, Any, Optional
from enum import Enum

class StageStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    SKIPPED = "skipped"

class StateManager:
    """Pipeline state management for checkpoint/resume."""

    def __init__(self, state_dir: str = ".state"):
        self.state_dir = Path(state_dir)
        self.state_dir.mkdir(exist_ok=True)
        self.state_file = self.state_dir / "pipeline_state.json"
        self.state = self._load_state()

    def _load_state(self) -> Dict:
        """Load state from disk."""
        if self.state_file.exists():
            with open(self.state_file) as f:
                return json.load(f)
        return {"stages": {}, "created_at": time.time()}

    def _save_state(self):
        """Persist state to disk."""
        with open(self.state_file, "w") as f:
            json.dump(self.state, f, indent=2)

    def stage_started(self, stage_name: str):
        """Mark stage as started."""
        self.state["stages"][stage_name] = {
            "status": StageStatus.RUNNING.value,
            "started_at": time.time(),
        }
        self._save_state()

    def stage_completed(self, stage_name: str, output_path: str, metrics: Dict = None):
        """Mark stage as completed with output reference."""
        self.state["stages"][stage_name].update({
            "status": StageStatus.COMPLETED.value,
            "completed_at": time.time(),
            "output_path": output_path,
            "metrics": metrics or {},
        })
        self._save_state()

    def stage_failed(self, stage_name: str, error: str):
        """Mark stage as failed."""
        self.state["stages"][stage_name].update({
            "status": StageStatus.FAILED.value,
            "error": error,
            "failed_at": time.time(),
        })
        self._save_state()

    def should_skip(self, stage_name: str) -> bool:
        """Check if stage should be skipped (already completed)."""
        stage = self.state["stages"].get(stage_name)
        if stage is None:
            return False
        return stage["status"] == StageStatus.COMPLETED.value

    def get_completed_stages(self) -> List[str]:
        """List all completed stages."""
        return [
            name for name, stage in self.state["stages"].items()
            if stage["status"] == StageStatus.COMPLETED.value
        ]

    def get_stage_output(self, stage_name: str) -> Optional[str]:
        """Get output path for a completed stage."""
        stage = self.state["stages"].get(stage_name)
        if stage and stage["status"] == StageStatus.COMPLETED.value:
            return stage.get("output_path")
        return None

    def reset(self, stage_name: Optional[str] = None):
        """Reset state for specific stage or all stages."""
        if stage_name:
            self.state["stages"].pop(stage_name, None)
        else:
            self.state["stages"] = {}
        self._save_state()

# Usage in pipeline
state = StateManager(".state/target-recon")

def run_stage(name: str, func, *args, **kwargs):
    """Run a stage with state management."""
    if state.should_skip(name):
        print(f"Skipping {name} (already completed)")
        return state.get_stage_output(name)

    state.stage_started(name)
    try:
        result = func(*args, **kwargs)
        output_path = f"data/{name}_output.json"
        with open(output_path, "w") as f:
            json.dump(result, f)
        state.stage_completed(name, output_path)
        return result
    except Exception as e:
        state.stage_failed(name, str(e))
        raise
```

---

## 5. Tool Arsenal with Commands

### 5.1 Async HTTP Prober

```python
# async_http_prober.py
import asyncio
import httpx
from typing import List, Dict
import time

async def probe_single_url(client: httpx.AsyncClient, url: str) -> Dict:
    """Probe a single URL with full metrics."""
    start = time.monotonic()
    try:
        response = await client.get(url, timeout=15, follow_redirects=True)
        return {
            "url": str(response.url),
            "status": response.status_code,
            "content_length": len(response.content),
            "headers": dict(response.headers),
            "technologies": detect_technologies(response),
            "response_time_ms": (time.monotonic() - start) * 1000,
            "redirect_chain": [str(r.url) for r in response.history],
        }
    except Exception as e:
        return {
            "url": url,
            "error": str(e),
            "response_time_ms": (time.monotonic() - start) * 1000,
        }

def detect_technologies(response: httpx.Response) -> List[str]:
    """Detect technologies from response headers and body."""
    techs = []
    headers = response.headers
    body = response.text[:10000]  # First 10KB

    # Header-based detection
    if "x-powered-by" in headers:
        techs.append(headers["x-powered-by"])
    if "server" in headers:
        techs.append(headers["server"])

    # Body-based detection
    indicators = {
        "WordPress": ["wp-content", "wp-includes"],
        "Drupal": ["drupal", "sites/default"],
        "Joomla": ["joomla", "media/system"],
        "React": ["react", "ReactDOM"],
        "Angular": ["ng-version", "angular"],
        "Vue.js": ["vue.js", "Vue."],
        "Next.js": ["_next", "nextjs"],
        "Laravel": ["laravel", "csrf-token"],
        "Django": ["csrfmiddlewaretoken", "django"],
        "Flask": ["werkzeug"],
        "Express": ["X-Powered-By: Express"],
    }
    for tech, patterns in indicators.items():
        for pattern in patterns:
            if pattern.lower() in body.lower() or pattern.lower() in str(headers).lower():
                techs.append(tech)
                break

    return list(set(techs))

async def batch_probe(urls: List[str], concurrency: int = 100) -> List[Dict]:
    """Probe many URLs concurrently."""
    async with httpx.AsyncClient(
        verify=False,
        follow_redirects=True,
        limits=httpx.Limits(
            max_connections=concurrency,
            max_keepalive_connections=concurrency // 2,
        )
    ) as client:
        semaphore = asyncio.Semaphore(concurrency)

        async def bounded_probe(url):
            async with semaphore:
                return await probe_single_url(client, url)

        tasks = [bounded_probe(url) for url in urls]
        return await asyncio.gather(*tasks)

# Run the prober
urls = [
    "http://test-target.example.com",
    "http://api.test-target.example.com",
    "http://admin.test-target.example.com",
]
results = asyncio.run(batch_probe(urls, concurrency=50))
print(f"Probed {len(results)} URLs")
for r in results:
    if "error" not in r:
        print(f"  {r['url']}: {r['status']} ({r['response_time_ms']:.0f}ms) [{', '.join(r['technologies'])}]")
```

### 5.2 Smart Deduplicator

```python
# deduplicator.py
from urllib.parse import urlparse, urlunparse, parse_qs, urlencode
from typing import List, Dict, Set
import hashlib
from collections import defaultdict

class SmartDeduplicator:
    """Multi-level URL and content deduplication."""

    @staticmethod
    def normalize_url(url: str) -> str:
        """Normalize URL for deduplication."""
        parsed = urlparse(url)

        # Normalize scheme
        scheme = parsed.scheme.lower()

        # Normalize host
        host = parsed.hostname.lower() if parsed.hostname else ""

        # Remove default ports
        port = parsed.port
        if (scheme == "http" and port == 80) or (scheme == "https" and port == 443):
            port = None

        # Normalize path
        path = parsed.path.rstrip("/") or "/"

        # Sort query parameters
        query_params = parse_qs(parsed.query, keep_blank_values=True)
        sorted_query = urlencode(sorted(query_params.items()), doseq=True)

        # Reconstruct
        netloc = host
        if port:
            netloc = f"{host}:{port}"

        normalized = urlunparse((scheme, netloc, path, "", sorted_query, ""))
        return normalized

    @staticmethod
    def content_hash(content: bytes) -> str:
        """Generate content hash for deduplication."""
        return hashlib.sha256(content).hexdigest()

    @staticmethod
    def extract_path_pattern(url: str) -> str:
        """Extract URL pattern by replacing IDs."""
        parsed = urlparse(url)
        path = parsed.path

        # Replace numeric segments
        import re
        pattern = re.sub(r'/\d+', '/{id}', path)

        # Replace UUIDs
        pattern = re.sub(
            r'/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
            '/{uuid}',
            pattern
        )

        return pattern

    def deduplicate_urls(self, urls: List[str]) -> List[str]:
        """Deduplicate URLs at multiple levels."""
        seen_normalized: Set[str] = set()
        seen_content: Set[str] = set()
        unique_urls = []

        for url in urls:
            # Level 1: Normalized URL
            normalized = self.normalize_url(url)
            if normalized in seen_normalized:
                continue

            # Level 2: Content hash (requires fetch - skip if not available)
            # This would be used if you have cached content

            seen_normalized.add(normalized)
            unique_urls.append(url)

        return unique_urls

    def deduplicate_findings(self, findings: List[Dict]) -> List[Dict]:
        """Deduplicate findings by severity, endpoint, and type."""
        seen = set()
        unique = []

        for finding in findings:
            key = (
                finding.get("type", ""),
                finding.get("endpoint", ""),
                finding.get("severity", ""),
            )
            if key not in seen:
                seen.add(key)
                unique.append(finding)

        return unique

# Usage
dedup = SmartDeduplicator()
urls = [
    "http://example.com/page?id=1",
    "http://example.com/page?id=2",
    "HTTP://Example.COM/page?id=1",  # Duplicate
    "http://example.com/page/",  # Trailing slash duplicate
]
unique = dedup.deduplicate_urls(urls)
print(f"Deduplicated: {len(urls)} -> {len(unique)}")
```

### 5.3 Pipeline Monitor

```python
# pipeline_monitor.py
import time
import json
from typing import Dict, List
from dataclasses import dataclass, asdict
from pathlib import Path
import threading

@dataclass
class PipelineEvent:
    timestamp: float
    event_type: str  # stage_start, stage_complete, error, metric
    stage: str
    details: Dict

class PipelineMonitor:
    """Real-time pipeline monitoring and alerting."""

    def __init__(self, log_dir: str = "monitoring"):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(exist_ok=True)
        self.events: List[PipelineEvent] = []
        self.alerts: List[Dict] = []
        self.lock = threading.Lock()
        self.thresholds = {
            "max_stage_duration": 600,  # 10 minutes
            "max_error_rate": 0.1,  # 10%
            "min_throughput": 10,  # items per second
        }

    def record_event(self, event_type: str, stage: str, details: Dict = None):
        """Record a pipeline event."""
        with self.lock:
            event = PipelineEvent(
                timestamp=time.time(),
                event_type=event_type,
                stage=stage,
                details=details or {}
            )
            self.events.append(event)

            # Check for alerts
            self._check_alerts(event)

    def _check_alerts(self, event: PipelineEvent):
        """Check if event triggers any alerts."""
        if event.event_type == "stage_complete":
            duration = event.details.get("duration", 0)
            if duration > self.thresholds["max_stage_duration"]:
                self.alerts.append({
                    "timestamp": event.timestamp,
                    "type": "slow_stage",
                    "stage": event.stage,
                    "duration": duration,
                    "threshold": self.thresholds["max_stage_duration"],
                })

        if event.event_type == "error":
            self.alerts.append({
                "timestamp": event.timestamp,
                "type": "error",
                "stage": event.stage,
                "details": event.details,
            })

    def get_stage_stats(self) -> Dict:
        """Calculate statistics per stage."""
        stage_events = {}
        for event in self.events:
            if event.stage not in stage_events:
                stage_events[event.stage] = {"starts": 0, "completions": 0, "errors": 0, "total_duration": 0}

            if event.event_type == "stage_start":
                stage_events[event.stage]["starts"] += 1
            elif event.event_type == "stage_complete":
                stage_events[event.stage]["completions"] += 1
                stage_events[event.stage]["total_duration"] += event.details.get("duration", 0)
            elif event.event_type == "error":
                stage_events[event.stage]["errors"] += 1

        stats = {}
        for stage, counts in stage_events.items():
            completions = counts["completions"]
            stats[stage] = {
                **counts,
                "avg_duration": counts["total_duration"] / completions if completions > 0 else 0,
                "error_rate": counts["errors"] / counts["starts"] if counts["starts"] > 0 else 0,
            }

        return stats

    def export_report(self, output_path: str = "monitoring/report.json"):
        """Export monitoring report."""
        report = {
            "total_events": len(self.events),
            "total_alerts": len(self.alerts),
            "stage_stats": self.get_stage_stats(),
            "alerts": self.alerts,
            "timeline": [
                {
                    "timestamp": e.timestamp,
                    "type": e.event_type,
                    "stage": e.stage,
                }
                for e in self.events
            ],
        }

        with open(output_path, "w") as f:
            json.dump(report, f, indent=2)

        return report
```

---

## 6. Real-World Examples

### 6.1 Bug Bounty Recon Pipeline

```python
# full_recon_pipeline.py
import asyncio
import json
import subprocess
from pathlib import Path
from typing import List, Dict
import time
import hashlib

class BugBountyPipeline:
    """Complete bug bounty reconnaissance pipeline."""

    def __init__(self, target_domain: str, output_dir: str = "output"):
        self.domain = target_domain
        self.output_dir = Path(output_dir) / target_domain
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.cache = CacheManager(cache_dir=f".cache/{target_domain}")
        self.state = StateManager(f".state/{target_domain}")
        self.monitor = PipelineMonitor(f"monitoring/{target_domain}")

    def run_subfinder(self) -> List[str]:
        """Run subfinder for subdomain enumeration."""
        if self.state.should_skip("subfinder"):
            return json.loads(Path(self.state.get_stage_output("subfinder")).read_text())

        self.state.stage_started("subfinder")
        self.monitor.record_event("stage_start", "subfinder")

        try:
            result = subprocess.run(
                ["subfinder", "-d", self.domain, "-silent", "-timeout", "300"],
                capture_output=True, text=True, timeout=600
            )
            subdomains = [s.strip() for s in result.stdout.strip().split("\n") if s.strip()]

            output_path = str(self.output_dir / "subdomains.json")
            with open(output_path, "w") as f:
                json.dump(subdomains, f, indent=2)

            self.state.stage_completed("subfinder", output_path, {"count": len(subdomains)})
            self.monitor.record_event("stage_complete", "subfinder", {
                "count": len(subdomains),
                "duration": 0
            })

            return subdomains
        except Exception as e:
            self.state.stage_failed("subfinder", str(e))
            self.monitor.record_event("error", "subfinder", {"error": str(e)})
            raise

    async def run_httpx(self, subdomains: List[str]) -> List[Dict]:
        """Run httpx for HTTP probing."""
        if self.state.should_skip("httpx"):
            return json.loads(Path(self.state.get_stage_output("httpx")).read_text())

        self.state.stage_started("httpx")
        self.monitor.record_event("stage_start", "httpx")

        try:
            # Write subdomains to temp file
            temp_file = self.output_dir / "subdomains_temp.txt"
            temp_file.write_text("\n".join(subdomains))

            result = subprocess.run(
                ["httpx", "-l", str(temp_file), "-silent", "-json",
                 "-threads", "50", "-timeout", "10"],
                capture_output=True, text=True, timeout=600
            )

            live_hosts = []
            for line in result.stdout.strip().split("\n"):
                if line.strip():
                    try:
                        live_hosts.append(json.loads(line))
                    except json.JSONDecodeError:
                        continue

            output_path = str(self.output_dir / "live_hosts.json")
            with open(output_path, "w") as f:
                json.dump(live_hosts, f, indent=2)

            self.state.stage_completed("httpx", output_path, {"count": len(live_hosts)})
            self.monitor.record_event("stage_complete", "httpx", {"count": len(live_hosts)})

            # Cleanup
            temp_file.unlink(missing_ok=True)

            return live_hosts
        except Exception as e:
            self.state.stage_failed("httpx", str(e))
            self.monitor.record_event("error", "httpx", {"error": str(e)})
            raise

    async def run_katana(self, live_hosts: List[Dict]) -> List[str]:
        """Run katana for URL discovery."""
        if self.state.should_skip("katana"):
            return json.loads(Path(self.state.get_stage_output("katana")).read_text())

        self.state.stage_started("katana")
        self.monitor.record_event("stage_start", "katana")

        try:
            urls_file = self.output_dir / "live_urls.txt"
            urls_file.write_text("\n".join([h["url"] for h in live_hosts]))

            result = subprocess.run(
                ["katana", "-l", str(urls_file), "-silent", "-d", "3",
                 "-timeout", "300"],
                capture_output=True, text=True, timeout=1200
            )

            urls = list(set([u.strip() for u in result.stdout.strip().split("\n") if u.strip()]))

            output_path = str(self.output_dir / "crawled_urls.json")
            with open(output_path, "w") as f:
                json.dump(urls, f, indent=2)

            self.state.stage_completed("katana", output_path, {"count": len(urls)})
            self.monitor.record_event("stage_complete", "katana", {"count": len(urls)})

            urls_file.unlink(missing_ok=True)

            return urls
        except Exception as e:
            self.state.stage_failed("katana", str(e))
            self.monitor.record_event("error", "katana", {"error": str(e)})
            raise

    async def run_nuclei(self, urls: List[str]) -> List[Dict]:
        """Run nuclei for vulnerability scanning."""
        if self.state.should_skip("nuclei"):
            return json.loads(Path(self.state.get_stage_output("nuclei")).read_text())

        self.state.stage_started("nuclei")
        self.monitor.record_event("stage_start", "nuclei")

        try:
            urls_file = self.output_dir / "scan_urls.txt"
            urls_file.write_text("\n".join(urls))

            result = subprocess.run(
                ["nuclei", "-l", str(urls_file), "-silent", "-json",
                 "-severity", "medium,high,critical", "-rate-limit", "150"],
                capture_output=True, text=True, timeout=3600
            )

            findings = []
            for line in result.stdout.strip().split("\n"):
                if line.strip():
                    try:
                        findings.append(json.loads(line))
                    except json.JSONDecodeError:
                        continue

            output_path = str(self.output_dir / "findings.json")
            with open(output_path, "w") as f:
                json.dump(findings, f, indent=2)

            self.state.stage_completed("nuclei", output_path, {"count": len(findings)})
            self.monitor.record_event("stage_complete", "nuclei", {"count": len(findings)})

            urls_file.unlink(missing_ok=True)

            return findings
        except Exception as e:
            self.state.stage_failed("nuclei", str(e))
            self.monitor.record_event("error", "nuclei", {"error": str(e)})
            raise

    async def execute(self):
        """Execute the full pipeline."""
        print(f"[*] Starting recon pipeline for {self.domain}")
        start_time = time.time()

        # Stage 1: Subdomain enumeration
        print("[*] Stage 1: Subdomain enumeration")
        subdomains = await asyncio.to_thread(self.run_subfinder)
        print(f"[+] Found {len(subdomains)} subdomains")

        # Stage 2: HTTP probing
        print("[*] Stage 2: HTTP probing")
        live_hosts = await self.run_httpx(subdomains)
        print(f"[+] Found {len(live_hosts)} live hosts")

        # Stage 3: URL crawling
        print("[*] Stage 3: URL crawling")
        urls = await self.run_katana(live_hosts)
        print(f"[+] Crawled {len(urls)} URLs")

        # Stage 4: Vulnerability scanning
        print("[*] Stage 4: Vulnerability scanning")
        findings = await self.run_nuclei(urls)
        print(f"[+] Found {len(findings)} potential vulnerabilities")

        # Generate report
        duration = time.time() - start_time
        report = {
            "target": self.domain,
            "duration_seconds": duration,
            "subdomains_found": len(subdomains),
            "live_hosts": len(live_hosts),
            "urls_crawled": len(urls),
            "findings": len(findings),
            "report_path": str(self.output_dir),
        }

        # Export monitoring report
        self.monitor.export_report(str(self.output_dir / "monitoring_report.json"))

        print(f"\n[+] Pipeline completed in {duration:.1f}s")
        print(f"[+] Results saved to {self.output_dir}")

        return report

# Execute
pipeline = BugBountyPipeline("test-target.example.com")
result = asyncio.run(pipeline.execute())
```

### 6.2 Batch Target Processor

```python
# batch_processor.py
import asyncio
import json
from typing import List, Dict
from pathlib import Path
import time

class BatchTargetProcessor:
    """Process multiple targets in parallel with shared resources."""

    def __init__(self, max_concurrent: int = 5):
        self.max_concurrent = max_concurrent
        self.results = {}
        self.semaphore = asyncio.Semaphore(max_concurrent)

    async def process_target(self, target: str) -> Dict:
        """Process a single target through full pipeline."""
        async with self.semaphore:
            pipeline = BugBountyPipeline(target)
            try:
                result = await pipeline.execute()
                return {"target": target, "success": True, "result": result}
            except Exception as e:
                return {"target": target, "success": False, "error": str(e)}

    async def process_batch(self, targets: List[str]) -> Dict:
        """Process all targets."""
        tasks = [self.process_target(target) for target in targets]
        results = await asyncio.gather(*tasks, return_exceptions=True)

        summary = {
            "total": len(targets),
            "successful": sum(1 for r in results if isinstance(r, dict) and r.get("success")),
            "failed": sum(1 for r in results if isinstance(r, dict) and not r.get("success")),
            "results": results,
        }

        # Save summary
        output_path = Path("output/batch_summary.json")
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            json.dump(summary, f, indent=2)

        return summary

# Usage
targets = [
    "test-target-1.example.com",
    "test-target-2.example.com",
    "test-target-3.example.com",
]

processor = BatchTargetProcessor(max_concurrent=3)
results = asyncio.run(processor.process_batch(targets))
print(f"Processed {results['total']} targets: {results['successful']} successful, {results['failed']} failed")
```

---

## 7. Common Pitfalls

### 7.1 Rate Limit Violations

```python
# rate_limiter.py
import time
import asyncio
from collections import defaultdict
from typing import Dict

class AdaptiveRateLimiter:
    """Adaptive rate limiter that backs off on errors."""

    def __init__(self, requests_per_second: float = 10, backoff_factor: float = 2.0):
        self.base_rate = requests_per_second
        self.current_rate = requests_per_second
        self.backoff_factor = backoff_factor
        self.last_request_time = 0
        self.error_count = 0
        self.success_count = 0

    async def acquire(self):
        """Wait until rate limit allows next request."""
        now = time.time()
        time_since_last = now - self.last_request_time
        min_interval = 1.0 / self.current_rate

        if time_since_last < min_interval:
            await asyncio.sleep(min_interval - time_since_last)

        self.last_request_time = time.time()

    def report_success(self):
        """Report successful request."""
        self.success_count += 1
        # Gradually increase rate
        if self.success_count % 100 == 0:
            self.current_rate = min(self.current_rate * 1.1, self.base_rate * 2)

    def report_error(self, status_code: int = None):
        """Report failed request."""
        self.error_count += 1
        if status_code in (429, 503):
            # Rate limited or service unavailable
            self.current_rate = max(1, self.current_rate / self.backoff_factor)
            print(f"[*] Rate limited, reducing to {self.current_rate:.1f} req/s")

    def get_status(self) -> Dict:
        return {
            "current_rate": self.current_rate,
            "base_rate": self.base_rate,
            "error_count": self.error_count,
            "success_count": self.success_count,
        }

# Usage
limiter = AdaptiveRateLimiter(requests_per_second=50)

async def rate_limited_request(client, url):
    await limiter.acquire()
    try:
        response = await client.get(url)
        if response.status_code == 429:
            limiter.report_error(429)
        else:
            limiter.report_success()
        return response
    except Exception as e:
        limiter.report_error()
        raise
```

### 7.2 Memory Exhaustion

```python
# memory_safe_processor.py
import json
from pathlib import Path
from typing import Iterator, Any
import gc

class MemorySafeProcessor:
    """Process large datasets without memory exhaustion."""

    def __init__(self, chunk_size: int = 1000):
        self.chunk_size = chunk_size

    def stream_jsonl(self, filepath: str) -> Iterator[Dict]:
        """Stream JSON lines file without loading all into memory."""
        with open(filepath, "r") as f:
            for line in f:
                if line.strip():
                    yield json.loads(line)

    def chunked_process(self, items: Iterator, processor_func):
        """Process items in chunks to control memory."""
        chunk = []
        results = []

        for item in items:
            chunk.append(item)
            if len(chunk) >= self.chunk_size:
                chunk_results = processor_func(chunk)
                results.extend(chunk_results)
                chunk = []
                gc.collect()  # Force garbage collection

        # Process remaining
        if chunk:
            results.extend(processor_func(chunk))

        return results

    def write_chunked(self, items: Iterator, output_path: str):
        """Write items to file in chunks."""
        with open(output_path, "w") as f:
            chunk = []
            for item in items:
                chunk.append(item)
                if len(chunk) >= self.chunk_size:
                    for line in chunk:
                        f.write(json.dumps(line) + "\n")
                    chunk = []
            for line in chunk:
                f.write(json.dumps(line) + "\n")
```

### 7.3 Cache Invalidation Storms

```python
# cache_strategy.py
class CacheStrategy:
    """Intelligent cache invalidation strategy."""

    @staticmethod
    def should_invalidate(cached_data: dict, current_context: dict) -> bool:
        """Determine if cache should be invalidated."""
        # Time-based
        if current_context.get("force_refresh"):
            return True

        # Content-based (for dynamic content)
        if cached_data.get("content_hash") != current_context.get("content_hash"):
            return True

        # Dependency-based
        for dep in current_context.get("dependencies", []):
            if dep in current_context.get("changed_dependencies", []):
                return True

        return False

    @staticmethod
    def get_ttl(content_type: str, freshness: str = "normal") -> int:
        """Get appropriate TTL based on content type."""
        ttls = {
            "dns_record": 3600,  # 1 hour
            "certificate": 86400,  # 24 hours
            "technology": 604800,  # 7 days
            "subdomain": 3600,  # 1 hour
            "url_probe": 300,  # 5 minutes
            "vulnerability_scan": 86400,  # 24 hours
        }

        base_ttl = ttls.get(content_type, 3600)

        if freshness == "aggressive":
            return base_ttl // 4
        elif freshness == "conservative":
            return base_ttl * 4

        return base_ttl
```

---

## 8. Advanced Techniques

### 8.1 Machine Learning-Based Prioritization

```python
# ml_prioritizer.py
import json
from typing import List, Dict
from dataclasses import dataclass

@dataclass
class PrioritizedFinding:
    finding: Dict
    priority_score: float
    reasons: List[str]

class MLPrioritizer:
    """ML-based vulnerability prioritization."""

    def __init__(self):
        # Simple scoring model (replace with trained model in production)
        self.severity_weights = {
            "critical": 10,
            "high": 7,
            "medium": 4,
            "low": 1,
        }
        self.vuln_type_weights = {
            "rce": 10,
            "sqli": 9,
            "ssrf": 8,
            "xss": 6,
            "idor": 5,
            "info_disclosure": 2,
        }

    def score_finding(self, finding: Dict) -> PrioritizedFinding:
        """Score and prioritize a finding."""
        score = 0
        reasons = []

        # Severity score
        severity = finding.get("severity", "low").lower()
        severity_score = self.severity_weights.get(severity, 1)
        score += severity_score
        reasons.append(f"Severity {severity}: +{severity_score}")

        # Vulnerability type score
        vuln_type = finding.get("type", "unknown").lower()
        type_score = self.vuln_type_weights.get(vuln_type, 1)
        score += type_score
        reasons.append(f"Type {vuln_type}: +{type_score}")

        # Endpoint sensitivity bonus
        endpoint = finding.get("endpoint", "").lower()
        sensitive_patterns = ["/admin", "/api", "/internal", "/debug", "/auth"]
        for pattern in sensitive_patterns:
            if pattern in endpoint:
                score += 3
                reasons.append(f"Sensitive endpoint ({pattern}): +3")
                break

        # Authentication required (higher if auth bypass)
        if finding.get("auth_required") and finding.get("bypass_auth"):
            score += 5
            reasons.append("Auth bypass potential: +5")

        return PrioritizedFinding(
            finding=finding,
            priority_score=score,
            reasons=reasons,
        )

    def prioritize(self, findings: List[Dict]) -> List[PrioritizedFinding]:
        """Prioritize all findings."""
        scored = [self.score_finding(f) for f in findings]
        return sorted(scored, key=lambda x: x.priority_score, reverse=True)

# Usage
prioritizer = MLPrioritizer()
findings = [
    {"severity": "high", "type": "sqli", "endpoint": "/api/users"},
    {"severity": "medium", "type": "xss", "endpoint": "/search"},
    {"severity": "critical", "type": "rce", "endpoint": "/admin/upload"},
]
prioritized = prioritizer.prioritize(findings)
for p in prioritized:
    print(f"Score {p.priority_score}: {p.finding['type']} ({', '.join(p.reasons)})")
```

### 8.2 Pipeline Composition Patterns

```python
# pipeline_composition.py
from typing import Callable, Any
from functools import wraps

class PipelineBuilder:
    """Fluent API for building pipelines."""

    def __init__(self):
        self.stages = []

    def stage(self, name: str, func: Callable = None):
        """Add a stage to the pipeline."""
        def decorator(f):
            self.stages.append({"name": name, "func": f})
            @wraps(f)
            def wrapper(*args, **kwargs):
                return f(*args, **kwargs)
            return wrapper
        return decorator

    def parallel(self, *funcs):
        """Add parallel execution stage."""
        async def parallel_stage(data):
            import asyncio
            tasks = [f(data) for f in funcs]
            return await asyncio.gather(*tasks)
        self.stages.append({"name": "parallel", "func": parallel_stage})

    def conditional(self, condition: Callable, true_func: Callable, false_func: Callable = None):
        """Add conditional stage."""
        def conditional_stage(data):
            if condition(data):
                return true_func(data)
            elif false_func:
                return false_func(data)
            return data
        self.stages.append({"name": "conditional", "func": conditional_stage})

    def build(self) -> Callable:
        """Build the pipeline into a callable function."""
        def pipeline(input_data):
            data = input_data
            for stage in self.stages:
                data = stage["func"](data)
            return data
        return pipeline

# Usage
builder = PipelineBuilder()

@builder.stage("enumerate")
def enumerate_targets(data):
    return ["target1.example.com", "target2.example.com"]

@builder.stage("probe")
async def probe_targets(targets):
    # Probe targets
    return [{"target": t, "alive": True} for t in targets]

@builder.stage("scan")
def scan_targets(probed):
    return [{"target": p["target"], "vulns": []} for p in probed]

pipeline = builder.build()
results = pipeline(None)
```

### 8.3 Distributed Pipeline Execution

```python
# distributed_pipeline.py
import json
import asyncio
from typing import Dict, Any
from pathlib import Path
import uuid
import time

class DistributedPipeline:
    """Distributed pipeline using filesystem-based coordination."""

    def __init__(self, shared_dir: str = "distributed"):
        self.shared_dir = Path(shared_dir)
        self.shared_dir.mkdir(exist_ok=True)
        self.worker_id = str(uuid.uuid4())[:8]

    def create_task(self, task_type: str, data: Any) -> str:
        """Create a task in the shared queue."""
        task_id = str(uuid.uuid4())
        task = {
            "id": task_id,
            "type": task_type,
            "data": data,
            "created_by": self.worker_id,
            "created_at": time.time(),
            "status": "pending",
        }

        task_file = self.shared_dir / f"task_{task_id}.json"
        with open(task_file, "w") as f:
            json.dump(task, f)

        return task_id

    def claim_task(self) -> Dict:
        """Claim the next available task."""
        pending_tasks = sorted(
            self.shared_dir.glob("task_*.json"),
            key=lambda f: f.stat().st_mtime
        )

        for task_file in pending_tasks:
            with open(task_file) as f:
                task = json.load(f)

            if task["status"] == "pending":
                task["status"] = "claimed"
                task["claimed_by"] = self.worker_id
                task["claimed_at"] = time.time()

                with open(task_file, "w") as f:
                    json.dump(task, f)

                return task

        return None

    def complete_task(self, task_id: str, result: Any):
        """Mark task as complete with result."""
        task_file = self.shared_dir / f"task_{task_id}.json"
        if task_file.exists():
            with open(task_file) as f:
                task = json.load(f)

            task["status"] = "completed"
            task["completed_at"] = time.time()
            task["result"] = result

            with open(task_file, "w") as f:
                json.dump(task, f)

    def worker_loop(self, processor_func, max_tasks: int = 100):
        """Main worker loop."""
        tasks_completed = 0

        while tasks_completed < max_tasks:
            task = self.claim_task()
            if task is None:
                time.sleep(1)
                continue

            try:
                result = processor_func(task["type"], task["data"])
                self.complete_task(task["id"], result)
                tasks_completed += 1
            except Exception as e:
                print(f"Error processing task {task['id']}: {e}")

        return tasks_completed
```

---

## 9. Reporting Template

### 9.1 Pipeline Execution Report

```markdown
# Pipeline Execution Report

## Summary
- **Target**: {domain}
- **Execution ID**: {execution_id}
- **Start Time**: {start_time}
- **End Time**: {end_time}
- **Duration**: {duration}
- **Status**: {status}

## Stage Performance

| Stage | Duration | Items Processed | Items Emitted | Success Rate |
|-------|----------|-----------------|---------------|--------------|
| Subdomain Enum | 45.2s | 1,234 | 892 | 100% |
| HTTP Probe | 120.5s | 892 | 445 | 99.8% |
| URL Crawl | 300.1s | 445 | 12,456 | 100% |
| Dir Fuzz | 600.3s | 445 | 2,345 | 99.5% |
| Vuln Scan | 1800.2s | 12,456 | 15 | 100% |

## Bottlenecks Identified

1. **URL Crawl (50% of total time)**
   - Recommendation: Increase parallelism from 8 to 16
   - Expected improvement: 40% reduction

2. **Dir Fuzz (33% of total time)**
   - Recommendation: Use smarter wordlist filtering based on discovered technologies
   - Expected improvement: 25% reduction

## Resource Utilization

- **Peak Memory**: 2.3 GB
- **Average CPU**: 65%
- **Network I/O**: 450 MB
- **Disk I/O**: 120 MB

## Cache Performance

- **Total Entries**: 15,234
- **Cache Hits**: 8,456 (55.5%)
- **Cache Misses**: 6,778 (44.5%)
- **Average Hit Count**: 3.2

## Findings Summary

- **Critical**: 2
- **High**: 5
- **Medium**: 12
- **Low**: 8
- **Info**: 25

## Recommendations

1. Implement async HTTP probing to reduce probe time by 60%
2. Add intelligent wordlist filtering to reduce dir fuzz time by 40%
3. Enable content-hash caching for static resources
4. Increase parallelism for URL crawl stage
```

### 9.2 Automated Report Generator

```python
# report_generator.py
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List

class ReportGenerator:
    """Generate formatted pipeline execution reports."""

    def __init__(self, output_dir: str = "reports"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

    def generate_markdown_report(self, pipeline_data: Dict) -> str:
        """Generate markdown report from pipeline data."""
        report = f"""# Pipeline Execution Report

## Summary
- **Target**: {pipeline_data.get('target', 'Unknown')}
- **Execution ID**: {pipeline_data.get('execution_id', 'N/A')}
- **Start Time**: {pipeline_data.get('start_time', 'N/A')}
- **Duration**: {pipeline_data.get('duration', 0):.1f}s
- **Status**: {pipeline_data.get('status', 'Unknown')}

## Stage Performance

| Stage | Duration | Items In | Items Out | Status |
|-------|----------|----------|-----------|--------|
"""
        for stage in pipeline_data.get('stages', []):
            report += f"| {stage['name']} | {stage['duration']:.1f}s | {stage['items_in']} | {stage['items_out']} | {stage['status']} |\n"

        report += f"""
## Bottlenecks

"""
        for bottleneck in pipeline_data.get('bottlenecks', []):
            report += f"- **{bottleneck['stage']}**: {bottleneck['percentage']}% of total time\n"

        report += f"""
## Findings

- **Critical**: {pipeline_data.get('critical', 0)}
- **High**: {pipeline_data.get('high', 0)}
- **Medium**: {pipeline_data.get('medium', 0)}
- **Low**: {pipeline_data.get('low', 0)}

## Recommendations

"""
        for rec in pipeline_data.get('recommendations', []):
            report += f"1. {rec}\n"

        return report

    def save_report(self, pipeline_data: Dict, format: str = "markdown"):
        """Save report in specified format."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        target = pipeline_data.get('target', 'unknown')

        if format == "markdown":
            content = self.generate_markdown_report(pipeline_data)
            ext = "md"
        elif format == "json":
            content = json.dumps(pipeline_data, indent=2)
            ext = "json"
        else:
            raise ValueError(f"Unsupported format: {format}")

        filename = f"report_{target}_{timestamp}.{ext}"
        filepath = self.output_dir / filename

        with open(filepath, "w") as f:
            f.write(content)

        return str(filepath)
```

---

## 10. Quick Reference

### 10.1 Essential Commands

```bash
# Subdomain enumeration
subfinder -d example.com -silent -o subs.txt

# HTTP probing
httpx -l subs.txt -silent -json -threads 50 -o live.json

# URL crawling
katana -l live.txt -silent -d 3 -o urls.txt

# Directory fuzzing
ffuf -u http://target/FUZZ -w wordlist.txt -o results.json

# Vulnerability scanning
nuclei -l urls.txt -severity high,critical -json -o findings.json

# Port scanning
nmap -sV -sC -T4 -oX scan.xml target

# Technology detection
whatweb --color=never -q target
```

### 10.2 Python Quick Imports

```python
# Common imports for pipeline development
import asyncio
import json
import time
import hashlib
from pathlib import Path
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
from functools import wraps
from collections import defaultdict

# HTTP client
import httpx

# DNS resolution
import dns.resolver

# HTML parsing
from bs4 import BeautifulSoup

# Data processing
import pandas as pd

# Logging
import structlog
```

### 10.3 Configuration Cheat Sheet

```yaml
# Optimal settings for common scenarios

# Small target (<100 subdomains)
small_target:
  subfinder_timeout: 60
  httpx_threads: 20
  katana_depth: 2
  nuclei_rate: 50

# Medium target (100-1000 subdomains)
medium_target:
  subfinder_timeout: 300
  httpx_threads: 50
  katana_depth: 3
  nuclei_rate: 150

# Large target (>1000 subdomains)
large_target:
  subfinder_timeout: 600
  httpx_threads: 100
  katana_depth: 4
  nuclei_rate: 300
  use_parallel_pipelines: true
  enable_caching: true
```

### 10.4 Performance Benchmarks

| Operation | Sequential | Parallel (4 workers) | Parallel (16 workers) | Async (100 concurrent) |
|-----------|-----------|---------------------|----------------------|------------------------|
| HTTP Probe (1000 URLs) | 120s | 35s | 12s | 8s |
| Subdomain Enum | 45s | 45s | 45s | 45s |
| URL Crawl | 300s | 90s | 35s | 25s |
| Dir Fuzz (10K words) | 600s | 180s | 60s | N/A |

### 10.5 Troubleshooting Guide

| Problem | Cause | Solution |
|---------|-------|----------|
| High memory usage | Loading all results into memory | Use streaming/chunked processing |
| Rate limit errors | Too many requests | Implement adaptive rate limiting |
| Slow pipeline | Sequential execution | Use parallel engine |
| Duplicate results | No deduplication | Implement smart dedup |
| Cache misses | Wrong TTL settings | Adjust TTL based on content type |
| Pipeline hangs | Deadlock in DAG | Validate DAG before execution |
| Tool crashes | Resource exhaustion | Add timeout and retry logic |
| Missing results | State not saved | Implement checkpoint/resume |
