# Automation-Efficiency 19: Integration Testing Automation

## 1. Expert Role

You are a **Test Automation Architect** specializing in integration testing, test frameworks, mocking strategies, and CI/CD testing for bug bounty automation pipelines. You ensure that every module in the scanning pipeline works correctly with every other module, that changes do not break existing functionality, and that tests run fast enough to keep pace with rapid development. You build test suites that catch real bugs before they waste time chasing false positives.

---

## 2. Core Concepts

### 2.1 Test Pyramid for Bug Bounty Automation

```
           /  E2E Tests  \         Few, slow, high confidence
          / Integration   \        Moderate, test module interactions
         /    Unit Tests    \      Many, fast, test individual functions
```

**Distribution:**
- **Unit Tests (70%)**: Test individual functions in isolation
- **Integration Tests (20%)**: Test module interactions and data flow
- **E2E Tests (10%)**: Test full pipeline against live targets

### 2.2 Integration Test Categories

| Category | What It Tests | Example |
|---|---|---|
| **Module Integration** | Two modules working together | Scanner output feeds into parser |
| **Service Integration** | Module with external service | Scanner with proxy provider |
| **Data Flow** | Data passes correctly between stages | Recon results format matches scan input |
| **API Integration** | HTTP endpoints work as expected | Target API responses handled correctly |
| **Database Integration** | Data persistence works | Results stored and retrieved correctly |
| **Queue Integration** | Task queue processes correctly | Jobs dispatched and completed |

### 2.3 Mocking Strategies

| Strategy | When to Use | Trade-off |
|---|---|---|
| **HTTP Mock** | External API calls | Fast, but may miss API changes |
| **File Mock** | File system operations | Fast, but may miss path issues |
| **Database Mock** | Database operations | Fast, but may miss schema issues |
| **Time Mock** | Time-dependent logic | Fast, but may miss timing issues |
| **Network Mock** | Network calls | Fast, but may miss DNS/TLS issues |
| **Real Service** | Final validation | Slow, but catches real issues |

### 2.4 Test Data Management

- **Fixtures**: Pre-defined test data
- **Factories**: Generate test data programmatically
- **Recorded Responses**: Capture real API responses for replay
- **Seed Data**: Database state for consistent tests

### 2.5 CI/CD Testing Pipeline

```
[Code Change] --> [Unit Tests] --> [Integration Tests] --> [E2E Tests] --> [Deploy]
                     ↓                    ↓                    ↓
                 [Coverage]          [Report]            [Gate Check]
```

---

## 3. Prerequisites

- Python 3.8+ installed
- `pytest` as test framework
- `pytest-asyncio` for async test support
- `aioresponses` or `responses` for HTTP mocking
- `pytest-cov` for coverage reporting
- `factory-boy` for test data generation
- `faker` for realistic test data

**Install dependencies:**
```bash
pip install pytest pytest-asyncio pytest-cov aioresponses factory-boy faker responses
```

---

## 4. Methodology

### Step 1: Identify Integration Points

Map all module interactions:
1. List every module in the pipeline
2. Identify data flow between modules
3. Identify external service dependencies
4. Identify shared state (queues, databases, files)

### Step 2: Write Integration Tests for Each Point

For each integration point:
1. Define input/output contracts
2. Write test with mocks for external services
3. Write test with real service for validation
4. Add edge cases and error scenarios

### Step 3: Create Test Data Fixtures

Build reusable test data:
1. Sample scan targets
2. Mock API responses
3. Expected output formats
4. Error response samples

### Step 4: Set Up Mock Servers

Configure mocks for external dependencies:
1. HTTP API mocks for target responses
2. DNS resolution mocks
3. Proxy response mocks
4. Rate limit response mocks

### Step 5: Implement Test Utilities

Create helper functions:
1. Async test runners
2. Temporary directory/file managers
3. Mock server lifecycle managers
4. Result comparison utilities

### Step 6: Integrate with CI/CD

Add tests to pipeline:
1. Unit tests on every commit
2. Integration tests on PR
3. E2E tests on merge to main
4. Coverage gates (minimum 80%)

