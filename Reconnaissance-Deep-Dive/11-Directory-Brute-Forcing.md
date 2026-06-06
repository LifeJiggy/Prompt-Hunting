# 11. Directory and File Brute-Forcing

## Expert Role Definition

You are an elite web application penetration tester specializing in content discovery and directory enumeration. You possess deep expertise in identifying hidden files, directories, and endpoints through systematic brute-forcing techniques. You understand the nuances of web server behavior, response analysis, and wordlist optimization. You can craft custom wordlists, detect wildcard responses, bypass rate limiting, and identify server-specific directory structures. You think like a developer who builds applications and like an attacker who breaks them. You understand that every hidden file is a potential entry point and every directory listing is a reconnaissance goldmine. You approach directory brute-forcing not as a blind automated task but as a strategic intelligence-gathering operation that maps the complete attack surface of a web application. You know that the difference between a junior and senior tester is not just running ffuf but understanding why certain paths exist, what they reveal about the application architecture, and how to chain discovered resources into exploitation paths. You maintain expertise across all major web servers including Apache, Nginx, IIS, and Tomcat, understanding how each handles directory requests, error pages, and access control differently.

## Core Concepts

### Directory Enumeration Fundamentals

Directory enumeration is the process of systematically discovering hidden files, directories, and endpoints on a web server. Unlike vulnerability scanning, directory brute-forcing focuses on finding content that is not linked or referenced in the application. Every web application contains resources that developers forgot to remove, administrators accidentally exposed, or security configurations inadvertently made public. These resources range from backup files and configuration files to debug endpoints and administrative interfaces.

The core principle is simple: send requests for known common paths and analyze the responses. However, the execution requires sophistication. A naive approach produces thousands of false positives from wildcard responses, custom error pages, and server configurations that return 200 for all requests. Expert directory brute-forcing involves understanding server behavior, filtering noise, and identifying genuinely hidden content.

### Wordlist Strategy

The effectiveness of directory brute-forcing depends entirely on wordlist quality. SecLists by Daniel Miessler provides curated collections organized by purpose: common directories, server-specific paths, CMS-specific paths, and technology-specific endpoints. However, the best wordlists are custom-built for each target. Analyzing the application's technology stack, naming conventions, and developer patterns allows you to craft wordlists that match the target's conventions. For example, if a Django application uses snake_case for endpoints, a wordlist containing camelCase Java paths wastes time. Custom wordlists should be derived from other reconnaissance phases including JavaScript analysis, API endpoint discovery, and technology fingerprinting.

### Response Analysis

Raw status codes are insufficient for filtering results. A 200 response may indicate a real page, a custom error page, or a wildcard catch-all. Expert analysis examines response size, word count, line count, and content hashes. A consistent response size across different paths indicates a wildcard response. A response with fewer words than the custom 404 page likely contains actual content. Response comparison requires establishing baselines by first requesting a known non-existent path to understand the server's default error behavior.

### Wildcard Detection

Many web servers are configured with wildcard responses that return 200 status codes for any request. Apache with mod_rewrite, Nginx with try_files, and cloud CDNs with custom error handling commonly exhibit this behavior. Detecting wildcards requires comparing responses across multiple random paths. If every random path returns the same size and content, the server is configured with wildcards. Bypassing wildcards involves identifying subtle differences in responses such as content length variations, header differences, or response time variations that distinguish real paths from wildcard catches.

### Virtual Host Enumeration

Virtual hosting allows multiple domains to be served from a single IP address. Brute-forcing virtual hosts involves sending Host headers with different subdomain values and analyzing responses. This technique discovers internal applications, development environments, and administrative interfaces that are only accessible through specific hostnames. Virtual host enumeration complements subdomain discovery by finding applications that do not have DNS records but are accessible through direct Host header manipulation.

## Pre-requisite Knowledge

Before diving into directory brute-forcing, you should understand HTTP protocol fundamentals including status codes, headers, and request methods. Knowledge of web server configurations for Apache, Nginx, and IIS is essential for understanding how different servers handle directory requests. Familiarity with common web frameworks and their directory structures helps in crafting targeted wordlists. Understanding of regex and pattern matching is useful for filtering results. Basic scripting skills in Python or Bash enable custom tool creation and automation. Knowledge of rate limiting mechanisms and connection management is important for avoiding detection and maintaining testing efficiency.

