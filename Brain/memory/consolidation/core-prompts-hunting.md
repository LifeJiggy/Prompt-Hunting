# MEMORY CONSOLIDATION: Core Prompts - Hunting Domain

## Domain Identity

- **Domain Name**: Core Prompts - Hunting
- **Domain Path**: `Core-Prompts-hunting/`
- **File Count**: 50 content files + README.md + registry.json
- **Domain Purpose**: Vulnerability hunting prompts, detection patterns, exploitation workflows, WAF bypass techniques, vulnerability class coverage, and hunting methodology
- **Consolidation Model**: Finding Promotion via Validation, False Positive Pruning, Vulnerability Pattern Merging

---

## Consolidation Overview

This document defines how memory consolidation operates for the Core Prompts - Hunting domain. Hunting prompts are the active intelligence that drives vulnerability discovery. Consolidation must distinguish between confirmed findings and false positives, promote effective hunting patterns, and merge similar vulnerability discoveries into unified threat assessments.

The consolidation pipeline handles five entity types: **Confirmed Findings** (validated vulnerabilities), **False Positives** (incorrectly identified issues), **Hunting Patterns** (effective detection patterns), **Vulnerability Classes** (vulnerability taxonomy entries), and **WAF Bypass Patterns** (effective bypass techniques).

---

## Domain File References

### Reconnaissance & Discovery Files

| File | Hunting Category | Consolidation Priority |
|------|-----------------|----------------------|
| `1-Reconnaissance-and-Asset-Discovery.md` | Recon methodology | HIGH — recon core |
| `2-JavaScript-Analysis-and-Deobfuscation.md` | JS analysis hunting | HIGH — tech analysis |
| `3-API-Endpoint-Analysis.md` | API hunting methods | HIGH — API hunting |
| `4-Authentication-and-Session-Management.md` | Auth hunting | CRITICAL — auth hunting |
| `5-Authorization-and-Access-Control.md` | Authorization hunting | CRITICAL — authz hunting |
| `6-Input-Validation-and-Sanitization.md` | Input validation hunting | HIGH — input hunting |
| `7-Business-Logic-Flaws.md` | Business logic hunting | HIGH — logic hunting |
| `8-Client-Side-Storage-Security.md` | Client-side hunting | MEDIUM — client-side |

### Injection Vulnerability Files

