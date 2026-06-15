# Automation-Efficiency 10: Change Detection Automation

## 1. Expert Role

You are a Security Configuration and Change Detection Engineer who builds automated systems to monitor, detect, and report changes across infrastructure, code, and configurations. Your expertise covers file integrity monitoring, configuration drift detection, version control diffing, audit trail generation, and automated rollback triggers. You ensure that any unauthorized or unexpected change is immediately visible and actionable.

---

## 2. Core Concepts

### 2.1 Change Detection Architecture

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Watched      │───▶│  Change      │───▶│  Diff &      │───▶│  Alert /     │
│  Resources    │    │  Detector    │    │  Classifier  │    │  Audit Log   │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
       │                   │                   │                    │
  Files, configs,     FSWatch/inotify,    Hash comparison,     Notifications,
  web endpoints,      polling, webhooks   content diff,        rollback,
  APIs, databases                         severity classify    audit trail
```

### 2.2 Change Categories

| Category | Detection Method | Severity | Example |
|----------|-----------------|----------|---------|
| Config File Change | File hash comparison | High | Nginx config modified |
| Code Change | Git diff / file watch | Medium | Source file updated |
| Credential Exposure | Pattern matching | Critical | API key in config |
| Endpoint Change | HTTP content hash | High | Web page content altered |
| Permission Change | OS attribute check | High | File permissions widened |
| New File Created | Directory watch | Medium | New script added |
| File Deleted | Directory watch | Low | Backup file removed |
| DNS Change | Record comparison | Medium | DNS record updated |
| SSL Certificate | Expiry check | High | Certificate expiring |

### 2.3 Change Detection Methods

```
Polling     → Periodic comparison against baseline
Event-based → OS-level file system notifications
Content     → Hash comparison of file/endpoint content
Structural  → Schema or structure comparison
Behavioral  → API response pattern comparison
```

### 2.4 Audit Trail Format

```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "resource": "/etc/nginx/nginx.conf",
  "change_type": "modified",
  "severity": "high",
  "old_hash": "abc123...",
  "new_hash": "def456...",
  "diff_summary": "3 lines changed, 1 line added",
  "actor": "root",
  "automated_response": "alert_sent"
}
```

---

## 3. Prerequisites

### 3.1 Required Python Packages

```bash
pip install watchdog requests pyyaml hashlib-plus schedule
```

### 3.2 System Dependencies

```bash
# Linux: inotify-tools (optional, for better file watching)
sudo apt-get install inotify-tools

# Windows: No additional dependencies needed (watchdog uses ReadDirectoryChangesW)
```

### 3.3 Directory Structure

```
change_detection/
├── config.yaml
├── detector.py
├── watchers/
│   ├── file_watcher.py
│   ├── endpoint_watcher.py
│   ├── config_watcher.py
│   └── dns_watcher.py
├── classifiers/
│   ├── change_classifier.py
│   └── severity_engine.py
├── audit/
│   ├── audit_logger.py
│   └── diff_engine.py
├── baselines/
│   └── {resource}_baseline.json
├── audit_logs/
│   └── audit_trail.json
└── alerts/
    └── change_alerts.json
```

---

## 4. Methodology

### Step 1: Define Watch Configuration

```yaml
# config.yaml
change_detection:
  watch_targets:
    - name: "nginx-config"
      type: "file"
      paths:
        - "/etc/nginx/nginx.conf"
        - "/etc/nginx/conf.d/"
      patterns: ["*.conf"]
      severity: "high"
      enabled: true

    - name: "web-endpoints"
      type: "endpoint"
      urls:
        - "https://target.example.com/robots.txt"
        - "https://target.example.com/.env"
        - "https://target.example.com/api/health"
      check_interval_seconds: 300
      severity: "high"
      enabled: true

    - name: "dns-records"
      type: "dns"
      domains:
        - "example.com"
        - "subdomain.example.com"
      record_types: ["A", "AAAA", "CNAME", "MX", "TXT"]
      check_interval_seconds: 3600
      severity: "medium"
      enabled: true

    - name: "ssl-certificates"
      type: "ssl"
      hosts:
        - "example.com:443"
        - "api.example.com:443"
      warning_days: 30
      critical_days: 7
      severity: "high"
      enabled: true

  audit:
    log_dir: "audit_logs"
    retention_days: 90
    log_format: "json"

  alerts:
    on_critical: ["slack", "email"]
    on_high: ["slack"]
    on_medium: ["log_only"]
    on_low: ["log_only"]
```

### Step 2: Build the File Hasher and Baseline Manager

```python
# detectors/file_detector.py
import hashlib
import json
import os
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


