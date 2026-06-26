# MEMORY CONSOLIDATION: Advanced Chaining Techniques Domain

## Domain Identity

- **Domain Name**: Advanced Chaining Techniques
- **Domain Path**: `Advanced-Chaining-Techniques/`
- **File Count**: 49 content files + README.md + registry.json
- **Domain Purpose**: Multi-vulnerability attack chains, cross-class exploitation sequences, compound impact demonstrations, and chain-to-RCE patterns
- **Consolidation Model**: Chain Validation via End-to-End Proof, Pattern Deduplication via Chain Signature, Temporal Pruning via Chain Expiry

---

## Consolidation Overview

This document defines how memory consolidation operates for the Advanced Chaining Techniques domain. Attack chains are the most complex artifacts in the memory system — they span multiple vulnerability classes, require sequential validation, and carry high importance scores when proven. Consolidation for chaining is unique because chains are composable: individual chain links may be reusable across multiple chains, requiring a link-level memory tier separate from full-chain memory.

The consolidation pipeline handles four entity types: **Chain Links** (individual vulnerability steps), **Full Chains** (complete multi-step attacks), **Chain Templates** (reusable chain patterns), and **Chain Failures** (validated dead-end approaches).

---

## Domain File References

### Chain Link Files

| File | Chain Role | Consolidation Priority |
|------|-----------|----------------------|
| `01-Basic-Vulnerability-Chaining.md` | Fundamental chaining principles | CRITICAL — foundational |
| `02-Information-Disclosure-to-RCE.md` | Info disclosure chain primitive | HIGH — RCE escalation path |
| `03-XSS-to-Account-Takeover.md` | XSS→ATO chain pattern | CRITICAL — high-impact chain |
| `04-IDOR-to-Mass-Data-Extraction.md` | IDOR→data exfil chain | CRITICAL — high-impact chain |
| `05-SQL-Injection-to-Shell-Access.md` | SQLi→RCE chain | CRITICAL — maximum impact |
| `06-SSRF-to-Internal-Network-Compromise.md` | SSRF→pivoting chain | CRITICAL — network impact |
| `07-CORS-Misconfiguration-Chains.md` | CORS exploitation chains | HIGH — origin abuse |
| `08-CSRF-to-Privilege-Escalation.md` | CSRF→privesc chain | HIGH — auth boundary |
| `09-File-Upload-to-Web-Shell.md` | Upload→RCE chain | CRITICAL — direct RCE |
| `10-XXE-to-Sensitive-Data-Access.md` | XXE→data exfil chain | HIGH — data breach |
| `11-Deserialization-to-RCE.md` | Deser→RCE chain | CRITICAL — maximum impact |
| `12-JWT-Manipulation-Chains.md` | JWT abuse chains | HIGH — auth manipulation |
| `13-SSTI-to-Complete-Compromise.md` | SSTI→full compromise | CRITICAL — RCE path |
| `15-NoSQL-Injection-to-Data-Breach.md` | NoSQLi→data breach | HIGH — data impact |
| `16-GraphQL-Abuse-Chains.md` | GraphQL attack chains | HIGH — API exploitation |
| `17-WebSocket-Security-Chains.md` | WebSocket attack chains | MEDIUM — modern protocol |
| `18-Prototype-Pollution-Exploitation.md` | Prototype pollution chains | HIGH — JS exploitation |
| `19-HTTP-Request-Smuggling-Chains.md` | Smuggling attack chains | HIGH — proxy exploitation |
| `20-Host-Header-Injection-Chains.md` | Host header chains | MEDIUM — header abuse |
| `21-DNS-Rebinding-Attacks.md` | DNS rebinding chains | HIGH — network bypass |
| `22-Race-Condition-Exploitation.md` | Race condition chains | MEDIUM — timing abuse |
| `23-Subdomain-Takeover-Chains.md` | Subdomain takeover chains | HIGH — infrastructure abuse |
| `24-Open-Redirect-to-Phishing.md` | Redirect→phishing chains | MEDIUM — social engineering |
| `25-Content-Spoofing-Chains.md` | Spoofing attack chains | MEDIUM — content manipulation |
| `26-WebCache-Poisoning-Chains.md` | Cache poisoning chains | HIGH — cache abuse |
| `27-Clickjacking-to-Account-Compromise.md` | Clickjacking→ATO | HIGH — UI manipulation |
| `28-Parameter-Pollution-Attacks.md` | Parameter pollution chains | MEDIUM — input manipulation |
| `29-LDAP-Injection-Chains.md` | LDAP injection chains | MEDIUM — directory abuse |
| `30-XPath-Injection-Exploitation.md` | XPath injection chains | MEDIUM — XML abuse |
| `31-Session-Puzzling-Techniques.md` | Session puzzling chains | HIGH — session manipulation |
| `32-Insecure-File-Handling-Chains.md` | File handling chains | MEDIUM — file system abuse |
| `33-Cross-Site-Script-Inclusion.md` | XSSI attack chains | MEDIUM — cross-origin |
| `34-HTTP-Response-Splitting.md` | Response splitting chains | MEDIUM — header injection |
| `35-Client-Side-Storage-Abuse.md` | Storage abuse chains | MEDIUM — client-side |
| `36-Cryptography-Weakness-Chains.md` | Crypto weakness chains | HIGH — crypto exploitation |
| `37-Third-Party-Component-Chains.md` | Third-party chain patterns | HIGH — dependency abuse |
| `38-Configuration-Misconfiguration-Chains.md` | Config misconfig chains | HIGH — infrastructure abuse |
| `39-Network-Infrastructure-Chains.md` | Network infra chains | HIGH — network impact |
| `40-Mobile-API-Chains.md` | Mobile API chain patterns | MEDIUM — mobile exploitation |
| `41-Cloud-Misconfiguration-Chains.md` | Cloud misconfig chains | HIGH — cloud impact |
| `42-Container-Escape-Chains.md` | Container escape chains | CRITICAL — escape chains |
| `43-Kubernetes-Attack-Chains.md` | K8s attack chains | HIGH — orchestration abuse |
| `44-Blockchain-Exploit-Chains.md` | Blockchain chain patterns | MEDIUM — web3 exploitation |
| `45-IoT-Device-Compromise-Chains.md` | IoT compromise chains | MEDIUM — device exploitation |
| `46-Supply-Chain-Attack-Chains.md` | Supply chain chains | CRITICAL — supply chain |
| `47-Zero-Day-Chaining-Strategies.md` | Zero-day chaining strategies | HIGH — advanced chaining |
| `48-Multi-Platform-Attack-Chains.md` | Cross-platform chains | HIGH — platform bridging |
| `49-Advanced-Persistent-Threat-Chains.md` | APT chain patterns | HIGH — persistence chains |
| `50-Master-Chaining-Framework.md` | Master framework | CRITICAL — meta-chaining |

