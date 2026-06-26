# MEMORY CONSOLIDATION: Core Prompts - Learning Domain

## Domain Identity

- **Domain Name**: Core Prompts - Learning
- **Domain Path**: `Core-Prompts-Learning/`
- **File Count**: 50 content files + README.md + registry.json
- **Domain Purpose**: Learning frameworks, knowledge acquisition patterns, skill development tracking, cross-domain knowledge connections, and advanced topic mastery
- **Consolidation Model**: Knowledge Mastery Promotion, Redundant Exercise Pruning, Knowledge Connection Merging

---

## Consolidation Overview

This document defines how memory consolidation operates for the Core Prompts - Learning domain. Learning is meta-cognitive — it tracks what has been learned, what needs reinforcement, and how knowledge connects across domains. Consolidation must build a knowledge graph that grows more refined with each learning cycle, promoting mastered topics to permanent knowledge while pruning redundant exercises.

The consolidation pipeline handles four entity types: **Mastered Topics** (fully learned knowledge), **In-Progress Topics** (partially learned), **Learning Exercises** (practice activities), and **Knowledge Connections** (cross-topic relationships).

---

## Domain File References

### Reconnaissance & Discovery Learning Files

| File | Learning Category | Consolidation Priority |
|------|------------------|----------------------|
| `1-Reconnaissance-and-Asset-Discovery-Learning.md` | Recon learning | HIGH — recon mastery |
| `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | JS analysis learning | HIGH — tech mastery |
| `3-API-Endpoint-Analysis-Learning.md` | API analysis learning | HIGH — API mastery |
| `4-Authentication-and-Session-Management-Learning.md` | Auth learning | CRITICAL — auth mastery |
| `5-Authorization-and-Access-Control-Learning.md` | Authz learning | CRITICAL — authz mastery |
| `6-Input-Validation-and-Sanitization-Learning.md` | Input validation learning | HIGH — input mastery |
| `7-Business-Logic-Flaws-Learning.md` | Business logic learning | HIGH — logic mastery |
| `8-Client-Side-Storage-Security-Learning.md` | Client-side learning | MEDIUM — client mastery |
| `9-Cryptography-and-Data-Protection-Learning.md` | Crypto learning | MEDIUM — crypto mastery |
| `10-Error-Handling-and-Information-Disclosure-Learning.md` | Error handling learning | MEDIUM — error mastery |
| `11-File-Upload-and-Processing-Learning.md` | File upload learning | HIGH — upload mastery |

### Injection & Exploitation Learning Files

| File | Learning Category | Consolidation Priority |
|------|------------------|----------------------|
| `12-Server-Side-Request-Forgery-SSRF-Learning.md` | SSRF learning | CRITICAL — SSRF mastery |
| `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | CSRF learning | HIGH — CSRF mastery |
| `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | CORS learning | HIGH — CORS mastery |
| `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | Race condition learning | HIGH — race mastery |
| `16-Third-Party-Component-Analysis-Learning.md` | Third-party learning | MEDIUM — dependency mastery |
| `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | Config learning | HIGH — misconfig mastery |
| `18-Network-and-Infrastructure-Security-Learning.md` | Network learning | MEDIUM — network mastery |
| `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | Mobile/API learning | MEDIUM — mobile mastery |
| `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | Reporting learning | HIGH — output mastery |
| `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | WAF bypass learning | HIGH — bypass mastery |
| `22-HTTP-Request-Smuggling-Learning.md` | HTTP smuggling learning | HIGH — smuggling mastery |
| `23-Subdomain-Takeover-Learning.md` | Subdomain takeover learning | HIGH — takeover mastery |
| `24-Host-Header-Injection-Learning.md` | Host header learning | MEDIUM — header mastery |
| `25-XML-External-Entity-XXE-Injection-Learning.md` | XXE learning | CRITICAL — XXE mastery |
| `26-Insecure-Deserialization-Learning.md` | Deserialization learning | CRITICAL — deser mastery |
| `27-Command-Injection-Learning.md` | Command injection learning | CRITICAL — cmdi mastery |
| `28-NoSQL-Injection-Learning.md` | NoSQL injection learning | HIGH — NoSQL mastery |
| `29-GraphQL-Vulnerabilities-Learning.md` | GraphQL learning | HIGH — GraphQL mastery |
| `30-WebSocket-Security-Learning.md` | WebSocket learning | MEDIUM — WebSocket mastery |

