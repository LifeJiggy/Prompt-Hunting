# Long-Term Memory: Specialized Targets

## Domain Mapping

- **Domain**: Specialized Targets
- **Root Directory**: `Specialized-Targets/`
- **Total Files**: 50 (including README.md)
- **Purpose**: Persistent memory for category-specific knowledge base, compliance mappings, and tool configurations

---

## Overview

This long-term memory system stores specialized knowledge for different target categories. It maintains category-specific testing methodologies, compliance requirements, tool configurations, and findings patterns that inform testing strategies for each target type.

### Memory Categories

1. **Category Knowledge Base** - Specialized knowledge per target type
2. **Compliance Mapping Database** - Regulatory requirements by category
3. **Tool Configuration Store** - Optimized tool configs per category
4. **Findings Pattern Library** - Common findings per category
5. **Testing Methodology Store** - Category-specific testing approaches

---

## Storage Schema

### Category Knowledge Record

```json
{
  "category_id": "string",
  "category_name": "string",
  "description": "string",
  "target_types": ["array"],
  "common_technologies": ["array"],
  "typical_architecture": "string",
  "attack_surface": ["array"],
  "common_vulnerabilities": [
    {
      "vuln_class": "string",
      "frequency": "enum: very_common|common|uncommon|rare",
      "typical_severity": "string",
      "detection_difficulty": "enum: easy|moderate|difficult"
    }
  ],
  "testing_approach": "string",
  "special_considerations": ["array"],
  "references": ["array"],
  "created": "ISO-8601",
  "last_updated": "ISO-8601"
}
```

### Compliance Mapping Record

```json
{
  "compliance_id": "string",
  "regulation": "string",
  "category": "string",
  "requirements": [
    {
      "requirement_id": "string",
      "description": "string",
      "security_control": "string",
      "testing_method": "string",
      "tool_recommendations": ["array"]
    }
  ],
  "applicable_countries": ["array"],
  "penalty_range": "string",
  "audit_frequency": "string",
  "last_reviewed": "ISO-8601"
}
```

### Tool Configuration Record

```json
{
  "config_id": "string",
  "category": "string",
  "tool_name": "string",
  "config_purpose": "string",
  "configuration": {},
  "target_profile": "string",
  "performance_notes": "string",
  "success_rate": "float 0-1",
  "usage_count": "integer",
  "created": "ISO-8601",
  "last_used": "ISO-8601"
}
```

### Findings Pattern Record

```json
{
  "pattern_id": "string",
  "category": "string",
  "vuln_class": "string",
  "pattern_name": "string",
  "description": "string",
  "indicators": ["array"],
  "detection_method": "string",
  "typical_severity": "string",
  "frequency_in_category": "enum: always|often|sometimes|rarely",
  "remediation_template": "string",
  "examples": ["array"],
  "created": "ISO-8601"
}
```

### Testing Methodology Record

```json
{
  "methodology_id": "string",
  "category": "string",
  "methodology_name": "string",
  "phases": [
    {
      "phase": "integer",
      "name": "string",
      "objective": "string",
      "techniques": ["array"],
      "tools": ["array"],
      "deliverables": ["array"],
      "estimated_time": "string"
    }
  ],
  "prerequisites": ["array"],
  "skill_level": "enum: beginner|intermediate|advanced|expert",
  "success_rate": "float 0-1",
  "created": "ISO-8601",
  "last_tested": "ISO-8601"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/specialized/categories
POST /memory/longterm/specialized/compliance-mappings
POST /memory/longterm/specialized/tool-configs
POST /memory/longterm/specialized/findings-patterns
POST /memory/longterm/specialized/methodologies
```

### Read

```
GET /memory/longterm/specialized/categories/{category_id}
GET /memory/longterm/specialized/compliance-mappings?category={cat}
GET /memory/longterm/specialized/tool-configs?category={cat}&tool={tool}
GET /memory/longterm/specialized/findings-patterns?category={cat}
GET /memory/longterm/specialized/methodologies?category={cat}
```

### Update

```
PATCH /memory/longterm/specialized/categories/{category_id}
PUT /memory/longterm/specialized/compliance-mappings/{compliance_id}
PATCH /memory/longterm/specialized/tool-configs/{config_id}
```

