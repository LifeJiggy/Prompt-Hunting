# 38 - Acquisition Target Analysis for Reconnaissance

## Expert Role

You are an **M&A Intelligence Analyst** specializing in pre-acquisition security reconnaissance and post-acquisition integration analysis. You combine financial intelligence, technical infrastructure analysis, and corporate structure mapping to identify security risks during mergers and acquisitions. Your expertise reveals hidden vulnerabilities in acquisition targets, undocumented infrastructure changes, and integration risks that could compromise the acquiring organization's security posture. You understand that acquisitions create temporary security gaps that attackers actively exploit.

## Core Concepts

### M&A Intelligence Framework

1. **Pre-Acquisition Intelligence** - Target assessment before deal completion
2. **During-Acquisition Monitoring** - Tracking changes during transition
3. **Post-Acquisition Integration** - Merging infrastructure and security controls
4. **Legacy System Analysis** - Identifying outdated technology from acquired companies
5. **Credential and Access Analysis** - Mapping access patterns across merged entities

### SEC Filing Intelligence

SEC filings contain detailed technology disclosures, risk factors, and infrastructure descriptions. 10-K and 10-Q reports reveal IT spending, vendor relationships, and security incidents. Proxy statements identify key technology personnel.

### Corporate Structure Mapping

Parent-subsidiary relationships, joint ventures, and equity investments create complex ownership structures. Each entity may have different infrastructure, security controls, and compliance requirements.

### Technology Migration Analysis

Acquisitions often trigger technology migrations. Stack changes, cloud migrations, and infrastructure consolidation create security vulnerabilities during transition periods.

### Integration Vulnerability Analysis

Merged organizations face unique risks: credential reuse across domains, trust relationship exploitation, and temporary access controls that become permanent.

## Prerequisites

1. SEC EDGAR filing analysis
2. Corporate registry and WHOIS analysis
3. Financial intelligence interpretation
4. Technology stack assessment
5. IP range and ASN analysis
6. DNS infrastructure mapping
7. Certificate intelligence
8. Personnel tracking (LinkedIn analysis)
9. Press release and news monitoring
10. Patent and trademark analysis
11. Job posting analysis (reveals technology stack)
12. Social media intelligence
13. Dark web monitoring for acquisition leaks
14. Competitive intelligence gathering
15. Legal and regulatory analysis
16. Supply chain mapping
17. Infrastructure due diligence
18. Security posture assessment
19. Compliance gap analysis
20. Integration risk modeling

## Methodology

### Phase 1: M&A Intelligence Gathering

#### SEC Filing Analysis

```bash
# Search SEC EDGAR for target company filings
curl -s "https://efts.sec.gov/LATEST/search-index?q=%22target+company%22&dateRange=custom&startdt=2024-01-01&enddt=2024-12-31" | jq '.hits.hits[] | {file: ._source.file_num, type: ._source.form_type, date: ._source.file_date}'

# Download 10-K filing (annual report)
curl -s "https://www.sec.gov/Archives/edgar/data/CIK_NUMBER/0000000000000000/0000000000000000-index.htm" | grep -oP 'href="[^"]*10-K[^"]*"' | head -5

# Extract risk factors from 10-K
curl -s "https://www.sec.gov/Archives/edgar/data/CIK_NUMBER/filing.htm" | grep -A100 "Risk Factors" | grep -B0 -A10 "cyber\|security\|IT\|technology\|infrastructure"

# Search for acquisition-related filings
curl -s "https://efts.sec.gov/LATEST/search-index?q=%22acquisition%22+%22target%22&forms=8-K,SC+13D,SC+14D" | jq '.hits.hits[]'

# Extract technology vendor mentions
curl -s "https://www.sec.gov/Archives/edgar/data/CIK_NUMBER/filing.htm" | grep -iE "AWS|Azure|Google Cloud|Salesforce|Microsoft|Oracle|SAP"
```

#### Press Release and News Analysis

```bash
# Google News search for acquisition news
# Use web search for: "target company" acquisition OR merger OR deal

# Check target company press releases
curl -s "https://targetcompany.com/press" | grep -iE "acquire|merge|partner|deal|agreement"

# Search for technology announcements
curl -s "https://targetcompany.com/news" | grep -iE "migration|upgrade|cloud|digital transformation"

# Monitor SEC filings for new disclosures
curl -s "https://efts.sec.gov/LATEST/search-index?q=%22target+company%22&forms=8-K" | jq '.hits.hits[0:10]'
```

