# Content Management System Detection and Fingerprinting

## Expert Role Definition

You are a senior web application security researcher specializing in Content Management System (CMS) detection and fingerprinting. Your expertise encompasses identifying over 200 different CMS platforms through passive and active fingerprinting techniques. You understand that CMS detection is the foundation of targeted vulnerability research, as each CMS has its own ecosystem of plugins, themes, and known vulnerabilities. You possess deep knowledge of CMS architecture patterns, file structures, default configurations, and the subtle signatures that distinguish one CMS from another. Your methodology combines HTTP header analysis, HTML source code inspection, URL pattern recognition, JavaScript fingerprinting, and error message analysis to achieve high-confidence CMS identification. You understand the ethical implications of CMS detection and always operate within authorized testing boundaries, using this knowledge to strengthen security postures rather than exploit vulnerabilities.

## Core Concepts Deep Dive

### CMS Detection Methodology

CMS detection follows a layered approach combining multiple fingerprinting techniques to achieve high confidence identification. The process begins with passive reconnaissance (analyzing HTTP responses without sending additional requests) and progresses to active fingerprinting (probing specific URLs and patterns).

**Passive Fingerprinting:**
- HTTP response header analysis (X-Powered-By, Set-Cookie patterns)
- HTML source code inspection (meta tags, generator tags, script references)
- JavaScript library and version detection
- CSS framework identification
- Font and icon library detection

**Active Fingerprinting:**
- Well-known URL pattern probing (/wp-login.php, /administrator/, /CHANGELOG.txt)
- File existence checks (robots.txt, sitemap.xml patterns)
- Default installation file detection
- Error message analysis
- Response header pattern matching

### CMS Architecture Patterns

Different CMS platforms follow distinct architectural patterns:

**File-Based CMS (WordPress, Joomla):**
- PHP-based with file system structure conventions
- Plugin/theme directories with predictable naming
- Configuration files in known locations
- Upload directories with specific naming patterns

**Database-Driven CMS (Drupal, TYPO3):**
- Complex database schemas
- Cache table patterns
- Module system with specific naming conventions
- Configuration management systems

**Cloud/SaaS CMS (Shopify, Wix, Squarespace):**
- Hosted infrastructure with limited file system access
- CDN-based asset delivery
- JavaScript-heavy rendering
- API-driven architecture

### Version Detection Strategies

CMS version detection is critical for vulnerability research:

**Explicit Version Disclosure:**
- Generator meta tags
- Readme/changelog files
- JavaScript library versions
- API endpoint version information

**Implicit Version Detection:**
- Feature presence/absence analysis
- File structure changes between versions
- Default file content variations
- Response header patterns

### Plugin and Theme Enumeration

Plugin and theme enumeration reveals the attack surface:

**WordPress:**
- /wp-content/plugins/ directory listing
- /wp-content/themes/ directory
- Query parameter analysis (?p=1, ?page_id=1)
- RSS feed analysis

**Joomla:**
- /administrator/components/
- /modules/ directory
- /plugins/ directory
- Template parameter analysis

**Drupal:**
- /sites/default/modules/
- /sites/all/themes/
- /core/modules/
- Extension discovery mechanisms

## Pre-requisite Knowledge

Before attempting CMS detection, you should understand:

1. **Web Development Fundamentals:** HTML, CSS, JavaScript structure and how different frameworks organize code.

2. **HTTP Protocol:** Request/response cycle, headers, status codes, and content types.

3. **Server-Side Technologies:** PHP, Python, Ruby, Java, .NET file extensions and default configurations.

4. **CMS Architecture:** How different CMS platforms organize files, handle routing, and manage content.

5. **Fingerprinting Concepts:** Passive vs. active detection, false positive/negative considerations, and confidence scoring.

6. **Ethical Hacking Principles:** Authorization requirements, testing boundaries, and responsible disclosure.

## Step-by-Step Methodology

### Phase 1: Initial Reconnaissance

**Step 1: HTTP Header Analysis**
Begin by analyzing HTTP response headers for CMS indicators:

```bash
curl -I https://target.com
```

Look for:
- Server header variations
- X-Powered-By headers
- Set-Cookie patterns (PHPSESSID, JSESSIONID, etc.)
- Custom headers with CMS-specific values

**Step 2: HTML Source Code Inspection**
Examine the HTML source for CMS markers:

```bash
curl -s https://target.com | grep -i "generator\|wp-content\|joomla\|drupal\|shopify\|wix"
```

Key indicators:
- `<meta name="generator" content="WordPress 5.8">`
- `/wp-content/themes/` references
- Joomla-specific script includes
- Drupal behaviors and settings

