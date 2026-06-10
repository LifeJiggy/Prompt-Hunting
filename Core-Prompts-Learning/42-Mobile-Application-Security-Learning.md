You are an elite Mobile Application Security Learning AI, specializing in teaching platform-specific mobile security assessment. Your expertise focuses on educating bug bounty hunters about iOS and Android application security, platform-specific vulnerabilities, and mobile attack techniques.

Your mission is to guide aspiring security researchers through mobile application security complexities, teaching them systematic approaches to testing mobile apps, identifying platform vulnerabilities, and developing secure mobile implementations.

Key Learning Objectives:
- **Mobile Platform Fundamentals**: Master iOS and Android application architectures
- **Reverse Engineering**: Learn mobile application reverse engineering techniques
- **Data Storage Security**: Study mobile data storage and protection mechanisms
- **Network Communication**: Assess mobile app network security and encryption
- **Authentication Security**: Test mobile authentication and session management
- **Platform Permissions**: Learn mobile permission model and security
- **Code Obfuscation**: Assess mobile code protection and reverse engineering prevention

Advanced Learning Concepts:
- **iOS Security Features**: Study iOS keychain, jailbreak detection, and app transport security
- **Android Security Model**: Learn Android permission system, sandboxing, and rooting detection
- **Certificate Pinning**: Test SSL certificate pinning implementation and bypass
- **Runtime Manipulation**: Study mobile app runtime analysis and manipulation
- **Inter-Process Communication**: Assess IPC mechanisms and security
- **Background Processing**: Test background service and push notification security
- **Device Binding**: Learn device fingerprinting and binding security

Learning Process:
1. **Mobile Fundamentals**: Understand mobile application architectures and platforms
2. **Reverse Engineering**: Learn mobile app analysis and reverse engineering techniques
3. **Data Security**: Study mobile data storage and protection mechanisms
4. **Network Security**: Assess mobile network communication and encryption
5. **Authentication**: Test mobile authentication and session management
6. **Platform Security**: Learn platform-specific security features and permissions
7. **Secure Implementation**: Develop secure mobile application practices

Teaching Methodology:
- **Mobile Labs**: Hands-on mobile application security testing exercises
- **Reverse Engineering Workshops**: Mobile app analysis and reverse engineering training
- **Data Security Exercises**: Mobile data storage security assessment labs
- **Network Tutorials**: Mobile network security testing guides
- **Authentication Labs**: Mobile authentication security testing frameworks
- **Platform Workshops**: Platform-specific security assessment exercises
- **Real-World Scenarios**: Case studies of mobile application vulnerabilities

Output Format:
- **Mobile Modules**: Structured learning units for mobile application security concepts
- **Reverse Engineering Exercises**: Practical mobile app analysis testing labs
- **Data Security Labs**: Mobile data storage security assessment exercises
- **Network Workshops**: Mobile network security testing guides
- **Authentication Tutorials**: Mobile authentication security testing frameworks
- **Platform Labs**: Platform-specific security assessment exercises
- **Case Studies**: Real-world mobile application vulnerability examples

Example Learning Query: "Teach me mobile application security from basics to expert level"

---

## MODULE 1: Android Security Architecture

### 1.1 Android Application Components

Android apps are built from four core components, each with distinct security implications:

**Activity Components:**
```xml
<!-- AndroidManifest.xml -->
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTask"
    android:permission="android.permission.INTERACT_ACROSS_USERS">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:scheme="myapp" android:host="deep" />
    </intent-filter>
</activity>
```

**Service Components:**
```xml
<service
    android:name=".SyncService"
    android:exported="true"
    android:permission="com.example.SYNC_SERVICE">
    <intent-filter>
        <action android:name="com.example.SYNC" />
    </intent-filter>
</service>
```

**Broadcast Receiver Components:**
```xml
<receiver
    android:name=".BootReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

**Content Provider Components:**
```xml
<provider
    android:name=".DataProvider"
    android:authorities="com.example.data"
    android:exported="true"
    android:grantUriPermissions="true"
    android:permission="com.example.READ_DATA">
    <grant-uri-permission android:pathPrefix="/" />
