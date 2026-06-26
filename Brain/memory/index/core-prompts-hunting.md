# Core Prompts Hunting — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `core-prompts-hunting` |
| Root Path | `Core-Prompts-hunting/` |
| File Count | 50 primary files + README + registry.json |
| Index Type | Finding-centric (vuln_class, severity, endpoint) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Core Prompts Hunting domain index manages metadata for 50 hunting prompt modules. Each file defines structured prompts for discovering specific vulnerability classes in web applications. The index organizes findings by vulnerability class, severity, endpoint patterns, and detection methodology. It supports both prompt-based discovery and finding aggregation.

This index supports two primary query patterns:
1. **Find all XSS findings** (or any vuln class) — given a vulnerability class, retrieve all hunting modules and their aggregated findings.
2. **Find findings on a specific endpoint** — given an endpoint pattern, retrieve all modules that target or reference that endpoint type.

---

## Index Schema

### Primary Index: `hunting_records`

```json
{
  "doc_type": "hunting_record",
  "file_ref": "Core-Prompts-hunting/<filename>.md",
  "module_id": "CH-<number>",
  "module_title": "<title>",
  "vuln_class": "enum[recon|javascript|api|auth|authorization|input_validation|business_logic|client_storage|cryptography|error_handling|file_upload|ssrf|csrf|cors|race_condition|third_party|configuration|network|mobile_api|reporting|waf_bypass|http_smuggling|subdomain_takeover|host_header|xxe|deserialization|command_injection|nosql|graphql|websocket|ssti|jwt|csp_bypass|clickjacking|parameter_pollution|ldap|session_puzzling|file_handling|xssi|prototype_pollution|response_splitting|xpath|csrf_dup|cors_dup|race_dup|third_party_dup|config_dup|network_dup|mobile_dup|reporting_dup]",
  "detection_method": "enum[passive|active|fuzzing|manual|automated|hybrid]",
  "severity_range": {
    "min": "enum[critical|high|medium|low|info]",
    "max": "enum[critical|high|medium|low|info]"
  },
  "endpoint_patterns": ["string"],
  "payloads_count": "integer",
  "detection_techniques": ["string"],
  "tools_required": ["string"],
  "false_positive_mitigation": "string",
  "confidence_level": "enum[high|medium|low]",
  "automation_feasibility": "enum[high|medium|low|manual_only]",
  "tags": ["string"],
  "prerequisites": ["string"],
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `finding_aggregation`

```json
{
  "vuln_class": "string",
  "modules": ["CH-<number>"],
  "total_payloads": "integer",
  "avg_confidence": "float",
  "severity_distribution": {
    "critical": "integer",
    "high": "integer",
    "medium": "integer",
    "low": "integer",
    "info": "integer"
  }
}
```

### Tertiary Index: `endpoint_index`

```json
{
  "endpoint_pattern": "string",
  "modules": ["CH-<number>"],
  "vuln_classes": ["string"]
}
```

---

## Index Creation

```python
import re
from pathlib import Path
from datetime import datetime

