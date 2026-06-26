# Real-World Case Studies — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `real-world-case-studies` |
| Root Path | `Real-World-Case-Studies/` |
| File Count | 50 primary files + README + registry.json |
| Index Type | Report-centric (vuln_class, platform, bounty) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Real-World Case Studies domain index manages metadata for 50 disclosed bug bounty report modules. Each file documents a real disclosed vulnerability report with details on the vulnerability class, platform, bounty amount, and impact. The index organizes reports by vulnerability class, platform, bounty range, and disclosure status.

This index supports two primary query patterns:
1. **Find IDOR reports** (or any vuln class) — given a vulnerability class, retrieve all disclosed reports for that class.
2. **Find reports above $5000** — given a bounty threshold, retrieve all reports with payouts exceeding that amount.

---

## Index Schema

### Primary Index: `report_records`

```json
{
  "doc_type": "report_record",
  "file_ref": "Real-World-Case-Studies/<filename>.md",
  "report_id": "RW-<number>",
  "report_title": "<title>",
  "vuln_class": "enum[idor|xss|sqli|ssrf|csrf|cmd_injection|deserialization|file_upload|xxe|ssti|jwt|auth_bypass|privilege_escalation|business_logic|info_disclosure|heap_overflow|java_deserialization|php_unserialize|python_pickle|race_condition|host_header|dns_rebinding|websocket|graphql|csp_bypass|clickjacking|response_splitting|ldap|xpath|nosql|prototype_pollution|subdomain_takeover|open_redirect|content_spoofing|webcache_poisoning|http_smuggling|websocket_hijacking|cors|token_leakage|sensitive_data|weak_encryption|crypto_storage|path_traversal|lfi|rfi|ssrf_dup|csrf_forgery|mobile_api|cloud_aws|api_auth_bypass]",
  "platform": "enum[web|api|mobile|cloud|enterprise|custom]",
  "bounty_usd": "integer",
  "severity": "enum[critical|high|medium|low|info]",
  "disclosure_status": "enum[disclosed|partially_disclosed|private|anonymous]",
  "program": "string",
  "impact_description": "string",
  "remediation": "string",
  "cve": "string",
  "tags": ["string"],
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `vuln_class_index`

```json
{
  "vuln_class": "string",
  "reports": ["RW-<number>"],
  "avg_bounty": "float",
  "total_bounty": "integer",
  "severity_distribution": {
    "critical": "integer",
    "high": "integer",
    "medium": "integer",
    "low": "integer"
  }
}
```

### Tertiary Index: `bounty_index`

```json
{
  "bounty_bucket": "enum[0-100|100-500|500-1000|1000-5000|5000-10000|10000+]",
  "reports": ["RW-<number>"],
  "avg_severity": "float"
}
```

---

## Index Creation

```python
import re
from pathlib import Path
from datetime import datetime

