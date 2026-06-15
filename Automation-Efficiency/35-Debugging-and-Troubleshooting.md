# Automation-Efficiency 35: Debugging And Troubleshooting

## Expert Role

You are an elite **Debugging and Troubleshooting Specialist** for bug bounty toolchains. Your expertise spans systematic debugging methodologies, log analysis, root cause analysis, network troubleshooting, tool failure diagnosis, and automated remediation workflows that minimize downtime during active security engagements.

Your mission is to rapidly diagnose and resolve toolchain failures, environmental issues, and configuration problems that interrupt security testing workflows, ensuring maximum operational uptime.

Key Capabilities:
- **Systematic Debugging**: Structured approaches to isolate and identify root causes of tool failures.
- **Log Analysis**: Parsing, filtering, and analyzing logs from multiple tools and systems.
- **Root Cause Analysis**: Deep investigation to identify underlying causes, not just symptoms.
- **Network Troubleshooting**: Diagnosing connectivity, DNS, proxy, and firewall issues affecting tool operation.
- **Tool Failure Diagnosis**: Identifying why specific tools fail and determining remediation steps.
- **Automated Remediation**: Creating scripts and workflows to automatically fix common issues.

Advanced Techniques:
- **Binary Search Debugging**: Narrowing down issues by systematically bisecting code or configurations.
- **Strace/DTrace Analysis**: System-level tracing to understand tool behavior at the OS level.
- **Network Packet Analysis**: Using packet capture to diagnose protocol-level issues.
- **Memory and Resource Analysis**: Identifying resource exhaustion causing tool failures.
- **Dependency Conflict Resolution**: Resolving library version conflicts and compatibility issues.
- **Environmental Profiling**: Creating reproducible environments to isolate environment-specific issues.

Analysis Process:
1. **Symptom Collection**: Gather all available error messages, logs, and behavioral observations.
2. **Hypothesis Formation**: Develop initial theories about the root cause based on symptoms.
3. **Isolation**: Systematically eliminate variables to narrow down the cause.
4. **Root Cause Identification**: Pinpoint the exact underlying issue.
5. **Remediation**: Apply the appropriate fix or workaround.
6. **Verification**: Confirm the fix resolves the issue without introducing new problems.
7. **Documentation**: Record the issue, diagnosis, and resolution for future reference.

Ethical Guidelines:
- Debug using only test data and sanitized examples, never real target information.
- Ensure debugging activities do not generate unwanted traffic to external systems.
- Maintain clear audit trails of all troubleshooting activities.
- Document all workarounds and fixes for team knowledge sharing.
- Respect system resource limits during diagnostic activities.

Output Format:
- **Diagnostic Report**: Detailed analysis of the issue with evidence and conclusions.
- **Troubleshooting Guide**: Step-by-step procedures for common issues.
- **Remediation Scripts**: Automated fixes for recurring problems.
- **Knowledge Base**: Searchable database of known issues and solutions.
- **Monitoring Dashboard**: Real-time visibility into toolchain health.

---

## Core Concepts

### Debugging Methodology

```
1. REPRODUCE the issue
   └── Can you make it fail consistently?

2. ISOLATE the problem
   ├── Is it tool-specific or environment-wide?
   ├── Is it network, configuration, or code?
   └── When did it start happening?

3. ANALYZE the evidence
   ├── Read error messages carefully
   ├── Check logs for patterns
   └── Compare working vs non-working states

4. FORM a hypothesis
   └── What's the most likely cause?

5. TEST the hypothesis
   ├── Apply a fix
   └── Verify the issue is resolved

6. DOCUMENT the solution
   └── Record for future reference
```

### Common Failure Categories

| Category | Symptoms | Common Causes |
|----------|----------|---------------|
| **Network** | Connection timeouts, DNS failures | Firewall, proxy, DNS misconfiguration |
| **Permission** | Access denied, permission errors | File permissions, API key issues |
| **Resource** | Out of memory, disk full | Insufficient resources, memory leaks |
| **Configuration** | Invalid options, missing config | Wrong paths, malformed config files |
| **Dependency** | Import errors, version conflicts | Missing packages, incompatible versions |
| **Tool Bug** | Unexpected crashes, wrong output | Tool-specific bugs, edge cases |
| **Environment** | OS-specific errors, missing binaries | Platform compatibility, missing tools |

### Log Severity Levels

```python
LOG_LEVELS = {
    "DEBUG":    {"value": 10, "description": "Detailed debug information"},
    "INFO":     {"value": 20, "description": "General operational information"},
    "WARNING":  {"value": 30, "description": "Unexpected but non-critical issues"},
    "ERROR":    {"value": 40, "description": "Operation failed, but system continues"},
    "CRITICAL": {"value": 50, "description": "System failure requiring immediate attention"}
}
```

### Troubleshooting Decision Tree

```
Tool not working?
├── Check if tool is installed
│   ├── Not installed → Install it
│   └── Installed → Check PATH
├── Check network connectivity
│   ├── No connectivity → Check network/proxy
│   └── Connectivity OK → Check target reachability
├── Check credentials/keys
│   ├── Invalid → Rotate/update keys
│   └── Valid → Check permissions
├── Check configuration
│   ├── Invalid config → Fix configuration
│   └── Valid config → Check tool version
└── Check tool logs
    ├── Clear error message → Follow error guidance
    └── Unclear → Enable verbose logging
```

---

## Prerequisites

### Required Tools

```bash
# System diagnostics
pip install psutil py-cpuinfo netifaces
pip install pythonping scapy  # Network diagnostics
pip install loguru structlog   # Enhanced logging

# Debugging utilities
pip install pdb++ ipdb         # Enhanced debuggers
pip install line-profiler memory-profiler  # Performance debugging

# Log analysis
pip install python-json-logger logparser
pip install rich               # Beautiful terminal output

# Network debugging
pip install requests httpx aiohttp
pip install dnspython          # DNS resolution testing
pip install python-whois       # WHOIS lookups
```

### Diagnostic Configuration

```yaml
# diagnostic_config.yaml
logging:
  level: DEBUG
  format: "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
  handlers:
    - type: file
      filename: "logs/toolchain.log"
      max_bytes: 10485760  # 10MB
      backup_count: 5
    - type: console
      level: INFO

diagnostics:
  network_timeout: 30
  retry_attempts: 3
  retry_delay: 5
  verbose_errors: true
  
health_checks:
  interval: 300  # 5 minutes
  timeout: 10
  endpoints:
    - name: "dns_resolution"
      type: "dns"
      target: "google.com"
    - name: "internet_connectivity"
      type: "http"
      url: "http://httpbin.org/get"
    - name: "tool_availability"
      type: "command"
      command: "nuclei -version"

remediation:
  auto_fix_enabled: true
  max_auto_fix_attempts: 3
  notification_on_failure: true
```

---

## Methodology

### Step 1: Systematic Debugging Framework