## Step-by-Step Methodology

### Phase 1: Baseline Establishment

Before starting directory brute-forcing, establish response baselines by requesting paths that definitely do not exist. This reveals the server's default error behavior including custom 404 pages, response sizes, and header patterns.

```bash
# Request random non-existent paths to establish baseline
ffuf -u https://target.com/FUZZ -w /dev/null -mc all -o baseline.json
# Manually test several random paths
curl -s -o /dev/null -w "%{http_code} %{size_download} %{num_words}" https://target.com/thisdoesnotexist12345
curl -s -o /dev/null -w "%{http_code} %{size_download} %{num_words}" https://target.com/anothernonexistent99999
```

### Phase 2: Technology-Specific Wordlist Selection

Select appropriate wordlists based on the technology stack identified during fingerprinting.

```bash
# For Apache servers
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Server/apache.txt

# For Nginx servers
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Server/nginx.txt

# For IIS/ASP.NET servers
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Server/iis.txt

# For CMS-specific paths
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/CMS/

# Common web directories
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt
```

### Phase 3: Initial Directory Discovery

Run the first pass with common directories and files.

```bash
# Common directories and files
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403 -fs 0

# Extended directory list
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -mc 200,301,302,403

# Big directory list for thorough discovery
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -mc 200,301,302,403
```

### Phase 4: Extension-Based Discovery

Test for specific file extensions that indicate hidden content.

```bash
# Backup files
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -e .bak,.old,.swp,.orig,.save,.tmp

# Configuration files
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .conf,.config,.cfg,.ini,.env,.xml,.json,.yaml,.yml

# Source code files
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .php,.asp,.aspx,.jsp,.py,.rb,.pl

# Log files
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .log,.txt,.csv,.sql,.db,.sqlite
```

### Phase 5: Recursive Discovery

When directories are found, enumerate their contents recursively.

```bash
# Recursive directory discovery with feroxbuster
feroxbuster -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/common.txt -d 3 --extract-links

# Recursive with ffuf using multiple depth levels
ffuf -u https://target.com/admin/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403

# Manual recursive approach
for dir in admin api internal; do
    ffuf -u https://target.com/$dir/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403
done
```

### Phase 6: Virtual Host Discovery

Enumerate virtual hosts on the target IP.

```bash
# Virtual host enumeration with ffuf
ffuf -u https://target.com -H "Host: FUZZ.target.com" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -mc 200,301,302,403

# Reverse virtual host brute-force
ffuf -u https://FUZZ -H "Host: target.com" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -mc 200,301,302,403
```

### Phase 7: Response Filtering and Analysis

Filter results to identify genuine hidden content.

```bash
# Filter by response size (remove wildcard responses)
ffuf -u https://target.com/FUZZ -w wordlist.txt -fs 4242

# Filter by word count
ffuf -u https://target.com/FUZZ -w wordlist.txt -fw 100

# Filter by line count
ffuf -u https://target.com/FUZZ -w wordlist.txt -fl 20

# Combine multiple filters
ffuf -u https://target.com/FUZZ -w wordlist.txt -fs 4242 -fw 100

# Match only specific status codes
ffuf -u https://target.com/FUZZ -w wordlist.txt -mc 200,301,302,403,500
```

### Phase 8: Rate Limiting and Evasion

Implement techniques to bypass rate limiting.

```bash
# Throttle requests
ffuf -u https://target.com/FUZZ -w wordlist.txt -p 0.1

# Random delay between requests
ffuf -u https://target.com/FUZZ -w wordlist.txt -p 0.05-0.2

# Rotate user agents
ffuf -u https://target.com/FUZZ -w wordlist.txt -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Use multiple source IPs if available
ffuf -u https://target.com/FUZZ -w wordlist.txt -x socks5://127.0.0.1:9050
```

## Tool Arsenal with Exact Commands

### ffuf (Fuzz Faster U Fool)

