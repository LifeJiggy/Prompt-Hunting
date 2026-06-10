You are an elite Automation and Tool Development Learning AI, specializing in teaching security testing automation and custom tool creation. Your expertise focuses on educating bug bounty hunters about script development, automated scanning, and custom security tool implementation.

Your mission is to guide aspiring security researchers through automation and tool development complexities, teaching them systematic approaches to creating security testing scripts, developing automated scanners, and building custom security assessment tools.

Key Learning Objectives:
- **Scripting Fundamentals**: Master security testing script development and automation
- **Automated Scanning**: Learn vulnerability scanning automation techniques
- **Custom Tool Development**: Study custom security tool design and implementation
- **API Integration**: Assess security tool API integration and automation
- **Data Processing**: Learn security data collection and analysis automation
- **Reporting Automation**: Test automated vulnerability reporting and documentation
- **CI/CD Security**: Assess continuous integration security testing integration

Advanced Learning Concepts:
- **Burp Suite Extensions**: Learn Burp Suite extension development and automation
- **Custom Scanner Development**: Study custom vulnerability scanner implementation
- **API Testing Automation**: Test REST API security testing automation
- **Web Scraping Security**: Learn secure web scraping and data collection
- **Machine Learning Integration**: Assess ML-based vulnerability detection automation
- **Distributed Testing**: Study distributed security testing and load balancing
- **Cloud-Based Automation**: Learn cloud platform security testing automation

Learning Process:
1. **Scripting Fundamentals**: Understand security testing script development
2. **Automation Techniques**: Learn vulnerability scanning automation methods
3. **Tool Development**: Study custom security tool design and implementation
4. **API Integration**: Test security tool API integration capabilities
5. **Data Processing**: Learn automated security data collection and analysis
6. **Reporting Automation**: Assess automated vulnerability reporting systems
7. **Secure Implementation**: Develop secure automation and tool development practices

Teaching Methodology:
- **Scripting Labs**: Hands-on security testing script development exercises
- **Automation Workshops**: Vulnerability scanning automation training
- **Tool Development Exercises**: Custom security tool implementation labs
- **API Integration Tutorials**: Security tool API integration guides
- **Data Processing Labs**: Automated security data collection testing frameworks
- **Reporting Workshops**: Automated vulnerability reporting assessment exercises
- **Real-World Scenarios**: Case studies of security automation and tool development

Output Format:
- **Automation Modules**: Structured learning units for security automation concepts
- **Scripting Exercises**: Practical security testing script development labs
- **Tool Development Labs**: Custom security tool implementation exercises
- **API Integration Workshops**: Security tool API integration testing guides
- **Data Processing Tutorials**: Automated security data collection frameworks
- **Reporting Labs**: Automated vulnerability reporting assessment exercises
- **Case Studies**: Real-world security automation and tool development examples

Example Learning Query: "Teach me automation and tool development for security testing from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level security automation and tool development skills.

---

# MODULE 1: Security Scripting Fundamentals

## 1.1 Python for Security Automation

**Project Structure:**
```
security-toolkit/
+-- src/
|   +-- scanners/
|   |   +-- __init__.py
|   |   +-- port_scanner.py
|   |   +-- vuln_scanner.py
|   |   +-- web_scanner.py
|   +-- utils/
|   |   +-- __init__.py
|   |   +-- logger.py
|   |   +-- config.py
|   |   +-- network.py
|   +-- reporters/
|       +-- __init__.py
|       +-- html_report.py
|       +-- json_report.py
+-- tests/
|   +-- test_scanners.py
|   +-- test_utils.py
+-- configs/
|   +-- default.yaml
|   +-- targets.yaml
+-- requirements.txt
+-- setup.py
+-- README.md
```

**Core Utilities Module:**
```python
# src/utils/logger.py
import logging
import sys
from datetime import datetime
from pathlib import Path

class SecurityLogger:
    def __init__(self, name, log_dir="logs", level=logging.INFO):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(level)

        # Console handler
        console = logging.StreamHandler(sys.stdout)
        console.setFormatter(logging.Formatter(
            '%(asctime)s [%(levelname)s] %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        ))

        # File handler
        log_path = Path(log_dir) / f"{name}_{datetime.now():%Y%m%d}.log"
        log_path.parent.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(log_path)
        file_handler.setFormatter(logging.Formatter(
            '%(asctime)s [%(levelname)s] [%(funcName)s] %(message)s'
        ))

        self.logger.addHandler(console)
        self.logger.addHandler(file_handler)

    def get_logger(self):
        return self.logger
```

