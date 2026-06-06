# SSL/TLS Certificate Analysis for Reconnaissance

## Expert Role Definition

You are a senior cybersecurity analyst specializing in SSL/TLS certificate analysis for reconnaissance and security assessment. Your expertise encompasses analyzing certificate chains, Subject Alternative Names (SANs), certificate transparency logs, and cryptographic configurations to gather intelligence about web infrastructure. You understand that SSL/TLS certificates are treasure troves of information, revealing domain ownership, subdomain inventories, organizational details, and infrastructure patterns. Your methodology combines passive certificate analysis (examining publicly available certificate data) with active probing (testing certificate configurations and vulnerabilities). You possess deep knowledge of X.509 certificate structures, certificate authority hierarchies, and the subtle intelligence that can be extracted from certificate data. Your approach emphasizes comprehensive intelligence gathering while maintaining ethical testing boundaries and providing actionable insights for security improvements.

## Core Concepts Deep Dive

### Certificate Analysis Methodology

SSL/TLS certificate analysis follows a systematic approach combining multiple intelligence gathering techniques to achieve comprehensive coverage.

**Passive Analysis:**
- Certificate Transparency (CT) log analysis
- Certificate database queries
- WHOIS data correlation
- DNS record analysis

**Active Analysis:**
- Direct certificate inspection
- Certificate chain validation
- Cipher suite analysis
- Protocol version testing

### X.509 Certificate Structure

Understanding certificate structure is crucial for intelligence extraction:

**Certificate Fields:**
- Subject: Owner information (CN, O, OU, L, ST, C)
- Issuer: Certificate authority information
- Validity Period: Not Before/Not After dates
- Public Key: Key algorithm and parameters
- Extensions: SAN, Key Usage, Basic Constraints
- Signature: CA's digital signature

**Critical Extensions:**
- Subject Alternative Name (SAN): Additional domain names
- Key Usage: Permitted uses for the certificate
- Extended Key Usage: Specific application purposes
- Basic Constraints: CA certificate indicator
- Certificate Policies: CA policy information

### Certificate Chain Analysis

Certificate chain analysis reveals trust relationships:

**Chain Components:**
- End-entity certificate: Server certificate
- Intermediate certificates: CA hierarchy
- Root certificate: Trust anchor
- Cross-signed certificates: Alternative trust paths

**Chain Validation:**
- Signature verification
- Expiration checking
- Revocation status
- Trust anchor validation

### Certificate Transparency (CT)

CT logs provide public records of issued certificates:

**CT Log Sources:**
- Google Argon
- Cloudflare Nimbus
- DigiCert Yeti
- Sectigo Sabre
- Let's Encrypt Oak

**CT Intelligence:**
- Subdomain discovery
- Infrastructure changes
- Organization mapping
- Attack surface expansion

## Pre-requisite Knowledge

Before attempting certificate analysis, you should understand:

1. **X.509 Certificate Structure:** Certificate fields, extensions, and their purposes.

2. **PKI Hierarchy:** Certificate authorities, trust chains, and validation processes.

3. **Certificate Transparency:** CT logs, SCTs, and their role in certificate monitoring.

4. **TLS Protocol:** Handshake process, cipher suites, and protocol versions.

5. **Cryptographic Concepts:** Public key cryptography, digital signatures, and hash functions.

6. **Ethical Hacking Principles:** Authorization requirements, testing boundaries, and responsible disclosure.

## Step-by-Step Methodology

### Phase 1: Certificate Discovery

**Step 1: Certificate Transparency Log Search**
Begin by searching CT logs for issued certificates:

```bash
# Using crt.sh
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u

# Using CT search APIs
curl -s "https://crt.sh/?q=target.com&output=json" | jq -r '.[].name_value' | sort -u
```

**Step 2: Direct Certificate Inspection**
Examine the certificate presented by the server:

```bash
# Using OpenSSL
openssl s_client -connect target.com:443 -showcerts < /dev/null 2>/dev/null | openssl x509 -text -noout

# Using curl
curl -vI https://target.com 2>&1 | grep -A 20 "Server certificate"
```

