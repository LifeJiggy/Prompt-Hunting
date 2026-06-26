# MEMORY CONSOLIDATION: Advanced Automation Domain

## Domain Identity

- **Domain Name**: Advanced Automation
- **Domain Path**: `Advanced-Automation/`
- **File Count**: 50 content files + README.md + registry.json
- **Domain Purpose**: Automated scanning workflows, tool orchestration, vulnerability detection pipelines, and result analysis systems
- **Consolidation Model**: Working-to-Long-Term Promotion via Success Validation, Stale Data Pruning via Time-Decay, Deduplication via Fingerprint Matching

---

## Consolidation Overview

This document defines how memory consolidation operates for the Advanced Automation domain. Every scan result, tool configuration, workflow pattern, and automation script exists first in working memory as ephemeral data. Consolidation determines what gets promoted to durable long-term knowledge, what gets pruned, and how overlapping findings are merged into unified representations.

The consolidation pipeline has three phases: **Acquisition** (raw scan data enters working memory), **Evaluation** (scoring and validation), and **Commit** (promoted to long-term or pruned). Each phase has domain-specific rules tailored to automated scanning workflows.

---

## Domain File References

### Core Automation Files

| File | Domain Role | Consolidation Priority |
|------|------------|----------------------|
| `01-Subdomain-Enumeration-Automation.md` | Subdomain discovery pipeline templates | HIGH — foundational recon |
| `02-Port-Scanning-Automation.md` | Port scan orchestration patterns | HIGH — core infrastructure |
| `03-Vulnerability-Scanning-Automation.md` | Vuln scanner integration workflows | CRITICAL — primary output |
| `04-JavaScript-Analysis-Automation.md` | JS deobfuscation and endpoint extraction | HIGH — attack surface |
| `05-API-Endpoint-Discovery.md` | API enumeration automation | HIGH — modern attack surface |
| `06-Parameter-Fuzzing-Automation.md` | Parameter discovery and fuzzing | MEDIUM — input validation |
| `07-Directory-Brute-Forcing.md` | Directory and file discovery | MEDIUM — content discovery |
| `09-Authentication-Testing-Automation.md` | Auth flow automation | HIGH — security boundary |
| `10-Session-Management-Testing.md` | Session handling validation | MEDIUM — session security |
| `11-IDOR-Detection-Automation.md` | IDOR identification pipelines | CRITICAL — high-impact class |
| `12-SQL-Injection-Automation.md` | SQLi detection automation | CRITICAL — critical vuln class |
| `13-XSS-Detection-Automation.md` | XSS identification workflows | CRITICAL — high-frequency class |
| `14-SSRF-Testing-Automation.md` | SSRF detection pipelines | CRITICAL — server-side impact |
| `15-CSRF-Testing-Automation.md` | CSRF validation automation | MEDIUM — state-changing ops |
| `16-Command-Injection-Automation.md` | Command injection detection | CRITICAL — RCE path |
| `17-XXE-Testing-Automation.md` | XXE identification automation | HIGH — data exfil vector |
| `18-SSTI-Testing-Automation.md` | SSTI detection pipelines | HIGH — template engine abuse |
| `19-JWT-Testing-Automation.md` | JWT analysis automation | HIGH — auth token security |
| `20-Deserialization-Testing.md` | Deserialization vuln detection | CRITICAL — RCE path |
| `21-Report-Generation-Automation.md` | Automated report creation | MEDIUM — output pipeline |
| `22-PoC-Development-Automation.md` | PoC script generation | HIGH — validation pipeline |
| `23-Target-Scouting-Automation.md` | Target identification workflows | MEDIUM — recon pipeline |
| `24-Scope-Validation-Automation.md` | Scope boundary verification | HIGH — operational safety |
| `25-Asset-Tracking-Automation.md` | Asset inventory management | MEDIUM — infrastructure |
| `26-Change-Monitoring-Automation.md` | Drift and change detection | HIGH — delta identification |
| `27-Notification-Alerting-Systems.md` | Alert pipeline configuration | LOW — operational support |
| `28-Data-Collection-Automation.md` | Data aggregation pipelines | MEDIUM — data pipeline |
| `29-Result-Analysis-Automation.md` | Result triage automation | HIGH — output processing |
| `30-Tool-Chaining-Automation.md` | Multi-tool orchestration | HIGH — workflow efficiency |
| `31-Proxy-Integration-Automation.md` | Proxy pipeline integration | MEDIUM — traffic analysis |
| `32-Browser-Automation-Workflows.md` | Browser-driven automation | HIGH — dynamic analysis |
| `33-Headless-Browser-Scripting.md` | Headless browser scripting | MEDIUM — automation depth |
| `34-Regex-Pattern-Automation.md` | Pattern matching automation | LOW — utility |
| `35-Response-Analysis-Automation.md` | Response classification | MEDIUM — analysis depth |
| `36-Header-Injection-Testing.md` | Header injection detection | MEDIUM — injection class |
| `37-CORS-Testing-Automation.md` | CORS misconfiguration detection | HIGH — origin security |
| `38-WebSocket-Testing-Automation.md` | WebSocket security testing | MEDIUM — modern protocol |
| `39-GraphQL-Testing-Automation.md` | GraphQL security automation | HIGH — API attack surface |
| `40-Cloud-Service-Enumeration.md` | Cloud resource discovery | HIGH — cloud attack surface |
| `41-DNS-Data-Extraction-Automation.md` | DNS data extraction pipelines | MEDIUM — infrastructure |
| `42-Email-Recon-Automation.md` | Email address enumeration | MEDIUM — recon support |
| `43-Social-Media-OSINT-Automation.md` | Social media data collection | LOW — recon support |
| `44-Framework-Detection-Automation.md` | Framework fingerprinting | MEDIUM — tech stack |
| `45-Technology-Stack-Identification.md` | Technology identification | MEDIUM — stack awareness |
| `46-Endpoint-Mapping-Automation.md` | Endpoint inventory automation | HIGH — attack surface |
| `47-Content-Discovery-Automation.md` | Content finding automation | MEDIUM — discovery |
| `48-Version-Detection-Automation.md` | Version fingerprinting | MEDIUM — vuln correlation |
| `49-Compliance-Checking-Automation.md` | Compliance validation | LOW — regulatory |
| `50-Workflow-Orchestration-Automation.md` | Meta-workflow orchestration | HIGH — automation core |