### Advanced Topic Learning Files

| File | Learning Category | Consolidation Priority |
|------|------------------|----------------------|
| `31-Server-Side-Template-Injection-SSTI-Learning.md` | SSTI learning | CRITICAL — SSTI mastery |
| `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | JWT learning | HIGH — JWT mastery |
| `33-Content-Security-Policy-CSP-Bypass-Learning.md` | CSP bypass learning | MEDIUM — CSP mastery |
| `34-Clickjacking-and-UI-Redressing-Learning.md` | Clickjacking learning | MEDIUM — UI mastery |
| `35-HTTP-Parameter-Pollution-Learning.md` | HPP learning | MEDIUM — parameter mastery |
| `36-LDAP-Injection-Learning.md` | LDAP injection learning | MEDIUM — LDAP mastery |
| `37-Session-Puzzling-and-Fixation-Learning.md` | Session learning | MEDIUM — session mastery |
| `38-Insecure-File-Handling-Learning.md` | File handling learning | MEDIUM — file mastery |
| `39-Advanced-Client-Side-Attacks-Learning.md` | Advanced client-side learning | HIGH — advanced client mastery |
| `40-Cloud-Security-and-Misconfigurations-Learning.md` | Cloud security learning | HIGH — cloud mastery |
| `41-Third-Party-Integration-Security-Learning.md` | Third-party integration learning | MEDIUM — integration mastery |
| `42-Mobile-Application-Security-Learning.md` | Mobile app security learning | MEDIUM — mobile mastery |
| `43-IoT-and-Embedded-Device-Security-Learning.md` | IoT security learning | MEDIUM — IoT mastery |
| `44-API-Security-and-GraphQL-Learning.md` | API security learning | HIGH — API mastery |
| `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | WASM/modern web learning | MEDIUM — modern web mastery |
| `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | Blockchain security learning | MEDIUM — blockchain mastery |
| `47-Automation-and-Tool-Development-Learning.md` | Automation learning | HIGH — automation mastery |
| `48-Advanced-Reverse-Engineering-Learning.md` | Reverse engineering learning | HIGH — RE mastery |
| `49-Compliance-and-Regulatory-Security-Learning.md` | Compliance learning | MEDIUM — compliance mastery |
| `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | Threat modeling learning | HIGH — threat modeling mastery |

---

## Consolidation Rules

### Rule CL-01: Topic Mastery Promotion

**Trigger**: A topic achieves mastery level through validated learning.

**Condition**: `mastery_score >= 0.85 AND exercises_completed >= 3 AND practical_application >= 1`

**Action**:
1. Verify mastery criteria: theory understanding + practical skill + teaching ability
2. Calculate final mastery score with confidence interval
3. Promote to mastered topic library
4. Record mastery date and evidence
5. Link mastered topic to knowledge connections

**Mastery Score Calculation**:
```
mastery = theoretical_score * 0.3
        + practical_score * 0.4
        + teaching_score * 0.2
        + recency_score * 0.1
where:
  practical_score = applications_completed / applications_required
  teaching_score = knowledge_transfer_success_rate
  recency_score = 1.0 - (days_since_last_practice / 90)
```

### Rule CL-02: Redundant Exercise Pruning

**Trigger**: A learning exercise no longer contributes to mastery.

**Condition**: `exercise_redundancy >= 0.8 OR exercise_mastery_saturation == true`

**Action**:
1. Identify overlapping knowledge with other exercises
2. Calculate exercise marginal value
3. If marginal value < threshold: mark for pruning
4. Preserve exercise metadata for reference
5. Update exercise library statistics

### Rule CL-03: Knowledge Connection Building

**Trigger**: A connection between two topics is discovered during learning.

**Condition**: `connection_discovered == true AND connection_validated == true`

**Action**:
1. Record connection: topic_a, topic_b, connection_type, strength
2. Calculate connection value: `bidirectional_benefit * 0.5 + knowledge_reinforcement * 0.5`
3. Update knowledge graph
4. Generate connection-based learning recommendations
5. Update topic cross-reference indices

