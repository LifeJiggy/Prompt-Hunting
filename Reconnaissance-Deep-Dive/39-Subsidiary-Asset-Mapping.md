# 39 - Subsidiary Asset Mapping and Enumeration

## Expert Role

You are a **Corporate Structure Intelligence Analyst** specializing in mapping organizational hierarchies through technical infrastructure. You combine WHOIS analysis, BGP data, ASN lookup, and corporate registry mining to uncover parent-subsidiary relationships. Your expertise reveals hidden subsidiaries, cross-ownership structures, and shared infrastructure that create extended attack surfaces. You understand that subsidiaries often have weaker security controls while maintaining trust relationships with parent organizations.

## Core Concepts

### Corporate Structure Taxonomy

1. **Wholly-Owned Subsidiaries** - 100% ownership by parent
2. **Majority-Owned Subsidiaries** - >50% ownership
3. **Minority Investments** - <50% ownership but strategic relationship
4. **Joint Ventures** - Shared ownership with third parties
5. **Shell Companies** - Entity used for tax or liability purposes
6. **Holding Companies** - Entity that owns other entities
7. **Franchise Operations** - Licensed business operations

### WHOIS Intelligence

WHOIS records reveal registrant organizations, email addresses, and physical addresses. Corporate email domains in WHOIS indicate parent company ownership. Registrant organization names reveal corporate hierarchy.

### BGP and ASN Analysis

Autonomous System Numbers (ASN) reveal network ownership and peering relationships. BGP prefix announcements show IP range allocations. ASN organization data maps corporate network infrastructure.

### Corporate Registry Mining

Business registries (SEC, Companies House, ASIC, etc.) contain ownership data, director information, and financial records. These registries reveal legal corporate structures.

### Cross-Subsidiary Trust

Subsidiaries often maintain trust relationships with parent organizations through:
- Active Directory trusts
- Shared identity providers
- Common certificate authorities
- Network peering arrangements
- Shared cloud accounts

## Prerequisites

1. WHOIS analysis techniques
2. BGP and ASN data interpretation
3. Corporate registry knowledge
4. DNS infrastructure understanding
5. IP range ownership analysis
6. Certificate intelligence
7. OSINT for corporate research
8. Financial filing analysis
9. LinkedIn and personnel analysis
10. Patent and trademark analysis
11. Supply chain mapping
12. Cloud infrastructure analysis
13. Network architecture understanding
14. Security assessment methodologies
15. Risk assessment frameworks
16. Legal entity structure knowledge
17. Tax and compliance understanding
18. Cross-border regulatory analysis
19. International business structures
20. Corporate governance principles

## Methodology

### Phase 1: Subsidiary Domain Discovery

#### WHOIS Analysis

```bash
# Comprehensive WHOIS lookup
whois parentcompany.com | grep -iE "registrant|admin|tech|billing|name server|creation|expiration"

# Extract registrant organization
whois parentcompany.com | grep -iE "Registrant Organization:" | head -1

# Extract registrant email domain
whois parentcompany.com | grep -iE "Registrant Email:" | grep -oP '@\K[^>]+'

# Check for registrant changes over time
whois parentcompany.com | grep -iE "Updated Date:|Creation Date:|Expiration Date:"

# Compare WHOIS across multiple domains
for domain in $(cat domains.txt); do
    echo "=== $domain ==="
    whois $domain | grep -iE "Registrant Organization:|Registrant Email:|Name Server:"
done

# Identify common registrant patterns
for domain in $(cat domains.txt); do
    org=$(whois $domain | grep -i "Registrant Organization:" | head -1 | awk -F: '{print $2}' | xargs)
    email=$(whois $domain | grep -i "Registrant Email:" | head -1 | awk -F: '{print $2}' | xargs)
    echo "$domain|$org|$email"
done
```

#### Domain Pattern Discovery

