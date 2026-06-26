# Long-Term Memory: Advanced Chaining Techniques

## Domain Mapping

- **Domain**: Advanced Chaining Techniques
- **Root Directory**: `Advanced-Chaining-Techniques/`
- **Total Files**: 49 (including README.md)
- **Purpose**: Persistent memory for multi-stage attack chains, severity amplification patterns, and chain success analytics

---

## Overview

This long-term memory system captures the collective knowledge of vulnerability chaining operations. It stores proven attack chain patterns, their success rates when combined, severity amplification data, and platform-specific chaining strategies. This memory enables researchers to replicate successful chains and avoid patterns with low success probability.

### Memory Categories

1. **Chain Pattern Archive** - Documented attack chains with full execution paths
2. **Success Rate Database** - Historical success/failure rates for each chain type
3. **Severity Amplification Matrix** - How individual vulns compound when chained
4. **Platform-Specific Notes** - Chain effectiveness across different platforms
5. **Chain Templates** - Reusable chain configurations for common scenarios

---

## Storage Schema

### Chain Pattern Record

```json
{
  "chain_id": "uuid-v4",
  "name": "string",
  "description": "string",
  "category": "enum: privesc|data_exfil|rce|auth_bypass|persistence",
  "stages": [
    {
      "stage_order": "integer",
      "vuln_class": "string",
      "technique": "string",
      "prerequisites": ["array"],
      "artifacts_produced": ["array"],
      "success_indicators": ["array"]
    }
  ],
  "total_stages": "integer",
  "max_severity": "enum: critical|high|medium|low",
  "avg_severity_boost": "float (severity points added)",
  "complexity": "enum: low|medium|high|expert",
  "time_estimate_minutes": "integer",
  "references": ["CVE-XXXX-XXXX"],
  "created": "ISO-8601",
  "last_used": "ISO-8601",
  "use_count": "integer"
}
```

### Chain Execution Record

```json
{
  "execution_id": "uuid-v4",
  "chain_id": "string",
  "target": "string",
  "target_type": "enum: web_app|api|mobile|cloud|infrastructure",
  "start_time": "ISO-8601",
  "end_time": "ISO-8601",
  "duration_minutes": "float",
  "stages_completed": [
    {
      "stage_order": "integer",
      "status": "enum: success|partial|failed|skipped",
      "findings": ["finding_ids"],
      "notes": "string"
    }
  ],
  "final_outcome": "enum: full_chain|partial_chain|failed",
  "severity_achieved": "enum: critical|high|medium|low|none",
  "bounties": {
    "submitted": "boolean",
    "amount_usd": "float",
    "currency": "string",
    "program": "string"
  },
  "lessons_learned": "string"
}
```

### Severity Amplification Matrix

```json
{
  "combination_id": "string",
  "vuln_classes": ["vuln1", "vuln2", "..."],
  "individual_severities": {
    "vuln1": "float",
    "vuln2": "float"
  },
  "combined_severity": "float",
  "amplification_factor": "float (combined / sum of individuals)",
  "common_chains": ["chain_ids"],
  "success_rate": "float 0-1",
  "example_impact": "string"
}
```

### Platform-Specific Chain Notes

```json
{
  "platform_id": "string",
  "platform_name": "string",
  "platform_version": "string",
  "chain_id": "string",
  "effectiveness_rating": "enum: high|medium|low|incompatible",
  "modifications_needed": ["array of changes"],
  "known_limitations": ["array"],
  "tested_date": "ISO-8601",
  "tester": "string"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/chaining/patterns
POST /memory/longterm/chaining/executions
POST /memory/longterm/chaining/amplification-matrix
POST /memory/longterm/chaining/platform-notes
```

### Read

```
GET /memory/longterm/chaining/patterns/{chain_id}
GET /memory/longterm/chaining/patterns?category={type}
GET /memory/longterm/chaining/executions?chain_id={id}&outcome={status}
GET /memory/longterm/chaining/amplification-matrix?vuln_class={class}
```

### Update

```
PATCH /memory/longterm/chaining/patterns/{chain_id}/metrics
PUT /memory/longterm/chaining/executions/{execution_id}/outcome
PATCH /memory/longterm/chaining/platform-notes/{platform_id}
```

### Delete

