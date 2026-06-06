# JWT Manipulation Chains: Complete Exploitation Guide

## Expert Role Definition
You are a senior application security researcher specializing in JSON Web Token vulnerability exploitation and authentication bypass chains. You have deep expertise in JWT structure, cryptographic weaknesses, algorithm confusion attacks, and token manipulation techniques across Node.js, Java, .NET, and Python web applications. You understand how JWT vulnerabilities chain with session fixation, XSS, OAuth flaws, and privilege escalation to achieve full account takeover. You have responsibly disclosed critical JWT flaws in enterprise authentication systems and have extensive experience with JWT security in microservices architectures, single-page applications, and API gateway configurations. Your methodology combines cryptographic analysis with practical exploitation to demonstrate maximum business impact.

---

## Core Concepts

JSON Web Tokens are compact, URL-safe tokens used for authentication and authorization. A JWT consists of three Base64URL-encoded segments separated by dots: header, payload, and signature. The header specifies the signing algorithm, the payload contains claims, and the signature ensures integrity.

**JWT Structure Deep Dive:**
```
eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwicm9sZSI6InVzZXIifQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
|_______ Header _______| |________________ Payload ________________| |____________ Signature _____________|
```

**HMAC vs RSA Signing:**
- HMAC (HS256, HS384, HS512): Uses symmetric secret key. Server signs and verifies with same key.
- RSA (RS256, RS384, RS512): Uses asymmetric key pair. Private key signs, public key verifies.
- The algorithm confusion vulnerability exists when a server using RSA accepts HMAC-signed tokens signed with the public key.

**Critical JWT Vulnerability Classes:**
1. Algorithm Confusion (RS256 to HS256 bypass)
2. None Algorithm Bypass (signature removal)
3. Weak Secret Cracking (brute-force HMAC keys)
4. Key Injection (jwk/jku header manipulation)
5. Payload Manipulation (claim modification)
6. Signature Stripping (removing signature)

**Chain Escalation Potential:**
JWT manipulation leads to authentication bypass, then privilege escalation, then full account takeover. Combined with XSS, it enables token theft. Combined with SSRF, it enables key extraction.

---

## Pre-requisite Knowledge

Before attempting JWT exploitation, you must understand:

1. Base64URL encoding and decoding differences from standard Base64
2. HMAC and RSA cryptographic primitives and their security properties
3. JSON web key set (JWKS) format and key distribution mechanisms
4. JWT claim semantics (sub, iss, exp, iat, aud, roles, scope)
5. Token lifecycle (issuance, validation, refresh, revocation)
6. JWT storage mechanisms (cookies, localStorage, sessionStorage, authorization header)
7. Common JWT libraries and their known vulnerabilities (jsonwebtoken, jose, nimbus-jose)
8. OAuth 2.0 and OIDC token exchange flows (id_token, access_token, refresh_token)
9. Web application session management and its interaction with JWTs
10. Public key cryptography and digital signature verification

---

## Chain Architecture / Attack Flow Diagram

```
+-----------------------------------------------------------------------+
|                    JWT MANIPULATION CHAIN                              |
+-----------------------------------------------------------------------+

  +----------------+    +------------------+    +-----------------+
  | Recon Phase    |    | Token Discovery  |    | Algorithm ID    |
  |                |    |                  |    |                 |
  | Find JWT use   |--->| Cookie analysis  |--->| Check header    |
  | Map auth flow  |    | Header inspect   |    | alg field       |
  | Identify lib   |    | LocalStorage     |    | HMAC or RSA?    |
  +----------------+    | API responses    |    | Known vuln lib? |
                        +------------------+    +--------+--------+
                                                         |
                                                         v
                        +------------------+    +-----------------+
                        | Attack Selection |<---|  Vulnerability  |
                        |                  |    |  Analysis       |
                        | Alg confusion    |    +-----------------+
                        | None bypass      |
                        | Secret crack     |
                        | Key injection    |
                        | Payload mod      |
                        +--------+---------+
                                 |
                                 v
                        +------------------+    +-----------------+
                        |  Token Crafting   |--->|  Access Gained  |
                        |                  |    |                 |
                        | Modified JWT     |    | Auth bypass     |
                        | Forged signature |    | Priv escalation |
                        | Stolen token     |    | Account takeover|
                        +------------------+    +--------+--------+
                                                         |
                                                         v
                        +------------------+    +-----------------+
                        |  Post-Exploit    |--->|  Full Compromise|
                        |                  |    |                 |
                        | Session hijack   |    | Data breach     |
                        | Admin access     |    | Lateral move    |
                        | API abuse        |    | Persistence     |
                        +------------------+    +-----------------+
```

