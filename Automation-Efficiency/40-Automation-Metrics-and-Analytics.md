# 40 — Automation Metrics and Analytics

## 1. Introduction

Automation generates vast quantities of operational data: scan durations, finding counts, triage decisions, submission outcomes, and tool performance. Without systematic analytics, this data remains an underutilized asset. This document defines the KPIs, funnel analysis, trend detection, and impact-scoring frameworks that turn raw automation telemetry into actionable intelligence for optimizing the security scanning pipeline.

---

## 2. KPIs for Automation

Key Performance Indicators (KPIs) for automation must be operationally meaningful, not vanity metrics. The core KPIs are organized by the stage they measure.

### 2.1 Scan Coverage KPI

Scan coverage measures what fraction of the authorized attack surface is actually scanned on a recurring basis.

```python
from dataclasses import dataclass
from typing import List, Dict, Set
import ipaddress

@dataclass
class CoverageMetric:
    total_targets: int
    scanned_targets: int
    coverage_ratio: float = 0.0
    by_category: Dict[str, Dict[str, int]] = None

    def __post_init__(self):
        if self.by_category is None:
            self.by_category = {}
        if self.total_targets > 0:
            self.coverage_ratio = self.scanned_targets / self.total_targets

    def record_category(self, category: str, total: int, scanned: int):
        self.by_category[category] = {"total": total, "scanned": scanned}

def compute_coverage(
    authorized_targets: List[str],
    scanned_hosts: Set[str],
    categories: Dict[str, List[str]] = None,
) -> CoverageMetric:
    total = len(authorized_targets)
    scanned = len(set(authorized_targets) & scanned_hosts)
    metric = CoverageMetric(total_targets=total, scanned_targets=scanned)
    if categories:
        for cat, targets in categories.items():
            cat_total = len(targets)
            cat_scanned = len(set(targets) & scanned_hosts)
            metric.record_category(cat, cat_total, cat_scanned)
    return metric

# Usage
authorized = ["app.example.com", "api.example.com", "admin.example.com", "vpn.example.com"]
scanned = {"app.example.com", "api.example.com", "admin.example.com"}
categories = {
    "web": ["app.example.com", "api.example.com"],
    "admin": ["admin.example.com"],
    "remote_access": ["vpn.example.com"],
}
metric = compute_coverage(authorized, scanned, categories)
print(f"Overall coverage: {metric.coverage_ratio:.1%}")
for cat, data in metric.by_category.items():
    ratio = data["scanned"] / data["total"] if data["total"] > 0 else 0
    print(f"  {cat}: {ratio:.1%} ({data['scanned']}/{data['total']})")
```

**Coverage targets:**
- Overall: ≥ 95% of authorized targets scanned within each 24-hour window.
- Critical assets: 100% coverage, scanned at minimum daily.
- New assets: Scanned within 4 hours of onboarding into the asset inventory.

### 2.2 Finding Rate KPI

Finding rate measures the volume and severity distribution of discoveries per scan cycle.

```python
from dataclasses import dataclass, field
from typing import Dict, List
from datetime import datetime, timezone
from collections import defaultdict

@dataclass
class FindingRateMetric:
    scan_id: str
    scan_timestamp: str
    total_findings: int = 0
    by_severity: Dict[str, int] = field(default_factory=lambda: defaultdict(int))
    by_tool: Dict[str, int] = field(default_factory=lambda: defaultdict(int))
    new_findings: int = 0
    repeated_findings: int = 0
    false_positive_rate: float = 0.0

    @property
    def critical_rate(self) -> float:
        return self.by_severity.get("critical", 0) / self.total_findings if self.total_findings > 0 else 0.0

    @property
    def findings_per_target(self) -> float:
        return self.total_findings / self.scanned_targets if self.scanned_targets > 0 else 0.0

def compute_finding_rate(
    scan_id: str,
    findings: List[Dict],
    known_finding_hashes: Set[str],
    scanned_targets: int,
) -> FindingRateMetric:
    metric = FindingRateMetric(scan_id=scan_id, scan_timestamp=datetime.now(timezone.utc).isoformat(), scanned_targets=scanned_targets)
    for f in findings:
        metric.total_findings += 1
        metric.by_severity[f.get("severity", "unknown")] += 1
        metric.by_tool[f.get("tool", "unknown")] += 1
        f_hash = hashlib.sha256(json.dumps(f, sort_keys=True).encode()).hexdigest()
        if f_hash in known_finding_hashes:
            metric.repeated_findings += 1
        else:
            metric.new_findings += 1
            known_finding_hashes.add(f_hash)
    return metric
```

