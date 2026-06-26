# Execution Monitoring

## Overview

Execution monitoring provides visibility into running tasks — progress tracking, metrics collection, alerting on anomalies, execution history, performance analysis, and bottleneck detection.

## Key Components

### ExecutionMonitor

Central hub that observes execution state and emits events.

```python
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Callable
from datetime import datetime
import time

class MetricType(Enum):
    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    RATE = "rate"

class AlertSeverity(Enum):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"

@dataclass
class ExecutionMonitor:
    metrics: dict[str, list[dict[str, Any]]] = field(default_factory=dict)
    alerts: list[dict[str, Any]] = field(default_factory=list)
    listeners: list[Callable] = field(default_factory=list)
    history: list[dict[str, Any]] = field(default_factory=list)
    _start_times: dict[str, float] = field(default_factory=dict)

    def record_metric(self, name: str, value: float, metric_type: MetricType, tags: dict | None = None) -> None:
        entry = {
            "name": name,
            "value": value,
            "type": metric_type.value,
            "tags": tags or {},
            "timestamp": time.time(),
        }
        self.metrics.setdefault(name, []).append(entry)
        self._emit("metric", entry)

    def start_tracking(self, step_id: str) -> None:
        self._start_times[step_id] = time.time()

    def stop_tracking(self, step_id: str) -> float:
        start = self._start_times.pop(step_id, time.time())
        duration = time.time() - start
        self.record_metric(f"{step_id}.duration", duration, MetricType.HISTOGRAM)
        return duration

    def _emit(self, event_type: str, data: dict) -> None:
        for listener in self.listeners:
            try:
                listener(event_type, data)
            except Exception:
                pass
```

### Progress Tracking

```python
@dataclass
class ProgressTracker:
    total_steps: int = 0
    completed_steps: int = 0
    failed_steps: int = 0
    skipped_steps: int = 0
    step_progress: dict[str, float] = field(default_factory=dict)

    @property
    def overall_progress(self) -> float:
        if self.total_steps == 0:
            return 0.0
        done = self.completed_steps + self.failed_steps + self.skipped_steps
        return done / self.total_steps

    def update_step(self, step_id: str, progress: float) -> None:
        self.step_progress[step_id] = min(max(progress, 0.0), 1.0)

    def mark_complete(self, step_id: str) -> None:
        self.completed_steps += 1
        self.step_progress[step_id] = 1.0

    def mark_failed(self, step_id: str) -> None:
        self.failed_steps += 1

    def mark_skipped(self, step_id: str) -> None:
        self.skipped_steps += 1

    def snapshot(self) -> dict[str, Any]:
        return {
            "total": self.total_steps,
            "completed": self.completed_steps,
            "failed": self.failed_steps,
            "skipped": self.skipped_steps,
            "progress": self.overall_progress,
        }
```

### Metrics Collection

```python
class MetricsCollector:
    def __init__(self, monitor: ExecutionMonitor):
        self.monitor = monitor
        self._counters: dict[str, int] = {}

    def increment(self, name: str, amount: int = 1, tags: dict | None = None) -> None:
        self._counters[name] = self._counters.get(name, 0) + amount
        self.monitor.record_metric(name, self._counters[name], MetricType.COUNTER, tags)

    def gauge(self, name: str, value: float, tags: dict | None = None) -> None:
        self.monitor.record_metric(name, value, MetricType.GAUGE, tags)

    def timer(self, name: str, tags: dict | None = None) -> "TimerContext":
        return TimerContext(self.monitor, name, tags)

class TimerContext:
    def __init__(self, monitor: ExecutionMonitor, name: str, tags: dict | None):
        self.monitor = monitor
        self.name = name
        self.tags = tags
        self.start: float = 0

    def __enter__(self):
        self.start = time.time()
        return self

    def __exit__(self, *args):
        duration = time.time() - self.start
        self.monitor.record_metric(self.name, duration, MetricType.HISTOGRAM, self.tags)
```

### Alerting

