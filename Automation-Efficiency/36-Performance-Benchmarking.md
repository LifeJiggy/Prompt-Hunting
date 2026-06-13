# 36 â€” Performance Benchmarking

## 1. Introduction

Performance benchmarking in automated security tooling ensures that every pipeline stage â€” subdomain enumeration, vulnerability scanning, result triage, reporting â€” operates within predictable latency and accuracy bounds. Without benchmarks, teams cannot distinguish a slow scanner from a broken one, nor can they prove that a new version of a tool is genuinely faster rather than merely skipping checks. This document establishes a reproducible benchmarking harness, defines normalization procedures, and provides comparison matrices and regression suites that can be integrated into CI/CD.

---

## 2. Measuring Tool Overhead

Tool overhead is the difference between wall-clock time spent inside the tool and total pipeline time including orchestration, serialization, and I/O. Measuring it precisely requires instrumentation at the boundary.

```python
import time
import psutil
import os
from dataclasses import dataclass, field
from typing import List

@dataclass
class OverheadSample:
    tool_name: str
    wall_clock_s: float
    cpu_time_s: float
    memory_peak_mb: float
    input_bytes: int = 0
    output_bytes: int = 0

    @property
    def overhead_ratio(self) -> float:
        return self.cpu_time_s / self.wall_clock_s if self.wall_clock_s > 0 else 0.0

def measure_tool_overhead(command_fn, tool_name: str) -> OverheadSample:
    proc = psutil.Process(os.getpid())
    mem_before = proc.memory_info().rss / 1024 / 1024
    cpu_before = time.process_time()
    wall_before = time.perf_counter()
    result = command_fn()
    wall_after = time.perf_counter()
    cpu_after = time.process_time()
    mem_after = proc.memory_info().rss / 1024 / 1024
    input_bytes = len(str(result.get("input", ""))) if isinstance(result, dict) else 0
    output_bytes = len(str(result.get("output", ""))) if isinstance(result, dict) else 0
    return OverheadSample(
        tool_name=tool_name,
        wall_clock_s=round(wall_after - wall_before, 4),
        cpu_time_s=round(cpu_after - cpu_before, 4),
        memory_peak_mb=round(max(mem_before, mem_after), 2),
        input_bytes=input_bytes,
        output_bytes=output_bytes,
    )
```

**Key metrics to collect:**
- `wall_clock_s`: End-to-end latency including I/O wait.
- `cpu_time_s`: Actual CPU consumption; ratio to wall-clock reveals I/O-bound vs CPU-bound behavior.
- `memory_peak_mb`: Peak RSS; identifies memory leaks in long-running scanners.
- `throughput_mb_s`: `output_bytes / wall_clock_s`; useful for data-extraction tools.
- `overhead_ratio`: `cpu_time_s / wall_clock_s`; values > 0.9 indicate CPU saturation.

---

## 3. Ranking Tool Performance

When multiple tools solve the same problem (e.g., subdomain enumeration with `subfinder`, `amass`, `assetfinder`), ranking requires a composite score that balances speed, coverage, and accuracy.

```python
import statistics
from dataclasses import dataclass, field
from typing import List

@dataclass
class ToolRankEntry:
    tool_name: str
    latency_p50_ms: float
    latency_p99_ms: float
    recall: float          # fraction of ground-truth items found
    precision: float       # fraction of reported items that are real
    cpu_cores: int = 1
    memory_mb: float = 0.0

    def composite_score(self, weights: dict = None) -> float:
        w = weights or {
            "latency": 0.25,
            "recall": 0.40,
            "precision": 0.25,
            "efficiency": 0.10,
        }
        latency_score = 1.0 / (1.0 + self.latency_p50_ms / 1000.0)
        efficiency = self.recall / (self.cpu_cores * self.memory_mb + 1)
        return (
            w["latency"] * latency_score
            + w["recall"] * self.recall
            + w["precision"] * self.precision
            + w["efficiency"] * min(efficiency, 1.0)
        )

def rank_tools(entries: List[ToolRankEntry]) -> List[ToolRankEntry]:
    return sorted(entries, key=lambda e: e.composite_score(), reverse=True)
```

