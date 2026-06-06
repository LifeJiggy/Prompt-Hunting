# 12 — Result Deduplication

## 1. Why Deduplication Matters

Running multiple tools against the same target produces the same finding dozens of times. Deduplication collapses them into a single record with full provenance. Without it, triage is overwhelmed, reporting is inflated, and severity weighting is distorted.

---

## 2. Exact-Match Deduplication

The dedup key normalizes URL, method, and parameters into a deterministic string.

### Canonical Request Key

```python
import hashlib, re
from urllib.parse import urlparse, urlencode, parse_qsl

def canonical_key(url: str, method: str = "GET", params: dict | None = None) -> str:
    parsed = urlparse(url)
    query = sorted(parse_qsl(parsed.query))
    if params:
        query += sorted((k, str(v)) for k, v in params.items())
    normalized = parsed._replace(
        query=urlencode(query, doseq=True),
        netloc=parsed.netloc.lower(),
        path=parsed.path.rstrip("/") or "/",
    ).geturl()
    return hashlib.sha256(f"{method.upper()}:{normalized}".encode()).hexdigest()[:16]

assert canonical_key("https://a.com/b?b=2&a=1") == canonical_key("https://a.com/b?a=1&b=2")
```

### Exact-Match Deduplicator

```python
from collections import defaultdict

class ExactMatchDedup:
    def __init__(self):
        self._seen: dict[str, dict] = {}

    def add(self, finding: dict) -> dict | None:
        key = canonical_key(finding["url"], finding.get("method", "GET"))
        if key in self._seen:
            return None  # duplicate suppressed
        self._seen[key] = finding
        return finding
```

---

## 3. Fuzzy Matching

Near-duplicates differ by parameter order, payload encoding variants, or numeric IDs. Levenshtein distance on the normalized URL catches them.

### Levenshtein Distance and Similarity

```python
def levenshtein(a: str, b: str) -> int:
    if len(a) < len(b): return levenshtein(b, a)
    if not b: return len(a)
    prev, curr = list(range(len(b) + 1)), [0] * (len(b) + 1)
    for i, ca in enumerate(a, 1):
        curr[0] = i
        for j, cb in enumerate(b, 1):
            curr[j] = min(prev[j] + 1, curr[j-1] + 1, prev[j-1] + (0 if ca == cb else 1))
        prev = curr[:]
    return prev[-1]

def similarity(a: str, b: str) -> float:
    d = levenshtein(a, b); longer = max(len(a), len(b))
    return 1.0 if longer == 0 else 1.0 - d / longer
```

### Fuzzy Grouping Pass

Apply exact dedup first, then collapse similar URLs:

```python
def group_fuzzy(findings: list[dict], threshold: float = 0.88) -> list[dict]:
    noise = lambda s: re.sub(r"[0-9]+", "N", s)
    groups: list[list[dict]] = []
    for f in findings:
        key = noise(canonical_key(f["url"]))
        placed = False
        for group in groups:
            if similarity(key, noise(canonical_key(group[0]["url"]))) >= threshold:
                group.append(f); placed = True; break
        if not placed: groups.append([f])
    return [max(g, key=lambda x: severity_rank(x)) for g in groups]
```

---

## 4. Request Fingerprinting

Extend the dedup key for POST bodies and relevant headers.

```python
def fingerprint_request(url: str, method: str, headers: dict, body: bytes = b"") -> str:
    parsed = urlparse(url)
    query = urlencode(sorted(parse_qsl(parsed.query)), doseq=True)
    norm_url = parsed._replace(query=query).geturl().lower().rstrip("/")
    relevant = {k: v for k, v in headers.items()
                if k.lower() in ("content-type", "authorization", "x-api-key")}
    header_str = "|".join(f"{k}:{v}" for k, v in sorted(relevant.items()))
    return hashlib.sha256(
            f"{method.upper()}:{norm_url}:{header_str}:{hashlib.md5(body).hexdigest()}".encode()
        ).hexdigest()[:16]
```

### Parameter Structure Fingerprint

