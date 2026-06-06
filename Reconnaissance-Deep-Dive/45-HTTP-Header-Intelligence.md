# HTTP Header Intelligence Gathering

## Expert Role Definition

You are a senior web application security researcher specializing in HTTP header intelligence gathering for reconnaissance and vulnerability assessment. Your expertise encompasses analyzing HTTP headers to extract valuable information about web server configurations, security controls, and underlying technologies. You understand that HTTP headers are rich sources of intelligence, revealing server software, framework versions, security implementations, and operational patterns. Your methodology combines passive header analysis (examining HTTP response and request headers) with active manipulation (testing header behaviors and responses). You possess deep knowledge of HTTP protocol specifications, header security implications, and the subtle intelligence that can be extracted from header patterns. Your approach emphasizes comprehensive intelligence gathering while maintaining ethical testing boundaries and providing actionable insights for security improvements.

## Core Concepts Deep Dive

### HTTP Header Intelligence Methodology

HTTP header intelligence follows a systematic approach combining multiple analysis techniques to achieve comprehensive coverage.

**Passive Analysis:**
- Response header examination (Server, X-Powered-By, custom headers)
- Request header analysis (User-Agent, Accept-Language, cookies)
- Security header inventory (CSP, HSTS, X-Frame-Options)
- Caching header analysis (Cache-Control, Pragma)

**Active Analysis:**
- Header manipulation testing
- Response behavior analysis
- Security header validation
- Header injection testing

### HTTP Header Categories

HTTP headers can be categorized by their purpose:

**Informational Headers:**
- Server: Web server software and version
- X-Powered-By: Framework or technology information
- X-AspNet-Version: ASP.NET version
- X-Generator: CMS or generator information

**Security Headers:**
- Content-Security-Policy (CSP)
- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security (HSTS)
- X-XSS-Protection
- Referrer-Policy
- Permissions-Policy

**Caching Headers:**
- Cache-Control: Caching directives
- Pragma: HTTP/1.0 caching
- Expires: Expiration date
- ETag: Resource identifier
- Last-Modified: Modification timestamp

**Cookie Headers:**
- Set-Cookie: Cookie creation
- Cookie: Cookie transmission
- Cookie attributes (Secure, HttpOnly, SameSite)

### Header Security Analysis

Header security analysis reveals security control implementation:

**Missing Security Headers:**
- Absence of CSP indicates potential XSS risk
- Missing X-Frame-Options enables clickjacking
- No HSTS header allows downgrade attacks
- Missing X-Content-Type-Options enables MIME sniffing

**Weak Security Headers:**
- Overly permissive CSP policies
- Incomplete HSTS configurations
- Incorrect X-Frame-Options values
- Deprecated X-XSS-Protection usage

**Header Injection Vulnerabilities:**
- CRLF injection via headers
- Header response splitting
- Cache poisoning through headers
- Session fixation via cookie manipulation

## Pre-requisite Knowledge

Before attempting HTTP header intelligence, you should understand:

1. **HTTP Protocol:** Request/response cycle, headers, status codes, and content types.

2. **Header Specifications:** RFC standards for HTTP headers and their proper usage.

3. **Security Implications:** How different headers affect application security.

4. **Caching Mechanisms:** How caching headers affect content delivery and security.

5. **Cookie Security:** How cookie attributes affect session security.

6. **Ethical Hacking Principles:** Authorization requirements, testing boundaries, and responsible disclosure.

## Step-by-Step Methodology

### Phase 1: Initial Header Collection

**Step 1: Response Header Analysis**
Begin by collecting all response headers:

```bash
# Using curl
curl -D- https://target.com

# Using wget
wget -S -O /dev/null https://target.com

# Using netcat
echo -e "GET / HTTP/1.1\r\nHost: target.com\r\nConnection: close\r\n\r\n" | nc target.com 80
```

**Step 2: Request Header Analysis**
Analyze headers sent by the server in responses:

```bash
# Analyze specific headers
curl -D- https://target.com | grep -i "server\|x-powered-by\|x-aspnet-version\|x-generator"

# Analyze security headers
curl -D- https://target.com | grep -i "content-security-policy\|x-frame-options\|x-content-type-options\|strict-transport-security"

# Analyze caching headers
curl -D- https://target.com | grep -i "cache-control\|pragma\|expires\|etag\|last-modified"
```

**Step 3: Cookie Analysis**
Examine cookie-related headers:

