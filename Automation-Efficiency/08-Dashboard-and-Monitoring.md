# Automation-Efficiency 8: Dashboard and Monitoring

## 1. Expert Role

You are a Security Operations Dashboard Engineer who builds real-time monitoring interfaces for bug bounty and vulnerability management workflows. Your expertise covers live scan progress tracking, finding trend visualization, health-check dashboards, team performance metrics, and infrastructure status monitoring. You build dashboards that give instant visibility into what is being scanned, what has been found, and where attention is needed.

---

## 2. Core Concepts

### 2.1 Dashboard Architecture

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Data Sources │───▶│  Collector   │───▶│  Dashboard   │
│  (scans/API) │    │  (aggregator)│    │  (frontend)  │
└──────────────┘    └──────────────┘    └──────────────┘
       │                   │                    │
  Scan results         Metrics DB          Web interface
  Health checks        Time-series         Charts/graphs
  Log streams          Cache               Real-time updates
```

### 2.2 Monitoring Layers

| Layer | What it Monitors | Update Frequency | Tool |
|-------|-----------------|-----------------|------|
| Scan Progress | Active scans, completion % | Real-time | WebSocket |
| Finding Trends | New/fixed/total findings | Hourly | Chart.js |
| Infrastructure | API uptime, service health | Every 5 min | Health checks |
| Team Performance | Findings per researcher | Daily | Aggregation |
| Target Coverage | Scope vs scanned | Weekly | Comparison |

### 2.3 Key Metrics

```
- scan_count_total          # Total scans executed
- scan_count_active         # Currently running scans
- finding_count_total       # Total findings discovered
- finding_count_by_severity # Breakdown by severity
- finding_rate_per_hour     # Discovery velocity
- mean_time_to_report       # Scan-to-report latency
- target_coverage_percent   # % of scope scanned
- false_positive_rate       # FP ratio
- service_uptime_percent    # Infrastructure health
- api_response_time_ms      # API latency
```

### 2.4 Dashboard Types

1. **Operations Dashboard**: Real-time scan status, active alerts
2. **Analytics Dashboard**: Trends, charts, historical data
3. **Executive Dashboard**: High-level KPIs, risk scores
4. **Health Dashboard**: Service status, uptime, errors

---

## 3. Prerequisites

### 3.1 Required Python Packages

```bash
pip install flask flask-socketio psutil requests pyyaml
pip install websockets aiohttp schedule
```

### 3.2 Frontend Libraries (via CDN)

```
Chart.js 4.x — Charts and graphs
Bootstrap 5.x — Responsive layout
Socket.IO — Real-time updates
DataTables — Sortable tables
```

### 3.3 Directory Structure

```
dashboard/
├── app.py                  # Flask + SocketIO server
├── config.yaml
├── static/
│   ├── css/
│   │   └── dashboard.css
│   ├── js/
│   │   ├── dashboard.js
│   │   ├── charts.js
│   │   └── realtime.js
│   └── img/
├── templates/
│   ├── base.html
│   ├── dashboard.html
│   ├── analytics.html
│   └── health.html
├── collectors/
│   ├── scan_collector.py
│   ├── metrics_collector.py
│   └── health_collector.py
├── data/
│   └── metrics.json
└── logs/
    └── dashboard.log
```

---

## 4. Methodology

### Step 1: Build the Data Collector

```python
# collectors/metrics_collector.py
import json
import time
import os
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any
from collections import defaultdict