```bash
# Common subsidiary domain patterns
# parentcompany-subsidiary.com
# subsidiary.parentcompany.com
# subsidiaryname.com
# subsidiaryname.co.uk (country-specific)

# Search for domains with similar registrant
# Use domain intelligence platforms

# Check for domain variations
for subsidiary in subsidiary1 subsidiary2 subsidiary3; do
    for tld in com net org co.uk co nz au ca; do
        whois ${subsidiary}.${tld} 2>/dev/null | grep -i "Registrant Organization:" && echo "${subsidiary}.${tld} exists"
    done
done

# Check for domain variations with parent name
for tld in com net org; do
    whois parentcompany-${subsidiary}.${tld} 2>/dev/null | grep -i "Registrant Organization:" && echo "parentcompany-${subsidiary}.${tld} exists"
done

# Reverse WHOIS lookup (find all domains by same registrant)
# Use DomainTools or similar service
```

#### DNS-Based Subsidiary Discovery

```bash
# Check for shared nameservers
for domain in $(cat domains.txt); do
    echo "$domain: $(dig NS $domain +short | sort | tr '\n' ',')"
done

# Identify domains sharing nameservers
# Group domains by nameserver patterns

# Check for DNS zone transfers
for ns in $(dig NS parentcompany.com +short | sed 's/\.$//'); do
    echo "=== $ns ==="
    dig axfr parentcompany.com @$ns 2>/dev/null | head -50
done

# Look for subdomain delegation
for subsidiary in subsidiary1 subsidiary2; do
    dig NS ${subsidiary}.parentcompany.com +short
done

# Check for glue records
dig NS parentcompany.com +norecurse | grep -i "ANSWER SECTION" -A20
```

### Phase 2: Subsidiary IP Range Identification

#### BGP Data Analysis

```bash
# Query BGP data for IP ownership
curl -s "https://api.bgpview.io/ips/$(dig A parentcompany.com +short | head -1)" | jq '.data.asns[] | {asn: .asn, name: .name, description: .description}'

# Find all IP ranges for an organization
curl -s "https://api.bgpview.io/asns/$(curl -s "https://api.bgpview.io/ips/$(dig A parentcompany.com +short | head -1)" | jq -r '.data.asns[0].asn')/prefixes" | jq '.data.prefixes[] | {prefix: .prefix, name: .name, description: .description}'

# Check for BGP announcements from subsidiary IPs
for ip in $(dig A subsidiary1.parentcompany.com +short); do
    echo "IP: $ip"
    curl -s "https://api.bgpview.io/ips/$ip" | jq '.data.asns[]'
done

# Monitor for new BGP announcements
# Use BGP monitoring services

# Check for IP range transfers between entities
# Track ARIN, RIPE, APNIC transfers
```

#### ASN Lookup and Analysis

```bash
# Find ASN for organization
curl -s "https://api.bgpview.io/search?query=parentcompany" | jq '.data.asns[] | {asn: .asn, name: .name, country: .country}'

# Get all IP prefixes for ASN
curl -s "https://api.bgpview.io/asns/ASN/prefixes" | jq '.data.prefixes[]'

# Check for ASN relationships
curl -s "https://api.bgpview.io/asns/ASN/upstreams" | jq '.data.upstreams[]'
curl -s "https://api.bgpview.io/asns/ASN/downstreams" | jq '.data.downstreams[]'

# Identify related ASNs
curl -s "https://api.bgpview.io/asns/ASN/peers" | jq '.data.peers[]'

# Check for ASN transfers
# Monitor BGP streams for changes
```

#### IP Range Ownership Analysis

```bash
# WHOIS for IP ranges
for ip in $(dig A parentcompany.com +short); do
    echo "IP: $ip"
    whois $ip | grep -iE "OrgName|NetName|descr|Country|CIDR|Range"
done

# Identify IP allocations to subsidiaries
# Check for separate IP blocks per subsidiary

# Analyze IP geolocation
for ip in $(dig A subsidiary1.parentcompany.com +short); do
    echo "IP: $ip"
    curl -s "https://ipinfo.io/$ip/json" | jq '.org, .city, .region, .country'
done

# Check for IP range overlap
# Identify shared IP ranges

# Monitor for new IP allocations
# Track RIR allocations
```