**Step 3: Certificate Chain Analysis**
Analyze the complete certificate chain:

```bash
# Full chain inspection
openssl s_client -connect target.com:443 -showcerts < /dev/null 2>/dev/null

# Chain validation
openssl s_client -connect target.com:443 -verify 5 < /dev/null 2>/dev/null
```

### Phase 2: Intelligence Extraction

**Step 4: SAN Field Extraction**
Extract Subject Alternative Names for subdomain discovery:

```bash
# Extract SANs from certificate
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -ext subjectAltName

# Extract all domains from CT logs
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u
```

**Step 5: Organizational Information Extraction**
Extract organization details from certificate:

```bash
# Extract subject information
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -subject

# Extract issuer information
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -issuer

# Extract all certificate details
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -text -noout
```

**Step 6: Validity and Expiration Analysis**
Analyze certificate validity and expiration:

```bash
# Check expiration date
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -dates

# Check certificate validity
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -checkend 0
```

### Phase 3: Security Assessment

**Step 7: Cipher Suite Analysis**
Analyze supported cipher suites:

```bash
# Using nmap
nmap --script ssl-enum-ciphers -p 443 target.com

# Using openssl
openssl s_client -connect target.com:443 -cipher ALL < /dev/null 2>/dev/null
```

**Step 8: Protocol Version Testing**
Test for supported TLS protocol versions:

```bash
# Test TLS 1.3
openssl s_client -connect target.com:443 -tls1_3 < /dev/null 2>/dev/null

# Test TLS 1.2
openssl s_client -connect target.com:443 -tls1_2 < /dev/null 2>/dev/null

# Test TLS 1.1
openssl s_client -connect target.com:443 -tls1_1 < /dev/null 2>/dev/null

# Test TLS 1.0
openssl s_client -connect target.com:443 -tls1 < /dev/null 2>/dev/null
```

**Step 9: Vulnerability Testing**
Test for known TLS vulnerabilities:

```bash
# Test for Heartbleed
openssl s_client -connect target.com:443 -tlsextdebug < /dev/null 2>/dev/null

# Test for POODLE
nmap --script ssl-poodle -p 443 target.com

# Test for DROWN
nmap --script ssl-drown -p 443 target.com
```

### Phase 4: Intelligence Correlation

**Step 10: Cross-Reference with Other Intelligence**
Correlate certificate data with other reconnaissance:

```bash
# Correlate with DNS records
dig target.com ANY
dig target.com A
dig target.com AAAA
dig target.com MX

# Correlate with WHOIS data
whois target.com

# Correlate with IP information
nslookup target.com
```

**Step 11: Infrastructure Mapping**
Map infrastructure based on certificate patterns:

```bash
# Analyze certificate sharing across subdomains
for subdomain in $(curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u); do
  echo "Checking $subdomain..."
  echo | openssl s_client -connect $subdomain:443 2>/dev/null | openssl x509 -noout -ext subjectAltName 2>/dev/null
done
```

**Step 12: Create Intelligence Report**
Document all findings in a comprehensive report:

```bash
# Generate certificate summary
echo "Certificate Analysis Report for target.com" > report.txt
echo "==========================================" >> report.txt
echo "" >> report.txt

echo "Certificate Details:" >> report.txt
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -text -noout >> report.txt

echo "" >> report.txt
echo "SAN Domains:" >> report.txt
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -ext subjectAltName >> report.txt
```

## Tool Arsenal with Exact Commands

### Primary Analysis Tools

**1. OpenSSL (Certificate Inspection)**
```bash
# Basic certificate inspection
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -text -noout

# Certificate chain inspection
openssl s_client -connect target.com:443 -showcerts < /dev/null 2>/dev/null

# SAN extraction
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -ext subjectAltName

# Expiration check
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -dates
```

**2. Nmap Scripts (NSE)**
```bash
# ssl-enum-ciphers
nmap --script ssl-enum-ciphers -p 443 target.com

# ssl-cert
nmap --script ssl-cert -p 443 target.com

# ssl-known-key
nmap --script ssl-known-key -p 443 target.com

# ssl-poodle
nmap --script ssl-poodle -p 443 target.com

# ssl-drown
nmap --script ssl-drown -p 443 target.com
```

