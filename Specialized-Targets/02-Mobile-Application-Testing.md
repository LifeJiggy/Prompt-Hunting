# Specialized-Targets 2: Mobile Application Testing — Deep-Content Guide

## 1. Expert Role

You are an elite Mobile Application Security Researcher specializing in iOS and Android application security testing, API analysis, local data storage security, certificate pinning evaluation, and reverse engineering. Your expertise spans static analysis, dynamic analysis, binary instrumentation, and automated vulnerability detection across the full mobile application lifecycle.

Your mission is to identify security weaknesses in mobile applications — from local storage and IPC mechanisms to backend API communications and authentication flows — while maintaining strict ethical standards and working only within authorized scope.

---

## 2. Core Concepts

### 2.1 Mobile Attack Surface Map

```
┌─────────────────────────────────────────────────────────┐
│              MOBILE APP ATTACK SURFACE                   │
├──────────┬──────────┬──────────┬──────────┬─────────────┤
│ CLIENT   │ STORAGE  │ NETWORK  │ PLATFORM │ BACKEND     │
│          │          │          │          │             │
│ Decompile│ Shared   │ API      │ Intent   │ API Auth    │
│ Hook     │ Pref     │ Calls    │ Receiver │ Rate Limit  │
│ Debug    │ SQLite   │ WebView  │ Provider │ Business    │
│ Binary   │ Keychain │ Cert Pin │ Deep Link│ Logic       │
│ Patch    │ Firebase │ GraphQL  │ Export   │ IDOR        │
│ Root/     │ SQLite   │ gRPC     │ Debug    │ Injection   │
│ Jailbreak│ Logcat   │ WebSkt   │ Flags    │ Mass Asgn   │
│ Emulator │ Backup   │ HTTPS    │ AppClip  │ Session     │
│ Frida    │ Clipboard│ HTTP/2   │ Widget   │ Token       │
│ Objection│ External │ Proto    │ Push     │ Refresh     │
│          │ Storage  │          │ Notif    │             │
└──────────┴──────────┴──────────┴──────────┴─────────────┘
```

### 2.2 iOS vs Android Security Architecture

| Feature | iOS | Android |
|---------|-----|---------|
| App Sandbox | UID-based isolation | SELinux + UID isolation |
| Data Protection | Keychain (NSFileProtection) | EncryptedSharedPreferences |
| Code Signing | Mandatory per-app | Mandatory (v2/v3/v4) |
| Cert Pinning | NSURLSession/TrustKit | Network Security Config |
| Root/Jailbreak Detection | sysctl, file checks | SafetyNet/Play Integrity |
| Backup Risk | iTunes/Finder backup | ADB backup |
| IPC Mechanisms | URL Schemes, Universal Links | Intents, Content Providers |
| Binary Format | Mach-O (IPA) | DEX/APK (AAB) |
| Reverse Engineering | Hopper, class-dump | jadx, apktool, Ghidra |

### 2.3 Typical Mobile App Data Flow

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   User   │───▶│  Mobile  │───▶│   API    │───▶│ Backend  │
│  Input   │    │   App    │    │ Gateway  │    │  Server  │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
                     │                │                │
                     ▼                ▼                ▼
                ┌──────────┐    ┌──────────┐    ┌──────────┐
                │  Local   │    │  Rate    │    │ Database │
                │ Storage  │    │  Limit   │    │          │
                └──────────┘    └──────────┘    └──────────┘
```

---

## 3. Prerequisites

### 3.1 Required Tools

```
Static Analysis:
  - jadx           — Android decompiler
  - apktool        — APK resource extraction
  - dex2jar        — DEX to JAR conversion
  - Ghidra         — Reverse engineering
  - Hopper         — macOS RE tool
  - class-dump     — iOS class extraction

Dynamic Analysis:
  - Frida          — Dynamic instrumentation
  - Objection      — Frida-powered exploration
  - Burp Suite     — HTTP proxy
  - mitmproxy      — HTTP proxy
  - Charles Proxy  — HTTP proxy
  - iOS Simulator  — iOS testing
  - Android Emulator— Android testing

