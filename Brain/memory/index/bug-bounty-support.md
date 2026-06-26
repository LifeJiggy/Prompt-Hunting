# Bug Bounty Support — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `bug-bounty-support` |
| Root Path | `bug-bounty-support/` |
| File Count | 23 primary files + README + registry.json |
| Index Type | Category-stratified (framework, methodology, template) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Bug Bounty Support domain index manages metadata for 23 support modules covering frameworks, methodologies, tools, and templates for bug bounty hunting. Each file provides guidance on specific aspects of the hunting workflow. The index enables lookup by category, methodology for a specific vulnerability class, and template availability for specific platforms.

This index supports two primary query patterns:
1. **Find methodology for XSS** (or any vuln class) — given a vulnerability class, retrieve all methodology modules relevant to hunting it.
2. **Find template for HackerOne** (or any platform) — given a platform, retrieve all template and format modules applicable to submissions on that platform.

---

## Index Schema

### Primary Index: `support_records`

```json
{
  "doc_type": "support_record",
  "file_ref": "bug-bounty-support/<filename>.md",
  "module_id": "BB-<number>",
  "module_title": "<title>",
  "category": "enum[advanced_hunting|security_hunting|info_disclosure|javascript_analysis|advanced_techniques|burp_integration|chaining|core_aspects|debugging|ethical_guidelines|exploitation|js_identification|manual_testing|parameters|poc_development|reconnaissance|reporting|specific_vulns|static_dynamic|injection_detection|tools_integration|user_functionality|vulnerability_detection]",
  "vuln_classes": ["enum[xss|sqli|ssrf|csrf|idor|xxe|ssti|rce|lfi|rfi|cmd_injection|auth_bypass|jwt|deserialization|cors|graphql|websocket|race_condition|file_upload|info_disclosure|business_logic|session|crypto|clickjacking|parameter_pollution|open_redirect|subdomain_takeover|host_header|http_smuggling|cache_poisoning|prototype_pollution|ldap|xpath|nosql|xxe|mobile|cloud]"],
  "platforms": ["enum[hackerone|bugcrowd|intigriti|yeswehack|all]"],
  "workflow_stage": "enum[recon|analysis|testing|exploitation|reporting]",
  "skill_level": "enum[beginner|intermediate|advanced|expert]",
  "tools_referenced": ["string"],
  "tags": ["string"],
  "supports_manual": "boolean",
  "supports_automated": "boolean",
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `vuln_class_index`

```json
{
  "vuln_class": "string",
  "modules": ["BB-<number>"],
  "stages_covered": ["string"]
}
```

### Tertiary Index: `platform_index`

```json
{
  "platform": "string",
  "modules": ["BB-<number>"],
  "template_count": "integer"
}
```

---

## Index Creation

```python
import re
from pathlib import Path
from datetime import datetime

