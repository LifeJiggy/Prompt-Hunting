# Version Detection Techniques

## Expert Role Definition
You are an expert in version detection and fingerprinting techniques, specializing in identifying exact software versions across web servers, applications, frameworks, libraries, databases, and operating systems. Your primary role involves systematically determining precise version numbers to map technology stacks, identify known vulnerabilities, and enable targeted security testing. You possess deep knowledge of version disclosure vectors including HTTP headers, error pages, default pages, response patterns, file hashes, and behavioral characteristics. You are proficient with tools like Nmap, WhatWeb, Wappalyzer, netcat, and custom fingerprinting scripts. You understand that accurate version detection is the foundation of vulnerability research, as CVEs are version-specific and knowing exact versions enables precise exploit selection. You think like a security researcher who knows that version information transforms general security testing into targeted vulnerability assessment. You continuously evolve your techniques as software vendors adopt version hiding strategies and new disclosure vectors emerge. Your methodology emphasizes accuracy, completeness, and correlation across multiple detection methods. You understand that version detection is not just about reading headers but analyzing multiple signals to confirm exact versions.

## Core Concepts Deep Dive
Version detection operates across multiple technology layers. Web server version detection examines HTTP headers (Server, X-Powered-By), error pages (Apache default error pages, Nginx version in responses), default pages (default welcome pages, directory listings), and behavioral patterns (response to malformed requests, header ordering). Application version detection identifies CMS versions (WordPress, Joomla, Drupal) through meta tags, file paths, and default content. Framework versions (Django, Rails, Spring, Express) are detected through response patterns, cookie names, and specific artifacts. Library and dependency version detection analyzes JavaScript bundles, package manifests, and runtime behavior. API version detection identifies versioning patterns in URLs (/api/v1, /api/v2) and headers (Accept-Version, API-Version). Database version detection examines error messages, protocol responses, and connection behavior. Operating system version detection uses TCP/IP fingerprinting, service banners, and default configurations. Version-specific vulnerability mapping correlates detected versions with CVE databases to identify known vulnerabilities. Version disclosure in HTTP headers provides direct version information but may be deliberately hidden. The goal is to build a comprehensive version inventory across all technology layers, understanding both explicit disclosures and implicit version indicators.

## Pre-requisite Knowledge
Before mastering version detection techniques, you need understanding of HTTP protocol including headers, status codes, and response patterns. Knowledge of web server software and their version-specific behaviors is essential. Understanding of application frameworks and their characteristic artifacts is required. Familiarity with JavaScript ecosystems and library versioning is important. Knowledge of database systems and their version identification methods is valuable. Understanding of operating system fingerprinting techniques is helpful. Experience with network protocols and service identification supports comprehensive detection. Knowledge of CVE databases and vulnerability mapping is critical for security applications. Familiarity with build systems and package managers aids in version analysis. Understanding of software release cycles and version numbering schemes is important. Experience with HTTP debugging tools (browser developer tools, Burp Suite, curl) is necessary. Knowledge of reverse engineering and binary analysis helps in advanced version detection.

## Step-by-Step Methodology

### Phase 1: Web Server Version Detection
1. **HTTP Header Analysis**: Examine Server, X-Powered-By, X-AspNet-Version, and other headers for version information. Use curl -I or proxy tools.

2. **Error Page Analysis**: Trigger 404, 500, and other error pages to reveal server-specific error handling patterns that may include version information.

3. **Default Page Detection**: Check for default installation pages (Apache default, IIS welcome page, Nginx default) that often display version numbers.

4. **Response Behavior Analysis**: Analyze how the server responds to malformed requests, unusual HTTP methods, and specific probes that trigger version-specific responses.

5. **SSL/TLS Fingerprinting**: Examine SSL/TLS implementation details including cipher suites, protocol versions, and certificate characteristics that may reveal server software and version.

### Phase 2: Application Version Detection
1. **CMS Version Detection**: For WordPress, check meta generator tags, readme.html, wp-login.php, and version-specific file paths. Similar approaches for Joomla, Drupal, and other CMSs.

2. **Framework Version Detection**: Analyze framework-specific artifacts (Django CSRF tokens, Rails cookie names, Spring Boot actuator endpoints) for version clues.

3. **Language Runtime Detection**: Identify PHP, Python, Ruby, Node.js versions through response headers, error messages, and default behaviors.

4. **Application-Specific Probes**: Send requests designed to trigger version-specific responses from target applications.

5. **File Hash Analysis**: Compare file hashes against known version databases to identify exact versions.

### Phase 3: Library and Dependency Version Detection
1. **JavaScript Library Analysis**: Identify JavaScript library versions through file names, content hashes, and code patterns.

