# Automation-Efficiency 2: Tool Chaining Strategies

## Expert Role

You are a Principal Security Pipeline Engineer who has built and operated tool chaining systems for enterprise-scale bug bounty programs. You specialize in designing data flow architectures that connect reconnaissance tools, vulnerability scanners, analysis engines, and reporting systems into seamless pipelines. Your expertise covers sequential chaining, parallel fan-out/fan-in patterns, conditional routing, and error recovery across heterogeneous tool ecosystems.

Your core belief: a tool's output is only as valuable as the pipeline that consumes it. Every tool must have a well-defined output schema, every consumer must have robust parsing, and every connection must handle failures gracefully.

---

## Core Concepts

### What is Tool Chaining?

Tool chaining is the practice of connecting multiple security tools such that the output of one tool becomes the input of the next, creating an automated data flow from raw reconnaissance to actionable findings. Unlike simple scripting (running tools in sequence), tool chaining requires:

- **Standardized data formats** between tools
- **Error propagation** handling
- **Intermediate state management**
- **Parallel execution** where possible
- **Data transformation** between incompatible formats

### The Data Flow Pipeline Model

```
[Source] -> [Transform] -> [Filter] -> [Enrich] -> [Analyze] -> [Report]
    |           |            |           |            |           |
  subfinder    httpx       grep       nuclei      custom      markdown
  amass        jq         awk        custom      python      json
  crtsh        sed        python     api calls    regex       csv
```

### Chaining Patterns

**Pattern 1: Linear Chain**
```
A -> B -> C -> D
```
Simple, sequential. Each step depends on the previous. Easy to debug, hard to parallelize.

**Pattern 2: Fan-Out / Fan-In**
```
       -> B -> 
A ->        -> E
       -> C ->
       -> D ->
```
One source feeds multiple parallel processors. Results aggregate at the end.

**Pattern 3: Conditional Routing**
```
A -> [if web] -> B
A -> [if api] -> C
A -> [if network] -> D
```
Different paths based on input characteristics.

**Pattern 4: Iterative Refinement**
```
A -> B -> [if not enough] -> A' -> B -> [if not enough] -> A'' -> ...
```
Repeat until a quality threshold is met.

**Pattern 5: Scatter-Gather**
```
A -> [B1, B2, B3, ...] -> C (merge)
```
Distribute work across multiple instances, gather results.

### The Standardized Interface Contract

Every tool in a chain must adhere to:

```python
from dataclasses import dataclass
from typing import Any, Dict, List, Optional
from enum import Enum

class ToolStatus(Enum):
    SUCCESS = "success"
    PARTIAL = "partial"
    FAILED = "failed"
    SKIPPED = "skipped"

@dataclass
class ToolOutput:
    """Standard output format for all tools in the chain."""
    tool_name: str
    status: ToolStatus
    data: Any  # Tool-specific structured data
    raw_output: str  # Original stdout/stderr
    metadata: Dict[str, Any]  # Execution metadata
    errors: List[str] = None

    def __post_init__(self):
        if self.errors is None:
            self.errors = []

    def is_usable(self) -> bool:
        return self.status in (ToolStatus.SUCCESS, ToolStatus.PARTIAL)

    def to_next_input(self, format: str = "json") -> str:
        """Serialize for next tool in chain."""
        import json
        if format == "json":
            return json.dumps(self.data, indent=2)
        elif format == "newline":
            if isinstance(self.data, list):
                return "\n".join(str(item) for item in self.data)
            return str(self.data)
        return str(self.data)
```

### Key Metrics for Chain Performance

| Metric | Description | Target |
|--------|-------------|--------|
| End-to-end latency | Total time from start to finish | < 30 minutes |
| Tool utilization | % of time each tool is active | > 70% |
| Data loss | % of input data not reaching output | < 1% |
| Error recovery rate | % of errors successfully retried | > 80% |
| Cache hit rate | % of executions served from cache | > 40% |

---

## Prerequisites

### Required Knowledge
- Python 3.8+ (intermediate to advanced)
- Understanding of subprocess management and pipes
- Familiarity with JSON, YAML, and CSV data formats
- Basic networking (HTTP, DNS, TCP/IP)
- Knowledge of common security tools (subfinder, httpx, nuclei, ffuf, nmap)

### Required Tools

```bash
# Python packages
pip install pydantic rich click pyyaml jinja2

# Security tools (install via go or package manager)
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/ffuf/ffuf/v2@latest

# Utility tools
pip install tabulate jq  # For data transformation
```

### Environment Validation