### Step 7: Maintain and Update Tests

Keep tests valuable:
1. Update tests when modules change
2. Remove obsolete tests
3. Add tests for new integration points
4. Review test failures and fix root causes

---

## 5. Tool Arsenal with Commands

### 5.1 Pytest Configuration

```python
# conftest.py
import pytest
import asyncio
import tempfile
import shutil
from pathlib import Path
from typing import AsyncGenerator
from unittest.mock import AsyncMock, MagicMock


@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def temp_dir():
    tmpdir = tempfile.mkdtemp()
    yield Path(tmpdir)
    shutil.rmtree(tmpdir)


@pytest.fixture
def mock_http():
    from aioresponses import Aioresponses
    with Aioresponses() as m:
        yield m


@pytest.fixture
def mock_redis():
    mock = MagicMock()
    mock.hgetall.return_value = {}
    mock.hset.return_value = True
    mock.hincrby.return_value = 1
    return mock


@pytest.fixture
def sample_targets():
    return [
        "test.example.com",
        "api.example.com",
        "admin.example.com",
    ]


@pytest.fixture
def sample_scan_results():
    return {
        "test.example.com": {
            "status": 200,
            "alive": True,
            "tech": ["nginx", "php"],
        },
        "api.example.com": {
            "status": 200,
            "alive": True,
            "tech": ["python", "flask"],
        },
        "admin.example.com": {
            "status": 403,
            "alive": True,
            "tech": ["apache", "django"],
        },
    }
```

### 5.2 HTTP Mocking Tests

```python
import pytest
import aiohttp
import asyncio
from aioresponses import aioresponses


class TestSubdomainScannerIntegration:
    @pytest.mark.asyncio
    async def test_scan_success(self, sample_targets):
        scanner = ResilientSubdomainScanner(targets=sample_targets, concurrency=5)

        with aioresponses() as m:
            for target in sample_targets:
                m.get(
                    f"http://{target}",
                    payload={"status": "alive"},
                    status=200,
                )

            results = await scanner.scan()

        assert len(results) == 3
        alive = [r for r in results if r.get("alive")]
        assert len(alive) == 3

    @pytest.mark.asyncio
    async def test_scan_with_rate_limiting(self, sample_targets):
        scanner = ResilientSubdomainScanner(targets=sample_targets, concurrency=5)

        with aioresponses() as m:
            m.get(
                f"http://{sample_targets[0]}",
                status=429,
                headers={"Retry-After": "1"},
            )
            m.get(
                f"http://{sample_targets[1]}",
                payload={"status": "alive"},
                status=200,
            )

            results = await scanner.scan()

        assert len(results) == 2

    @pytest.mark.asyncio
    async def test_scan_with_timeout(self):
        scanner = ResilientSubdomainScanner(targets=["timeout.example.com"])

        with aioresponses() as m:
            m.get(
                "http://timeout.example.com",
                exception=asyncio.TimeoutError(),
            )

            results = await scanner.scan()

        assert len(results) == 0
```

### 5.3 Module Integration Tests

```python
class TestReconToScanPipeline:
    @pytest.mark.asyncio
    async def test_recon_feeds_scan(self, mock_http):
        recon = ReconModule()
        scanner = VulnScanner()

        mock_http.get(
            "https://api.censys.io/v2/hosts/search",
            payload={
                "result": {
                    "hits": [
                        {"ip": "192.168.1.1", "services": [{"port": 80}]}
                    ]
                }
            },
            status=200,
        )

        recon_results = await recon.run("example.com")
        scan_results = await scanner.run(recon_results["targets"])

        assert "vulns" in scan_results
        assert scan_results["target_count"] > 0

    @pytest.mark.asyncio
    async def test_data_format_compatibility(self):
        recon = ReconModule()
        scanner = VulnScanner()

        sample_recon_output = {
            "targets": [
                {"host": "192.168.1.1", "ports": [80, 443], "domain": "test.com"}
            ],
            "metadata": {"scan_id": "test-123"},
        }

        assert scanner.validate_input(sample_recon_output) is True

        invalid_output = {"targets": "not a list"}
        assert scanner.validate_input(invalid_output) is False

    @pytest.mark.asyncio
    async def test_error_propagation(self):
        recon = ReconModule()
        scanner = VulnScanner()

        recon_results = {"targets": [], "error": "DNS resolution failed"}

        scan_results = await scanner.run(recon_results)
        assert scan_results.get("skipped") is True
        assert scan_results.get("skip_reason") == "no targets"
```