---

## Consolidation Rules

### Rule AC-01: Chain Link Promotion

**Trigger**: An individual vulnerability step in a chain is successfully exploited.

**Condition**: `step_exploited == true AND step_evidence != null`

**Action**:
1. Extract chain link metadata: vuln_class, entry_point, impact, prerequisite, payload
2. Generate link fingerprint: `SHA256(vuln_class + entry_point + prerequisite_hash)`
3. Store in chain link library
4. Calculate link reusability score based on:
   - Number of chains this link appears in
   - Diversity of contexts where effective
   - Impact of the link step in isolation vs in chain

**Link Reusability Score**:
```
reusability = chain_appearances / total_chains * 0.4
            + context_diversity * 0.3
            + standalone_impact * 0.3
```

### Rule AC-02: Full Chain Promotion

**Trigger**: An attack chain is successfully demonstrated end-to-end.

**Condition**: `chain_complete == true AND all_steps_validated AND chain_impact_demonstrated`

**Action**:
1. Validate each chain step has evidence
2. Compute chain complexity score: `sum(step_complexity) / chain_length`
3. Compute chain impact score: `final_impact * chain_reliability`
4. Store full chain with linked chain links
5. Generate chain signature for deduplication

**Chain Signature**:
```
signature = SHA256(
  sort(vuln_classes_in_chain) +
  step_sequence_hash +
  target_archetype_hash
)
```

