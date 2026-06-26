# Automation Efficiency — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `automation-efficiency` |
| Root Path | `Automation-Efficiency/` |
| File Count | 50 primary files + README + registry.json |
| Index Type | Pipeline-centric (workflow, optimization, metrics) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Automation Efficiency domain index manages metadata for 50 modules covering workflow design, tool chaining, optimization, deployment, and monitoring of automated security testing pipelines. Each file represents a component or strategy for improving automation effectiveness. The index enables lookup by pipeline component, optimization type, improvement percentage, and bottleneck category.

This index supports two primary query patterns:
1. **Find best optimizations** — given a pipeline or component, retrieve optimization strategies sorted by improvement percentage.
2. **Find bottlenecks** — given a pipeline stage or metric, retrieve modules that address specific performance bottlenecks.

---

## Index Schema

### Primary Index: `efficiency_records`

```json
{
  "doc_type": "efficiency_record",
  "file_ref": "Automation-Efficiency/<filename>.md",
  "module_id": "AE-<number>",
  "module_title": "<title>",
  "category": "enum[workflow|tool_chain|scripting|api_integration|parsing|notification|reporting|monitoring|scanning|change_detection|target_management|deduplication|false_positive|parallel|resource|error_handling|performance|scalability|testing|deployment|config_management|version_control|collaboration|knowledge_base|learning|custom_tool|rate_limiting|storage|backup|security|cost_optimization|maintenance|documentation|debugging|benchmarking|compliance|disaster_recovery|metrics|optimization|integration|database|network|cloud|container|orchestration|standards|architecture]",
  "pipeline_stage": {
    "primary": "enum[design|development|testing|deployment|monitoring|maintenance]",
    "secondary": "enum[none|recon|fuzzing|exploitation|analysis|reporting]"
  },
  "optimization": {
    "type": "enum[performance|accuracy|reliability|cost|speed|resource|coverage|maintainability]",
    "improvement_percentage": "float [0.0-100.0]",
    "baseline_metric": "string",
    "optimized_metric": "string",
    "measurement_method": "enum[benchmark|production|estimated|theoretical]"
  },
  "bottleneck_addressed": {
    "category": "enum[none|cpu|memory|network|io|api_rate|false_positive|deduplication|error_rate|latency|throughput|storage|concurrency]",
    "severity": "enum[none|minor|moderate|major|critical]",
    "typical_impact": "string"
  },
  "dependencies": ["string"],
  "complexity": {
    "implementation": "enum[easy|moderate|hard|expert]",
    "maintenance": "enum[low|moderate|high]",
    "time_to_implement_hours": "integer"
  },
  "applicable_pipelines": ["string"],
  "tags": ["string"],
  "success_metrics": {
    "before": "string",
    "after": "string",
    "delta": "string"
  },
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `pipeline_index`

```json
{
  "pipeline_id": "string",
  "modules": ["AE-<number>"],
  "total_optimization_potential": "float",
  "bottleneck_count": "integer"
}
```

### Tertiary Index: `optimization_ranking`

```json
{
  "optimization_type": "string",
  "modules": ["AE-<number>"],
  "avg_improvement": "float",
  "best_improvement": "float"
}
```

---

## Index Creation

### Step 1: Extract Efficiency Metadata

```python
import re
from pathlib import Path
from datetime import datetime

