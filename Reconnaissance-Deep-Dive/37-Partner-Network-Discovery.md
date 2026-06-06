# 37 - Partner Network Discovery and Analysis

## Expert Role

You are a **Partner Network Intelligence Analyst** specializing in mapping organizational relationships through technical infrastructure. You combine DNS analysis, certificate intelligence, HTTP header forensics, and business intelligence to uncover hidden partner connections. Your expertise reveals supply chain risks, third-party integrations, and shared infrastructure that attackers exploit as trust boundaries. You understand that partner networks represent extended attack surfaces where security controls may be weaker.

## Core Concepts

### Partner Relationship Taxonomy

1. **Technology Partners** - Cloud providers, SaaS vendors, API integrations
2. **Service Partners** - Managed service providers, consultants, outsourced IT
3. **Business Partners** - Resellers, distributors, franchisees
4. **Integration Partners** - OAuth connections, webhook consumers, data processors
5. **Infrastructure Partners** - CDN providers, DNS hosts, certificate authorities

### DNS-Based Partner Discovery

DNS records reveal infrastructure relationships that business relationships hide. MX records expose email providers, NS records show DNS hosting, CNAME chains reveal CDN and cloud dependencies, and TXT records contain verification tokens linking to third-party services.

### Certificate-Based Discovery

Shared TLS certificates across domains indicate common ownership or hosting. Certificate Transparency logs provide historical partnership data. Certificate reuse patterns reveal infrastructure consolidation.

### HTTP Header Intelligence

Server headers, powered-by headers, and custom response headers leak technology stack information. CDN headers identify shared delivery networks. Security headers reveal WAF and protection providers.

### JavaScript Partner Mapping

External script sources expose third-party integrations. API endpoint patterns reveal backend service dependencies. Third-party library inclusion indicates technology partnerships.

## Prerequisites

1. Understanding of DNS record types and their implications
2. Certificate Transparency log access and interpretation
3. HTTP header analysis techniques
4. JavaScript analysis and third-party dependency mapping
5. Business intelligence gathering methodologies
6. WHOIS and corporate registry analysis
7. API reconnaissance fundamentals
8. Network infrastructure concepts (CDN, WAF, load balancing)
9. Subdomain enumeration proficiency
10. OSINT techniques for business relationship mapping
11. Tool proficiency (dig, curl, openssl, nmap)
12. Understanding of OAuth and webhook architectures
13. BGP and ASN analysis basics
14. Reverse DNS and forward DNS correlation
15. Network scanning and service identification
16. SSL/TLS certificate chain analysis
17. JavaScript deobfuscation basics
18. API endpoint discovery techniques
19. Web crawling and spidering concepts
20. Threat intelligence platform familiarity

## Methodology

### Phase 1: DNS-Based Partner Discovery

#### MX Record Analysis

MX records reveal email infrastructure partnerships. Map mail exchange priorities and identify third-party email providers.

```bash
# Query all MX records for target domain
dig MX targetdomain.com +short +noall +answer

# Query with full details
dig MX targetdomain.com +noall +answer

# Reverse lookup MX server IPs
dig -x $(dig MX targetdomain.com +short | head -1 | awk '{print $2}' | sed 's/\.$//') +short

# Bulk MX analysis across multiple domains
for domain in $(cat domains.txt); do
    echo "=== $domain ==="
    dig MX $domain +short
done

# Check for common email providers
dig MX targetdomain.com +short | grep -iE "google|microsoft|proofpoint|mimecast|barracuda|cloudflare"
```

#### NS Record Analysis

NS records identify DNS hosting partnerships and potential shared infrastructure.

```bash
# Query NS records
dig NS targetdomain.com +short +noall +answer

# Identify DNS provider from NS
dig NS targetdomain.com +short | grep -iE "cloudflare|aws|azure|google|rackspace|dyn|akamai"

# Check nameserver IP ranges
for ns in $(dig NS targetdomain.com +short | sed 's/\.$//'); do
    echo "NS: $ns"
    dig A $ns +short
    whois $(dig A $ns +short | head -1) | grep -i "orgname\|netname\|descr"
done

# Detect shared nameservers across targets
for domain in $(cat domains.txt); do
    echo "$domain: $(dig NS $domain +short | sort | tr '\n' ',')"
done
```