### Delete

```
DELETE /memory/longterm/specialized/tool-configs/{config_id}
DELETE /memory/longterm/specialized/findings-patterns/{pattern_id}
DELETE /memory/longterm/specialized/methodologies/{methodology_id}
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Category Knowledge | 365 days | Knowledge persists |
| Compliance Mapping | 180 days | Regulations change |
| Tool Configurations | 90 days | Tools update frequently |
| Findings Patterns | 365 days | Patterns persist |
| Testing Methodologies | 180 days | Methodologies evolve |

### TTL Enforcement

```python
def enforce_specialized_ttl():
    categories.review_after_days(365)
    compliance.refresh_after_days(180)
    tool_configs.validate_after_days(90)
    findings_patterns.review_after_days(365)
    methodologies.update_after_days(180)
```

---

## Compression

### Compression Strategy

- **Category Knowledge**: GZIP (detailed content)
- **Compliance Mapping**: None (structured data)
- **Tool Configurations**: None (small records)
- **Findings Patterns**: None (small records)
- **Testing Methodologies**: GZIP (step-by-step content)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "categories": {
    "category_id": "primary_key",
    "category_name": "unique_index",
    "target_types": "gin_index"
  },
  "compliance_mappings": {
    "compliance_id": "primary_key",
    "category": "hash_index",
    "regulation": "hash_index",
    "applicable_countries": "gin_index"
  },
  "tool_configs": {
    "config_id": "primary_key",
    "category": "hash_index",
    "tool_name": "hash_index",
    "success_rate": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "category_tools": ["category", "tool_name", "success_rate"],
  "compliance_requirements": ["category", "regulation"],
  "findings_frequency": ["category", "vuln_class", "frequency_in_category"]
}
```

---

## Retrieval Patterns

### Pattern 1: Category-Specific Knowledge

```
SELECT * FROM categories
WHERE category_id = ?
  OR category_name LIKE ?
```

**Get specialized knowledge for a target category.

### Pattern 2: Compliance Requirements Lookup

```
SELECT regulation, requirements, penalty_range
FROM compliance_mappings
WHERE category = ?
  AND applicable_countries @> ARRAY[?]
```

**Find applicable compliance requirements.

### Pattern 3: Tool Configuration Selection

```
SELECT tool_name, configuration, success_rate
FROM tool_configurations
WHERE category = ?
  AND success_rate > 0.7
ORDER BY success_rate DESC
```

**Find effective tool configurations for a category.

### Pattern 4: Findings Pattern Discovery

```
SELECT pattern_name, vuln_class, typical_severity,
       frequency_in_category, detection_method
FROM findings_patterns
WHERE category = ?
  AND frequency_in_category IN ('always', 'often')
ORDER BY typical_severity DESC
```

**Identify common findings for a category.

### Pattern 5: Methodology Selection

```
SELECT methodology_id, methodology_name, phases,
       skill_level, success_rate
FROM methodologies
WHERE category = ?
  AND skill_level <= ?
  AND success_rate > 0.7
ORDER BY success_rate DESC
```

**Select appropriate methodology for skill level.

---

## Consolidation Triggers

### Automatic Consolidation

1. **Monthly**: Review and update compliance mappings
2. **Quarterly**: Validate tool configurations
3. **Semi-annually**: Update category knowledge base
4. **Annually**: Review testing methodologies

### Event-Triggered Consolidation

1. **New compliance regulation**: Add to mapping database
2. **Tool version update**: Validate configurations
3. **New findings pattern**: Add to pattern library
4. **Category expansion**: Update attack surface data

### Manual Consolidation