**Ranking dimensions:**
- **Latency**: Use p50 and p99 rather than mean; outliers distort averages.
- **Recall**: Determined by running each tool against a curated, versioned ground-truth dataset.
- **Precision**: Measured by manual or automated validation of a sample of reported items.
- **Efficiency**: Recall normalized by resource consumption (CPU Ã— memory).

---

## 4. Comparison Matrices

A comparison matrix presents tool capabilities side-by-side across standardized dimensions. Maintain the matrix in Markdown for version control and convert to CSV/JSON for dashboards.

| Tool | p50 Latency | p99 Latency | Recall | Precision | CPU Cores | Memory (MB) | Composite Score |
|------|-------------|-------------|--------|-----------|-----------|-------------|-----------------|
| subfinder | 320 | 580 | 0.91 | 0.76 | 4 | 128 | 0.83 |
| amass | 2100 | 4500 | 0.96 | 0.82 | 8 | 512 | 0.77 |
| assetfinder | 150 | 290 | 0.78 | 0.68 | 2 | 64 | 0.74 |
| findomain | 90 | 180 | 0.85 | 0.71 | 2 | 48 | 0.81 |

**Matrix best practices:**
- Freeze the benchmark dataset version in the matrix header.
- Include a `last_updated` timestamp and benchmark runner version.
- Highlight best-in-class values with bold or color in rendered output.
- Separate "single-run" metrics from "steady-state" (warm-cache) metrics.

---

## 5. Enobench Harnesses

Enobench (Enumerated Benchmark) harnesses provide a controlled, reproducible environment with a known set of targets and expected outputs. The harness orchestrates tool execution, captures metrics, and diffs results against a baseline.

```python
import json
import hashlib
import subprocess
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import List

@dataclass
class EnobenchCase:
    case_id: str
    description: str
    tool: str
    args: List[str]
    input_target: str
    expected_min_recall: float = 0.0
    timeout_s: int = 120
    tags: List[str] = field(default_factory=list)

class EnobenchHarness:
    def __init__(self, baseline_dir: Path, results_dir: Path):
        self.baseline_dir = Path(baseline_dir)
        self.results_dir = Path(results_dir)
        self.results_dir.mkdir(parents=True, exist_ok=True)

    def run_case(self, case: EnobenchCase) -> dict:
        output_file = self.results_dir / f"{case.case_id}.json"
        start = time.perf_counter()
        try:
            proc = subprocess.run(
                [case.tool] + case.args,
                input=case.input_target,
                capture_output=True,
                text=True,
                timeout=case.timeout_s,
            )
            latency = time.perf_counter() - start
            results = proc.stdout.strip().splitlines()
            recall = self._compute_recall(results, case.case_id)
            passed = recall >= case.expected_min_recall
            record = {
                "case_id": case.case_id,
                "tool": case.tool,
                "latency_s": round(latency, 4),
                "recall": round(recall, 4),
                "passed": passed,
                "result_count": len(results),
                "returncode": proc.returncode,
                "stderr_tail": proc.stderr[-500:] if proc.stderr else "",
            }
        except subprocess.TimeoutExpired:
            record = {
                "case_id": case.case_id,
                "tool": case.tool,
                "latency_s": case.timeout_s,
                "recall": 0.0,
                "passed": False,
                "result_count": 0,
                "returncode": -1,
                "stderr_tail": "TIMEOUT",
            }
        output_file.write_text(json.dumps(record, indent=2))
        return record

    def _compute_recall(self, results: List[str], case_id: str) -> float:
        baseline_file = self.baseline_dir / f"{case_id}.txt"
        if not baseline_file.exists():
            return 0.0
        ground_truth = set(baseline_file.read_text().strip().splitlines())
        found = set(results)
        if not ground_truth:
            return 0.0
        return len(ground_truth & found) / len(ground_truth)
```

