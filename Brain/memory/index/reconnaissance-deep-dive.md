# Reconnaissance Deep Dive — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `reconnaissance-deep-dive` |
| Root Path | `Reconnaissance-Deep-Dive/` |
| File Count | 50 primary files + README + registry.json |
| Index Type | Asset-centric (type, status, technology) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Reconnaissance Deep Dive domain index manages metadata for 50 reconnaissance modules covering subdomain enumeration, OSINT, technology fingerprinting, cloud resource discovery, API endpoint discovery, and advanced reconnaissance techniques. The index organizes assets by type, status, technology, and discovery method.

This index supports two primary query patterns:
1. **Find live hosts** — given a target domain, retrieve all modules that discover live assets.
2. **Find assets using WordPress** (or any technology) — given a technology stack, retrieve all modules that detect or interact with that technology.

---

## Index Schema

### Primary Index: `recon_records`

```json
{
  "doc_type": "recon_record",
  "file_ref": "Reconnaissance-Deep-Dive/<filename>.md",
  "module_id": "RD-<number>",
  "module_title": "<title>",
  "asset_types": ["enum[subdomain|ip|url|api_endpoint|email|phone|certificate|dns_record|git_repo|container_registry|iot_device|mobile_app|websocket|graphql|xml_rpc|soap|backup_file|source_code|config_file|debug_endpoint|staging_environment|social_media|employee_asset|third_party_integration|web_archive|pastebin|code_repository|competitor|partner|subsidiary|regional_infrastructure|cms|framework|server_config|ssl_cert|http_header|cookie|error_page]"],
  "discovery_method": "enum[passive|active|hybrid|osint|automated|manual]",
  "technology_focus": ["string"],
  "target_status": "enum[discovered|verified|alive|dead|unknown]",
  "scope_impact": "enum[direct|indirect|third_party]",
  "tools_required": ["string"],
  "output_format": "enum[subdomains|ips|urls|emails|certificates|dns|osint_raw|structured_json]",
  "reliability": "enum[high|medium|low]",
  "automation_level": "enum[fully_automated|semi_automated|manual]",
  "tags": ["string"],
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `asset_type_index`

```json
{
  "asset_type": "string",
  "modules": ["RD-<number>"],
  "discovery_methods": ["string"],
  "avg_reliability": "float"
}
```

### Tertiary Index: `technology_index`

```json
{
  "technology": "string",
  "modules": ["RD-<number>"],
  "asset_types": ["string"]
}
```

---

## Index Creation

```python
import re
from pathlib import Path
from datetime import datetime