**Finding rate targets:**
- New critical findings: Alert immediately; no rate limit applies.
- Repeated findings: Should decrease over time as remediation matures. A rising repeated-finding rate indicates stalled remediation.
- False positive rate: Target < 15% for all tools combined. Per-tool FPR should be tracked and tools with FPR > 25% flagged for tuning.

### 2.3 Time-to-Triage KPI

Time-to-triage measures how quickly a finding moves from raw discovery to a human-reviewed status.

```python
from dataclasses import dataclass
from typing import List, Dict, Optional
from datetime import datetime

@dataclass
class TriageEvent:
    finding_id: str
    event_type: str  # "discovered", "triaged", "assigned", "resolved"
    timestamp: str
    actor: str

class TriageTimer:
    def __init__(self, events: List[TriageEvent]):
        self.events = {e.finding_id: e for e in events}
        self.by_finding: Dict[str, List[TriageEvent]] = defaultdict(list)
        for e in events:
            self.by_finding[e.finding_id].append(e)

    def time_to_triage(self, finding_id: str) -> Optional[float]:
        events = sorted(self.by_finding.get(finding_id, []), key=lambda e: e.timestamp)
        discovered = next((e for e in events if e.event_type == "discovered"), None)
        triaged = next((e for e in events if e.event_type == "triaged"), None)
        if not discovered or not triaged:
            return None
        t1 = datetime.fromisoformat(discovered.timestamp.replace("Z", "+00:00"))
        t2 = datetime.fromisoformat(triaged.timestamp.replace("Z", "+00:00"))
        return (t2 - t1).total_seconds() / 3600  # hours

    def aggregate_stats(self) -> Dict:
        times = []
        for fid in self.by_finding:
            t = self.time_to_triage(fid)
            if t is not None:
                times.append(t)
        if not times:
            return {"count": 0}
        times.sort()
        n = len(times)
        return {
            "count": n,
            "p50_hours": times[n // 2],
            "p90_hours": times[int(n * 0.9)],
            "p99_hours": times[int(n * 0.99)] if n >= 100 else times[-1],
            "max_hours": times[-1],
            "mean_hours": sum(times) / n,
            "untriaged": len(self.by_finding) - len(times),
        }
```

**Time-to-triage targets:**
- Critical findings: < 4 hours to first human triage.
- High findings: < 24 hours.
- Medium/Low findings: < 5 business days.
- Untriaged backlog > 7 days triggers an alert to the triage team lead.

---

## 3. Funnel Analysis

The automation funnel tracks findings as they move through stages: raw → deduplicated → triaged → submitted/remediated. Funnel metrics reveal bottlenecks and drop-off points.

```
Raw Findings (100%)
  ↓ dedup
Deduplicated Findings (72%)
  ↓ triage
Triaged Findings (58%)
  ↓ false-positive removal
Validated Findings (44%)
  ↓ assignment
Assigned Findings (38%)
  ↓ remediation
Remediated Findings (21%)
  ↓ verification
Closed Findings (19%)
```

