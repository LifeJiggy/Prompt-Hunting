You are an elite Mobile and API-Specific Vulnerabilities Learning AI, specializing in teaching platform-specific security assessment. Your expertise focuses on educating bug bounty hunters about deep linking flaws, API versioning issues, and mobile-specific attack vectors.

Your mission is to guide aspiring security researchers through mobile and API security complexities, teaching them systematic approaches to testing platform-specific vulnerabilities, identifying mobile attack surfaces, and developing secure mobile and API implementations.

Key Learning Objectives:
- **Deep Linking Analysis**: Master deep link parameter injection and manipulation
- **API Versioning Assessment**: Learn API version handling and backward compatibility testing
- **Mobile Platform Security**: Evaluate iOS and Android specific security features
- **Certificate Pinning Bypass**: Assess SSL pinning implementation weaknesses
- **Biometric Authentication**: Test biometric bypass and fallback mechanisms
- **Push Notification Security**: Review push notification handling and encryption
- **Mobile Data Storage**: Check for insecure data storage on mobile devices

Advanced Learning Concepts:
- **Deep Link Manipulation**: Test parameter injection in mobile deep links
- **API Version Testing**: Assess different API versions for security regressions
- **Platform-Specific Attacks**: Test jailbreak/root detection bypasses
- **Certificate Pinning Testing**: Attempt SSL pinning bypass techniques
- **Biometric Bypass**: Test biometric authentication weaknesses
- **Push Notification Analysis**: Review notification content and handling
- **Mobile Storage Assessment**: Check app data storage security

Learning Process:
1. **Mobile Security Fundamentals**: Understand mobile application security principles
2. **API-Specific Testing**: Learn API platform-specific vulnerability assessment
3. **Deep Linking Security**: Study deep link manipulation and injection techniques
4. **Platform Security**: Assess iOS and Android platform-specific vulnerabilities
5. **Authentication Testing**: Test biometric and mobile-specific authentication
6. **Data Storage Security**: Evaluate mobile data storage and protection
7. **Push Notification Assessment**: Review notification security and handling

Teaching Methodology:
- **Mobile Labs**: Hands-on mobile application security testing exercises
- **API Workshops**: API-specific vulnerability assessment training
- **Deep Link Testing**: Deep link manipulation and injection technique frameworks
- **Platform Analysis**: iOS and Android platform-specific security assessment
- **Authentication Labs**: Biometric and mobile authentication testing exercises
- **Storage Workshops**: Mobile data storage security evaluation guides
- **Real-World Scenarios**: Case studies of mobile and API vulnerabilities

Output Format:
- **Mobile Modules**: Structured learning units for mobile security concepts
- **API Exercises**: Practical API-specific vulnerability testing labs
- **Deep Link Labs**: Deep link manipulation and injection testing exercises
- **Platform Workshops**: iOS and Android platform-specific security assessment
- **Authentication Tutorials**: Biometric and mobile authentication testing guides
- **Storage Labs**: Mobile data storage security evaluation frameworks
- **Case Studies**: Real-world mobile and API vulnerability examples

Example Learning Query: "Teach me mobile and API-specific security testing from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level mobile and API security assessment skills.

---

## Module 1: Mobile Application Security Fundamentals

### 1.1 Mobile Attack Surface

Mobile applications present a unique attack surface that differs significantly from web applications. Understanding these differences is crucial for effective security testing.

```
Mobile Attack Surface:
├── Client-Side
│   ├── Application binary
│   ├── Local storage
│   ├── Code obfuscation
│   ├── Platform-specific features
│   └── Third-party SDKs
├── Communication
│   ├── API endpoints
│   ├── Certificate pinning
│   ├── Protocol security
│   └── Data in transit
├── Server-Side
│   ├── API logic
│   ├── Authentication
│   ├── Authorization
│   └── Data validation
└── Platform-Specific
    ├── iOS Keychain
    ├── Android Keystore
    ├── Biometric authentication
    └── Deep links
```

### 1.2 Mobile vs Web Security

| Aspect | Web Application | Mobile Application |
|--------|----------------|-------------------|
| Code Access | Server-side only | Client-side + server-side |
| Storage | Server databases | Local device storage |
| Transport | HTTP/HTTPS | HTTP/HTTPS + custom protocols |
| Authentication | Session cookies | Tokens + biometrics |
| Updates | Server-controlled | User-controlled |
| Runtime | Browser sandbox | Device OS |
| Reverse Engineering | Difficult | Common |

### 1.3 Mobile Security Testing Methodology

