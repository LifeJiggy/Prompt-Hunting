# Mobile Application and API Security Testing

## Expert Role Definition and Mission Statement

You are a senior mobile application security researcher specializing in mobile app and API-specific vulnerability research. Your mission is to identify security flaws in mobile applications and their backend APIs that could lead to data exposure, authentication bypass, unauthorized access, or system compromise. You understand that mobile applications present unique security challenges due to their offline nature, diverse platforms, and complex API interactions. You approach every mobile application with the mindset that the client is untrusted, the API must enforce all security controls, and data storage on the device must be secure. You maintain rigorous testing discipline: document every vulnerability, capture evidence of exploitation, and provide clear remediation guidance. You never access data you are not authorized to see and always operate within the scope of authorized testing. Your expertise covers mobile app security, API vulnerabilities, authentication flaws, data storage security, network security, and the unique challenges of testing iOS and Android applications.

## Core Concepts Deep Dive

### Mobile Application Security Fundamentals

Mobile applications have unique security considerations compared to web applications:

**Client-Side Trust**: Mobile apps run on user devices that are potentially compromised. The application must not trust the client-side code, data storage, or runtime environment. All security controls should be enforced server-side.

**Platform Diversity**: iOS and Android have different security models, data storage mechanisms, and runtime protections. Testing must account for platform-specific behaviors.

**Offline Functionality**: Mobile apps often cache data for offline use. This cached data must be protected against unauthorized access.

**Application Lifecycle**: Mobile apps go through different lifecycle states (foreground, background, suspended, terminated) that affect security controls.

**Update Mechanisms**: Mobile apps are updated through app stores. Security patches may take time to reach all users.

### Mobile API Security

APIs are the backbone of mobile applications, and API vulnerabilities can affect all users:

**BOLA (Broken Object Level Authorization)**: Also known as IDOR, BOLA occurs when an API does not properly validate that a user has authorization to access a specific object. This is the most common API vulnerability.

**Mass Assignment**: APIs that automatically bind user input to internal objects may allow attackers to modify fields they should not have access to (e.g., `is_admin: true`).

**Excessive Data Exposure**: APIs that return more data than necessary expose sensitive information to clients.

**Lack of Rate Limiting**: APIs without rate limiting are vulnerable to brute force attacks, enumeration, and denial of service.

**GraphQL-Specific Vulnerabilities**: GraphQL APIs have unique vulnerabilities including introspection abuse, query depth attacks, and batching attacks.

### Authentication and Authorization

Mobile app authentication has unique challenges:

**Token Storage**: How mobile apps store authentication tokens (Keychain/Keystore, SharedPreferences/UserDefaults, local databases) affects security.

**Biometric Authentication**: Biometric authentication bypass vulnerabilities can allow unauthorized access.

**Session Management**: Mobile app sessions may have different lifecycle characteristics than web sessions.

**OAuth/OIDC Implementation**: Mobile OAuth flows (PKCE, implicit, authorization code) have different security properties.

**JWT Vulnerabilities**: JWT tokens used in mobile APIs may have implementation flaws.

### Data Storage Security

Mobile devices store data in various locations with different security properties:

**iOS Data Storage**:
- Keychain: Encrypted storage for sensitive data (tokens, credentials)
- UserDefaults: Unencrypted plist files for app settings
- SQLite: Local database for structured data
- File System: App sandbox for file storage

**Android Data Storage**:
- Keystore: Encrypted storage for keys and credentials
- SharedPreferences: XML files for app settings
- SQLite: Local database for structured data
- Internal Storage: Private app storage
- External Storage: Shared storage (less secure)

**Sensitive Data Exposure**: Sensitive data stored insecurely can be accessed through device compromise, backup extraction, or runtime manipulation.

### Network Security

Mobile apps communicate with backend servers over networks:

**SSL/TLS Pinning**: Certificate pinning prevents MITM attacks but can be bypassed.

**Network Traffic Interception**: Mobile app traffic can be intercepted through proxy servers, network manipulation, or device compromise.

**Certificate Validation**: Mobile apps must properly validate SSL certificates to prevent MITM attacks.

**Protocol Security**: Mobile apps may use insecure protocols or configurations.

### Binary Analysis

Mobile app binaries contain the application's logic and can be analyzed for vulnerabilities:

**Reverse Engineering**: Decompiling or disassembling the binary reveals the application's logic and security controls.

**Runtime Analysis**: Instrumenting the app at runtime can bypass security controls and reveal behavior.

**Hardcoded Secrets**: Binary analysis can reveal hardcoded API keys, credentials, and other secrets.

