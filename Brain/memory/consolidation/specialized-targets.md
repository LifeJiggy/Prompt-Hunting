# MEMORY CONSOLIDATION: Specialized Targets Domain

## Domain Identity

- **Domain Name**: Specialized Targets
- **Domain Path**: `Specialized-Targets/`
- **File Count**: 50 content files + README.md + registry.json
- **Domain Purpose**: IoT device security, mobile application testing, cloud infrastructure, container/K8s security, blockchain/DeFi, healthcare/finance/government systems, industrial control systems, and specialized platform expertise
- **Consolidation Model**: Category Knowledge Promotion, Irrelevant Data Pruning, Cross-Category Insight Merging

---

## Consolidation Overview

This document defines how memory consolidation operates for the Specialized Targets domain. Specialized targets require domain-specific knowledge that doesn't apply broadly — IoT protocols, mobile app architectures, cloud service models, blockchain smart contracts, industrial control systems, and regulated industry requirements. Consolidation must track category-specific expertise while pruning data that doesn't apply to the current target scope.

The consolidation pipeline handles five entity types: **Category Knowledge** (target-type-specific expertise), **Platform Profiles** (specific platform intelligence), **Regulatory Requirements** (compliance constraints), **Attack Surface Maps** (target-type attack surfaces), and **Defense Patterns** (target-type defensive measures).

---

## Domain File References

### IoT & Embedded Systems Files

| File | Target Category | Consolidation Priority |
|------|----------------|----------------------|
| `01-IoT-Device-Security.md` | IoT device testing | HIGH — IoT core |
| `02-Mobile-Application-Testing.md` | Mobile app testing | HIGH — mobile core |
| `03-Cloud-Infrastructure-Security.md` | Cloud infrastructure | HIGH — cloud core |
| `04-Container-Security.md` | Container security | HIGH — container core |
| `05-Kubernetes-Cluster-Security.md` | Kubernetes security | HIGH — K8s core |
| `06-Blockchain-Smart-Contracts.md` | Blockchain smart contracts | MEDIUM — blockchain |
| `07-DeFi-Protocol-Security.md` | DeFi protocol security | MEDIUM — DeFi |
| `08-NFT-Marketplace-Security.md` | NFT marketplace security | LOW — NFT |
| `09-Web3-Application-Security.md` | Web3 app security | MEDIUM — Web3 |
| `10-Cryptocurrency-Exchange-Security.md` | Crypto exchange security | MEDIUM — exchange |

### Financial & Industry Files

| File | Target Category | Consolidation Priority |
|------|----------------|----------------------|
| `11-Traditional-Finance-API-Security.md` | TradFi API security | MEDIUM — finance |
| `12-Healthcare-System-Security.md` | Healthcare system security | HIGH — healthcare |
| `13-Financial-Institution-Security.md` | Financial institution security | HIGH — finance |
| `14-Government-System-Security.md` | Government system security | HIGH — government |
| `15-Education-Platform-Security.md` | Education platform security | MEDIUM — education |
| `16-E-commerce-Platform-Security.md` | E-commerce platform security | HIGH — e-commerce |
| `17-Social-Media-Platform-Security.md` | Social media platform security | HIGH — social |
| `18-Content-Management-System-Security.md` | CMS security | HIGH — CMS |
| `19-Learning-Management-System-Security.md` | LMS security | MEDIUM — LMS |
| `20-Human-Resources-System-Security.md` | HR system security | MEDIUM — HR |

### Supply Chain & Manufacturing Files

| File | Target Category | Consolidation Priority |
|------|----------------|----------------------|
| `21-Supply-Chain-Management-Security.md` | Supply chain security | HIGH — supply chain |
| `22-Manufacturing-Control-System-Security.md` | Manufacturing control security | MEDIUM — manufacturing |
| `23-Smart-Building-Automation.md` | Smart building security | MEDIUM — building |
| `24-Connected-Vehicle-Security.md` | Connected vehicle security | MEDIUM — vehicle |
| `25-Autonomous-System-Security.md` | Autonomous system security | MEDIUM — autonomous |

### Industrial & Infrastructure Files

