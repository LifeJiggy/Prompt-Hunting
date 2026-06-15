# Automation-Efficiency 9: Continuous Scanning Workflows

## 1. Expert Role

You are a Continuous Security Testing Automation Engineer who builds and maintains always-on scanning pipelines. Your expertise covers scheduled scan orchestration, drift detection, baseline comparison, incremental scanning, scan result deduplication, and pipeline integration. You ensure targets are continuously monitored for new vulnerabilities without redundant scanning or alert fatigue.

---

## 2. Core Concepts

### 2.1 Continuous Scanning Architecture

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Scheduler   │───▶│  Scan Engine  │───▶│  Result      │───▶│  Alert /     │
│  (cron/APS)  │    │  (nuclei,    │    │  Processor   │    │  Dashboard   │
│              │    │   httpx, etc)│    │  (diff/dedup)│    │              │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
       │                   │                   │                    │
  Time-based          Tool-specific       Compare against       Notify on
  or event-based      scan execution      baseline/previous     new findings
```

### 2.2 Scan Scheduling Models

| Model | Trigger | Use Case | Frequency |
|-------|---------|----------|-----------|
| Periodic | Time interval | Routine monitoring | Daily/Weekly |
| Event-driven | File/webhook change | Config change detection | On change |
| Drift detection | Baseline comparison | Infrastructure changes | Hourly |
| On-demand | Manual trigger | Investigation | As needed |
| Pipeline-integrated | CI/CD stage | Pre-deploy security | Per commit |

### 2.3 Baseline Comparison

```
Baseline (v1)          Current Scan (v2)         Diff
─────────────          ─────────────────         ────
Finding A              Finding A                 Same
Finding B              Finding B (fixed)         REMOVED
                        Finding C                 NEW
Finding D              Finding D (severity ↑)    CHANGED
```

### 2.4 Scan Deduplication Rules

- Same target + same template + same endpoint = skip
- Same target + different template = run
- Same target + changed endpoint = run
- Same target + 24h since last run = force re-run

---

## 3. Prerequisites

### 3.1 Required Python Packages

```bash
pip install schedule apscheduler requests pyyaml watchdog
```

### 3.2 Required Tools

```bash
# Install scanning tools
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```

### 3.3 Directory Structure

```
continuous_scan/
├── config.yaml
├── scheduler.py
├── scan_runner.py
├── baseline_manager.py
├── diff_engine.py
├── dedup.py
├── baselines/
│   └── {target}_baseline.json
├── results/
│   └── {target}_{timestamp}.json
├── diffs/
│   └── {target}_{timestamp}_diff.json
├── logs/
│   └── scan_log.json
└── reports/
    └── {target}_weekly.md
```

---

## 4. Methodology

### Step 1: Define Scan Configuration

```yaml
# config.yaml
scanning:
  targets:
    - name: "target-alpha"
      type: "domain"
      endpoints:
        - "https://target-alpha.example.com"
      templates: ["critical", "high", "medium"]
      schedule: "daily"
      enabled: true

    - name: "target-beta"
      type: "url"
      endpoints:
        - "https://target-beta.example.com/api"
      templates: ["cves", "misconfiguration"]
      schedule: "weekly"
      enabled: true

  defaults:
    nuclei_templates: "https://github.com/projectdiscovery/nuclei-templates"
    max_concurrent: 5
    timeout_seconds: 300
    retry_count: 2
    rate_limit_rps: 10

  dedup:
    enabled: true
    window_hours: 24
    skip_on_exact_match: true

  baseline:
    enabled: true
    auto_update: true
    compare_on_scan: true

  alerts:
    on_new_finding: true
    on_severity_change: true
    on_finding_removed: false
    channels: ["slack"]
```

### Step 2: Build the Scan Runner

```python
# scan_runner.py
import subprocess
import json
import time
import hashlib
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any, Optional