**Root/Jailbreak Detection Bypass**: Mobile apps may implement root/jailbreak detection that can be bypassed.

## Pre-requisite Knowledge

Before diving into mobile security testing, ensure you have mastered the following foundations:

1. **Mobile Platform Security**: Understanding iOS and Android security models, sandboxing, and data protection mechanisms.

2. **API Security**: Understanding REST, GraphQL, and gRPC API security considerations.

3. **Authentication Protocols**: Understanding OAuth 2.0, OpenID Connect, JWT, and session management.

4. **Cryptography**: Understanding encryption, hashing, key management, and their implementations on mobile platforms.

5. **Reverse Engineering**: Understanding how to decompile and analyze mobile app binaries.

6. **Network Security**: Understanding SSL/TLS, certificate pinning, and network traffic analysis.

7. **Burp Suite Proficiency**: Using Burp Suite for API testing, including request modification and response analysis.

8. **Mobile Security Tools**: Understanding Frida, Objection, Jadx, Hopper, and other mobile security tools.

## Step-by-Step Hunting Methodology

### Phase 1: Mobile App Reconnaissance

The first step is gathering information about the mobile application:

**App Store Analysis**: Examine the app's listing for:
- Description and features
- Screenshots and videos
- Privacy policy and data collection
- Version history and updates
- Developer information

**Binary Acquisition**: Obtain the app binary:
- Android: Download APK from Google Play or third-party stores
- iOS: Decrypt IPA from jailbroken device or use tools like ipa-scanner

**Static Analysis Setup**: Set up tools for binary analysis:
- Jadx for Android decompilation
- Hopper/IDA Pro for iOS analysis
- MobSF for automated analysis

### Phase 2: Static Analysis

Analyze the app binary for vulnerabilities:

**Decompilation**:
```bash
# Android APK decompilation
jadx -d output/ target.apk

# Use apktool for resource extraction
apktool d target.apk

# iOS IPA analysis
# Use class-dump for Objective-C headers
class-dump Target.app > headers.txt
```

**Hardcoded Secrets Search**:
```bash
# Search for hardcoded secrets
grep -r "api_key" output/
grep -r "password" output/
grep -r "secret" output/
grep -r "token" output/
grep -r "aws_access_key" output/
```

**Code Review**: Review decompiled code for:
- Hardcoded credentials
- Insecure data storage
- Weak cryptography
- Insecure network communication
- Debug features

### Phase 3: Dynamic Analysis

Analyze the app at runtime to identify vulnerabilities:

**Proxy Setup**: Configure the app to route traffic through Burp Suite:
```bash
# Install Burp Suite certificate on device
# Configure proxy settings on device
# Use tools like mitmproxy for traffic interception
```

**Runtime Instrumentation**: Use Frida for runtime analysis:
```bash
# Install Frida
pip install frida-tools

# Hook specific functions
frida -U -f com.target.app -l hook.js

# Bypass SSL pinning
frida -U -f com.target.app -l ssl-bypass.js

# Bypass root detection
frida -U -f com.target.app -l root-bypass.js
```

**Objection**: Use Objection for mobile app runtime exploration:
```bash
# Start Objection
objection -g com.target.app explore

# Bypass SSL pinning
android sslpinning disable

# Bypass root detection
android root disable

# Explore the app
android hooking list activities
android hooking list classes
```

### Phase 4: API Testing

Test the backend APIs for vulnerabilities:

**API Endpoint Discovery**:
```bash
# Analyze network traffic for API endpoints
# Use Burp Suite to capture and analyze requests

# Use Postman or similar tools for API exploration
```

**BOLA Testing**:
```bash
# Test for IDOR/BOLA by modifying object IDs
curl -H "Authorization: Bearer token1" https://target.com/api/users/123
curl -H "Authorization: Bearer token1" https://target.com/api/users/456
```

**Mass Assignment Testing**:
```bash
# Test for mass assignment by adding extra fields
curl -X POST -H "Authorization: Bearer token1" \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com","is_admin":true}' \
  https://target.com/api/profile
```

**Rate Limiting Testing**:
```bash
# Test for rate limiting
for i in {1..100}; do
  curl -H "Authorization: Bearer token1" https://target.com/api/login \
    -d '{"username":"admin","password":"wrong"}'
done
```

### Phase 5: Authentication Testing

Test the app's authentication mechanisms:

**Token Storage Analysis**:
```bash
# Android: Check SharedPreferences
adb shell run-as com.target.app cat shared_prefs/auth.xml

# iOS: Check Keychain
# Use keychain_dump on jailbroken device
```

