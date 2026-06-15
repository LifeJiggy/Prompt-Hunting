# Automation-Efficiency 4: API Integration Automation

## Expert Role

You are a Principal API Integration Engineer specializing in security tool APIs, bug bounty platform APIs, and target application APIs. You have built systems that interact with dozens of APIs simultaneously — from HackerOne and Bugcrowd submission APIs to Shodan, Censys, VirusTotal, and custom target APIs. You understand the nuances of rate limiting, authentication patterns, error recovery, and data normalization across heterogeneous API ecosystems.

Your core principle: every API interaction is a potential failure point. Build for failure first, and success becomes a bonus.

---

## Core Concepts

### What is API Integration in Bug Bounty?

API integration in bug bounty encompasses three domains:

**1. Security Intelligence APIs**
- Shodan, Censys, SecurityTrails (recon data)
- VirusTotal, MalwareBazaar (threat data)
- NIST NVD, CVE.org (vulnerability data)
- Have I Been Pwned (breach data)

**2. Bug Bounty Platform APIs**
- HackerOne, Bugcrowd, Intigriti (submission and management)
- GitHub (disclosure tracking)
- Slack/Discord (notifications)

**3. Target Application APIs**
- REST/GraphQL endpoints on the target
- Authentication systems (OAuth, JWT, API keys)
- Webhook systems

### The API Integration Stack

```
+---------------------------------------------+
|            Application Layer                |
|    (Your scripts, pipelines, workflows)     |
+---------------------------------------------+
|            Integration Layer                |
|  (Rate limiting, retry, auth, caching)      |
+---------------------------------------------+
|            Transport Layer                  |
|    (HTTP client, connection pooling, TLS)   |
+---------------------------------------------+
|            API Provider                     |
|   (External APIs, target APIs, platforms)   |
+---------------------------------------------+
```

### Common Authentication Patterns

| Pattern | How It Works | Example |
|---------|--------------|---------|
| API Key | Key in header or query param | `X-API-Key: abc123` |
| Bearer Token | JWT or opaque token in header | `Authorization: Bearer xxx` |
| Basic Auth | Base64 encoded credentials | `Authorization: Basic dXNlcjpwYXNz` |
| OAuth 2.0 | Token exchange flow | Access token + refresh token |
| HMAC Signature | Request signature with secret | `X-Signature: sha256=xxx` |
| Cookie/Session | Session cookie from login | `Cookie: session=xxx` |

### Rate Limiting Patterns

```
Fixed Window:    N requests per T seconds
Sliding Window:  N requests in last T seconds (more accurate)
Token Bucket:    Tokens refill at rate R, consume 1 per request
Leaky Bucket:    Requests queue and process at fixed rate
Adaptive:        Adjust rate based on 429 responses
```

---

## Prerequisites

### Required Knowledge
- Python 3.8+ (intermediate to advanced)
- HTTP protocol fundamentals (headers, status codes, methods)
- JSON and XML parsing
- Understanding of OAuth 2.0 flows
- Familiarity with REST API design principles

### Required Tools

```bash
# Python packages
pip install httpx requests-oauthlib pyjwt cryptography
pip install tenacity ratelimit aiohttp
pip install pydantic rich click
pip install redis  # For distributed rate limiting

# For testing
pip install responses pytest-httpserver
```

### Environment Setup

```python
# setup_api_keys.py
"""Setup API keys securely."""
import os
from pathlib import Path

def setup_api_keys():
    """Create .env file template for API keys."""
    env_template = """# Security Intelligence APIs
SHODAN_API_KEY=
CENSYS_API_ID=
CENSYS_API_SECRET=
VIRUSTOTAL_API_KEY=
SECURITYTRAILS_API_KEY=

# Bug Bounty Platforms
HACKERONE_API_TOKEN=
HACKERONE_USERNAME=
BUGCROWD_API_KEY=

# Notification
SLACK_WEBHOOK_URL=
DISCORD_WEBHOOK_URL=
"""
    env_path = Path(".env")
    if not env_path.exists():
        env_path.write_text(env_template)
        print("Created .env template - fill in your API keys")
    else:
        print(".env already exists")

if __name__ == "__main__":
    setup_api_keys()
```

---

## Methodology

### Step 1: Build a Resilient HTTP Client

