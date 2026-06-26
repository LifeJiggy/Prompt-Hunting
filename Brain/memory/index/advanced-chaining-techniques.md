# Advanced Chaining Techniques — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `advanced-chaining-techniques` |
| Root Path | `Advanced-Chaining-Techniques/` |
| File Count | 49 primary files + README + registry.json |
| Index Type | Graph-based (chains as edges, primitives as nodes) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Advanced Chaining Techniques domain index manages metadata for 49 vulnerability chaining modules. Each file documents a multi-step attack chain that combines two or more vulnerability primitives to achieve higher impact than individual bugs. The index structures chains as directed graphs where nodes represent vulnerability primitives and edges represent chaining transitions.

This index supports two primary query patterns:
1. **Find chains by primitive type** — given a primitive (e.g., XSS, SSRF, IDOR), retrieve all chains that use it as an entry point, intermediate step, or escalation vector.
2. **Find chains by impact level** — given a target impact (e.g., RCE, ATO, mass data extraction), retrieve all chains that achieve that impact outcome.

---

## Index Schema

### Primary Index: `chain_records`

```json
{
  "doc_type": "chain_record",
  "file_ref": "Advanced-Chaining-Techniques/<filename>.md",
  "chain_id": "AC-<number>",
  "chain_title": "<title>",
  "chain_graph": {
    "nodes": [
      {
        "node_id": "string",
        "primitive": "enum[xss|sqli|ssrf|csrf|idor|xxe|ssti|rce|lfi|rfi|cmd_injection|auth_bypass|jwt|deserialization|cors|graphql|websocket|prototype_pollution|race_condition|file_upload|open_redirect|subdomain_takeover|webcache_poisoning|clickjacking|parameter_pollution|ldap|xpath|session_puzzling|cryptography|supply_chain|cloud_misconfig|host_header|dns_rebinding|http_smuggling|content_spoofing|client_side_storage|no_sql|file_handling|network_infrastructure|mobile_api]",
        "position": "enum[entry|intermediate|escalation|final]"
      }
    ],
    "edges": [
      {
        "from_node": "string",
        "to_node": "string",
        "transition_type": "enum[direct_exploit|privilege_escalation|lateral_movement|data_exfil|persistence|auth_bypass]",
        "difficulty": "enum[easy|medium|hard|expert]"
      }
    ]
  },
  "primitives_used": ["string"],
  "primitive_count": "integer",
  "impact": {
    "level": "enum[critical|high|medium|low]",
    "category": "enum[rce|ato|mass_data_extraction|financial_fraud|lateral_movement|full_compromise|supply_chain|cloud_takeover]",
    "cve_chain": ["string"]
  },
  "success_rate": {
    "lab": "float [0.0-1.0]",
    "real_world": "float [0.0-1.0]"
  },
  "platforms": ["enum[web|api|mobile|cloud|iot|blockchain|enterprise]"],
  "tags": ["string"],
  "complexity_score": "integer [1-10]",
  "reproduction_steps": "integer",
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `primitive_index`

```json
{
  "primitive_name": "string",
  "chains_as_entry": ["AC-<number>"],
  "chains_as_intermediate": ["AC-<number>"],
  "chains_as_escalation": ["AC-<number>"],
  "total_chain_appearances": "integer",
  "avg_success_rate": "float",
  "co_occurring_primitives": { "<primitive>": "integer" }
}
```

### Tertiary Index: `impact_index`

```json
{
  "impact_category": "string",
  "chains": ["AC-<number>"],
  "avg_complexity": "float",
  "avg_primitive_count": "float",
  "most_common_entry": "string"
}
```

---

## Index Creation

### Step 1: Extract Chain Graph from Module

```python
import re
from pathlib import Path

