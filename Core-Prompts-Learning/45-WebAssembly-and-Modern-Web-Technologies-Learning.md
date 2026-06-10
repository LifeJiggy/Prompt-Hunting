You are an elite WebAssembly and Modern Web Technologies Learning AI, specializing in teaching advanced web platform security assessment. Your expertise focuses on educating bug bounty hunters about WebAssembly security, modern web APIs, and cutting-edge web technology vulnerabilities.

Your mission is to guide aspiring security researchers through modern web technology complexities, teaching them systematic approaches to testing WebAssembly modules, assessing modern web APIs, and developing secure implementations of advanced web technologies.

Key Learning Objectives:
- **WebAssembly Fundamentals**: Master WebAssembly module structure and execution model
- **WebAssembly Security**: Learn WebAssembly security boundaries and sandboxing
- **Modern Web APIs**: Study advanced web APIs and their security implications
- **Service Workers**: Assess service worker security and background processing
- **WebRTC Security**: Test WebRTC peer-to-peer communication security
- **Web Components**: Learn custom element and shadow DOM security
- **Progressive Web Apps**: Assess PWA security and offline capabilities

Advanced Learning Concepts:
- **WebAssembly Exploitation**: Study WebAssembly module manipulation and exploitation
- **Memory Management**: Learn WebAssembly memory model and buffer overflow attacks
- **API Abuse**: Test modern web API misuse and security bypasses
- **Background Processing**: Assess service worker and background task security
- **Peer-to-Peer Security**: Study WebRTC connection and data transmission security
- **Component Isolation**: Test web component security and isolation mechanisms
- **Offline Security**: Learn PWA offline storage and cache security

Learning Process:
1. **WebAssembly Fundamentals**: Understand WebAssembly architecture and execution
2. **Modern Web APIs**: Learn advanced web API security assessment
3. **Service Worker Security**: Study background processing and caching security
4. **WebRTC Assessment**: Test peer-to-peer communication security
5. **Web Components**: Assess custom element and shadow DOM security
6. **PWA Security**: Learn progressive web app security considerations
7. **Secure Implementation**: Develop secure modern web technology practices

Teaching Methodology:
- **WebAssembly Labs**: Hands-on WebAssembly module security testing exercises
- **API Workshops**: Modern web API security assessment training
- **Service Worker Exercises**: Service worker security testing labs
- **WebRTC Tutorials**: WebRTC security assessment guides
- **Component Labs**: Web component security testing frameworks
- **PWA Workshops**: Progressive web app security assessment exercises
- **Real-World Scenarios**: Case studies of modern web technology vulnerabilities

Output Format:
- **WebAssembly Modules**: Structured learning units for modern web technology concepts
- **API Exercises**: Practical modern web API security testing labs
- **Service Worker Labs**: Service worker security assessment exercises
- **WebRTC Workshops**: WebRTC security testing guides
- **Component Tutorials**: Web component security assessment frameworks
- **PWA Labs**: Progressive web app security testing exercises
- **Case Studies**: Real-world modern web technology vulnerability examples

Example Learning Query: "Teach me WebAssembly and modern web technologies security from basics to expert level"

---

## MODULE 1: WebAssembly Security

### 1.1 WebAssembly Module Structure

WebAssembly (Wasm) is a binary instruction format for a stack-based virtual machine.

**Wasm Module Structure:**
```wat
;; WebAssembly Text Format Example
(module
  (type $func_type (func (param i32) (result i32)))
  (memory (export "memory") 1)
  (func $add (type $func_type) (param $a i32) (result i32)
    local.get $a
    i32.const 1
    i32.add
  )
  (export "add" (func $add))
)
```

**JavaScript Integration:**
```javascript
// Loading and instantiating WebAssembly
async function loadWasm() {
    const response = await fetch('module.wasm');
    const buffer = await response.arrayBuffer();
    const module = await WebAssembly.compile(buffer);
    const instance = await WebAssembly.instantiate(module, {
        env: {
            memory: new WebAssembly.Memory({ initial: 1 })
        }
    });
    
    return instance;
}

// Interacting with Wasm module
async function interactWithWasm() {
    const instance = await loadWasm();
    
    // Call exported function
    const result = instance.exports.add(5);
    console.log(result); // 6
    
    // Access memory
    const memory = instance.exports.memory;
    const buffer = new Uint8Array(memory.buffer);
    
    // Read/write memory directly
    buffer[0] = 0x41; // 'A'
}
```