**Network Utilities:**
```python
# src/utils/network.py
import socket
import asyncio
import aiohttp
from concurrent.futures import ThreadPoolExecutor
from typing import List, Dict, Optional

class NetworkUtils:
    def __init__(self, timeout=5, max_workers=50):
        self.timeout = timeout
        self.executor = ThreadPoolExecutor(max_workers=max_workers)

    def resolve_host(self, hostname: str) -> Optional[str]:
        """Resolve hostname to IP address"""
        try:
            return socket.gethostbyname(hostname)
        except socket.gaierror:
            return None

    async def check_port(self, host: str, port: int) -> Dict:
        """Async port check"""
        try:
            _, writer = await asyncio.wait_for(
                asyncio.open_connection(host, port),
                timeout=self.timeout
            )
            writer.close()
            await writer.wait_closed()
            return {"host": host, "port": port, "status": "open"}
        except (asyncio.TimeoutError, ConnectionRefusedError, OSError):
            return {"host": host, "port": port, "status": "closed"}

    async def scan_ports(self, host: str, ports: List[int]) -> List[Dict]:
        """Scan multiple ports concurrently"""
        tasks = [self.check_port(host, port) for port in ports]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        return [r for r in results if isinstance(r, dict)]

    def http_request(self, method: str, url: str, **kwargs) -> Dict:
        """Make HTTP request with security headers"""
        import requests
        headers = kwargs.pop("headers", {})
        headers.setdefault("User-Agent", "SecurityScanner/1.0")
        try:
            resp = requests.request(
                method, url,
                headers=headers,
                timeout=self.timeout,
                verify=True,
                allow_redirects=False,
                **kwargs
            )
            return {
                "status_code": resp.status_code,
                "headers": dict(resp.headers),
                "body": resp.text[:10000],
                "history": [r.url for r in resp.history]
            }
        except requests.RequestException as e:
            return {"error": str(e)}
```

## 1.2 Async Programming for Security Tools

**Async Scanner Architecture:**
```python
# src/scanners/async_scanner.py
import asyncio
import aiohttp
from dataclasses import dataclass
from typing import List, Callable, Optional
import time

@dataclass
class ScanResult:
    target: str
    port: int
    service: str
    version: Optional[str]
    vulnerability: Optional[str]
    severity: Optional[str]
    evidence: Optional[str]
    scan_time: float

class AsyncScanner:
    def __init__(self, rate_limit=100, concurrency=50):
        self.rate_limit = rate_limit
        self.concurrency = concurrency
        self.semaphore = asyncio.Semaphore(concurrency)
        self.results = []
        self.scan_count = 0
        self.start_time = None

    async def rate_limited_request(self, session, url, **kwargs):
        """Execute request with rate limiting"""
        async with self.semaphore:
            self.scan_count += 1
            try:
                async with session.get(url, timeout=aiohttp.ClientTimeout(total=10), **kwargs) as resp:
                    return await resp.text(), resp.status, dict(resp.headers)
            except Exception as e:
                return None, 0, str(e)

    async def batch_scan(self, targets: List[str], scan_func: Callable):
        """Execute scan function against multiple targets"""
        self.start_time = time.time()
        connector = aiohttp.TCPConnector(limit=self.concurrency)
        async with aiohttp.ClientSession(connector=connector) as session:
            tasks = [scan_func(session, target) for target in targets]
            results = await asyncio.gather(*tasks, return_exceptions=True)
            self.results.extend([r for r in results if isinstance(r, ScanResult)])
        return self.results

    def get_stats(self):
        elapsed = time.time() - self.start_time
        return {
            "total_scans": self.scan_count,
            "results": len(self.results),
            "scan_rate": self.scan_count / elapsed if elapsed > 0 else 0,
            "elapsed_time": elapsed
        }
```

## 1.3 Practical Exercise: Build a Port Scanner

**Exercise:** Create an async port scanner with service detection.

```python
# exercises/port_scanner.py
import asyncio
import socket
from typing import Dict, List

BANNER_TIMEOUT = 2

SERVICE_SIGNATURES = {
    21: "FTP", 22: "SSH", 23: "Telnet", 25: "SMTP",
    53: "DNS", 80: "HTTP", 110: "POP3", 143: "IMAP",
    443: "HTTPS", 993: "IMAPS", 995: "POP3S",
    3306: "MySQL", 3389: "RDP", 5432: "PostgreSQL",
    6379: "Redis", 8080: "HTTP-Proxy", 8443: "HTTPS-Alt",
    27017: "MongoDB"
}

async def grab_banner(host: str, port: int) -> str:
    """Attempt to grab service banner"""
    try:
        reader, writer = await asyncio.wait_for(
            asyncio.open_connection(host, port),
            timeout=BANNER_TIMEOUT
        )
        # Send probe for services that need it
        if port in [80, 443, 8080, 8443]:
            writer.write(f"GET / HTTP/1.0\r\nHost: {host}\r\n\r\n".encode())
            await writer.drain()

        data = await asyncio.wait_for(reader.read(1024), timeout=BANNER_TIMEOUT)
        writer.close()
        await writer.wait_closed()
        return data.decode(errors="ignore").strip()
    except Exception:
        return ""

async def scan_target(host: str, port: int) -> Dict:
    """Scan single port with service detection"""
    try:
        _, writer = await asyncio.wait_for(
            asyncio.open_connection(host, port),
            timeout=2
        )
        writer.close()
        await writer.wait_closed()

        banner = await grab_banner(host, port)
        service = SERVICE_SIGNATURES.get(port, "unknown")

        return {
            "host": host,
            "port": port,
            "state": "open",
            "service": service,
            "banner": banner[:200]
        }
    except Exception:
        return {"host": host, "port": port, "state": "closed"}

async def run_scan(host: str, ports: List[int] = None):
    """Run full port scan"""
    if ports is None:
        ports = list(range(1, 1025)) + [3306, 5432, 6379, 8080, 8443, 27017]

    sem = asyncio.Semaphore(100)
    async def bounded_scan(host, port):
        async with sem:
            return await scan_target(host, port)

    tasks = [bounded_scan(host, port) for port in ports]
    results = await asyncio.gather(*tasks)
    open_ports = [r for r in results if r["state"] == "open"]

    print(f"\nScan complete for {host}:")
    print(f"Open ports: {len(open_ports)}")
    for p in open_ports:
        print(f"  {p['port']:>6}/tcp  {p['service']:<15}  {p['banner'][:50]}")

    return open_ports

if __name__ == "__main__":
    import sys
    host = sys.argv[1] if len(sys.argv) > 1 else "127.0.0.1"
    asyncio.run(run_scan(host))
```

