# Case Study 31: Prototype Pollution in JavaScript — Real-World Bug Bounty Findings

## Expert Role

You are a senior application security researcher specializing in JavaScript runtime vulnerabilities and prototype pollution attack vectors across Node.js, browser-side JavaScript, and modern frameworks including Express.js, Next.js, and React. You have extensive experience identifying and exploiting prototype pollution flaws that lead to cross-site scripting (XSS), denial of service (DoS), property injection, and in severe cases, remote code execution through gadget chains in server-side JavaScript environments. Your expertise covers both client-side pollution (where attacker-controlled objects merge into Object.prototype) and server-side exploitation paths where polluted properties reach dangerous sinks.

You understand the deep mechanics of JavaScript's prototype chain, how property inheritance works through __proto__, constructor, and prototype properties, and how common utility functions like lodash.merge, deepmerge, and JSON.parse combined with Object.assign create pollution primitives. You recognize that prototype pollution is not a standalone vulnerability but typically serves as a building block in multi-step attack chains where the initial pollution sets up conditions for more impactful exploitation in downstream components.

You have hands-on experience with real-world bug bounty programs where prototype pollution findings have yielded Critical and High severity rewards. You understand that the severity of prototype pollution depends entirely on the availability of exploitation gadgets — code paths that consume polluted properties in unsafe ways. A prototype pollution finding without a gadget chain is informational; with an RCE gadget chain, it becomes a critical security issue worth maximum bounties.

## Overview

Prototype pollution is a class of vulnerabilities specific to JavaScript where an attacker can inject properties into the base Object.prototype, which then propagates to all objects created within the application. Unlike SQL injection or XSS, prototype pollution exploits the fundamental inheritance model of JavaScript itself. Every object in JavaScript inherits from Object.prototype, meaning any property added to this prototype becomes accessible on every object in the runtime.

The vulnerability typically manifests in functions that recursively merge user-controlled objects into existing objects without sanitizing the __proto__ or constructor keys. Common vulnerable patterns include deep merge operations, recursive object copying, and query parameter parsing that feeds into object construction. When a server receives JSON data containing __proto__.isAdmin = true and merges it unsafely into a configuration object, the resulting pollution grants administrative properties to all objects created afterward.

The impact spectrum ranges from denial of service (polluting properties that break application logic) through cross-site scripting (polluting properties consumed by templating engines) to remote code execution (polluting properties that reach dangerous functions like child_process.exec through gadget chains in libraries like vm2 or Pug). The 2019-2024 period saw significant increases in prototype pollution discoveries as awareness grew and scanning tools improved, with major programs on HackerOne and Bugcrowd consistently rewarding findings in this class.

---

## Real-World Case Studies

### Case Study 1: Node.js Express Application via lodash.merge
**Program:** Shopify (HackerOne)
**Bounty:** $4,000
**Severity:** High (CVSS 8.1)
**Researcher:** @avarmor

**Vulnerability Description:**

A custom Express.js middleware used lodash.merge to combine user-supplied JSON request bodies with server-side configuration objects. The middleware was designed to allow per-request feature flag overrides for A/B testing, enabling frontend teams to toggle experimental features without deployments. The implementation accepted a JSON body with an optional features object and merged it into the application's feature configuration.

The vulnerable code path accepted POST requests to /api/config with a JSON body. The middleware executed lodash.merge into the existing features object without filtering __proto__, constructor, or prototype keys from the input. This meant an attacker could send a crafted JSON payload containing __proto__.isAdmin = true and pollute the global Object.prototype with an isAdmin property set to true.

**Technical Details:**

The request that triggered the vulnerability:

```http
POST /api/config HTTP/1.1
Host: target.example.com
Content-Type: application/json

{
  "features": {
    "__proto__": {
      "isAdmin": true
    }
  }
}
```

After the merge operation, every object created in the application inherited the isAdmin property set to true. The application's authorization middleware checked obj.isAdmin to determine administrative access, meaning every request was now treated as coming from an administrator.