</provider>
```

### 1.2 Android Permission Model

```java
// Runtime Permission Request (Android 6.0+)
if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS)
        != PackageManager.PERMISSION_GRANTED) {
    ActivityCompat.requestPermissions(this,
        new String[]{Manifest.permission.READ_CONTACTS},
        MY_PERMISSIONS_REQUEST_READ_CONTACTS);
}

// Permission Checks
if (checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
    // Permission granted
} else {
    // Permission denied
}

// Custom Permission Declaration
<permission
    android:name="com.example.SECURE_PERMISSION"
    android:protectionLevel="signature|privileged"
    android:label="Secure Permission"
    android:description="Grants access to sensitive operations" />
```

### 1.3 Android Exported Component Enumeration

```python
import subprocess
import xml.etree.ElementTree as ET

def enumerate_exported_components(apk_path):
    """Enumerate exported components from Android APK"""
    # Decompile APK
    subprocess.run(['apktool', 'd', apk_path, '-o', 'decompiled'])
    
    # Parse AndroidManifest.xml
    tree = ET.parse('decompiled/AndroidManifest.xml')
    root = tree.getroot()
    
    exported = {
        'activities': [],
        'services': [],
        'receivers': [],
        'providers': []
    }
    
    # Find exported activities
    for activity in root.findall('.//activity'):
        exported_flag = activity.get('{http://schemas.android.com/apk/res/android}exported')
        intent_filter = activity.find('intent-filter')
        
        if exported_flag == 'true' or (exported_flag is None and intent_filter is not None):
            exported['activities'].append({
                'name': activity.get('{http://schemas.android.com/apk/res/android}name'),
                'permission': activity.get('{http://schemas.android.com/apk/res/android}permission'),
                'intent_filters': len(activity.findall('intent-filter'))
            })
    
    # Find exported services
    for service in root.findall('.//service'):
        exported_flag = service.get('{http://schemas.android.com/apk/res/android}exported')
        if exported_flag == 'true':
            exported['services'].append({
                'name': service.get('{http://schemas.android.com/apk/res/android}name'),
                'permission': service.get('{http://schemas.android.com/apk/res/android}permission')
            })
    
    # Find exported receivers
    for receiver in root.findall('.//receiver'):
        exported_flag = receiver.get('{http://schemas.android.com/apk/res/android}exported')
        if exported_flag == 'true':
            exported['receivers'].append({
                'name': receiver.get('{http://schemas.android.com/apk/res/android}name'),
                'permission': receiver.get('{http://schemas.android.com/apk/res/android}permission')
            })
    
    # Find exported providers
    for provider in root.findall('.//provider'):
        exported_flag = provider.get('{http://schemas.android.com/apk/res/android}exported')
        if exported_flag == 'true':
            exported['providers'].append({
                'name': provider.get('{http://schemas.android.com/apk/res/android}name'),
                'authorities': provider.get('{http://schemas.android.com/apk/res/android}authorities'),
                'permission': provider.get('{http://schemas.android.com/apk/res/android}permission'),
                'grant_uri_permissions': provider.get('{http://schemas.android.com/apk/res/android}grantUriPermissions')
            })
    
    return exported
```

### 1.4 Android Intent Injection Testing

```java
// Vulnerable Activity that processes untrusted intent data
public class VulnerableActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Get intent data
        Intent intent = getIntent();
        String url = intent.getStringExtra("url");
        
        // VULNERABLE: Direct use without validation
        if (url != null) {
            WebView webView = findViewById(R.id.webview);
            webView.loadUrl(url);  // Intent injection vulnerability
        }
    }
}

// Secure Activity with validation
public class SecureActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        Intent intent = getIntent();
        String action = intent.getAction();
        
        // Validate intent action
        if (!"com.example.VIEW".equals(action)) {
            finish();
            return;
        }
        
        Uri data = intent.getData();
        if (data != null) {
            // Validate URI scheme
            if (!"myapp".equals(data.getScheme())) {
                finish();
                return;
            }
            
            // Validate host
            String host = data.getHost();
            if (!"secure".equals(host)) {
                finish();
                return;
            }
            
            // Process validated data
            processSecureData(data);
        }
    }
}
```

### Practical Exercise 1.1: Android Component Enumeration

**Setup:**
1. Download a target APK from a bug bounty program
2. Decompile using apktool and jadx
3. Analyze AndroidManifest.xml

**Tasks:**
- [ ] Enumerate all exported components
- [ ] Identify unprotected exported components
- [ ] Test intent filters for injection
- [ ] Check content provider permissions
- [ ] Document attack surface

---

## MODULE 2: iOS Security Architecture

### 2.1 iOS Keychain Security

```swift
import Security

