# Long-Term Memory: Report Writing Mastery

## Domain Mapping

- **Domain**: Report Writing Mastery
- **Root Directory**: `Report-Writing-Mastery/`
- **Total Files**: 54 (including README.md)
- **Purpose**: Persistent memory for report archive, acceptance statistics, template library, and writing patterns

---

## Overview

This long-term memory system stores report templates, acceptance statistics, writing patterns, and feedback data that improve report quality and acceptance rates over time. It captures what makes reports successful and builds a library of proven templates.

### Memory Categories

1. **Report Archive** - Complete report records with outcomes
2. **Acceptance Statistics** - Success rates by report type and platform
3. **Template Library** - Reusable report templates
4. **Writing Pattern Database** - Proven writing patterns and styles
5. **Feedback Repository** - Program feedback and improvement notes

---

## Storage Schema

### Report Record

```json
{
  "report_id": "uuid-v4",
  "finding_title": "string",
  "vuln_class": "string",
  "severity": "enum: critical|high|medium|low|informational",
  "cvss_score": "float",
  "program": "string",
  "platform": "enum: hackerone|bugcrowd|intigriti|yeswehack|other",
  "report_content": {
    "summary": "string",
    "vulnerability_description": "string",
    "impact_statement": "string",
    "reproduction_steps": ["array"],
    "remediation": "string",
    "references": ["array"]
  },
  "attachments": ["array of attachment names"],
  "bounty_usd": "float",
  "status": "enum: draft|submitted|triaged|accepted|rejected|duplicate|informational",
  "response_time_days": "float",
  "triage_time_days": "float",
  "resolution_time_days": "float",
  "rejection_reason": "string",
  "program_feedback": "string",
  "resubmission_count": "integer",
  "submitted_date": "ISO-8601",
  "resolved_date": "ISO-8601",
  "writing_patterns": ["array of pattern_ids"]
}
```

### Acceptance Statistics Record

```json
{
  "stats_id": "string",
  "platform": "string",
  "vuln_class": "string",
  "severity": "string",
  "metrics": {
    "total_submitted": "integer",
    "accepted": "integer",
    "rejected": "integer",
    "duplicate": "integer",
    "informational": "integer",
    "acceptance_rate": "float 0-1",
    "avg_bounty": "float",
    "avg_triage_days": "float"
  },
  "common_rejection_reasons": [
    {
      "reason": "string",
      "count": "integer",
      "percentage": "float"
    }
  ],
  "last_updated": "ISO-8601"
}
```

### Template Record

```json
{
  "template_id": "string",
  "name": "string",
  "vuln_class": "string",
  "severity": "string",
  "platform": "string",
  "content": {
    "structure": "string (markdown template)",
    "variables": [
      {
        "name": "string",
        "description": "string",
        "example": "string"
      }
    ]
  },
  "usage_count": "integer",
  "acceptance_rate": "float 0-1",
  "avg_bounty": "float",
  "rating": "float 1-5",
  "tags": ["array"],
  "created": "ISO-8601",
  "last_used": "ISO-8601"
}
```

### Writing Pattern Record

```json
{
  "pattern_id": "string",
  "pattern_name": "string",
  "category": "enum: structure|language|impact|technical|remediation",
  "description": "string",
  "example": "string",
  "anti_pattern": "string (what to avoid)",
  "effectiveness_score": "float 0-1",
  "applicable_to": ["array of vuln classes"],
  "usage_count": "integer",
  "last_validated": "ISO-8601"
}
```

### Feedback Record

```json
{
  "feedback_id": "string",
  "report_id": "string",
  "program": "string",
  "feedback_type": "enum: triager|program_owner|researcher",
  "feedback_text": "string",
  "sentiment": "enum: positive|neutral|negative",
  "actionable": "boolean",
  "lesson_learned": "string",
  "date_received": "ISO-8601"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/reports/archive
POST /memory/longterm/reports/acceptance-stats
POST /memory/longterm/reports/templates
POST /memory/longterm/reports/writing-patterns
POST /memory/longterm/reports/feedback
```

### Read

