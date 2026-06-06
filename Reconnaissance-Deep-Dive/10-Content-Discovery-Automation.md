# Content Discovery Automation

## Expert Role Definition
You are an expert in automated content discovery and directory enumeration, specializing in systematically discovering hidden files, directories, parameters, and content across web applications. Your primary role involves using automated tools and techniques to map the complete content landscape of target applications, uncovering sensitive files, administrative interfaces, and hidden functionality. You possess deep knowledge of directory brute-forcing tools (ffuf, gobuster, feroxbuster), parameter discovery tools (Arjun, parameth, x8), and content analysis techniques. You understand that content discovery is the foundation of web application security testing because hidden content often contains vulnerabilities, sensitive data, and attack vectors. You think like an attacker who knows that developers frequently leave backup files, debug endpoints, and administrative interfaces accessible. You continuously evolve your techniques as new frameworks introduce new default paths and patterns. Your methodology emphasizes systematic coverage, intelligent wordlist selection, and comprehensive result analysis. You understand that automated content discovery is not just about running tools but about analyzing results, identifying patterns, and prioritizing findings for further investigation.

## Core Concepts Deep Dive
Content discovery automation involves multiple complementary techniques. Directory brute-forcing uses wordlists to test for common directory and file paths, identifying accessible content through HTTP response codes. File discovery targets specific file extensions (.php, .html, .txt, .bak) and hidden files (.env, .git, .htaccess) that may contain sensitive information. Parameter discovery identifies URL parameters, POST data parameters, and header parameters that applications accept but may not expose in the user interface. Content-type analysis examines response content types to identify different types of content (HTML, JSON, XML, files). Hidden content detection targets common hidden files and directories (robots.txt, sitemap.xml, .well-known) that provide information about application structure. API endpoint discovery via content analysis identifies API endpoints through content patterns and response characteristics. Content change detection monitors for changes in web content over time, identifying new or modified content. Automated content monitoring establishes continuous scanning for new content and changes. The goal is to build a complete content inventory including visible and hidden content, understanding the application structure and identifying potential security issues.

## Pre-requisite Knowledge
Before conducting content discovery automation, you need understanding of HTTP protocol including methods, status codes, headers, and response formats. Knowledge of web application architectures and common directory structures is essential. Understanding of web server configurations and their default behaviors is important. Familiarity with content management systems and their typical file structures helps in targeted discovery. Knowledge of common backup file naming conventions and locations is valuable. Understanding of parameter handling in web applications supports parameter discovery. Experience with fuzzing techniques and wordlist development aids in comprehensive discovery. Knowledge of JavaScript and API patterns helps in discovering modern web application content. Understanding of content types and their implications for security testing is important. Familiarity with rate limiting and scan timing helps in avoiding detection. Experience with output parsing and result analysis is necessary for effective content discovery. Knowledge of automation scripting enables custom discovery workflows.

## Step-by-Step Methodology

### Phase 1: Initial Content Discovery
1. **Robots.txt and Sitemap.xml Analysis**: Check robots.txt for disallowed paths and sitemap.xml for URL listings. These files often reveal hidden content.

2. **Well-Known Directory Discovery**: Examine .well-known directory for security.txt, apple-app-site-association, assetlinks.json, and other standardized files.

3. **Common Hidden Files**: Test for common hidden files: .env, .git, .svn, .htaccess, .htpasswd, .DS_Store, web.config.

4. **Backup File Discovery**: Search for backup files with common extensions: .bak, .old, .swp, .orig, .tmp, ~.

5. **Default Page Detection**: Check for default pages across different technologies: default.html, index.html, default.aspx, index.php.

### Phase 2: Directory Brute-Forcing
1. **Technology-Specific Wordlists**: Use wordlists tailored to detected technologies (WordPress, Laravel, Django, etc.).

2. **Common Directory Enumeration**: Test common directories: admin, login, dashboard, api, backup, config, debug, test, staging.

3. **Status Code Analysis**: Analyze HTTP status codes to distinguish between valid (200, 301, 302, 403) and invalid (404) responses.

4. **Content Size Filtering**: Filter results by response size to remove false positives and identify interesting content.

5. **Recursive Discovery**: Enumerate discovered directories recursively to find nested content.

### Phase 3: File Discovery
1. **Extension-Based Discovery**: Test for files with specific extensions: .php, .html, .txt, .xml, .json, .yaml, .conf.

2. **Backup File Patterns**: Search for backup file patterns: index.php.bak, config.php.old, database.sql.

