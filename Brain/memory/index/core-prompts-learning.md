# Core Prompts Learning — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `core-prompts-learning` |
| Root Path | `Core-Prompts-Learning/` |
| File Count | 50 primary files + README + registry.json |
| Index Type | Module-centric (difficulty, topic, completion) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Core Prompts Learning domain index manages metadata for 50 learning modules covering security vulnerability classes, techniques, and methodologies. Each file is a structured learning module with exercises, examples, and assessments. The index organizes modules by difficulty level, topic, completion status, and prerequisite chains.

This index supports two primary query patterns:
1. **Find incomplete modules** — given a learner's completed modules, retrieve all modules whose prerequisites are satisfied but which haven't been completed.
2. **Find modules on SSRF** (or any topic) — given a topic, retrieve all learning modules that teach that topic.

---

## Index Schema

### Primary Index: `learning_records`

```json
{
  "doc_type": "learning_record",
  "file_ref": "Core-Prompts-Learning/<filename>.md",
  "module_id": "CL-<number>",
  "module_title": "<title>",
  "topic": "enum[recon|javascript|api|auth|authorization|input_validation|business_logic|client_storage|cryptography|error_handling|file_upload|ssrf|csrf|cors|race_condition|third_party|configuration|network|mobile_api|reporting|waf_bypass|http_smuggling|subdomain_takeover|host_header|xxe|deserialization|command_injection|nosql|graphql|websocket|ssti|jwt|csp_bypass|clickjacking|parameter_pollution|ldap|session_puzzling|file_handling|advanced_client_side|cloud|third_party_integration|mobile_app|iot|api_security|webassembly|blockchain|automation|reverse_engineering|compliance|threat_modeling]",
  "difficulty": "enum[beginner|intermediate|advanced|expert]",
  "estimated_hours": "float",
  "prerequisites": ["CL-<number>"],
  "learning_objectives": ["string"],
  "exercises_count": "integer",
  "assessment_type": "enum[quiz|hands_on|project|mixed]",
  "completion_status": "enum[not_started|in_progress|completed]",
  "completion_percentage": "float [0.0-1.0]",
  "tags": ["string"],
  "tools_taught": ["string"],
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `topic_index`

```json
{
  "topic": "string",
  "modules": ["CL-<number>"],
  "difficulty_progression": ["CL-<number>"],
  "total_hours": "float"
}
```

### Tertiary Index: `prerequisite_graph`

```json
{
  "module_id": "CL-<number>",
  "depends_on": ["CL-<number>"],
  "depended_by": ["CL-<number>"],
  "depth": "integer"
}
```

---

## Index Creation

```python
import re
from pathlib import Path
from datetime import datetime

def extract_learning_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)-Learning\.md$', filename)
    if not match:
        match = re.match(r'^(\d+)-(.+)$', filename)
    
    module_num = int(match.group(1)) if match else 0
    module_slug = match.group(2) if match else filename
    module_slug = module_slug.replace('-Learning', '')
    
    topic = classify_learning_topic(module_slug)
    difficulty = detect_difficulty(content, module_slug)
    hours = estimate_hours(content, difficulty)
    prereqs = extract_prerequisites(content, module_num)
    objectives = extract_learning_objectives(content)
    exercises = count_exercises(content)
    assessment = detect_assessment_type(content)
    tools = extract_tools(content)
    
    return {
        "doc_type": "learning_record",
        "file_ref": f"Core-Prompts-Learning/{filepath.name}",
        "module_id": f"CL-{module_num:02d}",
        "module_title": format_title(module_slug),
        "topic": topic,
        "difficulty": difficulty,
        "estimated_hours": hours,
        "prerequisites": prereqs,
        "learning_objectives": objectives,
        "exercises_count": exercises,
        "assessment_type": assessment,
        "completion_status": "not_started",
        "completion_percentage": 0.0,
        "tags": extract_tags(content),
        "tools_taught": tools,
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_learning_topic(slug: str) -> str:
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
        'advanced-client-side': 'advanced_client_side',
        'cloud': 'cloud', 'misconfiguration': 'cloud',
        'third-party-integration': 'third_party_integration',
        'mobile-application': 'mobile_app', 'mobile-security': 'mobile_app',
        'iot': 'iot', 'embedded': 'iot',
        'api-security': 'api_security',
        'webassembly': 'webassembly', 'wasm': 'webassembly',
        'blockchain': 'blockchain', 'smart-contract': 'blockchain',
        'automation': 'automation', 'tool-development': 'automation',
        'reverse-engineering': 'reverse_engineering',
        'compliance': 'compliance', 'regulatory': 'compliance',
        'threat-modeling': 'threat_modeling', 'risk-assessment': 'threat_modeling',
    }
    slug_lower = slug.lower()
    for key, val in mapping.items():
        if key in slug_lower:
            return val
    return 'recon'

