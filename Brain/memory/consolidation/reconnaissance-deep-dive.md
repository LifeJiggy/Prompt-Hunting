# MEMORY CONSOLIDATION: Reconnaissance Deep Dive Domain

## Domain Identity

- **Domain Name**: Reconnaissance Deep Dive
- **Domain Path**: `Reconnaissance-Deep-Dive/`
- **File Count**: 50 content files + README.md + registry.json
- **Domain Purpose**: Advanced subdomain enumeration, passive/active recon, technology fingerprinting, cloud resource discovery, API endpoint discovery, source code analysis, and comprehensive asset mapping
- **Consolidation Model**: Asset Verification via Active Confirmation, Dead Host Pruning, Duplicate Discovery Merging

---

## Consolidation Overview

This document defines how memory consolidation operates for the Reconnaissance Deep Dive domain. Reconnaissance is the foundation of all security testing — it builds the asset inventory that drives all subsequent activity. Consolidation must track which assets are alive, which discoveries are duplicates, and which recon techniques yield the best results for different target types.

The consolidation pipeline handles five entity types: **Verified Assets** (confirmed alive and accessible), **Dead Hosts** (confirmed offline or decommissioned), **Technology Fingerprints** (identified technologies and frameworks), **API Endpoints** (discovered API surfaces), and **Source Code Artifacts** (extracted code intelligence).

---

## Domain File References

### Subdomain & Asset Discovery Files

| File | Recon Category | Consolidation Priority |
|------|---------------|----------------------|
| `01-Advanced-Subdomain-Enumeration.md` | Subdomain discovery | CRITICAL — asset core |
| `02-Passive-OSINT-Collection.md` | Passive recon | HIGH — passive intel |
| `03-Active-Asset-Discovery.md` | Active discovery | HIGH — active recon |
| `04-Technology-Stack-Fingerprinting.md` | Tech fingerprinting | HIGH — tech intel |
| `05-Cloud-Resource-Enumeration.md` | Cloud asset discovery | HIGH — cloud recon |
| `06-API-Endpoint-Discovery.md` | API endpoint discovery | HIGH — API recon |
| `07-JavaScript-Source-Analysis.md` | JS source analysis | HIGH — code intel |
| `08-Configuration-File-Extraction.md` | Config extraction | MEDIUM — config intel |
| `09-Version-Detection-Techniques.md` | Version detection | MEDIUM — version intel |
| `10-Content-Discovery-Automation.md` | Content discovery | HIGH — content recon |

### Directory & File Discovery Files

| File | Recon Category | Consolidation Priority |
|------|---------------|----------------------|
| `11-Directory-Brute-Forcing.md` | Directory discovery | MEDIUM — dir recon |
| `12-File-Type-Detection.md` | File type detection | MEDIUM — file recon |
| `13-Backup-File-Discovery.md` | Backup file discovery | HIGH — backup recon |
| `14-Source-Code-Leak-Detection.md` | Source code leaks | HIGH — code leaks |
| `15-Git-Repository-Analysis.md` | Git repo analysis | HIGH — git recon |
| `16-DNS-Enumeration-Advanced.md` | Advanced DNS enum | HIGH — DNS recon |
| `17-Certificate-Transparency-Logs.md` | CT log analysis | HIGH — cert recon |
| `18-Historical-Data-Analysis.md` | Historical analysis | MEDIUM — history intel |
| `19-Social-Media-OSINT.md` | Social media OSINT | MEDIUM — social recon |
| `20-Employee-Linked-Assets.md` | Employee asset mapping | MEDIUM — people recon |

### Integration & Supply Chain Files

