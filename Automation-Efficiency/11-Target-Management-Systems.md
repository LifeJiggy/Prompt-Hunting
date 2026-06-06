# 11 — Target Management Systems

## 1. Program Scope Tracking

Every program needs explicit scope boundaries. The core model captures three fields: matcher, matcher type, and scope state.

### Scope Entry Data Model

```python
from dataclasses import dataclass
from enum import Enum

class ScopeState(Enum):
    IN_SCOPE = "in_scope"
    OUT_OF_SCOPE = "out_of_scope"
    CONDITIONAL = "conditional"

class MatcherType(Enum):
    EXACT_DOMAIN = "exact_domain"
    WILDCARD_DOMAIN = "wildcard_domain"
    CIDR = "cidr"
    REGEX = "regex"

@dataclass
class ScopeEntry:
    matcher: str
    matcher_type: MatcherType
    state: ScopeState
    comment: str = ""
    added_by: str = "manual"
    added_at: str = ""
```

### Domain Wildcard Matching

A suffix match handles `www.target.com` via `*.target.com` but a naively-stripped glob also allows `evil-target.com`. Use a regex derived from the glob:

```python
import re

def expand_wildcard(pattern: str) -> str:
    pattern = re.escape(pattern)
    pattern = pattern.replace(r'\*', '.*')
    return f"^{pattern}$"

def is_in_scope(host: str, scope_patterns: list[ScopeEntry]) -> bool:
    for entry in scope_patterns:
        if entry.state != ScopeState.IN_SCOPE:
            continue
        if entry.matcher_type == MatcherType.WILDCARD_DOMAIN:
            if re.match(expand_wildcard(entry.matcher), host, re.IGNORECASE):
                return True
        elif entry.matcher_type == MatcherType.EXACT_DOMAIN:
            if host.lower() == entry.matcher.lower():
                return True
    return False
```

### CIDR Range Matching

Convert the host to an `ipaddress.IPv4Address` and use `ipaddress.IPv4Network` for membership:

```python
import ipaddress

def is_ip_in_scope(ip_str: str, cidr_list: list[str]) -> bool:
    addr = ipaddress.ip_address(ip_str)
    for cidr in cidr_list:
        if addr in ipaddress.IPv4Network(cidr, strict=False):
            return True
    return False
```

---

## 2. Scope Boundary Enforcement

Intercept outbound HTTP clients before any request leaves the network layer:

```python
import httpx

class ScopeEnforcingTransport(httpx.BaseTransport):
    def __init__(self, scope_entries: list[ScopeEntry], inner: httpx.BaseTransport):
        self._inner = inner
        self._out_scope = [e for e in scope_entries if e.state == ScopeState.OUT_OF_SCOPE]

    def handle_request(self, request: httpx.Request) -> httpx.Response:
        host = request.url.host
        for entry in self._out_scope:
            if entry.matcher_type == MatcherType.WILDCARD_DOMAIN:
                if re.match(expand_wildcard(entry.matcher), host, re.IGNORECASE):
                    raise httpx.TransportError(f"Blocked: {host} is out of scope")
            elif entry.matcher_type == MatcherType.EXACT_DOMAIN and host.lower() == entry.matcher.lower():
                raise httpx.TransportError(f"Blocked: {host} is out of scope")
        return self._inner.handle_request(request)

client = httpx.Client(transport=ScopeEnforcingTransport(scope, inner=httpx.HTTPTransport()))
```

---

## 3. Asset Inventory

Assets carry host identity, IP, ASN context, CDN provider, open ports, and tags.

### Asset Data Model

```python
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class AssetRecord:
    host: str
    ip: Optional[str] = None
    asn: Optional[str] = None
    asn_org: Optional[str] = None
    cdn: Optional[str] = None
    ports: list[int] = field(default_factory=list)
    technologies: list[str] = field(default_factory=list)
    tags: list[str] = field(default_factory=list)
    first_seen: str = ""
    last_seen: str = ""
    last_tested: Optional[str] = None
    test_count: int = 0
```