def extract_efficiency_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    module_num = int(match.group(1)) if match else 0
    module_slug = match.group(2) if match else filename
    
    category = classify_efficiency_category(module_slug)
    pipeline_stage = detect_pipeline_stage(content, module_slug)
    optimization = extract_optimization(content)
    bottleneck = detect_bottleneck(content)
    
    return {
        "doc_type": "efficiency_record",
        "file_ref": f"Automation-Efficiency/{filepath.name}",
        "module_id": f"AE-{module_num:02d}",
        "module_title": format_title(module_slug),
        "category": category,
        "pipeline_stage": pipeline_stage,
        "optimization": optimization,
        "bottleneck_addressed": bottleneck,
        "dependencies": extract_dependencies(content),
        "complexity": extract_complexity(content, module_slug),
        "applicable_pipelines": extract_applicable_pipelines(content),
        "tags": extract_tags(content),
        "success_metrics": extract_success_metrics(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_efficiency_category(slug: str) -> str:
    mapping = {
        'workflow': 'workflow', 'tool-chaining': 'tool_chain',
        'script': 'scripting', 'api-integration': 'api_integration',
        'parsing': 'parsing', 'result-parsing': 'parsing',
        'notification': 'notification', 'alerting': 'notification',
        'report-generation': 'reporting', 'dashboard': 'monitoring',
        'continuous-scanning': 'scanning', 'change-detection': 'change_detection',
        'target-management': 'target_management', 'deduplication': 'deduplication',
        'false-positive': 'false_positive', 'parallel': 'parallel',
        'resource': 'resource', 'error-handling': 'error_handling',
        'performance': 'performance', 'scalability': 'scalability',
        'integration-testing': 'testing', 'deployment': 'deployment',
        'configuration': 'config_management', 'version-control': 'version_control',
        'collaboration': 'collaboration', 'knowledge-base': 'knowledge_base',
        'learning': 'learning', 'custom-tool': 'custom_tool',
        'rate-limiting': 'rate_limiting', 'data-storage': 'storage',
        'backup': 'backup', 'security': 'security',
        'cost-optimization': 'cost_optimization', 'maintenance': 'maintenance',
        'documentation': 'documentation', 'debugging': 'debugging',
        'benchmarking': 'benchmarking', 'compliance': 'compliance',
        'disaster-recovery': 'disaster_recovery', 'metrics': 'metrics',
        'optimization': 'optimization', 'tool-integration': 'integration',
        'custom-api': 'api_integration', 'database': 'database',
        'network': 'network', 'cloud': 'cloud',
        'container': 'container', 'orchestration': 'orchestration',
        'standards': 'standards', 'architecture': 'architecture',
    }
    slug_lower = slug.lower()
    for key, val in mapping.items():
        if key in slug_lower:
            return val
    return 'workflow'

def detect_pipeline_stage(content: str, slug: str) -> dict:
    text = (slug + ' ' + content).lower()
    
    primary = 'design'
    if any(kw in text for kw in ['develop', 'build', 'create', 'script']):
        primary = 'development'
    elif any(kw in text for kw in ['test', 'validate', 'verify']):
        primary = 'testing'
    elif any(kw in text for kw in ['deploy', 'release', 'publish']):
        primary = 'deployment'
    elif any(kw in text for kw in ['monitor', 'alert', 'dashboard']):
        primary = 'monitoring'
    elif any(kw in text for kw in ['maintain', 'update', 'backup']):
        primary = 'maintenance'
    
    secondary = 'none'
    if any(kw in text for kw in ['recon', 'subdomain', 'enumeration']):
        secondary = 'recon'
    elif any(kw in text for kw in ['fuzz', 'scan', 'brute']):
        secondary = 'fuzzing'
    elif any(kw in text for kw in ['exploit', 'poc', 'injection']):
        secondary = 'exploitation'
    elif any(kw in text for kw in ['analyz', 'pars', 'result']):
        secondary = 'analysis'
    elif any(kw in text for kw in ['report', 'document']):
        secondary = 'reporting'
    
    return {"primary": primary, "secondary": secondary}

def extract_optimization(content: str) -> dict:
    text = content.lower()
    
    opt_type = 'performance'
    type_keywords = {
        'performance': ['performance', 'speed', 'fast', 'optimize'],
        'accuracy': ['accuracy', 'precision', 'false positive', 'correct'],
        'reliability': ['reliability', 'uptime', 'availability', 'fault tolerance'],
        'cost': ['cost', 'budget', 'resource saving', 'cheap'],
        'speed': ['speed', 'latency', 'timeout', 'duration'],
        'resource': ['resource', 'memory', 'cpu', 'disk'],
        'coverage': ['coverage', 'scope', 'comprehensive', 'complete'],
        'maintainability': ['maintain', 'clean', 'refactor', 'readable'],
    }
    for t, keywords in type_keywords.items():
        for kw in keywords:
            if kw in text:
                opt_type = t
                break
    
    pct_match = re.search(r'(\d+(?:\.\d+)?)\s*%\s*(?:improvement|increase|reduction|faster)', text)
    improvement = float(pct_match.group(1)) if pct_match else estimate_improvement(content)
    
    before_match = re.search(r'before[:\s]+(.+?)(?:\n|$)', text)
    after_match = re.search(r'after[:\s]+(.+?)(?:\n|$)', text)
    
    return {
        "type": opt_type,
        "improvement_percentage": improvement,
        "baseline_metric": before_match.group(1).strip() if before_match else "unknown",
        "optimized_metric": after_match.group(1).strip() if after_match else "unknown",
        "measurement_method": detect_measurement_method(text)
    }

def estimate_improvement(content: str) -> float:
    text = content.lower()
    if any(kw in text for kw in ['significant', 'major', 'dramatic']):
        return 50.0
    if any(kw in text for kw in ['moderate', 'noticeable', 'meaningful']):
        return 25.0
    if any(kw in text for kw in ['minor', 'slight', 'marginal']):
        return 10.0
    return 15.0

def detect_measurement_method(text: str) -> str:
    if any(kw in text for kw in ['benchmark', 'timed', 'measured']):
        return 'benchmark'
    if any(kw in text for kw in ['production', 'real-world', 'live']):
        return 'production'
    if any(kw in text for kw in ['estimated', 'approximate', 'roughly']):
        return 'estimated'
    return 'theoretical'

def detect_bottleneck(content: str) -> dict:
    text = content.lower()
    
    category = 'none'
    cat_keywords = {
        'cpu': ['cpu', 'processor', 'compute'],
        'memory': ['memory', 'ram', 'heap'],
        'network': ['network', 'bandwidth', 'latency'],
        'io': ['disk', 'io', 'file system'],
        'api_rate': ['rate limit', 'throttle', 'api limit'],
        'false_positive': ['false positive', 'noise', 'incorrect'],
        'deduplication': ['duplicate', 'dedup', 'redundant'],
        'error_rate': ['error', 'failure', 'crash'],
        'latency': ['latency', 'delay', 'slow'],
        'throughput': ['throughput', 'volume', 'capacity'],
        'storage': ['storage', 'space', 'database size'],
        'concurrency': ['concurrent', 'parallel', 'thread'],
    }
    for cat, keywords in cat_keywords.items():
        for kw in keywords:
            if kw in text:
                category = cat
                break
    
    severity = 'none'
    if category != 'none':
        if any(kw in text for kw in ['critical', 'severe', 'blocking']):
            severity = 'critical'
        elif any(kw in text for kw in ['major', 'significant']):
            severity = 'major'
        elif any(kw in text for kw in ['moderate']):
            severity = 'moderate'
        else:
            severity = 'minor'
    
    return {
        "category": category,
        "severity": severity,
        "typical_impact": extract_impact_description(content)
    }

def extract_impact_description(content: str) -> str:
    match = re.search(r'impact[:\s]+(.+?)(?:\n|$)', content.lower())
    return match.group(1).strip() if match else "unknown"

def extract_complexity(content: str, slug: str) -> dict:
    text = (slug + ' ' + content).lower()
    
    impl = 'moderate'
    if any(kw in text for kw in ['simple', 'easy', 'straightforward']):
        impl = 'easy'
    elif any(kw in text for kw in ['complex', 'advanced', 'sophisticated']):
        impl = 'hard'
    elif any(kw in text for kw in ['expert', 'cutting-edge', 'state-of-art']):
        impl = 'expert'
    
    maint = 'moderate'
    if any(kw in text for kw in ['low maintenance', 'set and forget']):
        maint = 'low'
    elif any(kw in text for kw in ['high maintenance', 'frequent updates']):
        maint = 'high'
    
    hours_match = re.search(r'(\d+)\s*(?:hours?|hrs?)', text)
    hours = int(hours_match.group(1)) if hours_match else 8
    
    return {
        "implementation": impl,
        "maintenance": maint,
        "time_to_implement_hours": hours
    }

def extract_applicable_pipelines(content: str) -> list:
    text = content.lower()
    pipelines = []
    if 'recon' in text:
        pipelines.append('recon')
    if 'scanning' in text or 'vulnerability scan' in text:
        pipelines.append('scanning')
    if 'fuzzing' in text:
        pipelines.append('fuzzing')
    if 'exploit' in text:
        pipelines.append('exploitation')
    if 'report' in text:
        pipelines.append('reporting')
    return pipelines if pipelines else ['general']

def extract_dependencies(content: str) -> list:
    deps = []
    dep_patterns = [
        r'requires?\s+([a-zA-Z0-9_-]+)', r'depends?\s+on\s+([a-zA-Z0-9_-]+)',
        r'uses?\s+([a-zA-Z0-9_-]+)', r'built\s+on\s+([a-zA-Z0-9_-]+)'
    ]
    for pattern in dep_patterns:
        matches = re.findall(pattern, content.lower())
        deps.extend(matches)
    return list(set(deps))[:10]

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'automation', 'optimization', 'parallel', 'async', 'pipeline',
        'monitoring', 'alerting', 'logging', 'metrics', 'dashboard',
        'ci-cd', 'devops', 'cloud-native', 'microservices', 'containerized'
    ]
    text = content.lower()
    for tag in tag_keywords:
        if tag in text:
            tags.append(tag)
    return tags

def extract_success_metrics(content: dict) -> dict:
    text = content.lower() if isinstance(content, str) else ''
    before = re.search(r'before[:\s]+(.+?)(?:\n|$)', text)
    after = re.search(r'after[:\s]+(.+?)(?:\n|$)', text)
    delta = re.search(r'delta[:\s]+(.+?)(?:\n|$)', text)
    return {
        "before": before.group(1).strip() if before else "unknown",
        "after": after.group(1).strip() if after else "unknown",
        "delta": delta.group(1).strip() if delta else "unknown"
    }

def format_title(slug: str) -> str:
    return slug.replace('-', ' ').title()

def extract_date(content: str) -> str:
    match = re.search(r'(\d{4}-\d{2}-\d{2})', content)
    return match.group(1) if match else datetime.now().isoformat()
```

### Step 2: Build Efficiency Index

```python
class EfficiencyIndex:
    def __init__(self):
        self.primary = {}
        self.by_category = {}
        self.by_pipeline_stage = {}
        self.by_optimization_type = {}
        self.by_bottleneck = {}
        self.by_complexity = {}
        self.by_applicable_pipeline = {}
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        self.by_category.setdefault(doc['category'], []).append(mid)
        
        stage = doc['pipeline_stage']['primary']
        self.by_pipeline_stage.setdefault(stage, []).append(mid)
        
        opt_type = doc['optimization']['type']
        self.by_optimization_type.setdefault(opt_type, []).append(mid)
        
        bn_cat = doc['bottleneck_addressed']['category']
        if bn_cat != 'none':
            self.by_bottleneck.setdefault(bn_cat, []).append(mid)
        
        impl = doc['complexity']['implementation']
        self.by_complexity.setdefault(impl, []).append(mid)
        
        for pipeline in doc['applicable_pipelines']:
            self.by_applicable_pipeline.setdefault(pipeline, []).append(mid)
    
    def find_best_optimizations(self, optimization_type: str = None, 
                                 min_improvement: float = 0.0) -> list:
        if optimization_type:
            mids = self.by_optimization_type.get(optimization_type, [])
        else:
            mids = list(self.primary.keys())
        
        results = []
        for mid in mids:
            doc = self.primary[mid]
            if doc['optimization']['improvement_percentage'] >= min_improvement:
                results.append(doc)
        
        results.sort(key=lambda x: x['optimization']['improvement_percentage'], reverse=True)
        return results
    
    def find_bottlenecks(self, bottleneck_category: str = None) -> list:
        if bottleneck_category:
            mids = self.by_bottleneck.get(bottleneck_category, [])
        else:
            mids = [mid for mid, doc in self.primary.items() 
                    if doc['bottleneck_addressed']['category'] != 'none']
        
        results = []
        for mid in mids:
            doc = self.primary[mid]
            results.append(doc)
        
        severity_order = {'critical': 4, 'major': 3, 'moderate': 2, 'minor': 1, 'none': 0}
        results.sort(key=lambda x: severity_order.get(x['bottleneck_addressed']['severity'], 0), reverse=True)
        return results
    
    def find_by_pipeline(self, pipeline_id: str) -> list:
        mids = self.by_applicable_pipeline.get(pipeline_id, [])
        return [self.primary[mid] for mid in mids]
    
    def find_quick_wins(self, max_hours: int = 8) -> list:
        """Find modules with high improvement and low implementation time."""
        results = []
        for mid, doc in self.primary.items():
            if doc['complexity']['time_to_implement_hours'] <= max_hours:
                if doc['optimization']['improvement_percentage'] >= 20:
                    doc_copy = doc.copy()
                    doc_copy['efficiency_ratio'] = (
                        doc['optimization']['improvement_percentage'] / 
                        max(doc['complexity']['time_to_implement_hours'], 1)
                    )
                    results.append(doc_copy)
        results.sort(key=lambda x: x['efficiency_ratio'], reverse=True)
        return results
```

### Step 3: Persist Index

```python
import json
from datetime import datetime

def persist_efficiency_index(index: EfficiencyIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "automation-efficiency",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_category": index.by_category,
            "by_pipeline_stage": index.by_pipeline_stage,
            "by_optimization_type": index.by_optimization_type,
            "by_bottleneck": index.by_bottleneck,
            "by_complexity": index.by_complexity,
            "by_applicable_pipeline": index.by_applicable_pipeline,
        }
    }
    
    index_file = output_dir / "efficiency-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Best Optimizations

