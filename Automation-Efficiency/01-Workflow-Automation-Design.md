# Automation-Efficiency 1: Workflow Automation Design

## Expert Role

You are an elite Bug Bounty Workflow Architect with 10+ years of experience building automated security testing pipelines. Your specialty is designing end-to-end workflow automation that transforms manual reconnaissance and vulnerability hunting into repeatable, scalable, and auditable processes. You combine deep technical knowledge of security tooling with software engineering discipline to build systems that catch what humans miss, faster than humans can find it.

Your philosophy: every manual step you repeat more than twice should be automated. Every decision tree you follow mentally should be encoded as logic. Every output you format by hand should be templated.

---

## Core Concepts

### What is Workflow Automation in Bug Bounty?

Workflow automation is the systematic design, implementation, and optimization of interconnected processes that handle reconnaissance, vulnerability discovery, validation, and reporting with minimal human intervention. It is NOT about replacing the hunter — it is about amplifying the hunter's capabilities by offloading repetitive, time-consuming, and error-prone tasks to deterministic pipelines.

### The Three Pillars of Workflow Automation

**1. Task Orchestration**
- Defining the sequence of operations (what runs when)
- Managing dependencies (tool B needs output from tool A)
- Handling parallelism (tool C and D can run simultaneously)
- Coordinating state across pipeline stages

**2. Dependency Graphs**
- Directed Acyclic Graphs (DAGs) represent task dependencies
- Nodes are tasks (scripts, tools, API calls)
- Edges are data flows (output of one task feeds input of another)
- Topological sorting determines execution order
- Cycle detection prevents deadlocks

**3. State Management**
- Tracking pipeline progress across stages
- Persisting intermediate results for resumability
- Managing context (target info, session tokens, config)
- Handling failures without losing accumulated state

### The Automation Maturity Model

```
Level 0: Manual        - Everything done by hand
Level 1: Scripted      - Individual commands wrapped in scripts
Level 2: Pipelined     - Scripts connected in sequence
Level 3: Orchestrated  - DAG-based execution with dependency resolution
Level 4: Autonomous    - Self-healing, adaptive, decision-making pipelines
Level 5: Intelligent   - ML-assisted prioritization and pattern recognition
```

Most bug bounty hunters operate at Level 0-2. The goal is to reach Level 3-4.

### Key Design Principles

| Principle | Description |
|-----------|-------------|
| Idempotency | Running the same pipeline twice produces the same results |
| Observability | Every stage logs what it does and why |
| Resumability | Pipeline can restart from the last successful stage |
| Modularity | Each stage is independent and reusable |
| Fail-fast | Detect errors early and propagate them clearly |
| Separation of concerns | Data collection, analysis, and reporting are distinct |
| Configuration over code | Behavior controlled by config files, not hardcoded values |

---

## Prerequisites

### Required Knowledge
- Python 3.8+ (intermediate level)
- Basic understanding of subprocess management
- Familiarity with JSON/YAML for configuration
- Understanding of directed acyclic graphs
- Knowledge of at least one task runner (Make, Invoke, or custom)

### Required Tools

```bash
# Core Python packages
pip install pyyaml rich click schedule networkx

# Task runners (choose one or more)
pip install invoke          # Fabric-like task runner
pip install celery          # Distributed task queue
pip install luigi           # Spotify's workflow framework
pip install prefect          # Modern workflow orchestration

# For DAG visualization
pip install graphviz matplotlib
```

### Environment Setup

```bash
# Create project structure
mkdir -p workflow-project/{config,pipelines,tasks,utils,logs,results}
cd workflow-project

# Initialize Python project
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Create requirements file
echo "pyyaml>=6.0
rich>=13.0
click>=8.0
networkx>=3.0
pydantic>=2.0" > requirements.txt
pip install -r requirements.txt
```

---

## Methodology

### Step 1: Map Your Current Workflow

Before automating, document what you do manually:

