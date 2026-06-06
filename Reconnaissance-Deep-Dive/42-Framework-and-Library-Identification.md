# Framework and Library Identification Techniques

## Expert Role Definition

You are a seasoned web application security researcher specializing in framework and library identification for reconnaissance and vulnerability assessment. Your expertise spans server-side frameworks (Django, Flask, Rails, Spring, Express, Laravel, ASP.NET) and client-side frameworks (React, Angular, Vue, jQuery, Bootstrap) along with hundreds of JavaScript libraries. You understand that framework identification is crucial for targeted security testing, as each framework has distinct security models, known vulnerabilities, and architectural patterns. Your methodology combines passive fingerprinting (analyzing HTTP responses, HTML source, and JavaScript) with active probing (testing framework-specific endpoints and behaviors). You possess deep knowledge of framework versioning schemes, security patch cycles, and the subtle signatures that reveal underlying technology choices. Your approach emphasizes accurate identification while maintaining ethical testing boundaries and providing actionable intelligence for security improvements.

## Core Concepts Deep Dive

### Framework Identification Methodology

Framework identification follows a systematic approach combining multiple fingerprinting techniques to achieve high-confidence results.

**Passive Fingerprinting:**
- HTTP header analysis (X-Powered-By, Server, Set-Cookie patterns)
- HTML source code inspection (meta tags, script references, CSS patterns)
- JavaScript library detection and version analysis
- CSS framework identification
- Font and icon library detection

**Active Fingerprinting:**
- Framework-specific URL pattern probing
- Error message analysis
- Response time analysis
- Default file and directory detection
- Configuration file probing

### Server-Side Framework Patterns

Different server-side frameworks follow distinct architectural patterns:

**Python Frameworks:**
- **Django:** URL patterns (/admin/, /static/admin/), CSRF token patterns, template engine markers
- **Flask:** Minimal structure, Jinja2 template markers, specific error message formats
- **FastAPI:** OpenAPI/Swagger endpoints, async response patterns
- **Bottle:** Minimal footprint, specific header patterns

**Ruby Frameworks:**
- **Rails:** Asset pipeline patterns (/assets/), session cookie patterns (_session_id)
- **Sinatra:** Minimal structure, specific route patterns
- **Hanami:** Distinct file organization, template patterns

**JavaScript Frameworks:**
- **Express:** Minimal headers, route patterns, middleware signatures
- **NestJS:** TypeScript patterns, specific header structures
- **Koa:** Async/await patterns, minimal response structure

**PHP Frameworks:**
- **Laravel:** Session cookie patterns (laravel_session), CSRF token patterns
- **Symfony:** Specific header patterns, profiler endpoints
- **CodeIgniter:** Session cookie patterns, specific error formats
- **CakePHP:** Specific routing patterns, helper references

**Java Frameworks:**
- **Spring:** Specific header patterns, actuator endpoints
- **Struts:** Specific error messages, configuration patterns
- **JSF:** ViewState patterns, specific component libraries

**.NET Frameworks:**
- **ASP.NET Core:** Specific header patterns, development mode indicators
- **ASP.NET MVC:** ViewState patterns, specific routing conventions
- **Blazor:** WebAssembly patterns, specific JavaScript references

### Client-Side Framework Patterns

Client-side frameworks have distinct detection signatures:

**React:**
- `data-reactroot` or `data-reactid` attributes
- `__REACT_DEVTOOLS_GLOBAL_HOOK__` JavaScript variable
- React-specific class naming patterns
- Bundle file patterns (main.chunk.js, bundle.js)

**Angular:**
- `ng-version` attribute on root element
- Angular-specific script references (polyfills.js, main.js)
- `ng-controller` or `ng-component` directives
- Angular CLI-generated file patterns

**Vue.js:**
- `data-v-` attributes on elements
- Vue-specific script references (app.js, chunk-vendors.js)
- Vue devtools hook (`__VUE_DEVTOOLS_GLOBAL_HOOK__`)
- Template compilation patterns

