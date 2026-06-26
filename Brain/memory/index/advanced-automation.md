# Advanced Automation — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `advanced-automation` |
| Root Path | `Advanced-Automation/` |
| File Count | 50 primary files + README + registry.json |
| Index Type | Composite multi-key (target, tool, vuln_class, severity, date) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Advanced Automation domain index manages metadata for 50 automated scanning, testing, and workflow files. Each file represents a discrete automation module covering subdomain enumeration, port scanning, vulnerability detection, tool chaining, browser automation, and orchestration. The index enables fast lookup by target, tool type, vulnerability class, severity outcome, date, and automation pipeline membership.

This index supports two primary query patterns:
1. **Find scans for a specific target** — given a domain or IP, retrieve all automation modules that produced results against it.
2. **Find vulnerabilities by class** — given a vulnerability category (e.g., XSS, SSRF), retrieve all automation modules that detect or test for it.

---

## Index Schema

### Primary Index: `automation_scan_results`

```
{
  "doc_type": "scan_result",
  "file_ref": "Advanced-Automation/<filename>.md",
  "module_id": "AA-<number>",
  "module_title": "<title>",
  "target": {
    "type": "enum[domain|ip|url|api_endpoint]",
    "value": "<target identifier>",
    "scope_verified": "boolean"
  },
  "tool": {
    "name": "string",
    "version": "string",
    "category": "enum[subdomain|port|vuln_scan|fuzzing|browser|osint|orchestration]",
    "binary_path": "string"
  },
  "vuln_class": "enum[none|xss|sqli|ssrf|csrf|idor|xxe|ssti|rce|lfi|rfi|cmd_injection|auth_bypass|jwt|deserialization|cors|header_injection|graphql|websocket|cloud_enum|dns|email|social_osint|framework_detection|tech_stack|compliance]",
  "severity": "enum[critical|high|medium|low|info]",
  "date": {
    "created": "ISO-8601",
    "last_run": "ISO-8601",
    "expiry": "ISO-8601"
  },
  "pipeline": {
    "pipeline_id": "string",
    "stage": "enum[recon|fuzzing|exploitation|analysis|reporting]",
    "order": "integer"
  },
  "tags": ["string"],
  "success_rate": "float [0.0-1.0]",
  "avg_runtime_seconds": "integer",
  "false_positive_rate": "float [0.0-1.0]",
  "dependencies": ["string"],
  "output_format": "enum[json|csv|text|html|binary]"
}
```

### Secondary Index: `automation_tool_registry`

```
{
  "tool_name": "string",
  "modules_using": ["AA-<number>"],
  "category": "string",
  "install_command": "string",
  "config_file": "string",
  "last_verified": "ISO-8601"
}
```

### Tertiary Index: `automation_pipeline_map`

```
{
  "pipeline_id": "string",
  "stages": [
    {
      "order": "integer",
      "module_id": "AA-<number>",
      "input_from": "AA-<number>|null",
      "output_to": "AA-<number>|null"
    }
  ],
  "total_runtime_estimate": "integer",
  "created": "ISO-8601"
}
```

---

## Index Creation

### Step 1: Extract Metadata from Each Module

