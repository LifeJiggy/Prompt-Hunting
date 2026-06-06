# Automation-Efficiency 24: Knowledge Base Automation

## Overview

Knowledge base automation converts static payloads, templates, techniques, and past findings into a queryable, self-improving system. This document covers auto-ingesting Nuclei templates, custom payload libraries, fingerprint databases, PoC management, technique libraries, auto-tagging, cross-referencing, search infrastructure, and learning from triage outcomes.

---

## 1. Auto-Ingesting Nuclei Templates

Pull public templates on a schedule and index them for querying.

```bash
#!/usr/bin/env bash
set -euo pipefail
TEMPLATES_DIR="./nuclei-templates"
INDEX_FILE="./docs/template-index.jsonl"

if [ ! -d "$TEMPLATES_DIR/.git" ]; then
    git clone --depth 1 https://github.com/projectdiscovery/nuclei-templates.git "$TEMPLATES_DIR"
else
    git -C "$TEMPLATES_DIR" pull --ff-only -q
fi

echo "Updated to $(git -C $TEMPLATES_DIR rev-parse --short HEAD)"
> "$INDEX_FILE"
find "$TEMPLATES_DIR" -name "*.yaml" | while read -r f; do
    nid=$(grep -m1 "^id:" "$f" | awk '{print $2}' | tr -d '"')
    sev=$(grep -m1 "^severity:" "$f" | awk '{print $2}' | tr -d '"')
    tags=$(grep -E "^tags:" "$f" | sed 's/^tags: //' | tr -d '"')
    echo "{\"id\":\"$nid\",\"severity\":\"$sev\",\"tags\":\"$tags\",\"path\":\"${f#$TEMPLATES_DIR/}\"}" >> "$INDEX_FILE"
done
echo "Indexed $(wc -l < "$INDEX_FILE") templates"
```

Cron: `0 * * * * /usr/bin/env bash /opt/bounty/scripts/update_templates.sh >> /var/log/bounty/templates.log 2>&1`

Maintain custom templates separate from the public set:

```
bounty-templates/
├── custom/
│   ├── cves/CVE-2025-1234.yaml
│   ├── logic/api-key-exposure.yaml
│   └── aws/s3-public-bucket.yaml
├── public/                   ← git submodule: projectdiscovery/nuclei-templates
└── KNOWN-FALSE-POSITIVES/
    └── noisy-template-id.yaml
```

Custom template index entry:
```json
{
  "id": "custom-api-key-exposure",
  "severity": "high",
  "source": "custom",
  "enabled_by_default": false,
  "requires_auth": true
}
```

---

## 2. Custom Payload Libraries

Organize payloads by category, subcategory, and technology for dynamic selection.

```
payloads/
├── lfi/basic.txt, lfi/filters/truncation-bypass.txt, lfi/tech-specific/php-filter.txt
├── sqli/time-based.txt, sqli/error-based.txt
├── xss/reflected/basic.txt, xss/stored/svg.txt
└── ssti/jinja2.txt, ssti/twig.txt, ssti/freemarker.txt
```

Payload loader:
```python
from dataclasses import dataclass
from pathlib import Path

@dataclass(frozen=True)
class Payload:
    content: str
    category: str
    subcategory: str
    waf_bypass: bool

PAYLOAD_ROOT = Path("./payloads")

def load_payloads(category: str, subcategory: str = "") -> list[Payload]:
    base = PAYLOAD_ROOT / category / subcategory if subcategory else PAYLOAD_ROOT / category
    return [
        Payload(
            content=f.read_text().strip(),
            category=category,
            subcategory=subcategory,
            waf_bypass="waf" in str(f.parent).lower(),
        )
        for f in sorted(base.glob("*.txt"))
    ]

pocs = load_payloads("lfi", "basic")
for p in pocs:
    send_probe(target, param="path", payload=p.content)
```

Payload files embed metadata as `key=value` headers:
```
# payloads/lfi/basic.txt
severity=high
tech=unix
waf_bypass=false
notes=Standard LFI probes, ordered

/etc/passwd
/proc/self/environ
../../../etc/passwd
%2e%2e%2fetc/passwd
```

Parse metadata at runtime:
```python
import re
META_RE = re.compile(r"^(\w+)=(.+)$")

def parse_payload_file(path: Path) -> tuple[dict, list[str]]:
    meta, payloads = {}, []
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = META_RE.match(line)
        if m:
            meta[m.group(1)] = m.group(2)
        else:
            payloads.append(line)
    return meta, payloads
```

---

## 3. Fingerprint Databases

Map observed responses to technology stack, version, and known exploitability.