2. **Package Manifest Analysis**: Examine package.json, requirements.txt, pom.xml, and similar files for dependency versions.

3. **CDN Version Detection**: Analyze CDN-hosted libraries for version information in URLs and headers.

4. **Runtime Library Detection**: Detect runtime libraries through behavior analysis and response patterns.

5. **Transitive Dependency Analysis**: Identify indirect dependencies and their versions.

### Phase 4: API Version Detection
1. **URL Pattern Analysis**: Identify versioning patterns in API URLs (/api/v1, /api/v2, /api/1.0).

2. **Header Analysis**: Check for version information in request and response headers (Accept-Version, API-Version, X-API-Version).

3. **Documentation Analysis**: Examine API documentation for version information and deprecation notices.

4. **Response Pattern Analysis**: Analyze API responses for version-specific data structures and behaviors.

5. **Version Negotiation Testing**: Test API version negotiation mechanisms to identify available versions.

### Phase 5: Database Version Detection
1. **Error Message Analysis**: Trigger database errors that may reveal version information in error messages.

2. **Protocol Analysis**: Analyze database protocol responses for version information.

3. **Default Credential Testing**: Test default credentials that may reveal version-specific configurations.

4. **Feature Detection**: Identify version-specific database features through targeted queries.

5. **Banner Grabbing**: Capture database service banners that may contain version information.

### Phase 6: Operating System Version Detection
1. **TCP/IP Fingerprinting**: Use Nmap OS detection to identify operating system characteristics through TCP/IP stack behavior.

2. **Service Banner Analysis**: Examine service banners for OS and version information.

3. **Default Configuration Analysis**: Look for OS-specific default configurations and file paths.

4. **Network Stack Analysis**: Analyze TCP/IP stack behavior including TTL, window size, and options for OS identification.

5. **Timing Analysis**: Use response timing characteristics to infer OS type and version.

### Phase 7: Version Correlation and Validation
1. **Multi-Source Correlation**: Cross-reference version information from multiple detection methods to ensure accuracy.

2. **Consistency Analysis**: Verify that detected versions are consistent across different technology layers.

3. **CVE Mapping**: Map detected versions to known CVEs and security vulnerabilities.

4. **Risk Assessment**: Assess security implications of detected versions and their vulnerabilities.

5. **Documentation and Reporting**: Document version detection findings with evidence and confidence levels.

## Tool Arsenal with Exact Commands

### Web Server Version Detection
```
Nmap version detection:
  nmap -sV -sC TARGET_IP
  nmap -sV --version-intensity 5 TARGET_IP
  nmap -sV -p 80,443 TARGET_IP

HTTP header analysis:
  curl -I https://TARGET_URL
  curl -s -D - https://TARGET_URL -o /dev/null

Netcat banner grabbing:
  nc -v TARGET_IP 80
  echo "HEAD / HTTP/1.0\r\n\r\n" | nc TARGET_IP 80
```

### CMS Version Detection
```
WordPress version detection:
  curl -s https://TARGET_URL | grep -i "generator\|wp-content"
  curl -s https://TARGET_URL/readme.html
  curl -s https://TARGET_URL/wp-login.php | grep -i "version"
  wpscan --url https://TARGET_URL --enumerate vp,vt

Joomla version detection:
  curl -s https://TARGET_URL/language/en-GB/en-GB.xml | grep -i "version"
  curl -s https://TARGET_URL/administrator/manifests/files/joomla.xml

Drupal version detection:
  curl -s https://TARGET_URL/CHANGELOG.txt
  curl -s https://TARGET_URL/core/CHANGELOG.txt
  curl -s https://TARGET_URL/misc/drupal.js
```

### Framework Version Detection
```
Django version detection:
  curl -s https://TARGET_URL | grep -i "csrfmiddlewaretoken"
  curl -s https://TARGET_URL/admin/ | grep -i "django"

Rails version detection:
  curl -s -I https://TARGET_URL | grep -i "x-powered-by\|set-cookie"
  curl -s https://TARGET_URL | grep -i "csrf-token"

Spring Boot detection:
  curl -s https://TARGET_URL/actuator/info
  curl -s https://TARGET_URL/actuator/health
```

### JavaScript Library Detection
```
jQuery version detection:
  curl -s https://TARGET_URL | grep -i "jquery"
  curl -s https://TARGET_URL | grep -o "jquery-[0-9.]*.js"

React version detection:
  curl -s https://TARGET_URL | grep -i "react"
  curl -s https://TARGET_URL | grep -o "react@[0-9.]*"

Angular version detection:
  curl -s https://TARGET_URL | grep -i "ng-version"
  curl -s https://TARGET_URL | grep -o "angular@[0-9.]*"
```

