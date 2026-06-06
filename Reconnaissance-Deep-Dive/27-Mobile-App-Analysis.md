# Mobile App Analysis for Reconnaissance

## Expert Role

You are a mobile application security specialist focused on extracting intelligence from mobile apps. You understand that mobile applications often contain hardcoded secrets, API endpoints, and internal business logic that can be leveraged for reconnaissance. You approach mobile app analysis with the understanding that apps frequently expose more information than their web counterparts, including API keys, hardcoded credentials, and internal infrastructure details. You combine reverse engineering techniques with traffic analysis to build a comprehensive picture of the target's mobile ecosystem.

## Core Concepts

### Mobile App Attack Surface

Mobile apps present a unique attack surface:

| Component | Risk | What to Look For |
|-----------|------|------------------|
| APK/IPA | High | Hardcoded secrets, API keys |
| Network Traffic | High | API endpoints, authentication |
| Local Storage | High | Stored credentials, tokens |
| Code | Medium | Business logic, algorithms |
| Permissions | Medium | Device access requirements |
| Dependencies | Medium | Third-party SDK vulnerabilities |
| Deep Links | Medium | URL scheme handling |
| Push Notifications | Low | Notification infrastructure |

### Android vs iOS Analysis

| Aspect | Android (APK) | iOS (IPA) |
|--------|---------------|-----------|
| Package Format | APK/IPA | IPA |
| Reverse Engineering | jadx, apktool | class-dump, Hopper |
| Traffic Analysis | mitmproxy, Burp | Charles, Burp |
| Certificate Pinning | Common | Common |
| Root/Jailbreak Detection | Common | Common |
| Storage | SQLite, SharedPreferences | Keychain, CoreData |
| Native Code | Native (NDK) | Native (Obj-C, Swift) |

### Common Secrets in Mobile Apps

| Secret Type | Location | Risk Level |
|-------------|----------|------------|
| API Keys | Code, strings.xml | High |
| Hardcoded Credentials | Code, config files | Critical |
| Private Keys | Assets, code | Critical |
| Backend URLs | Code, config | Medium |
| Firebase Config | google-services.json | High |
| OAuth Secrets | Code, config | High |
| Encryption Keys | Code, strings.xml | Critical |
| Third-Party SDK Keys | Code, config | Medium |

### Mobile App Reconnaissance Goals

1. **API Endpoint Discovery**: Find backend API endpoints
2. **Secret Extraction**: Extract hardcoded credentials
3. **Certificate Pinning Analysis**: Identify and bypass pinning
4. **Authentication Flow Analysis**: Understand auth mechanisms
5. **Business Logic Analysis**: Understand app functionality
6. **Third-Party SDK Identification**: Identify integrated services
7. **Infrastructure Discovery**: Find backend servers
8. **Vulnerability Identification**: Find security weaknesses

## Prerequisites

Before beginning mobile app analysis, ensure you have:
- Access to APK/IPA files (downloaded or extracted)
- Tools: jadx, apktool, dex2jar, JD-GUI
- Tools: mitmproxy, Burp Suite, Charles Proxy
- Tools: Frida, Objection, Xposed Framework
- Understanding of Android/iOS architecture
- Knowledge of common mobile security issues
- Access to a rooted Android device or jailbroken iOS device
- Familiarity with mobile app development

## Methodology

### Phase 1: APK Extraction and Decomilation

**Download APK Files**

```bash
# Using apkeep (automated download)
apkeep -a com.target.app /path/to/output

# Using apkmirror (manual download)
# Visit apkmirror.com and search for the app

# Using Google Play Store (with credentials)
gpapi googleplay --pkg com.target.app --download

# Check APK source
curl -s "https://play.google.com/store/apps/details?id=com.target.app" | grep -oP 'href="[^"]*apk[^"]*"'
```

**Decompile APK**

```bash
# Using jadx (recommended)
jadx -d decompiled_apk/ target.apk

# Using apktool
apktool d target.apk -o decompiled_apk/

# Using dex2jar and JD-GUI
d2j-dex2jar target.apk -o target-dex2jar.jar
jd-gui target-dex2jar.jar
```

**Analyze APK Structure**

```bash
# List APK contents
unzip -l target.apk

# Extract specific files
unzip target.apk AndroidManifest.xml -d extracted/
unzip target.apk classes.dex -d extracted/
unzip target.apk resources.arsc -d extracted/

# Analyze AndroidManifest.xml
cat decompiled_apk/AndroidManifest.xml | grep -i "permission\|intent-filter\|deeplink"
```

