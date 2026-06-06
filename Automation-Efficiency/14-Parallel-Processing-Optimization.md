# 14 — Parallel Processing Optimization

## 1. Model Selection Decision Tree

Security scanning is overwhelmingly I/O-bound (waiting for HTTP responses). CPU-bound work happens in response analysis, corpus processing, and log parsing.

```
Is the workload I/O-bound (HTTP, DNS, file I/O)?
├── Yes → Does the library support asyncio (aiohttp, aiofiles)?
│   ├── Yes → Use asyncio + aiohttp
│   └── No  → Use ThreadPoolExecutor

Is the workload CPU-bound (regex, hash diff, AST parsing)?
├── Yes → Use ProcessPoolExecutor
└── Mixed → asyncio outer layer + ProcessPoolExecutor for CPU function
```

---

## 2. Asyncio Bounded Concurrency

The core invariant: no more than N simultaneous requests per host to avoid detection.

```python
import asyncio, aiohttp, hashlib
from urllib.parse import urlparse
from dataclasses import dataclass

@dataclass
class ScanResult:
    url: str
    status: int
    body_hash: str
    error: str = ""

class BoundedScanner:
    def __init__(self, max_concurrent: int = 20, per_host: int = 4, timeout: float = 15.0):
        self._global = asyncio.Semaphore(max_concurrent)
        self._host_locks: dict[str, asyncio.Semaphore] = {}
        self._limit = per_host
        self._timeout = aiohttp.ClientTimeout(total=timeout)

    def _host_lock(self, host: str) -> asyncio.Semaphore:
        if host not in self._host_locks:
            self._host_locks[host] = asyncio.Semaphore(self._limit)
        return self._host_locks[host]

    async def request(self, session: aiohttp.ClientSession, url: str) -> ScanResult:
        host = urlparse(url).hostname or ""
        async with self._global, self._host_lock(host):
            try:
                async with session.request("GET", url, timeout=self._timeout) as resp:
                    body = await resp.read()
                    return ScanResult(url=url, status=resp.status,
                                      body_hash=hashlib.md5(body).hexdigest()[:12])
            except Exception as exc:
                return ScanResult(url=url, status=0, body_hash="", error=str(exc))

    async def scan_batch(self, session: aiohttp.ClientSession,
                         urls: list[str]) -> list[ScanResult]:
        tasks = [self.request(session, url) for url in urls]
        results: list[ScanResult] = []
        for coro in asyncio.as_completed(tasks):
            results.append(await coro)
        return results
```

Usage:

```python
async def main():
    urls = [f"https://target.com/api/item?id={i}" for i in range(500)]
    scanner = BoundedScanner(max_concurrent=30, per_host=5)
    async with aiohttp.ClientSession() as session:
        results = await scanner.scan_batch(session, urls)
    print(f"Scanned: {sum(1 for r in results if r.status > 0)}/{len(urls)}")
```

---

## 3. Progress Bars in Parallel

Use `tqdm.asyncio` for accurate async progress:

```python
from tqdm.asyncio import tqdm_asyncio

async def run_with_progress(urls: list[str]) -> list[ScanResult]:
    scanner = BoundedScanner(max_concurrent=30)
    async with aiohttp.ClientSession() as session:
        tasks = [scanner.request(session, url) for url in urls]
        results: list[ScanResult] = []
        for coro in tqdm_asyncio.as_completed(tasks, total=len(tasks), desc="Scanning"):
            results.append(await coro)
    return results
```

---

## 4. Thread Pool for Response Processing

ThreadPoolExecutor on I/O-bound response parsing avoids GIL contention:

```python
from concurrent.futures import ThreadPoolExecutor, as_completed

def process_response(body: bytes, url: str) -> dict:
    return {
        "url": url,
        "body_hash": hashlib.md5(body).hexdigest()[:12],
        "size": len(body),
        "has_form": b"<form" in body,
    }

def batch_process(pairs: list[tuple[str, bytes]], workers: int = 20) -> list[dict]:
    results: list[dict] = []
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {pool.submit(process_response, body, url): url
                   for url, body in pairs}
        for f in as_completed(futures):
            results.append(f.result())
    return results
```

---

## 5. ProcessPoolExecutor for CPU-Heavy Work

CPU-intensive corpus scanning must live outside the GIL:

```python
from concurrent.futures import ProcessPoolExecutor
import re

SECRET_PATTERNS = [
    re.compile(rb"[A-Za-z0-9_\-]{20,}:[A-Za-z0-9_\-]{40,}"),
    re.compile(rb"AWS_ACCESS_KEY_ID[\":\s]+(AKIA[0-9A-Z]{16})"),
]

def scan_bodies_for_secrets(pairs: list[tuple[int, bytes]]) -> list[dict]:
    findings: list[dict] = []
    for idx, body in pairs:
        for pat in SECRET_PATTERNS:
            for m in pat.finditer(body):
                findings.append({"index": idx, "match": m.group().decode("utf-8", errors="replace")})
    return findings

def run_process_pool(bodies: list[bytes], chunk_size: int = 200) -> list[dict]:
    items = [(i, bodies[i]) for i in range(len(bodies))]
    batches = [items[i:i+chunk_size] for i in range(0, len(items), chunk_size)]
    results: list[dict] = []
    with ProcessPoolExecutor() as pool:
        for f in as_completed(pool.submit(scan_bodies_for_secrets, b) for b in batches):
            results.extend(f.result())
    return results
```

### Mixed Pipeline: Async I/O + ProcessPool CPU

```python
async def pipeline(urls: list[str]) -> list[dict]:
    scanner = BoundedScanner(max_concurrent=30)
    bodies: list[tuple[int, bytes]] = []
    async with aiohttp.ClientSession() as session:
        tasks = [scanner.request(session, url) for url in urls]
        for coro in as_completed(tasks):
            r = await coro
            if r.status == 200:
                async with session.get(r.url) as resp:
                    bodies.append((len(bodies), await resp.read()))
    with ProcessPoolExecutor() as pool:
        batches = [bodies[i:i+500] for i in range(0, len(bodies), 500)]
        futures = [pool.submit(scan_bodies_for_secrets, b) for b in batches]
        results: list[dict] = []
        for f in as_completed(futures): results.extend(f.result())
    return results
```

---

## 6. Thread Pool Sizing

Formula: `optimal_threads = cpu_count * (1 + wait_time / compute_time)`.

```python
import os

def optimal_thread_count(wait_ratio: float = 10.0) -> int:
    cores = os.cpu_count() or 4
    return max(1, int(cores * (1 + wait_ratio)))

# I/O bound (network): ~50 threads on 4-core
# CPU bound (hashing): ~8 threads on 4-core
```

---

## 7. Bounded Concurrency and Deadlock Avoidance

### Hierarchical Rate Limiter

```python
class HierarchicalRateLimiter:
    def __init__(self, global_limit: int = 100, per_host: int = 5):
        self._global = asyncio.Semaphore(global_limit)
        self._host_locks: dict[str, asyncio.Semaphore] = {}
        self._per_host = per_host

    def _host(self, host: str) -> asyncio.Semaphore:
        if host not in self._host_locks:
            self._host_locks[host] = asyncio.Semaphore(self._per_host)
        return self._host_locks[host]

    async def acquire(self, url: str):
        parsed = urlparse(url); host = parsed.hostname or ""
        await self._global.acquire()
        await self._host(host).acquire()

    def release(self, url: str):
        parsed = urlparse(url); host = parsed.hostname or ""
        self._host(host).release()
        self._global.release()
```

### Ordered Lock Acquisition (Deadlock Prevention)

Always acquire locks in deterministic order when a single coroutine needs multiple host locks:

```python
async def two_host_request(session: aiohttp.ClientSession,
                           url_a: str, url_b: str) -> tuple[ScanResult, ScanResult]:
    hosts = sorted({urlparse(url_a).hostname, urlparse(url_b).hostname})
    locks = [limiter._host(h) for h in hosts]
    for lock in locks: await lock.acquire()
    try:
        r1, r2 = await asyncio.gather(
            scanner.request(session, url_a), scanner.request(session, url_b)
        )
        return r1, r2
    finally:
        for lock in reversed(locks): lock.release()
```

---

## 8. Result Aggregation

### Order-Preserving Aggregation

