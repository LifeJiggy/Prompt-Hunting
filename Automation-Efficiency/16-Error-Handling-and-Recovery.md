# Automation-Efficiency 16: Error Handling and Recovery

## 1. Expert Role

You are a **Senior Resilience Engineer** specializing in error handling, retry logic, circuit breaker patterns, graceful degradation, and structured logging for bug bounty automation pipelines. You build tools that survive flaky targets, rate limits, network timeouts, and partial failures without losing data or crashing mid-scan. Your automation must be fault-tolerant because targets are hostile, networks are unreliable, and you need every scan to produce results even when 60% of requests fail.

---

## 2. Core Concepts

### 2.1 Exception Taxonomy for Bug Bounty

| Exception Class | Example | Strategy |
|---|---|---|
| **Transient** | Connection timeout, DNS resolution failure | Retry with backoff |
| **Permanent** | 404 Not Found, invalid endpoint | Do not retry |
| **Rate-Limited** | 429 Too Many Requests, 503 with Retry-After | Respect header, exponential backoff |
| **Infrastructure** | Connection reset, socket hang up | Retry with circuit breaker |
| **Application** | 500 Internal Server Error, 502 Bad Gateway | Limited retry + alert |
| **Security** | 403 Forbidden, WAF block, IP ban | Rotate proxy, backoff, escalate |

### 2.2 Retry Logic

**Exponential Backoff Formula:**
```
delay = min(base_delay * (2 ^ attempt) + jitter, max_delay)
```

**Key Parameters:**
- `base_delay`: Starting delay (e.g., 1 second)
- `max_delay`: Cap on delay (e.g., 60 seconds)
- `max_retries`: Maximum retry attempts (e.g., 5)
- `jitter`: Random component to prevent thundering herd (0 to 1)

### 2.3 Circuit Breaker Pattern

Three states:
- **CLOSED**: Normal operation, requests pass through
- **OPEN**: Failures exceeded threshold, all requests fail fast
- **HALF-OPEN**: Trial period, one request probes if service recovered

### 2.4 Graceful Degradation

When a component fails:
- Return partial results instead of crashing
- Skip failed modules and continue with remaining work
- Cache previous results and serve stale data with warning
- Log degradation events for post-mortem analysis

### 2.5 Structured Logging

Every log entry should contain:
- Timestamp (ISO 8601)
- Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- Module/component name
- Correlation ID (trace requests through the pipeline)
- Structured data (JSON format for machine parsing)
- Human-readable message

---

## 3. Prerequisites

- Python 3.8+ installed
- `tenacity` library for retry logic
- `pybreaker` library for circuit breakers
- `structlog` or `python-json-logger` for structured logging
- Basic understanding of async programming (asyncio)
- Familiarity with HTTP status codes and network error types

**Install dependencies:**
```bash
pip install tenacity pybreaker structlog python-json-logger aiohttp requests
```

---

## 4. Methodology

### Step 1: Classify All Failure Modes

Before writing error handling, enumerate every way your pipeline can fail:

1. Network failures (DNS, TCP, TLS, timeout)
2. HTTP errors (4xx, 5xx)
3. Rate limiting (429, 503 with Retry-After)
4. Data parsing errors (malformed JSON, unexpected HTML)
5. Resource exhaustion (memory, disk, file descriptors)
6. External service failures (APIs, proxies, DNS resolvers)
7. Configuration errors (bad API keys, invalid targets)

### Step 2: Design Retry Strategy Per Failure Class

Map each failure class to a specific retry behavior:
- Which exceptions trigger retries
- How many retries
- What backoff strategy
- When to give up and move on

### Step 3: Implement Circuit Breakers

Add circuit breakers around:
- External API calls (target APIs, proxy providers)
- Database connections
- Shared resources that can cascade-fail

### Step 4: Build the Error Aggregation System

Centralize all errors in a collector:
- Count errors by type
- Track error rates over time
- Alert on error rate spikes
- Generate summary reports

### Step 5: Add Graceful Degradation

For each module, define:
- What constitutes "partial success"
- What results can be salvaged when a module fails
- How to communicate degradation to downstream modules

### Step 6: Implement Structured Logging

Replace all print statements with structured logs:
- JSON format for machine parsing
- Correlation IDs for request tracing
- Log levels appropriate to each event
- Rotation and retention policies

### Step 7: Test Error Handling

