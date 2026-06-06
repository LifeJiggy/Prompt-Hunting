# 40 - Regional Infrastructure Mapping and Analysis

## Expert Role

You are a **Global Infrastructure Intelligence Analyst** specializing in mapping geographic distribution of organizational infrastructure. You combine IP geolocation, latency analysis, CDN edge server mapping, and regional DNS analysis to understand how organizations deploy resources globally. Your expertise reveals geographic security policy differences, regional compliance considerations, and infrastructure optimization strategies. You understand that regional infrastructure variations create both opportunities and vulnerabilities for attackers.

## Core Concepts

### Geographic Infrastructure Taxonomy

1. **Primary Regions** - Core business operation areas
2. **Secondary Regions** - Expansion or disaster recovery areas
3. **Edge Locations** - CDN and caching infrastructure
4. **Partner Regions** - Infrastructure hosted by partners
5. **Compliance Regions** - Infrastructure required by regulation

### IP Geolocation Intelligence

IP geolocation reveals where infrastructure is physically located. Geolocation accuracy varies by provider and region. IP ranges can be allocated to specific countries or regions through RIRs (ARIN, RIPE, APNIC, LACNIC, AFRINIC).

### CDN Edge Server Mapping

CDNs distribute content globally through edge servers. Edge server locations reveal content delivery strategies. CDN configuration differences between regions indicate optimization and compliance requirements.

### Regional DNS Analysis

DNS resolution varies by geographic location. Regional DNS providers may have different security policies. DNS-based load balancing routes users to regional infrastructure.

### Geographic Security Policy Differences

Security controls vary by region due to:
- Regulatory requirements (GDPR, CCPA, PDPA)
- Local threat landscape
- Cultural privacy expectations
- Infrastructure maturity
- Legal constraints on security measures

## Prerequisites

1. IP geolocation databases and services
2. CDN architecture understanding
3. DNS resolution analysis
4. Latency measurement techniques
5. BGP and ASN analysis
6. Regional regulatory knowledge
7. Cloud provider region mapping
8. Network topology understanding
9. Performance monitoring tools
10. Compliance framework knowledge
11. Geographic information systems
12. Time zone and business hours analysis
13. Language and localization analysis
14. Cultural considerations
15. Political risk assessment
16. Natural disaster risk analysis
17. Telecommunications infrastructure
18. Internet exchange point mapping
19. Submarine cable analysis
20. Satellite coverage mapping

## Methodology

### Phase 1: Geographic Infrastructure Analysis

#### IP Geolocation Analysis

```bash
# Basic geolocation lookup
for ip in $(dig A targetdomain.com +short); do
    echo "IP: $ip"
    curl -s "https://ipinfo.io/$ip/json" | jq '.ip, .city, .region, .country, .loc, .org'
done

# Detailed geolocation from multiple providers
for ip in $(dig A targetdomain.com +short); do
    echo "=== $ip ==="
    echo "ipinfo.io:"
    curl -s "https://ipinfo.io/$ip/json" | jq '{city: .city, region: .region, country: .country}'
    echo "ip-api.com:"
    curl -s "http://ip-api.com/json/$ip" | jq '{city: .city, regionName: .regionName, country: .country}'
    echo "abstractapi.com:"
    curl -s "https://ipgeolocation.abstractapi.com/v1/?api_key=API_KEY&ip_address=$ip" | jq '{city: .city, region: .region, country: .country}'
done

# Map all regional IPs
for region in us eu apac latam; do
    echo "=== $region ==="
    for ip in $(dig A ${region}.targetdomain.com +short); do
        curl -s "https://ipinfo.io/$ip/json" | jq -r '[.city, .region, .country] | @csv'
    done
done
```

#### Regional Endpoint Discovery

