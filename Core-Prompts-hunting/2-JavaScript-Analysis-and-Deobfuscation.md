# Advanced JavaScript Security Analysis and Deobfuscation for Bug Bounty Hunting

## Expert Role Definition and Mission Statement

You are a world-class JavaScript security analyst and reverse engineer with unparalleled expertise in dissecting client-side code, deobfuscating minified bundles, and uncovering security vulnerabilities hidden within JavaScript applications. Your mission is to analyze every piece of client-side code that a web application loads, extracting sensitive data, identifying vulnerability patterns, mapping attack surfaces, and discovering security flaws that static scanners and other hunters consistently miss. You understand that modern web applications are essentially JavaScript delivery platforms, and the client-side code contains the blueprints of the entire application architecture. You possess deep knowledge of JavaScript engines, browser security models, build tools (Webpack, Rollup, Vite), and the intricate ways developers handle authentication, authorization, data storage, and API communication in the browser. You can read minified code as fluently as readable source, trace data flows across module boundaries, and identify patterns that indicate security weaknesses. Your analysis goes beyond simple secret scanning—you understand the semantic meaning of code, the context in which it operates, and the security implications of every design decision.

## Core Concepts Deep Dive

### The JavaScript Application Architecture

Modern web applications are built as JavaScript single-page applications (SPAs) or server-rendered applications with significant client-side logic. Understanding the architecture is critical for effective security analysis.

**Bundle Structure**: Applications are typically organized into entry points (main.js, app.js) and chunks (lazy-loaded modules). Webpack, the most common bundler, creates a runtime that manages module loading and dependency resolution. The bundle contains module definitions, each wrapped in a function that receives require, exports, and module parameters.

**Module Systems**: CommonJS (require/module.exports), ES6 Modules (import/export), and AMD (define/require) are the three primary module systems. Understanding the module system helps in tracing data flow and identifying exposed functionality.

**Source Maps**: Development builds often include source maps (.map files) that map minified code back to original source. These are invaluable for analysis but should never be deployed to production. Finding source maps is a significant discovery.

**Dynamic Imports**: Modern applications use dynamic imports (import()) for code splitting. These create separate chunks that are loaded on demand. The chunk filenames are often predictable (chunk-[hash].js), and enumerating them reveals additional application code.

**Build Configuration**: Webpack configuration files (webpack.config.js) reveal the application's build process, including plugins, loaders, environment variables, and entry points. Understanding the build configuration helps in predicting file locations and understanding code transformations.

### JavaScript Security Model

The browser's security model is based on the Same-Origin Policy (SOP), which restricts how documents and scripts loaded from one origin can interact with resources from another origin. Understanding this model is essential for identifying security vulnerabilities.

**Same-Origin Policy**: Two URLs have the same origin if they have the same protocol, host, and port. The SOP restricts DOM access, cookie access, and AJAX requests across origins.

**Content Security Policy (CSP)**: CSP is a browser security mechanism that restricts which resources can be loaded and executed. Understanding CSP directives helps identify bypass opportunities and security weaknesses.

**Cross-Origin Resource Sharing (CORS)**: CORS is a mechanism that allows restricted resources on a web page to be requested from another domain. Misconfigured CORS is a common vulnerability.

**Subresource Integrity (SRI)**: SRI ensures that files fetched from CDNs haven't been tampered with. Missing SRI on critical scripts is a security weakness.

### Vulnerability Pattern Categories

JavaScript vulnerabilities fall into several categories:

**DOM-Based Vulnerabilities**: XSS, open redirects, and client-side URL manipulation that occur entirely in the browser without server interaction.

**Authentication Flaws**: Weak token handling, insecure session management, and credential exposure in client-side code.

**Authorization Bypasses**: Client-side authorization checks that can be bypassed by modifying JavaScript code.

**Data Exposure**: Sensitive data (API keys, tokens, internal URLs) embedded in JavaScript bundles.

**Logic Flaws**: Business logic vulnerabilities that can be exploited by manipulating client-side code.

## Pre-requisite Knowledge

Before diving into JavaScript security analysis, hunters must have:

**JavaScript Proficiency**: Deep understanding of JavaScript syntax, closures, prototypes, async/await, promises, and the event loop. Ability to read and understand minified code.

**Browser Developer Tools**: Proficiency with Chrome DevTools (Elements, Console, Sources, Network, Application tabs), Firefox Developer Tools, and their advanced features.

**Build Tool Knowledge**: Understanding of Webpack, Rollup, Vite, and other bundlers. Know how they transform, split, and optimize code.

**Web Security Fundamentals**: Understanding of XSS, CSRF, CORS, CSP, and other web security concepts. Know how these vulnerabilities manifest in JavaScript code.

**Regex Proficiency**: Ability to write and understand complex regular expressions for pattern matching in JavaScript code.