### Phase 3: Subsidiary Technology Detection

#### Web Technology Fingerprinting

```bash
# Technology detection across subsidiaries
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    whatweb $domain 2>/dev/null | head -5
done

# Compare technology stacks
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -sI https://$domain | grep -iE "server|x-powered|x-generator"
done

# Identify shared technologies
# Group subsidiaries by technology stack

# Check for common frameworks
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -s https://$domain | grep -iE "wordpress|drupal|joomla|django|rails|laravel|spring"
done

# Monitor for technology changes
while true; do
    for domain in $(cat subsidiaries.txt); do
        whatweb $domain 2>/dev/null > /tmp/tech_$domain.txt
    done
    sleep 86400
done
```

#### Cloud Infrastructure Analysis

```bash
# Identify cloud providers across subsidiaries
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    dig CNAME www.$domain +short | grep -iE "cloudfront|azureedge|cloudflare|akamai"
    curl -sI https://$domain | grep -iE "cf-ray|cdn|cloudfront|azure"
done

# Check for shared cloud accounts
# Analyze AWS/Azure/GCP configurations

# Identify cloud service usage
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -s https://$domain | grep -iE "aws|azure|google cloud|microsoft"
done

# Check for cloud misconfigurations
# Monitor for public S3 buckets
# Check for exposed storage accounts

# Analyze cloud architecture
# Map cloud dependencies
```

#### Network Infrastructure Analysis

```bash
# Identify network equipment
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    nmap -sV -p 80,443 $domain 2>/dev/null | grep -i "server"
done

# Check for load balancers
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -sI https://$domain | grep -iE "x-amzn|awselb|bigip|f5|citrix|kemp"
done

# Identify CDN usage
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -sI https://$domain | grep -iE "cf-ray|cdn|via|x-cache|x-served-by"
done

# Check for WAF protection
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -sI https://$domain | grep -iE "x-sucuri|x-akamai|x-protected-by|x-waf"
done

# Monitor for network changes
# Track infrastructure updates
```

### Phase 4: Shared Credential Discovery

#### Cross-Domain Credential Analysis

```bash
# Check for shared email domains
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    dig MX $domain +short
done

# Identify common email providers
for domain in $(cat subsidiaries.txt); do
    mx=$(dig MX $domain +short | head -1 | awk '{print $2}' | sed 's/\.$//')
    echo "$domain: $mx"
done

# Check for shared authentication systems
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -s https://$domain/.well-known/openid-configuration 2>/dev/null | jq '.issuer'
done

# Analyze OAuth connections
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -s https://$domain/.well-known/oauth-authorization-server 2>/dev/null | jq '.issuer'
done

# Check for SAML configurations
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -s https://$domain/saml/metadata 2>/dev/null | grep -oP 'entityID="[^"]+"'
done

# Monitor for credential reuse
# Track authentication patterns
```

#### Active Directory Trust Analysis

```bash
# Identify AD trust relationships
# Check for forest trusts
# Map domain trust paths

# Analyze Kerberos configurations
# Check for cross-realm trusts
# Identify shared key distribution centers

# Check for shared certificates
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].issuer_name' | sort -u
done

# Identify common CAs
# Check for certificate reuse

# Monitor for trust changes
# Track AD modifications
```

#### Password and Credential Analysis

```bash
# Check for password reuse across domains
# Use breach intelligence platforms

# Monitor for credential leaks
# Check paste sites and dark web

# Analyze password policies
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -s https://$domain/settings/password 2>/dev/null | grep -iE "length|complexity|rotation"
done

# Check for shared accounts
# Monitor for default credentials

# Track credential changes
# Monitor for unauthorized access
```

### Phase 5: Corporate Structure Analysis

#### Parent-Subsidiary Relationship Mapping