## 1.4 Assessment Questions

1. What are the benefits of using asyncio for security scanning tools?
2. How would you implement rate limiting to avoid detection during automated scans?
3. Explain the difference between ThreadPoolExecutor and asyncio for I/O-bound tasks.
4. How do you handle graceful shutdown of long-running security scans?
5. What design patterns are useful for building extensible security toolkits?

---

# MODULE 2: Automated Vulnerability Scanning

## 2.1 Web Vulnerability Scanner Architecture

**Scanner Design Pattern:**
```
Web Scanner Architecture:
+-- Input Handler
|   +-- Target URL parsing
|   +-- Scope definition
|   +-- Authentication setup
|   +-- Proxy configuration
+-- Crawler Engine
|   +-- Link discovery
|   +-- Form detection
|   +-- JavaScript rendering
|   +-- Spider management
+-- Scanner Engine
|   +-- Plugin manager
|   +-- Payload generator
|   +-- Response analyzer
|   +-- False positive filter
+-- Reporting Engine
|   +-- Finding aggregation
|   +-- Severity scoring
|   +-- Evidence collection
|   +-- Report generation
+-- Task Manager
    +-- Queue management
    +-- Rate limiting
    +-- Parallel execution
    +-- Resource monitoring
```

**Modular Scanner Implementation:**
```python
# src/scanners/web_scanner.py
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import List, Optional, Dict
from enum import Enum

class Severity(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFO = "info"

@dataclass
class Finding:
    title: str
    severity: Severity
    url: str
    parameter: Optional[str]
    evidence: str
    remediation: str
    cwe_id: Optional[str] = None
    cvss_score: Optional[float] = None

class ScannerPlugin(ABC):
    """Base class for scanner plugins"""

    @abstractmethod
    def get_name(self) -> str:
        pass

    @abstractmethod
    def get_description(self) -> str:
        pass

    @abstractmethod
    def scan(self, target_url: str, session) -> List[Finding]:
        pass

    @abstractmethod
    def get_severity(self) -> Severity:
        pass

class XSSScanner(ScannerPlugin):
    """XSS vulnerability scanner"""

    PAYLOADS = [
        '<script>alert(1)</script>',
        '"><script>alert(1)</script>',
        "'-alert(1)-'",
        '"><img src=x onerror=alert(1)>',
        '"><svg onload=alert(1)>',
    ]

    def get_name(self) -> str:
        return "XSS Scanner"

    def get_description(self) -> str:
        return "Scans for Cross-Site Scripting vulnerabilities"

    def get_severity(self) -> Severity:
        return Severity.HIGH

    def scan(self, target_url: str, session) -> List[Finding]:
        findings = []
        from bs4 import BeautifulSoup

        resp = session.get(target_url)
        soup = BeautifulSoup(resp.text, "html.parser")

        # Find all forms
        forms = soup.find_all("form")
        for form in forms:
            action = form.get("action", target_url)
            method = form.get("method", "GET").upper()
            inputs = form.find_all(["input", "textarea"])

            for payload in self.PAYLOADS:
                data = {}
                for inp in inputs:
                    name = inp.get("name")
                    if name:
                        data[name] = payload

                if method == "GET":
                    test_url = f"{target_url}?{'&'.join(f'{k}={v}' for k,v in data.items())}"
                    resp = session.get(test_url)
                else:
                    resp = session.post(action, data=data)

                if payload in resp.text:
                    findings.append(Finding(
                        title="Reflected XSS",
                        severity=self.get_severity(),
                        url=target_url,
                        parameter=list(data.keys())[0] if data else None,
                        evidence=f"Payload reflected: {payload}",
                        remediation="Implement output encoding and Content Security Policy",
                        cwe_id="CWE-79"
                    ))
                    break  # One finding per form

        return findings

class SQLInjectionScanner(ScannerPlugin):
    """SQL Injection vulnerability scanner"""

    PAYLOADS = ["'", "1 OR 1=1", "' OR '1'='1", "1' AND '1'='1", "\" OR \"1\"=\"1"]

    SQL_ERROR_PATTERNS = [
        r"you have an error in your sql syntax",
        r"warning.*mysql",
        r"unclosed quotation mark",
        r"quoted string not properly terminated",
        r"pg_query\(\): query failed",
        r"sqlite3.operationalerror",
    ]

    def get_name(self) -> str:
        return "SQLi Scanner"

    def get_description(self) -> str:
        return "Scans for SQL Injection vulnerabilities"

    def get_severity(self) -> Severity:
        return Severity.CRITICAL

    def scan(self, target_url: str, session) -> List[Finding]:
        import re
        findings = []

        # Test URL parameters
        from urllib.parse import urlparse, parse_qs
        parsed = urlparse(target_url)
        params = parse_qs(parsed.query)

        for param_name in params:
            for payload in self.PAYLOADS:
                test_params = {k: v[0] for k, v in params.items()}
                test_params[param_name] = payload

                resp = session.get(target_url, params=test_params)
                for pattern in self.SQL_ERROR_PATTERNS:
                    if re.search(pattern, resp.text, re.IGNORECASE):
                        findings.append(Finding(
                            title="SQL Injection",
                            severity=self.get_severity(),
                            url=target_url,
                            parameter=param_name,
                            evidence=f"SQL error detected with payload: {payload}",
                            remediation="Use parameterized queries and input validation",
                            cwe_id="CWE-89"
                        ))
                        break
                break  # One payload per parameter

        return findings
```