```python
# api_client.py
"""Resilient HTTP client with retry, rate limiting, and error handling."""

import time
import logging
import threading
from typing import Any, Dict, Optional
from datetime import datetime
from dataclasses import dataclass, field

import httpx

logger = logging.getLogger("api_client")


@dataclass
class APIResponse:
    """Standardized API response wrapper."""
    status_code: int
    data: Any = None
    error: Optional[str] = None
    headers: Dict[str, str] = field(default_factory=dict)
    rate_limit_remaining: Optional[int] = None
    rate_limit_reset: Optional[datetime] = None
    duration: float = 0.0

    @property
    def success(self) -> bool:
        return 200 <= self.status_code < 300

    @property
    def is_rate_limited(self) -> bool:
        return self.status_code == 429

    @property
    def is_server_error(self) -> bool:
        return 500 <= self.status_code < 600


class RateLimiter:
    """Token bucket rate limiter."""

    def __init__(self, max_requests: int, window_seconds: int):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.tokens = max_requests
        self.last_refill = time.time()
        self._lock = threading.Lock()

    def acquire(self) -> bool:
        """Try to acquire a rate limit token."""
        with self._lock:
            now = time.time()
            elapsed = now - self.last_refill
            refill = elapsed * (self.max_requests / self.window_seconds)
            self.tokens = min(self.max_requests, self.tokens + refill)
            self.last_refill = now
            if self.tokens >= 1:
                self.tokens -= 1
                return True
            return False

    def wait_for_token(self, timeout: float = 60) -> bool:
        """Wait until a token is available."""
        start = time.time()
        while time.time() - start < timeout:
            if self.acquire():
                return True
            time.sleep(0.1)
        return False


class APIClient:
    """Production-grade HTTP client for API integrations."""

    def __init__(self, base_url: str = "", api_key: str = "",
                 rate_limit: int = 60, rate_window: int = 60,
                 timeout: int = 30, max_retries: int = 3):
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key
        self.timeout = timeout
        self.max_retries = max_retries
        self.rate_limiter = RateLimiter(rate_limit, rate_window)
        self.client = httpx.Client(
            base_url=self.base_url,
            timeout=httpx.Timeout(timeout),
            limits=httpx.Limits(
                max_connections=20,
                max_keepalive_connections=10,
                keepalive_expiry=30
            ),
            headers=self._default_headers()
        )
        self.request_count = 0
        self.total_duration = 0.0

    def _default_headers(self) -> Dict[str, str]:
        headers = {
            "User-Agent": "BugBounty-Scanner/1.0",
            "Accept": "application/json",
        }
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers

    def request(self, method: str, path: str, params: Dict = None,
                json_data: Dict = None, headers: Dict = None, **kw) -> APIResponse:
        """Make an API request with retry and rate limiting."""
        url = f"{self.base_url}/{path.lstrip('/')}" if path else self.base_url

        for attempt in range(self.max_retries):
            if not self.rate_limiter.wait_for_token(timeout=60):
                return APIResponse(status_code=429, error="Rate limit timeout")

            start_time = time.time()
            try:
                response = self.client.request(
                    method=method, url=url, params=params,
                    json=json_data, headers=headers, **kw
                )
                duration = time.time() - start_time
                self.request_count += 1
                self.total_duration += duration

                rl_remain = response.headers.get("X-RateLimit-Remaining")
                rl_reset = response.headers.get("X-RateLimit-Reset")

                api_response = APIResponse(
                    status_code=response.status_code,
                    data=self._parse_response(response),
                    headers=dict(response.headers),
                    rate_limit_remaining=int(rl_remain) if rl_remain else None,
                    rate_limit_reset=(
                        datetime.fromtimestamp(int(rl_reset)) if rl_reset else None
                    ),
                    duration=duration
                )

                if api_response.success:
                    return api_response

                if api_response.is_rate_limited:
                    retry_after = self._get_retry_after(response)
                    logger.warning(f"Rate limited. Waiting {retry_after}s...")
                    time.sleep(retry_after)
                    continue

                if api_response.is_server_error:
                    time.sleep(2 ** attempt)
                    continue

                return api_response

            except httpx.TimeoutException:
                if attempt < self.max_retries - 1:
                    time.sleep(2 ** attempt)
            except httpx.RequestError as e:
                logger.error(f"Request error: {e}")
                if attempt < self.max_retries - 1:
                    time.sleep(2 ** attempt)

        return APIResponse(status_code=0, error=f"Failed after {self.max_retries} attempts")

    def get(self, path: str, **kw) -> APIResponse:
        return self.request("GET", path, **kw)

    def post(self, path: str, **kw) -> APIResponse:
        return self.request("POST", path, **kw)

    def put(self, path: str, **kw) -> APIResponse:
        return self.request("PUT", path, **kw)

    def delete(self, path: str, **kw) -> APIResponse:
        return self.request("DELETE", path, **kw)

    def _parse_response(self, response: httpx.Response) -> Any:
        ct = response.headers.get("content-type", "")
        if "json" in ct:
            try:
                return response.json()
            except Exception:
                return response.text
        return response.text

    def _get_retry_after(self, response: httpx.Response) -> float:
        ra = response.headers.get("Retry-After")
        if ra:
            try:
                return float(ra)
            except ValueError:
                pass
        return 60.0

    def get_metrics(self) -> Dict:
        return {
            "total_requests": self.request_count,
            "total_duration": self.total_duration,
            "avg_duration": self.total_duration / max(self.request_count, 1),
        }

    def close(self):
        self.client.close()

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()
```