```python
# validate_env.py
"""Validate that all required tools are installed and accessible."""

import subprocess
import shutil
import sys

REQUIRED_TOOLS = {
    "subfinder": "subfinder -version",
    "httpx": "httpx -version",
    "nuclei": "nuclei -version",
    "ffuf": "ffuf -V",
    "python": "python --version",
    "jq": "jq --version",
}

def validate_environment():
    missing = []
    for tool, cmd in REQUIRED_TOOLS.items():
        if shutil.which(tool) is None:
            missing.append(tool)
        else:
            try:
                result = subprocess.run(
                    cmd.split(), capture_output=True, text=True, timeout=10
                )
                print(f"  [OK] {tool}")
            except Exception:
                print(f"  [WARN] {tool} installed but version check failed")

    if missing:
        print(f"\n[ERROR] Missing tools: {', '.join(missing)}")
        sys.exit(1)
    print("\nAll tools validated successfully.")

if __name__ == "__main__":
    validate_environment()
```

---

## Methodology

### Step 1: Design Your Data Contracts

Define what each tool produces and consumes:

```python
# data_contracts.py
"""Define input/output contracts for each tool in the chain."""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from enum import Enum

class SubfinderOutput(BaseModel):
    subdomains: List[str] = Field(description="Discovered subdomains")
    source_counts: Dict[str, int] = Field(
        default_factory=dict,
        description="Count per source (virustotal, shodan, etc.)"
    )

class HttpxOutput(BaseModel):
    live_hosts: List[Dict[str, Any]] = Field(
        description="Live host details",
        examples=[[{
            "url": "https://api.example.com",
            "status_code": 200,
            "content_length": 1234,
            "tech": ["nginx", "python"],
            "title": "API Endpoint"
        }]]
    )

class NucleiOutput(BaseModel):
    findings: List[Dict[str, Any]] = Field(
        description="Vulnerability findings",
        examples=[[{
            "template_id": "xss-reflected",
            "severity": "high",
            "host": "https://example.com",
            "matched_at": "https://example.com/search?q=test",
            "extracted_results": []
        }]]
    )

class FfufOutput(BaseModel):
    endpoints: List[Dict[str, Any]] = Field(
        description="Discovered endpoints",
        examples=[[{
            "url": "https://example.com/admin",
            "status": 200,
            "length": 5678,
            "words": 123
        }]]
    )

class ChainConfig(BaseModel):
    """Configuration for the entire tool chain."""
    target: str
    scope: List[str] = []
    tools: Dict[str, Dict[str, Any]] = {}
    output_format: str = "json"
    parallel_enabled: bool = True
    cache_enabled: bool = True
    rate_limit: int = 10  # requests per second
    timeout: int = 300  # seconds per tool
```

### Step 2: Build the Tool Executor

```python
# tool_executor.py
"""Execute security tools with standardized I/O and error handling."""

import subprocess
import json
import time
import logging
import tempfile
from pathlib import Path
from typing import Any, Dict, List, Optional
from dataclasses import dataclass

logger = logging.getLogger("tool_executor")


@dataclass
class ExecutionResult:
    tool: str
    command: str
    return_code: int
    stdout: str
    stderr: str
    duration: float
    output_file: Optional[str] = None

    @property
    def success(self) -> bool:
        return self.return_code == 0

    def parse_json(self) -> Any:
        """Parse stdout as JSON."""
        try:
            return json.loads(self.stdout)
        except json.JSONDecodeError:
            return None

    def parse_jsonl(self) -> List[Any]:
        """Parse stdout as newline-delimited JSON."""
        results = []
        for line in self.stdout.strip().split("\n"):
            if line.strip():
                try:
                    results.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
        return results


class ToolExecutor:
    """Execute and manage security tool invocations."""

    def __init__(self, work_dir: str = "./tool_workdir"):
        self.work_dir = Path(work_dir)
        self.work_dir.mkdir(parents=True, exist_ok=True)
        self.execution_log: List[ExecutionResult] = []

    def execute(self, tool: str, args: List[str],
                input_data: str = None,
                output_file: str = None,
                timeout: int = 300,
                parse_as: str = "json") -> ExecutionResult:
        """Execute a tool with optional stdin input."""
        cmd = [tool] + args
        cmd_str = " ".join(cmd)

        if output_file:
            cmd.extend(["-o", output_file])

        logger.info(f"Executing: {cmd_str}")
        start_time = time.time()

        try:
            proc = subprocess.run(
                cmd,
                input=input_data,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            duration = time.time() - start_time

            result = ExecutionResult(
                tool=tool,
                command=cmd_str,
                return_code=proc.returncode,
                stdout=proc.stdout,
                stderr=proc.stderr,
                duration=duration,
                output_file=output_file
            )

            self.execution_log.append(result)

            if result.success:
                logger.info(f"  Completed in {duration:.2f}s")
            else:
                logger.warning(f"  Failed (code {proc.returncode}): {proc.stderr[:200]}")

            return result

        except subprocess.TimeoutExpired:
            duration = time.time() - start_time
            logger.error(f"  Timeout after {timeout}s")
            result = ExecutionResult(
                tool=tool, command=cmd_str, return_code=-1,
                stdout="", stderr="Timeout exceeded", duration=duration
            )
            self.execution_log.append(result)
            return result

        except FileNotFoundError:
            logger.error(f"  Tool not found: {tool}")
            result = ExecutionResult(
                tool=tool, command=cmd_str, return_code=-2,
                stdout="", stderr=f"Tool not found: {tool}", duration=0
            )
            self.execution_log.append(result)
            return result

    def execute_chain(self, chain: List[Dict[str, Any]],
                      initial_input: str = None) -> List[ExecutionResult]:
        """Execute a sequence of tools, piping output to input."""
        results = []
        current_input = initial_input

        for step in chain:
            tool = step["tool"]
            args = step.get("args", [])
            timeout = step.get("timeout", 300)

            result = self.execute(
                tool=tool,
                args=args,
                input_data=current_input,
                timeout=timeout
            )
            results.append(result)

            if not result.success:
                logger.error(f"Chain broken at {tool}")
                break

            # Pass output to next tool
            current_input = result.stdout

        return results
```