def extract_hunting_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    module_num = int(match.group(1)) if match else 0
    module_slug = match.group(2) if match else filename
    
    vuln_class = classify_hunting_vuln(module_slug)
    detection_method = detect_method(content)
    severity = extract_severity_range(content)
    endpoints = extract_endpoint_patterns(content)
    payloads = count_payloads(content)
    techniques = extract_detection_techniques(content)
    tools = extract_tools(content)
    fp_mitigation = extract_fp_mitigation(content)
    confidence = detect_confidence(content)
    automation = detect_automation_feasibility(content)
    
    return {
        "doc_type": "hunting_record",
        "file_ref": f"Core-Prompts-hunting/{filepath.name}",
        "module_id": f"CH-{module_num:02d}",
        "module_title": format_title(module_slug),
        "vuln_class": vuln_class,
        "detection_method": detection_method,
        "severity_range": severity,
        "endpoint_patterns": endpoints,
        "payloads_count": payloads,
        "detection_techniques": techniques,
        "tools_required": tools,
        "false_positive_mitigation": fp_mitigation,
        "confidence_level": confidence,
        "automation_feasibility": automation,
        "tags": extract_tags(content),
        "prerequisites": extract_prerequisites(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_hunting_vuln(slug: str) -> str:
    mapping = {
        'reconnaissance': 'recon', 'asset-discovery': 'recon',
        'javascript': 'javascript', 'deobfuscation': 'javascript',
        'api-endpoint': 'api', 'api-analysis': 'api',
        'authentication': 'auth', 'session-management': 'auth',
        'authorization': 'authorization', 'access-control': 'authorization',
        'input-validation': 'input_validation', 'sanitization': 'input_validation',
        'business-logic': 'business_logic',
        'client-side': 'client_storage', 'storage-security': 'client_storage',
        'cryptography': 'cryptography', 'data-protection': 'cryptography',
        'error-handling': 'error_handling', 'information-disclosure': 'error_handling',
        'file-upload': 'file_upload', 'processing': 'file_upload',
        'ssrf': 'ssrf', 'server-side-request': 'ssrf',
        'csrf': 'csrf', 'cross-site-request': 'csrf',
        'cors': 'cors', 'cross-origin': 'cors',
        'race-condition': 'race_condition', 'concurrency': 'race_condition',
        'third-party': 'third_party', 'component': 'third_party',
        'configuration': 'configuration', 'misconfiguration': 'configuration',
        'network': 'network', 'infrastructure': 'network',
        'mobile': 'mobile_api', 'api-specific': 'mobile_api',
        'reporting': 'reporting', 'poc': 'reporting',
        'waf-bypass': 'waf_bypass', 'firewall': 'waf_bypass',
        'http-smuggling': 'http_smuggling', 'request-smuggling': 'http_smuggling',
        'subdomain-takeover': 'subdomain_takeover',
        'host-header': 'host_header',
        'xxe': 'xxe', 'xml-external': 'xxe',
        'deserialization': 'deserialization',
        'command-injection': 'command_injection',
        'nosql': 'nosql', 'mongodb': 'nosql',
        'graphql': 'graphql',
        'websocket': 'websocket',
        'ssti': 'ssti', 'template-injection': 'ssti',
        'jwt': 'jwt', 'json-web-token': 'jwt',
        'csp-bypass': 'csp_bypass', 'content-security': 'csp_bypass',
        'clickjacking': 'clickjacking', 'ui-redressing': 'clickjacking',
        'parameter-pollution': 'parameter_pollution', 'hpp': 'parameter_pollution',
        'ldap': 'ldap', 'xpath': 'xpath',
        'session': 'session_puzzling', 'fixation': 'session_puzzling',
        'file-handling': 'file_handling', 'insecure-file': 'file_handling',
        'xssi': 'xssi', 'script-inclusion': 'xssi',
        'prototype-pollution': 'prototype_pollution',
        'response-splitting': 'response_splitting',
    }
    slug_lower = slug.lower()
    for key, val in mapping.items():
        if key in slug_lower:
            return val
    return 'recon'

def detect_method(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['passive', 'no request', 'observe']):
        return 'passive'
    if any(kw in text for kw in ['fuzz', 'payload', 'inject', 'send request']):
        return 'fuzzing'
    if any(kw in text for kw in ['manual', 'hand']):
        return 'manual'
    if any(kw in text for kw in ['automat', 'script', 'pipeline']):
        return 'automated'
    return 'hybrid'

def extract_severity_range(content: dict) -> dict:
    text = content.lower() if isinstance(content, str) else ''
    severity_map = {'critical': 4, 'high': 3, 'medium': 2, 'low': 1, 'info': 0}
    
    found = []
    for sev in severity_map:
        if sev in text:
            found.append(sev)
    
    if not found:
        return {"min": "low", "max": "high"}
    
    sorted_found = sorted(found, key=lambda x: severity_map[x])
    return {"min": sorted_found[0], "max": sorted_found[-1]}

def extract_endpoint_patterns(content: str) -> list:
    patterns = []
    url_patterns = re.findall(r'(?:https?://)?[\w.-]+(?:/[\w/.-]*)?', content)
    api_patterns = re.findall(r'/api/[\w/.-]+', content)
    path_patterns = re.findall(r'/[\w]+(?:/[\w]+)*', content)
    
    patterns.extend(list(set(url_patterns[:5])))
    patterns.extend(list(set(api_patterns[:5])))
    patterns.extend(list(set(path_patterns[:5])))
    
    return patterns[:10] if patterns else ['/']

def count_payloads(content: str) -> int:
    payload_count = 0
    lines = content.split('\n')
    in_payload_block = False
    for line in lines:
        if 'payload' in line.lower() or '```' in line:
            in_payload_block = not in_payload_block
        if in_payload_block and ('<' in line or 'script' in line.lower() or 
            'select' in line.lower() or 'union' in line.lower()):
            payload_count += 1
    
    return max(payload_count, len(re.findall(r'`[^`]+`', content)))

def extract_detection_techniques(content: str) -> list:
    techniques = []
    text = content.lower()
    technique_keywords = [
        'response analysis', 'header analysis', 'timing attack',
        'error-based', 'boolean-based', 'union-based', 'blind',
        'reflected', 'stored', 'dom-based', 'out-of-band',
        'content-type check', 'status code', 'body inspection',
        'regex match', 'word list', 'fuzzing', 'brute force',
        'passive scan', 'active scan', 'crawler', 'spider'
    ]
    for tech in technique_keywords:
        if tech in text:
            techniques.append(tech)
    return techniques[:10]

def extract_tools(content: str) -> list:
    text = content.lower()
    tools = []
    tool_names = [
        'burp', 'nmap', 'nikto', 'sqlmap', 'xsstrike', 'dalfox',
        'ffuf', 'gobuster', 'subfinder', 'httpx', 'nuclei', 'katana',
        'waybackurls', 'gau', 'amass', 'sublist3r', 'wpscan',
        'curl', 'python', 'ruby', 'nodejs', 'postman', 'zap',
        'chrome devtools', 'firefox', 'wireshark', 'mitmproxy'
    ]
    for tool in tool_names:
        if tool in text:
            tools.append(tool)
    return tools

def extract_fp_mitigation(content: str) -> str:
    text = content.lower()
    if 'false positive' in text:
        match = re.search(r'false positive.*?(?:to reduce|mitigation|avoid|prevent)[:\s]+(.+?)(?:\n|$)', text)
        if match:
            return match.group(1).strip()
    return "manual verification recommended"

def detect_confidence(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['high confidence', 'reliable', 'accurate']):
        return 'high'
    if any(kw in text for kw in ['medium confidence', 'moderate']):
        return 'medium'
    return 'low'

def detect_automation_feasibility(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['fully automated', 'script', 'pipeline']):
        return 'high'
    if any(kw in text for kw in ['semi-automated', 'partial automation']):
        return 'medium'
    if any(kw in text for kw in ['manual only', 'human judgment', 'requires review']):
        return 'manual_only'
    return 'low'

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'owasp', 'top10', 'injection', 'broken-auth', 'sensitive-data',
        'xxe', 'broken-access', 'security-misconfig', 'xss', 'insecure-deserialization',
        'vulnerable-component', 'logging', 'ssrf'
    ]
    text = content.lower()
    for tag in tag_keywords:
        if tag in text:
            tags.append(tag)
    return tags

def extract_prerequisites(content: str) -> list:
    prereqs = []
    text = content.lower()
    prereq_keywords = ['requires authentication', 'requires login', 'needs auth', 'requires api key']
    for kw in prereq_keywords:
        if kw in text:
            prereqs.append(kw)
    return prereqs

def format_title(slug: str) -> str:
    return slug.replace('-', ' ').title()

def extract_date(content: str) -> str:
    match = re.search(r'(\d{4}-\d{2}-\d{2})', content)
    return match.group(1) if match else datetime.now().isoformat()
```

### Build Hunting Index

```python
class HuntingIndex:
    def __init__(self):
        self.primary = {}
        self.by_vuln_class = {}
        self.by_detection_method = {}
        self.by_severity = {}
        self.by_confidence = {}
        self.by_automation = {}
        self.by_tool = {}
        self.by_endpoint = {}
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        self.by_vuln_class.setdefault(doc['vuln_class'], []).append(mid)
        self.by_detection_method.setdefault(doc['detection_method'], []).append(mid)
        self.by_confidence.setdefault(doc['confidence_level'], []).append(mid)
        self.by_automation.setdefault(doc['automation_feasibility'], []).append(mid)
        
        for sev in [doc['severity_range']['min'], doc['severity_range']['max']]:
            self.by_severity.setdefault(sev, []).append(mid)
        
        for tool in doc['tools_required']:
            self.by_tool.setdefault(tool, []).append(mid)
        
        for ep in doc['endpoint_patterns']:
            self.by_endpoint.setdefault(ep, []).append(mid)
    
    def find_all_xss(self) -> list:
        mids = self.by_vuln_class.get('xss', [])
        return [self.primary[mid] for mid in mids]
    
    def find_findings_on_endpoint(self, endpoint: str) -> list:
        results = []
        for mid, doc in self.primary.items():
            for ep in doc['endpoint_patterns']:
                if endpoint in ep or ep in endpoint:
                    results.append(doc)
                    break
        return results
    
    def find_by_vuln_class(self, vuln_class: str) -> list:
        mids = self.by_vuln_class.get(vuln_class, [])
        return [self.primary[mid] for mid in mids]
    
    def find_high_confidence(self) -> list:
        mids = self.by_confidence.get('high', [])
        return [self.primary[mid] for mid in mids]
    
    def find_automatable(self) -> list:
        mids = self.by_automation.get('high', [])
        return [self.primary[mid] for mid in mids]
    
    def get_aggregation(self, vuln_class: str) -> dict:
        mids = self.by_vuln_class.get(vuln_class, [])
        total_payloads = sum(self.primary[mid]['payloads_count'] for mid in mids)
        
        sev_dist = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0, 'info': 0}
        for mid in mids:
            doc = self.primary[mid]
            for sev in [doc['severity_range']['min'], doc['severity_range']['max']]:
                sev_dist[sev] = sev_dist.get(sev, 0) + 1
        
        conf_map = {'high': 1.0, 'medium': 0.5, 'low': 0.25}
        avg_conf = sum(conf_map.get(self.primary[mid]['confidence_level'], 0.5) for mid in mids) / max(len(mids), 1)
        
        return {
            "vuln_class": vuln_class,
            "modules": mids,
            "total_payloads": total_payloads,
            "avg_confidence": round(avg_conf, 2),
            "severity_distribution": sev_dist
        }
