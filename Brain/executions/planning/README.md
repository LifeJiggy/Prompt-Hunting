# Execution Planning

## Overview

Execution planning defines how complex operations are structured into ordered, executable steps. The planning module handles step definitions, dependency resolution, conditional branching, and parallel execution paths.

## Key Components

### ExecutionPlan

The central model representing a complete execution strategy.

```python
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Callable

class StepStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    SKIPPED = "skipped"
    BLOCKED = "blocked"

@dataclass
class Step:
    id: str
    name: str
    handler: Callable
    dependencies: list[str] = field(default_factory=list)
    condition: Callable[[], bool] | None = None
    timeout: float | None = None
    retries: int = 0
    params: dict[str, Any] = field(default_factory=dict)
    status: StepStatus = StepStatus.PENDING
    result: Any = None
    error: Exception | None = None

@dataclass
class ExecutionPlan:
    id: str
    name: str
    steps: list[Step] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)

    def add_step(self, step: Step) -> None:
        self.steps.append(step)

    def get_step(self, step_id: str) -> Step | None:
        return next((s for s in self.steps if s.id == step_id), None)

    def get_ready_steps(self) -> list[Step]:
        completed = {s.id for s in self.steps if s.status == StepStatus.COMPLETED}
        return [
            s for s in self.steps
            if s.status == StepStatus.PENDING
            and all(dep in completed for dep in s.dependencies)
            and (s.condition is None or s.condition())
        ]
```

### Dependency Graphs

Steps declare dependencies that form a directed acyclic graph (DAG). The planner validates no cycles exist and resolves execution order.

```python
def validate_plan(plan: ExecutionPlan) -> list[str]:
    errors = []
    step_ids = {s.id for s in plan.steps}

    for step in plan.steps:
        for dep in step.dependencies:
            if dep not in step_ids:
                errors.append(f"Step '{step.id}' depends on unknown step '{dep}'")

    if _has_cycle(plan.steps):
        errors.append("Plan contains circular dependencies")

    return errors

def _has_cycle(steps: list[Step]) -> bool:
    visited, stack = set(), set()

    def dfs(step_id: str) -> bool:
        if step_id in stack:
            return True
        if step_id in visited:
            return False
        visited.add(step_id)
        stack.add(step_id)
        step = next((s for s in steps if s.id == step_id), None)
        if step:
            for dep in step.dependencies:
                if dfs(dep):
                    return True
        stack.discard(step_id)
        return False

    return any(dfs(s.id) for s in steps)
```

### Parallel Branches

Independent steps run concurrently via `ThreadPoolExecutor` or `ProcessPoolExecutor`.

```python
from concurrent.futures import ThreadPoolExecutor, as_completed

def execute_parallel(steps: list[Step], max_workers: int = 4) -> dict[str, Any]:
    results = {}
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(_run_step, s): s.id for s in steps}
        for future in as_completed(futures):
            step_id = futures[future]
            try:
                results[step_id] = future.result()
            except Exception as e:
                results[step_id] = {"error": str(e)}
    return results
```

### Conditional Execution

Steps can gate execution on runtime conditions evaluated at plan time.

```python
def evaluate_conditions(plan: ExecutionPlan) -> list[Step]:
    executable = []
    for step in plan.steps:
        if step.condition is not None and not step.condition():
            step.status = StepStatus.SKIPPED
            continue
        executable.append(step)
    return executable
```

### Plan Templates

Reusable plan definitions for common execution patterns.

```python
PLAN_TEMPLATES = {
    "data_pipeline": [
        Step(id="extract", name="Extract Data", handler=extract_handler),
        Step(id="transform", name="Transform", handler=transform_handler, dependencies=["extract"]),
        Step(id="validate", name="Validate", handler=validate_handler, dependencies=["transform"]),
        Step(id="load", name="Load", handler=load_handler, dependencies=["validate"]),
    ],
    "ml_training": [
        Step(id="prepare", name="Prepare Dataset", handler=prepare_handler),
        Step(id="train", name="Train Model", handler=train_handler, dependencies=["prepare"]),
        Step(id="evaluate", name="Evaluate", handler=evaluate_handler, dependencies=["train"]),
        Step(id="deploy", name="Deploy", handler=deploy_handler, dependencies=["evaluate"]),
    ],
}

def create_plan_from_template(template_name: str, plan_id: str) -> ExecutionPlan:
    steps = PLAN_TEMPLATES.get(template_name, [])
    return ExecutionPlan(id=plan_id, name=template_name, steps=steps)
```

## Design Notes

- Steps are immutable after creation — clone to modify.
- Dependencies form a DAG; cycles are rejected at validation.
- Conditional steps evaluate lazily at execution time, not plan creation.
- Plan templates enable consistent execution across similar workloads.
- Timeout and retry policies are per-step, not global.
