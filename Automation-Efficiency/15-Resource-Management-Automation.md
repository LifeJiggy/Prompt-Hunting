# 15 — Resource Management Automation

## 1. Resource Budget as Policy

Long-running security automation hits hard limits: memory exhaustion kills the host, open-FD ceilings prevent new connections, and disk full stops all output. Enforcement must be proactive: check at least every N events and act before the budget is consumed.

---

## 2. Memory Profiling (`tracemalloc`)

`tracemalloc` (stdlib) provides per-frame allocation attribution without external dependencies.

```python
import tracemalloc, gc
from dataclasses import dataclass, field

class MemoryProfiler:
    def __init__(self, max_frames: int = 25, enabled: bool = True):
        self._enabled = enabled
        self._snapshots: list[tuple[str, tracemalloc.Snapshot]] = []
        self._peak = 0

    def start(self):
        if self._enabled: tracemalloc.start(self._max_frames)

    def snapshot(self, label: str = ""):
        if not self._enabled: return None
        snap = tracemalloc.take_snapshot()
        self._snapshots.append((label, snap))
        _, peak = tracemalloc.get_traced_memory()
        self._peak = max(self._peak, peak)
        return snap

    def top_allocators(self, limit: int = 10):
        snap = self._snapshots[-1][1] if self._snapshots else None
        if snap is None: return []
        return [(str(s.traceback), s.size, s.count) for s in snap.statistics("lineno")[:limit]]

    def diff_since_first(self):
        if len(self._snapshots) < 2: return []
        _, first = self._snapshots[0]
        cur = self.snapshot() or first
        return [(str(s.traceback), s.size_diff, s.count_diff)
                for s in cur.compare_to(first, "lineno")[:20]]

    def stop(self) -> dict:
        if not self._enabled: return {}
        tracemalloc.stop()
        return {"peak_kb": self._peak // 1024, "snapshots": len(self._snapshots)}
```

---

## 3. Memory Budget Guard

`MemoryBudget` enforces a maximum RSS, triggers GC on breach, and optionally calls an emergency-reduction callback.

```python
import gc, os
from dataclasses import dataclass

def trigger_emergency_reduction():
    gc.collect(); gc.collect(); gc.collect()

@dataclass
class MemoryBudget:
    max_kb: int
    gc_after_reached: bool = True
    check_interval: int = 100
    _counter: int = 0

    def check(self) -> bool:
        self._counter += 1
        if self._counter % self._check_interval != 0: return True
        return self._enforce()

    def _enforce(self) -> bool:
        usage = self._current_kb()
        if usage <= self.max_kb: return True
        if self.gc_after_reached: gc.collect(); gc.collect()
        if self._current_kb() <= self.max_kb: return True
        trigger_emergency_reduction()
        return False

    @staticmethod
    def _current_kb() -> int:
        try:
            import psutil
            return psutil.Process(os.getpid()).memory_info().rss // 1024
        except ImportError: return 0
```

---

## 4. CPU Affinity

Binding a process to specific cores reduces context-switch overhead and keeps CPU caches warm.

```python
import psutil, os, subprocess

def bind_to_cores(core_indices: list[int]):
    psutil.Process(os.getpid()).cpu_affinity(core_indices)
    print(f"PID {os.getpid()} bound to cores {core_indices}")

def launch_on_cores(command: list[str], cores: list[int]) -> subprocess.Popen:
    if os.name != "nt":
        return subprocess.Popen(
            ["taskset", "-c", ",".join(map(str, cores))] + command
        )
    return subprocess.Popen(command)

# Multi-worker pool with distinct core assignment
def init_worker_cores(cores: list[int], worker_idx: int):
    bind_to_cores([cores[worker_idx % len(cores)]])

cpu_count = multiprocessing.cpu_count()
cores = list(range(4, cpu_count))
from multiprocessing import Pool
with Pool(processes=8, initializer=init_worker_cores, initargs=(cores,)) as pool:
    results = pool.map(analysis_task, items)
```

---

## 5. Open-File Descriptor Limits

Large-scale HTTP scanning creates many ephemeral sockets. The OS default (~1024) is easily exceeded.

```python
import resource, os

def raise_fd_limit(target: int = 65536):
    soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
    resource.setrlimit(resource.RLIMIT_NOFILE, (min(target, hard), hard))

def monitor_fd_count(pid: int, soft_limit: int, interval: float = 5.0,
                     threshold: float = 0.80) -> list[dict]:
    import time
    alerts: list[dict] = []
    for _ in range(120):
        try: fd_count = len(os.listdir(f"/proc/{pid}/fd"))
        except OSError: break
        util = fd_count / soft_limit
        if util >= threshold:
            alerts.append({"timestamp": datetime.utcnow().isoformat(),
                           "fd_count": fd_count, "util": util})
        time.sleep(interval)
    return alerts

import signal
signal.signal(signal.SIGCHLD, signal.SIG_IGN)

subprocess.Popen(
    ["nuclei", "-target", target],
    start_new_session=True,
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
)
```