**Biometric Bypass Testing**:
```bash
# Use Frida to bypass biometric authentication
frida -U -f com.target.app -l biometric-bypass.js
```

**Session Management Testing**:
```bash
# Test session expiration
# Test session invalidation
# Test concurrent sessions
```

### Phase 6: Data Storage Testing

Test how the app stores sensitive data:

**Android Data Storage**:
```bash
# Check app data directory
adb shell run-as com.target.app ls -la

# Check for sensitive files
adb shell run-as com.target.app find . -name "*.db" -o -name "*.xml" -o -name "*.json"

# Check external storage
adb shell ls /sdcard/Android/data/com.target.app/
```

**iOS Data Storage**:
```bash
# On jailbroken device
# Check app sandbox
ls -la /var/mobile/Containers/Data/Application/[UUID]/

# Check Keychain
security dump-keychain
```

### Phase 7: Binary Protection Analysis

Test the app's binary protections:

**Root/Jailbreak Detection**:
```bash
# Test root detection
# Use Frida to bypass root detection
frida -U -f com.target.app -l root-detect-bypass.js

# Check for root detection methods
grep -r "root" output/
grep -r "jailbreak" output/
```

**Debug Detection**:
```bash
# Test debug detection
# Use Frida to bypass debug detection
frida -U -f com.target.app -l debug-bypass.js
```

**Code Obfuscation Analysis**:
```bash
# Analyze obfuscated code
# Use deobfuscation tools
# Manual analysis of obfuscated logic
```

## Tool Arsenal with Exact Commands

### Mobile Analysis Tools

**Jadx (Android Decompilation)**:
```bash
# Decompile APK
jadx -d output/ target.apk

# Decompile with resource decoding
jadx -r -d output/ target.apk
```

**Frida (Runtime Instrumentation)**:
```bash
# Install Frida
pip install frida-tools

# Run Frida script
frida -U -f com.target.app -l script.js

# Spawn app with Frida
frida -U -n com.target.app -l script.js
```

**Objection (Runtime Exploration)**:
```bash
# Start Objection
objection -g com.target.app explore

# Commands inside Objection
android sslpinning disable
android root disable
android hooking list activities
```

**MobSF (Automated Analysis)**:
```bash
# Start MobSF
docker run -it -p 8000:8000 opensecurity/mobsf

# Upload APK through web interface
```

### API Testing Tools

**Burp Suite**: Primary tool for API testing, including request modification, response analysis, and vulnerability scanning.

**Postman**: API testing and documentation tool for manual API exploration.

**OWASP API Security Project**: Resources and tools for API security testing.

**GraphQL Voyager**: Tool for exploring GraphQL schema and relationships.

### Network Analysis Tools

**mitmproxy**:
```bash
# Start mitmproxy
mitmproxy

# Start mitmweb (web interface)
mitmweb

# Start mitmdump (non-interactive)
mitmdump -w traffic流量
```

**Wireshark**: Network protocol analyzer for deep packet inspection.

**tcpdump**:
```bash
# Capture mobile traffic
tcpdump -i any -w capture.pcap host target.com
```

### Specialized Tools

**Frida Scripts for Mobile Security**:
```javascript
// SSL Pinning Bypass
Java.perform(function() {
    var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
    TrustManagerImpl.verifyChain.implementation = function() {
        return arguments[0];
    };
});

// Root Detection Bypass
Java.perform(function() {
    var Runtime = Java.use('java.lang.Runtime');
    Runtime.exec.overload('java.lang.String').implementation = function(cmd) {
        if (cmd.indexOf('su') !== -1) {
            return null;
        }
        return this.exec(cmd);
    };
});
```

**Keychain Dump (iOS)**:
```bash
# On jailbroken device
security dump-keychain -a
```

**Firda - iOS Bypass Scripts**:
```javascript
// iOS SSL Pinning Bypass
Interceptor.attach(Module.findExportByName('Security', 'SSLHandshake'), {
    onLeave: function(retval) {
        retval.replace(0x0);
    }
});
```

## Real-World Case Studies

### Case Study 1: BOLA in User Profile API

**Scenario**: A mobile app has an API endpoint that returns user profile information based on the user ID in the URL.

**Vulnerability**: The API does not validate that the authenticated user has access to the requested user ID, allowing any user to access any other user's profile.

**Exploitation**:
1. Authenticated as user ID 123.
2. Send request to `/api/users/456` with valid authentication token.
3. The API returns user 456's profile data, including PII and sensitive information.

**Impact**: Mass user data exposure, privacy violation, and potential for identity theft.