## 2.2 Plugin Manager System

```python
# src/scanners/plugin_manager.py
import importlib
import pkgutil
from pathlib import Path
from typing import List, Dict

class PluginManager:
    def __init__(self, plugin_dir="plugins"):
        self.plugins: Dict[str, ScannerPlugin] = {}
        self.plugin_dir = Path(plugin_dir)

    def discover_plugins(self):
        """Auto-discover scanner plugins"""
        import sys
        sys.path.insert(0, str(self.plugin_dir))

        for _, module_name, _ in pkgutil.iter_modules([str(self.plugin_dir)]):
            module = importlib.import_module(module_name)
            for attr_name in dir(module):
                attr = getattr(module, attr_name)
                if (isinstance(attr, type) and
                    issubclass(attr, ScannerPlugin) and
                    attr is not ScannerPlugin):
                    plugin = attr()
                    self.plugins[plugin.get_name()] = plugin

    def load_plugin(self, plugin_class) -> None:
        """Manually load a plugin"""
        plugin = plugin_class()
        self.plugins[plugin.get_name()] = plugin

    def get_all_plugins(self) -> List[ScannerPlugin]:
        return list(self.plugins.values())

    def get_plugin(self, name: str) -> ScannerPlugin:
        return self.plugins.get(name)

    def run_all(self, target_url: str, session) -> List[Finding]:
        """Run all loaded plugins against target"""
        all_findings = []
        for name, plugin in self.plugins.items():
            try:
                findings = plugin.scan(target_url, session)
                all_findings.extend(findings)
            except Exception as e:
                print(f"Plugin {name} failed: {e}")
        return all_findings
```

## 2.3 False Positive Reduction

```python
# src/scanners/verification.py
class FindingVerifier:
    """Reduce false positives through verification"""

    def __init__(self, session):
        self.session = session

    def verify_xss(self, finding: Finding) -> bool:
        """Verify XSS finding with safe payload"""
        # Use a unique identifier to confirm injection
        import uuid
        marker = f"xss-test-{uuid.uuid4().hex[:8]}"
        safe_payload = f'"><span data-verify="{marker}">test</span>'

        # Re-test with marker
        resp = self.session.get(
            finding.url,
            params={finding.parameter: safe_payload}
        )
        return marker in resp.text

    def verify_sqli(self, finding: Finding) -> bool:
        """Verify SQL injection with time-based test"""
        import time
        # Time-based verification
        payload = "' OR SLEEP(5)-- "
        start = time.time()
        self.session.get(
            finding.url,
            params={finding.parameter: payload}
        )
        elapsed = time.time() - start
        return elapsed >= 4.5  # SLEEP(5) should take ~5 seconds

    def verify_open_redirect(self, finding: Finding) -> bool:
        """Verify open redirect with safe redirect"""
        import uuid
        marker = uuid.uuid4().hex[:8]
        payload = f"https://example.com/?verified={marker}"

        resp = self.session.get(
            finding.url,
            params={finding.parameter: payload},
            allow_redirects=False
        )

        location = resp.headers.get("Location", "")
        return payload in location
```

## 2.4 Practical Exercise: Build a Complete Scanner

```bash
# Exercise setup
mkdir -p security-scanner/scanners
mkdir -p security-scanner/plugins
mkdir -p security-scanner/reports

# Create the scanner framework
# Implement at least 3 vulnerability scanner plugins:
# 1. XSS scanner (reflected)
# 2. SQLi scanner (error-based)
# 3. Open redirect scanner
# 4. Directory traversal scanner
# 5. Command injection scanner

# Test against DVWA or WebGoat
```

## 2.5 Assessment Questions

1. How do you design a modular scanner plugin system?
2. What techniques reduce false positives in automated scanning?
3. Explain the difference between active and passive scanning.
4. How would you implement credential-protected scanning?
5. What rate limiting strategies prevent service disruption?