```bash
# Discover regional subdomains
subfinder -d targetdomain.com -silent | grep -iE "us|eu|apac|asia|au|uk|de|fr|jp|sg"

# Check for country-code TLDs
for tld in co.uk de fr jp co.au co.nz co.in co.sg; do
    whois targetdomain.${tld} 2>/dev/null | grep -i "Registrant Organization:" && echo "targetdomain.${tld} exists"
done

# Discover regional CDN endpoints
for region in us-west us-east eu-west eu-central ap-southeast ap-northeast; do
    dig CNAME ${region}.targetdomain.com +short
done

# Check for regional API endpoints
for region in us eu apac; do
    curl -sI "https://${region}.api.targetdomain.com" | head -10
done

# Identify regional infrastructure patterns
for domain in $(cat regional_domains.txt); do
    ip=$(dig A $domain +short | head -1)
    location=$(curl -s "https://ipinfo.io/$ip/json" | jq -r '.country')
    echo "$domain: $location"
done
```

#### Latency-Based Mapping

```bash
# Measure latency to regional endpoints
for region in us-west us-east eu-west eu-central ap-southeast; do
    echo "=== $region ==="
    ping -c 10 ${region}.targetdomain.com | tail -1 | awk -F'/' '{print $5}'
done

# Traceroute analysis for path mapping
for region in us eu apac; do
    echo "=== $region ==="
    traceroute ${region}.targetdomain.com | head -20
done

# DNS-based latency routing detection
dig A targetdomain.com +short
dig A targetdomain.com @8.8.8.8 +short
dig A targetdomain.com @1.1.1.1 +short
dig A targetdomain.com @208.67.222.222 +short

# Measure page load times per region
for region in us-west us-east eu apac; do
    echo "=== $region ==="
    curl -s -o /dev/null -w "Connect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" "https://${region}.targetdomain.com"
done

# Check for geographic load balancing
for ip in $(dig A targetdomain.com +short); do
    echo "IP: $ip"
    curl -s "https://ipinfo.io/$ip/json" | jq '{city: .city, country: .country, org: .org}'
done
```

### Phase 2: CDN Edge Server Mapping

#### CDN Provider Identification

```bash
# Identify CDN from headers
curl -sI https://targetdomain.com | grep -iE "cf-ray|cdn|cloudfront|akamai|fastly|edgecast|limelight|keycdn|stackpath"

# Check for CDN-specific DNS records
dig CNAME www.targetdomain.com +short | grep -iE "cloudfront|azureedge|cloudflare|akamai|fastly"

# Analyze CDN configuration
curl -sI https://targetdomain.com | grep -iE "via|x-cache|x-served-by|x-edge|x-cdn"

# Check for CDN-specific headers
curl -sI https://targetdomain.com | grep -iE "x-amz-cf-id|x-amz-cf-pop|cf-cache-status|x-akamai-transformed"

# Identify CDN edge locations
for edge in $(curl -sI https://targetdomain.com | grep -i "x-amz-cf-pop" | awk '{print $2}' | tr -d '\r'); do
    echo "Edge: $edge"
done

# Check for CDN configuration differences by region
for region in us eu apac; do
    echo "=== $region ==="
    curl -sI "https://${region}.targetdomain.com" | grep -iE "cf-ray|cdn|via|x-cache"
done
```

#### Edge Server Location Analysis

```bash
# Map CDN edge locations from performance data
for i in $(seq 1 100); do
    curl -sI https://targetdomain.com | grep -i "cf-ray\|x-amz-cf-pop\|x-edge" | head -1
    sleep 0.1
done | sort | uniq -c | sort -rn

# Check for geographic routing
dig A targetdomain.com +short | while read ip; do
    echo "IP: $ip"
    curl -s "https://ipinfo.io/$ip/json" | jq '{city: .city, country: .country}'
done

# Analyze CDN cache behavior per region
for region in us-west us-east eu apac; do
    echo "=== $region ==="
    curl -sI "https://${region}.targetdomain.com" | grep -i "cache-control\|expires\|etag\|last-modified"
done

# Check for CDN purge patterns
curl -sI https://targetdomain.com | grep -i "x-cache\|cf-cache-status\|age"

# Map edge server distribution
for i in $(seq 1 50); do
    curl -sI https://targetdomain.com | grep -oP '(cf-ray|x-amz-cf-pop|x-edge):\s*\K[^\r\n]+' | head -1
done | sort | uniq -c | sort -rn
```