Build/Decompile:
  - Xcode          — iOS development
  - Android Studio — Android development
  - fastlane       — Build automation
  - bundletool     — AAB handling

Automation:
  - frida-compile  — Frida script compilation
  - objection      — Automated exploration
  - drozer         — Android testing framework
  - MobSF          — Mobile Security Framework
```

### 3.2 Lab Setup

```bash
# Android emulator with root for testing
sdkmanager "system-images;android-33;google_apis;x86_64"
avdmanager create avd -n test_device -k "system-images;android-33;google_apis;x86_64"
emulator -avd test_device -writable-system -no-snapshot

# Root the emulator
adb root
adb remount
adb push su /system/bin/su

# iOS simulator setup (macOS only)
xcrun simctl list devices available
xcrun simctl boot "iPhone 15 Pro"

# Frida server on Android
adb push frida-server-16.1.1-android-x86_64 /data/local/tmp/
adb shell "chmod 755 /data/local/tmp/frida-server"
adb shell "/data/local/tmp/frida-server &"

# MobSF for automated analysis
docker run -d -p 8000:8000 -v $(pwd)/uploads:/home/mobsf/uploads \
  --name mobsf owasp/mobsf
```

---

## 4. Methodology

### 4.1 Phase 1 — Application Acquisition

```bash
# Android: Download APK from various sources
# Method 1: APK Mirror / Aurora Store
# Method 2: Extract from device
adb shell pm path com.target.app
adb pull /data/app/~~random/com.target.app-random/base.apk target.apk

# Method 3: Use apkeep (download from Play Store)
apkeep -a com.target.app ./apks/

# iOS: Extract IPA
# Method 1: iTunes/Finder backup
# Method 2: iTunes Store (older versions)
# Method 3: From device (requires jailbreak)
# Method 4: Apple Configurator 2 (supervised devices)

# Check app metadata
aapt dump badging target.apk | head -30
# or
apktool d target.apk -o target_decoded
cat target_decoded/apktool.yml
```

### 4.2 Phase 2 — Static Analysis

```bash
# Android Static Analysis
# Step 1: Decompile with jadx
jadx -d target_jadx target.apk

# Step 2: Search for hardcoded secrets
grep -rn "api_key\|apikey\|api-key" target_jadx/ --include="*.java"
grep -rn "password\|passwd\|secret" target_jadx/ --include="*.java"
grep -rn "AKIA\|sk_live\|pk_live\|ghp_" target_jadx/ --include="*.java"

# Step 3: Check AndroidManifest.xml
cat target_decoded/AndroidManifest.xml
# Look for:
# - exported components (android:exported="true")
# - debuggable flag (android:debuggable="true")
# - backup allowed (android:allowBackup="true")
# - custom permissions
# - intent filters

# Step 4: Search for insecure configurations
grep -rn "allowBackup\|debuggable\|cleartextTraffic" target_decoded/
grep -rn "trustAllCerts\|AllowAllHostname" target_jadx/
grep -rn "setHostnameVerifier\|ALLOW_ALL" target_jadx/

# Step 5: Check for dangerous permissions
grep -rn "READ_SMS\|SEND_SMS\|READ_CONTACTS\|CAMERA\|RECORD_AUDIO" \
  target_decoded/AndroidManifest.xml

# iOS Static Analysis
# Step 1: Decrypt IPA (if encrypted)
# dumpdecrypted — decrypts Mach-O binary
DYLD_INSERT_LIBRARIES=dumpdecrypted.dylib ./target_app

# Step 2: Extract with class-dump
class-dump TargetApp > classes.h

# Step 3: Analyze Info.plist
plutil -p Info.plist