### Step 2: API-Specific Integrations

```python
# integrations/shodan_api.py
"""Shodan API integration for security intelligence."""

from api_client import APIClient, APIResponse


class ShodanClient:
    BASE_URL = "https://api.shodan.io"

    def __init__(self, api_key: str):
        self.client = APIClient(
            base_url=self.BASE_URL,
            api_key=api_key,
            rate_limit=1,
            rate_window=1,
            timeout=30
        )

    def search(self, query: str, page: int = 1) -> APIResponse:
        return self.client.get(
            "/shodan/host/search",
            params={"key": self.client.api_key, "query": query, "page": page}
        )

    def host_info(self, ip: str) -> APIResponse:
        return self.client.get(
            f"/shodan/host/{ip}",
            params={"key": self.client.api_key}
        )

    def dns_resolve(self, hostnames: str) -> APIResponse:
        return self.client.get(
            "/dns/resolve",
            params={"hostnames": hostnames, "key": self.client.api_key}
        )

    def reverse_dns(self, ips: str) -> APIResponse:
        return self.client.get(
            "/dns/reverse",
            params={"ips": ips, "key": self.client.api_key}
        )


# integrations/virustotal_api.py
"""VirusTotal API v3 integration."""

class VirusTotalClient:
    BASE_URL = "https://www.virustotal.com/api/v3"

    def __init__(self, api_key: str):
        self.client = APIClient(
            base_url=self.BASE_URL,
            api_key=api_key,
            rate_limit=4,
            rate_window=60,
            timeout=30
        )

    def scan_url(self, url: str) -> APIResponse:
        return self.client.post("/urls", json_data={"url": url})

    def get_url_report(self, url_id: str) -> APIResponse:
        return self.client.get(f"/urls/{url_id}")

    def scan_domain(self, domain: str) -> APIResponse:
        return self.client.get(f"/domains/{domain}")

    def get_ip_report(self, ip: str) -> APIResponse:
        return self.client.get(f"/ip_addresses/{ip}")

    def search(self, query: str) -> APIResponse:
        return self.client.get("/search", params={"query": query})


# integrations/censys_api.py
"""Censys Search API v2 integration."""

import base64


class CensysClient:
    BASE_URL = "https://search.censys.io/api/v2"

    def __init__(self, api_id: str, api_secret: str):
        self.client = APIClient(
            base_url=self.BASE_URL,
            rate_limit=10,
            rate_window=60,
            timeout=30
        )
        credentials = base64.b64encode(f"{api_id}:{api_secret}".encode()).decode()
        self.client.client.headers["Authorization"] = f"Basic {credentials}"

    def search_hosts(self, query: str, per_page: int = 25) -> APIResponse:
        return self.client.get(
            "/hosts/search",
            params={"q": query, "per_page": per_page}
        )

    def get_host(self, ip: str) -> APIResponse:
        return self.client.get(f"/hosts/{ip}")

    def search_certificates(self, query: str) -> APIResponse:
        return self.client.get("/certificates/search", params={"q": query})
```

### Step 3: Authentication Manager