```bash
# SEC filing analysis for ownership
curl -s "https://efts.sec.gov/LATEST/search-index?q=%22parent+company%22+%22subsidiary%22" | jq '.hits.hits[]'

# Check annual reports for subsidiary lists
curl -s "https://www.sec.gov/Archives/edgar/data/CIK/filing.htm" | grep -A50 "Subsidiaries" | head -100

# Extract subsidiary information
curl -s "https://www.sec.gov/Archives/edgar/data/CIK/filing.htm" | grep -iE "wholly-owned|majority-owned|subsidiary" | head -20

# Check international subsidiaries
curl -s "https://www.sec.gov/Archives/edgar/data/CIK/filing.htm" | grep -iE "Inc\.|Ltd\.|GmbH\.|S\.A\.|B\.V\."

# Map corporate hierarchy
# Identify holding companies
# Check for shell companies

# Monitor for structural changes
# Track new subsidiary formations
```

#### Business Registry Analysis

```bash
# US State registries
curl -s "https://www.sos.state.tx.us/corp/sosda/index.shtml" | grep -i "parent company"

# UK Companies House
curl -s "https://api.company-information.service.gov.uk/company/COMPANY_NUMBER" -u "API_KEY:" | jq '.items[0]'

# Australian ASIC
curl -s "https://connectonline.asic.gov.au/RegistrySearch/faces/landing/SearchRegisters.jspx" | grep -i "parent"

# EU company registries
# Check for cross-border structures

# Map ownership percentages
# Identify ultimate beneficial owners

# Check for nominee directors
# Track corporate changes
```

#### Financial Analysis

```bash
# SEC filing financial data
curl -s "https://efts.sec.gov/LATEST/search-index?q=%22parent+company%22+%22revenue%22+%22subsidiary%22" | jq '.hits.hits[]'

# Check 10-K for subsidiary financials
curl -s "https://www.sec.gov/Archives/edgar/data/CIK/filing.htm" | grep -A100 "Segment Information" | head -150

# Analyze intercompany transactions
curl -s "https://www.sec.gov/Archives/edgar/data/CIK/filing.htm" | grep -iE "intercompany|related party|transfer pricing"

# Check for offshore structures
curl -s "https://www.sec.gov/Archives/edgar/data/CIK/filing.htm" | grep -iE "Cayman|BVI|Bermuda|Luxembourg|Ireland"

# Monitor for financial changes
# Track revenue allocations
# Check for tax optimization structures
```

### Phase 6: Cross-Subsidiary Trust Relationships

```bash
# Identify shared infrastructure
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    dig A $domain +short
done | sort -t: -k2 | uniq -f1

# Check for shared IP ranges
for domain in $(cat subsidiaries.txt); do
    ip=$(dig A $domain +short | head -1)
    echo "$domain: $ip"
done | awk '{print $2}' | sort | uniq -d

# Identify common network providers
for domain in $(cat subsidiaries.txt); do
    ip=$(dig A $domain +short | head -1)
    whois $ip | grep -i "OrgName" | head -1
done | sort | uniq -c

# Check for shared CDN usage
for domain in $(cat subsidiaries.txt); do
    echo "=== $domain ==="
    curl -sI https://$domain | grep -iE "cf-ray|cdn|via"
done

# Map trust relationships
# Identify lateral movement paths
# Check for trust abuse potential

# Monitor for trust changes
# Track infrastructure modifications
```

## Tool Arsenal

### Corporate Intelligence
- **SEC EDGAR** - US corporate filings
- **Companies House** - UK company registry
- **ASIC** - Australian business registry
- **OpenCorporates** - Global company data
- **Dun & Bradstreet** - Business intelligence

### Network Intelligence
- **BGPView** - BGP data API
- **Hurricane Electric** - Network tools
- **RIPEstat** - Network information
- **ARIN** - North American registry
- **APNIC** - Asia-Pacific registry