```python
# workflow_audit.py
"""Audit your current workflow to identify automation candidates."""

import json
from datetime import datetime
from dataclasses import dataclass, field, asdict
from typing import List

@dataclass
class WorkflowStep:
    name: str
    tool: str
    command: str
    estimated_minutes: int
    frequency_per_hunt: int
    error_rate: float  # 0.0 to 1.0
    automatable: bool
    dependencies: List[str] = field(default_factory=list)

def audit_workflow():
    """Document your current bug bounty workflow."""
    steps = [
        WorkflowStep(
            name="Subdomain Enumeration",
            tool="subfinder",
            command="subfinder -d target.com -o subs.txt",
            estimated_minutes=5,
            frequency_per_hunt=1,
            error_rate=0.05,
            automatable=True,
            dependencies=[]
        ),
        WorkflowStep(
            name="Live Host Check",
            tool="httpx",
            command="httpx -l subs.txt -o live.txt",
            estimated_minutes=3,
            frequency_per_hunt=1,
            error_rate=0.1,
            automatable=True,
            dependencies=["Subdomain Enumeration"]
        ),
        WorkflowStep(
            name="Directory Fuzzing",
            tool="ffuf",
            command="ffuf -u https://TARGET/FUZZ -w wordlist.txt",
            estimated_minutes=15,
            frequency_per_hunt=2,
            error_rate=0.15,
            automatable=True,
            dependencies=["Live Host Check"]
        ),
        WorkflowStep(
            name="Manual Endpoint Review",
            tool="browser",
            command="N/A",
            estimated_minutes=30,
            frequency_per_hunt=1,
            error_rate=0.0,
            automatable=False,
            dependencies=["Directory Fuzzing"]
        ),
        WorkflowStep(
            name="Vulnerability Testing",
            tool="burp/browserscript",
            command="Custom per endpoint",
            estimated_minutes=60,
            frequency_per_hunt=3,
            error_rate=0.3,
            automatable=False,
            dependencies=["Manual Endpoint Review"]
        ),
        WorkflowStep(
            name="Report Writing",
            tool="markdown",
            command="Manual",
            estimated_minutes=45,
            frequency_per_hunt=0.5,
            error_rate=0.1,
            automatable=True,
            dependencies=["Vulnerability Testing"]
        ),
    ]

    total_manual = sum(s.estimated_minutes * s.frequency_per_hunt
                       for s in steps if not s.automatable)
    total_auto = sum(s.estimated_minutes * s.frequency_per_hunt
                     for s in steps if s.automatable)

    print(f"Manual time per hunt:  {total_manual} minutes")
    print(f"Automatable time:      {total_auto} minutes")
    print(f"Automation potential:  {total_auto/(total_manual+total_auto)*100:.1f}%")
    print(f"\nAutomation candidates (sorted by time savings):")
    for step in sorted(steps, key=lambda s: s.estimated_minutes * s.frequency_per_hunt, reverse=True):
        if step.automatable:
            savings = step.estimated_minutes * step.frequency_per_hunt
            print(f"  [+] {step.name}: {savings} min/hunt ({step.tool})")

    return steps

if __name__ == "__main__":
    audit_workflow()
```

### Step 2: Design Your DAG

```python
# dag_designer.py
"""Design and validate workflow DAGs."""

import networkx as nx
from typing import Dict, List, Callable, Any

class WorkflowDAG:
    """Directed Acyclic Graph for bug bounty workflow orchestration."""

    def __init__(self, name: str):
        self.name = name
        self.graph = nx.DiGraph()
        self.tasks: Dict[str, Callable] = {}
        self.results: Dict[str, Any] = {}

    def add_task(self, name: str, func: Callable, dependencies: List[str] = None):
        """Add a task with optional dependencies."""
        self.graph.add_node(name, func=func)
        self.tasks[name] = func
        if dependencies:
            for dep in dependencies:
                self.graph.add_edge(dep, name)

        # Validate DAG (no cycles)
        if not nx.is_directed_acyclic_graph(self.graph):
            self.graph.remove_edge(dependencies[-1], name)
            raise ValueError(f"Adding {name} with deps {dependencies} would create a cycle!")

    def get_execution_order(self) -> List[str]:
        """Return topological sort of tasks."""
        return list(nx.topological_sort(self.graph))

    def get_parallel_groups(self) -> List[List[str]]:
        """Identify tasks that can run in parallel."""
        levels = []
        for node in nx.topological_generations(self.graph):
            levels.append(list(node))
        return levels

    def visualize(self):
        """Print ASCII representation of the DAG."""
        print(f"\n{'='*60}")
        print(f"  Workflow: {self.name}")
        print(f"{'='*60}")

        parallel_groups = self.get_parallel_groups()
        for i, group in enumerate(parallel_groups):
            marker = ">>>" if len(group) > 1 else "   "
            for task in group:
                deps = list(self.graph.predecessors(task))
                dep_str = f" (after: {', '.join(deps)})" if deps else ""
                print(f"  {marker} Stage {i}: {task}{dep_str}")
        print(f"{'='*60}\n")


def build_recon_workflow() -> WorkflowDAG:
    """Build a standard recon workflow DAG."""
    dag = WorkflowDAG("Recon Pipeline")

    def subdomain_enum(config):
        print("  [subfinder] Enumerating subdomains...")
        return {"subdomains": ["api.target.com", "dev.target.com"]}

    def http_check(config):
        print("  [httpx] Checking live hosts...")
        return {"live_hosts": ["api.target.com"]}

    def port_scan(config):
        print("  [nmap] Scanning ports on live hosts...")
        return {"open_ports": {"api.target.com": [443, 8080]}}

    def dir_fuzz(config):
        print("  [ffuf] Fuzzing directories...")
        return {"endpoints": ["/api/v1/users", "/api/v1/admin"]}

    def js_analysis(config):
        print("  [ LinkFinder] Extracting JS endpoints...")
        return {"js_endpoints": ["/api/internal", "/debug"]}

    def nuclei_scan(config):
        print("  [nuclei] Running template scan...")
        return {"vulns": []}

    dag.add_task("subdomain_enum", subdomain_enum, [])
    dag.add_task("http_check", http_check, ["subdomain_enum"])
    dag.add_task("port_scan", port_scan, ["http_check"])
    dag.add_task("dir_fuzz", dir_fuzz, ["http_check"])
    dag.add_task("js_analysis", js_analysis, ["http_check"])
    dag.add_task("nuclei_scan", nuclei_scan, ["dir_fuzz", "js_analysis"])

    return dag


if __name__ == "__main__":
    dag = build_recon_workflow()
    dag.visualize()
    print("Execution order:", dag.get_execution_order())
    print("Parallel groups:", dag.get_parallel_groups())
```

