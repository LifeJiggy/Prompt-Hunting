# Staging and Development Environment Detection

## Expert Role Definition

You are a senior web application security researcher specializing in staging and development environment detection for reconnaissance and vulnerability assessment. Your expertise encompasses identifying development, staging, testing, and production environments across complex web infrastructures. You understand that staging environments often have weaker security controls, debug features enabled, and incomplete configurations, making them attractive attack targets. Your methodology combines passive environment detection (analyzing HTTP responses, DNS records, and certificate data) with active probing (testing common staging patterns and subdomains). You possess deep knowledge of environment-specific configurations, naming conventions, and the subtle indicators that distinguish staging from production. Your approach emphasizes comprehensive environment mapping while maintaining ethical testing boundaries and providing actionable intelligence for security improvements.

## Core Concepts Deep Dive

### Staging Environment Detection Methodology

Staging environment detection follows a systematic approach combining multiple techniques to achieve comprehensive coverage.

**Passive Detection:**
- DNS record analysis
- Subdomain enumeration
- Certificate Transparency log analysis
- HTTP header analysis

**Active Probing:**
- Subdomain testing
- Port scanning
- Service fingerprinting
- Configuration analysis

### Environment Categories

Web environments can be categorized by purpose and security posture:

**Development Environments:**
- Local development (localhost, 127.0.0.1)
- Developer workstations
- Feature branches
- Experimental implementations

**Staging Environments:**
- Pre-production testing
- Quality assurance
- User acceptance testing
- Performance testing

**Testing Environments:**
- Unit testing
- Integration testing
- Security testing
- Load testing

**Production Environments:**
- Live application
- Customer-facing
- High availability
- Security hardened

### Environment Naming Conventions

Organizations follow distinct naming patterns for environments:

**Subdomain Patterns:**
- dev.target.com
- staging.target.com
- test.target.com
- qa.target.com
- uat.target.com
- pre-prod.target.com
- beta.target.com
- demo.target.com

**Path Patterns:**
- /dev/
- /staging/
- /test/
- /beta/
- /demo/
- /preview/

**Port Patterns:**
- :8080 (development)
- :8443 (staging)
- :3000 (development)
- :4000 (development)
- :5000 (development)

### Environment Security Implications

Staging environments pose significant security risks:

**Weaker Security Controls:**
- Disabled security features
- Default credentials
- Missing security headers
- Disabled HTTPS

**Debug Features Enabled:**
- Verbose error messages
- Debug endpoints exposed
- Development tools accessible
- Logging information disclosed

**Incomplete Configurations:**
- Missing access controls
- Default configurations
- Test data exposed
- Internal services accessible

**Data Exposure:**
- Test user data
- Sample datasets
- Configuration secrets
- Internal documentation

## Pre-requisite Knowledge

Before attempting staging environment detection, you should understand:

1. **DNS Architecture:** How organizations structure DNS for different environments.

2. **Subdomain Enumeration:** Techniques for discovering subdomains and environments.

3. **Certificate Analysis:** How certificates reveal environment information.

4. **Network Architecture:** How environments are networked and segmented.

5. **Security Configurations:** How security differs across environments.

6. **Ethical Hacking Principles:** Authorization requirements, testing boundaries, and responsible disclosure.

## Step-by-Step Methodology

### Phase 1: Passive Environment Discovery

**Step 1: DNS Record Analysis**
Begin by analyzing DNS records for environment indicators:

```bash
# Analyze DNS records
dig target.com ANY
dig target.com A
dig target.com AAAA
dig target.com MX
dig target.com NS

# Check for common environment subdomains
for subdomain in dev staging test qa uat pre-prod beta demo; do
  echo "Checking $subdomain.target.com..."
  dig $subdomain.target.com A +short
done
```

**Step 2: Subdomain Enumeration**
Discover subdomains through various techniques:

```bash
# Using subfinder
subfinder -d target.com -o subdomains.txt

# Using amass
amass enum -d target.com -o subdomains.txt

# Using assetfinder
assetfinder --subs-only target.com > subdomains.txt
```

