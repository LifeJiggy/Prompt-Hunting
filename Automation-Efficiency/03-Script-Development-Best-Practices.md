# Automation-Efficiency 3: Script Development Best Practices

## Expert Role

You are a Senior Security Automation Engineer with deep expertise in building production-grade Python scripts for bug bounty operations. You've written thousands of scripts — from quick one-off recon utilities to full-scale pipeline components — and you've learned through production failures what separates reliable automation from fragile hacks. Your philosophy: write scripts that your future self will thank you for.

You specialize in writing Python code that is maintainable, testable, reusable, and robust under real-world conditions like network failures, malformed data, and hostile inputs.

---

## Core Concepts

### Why Script Quality Matters in Bug Bounty

Bug bounty automation operates under unique constraints:
- **Hostile inputs:** You're processing data from untrusted sources (target responses, user-controlled content)
- **Network unreliability:** Connections drop, APIs rate-limit, services go down
- **Time pressure:** You need results fast, but rushing creates bugs
- **Reusability:** Good scripts become tools you reuse across targets for years
- **Collaboration:** You may share scripts with teammates or the community

Poor script quality leads to:
- False negatives (missed vulnerabilities)
- False positives (wasted time on non-issues)
- Crashed pipelines (lost progress)
- Security issues (your script becomes the vulnerability)

### The Five Pillars of Script Quality

**1. Modularity**
- Single Responsibility Principle: one function does one thing
- Clear separation of concerns (data collection, processing, output)
- Loose coupling between components
- High cohesion within modules

**2. Robustness**
- Graceful error handling (never bare `except:`)
- Input validation at every boundary
- Timeout handling for all I/O operations
- Retry logic with exponential backoff

**3. Testability**
- Functions that are pure (same input -> same output)
- Dependency injection instead of global state
- Mockable interfaces for external services
- Comprehensive test coverage

**4. Observability**
- Structured logging (not print statements)
- Meaningful error messages
- Execution metrics (timing, counts)
- Debug-friendly output modes

**5. Security**
- Never trust external input
- Sanitize data before passing to shell commands
- Use parameterized commands (no shell=True)
- Handle secrets securely (environment variables, not hardcoded)

---

## Prerequisites

### Required Knowledge
- Python 3.8+ (intermediate to advanced)
- Understanding of OOP and functional programming
- Familiarity with `unittest` and `pytest`
- Knowledge of `argparse` or `click` for CLI
- Understanding of logging best practices

### Required Tools

```bash
# Development tools
pip install pytest pytest-cov pytest-mock
pip install black flake8 mypy isort
pip install pre-commit

# Security tools for testing
pip install responses requests-mock vcrpy

# Documentation
pip install sphinx sphinx-rtd-theme
```

### Project Structure

```
bounty-scripts/
├── src/
│   ├── __init__.py
│   ├── recon/
│   │   ├── __init__.py
│   │   ├── subdomain.py
│   │   ├── http_check.py
│   │   └── nuclei_scan.py
│   ├── analysis/
│   │   ├── __init__.py
│   │   ├── findings.py
│   │   └── reporter.py
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── network.py
│   │   ├── output.py
│   │   └── config.py
│   └── cli.py
├── tests/
│   ├── __init__.py
│   ├── test_recon.py
│   ├── test_analysis.py
│   └── test_utils.py
├── config/
│   └── default.yaml
├── pyproject.toml
├── requirements.txt
└── README.md
```

---

## Methodology

### Step 1: Script Template Foundation

