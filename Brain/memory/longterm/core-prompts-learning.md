# Long-Term Memory: Core Prompts Learning

## Domain Mapping

- **Domain**: Core Prompts Learning
- **Root Directory**: `Core-Prompts-Learning/`
- **Total Files**: 50 (including README.md)
- **Purpose**: Persistent memory for module completion records, assessment history, knowledge graph, and learning progress

---

## Overview

This long-term memory system tracks the learning journey across all security domains. It maintains module completion records, assessment scores, knowledge gaps, and learning recommendations that personalize and accelerate skill development.

### Memory Categories

1. **Module Completion Records** - Track completed learning modules
2. **Assessment History** - Quiz and practical assessment scores
3. **Knowledge Graph** - Relationships between concepts and skills
4. **Learning Progress** - Progress tracking across domains
5. **Skill Proficiency** - Competency levels for each skill area

---

## Storage Schema

### Module Completion Record

```json
{
  "completion_id": "uuid-v4",
  "module_id": "string",
  "module_name": "string",
  "domain": "string",
  "category": "string",
  "difficulty": "enum: beginner|intermediate|advanced|expert",
  "started_date": "ISO-8601",
  "completed_date": "ISO-8601",
  "time_spent_minutes": "integer",
  "completion_status": "enum: in_progress|completed|skipped|failed",
  "score": "float 0-100",
  "notes": "string",
  "practical_applied": "boolean",
  "findings_from_practice": ["array"]
}
```

### Assessment Record

```json
{
  "assessment_id": "uuid-v4",
  "module_id": "string",
  "assessment_type": "enum: quiz|practical|challenge|real_world",
  "questions": [
    {
      "question_id": "string",
      "question_text": "string",
      "user_answer": "string",
      "correct_answer": "string",
      "is_correct": "boolean",
      "explanation": "string"
    }
  ],
  "total_questions": "integer",
  "correct_answers": "integer",
  "score": "float 0-100",
  "time_taken_seconds": "integer",
  "passed": "boolean",
  "attempt_number": "integer",
  "taken_date": "ISO-8601"
}
```

### Knowledge Graph Node

```json
{
  "node_id": "string",
  "concept_name": "string",
  "domain": "string",
  "category": "string",
  "difficulty": "enum: beginner|intermediate|advanced|expert",
  "mastery_level": "enum: novice|beginner|intermediate|advanced|expert",
  "mastery_score": "float 0-1",
  "relationships": [
    {
      "related_node_id": "string",
      "relationship_type": "enum: prerequisite|related|builds_on|applies_to",
      "strength": "float 0-1"
    }
  ],
  "learning_resources": ["array of resource_ids"],
  "assessments_taken": "integer",
  "avg_assessment_score": "float",
  "last_assessed": "ISO-8601"
}
```

### Learning Progress Record

```json
{
  "progress_id": "string",
  "domain": "string",
  "total_modules": "integer",
  "completed_modules": "integer",
  "in_progress_modules": "integer",
  "completion_percentage": "float",
  "avg_score": "float",
  "total_time_hours": "float",
  "streak_days": "integer",
  "last_activity": "ISO-8601",
  "milestones": [
    {
      "milestone_name": "string",
      "achieved_date": "ISO-8601",
      "description": "string"
    }
  ]
}
```

### Skill Proficiency Record

```json
{
  "skill_id": "string",
  "skill_name": "string",
  "domain": "string",
  "proficiency_level": "enum: novice|beginner|intermediate|advanced|expert",
  "proficiency_score": "float 0-1",
  "evidence": [
    {
      "type": "enum: assessment|practical|real_world",
      "score": "float",
      "date": "ISO-8601",
      "description": "string"
    }
  ],
  "recommended_next_steps": ["array"],
  "related_skills": ["array"],
  "last_updated": "ISO-8601"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/learning/completions
POST /memory/longterm/learning/assessments
POST /memory/longterm/learning/knowledge-graph
POST /memory/longterm/learning/progress
POST /memory/longterm/learning/skills
```

### Read