---

## Step-by-Step Exploitation Methodology

### Phase 1: Token Discovery and Analysis

**Step 1.1 - Locate JWT tokens:**
Check HTTP response headers for Authorization or Set-Cookie headers containing three Base64URL segments separated by dots. Inspect browser localStorage, sessionStorage, and cookies for JWT patterns. Monitor API responses for token issuance endpoints.

**Step 1.2 - Decode JWT structure:**
Split the token on the dot delimiter. Decode each segment using Base64URL decoding. Examine the header for algorithm (alg), key ID (kid), and key URL (jku) parameters. Examine payload for subject, role, expiration, and custom claims.

**Step 1.3 - Identify JWT library:**
Check application responses for version headers, error messages revealing library names, or JavaScript source code importing JWT libraries. Common libraries include jsonwebtoken, jose, nimbus-jose-jwt, Auth0, and pyjwt.

### Phase 2: Vulnerability Identification

**Step 2.1 - Test algorithm confusion:**
If server uses RS256, attempt downgrade to HS256. Sign with server's public key from JWKS endpoint. If verification succeeds, algorithm confusion exists.

**Step 2.2 - Test none algorithm:**
Modify header to set alg to "none". Remove signature entirely. If accepted, server does not validate signatures properly.

**Step 2.3 - Test weak secret:**
If algorithm is HMAC, attempt cracking using wordlists. Common weak secrets include "secret", "password", and application-specific terms.

### Phase 3: Token Manipulation

**Step 3.1 - Payload modification:**
Change role claims from user to admin. Modify subject claims to impersonate other users. Extend expiration claims for persistent access.

**Step 3.2 - Signature manipulation:**
For algorithm confusion, sign modified payload with public key using HMAC. For none algorithm, remove signature entirely. For weak secrets, sign with cracked key.

**Step 3.3 - Header injection:**
Inject jwk parameter with attacker-controlled public key. Inject jku URL pointing to attacker-controlled JWKS endpoint.

### Phase 4: Token Deployment

**Step 4.1 - Submit modified token:**
Replace the original token in the Authorization header, cookie, or storage location with the crafted token. Ensure proper formatting (no padding, correct Base64URL encoding).

**Step 4.2 - Verify access:**
Test access to protected resources. Verify privilege level matches modified claims. Test access to other user accounts if subject was changed.

**Step 4.3 - Chain exploitation:**
Use gained access to extract additional credentials. Pivot to admin functionality. Access other services accepting the same token.

---

## Tool Arsenal with Exact Commands

### 1. JWT Decoding and Analysis
Use jwt.io debugger to inspect token structure. Decode header and payload using Python's base64 module. Examine algorithm, key ID, and claim values.

### 2. JWT Tool (jwt_tool.py)
Scan token for vulnerabilities, test none algorithm bypass, test algorithm confusion, brute-force HMAC secret, and modify claims. Comprehensive JWT exploitation framework.

### 3. Hashcat JWT Cracking
Extract JWT signature for cracking. Use hashcat mode 16500 for HMAC-SHA256 brute-force. Apply rule-based mutation for common password patterns.

### 4. Custom JWT Forgery Script
Build token from header and payload. Base64URL encode each segment. Sign with HMAC or RSA depending on attack type. Return complete forged token.

### 5. JWKS Injection Server
Host attacker-controlled JWKS endpoint. Return attacker's public key in JWKS format. Configure server to fetch keys from attacker's URL via jku parameter.

### 6. Token Replay Script
Submit modified token to protected endpoints. Test access levels across different resources. Verify authorization matches modified claims.

---

## Real-World Case Studies

### Case Study 1: Algorithm Confusion in Java Application
**Target:** Enterprise SSO using RSA-signed JWTs
**Vulnerability:** Server accepted HMAC-signed tokens using RSA public key
**Attack Flow:** Obtained RSA public key from JWKS endpoint. Crafted JWT with alg HS256. Signed using public key bytes as HMAC secret. Modified role to admin. Server verified against public key, accepting forged token.
**Impact:** Full admin access, user impersonation

### Case Study 2: None Algorithm in Node.js API
**Target:** REST API using jsonwebtoken library
**Vulnerability:** Server did not disable none algorithm
**Attack Flow:** Decoded existing JWT. Modified header alg to none. Removed signature. Changed sub to admin. Server accepted without verification.
**Impact:** Account takeover, full API access