```python
def find_best_optimizations(index: EfficiencyIndex, 
                            opt_type: str = None,
                            min_improvement: float = 0.0,
                            max_complexity: str = 'hard') -> list:
    complexity_order = {'easy': 1, 'moderate': 2, 'hard': 3, 'expert': 4}
    max_idx = complexity_order.get(max_complexity, 4)
    
    results = index.find_best_optimizations(opt_type, min_improvement)
    return [r for r in results 
            if complexity_order.get(r['complexity']['implementation'], 4) <= max_idx]
```

### Query 2: Find Bottlenecks

```python
def find_bottlenecks(index: EfficiencyIndex, 
                     category: str = None,
                     min_severity: str = 'minor') -> list:
    severity_order = {'none': 0, 'minor': 1, 'moderate': 2, 'major': 3, 'critical': 4}
    min_idx = severity_order.get(min_severity, 1)
    
    results = index.find_bottlenecks(category)
    return [r for r in results 
            if severity_order.get(r['bottleneck_addressed']['severity'], 0) >= min_idx]
```

### Query 3: Find for Pipeline Stage

```python
def find_for_pipeline_stage(index: EfficiencyIndex, stage: str) -> list:
    mids = index.by_pipeline_stage.get(stage, [])
    return [index.primary[mid] for mid in mids]
```