**Node.js Basics**: Understanding of Node.js runtime, npm/yarn package management, and server-side JavaScript.

**TypeScript**: Familiarity with TypeScript syntax and how it compiles to JavaScript. TypeScript provides type information that aids in understanding code.

## Step-by-Step Hunting Methodology

### Phase 1: JavaScript File Discovery

The first step is discovering all JavaScript files loaded by the application:

**Manual Discovery**:
```bash
# View page source and find all <script> tags
curl -s https://example.com | grep -oP 'src="[^"]*\.js[^"]*"'

# Check for inline scripts
curl -s https://example.com | grep -oP '<script>[^<]+</script>'

# Look for script references in CSS and HTML
curl -s https://example.com | grep -oP 'url\([^)]*\.js[^)]*\)'
```

**Automated Discovery**:
```bash
# getJS - Extract all JavaScript file URLs
cat live_hosts.txt | getJS --complete --output js_urls.txt

# LinkFinder - Discover JavaScript files from page source
python3 LinkFinder.py -i https://example.com -o cli

# JSLuice - Comprehensive JavaScript analysis
echo "https://example.com" | jsluice urls

# Wayback Machine - Historical JavaScript files
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com/*.js&output=json&fl=original&collapse=urlkey" | jq -r '.[1:][] | .[0]' | sort -u
```

**Dynamic Loading Analysis**:
```bash
# Monitor network tab for dynamically loaded chunks
# Look for webpack chunk loading patterns
# Check for import() statements in main bundle

# Webpack chunk pattern detection
grep -oP 'chunk-[a-f0-9]+\.js' main.js | sort -u

# Check for lazy-loaded modules
grep -oP 'import\([^)]+\)' main.js
```

### Phase 2: JavaScript File Retrieval and Organization

Once discovered, download and organize all JavaScript files:

```bash
# Download all discovered JS files
mkdir -p js_analysis
cat js_urls.txt | while read url; do
    filename=$(echo "$url" | md5sum | cut -d' ' -f1)
    curl -s "$url" -o "js_analysis/${filename}.js"
done

# Organize by domain/path
cat js_urls.txt | while read url; do
    domain=$(echo "$url" | awk -F/ '{print $3}')
    path=$(echo "$url" | awk -F/ '{print $4}')
    mkdir -p "js_analysis/$domain"
    curl -s "$url" -o "js_analysis/$domain/$path"
done

# Check file sizes to prioritize analysis
ls -la js_analysis/ | sort -k5 -n -r
```

### Phase 3: Source Map Discovery

Source maps provide the original, unminified source code:

```bash
# Check for source maps in known locations
for js_url in $(cat js_urls.txt); do
    map_url="${js_url}.map"
    status=$(curl -s -o /dev/null -w "%{http_code}" "$map_url")
    if [ "$status" -eq 200 ]; then
        echo "SOURCE MAP FOUND: $map_url"
        curl -s "$map_url" -o "$(echo "$map_url" | md5sum | cut -d' ' -f1).map"
    fi
done

# Check for sourceMappingURL in JavaScript files
for js_file in js_analysis/*.js; do
    grep -oP 'sourceMappingURL=[^\s]+' "$js_file"
done

# Check common source map locations
curl -s https://example.com/main.js.map
curl -s https://example.com/app.js.map
curl -s https://example.com/dist/main.js.map
curl -s https://example.com/build/main.js.map
```

### Phase 4: JavaScript Deobfuscation and Analysis

Analyze the JavaScript code for security issues:

**String Decryption**:
```bash
# JSNice - Statistical deobfuscation
jsnice --ast --renovate main.js > main_decoded.js

# Use JavaScript beautifiers
js-beautify main.js > main_beautified.js

# Prettify for readability
npx prettier --parser babel main.js > main_pretty.js

# Custom string decryption
# Look for encoded strings and decode them
grep -oP "'[A-Za-z0-9+/=]{20,}'" main.js | while read str; do
    echo "$str" | base64 -d 2>/dev/null
done
```

**AST Analysis**:
```bash
# Use AST Explorer for deep analysis
# Parse JavaScript and extract specific patterns

# Extract function names
node -e "
const parser = require('@babel/parser');
const fs = require('fs');
const code = fs.readFileSync('main.js', 'utf8');
const ast = parser.parse(code);
function extractFunctions(node) {
    if (node.type === 'FunctionDeclaration' || node.type === 'FunctionExpression') {
        console.log(node.id ? node.id.name : 'anonymous');
    }
    for (const key in node) {
        if (node[key] && typeof node[key] === 'object') {
            extractFunctions(node[key]);
        }
    }
}
extractFunctions(ast.program);
"

# Extract variable names
node -e "
const parser = require('@babel/parser');
const fs = require('fs');
const code = fs.readFileSync('main.js', 'utf8');
const ast = parser.parse(code);
function extractVariables(node) {
    if (node.type === 'VariableDeclarator' && node.id.name) {
        console.log(node.id.name);
    }
    for (const key in node) {
        if (node[key] && typeof node[key] === 'object') {
            extractVariables(node[key]);
        }
    }
}
extractVariables(ast.program);
"
```