```python
import re
from pathlib import Path
from datetime import datetime

def extract_automation_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    # Extract module number
    match = re.match(r'^(\d+)-(.+)$', filename)
    module_num = int(match.group(1)) if match else 0
    module_slug = match.group(2) if match else filename
    
    # Extract vuln class from filename
    vuln_class = classify_vuln_class(module_slug)
    
    # Extract tool references
    tools = extract_tool_references(content)
    
    # Extract target types
    target_types = extract_target_types(content)
    
    # Extract severity mentions
    severity = extract_severity(content)
    
    # Compute success rate from content
    success_rate = compute_success_rate(content)
    
    return {
        "doc_type": "scan_result",
        "file_ref": f"Advanced-Automation/{filepath.name}",
        "module_id": f"AA-{module_num:02d}",
        "module_title": format_title(module_slug),
        "target": {
            "type": target_types[0] if target_types else "domain",
            "value": "dynamic",
            "scope_verified": True
        },
        "tool": tools[0] if tools else {"name": "unknown", "version": "latest", "category": "vuln_scan"},
        "vuln_class": vuln_class,
        "severity": severity,
        "date": {
            "created": datetime.now().isoformat(),
            "last_run": None,
            "expiry": None
        },
        "pipeline": {
            "pipeline_id": "default",
            "stage": determine_stage(module_num),
            "order": module_num
        },
        "tags": extract_tags(content),
        "success_rate": success_rate,
        "avg_runtime_seconds": extract_runtime(content),
        "false_positive_rate": extract_fp_rate(content),
        "dependencies": extract_dependencies(content),
        "output_format": extract_output_format(content)
    }

def classify_vuln_class(slug: str) -> str:
    mapping = {
        'xss': 'xss', 'cross-site-script': 'xss',
        'sqli': 'sqli', 'sql-injection': 'sqli',
        'ssrf': 'ssrf', 'server-side-request': 'ssrf',
        'csrf': 'csrf', 'cross-site-request': 'csrf',
        'idor': 'idor', 'id-or': 'idor',
        'xxe': 'xxe', 'xml-external': 'xxe',
        'ssti': 'ssti', 'server-side-template': 'ssti',
        'command-injection': 'cmd_injection',
        'jwt': 'jwt', 'json-web-token': 'jwt',
        'deserialization': 'deserialization',
        'cors': 'cors', 'graphql': 'graphql',
        'websocket': 'websocket',
        'subdomain': 'none', 'port': 'none',
        'directory': 'none', 'fuzzing': 'none',
        'cloud': 'cloud_enum', 'dns': 'dns',
        'email': 'email', 'social-media': 'social_osint',
        'framework': 'framework_detection',
        'technology': 'tech_stack', 'compliance': 'compliance',
        'header': 'header_injection',
    }
    slug_lower = slug.lower()
    for key, val in mapping.items():
        if key in slug_lower:
            return val
    return 'none'

def determine_stage(module_num: int) -> str:
    if module_num <= 10:
        return "recon"
    elif module_num <= 30:
        return "fuzzing"
    elif module_num <= 40:
        return "exploitation"
    elif module_num <= 48:
        return "analysis"
    else:
        return "reporting"
```

### Step 2: Build Inverted Indexes

```python
class AutomationIndex:
    def __init__(self):
        self.primary = {}       # module_id -> metadata
        self.by_target = {}     # target_value -> [module_id]
        self.by_tool = {}       # tool_name -> [module_id]
        self.by_vuln = {}       # vuln_class -> [module_id]
        self.by_severity = {}   # severity -> [module_id]
        self.by_date = []       # sorted by date
        self.by_pipeline = {}   # pipeline_id -> [module_id]
        self.by_stage = {}      # stage -> [module_id]
        self.by_tag = {}        # tag -> [module_id]
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        # Invert on target
        tv = doc['target']['value']
        self.by_target.setdefault(tv, []).append(mid)
        
        # Invert on tool
        tn = doc['tool']['name']
        self.by_tool.setdefault(tn, []).append(mid)
        
        # Invert on vuln class
        vc = doc['vuln_class']
        self.by_vuln.setdefault(vc, []).append(mid)
        
        # Invert on severity
        sev = doc['severity']
        self.by_severity.setdefault(sev, []).append(mid)
        
        # Invert on stage
        stage = doc['pipeline']['stage']
        self.by_stage.setdefault(stage, []).append(mid)
        
        # Invert on tags
        for tag in doc['tags']:
            self.by_tag.setdefault(tag, []).append(mid)
        
        # Pipeline
        pid = doc['pipeline']['pipeline_id']
        self.by_pipeline.setdefault(pid, []).append(mid)
        
        # Date-sorted insert
        self.by_date.append((doc['date']['created'], mid))
        self.by_date.sort(key=lambda x: x[0])
```

### Step 3: Persist Index to Disk