#### TXT Record Intelligence

TXT records contain SPF, DKIM, DMARC, and verification tokens that reveal third-party relationships.

```bash
# Query all TXT records
dig TXT targetdomain.com +short +noall +answer

# Extract SPF includes (third-party email senders)
dig TXT targetdomain.com +short | grep "v=spf1" | tr ' ' '\n' | grep "include:"

# Identify verification tokens
dig TXT targetdomain.com +short | grep -iE "google-site|facebook|apple|anthropic|openai|amazon"

# Check DKIM selectors
for selector in default google selector1 selector2 s1 s2 dkim; do
    result=$(dig TXT ${selector}._domainkey.targetdomain.com +short 2>/dev/null)
    if [ -n "$result" ]; then
        echo "DKIM $selector: $result"
    fi
done

# DMARC policy
dig TXT _dmarc.targetdomain.com +short

# Extract and resolve SPF includes
dig TXT targetdomain.com +short | grep "v=spf1" | grep -oP 'include:\K[^ ]+' | while read include; do
    dig TXT $include +short
done
```

#### CNAME Chain Analysis

CNAME records reveal CDN, cloud, and hosting partnerships through alias chains.

```bash
# Follow CNAME chains
dig CNAME targetdomain.com +short
dig CNAME www.targetdomain.com +short

# Recursive CNAME resolution
resolve_cname() {
    local domain=$1
    local cname=$(dig CNAME $domain +short 2>/dev/null | sed 's/\.$//')
    if [ -n "$cname" ]; then
        echo "$domain -> $cname"
        resolve_cname "$cname"
    else
        local ips=$(dig A $domain +short)
        echo "$domain -> IPs: $ips"
    fi
}
resolve_cname targetdomain.com

# Identify CDN from CNAME patterns
dig CNAME www.targetdomain.com +short | grep -iE "cdn|cloudfront|akamai|fastly|cloudflare|edgecast|limelight"

# Check for CNAME cloaking (hiding origin behind CDN)
dig A www.targetdomain.com +trace | tail -5
```

### Phase 2: Certificate-Based Partner Discovery

#### Certificate Transparency Log Mining

CT logs reveal certificate issuance patterns indicating hosting and domain relationships.

```bash
# Query crt.sh for certificates
curl -s "https://crt.sh/?q=%.targetdomain.com&output=json" | jq -r '.[].name_value' | sort -u

# Extract certificate details
curl -s "https://crt.sh/?q=%.targetdomain.com&output=json" | jq '.[] | {id: .id, name: .name_value, issuer: .issuer_name, not_before: .not_before, not_after: .not_after}'

# Find shared certificates
curl -s "https://crt.sh/?q=%.targetdomain.com&output=json" | jq -r '.[].issuer_name' | sort | uniq -c | sort -rn

# Search for certificate reuse across domains
for domain in $(cat domains.txt); do
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sort -u > /tmp/certs_$domain.txt
done

# Analyze certificate timeline
curl -s "https://crt.sh/?q=%.targetdomain.com&output=json" | jq -r '[.[] | .not_before] | sort | .[0], .[-1]'
```

#### Direct Certificate Inspection

```bash
# Extract certificate from live server
echo | openssl s_client -connect targetdomain.com:443 -servername targetdomain.com 2>/dev/null | openssl x509 -noout -text

# Get Subject Alternative Names (SANs) - reveals related domains
echo | openssl s_client -connect targetdomain.com:443 -servername targetdomain.com 2>/dev/null | openssl x509 -noout -ext subjectAltName

# Certificate fingerprint comparison
echo | openssl s_client -connect targetdomain.com:443 -servername targetdomain.com 2>/dev/null | openssl x509 -noout -fingerprint -sha256

# Compare certificates across multiple hosts
for host in www.targetdomain.com api.targetdomain.com cdn.targetdomain.com; do
    echo "=== $host ==="
    echo | openssl s_client -connect $host:443 -servername $host 2>/dev/null | openssl x509 -noout -fingerprint -sha256
done

# Check certificate chain for shared intermediates
echo | openssl s_client -connect targetdomain.com:443 -servername targetdomain.com -showcerts 2>/dev/null | grep -A1 "Certificate chain"
```