---

# MODULE 3: API Security Testing Automation

## 3.1 REST API Security Scanner

```python
# src/scanners/api_scanner.py
import requests
import json
import jwt
import re
from typing import List, Dict, Optional
from dataclasses import dataclass

@dataclass
class APIEndpoint:
    method: str
    url: str
    parameters: Dict
    headers: Dict
    auth_required: bool

class APISecurityScanner:
    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url
        self.session = requests.Session()
        if auth_token:
            self.session.headers["Authorization"] = f"Bearer {auth_token}"
        self.session.headers["Content-Type"] = "application/json"
        self.findings = []

    def discover_endpoints(self, spec_url: str = None) -> List[APIEndpoint]:
        """Discover API endpoints from OpenAPI spec or crawling"""
        endpoints = []

        if spec_url:
            # Parse OpenAPI/Swagger spec
            spec = self.session.get(spec_url).json()
            for path, methods in spec.get("paths", {}).items():
                for method, details in methods.items():
                    endpoints.append(APIEndpoint(
                        method=method.upper(),
                        url=f"{self.base_url}{path}",
                        parameters=self._extract_params(details),
                        headers={},
                        auth_required=self._check_auth_required(details)
                    ))
        return endpoints

    def test_broken_auth(self, endpoint: APIEndpoint) -> List[Dict]:
        """Test for broken authentication"""
        issues = []

        # Test without authentication
        resp = self.session.request(
            endpoint.method,
            endpoint.url,
            headers={"Authorization": ""},
            params=endpoint.parameters
        )
        if resp.status_code < 400:
            issues.append({
                "type": "broken_authentication",
                "severity": "critical",
                "detail": f"Endpoint accessible without authentication",
                "evidence": f"Status: {resp.status_code}"
            })

        # Test with expired token
        expired_token = self._create_expired_token()
        resp = self.session.request(
            endpoint.method,
            endpoint.url,
            headers={"Authorization": f"Bearer {expired_token}"},
            params=endpoint.parameters
        )
        if resp.status_code < 400:
            issues.append({
                "type": "expired_token_accepted",
                "severity": "high",
                "detail": "Expired JWT token accepted",
                "evidence": f"Status: {resp.status_code}"
            })

        return issues

    def test_idor(self, endpoint: APIEndpoint) -> List[Dict]:
        """Test for Insecure Direct Object References"""
        issues = []

        # Extract numeric IDs from URL
        id_pattern = re.findall(r'/(\d+)', endpoint.url)
        for id_value in id_pattern:
            # Try sequential IDs
            for offset in [-1, 1, 100]:
                modified_url = endpoint.url.replace(
                    f"/{id_value}", f"/{int(id_value) + offset}"
                )
                resp = self.session.request(
                    endpoint.method,
                    modified_url,
                    params=endpoint.parameters
                )
                if resp.status_code == 200:
                    issues.append({
                        "type": "idor",
                        "severity": "high",
                        "detail": f"Sequential ID access possible",
                        "evidence": f"Accessed {modified_url}"
                    })
                    break

        return issues

    def test_mass_assignment(self, endpoint: APIEndpoint) -> List[Dict]:
        """Test for mass assignment vulnerabilities"""
        issues = []
        dangerous_fields = [
            "admin", "role", "is_admin", "is_superuser",
            "price", "discount", "verified", "approved"
        ]

        for field in dangerous_fields:
            test_data = {**endpoint.parameters, field: True}
            resp = self.session.request(
                endpoint.method,
                endpoint.url,
                json=test_data
            )
            if resp.status_code < 400:
                issues.append({
                    "type": "mass_assignment",
                    "severity": "high",
                    "detail": f"Field '{field}' accepted in request",
                    "evidence": f"Server accepted {field}=true"
                })

        return issues

    def test_rate_limiting(self, endpoint: APIEndpoint) -> List[Dict]:
        """Test for rate limiting on sensitive endpoints"""
        issues = []
        request_count = 0

        for _ in range(100):
            resp = self.session.request(
                endpoint.method,
                endpoint.url,
                params=endpoint.parameters
            )
            request_count += 1
            if resp.status_code == 429:
                break

        if request_count >= 100:
            issues.append({
                "type": "missing_rate_limit",
                "severity": "medium",
                "detail": f"No rate limiting after {request_count} requests",
                "evidence": "All 100 requests succeeded"
            })

        return issues

    def _create_expired_token(self) -> str:
        """Create an expired JWT for testing"""
        payload = {
            "sub": "test",
            "exp": 1000000000,  # Far past
            "iat": 1000000000
        }
        return jwt.encode(payload, "secret", algorithm="HS256")

    def _extract_params(self, spec: Dict) -> Dict:
        return {}

    def _check_auth_required(self, spec: Dict) -> bool:
        return "security" in spec
```

## 3.2 GraphQL Security Testing

