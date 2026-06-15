# Automation-Efficiency 18: Scalability Design Patterns

## 1. Expert Role

You are a **Distributed Systems Architect** specializing in scalability, horizontal and vertical scaling, load balancing, and queue-based patterns for bug bounty automation. You design systems that can scan thousands of targets in parallel, distribute work across workers, and scale from a single laptop to a cloud fleet. You understand that scalability is not just about speed — it is about maintaining reliability, accuracy, and cost efficiency as the system grows.

---

## 2. Core Concepts

### 2.1 Horizontal vs Vertical Scaling

| Dimension | Vertical (Scale Up) | Horizontal (Scale Out) |
|---|---|---|
| **Mechanism** | Add more CPU/RAM to one machine | Add more machines |
| **Cost Curve** | Exponential (bigger hardware) | Linear (more commodity hardware) |
| **Limit** | Hardware ceiling | Theoretically unlimited |
| **Complexity** | Low | High (coordination, state) |
| **Best For** | Single-threaded tools, small scans | Large-scale parallel scanning |
| **Failure Mode** | Single point of failure | Graceful degradation |

### 2.2 Queue-Based Architecture

**Core Pattern: Producer-Worker-Consumer**

```
[Target List] --> [Queue] --> [Worker Pool] --> [Results Store]
     Producer        Buffer        Consumers        Output
```

**Queue Types:**
- **FIFO**: Simple ordering, fair distribution
- **Priority**: Critical targets first
- **Fan-out**: Multiple worker groups processing same queue
- **Dead letter**: Items that fail repeatedly

### 2.3 Load Balancing Strategies

| Strategy | Algorithm | Best For |
|---|---|---|
| **Round Robin** | Sequential assignment | Equal-capacity workers |
| **Least Connections** | Assign to worker with fewest active tasks | Variable-latency tasks |
| **Random** | Random assignment | Simple, statistically balanced |
| **Weighted** | Assign based on worker capacity | Mixed-capacity workers |
| **Consistent Hashing** | Hash-based assignment | Stateful workloads |

### 2.4 Backpressure Management

When workers cannot keep up with incoming work:
- **Buffering**: Queue work until workers catch up
- **Throttling**: Slow down producers
- **Dropping**: Discard low-priority work
- **Scaling**: Add more workers dynamically

### 2.5 Data Partitioning

Split targets across workers:
- **By IP range**: Each worker handles a subset of IPs
- **By subdomain**: Hash-based distribution
- **By target type**: Web, API, mobile in separate workers
- **By geography**: Region-based assignment

---

## 3. Prerequisites

- Python 3.8+ installed
- `asyncio` for concurrent operations
- `aiohttp` for async HTTP
- `celery` or `rq` for distributed task queues
- `redis` as message broker
- `docker` for containerized workers
- Understanding of async/await patterns

**Install dependencies:**
```bash
pip install aiohttp celery redis rq docker psutil
```

---

## 4. Methodology

### Step 1: Profile Current Capacity

Measure what a single machine can handle:
1. Maximum concurrent connections
2. Requests per second at different concurrency levels
3. Memory usage per concurrent task
4. CPU utilization at peak

### Step 2: Identify Bottlenecks

Determine what limits current throughput:
- Network bandwidth?
- CPU for TLS/JSON parsing?
- Memory for holding results?
- Rate limits on target?
- Disk I/O for logging?

### Step 3: Design Queue Architecture

Choose the right pattern:
- Single machine: asyncio task queue
- Multiple machines: Celery + Redis
- Cloud-native: AWS SQS / Google Pub/Sub

### Step 4: Implement Worker Pool

Build workers that:
- Pull tasks from queue
- Process with controlled concurrency
- Report progress back to queue
- Store results in shared store

### Step 5: Add Load Balancing

Distribute work across workers:
- Implement health checks
- Add capacity-aware routing
- Handle worker failures gracefully

### Step 6: Implement Auto-Scaling

Scale workers based on:
- Queue depth (number of pending tasks)
- Worker CPU/memory utilization
- Request rate vs target capacity
- Time of day patterns

### Step 7: Test at Scale

Validate the system handles load:
- Run load tests with simulated targets
- Verify no data loss under high concurrency
- Measure latency at scale
- Test failure recovery

---

## 5. Tool Arsenal with Commands

### 5.1 Async Task Queue (Single Machine)