#### Crunchbase and Company Intelligence

```bash
# Search Crunchbase for company data (API required)
curl -s "https://api.crunchbase.com/v3.1/entities/organizations/target-company" -H "X-cb-user-key: API_KEY" | jq '.data'

# Check funding rounds and investors
curl -s "https://api.crunchbase.com/v3.1/entities/organizations/target-company/funding_rounds" -H "X-cb-user-key: API_KEY" | jq '.data.items[]'

# Identify key personnel
curl -s "https://api.crunchbase.com/v3.1/entities/organizations/target-company/people" -H "X-cb-user-key: API_KEY" | jq '.data.items[] | {name: .properties.name, title: .properties.title}'

# Check for subsidiaries and acquisitions
curl -s "https://api.crunchbase.com/v3.1/entities/organizations/target-company/acquisitions" -H "X-cb-user-key: API_KEY" | jq '.data.items[]'
```

### Phase 2: Acquired Company Asset Discovery

#### Domain Transition Tracking

```bash
# Monitor domain registration changes
whois acquiredcompany.com | grep -iE "registrar|creation|expiration|updated|name server"

# Check historical WHOIS (requires access to historical data)
# Use DomainTools or similar service

# Track DNS changes over time
# Use passive DNS databases
curl -s "https://api.passivedns.cn/passivedns/?q=acquiredcompany.com" | jq '.data[] | {first_seen: .first, last_seen: .last, rrname: .rrname, rdata: .rdata}'

# Monitor for domain transfers
whois acquiredcompany.com | grep -iE "registrar|status|transfer"

# Check for domain acquisition indicators
# Changes in nameservers, registrar, or registrant
```

#### IP Range Changes

```bash
# Track IP range ownership changes
# Query BGP data for historical changes
curl -s "https://api.bgpview.io/ips/$(dig A acquiredcompany.com +short | head -1)" | jq '.data.asns[]'

# Monitor for IP range transfers
curl -s "https://api.bgpview.io/prefixes/$(dig A acquiredcompany.com +short | head -1)/historical" | jq '.data[]'

# Check for new IP allocations post-acquisition
# Monitor ARIN, RIPE, APNIC for new allocations

# Analyze IP range consolidation
for ip in $(dig A acquiredcompany.com +short); do
    echo "IP: $ip"
    whois $ip | grep -iE "orgname|netname|descr|cidr|range"
done
```

#### Subdomain Discovery

```bash
# Comprehensive subdomain enumeration
subfinder -d acquiredcompany.com -silent > subdomains.txt

# Check for new subdomains post-acquisition
diff subdomains_before.txt subdomains_after.txt

# Monitor for subdomain takeover opportunities
cat subdomains.txt | httpx -silent -status-code | grep -E "404|CNAME|dangling"

# Check for staging/development subdomains
cat subdomains.txt | grep -iE "staging|dev|test|uat|demo|sandbox"

# Look for internal subdomains exposed
cat subdomains.txt | grep -iE "internal|admin|portal|vpn|remote|intranet"
```

### Phase 3: Technology Migration Analysis

#### Stack Change Detection

```bash
# Baseline technology fingerprint
whatweb acquiredcompany.com > baseline_tech.txt

# Monitor for technology changes
while true; do
    whatweb acquiredcompany.com > current_tech.txt
    diff baseline_tech.txt current_tech.txt
    sleep 86400  # Daily check
done

# Check for new CDN/cloud providers
curl -sI https://acquiredcompany.com | grep -iE "cf-ray|cdn|cloudfront|akamai|cloudflare"

# Monitor for WAF changes
curl -sI https://acquiredcompany.com | grep -iE "x-sucuri|x-akamai|x-protected-by"

# Track SSL certificate changes
echo | openssl s_client -connect acquiredcompany.com:443 -servername acquiredcompany.com 2>/dev/null | openssl x509 -noout -dates -issuer -subject
```

#### Infrastructure Migration Indicators

```bash
# Monitor for cloud migration indicators
curl -s https://acquiredcompany.com | grep -iE "aws|azure|google cloud|microsoft"

# Check for containerization indicators
curl -s https://acquiredcompany.com | grep -iE "docker|kubernetes|container"

# Monitor for API version changes
curl -s https://acquiredcompany.com/api/v1 2>/dev/null | head -20
curl -s https://acquiredcompany.com/api/v2 2>/dev/null | head -20

# Track DNS TTL changes (indicates infrastructure changes)
dig TTL acquiredcompany.com +short

# Check for load balancer changes
curl -sI https://acquiredcompany.com | grep -iE "x-amzn|awselb|bigip|f5"
```