```

### Persist Index

```python
import json
from datetime import datetime

def persist_hunting_index(index: HuntingIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "core-prompts-hunting",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_vuln_class": index.by_vuln_class,
            "by_detection_method": index.by_detection_method,
            "by_severity": index.by_severity,
            "by_confidence": index.by_confidence,
            "by_automation": index.by_automation,
            "by_tool": index.by_tool,
            "by_endpoint": index.by_endpoint,
        },
        "aggregations": {
            vc: index.get_aggregation(vc) for vc in index.by_vuln_class
        }
    }
    
    index_file = output_dir / "hunting-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find All XSS Findings

```python
def find_all_xss(index: HuntingIndex) -> list:
    return index.find_all_xss()
```

### Query 2: Find Findings on Endpoint

```python
def find_findings_on_endpoint(index: HuntingIndex, endpoint: str) -> list:
    return index.find_findings_on_endpoint(endpoint)
```

### Query 3: Find by Vuln Class

```python
def find_by_vuln_class(index: HuntingIndex, vuln_class: str) -> list:
    return index.find_by_vuln_class(vuln_class)
```

### Query 4: Find High Confidence Findings

```python
def find_high_confidence(index: HuntingIndex) -> list:
    return index.find_high_confidence()
```

### Query 5: Find Automatable Modules