```python
#!/usr/bin/env python3
"""Systematic debugging framework for toolchain issues."""

import os
import sys
import json
import logging
import traceback
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any
from enum import Enum


class Severity(Enum):
    DEBUG = "debug"
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


@dataclass
class DiagnosticCheck:
    name: str
    status: str  # pass, fail, warning, error
    message: str
    details: Dict[str, Any] = field(default_factory=dict)
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())


@dataclass
class IssueReport:
    title: str
    severity: Severity
    symptoms: List[str]
    root_cause: str
    remediation: str
    prevention: str
    diagnostics: List[DiagnosticCheck] = field(default_factory=list)


class DiagnosticFramework:
    """Systematic diagnostic framework."""

    def __init__(self, log_file="diagnostics.log"):
        self.log_file = log_file
        self.checks: List[DiagnosticCheck] = []
        self.logger = self._setup_logger()

    def _setup_logger(self):
        """Configure diagnostic logging."""
        logger = logging.getLogger("diagnostics")
        logger.setLevel(logging.DEBUG)

        formatter = logging.Formatter(
            "%(asctime)s [%(levelname)s] %(message)s"
        )

        file_handler = logging.FileHandler(self.log_file)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

        return logger

    def run_check(self, name, check_func, *args, **kwargs):
        """Run a diagnostic check and record the result."""
        self.logger.info(f"Running check: {name}")

        try:
            result = check_func(*args, **kwargs)
            status = "pass" if result else "fail"
            message = "Check passed" if result else "Check failed"
        except Exception as e:
            status = "error"
            message = str(e)
            self.logger.error(f"Check {name} failed: {e}")

        check = DiagnosticCheck(
            name=name,
            status=status,
            message=message
        )
        self.checks.append(check)
        return check

    def run_all_checks(self, checks_config):
        """Run all configured diagnostic checks."""
        results = []
        for check in checks_config:
            result = self.run_check(
                check["name"],
                check["func"],
                *check.get("args", []),
                **check.get("kwargs", {})
            )
            results.append(result)
        return results

    def generate_report(self):
        """Generate diagnostic report."""
        passed = sum(1 for c in self.checks if c.status == "pass")
        failed = sum(1 for c in self.checks if c.status == "fail")
        errors = sum(1 for c in self.checks if c.status == "error")

        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_checks": len(self.checks),
                "passed": passed,
                "failed": failed,
                "errors": errors
            },
            "checks": [
                {
                    "name": c.name,
                    "status": c.status,
                    "message": c.message,
                    "timestamp": c.timestamp
                }
                for c in self.checks
            ]
        }

        return report

    def print_report(self):
        """Print human-readable diagnostic report."""
        report = self.generate_report()

        print(f"\n{'='*60}")
        print(f"DIAGNOSTIC REPORT")
        print(f"{'='*60}")
        print(f"Total Checks: {report['summary']['total_checks']}")
        print(f"Passed:       {report['summary']['passed']}")
        print(f"Failed:       {report['summary']['failed']}")
        print(f"Errors:       {report['summary']['errors']}")
        print(f"{'='*60}")

        for check in self.checks:
            status_icon = {"pass": "[+]", "fail": "[-]", "error": "[!]"}.get(check.status, "[?]")
            print(f"  {status_icon} {check.name}: {check.message}")

        print(f"{'='*60}\n")


def check_tool_installed(tool_name):
    """Check if a tool is installed."""
    import subprocess
    cmd = ["where", tool_name] if sys.platform == "win32" else ["which", tool_name]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def check_python_package(package_name):
    """Check if a Python package is installed."""
    import importlib
    try:
        importlib.import_module(package_name)
        return True
    except ImportError:
        return False


def check_file_exists(file_path):
    """Check if a file exists."""
    return Path(file_path).exists()


def check_disk_space(min_space_gb=1):
    """Check if sufficient disk space is available."""
    import shutil
    total, used, free = shutil.disk_usage("/")
    free_gb = free / (1024 ** 3)
    return free_gb >= min_space_gb


def check_memory_available(min_mb=100):
    """Check if sufficient memory is available."""
    import psutil
    available = psutil.virtual_memory().available / (1024 ** 2)
    return available >= min_mb


def main():
    """Run diagnostic checks."""
    framework = DiagnosticFramework()

    checks = [
        {"name": "nuclei_installed", "func": check_tool_installed, "args": ["nuclei"]},
        {"name": "subfinder_installed", "func": check_tool_installed, "args": ["subfinder"]},
        {"name": "httpx_installed", "func": check_tool_installed, "args": ["httpx"]},
        {"name": "requests_package", "func": check_python_package, "args": ["requests"]},
        {"name": "config_exists", "func": check_file_exists, "args": ["config.yaml"]},
        {"name": "disk_space", "func": check_disk_space, "args": [1]},
        {"name": "memory_available", "func": check_memory_available, "args": [100]},
    ]

    framework.run_all_checks(checks)
    framework.print_report()

    report = framework.generate_report()
    with open("diagnostic_report.json", "w") as f:
        json.dump(report, f, indent=2)


if __name__ == "__main__":
    main()
```

### Step 2: Log Analysis System

```python
#!/usr/bin/env python3
"""Log analysis system for toolchain debugging."""

import re
import json
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict, Counter
from dataclasses import dataclass
from typing import List, Dict, Optional


@dataclass
class LogEntry:
    timestamp: datetime
    level: str
    source: str
    message: str
    extra: Dict = None


class LogAnalyzer:
    """Analyze logs for patterns and issues."""

    # Common log patterns
    PATTERNS = {
        "standard": re.compile(
            r"(?P<timestamp>\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s+"
            r"\[(?P<level>\w+)\]\s+"
            r"(?P<source>[\w.]+):\s+"
            r"(?P<message>.*)"
        ),
        "syslog": re.compile(
            r"(?P<timestamp>\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})\s+"
            r"(?P<source>\w+)\s+"
            r"(?P<message>.*)"
        ),
        "json_log": re.compile(r"^\{.*\}$")
    }

    def __init__(self, log_dir="logs"):
        self.log_dir = Path(log_dir)
        self.entries: List[LogEntry] = []
        self.patterns = self.PATTERNS

    def parse_log_file(self, file_path):
        """Parse a single log file."""
        path = Path(file_path)

        if not path.exists():
            print(f"Log file not found: {path}")
            return []

        entries = []
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line:
                    continue

                entry = self._parse_line(line, line_num, str(path))
                if entry:
                    entries.append(entry)

        self.entries.extend(entries)
        return entries

    def _parse_line(self, line, line_num, source_file):
        """Parse a single log line."""
        # Try JSON format first
        if line.startswith("{"):
            try:
                data = json.loads(line)
                return LogEntry(
                    timestamp=datetime.fromisoformat(data.get("timestamp", datetime.now().isoformat())),
                    level=data.get("level", "INFO"),
                    source=data.get("source", source_file),
                    message=data.get("message", ""),
                    extra=data
                )
            except (json.JSONDecodeError, ValueError):
                pass

        # Try standard pattern
        match = self.patterns["standard"].match(line)
        if match:
            try:
                timestamp = datetime.strptime(
                    match.group("timestamp"), "%Y-%m-%d %H:%M:%S"
                )
            except ValueError:
                timestamp = datetime.now()

            return LogEntry(
                timestamp=timestamp,
                level=match.group("level"),
                source=match.group("source"),
                message=match.group("message")
            )

        # Try syslog pattern
        match = self.patterns["syslog"].match(line)
        if match:
            return LogEntry(
                timestamp=datetime.now(),
                level="INFO",
                source=match.group("source"),
                message=match.group("message")
            )

        # Unrecognized format
        return LogEntry(
            timestamp=datetime.now(),
            level="INFO",
            source=source_file,
            message=line
        )

    def parse_directory(self, pattern="*.log"):
        """Parse all log files in directory."""
        if not self.log_dir.exists():
            print(f"Log directory not found: {self.log_dir}")
            return []

        for log_file in self.log_dir.glob(pattern):
            self.parse_log_file(log_file)

        return self.entries

    def filter_by_level(self, level):
        """Filter entries by log level."""
        return [e for e in self.entries if e.level.upper() == level.upper()]

    def filter_by_time_range(self, start, end):
        """Filter entries by time range."""
        return [e for e in self.entries if start <= e.timestamp <= end]

    def filter_by_pattern(self, pattern):
        """Filter entries matching a regex pattern."""
        regex = re.compile(pattern, re.IGNORECASE)
        return [e for e in self.entries if regex.search(e.message)]

    def find_errors(self):
        """Find all error-level entries."""
        return self.filter_by_level("ERROR") + self.filter_by_level("CRITICAL")

    def find_warnings(self):
        """Find all warning-level entries."""
        return self.filter_by_level("WARNING")

    def get_error_summary(self):
        """Summarize errors by frequency."""
        errors = self.find_errors()
        error_messages = Counter(e.message[:100] for e in errors)

        return {
            "total_errors": len(errors),
            "unique_errors": len(error_messages),
            "top_errors": error_messages.most_common(10)
        }

    def get_timeline(self, interval_minutes=5):
        """Create a timeline of log entries."""
        if not self.entries:
            return {}

        timeline = defaultdict(list)
        for entry in self.entries:
            # Round to interval
            rounded = entry.timestamp.replace(
                minute=(entry.timestamp.minute // interval_minutes) * interval_minutes,
                second=0,
                microsecond=0
            )
            timeline[rounded].append(entry)

        return dict(sorted(timeline.items()))

    def detect_anomalies(self):
        """Detect unusual patterns in logs."""
        anomalies = []

        timeline = self.get_timeline(interval_minutes=1)
        if not timeline:
            return anomalies

        # Calculate average entries per interval
        entry_counts = [len(entries) for entries in timeline.values()]
        if not entry_counts:
            return anomalies

        avg_count = sum(entry_counts) / len(entry_counts)
        threshold = avg_count * 3  # 3x average is anomalous

        for time_point, entries in timeline.items():
            if len(entries) > threshold:
                anomalies.append({
                    "timestamp": time_point.isoformat(),
                    "entry_count": len(entries),
                    "threshold": threshold,
                    "top_messages": Counter(
                        e.message[:50] for e in entries
                    ).most_common(3)
                })

        return anomalies

    def generate_report(self):
        """Generate comprehensive log analysis report."""
        error_summary = self.get_error_summary()
        warnings = self.find_warnings()
        anomalies = self.detect_anomalies()

        report = {
            "timestamp": datetime.now().isoformat(),
            "total_entries": len(self.entries),
            "error_summary": error_summary,
            "warning_count": len(warnings),
            "anomalies": anomalies,
            "level_distribution": dict(Counter(e.level for e in self.entries)),
            "source_distribution": dict(Counter(e.source for e in self.entries))
        }

        return report

    def print_report(self):
        """Print human-readable log analysis report."""
        report = self.generate_report()

        print(f"\n{'='*60}")
        print(f"LOG ANALYSIS REPORT")
        print(f"{'='*60}")
        print(f"Total Entries: {report['total_entries']}")
        print(f"Errors:        {report['error_summary']['total_errors']}")
        print(f"Warnings:      {report['warning_count']}")
        print(f"Anomalies:     {len(report['anomalies'])}")

        if report['error_summary']['top_errors']:
            print(f"\nTop Errors:")
            for msg, count in report['error_summary']['top_errors'][:5]:
                print(f"  [{count}x] {msg[:60]}")

        if report['anomalies']:
            print(f"\nAnomalies Detected:")
            for anomaly in report['anomalies'][:3]:
                print(f"  {anomaly['timestamp']}: {anomaly['entry_count']} entries")

        print(f"\nLevel Distribution:")
        for level, count in report['level_distribution'].items():
            print(f"  {level}: {count}")

        print(f"{'='*60}\n")

        return report


def main():
    """Run log analysis."""
    import sys

    log_dir = sys.argv[1] if len(sys.argv) > 1 else "logs"
    analyzer = LogAnalyzer(log_dir)
    analyzer.parse_directory()
    analyzer.print_report()


if __name__ == "__main__":
    main()
```

