# Long-Term Memory: High-Level World Case Studies

## Domain Mapping

- **Domain**: High-Level World Case Studies
- **Root Directory**: `High-Level-World-Case-Studies/`
- **Total Files**: 46 (including README.md)
- **Purpose**: Persistent memory for case analysis archive, pattern library, and MITRE coverage map

---

## Overview

This long-term memory system stores comprehensive case analysis from real-world security incidents. It maintains a pattern library of attack techniques, maps findings to MITRE ATT&CK framework, and preserves lessons learned that inform future hunting strategies.

### Memory Categories

1. **Case Analysis Archive** - Detailed case study records
2. **Pattern Library** - Recurring attack patterns and techniques
3. **MITRE Coverage Map** - Mapping to ATT&CK framework
4. **Impact Assessment Database** - Business impact analysis
5. **Lessons Learned Repository** - Extracted insights and recommendations

---

## Storage Schema

### Case Study Record

```json
{
  "case_id": "uuid-v4",
  "title": "string",
  "category": "enum: breach|vulnerability|incident|attack_chain|apt",
  "industry": "string",
  "year": "integer",
  "severity": "enum: critical|high|medium|low",
  "attack_vector": "string",
  "initial_access": "string",
  "techniques_used": ["MITRE technique IDs"],
  "timeline": {
    "discovery_date": "ISO-8601",
    "disclosure_date": "ISO-8601",
    "patch_date": "ISO-8601",
    "resolution_date": "ISO-8601"
  },
  "impact": {
    "data_breach": "boolean",
    "records_exposed": "integer",
    "financial_loss_usd": "float",
    "affected_users": "integer",
    "business_impact": "string"
  },
  "vulnerabilities": [
    {
      "vuln_class": "string",
      "cve_id": "string",
      "cvss_score": "float",
      "description": "string"
    }
  ],
  "lessons_learned": ["array"],
  "mitigations": ["array"],
  "references": ["array of URLs"],
  "created": "ISO-8601"
}
```

### Pattern Record

```json
{
  "pattern_id": "string",
  "pattern_name": "string",
  "description": "string",
  "attack_chain": ["array of technique IDs"],
  "frequency": "integer (number of cases)",
  "avg_impact": "enum: critical|high|medium|low",
  "industries_affected": ["array"],
  "detection_difficulty": "enum: easy|moderate|difficult|evasive",
  "mitigation_effectiveness": "float 0-1",
  "cases": ["array of case_ids"],
  "first_observed": "ISO-8601",
  "last_observed": "ISO-8601",
  "trend": "enum: increasing|stable|decreasing"
}
```

### MITRE Coverage Record

```json
{
  "technique_id": "string (T####)",
  "technique_name": "string",
  "tactic": "string",
  "sub_techniques": ["array"],
  "cases_observed": ["array of case_ids"],
  "frequency": "integer",
  "avg_severity": "float",
  "detection_methods": ["array"],
  "mitigations": ["array"],
  "coverage_score": "float 0-1",
  "last_observed": "ISO-8601"
}
```

### Impact Assessment Record

```json
{
  "assessment_id": "string",
  "case_id": "string",
  "impact_type": "enum: financial|operational|reputational|legal|technical",
  "severity": "enum: critical|high|medium|low",
  "description": "string",
  "quantified_value": "float",
  "currency": "string",
  "recovery_time_days": "integer",
  "long_term_effects": ["array"]
}
```

### Lessons Learned Record

```json
{
  "lesson_id": "string",
  "case_ids": ["array"],
  "category": "enum: detection|prevention|response|recovery|governance",
  "lesson_text": "string",
  "applicable_to": ["array of industries/technologies"],
  "confidence": "float 0-1",
  "actionable": "boolean",
  "recommendation": "string",
  "date_extracted": "ISO-8601"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/cases/studies
POST /memory/longterm/cases/patterns
POST /memory/longterm/cases/mitre-coverage
POST /memory/longterm/cases/impact-assessments
POST /memory/longterm/cases/lessons-learned
```

### Read

```
GET /memory/longterm/cases/studies/{case_id}
GET /memory/longterm/cases/studies?category={cat}&industry={ind}
GET /memory/longterm/cases/patterns/{pattern_id}
GET /memory/longterm/cases/mitre-coverage/{technique_id}
GET /memory/longterm/cases/lessons-learned?category={cat}
```

### Update

