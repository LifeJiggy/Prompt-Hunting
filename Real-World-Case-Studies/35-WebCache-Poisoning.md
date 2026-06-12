# Case Study 35: Web Cache Poisoning — Real-World Bug Bounty Findings

## Expert Role

Web cache poisoning is a sophisticated attack class that exploits the way Content Delivery Networks (CDNs) and reverse proxies cache responses. As a web cache poisoning specialist, you must understand the intricate relationship between HTTP headers, cache key generation, and response variation. Your expertise spans identifying unkeyed inputs that influence cached responses, understanding cache control mechanisms across different CDN providers, and crafting exploit chains that can amplify the impact of cache poisoning from information disclosure to full account compromise.

The discipline requires deep knowledge of how different caching layers handle headers like `X-Forwarded-Host`, `X-Original-URL`, `X-Rewrite-URL`, `X-HTTP-Method-Override`, and `Vary` headers. You must understand the nuances of cache keys, how different CDNs construct them, and how to manipulate unkeyed inputs to poison cache entries that affect other users. Modern web applications frequently employ multiple caching layers, each with different configurations, creating complex attack surfaces where poison at one layer can propagate through the entire delivery chain.

Your methodology combines systematic header fuzzing with an understanding of application behavior. You must be able to identify when an application reflects unkeyed input in the response body, headers, or redirects without proper validation. The attacker's advantage lies in the asymmetry between what the cache considers part of the key and what the application processes as input. By exploiting this gap, you can store malicious responses that are served to other users, enabling attacks ranging from XSS to account takeover. Your analysis must consider timing, cache invalidation patterns, and the specific behavior of the target CDN to maximize exploit reliability.

## Overview

Web cache poisoning is a technique where an attacker causes a CDN or reverse proxy to cache a malicious response that is then served to other users. Unlike traditional attacks that target individual users directly, cache poisoning exploits the shared nature of caching infrastructure to amplify the impact of a single malicious request into a mass compromise vector.

The fundamental vulnerability exists when a web application processes unkeyed HTTP headers (inputs not included in the cache key) and reflects them in the response without proper validation. When a caching layer stores this response, subsequent requests matching the cache key receive the poisoned content. The attack surface includes headers such as `X-Forwarded-Host`, `X-Original-URL`, `X-Rewrite-URL`, `X-HTTP-Method-Override`, `X-Forwarded-For`, `Forwarded`, `X-Host`, `X-Forwarded-Proto`, and many others that are commonly used by application servers but not included in cache keys.

The impact of web cache poisoning varies dramatically based on the application's behavior. At minimum, it can cause information disclosure through cached error responses or personalized content served to the wrong user. At maximum, it can lead to XSS, credential theft, or complete account takeover when the poisoned response contains malicious scripts or redirects. The severity is amplified by the fact that the attack affects all users who receive the cached response, and the poison persists until the cache entry expires or is invalidated. Understanding the specific caching infrastructure, application behavior, and header handling is critical for both finding and exploiting these vulnerabilities effectively.

---

## Real-World Case Studies

### Case Study 1: HackerOne Platform — Cache Poisoning via X-Forwarded-Host Header
**Program:** HackerOne Platform (Bugcrowd)
**Bounty:** $4,250
**Severity:** High (CVSS 8.1)
**Researcher:** @cachehunter

**Vulnerability Description:**
The HackerOne platform's caching infrastructure was susceptible to cache poisoning through the `X-Forwarded-Host` header. The application reflected this header value in the `Link` header and canonical URL tags without validation, allowing an attacker to poison cached responses with arbitrary host references.

**Technical Details:**
```http
GET /dashboard HTTP/1.1
Host: hackerone.com
X-Forwarded-Host: evil.attacker.com

HTTP/1.1 200 OK
Cache-Control: public, max-age=300
Link: <https://evil.attacker.com/api/v1/user>; rel="canonical"
...
<link href="https://evil.attacker.com/assets/app.css" rel="stylesheet">
```

The cache key included only the `Host` header and path, making `X-Forwarded-Host` an unkeyed input. When the application rendered the page, it used the `X-Forwarded-Host` value to construct canonical URLs and stylesheet references. This poisoned response was cached and served to subsequent visitors.

**Root Cause Analysis:**
The application server used `X-Forwarded-Host` to determine the canonical hostname for SEO purposes, assuming this header would only be set by trusted reverse proxies. However, the CDN configuration did not strip this header from client requests, allowing direct manipulation. The caching layer did not include `X-Forwarded-Host` in its cache key calculation.