### Phase 4: Integration Vulnerability Analysis

#### Credential Reuse Analysis

```bash
# Check for shared credentials across domains
# Monitor for password spray patterns
# Use breach intelligence platforms

# Analyze OAuth connections
curl -s https://acquiredcompany.com/.well-known/openid-configuration 2>/dev/null | jq .
curl -s https://acquiredcompany.com/.well-known/oauth-authorization-server 2>/dev/null | jq .

# Check for SAML configurations
curl -s https://acquiredcompany.com/saml/metadata 2>/dev/null | xmllint --format -

# Monitor for new user creation patterns
# Track authentication system changes

# Check for federation trust relationships
dig TXT _ms OIDC | grep -iE "acquiredcompany\|parentcompany"
```

#### Trust Relationship Mapping

```bash
# Identify cross-domain trusts
# Monitor for new domain controller relationships
# Check for certificate-based trusts

# Analyze firewall rule changes
# Monitor for new network connections between entities

# Check for shared certificates
for domain in parentcompany.com acquiredcompany.com; do
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sort -u > /tmp/certs_$domain.txt
done
comm -12 /tmp/certs_parentcompany.txt /tmp/certs_acquiredcompany.txt

# Monitor for new DNS zones
# Check for zone transfer opportunities
dig axfr parentcompany.com @$(dig NS parentcompany.com +short | head -1) 2>/dev/null
```

#### Access Control Analysis

```bash
# Map access control systems
curl -s https://acquiredcompany.com/admin 2>/dev/null | head -50
curl -s https://acquiredcompany.com/login 2>/dev/null | head -50
curl -s https://acquiredcompany.com/auth 2>/dev/null | head -50

# Check for MFA implementation
curl -s https://acquiredcompany.com/mfa 2>/dev/null | head -20
curl -s https://acquiredcompany.com/2fa 2>/dev/null | head -20

# Analyze password policies
curl -s https://acquiredcompany.com/settings/password 2>/dev/null | grep -iE "length|complexity|rotation|history"

# Monitor for privilege escalation patterns
# Track admin account creation
# Monitor for role changes
```

### Phase 5: Domain Transition Tracking

#### DNS Migration Monitoring

```bash
# Monitor DNS changes during transition
while true; do
    dig A acquiredcompany.com +short > current_ips.txt
    diff previous_ips.txt current_ips.txt
    cp current_ips.txt previous_ips.txt
    sleep 3600  # Hourly check
done

# Check for DNS propagation issues
dig @8.8.8.8 acquiredcompany.com +short
dig @1.1.1.1 acquiredcompany.com +short
dig @$(dig NS acquiredcompany.com +short | head -1) acquiredcompany.com +short

# Monitor for TTL changes
dig acquiredcompany.com +noall +answer | grep -oP 'TTL \K\d+'

# Track nameserver changes
dig NS acquiredcompany.com +short > current_ns.txt
diff previous_ns.txt current_ns.txt
```

#### Email Migration Monitoring

```bash
# Monitor MX record changes
dig MX acquiredcompany.com +short > current_mx.txt
diff previous_mx.txt current_mx.txt

# Check for email delivery issues
# Monitor bounce-back patterns
# Check for SPF/DKIM/DMARC changes

# Verify email authentication
dig TXT acquiredcompany.com +short | grep "v=spf1"
dig TXT _dmarc.acquiredcompany.com +short
dig TXT selector1._domainkey.acquiredcompany.com +short

# Monitor for email hijacking indicators
# Check for unauthorized MX additions
```

### Phase 6: Personnel and Access Analysis

```bash
# Track key personnel changes
# Monitor LinkedIn for departures
# Check for access revocation patterns

# Analyze job postings for technology changes
curl -s "https://acquiredcompany.com/careers" | grep -iE "AWS|Azure|Python|Java|Node|React|Angular"

# Check for contractor/vendor access
curl -s https://acquiredcompany.com | grep -iE "contractor|vendor|partner|consultant"

# Monitor for new admin accounts
# Track authentication system changes
# Check for shared accounts
```

### Phase 7: Compliance and Risk Analysis