```python
import asyncio
import aiohttp
from dataclasses import dataclass, field
from typing import Any, Callable, Awaitable, Optional
from collections import deque
import time
import logging

logger = logging.getLogger(__name__)


@dataclass
class Task:
    id: str
    func: Callable[..., Awaitable[Any]]
    args: tuple = ()
    kwargs: dict = field(default_factory=dict)
    priority: int = 0
    created_at: float = field(default_factory=time.time)
    attempts: int = 0
    max_attempts: int = 3
    result: Any = None
    error: Optional[str] = None
    status: str = "pending"


class AsyncTaskQueue:
    def __init__(self, max_concurrent: int = 50, max_queue_size: int = 10000):
        self.max_concurrent = max_concurrent
        self.max_queue_size = max_queue_size
        self.queue: deque = deque()
        self.results = {}
        self.active_tasks = 0
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self._running = False
        self._workers = []

    async def add_task(self, task: Task) -> str:
        if len(self.queue) >= self.max_queue_size:
            raise QueueFullError(f"Queue full ({self.max_queue_size} tasks)")
        self.queue.append(task)
        logger.info(f"Task {task.id} added to queue (position: {len(self.queue)})")
        return task.id

    async def start(self, num_workers: int = 5):
        self._running = True
        self._workers = [
            asyncio.create_task(self._worker(i))
            for i in range(num_workers)
        ]
        logger.info(f"Started {num_workers} workers")

    async def stop(self):
        self._running = False
        for worker in self._workers:
            worker.cancel()
        await asyncio.gather(*self._workers, return_exceptions=True)
        logger.info("All workers stopped")

    async def _worker(self, worker_id: int):
        while self._running:
            if not self.queue:
                await asyncio.sleep(0.1)
                continue

            task = self.queue.popleft()
            async with self.semaphore:
                self.active_tasks += 1
                try:
                    task.attempts += 1
                    task.status = "running"
                    result = await task.func(*task.args, **task.kwargs)
                    task.result = result
                    task.status = "completed"
                    self.results[task.id] = result
                    logger.info(f"Task {task.id} completed by worker {worker_id}")
                except Exception as e:
                    task.error = str(e)
                    task.status = "failed"
                    if task.attempts < task.max_attempts:
                        self.queue.append(task)
                        logger.warning(f"Task {task.id} failed, retrying ({task.attempts}/{task.max_attempts})")
                    else:
                        logger.error(f"Task {task.id} failed permanently: {e}")
                finally:
                    self.active_tasks -= 1

    def get_stats(self) -> dict:
        return {
            "queue_size": len(self.queue),
            "active_tasks": self.active_tasks,
            "completed": sum(1 for t in self.results.values()),
            "max_concurrent": self.max_concurrent,
        }


class QueueFullError(Exception):
    pass
```

### 5.2 Distributed Worker with Celery

```python
from celery import Celery
from celery.signals import worker_init
import json
import time

app = Celery(
    "scan_workers",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/1",
)

app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_acks_late=True,
    worker_prefetch_multiplier=1,
    task_routes={
        "scan.subdomain": {"queue": "subdomain"},
        "scan.port": {"queue": "port"},
        "scan.vuln": {"queue": "vuln"},
    },
)


@app.task(bind=True, max_retries=3, default_retry_delay=60)
def scan_subdomain(self, target: str):
    try:
        import subprocess
        result = subprocess.run(
            ["python", "-m", "subfinder", "-d", target, "-silent"],
            capture_output=True,
            text=True,
            timeout=300,
        )
        subdomains = result.stdout.strip().split("\n")
        return {
            "target": target,
            "subdomains": subdomains,
            "count": len(subdomains),
            "timestamp": time.time(),
        }
    except subprocess.TimeoutExpired:
        raise self.retry(exc=Exception("Scan timeout"))
    except Exception as e:
        raise self.retry(exc=e)


@app.task(bind=True, max_retries=3)
def scan_port(self, target: str, ports: list = None):
    if ports is None:
        ports = [80, 443, 8080, 8443, 3000, 5000]
    try:
        import socket
        open_ports = []
        for port in ports:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(2)
            result = sock.connect_ex((target, port))
            if result == 0:
                open_ports.append(port)
            sock.close()
        return {
            "target": target,
            "open_ports": open_ports,
            "timestamp": time.time(),
        }
    except Exception as e:
        raise self.retry(exc=e)


@app.task
def aggregate_results(scan_id: str, results: list):
    total_subdomains = sum(r.get("count", 0) for r in results)
    all_ports = set()
    for r in results:
        all_ports.update(r.get("open_ports", []))
    return {
        "scan_id": scan_id,
        "total_subdomains": total_subdomains,
        "unique_open_ports": list(all_ports),
        "completed_at": time.time(),
    }
```