```python
def find_automatable(index: HuntingIndex) -> list:
    return index.find_automatable()
```

### Query 6: Get Vuln Class Aggregation

```python
def get_aggregation(index: HuntingIndex, vuln_class: str) -> dict:
    return index.get_aggregation(vuln_class)
```

---

## Search Algorithms

### Finding-Ranked Search

```python
class FindingRanker:
    def __init__(self, index: HuntingIndex):
        self.index = index
    
    def rank_findings(self, vuln_class: str = None, 
                      prioritize_severity: bool = True) -> list:
        if vuln_class:
            mids = self.index.by_vuln_class.get(vuln_class, [])
        else:
            mids = list(self.index.primary.keys())
        
        sev_map = {'critical': 4, 'high': 3, 'medium': 2, 'low': 1, 'info': 0}
        conf_map = {'high': 1.0, 'medium': 0.5, 'low': 0.25}
        
        results = []
        for mid in mids:
            doc = self.index.primary[mid]
            
            severity_score = (sev_map.get(doc['severity_range']['max'], 2)) / 4.0
            confidence_score = conf_map.get(doc['confidence_level'], 0.5)
            payload_score = min(doc['payloads_count'] / 20.0, 1.0)
            
            if prioritize_severity:
                score = severity_score * 0.4 + confidence_score * 0.3 + payload_score * 0.3
            else:
                score = confidence_score * 0.4 + payload_score * 0.3 + severity_score * 0.3
            
            doc_copy = doc.copy()
            doc_copy['finding_score'] = round(score, 4)
            results.append(doc_copy)
        
        results.sort(key=lambda x: x['finding_score'], reverse=True)
        return results
```