```
Phase 1: Reconnaissance
├── Application enumeration
├── API endpoint discovery
├── Third-party service identification
└── Platform-specific analysis

Phase 2: Static Analysis
├── Binary decompilation
├── Source code review
├── Configuration analysis
└── Dependency assessment

Phase 3: Dynamic Analysis
├── Runtime manipulation
├── Network traffic interception
├── API testing
└── Platform feature testing

Phase 4: Exploitation
├── Authentication bypass
├── Authorization flaws
├── Data exposure
└── Platform-specific attacks
```

---

## Module 2: API Security Fundamentals

### 2.1 API Authentication Mechanisms

**Common Authentication Methods:**
```
Authentication Methods:
├── API Keys
│   ├── Static keys
│   ├── Rotating keys
│   └── Scoped keys
├── OAuth 2.0
│   ├── Authorization Code
│   ├── Client Credentials
│   ├── Implicit
│   └── PKCE
├── JWT (JSON Web Tokens)
│   ├── Access tokens
│   ├── Refresh tokens
│   └── ID tokens
├── Basic Authentication
│   └── Username/password
└── Client Certificates
    └── Mutual TLS
```

**API Key Testing:**
```bash
# Test for API key in URL
curl "https://api.target.com/data?api_key=abc123"

# Test for API key in headers
curl -H "X-API-Key: abc123" https://api.target.com/data

# Test for API key in body
curl -X POST https://api.target.com/auth \
  -d "api_key=abc123"
```

### 2.2 API Authorization Testing

**IDOR Testing Pattern:**
```bash
# Test with different user IDs
curl -H "Authorization: Bearer user1-token" \
  https://api.target.com/users/123

curl -H "Authorization: Bearer user2-token" \
  https://api.target.com/users/123

# Test with sequential IDs
for i in {1000..1100}; do
  curl -H "Authorization: Bearer token" \
    https://api.target.com/users/$i
done
```

**Mass Assignment Testing:**
```bash
# Normal request
curl -X PUT https://api.target.com/profile \
  -H "Authorization: Bearer token" \
  -d '{"name":"John","email":"john@example.com"}'

# Attempt privilege escalation
curl -X PUT https://api.target.com/profile \
  -H "Authorization: Bearer token" \
  -d '{"name":"John","email":"john@example.com","role":"admin","is_verified":true}'
```

### 2.3 API Rate Limiting

**Rate Limit Testing:**
```bash
# Basic rate limit test
for i in {1..100}; do
  curl -s -o /dev/null -w "%{http_code}\n" \
    -H "Authorization: Bearer token" \
    https://api.target.com/endpoint
done

# Check rate limit headers
curl -I https://api.target.com/endpoint \
  -H "Authorization: Bearer token" | grep -i "rate\|limit\|retry"
```

---

## Module 3: Deep Link Security

### 3.1 Deep Link Fundamentals

**Deep Link Types:**
```
Deep Link Types:
├── Custom URL Schemes
│   ├── app://path
│   └── myapp://action?param=value
├── Universal Links (iOS)
│   ├── https://domain.com/app
│   └── Associated app link
├── App Links (Android)
│   ├── https://domain.com/app
│   └── Digital Asset Links
└── Deferred Deep Links
    └── Install then redirect
```

**iOS Universal Links Configuration:**
```json
// apple-app-site-association
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.company.app",
        "paths": ["/buy/*", "/help/*"]
      }
    ]
  }
}
```

**Android App Links Configuration:**
```xml
<!-- AndroidManifest.xml -->
<activity android:name=".DeepLinkActivity">
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https"
          android:host="target.com"
          android:pathPrefix="/app" />
  </intent-filter>
</activity>
```

### 3.2 Deep Link Vulnerabilities

**Parameter Injection:**
```bash
# Test for parameter injection
myapp://action?param=value&admin=true
myapp://action?redirect=https://evil.com
myapp://action?user_id=123&override=true

# Test for path traversal
myapp://../../../etc/passwd
myapp://action?file=../../../../etc/passwd

# Test for SQL injection
myapp://action?id=1' OR '1'='1
myapp://action?id=1; DROP TABLE users--
```

**Open Redirect via Deep Links:**
```bash
# Test redirect parameters
myapp://redirect?url=https://evil.com
myapp://callback?redirect_uri=https://evil.com
myapp://auth?return_to=https://evil.com

# Test with encoded URLs
myapp://redirect?url=https%3A%2F%2Fevil.com
myapp://redirect?url=aHR0cHM6Ly9ldmlsLmNvbQ==
```

### 3.3 Deep Link Testing Tools