```python
#!/usr/bin/env python3
"""
[Script Name] - [Brief description]

Usage:
    python script.py [OPTIONS] TARGET

Example:
    python script.py --threads 20 --output results.json example.com

Author: [Your Name]
License: MIT
Version: 1.0.0
"""

import argparse
import json
import logging
import sys
import time
from pathlib import Path
from typing import List, Optional, Dict, Any
from dataclasses import dataclass, field
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger(__name__)


# ─── Data Models ────────────────────────────────────────────────────

@dataclass
class ScriptConfig:
    """Configuration for the script."""
    target: str
    threads: int = 10
    timeout: int = 300
    output_dir: str = "./results"
    verbose: bool = False
    dry_run: bool = False

    def validate(self):
        """Validate configuration values."""
        if not self.target:
            raise ValueError("Target is required")
        if self.threads < 1 or self.threads > 100:
            raise ValueError(f"Threads must be 1-100, got {self.threads}")
        if self.timeout < 10:
            raise ValueError(f"Timeout must be >= 10, got {self.timeout}")


@dataclass
class Finding:
    """A single security finding."""
    title: str
    severity: str
    host: str
    evidence: str = ""
    recommendation: str = ""
    metadata: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "title": self.title,
            "severity": self.severity,
            "host": self.host,
            "evidence": self.evidence,
            "recommendation": self.recommendation,
            "metadata": self.metadata,
            "timestamp": datetime.now().isoformat()
        }


# ─── Core Functions ─────────────────────────────────────────────────

def process_target(config: ScriptConfig) -> List[Finding]:
    """Main processing logic."""
    findings = []

    logger.info(f"Processing target: {config.target}")
    logger.info(f"Config: threads={config.threads}, timeout={config.timeout}")

    # Your logic here
    # ...

    logger.info(f"Completed: {len(findings)} findings")
    return findings


def save_results(findings: List[Finding], output_path: Path):
    """Save findings to JSON file."""
    output_path.parent.mkdir(parents=True, exist_ok=True)

    data = {
        "findings": [f.to_dict() for f in findings],
        "summary": {
            "total": len(findings),
            "critical": sum(1 for f in findings if f.severity == "critical"),
            "high": sum(1 for f in findings if f.severity == "high"),
            "medium": sum(1 for f in findings if f.severity == "medium"),
            "low": sum(1 for f in findings if f.severity == "low"),
        },
        "generated_at": datetime.now().isoformat()
    }

    with open(output_path, "w") as f:
        json.dump(data, f, indent=2)

    logger.info(f"Results saved to {output_path}")


# ─── CLI ────────────────────────────────────────────────────────────

def parse_args() -> ScriptConfig:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="[Script description]",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    %(prog)s example.com
    %(prog)s --threads 20 --output ./out.json example.com
    %(prog)s --verbose --dry-run example.com
        """
    )
    parser.add_argument("target", help="Target domain or IP")
    parser.add_argument("-t", "--threads", type=int, default=10,
                        help="Number of threads (default: 10)")
    parser.add_argument("--timeout", type=int, default=300,
                        help="Timeout in seconds (default: 300)")
    parser.add_argument("-o", "--output", default="./results/findings.json",
                        help="Output file path")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Enable verbose output")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would be done without executing")

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    return ScriptConfig(
        target=args.target,
        threads=args.threads,
        timeout=args.timeout,
        output_dir=str(Path(args.output).parent),
        verbose=args.verbose,
        dry_run=args.dry_run
    )


def main():
    """Main entry point."""
    config = parse_args()
    config.validate()

    start_time = time.time()

    try:
        findings = process_target(config)
        save_results(findings, Path(config.output_dir) / "findings.json")
        print(f"\nCompleted in {time.time() - start_time:.2f}s")
        print(f"Findings: {len(findings)}")
        sys.exit(0)

    except KeyboardInterrupt:
        logger.warning("Interrupted by user")
        sys.exit(130)
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
```

### Step 2: Input Validation and Sanitization