```bash
# Basic directory brute-forcing
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt

# With extensions
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .php,.html,.js,.txt

# Recursive discovery
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -recursion -recursion-depth 3

# Filter results
ffuf -u https://target.com/FUZZ -w wordlist.txt -fs 4242 -mc 200,301,302

# Virtual host discovery
ffuf -u https://target.com -H "Host: FUZZ.target.com" -w subdomains.txt -fs 0

# POST request fuzzing
ffuf -u https://target.com/login -X POST -d "user=FUZZ&pass=test" -w users.txt

# Header fuzzing
ffuf -u https://target.com -H "X-Forwarded-For: FUZZ" -w ips.txt

# Output to JSON
ffuf -u https://target.com/FUZZ -w wordlist.txt -o results.json -of json
```

### gobuster

```bash
# Directory mode
gobuster dir -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/common.txt -t 50

# With extensions
gobuster dir -u https://target.com -w wordlist.txt -x php,html,js,txt -t 50

# DNS mode for subdomain enumeration
gobuster dns -d target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -t 50

# Vhost mode
gobuster vhost -u https://target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# With status code filtering
gobuster dir -u https://target.com -w wordlist.txt -s 200,301,302,403

# With proxy
gobuster dir -u https://target.com -w wordlist.txt -p http://127.0.0.1:8080
```

### feroxbuster

```bash
# Basic directory discovery
feroxbuster -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/common.txt

# Recursive with depth
feroxbuster -u https://target.com -w wordlist.txt -d 3 --extract-links

# With extensions
feroxbuster -u https://target.com -w wordlist.txt -x php html js

# Filter by size
feroxbuster -u https://target.com -w wordlist.txt --filter-size 4242

# Auto-calibrate filters
feroxbuster -u https://target.com -w wordlist.txt --auto-balance

# With proxy
feroxbuster -u https://target.com -w wordlist.txt --proxy http://127.0.0.1:8080

# Save output
feroxbuster -u https://target.com -w wordlist.txt -o results.txt
```

### dirsearch

```bash
# Basic directory search
dirsearch -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/common.txt

# With extensions
dirsearch -u https://target.com -e php,html,js,txt

# Recursive search
dirsearch -u https://target.com -r -R 3

# Exclude status codes
dirsearch -u https://target.com --exclude-status 404,403

# With wordlist
dirsearch -u https://target.com -w wordlist.txt

# Output format
dirsearch -u https://target.com -o results.json --format json
```

### dirb

```bash
# Basic directory scan
dirb https://target.com /usr/share/wordlists/dirb/common.txt

# With extensions
dirb https://target.com /usr/share/wordlists/dirb/common.txt -Z .php

# Recursive scan
dirb https://target.com /usr/share/wordlists/dirb/common.txt -r

# Force scan even if target is down
dirb https://target.com /usr/share/wordlists/dirb/common.txt -f
```

### Custom Scripting

```bash
# Python directory brute-forcer
python3 -c "
import requests
wordlist = open('wordlist.txt').read().splitlines()
for word in wordlist:
    r = requests.get(f'https://target.com/{word}')
    if r.status_code != 404:
        print(f'{r.status_code} - /{word} - {len(r.content)} bytes')
"

# Bash one-liner
while read word; do code=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com/$word"); [ "$code" != "404" ] && echo "$code - /$word"; done < wordlist.txt
```

## Real-World Case Studies

### Case Study 1: CMS Admin Panel Discovery

During a penetration test of a WordPress site, directory brute-forcing revealed a hidden admin panel at `/wp-admin-old/`. The panel was a backup of the WordPress admin interface from a previous version that had not been properly removed. The panel contained the same functionality as the current admin but lacked security patches applied to the main installation. Exploitation was straightforward using known WordPress vulnerabilities against the outdated admin panel. The root cause was a migration process that backed up the entire wp-admin directory but failed to delete it after migration completion.

### Case Study 2: Configuration File Exposure

A directory brute-forcing campaign against an Apache web server discovered `.env` files containing database credentials, API keys, and AWS secrets. The files were located at `/app/.env`, `/config/.env`, and `/backup/.env`. The backup directory contained a copy of the entire application from a deployment process that had directory listing disabled but not file access restrictions. The credentials provided access to the production database and AWS S3 buckets. The impact was critical as it enabled full database access and cloud resource compromise.

