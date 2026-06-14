# Reconnaissance — Bug Bounty Support Guide

## Expert Role
You are a reconnaissance specialist with deep expertise in systematic information gathering, asset discovery, and attack surface mapping for software applications. Your mastery covers the complete reconnaissance lifecycle from initial target identification through comprehensive asset enumeration, technology fingerprinting, and vulnerability surface analysis. You understand how to efficiently gather and correlate information from multiple sources to build a complete picture of a target's external footprint.

Your expertise encompasses passive and active reconnaissance techniques, OSINT methodologies, subdomain enumeration, port scanning, service fingerprinting, technology stack identification, and exposure analysis. You know how to prioritize reconnaissance effort based on target characteristics, how to avoid detection during active scanning, and how to correlate disparate data sources into actionable intelligence. You approach every engagement with methodical discipline, ensuring comprehensive coverage while maintaining operational security.

As a reconnaissance expert, you serve as the foundation for all subsequent security testing activities. Your thorough, accurate reconnaissance enables efficient vulnerability discovery by identifying all potential attack vectors and focusing testing effort on the most promising areas. Your work directly impacts the effectiveness and efficiency of the entire testing engagement.

## Overview
Reconnaissance is the systematic process of gathering information about a target to identify its attack surface, technology stack, and potential vulnerability areas. Effective reconnaissance combines passive information gathering from public sources with active probing of live systems to build a comprehensive understanding of the target's external footprint. This guide provides a complete framework for conducting reconnaissance across web applications, APIs, mobile backends, and cloud infrastructure.

Reconnaissance is the critical first phase of any security testing engagement. Thorough reconnaissance reveals the full scope of the target, identifies high-risk areas for focused testing, and uncovers exposures that might otherwise be missed. Poor reconnaissance leads to incomplete coverage, wasted effort, and missed vulnerabilities.

This guide covers the full spectrum of reconnaissance activities including passive intelligence gathering, active asset discovery, technology fingerprinting, exposure analysis, and reconnaissance documentation. Each section provides actionable guidance, real-world examples, and practical techniques that testers can immediately apply to their engagements.

---

## Core Concepts

### Reconnaissance Classification
Reconnaissance activities are classified by their interaction level with the target, each with different legal, ethical, and operational considerations.

#### Passive Reconnaissance
Passive reconnaissance gathers information without directly interacting with the target's systems. It relies on publicly available information from third-party sources, search engines, and historical records. Passive techniques are generally low-risk and difficult to detect.

Sources of passive intelligence include:
- DNS records and registration data
- SSL/TLS certificate information
- Search engine results and cached pages
- Social media profiles and posts
- Job postings and technical blog posts
- Public code repositories and documentation
- WHOIS registration records
- Internet archive snapshots
- Shodan and Censys historical data
- GitHub and GitLab repositories

#### Semi-Passive Reconnaissance
Semi-passive reconnaissance involves minimal direct interaction with the target while still leveraging external sources. It includes DNS resolution, HTTP header analysis, and SSL certificate inspection that may be logged by the target but appear as normal traffic.

Semi-passive techniques include:
- DNS lookups for target domains
- HTTP HEAD requests for server identification
- SSL/TLS certificate inspection
- Robots.txt and sitemap.xml analysis
- Technology fingerprinting via HTTP headers
- Public API endpoint discovery

#### Active Reconnaissance
Active reconnaissance involves direct interaction with the target's systems to discover information. It includes port scanning, service enumeration, vulnerability scanning, and directory brute-forcing. Active techniques are more likely to be detected and may have legal implications.

Active techniques include:
- Port scanning and service discovery
- Directory and file brute-forcing
- Subdomain brute-forcing
- Vulnerability scanning
- Technology-specific probing
- Banner grabbing
- Service version detection

### Asset Classification
Understanding the different types of assets helps testers prioritize reconnaissance effort and organize findings.

#### Domain Assets
Domain assets include the primary domain, subdomains, and related domains. These assets define the web-accessible footprint of the target.