**Harness structure:**
- `baseline_dir/`: Contains expected-output text files (one per case) and case metadata.
- `results_dir/`: Stores JSON result records for each run.
- Case IDs should be stable across benchmark versions to allow trend comparison.

---

## 6. Regression Benchmarks

Regression benchmarks detect performance degradations between versions. Store historical results and flag runs where any metric deviates beyond a threshold.

```python
import json
from pathlib import Path
from dataclasses import dataclass
from typing import Optional

REGRESSION_THRESHOLD_LATENCY_PCT = 20.0
REGRESSION_THRESHOLD_RECALL_PCT = 5.0

@dataclass
class RegressionResult:
    case_id: str
    metric: str
    baseline_value: float
    current_value: float
    delta_pct: float
    severity: str  # "ok" | "warning" | "critical"

def check_regression(
    baseline: dict,
    current: dict,
    latency_threshold: float = REGRESSION_THRESHOLD_LATENCY_PCT,
    recall_threshold: float = REGRESSION_THRESHOLD_RECALL_PCT,
) -> List[RegressionResult]:
    findings = []
    if baseline["case_id"] != current["case_id"]:
        raise ValueError("Case ID mismatch")
    case_id = baseline["case_id"]
    if baseline["passed"] and not current["passed"]:
        findings.append(RegressionResult(
            case_id=case_id, metric="passed",
            baseline_value=1.0, current_value=0.0,
            delta_pct=100.0, severity="critical",
        ))
    if baseline["latency_s"] > 0:
        delta = ((current["latency_s"] - baseline["latency_s"]) / baseline["latency_s"]) * 100
        sev = "critical" if delta > latency_threshold else "warning" if delta > latency_threshold / 2 else "ok"
        if sev != "ok":
            findings.append(RegressionResult(case_id, "latency_s", baseline["latency_s"], current["latency_s"], round(delta, 2), sev))
    if baseline["recall"] > 0:
        delta = ((baseline["recall"] - current["recall"]) / baseline["recall"]) * 100
        sev = "critical" if delta > recall_threshold else "warning" if delta > recall_threshold / 2 else "ok"
        if sev != "ok":
            findings.append(RegressionResult(case_id, "recall", baseline["recall"], current["recall"], round(delta, 2), sev))
    return findings
```

**Regression policy:**
- Any `critical` finding blocks the release pipeline.
- `warning` findings are tracked as technical debt with a 30-day remediation SLA.
- Baseline records are tagged with the tool version and benchmark harness version.

---

## 7. Environment Normalization

Benchmark results are meaningless without controlling for environment variables: CPU throttling, thermal limits, disk I/O contention, network jitter, and OS scheduler behavior all introduce noise.

**Normalization checklist:**
1. **CPU governor**: Set to `performance` mode on Linux (`cpupower frequency-set -g performance`). On Windows, disable "Processor power management" in group policy.
2. **Thermal**: Ensure the machine is below 70Â°C before each benchmark run. Use `sensors` (Linux) or `Get-WmiObject MSAcpi_ThermalZoneTemperature` (Python).
3. **Disk I/O**: Run on a dedicated NVMe volume with no concurrent writes. Pre-warm files into page cache before timing.
4. **Network**: Use a local mock server or recorded HAR replay for network-dependent tools. Never benchmark live DNS lookups against public resolvers without pinning the resolver IP.
5. **OS scheduler**: Pin benchmark processes to isolated CPU cores using `taskset` (Linux) or `Start-Process -ProcessorAffinity` (Python).
6. **Background load**: Kill non-essential processes. Use `nice`/`renice` to lower priority of unavoidable system daemons.
7. **Containerization**: For maximum reproducibility, run inside a Docker container with `--cpus`, `--memory`, and `--ulimit` constraints fixed.