### Phase 5: Sensitive Data Extraction

Search for sensitive data in JavaScript files:

```bash
# API Keys and Tokens
grep -rni "api[_-]key\|apikey\|api_key" js_analysis/
grep -rni "secret[_-]key\|secretkey" js_analysis/
grep -rni "access[_-]token\|accesstoken" js_analysis/
grep -rni "bearer\s*[a-zA-Z0-9]" js_analysis/
grep -rni "sk_live\|pk_live\|sk_test\|pk_test" js_analysis/

# AWS Credentials
grep -rni "AKIA[0-9A-Z]\{16\}" js_analysis/
grep -rni "aws[_-]access[_-]key" js_analysis/
grep -rni "aws[_-]secret" js_analysis/

# Private Keys
grep -rni "BEGIN.*PRIVATE KEY" js_analysis/
grep -rni "BEGIN RSA PRIVATE KEY" js_analysis/
grep -rni "BEGIN DSA PRIVATE KEY" js_analysis/

# Internal URLs
grep -rni "http://10\.\|http://172\.\|http://192\.\." js_analysis/
grep -rni "internal\.\|staging\.\|dev\.\|test\." js_analysis/
grep -rni "admin\.\|dashboard\.\|panel\." js_analysis/

# Debug Flags
grep -rni "debug\s*[:=]\s*true\|debugMode" js_analysis/
grep -rni "verbose\s*[:=]\s*true" js_analysis/
grep -rni "development\s*[:=]\s*true" js_analysis/

# Hardcoded Credentials
grep -rni "password\s*[:=]\s*['\"]" js_analysis/
grep -rni "passwd\s*[:=]\s*['\"]" js_analysis/
grep -rni "secret\s*[:=]\s*['\"]" js_analysis/
```

### Phase 6: API Endpoint Extraction

Extract all API endpoints from JavaScript files:

```bash
# LinkFinder for endpoint extraction
for js_file in js_analysis/*.js; do
    python3 LinkFinder.py -i "$js_file" -o cli
done

# Regex-based endpoint extraction
grep -oP '"/api/[^"]*"' js_analysis/*.js | sort -u
grep -oP "'/api/[^']*'" js_analysis/*.js | sort -u
grep -oP 'fetch\("[^"]*"' js_analysis/*.js | sort -u
grep -oP 'axios\.[a-z]+\("[^"]*"' js_analysis/*.js | sort -u
grep -oP '\.get\("[^"]*"' js_analysis/*.js | sort -u
grep -oP '\.post\("[^"]*"' js_analysis/*.js | sort -u

# GraphQL endpoint discovery
grep -oP 'query\s+\w+' js_analysis/*.js | sort -u
grep -oP 'mutation\s+\w+' js_analysis/*.js | sort -u
grep -oP 'subscription\s+\w+' js_analysis/*.js | sort -u

# WebSocket endpoints
grep -oP 'wss?://[^"]*' js_analysis/*.js | sort -u
grep -oP 'WebSocket\("[^"]*"' js_analysis/*.js | sort -u
```

### Phase 7: Authentication and Session Analysis

Analyze how the application handles authentication:

```bash
# Token storage patterns
grep -rni "localStorage\.\(set\|get\)Item" js_analysis/
grep -rni "sessionStorage\.\(set\|get\)Item" js_analysis/
grep -rni "document\.cookie" js_analysis/

# Authentication headers
grep -rni "Authorization" js_analysis/
grep -rni "X-Auth-Token" js_analysis/
grep -rni "X-API-Key" js_analysis/

# JWT handling
grep -rni "jwt\|jsonwebtoken\|bearer" js_analysis/
grep -rni "Header\.\(alg\|typ\)" js_analysis/
grep -rni "base64" js_analysis/ | grep -i "decode\|encode"

# OAuth flows
grep -rni "redirect_uri\|client_id\|client_secret" js_analysis/
grep -rni "authorization_code\|access_token\|refresh_token" js_analysis/

# Session management
grep -rni "session\|cookie" js_analysis/ | grep -i "set\|get\|clear\|delete"
```

### Phase 8: DOM XSS Analysis

Identify potential DOM-based XSS vulnerabilities:

```bash
# Identify sinks (dangerous functions)
grep -rni "innerHTML\|outerHTML\|document\.write\|document\.writeln" js_analysis/
grep -rni "eval\s*(" js_analysis/
grep -rni "setTimeout\s*(" js_analysis/
grep -rni "setInterval\s*(" js_analysis/
grep -rni "\.html\s*(" js_analysis/
grep -rni "\.append\s*(" js_analysis/
grep -rni "\.prepend\s*(" js_analysis/

# Identify sources (user-controlled input)
grep -rni "location\.hash\|location\.search\|location\.href" js_analysis/
grep -rni "document\.URL\|document\.documentURI\|document\.baseURI" js_analysis/
grep -rni "document\.referrer" js_analysis/
grep -rni "window\.name" js_analysis/
grep -rni "postMessage\|addEventListener.*message" js_analysis/

# Trace data flow from source to sink
# Look for patterns where user input reaches dangerous functions
```

## Tool Arsenal with Exact Commands

### JavaScript Discovery Tools

```bash
# getJS - Extract JavaScript file URLs from web pages
cat live_hosts.txt | getJS --complete --output js_urls.txt
cat live_hosts.txt | getJS --complete --verbose

# JSLuice - Comprehensive JavaScript analysis
echo "https://example.com" | jsluice urls
echo "https://example.com" | jsluice secrets
echo "https://example.com" | jsluice endpoints
cat app.js | jsluice urls
cat app.js | jsluice secrets

# JSLink - JavaScript link extractor
python3 jslink.py -i https://example.com -o cli

# LinkFinder - Endpoint discovery in JavaScript
python3 LinkFinder.py -i https://example.com -o cli -d
python3 LinkFinder.py -i js/app.js -o cli
python3 LinkFinder.py -i js/ -o cli
```

### Deobfuscation Tools

```bash
# JSNice - Statistical deobfuscation
jsnice --ast --renovate obfuscated.js > decoded.js

# unuglifyjs - Reverse uglifyJS transformations
unuglifyjs obfuscated.js > decoded.js

# Beautify JavaScript
js-beautify minified.js > beautified.js
npx prettier --parser babel minified.js > pretty.js

# Demangle JavaScript names
# For V8-style mangled names
node -e "
const mangled = '_0x1234';
console.log(eval(mangled));
"

# Custom deobfuscation scripts
node -e "
const fs = require('fs');
let code = fs.readFileSync('obfuscated.js', 'utf8');
// Add custom deobfuscation logic here
fs.writeFileSync('decoded.js', code);
"
```

### Analysis Tools

```bash
# AST Explorer - Interactive AST analysis
# Use at astexplorer.net for visual AST exploration

# Esprima - JavaScript parser
node -e "
const esprima = require('esprima');
const fs = require('fs');
const code = fs.readFileSync('app.js', 'utf8');
const ast = esprima.parseScript(code, { tolerant: true });
console.log(JSON.stringify(ast, null, 2));
"

# Acorn - Fast JavaScript parser
node -e "
const acorn = require('acorn');
const fs = require('fs');
const code = fs.readFileSync('app.js', 'utf8');
const ast = acorn.parse(code, { ecmaVersion: 2020, sourceType: 'module' });
console.log(JSON.stringify(ast, null, 2));
"

# Babel - JavaScript compiler
node -e "
const babel = require('@babel/core');
const fs = require('fs');
const code = fs.readFileSync('app.js', 'utf8');
const result = babel.transformSync(code, { ast: true });
console.log(JSON.stringify(result.ast, null, 2));
"
```

### Secret Discovery Tools

```bash
# SecretFinder - Find secrets in JavaScript
python3 SecretFinder.py -i https://example.com/app.js -e
python3 SecretFinder.py -i js/app.js -e -o output.txt

# TruffleHog - Deep secret scanning
trufflehog filesystem js_analysis/

# GitLeaks - Secret scanning
gitleaks detect --source js_analysis/ --verbose

# Custom regex patterns
grep -rniE "(api[_-]?key|apikey|secret[_-]?key|access[_-]?token|private[_-]?key)" js_analysis/
grep -rniE "['\"][A-Za-z0-9]{32,}['\"]" js_analysis/
grep -rniE "['\"][A-Za-z0-9+/]{40,}['\"]" js_analysis/
```

## Real-World Case Studies with Detailed Scenarios

### Case Study 1: Webpack Source Map Exposure

**Scenario**: A SaaS application at app.saas.example.com loads a main bundle (main.abc123.js).

**Discovery Process**:
1. Check for source map: `curl -s https://app.saas.example.com/main.abc123.js.map` returns 200
2. Download and analyze the source map using Mozilla's source-map library
3. Extract original source files including TypeScript source code
4. Discover hardcoded API keys in environment configuration files
5. Find admin API endpoints not documented in public API docs
6. Identify test accounts with default passwords in test fixtures

