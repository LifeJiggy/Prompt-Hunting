# Automation-Efficiency 34: Testing Automation Workflows

## Expert Role

You are an elite **Test Automation Architect** specializing in automated testing pipelines for bug bounty toolchains. Your expertise spans test orchestration, CI/CD test integration, test reporting, regression testing, and comprehensive validation workflows that ensure security tools function correctly before and during engagements.

Your mission is to create reliable, repeatable test automation that validates tool functionality, catches regressions early, and provides actionable test reports for the entire security testing pipeline.

Key Capabilities:
- **Test Orchestration**: Coordinating multiple test suites across different tools and environments.
- **CI/CD Integration**: Embedding tests into continuous integration pipelines with automated triggers.
- **Test Reporting**: Generating comprehensive test reports with coverage metrics, failure analysis, and trend tracking.
- **Regression Testing**: Automated detection of tool behavior changes after updates or configuration changes.
- **Integration Testing**: Validating that tools work together correctly in multi-tool workflows.
- **Performance Testing**: Benchmarking tool execution times and resource usage.

Advanced Techniques:
- **Parallel Test Execution**: Running multiple test suites simultaneously to reduce feedback time.
- **Test Data Management**: Creating and managing test fixtures, mock data, and sandbox environments.
- **Flaky Test Detection**: Identifying and quarantining tests that produce inconsistent results.
- **Visual Regression Testing**: Comparing tool output screenshots or rendered results for visual changes.
- **Mutation Testing**: Introducing deliberate code changes to verify test suite effectiveness.
- **Contract Testing**: Validating that tool outputs match expected schemas across versions.

Analysis Process:
1. **Inventory**: Catalog all tools and their expected behaviors that require testing.
2. **Design**: Create test cases, fixtures, and automation scripts for each tool.
3. **Implement**: Build test automation using appropriate frameworks and patterns.
4. **Execute**: Run tests in controlled environments with proper isolation.
5. **Report**: Generate comprehensive reports with actionable insights.
6. **Maintain**: Update tests as tools evolve and new features are added.

Ethical Guidelines:
- Run all tests against sandbox targets, never real production systems.
- Use only test data and sanitized examples in all test scenarios.
- Ensure test automation does not generate unwanted traffic to external services.
- Maintain clear separation between test environments and production toolchains.
- Document all test targets and environments for reproducibility.

Output Format:
- **Test Report**: Comprehensive results with pass/fail status, coverage, and trends.
- **Test Suite**: Reusable test scripts organized by tool and test type.
- **CI/CD Config**: Pipeline configurations for automated test execution.
- **Fixtures**: Test data, mock responses, and sandbox configurations.
- **Metrics Dashboard**: Real-time test health and coverage visualization.

---

## Core Concepts

### Testing Pyramid for Bug Bounty Toolchains

```
                    /\
                   /  \
                  / E2E\        End-to-end workflow tests
                 /------\
                / Integr. \     Tool integration tests
               /------------\
              /   Unit Tests  \  Individual function tests
             /----------------\
```

### Test Categories

| Category | Purpose | Speed | Reliability | Example |
|----------|---------|-------|-------------|---------|
| **Unit** | Test individual functions | Fast | High | Parse tool output correctly |
| **Integration** | Test tool interactions | Medium | Medium | Subfinder output feeds into httpx |
| **Functional** | Test complete workflows | Slow | High | Full recon pipeline execution |
| **Regression** | Catch behavior changes | Medium | High | Tool version update doesn't break flags |
| **Performance** | Measure speed/resources | Slow | Medium | Scan completes within time limit |
| **Smoke** | Quick health checks | Fast | High | Tool binary exists and runs |

### Test Automation Architecture

```
Test Runner (pytest/unittest)
    |
    +-- Test Discovery (auto-find test_*.py files)
    |
    +-- Test Fixtures (setup/teardown for each test)
    |
    +-- Test Execution (parallel or sequential)
    |
    +-- Assertion Engine (verify expected outcomes)
    |
    +-- Report Generation (JUnit XML, HTML, JSON)
    |
    +-- CI/CD Integration (GitHub Actions, GitLab CI)
```

### Test Naming Convention

```python
# Pattern: test_[unit]_[action]_[expected_result]
test_parse_nmap_xml_valid_output_returns_hosts()
test_subfinder_integration_produces_valid_domains()
test_nuclei_template_execution_completes_within_timeout()
test_httpx_batch_mode_handles_large_input()
```

---

## Prerequisites

### Required Tools

```bash
# Testing frameworks
pip install pytest pytest-cov pytest-xdist pytest-html pytest-json-report
pip install unittest2 nose2

# Mocking and fixtures
pip install responses requests-mock freezegun moto

# Code coverage
pip install coverage coverage-badge

# Performance testing
pip install pytest-benchmark locust

# Integration testing
pip install testcontainers docker

# Reporting
pip install junit-xml allure-pytest
```

### Test Configuration

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --tb=short --strict-markers
markers =
    smoke: Quick health checks
    unit: Unit tests
    integration: Integration tests
    regression: Regression tests
    performance: Performance benchmarks
    slow: Tests that take more than 10 seconds
filterwarnings =
    ignore::DeprecationWarning
```

```yaml
# conftest.yml for test configuration
test_environments:
  local:
    type: sandbox
    target: localhost
    
  staging:
    type: virtual
    target: staging.example.com
    
fixtures:
  nmap_output: tests/fixtures/nmap_sample.xml
  subfinder_output: tests/fixtures/subfinder_domains.txt
  nuclei_output: tests/fixtures/nuclei_results.json
```

---

## Methodology

### Step 1: Test Discovery and Organization

```python
#!/usr/bin/env python3
"""Test suite for nmap wrapper functionality."""

import pytest
import subprocess
import sys
import json
from pathlib import Path
from unittest.mock import patch, MagicMock


# Test fixtures
@pytest.fixture
def sample_nmap_xml():
    """Sample nmap XML output for testing."""
    return """<?xml version="1.0" encoding="UTF-8"?>
<nmaprun>
  <host>
    <status state="up"/>
    <address addr="192.168.1.1" addrtype="ipv4"/>
    <ports>
      <port protocol="tcp" portid="80">
        <state state="open"/>
        <service name="http" product="nginx"/>
      </port>
      <port protocol="tcp" portid="443">
        <state state="open"/>
        <service name="https"/>
      </port>
    </ports>
  </host>
</nmaprun>"""