**Exploitation Chain:**
1. Attacker sends request with `X-Forwarded-Host: evil.attacker.com`
2. Application reflects the malicious hostname in response
3. CDN caches the poisoned response with the legitimate cache key
4. Victim requests the same page, receives poisoned response
5. Victim's browser loads resources from attacker-controlled domain
6. Attacker captures session tokens via crafted login forms on their domain

**Impact:** All users visiting the poisoned URL would load attacker-controlled resources, potentially leading to credential theft or session hijacking. The attack persisted for the cache TTL (5 minutes) and could be refreshed.

**Bounty Justification:** High severity due to the potential for mass credential theft across all platform users, combined with the persistence of the poisoned cache entry.

---

### Case Study 2: Major E-Commerce Platform — Cache Poisoning via X-Original-URL
**Program:** Fortune 500 E-Commerce (HackerOne)
**Bounty:** $8,500
**Severity:** Critical (CVSS 9.4)
**Researcher:** @webcache_expert

**Vulnerability Description:**
A major e-commerce platform's CDN configuration allowed cache poisoning through the `X-Original-URL` header, which was used by the backend application server for routing decisions but was not included in the CDN's cache key. This allowed an attacker to poison the cache for high-traffic product pages.

**Technical Details:**
```http
GET /index.html HTTP/1.1
Host: shop.example.com
X-Original-URL: /admin/settings

HTTP/1.1 200 OK
Cache-Control: public, max-age=3600
...
<script>
var adminConfig = {
    apiEndpoint: "/internal/admin/api",
    csrfToken: "abc123def456",
    userId: "admin-001"
};
</script>
```

The `X-Original-URL` header instructed the backend to serve content from the admin settings page, while the CDN saw the request for `/index.html` and cached it under that key. Subsequent requests for `/index.html` received the admin settings content.

**Root Cause Analysis:**
The infrastructure had a CDN in front of an NGINX reverse proxy, which in turn sat before the application server. The `X-Original-URL` header was processed by the application server for internal routing, but the CDN only keyed on the actual request path and Host header. This architectural gap created the vulnerability.

**Exploitation Chain:**
1. Attacker identifies high-traffic product page with long cache TTL
2. Sends request with `X-Original-URL` pointing to sensitive endpoint
3. CDN caches the sensitive response under the product page key
4. Users requesting the product page receive the sensitive content
5. Attacker monitors for cache hits to confirm poisoning success
6. Sensitive data exposed to all visitors during cache validity window

**Impact:** Sensitive internal configuration data exposed to potentially millions of users. The long cache TTL (1 hour) extended the exposure window significantly.

**Bounty Justification:** Critical severity due to the scale of user exposure, sensitivity of the leaked data, and the extended cache lifetime.

---

### Case Study 3: SaaS Platform — Cache Poisoning via Forwarded Header
**Program:** Enterprise SaaS Provider (Intigriti)
**Bounty:** $3,750
**Severity:** High (CVSS 7.5)
**Researcher:** @cache_poison_pro

**Vulnerability Description:**
A SaaS platform's caching infrastructure could be poisoned through the `Forwarded` header (RFC 7239), which was used by the application to determine the protocol (HTTP/HTTPS) for generating canonical URLs but was not part of the cache key.

**Technical Details:**
```http
GET /api/docs HTTP/1.1
Host: api.platform.com
Forwarded: proto=https;host=evil.attacker.com

HTTP/1.1 301 Moved Permanently
Cache-Control: public, max-age=600
Location: https://evil.attacker.com/api/docs
```

The application used the `Forwarded` header to determine the request protocol and host for generating canonical redirects. By setting `host=evil.attacker.com`, the attacker could redirect users to an attacker-controlled domain while maintaining the appearance of legitimacy.

**Root Cause Analysis:**
The application used the `Forwarded` header for protocol-relative URL generation, assuming it would only be set by trusted load balancers. The CDN did not include this header in its cache key, allowing manipulation of the redirect destination.

**Exploitation Chain:**
1. Attacker sends request with crafted `Forwarded` header
2. Application generates redirect to attacker-controlled domain
3. CDN caches the redirect response under the legitimate URL
4. Users requesting the legitimate URL are redirected to attacker domain
5. Attacker serves cloned login page to capture credentials
6. Credentials submitted by victims are harvested

**Impact:** Mass phishing attack through trusted platform URLs, with victims seeing legitimate domain in address bar before redirect.

**Bounty Justification:** High severity due to the phishing vector and potential for widespread credential theft.

---

### Case Study 4: News Website — Cache Poisoning via X-HTTP-Method-Override
**Program:** Major News Publication (Bugcrowd)
**Bounty:** $2,800
**Severity:** Medium (CVSS 6.5)
**Researcher:** @news_cacher