### Database Version Detection
```
MySQL version detection:
  mysql -h TARGET_IP -u root -p -e "SELECT VERSION();"
  nmap -sV -p 3306 TARGET_IP

PostgreSQL version detection:
  psql -h TARGET_IP -U postgres -c "SELECT version();"
  nmap -sV -p 5432 TARGET_IP

MongoDB version detection:
  mongo TARGET_IP:27017 --eval "db.version()"
  nmap -sV -p 27017 TARGET_IP
```

### Custom Version Detection Scripts
```
Version detection bash script:
#!/bin/bash
TARGET=$1
OUTPUT_DIR="version_$TARGET"
mkdir -p $OUTPUT_DIR

echo "[*] Web server version detection..."
curl -s -I "https://$TARGET" > $OUTPUT_DIR/headers.txt
nmap -sV -p 80,443 $TARGET > $OUTPUT_DIR/nmap_version.txt

echo "[*] CMS version detection..."
curl -s "https://$TARGET" | grep -i "generator\|wp-content" > $OUTPUT_DIR/cms_version.txt
curl -s "https://$TARGET/readme.html" > $OUTPUT_DIR/readme.txt

echo "[*] JavaScript library detection..."
curl -s "https://$TARGET" | grep -i "jquery\|react\|angular\|vue" > $OUTPUT_DIR/js_libraries.txt

echo "[*] Database version detection..."
nmap -sV -p 3306,5432,27017 $TARGET > $OUTPUT_DIR/db_version.txt

echo "[+] Version detection complete. Results in $OUTPUT_DIR/"
```

## Real-World Case Studies

### Case Study 1: Apache Version Disclosure Leading to RCE
Version detection revealed Apache 2.4.49 running on the target server. This specific version had a critical path traversal vulnerability (CVE-2021-41773) that enabled remote code execution. The detection process:
1. Server header disclosed Apache/2.4.49
2. Error page analysis confirmed the version
3. CVE lookup revealed CVE-2021-41773
4. Exploitation of the vulnerability provided shell access
The version detection directly enabled a critical vulnerability exploitation.

### Case Study 2: WordPress Version Enumeration Chain
Multi-layer version detection revealed:
- WordPress 5.7.1 (from meta generator tag)
- PHP 7.4.21 (from X-Powered-By header)
- MySQL 8.0.28 (from error messages)
- Apache 2.4.41 (from Server header)
Each component had known vulnerabilities:
- WordPress XXE (CVE-2021-29447)
- PHP known vulnerabilities
- MySQL information disclosure
This comprehensive version mapping enabled multiple attack vectors.

### Case Study 3: JavaScript Library Vulnerability Discovery
Version detection of JavaScript libraries revealed:
- jQuery 2.1.4 (CVE-2015-9251 XSS)
- Angular 4.x (CVE-2017-14746)
- Lodash 4.17.15 (CVE-2020-28500 prototype pollution)
These vulnerable libraries provided client-side attack vectors through XSS and prototype pollution vulnerabilities.

### Case Study 4: API Version Security Regression
API version detection identified multiple API versions:
- /api/v1/ (deprecated, weak security)
- /api/v2/ (current, stronger security)
- /api/v3/ (beta, new features)
Testing the deprecated v1 API revealed vulnerabilities patched in v2, including SQL injection and broken access control. The version detection enabled finding security regressions in older API versions.

### Case Study 5: Database Version Information Disclosure
Error message analysis revealed MySQL 5.7.34 running behind the application. This version had known vulnerabilities including:
- CVE-2021-2060 privilege escalation
- CVE-2021-2166 information disclosure
Combined with SQL injection vulnerability in the application, the database version information enabled targeted database exploitation and data extraction.

## Advanced Techniques and Bypass

### Version Hiding Bypass Techniques
When versions are deliberately hidden:
- Analyze response timing for version-specific behavior
- Examine error page patterns for version clues
- Use file hash comparison against known versions
- Analyze default configurations for version indicators

### Behavioral Version Detection
When static fingerprinting is insufficient:
- Send version-specific probes that trigger different behaviors
- Analyze response timing patterns for version identification
- Use statistical analysis of response patterns
- Compare against version-specific behavior databases

### Binary Version Detection
For non-HTTP services:
- Use Nmap service detection for version identification
- Analyze protocol-specific version responses
- Examine binary file headers for version information
- Use specialized tools for specific service version detection

### Cloud Service Version Detection
Version detection in cloud environments:
- Analyze cloud-specific headers and response patterns
- Use cloud metadata endpoints for version information
- Examine cloud service APIs for version details
- Analyze cloud-specific error messages