### Case Study 3: Virtual Host Internal Application

Virtual host enumeration on a shared hosting environment discovered an internal application accessible only through the Host header `internal.target.com`. The application was a management interface for the hosting platform itself, accessible without authentication from the same IP. The application provided access to all hosted accounts, server configurations, and backup files. This finding demonstrated how virtual host misconfigurations can expose internal management interfaces to external attackers.

### Case Study 4: Directory Traversal via Wildcard Bypass

A target website displayed a custom 404 page for all non-existent paths (wildcard response). By analyzing the response, I discovered that the wildcard response had exactly 4242 bytes while real pages had varying sizes. Filtering by size `-fs 4242` revealed 47 hidden directories and files. Among them was a `/debug/` endpoint that exposed server information and a `/backup/` directory containing compressed source code archives. The wildcard bypass technique is essential when testing modern applications that use custom error handling.

### Case Study 5: Rate Limit Bypass Through Distributed Brute-Forcing

A target implemented rate limiting after 100 requests per minute from a single IP. The rate limiting was IP-based without considering distributed requests. By using a botnet of compromised servers across different IP addresses, the brute-forcing was distributed to avoid triggering rate limits. Each IP sent fewer than 100 requests per minute while the aggregate discovered content at full speed. This highlighted the importance of implementing request rate limiting at the application level, not just the network level.

## Advanced Techniques and Bypass

### Recursive Wordlist Generation

Generate custom wordlists from application content rather than using generic lists. Extract words from JavaScript files, HTML content, and API responses. Use tools like `cewl` to crawl the website and generate wordlists based on content.

```bash
# Generate wordlist from website content
cewl -d 2 -m 5 -w custom_wordlist.txt https://target.com

# Extract words from JavaScript files
cat js/*.js | grep -oE '[a-zA-Z]+' | sort -u > js_words.txt

# Combine wordlists
cat common.txt custom_wordlist.txt js_words.txt | sort -u > combined.txt
```

### Encoder-Based Bypass

Some web applications block common directory names but not their encoded equivalents. URL encoding, double encoding, and Unicode normalization can bypass filters.

```bash
# URL encoding bypass
ffuf -u https://target.com/FUZZ -w wordlist.txt -e %2e,%2f,%5c

# Double encoding
ffuf -u https://target.com/FUZZ -w wordlist.txt -e %252e,%252f,%255c

# Unicode normalization
ffuf -u https://target.com/FUZZ -w wordlist.txt -e %c0%ae,%c1%9c
```

### HTTP Method Variation

Different HTTP methods may return different results. A path that returns 403 for GET might return 200 for POST or PUT.

```bash
# Test with different HTTP methods
for method in GET POST PUT DELETE OPTIONS PATCH; do
    ffuf -u https://target.com/admin -X $method -w /dev/null -mc all -o ${method}.json
done
```

### Case Sensitivity Bypass

Some web servers are case-sensitive while others are not. Testing both cases can reveal hidden content.

```bash
# Generate case variations
cat wordlist.txt | sed 's/.*/\L&/' > lowercase.txt
cat wordlist.txt | sed 's/.*/\U&/' > uppercase.txt
cat wordlist.txt | sed 's/.*/\u&/' > capitalized.txt
```

### Parameter Discovery

Beyond directory discovery, brute-force parameters that may reveal hidden functionality.

```bash
# Parameter discovery
ffuf -u https://target.com/page -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc 200

# Parameter value fuzzing
ffuf -u https://target.com/page?id=FUZZ -w numbers.txt -mc 200
```

### API Endpoint Discovery

Modern applications often have API endpoints that are not referenced in the frontend. Discovering these endpoints requires API-specific wordlists.

```bash
# API endpoint discovery
ffuf -u https://target.com/api/FUZZ -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt

# REST API path discovery
ffuf -u https://target.com/api/v1/FUZZ -w /usr/share/seclists/Discovery/Web-Content/api/paths.txt
```

## Detection and Indicators

### Signs of Directory Brute-Forcing

Monitor for the following indicators during testing:

- Increased server load or response time degradation
- WAF alerts for high request volumes
- IP blocking or CAPTCHA challenges
- Log entries showing repeated requests for non-existent paths
- Security team engagement or incident response activity