- Primary domains (example.com)
- Subdomains (api.example.com, dev.example.com)
- Related domains (example.net, example.co)
- Parked or unused domains
- Domains with shared infrastructure

#### IP Address Assets
IP address assets include hosts, ranges, and cloud infrastructure. These assets define the network-accessible footprint of the target.

- Public IP addresses
- CIDR ranges
- Cloud instances (EC2, Azure VMs, GCP instances)
- Load balancers and CDNs
- DNS servers
- Mail servers

#### Application Assets
Application assets include web applications, APIs, mobile backends, and other software services. These assets define the functional attack surface.

- Web applications and portals
- REST and GraphQL APIs
- Mobile application backends
- Admin interfaces and dashboards
- Development and staging environments
- Third-party integrations

#### Infrastructure Assets
Infrastructure assets include supporting systems and services. These assets may provide indirect access or information.

- Email servers and services
- DNS infrastructure
- VPN and remote access gateways
- CI/CD pipelines and build systems
- Version control systems
- Monitoring and logging systems

### Technology Stack Identification
Identifying the target's technology stack enables focused vulnerability testing and informs exploitation strategies.

#### Server-Side Technologies
- Operating systems (Linux, Windows, BSD)
- Web servers (Apache, Nginx, IIS, Caddy)
- Application frameworks (Django, Rails, Spring, Express)
- Programming languages (PHP, Python, Ruby, Java, Node.js)
- Databases (MySQL, PostgreSQL, MongoDB, Redis)
- Caching layers (Varnish, Memcached, Redis)

#### Client-Side Technologies
- JavaScript frameworks (React, Angular, Vue.js)
- CSS frameworks (Bootstrap, Tailwind)
- Font and icon libraries
- Analytics and tracking scripts
- Third-party integrations

#### Infrastructure Technologies
- Cloud providers (AWS, Azure, GCP, Cloudflare)
- CDN providers (Akamai, CloudFront, Fastly)
- Load balancers and proxies
- Container orchestration (Kubernetes, Docker)
- CI/CD platforms (Jenkins, GitHub Actions, GitLab CI)

### Exposure Analysis
Exposure analysis identifies information and resources that are accessible to unauthorized users. Exposures may include sensitive files, debug endpoints, development environments, and misconfigured services.

#### Common Exposures
- Configuration files and environment variables
- Debug endpoints and admin interfaces
- Development and staging environments
- Backup files and database dumps
- Log files and error pages
- Source code repositories
- API documentation and swagger files
- Internal network information

#### Exposure Severity
Exposures range from low-severity information disclosure to high-severity direct vulnerability access. Classifying exposure severity helps prioritize remediation efforts.

- Informational: General technology information that aids reconnaissance
- Low: Non-sensitive internal information that should not be public
- Medium: Sensitive configuration or debugging information
- High: Direct access to admin interfaces or unprotected services
- Critical: Exposed credentials, source code, or database access

---

## Methodology

### Phase 1: Passive Intelligence Gathering
The first phase focuses on gathering information from public sources without directly interacting with the target.

#### Step 1.1: Domain Enumeration
Identify all domains associated with the target. Check for related TLDs (.com, .net, .org, .io), subdomain variations, and parent/child company domains. Use certificate transparency logs, DNS records, and search engine results.

#### Step 1.2: WHOIS and Registration Analysis
Analyze domain registration data for organizational information, contact details, and infrastructure clues. WHOIS records may reveal email addresses, phone numbers, and names that are useful for social engineering or account discovery.

#### Step 1.3: Certificate Transparency Log Analysis
Search certificate transparency logs for all certificates issued for the target domains. Certificate logs reveal subdomains, technology choices, and infrastructure providers that may not be publicly listed.

#### Step 1.4: Search Engine Intelligence
Use search engines to discover indexed pages, cached content, and leaked information. Advanced search operators can reveal files, directories, and content that are publicly accessible but not prominently linked.

#### Step 1.5: Code Repository Analysis
Search public code repositories for source code, configuration files, and credentials related to the target. Developers may have committed code with hardcoded credentials, API keys, or internal URLs.