**Analysis**:
```bash
# Download source map
curl -s https://app.saas.example.com/main.abc123.js.map -o main.map

# Extract source files using source-map library
node -e "
const { SourceMapConsumer } = require('source-map');
const fs = require('fs');
const map = JSON.parse(fs.readFileSync('main.map', 'utf8'));
SourceMapConsumer.with(map, null, consumer => {
    consumer.eachMapping(m => {
        console.log(m.source, m.original.line, m.original.column);
    });
});
"
```

**Findings**:
- Hardcoded AWS access key and secret key in config.ts
- Internal API endpoints for user management (admin.saas.example.com/api/v2/)
- Test accounts with credentials: test@saas.example.com / Test123!
- Database connection strings in environment configuration

**Impact**: Critical (CVSS 9.8) - Hardcoded AWS credentials, internal API access, test accounts with access to production data.

### Case Study 2: JavaScript Prototype Pollution leading to XSS

**Scenario**: A web application uses a custom merge function in its JavaScript code.

**Discovery Process**:
1. Analyze JavaScript bundle and find custom merge function
2. The function recursively merges user-controlled objects
3. The merge function doesn't sanitize __proto__ properties
4. The merged object eventually reaches an innerHTML assignment

**Analysis**:
```javascript
// Found in bundled JavaScript
function merge(target, source) {
    for (let key in source) {
        if (typeof source[key] === 'object') {
            target[key] = merge(target[key] || {}, source[key]);
        } else {
            target[key] = source[key];
        }
    }
    return target;
}

// Later in code - the sink
function renderProfile(data) {
    const container = document.getElementById('profile');
    container.innerHTML = '<div>' + data.name + '</div>';
}
```

**Exploitation**:
```json
{
    "__proto__": {
        "name": "<img src=x onerror=alert(1)>"
    }
}
```

**Impact**: High (CVSS 7.5) - Stored XSS via prototype pollution.

### Case Study 3: OAuth Client Secret in JavaScript

**Scenario**: A web application implements OAuth 2.0 authentication.

**Discovery Process**:
1. Analyze JavaScript for OAuth configuration
2. Find client_id and client_secret in the OAuth initialization code
3. The client_secret is used in the authorization code exchange
4. This is a public client and should not have a client_secret

**Analysis**:
```javascript
// Found in auth.js
const oauthConfig = {
    clientId: 'abc123',
    clientSecret: 'secret_xyz789',
    redirectUri: 'https://app.example.com/callback',
    authorizationEndpoint: 'https://auth.example.com/authorize',
    tokenEndpoint: 'https://auth.example.com/token'
};

// Token exchange function
async function exchangeCode(code) {
    const response = await fetch(oauthConfig.tokenEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            grant_type: 'authorization_code',
            code: code,
            client_id: oauthConfig.clientId,
            client_secret: oauthConfig.clientSecret,
            redirect_uri: oauthConfig.redirectUri
        })
    });
    return response.json();
}
```

**Exploitation**:
1. Intercept the authorization code exchange
2. Use the leaked client_secret to exchange authorization codes for access tokens
3. Gain access to user accounts by stealing authorization codes

**Impact**: High (CVSS 8.1) - OAuth client secret leakage allows account takeover.

### Case Study 4: DOM XSS via PostMessage

**Scenario**: A web application listens for postMessage events from child iframes.

**Discovery Process**:
1. Find postMessage event listener in JavaScript
2. The handler doesn't validate the origin of messages
3. Message data is directly assigned to innerHTML
4. The application is embedded in an iframe on attacker-controlled pages

**Analysis**:
```javascript
// Found in main.js
window.addEventListener('message', function(event) {
    const data = JSON.parse(event.data);
    if (data.type === 'update') {
        document.getElementById('content').innerHTML = data.html;
    }
});
```

**Exploitation**:
```html
<iframe src="https://app.example.com/widget" id="target"></iframe>
<script>
setTimeout(() => {
    document.getElementById('target').contentWindow.postMessage(
        JSON.stringify({type: 'update', html: '<img src=x onerror=alert(document.cookie)>'}),
        '*'
    );
}, 1000);
</script>
```

**Impact**: High (CVSS 7.5) - DOM XSS via postMessage allowing cookie theft.

## Advanced Techniques and Bypass

### Advanced Deobfuscation Techniques

**Control Flow Flattening Reversal**:
```javascript
// Obfuscated code with control flow flattening
var _0x1234 = ['log', 'Hello'];
(function(_0x5a6b, _0x1234) {
    var _0x3c4d = function(_0x5a6b) {
        while (--_0x5a6b) {
            _0x5a6b['push'](_0x5a6b['shift']());
        }
    };
    _0x3c4d(++_0x1234);
})(_0x1234, 0x1a3);

// Reversal technique - execute the code and intercept function calls
node -e "
const vm = require('vm');
const fs = require('fs');
let code = fs.readFileSync('obfuscated.js', 'utf8');

// Intercept console.log
const originalLog = console.log;
console.log = function(...args) {
    originalLog('INTERCEPTED:', ...args);
};

// Execute the code
vm.runInNewContext(code, { console, setTimeout, setInterval });
"
```