class FileHasher:
    """Compute and compare file hashes for change detection."""

    @staticmethod
    def hash_file(filepath: str, algorithm: str = "sha256") -> str:
        h = hashlib.new(algorithm)
        with open(filepath, "rb") as f:
            for chunk in iter(lambda: f.read(8192), b""):
                h.update(chunk)
        return h.hexdigest()

    @staticmethod
    def hash_directory(dirpath: str, patterns: List[str] = None) -> Dict[str, str]:
        hashes = {}
        path = Path(dirpath)
        for file in path.rglob("*"):
            if file.is_file():
                if patterns:
                    if not any(file.match(p) for p in patterns):
                        continue
                hashes[str(file)] = FileHasher.hash_file(str(file))
        return hashes


class FileBaselineManager:
    """Manage file integrity baselines."""

    def __init__(self, baselines_dir: str = "baselines"):
        self.baselines_dir = Path(baselines_dir)
        self.baselines_dir.mkdir(parents=True, exist_ok=True)

    def _baseline_path(self, name: str) -> Path:
        return self.baselines_dir / f"{name}_file_baseline.json"

    def save_baseline(self, name: str, paths: List[str], patterns: List[str] = None):
        baseline = {
            "name": name,
            "timestamp": datetime.now().isoformat(),
            "files": {},
        }

        for path_str in paths:
            path = Path(path_str)
            if path.is_file():
                baseline["files"][str(path)] = {
                    "hash": FileHasher.hash_file(str(path)),
                    "size": path.stat().st_size,
                    "mtime": path.stat().st_mtime,
                }
            elif path.is_dir():
                dir_hashes = FileHasher.hash_directory(str(path), patterns)
                for fpath, fhash in dir_hashes.items():
                    f = Path(fpath)
                    baseline["files"][fpath] = {
                        "hash": fhash,
                        "size": f.stat().st_size,
                        "mtime": f.stat().st_mtime,
                    }

        with open(self._baseline_path(name), "w") as f:
            json.dump(baseline, f, indent=2)

        return baseline

    def load_baseline(self, name: str) -> dict:
        path = self._baseline_path(name)
        if path.exists():
            with open(path) as f:
                return json.load(f)
        return {"name": name, "files": {}, "timestamp": None}

    def compare(self, name: str, current_paths: List[str], patterns: List[str] = None) -> dict:
        baseline = self.load_baseline(name)
        baseline_files = baseline.get("files", {})

        current_files = {}
        for path_str in current_paths:
            path = Path(path_str)
            if path.is_file():
                current_files[str(path)] = {
                    "hash": FileHasher.hash_file(str(path)),
                    "size": path.stat().st_size,
                    "mtime": path.stat().st_mtime,
                }
            elif path.is_dir():
                dir_hashes = FileHasher.hash_directory(str(path), patterns)
                for fpath, fhash in dir_hashes.items():
                    f = Path(fpath)
                    current_files[fpath] = {
                        "hash": fhash,
                        "size": f.stat().st_size,
                        "mtime": f.stat().st_mtime,
                    }

        baseline_set = set(baseline_files.keys())
        current_set = set(current_files.keys())

        added = current_set - baseline_set
        removed = baseline_set - current_set
        common = baseline_set & current_set

        modified = []
        unchanged = []
        for fpath in common:
            if baseline_files[fpath]["hash"] != current_files[fpath]["hash"]:
                modified.append({
                    "path": fpath,
                    "old_hash": baseline_files[fpath]["hash"],
                    "new_hash": current_files[fpath]["hash"],
                    "old_size": baseline_files[fpath]["size"],
                    "new_size": current_files[fpath]["size"],
                })
            else:
                unchanged.append(fpath)

        return {
            "name": name,
            "baseline_timestamp": baseline.get("timestamp"),
            "current_timestamp": datetime.now().isoformat(),
            "added": [{"path": p, **current_files[p]} for p in added],
            "removed": [{"path": p, **baseline_files[p]} for p in removed],
            "modified": modified,
            "unchanged_count": len(unchanged),
            "total_changes": len(added) + len(removed) + len(modified),
        }
```

### Step 3: Build the Endpoint Watcher

```python
# watchers/endpoint_watcher.py
import hashlib
import json
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List

import requests