Deliberately inject failures:
- Mock network errors
- Simulate rate limiting
- Kill dependent services mid-test
- Verify recovery and degradation behavior

---

## 5. Tool Arsenal with Commands

### 5.1 Retry Decorator with Tenacity

```python
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type,
    before_sleep_log,
    RetryError,
)
import logging
import aiohttp

logger = logging.getLogger(__name__)


@retry(
    stop=stop_after_attempt(5),
    wait=wait_exponential(multiplier=1, min=1, max=30),
    retry=retry_if_exception_type((
        aiohttp.ClientError,
        ConnectionError,
        TimeoutError,
    )),
    before_sleep=before_sleep_log(logger, logging.WARNING),
)
async def fetch_target(session: aiohttp.ClientSession, url: str) -> dict:
    async with session.get(url, timeout=aiohttp.ClientTimeout(total=30)) as resp:
        resp.raise_for_status()
        return await resp.json()
```

### 5.2 Custom Retry with Rate Limit Handling

```python
import asyncio
import random
from datetime import datetime, timedelta


class RateLimitRetry:
    def __init__(self, max_retries: int = 10, base_delay: float = 2.0):
        self.max_retries = max_retries
        self.base_delay = base_delay

    async def execute(self, func, *args, **kwargs):
        for attempt in range(self.max_retries):
            try:
                return await func(*args, **kwargs)
            except RateLimitError as e:
                retry_after = e.retry_after or self.base_delay * (2 ** attempt)
                jitter = random.uniform(0, retry_after * 0.1)
                wait_time = retry_after + jitter
                logger.warning(
                    f"Rate limited, waiting {wait_time:.1f}s",
                    extra={"attempt": attempt + 1, "retry_after": retry_after},
                )
                await asyncio.sleep(wait_time)
            except Exception as e:
                logger.error(f"Non-retryable error: {e}")
                raise
        raise MaxRetriesExceeded(f"Failed after {self.max_retries} retries")
```

### 5.3 Circuit Breaker Implementation

```python
import pybreaker
import time
from functools import wraps

# Circuit breaker for external API calls
api_breaker = pybreaker.CircuitBreaker(
    fail_max=5,
    reset_timeout=60,
    name="target_api",
    exclude=[ValueError, TypeError],
)


class CircuitBreakerMetrics:
    def __init__(self):
        self.state_changes = []
        self.failure_counts = {}

    def on_state_change(self, old_state, new_state):
        entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "from": old_state.name,
            "to": new_state.name,
        }
        self.state_changes.append(entry)
        logger.warning(
            f"Circuit breaker state change",
            extra=entry,
        )


metrics = CircuitBreakerMetrics()
api_breaker.add_listener(pybreaker.STATE_CHANGE, metrics.on_state_change)


@api_breaker
async def call_target_api(session, endpoint):
    async with session.get(endpoint) as resp:
        resp.raise_for_status()
        return await resp.json()
```

### 5.4 Structured Logger Setup

```python
import structlog
import logging
import json
import sys
from datetime import datetime


def setup_logging(log_level: str = "INFO", log_file: str = "pipeline.log"):
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.add_log_level,
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(
            logging.getLevelName(log_level)
        ),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(
            file=open(log_file, "a")
        ),
        cache_logger_on_first_use=True,
    )


def get_logger(module: str, correlation_id: str = None):
    logger = structlog.get_logger(module)
    if correlation_id:
        logger = logger.bind(correlation_id=correlation_id)
    return logger


# Usage
log = get_logger("recon", correlation_id="scan-abc-123")
log.info("starting_scan", target="example.com", tool="subfinder")
log.error("scan_failed", target="example.com", error="timeout", attempt=3)
```

### 5.5 Error Aggregator

```python
from collections import defaultdict, Counter
from datetime import datetime
import json


class ErrorAggregator:
    def __init__(self):
        self.errors = defaultdict(list)
        self.counts = Counter()
        self.start_time = datetime.utcnow()

    def record(self, error_type: str, message: str, context: dict = None):
        entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "message": message,
            "context": context or {},
        }
        self.errors[error_type].append(entry)
        self.counts[error_type] += 1

    def get_summary(self) -> dict:
        elapsed = (datetime.utcnow() - self.start_time).total_seconds()
        return {
            "duration_seconds": elapsed,
            "total_errors": sum(self.counts.values()),
            "error_breakdown": dict(self.counts),
            "error_rate_per_minute": (sum(self.counts.values()) / elapsed) * 60 if elapsed > 0 else 0,
        }

    def export(self, filepath: str):
        with open(filepath, "w") as f:
            json.dump({
                "summary": self.get_summary(),
                "details": dict(self.errors),
            }, f, indent=2)


# Usage
aggregator = ErrorAggregator()
aggregator.record("timeout", "Connection timed out", {"target": "test.example.com"})
aggregator.record("rate_limit", "429 received", {"target": "api.example.com"})
summary = aggregator.get_summary()
print(json.dumps(summary, indent=2))
```