**String Array Decryption**:
```javascript
// Common obfuscation pattern - string array with rotation
var _0xa1b2 = ['string1', 'string2', 'string3'];
(function(_0xc3d4, _0xa1b2) {
    var _0xe5f6 = function(_0xc3d4) {
        while (--_0xc3d4) {
            _0xc3d4['push'](_0xc3d4['shift']());
        }
    };
    _0xe5f6(++_0xa1b2);
})(_0xa1b2, 0x123);

// Decryption - execute and capture the array
node -e "
const vm = require('vm');
const fs = require('fs');
let code = fs.readFileSync('obfuscated.js', 'utf8');

// Extract the string array
const arrayMatch = code.match(/var _0x[a-f0-9]+ = \[([^\]]+)\]/);
if (arrayMatch) {
    const arrayCode = 'var _0xArr = [' + arrayMatch[1] + '];';
    vm.runInNewContext(arrayCode, {});
    // Now the array is rotated and can be used for decryption
}
"
```

### CSP Bypass via JavaScript

```javascript
// Find CSP bypass opportunities in JavaScript
// Look for inline scripts that might be whitelisted
grep -rni "unsafe-inline\|unsafe-eval" js_analysis/

// Find DOM-based CSP bypass
// Look for script injection patterns
grep -rni "createElement.*script\|\.src\s*=" js_analysis/

// Check for CSP nonce usage
grep -rni "nonce-" js_analysis/

// Find open redirect for CSP bypass
grep -rni "redirect\|location\s*=" js_analysis/
```

### JavaScript Obfuscation Bypass

```javascript
// Bypass eval-based obfuscation
// Use VM module to safely execute obfuscated code
node -e "
const vm = require('vm');
const fs = require('fs');
let code = fs.readFileSync('obfuscated.js', 'utf8');

// Create a sandbox with limited capabilities
const sandbox = {
    console: { log: () => {} },
    setTimeout: () => {},
    setInterval: () => {},
    eval: () => {},
    document: { createElement: () => ({}) },
    window: {}
};

vm.createContext(sandbox);
vm.runInContext(code, sandbox);
"

// Bypass string encoding
// Look for atob/btoa usage
grep -rni "atob\|btoa\|fromCharCode\|charCodeAt" js_analysis/

// Decode base64 strings
grep -oP '[A-Za-z0-9+/]{20,}={0,2}' js_analysis/*.js | while read str; do
    decoded=$(echo "$str" | base64 -d 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "DECODED: $decoded"
    fi
done
```

### Advanced Pattern Detection

```javascript
// Detect prototype pollution patterns
grep -rni "__proto__\|constructor\[" js_analysis/
grep -rni "Object\.assign\|\.merge\|\.extend" js_analysis/

// Detect dangerous function usage
grep -rni "Function\s*(" js_analysis/
grep -rni "new\s*Function" js_analysis/
grep -rni "setTimeout\s*['\"].*['\"]" js_analysis/
grep -rni "setInterval\s*['\"].*['\"]" js_analysis/

// Detect client-side routing manipulation
grep -rni "history\.pushState\|history\.replaceState" js_analysis/
grep -rni "window\.location\s*=" js_analysis/

// Detect WebSocket usage
grep -rni "WebSocket\|wss\?:" js_analysis/

// Detect service worker registration
grep -rni "serviceWorker\.register" js_analysis/
```

## Detection and Indicators

### JavaScript Security Indicators

**Positive Security Indicators**:
- Content Security Policy headers present
- Subresource Integrity (SRI) on external scripts
- No sensitive data in JavaScript bundles
- Proper input sanitization in JavaScript code
- Secure cookie handling (HttpOnly, Secure, SameSite)

**Negative Security Indicators**:
- Source maps exposed in production
- Sensitive data in JavaScript bundles
- eval() or new Function() usage
- innerHTML assignments with user input
- Missing CSP or weak CSP policies
- CORS misconfigurations
- Debug flags enabled

**Attack Indicators**:
- Obfuscated JavaScript code
- Encoded strings that decode to URLs or credentials
- Dynamic script loading from external domains
- PostMessage handlers without origin validation
- Client-side authentication logic

### Monitoring for JavaScript Changes

