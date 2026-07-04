# Report Writing Mastery — Memory Index Definition

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `report-writing-mastery` |
| Root Path | `Report-Writing-Mastery/` |
| File Count | 54 primary files + README + registry.json |
| Index Type | Report-centric (platform, status, severity) |
| Last Updated | 2026-06-26 |
| Schema Version | 1.0.0 |

---

## Overview

The Report Writing Mastery domain index manages metadata for 54 reporting modules covering report structure, technical writing, PoC development, severity assessment, remediation, templates, and platform-specific formatting. Each file provides guidance on producing high-quality bug bounty reports. The index organizes modules by platform, reporting stage, severity level, and report status.

This index supports two primary query patterns:
1. **Find accepted reports** — given a platform and status, retrieve all modules that produce reports likely to be accepted.
2. **Find reports needing follow-up** — given a report status, retrieve modules for improving or following up on reports.

---

## Index Schema

### Primary Index: `writing_records`

```json
{
  "doc_type": "writing_record",
  "file_ref": "Report-Writing-Mastery/<filename>.md",
  "module_id": "RW-<number>",
  "module_title": "<title>",
  "category": "enum[structure|writing_standards|case_study|poc|severity|remediation|executive_summary|technical_detail|visual_aids|code_formatting|timeline|collaboration|formatting|language|attachments|follow_up|rejection|negotiation|template|qa_process|grammar|accuracy|impact_quantification|business_context|compliance|international|audience|information_hierarchy|actionable|review|pitfalls|advanced_formatting|multimedia|interactive|cross_platform|version_control|analytics|peer_review|feedback|improvement|personalization|contextual|depth_calibration|impact_visualization|archiving|collaboration_standards|advanced_poc|automation_tools|quality_metrics|master_framework|bugcrowd_dissection|hackerone_analysis|high_severity_analysis|impact_communication]",
  "platforms": ["enum[hackerone|bugcrowd|intigriti|yeswehack|all]"],
  "report_stage": "enum[drafting|review|submission|follow_up|negotiation|archiving]",
  "severity_focus": "enum[all|critical|high|medium|low|info]",
  "report_status": "enum[accepted|pending|rejected|duplicate|informative|needs_improvement]",
  "skills_taught": ["string"],
  "applicable_vuln_classes": ["string"],
  "tags": ["string"],
  "first_documented": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### Secondary Index: `platform_index`

```json
{
  "platform": "string",
  "modules": ["RW-<number>"],
  "template_count": "integer",
  "avg_severity": "float"
}
```

### Tertiary Index: `stage_index`

```json
{
  "stage": "string",
  "modules": ["RW-<number>"],
  "total_skills": "integer"
}
```

---

## Index Creation

```python
import re
from pathlib import Path
from datetime import datetime

def extract_writing_metadata(filepath: Path) -> dict:
    content = filepath.read_text(encoding='utf-8')
    filename = filepath.stem
    
    match = re.match(r'^(\d+)-(.+)$', filename)
    if not match:
        module_num = 0
        module_slug = filename
    else:
        module_num = int(match.group(1))
        module_slug = match.group(2)
    
    category = classify_writing_category(filename, module_slug, content)
    platforms = extract_platforms(content)
    stage = detect_report_stage(content, module_slug)
    severity = detect_severity_focus(content)
    status = detect_report_status(content)
    skills = extract_skills(content)
    vuln_classes = extract_vuln_classes(content)
    
    return {
        "doc_type": "writing_record",
        "file_ref": f"Report-Writing-Mastery/{filepath.name}",
        "module_id": f"WR-{module_num:02d}" if module_num > 0 else f"WR-{filename[:8]}",
        "module_title": format_title(module_slug),
        "category": category,
        "platforms": platforms,
        "report_stage": stage,
        "severity_focus": severity,
        "report_status": status,
        "skills_taught": skills,
        "applicable_vuln_classes": vuln_classes,
        "tags": extract_tags(content),
        "first_documented": extract_date(content),
        "last_verified": None
    }