| File | Target Category | Consolidation Priority |
|------|----------------|----------------------|
| `26-Industrial-Control-System-Security.md` | ICS security | HIGH — ICS |
| `27-Medical-Device-Security.md` | Medical device security | HIGH — medical |
| `28-Wearable-Technology-Security.md` | Wearable tech security | LOW — wearable |
| `29-Smart-Home-Device-Security.md` | Smart home security | MEDIUM — smart home |
| `30-Embedded-System-Security.md` | Embedded system security | HIGH — embedded |
| `31-Real-Time-Operating-System-Security.md` | RTOS security | MEDIUM — RTOS |
| `32-Firmware-Security-Analysis.md` | Firmware security | HIGH — firmware |
| `33-Network-Device-Security.md` | Network device security | HIGH — network |
| `34-Telecommunication-System-Security.md` | Telecom security | MEDIUM — telecom |
| `35-Satellite-Communication-Security.md` | Satellite comm security | LOW — satellite |

### Critical Infrastructure Files

| File | Target Category | Consolidation Priority |
|------|----------------|----------------------|
| `36-Air-Traffic-Control-System-Security.md` | ATC security | HIGH — ATC |
| `37-Power-Grid-Security.md` | Power grid security | HIGH — power grid |
| `38-Water-Treatment-Facility-Security.md` | Water treatment security | HIGH — water |
| `39-Transportation-System-Security.md` | Transportation security | MEDIUM — transport |
| `40-Energy-Management-System-Security.md` | Energy management security | MEDIUM — energy |

### Organizational Scale Files

| File | Target Category | Consolidation Priority |
|------|----------------|----------------------|
| `41-Research-Institution-Security.md` | Research institution security | MEDIUM — research |
| `42-Non-Profit-Organization-Security.md` | Non-profit security | LOW — non-profit |
| `43-Startup-Company-Security.md` | Startup security | MEDIUM — startup |
| `44-Enterprise-Corporate-Security.md` | Enterprise security | HIGH — enterprise |
| `45-Fortune-500-Company-Security.md` | Fortune 500 security | HIGH — enterprise |
| `46-Open-Source-Project-Security.md` | Open source security | MEDIUM — open source |
| `47-Academic-Research-Security.md` | Academic security | MEDIUM — academic |
| `48-International-Organization-Security.md` | International org security | MEDIUM — international |
| `49-Developing-Country-Infrastructure.md` | Developing country infra | LOW — developing |
| `50-Global-Scale-System-Security.md` | Global scale security | HIGH — global |

---

## Consolidation Rules

### Rule ST-01: Category Knowledge Promotion

**Trigger**: Category-specific expertise is validated through successful application.

**Condition**: `category_expertise_applied >= 3_times AND success_rate >= 0.7`

**Action**:
1. Extract category knowledge: protocols, tools, techniques, constraints
2. Calculate knowledge effectiveness score
3. Store in category knowledge library
4. Link to successful outcomes
5. Update category expertise profile

**Category Knowledge Score**:
```
knowledge = success_rate * 0.35
          + applicability_breadth * 0.25
          + depth_of_knowledge * 0.25
          + recency * 0.15
```

### Rule ST-02: Irrelevant Data Pruning

**Trigger**: Category-specific data doesn't apply to current scope.

**Condition**: `scope_mismatch == true OR relevance_score < 0.3`

**Action**:
1. Mark data as out-of-scope
2. Move to category archive
3. Preserve for future reference
4. Update category coverage metrics
5. Generate scope-appropriate recommendations

### Rule ST-03: Cross-Category Insight Merging

**Trigger**: Insights from one category apply to another.

**Condition**: `cross_category_insight == true AND insight_validated == true`

**Action**:
1. Record cross-category insight
2. Calculate insight transferability score
3. Store in cross-category library
4. Link to applicable categories
5. Update cross-category correlation index

### Rule ST-04: Platform Profile Promotion

**Trigger**: A platform-specific profile is validated.

**Condition**: `platform_profile_validated == true AND profile_accuracy >= 0.8`

