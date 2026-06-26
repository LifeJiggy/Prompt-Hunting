# Bug Bounty Program Strategy — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `bug-bounty-program-strategy` |
| Root Path | `Bug-Bounty-Program-Strategy/` |
| File Count | 50 primary files + README + registry.json |
| Index Type | Program-centric (score, platform, bounty, scope) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Bug Bounty Program Strategy domain index manages metadata for 50 modules covering program selection, time management, ROI optimization, scope assessment, reward analysis, collaboration, and long-term strategy. Each file represents a strategic component for maximizing bug bounty income and efficiency. The index enables lookup by program criteria, bounty range, platform, and strategy type.

This index supports two primary query patterns:
1. **Find top programs** — given score criteria (reward, response time, scope), retrieve programs ranked by composite score.
2. **Find programs by criteria** — given specific filters (platform, bounty range, specialization), retrieve matching programs.

---

## Index Schema

### Primary Index: `strategy_records`

```json
{
  "doc_type": "strategy_record",
  "file_ref": "Bug-Bounty-Program-Strategy/<filename>.md",
  "module_id": "BS-<number>",
  "module_title": "<title>",
  "category": "enum[selection|time_management|roi|reputation|reward|scope|response|collaboration|private_program|vdi|seasonal|maturity|trend|expansion|communication|duplicate_avoidance|rules|negotiation|health|relationship|launch|competition|specialization|risk|timezone|diversity|consistency|exit|feedback|intelligence|network|influence|prediction|saturation|seasoned|forecast|resource_allocation|success_metrics|advanced_selection|relationship_management|collaboration_roi|discovery|scope_analysis|performance_tracking|reward_maximization|specialization_deep_dive|time_investment|network_optimization|advanced_strategy]",
  "strategy_type": "enum[offensive|defensive|analytical|collaborative|meta]",
  "platforms": ["enum[hackerone|bugcrowd|intigriti|yeswehack|synack|open_bounty|custom]"],
  "bounty_range": {
    "min_usd": "integer",
    "max_usd": "integer",
    "typical_usd": "integer"
  },
  "program_characteristics": {
    "response_time_days": "float",
    "triage_quality": "enum[excellent|good|average|poor]",
    "scope_breadth": "enum[narrow|moderate|wide|very_wide]",
    "competition_level": "enum[low|moderate|high|saturated]",
    "repeat_hunter_friendly": "boolean"
  },
  "roi_metrics": {
    "hours_per_report": "float",
    "reports_per_week": "float",
    "avg_payout": "float",
    "roi_ratio": "float"
  },
  "applicable_to": "enum[new_hunter|intermediate|advanced|expert|all]",
  "time_investment": "enum[low|moderate|high|very_high]",
  "tags": ["string"],
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `platform_index`

```json
{
  "platform": "string",
  "modules": ["BS-<number>"],
  "avg_bounty": "float",
  "avg_response_time": "float"
}
```

### Tertiary Index: `category_index`

```json
{
  "category": "string",
  "modules": ["BS-<number>"],
  "applicable_levels": ["string"]
}
```

---

## Index Creation

```python
import re
from pathlib import Path
from datetime import datetime