| File | Hunting Category | Consolidation Priority |
|------|-----------------|----------------------|
| `12-Server-Side-Request-Forgery-SSRF.md` | SSRF hunting | CRITICAL — SSRF |
| `13-Cross-Site-Request-Forgery-CSRF.md` | CSRF hunting | HIGH — CSRF |
| `14-Cross-Origin-Resource-Sharing-CORS.md` | CORS hunting | HIGH — CORS |
| `15-Race-Conditions-and-Concurrency-Issues.md` | Race condition hunting | HIGH — race |
| `16-Third-Party-Component-Analysis.md` | Third-party hunting | MEDIUM — dependencies |
| `17-Configuration-and-Misconfiguration-Hunting.md` | Config hunting | HIGH — misconfig |
| `18-Network-and-Infrastructure-Security.md` | Network hunting | MEDIUM — network |
| `19-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile/API hunting | MEDIUM — mobile |
| `21-Web-Application-Firewall-WAF-Bypass.md` | WAF bypass hunting | HIGH — bypass |
| `22-HTTP-Request-Smuggling.md` | HTTP smuggling hunting | HIGH — smuggling |
| `23-Subdomain-Takeover.md` | Subdomain takeover hunting | HIGH — takeover |
| `24-Host-Header-Injection.md` | Host header hunting | MEDIUM — header |
| `25-XML-External-Entity-XXE-Injection.md` | XXE hunting | CRITICAL — XXE |
| `26-Insecure-Deserialization.md` | Deserialization hunting | CRITICAL — deser |
| `27-Command-Injection.md` | Command injection hunting | CRITICAL — cmdi |
| `28-NoSQL-Injection.md` | NoSQL injection hunting | HIGH — NoSQL |
| `29-GraphQL-Vulnerabilities.md` | GraphQL hunting | HIGH — GraphQL |
| `30-WebSocket-Security.md` | WebSocket hunting | MEDIUM — WebSocket |

### Advanced Hunting Files

| File | Hunting Category | Consolidation Priority |
|------|-----------------|----------------------|
| `31-Server-Side-Template-Injection.md` | SSTI hunting | CRITICAL — SSTI |
| `32-JSON-Web-Token-JWT-Vulnerabilities.md` | JWT hunting | HIGH — JWT |
| `33-Content-Security-Policy-CSP-Bypass.md` | CSP bypass hunting | MEDIUM — CSP |
| `34-Clickjacking-and-UI-Redressing.md` | Clickjacking hunting | MEDIUM — UI |
| `35-HTTP-Parameter-Pollution.md` | HPP hunting | MEDIUM — parameter |
| `36-LDAP-Injection.md` | LDAP injection hunting | MEDIUM — LDAP |
| `37-Session-Puzzling-and-Fixation.md` | Session hunting | MEDIUM — session |
| `38-Insecure-File-Handling.md` | File handling hunting | MEDIUM — file |
| `39-Cross-Site-Script-Inclusion-XSSI.md` | XSSI hunting | MEDIUM — XSSI |
| `40-Prototype-Pollution.md` | Prototype pollution hunting | HIGH — prototype |

### Reporting & Output Files

| File | Hunting Category | Consolidation Priority |
|------|-----------------|----------------------|
| `9-Cryptography-and-Data-Protection.md` | Crypto hunting | MEDIUM — crypto |
| `10-Error-Handling-and-Information-Disclosure.md` | Error hunting | MEDIUM — error |
| `11-File-Upload-and-Processing.md` | File upload hunting | HIGH — upload |
| `20-Reporting-and-Proof-of-Concept-Development.md` | Reporting framework | HIGH — output |
| `41-HTTP-Response-Splitting.md` | Response splitting hunting | MEDIUM — response |
| `42-XPath-Injection.md` | XPath injection hunting | MEDIUM — XPath |
| `43-Cross-Site-Request-Forgery-CSRF.md` | CSRF v2 hunting | HIGH — CSRF |
| `44-Cross-Origin-Resource-Sharing-CORS.md` | CORS v2 hunting | HIGH — CORS |
| `45-Race-Conditions-and-Concurrency-Issues.md` | Race v2 hunting | HIGH — race |
| `46-Third-Party-Component-Analysis.md` | Third-party v2 | MEDIUM — dependencies |
| `47-Configuration-and-Misconfiguration-Hunting.md` | Config v2 hunting | HIGH — misconfig |
| `48-Network-and-Infrastructure-Security.md` | Network v2 hunting | MEDIUM — network |
| `49-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile/API v2 | MEDIUM — mobile |
| `50-Reporting-and-Proof-of-Concept-Development.md` | Reporting v2 | HIGH — output |

---

## Consolidation Rules

### Rule CH-01: Finding Promotion

**Trigger**: A vulnerability finding is validated through manual testing or reproduction.

**Condition**: `finding_validated == true AND validation_method == "manual" | "reproduction" | "tool_confirmation"`

**Action**:
1. Extract finding metadata: vuln_class, endpoint, parameter, severity, evidence
2. Generate finding fingerprint: `SHA256(target + vuln_class + endpoint + parameter + payload_class)`
3. Check for existing finding with same fingerprint
4. If new: create long-term finding entry with initial importance score
5. If duplicate: increment occurrence count, update severity if higher

**Finding Validation Tiers**:
| Tier | Validation Method | Confidence Boost |
|------|------------------|------------------|
| Gold | Manual reproduction + impact proof | +0.3 |
| Silver | Tool confirmation + manual verification | +0.2 |
| Bronze | Tool-only detection | +0.1 |
| Candidate | Pattern match, no confirmation | +0.0 |

### Rule CH-02: False Positive Pruning

**Trigger**: A finding is confirmed as false positive.

**Condition**: `finding_fp_confirmed == true`

**Action**:
1. Record false positive with reason and context
2. Extract FP pattern: what made this appear to be a real finding
3. Create FP detection rule
4. Update hunting patterns to avoid this FP
5. Remove from active findings

**False Positive Categories**:
| Category | Description | Detection Rule |
|----------|-------------|---------------|
| Scanner Artifact | Tool generates misleading output | Response pattern matching |
| Benign Pattern | Security feature appears malicious | Feature fingerprint |
| Outdated Finding | Vulnerability has been fixed | Version comparison |
| Incorrect Parameter | Wrong parameter tested | Parameter validation |
| Context Mismatch | Finding valid in different context | Context analysis |