```python
# auth_manager.py
"""Manage multiple authentication methods for different APIs."""

import os
import json
import time
import logging
from typing import Dict, Optional, Any
from pathlib import Path
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger("auth_manager")


class AuthMethod(Enum):
    API_KEY = "api_key"
    BEARER_TOKEN = "bearer_token"
    BASIC_AUTH = "basic_auth"
    OAUTH2 = "oauth2"
    HMAC = "hmac"


@dataclass
class AuthConfig:
    method: AuthMethod
    credentials: Dict[str, str]
    expires_at: Optional[float] = None
    refresh_token: Optional[str] = None

    @property
    def is_expired(self) -> bool:
        if self.expires_at is None:
            return False
        return time.time() > self.expires_at


class AuthManager:
    """Centralized authentication management."""

    def __init__(self, config_path: str = ".env"):
        self.config_path = Path(config_path)
        self.credentials: Dict[str, AuthConfig] = {}
        self._load_from_env()

    def _load_from_env(self):
        """Load API keys from environment variables."""
        env_map = {
            "SHODAN_API_KEY": ("shodan", AuthMethod.API_KEY),
            "VIRUSTOTAL_API_KEY": ("virustotal", AuthMethod.API_KEY),
            "CENSYS_API_ID": ("censys", AuthMethod.BASIC_AUTH),
            "HACKERONE_API_TOKEN": ("hackerone", AuthMethod.BEARER_TOKEN),
            "BUGCROWD_API_KEY": ("bugcrowd", AuthMethod.API_KEY),
        }
        for env_var, (service, method) in env_map.items():
            value = os.getenv(env_var)
            if value:
                creds = {"api_key": value} if method == AuthMethod.API_KEY else {}
                if service == "censys":
                    creds["api_id"] = value
                    creds["api_secret"] = os.getenv("CENSYS_API_SECRET", "")
                self.credentials[service] = AuthConfig(
                    method=method, credentials=creds
                )
                logger.debug(f"Loaded auth for {service}")

    def get_credentials(self, service: str) -> Optional[Dict[str, str]]:
        config = self.credentials.get(service)
        if config is None:
            logger.warning(f"No credentials found for {service}")
            return None
        if config.is_expired:
            logger.warning(f"Credentials for {service} are expired")
            return None
        return config.credentials

    def add_service(self, service: str, method: AuthMethod,
                    credentials: Dict[str, str], expires_at: float = None):
        self.credentials[service] = AuthConfig(
            method=method,
            credentials=credentials,
            expires_at=expires_at
        )

    def list_services(self) -> list:
        return list(self.credentials.keys())
```

### Step 4: Response Cache and Pagination

```python
# api_cache.py
"""API response caching and pagination utilities."""

import json
import time
import hashlib
from pathlib import Path
from typing import Any, Dict, List, Optional, Callable
from datetime import timedelta

import logging
logger = logging.getLogger("api_cache")


class APICache:
    """Disk-based API response cache."""

    def __init__(self, cache_dir: str = "./api_cache", ttl: int = 3600):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.ttl = ttl

    def _key(self, url: str, params: Dict = None) -> str:
        data = f"{url}:{json.dumps(params or {}, sort_keys=True)}"
        return hashlib.sha256(data.encode()).hexdigest()[:16]

    def get(self, url: str, params: Dict = None) -> Optional[Any]:
        key = self._key(url, params)
        cache_path = self.cache_dir / f"{key}.json"

        if cache_path.exists():
            try:
                with open(cache_path) as f:
                    cached = json.load(f)
                if time.time() - cached["timestamp"] < self.ttl:
                    logger.debug(f"Cache hit for {url}")
                    return cached["data"]
                else:
                    cache_path.unlink()
            except Exception:
                pass
        return None

    def set(self, url: str, data: Any, params: Dict = None):
        key = self._key(url, params)
        cache_path = self.cache_dir / f"{key}.json"
        with open(cache_path, "w") as f:
            json.dump({"timestamp": time.time(), "data": data}, f, indent=2)

    def clear(self):
        for f in self.cache_dir.glob("*.json"):
            f.unlink()


class PaginatedIterator:
    """Iterate through paginated API responses."""

    def __init__(self, fetch_func: Callable, page_param: str = "page",
                 per_page_param: str = "per_page", per_page: int = 25,
                 max_pages: int = 100):
        self.fetch_func = fetch_func
        self.page_param = page_param
        self.per_page_param = per_page_param
        self.per_page = per_page
        self.max_pages = max_pages

    def __iter__(self):
        page = 1
        while page <= self.max_pages:
            params = {
                self.page_param: page,
                self.per_page_param: self.per_page
            }
            result = self.fetch_func(params)

            if isinstance(result, dict):
                items = result.get("data", result.get("results", []))
                total = result.get("total", 0)
            elif isinstance(result, list):
                items = result
                total = len(items)
            else:
                break

            if not items:
                break

            for item in items:
                yield item

            if len(items) < self.per_page:
                break
            if page * self.per_page >= total:
                break

            page += 1
```

### Step 5: HackerOne and Bugcrowd Integration