### Query 4: Find Easy Implementations

```python
def find_easy_implementations(index: EfficiencyIndex) -> list:
    mids = index.by_complexity.get('easy', [])
    return [index.primary[mid] for mid in mids]
```

### Query 5: Composite Query

```python
def efficiency_composite_query(index: EfficiencyIndex, **kwargs) -> list:
    candidate_sets = []
    
    if 'category' in kwargs:
        candidate_sets.append(set(index.by_category.get(kwargs['category'], [])))
    if 'pipeline_stage' in kwargs:
        candidate_sets.append(set(index.by_pipeline_stage.get(kwargs['pipeline_stage'], [])))
    if 'optimization_type' in kwargs:
        candidate_sets.append(set(index.by_optimization_type.get(kwargs['optimization_type'], [])))
    if 'bottleneck' in kwargs:
        candidate_sets.append(set(index.by_bottleneck.get(kwargs['bottleneck'], [])))
    if 'complexity' in kwargs:
        candidate_sets.append(set(index.by_complexity.get(kwargs['complexity'], [])))
    
    if not candidate_sets:
        return list(index.primary.values())
    
    intersection = candidate_sets[0]
    for s in candidate_sets[1:]:
        intersection &= s
    
    return [index.primary[mid] for mid in intersection]
```

---