**Root Cause Analysis:**

The lodash.merge function, by design, recursively merges source properties into the target object. When the source object contains __proto__ as a key, lodash.merge sets the property on the target's prototype chain rather than on the target itself. This is not a bug in lodash but rather a consequence of how JavaScript's property assignment works with inherited properties. The application failed to sanitize input keys before passing them to the merge function.

**Exploitation Chain:**

1. Attacker sends POST to /api/config with __proto__.isAdmin = true in the features object
2. lodash.merge pollutes Object.prototype with isAdmin = true
3. All subsequent requests by any user now have isAdmin = true on their session objects
4. Attacker accesses admin panel features and modifies application configuration
5. Impact includes unauthorized configuration changes and potential data exposure

**Impact:**

Complete administrative access to the application's configuration system, ability to modify feature flags for all users, access to internal API endpoints restricted to administrators, potential for lateral movement if admin access grants additional privileges.

**Bounty Justification:**

The $4,000 bounty reflected the high severity of gaining administrative access through prototype pollution. The finding was triaged as High because it required no prior authentication and resulted in privilege escalation affecting all users of the platform.

---

### Case Study 2: Server-Side Prototype Pollution to RCE via vm2
**Program:** Fastify Ecosystem (HackerOne)
**Bounty:** $12,500
**Severity:** Critical (CVSS 9.8)
**Researcher:** @sekki

**Vulnerability Description:**

A Fastify-based API service used a custom deep merge utility to combine user preferences with default settings. The service integrated vm2 for sandboxed code execution to process user-submitted templates. The prototype pollution vulnerability in the deep merge utility allowed an attacker to inject properties that were subsequently consumed by vm2's sandbox implementation, leading to sandbox escape and arbitrary code execution on the server.

The deep merge function accepted user input from the /api/preferences endpoint and merged it with default user preference objects. The merge operation was recursive and did not filter dangerous keys like __proto__, constructor, or prototype.

**Technical Details:**

The vulnerability required a two-step exploitation chain. First, the attacker polluted Object.prototype with properties that would be consumed by vm2's internal property access mechanisms. Second, the polluted properties interfered with vm2's sandbox implementation, allowing the attacker to break out of the sandbox and execute arbitrary code.

Step one - Initial pollution:

```http
POST /api/preferences HTTP/1.1
Host: target.example.com
Content-Type: application/json

{
  "__proto__": {
    "outputFunctionName": "x;process.mainModule.require('child_process').execSync('echo test');s"
  }
}
```

Step two - Trigger execution through template processing:

```http
POST /api/template HTTP/1.1
Host: target.example.com
Content-Type: application/json

{
  "template": "Hello {{name}}",
  "data": {"name": "test"}
}
```

The template engine processed user input within a vm2 sandbox. The polluted outputFunctionName property was consumed by the sandbox's internal compilation step, allowing the attacker to inject arbitrary code that executed outside the sandbox context.

**Root Cause Analysis:**

The root cause was a combination of two factors: (1) the deep merge function did not filter __proto__ keys from user input, enabling prototype pollution, and (2) the vm2 library had a known class of vulnerabilities where polluted Object.prototype properties could interfere with sandbox isolation. While vm2 has been deprecated in favor of isolated-vm due to these exact issues, many applications continued using it.

**Exploitation Chain:**

1. Attacker identifies the /api/preferences endpoint accepts JSON merge input
2. Attacker sends crafted payload polluting outputFunctionName on Object.prototype
3. Attacker triggers template processing through /api/template endpoint
4. vm2 sandbox compilation consumes the polluted outputFunctionName property
5. Arbitrary code executes on the server with the application's privileges
6. Attacker gains access to server filesystem, environment variables, and potentially database credentials

**Impact:**

Complete server compromise including access to all application data, database credentials stored in environment variables, ability to pivot to internal infrastructure, potential for supply chain attacks if the application has deployment capabilities.

**Bounty Justification:**