### 5.4 Database Integration Tests

```python
import sqlite3
import json


class TestResultStoreIntegration:
    @pytest.fixture
    def db(self, temp_dir):
        db_path = temp_dir / "test_results.db"
        store = ResultStore(db_path)
        store.initialize()
        yield store
        store.close()

    def test_store_and_retrieve(self, db):
        result = {
            "target": "test.example.com",
            "status": 200,
            "vulns": ["xss-reflected"],
            "timestamp": "2025-01-15T10:30:00Z",
        }

        db.store("scan-123", "test.example.com", result)
        retrieved = db.get("scan-123", "test.example.com")

        assert retrieved is not None
        assert retrieved["target"] == "test.example.com"
        assert retrieved["vulns"] == ["xss-reflected"]

    def test_concurrent_access(self, db):
        import threading

        def write_results(thread_id):
            for i in range(100):
                result = {"target": f"host-{thread_id}-{i}.example.com", "status": 200}
                db.store(f"scan-{thread_id}", f"host-{thread_id}-{i}.example.com", result)

        threads = [threading.Thread(target=write_results, args=(i,)) for i in range(5)]
        for t in threads:
            t.start()
        for t in threads:
            t.join()

        for thread_id in range(5):
            results = db.get_all(f"scan-{thread_id}")
            assert len(results) == 100

    def test_export(self, db, temp_dir):
        db.store("scan-1", "a.example.com", {"status": 200})
        db.store("scan-1", "b.example.com", {"status": 404})

        export_path = temp_dir / "export.json"
        db.export("scan-1", export_path)

        with open(export_path) as f:
            data = json.load(f)
        assert len(data) == 2
```

### 5.5 Queue Integration Tests

```python
class TestTaskQueueIntegration:
    @pytest.mark.asyncio
    async def test_task_processing(self):
        queue = AsyncTaskQueue(max_concurrent=5)
        results = []

        async def dummy_task(value):
            await asyncio.sleep(0.01)
            results.append(value)
            return value

        for i in range(10):
            task = Task(id=f"task-{i}", func=dummy_task, args=(i,))
            await queue.add_task(task)

        await queue.start(num_workers=3)
        await asyncio.sleep(1)
        await queue.stop()

        assert len(results) == 10
        assert sorted(results) == list(range(10))

    @pytest.mark.asyncio
    async def test_task_retry(self):
        queue = AsyncTaskQueue(max_concurrent=2)
        call_count = 0

        async def flaky_task():
            nonlocal call_count
            call_count += 1
            if call_count < 3:
                raise Exception("Temporary failure")
            return "success"

        task = Task(id="flaky", func=flaky_task, max_attempts=5)
        await queue.add_task(task)

        await queue.start(num_workers=1)
        await asyncio.sleep(2)
        await queue.stop()

        assert call_count == 3

    @pytest.mark.asyncio
    async def test_concurrent_task_limit(self):
        queue = AsyncTaskQueue(max_concurrent=3)
        active_count = 0
        max_observed = 0

        async def slow_task():
            nonlocal active_count, max_observed
            active_count += 1
            max_observed = max(max_observed, active_count)
            await asyncio.sleep(0.5)
            active_count -= 1

        for i in range(20):
            task = Task(id=f"task-{i}", func=slow_task)
            await queue.add_task(task)

        await queue.start(num_workers=10)
        await asyncio.sleep(3)
        await queue.stop()

        assert max_observed <= 3
```

### 5.6 Test Data Factories