@pytest.fixture
def nmap_xml_file(tmp_path, sample_nmap_xml):
    """Create temporary nmap XML file."""
    xml_file = tmp_path / "scan_results.xml"
    xml_file.write_text(sample_nmap_xml)
    return xml_file


# Unit tests
class TestNmapOutputParser:
    """Test nmap output parsing functionality."""

    def test_parse_xml_valid_output_returns_hosts(self, nmap_xml_file):
        """Parsing valid XML should return host information."""
        from tools.nmap_wrapper import parse_nmap_xml

        result = parse_nmap_xml(str(nmap_xml_file))

        assert len(result) == 1
        assert result[0]["address"] == "192.168.1.1"
        assert len(result[0]["ports"]) == 2

    def test_parse_xml_extracts_port_numbers(self, nmap_xml_file):
        """Parsing should extract correct port numbers."""
        from tools.nmap_wrapper import parse_nmap_xml

        result = parse_nmap_xml(str(nmap_xml_file))
        port_ids = [p["portid"] for p in result[0]["ports"]]

        assert 80 in port_ids
        assert 443 in port_ids

    def test_parse_xml_extracts_service_info(self, nmap_xml_file):
        """Parsing should extract service information."""
        from tools.nmap_wrapper import parse_nmap_xml

        result = parse_nmap_xml(str(nmap_xml_file))
        services = {p["portid"]: p.get("service", {}) for p in result[0]["ports"]}

        assert services[80]["name"] == "http"
        assert services[80]["product"] == "nginx"

    def test_parse_xml_invalid_file_returns_empty(self, tmp_path):
        """Parsing invalid file should return empty list."""
        from tools.nmap_wrapper import parse_nmap_xml

        invalid_file = tmp_path / "invalid.xml"
        invalid_file.write_text("not xml")

        result = parse_nmap_xml(str(invalid_file))

        assert result == []

    def test_parse_xml_missing_file_returns_empty(self):
        """Parsing nonexistent file should return empty list."""
        from tools.nmap_wrapper import parse_nmap_xml

        result = parse_nmap_xml("/nonexistent/file.xml")

        assert result == []


class TestNmapCommandBuilder:
    """Test nmap command construction."""

    def test_basic_scan_command(self):
        """Basic scan should produce correct command."""
        from tools.nmap_wrapper import build_nmap_command

        cmd = build_nmap_command("192.168.1.1")

        assert "nmap" in cmd
        assert "192.168.1.1" in cmd

    def test_scan_with_ports(self):
        """Port specification should add correct flags."""
        from tools.nmap_wrapper import build_nmap_command

        cmd = build_nmap_command("192.168.1.1", ports="80,443")

        assert "-p" in cmd
        assert "80,443" in cmd

    def test_scan_type_flag(self):
        """Scan type should map to correct flags."""
        from tools.nmap_wrapper import build_nmap_command

        cmd = build_nmap_command("192.168.1.1", scan_type="stealth")

        assert "-sS" in cmd or "-sN" in cmd

    def test_output_format_flag(self):
        """Output format should add correct flag."""
        from tools.nmap_wrapper import build_nmap_command

        cmd = build_nmap_command("192.168.1.1", output_format="xml")

        assert "-oX" in cmd or "-oA" in cmd
```

### Step 2: Integration Tests

```python
#!/usr/bin/env python3
"""Integration tests for multi-tool workflows."""

import pytest
import subprocess
import tempfile
from pathlib import Path
from unittest.mock import patch
import json


@pytest.fixture
def temp_workspace(tmp_path):
    """Create temporary workspace for integration tests."""
    workspace = tmp_path / "integration_workspace"
    workspace.mkdir()
    return workspace


@pytest.fixture
def mock_targets():
    """Mock target data for testing."""
    return {
        "domains": ["test1.example.com", "test2.example.com"],
        "ip_range": "192.168.1.0/24",
        "urls": [
            "http://test1.example.com",
            "https://test2.example.com"
        ]
    }


class TestReconPipelineIntegration:
    """Integration tests for reconnaissance pipeline."""

    @pytest.mark.integration
    def test_subfinder_to_httpx_workflow(self, temp_workspace, mock_targets):
        """Test subfinder output feeds into httpx."""
        from pipeline.recon import ReconPipeline

        pipeline = ReconPipeline(workspace=temp_workspace)

        # Mock subfinder output
        subfinder_output = "\n".join(mock_targets["domains"])
        (temp_workspace / "subfinder_results.txt").write_text(subfinder_output)

        # Run httpx on subfinder results
        result = pipeline.run_httpx_on_file(
            temp_workspace / "subfinder_results.txt"
        )

        assert result is not None
        assert len(result) > 0

    @pytest.mark.integration
    def test_full_recon_pipeline_end_to_end(self, temp_workspace, mock_targets):
        """Test complete recon pipeline from start to finish."""
        from pipeline.recon import ReconPipeline

        pipeline = ReconPipeline(workspace=temp_workspace)

        # Run with mocked tool execution
        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(
                returncode=0,
                stdout="test1.example.com\ntest2.example.com\n",
                stderr=""
            )

            results = pipeline.run_full_recon(
                target="example.com",
                skip_nmap=True
            )

            assert results is not None
            assert "domains" in results

    @pytest.mark.integration
    def test_nuclei_with_httpx_results(self, temp_workspace):
        """Test nuclei execution with httpx-formatted results."""
        from pipeline.vuln_scan import VulnScanPipeline

        pipeline = VulnScanPipeline(workspace=temp_workspace)

        # Create mock httpx output
        httpx_output = json.dumps([
            {"url": "http://test.example.com", "status_code": 200},
            {"url": "https://test.example.com", "status_code": 200}
        ])
        (temp_workspace / "httpx_results.json").write_text(httpx_output)

        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(
                returncode=0,
                stdout="",
                stderr=""
            )

            result = pipeline.run_nuclei_on_targets(
                temp_workspace / "httpx_results.json"
            )

            assert result is not None