```python
# src/scanners/graphql_scanner.py
import requests
from typing import Dict, List

class GraphQLSecurityTester:
    def __init__(self, endpoint: str, headers: Dict = None):
        self.endpoint = endpoint
        self.session = requests.Session()
        if headers:
            self.session.headers.update(headers)
        self.session.headers["Content-Type"] = "application/json"

    def introspection_query(self) -> Dict:
        """Execute introspection query to map schema"""
        query = """
        query IntrospectionQuery {
            __schema {
                queryType { name }
                mutationType { name }
                types {
                    name
                    kind
                    fields {
                        name
                        type { name kind }
                    }
                }
            }
        }
        """
        resp = self.session.post(self.endpoint, json={"query": query})
        return resp.json()

    def test_introspection_disabled(self) -> Dict:
        """Check if introspection is disabled"""
        schema = self.introspection_query()
        if "__schema" in schema.get("data", {}):
            return {
                "vulnerable": True,
                "detail": "Introspection query successful",
                "risk": "Schema information disclosure"
            }
        return {"vulnerable": False}

    def test_depth_limit(self) -> Dict:
        """Test for query depth limiting"""
        # Deeply nested query
        query = """
        query {
            user {
                posts {
                    comments {
                        author {
                            posts {
                                comments {
                                    author { name }
                                }
                            }
                        }
                    }
                }
            }
        }
        """
        resp = self.session.post(self.endpoint, json={"query": query})
        if resp.status_code == 200:
            return {
                "vulnerable": True,
                "detail": "No query depth limiting",
                "risk": "Denial of service via deeply nested queries"
            }
        return {"vulnerable": False}

    def test_batch_query_abuse(self) -> Dict:
        """Test batch query DoS"""
        queries = [{"query": "{ __typename }"} for _ in range(1000)]
        resp = self.session.post(self.endpoint, json=queries)
        if resp.status_code == 200:
            return {
                "vulnerable": True,
                "detail": "Batch queries not limited",
                "risk": "Server resource exhaustion"
            }
        return {"vulnerable": False}

    def test_field_suggestion(self) -> Dict:
        """Test for field suggestion information disclosure"""
        query = '{ user { nonexistentField } }'
        resp = self.session.post(self.endpoint, json={"query": query})
        body = resp.json()
        errors = body.get("errors", [])
        for error in errors:
            msg = error.get("message", "")
            if "did you mean" in msg.lower():
                return {
                    "vulnerable": True,
                    "detail": f"Field suggestions enabled: {msg}",
                    "risk": "Schema enumeration via error messages"
                }
        return {"vulnerable": False}
```

## 3.3 Practical Exercise: API Security Assessment

```python
# exercises/api_assessment.py
"""
Build an API security assessment tool that:
1. Discovers endpoints from OpenAPI spec
2. Tests authentication and authorization
3. Checks for IDOR vulnerabilities
4. Tests rate limiting
5. Validates input handling
6. Generates comprehensive report
"""

# Starter code
def assess_api(base_url, spec_url=None, auth_token=None):
    scanner = APISecurityScanner(base_url, auth_token)

    # Phase 1: Discovery
    endpoints = scanner.discover_endpoints(spec_url)
    print(f"Discovered {len(endpoints)} endpoints")

    # Phase 2: Authentication Testing
    for endpoint in endpoints:
        issues = scanner.test_broken_auth(endpoint)
        # Process findings...

    # Phase 3: Authorization Testing
    for endpoint in endpoints:
        issues = scanner.test_idor(endpoint)
        # Process findings...

    # Phase 4: Input Validation
    for endpoint in endpoints:
        issues = scanner.test_mass_assignment(endpoint)
        # Process findings...

    # Phase 5: Rate Limiting
    for endpoint in endpoints:
        issues = scanner.test_rate_limiting(endpoint)
        # Process findings...

    # Phase 6: Report Generation
    # Generate comprehensive report
```

## 3.4 Assessment Questions

1. How do you test for broken authentication in REST APIs?
2. Explain the difference between IDOR and mass assignment vulnerabilities.
3. What rate limiting strategies should be tested during API security assessments?
4. How does GraphQL introspection create a security risk?
5. What fields should be sanitized in API input validation?

---

# MODULE 4: CI/CD Security Integration

## 4.1 Security Pipeline Architecture

```
CI/CD Security Pipeline:
+-- Pre-Commit Stage
|   +-- Secret detection (git-secrets, truffleHog)
|   +-- Code linting (semgrep, bandit)
|   +-- Dependency checking (safety, npm audit)
+-- Build Stage
|   +-- SAST (static application security testing)
|   +-- Container scanning (trivy, grype)
|   +-- License compliance check
+-- Test Stage
|   +-- DAST (dynamic application security testing)
|   +-- API security testing
|   +-- Integration security tests
+-- Deploy Stage
|   +-- Infrastructure as Code scanning (tfsec, checkov)
|   +-- Secret rotation verification
|   +-- Configuration validation
+-- Post-Deploy Stage
|   +-- Runtime security monitoring
|   +-- Vulnerability scanning
|   +-- Penetration testing triggers
```

## 4.2 GitHub Actions Security Pipeline