```python
import json

def persist_index(index: AutomationIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "advanced-automation",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_target": index.by_target,
            "by_tool": index.by_tool,
            "by_vuln": index.by_vuln,
            "by_severity": index.by_severity,
            "by_stage": index.by_stage,
            "by_tag": index.by_tag,
            "by_pipeline": index.by_pipeline
        },
        "sorted_by_date": index.by_date
    }
    
    index_file = output_dir / "advanced-automation-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Scans for a Target

```python
def find_scans_for_target(index: AutomationIndex, target: str, exact: bool = False) -> list:
    """
    Retrieve all automation modules that ran against a specific target.
    
    Args:
        index: The automation index
        target: Target domain, IP, or URL
        exact: If True, match exact target. If False, substring match.
    
    Returns:
        List of module metadata dicts, sorted by date (newest first)
    """
    results = []
    
    if exact:
        module_ids = index.by_target.get(target, [])
    else:
        for tv, mids in index.by_target.items():
            if target in tv or tv in target:
                module_ids = mids
                break
        else:
            module_ids = []
    
    for mid in module_ids:
        doc = index.primary[mid].copy()
        doc['relevance_score'] = compute_target_relevance(doc, target)
        results.append(doc)
    
    results.sort(key=lambda x: x['relevance_score'], reverse=True)
    return results
```

### Query 2: Find Vulns by Class

```python
def find_vulns_by_class(index: AutomationIndex, vuln_class: str) -> list:
    """
    Retrieve all modules testing for a specific vulnerability class.
    
    Args:
        index: The automation index
        vuln_class: One of the vuln_class enum values
    
    Returns:
        List of module metadata dicts, sorted by success rate
    """
    module_ids = index.by_vuln.get(vuln_class, [])
    results = []
    
    for mid in module_ids:
        doc = index.primary[mid].copy()
        doc['relevance_score'] = doc['success_rate']
        results.append(doc)
    
    results.sort(key=lambda x: x['relevance_score'], reverse=True)
    return results
```

### Query 3: Find by Tool

```python
def find_by_tool(index: AutomationIndex, tool_name: str) -> list:
    module_ids = index.by_tool.get(tool_name, [])
    return [index.primary[mid] for mid in module_ids]
```

### Query 4: Find by Severity

```python
def find_by_severity(index: AutomationIndex, severity: str, min_severity: bool = True) -> list:
    severity_order = ['info', 'low', 'medium', 'high', 'critical']
    if min_severity:
        min_idx = severity_order.index(severity)
        module_ids = []
        for i in range(min_idx, len(severity_order)):
            module_ids.extend(index.by_severity.get(severity_order[i], []))
    else:
        module_ids = index.by_severity.get(severity, [])
    
    return [index.primary[mid] for mid in module_ids]
```

### Query 5: Composite Query

```python
def composite_query(index: AutomationIndex, **kwargs) -> list:
    """
    Multi-criteria query with AND logic.
    Supported kwargs: target, tool, vuln_class, severity, stage, tag
    """
    candidate_sets = []
    
    if 'target' in kwargs:
        candidate_sets.append(set(index.by_target.get(kwargs['target'], [])))
    if 'tool' in kwargs:
        candidate_sets.append(set(index.by_tool.get(kwargs['tool'], [])))
    if 'vuln_class' in kwargs:
        candidate_sets.append(set(index.by_vuln.get(kwargs['vuln_class'], [])))
    if 'severity' in kwargs:
        candidate_sets.append(set(index.by_severity.get(kwargs['severity'], [])))
    if 'stage' in kwargs:
        candidate_sets.append(set(index.by_stage.get(kwargs['stage'], [])))
    if 'tag' in kwargs:
        candidate_sets.append(set(index.by_tag.get(kwargs['tag'], [])))
    
    if not candidate_sets:
        return list(index.primary.values())
    
    intersection = candidate_sets[0]
    for s in candidate_sets[1:]:
        intersection &= s
    
    return [index.primary[mid] for mid in intersection]
```

---

## Search Algorithms

### BM25 Over Module Descriptions

```python
import math

