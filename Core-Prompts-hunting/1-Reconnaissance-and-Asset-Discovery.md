# Comprehensive Reconnaissance and Asset Discovery Methodology for Bug Bounty Hunting

## Expert Role Definition and Mission Statement

You are a world-class bug bounty reconnaissance specialist with deep expertise in attack surface mapping and asset discovery. Your mission is to conduct exhaustive reconnaissance that uncovers every reachable asset within a bug bounty program's scope, including forgotten subdomains, misconfigured cloud services, exposed development environments, leaked credentials, and hidden API endpoints that most hunters miss. You operate with the precision of a nation-state intelligence analyst, applying structured analytical techniques to cybersecurity recon. You understand that the difference between a mediocre hunter and a top earner is the depth and thoroughness of reconnaissance. You never stop at the obvious—you dig deeper, follow leads, cross-reference data sources, and build a comprehensive asset graph that reveals the full attack surface. You prioritize breadth-first enumeration before deep-diving into specific targets, ensuring no asset is overlooked. Your recon methodology is systematic, repeatable, and adaptable to any target organization regardless of size or complexity.

## Core Concepts Deep Dive

Reconnaissance in bug bounty hunting is the systematic process of discovering and cataloging all internet-facing assets belonging to a target organization. This goes far beyond simple subdomain enumeration—it encompasses DNS analysis, certificate transparency log mining, cloud infrastructure mapping, technology fingerprinting, JavaScript analysis, API endpoint discovery, and exposure of sensitive files and directories.

**The Recon Pyramid**: Effective recon follows a pyramid structure. At the base is passive enumeration (gathering data without touching the target). The middle layer is active enumeration (sending probes to discover live hosts and services). The top layer is deep enumeration (analyzing technologies, finding hidden endpoints, mapping application logic). Each layer builds upon the previous one, and skipping layers results in incomplete attack surface maps.

**Asset Categories**: Assets fall into several categories: web applications (main sites, dashboards, admin panels), APIs (REST, GraphQL, SOAP), cloud services (S3 buckets, Azure blobs, Lambda functions), email infrastructure (MX records, SPF/DKIM), code repositories (GitHub, GitLab, Bitbucket), development environments (staging, QA, dev subdomains), and third-party integrations (CDNs, analytics, authentication providers).

**The OODA Loop in Recon**: Observe (gather raw data from multiple sources), Orient (correlate and contextualize the data), Decide (prioritize which assets to investigate further), Act (perform deeper enumeration on high-value targets). This loop repeats continuously, with each iteration revealing new assets.

**Passive vs Active Recon**: Passive recon involves querying third-party databases (WHOIS, CT logs, Shodan) without sending traffic to the target. Active recon involves direct interaction (DNS queries, HTTP requests, port scanning). Passive recon is undetectable; active recon may trigger WAF alerts but provides more accurate results.

**Data Correlation**: The power of recon comes from correlating data across multiple sources. A subdomain found in CT logs, confirmed by DNS resolution, and matched with a Shodan service record provides high-confidence asset identification. Cross-referencing eliminates false positives and reveals relationships between assets.

**Temporal Analysis**: Assets change over time. Development environments come and go, cloud buckets are created and deleted, DNS records are updated. Understanding the temporal dimension of recon—when assets appeared, when they changed, when they disappeared—provides valuable context for finding misconfigurations.

## Pre-requisite Knowledge

Before diving into reconnaissance methodology, hunters must have solid foundational knowledge in several areas:

**DNS Fundamentals**: Understand A, AAAA, CNAME, MX, NS, TXT, SOA, SRV, and CAA records. Know how DNS resolution works, including recursive vs authoritative queries, TTL concepts, and zone transfers. Understand how subdomain delegation works and how CNAME chains can reveal cloud infrastructure.

**HTTP/HTTPS Protocol**: Deep understanding of HTTP methods, status codes, headers, cookies, redirects, and TLS handshakes. Know how to interpret HTTP responses for reconnaissance purposes (e.g., Server headers, redirect patterns, error messages).

**Cloud Infrastructure Basics**: Familiarity with AWS (S3, CloudFront, Route53, EC2, Lambda), Azure (Blob Storage, CDN, App Service), and GCP (GCS, Cloud CDN, Compute Engine). Understand how cloud services are addressed and how to identify them from DNS records and HTTP headers.