### Step 3: Implement Data Transformers

```python
# transformers.py
"""Transform data between tool formats."""

import json
import re
from typing import Any, Dict, List, Optional
from pathlib import Path

class DataTransformer:
    """Convert between different tool data formats."""

    @staticmethod
    def subfinder_to_httpx(subfinder_output: str) -> List[str]:
        """Convert subfinder output to httpx input."""
        hosts = []
        for line in subfinder_output.strip().split("\n"):
            line = line.strip()
            if line and not line.startswith("#"):
                # Add protocol if missing
                if not line.startswith(("http://", "https://")):
                    line = f"https://{line}"
                hosts.append(line)
        return hosts

    @staticmethod
    def httpx_to_nuclei(httpx_json: List[Dict]) -> List[str]:
        """Extract URLs from httpx JSON output for nuclei input."""
        urls = []
        for entry in httpx_json:
            if entry.get("url"):
                urls.append(entry["url"])
        return urls

    @staticmethod
    def nuclei_to_findings(nuclei_jsonl: List[Dict]) -> List[Dict]:
        """Normalize nuclei JSONL to standard finding format."""
        findings = []
        for item in nuclei_jsonl:
            finding = {
                "template_id": item.get("template-id", "unknown"),
                "severity": item.get("info", {}).get("severity", "unknown"),
                "host": item.get("host", ""),
                "matched_at": item.get("matched-at", ""),
                "description": item.get("info", {}).get("description", ""),
                "reference": item.get("info", {}).get("reference", []),
                "tags": item.get("info", {}).get("tags", []),
                "cvss_score": item.get("info", {}).get("classification", {}).get(
                    "cvss-score", 0
                ),
            }
            findings.append(finding)
        return findings

    @staticmethod
    def merge_results(*result_sets) -> List[Dict]:
        """Merge multiple result sets, deduplicating by key fields."""
        seen = set()
        merged = []

        for result_set in result_sets:
            for item in result_set:
                key = (
                    item.get("host", ""),
                    item.get("matched_at", ""),
                    item.get("template_id", "")
                )
                if key not in seen:
                    seen.add(key)
                    merged.append(item)

        return merged

    @staticmethod
    def filter_by_severity(findings: List[Dict],
                           min_severity: str = "medium") -> List[Dict]:
        """Filter findings by minimum severity."""
        severity_order = {"info": 0, "low": 1, "medium": 2, "high": 3, "critical": 4}
        min_level = severity_order.get(min_severity, 0)

        return [
            f for f in findings
            if severity_order.get(f.get("severity", "info"), 0) >= min_level
        ]

    @staticmethod
    def filter_by_scope(findings: List[Dict],
                        scope: List[str]) -> List[Dict]:
        """Filter findings to only include in-scope targets."""
        import fnmatch
        filtered = []
        for finding in findings:
            host = finding.get("host", "")
            for pattern in scope:
                if fnmatch.fnmatch(host, pattern):
                    filtered.append(finding)
                    break
        return filtered

    @staticmethod
    def to_csv(data: List[Dict], output_path: str):
        """Export findings to CSV."""
        import csv
        if not data:
            return

        keys = data[0].keys()
        with open(output_path, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=keys)
            writer.writeheader()
            writer.writerows(data)

    @staticmethod
    def to_markdown_table(data: List[Dict], columns: List[str] = None) -> str:
        """Convert data to markdown table format."""
        if not data:
            return "No data"

        if columns is None:
            columns = list(data[0].keys())

        header = "| " + " | ".join(columns) + " |"
        separator = "| " + " | ".join(["---"] * len(columns)) + " |"
        rows = []
        for item in data:
            row = "| " + " | ".join(str(item.get(c, "")) for c in columns) + " |"
            rows.append(row)

        return "\n".join([header, separator] + rows)
```

