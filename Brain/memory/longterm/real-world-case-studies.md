# Long-Term Memory: Real-World Case Studies

## Domain Mapping

- **Domain**: Real-World Case Studies
- **Root Directory**: `Real-World-Case-Studies/`
- **Total Files**: 50 (including README.md)
- **Purpose**: Persistent memory for disclosed report patterns, bounty correlation data, and technique catalog

---

## Overview

This long-term memory system stores patterns from disclosed bug bounty reports, correlating techniques with bounty outcomes, and building a catalog of proven exploitation methods. It provides data-driven insights into what works in real bug bounty programs.

### Memory Categories

1. **Disclosed Pattern Database** - Patterns from accepted reports
2. **Bounty Correlation Data** - Technique-to-bounty mappings
3. **Technique Catalog** - Proven exploitation methods
4. **Program Response Patterns** - How programs respond to findings
5. **Resubmission Intelligence** - Patterns in resubmission success

---

## Storage Schema

### Disclosed Report Record

```json
{
  "report_id": "uuid-v4",
  "program": "string",
  "platform": "enum: hackerone|bugcrowd|intigriti|yeswehack|other",
  "vuln_class": "string",
  "severity": "enum: critical|high|medium|low|informational",
  "bounty_usd": "float",
  "title": "string",
  "disclosure_date": "ISO-8601",
  "techniques": ["array of technique descriptions"],
  "attack_vector": "string",
  "impact_description": "string",
  "remediation": "string",
  "report_url": "string",
  "researcher": "string",
  "response_time_days": "integer",
  "triage_time_days": "integer",
  "resolution_time_days": "integer"
}
```

### Bounty Correlation Record

```json
{
  "correlation_id": "uuid-v4",
  "vuln_class": "string",
  "technique": "string",
  "target_type": "string",
  "platform": "string",
  "bounty_stats": {
    "count": "integer",
    "min_bounty": "float",
    "max_bounty": "float",
    "avg_bounty": "float",
    "median_bounty": "float"
  },
  "severity_distribution": {
    "critical": "integer",
    "high": "integer",
    "medium": "integer",
    "low": "integer"
  },
  "success_rate": "float 0-1",
  "avg_response_days": "float",
  "last_updated": "ISO-8601"
}
```

### Technique Catalog Record

```json
{
  "technique_id": "string",
  "technique_name": "string",
  "vuln_class": "string",
  "description": "string",
  "prerequisites": ["array"],
  "steps": [
    {
      "step": "integer",
      "action": "string",
      "command": "string",
      "expected_output": "string"
    }
  ],
  "detection_signatures": ["array"],
  "common_mitigations": ["array"],
  "platforms": ["array"],
  "complexity": "enum: low|medium|high",
  "success_rate": "float 0-1",
  "disclosed_reports": ["array of report_ids"],
  "created": "ISO-8601"
}
```

### Program Response Record

```json
{
  "response_id": "string",
  "program": "string",
  "vuln_class": "string",
  "severity": "string",
  "response_pattern": "enum: quick_accept|slow_triage|rejected_info|duplicate|severity_downgrade",
  "avg_response_days": "float",
  "acceptance_rate": "float",
  "common_rejection_reasons": ["array"],
  "resubmission_success_rate": "float",
  "notes": "string"
}
```

### Resubmission Record

```json
{
  "resubmission_id": "string",
  "original_report_id": "string",
  "resubmission_number": "integer",
  "changes_made": ["array"],
  "outcome": "enum: accepted|rejected|duplicate",
  "new_bounty": "float",
  "time_to_resolution_days": "float",
  "lessons_learned": "string"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/case-studies/disclosed
POST /memory/longterm/case-studies/bounty-correlations
POST /memory/longterm/case-studies/technique-catalog
POST /memory/longterm/case-studies/program-responses
POST /memory/longterm/case-studies/resubmissions
```

### Read