```
GET /memory/longterm/learning/completions/{completion_id}
GET /memory/longterm/learning/completions?module_id={id}
GET /memory/longterm/learning/assessments?module_id={id}&passed={boolean}
GET /memory/longterm/learning/knowledge-graph/{node_id}
GET /memory/longterm/learning/progress?domain={domain}
GET /memory/longterm/learning/skills?proficiency_level={level}
```

### Update

```
PATCH /memory/longterm/learning/completions/{completion_id}
PUT /memory/longterm/learning/knowledge-graph/{node_id}/mastery
PATCH /memory/longterm/learning/progress/{progress_id}
PATCH /memory/longterm/learning/skills/{skill_id}/proficiency
```

### Delete

```
DELETE /memory/longterm/learning/completions/{completion_id}
DELETE /memory/longterm/learning/assessments/{assessment_id}
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Module Completions | No expiration | Learning history persists |
| Assessments | 2 years | Historical assessment data |
| Knowledge Graph | No expiration | Concept relationships persist |
| Learning Progress | No expiration | Progress tracking persists |
| Skill Proficiency | 180 days | Skills need periodic refresh |

### TTL Enforcement

```python
def enforce_learning_ttl():
    completions.never_expire()
    assessments.archive_after_days(730)
    knowledge_graph.never_expire()
    progress.never_expire()
    skills.refresh_after_days(180)
```

---

## Compression

### Compression Strategy

- **Module Completions**: None (small records)
- **Assessments**: GZIP (question/answer data)
- **Knowledge Graph**: None (small graph data)
- **Learning Progress**: None (aggregated data)
- **Skill Proficiency**: None (small records)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "completions": {
    "completion_id": "primary_key",
    "module_id": "btree_index",
    "domain": "hash_index",
    "completion_status": "hash_index",
    "completed_date": "btree_index"
  },
  "assessments": {
    "assessment_id": "primary_key",
    "module_id": "btree_index",
    "assessment_type": "hash_index",
    "passed": "hash_index",
    "score": "btree_index"
  },
  "knowledge_graph": {
    "node_id": "primary_key",
    "domain": "hash_index",
    "mastery_level": "hash_index",
    "mastery_score": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "module_progress": ["module_id", "completion_status", "score"],
  "domain_mastery": ["domain", "mastery_level", "mastery_score"],
  "assessment_history": ["module_id", "attempt_number", "score"]
}
```

---

## Retrieval Patterns

### Pattern 1: Domain Completion Summary

```
SELECT domain,
       COUNT(*) as total_modules,
       COUNT(CASE WHEN completion_status = 'completed' THEN 1 END) as completed,
       AVG(score) as avg_score,
       SUM(time_spent_minutes) / 60.0 as total_hours
FROM completions
GROUP BY domain
ORDER BY completed DESC
```

**Use Case**: Get overall progress across domains.

### Pattern 2: Skill Gap Analysis

```
SELECT ng.node_id, ng.concept_name, ng.domain,
       ng.mastery_level, ng.mastery_score,
       ng.assessments_taken, ng.avg_assessment_score
FROM knowledge_graph ng
WHERE ng.mastery_level IN ('novice', 'beginner')
  AND ng.difficulty IN ('intermediate', 'advanced')
ORDER BY ng.mastery_score ASC
```

**Use Case**: Identify areas needing improvement.

### Pattern 3: Learning Path Recommendation

```
SELECT ng.node_id, ng.concept_name, ng.domain,
       ng.difficulty, ng.mastery_level,
       ng.relationships
FROM knowledge_graph ng
WHERE ng.mastery_level = 'novice'
  AND ng.relationships @> ARRAY[{
    "related_node_id": ?,
    "relationship_type": "prerequisite"
  }]
ORDER BY ng.difficulty
```

**Use Case**: Find next concepts to learn based on current knowledge.

### Pattern 4: Assessment Performance Analysis

```
SELECT module_id, 
       COUNT(*) as attempts,
       MAX(score) as best_score,
       AVG(score) as avg_score,
       COUNT(CASE WHEN passed THEN 1 END) as passes,
       MAX(taken_date) as last_attempt
FROM assessments
WHERE module_id = ?
GROUP BY module_id
```

**Use Case**: Track assessment performance over time.

