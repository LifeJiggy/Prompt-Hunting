# Automation-Efficiency 17: Performance Monitoring

## 1. Expert Role

You are a **Performance Engineering Specialist** focused on monitoring, metrics collection, profiling, and bottleneck detection for bug bounty automation pipelines. You make scan pipelines fast, observable, and measurable. You know that you cannot improve what you cannot measure, and every millisecond saved compounds across thousands of targets. Your monitoring stack tells you exactly where time is spent, where resources are consumed, and where bottlenecks form before they impact scan results.

---

## 2. Core Concepts

### 2.1 The Four Golden Signals

Adapted from Google SRE for bug bounty automation:

| Signal | What It Measures | Why It Matters |
|---|---|---|
| **Latency** | Time to complete each scan phase | Identifies slow modules |
| **Traffic** | Number of requests per second | Detects rate limit risk |
| **Errors** | Error rate per module | Pinpoints failing components |
| **Saturation** | Resource utilization (CPU, memory, connections) | Predicts capacity limits |

### 2.2 Key Performance Indicators

**Pipeline KPIs:**
- **Requests per second (RPS)**: Throughput of your scanning engine
- **P50/P95/P99 latency**: Median and tail latencies
- **Error rate**: Percentage of failed requests
- **Target coverage**: Percentage of scope scanned successfully
- **Time to first result**: How quickly initial results appear
- **Cost per scan**: Proxy costs, API credits, compute time

**Resource KPIs:**
- **CPU utilization**: Per-core and aggregate
- **Memory usage**: Working set, peak, leak detection
- **Network I/O**: Bytes sent/received, connection count
- **File descriptor usage**: Open connections, file handles
- **Disk I/O**: Log write speed, cache persistence

### 2.3 Metrics Types

- **Counter**: Monotonically increasing (total requests, total errors)
- **Gauge**: Point-in-time value (memory usage, active connections)
- **Histogram**: Distribution of values (request latency)
- **Summary**: Pre-computed quantiles (P50, P95, P99)

### 2.4 Profiling Approaches

- **CPU Profiling**: Where time is spent in code
- **Memory Profiling**: What allocates memory and potential leaks
- **I/O Profiling**: Network and disk bottlenecks
- **Async Profiling**: Event loop blocking, coroutine scheduling

### 2.5 Alerting Thresholds

| Metric | Warning | Critical | Action |
|---|---|---|---|
| Error rate | > 5% | > 20% | Investigate, add circuit breaker |
| P95 latency | > 5s | > 30s | Optimize or reduce concurrency |
| Memory usage | > 70% | > 90% | Reduce batch size, add swap |
| CPU usage | > 70% | > 95% | Reduce concurrency, profile |
| Connection count | > 500 | > 1000 | Reduce concurrency, add pooling |

---

## 3. Prerequisites

- Python 3.8+ installed
- `psutil` for system metrics
- `prometheus-client` for metrics export
- `cProfile` / `yappi` for profiling
- `memory-profiler` for memory analysis
- `locust` or `aiohttp` for load testing
- `structlog` for structured logging

**Install dependencies:**
```bash
pip install psutil prometheus-client yappi memory-profiler structlog aiohttp
```

---

## 4. Methodology

### Step 1: Establish Baseline Metrics

Before optimizing, measure current performance:
1. Run a standard scan against a test target
2. Record all four golden signals
3. Save baseline for comparison

### Step 2: Instrument the Pipeline

Add metrics collection to every module:
- Timer decorators around key functions
- Counter increments for success/failure
- Gauge updates for resource usage
- Histogram recordings for latency distributions

### Step 3: Profile the Hot Path

Run profiling on the most time-consuming modules:
1. CPU profiling to find computation bottlenecks
2. Memory profiling to find leaks
3. I/O profiling to find network bottlenecks

### Step 4: Analyze Bottlenecks

Rank bottlenecks by impact:
1. Which module takes the most time?
2. Where is time spent waiting vs computing?
3. What is the concurrency limit before degradation?