PRIMITIVE_KEYWORDS = {
    'xss': ['xss', 'cross-site scripting', 'stored xss', 'reflected xss', 'dom xss'],
    'sqli': ['sqli', 'sql injection', 'blind sqli', 'union-based'],
    'ssrf': ['ssrf', 'server-side request forgery', 'internal request'],
    'csrf': ['csrf', 'cross-site request forgery'],
    'idor': ['idor', 'insecure direct object'],
    'xxe': ['xxe', 'xml external entity'],
    'ssti': ['ssti', 'server-side template injection'],
    'rce': ['rce', 'remote code execution'],
    'cmd_injection': ['command injection', 'os command'],
    'lfi': ['lfi', 'local file inclusion', 'path traversal'],
    'auth_bypass': ['auth bypass', 'authentication bypass'],
    'jwt': ['jwt', 'json web token'],
    'deserialization': ['deserialization', 'unsafe deserialization'],
    'cors': ['cors', 'cross-origin resource sharing'],
    'graphql': ['graphql'],
    'websocket': ['websocket'],
    'prototype_pollution': ['prototype pollution', '__proto__'],
    'race_condition': ['race condition', 'time-of-check'],
    'file_upload': ['file upload', 'webshell'],
    'open_redirect': ['open redirect', 'url redirect'],
    'subdomain_takeover': ['subdomain takeover', 'dangling dns'],
    'webcache_poisoning': ['cache poisoning', 'web cache'],
    'clickjacking': ['clickjacking', 'ui redressing'],
    'parameter_pollution': ['parameter pollution', 'hpp'],
    'ldap': ['ldap injection'],
    'xpath': ['xpath injection'],
    'session_puzzling': ['session puzzling', 'session fixation'],
    'cryptography': ['weak crypto', 'crypto weakness'],
    'supply_chain': ['supply chain'],
    'cloud_misconfig': ['cloud misconfiguration', 's3 bucket'],
    'host_header': ['host header injection'],
    'dns_rebinding': ['dns rebinding'],
    'http_smuggling': ['http smuggling', 'request smuggling'],
    'content_spoofing': ['content spoofing', 'content injection'],
    'client_side_storage': ['client-side storage', 'localStorage'],
    'no_sql': ['nosql injection', 'mongodb injection'],
    'file_handling': ['insecure file handling'],
    'network_infrastructure': ['network infrastructure', 'network attack'],
    'mobile_api': ['mobile api', 'mobile application'],
}

IMPACT_KEYWORDS = {
    'rce': ['remote code execution', 'rce', 'code execution', 'shell access'],
    'ato': ['account takeover', 'ato', 'account compromise'],
    'mass_data_extraction': ['mass data', 'data extraction', 'bulk data', 'sensitive data'],
    'financial_fraud': ['financial', 'payment', 'monetary', 'fraud'],
    'lateral_movement': ['lateral movement', 'pivot', 'internal network'],
    'full_compromise': ['full compromise', 'complete compromise', 'system compromise'],
    'supply_chain': ['supply chain attack', 'dependency'],
    'cloud_takeover': ['cloud takeover', 'cloud compromise', 'aws account'],
}

def extract_primitives(content: str, slug: str) -> list:
    text = (slug + ' ' + content).lower()
    found = []
    for primitive, keywords in PRIMITIVE_KEYWORDS.items():
        for kw in keywords:
            if kw in text:
                found.append(primitive)
                break
    return list(set(found))

def extract_chain_positions(content: str) -> list:
    lines = content.split('\n')
    nodes = []
    position_keywords = {
        'entry': ['entry point', 'initial access', 'starting point', 'first step'],
        'intermediate': ['intermediate', 'pivot', 'bridge', 'stepping stone'],
        'escalation': ['escalation', 'privilege', 'upgrade', 'escalate'],
        'final': ['final impact', 'end result', 'outcome', 'achieves'],
    }
    for i, line in enumerate(lines):
        line_lower = line.lower()
        for position, keywords in position_keywords.items():
            for kw in keywords:
                if kw in line_lower:
                    primitives = extract_primitives(line, line)
                    for p in primitives:
                        nodes.append({
                            "node_id": f"n{len(nodes)}",
                            "primitive": p,
                            "position": position
                        })
                    break
    return nodes

def build_chain_graph(content: str, primitives: list) -> dict:
    nodes = extract_chain_positions(content)
    if not nodes:
        for i, p in enumerate(primitives):
            position = 'entry' if i == 0 else ('final' if i == len(primitives) - 1 else 'intermediate')
            nodes.append({"node_id": f"n{i}", "primitive": p, "position": position})
    
    edges = []
    for i in range(len(nodes) - 1):
        edges.append({
            "from_node": nodes[i]['node_id'],
            "to_node": nodes[i+1]['node_id'],
            "transition_type": determine_transition(nodes[i], nodes[i+1], content),
            "difficulty": determine_difficulty(content, i)
        })
    
    return {"nodes": nodes, "edges": edges}