### Rule AC-03: Chain Failure Recording

**Trigger**: A chain attempt fails at a specific step.

**Condition**: `chain_attempt_failed == true AND failure_step_identified`

**Action**:
1. Record failure: chain_template_id, failure_step, failure_reason, failure_context
2. Update chain template reliability: `new_reliability = (successes / (successes + failures)) * weight`
3. If reliability drops below 0.3: mark template as unreliable
4. If failure is due to a defensive control: record as negative knowledge
5. If failure is due to target-specific config: record with target_class tag

### Rule AC-04: Chain Pattern Merge

**Trigger**: Two or more chains share 60%+ of their steps.

**Condition**: `step_overlap >= 0.6 OR chain_signature_similarity >= 0.8`

**Action**:
1. Identify shared steps (common prefix or common subsequence)
2. Create base chain template from shared steps
3. Store chain-specific steps as conditional variations
4. Link all original chains to the merged template
5. Calculate template generality score

### Rule AC-05: Dead-End Chain Pruning

**Trigger**: A chain template has 3+ consecutive failures with no successes.

**Condition**: `consecutive_failures >= 3 AND recent_successes == 0`

**Action**:
1. Move chain template to low-priority queue
2. Set extended TTL: 90 days for re-evaluation
3. If failures continue during TTL: archive with "deprecated" tag
4. Preserve one example for historical reference
5. Remove from active chain recommendation engine

### Rule AC-06: Chain Component Decomposition

**Trigger**: A complex chain (4+ steps) is successfully validated.

**Condition**: `chain_length >= 4 AND chain_validated == true`

**Action**:
1. Decompose chain into sub-chains of length 2 and 3
2. Evaluate each sub-chain's standalone viability
3. Promote viable sub-chains to chain link library
4. Tag sub-chains with parent_chain reference
5. Update sub-chain reusability scores

### Rule AC-07: Chain Impact Recalculation

**Trigger**: New information changes the assessed impact of a chain.

**Condition**: `impact_context_changed == true`

**Action**:
1. Recalculate chain impact using updated context
2. Propagate impact changes to all chains containing affected links
3. Update importance scores for all affected entries
4. Re-evaluate chain priority rankings
5. Alert if impact downgrade moves chain below promotion threshold

### Rule AC-08: Cross-Domain Chain Integration

**Trigger**: A chain spans multiple memory domains.

**Condition**: `chain_steps_span >= 2_domains`

**Action**:
1. Create cross-domain chain entry in both domains
2. Establish bidirectional references
3. Consolidate chain in the domain with highest step count
4. Store summary in secondary domain with link to primary
5. Update cross-domain correlation indices

---

## Importance Scoring System

### Chain Score Components

| Component | Weight | Description |
|-----------|--------|-------------|
| Impact Severity | 0.30 | Final chain impact (RCE=1.0, Data=0.8, Auth=0.7, Info=0.3) |
| Chain Reliability | 0.25 | Success rate across attempts |
| Step Count | 0.15 | Longer chains are rarer but harder to demonstrate |
| Uniqueness | 0.15 | How many similar chains exist in library |
| Recency | 0.10 | Time since last successful demonstration |
| Component Reuse | 0.05 | How reusable the chain links are |

### Chain Complexity Tiers

| Tier | Step Count | Complexity Bonus | Typical Impact |
|------|-----------|-----------------|----------------|
| Simple | 2 steps | 1.0x | Variable |
| Moderate | 3 steps | 1.2x | Usually High+ |
| Complex | 4-5 steps | 1.5x | Usually Critical |
| Advanced | 6+ steps | 2.0x | Critical / APT-level |

### Chain Reliability Classes