Fingerprint entry schema:
```json
{
  "fp_id": "fp-php-8",
  "indicator": "X-Powered-By: PHP/8.",
  "type": "header",
  "tech": "php",
  "version": "8.x",
  "confidence": "high",
  "known_vulns": ["CVE-2024-xxxx"],
  "bypass_vectors": ["filter chains", "STDIN wrappers"]
}
```

Sample `fingerprints/headers.jsonl`:
```jsonl
{"fp_id":"fp-nginx","indicator":"server: nginx","type":"header","tech":"nginx","confidence":"high"}
{"fp_id":"fp-cloudflare","indicator":"cf-ray: ","type":"header","tech":"cloudflare","waf":true,"bypass_techniques":["CNAME cloaking","origin IP"]}
{"fp_id":"fp-react-18","indicator":"<!--$-->","type":"dom","tech":"react","version":"18.x","confidence":"medium"}
```

Matcher:
```python
class FingerprintDB:
    def __init__(self, root: Path = Path("./fingerprints")):
        self.headers = [json.loads(l) for l in (root / "headers.jsonl").read_text().splitlines()] if (root / "headers.jsonl").exists() else []
        self.dom = [json.loads(l) for l in (root / "dom.jsonl").read_text().splitlines()] if (root / "dom.jsonl").exists() else []

    def match_headers(self, headers: dict) -> list[dict]:
        haystack = "\n".join(f"{k}: {v}" for k, v in headers.items()).lower()
        return [fp for fp in self.headers if fp["indicator"].lower() in haystack]

    def match_dom(self, snippet: str) -> list[dict]:
        return [fp for fp in self.dom if fp["indicator"] in snippet]
```

Dynamic payload selection:
```python
def select_payloads(response, fp_db: FingerprintDB) -> list[str]:
    matches = fp_db.match_headers(dict(response.headers)) + fp_db.match_dom(response.text[:4096])
    selected = []
    for fp in matches:
        pfile = Path(f"payloads/{fp['tech']}/priority.txt")
        if pfile.exists():
            selected.extend(pfile.read_text().splitlines())
        if fp.get("waf") and fp.get("bypass_techniques"):
            waf = Path(f"payloads/waf-bypass/{fp['tech']}.txt")
            if waf.exists():
                selected.extend(waf.read_text().splitlines())
    return list(dict.fromkeys(selected))
```

---

## 4. Proof-of-Concept Snippet Library

Organize PoC markdown files by vulnerability class for instant retrieval.

```
pocs/
├── xss/reflected/basic-html.md, xss/reflected/dom-clobber.md
├── sqli/time-based.md
├── idor/object-traversal.md
└── ssti/jinja2-rce.md
```

PoC file schema (frontmatter + body):
```markdown
---
id: poc-xss-reflected-001
class: xss
severity: medium
cwe: CWE-79
---

# Reflected XSS — Basic HTML Context

## Preconditions
- Param `q` reflected unsanitized in response
- No CSP header

## Steps

### 1. Verify reflection
```
GET /search?q=test123 HTTP/1.1
```

### 2. Inject
```
https://example.com/search?q=<script>alert(1)</script>
```

### 3. Observe
```http
<script>alert(1)</script>
```
```

Snippet search CLI:
```python
#!/usr/bin/env python3
import argparse
from pathlib import Path

def search(query: str, vuln_class: str | None = None):
    root = Path("./pocs") / vuln_class if vuln_class else Path("./pocs")
    results = []
    for f in root.rglob("*.md"):
        text = f.read_text()
        if query.lower() in text.lower():
            fm = {}
            for line in text.splitlines():
                if line.startswith("---"):
                    break
                if ":" in line:
                    k, v = line.split(":", 1)
                    fm[k.strip()] = v.strip().strip('"')
            results.append({"file": str(f), "title": fm.get("id", "?"), "class": fm.get("class","?")})
    return results

if __name__ == "__main__":
    import json
    parser = argparse.ArgumentParser()
    parser.add_argument("query")
    parser.add_argument("--class", dest="vuln_class")
    args = parser.parse_args()
    print(json.dumps(search(args.query, args.vuln_class), indent=2))
```

---

## 5. Technique Reference Library

```
techniques/
├── ssrf/
│   ├── README.md
│   ├── bypass-ip-table.md         # 30+ IP bypass patterns
│   ├── cloud-metadata.md          # IMDSv1/v2 patterns
│   └── blind-ssrf.md
├── jwt/
│   ├── alg-none.md
│   ├── weak-secret.md
│   └── kid-path-traversal.md
└── deserialization/
    ├── java.md, php.md, python.md
```