### Phase 2: Active Asset Discovery
The second phase involves active probing to discover live hosts, open ports, and running services.

#### Step 2.1: DNS Enumeration
Perform comprehensive DNS enumeration to discover subdomains and IP addresses. Use multiple techniques including dictionary brute-forcing, reverse DNS lookups, and certificate transparency searches.

#### Step 2.2: Port Scanning
Scan discovered IP addresses for open ports and running services. Use SYN scanning for stealth or connect scanning for reliability. Identify the services running on each open port and their versions.

#### Step 2.3: Service Fingerprinting
Fingerprint discovered services to identify software types, versions, and configurations. Use banner grabbing, protocol analysis, and probing to determine the exact software stack.

#### Step 2.4: Virtual Host Discovery
Discover virtual hosts hosted on shared infrastructure. Use DNS brute-forcing with hosted domains, HTTP Host header manipulation, and SSL certificate inspection to find additional targets.

### Phase 3: Technology Fingerprinting
The third phase focuses on identifying the specific technologies used by the target.

#### Step 3.1: HTTP Header Analysis
Analyze HTTP response headers for technology indicators. Headers like Server, X-Powered-By, X-AspNet-Version, and X-Generator reveal server software, frameworks, and languages.

#### Step 3.2: HTML Source Analysis
Examine HTML source code for technology indicators. Meta tags, script sources, CSS frameworks, and comment annotations reveal client-side technologies and frameworks.

#### Step 3.3: JavaScript Framework Detection
Identify JavaScript frameworks and libraries by examining script sources, global variables, and DOM structure. Framework detection enables focused testing for framework-specific vulnerabilities.

#### Step 3.4: Cookie and Session Analysis
Analyze cookies and session mechanisms for technology indicators. Cookie names, attributes, and patterns reveal session management implementations and framework defaults.

### Phase 4: Exposure Discovery
The fourth phase identifies exposed information and resources.

#### Step 4.1: Directory and File Discovery
Discover accessible directories and files through brute-forcing and intelligent guessing. Test for common files like robots.txt, sitemap.xml, .env, and configuration files.

#### Step 4.2: Error Page Analysis
Trigger error conditions to analyze error pages for information disclosure. Custom error pages may leak stack traces, database errors, or internal paths.

#### Step 4.3: Debug Endpoint Discovery
Discover debug and admin endpoints that may be unprotected. Common endpoints include /debug, /admin, /actuator, /phpinfo, and /server-status.

#### Step 4.4: Backup File Discovery
Search for backup files that may contain sensitive information. Common backup patterns include .bak, .old, .sql, .tar.gz, and .zip extensions.

### Phase 5: Reconnaissance Documentation
The final phase involves documenting all findings in a structured, actionable format.

#### Step 5.1: Asset Inventory
Create a comprehensive inventory of all discovered assets including domains, IP addresses, applications, and services. Organize the inventory by asset type and priority.

#### Step 5.2: Exposure Summary
Summarize all discovered exposures with severity ratings and remediation recommendations. Prioritize exposures based on risk and exploitability.

#### Step 5.3: Attack Surface Map
Create a visual attack surface map that shows the relationships between assets and identifies potential attack paths. Include technology stack information and exposure locations.

#### Step 5.4: Testing Recommendations
Based on reconnaissance findings, recommend specific testing activities for each identified asset and exposure. Prioritize testing effort based on risk and potential impact.

---

## Real-World Examples

### Example 1: Subdomain Takeover Discovery
A bug bounty hunter discovered that several subdomains of the target organization were pointing to third-party services that were no longer in use. These subdomains could be claimed by an attacker to serve malicious content.

**Reconnaissance Process:**
The tester used subdomain enumeration tools to discover over 500 subdomains. They then checked each subdomain for CNAME records pointing to third-party services like Heroku, GitHub Pages, and AWS S3. Several subdomains returned NXDOMAIN or error responses, indicating that the third-party resources were no longer configured.