class EndpointWatcher:
    """Monitor web endpoints for content changes."""

    def __init__(self, baselines_dir: str = "baselines"):
        self.baselines_dir = Path(baselines_dir)
        self.baselines_dir.mkdir(parents=True, exist_ok=True)

    def _baseline_path(self, name: str) -> Path:
        return self.baselines_dir / f"{name}_endpoint_baseline.json"

    def fetch_content(self, url: str, timeout: int = 10) -> dict:
        try:
            start = time.time()
            resp = requests.get(url, timeout=timeout, allow_redirects=True)
            latency_ms = (time.time() - start) * 1000

            content_hash = hashlib.sha256(resp.content).hexdigest()
            return {
                "url": url,
                "status_code": resp.status_code,
                "content_hash": content_hash,
                "content_length": len(resp.content),
                "latency_ms": round(latency_ms, 2),
                "headers": dict(resp.headers),
                "content": resp.text[:5000],
                "timestamp": datetime.now().isoformat(),
                "error": None,
            }
        except requests.RequestException as e:
            return {
                "url": url,
                "status_code": 0,
                "content_hash": "",
                "content_length": 0,
                "latency_ms": 0,
                "headers": {},
                "content": "",
                "timestamp": datetime.now().isoformat(),
                "error": str(e),
            }

    def save_baseline(self, name: str, urls: List[str]):
        baseline = {
            "name": name,
            "timestamp": datetime.now().isoformat(),
            "endpoints": {},
        }

        for url in urls:
            result = self.fetch_content(url)
            baseline["endpoints"][url] = result

        with open(self._baseline_path(name), "w") as f:
            json.dump(baseline, f, indent=2)

        return baseline

    def check_changes(self, name: str, urls: List[str]) -> dict:
        baseline_data = self.load_baseline(name)
        baseline_endpoints = baseline_data.get("endpoints", {})

        changes = []
        for url in urls:
            current = self.fetch_content(url)
            prev = baseline_endpoints.get(url, {})

            if not prev:
                changes.append({
                    "url": url,
                    "change_type": "new_endpoint",
                    "details": current,
                })
                continue

            change_details = {}
            if current["content_hash"] != prev.get("content_hash", ""):
                change_details["content_changed"] = True
            if current["status_code"] != prev.get("status_code", 0):
                change_details["status_changed"] = True
                change_details["old_status"] = prev.get("status_code")
                change_details["new_status"] = current["status_code"]

            if change_details:
                changes.append({
                    "url": url,
                    "change_type": "modified",
                    "details": change_details,
                    "current": current,
                    "previous": prev,
                })

        return {
            "name": name,
            "baseline_timestamp": baseline_data.get("timestamp"),
            "current_timestamp": datetime.now().isoformat(),
            "changes": changes,
            "total_endpoints": len(urls),
            "changed_endpoints": len(changes),
        }

    def load_baseline(self, name: str) -> dict:
        path = self._baseline_path(name)
        if path.exists():
            with open(path) as f:
                return json.load(f)
        return {"name": name, "endpoints": {}}
```

### Step 4: Build the DNS Watcher

```python
# watchers/dns_watcher.py
import hashlib
import json
import socket
from datetime import datetime
from pathlib import Path
from typing import Dict, List
import subprocess


class DNSWatcher:
    """Monitor DNS records for changes."""

    def __init__(self, baselines_dir: str = "baselines"):
        self.baselines_dir = Path(baselines_dir)
        self.baselines_dir.mkdir(parents=True, exist_ok=True)

    def _baseline_path(self, name: str) -> Path:
        return self.baselines_dir / f"{name}_dns_baseline.json"

    def resolve_domain(self, domain: str, record_type: str = "A") -> List[str]:
        try:
            if record_type == "A":
                results = socket.getaddrinfo(domain, None, socket.AF_INET)
                return list(set(r[4][0] for r in results))
            elif record_type == "AAAA":
                results = socket.getaddrinfo(domain, None, socket.AF_INET6)
                return list(set(r[4][0] for r in results))
            elif record_type == "CNAME":
                return [socket.getfqdn(domain)]
        except socket.gaierror:
            return []

        try:
            result = subprocess.run(
                ["nslookup", "-type=" + record_type, domain],
                capture_output=True, text=True, timeout=10
            )
            records = []
            for line in result.stdout.split("\n"):
                if record_type in line and "Address:" in line:
                    parts = line.split(":")
                    if len(parts) > 1:
                        records.append(parts[1].strip())
            return records
        except Exception:
            return []

    def get_all_records(self, domain: str, record_types: List[str]) -> dict:
        records = {}
        for rtype in record_types:
            records[rtype] = self.resolve_domain(domain, rtype)
        return records

    def save_baseline(self, name: str, domains: List[str], record_types: List[str]):
        baseline = {
            "name": name,
            "timestamp": datetime.now().isoformat(),
            "domains": {},
        }

        for domain in domains:
            baseline["domains"][domain] = self.get_all_records(domain, record_types)

        with open(self._baseline_path(name), "w") as f:
            json.dump(baseline, f, indent=2)

        return baseline

    def check_changes(self, name: str, domains: List[str], record_types: List[str]) -> dict:
        baseline_data = self.load_baseline(name)
        baseline_domains = baseline_data.get("domains", {})

        changes = []
        for domain in domains:
            current = self.get_all_records(domain, record_types)
            prev = baseline_domains.get(domain, {})

            domain_changes = {}
            for rtype in record_types:
                current_records = set(current.get(rtype, []))
                prev_records = set(prev.get(rtype, []))

                added = current_records - prev_records
                removed = prev_records - current_records

                if added or removed:
                    domain_changes[rtype] = {
                        "added": list(added),
                        "removed": list(removed),
                    }

            if domain_changes:
                changes.append({
                    "domain": domain,
                    "changes": domain_changes,
                })

        return {
            "name": name,
            "baseline_timestamp": baseline_data.get("timestamp"),
            "current_timestamp": datetime.now().isoformat(),
            "changes": changes,
            "total_domains": len(domains),
            "changed_domains": len(changes),
        }

    def load_baseline(self, name: str) -> dict:
        path = self._baseline_path(name)
        if path.exists():
            with open(path) as f:
                return json.load(f)
        return {"name": name, "domains": {}}