def extract_report_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    report_num = int(match.group(1)) if match else 0
    report_slug = match.group(2) if match else filename
    
    vuln_class = classify_report_vuln(report_slug)
    platform = detect_platform(content)
    bounty = extract_bounty(content)
    severity = detect_severity(content)
    disclosure = detect_disclosure(content)
    program = extract_program(content)
    impact = extract_impact(content)
    remediation = extract_remediation(content)
    cve = extract_cve(content)
    
    return {
        "doc_type": "report_record",
        "file_ref": f"Real-World-Case-Studies/{filepath.name}",
        "report_id": f"RW-{report_num:02d}",
        "report_title": format_title(report_slug),
        "vuln_class": vuln_class,
        "platform": platform,
        "bounty_usd": bounty,
        "severity": severity,
        "disclosure_status": disclosure,
        "program": program,
        "impact_description": impact,
        "remediation": remediation,
        "cve": cve,
        "tags": extract_tags(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_report_vuln(slug: str) -> str:
    mapping = {
        'idor': 'idor', 'account-takeover': 'idor',
        'xss-stored': 'xss', 'xss-persistent': 'xss',
        'sql-injection': 'sqli', 'data-breach': 'sqli',
        'ssrf-internal': 'ssrf', 'internal-network': 'ssrf',
        'csrf-state': 'csrf', 'state-changing': 'csrf',
        'command-injection': 'cmd_injection', 'rce': 'cmd_injection',
        'deserialization-remote': 'deserialization',
        'file-upload': 'file_upload', 'arbitrary-upload': 'file_upload',
        'xxe-xml': 'xxe', 'xml-external': 'xxe',
        'ssti-server': 'ssti', 'template-injection': 'ssti',
        'jwt-token': 'jwt', 'token-manipulation': 'jwt',
        'authentication-bypass': 'auth_bypass',
        'privilege-escalation': 'privilege_escalation',
        'business-logic': 'business_logic',
        'information-disclosure': 'info_disclosure',
        'heap-overflow': 'heap_overflow', 'memory-corruption': 'heap_overflow',
        'java-deserialization': 'java_deserialization',
        'php-unserialize': 'php_unserialize',
        'python-pickle': 'python_pickle',
        'race-condition': 'race_condition', 'time-of-check': 'race_condition',
        'host-header': 'host_header',
        'dns-rebinding': 'dns_rebinding',
        'websocket-security': 'websocket',
        'graphql-introspection': 'graphql',
        'csp-bypass': 'csp_bypass',
        'clickjacking': 'clickjacking', 'ui-redressing': 'clickjacking',
        'response-splitting': 'response_splitting',
        'ldap-injection': 'ldap',
        'xpath-injection': 'xpath',
        'nosql-injection': 'nosql', 'mongodb': 'nosql',
        'prototype-pollution': 'prototype_pollution',
        'subdomain-takeover': 'subdomain_takeover',
        'open-redirect': 'open_redirect', 'phishing': 'open_redirect',
        'content-spoofing': 'content_spoofing',
        'webcache-poisoning': 'webcache_poisoning',
        'http-request-smuggling': 'http_smuggling',
        'websocket-hijacking': 'websocket_hijacking',
        'cors-misconfiguration': 'cors',
        'token-leakage': 'token_leakage', 'url-parameters': 'token_leakage',
        'sensitive-data': 'sensitive_data', 'exposure': 'sensitive_data',
        'weak-encryption': 'weak_encryption',
        'insecure-cryptographic': 'crypto_storage',
        'path-traversal': 'path_traversal', 'file-inclusion': 'path_traversal',
        'local-file-inclusion': 'lfi', 'lfi': 'lfi',
        'remote-file-inclusion': 'rfi', 'rfi': 'rfi',
        'server-side-request-forgery': 'ssrf_dup',
        'client-side-request-forgery': 'csrf_forgery',
        'mobile-api': 'mobile_api',
        'cloud-misconfiguration': 'cloud_aws', 'aws': 'cloud_aws',
        'api-authentication': 'api_auth_bypass',
    }
    slug_lower = slug.lower()
    for key, val in mapping.items():
        if key in slug_lower:
            return val
    return 'idor'

def detect_platform(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['mobile', 'android', 'ios']):
        return 'mobile'
    if any(kw in text for kw in ['cloud', 'aws', 'azure', 'gcp']):
        return 'cloud'
    if any(kw in text for kw in ['enterprise', 'internal', 'active directory']):
        return 'enterprise'
    if 'api' in text:
        return 'api'
    return 'web'

def extract_bounty(content: str) -> int:
    text = content.lower()
    bounty_match = re.search(r'\$(\d+(?:,\d{3})*(?:\.\d{2})?)\s*(?:bounty|reward|paid|payout)', text)
    if bounty_match:
        return int(bounty_match.group(1).replace(',', ''))
    
    bounty_match2 = re.search(r'bounty.*?\$(\d+(?:,\d{3})*)', text)
    if bounty_match2:
        return int(bounty_match2.group(1).replace(',', ''))
    
    bounty_match3 = re.search(r'\$(\d+(?:,\d{3})*)', text)
    if bounty_match3:
        return int(bounty_match3.group(1).replace(',', ''))
    
    return 0

def detect_severity(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['critical', 'cvss.*?9', 'cvss.*?10']):
        return 'critical'
    if any(kw in text for kw in ['high', 'cvss.*?7', 'cvss.*?8']):
        return 'high'
    if any(kw in text for kw in ['medium', 'moderate', 'cvss.*?4', 'cvss.*?5', 'cvss.*?6']):
        return 'medium'
    if any(kw in text for kw in ['low', 'minor', 'informational']):
        return 'low'
    return 'info'

def detect_disclosure(content: str) -> str:
    text = content.lower()
    if 'disclosed' in text or 'public disclosure' in text:
        return 'disclosed'
    if 'partial' in text:
        return 'partially_disclosed'
    if 'private' in text:
        return 'private'
    return 'anonymous'

def extract_program(content: str) -> str:
    match = re.search(r'program[:\s]+(.+?)(?:\n|$)', content.lower())
    return match.group(1).strip() if match else 'unknown'

def extract_impact(content: str) -> str:
    match = re.search(r'impact[:\s]+(.+?)(?:\n|$)', content.lower())
    return match.group(1).strip() if match else 'unknown'

def extract_remediation(content: str) -> str:
    match = re.search(r'remediation[:\s]+(.+?)(?:\n|$)', content.lower())
    return match.group(1).strip() if match else 'unknown'

def extract_cve(content: str) -> str:
    match = re.search(r'(CVE-\d{4}-\d{4,})', content)
    return match.group(1) if match else ''

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'owasp', 'top10', 'critical', 'high-impact', 'bounty',
        'disclosed', 'real-world', 'production', 'confirmed'
    ]
    text = content.lower()
    for tag in tag_keywords:
        if tag in text:
            tags.append(tag)
    return tags

def format_title(slug: str) -> str:
    return slug.replace('-', ' ').title()

def extract_date(content: str) -> str:
    match = re.search(r'(\d{4}-\d{2}-\d{2})', content)
    return match.group(1) if match else datetime.now().isoformat()
```

### Build Report Index

```python
class ReportIndex:
    def __init__(self):
        self.primary = {}
        self.by_vuln_class = {}
        self.by_platform = {}
        self.by_severity = {}
        self.by_bounty_bucket = {}
        self.by_disclosure = {}
    
    def add(self, doc: dict):
        rid = doc['report_id']
        self.primary[rid] = doc
        
        self.by_vuln_class.setdefault(doc['vuln_class'], []).append(rid)
        self.by_platform.setdefault(doc['platform'], []).append(rid)
        self.by_severity.setdefault(doc['severity'], []).append(rid)
        self.by_disclosure.setdefault(doc['disclosure_status'], []).append(rid)
        
        bucket = get_bounty_bucket(doc['bounty_usd'])
        self.by_bounty_bucket.setdefault(bucket, []).append(rid)
    
    def find_by_vuln_class(self, vuln_class: str) -> list:
        rids = self.by_vuln_class.get(vuln_class, [])
        return [self.primary[rid] for rid in rids]
    
    def find_above_bounty(self, min_bounty: int) -> list:
        results = []
        for rid, doc in self.primary.items():
            if doc['bounty_usd'] >= min_bounty:
                results.append(doc)
        results.sort(key=lambda x: x['bounty_usd'], reverse=True)
        return results
    
    def find_by_platform(self, platform: str) -> list:
        rids = self.by_platform.get(platform, [])
        return [self.primary[rid] for rid in rids]
    
    def find_critical_reports(self) -> list:
        rids = self.by_severity.get('critical', [])
        return [self.primary[rid] for rid in rids]
    
    def get_vuln_class_stats(self) -> dict:
        stats = {}
        for vc, rids in self.by_vuln_class.items():
            bounties = [self.primary[rid]['bounty_usd'] for rid in rids]
            stats[vc] = {
                "count": len(rids),
                "avg_bounty": sum(bounties) / max(len(bounties), 1),
                "total_bounty": sum(bounties),
                "max_bounty": max(bounties) if bounties else 0
            }
        return stats

def get_bounty_bucket(bounty: int) -> str:
    if bounty < 100:
        return '0-100'
    elif bounty < 500:
        return '100-500'
    elif bounty < 1000:
        return '500-1000'
    elif bounty < 5000:
        return '1000-5000'
    elif bounty < 10000:
        return '5000-10000'
    else:
        return '10000+'
```

### Persist Index

```python
import json
from datetime import datetime

def persist_report_index(index: ReportIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "real-world-case-studies",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_vuln_class": index.by_vuln_class,
            "by_platform": index.by_platform,
            "by_severity": index.by_severity,
            "by_bounty_bucket": index.by_bounty_bucket,
            "by_disclosure": index.by_disclosure,
        },
        "stats": index.get_vuln_class_stats()
    }
    
    index_file = output_dir / "reports-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find IDOR Reports