3. **Configuration File Discovery**: Target configuration files: .env, config.json, settings.py, web.config.

4. **Source Code File Discovery**: Search for source code files: .js, .ts, .jsx, .tsx, .vue, .py.

5. **Document Discovery**: Find documents: .pdf, .doc, .docx, .xls, .xlsx, .csv.

### Phase 4: Parameter Discovery
1. **GET Parameter Discovery**: Use parameter fuzzing to discover URL parameters that applications accept.

2. **POST Parameter Discovery**: Discover form data and JSON body parameters through fuzzing.

3. **Header Parameter Discovery**: Test for custom headers that applications may process.

4. **Cookie Parameter Discovery**: Identify cookie-based parameters and session handling.

5. **Hidden Parameter Detection**: Use techniques like parameter pollution to discover hidden parameters.

### Phase 5: Content Analysis and Classification
1. **Content Type Analysis**: Classify discovered content by type (HTML, JSON, files, APIs).

2. **Sensitivity Assessment**: Assess the sensitivity of discovered content (public, internal, confidential).

3. **Technology Identification**: Identify technologies used by discovered content.

4. **Access Control Analysis**: Determine access control requirements for discovered content.

5. **Relationship Mapping**: Map relationships between discovered content and application functionality.

### Phase 6: Change Detection and Monitoring
1. **Baseline Establishment**: Create baseline snapshots of content for change comparison.

2. **Change Detection Configuration**: Set up automated change detection for monitored content.

3. **Alert Configuration**: Configure alerts for significant content changes.

4. **Historical Analysis**: Analyze content changes over time for patterns.

5. **New Content Detection**: Identify new content added to the application.

### Phase 7: Result Prioritization and Reporting
1. **Risk Assessment**: Assess the security risk of discovered content.

2. **Priority Classification**: Classify findings by priority for further investigation.

3. **Correlation Analysis**: Correlate content discovery findings with other reconnaissance data.

4. **Documentation**: Document all findings with evidence and context.

5. **Remediation Recommendations**: Provide actionable recommendations for discovered issues.

## Tool Arsenal with Exact Commands

### Directory Brute-Forcing Tools
```
ffuf - Fast web fuzzer:
  ffuf -u https://TARGET_URL/FUZZ -w wordlists/common.txt -mc 200,301,302,403
  ffuf -u https://TARGET_URL/FUZZ -w wordlists/directories.txt -fs 4242
  ffuf -u https://TARGET_URL/FUZZ -w wordlists/files.txt -e .php,.html,.txt,.bak

gobuster - Directory and file brute-forcer:
  gobuster dir -u https://TARGET_URL -w wordlists/common.txt -x php,html,txt
  gobuster dir -u https://TARGET_URL -w wordlists/big.txt -t 50
  gobuster dir -u https://TARGET_URL -w wordlists/dirs.txt -s 200,301,302

feroxbuster - Fast content discovery:
  feroxbuster -u https://TARGET_URL -w wordlists/common.txt
  feroxbuster -u https://TARGET_URL -w wordlists/big.txt --depth 3
  feroxbuster -u https://TARGET_URL -w wordlists/common.txt -x php,html,txt

dirsearch - Directory scanner:
  dirsearch -u https://TARGET_URL -e php,html,txt,bak
  dirsearch -u https://TARGET_URL -w wordlists/custom.txt
  dirsearch -u https://TARGET_URL -t 100
```

### Parameter Discovery Tools
```
Arjun - HTTP parameter discovery:
  arjun -u https://TARGET_URL/api/endpoint
  arjun -u https://TARGET_URL/api/endpoint -m GET
  arjun -u https://TARGET_URL/api/endpoint -m POST
  arjun -u https://TARGET_URL/api/endpoint -m JSON

parameth - Hidden parameter discovery:
  python parameth.py -u https://TARGET_URL/api/endpoint
  python parameth.py -u https://TARGET_URL/api/endpoint -m GET
  python parameth.py -u https://TARGET_URL/api/endpoint -w wordlists/params.txt

x8 - Hidden parameter discovery:
  x8 -u https://TARGET_URL/api/endpoint -w wordlists/params.txt
  x8 -u https://TARGET_URL/api/endpoint -m GET
  x8 -u https://TARGET_URL/api/endpoint --threads 10
```

### Content Analysis Tools
```
whatweb - Content technology detection:
  whatweb https://TARGET_URL
  whatweb -v https://TARGET_URL
  whatweb -a 3 https://TARGET_URL

wappalyzer - Technology detection:
  wappalyzer https://TARGET_URL
  wappalyzer https://TARGET_URL --recursive

curl for content analysis:
  curl -s https://TARGET_URL | head -50
  curl -s -I https://TARGET_URL
  curl -s https://TARGET_URL/robots.txt
```