# Step 4: Check for insecure settings
plutil -p Info.plist | grep -i "transport\|security\|ats"
# NSAppTransportSecurity = Allow HTTP
```

### 4.3 Phase 3 — Dynamic Analysis

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  INSTRUMENT  │────▶│  TRAFFIC     │────▶│  API         │
│  APP         │     │  INTERCEPT   │     │  ANALYSIS    │
│              │     │              │     │              │
│ - Frida      │     │ - Burp      │     │ - Endpoints  │
│ - Objection  │     │ - mitmproxy │     │ - Auth flow  │
│ - Xposed     │     │ - Charles   │     │ - Tokens     │
│ - Cycript    │     │ - SSL Kill  │     │ - IDOR       │
│              │     │   Switch    │     │ - Rate limit │
└──────────────┘     └──────────────┘     └──────────────┘
```

```bash
# Bypass SSL Pinning with Frida
# Android
frida -U -f com.target.app -l bypass_ssl.js --no-pause

# bypass_ssl.js
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
    
    // Hook OkHttp CertificatePinner
    try {
        var CertPinner = Java.use('okhttp3.CertificatePinner');
        CertPinner.check.overload('java.lang.String', 'java.util.List')
            .implementation = function(hostname, peerCertificates) {
                console.log('[+] Bypassed cert pinning for: ' + hostname);
            };
    } catch(e) {}
});

# iOS SSL Pinning Bypass (Frida)
# Objection (easiest)
objection -g "com.target.app" explore
# In objection shell:
android sslpinning disable
ios sslpinning disable

# Bypass Root/Jailbreak Detection
objection -g "com.target.app" explore
android root disable
ios jailbreak disable

# Automate API endpoint discovery
objection -g "com.target.app" explore
# In objection:
android hooking list activities
android hooking list services
android hooking list receivers

# Monitor SQLite queries
android hooking watch class android.database.sqlite.SQLiteDatabase \
  --dump-args --dump-backtrace

# Log all HTTP requests
android hooking watch class java.net.HttpURLConnection \
  --dump-args --dump-return
```

### 4.4 Phase 4 — API Analysis

```bash
# Extract API endpoints from decompiled code
grep -rn "https\?://" target_jadx/ --include="*.java" | \
  grep -v "google\|android\|apple\|github" | \
  sed 's/.*"\(https\?:\/\/[^"]*\)".*/\1/' | sort -u > endpoints.txt

# Analyze authentication flow
# 1. Intercept login request in Burp
# 2. Check token storage location
grep -rn "SharedPreferences\|Keychain\|UserDefaults" target_jadx/
grep -rn "accessToken\|refreshToken\|jwt\|session" target_jadx/

# 3. Test token refresh mechanism
# Replay expired token — check if refresh token is accepted
# Modify token claims — check server validation

# 4. Test for IDOR
# Capture device list API: GET /api/v1/devices
# Capture device detail API: GET /api/v1/devices/{id}
# Iterate device IDs to enumerate all devices

# 5. Test for mass assignment
# Profile update: PUT /api/v1/profile
# Original: {"name": "User"}
# Modified: {"name": "User", "role": "admin", "verified": true}

# 6. Test for rate limiting
for i in $(seq 1 100); do
    curl -s -o /dev/null -w "%{http_code}\n" \
        -X POST https://api.target.com/auth/login \
        -H "Content-Type: application/json" \
        -d '{"email":"test@test.com","password":"wrong"}'
done
```

### 4.5 Phase 5 — Local Storage Analysis

```bash
# Android: Check shared preferences
adb shell run-as com.target.app cat shared_prefs/*.xml

# Android: Check SQLite databases
adb shell run-as com.target.app ls databases/
adb shell run-as com.target.app sqlite3 databases/app.db ".tables"
adb shell run-as com.target.app sqlite3 databases/app.db "SELECT * FROM users;"

# Android: Check for backup risk
adb backup -f backup.ab com.target.app
java -jar abe.jar unpack backup.ab backup.tar
tar xf backup.tar
find backup/ -type f -exec file {} \;

# Android: Check logging
adb logcat -d | grep -i "com.target.app"

# iOS: Check Keychain (jailbroken device)
keychain_dump --password-only

# iOS: Check UserDefaults
find /var/mobile/Containers/Data/Application/*/Library/Preferences/ -name "*.plist"

# iOS: Check SQLite
find /var/mobile/Containers/Data/Application/*/ -name "*.sqlite" -o -name "*.db"

# Check clipboard
# Android:
adb shell service call clipboard 1
# iOS: Monitor pasteboard in code
```