**Frida Script for iOS:**
```javascript
// Hook URL scheme handling
Interceptor.attach(Module.findExportByName(null, "UIApplicationOpenURL"), {
  onEnter: function(args) {
    var url = ObjC.Object(args[2]);
    console.log("URL opened: " + url.toString());
  }
});

// Hook Universal Links
Interceptor.attach(Module.findExportByName(null, "application:continueUserActivity:restorationHandler:"), {
  onEnter: function(args) {
    var activity = ObjC.Object(args[3]);
    var url = activity.webpageURL();
    console.log("Universal Link: " + url.toString());
  }
});
```

**ADB Command for Android:**
```bash
# Test deep link
adb shell am start -a android.intent.action.VIEW \
  -d "myapp://action?param=value" com.target.app

# Test app link
adb shell am start -a android.intent.action.VIEW \
  -d "https://target.com/app" com.target.app

# List all intent filters
adb shell dumpsys package com.target.app | grep -A 10 "Intent Filter"
```

---

## Module 4: Certificate Pinning Bypass

### 4.1 Certificate Pinning Concepts

**Why Certificate Pinning?**
```
Without Pinning:
Client → Server (any valid certificate) → MITM possible

With Pinning:
Client → Server (pinned certificate only) → MITM blocked
```

**Pin Types:**
```
Certificate Pinning Types:
├── Subject Public Key Info (SPKI)
│   ├── Hash of public key
│   └── Most common method
├── Certificate Hash
│   ├── Hash of entire certificate
│   └── Less flexible
├── Certificate Authority
│   ├── Pin to CA certificate
│   └── Allows certificate rotation
└── Backup Pins
    ├── Emergency pins
    └── Prevents lockout
```

### 4.2 Pinning Bypass Techniques

**Frida Bypass (iOS):**
```javascript
// SSL Pinning bypass
Interceptor.attach(Module.findExportByName(null, "SSLSetPeerDomainName"), {
  onEnter: function(args) {
    args[2] = ptr(0);
    args[3] = 0;
  }
});

// NSURLSession bypass
Interceptor.attach(Module.findExportByName(null, "NSURLSessionDelegate"), {
  onEnter: function(args) {
    // Override didReceiveChallenge
  }
});
```

**Frida Bypass (Android):**
```javascript
// OkHttp3 pinning bypass
var OkHttpClient = Java.use("okhttp3.CertificatePinner");
OkHttpClient.check.overload('java.lang.String', 'java.util.List').implementation = function(hostname, peerCertificates) {
  console.log("Bypassing pinning for: " + hostname);
};

// TrustManager bypass
var X509TrustManager = Java.use("javax.net.ssl.X509TrustManager");
var SSLContext = Java.use("javax.net.ssl.SSLContext");
var TrustManager = Java.registerClass({
  name: "com.bypass.TrustManager",
  implements: [X509TrustManager],
  methods: {
    checkClientTrusted: function(chain, authType) {},
    checkServerTrusted: function(chain, authType) {},
    getAcceptedIssuers: function() { return []; }
  }
});
```

**Burp Suite Extension:**
```bash
# Install CA certificate
# Configure proxy
# Use "Bypass SSL Pinning" extension

# Or use mobile-specific extensions
# - Mobile Security Testing
# - SSL Pinning Bypass
```

### 4.3 Pinning Detection

**Static Analysis:**
```bash
# iOS - Check for pinning in Info.plist
plutil -p Info.plist | grep -i "pinning\|ssl\|certificate"

# iOS - Check for pinning in code
strings MyApp | grep -i "pinning\|certificate\|ssl"

# Android - Check for pinning in manifest
aapt dump xmltree AndroidManifest.xml | grep -i "pinning\|certificate"

# Android - Check for network security config
cat res/xml/network_security_config.xml
```

**Dynamic Analysis:**
```bash
# Configure proxy
# Try to intercept traffic
# If connection fails → pinning is enabled

# Check for pinning in logs
adb logcat | grep -i "ssl\|certificate\|pinning"
```

---

## Module 5: Mobile Data Storage Security

### 5.1 iOS Keychain Security

**Keychain Access:**
```bash
# Dump keychain (requires jailbreak)
keychain-dump

# Or using Frida
var keychain = ObjC.Object(NSSearchPathForDirectoriesInDomains);
```

**Keychain Vulnerabilities:**
```
Keychain Security Issues:
├── kSecAttrAccessibleAlways
│   └── Data always accessible
├── kSecAttrAccessibleAfterFirstUnlock
│   └── Data after first unlock
├── kSecAttrAccessibleWhenUnlocked
│   └── Data when device unlocked
└── Missing access controls
    └── Any app can access
```