### Step 4: Build Chain Templates

```python
# chain_templates.py
"""Pre-built chain templates for common recon workflows."""

from typing import Dict, List, Any

class ChainTemplate:
    """Template for a tool chain configuration."""

    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.steps: List[Dict[str, Any]] = []
        self.transforms: List[str] = []

    def add_step(self, tool: str, args: List[str],
                 transform: str = None, **kwargs):
        step = {"tool": tool, "args": args, **kwargs}
        if transform:
            step["transform"] = transform
        self.steps.append(step)
        return self

    def to_dict(self) -> Dict:
        return {
            "name": self.name,
            "description": self.description,
            "steps": self.steps,
            "transforms": self.transforms
        }


# Pre-built templates
WEB_RECON_CHAIN = (
    ChainTemplate("web_recon", "Full web application reconnaissance")
    .add_step("subfinder", ["-silent", "-recursive"],
              transform="subfinder_to_httpx")
    .add_step("httpx", ["-silent", "-json", "-tech-detect", "-status-code"],
              transform="httpx_output")
    .add_step("nuclei", ["-jsonl", "-severity", "medium,high,critical"],
              transform="nuclei_findings")
)

API_DISCOVERY_CHAIN = (
    ChainTemplate("api_discovery", "API endpoint discovery and analysis")
    .add_step("subfinder", ["-silent"],
              transform="subfinder_to_httpx")
    .add_step("httpx", ["-silent", "-json"],
              transform="httpx_output")
    .add_step("katana", ["-d", "3", "-jc"],  # JavaScript crawling
              transform="katana_urls")
    .add_step("custom_filter", [],  # Filter for API patterns
              transform="api_pattern_filter")
)

NETWORK_SCAN_CHAIN = (
    ChainTemplate("network_scan", "Network-level reconnaissance")
    .add_step("subfinder", ["-silent"],
              transform="subfinder_to_hosts")
    .add_step("masscan", ["-p1-65535", "--rate=1000"],
              transform="masscan_ports")
    .add_step("nmap", ["-sV", "-sC", "-O"],
              transform="nmap_services")
)

JS_ANALYSIS_CHAIN = (
    ChainTemplate("js_analysis", "JavaScript endpoint and secret extraction")
    .add_step("httpx", ["-silent", "-json"],
              transform="extract_js_urls")
    .add_step("linkfinder", ["-i", "-", "-o", "json"],
              transform="linkfinder_endpoints")
    .add_step("secretfinder", ["-i", "-", "-e"],
              transform="secretfinder_results")
)


def get_template(name: str) -> ChainTemplate:
    templates = {
        "web_recon": WEB_RECON_CHAIN,
        "api_discovery": API_DISCOVERY_CHAIN,
        "network_scan": NETWORK_SCAN_CHAIN,
        "js_analysis": JS_ANALYSIS_CHAIN,
    }
    return templates.get(name)
```

### Step 5: Implement Parallel Execution