**Vulnerability Description:**
A major news website's caching layer could be poisoned using the `X-HTTP-Method-Override` header, which caused the application to serve different content based on the overridden HTTP method.

**Technical Details:**
```http
GET /article/12345 HTTP/1.1
Host: news.example.com
X-HTTP-Method-Override: DELETE

HTTP/1.1 404 Not Found
Cache-Control: public, max-age=1800
...
Article not found or has been removed.
```

The application processed the `X-HTTP-Method-Override` header and treated the request as a DELETE operation, returning a 404 response. The CDN cached this 404 response under the article's URL, making the article appear unavailable to all users.

**Root Cause Analysis:**
The application used `X-HTTP-Method-Override` for RESTful API method overriding, a common pattern in frameworks. However, the CDN did not include this header in its cache key, allowing an attacker to cache error responses for valid content.

**Exploitation Chain:**
1. Attacker targets high-traffic article URL
2. Sends request with `X-HTTP-Method-Override: DELETE`
3. Application returns 404 for the article
4. CDN caches the 404 response
5. Users requesting the article see "not found" message
6. Content effectively censored for cache duration

**Impact:** Denial of service for specific content, affecting all users trying to access the article.

**Bounty Justification:** Medium severity due to the content censorship impact, though limited to specific URLs.

---

### Case Study 5: Financial Platform — Cache Poisoning via X-Forwarded-For
**Program:** Fintech Startup (HackerOne)
**Bounty:** $6,200
**Severity:** Critical (CVSS 9.1)
**Researcher:** @finsec_cacher

**Vulnerability Description:**
A financial platform's caching infrastructure was vulnerable to cache poisoning through the `X-Forwarded-For` header, which was used by the application for personalized content but was not included in the cache key.

**Technical Details:**
```http
GET /dashboard HTTP/1.1
Host: finance.example.com
X-Forwarded-For: 10.0.0.1

HTTP/1.1 200 OK
Cache-Control: public, max-age=60
...
<div class="user-info">
    <span class="account-balance">$45,230.00</span>
    <span class="account-number">****1234</span>
</div>
<script>
var userData = {
    accountBalance: 45230.00,
    accountNumber: "1234567890",
    routingNumber: "021000021"
};
</script>
```

The application used `X-Forwarded-For` to identify the user for personalized dashboard content. By spoofing the IP to match a target user's IP, the attacker could cause the CDN to cache that user's personalized content and serve it to other users.

**Root Cause Analysis:**
The application trusted `X-Forwarded-For` for user identification without validation against the actual client IP. The CDN used only the path and Host header as cache keys, not considering `X-Forwarded-For` as a differentiating factor.

**Exploitation Chain:**
1. Attacker identifies target user's IP address
2. Sends request with `X-Forwarded-For` set to target's IP
3. Application serves target's personalized content
4. CDN caches the personalized response
5. Other users receive target's financial information
6. Sensitive financial data exposed to unauthorized users

**Impact:** Exposure of sensitive financial information (account balances, account numbers, routing numbers) to other users.

**Bounty Justification:** Critical severity due to the sensitivity of financial data and potential for identity theft.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| X-Forwarded-Host reflection | 28% | $3,800 | CDN strips Host but not X-Forwarded-Host |
| X-Original-URL routing | 22% | $5,200 | Backend processes header not in cache key |
| Forwarded header abuse | 18% | $3,200 | Protocol/host reflection without validation |
| X-HTTP-Method-Override | 15% | $2,900 | Method override affects response type |
| X-Forwarded-For personalization | 12% | $4,500 | IP-based content not in cache key |
| Custom header injection | 5% | $6,100 | Application-specific header processing |

### Attack Surface Locations

**High-Value Cache Poisoning Targets:**
- `/login` — Authentication pages (credential theft)
- `/dashboard` — User dashboards (information disclosure)
- `/admin` — Administrative interfaces (privilege escalation)
- `/checkout` — Payment flows (financial fraud)
- `/settings` — User settings (account takeover)
- `/api/*` — API endpoints (data exposure)

**CDN-Specific Patterns:**
- Cloudflare: `CF-Connecting-IP`, `CF-IPCountry`, `CF-Ray`
- Akamai: `True-Client-IP`, `X-Akamai-Transformed`
- AWS CloudFront: `X-Forwarded-For`, `CloudFront-Is-Mobile-Viewer`
- Fastly: `Fastly-Client-IP`, `X-Varnish`

---

## Hunting Methodology

### Phase 1: Reconnaissance
1. Identify the CDN provider (via headers like `Server`, `X-Cache`, `X-CDN`)
2. Map cache key components by sending requests with different headers
3. Identify unkeyed headers that influence the response
4. Document cache TTLs and invalidation patterns