class MetricsCollector:
    """Collect and aggregate security scan metrics."""

    def __init__(self, data_dir: str = "data"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)
        self.metrics_file = self.data_dir / "metrics.json"
        self.metrics = self._load_metrics()

    def _load_metrics(self) -> dict:
        if self.metrics_file.exists():
            with open(self.metrics_file) as f:
                return json.load(f)
        return {
            "scans": [],
            "findings": [],
            "health_checks": [],
            "daily_stats": {},
            "last_updated": datetime.now().isoformat(),
        }

    def _save_metrics(self):
        self.metrics["last_updated"] = datetime.now().isoformat()
        with open(self.metrics_file, "w") as f:
            json.dump(self.metrics, f, indent=2)

    def record_scan(self, scan_info: dict):
        scan_info["timestamp"] = datetime.now().isoformat()
        self.metrics["scans"].append(scan_info)
        self._save_metrics()

    def record_finding(self, finding: dict):
        finding["timestamp"] = datetime.now().isoformat()
        self.metrics["findings"].append(finding)
        self._update_daily_stats(finding)
        self._save_metrics()

    def record_health_check(self, service: str, status: str, latency_ms: float = 0):
        self.metrics["health_checks"].append({
            "service": service,
            "status": status,
            "latency_ms": latency_ms,
            "timestamp": datetime.now().isoformat(),
        })
        self._save_metrics()

    def _update_daily_stats(self, finding: dict):
        today = datetime.now().strftime("%Y-%m-%d")
        if today not in self.metrics["daily_stats"]:
            self.metrics["daily_stats"][today] = {
                "findings_count": 0,
                "by_severity": defaultdict(int),
                "by_target": defaultdict(int),
            }
        stats = self.metrics["daily_stats"][today]
        stats["findings_count"] += 1
        sev = finding.get("severity", "unknown")
        stats["by_severity"][sev] += 1
        target = finding.get("target", "unknown")
        stats["by_target"][target] += 1

    def get_realtime_stats(self) -> dict:
        now = datetime.now()
        last_24h = now - timedelta(hours=24)
        last_7d = now - timedelta(days=7)

        recent_findings = [
            f for f in self.metrics["findings"]
            if datetime.fromisoformat(f["timestamp"]) > last_24h
        ]

        weekly_findings = [
            f for f in self.metrics["findings"]
            if datetime.fromisoformat(f["timestamp"]) > last_7d
        ]

        severity_counts = defaultdict(int)
        for f in recent_findings:
            severity_counts[f.get("severity", "info")] += 1

        return {
            "total_findings": len(self.metrics["findings"]),
            "findings_24h": len(recent_findings),
            "findings_7d": len(weekly_findings),
            "severity_24h": dict(severity_counts),
            "total_scans": len(self.metrics["scans"]),
            "active_scans": sum(
                1 for s in self.metrics["scans"]
                if s.get("status") == "running"
            ),
            "targets_covered": len(set(
                f.get("target", "") for f in self.metrics["findings"]
            )),
            "last_updated": now.isoformat(),
        }

    def get_trend_data(self, days: int = 30) -> List[dict]:
        trends = []
        for i in range(days):
            date = (datetime.now() - timedelta(days=i)).strftime("%Y-%m-%d")
            day_stats = self.metrics["daily_stats"].get(date, {})
            trends.append({
                "date": date,
                "count": day_stats.get("findings_count", 0),
                "by_severity": day_stats.get("by_severity", {}),
            })
        return list(reversed(trends))

    def get_target_stats(self) -> List[dict]:
        target_findings = defaultdict(int)
        target_severity = defaultdict(lambda: defaultdict(int))

        for f in self.metrics["findings"]:
            target = f.get("target", "unknown")
            target_findings[target] += 1
            target_severity[target][f.get("severity", "info")] += 1

        return [
            {
                "target": t,
                "total": count,
                "by_severity": dict(target_severity[t]),
            }
            for t, count in sorted(target_findings.items(), key=lambda x: -x[1])
        ]
```

### Step 2: Build Health Checker

```python
# collectors/health_collector.py
import time
import requests
from typing import Dict, List


class HealthChecker:
    """Monitor infrastructure and service health."""

    def __init__(self):
        self.services = {}
        self.results = []

    def register_service(self, name: str, url: str, timeout: int = 5):
        self.services[name] = {"url": url, "timeout": timeout}

    def check_all(self) -> List[dict]:
        results = []
        for name, config in self.services.items():
            result = self._check_service(name, config)
            results.append(result)
            self.results.append(result)
        return results

    def _check_service(self, name: str, config: dict) -> dict:
        start = time.time()
        try:
            resp = requests.get(
                config["url"],
                timeout=config["timeout"],
            )
            latency = (time.time() - start) * 1000
            return {
                "service": name,
                "url": config["url"],
                "status": "healthy" if resp.status_code < 400 else "degraded",
                "status_code": resp.status_code,
                "latency_ms": round(latency, 2),
                "timestamp": time.time(),
            }
        except requests.RequestException as e:
            latency = (time.time() - start) * 1000
            return {
                "service": name,
                "url": config["url"],
                "status": "down",
                "status_code": 0,
                "latency_ms": round(latency, 2),
                "error": str(e),
                "timestamp": time.time(),
            }

    def get_uptime(self, service_name: str, hours: int = 24) -> float:
        cutoff = time.time() - (hours * 3600)
        relevant = [
            r for r in self.results
            if r["service"] == service_name and r["timestamp"] > cutoff
        ]
        if not relevant:
            return 100.0
        healthy = sum(1 for r in relevant if r["status"] == "healthy")
        return round((healthy / len(relevant)) * 100, 2)

    def get_summary(self) -> dict:
        services = {}
        for name in self.services:
            services[name] = {
                "status": "unknown",
                "uptime_24h": self.get_uptime(name, 24),
                "latency_ms": 0,
            }
            recent = [
                r for r in self.results
                if r["service"] == name
            ]
            if recent:
                latest = recent[-1]
                services[name]["status"] = latest["status"]
                services[name]["latency_ms"] = latest.get("latency_ms", 0)
        return services