### 5.3 Worker Pool with Auto-Scaling

```python
import asyncio
import psutil
from typing import Callable, Awaitable
from dataclasses import dataclass


@dataclass
class WorkerConfig:
    min_workers: int = 2
    max_workers: int = 20
    scale_up_threshold: float = 0.8
    scale_down_threshold: float = 0.3
    check_interval: float = 10.0
    task_timeout: float = 300.0


class AutoScalingPool:
    def __init__(self, config: WorkerConfig = None):
        self.config = config or WorkerConfig()
        self.workers = {}
        self.task_queue = asyncio.Queue()
        self.current_workers = 0
        self.running = False

    async def start(self):
        self.running = True
        for _ in range(self.config.min_workers):
            await self._spawn_worker()
        asyncio.create_task(self._autoscaler())
        asyncio.create_task(self._monitor())

    async def _spawn_worker(self):
        worker_id = f"worker-{self.current_workers}"
        task = asyncio.create_task(self._worker_loop(worker_id))
        self.workers[worker_id] = {
            "task": task,
            "active": False,
            "tasks_completed": 0,
            "started_at": time.time(),
        }
        self.current_workers += 1
        logger.info(f"Spawned worker {worker_id} (total: {self.current_workers})")

    async def _worker_loop(self, worker_id: str):
        while self.running:
            try:
                task_data = await asyncio.wait_for(
                    self.task_queue.get(), timeout=5.0
                )
                self.workers[worker_id]["active"] = True
                try:
                    result = await asyncio.wait_for(
                        task_data["func"](*task_data["args"], **task_data["kwargs"]),
                        timeout=self.config.task_timeout,
                    )
                    task_data["future"].set_result(result)
                    self.workers[worker_id]["tasks_completed"] += 1
                except asyncio.TimeoutError:
                    task_data["future"].set_exception(
                        Exception(f"Task timeout after {self.config.task_timeout}s")
                    )
                except Exception as e:
                    task_data["future"].set_exception(e)
                finally:
                    self.workers[worker_id]["active"] = False
            except asyncio.TimeoutError:
                continue

    async def _autoscaler(self):
        while self.running:
            await asyncio.sleep(self.config.check_interval)
            utilization = self._get_utilization()
            queue_depth = self.task_queue.qsize()

            if queue_depth > 0 and utilization > self.config.scale_up_threshold:
                if self.current_workers < self.config.max_workers:
                    await self._spawn_worker()
            elif utilization < self.config.scale_down_threshold:
                if self.current_workers > self.config.min_workers:
                    await self._remove_worker()

    def _get_utilization(self) -> float:
        if not self.workers:
            return 0.0
        active = sum(1 for w in self.workers.values() if w["active"])
        return active / len(self.workers)

    async def _remove_worker(self):
        for worker_id, info in self.workers.items():
            if not info["active"]:
                info["task"].cancel()
                del self.workers[worker_id]
                self.current_workers -= 1
                logger.info(f"Removed worker {worker_id} (total: {self.current_workers})")
                break

    async def submit(self, func: Callable[..., Awaitable], *args, **kwargs):
        future = asyncio.get_event_loop().create_future()
        await self.task_queue.put({
            "func": func,
            "args": args,
            "kwargs": kwargs,
            "future": future,
        })
        return await future

    def get_stats(self) -> dict:
        return {
            "total_workers": self.current_workers,
            "active_workers": sum(1 for w in self.workers.values() if w["active"]),
            "queue_depth": self.task_queue.qsize(),
            "utilization": self._get_utilization(),
            "total_completed": sum(w["tasks_completed"] for w in self.workers.values()),
        }
```

### 5.4 Consistent Hashing for Target Distribution