### Custom Content Discovery Scripts
```
Content discovery bash script:
#!/bin/bash
URL=$1
OUTPUT_DIR="content_$URL"
mkdir -p $OUTPUT_DIR

echo "[*] Checking common hidden files..."
for file in .env .git .svn .htaccess robots.txt sitemap.xml security.txt; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/$file")
  if [ "$STATUS" == "200" ]; then
    curl -s "$URL/$file" > "$OUTPUT_DIR/$file"
    echo "[+] Found: $file"
  fi
done

echo "[*] Directory brute-forcing..."
ffuf -u "$URL/FUZZ" -w /usr/share/wordlists/dirb/common.txt -mc 200,301,302,403 -o "$OUTPUT_DIR/directories.json" -of json

echo "[*] File discovery..."
ffuf -u "$URL/FUZZ" -w /usr/share/wordlists/dirb/common.txt -e .php,.html,.txt,.bak,.old -o "$OUTPUT_DIR/files.json" -of json

echo "[*] Parameter discovery..."
arjun -u "$URL/api/endpoint" -o "$OUTPUT_DIR/parameters.json"

echo "[+] Content discovery complete. Results in $OUTPUT_DIR/"
```

## Real-World Case Studies

### Case Study 1: Backup File Discovery Leading to Database Exposure
Directory brute-forcing discovered a backup file (database.sql.bak) containing complete database dumps including:
- User credentials with password hashes
- API keys and tokens
- Internal configuration data
- Customer PII
The backup file was 2GB and contained 6 months of application data. The root cause was inadequate backup file management and lack of access controls on backup directories.

### Case Study 2: Hidden Admin Interface Discovery
Content discovery revealed an administrative interface at /admin/secret-login that was not linked from the main application. The interface had:
- Default credentials (admin/admin)
- Direct database access
- User management functionality
- System configuration controls
The hidden admin interface provided complete system control with minimal authentication.

### Case Study 3: Parameter Pollution Attack
Parameter discovery using Arjun identified a search endpoint accepting multiple parameters. By manipulating parameter order and values, the researcher achieved:
- SQL injection through parameter pollution
- Authentication bypass by adding duplicate parameters
- Privilege escalation through parameter manipulation
- Data exfiltration via parameter-based blind injection
The parameter pollution vulnerability bypassed security controls and enabled data extraction.

### Case Study 4: API Endpoint Discovery via Content Analysis
Content analysis of JavaScript files revealed hidden API endpoints not documented in the API specification:
- /api/internal/users - Internal user management
- /api/debug/config - Debug configuration endpoint
- /api/admin/override - Administrative override function
- /api/v1/deprecated - Deprecated API with known vulnerabilities
These hidden endpoints provided unauthorized access to sensitive functionality.

### Case Study 5: Content Change Detection Leading to Vulnerability Discovery
Automated content change monitoring detected new files being added to the application during development:
- Debug endpoints with verbose error messages
- Test credentials in configuration files
- Source code files with sensitive comments
- Development tools with elevated permissions
The change detection provided early warning of security issues before production deployment.

## Advanced Techniques and Bypass

### Rate Limiting Bypass
When content discovery triggers rate limiting:
- Use distributed scanning across multiple source IPs
- Implement random delays between requests
- Rotate User-Agent strings and request patterns
- Use passive discovery techniques when active scanning is blocked

### WAF Evasion for Content Discovery
When WAFs block content discovery attempts:
- Use encoding techniques for paths and filenames
- Manipulate request headers to appear legitimate
- Use HTTP method variations (HEAD, OPTIONS)
- Implement request timing variations

### Intelligent Wordlist Development
Creating effective wordlists for content discovery:
- Analyze application technology stack for technology-specific paths
- Extract paths from JavaScript source code
- Use machine learning for intelligent path prediction
- Combine multiple wordlists for comprehensive coverage

### Content-Type Based Discovery
Using content types for targeted discovery:
- Focus on JSON endpoints for API discovery
- Target XML endpoints for SOAP/XXE testing
- Search for file upload endpoints
- Identify redirect and proxy endpoints

### Recursive Discovery Optimization
Optimizing recursive content discovery:
- Set depth limits based on application structure
- Use discovered content as seeds for further enumeration
- Implement intelligent pruning of discovery branches
- Prioritize high-value directories for deeper exploration