### Phase 3: HTTP Header Partner Discovery

#### Server and Technology Headers

```bash
# Capture all response headers
curl -sI https://targetdomain.com | head -50

# Extract specific technology indicators
curl -sI https://targetdomain.com | grep -iE "server|x-powered|x-aspnet|x-runtime|x-generator|x-drupal|x-wordpress|x-shopify|x-wix|x-squarespace"

# CDN identification headers
curl -sI https://targetdomain.com | grep -iE "cf-ray|cdn|akamai|x-cache|x-served-by|x-varnish|via|x-cdn|x-edge"

# WAF detection headers
curl -sI https://targetdomain.com | grep -iE "x-sucuri|x-akamai-security|x-protected-by|x-waf"

# Security header analysis (reveals security vendor)
curl -sI https://targetdomain.com | grep -iE "strict-transport|x-content-type|x-frame|x-xss|content-security-policy|expect-ct"

# Bulk header analysis
for host in $(cat hosts.txt); do
    echo "=== $host ==="
    curl -sI "https://$host" | grep -iE "server|x-powered|cf-ray|cdn|via|x-cache"
done
```

#### Custom Partner Headers

```bash
# Identify custom headers (non-standard)
curl -sI https://targetdomain.com | grep -vE "^(HTTP|Content-Type|Content-Length|Date|Connection|Cache-Control|Set-Cookie|Vary|X-|Via|Server|CF-)" | head -20

# Check for partner-specific headers
curl -sI https://targetdomain.com | grep -iE "x-request-id|x-trace|x-correlation|x-partner|x-integration|x-vendor"

# Analyze Set-Cookie domains (cross-domain partnerships)
curl -sI https://targetdomain.com | grep -i "set-cookie" | grep -oP 'domain=\K[^;]+'

# Check for iframe restrictions (content partnerships)
curl -sI https://targetdomain.com | grep -i "x-frame-options\|content-security-policy" | grep -i "allow"
```

### Phase 4: JavaScript Partner Discovery

#### External Script Source Mapping

```bash
# Extract all external script sources
curl -s https://targetdomain.com | grep -oP 'src="https?://[^"]+' | sed 's/src="//' | sort -u

# Identify third-party scripts by domain
curl -s https://targetdomain.com | grep -oP 'https?://[^/"]+' | sort | uniq -c | sort -rn

# Map JavaScript dependencies
curl -s https://targetdomain.com | grep -oP 'https?://[^"]+\.js' | sort -u > js_deps.txt

# Analyze script loading patterns
curl -s https://targetdomain.com | grep -B2 -A2 '<script' | grep -iE "async|defer|crossorigin|integrity"

# Check for third-party tracking/analytics
curl -s https://targetdomain.com | grep -iE "google-analytics|gtag|hotjar|segment|mixpanel|amplitude|heap|pendo|intercom|drift|crisp|zendesk"

# Bulk JS partner analysis
for page in $(cat pages.txt); do
    echo "=== $page ==="
    curl -s "$page" | grep -oP 'https?://[^"]+\.js' | grep -v "$page" | sort -u
done
```

#### API Endpoint Discovery

```bash
# Extract API endpoints from JavaScript
curl -s https://targetdomain.com | grep -oP 'https?://[^"]+api[^"]*' | sort -u

# Find fetch/axios/XMLHttpRequest patterns
curl -s https://targetdomain.com | grep -oP '(fetch|axios|XMLHttpRequest|\.get|\.post)\s*\(\s*["\x27][^"]+["\x27]' | sort -u

# Identify GraphQL endpoints
curl -s https://targetdomain.com | grep -i "graphql\|gql"

# Discover API base URLs
curl -s https://targetdomain.com | grep -oP 'https?://[^"]+/api/[^"]*' | sort -u

# Check for API documentation links
curl -s https://targetdomain.com | grep -iE "swagger|openapi|api-doc|documentation|postman" | grep -oP 'https?://[^"]+'

# Analyze webpack chunk loading (reveals microservices)
curl -s https://targetdomain.com | grep -oP 'https?://[^"]+chunk[^"]*\.js' | sort -u
```

