# Long-Term Memory: Core Prompts Hunting

## Domain Mapping

- **Domain**: Core Prompts Hunting
- **Root Directory**: `Core-Prompts-hunting/`
- **Total Files**: 50 (including README.md)
- **Purpose**: Persistent memory for vulnerability hunting findings, tool effectiveness, and vulnerability class success rates

---

## Overview

This long-term memory system captures the accumulated knowledge from vulnerability hunting operations. It stores finding history, tool effectiveness metrics, vulnerability class success rates, and hunting patterns that inform future hunting strategies.

### Memory Categories

1. **Finding History Archive** - Complete records of all discoveries
2. **Tool Effectiveness Database** - Performance metrics for hunting tools
3. **Vulnerability Class Analytics** - Success rates by vulnerability type
4. **Hunting Pattern Library** - Proven hunting methodologies and patterns
5. **Target Profile Store** - Technology-specific hunting profiles

---

## Storage Schema

### Finding Record

```json
{
  "finding_id": "uuid-v4",
  "vuln_class": "string",
  "severity": "enum: critical|high|medium|low|informational",
  "cvss_score": "float",
  "title": "string",
  "description": "string",
  "location": {
    "url": "string",
    "parameter": "string",
    "endpoint": "string"
  },
  "evidence": {
    "request": "string",
    "response": "string",
    "screenshots": ["array"],
    "proof_of_concept": "string"
  },
  "remediation": "string",
  "tools_used": ["array"],
  "technique": "string",
  "target": {
    "domain": "string",
    "technology_stack": ["array"]
  },
  "program_id": "string",
  "submission_status": "enum: draft|submitted|triaged|accepted|rejected|duplicate",
  "bounty_amount": "float",
  "discovered_date": "ISO-8601",
  "submitted_date": "ISO-8601",
  "resolved_date": "ISO-8601"
}
```

### Tool Effectiveness Record

```json
{
  "tool_id": "string",
  "tool_name": "string",
  "version": "string",
  "vuln_class": "string",
  "metrics": {
    "total_runs": "integer",
    "total_findings": "integer",
    "findings_per_run": "float",
    "success_rate": "float 0-1",
    "false_positive_rate": "float 0-1",
    "avg_time_seconds": "float",
    "resource_usage": {
      "cpu_percent": "float",
      "memory_mb": "float"
    }
  },
  "best_for": ["array of contexts"],
  "limitations": ["array"],
  "last_updated": "ISO-8601"
}
```

### Vulnerability Class Analytics Record

```json
{
  "vuln_class": "string",
  "category": "enum: injection|auth|xss|ssrf|idor|business_logic|crypto|config",
  "metrics": {
    "total_findings": "integer",
    "avg_severity": "float",
    "avg_bounty": "float",
    "success_rate": "float 0-1",
    "avg_discovery_time_minutes": "float",
    "common_targets": ["array"],
    "detection_methods": ["array"]
  },
  "trends": {
    "discovery_rate_trend": "enum: increasing|stable|decreasing",
    "severity_trend": "enum: increasing|stable|decreasing",
    "bounty_trend": "enum: increasing|stable|decreasing"
  },
  "hunting_tips": ["array"],
  "common_patterns": ["array"],
  "last_analyzed": "ISO-8601"
}
```

### Hunting Pattern Record

```json
{
  "pattern_id": "string",
  "name": "string",
  "description": "string",
  "vuln_classes": ["array"],
  "target_types": ["array"],
  "steps": [
    {
      "step": "integer",
      "action": "string",
      "tool": "string",
      "command": "string",
      "expected_output": "string"
    }
  ],
  "success_rate": "float 0-1",
  "avg_findings_per_run": "float",
  "avg_time_minutes": "float",
  "prerequisites": ["array"],
  "created": "ISO-8601",
  "last_used": "ISO-8601",
  "usage_count": "integer"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/hunting/findings
POST /memory/longterm/hunting/tool-effectiveness
POST /memory/longterm/hunting/vuln-class-analytics
POST /memory/longterm/hunting/hunting-patterns
```

### Read