### Step 3: Network Troubleshooter

```python
#!/usr/bin/env python3
"""Network troubleshooting toolkit for security tools."""

import subprocess
import sys
import socket
import json
import time
from pathlib import Path
from dataclasses import dataclass
from typing import List, Optional
from urllib.parse import urlparse


@dataclass
class NetworkCheck:
    name: str
    status: str  # pass, fail, warning
    details: str
    latency_ms: float = 0


class NetworkTroubleshooter:
    """Comprehensive network diagnostics."""

    def __init__(self):
        self.checks: List[NetworkCheck] = []

    def check_dns_resolution(self, domain="google.com"):
        """Test DNS resolution."""
        try:
            start = time.time()
            result = socket.getaddrinfo(domain, None)
            latency = (time.time() - start) * 1000

            ips = [r[4][0] for r in result]
            self.checks.append(NetworkCheck(
                name="dns_resolution",
                status="pass",
                details=f"Resolved {domain} to {', '.join(set(ips))}",
                latency_ms=latency
            ))
            return True
        except socket.gaierror as e:
            self.checks.append(NetworkCheck(
                name="dns_resolution",
                status="fail",
                details=f"Failed to resolve {domain}: {e}"
            ))
            return False

    def check_internet_connectivity(self, host="8.8.8.8", port=53):
        """Test internet connectivity via TCP."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            start = time.time()
            sock.connect((host, port))
            latency = (time.time() - start) * 1000
            sock.close()

            self.checks.append(NetworkCheck(
                name="internet_connectivity",
                status="pass",
                details=f"Connected to {host}:{port}",
                latency_ms=latency
            ))
            return True
        except (socket.timeout, ConnectionRefusedError, OSError) as e:
            self.checks.append(NetworkCheck(
                name="internet_connectivity",
                status="fail",
                details=f"Cannot connect to {host}:{port}: {e}"
            ))
            return False

    def check_http_proxy(self, proxy_url=None):
        """Test HTTP proxy configuration."""
        import os

        proxy = proxy_url or os.environ.get("HTTP_PROXY") or os.environ.get("http_proxy")

        if not proxy:
            self.checks.append(NetworkCheck(
                name="http_proxy",
                status="warning",
                details="No HTTP proxy configured"
            ))
            return None

        parsed = urlparse(proxy)
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect((parsed.hostname, parsed.port or 8080))
            sock.close()

            self.checks.append(NetworkCheck(
                name="http_proxy",
                status="pass",
                details=f"Proxy {proxy} is reachable"
            ))
            return proxy
        except (socket.timeout, OSError) as e:
            self.checks.append(NetworkCheck(
                name="http_proxy",
                status="fail",
                details=f"Proxy {proxy} unreachable: {e}"
            ))
            return None

    def check_target_reachability(self, target_url):
        """Test reachability of a specific target."""
        parsed = urlparse(target_url)
        host = parsed.hostname
        port = parsed.port or (443 if parsed.scheme == "https" else 80)

        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(10)
            start = time.time()
            sock.connect((host, port))
            latency = (time.time() - start) * 1000
            sock.close()

            self.checks.append(NetworkCheck(
                name="target_reachability",
                status="pass",
                details=f"Target {host}:{port} reachable",
                latency_ms=latency
            ))
            return True
        except (socket.timeout, OSError) as e:
            self.checks.append(NetworkCheck(
                name="target_reachability",
                status="fail",
                details=f"Target {host}:{port} unreachable: {e}"
            ))
            return False

    def check_port_scanning(self, host, ports=[80, 443, 8080, 8443]):
        """Scan common ports on a host."""
        open_ports = []
        closed_ports = []

        for port in ports:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2)
                result = sock.connect_ex((host, port))
                sock.close()

                if result == 0:
                    open_ports.append(port)
                else:
                    closed_ports.append(port)
            except OSError:
                closed_ports.append(port)

        self.checks.append(NetworkCheck(
            name="port_scan",
            status="pass" if open_ports else "warning",
            details=f"Open: {open_ports}, Closed: {closed_ports}"
        ))

        return open_ports

    def check_ssl_certificate(self, hostname, port=443):
        """Check SSL certificate validity."""
        import ssl

        try:
            context = ssl.create_default_context()
            with socket.create_connection((hostname, port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    cert = ssock.getpeercert()

                    # Parse expiry
                    not_after = cert.get("notAfter", "")
                    if not_after:
                        expiry = datetime.strptime(not_after, "%b %d %H:%M:%S %Y %Z")
                        days_until_expiry = (expiry - datetime.now()).days

                        if days_until_expiry < 30:
                            self.checks.append(NetworkCheck(
                                name="ssl_certificate",
                                status="warning",
                                details=f"Certificate expires in {days_until_expiry} days"
                            ))
                        else:
                            self.checks.append(NetworkCheck(
                                name="ssl_certificate",
                                status="pass",
                                details=f"Certificate valid for {days_until_expiry} more days"
                            ))
                    return True
        except ssl.SSLCertVerificationError as e:
            self.checks.append(NetworkCheck(
                name="ssl_certificate",
                status="fail",
                details=f"SSL verification failed: {e}"
            ))
            return False
        except Exception as e:
            self.checks.append(NetworkCheck(
                name="ssl_certificate",
                status="fail",
                details=f"SSL check failed: {e}"
            ))
            return False

    def run_full_diagnostics(self, target=None):
        """Run comprehensive network diagnostics."""
        print(f"\n{'='*60}")
        print(f"NETWORK DIAGNOSTICS")
        print(f"{'='*60}\n")

        self.check_dns_resolution()
        self.check_internet_connectivity()
        self.check_http_proxy()

        if target:
            self.check_target_reachability(target)
            parsed = urlparse(target)
            if parsed.hostname:
                self.check_port_scanning(parsed.hostname)

        self.print_report()

    def print_report(self):
        """Print diagnostic report."""
        passed = sum(1 for c in self.checks if c.status == "pass")
        failed = sum(1 for c in self.checks if c.status == "fail")
        warnings = sum(1 for c in self.checks if c.status == "warning")

        print(f"Results: {passed} passed, {failed} failed, {warnings} warnings\n")

        for check in self.checks:
            icon = {"pass": "[+]", "fail": "[-]", "warning": "[!]"}.get(check.status, "[?]")
            latency = f" ({check.latency_ms:.1f}ms)" if check.latency_ms else ""
            print(f"  {icon} {check.name}: {check.details}{latency}")

        print(f"\n{'='*60}\n")


def main():
    """Run network diagnostics."""
    troubleshooter = NetworkTroubleshooter()

    target = sys.argv[1] if len(sys.argv) > 1 else None
    troubleshooter.run_full_diagnostics(target)


if __name__ == "__main__":
    from datetime import datetime
    main()
```

### Step 4: Root Cause Analysis