```python
# utils/validation.py
"""Input validation and sanitization utilities."""

import re
import ipaddress
import urllib.parse
from typing import Optional, Tuple
from pathlib import Path

class InputValidator:
    """Validate and sanitize user inputs."""

    # Regex patterns
    DOMAIN_PATTERN = re.compile(
        r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)'
        r'+[a-zA-Z]{2,}$'
    )
    IP_PATTERN = re.compile(
        r'^(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}'
        r'(?:25[0-5]|2[0-4]\d|[01]?\d\d?)$'
    )

    @classmethod
    def validate_target(cls, target: str) -> Tuple[bool, str]:
        """Validate a target (domain or IP)."""
        target = target.strip().lower()

        if not target:
            return False, "Target cannot be empty"

        if len(target) > 253:
            return False, "Target too long (max 253 chars)"

        if cls.IP_PATTERN.match(target):
            try:
                ip = ipaddress.ip_address(target)
                if ip.is_private:
                    return False, "Private IP addresses not allowed"
                return True, target
            except ValueError:
                return False, "Invalid IP address"

        if cls.DOMAIN_PATTERN.match(target):
            return True, target

        return False, f"Invalid target format: {target}"

    @classmethod
    def sanitize_url(cls, url: str) -> Optional[str]:
        """Sanitize and normalize a URL."""
        parsed = urllib.parse.urlparse(url)
        if not parsed.scheme:
            parsed = urllib.parse.urlparse(f"https://{url}")

        # Block dangerous schemes
        if parsed.scheme not in ("http", "https"):
            return None

        # Reconstruct with safe components
        sanitized = urllib.parse.urlunparse((
            parsed.scheme,
            parsed.netloc.lower(),
            parsed.path,
            parsed.params,
            parsed.query,
            ""  # Remove fragment
        ))
        return sanitized

    @classmethod
    def sanitize_filename(cls, filename: str) -> str:
        """Sanitize a filename for safe file system use."""
        # Remove path separators and dangerous chars
        unsafe = r'[<>:"/\\|?*\x00-\x1f]'
        sanitized = re.sub(unsafe, '_', filename)

        # Limit length
        if len(sanitized) > 200:
            name, ext = sanitized.rsplit('.', 1) if '.' in sanitized else (sanitized, '')
            sanitized = f"{name[:195]}.{ext}" if ext else name[:200]

        return sanitized

    @classmethod
    def validate_port(cls, port: int) -> bool:
        """Validate a port number."""
        return 1 <= port <= 65535

    @classmethod
    def validate_threads(cls, threads: int) -> bool:
        """Validate thread count."""
        return 1 <= threads <= 100

    @classmethod
    def validate_timeout(cls, timeout: int) -> bool:
        """Validate timeout value."""
        return 1 <= timeout <= 3600


# Usage in scripts
def safe_process(target: str):
    """Example of safe input handling."""
    is_valid, result = InputValidator.validate_target(target)
    if not is_valid:
        logger.error(f"Invalid target: {result}")
        sys.exit(1)

    sanitized_url = InputValidator.sanitize_url(f"https://{result}")
    if not sanitized_url:
        logger.error("URL sanitization failed")
        sys.exit(1)

    return sanitized_url
```

### Step 3: Error Handling Patterns

```python
# utils/errors.py
"""Structured error handling for security scripts."""

import logging
import traceback
from typing import Optional, Any
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)


class ErrorSeverity(Enum):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


@dataclass
class ScriptError:
    """Structured error information."""
    message: str
    severity: ErrorSeverity
    component: str
    details: Optional[dict] = None
    recoverable: bool = True

    def log(self):
        log_func = {
            ErrorSeverity.INFO: logger.info,
            ErrorSeverity.WARNING: logger.warning,
            ErrorSeverity.ERROR: logger.error,
            ErrorSeverity.CRITICAL: logger.critical,
        }[self.severity]

        log_func(f"[{self.component}] {self.message}")
        if self.details:
            logger.debug(f"Details: {self.details}")


class ErrorHandler:
    """Centralized error handling with recovery strategies."""

    def __init__(self):
        self.errors: list[ScriptError] = []
        self.max_retries = 3

    def handle(self, error: Exception, component: str,
               context: dict = None) -> ScriptError:
        """Handle an exception and determine recovery strategy."""
        severity = self._classify_error(error)
        recoverable = self._is_recoverable(error)

        script_error = ScriptError(
            message=str(error),
            severity=severity,
            component=component,
            details={
                "error_type": type(error).__name__,
                "context": context or {},
                "traceback": traceback.format_exc()
            },
            recoverable=recoverable
        )

        script_error.log()
        self.errors.append(script_error)
        return script_error

    def _classify_error(self, error: Exception) -> ErrorSeverity:
        error_type = type(error).__name__
        if error_type in ("ConnectionError", "TimeoutError"):
            return ErrorSeverity.WARNING
        elif error_type in ("ValueError", "KeyError"):
            return ErrorSeverity.ERROR
        elif error_type in ("PermissionError",):
            return ErrorSeverity.CRITICAL
        return ErrorSeverity.ERROR

    def _is_recoverable(self, error: Exception) -> bool:
        error_type = type(error).__name__
        recoverable_types = (
            "ConnectionError", "TimeoutError",
            "TemporaryFailure", "ResourceBusy"
        )
        return error_type in recoverable_types

    def should_retry(self, error: ScriptError, attempt: int) -> bool:
        """Determine if operation should be retried."""
        if not error.recoverable:
            return False
        if attempt >= self.max_retries:
            return False
        return True

    def summary(self) -> dict:
        return {
            "total_errors": len(self.errors),
            "by_severity": {
                s.value: sum(1 for e in self.errors if e.severity == s)
                for s in ErrorSeverity
            },
            "recoverable": sum(1 for e in self.errors if e.recoverable),
            "unrecoverable": sum(1 for e in self.errors if not e.recoverable)
        }
```