```python
from dataclasses import dataclass, field
from typing import List, Dict
from datetime import datetime, timezone

@dataclass
class FunnelStage:
    name: str
    count: int
    timestamp: str
    metadata: Dict = field(default_factory=dict)

class FunnelAnalyzer:
    def __init__(self, stages: List[FunnelStage]):
        self.stages = stages

    def conversion_rates(self) -> List[Dict]:
        rates = []
        for i in range(len(self.stages) - 1):
            current = self.stages[i]
            next_stage = self.stages[i + 1]
            rate = next_stage.count / current.count if current.count > 0 else 0
            dropoff = current.count - next_stage.count
            rates.append({
                "from_stage": current.name,
                "to_stage": next_stage.name,
                "conversion_rate": round(rate, 4),
                "dropoff_count": dropoff,
                "dropoff_pct": round((1 - rate) * 100, 2),
            })
        return rates

    def overall_efficiency(self) -> float:
        if len(self.stages) < 2:
            return 0.0
        first = self.stages[0].count
        last = self.stages[-1].count
        return last / first if first > 0 else 0.0

    def bottleneck_stage(self) -> str:
        rates = self.conversion_rates()
        if not rates:
            return "none"
        worst = min(rates, key=lambda r: r["conversion_rate"])
        return worst["from_stage"]

# Usage
stages = [
    FunnelStage("raw", 1000, "2024-12-01"),
    FunnelStage("deduplicated", 720, "2024-12-01"),
    FunnelStage("triaged", 580, "2024-12-01"),
    FunnelStage("validated", 440, "2024-12-01"),
    FunnelStage("assigned", 380, "2024-12-01"),
    FunnelStage("remediated", 210, "2024-12-05"),
    FunnelStage("closed", 190, "2024-12-10"),
]
analyzer = FunnelAnalyzer(stages)
for rate in analyzer.conversion_rates():
    print(f"{rate['from_stage']} → {rate['to_stage']}: {rate['conversion_rate']:.0%} (dropoff: {rate['dropoff_pct']:.1f}%)")
print(f"Bottleneck: {analyzer.bottleneck_stage()}")
```

**Funnel optimization targets:**
- Deduplication loss: < 30% (high loss indicates overly aggressive dedup or broken hash function).
- Triage-to-validated conversion: > 75% (low conversion indicates poor triage quality or noisy scanners).
- Remediation rate: Track by severity. Critical findings should remediate > 80% within 30 days.
- Identify the bottleneck stage monthly; assign an owner and a remediation target.

---

## 4. Trend Analysis

Trend analysis detects long-term changes in scan coverage, finding rates, remediation velocity, and tool reliability. Use time-series analysis with at least 90 days of history to distinguish signal from noise.

```python
import json
from datetime import datetime, timezone, timedelta
from typing import List, Dict, Optional
from collections import defaultdict
import statistics

class TrendAnalyzer:
    def __init__(self, metrics: List[Dict]):
        self.metrics = sorted(metrics, key=lambda m: m["timestamp"])

    def compute_rolling_average(self, metric_name: str, window_days: int = 7) -> List[Dict]:
        values = [(m["timestamp"], m[metric_name]) for m in self.metrics if metric_name in m]
        result = []
        for i, (ts, val) in enumerate(values):
            window_start = datetime.fromisoformat(ts.replace("Z", "+00:00")) - timedelta(days=window_days)
            window_values = [
                v for t, v in values[: i + 1]
                if datetime.fromisoformat(t.replace("Z", "+00:00")) >= window_start
            ]
            avg = sum(window_values) / len(window_values)
            result.append({"timestamp": ts, "value": val, "rolling_avg": round(avg, 4)})
        return result

    def detect_trend(self, metric_name: str, window_days: int = 30) -> Dict:
        recent = self._recent_values(metric_name, window_days)
        prior = self._prior_values(metric_name, window_days)
        if not recent or not prior:
            return {"trend": "insufficient_data"}
        recent_mean = statistics.mean(recent)
        prior_mean = statistics.mean(prior)
        if prior_mean == 0:
            return {"trend": "undefined", "recent_mean": recent_mean}
        change_pct = ((recent_mean - prior_mean) / prior_mean) * 100
        if abs(change_pct) < 5:
            trend = "stable"
        elif change_pct > 0:
            trend = "increasing"
        else:
            trend = "decreasing"
        return {
            "trend": trend,
            "change_pct": round(change_pct, 2),
            "recent_mean": round(recent_mean, 4),
            "prior_mean": round(prior_mean, 4),
            "recent_count": len(recent),
            "prior_count": len(prior),
        }

    def _recent_values(self, metric_name: str, days: int) -> List[float]:
        cutoff = datetime.now(timezone.utc) - timedelta(days=days)
        return [
            m[metric_name] for m in self.metrics
            if datetime.fromisoformat(m["timestamp"].replace("Z", "+00:00")) >= cutoff
            and metric_name in m
        ]

    def _prior_values(self, metric_name: str, days: int) -> List[float]:
        cutoff = datetime.now(timezone.utc) - timedelta(days=days * 2)
        recent_cutoff = datetime.now(timezone.utc) - timedelta(days=days)
        return [
            m[metric_name] for m in self.metrics
            if cutoff <= datetime.fromisoformat(m["timestamp"].replace("Z", "+00:00")) < recent_cutoff
            and metric_name in m
        ]

    def detect_anomalies(self, metric_name: str, stddev_threshold: float = 2.0) -> List[Dict]:
        values = [m[metric_name] for m in self.metrics if metric_name in m]
        if len(values) < 10:
            return []
        mean = statistics.mean(values)
        stdev = statistics.stdev(values)
        anomalies = []
        for m in self.metrics:
            if metric_name in m:
                val = m[metric_name]
                z_score = abs(val - mean) / (stdev or 1)
                if z_score > stddev_threshold:
                    anomalies.append({
                        "timestamp": m["timestamp"],
                        "value": val,
                        "mean": round(mean, 4),
                        "stdev": round(stdev, 4),
                        "z_score": round(z_score, 2),
                        "direction": "above" if val > mean else "below",
                    })
        return anomalies
```