def determine_transition(from_node: dict, to_node: dict, content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['privilege escalation', 'escalate', 'admin']):
        return 'privilege_escalation'
    if any(kw in text for kw in ['exfiltrat', 'extract', 'steal data']):
        return 'data_exfil'
    if any(kw in text for kw in ['lateral', 'pivot', 'internal']):
        return 'lateral_movement'
    if any(kw in text for kw in ['persist', 'maintain access']):
        return 'persistence'
    if any(kw in text for kw in ['auth bypass', 'bypass authentication']):
        return 'auth_bypass'
    return 'direct_exploit'

def determine_difficulty(content: str, step: int) -> str:
    text = content.lower()
    if 'expert' in text or 'advanced' in text:
        return 'expert'
    if 'hard' in text or 'complex' in text:
        return 'hard'
    if step < 2:
        return 'easy'
    return 'medium'

def determine_impact(content: str, slug: str) -> dict:
    text = (slug + ' ' + content).lower()
    category = 'rce'
    level = 'high'
    
    for cat, keywords in IMPACT_KEYWORDS.items():
        for kw in keywords:
            if kw in text:
                category = cat
                break
    
    if category in ['rce', 'full_compromise', 'cloud_takeover', 'supply_chain']:
        level = 'critical'
    elif category in ['ato', 'lateral_movement']:
        level = 'high'
    elif category == 'mass_data_extraction':
        level = 'high'
    else:
        level = 'medium'
    
    cves = re.findall(r'CVE-\d{4}-\d{4,}', content)
    
    return {"level": level, "category": category, "cve_chain": cves}

def compute_chain_complexity(graph: dict) -> int:
    node_count = len(graph['nodes'])
    edge_count = len(graph['edges'])
    unique_primitives = len(set(n['primitive'] for n in graph['nodes']))
    expert_edges = sum(1 for e in graph['edges'] if e['difficulty'] == 'expert')
    
    score = min(10, max(1, node_count + unique_primitives + expert_edges * 2))
    return score

def extract_success_rates(content: dict) -> dict:
    text = content.lower() if isinstance(content, str) else ''
    lab_match = re.search(r'lab.*?(\d+(?:\.\d+)?)\s*%', text)
    real_match = re.search(r'real.?world.*?(\d+(?:\.\d+)?)\s*%', text)
    return {
        "lab": float(lab_match.group(1)) / 100.0 if lab_match else 0.7,
        "real_world": float(real_match.group(1)) / 100.0 if real_match else 0.3
    }

def extract_platforms(content: str) -> list:
    text = content.lower()
    platforms = []
    checks = {
        'web': ['web application', 'web server', 'browser'],
        'api': ['api', 'rest', 'graphql'],
        'mobile': ['mobile', 'android', 'ios'],
        'cloud': ['cloud', 'aws', 'azure', 'gcp'],
        'iot': ['iot', 'embedded', 'device'],
        'blockchain': ['blockchain', 'smart contract', 'defi'],
        'enterprise': ['enterprise', 'active directory', 'domain'],
    }
    for platform, keywords in checks.items():
        for kw in keywords:
            if kw in text:
                platforms.append(platform)
                break
    return platforms if platforms else ['web']

def count_steps(content: str) -> int:
    step_patterns = [
        r'step\s*\d+', r'phase\s*\d+', r'stage\s*\d+',
        r'\d+\.\s', r'first,', r'second,', r'then,'
    ]
    count = 0
    for pattern in step_patterns:
        count += len(re.findall(pattern, content.lower()))
    return max(count, 2)

def extract_date(content: str) -> str:
    import datetime
    match = re.search(r'(\d{4}-\d{2}-\d{2})', content)
    return match.group(1) if match else datetime.date.today().isoformat()

def format_title(slug: str) -> str:
    return slug.replace('-', ' ').title()