### Rule CL-04: Knowledge Decay Detection

**Trigger**: A mastered topic hasn't been accessed for the configured period.

**Condition**: `days_since_last_access > decay_threshold AND topic_mastery == mastered`

**Action**:
1. Calculate decay factor: `e^(-lambda * days)`
2. Reduce mastery score by decay factor
3. If mastery score drops below 0.7: move to review queue
4. Generate spaced repetition recommendations
5. Update mastery statistics

**Decay Thresholds**:
| Topic Type | Decay Start | Full Decay | Review Trigger |
|-----------|------------|------------|----------------|
| Core Concepts | 30 days | 365 days | 60 days |
| Technical Skills | 14 days | 180 days | 30 days |
| Tool Proficiency | 7 days | 90 days | 14 days |
| Methodology | 60 days | 730 days | 120 days |

### Rule CL-05: Learning Path Optimization

**Trigger**: Learning path data reveals optimization opportunities.

**Condition**: `path_data_points >= 10 AND optimization_opportunity_identified`

**Action**:
1. Analyze learning path effectiveness
2. Identify bottleneck topics
3. Recommend path adjustments
4. Update learning path library
5. Generate personalized learning recommendations

### Rule CL-06: Cross-Domain Knowledge Integration

**Trigger**: Knowledge from one domain enhances learning in another.

**Condition**: `cross_domain_benefit == true AND benefit_validated == true`

**Action**:
1. Record cross-domain knowledge transfer
2. Update cross-domain knowledge graph
3. Generate cross-domain learning recommendations
4. Update topic effectiveness scores
5. Create integrated learning modules

### Rule CL-07: Learning Exercise Generation

**Trigger**: A gap in learning coverage is identified.

**Condition**: `coverage_gap_identified == true AND gap_significance >= 0.5`

**Action**:
1. Define gap: what knowledge is missing
2. Generate targeted learning exercises
3. Link exercises to gap location
4. Track exercise effectiveness in closing gap
5. Update coverage metrics

### Rule CL-08: Mastery Maintenance Scheduling

**Trigger**: A mastered topic approaches decay threshold.

**Condition**: `days_since_last_access >= (decay_threshold * 0.8)`

**Action**:
1. Generate maintenance exercise recommendation
2. Schedule spaced repetition review
3. Update maintenance calendar
4. Track maintenance completion
5. Adjust decay parameters based on maintenance success

---

## Importance Scoring System

### Topic Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Mastery Level | 0.35 | Current mastery score |
| Relevance | 0.25 | How relevant to current work |
| Connection Value | 0.20 | How many connections to other topics |
| Recency | 0.15 | Time since last practice |
| Uniqueness | 0.05 | How unique this knowledge is |

### Exercise Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Learning Value | 0.35 | How much this teaches |
| Efficiency | 0.25 | Learning per time unit |
| Retention | 0.25 | How well knowledge sticks |
| Applicability | 0.15 | How applicable to real work |

### Knowledge Connection Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Strength | 0.40 | How strong the connection is |
| Bidirectionality | 0.30 | Whether benefit flows both ways |
| Novelty | 0.20 | How unique this connection is |
| Validation Level | 0.10 | How well validated |

---

## Pruning Strategies

### Strategy 1: Exercise Lifecycle

```
New Exercise → Practice (3+ attempts) → Evaluated →
  ├─ High Learning Value: Active Exercise → Monitor monthly
  ├─ Medium Learning Value: Optional → Review quarterly
  ├─ Low Learning Value: Deprecated → Archive after 30 days
  └─ Redundant: Merged → Keep reference, remove duplicate
```

### Strategy 2: Knowledge Decay Management

```
Mastered Topic → Monitoring →
  ├─ Regular Access: Maintain Mastery → Continue tracking
  ├─ No Access (within threshold): Schedule Review → Generate exercise
  ├─ No Access (beyond threshold): Decay → Reduce mastery score
  └─ No Access (full decay): Archive → Preserve for relearning
```

### Strategy 3: Connection Lifecycle