---

## Consolidation Rules

### Rule AA-01: Successful Scan Result Promotion

**Trigger**: A scan completes with confirmed vulnerability findings.

**Condition**: `scan_status == "complete" AND finding_confidence >= 0.7 AND finding_impact >= "low"`

**Action**:
1. Extract finding metadata (target, vuln_class, severity, evidence, remediation)
2. Generate a deterministic fingerprint: `SHA256(target + vuln_class + endpoint + parameter)`
3. Check long-term store for existing fingerprint match
4. If no match: create new long-term entry with initial importance_score
5. If match exists: increment occurrence_count, update timestamp, recalculate importance_score

**Importance Scoring**:
```
base_score = impact_weight[severity]
occurrence_bonus = min(occurrence_count * 0.05, 0.25)
recency_bonus = max(0, (1 - days_since_last / 90) * 0.15)
confidence_bonus = confidence * 0.2
importance_score = base_score + occurrence_bonus + recency_bonus + confidence_bonus
```

**Impact Weights**:
- CRITICAL: 1.0
- HIGH: 0.8
- MEDIUM: 0.5
- LOW: 0.3
- INFO: 0.1

### Rule AA-02: Failed Scan Attempt Pruning

**Trigger**: A scan completes with no findings or errors.

**Condition**: `scan_status == "no_findings" OR scan_status == "error"`

**Action**:
1. Check if target has been scanned before (lookup by target_hash)
2. If first scan: create negative result record with short TTL (7 days)
3. If repeat scan with no findings: extend TTL to 30 days
4. If three consecutive no-findings scans: promote to negative cache (prune from working memory)
5. If error: log error context, set TTL based on error_class

**Error TTL Mapping**:
- Network timeout: 1 day (retry soon)
- Authentication failure: 7 days (creds may change)
- WAF block: 14 days (rotation needed)
- Rate limit: 3 days (back off)
- Unknown error: 3 days (investigate)

### Rule AA-03: Duplicate Finding Merge

**Trigger**: Two or more working memory entries share a target or endpoint.

**Condition**: `target_overlap >= 0.8 OR endpoint_similarity >= 0.9`

**Action**:
1. Compare finding fingerprints
2. If fingerprints match exactly: increment occurrence_count, keep highest severity
3. If fingerprints differ but target matches: evaluate if same vuln class
4. If same class: merge into unified finding with combined evidence
5. If different classes: keep separate, link via related_findings array

**Merge Strategy**:
```
merged_finding = {
  target: common_target,
  vuln_class: highest_severity_class,
  combined_evidence: dedupe(evidence_a + evidence_b),
  combined_remediation: merge_remediation(rem_a, rem_b),
  max_severity: max(severity_a, severity_b),
  occurrence_count: count_a + count_b,
  sources: [scan_id_a, scan_id_b]
}
```