### Phase 5: Business Relationship Discovery

#### LinkedIn and Corporate Intelligence

```bash
# Search for partnership announcements
# Use Google dorking for partner mentions
site:linkedin.com "targetdomain" "partner" OR "integration" OR "powered by"
site:linkedin.com "targetdomain" "technology partner" OR "strategic partner"

# Press release analysis
site:targetdomain.com/press OR site:targetdomain.com/news "partner" OR "integration"

# Check partnership pages
curl -s https://targetdomain.com/partners | grep -oP 'https?://[^"]+' | sort -u
curl -s https://targetdomain.com/integrations | grep -oP 'https?://[^"]+' | sort -u
curl -s https://targetdomain.com/partnership | grep -oP 'https?://[^"]+' | sort -u

# Identify vendor logos and links
curl -s https://targetdomain.com/partners | grep -oP 'https?://[^"]+' | grep -v "targetdomain" | sort -u

# Check for case studies and testimonials
curl -s "https://targetdomain.com/case-studies" | grep -oP 'https?://[^"]+' | sort -u
```

### Phase 6: Integration Point Discovery

#### Webhook and OAuth Discovery

```bash
# Discover OAuth callback URLs
curl -s https://targetdomain.com | grep -oP 'https?://[^"]+callback[^"]*' | sort -u
curl -s https://targetdomain.com | grep -oP 'https?://[^"]+oauth[^"]*' | sort -u

# Check for webhook endpoints
curl -s https://targetdomain.com | grep -iE "webhook|hook|callback|notify" | grep -oP 'https?://[^"]+' | sort -u

# Analyze OAuth provider configuration
curl -s https://targetdomain.com/.well-known/openid-configuration 2>/dev/null | jq .
curl -s https://targetdomain.com/.well-known/oauth-authorization-server 2>/dev/null | jq .

# Discover integration marketplace
curl -s https://targetdomain.com/integrations | grep -oP 'href="[^"]+' | sort -u
curl -s https://targetdomain.com/marketplace | grep -oP 'href="[^"]+' | sort -u
curl -s https://targetdirectory.com | grep -i "targetdomain" | grep -oP 'href="[^"]+'

# Check for API keys in public code
site:github.com "targetdomain" "api_key\|apikey\|secret\|token"
```

### Phase 7: Partner API Mapping

```bash
# Discover API versions
curl -s https://api.targetdomain.com/v1 2>/dev/null | head -20
curl -s https://api.targetdomain.com/v2 2>/dev/null | head -20
curl -s https://api.targetdomain.com/v3 2>/dev/null | head -20

# Check API documentation
curl -s https://api.targetdomain.com/docs 2>/dev/null | head -50
curl -s https://api.targetdomain.com/swagger.json 2>/dev/null | jq .
curl -s https://api.targetdomain.com/openapi.json 2>/dev/null | jq .

# Identify partner-specific API endpoints
curl -s https://api.targetdomain.com/partners 2>/dev/null | head -20
curl -s https://api.targetdomain.com/integrations 2>/dev/null | head -20

# Rate limit analysis (reveals API tier/partner level)
for i in $(seq 1 20); do
    curl -sI https://api.targetdomain.com/endpoint | grep -i "x-rate\|retry-after\|x-ratelimit"
done
```

### Phase 8: Shared Infrastructure Analysis

