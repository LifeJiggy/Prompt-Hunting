# Automation-Efficiency 25: Learning and Adaptation

## Overview

Static automation produces static results. Adaptive automation continuously improves scan profiles, payload selection, and resource allocation by analyzing past results, triage feedback, target characteristics, and team performance data. This document covers feedback loop design, learning from successful hunts, valid finding pattern mining, dynamic scan profile adaptation, fingerprint-driven payload selection, A/B testing, and performance regression detection.

---

## 1. Feedback Loop Architecture

Three-tier feedback model drives all adaptation:

```
TIER 1 — Triage Outcome     (valid / N/A / duplicate / not-exploitable)
TIER 2 — Scan Performance   (time, threads, coverage)
TIER 3 — Business Outcome  (bounty amount, program quality, time-to-find)
```

### Feedback life-cycle

```
Findings produced
       │
       ▼
Triage by researcher
   ├── Valid (paid)     → reinforce that path
   ├── N/A (false pos)  → suppress payload or adjust profile
   ├── Duplicate        → tune dedup logic
   └── Not exploitable  → update fingerprint accuracy
       │
       ▼
Aggregate per target, per tech stack, per vuln class
       │
       ▼
Update scan profile weights and payload selection rules
       │
       ▼
Next scan starts with improved configuration
```

### Triage Feedback Collector

```python
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict
import json

FEEDBACK_LOG = Path("./logs/triage-feedback.jsonl")

@dataclass
class TriageFeedback:
    finding_id: str
    outcome: str                      # valid | n_a | duplicate | not_exploitable
    bounty_amount: float | None
    program: str | None
    target: str
    vuln_class: str
    tool_chain: list[str]
    scan_profile_id: str
    timestamp: str
    researcher_notes: str | None = None

def record_triage(feedback: TriageFeedback):
    with open(FEEDBACK_LOG, "a") as f:
        f.write(json.dumps(asdict(feedback)) + "\n")
    update_adaptive_weights(feedback)
    update_payload_stats(feedback)
```

### Weight Update Logic

```python
ADAPTIVE_WEIGHTS = Path("./stats/adaptive-weights.json")

def load_weights() -> dict:
    if ADAPTIVE_WEIGHTS.exists():
        return json.loads(ADAPTIVE_WEIGHTS.read_text())
    return {}

def update_adaptive_weights(feedback: TriageFeedback):
    weights = load_weights()
    key = f"{feedback.target}::{feedback.vuln_class}::{feedback.scan_profile_id}"
    if key not in weights:
        weights[key] = {"successes": 0, "failures": 0, "bounty_total": 0}
    if feedback.outcome == "valid":
        weights[key]["successes"] += 1
        weights[key]["bounty_total"] += feedback.bounty_amount or 0
    else:
        weights[key]["failures"] += 1
    ADAPTIVE_WEIGHTS.write_text(json.dumps(weights, indent=2))
```

---

## 2. Learning from Successful Hunts

### Success Signal Schema

```python
@dataclass
class SuccessSignal:
    finding_id: str
    bounty: float
    program: str
    vuln_class: str
    stack_layers: list[str]
    waf: str | None
    recon_techniques: list[str]
    time_to_find_minutes: int
```

Load last 90 days of valid findings:

```python
def extract_signals(tail_days: int = 90) -> list[SuccessSignal]:
    cutoff = datetime.utcnow() - timedelta(days=tail_days)
    signals = []
    for line in FEEDBACK_LOG.read_text().splitlines():
        entry = json.loads(line)
        if entry["outcome"] != "valid":
            continue
        ts = datetime.fromisoformat(entry["timestamp"])
        if ts < cutoff:
            continue
        signals.append(SuccessSignal(
            finding_id=entry["finding_id"],
            bounty=entry.get("bounty_amount", 0),
            program=entry["program"],
            vuln_class=entry["vuln_class"],
            stack_layers=entry.get("stack_layers", []),
            waf=entry.get("waf"),
            recon_techniques=entry.get("tool_chain", []),
            time_to_find_minutes=entry.get("time_to_find_minutes", 0),
        ))
    return signals
```

### Efficiency Score Per Technique