```python
# parallel_executor.py
"""Execute independent chain steps in parallel."""

import concurrent.futures
import threading
import time
import logging
from typing import List, Dict, Any, Callable, Optional
from dataclasses import dataclass, field
from queue import Queue

logger = logging.getLogger("parallel_executor")


@dataclass
class ParallelJob:
    name: str
    func: Callable
    args: tuple = ()
    kwargs: dict = field(default_factory=dict)
    result: Any = None
    error: Optional[Exception] = None
    duration: float = 0.0


class ParallelExecutor:
    """Execute independent tasks in parallel with resource management."""

    def __init__(self, max_workers: int = 4, rate_limit: float = None):
        self.max_workers = max_workers
        self.rate_limit = rate_limit  # requests per second
        self._lock = threading.Lock()
        self._request_times: List[float] = []
        self._semaphore = threading.Semaphore(max_workers)

    def _rate_limit_check(self):
        """Enforce rate limiting."""
        if self.rate_limit is None:
            return

        with self._lock:
            now = time.time()
            # Remove timestamps older than 1 second
            self._request_times = [
                t for t in self._request_times if now - t < 1.0
            ]

            if len(self._request_times) >= self.rate_limit:
                sleep_time = 1.0 - (now - self._request_times[0])
                if sleep_time > 0:
                    time.sleep(sleep_time)

            self._request_times.append(time.time())

    def execute_parallel(self, jobs: List[ParallelJob]) -> List[ParallelJob]:
        """Execute jobs in parallel with thread pool."""
        logger.info(f"Executing {len(jobs)} jobs with {self.max_workers} workers")

        def run_job(job: ParallelJob) -> ParallelJob:
            self._rate_limit_check()
            start = time.time()
            try:
                with self._semaphore:
                    job.result = job.func(*job.args, **job.kwargs)
            except Exception as e:
                job.error = e
                logger.error(f"Job '{job.name}' failed: {e}")
            finally:
                job.duration = time.time() - start
            return job

        with concurrent.futures.ThreadPoolExecutor(
            max_workers=self.max_workers
        ) as executor:
            futures = {executor.submit(run_job, job): job for job in jobs}
            completed = []
            for future in concurrent.futures.as_completed(futures):
                job = future.result()
                status = "OK" if job.error is None else "FAIL"
                logger.info(f"  [{status}] {job.name} ({job.duration:.2f}s)")
                completed.append(job)

        return completed

    def fan_out_fan_in(self, data: List[Any],
                       process_func: Callable,
                       merge_func: Callable,
                       chunk_size: int = None) -> Any:
        """Process data in parallel chunks, then merge."""
        if chunk_size is None:
            chunk_size = max(1, len(data) // self.max_workers)

        chunks = [
            data[i:i + chunk_size]
            for i in range(0, len(data), chunk_size)
        ]

        jobs = [
            ParallelJob(
                name=f"chunk_{i}",
                func=process_func,
                args=(chunk,)
            )
            for i, chunk in enumerate(chunks)
        ]

        results = self.execute_parallel(jobs)

        # Merge successful results
        successful = [r.result for r in results if r.error is None]
        return merge_func(successful)
```

### Step 6: Build the Chain Orchestrator

```python
# chain_orchestrator.py
"""Orchestrate complete tool chains with monitoring and recovery."""

import json
import time
import logging
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, field

logger = logging.getLogger("chain_orchestrator")


@dataclass
class ChainStep:
    name: str
    tool: str
    args: List[str]
    input_from: Optional[str] = None  # Step name to get input from
    transform: Optional[str] = None
    timeout: int = 300
    retries: int = 1
    optional: bool = False  # If True, chain continues even if this fails


@dataclass
class ChainDefinition:
    name: str
    description: str
    steps: List[ChainStep]
    config: Dict[str, Any] = field(default_factory=dict)


class ChainOrchestrator:
    """Orchestrate tool chains with dependency resolution."""

    def __init__(self, executor, transformer):
        self.executor = executor
        self.transformer = transformer
        self.results: Dict[str, Any] = {}
        self.errors: List[Dict] = []

    def run_chain(self, chain: ChainDefinition,
                  target: str) -> Dict[str, Any]:
        """Execute a complete chain."""
        logger.info(f"Starting chain: {chain.name}")
        start_time = time.time()

        for step in chain.steps:
            logger.info(f"Step: {step.name} ({step.tool})")

            # Get input from previous step
            input_data = None
            if step.input_from and step.input_from in self.results:
                prev_result = self.results[step.input_from]
                input_data = self._prepare_input(prev_result, step.transform)

            # Execute with retries
            result = None
            for attempt in range(step.retries):
                try:
                    result = self.executor.execute(
                        tool=step.tool,
                        args=step.args,
                        input_data=input_data,
                        timeout=step.timeout
                    )
                    if result.success:
                        break
                except Exception as e:
                    logger.warning(f"  Attempt {attempt + 1} failed: {e}")
                    if attempt < step.retries - 1:
                        time.sleep(2 ** attempt)

            # Handle result
            if result and result.success:
                self.results[step.name] = result
                logger.info(f"  {step.name} completed ({result.duration:.2f}s)")
            elif step.optional:
                logger.warning(f"  {step.name} failed but is optional, continuing")
            else:
                logger.error(f"  {step.name} failed, chain stopped")
                self.errors.append({
                    "step": step.name,
                    "error": "Step failed after retries"
                })
                break

        total_time = time.time() - start_time
        return {
            "chain": chain.name,
            "target": target,
            "status": "completed" if not self.errors else "partial",
            "duration": total_time,
            "steps_completed": len(self.results),
            "steps_failed": len(self.errors),
            "results": {k: v.stdout[:500] for k, v in self.results.items()},
            "errors": self.errors
        }

    def _prepare_input(self, result, transform: Optional[str]) -> str:
        """Prepare input for next step, applying transform if specified."""
        if transform:
            transform_func = getattr(self.transformer, transform, None)
            if transform_func:
                return transform_func(result.stdout)
        return result.stdout
```