**Trend reporting cadence:**
- **Daily**: Automated anomaly detection on critical metrics (coverage, finding rate, P99 latency).
- **Weekly**: Rolling 7-day vs. prior 7-day comparison for all KPIs.
- **Monthly**: 90-day trend analysis with regression toward mean for seasonal patterns.

---

## 5. Anomaly Detection in Scan Results

Anomaly detection identifies unexpected patterns in scan outputs that may indicate a broken scanner, a new attack vector, or a targeted campaign.

```python
from typing import List, Dict
from datetime import datetime, timezone
import statistics

class ScanAnomalyDetector:
    def __init__(self, history: List[Dict]):
        self.history = history

    def detect_finding_spike(self, window_minutes: int = 60, min_findings: int = 50) -> List[Dict]:
        now = datetime.now(timezone.utc)
        cutoff = now - timedelta(minutes=window_minutes)
        recent = [
            m for m in self.history
            if datetime.fromisoformat(m["timestamp"].replace("Z", "+00:00")) >= cutoff
        ]
        if len(recent) < min_findings:
            baseline = self._baseline_findings_per_hour()
            current_rate = len(recent) / (window_minutes / 60)
            if current_rate > baseline * 3:
                return [{
                    "type": "finding_rate_spike",
                    "current_rate_per_hour": round(current_rate, 2),
                    "baseline_rate_per_hour": round(baseline, 2),
                    "multiplier": round(current_rate / baseline, 2),
                    "severity": "high" if current_rate > baseline * 5 else "medium",
                }]
        return []

    def detect_severity_shift(self, window_days: int = 7) -> List[Dict]:
        recent = self._recent_findings(window_days)
        prior = self._prior_findings(window_days)
        if not recent or not prior:
            return []
        recent_critical_pct = sum(1 for f in recent if f.get("severity") == "critical") / len(recent)
        prior_critical_pct = sum(1 for f in prior if f.get("severity") == "critical") / len(prior)
        delta = recent_critical_pct - prior_critical_pct
        if abs(delta) > 0.10:
            direction = "increase" if delta > 0 else "decrease"
            return [{
                "type": "severity_distribution_shift",
                "direction": direction,
                "delta_pct": round(delta * 100, 2),
                "recent_critical_pct": round(recent_critical_pct * 100, 2),
                "prior_critical_pct": round(prior_critical_pct * 100, 2),
                "severity": "high",
            }]
        return []

    def detect_tool_failure(self, window_hours: int = 1) -> List[Dict]:
        cutoff = datetime.now(timezone.utc) - timedelta(hours=window_hours)
        recent_runs = [
            m for m in self.history
            if m.get("event_type") == "scan_completed"
            and datetime.fromisoformat(m["timestamp"].replace("Z", "+00:00")) >= cutoff
        ]
        failures = [m for m in recent_runs if m.get("returncode", 0) != 0]
        if len(failures) > len(recent_runs) * 0.5 and len(recent_runs) > 3:
            return [{
                "type": "tool_failure_rate_anomaly",
                "failure_rate": round(len(failures) / len(recent_runs), 4),
                "total_runs": len(recent_runs),
                "failure_count": len(failures),
                "severity": "critical",
            }]
        return []

    def _baseline_findings_per_hour(self) -> float:
        finding_counts = [m.get("finding_count", 0) for m in self.history]
        return statistics.mean(finding_counts) if finding_counts else 0

    def _recent_findings(self, days: int) -> List[Dict]:
        cutoff = datetime.now(timezone.utc) - timedelta(days=days)
        return [
            m for m in self.history
            if m.get("event_type") == "finding"
            and datetime.fromisoformat(m["timestamp"].replace("Z", "+00:00")) >= cutoff
        ]

    def _prior_findings(self, days: int) -> List[Dict]:
        cutoff = datetime.now(timezone.utc) - timedelta(days=days * 2)
        recent_cutoff = datetime.now(timezone.utc) - timedelta(days=days)
        return [
            m for m in self.history
            if m.get("event_type") == "finding"
            and cutoff <= datetime.fromisoformat(m["timestamp"].replace("Z", "+00:00")) < recent_cutoff
        ]
```