```

### Step 3: Build the Flask Dashboard

```python
# app.py
import json
import os
from datetime import datetime
from pathlib import Path

from flask import Flask, render_template, jsonify, request
from flask_socketio import SocketIO, emit

from collectors.metrics_collector import MetricsCollector
from collectors.health_collector import HealthChecker

app = Flask(__name__)
app.config["SECRET_KEY"] = os.urandom(24).hex()
socketio = SocketIO(app, cors_allowed_origins="*", async_mode="threading")

collector = MetricsCollector()
health = HealthChecker()

# Register services to monitor
health.register_service("Nuclei", "http://localhost:8080/health")
health.register_service("httpx", "http://localhost:8081/health")
health.register_service("Dashboard API", "http://localhost:5000/api/health")


@app.route("/")
def index():
    return render_template("dashboard.html")


@app.route("/analytics")
def analytics():
    return render_template("analytics.html")


@app.route("/health")
def health_page():
    return render_template("health.html")


@app.route("/api/stats")
def api_stats():
    return jsonify(collector.get_realtime_stats())


@app.route("/api/trends")
def api_trends():
    days = request.args.get("days", 30, type=int)
    return jsonify(collector.get_trend_data(days))


@app.route("/api/targets")
def api_targets():
    return jsonify(collector.get_target_stats())


@app.route("/api/health")
def api_health():
    return jsonify(health.get_summary())


@app.route("/api/health/check", methods=["POST"])
def api_health_check():
    results = health.check_all()
    for r in results:
        collector.record_health_check(r["service"], r["status"], r["latency_ms"])
    return jsonify(results)


@socketio.on("connect")
def handle_connect():
    emit("connected", {"status": "connected"})


@socketio.on("request_stats")
def handle_stats_request():
    stats = collector.get_realtime_stats()
    emit("stats_update", stats)


def broadcast_stats():
    stats = collector.get_realtime_stats()
    socketio.emit("stats_update", stats)


if __name__ == "__main__":
    socketio.run(app, host="0.0.0.0", port=5000, debug=True)