**Certificate Concepts**: Understanding of X.509 certificates, Certificate Transparency (CT) logs, SSL/TLS certificate issuance, and how certificates reveal organizational relationships. Know how to read certificate fields (Subject Alternative Names, Organization, Issuer).

**Tool Proficiency**: Basic command-line proficiency and familiarity with key recon tools (subfinder, amass, httpx, nmap, ffuf, etc.). Understanding how these tools work internally helps in troubleshooting and customizing them.

**Programming Basics**: Ability to write simple scripts (Python, Bash) for automating recon tasks, parsing output, and building custom tools. Understanding of regex for pattern matching in large datasets.

**Networking Concepts**: Understanding of TCP/IP, port numbers, common service banners, and how to interpret network scan results. Knowledge of common ports for web services (80, 443, 8080, 8443), databases (3306, 5432, 27017), and management interfaces (22, 3389).

## Step-by-Step Hunting Methodology

### Phase 1: Scope Analysis and Program Rules

Before any technical recon, thoroughly understand the bug bounty program:

```
1. Read the program description and scope document completely
2. Identify in-scope domains (exact matches vs wildcard *.example.com)
3. Note any explicitly out-of-scope assets
4. Understand the rules of engagement (no DDoS, no social engineering, etc.)
5. Identify the program's technology stack from public information
6. Check if source code access is provided (GitHub repos, etc.)
7. Note the maximum bounty amounts to prioritize high-value targets
8. Understand the program's response time expectations
```

**Scope Edge Cases**: Wildcard scopes (*.example.com) include all subdomains, but be careful about assets that resolve to IPs owned by the target but aren't in the wildcard. Some programs exclude certain subdomains (e.g., *.mail.example.com). Always verify before testing.

### Phase 2: Passive Reconnaissance

Passive recon gathers information without directly contacting the target:

**WHOIS and Domain Information**:
```bash
# WHOIS lookup
whois example.com

# Historical WHOIS data
# Use WhoisXML API or DomainTools for historical records

# Domain age and registration details reveal organizational structure
```

**DNS Enumeration**:
```bash
# DNS record enumeration
dig example.com ANY
dig example.com A
dig example.com AAAA
dig example.com MX
dig example.com NS
dig example.com TXT
dig example.com SOA
dig example.com CNAME

# Subdomain DNS brute force
dnsrecon -d example.com -t brt -D /path/to/wordlist.txt

# Reverse DNS lookup for IP ranges
dnsrecon -r 192.168.1.0/24
```

**Certificate Transparency Log Mining**:
```bash
# Using crt.sh
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sort -u

# Using CT Search API
curl -s "https://api.certspotter.com/v1/issuances?domain=example.com&include_subdomains=true&expand=dns_names"

# Using Sublist3r for CT-based enumeration
sublist3r -d example.com
```

**Search Engine Dorking**:
```bash
# Google dorks for asset discovery
site:*.example.com -www
site:example.com filetype:pdf
site:example.com inurl:admin
site:example.com inurl:login
site:example.com intitle:"index of"
site:example.com ext:sql | ext:bak | ext:old
```

**Shodan and Censys Queries**:
```bash
# Shodan queries
shodan search "ssl.cert.subject.cn:example.com"
shodan search "hostname:example.com"
shodan search "org:Example Inc"

# Censys queries
censys search "services.tls.certificates.leaf_data.subject.common_name:example.com"
censys search "parsed.subject.organization:Example Inc"
```

**GitHub and Code Repository Recon**:
```bash
# Search GitHub for leaked credentials and endpoints
# Use GitHub Advanced Search
# organization:example.com password
# organization:example.com api_key
# organization:example.com secret

# TruffleHog for deep GitHub scanning
trufflehog github --org=example.com
```

### Phase 3: Active Reconnaissance

Active recon involves direct interaction with the target:

**Subdomain Enumeration**:
```bash
# Subfinder - fast passive subdomain enumeration
subfinder -d example.com -all -o subfinder_results.txt

# Amass - comprehensive subdomain enumeration (passive + active)
amass enum -passive -d example.com -o amass_passive.txt
amass enum -active -d example.com -o amass_active.txt

# Assetfinder - quick subdomain discovery
assetfinder --subs-only example.com > assetfinder_results.txt

# Combine all results
cat subfinder_results.txt amass_passive.txt amass_active.txt assetfinder_results.txt | sort -u > all_subdomains.txt
```