def extract_strategy_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    module_num = int(match.group(1)) if match else 0
    module_slug = match.group(2) if match else filename
    
    category = classify_strategy_category(module_slug)
    strategy_type = detect_strategy_type(content, module_slug)
    platforms = extract_platforms(content)
    bounty_range = extract_bounty_range(content)
    program_chars = extract_program_characteristics(content)
    roi = extract_roi_metrics(content)
    level = detect_applicable_level(content)
    time_invest = detect_time_investment(content)
    
    return {
        "doc_type": "strategy_record",
        "file_ref": f"Bug-Bounty-Program-Strategy/{filepath.name}",
        "module_id": f"BS-{module_num:02d}",
        "module_title": format_title(module_slug),
        "category": category,
        "strategy_type": strategy_type,
        "platforms": platforms,
        "bounty_range": bounty_range,
        "program_characteristics": program_chars,
        "roi_metrics": roi,
        "applicable_to": level,
        "time_investment": time_invest,
        "tags": extract_tags(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_strategy_category(slug: str) -> str:
    mapping = {
        'selection': 'selection', 'time-management': 'time_management',
        'roi': 'roi', 'reputation': 'reputation', 'reward': 'reward',
        'scope': 'scope', 'response': 'response', 'collaboration': 'collaboration',
        'private': 'private_program', 'vdi': 'vdi', 'seasonal': 'seasonal',
        'maturity': 'maturity', 'trend': 'trend', 'expansion': 'expansion',
        'communication': 'communication', 'duplicate': 'duplicate_avoidance',
        'rules': 'rules', 'negotiation': 'negotiation', 'health': 'health',
        'relationship': 'relationship', 'launch': 'launch',
        'competition': 'competition', 'specialization': 'specialization',
        'risk': 'risk', 'timezone': 'timezone', 'diversity': 'diversity',
        'consistency': 'consistency', 'exit': 'exit', 'feedback': 'feedback',
        'intelligence': 'intelligence', 'network': 'network',
        'influence': 'influence', 'prediction': 'prediction',
        'saturation': 'saturation', 'seasoned': 'seasoned',
        'forecast': 'forecast', 'resource': 'resource_allocation',
        'success': 'success_metrics', 'advanced-selection': 'advanced_selection',
        'relationship-management': 'relationship_management',
        'collaboration-roi': 'collaboration_roi', 'discovery': 'discovery',
        'scope-analysis': 'scope_analysis', 'performance': 'performance_tracking',
        'reward-maximization': 'reward_maximization',
        'specialization-deep': 'specialization_deep_dive',
        'time-investment': 'time_investment',
        'network-optimization': 'network_optimization',
        'advanced-strategy': 'advanced_strategy',
    }
    slug_lower = slug.lower()
    for key, val in mapping.items():
        if key in slug_lower:
            return val
    return 'selection'

def detect_strategy_type(content: str, slug: str) -> str:
    text = (slug + ' ' + content).lower()
    if any(kw in text for kw in ['offensive', 'attack', 'hunt', 'exploit']):
        return 'offensive'
    if any(kw in text for kw in ['defensive', 'protect', 'mitigate']):
        return 'defensive'
    if any(kw in text for kw in ['analyz', 'data', 'metric', 'trend']):
        return 'analytical'
    if any(kw in text for kw in ['collaborate', 'team', 'partner']):
        return 'collaborative'
    return 'meta'

def extract_platforms(content: str) -> list:
    text = content.lower()
    platforms = []
    platform_map = {
        'hackerone': ['hackerone', 'hacker one'],
        'bugcrowd': ['bugcrowd'],
        'intigriti': ['intigriti'],
        'yeswehack': ['yeswehack', 'yes we hack'],
        'synack': ['synack'],
        'open_bounty': ['open bounty', 'openbounty'],
    }
    for plat, keywords in platform_map.items():
        for kw in keywords:
            if kw in text:
                platforms.append(plat)
                break
    return platforms if platforms else ['custom']

def extract_bounty_range(content: dict) -> dict:
    text = content.lower() if isinstance(content, str) else ''
    min_match = re.search(r'\$(\d+)\s*(?:to|-|minimum|min)', text)
    max_match = re.search(r'(?:to|-|maximum|max)\s*\$(\d+)', text)
    typical_match = re.search(r'typical.*?\$(\d+)', text)
    
    return {
        "min_usd": int(min_match.group(1)) if min_match else 100,
        "max_usd": int(max_match.group(1)) if max_match else 10000,
        "typical_usd": int(typical_match.group(1)) if typical_match else 500
    }

def extract_program_characteristics(content: str) -> dict:
    text = content.lower()
    
    response_match = re.search(r'response.*?(\d+(?:\.\d+)?)\s*(?:days?|hours?)', text)
    response_days = float(response_match.group(1)) if response_match else 7.0
    if 'hours' in (response_match.group(0) if response_match else ''):
        response_days /= 24.0
    
    triage = 'average'
    if any(kw in text for kw in ['excellent triage', 'fast triage']):
        triage = 'excellent'
    elif 'good triage' in text:
        triage = 'good'
    elif 'poor triage' in text:
        triage = 'poor'
    
    scope = 'moderate'
    if 'wide scope' in text or 'broad scope' in text:
        scope = 'wide'
    elif 'very wide' in text or 'extensive scope' in text:
        scope = 'very_wide'
    elif 'narrow scope' in text:
        scope = 'narrow'
    
    competition = 'moderate'
    if 'saturated' in text or 'highly competitive' in text:
        competition = 'saturated'
    elif 'high competition' in text:
        competition = 'high'
    elif 'low competition' in text or 'less competitive' in text:
        competition = 'low'
    
    return {
        "response_time_days": response_days,
        "triage_quality": triage,
        "scope_breadth": scope,
        "competition_level": competition,
        "repeat_hunter_friendly": 'repeat' in text or 'returning' in text
    }

def extract_roi_metrics(content: str) -> dict:
    text = content.lower()
    hours_match = re.search(r'(\d+(?:\.\d+)?)\s*hours?\s*(?:per|/)\s*report', text)
    reports_match = re.search(r'(\d+(?:\.\d+)?)\s*reports?\s*(?:per|/)\s*week', text)
    payout_match = re.search(r'avg.*?\$(\d+)', text)
    roi_match = re.search(r'roi.*?(\d+(?:\.\d+)?)\s*x', text)
    
    return {
        "hours_per_report": float(hours_match.group(1)) if hours_match else 10.0,
        "reports_per_week": float(reports_match.group(1)) if reports_match else 2.0,
        "avg_payout": float(payout_match.group(1)) if payout_match else 500.0,
        "roi_ratio": float(roi_match.group(1)) if roi_match else 3.0
    }

def detect_applicable_level(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['expert', 'advanced hunter', 'experienced']):
        return 'advanced'
    if 'intermediate' in text:
        return 'intermediate'
    if any(kw in text for kw in ['beginner', 'new hunter', 'getting started']):
        return 'new_hunter'
    return 'all'

def detect_time_investment(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['quick', 'minimal time', 'low effort']):
        return 'low'
    if any(kw in text for kw in ['significant time', 'high investment']):
        return 'high'
    if any(kw in text for kw in ['major time', 'very high', 'extensive']):
        return 'very_high'
    return 'moderate'

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'strategy', 'optimization', 'analysis', 'collaboration',
        'program-selection', 'bounty-maximization', 'scope-analysis',
        'time-management', 'roi', 'competition', 'seasonal'
    ]
    text = content.lower()
    for tag in tag_keywords:
        if tag in text or tag.replace('-', ' ') in text:
            tags.append(tag)
    return tags

def format_title(slug: str) -> str:
    return slug.replace('-', ' ').title()

def extract_date(content: str) -> str:
    match = re.search(r'(\d{4}-\d{2}-\d{2})', content)
    return match.group(1) if match else datetime.now().isoformat()
```

### Build Strategy Index

```python
class StrategyIndex:
    def __init__(self):
        self.primary = {}
        self.by_category = {}
        self.by_platform = {}
        self.by_strategy_type = {}
        self.by_level = {}
        self.by_time_investment = {}
        self.by_competition = {}
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        self.by_category.setdefault(doc['category'], []).append(mid)
        
        for plat in doc['platforms']:
            self.by_platform.setdefault(plat, []).append(mid)
        
        self.by_strategy_type.setdefault(doc['strategy_type'], []).append(mid)
        self.by_level.setdefault(doc['applicable_to'], []).append(mid)
        self.by_time_investment.setdefault(doc['time_investment'], []).append(mid)
        
        comp = doc['program_characteristics']['competition_level']
        self.by_competition.setdefault(comp, []).append(mid)
    
    def find_top_programs(self, min_bounty: int = 0, 
                          max_competition: str = 'saturated',
                          platform: str = None) -> list:
        comp_order = ['low', 'moderate', 'high', 'saturated']
        max_idx = comp_order.index(max_competition)
        
        candidates = list(self.primary.keys())
        
        if platform:
            candidates = [mid for mid in candidates if platform in self.primary[mid]['platforms']]
        
        results = []
        for mid in candidates:
            doc = self.primary[mid]
            if doc['bounty_range']['typical_usd'] >= min_bounty:
                comp_idx = comp_order.index(doc['program_characteristics']['competition_level'])
                if comp_idx <= max_idx:
                    results.append(doc)
        
        results.sort(key=lambda x: x['roi_metrics']['roi_ratio'], reverse=True)
        return results
    
    def find_by_criteria(self, **kwargs) -> list:
        candidates = set(self.primary.keys())
        
        if 'platform' in kwargs:
            plat_set = set(self.by_platform.get(kwargs['platform'], []))
            candidates &= plat_set if plat_set else candidates
        
        if 'category' in kwargs:
            cat_set = set(self.by_category.get(kwargs['category'], []))
            candidates &= cat_set if cat_set else candidates
        
        if 'min_bounty' in kwargs:
            candidates = {mid for mid in candidates 
                         if self.primary[mid]['bounty_range']['typical_usd'] >= kwargs['min_bounty']}
        
        if 'max_bounty' in kwargs:
            candidates = {mid for mid in candidates 
                         if self.primary[mid]['bounty_range']['typical_usd'] <= kwargs['max_bounty']}
        
        if 'level' in kwargs:
            level_set = set(self.by_level.get(kwargs['level'], []))
            candidates &= level_set if level_set else candidates
        
        return [self.primary[mid] for mid in candidates]
```

### Persist Index

```python
import json
from datetime import datetime

def persist_strategy_index(index: StrategyIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "bug-bounty-program-strategy",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_category": index.by_category,
            "by_platform": index.by_platform,
            "by_strategy_type": index.by_strategy_type,
            "by_level": index.by_level,
            "by_time_investment": index.by_time_investment,
            "by_competition": index.by_competition,
        }
    }
    
    index_file = output_dir / "strategy-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Top Programs