// Store sensitive data in Keychain
func saveToKeychain(key: String, value: String) -> Bool {
    guard let data = value.data(using: .utf8) else { return false }
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        kSecAttrAccessControl as String: SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            nil
        )!
    ]
    
    // Delete existing item
    SecItemDelete(query as CFDictionary)
    
    // Add new item
    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
}

// Retrieve data from Keychain
func getFromKeychain(key: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess, let data = result as? Data else {
        return nil
    }
    
    return String(data: data, encoding: .utf8)
}

// Delete from Keychain
func deleteFromKeychain(key: String) -> Bool {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    return status == errSecSuccess
}
```

### 2.2 iOS App Transport Security (ATS)

```xml
<!-- Info.plist ATS Configuration -->
<key>NSAppTransportSecurity</key>
<dict>
    <!-- Disable ATS (NOT RECOMMENDED) -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    
    <!-- Exception for specific domain -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.example.com</key>
        <dict>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
            <key>NSRequiresCertificateTransparency</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### 2.3 iOS Universal Links Testing

```swift
// Test Universal Links configuration
// Associated Domains: applinks:example.com
// apple-app-site-association file: https://example.com/.well-known/apple-app-site-association

func testUniversalLinks() {
    // Test if universal links are properly configured
    let universalLinkURL = URL(string: "https://example.com/path")!
    
    // Check if app can open universal link
    UIApplication.shared.open(universalLinkURL) { success in
        if success {
            print("Universal link handled by app")
        } else {
            print("Universal link opened in browser")
        }
    }
}

// AASA (Apple App Site Association) Validator
func validateAASA(domain: String) {
    let url = URL(string: "https://\(domain)/.well-known/apple-app-site-association")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else { return }
        
        if let aasa = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Validate AASA structure
            let applinks = aasa["applinks"] as? [String: Any]
            let apps = applinks?["apps"] as? [String]
            let details = applinks?["details"] as? [[String: Any]]
            
            print("Apps: \(apps ?? [])")
            print("Details: \(details ?? [])")
        }
    }.resume()
}
```

### Practical Exercise 2.1: iOS Security Audit

**Setup:**
1. Obtain IPA from authorized target
2. Use class-dump-z for header extraction
3. Analyze Keychain storage

**Tasks:**
- [ ] Extract Keychain items (requires jailbroken device)
- [ ] Test universal links configuration
- [ ] Analyze ATS exceptions
- [ ] Check for insecure data storage
- [ ] Document iOS-specific vulnerabilities

---

## MODULE 3: Certificate Pinning Bypass

### 3.1 Frida Certificate Pinning Bypass

```javascript
// frida-pin-bypass.js
// Bypass SSL certificate pinning on Android

Java.perform(function() {
    console.log("[*] Starting certificate pinning bypass");
    
    // Bypass TrustManager
    var X509TrustManager = Java.use('javax.net.ssl.X509TrustManager');
    var SSLContext = Java.use('javax.net.ssl.SSLContext');
    
    var TrustManager = Java.registerClass({
        name: 'com.bypass.TrustManager',
        implements: [X509TrustManager],
        methods: {
            checkClientTrusted: function(chain, authType) {},
            checkServerTrusted: function(chain, authType) {},
            getAcceptedIssuers: function() { return []; }
        }
    });
    
    var TrustManagers = [TrustManager.$new()];
    var SSLContextInit = SSLContext.init.overload(
        '[Ljavax.net.ssl.KeyManager;',
        '[Ljavax.net.ssl.TrustManager;',
        'java.security.SecureRandom'
    );
    
    SSLContextInit.implementation = function(keyManagers, trustManagers, secureRandom) {
        console.log("[+] Bypassing SSLContext.init");
        SSLContextInit.call(this, keyManagers, TrustManagers, secureRandom);
    };
    
    // Bypass OkHttp3 CertificatePinner
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function(hostname, peerCertificates) {
            console.log("[+] Bypassing OkHttp3 CertificatePinner for: " + hostname);
            return;
        };
    } catch(e) {
        console.log("[-] OkHttp3 not found");
    }
    
    // Bypass Network Security Config (Android 7+)
    try {
        var NetworkSecurityConfig = Java.use('android.security.net.config.NetworkSecurityConfig');
        // Implementation depends on specific app
    } catch(e) {
        console.log("[-] NetworkSecurityConfig bypass not implemented");
    }
});
```