---

## 6. Disk Quota Monitoring

`DiskQuota` asserts healthy free space before every batch write.

```python
import shutil
from pathlib import Path
from dataclasses import dataclass

@dataclass
class DiskQuota:
    path: str
    max_gb: float
    warn_pct: float = 0.80
    critical_pct: float = 0.95

    def status(self) -> dict:
        u = shutil.disk_usage(self.path)
        total, used, free = u.total, u.used, u.free
        pct = used / total if total else 0.0
        return {
            "path": self.path, "total_gb": round(total / 1e9, 2),
            "free_gb": round(free / 1e9, 2), "pct": round(pct * 100, 1),
            "status": "CRITICAL" if pct >= self.critical_pct
                      else "WARNING" if pct >= self.warn_pct else "OK",
        }

    def assert_healthy(self):
        s = self.status()
        if s["status"] == "CRITICAL":
            raise RuntimeError(f"Disk quota exceeded on {self.path}: {s['pct']}% used, "
                               f"{s['free_gb']} GB free (max {self.max_gb} GB).")
```

### Log Rotation

```python
import gzip, shutil

def rotate_output(filepath: str, max_mb: float = 500, keep: int = 5):
    p = Path(filepath)
    if not p.exists() or p.stat().st_size / 1e6 < max_mb: return
    archive = p.with_suffix(f"{p.suffix}.1.gz")
    with p.open("rb") as src, gzip.open(archive, "wb") as dst:
        shutil.copyfileobj(src, dst)
    p.unlink()
    for i in range(keep - 1, 1, -1):
        src = p.with_suffix(f"{p.suffix}.{i-1}.gz")
        dst = p.with_suffix(f"{p.suffix}.{i}.gz")
        if src.exists(): src.rename(dst)
```

---

## 7. Long-Running Process Lifecycle

### State Machine

```python
from enum import Enum, auto
from dataclasses import dataclass

class ProcessState(Enum):
    IDLE=auto(); RUNNING=auto(); PAUSED=auto()
    STOPPING=auto(); STOPPED=auto(); FAILED=auto()

@dataclass
class ManagedProcess:
    name: str; pid: int; state: ProcessState
    mem_kb: int = 0; cpu_pct: float = 0.0
```

### Lifecycle Orchestrator

```python
import signal, asyncio

class LifecycleManager:
    def __init__(self):
        self._procs: dict[str, ManagedProcess] = {}
        self._stop = False

    def register(self, name: str, proc: ManagedProcess):
        self._procs[name] = proc

    async def graceful_stop(self, name: str, timeout: float = 10.0):
        proc = self._procs.get(name)
        if not proc: return
        proc.state = ProcessState.STOPPING
        try:
            os.kill(proc.pid, signal.SIGTERM)
            for _ in range(int(timeout * 10)):
                if not psutil.pid_exists(proc.pid): break
                await asyncio.sleep(0.1)
            else: os.kill(proc.pid, signal.SIGKILL)
        except ProcessLookupError: pass
        proc.state = ProcessState.STOPPED; proc.exit_code = 0

    async def monitor(self, interval: float = 5.0):
        while not self._stop:
            for name, proc in self._procs.items():
                if proc.state != ProcessState.RUNNING: continue
                try:
                    ps = psutil.Process(proc.pid)
                    proc.mem_kb = ps.memory_info().rss // 1024
                    proc.cpu_pct = ps.cpu_percent()
                except psutil.NoSuchProcess:
                    proc.state = ProcessState.STOPPED; proc.exit_code = 0
            await asyncio.sleep(interval)
```

---

## 8. Zombie Reaping and Cleanup

```python
def reap_zombies(parent_pid: int) -> list[int]:
    reaped: list[int] = []
    try:
        for child in psutil.Process(parent_pid).children(recursive=True):
            try:
                if child.status() == psutil.STATUS_ZOMBIE:
                    child.wait(timeout=1); reaped.append(child.pid)
            except (psutil.NoSuchProcess, psutil.TimeoutExpired): continue
    except psutil.NoSuchProcess: pass
    return reaped

async def zombie_reaper(parent_pid: int, interval: float = 30.0):
    while True:
        r = reap_zombies(parent_pid)
        if r: print(f"Reaped {len(r)} zombies: {r}")
        await asyncio.sleep(interval)
```

---

## 9. Connection Pooling

`aiohttp` and `httpx` both pool connections. Configure the connector to prevent TCP handshake spam.

```python
connector = aiohttp.TCPConnector(
    limit=100, limit_per_host=10,
    ttl_dns_cache=300, force_close=False,
    enable_cleanup_closed=True,
)
async with aiohttp.ClientSession(connector=connector) as session:
    async with session.get("https://target.com") as resp:
        body = await resp.read()  # connection returned to pool

import httpx
pool = httpx.Limits(max_connections=100, max_connections_per_host=10, keepalive_expiry=30.0)
transport = httpx.HTTPTransport(retries=2, limits=pool)
with httpx.Client(transport=transport) as client:
    resp = client.get("https://target.com")  # connection reused
```