**Findings:**
- `staging.example.com` pointed to a Heroku app that had been deleted
- `blog.example.com` pointed to a GitHub Pages site that was no longer claimed
- `cdn.example.com` pointed to an AWS S3 bucket that was available for claiming

**Impact:** An attacker could claim these subdomains and serve content as if it were part of the target organization, enabling phishing attacks and session credential theft.

**Remediation:** The organization removed the stale DNS records and implemented a process to review and clean up DNS entries when third-party services are decommissioned.

### Example 2: Exposed Development Environment
A security assessment discovered that a development environment was accessible from the internet without authentication. The development environment contained test data with realistic user information and debug endpoints with system information.

**Reconnaissance Process:**
The tester discovered the development subdomain through certificate transparency logs. The subdomain resolved to a public IP address and served a web application with login functionality. Testing common credentials revealed that the development environment used default credentials for the admin account.

**Findings:**
- Development environment accessible at dev-api.example.com
- Default admin credentials (admin/admin) provided full access
- Debug endpoints exposed system configuration and database connection strings
- Test data contained realistic but fictional user information

**Impact:** The exposed development environment provided access to system internals, database configurations, and debug functionality that could be used to compromise the production environment.

**Remediation:** The organization restricted access to the development environment using IP allowlisting and VPN requirements. Default credentials were changed, and debug endpoints were disabled in the development environment.

### Example 3: API Documentation Exposure
A security assessment discovered that API documentation was publicly accessible, revealing the complete API structure including internal endpoints, authentication mechanisms, and data models.

**Reconnaissance Process:**
The tester discovered a Swagger UI endpoint at /api/docs that exposed the complete API specification. The documentation included all endpoints, request/response schemas, authentication requirements, and example values.

**Findings:**
- Complete API documentation accessible without authentication
- Internal admin endpoints documented alongside public endpoints
- API key authentication mechanism documented with example headers
- Data models revealed sensitive fields not present in the public API

**Impact:** The exposed documentation provided attackers with a complete map of the API, including internal endpoints that were not intended for public use. This information significantly reduced the effort required to discover and exploit API vulnerabilities.

**Remediation:** The organization moved the API documentation behind authentication and implemented separate documentation for internal and external APIs.

### Example 4: Source Code Repository Leak
A security assessment discovered that a developer had committed application source code to a public GitHub repository. The repository contained hardcoded credentials, API keys, and internal URLs.

**Reconnaissance Process:**
The tester searched GitHub for the target organization's name and common repository naming patterns. They discovered a repository created by a developer that contained the application's source code, including configuration files with production credentials.

**Findings:**
- Full application source code in a public GitHub repository
- Database credentials hardcoded in configuration files
- AWS access keys in environment configuration
- Internal API endpoints and service URLs

**Impact:** The exposed source code and credentials could be used to access the production database, AWS infrastructure, and internal services. The credentials were active and had not been rotated since they were committed.

**Remediation:** The repository was made private, credentials were rotated immediately, and the organization implemented pre-commit hooks to prevent credential leakage. AWS IAM policies were reviewed to limit the blast radius of compromised credentials.

### Example 5: Technology Stack Fingerprinting Leading to Vulnerability Discovery
A security assessment used technology fingerprinting to identify the specific software versions running on the target, enabling focused vulnerability testing.

**Reconnaissance Process:**
The tester analyzed HTTP headers, HTML source, and JavaScript files to identify the technology stack. The analysis revealed that the application was running an outdated version of a popular framework with known vulnerabilities.

**Findings:**
- Web server: Apache 2.4.29 (known CVE-2017-15715)
- Framework: Django 2.0 (known CVE-2019-3498)
- JavaScript library: jQuery 3.1.0 (known CVE-2019-11358)
- Database: PostgreSQL 10.5 (known CVE-2018-1058)

**Impact:** The outdated software versions contained known vulnerabilities that could be exploited using public exploit code. The combination of multiple outdated components significantly increased the overall risk.

**Remediation:** The organization created a patch management process to keep all software components up to date. Vulnerability scanning was integrated into the CI/CD pipeline to detect outdated components before deployment.

---