```python
def find_top_programs(index: StrategyIndex, min_bounty: int = 500,
                      platform: str = None) -> list:
    return index.find_top_programs(min_bounty=min_bounty, platform=platform)
```

### Query 2: Find by Criteria

```python
def find_by_criteria(index: StrategyIndex, **kwargs) -> list:
    return index.find_by_criteria(**kwargs)
```

### Query 3: Find Low-Competition Programs

```python
def find_low_competition(index: StrategyIndex) -> list:
    mids = index.by_competition.get('low', [])
    return [index.primary[mid] for mid in mids]
```

### Query 4: Find Beginner-Friendly

```python
def find_beginner_friendly(index: StrategyIndex) -> list:
    mids = index.by_level.get('new_hunter', [])
    results = [index.primary[mid] for mid in mids]
    results.sort(key=lambda x: x['roi_metrics']['roi_ratio'], reverse=True)
    return results
```

### Query 5: Find Quick ROI

```python
def find_quick_roi(index: StrategyIndex, max_hours: float = 5.0) -> list:
    results = []
    for mid, doc in index.primary.items():
        if doc['roi_metrics']['hours_per_report'] <= max_hours:
            doc_copy = doc.copy()
            doc_copy['quick_roi_score'] = doc['roi_metrics']['roi_ratio'] / max(doc['roi_metrics']['hours_per_report'], 1)
            results.append(doc_copy)
    results.sort(key=lambda x: x['quick_roi_score'], reverse=True)
    return results
```