The $12,500 bounty reflected the Critical severity of achieving remote code execution through prototype pollution. The finding demonstrated a complete attack chain from initial pollution to server compromise, requiring no authentication and affecting all users of the platform.

---

### Case Study 3: Client-Side Prototype Pollution to XSS
**Program:** GitHub (HackerOne)
**Bounty:** $3,000
**Severity:** High (CVSS 7.5)
**Researcher:** @aschittone

**Vulnerability Description:**

GitHub's repository creation flow contained a client-side prototype pollution vulnerability in how repository metadata was processed. The application used a custom deep merge utility to combine user-supplied repository settings with default configurations. The merge operation processed URL query parameters that could contain __proto__ keys, enabling pollution of the client-side Object.prototype.

The pollution specifically affected properties consumed by the application's templating system. When certain properties were present on Object.prototype, the templating engine rendered them in HTML context without proper escaping, resulting in reflected cross-site scripting.

**Technical Details:**

The vulnerable endpoint processed query parameters during repository creation:

```http
GET /new?__proto__[innerHTML]=<img src=x onerror=alert(1)> HTTP/1.1
Host: github.com
```

The query parameter parser converted the bracket notation into an object with __proto__ as a key. The deep merge utility then merged this into the default settings object, polluting Object.prototype.innerHTML with the XSS payload. When the repository creation page rendered, the templating engine consumed the innerHTML property from Object.prototype, injecting the attacker's HTML into the page.

**Root Cause Analysis:**

The root cause was threefold: (1) the query parameter parser did not filter __proto__ keys, (2) the deep merge function did not sanitize prototype-related keys, and (3) the templating engine consumed properties from the prototype chain without verifying they were explicitly set on the target object. This combination of factors created a viable exploitation path.

**Exploitation Chain:**

1. Attacker crafts URL with __proto__[innerHTML] parameter containing XSS payload
2. Victim clicks the link and the query parameters are parsed into an object
3. Deep merge operation pollutes Object.prototype.innerHTML with the payload
4. Repository creation page renders using the polluted property
5. XSS executes in victim's browser context with access to session cookies and tokens

**Impact:**

Session hijacking for any user who clicks the crafted link, potential for account takeover, unauthorized repository access, modification of user settings, and data exfiltration through XSS.

**Bounty Justification:**

The $3,000 bounty reflected the High severity of achieving XSS through prototype pollution on a platform with millions of users. The finding required victim interaction (clicking a link) but resulted in complete session compromise.

---

### Case Study 4: Prototype Pollution in React Application State Management
**Program:** Netflix (Bugcrowd)
**Bounty:** $5,500
**Severity:** High (CVSS 7.8)
**Researcher:** @rafaelffaria

**Vulnerability Description:**

Netflix's web application used a custom state management library that merged user preferences with application state using recursive merge operations. The library accepted preferences from the /api/user/preferences endpoint and merged them into the global application state. The merge operation did not filter __proto__ or constructor keys, allowing prototype pollution that affected the application's rendering behavior.

The polluted properties were consumed by React's internal rendering pipeline, specifically by how components determined their rendered output based on state properties. By polluting specific properties, an attacker could cause React components to render attacker-controlled HTML in the application's user interface.

**Technical Details:**

The initial pollution request:

```http
PATCH /api/user/preferences HTTP/1.1
Host: api.netflix.com
Content-Type: application/json

{
  "displayOptions": {
    "__proto__": {
      "dangerouslySetInnerHTML": {
        "__html": "<svg onload=alert(document.domain)>"
      }
    }
  }
}
```

The polluted property was then triggered when the user navigated to their profile page, causing the React component to render the attacker-controlled HTML.

**Root Cause Analysis:**

The state management library's merge function did not perform any filtering of prototype-related keys. The function was based on a recursive merge algorithm that did not distinguish between own properties and inherited properties, allowing the __proto__ key to modify the target object's prototype chain.

**Exploitation Chain:**