### 3.2 Objection Certificate Bypass

```bash
# Start Objection with SSL pinning bypass
objection -g com.target.app explore

# Inside Objection REPL
android sslpinning disable

# Or with specific configuration
android sslpinning disable --disable-lockdown-ssl

# iOS SSL pinning bypass
ios sslpinning disable

# Monitor SSL connections
android sslpinning monitor
```

### 3.3 Burp Suite Mobile Setup

```bash
# 1. Install Burp CA certificate on device
# Export CA certificate from Burp
# Install on Android: Settings > Security > Install from storage
# Install on iOS: Install profile, then trust in Settings > General > About > Certificate Trust

# 2. Configure proxy
# Android: Settings > WiFi > Modify Network > Advanced > Proxy > Manual
# Host: 192.168.1.100 (your computer IP)
# Port: 8080

# 3. Set iptables to redirect traffic (requires root)
iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination <burp_ip>:8080
iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination <burp_ip>:8080

# 4. Use ProxyDroid for non-rooted devices
```

### Practical Exercise 3.1: Certificate Pinning Bypass Lab

**Setup:**
1. Use a target app with certificate pinning
2. Set up Burp Suite with mobile proxy
3. Practice bypassing pinning

**Tasks:**
- [ ] Identify certificate pinning implementation
- [ ] Bypass using Frida script
- [ ] Bypass using Objection
- [ ] Intercept API calls
- [ ] Document bypass techniques

---

## MODULE 4: Deep Links and Intent Injection

### 4.1 Android Deep Link Testing

```bash
# Enumerate deep links from AndroidManifest.xml
aapt dump badging app.apk | grep -E "scheme|host|pathPrefix"

# Test deep links via adb
adb shell am start -a android.intent.action.VIEW \
  -d "myapp://deep/data" \
  com.target.app

# Fuzz deep link parameters
for param in admin debug test internal; do
  adb shell am start -a android.intent.action.VIEW \
    -d "myapp://deep?$param=true" \
    com.target.app
done
```

### 4.2 iOS Universal Links Testing

```bash
# Test universal links
curl -H "apple-app-site-association: true" \
  "https://example.com/path"

# Check AASA file
curl "https://example.com/.well-known/apple-app-site-association"

# Use apple-app-site-association validator
npx aasa-validator https://example.com
```

### 4.3 Intent Injection Vulnerabilities

```java
// Vulnerable: Implicit intent with user-controlled data
Intent intent = new Intent();
intent.setAction("com.example.SHARE");
intent.putExtra("text", userInput);  // User-controlled
sendBroadcast(intent);  // Can trigger unintended receivers

// Secure: Explicit intent with validation
Intent intent = new Intent(this, TargetActivity.class);
intent.putExtra("text", sanitizeInput(userInput));
startActivity(intent);  // Explicit target
```

### Practical Exercise 4.1: Deep Link Security Audit

**Tasks:**
- [ ] Enumerate all deep links in target app
- [ ] Test for open redirect via deep links
- [ ] Test for intent injection
- [ ] Check for sensitive data exposure
- [ ] Document deep link security issues

---

## MODULE 5: Mobile API Testing

### 5.1 Mobile API Traffic Analysis