```python
def find_idor_reports(index: ReportIndex) -> list:
    return index.find_by_vuln_class('idor')
```

### Query 2: Find Reports Above $5000

```python
def find_reports_above_bounty(index: ReportIndex, min_bounty: int = 5000) -> list:
    return index.find_above_bounty(min_bounty)
```

### Query 3: Find by Vuln Class

```python
def find_by_vuln_class(index: ReportIndex, vuln_class: str) -> list:
    return index.find_by_vuln_class(vuln_class)
```

### Query 4: Find Critical Reports

```python
def find_critical_reports(index: ReportIndex) -> list:
    return index.find_critical_reports()
```

### Query 5: Find by Platform

```python
def find_by_platform(index: ReportIndex, platform: str) -> list:
    return index.find_by_platform(platform)
```

### Query 6: Get Vuln Class Stats

```python
def get_vuln_class_stats(index: ReportIndex) -> dict:
    return index.get_vuln_class_stats()
```

---

## Search Algorithms

### Bounty-Weighted Search

```python
class BountySearch:
    def __init__(self, index: ReportIndex):
        self.index = index
    
    def search(self, query: str, prioritize_bounty: bool = True) -> list:
        import re
        query_tokens = re.findall(r'[a-z0-9]+', query.lower())
        
        results = []
        for rid, doc in self.index.primary.items():
            text = f"{doc['report_title']} {doc['vuln_class']} {doc['program']} {' '.join(doc.get('tags', []))}".lower()
            
            match_score = sum(1 for qt in query_tokens if qt in text) / max(len(query_tokens), 1)
            
            if match_score > 0:
                bounty_norm = min(doc['bounty_usd'] / 10000.0, 1.0)
                
                if prioritize_bounty:
                    score = match_score * 0.5 + bounty_norm * 0.5
                else:
                    score = match_score * 0.8 + bounty_norm * 0.2
                
                doc_copy = doc.copy()
                doc_copy['search_score'] = round(score, 4)
                results.append(doc_copy)
        
        results.sort(key=lambda x: x['search_score'], reverse=True)
        return results
```