### DNS and Domain
- **dig** - DNS lookup
- **whois** - Domain registration
- **SecurityTrails** - DNS history
- **ViewDNS** - DNS tools
- **DNSlytics** - DNS analytics

### OSINT Tools
- **Maltego** - Link analysis
- **SpiderFoot** - Recon automation
- **Recon-ng** - Recon framework
- **theHarvester** - Data harvesting
- **Shodan** - Device search

### Corporate Research
- **Crunchbase** - Company data
- **PitchBook** - Financial data
- **LinkedIn** - Professional network
- **Glassdoor** - Company reviews
- **Indeed** - Job postings

### Technical Analysis
- **whatweb** - Technology detection
- **nmap** - Network scanning
- **masscan** - Port scanning
- **httpx** - HTTP probing
- **crt.sh** - Certificate search

## Case Studies

### Case Study 1: Hidden Subsidiary Discovery

A parent company's SEC filings listed only direct subsidiaries. Through WHOIS analysis and BGP data, analysts discovered 12 additional entities:
- 3 shell companies in Delaware
- 2 offshore entities in Cayman Islands
- 4 subsidiaries operating under different names
- 3 joint ventures with shared infrastructure

**Discovery Chain:**
1. WHOIS analysis → Common registrant email domain
2. BGP data → Shared IP ranges
3. Certificate analysis → Common certificate authority
4. DNS analysis → Shared nameservers
5. Financial analysis → Intercompany transactions

### Case Study 2: Cross-Subsidiary Trust Exploitation

An attacker compromised a small subsidiary with weak security controls. Through Active Directory trusts, they gained access to:
- Parent company's financial systems
- Other subsidiaries' customer data
- Shared intellectual property

**Impact:** $10M in damages across all entities.

### Case Study 3: Shared Infrastructure Vulnerability

Multiple subsidiaries shared the same cloud infrastructure without proper segmentation. A vulnerability in one subsidiary's application allowed access to:
- Other subsidiaries' databases
- Shared API keys and credentials
- Parent company's internal tools

**Impact:** Complete compromise of shared infrastructure.

### Case Study 4: Regulatory Compliance Gap

A multinational parent company had subsidiaries in 15 countries. Each subsidiary had different compliance requirements. The parent company assumed compliance in one country applied to all. This resulted in:
- GDPR violations in EU subsidiaries
- HIPAA violations in US healthcare subsidiary
- PCI DSS violations in retail subsidiary

**Impact:** $25M in regulatory fines.

### Case Study 5: Corporate Structure Obfuscation

A parent company used complex corporate structures to hide assets. Through SEC filing analysis and corporate registry mining, analysts discovered:
- 47 subsidiaries across 12 countries
- 3 holding companies in tax havens
- Complex intercompany loan structures
- Undisclosed related party transactions

**Impact:** SEC investigation and $50M in penalties.

## Advanced Techniques

### Advanced Corporate Structure Analysis

```bash
# Map complex ownership structures
# Use graph databases for relationship mapping

# Identify shell companies
# Check for nominee directors and shareholders

# Analyze offshore structures
# Map tax optimization schemes

# Track corporate changes over time
# Monitor for suspicious transactions

# Identify ultimate beneficial owners
# Check for politically exposed persons
```

###暗网 Intelligence

```bash
# Monitor dark web for subsidiary data
# Check for leaked credentials
# Track threat actor interest

# Search for leaked corporate data
# Monitor underground forums
# Check for data dumps

# Track insider threats
# Monitor for data exfiltration
# Check for unauthorized access
```

### Advanced Network Analysis

```bash
# Map complex network topologies
# Identify hidden connections

# Analyze traffic patterns
# Check for data flows between subsidiaries

# Monitor for network changes
# Track infrastructure modifications

# Identify network segmentation gaps
# Check for lateral movement paths
```

### Advanced Certificate Analysis