| Class | Success Rate | Action |
|-------|-------------|--------|
| Proven | >= 80% | Active recommendation, high priority |
| Reliable | 60-79% | Active recommendation, medium priority |
| Experimental | 40-59% | Candidate, requires validation |
| Unreliable | 20-39% | Low priority, archive candidate |
| Deprecated | < 20% | Archive, historical reference only |

---

## Pruning Strategies

### Strategy 1: Chain Lifecycle Management

```
New Chain → Experimental (0-30 days) →
  ├─ Proven (80%+ success) → Active Library → Archive after 180 days without use
  ├─ Reliable (60-79%) → Active Library → Re-evaluate quarterly
  ├─ Unreliable (<60%) → Low Priority → Archive after 90 days
  └─ Failed (0 successes, 3+ attempts) → Deprecated → Archive after 30 days
```

### Strategy 2: Chain Link Lifecycle

```
New Link → Candidate (test in 3+ chains) →
  ├─ Reusable (appears in 3+ chains) → Link Library → Permanent
  ├─ Contextual (appears in 1-2 chains) → Context Library → Prune after 90 days
  └─ Non-viable (fails in all contexts) → Dead Link → Archive after 30 days
```

### Strategy 3: Capacity-Based Eviction

When chain library exceeds capacity:
1. Calculate composite score for each chain: `impact * reliability * uniqueness`
2. Identify chains below threshold
3. Preserve at least one example per chain class (XSS→ATO, SQLi→RCE, etc.)
4. Archive evicted chains with full metadata

### Strategy 4: Temporal Pruning

- **Working Memory**: Chain attempts older than 3 days without success → evict
- **Transition Cache**: Chains not demonstrated in 60 days → review for archive
- **Long-Term Store**: Chains not referenced in 180 days → archive candidate

---

## Merge Algorithms

### Algorithm 1: Chain Subsumption

**Input**: Two chains where one is a superset of the other
**Process**:
1. Check if chain A's step sequence is a subsequence of chain B
2. If yes: A is subsumed by B
3. Create reference from A to B
4. Keep A in library as "stepping stone" to B
5. Update B's component library to include A as intermediate

### Algorithm 2: Parallel Chain Merging

**Input**: Two chains that achieve same impact via different paths
**Process**:
1. Verify both chains reach same impact level
2. Compare complexity scores
3. Create merged entry linking both paths
4. Store as "dual-path chain" with reliability = max(reliability_a, reliability_b)
5. Recommend both paths, prefer simpler path

### Algorithm 3: Chain Link Deduplication

**Input**: Multiple chain links with similar signatures
**Process**:
1. Compute link signature similarity
2. For links with similarity > 0.85: merge into generalized link
3. Store generalized link with context variations
4. Replace specific links in chains with generalized reference
5. Validate all chains still valid after replacement

### Algorithm 4: Chain Library Optimization

**Input**: Full chain library
**Process**:
1. Build chain dependency graph (links referenced by chains)
2. Identify orphan links (not in any chain)
3. Identify critical links (in 3+ chains)
4. Prune orphan links older than 60 days
5. Protect critical links from eviction
6. Optimize storage by deduplicating link metadata

---

## Scheduling

### Consolidation Cycles

| Cycle | Frequency | Scope | Duration |
|-------|-----------|-------|----------|
| Chain Completion | Per chain attempt | Single chain | < 2 seconds |
| Link Batch | Every 2 hours | Accumulated chain links | < 10 seconds |
| Chain Evaluation | Every 4 hours | All experimental chains | < 30 seconds |
| Library Optimization | Daily at 01:00 UTC | Full chain library | < 5 minutes |
| Reliability Recalc | Weekly | All chains with 5+ attempts | < 2 minutes |
| Archive Sweep | Monthly | Long-term archive | < 1 minute |

### Chain Completion (Per-Attempt)

Immediate processing after each chain attempt:
1. Record attempt outcome (success/failure/partial)
2. Update chain reliability metrics
3. If success: run full chain validation
4. If failure: record failure context
5. If partial: record which steps succeeded