```bash
# IP range ownership analysis
whois $(dig A targetdomain.com +short | head -1) | grep -iE "orgname|netname|descr|cidr|range"

# BGP prefix analysis
curl -s "https://api.bgpview.io/ips/$(dig A targetdomain.com +short | head -1)/prefixes" | jq '.data.prefixes[] | {prefix: .prefix, name: .name, description: .description}'

# Reverse IP lookup (shared hosting detection)
for ip in $(dig A targetdomain.com +short); do
    echo "=== $ip ==="
    curl -s "https://api.hackertarget.com/reverseiplookup/?q=$ip" | head -20
done

# ASN analysis
curl -s "https://api.bgpview.io/ips/$(dig A targetdomain.com +short | head -1)" | jq '.data.asns[]'

# Shared hosting detection
curl -s "https://api.hackertarget.com/hostsearch/?q=targetdomain.com" | head -20

# SSL certificate reuse across IPs
for ip in $(dig A targetdomain.com +short); do
    echo "IP: $ip"
    echo | openssl s_client -connect $ip:443 -servername targetdomain.com 2>/dev/null | openssl x509 -noout -ext subjectAltName 2>/dev/null
done
```

## Tool Arsenal

### DNS Analysis Tools
- **dig** - DNS lookup utility
- **dnsenum** - DNS enumeration tool
- **dnsrecon** - DNS reconnaissance
- **fierce** - Domain scanner
- **subfinder** - Subdomain discovery

### Certificate Analysis
- **crt.sh** - Certificate Transparency search
- **SSL Labs** - SSL server test
- **testssl.sh** - SSL/TLS testing
- **sslyze** - SSL/TLS configuration analyzer

### HTTP Analysis
- **curl** - HTTP client
- **httpx** - HTTP probing
- **whatweb** - Web technology identification
- **wappalyzer** - Technology profiler
- **builtwith** - Technology lookup

### JavaScript Analysis
- **LinkFinder** - JS endpoint discovery
- **SecretFinder** - JS secret detection
- **JSFinder** - JS URL extraction
- **retire.js** - Vulnerability detection

### OSINT Tools
- **theHarvester** - Email and subdomain harvester
- **Maltego** - Link analysis
- **SpiderFoot** - Reconnaissance automation
- **Recon-ng** - Reconnaissance framework

### Network Analysis
- **nmap** - Network scanner
- **masscan** - Port scanner
- **bgpview** - BGP data API
- **RIPEstat** - Network info API

### Business Intelligence
- **Crunchbase** - Company data
- **LinkedIn** - Professional network
- **Glassdoor** - Company reviews
- **SEC EDGAR** - Financial filings

## Case Studies

### Case Study 1: Cloud Provider Partnership Discovery

A target domain used AWS CloudFront with custom CNAME pointing to `.cloudfront.net`. CT log analysis revealed certificates for multiple related domains all using the same CloudFront distribution pattern. MX records showed AWS SES for email. This revealed a complete AWS partnership with shared infrastructure.

**Discovery Chain:**
1. CNAME analysis → CloudFront CDN
2. MX records → AWS SES
3. TXT records → AWS verification tokens
4. CT logs → Shared certificate patterns
5. IP analysis → AWS IP ranges

### Case Study 2: Hidden SaaS Integration

JavaScript analysis revealed external scripts from a third-party analytics provider. Further investigation of the provider's domains showed they had access to the target's user data through their integration. The provider's own security posture was weaker than the target's.

**Discovery Chain:**
1. JS extraction → Third-party analytics script
2. Script analysis → Data collection endpoints
3. Provider investigation → Weaker security controls
4. OAuth analysis → Excessive permissions granted
5. Webhook discovery → Real-time data exfiltration

### Case Study 3: Email Infrastructure Risk

MX records revealed a managed email security provider. Investigation showed the provider had access to all inbound email for phishing analysis. Their own infrastructure had outdated TLS configurations. This created a supply chain risk where compromising the email provider could affect all email communications.

**Discovery Chain:**
1. MX records → Managed email provider
2. Provider analysis → Weak TLS configuration
3. Access model analysis → Full email access
4. Risk assessment → Supply chain vulnerability
5. Remediation → Encryption and access controls

### Case Study 4: CDN Provider Shared Certificates

CT logs revealed that multiple domains from different companies shared the same TLS certificates through a CDN provider. This certificate sharing created a potential for domain confusion attacks and revealed the CDN provider's infrastructure patterns.

