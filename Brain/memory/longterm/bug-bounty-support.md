# Long-Term Memory: Bug Bounty Support

## Domain Mapping

- **Domain**: Bug Bounty Support
- **Root Directory**: `bug-bounty-support/`
- **Total Files**: 23 (including README.md)
- **Purpose**: Persistent memory for framework versions, template library, methodology database, and support resources

---

## Overview

This long-term memory system stores the foundational knowledge base for bug bounty operations. It maintains framework versions, methodology templates, tool configurations, and learning resources that support all other domains.

### Memory Categories

1. **Framework Registry** - Version-controlled methodology frameworks
2. **Template Library** - Reusable templates for common operations
3. **Methodology Database** - Step-by-step procedures for various scenarios
4. **Tool Configuration Store** - Saved tool configurations and presets
5. **Learning Resource Index** - Curated learning materials and references

---

## Storage Schema

### Framework Record

```json
{
  "framework_id": "string",
  "name": "string",
  "version": "semver",
  "category": "enum: recon|hunting|reporting|chaining|persistence|automation",
  "description": "string",
  "components": [
    {
      "component_id": "string",
      "name": "string",
      "version": "semver",
      "status": "enum: stable|beta|deprecated",
      "dependencies": ["array"]
    }
  ],
  "applicable_vuln_classes": ["array"],
  "target_types": ["array"],
  "performance_metrics": {
    "avg_time_minutes": "float",
    "success_rate": "float",
    "findings_per_hour": "float"
  },
  "changelog": [
    {
      "version": "semver",
      "date": "ISO-8601",
      "changes": ["array"]
    }
  ],
  "created": "ISO-8601",
  "last_updated": "ISO-8601"
}
```

### Template Record

```json
{
  "template_id": "string",
  "name": "string",
  "category": "enum: report|checklist|workflow|configuration|script",
  "framework_id": "string",
  "content": "string (markdown or code)",
  "variables": [
    {
      "name": "string",
      "type": "string",
      "description": "string",
      "default": "any"
    }
  ],
  "usage_count": "integer",
  "success_rate": "float 0-1",
  "rating": "float 1-5",
  "tags": ["array"],
  "created": "ISO-8601",
  "last_used": "ISO-8601"
}
```

### Methodology Record

```json
{
  "methodology_id": "string",
  "name": "string",
  "category": "enum: recon|discovery|testing|exploitation|reporting",
  "target_type": "enum: web|api|mobile|cloud|infrastructure",
  "steps": [
    {
      "step_order": "integer",
      "name": "string",
      "description": "string",
      "tools": ["array"],
      "commands": ["array"],
      "expected_output": "string",
      "success_criteria": "string",
      "failure_handling": "string"
    }
  ],
  "estimated_duration_minutes": "integer",
  "skill_level": "enum: beginner|intermediate|advanced|expert",
  "prerequisites": ["array"],
  "applicable_vuln_classes": ["array"],
  "success_rate": "float 0-1",
  "last_tested": "ISO-8601"
}
```

### Tool Configuration Record

```json
{
  "config_id": "string",
  "tool_name": "string",
  "config_name": "string",
  "description": "string",
  "configuration": {},
  "target_type": "string",
  "use_case": "string",
  "performance_profile": "enum: stealth|balanced|aggressive",
  "success_rate": "float 0-1",
  "usage_count": "integer",
  "created": "ISO-8601",
  "last_used": "ISO-8601"
}
```

### Learning Resource Record

```json
{
  "resource_id": "string",
  "title": "string",
  "type": "enum: article|video|tool|paper|course|book",
  "url": "string",
  "category": "string",
  "difficulty": "enum: beginner|intermediate|advanced",
  "topics": ["array"],
  "quality_score": "float 1-5",
  "relevance_score": "float 0-1",
  "date_added": "ISO-8601",
  "last_reviewed": "ISO-8601"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/support/frameworks
POST /memory/longterm/support/templates
POST /memory/longterm/support/methodologies
POST /memory/longterm/support/tool-configs
POST /memory/longterm/support/learning-resources
```

### Read

```
GET /memory/longterm/support/frameworks/{framework_id}
GET /memory/longterm/support/frameworks?category={category}
GET /memory/longterm/support/templates?category={category}&tags={tags}
GET /memory/longterm/support/methodologies?target_type={type}
GET /memory/longterm/support/tool-configs?tool_name={name}
GET /memory/longterm/support/learning-resources?difficulty={level}
```

### Update

```
PATCH /memory/longterm/support/frameworks/{framework_id}/version
PUT /memory/longterm/support/templates/{template_id}/content
PATCH /memory/longterm/support/methodologies/{methodology_id}/steps
PATCH /memory/longterm/support/tool-configs/{config_id}/configuration
```

### Delete

