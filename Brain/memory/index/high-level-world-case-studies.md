# High-Level World Case Studies — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `high-level-world-case-studies` |
| Root Path | `High-Level-World-Case-Studies/` |
| File Count | 46 primary files + README + registry.json |
| Index Type | Case-centric (category, attack_vector, severity) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The High-Level World Case Studies domain index manages metadata for 46 case study modules documenting real-world cybersecurity incidents, breaches, and attack campaigns at a strategic level. Each file provides high-level analysis of an incident category, attack pattern, or security failure. The index organizes cases by category, attack vector, severity, and industry impact.

This index supports two primary query patterns:
1. **Find cases involving ransomware** (or any category) — given an attack category, retrieve all case studies documenting that type of incident.
2. **Find cloud breach cases** — given an infrastructure type, retrieve all case studies involving that infrastructure.

---

## Index Schema

### Primary Index: `case_records`

```json
{
  "doc_type": "case_record",
  "file_ref": "High-Level-World-Case-Studies/<filename>.md",
  "case_id": "HC-<number>",
  "case_title": "<title>",
  "category": "enum[critical_infrastructure|zero_day|vulnerability_chain|impact_assessment|timeline|reward_strategy|report_quality|triage|program_response|disclosure|collaborative|cross_program|industry_specific|mobile|web_application|api_breach|cloud_error|container_escape|iot|blockchain|cryptocurrency|social_engineering|physical_security|network_infrastructure|database|file_system|auth_bypass|authorization|session_management|input_validation|business_logic|info_disclosure|weak_crypto|insecure_communication|third_party|supply_chain|zero_trust_bypass|mfa_bypass|privilege_escalation|lateral_movement|data_exfiltration|persistence|anti_forensic|incident_response|compliance|post_mortem]",
  "attack_vector": "enum[phishing|exploit|misconfiguration|insider|supply_chain|physical|social_engineering|brute_force|credential_stuffing|zero_day|malware|ransomware|apt|nation_state|opportunistic]",
  "severity": "enum[critical|high|medium|low|info]",
  "impact_scope": "enum[global|regional|industry|enterprise|small_business|individual]",
  "industries_affected": ["string"],
  "timeline": {
    "discovery_to_fix_days": "integer",
    "disclosure_type": "enum[coordinated|responsible|full_disclosure|non_disclosure]"
  },
  "financial_impact": {
    "estimated_usd": "integer",
    "bounty_paid": "integer",
    "recovery_cost": "integer"
  },
  "lessons_learned": ["string"],
  "tags": ["string"],
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `category_index`

```json
{
  "category": "string",
  "cases": ["HC-<number>"],
  "avg_severity": "float",
  "total_financial_impact": "integer"
}
```

### Tertiary Index: `attack_vector_index`

```json
{
  "attack_vector": "string",
  "cases": ["HC-<number>"],
  "categories": ["string"],
  "frequency": "integer"
}
```

---

## Index Creation

### Step 1: Extract Case Metadata

```python
import re
from pathlib import Path
from datetime import datetime