### Case Study 3: Weak Secret in Microservices
**Target:** Microservices using shared HMAC secret
**Vulnerability:** Secret was "secret123" in source repository
**Attack Flow:** Extracted token. Cracked secret in under 10 minutes. Forged tokens for any user including admins.
**Impact:** Cross-service impersonation, admin access

### Case Study 4: JWT Confusion in OAuth Flow
**Target:** OIDC provider issuing access and ID tokens
**Vulnerability:** Backend accepted ID tokens as access tokens
**Attack Flow:** Modified ID token with API access claims. Submitted as access token. Backend validated signature but used wrong token type for authorization.
**Impact:** Privilege escalation, unauthorized API access

---

## Bypass Techniques and Evasion

### Algorithm Confusion Variations
**RS256 to HS256:** Most common. Sign with public key bytes as HMAC secret.
**ES256 to HS256:** Elliptic curve to HMAC. Requires EC public key conversion.
**PS256 to HS256:** RSA-PSS to HMAC. Public key extraction enables confusion.

### None Algorithm Variations
**Empty signature:** Remove signature entirely. Some libraries reject this.
**Case sensitivity:** Try "None", "NONE", "none", "nOnE" variations.
**Alternative names:** Try "noCheck", "HSnone" for specific library bypasses.

### Secret Cracking Optimization
**Wordlist selection:** Use application-specific words, company name, domain.
**Rule-based mutation:** Apply capitalization, numbers, special characters.
**Rainbow tables:** Pre-computed tables for common short JWT secrets.

### Token Storage Attacks
**LocalStorage theft:** XSS accesses localStorage tokens for exfiltration.
**Cookie manipulation:** If no HttpOnly flag, JavaScript reads JWT cookie.
**Header interception:** MITM captures tokens in transit without HTTPS.

---

## Defensive Indicators / Detection

### Server-Side Indicators
- JWT verification failures with algorithm mismatch
- Tokens with "none" algorithm in header
- Tokens with unusual kid or jku header parameters
- HMAC-signed tokens when RSA is expected

### Client-Side Indicators
- JWT tokens in localStorage without encryption
- Tokens without expiration claims
- Tokens with overly broad scope claims
- Tokens accepted from multiple issuers

### Log Analysis
Monitor for JWT verification failures, algorithm downgrade attempts, and tokens with suspicious claim modifications.

---

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Auth Bypass | Rate-limited | Any user | Admin user | All users |
| Token Scope | Single endpoint | Single service | Multiple services | Full platform |
| Persistence | Token expiry | Extended expiry | No expiry | Permanent |
| Chaining | None | Info disclosure | Priv escalation | Full compromise |
| Business Impact | Low-priv access | User data | Admin data | System takeover |

**CVSS 3.1 Scoring:** Authentication bypass: AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H = 8.1. Admin impersonation: 9.8.

---

## Common Pitfalls and Anti-Patterns

1. Assuming JWT signature prevents modification - only works with secure algorithms
2. Not validating the alg claim - accepting any algorithm allows confusion attacks
3. Storing signing keys in source code - leads to secret compromise
4. Using weak HMAC secrets - enables brute-force cracking
5. Not checking token expiration - allows use of revoked tokens
6. Accepting tokens from multiple issuers - enables cross-service confusion
7. Not validating iss and aud claims - allows token reuse across services
8. Storing tokens in localStorage - vulnerable to XSS exfiltration
9. Not implementing token revocation - compromised tokens remain valid
10. Trusting client-side token storage - can be manipulated by attacker

---

## Advanced Variations

### JWKS Endpoint Injection
If the server fetches JWKS from a URL specified in the token header (jku parameter), inject an attacker-controlled JWKS URL. The server fetches the attacker's public key and uses it to verify the attacker's forged token.

### Cross-JWT Service Confusion
In microservices, different services may use different signing keys but share the same token format. Forge a token signed with Service A's key and present it to Service B. If Service B does not validate the issuer, it accepts the token.

### JWT Refresh Token Abuse
Obtain a refresh token. Use it to generate new access tokens after the original token expires. If refresh tokens are not rotated on use, the same refresh token can generate unlimited access tokens.

### JWT in OAuth Flows
Manipulate id_token in OIDC flows. Change the nonce to match a session controlled by the attacker. Modify claims to escalate privileges. Chain with open redirect to steal authorization codes.