**Discovery Chain:**
1. CT log mining → Shared certificates
2. Certificate analysis → CDN provider identification
3. Domain correlation → Multiple organizations
4. Infrastructure mapping → Shared edge servers
5. Security implications → Certificate confusion risk

### Case Study 5: OAuth Integration Over-Permissioning

OAuth callback URL analysis revealed that a third-party integration had excessive permissions. The integration could access user data across all organization accounts. The OAuth token had no expiration and could not be revoked through the target's admin interface.

**Discovery Chain:**
1. OAuth discovery → Third-party callback URLs
2. Permission analysis → Excessive scope grants
3. Token analysis → No expiration
4. Revocation analysis → No admin control
5. Risk assessment → Persistent data access

## Advanced Techniques

### Cross-Domain Correlation

```bash
# Find domains sharing the same Google Analytics ID
curl -s https://targetdomain.com | grep -oP 'UA-\d+-\d+|G-[A-Z0-9]+'

# Find domains sharing the same Google Tag Manager ID
curl -s https://targetdomain.com | grep -oP 'GTM-[A-Z0-9]+'

# Find domains sharing the same Facebook Pixel ID
curl -s https://targetdomain.com | grep -oP 'fbq\("[^"]+",\s*"[^"]+"'

# Find domains sharing the same Mixpanel token
curl -s https://targetdomain.com | grep -oP 'mixpanel\.init\("[^"]+"'

# Find domains sharing the same Segment write key
curl -s https://targetdomain.com | grep -oP 'analytics\.load\("[^"]+"'
```

### Infrastructure Fingerprinting

```bash
# Identify hosting provider from IP
for ip in $(dig A targetdomain.com +short); do
    echo "IP: $ip"
    curl -s "https://ipinfo.io/$ip/json" | jq '.org, .city, .region, .country'
done

# Identify cloud provider from IP ranges
# AWS: 3.0.0.0/8, 52.0.0.0/8, 54.0.0.0/8
# Azure: 13.0.0.0/8, 40.0.0.0/8, 52.0.0.0/8
# GCP: 34.0.0.0/8, 35.0.0.0/8

# Check for load balancer fingerprints
curl -sI https://targetdomain.com | grep -iE "x-amzn|awselb|bigip|f5|citrix|kemp|haproxy"
```

### Partner API Abuse Testing

```bash
# Test partner API rate limits
for i in $(seq 1 100); do
    response=$(curl -sI "https://api.targetdomain.com/partner/endpoint" | head -1)
    echo "$i: $response"
    if echo "$response" | grep -q "429"; then
        echo "Rate limit hit at request $i"
        break
    fi
done

# Test partner API authentication bypass
curl -s https://api.targetdomain.com/partner/data | head -20
curl -s -H "Authorization: Bearer test" https://api.targetdomain.com/partner/data | head -20
curl -s -H "X-Partner-Id: test" https://api.targetdomain.com/partner/data | head -20

# Check for partner API versioning
for version in v1 v2 v3; do
    echo "=== $version ==="
    curl -sI "https://api.targetdomain.com/$version/" | head -5
done
```

### Supply Chain Risk Analysis

```bash
# Analyze JavaScript dependencies for vulnerabilities
curl -s https://targetdomain.com | grep -oP 'https?://[^"]+\.js' | while read js; do
    echo "=== $js ==="
    curl -s "$js" | grep -oP 'version["\x27:]+["\x27]?\K[^"\x27,]+' | head -5
done

# Check for known vulnerable libraries
curl -s https://targetdomain.com | grep -iE "jquery-[0-9]|bootstrap-[0-9]|angular-[0-9]|react-[0-9]" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+'

# Analyze package.json if exposed
curl -s https://targetdomain.com/package.json 2>/dev/null | jq '.dependencies'
curl -s https://targetdomain.com/package-lock.json 2>/dev/null | jq '.dependencies | keys' | head -20
```

## Detection Evasion

### Avoiding Detection During Partner Discovery