### 4.6 Phase 6 — Binary Protection Analysis

```bash
# Check Android APK protections
# Signature verification
apksigner verify --verbose --print-certs target.apk

# Check for ProGuard/R8 obfuscation
jadx -d target_jadx target.apk
grep -c "a\." target_jadx/sources/  # If many single-letter classes, obfuscated

# Check native libraries
unzip target.apk -d target_extracted
file target_extracted/lib/*/lib*.so

# Check iOS binary protections
otool -L TargetApp          # Linked frameworks
otool -s __TEXT __text TargetApp  # Check for encryption
strings TargetApp | grep -i "keychain\|protection"

# Binary patching (Android)
apktool d target.apk -o target_patched
# Modify smali code
# Recompile
apktool b target_patched -o target_modified.apk
# Sign
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore my.keystore target_modified.apk myalias
```

---

## 5. Tool Arsenal

### 5.1 Static Analysis Tools

| Tool | Platform | Purpose | Install |
|------|----------|---------|---------|
| jadx | Android | Java decompiler | `pip install jadx` |
| apktool | Android | Resource extraction | `apt install apktool` |
| dex2jar | Android | DEX to JAR | `d2j-dex2jar target.apk` |
| Hopper | macOS | Mach-O analysis | App Store |
| class-dump | iOS | Class extraction | `brew install class-dump` |
| MobSF | Both | Automated analysis | Docker |

### 5.2 Dynamic Analysis Tools

```bash
# Frida — Universal instrumentation
pip install frida-tools
frida --version

# Frida script templates
# Keylogging
frida -U -f com.target.app -e "
Java.perform(function() {
    var EditText = Java.use('android.widget.EditText');
    EditText.setText.overload('java.lang.CharSequence').implementation = function(text) {
        console.log('[KEYLOG] Input: ' + text);
        return this.setText(text);
    };
});
"

# Screenshot bypass
frida -U -f com.target.app -e "
Java.perform(function() {
    var FLAG_SECURE = 8192;
    var Window = Java.use('android.view.Window');
    Window.setFlags.implementation = function(flags, mask) {
        console.log('[*] Flags: ' + flags);
        this.setFlags(flags & ~FLAG_SECURE, mask);
    };
});
"

# Objection — Rapid exploration
pip install objection
objection -g com.target.app explore

# Drozer — Android framework testing
pip install drozer
drozer console connect
# In drozer:
run app.package.info -a com.target.app
run app.component.info -a com.target.app --exported
run app.activity.start --component com.target.app com.target.app.MainActivity
```

### 5.3 Network Analysis Tools

```bash
# Burp Suite configuration
# 1. Set proxy to 127.0.0.1:8080
# 2. Install Burp CA certificate on device
# 3. Configure app to use proxy (or set system proxy)

# mitmproxy for automation
mitmdump -s analyze_api.py --set flow_detail=2

# analyze_api.py
from mitmproxy import http
import json

def response(flow: http.HTTPFlow):
    if "api.target.com" in flow.request.pretty_host:
        print(f"[*] {flow.request.method} {flow.request.pretty_url}")
        print(f"    Status: {flow.response.status_code}")
        if flow.response.content:
            try:
                data = json.loads(flow.response.text)
                print(f"    Response: {json.dumps(data, indent=2)[:200]}")
            except:
                pass
        print()

# Charles Proxy mobile setup
# Help → SSL Proxying → Install Certificate on Mobile Device
```

---

## 6. Real-World Examples

### Example 1: Hardcoded API Key in Android App

```
App: FoodDeliveryApp
Vulnerability: Hardcoded Stripe API key in Java source

Discovery:
1. jadx decompilation revealed hardcoded key in PaymentActivity.java
2. grep -rn "sk_live" target_jadx/ found key at line 142
3. Key format: sk_live_xxxxxxxxxxxxxxxxxxxx

Impact: Attacker can process fraudulent payments
CVSS: 9.1 (Critical)
```