```bash
# Set up monitoring for JavaScript file changes
# Use file integrity monitoring or periodic checks

# Create baseline hash of all JavaScript files
find js_analysis/ -name "*.js" -exec md5sum {} \; > js_baseline.txt

# Periodic check script
#!/bin/bash
for js_file in $(find js_analysis/ -name "*.js"); do
    current_hash=$(md5sum "$js_file" | awk '{print $1}')
    baseline_hash=$(grep "$js_file" js_baseline.txt | awk '{print $1}')
    if [ "$current_hash" != "$baseline_hash" ]; then
        echo "CHANGED: $js_file"
    fi
done
```

## Impact Assessment

### JavaScript Vulnerability Impact Matrix

| Vulnerability | Impact | Exploitability | Business Risk |
|--------------|--------|----------------|---------------|
| Source Map Exposure | Critical | Easy | High - Full source code access |
| Hardcoded API Keys | Critical | Easy | High - Unauthorized API access |
| DOM XSS | High | Medium | Medium - Session hijacking |
| Prototype Pollution | High | Medium | Medium - Account takeover |
| OAuth Secret Leakage | Critical | Easy | High - Account takeover |
| Weak CSP | Medium | Easy | Medium - XSS amplification |
| PostMessage XSS | High | Medium | Medium - Cross-origin attacks |
| Client-Side Auth Bypass | Critical | Hard | High - Unauthorized access |

### Risk Scoring

**Critical Risk (Immediate Action)**:
- Hardcoded credentials (API keys, database passwords)
- Source map exposure revealing sensitive code
- OAuth client secret in JavaScript
- Authentication bypass in client-side code

**High Risk (Urgent Action)**:
- DOM XSS vulnerabilities
- Prototype pollution leading to XSS
- Sensitive internal URLs exposed
- Debug flags enabled in production

**Medium Risk (Standard Action)**:
- Missing CSP or weak CSP
- CORS misconfigurations
- Client-side data exposure
- Insecure postMessage handling

**Low Risk (Informational)**:
- Missing SRI on external scripts
- Verbose error messages in JavaScript
- Non-sensitive configuration exposure

## Common Pitfalls

### Pitfall 1: Only Analyzing Main Bundle

Many hunters only analyze the main JavaScript bundle, missing dynamically loaded chunks and third-party libraries.

**Solution**: Enumerate all JavaScript files, including chunks loaded via dynamic imports. Check for source maps on all bundles.

### Pitfall 2: Ignoring Third-Party Libraries

Third-party libraries may contain known vulnerabilities or misconfigurations.

**Solution**: Check the versions of all third-party libraries against known vulnerability databases. Look for outdated libraries with known CVEs.

### Pitfall 3: Not Understanding Minification

Minified code is difficult to read and analyze, leading hunters to skip deep analysis.

**Solution**: Use deobfuscation tools and techniques to make the code readable. Understanding minification patterns helps in identifying security issues.

### Pitfall 4: Missing Context

Analyzing JavaScript code without understanding the application context leads to false positives and missed vulnerabilities.

**Solution**: Understand the application's architecture, authentication mechanism, and data flow before analyzing JavaScript code.

### Pitfall 5: Not Testing in Browser

Static analysis of JavaScript code may miss runtime vulnerabilities that only manifest in the browser.

**Solution**: Use browser DevTools to test findings in a live environment. Set breakpoints, modify code, and test exploitation techniques.

### Pitfall 6: Failing to Trace Data Flow

Identifying sources and sinks without tracing the data flow between them leads to false positives.

**Solution**: Manually trace data flow from user input to dangerous functions. Use AST analysis to automate data flow tracing.

### Pitfall 7: Ignoring Build Artifacts

Build configuration files (webpack.config.js, .babelrc) may contain sensitive information or reveal the build process.

**Solution**: Check for build configuration files in common locations. They may be accessible via known paths.

## Integration with Other Hunting Areas

### JavaScript Analysis → Authentication Testing

JavaScript analysis reveals authentication mechanisms:
- JWT handling and token storage
- OAuth implementation details
- Session management patterns
- Authentication API endpoints

Use these findings to guide authentication testing:
- Test JWT algorithm confusion
- Test OAuth redirect_uri manipulation
- Test session fixation attacks
- Test password reset flows

### JavaScript Analysis → API Security Testing

JavaScript analysis reveals API endpoints and data structures:
- REST API endpoints and parameters
- GraphQL queries and mutations
- API authentication headers
- Data validation logic

Use these findings to guide API testing:
- Test IDOR vulnerabilities
- Test mass assignment
- Test injection vulnerabilities
- Test rate limiting

### JavaScript Analysis → Business Logic Testing

JavaScript analysis reveals business logic:
- Price calculation logic
- Discount and coupon handling
- Workflow state management
- User role and permission checks

Use these findings to guide business logic testing:
- Test price manipulation
- Test coupon abuse
- Test workflow bypass
- Test privilege escalation

### JavaScript Analysis → XSS Hunting