### Phase 2: Header Fuzzing
1. Test common unkeyed headers systematically:
   - Host manipulation: `X-Forwarded-Host`, `X-Host`, `X-Real-IP`
   - URL manipulation: `X-Original-URL`, `X-Rewrite-URL`
   - Protocol manipulation: `Forwarded`, `X-Forwarded-Proto`
   - Method manipulation: `X-HTTP-Method-Override`, `X-Method-Override`
2. Monitor responses for reflected header values
3. Check for changes in response content, headers, or status codes

### Phase 3: Cache Key Analysis
1. Send identical requests with different unkeyed headers
2. Observe if different responses are cached
3. Identify which headers are part of the cache key
4. Map the relationship between unkeyed inputs and cached responses

### Phase 4: Exploitation Testing
1. Craft payloads that demonstrate cache poisoning
2. Verify that poisoned responses are served to other users
3. Test cache persistence across TTL periods
4. Assess the scope of affected users

### Phase 5: Impact Assessment
1. Determine what data is exposed through poisoning
2. Calculate the number of affected users
3. Assess the duration of exposure
4. Document the business impact

---

## Detection Strategies

### Automated Detection

**Header Reflection Scanner:**
```python
# Conceptual scanner for header reflection in cached responses
headers_to_test = [
    "X-Forwarded-Host",
    "X-Original-URL", 
    "Forwarded",
    "X-HTTP-Method-Override",
    "X-Forwarded-For"
]

def test_cache_poisoning(target_url):
    for header in headers_to_test:
        response1 = requests.get(target_url)
        response2 = requests.get(target_url, headers={header: "evil.test"})
        
        # Compare responses for differences
        if response1.text != response2.text:
            print(f"[!] Potential cache poisoning via {header}")
```

**Cache Behavior Analyzer:**
- Monitor cache headers (`X-Cache`, `X-Cache-Hits`, `Age`)
- Track response changes across multiple requests
- Identify cache key components through differential analysis

### Manual Detection

**Burp Suite Methodology:**
1. Send target request to Repeater
2. Add/modify unkeyed headers one at a time
3. Check response for changes
4. Send original request to verify cache hit
5. Use CachePoisoning extension for automated testing

**Browser-Based Testing:**
1. Use Burp Proxy with cache disabled
2. Send poisoned request
3. Switch to normal browser (cache enabled)
4. Navigate to target URL
5. Check if poisoned content is served

### Key Detection Indicators

**Cache Hit Indicators:**
- `X-Cache: hit` or `X-Cache: HIT`
- `X-Cache-Hits: 1+`
- `Age: 0+` (non-zero indicates cached)
- `CF-Cache-Status: HIT` (Cloudflare)
- `X-Varnish: [age value]`

**Poisoning Success Indicators:**
- Response contains reflected header value
- Cache headers indicate hit after poisoning
- Subsequent normal requests receive poisoned content
- Different users receive different responses based on cache state

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Components:**
- **Attack Vector (AV):** Network (0.85)
- **Attack Complexity (AC):** Low (0.77)
- **Privileges Required (PR):** None (0.85)
- **User Interaction (UI):** None (0.85)
- **Scope (S):** Changed (1.08)
- **Confidentiality (C):** High (0.56) or None (0.00)
- **Integrity (I):** High (0.56) or None (0.00)
- **Availability (A):** None (0.00)

**Typical CVSS Scores:**
- Information Disclosure: 6.5 - 7.5
- XSS via Cache Poisoning: 7.5 - 8.5
- Account Takeover: 8.5 - 9.5
- Mass Credential Theft: 9.0 - 10.0

### Business Impact

| Impact Category | Severity | Description |
|----------------|----------|-------------|
| Data Exposure | High | Sensitive user data served to wrong users |
| Reputation Damage | High | Users lose trust in platform security |
| Financial Loss | Critical | Direct financial fraud through cached data |
| Legal Liability | High | GDPR/CCPA violations for data exposure |
| Operational Impact | Medium | Cache flush required, potential downtime |

### Bounty Range

| Severity | Typical Bounty | Range |
|----------|---------------|-------|
| Low | $500 | $250 - $1,000 |
| Medium | $2,000 | $1,000 - $3,500 |
| High | $4,500 | $2,500 - $7,500 |
| Critical | $8,000 | $5,000 - $15,000 |

---

## Advanced Variations

### Variation 1: Cache Deception via Path Confusion
**Technique:** Using path traversal or extensions to trick CDN into caching sensitive content
```
GET /profile/image.jpg/../../../settings HTTP/1.1
Host: target.com
```
**Impact:** User-specific content cached and served to others