### Phase 2: Hardcoded Secret Discovery

**Search for API Keys**

```bash
# Search for common API key patterns
grep -r -i "api[_-]\?key\|apikey" decompiled_apk/ --include="*.java" --include="*.smali" --include="*.xml"

# Search for specific API key formats
grep -r "AIza[0-9A-Za-z_-]\{35\}" decompiled_apk/  # Google API
grep -r "AKIA[0-9A-Z]\{16\}" decompiled_apk/  # AWS
grep -r "sk_live_[a-zA-Z0-9]\+" decompiled_apk/  # Stripe
grep -r "ghp_[a-zA-Z0-9]\{36\}" decompiled_apk/  # GitHub
grep -r "xox[bpsa]-[a-zA-Z0-9-]\+" decompiled_apk/  # Slack
```

**Search for Credentials**

```bash
# Search for password patterns
grep -r -i "password\|passwd\|pwd" decompiled_apk/ --include="*.java" --include="*.smali"

# Search for hardcoded credentials
grep -r -E "(username|user|login).*=.*\"[^\"]+\"" decompiled_apk/ --include="*.java" --include="*.smali"
grep -r -E "(password|pass|pwd).*=.*\"[^\"]+\"" decompiled_apk/ --include="*.java" --include="*.smali"

# Search for database credentials
grep -r -i "jdbc\|mysql\|postgres\|mongodb" decompiled_apk/ --include="*.java" --include="*.smali"
```

**Search for Private Keys**

```bash
# Search for private key patterns
grep -r "BEGIN.*PRIVATE KEY" decompiled_apk/
grep -r "BEGIN RSA PRIVATE KEY" decompiled_apk/
grep -r "BEGIN DSA PRIVATE KEY" decompiled_apk/
grep -r "BEGIN EC PRIVATE KEY" decompiled_apk/

# Search for keystore files
find decompiled_apk/ -name "*.jks" -o -name "*.keystore" -o -name "*.p12"
```

### Phase 3: API Endpoint Discovery

**Extract URLs and Endpoints**

```bash
# Search for URL patterns
grep -r -E "https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" decompiled_apk/ --include="*.java" --include="*.smali"

# Search for API paths
grep -r -E "/api/[a-zA-Z0-9/-]+" decompiled_apk/ --include="*.java" --include="*.smali"

# Search for base URLs
grep -r -i "base.url\|baseurl\|api.url\|apiurl" decompiled_apk/ --include="*.java" --include="*.smali"

# Search for Retrofit/OkHttp endpoints
grep -r -E "@(GET|POST|PUT|DELETE|PATCH)\(" decompiled_apk/ --include="*.java"
grep -r -E "HttpUrl\.(parse|get)" decompiled_apk/ --include="*.java"
```

**Analyze Network Configuration**

```bash
# Check for network security config
cat decompiled_apk/res/xml/network_security_config.xml 2>/dev/null

# Check for certificate pinning
grep -r -i "certificate\|pinning\|TrustManager" decompiled_apk/ --include="*.java"

# Check for custom trust anchors
grep -r "X509TrustManager" decompiled_apk/ --include="*.java"
```

### Phase 4: Certificate Analysis

**Extract Certificates**

```bash
# Extract certificates from APK
keytool -list -v -keystore target.apk

# Extract from extracted files
find decompiled_apk/ -name "*.pem" -o -name "*.crt" -o -name "*.cer" -o -name "*.der"

# Analyze certificate
openssl x509 -in certificate.pem -text -noout
```

**Analyze Certificate Pinning**

```bash
# Search for certificate pinning implementations
grep -r -i "pin\|sha256\|sha1\|digest" decompiled_apk/ --include="*.java" --include="*.xml"

# Look for network security config
cat decompiled_apk/res/xml/network_security_config.xml

# Search for TrustManager implementations
grep -r "TrustManager" decompiled_apk/ --include="*.java" -A 10
```

### Phase 5: Traffic Analysis

**Set Up Proxy for Traffic Capture**

```bash
# Start mitmproxy
mitmproxy --listen-port 8080

# Start Burp Suite
# Configure Burp to listen on 127.0.0.1:8080

# Configure device to use proxy
# Android: Settings > WiFi > Advanced > Proxy > Manual
# iOS: Settings > WiFi > Configure Proxy > Manual
```

**Capture and Analyze Traffic**