---

## Tool Arsenal

### Command-Line Chaining

```bash
# Basic pipe chain
subfinder -d example.com -silent | httpx -silent | nuclei -severity high

# File-based chain
subfinder -d example.com -o subs.txt
httpx -l subs.txt -o live.txt
nuclei -l live.txt -jsonl -o findings.jsonl

# Parallel chain (xargs)
cat subs.txt | xargs -P 10 -I {} httpx -u {} -silent

# With jq transformation
subfinder -d example.com -silent | httpx -json | jq -r '.url' | nuclei -l -

# Conditional execution
cat live.txt | while read host; do
    curl -s -o /dev/null -w "%{http_code}" "$host" | grep -q "200" && \
    echo "$host" >> api_candidates.txt
done
```

### Python Chaining

```python
import subprocess
import json

def chain_simple(target: str):
    """Simple linear chain."""
    # Step 1: Subdomain enum
    p1 = subprocess.run(
        ["subfinder", "-d", target, "-silent"],
        capture_output=True, text=True
    )
    subs = p1.stdout.strip().split("\n")

    # Step 2: HTTP check
    p2 = subprocess.run(
        ["httpx", "-silent", "-json"],
        input="\n".join(subs),
        capture_output=True, text=True
    )
    live = [json.loads(line) for line in p2.stdout.strip().split("\n") if line]

    # Step 3: Nuclei scan
    urls = [h["url"] for h in live if "url" in h]
    p3 = subprocess.run(
        ["nuclei", "-jsonl", "-severity", "high,critical"],
        input="\n".join(urls),
        capture_output=True, text=True
    )
    findings = [json.loads(line) for line in p3.stdout.strip().split("\n") if line]

    return {"subdomains": len(subs), "live": len(live), "findings": len(findings)}
```

---

## Real-World Examples

### Example 1: Bug Bounty Recon Chain

```python
# chains/bounty_recon.py
"""Complete bug bounty reconnaissance chain."""

from tool_executor import ToolExecutor
from transformers import DataTransformer
from chain_orchestrator import ChainOrchestrator, ChainDefinition, ChainStep

def build_bounty_recon(target: str) -> ChainDefinition:
    """Build a comprehensive recon chain for bug bounty."""
    return ChainDefinition(
        name=f"bounty_recon_{target}",
        description=f"Full reconnaissance for {target}",
        steps=[
            ChainStep(
                name="subdomain_enum",
                tool="subfinder",
                args=["-d", target, "-silent", "-recursive"],
                timeout=300,
                retries=2
            ),
            ChainStep(
                name="http_check",
                tool="httpx",
                args=["-silent", "-json", "-tech-detect", "-status-code",
                       "-title", "-follow-redirects"],
                input_from="subdomain_enum",
                timeout=300
            ),
            ChainStep(
                name="directory_fuzz",
                tool="ffuf",
                args=["-u", "https://FUZZ.target.com", "-w",
                       "/usr/share/wordlists/common.txt", "-mc", "200,301,302,403",
                       "-o", "dir_results.json", "-of", "json"],
                input_from="http_check",
                timeout=600,
                optional=True
            ),
            ChainStep(
                name="nuclei_scan",
                tool="nuclei",
                args=["-jsonl", "-severity", "medium,high,critical",
                       "-rate-limit", "150"],
                input_from="http_check",
                timeout=900,
                retries=1
            ),
            ChainStep(
                name="report_generate",
                tool="python",
                args=["-c", "generate_report()"],  # Custom script
                input_from="nuclei_scan",
                timeout=30
            ),
        ]
    )

# Execute
executor = ToolExecutor(work_dir="./bounty_workdir")
transformer = DataTransformer()
orchestrator = ChainOrchestrator(executor, transformer)

chain = build_bounty_recon("example.com")
result = orchestrator.run_chain(chain, "example.com")
print(json.dumps(result, indent=2))
```

### Example 2: Multi-Target Parallel Chain

```python
# chains/parallel_targets.py
"""Scan multiple targets in parallel."""

from parallel_executor import ParallelExecutor, ParallelJob

def scan_target(target: str) -> dict:
    """Full scan of a single target."""
    import subprocess, json

    # Subdomain enum
    p1 = subprocess.run(
        ["subfinder", "-d", target, "-silent"],
        capture_output=True, text=True, timeout=120
    )
    subs = p1.stdout.strip().split("\n")

    # HTTP check
    p2 = subprocess.run(
        ["httpx", "-silent", "-json"],
        input="\n".join(subs),
        capture_output=True, text=True, timeout=300
    )
    live = [json.loads(l) for l in p2.stdout.strip().split("\n") if l]

    return {
        "target": target,
        "subdomains": len(subs),
        "live_hosts": len(live)
    }

targets = ["example.com", "test.com", "demo.com", "sample.com"]
executor = ParallelExecutor(max_workers=4, rate_limit=5)

jobs = [
    ParallelJob(name=t, func=scan_target, args=(t,))
    for t in targets
]

results = executor.execute_parallel(jobs)
for r in results:
    if r.error:
        print(f"[FAIL] {r.name}: {r.error}")
    else:
        print(f"[OK] {r.name}: {r.result}")
```