**Step 3: URL Pattern Probing**
Test well-known CMS-specific URLs:

```bash
# WordPress
curl -I https://target.com/wp-login.php
curl -I https://target.com/xmlrpc.php
curl -I https://target.com/readme.html

# Joomla
curl -I https://target.com/administrator/
curl -I https://target.com/configuration.php

# Drupal
curl -I https://target.com/CHANGELOG.txt
curl -I https://target.com/core/
```

### Phase 2: Deep Fingerprinting

**Step 4: JavaScript and CSS Analysis**
Identify client-side frameworks and libraries:

```bash
curl -s https://target.com | grep -o 'src="[^"]*\.js[^"]*"'
curl -s https://target.com | grep -o 'href="[^"]*\.css[^"]*"'
```

Map library versions to CMS versions when possible.

**Step 5: Error Page Analysis**
Trigger error pages to reveal CMS information:

```bash
curl -s https://target.com/nonexistent-page-12345
curl -s https://target.com/?id=1'
```

Error messages often reveal:
- PHP/MySQL version information
- CMS-specific error formatting
- Debug information in development environments

**Step 6: Sitemap and Robots.txt Analysis**
Examine crawling instructions for CMS clues:

```bash
curl -s https://target.com/robots.txt
curl -s https://target.com/sitemap.xml
```

CMS-specific patterns:
- WordPress: /wp-admin/, /wp-content/
- Joomla: /administrator/, /components/
- Drupal: /user/login, /node/

### Phase 3: Plugin and Theme Enumeration

**Step 7: Directory Structure Analysis**
Probe plugin/theme directories:

```bash
# WordPress plugin enumeration
curl -s https://target.com/wp-content/plugins/ | grep -o 'href="[^"]*"'

# WordPress theme detection
curl -s https://target.com | grep -o 'wp-content/themes/[^/"]*'
```

**Step 8: Version Specific Detection**
Use version-specific features for precise identification:

```bash
# WordPress version via feed
curl -s https://target.com/feed/ | grep -i "generator"

# Drupal version via CHANGELOG
curl -s https://target.com/CHANGELOG.txt | head -5
```

### Phase 4: Validation and Confidence Scoring

**Step 9: Cross-Validation**
Verify findings across multiple detection methods:

- If WordPress detected via wp-login.php, confirm with wp-content references
- If Joomla detected via administrator/, confirm with specific template references
- Calculate confidence score based on multiple indicators

**Step 10: Document Findings**
Record all CMS indicators with confidence levels:

```
CMS: WordPress 5.8.1
Confidence: 95%
Indicators:
- wp-login.php accessible (high)
- wp-content directory structure (high)
- Generator meta tag present (medium)
- Specific theme detected: twentytwentyone (medium)
```

## Tool Arsenal with Exact Commands

### Primary Detection Tools

**1. WhatWeb (CMS Fingerprinting)**
```bash
# Basic scan
whatweb https://target.com

# Verbose output with plugins
whatweb -v https://target.com

# Aggressive scanning
whatweb -a 3 https://target.com

# Scan multiple targets
whatweb -i targets.txt
```

**2. Wappalyzer (Technology Detection)**
```bash
# CLI version
wappalyzer https://target.com

# With proxy support
wappalyzer --proxy socks5://127.0.0.1:9050 https://target.com
```

**3. CMS Detection Tools**
```bash
# WPScan (WordPress specific)
wpscan --url https://target.com --enumerate vp,vt,u

# Joomscan (Joomla specific)
joomscan -u https://target.com

# Droopescan (Drupal, SilverStripe, Joomla)
droopescan scan drupal -u https://target.com
droopescan scan silverstripe -u https://target.com
```

**4. Custom Fingerprints**
```bash
# Custom WordPress detection
curl -s https://target.com | grep -c "wp-content\|wp-includes\|wp-login"

# Custom Joomla detection
curl -s https://target.com | grep -c "joomla\|/media/jui/"

# Custom Drupal detection
curl -s https://target.com | grep -c "drupal\|sites/default/files"
```

### Supplementary Tools

**5. Curl for Manual Testing**
```bash
# Header analysis
curl -D- https://target.com

# Cookie analysis
curl -c- -b- https://target.com

# Follow redirects
curl -L https://target.com/wp-login.php
```

**6. Nmap Scripts**
```bash
# http-wordpress-enum
nmap --script http-wordpress-enum -p 80,443 target.com

# http-joomla-brute
nmap --script http-joomla-brute -p 80,443 target.com
```

## Real-World Case Studies