### 1.2 WebAssembly Vulnerability Classes

```python
# WebAssembly Security Analysis Framework
import struct
import re

class WasmAnalyzer:
    def __init__(self, wasm_path):
        self.wasm_path = wasm_path
        self.findings = []
    
    def analyze_file(self):
        """Analyze Wasm binary for vulnerabilities"""
        with open(self.wasm_path, 'rb') as f:
            content = f.read()
        
        # Check magic number
        if content[:4] != b'\x00asm':
            return {'error': 'Not a valid Wasm file'}
        
        # Analyze sections
        self.analyze_sections(content)
        
        # Check for known vulnerabilities
        self.check_vulnerabilities(content)
        
        return self.findings
    
    def analyze_sections(self, content):
        """Analyze Wasm sections"""
        offset = 8  # Skip header
        
        while offset < len(content):
            section_id = content[offset]
            section_size, offset = self.read_leb128(content, offset + 1)
            
            section_data = content[offset:offset + section_size]
            
            if section_id == 1:  # Type section
                self.analyze_type_section(section_data)
            elif section_id == 3:  # Function section
                self.analyze_function_section(section_data)
            elif section_id == 7:  # Export section
                self.analyze_export_section(section_data)
            elif section_id == 10:  # Code section
                self.analyze_code_section(section_data)
            
            offset += section_size
    
    def check_vulnerabilities(self, content):
        """Check for common Wasm vulnerabilities"""
        # Check for suspicious imports
        suspicious_imports = [
            b'env.memory',
            b'env.abort',
            b'wasi_snapshot_preview1',
            b'wasi_unstable'
        ]
        
        for import_name in suspicious_imports:
            if import_name in content:
                self.findings.append({
                    'type': 'Suspicious Import',
                    'detail': f'Found import: {import_name.decode()}',
                    'risk': 'MEDIUM'
                })
        
        # Check for large memory allocations
        memory_pattern = b'\x00\x01\x01\x01'  # Memory section header
        if memory_pattern in content:
            self.findings.append({
                'type': 'Memory Export',
                'detail': 'Memory is exported - potential memory corruption',
                'risk': 'HIGH'
            })
    
    def read_leb128(self, data, offset):
        """Read LEB128 encoded integer"""
        result = 0
        shift = 0
        while True:
            byte = data[offset]
            result |= (byte & 0x7F) << shift
            offset += 1
            if (byte & 0x80) == 0:
                break
            shift += 7
        return result, offset
```

### 1.3 WebAssembly Memory Corruption

```c
// Vulnerable C code compiled to WebAssembly
// buffer_overflow.c
#include <stdint.h>

void vulnerable_function(uint8_t *input, size_t length) {
    uint8_t buffer[64];
    
    // Vulnerable: No bounds checking
    for (size_t i = 0; i < length; i++) {
        buffer[i] = input[i];  // Buffer overflow!
    }
}

// Compile to Wasm
// emcc vulnerable.c -o vulnerable.wasm -s EXPORTED_FUNCTIONS='["_vulnerable_function"]'
```

```javascript
// Exploit WebAssembly buffer overflow
async function exploitWasm() {
    const instance = await loadWasm();
    
    const memory = instance.exports.memory;
    const buffer = new Uint8Array(memory.buffer);
    
    // Create payload that overwrites return address
    const payload = new Uint8Array(128);
    
    // Fill buffer with padding
    for (let i = 0; i < 64; i++) {
        payload[i] = 0x41;  // 'A'
    }
    
    // Overwrite return address (simulated)
    payload[64] = 0x90;  // NOP
    payload[65] = 0x90;
    payload[66] = 0x90;
    payload[67] = 0x90;
    
    // Call vulnerable function
    instance.exports.vulnerable_function(payload, payload.length);
}
```

### Practical Exercise 1.1: WebAssembly Security Analysis

**Tasks:**
- [ ] Analyze Wasm binary structure
- [ ] Identify exported functions and memory
- [ ] Test for buffer overflow vulnerabilities
- [ ] Check for suspicious imports
- [ ] Document WebAssembly security issues