def classify_writing_category(filename: str, slug: str, content: str) -> str:
    text = (filename + ' ' + slug + ' ' + content).lower()
    mapping = {
        'report-structure': 'structure', 'structure-optimization': 'structure',
        'technical-writing': 'writing_standards', 'writing-standards': 'writing_standards',
        'private-program': 'case_study', 'case-study': 'case_study',
        'proof-of-concept': 'poc', 'poc-development': 'poc',
        'vulnerability-severity': 'severity', 'severity-assessment': 'severity',
        'remediation': 'remediation', 'recommendations': 'remediation',
        'executive-summary': 'executive_summary', 'crafting': 'executive_summary',
        'technical-detail': 'technical_detail', 'balancing': 'technical_detail',
        'visual-aid': 'visual_aids', 'integration': 'visual_aids',
        'code-sample': 'code_formatting', 'formatting': 'code_formatting',
        'timeline': 'timeline', 'documentation': 'timeline',
        'collaboration-crediting': 'collaboration',
        'program-specific': 'formatting', 'formatting-techniques': 'formatting',
        'language': 'language', 'tone-optimization': 'language',
        'attachment': 'attachments', 'management': 'attachments',
        'follow-up': 'follow_up', 'communication': 'follow_up',
        'rejection': 'rejection', 'analysis': 'rejection',
        'reward-negotiation': 'negotiation', 'preparation': 'negotiation',
        'report-template': 'template', 'development': 'template',
        'quality-assurance': 'qa_process', 'process': 'qa_process',
        'grammar': 'grammar', 'style': 'grammar',
        'technical-accuracy': 'accuracy', 'verification': 'accuracy',
        'impact-quantification': 'impact_quantification',
        'business-context': 'business_context', 'integration': 'business_context',
        'compliance': 'compliance', 'documentation': 'compliance',
        'international': 'international', 'standard': 'international',
        'audience': 'audience', 'analysis': 'audience',
        'information-hierarchy': 'information_hierarchy',
        'actionable': 'actionable', 'recommendations': 'actionable',
        'review-process': 'review', 'report-review': 'review',
        'common-pitfalls': 'pitfalls', 'avoidance': 'pitfalls',
        'advanced-formatting': 'advanced_formatting',
        'multimedia': 'multimedia', 'interactive': 'interactive',
        'cross-platform': 'cross_platform', 'compatibility': 'cross_platform',
        'version-control': 'version_control',
        'analytics': 'analytics', 'metrics': 'analytics',
        'peer-review': 'peer_review', 'optimization': 'peer_review',
        'feedback': 'feedback', 'incorporation': 'feedback',
        'continuous-improvement': 'improvement',
        'personalization': 'personalization',
        'contextual': 'contextual', 'intelligence': 'contextual',
        'depth-calibration': 'depth_calibration',
        'impact-visualization': 'impact_visualization',
        'archiving': 'archiving', 'strategy': 'archiving',
        'collaboration-report': 'collaboration_standards',
        'advanced-proof': 'advanced_poc',
        'automation-tools': 'automation_tools',
        'quality-metrics': 'quality_metrics',
        'master-framework': 'master_framework',
        'bugcrowd-finding': 'bugcrowd_dissection',
        'hackerone-report': 'hackerone_analysis',
        'high-severity': 'high_severity_analysis',
        'impact-communication': 'impact_communication',
    }
    for key, val in mapping.items():
        if key in text:
            return val
    return 'structure'

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

def detect_report_stage(content: str, slug: str) -> str:
    text = (slug + ' ' + content).lower()
    if any(kw in text for kw in ['draft', 'write', 'create', 'structure']):
        return 'drafting'
    if any(kw in text for kw in ['review', 'check', 'verify', 'qa']):
        return 'review'
    if any(kw in text for kw in ['submit', 'send', 'file']):
        return 'submission'
    if any(kw in text for kw in ['follow-up', 'follow up', 'status']):
        return 'follow_up'
    if any(kw in text for kw in ['negotiate', 'appeal', 'dispute']):
        return 'negotiation'
    if any(kw in text for kw in ['archive', 'store', 'version']):
        return 'archiving'
    return 'drafting'

def detect_severity_focus(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['critical', 'highest severity']):
        return 'critical'
    if 'high severity' in text or 'high-impact' in text:
        return 'high'
    if 'medium severity' in text:
        return 'medium'
    if 'low severity' in text:
        return 'low'
    return 'all'

def detect_report_status(content: str) -> str:
    text = content.lower()
    if any(kw in text for kw in ['accepted', 'fixed', 'resolved']):
        return 'accepted'
    if any(kw in text for kw in ['rejected', 'not applicable', 'wontfix']):
        return 'rejected'
    if any(kw in text for kw in ['duplicate', 'already known']):
        return 'duplicate'
    if any(kw in text for kw in ['informative', 'informational']):
        return 'informative'
    if any(kw in text for kw in ['needs improvement', 'revise', 'resubmit']):
        return 'needs_improvement'
    return 'pending'