```

### Step 2: Build Inverted Indexes

```python
class ChainingIndex:
    def __init__(self):
        self.primary = {}           # chain_id -> metadata
        self.by_primitive = {}      # primitive -> [chain_id]
        self.by_entry_primitive = {}  # entry_primitive -> [chain_id]
        self.by_impact = {}         # impact_category -> [chain_id]
        self.by_severity = {}       # impact_level -> [chain_id]
        self.by_platform = {}       # platform -> [chain_id]
        self.by_complexity = {}     # complexity_range -> [chain_id]
        self.co_occurrence = {}     # (p1, p2) -> count
        self.primitive_stats = {}   # primitive -> stats
    
    def add(self, doc: dict):
        cid = doc['chain_id']
        self.primary[cid] = doc
        
        graph = doc['chain_graph']
        primitives = doc['primitives_used']
        
        # Invert on all primitives
        for p in primitives:
            self.by_primitive.setdefault(p, []).append(cid)
        
        # Invert on entry primitive
        entry_nodes = [n for n in graph['nodes'] if n['position'] == 'entry']
        for n in entry_nodes:
            self.by_entry_primitive.setdefault(n['primitive'], []).append(cid)
        
        # Invert on impact
        self.by_impact.setdefault(doc['impact']['category'], []).append(cid)
        self.by_severity.setdefault(doc['impact']['level'], []).append(cid)
        
        # Invert on platform
        for p in doc['platforms']:
            self.by_platform.setdefault(p, []).append(cid)
        
        # Complexity buckets
        bucket = bucket_complexity(doc['complexity_score'])
        self.by_complexity.setdefault(bucket, []).append(cid)
        
        # Co-occurrence tracking
        for i in range(len(primitives)):
            for j in range(i+1, len(primitives)):
                pair = tuple(sorted([primitives[i], primitives[j]]))
                self.co_occurrence[pair] = self.co_occurrence.get(pair, 0) + 1
        
        # Update primitive stats
        for p in primitives:
            if p not in self.primitive_stats:
                self.primitive_stats[p] = {
                    'total_appearances': 0,
                    'as_entry': 0,
                    'as_intermediate': 0,
                    'as_escalation': 0,
                    'success_rates': []
                }
            self.primitive_stats[p]['total_appearances'] += 1
            for n in graph['nodes']:
                if n['primitive'] == p:
                    key = f"as_{n['position']}"
                    if key in self.primitive_stats[p]:
                        self.primitive_stats[p][key] += 1
            self.primitive_stats[p]['success_rates'].append(
                doc['success_rate']['real_world']
            )
    
    def get_primitive_stats(self, primitive: str) -> dict:
        stats = self.primitive_stats.get(primitive, {})
        if stats and stats.get('success_rates'):
            stats['avg_success_rate'] = sum(stats['success_rates']) / len(stats['success_rates'])
        return stats
    
    def get_co_occurring(self, primitive: str, top_n: int = 10) -> list:
        co_counts = {}
        for (p1, p2), count in self.co_occurrence.items():
            if p1 == primitive:
                co_counts[p2] = count
            elif p2 == primitive:
                co_counts[p1] = count
        sorted_pairs = sorted(co_counts.items(), key=lambda x: x[1], reverse=True)
        return sorted_pairs[:top_n]

def bucket_complexity(score: int) -> str:
    if score <= 3:
        return 'low'
    elif score <= 6:
        return 'medium'
    else:
        return 'high'
```

### Step 3: Persist Index

```python
import json
from datetime import datetime

def persist_chaining_index(index: ChainingIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "advanced-chaining-techniques",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_primitive": index.by_primitive,
            "by_entry_primitive": index.by_entry_primitive,
            "by_impact": index.by_impact,
            "by_severity": index.by_severity,
            "by_platform": index.by_platform,
            "by_complexity": index.by_complexity,
        },
        "co_occurrence": {f"{k[0]}|{k[1]}": v for k, v in index.co_occurrence.items()},
        "primitive_stats": index.primitive_stats
    }
    
    index_file = output_dir / "chaining-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Chains by Primitive

```python
def find_chains_by_primitive(index: ChainingIndex, primitive: str, role: str = 'any') -> list:
    """
    Find all chains involving a specific primitive.
    
    Args:
        index: The chaining index
        primitive: Vulnerability primitive name
        role: 'any', 'entry', 'intermediate', or 'escalation'
    
    Returns:
        List of chain records sorted by success_rate descending
    """
    if role == 'entry':
        chain_ids = index.by_entry_primitive.get(primitive, [])
    elif role == 'intermediate':
        chain_ids = []
        for cid, doc in index.primary.items():
            for node in doc['chain_graph']['nodes']:
                if node['primitive'] == primitive and node['position'] == 'intermediate':
                    chain_ids.append(cid)
                    break
    elif role == 'escalation':
        chain_ids = []
        for cid, doc in index.primary.items():
            for node in doc['chain_graph']['nodes']:
                if node['primitive'] == primitive and node['position'] == 'escalation':
                    chain_ids.append(cid)
                    break
    else:
        chain_ids = index.by_primitive.get(primitive, [])
    
    results = []
    for cid in chain_ids:
        doc = index.primary[cid].copy()
        doc['relevance_score'] = doc['success_rate']['real_world']
        results.append(doc)
    
    results.sort(key=lambda x: x['relevance_score'], reverse=True)
    return results
```