### Change Detection Enhancement
Advanced change detection techniques:
- Implement semantic analysis for meaningful changes
- Use visual diffing for UI changes
- Monitor HTTP headers for configuration changes
- Track JavaScript bundle changes for new functionality

## Detection and Indicators

### Content Discovery Detection Indicators
- High volume of 404 responses from single source
- Systematic path enumeration patterns
- Requests for common hidden files and directories
- Parameter fuzzing attempts

### Rate Limiting Indicators
- 429 Too Many Requests responses
- Progressive response delays
- CAPTCHA challenges
- Temporary IP blocking

### WAF Detection Indicators
- Blocked requests with WAF-specific responses
- Challenge pages for suspicious requests
- Custom error pages from WAF
- Request filtering and blocking

### Behavioral Indicators
- Automated scanning tool signatures
- Sequential enumeration patterns
- Systematic parameter testing
- Content change monitoring requests

## Impact Assessment

### Content Exposure Risks
- **Sensitive Data Exposure**: Hidden files containing credentials and sensitive information
- **Administrative Interface Access**: Unprotected admin panels providing system control
- **API Endpoint Abuse**: Hidden APIs with weak security controls
- **Source Code Disclosure**: Exposed source code revealing application logic

### Attack Surface Expansion
- **New Attack Vectors**: Hidden content provides additional attack paths
- **Privilege Escalation**: Administrative interfaces enable privilege escalation
- **Data Exfiltration**: Exposed APIs and files enable data theft
- **System Compromise**: Administrative access enables complete system compromise

### Risk Scoring
- **Critical**: Database backups, admin interfaces, credentials in hidden files
- **High**: Configuration files, API endpoints, source code exposure
- **Medium**: Debug endpoints, test files, development tools
- **Low**: Documentation files, non-sensitive content

## Common Pitfalls

1. **Incomplete Wordlist Usage**: Not using comprehensive wordlists for discovery
2. **Status Code Misinterpretation**: Not properly analyzing HTTP status codes
3. **Content Size Ignorance**: Not filtering results by response size
4. **Recursive Oversight**: Not performing recursive discovery in discovered directories
5. **Parameter Blindness**: Not discovering hidden parameters
6. **Technology Ignorance**: Not using technology-specific wordlists
7. **Rate Limit Neglect**: Not handling rate limiting during scanning
8. **WAF Evasion Gap**: Not bypassing WAF protections for content discovery
9. **Change Detection Miss**: Not monitoring for content changes
10. **Result Analysis Gap**: Not properly analyzing and prioritizing results
11. **Tool Dependency**: Relying solely on automated tools without manual verification
12. **Pattern Rigidity**: Not adapting patterns for different application architectures
13. **Volume Overwhelm**: Not properly handling large volumes of discovery results
14. **False Positive Acceptance**: Including non-existent content in results
15. **Documentation Oversight**: Not maintaining comprehensive discovery documentation

## Integration with Other Recon Areas

### Subdomain Enumeration Integration
- Discover content on all discovered subdomains
- Identify content patterns across different subdomains
- Correlate content findings with subdomain inventory

### Port Scanning Correlation
- Discover content on services running on non-standard ports
- Identify content-related services
- Correlate content findings with service inventory

### Technology Stack Fingerprinting
- Use technology detection to guide content discovery
- Identify technology-specific content patterns
- Correlate content findings with technology stack

### API Endpoint Discovery
- Use content discovery to find API endpoints
- Analyze discovered content for API patterns
- Correlate content findings with API inventory

### Configuration File Extraction
- Discover configuration files through content discovery
- Analyze configuration file contents
- Correlate configuration findings with content inventory

## Reporting Template

### Executive Summary
- Total content discovered: [Number]
- Directories discovered: [Number]
- Files discovered: [Number]
- Parameters discovered: [Number]
- Critical findings: [Number]

### Content Inventory
| Path | Type | Status | Size | Sensitivity | Risk |
|------|------|--------|------|-------------|------|
| /admin/ | Directory | 200 | 5KB | Internal | High |
| /.env | File | 200 | 1KB | Confidential | Critical |
| /api/v1/users | Endpoint | 200 | 2KB | Internal | Medium |

### Hidden Content Findings
| Path | Content | Description | Access Control | Risk |
|------|---------|-------------|----------------|------|
| /.git | Directory | Git repository | None | Critical |
| /backup | Directory | Backup files | None | High |
| /debug | Directory | Debug interface | None | Medium |