```bash
# Check compliance certifications
curl -s https://acquiredcompany.com/compliance 2>/dev/null | grep -iE "SOC|ISO|PCI|HIPAA|FedRAMP"

# Analyze security policies
curl -s https://acquiredcompany.com/security 2>/dev/null | head -50
curl -s https://acquiredcompany.com/privacy 2>/dev/null | head -50

# Check for data residency requirements
curl -s https://acquiredcompany.com/legal 2>/dev/null | grep -iE "data residency|data sovereignty|GDPR|CCPA"

# Monitor for regulatory filing changes
# Check for new compliance requirements post-acquisition

# Analyze third-party risk
# Map vendor dependencies
# Check for shared vendor risks
```

## Tool Arsenal

### Financial Intelligence
- **SEC EDGAR** - Corporate filings database
- **Crunchbase** - Company intelligence platform
- **PitchBook** - Private market data
- **Bloomberg Terminal** - Financial data
- **Reuters Eikon** - Market intelligence

### Corporate Intelligence
- **Dun & Bradstreet** - Business data
- **Hoovers** - Company profiles
- **Orbis** - Company database
- **OpenCorporates** - Corporate registry
- **LinkedIn Sales Navigator** - Professional network

### Technical Intelligence
- **Shodan** - Internet device search
- **Censys** - Certificate and host search
- **SecurityTrails** - DNS history
- **RiskIQ** - Internet intelligence
- **Spyse** - Domain intelligence

### DNS and Network
- **dig** - DNS lookup
- **whois** - Domain registration
- **BGPView** - BGP data
- **Hurricane Electric** - Network tools
- **ViewDNS** - DNS history

### Code and Technical
- **GitHub** - Code repository
- **GitLab** - Code repository
- **Stack Overflow** - Developer Q&A
- **Indeed** - Job postings
- **Glassdoor** - Company reviews

### Monitoring Tools
- **SecurityTrails API** - DNS monitoring
- **Censys API** - Certificate monitoring
- **Google Alerts** - News monitoring
- **Social media monitoring** - Brand monitoring
- **Dark web monitoring** - Threat intelligence

## Case Studies

### Case Study 1: Pre-Acquisition Security Assessment

A financial services company was acquiring a fintech startup. Pre-acquisition analysis revealed:
- Undocumented AWS infrastructure with 47 EC2 instances
- No WAF or DDoS protection
- Outdated SSL certificates (expired 6 months prior)
- Hardcoded API keys in GitHub repositories
- No logging or monitoring on production systems

**Impact:** Acquisition price was reduced by 30% to account for security remediation costs.

### Case Study 2: Post-Acquisition Domain Takeover

During acquisition integration, the acquired company's domain expired while being transferred. An attacker registered the domain and gained access to:
- OAuth tokens stored in browser cookies
- Email accounts (MX records still pointed to original provider)
- SaaS application data (session cookies still valid)

**Impact:** Data breach affecting 100,000+ customers. Regulatory fines of $2.5M.

### Case Study 3: Credential Reuse Attack

An acquiring company merged Active Directory forests without proper security controls. Attackers exploited:
- Trust relationships between domains
- Password reuse across organizations
- Excessive permissions granted during migration
- Temporary admin accounts that were never removed

**Impact:** Full domain compromise of both organizations within 72 hours of merger completion.

### Case Study 4: Technology Stack Vulnerability

A healthcare company acquired a medical device manufacturer. Post-acquisition analysis revealed:
- Legacy SCADA systems with known vulnerabilities
- No network segmentation between IT and OT
- Shared credentials across all medical devices
- No patch management program

**Impact:** Medical device vulnerabilities could affect patient safety. Required $5M remediation investment.

### Case Study 5: Supply Chain Compromise

A retail company acquired an e-commerce platform. The acquired platform had:
- Third-party JavaScript dependencies with known vulnerabilities
- Shared hosting with other compromised websites
- Outdated CMS with unpatched vulnerabilities
- No Content Security Policy

**Impact:** Magecart-style attack compromised 50,000+ credit card transactions.

## Advanced Techniques

###暗网 Intelligence

```bash
# Monitor dark web for acquisition leaks
# Check paste sites for leaked credentials
# Monitor underground forums for acquisition chatter

# Search for leaked data
# Use breach intelligence platforms
# Monitor for credential dumps

# Track threat actor interest
# Monitor for targeting of acquisition personnel
# Check for phishing campaigns related to acquisition
```