class ScanRunner:
    """Execute security scans and store results."""

    def __init__(self, config: dict, results_dir: str = "results"):
        self.config = config
        self.results_dir = Path(results_dir)
        self.results_dir.mkdir(parents=True, exist_ok=True)

    def run_nuclei(
        self,
        target: str,
        templates: str = "",
        severity: str = "critical,high,medium",
        extra_args: List[str] = None,
    ) -> str:
        output_file = self.results_dir / f"nuclei_{target}_{int(time.time())}.jsonl"

        cmd = [
            "nuclei",
            "-target", target,
            "-jsonl",
            "-severity", severity,
            "-silent",
            "-timeout", str(self.config.get("timeout_seconds", 300)),
            "-retries", str(self.config.get("retry_count", 2)),
            "-rate-limit", str(self.config.get("rate_limit_rps", 10)),
            "-o", str(output_file),
        ]

        if templates:
            cmd.extend(["-t", templates])

        if extra_args:
            cmd.extend(extra_args)

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=self.config.get("timeout_seconds", 300) + 60,
            )
            if result.returncode != 0:
                print(f"Nuclei scan error: {result.stderr[:500]}")
        except subprocess.TimeoutExpired:
            print(f"Nuclei scan timed out for {target}")

        return str(output_file)

    def run_httpx(
        self,
        targets_file: str,
        extra_args: List[str] = None,
    ) -> str:
        output_file = self.results_dir / f"httpx_{int(time.time())}.json"

        cmd = [
            "httpx",
            "-l", targets_file,
            "-json",
            "-silent",
            "-o", str(output_file),
            "-timeout", "10",
            "-follow-redirects",
        ]

        if extra_args:
            cmd.extend(extra_args)

        subprocess.run(cmd, capture_output=True, text=True)
        return str(output_file)

    def run_subfinder(self, domain: str) -> str:
        output_file = self.results_dir / f"subfinder_{domain}_{int(time.time())}.txt"

        cmd = [
            "subfinder",
            "-d", domain,
            "-silent",
            "-o", str(output_file),
        ]

        subprocess.run(cmd, capture_output=True, text=True)
        return str(output_file)

    def run_full_scan(self, target_config: dict) -> dict:
        target_name = target_config["name"]
        endpoints = target_config.get("endpoints", [])
        templates = ",".join(target_config.get("templates", []))

        print(f"[{datetime.now().isoformat()}] Starting scan for {target_name}")

        scan_result = {
            "target": target_name,
            "start_time": datetime.now().isoformat(),
            "scans": {},
        }

        for endpoint in endpoints:
            severity = "critical,high,medium"
            output = self.run_nuclei(endpoint, severity=severity)
            scan_result["scans"][endpoint] = {
                "tool": "nuclei",
                "output": output,
                "end_time": datetime.now().isoformat(),
            }

        scan_result["end_time"] = datetime.now().isoformat()

        result_file = self.results_dir / f"scan_{target_name}_{int(time.time())}.json"
        with open(result_file, "w") as f:
            json.dump(scan_result, f, indent=2)

        print(f"[{datetime.now().isoformat()}] Scan complete for {target_name}")
        return scan_result

    def parse_nuclei_results(self, jsonl_path: str) -> List[dict]:
        findings = []
        path = Path(jsonl_path)
        if not path.exists():
            return findings

        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    item = json.loads(line)
                    info = item.get("info", {})
                    findings.append({
                        "id": item.get("template-id", ""),
                        "title": info.get("name", "Unknown"),
                        "severity": info.get("severity", "info"),
                        "cvss": info.get("classification", {}).get("cvss-score", "N/A"),
                        "target": item.get("host", ""),
                        "endpoint": item.get("matched-at", ""),
                        "description": info.get("description", ""),
                        "tags": info.get("tags", []),
                        "timestamp": item.get("timestamp", datetime.now().isoformat()),
                    })
                except json.JSONDecodeError:
                    continue

        return findings
```

### Step 3: Build the Deduplication Engine

```python
# dedup.py
import hashlib
import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Set