```bash
# Capture traffic with mitmproxy
mitmdump -w traffic.mitm

# Analyze traffic with tshark
tshark -r traffic.pcap -Y "http or https" -T fields -e http.host -e http.request.uri -e http.response.code

# Extract API endpoints from traffic
tshark -r traffic.pcap -Y "http.request" -T fields -e http.request.uri | sort -u > api_endpoints.txt

# Extract authentication tokens
tshark -r traffic.pcap -Y "http.authorization" -T fields -e http.authorization
```

### Phase 6: Local Storage Analysis

**Extract Local Storage**

```bash
# Extract SQLite databases
find decompiled_apk/ -name "*.db" -o -name "*.sqlite"

# Analyze SQLite databases
sqlite3 database.db ".tables"
sqlite3 database.db "SELECT * FROM users;"

# Search for SharedPreferences
find decompiled_apk/ -name "*.xml" | xargs grep -l "shared_preferences"

# Search for Keychain (iOS)
# Use keychain_dump on jailbroken device
```

**Search for Sensitive Data**

```bash
# Search for stored credentials
grep -r -i "password\|token\|secret\|key" decompiled_apk/ --include="*.db" --include="*.xml"

# Search for user data
grep -r -i "email\|phone\|username" decompiled_apk/ --include="*.db" --include="*.xml"

# Search for session data
grep -r -i "session\|cookie\|auth" decompiled_apk/ --include="*.db" --include="*.xml"
```

### Phase 7: Reverse Engineering Basics

**Analyze Code Logic**

```bash
# Search for authentication logic
grep -r -i "login\|auth\|authenticate" decompiled_apk/ --include="*.java" -l | xargs grep -l "password\|token"

# Search for API calls
grep -r -E "Retrofit|OkHttp|Volley|HttpClient" decompiled_apk/ --include="*.java"

# Search for encryption/decryption
grep -r -E "Cipher|encrypt|decrypt|AES|RSA" decompiled_apk/ --include="*.java"

# Search for data parsing
grep -r -E "JSON|Gson|Jackson|Moshi" decompiled_apk/ --include="*.java"
```

**Analyze Business Logic**

```bash
# Search for purchase/payment logic
grep -r -i "purchase\|payment\|stripe\|paypal" decompiled_apk/ --include="*.java"

# Search for subscription logic
grep -r -i "subscription\|premium\|pro\|upgrade" decompiled_apk/ --include="*.java"

# Search for user roles/permissions
grep -r -i "admin\|role\|permission\|privilege" decompiled_apk/ --include="*.java"
```

### Phase 8: Complete Mobile App Analysis Workflow

```bash
#!/bin/bash
# mobile_analysis.sh - Complete mobile app analysis workflow

APP_PACKAGE=$1
OUTPUT_DIR="mobile_analysis_${APP_PACKAGE}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting mobile app analysis for $APP_PACKAGE"

# Step 1: Download APK
echo "[+] Downloading APK..."
apkeep -a "$APP_PACKAGE" "$OUTPUT_DIR/"

# Step 2: Decompile
echo "[+] Decompiling APK..."
jadx -d "$OUTPUT_DIR/decompiled/" "$OUTPUT_DIR/"*.apk

# Step 3: Search for secrets
echo "[+] Searching for secrets..."
grep -r -i "api[_-]\?key\|apikey" "$OUTPUT_DIR/decompiled/" --include="*.java" --include="*.xml" > "$OUTPUT_DIR/api_keys.txt"
grep -r -i "password\|secret\|token" "$OUTPUT_DIR/decompiled/" --include="*.java" --include="*.xml" > "$OUTPUT_DIR/secrets.txt"
grep -r "BEGIN.*PRIVATE KEY" "$OUTPUT_DIR/decompiled/" > "$OUTPUT_DIR/private_keys.txt"

# Step 4: Extract API endpoints
echo "[+] Extracting API endpoints..."
grep -r -E "https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" "$OUTPUT_DIR/decompiled/" --include="*.java" --include="*.xml" > "$OUTPUT_DIR/urls.txt"
grep -r -E "@(GET|POST|PUT|DELETE)" "$OUTPUT_DIR/decompiled/" --include="*.java" > "$OUTPUT_DIR/api_methods.txt"

# Step 5: Analyze network config
echo "[+] Analyzing network configuration..."
cat "$OUTPUT_DIR/decompiled/res/xml/network_security_config.xml" > "$OUTPUT_DIR/network_config.txt" 2>/dev/null
grep -r -i "certificate\|pinning" "$OUTPUT_DIR/decompiled/" --include="*.java" > "$OUTPUT_DIR/cert_pinning.txt"

# Step 6: Analyze local storage
echo "[+] Analyzing local storage..."
find "$OUTPUT_DIR/decompiled/" -name "*.db" -o -name "*.sqlite" -o -name "*.xml" | while read file; do
  if [[ $file == *.db ]] || [[ $file == *.sqlite ]]; then
    sqlite3 "$file" ".tables" >> "$OUTPUT_DIR/databases.txt"
  fi
done

# Step 7: Generate report
echo "[+] Generating report..."
echo "=== Mobile App Analysis Report ===" > "$OUTPUT_DIR/report.txt"
echo "App: $APP_PACKAGE" >> "$OUTPUT_DIR/report.txt"
echo "Date: $(date)" >> "$OUTPUT_DIR/report.txt"
echo "" >> "$OUTPUT_DIR/report.txt"
echo "API keys found: $(wc -l < "$OUTPUT_DIR/api_keys.txt")" >> "$OUTPUT_DIR/report.txt"
echo "Secrets found: $(wc -l < "$OUTPUT_DIR/secrets.txt")" >> "$OUTPUT_DIR/report.txt"
echo "Private keys found: $(wc -l < "$OUTPUT_DIR/private_keys.txt")" >> "$OUTPUT_DIR/report.txt"
echo "URLs found: $(wc -l < "$OUTPUT_DIR/urls.txt")" >> "$OUTPUT_DIR/report.txt"
echo "API methods found: $(wc -l < "$OUTPUT_DIR/api_methods.txt")" >> "$OUTPUT_DIR/report.txt"

echo "[*] Analysis complete. Results saved to $OUTPUT_DIR/"
```