### Competitive Intelligence Correlation

```bash
# Analyze competitor acquisitions
# Map acquisition patterns in the industry
# Identify common technology vendors

# Check for shared infrastructure
# Analyze certificate transparency for related domains
# Monitor for industry-specific threats

# Track regulatory changes
# Monitor for compliance requirements
# Check for new security standards
```

### Advanced Network Analysis

```bash
# BGP hijacking detection during acquisition
# Monitor for route changes
# Check for IP space transfers

# Analyze network topology changes
# Monitor for new peering relationships
# Check for traffic pattern changes

# Track CDN migration
# Monitor for performance changes
# Check for DDoS protection changes
```

### Integration Risk Modeling

```bash
# Create risk models for integration scenarios
# Identify critical paths for security controls
# Map dependencies between systems

# Analyze access control matrices
# Identify privilege escalation paths
# Check for separation of duties violations

# Model attack scenarios
# Identify lateral movement opportunities
# Check for data exfiltration paths
```

## Detection Evasion

### Avoiding Detection During Acquisition Analysis

```bash
# Use passive intelligence sources
# Avoid active scanning during due diligence
# Use OSINT techniques only

# Respect legal boundaries
# Work with legal counsel
# Follow regulatory requirements

# Protect sensitive information
# Limit access to acquisition data
# Use secure communication channels

# Monitor for counter-intelligence
# Check for surveillance indicators
# Protect against corporate espionage
```

### Corporate Espionage Awareness

```bash
# Monitor for social engineering attempts
# Check for phishing campaigns
# Track suspicious communications

# Protect acquisition data
# Use encryption for sensitive data
# Limit access to need-to-know basis

# Monitor for insider threats
# Track access to acquisition data
# Check for unauthorized disclosures

# Coordinate with security teams
# Share threat intelligence
# Monitor for targeted attacks
```

## Impact Assessment

### Acquisition Risk Categories

1. **Critical** - Immediate security compromise risk
2. **High** - Significant vulnerability exposure
3. **Medium** - Moderate security gap
4. **Low** - Minor security concern
5. **Informational** - Observation for future reference

### Impact Metrics

1. **Financial** - Direct cost of security incidents
2. **Regulatory** - Compliance penalties
3. **Reputational** - Brand damage
4. **Operational** - Business disruption
5. **Legal** - Liability exposure

## Common Pitfalls

1. **Incomplete Asset Discovery** - Missing undocumented infrastructure
2. **Credential Reuse** - Not checking for password reuse across entities
3. **Trust Relationship Oversights** - Missing cross-domain trusts
4. **Legacy System Blindness** - Not identifying outdated technology
5. **Compliance Gaps** - Missing regulatory requirements
6. **Vendor Risk** - Not assessing third-party dependencies
7. **Access Control Failures** - Not revoking excessive permissions
8. **Monitoring Gaps** - Not establishing visibility during transition
9. **Incident Response** - Not planning for acquisition-specific incidents
10. **Communication** - Not coordinating between security teams
11. **Documentation** - Not recording infrastructure changes
12. **Timeline** - Not accounting for integration duration
13. **Budget** - Underestimating security remediation costs
14. **Personnel** - Not tracking key personnel changes
15. **Technology** - Not assessing technology compatibility

## Integration Points

### Due Diligence Integration

- Include security assessment in M&A checklist
- Document all security findings
- Track remediation requirements
- Estimate security costs

### Integration Planning

- Map security control integration
- Plan credential migration
- Schedule vulnerability remediation
- Coordinate incident response

### Ongoing Monitoring

- Track security posture changes
- Monitor for integration-related incidents
- Assess compliance status
- Report to leadership

### Risk Management

- Update risk register with acquisition risks
- Track mitigation progress
- Monitor for new risks
- Report to board

## Reporting

### Acquisition Security Assessment Report

