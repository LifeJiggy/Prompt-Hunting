# Specialized Targets — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `specialized-targets` |
| Root Path | `Specialized-Targets/` |
| File Count | 50 primary files + README + registry.json |
| Index Type | Category-stratified (IoT, mobile, cloud, industry) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Specialized Targets domain index manages metadata for 50 specialized security testing modules covering IoT, mobile, cloud, blockchain, healthcare, finance, government, education, e-commerce, social media, CMS, and other vertical-specific targets. Each file provides specialized testing methodologies for a specific target category. The index organizes modules by target category, compliance framework, and industry vertical.

This index supports two primary query patterns:
1. **Find IoT findings** — given a target category, retrieve all modules with findings relevant to that category.
2. **Find HIPAA-relevant findings** — given a compliance framework, retrieve all modules that address compliance requirements.

---

## Index Schema

### Primary Index: `target_records`

```json
{
  "doc_type": "target_record",
  "file_ref": "Specialized-Targets/<filename>.md",
  "module_id": "ST-<number>",
  "module_title": "<title>",
  "target_category": "enum[iot|mobile|cloud|container|kubernetes|blockchain|defi|nft|web3|crypto_exchange|traditional_finance|healthcare|financial|government|education|ecommerce|social_media|cms|lms|hr_system|supply_chain|manufacturing|smart_building|connected_vehicle|autonomous_system|industrial_control|medical_device|wearable|smart_home|embedded|rtos|firmware|network_device|telecom|satellite|air_traffic|power_grid|water_treatment|transportation|energy|research|non_profit|startup|enterprise|fortune500|open_source|academic|international|developing_country|global_system]",
  "compliance_frameworks": ["enum[hipaa|pci_dss|sox|gdpr|ferpa|glba|pipeda|iso27001|soc2|fedramp|fisma|nist_800|cis|mitre_attack]"],
  "testing_methodology": "enum[web|api|firmware|network|protocol|physical|social|mobile|cloud|blockchain|ics_scada]",
  "attack_surface": ["string"],
  "severity_profile": {
    "typical": "enum[critical|high|medium|low|info]",
    "max_observed": "enum[critical|high|medium|low|info]"
  },
  "specialized_tools": ["string"],
  "regulatory_requirements": ["string"],
  "tags": ["string"],
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `category_index`

```json
{
  "category": "string",
  "modules": ["ST-<number>"],
  "compliance_frameworks": ["string"],
  "avg_severity": "float"
}
```

### Tertiary Index: `compliance_index`

```json
{
  "framework": "string",
  "modules": ["ST-<number>"],
  "categories": ["string"],
  "total_requirements": "integer"
}
```

---

## Index Creation

```python
import re
from pathlib import Path
from datetime import datetime