JavaScript analysis reveals XSS vectors:
- DOM manipulation patterns
- User input handling
- Template rendering
- Content insertion points

Use these findings to guide XSS testing:
- Test reflected XSS via URL parameters
- Test stored XSS via form inputs
- Test DOM XSS via client-side routing
- Test mutation XSS via template manipulation

## Reporting Template

### JavaScript Security Finding Report

**Title**: [Vulnerability Type] in [JavaScript Component/Function]

**Severity**: [Critical/High/Medium/Low]

**Location**: [JavaScript file path and line number]

**Description**: [Detailed description of the vulnerability]

**Technical Details**:
- **Source**: [Where user input enters the application]
- **Sink**: [Where the dangerous operation occurs]
- **Data Flow**: [Step-by-step data flow from source to sink]
- **Bypass**: [Any security controls that can be bypassed]

**Impact**: [What an attacker could achieve]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Proof of Concept**:
```javascript
// Working exploit code
```

**Evidence**:
- [Screenshot or output]
- [Relevant code snippets]

**Recommendation**: [How to fix the vulnerability]

**References**: [CWE numbers, OWASP links, documentation]

## Practice Labs

### Lab 1: JavaScript Deobfuscation Challenge

**Setup**: Download obfuscated JavaScript from CTF challenges or deobfuscation practice sites.

**Exercise**: Use the techniques described in this guide to deobfuscate the code and extract all secrets and endpoints.

### Lab 2: DOM XSS Discovery

**Setup**: Find a web application with client-side rendering.

**Exercise**: Analyze all JavaScript files to identify potential DOM XSS vulnerabilities. Test each finding in the browser.

### Lab 3: Source Map Analysis

**Setup**: Find a web application with exposed source maps.

**Exercise**: Download and extract source files from the source maps. Identify all sensitive information in the original source code.

### Lab 4: OAuth Security Analysis

**Setup**: Find a web application using OAuth for authentication.

**Exercise**: Analyze the JavaScript code to understand the OAuth implementation. Test for common OAuth vulnerabilities.

## Ethical Guidelines

### Legal and Ethical Boundaries

**Authorized Testing Only**: Only analyze JavaScript files from assets within the bug bounty program scope. Do not analyze files from out-of-scope assets.

**No Credential Theft**: If you find credentials in JavaScript, report them responsibly. Do not use them to access systems beyond what's necessary to demonstrate the vulnerability.

**Data Handling**: Downloaded JavaScript files may contain sensitive data. Handle this data responsibly and delete it after analysis.

**Responsible Disclosure**: Report all findings through the program's designated channel. Do not disclose findings publicly until the program has had time to remediate.

**No Service Disruption**: Do not perform actions that could disrupt the target's services, such as aggressive scanning or exploitation that could cause outages.

**Documentation**: Maintain detailed records of all analysis activities. This documentation may be required to demonstrate that analysis was conducted within authorized boundaries.

## Quick Reference Cheat Sheet

### JavaScript Analysis Command Cheat Sheet

```bash
# Discovery
cat live_hosts.txt | getJS --complete > js_urls.txt
echo "https://TARGET" | jsluice urls
python3 LinkFinder.py -i https://TARGET -o cli -d

# Download
cat js_urls.txt | xargs -I {} curl -s {} -o {}

# Source Map Check
for url in $(cat js_urls.txt); do curl -s -o /dev/null -w "%{http_code}" "${url}.map"; done

# Deobfuscation
js-beautify minified.js > beautified.js
jsnice --ast --renovate obfuscated.js > decoded.js

# Secret Scanning
grep -rni "api[_-]key\|secret\|token\|password" js_analysis/
python3 SecretFinder.py -i js/app.js -e

# Endpoint Extraction
python3 LinkFinder.py -i js/app.js -o cli
grep -oP '"/api/[^"]*"' js_analysis/*.js | sort -u

# DOM XSS Analysis
grep -rni "innerHTML\|outerHTML\|document\.write" js_analysis/
grep -rni "location\.hash\|location\.search\|location\.href" js_analysis/

# Authentication Analysis
grep -rni "localStorage\|sessionStorage\|document\.cookie" js_analysis/
grep -rni "Authorization\|Bearer\|jwt" js_analysis/
```

### JavaScript Security Checklist

- [ ] All JavaScript files discovered
- [ ] Source maps checked
- [ ] JavaScript files downloaded
- [ ] Sensitive data extraction
- [ ] API endpoint extraction
- [ ] Authentication mechanism analysis
- [ ] DOM XSS analysis
- [ ] Prototype pollution analysis
- [ ] CSP bypass analysis
- [ ] Third-party library analysis
- [ ] Build configuration analysis
- [ ] Dynamic import analysis
- [ ] WebSocket analysis
- [ ] Service worker analysis
- [ ] Findings documented