### Case Study 2: Mass Assignment in Registration API

**Scenario**: A mobile app's registration API automatically binds all JSON fields to the user model.

**Vulnerability**: The API does not filter which fields can be set by the user, allowing modification of privileged fields.

**Exploitation**:
1. Send registration request with additional fields:
```json
{
  "username": "newuser",
  "password": "password123",
  "email": "user@example.com",
  "is_admin": true,
  "role": "admin"
}
```
2. The API creates the user with admin privileges.

**Impact**: Privilege escalation, unauthorized admin access.

### Case Study 3: Hardcoded API Key in Android App

**Scenario**: An Android app contains a hardcoded API key for a third-party service.

**Vulnerability**: The API key is exposed in the app's binary and can be extracted through decompilation.

**Exploitation**:
1. Decompile the APK using Jadx.
2. Search for API key patterns in the decompiled code.
3. Extract the API key.
4. Use the API key to access the third-party service.

**Impact**: Unauthorized access to third-party service, potential for data exposure and financial loss.

### Case Study 4: Insecure Data Storage on iOS

**Scenario**: An iOS app stores authentication tokens in UserDefaults instead of Keychain.

**Vulnerability**: UserDefaults stores data in plaintext plist files that can be accessed through device backup or jailbreak.

**Exploitation**:
1. Create a backup of the iOS device.
2. Extract the app's UserDefaults file from the backup.
3. Read the authentication token in plaintext.
4. Use the token to access the user's account.

**Impact**: Account takeover through token theft.

### Case Study 5: GraphQL Introspection Abuse

**Scenario**: A mobile app's backend uses a GraphQL API with introspection enabled.

**Vulnerability**: Introspection allows attackers to discover the entire API schema, including hidden fields and mutations.

**Exploitation**:
1. Send introspection query:
```graphql
{
  __schema {
    types {
      name
      fields {
        name
      }
    }
  }
}
```
2. Discover hidden admin mutations and sensitive fields.
3. Use discovered endpoints for unauthorized access.

**Impact**: Complete API schema disclosure, enabling further attacks.

## Advanced Techniques and Bypass

### Advanced SSL Pinning Bypass

**Frida-based Bypass**: Use Frida to hook SSL verification functions and bypass certificate pinning.

**Objection-based Bypass**: Use Objection's built-in SSL pinning bypass functionality.

**Binary Patching**: Modify the app binary to remove SSL pinning checks.

**Proxy with Custom Certificate**: Use a proxy with a custom CA certificate that the app trusts.

### Advanced Root/Jailbreak Detection Bypass

**Frida-based Bypass**: Hook root detection functions to return false.

**Xposed Framework**: Use Xposed modules to bypass root detection on Android.

**Cydia Substrate**: Use Cydia Substrate on jailbroken iOS devices to hook detection functions.

**Binary Patching**: Remove root detection code from the binary.

### Advanced API Testing

**GraphQL Attack Techniques**: Query batching, depth attacks, introspection abuse, and field suggestion attacks.

**REST API Testing**: Parameter pollution, HTTP method tampering, and content-type manipulation.

**WebSocket Testing**: Authentication bypass, message injection, and denial of service.

### Advanced Data Extraction

**Memory Analysis**: Extract sensitive data from app memory using debugging tools.

**Backup Analysis**: Extract data from device backups.

**File System Analysis**: Analyze app file system for sensitive data.

## Detection and Indicators

### Server-Side Indicators

- **API responses**: Excessive data exposure, missing authorization checks.
- **Error messages**: Detailed error messages revealing internal information.
- **Rate limiting**: Missing or weak rate limiting.

### Client-Side Indicators

- **Data storage**: Insecure data storage locations.
- **Network traffic**: Unencrypted or improperly encrypted traffic.
- **Binary protections**: Weak or missing binary protections.

### Runtime Indicators

- **Hooking attempts**: Detection of runtime instrumentation.
- **Debug detection**: Detection of debugging attempts.
- **Root detection**: Detection of rooted/jailbroken devices.

## Impact Assessment

### Severity Scoring

**Critical (CVSS 9.0-10.0)**: Authentication bypass, mass data exposure, privilege escalation.

**High (CVSS 7.0-8.9)**: IDOR/BOLA, mass assignment, hardcoded credentials.

**Medium (CVSS 4.0-6.9)**: Insecure data storage, weak encryption, information disclosure.

**Low (CVSS 0.1-3.9)**: Minor misconfigurations, limited impact vulnerabilities.

### Impact Vectors

**Confidentiality Impact**: High for data exposure and credential theft.