```python
import pandas as pd
import numpy as np

def technique_ranking(signals: list[SuccessSignal]) -> pd.DataFrame:
    rows = []
    for sig in signals:
        for tech in sig.recon_techniques:
            rows.append({
                "technique": tech,
                "vuln_class": sig.vuln_class,
                "bounty": sig.bounty,
                "time_min": sig.time_to_find_minutes,
                "program": sig.program,
            })
    df = pd.DataFrame(rows)
    summary = df.groupby("technique").agg(
        uses=("technique", "count"),
        avg_bounty=("bounty", "mean"),
        median_time=("time_min", "median"),
        programs=("program", "nunique"),
    )
    summary["efficiency_score"] = (
        summary["avg_bounty"] * summary["uses"]
        / (summary["median_time"] + 1) * summary["programs"]
    )
    return summary.sort_values("efficiency_score", ascending=False)
```

Top techniques are promoted to `scan-profiles/winners/` automatically.

---

## 3. Pattern Mining from Valid Findings

### Embeddings + Clustering

Cluster findings textually to detect emerging pattern families.

```python
from sentence_transformers import SentenceTransformer
from sklearn.cluster import DBSCAN
from collections import defaultdict, Counter

model = SentenceTransformer("all-MiniLM-L6-v2")

def mine_patterns(min_findings: int = 10) -> list[dict]:
    findings = load_open_and_submitted()
    if len(findings) < min_findings:
        return []
    texts = [f"{f['title']} {f.get('description', '')} {','.join(f.get('auto_tags', {}).get('class', []))}"
             for f in findings]
    embeddings = model.encode(texts)
    labels = DBSCAN(eps=0.4, min_samples=3, metric="cosine").fit(embeddings).labels_
    clusters = defaultdict(list)
    for idx, label in enumerate(labels):
        if label == -1:
            continue
        clusters[label].append(findings[idx])
    pattern_report = []
    for label, group in clusters.items():
        classes = Counter(f["vuln_class"] for f in group)
        avg_bounty = float(np.mean([f.get("bounty_amount", 0) for f in group]))
        pattern_report.append({
            "cluster": label,
            "size": len(group),
            "top_classes": classes.most_common(),
            "avg_bounty": round(avg_bounty, 2),
            "sample_titles": [f["title"] for f in group[:3]],
        })
    return sorted(pattern_report, key=lambda x: -x["avg_bounty"] * x["size"])
```

### Profile Generator from Patterns

```python
def generate_scan_profile(pattern: dict) -> dict:
    profile = {
        "profile_id": f"learned-{pattern['cluster']}",
        "source": "pattern_mining",
        "description": f"Generated from {pattern['size']} findings, avg ${pattern['avg_bounty']}",
        "priority": 5,
        "threads": 15,
        "payload_focus": [],
        "tools": {},
    }
    for cls, count in pattern["top_classes"]:
        profile["payload_focus"].append(cls)
        if profile["tools"].get("nuclei") is None:
            profile["tools"]["nuclei"] = {"tags": []}
        profile["tools"]["nuclei"]["tags"].append(cls)
    return profile

# Save to auto-profiles dir for review before promotion
Path("configs/auto-profiles").mkdir(parents=True, exist_ok=True)
Path(f"configs/auto-profiles/learned-{pattern['cluster']}.toml").write_text(dict_to_toml(profile))
```

---

## 4. Adaptive Scan Profiles

### Profile Weighting System

Each vuln class has a weight. Reinforce weights on valid findings, decay on N/A.

```python
import json
from pathlib import Path

WEIGHTS_FILE = Path("./stats/scan-profile-weights.json")

def load_weights() -> dict:
    if WEIGHTS_FILE.exists():
        return json.loads(WEIGHTS_FILE.read_text())
    return {"xss": 1.0, "sqli": 1.0, "ssrf": 1.0, "idor": 1.0, "ssti": 1.2, "rce": 1.5}

def save_weights(w: dict): WEIGHTS_FILE.write_text(json.dumps(w, indent=2))

def reinforce(vuln_class: str, bounty: float, time_spent_seconds: float, learning_rate: float = 0.2):
    weights = load_weights()
    current = weights.get(vuln_class, 1.0)
    reward = bounty / max(time_spent_seconds, 1.0)
    delta = reward * learning_rate
    weights[vuln_class] = max(0.05, min(5.0, current + delta))
    save_weights(weights)
    log.info(f"Reinforced {vuln_class}: {current:.2f} → {weights[vuln_class]:.2f}")

# After a valid SSTI RCE ($5000, 180s): reinforce("ssti", 5000, 180)
# SSTI weight jumps significantly → future scans prioritize SSTI probes
```

### Resource Allocation from Weights