def extract_support_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    if filename == 'registry.json' or filename == 'README':
        return None
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    if not match:
        module_num = 0
        module_slug = filename
    else:
        module_num = int(match.group(1))
        module_slug = match.group(2)
    
    category = classify_support_category(filename, content)
    vuln_classes = extract_vuln_classes(content, module_slug)
    platforms = extract_platforms(content)
    stage = detect_workflow_stage(content, module_slug)
    level = detect_skill_level(content)
    tools = extract_tools(content)
    
    return {
        "doc_type": "support_record",
        "file_ref": f"bug-bounty-support/{filepath.name}",
        "module_id": f"BB-{module_num:02d}" if module_num > 0 else f"BB-{filename[:8]}",
        "module_title": format_title(module_slug),
        "category": category,
        "vuln_classes": vuln_classes,
        "platforms": platforms,
        "workflow_stage": stage,
        "skill_level": level,
        "tools_referenced": tools,
        "tags": extract_tags(content),
        "supports_manual": detect_manual(content),
        "supports_automated": detect_automated(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_support_category(filename: str, content: str) -> str:
    text = (filename + ' ' + content).lower()
    mapping = {
        'advanced-bug-bounty-prompt': 'advanced_hunting',
        'advanced-bug-security-hunting': 'security_hunting',
        'advanced-information-disclosure': 'info_disclosure',
        'advanced-javascript-vulnerability': 'javascript_analysis',
        'advanced-techniques': 'advanced_techniques',
        'burp-ai': 'burp_integration',
        'chaining': 'chaining',
        'core-aspects': 'core_aspects',
        'debuging': 'debugging',
        'ethical': 'ethical_guidelines',
        'exploitation': 'exploitation',
        'javascript-identification': 'js_identification',
        'manual-testing': 'manual_testing',
        'parameters': 'parameters',
        'poc-development': 'poc_development',
        'reconnaissance': 'reconnaissance',
        'reporting': 'reporting',
        'specific-vulnerabilities': 'specific_vulns',
        'static-and-dynamic': 'static_dynamic',
        'to-identify-injection': 'injection_detection',
        'tools-integration': 'tools_integration',
        'user-functionality': 'user_functionality',
        'vulnerability-detection': 'vulnerability_detection',
    }
    for key, val in mapping.items():
        if key in text:
            return val
    return 'core_aspects'

VULN_CLASS_KEYWORDS = {
    'xss': ['xss', 'cross-site scripting'],
    'sqli': ['sqli', 'sql injection'],
    'ssrf': ['ssrf', 'server-side request forgery'],
    'csrf': ['csrf', 'cross-site request forgery'],
    'idor': ['idor', 'insecure direct object'],
    'xxe': ['xxe', 'xml external entity'],
    'ssti': ['ssti', 'server-side template injection'],
    'rce': ['rce', 'remote code execution'],
    'cmd_injection': ['command injection'],
    'lfi': ['lfi', 'local file inclusion', 'path traversal'],
    'auth_bypass': ['auth bypass', 'authentication bypass'],
    'jwt': ['jwt', 'json web token'],
    'deserialization': ['deserialization'],
    'cors': ['cors', 'cross-origin'],
    'graphql': ['graphql'],
    'websocket': ['websocket'],
    'race_condition': ['race condition'],
    'file_upload': ['file upload'],
    'info_disclosure': ['information disclosure', 'data leak'],
    'business_logic': ['business logic'],
    'session': ['session', 'cookie'],
    'crypto': ['crypto', 'encryption'],
    'clickjacking': ['clickjacking'],
    'parameter_pollution': ['parameter pollution'],
    'open_redirect': ['open redirect'],
    'subdomain_takeover': ['subdomain takeover'],
    'host_header': ['host header'],
    'http_smuggling': ['http smuggling'],
    'cache_poisoning': ['cache poisoning'],
    'prototype_pollution': ['prototype pollution'],
    'ldap': ['ldap'],
    'xpath': ['xpath'],
    'nosql': ['nosql'],
    'mobile': ['mobile'],
    'cloud': ['cloud', 'aws', 'azure'],
}

def extract_vuln_classes(content: str, slug: str) -> list:
    text = (slug + ' ' + content).lower()
    found = []
    for vc, keywords in VULN_CLASS_KEYWORDS.items():
        for kw in keywords:
            if kw in text:
                found.append(vc)
                break
    return found if found else ['general']

def extract_platforms(content: str) -> list:
    text = content.lower()
    platforms = []
    if 'hackerone' in text:
        platforms.append('hackerone')
    if 'bugcrowd' in text:
        platforms.append('bugcrowd')
    if 'intigriti' in text:
        platforms.append('intigriti')
    if 'yeswehack' in text:
        platforms.append('yeswehack')
    return platforms if platforms else ['all']

def detect_workflow_stage(content: str, slug: str) -> str:
    text = (slug + ' ' + content).lower()
    if any(kw in text for kw in ['recon', 'enumerate', 'discover', 'osint']):
        return 'recon'
    if any(kw in text for kw in ['analyz', 'assess', 'evaluate', 'identify']):
        return 'analysis'
    if any(kw in text for kw in ['test', 'probe', 'fuzz', 'scan']):
        return 'testing'
    if any(kw in text for kw in ['exploit', 'trigger', 'poc', 'proof']):
        return 'exploitation'
    if any(kw in text for kw in ['report', 'write', 'document', 'template']):
        return 'reporting'
    return 'analysis'

def detect_skill_level(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['expert', 'advanced', 'complex', 'sophisticated']):
        return 'advanced'
    if any(kw in text for kw in ['intermediate', 'moderate']):
        return 'intermediate'
    if any(kw in text for kw in ['beginner', 'basic', 'introduction', 'getting started']):
        return 'beginner'
    return 'intermediate'

def extract_tools(content: str) -> list:
    text = content.lower()
    tools = []
    tool_names = [
        'burp suite', 'nmap', 'nikto', 'sqlmap', 'xsstrike', 'dalfox',
        'ffuf', 'gobuster', 'subfinder', 'httpx', 'nuclei', 'katana',
        'waybackurls', 'gau', 'katana', 'amass', 'sublist3r', 'wpscan',
        'dirsearch', 'wfuzz', 'hackbar', 'postman', 'curl', 'python',
        'ruby', 'nodejs', 'javascript', 'chrome devtools', 'firefox',
        'wireshark', 'mitmproxy', 'zaproxy', 'owasp zap'
    ]
    for tool in tool_names:
        if tool in text:
            tools.append(tool)
    return tools

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'automation', 'manual', 'tutorial', 'guide', 'reference',
        'template', 'checklist', 'methodology', 'framework', 'workflow'
    ]
    text = content.lower()
    for tag in tag_keywords:
        if tag in text:
            tags.append(tag)
    return tags

def detect_manual(content: str) -> bool:
    text = content.lower()
    return any(kw in text for kw in ['manual', 'hand-crafted', 'human review'])

def detect_automated(content: str) -> bool:
    text = content.lower()
    return any(kw in text for kw in ['automated', 'script', 'tool', 'pipeline'])

def format_title(slug: str) -> str:
    return slug.replace('-', ' ').title()

def extract_date(content: str) -> str:
    match = re.search(r'(\d{4}-\d{2}-\d{2})', content)
    return match.group(1) if match else datetime.now().isoformat()
```

### Build Support Index

```python
class SupportIndex:
    def __init__(self):
        self.primary = {}
        self.by_category = {}
        self.by_vuln_class = {}
        self.by_platform = {}
        self.by_stage = {}
        self.by_level = {}
        self.by_tool = {}
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        self.by_category.setdefault(doc['category'], []).append(mid)
        
        for vc in doc['vuln_classes']:
            self.by_vuln_class.setdefault(vc, []).append(mid)
        
        for plat in doc['platforms']:
            self.by_platform.setdefault(plat, []).append(mid)
        
        self.by_stage.setdefault(doc['workflow_stage'], []).append(mid)
        self.by_level.setdefault(doc['skill_level'], []).append(mid)
        
        for tool in doc['tools_referenced']:
            self.by_tool.setdefault(tool, []).append(mid)
    
    def find_methodology_for_vuln(self, vuln_class: str) -> list:
        mids = self.by_vuln_class.get(vuln_class, [])
        return [self.primary[mid] for mid in mids]
    
    def find_template_for_platform(self, platform: str) -> list:
        mids = self.by_platform.get(platform, [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_stage(self, stage: str) -> list:
        mids = self.by_stage.get(stage, [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_level(self, level: str) -> list:
        mids = self.by_level.get(level, [])
        return [self.primary[mid] for mid in mids]
```

### Persist Index

```python
import json
from datetime import datetime

def persist_support_index(index: SupportIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "bug-bounty-support",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_category": index.by_category,
            "by_vuln_class": index.by_vuln_class,
            "by_platform": index.by_platform,
            "by_stage": index.by_stage,
            "by_level": index.by_level,
            "by_tool": index.by_tool,
        }
    }
    
    index_file = output_dir / "support-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Methodology for XSS

```python
def find_methodology_for_vuln(index: SupportIndex, vuln_class: str) -> list:
    return index.find_methodology_for_vuln(vuln_class)
```

### Query 2: Find Template for HackerOne

```python
def find_template_for_platform(index: SupportIndex, platform: str) -> list:
    return index.find_template_for_platform(platform)
```

### Query 3: Find All Recon Modules

```python
def find_recon_modules(index: SupportIndex) -> list:
    return index.find_by_stage('recon')
```

### Query 4: Find Beginner Modules

```python
def find_beginner_modules(index: SupportIndex) -> list:
    return index.find_by_level('beginner')
```

### Query 5: Find Modules Using Burp

```python
def find_by_tool(index: SupportIndex, tool: str) -> list:
    mids = index.by_tool.get(tool, [])
    return [index.primary[mid] for mid in mids]
```

### Query 6: Find XSS Exploitation Guide

```python
def find_xss_exploitation(index: SupportIndex) -> list:
    xss_mids = set(index.by_vuln_class.get('xss', []))
    exploit_mids = set(index.by_stage.get('exploitation', []))
    results = xss_mids & exploit_mids
    return [index.primary[mid] for mid in results]
```

---

## Search Algorithms

### Support Module Scoring

```python
class SupportScorer:
    def __init__(self, index: SupportIndex):
        self.index = index
    
    def score_module(self, doc: dict, query: dict) -> float:
        score = 0.0
        
        if 'vuln_class' in query and query['vuln_class'] in doc['vuln_classes']:
            score += 0.35
        
        if 'platform' in query and query['platform'] in doc['platforms']:
            score += 0.20
        
        if 'stage' in query and doc['workflow_stage'] == query['stage']:
            score += 0.20
        
        if 'level' in query and doc['skill_level'] == query['level']:
            score += 0.15
        
        score += 0.10  # base relevance
        
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

class SupportBM25:
    def __init__(self, index: SupportIndex):
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
            text = f"{doc['module_title']} {doc['category']} {' '.join(doc['vuln_classes'])} {' '.join(doc.get('tags', []))}"
            doc_tokens = self._tokenize(text)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                if tf > 0:
                    df = sum(1 for d in self.index.primary.values() 
                             if qt in f"{d['module_title']} {d['category']}".lower())
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
def compute_support_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'vuln_class' in query and query['vuln_class'] in doc['vuln_classes']:
        score += 0.35
    if 'platform' in query and query['platform'] in doc['platforms']:
        score += 0.25
    if 'stage' in query and doc['workflow_stage'] == query['stage']:
        score += 0.20
    if 'level' in query and doc['skill_level'] == query['level']:
        score += 0.10
    
    tool_bonus = min(len(doc['tools_referenced']) / 5.0, 0.10)
    score += tool_bonus
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_support_index(index: SupportIndex, new_file: Path):
    doc = extract_support_metadata(new_file)
    if doc:
        index.add(doc)

def remove_module(index: SupportIndex, module_id: str):
    if module_id not in index.primary:
        return
    doc = index.primary[module_id]
    
    for idx_map in [index.by_category, index.by_vuln_class, index.by_platform,
                    index.by_stage, index.by_level]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
    
    for tool in doc['tools_referenced']:
        if tool in index.by_tool and module_id in index.by_tool[tool]:
            index.by_tool[tool].remove(module_id)
    
    del index.primary[module_id]

def verify_support_index(index: SupportIndex) -> dict:
    issues = []
    for mid, doc in index.primary.items():
        if not doc.get('vuln_classes'):
            issues.append(f"Module {mid} has no vuln classes")
        if not doc.get('category'):
            issues.append(f"Module {mid} has no category")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Module ID | Category | Vuln Classes | Stage | Level |
|---|------|-----------|----------|-------------|-------|-------|
| — | `Advanced-Bug-Bounty-Prompt.md` | BB-AB | advanced_hunting | general | analysis | advanced |
| — | `Advanced-Bug-Security-Hunting-Prompt.md` | BB-ASH | security_hunting | general | testing | advanced |
| — | `Advanced-Information-Disclosure-Analysis-Prompt.md` | BB-AID | info_disclosure | info_disclosure | analysis | intermediate |
| — | `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` | BB-AJS | javascript_analysis | xss | analysis | advanced |
| — | `Advanced-Techniques.md` | BB-AT | advanced_techniques | general | exploitation | advanced |
| — | `Burp-AI.md` | BB-BAI | burp_integration | general | testing | intermediate |
| — | `Chaining.md` | BB-CH | chaining | general | exploitation | advanced |
| — | `Core-Aspects-for-Bug-Security-Hunting.md` | BB-CAS | core_aspects | general | analysis | beginner |
| — | `debuging-using-browser-console-and-vscode-for-hunting.md` | BB-DBG | debugging | general | analysis | beginner |
| — | `Ethical-Guidelines.md` | BB-ETH | ethical_guidelines | general | recon | beginner |
| — | `Exploitation.md` | BB-EXP | exploitation | general | exploitation | intermediate |
| — | `JavaScript-Identification-Deobfuscation.md` | BB-JID | js_identification | xss | analysis | intermediate |
| — | `manual-testing-scope.md` | BB-MTS | manual_testing | general | testing | beginner |
| — | `parameters.md` | BB-PRM | parameters | general | analysis | beginner |
| — | `PoC-Development.md` | BB-POC | poc_development | general | exploitation | intermediate |
| — | `Reconnaissance.md` | BB-REC | reconnaissance | general | recon | beginner |
| — | `Reporting.md` | BB-RPT | reporting | general | reporting | beginner |
| — | `Specific-Vulnerabilities-Hunting.md` | BB-SVH | specific_vulns | general | testing | intermediate |
| — | `static-and-dynamic-testing.md` | BB-SDT | static_dynamic | general | testing | intermediate |
| — | `to-identify-injection-and-reflected-point-during-testing.md` | BB-IIR | injection_detection | sqli,xss,rce | testing | intermediate |
| — | `Tools-Integration.md` | BB-TIN | tools_integration | general | testing | intermediate |
| — | `user-functionality.md` | BB-UFN | user_functionality | business_logic | analysis | beginner |
| — | `Vulnerability-Detection.md` | BB-VDT | vulnerability_detection | general | testing | intermediate |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and support methodology |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

- **core-prompts-hunting.md** — Hunting prompts reference support methodologies.
- **report-writing-mastery.md** — Reporting modules share templates with support.
- **bug-bounty-program-strategy.md** — Strategy modules reference support frameworks.
- **real-world-case-studies.md** — Case studies validate support methodologies.

---

## Usage Examples

### Example 1: Find XSS Methodology

```python
results = find_methodology_for_vuln(index, 'xss')
# Returns: BB-AJS, BB-JID, BB-IIR, BB-VDT
```

### Example 2: Find HackerOne Templates

```python
results = find_template_for_platform(index, 'hackerone')
```

### Example 3: Find Beginner Recon Guide

```python
scorer = SupportScorer(index)
ranked = scorer.rank_modules({"vuln_class": "general", "stage": "recon", "level": "beginner"})
```

### Example 4: Find All Burp-Integrated Modules

```python
results = find_by_tool(index, 'burp suite')
```