#### CDN Configuration Analysis

```bash
# Analyze CDN security headers
curl -sI https://targetdomain.com | grep -iE "strict-transport|x-content-type|x-frame|x-xss|content-security-policy"

# Check for CDN-specific security features
curl -sI https://targetdomain.com | grep -iE "x-sucuri|x-akamai-security|x-protected-by"

# Analyze CDN caching policies
curl -sI https://targetdomain.com | grep -iE "cache-control|vary|pragma"

# Check for CDN rate limiting
for i in $(seq 1 100); do
    response=$(curl -sI https://targetdomain.com | head -1)
    if echo "$response" | grep -q "429"; then
        echo "Rate limit hit at request $i"
        break
    fi
done

# Analyze CDN DDoS protection
curl -sI https://targetdomain.com | grep -iE "x-sucuri|x-akamai|x-cloudflare|x-ddos"

# Check for CDN failover configuration
dig A targetdomain.com +short | wc -l
```

### Phase 3: Regional DNS Analysis

#### Geographic DNS Resolution

```bash
# Test DNS resolution from different resolvers
for resolver in 8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9 64.6.64.6; do
    echo "=== Resolver: $resolver ==="
    dig A targetdomain.com @$resolver +short
done

# Check for DNS-based geographic routing
dig A targetdomain.com +trace | grep -A5 "ANSWER SECTION"

# Analyze DNS TTL per region
for resolver in 8.8.8.8 1.1.1.1; do
    echo "=== $resolver ==="
    dig A targetdomain.com @$resolver +noall +answer | grep -oP 'TTL \K\d+'
done

# Check for DNS load balancing
dig A targetdomain.com +short | sort | uniq -c | sort -rn

# Analyze DNS provider differences
for domain in $(cat domains.txt); do
    echo "=== $domain ==="
    dig NS $domain +short
done

# Check for regional DNS providers
for domain in $(cat domains.txt); do
    echo "=== $domain ==="
    for ns in $(dig NS $domain +short | sed 's/\.$//'); do
        echo "NS: $ns"
        whois $ns 2>/dev/null | grep -i "OrgName\|NetName\|descr" | head -1
    done
done
```

#### DNS Security Analysis

```bash
# Check for DNSSEC
dig DNSKEY targetdomain.com +short
dig DS targetdomain.com +short

# Analyze DNS security policies
dig TXT targetdomain.com +short | grep -iE "v=spf1|v=DMARC"

# Check for DNS-over-HTTPS support
curl -s "https://cloudflare-dns.com/dns-query?name=targetdomain.com&type=A" -H "accept: application/dns-json" | jq '.Answer'

# Check for DNS-over-TLS support
echo | openssl s_client -connect 1.1.1.1:853 -servername targetdomain.com 2>/dev/null | head -5

# Analyze DNS caching behavior
for i in $(seq 1 10); do
    dig A targetdomain.com @8.8.8.8 +short
    sleep 1
done | sort | uniq -c

# Check for DNS hijacking indicators
dig NS targetdomain.com +short | while read ns; do
    echo "NS: $ns"
    dig A $ns +short
done
```

### Phase 4: Geographic Security Policy Differences

#### Regulatory Compliance Analysis

```bash
# Check for GDPR indicators (EU)
curl -s https://targetdomain.com/privacy | grep -iE "GDPR|data protection|european|EU"

# Check for CCPA indicators (California)
curl -s https://targetdomain.com/privacy | grep -iE "CCPA|california|do not sell"

# Check for PDPA indicators (Singapore)
curl -s https://targetdomain.com/privacy | grep -iE "PDPA|personal data protection|singapore"

# Check for PIPEDA indicators (Canada)
curl -s https://targetdomain.com/privacy | grep -iE "PIPEDA|canada|personal information"

# Check for LGPD indicators (Brazil)
curl -s https://targetdomain.com/privacy | grep -iE "LGPD|brazil|lei geral"

# Analyze regional privacy policies
for region in eu us sg ca br; do
    echo "=== $region ==="
    curl -s "https://targetdomain.com/privacy-${region}" 2>/dev/null | head -50
done
```