---

## MODULE 2: Service Workers Security

### 2.1 Service Worker Registration Analysis

```javascript
// Analyze service worker registration
async function analyzeServiceWorker() {
    if ('serviceWorker' in navigator) {
        const registration = await navigator.serviceWorker.getRegistration();
        
        if (registration) {
            return {
                'registered': true,
                'scope': registration.scope,
                'installing': registration.installing,
                'waiting': registration.waiting,
                'active': registration.active
            };
        }
    }
    return { 'registered': false };
}

// Monitor service worker updates
function monitorServiceWorkerUpdates() {
    navigator.serviceWorker.addEventListener('controllerchange', () => {
        console.log('Service Worker updated');
    });
    
    navigator.serviceWorker.addEventListener('message', (event) => {
        console.log('Message from SW:', event.data);
    });
}
```

### 2.2 Service Worker Cache Poisoning

```python
# Service Worker cache poisoning test
import requests

def test_sw_cache_poisoning(target_url):
    """Test for service worker cache poisoning"""
    results = []
    
    # Test 1: Check if SW file is modifiable
    sw_url = f'{target_url}/sw.js'
    response = requests.get(sw_url)
    
    if response.status_code == 200:
        # Check for cache manipulation
        if 'caches' in response.text:
            results.append({
                'test': 'Cache API usage detected',
                'risk': 'MEDIUM',
                'detail': 'Service worker uses Cache API'
            })
    
    # Test 2: Check for importScripts vulnerability
    if 'importScripts' in response.text:
        results.append({
            'test': 'importScripts usage',
            'risk': 'HIGH',
            'detail': 'Service worker imports external scripts'
        })
    
    # Test 3: Check for fetch event handler
    if 'addEventListener' in response.text and 'fetch' in response.text:
        results.append({
            'test': 'Fetch event handler',
            'risk': 'MEDIUM',
            'detail': 'Service worker intercepts fetch requests'
        })
    
    return results
```

### 2.3 Service Worker Script Injection

```javascript
// Service Worker injection test
async function testSwInjection(targetOrigin) {
    // Test if attacker can register malicious service worker
    try {
        const registration = await navigator.serviceWorker.register(
            '/evil-sw.js',
            { scope: '/' }
        );
        
        return {
            'injection_possible': true,
            'registration': registration
        };
    } catch (error) {
        return {
            'injection_possible': false,
            'error': error.message
        };
    }
}

// Malicious service worker example (for testing)
// evil-sw.js
/*
self.addEventListener('fetch', (event) => {
    // Intercept all requests
    event.respondWith(
        fetch(event.request)
            .then(response => {
                // Add malicious code to responses
                const modifiedResponse = new Response(response.body, {
                    headers: response.headers
                });
                return modifiedResponse;
            })
    );
});
*/
```

### Practical Exercise 2.1: Service Worker Security Audit

**Tasks:**
- [ ] Analyze service worker registration
- [ ] Test for cache poisoning
- [ ] Check for script injection vulnerabilities
- [ ] Document service worker security issues

---

## MODULE 3: Progressive Web Apps Security

### 3.1 Web App Manifest Analysis

```python
import requests
import json

def analyze_web_app_manifest(target_url):
    """Analyze Web App Manifest for security issues"""
    manifest_url = f'{target_url}/manifest.json'
    response = requests.get(manifest_url)
    
    if response.status_code != 200:
        return {'error': 'Manifest not found'}
    
    manifest = response.json()
    
    analysis = {
        'name': manifest.get('name'),
        'short_name': manifest.get('short_name'),
        'start_url': manifest.get('start_url'),
        'display': manifest.get('display'),
        'scope': manifest.get('scope'),
        'icons': manifest.get('icons', []),
        'security_issues': []
    }
    
    # Check for security issues
    if manifest.get('start_url', '').startswith('http://'):
        analysis['security_issues'].append({
            'issue': 'Insecure start_url',
            'risk': 'HIGH',
            'detail': 'Start URL uses HTTP instead of HTTPS'
        })
    
    if not manifest.get('scope'):
        analysis['security_issues'].append({
            'issue': 'Missing scope',
            'risk': 'MEDIUM',
            'detail': 'Scope not defined - may allow URL hijacking'
        })
    
    # Check for dangerous permissions
    if 'permissions' in manifest:
        dangerous_permissions = ['camera', 'microphone', 'geolocation', 'notifications']
        for perm in manifest['permissions']:
            if any(d in perm.lower() for d in dangerous_permissions):
                analysis['security_issues'].append({
                    'issue': f'Dangerous permission: {perm}',
                    'risk': 'HIGH',
                    'detail': 'App requests sensitive permissions'
                })
    
    return analysis
```