```python
async def ordered_scan(urls: list[str]) -> list[ScanResult]:
    scanner = BoundedScanner(max_concurrent=30, per_host=5)
    results: list[ScanResult | None] = [None] * len(urls)
    async with aiohttp.ClientSession() as session:
        async def task(idx: int, url: str):
            results[idx] = await scanner.request(session, url)
        await asyncio.gather(*[task(i, u) for i, u in enumerate(urls)])
    return [r for r in results if r is not None]
```

### Streaming to Disk (aiosqlite)

```python
import aiosqlite

async def streaming_scan(urls: list[str], db_path: str = "results.db"):
    scanner = BoundedScanner(max_concurrent=30)
    scanner = BoundedScanner(max_concurrent=30)
    conn = await aiosqlite.connect(db_path)
    await conn.execute("CREATE TABLE IF NOT EXISTS scan_results (id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT, status INTEGER, body_hash TEXT, error TEXT)")
    await conn.commit()
    async with aiohttp.ClientSession() as session:
        batch: list[ScanResult] = []
        for coro in asyncio.as_completed([scanner.request(session, u) for u in urls]):
            r: ScanResult = await coro
            batch.append(r)
            if len(batch) >= 200:
                await conn.executemany(
                    "INSERT INTO scan_results (url,status,body_hash,error) VALUES (?,?,?,?)",
                    [(r.url, r.status, r.body_hash, r.error) for r in batch]
                )
                await conn.commit()
                batch.clear()
    if batch:
        await conn.executemany("INSERT INTO scan_results (url,status,body_hash,error) VALUES (?,?,?,?)",
                               [(r.url, r.status, r.body_hash, r.error) for r in batch])
        await conn.commit()
    await conn.close()
```

---

## 9. Circuit Breaker for Failing Hosts

Opens after `N` consecutive failures; tries half-open after a cooldown.

```python
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class CircuitState:
    host: str
    failure_count: int = 0
    state: str = "closed"          # closed | open | half_open
    open_until: str = ""

class CircuitBreakerRegistry:
    FAILURE_THRESHOLD = 5
    RECOVERY_SEC = 60

    def __init__(self):
        self._breakers: dict[str, CircuitState] = {}

    def allow_request(self, host: str) -> bool:
        b = self._breakers.get(host)
        if not b or b.state != "open": return True
        if datetime.utcnow() >= datetime.fromisoformat(b.open_until):
            b.state = "half_open"; return True
        return False

    def record_failure(self, host: str):
        if host not in self._breakers:
            self._breakers[host] = CircuitState(host=host)
        b = self._breakers[host]
        b.failure_count += 1
        if b.failure_count >= self.FAILURE_THRESHOLD:
            b.state = "open"
            b.open_until = (datetime.utcnow() + timedelta(seconds=self.RECOVERY_SEC)).isoformat()

    def record_success(self, host: str):
        if host in self._breakers:
            self._breakers[host].failure_count = 0
            self._breakers[host].state = "closed"
```

---

## 10. Resilience: Exponential Backoff with Jitter

```python
from random import uniform

async def request_with_retry(session: aiohttp.ClientSession, url: str,
                              max_retries: int = 3, base_delay: float = 0.5) -> ScanResult:
    for attempt in range(max_retries):
        r = await scanner.request(session, url)
        if r.status > 0 or attempt == max_retries - 1:
            return r
        delay = base_delay * (2 ** attempt) + uniform(0, 0.3)
        await asyncio.sleep(delay)
    # unreachable — final return above
```

---

## 11. Quick-Reference Checklist

- [ ] `BoundedScanner` enforces global + per-host concurrency via layered semaphores
- [ ] Per-host limit set to 3–5 to avoid WAF detection
- [ ] `ProcessPoolExecutor` handles regex corpus and secret scanning outside GIL
- [ ] `aiosqlite` streams results to disk; no in-memory accumulation for >100k results
- [ ] `tqdm_asyncio` shows accurate progress for async pipelines
- [ ] `asyncio.wait_for` on all lock acquisitions; raises on 5s timeout
- [ ] Lock ordering consistency when acquiring multiple per-host locks
- [ ] Circuit breaker opens after 5 consecutive host failures; half-open after 60s
- [ ] Retry uses exponential backoff with jitter (`base_delay * 2^attempt + uniform(0, 0.3)`)
- [ ] `asyncio.gather(*tasks, return_exceptions=True)` prevents single-task failure