```yaml
# .github/workflows/security.yml
name: Security Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: TruffleHog scan
        uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified

  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Semgrep scan
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/owasp-top-ten
            p/python
      - name: Bandit security scan
        run: |
          pip install bandit
          bandit -r src/ -f json -o bandit-report.json

  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Safety check
        run: |
          pip install safety
          safety check --output json > safety-report.json
      - name: npm audit
        run: npm audit --audit-level=high

  container-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t app:${{ github.sha }} .
      - name: Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'app:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'

  dast:
    runs-on: ubuntu-latest
    needs: [sast, dependency-scan]
    services:
      app:
        image: app:${{ github.sha }}
        ports:
          - 8080:8080
    steps:
      - name: OWASP ZAP scan
        uses: zaproxy/action-full-scan@v0.8.0
        with:
          target: 'http://localhost:8080'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'

  iac-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: tfsec scan
        uses: aquasecurity/tfsec-action@v1.0.3
        with:
          working_directory: terraform/
          soft_fail: true
      - name: checkov scan
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: terraform/
          framework: terraform
```

## 4.3 Pre-Commit Hook Implementation

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running security checks..."

# Secret detection
if command -v trufflehog &> /dev/null; then
    trufflehog git file://. --since-commit HEAD --fail
    if [ $? -ne 0 ]; then
        echo "ERROR: Secrets detected in commit!"
        exit 1
    fi
fi

# Python security linting
if command -v bandit &> /dev/null; then
    bandit -r src/ -ll --skip B101
    if [ $? -ne 0 ]; then
        echo "ERROR: Security issues found!"
        exit 1
    fi
fi

# Dependency check
if [ -f "requirements.txt" ]; then
    pip install safety -q 2>/dev/null
    safety check -r requirements.txt --short-hashes
    if [ $? -ne 0 ]; then
        echo "WARNING: Vulnerable dependencies found"
    fi
fi

echo "Security checks passed!"
```

## 4.4 Custom Security Scanner CI Integration

```python
# ci/security_gate.py
import sys
import json
from pathlib import Path

class SecurityGate:
    def __init__(self, config_path="security_gate.yaml"):
        self.config = self._load_config(config_path)
        self.blockers = []
        self.warnings = []

    def check_severity_threshold(self, findings_file: str):
        """Block deployment if critical findings exist"""
        with open(findings_file) as f:
            findings = json.load(f)

        for finding in findings:
            severity = finding.get("severity", "info")
            if severity == "critical":
                self.blockers.append(finding)
            elif severity == "high":
                self.warnings.append(finding)

        if self.blockers:
            print(f"BLOCKED: {len(self.blockers)} critical findings")
            for b in self.blockers:
                print(f"  - {b['title']}: {b['detail']}")
            return False

        if self.warnings:
            print(f"WARNING: {len(self.warnings)} high-severity findings")

        return True

    def check_compliance(self, scan_results: dict):
        """Verify compliance requirements"""
        checks = {
            "no_critical_cves": self._check_cves(scan_results),
            "dependencies_updated": self._check_dependency_versions(scan_results),
            "secrets_not_exposed": self._check_secrets(scan_results),
            "licenses_approved": self._check_licenses(scan_results)
        }

        failed = [k for k, v in checks.items() if not v]
        if failed:
            print(f"COMPLIANCE FAILED: {', '.join(failed)}")
            return False
        return True

    def _load_config(self, path):
        return {}

    def _check_cves(self, results):
        return True

    def _check_dependency_versions(self, results):
        return True

    def _check_secrets(self, results):
        return True

    def _check_licenses(self, results):
        return True

if __name__ == "__main__":
    gate = SecurityGate()
    if not gate.check_severity_threshold(sys.argv[1]):
        sys.exit(1)
    print("Security gate passed")
```

## 4.5 Assessment Questions

1. What security checks should run at each stage of a CI/CD pipeline?
2. How do you implement a security gate that blocks deployments?
3. Explain the difference between SAST and DAST in pipeline security.
4. How would you integrate container scanning into a Kubernetes deployment pipeline?
5. What metrics should be tracked for CI/CD security effectiveness?

---

# MODULE 5: Burp Suite Extension Development

## 5.1 Burp Extension Architecture

```python
# burp_extension.py
from burp import IBurpExtender, ITab, IMessageEditorController
from javax.swing import JPanel, JButton, JTable, JScrollPane, JLabel
from javax.swing.table import AbstractTableModel
from java.awt import BorderLayout, Dimension

class BurpExtender(IBurpExtender, ITab):
    def registerExtenderCallbacks(self, callbacks):
        self._callbacks = callbacks
        self._helpers = callbacks.getHelpers()
        callbacks.setExtensionName("Custom Security Scanner")

        # Create UI
        self._panel = JPanel(BorderLayout())
        self._panel.setPreferredSize(Dimension(800, 600))

        # Scanner results table
        self._table_model = ScannerTableModel()
        self._table = JTable(self._table_model)
        scroll_pane = JScrollPane(self._table)
        self._panel.add(scroll_pane, BorderLayout.CENTER)

        # Control buttons
        button_panel = JPanel()
        scan_button = JButton("Scan Selected", actionPerformed=self._scan_selected)
        export_button = JButton("Export Report", actionPerformed=self._export_report)
        button_panel.add(scan_button)
        button_panel.add(export_button)
        self._panel.add(button_panel, BorderLayout.SOUTH)

        callbacks.addSuiteTab(self)

        # Register scan checks
        callbacks.registerScannerCheck(ScanCheck(self._helpers))

        return

    def getTabCaption(self):
        return "Custom Scanner"

    def getUiComponent(self):
        return self._panel

    def _scan_selected(self, event):
        selected_rows = self._table.getSelectedRows()
        # Perform scan on selected items
        pass

    def _export_report(self, event):
        # Export findings to report
        pass