### 3.2 PWA Offline Storage Security

```javascript
// Analyze PWA offline storage
async function analyzePwaStorage() {
    const results = {
        'localStorage': {},
        'sessionStorage': {},
        'indexedDB': {},
        'cacheStorage': {}
    };
    
    // Check localStorage
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        const value = localStorage.getItem(key);
        results.localStorage[key] = {
            'size': value.length,
            'containsSensitive': containsSensitiveData(key, value)
        };
    }
    
    // Check sessionStorage
    for (let i = 0; i < sessionStorage.length; i++) {
        const key = sessionStorage.key(i);
        const value = sessionStorage.getItem(key);
        results.sessionStorage[key] = {
            'size': value.length,
            'containsSensitive': containsSensitiveData(key, value)
        };
    }
    
    // Check Cache Storage
    if ('caches' in window) {
        const cacheNames = await caches.keys();
        for (const cacheName of cacheNames) {
            const cache = await caches.open(cacheName);
            const requests = await cache.keys();
            results.cacheStorage[cacheName] = {
                'entries': requests.length,
                'urls': requests.map(req => req.url)
            };
        }
    }
    
    return results;
}

function containsSensitiveData(key, value) {
    const sensitivePatterns = [
        /password/i,
        /token/i,
        /secret/i,
        /api[_-]?key/i,
        /session/i,
        /auth/i
    ];
    
    return sensitivePatterns.some(pattern => 
        pattern.test(key) || pattern.test(value)
    );
}
```

### Practical Exercise 3.1: PWA Security Audit

**Tasks:**
- [ ] Analyze Web App Manifest
- [ ] Check offline storage security
- [ ] Test PWA installation security
- [ ] Document PWA vulnerabilities

---

## MODULE 4: HTTP/2 Security

### 4.1 HTTP/2 Smuggling Attacks

```python
import http2
import socket

def test_http2_smuggling(target_host, target_port=443):
    """Test for HTTP/2 request smuggling"""
    results = []
    
    # Test 1: CL.TE via HTTP/2 downgrade
    h2_headers = [
        (':method', 'POST'),
        (':path', '/'),
        (':authority', target_host),
        (':scheme', 'https'),
        ('content-type', 'application/x-www-form-urlencoded'),
        ('transfer-encoding', 'chunked'),
        ('content-length', '0')
    ]
    
    h2_body = '0\r\n\r\nGET /admin HTTP/1.1\r\nHost: ' + target_host + '\r\n\r\n'
    
    try:
        # Send HTTP/2 request
        sock = socket.create_connection((target_host, target_port))
        # Implementation depends on HTTP/2 library
        results.append({
            'test': 'CL.TE via HTTP/2 downgrade',
            'status': 'Needs manual verification'
        })
    except Exception as e:
        results.append({
            'test': 'CL.TE via HTTP/2 downgrade',
            'error': str(e)
        })
    
    return results

def analyze_http2_settings(target_host):
    """Analyze HTTP/2 settings for vulnerabilities"""
    settings_url = f'https://{target_host}/'
    
    response = requests.get(settings_url, headers={
        'Upgrade': 'h2c',
        'HTTP2-Settings': 'AAEAAEAAAAAAAEAAgAAAQAAAAAAAAEAAA'
    })
    
    analysis = {
        'http2_supported': response.http_version == 'HTTP/2',
        'settings': {}
    }
    
    # Check for HTTP/2 specific headers
    h2_headers = [
        'x-http2-SETTINGS',
        'x-http2-stream-id',
        'x-http2-pseudo-header'
    ]
    
    for header in h2_headers:
        if header.lower() in [h.lower() for h in response.headers]:
            analysis['settings'][header] = response.headers.get(header)
    
    return analysis
```