## Search Algorithms

### Efficiency Score Ranking

```python
class EfficiencyRanker:
    def __init__(self, index: EfficiencyIndex):
        self.index = index
    
    def rank_modules(self, priorities: dict = None) -> list:
        """
        Rank all modules by composite efficiency score.
        priorities: dict of {metric: weight} where weight is 0.0-1.0
        """
        if priorities is None:
            priorities = {
                'improvement': 0.35,
                'implementation_ease': 0.25,
                'bottleneck_severity': 0.20,
                'maintenance': 0.20
            }
        
        impl_ease_map = {'easy': 1.0, 'moderate': 0.6, 'hard': 0.3, 'expert': 0.1}
        maint_map = {'low': 1.0, 'moderate': 0.5, 'high': 0.2}
        sev_map = {'none': 0.0, 'minor': 0.2, 'moderate': 0.5, 'major': 0.8, 'critical': 1.0}
        
        results = []
        for mid, doc in self.index.primary.items():
            score = 0.0
            
            improvement_norm = min(doc['optimization']['improvement_percentage'] / 100.0, 1.0)
            impl_norm = impl_ease_map.get(doc['complexity']['implementation'], 0.5)
            sev_norm = sev_map.get(doc['bottleneck_addressed']['severity'], 0.0)
            maint_norm = maint_map.get(doc['complexity']['maintenance'], 0.5)
            
            score = (
                improvement_norm * priorities.get('improvement', 0.35) +
                impl_norm * priorities.get('implementation_ease', 0.25) +
                sev_norm * priorities.get('bottleneck_severity', 0.20) +
                maint_norm * priorities.get('maintenance', 0.20)
            )
            
            doc_copy = doc.copy()
            doc_copy['efficiency_score'] = round(score, 4)
            results.append(doc_copy)
        
        results.sort(key=lambda x: x['efficiency_score'], reverse=True)
        return results
```