```
New Connection → Validation →
  ├─ Strong Connection: Permanent → Monitor annually
  ├─ Medium Connection: Active → Review quarterly
  ├─ Weak Connection: Candidate → Further validation
  └─ Invalid Connection: Removed → Archive
```

### Strategy 4: Coverage Maintenance

- **Core topics**: 100% coverage target, monthly review
- **Advanced topics**: 80% coverage target, quarterly review
- **Specialized topics**: 60% coverage target, semi-annual review
- **Emerging topics**: 40% coverage target, continuous update

---

## Merge Algorithms

### Algorithm 1: Topic Consolidation

**Input**: Multiple exercises covering same topic
**Process**:
1. Compare learning objectives of exercises
2. Identify overlapping content
3. Create comprehensive topic module
4. Store exercises as sub-modules
5. Validate comprehensive module effectiveness

### Algorithm 2: Knowledge Graph Optimization

**Input**: Full knowledge graph
**Process**:
1. Identify redundant connections
2. Strengthen weak but valuable connections
3. Prune invalid connections
4. Add missing connections
5. Optimize graph traversal for learning recommendations

### Algorithm 3: Learning Path Consolidation

**Input**: Multiple learning paths for same objective
**Process**:
1. Compare path effectiveness
2. Identify common successful segments
3. Create optimized composite path
4. Store path variations for different contexts
5. Validate composite path efficiency

### Algorithm 4: Exercise Deduplication

**Input**: Multiple exercises with overlapping content
**Process**:
1. Compute exercise similarity
2. For exercises with similarity > 0.7: merge
3. Create comprehensive exercise from merged content
4. Store specific variations as context branches
5. Validate merged exercise learning value

---

## Scheduling

### Consolidation Cycles

| Cycle | Frequency | Scope | Duration |
|-------|-----------|-------|----------|
| Mastery Check | Per learning session | Single topic | < 1 second |
| Connection Validation | Per connection discovery | Single connection | < 1 second |
| Decay Monitoring | Daily | All mastered topics | < 30 seconds |
| Exercise Assessment | Weekly | All active exercises | < 2 minutes |
| Knowledge Graph Audit | Monthly | Full knowledge graph | < 5 minutes |
| Coverage Review | Quarterly | Full knowledge base | < 10 minutes |

### Daily Decay Monitoring

1. Check all mastered topics for decay threshold
2. Generate maintenance recommendations
3. Schedule spaced repetition reviews
4. Update mastery scores
5. Generate daily decay report

### Monthly Knowledge Graph Audit

1. Full graph traversal
2. Identify orphaned connections
3. Strengthen valuable connections
4. Add missing connections
5. Generate graph health report

---

## Metrics and Monitoring

### Learning Health Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Mastery Rate | > 70% of active topics | < 50% |
| Decay Rate | < 20% of mastered topics | > 40% |
| Connection Density | > 3 connections per topic | < 1.5 |
| Coverage Breadth | > 80% of required topics | < 60% |
| Exercise Efficiency | > 0.7 learning per hour | < 0.4 |

### Knowledge Quality Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Mastery Stability | Maintenance of mastery over time | > 80% retention |
| Connection Accuracy | Percentage of valid connections | > 90% |
| Learning Transfer | Application of knowledge to new contexts | > 60% |
| Knowledge Freshness | Percentage of up-to-date knowledge | > 80% |

---

## Cross-Domain References

### Primary Dependencies

| Domain | Relationship | Data Flow |
|--------|-------------|-----------|
| `core-prompts-hunting` | Learning enhances hunting capability | Mastery → hunting effectiveness |
| `advanced-automation` | Learning improves automation design | Knowledge → automation quality |
| `advanced-chaining-techniques` | Learning enables complex chain development | Mastery → chain sophistication |
| `report-writing-mastery` | Learning improves report quality | Knowledge → report depth |

### Secondary Dependencies

| Domain | Relationship | Impact |
|--------|-------------|--------|
| `bug-bounty-support` | Learning informs support methodology | Framework improvement |
| `real-world-case-studies` | Cases provide learning material | Exercise generation |
| `reconnaissance-deep-dive` | Learning enhances recon skill | Recon mastery |
| `specialized-targets` | Learning builds target expertise | Target mastery |