```

### Step 5: Build the Audit Logger

```python
# audit/audit_logger.py
import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List


class AuditLogger:
    """Log all changes to an immutable audit trail."""

    def __init__(self, log_dir: str = "audit_logs", retention_days: int = 90):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.audit_file = self.log_dir / "audit_trail.json"
        self.retention_days = retention_days
        self.entries = self._load()

    def _load(self) -> list:
        if self.audit_file.exists():
            with open(self.audit_file) as f:
                return json.load(f)
        return []

    def _save(self):
        with open(self.audit_file, "w") as f:
            json.dump(self.entries, f, indent=2)

    def log_change(
        self,
        resource: str,
        change_type: str,
        severity: str,
        details: dict,
        old_hash: str = "",
        new_hash: str = "",
        actor: str = "automated",
        response: str = "logged",
    ):
        entry = {
            "id": len(self.entries) + 1,
            "timestamp": datetime.now().isoformat(),
            "resource": resource,
            "change_type": change_type,
            "severity": severity,
            "old_hash": old_hash,
            "new_hash": new_hash,
            "diff_summary": details.get("diff_summary", ""),
            "details": details,
            "actor": actor,
            "automated_response": response,
        }
        self.entries.append(entry)
        self._save()
        return entry

    def log_file_change(self, change_result: dict, severity: str = "high"):
        for added in change_result.get("added", []):
            self.log_change(
                resource=added["path"],
                change_type="file_added",
                severity=severity,
                details={"size": added.get("size", 0), "hash": added.get("hash", "")},
                new_hash=added.get("hash", ""),
            )

        for removed in change_result.get("removed", []):
            self.log_change(
                resource=removed["path"],
                change_type="file_removed",
                severity=severity,
                details={"size": removed.get("size", 0), "hash": removed.get("hash", "")},
                old_hash=removed.get("hash", ""),
            )

        for modified in change_result.get("modified", []):
            self.log_change(
                resource=modified["path"],
                change_type="file_modified",
                severity=severity,
                details={
                    "old_size": modified.get("old_size", 0),
                    "new_size": modified.get("new_size", 0),
                    "diff_summary": f"Hash changed: {modified['old_hash'][:8]} -> {modified['new_hash'][:8]}",
                },
                old_hash=modified.get("old_hash", ""),
                new_hash=modified.get("new_hash", ""),
            )

    def log_endpoint_change(self, change_result: dict, severity: str = "high"):
        for change in change_result.get("changes", []):
            self.log_change(
                resource=change["url"],
                change_type="endpoint_" + change.get("change_type", "modified"),
                severity=severity,
                details=change.get("details", {}),
            )

    def log_dns_change(self, change_result: dict, severity: str = "medium"):
        for change in change_result.get("changes", []):
            for rtype, rdata in change.get("changes", {}).items():
                self.log_change(
                    resource=f"{change['domain']}:{rtype}",
                    change_type="dns_record_changed",
                    severity=severity,
                    details=rdata,
                )

    def query(
        self,
        start_date: str = None,
        end_date: str = None,
        severity: str = None,
        change_type: str = None,
        resource: str = None,
    ) -> List[dict]:
        results = self.entries

        if start_date:
            results = [e for e in results if e["timestamp"] >= start_date]
        if end_date:
            results = [e for e in results if e["timestamp"] <= end_date]
        if severity:
            results = [e for e in results if e["severity"] == severity]
        if change_type:
            results = [e for e in results if e["change_type"] == change_type]
        if resource:
            results = [e for e in results if resource in e["resource"]]

        return results

    def get_summary(self) -> dict:
        now = datetime.now()
        last_24h = (now - timedelta(hours=24)).isoformat()
        last_7d = (now - timedelta(days=7)).isoformat()

        recent_24h = [e for e in self.entries if e["timestamp"] >= last_24h]
        recent_7d = [e for e in self.entries if e["timestamp"] >= last_7d]

        severity_counts = {}
        for e in self.entries:
            s = e.get("severity", "unknown")
            severity_counts[s] = severity_counts.get(s, 0) + 1

        return {
            "total_entries": len(self.entries),
            "entries_24h": len(recent_24h),
            "entries_7d": len(recent_7d),
            "by_severity": severity_counts,
            "last_entry": self.entries[-1]["timestamp"] if self.entries else None,
        }

    def cleanup_old_entries(self):
        cutoff = (datetime.now() - timedelta(days=self.retention_days)).isoformat()
        self.entries = [e for e in self.entries if e["timestamp"] >= cutoff]
        self._save()