```python
import factory
from faker import Faker

fake = Faker()


class TargetFactory:
    @staticmethod
    def create(domain: str = None) -> dict:
        domain = domain or fake.domain_name()
        return {
            "domain": domain,
            "ip": fake.ipv4(),
            "ports": [80, 443],
            "subdomains": [f"www.{domain}", f"api.{domain}"],
            "metadata": {
                "discovered_at": fake.date_time_iso(),
                "source": "recon",
            },
        }

    @staticmethod
    def create_batch(count: int, domain: str = None) -> list:
        return [TargetFactory.create(domain) for _ in range(count)]


class ScanResultFactory:
    @staticmethod
    def create(target: str = None, vulns: list = None) -> dict:
        target = target or fake.domain_name()
        vulns = vulns or []
        return {
            "target": target,
            "status": 200 if not vulns else 200,
            "alive": True,
            "vulns": vulns,
            "tech": [fake.word() for _ in range(3)],
            "timestamp": fake.date_time_iso(),
            "response_time_ms": fake.random_int(min=50, max=5000),
        }

    @staticmethod
    def create_with_vulns(target: str = None, vuln_count: int = 3) -> dict:
        vulns = [fake.word() for _ in range(vuln_count)]
        return ScanResultFactory.create(target=target, vulns=vulns)
```

---

## 6. Real-World Examples

### 6.1 Full Pipeline Integration Test

```python
class TestFullScanPipeline:
    @pytest.mark.asyncio
    async def test_complete_scan_flow(self, mock_http, temp_dir):
        scan_config = {
            "targets": ["example.com"],
            "concurrency": 5,
            "output_dir": str(temp_dir),
        }

        mock_http.get(
            "https://api.censys.io/v2/hosts/search",
            payload={"result": {"hits": []}},
            status=200,
        )

        mock_http.get(
            "http://example.com",
            payload={"status": "alive"},
            status=200,
        )

        pipeline = ScanPipeline(scan_config)
        results = await pipeline.run()

        assert results["status"] == "completed"
        assert results["phases_completed"] == ["recon", "fingerprint", "scan"]
        assert (temp_dir / "results.json").exists()

    @pytest.mark.asyncio
    async def test_partial_failure_recovery(self, mock_http, temp_dir):
        scan_config = {
            "targets": ["example.com", "fail.example.com"],
            "concurrency": 5,
            "output_dir": str(temp_dir),
        }

        mock_http.get(
            "http://example.com",
            payload={"status": "alive"},
            status=200,
        )

        mock_http.get(
            "http://fail.example.com",
            exception=ConnectionError(),
        )

        pipeline = ScanPipeline(scan_config)
        results = await pipeline.run()

        assert results["status"] == "partial"
        assert results["failed_targets"] == ["fail.example.com"]
        assert results["successful_targets"] == ["example.com"]
```

### 6.2 Mock Server for External APIs

```python
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
import json


class MockAPIHandler(BaseHTTPRequestHandler):
    responses = {}

    def do_GET(self):
        response = self.responses.get(self.path, {"error": "not found"},)
        self.send_response(200 if "error" not in response else 404)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())

    def log_message(self, format, *args):
        pass


class MockAPIServer:
    def __init__(self, port: int = 8888):
        self.port = port
        self.server = None
        self.thread = None

    def start(self, responses: dict = None):
        if responses:
            MockAPIHandler.responses = responses
        self.server = HTTPServer(("localhost", self.port), MockAPIHandler)
        self.thread = threading.Thread(target=self.server.serve_forever)
        self.thread.daemon = True
        self.thread.start()

    def stop(self):
        if self.server:
            self.server.shutdown()

    def set_response(self, path: str, data: dict, status: int = 200):
        MockAPIHandler.responses[path] = {"data": data, "status": status}
```

### 6.3 Parameterized Integration Tests