### Step 3: Implement the Task Runner

```python
# task_runner.py
"""Core task execution engine with state management and error handling."""

import json
import time
import logging
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Any, Dict, Optional, Callable
from dataclasses import dataclass, field
from enum import Enum

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger("task_runner")


class TaskStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    SKIPPED = "skipped"


@dataclass
class TaskResult:
    status: TaskStatus
    output: Any = None
    error: Optional[str] = None
    duration_seconds: float = 0.0
    timestamp: str = ""

    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.now().isoformat()


@dataclass
class PipelineState:
    """Persisted state for resumable pipelines."""
    pipeline_id: str
    started_at: str = ""
    completed_at: str = ""
    task_results: Dict[str, TaskResult] = field(default_factory=dict)
    context: Dict[str, Any] = field(default_factory=dict)

    def save(self, path: Path):
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w") as f:
            json.dump(self.__dict__, f, indent=2, default=str)

    @classmethod
    def load(cls, path: Path) -> "PipelineState":
        with open(path) as f:
            data = json.load(f)
        return cls(**data)


class TaskRunner:
    """Execute tasks with dependency resolution and state persistence."""

    def __init__(self, state_dir: str = "./pipeline_state"):
        self.state_dir = Path(state_dir)
        self.state_dir.mkdir(parents=True, exist_ok=True)

    def run_pipeline(self, pipeline_id: str, tasks: Dict[str, Callable],
                     dependencies: Dict[str, List[str]],
                     context: Dict[str, Any] = None) -> PipelineState:
        """Execute a full pipeline with dependency resolution."""
        state = PipelineState(
            pipeline_id=pipeline_id,
            started_at=datetime.now().isoformat(),
            context=context or {}
        )

        execution_order = self._resolve_order(dependencies)
        logger.info(f"Pipeline '{pipeline_id}' starting with {len(tasks)} tasks")
        logger.info(f"Execution order: {' -> '.join(execution_order)}")

        for task_name in execution_order:
            # Check if all dependencies completed
            deps = dependencies.get(task_name, [])
            deps_ok = all(
                state.task_results.get(d, TaskResult(TaskStatus.FAILED)).status
                == TaskStatus.COMPLETED
                for d in deps
            )

            if not deps_ok:
                logger.warning(f"Skipping '{task_name}': dependency failed")
                state.task_results[task_name] = TaskResult(
                    status=TaskStatus.SKIPPED,
                    error="Dependency failed"
                )
                continue

            # Check for cached results (idempotency)
            cache_key = self._cache_key(task_name, state.context)
            cached = self._load_cache(cache_key)
            if cached:
                logger.info(f"Cache hit for '{task_name}', skipping execution")
                state.task_results[task_name] = TaskResult(
                    status=TaskStatus.COMPLETED,
                    output=cached["output"],
                    duration_seconds=0
                )
                continue

            # Execute task
            logger.info(f"Running '{task_name}'...")
            state.task_results[task_name] = TaskResult(status=TaskStatus.RUNNING)
            state.save(self._state_path(pipeline_id))

            start_time = time.time()
            try:
                result = tasks[task_name](state.context)
                duration = time.time() - start_time

                state.task_results[task_name] = TaskResult(
                    status=TaskStatus.COMPLETED,
                    output=result,
                    duration_seconds=duration
                )
                logger.info(f"  Completed '{task_name}' in {duration:.2f}s")

                # Cache result
                self._save_cache(cache_key, result)

            except Exception as e:
                duration = time.time() - start_time
                state.task_results[task_name] = TaskResult(
                    status=TaskStatus.FAILED,
                    error=str(e),
                    duration_seconds=duration
                )
                logger.error(f"  Failed '{task_name}': {e}")

            state.save(self._state_path(pipeline_id))

        state.completed_at = datetime.now().isoformat()
        state.save(self._state_path(pipeline_id))
        return state

    def _resolve_order(self, dependencies: Dict[str, List[str]]) -> list:
        """Topological sort of tasks."""
        import networkx as nx
        G = nx.DiGraph()
        for task, deps in dependencies.items():
            for dep in deps:
                G.add_edge(dep, task)
        return list(nx.topological_sort(G))

    def _cache_key(self, task_name: str, context: Dict) -> str:
        data = json.dumps({"task": task_name, "context": context}, sort_keys=True)
        return hashlib.sha256(data.encode()).hexdigest()[:16]

    def _state_path(self, pipeline_id: str) -> Path:
        return self.state_dir / f"{pipeline_id}_state.json"

    def _load_cache(self, key: str) -> Optional[Dict]:
        cache_path = self.state_dir / f"cache_{key}.json"
        if cache_path.exists():
            with open(cache_path) as f:
                return json.load(f)
        return None

    def _save_cache(self, key: str, output: Any):
        cache_path = self.state_dir / f"cache_{key}.json"
        with open(cache_path, "w") as f:
            json.dump({"output": output}, f, indent=2, default=str)
```

