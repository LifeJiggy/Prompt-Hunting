# Brain Executions

**Component:** Task Execution Infrastructure

Manages the complete lifecycle of task execution — from planning and scheduling through step-by-step processing, progress monitoring, retry handling, and error recovery. The execution engine is the workhorse that turns agent capabilities into completed tasks.

---

## Purpose

Executions provides the infrastructure for running tasks reliably at scale. It handles:

- **Execution planning** — Breaking complex tasks into executable steps
- **Task scheduling** — Ordering and prioritizing work items
- **Step execution** — Running individual operations with timeout and retry
- **Progress monitoring** — Tracking completion across parallel tasks
- **Error handling** — Recovering from failures gracefully
- **Resource management** — Preventing resource exhaustion

---

## Execution Lifecycle

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  PLAN    │───▶│ SCHEDULE │───▶│ EXECUTE  │───▶│ COMPLETE │
└──────────┘    └──────────┘    └────┬─────┘    └──────────┘
                                     │
                                     ▼
                                ┌──────────┐
                                │  RETRY   │──── back to EXECUTE
                                └────┬─────┘
                                     │ (max retries exceeded)
                                     ▼
                                ┌──────────┐
                                │  FAILED  │
                                └──────────┘
```

---

## Core Components

### Execution Plan

An execution plan defines what needs to happen:

```yaml
plan:
  id: "plan_abc123"
  task: "Enumerate and scan target.com"
  steps:
    - id: step_1
      action: "subdomain_enumerate"
      target: "target.com"
      tool: "subfinder"
      timeout: 120
      retries: 2
    - id: step_2
      action: "http_probe"
      input_from: step_1
      tool: "httpx"
      timeout: 60
    - id: step_3
      action: "vulnerability_scan"
      input_from: step_2
      tool: "nuclei"
      timeout: 300
      retries: 1
  dependencies:
    - step_2 depends_on step_1
    - step_3 depends_on step_2
```

Plans support:
- **Sequential steps** — Step B runs after Step A completes
- **Parallel steps** — Steps C and D run simultaneously
- **Conditional branches** — Step E runs only if Step D finds results
- **Loop constructs** — Repeat steps until a condition is met

### Task Scheduler

The scheduler manages task ordering and resource allocation:

| Scheduling Strategy | Description | Use Case |
|--------------------|-------------|----------|
| **FIFO** | First in, first out | Simple pipelines |
| **Priority** | Higher priority tasks first | Multi-target operations |
| **Deadline** | Tasks closest to deadline first | Time-sensitive operations |
| **Resource-aware** | Schedule based on available resources | Large-scale operations |
| **Dependency-aware** | Respect task dependencies | Complex workflows |

### Step Executor

Individual step execution with built-in reliability:

```python
# Step execution flow
result = executor.run_step(
    step=step,
    context=previous_results,
    config=step_config
)

# Built-in features:
# - Timeout enforcement (kill after N seconds)
# - Retry with exponential backoff
# - Output validation
# - Resource cleanup on failure
# - Progress reporting
```

### Retry Policies

| Policy | Behavior | When to Use |
|--------|----------|-------------|
| **Fixed** | Wait constant time between retries | Network calls |
| **Exponential** | Double wait time each retry | API rate limits |
| **Linear** | Add constant time each retry | General purpose |
| **Custom** | User-defined backoff function | Special requirements |

---

## Progress Monitoring

Real-time visibility into execution state:

```yaml
progress:
  plan_id: "plan_abc123"
  status: "running"
  started_at: "2025-01-15T10:30:00Z"
  steps_total: 5
  steps_completed: 3
  steps_failed: 0
  steps_running: 1
  steps_pending: 1
  current_step: "step_4"
  estimated_remaining: "2m 30s"
  resource_usage:
    cpu: "45%"
    memory: "2.1 GB"
    network: "12 Mbps"
```

Progress updates are emitted as events, enabling dashboards, notifications, and automated scaling.

---

## Error Handling Strategies

### Per-Step Error Handling

```
Step Failure
├── Retry? (retries_remaining > 0)
│   ├── Yes → Wait (backoff) → Retry step
│   └── No → Continue
├── Fallback? (fallback defined)
│   ├── Yes → Run fallback step
│   └── No → Continue
├── Skip? (step marked optional)
│   ├── Yes → Log warning → Continue
│   └── No → Mark plan as failed
```

### Plan-Level Error Handling

| Strategy | Behavior |
|----------|----------|
| **Fail-fast** | Stop entire plan on first failure |
| **Best-effort** | Continue all independent steps |
| **Critical-path** | Only fail if critical step fails |
| **Threshold** | Fail if >N% of steps fail |

---

## Parallel Execution

```yaml
parallel_group:
  id: "group_1"
  strategy: "all"  # all | any | majority
  max_concurrent: 10
  steps:
    - scan_subdomain_1
    - scan_subdomain_2
    - scan_subdomain_3
  on_complete: "merge_results"
```

Parallel execution features:
- **Concurrency limits** — Prevent resource exhaustion
- **Work distribution** — Split large tasks across workers
- **Result merging** — Combine parallel outputs into unified results
- **Partial failure handling** — Continue if some parallel tasks fail

---

## Resource Management

| Resource | Monitoring | Limits |
|----------|-----------|--------|
| **CPU** | Usage percentage | Max concurrent steps |
| **Memory** | Peak usage per step | Total allocation cap |
| **Network** | Bandwidth per connection | Connection pool size |
| **Disk** | I/O operations per second | Temp storage quota |
| **Time** | Wall-clock per step and plan | Global timeout |

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | TaskDefinition, TaskResult, Error types |
| `memory/` | Store execution logs, retrieve past results |
| `tools/` | Invoke tools for each step |
| `session-managements/` | Checkpoint execution state, resume on restart |
| `runtime/` | Resource monitoring, health checks |
| `utils/` | Logging, timing, serialization |

---

## Example: Bug Bounty Pipeline Execution

```yaml
plan:
  name: "target_scan_target.com"
  steps:
    - subdomain_enum: subfinder -d target.com
    - http_probe: httpx -l subdomains.txt
    - port_scan: naabu -l live.txt
    - vuln_scan: nuclei -l live.txt -t critical/
    - report: generate_report findings.json
  execution:
    max_concurrent: 3
    timeout: 3600
    retry_policy: exponential
    on_failure: best_effort
```

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