```python
# integrations/hackerone.py
"""HackerOne API integration for report submission."""

import json
import base64
from typing import Dict, List, Optional
from api_client import APIClient, APIResponse


class HackerOneClient:
    BASE_URL = "https://api.hackerone.com/v1"

    def __init__(self, username: str, api_token: str):
        self.username = username
        credentials = base64.b64encode(f"{username}:{api_token}".encode()).decode()
        self.client = APIClient(
            base_url=self.BASE_URL,
            rate_limit=10,
            rate_window=60,
            timeout=30
        )
        self.client.client.headers["Authorization"] = f"Basic {credentials}"

    def get_program(self, handle: str) -> APIResponse:
        return self.client.get(f"/hackers/programs/{handle}")

    def get_reports(self, state: str = "triaged") -> APIResponse:
        return self.client.get(
            "/hackers/me/reports",
            params={"filter[state]": state}
        )

    def create_report(self, program_id: str, report_data: Dict) -> APIResponse:
        payload = {
            "data": {
                "type": "report",
                "attributes": {
                    "team_handle": program_id,
                    "title": report_data["title"],
                    "vulnerability_information": report_data["description"],
                    "impact": report_data.get("impact", ""),
                },
                "relationships": {}
            }
        }
        return self.client.post("/hackers/reports", json_data=payload)


# integrations/bugcrowd_api.py
"""Bugcrowd API integration."""

class BugcrowdClient:
    BASE_URL = "https://api.bugcrowd.com"

    def __init__(self, api_key: str):
        self.client = APIClient(
            base_url=self.BASE_URL,
            rate_limit=5,
            rate_window=60,
            timeout=30
        )
        self.client.client.headers["Authorization"] = f"Token {api_key}"
        self.client.client.headers["Accept"] = "application/vnd.bugcrowd+json"

    def get_submissions(self, program: str) -> APIResponse:
        return self.client.get(
            f"/submissions/",
            params={"program": program}
        )

    def create_submission(self, program: str, submission_data: Dict) -> APIResponse:
        payload = {
            "data": {
                "type": "submission",
                "attributes": {
                    "title": submission_data["title"],
                    "description": submission_data["description"],
                    "severity": submission_data.get("severity", "medium"),
                },
                "relationships": {
                    "program": {
                        "data": {"type": "program", "id": program}
                    }
                }
            }
        }
        return self.client.post("/submissions/", json_data=payload)
```

### Step 6: Webhook Notifications

```python
# integrations/webhooks.py
"""Webhook integrations for notifications."""

import json
import hashlib
import hmac
from typing import Dict, Optional
from api_client import APIClient, APIResponse


class SlackWebhook:
    def __init__(self, webhook_url: str):
        self.webhook_url = webhook_url
        self.client = APIClient(timeout=10, max_retries=2)

    def send(self, message: str, channel: str = None,
             severity: str = "info") -> APIResponse:
        color_map = {
            "critical": "#FF0000",
            "high": "#FF6600",
            "medium": "#FFCC00",
            "low": "#00FF00",
            "info": "#0099FF"
        }
        payload = {
            "attachments": [{
                "color": color_map.get(severity, "#999999"),
                "text": message,
                "footer": "Bug Bounty Scanner",
            }]
        }
        if channel:
            payload["channel"] = channel

        return self.client.post(
            self.webhook_url,
            json_data=payload
        )


class DiscordWebhook:
    def __init__(self, webhook_url: str):
        self.webhook_url = webhook_url
        self.client = APIClient(timeout=10, max_retries=2)

    def send(self, title: str, description: str,
             severity: str = "info") -> APIResponse:
        color_map = {
            "critical": 0xFF0000,
            "high": 0xFF6600,
            "medium": 0xFFCC00,
            "low": 0x00FF00,
            "info": 0x0099FF
        }
        payload = {
            "embeds": [{
                "title": title,
                "description": description,
                "color": color_map.get(severity, 0x999999),
            }]
        }
        return self.client.post(self.webhook_url, json_data=payload)
```

---

## Tool Arsenal

### Python API Packages

```bash
# HTTP clients
pip install httpx            # Modern, async-capable HTTP client
pip install requests         # Classic, battle-tested
pip install aiohttp          # Async HTTP client

# Authentication
pip install requests-oauthlib  # OAuth 1.0/2.0
pip install authlib            # Advanced auth (JWT, OAuth, OIDC)
pip install pyjwt              # JWT handling
pip install cryptography       # Crypto primitives

# Rate limiting
pip install tenacity          # Retry with backoff
pip install ratelimit         # Rate limit decorator

# Data handling
pip install pydantic          # Data validation
pip install marshmallow       # Serialization

# Testing
pip install responses         # Mock requests
pip install vcrpy             # Record/replay HTTP
```