**Step 3: Certificate Transparency Analysis**
Analyze CT logs for environment subdomains:

```bash
# Search CT logs
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u

# Filter for environment patterns
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | grep -i "dev\|staging\|test\|qa\|uat\|beta"
```

### Phase 2: Active Environment Probing

**Step 4: Subdomain Testing**
Test discovered subdomains for environment indicators:

```bash
# Test subdomains for HTTP responses
httpx -l subdomains.txt -o live-hosts.txt

# Test for environment-specific patterns
for subdomain in $(cat subdomains.txt); do
  echo "Testing $subdomain..."
  curl -I https://$subdomain | grep -i "staging\|development\|test"
done
```

**Step 5: Port Scanning**
Scan for common development ports:

```bash
# Using nmap
nmap -p 80,443,8080,8443,3000,4000,5000 target.com

# Scan for common development services
nmap -p 8080,8443,3000,4000,5000,8000,8888 target.com
```

**Step 6: Service Fingerprinting**
Identify services running on discovered ports:

```bash
# Service version detection
nmap -sV -p 80,443,8080,8443 target.com

# Technology fingerprinting
whatweb https://target.com
```

### Phase 3: Environment Configuration Analysis

**Step 7: HTTP Header Analysis**
Analyze headers for environment indicators:

```bash
# Check for environment headers
curl -D- https://target.com | grep -i "staging\|development\|test\|environment"

# Check for debug headers
curl -D- https://target.com | grep -i "debug\|x-debug\|development"
```

**Step 8: Error Page Analysis**
Analyze error pages for environment information:

```bash
# Trigger error pages
curl -s https://target.com/nonexistent-page-12345

# Analyze error messages
curl -s https://target.com/nonexistent-page-12345 | grep -i "staging\|development\|test"
```

**Step 9: Debug Endpoint Discovery**
Search for debug endpoints in staging environments:

```bash
# Test common debug endpoints
curl -I https://target.com/phpinfo.php
curl -I https://target.com/debug/
curl -I https://target.com/admin/
curl -I https://target.com/actuator
```

### Phase 4: Environment Validation and Documentation

**Step 10: Environment Validation**
Validate discovered environments:

```bash
# Test for production indicators
curl -I https://target.com | grep -i "production\|live"

# Test for staging indicators
curl -I https://staging.target.com | grep -i "staging\|development"
```

**Step 11: Security Assessment**
Assess security of discovered environments:

```bash
# Test access controls
curl -D- https://staging.target.com/admin/

# Test authentication
curl -u admin:password https://staging.target.com/admin/

# Test security headers
curl -D- https://staging.target.com | grep -i "security"
```

**Step 12: Documentation and Reporting**
Document all findings:

```bash
# Generate environment report
echo "Staging Environment Detection Report for target.com" > report.txt
echo "==================================================" >> report.txt
echo "" >> report.txt

echo "Environments Discovered:" >> report.txt
cat subdomains.txt >> report.txt

echo "" >> report.txt
echo "Security Assessment:" >> report.txt
echo "- Staging environment: https://staging.target.com" >> report.txt
echo "- Debug endpoints: Accessible" >> report.txt
echo "- Security controls: Weak" >> report.txt
```

## Tool Arsenal with Exact Commands

### Primary Discovery Tools

**1. Subfinder (Subdomain Enumeration)**
```bash
# Basic enumeration
subfinder -d target.com -o subdomains.txt

# With silent mode
subfinder -d target.com -o subdomains.txt -silent

# With all sources
subfinder -d target.com -o subdomains.txt -all
```

**2. Amass (Asset Discovery)**
```bash
# Passive enumeration
amass enum -d target.com -o subdomains.txt

# Active enumeration
amass enum -active -d target.com -o subdomains.txt

# With brute force
amass enum -brute -d target.com -o subdomains.txt
```

**3. Assetfinder (Asset Discovery)**
```bash
# Find subdomains
assetfinder --subs-only target.com > subdomains.txt

# Find related domains
assetfinder target.com > domains.txt
```