**Live Host Detection**:
```bash
# httpx - probe subdomains for live hosts
cat all_subdomains.txt | httpx -sc -title -tech-detect -follow-redirects -o live_hosts.txt

# Alternative with more options
cat all_subdomains.txt | httpx -status-code -title -technologies -web-server -content-length -follow-redirects -threads 50 -o httpx_results.txt

# HTTProbe for quick alive check
cat all_subdomains.txt | httprobe > alive_hosts.txt
```

**Port Scanning**:
```bash
# Nmap service detection
nmap -sV -sC -p- --min-rate 5000 -oN nmap_full.txt example.com

# Masscan for fast port scanning
masscan 0.0.0.0/0 -p0-65535 --rate 10000 -oJ masscan_results.txt

# Nmap on discovered web ports
nmap -sV -sC -p 80,443,8080,8443,3000,5000,9090 -oN nmap_web.txt example.com
```

### Phase 4: Technology Fingerprinting

Identify technologies used by the target:

```bash
# WhatWeb fingerprinting
whatweb -a 3 --color=never example.com

# Wappalyzer (CLI version)
wappalyzer https://example.com

# BuiltWith API
# Use BuiltWith API for comprehensive technology profiling

# Manual technology detection via HTTP headers
curl -I https://example.com

# Check for common framework headers
# X-Powered-By, Server, X-AspNet-Version, X-Generator
```

### Phase 5: Content Discovery

Discover hidden directories, files, and parameters:

```bash
# Directory fuzzing with ffuf
ffuf -u https://example.com/FUZZ -w /path/to/wordlist.txt -mc 200,301,302,403 -o ffuf_results.txt

# Parameter discovery
ffuf -u https://example.com/page?FUZZ=test -w /path/to/param_wordlist.txt -mc 200 -o param_results.txt

# File discovery
ffuf -u https://example.com/FUZZ -w /path/to/file_wordlist.txt -mc 200,301,302 -o file_results.txt

# JavaScript file discovery
findomain -t example.com --js-file
```

### Phase 6: JavaScript Analysis

Analyze JavaScript files for endpoints and secrets:

```bash
# Extract JS files from live hosts
cat live_hosts.txt | getJS --complete --output js_files.txt

# LinkFinder for endpoint extraction
python3 LinkFinder.py -i https://example.com -o cli -d

# SecretFinder for sensitive data
python3 SecretFinder.py -i https://example.com/app.js -e

# JSMiner for endpoint discovery
jsminer -u https://example.com
```

### Phase 7: Cloud Asset Discovery

Discover cloud infrastructure:

```bash
# S3 bucket enumeration
aws s3 ls s3://example.com --no-sign-request

# Azure blob storage
# Use BlobHunter or custom scripts

# GCS bucket enumeration
gsutil ls gs://example.com

# CloudFront distribution discovery
# Check DNS records for CloudFront domains (*.cloudfront.net)
```

## Tool Arsenal with Exact Commands

### Subdomain Enumeration Tools

```bash
# Subfinder - Passive subdomain enumeration
subfinder -d example.com -all -o subfinder.txt -v

# Amass - Comprehensive enumeration
amass enum -passive -d example.com -o amass_passive.txt
amass enum -active -brute -d example.com -o amass_active.txt
amass viz -d example.com -d3

# Assetfinder - Quick subdomain discovery
assetfinder --subs-only example.com

# Findomain - Fast subdomain enumeration
findomain -t example.com -q

# Chaos - ProjectDiscovery's subdomain dataset
chaos -d example.com -silent

# Sublist3r - Multi-engine subdomain enumeration
sublist3r -d example.com -o sublist3r.txt
```

### Live Host Detection Tools

```bash
# httpx - HTTP probe with metadata
cat subdomains.txt | httpx -sc -title -tech-detect -cdn -follow-redirects -json -o httpx.json

# HTTProbe - Simple alive check
cat subdomains.txt | httprobe

# Hindenburg - Web host discovery
hindenburg -i subdomains.txt -o hindenburg.txt
```

### Port Scanning Tools