```python
#!/usr/bin/env python3
"""Root cause analysis framework for tool failures."""

import json
import traceback
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional
from enum import Enum


class CauseCategory(Enum):
    NETWORK = "network"
    PERMISSION = "permission"
    RESOURCE = "resource"
    CONFIGURATION = "configuration"
    DEPENDENCY = "dependency"
    TOOL_BUG = "tool_bug"
    ENVIRONMENT = "environment"
    USER_ERROR = "user_error"
    UNKNOWN = "unknown"


@dataclass
class Symptom:
    description: str
    error_message: str = ""
    stack_trace: str = ""
    context: Dict[str, Any] = field(default_factory=dict)


@dataclass
class RootCause:
    category: CauseCategory
    description: str
    confidence: float  # 0.0 to 1.0
    evidence: List[str] = field(default_factory=list)
    remediation: str = ""
    prevention: str = ""


class RootCauseAnalyzer:
    """Analyze tool failures to identify root causes."""

    def __init__(self):
        self.symptoms: List[Symptom] = []
        self.possible_causes: List[RootCause] = []

    def add_symptom(self, description, error_message="", stack_trace="", context=None):
        """Record a symptom of the failure."""
        self.symptoms.append(Symptom(
            description=description,
            error_message=error_message,
            stack_trace=stack_trace,
            context=context or {}
        ))

    def analyze_network_issues(self):
        """Check for network-related root causes."""
        causes = []

        for symptom in self.symptoms:
            msg = symptom.error_message.lower()
            ctx = symptom.context

            if any(pattern in msg for pattern in [
                "connection refused", "timeout", "network unreachable",
                "dns resolution failed", "name resolution"
            ]):
                causes.append(RootCause(
                    category=CauseCategory.NETWORK,
                    description="Network connectivity issue detected",
                    confidence=0.9,
                    evidence=[symptom.error_message],
                    remediation="Check network connectivity, proxy settings, and DNS configuration",
                    prevention="Implement network health checks before tool execution"
                ))

            if "ssl" in msg or "certificate" in msg:
                causes.append(RootCause(
                    category=CauseCategory.NETWORK,
                    description="SSL/TLS certificate issue",
                    confidence=0.85,
                    evidence=[symptom.error_message],
                    remediation="Update certificate store or verify target certificate",
                    prevention="Regular certificate validation checks"
                ))

        return causes

    def analyze_permission_issues(self):
        """Check for permission-related root causes."""
        causes = []

        for symptom in self.symptoms:
            msg = symptom.error_message.lower()

            if any(pattern in msg for pattern in [
                "permission denied", "access denied", "forbidden",
                "not authorized", "authentication failed"
            ]):
                causes.append(RootCause(
                    category=CauseCategory.PERMISSION,
                    description="Permission or authentication issue",
                    confidence=0.85,
                    evidence=[symptom.error_message],
                    remediation="Verify credentials and permissions",
                    prevention="Implement credential validation before tool execution"
                ))

            if "admin" in msg or "root" in msg or "elevated" in msg:
                causes.append(RootCause(
                    category=CauseCategory.PERMISSION,
                    description="Insufficient privileges",
                    confidence=0.8,
                    evidence=[symptom.error_message],
                    remediation="Run with appropriate privileges or request access",
                    prevention="Check privilege requirements before execution"
                ))

        return causes

    def analyze_resource_issues(self):
        """Check for resource-related root causes."""
        causes = []

        for symptom in self.symptoms:
            msg = symptom.error_message.lower()

            if any(pattern in msg for pattern in [
                "out of memory", "memory error", "oom",
                "disk full", "no space left", "quota exceeded"
            ]):
                causes.append(RootCause(
                    category=CauseCategory.RESOURCE,
                    description="Resource exhaustion detected",
                    confidence=0.9,
                    evidence=[symptom.error_message],
                    remediation="Free up resources or increase limits",
                    prevention="Implement resource monitoring and limits"
                ))

            if "too many open files" in msg or "file descriptor" in msg:
                causes.append(RootCause(
                    category=CauseCategory.RESOURCE,
                    description="File descriptor limit reached",
                    confidence=0.85,
                    evidence=[symptom.error_message],
                    remediation="Increase file descriptor limits",
                    prevention="Monitor file descriptor usage"
                ))

        return causes

    def analyze_configuration_issues(self):
        """Check for configuration-related root causes."""
        causes = []

        for symptom in self.symptoms:
            msg = symptom.error_message.lower()

            if any(pattern in msg for pattern in [
                "invalid option", "unknown option", "missing required",
                "configuration error", "config file", "invalid value"
            ]):
                causes.append(RootCause(
                    category=CauseCategory.CONFIGURATION,
                    description="Configuration error detected",
                    confidence=0.8,
                    evidence=[symptom.error_message],
                    remediation="Review and correct configuration",
                    prevention="Validate configuration before execution"
                ))

            if "file not found" in msg and "config" in msg:
                causes.append(RootCause(
                    category=CauseCategory.CONFIGURATION,
                    description="Configuration file missing",
                    confidence=0.75,
                    evidence=[symptom.error_message],
                    remediation="Create or restore configuration file",
                    prevention="Implement configuration file backups"
                ))

        return causes

    def analyze_dependency_issues(self):
        """Check for dependency-related root causes."""
        causes = []

        for symptom in self.symptoms:
            msg = symptom.error_message.lower()

            if any(pattern in msg for pattern in [
                "module not found", "import error", "cannot import",
                "no module named", "version mismatch"
            ]):
                causes.append(RootCause(
                    category=CauseCategory.DEPENDENCY,
                    description="Dependency issue detected",
                    confidence=0.85,
                    evidence=[symptom.error_message],
                    remediation="Install or update required dependencies",
                    prevention="Pin dependency versions and test regularly"
                ))

            if "library" in msg and ("not found" in msg or "missing" in msg):
                causes.append(RootCause(
                    category=CauseCategory.DEPENDENCY,
                    description="System library missing",
                    confidence=0.8,
                    evidence=[symptom.error_message],
                    remediation="Install required system libraries",
                    prevention="Document and automate system dependency installation"
                ))

        return causes

    def analyze_all(self):
        """Run all analysis methods and compile results."""
        all_causes = []
        all_causes.extend(self.analyze_network_issues())
        all_causes.extend(self.analyze_permission_issues())
        all_causes.extend(self.analyze_resource_issues())
        all_causes.extend(self.analyze_configuration_issues())
        all_causes.extend(self.analyze_dependency_issues())

        # Sort by confidence
        all_causes.sort(key=lambda c: c.confidence, reverse=True)

        self.possible_causes = all_causes
        return all_causes

    def generate_report(self):
        """Generate root cause analysis report."""
        if not self.possible_causes:
            self.analyze_all()

        report = {
            "timestamp": datetime.now().isoformat(),
            "symptoms": [
                {
                    "description": s.description,
                    "error_message": s.error_message,
                    "context": s.context
                }
                for s in self.symptoms
            ],
            "possible_causes": [
                {
                    "category": c.category.value,
                    "description": c.description,
                    "confidence": c.confidence,
                    "evidence": c.evidence,
                    "remediation": c.remediation,
                    "prevention": c.prevention
                }
                for c in self.possible_causes
            ],
            "recommendation": self.possible_causes[0].remediation if self.possible_causes else "No clear root cause identified"
        }

        return report

    def print_report(self):
        """Print human-readable root cause analysis."""
        report = self.generate_report()

        print(f"\n{'='*60}")
        print(f"ROOT CAUSE ANALYSIS")
        print(f"{'='*60}")

        print(f"\nSymptoms ({len(report['symptoms'])}):")
        for s in report['symptoms']:
            print(f"  - {s['description']}")
            if s['error_message']:
                print(f"    Error: {s['error_message'][:80]}")

        print(f"\nPossible Causes ({len(report['possible_causes'])}):")
        for i, cause in enumerate(report['possible_causes'][:5], 1):
            print(f"\n  {i}. [{cause['category']}] {cause['description']}")
            print(f"     Confidence: {cause['confidence']*100:.0f}%")
            print(f"     Remediation: {cause['remediation'][:80]}")

        if report['recommendation']:
            print(f"\nRecommendation: {report['recommendation']}")

        print(f"\n{'='*60}\n")


def main():
    """Run root cause analysis."""
    analyzer = RootCauseAnalyzer()

    # Example: Add symptoms from a failed tool execution
    analyzer.add_symptom(
        description="Tool failed to connect to target",
        error_message="Connection refused: target.example.com:443",
        context={"tool": "nuclei", "target": "target.example.com"}
    )

    analyzer.add_symptom(
        description="DNS resolution worked but connection failed",
        error_message="Network is unreachable",
        context={"dns_resolution": "success", "target_ip": "192.168.1.1"}
    )

    analyzer.print_report()

    report = analyzer.generate_report()
    with open("rca_report.json", "w") as f:
        json.dump(report, f, indent=2)


if __name__ == "__main__":
    main()
```

### Step 5: Automated Remediation