**jQuery:**
- jQuery-specific script references
- jQuery object patterns in JavaScript
- Plugin references and patterns
- Version detection via `$.fn.jquery`

**CSS Frameworks:**
- **Bootstrap:** `.container`, `.row`, `.col-*` classes
- **Tailwind CSS:** Utility-first class patterns
- **Foundation:** `.grid-x`, `.cell` classes
- **Bulma:** `.is-*`, `.has-*` modifier patterns

### Version Detection Strategies

Framework version detection is critical for vulnerability research:

**Explicit Version Disclosure:**
- Meta tags with version information
- JavaScript library version variables
- HTTP header version information
- Configuration file exposure

**Implicit Version Detection:**
- Feature presence/absence analysis
- API endpoint patterns
- Default file content variations
- Security patch indicators

## Pre-requisite Knowledge

Before attempting framework identification, you should understand:

1. **Web Development Fundamentals:** HTML, CSS, JavaScript structure and how different frameworks organize code.

2. **HTTP Protocol:** Request/response cycle, headers, status codes, and content types.

3. **Server-Side Technologies:** PHP, Python, Ruby, Java, .NET file extensions and default configurations.

4. **Framework Architecture:** How different frameworks organize code, handle routing, and manage state.

5. **Fingerprinting Concepts:** Passive vs. active detection, false positive/negative considerations, and confidence scoring.

6. **Ethical Hacking Principles:** Authorization requirements, testing boundaries, and responsible disclosure.

## Step-by-Step Methodology

### Phase 1: Initial Reconnaissance

**Step 1: HTTP Header Analysis**
Begin by analyzing HTTP response headers for framework indicators:

```bash
curl -I https://target.com
```

Look for:
- X-Powered-By headers (Express, PHP, ASP.NET)
- Server header variations
- Set-Cookie patterns (framework-specific session cookies)
- Custom headers with framework-specific values

**Step 2: HTML Source Code Inspection**
Examine the HTML source for framework markers:

```bash
curl -s https://target.com | grep -i "react\|angular\|vue\|jquery\|bootstrap"
```

Key indicators:
- Script references to framework bundles
- CSS framework class patterns
- Meta tags with framework information
- Data attributes specific to frameworks

**Step 3: JavaScript Bundle Analysis**
Identify client-side frameworks through JavaScript analysis:

```bash
curl -s https://target.com | grep -o 'src="[^"]*\.js[^"]*"'
```

Map bundle names to frameworks:
- React: main.chunk.js, bundle.js, vendor.js
- Angular: polyfills.js, main.js, runtime.js
- Vue: app.js, chunk-vendors.js
- jQuery: jquery.min.js, jquery-[version].js

### Phase 2: Deep Fingerprinting

**Step 4: CSS Framework Detection**
Identify CSS frameworks through class patterns:

```bash
curl -s https://target.com | grep -o 'class="[^"]*"'
```

Look for framework-specific patterns:
- Bootstrap: container, row, col-md-*, btn, navbar
- Tailwind CSS: flex, p-4, text-lg, bg-blue-500
- Foundation: grid-x, cell, medium-6
- Bulma: is-primary, has-text-centered, columns

**Step 5: Font and Icon Library Detection**
Identify typography and icon libraries:

```bash
curl -s https://target.com | grep -i "font-awesome\|material-icons\|bootstrap-icons"
```

Common patterns:
- Font Awesome: fa, fas, far, fab classes
- Material Icons: material-icons class
- Bootstrap Icons: bi-* classes
- Google Fonts: fonts.googleapis.com references

**Step 6: Error Page Analysis**
Trigger error pages to reveal framework information:

```bash
curl -s https://target.com/nonexistent-page-12345
curl -s "https://target.com/?param=<script>alert(1)</script>"
```