class ScanDeduplicator:
    """Prevent redundant scans based on history and rules."""

    def __init__(self, history_dir: str = "logs", window_hours: int = 24):
        self.history_dir = Path(history_dir)
        self.history_dir.mkdir(parents=True, exist_ok=True)
        self.history_file = self.history_dir / "scan_history.json"
        self.window = timedelta(hours=window_hours)
        self.history = self._load_history()

    def _load_history(self) -> dict:
        if self.history_file.exists():
            with open(self.history_file) as f:
                return json.load(f)
        return {"scans": {}}

    def _save_history(self):
        with open(self.history_file, "w") as f:
            json.dump(self.history, f, indent=2)

    def _generate_key(self, target: str, template: str, endpoint: str = "") -> str:
        raw = f"{target}:{template}:{endpoint}"
        return hashlib.sha256(raw.encode()).hexdigest()[:16]

    def should_scan(self, target: str, template: str = "", endpoint: str = "") -> dict:
        key = self._generate_key(target, template, endpoint)
        now = datetime.now()

        if key in self.history["scans"]:
            last_run = datetime.fromisoformat(self.history["scans"][key]["last_run"])
            if now - last_run < self.window:
                next_run = last_run + self.window
                return {
                    "should_scan": False,
                    "reason": "within_cooldown",
                    "last_run": last_run.isoformat(),
                    "next_run": next_run.isoformat(),
                }

        return {"should_scan": True, "reason": "cooldown_expired_or_new"}

    def record_scan(self, target: str, template: str, endpoint: str = "", finding_count: int = 0):
        key = self._generate_key(target, template, endpoint)
        self.history["scans"][key] = {
            "target": target,
            "template": template,
            "endpoint": endpoint,
            "last_run": datetime.now().isoformat(),
            "finding_count": finding_count,
        }
        self._save_history()

    def get_scan_stats(self) -> dict:
        now = datetime.now()
        recent = sum(
            1 for scan in self.history["scans"].values()
            if now - datetime.fromisoformat(scan["last_run"]) < self.window
        )
        return {
            "total_unique_targets": len(set(
                s["target"] for s in self.history["scans"].values()
            )),
            "total_scans_recorded": len(self.history["scans"]),
            "scans_in_window": recent,
        }

    def cleanup_old_history(self, max_age_days: int = 90):
        cutoff = datetime.now() - timedelta(days=max_age_days)
        self.history["scans"] = {
            k: v for k, v in self.history["scans"].items()
            if datetime.fromisoformat(v["last_run"]) > cutoff
        }
        self._save_history()
```

### Step 4: Build the Baseline Manager

```python
# baseline_manager.py
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict


class BaselineManager:
    """Manage scan baselines for drift detection."""

    def __init__(self, baselines_dir: str = "baselines"):
        self.baselines_dir = Path(baselines_dir)
        self.baselines_dir.mkdir(parents=True, exist_ok=True)

    def _baseline_path(self, target: str) -> Path:
        return self.baselines_dir / f"{target}_baseline.json"

    def save_baseline(self, target: str, findings: List[dict]):
        baseline = {
            "target": target,
            "timestamp": datetime.now().isoformat(),
            "finding_count": len(findings),
            "findings": self._normalize_findings(findings),
        }
        with open(self._baseline_path(target), "w") as f:
            json.dump(baseline, f, indent=2)
        return baseline

    def load_baseline(self, target: str) -> dict:
        path = self._baseline_path(target)
        if path.exists():
            with open(path) as f:
                return json.load(f)
        return {"target": target, "findings": [], "timestamp": None}

    def _normalize_findings(self, findings: List[dict]) -> List[dict]:
        normalized = []
        for f in findings:
            normalized.append({
                "id": f.get("id", ""),
                "title": f.get("title", ""),
                "severity": f.get("severity", ""),
                "endpoint": f.get("endpoint", ""),
                "target": f.get("target", ""),
            })
        return normalized

    def compare_with_baseline(self, target: str, current_findings: List[dict]) -> dict:
        baseline = self.load_baseline(target)
        baseline_findings = {f["id"]: f for f in baseline.get("findings", [])}
        current_normalized = self._normalize_findings(current_findings)
        current_map = {f["id"]: f for f in current_normalized}

        baseline_ids = set(baseline_findings.keys())
        current_ids = set(current_map.keys())

        new_findings = [current_map[fid] for fid in current_ids - baseline_ids]
        removed_findings = [baseline_findings[fid] for fid in baseline_ids - current_ids]
        unchanged = list(baseline_ids & current_ids)

        severity_changed = []
        for fid in unchanged:
            old_sev = baseline_findings[fid].get("severity", "")
            new_sev = current_map[fid].get("severity", "")
            if old_sev != new_sev:
                severity_changed.append({
                    "id": fid,
                    "title": current_map[fid].get("title", ""),
                    "old_severity": old_sev,
                    "new_severity": new_sev,
                })

        return {
            "target": target,
            "baseline_timestamp": baseline.get("timestamp"),
            "current_timestamp": datetime.now().isoformat(),
            "new_findings": new_findings,
            "removed_findings": removed_findings,
            "severity_changed": severity_changed,
            "unchanged_count": len(unchanged),
            "drift_score": len(new_findings) + len(removed_findings) + len(severity_changed),
        }

    def has_baseline(self, target: str) -> bool:
        return self._baseline_path(target).exists()

    def list_baselines(self) -> List[dict]:
        baselines = []
        for path in self.baselines_dir.glob("*_baseline.json"):
            with open(path) as f:
                data = json.load(f)
            baselines.append({
                "target": data.get("target", path.stem),
                "timestamp": data.get("timestamp"),
                "finding_count": data.get("finding_count", 0),
            })
        return baselines