```
PATCH /memory/longterm/cases/studies/{case_id}
PUT /memory/longterm/cases/patterns/{pattern_id}/frequency
PATCH /memory/longterm/cases/mitre-coverage/{technique_id}
```

### Delete

```
DELETE /memory/longterm/cases/studies/{case_id} (archive)
DELETE /memory/longterm/cases/patterns/{pattern_id}
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Case Studies | No expiration | Historical cases persist |
| Patterns | No expiration | Patterns are evergreen |
| MITRE Coverage | 365 days | ATT&CK framework updates |
| Impact Assessments | 2 years | Business impact data ages |
| Lessons Learned | No expiration | Insights persist |

### TTL Enforcement

```python
def enforce_cases_ttl():
    case_studies.never_expire()
    patterns.never_expire()
    mitre_coverage.refresh_after_days(365)
    impact_assessments.archive_after_days(730)
    lessons_learned.never_expire()
```

---

## Compression

### Compression Strategy

- **Case Studies**: GZIP (detailed content)
- **Patterns**: None (small records)
- **MITRE Coverage**: None (aggregated data)
- **Impact Assessments**: None (small records)
- **Lessons Learned**: None (small records)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "case_studies": {
    "case_id": "primary_key",
    "category": "hash_index",
    "industry": "hash_index",
    "year": "btree_index",
    "severity": "hash_index",
    "techniques_used": "gin_index"
  },
  "patterns": {
    "pattern_id": "primary_key",
    "frequency": "btree_index",
    "avg_impact": "hash_index",
    "industries_affected": "gin_index"
  },
  "mitre_coverage": {
    "technique_id": "primary_key",
    "tactic": "hash_index",
    "frequency": "btree_index",
    "coverage_score": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "case_industry": ["industry", "year", "severity"],
  "pattern_frequency": ["frequency", "avg_impact"],
  "mitre_analysis": ["tactic", "frequency", "coverage_score"]
}
```

---

## Retrieval Patterns

### Pattern 1: Industry-Specific Case Analysis

```
SELECT * FROM case_studies
WHERE industry = ?
  AND year >= ?
ORDER BY severity, year DESC
```

**Use Case**: Understand attacks targeting a specific industry.

### Pattern 2: Technique Frequency Analysis

```
SELECT technique_id, technique_name, tactic,
       frequency, avg_severity, coverage_score
FROM mitre_coverage
WHERE frequency > ?
ORDER BY frequency DESC
```

**Use Case**: Identify most commonly observed techniques.

### Pattern 3: Pattern Discovery

```
SELECT * FROM patterns
WHERE industries_affected @> ARRAY[?]
  AND frequency > 3
ORDER BY frequency DESC, avg_impact DESC
```

**Use Case**: Find recurring patterns for a specific industry.

### Pattern 4: Attack Chain Reconstruction

```
SELECT technique_id, technique_name, tactic
FROM mitre_coverage
WHERE technique_id IN (
    SELECT unnest(techniques_used) 
    FROM case_studies 
    WHERE case_id = ?
)
ORDER BY tactic, technique_id
```

**Reconstruct the attack chain from a specific case.

### Pattern 5: Lessons Learned by Category

```
SELECT lesson_id, lesson_text, recommendation,
       confidence, applicable_to
FROM lessons_learned
WHERE category = ?
  AND confidence > 0.7
ORDER BY confidence DESC
```

**Get high-confidence lessons for a specific category.

---

## Consolidation Triggers

### Automatic Consolidation

1. **Monthly**: Update pattern frequency counts
2. **Quarterly**: Refresh MITRE coverage scores
3. **Semi-annually**: Review and update lessons learned
4. **Annually**: Archive old impact assessments

### Event-Triggered Consolidation

1. **New case added**: Update pattern frequencies
2. **ATT&CK framework update**: Refresh coverage map
3. **New lesson extracted**: Validate against existing lessons
4. **Pattern threshold reached**: Create new pattern record

### Manual Consolidation