```python
import frida
import json

def monitor_api_traffic(package_name):
    """Monitor API traffic from Android app using Frida"""
    
    script_code = """
    Java.perform(function() {
        // Hook OkHttp3
        try {
            var RealCall = Java.use('okhttp3.RealCall');
            RealCall.execute.implementation = function() {
                var request = this.request();
                var url = request.url().toString();
                var method = request.method();
                var headers = request.headers().toString();
                var body = request.body() ? request.body().toString() : '';
                
                send({
                    type: 'request',
                    url: url,
                    method: method,
                    headers: headers,
                    body: body
                });
                
                var response = this.execute();
                var responseBody = response.body() ? response.body().string() : '';
                
                send({
                    type: 'response',
                    code: response.code(),
                    body: responseBody
                });
                
                return response;
            };
        } catch(e) {
            console.log('OkHttp3 not found');
        }
        
        // Hook HttpURLConnection
        try {
            var HttpURLConnection = Java.use('java.net.HttpURLConnection');
            HttpURLConnection.getOutputStream.implementation = function() {
                send({
                    type: 'request',
                    url: this.getURL().toString(),
                    method: this.getRequestMethod()
                });
                return this.getOutputStream();
            };
        } catch(e) {
            console.log('HttpURLConnection hook failed');
        }
    });
    """
    
    device = frida.get_usb_device()
    session = device.attach(package_name)
    script = session.create_script(script_code)
    
    def on_message(message, data):
        if message['type'] == 'send':
            payload = message['payload']
            if payload['type'] == 'request':
                print(f"[REQUEST] {payload['method']} {payload['url']}")
            elif payload['type'] == 'response':
                print(f"[RESPONSE] {payload['code']}")
    
    script.on('message', on_message)
    script.load()
    
    return session
```

### 5.2 Mobile Authentication Testing

```python
def test_mobile_auth_bypass(api_base_url):
    """Test mobile API authentication bypass"""
    tests = []
    
    # Test 1: Token manipulation
    response = requests.get(f'{api_base_url}/api/user/profile',
        headers={'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.invalid'})
    tests.append({
        'test': 'Invalid JWT token',
        'status': response.status_code,
        'vulnerable': response.status_code == 200
    })
    
    # Test 2: Missing authorization header
    response = requests.get(f'{api_base_url}/api/user/profile')
    tests.append({
        'test': 'Missing authorization header',
        'status': response.status_code,
        'vulnerable': response.status_code == 200
    })
    
    # Test 3: API key in parameters
    response = requests.get(f'{api_base_url}/api/user/profile',
        params={'api_key': 'test123'})
    tests.append({
        'test': 'API key in URL parameter',
        'status': response.status_code,
        'vulnerable': response.status_code == 200
    })
    
    return tests
```

### Practical Exercise 5.1: Mobile API Security Audit

**Tasks:**
- [ ] Set up intercepting proxy for mobile app
- [ ] Enumerate all API endpoints
- [ ] Test authentication mechanisms
- [ ] Check for sensitive data in responses
- [ ] Document API vulnerabilities

---

## MODULE 6: Data Storage Security

### 6.1 Android Insecure Storage Detection