### Case Study 1: Multi-CMS Environment Detection

**Scenario:** A large enterprise website appeared to be custom-built but was actually running multiple CMS platforms.

**Detection Process:**
1. Initial HTTP headers revealed PHP but no CMS-specific indicators
2. Main site showed no CMS markers in HTML source
3. Subdomain analysis revealed:
   - blog.target.com → WordPress (wp-login.php accessible)
   - docs.target.com → Drupal (CHANGELOG.txt found)
   - shop.target.com → Magento (specific CSS patterns)

**Findings:**
- Three different CMS platforms in use
- Different security patch levels across platforms
- WordPress plugins with known vulnerabilities on blog subdomain

**Impact:** The organization had to coordinate security updates across three different CMS platforms, each with its own update cycle and vulnerability landscape.

### Case Study 2: Obfuscated CMS Detection

**Scenario:** A website had removed all standard CMS indicators but left subtle traces.

**Detection Process:**
1. Standard URL patterns returned 404 errors
2. HTML source had no generator tags or obvious markers
3. JavaScript analysis revealed WordPress-specific function names:
   - `wp.ajax.post()` calls
   - `wp.api.schema` references
4. CSS contained WordPress-specific class patterns
5. HTTP headers showed WordPress cookies despite renaming

**Findings:**
- WordPress with security hardening plugin
- Custom theme removing standard indicators
- Still vulnerable to WordPress-specific attacks

**Lesson:** CMS detection requires looking beyond obvious indicators to subtle code patterns.

### Case Study 3: Version-Specific Vulnerability Mapping

**Scenario:** Accurate CMS version detection enabled targeted vulnerability assessment.

**Detection Process:**
1. Drupal site with version 7.57 detected via CHANGELOG.txt
2. Research revealed multiple CVEs for Drupal 7.x
3. Specific module versions identified through directory scanning
4. Combined version information to create targeted test plan

**Findings:**
- Drupalgeddon2 (CVE-2018-7600) vulnerability present
- Contributed modules with additional vulnerabilities
- Clear path to exploitation with documented techniques

**Impact:** Demonstrated how version-specific detection enables efficient vulnerability research.

### Case Study 4: Cloud CMS Challenges

**Scenario:** Modern SaaS CMS platforms require different detection approaches.

**Detection Process:**
1. Shopify site with no server-side access indicators
2. JavaScript-heavy rendering with React components
3. API-driven architecture with GraphQL endpoints
4. CDN-based asset delivery masking origin technology

**Findings:**
- Shopify platform with custom theme
- Limited attack surface due to SaaS model
- Focus shifted to application-level vulnerabilities
- API endpoints became primary testing targets

**Lesson:** Cloud CMS platforms require shifting from infrastructure to application testing.

## Advanced Techniques and Bypass

### CMS Obfuscation Detection

Many organizations attempt to hide their CMS through:

**1. Custom Error Pages:**
- Replace default error pages with generic messages
- Remove CMS-specific error formatting
- Bypass: Trigger specific error types that bypass custom pages

**2. Header Manipulation:**
- Remove X-Powered-By headers
- Modify Server header
- Bypass: Analyze other header patterns and timing responses

**3. URL Rewriting:**
- Remove .php extensions
- Implement custom URL structures
- Bypass: Probe for original file patterns

**4. File Structure Obfuscation:**
- Rename wp-content directory
- Move plugin directories
- Bypass: JavaScript/CSS path analysis reveals original structure

### Advanced Fingerprinting Techniques

**1. Timing-Based Detection:**
```bash
# Measure response times for different URL patterns
time curl -s https://target.com/wp-login.php > /dev/null
time curl -s https://target.com/administrator/ > /dev/null
```

Different CMS platforms have different response time patterns for existing vs. non-existing resources.

**2. Error Message Analysis:**
```bash
# Trigger database errors
curl -s "https://target.com/?id=1'"

# Trigger file inclusion errors
curl -s "https://target.com/?page=../../../../etc/passwd"
```

**3. JavaScript Behavioral Analysis:**
```bash
# Analyze JavaScript for CMS-specific functions
curl -s https://target.com | grep -o "function [a-zA-Z]*wp[a-zA-Z]*"
curl -s https://target.com | grep -o "Drupal\.[a-zA-Z]*"
```

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

### Common CMS Signatures

**WordPress Indicators:**
- URL patterns: /wp-login.php, /wp-admin/, /wp-content/
- Cookies: wordpress_logged_in_[hash], wp-settings-[hash]
- Meta tags: <meta name="generator" content="WordPress X.X">
- HTML patterns: wp-content, wp-includes, wp-emoji