### Step 4: Build the Configuration System

```python
# config_manager.py
"""Configuration management for workflow pipelines."""

import yaml
from pathlib import Path
from typing import Any, Dict, Optional
from dataclasses import dataclass, field

@dataclass
class PipelineConfig:
    """Configuration for a workflow pipeline."""
    name: str
    target: str
    scope: list = field(default_factory=list)
    tools: Dict[str, Dict[str, Any]] = field(default_factory=dict)
    stages: list = field(default_factory=list)
    rate_limits: Dict[str, int] = field(default_factory=dict)
    output_dir: str = "./results"
    log_level: str = "INFO"

    @classmethod
    def from_yaml(cls, path: str) -> "PipelineConfig":
        with open(path) as f:
            data = yaml.safe_load(f)
        return cls(**data)

    def to_yaml(self, path: str):
        with open(path, "w") as f:
            yaml.dump(self.__dict__, f, default_flow_style=False)


DEFAULT_CONFIG = PipelineConfig(
    name="default_recon",
    target="example.com",
    tools={
        "subfinder": {"threads": 30, "timeout": 300},
        "httpx": {"threads": 50, "status_codes": "200,301,302,403"},
        "nuclei": {"severity": "low,medium,high,critical", "rate_limit": 150},
        "ffuf": {"threads": 40, "timeout": 300},
    },
    stages=[
        {"name": "subdomain_enum", "tool": "subfinder", "parallel": False},
        {"name": "http_check", "tool": "httpx", "parallel": False},
        {"name": "dir_fuzz", "tool": "ffuf", "parallel": True},
        {"name": "js_analysis", "tool": "linkfinder", "parallel": True},
        {"name": "vuln_scan", "tool": "nuclei", "parallel": False},
    ],
    rate_limits={"requests_per_second": 10, "concurrent_connections": 25},
)

SAMPLE_CONFIG_YAML = """
name: full_recon_pipeline
target: example.com
scope:
  - "*.example.com"
  - "example.com"
tools:
  subfinder:
    threads: 30
    timeout: 300
    sources: "virustotal,shodan,crtsh"
  httpx:
    threads: 50
    status_codes: "200,301,302,403,500"
    tech_detect: true
  nuclei:
    severity: "medium,high,critical"
    rate_limit: 150
    tags: "cve,xss,sqli,ssrf"
  ffuf:
    threads: 40
    wordlist: "/usr/share/wordlists/common.txt"
    extensions: "php,asp,aspx,jsp"
stages:
  - name: subdomain_enum
    tool: subfinder
    parallel: false
  - name: http_check
    tool: httpx
    parallel: false
  - name: port_scan
    tool: nmap
    parallel: false
  - name: dir_fuzz
    tool: ffuf
    parallel: true
  - name: js_analysis
    tool: linkfinder
    parallel: true
  - name: nuclei_scan
    tool: nuclei
    parallel: false
  - name: report_generate
    tool: custom
    parallel: false
rate_limits:
  requests_per_second: 10
  concurrent_connections: 25
output_dir: ./results
log_level: INFO
"""
```