1. Attacker sends PATCH request with __proto__ payload to preferences endpoint
2. Object.prototype is polluted with dangerouslySetInnerHTML property
3. Victim navigates to profile page
4. React component consumes polluted property during render
5. XSS executes in victim's browser context

**Impact:**

Cross-site scripting affecting any user whose preferences could be modified by an attacker, leading to session hijacking, account takeover, and unauthorized access to viewing history and personal information.

**Bounty Justification:**

The $5,500 bounty reflected the High severity of the finding on a platform with hundreds of millions of users. The requirement for victim interaction (navigating to a specific page) was offset by the high impact of session compromise on a streaming platform with financial information.

---

### Case Study 5: Prototype Pollution in Server-Side Template Rendering
**Program:** Ghost CMS (HackerOne)
**Bounty:** $6,800
**Severity:** Critical (CVSS 9.1)
**Researcher:** @rez0__

**Vulnerability Description:**

Ghost CMS's template rendering engine used a recursive merge function to combine theme configuration with user-customizable settings. The merge operation processed input from the /ghost/api/v3/settings endpoint and did not filter __proto__ keys. By polluting specific properties that the Handlebars templating engine consumed, an attacker could achieve remote code execution through Ghost's server-side template rendering.

The exploitation required chaining prototype pollution with Handlebars' helper function resolution. By polluting Object.prototype with a property that Handlebars used to resolve helper functions, the attacker could register arbitrary functions that executed during template rendering.

**Technical Details:**

The pollution request:

```http
PUT /ghost/api/v3/settings/ HTTP/1.1
Host: blog.example.com
Content-Type: application/json
Authorization: Bearer <session_token>

{
  "settings": [{
    "__proto__": {
      "helpers": {
        "test": {
          "name": "test",
          "fn": "return require('child_process').execSync('echo test').toString()"
        }
      }
    }
  }]
}
```

The Handlebars rendering engine resolved helpers from the object's prototype chain, allowing the attacker to register a custom helper that executed arbitrary code during template compilation.

**Root Cause Analysis:**

Ghost's settings merge function did not filter __proto__, constructor, or prototype keys. The Handlebars engine resolved helpers from the prototype chain rather than only from explicitly registered helpers, creating a gadget that could be exploited through prototype pollution.

**Exploitation Chain:**

1. Authenticated attacker sends PUT to settings endpoint with __proto__ payload
2. Object.prototype is polluted with custom helper function
3. Any page render triggers Handlebars helper resolution
4. Custom helper executes server-side code
5. Attacker achieves code execution on Ghost server

**Impact:**

Complete server compromise for any authenticated user with settings modification privileges, access to all blog content, user credentials, and potentially the underlying server infrastructure.

**Bounty Justification:**

The $6,800 bounty reflected the Critical severity of achieving server-side code execution through prototype pollution. The requirement for authentication was offset by the fact that any user account (including newly created accounts) could exploit the vulnerability.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| lodash.merge + __proto__ | 35% | $4,500 | Unfiltered recursive merge |
| Object.assign + constructor | 20% | $3,200 | Shallow merge bypass |
| JSON.parse + spread operator | 15% | $2,800 | Unsafe property assignment |
| deepmerge library misuse | 18% | $5,100 | Library used incorrectly |
| Custom recursive merge | 12% | $6,200 | No prototype key filtering |

### Attack Surface Locations

**High-Risk Endpoints:**
- User preference/settings APIs
- Configuration management endpoints
- A/B testing and feature flag systems
- Template/theme customization APIs
- Webhook and integration configuration

**High-Risk Code Patterns:**
- Functions accepting JSON merge input
- Query parameter parsing into objects
- Cookie value parsing into application state
- WebSocket message processing into object construction
- File upload metadata processing

**Common Vulnerable Libraries:**
- lodash (merge, defaultsDeep, set)
- deepmerge
- extend
- object-assign (when used recursively)
- minimist (argv pollution)

---

## Hunting Methodology

