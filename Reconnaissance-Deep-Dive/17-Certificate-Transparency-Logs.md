# 17. Certificate Transparency Log Analysis

## Expert Role Definition

You are a specialized security researcher focusing on Certificate Transparency (CT) log analysis for reconnaissance. You understand that CT logs provide a publicly accessible, append-only record of all SSL/TLS certificates issued by Certificate Authorities, making them an invaluable resource for discovering subdomains, identifying infrastructure, and monitoring certificate issuance. You can query CT logs through multiple interfaces, analyze certificate fields for intelligence, and set up monitoring for new certificate issuances. You approach CT log analysis with the systematic precision of a certificate auditor and the creative thinking of an attacker. You know that certificates contain rich information beyond the domain name including organization details, validation levels, and certificate chains that reveal infrastructure relationships. You maintain expertise in CT log APIs, certificate analysis techniques, and monitoring strategies. You understand that CT logs are not just for certificate verification but are a goldmine for passive reconnaissance that reveals the complete attack surface of an organization without directly interacting with the target. You think like a certificate authority that issues certificates and like an attacker who uses certificate information for targeting.

## Core Concepts

### Certificate Transparency Fundamentals

Certificate Transparency is a system for monitoring and auditing SSL/TLS certificate issuance. All major Certificate Authorities are required to log certificates to public CT logs.

**CT Log Structure**: CT logs are append-only data structures that store certificates in Merkle trees. Each log entry contains the certificate, timestamp, and entry identifier. The Merkle tree structure ensures log integrity and prevents tampering.

**Certificate Fields**: CT log entries contain rich information:
- **Subject Alternative Name (SAN)**: All domain names covered by the certificate
- **Common Name (CN)**: Primary domain name
- **Issuer Information**: Certificate Authority details
- **Validity Period**: Certificate expiration dates
- **Serial Number**: Unique certificate identifier
- **Public Key**: Certificate public key

**CT Log Sources**: Multiple CT log interfaces exist:
- **crt.sh**: Web interface and API for querying CT logs
- **CertSpotter**: CT log monitoring service
- **Google CT**: Google CT log search
- **Facebook CT**: Facebook CT monitoring

### CT Log Reconnaissance Value

CT logs provide unique reconnaissance value:
- **Subdomain Discovery**: Certificates often cover multiple subdomains not found through other enumeration techniques
- **Infrastructure Mapping**: Certificate chains reveal relationships between servers and services
- **Organization Intelligence**: Organization names and locations in certificates provide organizational context
- **Technology Fingerprinting**: Certificate types and configurations reveal technology choices
- **Temporal Analysis**: Certificate issuance dates reveal deployment and migration patterns

### CT Log Monitoring

Continuous monitoring of CT logs provides real-time intelligence:
- **New Subdomain Discovery**: Monitor for certificates covering new subdomains
- **Certificate Expiration Tracking**: Track certificate expiration for potential takeover opportunities
- **Infrastructure Changes**: Monitor certificate changes that indicate infrastructure modifications
- **Unauthorized Issuance**: Detect certificates issued without authorization

### CT Log API Usage

Programmatic access to CT logs enables automated reconnaissance:
- **crt.sh API**: RESTful API for querying CT logs
- **CertSpotter API**: Monitoring and alerting API
- **Custom Queries**: API parameters for targeted searches
- **Bulk Analysis**: Processing large volumes of certificate data

## Pre-requisite Knowledge

Before mastering CT log analysis, you should understand SSL/TLS certificate fundamentals including certificate structure and validation. Knowledge of Certificate Authorities and their operations is essential. Familiarity with DNS and subdomain enumeration provides context for certificate analysis. Understanding of web APIs and JSON data structures enables programmatic CT log access.

## Step-by-Step Methodology

### Phase 1: Basic CT Log Querying

Start with basic CT log queries to gather initial information.

```bash
# Query crt.sh for domain
curl -s "https://crt.sh/?q=%.target.com&output=json"

# Query specific domain
curl -s "https://crt.sh/?q=target.com&output=json"

# Parse JSON output
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u

# Extract unique subdomains
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//' | sort -u > subdomains.txt
```

### Phase 2: Certificate Field Analysis

Analyze certificate fields for intelligence.

```bash
# Extract organization information
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[] | {name: .name_value, issuer: .issuer_name, not_before: .not_before, not_after: .not_after}'

# Extract certificate chains
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].issuer_name' | sort | uniq -c | sort -rn

# Analyze validity periods
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '[.[] | {not_before: .not_before, not_after: .not_after}] | sort_by(.not_before)'
```

### Phase 3: Certificate-Based Subdomain Discovery

Use CT logs for comprehensive subdomain discovery.