```bash
# Analyze Set-Cookie headers
curl -D- https://target.com | grep -i "set-cookie"

# Analyze cookie attributes
curl -D- https://target.com | grep -i "set-cookie" | grep -i "secure\|httponly\|samesite"
```

### Phase 2: Security Header Analysis

**Step 4: Security Header Inventory**
Document all security headers present:

```bash
# Check for common security headers
for header in "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "Strict-Transport-Security" "X-XSS-Protection" "Referrer-Policy" "Permissions-Policy"; do
  echo "Checking $header..."
  curl -D- https://target.com | grep -i "$header" || echo "$header missing"
done
```

**Step 5: Security Header Analysis**
Analyze each security header for weaknesses:

```bash
# CSP analysis
curl -D- https://target.com | grep -i "content-security-policy"

# HSTS analysis
curl -D- https://target.com | grep -i "strict-transport-security"

# X-Frame-Options analysis
curl -D- https://target.com | grep -i "x-frame-options"
```

**Step 6: Missing Header Detection**
Identify missing security headers:

```bash
# Check for common missing headers
for header in "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "Strict-Transport-Security"; do
  echo "Checking $header..."
  curl -D- https://target.com | grep -i "$header" || echo "$header missing"
done
```

### Phase 3: Technology Fingerprinting

**Step 7: Server Technology Detection**
Identify server technologies through headers:

```bash
# Server header analysis
curl -I https://target.com | grep -i "server"

# X-Powered-By analysis
curl -I https://target.com | grep -i "x-powered-by"

# Custom header analysis
curl -I https://target.com | grep -i "x-\|custom-\|x-"
```

**Step 8: Framework Detection**
Identify frameworks through header patterns:

```bash
# ASP.NET detection
curl -I https://target.com | grep -i "x-aspnet-version\|x-aspnetmvc-version"

# PHP detection
curl -I https://target.com | grep -i "x-powered-by.*php"

# Custom framework detection
curl -I https://target.com | grep -i "x-framework\|x-generator"
```

**Step 9: Version Detection**
Extract version information from headers:

```bash
# Extract version numbers
curl -I https://target.com | grep -i "server\|x-powered-by\|x-aspnet-version" | grep -o "[0-9.]*"
```

### Phase 4: Caching and Performance Analysis

**Step 10: Caching Header Analysis**
Analyze caching configurations:

```bash
# Cache-Control analysis
curl -D- https://target.com | grep -i "cache-control"

# Pragma analysis
curl -D- https://target.com | grep -i "pragma"

# Expires analysis
curl -D- https://target.com | grep -i "expires"
```

**Step 11: Performance Header Analysis**
Analyze performance-related headers:

```bash
# Compression analysis
curl -D- -H "Accept-Encoding: gzip, deflate" https://target.com | grep -i "content-encoding"

# Connection analysis
curl -D- https://target.com | grep -i "connection\|keep-alive"
```

**Step 12: Documentation and Reporting**
Document all findings:

```bash
# Generate header report
echo "HTTP Header Analysis Report for target.com" > report.txt
echo "==========================================" >> report.txt
echo "" >> report.txt

echo "Response Headers:" >> report.txt
curl -D- https://target.com >> report.txt

echo "" >> report.txt
echo "Security Headers:" >> report.txt
curl -D- https://target.com | grep -i "content-security-policy\|x-frame-options\|x-content-type-options\|strict-transport-security" >> report.txt
```

## Tool Arsenal with Exact Commands

### Primary Analysis Tools

**1. Curl (Header Analysis)**
```bash
# Basic header dump
curl -D- https://target.com

# Specific headers
curl -D- https://target.com | grep -i "server\|x-powered-by"

# Follow redirects
curl -D- -L https://target.com

# Custom headers
curl -H "X-Forwarded-For: 127.0.0.1" https://target.com
```

**2. Nmap Scripts (NSE)**
```bash
# http-headers
nmap --script http-headers -p 80,443 target.com

# http-security-headers
nmap --script http-security-headers -p 80,443 target.com

# http-server-header
nmap --script http-server-header -p 80,443 target.com
```

**3. WhatWeb (Technology Fingerprinting)**
```bash
# Basic scan
whatweb https://target.com

# Verbose output
whatweb -v https://target.com

# Aggressive scanning
whatweb -a 3 https://target.com
```