### Step 5: Optimize and Re-Measure

Apply optimizations and verify improvement:
1. Make one change at a time
2. Re-run the same benchmark
3. Compare against baseline
4. Keep changes that show measurable improvement

### Step 6: Set Up Continuous Monitoring

Build dashboards and alerts:
1. Real-time metrics during scans
2. Historical trend analysis
3. Automated alerting on degradation
4. Post-scan performance reports

### Step 7: Automate Performance Regression Detection

Run performance tests in CI:
1. Benchmark critical paths
2. Fail CI if performance degrades beyond threshold
3. Track performance over time

---

## 5. Tool Arsenal with Commands

### 5.1 Metrics Collection Framework

```python
import time
import psutil
import threading
from dataclasses import dataclass, field
from typing import Dict, List
from collections import defaultdict
from contextlib import contextmanager


@dataclass
class MetricPoint:
    timestamp: float
    value: float
    labels: Dict[str, str] = field(default_factory=dict)


class MetricsCollector:
    def __init__(self):
        self.counters = defaultdict(float)
        self.gauges = {}
        self.histograms = defaultdict(list)
        self._lock = threading.Lock()
        self.start_time = time.time()

    def increment(self, name: str, value: float = 1, labels: Dict[str, str] = None):
        with self._lock:
            key = self._make_key(name, labels)
            self.counters[key] += value

    def gauge(self, name: str, value: float, labels: Dict[str, str] = None):
        with self._lock:
            key = self._make_key(name, labels)
            self.gauges[key] = value

    def histogram(self, name: str, value: float, labels: Dict[str, str] = None):
        with self._lock:
            key = self._make_key(name, labels)
            self.histograms[key].append(value)

    @contextmanager
    def timer(self, name: str, labels: Dict[str, str] = None):
        start = time.monotonic()
        try:
            yield
        finally:
            elapsed = time.monotonic() - start
            self.histogram(name, elapsed, labels)
            self.increment(f"{name}_count", labels=labels)

    def _make_key(self, name: str, labels: Dict[str, str] = None) -> str:
        if labels:
            label_str = ",".join(f"{k}={v}" for k, v in sorted(labels.items()))
            return f"{name}{{{label_str}}}"
        return name

    def get_summary(self) -> dict:
        with self._lock:
            summary = {
                "uptime_seconds": time.time() - self.start_time,
                "counters": dict(self.counters),
                "gauges": dict(self.gauges),
                "histograms": {},
            }
            for name, values in self.histograms.items():
                if values:
                    sorted_vals = sorted(values)
                    summary["histograms"][name] = {
                        "count": len(values),
                        "min": min(values),
                        "max": max(values),
                        "mean": sum(values) / len(values),
                        "p50": sorted_vals[len(sorted_vals) // 2],
                        "p95": sorted_vals[int(len(sorted_vals) * 0.95)],
                        "p99": sorted_vals[int(len(sorted_vals) * 0.99)],
                    }
            return summary


# Global metrics instance
metrics = MetricsCollector()
```

### 5.2 System Resource Monitor

```python
import psutil
import asyncio
from datetime import datetime


class ResourceMonitor:
    def __init__(self, interval: float = 5.0):
        self.interval = interval
        self.running = False
        self.history = []
        self.process = psutil.Process()

    async def start(self):
        self.running = True
        while self.running:
            snapshot = self._collect()
            self.history.append(snapshot)
            metrics.gauge("cpu_percent", snapshot["cpu_percent"])
            metrics.gauge("memory_percent", snapshot["memory_percent"])
            metrics.gauge("memory_mb", snapshot["memory_mb"])
            metrics.gauge("open_files", snapshot["open_files"])
            metrics.gauge("threads", snapshot["threads"])
            await asyncio.sleep(self.interval)

    def stop(self):
        self.running = False

    def _collect(self) -> dict:
        cpu = psutil.cpu_percent(interval=0.1)
        mem = psutil.virtual_memory()
        proc_mem = self.process.memory_info()
        return {
            "timestamp": datetime.utcnow().isoformat(),
            "cpu_percent": cpu,
            "memory_percent": mem.percent,
            "memory_mb": proc_mem.rss / (1024 * 1024),
            "open_files": len(self.process.open_files()),
            "threads": self.process.num_threads(),
            "net_io": psutil.net_io_counters()._asdict(),
        }

    def get_peak_usage(self) -> dict:
        if not self.history:
            return {}
        return {
            "peak_cpu": max(h["cpu_percent"] for h in self.history),
            "peak_memory_mb": max(h["memory_mb"] for h in self.history),
            "peak_threads": max(h["threads"] for h in self.history),
            "samples": len(self.history),
        }
```