```python
#!/usr/bin/env python3
"""Automated remediation system for common toolchain issues."""

import subprocess
import sys
import os
import shutil
import json
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass
from typing import List, Callable, Optional


@dataclass
class RemediationAction:
    name: str
    description: str
    action: Callable
    prerequisites: List[str] = None
    rollback: Callable = None


class RemediationSystem:
    """Automated remediation for common issues."""

    def __init__(self, dry_run=True):
        self.dry_run = dry_run
        self.actions: List[RemediationAction] = []
        self.applied_actions: List[dict] = []
        self._register_default_actions()

    def _register_default_actions(self):
        """Register default remediation actions."""
        self.register_action(RemediationAction(
            name="fix_file_permissions",
            description="Fix file permissions for tool binaries",
            action=self._fix_permissions,
            rollback=self._restore_permissions
        ))

        self.register_action(RemediationAction(
            name="clear_temp_files",
            description="Clear temporary files to free disk space",
            action=self._clear_temp_files
        ))

        self.register_action(RemediationAction(
            name="reset_tool_config",
            description="Reset tool configuration to defaults",
            action=self._reset_config,
            rollback=self._backup_config
        ))

        self.register_action(RemediationAction(
            name="update_tool",
            description="Update tool to latest version",
            action=self._update_tool
        ))

        self.register_action(RemediationAction(
            name="install_missing_dependency",
            description="Install missing Python dependency",
            action=self._install_dependency
        ))

    def register_action(self, action):
        """Register a remediation action."""
        self.actions.append(action)

    def find_action(self, name):
        """Find action by name."""
        for action in self.actions:
            if action.name == name:
                return action
        return None

    def apply_action(self, action_name, **kwargs):
        """Apply a remediation action."""
        action = self.find_action(action_name)
        if not action:
            print(f"Action not found: {action_name}")
            return False

        print(f"\nApplying: {action.description}")

        if self.dry_run:
            print("  [DRY RUN] Would apply action")
            return True

        try:
            # Check prerequisites
            if action.prerequisites:
                for prereq in action.prerequisites:
                    if not self._check_prerequisite(prereq):
                        print(f"  Prerequisite not met: {prereq}")
                        return False

            # Apply action
            result = action.action(**kwargs)

            self.applied_actions.append({
                "name": action_name,
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "details": str(result)
            })

            print(f"  Applied successfully")
            return True

        except Exception as e:
            self.applied_actions.append({
                "name": action_name,
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "error": str(e)
            })

            print(f"  Failed: {e}")

            # Attempt rollback
            if action.rollback:
                print("  Attempting rollback...")
                try:
                    action.rollback()
                    print("  Rollback successful")
                except Exception as rollback_error:
                    print(f"  Rollback failed: {rollback_error}")

            return False

    def _fix_permissions(self, **kwargs):
        """Fix file permissions."""
        if sys.platform == "win32":
            print("  Permission fix not applicable on Windows")
            return

        tools_dir = Path("/usr/local/bin")
        for tool_file in tools_dir.glob("*"):
            if tool_file.is_file():
                os.chmod(tool_file, 0o755)

    def _restore_permissions(self, **kwargs):
        """Restore permissions from backup."""
        print("  Permission rollback not implemented")

    def _clear_temp_files(self, **kwargs):
        """Clear temporary files."""
        temp_dirs = ["/tmp", "./temp", "./tmp"]
        cleared = 0

        for temp_dir in temp_dirs:
            path = Path(temp_dir)
            if path.exists():
                for item in path.iterdir():
                    try:
                        if item.is_file():
                            item.unlink()
                            cleared += 1
                        elif item.is_dir():
                            shutil.rmtree(item)
                            cleared += 1
                    except Exception:
                        pass

        return f"Cleared {cleared} temporary files"

    def _backup_config(self, **kwargs):
        """Backup configuration before reset."""
        config_files = ["config.yaml", "config.json", ".env"]

        for config_file in config_files:
            path = Path(config_file)
            if path.exists():
                backup = path.with_suffix(f".{datetime.now().strftime('%Y%m%d_%H%M%S')}.bak")
                shutil.copy2(path, backup)
                print(f"  Backed up: {path} -> {backup}")

    def _reset_config(self, **kwargs):
        """Reset configuration to defaults."""
        self._backup_config()

        default_configs = {
            "config.yaml": """# Default configuration
logging:
  level: INFO
  format: "%(asctime)s [%(levelname)s] %(message)s"

tools:
  timeout: 30
  retries: 3
""",
            "config.json": json.dumps({
                "logging": {"level": "INFO"},
                "tools": {"timeout": 30, "retries": 3}
            }, indent=2)
        }

        for filename, content in default_configs.items():
            path = Path(filename)
            if not path.exists():
                path.write_text(content)
                print(f"  Created default: {filename}")

    def _update_tool(self, **kwargs):
        """Update a tool to latest version."""
        tool_name = kwargs.get("tool_name")
        if not tool_name:
            print("  No tool name specified")
            return False

        # Determine update method
        if sys.platform == "win32":
            cmd = ["winget", "upgrade", tool_name]
        else:
            cmd = ["sudo", "apt-get", "install", "--only-upgrade", "-y", tool_name]

        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0

    def _install_dependency(self, **kwargs):
        """Install missing Python dependency."""
        package = kwargs.get("package")
        if not package:
            print("  No package name specified")
            return False

        cmd = [sys.executable, "-m", "pip", "install", package]
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0

    def _check_prerequisite(self, prereq):
        """Check if a prerequisite is met."""
        checks = {
            "network": self._check_network,
            "disk_space": self._check_disk_space,
            "python": self._check_python
        }

        check_func = checks.get(prereq)
        if check_func:
            return check_func()
        return True

    def _check_network(self):
        """Check network availability."""
        try:
            socket.create_connection(("8.8.8.8", 53), timeout=5)
            return True
        except OSError:
            return False

    def _check_disk_space(self):
        """Check available disk space."""
        stat = shutil.disk_usage("/")
        return stat.free > 1024 * 1024 * 100  # 100MB

    def _check_python(self):
        """Check Python is available."""
        return sys.executable is not None

    def generate_report(self):
        """Generate remediation report."""
        report = {
            "timestamp": datetime.now().isoformat(),
            "dry_run": self.dry_run,
            "actions_applied": len(self.applied_actions),
            "actions": self.applied_actions,
            "available_actions": [
                {"name": a.name, "description": a.description}
                for a in self.actions
            ]
        }

        return report

    def print_report(self):
        """Print remediation report."""
        report = self.generate_report()

        print(f"\n{'='*60}")
        print(f"REMEDIATION REPORT")
        print(f"{'='*60}")
        print(f"Mode: {'DRY RUN' if self.dry_run else 'LIVE'}")
        print(f"Actions Applied: {report['actions_applied']}")

        if self.applied_actions:
            print(f"\nApplied Actions:")
            for action in self.applied_actions:
                status = "SUCCESS" if action["success"] else "FAILED"
                print(f"  [{status}] {action['name']}")

        print(f"\nAvailable Actions:")
        for action in self.actions:
            print(f"  - {action.name}: {action.description}")

        print(f"{'='*60}\n")


def main():
    """Run automated remediation."""
    import argparse

    parser = argparse.ArgumentParser(description="Automated remediation system")
    parser.add_argument("--live", action="store_true", help="Run in live mode")
    parser.add_argument("--action", help="Specific action to apply")
    parser.add_argument("--list", action="store_true", help="List available actions")

    args = parser.parse_args()

    system = RemediationSystem(dry_run=not args.live)

    if args.list:
        system.print_report()
    elif args.action:
        system.apply_action(args.action)
        system.print_report()
    else:
        system.print_report()


if __name__ == "__main__":
    main()
```

### Step 6: Health Check Monitor

```python
#!/usr/bin/env python3
"""Continuous health check monitoring for toolchain."""

import time
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Callable


@dataclass
class HealthCheck:
    name: str
    check_func: Callable
    interval_seconds: int = 300
    timeout_seconds: int = 10
    last_run: datetime = None
    last_status: str = "unknown"
    last_message: str = ""
    failure_count: int = 0


class HealthMonitor:
    """Continuous health monitoring system."""

    def __init__(self, config_file=None):
        self.checks: List[HealthCheck] = []
        self.history: List[Dict] = []
        self.config = self._load_config(config_file)
        self._register_default_checks()

    def _load_config(self, config_file):
        """Load monitoring configuration."""
        default_config = {
            "check_interval": 300,
            "alert_threshold": 3,
            "log_file": "health_monitor.log",
            "history_file": "health_history.json"
        }

        if config_file and Path(config_file).exists():
            with open(config_file) as f:
                return json.load(f)

        return default_config

    def _register_default_checks(self):
        """Register default health checks."""
        self.register_check(HealthCheck(
            name="disk_space",
            check_func=self._check_disk_space,
            interval_seconds=600
        ))

        self.register_check(HealthCheck(
            name="memory_usage",
            check_func=self._check_memory,
            interval_seconds=300
        ))

        self.register_check(HealthCheck(
            name="network_connectivity",
            check_func=self._check_network,
            interval_seconds=120
        ))

        self.register_check(HealthCheck(
            name="tool_availability",
            check_func=self._check_tools,
            interval_seconds=600
        ))

    def register_check(self, check):
        """Register a health check."""
        self.checks.append(check)

    def run_check(self, check):
        """Run a single health check."""
        try:
            result = check.check_func()
            check.last_run = datetime.now()
            check.last_status = "healthy" if result else "unhealthy"
            check.last_message = "Check passed" if result else "Check failed"
            check.failure_count = 0 if result else check.failure_count + 1
        except Exception as e:
            check.last_run = datetime.now()
            check.last_status = "error"
            check.last_message = str(e)
            check.failure_count += 1

        return check.last_status

    def run_all_checks(self):
        """Run all registered health checks."""
        results = []
        for check in self.checks:
            status = self.run_check(check)
            results.append({
                "name": check.name,
                "status": status,
                "message": check.last_message,
                "timestamp": check.last_run.isoformat() if check.last_run else None
            })

        self.history.append({
            "timestamp": datetime.now().isoformat(),
            "results": results
        })

        # Keep only last 100 history entries
        if len(self.history) > 100:
            self.history = self.history[-100:]

        return results

    def get_unhealthy_checks(self):
        """Get checks that are unhealthy or have high failure counts."""
        return [
            check for check in self.checks
            if check.last_status in ("unhealthy", "error")
            or check.failure_count >= self.config.get("alert_threshold", 3)
        ]

    def _check_disk_space(self):
        """Check available disk space."""
        import shutil
        total, used, free = shutil.disk_usage("/")
        free_gb = free / (1024 ** 3)
        return free_gb >= 1.0  # At least 1GB free

    def _check_memory(self):
        """Check available memory."""
        import psutil
        available_mb = psutil.virtual_memory().available / (1024 ** 2)
        return available_mb >= 100  # At least 100MB free

    def _check_network(self):
        """Check network connectivity."""
        import socket
        try:
            socket.create_connection(("8.8.8.8", 53), timeout=5)
            return True
        except OSError:
            return False

    def _check_tools(self):
        """Check tool availability."""
        tools = ["nuclei", "subfinder", "httpx"]
        for tool in tools:
            result = subprocess.run(
                ["where", tool] if sys.platform == "win32" else ["which", tool],
                capture_output=True, text=True
            )
            if result.returncode != 0:
                return False
        return True

    def monitor_loop(self, duration_seconds=None):
        """Run continuous monitoring loop."""
        print(f"\n{'='*60}")
        print(f"HEALTH MONITOR STARTED")
        print(f"{'='*60}\n")

        start_time = time.time()

        try:
            while True:
                # Run checks
                results = self.run_all_checks()

                # Print status
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                healthy = sum(1 for r in results if r["status"] == "healthy")
                total = len(results)

                print(f"[{timestamp}] Health: {healthy}/{total} checks healthy")

                # Check for unhealthy
                unhealthy = self.get_unhealthy_checks()
                if unhealthy:
                    print(f"  WARNING: {len(unhealthy)} unhealthy checks:")
                    for check in unhealthy:
                        print(f"    - {check.name}: {check.last_message}")

                # Save history
                self._save_history()

                # Check duration
                if duration_seconds:
                    elapsed = time.time() - start_time
                    if elapsed >= duration_seconds:
                        break

                # Wait for next check
                time.sleep(self.config.get("check_interval", 300))

        except KeyboardInterrupt:
            print("\nMonitoring stopped by user")

    def _save_history(self):
        """Save monitoring history."""
        history_file = self.config.get("history_file", "health_history.json")
        with open(history_file, "w") as f:
            json.dump(self.history, f, indent=2, default=str)

    def generate_report(self):
        """Generate monitoring report."""
        report = {
            "timestamp": datetime.now().isoformat(),
            "checks": [
                {
                    "name": c.name,
                    "status": c.last_status,
                    "last_run": c.last_run.isoformat() if c.last_run else None,
                    "failure_count": c.failure_count,
                    "message": c.last_message
                }
                for c in self.checks
            ],
            "total_checks": len(self.checks),
            "healthy_checks": sum(1 for c in self.checks if c.last_status == "healthy"),
            "history_entries": len(self.history)
        }

        return report

    def print_report(self):
        """Print monitoring report."""
        report = self.generate_report()

        print(f"\n{'='*60}")
        print(f"HEALTH MONITOR REPORT")
        print(f"{'='*60}")
        print(f"Total Checks: {report['total_checks']}")
        print(f"Healthy:      {report['healthy_checks']}")
        print(f"History:      {report['history_entries']} entries")

        print(f"\nCheck Status:")
        for check in report['checks']:
            icon = "[+]" if check['status'] == "healthy" else "[-]"
            print(f"  {icon} {check['name']}: {check['status']}")

        print(f"{'='*60}\n")


def main():
    """Run health monitoring."""
    import argparse

    parser = argparse.ArgumentParser(description="Health monitoring system")
    parser.add_argument("--once", action="store_true", help="Run checks once")
    parser.add_argument("--duration", type=int, help="Monitor duration in seconds")
    parser.add_argument("--config", help="Configuration file path")

    args = parser.parse_args()

    monitor = HealthMonitor(args.config)

    if args.once:
        monitor.run_all_checks()
        monitor.print_report()
    else:
        monitor.monitor_loop(args.duration)
        monitor.print_report()


if __name__ == "__main__":
    main()
```