```
GET /memory/longterm/case-studies/disclosed/{report_id}
GET /memory/longterm/case-studies/disclosed?vuln_class={class}&platform={p}
GET /memory/longterm/case-studies/bounty-correlations?technique={tech}
GET /memory/longterm/case-studies/technique-catalog/{technique_id}
GET /memory/longterm/case-studies/program-responses?program={name}
```

### Update

```
PATCH /memory/longterm/case-studies/disclosed/{report_id}
PUT /memory/longterm/case-studies/bounty-correlations/{correlation_id}
PATCH /memory/longterm/case-studies/technique-catalog/{technique_id}
```

### Delete

```
DELETE /memory/longterm/case-studies/disclosed/{report_id} (archive)
DELETE /memory/longterm/case-studies/resubmissions/{resubmission_id}
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Disclosed Reports | No expiration | Historical data valuable |
| Bounty Correlations | 180 days | Bounty patterns shift |
| Technique Catalog | 365 days | Techniques persist |
| Program Responses | 90 days | Programs change policies |
| Resubmissions | 2 years | Resubmission patterns persist |

### TTL Enforcement

```python
def enforce_case_studies_ttl():
    disclosed_reports.never_expire()
    bounty_correlations.refresh_after_days(180)
    technique_catalog.review_after_days(365)
    program_responses.update_after_days(90)
    resubmissions.archive_after_days(730)
```

---

## Compression

### Compression Strategy

- **Disclosed Reports**: GZIP (detailed content)
- **Bounty Correlations**: None (aggregated data)
- **Technique Catalog**: GZIP (step-by-step content)
- **Program Responses**: None (small records)
- **Resubmissions**: None (small records)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "disclosed_reports": {
    "report_id": "primary_key",
    "vuln_class": "hash_index",
    "platform": "hash_index",
    "severity": "hash_index",
    "bounty_usd": "btree_index",
    "disclosure_date": "btree_index"
  },
  "bounty_correlations": {
    "correlation_id": "primary_key",
    "vuln_class": "hash_index",
    "technique": "hash_index",
    "bounty_stats.avg_bounty": "btree_index"
  },
  "technique_catalog": {
    "technique_id": "primary_key",
    "vuln_class": "hash_index",
    "complexity": "hash_index",
    "success_rate": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "vuln_platform": ["vuln_class", "platform", "bounty_usd"],
  "technique_effectiveness": ["vuln_class", "complexity", "success_rate"],
  "program_analysis": ["program", "vuln_class", "acceptance_rate"]
}
```

---

## Retrieval Patterns

### Pattern 1: Bounty Prediction

```
SELECT vuln_class, technique,
       bounty_stats.avg_bounty,
       bounty_stats.median_bounty,
       bounty_stats.count,
       success_rate
FROM bounty_correlations
WHERE vuln_class = ?
  AND target_type = ?
ORDER BY bounty_stats.avg_bounty DESC
```

**Predict expected bounty for a vulnerability class.

### Pattern 2: Technique Effectiveness

```
SELECT technique_id, technique_name,
       success_rate,
       disclosed_reports,
       complexity
FROM technique_catalog
WHERE vuln_class = ?
  AND platforms @> ARRAY[?]
ORDER BY success_rate DESC
```

Find the most effective techniques for a vulnerability class.

### Pattern 3: Program Response Analysis

```
SELECT program, vuln_class, severity,
       acceptance_rate,
       avg_response_days,
       common_rejection_reasons
FROM program_responses
WHERE program = ?
ORDER BY acceptance_rate DESC
```

**Analyze how a specific program responds to findings.

### Pattern 4: Resubmission Strategy

```
SELECT resubmission_number,
       AVG(new_bounty) as avg_bounty,
       COUNT(CASE WHEN outcome = 'accepted' THEN 1 END) * 100.0 / COUNT(*) as success_rate
FROM resubmissions r
JOIN disclosed_reports dr ON r.original_report_id = dr.report_id
WHERE dr.vuln_class = ?
GROUP BY resubmission_number
ORDER BY resubmission_number
```