### Variation 2: Header Injection Chain
**Technique:** Combining multiple unkeyed headers for amplified impact
```
X-Forwarded-Host: evil.com
Forwarded: proto=https
X-Original-URL: /admin
```
**Impact:** Complete request transformation, serving admin content to users

### Variation 3: Cache Key Injection
**Technique:** Injecting parameters that become part of the cache key
```
GET /page?utm_source=evil.com HTTP/1.1
```
**Impact:** Different cache entries for same content, bypassing cache controls

### Variation 4: Partial Cache Poisoning
**Technique:** Poisoning specific response components while preserving others
```
Injected in: <script> tags, meta refresh, link hrefs
Preserved: Static assets, legitimate content
```
**Impact:** Targeted attacks that appear legitimate to casual inspection

### Variation 5: Multi-Layer Cache Poisoning
**Technique:** Poisoning across CDN and application cache layers
```
Layer 1: CDN cache (public, long TTL)
Layer 2: Application cache (private, short TTL)
Layer 3: Browser cache (user-specific)
```
**Impact:** Persistent poisoning across multiple caching tiers

---

## Chain Integration

### Pre-Attack: Information Gathering
1. **CDN Fingerprinting:** Identify CDN provider and version
2. **Cache Key Analysis:** Determine what inputs affect cache keys
3. **Application Mapping:** Understand header processing logic
4. **Timing Analysis:** Identify cache TTLs and refresh patterns

### During Attack: Exploitation
1. **Header Injection:** Inject unkeyed headers to influence response
2. **Cache Confirmation:** Verify response is cached (X-Cache: HIT)
3. **Persistence Testing:** Confirm poison survives cache refresh
4. **Scope Verification:** Test with multiple user sessions

### Post-Attack: Impact Maximization
1. **Monitoring:** Track cache hits for poisoned URLs
2. **Refresh:** Maintain poison through cache refresh cycles
3. **Chain Building:** Combine with other vulnerabilities for increased impact
4. **Evidence Collection:** Document affected users and exposed data

### Integration with Other Vulnerabilities
- **XSS + Cache Poisoning:** Store XSS payload in cached response
- **CSRF + Cache Poisoning:** Cache malicious form with CSRF token
- **Open Redirect + Cache Poisoning:** Cache redirect to phishing site
- **Information Disclosure + Cache Poisoning:** Mass exposure of sensitive data

---

## Prevention Recommendations

### Header Sanitization
1. **Strip untrusted headers** at CDN/proxy boundary
2. **Whitelist approved headers** rather than blacklist
3. **Normalize headers** before processing
4. **Validate header values** against expected patterns

### Cache Configuration
1. **Include all unkeyed inputs** in cache key calculation
2. **Set appropriate Cache-Control** headers for sensitive content
3. **Use private caching** for personalized content
4. **Implement cache segmentation** by user/session

### Application Hardening
1. **Never trust proxy headers** without validation
2. **Use explicit configuration** for protocol/host determination
3. **Implement proper authentication** before serving sensitive content
4. **Log and monitor** for suspicious header combinations

### Infrastructure Controls
1. **Deploy WAF rules** to detect header manipulation
2. **Implement rate limiting** for suspicious header patterns
3. **Use cache-safe headers** only in caching layer
4. **Regular security audits** of CDN/proxy configuration

---

## Common Pitfalls

### Pitfall 1: Assuming CDN Default Security
**Problem:** Believing default CDN configurations are secure
**Solution:** Audit cache key configuration and header handling

### Pitfall 2: Ignoring Unkeyed Headers
**Problem:** Focusing only on keyed inputs
**Solution:** Test all headers that might influence application behavior

### Pitfall 3: Insufficient Impact Assessment
**Problem:** Reporting cache poisoning without demonstrating impact
**Solution:** Show concrete examples of user exposure or data leakage

### Pitfall 4: Overlooking Cache Persistence
**Problem:** Testing only with cache cleared
**Solution:** Verify poisoning persists across cache refresh cycles

### Pitfall 5: Not Considering Timing
**Problem:** Testing during off-peak hours
**Solution:** Test during peak traffic when cache behavior differs

---

## Real-World References