### 5.3 Request-Level Performance Tracker

```python
import time
from contextlib import asynccontextmanager
from dataclasses import dataclass
from typing import Optional


@dataclass
class RequestMetrics:
    url: str
    method: str
    status_code: Optional[int]
    latency_ms: float
    bytes_sent: int
    bytes_received: int
    error: Optional[str]
    timestamp: float


class RequestTracker:
    def __init__(self):
        self.requests: List[RequestMetrics] = []
        self._active = {}

    def start_request(self, request_id: str, url: str, method: str = "GET"):
        self._active[request_id] = {
            "url": url,
            "method": method,
            "start_time": time.monotonic(),
            "start_real": time.time(),
        }

    def end_request(self, request_id: str, status_code: int = None,
                    bytes_sent: int = 0, bytes_received: int = 0,
                    error: str = None):
        if request_id not in self._active:
            return

        info = self._active.pop(request_id)
        latency_ms = (time.monotonic() - info["start_time"]) * 1000

        req_metrics = RequestMetrics(
            url=info["url"],
            method=info["method"],
            status_code=status_code,
            latency_ms=latency_ms,
            bytes_sent=bytes_sent,
            bytes_received=bytes_received,
            error=error,
            timestamp=info["start_real"],
        )
        self.requests.append(req_metrics)

        labels = {"method": info["method"], "status": str(status_code or "error")}
        metrics.histogram("request_latency_ms", latency_ms, labels)
        metrics.increment("requests_total", labels=labels)
        metrics.increment("bytes_sent", bytes_sent)
        metrics.increment("bytes_received", bytes_received)

    @asynccontextmanager
    async def track(self, url: str, method: str = "GET"):
        request_id = f"{url}_{time.monotonic()}"
        self.start_request(request_id, url, method)
        try:
            yield request_id
            self.end_request(request_id, status_code=200)
        except Exception as e:
            self.end_request(request_id, error=str(e))
            raise

    def get_stats(self) -> dict:
        if not self.requests:
            return {"total_requests": 0}
        latencies = [r.latency_ms for r in self.requests]
        errors = [r for r in self.requests if r.error or (r.status_code and r.status_code >= 400)]
        return {
            "total_requests": len(self.requests),
            "error_rate": len(errors) / len(self.requests),
            "avg_latency_ms": sum(latencies) / len(latencies),
            "p95_latency_ms": sorted(latencies)[int(len(latencies) * 0.95)],
            "total_bytes_sent": sum(r.bytes_sent for r in self.requests),
            "total_bytes_received": sum(r.bytes_received for r in self.requests),
        }
```

### 5.4 CPU Profiler

```python
import yappi
import json
from datetime import datetime


class CPUProfiler:
    def __init__(self):
        self.running = False

    def start(self):
        yappi.set_clock_type("wall")
        yappi.start()
        self.running = True

    def stop(self):
        yappi.stop()
        self.running = False

    def get_top_functions(self, n: int = 20) -> list:
        stats = yappi.get_func_stats()
        stats.sort("ttot", "desc")
        results = []
        for i, stat in enumerate(stats[:n]):
            results.append({
                "rank": i + 1,
                "name": stat.full_name,
                "ncalls": stat.ncall,
                "total_time_ms": stat.ttot * 1000,
                "own_time_ms": stat.own * 1000,
                "avg_time_ms": (stat.ttot / stat.ncall * 1000) if stat.ncall else 0,
            })
        return results

    def get_thread_stats(self) -> list:
        threads = yappi.get_thread_stats()
        return [
            {
                "id": t.id,
                "name": t.name,
                "total_time_ms": t.ttot * 1000,
                "ctx_switches": t.ctsw,
                "call_count": t.sched_count,
            }
            for t in threads
        ]

    def export_report(self, filepath: str):
        report = {
            "timestamp": datetime.utcnow().isoformat(),
            "top_functions": self.get_top_functions(50),
            "thread_stats": self.get_thread_stats(),
        }
        with open(filepath, "w") as f:
            json.dump(report, f, indent=2)
        yappi.clear_stats()
```