### Link Batch (Hourly)

Process accumulated chain links:
1. Deduplicate new links against existing library
2. Calculate link reusability scores
3. Promote high-reusability links to library
4. Merge similar links
5. Update chain compositions

### Chain Evaluation (4-Hour)

Evaluate experimental chains:
1. Review chains in experimental status
2. Calculate promotion eligibility
3. Promote proven chains to active library
4. Demote unreliable chains
5. Update chain recommendations

---

## Metrics and Monitoring

### Chain Health Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Chain Success Rate (Overall) | > 50% | < 30% |
| Link Library Coverage | > 90% chain steps covered | < 70% |
| Duplicate Chain Rate | < 10% | > 20% |
| Chain Completeness Rate | > 80% steps validated | < 60% |
| Average Chain Length | 3-4 steps | > 6 steps (complexity) |
| Chain Diversity Index | > 0.7 | < 0.4 |

### Chain Quality Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Impact Accuracy | Chain impact matches demonstrated impact | > 90% |
| Reliability Accuracy | Predicted reliability matches observed | > 85% |
| Merge Quality | Merged chains maintain original validity | > 95% |
| Archive Accuracy | Archived chains were truly obsolete | > 80% |

---

## Cross-Domain References

### Primary Dependencies

| Domain | Relationship | Data Flow |
|--------|-------------|-----------|
| `advanced-automation` | Automation generates chain inputs | Scan results → chain candidates |
| `advanced-persistence-exploitation` | Persistence chains extend automation findings | High-impact chains → persistence |
| `core-prompts-hunting` | Hunting prompts trigger chain discovery | Chain patterns → hunting templates |
| `real-world-case-studies` | Real cases validate chain patterns | Disclosed chains → scoring calibration |

### Secondary Dependencies

| Domain | Relationship | Impact |
|--------|-------------|--------|
| `automation-efficiency` | Efficiency metrics guide chain optimization | Performance data |
| `bug-bounty-program-strategy` | Program scope limits chain scope | Strategy constraints |
| `report-writing-mastery` | Chains become report subjects | Output formatting |
| `high-level-world-case-studies` | Historical chains inform new patterns | Pattern library |

### Chain Domain Interaction Map

```
advanced-automation ──scan_results──> advanced-chaining-techniques
                                          │
                         ┌─────────────────┤
                         │                 │
                         v                 v
              core-prompts-hunting    advanced-persistence-exploitation
                         │                 │
                         v                 v
              report-writing-mastery    real-world-case-studies
```

---

## Domain-Specific Consolidation Notes

### Chain Entity Types

| Entity Type | Memory Tier | TTL | Max Count |
|-------------|------------|-----|-----------|
| Chain Link | Link Library | Permanent if reused | 500 |
| Full Chain | Chain Library | 180 days without use | 200 |
| Chain Template | Template Library | 90 days without use | 100 |
| Failed Chain | Failure Archive | 30 days | 50 |
| Chain Pattern | Pattern Library | Permanent | 50 |

### Chain Fingerprint Format

```json
{
  "chain_id": "chain_<uuid>",
  "chain_signature": "sha256_hex",
  "steps": [
    {
      "step_index": 0,
      "link_id": "link_<uuid>",
      "vuln_class": "xss",
      "prerequisite": null,
      "payload_hash": "sha256_hex",
      "evidence_ref": "ref_id"
    }
  ],
  "impact": "rce|data_breach|auth_bypass|privilege_escalation|info_disclosure",
  "reliability": 0.0-1.0,
  "complexity": "simple|moderate|complex|advanced",
  "status": "experimental|proven|reliable|unreliable|deprecated",
  "created_at": "ISO8601",
  "last_successful": "ISO8601",
  "attempt_count": 0,
  "success_count": 0
}
```

### Chain Recommendation Engine

When recommending chains for a target:
1. Filter chains by applicable technology stack
2. Filter by target scope (in-scope only)
3. Rank by: `impact * reliability * (1 / complexity) * recency_bonus`
4. Return top 5 chains with estimated success probability
5. Include fallback chains for each primary recommendation