Error messages often reveal:
- Framework-specific error formatting
- Development mode indicators
- Debug information exposure

### Phase 3: Server-Side Framework Detection

**Step 7: Framework-Specific URL Probing**
Test framework-specific endpoints:

```bash
# Django
curl -I https://target.com/admin/
curl -I https://target.com/static/admin/

# Laravel
curl -I https://target.com/storage/logs/laravel.log

# Spring Boot
curl -I https://target.com/actuator
curl -I https://target.com/actuator/health

# Express
curl -I https://target.com/robots.txt (default Express behavior)
```

**Step 8: Configuration File Probing**
Test for framework configuration files:

```bash
# Django
curl -I https://target.com/settings.py

# Laravel
curl -I https://target.com/.env
curl -I https://target.com/config/database.php

# Spring
curl -I https://target.com/application.properties
```

### Phase 4: Version Detection and Validation

**Step 9: Version-Specific Features**
Use framework-specific features for precise identification:

```bash
# jQuery version detection
curl -s https://target.com | grep -o "jquery-[0-9.]*"

# Bootstrap version detection
curl -s https://target.com | grep -o "bootstrap[0-9.]*"
```

**Step 10: Cross-Validation and Documentation**
Verify findings across multiple detection methods:

- If React detected via data attributes, confirm with bundle patterns
- If Django detected via /admin/, confirm with CSRF token patterns
- Calculate confidence score based on multiple indicators

## Tool Arsenal with Exact Commands

### Primary Detection Tools

**1. WhatWeb (Technology Fingerprinting)**
```bash
# Basic scan
whatweb https://target.com

# Verbose output with plugins
whatweb -v https://target.com

# Aggressive scanning
whatweb -a 3 https://target.com

# Scan multiple targets
whatweb -i targets.txt
```

**2. Wappalyzer (Technology Detection)**
```bash
# CLI version
wappalyzer https://target.com

# With proxy support
wappalyzer --proxy socks5://127.0.0.1:9050 https://target.com
```

**3. BuiltWith (Technology Profiling)**
```bash
# API-based scanning
curl "https://api.builtwith.com/free1/api.json?KEY=YOUR_API_KEY&LOOKUP=target.com"

# Direct scanning
whatweb --plugin BuiltWith target.com
```

**4. Custom Fingerprints**
```bash
# React detection
curl -s https://target.com | grep -c "data-reactroot\|__REACT_DEVTOOLS"

# Angular detection
curl -s https://target.com | grep -c "ng-version\|ng-controller"

# Vue detection
curl -s https://target.com | grep -c "data-v-\|__VUE_DEVTOOLS"
```

### Supplementary Tools

**5. Curl for Manual Testing**
```bash
# Header analysis
curl -D- https://target.com

# Cookie analysis
curl -c- -b- https://target.com

# Follow redirects
curl -L https://target.com
```

**6. Nmap Scripts**
```bash
# http-generator
nmap --script http-generator -p 80,443 target.com

# http-headers
nmap --script http-headers -p 80,443 target.com
```

**7. JavaScript Analysis Tools**
```bash
# Extract JavaScript URLs
curl -s https://target.com | grep -o 'src="[^"]*\.js[^"]*"' | cut -d'"' -f2

# Analyze JavaScript content
curl -s https://target.com/static/js/main.js | grep -i "react\|angular\|vue"
```

## Real-World Case Studies

### Case Study 1: Mixed Framework Environment

**Scenario:** A modern web application used multiple frameworks across different components.

**Detection Process:**
1. Main application: React (data-reactroot, bundle patterns)
2. API backend: Express (minimal headers, route patterns)
3. Admin panel: Django (/admin/, CSRF patterns)
4. Documentation: Vue.js (data-v- attributes, bundle patterns)

**Findings:**
- Four different frameworks in use
- Different security models and update cycles
- React frontend vulnerable to XSS due to dangerouslySetInnerHTML
- Django admin panel accessible without additional authentication
- Express API endpoints vulnerable to prototype pollution