def detect_difficulty(content: str, slug: str) -> str:
    text = (slug + ' ' + content).lower()
    if any(kw in text for kw in ['expert', 'advanced', 'complex', 'sophisticated']):
        return 'advanced'
    if any(kw in text for kw in ['intermediate', 'moderate']):
        return 'intermediate'
    if any(kw in text for kw in ['beginner', 'basic', 'introduction', 'getting started']):
        return 'beginner'
    return 'intermediate'

def estimate_hours(content: str, difficulty: str) -> float:
    text = content.lower()
    hours_match = re.search(r'(\d+(?:\.\d+)?)\s*(?:hours?|hrs?)', text)
    if hours_match:
        return float(hours_match.group(1))
    
    diff_hours = {'beginner': 2.0, 'intermediate': 4.0, 'advanced': 8.0, 'expert': 16.0}
    base = diff_hours.get(difficulty, 4.0)
    
    lines = len(content.split('\n'))
    return base * (1 + lines / 500)

def extract_prerequisites(content: str, module_num: int) -> list:
    prereqs = []
    text = content.lower()
    
    prereq_match = re.findall(r'(?:prerequisite|requires?|depends? on)\s+(?:module\s+)?(\d+)', text)
    for num in prereq_match:
        prereq_id = f"CL-{int(num):02d}"
        if prereq_id != f"CL-{module_num:02d}":
            prereqs.append(prereq_id)
    
    if module_num > 1 and not prereqs:
        prereqs.append(f"CL-{module_num - 1:02d}")
    
    return prereqs

def extract_learning_objectives(content: str) -> list:
    objectives = []
    lines = content.split('\n')
    in_objectives = False
    for line in lines:
        if 'learning objective' in line.lower() or 'objective' in line.lower():
            in_objectives = True
            continue
        if in_objectives:
            if line.startswith('#') or line.startswith('---'):
                in_objectives = False
                continue
            if line.startswith('-') or line.startswith('*') or re.match(r'^\d+\.', line):
                obj = re.sub(r'^[-*\d.]+\s*', '', line).strip()
                if obj:
                    objectives.append(obj)
    return objectives[:10] if objectives else ["Understand the vulnerability class"]

def count_exercises(content: str) -> int:
    exercise_count = 0
    text = content.lower()
    exercise_count += len(re.findall(r'exercise\s*\d+', text))
    exercise_count += len(re.findall(r'lab\s*\d+', text))
    exercise_count += len(re.findall(r'challenge\s*\d+', text))
    exercise_count += len(re.findall(r'practice\s*\d+', text))
    return max(exercise_count, 3)

def detect_assessment_type(content: str) -> str:
    text = content.lower()
    if 'quiz' in text and ('hands-on' in text or 'lab' in text):
        return 'mixed'
    if 'quiz' in text:
        return 'quiz'
    if any(kw in text for kw in ['hands-on', 'lab', 'practical']):
        return 'hands_on'
    if 'project' in text:
        return 'project'
    return 'mixed'