**3. Cert.sh (Certificate Transparency)**
```bash
# Search CT logs
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u

# JSON output for analysis
curl -s "https://crt.sh/?q=target.com&output=json" | jq -r '.[].name_value' | sort -u

# Specific subdomain search
curl -s "https://crt.sh/?q=api.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u
```

**4. TestSSL.sh (Comprehensive Testing)**
```bash
# Full SSL/TLS test
testssl https://target.com

# Specific tests
testssl --headers https://target.com
testssl --vulnerabilities https://target.com
testssl --cipher https://target.com
```

### Supplementary Tools

**5. SSLyze (SSL Configuration Analyzer)**
```bash
# Basic analysis
sslyze --regular target.com

# Full analysis
sslyze --full target.com

# JSON output
sslyze --json_out=results.json target.com
```

**6. Shodan (Certificate Search)**
```bash
# Search for certificates
shodan search ssl.cert.subject.CN:target.com

# Search for specific certificates
shodan search ssl.cert.subject.CN:target.com ssl.cert.issuer.CN:"Let's Encrypt"
```

**7. Censys (Certificate Search)**
```bash
# Search certificates
censys search "parsed.subject.common_name: target.com"

# Search with filters
censys search "parsed.subject.common_name: target.com AND parsed.issuer.organization: Let's Encrypt"
```

## Real-World Case Studies

### Case Study 1: Subdomain Discovery via Certificate Transparency

**Scenario:** A large enterprise had extensive subdomain inventory revealed through CT logs.

**Detection Process:**
1. Searched CT logs for *.target.com
2. Found 500+ unique subdomains across multiple certificates
3. Identified internal naming conventions (dev., staging., test., internal.)
4. Discovered abandoned subdomains still pointing to old infrastructure

**Findings:**
- 500+ subdomains discovered
- Internal naming patterns revealed development workflow
- Abandoned subdomains with outdated SSL certificates
- Multiple certificate authorities used for different purposes

**Impact:** The comprehensive subdomain inventory revealed the organization's development lifecycle and identified potential attack vectors through abandoned infrastructure.

### Case Study 2: Certificate Chain Analysis Reveals Infrastructure

**Scenario:** Certificate chain analysis exposed internal infrastructure details.

**Detection Process:**
1. Analyzed certificate chain for target.com
2. Discovered intermediate CA signed by internal CA
3. Found internal CA hierarchy in certificate chain
4. Correlated with other reconnaissance data

**Findings:**
- Internal CA hierarchy revealed organizational structure
- Intermediate CA certificates exposed internal domains
- Certificate policies revealed security control implementation
- Trust relationships mapped organizational boundaries

**Impact:** The certificate chain analysis provided insights into the organization's internal PKI infrastructure and trust relationships.

### Case Study 3: Cipher Suite Analysis Reveals Security Posture

**Scenario:** Cipher suite analysis identified weak cryptographic configurations.

**Detection Process:**
1. Analyzed supported cipher suites
2. Found support for weak ciphers (RC4, DES, 3DES)
3. Identified outdated TLS versions (SSLv3, TLS 1.0)
4. Discovered missing forward secrecy ciphers

**Findings:**
- Weak cipher suites enabled potential decryption attacks
- Outdated TLS versions vulnerable to known attacks
- Missing forward secrecy compromised session security
- Incomplete certificate chain validation possible

**Impact:** The weak cryptographic configuration exposed the organization to multiple known attacks and compliance violations.

### Case Study 4: Certificate Expiration Monitoring

**Scenario:** Certificate expiration monitoring revealed poor certificate management.

**Detection Process:**
1. Monitored certificate expiration across all subdomains
2. Found multiple certificates expiring within 30 days
3. Discovered certificates with different expiration dates
4. Identified manual certificate management processes

**Findings:**
- Inconsistent certificate expiration dates
- No automated certificate renewal process
- Multiple certificate authorities with different validity periods
- Risk of service disruption due to expired certificates