**4. Httpx (HTTP Probing)**
```bash
# Probe subdomains
httpx -l subdomains.txt -o live-hosts.txt

# With status codes
httpx -l subdomains.txt -status-code -o live-hosts.txt

# With titles
httpx -l subdomains.txt -title -o live-hosts.txt
```

### Supplementary Tools

**5. Nmap (Port Scanning)**
```bash
# Quick scan
nmap -F target.com

# Full port scan
nmap -p- target.com

# Service version detection
nmap -sV target.com
```

**6. WhatWeb (Technology Fingerprinting)**
```bash
# Basic scan
whatweb https://target.com

# Verbose output
whatweb -v https://target.com

# Aggressive scanning
whatweb -a 3 https://target.com
```

**7. Curl for Manual Testing**
```bash
# Test specific subdomains
curl -I https://staging.target.com
curl -I https://dev.target.com
curl -I https://test.target.com

# Analyze responses
curl -D- https://staging.target.com | grep -i "staging\|development"
```

## Real-World Case Studies

### Case Study 1: Staging Environment with Debug Enabled

**Scenario:** Staging environment exposed debug features and weak security.

**Detection Process:**
1. Discovered staging.target.com through subdomain enumeration
2. Debug toolbar accessible in staging
3. phpinfo.php accessible without authentication
4. Default credentials worked on admin panel

**Findings:**
- Debug mode enabled in staging
- phpinfo.php exposed server information
- Default credentials (admin/admin) worked
- Security headers missing

**Impact:** The staging environment provided a softer target with debug features and weak credentials.

### Case Study 2: Development Environment Data Exposure

**Scenario:** Development environment exposed test data and configuration secrets.

**Detection Process:**
1. Discovered dev.target.com through CT logs
2. Development environment accessible without authentication
3. Test user data exposed in application
4. Configuration files accessible showing secrets

**Findings:**
- Development environment publicly accessible
- Test user data exposed
- Configuration secrets (API keys, database credentials) exposed
- Debug endpoints accessible

**Impact:** The development environment exposed sensitive configuration data and test user information.

### Case Case 3: Multi-Environment Security Inconsistency

**Scenario:** Different environments had inconsistent security configurations.

**Detection Process:**
1. Production environment had strong security controls
2. Staging environment had weaker controls
3. Development environment had no controls
4. Testing environment exposed debug features

**Findings:**
- Production: Strong security, HTTPS enforced
- Staging: Weaker controls, debug enabled
- Development: No authentication, full debug access
- Testing: Debug features, test data exposed

**Impact:** The security inconsistency across environments created multiple attack vectors.

### Case Case 4: Internal Tool Exposure

**Scenario:** Internal development tools exposed through staging environment.

**Detection Process:**
1. Discovered internal tools accessible through staging
2. Git repository accessible showing source code
3. CI/CD pipeline exposed
4. Internal documentation accessible

**Findings:**
- Git repository publicly accessible
- Source code exposed
- CI/CD configuration exposed
- Internal documentation available

**Impact:** The internal tool exposure enabled source code analysis and potential code injection.

## Advanced Techniques and Bypass

### Environment Detection Obfuscation

Organizations attempt to hide staging environments through:

**1. Access Controls:**
- IP-based restrictions
- VPN requirements
- Authentication requirements
- Bypass: IP spoofing, credential testing

**2. Naming Obfuscation:**
- Non-standard naming conventions
- Randomized subdomain names
- Hash-based naming
- Bypass: Comprehensive enumeration techniques

**3. Network Segmentation:**
- Internal network placement
- Firewall restrictions
- Bypass: Network pivoting, VPN access

### Advanced Discovery Techniques

**1. Timing-Based Discovery:**
```bash
# Measure response times for different subdomains
time curl -s https://staging.target.com > /dev/null
time curl -s https://dev.target.com > /dev/null
time curl -s https://test.target.com > /dev/null
```

**2. Certificate Analysis:**
```bash
# Analyze certificates for environment information
echo | openssl s_client -connect staging.target.com:443 2>/dev/null | openssl x509 -text -noout
```