### Step 5: Implement Error Handling and Recovery

```python
# error_handling.py
"""Robust error handling for workflow pipelines."""

import time
import logging
import functools
from typing import Callable, Any, Optional, Tuple
from enum import Enum

logger = logging.getLogger("error_handler")


class RetryStrategy(Enum):
    FIXED = "fixed"
    EXPONENTIAL = "exponential"
    LINEAR = "linear"


def retry(max_attempts: int = 3,
          strategy: RetryStrategy = RetryStrategy.EXPONENTIAL,
          base_delay: float = 1.0,
          max_delay: float = 60.0,
          exceptions: Tuple = (Exception,)):
    """Decorator for automatic retry with configurable backoff."""

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs) -> Any:
            last_exception = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    last_exception = e
                    if attempt < max_attempts - 1:
                        delay = _calculate_delay(
                            attempt, strategy, base_delay, max_delay
                        )
                        logger.warning(
                            f"Attempt {attempt + 1}/{max_attempts} failed: {e}. "
                            f"Retrying in {delay:.1f}s..."
                        )
                        time.sleep(delay)
                    else:
                        logger.error(
                            f"All {max_attempts} attempts failed for {func.__name__}"
                        )
            raise last_exception
        return wrapper
    return decorator


def _calculate_delay(attempt: int, strategy: RetryStrategy,
                     base: float, max_delay: float) -> float:
    if strategy == RetryStrategy.FIXED:
        return min(base, max_delay)
    elif strategy == RetryStrategy.LINEAR:
        return min(base * (attempt + 1), max_delay)
    elif strategy == RetryStrategy.EXPONENTIAL:
        return min(base * (2 ** attempt), max_delay)
    return base


class CircuitBreaker:
    """Prevent cascading failures by breaking the circuit after too many errors."""

    def __init__(self, failure_threshold: int = 5, reset_timeout: float = 300):
        self.failure_threshold = failure_threshold
        self.reset_timeout = reset_timeout
        self.failure_count = 0
        self.last_failure_time = 0
        self.state = "closed"  # closed, open, half-open

    def call(self, func: Callable, *args, **kwargs) -> Any:
        if self.state == "open":
            if time.time() - self.last_failure_time > self.reset_timeout:
                self.state = "half-open"
                logger.info("Circuit breaker: half-open state")
            else:
                raise CircuitBreakerOpenError(
                    f"Circuit breaker open. Retry after "
                    f"{self.reset_timeout - (time.time() - self.last_failure_time):.0f}s"
                )

        try:
            result = func(*args, **kwargs)
            if self.state == "half-open":
                self.state = "closed"
                self.failure_count = 0
                logger.info("Circuit breaker: closed (recovered)")
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            if self.failure_count >= self.failure_threshold:
                self.state = "open"
                logger.warning(
                    f"Circuit breaker: OPEN after {self.failure_count} failures"
                )
            raise


class CircuitBreakerOpenError(Exception):
    pass


class PipelineErrorHandler:
    """Centralized error handling for pipeline execution."""

    def __init__(self, max_consecutive_failures: int = 3):
        self.max_consecutive_failures = max_consecutive_failures
        self.consecutive_failures = 0
        self.error_log = []

    def handle_task_error(self, task_name: str, error: Exception,
                          context: dict) -> dict:
        """Handle a task failure and decide next action."""
        self.consecutive_failures += 1
        self.error_log.append({
            "task": task_name,
            "error": str(error),
            "type": type(error).__name__,
            "consecutive": self.consecutive_failures
        })

        action = self._decide_action(error)
        logger.error(f"Task '{task_name}' failed: {error} -> Action: {action}")

        return {
            "action": action,
            "should_abort": self.consecutive_failures >= self.max_consecutive_failures,
            "retry_count": self.error_log.count(
                {"task": task_name, "error": str(error)}
            )
        }

    def _decide_action(self, error: Exception) -> str:
        error_type = type(error).__name__
        if error_type == "TimeoutError":
            return "retry_with_backoff"
        elif error_type == "ConnectionError":
            return "retry_after_delay"
        elif "rate limit" in str(error).lower():
            return "wait_and_retry"
        elif error_type == "FileNotFoundError":
            return "skip_task"
        else:
            return "fail_and_continue"

    def reset(self):
        self.consecutive_failures = 0
```

### Step 6: Build the Scheduler