```dockerfile
# Dockerfile for normalized benchmark environment
FROM python:3.12-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps psutil && rm -rf /var/lib/apt/lists/*
WORKDIR /bench
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY harness/ ./harness/
# Disable Python output buffering for accurate timing
ENV PYTHONUNBUFFERED=1
# Pin to 4 CPU cores, 8GB RAM
# docker run --cpus=4 --memory=8g ...
```

**Normalization metadata to record with every benchmark run:**
```json
{
  "benchmark_version": "2.1.0",
  "host_cpu": "AMD Ryzen 9 7950X",
  "host_cores": 16,
  "host_ram_gb": 64,
  "os": "Ubuntu 24.04",
  "kernel": "6.8.0-45-generic",
  "cpu_governor": "performance",
  "thermal_celsius": 58,
  "container_cpus": 4,
  "container_memory_mb": 8192,
  "network": "mock-local",
  "disk": "NVMe SN850X",
  "python_version": "3.12.4",
  "env_vars": {"PYTHONUNBUFFERED": "1"}
}
```

---

## 8. Throughput / Accuracy Tradeoff Analysis

Most security scanners can trade accuracy for speed by adjusting concurrency, depth limits, or signature sets. Quantifying this tradeoff enables teams to pick the right operating point for each pipeline stage.

```python
import csv
from pathlib import Path
from dataclasses import dataclass
from typing import List

@dataclass
class ThroughputAccuracyPoint:
    concurrency: int
    timeout_s: float
    throughput_req_s: float
    recall: float
    precision: float
    f1: float = 0.0

    def __post_init__(self):
        if self.recall + self.precision > 0:
            self.f1 = (
                2 * self.recall * self.precision
                / (self.recall + self.precision)
            )

def run_tradeoff_sweep(
    tool: str,
    base_args: List[str],
    concurrencies: List[int],
    timeouts: List[float],
    ground_truth: set,
    validate_fn,
) -> List[ThroughputAccuracyPoint]:
    points = []
    for c in concurrencies:
        for t in timeouts:
            args = base_args + ["--concurrency", str(c), "--timeout", str(t)]
            results, latency = execute_tool(tool, args)
            throughput = len(results) / latency if latency > 0 else 0
            recall = len(set(results) & ground_truth) / len(ground_truth) if ground_truth else 0
            precision = validate_fn(results)
            points.append(ThroughputAccuracyPoint(
                concurrency=c, timeout_s=t,
                throughput_req_s=round(throughput, 2),
                recall=round(recall, 4),
                precision=round(precision, 4),
            ))
    return points

def save_tradeoff_csv(points: List[ThroughputAccuracyPoint], path: Path):
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "concurrency", "timeout_s", "throughput_req_s", "recall", "precision", "f1"
        ])
        writer.writeheader()
        for p in points:
            writer.writerow({
                "concurrency": p.concurrency,
                "timeout_s": p.timeout_s,
                "throughput_req_s": p.throughput_req_s,
                "recall": p.recall,
                "precision": p.precision,
                "f1": round(p.f1, 4),
            })
```

**Interpreting the tradeoff curve:**
- Plot F1 score vs. throughput. The "knee" of the curve (where F1 plateaus) is the optimal operating point.
- A flat F1 with rising throughput indicates headroom to increase concurrency.
- A steep F1 drop with rising throughput indicates the tool is skipping checks under load.
- Document the chosen operating point as a **performance budget** (see next section).

---

## 9. Performance Budgets

A performance budget is a contract stating the maximum acceptable latency, resource usage, and accuracy degradation for each pipeline stage. Budgets should be enforced in CI.

```yaml
# .github/workflows/performance-budget.yml
name: Performance Budget
on: [pull_request]

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Enobench harness
        run: python harness/run.py --output results.json
      - name: Check budgets
        run: python harness/check_budgets.py results.json budgets.yaml
        env:
          BUDGET_FAIL_ON: "critical"
```