### 5.5 Memory Profiler

```python
from memory_profiler import memory_usage
from functools import wraps
import tracemalloc
import gc


class MemoryProfiler:
    def __init__(self):
        self.snapshots = []
        tracemalloc.start()

    def take_snapshot(self, label: str = ""):
        snapshot = tracemalloc.take_snapshot()
        stats = snapshot.statistics("lineno")
        self.snapshots.append({
            "label": label,
            "timestamp": time.time(),
            "stats": [
                {"file": s.traceback.format()[0], "size_kb": s.size / 1024}
                for s in stats[:20]
            ],
        })

    def get_top_allocations(self, n: int = 20) -> list:
        snapshot = tracemalloc.take_snapshot()
        stats = snapshot.statistics("lineno")
        return [
            {
                "location": str(stat.traceback),
                "size_kb": stat.size / 1024,
                "count": stat.count,
            }
            for stat in stats[:n]
        ]

    def check_leaks(self) -> list:
        gc.collect()
        snapshot = tracemalloc.take_snapshot()
        stats = snapshot.statistics("filename")
        return [
            {
                "file": stat.traceback.format()[0],
                "size_kb": stat.size / 1024,
                "count": stat.count,
            }
            for stat in stats
            if stat.size > 1024 * 1024
        ]

    def measure_function(self, func, *args, **kwargs):
        mem_before = memory_usage()[0]
        result = func(*args, **kwargs)
        mem_after = memory_usage()[0]
        return {
            "result": result,
            "memory_delta_mb": mem_after - mem_before,
        }
```

### 5.6 Prometheus Metrics Exporter

```python
from prometheus_client import (
    Counter,
    Histogram,
    Gauge,
    start_http_server,
    CollectorRegistry,
    REGISTRY,
)

REQUEST_COUNT = Counter(
    "scan_requests_total",
    "Total scan requests",
    ["method", "target", "status"],
)

REQUEST_LATENCY = Histogram(
    "scan_request_latency_seconds",
    "Request latency",
    ["method", "target"],
    buckets=[0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0, 30.0],
)

ACTIVE_CONNECTIONS = Gauge(
    "scan_active_connections",
    "Current active connections",
)

ERROR_COUNT = Counter(
    "scan_errors_total",
    "Total errors",
    ["error_type", "module"],
)


def start_metrics_server(port: int = 9090):
    start_http_server(port)
    print(f"Metrics server started on port {port}")
```

---

## 6. Real-World Examples

### 6.1 Full Scan Performance Report