**Impact:** The organization had to coordinate security testing across four different framework ecosystems, each with distinct vulnerability classes and remediation approaches.

### Case Study 2: Framework Version Vulnerability Mapping

**Scenario:** Accurate framework version detection enabled targeted vulnerability assessment.

**Detection Process:**
1. jQuery 1.8.3 detected via script references
2. Bootstrap 3.3.7 detected via CSS patterns
3. Angular 1.5.11 detected via ng-version attribute
4. Research revealed multiple CVEs for each version

**Findings:**
- jQuery vulnerable to XSS via $.htmlPrefilter (CVE-2020-11022, CVE-2020-11023)
- Bootstrap vulnerable to XSS via tooltip/popover (CVE-2018-14040)
- Angular 1.x vulnerable to various sandbox escapes
- Combined vulnerability chain possible

**Impact:** Demonstrated how outdated client-side frameworks create significant attack surface, even when server-side frameworks are up-to-date.

### Case Study 3: Obfuscated Framework Detection

**Scenario:** A website had minified and obfuscated JavaScript, making framework detection challenging.

**Detection Process:**
1. Standard detection methods failed due to obfuscation
2. Timing analysis revealed framework-specific response patterns
3. Error message analysis exposed framework information
4. Network request patterns revealed framework behavior

**Findings:**
- Custom Webpack bundle with React
- Server-side rendering with Next.js
- GraphQL API with Apollo Client
- Obfuscation removed but didn't eliminate framework signatures

**Lesson:** Framework detection requires looking beyond obvious indicators to behavioral patterns.

### Case Study 4: Legacy Framework Security Assessment

**Scenario:** An enterprise application used legacy frameworks with known vulnerabilities.

**Detection Process:**
1. ASP.NET WebForms detected via ViewState patterns
2. jQuery 1.4.2 detected via script references
3. Custom JavaScript framework with proprietary patterns
4. IIS 7.5 with .NET Framework 4.0

**Findings:**
- ASP.NET ViewState deserialization vulnerability possible
- jQuery vulnerable to multiple XSS attacks
- Custom framework had no security updates since 2015
- .NET Framework version end-of-life

**Impact:** The legacy technology stack required complete modernization rather than incremental updates.

## Advanced Techniques and Bypass

### Framework Obfuscation Detection

Many frameworks attempt to hide their presence through:

**1. Asset Fingerprinting:**
- Hash-based filenames (main.a1b2c3.js)
- Content-based hashing
- Bypass: Analyze bundle structure and content patterns

**2. Minification and Obfuscation:**
- Removed whitespace and short variable names
- String encoding and array-based obfuscation
- Bypass: Look for framework-specific function patterns

**3. Server-Side Rendering:**
- Pre-rendered HTML masks client-side frameworks
- Bypass: Analyze hydration patterns and JavaScript bundles

**4. Custom Build Configurations:**
- Non-standard build outputs
- Custom chunk naming
- Bypass: Analyze chunk loading patterns and manifest files

### Advanced Fingerprinting Techniques

**1. Timing-Based Detection:**
```bash
# Measure response times for different request types
time curl -s https://target.com/api/data > /dev/null
time curl -s https://target.com/static/main.js > /dev/null
```

Different frameworks have different response time patterns for static vs. dynamic content.

**2. Error Message Analysis:**
```bash
# Trigger framework-specific errors
curl -s "https://target.com/?param=<script>alert(1)</script>"
curl -s "https://target.com/nonexistent-api-endpoint"
```

**3. JavaScript Behavioral Analysis:**
```bash
# Analyze framework-specific JavaScript patterns
curl -s https://target.com | grep -o "React\.[a-zA-Z]*"
curl -s https://target.com | grep -o "angular\.[a-zA-Z]*"
curl -s https://target.com | grep -o "Vue\.[a-zA-Z]*"
```