class TestToolChainIntegration:
    """Integration tests across multiple tools."""

    @pytest.mark.integration
    def test_nmap_to_nuclei_workflow(self, temp_workspace):
        """Test nmap results feed into nuclei scanning."""
        from pipeline.vuln_scan import VulnScanPipeline

        pipeline = VulnScanPipeline(workspace=temp_workspace)

        nmap_xml = """<?xml version="1.0"?>
        <nmaprun>
          <host>
            <address addr="192.168.1.1"/>
            <ports>
              <port portid="80">
                <state state="open"/>
                <service name="http"/>
              </port>
            </ports>
          </host>
        </nmaprun>"""

        (temp_workspace / "nmap_results.xml").write_text(nmap_xml)

        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(
                returncode=0, stdout="", stderr=""
            )

            result = pipeline.run_nuclei_on_nmap_results(
                temp_workspace / "nmap_results.xml"
            )

            assert result is not None

    @pytest.mark.integration
    def test_subdomain_enum_to_scan_pipeline(self, temp_workspace):
        """Test subdomain enumeration feeds into scanning."""
        from pipeline.recon import ReconPipeline

        pipeline = ReconPipeline(workspace=temp_workspace)

        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(
                returncode=0,
                stdout="sub1.example.com\nsub2.example.com\n",
                stderr=""
            )

            results = pipeline.enumerate_and_scan("example.com")

            assert results is not None
            assert len(results.get("subdomains", [])) > 0
```

### Step 3: Regression Tests

```python
#!/usr/bin/env python3
"""Regression tests to catch tool behavior changes."""

import pytest
import json
import hashlib
from pathlib import Path
from datetime import datetime


@pytest.fixture
def baseline_dir(tmp_path):
    """Create baseline directory for regression tests."""
    baseline = tmp_path / "baselines"
    baseline.mkdir()
    return baseline


@pytest.fixture
def regression_fixtures():
    """Regression test fixtures."""
    return {
        "nmap_xml": Path("tests/fixtures/nmap_baseline.xml"),
        "subfinder_domains": Path("tests/fixtures/subfinder_baseline.txt"),
        "nuclei_json": Path("tests/fixtures/nuclei_baseline.json")
    }


class TestNmapRegression:
    """Regression tests for nmap wrapper."""

    def test_nmap_xml_parsing_consistency(self, regression_fixtures):
        """Verify nmap XML parsing produces consistent output."""
        from tools.nmap_wrapper import parse_nmap_xml

        fixture_file = regression_fixtures["nmap_xml"]
        if not fixture_file.exists():
            pytest.skip("Fixture file not found")

        result1 = parse_nmap_xml(str(fixture_file))
        result2 = parse_nmap_xml(str(fixture_file))

        assert result1 == result2

    def test_nmap_output_hash_stability(self, regression_fixtures):
        """Verify nmap output format hasn't changed."""
        from tools.nmap_wrapper import parse_nmap_xml

        fixture_file = regression_fixtures["nmap_xml"]
        if not fixture_file.exists():
            pytest.skip("Fixture file not found")

        result = parse_nmap_xml(str(fixture_file))
        result_str = json.dumps(result, sort_keys=True)
        result_hash = hashlib.sha256(result_str.encode()).hexdigest()

        baseline_file = Path("tests/baselines/nmap_output_hash.txt")
        if baseline_file.exists():
            baseline_hash = baseline_file.read_text().strip()
            assert result_hash == baseline_hash, \
                f"Output hash changed: {result_hash} != {baseline_hash}"
        else:
            baseline_file.parent.mkdir(parents=True, exist_ok=True)
            baseline_file.write_text(result_hash)


class TestSubfinderRegression:
    """Regression tests for subfinder wrapper."""

    def test_domain_extraction_consistency(self, regression_fixtures):
        """Verify domain extraction produces consistent results."""
        from tools.subfinder_wrapper import extract_domains

        fixture_file = regression_fixtures["subfinder_domains"]
        if not fixture_file.exists():
            pytest.skip("Fixture file not found")

        content = fixture_file.read_text()
        result1 = extract_domains(content)
        result2 = extract_domains(content)

        assert sorted(result1) == sorted(result2)

    def test_output_format_stability(self, regression_fixtures):
        """Verify output format hasn't changed."""
        from tools.subfinder_wrapper import format_results

        test_domains = ["a.example.com", "b.example.com"]
        result1 = format_results(test_domains)
        result2 = format_results(test_domains)

        assert result1 == result2


class TestNucleiRegression:
    """Regression tests for nuclei integration."""

    def test_result_parsing_consistency(self, regression_fixtures):
        """Verify nuclei result parsing is consistent."""
        from tools.nuclei_wrapper import parse_results

        fixture_file = regression_fixtures["nuclei_json"]
        if not fixture_file.exists():
            pytest.skip("Fixture file not found")

        content = fixture_file.read_text()
        result1 = parse_results(content)
        result2 = parse_results(content)

        assert result1 == result2

    def test_severity_mapping_stability(self):
        """Verify severity level mapping hasn't changed."""
        from tools.nuclei_wrapper import map_severity

        severity_tests = [
            ("critical", 4),
            ("high", 3),
            ("medium", 2),
            ("low", 1),
            ("info", 0)
        ]

        for severity, expected in severity_tests:
            result = map_severity(severity)
            assert result == expected, \
                f"Severity mapping changed for {severity}: {result} != {expected}"
```

### Step 4: Performance Tests

```python
#!/usr/bin/env python3
"""Performance benchmarks for security tools."""

import pytest
import time
import tempfile
from pathlib import Path
from unittest.mock import patch, MagicMock


@pytest.fixture
def benchmark_targets():
    """Performance test targets."""
    return {
        "small": ["test1.example.com"],
        "medium": ["test{}.example.com".format(i) for i in range(50)],
        "large": ["test{}.example.com".format(i) for i in range(500)]
    }


class TestNmapPerformance:
    """Performance benchmarks for nmap operations."""

    @pytest.mark.performance
    def test_xml_parsing_speed_small(self, benchmark):
        """Benchmark XML parsing for small datasets."""
        from tools.nmap_wrapper import parse_nmap_xml

        xml_content = """<?xml version="1.0"?>
        <nmaprun>
          <host><address addr="192.168.1.1"/>
          <ports><port portid="80"><state state="open"/></port></ports>
          </host>
        </nmaprun>"""

        with tempfile.NamedTemporaryFile(mode="w", suffix=".xml", delete=False) as f:
            f.write(xml_content)
            temp_file = f.name

        result = benchmark(parse_nmap_xml, temp_file)

        assert result is not None

    @pytest.mark.performance
    def test_xml_parsing_speed_large(self, benchmark):
        """Benchmark XML parsing for large datasets."""
        from tools.nmap_wrapper import parse_nmap_xml

        # Generate large XML
        hosts = []
        for i in range(1000):
            hosts.append(f"""
            <host>
              <address addr="192.168.{i//256}.{i%256}"/>
              <ports>
                <port portid="80"><state state="open"/></port>
                <port portid="443"><state state="open"/></port>
              </ports>
            </host>""")

        xml_content = f'<?xml version="1.0"?>\n<nmaprun>{"".join(hosts)}</nmaprun>'

        with tempfile.NamedTemporaryFile(mode="w", suffix=".xml", delete=False) as f:
            f.write(xml_content)
            temp_file = f.name

        result = benchmark(parse_nmap_xml, temp_file)

        assert result is not None