### Query 2: Find Chains by Impact

```python
def find_chains_by_impact(index: ChainingIndex, impact_category: str = None, 
                          min_level: str = None) -> list:
    """
    Find chains achieving a specific impact.
    
    Args:
        index: The chaining index
        impact_category: e.g., 'rce', 'ato', 'mass_data_extraction'
        min_level: minimum severity level (critical > high > medium > low)
    """
    level_order = ['low', 'medium', 'high', 'critical']
    
    if impact_category:
        chain_ids = index.by_impact.get(impact_category, [])
    elif min_level:
        min_idx = level_order.index(min_level)
        chain_ids = []
        for level in level_order[min_idx:]:
            chain_ids.extend(index.by_severity.get(level, []))
    else:
        chain_ids = list(index.primary.keys())
    
    results = []
    for cid in chain_ids:
        doc = index.primary[cid]
        results.append(doc)
    
    results.sort(key=lambda x: x['complexity_score'], reverse=True)
    return results
```

### Query 3: Find by Platform

```python
def find_by_platform(index: ChainingIndex, platform: str) -> list:
    chain_ids = index.by_platform.get(platform, [])
    return [index.primary[cid] for cid in chain_ids]
```

### Query 4: Find Shortest Chain for Impact

```python
def find_shortest_chain(index: ChainingIndex, impact_category: str) -> dict:
    chain_ids = index.by_impact.get(impact_category, [])
    if not chain_ids:
        return None
    
    shortest = None
    min_nodes = float('inf')
    for cid in chain_ids:
        doc = index.primary[cid]
        node_count = len(doc['chain_graph']['nodes'])
        if node_count < min_nodes:
            min_nodes = node_count
            shortest = doc
    return shortest
```

### Query 5: Find Chains Combining Two Primitives

```python
def find_chains_with_pair(index: ChainingIndex, prim1: str, prim2: str) -> list:
    set1 = set(index.by_primitive.get(prim1, []))
    set2 = set(index.by_primitive.get(prim2, []))
    intersection = set1 & set2
    return [index.primary[cid] for cid in intersection]
```

### Query 6: Find Most Versatile Primitives

```python
def find_most_versatile_primitives(index: ChainingIndex, top_n: int = 10) -> list:
    ranked = sorted(
        index.primitive_stats.items(),
        key=lambda x: x[1]['total_appearances'],
        reverse=True
    )
    return ranked[:top_n]
```

---

## Search Algorithms

### Graph Traversal for Chain Discovery

```python
from collections import deque

class ChainGraphSearch:
    def __init__(self, index: ChainingIndex):
        self.index = index
    
    def find_chains_from_entry(self, entry_primitive: str, max_depth: int = 5) -> list:
        """BFS from entry primitive to find all reachable chains."""
        results = []
        entry_chains = self.index.by_entry_primitive.get(entry_primitive, [])
        
        for cid in entry_chains:
            doc = self.index.primary[cid]
            graph = doc['chain_graph']
            
            visited = set()
            queue = deque([(n['node_id'], 0) for n in graph['nodes'] if n['position'] == 'entry'])
            
            while queue:
                node_id, depth = queue.popleft()
                if node_id in visited or depth > max_depth:
                    continue
                visited.add(node_id)
                
                for edge in graph['edges']:
                    if edge['from_node'] == node_id:
                        queue.append((edge['to_node'], depth + 1))
            
            doc['traversal_depth'] = len(visited)
            results.append(doc)
        
        return results
    
    def find_paths_between(self, start_primitive: str, end_primitive: str) -> list:
        """Find all chains that connect start_primitive to end_primitive."""
        start_chains = set(self.index.by_primitive.get(start_primitive, []))
        end_chains = set(self.index.by_primitive.get(end_primitive, []))
        connecting = start_chains & end_chains
        
        paths = []
        for cid in connecting:
            doc = self.index.primary[cid]
            path = self._extract_path(doc['chain_graph'], start_primitive, end_primitive)
            if path:
                paths.append({"chain_id": cid, "path": path, "doc": doc})
        
        return paths
    
    def _extract_path(self, graph: dict, start: str, end: str) -> list:
        start_nodes = [n for n in graph['nodes'] if n['primitive'] == start]
        end_nodes = [n for n in graph['nodes'] if n['primitive'] == end]
        
        if not start_nodes or not end_nodes:
            return []
        
        for sn in start_nodes:
            for en in end_nodes:
                path = self._bfs_path(graph, sn['node_id'], en['node_id'])
                if path:
                    return path
        return []
    
    def _bfs_path(self, graph: dict, start: str, end: str) -> list:
        adj = {}
        for edge in graph['edges']:
            adj.setdefault(edge['from_node'], []).append(edge['to_node'])
        
        visited = {start}
        queue = deque([(start, [start])])
        
        while queue:
            node, path = queue.popleft()
            if node == end:
                return path
            for neighbor in adj.get(node, []):
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append((neighbor, path + [neighbor]))
        return []
```