### WAF and CDN Bypass Techniques

**1. IP Address Direct Access:**
```bash
# Bypass CDN by accessing origin directly
dig target.com
curl -H "Host: target.com" https://[origin-ip]
```

**2. Subdomain Discovery:**
```bash
# Find origin subdomains
subfinder -d target.com -o subdomains.txt
httpx -l subdomains.txt -o live-hosts.txt
```

**3. Certificate Transparency Analysis:**
```bash
# Find alternative domains
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u
```

## Detection and Indicators

### Common Framework Signatures

**React Indicators:**
- HTML: data-reactroot, data-reactid attributes
- JavaScript: __REACT_DEVTOOLS_GLOBAL_HOOK__, React.createElement
- Bundles: main.chunk.js, vendor.js, bundle.js
- Classes: className (JSX pattern)

**Angular Indicators:**
- HTML: ng-version, ng-controller, ng-component attributes
- JavaScript: angular.module, ng-zone
- Bundles: polyfills.js, main.js, runtime.js
- Routing: #/path (hash-based routing)

**Vue.js Indicators:**
- HTML: data-v-* attributes on elements
- JavaScript: __VUE_DEVTOOLS_GLOBAL_HOOK__, Vue.component
- Bundles: app.js, chunk-vendors.js
- Template: v-if, v-for directives

**jQuery Indicators:**
- JavaScript: $(), jQuery(), $.fn.jquery
- Plugins: jquery.[plugin].js
- Selectors: jQuery-specific selector patterns
- Version: $.fn.jquery variable

**Bootstrap Indicators:**
- Classes: container, row, col-*, btn, navbar
- JavaScript: bootstrap.js, bootstrap.min.js
- Components: modal, tooltip, popover patterns
- Grid system: responsive breakpoint classes

### Confidence Scoring Matrix

| Indicator Type | Weight | Examples |
|----------------|--------|----------|
| Framework-specific attributes | High | data-reactroot, ng-version |
| Bundle file patterns | High | main.chunk.js, polyfills.js |
| JavaScript framework variables | Medium | React, angular, Vue objects |
| CSS class patterns | Medium | container, row, col-* |
| HTTP header patterns | Low | X-Powered-By, Server |
| Error message patterns | Low | Framework-specific errors |

## Impact Assessment

### Security Implications by Framework Type

**Client-Side Frameworks:**
- **React:** XSS via dangerouslySetInnerHTML, prototype pollution
- **Angular:** Template injection, XSS via unsafe expressions
- **Vue.js:** XSS via v-html directive, prototype pollution
- **jQuery:** XSS via selector injection, deprecated functions

**Server-Side Frameworks:**
- **Django:** SQL injection, CSRF bypass, template injection
- **Flask:** SSTI, XSS, improper session management
- **Rails:** SQL injection, deserialization, CSRF
- **Spring:** Expression language injection, deserialization
- **Express:** Prototype pollution, XSS, open redirects
- **Laravel:** SQL injection, deserialization, debug mode exposure
- **ASP.NET:** ViewState deserialization, XSS, CSRF

**CSS Frameworks:**
- **Bootstrap:** XSS via tooltip/popover, CSS injection
- **Tailwind CSS:** Limited attack surface, utility-class patterns
- **Foundation:** XSS via specific components

### Risk Assessment Framework

1. **Framework Popularity Risk:** More popular frameworks = more known vulnerabilities
2. **Version Age Risk:** Outdated versions = known CVEs
3. **Configuration Risk:** Default configurations = known attack vectors
4. **Plugin Ecosystem Risk:** More plugins = larger attack surface
5. **Update Frequency Risk:** Infrequent updates = unpatched vulnerabilities

## Common Pitfalls

### Detection Errors

1. **False Positives from CDNs:**
   - CDN-hosted libraries may not reflect actual framework usage
   - Solution: Analyze multiple indicators, not single signatures