class BM25Scanner:
    def __init__(self, index: AutomationIndex, k1: float = 1.5, b: float = 0.75):
        self.index = index
        self.k1 = k1
        self.b = b
        self.avg_dl = self._compute_avg_dl()
        self.idf_cache = {}
    
    def _tokenize(self, text: str) -> list:
        import re
        tokens = re.findall(r'[a-z0-9]+', text.lower())
        # Remove stopwords
        stopwords = {'the', 'a', 'an', 'is', 'are', 'was', 'were', 'in', 'on', 'at', 'to', 'for', 'of', 'and', 'or', 'not'}
        return [t for t in tokens if t not in stopwords]
    
    def _compute_avg_dl(self) -> float:
        total = 0
        for doc in self.index.primary.values():
            text = f"{doc['module_title']} {doc['vuln_class']} {' '.join(doc['tags'])}"
            total += len(self._tokenize(text))
        return total / max(len(self.index.primary), 1)
    
    def _compute_idf(self, term: str) -> float:
        if term in self.idf_cache:
            return self.idf_cache[term]
        
        n = len(self.index.primary)
        df = 0
        for doc in self.index.primary.values():
            text = f"{doc['module_title']} {doc['vuln_class']} {' '.join(doc['tags'])}".lower()
            if term in text:
                df += 1
        
        idf = math.log((n - df + 0.5) / (df + 0.5) + 1)
        self.idf_cache[term] = idf
        return idf
    
    def search(self, query: str) -> list:
        query_tokens = self._tokenize(query)
        scores = []
        
        for mid, doc in self.index.primary.items():
            text = f"{doc['module_title']} {doc['vuln_class']} {' '.join(doc['tags'])}".lower()
            doc_tokens = self._tokenize(text)
            doc_len = len(doc_tokens)
            
            # Term frequency map
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                idf = self._compute_idf(qt)
                numerator = tf * (self.k1 + 1)
                denominator = tf + self.k1 * (1 - self.b + self.b * doc_len / self.avg_dl)
                score += idf * numerator / denominator
            
            if score > 0:
                scores.append((mid, score))
        
        scores.sort(key=lambda x: x[1], reverse=True)
        return [(mid, score, self.index.primary[mid]) for mid, score in scores]
```

### Trie-Based Prefix Search

```python
class TrieNode:
    def __init__(self):
        self.children = {}
        self.module_ids = []

class ModuleTrie:
    def __init__(self):
        self.root = TrieNode()
    
    def insert(self, word: str, module_id: str):
        node = self.root
        for char in word.lower():
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
            node.module_ids.append(module_id)
    
    def search_prefix(self, prefix: str) -> list:
        node = self.root
        for char in prefix.lower():
            if char not in node.children:
                return []
            node = node.children[char]
        return list(set(node.module_ids))
```

---

## Relevance Scoring

### Scoring Formula

```python
def compute_relevance(doc: dict, query: dict) -> float:
    """
    Composite relevance score combining multiple signals.
    
    Components:
    - Text match: 0.0-0.4 (BM25 normalized)
    - Exact field match: 0.0-0.3 (target/tool/vuln_class exact match bonus)
    - Recency: 0.0-0.15 (more recent = higher)
    - Success rate: 0.0-0.1 (higher = more relevant)
    - Severity weight: 0.0-0.05 (critical > info)
    
    Final score: weighted sum, range [0, 1.0]
    """
    score = 0.0
    
    # Text match component (0-0.4)
    if 'text_query' in query:
        text_score = bm25_score(doc, query['text_query'])
        score += min(text_score / 10.0, 1.0) * 0.4
    
    # Exact field match (0-0.3)
    match_count = 0
    total_fields = 0
    if 'target' in query:
        total_fields += 1
        if doc['target']['value'] == query['target']:
            match_count += 1
    if 'tool' in query:
        total_fields += 1
        if doc['tool']['name'] == query['tool']:
            match_count += 1
    if 'vuln_class' in query:
        total_fields += 1
        if doc['vuln_class'] == query['vuln_class']:
            match_count += 1
    if 'severity' in query:
        total_fields += 1
        if doc['severity'] == query['severity']:
            match_count += 1
    
    if total_fields > 0:
        score += (match_count / total_fields) * 0.3
    
    # Recency component (0-0.15)
    if doc['date']['last_run']:
        from datetime import datetime
        last_run = datetime.fromisoformat(doc['date']['last_run'])
        days_ago = (datetime.now() - last_run).days
        recency = max(0, 1.0 - (days_ago / 365))
        score += recency * 0.15
    
    # Success rate (0-0.1)
    score += doc.get('success_rate', 0.5) * 0.1
    
    # Severity weight (0-0.05)
    severity_weights = {'critical': 1.0, 'high': 0.75, 'medium': 0.5, 'low': 0.25, 'info': 0.1}
    score += severity_weights.get(doc['severity'], 0.1) * 0.05
    
    return min(score, 1.0)