### Rule CH-03: Hunting Pattern Promotion

**Trigger**: A hunting prompt or detection pattern consistently identifies real vulnerabilities.

**Condition**: `pattern_true_positive_rate >= 0.7 AND pattern_applied >= 5_times`

**Action**:
1. Extract hunting pattern: detection method, target characteristics, success indicators
2. Calculate pattern effectiveness score
3. Store in active hunting pattern library
4. Link to confirmed findings
5. Version pattern for tracking

### Rule CH-04: Vulnerability Pattern Merging

**Trigger**: Multiple findings share the same underlying vulnerability pattern.

**Condition**: `vuln_pattern_similarity >= 0.8 AND findings_share_root_cause`

**Action**:
1. Identify shared root cause
2. Merge findings into unified vulnerability assessment
3. Store individual findings as variations
4. Create comprehensive remediation recommendation
5. Update vulnerability pattern library

### Rule CH-05: WAF Bypass Pattern Tracking

**Trigger**: A WAF bypass technique is successfully demonstrated.

**Condition**: `bypass_demonstrated == true AND waf_product_identified`

**Action**:
1. Record bypass technique with WAF product context
2. Generate bypass pattern fingerprint
3. Store in WAF bypass library
4. Link to bypassed vulnerability classes
5. Track WAF product version compatibility

### Rule CH-06: Exploitation Pattern Lifecycle

**Trigger**: An exploitation pattern is validated or invalidated.

**Condition**: `exploitation_tested == true`

**Action**:
1. Record exploitation outcome with context
2. Update exploitation pattern reliability
3. If successful: promote to exploitation library
4. If failed: record failure context
5. Update exploitation recommendations

### Rule CH-07: Vulnerability Class Knowledge Update

**Trigger**: New information about a vulnerability class is discovered.

**Condition**: `knowledge_update == true AND update_source == validated`

**Action**:
1. Update vulnerability class entry
2. Propagate knowledge to all affected hunting patterns
3. Update detection rules
4. Update remediation recommendations
5. Generate knowledge update notification

### Rule CH-08: Cross-Target Pattern Validation

**Trigger**: A hunting pattern works across multiple targets.

**Condition**: `pattern_works_across_targets >= 3 AND pattern_consistent == true`

**Action**:
1. Promote pattern to "universal" status
2. Increase pattern importance score
3. Link to all validated targets
4. Generate universal pattern recommendation
5. Update pattern transferability metrics

---

## Importance Scoring System

### Finding Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Validation Tier | 0.35 | Gold/Silver/Bronze/Candidate |
| Severity | 0.25 | CVSS or equivalent |
| Uniqueness | 0.20 | How unique this finding is |
| Recency | 0.10 | Time since discovery |
| Impact Breadth | 0.10 | Number of affected resources |

### Hunting Pattern Score

| Component | Weight | Description |
|-----------|--------|-------------|
| True Positive Rate | 0.35 | Percentage of confirmed findings |
| Applicability | 0.25 | Number of targets where effective |
| Uniqueness | 0.20 | How many similar patterns exist |
| Efficiency | 0.10 | Findings per hour of hunting |
| Recency | 0.10 | Time since last validation |

### Vulnerability Class Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Discovery Frequency | 0.30 | How often this class is found |
| Impact Distribution | 0.25 | Typical severity of findings |
| Detection Difficulty | 0.20 | How hard to detect |
| Remidiation Complexity | 0.15 | How hard to fix |
| Trend Direction | 0.10 | Increasing or decreasing |

---

## Pruning Strategies

### Strategy 1: Finding Lifecycle

```
Discovered → Candidate → Validated → Confirmed →
  ├─ Active: Still relevant → Monitor quarterly
  ├─ Fixed: Remediated → Archive after 90 days
  ├─ Duplicate: Merged → Keep reference
  └─ False Positive: Removed → Record for FP detection
```

### Strategy 2: Hunting Pattern Lifecycle