```
POST /memory/longterm/specialized/consolidate
{
  "action": "update_compliance|validate_tools|review_patterns",
  "category": "optional filter"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Core-Prompts-Hunting | Input | Category-specific testing |
| Reconnaissance-Deep-Dive | Input | Target-specific recon |
| Advanced-Automation | Input | Tool configurations |
| Bug-Bounty-Program-Strategy | Output | Category-specific strategy |

---

## Domain File References

### IoT & Embedded Systems (Files 01-10)

1. `01-IoT-Device-Security.md` - IoT device testing
2. `02-Mobile-Application-Testing.md` - Mobile app testing
3. `03-Cloud-Infrastructure-Security.md` - Cloud infrastructure
4. `04-Container-Security.md` - Container security
5. `05-Kubernetes-Cluster-Security.md` - Kubernetes security
6. `06-Blockchain-Smart-Contracts.md` - Smart contract security
7. `07-DeFi-Protocol-Security.md` - DeFi protocol security
8. `08-NFT-Marketplace-Security.md` - NFT marketplace security
9. `09-Web3-Application-Security.md` - Web3 application security
10. `10-Cryptocurrency-Exchange-Security.md` - Exchange security

### Financial & Enterprise (Files 11-20)

11. `11-Traditional-Finance-API-Security.md` - Finance API security
12. `12-Healthcare-System-Security.md` - Healthcare security
13. `13-Financial-Institution-Security.md` - Financial institution security
14. `14-Government-System-Security.md` - Government system security
15. `15-Education-Platform-Security.md` - Education platform security
16. `16-E-commerce-Platform-Security.md` - E-commerce security
17. `17-Social-Media-Platform-Security.md` - Social media security
18. `18-Content-Management-System-Security.md` - CMS security
19. `19-Learning-Management-System-Security.md` - LMS security
20. `20-Human-Resources-System-Security.md` - HR system security

### Industrial & Infrastructure (Files 21-30)

21. `21-Supply-Chain-Management-Security.md` - Supply chain security
22. `22-Manufacturing-Control-System-Security.md` - Manufacturing security
23. `23-Smart-Building-Automation.md` - Smart building security
24. `24-Connected-Vehicle-Security.md` - Connected vehicle security
25. `25-Autonomous-System-Security.md` - Autonomous system security
26. `26-Industrial-Control-System-Security.md` - ICS security
27. `27-Medical-Device-Security.md` - Medical device security
28. `28-Wearable-Technology-Security.md` - Wearable security
29. `29-Smart-Home-Device-Security.md` - Smart home security
30. `30-Embedded-System-Security.md` - Embedded system security

### Specialized Systems (Files 31-40)

31. `31-Real-Time-Operating-System-Security.md` - RTOS security
32. `32-Firmware-Security-Analysis.md` - Firmware security
33. `33-Network-Device-Security.md` - Network device security
34. `34-Telecommunication-System-Security.md` - Telecom security
35. `35-Satellite-Communication-Security.md` - Satellite security
36. `36-Air-Traffic-Control-System-Security.md` - ATC security
37. `37-Power-Grid-Security.md` - Power grid security
38. `38-Water-Treatment-Facility-Security.md` - Water treatment security
39. `39-Transportation-System-Security.md` - Transportation security
40. `40-Energy-Management-System-Security.md` - Energy management security

### Organizational Targets (Files 41-50)

41. `41-Research-Institution-Security.md` - Research institution security
42. `42-Non-Profit-Organization-Security.md` - Non-profit security
43. `43-Startup-Company-Security.md` - Startup security
44. `44-Enterprise-Corporate-Security.md` - Enterprise security
45. `45-Fortune-500-Company-Security.md` - Fortune 500 security
46. `46-Open-Source-Project-Security.md` - Open source security
47. `47-Academic-Research-Security.md` - Academic security
48. `48-International-Organization-Security.md` - International org security
49. `49-Developing-Country-Infrastructure.md` - Developing country infrastructure
50. `50-Global-Scale-System-Security.md` - Global scale systems

---

## Category-Specific Benchmarks

### By Category

| Category | Common Vulns | Avg Severity | Testing Complexity | Avg Bounty |
|----------|--------------|--------------|-------------------|------------|
| IoT Devices | Hardcoded creds, firmware vulns | High | High | $500-$2000 |
| Cloud | Misconfig, IAM, SSRF | Critical | Medium | $1000-$5000 |
| Mobile | Insecure storage, API abuse | High | Medium | $500-$1500 |
| Web3/DeFi | Reentrancy, access control | Critical | Very High | $2000-$10000 |
| Healthcare | HIPAA violations, device vulns | Critical | High | $1000-$5000 |
| Financial | PCI violations, fraud | Critical | High | $2000-$10000 |
| Industrial/ICS | SCADA vulns, protocol issues | Critical | Very High | $5000-$20000 |

### Compliance Frequency

| Regulation | Category | Frequency | Penalty Range |
|------------|----------|-----------|---------------|
| HIPAA | Healthcare | Annual | $100-$50K per violation |
| PCI DSS | Financial | Annual | $5K-$100K per month |
| GDPR | All (EU) | Ongoing | 4% annual revenue |
| SOC 2 | Enterprise | Annual | Varies |
| NERC CIP | Power Grid | Quarterly | $1K-$1M per violation |
| FDA 510(k) | Medical Devices | Per device | Recall, fines |

---

## Tool Configuration Reference

### By Category

| Category | Primary Tools | Secondary Tools | Specialized Tools |
|----------|--------------|-----------------|-------------------|
| IoT | nmap, binwalk | Frida, Ghidra | JTAG, UART tools |
| Cloud | ScoutSuite, Prowler | Steampipe | CloudSploit |
| Mobile | Frida, Objection | MobSF | apktool |
| Web3 | Slither, Mythril | Echidna | Foundry |
| ICS | nmap, Shodan | Modbus tools | PLC tools |
| Medical | Custom scripts | Network scanners | Device analyzers |

---

## Security Considerations

### Data Sensitivity

- **Category Knowledge**: Internal - team use only
- **Compliance Mapping**: Internal - regulatory data
- **Tool Configurations**: Internal - operational data
- **Findings Patterns**: Internal - intelligence data
- **Testing Methodologies**: Internal - operational data

### Data Protection

- Protect compliance mapping from competitors
- Restrict tool configuration access
- Maintain confidentiality of findings patterns
- Secure methodology documentation

### Access Control by Role

| Role | Category Knowledge | Compliance | Tool Configs | Methodologies |
|------|-------------------|------------|--------------|---------------|
| Researcher | Read | Read | Read | Read |
| Team Lead | Read/Write | Read/Write | Read/Write | Read/Write |
| Auditor | Read | Read/Write | Read | Read |
| Admin | Full | Full | Full | Full |

### Data Retention by Sensitivity

| Data Type | Retention | Backup Frequency | Recovery Time |
|-----------|-----------|------------------|---------------|
| Category Knowledge | Indefinite | Weekly | 1 hour |
| Compliance Mapping | 5 years | Monthly | 4 hours |
| Tool Configs | 1 year | Daily | 30 minutes |
| Findings Patterns | 2 years | Weekly | 2 hours |
| Methodologies | Indefinite | Weekly | 1 hour |

---

## Category Testing Workflow

### Standard Testing Process

```
1. Identify Target Category
   └── Load category knowledge base
   └── Identify applicable compliance requirements
   └── Select appropriate methodology

