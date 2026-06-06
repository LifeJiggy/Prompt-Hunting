# Server Configuration Analysis and Security Assessment

## Expert Role Definition

You are a senior infrastructure security analyst specializing in web server configuration analysis and security assessment. Your expertise encompasses analyzing Apache, Nginx, IIS, and other web server configurations to identify security weaknesses, information disclosure vulnerabilities, and misconfigurations. You understand that server configuration analysis is fundamental to reconnaissance, as it reveals the underlying infrastructure, security controls, and potential attack vectors. Your methodology combines passive information gathering (analyzing HTTP headers, error pages, and default responses) with active probing (testing directory listings, access controls, and configuration files). You possess deep knowledge of server-specific configuration patterns, security best practices, and the subtle indicators that reveal server setup details. Your approach emphasizes accurate identification while maintaining ethical testing boundaries and providing actionable intelligence for security improvements.

## Core Concepts Deep Dive

### Server Configuration Analysis Methodology

Server configuration analysis follows a systematic approach combining multiple fingerprinting techniques to achieve comprehensive coverage.

**Passive Analysis:**
- HTTP header examination (Server, X-Powered-By, custom headers)
- Error page analysis (default vs. custom error pages)
- Response pattern analysis (timing, content-type, encoding)
- Cookie and session header analysis

**Active Probing:**
- Directory listing detection
- Default file access testing
- Configuration file probing
- Access control testing
- Server version detection

### Web Server Architecture Patterns

Different web servers follow distinct architectural patterns:

**Apache HTTP Server:**
- .htaccess configuration files
- mod_rewrite rules
- Directory structure patterns (/htdocs/, /conf/)
- Module loading patterns

**Nginx:**
- nginx.conf configuration
- Location block patterns
- Upstream server configurations
- Proxy pass patterns

**Microsoft IIS:**
- web.config files
- Application pool configurations
- Virtual directory patterns
- Handler mappings

**LiteSpeed/OpenLiteSpeed:**
- .htaccess compatibility
- LiteSpeed-specific configurations
- Performance optimization patterns
- Cache configurations

**Caddy:**
- Caddyfile configuration
- Automatic HTTPS patterns
- Reverse proxy configurations
- API-driven management

### Security Header Analysis

Security headers reveal server configuration and security posture:

**Essential Security Headers:**
- Content-Security-Policy (CSP)
- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security (HSTS)
- X-XSS-Protection
- Referrer-Policy
- Permissions-Policy

**Server-Specific Headers:**
- X-Powered-By (ASP.NET, PHP)
- X-AspNet-Version
- X-Generator (CMS-specific)
- Server (Apache, Nginx, IIS)

### Directory Listing and Access Control

Directory listing configuration affects information disclosure:

**Common Patterns:**
- Apache: Options +Indexes in httpd.conf or .htaccess
- Nginx: autoindex on; in location blocks
- IIS: Directory Browsing feature enabled

**Security Implications:**
- File and directory structure disclosure
- Source code exposure
- Backup file discovery
- Configuration file access

## Pre-requisite Knowledge

Before attempting server configuration analysis, you should understand:

1. **Web Server Architecture:** How Apache, Nginx, IIS, and other servers process requests.

2. **HTTP Protocol:** Request/response cycle, headers, status codes, and content types.

3. **Configuration File Locations:** Where different servers store configuration files.

4. **Security Best Practices:** Recommended security configurations for each server type.

5. **Fingerprinting Concepts:** Passive vs. active analysis, false positive/negative considerations, and confidence scoring.

6. **Ethical Hacking Principles:** Authorization requirements, testing boundaries, and responsible disclosure.

## Step-by-Step Methodology

### Phase 1: Initial Reconnaissance

**Step 1: HTTP Header Analysis**
Begin by analyzing HTTP response headers for server indicators:

```bash
curl -I https://target.com
```

Look for:
- Server header variations (Apache, Nginx, IIS, etc.)
- X-Powered-By headers (PHP, ASP.NET, etc.)
- Custom headers with server-specific values
- Security header presence/absence

**Step 2: Error Page Analysis**
Trigger error pages to reveal server information:

```bash
# 404 Not Found
curl -s https://target.com/nonexistent-page-12345

# 403 Forbidden
curl -s https://target.com/forbidden-resource

# 500 Internal Server Error
curl -s "https://target.com/?invalid= parameter"
```

Analyze error page patterns:
- Default error page formatting
- Server version information
- Debug information exposure
- Custom error page implementation

**Step 3: Default File Access Testing**
Test for common default files:

```bash
# Apache defaults
curl -I https://target.com/server-status
curl -I https://target.com/server-info
curl -I https://target.com/.htaccess

# Nginx defaults
curl -I https://target.com/nginx_status
curl -I https://target.com/nginx_status

# IIS defaults
curl -I https://target.com/iisstart.htm
curl -I https://target.comaspnet_client/
```

### Phase 2: Directory Listing Detection

**Step 4: Common Directory Testing**
Test for directory listing on common directories:

```bash
# Web root directories
curl -s https://target.com/
curl -s https://target.com/images/
curl -s https://target.com/uploads/
curl -s https://target.com/backup/

# Application directories
curl -s https://target.com/wp-content/
curl -s https://target.com/wp-includes/
curl -s https://target.com/admin/
```

**Step 5: Hidden Directory Discovery**
Use wordlists to discover hidden directories:

```bash
# Using dirb
dirb https://target.com /usr/share/wordlists/dirb/common.txt

# Using dirbuster
dirbuster -u https://target.com -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# Using ffuf
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt
```

**Step 6: Configuration File Probing**
Test for accessible configuration files:

```bash
# Apache
curl -I https://target.com/.htaccess
curl -I https://target.com/.htpasswd

# Nginx
curl -I https://target.com/nginx.conf
curl -I https://target.com/etc/nginx/nginx.conf

# IIS
curl -I https://target.com/web.config
curl -I https://target.com/web.config.bak

# PHP
curl -I https://target.com/php.ini
curl -I https://target.com/php.ini.bak
```

### Phase 3: Security Header Analysis

**Step 7: Security Header Inventory**
Document all security headers present:

```bash
curl -D- https://target.com | grep -i "content-security-policy\|x-frame-options\|x-content-type-options\|strict-transport-security\|x-xss-protection\|referrer-policy\|permissions-policy"
```

**Step 8: Security Header Analysis**
Analyze each security header for weaknesses:

```bash
# CSP analysis
curl -D- https://target.com | grep -i "content-security-policy"

# HSTS analysis
curl -D- https://target.com | grep -i "strict-transport-security"

# X-Frame-Options analysis
curl -D- https://target.com | grep -i "x-frame-options"
```

**Step 9: Missing Header Detection**
Identify missing security headers:

```bash
# Check for common missing headers
for header in "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "Strict-Transport-Security"; do
  echo "Checking $header..."
  curl -D- https://target.com | grep -i "$header" || echo "$header missing"
done
```

### Phase 4: Server Version and Configuration Detection

**Step 10: Version Detection**
Attempt to determine server version:

```bash
# Server header analysis
curl -I https://target.com | grep -i "server"

# X-Powered-By analysis
curl -I https://target.com | grep -i "x-powered-by"

# Error page version leakage
curl -s https://target.com/nonexistent-page-12345 | grep -i "apache\|nginx\|iis"
```

**Step 11: Module and Extension Detection**
Identify server modules and extensions:

```bash
# Apache modules
curl -I https://target.com/server-status

# Nginx modules
curl -I https://target.com/nginx_status

# IIS extensions
curl -I https://target.comaspnet_client/
```

**Step 12: Configuration Analysis**
Analyze configuration patterns:

```bash
# Access control testing
curl -I https://target.com/admin/
curl -I https://target.com/.env
curl -I https://target.com/config.php

# HTTP method testing
curl -X OPTIONS https://target.com
curl -X TRACE https://target.com
curl -X PUT https://target.com/test.txt
```

## Tool Arsenal with Exact Commands

### Primary Analysis Tools

**1. Nikto (Web Server Scanner)**
```bash
# Basic scan
nikto -h https://target.com

# Scan specific port
nikto -h target.com -p 8080

# Scan with authentication
nikto -h https://target.com -id user:password

# Scan multiple targets
nikto -h targets.txt
```

**2. Nmap Scripts (NSE)**
```bash
# http-server-header
nmap --script http-server-header -p 80,443 target.com

# http-headers
nmap --script http-headers -p 80,443 target.com

# http-methods
nmap --script http-methods -p 80,443 target.com

# http-security-headers
nmap --script http-security-headers -p 80,443 target.com
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

**5. Curl for Manual Testing**
```bash
# Header analysis
curl -D- https://target.com

# Cookie analysis
curl -c- -b- https://target.com

# Follow redirects
curl -L https://target.com

# Custom headers
curl -H "X-Forwarded-For: 127.0.0.1" https://target.com
```

**6. Directory Enumeration Tools**
```bash
# dirb
dirb https://target.com /usr/share/wordlists/dirb/common.txt