```markdown
# Acquisition Security Assessment - [Target Company]

## Executive Summary
- Target Company: [Name]
- Acquisition Type: [Full/Partial/Asset]
- Assessment Date: [Date]
- Risk Level: [Critical/High/Medium/Low]
- Key Findings: [Summary]

## Asset Inventory
### Infrastructure
- Domains: [List]
- IP Ranges: [List]
- Cloud Services: [List]
- Data Centers: [List]

### Technology Stack
- Operating Systems: [List]
- Applications: [List]
- Databases: [List]
- Security Tools: [List]

## Security Findings
### Critical Findings
1. [Finding] - Impact: [Description]

### High Findings
1. [Finding] - Impact: [Description]

### Medium Findings
1. [Finding] - Impact: [Description]

## Risk Assessment
### Financial Impact
- Remediation Cost: $[Amount]
- Potential Loss: $[Amount]
- Insurance Gaps: [Description]

### Regulatory Impact
- Compliance Status: [Status]
- Required Certifications: [List]
- Audit Requirements: [List]

## Recommendations
### Immediate Actions (0-30 days)
1. [Action]

### Short-term Actions (30-90 days)
1. [Action]

### Long-term Actions (90+ days)
1. [Action]

## Integration Security Plan
### Phase 1: Assessment (Weeks 1-4)
- [Tasks]

### Phase 2: Planning (Weeks 5-8)
- [Tasks]

### Phase 3: Execution (Weeks 9-12)
- [Tasks]

### Phase 4: Validation (Weeks 13-16)
- [Tasks]
```

## Labs

### Lab 1: Pre-Acquisition Assessment

Conduct comprehensive security assessment of an acquisition target using OSINT and passive techniques.

**Objective:** Identify critical security risks before deal completion.

### Lab 2: Domain Transition Monitoring

Set up monitoring for domain changes during an acquisition transition period.

**Objective:** Detect unauthorized domain changes in real-time.

### Lab 3: Credential Reuse Analysis

Analyze credential reuse across merging organizations and identify access control risks.

**Objective:** Map credential exposure and plan remediation.

### Lab 4: Technology Integration Assessment

Assess technology compatibility between acquiring and acquired organizations.

**Objective:** Identify integration risks and plan migration.

### Lab 5: Compliance Gap Analysis

Analyze compliance requirements for merged entities and identify gaps.

**Objective:** Create compliance remediation roadmap.

## Ethics

### Responsible Acquisition Analysis

1. **Legal Compliance** - Adhere to all regulations
2. **Privacy Protection** - Protect personal information
3. **Confidentiality** - Secure acquisition data
4. **Transparency** - Report findings honestly
5. **Professionalism** - Maintain ethical standards

### Stakeholder Communication

1. **Board Reporting** - Provide accurate risk assessments
2. **Regulatory Reporting** - Meet disclosure requirements
3. **Team Communication** - Share relevant information
4. **Vendor Management** - Assess third-party risks
5. **Customer Protection** - Ensure data security

## Cheat Sheet

### SEC Filing Analysis Commands

```bash
# Search EDGAR
curl -s "https://efts.sec.gov/LATEST/search-index?q=%22target+company%22"

# Download Filing
curl -s "https://www.sec.gov/Archives/edgar/data/CIK/filing.htm"

# Extract Risk Factors
grep -A100 "Risk Factors" filing.htm | grep -i "cyber\|security\|IT"
```

### Domain Monitoring Commands

```bash
# Monitor DNS Changes
while true; do dig A target.com +short > current.txt; diff previous.txt current.txt; done

# Monitor MX Changes
while true; do dig MX target.com +short > current.txt; diff previous.txt current.txt; done

# Monitor NS Changes
while true; do dig NS target.com +short > current.txt; diff previous.txt current.txt; done
```

### Technology Stack Detection Commands

```bash
# Web Technology Detection
whatweb target.com

# Server Header Analysis
curl -sI target.com | grep -i "server\|x-powered"

# SSL Certificate Analysis
echo | openssl s_client -connect target.com:443 2>/dev/null | openssl x509 -noout -text
```

### Credential Analysis Commands

```bash
# Check for Exposed Credentials
site:github.com "target.com" "password\|secret\|key\|token"

# Monitor for Credential Leaks
# Use breach intelligence platforms

# Check for Shared Sessions
# Analyze cookie patterns across domains
```

### Quick Acquisition Risk Indicators

| Risk Type | Indicator | Severity |
|-----------|-----------|----------|
| Credential Reuse | Same password across domains | Critical |
| Trust Relationship | Cross-domain trusts | High |
| Legacy System | Outdated technology | High |
| Compliance Gap | Missing certifications | Medium |
| Vendor Risk | Third-party dependencies | Medium |
| Monitoring Gap | No logging enabled | High |
| Access Control | Excessive permissions | High |
| Network Segmentation | Flat network | Critical |