Technique entry schema:
```yaml
# techniques/ssrf/blind-ssrf.md
id: ssrf-blind-001
name: Blind SSRF — DNS Callback Detection
class: ssrf
severity_range: [high, critical]
detection_methods:
  - type: dns
    tool: interactsh
    pattern: "unique subdomain per request"
  - type: timing
    pattern: "delta > 5s = callback made"
bypass_vectors:
  - DNS rebinding
  - IP obfuscation (decimal, octal, hex)
  - gopher:// protocol smuggling
historical_payouts:
  - program: H1 Salesforce
    amount: 15000
    year: 2024
```

Lookup:
```python
def techniques_for_stack(tech_stack: list[str]) -> list[dict]:
    results = []
    for tech in tech_stack:
        f = Path(f"techniques/{tech.lower()}/README.md")
        if f.exists():
            results.extend(parse_yaml_frontmatter(f.read_text()))
    return sorted(results, key=lambda x: x.get("severity", []), reverse=True)
```

---

## 6. Auto-Tagging Findings

Apply multi-axis tags to findings automatically on creation.

Axes: `class`, `severity`, `target_type`, `tech_stack`, `waf`, `status`, `program`

```python
import re
from collections import defaultdict

TAG_RULES = [
    (re.compile(r"ssrf|server-side request", re.I),  ("class", "ssrf")),
    (re.compile(r"sql injection|sqli", re.I),          ("class", "sqli")),
    (re.compile(r"xss|cross.site scripting", re.I),   ("class", "xss")),
    (re.compile(r"idor|insecure direct object", re.I), ("class", "idor")),
    (re.compile(r"ssti|template injection", re.I),    ("class", "ssti")),
    (re.compile(r"\/api\/", re.I),                    ("target_type", "api")),
    (re.compile(r"cloudflare|cf-ray", re.I),          ("waf", "cloudflare")),
]

def auto_tag_finding(data: dict) -> dict:
    tags = defaultdict(set)
    text = json.dumps(data)
    for pattern, (axis, value) in TAG_RULES:
        if pattern.search(text):
            tags[axis].add(value)
    data["auto_tags"] = {k: sorted(v) for k, v in tags.items()}
    return data
```

---

## 7. Cross-Referencing Reports

Link findings to related findings, PoCs, techniques, templates, and fingerprint IDs.

Rich cross-refs schema:
```json
{
  "cross_refs": {
    "related_findings": ["F-2024-0103", "F-2025-0019"],
    "poa_of_control": ["pocs/ssrf/blind-ssrf.md"],
    "techniques": ["ssrf-blind-001"],
    "templates": ["CVE-2024-xxxx.yaml"],
    "fingerprints": ["fp-laravel-10", "fp-cloudflare-waf"],
    "payloads_used": ["payloads/ssrf/basic.txt"],
    "waf_bypasses_applied": ["dns-rebinding"]
  }
}
```

Bi-directional linking:
```python
def add_cross_ref(from_id: str, to_id: str, relation: str = "related"):
    src = json.loads(Path(f"results/open/{from_id}.json").read_text())
    dst = json.loads(Path(f"results/open/{to_id}.json").read_text())
    src.setdefault("cross_refs", {}).setdefault(relation, []).append(to_id)
    dst.setdefault("cross_refs", {}).setdefault(f"{relation}_back", []).append(from_id)
    Path(f"results/open/{from_id}.json").write_text(json.dumps(src, indent=2))
    Path(f"results/open/{to_id}.json").write_text(json.dumps(dst, indent=2))
```

---

## 8. Search Infrastructure

SQLite full-text index for fast queries across all KB content.

```python
import sqlite3

DB_PATH = Path("./cache/knowledge-base.db")

def init_kb_db():
    con = sqlite3.connect(DB_PATH)
    con.executescript("""
        CREATE TABLE IF NOT EXISTS findings (id TEXT PRIMARY KEY, title TEXT, severity TEXT, target TEXT, class TEXT);
        CREATE TABLE IF NOT EXISTS techniques (id TEXT PRIMARY KEY, name TEXT, class TEXT);
        CREATE TABLE IF NOT EXISTS templates  (id TEXT PRIMARY KEY, name TEXT, severity TEXT, tags TEXT);
        CREATE VIRTUAL TABLE IF NOT EXISTS findings_fts USING fts5(id, title, target, content=findings);
    """)
    con.commit()
```

Full-text query:
```python
def kb_search(query: str, table: str = "findings") -> list[dict]:
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    if table == "findings":
        rows = con.execute("SELECT * FROM findings_fts WHERE findings_fts MATCH ?", (query,)).fetchall()
    else:
        rows = con.execute(f"SELECT * FROM {table} WHERE id LIKE ?", (f"%{query}%",)).fetchall()
    return [dict(r) for r in rows]
```