---

## 10. Async Cleanup with Task Group

`asyncio.TaskGroup` (Python 3.11+) cancels all sibling tasks together on failure:

```python
async def pipeline_with_cleanup():
    async with (
        aiohttp.ClientSession() as session,
        aiosqlite.connect("results.db") as db,
        asyncio.TaskGroup() as tg,
    ):
        t1 = tg.create_task(scanner.scan_batch(session, urls_a))
        t2 = tg.create_task(scanner.scan_batch(session, urls_b))
        results_a = await t1
        results_b = await t2
    # Session, DB, and all tasks closed/cancelled on scope exit

async def scan_stream(urls, quota: "DiskQuota | None" = None):
    session: aiohttp.ClientSession | None = None
    try:
        session = aiohttp.ClientSession()
        scanner = BoundedScanner(max_concurrent=30)
        for coro in asyncio.as_completed([scanner.request(session, u) for u in urls]):
            r = await coro
            if quota: quota.assert_healthy()
            yield r
    finally:
        if session: await session.close()
```

---

## 11. Start/Stop Scripts

### systemd Unit for Scanner Process

```ini
# /etc/systemd/system/scanner.service
[Unit]
Description=Security Automation Scanner
After=network-online.target

[Service]
Type=simple
User=scanner
WorkingDirectory=/opt/automation/scanner
ExecStart=/opt/automation/venv/bin/python -m scanner.main
ExecStop=/bin/kill -TERM $MAINPID
Restart=on-failure; RestartSec=30
StandardOutput=journal; StandardError=journal
LimitNOFILE=65536; MemoryMax=8G; CPUQuota=200%

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now scanner.service
journalctl -u scanner -f
```

### Python `ServiceController` with PID File

```python
from pathlib import Path
import subprocess, signal, time, psutil

class ServiceController:
    def __init__(self, name: str, command: list[str], logfile: str, cwd: str = "."):
        self.name, self.cmd = name, command
        self.logfile = Path(logfile); self.cwd = Path(cwd)
        self.pidfile = Path(f"{name}.pid")

    def start(self) -> int:
        if self.pidfile.exists(): raise RuntimeError(f"{self.name} already running")
        fh = self.logfile.open("ab")
        proc = subprocess.Popen(self.cmd, stdout=fh, stderr=fh,
                                cwd=self.cwd, start_new_session=True)
        self.pidfile.write_text(str(proc.pid))
        return proc.pid

    def stop(self, timeout: float = 10.0):
        pid = self._pid()
        if pid is None: return
        try:
            os.kill(pid, signal.SIGTERM)
            for _ in range(int(timeout * 10)):
                if not psutil.pid_exists(pid): break
                time.sleep(0.1)
            else: os.kill(pid, signal.SIGKILL)
        except ProcessLookupError: pass
        self.pidfile.unlink(missing_ok=True)

    def status(self) -> str:
        pid = self._pid()
        return f"RUNNING (PID {pid})" if pid and psutil.pid_exists(int(pid)) else "STOPPED"

    def _pid(self) -> int | None:
        return int(self.pidfile.read_text()) if self.pidfile.exists() else None
```

```python
svc = ServiceController(
    "nuclei-scan",
    ["nuclei","-target","https://target.com","-json","-o","nuclei.jsonl"],
    logfile="nuclei.log", cwd="/opt/automation",
)
svc.start(); time.sleep(5); print(svc.status()); svc.stop()
```

---

## 12. Quick-Reference Checklist

- [ ] `MemoryProfiler` snapshots at every stage boundary; `diff_since_first()` on budget breach
- [ ] `MemoryBudget` checks RSS every 100 scan events; triggers triple-`gc.collect()` when exceeded
- [ ] CPU affinity bound to dedicated cores via `psutil.Process.cpu_affinity()`
- [ ] `resource.RLIMIT_NOFILE` raised to 65536 before scanning
- [ ] FD count monitored every 5 min; alert at 80% utilization
- [ ] `DiskQuota.assert_healthy()` enforced before every batch write
- [ ] Output rotated when exceeding 500 MB; last 5 gzipped archives kept
- [ ] Subprocesses launched with `start_new_session=True`; `SIG_IGN(SIGCHLD)` on Unix
- [ ] Zombie reaper loop every 30s with `psutil.STATUS_ZOMBIE` detection
- [ ] `aiohttp.TCPConnector(limit=100, limit_per_host=10)` on all HTTP sessions
- [ ] `httpx.Limits` configured for sync HTTP workflows
- [ ] `asyncio.TaskGroup` wraps concurrent async resources (Python 3.11+)
- [ ] `ServiceController` provides `start`/`stop`/`status` with PID file management
- [ ] systemd unit enforces `LimitNOFILE=65536 MemoryMax=8G CPUQuota=200%`