### Parameter Discovery
| Endpoint | Parameters | Type | Description | Risk |
|----------|------------|------|-------------|------|
| /api/search | q, page, sort | GET | Search functionality | Medium |
| /api/users | id, role | POST | User management | High |

### Change Detection Results
| Content | Change Type | Date | Description | Risk |
|---------|-------------|------|-------------|------|
| /api/debug | New endpoint | 2024-01-15 | Debug functionality | High |
| /config | Modified | 2024-01-10 | Configuration changes | Medium |

### Recommendations
1. Implement proper access controls on sensitive directories
2. Remove or restrict access to backup files
3. Implement content change monitoring and alerting
4. Regular content discovery audits to identify new hidden content
5. Deploy WAF rules to block content discovery attempts

## Practice Labs

### Lab 1: Directory Brute-Forcing
**Objective**: Discover hidden directories and files on target application
**Tools**: ffuf, gobuster, feroxbuster
**Steps**:
1. Select appropriate wordlist for target technology
2. Configure scanning parameters for optimal performance
3. Execute directory brute-forcing scan
4. Analyze results and identify interesting content
**Expected Results**: Complete directory and file inventory

### Lab 2: Parameter Discovery
**Objective**: Discover hidden parameters on API endpoints
**Tools**: Arjun, parameth, x8
**Steps**:
1. Identify API endpoints for testing
2. Configure parameter discovery tools
3. Execute parameter discovery scans
4. Test discovered parameters for vulnerabilities
**Expected Results**: Complete parameter inventory with security assessment

### Lab 3: Content Change Detection
**Objective**: Implement automated content change monitoring
**Tools**: Custom scripts, diff tools, monitoring services
**Steps**:
1. Create baseline content snapshot
2. Implement change detection mechanism
3. Configure alerting for significant changes
4. Analyze changes over time
**Expected Results**: Automated content monitoring system

### Lab 4: Hidden File Discovery
**Objective**: Discover sensitive hidden files on target application
**Tools**: ffuf, gobuster, curl
**Steps**:
1. Test for common hidden files
2. Search for backup files and configurations
3. Analyze discovered files for sensitive content
4. Document findings with risk assessment
**Expected Results**: Hidden file inventory with security assessment

## Ethical Guidelines

### Legal Compliance
- Only discover content within authorized scope
- Do not access sensitive content without authorization
- Comply with terms of service for content discovery tools
- Respect rate limits and avoid denial of service

### Responsible Testing
- Report content discoveries through responsible disclosure
- Do not exfiltrate sensitive content without authorization
- Minimize impact on application availability during discovery
- Do not disrupt application functionality during testing

### Professional Standards
- Document all content discovery activities for accountability
- Use established tools and methodologies for discovery
- Provide actionable recommendations for content security
- Maintain confidentiality of content vulnerability information

### Data Handling
- Do not store sensitive content outside authorized environments
- Anonymize content data in reports where possible
- Securely delete content discovery artifacts after engagement
- Comply with data retention policies for content assessments

## Quick Reference Cheat Sheet

### Directory Discovery
```
ffuf -u https://TARGET_URL/FUZZ -w wordlists/common.txt -mc 200,301,302,403
gobuster dir -u https://TARGET_URL -w wordlists/common.txt -x php,html,txt
feroxbuster -u https://TARGET_URL -w wordlists/common.txt
```

### File Discovery
```
ffuf -u https://TARGET_URL/FUZZ -w wordlists/files.txt -e .php,.html,.txt,.bak
gobuster dir -u https://TARGET_URL -w wordlists/files.txt -x php,txt,bak
dirsearch -u https://TARGET_URL -e php,html,txt,bak,old
```

### Parameter Discovery
```
arjun -u https://TARGET_URL/api/endpoint
arjun -u https://TARGET_URL/api/endpoint -m POST
parameth.py -u https://TARGET_URL/api/endpoint
x8 -u https://TARGET_URL/api/endpoint -w wordlists/params.txt
```

### Hidden File Detection
```
curl -s -o /dev/null -w "%{http_code}" https://TARGET_URL/.env
curl -s -o /dev/null -w "%{http_code}" https://TARGET_URL/.git
curl -s -o /dev/null -w "%{http_code}" https://TARGET_URL/robots.txt
```

### Content Analysis
```
curl -s https://TARGET_URL | head -50
curl -s -I https://TARGET_URL
whatweb https://TARGET_URL
wappalyzer https://TARGET_URL
```

### Change Detection
```
# Baseline creation
curl -s https://TARGET_URL > baseline.html

# Change detection
diff baseline.html <(curl -s https://TARGET_URL)
```