---

## Learning Progress Tracking System

### Mastery Level Definitions

| Level | Score Range | Description | Maintenance |
|-------|-------------|-------------|-------------|
| Novice | 0.0-0.2 | Just started learning | Daily practice |
| Beginner | 0.2-0.4 | Basic understanding | 3x weekly |
| Intermediate | 0.4-0.6 | Can apply with guidance | 2x weekly |
| Advanced | 0.6-0.8 | Independent application | Weekly |
| Expert | 0.8-0.95 | Can teach others | Bi-weekly |
| Master | 0.95-1.0 | Innovative application | Monthly |

### Spaced Repetition Schedule

| Mastery Level | Review Interval | Review Duration |
|--------------|----------------|-----------------|
| Novice | 1 day | 30 minutes |
| Beginner | 3 days | 20 minutes |
| Intermediate | 7 days | 15 minutes |
| Advanced | 14 days | 10 minutes |
| Expert | 30 days | 5 minutes |
| Master | 60 days | 5 minutes |

### Learning Velocity Metrics

| Metric | Calculation | Target |
|--------|-------------|--------|
| Topics per Week | New topics mastered / weeks | > 2 |
| Retention Rate | Review success / total reviews | > 85% |
| Transfer Rate | Application success in new context | > 60% |
| Connection Density | Connections per topic | > 3 |

---

## Knowledge Graph Structure

### Node Types

| Node Type | Description | Properties |
|-----------|-------------|------------|
| Topic | Learning topic | name, category, mastery_level |
| Concept | Abstract concept | name, definition, examples |
| Skill | Practical skill | name, proficiency, applications |
| Resource | Learning resource | type, quality, relevance |
| Exercise | Practice activity | type, difficulty, effectiveness |

### Edge Types

| Edge Type | Description | Weight Range |
|-----------|-------------|-------------|
| prerequisite | Must know before | 0-1 |
| related | Conceptually related | 0-1 |
| enhances | Improves understanding of | 0-1 |
| applies_to | Practical application | 0-1 |
| conflicts_with | Incompatible knowledge | 0-1 |

### Graph Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Connectivity | Average edges per node | > 3 |
| Clustering | Community structure | > 0.4 |
| Diameter | Longest shortest path | < 6 |
| Orphan Rate | Nodes with no edges | < 5% |

---

## Exercise Effectiveness Analysis

### Exercise Types and Effectiveness

| Exercise Type | Learning Value | Time Investment | Best For |
|--------------|---------------|-----------------|----------|
| Hands-on lab | Very High | High | Practical skills |
| CTF challenge | High | Medium | Problem solving |
| Code review | High | Medium | Pattern recognition |
| Report writing | Medium | Medium | Communication |
| Flashcards | Medium | Low | Memorization |
| Teaching | Very High | High | Deep understanding |

### Exercise Selection Algorithm

```
available_time = get_available_time()
current_gaps = identify_knowledge_gaps()
candidate_exercises = filter_by_gaps(all_exercises, current_gaps)
ranked = sort_by(candidate_exercises, effectiveness / time_cost, desc)
selected = greedy_select(ranked, available_time)
return selected
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-26 | Initial consolidation framework for Core Prompts - Learning domain |
| 1.1.0 | 2026-06-26 | Added progress tracking, knowledge graph structure, and exercise analysis |

---

## Learning Session Templates

### 30-Minute Session

| Phase | Duration | Activity |
|-------|----------|----------|
| Warm-up | 5 min | Review previous session notes |
| Focus | 20 min | Core learning activity |
| Review | 5 min | Summarize key takeaways |

### 60-Minute Session

| Phase | Duration | Activity |
|-------|----------|----------|
| Warm-up | 5 min | Review spaced repetition cards |
| Theory | 15 min | Read/study new concepts |
| Practice | 30 min | Hands-on exercise |
| Review | 10 min | Document learnings, plan next |

### Weekly Review Session

| Phase | Duration | Activity |
|-------|----------|----------|
| Progress check | 10 min | Review mastery scores |
| Gap analysis | 15 min | Identify weak areas |
| Planning | 10 min | Set next week goals |
| Review | 5 min | Update learning path |