## Tool Arsenal

### Decomilation Tools

**jadx (Android)**
```bash
# Decompile APK
jadx -d output/ target.apk

# Decompile with resources
jadx -d output/ --no-res target.apk
```

**apktool (Android)**
```bash
# Decompile APK
apktool d target.apk -o output/

# Recompile APK
apktool b output/ -o modified.apk
```

**Frida (Dynamic Analysis)**
```bash
# Install Frida
pip install frida-tools

# Run Frida script
frida -U -f com.target.app -l script.js

# Bypass certificate pinning
frida -U -f com.target.app -l bypass_ssl.js
```

### Traffic Analysis Tools

**mitmproxy**
```bash
# Start proxy
mitmproxy --listen-port 8080

# Capture traffic
mitmdump -w traffic.mitm

# Analyze traffic
mitmproxy -r traffic.mitm
```

**Burp Suite**
```bash
# Start Burp
# Configure browser to use proxy
# Analyze traffic in Proxy tab
```

### Custom Scripts

**Secret Extractor**
```bash
#!/bin/bash
# secret_extractor.sh - Extract secrets from decompiled APK

DECOMPILED_DIR=$1
OUTPUT="secrets_report.json"

echo '{"secrets":[' > "$OUTPUT"

# Search for API keys
grep -r -E "(AIza[0-9A-Za-z_-]{35}|AKIA[0-9A-Z]{16}|sk_live_[a-zA-Z0-9]+|ghp_[a-zA-Z0-9]{36})" "$DECOMPILED_DIR" | while read line; do
  echo "{\"type\":\"api_key\",\"value\":\"$(echo $line | grep -oE '(AIza[0-9A-Za-z_-]{35}|AKIA[0-9A-Z]{16}|sk_live_[a-zA-Z0-9]+|ghp_[a-zA-Z0-9]{36})')\",\"file\":\"$(echo $line | cut -d: -f1)\"},"
done

echo '],"scan_date":"'$(date)'"}' >> "$OUTPUT"
```

**API Endpoint Extractor**
```bash
#!/bin/bash
# api_extractor.sh - Extract API endpoints from decompiled APK

DECOMPILED_DIR=$1
OUTPUT="api_endpoints.json"

echo '{"endpoints":[' > "$OUTPUT"

# Extract URLs
grep -r -E "https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" "$DECOMPILED_DIR" --include="*.java" --include="*.xml" | grep -oE "https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[/a-zA-Z0-9.-]*" | sort -u | while read url; do
  echo "{\"url\":\"$url\"},"
done

echo '],"scan_date":"'$(date)'"}' >> "$OUTPUT"
```

## Case Studies

### Case Study 1: Hardcoded API Keys in Android App