```
GET /memory/longterm/reports/archive/{report_id}
GET /memory/longterm/reports/archive?vuln_class={class}&status={status}
GET /memory/longterm/reports/acceptance-stats?platform={p}&vuln_class={v}
GET /memory/longterm/reports/templates?vuln_class={class}&rating>{rating}
GET /memory/longterm/reports/writing-patterns?category={cat}
GET /memory/longterm/reports/feedback?report_id={id}
```

### Update

```
PATCH /memory/longterm/reports/archive/{report_id}/status
PUT /memory/longterm/reports/templates/{template_id}/metrics
PATCH /memory/longterm/reports/writing-patterns/{pattern_id}/effectiveness
```

### Delete

```
DELETE /memory/longterm/reports/archive/{report_id} (archive)
DELETE /memory/longterm/reports/templates/{template_id} (deprecate)
DELETE /memory/longterm/reports/feedback/{feedback_id}
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Report Archive | No expiration | Historical reports persist |
| Acceptance Statistics | 90 days | Stats need refreshing |
| Template Library | 365 days | Templates need review |
| Writing Patterns | 180 days | Patterns need validation |
| Feedback | 2 years | Feedback ages slowly |

### TTL Enforcement

```python
def enforce_reports_ttl():
    report_archive.never_expire()
    acceptance_stats.refresh_after_days(90)
    templates.review_after_days(365)
    writing_patterns.validate_after_days(180)
    feedback.archive_after_days(730)
```

---

## Compression

### Compression Strategy

- **Report Archive**: GZIP (detailed content)
- **Acceptance Statistics**: None (aggregated data)
- **Template Library**: None (small records)
- **Writing Patterns**: None (small records)
- **Feedback**: None (small records)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "report_archive": {
    "report_id": "primary_key",
    "vuln_class": "hash_index",
    "severity": "hash_index",
    "platform": "hash_index",
    "status": "hash_index",
    "bounty_usd": "btree_index",
    "submitted_date": "btree_index"
  },
  "acceptance_stats": {
    "stats_id": "primary_key",
    "platform": "hash_index",
    "vuln_class": "hash_index",
    "metrics.acceptance_rate": "btree_index"
  },
  "templates": {
    "template_id": "primary_key",
    "vuln_class": "hash_index",
    "severity": "hash_index",
    "rating": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "report_analysis": ["vuln_class", "severity", "status", "bounty_usd"],
  "template_effectiveness": ["vuln_class", "acceptance_rate", "rating"],
  "platform_stats": ["platform", "vuln_class", "acceptance_rate"]
}
```

---

## Retrieval Patterns

### Pattern 1: Report Success Analysis

```
SELECT vuln_class, severity,
       COUNT(*) as total,
       COUNT(CASE WHEN status = 'accepted' THEN 1 END) as accepted,
       AVG(bounty_usd) as avg_bounty,
       AVG(CASE WHEN status = 'accepted' THEN bounty_usd END) as accepted_bounty
FROM report_archive
WHERE platform = ?
GROUP BY vuln_class, severity
ORDER BY accepted_bounty DESC
```

**Analyze which report types succeed most.

### Pattern 2: Template Effectiveness

```
SELECT template_id, name, vuln_class,
       usage_count, acceptance_rate, rating, avg_bounty
FROM templates
WHERE vuln_class = ?
  AND rating > 4.0
ORDER BY acceptance_rate DESC, rating DESC
```

**Find the most effective templates.

### Pattern 3: Writing Pattern Impact

```
SELECT wp.pattern_name, wp.category,
       COUNT(rp.writing_patterns) as usage_count,
       AVG(ra.bounty_usd) as avg_bounty,
       COUNT(CASE WHEN ra.status = 'accepted' THEN 1 END) * 100.0 / COUNT(*) as acceptance_rate
FROM writing_patterns wp
JOIN report_archive ra ON wp.pattern_id = ANY(ra.writing_patterns)
GROUP BY wp.pattern_name, wp.category
ORDER BY acceptance_rate DESC
```

**Measure how writing patterns impact outcomes.

### Pattern 4: Rejection Pattern Analysis

```
SELECT rejection_reason,
       COUNT(*) as frequency,
       vuln_class,
       severity
FROM report_archive
WHERE status = 'rejected'
GROUP BY rejection_reason, vuln_class, severity
ORDER BY frequency DESC
```

**Identify common rejection reasons.

### Pattern 5: Platform-Specific Optimization