```

### Step 6: Build the Change Classifier

```python
# classifiers/change_classifier.py
from typing import Dict


class ChangeClassifier:
    """Classify changes by severity and type."""

    SEVERITY_RULES = {
        "file_modified": {
            "patterns": {
                r"\.conf$": "high",
                r"\.env$": "critical",
                r"\.key$": "critical",
                r"\.pem$": "critical",
                r"password": "critical",
                r"secret": "critical",
                r"api.key": "critical",
                r"token": "critical",
            },
            "default": "medium",
        },
        "file_added": {
            "patterns": {
                r"\.sh$": "high",
                r"\.py$": "medium",
                r"\.js$": "medium",
                r"\.exe$": "critical",
                r"\.dll$": "critical",
            },
            "default": "low",
        },
        "file_removed": {
            "default": "medium",
        },
        "endpoint_modified": {
            "default": "high",
        },
        "endpoint_status_changed": {
            "default": "high",
        },
        "dns_record_changed": {
            "default": "medium",
        },
    }

    def classify(self, change_type: str, resource: str, details: dict = None) -> str:
        rules = self.SEVERITY_RULES.get(change_type, {})
        patterns = rules.get("patterns", {})

        for pattern, severity in patterns.items():
            if pattern.lower() in resource.lower():
                return severity

        return rules.get("default", "info")

    def should_alert(self, severity: str, alert_config: dict) -> bool:
        channels = alert_config.get(f"on_{severity}", [])
        return len(channels) > 0 and channels != ["log_only"]
```

---

## 5. Tool Arsenal with Commands

### 5.1 Quick File Baseline

```python
from detectors.file_detector import FileBaselineManager

mgr = FileBaselineManager()
mgr.save_baseline(
    name="nginx-config",
    paths=["/etc/nginx/nginx.conf", "/etc/nginx/conf.d/"],
    patterns=["*.conf"],
)
print("Baseline saved")
```

### 5.2 Quick File Change Check

```python
from detectors.file_detector import FileBaselineManager

mgr = FileBaselineManager()
diff = mgr.compare(
    name="nginx-config",
    current_paths=["/etc/nginx/nginx.conf", "/etc/nginx/conf.d/"],
    patterns=["*.conf"],
)
print(f"Changes: {diff['total_changes']}")
print(f"Modified: {len(diff['modified'])}")
print(f"Added: {len(diff['added'])}")
print(f"Removed: {len(diff['removed'])}")
```

### 5.3 Quick Endpoint Check

```python
from watchers.endpoint_watcher import EndpointWatcher

watcher = EndpointWatcher()
watcher.save_baseline("web-check", ["https://target.example.com/robots.txt"])
changes = watcher.check_changes("web-check", ["https://target.example.com/robots.txt"])
print(f"Endpoint changes: {changes['changed_endpoints']}")
```

### 5.4 Run All Detectors

```python
import yaml
from detectors.file_detector import FileBaselineManager
from watchers.endpoint_watcher import EndpointWatcher
from watchers.dns_watcher import DNSWatcher
from audit.audit_logger import AuditLogger