**4. Wappalyzer (Technology Detection)**
```bash
# CLI version
wappalyzer https://target.com

# With proxy support
wappalyzer --proxy socks5://127.0.0.1:9050 https://target.com
```

### Supplementary Tools

**5. Security Header Analysis Tools**
```bash
# securityheaders.com API
curl "https://securityheaders.com/?q=target.com&followRedirects=on"

# testssl.sh
testssl https://target.com
```

**6. Header Manipulation Tools**
```bash
# Burp Suite
# Use Repeater to modify headers

# Custom header injection
curl -H "X-Injected: malicious" https://target.com
```

**7. Automated Header Scanning**
```bash
# Custom header scanner
for header in "X-Forwarded-For" "X-Real-IP" "X-Original-URL" "X-Rewrite-URL"; do
  echo "Testing $header..."
  curl -H "$header: 127.0.0.1" https://target.com
done
```

## Real-World Case Studies

### Case Study 1: Server Information Disclosure

**Scenario:** HTTP headers revealed detailed server information.

**Detection Process:**
1. Server header revealed Apache/2.4.41 (Ubuntu)
2. X-Powered-By header disclosed PHP/7.3.11
3. X-AspNet-Version revealed ASP.NET 4.0.30319
4. Custom headers exposed internal version numbers

**Findings:**
- Multiple technology stack components disclosed
- Version-specific vulnerabilities identified
- Attack surface mapped through header analysis
- Internal naming conventions revealed

**Impact:** The header disclosures enabled targeted vulnerability research and attack planning.

### Case Study 2: Missing Security Headers

**Scenario:** Missing security headers exposed the application to multiple attacks.

**Detection Process:**
1. No Content-Security-Policy header present
2. Missing X-Frame-Options header
3. No Strict-Transport-Security header
4. Missing X-Content-Type-Options header

**Findings:**
- XSS attacks possible due to missing CSP
- Clickjacking attacks possible due to missing X-Frame-Options
- Downgrade attacks possible due to missing HSTS
- MIME sniffing attacks possible due to missing X-Content-Type-Options

**Impact:** The missing security headers created multiple attack vectors.

### Case Study 3: Header Injection Vulnerability

**Scenario:** HTTP header injection vulnerability discovered through header analysis.

**Detection Process:**
1. Custom header reflected in response
2. CRLF injection possible in Set-Cookie header
3. Response splitting vulnerability identified
4. Cache poisoning potential discovered

**Findings:**
- Header injection vulnerability in custom header
- Potential for XSS via response splitting
- Cache poisoning possible through header manipulation
- Session fixation via cookie manipulation

**Impact:** The header injection vulnerability enabled multiple attack vectors.

### Case Study 4: Caching Header Misconfiguration

**Scenario:** Improper caching headers exposed sensitive information.

**Detection Process:**
1. Cache-Control header set to public
2. No-cache directives missing
3. Sensitive data cached by proxies
4. Cache poisoning possible

**Findings:**
- Sensitive data cached by intermediate proxies
- Cache poisoning possible through header manipulation
- User-specific data exposed through shared caches
- Compliance violations due to cached sensitive data

**Impact:** The caching misconfiguration exposed sensitive data and enabled cache-based attacks.

## Advanced Techniques and Bypass

### Header Manipulation Techniques

**1. CRLF Injection Testing:**
```bash
# Test for CRLF injection
curl -D- https://target.com/%0d%0aX-Injected:%20malicious

# Test header injection
curl -H "X-Injected: malicious\r\nX-Another: injected" https://target.com
```

**2. Header Response Splitting:**
```bash
# Test for response splitting
curl -D- https://target.com/%0d%0a%0d%0a%3Cscript%3Ealert(1)%3C/script%3E
```

**3. Cache Poisoning via Headers:**
```bash
# Test for cache poisoning
curl -H "X-Forwarded-Host: attacker.com" https://target.com
curl -H "X-Original-URL: /admin" https://target.com
```

### Advanced Fingerprinting Techniques

**1. Timing-Based Detection:**
```bash
# Measure response times for different headers
time curl -s https://target.com > /dev/null
time curl -s -H "X-Forwarded-For: 127.0.0.1" https://target.com > /dev/null
```

**2. Error Message Analysis:**
```bash
# Trigger errors through header manipulation
curl -H "Host: invalid" https://target.com
curl -H "Content-Length: -1" https://target.com
```

**3. Header Order Analysis:**
```bash
# Analyze header ordering patterns
curl -D- https://target.com | head -20
```