---

## Search Algorithms

### Composite Program Scoring

```python
class ProgramScorer:
    def __init__(self, index: StrategyIndex):
        self.index = index
    
    def score_program(self, doc: dict, priorities: dict = None) -> float:
        if priorities is None:
            priorities = {
                'bounty': 0.30,
                'response_time': 0.20,
                'competition': 0.20,
                'triage': 0.15,
                'roi': 0.15
            }
        
        bounty_norm = min(doc['bounty_range']['typical_usd'] / 5000.0, 1.0)
        
        response_norm = max(0, 1.0 - (doc['program_characteristics']['response_time_days'] / 30.0))
        
        comp_map = {'low': 1.0, 'moderate': 0.6, 'high': 0.3, 'saturated': 0.1}
        comp_norm = comp_map.get(doc['program_characteristics']['competition_level'], 0.5)
        
        triage_map = {'excellent': 1.0, 'good': 0.7, 'average': 0.4, 'poor': 0.1}
        triage_norm = triage_map.get(doc['program_characteristics']['triage_quality'], 0.5)
        
        roi_norm = min(doc['roi_metrics']['roi_ratio'] / 10.0, 1.0)
        
        score = (
            bounty_norm * priorities.get('bounty', 0.30) +
            response_norm * priorities.get('response_time', 0.20) +
            comp_norm * priorities.get('competition', 0.20) +
            triage_norm * priorities.get('triage', 0.15) +
            roi_norm * priorities.get('roi', 0.15)
        )
        
        return round(score, 4)
    
    def rank_all(self, priorities: dict = None) -> list:
        results = []
        for mid, doc in self.index.primary.items():
            score = self.score_program(doc, priorities)
            doc_copy = doc.copy()
            doc_copy['composite_score'] = score
            results.append(doc_copy)
        results.sort(key=lambda x: x['composite_score'], reverse=True)
        return results
```