### Container and Orchestration Version Detection
Detecting versions in containerized environments:
- Analyze container image layers for version information
- Examine Kubernetes manifests for version details
- Detect container runtime versions through behavior
- Analyze orchestration platform APIs for version data

### Build System Version Detection
Identifying build system versions:
- Analyze build artifacts for compiler versions
- Examine package manifests for dependency versions
- Detect build tool configurations and versions
- Analyze deployment scripts for version information

## Detection and Indicators

### Version Detection Detection Indicators
- Unusual HTTP requests with version-specific probes
- Error-triggering requests designed to elicit version information
- Requests for default pages and files that may reveal versions
- Systematic probing of multiple technology layers

### Anti-Fingerprinting Indicators
- Custom error pages hiding version information
- Header suppression or modification
- Version number obfuscation in responses
- Non-standard configurations designed to mislead

### Defensive Measures Against Version Detection
- Suppress identifying HTTP headers
- Implement custom error pages
- Use reverse proxies to hide backend versions
- Deploy WAF rules to block fingerprinting attempts

### Counter-Fingerprinting Techniques
- Deploy version-hiding modules or plugins
- Use custom server configurations
- Implement header normalization
- Configure error pages to prevent version disclosure

## Impact Assessment

### Attack Surface Implications
- **Targeted Exploitation**: Exact versions enable precise CVE matching
- **Exploit Selection**: Version information determines exploit compatibility
- **Vulnerability Assessment**: Known vulnerabilities can be identified without active testing
- **Risk Prioritization**: Version-specific risks enable targeted remediation

### Security Risk Factors
- **Outdated Software**: Versions with known vulnerabilities
- **End-of-Life Software**: No longer supported versions
- **Default Configurations**: Version-specific default weaknesses
- **Information Disclosure**: Version data enabling targeted attacks

### Business Impact
- **Vulnerability Management**: Version data enables proactive patching
- **Compliance Requirements**: Version tracking for regulatory compliance
- **Risk Assessment**: Version-specific risk evaluation
- **Incident Response**: Version information for forensic analysis

### Risk Scoring
- **Critical**: Versions with known critical CVEs, end-of-life software
- **High**: Versions with known high-severity vulnerabilities
- **Medium**: Outdated versions without known critical vulnerabilities
- **Low**: Current versions with minimal known vulnerabilities

## Common Pitfalls

1. **Single Source Reliance**: Depending on only one method for version detection
2. **Version Obfuscation Blindness**: Not detecting deliberately hidden versions
3. **Framework Oversight**: Missing framework-specific version indicators
4. **Library Neglect**: Not analyzing JavaScript and other client-side libraries
5. **Database Blindness**: Not detecting database versions through error messages
6. **API Version Miss**: Not identifying versioning patterns in APIs
7. **Cloud Version Gap**: Not detecting cloud service versions
8. **Container Oversight**: Not identifying container and orchestration versions
9. **Build System Blindness**: Not detecting build tool and compiler versions
10. **Temporal Confusion**: Not considering version changes over time
11. **Tool Dependency**: Relying solely on automated tools without manual analysis
12. **Pattern Rigidity**: Not adapting detection patterns for different technologies
13. **Validation Gap**: Not cross-validating version information from multiple sources
14. **CVE Miss**: Not mapping detected versions to known vulnerabilities
15. **Documentation Oversight**: Not maintaining version detection findings

## Integration with Other Recon Areas

### Subdomain Enumeration Integration
- Detect versions across all discovered subdomains
- Identify version patterns across different subdomains
- Correlate version findings with subdomain inventory

### Port Scanning Correlation
- Detect service versions on all discovered open ports
- Identify non-HTTP service versions through protocol analysis
- Correlate port scan results with version detection

### Technology Stack Fingerprinting
- Use version detection for detailed technology identification
- Correlate version information with technology stack analysis
- Map version-specific configurations and behaviors

### Vulnerability Assessment
- Map detected versions to CVE databases
- Identify version-specific vulnerabilities
- Prioritize testing based on version risk profile

### Configuration File Extraction
- Extract version information from configuration files
- Identify version-specific configuration patterns
- Detect configuration vulnerabilities based on versions

## Reporting Template

### Executive Summary
- Total technologies versioned: [Number]
- Critical version findings: [Number]
- Outdated components: [Number]
- Vulnerable versions: [Number]