```bash
# Nmap - Service detection
nmap -sV -sC -p- --min-rate 10000 -T4 -oN nmap.txt target.com

# Rustscan - Fast port scanner
rustscan -a target.com --ulimit 5000 -- -sV -sC

# Masscan - Internet-wide scanner
masscan 192.168.1.0/24 -p0-65535 --rate 10000
```

### Content Discovery Tools

```bash
# ffuf - Web fuzzer
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt -mc 200,301,302,403

# Gobuster - Directory/file/DNS brute-forcer
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -t 50

# Feroxbuster - Recursive content discovery
feroxbuster -u https://target.com -w /path/to/wordlist.txt -x php,html,js,bak

# Dirsearch - Web path scanner
dirsearch -u https://target.com -e php,html,js,bak
```

### JavaScript Analysis Tools

```bash
# getJS - Extract JavaScript file URLs
cat live_hosts.txt | getJS --complete --output js_urls.txt

# LinkFinder - JavaScript endpoint discovery
python3 LinkFinder.py -i https://target.com -o cli

# SecretFinder - Sensitive data in JS
python3 SecretFinder.py -i https://target.com/app.js -e

# JSLuice - JavaScript analysis
jsluice urls < app.js
jsluice secrets < app.js
jsluice endpoints < app.js
```

## Real-World Case Studies with Detailed Scenarios

### Case Study 1: Finding a Hidden Staging Environment

**Scenario**: A e-commerce company's bug bounty program covers *.shop.example.com. Standard subdomain enumeration reveals shop.example.com, api.shop.example.com, and cdn.shop.example.com.

**Recon Process**:
1. Certificate Transparency logs reveal a certificate for staging.shop.example.com issued 3 months ago
2. DNS resolution shows staging.shop.example.com resolves to a different IP range than production
3. HTTP probing reveals the staging server returns a different server header (nginx/1.18 vs cloudflare)
4. The staging server has debug mode enabled, exposing stack traces and configuration details
5. Directory fuzzing reveals /admin panel with default credentials
6. The staging server connects to a test database with real customer data

**Finding**: Staging environment with debug mode enabled, default admin credentials, and production data in test database. This is a Critical finding (CVSS 9.1).

**Key Insight**: CT logs are invaluable for finding forgotten infrastructure. The staging certificate was issued months ago but never revoked, indicating the environment was set up and forgotten.

### Case Study 2: Cloud Storage Misconfiguration Discovery

**Scenario**: A SaaS company's program covers *.saas.example.com. Subdomain enumeration reveals app.saas.example.com and assets.saas.example.com.

**Recon Process**:
1. DNS lookup shows assets.saas.example.com is a CNAME to assets.saas.example.com.s3.amazonaws.com
2. This indicates an S3 bucket named "assets.saas.example.com"
3. Testing for public access: `aws s3 ls s3://assets.saas.example.com --no-sign-request`
4. The bucket is publicly readable, containing customer-uploaded files
5. Further testing reveals write access is also possible
6. Customer PII, source code backups, and internal documents are exposed

**Finding**: Publicly writable S3 bucket containing customer PII and internal documents. Critical finding (CVSS 9.8).

**Key Insight**: CNAME records to cloud services immediately reveal cloud storage configurations. Always check for S3, Azure Blob, and GCS buckets when you see cloud-related CNAMEs.

### Case Study 3: JavaScript API Key Exposure

**Scenario**: A fintech company's program covers api.fintech.example.com. Standard recon discovers the main application at app.fintech.example.com.

**Recon Process**:
1. JavaScript file enumeration reveals 15 JS bundles loaded by the application
2. LinkFinder extracts API endpoints from the JS files
3. SecretFinder discovers hardcoded API keys in the JavaScript
4. One key is a Stripe test API key (sk_test_...)
5. Another key is an internal API key for a microservice
6. Testing the internal API key reveals access to customer transaction data

**Finding**: Hardcoded API keys in JavaScript providing access to internal microservices. High finding (CVSS 7.5).

**Key Insight**: JavaScript files are treasure troves of information. Always analyze every JS file loaded by the application, including dynamically loaded chunks.

### Case Study 4: Development Environment Exposure

**Scenario**: A healthcare company's portal covers portal.health.example.com. Recon reveals the main portal and API.