```python
import os
import sqlite3
import xml.etree.ElementTree as ET

def analyze_android_storage(app_data_path):
    """Analyze Android app data storage for vulnerabilities"""
    findings = []
    
    # Check SharedPreferences
    shared_prefs_dir = os.path.join(app_data_path, 'shared_prefs')
    if os.path.exists(shared_prefs_dir):
        for filename in os.listdir(shared_prefs_dir):
            filepath = os.path.join(shared_prefs_dir, filename)
            with open(filepath, 'r') as f:
                content = f.read()
                # Check for sensitive data
                sensitive_patterns = ['password', 'token', 'secret', 'key', 'api']
                for pattern in sensitive_patterns:
                    if pattern.lower() in content.lower():
                        findings.append({
                            'type': 'Insecure SharedPreferences',
                            'file': filepath,
                            'risk': 'HIGH',
                            'detail': f'Potential sensitive data found: {pattern}'
                        })
    
    # Check SQLite databases
    databases_dir = os.path.join(app_data_path, 'databases')
    if os.path.exists(databases_dir):
        for filename in os.listdir(databases_dir):
            if filename.endswith('.db'):
                filepath = os.path.join(databases_dir, filename)
                try:
                    conn = sqlite3.connect(filepath)
                    cursor = conn.cursor()
                    
                    # Get all tables
                    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
                    tables = cursor.fetchall()
                    
                    for table in tables:
                        cursor.execute(f"SELECT * FROM {table} LIMIT 5")
                        columns = [desc[0] for desc in cursor.description]
                        
                        # Check for sensitive columns
                        for col in columns:
                            if any(s in col.lower() for s in ['password', 'token', 'secret']):
                                findings.append({
                                    'type': 'Sensitive Data in SQLite',
                                    'database': filepath,
                                    'table': table[0],
                                    'column': col,
                                    'risk': 'HIGH'
                                })
                    
                    conn.close()
                except:
                    pass
    
    # Check for world-readable files
    for root, dirs, files in os.walk(app_data_path):
        for filename in files:
            filepath = os.path.join(root, filename)
            if os.access(filepath, os.R_OK):
                # Check file permissions
                import stat
                file_stat = os.stat(filepath)
                mode = file_stat.st_mode
                if mode & stat.S_IROTH:  # World-readable
                    findings.append({
                        'type': 'World-Readable File',
                        'file': filepath,
                        'risk': 'MEDIUM',
                        'detail': f'File is world-readable (mode: {oct(mode)})'
                    })
    
    return findings
```

### 6.2 iOS Insecure Storage Detection

```swift
// Check for insecure data storage locations
func checkInsecureStorage() -> [String: Any] {
    var findings: [String: Any] = [:]
    
    // Check UserDefaults
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    let sensitiveKeys = dictionary.keys.filter { key in
        key.lowercased().contains("password") ||
        key.lowercased().contains("token") ||
        key.lowercased().contains("secret")
    }
    
    if !sensitiveKeys.isEmpty {
        findings["UserDefaults"] = Array(sensitiveKeys)
    }
    
    // Check Documents directory
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsContents = try? FileManager.default.contentsOfDirectory(atPath: documentsPath)
    
    // Check for sensitive files
    let sensitiveFiles = documentsContents?.filter { file in
        file.contains(".db") || file.contains(".plist") || file.contains("backup")
    }
    
    if let files = sensitiveFiles, !files.isEmpty {
        findings["Documents"] = files
    }
    
    // Check for Keychain items
    let keychainQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitAll
    ]
    
    var keychainItems: AnyObject?
    let status = SecItemCopyMatching(keychainQuery as CFDictionary, &keychainItems)
    
    if status == errSecSuccess, let items = keychainItems as? [[String: Any]] {
        let sensitiveItems = items.filter { item in
            if let account = item[kSecAttrAccount as String] as? String {
                return account.lowercased().contains("password") ||
                       account.lowercased().contains("token")
            }
            return false
        }
        
        if !sensitiveItems.isEmpty {
            findings["Keychain"] = sensitiveItems.count
        }
    }
    
    return findings
}
```

### Practical Exercise 6.1: Data Storage Security Audit

**Tasks:**
- [ ] Extract app data from device/emulator
- [ ] Analyze SharedPreferences/UserDefaults
- [ ] Check SQLite/CoreData databases
- [ ] Identify sensitive data in plaintext
- [ ] Document data storage vulnerabilities

---

## MODULE 7: Reverse Engineering Basics

### 7.1 APK Decompilation with jadx

```bash
# Decompile APK to Java source
jadx -d output_dir target.apk

# Decompile with debug info
jadx --show-bad-code -d output_dir target.apk

# Search for specific patterns
grep -r "password" output_dir/
grep -r "api_key" output_dir/
grep -r "http://" output_dir/
grep -r "https://" output_dir/ | grep -v "example.com"
```

### 7.2 IPA Analysis

```bash
# Extract IPA (unzip)
unzip target.ipa -d extracted/

# Analyze Info.plist
plutil -p extracted/Payload/Target.app/Info.plist

# Check entitlements
codesign -d --entitlements - extracted/Payload/Target.app

# Analyze binary
otool -L extracted/Payload/Target.app/Target  # Library dependencies
strings extracted/Payload/Target.app/Target | grep -i "http"
```

### 7.3 Dynamic Analysis with Frida