| File | Recon Category | Consolidation Priority |
|------|---------------|----------------------|
| `21-Third-Party-Integration-Discovery.md` | Third-party discovery | HIGH — integration recon |
| `22-Web-Archive-Analysis.md` | Web archive analysis | MEDIUM — archive recon |
| `23-Pastebin-and-Leak-Searching.md` | Leak searching | HIGH — leak recon |
| `24-Code-Repository-Mining.md` | Code repo mining | HIGH — code recon |
| `25-Container-Registry-Enumeration.md` | Container registry recon | HIGH — container recon |
| `26-IoT-Device-Discovery.md` | IoT device discovery | MEDIUM — IoT recon |
| `27-Mobile-App-Analysis.md` | Mobile app analysis | MEDIUM — mobile recon |
| `28-API-Documentation-Extraction.md` | API doc extraction | HIGH — API intel |
| `29-WebSocket-Endpoint-Discovery.md` | WebSocket discovery | MEDIUM — WS recon |
| `30-GraphQL-Introspection.md` | GraphQL introspection | HIGH — GraphQL recon |

### Protocol & Communication Files

| File | Recon Category | Consolidation Priority |
|------|---------------|----------------------|
| `31-XML-RPC-and-SOAP-Discovery.md` | XML-RPC/SOAP discovery | MEDIUM — protocol recon |
| `32-Email-Address-Harvesting.md` | Email harvesting | MEDIUM — email recon |
| `33-Phone-Number-Enumeration.md` | Phone enumeration | LOW — phone recon |
| `34-Physical-Location-Intelligence.md` | Physical location intel | LOW — physical recon |
| `35-Supply-Chain-Asset-Mapping.md` | Supply chain mapping | HIGH — supply chain |
| `36-Competitor-Analysis.md` | Competitor analysis | LOW — competitive |
| `37-Partner-Network-Discovery.md` | Partner network discovery | MEDIUM — partner recon |
| `38-Acquisition-Target-Analysis.md` | Acquisition analysis | LOW — M&A recon |
| `39-Subsidiary-Asset-Mapping.md` | Subsidiary mapping | MEDIUM — org recon |
| `40-Regional-Infrastructure-Mapping.md` | Regional infra mapping | MEDIUM — geo recon |

### CMS & Framework Files

| File | Recon Category | Consolidation Priority |
|------|---------------|----------------------|
| `41-Content-Management-System-Detection.md` | CMS detection | HIGH — CMS recon |
| `42-Framework-and-Library-Identification.md` | Framework identification | HIGH — framework recon |
| `43-Server-Configuration-Analysis.md` | Server config analysis | MEDIUM — server recon |
| `44-SSL-TLS-Certificate-Analysis.md` | SSL/TLS analysis | HIGH — cert recon |
| `45-HTTP-Header-Intelligence.md` | Header intelligence | MEDIUM — header recon |
| `46-Cookie-Analysis-and-Session-Management.md` | Cookie/session analysis | MEDIUM — session recon |
| `47-Error-Page-Analysis.md` | Error page analysis | MEDIUM — error recon |
| `48-Debug-Endpoint-Discovery.md` | Debug endpoint discovery | HIGH — debug recon |
| `49-Staging-Environment-Detection.md` | Staging environment detection | HIGH — staging recon |
| `50-Advanced-Reconnaissance-Strategy.md` | Master recon framework | CRITICAL — recon core |

---

## Consolidation Rules

### Rule RD-01: Asset Verification

**Trigger**: An asset is confirmed alive through active probing.

**Condition**: `asset_alive == true AND verification_method == "active" AND response_received == true`

**Action**:
1. Extract asset metadata: IP, hostname, technology, status, response characteristics
2. Generate asset fingerprint: `SHA256(hostname + IP + technology_stack_hash)`
3. Store in verified asset library
4. Calculate asset importance score
5. Link to discovery source

### Rule RD-02: Dead Host Pruning

**Trigger**: An asset is confirmed dead or unreachable.

**Condition**: `asset_dead == true AND verification_attempts >= 3 AND verification_period >= 7_days`

**Action**:
1. Mark asset as "dead" in library
2. Set TTL based on asset type:
   - Cloud instance: 30 days (may restart)
   - Static server: 90 days (may be temporary)
   - Domain: 180 days (DNS may change)
3. Preserve asset metadata for historical reference
4. Update asset inventory statistics
5. Generate dead host report

### Rule RD-03: Duplicate Discovery Merging

**Trigger**: Multiple discoveries reference the same asset.

**Condition**: `asset_overlap >= 0.9 OR hostname_match == true AND IP_match == true`