```bash
# Use multiple source IPs for enumeration
# Rotate through proxy list
while read proxy; do
    curl -x "$proxy" -s "https://crt.sh/?q=%.targetdomain.com&output=json" | jq '.[].name_value' | sort -u
done < proxies.txt

# Rate limit requests to avoid blocks
sleep $((RANDOM % 5 + 1))

# Use passive DNS sources
curl -s "https://dns.bufferover.run/dns?q=.targetdomain.com" | jq -r '.A_records[].ip_domain' | sort -u

# Use Threat Intelligence Platforms
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/targetdomain.com/passive_dns" | jq '.passive_dns[] | {hostname: .hostname, record: .record}'
```

### Passive Enumeration Techniques

```bash
# Use search engines for passive discovery
# Google dorking for partner mentions
site:targetdomain.com inurl:partner
site:targetdomain.com inurl:integration
site:targetdomain.com inurl:api
site:targetdomain.com "powered by"
site:targetdomain.com "integrated with"

# Use Shodan for passive service discovery
curl -s "https://api.shodan.io/dns/domain/targetdomain.com?key=API_KEY" | jq '.data[]'

# Use Censys for certificate discovery
curl -s "https://search.censys.io/api/v2/search/certificates?q=targetdomain.com" | jq '.result.hits[]'
```

## Impact Assessment

### Partner Risk Categories

1. **Critical Partners** - Direct access to sensitive data or systems
2. **High-Risk Partners** - Access to user data or business processes
3. **Medium-Risk Partners** - Limited integration with specific systems
4. **Low-Risk Partners** - Marketing or analytics integrations
5. **Informational Partners** - Public relationship with no technical integration

### Risk Indicators

1. **Excessive Permissions** - Partner has more access than needed
2. **Weak Authentication** - Partner uses weak or no authentication
3. **Shared Credentials** - Multiple partners use same credentials
4. **No Rotation** - Partner credentials never rotated
5. **No Monitoring** - Partner access not logged or monitored

## Common Pitfalls

1. **Incomplete DNS Analysis** - Missing MX, TXT, or CNAME records
2. **Certificate Blindness** - Not analyzing CT logs for historical data
3. **JavaScript Dependency** - Not mapping all external script sources
4. **API Discovery Gaps** - Missing versioned or undocumented endpoints
5. **Business Intelligence** - Not correlating technical findings with business relationships
6. **Assumption of Security** - Assuming partners have same security standards
7. **Missing Webhook Discovery** - Not identifying all integration points
8. **OAuth Scope Analysis** - Not reviewing granted permissions
9. **Shared Infrastructure** - Missing common IP ranges or certificates
10. **Rate Limit Awareness** - Not respecting API rate limits
11. **Passive vs Active** - Using active scanning when passive is sufficient
12. **Documentation Gaps** - Not recording partnership details
13. **Risk Assessment** - Not categorizing partners by risk level
14. **Monitoring Setup** - Not establishing ongoing partner monitoring
15. **Incident Response** - Not planning for partner-related incidents

## Integration Points

### SIEM Integration

- Log partner API access patterns
- Alert on unusual partner data access
- Correlate partner activity with security events

### Threat Intelligence

- Monitor partner domains for compromise
- Track partner certificates for anomalies
- Correlate partner infrastructure with threat indicators

### Asset Management

- Maintain partner inventory
- Track partner API versions
- Monitor partner security posture

### Risk Management

- Assess partner risk ratings
- Track partner compliance status
- Document partner security requirements

## Reporting

### Partner Network Report Template

```markdown
# Partner Network Analysis Report - [Target Organization]

## Executive Summary
- Total Partners Identified: [N]
- Critical Partners: [N]
- High-Risk Partners: [N]
- Key Findings: [Summary]

## Partner Inventory
| Partner | Type | Integration | Risk Level | Data Access |
|---------|------|-------------|------------|-------------|
| [Name] | [Type] | [Method] | [Risk] | [Access] |

## Technical Findings
### DNS-Based Discoveries
- MX Record Partners: [List]
- NS Record Partners: [List]
- CNAME Partners: [List]

### Certificate-Based Discoveries
- Shared Certificates: [List]
- Certificate Providers: [List]

### Integration Discoveries
- OAuth Connections: [List]
- Webhook Integrations: [List]
- API Partners: [List]

## Risk Assessment
### Critical Findings
1. [Finding] - Impact: [Description]

### Recommendations
1. [Recommendation]
```