```
New Pattern → Testing (5+ applications) → Validated →
  ├─ High TP Rate: Active Pattern → Monitor monthly
  ├─ Medium TP Rate: Candidate → Further testing
  ├─ Low TP Rate: Deprecated → Archive after 30 days
  └─ High FP Rate: Blocked → Immediate archive with FP analysis
```

### Strategy 3: Vulnerability Class Knowledge Retention

| Knowledge Type | Retention | Update Frequency |
|---------------|-----------|------------------|
| Active class knowledge | Permanent | As discovered |
| Outdated techniques | 180 days | Quarterly review |
| Deprecated methods | 90 days | Monthly review |
| Historical patterns | Permanent | Annual review |

### Strategy 4: WAF Bypass Library Maintenance

- **Active bypasses**: Retained, updated with WAF version tracking
- **Patched bypasses**: Archived with patch date
- **Universal bypasses**: Permanent retention, high priority
- **Product-specific bypasses**: Retained while product is in market

---

## Merge Algorithms

### Algorithm 1: Finding Consolidation

**Input**: Multiple findings with same root cause
**Process**:
1. Group findings by root cause
2. Within each group, identify most severe instance
3. Create consolidated finding with combined evidence
4. Store individual findings as instances
5. Generate comprehensive impact assessment

### Algorithm 2: Pattern Library Deduplication

**Input**: Multiple similar hunting patterns
**Process**:
1. Compute pattern similarity
2. For patterns with similarity > 0.8: merge
3. Create generalized pattern from merged patterns
4. Store specific patterns as context variants
5. Validate generalized pattern effectiveness

### Algorithm 3: Vulnerability Class Merging

**Input**: Related vulnerability classes
**Process**:
1. Build vulnerability class hierarchy
2. Identify parent-child relationships
3. Create class taxonomy with relationships
4. Store class-specific hunting guidance
5. Update class cross-references

### Algorithm 4: FP Pattern Consolidation

**Input**: Multiple false positive patterns
**Process**:
1. Group FP patterns by category
2. Create FP detection rules for each category
3. Test FP detection rules against known FPs
4. Update hunting patterns with FP avoidance
5. Track FP detection effectiveness

---

## Scheduling

### Consolidation Cycles

| Cycle | Frequency | Scope | Duration |
|-------|-----------|-------|----------|
| Finding Validation | Per validation event | Single finding | < 1 second |
| FP Recording | Per FP confirmation | Single FP | < 1 second |
| Pattern Assessment | Every 2 hours | Accumulated patterns | < 10 seconds |
| Finding Review | Daily | All active findings | < 30 seconds |
| Pattern Library Audit | Weekly | Full pattern library | < 2 minutes |
| Vulnerability Class Update | Monthly | All classes | < 5 minutes |

### Daily Finding Review

1. Review all candidate findings
2. Validate high-priority candidates
3. Process validation results
4. Update finding importance scores
5. Generate daily finding report

### Weekly Pattern Assessment

1. Evaluate all hunting patterns
2. Calculate updated effectiveness scores
3. Promote/demote patterns
4. Archive stale patterns
5. Generate pattern library report

---

## Metrics and Monitoring

### Hunting Health Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Finding Validation Rate | > 70% candidates validated | < 50% |
| False Positive Rate | < 15% | > 30% |
| Pattern Effectiveness | > 60% TP rate | < 40% |
| Finding Uniqueness | > 70% unique findings | < 50% |
| Coverage Breadth | > 80% vuln classes covered | < 60% |

### Pattern Quality Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Pattern Transferability | Success across different targets | > 50% |
| Pattern Longevity | Pattern remains effective over time | > 6 months |
| Pattern Efficiency | Findings per hour of pattern use | Track trend |
| Pattern Complementarity | Pattern covers gaps in other patterns | > 30% unique coverage |

---

## Cross-Domain References

### Primary Dependencies

| Domain | Relationship | Data Flow |
|--------|-------------|-----------|
| `advanced-automation` | Automation executes hunting patterns | Patterns → automation workflows |
| `advanced-chaining-techniques` | Findings become chain components | Validated findings → chains |
| `core-prompts-learning` | Learning enhances hunting knowledge | Learned patterns → hunting |
| `report-writing-mastery` | Findings become report content | Validated findings → reports |

### Secondary Dependencies