```javascript
// frida-dynamic-analysis.js
Java.perform(function() {
    // Hook all HTTP requests
    var URL = Java.use('java.net.URL');
    URL.$init.overload('java.lang.String').implementation = function(url) {
        console.log('[URL] ' + url);
        return this.$init(url);
    };
    
    // Hook SharedPreferences
    var SharedPreferencesImpl = Java.use('android.app.SharedPreferencesImpl');
    SharedPreferencesImpl.getString.implementation = function(key, defValue) {
        var value = this.getString(key, defValue);
        console.log('[SharedPreferences] getString(' + key + ') = ' + value);
        return value;
    };
    
    // Hook SQLite queries
    var SQLiteDatabase = Java.use('android.database.sqlite.SQLiteDatabase');
    SQLiteDatabase.rawQuery.implementation = function(sql, selectionArgs) {
        console.log('[SQLite] ' + sql);
        return this.rawQuery(sql, selectionArgs);
    };
});
```

### Practical Exercise 7.1: Reverse Engineering Challenge

**Tasks:**
- [ ] Decompile target APK/IPA
- [ ] Identify hardcoded credentials
- [ ] Map API endpoints from code
- [ ] Analyze cryptographic implementations
- [ ] Document security weaknesses

---

## MODULE 8: Mobile Malware Analysis

### 8.1 Static Analysis of Mobile Malware

```python
import subprocess
import json

def analyze_apk_permissions(apk_path):
    """Analyze APK permissions for malware indicators"""
    # Get permissions using aapt
    result = subprocess.run(['aapt', 'dump', 'permissions', apk_path],
                          capture_output=True, text=True)
    
    permissions = []
    high_risk = [
        'android.permission.SEND_SMS',
        'android.permission.READ_SMS',
        'android.permission.RECORD_AUDIO',
        'android.permission.CAMERA',
        'android.permission.READ_CONTACTS',
        'android.permission.READ_CALL_LOG',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.WRITE_SETTINGS',
        'android.permission.INSTALL_PACKAGES',
        'android.permission.DELETE_PACKAGES'
    ]
    
    for line in result.stdout.split('\n'):
        if 'uses-permission' in line:
            perm = line.split('name=')[1].strip('"')
            permissions.append(perm)
    
    risk_analysis = {
        'total_permissions': len(permissions),
        'high_risk_permissions': [p for p in permissions if p in high_risk],
        'suspicious_combinations': []
    }
    
    # Check for suspicious permission combinations
    if 'android.permission.SEND_SMS' in permissions and \
       'android.permission.READ_CONTACTS' in permissions:
        risk_analysis['suspicious_combinations'].append('SMS + Contacts = Potential spam/fraud')
    
    if 'android.permission.RECORD_AUDIO' in permissions and \
       'android.permission.CAMERA' in permissions:
        risk_analysis['suspicious_combinations'].append('Audio + Camera = Potential surveillance')
    
    return risk_analysis
```

### Practical Exercise 8.1: Mobile Malware Analysis Lab

**Tasks:**
- [ ] Analyze APK permissions
- [ ] Check for dynamic code loading
- [ ] Identify anti-analysis techniques
- [ ] Document malware behaviors

---

## ASSESSMENT QUESTIONS

### Section A: Multiple Choice (10 questions)

1. **Which Android component is most commonly exported by default?**
   - A) Service
   - B) Broadcast Receiver
   - C) Activity with intent-filter
   - D) Content Provider

2. **What is the primary risk of storing data in SharedPreferences without encryption?**
   - A) Performance degradation
   - B) Data leakage on rooted devices
   - C) App crashes
   - D) Memory overflow

3. **Which iOS feature provides hardware-backed key storage?**
   - A) NSUserDefaults
   - B) Keychain
   - C) CoreData
   - D) Plist files

### Section B: Practical (5 scenarios)

1. **Scenario:** You find an Android app with exported components and no permission checks.
   - Write intent commands to interact with each component
   - Document potential vulnerabilities
   - Assess impact

2. **Scenario:** An iOS app stores authentication tokens in NSUserDefaults.
   - Explain the security risk
   - Provide exploitation approach
   - Recommend secure alternatives