ripgrep CLI shortcut:
```bash
kb() { rg --json -i "$*" ./techniques/ ./pocs/ ./payloads/ | jq -r 'select(.type=="match") | .data.matches[].lines.text' | sort -u; }
```

---

## 9. Learning from Triage Outcomes

Log triage decisions to build accurate payload effectiveness stats.

Triage outcome schema:
```json
{
  "finding_id": "F-2025-0042",
  "outcome": "valid",
  "triaged_by": "bob",
  "triaged_at": "2025-06-06T09:00:00Z",
  "bounty_amount": 2500,
  "program": "H1 Uber",
  "auto_tags_at_triage": {"class": ["ssrf"]},
  "learnings": ["Include Collaborator URL", "Mention IMDSv1"]
}
```

Feedback processor:
```python
from collections import defaultdict
FEEDBACK_LOG = Path("./logs/triage-feedback.jsonl")

def record_triage(outcome: dict):
    with open(FEEDBACK_LOG, "a") as f:
        f.write(json.dumps(outcome) + "\n")
    update_payload_effectiveness(outcome)

def update_payload_effectiveness(outcome: dict):
    stats = defaultdict(lambda: {"hits": 0, "valid": 0})
    if Path("./stats/payloads.json").exists():
        stats.update(json.loads(Path("./stats/payloads.json").read_text()))
    for cls in outcome.get("auto_tags_at_triage", {}).get("class", []):
        stats[cls]["hits"] += 1
        if outcome["outcome"] == "valid":
            stats[cls]["valid"] += 1
    Path("./stats/payloads.json").write_text(json.dumps(stats, indent=2))

def accuracy_for_class(cls: str) -> float:
    s = json.loads(Path("./stats/payloads.json").read_text()).get(cls, {"hits":0,"valid":0})
    return s["valid"] / s["hits"] if s["hits"] else 0.0
```

Weekly report generator:
```python
def weekly_triage_report() -> str:
    week_ago = (datetime.utcnow() - timedelta(days=7)).isoformat()
    outcomes = [json.loads(l) for l in FEEDBACK_LOG.read_text().splitlines() if json.loads(l)["triaged_at"] > week_ago]
    classes = defaultdict(int)
    for o in outcomes:
        for c in o.get("auto_tags_at_triage", {}).get("class", []):
            classes[c] += 1
    lines = ["## Weekly Triage Report\n", f"- Total: {len(outcomes)}"]
    for cls, count in sorted(classes.items(), key=lambda x: -x[1]):
        lines.append(f"- {cls}: {count} hits, accuracy {accuracy_for_class(cls):.0%}")
    return "\n".join(lines)
```

---

## 10. Knowledge Base Health Checks

```python
KB_CHECKS = {
    "templates_synced": lambda: Path("./nuclei-templates/.git").exists() and Path("./docs/template-index.jsonl").exists(),
    "fingerprints_loaded": lambda: Path("./fingerprints/headers.jsonl").exists(),
    "pocs_indexed":      lambda: len(list(Path("./pocs").rglob("*.md"))) > 0,
    "techniques_ready":  lambda: len(list(Path("./techniques").rglob("*.md"))) > 0,
    "feedback_logged":   lambda: Path("./logs/triage-feedback.jsonl").exists() and Path("./logs/triage-feedback.jsonl").stat().st_size > 0,
    "stats_fresh":       lambda: Path("./stats/payloads.json").exists() and (datetime.utcnow() - datetime.fromtimestamp(Path("./stats/payloads.json").stat().st_mtime)).days < 7,
}

def run_kb_healthcheck():
    return {k: v() for k, v in KB_CHECKS.items()}
```

---

## 11. Checklist

- [ ] `scripts/update_templates.sh` runs hourly via cron
- [ ] Custom templates in `bounty-templates/custom/` separated from public submodule
- [ ] Payload files include `key=value` metadata headers (severity, tech, waf_bypass)
- [ ] Fingerprint DB covers header, DOM, and TLS facets
- [ ] PoC library in `pocs/` follows frontmatter template
- [ ] Technique library in `techniques/` includes bypass tables and payout history
- [ ] Auto-tagger runs on every new finding before it enters `results/`
- [ ] SQLite KB index (`knowledge-base.db`) rebuilt nightly
- [ ] Triage outcomes logged to `logs/triage-feedback.jsonl` with full schema
- [ ] `stats/payloads.json` updated after every triage; accuracy per class tracked
- [ ] KB healthcheck runs daily; alerts if templates > 2h stale or feedback log empty