**Discovery**: Analysis of an Android APK revealed hardcoded API keys for AWS, Stripe, and SendGrid in the source code. The keys were embedded in the Java code and could be easily extracted.

**Impact**:
1. Full AWS account compromise
2. Financial fraud via Stripe key
3. Email spoofing via SendGrid key
4. Third-party service abuse

**Methodology**:
```bash
# Decompile APK
jadx -d decompiled/ target.apk

# Search for API keys
grep -r "AKIA" decompiled/
grep -r "sk_live_" decompiled/
grep -r "SG." decompiled/
```

### Case Study 2: Certificate Pinning Bypass

**Discovery**: An Android app implemented certificate pinning to prevent traffic interception. Using Frida, the pinning was bypassed, revealing sensitive API endpoints and data in transit.

**Impact**:
1. API endpoint discovery
2. Authentication token interception
3. Sensitive data exposure
4. Man-in-the-middle attack capability

**Methodology**:
```bash
# Use Frida to bypass pinning
frida -U -f com.target.app -l bypass_ssl.js

# Capture traffic with mitmproxy
mitmdump -w traffic.mitm

# Analyze traffic
tshark -r traffic.pcap -Y "http" -T fields -e http.host -e http.request.uri
```

### Case Study 3: Firebase Configuration Exposure

**Discovery**: An Android app's google-services.json file contained Firebase configuration with database URLs and API keys, providing access to the Firebase backend.

**Impact**:
1. Access to Firebase Realtime Database
2. User data exposure
3. Ability to modify data
4. Potential for privilege escalation

### Case Study 4: Business Logic Vulnerability

**Discovery**: Reverse engineering of an iOS app revealed that premium features were only checked client-side, allowing bypass of payment requirements.

**Impact**:
1. Free access to premium features
2. Revenue loss
3. Business logic bypass
4. Potential for abuse

### Case Study 5: Hardcoded Admin Credentials

**Discovery**: An Android app contained hardcoded admin credentials that provided access to the admin panel and backend systems.

**Impact**:
1. Admin access to backend systems
2. User data manipulation
3. System configuration changes
4. Potential for data breach

## Advanced Techniques

### Dynamic Analysis with Frida

```javascript
// bypass_ssl.js - Bypass SSL certificate pinning
Java.perform(function() {
    var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
    TrustManagerImpl.verifyChain.implementation = function() {
        return arguments[0];
    };
});

// hook_api_calls.js - Hook API calls
Java.perform(function() {
    var Retrofit = Java.use('retrofit2.Retrofit');
    Retrofit.create.implementation = function() {
        console.log('Retrofit.create called');
        return this.create.apply(this, arguments);
    };
});
```

### APK Modifying

```bash
# Decompile with apktool
apktool d target.apk -o modified/

# Modify smali code
# (Edit files in modified/smali/)

# Recompile
apktool b modified/ -o modified.apk

# Sign APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore keystore.jks modified.apk alias

# Zipalign
zipalign -v 4 modified.apk final.apk
```

### Network Traffic Manipulation

```bash
# Intercept and modify traffic with mitmproxy
mitmproxy --listen-port 8080 -s modify_request.py

# modify_request.py
from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    if "api.target.com" in flow.request.pretty_host:
        flow.request.headers["Authorization"] = "Bearer stolen_token"
```

## Detection Signatures

### Known Secret Patterns in Apps

| Pattern | Platform | Description |
|---------|----------|-------------|
| `AIza[0-9A-Za-z_-]{35}` | Android/iOS | Google API Key |
| `AKIA[0-9A-Z]{16}` | Android/iOS | AWS Access Key |
| `sk_live_[a-zA-Z0-9]+` | Android/iOS | Stripe Secret Key |
| `google-services.json` | Android | Firebase Config |
| `GoogleService-Info.plist` | iOS | Firebase Config |

### Common App Files

| File | Platform | Content |
|------|----------|---------|
| AndroidManifest.xml | Android | App configuration |
| classes.dex | Android | Compiled code |
| resources.arsc | Android | Resources |
| Info.plist | iOS | App configuration |
| entitlements | iOS | App permissions |

## Impact Assessment

Mobile app analysis can reveal:
1. **Hardcoded Credentials**: API keys, passwords, tokens
2. **API Endpoints**: Backend server addresses and paths
3. **Business Logic**: Application workflows and rules
4. **Authentication Mechanisms**: How users authenticate
5. **Data Storage**: How sensitive data is stored
6. **Third-Party Integrations**: External services used
7. **Infrastructure Details**: Server configurations
8. **Vulnerability Information**: Security weaknesses