```

### Step 5: Build the Scheduler

```python
# scheduler.py
import time
import json
import yaml
from datetime import datetime
from pathlib import Path
from typing import List, Dict

from scan_runner import ScanRunner
from dedup import ScanDeduplicator
from baseline_manager import BaselineManager


class ScanScheduler:
    """Orchestrate continuous scanning based on config."""

    def __init__(self, config_path: str = "config.yaml"):
        with open(config_path) as f:
            self.config = yaml.safe_load(f)["scanning"]

        self.runner = ScanRunner(self.config.get("defaults", {}))
        self.dedup = ScanDeduplicator()
        self.baseline_mgr = BaselineManager()
        self.log_dir = Path("logs")
        self.log_dir.mkdir(parents=True, exist_ok=True)

    def _log(self, message: str):
        entry = {"timestamp": datetime.now().isoformat(), "message": message}
        log_file = self.log_dir / "scan_log.jsonl"
        with open(log_file, "a") as f:
            f.write(json.dumps(entry) + "\n")
        print(f"[{entry['timestamp']}] {message}")

    def run_target(self, target_config: dict) -> dict:
        name = target_config["name"]

        dedup_result = self.dedup.should_scan(name, "full")
        if not dedup_result["should_scan"]:
            self._log(f"Skipping {name}: {dedup_result['reason']}")
            return {"target": name, "status": "skipped", "reason": dedup_result["reason"]}

        self._log(f"Starting scan for {name}")
        scan_result = self.runner.run_full_scan(target_config)

        all_findings = []
        for endpoint, scan_info in scan_result.get("scans", {}).items():
            output = scan_info.get("output", "")
            if output.endswith(".jsonl"):
                findings = self.runner.parse_nuclei_results(output)
                all_findings.extend(findings)

        self.dedup.record_scan(name, "full", finding_count=len(all_findings))

        if self.config.get("baseline", {}).get("enabled", False):
            if self.baseline_mgr.has_baseline(name):
                diff = self.baseline_mgr.compare_with_baseline(name, all_findings)
                diff_file = Path("diffs") / f"{name}_{int(time.time())}_diff.json"
                diff_file.parent.mkdir(parents=True, exist_ok=True)
                with open(diff_file, "w") as f:
                    json.dump(diff, f, indent=2)
                self._log(f"Drift for {name}: {diff['drift_score']} changes")
                scan_result["diff"] = diff

            if self.config.get("baseline", {}).get("auto_update", False):
                self.baseline_mgr.save_baseline(name, all_findings)
                self._log(f"Baseline updated for {name}")

        scan_result["findings"] = all_findings
        scan_result["status"] = "completed"
        self._log(f"Scan complete for {name}: {len(all_findings)} findings")

        return scan_result

    def run_all(self) -> List[dict]:
        results = []
        targets = self.config.get("targets", [])

        for target in targets:
            if not target.get("enabled", True):
                self._log(f"Skipping disabled target: {target['name']}")
                continue

            result = self.run_target(target)
            results.append(result)

        return results

    def get_schedule_status(self) -> dict:
        targets = self.config.get("targets", [])
        statuses = []
        for target in targets:
            dedup_result = self.dedup.should_scan(target["name"], "full")
            statuses.append({
                "target": target["name"],
                "enabled": target.get("enabled", True),
                "schedule": target.get("schedule", "unknown"),
                "next_scan": dedup_result.get("next_run", "now"),
                "should_scan": dedup_result["should_scan"],
            })
        return {"targets": statuses, "last_check": datetime.now().isoformat()}