**Impact:** The certificate expiration analysis revealed operational risks and the need for automated certificate management.

## Advanced Techniques and Bypass

### Certificate Pinning Detection

Certificate pinning can be detected and analyzed:

**1. Pin Validation Testing:**
```bash
# Test certificate pinning
curl -k https://target.com  # Ignore certificate errors

# Analyze pin headers
curl -D- https://target.com | grep -i "public-key-pins"
```

**2. Pin Configuration Analysis:**
```bash
# Test with different certificates
openssl s_client -connect target.com:443 -cert client.pem -key client-key.pem

# Analyze pin validation behavior
curl -v https://target.com 2>&1 | grep -i "pin"
```

### Advanced Certificate Analysis Techniques

**1. Certificate Fingerprint Analysis:**
```bash
# Calculate certificate fingerprints
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256

# Compare fingerprints across certificates
for domain in target.com api.target.com admin.target.com; do
  echo "$domain: $(echo | openssl s_client -connect $domain:443 2>/dev/null | openssl x509 -noout -fingerprint -sha256)"
done
```

**2. Certificate Timeline Analysis:**
```bash
# Analyze certificate issuance timeline
curl -s "https://crt.sh/?q=target.com&output=json" | jq -r '.[] | "\(.not_before) \(.not_after) \(.common_name)"' | sort
```

**3. Cross-Domain Certificate Correlation:**
```bash
# Find certificates shared across multiple domains
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort | uniq -c | sort -rn
```

### WAF and CDN Bypass Techniques

**1. Origin Certificate Discovery:**
```bash
# Find origin server certificates
dig target.com
curl -H "Host: target.com" https://[origin-ip]

# Analyze origin certificate
openssl s_client -connect [origin-ip]:443 < /dev/null 2>/dev/null | openssl x509 -text -noout
```

**2. Subdomain Certificate Analysis:**
```bash
# Analyze certificates for all discovered subdomains
for subdomain in $(subfinder -d target.com); do
  echo "Checking $subdomain..."
  echo | openssl s_client -connect $subdomain:443 2>/dev/null | openssl x509 -noout -ext subjectAltName 2>/dev/null
done
```

**3. Certificate Transparency Log Analysis:**
```bash
# Analyze CT logs for infrastructure changes
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[] | "\(.entry_timestamp) \(.common_name)"' | sort
```

## Detection and Indicators

### Common Certificate Patterns

**Let's Encrypt Certificates:**
- Issuer: Let's Encrypt
- Validity: 90 days
- Auto-renewal patterns
- Free certificate indicators

**Commercial Certificates:**
- Issuer: DigiCert, Comodo, Symantec, etc.
- Validity: 1-2 years
- Organization validation
- Extended validation indicators

**Internal PKI Certificates:**
- Issuer: Internal CA
- Custom validity periods
- Organization-specific extensions
- Trust chain indicators

**Wildcard Certificates:**
- SAN: *.domain.com
- Subdomain coverage
- Infrastructure patterns
- Certificate sharing

### Confidence Scoring Matrix

| Indicator Type | Weight | Examples |
|----------------|--------|----------|
| SAN field extraction | High | *.target.com, api.target.com |
| Certificate chain analysis | High | Internal CA hierarchy |
| CT log analysis | Medium | 500+ subdomains discovered |
| Cipher suite analysis | Medium | Weak ciphers detected |
| Expiration analysis | Low | Inconsistent expiration dates |
| Fingerprint comparison | Low | Certificate sharing patterns |

## Impact Assessment

### Security Implications by Certificate Type

**Let's Encrypt:**
- Automated management reduces human error
- Short validity limits exposure window
- Free certificates encourage widespread adoption
- CT logging provides transparency

**Commercial Certificates:**
- Extended validation provides assurance
- Longer validity increases exposure window
- Cost factors affect certificate management
- Limited CT transparency

**Internal PKI:**
- Custom trust relationships
- Potential for misconfiguration
- Limited external visibility
- Complex management requirements

**Wildcard Certificates:**
- Broad subdomain coverage
- Single point of failure
- Potential for over-sharing
- Complex renewal management

### Risk Assessment Framework