## Advanced Techniques

### DNS Enumeration Techniques
DNS enumeration is the foundation of subdomain discovery. Multiple techniques provide complementary coverage.

#### Dictionary-Based Enumeration
Use wordlists to enumerate common subdomain names. Tools like Sublist3r, Amass, and assetfinder automate this process. Customize wordlists based on the target's naming conventions observed during passive reconnaissance.

#### Certificate Transparency Enumeration
Search certificate transparency logs for all certificates issued for the target domain. Services like crt.sh, Censys, and Certificate Search provide API access to certificate data that reveals subdomains.

#### DNS Record Analysis
Analyze DNS records for additional information. MX records reveal email infrastructure, TXT records reveal SPF/DKIM/DMARC configurations, and NS records reveal delegation patterns.

#### Reverse DNS Enumeration
Perform reverse DNS lookups on IP addresses discovered during reconnaissance. Reverse lookups may reveal additional hostnames and services not found through forward DNS enumeration.

### Port Scanning Strategies
Port scanning identifies open ports and running services on target systems.

#### SYN Scanning
SYN scanning sends SYN packets and analyzes responses without completing the TCP handshake. It is stealthier than full connect scanning but requires root/administrator privileges on most operating systems.

#### Connect Scanning
Connect scanning completes the full TCP handshake for each port. It is more reliable and does not require special privileges but is more easily detected by intrusion detection systems.

#### Service Version Detection
After identifying open ports, perform service version detection to identify the exact software and version running. Version detection enables targeted vulnerability testing for known CVEs.

#### OS Fingerprinting
Use TCP/IP stack fingerprinting to identify the operating system. OS fingerprinting analyzes TCP window sizes, TTL values, and other packet characteristics to determine the target operating system.

### Technology Fingerprinting Techniques
Technology fingerprinting identifies the specific software stack used by the target.

#### HTTP Header Analysis
Analyze HTTP response headers for technology indicators. Common indicators include:
- Server: Web server software and version
- X-Powered-By: Application framework or language
- X-AspNet-Version: ASP.NET version
- X-Generator: CMS or framework identifier
- Set-Cookie: Framework-specific cookie names

#### HTML Source Analysis
Examine HTML source code for technology indicators:
- Meta generator tags identify CMS platforms
- Script and CSS file paths reveal framework directory structures
- Comment annotations may contain version information
- Doctype declarations identify HTML standards compliance

#### JavaScript Framework Detection
Identify JavaScript frameworks through multiple indicators:
- Global variables (React: __REACT_DEVTOOLS_GLOBAL_HOOK__, Angular: ng, Vue: __VUE__)
- Script file naming patterns (angular.js, react.js, vue.js)
- DOM structure patterns and data attributes
- Network requests to framework-specific endpoints

#### WAF Detection
Identify Web Application Firewalls through response analysis:
- HTTP status codes for blocked requests (403, 406, 429)
- Response headers containing WAF identifiers
- Error pages with WAF branding
- Request blocking patterns

### Exposure Discovery Techniques
Exposure discovery identifies accessible information and resources that should not be publicly available.

#### Directory Brute-Forcing
Use wordlists to discover accessible directories and files. Tools like ffuf, dirsearch, and feroxbuster automate this process. Customize wordlists based on the target's technology stack and naming conventions.

#### File Discovery Patterns
Test for common file patterns that may be exposed:
- Configuration files (.env, .config, .json, .yaml)
- Backup files (.bak, .old, .sql, .tar.gz)
- Debug endpoints (/debug, /phpinfo, /actuator)
- Documentation (/docs, /api, /swagger)

#### JavaScript File Analysis
Analyze JavaScript files for exposed endpoints, API keys, and internal information. JavaScript files often contain hardcoded URLs, tokens, and configuration data that are useful for further testing.

#### Error Page Analysis
Trigger error conditions to analyze error pages for information disclosure. Common techniques include:
- Invalid parameters to trigger application errors
- Special characters to trigger database errors
- Invalid HTTP methods to trigger method not allowed errors
- Oversized payloads to trigger validation errors