### 4.2 HTTP/2 Header Injection

```python
def test_h2_header_injection(target_host):
    """Test for HTTP/2 header injection"""
    tests = []
    
    # Test 1: CRLF injection in headers
    malicious_headers = [
        ('X-Injected', 'value\r\nX-Injected-2: malicious'),
        ('X-Header', 'value\nX-Injected: malicious'),
    ]
    
    for header_name, header_value in malicious_headers:
        try:
            response = requests.get(f'https://{target_host}/',
                headers={header_name: header_value})
            
            tests.append({
                'header': header_name,
                'value': header_value,
                'status': response.status_code,
                'injected': header_name.lower() in [h.lower() for h in response.headers]
            })
        except:
            pass
    
    return tests
```

### Practical Exercise 4.1: HTTP/2 Security Audit

**Tasks:**
- [ ] Test HTTP/2 support and settings
- [ ] Test for HTTP/2 smuggling
- [ ] Check for header injection
- [ ] Document HTTP/2 security issues

---

## MODULE 5: WebRTC Security

### 5.1 WebRTC Configuration Analysis

```javascript
// Analyze WebRTC configuration
async function analyzeWebRTC() {
    const results = {
        'stun_servers': [],
        'turn_servers': [],
        'ice_candidates': [],
        'media_streams': []
    };
    
    // Create peer connection to analyze ICE configuration
    const pc = new RTCPeerConnection({
        iceServers: [
            { urls: 'stun:stun.l.google.com:19302' }
        ]
    });
    
    // Monitor ICE candidates
    pc.onicecandidate = (event) => {
        if (event.candidate) {
            results.ice_candidates.push({
                'candidate': event.candidate.candidate,
                'type': event.candidate.type,
                'protocol': event.candidate.protocol
            });
        }
    };
    
    // Create data channel to trigger ICE gathering
    const channel = pc.createDataChannel('test');
    
    // Wait for ICE gathering
    await new Promise(resolve => {
        pc.onicegatheringstatechange = () => {
            if (pc.iceGatheringState === 'complete') {
                resolve();
            }
        };
    });
    
    pc.close();
    
    return results;
}
```

### 5.2 WebRTC IP Leak Testing

```python
def test_webrtc_ip_leak():
    """Test for WebRTC IP leakage"""
    test_html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>WebRTC IP Leak Test</title>
    </head>
    <body>
        <div id="output"></div>
        <script>
            function getLocalIPs(callback) {
                var ips = [];
                var pc = new RTCPeerConnection({iceServers: []});
                pc.createDataChannel('');
                pc.createOffer().then(function(offer) {
                    return pc.setLocalDescription(offer);
                });
                
                pc.onicecandidate = function(event) {
                    if (!event || !event.candidate || !event.candidate.candidate) {
                        callback(ips);
                        return;
                    }
                    var ip = event.candidate.candidate.split(' ')[4];
                    if (ips.indexOf(ip) === -1) {
                        ips.push(ip);
                    }
                };
            }
            
            getLocalIPs(function(ips) {
                document.getElementById('output').innerHTML = 
                    'Local IPs: ' + ips.join(', ');
            });
        </script>
    </body>
    </html>
    """
    
    return {
        'test_html': test_html,
        'description': 'This page tests for WebRTC IP leakage'
    }
```

### Practical Exercise 5.1: WebRTC Security Audit

**Tasks:**
- [ ] Analyze WebRTC configuration
- [ ] Test for IP leakage
- [ ] Check STUN/TURN server security
- [ ] Document WebRTC vulnerabilities

---

## MODULE 6: Web Components Security

### 6.1 Shadow DOM Security Analysis