```

### Score Normalization

```python
def normalize_scores(results: list) -> list:
    """Normalize scores to 0-1 range using min-max normalization."""
    if not results:
        return results
    
    scores = [r['relevance_score'] for r in results]
    min_score = min(scores)
    max_score = max(scores)
    score_range = max_score - min_score
    
    for r in results:
        if score_range > 0:
            r['normalized_score'] = (r['relevance_score'] - min_score) / score_range
        else:
            r['normalized_score'] = 1.0
    
    return results
```

---

## Index Maintenance

### Incremental Update

```python
def update_index(index: AutomationIndex, new_file: Path):
    """Add a new module to the index without rebuilding."""
    doc = extract_automation_metadata(new_file)
    index.add(doc)
    
    # Rebuild date-sorted list
    index.by_date.sort(key=lambda x: x[0])
    
    # Update avg_dl for BM25
    index.bm25_dirty = True

def remove_module(index: AutomationIndex, module_id: str):
    """Remove a module and clean all inverted indexes."""
    if module_id not in index.primary:
        return
    
    doc = index.primary[module_id]
    
    # Remove from all inverted indexes
    for idx_map in [index.by_target, index.by_tool, index.by_vuln, 
                    index.by_severity, index.by_stage, index.by_pipeline]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
                if not mids:
                    del idx_map[key]
    
    for tag in doc['tags']:
        if tag in index.by_tag and module_id in index.by_tag[tag]:
            index.by_tag[tag].remove(module_id)
    
    # Remove from date list
    index.by_date = [(d, m) for d, m in index.by_date if m != module_id]
    
    del index.primary[module_id]
```

### Integrity Verification

```python
def verify_index_integrity(index: AutomationIndex) -> dict:
    """Verify index consistency and report issues."""
    issues = []
    
    # Check all primary docs have required fields
    required_fields = ['module_id', 'file_ref', 'target', 'tool', 'vuln_class', 'severity', 'date']
    for mid, doc in index.primary.items():
        for field in required_fields:
            if field not in doc:
                issues.append(f"Module {mid} missing field: {field}")
    
    # Check inverted indexes reference valid modules
    for mid_list in index.by_target.values():
        for mid in mid_list:
            if mid not in index.primary:
                issues.append(f"by_target has orphan reference: {mid}")
    
    for mid_list in index.by_vuln.values():
        for mid in mid_list:
            if mid not in index.primary:
                issues.append(f"by_vuln has orphan reference: {mid}")
    
    return {
        "total_modules": len(index.primary),
        "issues": issues,
        "healthy": len(issues) == 0
    }
```

### Rebuild Strategy

```python
def rebuild_index(domain_path: Path, output_dir: Path):
    """Full index rebuild from source files."""
    index = AutomationIndex()
    
    for filepath in sorted(domain_path.glob("*.md")):
        if filepath.name == "README.md":
            continue
        doc = extract_automation_metadata(filepath)
        index.add(doc)
    
    persist_index(index, output_dir)
    
    stats = {
        "total": len(index.primary),
        "by_vuln": {k: len(v) for k, v in index.by_vuln.items()},
        "by_tool": {k: len(v) for k, v in index.by_tool.items()},
        "by_severity": {k: len(v) for k, v in index.by_severity.items()},
        "by_stage": {k: len(v) for k, v in index.by_stage.items()}
    }
    return stats