### Step 4: Logging and Observability

```python
# utils/observability.py
"""Structured logging and metrics collection."""

import logging
import json
import time
from datetime import datetime
from typing import Any, Dict, List, Optional
from contextlib import contextmanager
from functools import wraps

logger = logging.getLogger(__name__)


class StructuredLogger:
    """Logger that outputs structured JSON for analysis."""

    def __init__(self, name: str, log_file: str = None):
        self.name = name
        self.logger = logging.getLogger(name)
        self.metrics: List[Dict] = []

        if log_file:
            handler = logging.FileHandler(log_file)
            handler.setFormatter(
                logging.Formatter('%(message)s')
            )
            self.logger.addHandler(handler)

    def log_event(self, event_type: str, data: Dict[str, Any]):
        """Log a structured event."""
        event = {
            "timestamp": datetime.now().isoformat(),
            "logger": self.name,
            "event_type": event_type,
            **data
        }
        self.logger.info(json.dumps(event))
        self.metrics.append(event)

    def log_tool_execution(self, tool: str, command: str,
                           duration: float, success: bool,
                           output_size: int = 0):
        """Log a tool execution event."""
        self.log_event("tool_execution", {
            "tool": tool,
            "command": command,
            "duration_seconds": duration,
            "success": success,
            "output_bytes": output_size
        })

    def log_finding(self, finding_type: str, severity: str,
                    host: str, details: Dict):
        """Log a security finding."""
        self.log_event("finding", {
            "finding_type": finding_type,
            "severity": severity,
            "host": host,
            "details": details
        })

    def get_metrics_summary(self) -> Dict:
        """Get summary of collected metrics."""
        executions = [m for m in self.metrics if m["event_type"] == "tool_execution"]
        findings = [m for m in self.metrics if m["event_type"] == "finding"]

        return {
            "total_events": len(self.metrics),
            "tool_executions": len(executions),
            "total_duration": sum(m.get("duration_seconds", 0) for m in executions),
            "success_rate": (
                sum(1 for m in executions if m.get("success"))
                / max(len(executions), 1)
            ),
            "findings_count": len(findings),
            "findings_by_severity": {
                sev: sum(1 for f in findings if f.get("severity") == sev)
                for sev in ["critical", "high", "medium", "low", "info"]
            }
        }


@contextmanager
def timer(operation_name: str):
    """Context manager to time operations."""
    start = time.time()
    try:
        yield
    finally:
        duration = time.time() - start
        logger.info(f"{operation_name} completed in {duration:.2f}s")


def timed(func):
    """Decorator to time function execution."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        try:
            result = func(*args, **kwargs)
            duration = time.time() - start
            logger.debug(f"{func.__name__} completed in {duration:.2f}s")
            return result
        except Exception as e:
            duration = time.time() - start
            logger.error(f"{func.__name__} failed after {duration:.2f}s: {e}")
            raise
    return wrapper
```

### Step 5: Testing Framework