### Reconnaissance Automation
Automating reconnaissance activities improves efficiency and consistency across engagements.

#### Automated Discovery Pipelines
Create automated pipelines that chain multiple reconnaissance tools:
- Subdomain enumeration → DNS resolution → Port scanning → Service fingerprinting
- URL discovery → Parameter extraction → Technology identification
- Certificate transparency → Subdomain validation → HTTP probing

#### Continuous Monitoring
Set up continuous monitoring for changes in the target's attack surface:
- New subdomain discovery
- Certificate transparency log alerts
- Port and service changes
- New technology deployments

#### Results Correlation
Correlate results from multiple tools to build a comprehensive picture:
- Merge subdomain lists from multiple sources
- Deduplicate IP addresses and services
- Cross-reference technology fingerprints
- Prioritize findings based on risk

### Operational Security During Reconnaissance
Maintaining operational security during reconnaissance prevents detection and protects the tester.

#### Traffic Pattern Management
Manage traffic patterns to avoid triggering intrusion detection systems:
- Use random timing between requests
- Vary request headers and patterns
- Rotate through multiple source IP addresses
- Use proxy chains and VPN services

#### User-Agent Rotation
Rotate user-agent strings to avoid fingerprinting:
- Use realistic browser user-agents
- Match user-agents to requested content types
- Avoid known scanner user-agents
- Include appropriate Accept headers

#### Rate Limiting Awareness
Be aware of rate limiting and implement appropriate delays:
- Monitor for rate limit responses (429, 503)
- Implement exponential backoff on rate limits
- Distribute requests over time
- Use multiple source addresses when possible

---

## Common Pitfalls

### Pitfall 1: Incomplete Subdomain Enumeration
Failing to enumerate all subdomains leads to missed attack surface. Use multiple enumeration techniques and tools to maximize coverage. Cross-reference results from different sources to identify gaps.

### Pitfall 2: Ignoring Passive Sources
Relying only on active scanning misses information available from passive sources. Always begin with comprehensive passive reconnaissance before launching active probes.

### Pitfall 3: Technology Fingerprinting Errors
Incorrect technology identification leads to wasted effort on inappropriate vulnerability testing. Use multiple fingerprinting techniques and verify findings through multiple indicators.

### Pitfall 4: Missing Development Environments
Development and staging environments often have weaker security controls. Actively search for development subdomains and test environments that may not be listed in public documentation.

### Pitfall 5: Overlooking Certificate Transparency
Certificate transparency logs reveal subdomains that may not appear in DNS enumeration. Always search certificate transparency logs as part of comprehensive subdomain discovery.

### Pitfall 6: Insufficient Exposure Discovery
Failing to test for exposed files and directories misses easy wins. Systematically test for common exposure patterns and customize testing based on the target's technology stack.

### Pitfall 7: Poor Documentation
Inadequate documentation of reconnaissance findings leads to missed opportunities during testing. Document all findings systematically and create actionable summaries for the testing team.

---

## Tools and Resources

### Subdomain Enumeration
- **Subfinder**: Fast passive subdomain enumeration tool
- **Amass**: Comprehensive attack surface mapping tool
- **assetfinder**: Lightweight subdomain discovery tool
- **crt.sh**: Certificate transparency log search
- **DNSDumpster**: DNS reconnaissance and research tool

### Port Scanning
- **Nmap**: Industry-standard port scanner and service detector
- **Masscan**: Fastest Internet port scanner
- **RustScan**: Modern port scanner written in Rust
- **Unicornscan**: Asynchronous TCP/UDP scanner

### Technology Fingerprinting
- **Wappalyzer**: Web technology profiler
- **BuiltWith**: Web technology profiler with detailed reports
- **whatweb**: Next-generation web scanner
- **httpx**: Fast HTTP probing tool

### Directory Discovery
- **ffuf**: Fast web fuzzer for directory discovery
- **dirsearch**: Web path scanner
- **feroxbuster**: Fast, simple, recursive content discovery tool
- **gobuster**: Directory and DNS busting tool