### 5.6 Graceful Degradation Handler

```python
from dataclasses import dataclass, field
from typing import Any, Optional
from enum import Enum


class DegradationLevel(Enum):
    FULL = "full"
    PARTIAL = "partial"
    MINIMAL = "minimal"
    FAILED = "failed"


@dataclass
class ModuleResult:
    success: bool
    data: Any = None
    degradation_level: DegradationLevel = DegradationLevel.FULL
    errors: list = field(default_factory=list)
    partial_data: Any = None


class PipelineOrchestrator:
    def __init__(self):
        self.results = {}
        self.degradation_log = []

    async def run_module(self, name: str, func, *args, **kwargs) -> ModuleResult:
        try:
            data = await func(*args, **kwargs)
            return ModuleResult(success=True, data=data)
        except RateLimitError as e:
            self.degradation_log.append({
                "module": name,
                "level": DegradationLevel.PARTIAL,
                "reason": str(e),
            })
            return ModuleResult(
                success=False,
                degradation_level=DegradationLevel.PARTIAL,
                errors=[str(e)],
            )
        except Exception as e:
            self.degradation_log.append({
                "module": name,
                "level": DegradationLevel.FAILED,
                "reason": str(e),
            })
            return ModuleResult(
                success=False,
                degradation_level=DegradationLevel.FAILED,
                errors=[str(e)],
            )

    def merge_results(self) -> dict:
        merged = {"modules": {}, "degradation": self.degradation_log}
        successful = 0
        for name, result in self.results.items():
            merged["modules"][name] = {
                "success": result.success,
                "degradation": result.degradation_level.value,
                "data_available": result.data is not None,
            }
            if result.success:
                successful += 1
        merged["pipeline_health"] = successful / len(self.results) if self.results else 0
        return merged
```

---

## 6. Real-World Examples

### 6.1 Resilient Subdomain Scanner

```python
import asyncio
import aiohttp
from tenacity import retry, stop_after_attempt, wait_exponential


class ResilientSubdomainScanner:
    def __init__(self, targets: list, concurrency: int = 10):
        self.targets = targets
        self.semaphore = asyncio.Semaphore(concurrency)
        self.results = []
        self.errors = ErrorAggregator()

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=2, min=1, max=20),
    )
    async def probe(self, session, subdomain):
        async with self.semaphore:
            url = f"http://{subdomain}"
            try:
                async with session.get(url, timeout=aiohttp.ClientTimeout(total=10)) as resp:
                    self.results.append({
                        "subdomain": subdomain,
                        "status": resp.status,
                        "alive": resp.status < 400,
                    })
            except asyncio.TimeoutError:
                self.errors.record("timeout", subdomain)
            except aiohttp.ClientError as e:
                self.errors.record("connection_error", subdomain, {"error": str(e)})

    async def scan(self):
        async with aiohttp.ClientSession() as session:
            tasks = [self.probe(session, t) for t in self.targets]
            await asyncio.gather(*tasks, return_exceptions=True)

        summary = self.errors.get_summary()
        alive = [r for r in self.results if r.get("alive")]
        print(f"Scanned {len(self.targets)} targets: {len(alive)} alive")
        print(f"Errors: {json.dumps(summary, indent=2)}")
        return self.results


# Run the scanner
scanner = ResilientSubdomainScanner(targets=["test.example.com", "api.example.com"])
asyncio.run(scanner.scan())
```

### 6.2 Rate-Limited API Harvester