### Token Confusion via Custom Claims
Add non-standard claims that the server interprets differently. For example, adding a "permissions" claim that overrides the standard "scope" claim. The server may process the custom claim first.

---

## Integration with Other Chains

### JWT to XSS Chain
Steal JWT via XSS in localStorage. Use stolen token to access other users' data. Chain with stored XSS to exfiltrate tokens from all users.

### JWT to SSRF Chain
If JWT controls redirect URLs, manipulate claims to cause server-side requests. Chain with SSRF to access internal resources using the server's authenticated context.

### JWT to Account Takeover Chain
Forge JWT with victim's user ID. Access victim's account. Change victim's email or password. Complete account takeover through authentication flow manipulation.

### JWT to API Abuse Chain
Forge tokens with elevated scopes. Access administrative API endpoints. Chain with mass assignment to modify other users' data.

---

## Reporting and Documentation

**Title:** JWT Authentication Bypass via [specific technique]
**Severity:** Critical (CVSS 3.1: 8.1 to 9.8)
**Endpoint:** Authentication endpoint and protected resources

**Description:** Application uses JWT authentication but fails to properly validate [algorithm/signature/claims]. This allows forging tokens for arbitrary users including administrators.

**Reproduction Steps:**
1. Obtain a valid JWT token from authenticated session
2. Decode token to examine header and payload structure
3. Apply the specific manipulation technique described
4. Submit modified token to access protected resources
5. Observe successful authentication and authorization

**Impact:** Account takeover of any user, privilege escalation to admin, access to all protected resources
**Remediation:** Whitelist allowed algorithms, validate signatures strictly, enforce claim validation, implement token revocation

---

## Practice Labs and Exercises

### Lab Environment Setup
Deploy JWT authentication practice applications. Common options include intentionally vulnerable JWT implementations and CTF-style authentication challenges.

### Progressive Exercises
- Level 1: Decode and analyze JWT structure
- Level 2: Exploit none algorithm bypass
- Level 3: Perform algorithm confusion attack
- Level 4: Crack weak HMAC secret
- Level 5: Forge token with modified claims
- Level 6: Chain JWT bypass with privilege escalation

### Self-Assessment
- [ ] Can decode and analyze any JWT token
- [ ] Can identify algorithm type and signing method
- [ ] Can exploit algorithm confusion vulnerabilities
- [ ] Can bypass none algorithm protections
- [ ] Can crack weak HMAC secrets
- [ ] Can forge tokens for arbitrary users

---

## Ethical Guidelines

1. **Authorization First** - Only test JWT authentication on authorized targets
2. **No Account Takeover** - Demonstrate vulnerability without accessing real user accounts
3. **Test with Own Account** - Use test accounts for exploitation proof of concept
4. **Document All Steps** - Record every manipulation attempt for reporting
5. **Responsible Disclosure** - Report findings through official channels
6. **Minimal Impact** - Do not modify other users' data during testing
7. **Scope Boundaries** - Do not use bypassed access for out-of-scope testing
8. **Key Protection** - Do not publish cracked secrets publicly
9. **Client Communication** - Report critical auth bypass immediately
10. **Professional Standards** - Maintain confidentiality of findings

---

## Quick Reference Cheat Sheet

### JWT Structure
```
Header.Payload.Signature
Header: {"alg":"HS256","typ":"JWT"}
Payload: {"sub":"1234567890","role":"user","exp":1356048000}
Signature: HMACSHA256(base64(header) + "." + base64(payload), secret)
```

### Common Attack Payloads
- None algorithm: Change alg to "none", remove signature
- Algorithm confusion: Change RS256 to HS256, sign with public key
- Claim modification: Change role to admin, sub to target user
- Expiration bypass: Set exp to far future timestamp

### Quick Detection Commands
```bash
# Decode JWT header
echo 'HEADER' | base64 -d 2>/dev/null

# Check if token is HMAC signed
python3 -c "import jwt; print(jwt.decode(TOKEN, options={'verify_signature': False}))"

# Test none algorithm
python3 -c "
import base64, json
header = base64.urlsafe_b64encode(json.dumps({'alg':'none','typ':'JWT'}).encode()).rstrip(b'=')
payload = base64.urlsafe_b64encode(json.dumps({'sub':'admin','role':'admin'}).encode()).rstrip(b'=')
print(f'{header.decode()}.{payload.decode()}.')
"
```

### Hashcat Modes for JWT
- Mode 16500: JWT (JSON Web Token)
- Mode 16501: JWT (JSON Web Token) with RS256