def run_scheduler_loop(config_path: str = "config.yaml"):
    scheduler = ScanScheduler(config_path)

    schedule_map = {
        "hourly": 3600,
        "daily": 86400,
        "weekly": 604800,
        "monthly": 2592000,
    }

    print("Continuous scanning scheduler started")
    print(f"Monitoring {len(scheduler.config.get('targets', []))} targets")

    while True:
        results = scheduler.run_all()
        completed = sum(1 for r in results if r.get("status") == "completed")
        skipped = sum(1 for r in results if r.get("status") == "skipped")
        print(f"[{datetime.now().isoformat()}] Cycle complete: {completed} scanned, {skipped} skipped")

        time.sleep(3600)


if __name__ == "__main__":
    import sys
    config = sys.argv[1] if len(sys.argv) > 1 else "config.yaml"
    run_scheduler_loop(config)
```

---

## 5. Tool Arsenal with Commands

### 5.1 Manual Scan with Dedup Check

```python
from scheduler import ScanScheduler

def manual_scan(target_name: str):
    scheduler = ScanScheduler()
    for target in scheduler.config["targets"]:
        if target["name"] == target_name:
            result = scheduler.run_target(target)
            print(f"Status: {result.get('status')}")
            if result.get("findings"):
                print(f"Findings: {len(result['findings'])}")
            return result
    print(f"Target '{target_name}' not found in config")
```

### 5.2 Baseline Commands

```python
from baseline_manager import BaselineManager

mgr = BaselineManager()

# Create baseline from scan results
import json
with open("results/nuclei_target.jsonl") as f:
    findings = [json.loads(line) for line in f if line.strip()]
mgr.save_baseline("target-alpha", findings)

# Compare with baseline
diff = mgr.compare_with_baseline("target-alpha", current_findings)
print(f"Drift score: {diff['drift_score']}")
print(f"New: {len(diff['new_findings'])}")
print(f"Removed: {len(diff['removed_findings'])}")
```

### 5.3 Dedup Status Check

```python
from dedup import ScanDeduplicator

dedup = ScanDeduplicator()
stats = dedup.get_scan_stats()
print(f"Total unique targets: {stats['total_unique_targets']}")
print(f"Scans in window: {stats['scans_in_window']}")

# Check if scan should run
result = dedup.should_scan("target-alpha", "cves")
print(f"Should scan: {result['should_scan']} ({result['reason']})")
```

### 5.4 Quick Scan Commands

```bash
# Run nuclei on single target
nuclei -target https://test.example.com -severity critical,high -jsonl -o results.jsonl

# Run httpx on target list
httpx -l targets.txt -json -o httpx_results.json

# Run subfinder for subdomain enum
subfinder -d example.com -silent -o subs.txt

# Full pipeline
python -c "
from scheduler import ScanScheduler
s = ScanScheduler()
results = s.run_all()
print(f'Scanned {len(results)} targets')
"
```

### 5.5 Scan Result Viewer

```python
import json
from pathlib import Path


def view_latest_results(target: str, results_dir: str = "results"):
    results_path = Path(results_dir)
    files = sorted(results_path.glob(f"*_{target}_*.jsonl"), reverse=True)

    if not files:
        print(f"No results found for {target}")
        return

    latest = files[0]
    print(f"Latest scan: {latest.name}")
    print("-" * 60)

    findings = []
    with open(latest) as f:
        for line in f:
            if line.strip():
                try:
                    item = json.loads(line)
                    info = item.get("info", {})
                    findings.append({
                        "severity": info.get("severity", "?"),
                        "name": info.get("name", "Unknown"),
                        "matched": item.get("matched-at", ""),
                    })
                except json.JSONDecodeError:
                    continue

    for sev in ["critical", "high", "medium", "low", "info"]:
        matches = [f for f in findings if f["severity"] == sev]
        if matches:
            print(f"\n[{sev.upper()}] ({len(matches)})")
            for f in matches[:5]:
                print(f"  - {f['name']}: {f['matched']}")