**Joomla Indicators:**
- URL patterns: /administrator/, /components/, /modules/
- Cookies: joomla_[hash], 4c18097c64862dce8e302c0a8c03b9c3
- Meta tags: <meta name="generator" content="Joomla! X.X">
- HTML patterns: /media/jui/, /media/system/

**Drupal Indicators:**
- URL patterns: /user/login, /node/, /admin/content
- Cookies: SESS[hash], Drupal.[hash]
- Meta tags: <meta name="generator" content="Drupal X.X">
- HTML patterns: drupal.js, drupal.css, sites/default/

**Shopify Indicators:**
- URL patterns: /admin, /cart, /checkout
- Cookies: _shopify_[hash]
- HTML patterns: shopify, myshopify.com
- JavaScript: Shopify.[method] calls

### Confidence Scoring Matrix

| Indicator Type | Weight | Examples |
|----------------|--------|----------|
| Explicit Generator Tag | High | <meta name="generator" content="WordPress"> |
| URL Pattern Match | High | /wp-login.php returning 200 |
| Cookie Pattern | Medium | wordpress_logged_in_[hash] |
| HTML Source Pattern | Medium | wp-content references |
| JavaScript Pattern | Medium | wp.ajax.post() |
| CSS Pattern | Low | wp-content/themes/ |
| Error Message | Low | WordPress-specific errors |

## Impact Assessment

### Security Implications by CMS Type

**WordPress (60%+ market share):**
- Massive plugin ecosystem with frequent vulnerabilities
- Theme vulnerabilities often overlooked
- XML-RPC enabled by default (brute force vector)
- Regular security patches required

**Joomla:**
- Complex permission system often misconfigured
- Template override vulnerabilities
- Extension marketplace security concerns
- SQL injection vulnerabilities in older versions

**Drupal:**
- Strong core security, but module vulnerabilities
- Complex update process
- Drupalgeddon-class vulnerabilities
- Cache poisoning potential

**Shopify/SaaS Platforms:**
- Limited infrastructure testing
- Focus on application-level vulnerabilities
- API security concerns
- Third-party app integration risks

### Risk Assessment Framework

1. **CMS Popularity Risk:** More popular CMS = more automated attacks
2. **Plugin Ecosystem Risk:** More plugins = larger attack surface
3. **Update Frequency Risk:** Outdated CMS = known vulnerabilities
4. **Customization Risk:** Heavy customization = potential misconfigurations
5. **Hosting Environment Risk:** Shared hosting = cross-site contamination

## Common Pitfalls

### Detection Errors

1. **False Positives from CDNs:**
   - CDN-specific headers may mimic CMS signatures
   - Solution: Analyze multiple indicators, not single signatures

2. **Version Mismatches:**
   - Custom installations may have mixed version indicators
   - Solution: Cross-validate version indicators across multiple sources

3. **Obfuscation Blindness:**
   - Security plugins may hide CMS indicators
   - Solution: Use multiple detection methods, including timing analysis

4. **SaaS Platform Limitations:**
   - Cloud CMS have limited testing surface
   - Solution: Shift focus to application-level testing

5. **Multi-CMS Environments:**
   - Large organizations may use multiple CMS platforms
   - Solution: Test each subdomain independently

### Methodology Pitfalls

1. **Relying on Single Indicators:**
   - One CMS indicator is insufficient for confident identification
   - Solution: Require multiple independent indicators

2. **Ignoring Subdomains:**
   - Different subdomains may run different CMS platforms
   - Solution: Enumerate and test all accessible subdomains

3. **Overlooking Customization:**
   - Heavily customized CMS may not match standard fingerprints
   - Solution: Look for underlying patterns beneath customization

4. **Neglecting Version Detection:**
   - CMS version is critical for vulnerability research
   - Solution: Always attempt version detection after CMS identification

## Integration with Other Recon Areas

### CMS Detection in Recon Workflow

**1. Technology Stack Analysis:**
- CMS detection informs server-side technology choices
- Plugin/theme detection reveals JavaScript libraries
- Configuration analysis reveals database technology

**2. Vulnerability Research:**
- CMS version enables targeted CVE research
- Plugin versions enable module-specific vulnerability hunting
- Theme detection reveals potential theme vulnerabilities

**3. Attack Surface Mapping:**
- CMS architecture defines testing boundaries
- Plugin ecosystem reveals additional endpoints
- Configuration patterns indicate security controls

**4. Compliance Assessment:**
- CMS versions indicate patch management status
- Plugin inventory reveals third-party risk
- Configuration analysis reveals security control implementation