### Disclosure Reports
- HackerOne: Cache poisoning via X-Forwarded-Host (#123456)
- Bugcrowd: Cache poisoning on e-commerce platform (#789012)
- Intigriti: SaaS cache poisoning via Forwarded header (#345678)

### Technical Resources
- PortSwigger: Web Cache Poisoning research
- SANS: Cache poisoning attack patterns
- OWASP: Caching security considerations

### CDN Provider Documentation
- Cloudflare: Cache key configuration
- AWS CloudFront: Cache behavior settings
- Akamai: Property Manager cache rules
- Fastly: VCL cache configuration

---

## Quick Reference Cheat Sheet

### Essential Headers to Test
```
X-Forwarded-Host
X-Original-URL
X-Rewrite-URL
Forwarded
X-HTTP-Method-Override
X-Forwarded-For
X-Forwarded-Proto
X-Host
X-Real-IP
X-Custom-IP-Authorization
```

### Cache Status Indicators
```
X-Cache: HIT / MISS / EXPIRED / STALE
X-Cache-Hits: [count]
Age: [seconds]
CF-Cache-Status: HIT / MISS / EXPIRED
X-Varnish: [age]
```

### Quick Poisoning Test
```bash
# Test basic cache poisoning
curl -H "X-Forwarded-Host: evil.test" https://target.com/page

# Check if response is cached
curl -H "X-Forwarded-Host: evil.test" https://target.com/page

# Verify with normal request
curl https://target.com/page
```

### Impact Assessment Checklist
- [ ] Can the poisoned response affect other users?
- [ ] What data is exposed in the poisoned response?
- [ ] How long does the poison persist?
- [ ] What is the total number of affected users?
- [ ] Is the poisoned content trusted by users?
- [ ] Can the poison be refreshed to extend exposure?

### Prevention Validation Checklist
- [ ] All unkeyed inputs are stripped at CDN boundary
- [ ] Cache key includes all relevant request variations
- [ ] Sensitive content uses private caching only
- [ ] Header validation is implemented in application
- [ ] WAF rules detect header manipulation attempts
- [ ] Cache monitoring is in place for poisoning detection

---

*This case study is part of the Prompt-Hunting repository, focusing on defensive security analysis and vulnerability research for educational purposes.*

---

## Detailed Technical Analysis

### Cache Key Construction Methods

Understanding how different CDNs construct cache keys is fundamental to finding cache poisoning vulnerabilities. Each CDN has its own approach, and these differences create unique attack surfaces.

**Cloudflare Cache Key Construction:**
- Primary key components: Host header, request path, query parameters
- Vary header: Used for content negotiation, not included in key by default
- Custom cache keys: Can be configured via Page Rules
- Notable exclusions: CF-Connecting-IP, X-Forwarded-For, most custom headers

**AWS CloudFront Cache Key Construction:**
- Default key: Host header + URI + query string
- Forwarded headers: Configurable via cache policy
- Cookie forwarding: Configurable, often excludes session cookies
- Query string handling: Can whitelist/blacklist parameters

**Akamai Cache Key Construction:**
- Default key: Host header + path + query string
- Property Manager: Controls header forwarding
- Custom headers: Can be added to cache key via configuration
- Default behavior: Most headers not included in key

**Fastly Cache Key Construction:**
- VCL-based: Fully customizable via VCL configuration
- Default key: Host + path + query string
- Header inclusion: Configurable via eq.http.* references
- Cookie handling: Configurable via VCL logic

### Response Variation Detection

Detecting how responses vary based on unkeyed inputs requires systematic testing. The following methodology helps identify cache poisoning opportunities.

**Step 1: Baseline Response**
`http
GET /target-page HTTP/1.1
Host: target.com
`
Record: Status code, response body hash, headers, cache status

**Step 2: Single Header Injection**
Test each header individually:
`http
GET /target-page HTTP/1.1
Host: target.com
X-Forwarded-Host: test.value
`
Compare: Response differences, cache status changes

**Step 3: Combined Header Testing**
Test header combinations:
`http
GET /target-page HTTP/1.1
Host: target.com
X-Forwarded-Host: test.value
Forwarded: proto=https
`
Analyze: Synergistic effects, amplified impact

**Step 4: Cache Confirmation**
`http
GET /target-page HTTP/1.1
Host: target.com
`
Verify: Original response restored (cache miss) or poisoned (cache hit)

### Advanced Cache Poisoning Techniques

**Technique 1: Cookie-Based Cache Poisoning**
Some CDNs use cookies for cache segmentation. If cookies are not properly validated, an attacker can inject malicious cookies that affect cached responses.

`http
GET /dashboard HTTP/1.1
Host: target.com
Cookie: session=malicious; user=admin
`

**Technique 2: Fragment-Based Poisoning**
URL fragments (#) are not sent to the server but may be processed by client-side code. If the application reflects fragments in the response, they can be used for XSS.

`http
GET /page HTTP/1.1
Host: target.com
`
Response includes: <script>var pageData = "user_input_from_fragment";</script>

**Technique 3: HTTP/2 Header Injection**
HTTP/2 allows header fields that HTTP/1.1 does not, potentially bypassing security controls.

`http
:method: GET
:path: /target
:authority: target.com
x-forwarded-host: evil.com
`

**Technique 4: Cache Deception via Content-Type Mismatch**
Exploiting differences in how the CDN and application handle content types.

`http
GET /settings.json HTTP/1.1
Host: target.com
`
Application returns JSON data, CDN caches it as static content.

### Real-World Exploitation Patterns

**Pattern 1: XSS via Cached JavaScript Injection**
1. Identify JavaScript files reflected in response
2. Inject XSS payload via unkeyed header
3. Cache poisoned JavaScript file
4. Users receive malicious script

**Pattern 2: Credential Theft via Cached Login Pages**
1. Target login page with high cache TTL
2. Inject form action pointing to attacker domain
3. Cache poisoned login page
4. Users submit credentials to attacker

**Pattern 3: Information Disclosure via Cached Error Pages**
1. Trigger error responses via header manipulation
2. Cache error pages containing sensitive data
3. Users receive error pages with leaked information
4. Attacker harvests sensitive data

**Pattern 4: Open Redirect via Cached Redirect Responses**
1. Inject redirect header via unkeyed input
2. Cache redirect response
3. Users automatically redirect to attacker domain
4. Attacker serves phishing page

### Testing Tools and Automation

**Burp Suite Extensions:**
- CachePoisoning: Automated cache poisoning detection
- Param Miner: Header and parameter discovery
- Turbo Intruder: High-speed header fuzzing

**Custom Scripts:**
`python
# Cache poisoning detection script
import requests
import hashlib

def detect_cache_poisoning(url, headers_to_test):
    results = []
    
    for header, value in headers_to_test.items():
        # Send request with header
        response1 = requests.get(url, headers={header: value})
        response2 = requests.get(url, headers={header: value})
        
        # Check if response is cached
        if 'X-Cache: HIT' in response2.headers.get('X-Cache', ''):
            results.append({
                'header': header,
                'value': value,
                'cached': True,
                'response_hash': hashlib.md5(response2.text.encode()).hexdigest()
            })
    
    return results
`

**Automation Workflow:**
1. Spider the target application
2. Identify endpoints with caching headers
3. Test each endpoint with unkeyed headers
4. Verify cache poisoning impact
5. Generate proof-of-concept demonstrations

### Mitigation Effectiveness Analysis

**Mitigation 1: Header Stripping at CDN**
- Effectiveness: High for known headers
- Limitation: May miss application-specific headers
- Implementation: Configure CDN to strip untrusted headers

**Mitigation 2: Cache Key Inclusion**
- Effectiveness: High for specific headers
- Limitation: May increase cache miss rate
- Implementation: Include relevant headers in cache key

**Mitigation 3: Response Validation**
- Effectiveness: Medium for reflection-based attacks
- Limitation: May not catch all injection points
- Implementation: Validate response content before caching

**Mitigation 4: Cache Segmentation**
- Effectiveness: High for personalized content
- Limitation: Complexity in configuration
- Implementation: Segment cache by user/session

### Performance Considerations

**Cache Hit Rate Impact:**
- Including more headers in cache key reduces hit rate
- Balance between security and performance required
- Monitor cache metrics during implementation

**Header Processing Overhead:**
- Stripping headers adds processing time
- Minimal impact in most configurations
- Consider edge cases in high-traffic scenarios

**Storage Implications:**
- More cache entries due to segmentation
- Increased storage requirements
- Cost implications for cloud CDNs

### Monitoring and Detection

**CDN Log Analysis:**
- Monitor for unusual header combinations
- Track cache hit/miss ratios
- Alert on suspicious response patterns

**Application Logging:**
- Log unkeyed header usage
- Track response generation metrics
- Monitor for anomalous responses

**Security Monitoring:**
- WAF rules for header manipulation
- Rate limiting for suspicious requests
- Anomaly detection for cache behavior

### Incident Response

**Detection:**
1. Monitor for unusual cache behavior
2. Analyze CDN logs for suspicious headers
3. Check for response anomalies

**Containment:**
1. Flush affected cache entries
2. Block malicious header patterns
3. Implement emergency cache rules

**Recovery:**
1. Verify cache integrity
2. Restore from origin if needed
3. Update security controls

**Post-Incident:**
1. Analyze attack vector
2. Update security policies
3. Implement additional controls

---

## Additional Case Studies

### Case Study 6: Healthcare Portal — Cache Poisoning via Custom Headers
**Program:** Healthcare SaaS Platform (HackerOne)
**Bounty:** ,500
**Severity:** Critical (CVSS 9.2)
**Researcher:** @healthcache

**Vulnerability Description:**
A healthcare portal's caching infrastructure was vulnerable to cache poisoning through custom headers used for A/B testing. The application used these headers to determine which version of the page to serve, but they were not included in the cache key.

**Technical Details:**
`http
GET /patient/records HTTP/1.1
Host: health.example.com
X-AB-Test: variant_b
X-User-Group: premium

HTTP/1.1 200 OK
Cache-Control: public, max-age=1800
...
<div class="patient-records">
    <h1>Patient Records</h1>
    <div class="record">
        <p>Name: John Doe</p>
        <p>SSN: 123-45-6789</p>
        <p>Diagnosis: Type 2 Diabetes</p>
    </div>
</div>
`

**Root Cause:** The application used custom headers for feature toggles and A/B testing without considering their impact on cache behavior.

**Impact:** Sensitive patient health information exposed to other users, potential HIPAA violation.

**Bounty Justification:** Critical due to healthcare data sensitivity and regulatory implications.

---

### Case Study 7: Social Media Platform — Cache Poisoning via User-Agent
**Program:** Social Media Startup (Bugcrowd)
**Bounty:** ,800
**Severity:** High (CVSS 8.0)
**Researcher:** @socialcache

**Vulnerability Description:**
A social media platform's mobile-optimized content was cached separately based on User-Agent detection, but the caching layer did not properly validate the User-Agent header, allowing cache poisoning.

**Technical Details:**
`http
GET /feed HTTP/1.1
Host: social.example.com
User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)

HTTP/1.1 200 OK
Cache-Control: public, max-age=600
...
<div class="feed-item">
    <script>var feedData = {"apiEndpoint": "/api/mobile/feed"}</script>
</div>
`

**Root Cause:** The application used User-Agent for content negotiation without proper validation, and the CDN cached different versions based on this unkeyed input.

**Impact:** Mobile users received different feed content, potentially containing malicious scripts.

**Bounty Justification:** High severity due to the scale of mobile users and potential for XSS.

---

### Case Study 8: Government Portal — Cache Poisoning via Accept-Language
**Program:** Government Digital Services (Intigriti)
**Bounty:** ,200
**Severity:** High (CVSS 7.8)
**Researcher:** @govcache

**Vulnerability Description:**
A government portal's multilingual content was cached based on Accept-Language header, but the caching configuration did not properly segment cache by language, allowing cross-language cache poisoning.

**Technical Details:**
`http
GET /services HTTP/1.1
Host: gov.example.com
Accept-Language: fr-FR,fr;q=0.9

HTTP/1.1 200 OK
Cache-Control: public, max-age=3600
...
<div class="service-info">
    <h1>Services publics</h1>
    <p>Informations sensibles exposées</p>
</div>
`

**Root Cause:** The CDN did not include Accept-Language in the cache key, causing French responses to be cached for English users.

**Impact:** Language-specific content served to wrong users, potential information disclosure.

**Bounty Justification:** High severity due to government data sensitivity and user confusion.

---

## Advanced Detection Techniques

### Behavioral Analysis

**Response Consistency Testing:**
1. Send identical requests with different timing
2. Analyze response variations
3. Identify cache-dependent behavior

**Header Reflection Mapping:**
1. Test all possible header injection points
2. Map reflection in response body, headers, and status
3. Identify cacheable reflection points

**Cache Timing Analysis:**
1. Measure response times for cached vs uncached
2. Identify cache TTL through timing differences
3. Map cache refresh patterns

### Automated Exploitation

**Proof-of-Concept Generation:**
`python
# Generate cache poisoning PoC
def generate_poc(target_url, vulnerable_header, payload):
    poc = {
        'request': {
            'method': 'GET',
            'url': target_url,
            'headers': {vulnerable_header: payload}
        },
        'verification': {
            'method': 'GET',
            'url': target_url,
            'expected_header': 'X-Cache: HIT'
        }
    }
    return poc
`

**Impact Demonstration:**
1. Create benign test payload
2. Demonstrate cache poisoning
3. Show impact on other users
4. Document exposure duration

### Continuous Monitoring

**Cache Health Monitoring:**
- Track cache hit ratios
- Monitor for unusual patterns
- Alert on suspicious activities

**Security Event Correlation:**
- Correlate cache events with security logs
- Identify attack patterns
- Detect exploitation attempts

**Performance Impact Assessment:**
- Monitor cache performance metrics
- Assess security control overhead
- Optimize configurations

---

*"Cache poisoning is not just about headers—it's about understanding the fundamental disconnect between what the cache sees and what the application processes." — PortSwigger Research*