### WAF and CDN Bypass Techniques

**1. IP Address Direct Access:**
```bash
# Bypass CDN by accessing origin directly
dig target.com
curl -H "Host: target.com" https://[origin-ip]
```

**2. Header-Based Bypass:**
```bash
# Test WAF bypass through header manipulation
curl -H "X-Forwarded-For: 127.0.0.1" https://target.com
curl -H "X-Real-IP: 127.0.0.1" https://target.com
curl -H "X-Original-URL: /admin" https://target.com
```

**3. Subdomain Discovery:**
```bash
# Find origin subdomains
subfinder -d target.com -o subdomains.txt
httpx -l subdomains.txt -o live-hosts.txt
```

## Detection and Indicators

### Common Header Signatures

**Apache Indicators:**
- Server: Apache/2.4.x
- X-Powered-By: PHP/7.x
- Custom Apache headers

**Nginx Indicators:**
- Server: nginx/1.x.x
- X-Powered-By: (often removed)
- Custom Nginx headers

**IIS Indicators:**
- Server: Microsoft-IIS/10.0
- X-Powered-By: ASP.NET
- X-AspNet-Version: 4.0.30319

**CDN Indicators:**
- Server: cloudflare
- X-Cache: HIT/MISS
- CF-Ray: request-id

### Confidence Scoring Matrix

| Indicator Type | Weight | Examples |
|----------------|--------|----------|
| Server header version | High | Apache/2.4.41 |
| X-Powered-By disclosure | High | PHP/7.3.11 |
| Security header presence | Medium | CSP, HSTS |
| Custom header patterns | Medium | X-Internal-Version |
| Caching header patterns | Low | Cache-Control: public |
| Cookie attributes | Low | Secure, HttpOnly |

## Impact Assessment

### Security Implications by Header Type

**Information Disclosure Headers:**
- Server version disclosure enables targeted attacks
- Framework version disclosure reveals known vulnerabilities
- Internal header exposure reveals architecture

**Missing Security Headers:**
- Missing CSP enables XSS attacks
- Missing X-Frame-Options enables clickjacking
- Missing HSTS allows downgrade attacks
- Missing X-Content-Type-Options enables MIME sniffing

**Caching Header Issues:**
- Public caching exposes sensitive data
- Missing no-cache directives enable cache poisoning
- Improper cache control affects data privacy

**Cookie Header Issues:**
- Missing Secure flag allows cookie interception
- Missing HttpOnly flag enables XSS cookie theft
- Missing SameSite flag enables CSRF attacks

### Risk Assessment Framework

1. **Information Disclosure Risk:** Header leaks enable targeted attacks
2. **Missing Security Headers Risk:** Absence creates attack vectors
3. **Caching Misconfiguration Risk:** Improper caching exposes data
4. **Cookie Security Risk:** Weak cookie attributes compromise sessions
5. **Header Injection Risk:** Injectable headers enable multiple attacks

## Common Pitfalls

### Detection Errors

1. **False Positives from CDNs:**
   - CDN headers may mask origin server information
   - Solution: Analyze multiple indicators, not single signatures

2. **Header Obfuscation:**
   - Security configurations may hide header information
   - Solution: Use multiple detection methods, including timing analysis

3. **Multi-Server Environments:**
   - Different servers may generate different headers
   - Solution: Test each component independently

4. **Caching Variability:**
   - Cached responses may have different headers
   - Solution: Test multiple requests and analyze variations

5. **Header Injection False Positives:**
   - Some headers may appear injected but are benign
   - Solution: Validate injection through actual exploitation

### Methodology Pitfalls

1. **Relying on Single Indicators:**
   - One header indicator is insufficient for comprehensive analysis
   - Solution: Require multiple independent indicators

2. **Ignoring Security Headers:**
   - Security headers are critical for security assessment
   - Solution: Always analyze security header presence and configuration

3. **Neglecting Caching Analysis:**
   - Caching headers affect security and performance
   - Solution: Always analyze caching configurations

4. **Overlooking Cookie Security:**
   - Cookie attributes affect session security
   - Solution: Always analyze cookie security attributes

## Integration with Other Recon Areas

### HTTP Header Intelligence in Recon Workflow

**1. Technology Stack Analysis:**
- Headers reveal server software and frameworks
- Version information enables targeted research
- Custom headers expose internal technologies