**Anomaly alerting rules:**
- Finding rate spike > 3× baseline: Page on-call security engineer.
- Severity distribution shift > 10%: Alert triage team lead.
- Tool failure rate > 50% in 1 hour: Page automation owner immediately.

---

## 6. Impact Scoring for Automation Improvements

When evaluating proposed changes to the automation stack (new tool, tuned parameter, revised dedup logic), quantify the expected impact on the core KPIs before implementation.

```python
from dataclasses import dataclass
from typing import Dict, List
from datetime import datetime, timezone

@dataclass
class AutomationChange:
    change_id: str
    title: str
    description: str
    proposed_at: str
    author: str
    target_kpis: Dict[str, float]
    expected_impact: Dict[str, float]
    implementation_cost_hours: float
    risk_level: str  # "low" | "medium" | "high"

    @property
    def roi_score(self) -> float:
        total_benefit = sum(self.expected_impact.values())
        return total_benefit / (self.implementation_cost_hours or 1)

@dataclass
class AutomationChangeResult:
    change_id: str
    implemented_at: str
    actual_impact: Dict[str, float]
    roi_actual: float
    roi_estimated: float
    variance_pct: float
    lessons_learned: str = ""

class ImpactScorer:
    def __init__(self, baseline_kpis: Dict[str, float]):
        self.baseline_kpis = baseline_kpis

    def estimate_roi(self, change: AutomationChange) -> float:
        return change.roi_score

    def rank_changes(self, changes: List[AutomationChange]) -> List[AutomationChange]:
        return sorted(changes, key=lambda c: c.roi_score, reverse=True)

    def evaluate_result(self, result: AutomationChangeResult) -> Dict:
        variance = abs(result.roi_actual - result.roi_estimated) / (result.roi_estimated or 1)
        return {
            "change_id": result.change_id,
            "roi_actual": round(result.roi_actual, 4),
            "roi_estimated": round(result.roi_estimated, 4),
            "variance_pct": round(variance * 100, 2),
            "accuracy": "high" if variance < 0.2 else "medium" if variance < 0.5 else "low",
            "recommendation": "repeat_approach" if variance < 0.3 else "review_estimation_method",
        }
```

**Impact scoring template:**
```json
{
  "change_id": "auto-2024-1201-nuclei-tag-tuning",
  "title": "Nuclei template tag optimization to reduce false positives",
  "proposed_at": "2024-12-01",
  "author": "security-automation-team",
  "target_kpis": {
    "false_positive_rate": 0.18,
    "time_to_triage_hours": 48
  },
  "expected_impact": {
    "false_positive_rate_reduction": 0.08,
    "time_to_triage_reduction_hours": 12,
    "finding_rate_change": -0.05
  },
  "implementation_cost_hours": 8,
  "risk_level": "low",
  "roi_score": 2.375
}
```