```
DELETE /memory/longterm/support/frameworks/{framework_id} (deprecate)
DELETE /memory/longterm/support/templates/{template_id} (soft delete)
DELETE /memory/longterm/support/tool-configs/{config_id}
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Frameworks | No expiration | Core methodology persists |
| Templates | 365 days | Templates need periodic review |
| Methodologies | 180 days | Procedures need updating |
| Tool Configs | 90 days | Tool versions change |
| Learning Resources | 365 days | Educational content ages slowly |

### TTL Enforcement

```python
def enforce_support_ttl():
    frameworks.never_expire()
    templates.review_after_days(365)
    methodologies.update_after_days(180)
    tool_configs.validate_after_days(90)
    learning_resources.review_after_days(365)
```

---

## Compression

### Compression Strategy

- **Frameworks**: None (small, critical data)
- **Templates**: GZIP (content storage)
- **Methodologies**: GZIP (step-by-step content)
- **Tool Configs**: None (small configuration data)
- **Learning Resources**: None (metadata only)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "frameworks": {
    "framework_id": "primary_key",
    "category": "hash_index",
    "version": "btree_index"
  },
  "templates": {
    "template_id": "primary_key",
    "category": "hash_index",
    "framework_id": "btree_index",
    "tags": "gin_index"
  },
  "methodologies": {
    "methodology_id": "primary_key",
    "category": "hash_index",
    "target_type": "hash_index",
    "skill_level": "hash_index"
  }
}
```

### Composite Indexes

```json
{
  "template_usage": ["category", "usage_count", "rating"],
  "methodology_target": ["target_type", "category", "skill_level"],
  "tool_config_effectiveness": ["tool_name", "success_rate"]
}
```

---

## Retrieval Patterns

### Pattern 1: Framework Version Lookup

```
SELECT * FROM frameworks
WHERE name = ?
  AND version = (
    SELECT MAX(version) FROM frameworks WHERE name = ?
  )
```

**Use Case**: Get the latest version of a framework.

### Pattern 2: Template Discovery

```
SELECT * FROM templates
WHERE category = ?
  AND tags @> ARRAY[?]
  AND rating > 4.0
ORDER BY usage_count DESC, rating DESC
```

**Use Case**: Find highly-rated templates for a specific use case.

### Pattern 3: Methodology Selection

```
SELECT * FROM methodologies
WHERE target_type = ?
  AND category = ?
  AND skill_level <= ?
  AND success_rate > 0.7
ORDER BY success_rate DESC, estimated_duration_minutes ASC
```

**Use Case**: Select appropriate methodology based on target and skill level.

### Pattern 4: Tool Configuration Matching

```
SELECT * FROM tool_configurations
WHERE tool_name = ?
  AND target_type = ?
  AND performance_profile = ?
  AND success_rate > 0.5
ORDER BY success_rate DESC
LIMIT 5
```

**Use Case**: Find optimized configurations for a tool.

### Pattern 5: Learning Path Discovery

```
SELECT * FROM learning_resources
WHERE topics @> ARRAY[?]
  AND difficulty = ?
  AND quality_score > 4.0
ORDER BY relevance_score DESC, quality_score DESC
```

**Use Case**: Build a learning path for a specific topic.

---

## Consolidation Triggers

### Automatic Consolidation

1. **Monthly**: Review and update template ratings
2. **Quarterly**: Validate methodology success rates
3. **Semi-annually**: Review learning resource quality
4. **On framework update**: Cascade version updates

### Event-Triggered Consolidation

1. **New tool version released**: Update tool configurations
2. **Methodology tested**: Update success rate metrics
3. **Template used successfully**: Increment usage count
4. **Learning resource reviewed**: Update quality score

### Manual Consolidation