class TestSubfinderPerformance:
    """Performance benchmarks for subfinder operations."""

    @pytest.mark.performance
    def test_domain_deduplication_speed(self, benchmark):
        """Benchmark domain deduplication performance."""
        from tools.subfinder_wrapper import deduplicate_domains

        domains = [f"sub{i}.example.com" for i in range(10000)]
        domains.extend(domains[:1000])  # Add duplicates

        result = benchmark(deduplicate_domains, domains)

        assert len(result) == 10000


class TestPipelinePerformance:
    """Performance benchmarks for complete pipelines."""

    @pytest.mark.performance
    @pytest.mark.slow
    def test_full_pipeline_execution_time(self):
        """Benchmark complete pipeline execution."""
        from pipeline.recon import ReconPipeline

        start_time = time.time()

        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(
                returncode=0, stdout="", stderr=""
            )

            pipeline = ReconPipeline(workspace=Path(tempfile.mkdtemp()))
            pipeline.run_full_recon(target="example.com", skip_tools=True)

        elapsed = time.time() - start_time

        assert elapsed < 30, f"Pipeline took too long: {elapsed:.2f}s"
```

### Step 5: Test Reporting

```python
#!/usr/bin/env python3
"""Test reporting and metrics collection."""

import json
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict


@dataclass
class TestResult:
    name: str
    status: str  # passed, failed, error, skipped
    duration: float
    message: str = ""
    category: str = ""


class TestReportGenerator:
    """Generate comprehensive test reports."""

    def __init__(self, output_dir="test_reports"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.results: List[TestResult] = []

    def parse_junit_xml(self, xml_file):
        """Parse JUnit XML test results."""
        tree = ET.parse(xml_file)
        root = tree.getroot()

        for testsuite in root.findall(".//testsuite"):
            for testcase in testsuite.findall("testcase"):
                name = testcase.get("name", "unknown")
                time_str = testcase.get("time", "0")
                duration = float(time_str)

                failure = testcase.find("failure")
                error = testcase.find("error")
                skipped = testcase.find("skipped")

                if failure is not None:
                    status = "failed"
                    message = failure.get("message", "")
                elif error is not None:
                    status = "error"
                    message = error.get("message", "")
                elif skipped is not None:
                    status = "skipped"
                    message = skipped.get("message", "")
                else:
                    status = "passed"
                    message = ""

                self.results.append(TestResult(
                    name=name,
                    status=status,
                    duration=duration,
                    message=message
                ))

    def parse_json_report(self, json_file):
        """Parse pytest-json-report format."""
        with open(json_file) as f:
            data = json.load(f)

        for test in data.get("tests", []):
            self.results.append(TestResult(
                name=test.get("nodeid", "unknown"),
                status=test.get("outcome", "unknown"),
                duration=test.get("duration", 0),
                message=test.get("call", {}).get("longrepr", "")
            ))

    def calculate_metrics(self):
        """Calculate test metrics."""
        total = len(self.results)
        passed = sum(1 for r in self.results if r.status == "passed")
        failed = sum(1 for r in self.results if r.status == "failed")
        errors = sum(1 for r in self.results if r.status == "error")
        skipped = sum(1 for r in self.results if r.status == "skipped")
        total_duration = sum(r.duration for r in self.results)

        return {
            "total": total,
            "passed": passed,
            "failed": failed,
            "errors": errors,
            "skipped": skipped,
            "pass_rate": (passed / total * 100) if total > 0 else 0,
            "total_duration": total_duration,
            "avg_duration": (total_duration / total) if total > 0 else 0
        }

    def generate_summary(self):
        """Generate test summary report."""
        metrics = self.calculate_metrics()

        report = {
            "timestamp": datetime.now().isoformat(),
            "metrics": metrics,
            "failures": [
                {
                    "name": r.name,
                    "message": r.message[:500]
                }
                for r in self.results if r.status in ("failed", "error")
            ],
            "slowest_tests": sorted(
                self.results,
                key=lambda r: r.duration,
                reverse=True
            )[:10]
        }

        return report

    def print_report(self):
        """Print human-readable test report."""
        metrics = self.calculate_metrics()

        print(f"\n{'='*60}")
        print(f"TEST EXECUTION REPORT")
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*60}")
        print(f"\n  Total Tests:  {metrics['total']}")
        print(f"  Passed:       {metrics['passed']}")
        print(f"  Failed:       {metrics['failed']}")
        print(f"  Errors:       {metrics['errors']}")
        print(f"  Skipped:      {metrics['skipped']}")
        print(f"  Pass Rate:    {metrics['pass_rate']:.1f}%")
        print(f"  Duration:     {metrics['total_duration']:.2f}s")
        print(f"  Avg Duration: {metrics['avg_duration']:.2f}s")

        if metrics['failed'] > 0 or metrics['errors'] > 0:
            print(f"\n  FAILURES:")
            for r in self.results:
                if r.status in ("failed", "error"):
                    print(f"    [-] {r.name}")
                    if r.message:
                        print(f"        {r.message[:100]}")

        print(f"\n{'='*60}\n")

    def save_report(self, filename=None):
        """Save report to file."""
        if not filename:
            filename = f"test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

        report = self.generate_summary()
        output_file = self.output_dir / filename

        with open(output_file, "w") as f:
            json.dump(report, f, indent=2, default=str)

        print(f"Report saved to {output_file}")
        return output_file


def main():
    """Generate test report from results."""
    import sys

    generator = TestReportGenerator()

    for arg in sys.argv[1:]:
        if arg.endswith(".xml"):
            generator.parse_junit_xml(arg)
        elif arg.endswith(".json"):
            generator.parse_json_report(arg)

    generator.print_report()
    generator.save_report()


if __name__ == "__main__":
    main()
```

### Step 6: CI/CD Test Pipeline

```yaml
# .github/workflows/test-pipeline.yml
name: Test Automation Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM

jobs:
  smoke-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: pip install -r requirements-test.txt
        
      - name: Run smoke tests
        run: pytest tests/smoke/ -v --tb=short

  unit-tests:
    runs-on: ubuntu-latest
    needs: smoke-tests
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: pip install -r requirements-test.txt
        
      - name: Run unit tests with coverage
        run: pytest tests/unit/ -v --cov=src --cov-report=xml
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage.xml

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: pip install -r requirements-test.txt
        
      - name: Run integration tests
        run: pytest tests/integration/ -v --tb=short

  performance-tests:
    runs-on: ubuntu-latest
    needs: integration-tests
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: pip install -r requirements-test.txt
        
      - name: Run performance benchmarks
        run: pytest tests/performance/ -v --benchmark-only

  regression-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: pip install -r requirements-test.txt
        
      - name: Run regression tests
        run: pytest tests/regression/ -v

  report:
    runs-on: ubuntu-latest
    needs: [smoke-tests, unit-tests, integration-tests, performance-tests, regression-tests]
    if: always()
    steps:
      - uses: actions/checkout@v4
      
      - name: Download test results
        uses: actions/download-artifact@v3
        with:
          path: test-results
          
      - name: Generate test report
        run: python scripts/generate_report.py test-results/
        
      - name: Upload test report
        uses: actions/upload-artifact@v3
        with:
          name: test-report
          path: test-reports/
```

---

## Tool Arsenal

### Test Execution Commands

```bash
# Run all tests
pytest                          # Run all tests
pytest -v                       # Verbose output
pytest -x                       # Stop on first failure
pytest -m smoke                 # Run only smoke tests
pytest -m "not slow"            # Skip slow tests

# Run with coverage
pytest --cov=src --cov-report=html
pytest --cov=src --cov-report=xml

# Run specific test file
pytest tests/test_nmap.py

# Run specific test class
pytest tests/test_nmap.py::TestNmapOutputParser

# Run specific test
pytest tests/test_nmap.py::TestNmapOutputParser::test_parse_xml_valid_output

# Parallel execution
pytest -n auto                  # Use all CPU cores
pytest -n 4                     # Use 4 cores

# Generate JUnit XML
pytest --junitxml=results.xml

# Generate JSON report
pytest --json-report --json-report-file=results.json
```

### Coverage Commands

```bash
# Generate coverage report
coverage run -m pytest
coverage report                  # Text report
coverage html                    # HTML report
coverage xml                     # XML report

# Coverage with minimum threshold
coverage run -m pytest
coverage report --fail-under=80  # Fail if coverage < 80%
```

### Test Data Management

```python
"""Test data management utilities."""

import json
import tempfile
from pathlib import Path


class TestDataManager:
    """Manage test fixtures and data."""

    def __init__(self, base_dir="tests/fixtures"):
        self.base_dir = Path(base_dir)
        self.base_dir.mkdir(parents=True, exist_ok=True)

    def create_nmap_fixture(self, hosts, ports):
        """Create nmap XML fixture."""
        hosts_xml = ""
        for host in hosts:
            ports_xml = ""
            for port in ports:
                ports_xml += f"""
                <port protocol="tcp" portid="{port}">
                    <state state="open"/>
                    <service name="http"/>
                </port>"""

            hosts_xml += f"""
            <host>
                <address addr="{host}"/>
                <ports>{ports_xml}</ports>
            </host>"""

        xml = f'<?xml version="1.0"?>\n<nmaprun>{hosts_xml}\n</nmaprun>'

        fixture_file = self.base_dir / "nmap_fixture.xml"
        fixture_file.write_text(xml)
        return fixture_file

    def create_subfinder_fixture(self, domains):
        """Create subfinder output fixture."""
        content = "\n".join(domains)

        fixture_file = self.base_dir / "subfinder_fixture.txt"
        fixture_file.write_text(content)
        return fixture_file

    def create_nuclei_fixture(self, findings):
        """Create nuclei output fixture."""
        content = json.dumps(findings, indent=2)

        fixture_file = self.base_dir / "nuclei_fixture.json"
        fixture_file.write_text(content)
        return fixture_file

    def cleanup(self):
        """Clean up test fixtures."""
        import shutil
        if self.base_dir.exists():
            shutil.rmtree(self.base_dir)
```

---

## Real-World Examples

### Example 1: Tool Wrapper Unit Tests

```python
"""Complete unit test suite for security tool wrappers."""

import pytest
import json
from pathlib import Path
from unittest.mock import patch, MagicMock, mock_open


class TestSubfinderWrapper:
    """Tests for subfinder wrapper module."""

    def test_extract_domains_from_output(self):
        """Test domain extraction from subfinder output."""
        from tools.subfinder_wrapper import extract_domains

        output = "sub1.example.com\nsub2.example.com\nsub3.example.com"
        result = extract_domains(output)

        assert len(result) == 3
        assert "sub1.example.com" in result

    def test_extract_domains_removes_duplicates(self):
        """Test deduplication of domains."""
        from tools.subfinder_wrapper import extract_domains

        output = "sub1.example.com\nsub1.example.com\nsub2.example.com"
        result = extract_domains(output)

        assert len(result) == 2

    def test_extract_domains_filters_invalid(self):
        """Test filtering of invalid domains."""
        from tools.subfinder_wrapper import extract_domains

        output = "valid.example.com\ninvalid\nalso-valid.test.org"
        result = extract_domains(output)

        assert all("." in d for d in result)

    def test_build_subfinder_command_default(self):
        """Test default command construction."""
        from tools.subfinder_wrapper import build_command

        cmd = build_command("example.com")

        assert "subfinder" in cmd
        assert "-d" in cmd
        assert "example.com" in cmd

    def test_build_subfinder_command_with_flags(self):
        """Test command with additional flags."""
        from tools.subfinder_wrapper import build_command

        cmd = build_command("example.com", silent=True, recursive=True)

        assert "-silent" in cmd or "-s" in cmd