# dirbuster
dirbuster -u https://target.com -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# ffuf
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt

# gobuster
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt
```

**7. Security Header Analysis Tools**
```bash
# securityheaders.com API
curl "https://securityheaders.com/?q=target.com&followRedirects=on"

# testssl.sh
testssl https://target.com
```

## Real-World Case Studies

### Case Study 1: Apache Misconfiguration Exposure

**Scenario:** A corporate website exposed sensitive information through Apache misconfigurations.

**Detection Process:**
1. Server header revealed Apache/2.4.41 (Ubuntu)
2. /server-status endpoint accessible without authentication
3. /server-info endpoint revealed loaded modules
4. .htaccess file accessible showing directory restrictions
5. Directory listing enabled on /uploads/ directory

**Findings:**
- Server version disclosure (Apache 2.4.41)
- Module information disclosure (mod_ssl, mod_rewrite, mod_security)
- Directory structure exposure (/uploads/ contained backup files)
- .htaccess revealed authentication bypass attempts

**Impact:** The information gathered enabled targeted vulnerability research for Apache 2.4.41 and revealed potential paths for further exploitation.

### Case Study 2: Nginx Reverse Proxy Misconfiguration

**Scenario:** An Nginx reverse proxy configuration exposed internal services.

**Detection Process:**
1. Server header revealed Nginx/1.18.0
2. Proxy header analysis revealed internal IP addresses
3. X-Forwarded-For headers accepted without validation
4. Proxy_pass configuration leaked internal hostnames
5. Error pages revealed backend server information

**Findings:**
- Internal IP address disclosure (10.0.1.x range)
- Backend server hostname exposure
- SSRF potential through proxy misconfiguration
- Missing access controls on admin endpoints

**Impact:** The proxy misconfiguration enabled SSRF attacks and internal network reconnaissance.

### Case Study 3: IIS Default Configuration Weaknesses

**Scenario:** An IIS server with default configurations exposed multiple vulnerabilities.

**Detection Process:**
1. Server header revealed Microsoft-IIS/10.0
2. Default IIS welcome page accessible
3. ASP.NET version disclosure in X-AspNet-Version header
4. web.config file accessible showing connection strings
5. Directory browsing enabled on /images/ directory

**Findings:**
- IIS version disclosure (10.0)
- ASP.NET version disclosure (4.0.30319)
- Connection string exposure in web.config
- Directory listing on multiple directories
- Default application pool identity revealed

**Impact:** The default configurations provided multiple attack vectors including information disclosure and potential credential theft.

### Case Study 4: Multi-Server Environment Analysis

**Scenario:** A complex web application used multiple server types across different components.

**Detection Process:**
1. Main site: Nginx 1.18.0 (reverse proxy)
2. API backend: Apache 2.4.41 (application server)
3. Admin panel: IIS 10.0 (internal tool)
4. Each server had different security configurations

**Findings:**
- Mixed server environment with different security postures
- Inconsistent security header implementations
- Different vulnerability profiles for each server type
- Complex attack surface requiring multiple testing approaches

**Impact:** The multi-server environment required comprehensive testing across different server technologies, each with distinct vulnerability classes.

## Advanced Techniques and Bypass

### Server Version Obfuscation Detection

Many administrators attempt to hide server versions through:

**1. Header Manipulation:**
- Removing Server header
- Modifying X-Powered-By header
- Adding misleading headers
- Bypass: Analyze other header patterns and timing responses

**2. Custom Error Pages:**
- Replacing default error pages
- Removing version information
- Bypass: Trigger specific error types that bypass custom pages

**3. Response Modification:**
- Changing response signatures
- Adding randomization
- Bypass: Analyze response patterns and timing

### Advanced Fingerprinting Techniques

**1. Timing-Based Detection:**
```bash
# Measure response times for different request types
time curl -s https://target.com/ > /dev/null
time curl -s https://target.com/nonexistent > /dev/null
```

Different servers have different response time patterns for existing vs. non-existing resources.

**2. Error Message Analysis:**
```bash
# Trigger server-specific errors
curl -s "https://target.com/?=<script>alert(1)</script>"
curl -s "https://target.com/nonexistent-api-endpoint"
```

**3. Header Order Analysis:**
```bash
# Analyze header ordering patterns
curl -D- https://target.com | head -20
```

Different servers have distinct header ordering patterns.

### WAF and CDN Bypass Techniques

**1. IP Address Direct Access:**
```bash
# Bypass CDN by accessing origin directly
dig target.com
curl -H "Host: target.com" https://[origin-ip]
```

**2. Subdomain Discovery:**
```bash
# Find origin subdomains
subfinder -d target.com -o subdomains.txt
httpx -l subdomains.txt -o live-hosts.txt
```

**3. Certificate Transparency Analysis:**
```bash
# Find alternative domains
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u
```

## Detection and Indicators

### Common Server Signatures

**Apache Indicators:**
- Header: Server: Apache/2.4.x
- Files: .htaccess, .htpasswd
- Directories: /server-status, /server-info
- Error pages: Apache-specific formatting

**Nginx Indicators:**
- Header: Server: nginx/1.x.x
- Files: nginx.conf, default.conf
- Directories: /nginx_status
- Error pages: Nginx-specific formatting

**IIS Indicators:**
- Header: Server: Microsoft-IIS/10.0
- Files: web.config, iisstart.htm
- Directories: /aspnet_client/
- Error pages: IIS-specific formatting

**LiteSpeed Indicators:**
- Header: Server: LiteSpeed/6.x
- Files: .htaccess (compatible)
- Directories: /ls-cache/
- Error pages: LiteSpeed-specific formatting

### Confidence Scoring Matrix

| Indicator Type | Weight | Examples |
|----------------|--------|----------|
| Server header version | High | Apache/2.4.41 |
| Default file access | High | /server-status accessible |
| Error page patterns | Medium | Server-specific formatting |
| Header ordering | Medium | Distinct header sequences |
| Timing patterns | Low | Response time variations |
| Custom headers | Low | Server-specific additions |

## Impact Assessment

### Security Implications by Server Type

**Apache:**
- Module-based attack surface
- .htaccess misconfigurations
- Directory listing vulnerabilities
- Version-specific CVEs

**Nginx:**
- Reverse proxy misconfigurations
- Path traversal vulnerabilities
- SSRF through proxy_pass
- Configuration file exposure

**IIS:**
- ASP.NET specific vulnerabilities
- Default configuration weaknesses
- Application pool misconfigurations
- Handler mapping issues

**LiteSpeed/OpenLiteSpeed:**
- Apache compatibility vulnerabilities
- Cache poisoning potential
- Performance-related security issues
- Configuration exposure

### Risk Assessment Framework

1. **Server Version Risk:** Outdated versions = known vulnerabilities
2. **Configuration Risk:** Default configurations = known attack vectors
3. **Header Disclosure Risk:** Information leakage = targeted attacks
4. **Directory Listing Risk:** File exposure = source code disclosure
5. **Access Control Risk:** Weak controls = unauthorized access

## Common Pitfalls

### Detection Errors

1. **False Positives from CDNs:**
   - CDN headers may mask origin server information
   - Solution: Analyze multiple indicators, not single signatures

2. **Version Mismatches:**
   - Custom builds may have different version indicators
   - Solution: Cross-validate version indicators across multiple sources

3. **Obfuscation Blindness:**
   - Security configurations may hide server information
   - Solution: Use multiple detection methods, including timing analysis

4. **Multi-Server Complexity:**
   - Different servers may be used for different components
   - Solution: Test each component independently

5. **Configuration File Changes:**
   - Custom configurations may deviate from defaults
   - Solution: Analyze actual behavior, not expected configurations

### Methodology Pitfalls

1. **Relying on Single Indicators:**
   - One server indicator is insufficient for confident identification
   - Solution: Require multiple independent indicators

2. **Ignoring Version Detection:**
   - Server version is critical for vulnerability research
   - Solution: Always attempt version detection after server identification

3. **Neglecting Configuration Analysis:**
   - Server configuration affects security posture
   - Solution: Analyze configuration files and settings when accessible

4. **Overlooking Security Headers:**
   - Security headers indicate security control implementation
   - Solution: Always analyze security header presence and configuration

## Integration with Other Recon Areas

### Server Configuration in Recon Workflow

**1. Technology Stack Analysis:**
- Server configuration informs security testing approach
- Module/extension detection reveals additional attack surface
- Configuration analysis reveals security controls

**2. Vulnerability Research:**
- Server version enables targeted CVE research
- Module versions enable component-specific vulnerability hunting
- Configuration patterns indicate security control implementation

**3. Attack Surface Mapping:**
- Server architecture defines testing boundaries
- Configuration files reveal additional endpoints
- Directory structures indicate application organization

**4. Compliance Assessment:**
- Server configurations indicate security control implementation
- Security headers reveal compliance with standards
- Access control configurations indicate security policies

### Cross-Reference with Other Recon Skills

- **CMS Detection:** CMS platforms often run on specific servers
- **Framework Identification:** Framework may influence server configuration
- **SSL/TLS Analysis:** Server affects TLS configuration
- **HTTP Header Intelligence:** Server generates specific header patterns

## Reporting Template

### Server Configuration Analysis Report

**Executive Summary:**
- Server Type: [Apache/Nginx/IIS/etc.]
- Version: [Specific version if detected]
- Configuration Status: [Secure/Misconfigured/Default]
- Key Findings: [Brief summary]

**Technical Findings:**

1. **Server Identification:**
   - Server type: [Identified server]
   - Version: [Version if detected]
   - Configuration: [Configuration patterns observed]

2. **Security Header Analysis:**
   - Headers present: [List security headers]
   - Headers missing: [List missing headers]
   - Configuration issues: [Identified problems]

3. **Directory and File Analysis:**
   - Directory listing: [Enabled/Disabled]
   - Sensitive files: [Accessible files]
   - Configuration exposure: [Exposed configurations]

4. **Security Implications:**
   - Known vulnerabilities: [CVEs if version-specific]
   - Attack surface: [Relevant attack vectors]
   - Configuration concerns: [Identified issues]

**Recommendations:**
1. [Server-specific security recommendations]
2. [Configuration hardening suggestions]
3. [Security header implementation]
4. [Monitoring recommendations]

**Evidence:**
- Screenshots of detection indicators
- HTTP request/response samples
- Configuration file contents
- Directory listings

## Practice Labs

### Lab 1: Basic Server Configuration Analysis

**Objective:** Identify server types and analyze configurations.

**Setup:**
```bash
# Create test environment
mkdir server-labs && cd server-labs