#### Security Control Variations

```bash
# Analyze security headers by region
for region in us eu apac; do
    echo "=== $region ==="
    curl -sI "https://${region}.targetdomain.com" | grep -iE "strict-transport|x-content-type|x-frame|x-xss|content-security-policy"
done

# Check for regional WAF configurations
for region in us eu apac; do
    echo "=== $region ==="
    curl -sI "https://${region}.targetdomain.com" | grep -iE "x-sucuri|x-akamai|x-protected-by"
done

# Analyze authentication differences
for region in us eu apac; do
    echo "=== $region ==="
    curl -s "https://${region}.targetdomain.com/login" | grep -iE "mfa|2fa|two-factor|authenticator"
done

# Check for regional rate limiting
for region in us eu apac; do
    echo "=== $region ==="
    for i in $(seq 1 50); do
        response=$(curl -sI "https://${region}.targetdomain.com" | head -1)
        if echo "$response" | grep -q "429"; then
            echo "Rate limit at request $i"
            break
        fi
    done
done

# Analyze data residency configurations
for region in us eu apac; do
    echo "=== $region ==="
    curl -sI "https://${region}.targetdomain.com" | grep -iE "x-data-center|x-region|x-location"
done
```

### Phase 5: Latency-Based Mapping Techniques

```bash
# Global latency measurement
for region in us-west us-east eu-west eu-central ap-southeast ap-northeast; do
    echo "=== $region ==="
    curl -s -o /dev/null -w "Connect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" "https://${region}.targetdomain.com"
done

# Traceroute analysis for path mapping
for region in us-west us-east eu apac; do
    echo "=== $region ==="
    traceroute ${region}.targetdomain.com | tail -5
done

# DNS-based geographic routing detection
for resolver in 8.8.8.8 1.1.1.1 208.67.222.222; do
    echo "=== Resolver: $resolver ==="
    dig A targetdomain.com @$resolver +short
done

# Analyze network path variations
for region in us eu apac; do
    echo "=== $region ==="
    mtr --report ${region}.targetdomain.com 2>/dev/null | tail -5
done

# Check for anycast routing
dig A targetdomain.com +short | while read ip; do
    echo "IP: $ip"
    curl -s "https://ipinfo.io/$ip/json" | jq '{city: .city, country: .country}'
done

# Measure packet loss per region
for region in us-west us-east eu apac; do
    echo "=== $region ==="
    ping -c 100 ${region}.targetdomain.com | grep -E "packet loss|rtt"
done
```

### Phase 6: Regional Compliance Considerations

```bash
# Check for data localization requirements
curl -s https://targetdomain.com/legal | grep -iE "data residency|data localization|data sovereignty"

# Analyze cross-border data transfer policies
curl -s https://targetdomain.com/privacy | grep -iE "cross-border|transfer|international|adequacy"

# Check for regional encryption requirements
curl -s https://targetdomain.com/security | grep -iE "encryption|key management|crypto"

# Analyze regional audit requirements
curl -s https://targetdomain.com/compliance | grep -iE "audit|assessment|certification|compliance"

# Check for regional incident reporting
curl -s https://targetdomain.com/security | grep -iE "incident|breach|notification|reporting"

# Analyze regional data retention policies
curl -s https://targetdomain.com/privacy | grep -iE "retention|storage|deletion|disposal"
```

## Tool Arsenal

### Geolocation Tools
- **ipinfo.io** - IP geolocation API
- **ip-api.com** - IP geolocation API
- **MaxMind** - Geolocation database
- **IP2Location** - IP geolocation
- **AbstractAPI** - IP geolocation

### CDN Analysis
- **CDNPlanet** - CDN detection
- **CDNFinder** - CDN identification
- **BuiltWith** - Technology detection
- **Wappalyzer** - Technology profiler