```javascript
// Analyze Shadow DOM security
function analyzeShadowDOM() {
    const results = {
        'shadow_roots': [],
        'isolated_elements': [],
        'security_issues': []
    };
    
    // Find all elements with shadow roots
    const allElements = document.querySelectorAll('*');
    
    allElements.forEach(element => {
        if (element.shadowRoot) {
            results.shadow_roots.push({
                'tag': element.tagName,
                'mode': element.shadowRoot.mode,
                'innerHTML': element.shadowRoot.innerHTML.length
            });
            
            // Check for security issues
            if (element.shadowRoot.mode === 'open') {
                results.security_issues.push({
                    'element': element.tagName,
                    'issue': 'Open shadow root - accessible from outside',
                    'risk': 'MEDIUM'
                });
            }
        }
    });
    
    return results;
}

// Test for DOM clobbering in Shadow DOM
function testDOMClobbering() {
    const testHTML = `
        <div id="test">
            <a id="test" name="test"></a>
        </div>
    `;
    
    const div = document.createElement('div');
    div.innerHTML = testHTML;
    document.body.appendChild(div);
    
    const element = document.getElementById('test');
    
    return {
        'clobbered': element instanceof HTMLAnchorElement,
        'original': element instanceof HTMLDivElement
    };
}
```

### 6.2 Custom Element Security

```javascript
// Analyze custom element security
class SecureCustomElement extends HTMLElement {
    constructor() {
        super();
        
        // Create shadow DOM
        this.attachShadow({ mode: 'closed' });
        
        // Set up MutationObserver to watch for changes
        this.observer = new MutationObserver((mutations) => {
            mutations.forEach((mutation) => {
                this.validateChanges(mutation);
            });
        });
    }
    
    connectedCallback() {
        // Sanitize and render content
        this.render();
        
        // Start observing
        this.observer.observe(this.shadowRoot, {
            childList: true,
            subtree: true,
            attributes: true
        });
    }
    
    render() {
        // Use safe DOM manipulation
        const template = document.createElement('template');
        template.innerHTML = `
            <style>
                :host {
                    display: block;
                    padding: 10px;
                }
            </style>
            <div class="content"></div>
        `;
        
        this.shadowRoot.appendChild(template.content.cloneNode(true));
    }
    
    validateChanges(mutation) {
        // Validate DOM changes for security
        if (mutation.type === 'childList') {
            mutation.addedNodes.forEach((node) => {
                if (node.nodeType === Node.ELEMENT_NODE) {
                    // Check for script injection
                    if (node.tagName === 'SCRIPT') {
                        node.remove();
                        console.warn('Script injection blocked');
                    }
                    
                    // Check for event handlers
                    if (node.onclick || node.onload || node.onerror) {
                        node.removeAttribute('onclick');
                        node.removeAttribute('onload');
                        node.removeAttribute('onerror');
                        console.warn('Event handler removed');
                    }
                }
            });
        }
    }
}

// Register custom element
customElements.define('secure-element', SecureCustomElement);
```

### Practical Exercise 6.1: Web Components Security Audit

**Tasks:**
- [ ] Analyze Shadow DOM usage
- [ ] Test for DOM clobbering
- [ ] Check custom element security
- [ ] Document Web Components vulnerabilities

---

## MODULE 7: Modern Web API Security

### 7.1 BroadcastChannel Security

```javascript
// Test BroadcastChannel security
function testBroadcastChannelSecurity() {
    const results = [];
    
    // Create channel
    const channel = new BroadcastChannel('test-channel');
    
    // Test 1: Origin validation
    channel.onmessage = (event) => {
        results.push({
            'test': 'Message received',
            'origin': event.origin,
            'data': event.data
        });
    };
    
    // Test 2: Send message from different context
    // This would be done in an iframe or worker
    
    return results;
}
```

### 7.2 Web Workers Security

```javascript
// Analyze Web Worker security
function analyzeWebWorkers() {
    const results = {
        'workers': [],
        'shared_workers': [],
        'service_workers': []
    };
    
    // Check for dedicated workers
    if ('Worker' in window) {
        // Test worker creation
        try {
            const blob = new Blob(['self.postMessage("test")'], 
                { type: 'application/javascript' });
            const url = URL.createObjectURL(blob);
            const worker = new Worker(url);
            
            worker.onmessage = (event) => {
                results.workers.push({
                    'type': 'dedicated',
                    'active': true
                });
            };
            
            worker.postMessage('start');
        } catch (e) {
            results.workers.push({
                'type': 'dedicated',
                'error': e.message
            });
        }
    }
    
    // Check for shared workers
    if ('SharedWorker' in window) {
        try {
            const blob = new Blob(['self.port.onmessage = (e) => self.port.postMessage("test")'], 
                { type: 'application/javascript' });
            const url = URL.createObjectURL(blob);
            const worker = new SharedWorker(url);
            
            results.shared_workers.push({
                'type': 'shared',
                'active': true
            });
        } catch (e) {
            results.shared_workers.push({
                'type': 'shared',
                'error': e.message
            });
        }
    }
    
    return results;
}
```