**3. DNS Analysis:**
```bash
# Analyze DNS records for environment patterns
dig staging.target.com A +short
dig dev.target.com A +short
dig test.target.com A +short
```

### WAF and CDN Bypass Techniques

**1. Subdomain Discovery:**
```bash
# Find staging subdomains
subfinder -d target.com -o subdomains.txt
httpx -l subdomains.txt -o live-hosts.txt
```

**2. Certificate Transparency Analysis:**
```bash
# Find staging domains in CT logs
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | grep -i "staging\|dev\|test"
```

**3. Port Scanning:**
```bash
# Scan for staging ports
nmap -p 8080,8443,3000,4000,5000 target.com
```

## Detection and Indicators

### Common Environment Patterns

**Subdomain Patterns:**
- dev.target.com
- staging.target.com
- test.target.com
- qa.target.com
- uat.target.com
- pre-prod.target.com
- beta.target.com
- demo.target.com

**Path Patterns:**
- /dev/
- /staging/
- /test/
- /beta/
- /demo/
- /preview/

**Port Patterns:**
- :8080 (development)
- :8443 (staging)
- :3000 (development)
- :4000 (development)
- :5000 (development)

**Header Patterns:**
- X-Environment: staging
- X-Debug: true
- Server: Apache/2.4.41 (Ubuntu)

### Confidence Scoring Matrix

| Indicator Type | Weight | Examples |
|----------------|--------|----------|
| Subdomain naming | High | staging.target.com |
| Debug endpoints | High | phpinfo.php accessible |
| Security headers | Medium | Missing security headers |
| Error messages | Medium | Development error pages |
| Port patterns | Low | :8080, :3000 |
| Certificate analysis | Low | Staging certificate |

## Impact Assessment

### Security Implications by Environment Type

**Development Environments:**
- Full debug access
- No authentication
- Source code exposure
- Configuration secrets

**Staging Environments:**
- Debug features enabled
- Weaker security controls
- Test data exposure
- Default credentials

**Testing Environments:**
- Debug endpoints exposed
- Test data accessible
- Weak access controls
- Internal tools exposed

**Production Environments:**
- Strong security controls
- Limited debug features
- Proper access controls
- Security hardened

### Risk Assessment Framework

1. **Information Disclosure Risk:** Environments expose sensitive information
2. **Access Control Risk:** Weak controls enable unauthorized access
3. **Data Exposure Risk:** Test data and secrets exposed
4. **Code Execution Risk:** Debug features enable code execution
5. **Compliance Risk:** Exposed environments violate compliance

## Common Pitfalls

### Detection Errors

1. **False Positives from CDNs:**
   - CDN endpoints may mask staging environments
   - Solution: Analyze origin servers directly

2. **Access Control Limitations:**
   - Some environments may require VPN or authentication
   - Solution: Test different access methods

3. **Naming Obfuscation:**
   - Non-standard naming may be missed
   - Solution: Use comprehensive enumeration techniques

4. **Network Segmentation:**
   - Some environments may be internal only
   - Solution: Use network pivoting techniques

5. **Dynamic Environments:**
   - Environments may change frequently
   - Solution: Monitor and update environment lists regularly

### Methodology Pitfalls

1. **Relying on Single Indicators:**
   - One environment indicator is insufficient
   - Solution: Require multiple independent indicators

2. **Ignoring Security Assessment:**
   - Security assessment reveals vulnerability impact
   - Solution: Always assess security implications

3. **Neglecting Information Extraction:**
   - Information extraction reveals sensitive data
   - Solution: Always extract and analyze information

4. **Overlooking Documentation:**
   - Documentation ensures comprehensive coverage
   - Solution: Always document findings and recommendations

## Integration with Other Recon Areas

### Staging Environment Detection in Recon Workflow

**1. Subdomain Discovery:**
- Environment detection expands subdomain inventory
- Staging environments reveal internal naming conventions
- Development environments expose additional attack surface

**2. Vulnerability Research:**
- Staging environments often have known vulnerabilities
- Debug features enable further reconnaissance
- Weak security controls enable exploitation