```python
import hashlib
from bisect import bisect_right
from typing import Any


class ConsistentHashRing:
    def __init__(self, nodes: list = None, virtual_nodes: int = 150):
        self.virtual_nodes = virtual_nodes
        self.ring = {}
        self.sorted_keys = []
        self.nodes = set()
        if nodes:
            for node in nodes:
                self.add_node(node)

    def _hash(self, key: str) -> int:
        return int(hashlib.md5(key.encode()).hexdigest(), 16)

    def add_node(self, node: Any):
        self.nodes.add(node)
        for i in range(self.virtual_nodes):
            key = self._hash(f"{node}:v{i}")
            self.ring[key] = node
            self.sorted_keys.append(key)
        self.sorted_keys.sort()

    def remove_node(self, node: Any):
        self.nodes.discard(node)
        for i in range(self.virtual_nodes):
            key = self._hash(f"{node}:v{i}")
            if key in self.ring:
                del self.ring[key]
                self.sorted_keys.remove(key)

    def get_node(self, item: str) -> Any:
        if not self.ring:
            return None
        key = self._hash(item)
        idx = bisect_right(self.sorted_keys, key) % len(self.sorted_keys)
        return self.ring[self.sorted_keys[idx]]

    def get_distribution(self) -> dict:
        distribution = {node: 0 for node in self.nodes}
        test_items = [f"target-{i}" for i in range(10000)]
        for item in test_items:
            node = self.get_node(item)
            if node:
                distribution[node] += 1
        return distribution
```

### 5.5 Result Aggregator with Redis

```python
import redis
import json
from datetime import datetime


class DistributedResultStore:
    def __init__(self, redis_url: str = "redis://localhost:6379"):
        self.redis = redis.from_url(redis_url)
        self.results_key = "scan:results"
        self.progress_key = "scan:progress"
        self.meta_key = "scan:meta"

    def store_result(self, scan_id: str, target: str, result: dict):
        key = f"{self.results_key}:{scan_id}"
        self.redis.hset(key, target, json.dumps(result))
        self.redis.hincrby(self.progress_key, scan_id, 1)

    def get_results(self, scan_id: str) -> dict:
        key = f"{self.results_key}:{scan_id}"
        raw = self.redis.hgetall(key)
        return {k.decode(): json.loads(v) for k, v in raw.items()}

    def get_progress(self, scan_id: str) -> dict:
        meta = self.redis.hgetall(f"{self.meta_key}:{scan_id}")
        completed = self.redis.hget(self.progress_key, scan_id)
        return {
            "scan_id": scan_id,
            "total_targets": int(meta.get(b"total_targets", 0)),
            "completed": int(completed or 0),
            "progress_percent": (
                int(completed or 0) / int(meta.get(b"total_targets", 1)) * 100
            ),
        }

    def set_meta(self, scan_id: str, meta: dict):
        key = f"{self.meta_key}:{scan_id}"
        for k, v in meta.items():
            self.redis.hset(key, k, json.dumps(v))

    def export(self, scan_id: str, filepath: str):
        results = self.get_results(scan_id)
        with open(filepath, "w") as f:
            json.dump(results, f, indent=2)
```

---

## 6. Real-World Examples

### 6.1 Multi-Phase Scan Pipeline

```python
class MultiPhaseScanPipeline:
    def __init__(self, config: dict):
        self.config = config
        self.phases = ["recon", "fingerprint", "scan", "report"]
        self.results = {}

    async def run(self, targets: list):
        phase_results = {}

        # Phase 1: Reconnaissance
        recon_queue = AsyncTaskQueue(max_concurrent=50)
        for target in targets:
            task = Task(
                id=f"recon-{target}",
                func=self._recon_phase,
                args=(target,),
            )
            await recon_queue.add_task(task)
        await recon_queue.start(num_workers=10)
        phase_results["recon"] = recon_queue.results

        # Phase 2: Fingerprint (uses recon results)
        fingerprint_targets = []
        for target, recon_data in phase_results["recon"].items():
            for subdomain in recon_data.get("subdomains", []):
                fingerprint_targets.append(subdomain)

        fp_queue = AsyncTaskQueue(max_concurrent=30)
        for target in fingerprint_targets:
            task = Task(
                id=f"fp-{target}",
                func=self._fingerprint_phase,
                args=(target,),
            )
            await fp_queue.add_task(task)
        await fp_queue.start(num_workers=5)
        phase_results["fingerprint"] = fp_queue.results

        # Phase 3: Vulnerability scanning
        scan_queue = AsyncTaskQueue(max_concurrent=20)
        for target, fp_data in phase_results["fingerprint"].items():
            if fp_data.get("has_web"):
                task = Task(
                    id=f"scan-{target}",
                    func=self._vuln_scan_phase,
                    args=(target,),
                )
                await scan_queue.add_task(task)
        await scan_queue.start(num_workers=5)
        phase_results["scan"] = scan_queue.results

        return phase_results

    async def _recon_phase(self, target: str) -> dict:
        await asyncio.sleep(0.1)
        return {"subdomains": [f"sub{i}.{target}" for i in range(5)]}

    async def _fingerprint_phase(self, target: str) -> dict:
        await asyncio.sleep(0.1)
        return {"has_web": True, "tech": ["nginx", "php"]}

    async def _vuln_scan_phase(self, target: str) -> dict:
        await asyncio.sleep(0.1)
        return {"vulns": [], "risk": "low"}
```