### BM25 Search

```python
import math

class EfficiencyBM25:
    def __init__(self, index: EfficiencyIndex, k1: float = 1.5, b: float = 0.75):
        self.index = index
        self.k1 = k1
        self.b = b
    
    def _tokenize(self, text: str) -> list:
        import re
        tokens = re.findall(r'[a-z0-9]+', text.lower())
        stopwords = {'the', 'a', 'an', 'is', 'are', 'in', 'on', 'for', 'of', 'and', 'or', 'to'}
        return [t for t in tokens if t not in stopwords]
    
    def search(self, query: str) -> list:
        query_tokens = self._tokenize(query)
        avg_dl = self._compute_avg_dl()
        scores = []
        
        for mid, doc in self.index.primary.items():
            text = f"{doc['module_title']} {doc['category']} {doc['optimization']['type']} {' '.join(doc.get('tags', []))}"
            doc_tokens = self._tokenize(text)
            doc_len = len(doc_tokens)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                df = sum(1 for d in self.index.primary.values() 
                         if qt in f"{d['module_title']} {d['category']}".lower())
                idf = math.log((len(self.index.primary) - df + 0.5) / (df + 0.5) + 1)
                numerator = tf * (self.k1 + 1)
                denominator = tf + self.k1 * (1 - self.b + self.b * doc_len / avg_dl)
                score += idf * numerator / denominator
            
            if score > 0:
                scores.append((mid, score))
        
        scores.sort(key=lambda x: x[1], reverse=True)
        return [(mid, s, self.index.primary[mid]) for mid, s in scores]
    
    def _compute_avg_dl(self) -> float:
        total = 0
        for doc in self.index.primary.values():
            text = f"{doc['module_title']} {doc['category']} {doc['optimization']['type']}"
            total += len(self._tokenize(text))
        return total / max(len(self.index.primary), 1)
```

---

## Relevance Scoring