**3. Attack Surface Mapping:**
- Environments expand attack surface
- Internal tools provide additional targets
- Configuration secrets enable further attacks

**4. Compliance Assessment:**
- Exposed environments violate compliance
- Weak security controls affect security posture
- Data exposure impacts privacy compliance

### Cross-Reference with Other Recon Skills

- **Subdomain Discovery:** Environment detection enhances subdomain enumeration
- **Debug Endpoint Discovery:** Staging environments often have debug endpoints
- **Server Configuration:** Environments have different server configurations
- **SSL/TLS Analysis:** Environments may have different certificate configurations

## Reporting Template

### Staging Environment Detection Report

**Executive Summary:**
- Environments Discovered: [Number]
- Security Status: [Secure/Exposed/Vulnerable]
- Key Findings: [Brief summary]
- Risk Level: [High/Medium/Low]

**Technical Findings:**

1. **Environment Inventory:**
   - Development environments: [List]
   - Staging environments: [List]
   - Testing environments: [List]
   - Other environments: [List]

2. **Security Assessment:**
   - Access controls: [Analysis]
   - Authentication: [Status]
   - Security headers: [Status]
   - Debug features: [Status]

3. **Information Disclosure:**
   - Configuration secrets: [Exposed]
   - Test data: [Exposed]
   - Debug endpoints: [Accessible]
   - Internal tools: [Accessible]

4. **Risk Assessment:**
   - Overall risk level: [High/Medium/Low]
   - Priority findings: [Critical issues]
   - Remediation recommendations: [Specific actions]

**Recommendations:**
1. [Access control implementation]
2. [Security hardening]
3. [Debug feature removal]
4. [Monitoring enhancement]

**Evidence:**
- Environment discovery screenshots
- HTTP response samples
- Security assessment results
- Information disclosure proof

## Practice Labs

### Lab 1: Basic Environment Detection

**Objective:** Discover and analyze staging environments.

**Setup:**
```bash
# Create test environment
mkdir staging-labs && cd staging-labs

# Set up different environments
# Production environment
# Staging environment
# Development environment
# Testing environment
```

**Exercises:**
1. Discover environments using various techniques
2. Analyze environment configurations
3. Assess security implications
4. Document findings and recommendations

### Lab 2: Subdomain Enumeration

**Objective:** Enumerate subdomains for environment discovery.

**Setup:**
- Target domain with multiple environments
- DNS records for different environments
- Certificates for different environments

**Exercises:**
1. Enumerate subdomains using various tools
2. Identify environment patterns
3. Analyze certificate information
4. Document environment inventory

### Lab 3: Security Assessment

**Objective:** Assess security of discovered environments.

**Setup:**
- Staging environment with weak security
- Development environment with debug features
- Testing environment with test data

**Exercises:**
1. Assess access controls
2. Test authentication mechanisms
3. Analyze security configurations
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
5. **Continuous Learning:** Stay updated with environment security developments

## Quick Reference Cheat Sheet

### Subdomain Enumeration Commands
```bash
# Subfinder
subfinder -d target.com -o subdomains.txt

# Amass
amass enum -d target.com -o subdomains.txt

# Assetfinder
assetfinder --subs-only target.com > subdomains.txt
```

### Environment Detection Commands
```bash
# Test common environment subdomains
for subdomain in dev staging test qa uat pre-prod beta demo; do
  echo "Checking $subdomain.target.com..."
  dig $subdomain.target.com A +short
done

# Test HTTP responses
httpx -l subdomains.txt -o live-hosts.txt
```

### Security Assessment Commands
```bash
# Test access controls
curl -D- https://staging.target.com/admin/

# Test authentication
curl -u admin:password https://staging.target.com/admin/

# Test security headers
curl -D- https://staging.target.com | grep -i "security"
```

### Confidence Assessment
- **High (90%+):** Multiple independent indicators, direct access
- **Medium (70-89%):** Several indicators, limited access
- **Low (50-69%):** Limited indicators, restricted access
- **Uncertain (<50%):** Insufficient evidence for comprehensive analysis