```
DELETE /memory/longterm/chaining/patterns/{chain_id}  (soft delete)
DELETE /memory/longterm/chaining/executions/{execution_id} (archive)
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Chain Patterns | No expiration | Proven chains are evergreen knowledge |
| Chain Executions | 180 days active | Execution details age; summaries persist |
| Amplification Matrix | 365 days | Severity relationships are stable |
| Platform Notes | 90 days | Platform versions change frequently |
| Lessons Learned | No expiration | Insights are always valuable |

### TTL Enforcement

```python
def enforce_chaining_ttl():
    chain_patterns.never_expire()
    chain_executions.archive_after_days(180)
    amplification_matrix.refresh_after_days(365)
    platform_notes.validate_after_days(90)
```

---

## Compression

### Compression Strategy

- **Chain Patterns**: GZIP (JSON, highly compressible)
- **Execution Records**: LZ4 (fast access for recent)
- **Amplification Matrix**: None (small, frequently accessed)
- **Platform Notes**: GZIP (text-heavy content)

### Expected Ratios

| Content Type | Original | Compressed | Ratio |
|--------------|----------|------------|-------|
| Chain pattern JSON | 5KB | 1KB | 80% |
| Execution records | 10KB | 2KB | 80% |
| Platform notes | 3KB | 500B | 83% |

---

## Indexing Strategy

### Primary Indexes

```json
{
  "chain_patterns": {
    "chain_id": "primary_key",
    "category": "hash_index",
    "max_severity": "hash_index",
    "complexity": "hash_index",
    "stages.vuln_class": "gin_index"
  },
  "chain_executions": {
    "execution_id": "primary_key",
    "chain_id": "btree_index",
    "final_outcome": "hash_index",
    "severity_achieved": "hash_index",
    "target_type": "hash_index"
  },
  "amplification_matrix": {
    "combination_id": "primary_key",
    "vuln_classes": "gin_index",
    "amplification_factor": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "chain_severity": ["category", "max_severity"],
  "execution_outcome": ["chain_id", "final_outcome", "severity_achieved"],
  "platform_effectiveness": ["platform_id", "effectiveness_rating"]
}
```

---

## Retrieval Patterns

### Pattern 1: Chain Discovery by Vuln Class

```
SELECT * FROM chain_patterns
WHERE stages.vuln_class @> ARRAY[?]
  AND complexity <= ?
ORDER BY use_count DESC, avg_severity_boost DESC
```

**Use Case**: Find chains starting from a discovered vulnerability class.

### Pattern 2: Success Rate Analysis

```
SELECT chain_id, 
       COUNT(*) as total_executions,
       AVG(CASE WHEN final_outcome = 'full_chain' THEN 1.0 ELSE 0.0 END) as success_rate,
       AVG(severity_boost) as avg_severity
FROM chain_executions
WHERE target_type = ?
GROUP BY chain_id
HAVING COUNT(*) >= 3
ORDER BY success_rate DESC
```

**Use Case**: Identify the most reliable chains for a given target type.

### Pattern 3: Severity Amplification Lookup

```
SELECT * FROM amplification_matrix
WHERE vuln_classes @> ARRAY[?, ?]
ORDER BY amplification_factor DESC
LIMIT 5
```

**Use Case**: Determine if combining two found vulns amplifies severity.

### Pattern 4: Platform-Specific Chain Validation

```
SELECT cp.*, pn.effectiveness_rating, pn.modifications_needed
FROM chain_patterns cp
JOIN platform_notes pn ON cp.chain_id = pn.chain_id
WHERE pn.platform_id = ?
  AND pn.effectiveness_rating IN ('high', 'medium')
ORDER BY pn.effectiveness_rating
```

**Use Case**: Find chains proven to work on the target's platform.

### Pattern 5: Chain Recommendation Engine

```
SELECT chain_id, name, total_stages, max_severity,
       success_rate, time_estimate_minutes
FROM chain_patterns cp
JOIN (
    SELECT chain_id, 
           AVG(CASE WHEN final_outcome='full_chain' THEN 1.0 ELSE 0.0 END) as success_rate
    FROM chain_executions
    GROUP BY chain_id
) stats ON cp.chain_id = stats.chain_id
WHERE cp.stages[1].vuln_class = ?
  AND cp.complexity <= ?
  AND stats.success_rate > 0.5
ORDER BY stats.success_rate DESC, cp.avg_severity_boost DESC
```

**Use Case**: Recommend the best chain based on current findings.

---

## Consolidation Triggers

### Automatic Consolidation

1. **After 5 executions of same chain**: Update success rate metrics
2. **After platform version update**: Refresh platform-specific notes
3. **Quarterly**: Recalculate amplification matrix averages
4. **Monthly**: Archive old execution records

### Event-Triggered Consolidation

1. **New chain pattern created**: Validate against existing patterns
2. **Chain execution completes**: Update pattern metrics
3. **Platform notes updated**: Cross-reference with other platforms
4. **Severity assessment changes**: Update amplification matrix

### Manual Consolidation

```
POST /memory/longterm/chaining/consolidate
{
  "action": "recalculate_metrics|archive_old_executions|validate_patterns",
  "date_range": "optional",
  "chain_ids": "optional - specific chains to consolidate"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Core-Prompts-Hunting | Input | Individual vulnerability findings |
| Advanced-Persistence-Exploitation | Bidirectional | Chain→persistence, persistence→chain |
| Real-World-Case-Studies | Input | Disclosed chain patterns |
| High-Level-World-Case-Studies | Input | Case study chain examples |
| Report-Writing-Mastery | Output | Chain findings for reporting |

### Chain Composition Rules

- Minimum 2 stages for a valid chain
- Each stage must have defined success indicators
- Chain severity ≥ max individual severity
- Platform compatibility must be verified

---

## Domain File References

### Basic Chaining (Files 01-10)

1. `01-Basic-Vulnerability-Chaining.md` - Foundational chaining concepts
2. `02-Information-Disclosure-to-RCE.md` - Info disclosure escalation chains
3. `03-XSS-to-Account-Takeover.md` - Cross-site scripting ATO chains
4. `04-IDOR-to-Mass-Data-Extraction.md` - IDOR exploitation chains
5. `05-SQL-Injection-to-Shell-Access.md` - SQLi to system access
6. `06-SSRF-to-Internal-Network-Compromise.md` - SSRF exploitation chains
7. `07-CORS-Misconfiguration-Chains.md` - CORS abuse chains
8. `08-CSRF-to-Privilege-Escalation.md` - CSRF privilege escalation
9. `09-File-Upload-to-Web-Shell.md` - Upload to shell chains
10. `10-XXE-to-Sensitive-Data-Access.md` - XXE exploitation chains

### Advanced Injection Chains (Files 11-20)

11. `11-Deserialization-to-RCE.md` - Deserialization RCE chains
12. `12-JWT-Manipulation-Chains.md` - JWT attack chains
13. `13-SSTI-to-Complete-Compromise.md` - Template injection chains
14. `14-NoSQL-Injection-to-Data-Breach.md` - NoSQL exploitation chains
15. `15-GraphQL-Abuse-Chains.md` - GraphQL attack chains
16. `16-WebSocket-Security-Chains.md` - WebSocket exploitation
17. `17-Prototype-Pollution-Exploitation.md` - Prototype pollution chains
18. `18-HTTP-Request-Smuggling-Chains.md` - Smuggling attack chains
19. `19-Host-Header-Injection-Chains.md` - Host header abuse
20. `20-DNS-Rebinding-Attacks.md` - DNS rebinding chains

### Infrastructure Chains (Files 21-30)

21. `21-Open-Redirect-to-Phishing.md` - Redirect to phishing chains
22. `22-Race-Condition-Exploitation.md` - Race condition chains
23. `23-Subdomain-Takeover-Chains.md` - Subdomain takeover chains
24. `24-Content-Spoofing-Chains.md` - Content spoofing chains
25. `25-WebCache-Poisoning-Chains.md` - Cache poisoning chains
26. `26-Clickjacking-to-Account-Compromise.md` - Clickjacking chains
27. `27-Parameter-Pollution-Attacks.md` - Parameter pollution chains
28. `28-LDAP-Injection-Chains.md` - LDAP injection chains
29. `29-XPath-Injection-Exploitation.md` - XPath injection chains
30. `30-Session-Puzzling-Techniques.md` - Session manipulation chains

### Client-Side & Advanced Chains (Files 31-40)

31. `31-Insecure-File-Handling-Chains.md` - File handling exploitation
32. `32-HTTP-Response-Splitting.md` - Response splitting chains
33. `33-Client-Side-Storage-Abuse.md` - Client storage exploitation
34. `34-Configuration-Misconfiguration-Chains.md` - Config abuse chains
35. `35-Third-Party-Component-Chains.md` - Component exploitation
36. `36-Cryptography-Weakness-Chains.md` - Crypto weakness chains
37. `37-Network-Infrastructure-Chains.md` - Network attack chains
38. `38-Mobile-API-Chains.md` - Mobile API attack chains
39. `39-Cloud-Misconfiguration-Chains.md` - Cloud exploitation chains
40. `40-Container-Escape-Chains.md` - Container escape chains

### Enterprise & Platform Chains (Files 41-49)

41. `41-Kubernetes-Attack-Chains.md` - Kubernetes attack chains
42. `42-Blockchain-Exploit-Chains.md` - Blockchain exploitation
43. `43-IoT-Device-Compromise-Chains.md` - IoT attack chains
44. `44-Supply-Chain-Attack-Chains.md` - Supply chain attack chains
45. `45-Multi-Platform-Attack-Chains.md` - Cross-platform chains
46. `46-Zero-Day-Chaining-Strategies.md` - Zero-day chain strategies
47. `47-Advanced-Persistent-Threat-Chains.md` - APT chain patterns
48. `48-Master-Chaining-Framework.md` - Master chain framework

---

## Chain Success Rate Benchmarks

### By Chain Complexity

| Complexity | Avg Stages | Success Rate | Avg Time |
|------------|------------|--------------|----------|
| Low | 2-3 | 75-85% | 15-30 min |
| Medium | 4-5 | 50-70% | 30-60 min |
| High | 6-8 | 30-50% | 1-3 hours |
| Expert | 9+ | 15-30% | 3-8 hours |

### By Target Type

| Target Type | Avg Success Rate | Top Chain Type |
|-------------|------------------|----------------|
| Web Application | 65% | XSS→ATO |
| REST API | 55% | IDOR→Data Exfil |
| Mobile App | 45% | API Abuse→Priv Esc |
| Cloud Infra | 40% | SSRF→Metadata→Keys |
| Kubernetes | 35% | Container Escape→RCE |

---

## Severity Amplification Reference

### Common Amplification Patterns

| Base Vuln | Chain Partner | Resulting Severity | Amplification |
|-----------|---------------|-------------------|---------------|
| XSS (Medium) | Session Fixation | Critical (8.5) | 2.1x |
| IDOR (Medium) | Auth Bypass | High (7.5) | 1.9x |
| SSRF (High) | Cloud Metadata | Critical (9.0) | 1.8x |
| Open Redirect (Low) | OAuth Theft | High (7.0) | 3.5x |
| Info Disclosure (Low) | Credential Leak | High (7.5) | 4.0x |
| CSRF (Medium) | Account Change | High (8.0) | 2.0x |
| LFI (High) | Code Execution | Critical (9.5) | 1.9x |
| Race Condition (Medium) | Double Spend | High (8.0) | 2.0x |

### Amplification Rules

1. **Minimum amplification**: Combined severity > max individual severity
2. **Maximum amplification**: Capped at 10.0 (CVSS max)
3. **Threshold for Critical**: Combined severity ≥ 9.0
4. **Threshold for High**: Combined severity ≥ 7.0

---

## Security Considerations

### Chain Documentation Sensitivity

- **Full Chain Details**: Confidential - authorized use only
- **Success Rates**: Internal - team use only
- **Severity Matrices**: Internal - team use only
- **Platform Notes**: Internal - team use only

### Responsible Disclosure

- Document chains with responsible disclosure in mind
- Include impact assessment for each chain
- Recommend mitigation strategies alongside exploitation paths
- Track disclosure timelines for chain-related findings

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-02-01 | Initial chain pattern schema |
| 1.1.0 | 2024-05-01 | Added severity amplification matrix |
| 1.2.0 | 2024-08-01 | Added platform-specific notes |
| 1.3.0 | 2024-11-01 | Enhanced success rate tracking |
| 2.0.0 | 2025-02-01 | Complete schema redesign |