```bash
# Map certificate relationships
# Identify shared certificate authorities

# Check for certificate transparency
# Monitor for unauthorized certificates

# Analyze certificate chains
# Identify common intermediates

# Track certificate lifecycle
# Monitor for expiration issues
```

## Detection Evasion

### Avoiding Detection During Subsidiary Mapping

```bash
# Use passive intelligence sources
# Avoid active scanning when possible

# Respect legal boundaries
# Work with legal counsel

# Protect sensitive information
# Limit access to corporate data

# Monitor for counter-intelligence
# Check for surveillance indicators

# Coordinate with corporate security
# Share threat intelligence responsibly
```

### Corporate Espionage Awareness

```bash
# Monitor for social engineering attempts
# Check for phishing campaigns

# Protect acquisition data
# Use encryption for sensitive information

# Monitor for insider threats
# Track access to corporate data

# Coordinate with legal teams
# Follow regulatory requirements
```

## Impact Assessment

### Subsidiary Risk Categories

1. **Critical** - Direct access to parent systems
2. **High** - Shared infrastructure with parent
3. **Medium** - Limited integration with parent
4. **Low** - Independent operation
5. **Informational** - Observation only

### Risk Indicators

1. **Shared Credentials** - Same passwords across entities
2. **Trust Relationships** - Cross-domain trusts
3. **Shared Infrastructure** - Common IP ranges or hosting
4. **Weak Security** - Outdated controls at subsidiary
5. **Compliance Gaps** - Missing certifications

## Common Pitfalls

1. **Incomplete Asset Discovery** - Missing subsidiaries
2. **Trust Relationship Oversights** - Not mapping cross-domain trusts
3. **Shared Infrastructure Blindness** - Missing common systems
4. **Credential Reuse** - Not checking for password reuse
5. **Compliance Gaps** - Missing regulatory requirements
6. **Corporate Structure Complexity** - Missing hidden entities
7. **Offshore Structures** - Missing international entities
8. **Joint Venture Risks** - Not assessing partner security
9. **Franchise Risks** - Not monitoring franchise operations
10. **Holding Company Complexity** - Missing intermediate entities
11. **Shell Company Detection** - Missing entity used for obfuscation
12. **Trust Abuse Potential** - Not identifying lateral movement paths
13. **Shared Certificate Risks** - Missing certificate reuse
14. **DNS Delegation Risks** - Not checking subdomain delegation
15. **Network Segmentation** - Missing network boundaries

## Integration Points

### Corporate Governance

- Include subsidiary security in board reporting
- Track corporate structure changes
- Monitor for regulatory requirements

### Risk Management

- Assess subsidiary risk ratings
- Track compliance status
- Monitor for new risks

### Security Operations

- Monitor subsidiary infrastructure
- Track credential changes
- Coordinate incident response

### Compliance

- Track regulatory requirements
- Monitor for compliance gaps
- Report to regulators

## Reporting

### Subsidiary Asset Map Report

```markdown
# Subsidiary Asset Map - [Parent Company]

## Executive Summary
- Total Subsidiaries: [N]
- Countries: [N]
- Shared Infrastructure: [Y/N]
- Key Findings: [Summary]

## Corporate Structure
### Direct Subsidiaries
| Subsidiary | Ownership | Country | Domain | IP Range |
|------------|-----------|---------|--------|----------|
| [Name] | [%] | [Country] | [Domain] | [Range] |

### Indirect Subsidiaries
| Subsidiary | Parent | Country | Domain | IP Range |
|------------|--------|---------|--------|----------|
| [Name] | [Parent] | [Country] | [Domain] | [Range] |

## Technical Infrastructure
### Shared Infrastructure
- Common Nameservers: [List]
- Shared IP Ranges: [List]
- Common Certificates: [List]

### Individual Infrastructure
| Subsidiary | Cloud | CDN | WAF | Email |
|------------|-------|-----|-----|-------|
| [Name] | [Provider] | [Provider] | [Provider] | [Provider] |

## Trust Relationships
### Active Directory Trusts
| Parent | Child | Trust Type | Direction |
|--------|-------|------------|-----------|
| [Domain] | [Domain] | [Type] | [Direction] |

### Shared Authentication
| Subsidiary | IdP | Protocol | Notes |
|------------|-----|----------|-------|
| [Name] | [Provider] | [Protocol] | [Notes] |

## Risk Assessment
### Critical Findings
1. [Finding] - Impact: [Description]

### Recommendations
1. [Recommendation]
```