## Labs

### Lab 1: Partner Discovery Challenge

Given a target domain, discover all technology partners through DNS, certificate, and HTTP header analysis.

**Objective:** Map complete partner ecosystem from technical indicators.

### Lab 2: OAuth Integration Analysis

Analyze OAuth configurations to identify third-party integrations and assess permission levels.

**Objective:** Identify over-permissioned integrations and potential data exposure.

### Lab 3: JavaScript Dependency Mapping

Map all external JavaScript dependencies and identify potential supply chain risks.

**Objective:** Create complete dependency map with vulnerability assessment.

### Lab 4: Certificate Relationship Analysis

Use Certificate Transparency logs to discover related domains and shared infrastructure.

**Objective:** Identify domain relationships through certificate analysis.

### Lab 5: Partner Risk Assessment

Conduct comprehensive risk assessment of discovered partners based on access levels and security posture.

**Objective:** Create prioritized partner risk inventory.

## Ethics

### Responsible Partner Discovery

1. **Scope Compliance** - Only discover partners within authorized scope
2. **Data Handling** - Handle partner information responsibly
3. **Disclosure** - Report critical partner risks to appropriate parties
4. **Privacy** - Protect partner contact information
5. **Legal Compliance** - Adhere to data protection regulations

### Partner Notification

1. **Risk Communication** - Notify partners of discovered vulnerabilities
2. **Coordinated Disclosure** - Work with partners on remediation
3. **Documentation** - Record all partner communications
4. **Follow-up** - Verify remediation completion

## Cheat Sheet

### DNS Partner Discovery Commands

```bash
# MX Records
dig MX targetdomain.com +short

# NS Records
dig NS targetdomain.com +short

# TXT Records (SPF, DKIM, DMARC)
dig TXT targetdomain.com +short
dig TXT _dmarc.targetdomain.com +short

# CNAME Analysis
dig CNAME www.targetdomain.com +short
```

### Certificate Analysis Commands

```bash
# CT Log Search
curl -s "https://crt.sh/?q=%.targetdomain.com&output=json"

# Live Certificate Inspection
echo | openssl s_client -connect targetdomain.com:443 -servername targetdomain.com 2>/dev/null | openssl x509 -noout -text

# SAN Extraction
echo | openssl s_client -connect targetdomain.com:443 -servername targetdomain.com 2>/dev/null | openssl x509 -noout -ext subjectAltName
```

### HTTP Header Analysis Commands

```bash
# Full Headers
curl -sI https://targetdomain.com

# Technology Identification
curl -sI https://targetdomain.com | grep -iE "server|x-powered|x-generator"

# CDN Detection
curl -sI https://targetdomain.com | grep -iE "cf-ray|cdn|via|x-cache"
```

### JavaScript Analysis Commands

```bash
# Extract Script Sources
curl -s https://targetdomain.com | grep -oP 'src="https?://[^"]+'

# API Endpoint Discovery
curl -s https://targetdomain.com | grep -oP 'https?://[^"]+api[^"]*'

# Third-Party Tracking
curl -s https://targetdomain.com | grep -iE "analytics|tracking|pixel"
```

### Quick Partner Indicators

| Record Type | Partner Indicator | Example |
|------------|-------------------|---------|
| MX | Email provider | Google, Microsoft, Proofpoint |
| NS | DNS provider | Cloudflare, AWS Route53 |
| TXT | Third-party services | SPF includes, verification tokens |
| CNAME | CDN/Cloud | CloudFront, Fastly, Cloudflare |
| Certificate | Hosting provider | Let's Encrypt, DigiCert |
| Header | Technology stack | nginx, Apache, IIS |
| JavaScript | Integrations | Analytics, chat, support |