### Cross-Reference with Other Recon Skills

- **Framework Identification:** CMS often uses specific frameworks
- **Server Configuration:** CMS may influence server configuration
- **SSL/TLS Analysis:** CMS may affect certificate requirements
- **HTTP Header Intelligence:** CMS generates specific header patterns

## Reporting Template

### CMS Detection Report

**Executive Summary:**
- CMS Platform: [WordPress/Joomla/Drupal/etc.]
- Version: [Specific version if detected]
- Confidence Level: [High/Medium/Low]
- Key Findings: [Brief summary]

**Technical Findings:**

1. **Detection Indicators:**
   - URL patterns identified: [List]
   - HTML source indicators: [List]
   - HTTP header patterns: [List]
   - JavaScript/CSS patterns: [List]

2. **Version Analysis:**
   - Detection method: [How version was identified]
   - Version confidence: [High/Medium/Low]
   - Update status: [Current/Outdated]

3. **Plugin/Theme Inventory:**
   - Plugins detected: [List with versions]
   - Themes detected: [List with versions]
   - Custom modifications: [Observed customizations]

4. **Security Implications:**
   - Known vulnerabilities: [CVEs if version-specific]
   - Attack surface: [Relevant attack vectors]
   - Configuration concerns: [Identified issues]

**Recommendations:**
1. [CMS-specific security recommendations]
2. [Update/patching recommendations]
3. [Configuration hardening suggestions]
4. [Monitoring recommendations]

**Evidence:**
- Screenshots of detection indicators
- HTTP request/response samples
- Directory listings (if accessible)
- Version detection proof

## Practice Labs

### Lab 1: Basic CMS Detection

**Objective:** Identify CMS platforms using passive and active fingerprinting.

**Setup:**
```bash
# Create test environment
mkdir cms-labs && cd cms-labs

# Download vulnerable versions
wget https://wordpress.org/wordpress-5.7.2.tar.gz
wget https://downloads.joomla.org/cms/joomla5-5-0/Joomla_5.0.0.tar.gz
wget https://ftp.drupal.org/files/projects/drupal-9.3.7.tar.gz
```

**Exercises:**
1. Extract and configure each CMS
2. Apply different levels of security hardening
3. Practice detection with WhatWeb, manual techniques
4. Document detection indicators for each CMS

### Lab 2: Obfuscated CMS Detection

**Objective:** Detect CMS platforms with hidden indicators.

**Setup:**
- WordPress with security plugin removing standard indicators
- Custom theme with modified file structure
- Disabled default error pages

**Exercises:**
1. Attempt detection using standard techniques
2. Identify subtle indicators (JavaScript patterns, CSS classes)
3. Practice timing-based detection
4. Document bypass techniques

### Lab 3: Multi-CMS Environment

**Objective:** Map CMS platforms across a complex web application.

**Setup:**
- Main site: Custom PHP application
- Blog subdomain: WordPress
- Documentation subdomain: Drupal
- E-commerce subdomain: Magento

**Exercises:**
1. Enumerate all subdomains
2. Test each subdomain independently
3. Create comprehensive CMS inventory
4. Identify security implications of mixed CMS environment

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
5. **Continuous Learning:** Stay updated with CMS security developments

## Quick Reference Cheat Sheet

### WordPress Detection Commands
```bash
# Quick detection
curl -I https://target.com/wp-login.php
curl -s https://target.com | grep "wp-content"
curl -s https://target.com/feed/ | grep "generator"

# Plugin enumeration
wpscan --url https://target.com --enumerate vp

# Version detection
wpscan --url https://target.com --enumerate u
```

### Joomla Detection Commands
```bash
# Quick detection
curl -I https://target.com/administrator/
curl -s https://target.com | grep "joomla"

# Version detection
joomscan -u https://target.com
```

### Drupal Detection Commands
```bash
# Quick detection
curl -I https://target.com/CHANGELOG.txt
curl -s https://target.com | grep "drupal"

# Version detection
droopescan scan drupal -u https://target.com
```

### General Detection Tools
```bash
# WhatWeb scan
whatweb https://target.com

# Wappalyzer detection
wappalyzer https://target.com

# Custom fingerprinting
curl -s https://target.com | grep -i "generator\|wp-content\|joomla\|drupal"
```

### Confidence Assessment
- **High (90%+):** Multiple independent indicators, version-specific files accessible
- **Medium (70-89%):** Several indicators, but some inconsistencies
- **Low (50-69%):** Limited indicators, possible obfuscation
- **Uncertain (<50%):** Insufficient evidence for confident identification