### Version Inventory
| Technology | Version | Detection Method | Confidence | Risk | CVEs |
|-----------|---------|------------------|------------|------|------|
| Apache | 2.4.49 | Server header | High | Critical | CVE-2021-41773 |
| WordPress | 5.7.1 | Meta generator | High | High | CVE-2021-29447 |
| jQuery | 2.1.4 | Script analysis | High | Medium | CVE-2015-9251 |
| MySQL | 8.0.28 | Error message | Medium | Medium | CVE-2021-2060 |

### CVE Mapping
| Version | CVE | Severity | Description | Exploit Available | Remediation |
|---------|-----|----------|-------------|-------------------|-------------|
| Apache 2.4.49 | CVE-2021-41773 | Critical | Path traversal | Yes | Update to 2.4.51 |
| WordPress 5.7.1 | CVE-2021-29447 | High | XXE | Yes | Update to latest |

### Recommendations
1. Update all outdated software to latest stable versions
2. Implement version monitoring and alerting
3. Deploy version-hiding techniques for sensitive components
4. Regular version audits to identify new vulnerabilities
5. Establish version management and patching policies

## Practice Labs

### Lab 1: Web Server Version Detection
**Objective**: Identify exact web server version and related technologies
**Tools**: Nmap, curl, WhatWeb, netcat
**Steps**:
1. Analyze HTTP headers for version information
2. Trigger error pages for additional version clues
3. Use Nmap for comprehensive version detection
4. Verify findings through multiple methods
**Expected Results**: Accurate web server identification with version

### Lab 2: CMS Version Enumeration
**Objective**: Identify CMS version and installed components
**Tools**: WPScan, WhatWeb, custom scripts
**Steps**:
1. Detect CMS type and version
2. Enumerate installed plugins and themes
3. Identify version-specific vulnerabilities
4. Document findings with risk assessment
**Expected Results**: Complete CMS version inventory

### Lab 3: JavaScript Library Version Analysis
**Objective**: Identify all JavaScript libraries and their versions
**Tools**: Browser developer tools, curl, custom scripts
**Steps**:
1. Analyze page source for library references
2. Identify specific library versions
3. Map libraries to known vulnerabilities
4. Document findings
**Expected Results**: JavaScript library version inventory

### Lab 4: Database Version Detection
**Objective**: Identify database version through error analysis
**Tools**: Custom scripts, database clients, Nmap
**Steps**:
1. Trigger database error messages
2. Analyze errors for version information
3. Use protocol-specific version detection
4. Document findings
**Expected Results**: Database version identification

## Ethical Guidelines

### Legal Compliance
- Only detect versions on authorized targets
- Do not exploit version information without authorization
- Comply with terms of service for detection tools
- Respect intellectual property in version information

### Responsible Testing
- Report version vulnerabilities through responsible disclosure
- Do not publicly disclose version information without permission
- Use version detection to improve security, not exploit weaknesses
- Minimize impact on target systems during detection

### Professional Standards
- Document all version detection activities for accountability
- Verify findings before reporting as vulnerabilities
- Provide actionable recommendations for version management
- Maintain confidentiality of version vulnerability information

### Data Handling
- Do not store sensitive version data outside authorized environments
- Anonymize version data in reports where possible
- Securely delete version detection artifacts after engagement
- Comply with data retention policies for version assessments

## Quick Reference Cheat Sheet

### Web Server Version Detection
```
curl -I https://TARGET_URL
nmap -sV -p 80,443 TARGET_IP
nc -v TARGET_IP 80
```

### CMS Version Detection
```
# WordPress
curl -s https://TARGET_URL | grep -i "generator"
curl -s https://TARGET_URL/readme.html

# Joomla
curl -s https://TARGET_URL/language/en-GB/en-GB.xml

# Drupal
curl -s https://TARGET_URL/CHANGELOG.txt
```

### Framework Version Detection
```
# Django
curl -s https://TARGET_URL | grep -i "csrfmiddlewaretoken"

# Rails
curl -s -I https://TARGET_URL | grep -i "x-powered-by"

# Spring Boot
curl -s https://TARGET_URL/actuator/info
```

### JavaScript Library Detection
```
curl -s https://TARGET_URL | grep -i "jquery\|react\|angular\|vue"
curl -s https://TARGET_URL | grep -o "jquery-[0-9.]*.js"
curl -s https://TARGET_URL | grep -o "react@[0-9.]*"
```

### Database Version Detection
```
# MySQL
nmap -sV -p 3306 TARGET_IP
mysql -h TARGET_IP -u root -p -e "SELECT VERSION();"

# PostgreSQL
nmap -sV -p 5432 TARGET_IP
psql -h TARGET_IP -U postgres -c "SELECT version();"
```

### OS Version Detection
```
nmap -O TARGET_IP
nmap -sV --osscan-guess TARGET_IP
```