### Rule AA-04: Stale Working Memory Eviction

**Trigger**: Working memory reaches capacity threshold (80% full).

**Condition**: `working_memory_usage >= 0.8`

**Action**:
1. Sort all working memory entries by importance_score ascending
2. For entries with importance_score < 0.3 AND age > 7 days: mark for eviction
3. For entries with importance_score < 0.1 AND age > 1 day: mark for immediate eviction
4. Evict marked entries, preserving a summary (target + vuln_class + last_seen)
5. If working memory still > 80%: escalate eviction threshold

### Rule AA-05: Workflow Pattern Promotion

**Trigger**: An automation workflow completes successfully 3+ times.

**Condition**: `workflow_success_count >= 3 AND workflow_failure_rate < 0.2`

**Action**:
1. Extract workflow template (tool sequence, parameters, filters)
2. Create long-term workflow pattern entry
3. Associate with domain category (recon, vuln_scan, post_exploit, reporting)
4. Tag with applicable target_types and technology_stacks
5. Update workflow effectiveness metrics

### Rule AA-06: Tool Configuration Persistence

**Trigger**: A tool configuration proves effective across multiple targets.

**Condition**: `config_success_rate >= 0.7 AND config_use_count >= 5`

**Action**:
1. Serialize effective configuration with context metadata
2. Store in long-term configuration library
3. Tag with applicable tool, target_type, and environment characteristics
4. Version configuration for future reference
5. Link to successful findings generated using this configuration

### Rule AA-07: Regex Pattern Library Growth

**Trigger**: A new regex pattern successfully identifies a previously undetected pattern.

**Condition**: `pattern_true_positive >= 1 AND pattern_false_positive_rate < 0.3`

**Action**:
1. Validate regex correctness
2. Test against existing pattern library for duplicates
3. If novel: add to pattern library with metadata
4. If overlapping: merge patterns into optimized regex
5. Link pattern to successful finding type

### Rule AA-08: Negative Knowledge Persistence

**Trigger**: A specific technique or approach consistently fails against a target class.

**Condition**: `technique_failure_count >= 5 AND technique_failure_rate >= 0.8`

**Action**:
1. Record negative knowledge: "technique X does not work against target class Y"
2. Set TTL based on target stability (dynamic targets: 30 days, static: 90 days)
3. Link to alternative techniques that succeeded against same target class
4. Include in automation skip-list for efficiency

---

## Importance Scoring System

### Score Components

| Component | Weight | Description |
|-----------|--------|-------------|
| Severity | 0.35 | CVSS or equivalent severity rating |
| Confidence | 0.20 | How certain the finding is |
| Recency | 0.15 | Time since last validation |
| Occurrence | 0.10 | How many times observed |
| Uniqueness | 0.10 | How rare this finding pattern is |
| Impact Breadth | 0.10 | Number of affected resources |

### Score Ranges

| Range | Classification | Consolidation Action |
|-------|---------------|---------------------|
| 0.9-1.0 | CRITICAL | Immediate long-term promotion, alert generation |
| 0.7-0.89 | HIGH | Fast-track promotion, weekly review |
| 0.5-0.69 | MEDIUM | Standard promotion, monthly review |
| 0.3-0.49 | LOW | Delayed promotion, quarterly review |
| 0.0-0.29 | EVICT | Candidate for pruning |

### Score Decay Functions

**Time Decay**:
```
recency_score = base_score * e^(-lambda * days_since_last)
where lambda = 0.01 for stable targets, 0.05 for dynamic targets
```

**Frequency Decay**:
```
frequency_score = base_score * (1 - 1 / (1 + log(1 + observation_count)))
```

**Relevance Decay**:
```
relevance_score = base_score * context_match_ratio
where context_match = overlap(current_target_profile, historical_target_profile)
```

---

## Pruning Strategies

### Strategy 1: Time-Based Eviction

- **Working Memory**: Entries older than 7 days with score < 0.3 are evicted
- **Transition Cache**: Entries older than 30 days without access are candidates
- **Long-Term Archive**: Entries older than 365 days with score < 0.5 are archived

### Strategy 2: Capacity-Based Eviction

When any memory tier exceeds capacity:
1. Sort entries by importance_score ascending
2. Identify "dust" — entries below score threshold that haven't been accessed
3. Evict dust starting with oldest last-access timestamps
4. Maintain minimum 20% free capacity for new high-priority entries

### Strategy 3: Relevance-Based Eviction