### BM25 Search

```python
import math

class StrategyBM25:
    def __init__(self, index: StrategyIndex):
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
            text = f"{doc['module_title']} {doc['category']} {doc['strategy_type']} {' '.join(doc.get('tags', []))}"
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
def compute_strategy_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'platform' in query and query['platform'] in doc['platforms']:
        score += 0.25
    if 'category' in query and doc['category'] == query['category']:
        score += 0.20
    if 'min_bounty' in query:
        if doc['bounty_range']['typical_usd'] >= query['min_bounty']:
            score += 0.20
    if 'level' in query and doc['applicable_to'] == query['level']:
        score += 0.15
    
    score += doc['roi_metrics']['roi_ratio'] / 10.0 * 0.10
    
    comp_map = {'low': 0.10, 'moderate': 0.06, 'high': 0.03, 'saturated': 0.01}
    score += comp_map.get(doc['program_characteristics']['competition_level'], 0.05)
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_strategy_index(index: StrategyIndex, new_file: Path):
    doc = extract_strategy_metadata(new_file)
    index.add(doc)

def remove_module(index: StrategyIndex, module_id: str):
    if module_id not in index.primary:
        return
    doc = index.primary[module_id]
    
    for idx_map in [index.by_category, index.by_strategy_type, index.by_level,
                    index.by_time_investment, index.by_competition]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
    
    for plat in doc['platforms']:
        if plat in index.by_platform and module_id in index.by_platform[plat]:
            index.by_platform[plat].remove(module_id)
    
    del index.primary[module_id]

def verify_strategy_index(index: StrategyIndex) -> dict:
    issues = []
    for mid, doc in index.primary.items():
        if doc['bounty_range']['min_usd'] > doc['bounty_range']['max_usd']:
            issues.append(f"Module {mid} has invalid bounty range")
        if doc['roi_metrics']['hours_per_report'] <= 0:
            issues.append(f"Module {mid} has invalid hours_per_report")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Module ID | Category | Strategy Type | Level |
|---|------|-----------|----------|---------------|-------|
| 01 | `01-Program-Selection-Criteria.md` | BS-01 | selection | analytical | all |
| 02 | `02-Time-Management-Optimization.md` | BS-02 | time_management | meta | all |
| 03 | `03-ROI-Maximization-Strategies.md` | BS-03 | roi | analytical | intermediate |
| 04 | `04-Program-Reputation-Analysis.md` | BS-04 | reputation | analytical | intermediate |
| 05 | `05-Reward-Structure-Evaluation.md` | BS-05 | reward | analytical | all |
| 06 | `06-Scope-Assessment-Techniques.md` | BS-06 | scope | offensive | all |
| 07 | `07-Response-Time-Analysis.md` | BS-07 | response | analytical | all |
| 08 | `08-Collaboration-Opportunities.md` | BS-08 | collaboration | collaborative | all |
| 09 | `09-Private-vs-Public-Programs.md` | BS-09 | private_program | analytical | intermediate |
| 10 | `10-VDI-Program-Strategy.md` | BS-10 | vdi | analytical | advanced |
| 11 | `11-Seasonal-Program-Analysis.md` | BS-11 | seasonal | analytical | intermediate |
| 12 | `12-Program-Maturity-Assessment.md` | BS-12 | maturity | analytical | advanced |
| 13 | `13-Reward-Trends-Analysis.md` | BS-13 | trend | analytical | intermediate |
| 14 | `14-Program-Scope-Expansion.md` | BS-14 | expansion | offensive | advanced |
| 15 | `15-Communication-Channel-Optimization.md` | BS-15 | communication | collaborative | all |
| 16 | `16-Duplicate-Submission-Avoidance.md` | BS-16 | duplicate_avoidance | meta | all |
| 17 | `17-Program-Specific-Rules.md` | BS-17 | rules | meta | all |
| 18 | `18-Reward-Negotiation-Tactics.md` | BS-18 | negotiation | collaborative | advanced |
| 19 | `19-Program-Health-Monitoring.md` | BS-19 | health | analytical | intermediate |
| 20 | `20-Long-Term-Program-Relationships.md` | BS-20 | relationship | collaborative | advanced |
| 21 | `21-Program-Launch-Strategy.md` | BS-21 | launch | offensive | advanced |
| 22 | `22-Competition-Analysis.md` | BS-22 | competition | analytical | intermediate |
| 23 | `23-Program-Specialization.md` | BS-23 | specialization | analytical | intermediate |
| 24 | `24-Risk-Assessment-Per-Program.md` | BS-24 | risk | analytical | advanced |
| 25 | `25-Time-Zone-Optimization.md` | BS-25 | timezone | meta | all |
| 26 | `26-Program-Diversity-Strategy.md` | BS-26 | diversity | analytical | all |
| 27 | `27-Reward-Consistency-Analysis.md` | BS-27 | consistency | analytical | intermediate |
| 28 | `28-Program-Exit-Strategy.md` | BS-28 | exit | meta | advanced |
| 29 | `29-Program-Feedback-Analysis.md` | BS-29 | feedback | analytical | all |
| 30 | `30-Advanced-Program-Intelligence.md` | BS-30 | intelligence | analytical | expert |
| 31 | `31-Program-Network-Analysis.md` | BS-31 | network | analytical | advanced |
| 32 | `32-Collaboration-Network-Building.md` | BS-32 | network | collaborative | advanced |
| 33 | `33-Program-Influence-Strategies.md` | BS-33 | influence | collaborative | expert |
| 34 | `34-Reward-Prediction-Models.md` | BS-34 | prediction | analytical | expert |
| 35 | `35-Program-Saturation-Analysis.md` | BS-35 | saturation | analytical | advanced |
| 36 | `36-Seasoned-Hunter-Advantages.md` | BS-36 | seasoned | meta | advanced |
| 37 | `37-Program-Trend-Forecasting.md` | BS-37 | forecast | analytical | expert |
| 38 | `38-Resource-Allocation-Strategy.md` | BS-38 | resource_allocation | meta | advanced |
| 39 | `39-Program-Success-Metrics.md` | BS-39 | success_metrics | analytical | all |
| 40 | `40-Advanced-Program-Selection.md` | BS-40 | advanced_selection | analytical | expert |
| 41 | `41-Program-Relationship-Management.md` | BS-41 | relationship_management | collaborative | expert |
| 42 | `42-Collaboration-ROI-Analysis.md` | BS-42 | collaboration_roi | analytical | advanced |
| 43 | `43-Program-Discovery-Methods.md` | BS-43 | discovery | offensive | all |
| 44 | `44-Advanced-Scope-Analysis.md` | BS-44 | scope_analysis | offensive | expert |
| 45 | `45-Program-Performance-Tracking.md` | BS-45 | performance_tracking | analytical | advanced |
| 46 | `46-Reward-Maximization-Framework.md` | BS-46 | reward_maximization | analytical | expert |
| 47 | `47-Program-Specialization-Deep-Dive.md` | BS-47 | specialization_deep_dive | analytical | expert |
| 48 | `48-Time-Investment-ROI.md` | BS-48 | time_investment | analytical | intermediate |
| 49 | `49-Program-Network-Optimization.md` | BS-49 | network_optimization | analytical | expert |
| 50 | `50-Advanced-Program-Strategy.md` | BS-50 | advanced_strategy | meta | expert |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and strategy methodology |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

- **report-writing-mastery.md** — Reporting quality affects program reputation and bounty outcomes.
- **core-prompts-hunting.md** — Hunting strategies depend on program selection.
- **bug-bounty-support.md** — Support frameworks provide templates for program-specific submissions.

---

## Usage Examples

### Example 1: Find Top HackerOne Programs

```python
results = find_top_programs(index, min_bounty=500, platform='hackerone')
```

### Example 2: Find Beginner-Friendly Programs

```python
results = find_beginner_friendly(index)
```

### Example 3: Rank All Programs

```python
scorer = ProgramScorer(index)
ranked = scorer.rank_all()
```

### Example 4: Find Low-Competition High-Bounty

```python
results = find_by_criteria(index, competition='low', min_bounty=1000)
```