class TestHttpxWrapper:
    """Tests for httpx wrapper module."""

    def test_parse_httpx_json_output(self):
        """Test parsing of httpx JSON output."""
        from tools.httpx_wrapper import parse_output

        output = json.dumps([
            {"url": "http://test.com", "status_code": 200},
            {"url": "https://test.com", "status_code": 301}
        ])

        result = parse_output(output, format="json")

        assert len(result) == 2
        assert result[0]["status_code"] == 200

    def test_parse_httpx_text_output(self):
        """Test parsing of httpx text output."""
        from tools.httpx_wrapper import parse_output

        output = "http://test.com [200]\nhttps://test.com [301]"

        result = parse_output(output, format="text")

        assert len(result) == 2

    def test_filter_by_status_code(self):
        """Test filtering results by status code."""
        from tools.httpx_wrapper import filter_by_status

        results = [
            {"url": "http://a.com", "status_code": 200},
            {"url": "http://b.com", "status_code": 404},
            {"url": "http://c.com", "status_code": 200}
        ]

        filtered = filter_by_status(results, [200])

        assert len(filtered) == 2


class TestNucleiWrapper:
    """Tests for nuclei wrapper module."""

    def test_parse_nuclei_jsonl_output(self):
        """Test parsing of nuclei JSONL output."""
        from tools.nuclei_wrapper import parse_results

        output = "\n".join([
            json.dumps({"template-id": "test-1", "severity": "high", "matched-at": "http://test.com"}),
            json.dumps({"template-id": "test-2", "severity": "low", "matched-at": "http://test.com"})
        ])

        result = parse_results(output)

        assert len(result) == 2
        assert result[0]["severity"] == "high"

    def test_group_findings_by_severity(self):
        """Test grouping findings by severity."""
        from tools.nuclei_wrapper import group_by_severity

        findings = [
            {"severity": "high", "template-id": "t1"},
            {"severity": "low", "template-id": "t2"},
            {"severity": "high", "template-id": "t3"}
        ]

        grouped = group_by_severity(findings)

        assert len(grouped["high"]) == 2
        assert len(grouped["low"]) == 1

    def test_format_findings_markdown(self):
        """Test Markdown formatting of findings."""
        from tools.nuclei_wrapper import format_markdown

        findings = [
            {"severity": "high", "template-id": "test-1", "matched-at": "http://test.com"}
        ]

        result = format_markdown(findings)

        assert "high" in result.lower()
        assert "test-1" in result
```

### Example 2: Complete Test Suite Runner

```python
#!/usr/bin/env python3
"""Run the complete test suite with reporting."""

import subprocess
import sys
import json
from datetime import datetime
from pathlib import Path


class TestSuiteRunner:
    """Run complete test suite with reporting."""

    def __init__(self, project_root="."):
        self.project_root = Path(project_root)
        self.results_dir = self.project_root / "test_results"
        self.results_dir.mkdir(exist_ok=True)

    def run_smoke_tests(self):
        """Run smoke tests."""
        print("[1/5] Running smoke tests...")
        result = subprocess.run(
            [sys.executable, "-m", "pytest", "tests/smoke/",
             "-v", "--tb=short", "--json-report",
             f"--json-report-file={self.results_dir}/smoke.json"],
            capture_output=True, text=True
        )
        return result.returncode == 0

    def run_unit_tests(self):
        """Run unit tests with coverage."""
        print("[2/5] Running unit tests...")
        result = subprocess.run(
            [sys.executable, "-m", "pytest", "tests/unit/",
             "-v", "--cov=src", "--cov-report=xml",
             f"--junitxml={self.results_dir}/unit.xml"],
            capture_output=True, text=True
        )
        return result.returncode == 0

    def run_integration_tests(self):
        """Run integration tests."""
        print("[3/5] Running integration tests...")
        result = subprocess.run(
            [sys.executable, "-m", "pytest", "tests/integration/",
             "-v", "--tb=short",
             f"--junitxml={self.results_dir}/integration.xml"],
            capture_output=True, text=True
        )
        return result.returncode == 0

    def run_regression_tests(self):
        """Run regression tests."""
        print("[4/5] Running regression tests...")
        result = subprocess.run(
            [sys.executable, "-m", "pytest", "tests/regression/",
             "-v",
             f"--junitxml={self.results_dir}/regression.xml"],
            capture_output=True, text=True
        )
        return result.returncode == 0

    def run_performance_tests(self):
        """Run performance benchmarks."""
        print("[5/5] Running performance tests...")
        result = subprocess.run(
            [self.project_root / "tests" / "performance" / "run_benchmarks.py"],
            capture_output=True, text=True
        )
        return result.returncode == 0

    def generate_summary(self, results):
        """Generate test run summary."""
        summary = {
            "timestamp": datetime.now().isoformat(),
            "results": results,
            "all_passed": all(results.values())
        }

        summary_file = self.results_dir / "summary.json"
        with open(summary_file, "w") as f:
            json.dump(summary, f, indent=2)

        print(f"\n{'='*60}")
        print(f"TEST SUITE SUMMARY")
        print(f"{'='*60}")
        for suite, passed in results.items():
            status = "PASS" if passed else "FAIL"
            print(f"  [{status}] {suite}")
        print(f"\n  Overall: {'ALL PASSED' if summary['all_passed'] else 'SOME FAILED'}")
        print(f"{'='*60}\n")

        return summary

    def run_all(self):
        """Run complete test suite."""
        print(f"\n{'='*60}")
        print(f"COMPLETE TEST SUITE")
        print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*60}\n")

        results = {
            "smoke": self.run_smoke_tests(),
            "unit": self.run_unit_tests(),
            "integration": self.run_integration_tests(),
            "regression": self.run_regression_tests(),
            "performance": self.run_performance_tests()
        }

        return self.generate_summary(results)


if __name__ == "__main__":
    runner = TestSuiteRunner()
    runner.run_all()
```

### Example 3: Test Data Generator

```python
#!/usr/bin/env python3
"""Generate test data for security tool testing."""

import json
import random
import string
from pathlib import Path
from datetime import datetime