| Domain | Relationship | Impact |
|--------|-------------|--------|
| `bug-bounty-support` | Support provides hunting methodology | Framework guidance |
| `real-world-case-studies` | Cases inform hunting patterns | Pattern validation |
| `reconnaissance-deep-dive` | Recon feeds hunting targets | Target selection |
| `bug-bounty-program-strategy` | Strategy guides hunting priorities | Priority data |

---

## Hunting Prompt Effectiveness Tracking

### Prompt Performance Metrics

| Metric | Measurement | Target |
|--------|-------------|--------|
| Prompt Application Rate | Times used per week | > 10 |
| Finding Yield | Findings per application | > 0.5 |
| Quality Score | Accepted findings / total | > 60% |
| Uniqueness Score | Unique findings / total | > 70% |
| Time Efficiency | Findings per hour | > 0.2 |

### Prompt Version Control

Each prompt version tracks:
- Version number and change description
- Performance metrics at version creation
- Comparison with previous version
- Rollback decision criteria

### Prompt Selection Algorithm

```
applicable_prompts = filter_by_target_type(all_prompts, target_type)
ranked_prompts = sort_by(applicable_prompts, effectiveness_score, desc)
selected = top_n(ranked_prompts, 5)
return selected with confidence_scores
```

---

## Vulnerability Class Coverage Analysis

### Coverage Matrix

| Vuln Class | Hunting Prompt | Automation Support | Manual Verification |
|-----------|---------------|-------------------|-------------------|
| SQL Injection | 12-SQLi | sqlmap integration | Time-based confirm |
| XSS | 13-XSS | XSStrike | DOM analysis |
| SSRF | 14-SSRF | SSRFmap | Internal service access |
| IDOR | 11-IDOR | Autorize | Parameter manipulation |
| XXE | 17-XXE | XXEinject | Data extraction |
| SSTI | 18-SSTI | Tplmap | RCE confirmation |
| Command Injection | 16-CMDI | Commix | Output verification |
| Deserialization | 20-Deser | ysoserial | Gadget chain confirm |

### Coverage Gap Identification

Gaps are identified when:
- A vulnerability class has no active hunting prompt
- A hunting prompt hasn't produced findings in 90 days
- New vulnerability classes emerge without coverage
- Target technology stack has unexplored attack surfaces

### Gap Remediation Priority

| Priority | Gap Type | Response Time |
|----------|---------|--------------|
| Critical | High-value class with no coverage | 1 week |
| High | Active class with declining results | 2 weeks |
| Medium | Low-frequency class with gaps | 1 month |
| Low | Emerging class with partial coverage | 3 months |

---

## False Positive Pattern Database

### FP Categories and Detection Rules

| FP Category | Detection Rule | Prevention Method |
|-------------|---------------|-------------------|
| Scanner artifact | Response contains tool signature | Post-scan validation |
| Benign feature | Feature matches security pattern | Context-aware analysis |
| Outdated finding | Version indicates fix applied | Version check first |
| Parameter pollution | Multiple param values confuse | Parameter isolation |
| Encoding artifact | Encoding creates false signal | Decode before analysis |

### FP Rate Tracking

| Pattern | FP Rate (Before) | FP Rate (After) | Improvement |
|---------|------------------|-----------------|-------------|
| XSS detection | 25% | 8% | 68% reduction |
| SQLi detection | 20% | 5% | 75% reduction |
| SSRF detection | 30% | 12% | 60% reduction |
| IDOR detection | 15% | 4% | 73% reduction |
| Open redirect | 35% | 15% | 57% reduction |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-26 | Initial consolidation framework for Core Prompts - Hunting domain |
| 1.1.0 | 2026-06-26 | Added prompt effectiveness tracking, vulnerability coverage analysis, and FP pattern database |

---

## Hunting Session Workflow

### Pre-Hunt Checklist

1. Verify target scope and rules
2. Load applicable hunting prompts
3. Configure tools and proxies
4. Set time limits and goals
5. Document starting state

### Active Hunting Protocol

1. Execute hunting prompts in priority order
2. Record all findings immediately
3. Validate findings before moving on
4. Note false positives for FP database
5. Track time per vulnerability class

### Post-Hunt Documentation

1. Compile all findings
2. Prioritize by severity and confidence
3. Begin report drafting for top findings
4. Update hunting pattern effectiveness
5. Generate session summary