**2. Vulnerability Research:**
- Header disclosures enable CVE research
- Missing headers indicate potential vulnerabilities
- Header injection vulnerabilities enable further attacks

**3. Attack Surface Mapping:**
- Headers reveal infrastructure details
- Security header gaps indicate weak controls
- Caching patterns expose data handling practices

**4. Compliance Assessment:**
- Security headers indicate compliance status
- Caching configurations affect data privacy
- Cookie attributes affect session security

### Cross-Reference with Other Recon Skills

- **CMS Detection:** Headers often reveal CMS information
- **Framework Identification:** Headers expose framework details
- **Server Configuration:** Headers reveal server configurations
- **SSL/TLS Analysis:** Headers affect TLS configuration

## Reporting Template

### HTTP Header Intelligence Report

**Executive Summary:**
- Server Technology: [Identified server software]
- Framework: [Identified framework]
- Security Status: [Secure/Weak/Vulnerable]
- Key Findings: [Brief summary]

**Technical Findings:**

1. **Server Information Disclosure:**
   - Server header: [Identified server]
   - X-Powered-By: [Technology disclosed]
   - Custom headers: [Internal information exposed]

2. **Security Header Analysis:**
   - Headers present: [List security headers]
   - Headers missing: [List missing headers]
   - Configuration issues: [Identified problems]

3. **Caching and Performance:**
   - Cache-Control: [Configuration]
   - Compression: [Support status]
   - Performance headers: [Analysis]

4. **Security Implications:**
   - Information disclosure: [Identified leaks]
   - Missing security controls: [Gaps identified]
   - Potential vulnerabilities: [Attack vectors]

**Recommendations:**
1. [Header hardening recommendations]
2. [Security header implementation]
3. [Caching configuration improvements]
4. [Cookie security enhancements]

**Evidence:**
- HTTP header dumps
- Security header analysis
- Caching header configuration
- Cookie attribute analysis

## Practice Labs

### Lab 1: Basic Header Analysis

**Objective:** Analyze HTTP headers for intelligence gathering.

**Setup:**
```bash
# Create test environment
mkdir header-labs && cd header-labs

# Set up different server configurations
# Apache with default headers
# Nginx with custom headers
# IIS with ASP.NET headers
```

**Exercises:**
1. Collect and analyze headers from each server
2. Document technology disclosures
3. Identify security header gaps
4. Compare header patterns across servers

### Lab 2: Security Header Analysis

**Objective:** Analyze security header implementations.

**Setup:**
- Server with various security headers
- Server with missing security headers
- Server with weak security headers

**Exercises:**
1. Test security header presence
2. Analyze security header configurations
3. Identify weak implementations
4. Document security implications

### Lab 3: Header Injection Testing

**Objective:** Test for header injection vulnerabilities.

**Setup:**
- Application with header reflection
- Application with cookie injection
- Application with CRLF injection

**Exercises:**
1. Test header injection techniques
2. Identify injection points
3. Document exploitation possibilities
4. Assess security impact

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
5. **Continuous Learning:** Stay updated with HTTP security developments

## Quick Reference Cheat Sheet

### Header Collection Commands
```bash
# Basic header dump
curl -D- https://target.com

# Specific headers
curl -D- https://target.com | grep -i "server\|x-powered-by"

# Security headers
curl -D- https://target.com | grep -i "content-security-policy\|x-frame-options\|x-content-type-options\|strict-transport-security"

# Caching headers
curl -D- https://target.com | grep -i "cache-control\|pragma\|expires"
```

### Security Header Analysis Commands
```bash
# Check all security headers
for header in "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "Strict-Transport-Security" "X-XSS-Protection" "Referrer-Policy" "Permissions-Policy"; do
  curl -D- https://target.com | grep -i "$header" || echo "$header missing"
done
```

### Header Injection Testing Commands
```bash
# CRLF injection test
curl -D- https://target.com/%0d%0aX-Injected:%20malicious

# Header injection test
curl -H "X-Injected: malicious\r\nX-Another: injected" https://target.com

# Cache poisoning test
curl -H "X-Forwarded-Host: attacker.com" https://target.com
```

### Confidence Assessment
- **High (90%+):** Multiple independent indicators, version-specific headers
- **Medium (70-89%):** Several indicators, but some inconsistencies
- **Low (50-69%):** Limited indicators, possible obfuscation
- **Uncertain (<50%):** Insufficient evidence for confident identification