```python
# scheduler.py
"""Pipeline scheduling and automation."""

import time
import json
import logging
from pathlib import Path
from datetime import datetime, timedelta
from typing import Callable, Dict, List, Optional
from dataclasses import dataclass
import threading

logger = logging.getLogger("scheduler")


@dataclass
class ScheduledJob:
    name: str
    func: Callable
    interval_seconds: int
    last_run: Optional[str] = None
    enabled: bool = True
    config: dict = None

    def should_run(self) -> bool:
        if not self.enabled:
            return False
        if self.last_run is None:
            return True
        last = datetime.fromisoformat(self.last_run)
        return datetime.now() - last >= timedelta(seconds=self.interval_seconds)


class PipelineScheduler:
    """Run pipelines on a schedule with monitoring."""

    def __init__(self, state_dir: str = "./scheduler_state"):
        self.state_dir = Path(state_dir)
        self.state_dir.mkdir(parents=True, exist_ok=True)
        self.jobs: Dict[str, ScheduledJob] = {}
        self.running = False
        self._lock = threading.Lock()

    def add_job(self, job: ScheduledJob):
        with self._lock:
            self.jobs[job.name] = job
            logger.info(f"Registered job: {job.name} (every {job.interval_seconds}s)")

    def start(self, check_interval: int = 10):
        """Start the scheduler loop."""
        self.running = True
        logger.info("Scheduler started")

        while self.running:
            with self._lock:
                for name, job in self.jobs.items():
                    if job.should_run():
                        logger.info(f"Triggering job: {name}")
                        try:
                            job.func(job.config or {})
                            job.last_run = datetime.now().isoformat()
                            self._save_state()
                        except Exception as e:
                            logger.error(f"Job '{name}' failed: {e}")
            time.sleep(check_interval)

    def stop(self):
        self.running = False
        logger.info("Scheduler stopped")

    def _save_state(self):
        state = {
            name: {"last_run": job.last_run, "enabled": job.enabled}
            for name, job in self.jobs.items()
        }
        with open(self.state_dir / "scheduler_state.json", "w") as f:
            json.dump(state, f, indent=2)

    def load_state(self):
        state_path = self.state_dir / "scheduler_state.json"
        if state_path.exists():
            with open(state_path) as f:
                state = json.load(f)
            for name, data in state.items():
                if name in self.jobs:
                    self.jobs[name].last_run = data.get("last_run")
                    self.jobs[name].enabled = data.get("enabled", True)
```

---

## Tool Arsenal

### Essential Python Libraries

```bash
# Workflow orchestration
pip install prefect           # Modern, visual workflows
pip install dagster           # Data-aware orchestration
pip install Luigi             # Simple, proven DAGs

# Task running
pip install invoke            # Local task execution
pip install celery            # Distributed task queue
pip install dramatiq          # Celery alternative

# Scheduling
pip install schedule          # Simple periodic scheduling
pip install apscheduler       # Advanced job scheduling
pip install croniter          # Cron expression parsing

# Monitoring
pip install rich              # Beautiful terminal output
pip install loguru            # Better logging
pip install sentry-sdk        # Error tracking
```

### Quick Commands

```bash
# Run a pipeline
python -m pipeline --config config.yaml --target example.com

# List scheduled jobs
python -m scheduler list

# Check pipeline state
cat pipeline_state/recon_abc123_state.json | python -m json.tool

# Visualize DAG
python -c "from dag_designer import *; dag = build_recon_workflow(); dag.visualize()"

# Run with logging
python -m pipeline --config config.yaml --log-level DEBUG 2>&1 | tee logs/run.log
```

---

## Real-World Examples

### Example 1: Automated Recon Pipeline