def extract_tools(content: str) -> list:
    text = content.lower()
    tools = []
    tool_names = [
        'burp suite', 'nmap', 'nikto', 'sqlmap', 'xsstrike', 'dalfox',
        'ffuf', 'gobuster', 'subfinder', 'httpx', 'nuclei', 'katana',
        'waybackurls', 'gau', 'amass', 'sublist3r', 'wpscan',
        'curl', 'python', 'ruby', 'nodejs', 'postman', 'zap',
        'chrome devtools', 'firefox', 'wireshark', 'mitmproxy'
    ]
    for tool in tool_names:
        if tool in text:
            tools.append(tool)
    return tools

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'owasp', 'top10', 'exercise', 'lab', 'assessment',
        'project', 'quiz', 'case-study', 'real-world'
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

### Build Learning Index

```python
class LearningIndex:
    def __init__(self):
        self.primary = {}
        self.by_topic = {}
        self.by_difficulty = {}
        self.by_assessment = {}
        self.by_prerequisite = {}
        self.by_tool = {}
        self.prerequisite_graph = {}
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        self.by_topic.setdefault(doc['topic'], []).append(mid)
        self.by_difficulty.setdefault(doc['difficulty'], []).append(mid)
        self.by_assessment.setdefault(doc['assessment_type'], []).append(mid)
        
        for tool in doc['tools_taught']:
            self.by_tool.setdefault(tool, []).append(mid)
        
        for prereq in doc['prerequisites']:
            self.by_prerequisite.setdefault(prereq, []).append(mid)
        
        self.prerequisite_graph[mid] = {
            "depends_on": doc['prerequisites'],
            "depended_by": [],
            "depth": 0
        }
        for prereq in doc['prerequisites']:
            if prereq in self.prerequisite_graph:
                self.prerequisite_graph[prereq]['depended_by'].append(mid)
        
        self._compute_depths()
    
    def _compute_depths(self):
        for mid in self.prerequisite_graph:
            depth = 0
            visited = set()
            queue = [mid]
            while queue:
                current = queue.pop(0)
                if current in visited:
                    continue
                visited.add(current)
                if current in self.prerequisite_graph:
                    for dep in self.prerequisite_graph[current]['depends_on']:
                        queue.append(dep)
                        depth += 1
            self.prerequisite_graph[mid]['depth'] = depth
    
    def find_incomplete_modules(self, completed: list = None) -> list:
        if completed is None:
            completed = []
        
        results = []
        for mid, doc in self.primary.items():
            if mid in completed:
                continue
            
            prereqs_met = all(p in completed for p in doc['prerequisites'])
            if prereqs_met:
                doc_copy = doc.copy()
                doc_copy['prereqs_met'] = True
                results.append(doc_copy)
        
        results.sort(key=lambda x: (
            {'beginner': 0, 'intermediate': 1, 'advanced': 2, 'expert': 3}.get(x['difficulty'], 1),
            x['estimated_hours']
        ))
        return results
    
    def find_modules_on_topic(self, topic: str) -> list:
        mids = self.by_topic.get(topic, [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_difficulty(self, difficulty: str) -> list:
        mids = self.by_difficulty.get(difficulty, [])
        return [self.primary[mid] for mid in mids]
    
    def get_learning_path(self, topic: str) -> list:
        mids = self.by_topic.get(topic, [])
        if not mids:
            return []
        
        sorted_modules = sorted(mids, key=lambda mid: self.primary[mid]['estimated_hours'])
        return [self.primary[mid] for mid in sorted_modules]
    
    def get_total_hours(self, difficulty: str = None) -> float:
        if difficulty:
            mids = self.by_difficulty.get(difficulty, [])
        else:
            mids = list(self.primary.keys())
        return sum(self.primary[mid]['estimated_hours'] for mid in mids)
```

### Persist Index