### Quick Commands

```bash
# Test API connectivity
python -c "from api_client import APIClient; c = APIClient('https://httpbin.org'); print(c.get('/get').data)"

# Check rate limits
python -c "from integrations.shodan import ShodanClient; s = ShodanClient('KEY'); print(s.search('apache'))"

# Test webhook
python -c "from integrations.webhooks import SlackWebhook; s = SlackWebhook('URL'); s.send('Test message')"
```

---

## Real-World Examples

### Example 1: Multi-API Recon Pipeline

```python
# pipelines/api_recon.py
"""Recon pipeline using multiple APIs for data enrichment."""

import os
import json
from typing import Dict, List
from api_client import APIClient
from integrations.shodan_api import ShodanClient
from integrations.virustotal_api import VirusTotalClient
from integrations.censys_api import CensysClient


class APIReconPipeline:
    """Aggregate recon data from multiple API sources."""

    def __init__(self):
        self.shodan = ShodanClient(os.getenv("SHODAN_API_KEY", ""))
        self.virustotal = VirusTotalClient(os.getenv("VIRUSTOTAL_API_KEY", ""))
        self.results = {}

    def enrich_target(self, target: str) -> Dict:
        """Enrich target with data from all API sources."""
        enrichment = {
            "target": target,
            "shodan": self._shodan_lookup(target),
            "virustotal": self._vt_lookup(target),
            "subdomains": self._vt_subdomains(target),
        }
        self.results[target] = enrichment
        return enrichment

    def _shodan_lookup(self, target: str) -> Dict:
        try:
            resp = self.shodan.host_info(target)
            if resp.success:
                return {
                    "ports": [s["port"] for s in resp.data.get("data", [])],
                    "vulns": resp.data.get("vulns", []),
                    "org": resp.data.get("org", ""),
                    "os": resp.data.get("os", ""),
                }
        except Exception as e:
            return {"error": str(e)}
        return {}

    def _vt_lookup(self, target: str) -> Dict:
        try:
            resp = self.virustotal.scan_domain(target)
            if resp.success:
                attrs = resp.data.get("data", {}).get("attributes", {})
                return {
                    "reputation": attrs.get("reputation", 0),
                    "last_analysis": attrs.get("last_analysis_date", ""),
                }
        except Exception as e:
            return {"error": str(e)}
        return {}

    def _vt_subdomains(self, target: str) -> List[str]:
        try:
            resp = self.virustotal.scan_domain(target)
            if resp.success:
                return resp.data.get("data", {}).get("attributes", {}).get(
                    "last_dns_records", []
                )
        except Exception:
            pass
        return []

    def save_results(self, output_file: str = "api_recon_results.json"):
        with open(output_file, "w") as f:
            json.dump(self.results, f, indent=2, default=str)
```

### Example 2: Automated Report Submission

```python
# pipelines/auto_submit.py
"""Automated report submission to bug bounty platforms."""

import json
from pathlib import Path
from integrations.hackerone import HackerOneClient
from integrations.bugcrowd_api import BugcrowdClient
from integrations.webhooks import SlackWebhook


class ReportSubmitter:
    """Submit findings to bug bounty platforms."""

    def __init__(self, h1_username: str = "", h1_token: str = "",
                 bc_api_key: str = "", slack_url: str = ""):
        self.hackerone = HackerOneClient(h1_username, h1_token) if h1_username else None
        self.bugcrowd = BugcrowdClient(bc_api_key) if bc_api_key else None
        self.slack = SlackWebhook(slack_url) if slack_url else None

    def submit_report(self, finding: Dict, platform: str = "hackerone") -> Dict:
        """Submit a finding to the specified platform."""
        result = {"platform": platform, "status": "pending"}

        try:
            if platform == "hackerone" and self.hackerone:
                resp = self.hackerone.create_report(
                    finding["program"],
                    {
                        "title": finding["title"],
                        "description": finding["description"],
                        "impact": finding.get("impact", ""),
                    }
                )
                result["status"] = "submitted" if resp.success else "failed"
                result["response"] = resp.data

            elif platform == "bugcrowd" and self.bugcrowd:
                resp = self.bugcrowd.create_submission(
                    finding["program"],
                    {
                        "title": finding["title"],
                        "description": finding["description"],
                        "severity": finding.get("severity", "medium"),
                    }
                )
                result["status"] = "submitted" if resp.success else "failed"
                result["response"] = resp.data

            if self.slack and result["status"] == "submitted":
                self.slack.send(
                    f"Report submitted to {platform}: {finding['title']}",
                    severity="info"
                )

        except Exception as e:
            result["status"] = "error"
            result["error"] = str(e)

        return result

    def batch_submit(self, findings_file: str, platform: str) -> list:
        """Submit multiple findings from a JSON file."""
        with open(findings_file) as f:
            findings = json.load(f)

        results = []
        for finding in findings.get("findings", []):
            result = self.submit_report(finding, platform)
            results.append(result)
        return results
```