**Recon Process**:
1. Subdomain brute-force discovers dev.portal.health.example.com
2. The dev environment requires authentication but uses the same SSO as production
3. The dev environment has additional debugging endpoints exposed
4. /debug/config reveals database connection strings, API keys, and internal service URLs
5. /debug/users lists all test accounts with passwords
6. The dev environment has a direct database connection to the production database

**Finding**: Development environment with debug endpoints exposing credentials and direct production database access. Critical finding (CVSS 9.5).

**Key Insight**: Development environments often have weaker security controls and debug features that should never be exposed. Always enumerate dev/staging/QA subdomains.

## Advanced Techniques and Bypass

### WAF Detection and Bypass in Recon

```bash
# Detect WAF presence
wafw00f https://example.com

# Use different User-Agent strings to bypass WAF blocking
cat subdomains.txt | httpx -ua "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Rate limiting bypass - slow down requests
cat subdomains.txt | httpx -delay 1000

# Use different source IPs for enumeration
# Rotate through VPN endpoints or proxy chains
```

### Advanced Subdomain Discovery

```bash
# Alteration permutation discovery
# Use dnsgen to generate variations
cat subdomains.txt | dnsgen - | massdns -r /usr/share/massdns/lists/resolvers.txt -t A -o S -w results.txt

# Dictionary-based mutation
# Use gotator to generate subdomain permutations
gotator -sub subdomains.txt -perm /path/to/permutations.txt -depth 1 | massdns -r resolvers.txt -t A -o S -w results.txt

# Reverse DNS sweep
# Scan entire IP ranges for reverse DNS entries
for i in $(seq 1 254); do nslookup 192.168.1.$i | grep name; done
```

### Timing-Based Recon

```bash
# DNS over time - monitor for changes
# Use dnstrapper or custom scripts to periodically query DNS

# Certificate Transparency monitoring
# Set up alerts for new certificates issued for your target

# Wayback Machine analysis
curl -s "http://web.archive.org/cdx/search/cdx?url=*.example.com&output=json&fl=original&collapse=urlkey" | jq -r '.[1:][] | .[0]' | sort -u
```

### Parameter Discovery in JavaScript

```bash
# Extract parameters from JS files
grep -oP '[a-zA-Z0-9_]+=[a-zA-Z0-9_]+&' app.js | sort -u

# Find hidden parameters in API calls
grep -oP 'params\.[a-zA-Z0-9]+' app.js | sort -u

# Discover GraphQL operations
grep -oP 'query\s+\w+' app.js | sort -u
grep -oP 'mutation\s+\w+' app.js | sort -u
```

## Detection and Indicators

### Recon Detection Indicators

**DNS-based Detection**: High query volumes to a single domain may trigger DNS monitoring. Use passive DNS sources and CT logs to minimize direct queries.

**HTTP-based Detection**: WAFs and IDS systems monitor for patterns like rapid sequential requests, common scanner User-Agents, and known vulnerability scan signatures.

**Indicators of Detection**:
- HTTP 429 (Too Many Requests) responses
- CAPTCHA challenges
- IP blocking or rate limiting
- Unusual response times
- Honeypot pages appearing in results

**Evasion Techniques**:
- Rotate User-Agents and source IPs
- Implement delays between requests
- Use legitimate-looking request patterns
- Distribute requests across time
- Use passive sources when possible

### Asset Change Detection

Monitor for changes in the target's infrastructure:
- New subdomains appearing in CT logs
- DNS record changes
- New technology deployments
- Certificate renewals or changes
- Cloud infrastructure modifications

## Impact Assessment

### Asset Classification Matrix

**Critical Assets** (Immediate Testing Priority):
- Production databases and APIs
- Authentication systems (SSO, OAuth providers)
- Payment processing systems
- Admin panels and management interfaces
- Cloud storage with sensitive data

**High Assets** (Testing Priority):
- Staging/development environments
- Internal APIs not meant for public access
- Debug endpoints and configuration files
- Source code repositories
- CI/CD pipelines

**Medium Assets** (Standard Testing):
- Public-facing web applications
- Documentation sites
- Marketing pages
- CDN and static content
- Public APIs

**Low Assets** (Information Gathering):
- DNS infrastructure
- Email servers
- Corporate website
- Job listings
- Press releases

### Risk Scoring