```python
import json
from datetime import datetime

def persist_learning_index(index: LearningIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "core-prompts-learning",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_topic": index.by_topic,
            "by_difficulty": index.by_difficulty,
            "by_assessment": index.by_assessment,
            "by_tool": index.by_tool,
            "by_prerequisite": index.by_prerequisite,
        },
        "prerequisite_graph": index.prerequisite_graph
    }
    
    index_file = output_dir / "learning-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Incomplete Modules

```python
def find_incomplete_modules(index: LearningIndex, completed: list = None) -> list:
    return index.find_incomplete_modules(completed)
```

### Query 2: Find Modules on SSRF

```python
def find_modules_on_topic(index: LearningIndex, topic: str) -> list:
    return index.find_modules_on_topic(topic)
```

### Query 3: Find Beginner Modules

```python
def find_beginner_modules(index: LearningIndex) -> list:
    return index.find_by_difficulty('beginner')
```

### Query 4: Get Learning Path

```python
def get_learning_path(index: LearningIndex, topic: str) -> list:
    return index.get_learning_path(topic)
```

### Query 5: Get Total Hours

```python
def get_total_hours(index: LearningIndex, difficulty: str = None) -> float:
    return index.get_total_hours(difficulty)
```

### Query 6: Find Modules Teaching a Tool

```python
def find_modules_by_tool(index: LearningIndex, tool: str) -> list:
    mids = index.by_tool.get(tool, [])
    return [index.primary[mid] for mid in mids]
```

---

## Search Algorithms

### Learning Path Optimizer

```python
class LearningPathOptimizer:
    def __init__(self, index: LearningIndex):
        self.index = index
    
    def optimize_path(self, start_module: str, end_module: str) -> list:
        """Find optimal learning path from start to end module."""
        if start_module not in self.index.primary or end_module not in self.index.primary:
            return []
        
        path = []
        visited = set()
        current = end_module
        
        while current and current not in visited:
            visited.add(current)
            doc = self.index.primary[current]
            path.append(doc)
            
            prereqs = doc['prerequisites']
            if prereqs:
                current = prereqs[0]
            else:
                break
        
        path.reverse()
        return path
    
    def suggest_next(self, completed: list) -> dict:
        """Suggest the best next module to study."""
        incomplete = self.index.find_incomplete_modules(completed)
        
        if not incomplete:
            return {"status": "all_completed", "next": None}
        
        scored = []
        for doc in incomplete:
            score = 0
            if doc['difficulty'] == 'beginner':
                score += 3
            elif doc['difficulty'] == 'intermediate':
                score += 2
            else:
                score += 1
            
            score += min(doc['exercises_count'] / 5.0, 1.0)
            
            if doc['estimated_hours'] <= 4:
                score += 0.5
            
            scored.append((doc, score))
        
        scored.sort(key=lambda x: x[1], reverse=True)
        return {"status": "continue", "next": scored[0][0], "alternatives": [s[0] for s in scored[1:4]]}
```

### BM25 Search

```python
import math

class LearningBM25:
    def __init__(self, index: LearningIndex):
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
            text = f"{doc['module_title']} {doc['topic']} {' '.join(doc['learning_objectives'])} {' '.join(doc.get('tags', []))}"
            doc_tokens = self._tokenize(text)
            
            tf_map = {}
            for t in doc_tokens:
                tf_map[t] = tf_map.get(t, 0) + 1
            
            score = 0
            for qt in query_tokens:
                tf = tf_map.get(qt, 0)
                if tf > 0:
                    df = sum(1 for d in self.index.primary.values() 
                             if qt in f"{d['module_title']} {d['topic']}".lower())
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
def compute_learning_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'topic' in query and doc['topic'] == query['topic']:
        score += 0.30
    if 'difficulty' in query and doc['difficulty'] == query['difficulty']:
        score += 0.25
    if 'assessment' in query and doc['assessment_type'] == query['assessment']:
        score += 0.15
    if 'max_hours' in query and doc['estimated_hours'] <= query['max_hours']:
        score += 0.15
    if 'tool' in query and query['tool'] in doc['tools_taught']:
        score += 0.15
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_learning_index(index: LearningIndex, new_file: Path):
    doc = extract_learning_metadata(new_file)
    index.add(doc)