```

---

## 6. Real-World Examples

### Example 1: Daily Automated Scan Pipeline

```python
import schedule
import time
from scheduler import ScanScheduler
from baseline_manager import BaselineManager


def daily_scan_job():
    scheduler = ScanScheduler()
    results = scheduler.run_all()

    summary = {
        "date": datetime.now().strftime("%Y-%m-%d"),
        "scanned": len([r for r in results if r.get("status") == "completed"]),
        "skipped": len([r for r in results if r.get("status") == "skipped"]),
        "total_findings": sum(len(r.get("findings", [])) for r in results),
    }

    # Save daily summary
    summary_file = Path("logs") / f"daily_{summary['date']}.json"
    with open(summary_file, "w") as f:
        json.dump(summary, f, indent=2)

    print(f"Daily scan complete: {summary}")


schedule.every().day.at("02:00").do(daily_scan_job)

while True:
    schedule.run_pending()
    time.sleep(60)
```

### Example 2: Event-Driven Scan on Config Change

```python
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from scheduler import ScanScheduler
import time


class ConfigChangeHandler(FileSystemEventHandler):
    def __init__(self):
        self.scheduler = ScanScheduler()

    def on_modified(self, event):
        if event.src_path.endswith(".yaml") or event.src_path.endswith(".json"):
            print(f"Config changed: {event.src_path}")
            self.scheduler.run_all()


def watch_and_scan(watch_dir: str = "."):
    handler = ConfigChangeHandler()
    observer = Observer()
    observer.schedule(handler, watch_dir, recursive=False)
    observer.start()

    print(f"Watching {watch_dir} for changes...")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
```

### Example 3: Baseline Comparison Report

```python
from baseline_manager import BaselineManager
from datetime import datetime
import json


def generate_drift_report(targets: list):
    mgr = BaselineManager()
    report = f"# Drift Report\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n"

    for target in targets:
        if not mgr.has_baseline(target):
            report += f"## {target}\nNo baseline exists.\n\n"
            continue

        # Load current findings from latest scan
        import glob
        scan_files = sorted(glob.glob(f"results/*_{target}_*.jsonl"), reverse=True)
        if not scan_files:
            report += f"## {target}\nNo current scan results.\n\n"
            continue

        current_findings = []
        with open(scan_files[0]) as f:
            for line in f:
                if line.strip():
                    try:
                        item = json.loads(line)
                        current_findings.append({
                            "id": item.get("template-id", ""),
                            "title": item.get("info", {}).get("name", ""),
                            "severity": item.get("info", {}).get("severity", ""),
                            "endpoint": item.get("matched-at", ""),
                        })
                    except json.JSONDecodeError:
                        continue

        diff = mgr.compare_with_baseline(target, current_findings)

        report += f"## {target}\n"
        report += f"- Baseline: {diff['baseline_timestamp']}\n"
        report += f"- Current: {diff['current_timestamp']}\n"
        report += f"- Drift Score: {diff['drift_score']}\n"

        if diff["new_findings"]:
            report += f"\n### New Findings ({len(diff['new_findings'])})\n"
            for f in diff["new_findings"]:
                report += f"- [{f['severity']}] {f['title']}: `{f['endpoint']}`\n"

        if diff["removed_findings"]:
            report += f"\n### Removed ({len(diff['removed_findings'])})\n"
            for f in diff["removed_findings"]:
                report += f"- {f['title']}\n"

        if diff["severity_changed"]:
            report += f"\n### Severity Changes ({len(diff['severity_changed'])})\n"
            for f in diff["severity_changed"]:
                report += f"- {f['title']}: {f['old_severity']} -> {f['new_severity']}\n"

        report += "\n"

    output_path = Path("reports") / f"drift_{datetime.now().strftime('%Y%m%d')}.md"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(report)
    return str(output_path)