def run_all_detectors(config_path: str = "config.yaml"):
    with open(config_path) as f:
        config = yaml.safe_load(f)["change_detection"]

    file_mgr = FileBaselineManager()
    endpoint_watcher = EndpointWatcher()
    dns_watcher = DNSWatcher()
    audit = AuditLogger()

    for target in config.get("watch_targets", []):
        if not target.get("enabled", True):
            continue

        name = target["name"]
        target_type = target["type"]

        if target_type == "file":
            paths = target.get("paths", [])
            patterns = target.get("patterns", [])
            if file_mgr.load_baseline(name).get("timestamp"):
                diff = file_mgr.compare(name, paths, patterns)
                if diff["total_changes"] > 0:
                    audit.log_file_change(diff, target.get("severity", "medium"))
                    print(f"[{name}] {diff['total_changes']} changes detected")
            else:
                file_mgr.save_baseline(name, paths, patterns)
                print(f"[{name}] Baseline created")

        elif target_type == "endpoint":
            urls = target.get("urls", [])
            if endpoint_watcher.load_baseline(name).get("timestamp"):
                changes = endpoint_watcher.check_changes(name, urls)
                if changes["changed_endpoints"] > 0:
                    audit.log_endpoint_change(changes, target.get("severity", "high"))
                    print(f"[{name}] {changes['changed_endpoints']} endpoints changed")
            else:
                endpoint_watcher.save_baseline(name, urls)
                print(f"[{name}] Baseline created")

        elif target_type == "dns":
            domains = target.get("domains", [])
            rtypes = target.get("record_types", ["A"])
            if dns_watcher.load_baseline(name).get("timestamp"):
                changes = dns_watcher.check_changes(name, domains, rtypes)
                if changes["changed_domains"] > 0:
                    audit.log_dns_change(changes, target.get("severity", "medium"))
                    print(f"[{name}] {changes['changed_domains']} domains changed")
            else:
                dns_watcher.save_baseline(name, domains, rtypes)
                print(f"[{name}] Baseline created")
```

### 5.5 Audit Log Query

```python
from audit.audit_logger import AuditLogger

audit = AuditLogger()

# Get last 24h critical changes
critical = audit.query(severity="critical")
print(f"Critical changes: {len(critical)}")

# Get summary
summary = audit.get_summary()
print(f"Total audit entries: {summary['total_entries']}")
print(f"Changes in 24h: {summary['entries_24h']}")
```

---

## 6. Real-World Examples

### Example 1: Continuous File Monitoring

```python
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from detectors.file_detector import FileBaselineManager, FileHasher
from audit.audit_logger import AuditLogger


class ConfigChangeHandler(FileSystemEventHandler):
    def __init__(self, baseline_mgr: FileBaselineManager, audit: AuditLogger):
        self.baseline_mgr = baseline_mgr
        self.audit = audit

    def on_modified(self, event):
        if event.is_directory:
            return

        filepath = event.src_path
        new_hash = FileHasher.hash_file(filepath)

        baseline = self.baseline_mgr.load_baseline("active")
        old_hash = baseline.get("files", {}).get(filepath, {}).get("hash", "")

        if new_hash != old_hash:
            self.audit.log_change(
                resource=filepath,
                change_type="file_modified",
                severity="high",
                details={"diff_summary": f"Hash: {old_hash[:8]} -> {new_hash[:8]}"},
                old_hash=old_hash,
                new_hash=new_hash,
            )
            print(f"Change detected: {filepath}")


def watch_directory(directory: str):
    baseline_mgr = FileBaselineManager()
    audit = AuditLogger()

    handler = ConfigChangeHandler(baseline_mgr, audit)
    observer = Observer()
    observer.schedule(handler, directory, recursive=True)
    observer.start()

    print(f"Watching {directory} for changes...")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
```

### Example 2: API Endpoint Monitoring

```python
from watchers.endpoint_watcher import EndpointWatcher
from audit.audit_logger import AuditLogger
import schedule
import time


def check_endpoints():
    watcher = EndpointWatcher()
    audit = AuditLogger()

    urls = [
        "https://target.example.com/robots.txt",
        "https://target.example.com/.well-known/security.txt",
        "https://target.example.com/api/health",
    ]

    changes = watcher.check_changes("web-monitor", urls)
    if changes["changed_endpoints"] > 0:
        audit.log_endpoint_change(changes, severity="high")
        print(f"Changes detected on {changes['changed_endpoints']} endpoints")
    else:
        print("No changes detected")


schedule.every(5).minutes.do(check_endpoints)

while True:
    schedule.run_pending()
    time.sleep(60)
```

### Example 3: Git Repository Change Detection

```python
import subprocess
import json
from pathlib import Path
from audit.audit_logger import AuditLogger


def detect_git_changes(repo_path: str):
    audit = AuditLogger()

    cmd = ["git", "-C", repo_path, "diff", "--stat", "HEAD~1"]
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.stdout.strip():
        changes = result.stdout.strip().split("\n")
        for change in changes:
            if "|" in change:
                parts = change.split("|")
                file_path = parts[0].strip()
                change_stat = parts[1].strip()

                audit.log_change(
                    resource=f"{repo_path}/{file_path}",
                    change_type="code_changed",
                    severity="medium",
                    details={"stat": change_stat},
                )

        print(f"Logged {len(changes)} git changes")
    else:
        print("No git changes detected")
```

---

## 7. Common Pitfalls

### Pitfall 1: False Positives from Timestamps

**Problem**: File mtime changes without content change (e.g., touch command).

**Solution**: Always compare hashes, not timestamps.

```python
# WRONG: Comparing mtime
if current["mtime"] != baseline["mtime"]:
    print("Changed!")