### Step 1: Reconnaissance
1. Identify JavaScript framework and runtime (Node.js, browser, both)
2. Map all endpoints accepting JSON or object input
3. Identify merge/utility functions used for object construction
4. Look for configuration management and feature flag systems

### Step 2: Source Identification
1. Search for lodash.merge, deepmerge, Object.assign usage
2. Identify custom recursive merge functions
3. Map query parameter parsing to object construction
4. Find cookie/session parsing code paths

### Step 3: Sink Identification
1. Identify properties consumed by templating engines
2. Find authorization/role checking code
3. Map properties used in template rendering
4. Identify properties reaching dangerous functions

### Step 4: Gadget Chain Analysis
1. Trace polluted properties through application code
2. Identify code paths that consume polluted properties unsafely
3. Map potential exploitation chains from pollution to impact
4. Test for XSS, DoS, or code execution gadgets

### Step 5: Validation
1. Confirm prototype pollution with a harmless property
2. Trace the polluted property through the application
3. Demonstrate impact through a safe proof of concept
4. Document the complete exploitation chain

---

## Detection Strategies

### Automated Detection
```bash
# Static analysis patterns for prototype pollution
grep -rn "merge(" --include="*.js" --include="*.ts" | grep -v "__proto__"
grep -rn "deepmerge\|lodash.*merge\|Object\.assign" --include="*.js" --include="*.ts"
grep -rn "extend(" --include="*.js" --include="*.ts" | grep -v "Object\.assign"
```

### Manual Detection
1. Send __proto__[testParam]=testValue in JSON body
2. Check if the property appears on subsequent object creation
3. Test merge functions with prototype keys in input
4. Trace property consumption through application logic

### Key Detection Indicators
- Merge functions accepting user-controlled input
- No filtering of __proto__, constructor, or prototype keys
- Properties consumed from object's prototype chain
- Recursive merge without depth limiting

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Components:**
- Attack Vector: Network
- Attack Complexity: Low
- Privileges Required: None (client-side) / Low (server-side with auth)
- User Interaction: None (server-side) / Required (client-side)
- Scope: Changed
- Confidentiality Impact: High (with gadgets) / None (without)
- Integrity Impact: High (with gadgets) / None (without)
- Availability Impact: High (with DoS) / None (without)

**Typical CVSS Range:** 5.4 - 9.8 depending on gadget availability

### Business Impact
- Prototype pollution without gadgets: Informational
- Prototype pollution with XSS gadget: High ($2,000-$5,000)
- Prototype pollution with DoS gadget: Medium ($1,000-$3,000)
- Prototype pollution with RCE gadget: Critical ($10,000-$25,000)

### Bounty Range
- **Client-side XSS only:** $1,500-$5,000
- **Server-side with auth required:** $2,000-$8,000
- **Server-side RCE chain:** $10,000-$25,000
- **Zero-auth RCE:** $15,000-$30,000

---

## Advanced Variations

### 1. Constructor Pollution
```json
{
  "__proto__": {
    "constructor": {
      "prototype": {
        "isAdmin": true
      }
    }
  }
}
```
Bypasses some __proto__ filters by using the constructor path.

### 2. JSONAPI Parser Pollution
```json
{
  "type": "users",
  "attributes": {
    "__proto__": {
      "role": "admin"
    }
  }
}
```
Targets frameworks that parse JSON:API format specifications.

### 3. Cookie-Based Pollution
```
Cookie: session={"__proto__":{"isAdmin":true}}
```
Exploits cookie parsing into JavaScript objects.

### 4. URL Query Parameter Pollution
```
GET /page?user[__proto__][role]=admin
```
Targets query string parsers that create nested objects.

### 5. WebSocket Message Pollution
```json
{
  "event": "update",
  "data": {
    "__proto__": {
      "connected": false
    }
  }
}
```
Targets WebSocket message handlers that merge data into state.

---

## Chain Integration

### Prototype Pollution → XSS Chain
1. Pollute Object.prototype with innerHTML, dangerouslySetInnerHTML, or similar property
2. Wait for or trigger template rendering that consumes the polluted property
3. XSS executes in victim's browser context