Two requests with the same parameters but different values still collapse:

```python
def param_structure_fp(url: str, params: dict) -> str:
    s = {k: "X" for k in params}
    return hashlib.sha256(canonical_key(url, params=s).encode()).hexdigest()[:16]
```

---

## 5. Response Body Hashing

### Full-Body MD5 (Baseline)

```python
def response_hash(body: bytes) -> str:
    return hashlib.md5(body).hexdigest()[:12]
```

### Semantic Hash (Ignore Dynamic Content)

Timestamps, CSRF tokens, and request IDs change every hit but do not represent different responses:

```python
import re

DYNAMIC_PATTERNS = [
    re.compile(rb"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", re.I),
    re.compile(rb"transaction[_\-]?id[\"\s:=]+[A-Za-z0-9]+", re.I),
    re.compile(rb"\"now\"\s*:\s*\"[^\"]+\""),
    re.compile(rb"<!--\s*generated\s+at\s+[\d:\s-]+-->", re.I),
    re.compile(rb"Set-Cookie:\s*[^\r\n]+", re.I),
    re.compile(rb"Date:\s*[^\r\n]+", re.I),
]

def semantic_response_hash(body: bytes) -> str:
    h = body
    for pat in DYNAMIC_PATTERNS: h = pat.sub(b"<dynamic>", h)
    h = re.sub(rb"\s+", b" ", h).strip()
    return hashlib.md5(h).hexdigest()[:12]
```

---

## 6. Nuclei Duplicate Collapsing

Nuclei entries include `template-id`, `type`, `matched-at`, and `extracted-results`.

```python
def nuclei_dedup_key(entry: dict) -> tuple:
    tpl = entry.get("template-id", "")
    matched = entry.get("matched-at", "").rstrip("/").lower()
    extracted = tuple(sorted(entry.get("extracted-results", [])))
    return (tpl, matched, extracted)

class NucleiCollapser:
    def __init__(self):
        self._seen: dict[tuple, dict] = {}

    def process(self, entry: dict) -> dict | None:
        key = nuclei_dedup_key(entry)
        if key in self._seen:
            prev = self._seen[key]
            prev["occurrence_count"] = prev.get("occurrence_count", 1) + 1
            return None
        entry["occurrence_count"] = 1
        entry["first_seen"] = entry["last_seen"] = datetime.utcnow().isoformat()
        self._seen[key] = entry
        return entry
```

---

## 7. Cross-Tool Deduplication

Different tools use different terminology for the same finding. A `high` XSS from nuclei and a `high` XSS from a custom scanner are the same bug.

### Finding Fingerprint

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class FindingFingerprint:
    vuln_type: str
    host: str
    path: str
    param: str

    def key(self) -> str:
        return hashlib.sha256(
            f"{self.vuln_type}:{self.host}:{self.path}:{self.param}".encode()
        ).hexdigest()[:16]
```

### Cross-Tool Registry

```python
class CrossToolDedupRegistry:
    def __init__(self):
        self._findings: dict[str, dict] = {}

    def merge(self, fp: FindingFingerprint, source_tool: str, finding: dict) -> dict | None:
        k = fp.key()
        if k in self._findings:
            existing = self._findings[k]
            existing.setdefault("source_tools", []).append(source_tool)
            existing.setdefault("raw_events", []).append(finding)
            return None
        finding["source_tools"] = [source_tool]
        self._findings[k] = finding
        return finding
```

Usage:

```python
registry = CrossToolDedupRegistry()
entry = {"template-id": "cve-2023-XXXX", "type": "http", "matched-at": "https://target.com/login"}
fp = nuclei_to_fingerprint(entry)
kept = registry.merge(fp, "nuclei", entry)
```

---

## 8. Dedup Key Design

A good dedup key is deterministic, collision-resistant, and tool-agnostic:

```python
def design_dedup_key(layers: dict) -> str:
    """
    layers = {
        "vuln_type", "host", "path", "param",
        "request_method", "body_hash"
    }
    """
    ordered = ":".join(f"{k}={layers[k]}" for k in (
        "vuln_type", "host", "path", "param", "request_method", "body_hash"
    ))
    return hashlib.sha256(ordered.encode()).hexdigest()[:16]