```python
# pipelines/full_recon.py
"""Complete reconnaissance pipeline with parallel execution."""

import subprocess
import json
from pathlib import Path
from task_runner import TaskRunner, PipelineState

def run_subfinder(context: dict) -> dict:
    target = context["target"]
    output_file = f"/tmp/subs_{target}.txt"
    subprocess.run(
        ["subfinder", "-d", target, "-o", output_file, "-silent"],
        check=True, capture_output=True
    )
    with open(output_file) as f:
        subs = [line.strip() for line in f if line.strip()]
    return {"subdomains": subs, "file": output_file}

def run_httpx(context: dict) -> dict:
    subs_file = context["subfinder"]["file"]
    output_file = f"/tmp/live_{context['target']}.txt"
    subprocess.run(
        ["httpx", "-l", subs_file, "-o", output_file, "-silent", "-status-code"],
        check=True, capture_output=True
    )
    with open(output_file) as f:
        hosts = [line.strip() for line in f if line.strip()]
    return {"live_hosts": hosts, "file": output_file}

def run_nuclei(context: dict) -> dict:
    live_file = context["httpx"]["file"]
    subprocess.run(
        ["nuclei", "-l", live_file, "-severity", "medium,high,critical",
         "-json", "-o", "/tmp/nuclei_results.json"],
        check=True, capture_output=True
    )
    try:
        with open("/tmp/nuclei_results.json") as f:
            results = [json.loads(line) for line in f if line.strip()]
    except FileNotFoundError:
        results = []
    return {"vulnerabilities": results}

def generate_report(context: dict) -> dict:
    vulns = context.get("nuclei", {}).get("vulnerabilities", [])
    report = {
        "target": context["target"],
        "summary": {
            "total_vulns": len(vulns),
            "critical": len([v for v in vulns if v.get("info", {}).get("severity") == "critical"]),
            "high": len([v for v in vulns if v.get("info", {}).get("severity") == "high"]),
        },
        "findings": vulns[:20]
    }
    report_path = Path(f"./results/{context['target']}_report.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, "w") as f:
        json.dump(report, f, indent=2)
    return {"report_path": str(report_path)}


# Define pipeline
runner = TaskRunner()
tasks = {
    "subfinder": run_subfinder,
    "httpx": run_httpx,
    "nuclei": run_nuclei,
    "report": generate_report,
}
dependencies = {
    "httpx": ["subfinder"],
    "nuclei": ["httpx"],
    "report": ["nuclei"],
}

state = runner.run_pipeline(
    pipeline_id="recon_example",
    tasks=tasks,
    dependencies=dependencies,
    context={"target": "example.com"}
)
```

### Example 2: Parallel Port Scanning

```python
# pipelines/parallel_scan.py
"""Parallel scanning with rate limiting."""

import concurrent.futures
import subprocess
import json
from typing import List, Dict

def scan_host(host: str, ports: str = "1-65535", rate: int = 1000) -> Dict:
    """Scan a single host with masscan/nmap."""
    try:
        result = subprocess.run(
            ["nmap", "-sV", "-T4", "-p", ports, "--open", "-oX", "-", host],
            capture_output=True, text=True, timeout=300
        )
        return {"host": host, "status": "completed", "output": result.stdout}
    except subprocess.TimeoutExpired:
        return {"host": host, "status": "timeout", "output": ""}
    except Exception as e:
        return {"host": host, "status": "error", "output": str(e)}

def parallel_scan(hosts: List[str], max_workers: int = 10) -> List[Dict]:
    """Scan multiple hosts in parallel with thread pool."""
    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_host = {
            executor.submit(scan_host, host): host
            for host in hosts
        }
        for future in concurrent.futures.as_completed(future_to_host):
            host = future_to_host[future]
            try:
                result = future.result()
                results.append(result)
                print(f"  [{result['status']}] {host}")
            except Exception as e:
                results.append({"host": host, "status": "error", "output": str(e)})
    return results
```

---

## Common Pitfalls

### Pitfall 1: No Idempotency
**Problem:** Running the same pipeline twice creates duplicate results or side effects.
**Solution:** Cache task outputs by input hash. Check cache before execution.

### Pitfall 2: Blocking on Slow Tools
**Problem:** One slow tool (like nmap full scan) blocks the entire pipeline.
**Solution:** Set timeouts on all subprocess calls. Use async execution for independent tasks.

### Pitfall 3: Ignoring Rate Limits
**Problem:** Aggressive parallelism triggers target's WAF/IPS.
**Solution:** Implement per-target rate limiting. Add configurable delays between requests.

### Pitfall 4: No State Persistence
**Problem:** Pipeline crash loses all progress, requiring full restart.
**Solution:** Save state after each task completion. Implement checkpointing.

### Pitfall 5: Hardcoded Values
**Problem:** Target-specific values baked into scripts.
**Solution:** Externalize all configuration to YAML/JSON files.

### Pitfall 6: Silent Failures
**Problem:** Tasks fail without proper error reporting.
**Solution:** Implement structured logging. Use try/except with specific error types.

### Pitfall 7: Memory Leaks in Long Pipelines
**Problem:** Accumulating results in memory during long-running pipelines.
**Solution:** Stream results to disk. Process in batches. Use generators.

---

## Advanced Techniques

### 1. Dynamic DAG Generation

```python
def build_dynamic_dag(target: str, scan_type: str) -> WorkflowDAG:
    """Build DAG based on target characteristics."""
    dag = WorkflowDAG(f"{scan_type}_{target}")

    if scan_type == "web":
        dag.add_task("subfinder", subfinder_func, [])
        dag.add_task("httpx", httpx_func, ["subfinder"])
        dag.add_task("dir_fuzz", ffuf_func, ["httpx"])
        dag.add_task("nuclei", nuclei_func, ["httpx"])
    elif scan_type == "api":
        dag.add_task("subfinder", subfinder_func, [])
        dag.add_task("httpx", httpx_func, ["subfinder"])
        dag.add_task("swagger_scan", swagger_func, ["httpx"])
        dag.add_task("jwt_audit", jwt_func, ["httpx"])
    elif scan_type == "network":
        dag.add_task("subfinder", subfinder_func, [])
        dag.add_task("masscan", masscan_func, ["subfinder"])
        dag.add_task("nmap", nmap_func, ["masscan"])
        dag.add_task("service_enum", enum_func, ["nmap"])

    return dag
```