def extract_skills(content: str) -> list:
    skills = []
    text = content.lower()
    skill_keywords = [
        'technical writing', 'report structure', 'poc development',
        'severity assessment', 'remediation', 'impact quantification',
        'code formatting', 'visual aids', 'timeline documentation',
        'collaboration', 'negotiation', 'follow-up communication',
        'rejection handling', 'quality assurance', 'peer review'
    ]
    for skill in skill_keywords:
        if skill in text:
            skills.append(skill)
    return skills[:10] if skills else ['report writing']

def extract_vuln_classes(content: str) -> list:
    text = content.lower()
    vuln_classes = []
    vc_keywords = [
        'xss', 'sqli', 'ssrf', 'csrf', 'idor', 'xxe', 'ssti',
        'rce', 'lfi', 'auth_bypass', 'jwt', 'deserialization',
        'race_condition', 'file_upload', 'info_disclosure'
    ]
    for vc in vc_keywords:
        if vc.replace('_', ' ') in text or vc in text:
            vuln_classes.append(vc)
    return vuln_classes if vuln_classes else ['general']

def extract_tags(content: str) -> list:
    tags = []
    tag_keywords = [
        'template', 'guide', 'tutorial', 'best-practice',
        'checklist', 'framework', 'methodology', 'workflow'
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

### Build Writing Index

```python
class WritingIndex:
    def __init__(self):
        self.primary = {}
        self.by_category = {}
        self.by_platform = {}
        self.by_stage = {}
        self.by_severity = {}
        self.by_status = {}
    
    def add(self, doc: dict):
        mid = doc['module_id']
        self.primary[mid] = doc
        
        self.by_category.setdefault(doc['category'], []).append(mid)
        
        for plat in doc['platforms']:
            self.by_platform.setdefault(plat, []).append(mid)
        
        self.by_stage.setdefault(doc['report_stage'], []).append(mid)
        self.by_severity.setdefault(doc['severity_focus'], []).append(mid)
        self.by_status.setdefault(doc['report_status'], []).append(mid)
    
    def find_accepted_modules(self, platform: str = None) -> list:
        accepted = self.by_status.get('accepted', [])
        if platform:
            plat_modules = set(self.by_platform.get(platform, []))
            accepted = [mid for mid in accepted if mid in plat_modules]
        return [self.primary[mid] for mid in accepted]
    
    def find_follow_up_modules(self) -> list:
        follow_up = self.by_stage.get('follow_up', [])
        needs_improvement = self.by_status.get('needs_improvement', [])
        combined = list(set(follow_up + needs_improvement))
        return [self.primary[mid] for mid in combined]
    
    def find_by_platform(self, platform: str) -> list:
        mids = self.by_platform.get(platform, [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_category(self, category: str) -> list:
        mids = self.by_category.get(category, [])
        return [self.primary[mid] for mid in mids]
    
    def find_by_stage(self, stage: str) -> list:
        mids = self.by_stage.get(stage, [])
        return [self.primary[mid] for mid in mids]
    
    def find_template_modules(self) -> list:
        mids = self.by_category.get('template', [])
        return [self.primary[mid] for mid in mids]
    
    def find_rejection_handling(self) -> list:
        mids = self.by_category.get('rejection', [])
        return [self.primary[mid] for mid in mids]
```

### Persist Index

```python
import json
from datetime import datetime

def persist_writing_index(index: WritingIndex, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    index_data = {
        "version": "1.0.0",
        "domain": "report-writing-mastery",
        "created": datetime.now().isoformat(),
        "doc_count": len(index.primary),
        "primary": index.primary,
        "inverted": {
            "by_category": index.by_category,
            "by_platform": index.by_platform,
            "by_stage": index.by_stage,
            "by_severity": index.by_severity,
            "by_status": index.by_status,
        }
    }
    
    index_file = output_dir / "writing-index.json"
    index_file.write_text(json.dumps(index_data, indent=2), encoding='utf-8')
```

---

## Query API

### Query 1: Find Accepted Reports

```python
def find_accepted_reports(index: WritingIndex, platform: str = None) -> list:
    return index.find_accepted_modules(platform)
```

### Query 2: Find Reports Needing Follow-Up

```python
def find_follow_up_reports(index: WritingIndex) -> list:
    return index.find_follow_up_modules()
```

### Query 3: Find by Platform

```python
def find_by_platform(index: WritingIndex, platform: str) -> list:
    return index.find_by_platform(platform)
```

### Query 4: Find Templates

```python
def find_templates(index: WritingIndex) -> list:
    return index.find_template_modules()
```

### Query 5: Find Rejection Handling

```python
def find_rejection_handling(index: WritingIndex) -> list:
    return index.find_rejection_handling()
```

### Query 6: Find by Stage

```python
def find_by_stage(index: WritingIndex, stage: str) -> list:
    return index.find_by_stage(stage)
```

---

## Search Algorithms

### Writing Module Scoring

```python
class WritingScorer:
    def __init__(self, index: WritingIndex):
        self.index = index
    
    def score_module(self, doc: dict, query: dict) -> float:
        score = 0.0
        
        if 'category' in query and doc['category'] == query['category']:
            score += 0.30
        if 'platform' in query and query['platform'] in doc['platforms']:
            score += 0.25
        if 'stage' in query and doc['report_stage'] == query['stage']:
            score += 0.20
        if 'severity' in query and doc['severity_focus'] == query['severity']:
            score += 0.15
        
        skill_bonus = min(len(doc['skills_taught']) / 10.0, 0.10)
        score += skill_bonus
        
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

class WritingBM25:
    def __init__(self, index: WritingIndex):
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
            text = f"{doc['module_title']} {doc['category']} {' '.join(doc['skills_taught'])} {' '.join(doc.get('tags', []))}"
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
def compute_writing_relevance(doc: dict, query: dict) -> float:
    score = 0.0
    
    if 'category' in query and doc['category'] == query['category']:
        score += 0.30
    if 'platform' in query and query['platform'] in doc['platforms']:
        score += 0.25
    if 'stage' in query and doc['report_stage'] == query['stage']:
        score += 0.20
    if 'severity' in query and doc['severity_focus'] == query['severity']:
        score += 0.15
    
    return min(score, 1.0)
```

---

## Index Maintenance

```python
def update_writing_index(index: WritingIndex, new_file: Path):
    doc = extract_writing_metadata(new_file)
    index.add(doc)

def remove_module(index: WritingIndex, module_id: str):
    if module_id not in index.primary:
        return
    doc = index.primary[module_id]
    
    for idx_map in [index.by_category, index.by_stage, index.by_severity, index.by_status]:
        for key, mids in idx_map.items():
            if module_id in mids:
                mids.remove(module_id)
    
    for plat in doc['platforms']:
        if plat in index.by_platform and module_id in index.by_platform[plat]:
            index.by_platform[plat].remove(module_id)
    
    del index.primary[module_id]

def verify_writing_index(index: WritingIndex) -> dict:
    issues = []
    for mid, doc in index.primary.items():
        if not doc.get('category'):
            issues.append(f"Module {mid} has no category")
        if not doc.get('skills_taught'):
            issues.append(f"Module {mid} has no skills")
    return {"total": len(index.primary), "issues": issues, "healthy": len(issues) == 0}
```

---

## Full Domain File References

| # | File | Module ID | Category | Platform | Stage |
|---|------|-----------|----------|----------|-------|
| 01 | `01-Report-Structure-Optimization.md` | WR-01 | structure | all | drafting |
| 02 | `02-Technical-Writing-Standards.md` | WR-02 | writing_standards | all | drafting |
| 03 | `03-Private-Program-Case-Study.md` | WR-03 | case_study | hackerone | drafting |
| 04 | `04-Proof-of-Concept-Development.md` | WR-04 | poc | all | drafting |
| 05 | `05-Vulnerability-Severity-Assessment.md` | WR-05 | severity | all | drafting |
| 06 | `06-Remediation-Recommendations.md` | WR-06 | remediation | all | drafting |
| 07 | `07-Executive-Summary-Crafting.md` | WR-07 | executive_summary | all | drafting |
| 08 | `08-Technical-Detail-Balancing.md` | WR-08 | technical_detail | all | drafting |
| 09 | `09-Visual-Aid-Integration.md` | WR-09 | visual_aids | all | drafting |
| 10 | `10-Code-Sample-Formatting.md` | WR-10 | code_formatting | all | drafting |
| 11 | `11-Timeline-Documentation.md` | WR-11 | timeline | all | drafting |
| 12 | `12-Collaboration-Crediting.md` | WR-12 | collaboration | all | drafting |
| 13 | `13-Program-Specific-Formatting.md` | WR-13 | formatting | all | drafting |
| 14 | `14-Language-and-Tone-Optimization.md` | WR-14 | language | all | drafting |
| 15 | `15-Attachment-Management.md` | WR-15 | attachments | all | drafting |
| 16 | `16-Follow-up-Communication.md` | WR-16 | follow_up | all | follow_up |
| 17 | `17-Rejection-Analysis-and-Improvement.md` | WR-17 | rejection | all | follow_up |
| 18 | `18-Reward-Negotiation-Preparation.md` | WR-18 | negotiation | all | negotiation |
| 19 | `19-Report-Template-Development.md` | WR-19 | template | all | drafting |
| 20 | `20-Quality-Assurance-Process.md` | WR-20 | qa_process | all | review |
| 21 | `21-Grammar-and-Style-Standards.md` | WR-21 | grammar | all | review |
| 22 | `22-Technical-Accuracy-Verification.md` | WR-22 | accuracy | all | review |
| 23 | `23-Impact-Quantification.md` | WR-23 | impact_quantification | all | drafting |
| 24 | `24-Business-Context-Integration.md` | WR-24 | business_context | all | drafting |
| 25 | `25-Compliance-Documentation.md` | WR-25 | compliance | all | drafting |
| 26 | `26-International-Standard-Adherence.md` | WR-26 | international | all | drafting |
| 27 | `27-Audience-Analysis.md` | WR-27 | audience | all | drafting |
| 28 | `28-Information-Hierarchy.md` | WR-28 | information_hierarchy | all | drafting |
| 29 | `29-Actionable-Recommendations.md` | WR-29 | actionable | all | drafting |
| 30 | `30-Report-Review-Process.md` | WR-30 | review | all | review |
| 31 | `31-Common-Pitfalls-Avoidance.md` | WR-31 | pitfalls | all | review |
| 32 | `32-Advanced-Formatting-Techniques.md` | WR-32 | advanced_formatting | all | drafting |
| 33 | `33-Multimedia-Integration.md` | WR-33 | multimedia | all | drafting |
| 34 | `34-Interactive-Report-Elements.md` | WR-34 | interactive | all | drafting |
| 35 | `35-Cross-Platform-Compatibility.md` | WR-35 | cross_platform | all | drafting |
| 36 | `36-Version-Control-for-Reports.md` | WR-36 | version_control | all | archiving |
| 37 | `37-Report-Analytics-and-Metrics.md` | WR-37 | analytics | all | archiving |
| 38 | `38-Peer-Review-Optimization.md` | WR-38 | peer_review | all | review |
| 39 | `39-Program-Feedback-Incorporation.md` | WR-39 | feedback | all | follow_up |
| 40 | `40-Continuous-Improvement.md` | WR-40 | improvement | all | follow_up |
| 41 | `41-Report-Personalization.md` | WR-41 | personalization | all | drafting |
| 42 | `42-Contextual-Intelligence.md` | WR-42 | contextual | all | drafting |
| 43 | `43-Technical-Depth-Calibration.md` | WR-43 | depth_calibration | all | drafting |
| 44 | `44-Impact-Visualization.md` | WR-44 | impact_visualization | all | drafting |
| 45 | `45-Report-Archiving-Strategy.md` | WR-45 | archiving | all | archiving |
| 46 | `46-Collaboration-Report-Standards.md` | WR-46 | collaboration_standards | all | drafting |
| 47 | `47-Advanced-Proof-of-Concept.md` | WR-47 | advanced_poc | all | drafting |
| 48 | `48-Report-Automation-Tools.md` | WR-48 | automation_tools | all | drafting |
| 49 | `49-Quality-Metrics-Development.md` | WR-49 | quality_metrics | all | review |
| 50 | `50-Master-Report-Writing-Framework.md` | WR-50 | master_framework | all | drafting |
| — | `Bugcrowd-Finding-Dissection.md` | WR-BD | bugcrowd_dissection | bugcrowd | drafting |
| — | `HackerOne-Report-Analysis.md` | WR-H1 | hackerone_analysis | hackerone | drafting |
| — | `High-Severity-Vulnerability-Analysis.md` | WR-HS | high_severity_analysis | all | drafting |
| — | `Impact-Communication.md` | WR-IC | impact_communication | all | drafting |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain overview and writing methodology |
| `registry.json` | Machine-readable module registry |

---

## Cross-Domain References

- **bug-bounty-program-strategy.md** — Strategy modules reference reporting for bounty outcomes.
- **bug-bounty-support.md** — Support modules share templates with reporting.
- **real-world-case-studies.md** — Disclosed reports validate writing standards.
- **core-prompts-hunting.md** — Hunting findings feed into report generation.

---

## Usage Examples

### Example 1: Find HackerOne Templates

```python
results = find_accepted_reports(index, platform='hackerone')
```

### Example 2: Find Follow-Up Modules

```python
results = find_follow_up_reports(index)
```

### Example 3: Find Report Templates

```python
results = find_templates(index)
```

### Example 4: Find Rejection Handling

```python
results = find_rejection_handling(index)
```