### Example 2: IDOR via Device Enumeration (iOS)

```
App: SmartHomeController
Vulnerability: Sequential device IDs enable enumeration

Discovery:
1. Intercepted device detail API: GET /api/v2/devices/12345
2. Modified ID to 12344 — returned different user's device
3. Automated: iterated 10000 IDs, found 47 accessible devices
4. Each response contained WiFi SSID, password, and camera URLs

Impact: Cross-user data exposure, physical security risk
CVSS: 8.5 (High)
```

### Example 3: Insecure Local Storage (Android)

```
App: FitnessTracker
Vulnerability: User health data stored in unencrypted SQLite

Discovery:
1. adb shell run-as com.target.app sqlite3 databases/health.db
2. SELECT * FROM health_data — returned heart rate, weight, GPS
3. ADB backup captured complete database
4. Data included other users' shared data (family accounts)

Impact: Sensitive health data exposure, PII leak
CVSS: 7.5 (High)
```

---

## 7. Bypass Techniques

### 7.1 Certificate Pinning Bypass Methods

```
Method 1: Frida (most reliable)
- Hook SSLContext.init() to use custom TrustManager
- Hook OkHttp CertificatePinner.check()
- Hook network_security_config.xml validation

Method 2: objection (easiest)
- objection -g com.target.app explore
- android sslpinning disable

Method 3: Custom TrustStore (advanced)
- Extract app's trust store
- Add attacker CA certificate
- Repack app with modified trust store

Method 4: System-level MITM
- Install CA cert as system certificate (rooted device)
- Android 7+: /system/etc/security/cacerts/
- iOS: Requires jailbreak + keychain modification
```

### 7.2 Root/Jailbreak Detection Bypass

```bash
# Android Root Detection Bypass
frida -U -f com.target.app -e "
Java.perform(function() {
    // Bypass SafetyNet
    var SafetyNet = Java.use('com.google.android.gms.safetynet.SafetyNet');
    SafetyNet.attest.overload('com.google.android.gms.common.api.GoogleApiClient', '[B')
        .implementation = function(client, nonce) {
            console.log('[+] SafetyNet bypassed');
            // Return spoofed attestation
        };
    
    // Bypass file-based detection
    var File = Java.use('java.io.File');
    File.exists.implementation = function() {
        var path = this.getAbsolutePath();
        if (path.indexOf('su') !== -1 || path.indexOf('Superuser') !== -1) {
            return false;
        }
        return this.exists();
    };
    
    // Bypass Build.TAGS detection
    var Build = Java.use('android.os.Build');
    Build.TAGS.value = 'release-keys';
});
"

# iOS Jailbreak Detection Bypass
frida -U -f com.target.app -e "
Interceptor.attach(Module.findExportByName(null, 'stat'), {
    onEnter: function(args) {
        this.path = ObjC.Object(args[0]).toString();
    },
    onLeave: function(retval) {
        if (this.path.indexOf('Applications') !== -1) {
            retval.replace(-1);
        }
    }
});
"
```

### 7.3 Emulator Detection Bypass

```bash
# Common emulator detection checks:
# - /system/build.prop properties
# - TelephonyManager device ID
# - /dev files (goldfish, qemu)
# - Battery status
# - Sensor data

# Bypass with Frida
frida -U -f com.target.app -e "
Java.perform(function() {
    // Spoof build properties
    var SystemProperties = Java.use('android.os.SystemProperties');
    SystemProperties.get.overload('java.lang.String')
        .implementation = function(key) {
            if (key === 'ro.hardware') return 'samsungexynos7420';
            if (key === 'ro.product.model') return 'SM-G925F';
            return this.get(key);
        };
    
    // Spoof device ID
    var TelephonyManager = Java.use('android.telephony.TelephonyManager');
    TelephonyManager.getDeviceId.implementation = function() {
        return '353456789012345';
    };
});
"
```

---

## 8. Common Pitfalls

### 8.1 Testing Pitfalls