```python
# tests/test_recon.py
"""Tests for reconnaissance scripts."""

import pytest
import json
from unittest.mock import patch, MagicMock
from pathlib import Path
import sys

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from recon.subdomain import SubdomainEnumerator
from recon.http_check import HttpChecker
from utils.validation import InputValidator


class TestSubdomainEnumerator:
    """Tests for subdomain enumeration."""

    @pytest.fixture
    def enumerator(self):
        return SubdomainEnumerator(timeout=10, threads=2)

    def test_validate_target_valid(self, enumerator):
        """Test valid target validation."""
        assert InputValidator.validate_target("example.com") == (True, "example.com")
        assert InputValidator.validate_target("sub.example.com") == (True, "sub.example.com")

    def test_validate_target_invalid(self, enumerator):
        """Test invalid target validation."""
        is_valid, msg = InputValidator.validate_target("")
        assert not is_valid

        is_valid, msg = InputValidator.validate_target("192.168.1.1")
        assert not is_valid  # Private IP

    @patch('subprocess.run')
    def test_subfinder_execution(self, mock_run, enumerator):
        """Test subfinder command execution."""
        mock_run.return_value = MagicMock(
            returncode=0,
            stdout="api.example.com\ndev.example.com\n",
            stderr=""
        )

        results = enumerator.enumerate("example.com")
        assert len(results) == 2
        assert "api.example.com" in results

    @patch('subprocess.run')
    def test_subfinder_failure(self, mock_run, enumerator):
        """Test subfinder failure handling."""
        mock_run.return_value = MagicMock(
            returncode=1,
            stdout="",
            stderr="Error: connection refused"
        )

        results = enumerator.enumerate("example.com")
        assert len(results) == 0


class TestHttpChecker:
    """Tests for HTTP checking."""

    @pytest.fixture
    def checker(self):
        return HttpChecker(timeout=10, threads=2)

    @patch('subprocess.run')
    def test_httpx_check(self, mock_run, checker):
        """Test HTTP check with httpx."""
        mock_run.return_value = MagicMock(
            returncode=0,
            stdout=json.dumps({
                "url": "https://example.com",
                "status_code": 200,
                "content_length": 1234
            }) + "\n",
            stderr=""
        )

        results = checker.check(["example.com"])
        assert len(results) == 1
        assert results[0]["status_code"] == 200


class TestIntegration:
    """Integration tests (require network)."""

    @pytest.mark.integration
    def test_full_chain(self):
        """Test complete recon chain (slow, requires network)."""
        pytest.skip("Integration test - requires network")


# pytest configuration
def pytest_configure(config):
    config.addinivalue_line(
        "markers", "integration: marks tests as integration tests"
    )
```

### Step 6: Configuration Management

```python
# utils/config.py
"""Configuration loading and management."""

import os
import yaml
from pathlib import Path
from typing import Any, Dict, Optional
from dataclasses import dataclass, field
from dotenv import load_dotenv

# Load environment variables
load_dotenv()


@dataclass
class ToolConfig:
    """Configuration for a specific tool."""
    binary_path: str = ""
    timeout: int = 300
    threads: int = 10
    extra_args: list = field(default_factory=list)
    env_vars: dict = field(default_factory=dict)


@dataclass
class ScriptConfig:
    """Complete script configuration."""
    target: str = ""
    output_dir: str = "./results"
    log_level: str = "INFO"
    tools: Dict[str, ToolConfig] = field(default_factory=dict)
    rate_limit: int = 10
    retry_count: int = 3
    custom: Dict[str, Any] = field(default_factory=dict)

    @classmethod
    def from_yaml(cls, path: str) -> "ScriptConfig":
        """Load configuration from YAML file."""
        with open(path) as f:
            data = yaml.safe_load(f)

        config = cls()
        config.target = data.get("target", "")
        config.output_dir = data.get("output_dir", "./results")
        config.log_level = data.get("log_level", "INFO")
        config.rate_limit = data.get("rate_limit", 10)
        config.retry_count = data.get("retry_count", 3)
        config.custom = data.get("custom", {})

        for tool_name, tool_data in data.get("tools", {}).items():
            config.tools[tool_name] = ToolConfig(**tool_data)

        return config

    @classmethod
    def from_env(cls) -> "ScriptConfig":
        """Load configuration from environment variables."""
        return cls(
            target=os.getenv("TARGET", ""),
            output_dir=os.getenv("OUTPUT_DIR", "./results"),
            log_level=os.getenv("LOG_LEVEL", "INFO"),
            rate_limit=int(os.getenv("RATE_LIMIT", "10")),
        )

    def get_tool_config(self, tool_name: str) -> ToolConfig:
        """Get configuration for a specific tool."""
        return self.tools.get(tool_name, ToolConfig())

    def validate(self):
        """Validate the configuration."""
        if not self.target:
            raise ValueError("TARGET is required")
        if self.rate_limit < 1:
            raise ValueError("RATE_LIMIT must be >= 1")
```

---

## Tool Arsenal

### Code Quality Tools