class TestDataGenerator:
    """Generate realistic test data for tool testing."""

    def __init__(self, output_dir="tests/test_data"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def generate_domains(self, count=100):
        """Generate test domain list."""
        tlds = [".com", ".org", ".net", ".test", ".example"]
        prefixes = ["www", "api", "dev", "staging", "admin", "mail", "ftp"]

        domains = []
        for _ in range(count):
            prefix = random.choice(prefixes)
            name = "".join(random.choices(string.ascii_lowercase, k=random.randint(5, 12)))
            tld = random.choice(tlds)
            domains.append(f"{prefix}.{name}{tld}")

        output_file = self.output_dir / "test_domains.txt"
        output_file.write_text("\n".join(domains))

        return output_file

    def generate_ip_addresses(self, count=100):
        """Generate test IP addresses."""
        ips = []
        for _ in range(count):
            ip = ".".join(str(random.randint(1, 254)) for _ in range(4))
            ips.append(ip)

        output_file = self.output_dir / "test_ips.txt"
        output_file.write_text("\n".join(ips))

        return output_file

    def generate_urls(self, count=100):
        """Generate test URLs."""
        protocols = ["http", "https"]
        paths = ["/", "/api", "/admin", "/login", "/dashboard", "/users"]

        urls = []
        for _ in range(count):
            protocol = random.choice(protocols)
            name = "".join(random.choices(string.ascii_lowercase, k=random.randint(5, 10)))
            path = random.choice(paths)
            urls.append(f"{protocol}://{name}.example.com{path}")

        output_file = self.output_dir / "test_urls.txt"
        output_file.write_text("\n".join(urls))

        return output_file

    def generate_nmap_xml(self, host_count=10):
        """Generate realistic nmap XML output."""
        hosts = []
        for i in range(host_count):
            ip = f"192.168.{random.randint(0, 255)}.{random.randint(1, 254)}"
            ports = random.sample([21, 22, 23, 25, 53, 80, 443, 8080, 8443],
                                 k=random.randint(2, 5))

            ports_xml = ""
            for port in ports:
                ports_xml += f"""
                <port protocol="tcp" portid="{port}">
                    <state state="open"/>
                    <service name="http" product="nginx"/>
                </port>"""

            hosts.append(f"""
            <host>
                <status state="up"/>
                <address addr="{ip}" addrtype="ipv4"/>
                <ports>{ports_xml}
                </ports>
            </host>""")

        xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<nmaprun>
{"".join(hosts)}
</nmaprun>"""

        output_file = self.output_dir / "test_nmap.xml"
        output_file.write_text(xml)

        return output_file

    def generate_nuclei_results(self, count=20):
        """Generate realistic nuclei scan results."""
        templates = [
            {"id": "tech-detect", "severity": "info"},
            {"id": "xss-reflected", "severity": "high"},
            {"id": "sql-injection", "severity": "critical"},
            {"id": "open-redirect", "severity": "medium"},
            {"id": "cve-2024-1234", "severity": "high"},
            {"id": "misconfiguration", "severity": "low"}
        ]

        findings = []
        for _ in range(count):
            template = random.choice(templates)
            finding = {
                "template-id": template["id"],
                "severity": template["severity"],
                "matched-at": f"http://test{random.randint(1,100)}.example.com",
                "host": f"test{random.randint(1,100)}.example.com",
                "ip": f"192.168.{random.randint(0,255)}.{random.randint(1,254)}",
                "timestamp": datetime.now().isoformat()
            }
            findings.append(finding)

        output_file = self.output_dir / "test_nuclei.jsonl"
        with open(output_file, "w") as f:
            for finding in findings:
                f.write(json.dumps(finding) + "\n")

        return output_file

    def generate_all(self):
        """Generate all test data."""
        print("Generating test data...")
        print(f"  Domains: {self.generate_domains()}")
        print(f"  IPs: {self.generate_ip_addresses()}")
        print(f"  URLs: {self.generate_urls()}")
        print(f"  Nmap XML: {self.generate_nmap_xml()}")
        print(f"  Nuclei Results: {self.generate_nuclei_results()}")
        print("Done!")


if __name__ == "__main__":
    generator = TestDataGenerator()
    generator.generate_all()
```

---

## Common Pitfalls

### Pitfall 1: Flaky Tests

**Problem**: Tests that pass sometimes and fail other times due to timing, network, or state issues.

**Prevention**:
```python
# Use fixed seeds for random operations
import random
random.seed(42)

# Use timeouts for network operations
@pytest.mark.timeout(30)
def test_network_operation():
    pass

# Use fixtures with proper cleanup
@pytest.fixture
def temp_file():
    with tempfile.NamedTemporaryFile(delete=False) as f:
        yield f.name
    os.unlink(f.name)
```

### Pitfall 2: Test Interdependence

**Problem**: Tests that depend on other tests or shared state.

**Prevention**:
```python
# Each test should be independent
@pytest.fixture(autouse=True)
def reset_state():
    """Reset state before each test."""
    yield
    # Cleanup after each test

# Use fresh fixtures for each test
@pytest.fixture
def fresh_workspace(tmp_path):
    """Create fresh workspace for each test."""
    return tmp_path / "workspace"
```

### Pitfall 3: Slow Test Suite

**Problem**: Test suite takes too long to run, discouraging frequent testing.

**Prevention**:
```bash
# Use parallel execution
pytest -n auto

# Mark slow tests
@pytest.mark.slow
def test_heavy_operation():
    pass

# Run fast tests first
pytest -m "not slow"
```

### Pitfall 4: Unclear Failure Messages

**Problem**: Test failures don't provide enough context to diagnose issues.

**Prevention**:
```python
# Use descriptive assertions
assert result is not None, f"Expected result, got None for input: {input_data}"

# Add context to failures
def test_parse_output():
    output = "invalid format"
    with pytest.raises(ValueError) as exc_info:
        parse_output(output)
    assert "Invalid format" in str(exc_info.value)
```

### Pitfall 5: Missing Edge Cases

**Problem**: Tests only cover happy path, missing error conditions.

**Prevention**:
```python
# Test error conditions
def test_parse_empty_input():
    result = parse_input("")
    assert result == []

def test_parse_invalid_format():
    result = parse_input("not valid")
    assert result is None

def test_parse_large_input():
    large_input = "x" * 1000000
    result = parse_input(large_input)
    assert result is not None
```

---

## Advanced Techniques

### Mutation Testing

```python
"""Mutation testing to verify test suite effectiveness."""

import subprocess
import sys
from pathlib import Path


class MutationTester:
    """Run mutation testing to verify test quality."""

    def __init__(self, source_dir="src", test_dir="tests"):
        self.source_dir = Path(source_dir)
        self.test_dir = Path(test_dir)

    def run_mutation_testing(self):
        """Run mutation testing using mutmut."""
        result = subprocess.run(
            [sys.executable, "-m", "mutmut", "run",
             f"--paths-to-mutate={self.source_dir}",
             f"--tests-dir={self.test_dir}"],
            capture_output=True, text=True
        )

        return result.returncode == 0

    def generate_report(self):
        """Generate mutation testing report."""
        result = subprocess.run(
            [sys.executable, "-m", "mutmut", "results"],
            capture_output=True, text=True
        )

        return result.stdout


if __name__ == "__main__":
    tester = MutationTester()
    tester.run_mutation_testing()
    print(tester.generate_report())
```

### Contract Testing

```python
"""Contract testing for tool output schemas."""

import json
import jsonschema
from pathlib import Path


class ContractTester:
    """Validate tool outputs against expected schemas."""

    def __init__(self, schemas_dir="tests/schemas"):
        self.schemas_dir = Path(schemas_dir)

    def load_schema(self, tool_name):
        """Load output schema for a tool."""
        schema_file = self.schemas_dir / f"{tool_name}_schema.json"
        with open(schema_file) as f:
            return json.load(f)

    def validate_output(self, tool_name, output):
        """Validate tool output against schema."""
        schema = self.load_schema(tool_name)

        try:
            jsonschema.validate(instance=output, schema=schema)
            return True, None
        except jsonschema.ValidationError as e:
            return False, str(e)

    def test_all_schemas(self):
        """Test all registered tool schemas."""
        results = {}

        for schema_file in self.schemas_dir.glob("*_schema.json"):
            tool_name = schema_file.stem.replace("_schema", "")
            schema = self.load_schema(tool_name)

            results[tool_name] = {
                "valid": True,
                "schema": schema
            }

        return results
```

### Test Analytics Dashboard

```python
"""Test analytics and trend tracking."""

import json
from datetime import datetime, timedelta
from pathlib import Path


class TestAnalytics:
    """Analyze test results over time."""

    def __init__(self, history_dir="test_history"):
        self.history_dir = Path(history_dir)
        self.history_dir.mkdir(exist_ok=True)

    def record_results(self, results):
        """Record test results for trend analysis."""
        record = {
            "timestamp": datetime.now().isoformat(),
            "results": results
        }

        filename = f"results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(self.history_dir / filename, "w") as f:
            json.dump(record, f, indent=2)

    def get_trends(self, days=30):
        """Get test trends over specified period."""
        cutoff = datetime.now() - timedelta(days=days)
        trends = []

        for result_file in sorted(self.history_dir.glob("results_*.json")):
            with open(result_file) as f:
                record = json.load(f)

            record_time = datetime.fromisoformat(record["timestamp"])
            if record_time > cutoff:
                trends.append(record)

        return trends

    def calculate_pass_rate_trend(self, trends):
        """Calculate pass rate trend."""
        rates = []
        for trend in trends:
            total = sum(trend["results"].values())
            passed = trend["results"].get("passed", 0)
            rate = (passed / total * 100) if total > 0 else 0
            rates.append(rate)

        return {
            "average": sum(rates) / len(rates) if rates else 0,
            "trend": "improving" if len(rates) > 1 and rates[-1] > rates[0] else "stable",
            "data_points": rates
        }
```

---

## Reporting Template

### Test Execution Report

```
# Test Execution Report

**Date**: [DATE]
**Pipeline Run**: [RUN_ID]
**Duration**: [DURATION]

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | [N] |
| Passed | [N] |
| Failed | [N] |
| Errors | [N] |
| Skipped | [N] |
| Pass Rate | [X]% |
| Coverage | [X]% |

## Test Suite Breakdown

| Suite | Tests | Passed | Failed | Duration |
|-------|-------|--------|--------|----------|
| Smoke | [N] | [N] | [N] | [T]s |
| Unit | [N] | [N] | [N] | [T]s |
| Integration | [N] | [N] | [N] | [T]s |
| Regression | [N] | [N] | [N] | [T]s |
| Performance | [N] | [N] | [N] | [T]s |

## Failures

| Test | Error Message | Stack Trace |
|------|---------------|-------------|
| [test_name] | [error] | [trace] |

## Coverage Report

| Module | Coverage | Missing Lines |
|--------|----------|---------------|
| [module] | [X]% | [lines] |

## Performance Benchmarks

| Benchmark | Result | Baseline | Change |
|-----------|--------|----------|--------|
| [benchmark] | [T]s | [T]s | [+/-X]% |

## Trends

| Metric | This Run | Last Run | Change |
|--------|----------|----------|--------|
| Pass Rate | [X]% | [X]% | [+/-X]% |
| Coverage | [X]% | [X]% | [+/-X]% |

## Recommendations

1. [recommendation_1]
2. [recommendation_2]
3. [recommendation_3]
```

---

## Quick Reference

### Test Commands Cheat Sheet

```bash
# Run tests
pytest                          # All tests
pytest -v                       # Verbose
pytest -x                       # Stop on first failure
pytest -m smoke                 # Smoke tests only
pytest -m "not slow"            # Skip slow tests
pytest -n auto                  # Parallel execution

# Coverage
pytest --cov=src --cov-report=html
coverage report --fail-under=80

# Reporting
pytest --junitxml=results.xml
pytest --json-report --json-report-file=results.json

# Mutation testing
mutmut run
mutmut results

# Benchmarks
pytest --benchmark-only
pytest --benchmark-compare
```

### Test File Organization

```
tests/
  __init__.py
  conftest.py              # Shared fixtures
  smoke/                   # Quick health checks
    test_tools_exist.py
    test_basic_imports.py
  unit/                    # Individual function tests
    test_nmap_parser.py
    test_subfinder.py
    test_httpx.py
    test_nuclei.py
  integration/             # Tool interaction tests
    test_recon_pipeline.py
    test_vuln_scan.py
  regression/              # Behavior consistency
    test_output_format.py
    test_parsing_stability.py
  performance/             # Benchmarks
    test_parsing_speed.py
    test_pipeline_speed.py
  fixtures/                # Test data
    nmap_sample.xml
    subfinder_sample.txt
    nuclei_sample.json
  schemas/                 # Contract schemas
    nmap_output_schema.json
    httpx_output_schema.json
```

### Test Markers Reference

| Marker | Description | When to Use |
|--------|-------------|-------------|
| `@pytest.mark.smoke` | Quick health checks | Every commit |
| `@pytest.mark.unit` | Unit tests | Every commit |
| `@pytest.mark.integration` | Integration tests | Before merge |
| `@pytest.mark.regression` | Regression tests | Before release |
| `@pytest.mark.performance` | Performance benchmarks | Weekly |
| `@pytest.mark.slow` | Long-running tests | Nightly |
| `@pytest.mark.network` | Requires network | CI only |

---

*Last Updated: [DATE]*
*Version: 2.0*
*Author: Testing Automation Guide v2*