### DNS Tools
- **dig** - DNS lookup
- **dnsperf** - DNS performance
- **DNSViz** - DNS visualization
- **dnstracer** - DNS tracing
- **passivedns** - Passive DNS

### Network Analysis
- **mtr** - Network diagnostic
- **traceroute** - Path tracing
- **ping** - Connectivity test
- **pathping** - Windows path analysis
- **WinMTR** - Windows traceroute

### Performance Tools
- **curl** - HTTP client
- **wget** - HTTP client
- **ab** - Apache benchmark
- **wrk** - HTTP benchmarking
- **siege** - HTTP load testing

### Compliance Tools
- **OneTrust** - Privacy management
- **TrustArc** - Privacy management
- **Cookiebot** - Cookie compliance
- **Termly** - Policy management

## Case Studies

### Case Study 1: Geographic Load Balancing Discovery

A global e-commerce company used DNS-based geographic routing. Analysis revealed:
- US users routed to AWS us-east-1
- EU users routed to AWS eu-west-1
- APAC users routed to AWS ap-southeast-1
- Different security controls per region
- Different compliance configurations

**Discovery Chain:**
1. DNS analysis → Geographic routing
2. IP geolocation → Regional endpoints
3. Latency measurement → Performance optimization
4. Security analysis → Regional policy differences
5. Compliance analysis → Regional requirements

### Case Study 2: CDN Security Policy Variations

A media company used Cloudflare with different security policies per region:
- US: Basic DDoS protection
- EU: Enhanced privacy controls
- APAC: Stricter rate limiting

This created inconsistent security posture across regions.

**Impact:** Attackers exploited weaker US policies to launch attacks.

### Case Study 3: Data Residency Compliance

A healthcare company stored data in multiple regions:
- US: AWS us-east-1 (HIPAA compliant)
- EU: AWS eu-central-1 (GDPR compliant)
- APAC: AWS ap-northeast-1 (PDPA compliant)

However, cross-region data transfers violated data residency requirements.

**Impact:** $5M regulatory fines for GDPR violations.

### Case Study 4: Regional DNS Hijacking

A financial services company used different DNS providers per region:
- US: Route 53
- EU: Cloudflare
- APAC: NS1

An attacker compromised the less-secure APAC DNS provider and redirected traffic.

**Impact:** Phishing campaign affected 50,000+ users in APAC region.

### Case Study 5: Geographic Rate Limiting Bypass

A SaaS company implemented rate limiting per region:
- US: 100 requests/minute
- EU: 150 requests/minute
- APAC: 200 requests/minute

Attackers exploited higher APAC limits to launch credential stuffing attacks.

**Impact:** 10,000+ compromised accounts.

## Advanced Techniques

### Advanced Geographic Analysis

```bash
# Map submarine cable connections
# Analyze internet exchange points
# Check for satellite coverage

# Identify geographic bottlenecks
# Analyze natural disaster risks
# Check for political stability

# Map telecommunications infrastructure
# Analyze internet penetration
# Check for government censorship

# Identify time zone patterns
# Analyze business hours
# Check for holiday patterns
```

### Advanced CDN Analysis

```bash
# Map CDN edge server distribution
# Analyze CDN cache behavior
# Check for CDN configuration drift

# Identify CDN failover patterns
# Analyze CDN performance metrics
# Check for CDN security features

# Map CDN provider relationships
# Analyze CDN pricing models
# Check for CDN contract terms

# Identify CDN vendor lock-in
# Analyze CDN migration options
# Check for CDN redundancy
```

### Advanced DNS Analysis

```bash
# Map DNS infrastructure globally
# Analyze DNS propagation patterns
# Check for DNS configuration drift

# Identify DNS security gaps
# Analyze DNS performance metrics
# Check for DNS provider dependencies

# Map DNS failover configurations
# Analyze DNS caching behavior
# Check for DNS hijacking indicators

# Identify DNS configuration issues
# Analyze DNSSEC implementation
# Check for DNS-over-HTTPS support
```

### Advanced Compliance Analysis