2. Configure Tools
   └── Load category-specific tool configs
   └── Adjust for target technology stack
   └── Set performance profiles

3. Execute Testing
   └── Follow methodology phases
   └── Document findings using patterns
   └── Capture evidence

4. Analyze Results
   └── Map findings to category patterns
   └── Assess compliance impact
   └── Calculate risk scores

5. Generate Report
   └── Use category-specific templates
   └── Include compliance references
   └── Provide remediation guidance
```

### Quality Checklist by Category

| Category | Required Checks | Compliance Review | Documentation |
|----------|----------------|-------------------|---------------|
| Healthcare | Device isolation, data encryption | HIPAA mandatory | FDA guidelines |
| Financial | Access controls, transaction integrity | PCI DSS required | SOC 2 recommended |
| Cloud | IAM, network security, logging | GDPR if EU | Best practices |
| IoT | Firmware analysis, credential audit | Device-specific | Manufacturer guidelines |
| Industrial | Protocol analysis, safety systems | NERC CIP if applicable | ICS-CERT guidelines |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-01 | Initial specialized schema |
| 1.1.0 | 2025-03-01 | Added compliance mappings |
| 1.2.0 | 2025-06-01 | Added tool configurations |
| 1.3.0 | 2025-09-01 | Added findings patterns |
| 2.0.0 | 2025-12-01 | Complete schema redesign |