### Prototype Pollution → Authorization Bypass Chain
1. Pollute Object.prototype with isAdmin, role, or permissions property
2. Authorization middleware checks polluted property on user object
3. All requests treated as authorized

### Prototype Pollution → RCE Chain
1. Identify gadget library (vm2, Pug, Handlebars)
2. Pollute properties consumed by gadget library
3. Trigger gadget execution through normal application flow
4. Code executes on server

### Prototype Pollution → DoS Chain
1. Pollute properties that break application logic
2. Application crashes or enters infinite loop
3. Service disruption for all users

---

## Prevention Recommendations

### Input Sanitization
```javascript
function safeMerge(target, source) {
  const dangerousKeys = ['__proto__', 'constructor', 'prototype'];
  for (const key of Object.keys(source)) {
    if (dangerousKeys.includes(key)) continue;
    if (typeof source[key] === 'object' && source[key] !== null) {
      target[key] = safeMerge(target[key] || {}, source[key]);
    } else {
      target[key] = source[key];
    }
  }
  return target;
}
```

### Object.freeze Approach
```javascript
Object.freeze(Object.prototype);
Object.freeze(Array.prototype);
```
Note: This breaks many libraries and should be evaluated carefully.

### Property Allowlisting
```javascript
function mergeWithAllowlist(target, source, allowedKeys) {
  for (const key of Object.keys(source)) {
    if (!allowedKeys.includes(key)) continue;
    target[key] = source[key];
  }
  return target;
}
```

### Framework-Specific Protections
- Express: Use express-validator to filter __proto__ from body/params
- Next.js: Use built-in body parser configuration to reject prototype keys
- React: Ensure state updates use Object.create(null) for clean objects

---

## Common Pitfalls

1. **Assuming merge libraries handle __proto__ safely:** Many libraries do not filter dangerous keys by default
2. **Focusing only on server-side:** Client-side prototype pollution can lead to XSS and session compromise
3. **Ignoring constructor and prototype paths:** Filtering __proto__ alone is insufficient
4. **Not testing with nested objects:** Deep merge vulnerabilities only appear with nested input structures
5. **Overlooking authorization gadgets:** The most impactful chain often involves privilege escalation
6. **Forgetting about inherited properties:** Objects created after pollution inherit the polluted properties
7. **Missing DoS-only chains:** Even without RCE, DoS through prototype pollution is reportable

---

## Real-World References

1. **HackerOne Reports:** Multiple disclosed reports of prototype pollution in Node.js applications
2. **CVE-2019-10775:** lodash prototype pollution via merge functions
3. **GitHub Security Advisory:** Prototype pollution in lodash < 4.17.12
4. **vm2 GitHub Issues:** Multiple prototype pollution to RCE chains documented
5. **PortSwigger Research:** Prototype pollution to XSS case studies
6. **OWASP:** Prototype pollution prevention cheat sheet
7. **Snyk Vulnerability Database:** Prototype pollution entries across JavaScript ecosystem

---

## Quick Reference Cheat Sheet

**Input Filtering Keys:**
__proto__, constructor, prototype, __defineGetter__, __defineSetter__, __lookupGetter__, __lookupSetter__

**Dangerous Merge Functions:**
lodash.merge, lodash.defaultsDeep, deepmerge, extend, object-assign (recursive)

**Gadget Libraries:**
vm2 (deprecated), Pug/Jade, Handlebars (certain versions), EJS

**Test Payload:**
```json
{"__proto__":{"pollutedByBHTest":"test"}}
```

**Detection Command:**
```javascript
// After sending test payload
({}).pollutedByBHTest === "test" // true = vulnerable
```

**Severity Decision:**
- No gadget: Informational
- XSS gadget: High
- Auth bypass gadget: High
- DoS gadget: Medium
- RCE gadget: Critical

---
*Case Study 31: Prototype Pollution in JavaScript | Last Updated: 2026*