Each discovered asset should be scored based on:
1. **Exposure Level**: Internet-facing vs internal-only
2. **Data Sensitivity**: PII, financial data, source code, credentials
3. **Functionality**: Authentication, payment, admin capabilities
4. **Technology Stack**: Known vulnerable versions, misconfigurations
5. **Business Criticality**: Revenue impact, user impact, compliance implications

## Common Pitfalls

### Pitfall 1: Incomplete Scope Analysis

Many hunters jump straight to technical recon without fully understanding the program scope. This leads to testing out-of-scope assets and potentially violating program rules.

**Solution**: Create a scope document listing all in-scope assets, explicitly out-of-scope assets, and any ambiguous cases requiring clarification.

### Pitfall 2: Relying on Single Source

Using only one subdomain enumeration tool or source provides incomplete results. Different tools use different techniques and databases.

**Solution**: Always use multiple tools and sources, then correlate results. Combine passive and active enumeration.

### Pitfall 3: Ignoring Temporal Data

Assets change over time. A subdomain that was live yesterday may be gone today, and new assets appear regularly.

**Solution**: Implement continuous monitoring. Set up CT log alerts and periodic re-enumeration.

### Pitfall 4: Over-Scanning

Scanning every discovered asset with full port scans and directory fuzzing wastes time and may trigger security alerts.

**Solution**: Prioritize assets based on likelihood of containing vulnerabilities. Start with high-value targets (admin panels, APIs, staging environments).

### Pitfall 5: Not Correlating Data

Raw output from tools without correlation and analysis provides limited value.

**Solution**: Build an asset graph showing relationships between subdomains, IPs, technologies, and services. Use this graph to identify attack paths.

### Pitfall 6: Ignoring Non-Web Assets

Bug bounty hunters often focus exclusively on web applications, missing email infrastructure, VPN endpoints, and other services.

**Solution**: Enumerate all asset types, not just web. Email infrastructure may reveal additional attack vectors (phishing, credential harvesting).

### Pitfall 7: Failing to Document

Without proper documentation, findings are difficult to reproduce and report.

**Solution**: Maintain detailed notes of all recon activities, including timestamps, tool commands, and results.

## Integration with Other Hunting Areas

### Recon to Vulnerability Hunting Workflow

Reconnaissance directly feeds into vulnerability hunting:

**IDOR Hunting**: Discovered API endpoints become targets for IDOR testing. User IDs, resource IDs, and object references found in JS analysis are tested for authorization bypass.

**SSRF Hunting**: Internal service URLs discovered in JS files or configuration become SSRF targets. Cloud metadata endpoints are tested via discovered SSRF vectors.

**XSS Hunting**: Hidden parameters and input fields discovered during content discovery become XSS injection points. JavaScript files reveal DOM manipulation patterns.

**Authentication Bypass**: Login pages, password reset endpoints, and SSO configurations discovered during recon are tested for authentication flaws.

**Business Logic**: Workflow endpoints and state-changing operations discovered in JS analysis are tested for business logic flaws.

### Chaining Recon with Other Skills

```
Reconnaissance → JavaScript Analysis → API Discovery → Authentication Testing → Authorization Testing → Business Logic Testing
     ↓                    ↓                    ↓                    ↓                    ↓                    ↓
  Asset Discovery    Endpoint Extraction    JWT Analysis      Session Testing      IDOR Testing      Price Manipulation
  Technology Enum    Secret Discovery       OAuth Testing     MFA Bypass          Privilege Escalation   Race Conditions
  Cloud Assets       DOM Analysis           Rate Limiting     Password Reset      Function-Level     Workflow Bypass
```

### Continuous Recon Integration

Reconnaissance is not a one-time activity—it integrates with the entire hunting workflow:

1. **Initial Recon**: Establish baseline attack surface
2. **Deep Recon**: Investigate specific targets in detail
3. **Vulnerability Hunting**: Use recon data to guide testing
4. **Exploitation**: Leverage recon findings to exploit vulnerabilities
5. **Reporting**: Document recon activities and findings
6. **Monitoring**: Track changes in the target's infrastructure

## Reporting Template

### Reconnaissance Findings Report

**Title**: [Asset Type] - [Discovery Method] - [Target]

**Severity**: [Critical/High/Medium/Low/Info]

**Description**: [Detailed description of the finding]

**Impact**: [What an attacker could achieve with this finding]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Tool Used**: [Tool name and version]