### BM25 Search

```python
import math

class HuntingBM25:
    def __init__(self, index: HuntingIndex):
        self.index = index
    
    def _tokenize(self, text: str) -> list:
        import re
        tokens = re.findall(r'[a-z0-9]+', text.lower())
        stopwords = {'the', 'a', 'an', 'is', 'are', 'in', 'on', 'for', 'of', 'and', 'or', 'to'}
        return [t for t in tokens if t not in stopwords]
    
    def search(self, query: str) -> list:
        query_tokens = self._tokenize(query)
        scores = []
        
        for mid, doc in self.index.primary.items():
            text = f"{doc['module_title']} {doc['vuln_class']} {' '.join(doc['detection_techniques'])} {' '.join(doc.get('tags', []))}"
            doc_tokens = self._tokenize(text)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                if tf > 0:
                    df = sum(1 for d in self.index.primary.values() 
                             if qt in f"{d['module_title']} {d['vuln_class']}".lower())
                    idf = math.log((len(self.index.primary) - df + 0.5) / (df + 0.5) + 1)
                    score += idf * tf
            
            if score > 0:
                scores.append((mid, score))
        
        scores.sort(key=lambda x: x[1], reverse=True)
        return [(mid, s, self.index.primary[mid]) for mid, s in scores]
```

---

## Relevance Scoring