2. **Version Mismatches:**
   - Multiple versions of same framework may coexist
   - Solution: Cross-validate version indicators across multiple sources

3. **Obfuscation Blindness:**
   - Minified/obfuscated code may hide framework signatures
   - Solution: Use behavioral analysis and timing techniques

4. **SSR Complexity:**
   - Server-side rendering masks client-side frameworks
   - Solution: Analyze JavaScript bundles and hydration patterns

5. **Mixed Framework Environments:**
   - Multiple frameworks may be in use
   - Solution: Test each component independently

### Methodology Pitfalls

1. **Relying on Single Indicators:**
   - One framework indicator is insufficient for confident identification
   - Solution: Require multiple independent indicators

2. **Ignoring Version Detection:**
   - Framework version is critical for vulnerability research
   - Solution: Always attempt version detection after framework identification

3. **Neglecting Server-Side Analysis:**
   - Client-side frameworks often rely on server-side frameworks
   - Solution: Analyze both client and server components

4. **Overlooking Configuration:**
   - Framework configuration affects security posture
   - Solution: Analyze configuration files and settings when accessible

## Integration with Other Recon Areas

### Framework Identification in Recon Workflow

**1. Technology Stack Analysis:**
- Framework identification informs security testing approach
- Library detection reveals additional attack surface
- Configuration analysis reveals security controls

**2. Vulnerability Research:**
- Framework version enables targeted CVE research
- Library versions enable module-specific vulnerability hunting
- Configuration patterns indicate security control implementation

**3. Attack Surface Mapping:**
- Framework architecture defines testing boundaries
- Library ecosystem reveals additional endpoints
- Configuration patterns indicate security controls

**4. Compliance Assessment:**
- Framework versions indicate patch management status
- Library inventory reveals third-party risk
- Configuration analysis reveals security control implementation

### Cross-Reference with Other Recon Skills

- **CMS Detection:** CMS platforms often use specific frameworks
- **Server Configuration:** Framework may influence server configuration
- **SSL/TLS Analysis:** Framework may affect certificate requirements
- **HTTP Header Intelligence:** Framework generates specific header patterns

## Reporting Template

### Framework Detection Report

**Executive Summary:**
- Primary Framework: [React/Angular/Vue/etc.]
- Server-Side Framework: [Django/Flask/Rails/etc.]
- Key Libraries: [jQuery/Bootstrap/etc.]
- Confidence Level: [High/Medium/Low]

**Technical Findings:**

1. **Detection Indicators:**
   - Client-side framework: [List indicators]
   - Server-side framework: [List indicators]
   - Libraries detected: [List with versions]
   - CSS framework: [Identified framework]

2. **Version Analysis:**
   - Framework version: [Specific version if detected]
   - Library versions: [List versions]
   - Update status: [Current/Outdated]

3. **Security Implications:**
   - Known vulnerabilities: [CVEs if version-specific]
   - Attack surface: [Relevant attack vectors]
   - Configuration concerns: [Identified issues]

4. **Risk Assessment:**
   - Overall risk level: [High/Medium/Low]
   - Priority findings: [Critical issues]
   - Remediation recommendations: [Specific actions]

**Recommendations:**
1. [Framework-specific security recommendations]
2. [Update/patching recommendations]
3. [Configuration hardening suggestions]
4. [Monitoring recommendations]

**Evidence:**
- Screenshots of detection indicators
- HTTP request/response samples
- JavaScript bundle analysis
- Version detection proof

## Practice Labs

### Lab 1: Basic Framework Detection

**Objective:** Identify frameworks using passive and active fingerprinting.

**Setup:**
```bash
# Create test environment
mkdir framework-labs && cd framework-labs

# Set up different frameworks
# React app
npx create-react-app test-react

# Angular app
npx @angular/cli new test-angular

# Vue app
vue create test-vue

# Django app
django-admin startproject test-django

# Flask app
mkdir test-flask && cd test-flask
flask init-app
```