```bash
# Formatting
black src/ tests/           # Auto-format code
isort src/ tests/           # Sort imports

# Linting
flake8 src/ tests/          # Style checking
pylint src/                 # Deep analysis

# Type checking
mypy src/                   # Static type analysis
pyright src/                # Fast type checker

# Security
bandit -r src/              # Security linting
safety check                # Dependency vulnerability scan

# Testing
pytest tests/ -v            # Run tests
pytest --cov=src/ tests/    # With coverage
pytest -m "not integration" # Skip slow tests
```

### Quick Commands

```bash
# Format and lint
black src/ tests/ && isort src/ tests/ && flake8 src/ tests/

# Run all checks
mypy src/ && pytest tests/ -v && bandit -r src/

# Generate test coverage report
pytest --cov=src/ --cov-report=html tests/
open htmlcov/index.html

# Type check with strict mode
mypy src/ --strict

# Security scan
bandit -r src/ -ll  # Only medium+ severity
```

---

## Real-World Examples

### Example 1: Production-Grade Subdomain Scanner

```python
#!/usr/bin/env python3
"""Production-grade subdomain scanner with full error handling."""

import json
import logging
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional, Set

from utils.validation import InputValidator
from utils.errors import ErrorHandler
from utils.observability import StructuredLogger, timed

logger = logging.getLogger(__name__)
obs = StructuredLogger("subdomain_scanner")


@dataclass
class ScanResult:
    subdomains: Set[str]
    sources_used: int
    duration: float
    errors: List[str]


class SubdomainScanner:
    def __init__(self, threads: int = 20, timeout: int = 300):
        self.threads = threads
        self.timeout = timeout
        self.error_handler = ErrorHandler()

    @timed
    def scan(self, target: str) -> ScanResult:
        """Perform full subdomain enumeration."""
        is_valid, target = InputValidator.validate_target(target)
        if not is_valid:
            raise ValueError(f"Invalid target: {target}")

        logger.info(f"Starting subdomain scan for {target}")
        all_subdomains: Set[str] = set()
        errors: List[str] = []

        # Tool 1: subfinder
        try:
            subs = self._run_subfinder(target)
            all_subdomains.update(subs)
            logger.info(f"subfinder found {len(subs)} subdomains")
        except Exception as e:
            error = self.error_handler.handle(e, "subfinder", {"target": target})
            errors.append(str(e))

        # Tool 2: crt.sh (via API)
        try:
            subs = self._query_crtsh(target)
            all_subdomains.update(subs)
            logger.info(f"crt.sh found {len(subs)} subdomains")
        except Exception as e:
            errors.append(str(e))

        # Tool 3: dns brute force (lightweight)
        try:
            subs = self._dns_brute(target)
            all_subdomains.update(subs)
            logger.info(f"dns brute found {len(subs)} subdomains")
        except Exception as e:
            errors.append(str(e))

        return ScanResult(
            subdomains=all_subdomains,
            sources_used=3 - len(errors),
            duration=0,  # Set by @timed
            errors=errors
        )

    def _run_subfinder(self, target: str) -> List[str]:
        """Run subfinder and parse output."""
        cmd = [
            "subfinder", "-d", target,
            "-silent", "-timeout", str(self.timeout)
        ]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=self.timeout + 10
        )
        if result.returncode != 0:
            raise RuntimeError(f"subfinder failed: {result.stderr}")

        return [
            line.strip()
            for line in result.stdout.strip().split("\n")
            if line.strip()
        ]

    def _query_crtsh(self, target: str) -> List[str]:
        """Query crt.sh for certificate transparency logs."""
        import urllib.request
        url = f"https://crt.sh/?q=%.{target}&output=json"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})

        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read())

        subdomains = set()
        for entry in data:
            name = entry.get("name_value", "")
            for sub in name.split("\n"):
                sub = sub.strip().lower()
                if sub.endswith(f".{target}") or sub == target:
                    subdomains.add(sub)

        return list(subdomains)

    def _dns_brute(self, target: str, wordlist: str = None) -> List[str]:
        """Lightweight DNS brute force."""
        common = [
            "www", "mail", "ftp", "api", "dev", "staging",
            "test", "admin", "portal", "vpn", "remote"
        ]
        found = []
        import socket
        for prefix in common:
            fqdn = f"{prefix}.{target}"
            try:
                socket.getaddrinfo(fqdn, None, socket.AF_INET)
                found.append(fqdn)
            except socket.gaierror:
                continue
        return found


if __name__ == "__main__":
    scanner = SubdomainScanner(threads=20)
    result = scanner.scan("example.com")

    print(f"\nScan complete:")
    print(f"  Subdomains found: {len(result.subdomains)}")
    print(f"  Sources used: {result.sources_used}")
    print(f"  Errors: {len(result.errors)}")

    # Save results
    output = Path("./results/subdomains.json")
    output.parent.mkdir(parents=True, exist_ok=True)
    with open(output, "w") as f:
        json.dump(sorted(result.subdomains), f, indent=2)
```