```

### Step 4: Create Dashboard Template

```html
<!-- templates/base.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Security Dashboard{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.3.0/dist/chart.umd.min.js"></script>
    <script src="https://cdn.socket.io/4.6.0/socket.io.min.js"></script>
    <style>
        body { background: #0f172a; color: #e2e8f0; font-family: 'Segoe UI', sans-serif; }
        .sidebar { background: #1e293b; min-height: 100vh; padding-top: 20px; }
        .sidebar .nav-link { color: #94a3b8; padding: 10px 20px; border-radius: 6px; margin: 2px 8px; }
        .sidebar .nav-link:hover, .sidebar .nav-link.active { background: #334155; color: #fff; }
        .card { background: #1e293b; border: 1px solid #334155; border-radius: 12px; }
        .card-header { background: transparent; border-bottom: 1px solid #334155; color: #94a3b8; }
        .stat-value { font-size: 2rem; font-weight: bold; }
        .stat-label { font-size: 0.85rem; color: #64748b; text-transform: uppercase; }
        .stat-card { border-left: 4px solid; padding: 20px; }
        .border-critical { border-left-color: #ef4444 !important; }
        .border-high { border-left-color: #f97316 !important; }
        .border-medium { border-left-color: #eab308 !important; }
        .border-low { border-left-color: #22c55e !important; }
        .border-info { border-left-color: #3b82f6 !important; }
        .text-critical { color: #ef4444; }
        .text-high { color: #f97316; }
        .text-medium { color: #eab308; }
        .text-low { color: #22c55e; }
        .text-info { color: #3b82f6; }
        .status-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 8px; }
        .status-healthy { background: #22c55e; }
        .status-degraded { background: #eab308; }
        .status-down { background: #ef4444; }
        .status-unknown { background: #64748b; }
        .finding-table { max-height: 400px; overflow-y: auto; }
        .pulse { animation: pulse 2s infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <nav class="col-md-2 sidebar">
                <div class="text-center mb-4">
                    <h5 class="text-white">🛡️ Security Dashboard</h5>
                </div>
                <ul class="nav flex-column">
                    <li class="nav-item">
                        <a class="nav-link {% if request.path == '/' %}active{% endif %}" href="/">Overview</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {% if request.path == '/analytics' %}active{% endif %}" href="/analytics">Analytics</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {% if request.path == '/health' %}active{% endif %}" href="/health">Health</a>
                    </li>
                </ul>
                <div class="mt-4 px-3">
                    <small class="text-muted">Last Updated</small><br>
                    <span id="last-updated" class="text-white">--</span>
                </div>
            </nav>

            <main class="col-md-10 p-4">
                {% block content %}{% endblock %}
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const socket = io();
        socket.on('connect', () => console.log('Connected to dashboard'));
        socket.on('stats_update', (data) => {
            updateDashboard(data);
            document.getElementById('last-updated').textContent = new Date().toLocaleTimeString();
        });

        function fetchStats() {
            fetch('/api/stats')
                .then(r => r.json())
                .then(data => {
                    updateDashboard(data);
                    document.getElementById('last-updated').textContent = new Date().toLocaleTimeString();
                });
        }

        function updateDashboard(data) {
            document.getElementById('stat-total-findings').textContent = data.total_findings || 0;
            document.getElementById('stat-findings-24h').textContent = data.findings_24h || 0;
            document.getElementById('stat-active-scans').textContent = data.active_scans || 0;
            document.getElementById('stat-targets').textContent = data.targets_covered || 0;
            document.getElementById('stat-scans-total').textContent = data.total_scans || 0;
            document.getElementById('stat-findings-7d').textContent = data.findings_7d || 0;

            const sev = data.severity_24h || {};
            document.getElementById('stat-critical-24h').textContent = sev.critical || 0;
            document.getElementById('stat-high-24h').textContent = sev.high || 0;
            document.getElementById('stat-medium-24h').textContent = sev.medium || 0;
            document.getElementById('stat-low-24h').textContent = sev.low || 0;
        }

        fetchStats();
        setInterval(fetchStats, 30000);
    </script>
</body>
</html>
```

```html
<!-- templates/dashboard.html -->
{% extends "base.html" %}
{% block title %}Security Dashboard — Overview{% endblock %}
{% block content %}
<h2 class="mb-4">Dashboard Overview</h2>

<div class="row mb-4">
    <div class="col-md-3">
        <div class="card stat-card border-critical">
            <div class="stat-value text-critical" id="stat-total-findings">--</div>
            <div class="stat-label">Total Findings</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stat-card border-high">
            <div class="stat-value text-high" id="stat-findings-24h">--</div>
            <div class="stat-label">Findings (24h)</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stat-card border-medium">
            <div class="stat-value text-medium" id="stat-active-scans">--</div>
            <div class="stat-label">Active Scans</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stat-card border-info">
            <div class="stat-value text-info" id="stat-targets">--</div>
            <div class="stat-label">Targets Covered</div>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-3">
        <div class="card stat-card border-critical">
            <div class="stat-value text-critical" id="stat-critical-24h">--</div>
            <div class="stat-label">Critical (24h)</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stat-card border-high">
            <div class="stat-value text-high" id="stat-high-24h">--</div>
            <div class="stat-label">High (24h)</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stat-card border-medium">
            <div class="stat-value text-medium" id="stat-medium-24h">--</div>
            <div class="stat-label">Medium (24h)</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stat-card border-low">
            <div class="stat-value text-low" id="stat-low-24h">--</div>
            <div class="stat-label">Low (24h)</div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-8">
        <div class="card">
            <div class="card-header">Findings Trend (30 days)</div>
            <div class="card-body">
                <canvas id="trendChart" height="300"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card">
            <div class="card-header">Severity Distribution</div>
            <div class="card-body">
                <canvas id="severityChart" height="300"></canvas>
            </div>
        </div>
    </div>
</div>

<div class="row mt-4">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header">Top Targets</div>
            <div class="card-body finding-table">
                <table class="table table-dark table-striped" id="targetsTable">
                    <thead>
                        <tr>
                            <th>Target</th>
                            <th>Total Findings</th>
                            <th>Critical</th>
                            <th>High</th>
                            <th>Medium</th>
                            <th>Low</th>
                        </tr>
                    </thead>
                    <tbody id="targetsBody"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    let trendChart, severityChart;

    function initCharts() {
        const trendCtx = document.getElementById('trendChart').getContext('2d');
        trendChart = new Chart(trendCtx, {
            type: 'line',
            data: { labels: [], datasets: [{ label: 'Findings', data: [], borderColor: '#3b82f6', tension: 0.3, fill: true, backgroundColor: 'rgba(59,130,246,0.1)' }] },
            options: { responsive: true, plugins: { legend: { labels: { color: '#94a3b8' } } }, scales: { x: { ticks: { color: '#64748b' } }, y: { ticks: { color: '#64748b' } } } }
        });

        const sevCtx = document.getElementById('severityChart').getContext('2d');
        severityChart = new Chart(sevCtx, {
            type: 'doughnut',
            data: { labels: ['Critical', 'High', 'Medium', 'Low', 'Info'], datasets: [{ data: [0,0,0,0,0], backgroundColor: ['#ef4444','#f97316','#eab308','#22c55e','#3b82f6'] }] },
            options: { responsive: true, plugins: { legend: { labels: { color: '#94a3b8' } } } }
        });
    }

    function loadTrends() {
        fetch('/api/trends?days=30').then(r => r.json()).then(data => {
            trendChart.data.labels = data.map(d => d.date.slice(5));
            trendChart.data.datasets[0].data = data.map(d => d.count);
            trendChart.update();
        });
    }

    function loadTargets() {
        fetch('/api/targets').then(r => r.json()).then(data => {
            const tbody = document.getElementById('targetsBody');
            tbody.innerHTML = data.slice(0, 15).map(t => `
                <tr>
                    <td>${t.target}</td>
                    <td>${t.total}</td>
                    <td class="text-critical">${(t.by_severity || {}).critical || 0}</td>
                    <td class="text-high">${(t.by_severity || {}).high || 0}</td>
                    <td class="text-medium">${(t.by_severity || {}).medium || 0}</td>
                    <td class="text-low">${(t.by_severity || {}).low || 0}</td>
                </tr>
            `).join('');
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        initCharts();
        loadTrends();
        loadTargets();
    });
</script>
{% endblock %}
```

### Step 5: Health Check Dashboard Page

```html
<!-- templates/health.html -->
{% extends "base.html" %}
{% block title %}Security Dashboard — Health{% endblock %}
{% block content %}
<h2 class="mb-4">Service Health</h2>

<div class="row mb-4" id="healthCards">
    <div class="col-md-4"><div class="card p-4"><div class="text-center">
        <div class="status-dot status-unknown"></div>
        <h5>Loading...</h5>
    </div></div></div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header">Health Check History</div>
            <div class="card-body">
                <canvas id="healthChart" height="200"></canvas>
            </div>
        </div>
    </div>
</div>

<script>
    function loadHealth() {
        fetch('/api/health').then(r => r.json()).then(data => {
            const container = document.getElementById('healthCards');
            container.innerHTML = Object.entries(data).map(([name, info]) => `
                <div class="col-md-4">
                    <div class="card stat-card border-${info.status === 'healthy' ? 'low' : info.status === 'degraded' ? 'medium' : 'critical'}">
                        <div class="d-flex align-items-center mb-2">
                            <span class="status-dot status-${info.status}"></span>
                            <h5 class="mb-0">${name}</h5>
                        </div>
                        <div class="stat-label">Status: ${info.status.toUpperCase()}</div>
                        <div class="stat-label">Latency: ${info.latency_ms}ms</div>
                        <div class="stat-label">Uptime (24h): ${info.uptime_24h}%</div>
                    </div>
                </div>
            `).join('');
        });
    }

    function runHealthCheck() {
        fetch('/api/health/check', { method: 'POST' })
            .then(r => r.json())
            .then(() => loadHealth());
    }

    document.addEventListener('DOMContentLoaded', () => {
        loadHealth();
        setInterval(loadHealth, 60000);
    });
</script>
{% endblock %}
```

---

## 5. Tool Arsenal with Commands

### 5.1 Start Dashboard Server

```bash
python app.py
```

### 5.2 Quick Stats via API

```bash
# Get current stats
curl http://localhost:5000/api/stats

# Get trends
curl http://localhost:5000/api/trends?days=7

# Get health
curl http://localhost:5000/api/health

# Trigger health check
curl -X POST http://localhost:5000/api/health/check
```

### 5.3 Metrics Recorder for Python Scripts

```python
import requests


class DashboardRecorder:
    def __init__(self, base_url: str = "http://localhost:5000"):
        self.base_url = base_url

    def record_finding(self, finding: dict):
        """Call this after each scan finding to push to dashboard."""
        try:
            requests.post(f"{self.base_url}/api/finding", json=finding, timeout=5)
        except requests.RequestException:
            pass

    def record_scan_start(self, target: str, tool: str):
        requests.post(f"{self.base_url}/api/scan", json={
            "target": target,
            "tool": tool,
            "status": "running",
        }, timeout=5)

    def record_scan_end(self, target: str, tool: str, finding_count: int):
        requests.post(f"{self.base_url}/api/scan", json={
            "target": target,
            "tool": tool,
            "status": "completed",
            "finding_count": finding_count,
        }, timeout=5)
```

### 5.4 Standalone Metrics File Writer

```python
import json
from datetime import datetime
from pathlib import Path


class LocalMetrics:
    """Write metrics to JSON for dashboard consumption."""

    def __init__(self, path: str = "data/metrics.json"):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.data = self._load()

    def _load(self) -> dict:
        if self.path.exists():
            with open(self.path) as f:
                return json.load(f)
        return {"findings": [], "scans": [], "health": []}

    def _save(self):
        with open(self.path, "w") as f:
            json.dump(self.data, f, indent=2)

    def add_finding(self, target: str, severity: str, title: str):
        self.data["findings"].append({
            "target": target,
            "severity": severity,
            "title": title,
            "timestamp": datetime.now().isoformat(),
        })
        self._save()

    def add_scan(self, target: str, tool: str, status: str):
        self.data["scans"].append({
            "target": target,
            "tool": tool,
            "status": status,
            "timestamp": datetime.now().isoformat(),
        })
        self._save()

    def get_summary(self) -> dict:
        return {
            "total_findings": len(self.data["findings"]),
            "total_scans": len(self.data["scans"]),
        }
```

### 5.5 CLI Dashboard Status

```python
#!/usr/bin/env python3
"""Print dashboard metrics to terminal."""
import json
from pathlib import Path


def print_dashboard_status():
    metrics_file = Path("data/metrics.json")
    if not metrics_file.exists():
        print("No metrics data found. Start the dashboard first.")
        return

    with open(metrics_file) as f:
        data = json.load(f)

    findings = data.get("findings", [])
    scans = data.get("scans", [])

    print("=" * 50)
    print("  SECURITY DASHBOARD STATUS")
    print("=" * 50)
    print(f"  Total Findings:   {len(findings)}")
    print(f"  Total Scans:      {len(scans)}")

    sev_counts = {}
    for f in findings:
        s = f.get("severity", "info")
        sev_counts[s] = sev_counts.get(s, 0) + 1

    print(f"  Critical:         {sev_counts.get('critical', 0)}")
    print(f"  High:             {sev_counts.get('high', 0)}")
    print(f"  Medium:           {sev_counts.get('medium', 0)}")
    print(f"  Low:              {sev_counts.get('low', 0)}")
    print("=" * 50)


if __name__ == "__main__":
    print_dashboard_status()
```

---

## 6. Real-World Examples

### Example 1: Live Nuclei Scan Dashboard

```python
import subprocess
import json
import threading
from app import socketio, collector


def run_nuclei_with_live_dashboard(target: str, templates: str):
    collector.record_scan({"target": target, "tool": "nuclei", "status": "running"})
    socketio.emit("stats_update", collector.get_realtime_stats())

    cmd = ["nuclei", "-target", target, "-t", templates, "-jsonl", "-silent"]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True)

    finding_count = 0
    for line in process.stdout:
        line = line.strip()
        if not line:
            continue
        try:
            finding = json.loads(line)
            record = {
                "target": finding.get("host", target),
                "severity": finding.get("info", {}).get("severity", "info"),
                "title": finding.get("info", {}).get("name", "Unknown"),
            }
            collector.record_finding(record)
            finding_count += 1

            if finding_count % 5 == 0:
                socketio.emit("stats_update", collector.get_realtime_stats())
        except json.JSONDecodeError:
            continue

    process.wait()
    collector.record_scan({"target": target, "tool": "nuclei", "status": "completed"})
    socketio.emit("stats_update", collector.get_realtime_stats())
    print(f"Scan complete. {finding_count} findings.")
```

### Example 2: Multi-Tool Aggregate Dashboard

```python
import subprocess
import json
import threading
from app import collector


def scan_with_httpx(targets_file: str):
    cmd = ["httpx", "-l", targets_file, "-json", "-silent"]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True)

    for line in process.stdout:
        try:
            data = json.loads(line.strip())
            if data.get("tech"):
                collector.record_finding({
                    "target": data.get("url", ""),
                    "severity": "info",
                    "title": f"Technology detected: {', '.join(data['tech'][:3])}",
                })
        except (json.JSONDecodeError, KeyError):
            continue

    process.wait()


def run_parallel_scans(targets_file: str):
    t1 = threading.Thread(target=scan_with_httpx, args=(targets_file,))
    t2 = threading.Thread(target=lambda: subprocess.run([
        "nuclei", "-target", targets_file, "-jsonl", "-silent"
    ], stdout=subprocess.PIPE))

    t1.start()
    t2.start()
    t1.join()
    t2.join()
```

### Example 3: Scheduled Dashboard Refresh

```python
import schedule
import time
from app import collector, health, socketio


def refresh_dashboard():
    health_results = health.check_all()
    for r in health_results:
        collector.record_health_check(r["service"], r["status"], r["latency_ms"])

    stats = collector.get_realtime_stats()
    socketio.emit("stats_update", stats)
    print(f"Dashboard refreshed: {stats['total_findings']} findings")


schedule.every(5).minutes.do(refresh_dashboard)

while True:
    schedule.run_pending()
    time.sleep(1)
```

---

## 7. Common Pitfalls

### Pitfall 1: Dashboard Performance with Large Datasets

**Problem**: 100K+ findings slow dashboard loading.

**Solution**: Pagination and aggregation at the database level.

```python
@app.route("/api/stats")
def api_stats():
    # Only aggregate, don't load all findings into memory
    return jsonify({
        "total_findings": len(collector.metrics["findings"]),
        "findings_24h": count_recent(collector.metrics["findings"], hours=24),
    })
```

### Pitfall 2: WebSocket Connection Drops

**Problem**: Real-time updates stop after inactivity.

**Solution**: Reconnection logic and heartbeat.

```javascript
// Client-side reconnection
socket.on('disconnect', () => {
    setTimeout(() => socket.connect(), 3000);
});
socket.on('connect', () => {
    socket.emit('request_stats');
});
```

### Pitfall 3: Race Conditions in Metrics Collection

**Problem**: Multiple scan threads write to same metrics file.

**Solution**: Use file locks or thread-safe storage.

```python
import fcntl  # Linux only
# For Windows, use threading.Lock
import threading
lock = threading.Lock()

def safe_record(finding):
    with lock:
        collector.record_finding(finding)
```

### Pitfall 4: Memory Bloat from Unbounded History

**Problem**: Metrics file grows to hundreds of MB.

**Solution**: Rolling window and periodic cleanup.

```python
def cleanup_old_data(max_days: int = 90):
    cutoff = (datetime.now() - timedelta(days=max_days)).isoformat()
    collector.metrics["findings"] = [
        f for f in collector.metrics["findings"]
        if f["timestamp"] > cutoff
    ]
    collector._save_metrics()
```

### Pitfall 5: No Authentication on Dashboard

**Problem**: Dashboard exposed without auth, anyone can see findings.

**Solution**: Add basic auth or IP whitelist.

```python
from functools import wraps
from flask import request, Response

def check_auth(username, password):
    return username == "admin" and password == os.getenv("DASHBOARD_PASS", "")

def auth_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return Response("Unauthorized", 401, {"WWW-Authenticate": "Basic realm=Restricted"})
        return f(*args, **kwargs)
    return decorated

@app.route("/api/stats")
@auth_required
def api_stats():
    return jsonify(collector.get_realtime_stats())
```

---

## 8. Advanced Techniques

### 8.1 Real-Time Alert Overlay

```python
from flask_socketio import emit


def broadcast_alert(alert: dict):
    """Push alert to connected dashboard clients."""
    severity = alert.get("severity", "info")
    socketio.emit("alert", {
        "title": alert.get("title", "Security Alert"),
        "severity": severity,
        "target": alert.get("target", ""),
        "timestamp": datetime.now().isoformat(),
    })
```

```javascript
// Client-side alert handling
socket.on('alert', (data) => {
    const alertHtml = `
        <div class="alert alert-${data.severity === 'critical' ? 'danger' : 'warning'} alert-dismissible fade show">
            <strong>[${data.severity.toUpperCase()}]</strong> ${data.title} — ${data.target}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>`;
    document.getElementById('alert-container').insertAdjacentHTML('afterbegin', alertHtml);
});
```

### 8.2 Performance Metrics Collection

```python
import psutil
import time
from collectors.metrics_collector import MetricsCollector


def collect_system_metrics(collector: MetricsCollector):
    cpu = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage("/")

    collector.record_health_check("CPU", "healthy" if cpu < 80 else "degraded", cpu)
    collector.record_health_check("Memory", "healthy" if memory.percent < 85 else "degraded", memory.percent)
    collector.record_health_check("Disk", "healthy" if disk.percent < 90 else "degraded", disk.percent)
```

### 8.3 Custom Chart Components

```javascript
// charts.js
function createFindingTimelineChart(canvasId, data) {
    const ctx = document.getElementById(canvasId).getContext('2d');
    return new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.map(d => d.date),
            datasets: [
                { label: 'Critical', data: data.map(d => d.critical), backgroundColor: '#ef4444' },
                { label: 'High', data: data.map(d => d.high), backgroundColor: '#f97316' },
                { label: 'Medium', data: data.map(d => d.medium), backgroundColor: '#eab308' },
                { label: 'Low', data: data.map(d => d.low), backgroundColor: '#22c55e' },
            ]
        },
        options: {
            responsive: true,
            plugins: { legend: { labels: { color: '#94a3b8' } } },
            scales: {
                x: { stacked: true, ticks: { color: '#64748b' } },
                y: { stacked: true, ticks: { color: '#64748b' } },
            }
        }
    });
}

function createTargetHeatmap(canvasId, targets) {
    const ctx = document.getElementById(canvasId).getContext('2d');
    const colors = targets.map(t => t.total > 10 ? '#ef4444' : t.total > 5 ? '#f97316' : '#22c55e');
    return new Chart(ctx, {
        type: 'bar',
        data: {
            labels: targets.map(t => t.target.substring(0, 30)),
            datasets: [{ label: 'Findings', data: targets.map(t => t.total), backgroundColor: colors }]
        },
        options: { indexAxis: 'y', responsive: true }
    });
}
```

### 8.4 Dashboard Configuration API

```python
@app.route("/api/config", methods=["GET", "POST"])
def dashboard_config():
    config_path = Path("data/dashboard_config.json")

    if request.method == "GET":
        if config_path.exists():
            with open(config_path) as f:
                return jsonify(json.load(f))
        return jsonify({"refresh_interval": 30, "theme": "dark"})

    data = request.get_json()
    with open(config_path, "w") as f:
        json.dump(data, f, indent=2)
    return jsonify({"status": "saved"})
```

---

## 9. Reporting Template

### Dashboard Health Report

```python
def generate_dashboard_report() -> str:
    stats = collector.get_realtime_stats()
    health_summary = health.get_summary()
    targets = collector.get_target_stats()
    trends = collector.get_trend_data(days=7)

    report = f"""# Dashboard Health Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Current Metrics
| Metric | Value |
|--------|-------|
| Total Findings | {stats['total_findings']} |
| Findings (24h) | {stats['findings_24h']} |
| Findings (7d) | {stats['findings_7d']} |
| Active Scans | {stats['active_scans']} |
| Targets Covered | {stats['targets_covered']} |

## Service Health
| Service | Status | Latency | Uptime (24h) |
|---------|--------|---------|--------------|
"""
    for name, info in health_summary.items():
        report += f"| {name} | {info['status']} | {info['latency_ms']}ms | {info['uptime_24h']}% |\n"

    report += "\n## Top 10 Targets\n| Target | Findings | Critical | High | Medium |\n|--------|----------|----------|------|--------|\n"
    for t in targets[:10]:
        sev = t.get("by_severity", {})
        report += f"| {t['target']} | {t['total']} | {sev.get('critical',0)} | {sev.get('high',0)} | {sev.get('medium',0)} |\n"

    report += "\n## Daily Trend (7 days)\n| Date | Findings |\n|------|----------|\n"
    for t in trends:
        report += f"| {t['date']} | {t['count']} |\n"

    output_path = Path("output/dashboard_report.md")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(report)
    return str(output_path)
```

---

## 10. Quick Reference

### API Endpoints

```
GET  /                     # Dashboard overview
GET  /analytics            # Analytics page
GET  /health               # Health check page
GET  /api/stats            # Real-time statistics JSON
GET  /api/trends?days=30   # Trend data JSON
GET  /api/targets          # Target statistics JSON
GET  /api/health           # Service health JSON
POST /api/health/check     # Trigger health check
```

### Start Commands

```bash
# Start dashboard
python app.py

# Start with custom port
python -c "from app import socketio, app; socketio.run(app, port=8080)"

# Record finding from script
python -c "from collectors.metrics_collector import MetricsCollector; c=MetricsCollector(); c.record_finding({'target':'test.com','severity':'high','title':'XSS'})"
```

### Key Metrics

```
total_findings          All-time finding count
findings_24h            Findings in last 24 hours
findings_7d             Findings in last 7 days
active_scans            Currently running scans
targets_covered         Unique targets with findings
total_scans             All-time scan count
severity_24h            Severity breakdown (24h)
service_health          Service status map
```

### File Structure

```
dashboard/
├── app.py                      # Flask + SocketIO server
├── config.yaml                 # Configuration
├── static/
│   ├── css/dashboard.css       # Dashboard styles
│   └── js/
│       ├── dashboard.js        # Main dashboard logic
│       └── charts.js           # Chart components
├── templates/
│   ├── base.html               # Base layout
│   ├── dashboard.html          # Overview page
│   ├── analytics.html          # Analytics page
│   └── health.html             # Health check page
├── collectors/
│   ├── metrics_collector.py    # Metrics aggregation
│   ├── health_collector.py     # Service health checks
│   └── scan_collector.py       # Scan progress tracking
└── data/
    └── metrics.json            # Stored metrics
```

### Dashboard Design Principles

1. **Dark theme**: Reduces eye strain during long sessions
2. **Real-time updates**: WebSocket for live data push
3. **Responsive**: Works on mobile for on-the-go checks
4. **Low latency**: API responses under 100ms
5. **Accessible**: Color-blind friendly severity colors
6. **Modular**: Cards and widgets can be rearranged
7. **Exportable**: All data available via API for reporting