**Action**:
1. Extract platform profile: architecture, protocols, known vulnerabilities
2. Calculate profile completeness score
3. Store in platform library
4. Link to category knowledge
5. Update platform risk assessment

### Rule ST-05: Regulatory Requirement Tracking

**Trigger**: Regulatory requirements are identified for a category.

**Condition**: `regulatory_requirement_identified == true AND requirement_source == authoritative`

**Action**:
1. Record regulatory requirement
2. Link to applicable category
3. Update compliance checklist
4. Generate compliance recommendations
5. Track compliance status

### Rule ST-06: Attack Surface Mapping

**Trigger**: An attack surface map is validated for a category.

**Condition**: `attack_surface_validated == true AND surface_coverage >= 0.7`

**Action**:
1. Record attack surface: components, protocols, entry points
2. Calculate surface completeness score
3. Store in attack surface library
4. Link to category knowledge
5. Update attack surface recommendations

### Rule ST-07: Defense Pattern Tracking

**Trigger**: Defensive measures are validated for a category.

**Condition**: `defense_validated == true AND defense_effectiveness >= 0.6`

**Action**:
1. Record defense pattern: measure, implementation, effectiveness
2. Calculate defense effectiveness score
3. Store in defense library
4. Link to applicable attack patterns
5. Update defense recommendations

### Rule ST-08: Category Expertise Decay Detection

**Trigger**: Category expertise hasn't been applied recently.

**Condition**: `days_since_last_application > decay_threshold`

**Action**:
1. Calculate expertise decay factor
2. Reduce expertise score
3. If score drops below 0.5: flag for review
4. Generate maintenance recommendations
5. Update expertise statistics

---

## Importance Scoring System

### Category Knowledge Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Application Success | 0.35 | Success rate when applied |
| Category Relevance | 0.25 | How relevant to current targets |
| Knowledge Depth | 0.25 | How comprehensive the knowledge is |
| Recency | 0.15 | Time since last validation |

### Platform Profile Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Completeness | 0.35 | How complete the profile is |
| Accuracy | 0.25 | How accurate the profile is |
| Freshness | 0.25 | How recently updated |
| Uniqueness | 0.15 | How unique this platform is |

### Attack Surface Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Coverage | 0.35 | How much surface is mapped |
| Accuracy | 0.25 | How accurate the mapping is |
| Vulnerability Potential | 0.25 | Likelihood of finding vulns |
| Accessibility | 0.15 | How accessible the surface is |

---

## Pruning Strategies

### Strategy 1: Category Knowledge Lifecycle

```
New Category → Learning (3+ applications) → Validated →
  ├─ High Effectiveness: Active Knowledge → Monitor quarterly
  ├─ Medium Effectiveness: Candidate → Further application
  ├─ Low Effectiveness: Deprecated → Archive after 90 days
  └─ Irrelevant: Out of Scope → Immediate archive
```

### Strategy 2: Platform Profile Retention

| Platform Status | Retention | Update Frequency |
|----------------|-----------|------------------|
| Active platform | Permanent | Monthly |
| Legacy platform | 365 days | Quarterly |
| Deprecated platform | 180 days | Semi-annual |
| Emerging platform | Permanent | Weekly |

### Strategy 3: Regulatory Requirement Retention

- **Active requirements**: Permanent, updated as regulations change
- **Superseded requirements**: 365 days, marked superseded
- **Upcoming requirements**: Permanent, marked upcoming
- **Jurisdiction-specific**: Retained per jurisdiction

### Strategy 4: Cross-Category Insight Retention

- **Validated insights**: Permanent, monitored for applicability
- **Unvalidated insights**: 90 days, pending validation
- **Disproven insights**: Archive with disproof note
- **Context-specific insights**: Retained with context tags

---

## Merge Algorithms

### Algorithm 1: Category Knowledge Consolidation

**Input**: Multiple knowledge entries for same category
**Process**:
1. Compare knowledge components
2. Identify overlapping knowledge
3. Create comprehensive category knowledge base
4. Store specific applications as case studies
5. Validate consolidated knowledge effectiveness

### Algorithm 2: Platform Profile Merging