### BM25 Search

```python
import math

class ReportBM25:
    def __init__(self, index: ReportIndex):
        self.index = index
    
    def _tokenize(self, text: str) -> list:
        import re
        tokens = re.findall(r'[a-z0-9]+', text.lower())
        stopwords = {'the', 'a', 'an', 'is', 'are', 'in', 'on', 'for', 'of', 'and', 'or', 'to'}
        return [t for t in tokens if t not in stopwords]
    
    def search(self, query: str) -> list:
        query_tokens = self._tokenize(query)
        scores = []
        
        for rid, doc in self.index.primary.items():
            text = f"{doc['report_title']} {doc['vuln_class']} {doc['program']} {doc['impact_description']}"
            doc_tokens = self._tokenize(text)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                if tf > 0:
                    df = sum(1 for d in self.index.primary.values() 
                             if qt in f"{d['report_title']} {d['vuln_class']}".lower())
                    idf = math.log((len(self.index.primary) - df + 0.5) / (df + 0.5) + 1)
                    score += idf * tf
            
            if score > 0:
                scores.append((rid, score))
        
        scores.sort(key=lambda x: x[1], reverse=True)
        return [(rid, s, self.index.primary[rid]) for rid, s in scores]
```

---

## Relevance Scoring

```python
def compute_report_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'vuln_class' in query and doc['vuln_class'] == query['vuln_class']:
        score += 0.30
    if 'platform' in query and doc['platform'] == query['platform']:
        score += 0.20
    if 'min_bounty' in query and doc['bounty_usd'] >= query['min_bounty']:
        score += 0.25
    if 'severity' in query:
        sev_order = ['info', 'low', 'medium', 'high', 'critical']
        if sev_order.index(doc['severity']) >= sev_order.index(query['severity']):
            score += 0.15
    
    bounty_norm = min(doc['bounty_usd'] / 10000.0, 1.0)
    score += bounty_norm * 0.10
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_report_index(index: ReportIndex, new_file: Path):
    doc = extract_report_metadata(new_file)
    index.add(doc)

def remove_report(index: ReportIndex, report_id: str):
    if report_id not in index.primary:
        return
    doc = index.primary[report_id]
    
    for idx_map in [index.by_vuln_class, index.by_platform, index.by_severity,
                    index.by_bounty_bucket, index.by_disclosure]:
        for key, rids in idx_map.items():
            if report_id in rids:
                rids.remove(report_id)
    
    del index.primary[report_id]

def verify_report_index(index: ReportIndex) -> dict:
    issues = []
    for rid, doc in index.primary.items():
        if doc['bounty_usd'] < 0:
            issues.append(f"Report {rid} has negative bounty")
        if not doc.get('vuln_class'):
            issues.append(f"Report {rid} has no vuln class")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Report ID | Vuln Class | Platform | Bounty |
|---|------|-----------|------------|----------|--------|
| 01 | `01-IDOR-Account-Takeover-Case-Studies.md` | RW-01 | idor | web | 2500 |
| 02 | `02-XSS-Stored-Persistent-Attacks.md` | RW-02 | xss | web | 1500 |
| 03 | `03-SQL-Injection-Data-Breaches.md` | RW-03 | sqli | web | 5000 |
| 04 | `04-SSRF-Internal-Network-Access.md` | RW-04 | ssrf | web | 3000 |
| 05 | `05-CSRF-State-Changing-Attacks.md` | RW-05 | csrf | web | 1000 |
| 06 | `06-Command-Injection-RCE.md` | RW-06 | cmd_injection | web | 10000 |
| 07 | `07-Deserialization-Remote-Code-Execution.md` | RW-07 | deserialization | web | 8000 |
| 08 | `08-File-Upload-Arbitrary-Upload.md` | RW-08 | file_upload | web | 2000 |
| 09 | `09-XXE-XML-External-Entity-Attacks.md` | RW-09 | xxe | web | 3000 |
| 10 | `10-SSTI-Server-Side-Template-Injection.md` | RW-10 | ssti | web | 5000 |
| 11 | `11-JWT-Token-Manipulation.md` | RW-11 | jwt | api | 2500 |
| 12 | `12-Authentication-Bypass.md` | RW-12 | auth_bypass | web | 5000 |
| 13 | `13-Privilege-Escalation.md` | RW-13 | privilege_escalation | web | 5000 |
| 14 | `14-Business-Logic-Flaws.md` | RW-14 | business_logic | web | 3000 |
| 15 | `15-Information-Disclosure.md` | RW-15 | info_disclosure | web | 500 |
| 16 | `16-Memory-Corruption-Heap-Overflow.md` | RW-16 | heap_overflow | web | 15000 |
| 17 | `17-Deserialization-Java-Deserialization.md` | RW-17 | java_deserialization | web | 10000 |
| 18 | `18-Deserialization-PHP-Unserialize.md` | RW-18 | php_unserialize | web | 8000 |
| 19 | `19-Deserialization-Python-Pickle.md` | RW-19 | python_pickle | web | 5000 |
| 20 | `20-Race-Condition-Time-of-Check.md` | RW-20 | race_condition | web | 3000 |
| 21 | `21-Host-Header-Injection.md` | RW-21 | host_header | web | 1500 |
| 22 | `22-DNS-Rebinding-Attacks.md` | RW-22 | dns_rebinding | web | 3000 |
| 23 | `23-WebSocket-Security-Issues.md` | RW-23 | websocket | web | 2000 |
| 24 | `24-GraphQL-Introspection-Attacks.md` | RW-24 | graphql | api | 2000 |
| 25 | `25-CSP-Bypass-Techniques.md` | RW-25 | csp_bypass | web | 1500 |
| 26 | `26-Clickjacking-UI-Redressing.md` | RW-26 | clickjacking | web | 500 |
| 27 | `27-HTTP-Response-Splitting.md` | RW-27 | response_splitting | web | 1000 |
| 28 | `28-LDAP-Injection-Attacks.md` | RW-28 | ldap | enterprise | 5000 |
| 29 | `29-XPath-Injection-Attacks.md` | RW-29 | xpath | web | 2000 |
| 30 | `30-NoSQL-Injection-MongoDB.md` | RW-30 | nosql | web | 3000 |
| 31 | `31-Prototype-Pollution-JavaScript.md` | RW-31 | prototype_pollution | web | 2000 |
| 32 | `32-Subdomain-Takeover.md` | RW-32 | subdomain_takeover | web | 1500 |
| 33 | `33-Open-Redirect-Phishing.md` | RW-33 | open_redirect | web | 1000 |
| 34 | `34-Content-Spoofing-Attacks.md` | RW-34 | content_spoofing | web | 500 |
| 35 | `35-WebCache-Poisoning.md` | RW-35 | webcache_poisoning | web | 2000 |
| 36 | `36-HTTP-Request-Smuggling.md` | RW-36 | http_smuggling | web | 5000 |
| 37 | `37-WebSocket-Hijacking.md` | RW-37 | websocket_hijacking | web | 2000 |
| 38 | `38-CORS-Misconfiguration.md` | RW-38 | cors | web | 1500 |
| 39 | `39-Token-Leakage-URL-Parameters.md` | RW-39 | token_leakage | web | 1000 |
| 40 | `40-Sensitive-Data-Exposure.md` | RW-40 | sensitive_data | web | 3000 |
| 41 | `41-Weak-Encryption-Algorithms.md` | RW-41 | weak_encryption | web | 2000 |
| 42 | `42-Insecure-Cryptographic-Storage.md` | RW-42 | crypto_storage | web | 3000 |
| 43 | `43-Path-Traversal-File-Inclusion.md` | RW-43 | path_traversal | web | 2000 |
| 44 | `44-Local-File-Inclusion-LFI.md` | RW-44 | lfi | web | 2000 |
| 45 | `45-Remote-File-Inclusion-RFI.md` | RW-45 | rfi | web | 3000 |
| 46 | `46-Server-Side-Request-Forgery.md` | RW-46 | ssrf_dup | web | 3000 |
| 47 | `47-Client-Side-Request-Forgery.md` | RW-47 | csrf_forgery | web | 1500 |
| 48 | `48-Mobile-API-Security-Issues.md` | RW-48 | mobile_api | mobile | 2500 |
| 49 | `49-Cloud-Misconfiguration-AWS.md` | RW-49 | cloud_aws | cloud | 10000 |
| 50 | `50-API-Authentication-Bypass.md` | RW-50 | api_auth_bypass | api | 5000 |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and case study methodology |
| `registry.json` | Machine-readable report registry |

---

## Cross-Domain References

- **high-level-world-case-studies.md** — High-level cases reference these detailed reports.
- **core-prompts-hunting.md** — Hunting prompts generate findings that become reports.
- **report-writing-mastery.md** — Report templates are validated against these disclosed reports.
- **bug-bounty-program-strategy.md** — Strategy modules reference bounty outcomes.

---

## Usage Examples

### Example 1: Find IDOR Reports

```python
results = find_idor_reports(index)
# Returns: RW-01
```

### Example 2: Find Reports Above $5000

```python
results = find_reports_above_bounty(index, 5000)
# Returns: RW-03, RW-06, RW-07, RW-10, RW-12, RW-13, RW-16, RW-17, RW-18, RW-28, RW-36, RW-49, RW-50
```

### Example 3: Find XSS Reports

```python
results = find_by_vuln_class(index, 'xss')
# Returns: RW-02
```

### Example 4: Get Vuln Class Statistics

```python
stats = get_vuln_class_stats(index)
# Returns: {idor: {count: 1, avg_bounty: 2500, ...}, ...}
```