**Action**:
1. Compare asset characteristics
2. Identify which discovery has most complete data
3. Merge discoveries into unified asset profile
4. Preserve discovery sources as references
5. Update asset completeness score

### Rule RD-04: Technology Fingerprint Promotion

**Trigger**: A technology is confirmed through multiple detection methods.

**Condition**: `tech_detected_by >= 2_methods AND tech_confidence >= 0.8`

**Action**:
1. Record technology with confidence score
2. Link to asset profile
3. Calculate technology coverage for target
4. Generate technology-based attack recommendations
5. Update technology library

### Rule RD-05: API Endpoint Cataloging

**Trigger**: An API endpoint is discovered and characterized.

**Condition**: `endpoint_discovered == true AND endpoint_characterized == true`

**Action**:
1. Record endpoint: URL, method, parameters, authentication, response type
2. Generate endpoint fingerprint
3. Store in API catalog
4. Link to asset profile
5. Update API coverage metrics

### Rule RD-06: Source Code Intelligence Extraction

**Trigger**: Source code artifacts are extracted from a target.

**Condition**: `code_extracted == true AND code_analyzed == true`

**Action**:
1. Extract intelligence: hardcoded secrets, API keys, internal URLs, comments
2. Generate code intelligence fingerprint
3. Store in code intelligence library
4. Link to source asset
5. Update code intelligence metrics

### Rule RD-07: Recon Technique Effectiveness Tracking

**Trigger**: A recon technique is applied and yields results.

**Condition**: `technique_applied == true AND results_yielded == true`

**Action**:
1. Record technique application with results
2. Calculate technique effectiveness: `results_count / time_invested`
3. Update technique library
4. Generate technique recommendations
5. Update recon strategy

### Rule RD-08: Historical Data Integration

**Trigger**: Historical data (Wayback, CT logs, etc.) is analyzed.

**Condition**: `historical_data_analyzed == true AND new_assets_found >= 1`

**Action**:
1. Extract historical assets and endpoints
2. Cross-reference with current assets
3. Identify changes and trends
4. Update historical intelligence
5. Generate historical insights

---

## Importance Scoring System

### Asset Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Accessibility | 0.30 | How accessible the asset is |
| Technology Richness | 0.25 | How many technologies identified |
| Endpoint Count | 0.20 | Number of endpoints discovered |
| Information Value | 0.15 | How much intelligence extracted |
| Recency | 0.10 | Time since last verification |

### Technology Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Coverage | 0.30 | Percentage of target using this tech |
| Vulnerability Potential | 0.25 | Known vulnerability likelihood |
| Detection Confidence | 0.25 | How confident in detection |
| Uniqueness | 0.20 | How common this tech is |

### Recon Technique Score

| Component | Weight | Description |
|-----------|--------|-------------|
| Yield Rate | 0.35 | Results per application |
| Uniqueness | 0.25 | Results not found by other techniques |
| Efficiency | 0.25 | Results per time unit |
| Reliability | 0.15 | Consistency of results |

---

## Pruning Strategies

### Strategy 1: Asset Lifecycle

```
Discovered → Verified → Active →
  ├─ Confirmed: Regular verification → Maintain
  ├─ Unreachable: Dead check → Prune after TTL
  ├─ Decommissioned: Confirmed dead → Archive
  └─ Out of Scope: Scope change → Archive
```

### Strategy 2: Technology Retention

| Technology Status | Retention | Update Frequency |
|------------------|-----------|------------------|
| Active on target | Permanent | Per scan |
| Recently removed | 90 days | Monthly |
| Deprecated | 180 days | Quarterly |
| Historical only | 365 days | Annual |

### Strategy 3: Recon Result Retention

| Result Type | Retention | Detail Level |
|-------------|-----------|-------------|
| Verified assets | Permanent | Full |
| Historical assets | 365 days | Summary |
| Dead hosts | 90 days | Brief |
| Failed discoveries | 30 days | Minimal |

### Strategy 4: API Catalog Maintenance

- **Active endpoints**: Updated continuously, full detail
- **Deprecated endpoints**: Retained 90 days, marked deprecated
- **Internal endpoints**: Retained, access restricted
- **Third-party endpoints**: Retained with third-party reference