**Determine optimal resubmission strategy.

### Pattern 5: High-Value Disclosure Analysis

```
SELECT title, vuln_class, severity, bounty_usd,
       program, disclosure_date, techniques
FROM disclosed_reports
WHERE bounty_usd > ?
  AND disclosure_date > NOW() - INTERVAL '1 year'
ORDER BY bounty_usd DESC
LIMIT 20
```

**Analyze highest-paying disclosures for patterns.

---

## Consolidation Triggers

### Automatic Consolidation

1. **Weekly**: Update bounty correlation statistics
2. **Monthly**: Refresh program response patterns
3. **Quarterly**: Review technique catalog effectiveness
4. **Semi-annually**: Archive old resubmission records

### Event-Triggered Consolidation

1. **New disclosed report added**: Update correlations
2. **Bounty amount received**: Update correlation stats
3. **Program policy change**: Update response patterns
4. **Technique threshold reached**: Update technique catalog

### Manual Consolidation

```
POST /memory/longterm/case-studies/consolidate
{
  "action": "update_correlations|refresh_programs|review_techniques",
  "vuln_class": "optional filter",
  "platform": "optional filter"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Bug-Bounty-Program-Strategy | Input | Program-specific data |
| Core-Prompts-Hunting | Output | Technique effectiveness |
| Advanced-Chaining-Techniques | Input | Chaining patterns |
| Report-Writing-Mastery | Input | Report quality patterns |

---

## Domain File References

### Injection Vulnerabilities (Files 01-10)

1. `01-IDOR-Account-Takeover-Case-Studies.md` - IDOR case studies
2. `02-XSS-Stored-Persistent-Attacks.md` - Stored XSS cases
3. `03-SQL-Injection-Data-Breaches.md` - SQLi cases
4. `04-SSRF-Internal-Network-Access.md` - SSRF cases
5. `05-CSRF-State-Changing-Attacks.md` - CSRF cases
6. `06-Command-Injection-RCE.md` - Command injection cases
7. `07-Deserialization-Remote-Code-Execution.md` - Deserialization cases
8. `08-File-Upload-Arbitrary-Upload.md` - File upload cases
9. `09-XXE-XML-External-Entity-Attacks.md` - XXE cases
10. `10-SSTI-Server-Side-Template-Injection.md` - SSTI cases

### Authentication & Authorization (Files 11-20)

11. `11-JWT-Token-Manipulation.md` - JWT attack cases
12. `12-Authentication-Bypass.md` - Auth bypass cases
13. `13-Privilege-Escalation.md` - Privesc cases
14. `14-Business-Logic-Flaws.md` - Business logic cases
15. `15-Information-Disclosure.md` - Info disclosure cases
16. `16-Memory-Corruption-Heap-Overflow.md` - Memory corruption cases
17. `17-Deserialization-Java-Deserialization.md` - Java deser cases
18. `18-Deserialization-PHP-Unserialize.md` - PHP unser cases
19. `19-Deserialization-Python-Pickle.md` - Python pickle cases
20. `20-Race-Condition-Time-of-Check.md` - Race condition cases

### Client-Side Attacks (Files 21-30)

21. `21-Host-Header-Injection.md` - Host header cases
22. `22-DNS-Rebinding-Attacks.md` - DNS rebinding cases
23. `23-WebSocket-Security-Issues.md` - WebSocket cases
24. `24-GraphQL-Introspection-Attacks.md` - GraphQL cases
25. `25-CSP-Bypass-Techniques.md` - CSP bypass cases
26. `26-Clickjacking-UI-Redressing.md` - Clickjacking cases
27. `27-HTTP-Response-Splitting.md` - Response splitting cases
28. `28-LDAP-Injection-Attacks.md` - LDAP injection cases
29. `29-XPath-Injection-Attacks.md` - XPath injection cases
30. `30-NoSQL-Injection-MongoDB.md` - NoSQL injection cases

### Infrastructure Attacks (Files 31-40)

31. `31-Prototype-Pollution-JavaScript.md` - Prototype pollution cases
32. `32-Subdomain-Takeover.md` - Subdomain takeover cases
33. `33-Open-Redirect-Phishing.md` - Open redirect cases
34. `34-Content-Spoofing-Attacks.md` - Content spoofing cases
35. `35-WebCache-Poisoning.md` - Cache poisoning cases
36. `36-HTTP-Request-Smuggling.md` - Request smuggling cases
37. `37-WebSocket-Hijacking.md` - WebSocket hijacking cases
38. `38-CORS-Misconfiguration.md` - CORS misconfig cases
39. `39-Token-Leakage-URL-Parameters.md` - Token leakage cases
40. `40-Sensitive-Data-Exposure.md` - Data exposure cases

### Crypto & Cloud (Files 41-50)

41. `41-Weak-Encryption-Algorithms.md` - Weak crypto cases
42. `42-Insecure-Cryptographic-Storage.md` - Crypto storage cases
43. `43-Path-Traversal-File-Inclusion.md` - Path traversal cases
44. `44-Local-File-Inclusion-LFI.md` - LFI cases
45. `45-Remote-File-Inclusion-RFI.md` - RFI cases
46. `46-Server-Side-Request-Forgery.md` - SSRF cases
47. `47-Client-Side-Request-Forgery.md` - Client-side SSRF cases
48. `48-Mobile-API-Security-Issues.md` - Mobile API cases
49. `49-Cloud-Misconfiguration-AWS.md` - AWS misconfig cases
50. `50-API-Authentication-Bypass.md` - API auth bypass cases

---

## Bounty Correlation Reference

### By Vulnerability Class

| Vuln Class | Avg Bounty | Success Rate | Best Platform |
|------------|-----------|--------------|---------------|
| SQL Injection | $1500 | 75% | HackerOne |
| XSS (Stored) | $750 | 80% | Bugcrowd |
| IDOR | $500 | 85% | Intigriti |
| SSRF | $1000 | 65% | HackerOne |
| Auth Bypass | $2000 | 60% | HackerOne |
| RCE | $3000 | 50% | All |

### By Platform

| Platform | Avg Bounty | Acceptance Rate | Response Time |
|----------|-----------|-----------------|---------------|
| HackerOne | $800 | 65% | 5 days |
| Bugcrowd | $600 | 60% | 7 days |
| Intigriti | $500 | 70% | 3 days |
| YesWeHack | $400 | 65% | 5 days |

---

## Technique Effectiveness Reference

### Top Techniques by Success Rate

| Technique | Vuln Class | Success Rate | Avg Bounty |
|-----------|------------|--------------|------------|
| Parameter manipulation | IDOR | 85% | $400 |
| Payload injection | XSS | 75% | $600 |
| Union-based extraction | SQLi | 70% | $1200 |
| SSRF to metadata | SSRF | 65% | $900 |
| JWT none algorithm | Auth | 60% | $800 |

---

## Security Considerations

### Data Sensitivity

- **Disclosed Reports**: Public - published data
- **Bounty Correlations**: Internal - strategic data
- **Technique Catalog**: Internal - operational data
- **Program Responses**: Internal - intelligence data
- **Resubmissions**: Internal - strategic data

### Data Protection

- Attribute disclosed reports to original researchers
- Protect program response patterns from competitors
- Maintain confidentiality of resubmission strategies
- Use aggregated data for sharing

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-10-01 | Initial case study schema |
| 1.1.0 | 2025-01-01 | Added bounty correlation |
| 1.2.0 | 2025-04-01 | Added technique catalog |
| 1.3.0 | 2025-07-01 | Enhanced program response tracking |
| 2.0.0 | 2025-10-01 | Complete schema redesign |