### Server-Side Detection Methods

Web servers can detect directory brute-forcing through:

- Request rate monitoring and threshold alerts
- Pattern recognition for sequential or alphabetical path requests
- User-agent analysis for known scanning tools
- Honeypot directories designed to detect automated scanning
- Log analysis for access patterns indicating enumeration

### Evasion Techniques

To avoid detection during authorized testing:

- Randomize request order rather than sequential enumeration
- Use multiple source IP addresses
- Implement delays between requests matching human browsing patterns
- Rotate user agents to appear as different browsers
- Use proxy chains to obscure the source of requests

## Impact Assessment

### Finding Severity Classification

Directory brute-forcing findings should be classified based on the content discovered:

- **Critical**: Administrative interfaces, database backups, source code archives, credentials
- **High**: Configuration files, environment files, debug endpoints, internal APIs
- **Medium**: Log files, temporary files, development endpoints, version control directories
- **Low**: Information disclosure through error pages, publicly accessible documentation
- **Informational**: Directory listings without sensitive content, default pages

### Business Impact Analysis

Consider the business context when assessing impact:

- A development endpoint in production may indicate inadequate deployment processes
- Backup files may contain sensitive data subject to regulatory requirements
- Administrative interfaces may provide access to customer data
- Source code exposure may reveal proprietary algorithms or business logic

## Common Pitfalls

### Over-Reliance on Status Codes

Many testers only look for 200 status codes, missing 301, 302, 403, and 500 responses that may indicate hidden content. A 403 Forbidden response often indicates a real resource that is access-restricted, which is valuable information for further testing.

### Ignoring Response Content

Status codes without content analysis leads to false positives. Custom error pages returning 200 for all paths create noise that obscures real findings. Always compare response sizes and content hashes against established baselines.

### Using Generic Wordlists

Generic wordlists waste time on irrelevant paths. A Node.js application should not be tested with PHP-specific paths, and a REST API requires different wordlists than a traditional web application. Technology-specific wordlists based on fingerprinting results are essential for efficiency.

### Not Testing Different HTTP Methods

A path returning 403 for GET may return 200 for POST. Testing all HTTP methods on discovered paths can reveal additional functionality. Some applications use different methods for different operations.

### Overlooking Query Parameters

Directory brute-forcing often focuses on path enumeration while ignoring query parameters. Parameters like `?page=`, `?file=`, and `?action=` can reveal hidden functionality when fuzzed with appropriate values.

### Forgetting to Test Root Directory

Some testers start brute-forcing from subdirectories without testing the root. Important files like `robots.txt`, `sitemap.xml`, `.env`, and `config.php` are at the root level.

### Not Adapting to Rate Limiting

When rate limiting is encountered, many testers give up rather than adapting. Implementing delays, using distributed sources, and targeting specific directories rather than the entire application can maintain testing efficiency while respecting rate limits.

## Integration with Other Recon Areas

Directory brute-forcing integrates with and enhances other reconnaissance activities:

- **Technology Fingerprinting**: Use identified technologies to select appropriate wordlists
- **JavaScript Analysis**: Extract paths and endpoints from JavaScript for custom wordlists
- **API Endpoint Discovery**: Combine directory brute-forcing with API enumeration for complete coverage
- **Configuration File Extraction**: Discover configuration files that may contain credentials or architecture information
- **Source Code Leak Detection**: Find exposed source code through backup files and development endpoints
- **Version Detection**: Identify software versions through files like `CHANGELOG.md`, `VERSION`, and `README.md`

The output of directory brute-forcing feeds into subsequent reconnaissance phases. Discovered endpoints become targets for vulnerability assessment. Found files provide intelligence for social engineering attacks. Exposed configuration files reveal the complete technology stack for targeted exploitation.

## Reporting Template

### Directory Brute-Forcing Report

**Executive Summary**: Overview of the directory brute-forcing activity, methodology used, and key findings.

**Methodology**: Description of wordlists used, tools employed, filters applied, and duration of testing.

**Findings Summary**:
- Total paths tested
- Total positive responses identified
- Breakdown by severity (Critical, High, Medium, Low, Informational)
- Notable discoveries