```bash
# Using subfinder with CT logs
subfinder -d target.com -all

# Using amass with CT sources
amass enum -d target.com -src

# Custom CT log parser
python3 -c "
import requests, json
target = 'target.com'
url = f'https://crt.sh/?q=%.{target}&output=json'
r = requests.get(url)
certs = json.loads(r.text)
subdomains = set()
for cert in certs:
    for name in cert['name_value'].split('\n'):
        subdomains.add(name.strip())
for subdomain in sorted(subdomains):
    print(subdomain)
"
```

### Phase 4: CT Log Monitoring Setup

Set up continuous monitoring for new certificates.

```bash
# Using CertSpotter
curl -s "https://api.certspotter.com/v1/issuances?domain=target.com&include_subdomains=true&expand=dns_names"

# Custom monitoring script
python3 -c "
import requests, json, time
target = 'target.com'
known_certs = set()
while True:
    url = f'https://crt.sh/?q=%.{target}&output=json'
    r = requests.get(url)
    certs = json.loads(r.text)
    for cert in certs:
        cert_id = cert['id']
        if cert_id not in known_certs:
            print(f'New certificate: {cert[\"name_value\"]}')
            known_certs.add(cert_id)
    time.sleep(3600)
"
```

### Phase 5: CT Log for Bug Bounty

Use CT logs for bug bounty reconnaissance.

```bash
# Find subdomains for bug bounty programs
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//' | sort -u > bug_bounty_subdomains.txt

# Filter for specific subdomains
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | grep -E "^(api|dev|staging|admin)\." | sort -u

# Find expired certificates
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[] | select(.not_after < now) | .name_value' | sort -u
```

### Phase 6: Certificate Analysis for Infrastructure

Analyze certificates to map infrastructure.

```bash
# Extract IP addresses from certificates
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].common_name' | while read domain; do
    dig +short $domain A
done | sort -u

# Analyze certificate chains
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].issuer_name' | sort | uniq -c | sort -rn

# Find wildcard certificates
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | grep "^\*\.target.com$"
```

### Phase 7: Advanced CT Log Queries

Perform advanced CT log queries for specific intelligence.

```bash
# Search for specific subdomains
curl -s "https://crt.sh/?q=admin.target.com&output=json"

# Search for organization name
curl -s "https://crt.sh/?q=Organization+Target+Corp&output=json"

# Search for specific certificate types
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[] | select(.entry_type == "precert") | .name_value'

# Search for certificates with specific SANs
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | grep -E "^(api|dev|staging)\." | sort -u
```

### Phase 8: CT Log Analysis Script

Create comprehensive CT log analysis script.

```bash
#!/bin/bash
# ct_analysis.sh - Certificate Transparency analysis
TARGET=$1
echo "=== CT Log Analysis for $TARGET ==="

# Query CT logs
echo -e "\n[*] Querying CT logs..."
curl -s "https://crt.sh/?q=%.$TARGET&output=json" > /tmp/ct_results.json

# Extract subdomains
echo -e "\n[*] Extracting subdomains..."
cat /tmp/ct_results.json | jq -r '.[].name_value' | sed 's/\*\.//' | sort -u > /tmp/subdomains.txt
echo "[+] Found $(wc -l < /tmp/subdomains.txt) unique subdomains"

# Analyze certificates
echo -e "\n[*] Analyzing certificates..."
cat /tmp/ct_results.json | jq -r '.[] | "\(.name_value) | \(.issuer_name) | \(.not_before) | \(.not_after)"' | head -20

# Find expired certificates
echo -e "\n[*] Finding expired certificates..."
cat /tmp/ct_results.json | jq -r '.[] | select(.not_after < now) | .name_value' | sort -u

# Find wildcard certificates
echo -e "\n[*] Finding wildcard certificates..."
cat /tmp/ct_results.json | jq -r '.[].name_value' | grep "^\*\." | sort -u
```

## Tool Arsenal with Exact Commands

### crt.sh

```bash
# Basic query
curl -s "https://crt.sh/?q=%.target.com&output=json"

# Parse subdomains
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u

# Extract unique subdomains
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//' | sort -u > subdomains.txt
```

### CertSpotter

```bash
# Query CertSpotter API
curl -s "https://api.certspotter.com/v1/issuances?domain=target.com&include_subdomains=true&expand=dns_names"

# Parse results
curl -s "https://api.certspotter.com/v1/issuances?domain=target.com&include_subdomains=true&expand=dns_names" | jq -r '.[].dns_names[]' | sort -u
```

### Google CT

```bash
# Query Google CT
curl -s "https://www.google.com/transparencylog/api/v1/issuances?domain=target.com"

# Parse results
curl -s "https://www.google.com/transparencylog/api/v1/issuances?domain=target.com" | jq -r '.[].dns_names[].value' | sort -u
```