---

## Common Pitfalls

### Pitfall 1: Ignoring Rate Limits
**Problem:** API bans your key after exceeding rate limits.
**Solution:** Implement client-side rate limiting. Parse rate-limit headers. Use exponential backoff on 429s.

### Pitfall 2: No API Key Rotation
**Problem:** Compromised API key stays valid indefinitely.
**Solution:** Rotate keys periodically. Use short-lived tokens where possible. Monitor API usage logs.

### Pitfall 3: Hardcoding Credentials
**Problem:** API keys in source code get committed to repos.
**Solution:** Use environment variables, .env files (not committed), or secret managers.

### Pitfall 4: Not Handling Pagination
**Problem:** Only getting first page of results.
**Solution:** Implement pagination handling. Use the PaginatedIterator pattern.

### Pitfall 5: No Response Validation
**Problem:** API response schema changes break your parser.
**Solution:** Validate responses with Pydantic. Handle missing fields gracefully.

### Pitfall 6: Synchronous API Calls
**Problem:** Sequential API calls waste time.
**Solution:** Use async (aiohttp) or thread pools for independent API calls.

### Pitfall 7: No Retry Logic
**Problem:** Transient failures cause permanent data loss.
**Solution:** Implement retry with exponential backoff. Use the tenacity library.

---

## Advanced Techniques

### 1. OAuth 2.0 Flow Implementation

```python
# auth/oauth2.py
"""OAuth 2.0 client credentials and authorization code flows."""

import time
import webbrowser
from urllib.parse import urlencode, parse_qs
from api_client import APIClient, APIResponse


class OAuth2Client:
    def __init__(self, client_id: str, client_secret: str,
                 auth_url: str, token_url: str, redirect_uri: str = "http://localhost:8080"):
        self.client_id = client_id
        self.client_secret = client_secret
        self.auth_url = auth_url
        self.token_url = token_url
        self.redirect_uri = redirect_uri
        self.access_token = None
        self.refresh_token = None
        self.expires_at = 0

    def client_credentials_flow(self, scopes: list = None) -> APIResponse:
        """Client credentials grant (machine-to-machine)."""
        client = APIClient(timeout=30)
        data = {
            "grant_type": "client_credentials",
            "client_id": self.client_id,
            "client_secret": self.client_secret,
        }
        if scopes:
            data["scope"] = " ".join(scopes)

        resp = client.post(self.token_url, json_data=data)
        if resp.success:
            self.access_token = resp.data["access_token"]
            self.expires_at = time.time() + resp.data.get("expires_in", 3600)
        return resp

    def authorization_code_flow(self, scopes: list = None) -> str:
        """Authorization code grant (user-interactive)."""
        params = {
            "response_type": "code",
            "client_id": self.client_id,
            "redirect_uri": self.redirect_uri,
        }
        if scopes:
            params["scope"] = " ".join(scopes)

        auth_url = f"{self.auth_url}?{urlencode(params)}"
        print(f"Open this URL in your browser:\n{auth_url}")
        webbrowser.open(auth_url)
        redirect_response = input("Paste the full redirect URL here: ")

        code = parse_qs(
            redirect_response.split("?", 1)[1] if "?" in redirect_response else ""
        ).get("code", [None])[0]

        if code:
            self._exchange_code(code)
        return code

    def _exchange_code(self, code: str):
        client = APIClient(timeout=30)
        resp = client.post(self.token_url, json_data={
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": self.redirect_uri,
            "client_id": self.client_id,
            "client_secret": self.client_secret,
        })
        if resp.success:
            self.access_token = resp.data["access_token"]
            self.refresh_token = resp.data.get("refresh_token")
            self.expires_at = time.time() + resp.data.get("expires_in", 3600)

    def refresh_access_token(self) -> APIResponse:
        if not self.refresh_token:
            raise ValueError("No refresh token available")
        client = APIClient(timeout=30)
        return client.post(self.token_url, json_data={
            "grant_type": "refresh_token",
            "refresh_token": self.refresh_token,
            "client_id": self.client_id,
            "client_secret": self.client_secret,
        })
```