```python
class RateLimitedHarvester:
    def __init__(self, api_base: str, requests_per_second: float = 5):
        self.api_base = api_base
        self.interval = 1.0 / requests_per_second
        self.last_request_time = 0

    async def fetch_with_rate_limit(self, session, endpoint):
        elapsed = time.time() - self.last_request_time
        if elapsed < self.interval:
            await asyncio.sleep(self.interval - elapsed)

        self.last_request_time = time.time()

        for attempt in range(5):
            try:
                async with session.get(f"{self.api_base}/{endpoint}") as resp:
                    if resp.status == 429:
                        retry_after = float(resp.headers.get("Retry-After", 60))
                        logger.warning(f"Rate limited, sleeping {retry_after}s")
                        await asyncio.sleep(retry_after)
                        continue
                    resp.raise_for_status()
                    return await resp.json()
            except aiohttp.ClientError as e:
                logger.warning(f"Attempt {attempt + 1} failed: {e}")
                await asyncio.sleep(2 ** attempt)
        return None
```

---

## 7. Common Pitfalls

| Pitfall | Problem | Solution |
|---|---|---|
| **Infinite retry loops** | Retry logic never gives up | Always set `max_retries` and `max_delay` |
| **Retry storm** | All clients retry simultaneously causing cascading failure | Add jitter to backoff delays |
| **Swallowing exceptions** | `except: pass` hides bugs | Always log exceptions, even if you continue |
| **No correlation IDs** | Cannot trace requests through pipeline | Generate and propagate correlation IDs |
| **Logging PII** | Credentials or personal data in logs | Sanitize log output, mask sensitive fields |
| **Synchronous retry blocking** | Retry sleeps block the event loop | Use `asyncio.sleep` not `time.sleep` |
| **Missing circuit breakers** | One failing service slows entire pipeline | Add circuit breakers at service boundaries |
| **Over-aggressive retry** | Retrying permanent errors wastes time | Classify errors before retrying |

---

## 8. Advanced Techniques

### 8.1 Adaptive Retry with Machine Learning

```python
class AdaptiveRetry:
    def __init__(self, history_size: int = 100):
        self.history = []
        self.history_size = history_size

    def record_attempt(self, success: bool, response_time: float, error_type: str = None):
        self.history.append({
            "success": success,
            "response_time": response_time,
            "error_type": error_type,
        })
        if len(self.history) > self.history_size:
            self.history.pop(0)

    def should_retry(self, error_type: str) -> bool:
        recent_errors = [
            h for h in self.history[-20:]
            if h["error_type"] == error_type
        ]
        if not recent_errors:
            return True
        success_rate = sum(1 for h in recent_errors if h["success"]) / len(recent_errors)
        return success_rate > 0.1

    def optimal_delay(self, attempt: int) -> float:
        avg_response = sum(h["response_time"] for h in self.history[-10:]) / max(len(self.history[-10:]), 1)
        return min(avg_response * (2 ** attempt), 120)
```

### 8.2 Dead Letter Queue for Failed Items

```python
import json
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Any
from datetime import datetime


@dataclass
class DeadLetterEntry:
    item: Any
    error: str
    attempts: int
    first_failed: str
    last_failed: str
    module: str


class DeadLetterQueue:
    def __init__(self, filepath: str = "dead_letters.jsonl"):
        self.filepath = Path(filepath)
        self.entries = []

    def add(self, item: Any, error: str, attempts: int, module: str):
        now = datetime.utcnow().isoformat()
        entry = DeadLetterEntry(
            item=item,
            error=error,
            attempts=attempts,
            first_failed=now,
            last_failed=now,
            module=module,
        )
        self.entries.append(entry)
        with open(self.filepath, "a") as f:
            f.write(json.dumps(asdict(entry)) + "\n")

    def retry_all(self, func):
        results = []
        for entry in self.entries:
            try:
                result = func(entry.item)
                results.append({"item": entry.item, "retried": True})
            except Exception as e:
                entry.attempts += 1
                entry.last_failed = datetime.utcnow().isoformat()
                entry.error = str(e)
        return results

    def get_stats(self) -> dict:
        return {
            "total_dead_letters": len(self.entries),
            "by_error": {},
            "by_module": {},
        }
```

### 8.3 Health Check Endpoint

```python
from datetime import datetime


class HealthChecker:
    def __init__(self):
        self.checks = {}
        self.last_check = None

    def register(self, name: str, check_func):
        self.checks[name] = check_func

    async def run_all(self) -> dict:
        results = {}
        for name, check in self.checks.items():
            try:
                ok = await check()
                results[name] = {"status": "healthy" if ok else "unhealthy"}
            except Exception as e:
                results[name] = {"status": "error", "error": str(e)}

        self.last_check = {
            "timestamp": datetime.utcnow().isoformat(),
            "results": results,
            "overall": all(r["status"] == "healthy" for r in results.values()),
        }
        return self.last_check


# Usage
health = HealthChecker()
health.register("database", check_database_connection)
health.register("redis", check_redis_connection)
health.register("target_api", check_target_api)
```