### Python Scripts

```bash
# CT log analyzer
python3 -c "
import requests, json
target = 'target.com'
url = f'https://crt.sh/?q=%.{target}&output=json'
r = requests.get(url)
certs = json.loads(r.text)
subdomains = set()
for cert in certs:
    for name in cert['name_value'].split('\n'):
        subdomains.add(name.strip())
for subdomain in sorted(subdomains):
    print(subdomain)
"

# Certificate expiration monitor
python3 -c "
import requests, json
from datetime import datetime
target = 'target.com'
url = f'https://crt.sh/?q=%.{target}&output=json'
r = requests.get(url)
certs = json.loads(r.text)
for cert in certs:
    not_after = datetime.strptime(cert['not_after'], '%Y-%m-%dT%H:%M:%S')
    if not_after < datetime.now():
        print(f'EXPIRED: {cert[\"name_value\"]} (expired: {cert[\"not_after\"]})')
    else:
        days_left = (not_after - datetime.now()).days
        print(f'VALID: {cert[\"name_value\"]} (expires in {days_left} days)')
"
```

### CT Log Monitoring Tools

```bash
# using certspotter CLI
certspotter --domain target.com

# Monitor with curl and cron
echo "0 * * * * curl -s 'https://crt.sh/?q=%.target.com&output=json' | jq -r '.[].name_value' | sort -u > /tmp/ct_monitor.txt" | crontab -

# Bulk CT log query
for domain in target1.com target2.com target3.com; do
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//' | sort -u
done
```

## Real-World Case Studies

### Case Study 1: Subdomain Discovery Through CT Logs

During a bug bounty engagement, I used CT log analysis to discover 47 subdomains of the target domain. Standard subdomain enumeration tools found only 23 subdomains. The additional 24 subdomains discovered through CT logs included internal development servers, staging environments, and API endpoints. Three of these subdomains were vulnerable to SQL injection, and one contained an exposed admin panel. The CT logs were effective because the target used wildcard certificates that covered all subdomains, and each subdomain had its own certificate with SAN entries.

### Case Study 2: Certificate Expiration for Subdomain Takeover

CT log analysis revealed that several subdomains had expired certificates. Investigation showed that these subdomains were pointing to third-party services (Heroku, AWS S3) that were no longer controlled by the target organization. This created subdomain takeover opportunities. The expired certificates were identified by querying CT logs and filtering for certificates with `not_after` dates in the past. The subdomains were verified by checking DNS records and confirming they pointed to unclaimed resources.

### Case Study 3: Infrastructure Mapping Through Certificate Chains

Analysis of certificate issuer information in CT logs revealed the complete infrastructure of the target organization. Different subdomains used certificates from different Certificate Authorities, indicating different teams or services. The certificate chains showed relationships between services, and the validity periods revealed deployment timelines. This information was used to create a comprehensive infrastructure map that guided subsequent penetration testing activities.

### Case Study 4: Unauthorized Certificate Detection

Continuous CT log monitoring detected a certificate issued for the target domain by an unknown Certificate Authority. Investigation revealed that a third-party contractor had obtained a certificate for a subdomain without authorization. The unauthorized certificate was identified by comparing the issuer information against known authorized Certificate Authorities. This finding highlighted the importance of CT log monitoring for detecting unauthorized certificate issuance.

### Case Study 5: Technology Fingerprinting Through Certificates

CT log analysis revealed the technology stack of the target organization through certificate configurations. Different services used different certificate types (EV, DV, OV) and configurations (key sizes, algorithms). The certificate issuance patterns showed migration from RSA to ECDSA keys, indicating modern security practices. The certificate transparency information was combined with other reconnaissance data to create a comprehensive technology profile.

## Advanced Techniques and Bypass

### Wildcard Certificate Analysis

Wildcard certificates cover multiple subdomains and provide insights into naming conventions.

```bash
# Find wildcard certificates
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | grep "^\*\." | sort -u

# Analyze wildcard patterns
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | grep "^\*\." | sed 's/\*\.//' | sort -u

# Generate subdomains based on wildcard patterns
for sub in api dev staging admin test; do
    dig +short $sub.target.com A
done
```

### Certificate Transparency Log Chaining

Combine multiple CT log sources for comprehensive coverage.

```bash
# Query multiple CT log sources
curl -s "https://crt.sh/?q=%.target.com&output=json" > /tmp/crtsh.json
curl -s "https://api.certspotter.com/v1/issuances?domain=target.com&include_subdomains=true" > /tmp/certspotter.json

# Combine results
cat /tmp/crtsh.json | jq -r '.[].name_value' | sort -u > /tmp/crtsh_subdomains.txt
cat /tmp/certspotter.json | jq -r '.[].dns_names[]' | sort -u > /tmp/certspotter_subdomains.txt
cat /tmp/crtsh_subdomains.txt /tmp/certspotter_subdomains.txt | sort -u > /tmp/combined_subdomains.txt
```