### 6.2 Distributed Scan Orchestrator

```python
class DistributedOrchestrator:
    def __init__(self, worker_urls: list):
        self.workers = worker_urls
        self.task分配 = ConsistentHashRing(self.workers)
        self.result_store = DistributedResultStore()

    async def scan_targets(self, targets: list, scan_id: str):
        total = len(targets)
        self.result_store.set_meta(scan_id, {"total_targets": total})

        async with aiohttp.ClientSession() as session:
            tasks = []
            for target in targets:
                worker = self.task分配.get_node(target)
                task = self._dispatch_to_worker(session, worker, target, scan_id)
                tasks.append(task)

            results = await asyncio.gather(*tasks, return_exceptions=True)

        successful = sum(1 for r in results if not isinstance(r, Exception))
        failed = sum(1 for r in results if isinstance(r, Exception))

        return {
            "scan_id": scan_id,
            "total": total,
            "successful": successful,
            "failed": failed,
        }

    async def _dispatch_to_worker(self, session, worker_url, target, scan_id):
        async with session.post(
            f"{worker_url}/scan",
            json={"target": target, "scan_id": scan_id},
            timeout=aiohttp.ClientTimeout(total=300),
        ) as resp:
            result = await resp.json()
            self.result_store.store_result(scan_id, target, result)
            return result
```

---

## 7. Common Pitfalls

| Pitfall | Problem | Solution |
|---|---|---|
| **No backpressure** | Queue grows unbounded, OOM | Set max queue size, implement backpressure |
| **Shared state race conditions** | Data corruption from concurrent access | Use locks, atomic operations, or message passing |
| **Hot partition** | One worker gets all the work | Use consistent hashing with virtual nodes |
| **No health checks** | Dead workers never detected | Add heartbeat and health check endpoints |
| **Blocking event loop** | Async benefits lost | Use `asyncio.to_thread` for blocking I/O |
| **No graceful shutdown** | Workers lose in-progress tasks | Drain queue before stopping |
| **Over-partitioning** | Too many small tasks, overhead dominates | Batch items into reasonable chunk sizes |
| **Ignoring worker capacity** | Fast and slow workers treated equally | Implement weighted load balancing |

---

## 8. Advanced Techniques

### 8.1 Work Stealing

```python
class WorkStealingPool:
    def __init__(self, num_workers: int):
        self.queues = [asyncio.Queue() for _ in range(num_workers)]
        self.workers = {}

    async def submit(self, task):
        min_queue = min(range(len(self.queues)), key=lambda i: self.queues[i].qsize())
        await self.queues[min_queue].put(task)

    async def worker_loop(self, worker_id: int):
        local_queue = self.queues[worker_id]
        while True:
            try:
                task = await asyncio.wait_for(local_queue.get(), timeout=1.0)
                await task()
            except asyncio.TimeoutError:
                stolen = await self._try_steal(worker_id)
                if stolen:
                    await stolen()
            except Exception as e:
                logger.error(f"Worker {worker_id} error: {e}")

    async def _try_steal(self, thief_id: int):
        for i, queue in enumerate(self.queues):
            if i != thief_id and not queue.empty():
                try:
                    return queue.get_nowait()
                except asyncio.QueueEmpty:
                    continue
        return None
```

### 8.2 Adaptive Concurrency