```python
def compute_hunting_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'vuln_class' in query and doc['vuln_class'] == query['vuln_class']:
        score += 0.30
    if 'endpoint' in query:
        for ep in doc['endpoint_patterns']:
            if query['endpoint'] in ep:
                score += 0.25
                break
    if 'severity' in query:
        sev_order = ['info', 'low', 'medium', 'high', 'critical']
        if sev_order.index(doc['severity_range']['max']) >= sev_order.index(query['severity']):
            score += 0.20
    
    conf_map = {'high': 0.15, 'medium': 0.10, 'low': 0.05}
    score += conf_map.get(doc['confidence_level'], 0.05)
    
    score += min(doc['payloads_count'] / 50.0, 0.10)
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_hunting_index(index: HuntingIndex, new_file: Path):
    doc = extract_hunting_metadata(new_file)
    index.add(doc)

def remove_module(index: HuntingIndex, module_id: str):
    if module_id not in index.primary:
        return
    doc = index.primary[module_id]
    
    for idx_map in [index.by_vuln_class, index.by_detection_method, 
                    index.by_severity, index.by_confidence, index.by_automation]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
    
    for tool in doc['tools_required']:
        if tool in index.by_tool and module_id in index.by_tool[tool]:
            index.by_tool[tool].remove(module_id)
    
    for ep in doc['endpoint_patterns']:
        if ep in index.by_endpoint and module_id in index.by_endpoint[ep]:
            index.by_endpoint[ep].remove(module_id)
    
    del index.primary[module_id]

def verify_hunting_index(index: HuntingIndex) -> dict:
    issues = []
    for mid, doc in index.primary.items():
        if not doc.get('vuln_class'):
            issues.append(f"Module {mid} has no vuln class")
        if doc['payloads_count'] < 0:
            issues.append(f"Module {mid} has negative payload count")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Module ID | Vuln Class | Detection | Confidence |
|---|------|-----------|------------|-----------|------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery.md` | CH-01 | recon | passive | high |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation.md` | CH-02 | javascript | manual | high |
| 03 | `3-API-Endpoint-Analysis.md` | CH-03 | api | hybrid | high |
| 04 | `4-Authentication-and-Session-Management.md` | CH-04 | auth | active | medium |
| 05 | `5-Authorization-and-Access-Control.md` | CH-05 | authorization | active | high |
| 06 | `6-Input-Validation-and-Sanitization.md` | CH-06 | input_validation | fuzzing | high |
| 07 | `7-Business-Logic-Flaws.md` | CH-07 | business_logic | manual | medium |
| 08 | `8-Client-Side-Storage-Security.md` | CH-08 | client_storage | passive | high |
| 09 | `9-Cryptography-and-Data-Protection.md` | CH-09 | cryptography | passive | high |
| 10 | `10-Error-Handling-and-Information-Disclosure.md` | CH-10 | error_handling | passive | high |
| 11 | `11-File-Upload-and-Processing.md` | CH-11 | file_upload | active | high |
| 12 | `12-Server-Side-Request-Forgery-SSRF.md` | CH-12 | ssrf | active | high |
| 13 | `13-Cross-Site-Request-Forgery-CSRF.md` | CH-13 | csrf | active | high |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS.md` | CH-14 | cors | passive | high |
| 15 | `15-Race-Conditions-and-Concurrency-Issues.md` | CH-15 | race_condition | active | medium |
| 16 | `16-Third-Party-Component-Analysis.md` | CH-16 | third_party | passive | high |
| 17 | `17-Configuration-and-Misconfiguration-Hunting.md` | CH-17 | configuration | passive | high |
| 18 | `18-Network-and-Infrastructure-Security.md` | CH-18 | network | active | medium |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities.md` | CH-19 | mobile_api | active | medium |
| 20 | `20-Reporting-and-Proof-of-Concept-Development.md` | CH-20 | reporting | manual | high |
| 21 | `21-Web-Application-Firewall-WAF-Bypass.md` | CH-21 | waf_bypass | active | medium |
| 22 | `22-HTTP-Request-Smuggling.md` | CH-22 | http_smuggling | active | high |
| 23 | `23-Subdomain-Takeover.md` | CH-23 | subdomain_takeover | passive | high |
| 24 | `24-Host-Header-Injection.md` | CH-24 | host_header | active | high |
| 25 | `25-XML-External-Entity-XXE-Injection.md` | CH-25 | xxe | active | high |
| 26 | `26-Insecure-Deserialization.md` | CH-26 | deserialization | active | high |
| 27 | `27-Command-Injection.md` | CH-27 | command_injection | active | high |
| 28 | `28-NoSQL-Injection.md` | CH-28 | nosql | active | high |
| 29 | `29-GraphQL-Vulnerabilities.md` | CH-29 | graphql | active | high |
| 30 | `30-WebSocket-Security.md` | CH-30 | websocket | active | medium |
| 31 | `31-Server-Side-Template-Injection.md` | CH-31 | ssti | active | high |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | CH-32 | jwt | active | high |
| 33 | `33-Content-Security-Policy-CSP-Bypass.md` | CH-33 | csp_bypass | passive | high |
| 34 | `34-Clickjacking-and-UI-Redressing.md` | CH-34 | clickjacking | passive | high |
| 35 | `35-HTTP-Parameter-Pollution.md` | CH-35 | parameter_pollution | active | high |
| 36 | `36-LDAP-Injection.md` | CH-36 | ldap | active | high |
| 37 | `37-Session-Puzzling-and-Fixation.md` | CH-37 | session_puzzling | active | medium |
| 38 | `38-Insecure-File-Handling.md` | CH-38 | file_handling | active | high |
| 39 | `39-Cross-Site-Script-Inclusion-XSSI.md` | CH-39 | xssi | passive | high |
| 40 | `40-Prototype-Pollution.md` | CH-40 | prototype_pollution | active | high |
| 41 | `41-HTTP-Response-Splitting.md` | CH-41 | response_splitting | active | high |
| 42 | `42-XPath-Injection.md` | CH-42 | xpath | active | high |
| 43 | `43-Cross-Site-Request-Forgery-CSRF.md` | CH-43 | csrf | active | high |
| 44 | `44-Cross-Origin-Resource-Sharing-CORS.md` | CH-44 | cors | passive | high |
| 45 | `45-Race-Conditions-and-Concurrency-Issues.md` | CH-45 | race_condition | active | medium |
| 46 | `46-Third-Party-Component-Analysis.md` | CH-46 | third_party | passive | high |
| 47 | `47-Configuration-and-Misconfiguration-Hunting.md` | CH-47 | configuration | passive | high |
| 48 | `48-Network-and-Infrastructure-Security.md` | CH-48 | network | active | medium |
| 49 | `49-Mobile-and-API-Specific-Vulnerabilities.md` | CH-49 | mobile_api | active | medium |
| 50 | `50-Reporting-and-Proof-of-Concept-Development.md` | CH-50 | reporting | manual | high |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and hunting methodology |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

- **advanced-automation.md** — Automation modules use hunting prompts as input.
- **core-prompts-learning.md** — Learning modules teach the methodologies referenced here.
- **real-world-case-studies.md** — Case studies validate hunting findings.
- **report-writing-mastery.md** — Findings feed into report generation.

---

## Usage Examples

### Example 1: Find All XSS Modules

```python
results = find_all_xss(index)
# Returns: CH-02, CH-06, CH-21, CH-33, CH-39, CH-40
```

### Example 2: Find Findings on /api/ Endpoint

```python
results = find_findings_on_endpoint(index, '/api/')
```

### Example 3: Get SSRF Aggregation

```python
agg = get_aggregation(index, 'ssrf')
# Returns: module count, total payloads, severity distribution
```

### Example 4: Rank by Severity

```python
ranker = FindingRanker(index)
ranked = ranker.rank_findings(vuln_class='xss', prioritize_severity=True)
```