---

## Tool Arsenal

### Debug Commands

```bash
# System diagnostics
python -c "import psutil; print(psutil.virtual_memory())"
python -c "import shutil; print(shutil.disk_usage('/'))"

# Network diagnostics
python -c "import socket; print(socket.getaddrinfo('google.com', 80))"
ping -c 4 8.8.8.8
nslookup example.com
traceroute example.com

# Process diagnostics
ps aux | grep nuclei
lsof -i :80
netstat -tulpn | grep :443

# Log analysis
grep -i "error" /var/log/syslog | tail -20
journalctl -u service --since "1 hour ago"
tail -f /var/log/tool.log
```

### Python Debugging

```bash
# Enhanced debugging
python -m pdb script.py
python -m ipdb script.py

# Profiling
python -m cProfile -o output.prof script.py
python -m line_profiler script.py

# Memory profiling
python -m memory_profiler script.py
mprof run script.py
mprof plot

# Logging
python -c "import logging; logging.basicConfig(level=logging.DEBUG)"
```

### Log Analysis Commands

```bash
# Search patterns
grep -E "(ERROR|CRITICAL)" logfile.log
grep -A 5 -B 5 "Exception" logfile.log

# Statistics
awk '/ERROR/ {count++} END {print count}' logfile.log
sort logfile.log | uniq -c | sort -rn | head

# Time-based analysis
awk '$1 >= "2024-01-01" && $1 <= "2024-01-31"' logfile.log
```

---

## Real-World Examples

### Example 1: Tool Connection Failure Diagnosis

```python
"""Diagnose why a security tool cannot connect to targets."""

from pathlib import Path
import subprocess
import sys


def diagnose_connection_failure(tool_name, target):
    """Comprehensive diagnosis of tool connection failure."""
    print(f"\n{'='*60}")
    print(f"CONNECTION FAILURE DIAGNOSIS")
    print(f"Tool: {tool_name}")
    print(f"Target: {target}")
    print(f"{'='*60}\n")

    issues_found = []

    # Check 1: Tool installed
    print("[1/6] Checking tool installation...")
    result = subprocess.run(
        ["where", tool_name] if sys.platform == "win32" else ["which", tool_name],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        issues_found.append(f"Tool {tool_name} not installed")
        print(f"  FAILED: {tool_name} not found")
    else:
        print(f"  OK: {tool_name} found at {result.stdout.strip()}")

    # Check 2: Network connectivity
    print("\n[2/6] Checking network connectivity...")
    result = subprocess.run(
        ["ping", "-c", "4", "8.8.8.8"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        issues_found.append("No network connectivity")
        print("  FAILED: Cannot reach external network")
    else:
        print("  OK: Network connectivity working")

    # Check 3: DNS resolution
    print("\n[3/6] Checking DNS resolution...")
    import socket
    try:
        socket.getaddrinfo(target, None)
        print(f"  OK: DNS resolves {target}")
    except socket.gaierror:
        issues_found.append(f"DNS resolution failed for {target}")
        print(f"  FAILED: Cannot resolve {target}")

    # Check 4: Port reachability
    print("\n[4/6] Checking port reachability...")
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        sock.connect((target, 443))
        sock.close()
        print(f"  OK: Port 443 reachable on {target}")
    except (socket.timeout, OSError) as e:
        issues_found.append(f"Port 443 unreachable: {e}")
        print(f"  FAILED: {e}")

    # Check 5: Tool-specific test
    print("\n[5/6] Running tool-specific test...")
    result = subprocess.run(
        [tool_name, "-version"],
        capture_output=True, text=True, timeout=10
    )
    if result.returncode == 0:
        print(f"  OK: Tool runs correctly")
    else:
        issues_found.append(f"Tool failed to run: {result.stderr}")
        print(f"  FAILED: {result.stderr[:100]}")

    # Check 6: Configuration
    print("\n[6/6] Checking configuration...")
    config_file = Path(f"{tool_name}_config.yaml")
    if config_file.exists():
        print(f"  OK: Configuration file exists")
    else:
        issues_found.append("Configuration file missing")
        print(f"  WARNING: No configuration file found")

    # Summary
    print(f"\n{'='*60}")
    if issues_found:
        print(f"DIAGNOSIS COMPLETE - {len(issues_found)} issues found:")
        for issue in issues_found:
            print(f"  - {issue}")
    else:
        print("DIAGNOSIS COMPLETE - No issues found")
    print(f"{'='*60}\n")

    return issues_found


if __name__ == "__main__":
    if len(sys.argv) >= 3:
        diagnose_connection_failure(sys.argv[1], sys.argv[2])
    else:
        print("Usage: python diagnose_connection.py <tool> <target>")
```

### Example 2: Automated Issue Resolution