# RIGHT: Comparing hash
if current["hash"] != baseline["hash"]:
    print("Actually changed!")
```

### Pitfall 2: Race Conditions During Baseline Save

**Problem**: File changes while baseline is being saved.

**Solution**: Atomic baseline operations.

```python
import tempfile
import os

def atomic_save_baseline(path: Path, data: dict):
    tmp = tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False)
    json.dump(data, tmp, indent=2)
    tmp.close()
    os.replace(tmp.name, path)
```

### Pitfall 3: Too Many Small Changes

**Problem**: Rapid file changes generate hundreds of audit entries.

**Solution**: Debounce changes within a time window.

```python
from collections import defaultdict
import time


class ChangeDebouncer:
    def __init__(self, window_seconds: int = 5):
        self.window = window_seconds
        self.pending = defaultdict(float)

    def should_process(self, resource: str) -> bool:
        now = time.time()
        if now - self.pending[resource] > self.window:
            self.pending[resource] = now
            return True
        return False
```

### Pitfall 4: Endpoint Monitoring Rate Limits

**Problem**: Checking endpoints too frequently triggers rate limiting.

**Solution**: Respect Retry-After headers and use exponential backoff.

```python
def fetch_with_backoff(url: str, max_retries: int = 3):
    for attempt in range(max_retries):
        resp = requests.get(url, timeout=10)
        if resp.status_code == 429:
            retry_after = int(resp.headers.get("Retry-After", 60))
            time.sleep(retry_after)
            continue
        return resp
    return None
```

### Pitfall 5: Audit Log Corruption

**Problem**: Power loss during write corrupts audit trail.

**Solution**: Append-only logging with fsync.

```python
def safe_append_audit(entry: dict, audit_file: Path):
    with open(audit_file, "a") as f:
        f.write(json.dumps(entry) + "\n")
        f.flush()
        os.fsync(f.fileno())
```

---

## 8. Advanced Techniques

### 8.1 Content-Aware Diff Engine

```python
import difflib


def compute_content_diff(old_content: str, new_content: str) -> str:
    old_lines = old_content.splitlines(keepends=True)
    new_lines = new_content.splitlines(keepends=True)
    diff = difflib.unified_diff(old_lines, new_lines, fromfile="before", tofile="after")
    return "".join(diff)


def summarize_diff(diff_text: str) -> dict:
    added = sum(1 for line in diff_text.split("\n") if line.startswith("+") and not line.startswith("+++"))
    removed = sum(1 for line in diff_text.split("\n") if line.startswith("-") and not line.startswith("---"))
    return {"lines_added": added, "lines_removed": removed, "total_changed": added + removed}
```

### 8.2 Webhook-Based Change Notifications

```python
import requests
import json


class ChangeNotifier:
    def __init__(self, slack_webhook: str = None, email_config: dict = None):
        self.slack_webhook = slack_webhook
        self.email_config = email_config

    def notify_slack(self, change: dict):
        if not self.slack_webhook:
            return

        severity = change.get("severity", "info")
        emoji = {"critical": "🚨", "high": "🔴", "medium": "🟡", "low": "🟢"}.get(severity, "📢")

        payload = {
            "text": f"{emoji} *[{severity.upper()}] Change Detected*",
            "attachments": [{
                "color": {"critical": "#FF0000", "high": "#FF6600", "medium": "#FFCC00"}.get(severity, "#999"),
                "fields": [
                    {"title": "Resource", "value": change.get("resource", "N/A"), "short": True},
                    {"title": "Type", "value": change.get("change_type", "N/A"), "short": True},
                    {"title": "Time", "value": change.get("timestamp", "N/A"), "short": True},
                ]
            }]
        }
        requests.post(self.slack_webhook, json=payload, timeout=10)

    def notify(self, change: dict):
        self.notify_slack(change)
```

### 8.3 Scheduled Baseline Refresh

```python
import schedule
import time
from detectors.file_detector import FileBaselineManager
from watchers.endpoint_watcher import EndpointWatcher


def refresh_all_baselines():
    file_mgr = FileBaselineManager()
    endpoint_watcher = EndpointWatcher()

    # Refresh file baselines
    file_mgr.save_baseline(
        "nginx-config",
        ["/etc/nginx/nginx.conf", "/etc/nginx/conf.d/"],
        ["*.conf"],
    )

    # Refresh endpoint baselines
    endpoint_watcher.save_baseline(
        "web-check",
        ["https://target.example.com/robots.txt"],
    )

    print(f"Baselines refreshed at {time.strftime('%Y-%m-%d %H:%M:%S')}")


schedule.every().monday.at("00:00").do(refresh_all_baselines)

while True:
    schedule.run_pending()
    time.sleep(60)