- **Target Mismatch**: Working memory entries for out-of-scope targets are evicted immediately
- **Technology Mismatch**: Entries for technology stacks not in current scope are deprioritized
- **Temporal Mismatch**: Findings from expired engagement windows are archived

### Strategy 4: Duplicate Removal

- **Exact Match**: Same fingerprint → keep highest-score version
- **Near Match**: Similar target + same vuln class → merge
- **Semantic Match**: Same vulnerability pattern, different endpoint → link but keep separate

---

## Merge Algorithms

### Algorithm 1: Finding Consolidation

**Input**: Multiple findings targeting the same endpoint
**Process**:
1. Group findings by endpoint
2. Within each group, group by vulnerability class
3. For each class group: merge evidence, keep max severity, combine remediation
4. Cross-link related findings across classes
5. Generate consolidated impact assessment

### Algorithm 2: Workflow Merging

**Input**: Multiple workflow templates for same task
**Process**:
1. Compare workflow step sequences
2. Identify common steps vs optional steps
3. Merge common steps into base template
4. Store optional steps as conditional branches
5. Calculate merged workflow effectiveness score

### Algorithm 3: Pattern Library Consolidation

**Input**: Multiple similar regex or detection patterns
**Process**:
1. Compute pattern similarity using edit distance
2. For patterns with similarity > 0.8: merge into generalized pattern
3. Test merged pattern against known corpus
4. If merged pattern maintains or improves detection rate: replace originals
5. If merged pattern reduces detection: keep originals separate

### Algorithm 4: Configuration Merge

**Input**: Multiple tool configurations for same target type
**Process**:
1. Extract parameter sets from each configuration
2. Identify common parameters vs target-specific parameters
2. Create base configuration with common parameters
3. Store target-specific overrides separately
4. Link effective configurations to successful outcomes

---

## Scheduling

### Consolidation Cycles

| Cycle | Frequency | Scope | Duration |
|-------|-----------|-------|----------|
| Micro-Consolidation | Every scan completion | Single scan results | < 1 second |
| Mini-Consolidation | Every hour | Working memory batch | < 5 seconds |
| Standard Consolidation | Every 6 hours | All working memory | < 30 seconds |
| Deep Consolidation | Daily at 02:00 UTC | All memory tiers | < 5 minutes |
| Archive Consolidation | Weekly on Sunday | Long-term archive | < 15 minutes |
| Pruning Run | Daily at 03:00 UTC | All tiers, all domains | < 2 minutes |

### Micro-Consolidation (Per-Scan)

Triggered immediately after scan completion:
1. Extract findings from scan output
2. Score each finding
3. Check for duplicates in working memory
4. If duplicate: merge. If new: add with TTL
5. Update scan statistics

### Mini-Consolidation (Hourly)

Runs every hour to batch-process accumulated micro-results:
1. Aggregate all scan results from the past hour
2. Run cross-scan duplicate detection
3. Identify patterns across multiple scans
4. Promote high-scoring entries to transition cache
5. Evict expired working memory entries

### Standard Consolidation (6-Hour)

Comprehensive processing of all active memory:
1. Full working memory review
2. Cross-reference with transition cache
3. Identify promotion candidates
4. Run merge algorithms on accumulated data
5. Update importance scores based on new context

### Deep Consolidation (Daily)

Full-system consolidation cycle:
1. Complete working memory → transition cache promotion evaluation
2. Transition cache → long-term store promotion evaluation
3. Long-term store staleness review
4. Pattern library optimization
5. Configuration effectiveness review
6. Negative knowledge TTL verification
7. Metrics collection and reporting

### Archive Consolidation (Weekly)

Long-term maintenance cycle:
1. Archive low-scoring long-term entries
2. Compress and optimize storage
3. Generate weekly consolidation metrics report
4. Review and update scoring weights based on outcome data
5. Prune archived entries exceeding retention period

---

## Metrics and Monitoring

### Consolidation Health Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Working Memory Utilization | < 70% | > 85% |
| Duplicate Detection Rate | > 95% | < 90% |
| Promotion Accuracy | > 80% true positive | < 70% |
| Pruning Precision | < 5% data loss | > 10% data loss |
| Merge Quality Score | > 0.85 | < 0.70 |
| Consolidation Latency | < 1 second micro | > 5 seconds micro |
| Score Distribution Entropy | 0.4-0.7 | < 0.2 or > 0.9 |

### Performance Tracking

**Throughput Metrics**:
- Findings processed per hour
- Duplicates detected per consolidation cycle
- Merges performed per day
- Evictions performed per day