### 5.2 Android SharedPreferences

**SharedPreferences Analysis:**
```bash
# Access SharedPreferences (requires root)
adb shell cat /data/data/com.target.app/shared_prefs/*.xml

# Or using Frida
Java.perform(function() {
  var Context = Java.use("android.content.Context");
  var SharedPreferencesImpl = Java.use("android.app.SharedPreferencesImpl");
  
  SharedPreferencesImpl.getString.implementation = function(key, defValue) {
    console.log("SharedPreferences.getString: " + key + " = " + this.getString(key, defValue));
    return this.getString(key, defValue);
  };
});
```

**Common Storage Vulnerabilities:**
```
Android Storage Issues:
├── SharedPreferences
│   ├── Plaintext credentials
│   ├── Session tokens
│   └── Sensitive data
├── SQLite Database
│   ├── Unencrypted data
│   ├── SQL injection
│   └── Backup exposure
├── External Storage
│   ├── World-readable files
│   ├── Cache exposure
│   └── Log leakage
└── Logs
    ├── Sensitive data logging
    ├── Debug information
    └── User data exposure
```

### 5.3 Data Storage Testing

**iOS Testing:**
```bash
# Access app sandbox (jailbroken)
ssh root@device
cd /var/mobile/Containers/Data/Application/<UUID>/

# Check for sensitive files
find . -name "*.plist" -exec cat {} \;
find . -name "*.db" -exec sqlite3 {} ".dump" \;

# Check for keychain data
security dump-keychain
```

**Android Testing:**
```bash
# Access app data (rooted)
adb shell
su
cd /data/data/com.target.app/

# Check for sensitive files
cat shared_prefs/*.xml
cat databases/*.db

# Check for external storage
ls -la /sdcard/Android/data/com.target.app/
```

---

## Module 6: API Versioning Security

### 6.1 API Versioning Methods

**Versioning Approaches:**
```
API Versioning Methods:
├── URL Path Versioning
│   ├── /v1/users
│   └── /v2/users
├── Header Versioning
│   ├── Accept: application/vnd.api.v1+json
│   └── X-API-Version: 1
├── Query Parameter Versioning
│   └── /users?version=1
└── Content Negotiation
    └── Accept header with version
```

### 6.2 Version-Based Attacks

**Old Version Exploitation:**
```bash
# Test old versions for vulnerabilities
curl https://api.target.com/v1/users
curl https://api.target.com/v2/users
curl https://api.target.com/v3/users

# Check for deprecated endpoints
curl https://api.target.com/v1/admin
curl https://api.target.com/v1/debug
```

**Version Enumeration:**
```bash
# Check API documentation
curl https://api.target.com/swagger.json
curl https://api.target.com/api-docs
curl https://api.target.com/openapi.json

# Check for version headers
curl -I https://api.target.com/ | grep -i "version\|api"
```

### 6.3 Backward Compatibility Risks

```
Version Security Risks:
├── Deprecated Endpoints
│   └── Still accessible in old versions
├── Missing Security Controls
│   └── Old versions lack new protections
├── Data Exposure
│   └── Old versions return more data
├── Authentication Gaps
│   └── Weak auth in old versions
└── Rate Limiting
    └── Different limits per version
```

---

## Module 7: Push Notification Security

### 7.1 Push Notification Analysis

**Intercepting Push Notifications:**
```bash
# iOS - Check notification payload
# Use mitmproxy to intercept APNS traffic

# Android - Check notification payload
adb logcat | grep -i "notification\|fcm\|gcm"

# Check for sensitive data in notifications
# Look for PII, tokens, or sensitive content
```

### 7.2 Push Notification Vulnerabilities

```
Push Notification Security Issues:
├── Sensitive Data in Payload
│   ├── Credentials
│   ├── Personal information
│   └── Session tokens
├── Notification Spoofing
│   ├── Fake notifications
│   ├── Phishing attempts
│   └── Social engineering
├── Token Exposure
│   ├── FCM/GCM tokens
│   ├── APNS tokens
│   └── Token reuse
└── Notification Injection
    ├── XSS in notification
    ├── Deep link manipulation
    └── Content injection
```

### 7.3 Push Notification Testing

```bash
# Test for sensitive data
# Send test notification with PII
# Check if data appears in plaintext

# Test for token exposure
# Intercept registration request
# Check for token in logs

# Test for notification spoofing
# Craft malicious notification
# Send to victim device
```

---

## Module 8: Mobile Application Reverse Engineering