```
POST /memory/longterm/cases/consolidate
{
  "action": "update_patterns|refresh_mitre|review_lessons",
  "category": "optional filter"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Advanced-Chaining-Techniques | Input | Attack chain patterns |
| Core-Prompts-Hunting | Input | Vulnerability patterns |
| Advanced-Persistence-Exploitation | Input | Persistence patterns |
| Real-World-Case-Studies | Bidirectional | Case data |

---

## Domain File References

### Attack Pattern Studies (Files 01-10)

1. `01-IDOR-Account-Takeover-Case-Studies.md` - IDOR case studies
2. `02-XSS-Stored-Persistent-Attacks.md` - Stored XSS cases
3. `03-SQL-Injection-Data-Breaches.md` - SQLi breach cases
4. `04-SSRF-Internal-Network-Access.md` - SSRF cases
5. `05-CSRF-State-Changing-Attacks.md` - CSRF attack cases
6. `06-Command-Injection-RCE.md` - Command injection cases
7. `07-Deserialization-Remote-Code-Execution.md` - Deserialization RCE cases
8. `08-File-Upload-Arbitrary-Upload.md` - File upload cases
9. `09-XXE-XML-External-Entity-Attacks.md` - XXE attack cases
10. `10-SSTI-Server-Side-Template-Injection.md` - SSTI cases

### Advanced Vulnerability Studies (Files 11-20)

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

### Client-Side & Injection Studies (Files 21-30)

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

### Infrastructure & Advanced Studies (Files 31-40)

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

### Cloud & Mobile Studies (Files 41-50)

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

## MITRE ATT&CK Coverage Reference

### Most Common Techniques Observed

| Technique ID | Name | Tactic | Frequency | Avg Severity |
|--------------|------|--------|-----------|--------------|
| T1190 | Exploit Public-Facing App | Initial Access | High | Critical |
| T1059 | Command and Scripting Interpreter | Execution | High | High |
| T1078 | Valid Accounts | Persistence | High | High |
| T1053 | Scheduled Task/Job | Persistence | Medium | Medium |
| T1021 | Remote Services | Lateral Movement | Medium | High |
| T1562 | Impair Defenses | Defense Evasion | Medium | High |
| T1048 | Exfiltration Over Alternative Protocol | Exfiltration | Medium | Critical |
| T1486 | Data Encrypted for Impact | Impact | Low | Critical |

### Coverage Gaps

| Technique ID | Name | Tactic | Gap Reason |
|--------------|------|--------|------------|
| T1210 | Exploitation of Remote Services | Lateral Movement | Rarely observed |
| T1557 | Adversary-in-the-Middle | Collection | Complex attack |
| T1565 | Data Manipulation | Impact | Advanced technique |

---

## Impact Assessment Benchmarks

### By Vulnerability Class

| Vuln Class | Avg Financial Loss | Avg Records Exposed | Recovery Time |
|------------|-------------------|--------------------| --------------|
| SQL Injection | $1.5M | 100K-1M | 30-90 days |
| XSS (Stored) | $500K | 10K-100K | 14-30 days |
| Auth Bypass | $2M | 100K-1M | 30-60 days |
| RCE | $3M | 1M+ | 60-180 days |
| IDOR | $200K | 10K-50K | 7-14 days |

### By Industry

| Industry | Avg Incident Cost | Recovery Time | Regulatory Impact |
|----------|-------------------|---------------|-------------------|
| Healthcare | $5M | 90+ days | High (HIPAA) |
| Financial | $10M | 60+ days | High (PCI, SOX) |
| Retail | $3M | 30-60 days | Medium (PCI) |
| Technology | $4M | 30-90 days | Medium |
| Government | $2M | 60-180 days | High (various) |

---

## Lessons Learned Reference

### Top Lessons by Category

| Category | Lesson | Confidence | Applicability |
|----------|--------|------------|---------------|
| Detection | Implement comprehensive logging | 0.95 | Universal |
| Prevention | Input validation at all entry points | 0.90 | Universal |
| Response | Have an incident response plan | 0.95 | Universal |
| Recovery | Maintain offsite backups | 0.90 | Universal |
| Governance | Regular security assessments | 0.85 | Universal |

---

## Security Considerations

### Data Sensitivity

- **Case Studies**: Public - published incidents
- **Patterns**: Internal - team use only
- **MITRE Coverage**: Public - framework data
- **Impact Assessments**: Internal - business data
- **Lessons Learned**: Internal - team use only

### Data Protection

- Anonymize unpublished case data
- Restrict impact assessment access
- Protect lessons learned from competitors
- Maintain source attribution for case studies

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-09-01 | Initial case study schema |
| 1.1.0 | 2024-12-01 | Added pattern library |
| 1.2.0 | 2025-03-01 | Added MITRE coverage map |
| 1.3.0 | 2025-06-01 | Enhanced lessons learned |
| 2.0.0 | 2025-09-01 | Complete schema redesign |