def remove_module(index: LearningIndex, module_id: str):
    if module_id not in index.primary:
        return
    doc = index.primary[module_id]
    
    for idx_map in [index.by_topic, index.by_difficulty, index.by_assessment]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
    
    for tool in doc['tools_taught']:
        if tool in index.by_tool and module_id in index.by_tool[tool]:
            index.by_tool[tool].remove(module_id)
    
    if module_id in index.prerequisite_graph:
        del index.prerequisite_graph[module_id]
    
    del index.primary[module_id]

def verify_learning_index(index: LearningIndex) -> dict:
    issues = []
    for mid, doc in index.primary.items():
        for prereq in doc['prerequisites']:
            if prereq not in index.primary:
                issues.append(f"Module {mid} depends on non-existent {prereq}")
        if doc['estimated_hours'] <= 0:
            issues.append(f"Module {mid} has invalid estimated hours")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Module ID | Topic | Difficulty | Hours |
|---|------|-----------|-------|------------|-------|
| 01 | `1-Reconnaissance-and-Asset-Discovery-Learning.md` | CL-01 | recon | beginner | 3.0 |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | CL-02 | javascript | intermediate | 5.0 |
| 03 | `3-API-Endpoint-Analysis-Learning.md` | CL-03 | api | intermediate | 4.0 |
| 04 | `4-Authentication-and-Session-Management-Learning.md` | CL-04 | auth | intermediate | 4.0 |
| 05 | `5-Authorization-and-Access-Control-Learning.md` | CL-05 | authorization | intermediate | 4.0 |
| 06 | `6-Input-Validation-and-Sanitization-Learning.md` | CL-06 | input_validation | beginner | 3.0 |
| 07 | `7-Business-Logic-Flaws-Learning.md` | CL-07 | business_logic | advanced | 6.0 |
| 08 | `8-Client-Side-Storage-Security-Learning.md` | CL-08 | client_storage | beginner | 2.0 |
| 09 | `9-Cryptography-and-Data-Protection-Learning.md` | CL-09 | cryptography | intermediate | 5.0 |
| 10 | `10-Error-Handling-and-Information-Disclosure-Learning.md` | CL-10 | error_handling | beginner | 2.0 |
| 11 | `11-File-Upload-and-Processing-Learning.md` | CL-11 | file_upload | intermediate | 3.0 |
| 12 | `12-Server-Side-Request-Forgery-SSRF-Learning.md` | CL-12 | ssrf | intermediate | 5.0 |
| 13 | `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | CL-13 | csrf | intermediate | 3.0 |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | CL-14 | cors | intermediate | 3.0 |
| 15 | `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | CL-15 | race_condition | advanced | 5.0 |
| 16 | `16-Third-Party-Component-Analysis-Learning.md` | CL-16 | third_party | intermediate | 3.0 |
| 17 | `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | CL-17 | configuration | beginner | 2.0 |
| 18 | `18-Network-and-Infrastructure-Security-Learning.md` | CL-18 | network | advanced | 6.0 |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | CL-19 | mobile_api | advanced | 5.0 |
| 20 | `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | CL-20 | reporting | beginner | 2.0 |
| 21 | `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | CL-21 | waf_bypass | advanced | 6.0 |
| 22 | `22-HTTP-Request-Smuggling-Learning.md` | CL-22 | http_smuggling | expert | 8.0 |
| 23 | `23-Subdomain-Takeover-Learning.md` | CL-23 | subdomain_takeover | intermediate | 4.0 |
| 24 | `24-Host-Header-Injection-Learning.md` | CL-24 | host_header | intermediate | 3.0 |
| 25 | `25-XML-External-Entity-XXE-Injection-Learning.md` | CL-25 | xxe | intermediate | 4.0 |
| 26 | `26-Insecure-Deserialization-Learning.md` | CL-26 | deserialization | advanced | 6.0 |
| 27 | `27-Command-Injection-Learning.md` | CL-27 | command_injection | intermediate | 4.0 |
| 28 | `28-NoSQL-Injection-Learning.md` | CL-28 | nosql | intermediate | 4.0 |
| 29 | `29-GraphQL-Vulnerabilities-Learning.md` | CL-29 | graphql | advanced | 5.0 |
| 30 | `30-WebSocket-Security-Learning.md` | CL-30 | websocket | advanced | 4.0 |
| 31 | `31-Server-Side-Template-Injection-SSTI-Learning.md` | CL-31 | ssti | advanced | 6.0 |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | CL-32 | jwt | intermediate | 4.0 |
| 33 | `33-Content-Security-Policy-CSP-Bypass-Learning.md` | CL-33 | csp_bypass | advanced | 5.0 |
| 34 | `34-Clickjacking-and-UI-Redressing-Learning.md` | CL-34 | clickjacking | beginner | 2.0 |
| 35 | `35-HTTP-Parameter-Pollution-Learning.md` | CL-35 | parameter_pollution | intermediate | 3.0 |
| 36 | `36-LDAP-Injection-Learning.md` | CL-36 | ldap | advanced | 5.0 |
| 37 | `37-Session-Puzzling-and-Fixation-Learning.md` | CL-37 | session_puzzling | intermediate | 4.0 |
| 38 | `38-Insecure-File-Handling-Learning.md` | CL-38 | file_handling | intermediate | 3.0 |
| 39 | `39-Advanced-Client-Side-Attacks-Learning.md` | CL-39 | advanced_client_side | advanced | 6.0 |
| 40 | `40-Cloud-Security-and-Misconfigurations-Learning.md` | CL-40 | cloud | advanced | 6.0 |
| 41 | `41-Third-Party-Integration-Security-Learning.md` | CL-41 | third_party_integration | intermediate | 4.0 |
| 42 | `42-Mobile-Application-Security-Learning.md` | CL-42 | mobile_app | advanced | 6.0 |
| 43 | `43-IoT-and-Embedded-Device-Security-Learning.md` | CL-43 | iot | expert | 8.0 |
| 44 | `44-API-Security-and-GraphQL-Learning.md` | CL-44 | api_security | advanced | 5.0 |
| 45 | `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | CL-45 | webassembly | expert | 8.0 |
| 46 | `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | CL-46 | blockchain | expert | 10.0 |
| 47 | `47-Automation-and-Tool-Development-Learning.md` | CL-47 | automation | advanced | 6.0 |
| 48 | `48-Advanced-Reverse-Engineering-Learning.md` | CL-48 | reverse_engineering | expert | 10.0 |
| 49 | `49-Compliance-and-Regulatory-Security-Learning.md` | CL-49 | compliance | intermediate | 4.0 |
| 50 | `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | CL-50 | threat_modeling | expert | 8.0 |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and learning methodology |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

- **core-prompts-hunting.md** — Hunting modules reference learning for methodology.
- **real-world-case-studies.md** — Case studies provide learning examples.
- **bug-bounty-support.md** — Support modules reference learning prerequisites.

---

## Usage Examples

### Example 1: Find Incomplete Modules

```python
completed = ['CL-01', 'CL-02', 'CL-06']
results = find_incomplete_modules(index, completed)
```

### Example 2: Find SSRF Modules

```python
results = find_modules_on_topic(index, 'ssrf')
# Returns: CL-12
```

### Example 3: Get SSRF Learning Path

```python
path = get_learning_path(index, 'ssrf')
```

### Example 4: Suggest Next Module

```python
optimizer = LearningPathOptimizer(index)
suggestion = optimizer.suggest_next(['CL-01', 'CL-02', 'CL-06', 'CL-08'])
```