```python
@dataclass
class AlertRule:
    metric_name: str
    condition: str  # "gt", "lt", "eq"
    threshold: float
    severity: AlertSeverity = AlertSeverity.WARNING
    message_template: str = ""

    def check(self, value: float) -> bool:
        if self.condition == "gt":
            return value > self.threshold
        if self.condition == "lt":
            return value < self.threshold
        if self.condition == "eq":
            return value == self.threshold
        return False

class AlertEngine:
    def __init__(self, monitor: ExecutionMonitor):
        self.monitor = monitor
        self.rules: list[AlertRule] = []
        self.handlers: list[Callable] = []

    def add_rule(self, rule: AlertRule) -> None:
        self.rules.append(rule)

    def evaluate(self, metric_name: str, value: float) -> list[dict[str, Any]]:
        triggered = []
        for rule in self.rules:
            if rule.metric_name == metric_name and rule.check(value):
                alert = {
                    "rule": rule,
                    "metric": metric_name,
                    "value": value,
                    "severity": rule.severity.value,
                    "message": rule.message_template.format(value=value, threshold=rule.threshold),
                    "timestamp": time.time(),
                }
                triggered.append(alert)
                self.monitor.alerts.append(alert)
                for handler in self.handlers:
                    handler(alert)
        return triggered
```

### Execution History

```python
@dataclass
class ExecutionRecord:
    plan_id: str
    step_id: str
    status: str
    start_time: float
    end_time: float | None = None
    duration: float | None = None
    error: str | None = None
    result_summary: dict[str, Any] = field(default_factory=dict)

class HistoryStore:
    def __init__(self):
        self.records: list[ExecutionRecord] = []
        self._max_history: int = 10000

    def record(self, rec: ExecutionRecord) -> None:
        if rec.end_time and rec.start_time:
            rec.duration = rec.end_time - rec.start_time
        self.records.append(rec)
        if len(self.records) > self._max_history:
            self.records = self.records[-self._max_history:]

    def query(self, plan_id: str | None = None, status: str | None = None) -> list[ExecutionRecord]:
        results = self.records
        if plan_id:
            results = [r for r in results if r.plan_id == plan_id]
        if status:
            results = [r for r in results if r.status == status]
        return results
```

### Performance Analysis

```python
class PerformanceAnalyzer:
    def __init__(self, history: HistoryStore):
        self.history = history

    def summary(self, plan_id: str) -> dict[str, Any]:
        records = self.history.query(plan_id=plan_id)
        durations = [r.duration for r in records if r.duration is not None]
        errors = [r for r in records if r.status == "failed"]
        return {
            "total_runs": len(records),
            "success_rate": 1 - (len(errors) / max(len(records), 1)),
            "avg_duration": sum(durations) / max(len(durations), 1),
            "p95_duration": sorted(durations)[int(len(durations) * 0.95)] if durations else 0,
            "p99_duration": sorted(durations)[int(len(durations) * 0.99)] if durations else 0,
            "error_rate": len(errors) / max(len(records), 1),
        }

    def slowest_steps(self, n: int = 5) -> list[dict[str, Any]]:
        from collections import defaultdict
        step_durations: dict[str, list[float]] = defaultdict(list)
        for rec in self.history.records:
            if rec.duration is not None:
                step_durations[rec.step_id].append(rec.duration)
        ranked = sorted(
            step_durations.items(),
            key=lambda x: sum(x[1]) / len(x[1]),
            reverse=True,
        )
        return [{"step": s, "avg_ms": d / len(d) * 1000, "count": len(d)} for s, d in ranked[:n]]
```

### Bottleneck Detection

```python
class BottleneckDetector:
    def __init__(self, analyzer: PerformanceAnalyzer):
        self.analyzer = analyzer

    def detect(self, threshold_ratio: float = 0.3) -> list[dict[str, Any]]:
        slowest = self.analyzer.slowest_steps(10)
        if not slowest:
            return []
        total_avg = sum(s["avg_ms"] for s in slowest)
        bottlenecks = []
        for step in slowest:
            ratio = step["avg_ms"] / total_avg if total_avg > 0 else 0
            if ratio > threshold_ratio:
                bottlenecks.append({
                    "step": step["step"],
                    "avg_ms": step["avg_ms"],
                    "share": ratio,
                    "recommendation": f"Consider optimizing or parallelizing '{step['step']}'",
                })
        return bottlenecks
```

## Design Notes

- Metrics are append-only — no in-place mutation of historical data.
- Alert rules evaluate synchronously on metric emission; async handlers recommended.
- History store caps at configurable limit to bound memory usage.
- Performance analysis computes on-demand from raw history, not cached aggregates.
- Bottleneck detection uses proportional thresholds relative to total step time.
- All timestamps use Unix epoch (float) for consistency across components.