```
POST /memory/longterm/support/consolidate
{
  "action": "update_ratings|validate_methodologies|review_resources",
  "category": "optional filter"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Advanced-Automation | Input | Tool configurations, workflows |
| Core-Prompts-Hunting | Input | Methodologies, templates |
| Report-Writing-Mastery | Input | Report templates |
| All Domains | Input | Framework versions |

---

## Domain File References

### Core Support Files (01-10)

1. `Core-Aspects-for-Bug-Security-Hunting.md` - Core security hunting concepts
2. `Reconnaissance.md` - Reconnaissance methodology
3. `Vulnerability-Detection.md` - Detection techniques
4. `Exploitation.md` - Exploitation procedures
5. `Chaining.md` - Vulnerability chaining methods
6. `Reporting.md` - Report writing guidelines
7. `PoC-Development.md` - Proof of concept development
8. `Ethical-Guidelines.md` - Ethical framework
9. `parameters.md` - Parameter analysis
10. `user-functionality.md` - User functionality testing

### Advanced Support Files (11-20)

11. `Advanced-Techniques.md` - Advanced testing techniques
12. `Advanced-Bug-Bounty-Prompt.md` - Advanced hunting prompts
13. `Advanced-Bug-Security-Hunting-Prompt.md` - Security hunting prompts
14. `Advanced-Information-Disclosure-Analysis-Prompt.md` - Info disclosure prompts
15. `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` - JS vulnerability prompts
16. `to-identify-injection-and-reflected-point-during-testing.md` - Injection identification
17. `debuging-using-browser-console-and-vscode-for-hunting.md` - Debugging techniques
18. `JavaScript-Identification-Deobfuscation.md` - JS deobfuscation
19. `manual-testing-scope.md` - Manual testing scope
20. `Specific-Vulnerabilities-Hunting.md` - Specific vuln hunting

### Tool Integration Files (21-23)

21. `Tools-Integration.md` - Tool integration guide
22. `static-and-dynamic-testing.md` - Static and dynamic testing
23. `Burp-AI.md` - Burp Suite AI integration

---

## Framework Version Reference

### Current Frameworks

| Framework | Version | Last Updated | Status |
|-----------|---------|--------------|--------|
| Recon Framework | 2.3.0 | 2025-01-15 | Stable |
| Hunting Framework | 2.1.0 | 2025-02-01 | Stable |
| Reporting Framework | 2.0.0 | 2025-01-20 | Stable |
| Chaining Framework | 1.5.0 | 2024-12-01 | Beta |
| Automation Framework | 1.8.0 | 2025-01-10 | Stable |

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-01-01 | Initial framework release |
| 1.5.0 | 2024-06-01 | Added chaining framework |
| 2.0.0 | 2024-12-01 | Major framework redesign |
| 2.1.0 | 2025-01-01 | Enhanced hunting framework |
| 2.3.0 | 2025-02-01 | Updated recon framework |

---

## Template Categories

### Report Templates

| Template | Rating | Usage | Best For |
|----------|--------|-------|----------|
| Critical Finding | 4.8 | 150+ | Critical vulnerabilities |
| High Finding | 4.6 | 200+ | High severity findings |
| Medium Finding | 4.5 | 300+ | Medium severity findings |
| Chain Finding | 4.7 | 50+ | Chained vulnerabilities |
| Informational | 4.3 | 400+ | Info disclosure findings |

### Workflow Templates

| Template | Rating | Usage | Best For |
|----------|--------|-------|----------|
| Quick Scan | 4.4 | 100+ | Rapid assessment |
| Deep Dive | 4.7 | 75+ | Comprehensive testing |
| API Testing | 4.5 | 120+ | API endpoints |
| Mobile Testing | 4.2 | 60+ | Mobile applications |
| Cloud Testing | 4.3 | 40+ | Cloud infrastructure |

---

## Security Considerations

### Data Sensitivity

- **Frameworks**: Internal - team use only
- **Templates**: Internal - team use only
- **Methodologies**: Internal - team use only
- **Tool Configs**: Internal - team use only
- **Learning Resources**: Public - educational use

### Access Control

- Frameworks: All team members (read), maintainers (write)
- Templates: All team members (read/write)
- Methodologies: All team members (read), reviewers (write)
- Tool Configs: All team members (read/write)
- Learning Resources: All team members (read/write)

---

## Encryption Requirements

- **Templates**: Optional encryption (non-sensitive content)
- **Methodologies**: Encryption recommended for proprietary methods
- **Tool Configs**: Encryption if containing credentials
- **Learning Resources**: No encryption required (public content)

---

## Audit Trail

- Log all framework version changes
- Track template usage by user and date
- Record methodology modifications with reasons
- Monitor tool configuration access

---

## Framework Usage Patterns

### By Experience Level

| Level | Recommended Frameworks | Focus Areas |
|-------|----------------------|-------------|
| Beginner | Recon Framework, Basic Hunting | Recon, simple vulns |
| Intermediate | All Core Frameworks | Web vulns, API testing |
| Advanced | Full Suite + Custom | Chaining, advanced techniques |
| Expert | Custom + Experimental | Novel techniques, research |

### By Time Available

| Time Budget | Framework Focus | Expected Findings |
|-------------|-----------------|-------------------|
| 1 hour | Quick Recon + Basic Scan | 0-2 findings |
| 4 hours | Full Recon + Targeted Hunting | 2-5 findings |
| 8 hours | Deep Recon + Comprehensive Testing | 5-10 findings |
| 24+ hours | Full Methodology Application | 10+ findings |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-06-01 | Initial support schema |
| 1.1.0 | 2024-09-01 | Added template library |
| 1.2.0 | 2024-12-01 | Added methodology database |
| 1.3.0 | 2025-03-01 | Added learning resources |
| 2.0.0 | 2025-06-01 | Complete schema redesign |