### BM25 Search Over Chain Descriptions

```python
import math

class ChainBM25:
    def __init__(self, index: ChainingIndex, k1: float = 1.5, b: float = 0.75):
        self.index = index
        self.k1 = k1
        self.b = b
        self.avg_dl = 0
        self._compute_avg_dl()
    
    def _tokenize(self, text: str) -> list:
        import re
        tokens = re.findall(r'[a-z0-9]+', text.lower())
        stopwords = {'the', 'a', 'an', 'is', 'are', 'in', 'on', 'for', 'of', 'and', 'or', 'to'}
        return [t for t in tokens if t not in stopwords]
    
    def _compute_avg_dl(self):
        total = 0
        for doc in self.index.primary.values():
            text = f"{doc['chain_title']} {' '.join(doc['primitives_used'])} {doc['impact']['category']}"
            total += len(self._tokenize(text))
        self.avg_dl = total / max(len(self.index.primary), 1)
    
    def search(self, query: str) -> list:
        query_tokens = self._tokenize(query)
        scores = []
        
        for cid, doc in self.index.primary.items():
            text = f"{doc['chain_title']} {' '.join(doc['primitives_used'])} {doc['impact']['category']} {' '.join(doc.get('tags', []))}"
            doc_tokens = self._tokenize(text)
            doc_len = len(doc_tokens)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                df = sum(1 for d in self.index.primary.values() 
                         if qt in f"{d['chain_title']} {' '.join(d['primitives_used'])}".lower())
                idf = math.log((len(self.index.primary) - df + 0.5) / (df + 0.5) + 1)
                numerator = tf * (self.k1 + 1)
                denominator = tf + self.k1 * (1 - self.b + self.b * doc_len / self.avg_dl)
                score += idf * numerator / denominator
            
            if score > 0:
                scores.append((cid, score))
        
        scores.sort(key=lambda x: x[1], reverse=True)
        return [(cid, s, self.index.primary[cid]) for cid, s in scores]
```

---

## Relevance Scoring