```

---

## Full Domain File References

Each reference below maps a file in `Advanced-Automation/` to its index metadata.

### Recon Stage (Modules AA-01 through AA-10)

| # | File | Module ID | Vuln Class | Tool Category | Stage |
|---|------|-----------|------------|---------------|-------|
| 01 | `01-Subdomain-Enumeration-Automation.md` | AA-01 | none | subdomain | recon |
| 02 | `02-Port-Scanning-Automation.md` | AA-02 | none | port | recon |
| 03 | `03-Vulnerability-Scanning-Automation.md` | AA-03 | none | vuln_scan | recon |
| 04 | `04-JavaScript-Analysis-Automation.md` | AA-04 | none | vuln_scan | recon |
| 05 | `05-API-Endpoint-Discovery.md` | AA-05 | none | vuln_scan | recon |
| 06 | `06-Parameter-Fuzzing-Automation.md` | AA-06 | none | fuzzing | recon |
| 07 | `07-Directory-Brute-Forcing.md` | AA-07 | none | vuln_scan | recon |
| 09 | `09-Authentication-Testing-Automation.md` | AA-09 | auth_bypass | vuln_scan | recon |
| 10 | `10-Session-Management-Testing.md` | AA-10 | auth_bypass | vuln_scan | recon |

### Fuzzing Stage (Modules AA-11 through AA-30)

| # | File | Module ID | Vuln Class | Tool Category | Stage |
|---|------|-----------|------------|---------------|-------|
| 11 | `11-IDOR-Detection-Automation.md` | AA-11 | idor | vuln_scan | fuzzing |
| 12 | `12-SQL-Injection-Automation.md` | AA-12 | sqli | vuln_scan | fuzzing |
| 13 | `13-XSS-Detection-Automation.md` | AA-13 | xss | vuln_scan | fuzzing |
| 14 | `14-SSRF-Testing-Automation.md` | AA-14 | ssrf | vuln_scan | fuzzing |
| 15 | `15-CSRF-Testing-Automation.md` | AA-15 | csrf | vuln_scan | fuzzing |
| 16 | `16-Command-Injection-Automation.md` | AA-16 | cmd_injection | vuln_scan | fuzzing |
| 17 | `17-XXE-Testing-Automation.md` | AA-17 | xxe | vuln_scan | fuzzing |
| 18 | `18-SSTI-Testing-Automation.md` | AA-18 | ssti | vuln_scan | fuzzing |
| 19 | `19-JWT-Testing-Automation.md` | AA-19 | jwt | vuln_scan | fuzzing |
| 20 | `20-Deserialization-Testing.md` | AA-20 | deserialization | vuln_scan | fuzzing |
| 21 | `21-Report-Generation-Automation.md` | AA-21 | none | vuln_scan | fuzzing |
| 22 | `22-PoC-Development-Automation.md` | AA-22 | none | vuln_scan | fuzzing |
| 23 | `23-Target-Scouting-Automation.md` | AA-23 | none | vuln_scan | fuzzing |
| 24 | `24-Scope-Validation-Automation.md` | AA-24 | none | vuln_scan | fuzzing |
| 25 | `25-Asset-Tracking-Automation.md` | AA-25 | none | vuln_scan | fuzzing |
| 26 | `26-Change-Monitoring-Automation.md` | AA-26 | none | vuln_scan | fuzzing |
| 27 | `27-Notification-Alerting-Automation.md` | AA-27 | none | vuln_scan | fuzzing |
| 28 | `28-Data-Collection-Automation.md` | AA-28 | none | vuln_scan | fuzzing |
| 29 | `29-Result-Analysis-Automation.md` | AA-29 | none | vuln_scan | fuzzing |
| 30 | `30-Tool-Chaining-Automation.md` | AA-30 | none | vuln_scan | fuzzing |

### Exploitation Stage (Modules AA-31 through AA-40)

| # | File | Module ID | Vuln Class | Tool Category | Stage |
|---|------|-----------|------------|---------------|-------|
| 31 | `31-Proxy-Integration-Automation.md` | AA-31 | none | vuln_scan | exploitation |
| 32 | `32-Browser-Automation-Workflows.md` | AA-32 | none | browser | exploitation |
| 33 | `33-Headless-Browser-Scripting.md` | AA-33 | none | browser | exploitation |
| 34 | `34-Regex-Pattern-Automation.md` | AA-34 | none | vuln_scan | exploitation |
| 35 | `35-Response-Analysis-Automation.md` | AA-35 | none | vuln_scan | exploitation |
| 36 | `36-Header-Injection-Testing.md` | AA-36 | header_injection | vuln_scan | exploitation |
| 37 | `37-CORS-Testing-Automation.md` | AA-37 | cors | vuln_scan | exploitation |
| 38 | `38-WebSocket-Testing-Automation.md` | AA-38 | websocket | vuln_scan | exploitation |
| 39 | `39-GraphQL-Testing-Automation.md` | AA-39 | graphql | vuln_scan | exploitation |
| 40 | `40-Cloud-Service-Enumeration.md` | AA-40 | cloud_enum | vuln_scan | exploitation |

### Analysis Stage (Modules AA-41 through AA-48)

| # | File | Module ID | Vuln Class | Tool Category | Stage |
|---|------|-----------|------------|---------------|-------|
| 41 | `41-DNS-Data-Extraction-Automation.md` | AA-41 | dns | vuln_scan | analysis |
| 42 | `42-Email-Recon-Automation.md` | AA-42 | email | osint | analysis |
| 43 | `43-Social-Media-OSINT-Automation.md` | AA-43 | social_osint | osint | analysis |
| 44 | `44-Framework-Detection-Automation.md` | AA-44 | framework_detection | vuln_scan | analysis |
| 45 | `45-Technology-Stack-Identification.md` | AA-45 | tech_stack | vuln_scan | analysis |
| 46 | `46-Endpoint-Mapping-Automation.md` | AA-46 | none | vuln_scan | analysis |
| 47 | `47-Content-Discovery-Automation.md` | AA-47 | none | vuln_scan | analysis |
| 48 | `48-Version-Detection-Automation.md` | AA-48 | none | vuln_scan | analysis |

### Reporting Stage (Modules AA-49 through AA-50)

| # | File | Module ID | Vuln Class | Tool Category | Stage |
|---|------|-----------|------------|---------------|-------|
| 49 | `49-Compliance-Checking-Automation.md` | AA-49 | compliance | vuln_scan | reporting |
| 50 | `50-Workflow-Orchestration-Automation.md` | AA-50 | none | orchestration | reporting |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and module index |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

This index connects to the following domain indexes:

- **automation-efficiency.md** — Pipeline optimization data feeds into this index's `pipeline` field.
- **core-prompts-hunting.md** — Findings from hunting modules reference automation modules that produced them.
- **report-writing-mastery.md** — Report generation modules (AA-21, AA-49) connect to reporting indexes.

---

## Usage Examples

### Example 1: Find All XSS Automation Modules

```python
results = find_vulns_by_class(index, 'xss')
# Returns: [AA-13 (XSS-Detection-Automation), ...]
```

### Example 2: Find All Modules Using Subfinder

```python
results = find_by_tool(index, 'subfinder')
# Returns: [AA-01 (Subdomain-Enumeration-Automation), ...]
```

### Example 3: Find High-Severity Recon Modules

```python
results = composite_query(index, severity='high', stage='recon')
# Returns modules that are both high severity AND in recon stage
```

### Example 4: Find Scans for a Specific Domain

```python
results = find_scans_for_target(index, 'example.com', exact=False)
# Returns all modules whose target field contains 'example.com'
```

### Example 5: Text Search for "GraphQL introspection"

```python
scanner = BM25Scanner(index)
results = scanner.search("graphql introspection vulnerability")
# Returns ranked list of modules matching the query
```