```

### 8.4 Change Impact Analysis

```python
def analyze_change_impact(change: dict) -> dict:
    resource = change.get("resource", "")
    change_type = change.get("change_type", "")

    impact = {
        "risk_level": "low",
        "affected_systems": [],
        "recommended_actions": [],
    }

    if ".conf" in resource:
        impact["risk_level"] = "high"
        impact["affected_systems"].append("configuration")
        impact["recommended_actions"].append("Verify configuration syntax")

    if ".key" in resource or ".pem" in resource:
        impact["risk_level"] = "critical"
        impact["affected_systems"].append("security")
        impact["recommended_actions"].append("Rotate credentials immediately")

    if change_type == "file_removed":
        impact["risk_level"] = "medium"
        impact["recommended_actions"].append("Check if removal was intentional")

    return impact
```

---

## 9. Reporting Template

### Change Detection Report

```python
from datetime import datetime
from pathlib import Path
import json
from audit.audit_logger import AuditLogger


def generate_change_report(days: int = 7) -> str:
    audit = AuditLogger()
    summary = audit.get_summary()

    from datetime import timedelta
    start = (datetime.now() - timedelta(days=days)).isoformat()
    recent = audit.query(start_date=start)

    report = f"""# Change Detection Report
Period: Last {days} days
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Summary
| Metric | Value |
|--------|-------|
| Total Changes | {summary['total_entries']} |
| Changes (24h) | {summary['entries_24h']} |
| Changes (7d) | {summary['entries_7d']} |
| Last Entry | {summary.get('last_entry', 'N/A')} |

## Changes by Severity
"""
    for sev, count in summary.get("by_severity", {}).items():
        report += f"- **{sev.upper()}**: {count}\n"

    report += "\n## Recent Changes\n\n"
    for change in recent[:20]:
        report += f"- [{change['timestamp'][:19]}] **{change['severity'].upper()}** `{change['resource']}` — {change['change_type']}\n"

    output_path = Path("reports") / f"change_report_{datetime.now().strftime('%Y%m%d')}.md"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(report)
    return str(output_path)
```

---

## 10. Quick Reference

### Change Types

```
file_added          New file detected
file_removed        File deleted
file_modified       File content changed
endpoint_modified   Web content changed
endpoint_status_changed  HTTP status changed
dns_record_changed  DNS record updated
code_changed        Git repository change
```

### Severity Classification

```
Critical  → .key, .pem, .env, secrets, credentials
High      → .conf, config files, endpoints, permissions
Medium    → .py, .js, .html, DNS changes, general files
Low       → Backup files, documentation, non-code files
Info      → Metadata changes, timestamps
```

### Key Commands

```bash
# Create file baseline
python -c "from detectors.file_detector import FileBaselineManager; m=FileBaselineManager(); m.save_baseline('config', ['/etc/nginx/'], ['*.conf'])"

# Check file changes
python -c "from detectors.file_detector import FileBaselineManager; m=FileBaselineManager(); print(m.compare('config', ['/etc/nginx/'], ['*.conf']))"

# Check endpoint changes
python -c "from watchers.endpoint_watcher import EndpointWatcher; w=EndpointWatcher(); print(w.check_changes('web', ['https://target.example.com/robots.txt']))"

# View audit log
python -c "from audit.audit_logger import AuditLogger; a=AuditLogger(); print(a.get_summary())"

# Run all detectors
python -c "from change_detection import run_all_detectors; run_all_detectors()"
```

### File Structure

```
change_detection/
├── config.yaml                    # Watch targets and rules
├── detectors/
│   └── file_detector.py           # File hashing and baseline
├── watchers/
│   ├── endpoint_watcher.py        # Web endpoint monitoring
│   └── dns_watcher.py             # DNS record monitoring
├── classifiers/
│   ├── change_classifier.py       # Severity classification
│   └── severity_engine.py         # Risk scoring
├── audit/
│   ├── audit_logger.py            # Immutable audit trail
│   └── diff_engine.py             # Content diff generation
├── baselines/                     # Stored baselines
├── audit_logs/                    # Audit trail
└── reports/                       # Generated reports
```

### Watch Types

```
file       → Hash comparison of local files
endpoint   → HTTP content hash comparison
dns        → DNS record resolution comparison
ssl        → Certificate expiry monitoring
git        → Repository commit diff
```

### Design Principles

1. **Hash over timestamp**: Never trust mtime, always verify content
2. **Baseline everything**: No detection without a known-good state
3. **Immutable audit**: Append-only logs, never delete history
4. **Debounce rapid changes**: Avoid flooding from build scripts
5. **Classify by impact**: Not all changes are equal
6. **Alert intelligently**: Route by severity, respect quiet hours
7. **Refresh baselines**: Periodically re-baseline to avoid drift fatigue
8. **Atomic operations**: Safe writes to prevent corruption