---

## Common Pitfalls

### Pitfall 1: Bare `except:` Clauses
```python
# BAD
try:
    do_something()
except:
    pass  # Silently swallows ALL errors

# GOOD
try:
    do_something()
except ConnectionError as e:
    logger.warning(f"Connection failed: {e}")
except TimeoutError as e:
    logger.error(f"Timeout: {e}")
except Exception as e:
    logger.critical(f"Unexpected error: {e}", exc_info=True)
```

### Pitfall 2: Hardcoded Paths
```python
# BAD
subprocess.run(["subfinder", "-d", target, "-o", "/tmp/output.txt"])

# GOOD
import tempfile
with tempfile.NamedTemporaryFile(suffix=".txt", delete=False) as f:
    output_path = f.name
subprocess.run(["subfinder", "-d", target, "-o", output_path])
```

### Pitfall 3: No Timeouts
```python
# BAD
result = subprocess.run(["nmap", "-sV", target], capture_output=True)

# GOOD
result = subprocess.run(
    ["nmap", "-sV", target],
    capture_output=True,
    timeout=600  # 10 minute timeout
)
```

### Pitfall 4: Using `shell=True`
```python
# BAD (security risk - command injection)
subprocess.run(f"subfinder -d {target}", shell=True)

# GOOD (safe - no shell interpretation)
subprocess.run(["subfinder", "-d", target])
```

### Pitfall 5: Print Statements for Logging
```python
# BAD
print(f"Found {count} results")

# GOOD
logger.info(f"Found {count} results")
```

### Pitfall 6: No Docstrings
```python
# BAD
def process(data):
    return [x for x in data if x > 0]

# GOOD
def filter_positive_numbers(data: List[int]) -> List[int]:
    """Filter list to only include positive numbers.

    Args:
        data: List of integers to filter.

    Returns:
        List of positive integers from input.

    Example:
        >>> filter_positive_numbers([-1, 0, 1, 2])
        [1, 2]
    """
    return [x for x in data if x > 0]
```

### Pitfall 7: Ignoring Type Hints
```python
# BAD
def scan(target, threads=10, timeout=300):
    pass

# GOOD
def scan(target: str, threads: int = 10, timeout: int = 300) -> List[Finding]:
    pass
```

---

## Advanced Techniques

### 1. Plugin Architecture

```python
# plugins/base.py
"""Base class for scanner plugins."""

from abc import ABC, abstractmethod
from typing import List, Dict, Any

class ScannerPlugin(ABC):
    """Abstract base class for scanner plugins."""

    @property
    @abstractmethod
    def name(self) -> str:
        """Plugin name."""

    @property
    @abstractmethod
    def version(self) -> str:
        """Plugin version."""

    @abstractmethod
    def scan(self, target: str, config: Dict[str, Any]) -> List[Dict]:
        """Execute scan and return findings."""

    def validate_config(self, config: Dict[str, Any]) -> bool:
        """Validate plugin configuration."""
        return True


# plugins/subfinder_plugin.py
class SubfinderPlugin(ScannerPlugin):
    @property
    def name(self) -> str:
        return "subfinder"

    @property
    def version(self) -> str:
        return "1.0.0"

    def scan(self, target: str, config: Dict[str, Any]) -> List[Dict]:
        # Plugin implementation
        pass


# Plugin registry
class PluginRegistry:
    def __init__(self):
        self._plugins: Dict[str, ScannerPlugin] = {}

    def register(self, plugin: ScannerPlugin):
        self._plugins[plugin.name] = plugin

    def get(self, name: str) -> ScannerPlugin:
        return self._plugins.get(name)

    def list_plugins(self) -> List[str]:
        return list(self._plugins.keys())
```

### 2. Async Tool Execution