**Input**: Multiple platform profiles for related platforms
Process:
1. Compare platform architectures
2. Identify common components
3. Create base platform template
4. Store platform-specific variations
5. Validate merged profile accuracy

### Algorithm 3: Attack Surface Merging

**Input**: Multiple attack surface maps for same category
Process:
1. Compare surface components
2. Identify overlapping surfaces
3. Create comprehensive surface map
4. Store category-specific variations
5. Validate merged surface completeness

### Algorithm 4: Cross-Category Insight Consolidation

**Input**: Multiple cross-category insights
Process:
1. Compare insight applicability
2. Identify common transfer patterns
3. Create cross-category insight library
4. Store insight-specific contexts
5. Validate insight transferability

---

## Scheduling

### Consolidation Cycles

| Cycle | Frequency | Scope | Duration |
|-------|-----------|-------|----------|
| Knowledge Application | Per use | Single knowledge entry | < 1 second |
| Platform Assessment | Per platform encounter | Single platform | < 5 seconds |
| Category Review | Weekly | All active categories | < 2 minutes |
| Platform Profile Update | Monthly | All active profiles | < 5 minutes |
| Regulatory Check | Quarterly | All regulatory requirements | < 10 minutes |
| Cross-Category Audit | Semi-annually | Full cross-category library | < 15 minutes |

### Weekly Category Review

1. Assess all active category knowledge
2. Identify underperforming knowledge
3. Promote successful new knowledge
4. Archive deprecated knowledge
5. Generate category health report

### Quarterly Regulatory Check

1. Review all regulatory requirements
2. Update for regulation changes
3. Verify compliance status
4. Generate compliance report
5. Update compliance recommendations

---

## Metrics and Monitoring

### Specialized Target Health Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Category Coverage | > 80% target categories covered | < 60% |
| Platform Profile Accuracy | > 85% | < 70% |
| Cross-Category Insight Rate | > 30% insights transfer | < 15% |
| Knowledge Application Rate | > 70% knowledge applied in 90 days | < 50% |
| Regulatory Compliance | > 95% compliance | < 85% |

### Knowledge Quality Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Knowledge Depth | Comprehensiveness of category knowledge | > 80% |
| Knowledge Accuracy | Percentage of accurate information | > 90% |
| Knowledge Freshness | Percentage of up-to-date knowledge | > 85% |
| Knowledge Transferability | Percentage applicable cross-category | > 40% |

---

## Cross-Domain References

### Primary Dependencies

| Domain | Relationship | Data Flow |
|--------|-------------|-----------|
| `core-prompts-hunting` | Category knowledge informs hunting | Target expertise → hunting |
| `advanced-automation` | Category knowledge guides automation | Platform info → automation |
| `reconnaissance-deep-dive` | Recon builds target profiles | Asset data → target profiles |
| `advanced-chaining-Techniques` | Category knowledge informs chains | Target info → chain development |

### Secondary Dependencies

| Domain | Relationship | Impact |
|--------|-------------|--------|
| `real-world-case-studies` | Cases inform category expertise | Validation data |
| `report-writing-mastery` | Category knowledge informs reports | Target-specific reports |
| `bug-bounty-program-strategy` | Strategy identifies target opportunities | Target selection |
| `high-level-world-case-studies` | Cases inform category defense | Defense patterns |

---

## Target Category Attack Surface Mapping

### IoT Device Attack Surface

| Component | Attack Vector | Difficulty | Impact |
|-----------|--------------|------------|--------|
| Web interface | XSS, CSRF, auth bypass | Medium | High |
| MQTT broker | Auth bypass, injection | Medium | Critical |
| CoAP endpoint | DDoS, info disclosure | Low | Medium |
| Firmware | Extraction, modification | High | Critical |
| Hardware interfaces | JTAG, UART access | High | Critical |
| Mobile app | Insecure storage, MITM | Medium | High |
| Cloud API | IDOR, auth bypass | Medium | High |

### Mobile Application Attack Surface