### 2. Webhook Notifications

```python
import requests

def notify_completion(state: PipelineState, webhook_url: str):
    """Send pipeline completion notification."""
    summary = {
        "pipeline": state.pipeline_id,
        "status": "completed",
        "completed_at": state.completed_at,
        "tasks": {
            name: result.status.value
            for name, result in state.task_results.items()
        }
    }
    requests.post(webhook_url, json=summary, timeout=10)
```

### 3. Pipeline Composition

```python
def build_composite_pipeline(config: dict) -> dict:
    """Compose multiple sub-pipelines into a master pipeline."""
    sub_pipelines = {
        "recon": build_recon_dag(config["recon"]),
        "scan": build_scan_dag(config["scan"]),
        "report": build_report_dag(config["report"]),
    }
    # Link sub-pipelines: scan depends on recon, report depends on scan
    sub_pipelines["scan"].add_dependency("recon")
    sub_pipelines["report"].add_dependency("scan")
    return sub_pipelines
```

### 4. Conditional Execution

```python
def should_run_nuclei(context: dict) -> bool:
    """Only run nuclei if live hosts were found."""
    return len(context.get("httpx", {}).get("live_hosts", [])) > 0

def should_run_dir_fuzz(context: dict) -> bool:
    """Only run dir fuzzing on hosts with open HTTP ports."""
    return any(":80" in h or ":443" in h
               for h in context.get("port_scan", {}).get("results", []))
```

### 5. Resource Monitoring

```python
import psutil

def check_resources() -> bool:
    """Check if system has enough resources to continue."""
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    if cpu_percent > 90:
        logger.warning(f"High CPU usage: {cpu_percent}%")
        return False
    if memory.percent > 85:
        logger.warning(f"High memory usage: {memory.percent}%")
        return False
    return True
```

---

## Reporting Template

### Pipeline Execution Report

```markdown
# Pipeline Execution Report

## Summary
- **Pipeline ID**: {pipeline_id}
- **Target**: {target}
- **Started**: {started_at}
- **Completed**: {completed_at}
- **Duration**: {total_duration}
- **Status**: {overall_status}

## Task Results

| Task | Status | Duration | Output |
|------|--------|----------|--------|
| subfinder | COMPLETED | 4.2s | 142 subdomains |
| httpx | COMPLETED | 8.1s | 89 live hosts |
| port_scan | COMPLETED | 125.3s | 12 open ports |
| dir_fuzz | COMPLETED | 45.2s | 23 endpoints |
| nuclei | COMPLETED | 67.8s | 3 findings |

## Findings Summary
- **Critical**: {critical_count}
- **High**: {high_count}
- **Medium**: {medium_count}
- **Low**: {low_count}

## Errors Encountered
- None / {error_count} errors (see detailed log)

## Recommendations
1. {recommendation_1}
2. {recommendation_2}

## Next Steps
1. Manual review of nuclei findings
2. Test identified endpoints for business logic flaws
3. Expand scope to discovered subdomains
```

---

## Quick Reference

### One-Liner Commands

```bash
# Run pipeline
python -m pipeline --config config.yaml --target example.com

# Visualize DAG
python -c "from dag_designer import *; build_recon_workflow().visualize()"

# Check pipeline state
cat pipeline_state/pipeline_id_state.json | python -m json.tool

# Run scheduler
python -m scheduler --daemon

# Dry run (validate without executing)
python -m pipeline --config config.yaml --dry-run
```

### Decision Matrix

| Scenario | Tool | Approach |
|----------|------|----------|
| Simple sequential | invoke | Linear script |
| Complex DAG | networkx + custom | Custom runner |
| Distributed | celery | Worker pool |
| Scheduled | apscheduler | Cron-like |
| Visual | prefect | Web UI |

### Configuration Template

```yaml
name: pipeline_name
target: example.com
scope:
  - "*.example.com"
rate_limits:
  rps: 10
  concurrency: 25
timeout: 3600
output_dir: ./results
log_level: INFO
notify:
  webhook: https://hooks.slack.com/xxx
  on_complete: true
  on_failure: true
```

---

*Document Version: 1.0 | Last Updated: 2026 | Automation-Efficiency Series*