### ASN Enrichment Pipeline

```python
import sqlite3, requests, time, hashlib

def init_cache(db_path: str = "asn_cache.db"):
    conn = sqlite3.connect(db_path)
    conn.execute("CREATE TABLE IF NOT EXISTS asn_cache (ip_hash TEXT PRIMARY KEY, asn TEXT, asn_org TEXT, fetched_at TEXT)")
    conn.commit()
    return conn

def lookup_asn(ip: str, conn: sqlite3.Connection) -> tuple[str, str]:
    ip_hash = hashlib.sha256(ip.encode()).hexdigest()[:16]
    row = conn.execute("SELECT asn, asn_org FROM asn_cache WHERE ip_hash=?", (ip_hash,)).fetchone()
    if row: return row
    try:
        r = requests.get(f"http://ip-api.com/json/{ip}", timeout=5)
        data = r.json()
        asn, org = data.get("as",""), data.get("org","")
        conn.execute("INSERT OR REPLACE INTO asn_cache VALUES (?,?,?,?)", (ip_hash, asn, org, time.strftime("%Y-%m-%d")))
        conn.commit()
        return asn, org
    except Exception: return "", ""
```

### CDN Fingerprinting

CNAME suffix matching covers bulk CDN identification:

```python
CDN_SUFFIXES = {
    "cloudfront.net": "CloudFront", "amazonaws.com": "AWS",
    "azure.com": "Azure", "googleusercontent.com": "Google",
    "fastly.net": "Fastly", "cloudflare.com": "Cloudflare",
}

def detect_cdn(cname: str) -> Optional[str]:
    for suffix, provider in CDN_SUFFIXES.items():
        if cname.endswith(suffix): return provider
    return None
```

---

## 4. Program Data Model

```python
from dataclasses import dataclass, field
from typing import Optional
from datetime import date

@dataclass
class Program:
    id: str
    name: str
    platform: str
    url: str
    scope_entries: list[ScopeEntry] = field(default_factory=list)
    asset_records: list[AssetRecord] = field(default_factory=list)
    state: TargetState = TargetState.CREATED
    created_at: str = ""
    updated_at: str = ""
    created_by: str = ""
    tags: list[str] = field(default_factory=list)
    health_score: float = 0.0
    last_tested: Optional[str] = None
    retest_interval_days: int = 90
    notes: str = ""
```

---

## 5. Target Lifecycle

Programs move through a well-defined state machine. Invalid transitions are rejected at write time.

```python
from enum import Enum, auto

class TargetState(Enum):
    CREATED = auto()
    ENUMERATING = auto()
    TESTING = auto()
    PAUSED = auto()
    REPORTED = auto()
    CLOSED = auto()
    RETEST_QUEUED = auto()

VALID_TRANSITIONS = {
    TargetState.CREATED:      [TargetState.ENUMERATING, TargetState.CLOSED],
    TargetState.ENUMERATING:  [TargetState.TESTING, TargetState.PAUSED],
    TargetState.TESTING:      [TargetState.REPORTED, TargetState.PAUSED, TargetState.RETEST_QUEUED],
    TargetState.PAUSED:       [TargetState.TESTING, TargetState.CLOSED],
    TargetState.REPORTED:     [TargetState.RETEST_QUEUED, TargetState.CLOSED],
    TargetState.RETEST_QUEUED:[TargetState.TESTING, TargetState.CLOSED],
    TargetState.CLOSED:       [],
}

def transition(state: TargetState, action: str) -> TargetState:
    if action not in VALID_TRANSITIONS[state]:
        raise ValueError(f"Invalid transition: {state.name} → {action}")
    return TargetState[action]
```

### Lifecycle Event Log

```python
from dataclasses import dataclass

@dataclass
class LifecycleEvent:
    program_id: str
    from_state: str
    to_state: str
    timestamp: str
    actor: str
    metadata: dict = field(default_factory=dict)

event_log: list[LifecycleEvent] = []
```

---

## 6. Asset Tag Grouping

Tags create flexible ad-hoc groupings beyond scope:

```python
from collections import defaultdict

@dataclass
class TagGroup:
    tag: str
    asset_hosts: set = field(default_factory=set)

class TagRegistry:
    def __init__(self):
        self._groups: dict[str, TagGroup] = {}

    def add(self, tag: str, host: str):
        if tag not in self._groups:
            self._groups[tag] = TagGroup(tag=tag)
        self._groups[tag].asset_hosts.add(host)

    def hosts(self, tag: str) -> set[str]:
        return set(self._groups.get(tag, TagGroup(tag=tag)).asset_hosts)
```

---

## 7. Program Health Scoring

Health scoring drives triage priority. Weighted factors:

- Test coverage (0.4 weight)
- Time-since-last-test with half-life decay (0.3 weight)
- Scope change frequency (0.15 weight)
- Historical finding rate (0.15 weight)

```python
import math
from datetime import datetime, timedelta

DECAY_HALFLIFE = 90

def compute_health(program: Program, total_assets: int) -> float:
    tested = sum(1 for a in program.asset_records if a.last_tested)
    coverage = tested / max(total_assets, 1)
    days_since = 9999
    if program.last_tested:
        delta = datetime.utcnow() - datetime.fromisoformat(program.last_tested)
        days_since = delta.days
    score = (
        0.4 * coverage +
        0.3 * math.exp(-days_since * math.log(2) / DECAY_HALFLIFE) +
        0.15 * max(0, 1 - program.scope_changes_recent * 0.1) +
        0.15 * min(program.findings_per_cycle / 5.0, 1.0)
    )
    return max(0.0, min(1.0, score))

def health_label(score: float) -> str:
    if score >= 0.8: return "Healthy"
    if score >= 0.5: return "Adequate"
    if score >= 0.25: return "Degraded"
    return "Critical"
```

---

## 8. Last-Tested Tracking

Stale-asset detection drives retest scheduling:

```python
def stamp_tested(asset: AssetRecord):
    asset.last_tested = datetime.utcnow().isoformat()
    asset.test_count += 1

def stale_assets(assets: list[AssetRecord], max_days: int = 30) -> list[AssetRecord]:
    cutoff = datetime.utcnow() - timedelta(days=max_days)
    return [a for a in assets
            if not a.last_tested or datetime.fromisoformat(a.last_tested) < cutoff]
```

---

## 9. Program Comparison

Side-by-side across scope breadth, attack surface, coverage, finding density, and staleness:

```python
@dataclass
class ProgramComparison:
    program_a: str; program_b: str
    scope_diff: set[str]
    coverage_delta: float
    health_delta: float
    findings_density_delta: float

def compare(a: Program, b: Program) -> ProgramComparison:
    a_hosts = {r.host for r in a.asset_records}
    b_hosts = {r.host for r in b.asset_records}
    s_a = compute_health(a, len(a.asset_records))
    s_b = compute_health(b, len(b.asset_records))
    return ProgramComparison(
        program_a=a.id, program_b=b.id,
        scope_diff=a_hosts.symmetric_difference(b_hosts),
        coverage_delta=len([r for r in a.asset_records if r.last_tested]) / max(len(a.asset_records), 1)
                       - len([r for r in b.asset_records if r.last_tested]) / max(len(b.asset_records), 1),
        health_delta=s_a - s_b,
        findings_density_delta=a.findings_per_cycle - b.findings_per_cycle,
    )
```

---

## 10. Quick-Reference Checklist

- [ ] `ScopeEntry` supports wildcard domain, CIDR, exact domain, and regex matchers
- [ ] HTTP client wrapped with `ScopeEnforcingTransport` interceptor
- [ ] ASN/CDN enrichment runs at asset ingest
- [ ] `TargetState` state machine validates all transitions
- [ ] Bulk import from YAML, JSONL, and CSV
- [ ] `compute_health()` runs nightly for all active programs
- [ ] `stale_assets()` flags assets > 30 days since test
- [ ] `ScopeViolationLog` records every blocked out-of-scope request
- [ ] Program comparison exports to triage dashboard