---

## Merge Algorithms

### Algorithm 1: Asset Deduplication

**Input**: Multiple asset discoveries
**Process**:
1. Compare asset fingerprints
2. For assets with similarity > 0.9: merge
3. Create unified asset profile from merged data
4. Preserve discovery sources
5. Update asset inventory

### Algorithm 2: Technology Consolidation

**Input**: Multiple technology detections for same asset
**Process**:
1. Compare technology detection results
2. Resolve conflicts (most recent, highest confidence)
3. Create unified technology profile
4. Link to asset
5. Update technology coverage metrics

### Algorithm 3: Endpoint Catalog Deduplication

**Input**: Multiple API endpoint discoveries
**Process**:
1. Compare endpoint fingerprints
2. For endpoints with similarity > 0.95: merge
3. Create unified endpoint profile
4. Preserve discovery sources
5. Update API catalog

### Algorithm 4: Recon Strategy Optimization

**Input**: Multiple recon technique results
**Process**:
1. Analyze technique effectiveness
2. Identify complementary techniques
3. Create optimized recon strategy
4. Store technique组合
5. Validate strategy effectiveness

---

## Scheduling

### Consolidation Cycles

| Cycle | Frequency | Scope | Duration |
|-------|-----------|-------|----------|
| Asset Verification | Per probe | Single asset | < 1 second |
| Discovery Processing | Per scan completion | Scan results | < 5 seconds |
| Asset Deduplication | Every 2 hours | All new discoveries | < 10 seconds |
| Dead Host Check | Daily | All assets > 7 days old | < 1 minute |
| Technology Update | Daily | All verified assets | < 30 seconds |
| Full Recon Audit | Weekly | Complete recon library | < 5 minutes |

### Daily Dead Host Verification

1. Select assets older than 7 days
2. Probe for liveness
3. Update asset status
4. Prune confirmed dead hosts
5. Generate dead host report

### Weekly Recon Audit

1. Full asset inventory review
2. Technology coverage assessment
3. API catalog completeness check
4. Recon technique effectiveness review
5. Generate recon health report

---

## Metrics and Monitoring

### Recon Health Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Asset Verification Rate | > 90% assets verified | < 75% |
| Dead Host Rate | < 15% of assets | > 30% |
| Duplicate Discovery Rate | < 10% | > 25% |
| Technology Coverage | > 80% target tech identified | < 60% |
| API Endpoint Coverage | > 70% endpoints discovered | < 50% |

### Recon Quality Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Recon Completeness | Percentage of target surface covered | > 85% |
| Recon Accuracy | Percentage of discoveries valid | > 90% |
| Recon Efficiency | Discoveries per hour of recon | Track trend |
| Recon Freshness | Percentage of assets verified in 30 days | > 80% |

---

## Cross-Domain References

### Primary Dependencies

| Domain | Relationship | Data Flow |
|--------|-------------|-----------|
| `advanced-automation` | Recon feeds automation targets | Verified assets → scan targets |
| `core-prompts-hunting` | Recon identifies hunting targets | Asset intel → hunting priorities |
| `bug-bounty-program-strategy` | Recon informs program selection | Asset scope → program fit |
| `specialized-targets` | Recon builds target profiles | Asset data → target intel |

### Secondary Dependencies

| Domain | Relationship | Impact |
|--------|-------------|--------|
| `advanced-chaining-techniques` | Recon identifies chain entry points | Entry point data |
| `report-writing-mastery` | Recon data informs reports | Asset context |
| `real-world-case-studies` | Cases inform recon priorities | Recon focus |
| `bug-bounty-support` | Recon methodology guides automation | Recon frameworks |

---

## Reconnaissance Pipeline Architecture

### Pipeline Stages

```
Seed Discovery →
  ├─ Subdomain Enumeration → DNS Resolution →
  │   └─ Live Host Discovery → Port Scanning →
  │       └─ Service Identification → Technology Fingerprinting →
  │           └─ Endpoint Discovery → Content Analysis →
  │               └─ Vulnerability Surface Mapping → Target Prioritization
  └─ Parallel Tracks:
      ├─ OSINT Collection → Personnel Mapping
      ├─ Certificate Transparency → Subdomain Discovery
      ├─ Code Repository Mining → Secret Discovery
      └─ Historical Data → Endpoint Archaeology
```