**Critical/High Findings**:
For each finding:
- Path discovered
- HTTP status code
- Response size
- Content type
- Access requirements
- Potential impact
- Recommended remediation

**Recommendations**:
- Remove or restrict access to discovered sensitive files
- Implement proper access controls for administrative paths
- Disable directory listings
- Remove backup files from production environments
- Implement Web Application Firewall rules for path traversal attempts

## Practice Labs

### Lab 1: Basic Directory Discovery

Set up a target with hidden directories and practice basic enumeration using common wordlists. Focus on establishing response baselines and filtering results.

### Lab 2: Wildcard Detection and Bypass

Create a target with wildcard responses and practice detecting and bypassing them. Identify the subtle differences between wildcard responses and real content.

### Lab 3: Recursive Discovery

Practice recursive directory discovery on a target with nested directories. Track the depth of discovery and identify how deep the application structure goes.

### Lab 4: Virtual Host Enumeration

Practice virtual host discovery on a target with multiple virtual hosts. Identify internal applications and management interfaces.

### Lab 5: Rate Limit Bypass

Practice bypassing rate limiting through distributed requests, delays, and user-agent rotation. Develop strategies for maintaining testing efficiency while respecting rate limits.

### Lab 6: Custom Wordlist Creation

Create custom wordlists based on application content, technology stack, and naming conventions. Compare the effectiveness of custom wordlists against generic lists.

## Ethical Guidelines

### Authorization Requirements

Always obtain explicit written authorization before performing directory brute-forcing. The reconnaissance techniques described in this document should only be used in authorized penetration testing, security assessments, or bug bounty programs within scope.

### Impact Minimization

- Use rate limiting to avoid denial-of-service conditions
- Avoid accessing or downloading sensitive data unless necessary for the assessment
- Report all discovered vulnerabilities through responsible disclosure channels
- Do not modify, delete, or corrupt any data during testing
- Respect robots.txt directives as a matter of professional courtesy

### Scope Limitation

Stay within the defined scope of the engagement. Directory brute-forcing should only be performed against authorized targets. Discovering content on third-party systems or shared hosting environments requires separate authorization.

### Documentation

Maintain detailed records of all testing activities including:
- Timestamps of all requests
- Tools and configurations used
- Findings discovered
- Remediation recommendations

## Quick Reference Cheat Sheet

### ffuf Quick Commands
```bash
ffuf -u https://target.com/FUZZ -w wordlist.txt                    # Basic
ffuf -u https://target.com/FUZZ -w wordlist.txt -mc 200,301,302    # Filter codes
ffuf -u https://target.com/FUZZ -w wordlist.txt -fs 4242           # Filter size
ffuf -u https://target.com/FUZZ -w wordlist.txt -e .php,.bak      # Extensions
ffuf -u https://target.com/FUZZ -w wordlist.txt -recursion         # Recursive
ffuf -u https://target.com -H "Host: FUZZ.target.com" -w subs.txt # Vhosts
```

### gobuster Quick Commands
```bash
gobuster dir -u https://target.com -w wordlist.txt -t 50           # Basic
gobuster dir -u https://target.com -w wordlist.txt -x php,html     # Extensions
gobuster dns -d target.com -w wordlist.txt -t 50                   # DNS
gobuster vhost -u https://target.com -w wordlist.txt               # Vhosts
```

### feroxbuster Quick Commands
```bash
feroxbuster -u https://target.com -w wordlist.txt                  # Basic
feroxbuster -u https://target.com -w wordlist.txt -d 3             # Recursive
feroxbuster -u https://target.com -w wordlist.txt -x php html      # Extensions
feroxbuster -u https://target.com -w wordlist.txt --auto-balance   # Auto-filter
```

### Response Filters
```bash
-mc 200,301,302    # Match status codes
-fs 4242           # Filter by size
-fw 100            # Filter by words
-fl 20             # Filter by lines
-fc 404            # Exclude status codes
```

### Wordlist Locations
```bash
/usr/share/seclists/Discovery/Web-Content/common.txt
/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt
/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt
/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt
/usr/share/wordlists/dirb/common.txt
/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```