### Pattern 5: Skill Proficiency Dashboard

```
SELECT domain,
       proficiency_level,
       COUNT(*) as skill_count,
       AVG(proficiency_score) as avg_proficiency
FROM skills
GROUP BY domain, proficiency_level
ORDER BY domain, 
  CASE proficiency_level
    WHEN 'expert' THEN 1
    WHEN 'advanced' THEN 2
    WHEN 'intermediate' THEN 3
    WHEN 'beginner' THEN 4
    WHEN 'novice' THEN 5
  END
```

**Use Case**: Visualize skill distribution across levels.

---

## Consolidation Triggers

### Automatic Consolidation

1. **After each assessment**: Update knowledge graph mastery
2. **Weekly**: Recalculate domain completion percentages
3. **Monthly**: Refresh skill proficiency scores
4. **Quarterly**: Archive old assessments, update progress

### Event-Triggered Consolidation

1. **Module completed**: Update domain progress
2. **Assessment passed**: Update skill proficiency
3. **New concept mastered**: Update knowledge graph relationships
4. **Learning streak achieved**: Update streak counter

### Manual Consolidation

```
POST /memory/longterm/learning/consolidate
{
  "action": "update_graph|recalculate_progress|refresh_skills",
  "domain": "optional filter"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Core-Prompts-Hunting | Output | Practical application results |
| All Domains | Input | Learning modules, assessments |
| Bug-Bounty-Support | Input | Methodology learning |

---

## Domain File References

### Foundation Learning (Files 01-10)

1. `1-Reconnaissance-and-Asset-Discovery-Learning.md` - Recon learning
2. `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` - JS analysis learning
3. `3-API-Endpoint-Analysis-Learning.md` - API analysis learning
4. `4-Authentication-and-Session-Management-Learning.md` - Auth learning
5. `5-Authorization-and-Access-Control-Learning.md` - Authorization learning
6. `6-Input-Validation-and-Sanitization-Learning.md` - Input validation learning
7. `7-Business-Logic-Flaws-Learning.md` - Business logic learning
8. `8-Client-Side-Storage-Security-Learning.md` - Client storage learning
9. `9-Cryptography-and-Data-Protection-Learning.md` - Crypto learning
10. `10-Error-Handling-and-Information-Disclosure-Learning.md` - Error handling learning

### Web Vulnerability Learning (Files 11-20)

11. `11-File-Upload-and-Processing-Learning.md` - File upload learning
12. `12-Server-Side-Request-Forgery-SSRF-Learning.md` - SSRF learning
13. `13-Cross-Site-Request-Forgery-CSRF-Learning.md` - CSRF learning
14. `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` - CORS learning
15. `15-Race-Conditions-and-Concurrency-Issues-Learning.md` - Race condition learning
16. `16-Third-Party-Component-Analysis-Learning.md` - Component analysis learning
17. `17-Configuration-and-Misconfiguration-Hunting-Learning.md` - Config hunting learning
18. `18-Network-and-Infrastructure-Security-Learning.md` - Network security learning
19. `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` - Mobile/API learning
20. `20-Reporting-and-Proof-of-Concept-Development-Learning.md` - Reporting learning

### Advanced Injection Learning (Files 21-30)

21. `21-Web-Application-Firewall-WAF-Bypass-Learning.md` - WAF bypass learning
22. `22-HTTP-Request-Smuggling-Learning.md` - Request smuggling learning
23. `23-Subdomain-Takeover-Learning.md` - Subdomain takeover learning
24. `24-Host-Header-Injection-Learning.md` - Host header learning
25. `25-XML-External-Entity-XXE-Injection-Learning.md` - XXE learning
26. `26-Insecure-Deserialization-Learning.md` - Deserialization learning
27. `27-Command-Injection-Learning.md` - Command injection learning
28. `28-NoSQL-Injection-Learning.md` - NoSQL injection learning
29. `29-GraphQL-Vulnerabilities-Learning.md` - GraphQL learning
30. `30-WebSocket-Security-Learning.md` - WebSocket security learning

### Specialized Attack Learning (Files 31-40)

31. `31-Server-Side-Template-Injection-SSTI-Learning.md` - SSTI learning
32. `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` - JWT learning
33. `33-Content-Security-Policy-CSP-Bypass-Learning.md` - CSP bypass learning
34. `34-Clickjacking-and-UI-Redressing-Learning.md` - Clickjacking learning
35. `35-HTTP-Parameter-Pollution-Learning.md` - HPP learning
36. `36-LDAP-Injection-Learning.md` - LDAP injection learning
37. `37-Session-Puzzling-and-Fixation-Learning.md` - Session attacks learning
38. `38-Insecure-File-Handling-Learning.md` - File handling learning
39. `39-Advanced-Client-Side-Attacks-Learning.md` - Client-side attacks learning
40. `40-Cloud-Security-and-Misconfigurations-Learning.md` - Cloud security learning

### Advanced Technique Learning (Files 41-50)

41. `41-Third-Party-Integration-Security-Learning.md` - Third-party security learning
42. `42-Mobile-Application-Security-Learning.md` - Mobile security learning
43. `43-IoT-and-Embedded-Device-Security-Learning.md` - IoT security learning
44. `44-API-Security-and-GraphQL-Learning.md` - API/GraphQL learning
45. `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` - WASM learning
46. `46-Blockchain-and-Cryptocurrency-Security-Learning.md` - Blockchain learning
47. `47-Automation-and-Tool-Development-Learning.md` - Automation learning
48. `48-Advanced-Reverse-Engineering-Learning.md` - Reverse engineering learning
49. `49-Compliance-and-Regulatory-Security-Learning.md` - Compliance learning
50. `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` - Threat modeling learning

---

## Learning Progress Benchmarks

### Domain Completion Targets

| Domain | Beginner | Intermediate | Advanced | Expert |
|--------|----------|--------------|----------|--------|
| Reconnaissance | 5 modules | 10 modules | 15 modules | 20 modules |
| Web Vulnerabilities | 10 modules | 20 modules | 30 modules | 40 modules |
| API Security | 3 modules | 6 modules | 9 modules | 12 modules |
| Cloud Security | 3 modules | 6 modules | 9 modules | 12 modules |
| Mobile Security | 3 modules | 6 modules | 9 modules | 12 modules |

### Assessment Score Targets

| Level | Quiz Score | Practical Score | Challenge Score |
|-------|-----------|-----------------|-----------------|
| Beginner | > 70% | > 60% | N/A |
| Intermediate | > 80% | > 70% | > 50% |
| Advanced | > 85% | > 80% | > 70% |
| Expert | > 90% | > 85% | > 80% |

---

## Knowledge Graph Structure

### Core Relationships

```
Reconnaissance
  ├── Asset Discovery
  │   ├── Subdomain Enumeration
  │   ├── Port Scanning
  │   └── Technology Fingerprinting
  ├── OSINT
  │   ├── Social Media
  │   ├── Public Records
  │   └── Code Repositories
  └── Content Discovery
      ├── Directory Brute-Force
      ├── Parameter Discovery
      └── Hidden Files

Web Vulnerabilities
  ├── Injection
  │   ├── SQL Injection
  │   ├── XSS
  │   ├── Command Injection
  │   └── Template Injection
  ├── Authentication
  │   ├── Session Management
  │   ├── Password Attacks
  │   └── MFA Bypass
  └── Authorization
      ├── IDOR
      ├── Privilege Escalation
      └── Access Control
```

---

## Security Considerations

### Data Sensitivity

- **Module Completions**: Personal - learning records
- **Assessments**: Personal - assessment scores
- **Knowledge Graph**: Internal - learning structure
- **Learning Progress**: Personal - progress tracking
- **Skill Proficiency**: Internal - competency data

### Data Protection

- Learning records are personal and private
- Assessment scores are confidential
- Knowledge graph is internal team knowledge
- Skill proficiency is for personal development

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-08-01 | Initial learning schema |
| 1.1.0 | 2024-11-01 | Added knowledge graph |
| 1.2.0 | 2025-02-01 | Added skill proficiency tracking |
| 1.3.0 | 2025-05-01 | Enhanced assessment analytics |
| 2.0.0 | 2025-08-01 | Complete schema redesign |