---

## Chain Success Classification Taxonomy

### Impact Achievement Levels

| Level | Description | Score Range | Example |
|-------|-------------|-------------|---------|
| Level 1 | Information disclosure | 0.1-0.3 | Leaking internal headers |
| Level 2 | Authentication bypass | 0.3-0.5 | Accessing admin panel |
| Level 3 | Privilege escalation | 0.5-0.7 | Regular user to admin |
| Level 4 | Data breach | 0.7-0.85 | Exfiltrating user records |
| Level 5 | Remote code execution | 0.85-1.0 | Command execution on server |

### Chain Reliability Classification

| Class | Success Rate | Recommended Use |
|-------|-------------|----------------|
| Battle-Tested | >= 90% | Primary chain for target class |
| Proven | 75-89% | Reliable with minor variations |
| Experimental | 50-74% | Requires validation per target |
| Fragile | 25-49% | Only when other options exhausted |
| Unreliable | < 25% | Archive, historical reference |

### Chain Complexity Impact Matrix

| Complexity | Steps | Typical Time | Skill Required | Reward Potential |
|-----------|-------|-------------|----------------|------------------|
| Simple | 2 | < 1 hour | Intermediate | Low-Medium |
| Moderate | 3 | 1-4 hours | Advanced | Medium-High |
| Complex | 4-5 | 4-12 hours | Expert | High-Critical |
| Advanced | 6+ | 12+ hours | Master | Critical-APT |

---

## Chain Validation Protocol

### Pre-Execution Checklist

Before attempting a chain:
1. Verify all target assets are in scope
2. Confirm prerequisite access level
3. Validate tool availability and configuration
4. Estimate time and resource requirements
5. Document expected chain path

### Execution Documentation Requirements

Each chain attempt must record:
- Start timestamp and initial state
- Each step execution with request/response
- Success or failure at each step
- Intermediate findings
- Final outcome and impact demonstration
- Total time invested

### Post-Execution Analysis

After each chain attempt:
1. Calculate actual vs predicted reliability
2. Identify chain bottleneck steps
3. Document environment-specific factors
4. Update chain template with lessons learned
5. Generate chain improvement recommendations

---

## Chain Link Quality Assessment

### Link Reusability Criteria

A chain link is considered reusable when:
- It works across multiple target types
- It requires minimal modification for new contexts
- Its prerequisites are commonly available
- Its payload is not target-specific
- It has been validated in >= 3 different contexts

### Link Dependency Analysis

Chain links have dependency types:
- **Hard dependency**: Cannot proceed without this link succeeding
- **Soft dependency**: Can skip with reduced impact
- **Enabling dependency**: Creates conditions for next link
- **Information dependency**: Provides data needed by next link

### Link Risk Assessment

Each link carries risk factors:
- **Detection probability**: Likelihood of triggering WAF/IDS
- **Collateral damage**: Side effects on target system
- **Reversibility**: Whether effects can be undone
- **Time sensitivity**: Whether link has expiration

---

## Chain Environment Factors

### Target Architecture Impact

| Architecture | Chain Impact | Adaptation Required |
|-------------|-------------|-------------------|
| Monolith | Standard chain applies | Minimal |
| Microservices | May need service hopping | Medium |
| Serverless | Short execution windows | High |
| Legacy | Limited API surface | Variable |
| Cloud-native | Multiple access paths | Medium |

### Defensive Control Impact

| Defense | Chain Impact | Bypass Strategy |
|---------|-------------|----------------|
| WAF | High | Encoding, fragmentation |
| RASP | High | Memory-only techniques |
| EDR | Medium | Living-off-the-land |
| Network segmentation | High | Pivot through compromised hosts |
| MFA | Medium | Session token theft |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-26 | Initial consolidation framework for Advanced Chaining Techniques domain |
| 1.1.0 | 2026-06-26 | Added chain classification taxonomy, validation protocol, link quality assessment, and environment factors |