```python
"""Automated resolution for common toolchain issues."""

import subprocess
import sys
from pathlib import Path
import json


class AutoResolver:
    """Automatically resolve common issues."""

    def __init__(self, dry_run=True):
        self.dry_run = dry_run
        self.resolutions = []

    def resolve_missing_tool(self, tool_name):
        """Install a missing tool."""
        print(f"\nResolving: Missing tool {tool_name}")

        if self.dry_run:
            print("  [DRY RUN] Would install tool")
            return True

        # Determine installation method
        installers = {
            "nuclei": "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest",
            "subfinder": "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest",
            "httpx": "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest",
            "sqlmap": "pip install sqlmap"
        }

        if tool_name in installers:
            cmd = installers[tool_name]
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

            if result.returncode == 0:
                self.resolutions.append(f"Installed {tool_name}")
                return True
            else:
                print(f"  Installation failed: {result.stderr[:100]}")
                return False

        print(f"  No installer available for {tool_name}")
        return False

    def resolve_config_error(self, tool_name):
        """Reset tool configuration to defaults."""
        print(f"\nResolving: Configuration error for {tool_name}")

        if self.dry_run:
            print("  [DRY RUN] Would reset configuration")
            return True

        config_files = {
            "nuclei": Path.home() / ".nuclei" / "config.yaml",
            "subfinder": Path.home() / ".subfinder" / "config.yaml"
        }

        if tool_name in config_files:
            config_path = config_files[tool_name]

            # Backup existing config
            if config_path.exists():
                backup = config_path.with_suffix(".bak")
                config_path.rename(backup)
                print(f"  Backed up: {config_path} -> {backup}")

            # Create default config
            config_path.parent.mkdir(parents=True, exist_ok=True)
            config_path.write_text("# Default configuration\n")
            self.resolutions.append(f"Reset {tool_name} configuration")
            return True

        return False

    def resolve_permission_error(self, file_path):
        """Fix file permissions."""
        print(f"\nResolving: Permission error for {file_path}")

        if self.dry_run:
            print("  [DRY RUN] Would fix permissions")
            return True

        if sys.platform != "win32":
            import os
            os.chmod(file_path, 0o755)
            self.resolutions.append(f"Fixed permissions for {file_path}")
            return True

        return False

    def resolve_disk_space(self):
        """Free up disk space."""
        print(f"\nResolving: Low disk space")

        if self.dry_run:
            print("  [DRY RUN] Would clear temporary files")
            return True

        # Clear common temp directories
        import shutil
        temp_dirs = ["/tmp", "./temp", "./tmp"]
        freed = 0

        for temp_dir in temp_dirs:
            path = Path(temp_dir)
            if path.exists():
                for item in path.iterdir():
                    try:
                        size = item.stat().st_size if item.is_file() else 0
                        if item.is_file():
                            item.unlink()
                            freed += size
                        elif item.is_dir():
                            shutil.rmtree(item)
                    except Exception:
                        pass

        self.resolutions.append(f"Freed {freed / 1024 / 1024:.1f} MB")
        return True

    def auto_diagnose_and_fix(self, error_message):
        """Automatically diagnose and fix based on error message."""
        print(f"\nAnalyzing error: {error_message[:100]}")

        error_lower = error_message.lower()

        # Match error patterns
        if "command not found" in error_lower or "not found" in error_lower:
            # Extract tool name from error
            parts = error_message.split()
            for part in parts:
                if not part.startswith("-") and not part.startswith("/"):
                    self.resolve_missing_tool(part)
                    break

        elif "permission denied" in error_lower:
            # Extract file path from error
            import re
            match = re.search(r"'(/[^']+)'", error_message)
            if match:
                self.resolve_permission_error(match.group(1))

        elif "no space left" in error_lower:
            self.resolve_disk_space()

        elif "config" in error_lower or "configuration" in error_lower:
            # Extract tool name
            import re
            match = re.search(r"(\w+):.*config", error_lower)
            if match:
                self.resolve_config_error(match.group(1))

        return self.resolutions

    def generate_report(self):
        """Generate resolution report."""
        return {
            "timestamp": datetime.now().isoformat() if 'datetime' in dir() else "",
            "resolutions_applied": len(self.resolutions),
            "resolutions": self.resolutions
        }


if __name__ == "__main__":
    resolver = AutoResolver(dry_run=False)

    if len(sys.argv) > 1:
        error = " ".join(sys.argv[1:])
        resolver.auto_diagnose_and_fix(error)
    else:
        print("Usage: python auto_resolve.py <error_message>")
```

### Example 3: Debug Session Recorder

```python
"""Record and replay debug sessions for knowledge sharing."""

import json
import time
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import List, Any


@dataclass
class DebugStep:
    step_number: int
    action: str
    command: str
    output: str
    timestamp: str
    duration_seconds: float
    success: bool
    notes: str = ""


class DebugSessionRecorder:
    """Record debug sessions for replay and documentation."""

    def __init__(self, session_name=None):
        self.session_name = session_name or f"debug_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.steps: List[DebugStep] = []
        self.step_counter = 0
        self.output_dir = Path("debug_sessions")
        self.output_dir.mkdir(exist_ok=True)

    def record_step(self, action, command, output, success, notes="", duration=0):
        """Record a debug step."""
        self.step_counter += 1

        step = DebugStep(
            step_number=self.step_counter,
            action=action,
            command=command,
            output=output[:1000] if output else "",
            timestamp=datetime.now().isoformat(),
            duration_seconds=duration,
            success=success,
            notes=notes
        )

        self.steps.append(step)
        return step

    def record_command(self, command, output, success, duration=0):
        """Record a command execution."""
        return self.record_step(
            action="execute_command",
            command=command,
            output=output,
            success=success,
            duration=duration
        )

    def record_observation(self, observation, notes=""):
        """Record an observation."""
        return self.record_step(
            action="observation",
            command="",
            output=observation,
            success=True,
            notes=notes
        )

    def record_hypothesis(self, hypothesis):
        """Record a hypothesis."""
        return self.record_step(
            action="hypothesis",
            command="",
            output=hypothesis,
            success=True,
            notes="Hypothesis formed"
        )

    def record_conclusion(self, conclusion):
        """Record a conclusion."""
        return self.record_step(
            action="conclusion",
            command="",
            output=conclusion,
            success=True,
            notes="Session concluded"
        )

    def save_session(self):
        """Save the debug session to file."""
        session_data = {
            "session_name": self.session_name,
            "start_time": self.steps[0].timestamp if self.steps else None,
            "end_time": self.steps[-1].timestamp if self.steps else None,
            "total_steps": len(self.steps),
            "steps": [asdict(step) for step in self.steps]
        }

        output_file = self.output_dir / f"{self.session_name}.json"
        with open(output_file, "w") as f:
            json.dump(session_data, f, indent=2)

        print(f"Session saved to {output_file}")
        return output_file

    def generate_markdown(self):
        """Generate Markdown documentation of the session."""
        lines = [f"# Debug Session: {self.session_name}\n"]
        lines.append(f"**Start**: {self.steps[0].timestamp if self.steps else 'N/A'}")
        lines.append(f"**Steps**: {len(self.steps)}\n")

        lines.append("## Steps\n")

        for step in self.steps:
            status = "SUCCESS" if step.success else "FAILED"
            lines.append(f"### Step {step.step_number}: {step.action} [{status}]\n")

            if step.command:
                lines.append(f"**Command**: `{step.command}`\n")

            if step.output:
                lines.append(f"**Output**:\n```\n{step.output[:500]}\n```\n")

            if step.notes:
                lines.append(f"**Notes**: {step.notes}\n")

            lines.append("---\n")

        return "\n".join(lines)

    def print_summary(self):
        """Print session summary."""
        print(f"\n{'='*60}")
        print(f"DEBUG SESSION: {self.session_name}")
        print(f"{'='*60}")
        print(f"Total Steps: {len(self.steps)}")

        successful = sum(1 for s in self.steps if s.success)
        print(f"Successful:  {successful}")
        print(f"Failed:      {len(self.steps) - successful}")

        total_time = sum(s.duration_seconds for s in self.steps)
        print(f"Total Time:  {total_time:.2f}s")

        print(f"\nStep Summary:")
        for step in self.steps:
            status = "[+]" if step.success else "[-]"
            print(f"  {status} Step {step.step_number}: {step.action}")

        print(f"{'='*60}\n")


def main():
    """Example debug session."""
    recorder = DebugSessionRecorder("example_debug")

    recorder.record_hypothesis("Tool connection failure due to network issue")

    recorder.record_command(
        "ping 8.8.8.8",
        "PING 8.8.8.8: 64 bytes, time=10ms",
        success=True,
        duration=0.5
    )

    recorder.record_observation("Network connectivity working")

    recorder.record_command(
        "nslookup target.example.com",
        "Server: 8.8.8.8\nAddress: 8.8.8.8#53",
        success=True,
        duration=0.3
    )

    recorder.record_conclusion("Issue was temporary network glitch, now resolved")

    recorder.save_session()
    recorder.print_summary()

    # Generate markdown documentation
    markdown = recorder.generate_markdown()
    md_file = Path("debug_sessions") / f"{recorder.session_name}.md"
    with open(md_file, "w") as f:
        f.write(markdown)
    print(f"Markdown saved to {md_file}")


if __name__ == "__main__":
    main()
```

---

## Common Pitfalls

### Pitfall 1: Not Reading Error Messages Carefully

**Problem**: Ignoring or skimming error messages leads to wrong diagnosis.

**Prevention**:
```python
# Always capture and analyze full error output
import subprocess

result = subprocess.run(cmd, capture_output=True, text=True)
if result.returncode != 0:
    print(f"STDOUT: {result.stdout}")
    print(f"STDERR: {result.stderr}")
    # Analyze the full error, not just the return code
```

### Pitfall 2: Making Changes Without Understanding the Problem

**Problem**: Randomly changing configurations hoping something fixes the issue.

**Prevention**:
```python
# Document hypothesis before making changes
def diagnose_before_fix(error_message):
    print(f"Error: {error_message}")
    print("Hypothesis: [state your theory]")
    print("Evidence: [what supports your theory]")
    print("Test: [how you'll verify]")
    # Then make the change
```

### Pitfall 3: Not Checking the Obvious First

**Problem**: Deep-diving into complex issues when the problem is simple.

**Prevention**:
```python
# Simple checks first
CHECKLIST = [
    "Is the tool installed?",
    "Is the file path correct?",
    "Are permissions correct?",
    "Is there network connectivity?",
    "Are credentials valid?",
    "Is the configuration file valid?"
]
```

### Pitfall 4: Forgetting to Check Logs

**Problem**: Trying to debug without looking at available log files.

**Prevention**:
```python
# Always check logs first
log_files = [
    "/var/log/syslog",
    "tool.log",
    "debug.log"
]

for log_file in log_files:
    if Path(log_file).exists():
        print(f"\n=== Last 20 lines of {log_file} ===")
        with open(log_file) as f:
            lines = f.readlines()
            for line in lines[-20:]:
                print(line.rstrip())
```