## Common Pitfalls

1. **Certificate pinning**: May prevent traffic analysis
2. **Root/jailbreak detection**: May prevent dynamic analysis
3. **Code obfuscation**: May make analysis difficult
4. **Encryption**: May protect sensitive data
5. **Legal considerations**: Reverse engineering may have legal implications
6. **App updates**: Analysis may become outdated
7. **Platform differences**: Android and iOS differ significantly
8. **Tool limitations**: Some tools may not work with all apps

## Integration with Other Recon Activities

Mobile app analysis connects to:
- **Subdomain enumeration**: Backend servers for mobile apps
- **API documentation discovery**: API endpoints used by apps
- **Cloud infrastructure discovery**: Cloud services used by apps
- **Third-party integration discovery**: SDKs and services integrated
- **Secret scanning**: Credentials in app code
- **Technology fingerprinting**: Frameworks and libraries used

## Reporting

### Mobile App Analysis Report Template

```markdown
# Mobile App Analysis Report

## Executive Summary
- Total secrets found: X
- API endpoints discovered: X
- Critical findings: X
- High-risk findings: X

## App Information
| Property | Value |
|----------|-------|
| Package Name | com.target.app |
| Version | 1.2.3 |
| Target SDK | 30 |
| Min SDK | 21 |

## Secret Findings

### API Keys
| Key Type | Value (Redacted) | Location | Risk Level |
|----------|------------------|----------|------------|
| AWS | AKIA*** | MainActivity.java | Critical |
| Stripe | sk_live_*** | PaymentService.java | Critical |

### Credentials
| Type | Value (Redacted) | Location | Risk Level |
|------|------------------|----------|------------|
| Admin | admin:*** | Config.java | Critical |

## API Endpoints
| Method | URL | Authentication | Risk Level |
|--------|-----|----------------|------------|
| POST | /api/login | Token | Medium |
| GET | /api/users | Token | High |

## Network Analysis
| Finding | Details | Risk Level |
|---------|---------|------------|
| Certificate Pinning | Implemented | Low |
| TLS Version | 1.2 | Low |

## Recommendations
1. Remove all hardcoded credentials
2. Implement proper secret management
3. Strengthen certificate pinning
4. Implement root/jailbreak detection
5. Encrypt sensitive local storage
```

## Labs

### Lab 1: Basic APK Analysis
1. Download a test APK
2. Decompile with jadx
3. Search for hardcoded secrets
4. Document all findings

### Lab 2: Traffic Analysis
1. Set up mitmproxy
2. Configure device proxy
3. Capture and analyze traffic
4. Extract API endpoints

### Lab 3: Certificate Pinning Bypass
1. Analyze certificate pinning implementation
2. Use Frida to bypass pinning
3. Capture intercepted traffic
4. Document bypass technique

### Lab 4: Dynamic Analysis
1. Set up Frida environment
2. Hook sensitive functions
3. Extract runtime data
4. Document dynamic analysis findings

## Ethics

Mobile app analysis should be conducted ethically:

1. **Authorization**: Only analyze apps you have permission to test
2. **Data Handling**: Treat discovered credentials responsibly
3. **No Exploitation**: Do not use found credentials for unauthorized access
4. **Responsible Disclosure**: Report findings through proper channels
5. **Privacy**: Respect privacy of app users
6. **Scope**: Stay within the defined scope of engagement
7. **Legal Compliance**: Ensure compliance with applicable laws
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Decompile APK
jadx -d decompiled/ target.apk

# Search for API keys
grep -r "AKIA[0-9A-Z]\{16\}" decompiled/
grep -r "sk_live_[a-zA-Z0-9]\+" decompiled/

# Extract URLs
grep -r -E "https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" decompiled/ --include="*.java"

# Capture traffic
mitmdump -w traffic.mitm

# Analyze traffic
tshark -r traffic.pcap -Y "http" -T fields -e http.host -e http.request.uri

# Bypass SSL pinning
frida -U -f com.target.app -l bypass_ssl.js

# Extract certificates
keytool -list -v -keystore target.apk

# Search for private keys
grep -r "BEGIN.*PRIVATE KEY" decompiled/

# Analyze SQLite databases
sqlite3 database.db ".tables"

# Extract Firebase config
cat decompiled/google-services.json

# Recompile APK
apktool b modified/ -o modified.apk
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore keystore.jks modified.apk alias
```