### Certificate Serial Number Analysis

Certificate serial numbers can reveal information about Certificate Authority operations.

```bash
# Extract serial numbers
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].serial_number'

# Analyze serial number patterns
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].serial_number' | head -20
```

### CT Log Error Handling

Handle CT log query errors and rate limiting.

```bash
# Retry logic for CT log queries
for i in {1..3}; do
    curl -s --retry 3 --retry-delay 5 "https://crt.sh/?q=%.target.com&output=json" > /tmp/ct_results.json
    if [ $? -eq 0 ]; then
        break
    fi
    sleep 10
done

# Rate limiting awareness
curl -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" "https://crt.sh/?q=%.target.com&output=json"
```

## Detection and Indicators

### Signs of CT Log Monitoring

Monitor for the following indicators:
- Repeated queries to CT log APIs
- Monitoring for new certificate issuances
- Analysis of certificate fields and metadata

### Server-Side Detection Methods

Certificate Authorities can detect CT log monitoring through:
- API query patterns and frequency
- User-agent analysis for known monitoring tools
- IP-based rate limiting and blocking

## Impact Assessment

### Finding Severity Classification

CT log findings should be classified based on information disclosed:
- **High**: Subdomains with expired certificates enabling takeover
- **Medium**: Internal subdomains discovered through CT logs
- **Low**: Public subdomains already known through other enumeration
- **Informational**: Certificate configuration details and patterns

## Common Pitfalls

### Not Querying All CT Log Sources

Different CT log sources may contain different certificates. Always query multiple sources for comprehensive coverage.

### Ignoring Wildcard Certificates

Wildcard certificates can reveal naming conventions and provide clues for subdomain enumeration. Always analyze wildcard certificate patterns.

### Forgetting About Certificate Expiration

Expired certificates may indicate abandoned subdomains that could be vulnerable to takeover. Always check certificate expiration dates.

### Not Analyzing Certificate Chains

Certificate chains reveal relationships between services and infrastructure. Always analyze issuer information and certificate chains.

### Overlooking Organization Information

Certificate fields contain organization names and locations that provide valuable intelligence. Always extract and analyze organization information.

## Integration with Other Recon Areas

CT log analysis integrates with other reconnaissance activities:
- **Subdomain Enumeration**: CT logs provide additional subdomains not found through other techniques
- **Certificate Transparency**: CT logs are a primary source for subdomain discovery
- **Technology Stack Fingerprinting**: Certificate configurations reveal technology choices
- **Employee-Linked Assets**: Organization information in certificates correlates with employee data

## Reporting Template

### CT Log Analysis Report

**Executive Summary**: Overview of CT log analysis activities and findings.

**Methodology**: Description of CT log sources queried, tools used, and analysis performed.

**Findings Summary**:
- Total subdomains discovered through CT logs
- Certificate configurations analyzed
- Infrastructure relationships identified
- Expired or vulnerable certificates found

**Critical/High Findings**:
For each finding:
- Subdomain or certificate information
- Potential security implications
- Recommended remediation

## Practice Labs

### Lab 1: Basic CT Log Querying

Practice querying CT logs using crt.sh and other interfaces.

### Lab 2: Subdomain Discovery

Practice discovering subdomains through CT log analysis.

### Lab 3: Certificate Field Analysis

Practice analyzing certificate fields for intelligence gathering.

### Lab 4: CT Log Monitoring

Practice setting up CT log monitoring for new certificate issuances.

### Lab 5: Certificate Expiration Analysis

Practice identifying expired certificates for subdomain takeover opportunities.

## Ethical Guidelines

CT log analysis should only be performed on domains you own or have authorization to test. CT logs are publicly accessible, but the information gathered should be used responsibly. Always obtain explicit authorization before performing active reconnaissance based on CT log findings. Report all discovered vulnerabilities through responsible disclosure channels.

## Quick Reference Cheat Sheet

### CT Log Query Commands
```bash
curl -s "https://crt.sh/?q=%.target.com&output=json"
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//' | sort -u
```

### Certificate Analysis Commands
```bash
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].issuer_name' | sort | uniq -c
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[] | select(.not_after < now) | .name_value'
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | grep "^\*\."
```

### CT Log Monitoring
```bash
# CertSpotter API
curl -s "https://api.certspotter.com/v1/issuances?domain=target.com&include_subdomains=true"

# Custom monitoring
while true; do curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u; sleep 3600; done
```