```python
class ScanPerformanceReport:
    def __init__(self, scan_name: str, metrics_collector: MetricsCollector):
        self.scan_name = scan_name
        self.collector = metrics_collector
        self.start_time = time.time()

    def generate(self) -> dict:
        summary = self.collector.get_summary()
        elapsed = time.time() - self.start_time

        return {
            "scan_name": self.scan_name,
            "duration_seconds": elapsed,
            "throughput": {
                "requests_per_second": summary["counters"].get("requests_total", 0) / elapsed if elapsed > 0 else 0,
            },
            "latency": summary.get("histograms", {}).get("request_latency_ms", {}),
            "errors": {
                "total": summary["counters"].get("errors_total", 0),
                "rate": summary["counters"].get("errors_total", 0) / max(summary["counters"].get("requests_total", 1), 1),
            },
            "resources": {
                "peak_cpu_percent": summary["gauges"].get("cpu_percent", 0),
                "peak_memory_mb": summary["gauges"].get("memory_mb", 0),
            },
        }

    def print_report(self):
        report = self.generate()
        print(f"\n{'='*60}")
        print(f"  Performance Report: {report['scan_name']}")
        print(f"{'='*60}")
        print(f"  Duration: {report['duration_seconds']:.1f}s")
        print(f"  Throughput: {report['throughput']['requests_per_second']:.1f} req/s")
        latency = report.get("latency", {})
        print(f"  Latency P50: {latency.get('p50', 0)*1000:.0f}ms")
        print(f"  Latency P95: {latency.get('p95', 0)*1000:.0f}ms")
        print(f"  Latency P99: {latency.get('p99', 0)*1000:.0f}ms")
        print(f"  Error Rate: {report['errors']['rate']*100:.1f}%")
        print(f"  Peak Memory: {report['resources']['peak_memory_mb']:.1f}MB")
        print(f"{'='*60}\n")
        return report
```

### 6.2 Concurrency Benchmark

```python
class ConcurrencyBenchmark:
    def __init__(self, target_url: str):
        self.target_url = target_url
        self.results = []

    async def run_single(self, concurrency: int, duration: float = 30) -> dict:
        semaphore = asyncio.Semaphore(concurrency)
        tracker = RequestTracker()
        start_time = time.time()
        request_count = 0

        async def make_request():
            nonlocal request_count
            async with semaphore:
                async with aiohttp.ClientSession() as session:
                    async with tracker.track(self.target_url) as req_id:
                        async with session.get(self.target_url) as resp:
                            await resp.read()
                            request_count += 1

        tasks = []
        while time.time() - start_time < duration:
            tasks.append(asyncio.create_task(make_request()))
            await asyncio.sleep(0.01)

        await asyncio.gather(*tasks, return_exceptions=True)
        elapsed = time.time() - start_time
        stats = tracker.get_stats()

        result = {
            "concurrency": concurrency,
            "duration_seconds": elapsed,
            "total_requests": request_count,
            "requests_per_second": request_count / elapsed,
            "avg_latency_ms": stats.get("avg_latency_ms", 0),
            "error_rate": stats.get("error_rate", 0),
        }
        self.results.append(result)
        return result

    async def run_benchmark(self, concurrency_levels: list = None):
        if concurrency_levels is None:
            concurrency_levels = [1, 5, 10, 25, 50, 100]

        for c in concurrency_levels:
            print(f"Testing concurrency={c}...")
            result = await self.run_single(c, duration=15)
            print(f"  RPS: {result['requests_per_second']:.1f}, "
                  f"Latency: {result['avg_latency_ms']:.0f}ms, "
                  f"Errors: {result['error_rate']*100:.1f}%")
            await asyncio.sleep(5)

        optimal = max(self.results, key=lambda x: x["requests_per_second"])
        print(f"\nOptimal concurrency: {optimal['concurrency']}")
        return self.results
```

### 6.3 Real-Time Dashboard (Terminal)

```python
import os
import time


class TerminalDashboard:
    def __init__(self, metrics_collector: MetricsCollector):
        self.collector = metrics_collector

    def render(self):
        os.system("cls" if os.name == "nt" else "clear")
        summary = self.collector.get_summary()

        print(f"{'='*70}")
        print(f"  SCAN PERFORMANCE DASHBOARD")
        print(f"{'='*70}")
        print(f"  Uptime: {summary['uptime_seconds']:.0f}s")
        print(f"{'='*70}")

        print(f"\n  COUNTERS:")
        for name, value in summary.get("counters", {}).items():
            print(f"    {name}: {value}")

        print(f"\n  GAUGES:")
        for name, value in summary.get("gauges", {}).items():
            print(f"    {name}: {value}")

        print(f"\n  HISTOGRAMS:")
        for name, stats in summary.get("histograms", {}).items():
            print(f"    {name}:")
            print(f"      Count: {stats['count']}")
            print(f"      Mean: {stats['mean']*1000:.1f}ms")
            print(f"      P50: {stats['p50']*1000:.1f}ms")
            print(f"      P95: {stats['p95']*1000:.1f}ms")
            print(f"      P99: {stats['p99']*1000:.1f}ms")

        print(f"\n{'='*70}")
```