```python
def compute_efficiency_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'category' in query and doc['category'] == query['category']:
        score += 0.25
    
    if 'optimization_type' in query and doc['optimization']['type'] == query['optimization_type']:
        score += 0.20
    
    if 'bottleneck' in query and doc['bottleneck_addressed']['category'] == query['bottleneck']:
        score += 0.20
    
    improvement_norm = min(doc['optimization']['improvement_percentage'] / 100.0, 1.0)
    score += improvement_norm * 0.15
    
    impl_ease_map = {'easy': 1.0, 'moderate': 0.6, 'hard': 0.3, 'expert': 0.1}
    score += impl_ease_map.get(doc['complexity']['implementation'], 0.5) * 0.10
    
    sev_map = {'none': 0.0, 'minor': 0.2, 'moderate': 0.5, 'major': 0.8, 'critical': 1.0}
    score += sev_map.get(doc['bottleneck_addressed']['severity'], 0.0) * 0.10
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_efficiency_index(index: EfficiencyIndex, new_file: Path):
    doc = extract_efficiency_metadata(new_file)
    index.add(doc)

def remove_module(index: EfficiencyIndex, module_id: str):
    if module_id not in index.primary:
        return
    doc = index.primary[module_id]
    
    for idx_map in [index.by_category, index.by_pipeline_stage, index.by_optimization_type,
                    index.by_bottleneck, index.by_complexity]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
    
    for pipeline in doc['applicable_pipelines']:
        if pipeline in index.by_applicable_pipeline and module_id in index.by_applicable_pipeline[pipeline]:
            index.by_applicable_pipeline[pipeline].remove(module_id)
    
    del index.primary[module_id]

def verify_efficiency_index(index: EfficiencyIndex) -> dict:
    issues = []
    for mid, doc in index.primary.items():
        if doc['optimization']['improvement_percentage'] < 0:
            issues.append(f"Module {mid} has negative improvement")
        if doc['complexity']['time_to_implement_hours'] < 0:
            issues.append(f"Module {mid} has negative implementation time")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Module ID | Category | Optimization Type | Bottleneck |
|---|------|-----------|----------|-------------------|------------|
| 01 | `01-Workflow-Automation-Design.md` | AE-01 | workflow | performance | none |
| 02 | `02-Tool-Chaining-Strategies.md` | AE-02 | tool_chain | speed | none |
| 03 | `03-Script-Development-Best-Practices.md` | AE-03 | scripting | maintainability | none |
| 04 | `04-API-Integration-Automation.md` | AE-04 | api_integration | reliability | api_rate |
| 05 | `05-Result-Parsing-and-Analysis.md` | AE-05 | parsing | accuracy | false_positive |
| 06 | `06-Notification-and-Alerting-Systems.md` | AE-06 | notification | reliability | latency |
| 07 | `07-Report-Generation-Automation.md` | AE-07 | reporting | speed | none |
| 08 | `08-Dashboard-and-Monitoring.md` | AE-08 | monitoring | coverage | none |
| 09 | `09-Continuous-Scanning-Workflows.md` | AE-09 | scanning | coverage | throughput |
| 10 | `10-Change-Detection-Automation.md` | AE-10 | change_detection | accuracy | false_positive |
| 11 | `11-Target-Management-Systems.md` | AE-11 | target_management | maintainability | none |
| 12 | `12-Result-Deduplication.md` | AE-12 | deduplication | accuracy | deduplication |
| 13 | `13-False-Positive-Reduction.md` | AE-13 | false_positive | accuracy | false_positive |
| 14 | `14-Parallel-Processing-Optimization.md` | AE-14 | parallel | speed | concurrency |
| 15 | `15-Resource-Management-Automation.md` | AE-15 | resource | cost | cpu |
| 16 | `16-Error-Handling-and-Recovery.md` | AE-16 | error_handling | reliability | error_rate |
| 17 | `17-Performance-Monitoring.md` | AE-17 | performance | performance | latency |
| 18 | `18-Scalability-Design-Patterns.md` | AE-18 | scalability | throughput | throughput |
| 19 | `19-Integration-Testing-Automation.md` | AE-19 | testing | reliability | none |
| 20 | `20-Deployment-Automation.md` | AE-20 | deployment | speed | none |
| 21 | `21-Configuration-Management.md` | AE-21 | config_management | maintainability | none |
| 22 | `22-Version-Control-for-Tools.md` | AE-22 | version_control | maintainability | none |
| 23 | `23-Collaboration-Workflows.md` | AE-23 | collaboration | maintainability | none |
| 24 | `24-Knowledge-Base-Automation.md` | AE-24 | knowledge_base | accuracy | none |
| 25 | `25-Learning-and-Adaptation.md` | AE-25 | learning | accuracy | none |
| 26 | `26-Custom-Tool-Development.md` | AE-26 | custom_tool | coverage | none |
| 27 | `27-API-Rate-Limiting-Handling.md` | AE-27 | rate_limiting | reliability | api_rate |
| 28 | `28-Data-Storage-and-Retrieval.md` | AE-28 | storage | speed | storage |
| 29 | `29-Backup-and-Recovery-Automation.md` | AE-29 | backup | reliability | none |
| 30 | `30-Security-for-Automation-Tools.md` | AE-30 | security | reliability | none |
| 31 | `31-Cost-Optimization-Strategies.md` | AE-31 | cost_optimization | cost | none |
| 32 | `32-Maintenance-and-Updates.md` | AE-32 | maintenance | maintainability | none |
| 33 | `33-Documentation-Automation.md` | AE-33 | documentation | maintainability | none |
| 34 | `34-Testing-Automation-Workflows.md` | AE-34 | testing | reliability | none |
| 35 | `35-Debugging-and-Troubleshooting.md` | AE-35 | debugging | reliability | error_rate |
| 36 | `36-Performance-Benchmarking.md` | AE-36 | benchmarking | performance | none |
| 37 | `37-Automation-Security-Assessment.md` | AE-37 | security | reliability | none |
| 38 | `38-Compliance-and-Audit-Trails.md` | AE-38 | compliance | reliability | none |
| 39 | `39-Disaster-Recovery-Planning.md` | AE-39 | disaster_recovery | reliability | none |
| 40 | `40-Automation-Metrics-and-Analytics.md` | AE-40 | metrics | coverage | none |
| 41 | `41-Workflow-Optimization.md` | AE-41 | optimization | speed | latency |
| 42 | `42-Tool-Integration-Frameworks.md` | AE-42 | integration | coverage | none |
| 43 | `43-Custom-API-Development.md` | AE-43 | api_integration | speed | api_rate |
| 44 | `44-Database-Automation.md` | AE-44 | database | speed | io |
| 45 | `45-Network-Automation.md` | AE-45 | network | speed | network |
| 46 | `46-Cloud-Automation.md` | AE-46 | cloud | cost | none |
| 47 | `47-Container-Automation.md` | AE-47 | container | speed | none |
| 48 | `48-Orchestration-Frameworks.md` | AE-48 | orchestration | coverage | none |
| 49 | `49-Automation-Standards.md` | AE-49 | standards | maintainability | none |
| 50 | `50-Advanced-Automation-Architecture.md` | AE-50 | architecture | coverage | none |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and efficiency methodology |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

- **advanced-automation.md** — Automation modules are consumers of efficiency optimizations.
- **report-writing-mastery.md** — Report generation modules (AE-07) connect to reporting indexes.
- **core-prompts-hunting.md** — Hunting modules benefit from efficiency improvements.

---

## Usage Examples

### Example 1: Find Best Speed Optimizations

```python
results = find_best_optimizations(index, opt_type='speed', min_improvement=30.0)
```

### Example 2: Find API Rate Limiting Solutions

```python
results = find_bottlenecks(index, category='api_rate', min_severity='moderate')
```

### Example 3: Find Quick Wins

```python
results = index.find_quick_wins(max_hours=4)
```

### Example 4: Rank All Modules

```python
ranker = EfficiencyRanker(index)
ranked = ranker.rank_modules({"improvement": 0.4, "implementation_ease": 0.3, "bottleneck_severity": 0.3})
```