### Section C: Code Review (3 exercises)

1. Review AndroidManifest.xml for security misconfigurations
2. Analyze iOS Keychain implementation code
3. Assess certificate pinning implementation

---

## FURTHER READING

### Essential Resources
- OWASP Mobile Security Testing Guide (MSTG)
- OWASP Mobile Top 10 2024
- Android Security Internals (book)
- iOS Security Guide (Apple)

### Tools
- Frida / Objection
- jadx / apktool
- Ghidra / IDA Pro
- Burp Suite Mobile
- MobSF (Mobile Security Framework)

### Practice Platforms
- DVIA (Damn Vulnerable iOS App)
- InsecureBankv2 (Android)
- OWASP MSTG Crackmes
- HackTheBox Mobile Challenges

---

## MODULE 9: Advanced Mobile Exploitation

### 9.1 Android Root Detection Bypass

```javascript
// frida-root-bypass.js
Java.perform(function() {
    // Bypass root check via file existence
    var File = Java.use('java.io.File');
    File.exists.implementation = function() {
        var path = this.getAbsolutePath();
        if (path.includes('su') || path.includes('Superuser') || 
            path.includes('supersu')) {
            console.log('[Root Bypass] Blocking check: ' + path);
            return false;
        }
        return this.exists();
    };
    
    // Bypass root check via Runtime.exec
    var Runtime = Java.use('java.lang.Runtime');
    Runtime.exec.overload('[Ljava.lang.String;').implementation = function(commands) {
        var cmd = commands.join(' ');
        if (cmd.includes('su') || cmd.includes('which')) {
            console.log('[Root Bypass] Blocking command: ' + cmd);
            throw Java.use('java.io.IOException').$new('Command not found');
        }
        return this.exec(commands);
    };
    
    // Bypass SafetyNet/Play Integrity
    try {
        var SafetyNet = Java.use('com.google.android.gms.safetynet.SafetyNet');
        SafetyNet.attest.implementation = function(request, callback) {
            console.log('[SafetyNet Bypass] Blocking attestation');
            // Return fake success response
            var fakeResponse = Java.use('com.google.android.gms.safetynet.SafetyNetApi$AttestationResponse');
            // Implementation depends on specific app
        };
    } catch(e) {
        console.log('[-] SafetyNet bypass not implemented');
    }
});
```

### 9.2 iOS Jailbreak Detection Bypass

```javascript
// frida-jailbreak-bypass.js
// Bypass common jailbreak detection methods

Interceptor.attach(Module.findExportByName(null, 'strstr'), {
    onEnter: function(args) {
        this.arg0 = args[0].readUtf8String();
        this.arg1 = args[1].readUtf8String();
    },
    onLeave: function(retval) {
        var blacklisted = [
            '/Applications/Cydia.app',
            '/Library/MobileSubstrate/MobileSubstrate.dylib',
            '/bin/bash',
            '/usr/sbin/sshd',
            '/etc/apt',
            '/private/var/lib/apt/',
            '/usr/bin/ssh'
        ];
        
        if (blacklisted.some(path => this.arg0.includes(path) || this.arg1.includes(path))) {
            retval.replace(ptr(0));
        }
    }
});

// Bypass file existence checks
var NSFileManager = ObjC.NSFileManager;
Interceptor.attach(NSFileManager['- fileExistsAtPath:'].implementation, {
    onEnter: function(args) {
        this.path = ObjC.Object(args[2]).toString();
    },
    onLeave: function(retval) {
        var blacklisted = [
            '/Applications/Cydia.app',
            '/Library/MobileSubstrate/',
            '/private/var/lib/apt'
        ];
        
        if (blacklisted.some(path => this.path.includes(path))) {
            retval.replace(0);
        }
    }
});
```

### Practical Exercise 9.1: Advanced Mobile Exploitation

**Tasks:**
- [ ] Bypass root/jailbreak detection
- [ ] Bypass debugger detection
- [ ] Bypass emulator detection
- [ ] Extract encryption keys at runtime
- [ ] Document bypass techniques

---

*This module provides comprehensive mobile application security assessment training. Practice all techniques in authorized environments only.*