class ScannerTableModel(AbstractTableModel):
    def __init__(self):
        self._data = []
        self._columns = ["URL", "Severity", "Type", "Detail"]

    def getRowCount(self):
        return len(self._data)

    def getColumnCount(self):
        return len(self._columns)

    def getColumnName(self, col):
        return self._columns[col]

    def getValueAt(self, row, col):
        return self._data[row][col]

    def add_finding(self, finding):
        self._data.append(finding)
        self.fireTableRowsInserted(len(self._data)-1, len(self._data)-1)


class ScanCheck:
    def __init__(self, helpers):
        self._helpers = helpers

    def doActiveScan(self, baseRequestResponse, insertionPoint):
        """Perform active scan on insertion point"""
        findings = []

        # Test for SQL injection
        sqli_payloads = ["'", "1 OR 1=1", "' OR '1'='1"]
        for payload in sqli_payloads:
            check_request = insertionPoint.buildRequest(
                self._helpers.stringToBytes(payload)
            )
            check_response = self._callbacks.makeHttpRequest(
                baseRequestResponse.getHttpService(),
                check_request
            )
            response_info = self._helpers.analyzeResponse(
                check_response.getResponse()
            )
            if self._detect_sqli(response_info):
                findings.append({
                    "type": "SQL Injection",
                    "severity": "High",
                    "detail": f"SQLi detected with payload: {payload}"
                })
                break

        return findings

    def doPassiveScan(self, baseRequestResponse):
        """Perform passive scan"""
        findings = []
        response = self._helpers.bytesToString(
            baseRequestResponse.getResponse()
        )

        # Check for security headers
        headers = self._helpers.analyzeResponse(
            baseRequestResponse.getResponse()
        ).getHeaders()

        missing_headers = []
        required = ["X-Frame-Options", "Content-Security-Policy",
                    "Strict-Transport-Security"]
        for header in required:
            if not any(header in h for h in headers):
                missing_headers.append(header)

        if missing_headers:
            findings.append({
                "type": "Missing Security Headers",
                "severity": "Medium",
                "detail": f"Missing: {', '.join(missing_headers)}"
            })

        return findings

    def consolidateDuplicateIssues(self, existingIssue, newIssue):
        if existingIssue.getIssueDetail() == newIssue.getIssueDetail():
            return -1  # Keep existing
        return 0  # Report both

    def _detect_sqli(self, response_info):
        error_patterns = [
            "sql syntax", "mysql", "postgresql", "sqlite",
            "ORA-", "unclosed quotation"
        ]
        body = self._helpers.bytesToString(response_info.getBody() or b"")
        return any(p.lower() in body.lower() for p in error_patterns)
```

## 5.2 Practical Exercise: Burp Extension

```bash
# Setup Burp Suite Community Edition
# Download from PortSwigger

# Create extension project structure:
mkdir burp-custom-scanner
cd burp-custom-scanner

# Files to create:
# - burp_extension.py (main extension)
# - scanner_checks.py (custom scan checks)
# - report_generator.py (report export)
# - config.py (extension configuration)

# Test the extension:
# 1. Load in Burp Suite
# 2. Configure scan checks
# 3. Run against vulnerable application
# 4. Verify findings are reported correctly
```

## 5.3 Assessment Questions

1. Explain the difference between IBurpExtender and ITab interfaces.
2. How do you implement custom scan checks in Burp Suite?
3. What are the key APIs for building Burp extensions?
4. How would you add support for custom authentication in a Burp extension?
5. How do you export findings from Burp to external report formats?

---

# FURTHER READING

## Books
- "Black Hat Python" by Justin Seitz
- "Violent Python" by TJ O'Connor
- "Automate the Boring Stuff with Python" by Al Sweigart

## Online Resources
- OWASP Testing Guide - Comprehensive web security testing methodology
- NIST SP 800-115 - Technical Guide to Information Security Testing
- SANS SEC560 - Network Penetration Testing and Ethical Hacking

## Practice Platforms
- HackTheBox - Penetration testing labs
- TryHackMe - Guided security learning
- PortSwigger Web Security Academy - Web vulnerability labs
- DVWA - Damn Vulnerable Web Application
- WebGoat - OWASP teaching application
- Juice Shop - OWASP vulnerable application

## Tools Reference
- Burp Suite - Web security testing platform
- OWASP ZAP - Open source web security scanner
- Nmap - Network discovery and security auditing
- Metasploit - Penetration testing framework
- Nuclei - Template-based vulnerability scanner
- Subfinder - Subdomain discovery tool
- httpx - HTTP toolkit
- katana - Web crawler
- ffuf - Web fuzzer
- ffuf - Fuzz Faster U Fool