```

---

## 7. Common Pitfalls

### Pitfall 1: Scan Overload

**Problem**: Too many concurrent scans overwhelm target or local resources.

**Solution**: Limit concurrency with semaphore.

```python
import threading

scan_semaphore = threading.Semaphore(3)  # Max 3 concurrent scans

def limited_scan(target_config):
    with scan_semaphore:
        return scheduler.run_target(target_config)
```

### Pitfall 2: Stale Baselines

**Problem**: Baseline never updated, drift reports always show changes.

**Solution**: Auto-update baseline after each scan cycle.

```python
if config["baseline"]["auto_update"]:
    mgr.save_baseline(target_name, current_findings)
```

### Pitfall 3: Duplicate Scan Alerts

**Problem**: Same finding reported multiple times across scan cycles.

**Solution**: Dedup findings by hash before alerting.

```python
def dedup_findings(findings: list) -> list:
    seen = set()
    unique = []
    for f in findings:
        key = hashlib.sha256(f"{f['id']}:{f['endpoint']}".encode()).hexdigest()[:12]
        if key not in seen:
            seen.add(key)
            unique.append(f)
    return unique
```

### Pitfall 4: Scan Tool Failures

**Problem**: Nuclei crashes or times out, no results recorded.

**Solution**: Error handling and retry logic.

```python
def run_with_retry(func, *args, retries=2, **kwargs):
    for attempt in range(retries + 1):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            if attempt == retries:
                raise
            print(f"Attempt {attempt + 1} failed: {e}, retrying...")
            time.sleep(5)
```

### Pitfall 5: Disk Space Exhaustion

**Problem**: Scan results fill up disk over time.

**Solution**: Rotate old results.

```python
def rotate_results(results_dir: str, max_files: int = 100):
    path = Path(results_dir)
    files = sorted(path.glob("*"), key=lambda f: f.stat().st_mtime)
    if len(files) > max_files:
        for f in files[:len(files) - max_files]:
            f.unlink()
            print(f"Removed old result: {f.name}")
```

---

## 8. Advanced Techniques

### 8.1 Adaptive Scan Frequency

```python
def calculate_scan_frequency(target_stats: dict) -> int:
    """Return scan interval in seconds based on finding history."""
    recent_findings = target_stats.get("findings_last_7d", 0)
    if recent_findings > 10:
        return 43200   # Every 12 hours for active targets
    elif recent_findings > 3:
        return 86400   # Daily
    else:
        return 259200  # Every 3 days for quiet targets
```

### 8.2 Multi-Stage Scan Pipeline

```python
def multi_stage_scan(target: str):
    """Stage 1: Subdomain enum -> Stage 2: Live host check -> Stage 3: Vuln scan."""
    from scan_runner import ScanRunner
    runner = ScanRunner({})

    # Stage 1: Discover subdomains
    subs_file = runner.run_subfinder(target)
    print(f"Stage 1: Subdomains discovered")

    # Stage 2: Check which are live
    httpx_file = runner.run_httpx(subs_file)
    print(f"Stage 2: Live hosts identified")

    # Stage 3: Run nuclei on live hosts
    results_file = runner.run_nuclei(httpx_file)
    print(f"Stage 3: Vulnerability scan complete")

    return runner.parse_nuclei_results(results_file)
```

### 8.3 Scan Result Caching

```python
import hashlib
from pathlib import Path


class ScanCache:
    def __init__(self, cache_dir: str = ".cache/scans"):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def _key(self, target: str, template: str) -> str:
        raw = f"{target}:{template}"
        return hashlib.sha256(raw.encode()).hexdigest()[:16]

    def get(self, target: str, template: str) -> list | None:
        cache_file = self.cache_dir / f"{self._key(target, template)}.json"
        if cache_file.exists():
            with open(cache_file) as f:
                return json.load(f)
        return None

    def set(self, target: str, template: str, findings: list):
        cache_file = self.cache_dir / f"{self._key(target, template)}.json"
        with open(cache_file, "w") as f:
            json.dump(findings, f)