### Example 3: Conditional Chain with Branching

```python
# chains/conditional_branch.py
"""Conditional chain that routes based on target type."""

def detect_target_type(target: str) -> str:
    """Determine if target is web, API, or network."""
    import subprocess
    try:
        p = subprocess.run(
            ["httpx", "-u", f"https://{target}", "-silent", "-json"],
            capture_output=True, text=True, timeout=30
        )
        if p.returncode == 0 and p.stdout.strip():
            data = json.loads(p.stdout.strip().split("\n")[0])
            tech = " ".join(data.get("tech", []))
            if any(k in tech.lower() for k in ["swagger", "openapi", "graphql"]):
                return "api"
            return "web"
    except Exception:
        pass
    return "network"

def run_conditional_chain(target: str):
    target_type = detect_target_type(target)
    print(f"Detected target type: {target_type}")

    if target_type == "web":
        return build_web_chain(target)
    elif target_type == "api":
        return build_api_chain(target)
    else:
        return build_network_chain(target)
```

---

## Common Pitfalls

### Pitfall 1: assuming all tools accept stdin
**Problem:** Some tools (ffuf, nmap) don't read from stdin.
**Solution:** Use temp files for intermediate storage. Check tool documentation for input methods.

### Pitfall 2: Not Handling Partial Failures
**Problem:** One tool in a chain fails, losing all previous results.
**Solution:** Persist intermediate results. Use optional chain steps for non-critical tools.

### Pitfall 3: Unescaped Special Characters
**Problem:** User input containing shell metacharacters breaks subprocess calls.
**Solution:** Always use `subprocess.run()` with list arguments, never `shell=True`.

### Pitfall 4: Ignoring Tool Version Differences
**Problem:** Output format changes between tool versions break parsers.
**Solution:** Pin tool versions. Add version checks to chain validation.

### Pitfall 5: No Timeout Configuration
**Problem:** A hung tool blocks the entire chain indefinitely.
**Solution:** Set explicit timeouts on every subprocess call. Implement watchdog timers.

### Pitfall 6: Memory Exhaustion on Large Targets
**Problem:** Large targets produce massive output that fills memory.
**Solution:** Stream processing instead of loading everything into memory. Write to disk.

### Pitfall 7: Race Conditions in Parallel Chains
**Problem:** Multiple tools writing to the same output file simultaneously.
**Solution:** Use unique temp files per thread. Use file locking where needed.

---

## Advanced Techniques

### 1. Dynamic Chain Adaptation

```python
class AdaptiveChain:
    """Chain that adapts based on intermediate results."""

    def __init__(self):
        self.adaptation_rules = []

    def add_rule(self, condition, action):
        self.adaptation_rules.append({"condition": condition, "action": action})

    def evaluate(self, current_results: dict) -> list:
        """Determine next steps based on results."""
        steps = []
        for rule in self.adaptation_rules:
            if rule["condition"](current_results):
                steps.append(rule["action"])
        return steps

# Example: If nuclei finds critical vulns, add deep-dive step
chain = AdaptiveChain()
chain.add_rule(
    condition=lambda r: any(
        f.get("severity") == "critical"
        for f in r.get("nuclei", {}).get("findings", [])
    ),
    action=ChainStep(name="deep_dive", tool="custom_dexploit", args=[])
)
```

### 2. Streaming Pipeline

```python
class StreamingChain:
    """Process data as it flows through the chain, not batch."""

    def __init__(self):
        self.buffer = []
        self.batch_size = 100

    def process_stream(self, input_stream, process_func):
        """Process input stream in batches."""
        for item in input_stream:
            self.buffer.append(item)
            if len(self.buffer) >= self.batch_size:
                yield process_func(self.buffer)
                self.buffer = []
        if self.buffer:
            yield process_func(self.buffer)
```

### 3. Chain Caching and Deduplication