**Change evaluation workflow:**
1. Define baseline KPI values for the 30 days preceding the change.
2. Implement the change in a canary pipeline (10% of traffic).
3. Run for 14 days; compare canary KPIs against baseline.
4. If impact is positive and within ±30% of estimate, roll out to 100%.
5. Document actual impact and variance in the change record.
6. Feed variance data back into the estimation model to improve future ROI predictions.

---

## 7. Metrics Dashboard Specification

A unified metrics dashboard is essential for operational visibility. Define the dashboard in Grafana, Datadog, or equivalent:

**Dashboard panels (top to bottom):**
1. **Scan Coverage Gauge**: Overall coverage % with trend line (7-day).
2. **Finding Rate Time Series**: Findings per day by severity (critical/high/medium/low/info).
3. **Funnel Snapshot**: Bar chart showing stage-to-stage conversion for the current cycle.
4. **Time-to-Triage Distribution**: Histogram with p50/p90/p99 annotated.
5. **Tool Latency Heatmap**: p50/p99 latency by tool and scan profile.
6. **Anomaly Alerts Table**: Active anomalies with severity, timestamp, and acknowledgment status.
7. **Remediation Velocity**: Mean days to remediate by severity (30-day rolling).
8. **False Positive Rate**: Per-tool FPR trend line with threshold line at 15%.
9. **Automation Change ROI**: Bar chart of implemented changes ranked by actual ROI.

**Dashboard refresh:**
- Real-time panels (anomaly alerts, active scans): 30-second refresh.
- Daily panels (coverage, finding rate): 5-minute refresh.
- Weekly panels (trends, ROI): 1-hour refresh.

---

## 8. Metrics Collection Pipeline

All metrics must flow through a standardized collection pipeline that ensures consistency, completeness, and immutability.

```python
from datetime import datetime, timezone
from typing import Dict, Any
import json
import hashlib

class MetricsCollector:
    def __init__(self, metrics_backend: str, api_key: str):
        self.backend = metrics_backend
        self.api_key = api_key
        self._buffer: List[Dict] = []
        self._buffer_max = 100

    def record(self, metric_name: str, value: float, tags: Dict[str, str] = None, timestamp: str = None):
        entry = {
            "metric": metric_name,
            "value": value,
            "timestamp": timestamp or datetime.now(timezone.utc).isoformat(),
            "tags": tags or {},
            "integrity_hash": None,
        }
        entry["integrity_hash"] = hashlib.sha256(
            json.dumps(entry, sort_keys=True, default=str).encode()
        ).hexdigest()[:16]
        self._buffer.append(entry)
        if len(self._buffer) >= self._buffer_max:
            self._flush()

    def _flush(self):
        # In production, send to metrics backend (Datadog, Prometheus, etc.)
        serialized = json.dumps(self._buffer, indent=2)
        print(f"Flushing {len(self._buffer)} metrics: {serialized[:200]}...")
        self._buffer = []

    def gauge(self, name: str, value: float, tags: Dict = None):
        self.record(name, value, tags)

    def counter(self, name: str, value: float = 1, tags: Dict = None):
        self.record(name, value, tags)

    def histogram(self, name: str, value: float, tags: Dict = None):
        self.record(name, value, tags)
```

**Collection rules:**
- Every metric record includes an integrity hash for tamper detection.
- Metrics are tagged with `scan_id`, `tool`, `profile`, and `environment` for drill-down.
- Buffer flush failures are retried with exponential backoff (max 3 retries).
- Metric schemas are versioned and documented in a metrics registry.

---

## 9. Summary

Automation metrics and analytics transform operational data into strategic insight. Define KPIs that reflect real operational goals (coverage, finding rate, time-to-triage), instrument the funnel to locate bottlenecks, apply trend and anomaly detection to surface problems before they become incidents, and score proposed improvements by estimated ROI to prioritize automation investment. Analytics is not a reporting layer — it is the feedback loop that makes the automation platform self-improving.