### Pipeline Configuration

| Stage | Tool | Timeout | Parallelism |
|-------|------|---------|-------------|
| Subdomain Enum | subfinder, amass | 5 min | 3 concurrent |
| DNS Resolution | dnsx | 2 min | 10 concurrent |
| Live Host | httpx | 10 min | 50 concurrent |
| Port Scan | nmap, masscan | 15 min | 1 concurrent |
| Service ID | nmap scripts | 10 min | Per-host |
| Tech Fingerprint | whatweb, wappalyzer | 5 min | 20 concurrent |
| Endpoint Discovery | katana, gau | 20 min | 5 concurrent |
| Content Analysis | custom | 30 min | 10 concurrent |

### Pipeline Error Handling

| Error Type | Recovery | Max Retries |
|-----------|----------|-------------|
| DNS timeout | Retry with alternate resolver | 3 |
| Connection refused | Skip host, log | 0 |
| Rate limit | Backoff and retry | 5 |
| Tool crash | Restart tool, continue | 2 |
| Data corruption | Re-run stage | 1 |

---

## Asset Scoring Model

### Asset Importance Score

```
asset_importance = access_level * 0.3
                 + technology_richness * 0.25
                 + endpoint_count * 0.2
                 + information_value * 0.15
                 + recency * 0.1
```

### Asset Classification Tiers

| Tier | Score Range | Description | Priority |
|------|-------------|-------------|----------|
| Critical | 0.8-1.0 | Core application, admin panels | Immediate |
| High | 0.6-0.79 | Main services, API endpoints | High |
| Medium | 0.4-0.59 | Supporting services | Medium |
| Low | 0.2-0.39 | Static content, docs | Low |
| Informational | 0.0-0.19 | Minimal attack surface | Background |

### Asset Relationship Mapping

| Relationship | Description | Intelligence Value |
|-------------|-------------|-------------------|
| Parent-child | Subdomain relationships | Scope definition |
| Service dependency | Services that depend on each other | Attack chain potential |
| Data flow | Data movement between assets | Impact assessment |
| Authentication flow | Auth relationships | Session handling analysis |

---

## Technology Stack Intelligence

### Detection Methods

| Method | Accuracy | Speed | Coverage |
|--------|----------|-------|----------|
| HTTP headers | High | Fast | Limited |
| HTML source | High | Fast | Good |
| JavaScript analysis | Medium | Medium | Good |
| Cookie patterns | Medium | Fast | Limited |
| Error pages | Medium | Fast | Limited |
| Default files | Low | Fast | Limited |

### Technology Risk Assessment

| Technology | Common Vulns | Detection Confidence | Risk Level |
|-----------|-------------|---------------------|------------|
| WordPress | Plugin vulns, XSS | Very High | High |
| Apache Struts | RCE, deserialization | High | Critical |
| Jenkins | Auth bypass, RCE | High | Critical |
| Spring Boot | Actuator, SSTI | High | High |
| Django | Template injection | Medium | Medium |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-26 | Initial consolidation framework for Reconnaissance Deep Dive domain |
| 1.1.0 | 2026-06-26 | Added pipeline architecture, asset scoring model, and technology intelligence |

---

## Reconnaissance Output Formats

### Asset Report Structure

| Section | Content | Priority |
|---------|---------|----------|
| Executive Summary | High-level findings | Critical |
| Asset Inventory | Complete asset list | High |
| Technology Map | Stack identification | High |
| Endpoint Catalog | API and web endpoints | High |
| Risk Assessment | Prioritized findings | Critical |
| Recommendations | Next steps | High |

### Continuous Monitoring Configuration

| Monitor Type | Check Frequency | Alert Condition |
|-------------|----------------|-----------------|
| New subdomain | Daily | Any new discovery |
| Certificate change | Hourly | New certificate issued |
| Technology change | Daily | Stack modification |
| Endpoint change | Daily | New or removed endpoint |
| Status change | Hourly | Host goes offline |