# Set up different servers
# Apache
apt install apache2

# Nginx
apt install nginx

# IIS (Windows Server)
# Install via Server Manager
```

**Exercises:**
1. Configure each server with default settings
2. Practice detection with WhatWeb, manual techniques
3. Document configuration indicators for each server
4. Compare detection difficulty across servers

### Lab 2: Misconfiguration Detection

**Objective:** Identify security misconfigurations in server setups.

**Setup:**
- Apache with directory listing enabled
- Nginx with proxy misconfiguration
- IIS with default configurations

**Exercises:**
1. Attempt detection using standard techniques
2. Identify misconfigurations through manual testing
3. Practice security header analysis
4. Document vulnerability indicators

### Lab 3: Multi-Server Environment

**Objective:** Analyze complex multi-server environments.

**Setup:**
- Nginx reverse proxy
- Apache application server
- IIS admin panel

**Exercises:**
1. Enumerate all server components
2. Test each server independently
3. Create comprehensive server inventory
4. Identify security implications of mixed server environment

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
5. **Continuous Learning:** Stay updated with server security developments

## Quick Reference Cheat Sheet

### Apache Detection Commands
```bash
# Quick detection
curl -I https://target.com | grep -i "server"
curl -I https://target.com/server-status
curl -I https://target.com/.htaccess