## Labs

### Lab 1: Subsidiary Discovery Challenge

Given a parent company, discover all subsidiaries through WHOIS, BGP, and corporate registry analysis.

**Objective:** Map complete corporate structure with technical indicators.

### Lab 2: Cross-Subsidiary Trust Analysis

Analyze trust relationships between parent and subsidiary organizations.

**Objective:** Identify lateral movement paths and trust abuse potential.

### Lab 3: Shared Infrastructure Assessment

Map shared infrastructure across subsidiaries and assess security implications.

**Objective:** Identify segmentation gaps and shared risks.

### Lab 4: Corporate Structure Compliance

Analyze corporate structure for compliance requirements across jurisdictions.

**Objective:** Identify compliance gaps and regulatory risks.

### Lab 5: Risk Assessment and Remediation

Conduct comprehensive risk assessment of subsidiary ecosystem.

**Objective:** Create prioritized remediation roadmap.

## Ethics

### Responsible Subsidiary Analysis

1. **Legal Compliance** - Adhere to all regulations
2. **Privacy Protection** - Protect personal information
3. **Confidentiality** - Secure corporate data
4. **Transparency** - Report findings honestly
5. **Professionalism** - Maintain ethical standards

### Stakeholder Communication

1. **Board Reporting** - Provide accurate risk assessments
2. **Regulatory Reporting** - Meet disclosure requirements
3. **Team Communication** - Share relevant information
4. **Vendor Management** - Assess third-party risks
5. **Customer Protection** - Ensure data security

## Cheat Sheet

### WHOIS Analysis Commands

```bash
# Basic WHOIS
whois domain.com

# Extract Registrant
whois domain.com | grep -i "Registrant Organization:"

# Extract Email Domain
whois domain.com | grep -i "Registrant Email:" | grep -oP '@\K[^>]+'

# Compare Multiple Domains
for d in $(cat domains.txt); do echo "=== $d ==="; whois $d | grep -i "Registrant Organization:"; done
```

### BGP Analysis Commands

```bash
# IP to ASN
curl -s "https://api.bgpview.io/ips/IP_ADDRESS" | jq '.data.asns[]'

# ASN to Prefixes
curl -s "https://api.bgpview.io/asns/ASN/prefixes" | jq '.data.prefixes[]'

# Search ASN
curl -s "https://api.bgpview.io/search?query=ORGANIZATION" | jq '.data.asns[]'
```

### DNS Analysis Commands

```bash
# NS Records
dig NS domain.com +short

# MX Records
dig MX domain.com +short

# TXT Records
dig TXT domain.com +short

# CNAME Analysis
dig CNAME www.domain.com +short
```

### Certificate Analysis Commands

```bash
# CT Log Search
curl -s "https://crt.sh/?q=%.domain.com&output=json"

# Live Certificate
echo | openssl s_client -connect domain.com:443 2>/dev/null | openssl x509 -noout -text

# SAN Extraction
echo | openssl s_client -connect domain.com:443 2>/dev/null | openssl x509 -noout -ext subjectAltName
```

### Quick Subsidiary Indicators

| Indicator | Meaning | Risk |
|-----------|---------|------|
| Common WHOIS | Same registrant | High |
| Shared NS | Same DNS provider | Medium |
| Shared IP | Same hosting | High |
| Common Cert | Same CA | Medium |
| Trust Relationship | AD trust | Critical |
| Shared IdP | Same authentication | High |
| Offshore Entity | Tax optimization | Medium |
| Shell Company | Obfuscation | High |