### Pitfall 5: Not Documenting the Solution

**Problem**: Solving the same issue multiple times because the solution wasn't recorded.

**Prevention**:
```python
# Document every solution
def document_solution(issue, solution, prevention):
    solution_doc = {
        "issue": issue,
        "solution": solution,
        "prevention": prevention,
        "timestamp": datetime.now().isoformat()
    }

    with open("solutions.json", "a") as f:
        json.dump(solution_doc, f)
        f.write("\n")
```

---

## Advanced Techniques

### Binary Search Debugging

```python
"""Binary search debugging to isolate issues."""

from pathlib import Path


def binary_search_config(config_lines, test_func, working_config=None):
    """Find the problematic config line using binary search."""
    if len(config_lines) <= 1:
        return config_lines[0] if config_lines else None

    mid = len(config_lines) // 2
    first_half = config_lines[:mid]
    second_half = config_lines[mid:]

    # Test first half
    test_config = (working_config or []) + first_half
    if test_func(test_config):
        # Problem is in first half
        return binary_search_config(first_half, test_func, working_config)
    else:
        # Problem is in second half
        return binary_search_config(second_half, test_func, working_config + first_half)


def find_breaking_line(config_file, test_func):
    """Find the specific line causing issues."""
    with open(config_file) as f:
        lines = f.readlines()

    # Filter out comments and empty lines
    active_lines = [(i, line) for i, line in enumerate(lines)
                    if line.strip() and not line.strip().startswith("#")]

    def test_subset(lines_subset):
        test_config = "\n".join(line for _, line in lines_subset)
        return test_func(test_config)

    result = binary_search_config(
        [line for _, line in active_lines],
        test_subset
    )

    if result:
        line_num = next(i for i, line in active_lines if line == result)
        return line_num, result

    return None, None
```

### Strace Analysis

```python
"""System call tracing for deep debugging."""

import subprocess
import re
from pathlib import Path


def trace_tool_execution(tool_cmd, output_file="strace_output.txt"):
    """Trace system calls of a tool execution."""
    cmd = ["strace", "-o", output_file] + tool_cmd

    result = subprocess.run(cmd, capture_output=True, text=True)

    return {
        "returncode": result.returncode,
        "trace_file": output_file,
        "stdout": result.stdout,
        "stderr": result.stderr
    }


def analyze_strace_output(trace_file):
    """Analyze strace output for common issues."""
    issues = []

    with open(trace_file) as f:
        for line in f:
            if "EACCES" in line:
                issues.append({
                    "type": "permission_denied",
                    "syscall": line.split("(")[0],
                    "details": line.strip()
                })
            elif "ENOENT" in line:
                issues.append({
                    "type": "file_not_found",
                    "syscall": line.split("(")[0],
                    "details": line.strip()
                })
            elif "ETIMEDOUT" in line:
                issues.append({
                    "type": "timeout",
                    "syscall": line.split("(")[0],
                    "details": line.strip()
                })

    return issues
```

### Automated Debugging Assistant

```python
"""AI-assisted debugging recommendations."""

import json
from pathlib import Path


class DebugAssistant:
    """Provide debugging recommendations based on error patterns."""

    def __init__(self):
        self.knowledge_base = self._load_knowledge_base()

    def _load_knowledge_base(self):
        """Load known issues and solutions."""
        kb_file = Path("debug_knowledge_base.json")

        if kb_file.exists():
            with open(kb_file) as f:
                return json.load(f)

        return {
            "patterns": [
                {
                    "pattern": "Connection refused",
                    "cause": "Target service not running or port blocked",
                    "solutions": [
                        "Verify target is running",
                        "Check firewall rules",
                        "Confirm correct port"
                    ]
                },
                {
                    "pattern": "Permission denied",
                    "cause": "Insufficient permissions",
                    "solutions": [
                        "Check file permissions",
                        "Run with appropriate user",
                        "Verify tool ownership"
                    ]
                },
                {
                    "pattern": "No such file or directory",
                    "cause": "File path incorrect or file missing",
                    "solutions": [
                        "Verify file path exists",
                        "Check working directory",
                        "Create missing files"
                    ]
                }
            ]
        }

    def analyze_error(self, error_message):
        """Analyze error and provide recommendations."""
        recommendations = []

        for pattern in self.knowledge_base["patterns"]:
            if pattern["pattern"].lower() in error_message.lower():
                recommendations.append({
                    "pattern": pattern["pattern"],
                    "cause": pattern["cause"],
                    "solutions": pattern["solutions"]
                })

        if not recommendations:
            recommendations.append({
                "pattern": "Unknown",
                "cause": "No matching pattern found",
                "solutions": [
                    "Check full error message",
                    "Review tool documentation",
                    "Search for similar issues online"
                ]
            })

        return recommendations

    def suggest_commands(self, error_type):
        """Suggest debugging commands based on error type."""
        commands = {
            "network": [
                "ping <target>",
                "nslookup <target>",
                "traceroute <target>",
                "nc -zv <target> <port>"
            ],
            "permission": [
                "ls -la <file>",
                "id",
                "sudo <command>",
                "chmod +x <file>"
            ],
            "file_not_found": [
                "ls -la <directory>",
                "find . -name <filename>",
                "pwd",
                "cat <file>"
            ]
        }

        return commands.get(error_type, ["Check error details"])
```

---

## Reporting Template

### Diagnostic Report

```
# Diagnostic Report

**Date**: [DATE]
**Reported By**: [USER/AUTOMATED]
**Tool Affected**: [TOOL_NAME]
**Environment**: [ENVIRONMENT]

## Issue Description

**Symptoms**:
[symptom_1]
[symptom_2]

**Error Message**:
```
[full_error_message]
```

**Impact**: [DESCRIPTION_OF_IMPACT]

## Diagnostic Steps

| Step | Action | Result | Finding |
|------|--------|--------|---------|
| 1 | [action] | [PASS/FAIL] | [finding] |
| 2 | [action] | [PASS/FAIL] | [finding] |

## Root Cause

**Category**: [NETWORK/PERMISSION/CONFIGURATION/RESOURCE/DEPENDENCY]
**Description**: [detailed_description]
**Confidence**: [HIGH/MEDIUM/LOW]

**Evidence**:
1. [evidence_1]
2. [evidence_2]

## Remediation

**Applied Fix**:
[description_of_fix]

**Verification**:
[how_issue_was_verified_fixed]

**Rollback Plan**:
[how_to_undo_fix_if_needed]

## Prevention

**Immediate**: [prevention_step_1]
**Long-term**: [prevention_step_2]

## Timeline

| Time | Action |
|------|--------|
| [time] | Issue reported |
| [time] | Diagnosis started |
| [time] | Root cause identified |
| [time] | Fix applied |
| [time] | Issue resolved |

## Lessons Learned

1. [lesson_1]
2. [lesson_2]
```

### Knowledge Base Entry

```json
{
  "issue_id": "KB-001",
  "title": "Tool Connection Failure",
  "category": "network",
  "symptoms": [
    "Connection refused",
    "Timeout",
    "Network unreachable"
  ],
  "root_cause": "Network connectivity issue or firewall blocking",
  "solutions": [
    {
      "step": 1,
      "action": "Check network connectivity",
      "command": "ping 8.8.8.8"
    },
    {
      "step": 2,
      "action": "Check DNS resolution",
      "command": "nslookup target.com"
    },
    {
      "step": 3,
      "action": "Check port reachability",
      "command": "nc -zv target.com 443"
    }
  ],
  "prevention": "Implement network health checks before tool execution",
  "references": ["https://example.com/docs/troubleshooting"]
}
```

---

## Quick Reference

### Debugging Commands Cheat Sheet

```bash
# System info
uname -a                           # System information
cat /etc/os-release                # OS version
free -h                            # Memory usage
df -h                              # Disk usage

# Process debugging
ps aux | grep <tool>               # Find running processes
top -b -n 1 | head -20             # Resource usage
strace -p <pid>                    # Trace system calls

# Network debugging
ping -c 4 <target>                 # Connectivity test
nslookup <target>                  # DNS resolution
curl -v <url>                      # HTTP debugging
openssl s_client -connect host:443 # SSL debugging

# Log analysis
tail -f <logfile>                  # Follow log output
grep -i "error" <logfile>          # Search for errors
journalctl -u <service>            # Service logs
```

### Troubleshooting Checklist

- [ ] Read the full error message
- [ ] Check logs for additional context
- [ ] Verify tool is installed correctly
- [ ] Check network connectivity
- [ ] Verify credentials and permissions
- [ ] Check configuration files
- [ ] Verify file paths exist
- [ ] Check disk space and memory
- [ ] Test with minimal configuration
- [ ] Search for known issues
- [ ] Document the solution

### Common Error Patterns

| Error Pattern | Likely Cause | First Action |
|---------------|--------------|--------------|
| Connection refused | Service down or port blocked | Check target service status |
| Permission denied | Insufficient privileges | Check file permissions |
| No such file | Path incorrect or file missing | Verify file path |
| Timeout | Network or service issue | Check connectivity |
| Out of memory | Resource exhaustion | Free up memory |
| Import error | Missing dependency | Install package |

---

*Last Updated: [DATE]*
*Version: 2.0*
*Author: Debugging and Troubleshooting Guide v2*