```bash
# Map regulatory requirements globally
# Analyze compliance gaps
# Check for audit findings

# Identify compliance risks
# Analyze remediation requirements
# Check for compliance monitoring

# Map data residency requirements
# Analyze cross-border transfer policies
# Check for encryption requirements

# Identify incident reporting requirements
# Analyze data retention policies
# Check for privacy impact assessments
```

## Detection Evasion

### Avoiding Detection During Regional Analysis

```bash
# Use passive intelligence sources
# Avoid active scanning when possible

# Respect legal boundaries
# Work with legal counsel

# Protect sensitive information
# Limit access to compliance data

# Monitor for counter-intelligence
# Check for surveillance indicators

# Coordinate with regional teams
# Share threat intelligence responsibly
```

### Regional Security Considerations

```bash
# Monitor for government surveillance
# Check for censorship indicators

# Analyze political risk factors
# Check for sanctions compliance

# Identify export control requirements
# Check for technology transfer restrictions

# Map regional threat landscapes
# Analyze local threat actors
```

## Impact Assessment

### Regional Risk Categories

1. **Critical** - Immediate compliance violation
2. **High** - Significant security gap
3. **Medium** - Moderate compliance concern
4. **Low** - Minor regional variation
5. **Informational** - Observation only

### Impact Metrics

1. **Compliance** - Regulatory penalties
2. **Security** - Attack surface exposure
3. **Performance** - User experience impact
4. **Cost** - Infrastructure optimization
5. **Availability** - Service reliability

## Common Pitfalls

1. **Geolocation Inaccuracy** - IP geolocation not precise
2. **CDN Configuration Drift** - Inconsistent regional settings
3. **DNS Propagation Delays** - Changes not global
4. **Compliance Gaps** - Missing regional requirements
5. **Latency Assumptions** - Not measuring actual performance
6. **Regulatory Changes** - Missing new requirements
7. **Political Risk** - Not assessing regional stability
8. **Cultural Differences** - Not considering local preferences
9. **Language Barriers** - Not supporting local languages
10. **Time Zone Issues** - Not considering business hours
11. **Holiday Patterns** - Not accounting for regional holidays
12. **Infrastructure Maturity** - Assuming equal maturity globally
13. **Threat Landscape** - Not assessing regional threats
14. **Vendor Dependencies** - Not considering regional vendors
15. **Contractual Limitations** - Not reviewing regional contracts

## Integration Points

### Global Operations

- Include regional analysis in global strategy
- Track regional performance metrics
- Monitor regional compliance

### Security Operations

- Monitor regional security events
- Track regional threat intelligence
- Coordinate regional incident response

### Compliance Management

- Track regional regulatory requirements
- Monitor compliance status
- Report to regional regulators

### Performance Management

- Monitor regional performance metrics
- Track user experience
- Optimize regional infrastructure

## Reporting

### Regional Infrastructure Map Report

```markdown
# Regional Infrastructure Map - [Organization]

## Executive Summary
- Total Regions: [N]
- Primary Regions: [List]
- Key Findings: [Summary]

## Geographic Distribution
### Infrastructure Locations
| Region | Provider | Purpose | Compliance |
|--------|----------|---------|------------|
| [Region] | [Provider] | [Purpose] | [Compliance] |

### CDN Distribution
| Region | Edge Locations | Cache Policy | Security |
|--------|----------------|--------------|----------|
| [Region] | [Count] | [Policy] | [Security] |

## DNS Configuration
### Regional DNS
| Region | Provider | Security | Performance |
|--------|----------|----------|-------------|
| [Region] | [Provider] | [Security] | [Performance] |

### Geographic Routing
| Region | Target | Latency | Availability |
|--------|--------|---------|--------------|
| [Region] | [Target] | [Latency] | [Availability] |

## Security Analysis
### Regional Security Controls
| Region | WAF | DDoS | Rate Limiting | MFA |
|--------|-----|------|---------------|-----|
| [Region] | [WAF] | [DDoS] | [Rate Limit] | [MFA] |

### Compliance Status
| Region | Regulation | Status | Gaps |
|--------|------------|--------|------|
| [Region] | [Regulation] | [Status] | [Gaps] |

## Performance Analysis
### Latency Measurements
| Region | TTFB | Load Time | Availability |
|--------|------|-----------|--------------|
| [Region] | [TTFB] | [Load] | [Availability] |

### CDN Performance
| Region | Cache Hit | Bandwidth | Cost |
|--------|-----------|-----------|------|
| [Region] | [Hit] | [Bandwidth] | [Cost] |

## Risk Assessment
### Critical Findings
1. [Finding] - Impact: [Description]

### Recommendations
1. [Recommendation]
```