### 7.3 Storage API Security

```javascript
// Analyze Storage API security
async function analyzeStorageSecurity() {
    const results = {
        'localStorage': analyzeLocalStorage(),
        'sessionStorage': analyzeSessionStorage(),
        'indexedDB': await analyzeIndexedDB(),
        'cacheStorage': await analyzeCacheStorage()
    };
    
    return results;
}

function analyzeLocalStorage() {
    const items = [];
    
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        const value = localStorage.getItem(key);
        
        items.push({
            'key': key,
            'size': value.length,
            'containsSensitive': containsSensitiveData(value),
            'isAccessible': true  // LocalStorage is always accessible
        });
    }
    
    return {
        'items': items,
        'totalSize': items.reduce((sum, item) => sum + item.size, 0),
        'vulnerabilities': items.filter(item => item.containsSensitive)
    };
}

function analyzeSessionStorage() {
    const items = [];
    
    for (let i = 0; i < sessionStorage.length; i++) {
        const key = sessionStorage.key(i);
        const value = sessionStorage.getItem(key);
        
        items.push({
            'key': key,
            'size': value.length,
            'containsSensitive': containsSensitiveData(value)
        });
    }
    
    return {
        'items': items,
        'totalSize': items.reduce((sum, item) => sum + item.size, 0)
    };
}

async function analyzeIndexedDB() {
    if (!('indexedDB' in window)) {
        return { 'supported': false };
    }
    
    const databases = await indexedDB.databases();
    
    return {
        'supported': true,
        'databases': databases.map(db => ({
            'name': db.name,
            'version': db.version
        }))
    };
}

async function analyzeCacheStorage() {
    if (!('caches' in window)) {
        return { 'supported': false };
    }
    
    const cacheNames = await caches.keys();
    const caches = [];
    
    for (const name of cacheNames) {
        const cache = await caches.open(name);
        const keys = await cache.keys();
        
        caches.push({
            'name': name,
            'entries': keys.length,
            'urls': keys.map(req => req.url)
        });
    }
    
    return {
        'supported': true,
        'caches': caches
    };
}

function containsSensitiveData(value) {
    const patterns = [
        /password/i,
        /token/i,
        /secret/i,
        /api[_-]?key/i,
        /session/i,
        /auth/i,
        /credit[_-]?card/i,
        /ssn/i
    ];
    
    return patterns.some(pattern => pattern.test(value));
}
```

### Practical Exercise 7.1: Modern Web API Security Audit

**Tasks:**
- [ ] Analyze BroadcastChannel usage
- [ ] Test Web Worker security
- [ ] Check Storage API security
- [ ] Document Modern Web API vulnerabilities

---

## ASSESSMENT QUESTIONS

### Section A: Multiple Choice (10 questions)

1. **What is the primary security concern with WebAssembly?**
   - A) Performance degradation
   - B) Memory safety outside browser sandbox
   - C) Limited browser support
   - D) Difficult debugging

2. **Which service worker feature can be used for cache poisoning?**
   - A) Fetch event handler
   - B) Push notifications
   - C) Background sync
   - D) Periodic sync

3. **What is the main security risk with HTTP/2?**
   - A) Slower performance
   - B) Request smuggling via protocol downgrade
   - C) Larger payload sizes
   - D) Complex implementation

### Section B: Practical (5 scenarios)

1. **Scenario:** You find a WebAssembly module that processes user input.
   - Analyze the module for vulnerabilities
   - Test for memory corruption
   - Document potential exploits

2. **Scenario:** A Progressive Web App uses service workers for caching.
   - Test for cache poisoning
   - Check for script injection
   - Document security issues

### Section C: Code Review (3 exercises)

1. Review WebAssembly module for security flaws
2. Analyze service worker implementation
3. Assess PWA manifest configuration

---

## FURTHER READING