---

## 7. Common Pitfalls

| Pitfall | Problem | Solution |
|---|---|---|
| **Measuring too much** | Metrics overload obscures important signals | Focus on the four golden signals |
| **Not establishing baseline** | Cannot quantify improvement | Always measure before optimizing |
| **Optimizing the wrong thing** | Micro-optimizing slow code | Profile first, optimize the biggest bottleneck |
| **Ignoring tail latency** | P50 looks good but P99 is terrible | Always check P95 and P99 |
| **Synchronous metrics** | Metrics collection slows the pipeline | Use async/non-blocking collection |
| **No time-series storage** | Cannot spot trends over time | Store metrics with timestamps |
| **Alert fatigue** | Too many alerts, all ignored | Set meaningful thresholds, alert on trends |
| **Profiling in production** | Profiler overhead impacts results | Profile representative test runs |

---

## 8. Advanced Techniques

### 8.1 Distributed Tracing

```python
import uuid
import time
from contextlib import contextmanager
from typing import Dict, Optional


class Span:
    def __init__(self, trace_id: str, span_id: str, name: str, parent_id: Optional[str] = None):
        self.trace_id = trace_id
        self.span_id = span_id
        self.name = name
        self.parent_id = parent_id
        self.start_time = time.monotonic()
        self.end_time = None
        self.attributes = {}
        self.events = []

    def set_attribute(self, key: str, value):
        self.attributes[key] = value

    def add_event(self, name: str, attributes: Dict = None):
        self.events.append({
            "name": name,
            "timestamp": time.time(),
            "attributes": attributes or {},
        })

    def finish(self):
        self.end_time = time.monotonic()

    @property
    def duration_ms(self) -> float:
        if self.end_time:
            return (self.end_time - self.start_time) * 1000
        return (time.monotonic() - self.start_time) * 1000

    def to_dict(self) -> dict:
        return {
            "trace_id": self.trace_id,
            "span_id": self.span_id,
            "name": self.name,
            "parent_id": self.parent_id,
            "duration_ms": self.duration_ms,
            "attributes": self.attributes,
            "events": self.events,
        }


class Tracer:
    def __init__(self):
        self.spans = []
        self._context = {}

    def start_trace(self, name: str) -> Span:
        trace_id = str(uuid.uuid4())
        span = Span(trace_id, str(uuid.uuid4()), name)
        self.spans.append(span)
        self._context["current"] = span
        return span

    @contextmanager
    def span(self, name: str, parent: Span = None):
        trace_id = parent.trace_id if parent else str(uuid.uuid4())
        span = Span(trace_id, str(uuid.uuid4()), name, parent.span_id if parent else None)
        self.spans.append(span)
        old_current = self._context.get("current")
        self._context["current"] = span
        try:
            yield span
        finally:
            span.finish()
            self._context["current"] = old_current

    def export_trace(self) -> list:
        return [s.to_dict() for s in self.spans]
```

### 8.2 Performance Regression Detection

```python
class RegressionDetector:
    def __init__(self, baseline_file: str = "baseline_metrics.json"):
        self.baseline_file = baseline_file
        self.baseline = self._load_baseline()

    def _load_baseline(self) -> dict:
        try:
            with open(self.baseline_file) as f:
                return json.load(f)
        except FileNotFoundError:
            return {}

    def save_baseline(self, metrics: dict):
        with open(self.baseline_file, "w") as f:
            json.dump(metrics, f, indent=2)
        self.baseline = metrics

    def check_regression(self, current: dict, threshold: float = 0.2) -> list:
        regressions = []
        for key, current_value in current.items():
            if key in self.baseline:
                baseline_value = self.baseline[key]
                if baseline_value > 0:
                    change = (current_value - baseline_value) / baseline_value
                    if change > threshold:
                        regressions.append({
                            "metric": key,
                            "baseline": baseline_value,
                            "current": current_value,
                            "change_percent": change * 100,
                        })
        return regressions
```