```
GET /memory/longterm/hunting/findings/{finding_id}
GET /memory/longterm/hunting/findings?vuln_class={class}&severity={sev}
GET /memory/longterm/hunting/tool-effectiveness/{tool_id}
GET /memory/longterm/hunting/vuln-class-analytics/{vuln_class}
GET /memory/longterm/hunting/hunting-patterns?target_type={type}
```

### Update

```
PATCH /memory/longterm/hunting/findings/{finding_id}/status
PUT /memory/longterm/hunting/tool-effectiveness/{tool_id}/metrics
PATCH /memory/longterm/hunting/vuln-class-analytics/{vuln_class}/trends
```

### Delete

```
DELETE /memory/longterm/hunting/findings/{finding_id} (archive)
DELETE /memory/longterm/hunting/hunting-patterns/{pattern_id}
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Findings | No expiration | Historical findings are valuable |
| Tool Effectiveness | 90 days | Need fresh performance data |
| Vuln Class Analytics | 180 days | Trends need periodic refresh |
| Hunting Patterns | 365 days | Proven patterns persist |
| Target Profiles | 30 days | Technology stacks change |

### TTL Enforcement

```python
def enforce_hunting_ttl():
    findings.never_expire()
    tool_effectiveness.refresh_after_days(90)
    vuln_class_analytics.update_after_days(180)
    hunting_patterns.review_after_days(365)
    target_profiles.expire_after_days(30)
```

---

## Compression

### Compression Strategy

- **Findings**: GZIP (JSON with request/response data)
- **Tool Effectiveness**: None (small, critical data)
- **Vuln Class Analytics**: None (aggregated data)
- **Hunting Patterns**: GZIP (step-by-step content)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "findings": {
    "finding_id": "primary_key",
    "vuln_class": "hash_index",
    "severity": "hash_index",
    "target.domain": "btree_index",
    "discovered_date": "btree_index",
    "submission_status": "hash_index"
  },
  "tool_effectiveness": {
    "tool_id": "primary_key",
    "vuln_class": "hash_index",
    "metrics.success_rate": "btree_index"
  },
  "vuln_class_analytics": {
    "vuln_class": "primary_key",
    "category": "hash_index",
    "metrics.avg_bounty": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "finding_analysis": ["vuln_class", "severity", "discovered_date"],
  "tool_performance": ["tool_name", "vuln_class", "metrics.success_rate"],
  "bounty_analysis": ["vuln_class", "severity", "bounty_amount"]
}
```

---

## Retrieval Patterns

### Pattern 1: Vulnerability Class Discovery Rate

```
SELECT vuln_class,
       COUNT(*) as total_findings,
       COUNT(CASE WHEN severity IN ('critical', 'high') THEN 1 END) as high_severity,
       AVG(bounty_amount) as avg_bounty,
       AVG(cvss_score) as avg_cvss
FROM findings
WHERE discovered_date > NOW() - INTERVAL '90 days'
GROUP BY vuln_class
ORDER BY total_findings DESC
```

**Use Case**: Identify which vulnerability classes yield the most findings.

### Pattern 2: Tool Effectiveness Comparison

```
SELECT tool_name, vuln_class,
       metrics.findings_per_run,
       metrics.success_rate,
       metrics.false_positive_rate,
       metrics.avg_time_seconds
FROM tool_effectiveness
WHERE vuln_class = ?
  AND metrics.total_runs > 10
ORDER BY metrics.findings_per_run DESC
```

**Use Case**: Select the most effective tool for a vulnerability class.

### Pattern 3: Hunting Pattern Matching

```
SELECT * FROM hunting_patterns
WHERE vuln_classes @> ARRAY[?]
  AND target_types @> ARRAY[?]
  AND success_rate > 0.5
ORDER BY success_rate DESC, avg_findings_per_run DESC
```

**Use Case**: Find proven hunting patterns for a target type.

### Pattern 4: Finding Trend Analysis

```
SELECT DATE_TRUNC('month', discovered_date) as month,
       vuln_class,
       COUNT(*) as findings_count,
       AVG(bounty_amount) as avg_bounty
FROM findings
WHERE discovered_date > NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', discovered_date), vuln_class
ORDER BY month, findings_count DESC
```