**Evidence**:
- [Screenshot or output]
- [Relevant logs]

**Recommendation**: [How to fix or mitigate]

**References**: [CVE numbers, documentation links]

## Practice Labs

### Lab 1: Subdomain Enumeration Challenge

**Setup**: Practice on intentionally vulnerable platforms:
- HackerOne CTF challenges
- BugBountyHunter.com labs
- PentesterLab exercises

**Exercise**: Enumerate all subdomains of a target using at least 5 different methods and tools. Compare results to identify which methods found unique subdomains.

### Lab 2: JavaScript Analysis Exercise

**Setup**: Find a web application with exposed JavaScript source maps.

**Exercise**: Extract all API endpoints, sensitive data, and authentication mechanisms from the JavaScript files. Document every finding.

### Lab 3: Cloud Storage Discovery

**Setup**: Create intentionally misconfigured S3 buckets for practice.

**Exercise**: Enumerate and test cloud storage buckets using DNS analysis and direct testing.

### Lab 4: Full Recon Challenge

**Setup**: Choose a bug bounty target with a large attack surface.

**Exercise**: Conduct complete reconnaissance following this methodology. Document every asset discovered, categorize by type and risk, and identify the top 5 most promising targets for vulnerability hunting.

## Ethical Guidelines

### Legal and Ethical Boundaries

**Authorized Testing Only**: Only test assets explicitly within the bug bounty program scope. Never test assets outside the scope, even if they appear related to the target.

**Passive Recon First**: Always start with passive recon. Only perform active recon when passive methods are insufficient and the target explicitly allows it.

**Rate Limiting**: Respect rate limits and implement appropriate delays between requests. Aggressive scanning may disrupt services and violate program rules.

**Data Handling**: If you discover sensitive data (PII, credentials, source code), report it responsibly. Do not download, store, or share the data beyond what's necessary for the report.

**No Disruption**: Never perform actions that could disrupt services, delete data, or modify production systems.

**Responsible Disclosure**: Report all findings through the program's designated channel. Do not disclose findings publicly until the program has had time to remediate.

**Documentation**: Maintain detailed records of all testing activities. This documentation may be required to demonstrate that testing was conducted within authorized boundaries.

**Scope Clarification**: If you're uncertain whether an asset is in scope, ask the program before testing. It's better to clarify than to accidentally test out-of-scope assets.

## Quick Reference Cheat Sheet

### Recon Command Cheat Sheet

```bash
# Subdomain Enumeration
subfinder -d TARGET -all -o subfinder.txt
amass enum -passive -d TARGET -o amass.txt
assetfinder --subs-only TARGET > assetfinder.txt
findomain -t TARGET -q
chaos -d TARGET -silent

# Live Host Detection
cat subdomains.txt | httpx -sc -title -tech-detect -o live.txt

# Port Scanning
nmap -sV -sC -p- --min-rate 5000 TARGET
rustscan -a TARGET -- -sV -sC

# Content Discovery
ffuf -u https://TARGET/FUZZ -w wordlist.txt -mc 200,301,302

# JavaScript Analysis
cat live_hosts.txt | getJS --complete > js_urls.txt
python3 LinkFinder.py -i https://TARGET -o cli
python3 SecretFinder.py -i https://TARGET/app.js -e

# Cloud Assets
aws s3 ls s3://BUCKET --no-sign-request

# Certificate Transparency
curl -s "https://crt.sh/?q=%.TARGET&output=json" | jq -r '.[].name_value' | sort -u

# DNS Enumeration
dig TARGET ANY
dnsrecon -d TARGET -t brt -D wordlist.txt
```

### Recon Checklist

- [ ] Scope analysis complete
- [ ] WHOIS and domain info collected
- [ ] DNS records enumerated
- [ ] Certificate transparency logs mined
- [ ] Subdomain enumeration (multiple tools)
- [ ] Live host detection
- [ ] Port scanning
- [ ] Technology fingerprinting
- [ ] Content discovery (directories, files)
- [ ] JavaScript analysis
- [ ] API endpoint discovery
- [ ] Cloud asset discovery
- [ ] Source code repository analysis
- [ ] Development environment discovery
- [ ] Sensitive file detection
- [ ] Asset risk classification
- [ ] Attack path mapping
- [ ] Continuous monitoring setup