### 2. HMAC Request Signing

```python
import hashlib
import hmac
import time


def sign_request(method: str, path: str, body: str,
                 secret: str, timestamp: str = None) -> dict:
    """Sign an API request with HMAC-SHA256."""
    if timestamp is None:
        timestamp = str(int(time.time()))

    message = f"{method}\n{path}\n{timestamp}\n{body}"
    signature = hmac.new(
        secret.encode(),
        message.encode(),
        hashlib.sha256
    ).hexdigest()

    return {
        "X-Timestamp": timestamp,
        "X-Signature": f"sha256={signature}"
    }
```

### 3. API Response Normalizer

```python
class ResponseNormalizer:
    """Normalize different API response formats to a common schema."""

    SCHEMA_MAP = {
        "shodan": {
            "host": lambda d: d.get("ip_str", ""),
            "ports": lambda d: d.get("ports", []),
            "vulns": lambda d: list(d.get("vulns", {}).keys()),
        },
        "censys": {
            "host": lambda d: d.get("ip", ""),
            "ports": lambda d: [s["port"] for s in d.get("services", [])],
            "vulns": lambda d: [],
        },
        "virustotal": {
            "host": lambda d: d.get("id", ""),
            "ports": lambda d: [],
            "vulns": lambda d: [],
        },
    }

    @classmethod
    def normalize(cls, source: str, data: dict) -> dict:
        schema = cls.SCHEMA_MAP.get(source, {})
        return {
            "source": source,
            "host": schema.get("host", lambda d: "")(data),
            "ports": schema.get("ports", lambda d: [])(data),
            "vulns": schema.get("vulns", lambda d: [])(data),
            "raw": data,
        }
```

---

## Reporting Template

### API Integration Report

```markdown
# API Integration Report

## Summary
- **APIs Integrated**: {api_count}
- **Total Requests**: {total_requests}
- **Success Rate**: {success_rate}%
- **Average Response Time**: {avg_response_time}ms

## API Status

| API | Status | Rate Limit | Remaining | Reset |
|-----|--------|------------|-----------|-------|
| Shodan | OK | 1/s | 45 | - |
| VirusTotal | OK | 4/min | 2 | 2026-01-01T00:01:00 |
| Censys | OK | 10/min | 8 | - |
| HackerOne | OK | 10/min | 9 | - |

## Data Enrichment Results
- **Targets Enriched**: {target_count}
- **Total Findings**: {finding_count}
- **API Sources per Target**: {avg_sources}

## Error Summary
- **Rate Limits Hit**: {rate_limit_count}
- **Timeouts**: {timeout_count}
- **Server Errors**: {server_error_count}

## Recommendations
1. {recommendation_1}
2. {recommendation_2}
```

---

## Quick Reference

### One-Liner Commands

```bash
# Test API key
python -c "import httpx; print(httpx.get('https://api.shodan.io/shodan/host/8.8.8.8?key=KEY').json())"

# Check rate limit status
python -c "from api_client import APIClient; c = APIClient('https://api.shodan.io', api_key='KEY'); print(c.get('/shodan/host/8.8.8.8').rate_limit_remaining)"

# Test webhook
python -c "from integrations.webhooks import SlackWebhook; SlackWebhook('URL').send('Test')"
```

### API Rate Limits Reference

| API | Free Tier | Paid Tier | Auth Method |
|-----|-----------|-----------|-------------|
| Shodan | 1 req/s | 60 req/s | API Key |
| VirusTotal | 4 req/min | 600 req/min | API Key |
| Censys | 10 req/min | 300 req/min | Basic Auth |
| SecurityTrails | 50 req/mo | Unlimited | API Key |
| HackerOne | 10 req/min | 100 req/min | Basic Auth |

### Configuration Template

```yaml
apis:
  shodan:
    api_key: ${SHODAN_API_KEY}
    rate_limit: 1
    rate_window: 1
    timeout: 30
  virustotal:
    api_key: ${VIRUSTOTAL_API_KEY}
    rate_limit: 4
    rate_window: 60
    timeout: 30
  censys:
    api_id: ${CENSYS_API_ID}
    api_secret: ${CENSYS_API_SECRET}
    rate_limit: 10
    rate_window: 60
    timeout: 30

notifications:
  slack_webhook: ${SLACK_WEBHOOK_URL}
  discord_webhook: ${DISCORD_WEBHOOK_URL}
  on_finding: true
  on_error: true
```

---

*Document Version: 1.0 | Last Updated: 2026 | Automation-Efficiency Series*