```python
def compute_chain_relevance(doc: dict, query: dict) -> float:
    """
    Composite relevance score for chain records.
    
    Components:
    - Primitive match: 0.0-0.35
    - Impact match: 0.0-0.25
    - Success rate: 0.0-0.2
    - Complexity fit: 0.0-0.1
    - Recency: 0.0-0.1
    """
    score = 0.0
    
    # Primitive match
    if 'primitive' in query:
        if query['primitive'] in doc['primitives_used']:
            score += 0.35
            # Bonus for entry role
            for node in doc['chain_graph']['nodes']:
                if node['primitive'] == query['primitive'] and node['position'] == 'entry':
                    score += 0.05
                    break
    
    # Impact match
    if 'impact_category' in query:
        if doc['impact']['category'] == query['impact_category']:
            score += 0.25
    if 'min_severity' in query:
        level_order = ['low', 'medium', 'high', 'critical']
        if level_order.index(doc['impact']['level']) >= level_order.index(query['min_severity']):
            score += 0.15
    
    # Success rate
    score += doc['success_rate']['real_world'] * 0.2
    
    # Complexity fit
    if 'max_complexity' in query:
        if doc['complexity_score'] <= query['max_complexity']:
            score += 0.1
    else:
        score += 0.1
    
    # Recency
    from datetime import datetime
    try:
        verified = datetime.fromisoformat(doc['last_verified'] or doc['first_documented'])
        days_ago = (datetime.now() - verified).days
        recency = max(0, 1.0 - (days_ago / 365))
        score += recency * 0.1
    except:
        score += 0.05
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_chaining_index(index: ChainingIndex, new_file: Path):
    doc = extract_chain_metadata(new_file)
    index.add(doc)

def remove_chain(index: ChainingIndex, chain_id: str):
    if chain_id not in index.primary:
        return
    doc = index.primary[chain_id]
    
    for p in doc['primitives_used']:
        if p in index.by_primitive and chain_id in index.by_primitive[p]:
            index.by_primitive[p].remove(chain_id)
    
    for cat_list in index.by_impact.values():
        if chain_id in cat_list:
            cat_list.remove(chain_id)
    
    for sev_list in index.by_severity.values():
        if chain_id in sev_list:
            sev_list.remove(chain_id)
    
    for plat_list in index.by_platform.values():
        if chain_id in plat_list:
            plat_list.remove(chain_id)
    
    del index.primary[chain_id]

def verify_chaining_index(index: ChainingIndex) -> dict:
    issues = []
    for cid, doc in index.primary.items():
        if not doc.get('chain_graph', {}).get('nodes'):
            issues.append(f"Chain {cid} has empty graph")
        if not doc.get('primitives_used'):
            issues.append(f"Chain {cid} has no primitives")
        if doc.get('complexity_score', 0) < 1 or doc.get('complexity_score', 0) > 10:
            issues.append(f"Chain {cid} has invalid complexity_score")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

### Chain Modules (AC-01 through AC-49)

| # | File | Chain ID | Primitives | Impact | Complexity |
|---|------|----------|------------|--------|------------|
| 01 | `01-Basic-Vulnerability-Chaining.md` | AC-01 | sqli, xss | rce | 3 |
| 02 | `02-Information-Disclosure-to-RCE.md` | AC-02 | lfi, cmd_injection | rce | 5 |
| 03 | `03-XSS-to-Account-Takeover.md` | AC-03 | xss, csrf | ato | 4 |
| 04 | `04-IDOR-to-Mass-Data-Extraction.md` | AC-04 | idor | mass_data_extraction | 2 |
| 05 | `05-SQL-Injection-to-Shell-Access.md` | AC-05 | sqli, cmd_injection | rce | 6 |
| 06 | `06-SSRF-to-Internal-Network-Compromise.md` | AC-06 | ssrf, lateral_movement | lateral_movement | 7 |
| 07 | `07-CORS-Misconfiguration-Chains.md` | AC-07 | cors, xss | ato | 4 |
| 08 | `08-CSRF-to-Privilege-Escalation.md` | AC-08 | csrf, auth_bypass | ato | 5 |
| 09 | `09-File-Upload-to-Web-Shell.md` | AC-09 | file_upload, rce | rce | 4 |
| 10 | `10-XXE-to-Sensitive-Data-Access.md` | AC-10 | xxe | mass_data_extraction | 3 |
| 11 | `11-Deserialization-to-RCE.md` | AC-11 | deserialization, rce | rce | 7 |
| 12 | `12-JWT-Manipulation-Chains.md` | AC-12 | jwt, auth_bypass | ato | 5 |
| 13 | `13-SSTI-to-Complete-Compromise.md` | AC-13 | ssti, rce | full_compromise | 7 |
| 15 | `15-NoSQL-Injection-to-Data-Breach.md` | AC-15 | no_sql | mass_data_extraction | 4 |
| 16 | `16-GraphQL-Abuse-Chains.md` | AC-16 | graphql, idor | mass_data_extraction | 5 |
| 17 | `17-WebSocket-Security-Chains.md` | AC-17 | websocket, xss | ato | 5 |
| 18 | `18-Prototype-Pollution-Exploitation.md` | AC-18 | prototype_pollution, rce | rce | 6 |
| 19 | `19-HTTP-Request-Smuggling-Chains.md` | AC-19 | http_smuggling | ato | 7 |
| 20 | `20-Host-Header-Injection-Chains.md` | AC-20 | host_header | ato | 4 |
| 21 | `21-DNS-Rebinding-Attacks.md` | AC-21 | dns_rebinding, ssrf | lateral_movement | 6 |
| 22 | `22-Race-Condition-Exploitation.md` | AC-22 | race_condition | financial_fraud | 5 |
| 23 | `23-Subdomain-Takeover-Chains.md` | AC-23 | subdomain_takeover, xss | ato | 5 |
| 24 | `24-Open-Redirect-to-Phishing.md` | AC-24 | open_redirect | ato | 3 |
| 25 | `25-Content-Spoofing-Chains.md` | AC-25 | content_spoofing | ato | 3 |
| 26 | `26-WebCache-Poisoning-Chains.md` | AC-26 | webcache_poisoning, xss | ato | 6 |
| 27 | `27-Clickjacking-to-Account-Compromise.md` | AC-27 | clickjacking | ato | 3 |
| 28 | `28-Parameter-Pollution-Attacks.md` | AC-28 | parameter_pollution, auth_bypass | ato | 4 |
| 29 | `29-LDAP-Injection-Chains.md` | AC-29 | ldap, auth_bypass | ato | 5 |
| 30 | `30-XPath-Injection-Exploitation.md` | AC-30 | xpath | mass_data_extraction | 4 |
| 31 | `31-Session-Puzzling-Techniques.md` | AC-31 | session_puzzling | ato | 5 |
| 32 | `32-Insecure-File-Handling-Chains.md` | AC-32 | file_handling, lfi | rce | 4 |
| 33 | `33-Cross-Site-Script-Inclusion.md` | AC-33 | xss | ato | 3 |
| 34 | `34-HTTP-Response-Splitting.md` | AC-34 | xss | ato | 3 |
| 35 | `35-Client-Side-Storage-Abuse.md` | AC-35 | client_side_storage | ato | 3 |
| 36 | `36-Cryptography-Weakness-Chains.md` | AC-36 | cryptography | mass_data_extraction | 6 |
| 37 | `37-Third-Party-Component-Chains.md` | AC-37 | supply_chain | full_compromise | 7 |
| 38 | `38-Configuration-Misconfiguration-Chains.md` | AC-38 | cloud_misconfig | full_compromise | 5 |
| 39 | `39-Network-Infrastructure-Chains.md` | AC-39 | network_infrastructure | lateral_movement | 7 |
| 40 | `40-Mobile-API-Chains.md` | AC-40 | mobile_api, auth_bypass | ato | 5 |
| 41 | `41-Cloud-Misconfiguration-Chains.md` | AC-41 | cloud_misconfig | cloud_takeover | 6 |
| 42 | `42-Container-Escape-Chains.md` | AC-42 | cloud_misconfig | full_compromise | 8 |
| 43 | `43-Kubernetes-Attack-Chains.md` | AC-43 | cloud_misconfig, auth_bypass | full_compromise | 8 |
| 44 | `44-Blockchain-Exploit-Chains.md` | AC-44 | supply_chain | financial_fraud | 7 |
| 45 | `45-IoT-Device-Compromise-Chains.md` | AC-45 | network_infrastructure | full_compromise | 8 |
| 46 | `46-Supply-Chain-Attack-Chains.md` | AC-46 | supply_chain | full_compromise | 9 |
| 47 | `47-Zero-Day-Chaining-Strategies.md` | AC-47 | xss, sqli, rce | full_compromise | 9 |
| 48 | `48-Multi-Platform-Attack-Chains.md` | AC-48 | web, mobile, cloud | full_compromise | 9 |
| 49 | `49-Advanced-Persistent-Threat-Chains.md` | AC-49 | multiple | apt_simulation | 10 |
| 50 | `50-Master-Chaining-Framework.md` | AC-50 | multiple | full_compromise | 10 |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and chaining methodology |
| `registry.json` | Machine-readable chain registry |

---

## Cross-Domain References

- **advanced-automation.md** — Automation modules generate data consumed by chaining analysis.
- **core-prompts-hunting.md** — Hunting findings feed into chain construction.
- **real-world-case-studies.md** — Disclosed reports validate chain effectiveness.
- **report-writing-mastery.md** — Chain findings require specialized reporting templates.

---

## Usage Examples

### Example 1: Find All XSS Entry Chains

```python
results = find_chains_by_primitive(index, 'xss', role='entry')
# Returns: AC-03 (XSS-to-ATO), AC-07, AC-17, AC-23, etc.
```

### Example 2: Find RCE Chains Under Complexity 6

```python
results = find_chains_by_impact(index, impact_category='rce')
low_complexity = [r for r in results if r['complexity_score'] <= 6]
```

### Example 3: Find Chains Connecting SSRF to RCE

```python
paths = find_paths_between(search, 'ssrf', 'rce')
```

### Example 4: Get Co-Occurrence Stats

```python
co = index.get_co_occurring('xss')
# Returns: [('csrf', 8), ('idor', 5), ('jwt', 3), ...]
```