### Essential Resources
- WebAssembly Security (W3C)
- Service Worker specification
- PWA Security Guidelines
- HTTP/2 Security Considerations (RFC 7540)
- WebRTC Security (W3C)

### Tools
- WebAssembly Studio
- Chrome DevTools (Application tab)
- Firefox Web Console
- wabt (WebAssembly Binary Toolkit)
- sw-precache / workbox

### Practice Platforms
- WebAssembly Security CTF
- PWA Security Challenges
- HTTP/2 Test Suite
- WebRTC Samples

---

## MODULE 8: Advanced WebAssembly Exploitation

### 8.1 WebAssembly Buffer Overflow Exploitation

```python
class WasmExploit:
    def __init__(self, wasm_instance):
        self.instance = wasm_instance
        self.memory = wasm_instance.exports.memory
        self.buffer = None
    
    def setup_buffer(self, size=1024):
        """Setup buffer for exploitation"""
        self.buffer = self.memory.buffer.slice(0, size)
        return self.buffer
    
    def overflow_buffer(self, payload):
        """Overflow buffer with payload"""
        # Get buffer start address
        buffer_ptr = self.instance.exports.get_buffer_ptr()
        
        # Write payload to memory
        memory_view = new Uint8Array(self.memory.buffer)
        
        for i, byte in enumerate(payload):
            memory_view[buffer_ptr + i] = byte
        
        # Call vulnerable function
        self.instance.exports.vulnerable_function(buffer_ptr, len(payload))
    
    def leak_memory(self):
        """Leak memory contents"""
        memory_view = new Uint8Array(self.memory.buffer)
        
        # Search for sensitive data
        patterns = {
            'password': b'password',
            'token': b'token',
            'secret': b'secret',
            'key': b'key'
        }
        
        leaked_data = {}
        for name, pattern in patterns.items():
            for i in range(len(memory_view) - len(pattern)):
                if memory_view[i:i+len(pattern)] == pattern:
                    leaked_data[name] = memory_view[i:i+50].decode('utf-8', errors='ignore')
        
        return leaked_data
    
    def execute_arbitrary_code(self, shellcode):
        """Execute arbitrary code via Wasm"""
        # This is a simplified example
        # Real exploitation would be more complex
        
        buffer_ptr = self.instance.exports.get_buffer_ptr()
        memory_view = new Uint8Array(self.memory.buffer)
        
        # Write shellcode
        for i, byte in enumerate(shellcode):
            memory_view[buffer_ptr + i] = byte
        
        # Trigger code execution
        self.instance.exports.execute(buffer_ptr)
```

### Practical Exercise 8.1: Advanced WebAssembly Exploitation

**Tasks:**
- [ ] Perform buffer overflow in WebAssembly
- [ ] Leak memory contents
- [ ] Attempt code execution
- [ ] Document exploitation techniques

---

## MODULE 9: Service Worker Advanced Attacks

### 9.1 Service Worker Update Poisoning

```python
def test_sw_update_poisoning(target_url):
    """Test service worker update poisoning"""
    results = []
    
    # Check if SW updates are fetched over HTTP
    sw_url = f'{target_url}/sw.js'
    response = requests.get(sw_url, allow_redirects=True)
    
    if response.url.startswith('http://'):
        results.append({
            'vulnerability': 'Insecure SW update',
            'risk': 'HIGH',
            'detail': 'Service worker fetched over HTTP'
        })
    
    # Check for cache poisoning
    if 'caches' in response.text:
        # Look for cache manipulation patterns
        cache_patterns = [
            r'caches\.open\([\'"](.+?)[\'"]\)',
            r'cache\.put\(',
            r'cache\.add\('
        ]
        
        for pattern in cache_patterns:
            matches = re.findall(pattern, response.text)
            if matches:
                results.append({
                    'vulnerability': 'Cache manipulation',
                    'risk': 'MEDIUM',
                    'detail': f'Cache operation found: {pattern}'
                })
    
    return results
```

### Practical Exercise 9.1: Service Worker Advanced Attacks

**Tasks:**
- [ ] Test SW update poisoning
- [ ] Analyze cache manipulation
- [ ] Document advanced SW attacks

---

*This module provides comprehensive WebAssembly and modern web technology security assessment training. Practice these techniques in authorized environments only.*