| Component | Attack Vector | Difficulty | Impact |
|-----------|--------------|------------|--------|
| API endpoints | IDOR, injection, auth bypass | Medium | High |
| Local storage | Insecure data storage | Low | High |
| Deep links | URL scheme hijacking | Medium | Medium |
| Binary | Reverse engineering, tampering | High | Critical |
| Network | MITM, certificate pinning bypass | Medium | High |
| WebView | JavaScript injection | Medium | High |
| Push notifications | Notification hijacking | Low | Low |

### Cloud Infrastructure Attack Surface

| Component | Attack Vector | Difficulty | Impact |
|-----------|--------------|------------|--------|
| IAM policies | Privilege escalation, misconfig | Medium | Critical |
| Storage buckets | Public access, misconfig | Low | Critical |
| Serverless functions | Injection, event injection | Medium | High |
| Containers | Escape, resource abuse | High | Critical |
| Kubernetes | RBAC bypass, secret theft | High | Critical |
| CI/CD pipelines | Secret leakage, injection | Medium | Critical |

### Blockchain/DeFi Attack Surface

| Component | Attack Vector | Difficulty | Impact |
|-----------|--------------|------------|--------|
| Smart contracts | Reentrancy, overflow, access control | High | Critical |
| Oracle manipulation | Price feed manipulation | High | Critical |
| Flash loans | Economic attack | High | Critical |
| Governance | Voting manipulation | Medium | High |
| Frontend | XSS, DNS hijacking | Medium | High |
| Private keys | Key management flaws | High | Critical |

---

## Regulatory Compliance Framework

### Healthcare (HIPAA)

| Requirement | Description | Testing Approach |
|-------------|-------------|-----------------|
| Access controls | Role-based access | IDOR testing |
| Audit controls | Activity logging | Log manipulation |
| Integrity controls | Data integrity | Data modification |
| Transmission security | Encryption in transit | MITM testing |
| Authentication | Strong authentication | Auth bypass testing |

### Financial (PCI DSS)

| Requirement | Description | Testing Approach |
|-------------|-------------|-----------------|
| Network segmentation | Isolated cardholder data | Network discovery |
| Access control | Need-to-know access | Privilege testing |
| Encryption | Card data encryption | Crypto analysis |
| Vulnerability management | Regular scanning | Vuln assessment |
| Logging and monitoring | Activity tracking | Log review |

### Government (FISMA)

| Requirement | Description | Testing Approach |
|-------------|-------------|-----------------|
| Access control | Least privilege | Privilege testing |
| Audit logging | Comprehensive logging | Log manipulation |
| Configuration management | Baseline configs | Config analysis |
| Incident response | Response procedures | IR testing |
| Risk assessment | Risk identification | Risk analysis |

---

## Cross-Category Knowledge Transfer

### Transfer Patterns

| From Category | To Category | Transferable Knowledge |
|--------------|-------------|----------------------|
| Web application | API security | Input validation, auth patterns |
| Cloud infrastructure | Container security | IAM, network security |
| Mobile application | IoT security | API security, local storage |
| Network security | Cloud security | Segmentation, monitoring |
| Cryptography | Blockchain security | Key management, signatures |

### Transfer Effectiveness Matrix

| Source → Target | Knowledge Transfer Rate | Adaptation Required |
|----------------|------------------------|-------------------|
| Web → API | 80% | Minimal |
| Cloud → Container | 70% | Medium |
| Mobile → IoT | 60% | High |
| Network → Cloud | 65% | Medium |
| Crypto → Blockchain | 75% | Low-Medium |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-26 | Initial consolidation framework for Specialized Targets domain |
| 1.1.0 | 2026-06-26 | Added attack surface mapping, regulatory compliance, and cross-category knowledge transfer |

---

## Target Assessment Checklist

### Pre-Assessment Verification

1. Confirm target is in-scope
2. Review program rules and restrictions
3. Identify applicable regulatory requirements
4. Assess target category-specific risks
5. Configure category-specific tooling

### Assessment Documentation

| Document | Purpose | When to Update |
|----------|---------|---------------|
| Target profile | Asset inventory | Per discovery |
| Attack surface map | Visual representation | Weekly |
| Finding tracker | All discovered issues | Per finding |
| Risk register | Prioritized risks | Per assessment |
| Compliance checklist | Regulatory status | Monthly |