### Exposure Discovery
- **Nuclei**: Fast vulnerability scanner with templates
- **Arjun**: HTTP parameter discovery suite
- **LinkFinder**: Discover endpoints in JavaScript files
- **SecretFinder**: Find secrets in JavaScript files

### OSINT Tools
- **Maltego**: OSINT and graphical link analysis tool
- **Recon-ng**: Full-featured web reconnaissance framework
- **theHarvester**: Email, subdomain, and name harvester
- **Shodan**: Internet-connected device search engine
- **Censys**: Internet-wide scanning and search

### Reference Materials
- **PTES**: Penetration Testing Execution Standard
- **OWASP Testing Guide**: Comprehensive security testing methodology
- **NIST SP 800-115**: Technical guide for information security testing
- **Bug Bounty Recon Methodology**: Community-driven reconnaissance guides

---

## Quick Reference Cheat Sheet

### Reconnaissance Checklist
```
Passive Reconnaissance:
[ ] Domain enumeration (related TLDs, variations)
[ ] WHOIS registration analysis
[ ] Certificate transparency log search
[ ] Search engine intelligence gathering
[ ] Code repository analysis
[ ] Social media reconnaissance
[ ] Job posting analysis
[ ] Public documentation review

Active Reconnaissance:
[ ] DNS enumeration (brute-force, reverse, zone transfer)
[ ] Port scanning (top 1000 ports, then all ports)
[ ] Service fingerprinting and version detection
[ ] Technology stack identification
[ ] Directory and file discovery
[ ] Exposure discovery
[ ] Subdomain takeover verification
[ ] API endpoint discovery

Documentation:
[ ] Asset inventory (domains, IPs, applications)
[ ] Technology stack summary
[ ] Exposure list with severity ratings
[ ] Attack surface map
[ ] Testing recommendations
```

### Subdomain Discovery Commands
```
Subfinder: subfinder -d example.com -o subdomains.txt
Amass: amass enum -passive -d example.com -o amass.txt
Assetfinder: assetfinder --subs-only example.com > assets.txt
Crt.sh: curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sort -u
DNSRecon: dnsrecon -d example.com -t brt -D wordlist.txt
```

### Port Scanning Commands
```
Nmap SYN Scan: nmap -sS -p- -T4 target_ip
Nmap Service Detection: nmap -sV -sC -p 80,443,8080 target_ip
Nmap OS Detection: nmap -O -osscan-guess target_ip
Masscan: masscan target_ip -p0-65535 --rate 1000
RustScan: rustscan -a target_ip -- -sV -sC
```

### Technology Fingerprinting
```
HTTP Headers: curl -I https://example.com
Wappalyzer: Browser extension for technology detection
WhatWeb: whatweb --color=never https://example.com
httpx: httpx -l urls.txt -tech-detect -status-code
```

### Directory Discovery
```
FFUF: ffuf -u https://example.com/FUZZ -w wordlist.txt
Dirsearch: dirsearch -u https://example.com -e php,html,js
Feroxbuster: feroxbuster -u https://example.com -w wordlist.txt
Gobuster: gobuster dir -u https://example.com -w wordlist.txt
```

### Exposure Discovery Patterns
```
Common Files:
robots.txt, sitemap.xml, .env, .git/config
web.config, .htaccess, .DS_Store
phpinfo.php, server-status, server-info
swagger.json, openapi.json, graphql

Debug Endpoints:
/debug, /actuator, /trace, /metrics
/console, /admin, /phpmyadmin
/.well-known/, /elmah.axd, /trace.axd

Backup Patterns:
*.bak, *.old, *.sql, *.tar.gz
*~, *.swp, *.swo
backup/, backup-/, db_backup/
```

### OSINT Search Queries
```
Google Dorks:
site:example.com filetype:pdf
site:example.com inurl:admin
site:example.com intitle:"index of"
site:example.com ext:sql | ext:bak | ext:log

GitHub Search:
"example.com" password
"example.com" api_key
"example.com" secret
"example.com" credentials
```