def extract_target_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    module_num = int(match.group(1)) if match else 0
    module_slug = match.group(2) if match else filename
    
    category = classify_target_category(module_slug)
    compliance = extract_compliance_frameworks(content, module_slug)
    methodology = detect_testing_methodology(content, module_slug)
    attack_surface = extract_attack_surface(content)
    severity = extract_severity_profile(content)
    tools = extract_tools(content)
    regulatory = extract_regulatory_requirements(content)
    
    return {
        "doc_type": "target_record",
        "file_ref": f"Specialized-Targets/{filepath.name}",
        "module_id": f"ST-{module_num:02d}",
        "module_title": format_title(module_slug),
        "target_category": category,
        "compliance_frameworks": compliance,
        "testing_methodology": methodology,
        "attack_surface": attack_surface,
        "severity_profile": severity,
        "specialized_tools": tools,
        "regulatory_requirements": regulatory,
        "tags": extract_tags(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_target_category(slug: str) -> str:
    mapping = {
        'iot-device': 'iot', 'internet-of-things': 'iot',
        'mobile-application': 'mobile', 'mobile-app': 'mobile',
        'cloud-infrastructure': 'cloud', 'cloud-security': 'cloud',
        'container-security': 'container',
        'kubernetes-cluster': 'kubernetes',
        'blockchain-smart': 'blockchain', 'smart-contract': 'blockchain',
        'defi-protocol': 'defi', 'decentralized-finance': 'defi',
        'nft-marketplace': 'nft',
        'web3-application': 'web3',
        'cryptocurrency-exchange': 'crypto_exchange',
        'traditional-finance': 'traditional_finance',
        'healthcare-system': 'healthcare', 'medical-device': 'medical_device',
        'financial-institution': 'financial',
        'government-system': 'government',
        'education-platform': 'education',
        'ecommerce-platform': 'ecommerce', 'e-commerce': 'ecommerce',
        'social-media-platform': 'social_media',
        'content-management': 'cms',
        'learning-management': 'lms',
        'human-resources': 'hr_system',
        'supply-chain-management': 'supply_chain',
        'manufacturing-control': 'manufacturing',
        'smart-building': 'smart_building',
        'connected-vehicle': 'connected_vehicle',
        'autonomous-system': 'autonomous_system',
        'industrial-control': 'industrial_control', 'ics': 'industrial_control', 'scada': 'industrial_control',
        'wearable-technology': 'wearable',
        'smart-home': 'smart_home',
        'embedded-system': 'embedded',
        'real-time-operating': 'rtos',
        'firmware-security': 'firmware',
        'network-device': 'network_device',
        'telecommunication': 'telecom',
        'satellite-communication': 'satellite',
        'air-traffic-control': 'air_traffic',
        'power-grid': 'power_grid',
        'water-treatment': 'water_treatment',
        'transportation-system': 'transportation',
        'energy-management': 'energy',
        'research-institution': 'research',
        'non-profit': 'non_profit',
        'startup-company': 'startup',
        'enterprise-corporate': 'enterprise',
        'fortune-500': 'fortune500',
        'open-source-project': 'open_source',
        'academic-research': 'academic',
        'international-organization': 'international',
        'developing-country': 'developing_country',
        'global-scale': 'global_system',
    }
    slug_lower = slug.lower()
    for key, val in mapping.items():
        if key in slug_lower:
            return val
    return 'enterprise'

def extract_compliance_frameworks(content: str, slug: str) -> list:
    text = (slug + ' ' + content).lower()
    frameworks = []
    fw_keywords = {
        'hipaa': ['hipaa', 'health insurance'],
        'pci_dss': ['pci', 'pci-dss', 'payment card'],
        'sox': ['sox', 'sarbanes'],
        'gdpr': ['gdpr', 'general data protection'],
        'ferpa': ['ferpa', 'education records'],
        'glba': ['glba', 'gramm-leach'],
        'pipeda': ['pipeda', 'canadian privacy'],
        'iso27001': ['iso27001', 'iso 27001'],
        'soc2': ['soc2', 'soc 2'],
        'fedramp': ['fedramp', 'fed ramp'],
        'fisma': ['fisma', 'federal information'],
        'nist_800': ['nist', 'nist-800'],
        'cis': ['cis', 'center for internet'],
        'mitre_attack': ['mitre', 'mitre-attack', 'attack framework'],
    }
    for fw, keywords in fw_keywords.items():
        for kw in keywords:
            if kw in text:
                frameworks.append(fw)
                break
    return frameworks

def detect_testing_methodology(content: str, slug: str) -> str:
    text = (slug + ' ' + content).lower()
    if any(kw in text for kw in ['firmware', 'bios', 'embedded']):
        return 'firmware'
    if any(kw in text for kw in ['protocol', 'modbus', 'bacnet', 'mqtt']):
        return 'protocol'
    if any(kw in text for kw in ['physical', 'hardware', 'jtag']):
        return 'physical'
    if any(kw in text for kw in ['social engineering', 'phishing']):
        return 'social'
    if any(kw in text for kw in ['mobile', 'android', 'ios']):
        return 'mobile'
    if any(kw in text for kw in ['cloud', 'aws', 'azure', 'gcp']):
        return 'cloud'
    if any(kw in text for kw in ['blockchain', 'smart contract', 'defi']):
        return 'blockchain'
    if any(kw in text for kw in ['ics', 'scada', 'plc', 'hmi']):
        return 'ics_scada'
    if 'api' in text:
        return 'api'
    return 'web'

def extract_attack_surface(content: str) -> list:
    text = content.lower()
    surfaces = []
    surface_keywords = [
        'web application', 'api', 'mobile app', 'firmware',
        'network', 'physical', 'cloud', 'iot device',
        'smart contract', 'database', 'email', 'social media',
        'supply chain', 'third party', 'vendor'
    ]
    for surface in surface_keywords:
        if surface in text:
            surfaces.append(surface)
    return surfaces[:10] if surfaces else ['web application']

def extract_severity_profile(content: dict) -> dict:
    text = content.lower() if isinstance(content, str) else ''
    
    typical = 'medium'
    if any(kw in text for kw in ['critical vulnerability', 'rce possible']):
        typical = 'critical'
    elif any(kw in text for kw in ['high severity', 'significant impact']):
        typical = 'high'
    elif any(kw in text for kw in ['low severity', 'minor issue']):
        typical = 'low'
    
    max_observed = typical
    if 'critical' in text:
        max_observed = 'critical'
    elif 'high' in text:
        max_observed = 'high'
    
    return {"typical": typical, "max_observed": max_observed}

def extract_tools(content: str) -> list:
    text = content.lower()
    tools = []
    tool_names = [
        'ghidra', 'ida pro', 'radare2', 'binwalk', 'firmwalker',
        'jadx', 'apktool', 'frida', 'objection', 'drozer',
        'scout suite', 'pacu', 'cloudsploit', 'prowler',
        'metasploit', 'burp suite', 'nmap', 'wireshark',
        'plcscan', 'modbus-tcp', 'mbtget', 's7comm',
        'mythril', 'slither', 'echidna', 'manticore',
        'ganache', 'truffle', 'hardhat', 'foundry',
        'sqlmap', 'nuclei', 'ffuf', 'gobuster',
        'postman', 'curl', 'python', 'ruby',
    ]
    for tool in tool_names:
        if tool in text:
            tools.append(tool)
    return tools

def extract_regulatory_requirements(content: str) -> list:
    text = content.lower()
    requirements = []
    req_keywords = [
        'data encryption', 'access control', 'audit logging',
        'incident response', 'business continuity', 'disaster recovery',
        'penetration testing', 'vulnerability scanning', 'risk assessment',
        'employee training', 'vendor management', 'data retention',
        'privacy notice', 'consent management', 'breach notification',
    ]
    for req in req_keywords:
        if req in text:
            requirements.append(req)
    return requirements[:10]

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'security', 'compliance', 'audit', 'penetration-test',
        'vulnerability', 'risk', 'regulation', 'framework'
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

### Build Target Index

```python
class TargetIndex:
    def __init__(self):
        self.primary = {}
        self.by_category = {}
        self.by_compliance = {}
        self.by_methodology = {}
        self.by_severity = {}
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        self.by_category.setdefault(doc['target_category'], []).append(mid)
        
        for fw in doc['compliance_frameworks']:
            self.by_compliance.setdefault(fw, []).append(mid)
        
        self.by_methodology.setdefault(doc['testing_methodology'], []).append(mid)
        self.by_severity.setdefault(doc['severity_profile']['typical'], []).append(mid)
    
    def find_iot_findings(self) -> list:
        mids = self.by_category.get('iot', [])
        return [self.primary[mid] for mid in mids]
    
    def find_hipaa_findings(self) -> list:
        mids = self.by_compliance.get('hipaa', [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_category(self, category: str) -> list:
        mids = self.by_category.get(category, [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_compliance(self, framework: str) -> list:
        mids = self.by_compliance.get(framework, [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_methodology(self, methodology: str) -> list:
        mids = self.by_methodology.get(methodology, [])
        return [self.primary[mid] for mid in mids]
    
    def find_critical_targets(self) -> list:
        mids = self.by_severity.get('critical', [])
        return [self.primary[mid] for mid in mids]
    
    def find_healthcare_targets(self) -> list:
        results = []
        for mid, doc in self.primary.items():
            if doc['target_category'] in ['healthcare', 'medical_device']:
                results.append(doc)
            elif 'hipaa' in doc['compliance_frameworks']:
                results.append(doc)
        return results
    
    def get_compliance_stats(self) -> dict:
        stats = {}
        for fw, mids in self.by_compliance.items():
            categories = set()
            for mid in mids:
                categories.add(self.primary[mid]['target_category'])
            stats[fw] = {
                "count": len(mids),
                "categories": list(categories)
            }
        return stats
```

### Persist Index

```python
import json
from datetime import datetime

def persist_target_index(index: TargetIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "specialized-targets",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_category": index.by_category,
            "by_compliance": index.by_compliance,
            "by_methodology": index.by_methodology,
            "by_severity": index.by_severity,
        },
        "compliance_stats": index.get_compliance_stats()
    }
    
    index_file = output_dir / "targets-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find IoT Findings

```python
def find_iot_findings(index: TargetIndex) -> list:
    return index.find_iot_findings()
```

### Query 2: Find HIPAA-Relevant Findings

```python
def find_hipaa_findings(index: TargetIndex) -> list:
    return index.find_hipaa_findings()
```

### Query 3: Find by Category

```python
def find_by_category(index: TargetIndex, category: str) -> list:
    return index.find_by_category(category)
```

### Query 4: Find by Compliance

```python
def find_by_compliance(index: TargetIndex, framework: str) -> list:
    return index.find_by_compliance(framework)
```

### Query 5: Find Healthcare Targets

```python
def find_healthcare_targets(index: TargetIndex) -> list:
    return index.find_healthcare_targets()
```

### Query 6: Find Critical Targets

```python
def find_critical_targets(index: TargetIndex) -> list:
    return index.find_critical_targets()
```

---

## Search Algorithms

### Target Module Scoring

```python
class TargetScorer:
    def __init__(self, index: TargetIndex):
        self.index = index
    
    def score_module(self, doc: dict, query: dict) -> float:
        score = 0.0
        
        if 'category' in query and doc['target_category'] == query['category']:
            score += 0.30
        if 'compliance' in query and query['compliance'] in doc['compliance_frameworks']:
            score += 0.25
        if 'methodology' in query and doc['testing_methodology'] == query['methodology']:
            score += 0.20
        
        sev_map = {'critical': 0.15, 'high': 0.12, 'medium': 0.08, 'low': 0.05, 'info': 0.02}
        score += sev_map.get(doc['severity_profile']['typical'], 0.05)
        
        tool_bonus = min(len(doc['specialized_tools']) / 10.0, 0.10)
        score += tool_bonus
        
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

class TargetBM25:
    def __init__(self, index: TargetIndex):
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
            text = f"{doc['module_title']} {doc['target_category']} {' '.join(doc['compliance_frameworks'])} {' '.join(doc['attack_surface'])}"
            doc_tokens = self._tokenize(text)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                if tf > 0:
                    df = sum(1 for d in self.index.primary.values() 
                             if qt in f"{d['module_title']} {d['target_category']}".lower())
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
def compute_target_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'category' in query and doc['target_category'] == query['category']:
        score += 0.30
    if 'compliance' in query and query['compliance'] in doc['compliance_frameworks']:
        score += 0.25
    if 'methodology' in query and doc['testing_methodology'] == query['methodology']:
        score += 0.20
    if 'severity' in query:
        sev_order = ['info', 'low', 'medium', 'high', 'critical']
        if sev_order.index(doc['severity_profile']['typical']) >= sev_order.index(query['severity']):
            score += 0.15
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_target_index(index: TargetIndex, new_file: Path):
    doc = extract_target_metadata(new_file)
    index.add(doc)

def remove_module(index: TargetIndex, module_id: str):
    if module_id not in index.primary:
        return
    doc = index.primary[module_id]
    
    for idx_map in [index.by_category, index.by_methodology, index.by_severity]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
    
    for fw in doc['compliance_frameworks']:
        if fw in index.by_compliance and module_id in index.by_compliance[fw]:
            index.by_compliance[fw].remove(module_id)
    
    del index.primary[module_id]

def verify_target_index(index: TargetIndex) -> dict:
    issues = []
    for mid, doc in index.primary.items():
        if not doc.get('target_category'):
            issues.append(f"Module {mid} has no target category")
        if not doc.get('testing_methodology'):
            issues.append(f"Module {mid} has no testing methodology")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Module ID | Category | Compliance | Methodology |
|---|------|-----------|----------|------------|-------------|
| 01 | `01-IoT-Device-Security.md` | ST-01 | iot | none | firmware |
| 02 | `02-Mobile-Application-Testing.md` | ST-02 | mobile | none | mobile |
| 03 | `03-Cloud-Infrastructure-Security.md` | ST-03 | cloud | iso27001,soc2 | cloud |
| 04 | `04-Container-Security.md` | ST-04 | container | cis | cloud |
| 05 | `05-Kubernetes-Cluster-Security.md` | ST-05 | kubernetes | cis | cloud |
| 06 | `06-Blockchain-Smart-Contracts.md` | ST-06 | blockchain | none | blockchain |
| 07 | `07-DeFi-Protocol-Security.md` | ST-07 | defi | none | blockchain |
| 08 | `08-NFT-Marketplace-Security.md` | ST-08 | nft | none | blockchain |
| 09 | `09-Web3-Application-Security.md` | ST-09 | web3 | none | blockchain |
| 10 | `10-Cryptocurrency-Exchange-Security.md` | ST-10 | crypto_exchange | pci_dss | blockchain |
| 11 | `11-Traditional-Finance-API-Security.md` | ST-11 | traditional_finance | pci_dss,sox | api |
| 12 | `12-Healthcare-System-Security.md` | ST-12 | healthcare | hipaa | web |
| 13 | `13-Financial-Institution-Security.md` | ST-13 | financial | pci_dss,sox,glba | web |
| 14 | `14-Government-System-Security.md` | ST-14 | government | fedramp,fisma,nist_800 | web |
| 15 | `15-Education-Platform-Security.md` | ST-15 | education | ferpa | web |
| 16 | `16-E-commerce-Platform-Security.md` | ST-16 | ecommerce | pci_dss | web |
| 17 | `17-Social-Media-Platform-Security.md` | ST-17 | social_media | gdpr | web |
| 18 | `18-Content-Management-System-Security.md` | ST-18 | cms | none | web |
| 19 | `19-Learning-Management-System-Security.md` | ST-19 | lms | ferpa | web |
| 20 | `20-Human-Resources-System-Security.md` | ST-20 | hr_system | gdpr | web |
| 21 | `21-Supply-Chain-Management-Security.md` | ST-21 | supply_chain | iso27001 | web |
| 22 | `22-Manufacturing-Control-System-Security.md` | ST-22 | manufacturing | none | ics_scada |
| 23 | `23-Smart-Building-Automation.md` | ST-23 | smart_building | none | iot |
| 24 | `24-Connected-Vehicle-Security.md` | ST-24 | connected_vehicle | none | protocol |
| 25 | `25-Autonomous-System-Security.md` | ST-25 | autonomous_system | none | protocol |
| 26 | `26-Industrial-Control-System-Security.md` | ST-26 | industrial_control | none | ics_scada |
| 27 | `27-Medical-Device-Security.md` | ST-27 | medical_device | hipaa | firmware |
| 28 | `28-Wearable-Technology-Security.md` | ST-28 | wearable | none | mobile |
| 29 | `29-Smart-Home-Device-Security.md` | ST-29 | smart_home | none | iot |
| 30 | `30-Embedded-System-Security.md` | ST-30 | embedded | none | firmware |
| 31 | `31-Real-Time-Operating-System-Security.md` | ST-31 | rtos | none | firmware |
| 32 | `32-Firmware-Security-Analysis.md` | ST-32 | firmware | none | firmware |
| 33 | `33-Network-Device-Security.md` | ST-33 | network_device | cis | network |
| 34 | `34-Telecommunication-System-Security.md` | ST-34 | telecom | none | network |
| 35 | `35-Satellite-Communication-Security.md` | ST-35 | satellite | none | protocol |
| 36 | `36-Air-Traffic-Control-System-Security.md` | ST-36 | air_traffic | none | ics_scada |
| 37 | `37-Power-Grid-Security.md` | ST-37 | power_grid | none | ics_scada |
| 38 | `38-Water-Treatment-Facility-Security.md` | ST-38 | water_treatment | none | ics_scada |
| 39 | `39-Transportation-System-Security.md` | ST-39 | transportation | none | ics_scada |
| 40 | `40-Energy-Management-System-Security.md` | ST-40 | energy | none | ics_scada |
| 41 | `41-Research-Institution-Security.md` | ST-41 | research | iso27001 | web |
| 42 | `42-Non-Profit-Organization-Security.md` | ST-42 | non_profit | none | web |
| 43 | `43-Startup-Company-Security.md` | ST-43 | startup | none | web |
| 44 | `44-Enterprise-Corporate-Security.md` | ST-44 | enterprise | iso27001,soc2 | web |
| 45 | `45-Fortune-500-Company-Security.md` | ST-45 | fortune500 | iso27001,soc2,pci_dss | web |
| 46 | `46-Open-Source-Project-Security.md` | ST-46 | open_source | none | web |
| 47 | `47-Academic-Research-Security.md` | ST-47 | academic | ferpa | web |
| 48 | `48-International-Organization-Security.md` | ST-48 | international | gdpr,iso27001 | web |
| 49 | `49-Developing-Country-Infrastructure.md` | ST-49 | developing_country | none | ics_scada |
| 50 | `50-Global-Scale-System-Security.md` | ST-50 | global_system | iso27001,soc2 | web |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and specialized targets methodology |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

- **advanced-persistence-exploitation.md** — Persistence techniques vary by target category.
- **advanced-chaining-techniques.md** — Attack chains are target-specific.
- **core-prompts-hunting.md** — Hunting prompts reference specialized targets.
- **real-world-case-studies.md** — Case studies validate specialized testing approaches.

---

## Usage Examples

### Example 1: Find IoT Findings

```python
results = find_iot_findings(index)
# Returns: ST-01, ST-23, ST-29
```

### Example 2: Find HIPAA-Relevant Findings

```python
results = find_hipaa_findings(index)
# Returns: ST-12, ST-27
```

### Example 3: Find Healthcare Targets

```python
results = find_healthcare_targets(index)
# Returns: ST-12, ST-27
```

### Example 4: Find Cloud Targets with SOC2

```python
results = find_by_compliance(index, 'soc2')
# Returns: ST-03, ST-04, ST-05, ST-44, ST-45, ST-48, ST-50
```

### Example 5: Find Critical Targets

```python
results = find_critical_targets(index)
```