---

## 9. Reporting Template

```markdown
# Performance Report - [Scan Name]

## Scan Parameters
- **Target Scope**: X subdomains, Y URLs
- **Concurrency Level**: X
- **Duration**: X minutes
- **Date**: YYYY-MM-DD

## Throughput Summary
| Metric | Value | Target | Status |
|---|---|---|---|
| Requests/Second | X | > 50 | PASS/FAIL |
| Total Requests | X | - | - |
| Successful Requests | X (XX%) | > 95% | PASS/FAIL |
| Average Latency | Xms | < 2000ms | PASS/FAIL |

## Latency Distribution
| Percentile | Latency (ms) | Threshold | Status |
|---|---|---|---|
| P50 | X | < 500ms | PASS/FAIL |
| P75 | X | < 1000ms | PASS/FAIL |
| P90 | X | < 2000ms | PASS/FAIL |
| P95 | X | < 5000ms | PASS/FAIL |
| P99 | X | < 10000ms | PASS/FAIL |

## Resource Utilization
| Resource | Peak | Average | Limit | Status |
|---|---|---|---|---|
| CPU | X% | X% | 80% | PASS/FAIL |
| Memory | XMB | XMB | 1GB | PASS/FAIL |
| Connections | X | X | 1000 | PASS/FAIL |
| File Descriptors | X | X | 4096 | PASS/FAIL |

## Bottleneck Analysis
| Bottleneck | Impact | Recommendation |
|---|---|---|
| [Module] latency | X% of total time | Optimize or parallelize |
| Rate limiting | X requests blocked | Reduce concurrency |
| DNS resolution | Xms average | Cache DNS results |

## Comparison with Previous Scan
| Metric | Previous | Current | Change |
|---|---|---|---|
| RPS | X | X | +X% |
| P95 Latency | Xms | Xms | -X% |
| Error Rate | X% | X% | -X% |

## Recommendations
1. Increase concurrency from X to Y (based on benchmark)
2. Optimize [module] - currently X% of total time
3. Add connection pooling for [service]
4. Enable DNS caching to reduce resolution time
```

---

## 10. Quick Reference

### Performance Monitoring Commands

```bash
# Install monitoring tools
pip install psutil prometheus-client yappi memory-profiler

# Run memory profiler on a script
python -m memory_profiler scan_script.py

# CPU profile a function
python -c "
import yappi
yappi.start()
# call your function
yappi.get_func_stats().sort('ttot', 'desc').print_all()
"

# Monitor system resources in real-time
python -c "
import psutil, time
while True:
    print(f'CPU: {psutil.cpu_percent()}%  Mem: {psutil.virtual_memory().percent}%')
    time.sleep(1)
"

# Export Prometheus metrics
python -c "from prometheus_client import start_http_server; start_http_server(9090)"
```

### Latency Thresholds

| Operation | Acceptable | Warning | Critical |
|---|---|---|---|
| HTTP GET | < 1s | 1-3s | > 3s |
| DNS Resolution | < 100ms | 100-500ms | > 500ms |
| TLS Handshake | < 200ms | 200-500ms | > 500ms |
| JSON Parse | < 10ms | 10-100ms | > 100ms |
| Database Query | < 50ms | 50-200ms | > 200ms |
| File Write | < 10ms | 10-50ms | > 50ms |

### Key Libraries

```bash
# System metrics
pip install psutil

# Profiling
pip install yappi memory-profiler line-profiler

# Metrics export
pip install prometheus-client statsd

# Load testing
pip install locust aiohttp

# Structured logging
pip install structlog python-json-logger
```

---

*This guide provides a complete performance monitoring framework for bug bounty automation. Measure first, optimize based on data, and continuously monitor for regressions.*