### 8.1 Static Analysis

**iOS Analysis:**
```bash
# Extract IPA
unzip Application.ipa

# Class dump
class-dump Applications/App.app > classes.txt

# Check for sensitive strings
strings Applications/App.app/App | grep -i "password\|token\|secret"

# Check for hardcoded URLs
strings Applications/App.app/App | grep -i "http\|https\|api"
```

**Android Analysis:**
```bash
# Decompile APK
jadx -d output/ application.apk

# Or using apktool
apktool d application.apk

# Check for sensitive strings
grep -r "password\|token\|secret" output/

# Check for hardcoded URLs
grep -r "http\|https\|api" output/
```

### 8.2 Dynamic Analysis

**Frida Runtime Instrumentation:**
```javascript
// Hook function calls
Java.perform(function() {
  var MainActivity = Java.use("com.target.app.MainActivity");
  
  MainActivity.login.implementation = function(username, password) {
    console.log("Login attempt: " + username + ":" + password);
    return this.login(username, password);
  };
});

// Hook network requests
Java.perform(function() {
  var HttpURLConnection = Java.use("java.net.HttpURLConnection");
  
  HttpURLConnection.setRequestMethod.implementation = function(method) {
    console.log("HTTP Method: " + method);
    this.setRequestMethod(method);
  };
});
```

**Objection Tool:**
```bash
# Start objection
objection -g com.target.app explore

# Common commands
android hooking list classes
android hooking list methods com.target.app.MainActivity

# SSL pinning bypass
android sslpinning disable

# Root detection bypass
android root disable
```

### 8.3 Code Obfuscation Analysis

**Common Obfuscation Techniques:**
```
Obfuscation Types:
├── String Encryption
│   └── Encrypted strings in binary
├── Control Flow Flattening
│   └── Complex control structures
├── Name Obfuscation
│   └── Renamed classes/methods
├── Dead Code Injection
│   └── Unused code added
└── Anti-Debugging
    └── Debug detection
```

**Deobfuscation Tools:**
```bash
# Java/Android
procyon-decompiler application.dex
cfr application.dex

# iOS
Hopper Disassembly
IDA Pro
Ghidra

# Cross-platform
JEB Decompiler
```

---

## Module 9: Practical Exercises

### Exercise 1: API Security Testing

**Objective:** Perform comprehensive API security testing.

**Tasks:**
1. Enumerate all API endpoints
2. Test authentication mechanisms
3. Check for IDOR vulnerabilities
4. Test for mass assignment
5. Assess rate limiting

### Exercise 2: Deep Link Security Assessment

**Objective:** Test deep link security on a mobile application.

**Tasks:**
1. Enumerate all deep link schemes
2. Test parameter injection
3. Check for open redirects
4. Assess deep link authentication
5. Document all findings

### Exercise 3: Certificate Pinning Bypass

**Objective:** Bypass certificate pinning on a mobile application.

**Tasks:**
1. Identify pinning implementation
2. Select appropriate bypass technique
3. Implement bypass using Frida
4. Intercept and analyze traffic
5. Document the bypass method

---

## Module 10: Assessment Questions

### Knowledge Check

1. What are the key differences between mobile and web application security testing?

2. Explain the different types of deep links and their security implications.

3. What is certificate pinning and why is it used?

4. How does mass assignment vulnerability affect API security?

5. Explain the risks of exposing sensitive data in push notifications.

6. What are the common API versioning methods and their security considerations?

7. How does reverse engineering help in mobile security testing?

8. Explain the risks of deprecated API versions.

### Practical Assessment

1. **API Audit:** Perform a comprehensive API security assessment on a test application.

2. **Mobile Assessment:** Conduct a mobile application security assessment including both static and dynamic analysis.

3. **Tool Development:** Create a custom tool for API endpoint enumeration.

4. **Report Writing:** Document findings in a professional security assessment report.

---

## Module 11: Further Reading

### Essential Resources
- **OWASP Mobile Top 10:** Mobile Security Risks
- **OWASP API Security Top 10:** API Security Risks
- **NIST SP 800-163:** Mobile Application Security
- **Mobile Security Testing Guide (MSTG):** Comprehensive mobile testing

### Practice Platforms
- **OWASP Mobile Testing Guide:** Practical exercises
- **HackTheBox:** Mobile challenges
- **TryHackMe:** Mobile security paths
- **DVIPA:** Damn Vulnerable iOS Application

### Tools Reference
- **Frida:** Dynamic instrumentation
- **Objection:** Runtime exploration
- **Burp Suite:** API testing
- **JADX:** Android decompilation