```
SELECT platform, vuln_class,
       AVG(CASE WHEN status = 'accepted' THEN bounty_usd END) as avg_bounty,
       AVG(triage_time_days) as avg_triage,
       COUNT(*) as submissions
FROM report_archive
GROUP BY platform, vuln_class
HAVING COUNT(*) > 5
ORDER BY avg_bounty DESC
```

**Optimize reports for specific platforms.

---

## Consolidation Triggers

### Automatic Consolidation

1. **After each submission**: Update acceptance statistics
2. **Weekly**: Recalculate template effectiveness
3. **Monthly**: Refresh writing pattern scores
4. **Quarterly**: Archive old feedback records

### Event-Triggered Consolidation

1. **Report accepted**: Update template metrics
2. **Report rejected**: Analyze rejection reason
3. **New template created**: Validate against existing
4. **Writing pattern validated**: Update effectiveness score

### Manual Consolidation

```
POST /memory/longterm/reports/consolidate
{
  "action": "update_stats|refresh_templates|analyze_patterns",
  "platform": "optional filter",
  "vuln_class": "optional filter"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Core-Prompts-Hunting | Input | Findings for reporting |
| Bug-Bounty-Program-Strategy | Input | Program formatting requirements |
| Advanced-Chaining-Techniques | Input | Chain findings for reporting |
| All Domains | Output | Report templates |

---

## Domain File References

### Report Structure (Files 01-10)

1. `01-Report-Structure-Optimization.md` - Report structure best practices
2. `02-Technical-Writing-Standards.md` - Technical writing standards
3. `03-Private-Program-Case-Study.md` - Private program reports
4. `04-Proof-of-Concept-Development.md` - PoC development
5. `05-Vulnerability-Severity-Assessment.md` - Severity assessment
6. `06-Remediation-Recommendations.md` - Remediation writing
7. `07-Executive-Summary-Crafting.md` - Executive summaries
8. `08-Technical-Detail-Balancing.md` - Balancing detail
9. `09-Visual-Aid-Integration.md` - Visual aids in reports
10. `10-Code-Sample-Formatting.md` - Code formatting

### Report Enhancement (Files 11-20)

11. `11-Timeline-Documentation.md` - Timeline documentation
12. `12-Collaboration-Crediting.md` - Crediting collaborators
13. `13-Program-Specific-Formatting.md` - Program-specific formats
14. `14-Language-and-Tone-Optimization.md` - Language optimization
15. `15-Attachment-Management.md` - Attachment management
16. `16-Follow-up-Communication.md` - Follow-up communications
17. `17-Rejection-Analysis-and-Improvement.md` - Rejection analysis
18. `18-Reward-Negotiation-Preparation.md` - Bounty negotiation
19. `19-Report-Template-Development.md` - Template development
20. `20-Quality-Assurance-Process.md` - QA process

### Report Standards (Files 21-30)

21. `21-Grammar-and-Style-Standards.md` - Grammar standards
22. `22-Technical-Accuracy-Verification.md` - Technical accuracy
23. `23-Impact-Quantification.md` - Impact quantification
24. `24-Business-Context-Integration.md` - Business context
25. `25-Compliance-Documentation.md` - Compliance docs
26. `26-International-Standard-Adherence.md` - International standards
27. `27-Audience-Analysis.md` - Audience analysis
28. `28-Information-Hierarchy.md` - Information hierarchy
29. `29-Actionable-Recommendations.md` - Recommendations
30. `30-Report-Review-Process.md` - Review process

### Advanced Reporting (Files 31-40)

31. `31-Common-Pitfalls-Avoidance.md` - Common pitfalls
32. `32-Advanced-Formatting-Techniques.md` - Advanced formatting
33. `33-Multimedia-Integration.md` - Multimedia in reports
34. `34-Interactive-Report-Elements.md` - Interactive elements
35. `35-Cross-Platform-Compatibility.md` - Cross-platform reports
36. `36-Version-Control-for-Reports.md` - Report versioning
37. `37-Report-Analytics-and-Metrics.md` - Report analytics
38. `38-Peer-Review-Optimization.md` - Peer review
39. `39-Program-Feedback-Incorporation.md` - Feedback incorporation
40. `40-Continuous-Improvement.md` - Continuous improvement

### Platform-Specific Reporting (Files 41-50)

41. `41-Report-Personalization.md` - Personalized reports
42. `42-Contextual-Intelligence.md` - Contextual intelligence
43. `43-Technical-Depth-Calibration.md` - Technical depth
44. `44-Impact-Visualization.md` - Impact visualization
45. `45-Report-Archiving-Strategy.md` - Report archiving
46. `46-Collaboration-Report-Standards.md` - Collaboration reports
47. `47-Advanced-Proof-of-Concept.md` - Advanced PoC
48. `48-Report-Automation-Tools.md` - Report automation
49. `49-Quality-Metrics-Development.md` - Quality metrics
50. `50-Master-Report-Writing-Framework.md` - Master framework

### Specialized Reports (Files 51-54)

51. `HackerOne-Report-Analysis.md` - HackerOne report analysis
52. `Bugcrowd-Finding-Dissection.md` - Bugcrowd finding analysis
53. `Impact-Communication.md` - Impact communication
54. `High-Severity-Vulnerability-Analysis.md` - High-severity reports

---

## Acceptance Rate Benchmarks

### By Platform

| Platform | Avg Acceptance Rate | Avg Bounty | Best Performing Vuln |
|----------|---------------------|-----------|----------------------|
| HackerOne | 65% | $800 | IDOR, XSS |
| Bugcrowd | 60% | $600 | SQLi, Auth Bypass |
| Intigriti | 70% | $500 | IDOR, CSRF |
| YesWeHack | 65% | $400 | XSS, Info Disclosure |

### By Vulnerability Class

| Vuln Class | Acceptance Rate | Avg Bounty | Report Quality Score |
|------------|-----------------|-----------|---------------------|
| IDOR | 85% | $500 | High |
| XSS (Stored) | 75% | $750 | High |
| SQLi | 70% | $1500 | Very High |
| SSRF | 65% | $1000 | High |
| Auth Bypass | 60% | $2000 | Very High |
| Business Logic | 55% | $800 | Medium |

---

## Writing Pattern Reference

### High-Impact Patterns

| Pattern | Category | Effectiveness | Best For |
|---------|----------|---------------|----------|
| Impact-first writing | Impact | 90% | All severities |
| Step-by-step reproduction | Technical | 85% | All vuln classes |
| Clear remediation | Remediation | 85% | All vuln classes |
| Business impact quantification | Impact | 80% | Critical/High |
| Code snippet inclusion | Technical | 75% | Injection vulns |
| Visual proof (screenshots) | Structure | 70% | Client-side vulns |

### Anti-Patterns to Avoid

| Anti-Pattern | Issue | Solution |
|--------------|-------|----------|
| Overly technical language | Confuses triagers | Use clear, simple language |
| Missing impact statement | Hard to assess severity | Always quantify impact |
| Incomplete reproduction | Cannot verify | Provide complete steps |
| Aggressive tone | Unprofessional | Maintain professional tone |
| No remediation advice | Lowers acceptance | Always include fixes |

---

## Report Template Examples

### Critical Finding Template

```markdown
# [VULN_CLASS] in [ENDPOINT] leading to [IMPACT]

## Summary
[1-2 sentence summary of the vulnerability and its impact]

## Vulnerability Description
[Detailed technical description]

## Impact
[Quantified business impact]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
...

## Proof of Concept
[Code/screenshots demonstrating the issue]

## Remediation
[Specific fix recommendations]

## References
[CVE, documentation, etc.]
```

---

## Security Considerations

### Data Sensitivity

- **Report Archive**: Confidential - may contain sensitive URLs
- **Acceptance Statistics**: Internal - strategic data
- **Template Library**: Internal - team use only
- **Writing Patterns**: Internal - team use only
- **Feedback**: Internal - program communications

### Data Protection

- Sanitize report URLs before storage
- Redact sensitive endpoints in templates
- Protect program feedback from competitors
- Maintain researcher attribution in archives

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-12-01 | Initial report schema |
| 1.1.0 | 2025-03-01 | Added acceptance statistics |
| 1.2.0 | 2025-06-01 | Added template library |
| 1.3.0 | 2025-09-01 | Added writing patterns |
| 2.0.0 | 2025-12-01 | Complete schema redesign |