**Exercises:**
1. Deploy each framework with default configurations
2. Practice detection with WhatWeb, manual techniques
3. Document detection indicators for each framework
4. Compare detection difficulty across frameworks

### Lab 2: Obfuscated Framework Detection

**Objective:** Detect frameworks with hidden indicators.

**Setup:**
- React app with aggressive obfuscation
- Angular app with removed metadata
- Vue app with custom build configuration

**Exercises:**
1. Attempt detection using standard techniques
2. Identify subtle indicators (JavaScript patterns, bundle structure)
3. Practice timing-based detection
4. Document bypass techniques

### Lab 3: Mixed Framework Environment

**Objective:** Map frameworks across a complex web application.

**Setup:**
- Main application: React
- API backend: Express
- Admin panel: Django
- Documentation: Vue.js

**Exercises:**
1. Enumerate all application components
2. Test each component independently
3. Create comprehensive framework inventory
4. Identify security implications of mixed framework environment

## Ethical Guidelines

### Legal and Authorization Requirements

1. **Written Authorization:** Always obtain explicit written permission before testing
2. **Scope Definition:** Understand exactly what systems you're authorized to test
3. **Testing Boundaries:** Respect limits on active scanning and probing
4. **Data Handling:** Protect any discovered sensitive information
5. **Disclosure:** Follow responsible disclosure practices

### Professional Conduct

1. **Minimal Impact:** Avoid disrupting production systems
2. **Data Protection:** Don't access or exfiltrate user data
3. **Documentation:** Record all testing activities for transparency
4. **Reporting:** Provide actionable findings with remediation guidance
5. **Knowledge Sharing:** Share detection techniques with the security community

### Ethical Considerations

1. **Do No Harm:** Ensure testing doesn't harm systems or users
2. **Authorization:** Never exceed authorized testing scope
3. **Privacy:** Respect user privacy and data protection regulations
4. **Professionalism:** Maintain professional standards in all interactions
5. **Continuous Learning:** Stay updated with framework security developments

## Quick Reference Cheat Sheet

### React Detection Commands
```bash
# Quick detection
curl -s https://target.com | grep -c "data-reactroot\|__REACT_DEVTOOLS"

# Bundle analysis
curl -s https://target.com | grep -o 'src="[^"]*\.js[^"]*"'

# Version detection (if accessible)
curl -s https://target.com/static/js/main.js | grep -o "React v[0-9.]*"
```

### Angular Detection Commands
```bash
# Quick detection
curl -s https://target.com | grep -c "ng-version\|angular"

# Bundle analysis
curl -s https://target.com | grep -o 'src="[^"]*\.js[^"]*"'

# Version detection
curl -s https://target.com | grep -o "ng-version=\"[0-9.]*\""
```

### Vue.js Detection Commands
```bash
# Quick detection
curl -s https://target.com | grep -c "data-v-\|__VUE_DEVTOOLS"

# Bundle analysis
curl -s https://target.com | grep -o 'src="[^"]*\.js[^"]*"'

# Template analysis
curl -s https://target.com | grep -c "v-if\|v-for\|v-model"
```

### Server-Side Framework Detection
```bash
# Django
curl -I https://target.com/admin/
curl -s https://target.com | grep -c "csrfmiddlewaretoken"

# Laravel
curl -I https://target.com/storage/logs/laravel.log
curl -s https://target.com | grep -c "laravel_session"

# Spring Boot
curl -I https://target.com/actuator
curl -s https://target.com | grep -c "spring"

# Express
curl -s https://target.com | grep -c "express\|X-Powered-By: Express"
```

### Confidence Assessment
- **High (90%+):** Multiple independent indicators, version-specific files accessible
- **Medium (70-89%):** Several indicators, but some inconsistencies
- **Low (50-69%):** Limited indicators, possible obfuscation
- **Uncertain (<50%):** Insufficient evidence for confident identification