---

## 9. Reporting Template

```markdown
# Error Handling Report - [Scan Name]

## Executive Summary
- **Total Requests**: X
- **Successful**: X (XX%)
- **Failed**: X (XX%)
- **Retried Successfully**: X
- **Gave Up After Retries**: X

## Error Breakdown
| Error Type | Count | % of Total | Avg Response Time | Resolved by Retry |
|---|---|---|---|---|
| Timeout | X | XX% | Xs | XX% |
| Rate Limit (429) | X | XX% | Xs | XX% |
| Connection Reset | X | XX% | Xs | XX% |
| 500 Server Error | X | XX% | Xs | XX% |

## Circuit Breaker Events
| Timestamp | Component | State Change | Trigger |
|---|---|---|---|
| ISO-8601 | API | CLOSED -> OPEN | 5 consecutive failures |

## Degradation Summary
| Module | Degradation Level | Impact | Recoverable |
|---|---|---|---|
| Subdomain Scanner | Partial | 40% targets skipped | Yes |
| Port Scanner | Full | None | N/A |
| Vuln Scanner | Failed | No results | After restart |

## Recommendations
1. Increase timeout for [module] from Xs to Ys
2. Add circuit breaker to [component]
3. Reduce concurrency for [target] to avoid rate limiting
4. Update retry policy for [error type] to max 3 attempts

## Dead Letters
- Items that failed all retries: X
- Most common dead letter error: [error type]
- Dead letter file: dead_letters.jsonl
```

---

## 10. Quick Reference

### Retry Decision Matrix

| Error Type | Retry? | Max Attempts | Backoff Strategy |
|---|---|---|---|
| DNS resolution failure | Yes | 3 | Exponential |
| Connection timeout | Yes | 3 | Exponential |
| Connection reset | Yes | 5 | Exponential + jitter |
| 404 Not Found | No | 0 | N/A |
| 403 Forbidden | No | 0 | Rotate proxy |
| 429 Rate Limited | Yes | 10 | Use Retry-After header |
| 500 Server Error | Yes | 2 | Linear |
| 502 Bad Gateway | Yes | 3 | Exponential |
| 503 Service Unavailable | Yes | 5 | Exponential |
| SSL/TLS error | No | 0 | Check cert config |
| JSON decode error | No | 0 | Log and skip |

### Circuit Breaker Thresholds

| Service Type | Fail Max | Reset Timeout | Half-Open Max |
|---|---|---|---|
| External API | 5 | 60s | 1 |
| Database | 3 | 30s | 1 |
| Proxy Provider | 10 | 120s | 2 |
| DNS Resolver | 3 | 15s | 1 |

### Log Levels

| Level | When to Use |
|---|---|
| DEBUG | Variable values, request/response bodies |
| INFO | Scan start/end, module completion, results summary |
| WARNING | Rate limiting, degraded operation, retried errors |
| ERROR | Failed module, lost data, unrecoverable errors |
| CRITICAL | Pipeline halted, all targets unreachable |

### Key Libraries

```bash
# Retry logic
pip install tenacity

# Circuit breaker
pip install pybreaker

# Structured logging
pip install structlog python-json-logger

# Async error handling
pip install aiohttp asyncio

# Monitoring
pip install prometheus-client
```

### One-Liner Commands

```bash
# Search for error patterns in logs
grep -r "ERROR" logs/ | wc -l

# Count errors by type
cat pipeline.log | python -c "import sys,json; from collections import Counter; c=Counter(json.loads(l).get('log_level','') for l in sys.stdin); print(dict(c))"

# Watch error rate in real-time
tail -f pipeline.log | grep --line-buffered "ERROR"

# Export dead letters summary
python -c "import json; d=[json.loads(l) for l in open('dead_letters.jsonl')]; print(f'Total: {len(d)}')"
```

---

*This guide provides a complete error handling and recovery framework for bug bounty automation. Adapt thresholds, retry counts, and circuit breaker settings based on your specific target environment and network conditions.*