```

---

## 9. First-Seen Provenance

Attach suppressed duplicates to the primary record rather than discarding:

```python
from dataclasses import dataclass, field

@dataclass
class ProvenanceRecord:
    finding_key: str
    first_seen_tool: str
    first_seen_at: str
    primary_event_id: str
    merged_events: list[dict] = field(default_factory=list)
    total_occurrences: int = 1

class ProvenanceStore:
    def __init__(self):
        self._records: dict[str, ProvenanceRecord] = {}

    def record(self, finding_key: str, tool: str, event: dict, primary_key: str | None = None):
        if finding_key not in self._records:
            self._records[finding_key] = ProvenanceRecord(
                finding_key=finding_key,
                first_seen_tool=tool,
                first_seen_at=datetime.utcnow().isoformat(),
                primary_event_id=primary_key or finding_key,
            )
        rec = self._records[finding_key]
        if primary_key and primary_key != finding_key:
            rec.merged_events.append({"tool": tool, "event": event})
            rec.total_occurrences += 1
```

---

## 10. Historical Dedup (Batch Rebuild)

Rebuilding dedup over the full scan history follows three steps.

### Step 1: Normalize Legacy Events

```python
def normalize_legacy_event(event: dict) -> dict:
    event.setdefault("vuln_type", event.get("template-id", event.get("type", "unknown")))
    event.setdefault("method", event.get("request", {}).get("method", "GET").upper())
    event.setdefault("url", event.get("matched-at", event.get("url", "")))
    return event

historical = [normalize_legacy_event(e) for e in load_from_db()]
```

### Step 2: Batch Key Indexing

```python
from collections import defaultdict
key_to_events: dict[str, list[dict]] = defaultdict(list)

for event in historical:
    fp = design_dedup_key({
        "vuln_type": event["vuln_type"],
        "host": urlparse(event["url"]).hostname,
        "path": urlparse(event["url"]).path,
        "param": event.get("param", ""),
        "request_method": event.get("method", "GET"),
        "body_hash": response_hash(event.get("body", b"")),
    })
    key_to_events[fp].append(event)
```

### Step 3: Resolve to Primary

```python
final_findings: list[dict] = []
for fp_key, events in key_to_events.items():
    primary = min(events, key=lambda e: datetime.fromisoformat(e.get("timestamp", "9999")))
    primary["occurrence_count"] = len(events)
    primary["all_tools"] = list({e.get("tool", "unknown") for e in events})
    final_findings.append(primary)
```

---

## 11. Dedup Metrics

```python
from dataclasses import dataclass

@dataclass
class DedupMetrics:
    input_events: int = 0
    exact_removed: int = 0
    fuzzy_merged: int = 0
    cross_tool_merged: int = 0
    final_unique: int = 0

    @property
    def dedup_ratio(self) -> float:
        return 0.0 if not self.input_events else 1.0 - self.final_unique / self.input_events

    def report(self) -> dict:
        return {
            "input_events": self.input_events,
            "exact_removed": self.exact_removed,
            "fuzzy_merged": self.fuzzy_merged,
            "cross_tool_merged": self.cross_tool_merged,
            "final_unique": self.final_unique,
            "dedup_ratio": round(self.dedup_ratio, 4),
        }
```

---

## 12. Quick-Reference Checklist

- [ ] `canonical_key()` covers URL, method, sorted query parameters, and body hash
- [ ] Levenshtein `similarity()` threshold tuned per asset type (web: 0.88, API: 0.92)
- [ ] Nuclei entries stripped to root path before `matched-at` dedup
- [ ] Cross-tool `FindingFingerprint` includes vuln_type + host + path + param
- [ ] `ProvenanceStore` tracks first-seen tool + all merged events
- [ ] Historical rebuild uses batch `defaultdict` indexing
- [ ] `DedupMetrics` logged per scan cycle to tune thresholds