```python
import hashlib
from functools import lru_cache

class CachedChain:
    """Cache chain results to avoid redundant executions."""

    def __init__(self, cache_dir: str = "./chain_cache"):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def _cache_key(self, chain_name: str, target: str, params: dict) -> str:
        data = f"{chain_name}:{target}:{json.dumps(params, sort_keys=True)}"
        return hashlib.sha256(data.encode()).hexdigest()[:16]

    def get_cached(self, key: str) -> Optional[dict]:
        cache_path = self.cache_dir / f"{key}.json"
        if cache_path.exists():
            with open(cache_path) as f:
                return json.load(f)
        return None

    def save_cached(self, key: str, result: dict):
        cache_path = self.cache_dir / f"{key}.json"
        with open(cache_path, "w") as f:
            json.dump(result, f, indent=2)
```

### 4. Chain Metrics and Monitoring

```python
class ChainMetrics:
    """Track chain performance metrics."""

    def __init__(self):
        self.metrics = []

    def record(self, chain_name: str, step: str, duration: float,
               success: bool, data_size: int = 0):
        self.metrics.append({
            "chain": chain_name,
            "step": step,
            "duration": duration,
            "success": success,
            "data_size": data_size,
            "timestamp": time.time()
        })

    def summary(self, chain_name: str = None) -> dict:
        filtered = self.metrics
        if chain_name:
            filtered = [m for m in filtered if m["chain"] == chain_name]

        return {
            "total_steps": len(filtered),
            "total_duration": sum(m["duration"] for m in filtered),
            "success_rate": sum(1 for m in filtered if m["success"]) / max(len(filtered), 1),
            "avg_duration": sum(m["duration"] for m in filtered) / max(len(filtered), 1),
            "total_data_bytes": sum(m["data_size"] for m in filtered)
        }
```

---

## Reporting Template

### Tool Chain Execution Report

```markdown
# Tool Chain Execution Report

## Chain Summary
- **Chain Name**: {chain_name}
- **Target**: {target}
- **Started**: {start_time}
- **Completed**: {end_time}
- **Total Duration**: {duration}
- **Status**: {status}

## Step Results

| Step | Tool | Status | Duration | Output Size | Notes |
|------|------|--------|----------|-------------|-------|
| subdomain_enum | subfinder | OK | 4.2s | 142 entries | |
| http_check | httpx | OK | 8.1s | 89 entries | |
| dir_fuzz | ffuf | OK | 45.2s | 23 endpoints | |
| nuclei_scan | nuclei | OK | 67.8s | 3 findings | |

## Data Flow Visualization

```
subfinder (142 subs) -> httpx (89 live) -> nuclei (3 findings)
                                  |-> ffuf (23 endpoints)
```

## Performance Metrics
- **Tool Utilization**: {utilization}%
- **Cache Hit Rate**: {cache_rate}%
- **Error Recovery Rate**: {recovery_rate}%

## Findings Summary
- **Critical**: {critical_count}
- **High**: {high_count}
- **Medium**: {medium_count}
- **Low**: {low_count}

## Chain Optimization Suggestions
1. {suggestion_1}
2. {suggestion_2}
3. {suggestion_3}
```

---

## Quick Reference

### One-Liner Chains

```bash
# Subdomain -> HTTP -> Nuclei
subfinder -d TARGET -silent | httpx -silent | nuclei -severity high

# Subdomain -> HTTP -> Directory Fuzz
subfinder -d TARGET -silent | httpx -silent | xargs -I {} ffuf -u {}/FUZZ -w wordlist.txt

# Parallel host scanning
cat hosts.txt | xargs -P 10 -I {} nmap -sV {} -oX {}.xml
```

### Chain Decision Matrix

| Scenario | Pattern | Tools | Parallelism |
|----------|---------|-------|-------------|
| Simple recon | Linear | subfinder->httpx->nuclei | Sequential |
| Full recon | Fan-out | subfinder->httpx->{ffuf,nuclei,linkfinder} | Parallel middle |
| Multi-target | Scatter-gather | Per-target chains | Parallel targets |
| API discovery | Conditional | subfinder->httpx->[api\|web] chain | Branching |
| Deep scan | Iterative | nuclei->recheck->nuclei again | Sequential loops |

### Configuration Template

```yaml
chain:
  name: my_recon_chain
  target: example.com
  steps:
    - name: subfinder
      tool: subfinder
      args: ["-d", "{target}", "-silent"]
      timeout: 300
      retries: 2
    - name: httpx
      tool: httpx
      args: ["-silent", "-json"]
      input_from: subfinder
      timeout: 300
    - name: nuclei
      tool: nuclei
      args: ["-jsonl", "-severity", "medium,high,critical"]
      input_from: httpx
      timeout: 900
  parallel:
    max_workers: 4
    rate_limit: 10
  caching:
    enabled: true
    ttl: 3600
```

---

*Document Version: 1.0 | Last Updated: 2026 | Automation-Efficiency Series*