```python
def allocate_resources(weights: dict, total_threads: int, total_budget_minutes: int) -> dict:
    ranked = sorted(weights.items(), key=lambda x: -x[1])
    total_w = sum(w for _, w in ranked)
    allocation = {}
    remaining_t = total_threads
    remaining_m = total_budget_minutes
    for cls, w in ranked[:-1]:
        share = int(total_threads * (w / total_w))
        budget = int(total_budget_minutes * (w / total_w))
        allocation[cls] = {"threads": share, "budget_minutes": budget}
        remaining_t -= share
        remaining_m -= budget
    # Remainder → highest-weighted class
    top_cls = ranked[0][0]
    allocation[top_cls]["threads"] += remaining_t
    allocation[top_cls]["budget_minutes"] += remaining_m
    return allocation

# With 50 threads, 60 min, and weights ssti=3.0, xss=1.0, etc:
# → ssti gets ~18 threads, xss/sqli/ssrf/idor share the rest
```

---

## 5. Dynamic Payload Selection

Payload files organized by tech stack with a `priority.txt` ordering.

```
payloads/
├── php/priority.txt
├── lfi/basic.txt, lfi/filters/waf-bypass.txt
├── sqli/time-based.txt
└── waf-bypass/cloudflare.txt
```

`payloads/php/priority.txt` (ordered by success rate, metadata at top):
```
severity=high
category=ssti
tech=php
notes=2024-2025 data, ordered by exploit success rate

{{7*7}}
{{_self.env.registerUndefinedFilterCallback('system')}}{{7*7}}
{{['id']}}
{{_self.env}}
{% for c in [].__class__.__base__.__subclasses__() %}{% if c.__name__ == 'catch_warnings' %}{% for b in c.__init__.__globals__.values() %}{% if b.__class__ == {}.__class__ %}{% if 'eval' in b.keys() %}{{ b['eval']('id') }}{% endif %}{% endif %}{% endfor %}{% endif %}{% endfor %}
```

Dynamic selector:
```python
class DynamicPayloadSelector:
    def __init__(self, fp_db: FingerprintDB, lives: list):
        self.fp_db = fp_db
        self.lives = lives

    def for_endpoint(self, url: str, param: str) -> list[str]:
        tech = ""
        for live in self.lives:
            if live.url == url:
                matches = self.fp_db.match_headers(dict(live.headers))
                if matches:
                    tech = matches[0]["tech"]
                break
        base = Path(f"payloads/{tech}/priority.txt") if tech else Path("payloads/generic/all.txt")
        if not base.exists():
            return []
        selected = base.read_text().splitlines()
        waf = [fp for fp in matches if fp.get("waf")] if matches else []
        for fp in waf:
            waf_file = Path(f"payloads/waf-bypass/{fp.get('tech', 'generic')}.txt")
            if waf_file.exists():
                selected.extend(waf_file.read_text().splitlines())
        return list(dict.fromkeys(selected))
```

---

## 6. A/B Testing Automation

Compare two scan profiles head-to-head; promote the winner.

```python
from dataclasses import dataclass
from scipy import stats

@dataclass
class ABTest:
    test_id: str
    arm_a: str          # profile name
    arm_b: str          # profile name
    metric: str         # valid_findings_per_hour | bounty_per_dollar | fp_rate
    min_sample: int = 30

class ABRunner:
    def __init__(self):
        self.data: dict[str, list[float]] = {}

    def record(self, test_id: str, arm: str, value: float):
        key = f"{test_id}:{arm}"
        self.data.setdefault(key, []).append(value)
        result = self._check(test_id)
        if result:
            self._promote(test_id, result)

    def _check(self, test_id: str) -> str | None:
        a = self.data.get(f"{test_id}:a", [])
        b = self.data.get(f"{test_id}:b", [])
        if len(a) < 30 or len(b) < 30:
            return None
        _, p_value = stats.ttest_ind(a, b)
        if p_value < 0.05:
            return "a" if sum(a)/len(a) > sum(b)/len(b) else "b"
        return None

    def _promote(self, test_id: str, winner: str):
        arm = self.arm_a if winner == "a" else self.arm_b
        save_as_default(arm)
        log.info(f"[AB] Promoted {arm} to default (test: {test_id})")
```

### Canary Deployment

