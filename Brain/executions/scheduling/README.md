# Task Scheduling

## Overview

Task scheduling determines when and how execution steps are dispatched to available workers. The module provides pluggable strategies, queue management, concurrent execution, worker pools, and load balancing.

## Key Components

### TaskScheduler

Central coordinator that accepts plans and dispatches steps according to the active strategy.

```python
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Callable
from collections import deque

class Priority(Enum):
    LOW = 0
    NORMAL = 1
    HIGH = 2
    CRITICAL = 3

@dataclass
class ScheduledTask:
    step_id: str
    priority: Priority = Priority.NORMAL
    deadline: float | None = None
    resource_requirements: dict[str, Any] = field(default_factory=dict)
    metadata: dict[str, Any] = field(default_factory=dict)

@dataclass
class TaskScheduler:
    strategy: str = "fifo"
    max_concurrent: int = 4
    queue: deque = field(default_factory=deque)
    running: dict[str, ScheduledTask] = field(default_factory=dict)
    completed: list[str] = field(default_factory=list)

    def enqueue(self, task: ScheduledTask) -> None:
        self.queue.append(task)

    def dequeue(self) -> ScheduledTask | None:
        if not self.queue:
            return None
        if self.strategy == "priority":
            return self._pick_by_priority()
        elif self.strategy == "deadline":
            return self._pick_by_deadline()
        elif self.strategy == "resource_aware":
            return self._pick_by_resource_fit()
        return self.queue.popleft()

    def can_accept(self) -> bool:
        return len(self.running) < self.max_concurrent
```

### Scheduling Strategies

#### FIFO (First In, First Out)

Simple queue — tasks execute in submission order.

```python
def fifo_schedule(scheduler: TaskScheduler) -> list[ScheduledTask]:
    batch = []
    while scheduler.can_accept() and scheduler.queue:
        task = scheduler.dequeue()
        if task:
            batch.append(task)
    return batch
```

#### Priority

Tasks sorted by priority level; higher priority executes first.

```python
def priority_schedule(scheduler: TaskScheduler) -> list[ScheduledTask]:
    sorted_queue = sorted(scheduler.queue, key=lambda t: t.priority.value, reverse=True)
    scheduler.queue = deque(sorted_queue)
    return [scheduler.dequeue() for _ in range(min(scheduler.max_concurrent, len(scheduler.queue)))]
```

#### Deadline-Aware

Tasks closest to their deadline execute first.

```python
def deadline_schedule(scheduler: TaskScheduler) -> list[ScheduledTask]:
    import time
    now = time.time()
    sorted_queue = sorted(
        scheduler.queue,
        key=lambda t: t.deadline - now if t.deadline else float('inf')
    )
    scheduler.queue = deque(sorted_queue)
    return [scheduler.dequeue() for _ in range(min(scheduler.max_concurrent, len(scheduler.queue)))]
```

#### Resource-Aware

Matches task resource requirements against available worker capacity.

```python
@dataclass
class WorkerPool:
    workers: list[dict[str, Any]] = field(default_factory=list)
    total_capacity: dict[str, float] = field(default_factory=dict)
    used_capacity: dict[str, float] = field(default_factory=dict)

    def available(self, resource: str) -> float:
        return self.total_capacity.get(resource, 0) - self.used_capacity.get(resource, 0)

    def fits(self, requirements: dict[str, float]) -> bool:
        return all(self.available(r) >= v for r, v in requirements.items())

    def allocate(self, requirements: dict[str, float]) -> None:
        for r, v in requirements.items():
            self.used_capacity[r] = self.used_capacity.get(r, 0) + v

    def release(self, requirements: dict[str, float]) -> None:
        for r, v in requirements.items():
            self.used_capacity[r] = max(0, self.used_capacity.get(r, 0) - v)
```

### Queue Management

```python
import heapq
from threading import Lock

class PriorityQueue:
    def __init__(self):
        self._heap: list[tuple[int, int, ScheduledTask]] = []
        self._counter = 0
        self._lock = Lock()

    def push(self, task: ScheduledTask, priority: int) -> None:
        with self._lock:
            heapq.heappush(self._heap, (priority, self._counter, task))
            self._counter += 1

    def pop(self) -> ScheduledTask | None:
        with self._lock:
            if self._heap:
                _, _, task = heapq.heappop(self._heap)
                return task
            return None

    def size(self) -> int:
        return len(self._heap)
```

### Concurrent Execution

```python
import concurrent.futures

class ConcurrentScheduler:
    def __init__(self, worker_pool: WorkerPool):
        self.pool = worker_pool
        self.executor = concurrent.futures.ThreadPoolExecutor(max_workers=8)

    def dispatch(self, tasks: list[ScheduledTask], handlers: dict[str, Callable]) -> dict[str, concurrent.futures.Future]:
        futures = {}
        for task in tasks:
            if task.step_id in handlers:
                fut = self.executor.submit(handlers[task.step_id], **task.metadata)
                futures[task.step_id] = fut
        return futures

    def shutdown(self, wait: bool = True) -> None:
        self.executor.shutdown(wait=wait)
```

### Load Balancing

Distributes tasks across workers based on current load metrics.

```python
@dataclass
class LoadBalancer:
    workers: list[WorkerPool] = field(default_factory=list)
    strategy: str = "least_loaded"

    def select_worker(self, task: ScheduledTask) -> WorkerPool | None:
        available = [w for w in self.workers if w.fits(task.resource_requirements)]
        if not available:
            return None
        if self.strategy == "least_loaded":
            return min(available, key=lambda w: sum(w.used_capacity.values()))
        if self.strategy == "round_robin":
            return available[hash(task.step_id) % len(available)]
        if self.strategy == "random":
            import random
            return random.choice(available)
        return available[0]
```

## Design Notes

- Strategies are pluggable — swap by setting `scheduler.strategy` at runtime.
- Deadline scheduling uses wall-clock time; clock skew can affect ordering.
- Resource-aware scheduling prevents overcommitment on memory/CPU-bound tasks.
- Queue operations are thread-safe for multi-threaded dispatchers.
- Worker pools are elastic — capacity reclaims on task completion.
- Load balancing selects among healthy workers; health checks run separately.