```python
import pytest


@pytest.mark.parametrize("target,expected_status", [
    ("test.example.com", 200),
    ("api.example.com", 200),
    ("missing.example.com", None),
    ("timeout.example.com", None),
])
@pytest.mark.asyncio
async def test_scanner_various_targets(target, expected_status):
    scanner = ResilientSubdomainScanner(targets=[target])

    with aioresponses() as m:
        if expected_status:
            m.get(f"http://{target}", status=expected_status)
        else:
            m.get(f"http://{target}", exception=ConnectionError())

        results = await scanner.scan()

    if expected_status:
        assert any(r.get("status") == expected_status for r in results)
    else:
        assert len(results) == 0


@pytest.mark.parametrize("concurrency,expected_time", [
    (1, 10.0),
    (5, 3.0),
    (20, 1.0),
])
@pytest.mark.asyncio
async def test_concurrency_scaling(concurrency, expected_time):
    targets = [f"host-{i}.example.com" for i in range(50)]
    scanner = ResilientSubdomainScanner(targets=targets, concurrency=concurrency)

    with aioresponses() as m:
        for t in targets:
            m.get(f"http://{t}", status=200)

        import time
        start = time.time()
        await scanner.scan()
        elapsed = time.time() - start

    assert elapsed < expected_time
```

---

## 7. Common Pitfalls

| Pitfall | Problem | Solution |
|---|---|---|
| **Flaky tests** | Tests pass/fail randomly | Use deterministic mocks, avoid real time |
| **Slow test suite** | Tests take too long to run | Parallelize, use mocks, reduce E2E tests |
| **No test isolation** | Tests depend on each other | Use fresh fixtures, reset state between tests |
| **Over-mocking** | Tests pass but code is broken | Mix mocks with real integrations |
| **No coverage gates** | Bad code gets merged | Enforce minimum coverage in CI |
| **Hardcoded URLs** | Tests break when endpoints change | Use mock servers, configuration |
| **Ignoring test failures** | Broken tests accumulate | Fail CI on any test failure |
| **No data cleanup** | Tests pollute shared state | Use temp directories, database rollback |

---

## 8. Advanced Techniques

### 8.1 Contract Testing

```python
class TestModuleContract:
    def test_recon_output_contract(self):
        recon = ReconModule()
        output = recon.create_empty_output()

        required_keys = ["targets", "metadata", "timestamp"]
        for key in required_keys:
            assert key in output, f"Missing required key: {key}"

        assert isinstance(output["targets"], list)
        assert isinstance(output["metadata"], dict)

    def test_scan_input_contract(self):
        scanner = VulnScanner()
        sample_input = {
            "targets": [{"host": "1.2.3.4", "ports": [80]}],
            "metadata": {"scan_id": "test"},
        }

        assert scanner.validate_input(sample_input) is True

    def test_output_format_consistency(self):
        modules = [ReconModule(), VulnScanner(), ReportGenerator()]
        for module in modules:
            output = module.create_empty_output()
            assert "timestamp" in output
            assert "status" in output
```

### 8.2 Performance Integration Tests

```python
class TestPerformanceIntegration:
    @pytest.mark.asyncio
    async def test_scan_throughput(self):
        targets = [f"host-{i}.example.com" for i in range(100)]
        scanner = ResilientSubdomainScanner(targets=targets, concurrency=50)

        with aioresponses() as m:
            for t in targets:
                m.get(f"http://{t}", status=200)

            import time
            start = time.time()
            results = await scanner.scan()
            elapsed = time.time() - start

        rps = len(results) / elapsed
        assert rps > 50, f"Throughput too low: {rps:.1f} req/s"

    @pytest.mark.asyncio
    async def test_memory_usage(self):
        import psutil
        process = psutil.Process()

        targets = [f"host-{i}.example.com" for i in range(500)]
        scanner = ResilientSubdomainScanner(targets=targets, concurrency=100)

        mem_before = process.memory_info().rss / 1024 / 1024

        with aioresponses() as m:
            for t in targets:
                m.get(f"http://{t}", status=200)
            await scanner.scan()

        mem_after = process.memory_info().rss / 1024 / 1024
        mem_delta = mem_after - mem_before

        assert mem_delta < 100, f"Memory usage too high: {mem_delta:.1f}MB"
```

### 8.3 Chaos Testing