```yaml
# budgets.yaml â€” performance budget definitions
stages:
  subdomain_enum:
    wall_clock_s:
      p50: 600
      p99: 1800
    memory_mb: 1024
    recall_min: 0.85
    precision_min: 0.60
  port_scan:
    wall_clock_s:
      p50: 900
      p99: 3000
    memory_mb: 2048
    recall_min: 0.80
  vuln_scan:
    wall_clock_s:
      p50: 2400
      p99: 7200
    memory_mb: 4096
    recall_min: 0.70
    precision_min: 0.75
```

**Budget enforcement rules:**
- New PRs must pass all budget checks.
- Budget updates require a `benchmark-update` PR label and a documented rationale.
- Budgets are reviewed quarterly; stale budgets are archived, not deleted.

---

## 10. Benchmark Database Schema

Persist benchmark results for long-term trend analysis:

```sql
CREATE TABLE benchmark_runs (
    run_id          UUID PRIMARY KEY,
    tool_name       TEXT NOT NULL,
    tool_version    TEXT NOT NULL,
    benchmark_version TEXT NOT NULL,
    case_id         TEXT NOT NULL,
    latency_s       DOUBLE PRECISION,
    cpu_time_s      DOUBLE PRECISION,
    memory_peak_mb  DOUBLE PRECISION,
    recall          DOUBLE PRECISION,
    precision       DOUBLE PRECISION,
    passed          BOOLEAN,
    returncode      INTEGER,
    env_json        JSONB,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_benchmark_runs_tool_case
    ON benchmark_runs (tool_name, case_id, created_at DESC);

CREATE TABLE benchmark_budgets (
    tool_name       TEXT NOT NULL,
    case_id         TEXT NOT NULL,
    metric          TEXT NOT NULL,
    threshold       DOUBLE PRECISION NOT NULL,
    severity        TEXT NOT NULL CHECK (severity IN ('warning','critical')),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (tool_name, case_id, metric)
);
```

---

## 11. Continuous Benchmarking in CI

Integrate benchmarks into every CI pipeline so regressions are caught before merge:

```yaml
# .gitlab-ci.yml snippet
benchmark_job:
  stage: test
  image: python:3.12-slim
  variables:
    BENCH_OUTPUT: "bench-results.json"
    BASELINE_BRANCH: "main"
  script:
    - pip install -r requirements.txt
    - python harness/run.py --output $BENCH_OUTPUT
    - python harness/regression_check.py $BENCH_OUTPUT baseline/$BASELINE_BRANCH/
  artifacts:
    paths: [bench-results.json]
    expire_in: 30 days
  only:
    - merge_requests
    - main
```

**CI benchmark rules:**
1. Run on every PR touching tooling, harness, or dependency files.
2. Compare against the `main` branch baseline, not the merge-base.
3. Fail CI on any `critical` regression; warn on `warning`.
4. Archive results as CI artifacts for 30 days minimum.
5. Post benchmark deltas as PR comments using the harness reporter.

---

## 12. Common Pitfalls

- **Warm-up effects**: First-run latency includes JIT compilation (Java, Python), cache population, and disk seeks. Always discard the first run and report the mean of 3â€“5 warm runs.
- **GC interference**: Java and Go GC pauses can inflate p99 latency. Disable concurrent GC (`-XX:+UseSerialGC`) for deterministic benchmarks, and report GC pause time separately.
- **Network dependency**: Never benchmark against production infrastructure; use local mocks or recorded traffic replays.
- **Sample size**: One run per configuration is not a benchmark. Minimum 5 runs; report mean Â± stddev.
- **Tool version drift**: Pin every tool binary and container image by digest SHA in the benchmark config.

---

## 13. Summary

Performance benchmarking is a discipline, not a one-time task. A mature benchmarking practice includes normalized environments, reproducible harnesses, composite ranking, regression gates in CI, and documented performance budgets. The artifacts â€” comparison matrices, harness output, regression reports â€” become evidence that the security automation stack is reliable, fast, and improving over time.