```python
import random

def canary_deploy(profile_new: str, profile_control: str, team: list[str], fraction: float = 0.1):
    n = max(1, int(len(team) * fraction))
    canary = set(random.sample(team, n))
    assignments = {m: (profile_new if m in canary else profile_control) for m in team}
    log.info(f"Canary: {profile_new} → {sorted(canary)}")
    return assignments

def evaluate_canary(profile_new: str, profile_control: str) -> bool:
    new_valid   = sum_valid_findings(profile_new)
    control_valid = sum_valid_findings(profile_control)
    if new_valid > control_valid * 1.1:
        log.info(f"Canary won: {profile_new} (new={new_valid}, ctrl={control_valid})")
        return True
    log.info(f"Canary lost: {profile_new}")
    return False
```

---

## 7. Performance Regression Learning

### KPI Regression Detector

Track six core KPIs; alert when any drops ≥20% from 7-day baseline.

```python
from dataclasses import dataclass
from datetime import datetime

KPIS = [
    "findings_per_hour", "valid_finding_rate",
    "avg_bounty_per_finding", "scan_duration_per_target",
    "false_positive_rate", "tool_coverage_score",
]
REG_THRESHOLD = 0.20

@dataclass
class MetricSnapshot:
    date: str; metric: str; value: float; baseline: float | None = None

class RegressionTracker:
    def __init__(self):
        self.history: dict[str, list[MetricSnapshot]] = {}
        self.baselines: dict[str, float] = {}

    def snapshot(self, date: str, metrics: dict):
        for metric, value in metrics.items():
            self.history.setdefault(metric, []).append(MetricSnapshot(date, metric, value, self.baselines.get(metric)))
        self._detect()

    def set_baseline(self, metric: str, value: float):
        self.baselines[metric] = value
        for snap in self.history.get(metric, []):
            snap.baseline = value

    def _detect(self) -> list[dict]:
        regressions = []
        for metric, snaps in self.history.items():
            if len(snaps) < 3:
                continue
            recent_min = min(s.value for s in snaps[-3:])
            bl = self.baselines.get(metric, recent_min)
            if bl == 0:
                continue
            drop = (bl - recent_min) / bl
            if drop >= REG_THRESHOLD:
                regressions.append({"metric": metric, "baseline": bl, "recent_min": recent_min, "drop_pct": round(drop*100, 1)})
        return regressions
```

### Root Cause Correlation

```python
def correlate_regression(regression: dict) -> list[str]:
    suspects = []
    d = regression["date"]
    for tool, info in current_versions.items():
        if info["updated_at"] > (datetime.utcnow() - timedelta(days=7)).isoformat():
            suspects.append(f"Tool {tool} upgraded to {info['version']}")
    suspects += recent_git_changes("configs/", since=d)
    suspects += recent_git_changes("payloads/", since=d)
    return suspects
```

Alert with suspects:

```python
regressions = tracker._detect()
for r in regressions:
    suspects = correlate_regression(r)
    send_alert(f"[REGRESSION] {r['metric']} dropped {r['drop_pct']}% — suspects: {suspects}")
```

---

## 8. Integration Points

| Adaptive Component | Reads From | Writes To | Integration |
|---------------------|-----------|-----------|--------------|
| Feedback collector | `results/processed/` | `stats/adaptive-weights.json` | Triggers profile re-weight |
| Pattern miner | `results/processed/` | `configs/auto-profiles/` | New profiles after 20+ findings |
| Dynamic payload selector | `fingerprints/`, `payloads/` | Scan runtime args | Tool chaining (file 21) |
| AB runner | Triage outcomes | `configs/scan-profiles/winners/` | Promoted profile loaded by config layer |
| Regression tracker | `logs/scan-runtime.jsonl` | Alert channel | Alerts team leads; triggers rollback |

---

## 9. Checklist

- [ ] Triage schema defined in `docs/schemas/triage-feedback.json`
- [ ] `record_triage()` wired into triage CLI / UI
- [ ] Adaptive weights in `stats/scan-profile-weights.json` updated per valid finding
- [ ] `technique_ranking()` runs nightly; top 5 techniques logged to `reports/technique-rank.md`
- [ ] Pattern miner runs weekly when finding count ≥ 20
- [ ] Generated profiles in `configs/auto-profiles/` require human approval before promotion
- [ ] AB test: minimum 30 samples enforced before declaring winner
- [ ] Canary: 10% of team on new profile for 2-week windows
- [ ] Regression tracker monitors all 6 KPIs daily with 20% drop threshold
- [ ] Alerts include auto-generated suspect list (tool upgrades, config changes, payload changes)
- [ ] Integration table maintained; each adaptive component linked to at least one other spec
- [ ] All stats files in `.gitignore`; schema templates in `docs/schemas/` tracked in git