```python
import random


class ChaosMonkey:
    def __init__(self, failure_rate: float = 0.1):
        self.failure_rate = failure_rate

    def maybe_fail(self):
        if random.random() < self.failure_rate:
            raise Exception("Chaos monkey injected failure")

    def maybe_slow(self, max_delay: float = 5.0):
        if random.random() < self.failure_rate:
            time.sleep(random.uniform(0.1, max_delay))


class TestChaosResilience:
    @pytest.mark.asyncio
    async def test_pipeline_survives_random_failures(self):
        chaos = ChaosMonkey(failure_rate=0.3)
        pipeline = ScanPipeline({"targets": ["test.example.com"]})

        original_run = pipeline._run_module

        async def chaotic_run(*args, **kwargs):
            chaos.maybe_fail()
            return await original_run(*args, **kwargs)

        pipeline._run_module = chaotic_run

        results = await pipeline.run()
        assert results["status"] in ["completed", "partial"]
```

---

## 9. Reporting Template

```markdown
# Integration Test Report - [Project]

## Test Summary
- **Total Tests**: X
- **Passed**: X (XX%)
- **Failed**: X (XX%)
- **Skipped**: X
- **Duration**: X seconds

## Coverage Report
| Module | Line Coverage | Branch Coverage | Functions |
|---|---|---|---|
| recon | XX% | XX% | XX/XX |
| scanner | XX% | XX% | XX/XX |
| parser | XX% | XX% | XX/XX |
| reporter | XX% | XX% | XX/XX |

## Integration Points Tested
| Integration | Status | Test Count | Issues |
|---|---|---|---|
| recon -> scanner | PASS | X | None |
| scanner -> parser | PASS | X | None |
| scanner -> database | PASS | X | None |
| scanner -> API | FAIL | X | Timeout issue |

## Failed Tests
| Test Name | Module | Error | Root Cause |
|---|---|---|---|
| test_api_timeout | scanner | TimeoutError | API mock not set up |

## Performance Metrics
| Metric | Value | Threshold | Status |
|---|---|---|---|
| Test Suite Duration | Xs | < 120s | PASS |
| Average Test Duration | Xs | < 5s | PASS |
| Slowest Test | Xs | < 30s | PASS |

## Recommendations
1. Add integration test for [module] -> [module] connection
2. Increase coverage for [module] from X% to 80%
3. Fix flaky test: [test name]
4. Add chaos testing for [component]
```

---

## 10. Quick Reference

### Test Execution Commands

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/test_scanner.py

# Run tests matching pattern
pytest -k "test_scan"

# Run tests in parallel
pytest -n auto

# Run only integration tests
pytest -m integration

# Run with verbose output
pytest -v

# Run and stop on first failure
pytest -x
```

### Mock Quick Reference

```python
# Mock HTTP response
with aioresponses() as m:
    m.get("http://example.com", payload={"key": "value"}, status=200)

# Mock exception
with aioresponses() as m:
    m.get("http://example.com", exception=ConnectionError())

# Mock database
mock_db = MagicMock()
mock_db.query.return_value = [{"id": 1, "name": "test"}]

# Mock time
with freezegun.freeze_time("2025-01-15"):
    # code here sees frozen time
    pass
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements-test.txt
      - run: pytest --cov=src --cov-report=xml
      - uses: codecov/codecov-action@v4
```

### Test Data Templates

```python
# Minimal valid scan result
MINIMAL_RESULT = {
    "target": "test.example.com",
    "status": 200,
    "alive": True,
}

# Full scan result with vulnerabilities
FULL_RESULT = {
    "target": "test.example.com",
    "status": 200,
    "alive": True,
    "vulns": ["xss-reflected", "sqli"],
    "tech": ["nginx", "php", "mysql"],
    "ports": [80, 443, 3306],
    "response_time_ms": 150,
    "timestamp": "2025-01-15T10:30:00Z",
}
```

---

*This guide provides a complete integration testing framework for bug bounty automation. Test early, test often, and always test module interactions — that is where most bugs hide.*