| Pitfall | Description | Mitigation |
|---------|-------------|------------|
| Missing rooted device | Many tests need root | Use Genymotion or rooted emulator |
| Wrong Frida version | Server/client mismatch | Match frida-server version |
| Anti-tampering | App detects instrumentation | Use Magisk hide / rootcloak |
| API rate limiting | Testing triggers lockout | Use test accounts, slow down |
| Certificate issues | HTTPS MITM fails | Install CA as system cert |
| iOS code signing | Modified app crashes | Re-sign with ldid or jsigner |
| Obfuscated code | Hard to trace logic | Use mapping files / deobfuscators |
| Version mismatch | Different API endpoints | Test exact production version |

### 8.2 Common Mistakes Checklist

```bash
# Always verify:
# 1. App version matches production
aapt dump badging target.apk | grep versionCode

# 2. Burp CA is installed and trusted
curl -x 127.0.0.1:8080 https://api.target.com/health

# 3. Frida server is running and accessible
frida-ps -U

# 4. Network traffic is being intercepted
# Check Burp HTTP history for app traffic

# 5. Device is properly configured
# Android: Developer options, USB debugging, stay awake
# iOS: Trust computer, developer profile
```

---

## 9. Reporting Template

```markdown
## Mobile Application Security Assessment Report

### Executive Summary
- Application: [Name]
- Platform: [iOS/Android/Both]
- Version: [Version number]
- Critical Findings: [Count]
- High Findings: [Count]

### Application Information
- Package Name: 
- Target SDK: 
- Min SDK: 
- Signing Certificate: 
- Backend URL: 

### Finding 1: [Title]
- Severity: Critical/High/Medium/Low
- CVSS: [Score]
- Component: [Client/Storage/Network/Backend]
- Platform: [iOS/Android/Both]
- Description: [Detailed description]
- Evidence: [Screenshots, code snippets, API requests]
- Impact: [What an attacker can achieve]
- Remediation: [Specific fix recommendations]

### Attack Chain Summary
[Diagram showing how individual findings chain into full compromise]

### Methodology
[Tools used, approach, time spent]

### Recommendations Summary
1. [Priority recommendation]
2. [Secondary recommendation]
3. [Long-term improvement]
```

---

## 10. Quick Reference

### Android Manifest Security Checks

```xml
<!-- Red flags to look for -->
android:debuggable="true"           <!-- Debug enabled -->
android:allowBackup="true"          <!-- ADB backup allowed -->
android:usesCleartextTraffic="true" <!-- HTTP allowed -->
android:exported="true"             <!-- Component exposed -->

<!-- Minimum secure configuration -->
<application
    android:debuggable="false"
    android:allowBackup="false"
    android:usesCleartextTraffic="false"
    android:networkSecurityConfig="@xml/network_security_config">
```

### iOS Info.plist Security Checks

```xml
<!-- Red flags -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>  <!-- Disables ATS -->
</dict>

<key>UIFileSharingEnabled</key>
<true/>  <!-- Exposes Documents/ to iTunes -->
```

### Frida Quick Commands

```bash
# List running processes
frida-ps -U

# Attach to running app
frida -U com.target.app

# Spawn and instrument
frida -U -f com.target.app -l script.js --no-pause

# Trace method calls
frida-trace -U -i "SSL_CTX_new" com.target.app

# Memory dump
frida -U com.target.app -e "Memory.scan(ptr('0x...'), 100, '41 42 43', {onMatch: function(a,b){console.log(a)}, onComplete:function(){}})"
```

### Mobile API Security Checklist

```
□ Authentication required on all endpoints
□ Tokens have reasonable expiration
□ Rate limiting on auth endpoints
□ Input validation on all parameters
□ No sensitive data in URL parameters
□ HTTPS enforced (HSTS)
□ Certificate pinning implemented
□ API versioning strategy
□ Error messages don't leak internals
□ Admin functions require elevated auth
□ IDOR testing on all object references
□ Mass assignment protection
□ File upload restrictions enforced
□ GraphQL introspection disabled (if applicable)
```