**Use Case**: Track hunting performance trends over time.

### Pattern 5: Severity Distribution Analysis

```
SELECT severity,
       COUNT(*) as count,
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentage,
       AVG(bounty_amount) as avg_bounty,
       AVG(cvss_score) as avg_cvss
FROM findings
WHERE vuln_class = ?
GROUP BY severity
ORDER BY 
  CASE severity 
    WHEN 'critical' THEN 1 
    WHEN 'high' THEN 2 
    WHEN 'medium' THEN 3 
    WHEN 'low' THEN 4 
    WHEN 'informational' THEN 5 
  END
```

**Understand the severity distribution for a vulnerability class.

---

## Consolidation Triggers

### Automatic Consolidation

1. **Daily**: Update tool effectiveness metrics
2. **Weekly**: Recalculate vulnerability class analytics
3. **Monthly**: Refresh hunting pattern success rates
4. **Quarterly**: Archive old findings, update trends

### Event-Triggered Consolidation

1. **New finding discovered**: Update class analytics
2. **Tool run completed**: Update effectiveness metrics
3. **Hunting pattern used**: Update success rate
4. **Finding submitted**: Update submission statistics

### Manual Consolidation

```
POST /memory/longterm/hunting/consolidate
{
  "action": "update_analytics|refresh_patterns|archive_findings",
  "vuln_class": "optional filter",
  "date_range": "optional"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Advanced-Automation | Bidirectional | Tool effectiveness, finding automation |
| Advanced-Chaining-Techniques | Output | Findings for chaining |
| Report-Writing-Mastery | Output | Findings for reporting |
| Core-Prompts-Learning | Output | Finding patterns for learning |

---

## Domain File References

### Foundation (Files 01-10)

1. `1-Reconnaissance-and-Asset-Discovery.md` - Reconnaissance methodology
2. `2-JavaScript-Analysis-and-Deobfuscation.md` - JS analysis techniques
3. `3-API-Endpoint-Analysis.md` - API hunting methods
4. `4-Authentication-and-Session-Management.md` - Auth testing
5. `5-Authorization-and-Access-Control.md` - Authorization testing
6. `6-Input-Validation-and-Sanitization.md` - Input validation testing
7. `7-Business-Logic-Flaws.md` - Business logic hunting
8. `8-Client-Side-Storage-Security.md` - Client storage testing
9. `9-Cryptography-and-Data-Protection.md` - Crypto analysis
10. `10-Error-Handling-and-Information-Disclosure.md` - Error handling testing

### Web Vulnerabilities (Files 11-20)

11. `11-File-Upload-and-Processing.md` - File upload testing
12. `12-Server-Side-Request-Forgery-SSRF.md` - SSRF hunting
13. `13-Cross-Site-Request-Forgery-CSRF.md` - CSRF testing
14. `14-Cross-Origin-Resource-Sharing-CORS.md` - CORS testing
15. `15-Race-Conditions-and-Concurrency-Issues.md` - Race condition hunting
16. `16-Third-Party-Component-Analysis.md` - Component analysis
17. `17-Configuration-and-Misconfiguration-Hunting.md` - Config hunting
18. `18-Network-and-Infrastructure-Security.md` - Network security
19. `19-Mobile-and-API-Specific-Vulnerabilities.md` - Mobile/API vulns
20. `20-Reporting-and-Proof-of-Concept-Development.md` - Reporting

### Advanced Injection (Files 21-30)

21. `21-Web-Application-Firewall-WAF-Bypass.md` - WAF bypass techniques
22. `22-HTTP-Request-Smuggling.md` - Request smuggling
23. `23-Subdomain-Takeover.md` - Subdomain takeover
24. `24-Host-Header-Injection.md` - Host header injection
25. `25-XML-External-Entity-XXE-Injection.md` - XXE testing
26. `26-Insecure-Deserialization.md` - Deserialization testing
27. `27-Command-Injection.md` - Command injection
28. `28-NoSQL-Injection.md` - NoSQL injection
29. `29-GraphQL-Vulnerabilities.md` - GraphQL testing
30. `30-WebSocket-Security.md` - WebSocket security

### Specialized Attacks (Files 31-40)

31. `31-Server-Side-Template-Injection.md` - SSTI testing
32. `32-JSON-Web-Token-JWT-Vulnerabilities.md` - JWT testing
33. `33-Content-Security-Policy-CSP-Bypass.md` - CSP bypass
34. `34-Clickjacking-and-UI-Redressing.md` - Clickjacking
35. `35-HTTP-Parameter-Pollution.md` - HPP testing
36. `36-LDAP-Injection.md` - LDAP injection
37. `37-Session-Puzzling-and-Fixation.md` - Session attacks
38. `38-Insecure-File-Handling.md` - File handling
39. `39-Cross-Site-Script-Inclusion-XSSI.md` - XSSI testing
40. `40-Prototype-Pollution.md` - Prototype pollution

### Advanced Techniques (Files 41-50)

41. `41-HTTP-Response-Splitting.md` - Response splitting
42. `42-XPath-Injection.md` - XPath injection
43. `43-Cross-Site-Request-Forgery-CSRF.md` - Advanced CSRF
44. `44-Cross-Origin-Resource-Sharing-CORS.md` - Advanced CORS
45. `45-Race-Conditions-and-Concurrency-Issues.md` - Advanced races
46. `46-Third-Party-Component-Analysis.md` - Advanced component analysis
47. `47-Configuration-and-Misconfiguration-Hunting.md` - Advanced config
48. `48-Network-and-Infrastructure-Security.md` - Advanced network
49. `49-Mobile-and-API-Specific-Vulnerabilities.md` - Advanced mobile/API
50. `50-Reporting-and-Proof-of-Concept-Development.md` - Advanced reporting

---

## Vulnerability Class Success Benchmarks

### By Class

| Vuln Class | Avg Discovery Time | Success Rate | Avg Bounty |
|------------|-------------------|--------------|------------|
| XSS (Stored) | 45 min | 65% | $500 |
| IDOR | 30 min | 70% | $400 |
| SSRF | 60 min | 55% | $800 |
| SQLi | 90 min | 45% | $1200 |
| CSRF | 25 min | 75% | $300 |
| Auth Bypass | 120 min | 35% | $1500 |
| RCE | 180 min | 25% | $3000 |
| Business Logic | 150 min | 40% | $600 |

### By Target Type

| Target Type | Best Vuln Classes | Avg Findings/Session |
|-------------|-------------------|---------------------|
| E-commerce | IDOR, Business Logic, XSS | 3-5 |
| SaaS Platform | IDOR, Auth Bypass, SSRF | 2-4 |
| API Backend | IDOR, Injection, Auth | 4-6 |
| CMS Platform | XSS, CSRF, File Upload | 5-8 |
| Banking App | Business Logic, Auth, Crypto | 1-3 |

---

## Tool Effectiveness Reference

### By Vulnerability Class

| Vuln Class | Best Tool | Success Rate | False Positive Rate |
|------------|-----------|--------------|---------------------|
| XSS | nuclei | 70% | 15% |
| SQLi | sqlmap | 65% | 10% |
| IDOR | custom scripts | 75% | 5% |
| SSRF | nuclei | 60% | 20% |
| CSRF | custom scripts | 80% | 5% |
| Subdomain Takeover | subjack | 85% | 10% |

---

## Security Considerations

### Finding Data Sensitivity

- **Finding Records**: Confidential - may contain sensitive URLs
- **Tool Effectiveness**: Internal - team use only
- **Vuln Class Analytics**: Internal - team use only
- **Hunting Patterns**: Internal - team use only

### Data Protection

- Sanitize finding URLs before storage
- Encrypt request/response data containing credentials
- Restrict access to finding records
- Audit access to hunting patterns

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-07-01 | Initial hunting schema |
| 1.1.0 | 2024-10-01 | Added tool effectiveness tracking |
| 1.2.0 | 2025-01-01 | Added vulnerability class analytics |
| 1.3.0 | 2025-04-01 | Added hunting pattern library |
| 2.0.0 | 2025-07-01 | Complete schema redesign |