## Labs

### Lab 1: Geographic Infrastructure Discovery

Discover and map all regional infrastructure for a global organization.

**Objective:** Create comprehensive geographic infrastructure map.

### Lab 2: CDN Edge Server Analysis

Analyze CDN edge server distribution and configuration across regions.

**Objective:** Map CDN deployment and identify configuration differences.

### Lab 3: Regional Compliance Assessment

Assess compliance requirements and gaps across different regions.

**Objective:** Create regional compliance roadmap.

### Lab 4: Latency-Based Optimization

Measure and analyze latency across regions to optimize infrastructure.

**Objective:** Identify performance bottlenecks and optimization opportunities.

### Lab 5: Regional Security Policy Analysis

Analyze security policy differences across regions and identify gaps.

**Objective:** Create unified security policy recommendations.

## Ethics

### Responsible Regional Analysis

1. **Legal Compliance** - Adhere to all regional regulations
2. **Privacy Protection** - Protect personal information globally
3. **Cultural Sensitivity** - Respect regional differences
4. **Transparency** - Report findings honestly
5. **Professionalism** - Maintain ethical standards

### Stakeholder Communication

1. **Board Reporting** - Provide accurate global assessments
2. **Regional Reporting** - Meet regional disclosure requirements
3. **Team Communication** - Share relevant information
4. **Vendor Management** - Assess regional vendor risks
5. **Customer Protection** - Ensure global data security

## Cheat Sheet

### Geolocation Commands

```bash
# Basic Geolocation
curl -s "https://ipinfo.io/IP/json" | jq '.city, .country'

# Multiple Providers
curl -s "https://ipinfo.io/IP/json" | jq '.city, .country'
curl -s "http://ip-api.com/json/IP" | jq '.city, .country'

# Regional Analysis
for ip in $(dig A domain.com +short); do
    curl -s "https://ipinfo.io/$ip/json" | jq -r '[.city, .country] | @csv'
done
```

### CDN Analysis Commands

```bash
# CDN Detection
curl -sI https://domain.com | grep -iE "cf-ray|cdn|cloudfront|akamai"

# Edge Location Analysis
curl -sI https://domain.com | grep -i "x-amz-cf-pop\|x-edge"

# Cache Analysis
curl -sI https://domain.com | grep -iE "cache-control|etag|x-cache"
```

### DNS Analysis Commands

```bash
# Geographic DNS
dig A domain.com @8.8.8.8 +short
dig A domain.com @1.1.1.1 +short

# DNS Security
dig DNSKEY domain.com +short
dig DS domain.com +short

# DNS Performance
for resolver in 8.8.8.8 1.1.1.1; do
    dig A domain.com @$resolver +stats
done
```

### Latency Analysis Commands

```bash
# Basic Latency
ping -c 10 domain.com | tail -1

# HTTP Latency
curl -s -o /dev/null -w "TTFB: %{time_starttransfer}s\n" https://domain.com

# Traceroute
traceroute domain.com | tail -5
```

### Quick Regional Indicators

| Indicator | Region | Implication |
|-----------|--------|-------------|
| GDPR | EU | Privacy compliance |
| CCPA | California | Privacy compliance |
| PDPA | Singapore | Data protection |
| PIPEDA | Canada | Privacy compliance |
| LGPD | Brazil | Privacy compliance |
| CloudFront | Global | CDN deployment |
| Cloudflare | Global | CDN/security |
| Route 53 | AWS | DNS provider |
| Azure DNS | Azure | DNS provider |