```python
class AdaptiveConcurrencyController:
    def __init__(self, initial_concurrency: int = 10):
        self.concurrency = initial_concurrency
        self.min_concurrency = 1
        self.max_concurrency = 200
        self.success_window = []
        self.window_size = 100

    def record_result(self, success: bool, latency_ms: float):
        self.success_window.append({
            "success": success,
            "latency": latency_ms,
        })
        if len(self.success_window) > self.window_size:
            self.success_window.pop(0)

        if len(self.success_window) >= 20:
            self._adjust()

    def _adjust(self):
        success_rate = sum(1 for r in self.success_window if r["success"]) / len(self.success_window)
        avg_latency = sum(r["latency"] for r in self.success_window) / len(self.success_window)

        if success_rate > 0.95 and avg_latency < 1000:
            self.concurrency = min(self.concurrency + 5, self.max_concurrency)
        elif success_rate < 0.8 or avg_latency > 5000:
            self.concurrency = max(self.concurrency - 10, self.min_concurrency)

    @property
    def current_limit(self) -> int:
        return self.concurrency
```

---

## 9. Reporting Template

```markdown
# Scalability Report - [Scan System]

## System Architecture
- **Workers**: X active / Y total
- **Queue**: Redis-backed, max depth Z
- **Result Store**: Redis / PostgreSQL
- **Load Balancer**: Consistent hashing with W virtual nodes

## Capacity Metrics
| Metric | Value | Threshold | Status |
|---|---|---|---|
| Max Concurrent Tasks | X | - | - |
| Queue Depth (current) | X | < 1000 | PASS/FAIL |
| Worker Utilization | X% | 60-80% | PASS/FAIL |
| Task Throughput | X/sec | > 50/sec | PASS/FAIL |

## Worker Distribution
| Worker | Tasks Completed | Active | Avg Latency |
|---|---|---|---|
| worker-0 | X | Yes/No | Xms |
| worker-1 | X | Yes/No | Xms |
| worker-2 | X | Yes/No | Xms |

## Scaling Events
| Timestamp | Action | Trigger | Workers After |
|---|---|---|---|
| ISO-8601 | Scale Up | Queue depth > 500 | X |
| ISO-8601 | Scale Down | Utilization < 30% | X |

## Cost Analysis
| Resource | Usage | Cost/Unit | Total Cost |
|---|---|---|---|
| Compute (vCPU-hours) | X | $X/hr | $X |
| Memory (GB-hours) | X | $X/hr | $X |
| Network (GB) | X | $X/GB | $X |
| Redis (hours) | X | $X/hr | $X |

## Recommendations
1. Current max throughput: X targets/minute
2. Recommend scaling to Y workers for Z-target scope
3. Cost optimization: use spot instances for worker pool
4. Consider adding result caching for repeated scans
```

---

## 10. Quick Reference

### Scaling Decision Matrix

| Scan Size | Single Machine | Small Cluster | Cloud Fleet |
|---|---|---|---|
| < 100 targets | Yes | Overkill | Overkill |
| 100-1000 targets | Maybe (if powerful) | Yes | Overkill |
| 1000-10000 targets | No | Yes | Maybe |
| > 10000 targets | No | Maybe | Yes |

### Queue Comparison

| Queue | Use Case | Complexity | Persistence |
|---|---|---|---|
| asyncio.Queue | Single machine | Low | No |
| Celery + Redis | Small cluster | Medium | Yes |
| RabbitMQ | Complex routing | High | Yes |
| AWS SQS | Cloud-native | Medium | Yes |
| Kafka | High throughput | High | Yes |

### Key Libraries

```bash
# Async task queue
pip install aiohttp asyncio

# Distributed tasks
pip install celery redis rq

# Container orchestration
pip install docker kubernetes

# Load balancing
pip install aiohttp-remote

# Monitoring
pip install psutil prometheus-client
```

### Quick Commands

```bash
# Start Redis for Celery
redis-server

# Start Celery worker
celery -A scan_workers worker -l info -Q subdomain,port,vuln

# Monitor Celery
celery -A scan_workers flower

# Docker compose for workers
docker-compose up -d --scale worker=5

# Check system capacity
python -c "import psutil; print(f'CPU: {psutil.cpu_count()} cores, RAM: {psutil.virtual_memory().total / 1024**3:.1f}GB')"
```

---

*This guide provides a complete scalability framework for bug bounty automation. Start with a single-machine async queue, then distribute across workers as your target scope grows.*