**Quality Metrics**:
- False positive rate in promoted findings
- False negative rate in pruned entries
- Merge accuracy (user-validated)
- Pattern library hit rate

### Success Criteria

| Criterion | Threshold | Measurement |
|-----------|-----------|-------------|
| Memory Efficiency | > 60% useful data ratio | promoted / total entries |
| Consolidation Speed | < 30 seconds standard | average cycle duration |
| Data Integrity | > 99.9% | checksum verification |
| Query Performance | < 10ms p99 | lookup latency |
| Storage Optimization | < 2x theoretical minimum | actual / optimal size |

---

## Cross-Domain References

### Primary Dependencies

| Domain | Relationship | Consolidation Impact |
|--------|-------------|---------------------|
| `advanced-chaining-techniques` | Chains consume automation outputs | Promoted findings become chain inputs |
| `automation-efficiency` | Efficiency drives consolidation frequency | Optimization metrics feed back into scheduling |
| `core-prompts-hunting` | Hunting prompts trigger automation | Promoted findings validate hunting approaches |
| `reconnaissance-deep-dive` | Recon feeds automation targets | Verified assets become scan targets |

### Secondary Dependencies

| Domain | Relationship | Data Flow |
|--------|-------------|-----------|
| `advanced-persistence-exploitation` | Persistence findings from automation | Low-frequency but high-impact |
| `bug-bounty-program-strategy` | Program scope guides automation targets | Strategy filters automation scope |
| `bug-bounty-support` | Support frameworks guide automation workflows | Templates inform automation templates |
| `report-writing-mastery` | Automation outputs feed report generation | Promoted findings become report content |

### Read Dependencies (consolidation reads from these)

- `real-world-case-studies`: Validated patterns for scoring calibration
- `high-level-world-case-studies`: Historical patterns for merge reference
- `core-prompts-learning`: Learned patterns for configuration optimization

### Write Dependencies (consolidation writes to these)

- `specialized-targets`: Domain-specific findings feed target profiles
- `report-writing-mastery`: Consolidated findings become report inputs
- `core-prompts-hunting`: Validated patterns enhance hunting prompts

---

## Domain-Specific Consolidation Notes

### Scan Result Lifecycle

```
Raw Scan Output → Working Memory (0-7 days) → Evaluation →
  ├─ High Score (≥0.7) → Transition Cache (7-30 days) → Long-Term Store
  ├─ Medium Score (0.3-0.7) → Transition Cache → Review → Promotion or Eviction
  └─ Low Score (<0.3) → Eviction Queue → Pruning
```

### Automation Configuration Lifecycle

```
New Config → Working Config (test period) → Validated Config →
  ├─ High Effectiveness → Production Config Library
  ├─ Medium Effectiveness → Candidate Library → Further Testing
  └─ Low Effectiveness → Deprecation Queue → Pruning
```

### Pattern Library Lifecycle

```
New Pattern → Candidate Library (30-day trial) →
  ├─ High Detection Rate → Active Pattern Library
  ├─ Medium Detection Rate → Extended Trial → Re-evaluation
  └─ Low Detection Rate → Deprecation → Archive
```

---

## Implementation Notes

### Memory Format (Working)

```json
{
  "entry_id": "auto_<uuid>",
  "domain": "advanced-automation",
  "entry_type": "scan_result|workflow|config|pattern",
  "target": "target_hash",
  "vuln_class": "sqli|xss|ssrf|...",
  "severity": "critical|high|medium|low|info",
  "confidence": 0.0-1.0,
  "evidence": "raw_evidence_ref",
  "fingerprint": "sha256_hex",
  "created_at": "ISO8601",
  "last_accessed": "ISO8601",
  "access_count": 0,
  "importance_score": 0.0-1.0,
  "ttl_days": 7,
  "tags": ["automation", "scan_type"],
  "related_entries": ["entry_id_list"]
}
```

### Memory Format (Long-Term)

```json
{
  "entry_id": "lt_<uuid>",
  "domain": "advanced-automation",
  "entry_type": "confirmed_finding|validated_workflow|production_config|mature_pattern",
  "fingerprint": "sha256_hex",
  "consolidated_from": ["working_entry_ids"],
  "occurrence_count": 1,
  "first_seen": "ISO8601",
  "last_seen": "ISO8601",
  "importance_score": 0.0-1.0,
  "effectiveness_score": 0.0-1.0,
  "confidence": 0.0-1.0,
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "archive_eligible_at": "ISO8601",
  "linked_domains": ["domain_list"],
  "evidence_refs": ["ref_list"],
  "metadata": {}
}
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-26 | Initial consolidation framework for Advanced Automation domain |