# Version detection
curl -I https://target.com | grep -i "apache"
curl -s https://target.com/nonexistent-page | grep -i "apache"
```

### Nginx Detection Commands
```bash
# Quick detection
curl -I https://target.com | grep -i "server"
curl -I https://target.com/nginx_status

# Version detection
curl -I https://target.com | grep -i "nginx"
curl -s https://target.com/nonexistent-page | grep -i "nginx"
```

### IIS Detection Commands
```bash
# Quick detection
curl -I https://target.com | grep -i "server"
curl -I https://target.com/iisstart.htm

# Version detection
curl -I https://target.com | grep -i "iis"
curl -s https://target.com/nonexistent-page | grep -i "iis"
```

### Security Header Analysis Commands
```bash
# Check all security headers
curl -D- https://target.com | grep -iE "content-security-policy|x-frame-options|x-content-type-options|strict-transport-security|x-xss-protection|referrer-policy|permissions-policy"

# Check for missing headers
for header in "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "Strict-Transport-Security"; do
  curl -D- https://target.com | grep -i "$header" || echo "$header missing"
done
```

### Confidence Assessment
- **High (90%+):** Multiple independent indicators, version-specific files accessible
- **Medium (70-89%):** Several indicators, but some inconsistencies
- **Low (50-69%):** Limited indicators, possible obfuscation
- **Uncertain (<50%):** Insufficient evidence for confident identification