```

### 8.4 Scan Progress Tracking

```python
class ScanProgress:
    def __init__(self):
        self.progress = {}

    def start(self, scan_id: str, total_steps: int):
        self.progress[scan_id] = {
            "total": total_steps,
            "completed": 0,
            "status": "running",
            "start_time": datetime.now().isoformat(),
        }

    def update(self, scan_id: str, completed: int):
        if scan_id in self.progress:
            self.progress[scan_id]["completed"] = completed

    def finish(self, scan_id: str, status: str = "completed"):
        if scan_id in self.progress:
            self.progress[scan_id]["status"] = status
            self.progress[scan_id]["end_time"] = datetime.now().isoformat()

    def get_percentage(self, scan_id: str) -> float:
        p = self.progress.get(scan_id, {})
        total = p.get("total", 1)
        completed = p.get("completed", 0)
        return round((completed / total) * 100, 1)
```

---

## 9. Reporting Template

### Continuous Scan Status Report

```python
from datetime import datetime
from pathlib import Path
import json


def generate_scan_status_report():
    log_file = Path("logs/scan_log.jsonl")
    if not log_file.exists():
        return "No scan logs found."

    entries = []
    with open(log_file) as f:
        for line in f:
            if line.strip():
                entries.append(json.loads(line))

    today = datetime.now().strftime("%Y-%m-%d")
    today_entries = [e for e in entries if e["timestamp"].startswith(today)]

    report = f"""# Continuous Scan Status Report
Date: {today}

## Today's Activity
- Log entries: {len(today_entries)}
"""
    for e in today_entries:
        report += f"- [{e['timestamp'][:19]}] {e['message']}\n"

    # Scan statistics
    dedup = ScanDeduplicator()
    stats = dedup.get_scan_stats()
    report += f"""
## Scan Statistics
- Unique targets: {stats['total_unique_targets']}
- Total scans recorded: {stats['total_scans_recorded']}
- Scans in last 24h: {stats['scans_in_window']}

## Baselines
"""
    mgr = BaselineManager()
    for b in mgr.list_baselines():
        report += f"- {b['target']}: {b['finding_count']} findings (updated: {b['timestamp']})\n"

    output_path = Path("reports") / f"scan_status_{today}.md"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(report)
    return str(output_path)
```

---

## 10. Quick Reference

### Scan Schedule

```
Hourly   → Drift detection, health checks
Daily    → Full vulnerability scans
Weekly   → Comprehensive scan with baseline comparison
Monthly  → Full re-baseline
```

### Key Commands

```bash
# Start continuous scanner
python scheduler.py

# Run all targets once
python -c "from scheduler import ScanScheduler; s=ScanScheduler(); s.run_all()"

# Check dedup status
python -c "from dedup import ScanDeduplicator; d=ScanDeduplicator(); print(d.get_scan_stats())"

# Create baseline
python -c "from baseline_manager import BaselineManager; m=BaselineManager(); m.save_baseline('target', findings)"

# View drift
python -c "from baseline_manager import BaselineManager; m=BaselineManager(); print(m.compare_with_baseline('target', current))"
```

### Dedup Logic

```
should_scan(target, template) →
  IF last_run < window_hours → SKIP (cooldown)
  ELSE → ALLOW
```

### Baseline Diff Output

```json
{
  "new_findings": [...],
  "removed_findings": [...],
  "severity_changed": [...],
  "unchanged_count": 15,
  "drift_score": 3
}
```

### File Structure

```
continuous_scan/
├── config.yaml               # Scan targets and schedules
├── scheduler.py              # Main scheduling loop
├── scan_runner.py            # Tool execution
├── dedup.py                  # Deduplication engine
├── baseline_manager.py       # Baseline CRUD + comparison
├── baselines/                # Stored baselines
├── results/                  # Raw scan outputs
├── diffs/                    # Drift comparison results
├── logs/                     # Scan history
└── reports/                  # Generated reports
```

### Design Principles

1. **Never scan without checking dedup first**
2. **Baseline everything, compare everything**
3. **Fail gracefully**: Tool crash should not stop pipeline
4. **Log all activity**: Every scan, skip, and diff
5. **Rotate old data**: Keep disk usage bounded
6. **Adaptive frequency**: More findings = more scans
7. **Incremental over full**: When possible, scan only changed assets