1. **Certificate Expiration Risk:** Expired certificates cause service disruption
2. **Weak Cipher Risk:** Outdated ciphers enable attacks
3. **Certificate Pinning Risk:** Misconfigured pins cause accessibility issues
4. **CT Transparency Risk:** Lack of CT enables malicious certificate issuance
5. **Certificate Management Risk:** Poor management increases operational risk

## Common Pitfalls

### Detection Errors

1. **False Positives from CDNs:**
   - CDN certificates may not reflect origin certificates
   - Solution: Analyze origin server directly

2. **Certificate Chain Complexity:**
   - Complex chains may hide intermediate certificates
   - Solution: Analyze complete certificate chain

3. **CT Log Limitations:**
   - Not all certificates appear in CT logs
   - Solution: Combine CT analysis with direct inspection

4. **Certificate Pinning Issues:**
   - Pinned certificates may not match expected patterns
   - Solution: Test pin validation behavior

5. **Multi-Certificate Environments:**
   - Different services may use different certificates
   - Solution: Test each service independently

### Methodology Pitfalls

1. **Relying on Single Indicators:**
   - One certificate indicator is insufficient for comprehensive analysis
   - Solution: Require multiple independent indicators

2. **Ignoring Certificate Chain:**
   - Certificate chain reveals trust relationships
   - Solution: Always analyze complete certificate chain

3. **Neglecting Cipher Analysis:**
   - Cipher suites affect security posture
   - Solution: Always analyze supported cipher suites

4. **Overlooking Expiration:**
   - Certificate expiration affects availability
   - Solution: Always check certificate expiration dates

## Integration with Other Recon Areas

### Certificate Analysis in Recon Workflow

**1. Subdomain Discovery:**
- CT logs reveal extensive subdomain inventories
- Certificate SANs provide comprehensive domain lists
- Certificate sharing patterns reveal infrastructure

**2. Infrastructure Mapping:**
- Certificate chains reveal trust relationships
- Certificate authorities indicate organizational structure
- Certificate patterns reveal development workflows

**3. Vulnerability Research:**
- Certificate versions enable CVE research
- Cipher suite analysis reveals cryptographic weaknesses
- Certificate pinning affects testing approaches

**4. Compliance Assessment:**
- Certificate configurations indicate compliance status
- CT transparency reveals monitoring practices
- Certificate management reveals operational maturity

### Cross-Reference with Other Recon Skills

- **Subdomain Discovery:** Certificate analysis enhances subdomain enumeration
- **Server Configuration:** Certificate reveals server infrastructure
- **HTTP Header Intelligence:** Certificate affects header analysis
- **SSL/TLS Testing:** Certificate analysis is foundational to TLS testing

## Reporting Template

### SSL/TLS Certificate Analysis Report