def extract_case_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    case_num = int(match.group(1)) if match else 0
    case_slug = match.group(2) if match else filename
    
    category = classify_case_category(case_slug)
    attack_vector = detect_attack_vector(content, case_slug)
    severity = detect_severity(content)
    impact_scope = detect_impact_scope(content)
    industries = extract_industries(content)
    timeline = extract_timeline(content)
    financial = extract_financial_impact(content)
    lessons = extract_lessons_learned(content)
    
    return {
        "doc_type": "case_record",
        "file_ref": f"High-Level-World-Case-Studies/{filepath.name}",
        "case_id": f"HC-{case_num:02d}",
        "case_title": format_title(case_slug),
        "category": category,
        "attack_vector": attack_vector,
        "severity": severity,
        "impact_scope": impact_scope,
        "industries_affected": industries,
        "timeline": timeline,
        "financial_impact": financial,
        "lessons_learned": lessons,
        "tags": extract_tags(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_case_category(slug: str) -> str:
    mapping = {
        'critical-infrastructure': 'critical_infrastructure',
        'zero-day': 'zero_day',
        'zero_day': 'zero_day',
        'chain-of': 'vulnerability_chain',
        'vulnerability-chain': 'vulnerability_chain',
        'real-world-impact': 'impact_assessment',
        'impact-assessment': 'impact_assessment',
        'timeline': 'timeline',
        'discovery-to-fix': 'timeline',
        'reward': 'reward_strategy',
        'maximization': 'reward_strategy',
        'report-quality': 'report_quality',
        'quality-analysis': 'report_quality',
        'triage': 'triage',
        'process-understanding': 'triage',
        'program-response': 'program_response',
        'response-analysis': 'program_response',
        'disclosure': 'disclosure',
        'timeline-study': 'disclosure',
        'collaborative': 'collaborative',
        'collaborative-hunting': 'collaborative',
        'cross-program': 'cross_program',
        'vulnerability-patterns': 'cross_program',
        'industry': 'industry_specific',
        'specific-findings': 'industry_specific',
        'mobile-app': 'mobile',
        'vulnerability-case': 'mobile',
        'web-application': 'web_application',
        'security-case': 'web_application',
        'api-security': 'api_breach',
        'breach-analysis': 'api_breach',
        'cloud-configuration': 'cloud_error',
        'configuration-error': 'cloud_error',
        'container-escape': 'container_escape',
        'case-study': 'container_escape',
        'iot-device': 'iot',
        'device-compromise': 'iot',
        'blockchain': 'blockchain',
        'smart-contract': 'blockchain',
        'cryptocurrency': 'cryptocurrency',
        'exchange-hack': 'cryptocurrency',
        'social-engineering': 'social_engineering',
        'engineering-success': 'social_engineering',
        'physical-security': 'physical_security',
        'security-bypass': 'physical_security',
        'network-infrastructure': 'network_infrastructure',
        'infrastructure-attack': 'network_infrastructure',
        'database': 'database',
        'compromise-case': 'database',
        'file-system': 'file_system',
        'attack-analysis': 'file_system',
        'authentication-bypass': 'auth_bypass',
        'bypass-case': 'auth_bypass',
        'authorization-flaw': 'authorization',
        'flaw-study': 'authorization',
        'session-management': 'session_management',
        'management-issue': 'session_management',
        'input-validation': 'input_validation',
        'validation-failure': 'input_validation',
        'business-logic': 'business_logic',
        'logic-flaw': 'business_logic',
        'information-disclosure': 'info_disclosure',
        'disclosure-case': 'info_disclosure',
        'weak-cryptography': 'weak_crypto',
        'cryptography-example': 'weak_crypto',
        'insecure-communication': 'insecure_communication',
        'communication-study': 'insecure_communication',
        'third-party-component': 'third_party',
        'component-vulnerability': 'third_party',
        'supply-chain': 'supply_chain',
        'attack-case': 'supply_chain',
        'zero-trust': 'zero_trust_bypass',
        'bypass-analysis': 'zero_trust_bypass',
        'multi-factor': 'mfa_bypass',
        'privilege-escalation': 'privilege_escalation',
        'escalation-case': 'privilege_escalation',
        'lateral-movement': 'lateral_movement',
        'movement-study': 'lateral_movement',
        'data-exfiltration': 'data_exfiltration',
        'exfiltration-method': 'data_exfiltration',
        'persistence-mechanism': 'persistence',
        'mechanism-analysis': 'persistence',
        'anti-forensic': 'anti_forensic',
        'technique-study': 'anti_forensic',
        'incident-response': 'incident_response',
        'response-failure': 'incident_response',
        'compliance-violation': 'compliance',
        'violation-case': 'compliance',
        'post-mortem': 'post_mortem',
        'analysis': 'post_mortem',
    }
    slug_lower = slug.lower()
    for key, val in mapping.items():
        if key in slug_lower:
            return val
    return 'post_mortem'

def detect_attack_vector(content: str, slug: str) -> str:
    text = (slug + ' ' + content).lower()
    vectors = {
        'phishing': ['phishing', 'spear-phishing', 'email attack'],
        'exploit': ['exploit', 'cve', 'vulnerability exploit'],
        'misconfiguration': ['misconfiguration', 'config error', 'default config'],
        'insider': ['insider', 'internal threat', 'employee'],
        'supply_chain': ['supply chain', 'dependency', 'compromised update'],
        'physical': ['physical', 'tailgating', 'lockpicking'],
        'social_engineering': ['social engineering', 'pretexting', 'vishing'],
        'brute_force': ['brute force', 'password spray', 'credential stuffing'],
        'zero_day': ['zero-day', 'zero day', '0-day', 'unknown vulnerability'],
        'malware': ['malware', 'trojan', 'virus'],
        'ransomware': ['ransomware', 'encrypt', 'ransom'],
        'apt': ['apt', 'advanced persistent', 'nation-state'],
        'opportunistic': ['opportunistic', 'random', 'automated scan'],
    }
    for vector, keywords in vectors.items():
        for kw in keywords:
            if kw in text:
                return vector
    return 'exploit'

def detect_severity(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['critical', 'catastrophic', 'devastating']):
        return 'critical'
    if any(kw in text for kw in ['high', 'severe', 'major']):
        return 'high'
    if any(kw in text for kw in ['medium', 'moderate']):
        return 'medium'
    if any(kw in text for kw in ['low', 'minor']):
        return 'low'
    return 'info'

def detect_impact_scope(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['global', 'worldwide', 'international']):
        return 'global'
    if any(kw in text for kw in ['regional', 'country', 'nation']):
        return 'regional'
    if any(kw in text for kw in ['industry', 'sector', 'vertical']):
        return 'industry'
    if any(kw in text for kw in ['enterprise', 'large corporation', 'fortune']):
        return 'enterprise'
    return 'small_business'

def extract_industries(content: str) -> list:
    text = content.lower()
    industries = []
    industry_keywords = [
        'healthcare', 'finance', 'banking', 'technology', 'retail',
        'education', 'government', 'energy', 'manufacturing', 'telecom',
        'media', 'transportation', 'defense', 'agriculture', 'real estate'
    ]
    for industry in industry_keywords:
        if industry in text:
            industries.append(industry)
    return industries if industries else ['technology']

def extract_timeline(content: str) -> dict:
    text = content.lower()
    days_match = re.search(r'(\d+)\s*(?:days?|hours?|weeks?|months?)\s*(?:to fix|to patch|disclosure)', text)
    discovery_days = int(days_match.group(1)) if days_match else 30
    
    disclosure = 'coordinated'
    if 'responsible disclosure' in text:
        disclosure = 'responsible'
    elif 'full disclosure' in text:
        disclosure = 'full_disclosure'
    
    return {
        "discovery_to_fix_days": discovery_days,
        "disclosure_type": disclosure
    }

def extract_financial_impact(content: str) -> dict:
    text = content.lower()
    
    estimated_match = re.search(r'\$(\d+(?:\.\d+)?)\s*(?:million|billion|M|B)', text)
    estimated = 0
    if estimated_match:
        val = float(estimated_match.group(1))
        if 'billion' in text or 'B' in text:
            estimated = int(val * 1e9)
        elif 'million' in text or 'M' in text:
            estimated = int(val * 1e6)
        else:
            estimated = int(val)
    
    bounty_match = re.search(r'bounty.*?\$(\d+)', text)
    bounty = int(bounty_match.group(1)) if bounty_match else 0
    
    recovery_match = re.search(r'recovery.*?\$(\d+)', text)
    recovery = int(recovery_match.group(1)) if recovery_match else 0
    
    return {
        "estimated_usd": estimated,
        "bounty_paid": bounty,
        "recovery_cost": recovery
    }

def extract_lessons_learned(content: str) -> list:
    lessons = []
    lines = content.split('\n')
    in_lessons = False
    for line in lines:
        if 'lesson' in line.lower() or 'takeaway' in line.lower():
            in_lessons = True
            continue
        if in_lessons:
            if line.startswith('#') or line.startswith('---'):
                in_lessons = False
                continue
            if line.startswith('-') or line.startswith('*'):
                lesson = re.sub(r'^[-*]\s*', '', line).strip()
                if lesson:
                    lessons.append(lesson)
    return lessons[:10] if lessons else ["Improve security awareness"]

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'breach', 'incident', 'case-study', 'real-world', 'disclosed',
        'apt', 'ransomware', 'data-leak', 'compromise', 'zero-day'
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

### Step 2: Build Case Index

```python
class CaseIndex:
    def __init__(self):
        self.primary = {}
        self.by_category = {}
        self.by_attack_vector = {}
        self.by_severity = {}
        self.by_impact_scope = {}
        self.by_industry = {}
    
    def add(self, doc: dict):
        cid = doc['case_id']
        self.primary[cid] = doc
        
        self.by_category.setdefault(doc['category'], []).append(cid)
        self.by_attack_vector.setdefault(doc['attack_vector'], []).append(cid)
        self.by_severity.setdefault(doc['severity'], []).append(cid)
        self.by_impact_scope.setdefault(doc['impact_scope'], []).append(cid)
        
        for industry in doc['industries_affected']:
            self.by_industry.setdefault(industry, []).append(cid)
    
    def find_by_category(self, category: str) -> list:
        cids = self.by_category.get(category, [])
        return [self.primary[cid] for cid in cids]
    
    def find_by_attack_vector(self, vector: str) -> list:
        cids = self.by_attack_vector.get(vector, [])
        return [self.primary[cid] for cid in cids]
    
    def find_by_industry(self, industry: str) -> list:
        cids = self.by_industry.get(industry, [])
        return [self.primary[cid] for cid in cids]
    
    def find_cloud_breach_cases(self) -> list:
        results = []
        for cid, doc in self.primary.items():
            if 'cloud' in doc['case_title'].lower() or 'cloud' in ' '.join(doc.get('tags', [])):
                results.append(doc)
        return results
    
    def find_ransomware_cases(self) -> list:
        cids = self.by_attack_vector.get('ransomware', [])
        return [self.primary[cid] for cid in cids]
    
    def get_category_stats(self) -> dict:
        stats = {}
        for cat, cids in self.by_category.items():
            severities = [self.primary[cid]['severity'] for cid in cids]
            financial = sum(self.primary[cid]['financial_impact']['estimated_usd'] for cid in cids)
            stats[cat] = {
                "count": len(cids),
                "avg_severity": severities[0] if severities else 'info',
                "total_financial_impact": financial
            }
        return stats
```

### Step 3: Persist Index

```python
import json
from datetime import datetime

def persist_case_index(index: CaseIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "high-level-world-case-studies",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_category": index.by_category,
            "by_attack_vector": index.by_attack_vector,
            "by_severity": index.by_severity,
            "by_impact_scope": index.by_impact_scope,
            "by_industry": index.by_industry,
        },
        "stats": index.get_category_stats()
    }
    
    index_file = output_dir / "case-studies-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Cases by Category

```python
def find_cases_by_category(index: CaseIndex, category: str) -> list:
    return index.find_by_category(category)
```

### Query 2: Find Cloud Breach Cases

```python
def find_cloud_breach_cases(index: CaseIndex) -> list:
    return index.find_cloud_breach_cases()
```

### Query 3: Find Ransomware Cases

```python
def find_ransomware_cases(index: CaseIndex) -> list:
    return index.find_ransomware_cases()
```

### Query 4: Find by Industry

```python
def find_by_industry(index: CaseIndex, industry: str) -> list:
    return index.find_by_industry(industry)
```

### Query 5: Find Critical Incidents

```python
def find_critical_incidents(index: CaseIndex) -> list:
    cids = index.by_severity.get('critical', [])
    return [index.primary[cid] for cid in cids]
```

### Query 6: Get Category Stats

```python
def get_category_stats(index: CaseIndex) -> dict:
    return index.get_category_stats()
```

### Query 7: Composite Query

```python
def case_composite_query(index: CaseIndex, **kwargs) -> list:
    candidate_sets = []
    
    if 'category' in kwargs:
        candidate_sets.append(set(index.by_category.get(kwargs['category'], [])))
    if 'attack_vector' in kwargs:
        candidate_sets.append(set(index.by_attack_vector.get(kwargs['attack_vector'], [])))
    if 'severity' in kwargs:
        candidate_sets.append(set(index.by_severity.get(kwargs['severity'], [])))
    if 'impact_scope' in kwargs:
        candidate_sets.append(set(index.by_impact_scope.get(kwargs['impact_scope'], [])))
    if 'industry' in kwargs:
        candidate_sets.append(set(index.by_industry.get(kwargs['industry'], [])))
    
    if not candidate_sets:
        return list(index.primary.values())
    
    intersection = candidate_sets[0]
    for s in candidate_sets[1:]:
        intersection &= s
    
    return [index.primary[cid] for cid in intersection]
```

---

## Search Algorithms

### Case Relevance Scoring

```python
class CaseScorer:
    def __init__(self, index: CaseIndex):
        self.index = index
    
    def score_case(self, doc: dict, query: dict) -> float:
        """
        Composite relevance score for case records.
        
        Components:
        - Category match: 0.0-0.30
        - Attack vector match: 0.0-0.25
        - Industry match: 0.0-0.20
        - Severity match: 0.0-0.15
        - Financial impact: 0.0-0.10
        """
        score = 0.0
        
        if 'category' in query and doc['category'] == query['category']:
            score += 0.30
        if 'attack_vector' in query and doc['attack_vector'] == query['attack_vector']:
            score += 0.25
        if 'industry' in query and query['industry'] in doc['industries_affected']:
            score += 0.20
        if 'severity' in query:
            sev_order = ['info', 'low', 'medium', 'high', 'critical']
            if sev_order.index(doc['severity']) >= sev_order.index(query['severity']):
                score += 0.15
        
        if doc['financial_impact']['estimated_usd'] > 0:
            score += 0.10
        
        return min(score, 1.0)
    
    def rank_cases(self, query: dict) -> list:
        results = []
        for cid, doc in self.index.primary.items():
            score = self.score_case(doc, query)
            doc_copy = doc.copy()
            doc_copy['relevance_score'] = score
            results.append(doc_copy)
        results.sort(key=lambda x: x['relevance_score'], reverse=True)
        return results
```

### BM25 Search

```python
import math

class CaseBM25:
    def __init__(self, index: CaseIndex, k1: float = 1.5, b: float = 0.75):
        self.index = index
        self.k1 = k1
        self.b = b
        self.avg_dl = self._compute_avg_dl()
    
    def _tokenize(self, text: str) -> list:
        import re
        tokens = re.findall(r'[a-z0-9]+', text.lower())
        stopwords = {'the', 'a', 'an', 'is', 'are', 'in', 'on', 'for', 'of', 'and', 'or', 'to'}
        return [t for t in tokens if t not in stopwords]
    
    def _compute_avg_dl(self) -> float:
        total = 0
        for doc in self.index.primary.values():
            text = f"{doc['case_title']} {doc['category']} {doc['attack_vector']} {' '.join(doc.get('tags', []))}"
            total += len(self._tokenize(text))
        return total / max(len(self.index.primary), 1)
    
    def search(self, query: str) -> list:
        query_tokens = self._tokenize(query)
        scores = []
        
        for cid, doc in self.index.primary.items():
            text = f"{doc['case_title']} {doc['category']} {doc['attack_vector']} {' '.join(doc.get('tags', []))}"
            doc_tokens = self._tokenize(text)
            doc_len = len(doc_tokens)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                df = sum(1 for d in self.index.primary.values() 
                         if qt in f"{d['case_title']} {d['category']}".lower())
                idf = math.log((len(self.index.primary) - df + 0.5) / (df + 0.5) + 1)
                numerator = tf * (self.k1 + 1)
                denominator = tf + self.k1 * (1 - self.b + self.b * doc_len / self.avg_dl)
                score += idf * numerator / denominator
            
            if score > 0:
                scores.append((cid, score))
        
        scores.sort(key=lambda x: x[1], reverse=True)
        return [(cid, s, self.index.primary[cid]) for cid, s in scores]
```

### Timeline Analysis

```python
class TimelineAnalyzer:
    def __init__(self, index: CaseIndex):
        self.index = index
    
    def analyze_fix_times(self) -> dict:
        """Analyze discovery-to-fix timelines across all cases."""
        fix_times = {}
        for cid, doc in self.index.primary.items():
            category = doc['category']
            days = doc['timeline']['discovery_to_fix_days']
            if category not in fix_times:
                fix_times[category] = []
            fix_times[category].append(days)
        
        stats = {}
        for cat, times in fix_times.items():
            stats[cat] = {
                "avg_days": sum(times) / max(len(times), 1),
                "min_days": min(times),
                "max_days": max(times),
                "count": len(times)
            }
        return stats
    
    def find_slowest_fixes(self, top_n: int = 10) -> list:
        cases = []
        for cid, doc in self.index.primary.items():
            cases.append(doc)
        cases.sort(key=lambda x: x['timeline']['discovery_to_fix_days'], reverse=True)
        return cases[:top_n]
    
    def find_fastest_fixes(self, top_n: int = 10) -> list:
        cases = []
        for cid, doc in self.index.primary.items():
            cases.append(doc)
        cases.sort(key=lambda x: x['timeline']['discovery_to_fix_days'])
        return cases[:top_n]
```

---

## Relevance Scoring

```python
def compute_case_relevance(doc: dict, query: dict) -> float:
    """
    Composite relevance score for case records.
    
    Components:
    - Category match: 0.0-0.30
    - Attack vector match: 0.0-0.25
    - Industry match: 0.0-0.20
    - Severity match: 0.0-0.15
    - Financial impact: 0.0-0.10
    """
    score = 0.0
    
    if 'category' in query and doc['category'] == query['category']:
        score += 0.30
    if 'attack_vector' in query and doc['attack_vector'] == query['attack_vector']:
        score += 0.25
    if 'industry' in query and query['industry'] in doc['industries_affected']:
        score += 0.20
    if 'severity' in query:
        sev_order = ['info', 'low', 'medium', 'high', 'critical']
        if sev_order.index(doc['severity']) >= sev_order.index(query['severity']):
            score += 0.15
    
    return min(score, 1.0)
```

---

## Index Maintenance

### Incremental Update

```python
def update_case_index(index: CaseIndex, new_file: Path):
    """Add a new case to the index without rebuilding."""
    doc = extract_case_metadata(new_file)
    index.add(doc)

def remove_case(index: CaseIndex, case_id: str):
    """Remove a case and clean all inverted indexes."""
    if case_id not in index.primary:
        return
    doc = index.primary[case_id]
    
    for idx_map in [index.by_category, index.by_attack_vector, index.by_severity, index.by_impact_scope]:
        for key, cids in idx_map.items():
            if case_id in cids:
                cids.remove(case_id)
                if not cids:
                    del idx_map[key]
    
    for industry in doc['industries_affected']:
        if industry in index.by_industry and case_id in index.by_industry[industry]:
            index.by_industry[industry].remove(case_id)
            if not index.by_industry[industry]:
                del index.by_industry[industry]
    
    del index.primary[case_id]
```

### Integrity Verification

```python
def verify_case_index(index: CaseIndex) -> dict:
    """Verify index consistency and report issues."""
    issues = []
    
    required_fields = ['case_id', 'category', 'attack_vector', 'severity', 'impact_scope']
    for cid, doc in index.primary.items():
        for field in required_fields:
            if field not in doc:
                issues.append(f"Case {cid} missing field: {field}")
    
    for cid_list in index.by_category.values():
        for cid in cid_list:
            if cid not in index.primary:
                issues.append(f"by_category has orphan reference: {cid}")
    
    for cid_list in index.by_attack_vector.values():
        for cid in cid_list:
            if cid not in index.primary:
                issues.append(f"by_attack_vector has orphan reference: {cid}")
    
    return {
        "total_cases": len(index.primary),
        "issues": issues,
        "healthy": len(issues) == 0
    }
```

### Rebuild Strategy

```python
def rebuild_case_index(domain_path: Path, output_dir: Path):
    """Full index rebuild from source files."""
    index = CaseIndex()
    
    for filepath in sorted(domain_path.glob("*.md")):
        if filepath.name == "README.md":
            continue
        doc = extract_case_metadata(filepath)
        index.add(doc)
    
    persist_case_index(index, output_dir)
    
    stats = {
        "total": len(index.primary),
        "by_category": {k: len(v) for k, v in index.by_category.items()},
        "by_attack_vector": {k: len(v) for k, v in index.by_attack_vector.items()},
        "by_severity": {k: len(v) for k, v in index.by_severity.items()},
        "by_impact_scope": {k: len(v) for k, v in index.by_impact_scope.items()},
    }
    return stats
```

---

## Full Domain File References

### Case Study Modules (HC-05 through HC-50)

| # | File | Case ID | Category | Attack Vector | Severity | Impact Scope |
|---|------|---------|----------|---------------|----------|-------------|
| 05 | `05-Critical-Infrastructure-Breach.md` | HC-05 | critical_infrastructure | apt | critical | global |
| 06 | `06-Zero-Day-Exploitation-Case.md` | HC-06 | zero_day | zero_day | critical | industry |
| 07 | `07-Chain-of-Vulnerabilities.md` | HC-07 | vulnerability_chain | exploit | high | enterprise |
| 08 | `08-Real-World-Impact-Assessment.md` | HC-08 | impact_assessment | exploit | high | enterprise |
| 09 | `09-Timeline-from-Discovery-to-Fix.md` | HC-09 | timeline | exploit | medium | enterprise |
| 10 | `10-Reward-Maximization-Strategies.md` | HC-10 | reward_strategy | exploit | info | industry |
| 11 | `11-Report-Quality-Analysis.md` | HC-11 | report_quality | exploit | info | industry |
| 12 | `12-Triage-Process-Understanding.md` | HC-12 | triage | exploit | info | industry |
| 13 | `13-Program-Response-Analysis.md` | HC-13 | program_response | exploit | info | industry |
| 14 | `14-Disclosure-Timeline-Study.md` | HC-14 | disclosure | exploit | info | industry |
| 15 | `15-Collaborative-Hunting-Case.md` | HC-15 | collaborative | exploit | medium | industry |
| 16 | `16-Cross-Program-Vulnerability-Patterns.md` | HC-16 | cross_program | exploit | medium | industry |
| 17 | `17-Industry-Specific-Findings.md` | HC-17 | industry_specific | exploit | medium | industry |
| 18 | `18-Mobile-App-Vulnerability-Case.md` | HC-18 | mobile | exploit | high | enterprise |
| 19 | `19-Web-Application-Security-Case.md` | HC-19 | web_application | exploit | high | enterprise |
| 20 | `20-API-Security-Breach-Analysis.md` | HC-20 | api_breach | exploit | high | enterprise |
| 21 | `21-Cloud-Configuration-Error.md` | HC-21 | cloud_error | misconfiguration | high | enterprise |
| 22 | `22-Container-Escape-Case-Study.md` | HC-22 | container_escape | exploit | critical | enterprise |
| 23 | `23-IoT-Device-Compromise.md` | HC-23 | iot | exploit | high | industry |
| 24 | `24-Blockchain-Smart-Contract-Bug.md` | HC-24 | blockchain | exploit | high | industry |
| 25 | `25-Cryptocurrency-Exchange-Hack.md` | HC-25 | cryptocurrency | exploit | critical | global |
| 26 | `26-Social-Engineering-Success.md` | HC-26 | social_engineering | social_engineering | high | enterprise |
| 27 | `27-Physical-Security-Bypass.md` | HC-27 | physical_security | physical | high | enterprise |
| 28 | `28-Network-Infrastructure-Attack.md` | HC-28 | network_infrastructure | exploit | high | enterprise |
| 29 | `29-Database-Compromise-Case.md` | HC-29 | database | exploit | high | enterprise |
| 30 | `30-File-System-Attack-Analysis.md` | HC-30 | file_system | exploit | medium | enterprise |
| 31 | `31-Authentication-Bypass-Case.md` | HC-31 | auth_bypass | exploit | high | enterprise |
| 32 | `32-Authorization-Flaw-Study.md` | HC-32 | authorization | exploit | high | enterprise |
| 33 | `33-Session-Management-Issue.md` | HC-33 | session_management | exploit | medium | enterprise |
| 34 | `34-Input-Validation-Failure.md` | HC-34 | input_validation | exploit | medium | enterprise |
| 35 | `35-Business-Logic-Flaw-Analysis.md` | HC-35 | business_logic | exploit | high | enterprise |
| 36 | `36-Information-Disclosure-Case.md` | HC-36 | info_disclosure | exploit | medium | enterprise |
| 37 | `37-Weak-Cryptography-Example.md` | HC-37 | weak_crypto | exploit | medium | enterprise |
| 38 | `38-Insecure-Communication-Study.md` | HC-38 | insecure_communication | exploit | medium | enterprise |
| 39 | `39-Third-Party-Component-Vulnerability.md` | HC-39 | third_party | supply_chain | high | industry |
| 40 | `40-Supply-Chain-Attack-Case.md` | HC-40 | supply_chain | supply_chain | critical | global |
| 41 | `41-Zero-Trust-Bypass-Analysis.md` | HC-41 | zero_trust_bypass | exploit | high | enterprise |
| 42 | `42-Multi-Factor-Authentication-Bypass.md` | HC-42 | mfa_bypass | exploit | high | enterprise |
| 43 | `43-Privilege-Escalation-Case.md` | HC-43 | privilege_escalation | exploit | high | enterprise |
| 44 | `44-Lateral-Movement-Study.md` | HC-44 | lateral_movement | exploit | high | enterprise |
| 45 | `45-Data-Exfiltration-Method.md` | HC-45 | data_exfiltration | exploit | high | enterprise |
| 46 | `46-Persistence-Mechanism-Analysis.md` | HC-46 | persistence | exploit | high | enterprise |
| 47 | `47-Anti-Forensic-Technique-Study.md` | HC-47 | anti_forensic | apt | high | enterprise |
| 48 | `48-Incident-Response-Failure.md` | HC-48 | incident_response | exploit | high | enterprise |
| 49 | `49-Compliance-Violation-Case.md` | HC-49 | compliance | exploit | medium | industry |
| 50 | `50-Post-Mortem-Analysis.md` | HC-50 | post_mortem | exploit | info | industry |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and case study methodology |
| `registry.json` | Machine-readable case registry |

---

## Cross-Domain References

- **real-world-case-studies.md** — Detailed reports validate high-level case analysis.
- **core-prompts-hunting.md** — Hunting findings connect to case study patterns.
- **report-writing-mastery.md** — Case studies inform report writing standards.
- **high-level-world-case-studies.md** — Self-referential for methodology consistency.

---

## Usage Examples

### Example 1: Find Ransomware Cases

```python
results = find_ransomware_cases(index)
# Returns cases where attack_vector == 'ransomware'
```

### Example 2: Find Cloud Breach Cases

```python
results = find_cloud_breach_cases(index)
# Returns cases with 'cloud' in title or tags
```

### Example 3: Find Healthcare Cases

```python
results = find_by_industry(index, 'healthcare')
# Returns cases affecting healthcare industry
```

### Example 4: Find Critical Supply Chain Cases

```python
results = case_composite_query(index, category='supply_chain', severity='critical')
# Returns: HC-40
```

### Example 5: Get Category Statistics

```python
stats = get_category_stats(index)
# Returns: {supply_chain: {count: 1, total_financial_impact: ...}, ...}
```

### Example 6: Find Slowest Fixes

```python
analyzer = TimelineAnalyzer(index)
slow = analyzer.find_slowest_fixes(top_n=5)
# Returns top 5 cases with longest discovery-to-fix times
```

### Example 7: Text Search for "APT breach"

```python
bm25 = CaseBM25(index)
results = bm25.search("apt breach nation state")
# Returns ranked list of cases matching the query
```