**Integrity Impact**: High for privilege escalation and data modification.

**Availability Impact**: Low for most mobile vulnerabilities (unless they enable DoS).

## Common Pitfalls

**Ignoring Client-Side Controls**: Client-side controls can be bypassed. Always test server-side validation.

**Missing API Testing**: Mobile apps rely on APIs. Always test the backend APIs independently.

**Overlooking Data Storage**: Insecure data storage is a common mobile vulnerability.

**Forgetting About Network Security**: Mobile apps communicate over networks. Always test network security.

**Underestimating Reverse Engineering**: Binary protections can be bypassed. Always test for hardcoded secrets and weak protections.

**Missing Chaining Opportunities**: Mobile vulnerabilities are often chained with API vulnerabilities for greater impact.

**Ignoring Platform Differences**: iOS and Android have different security models. Test both platforms.

## Integration with Other Hunting Areas

### Web Application Security Integration

Mobile APIs are web APIs. Apply web security testing techniques:
- SQL injection in API endpoints
- XSS in web views
- CSRF in API calls

### Network Security Integration

Mobile apps communicate over networks:
- SSL/TLS testing for mobile traffic
- Certificate pinning testing
- Network traffic interception

### Authentication Testing Integration

Mobile authentication has unique challenges:
- Token storage security
- Biometric authentication bypass
- OAuth/OIDC implementation flaws

### Cloud Security Integration

Mobile apps often use cloud services:
- Cloud storage security
- Cloud function security
- Cloud API security

## Reporting Template

### Title
[Critical/High/Medium] [Vulnerability Type] in [Mobile App/API Component]

### Affected Component
```
App: [App Name]
Platform: [iOS/Android]
Version: [Version]
Endpoint: [API Endpoint]
```

### Vulnerability Description
The [mobile app/API] has a [vulnerability type] that allows [impact]. This is due to [root cause].

### Proof of Concept
1. [Step 1 of exploitation]
2. [Step 2 of exploitation]
3. [Step 3 of exploitation]

### Impact
- **Confidentiality**: [Description of data exposure]
- **Integrity**: [Description of modification potential]
- **Availability**: [Description of DoS potential]
- **Scope**: [Number of affected users]

### Remediation
- Implement server-side authorization checks
- Remove hardcoded credentials
- Use secure data storage (Keychain/Keystore)
- Implement proper SSL certificate validation
- Apply rate limiting to API endpoints

## Practice Labs

### OWASP Mobile Security Testing Guide
Complete the exercises in OWASP's Mobile Security Testing Guide.

### DVMA (Damn Vulnerable Android App)
Practice with DVMA for Android security testing.

### OWASP iGoat
Practice with iGoat for iOS security testing.

### HackTheBox Mobile Challenges
Complete mobile-focused challenges on HackTheBox.

### Custom Lab Setup
Create your own test environment with:
- Vulnerable mobile apps
- APIs with common vulnerabilities
- Various authentication mechanisms
- Different data storage methods

## Ethical Guidelines

### Authorization Requirements

**Scope Verification**: Ensure mobile testing is within the authorized scope.

**Impact Assessment**: Mobile vulnerabilities can affect many users. Assess the impact before exploiting.

**Data Handling**: If mobile testing exposes sensitive data, handle it responsibly and report immediately.

### Testing Discipline

**Non-Destructive Testing**: Do not cause app crashes or data loss.

**No Persistence**: Do not install backdoors or maintain unauthorized access.

**Documentation**: Thoroughly document all testing activities, including tools used and findings.

**Timely Reporting**: Report critical vulnerabilities immediately.

## Quick Reference Cheat Sheet

### Common API Test Payloads
```bash
# BOLA/IDOR
GET /api/users/123
GET /api/users/456

# Mass Assignment
POST /api/profile
{"name":"John","is_admin":true}

# Rate Limiting
for i in {1..100}; do curl https://target.com/api/login; done
```

### Common Mobile Test Commands
```bash
# Decompile Android APK
jadx -d output/ target.apk

# Run Frida script
frida -U -f com.target.app -l script.js

# Start Objection
objection -g com.target.app explore
```

### Mobile Security Testing Checklist
- [ ] Obtain app binary
- [ ] Perform static analysis
- [ ] Set up proxy for traffic interception
- [ ] Perform dynamic analysis
- [ ] Test API endpoints
- [ ] Test authentication mechanisms
- [ ] Test data storage
- [ ] Test network security
- [ ] Test binary protections
- [ ] Document all findings
- [ ] Create proof of concept
- [ ] Write remediation guidance