**Executive Summary:**
- Certificate Type: [Let's Encrypt/Commercial/Internal PKI]
- Domains Covered: [Number of domains in SAN]
- Security Status: [Secure/Weak/Vulnerable]
- Key Findings: [Brief summary]

**Technical Findings:**

1. **Certificate Details:**
   - Subject: [Certificate subject]
   - Issuer: [Certificate authority]
   - Validity: [Not Before/Not After]
   - SAN Domains: [List of domains]

2. **Certificate Chain Analysis:**
   - Chain components: [List certificates]
   - Trust relationships: [Trust hierarchy]
   - Validation status: [Valid/Invalid]

3. **Security Assessment:**
   - Cipher suites: [Supported ciphers]
   - Protocol versions: [Supported TLS versions]
   - Vulnerabilities: [Known vulnerabilities]

4. **Intelligence Extraction:**
   - Subdomains discovered: [List from CT logs]
   - Infrastructure patterns: [Identified patterns]
   - Organizational information: [Extracted details]

**Recommendations:**
1. [Certificate management recommendations]
2. [Cipher suite hardening suggestions]
3. [Certificate transparency monitoring]
4. [Expiration monitoring implementation]

**Evidence:**
- Certificate details output
- CT log search results
- Cipher suite analysis
- Certificate chain inspection

## Practice Labs

### Lab 1: Basic Certificate Analysis

**Objective:** Analyze SSL/TLS certificates for intelligence gathering.

**Setup:**
```bash
# Create test environment
mkdir cert-labs && cd cert-labs

# Set up test certificates
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt

# Create certificate chain
openssl req -new -nodes -out server.csr -key server.key
openssl ca -in server.csr -out server.crt -cert ca.crt -keyfile ca.key
```

**Exercises:**
1. Analyze certificate structure using OpenSSL
2. Extract SAN fields and organizational information
3. Analyze certificate chain and trust relationships
4. Document all findings

### Lab 2: Certificate Transparency Analysis

**Objective:** Use CT logs for subdomain discovery and intelligence gathering.

**Setup:**
- Target domain with multiple subdomains
- Access to CT log search tools
- Certificate monitoring setup

**Exercises:**
1. Search CT logs for target domain
2. Extract all subdomains from certificate records
3. Analyze certificate issuance timeline
4. Identify infrastructure patterns

### Lab 3: Cipher Suite Analysis

**Objective:** Analyze cipher suite configurations for security assessment.

**Setup:**
- Test server with different cipher configurations
- Tools for cipher suite testing
- Vulnerable cipher suites for testing

**Exercises:**
1. Test supported cipher suites
2. Identify weak cipher configurations
3. Analyze protocol version support
4. Document security implications

## Ethical Guidelines

### Legal and Authorization Requirements

1. **Written Authorization:** Always obtain explicit written permission before testing
2. **Scope Definition:** Understand exactly what systems you're authorized to test
3. **Testing Boundaries:** Respect limits on active scanning and probing
4. **Data Handling:** Protect any discovered sensitive information
5. **Disclosure:** Follow responsible disclosure practices

### Professional Conduct

1. **Minimal Impact:** Avoid disrupting production systems
2. **Data Protection:** Don't access or exfiltrate user data
3. **Documentation:** Record all testing activities for transparency
4. **Reporting:** Provide actionable findings with remediation guidance
5. **Knowledge Sharing:** Share detection techniques with the security community

### Ethical Considerations

1. **Do No Harm:** Ensure testing doesn't harm systems or users
2. **Authorization:** Never exceed authorized testing scope
3. **Privacy:** Respect user privacy and data protection regulations
4. **Professionalism:** Maintain professional standards in all interactions
5. **Continuous Learning:** Stay updated with TLS security developments

## Quick Reference Cheat Sheet

### Certificate Inspection Commands
```bash
# Basic certificate inspection
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -text -noout

# SAN extraction
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -ext subjectAltName

# Expiration check
openssl s_client -connect target.com:443 < /dev/null 2>/dev/null | openssl x509 -noout -dates

# Certificate chain
openssl s_client -connect target.com:443 -showcerts < /dev/null 2>/dev/null
```

### Certificate Transparency Commands
```bash
# Search CT logs
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u

# JSON output
curl -s "https://crt.sh/?q=target.com&output=json" | jq -r '.[].name_value' | sort -u
```

### Cipher Suite Analysis Commands
```bash
# Nmap cipher scan
nmap --script ssl-enum-ciphers -p 443 target.com

# OpenSSL cipher test
openssl s_client -connect target.com:443 -cipher ALL < /dev/null 2>/dev/null
```

### Protocol Version Testing
```bash
# TLS 1.3
openssl s_client -connect target.com:443 -tls1_3 < /dev/null 2>/dev/null

# TLS 1.2
openssl s_client -connect target.com:443 -tls1_2 < /dev/null 2>/dev/null

# TLS 1.1
openssl s_client -connect target.com:443 -tls1_1 < /dev/null 2>/dev/null

# TLS 1.0
openssl s_client -connect target.com:443 -tls1 < /dev/null 2>/dev/null
```

### Confidence Assessment
- **High (90%+):** Complete certificate chain, comprehensive CT log data
- **Medium (70-89%):** Partial certificate information, limited CT data
- **Low (50-69%):** Limited certificate details, minimal CT coverage
- **Uncertain (<50%):** Insufficient evidence for comprehensive analysis