```python
import asyncio
import aiohttp

class AsyncScanner:
    """Async scanner for I/O-bound operations."""

    async def check_host(self, url: str, session: aiohttp.ClientSession) -> dict:
        """Check if a host is alive."""
        try:
            async with session.get(url, timeout=aiohttp.ClientTimeout(total=10)) as resp:
                return {
                    "url": url,
                    "status": resp.status,
                    "alive": resp.status < 500
                }
        except Exception as e:
            return {"url": url, "status": 0, "alive": False, "error": str(e)}

    async def scan_hosts(self, hosts: List[str]) -> List[dict]:
        """Scan multiple hosts concurrently."""
        async with aiohttp.ClientSession() as session:
            tasks = [self.check_host(h, session) for h in hosts]
            return await asyncio.gather(*tasks, return_exceptions=True)
```

### 3. Data Pipeline with Generators

```python
def read_targets(file_path: str):
    """Generator to read targets from file."""
    with open(file_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                yield line

def process_targets(targets):
    """Generator to process targets lazily."""
    for target in targets:
        result = scan_target(target)
        if result:
            yield result

def save_results(results, output_path: str):
    """Consume generator and save results."""
    with open(output_path, "w") as f:
        for result in results:
            f.write(json.dumps(result) + "\n")

# Usage: memory-efficient processing
targets = read_targets("targets.txt")
processed = process_targets(targets)
save_results(processed, "results.jsonl")
```

### 4. Script Composition

```python
# compose.py
"""Compose multiple scripts into complex workflows."""

from typing import Callable, List

class ScriptComposer:
    def __init__(self):
        self.steps: List[Callable] = []

    def add_step(self, func: Callable) -> "ScriptComposer":
        self.steps.append(func)
        return self

    def execute(self, initial_input):
        """Execute all steps in sequence."""
        result = initial_input
        for step in self.steps:
            result = step(result)
        return result

# Usage
composer = (
    ScriptComposer()
    .add_step(lambda target: subfinder_scan(target))
    .add_step(lambda subs: httpx_check(subs))
    .add_step(lambda hosts: nuclei_scan(hosts))
    .add_step(lambda findings: generate_report(findings))
)

result = composer.execute("example.com")
```

---

## Reporting Template

### Script Quality Report

```markdown
# Script Quality Report

## Script: {script_name}
- **Lines of Code**: {loc}
- **Cyclomatic Complexity**: {complexity}
- **Test Coverage**: {coverage}%
- **Type Coverage**: {type_coverage}%
- **Security Issues**: {security_issues}

## Code Quality Metrics
| Metric | Value | Status |
|--------|-------|--------|
| Black formatting | {black_status} | PASS/FAIL |
| Flake8 | {flake8_issues} issues | PASS/FAIL |
| MyPy | {mypy_errors} errors | PASS/FAIL |
| Bandit | {bandit_issues} issues | PASS/FAIL |
| Test Coverage | {coverage}% | PASS/FAIL |

## Recommendations
1. {recommendation_1}
2. {recommendation_2}
3. {recommendation_3}
```

---

## Quick Reference

### One-Liner Commands

```bash
# Format code
black src/ tests/ && isort src/ tests/

# Lint code
flake8 src/ tests/ --max-line-length 100

# Type check
mypy src/ --strict

# Security scan
bandit -r src/ -ll

# Run tests with coverage
pytest --cov=src/ --cov-report=term-missing tests/

# Full quality check
black --check src/ tests/ && flake8 src/ tests/ && mypy src/ && pytest tests/
```

### Code Quality Checklist

```yaml
before_commit:
  - [ ] Code formatted with black
  - [ ] Imports sorted with isort
  - [ ] No flake8 errors
  - [ ] No mypy errors
  - [ ] No bandit security issues
  - [ ] Tests pass
  - [ ] Coverage > 80%
  - [ ] Docstrings present
  - [ ] Type hints present
  - [ ] Error handling implemented
  - [ ] Logging configured
  - [ ] No hardcoded secrets
```

### Project Structure Template

```
project/
├── src/
│   ├── __init__.py
│   ├── main.py
│   ├── core/
│   ├── utils/
│   └── plugins/
├── tests/
│   ├── __init__.py
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── config/
├── docs/
├── pyproject.toml
├── requirements.txt
└── README.md
```

---

*Document Version: 1.0 | Last Updated: 2026 | Automation-Efficiency Series*