def extract_recon_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    module_num = int(match.group(1)) if match else 0
    module_slug = match.group(2) if match else filename
    
    asset_types = extract_asset_types(content, module_slug)
    discovery_method = detect_discovery_method(content, module_slug)
    tech_focus = extract_technology_focus(content)
    tools = extract_tools(content)
    output = detect_output_format(content)
    reliability = detect_reliability(content)
    automation = detect_automation_level(content)
    
    return {
        "doc_type": "recon_record",
        "file_ref": f"Reconnaissance-Deep-Dive/{filepath.name}",
        "module_id": f"RD-{module_num:02d}",
        "module_title": format_title(module_slug),
        "asset_types": asset_types,
        "discovery_method": discovery_method,
        "technology_focus": tech_focus,
        "target_status": "unknown",
        "scope_impact": detect_scope_impact(content),
        "tools_required": tools,
        "output_format": output,
        "reliability": reliability,
        "automation_level": automation,
        "tags": extract_tags(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def extract_asset_types(content: str, slug: str) -> list:
    text = (slug + ' ' + content).lower()
    asset_keywords = {
        'subdomain': ['subdomain', 'sub-domain', 'dns enum'],
        'ip': ['ip address', 'ip range', 'cidr', 'ip scan'],
        'url': ['url', 'endpoint', 'path'],
        'api_endpoint': ['api', 'rest', 'graphql', 'swagger'],
        'email': ['email', 'mail', 'contact'],
        'phone': ['phone', 'telephone', 'number'],
        'certificate': ['certificate', 'ssl', 'tls', 'cert'],
        'dns_record': ['dns', 'mx', 'txt', 'ns record'],
        'git_repo': ['git', 'repository', 'github', 'gitlab'],
        'container_registry': ['docker', 'container', 'registry', 'ghcr'],
        'iot_device': ['iot', 'embedded', 'device'],
        'mobile_app': ['mobile', 'android', 'ios', 'apk'],
        'websocket': ['websocket', 'ws://', 'wss://'],
        'graphql': ['graphql', 'introspection'],
        'xml_rpc': ['xml-rpc', 'xmlrpc', 'soap'],
        'backup_file': ['backup', '.bak', '.old', '.orig'],
        'source_code': ['source code', 'leak', 'code leak'],
        'config_file': ['config', 'configuration', '.env'],
        'debug_endpoint': ['debug', 'test', 'dev', 'staging'],
        'staging_environment': ['staging', 'dev environment', 'uat'],
        'social_media': ['social media', 'twitter', 'linkedin', 'facebook'],
        'employee_asset': ['employee', 'staff', 'personnel'],
        'third_party_integration': ['third party', 'integration', 'vendor'],
        'web_archive': ['web archive', 'wayback', 'archive.org'],
        'pastebin': ['pastebin', 'pastebin', 'paste site'],
        'code_repository': ['code repository', 'bitbucket', 'gitlab'],
        'competitor': ['competitor', 'rival'],
        'partner': ['partner', 'affiliate'],
        'subsidiary': ['subsidiary', 'child company'],
        'regional_infrastructure': ['regional', 'local', 'branch'],
        'cms': ['cms', 'wordpress', 'drupal', 'joomla'],
        'framework': ['framework', 'laravel', 'django', 'rails'],
        'server_config': ['server', 'apache', 'nginx', 'iis'],
        'ssl_cert': ['ssl', 'certificate', 'tls'],
        'http_header': ['header', 'http header'],
        'cookie': ['cookie', 'session'],
        'error_page': ['error page', '404', '500', 'stack trace'],
    }
    
    found = []
    for asset, keywords in asset_keywords.items():
        for kw in keywords:
            if kw in text:
                found.append(asset)
                break
    return found if found else ['subdomain']

def detect_discovery_method(content: str, slug: str) -> str:
    text = (slug + ' ' + content).lower()
    if any(kw in text for kw in ['passive', 'osint', 'no request', 'passive recon']):
        return 'passive'
    if any(kw in text for kw in ['active', 'scan', 'probe', 'active recon']):
        return 'active'
    if any(kw in text for kw in ['osint', 'open source', 'public data']):
        return 'osint'
    if any(kw in text for kw in ['automat', 'script', 'pipeline']):
        return 'automated'
    if any(kw in text for kw in ['manual', 'hand']):
        return 'manual'
    return 'hybrid'

def extract_technology_focus(content: str) -> list:
    text = content.lower()
    techs = []
    tech_keywords = [
        'wordpress', 'drupal', 'joomla', 'laravel', 'django', 'rails',
        'spring', 'angular', 'react', 'vue', 'nodejs', 'express',
        'flask', 'fastapi', 'nextjs', 'nuxtjs', 'gatsby',
        'apache', 'nginx', 'iis', 'tomcat', 'caddy',
        'mysql', 'postgresql', 'mongodb', 'redis', 'elasticsearch',
        'docker', 'kubernetes', 'aws', 'azure', 'gcp',
        'cloudflare', 'akamai', 'fastly', 's3',
        'php', 'java', 'python', 'ruby', 'go', 'rust',
        'javascript', 'typescript', 'graphql', 'rest', 'soap',
    ]
    for tech in tech_keywords:
        if tech in text:
            techs.append(tech)
    return techs[:10]

def detect_scope_impact(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['third-party', 'vendor', 'partner']):
        return 'third_party'
    if any(kw in text for kw in ['indirect', 'related', 'subsidiary']):
        return 'indirect'
    return 'direct'

def extract_tools(content: str) -> list:
    text = content.lower()
    tools = []
    tool_names = [
        'subfinder', 'amass', 'sublist3r', 'assetfinder', 'chaos',
        'httpx', 'nmap', 'masscan', 'zmap', 'nuclei',
        'ffuf', 'gobuster', 'dirsearch', 'wfuzz',
        'waybackurls', 'gau', 'katana', ' hakrawler',
        'dnsx', 'dnsrecon', 'dnsgen',
        'curl', 'python', 'ruby', 'nodejs',
        'chrome', 'firefox', 'burp', 'zap',
        'wireshark', 'mitmproxy', 'shodan', 'censys',
        'theharvester', 'recon-ng', 'spiderfoot',
        'gitrob', 'trufflehog', 'gitleaks',
    ]
    for tool in tool_names:
        if tool in text:
            tools.append(tool)
    return tools

def detect_output_format(content: str) -> str:
    text = content.lower()
    if 'subdomain' in text:
        return 'subdomains'
    if 'email' in text:
        return 'emails'
    if 'certificate' in text or 'cert' in text:
        return 'certificates'
    if 'dns' in text:
        return 'dns'
    if 'osint' in text:
        return 'osint_raw'
    return 'structured_json'

def detect_reliability(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['high reliability', 'accurate', 'reliable']):
        return 'high'
    if any(kw in text for kw in ['low reliability', 'inaccurate', 'unreliable']):
        return 'low'
    return 'medium'

def detect_automation_level(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['fully automated', 'script', 'pipeline']):
        return 'fully_automated'
    if any(kw in text for kw in ['semi-automated', 'partial']):
        return 'semi_automated'
    return 'manual'

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'passive', 'active', 'osint', 'automation', 'recon',
        'discovery', 'enumeration', 'fingerprinting', 'scanning'
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

### Build Recon Index

```python
class ReconIndex:
    def __init__(self):
        self.primary = {}
        self.by_asset_type = {}
        self.by_discovery_method = {}
        self.by_technology = {}
        self.by_reliability = {}
        self.by_automation = {}
        self.by_tool = {}
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        for at in doc['asset_types']:
            self.by_asset_type.setdefault(at, []).append(mid)
        
        self.by_discovery_method.setdefault(doc['discovery_method'], []).append(mid)
        
        for tech in doc['technology_focus']:
            self.by_technology.setdefault(tech, []).append(mid)
        
        self.by_reliability.setdefault(doc['reliability'], []).append(mid)
        self.by_automation.setdefault(doc['automation_level'], []).append(mid)
        
        for tool in doc['tools_required']:
            self.by_tool.setdefault(tool, []).append(mid)
    
    def find_live_hosts_modules(self) -> list:
        """Find modules that discover live assets."""
        results = []
        for mid, doc in self.primary.items():
            if 'subdomain' in doc['asset_types'] or 'ip' in doc['asset_types']:
                if doc['discovery_method'] in ['active', 'hybrid']:
                    results.append(doc)
        return results
    
    def find_assets_by_technology(self, technology: str) -> list:
        mids = self.by_technology.get(technology, [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_asset_type(self, asset_type: str) -> list:
        mids = self.by_asset_type.get(asset_type, [])
        return [self.primary[mid] for mid in mids]
    
    def find_passive_modules(self) -> list:
        mids = self.by_discovery_method.get('passive', [])
        return [self.primary[mid] for mid in mids]
    
    def find_high_reliability(self) -> list:
        mids = self.by_reliability.get('high', [])
        return [self.primary[mid] for mid in mids]
    
    def find_automatable(self) -> list:
        mids = self.by_automation.get('fully_automated', [])
        return [self.primary[mid] for mid in mids]
```

### Persist Index

```python
import json
from datetime import datetime

def persist_recon_index(index: ReconIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "reconnaissance-deep-dive",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_asset_type": index.by_asset_type,
            "by_discovery_method": index.by_discovery_method,
            "by_technology": index.by_technology,
            "by_reliability": index.by_reliability,
            "by_automation": index.by_automation,
            "by_tool": index.by_tool,
        }
    }
    
    index_file = output_dir / "recon-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Live Hosts Modules

```python
def find_live_hosts_modules(index: ReconIndex) -> list:
    return index.find_live_hosts_modules()
```

### Query 2: Find Assets Using WordPress

```python
def find_assets_by_technology(index: ReconIndex, technology: str) -> list:
    return index.find_assets_by_technology(technology)
```

### Query 3: Find by Asset Type

```python
def find_by_asset_type(index: ReconIndex, asset_type: str) -> list:
    return index.find_by_asset_type(asset_type)
```

### Query 4: Find Passive Modules

```python
def find_passive_modules(index: ReconIndex) -> list:
    return index.find_passive_modules()
```

### Query 5: Find High Reliability

```python
def find_high_reliability(index: ReconIndex) -> list:
    return index.find_high_reliability()
```

### Query 6: Find Automatable

```python
def find_automatable(index: ReconIndex) -> list:
    return index.find_automatable()
```

---

## Search Algorithms

### Recon Module Scoring

```python
class ReconScorer:
    def __init__(self, index: ReconIndex):
        self.index = index
    
    def score_module(self, doc: dict, query: dict) -> float:
        score = 0.0
        
        if 'asset_type' in query and query['asset_type'] in doc['asset_types']:
            score += 0.30
        if 'technology' in query and query['technology'] in doc['technology_focus']:
            score += 0.25
        if 'discovery_method' in query and doc['discovery_method'] == query['discovery_method']:
            score += 0.20
        
        rel_map = {'high': 0.15, 'medium': 0.10, 'low': 0.05}
        score += rel_map.get(doc['reliability'], 0.10)
        
        auto_map = {'fully_automated': 0.10, 'semi_automated': 0.05, 'manual': 0.0}
        score += auto_map.get(doc['automation_level'], 0.0)
        
        return min(score, 1.0)
    
    def rank_modules(self, query: dict) -> list:
        results = []
        for mid, doc in self.index.primary.items():
            score = self.score_module(doc, query)
            doc_copy = doc.copy()
            doc_copy['relevance_score'] = score
            results.append(doc_copy)
        results.sort(key=lambda x: x['relevance_score'], reverse=True)
        return results
```

### BM25 Search

```python
import math

class ReconBM25:
    def __init__(self, index: ReconIndex):
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
            text = f"{doc['module_title']} {' '.join(doc['asset_types'])} {' '.join(doc['technology_focus'])} {' '.join(doc.get('tags', []))}"
            doc_tokens = self._tokenize(text)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                if tf > 0:
                    df = sum(1 for d in self.index.primary.values() 
                             if qt in f"{d['module_title']} {' '.join(d['asset_types'])}".lower())
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
def compute_recon_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'asset_type' in query and query['asset_type'] in doc['asset_types']:
        score += 0.30
    if 'technology' in query and query['technology'] in doc['technology_focus']:
        score += 0.25
    if 'discovery_method' in query and doc['discovery_method'] == query['discovery_method']:
        score += 0.20
    
    rel_map = {'high': 0.15, 'medium': 0.10, 'low': 0.05}
    score += rel_map.get(doc['reliability'], 0.10)
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_recon_index(index: ReconIndex, new_file: Path):
    doc = extract_recon_metadata(new_file)
    index.add(doc)

def remove_module(index: ReconIndex, module_id: str):
    if module_id not in index.primary:
        return
    doc = index.primary[module_id]
    
    for idx_map in [index.by_asset_type, index.by_discovery_method, index.by_technology,
                    index.by_reliability, index.by_automation]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
    
    for tool in doc['tools_required']:
        if tool in index.by_tool and module_id in index.by_tool[tool]:
            index.by_tool[tool].remove(module_id)
    
    del index.primary[module_id]

def verify_recon_index(index: ReconIndex) -> dict:
    issues = []
    for mid, doc in index.primary.items():
        if not doc.get('asset_types'):
            issues.append(f"Module {mid} has no asset types")
        if not doc.get('discovery_method'):
            issues.append(f"Module {mid} has no discovery method")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Module ID | Asset Types | Discovery | Technology |
|---|------|-----------|-------------|-----------|------------|
| 01 | `01-Advanced-Subdomain-Enumeration.md` | RD-01 | subdomain | hybrid | subfinder,amass |
| 02 | `02-Passive-OSINT-Collection.md` | RD-02 | email,social_media | passive | theharvester |
| 03 | `03-Active-Asset-Discovery.md` | RD-03 | subdomain,ip,url | active | nmap,masscan |
| 04 | `04-Technology-Stack-Fingerprinting.md` | RD-04 | cms,framework,server_config | passive | wappalyzer |
| 05 | `05-Cloud-Resource-Enumeration.md` | RD-05 | cloud | passive | s3scanner |
| 06 | `06-API-Endpoint-Discovery.md` | RD-06 | api_endpoint,graphql | active | ffuf,katana |
| 07 | `07-JavaScript-Source-Analysis.md` | RD-07 | source_code,config_file | passive | linkfinder |
| 08 | `08-Configuration-File-Extraction.md` | RD-08 | config_file | active | ffuf |
| 09 | `09-Version-Detection-Techniques.md` | RD-09 | cms,framework | passive | whatweb |
| 10 | `10-Content-Discovery-Automation.md` | RD-10 | url | active | ffuf,gobuster |
| 11 | `11-Directory-Brute-Forcing.md` | RD-11 | url | active | ffuf,gobuster |
| 12 | `12-File-Type-Detection.md` | RD-12 | backup_file,config_file | active | ffuf |
| 13 | `13-Backup-File-Discovery.md` | RD-13 | backup_file | active | ffuf |
| 14 | `14-Source-Code-Leak-Detection.md` | RD-14 | source_code,git_repo | passive | gitrob |
| 15 | `15-Git-Repository-Analysis.md` | RD-15 | git_repo | passive | gitrob,trufflehog |
| 16 | `16-DNS-Enumeration-Advanced.md` | RD-16 | dns_record,subdomain | active | dnsrecon,dnsx |
| 17 | `17-Certificate-Transparency-Logs.md` | RD-17 | certificate | passive | crt.sh |
| 18 | `18-Historical-Data-Analysis.md` | RD-18 | url,subdomain | passive | waybackurls |
| 19 | `19-Social-Media-OSINT.md` | RD-19 | social_media,employee_asset | osint | recon-ng |
| 20 | `20-Employee-Linked-Assets.md` | RD-20 | employee_asset | osint | theharvester |
| 21 | `21-Third-Party-Integration-Discovery.md` | RD-21 | third_party_integration | passive | wappalyzer |
| 22 | `22-Web-Archive-Analysis.md` | RD-22 | web_archive,url | passive | waybackurls |
| 23 | `23-Pastebin-and-Leak-Searching.md` | RD-23 | pastebin | osint | custom |
| 24 | `24-Code-Repository-Mining.md` | RD-24 | code_repository,git_repo | passive | trufflehog |
| 25 | `25-Container-Registry-Enumeration.md` | RD-25 | container_registry | passive | custom |
| 26 | `26-IoT-Device-Discovery.md` | RD-26 | iot_device | active | shodan |
| 27 | `27-Mobile-App-Analysis.md` | RD-27 | mobile_app | manual | jadx |
| 28 | `28-API-Documentation-Extraction.md` | RD-28 | api_endpoint | passive | swagger |
| 29 | `29-WebSocket-Endpoint-Discovery.md` | RD-29 | websocket | active | custom |
| 30 | `30-GraphQL-Introspection.md` | RD-30 | graphql | active | introspection |
| 31 | `31-XML-RPC-and-SOAP-Discovery.md` | RD-31 | xml_rpc,soap | active | custom |
| 32 | `32-Email-Address-Harvesting.md` | RD-32 | email | osint | theharvester |
| 33 | `33-Phone-Number-Enumeration.md` | RD-33 | phone | osint | custom |
| 34 | `34-Physical-Location-Intelligence.md` | RD-34 | physical | osint | google-maps |
| 35 | `35-Supply-Chain-Asset-Mapping.md` | RD-35 | third_party_integration | passive | custom |
| 36 | `36-Competitor-Analysis.md` | RD-36 | competitor | osint | custom |
| 37 | `37-Partner-Network-Discovery.md` | RD-37 | partner | osint | custom |
| 38 | `38-Acquisition-Target-Analysis.md` | RD-38 | subsidiary | osint | custom |
| 39 | `39-Subsidiary-Asset-Mapping.md` | RD-39 | subsidiary | osint | custom |
| 40 | `40-Regional-Infrastructure-Mapping.md` | RD-40 | regional_infrastructure | active | nmap |
| 41 | `41-Content-Management-System-Detection.md` | RD-41 | cms | passive | whatweb,wappalyzer |
| 42 | `42-Framework-and-Library-Identification.md` | RD-42 | framework | passive | wappalyzer |
| 43 | `43-Server-Configuration-Analysis.md` | RD-43 | server_config | passive | nmap |
| 44 | `44-SSL-TLS-Certificate-Analysis.md` | RD-44 | ssl_cert | passive | sslscan |
| 45 | `45-HTTP-Header-Intelligence.md` | RD-45 | http_header | passive | curl |
| 46 | `46-Cookie-Analysis-and-Session-Management.md` | RD-46 | cookie | passive | burp |
| 47 | `47-Error-Page-Analysis.md` | RD-47 | error_page | active | custom |
| 48 | `48-Debug-Endpoint-Discovery.md` | RD-48 | debug_endpoint | active | ffuf |
| 49 | `49-Staging-Environment-Detection.md` | RD-49 | staging_environment | active | ffuf |
| 50 | `50-Advanced-Reconnaissance-Strategy.md` | RD-50 | multiple | hybrid | multiple |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and recon methodology |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

- **advanced-automation.md** — Automation modules use recon data as input.
- **core-prompts-hunting.md** — Hunting modules reference recon techniques.
- **specialized-targets.md** — Specialized targets require specific recon approaches.

---

## Usage Examples

### Example 1: Find Live Hosts Modules

```python
results = find_live_hosts_modules(index)
```

### Example 2: Find WordPress Modules

```python
results = find_assets_by_technology(index, 'wordpress')
# Returns: RD-04, RD-09, RD-41
```

### Example 3: Find Passive Modules

```python
results = find_passive_modules(index)
```

### Example 4: Find Subdomain Modules

```python
results = find_by_asset_type(index, 'subdomain')
```
