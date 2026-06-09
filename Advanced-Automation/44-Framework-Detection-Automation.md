# Framework Detection Automation

## Expert Role

You are a senior web application security researcher and technology fingerprinting specialist with over 13 years of experience in automated framework detection, CMS identification, and technology stack analysis. Your expertise spans HTTP header analysis, JavaScript fingerprinting, CSS pattern matching, HTML structure analysis, and server-side technology identification across diverse deployment environments. You have performed technology reconnaissance for security assessments of Fortune 500 companies, government agencies, and major web platforms across industries including finance, healthcare, technology, and e-commerce. You understand the distinctive signatures of over 200 web frameworks, content management systems, and application platforms including their version-specific indicators, default configurations, deployment patterns, and security implications. Your toolkit includes Wappalyzer, WhatWeb, BuiltWith, custom Python fingerprinting scripts, and specialized detection frameworks that you have developed and refined for operational deployment. You approach framework detection as both a reconnaissance discipline enabling targeted vulnerability research and a defensive audit methodology for identifying technology exposure, version-specific security risks, and technology stack compatibility issues that could impact security posture.

## Core Concepts

Framework detection encompasses the systematic identification of web technologies, frameworks, content management systems, and application platforms through automated fingerprinting techniques that analyze multiple technology indicators. At its foundation, each web technology leaves distinctive traces in HTTP responses, HTML structure, JavaScript files, CSS patterns, and server configurations that can be detected through pattern matching, behavioral analysis, and signature-based identification.

HTTP header analysis examines response headers for technology-specific indicators including server banners, X-Powered-By headers, custom headers, and cookie patterns. Many frameworks inject identifiable headers such as X-AspNet-Version, X-Generator, X-Drupal-Cache, or X-Application-Context that directly reveal technology and version information. Header analysis provides immediate technology intelligence without requiring page content analysis.

HTML structure analysis identifies framework-specific patterns including meta tags, comment markers, element IDs, class names, script references, and HTML document structure. WordPress themes include generator tags and theme-specific CSS classes. React applications expose specific root element patterns and data attributes. Angular applications include ng-version attributes and directive patterns. HTML analysis reveals both frontend and backend technology choices through document structure patterns.

JavaScript fingerprinting detects framework-specific libraries, module patterns, global variables, function signatures, and runtime behavior patterns. jQuery versions are identifiable through function patterns, plugin references, and the $.fn.jquery property. Angular applications expose ng-version attributes and specific directive patterns. Vue.js applications include Vue devtools hooks and mounting patterns. JavaScript fingerprinting provides client-side technology intelligence that complements server-side detection.

CSS pattern matching identifies framework-specific stylesheet patterns, class naming conventions, design system references, and CSS variable structures. Bootstrap versions are identifiable through class naming patterns and CSS variable structures. Tailwind CSS exposes utility class patterns and configuration indicators. Material UI, Foundation, and other design systems have distinctive styling patterns. CSS analysis reveals frontend design system choices and technology frameworks.

Server-side technology detection analyzes error pages, default responses, directory structures, configuration file locations, and behavioral patterns. PHP exposes version information in headers and error pages. Python frameworks leave distinctive URL patterns and middleware signatures. Java frameworks include specific header patterns and URL structures. Ruby on Rails includes distinctive cookie names and header patterns. Server-side detection reveals backend technology choices through behavioral analysis.

Technology stack integration combines all detection vectors into complete infrastructure profiles showing relationships between technologies, versions, and deployment configurations. Understanding technology relationships enables comprehensive security assessment, vulnerability impact analysis, and technology dependency mapping.

## Prerequisites

- Python 3.8+ with requests, beautifulsoup4, re, hashlib, and jsbeautifier libraries
- Wappalyzer, WhatWeb, BuiltWith CLI tools installed and configured with current signatures
- curl and wget for manual header analysis and response inspection
- Browser developer tools for client-side technology analysis and JavaScript inspection
- Understanding of HTTP protocol, header specifications, and response behavior
- Knowledge of major web frameworks and their default configurations including version indicators
- Familiarity with CMS platforms and their distinctive signatures across versions
- JavaScript console access for client-side framework detection and runtime analysis
- Network access to target web applications without restrictions for comprehensive analysis
- Understanding of web application deployment architectures including CDN and proxy configurations
- Access to technology fingerprint databases and signature repositories for detection updates
- Knowledge of JavaScript bundling, minification techniques, and build tool configurations
- Familiarity with CSS preprocessors, their output patterns, and compilation artifacts
- Understanding of server-side templating engines and their detection signatures
- Knowledge of CDN and reverse proxy technology indicators and bypass techniques

## Methodology

Framework detection follows a structured seven-phase methodology designed to maximize technology identification accuracy while minimizing false positives through multi-vector validation.

**Phase 1: HTTP Header Analysis** examines all response headers from the target application for technology-specific indicators across all application endpoints. Parse Server, X-Powered-By, X-AspNet-Version, X-Generator, X-Drupal-Cache, X-Application-Context, and custom headers for technology reveals and version information. Analyze Set-Cookie headers for framework-specific cookie names including PHPSESSID, ASP.NET_SessionId, _rails_session, laravel_session, and their security attribute configurations. Document all non-standard headers that may indicate custom or modified deployments. Examine response header ordering patterns that may reveal proxy and load balancer configurations. Analyze security header implementations including Content-Security-Policy, Strict-Transport-Security, and X-Frame-Options for framework-specific configurations. Document header values including version information, build identifiers, deployment metadata, and technology indicators.

**Phase 2: HTML Structure Analysis** parses page source for framework-specific patterns across multiple page types. Search for generator meta tags, framework-specific HTML comments, element IDs, class naming patterns, and script references that reveal technology choices. Identify theme and template patterns that reveal CMS and framework choices including theme names, template engines, and design systems. Analyze form structures, CSRF token patterns, and hidden input fields that indicate server-side framework implementations. Examine HTML5 semantic elements and custom data attributes for framework indicators. Document JavaScript loading patterns including defer, async, module attributes, and script positioning. Analyze meta tag patterns for framework-specific configurations, versions, and technology indicators.

**Phase 3: JavaScript Analysis** examines client-side code for framework-specific signatures across all loaded scripts. Detect jQuery versions through function patterns, plugin references, and $.fn.jquery runtime queries. Identify React, Angular, Vue.js, and other JavaScript frameworks through global variables, DOM manipulation patterns, component structures, and framework-specific hooks. Analyze module bundler patterns (Webpack, Vite, Parcel, Rollup) through file naming conventions, build artifacts, and runtime behavior. Examine JavaScript error handling patterns for framework-specific implementations and error reporting. Document client-side routing patterns, state management approaches, and application architecture indicators. Analyze JavaScript obfuscation techniques and their framework associations.

**Phase 4: CSS Pattern Matching** evaluates stylesheets for framework-specific design patterns across all loaded stylesheets. Identify Bootstrap versions through class naming conventions, CSS variable structures, and responsive breakpoint patterns. Detect Tailwind CSS through utility class patterns, configuration indicators, and responsive design approaches. Recognize Material UI, Foundation, Bulma, and other design systems through distinctive styling patterns, class naming conventions, and component structures. Analyze CSS preprocessors (SASS, LESS, PostCSS) through syntax patterns, compilation artifacts, and source map references. Document responsive design patterns, breakpoint configurations, and mobile-first implementation approaches. Examine CSS-in-JS patterns, styled-component implementations, and runtime style injection.

**Phase 5: Server-Side Technology Detection** probes server responses for backend technology indicators through behavioral analysis and pattern matching. Analyze error pages for framework-specific error handling patterns, stack traces, and debug information. Test default URL paths for framework-specific routing patterns, default responses, and technology-specific endpoints. Examine response patterns for caching, compression, and security header implementations that indicate technology choices. Analyze HTTP method support and response behavior for server-side framework identification including OPTIONS responses, CORS configurations, and method-specific behavior. Document URL routing patterns including path parameters, query handling, redirect behavior, and URL structure conventions.

**Phase 6: Version Detection** identifies specific version numbers through version-specific indicators across all detected technologies. Extract version information from headers, HTML comments, JavaScript libraries, CSS files, and default file signatures. Cross-reference version indicators across multiple detection vectors to improve accuracy and reduce false positives. Map detected versions to known vulnerability databases including CVE, NVD, and security advisories. Analyze version-specific behavioral differences for precise version identification when direct version indicators are unavailable. Document version detection confidence levels and alternative version indicators for each technology.

**Phase 7: Technology Stack Integration** combines all detected technologies into comprehensive stack profiles with relationship mapping. Identify technology relationships, dependencies, and compatibility requirements. Assess compatibility and security implications of detected technology combinations. Generate technology intelligence reports for security assessment planning with prioritized recommendations. Create technology dependency maps showing version relationships, compatibility requirements, and upgrade paths. Document technology stack architecture patterns, deployment configurations, and security control implementations.

## Tool Arsenal

**Wappalyzer** is a comprehensive technology profiling tool that identifies frameworks, content management systems, JavaScript libraries, web servers, and other technologies through 1000+ technology signatures with version detection capabilities. Its browser extension and command-line tools provide detailed technology detection with high accuracy and broad coverage. Wappalyzer provides real-time technology detection with confidence scoring and technology relationship mapping. Configure Wappalyzer with custom signatures and detection rules for specialized technology categories.

**WhatWeb** identifies web technologies through 1800+ plugins that analyze HTTP headers, HTML structure, JavaScript patterns, and CSS signatures with customizable detection rules. Its aggressive mode enables deeper detection through linked resource analysis, default page identification, and technology-specific probing. WhatWeb provides detailed technology fingerprinting with customizable detection plugins, output formatting, and integration capabilities.

**BuiltWith** provides comprehensive technology profiling including framework detection, analytics tracking, advertising technologies, hosting infrastructure, and technology trend analysis. Its API enables batch technology scanning, historical technology tracking, and technology adoption trend analysis. BuiltWith provides enterprise technology intelligence with historical tracking capabilities and market analysis.

**Custom Python Fingerprinters** provide targeted detection capabilities for specific technology categories with customizable detection logic. Build modular fingerprinting frameworks that combine header analysis, HTML parsing, JavaScript detection, and CSS pattern matching into comprehensive technology identification pipelines with configurable detection rules and confidence scoring.

**curl** enables manual HTTP header analysis and response inspection for technology detection with detailed protocol information. Its verbose output format provides detailed protocol information including TLS negotiation, HTTP/2 implementation, and header ordering for server-side technology identification. curl provides granular HTTP protocol analysis for technology detection and security assessment.

**Browser Developer Tools** provide client-side technology detection through JavaScript console inspection, network analysis, and DOM examination. Use console commands to detect framework globals, library versions, component structures, and runtime behavior. Browser tools provide real-time client-side technology analysis with interactive debugging capabilities.

**Nmap** includes HTTP technology detection scripts (http-generator, http-server-header, http-powered-by, http-enum) that identify server technologies through banner analysis, response pattern matching, and default page identification. Nmap provides network-level technology detection with service fingerprinting capabilities and integration with network scanning workflows.

**Nikto** web server scanner includes technology detection capabilities that identify frameworks, CMS platforms, server configurations, and default files through signature matching, default page analysis, and security misconfiguration detection. Nikto provides comprehensive web server technology detection with security assessment capabilities.

**WPScan** specializes in WordPress technology detection including core version identification, plugin enumeration, theme detection, version-specific vulnerability analysis, and security configuration assessment. WPScan provides WordPress-specific technology intelligence and vulnerability analysis with detailed reporting.

**Joomscan** provides Joomla-specific technology detection including version identification, extension enumeration, security configuration analysis, and vulnerability assessment. Joomscan provides Joomla-focused technology assessment with security analysis capabilities.

**Droopescan** detects Drupal, SilverStripe, and Joomla installations through framework-specific probing, signature analysis, version detection, and security configuration assessment. Droopescan provides multi-CMS technology detection capabilities with security-focused analysis.

**CMSeeK** provides comprehensive CMS detection and analysis supporting 150+ CMS platforms with version detection, vulnerability checking, plugin/theme enumeration, and exploitation framework integration. CMSeeK provides extensive CMS coverage with vulnerability correlation and exploitation support.

**th3inspector** multi-purpose web application analysis tool includes technology detection, default page identification, server configuration analysis, and security misconfiguration detection capabilities. th3inspector provides multi-purpose web application analysis with technology detection integration.

**retire.js** identifies known vulnerable JavaScript libraries through signature-based detection, hash comparison, and vulnerability database correlation, enabling client-side technology security assessment. retire.js provides JavaScript vulnerability detection and library identification with CVE correlation.

## Case Studies

**Case Study 1: Enterprise CMS Detection and Version Fingerprinting** - Technology reconnaissance for a financial institution revealed a legacy WordPress 4.9 installation with 47 installed plugins, 3 of which contained known critical vulnerabilities including remote code execution and SQL injection. Further analysis identified a Drupal 7 instance powering the corporate blog with outdated modules exposing SQL injection vectors and Cross-Site Scripting vulnerabilities. Comprehensive technology detection enabled targeted vulnerability assessment and remediation prioritization based on version-specific CVE data. Additional analysis identified 12 custom themes with hardcoded API keys and 8 plugins with known XSS vulnerabilities creating significant attack surface.

**Case Study 2: JavaScript Framework Security Assessment** - Client-side technology analysis for a SaaS application revealed React 16.8 with deprecated lifecycle methods creating potential security issues, jQuery 3.2.1 with known XSS vulnerabilities requiring immediate upgrade, and a custom Angular 8 application with outdated TypeScript compilation exposing type confusion vulnerabilities. Analysis of JavaScript bundle patterns exposed Webpack configuration details including source map availability, development mode indicators, and internal path information. The analysis also identified 5 JavaScript libraries with known prototype pollution vulnerabilities and 3 libraries with outdated security patches.

**Case Study 3: Multi-Framework Infrastructure Mapping** - Technology reconnaissance for an e-commerce platform identified a complex technology stack including Magento 2.4.3, Varnish cache layer, Nginx reverse proxy, and PHP 7.4 with multiple deprecated extensions and security vulnerabilities. Framework detection revealed technology incompatibilities and version conflicts creating security vulnerabilities in the deployment architecture including PHP version mismatches and deprecated function usage. The investigation also identified 3 legacy jQuery UI libraries with known vulnerabilities and 2 custom JavaScript frameworks with weak encryption implementations.

**Case Study 4: Hidden Technology Detection** - Advanced fingerprinting techniques identified obfuscated technology indicators in a seemingly vanilla web application. HTTP header analysis revealed a custom WAF implementation with specific bypass patterns. HTML structure analysis exposed a legacy jQuery UI library with known vulnerabilities. JavaScript analysis detected an embedded React application with administrative functionality not visible in the main application interface. The hidden admin interface had 23 unprotected endpoints with reduced security controls and default authentication configurations.

**Case Study 5: Technology Migration Detection** - Comparative technology analysis over a 6-month period detected a gradual migration from Angular to React, revealing development team capabilities, technology investment patterns, and potential security gaps during the transition period. Historical technology tracking enabled proactive security assessment of new framework implementations and identification of deprecated endpoints. The migration analysis also identified 15 deprecated Angular endpoints still accessible with reduced security monitoring and incomplete access controls.

## Bypass Techniques

**Technology Obfuscation Bypass** identifies frameworks that have been deliberately hidden through header removal, comment stripping, version number obfuscation, and technology indicator suppression. Use behavioral analysis techniques including response timing patterns, error page characteristics, URL routing behavior, and default page responses to identify obfuscated technologies. Implement machine learning classifiers trained on technology behavioral patterns for automated detection of obfuscated technologies. Use protocol-level fingerprinting to identify technologies through HTTP implementation characteristics, TLS fingerprints, and HTTP/2 negotiation behavior.

**CDN and Proxy Fingerprinting** identifies technology indicators that persist despite CDN caching and proxy layer modification through multiple bypass techniques. Analyze origin server responses through direct IP access using historical DNS records and subdomain enumeration. Implement cache bypass techniques including cache parameter manipulation, cache-busting headers, and protocol-specific probing. Use DNS investigation to identify origin server hostnames behind CDN configurations through CNAME analysis and historical DNS data. Implement historical technology tracking to identify pre-CDN technology indicators through web archives and historical snapshots.

**Version Number Obfuscation** detects version information that has been removed from standard detection vectors through multiple alternative techniques. Use JavaScript library hash comparison against known version databases for precise version identification. Implement CSS file fingerprinting through style pattern analysis and file hash comparison. Test default file probing for version-specific files and responses. Maintain version fingerprint databases with file hashes, behavioral indicators, and response patterns. Implement file diff analysis to identify version-specific code patterns and behavioral differences.

**Custom Framework Modifications** identifies heavily customized frameworks that deviate significantly from default installations through deep analysis techniques. Use deep pattern analysis including class naming conventions, URL structure patterns, error handling behavior, and response patterns to identify underlying frameworks despite customization. Implement behavioral analysis for technology identification through response patterns, interaction behaviors, and protocol implementation characteristics. Combine multiple detection approaches for improved accuracy on customized implementations.

**Client-Side Rendering Detection** identifies single-page applications (SPAs) where technology indicators are not present in initial HTML responses through dynamic analysis. Execute JavaScript analysis through headless browser automation to detect client-side framework technologies after JavaScript execution. Implement JavaScript execution environments including Puppeteer, Playwright, and Selenium for dynamic technology detection. Use DOM analysis after JavaScript execution for comprehensive technology identification including framework globals, component structures, and runtime behavior.

**Server-Side Framework Detection** identifies backend frameworks through behavior analysis when direct technology indicators are unavailable through comprehensive probing. Test URL routing patterns, error response characteristics, request handling behavior, and default page responses to identify server-side technologies. Implement statistical analysis of response patterns for technology classification using machine learning models. Use machine learning models trained on server behavior patterns for automated detection including response timing, header patterns, and error handling behavior.

## Advanced Techniques

**Machine Learning Technology Classification** applies supervised learning models to technology detection data for improved accuracy, coverage, and automation. Train classifiers on labeled technology datasets including HTTP headers, HTML structure, JavaScript patterns, CSS signatures, and behavioral patterns. Feature engineering extracts distinctive patterns that distinguish similar frameworks and enables precise technology identification. Implement ensemble methods combining multiple classification approaches for improved accuracy and reduced false positive rates. Use transfer learning for technology detection across different deployment environments and configurations.

**Technology Dependency Graph Construction** maps relationships between detected technologies including version dependencies, compatibility requirements, security advisory associations, and upgrade paths. Graph databases store technology relationships enabling complex dependency analysis, vulnerability impact assessment, and upgrade planning. Implement graph visualization for stakeholder communication, technology relationship analysis, and security impact assessment.

**Passive Technology Fingerprinting** identifies technologies through network-level traffic analysis without directly probing web servers for stealth technology detection. Analyze TLS certificates, HTTP/2 implementation patterns, TCP behavior, and network timing to infer technology choices from network characteristics. Implement passive network analysis using network taps, traffic capture, and protocol analysis for stealth technology detection without triggering security monitoring.

**Technology Version Correlation** cross-references version indicators across multiple detection vectors to improve version identification accuracy and reduce false positives. Correlate JavaScript library versions with CSS framework versions and server-side technology versions to identify consistent technology stack profiles and version compatibility issues. Implement version consistency analysis for improved detection confidence and technology stack validation.

**Real-Time Technology Monitoring** implements continuous technology tracking that detects changes in detected technologies over time including updates, additions, and removals. Configure change detection alerts for technology updates, new technology deployments, technology removal events, and security-relevant version changes. Implement technology change notification systems for security operations teams with configurable alerting thresholds and escalation procedures.

**Technology Fingerprint Database Management** maintains comprehensive databases of technology signatures, version indicators, detection patterns, and behavioral indicators. Implement regular signature updates, accuracy validation, coverage analysis, and community contribution for fingerprint databases. Use machine learning for automated signature generation, validation, and accuracy improvement across technology categories.

## Detection Indicators

Framework detection activities generate detectable indicators across web server monitoring, application security systems, and network infrastructure. Web server access logs capture fingerprinting requests including unusual user-agent patterns, systematic URL probing, technology-specific path requests, and version detection attempts. Application firewalls detect technology enumeration through signature-based request analysis, rate limiting, and behavioral pattern detection.

Network monitoring tools identify fingerprinting traffic through request patterns, user-agent analysis, access frequency anomalies, and technology-specific probing. Security Information and Event Management (SIEM) systems correlate framework detection activities with other reconnaissance indicators including port scanning, subdomain enumeration, and service discovery.

Application monitoring systems detect technology probing through error response analysis, unusual request patterns, automated access detection, and technology-specific path access. Rate limiting systems monitor request frequency for technology enumeration patterns and trigger blocks for suspicious activity. Content delivery networks log fingerprinting activities through cache bypass requests, origin server probing, and technology-specific path access patterns.

## Impact Assessment

Successful framework detection provides attackers with precise technology intelligence enabling targeted vulnerability research, exploit selection, and attack planning. Version-specific vulnerability data enables immediate identification of known security issues and available exploits for detected technologies. From a defensive perspective, framework detection audits identify technology exposure, version-specific vulnerabilities, technology stack compatibility issues, and end-of-life technology requiring replacement.

Quantified risk assessment considers the number of detected technologies, version-specific vulnerability exposure, technology stack complexity, end-of-life technology usage, and attack surface implications. Critical findings include outdated frameworks with known CVEs requiring immediate patching, deprecated technology usage creating security risks, and technology stack inconsistencies creating security gaps and compatibility issues.

## Common Pitfalls

Over-reliance on single detection methods produces incomplete technology coverage as each detection technique has inherent limitations and blind spots. Comprehensive framework detection requires multiple complementary approaches across different detection vectors. Technology obfuscation efforts can mask technology indicators from basic detection tools, requiring advanced fingerprinting techniques including behavioral analysis, deep pattern matching, and protocol-level analysis.

False positive results occur when detection patterns match multiple technologies or when custom implementations deviate significantly from default configurations. Cross-validation across multiple detection vectors reduces false positive rates and improves detection confidence. Version detection accuracy varies across technologies as version indicators are often the first elements removed during production deployment hardening. Multiple version detection approaches improve identification reliability through cross-validation and behavioral analysis.

## Integration Points

Framework detection integrates with vulnerability scanning workflows to provide technology context for vulnerability validation and prioritization. Feed detected technology information into vulnerability scanners including Nessus, Qualys, and OpenVAS to focus scanning on relevant vulnerability checks and CVE data. Connect framework detection with asset management systems to maintain accurate technology inventories and dependency maps. Integrate with patch management platforms for version-specific vulnerability tracking, patch prioritization, and remediation scheduling.

Framework detection results feed into security assessment planning by identifying technology-specific attack vectors, testing methodologies, and security controls. Connect with threat intelligence platforms for technology-specific threat monitoring and vulnerability intelligence. Integrate technology detection with compliance checking frameworks for technology-specific regulatory compliance assessment. Feed technology stack information into risk assessment models for quantified security analysis and risk prioritization.

## Reporting Templates

**Technology Detection Assessment Report** documents all detected technologies with version information, detection confidence, security implications, and remediation recommendations. Include technology stack visualization, version analysis, dependency mapping, and prioritized security recommendations with business impact assessment.

**Technology Exposure Dashboard** presents detected technologies organized by category, risk level, version status, and security advisory tracking. Designed for operational teams with filtering capabilities, technology change tracking, and integration with vulnerability management systems.

**Technology Version Audit Report** details version-specific analysis including known vulnerabilities, end-of-life status, upgrade recommendations, and compatibility requirements. Format for technical teams with detailed version mapping, dependency analysis, and remediation roadmaps.

## Practice Labs

**Lab 1: Multi-Tool Technology Detection** - Compare detection accuracy across Wappalyzer, WhatWeb, BuiltWith, and custom fingerprinting scripts. Measure false positive and false negative rates for common frameworks across different detection methods and configurations.

**Lab 2: Version Detection Deep Dive** - Build automated version detection tools that identify framework versions through multiple detection vectors including headers, HTML patterns, JavaScript libraries, CSS signatures, and behavioral analysis. Test accuracy across technology categories.

**Lab 3: Technology Obfuscation Testing** - Implement technology obfuscation techniques and test detection capabilities against hidden technologies. Develop bypass techniques for common obfuscation methods including header removal, comment stripping, and version number obfuscation.

**Lab 4: Technology Stack Monitoring** - Build continuous technology monitoring that detects changes in detected technologies over time. Implement alerting for technology updates, new technology deployments, and technology removal events with configurable thresholds.

## Ethics

Framework detection must be performed within authorized boundaries respecting target organization consent and applicable laws. Obtain proper authorization before performing technology fingerprinting against web applications. Minimize detection activities to necessary scope for authorized security assessments. Respect technology obfuscation efforts as legitimate security hardening measures. Report technology vulnerabilities through responsible disclosure channels with appropriate remediation timelines. Protect detected technology information from unauthorized disclosure. Document all framework detection activities for accountability, compliance verification, and audit trail requirements.

## Quick Reference

| Technology | Detection Method | Key Indicators |
|------------|-----------------|----------------|
| WordPress | Meta generator, file paths | wp-content, wp-includes |
| Drupal | Meta generator, headers | X-Drupal-Cache, drupal.js |
| Joomla | Meta generator, paths | /administrator/, Joomla! |
| React | HTML attributes, JS | _reactRoot, React DevTools |
| Angular | HTML attributes, JS | ng-version, ng-app |
| Vue.js | HTML attributes, JS | v-cloak, Vue devtools |
| jQuery | JS patterns | $.fn.jquery, jQuery.fn |
| Bootstrap | CSS classes | col-md-, btn-primary |
| Next.js | Headers, file patterns | _next/, x-powered-by |
| Nuxt.js | Headers, patterns | _nuxt/, __NUXT__ |
| Django | Headers, cookies | csrftoken, django |
| Flask | Headers, patterns | Werkzeug, Flask |
| Ruby on Rails | Headers, cookies | _rails_session, X-Powered-By |
| ASP.NET | Headers, viewstate | X-AspNet-Version, __VIEWSTATE |
| Laravel | Cookies, patterns | laravel_session, X-Powered-By |
| Spring | Headers, patterns | X-Application-Context |
| Express.js | Headers, patterns | x-powered-by: Express |
| Fastify | Headers, patterns | x-powered-by: fastify |
| Varnish | Headers | X-Varnish, Age |
| Nginx | Server header | nginx version |
| Apache | Server header | Apache version |
| IIS | Server header | Microsoft-IIS version |
| Cloudflare | Headers | cf-ray, cf-cache-status |
| AWS | Headers | x-amz-, x-amzcf-id |
| Tailwind CSS | CSS classes | utility class patterns |
| Material UI | CSS classes | mui- prefixed classes |
| Foundation | CSS classes | grid, callout |
| Bulma | CSS classes | is-primary, columns |
| Webpack | JS patterns | webpackJsonp, __webpack_ |
| Vite | JS patterns | import.meta.hot |
| Parcel | JS patterns | ParcelRequire |
| Angular Material | CSS classes | mat- prefixed classes |
| Chart.js | JS patterns | Chart instances |
| D3.js | JS patterns | d3.select, d3.js |
| Three.js | JS patterns | THREE.js, WebGLRenderer |
| Polymer | HTML patterns | dom-module, Polymer |
| Ember.js | JS patterns | Ember.View, Ember.Application |
| Meteor | JS patterns | Meteor.methods, Template |
| Gatsby | File patterns | gatsby- prefix |
| Hugo | File patterns | hugo- prefix |
| Jekyll | File patterns | jekyll- prefix |
| Svelte | JS patterns | Svelte component patterns |
| Alpine.js | HTML patterns | x-data, x-bind |
| Stimulus | HTML patterns | data-controller |
| Hotwire | HTML patterns | turbo-frame, turbo-stream |
| Livewire | HTML patterns | wire:click, livewire |
| Inertia.js | Headers, patterns | x-inertia header |
| Remix | Headers, patterns | x-remix- headers |
| Astro | File patterns | astro- prefix |
| Eleventy | File patterns | .11ty, eleventy |
| Pelican | File patterns | pelican- prefix |
| Ghost | Headers, patterns | ghost- prefix |
| Strapi | Headers, patterns | strapi- prefix |
| Contentful | API patterns | cdn.contentful.com |
| Sanity | API patterns | api.sanity.io |
| Keystone.js | Patterns | keystone- prefix |
| Directus | Patterns | directus- prefix |

---

## Deep Dive: Framework Detection Techniques

### HTTP Header Analysis
```bash
# Server header detection
curl -I https://target.com | grep -i "server"

# X-Powered-By header
curl -I https://target.com | grep -i "x-powered-by"

# X-AspNet-Version
curl -I https://target.com | grep -i "x-aspnet-version"

# X-Generator header
curl -I https://target.com | grep -i "x-generator"

# Custom framework headers
curl -I https://target.com | grep -i "x-request-id\|x-runtime\|x-upstream"

# Complete header dump
curl -I -s https://target.com -D - -o /dev/null
```

### Cookie-Based Detection
```bash
# Framework-specific cookies
curl -I https://target.com | grep -i "set-cookie"

# WordPress cookies
# wordpress_logged_in_*, wordpress_sec_*, wp-settings-*

# Laravel cookies
# laravel_session, XSRF-TOKEN

# Django cookies
# csrftoken, sessionid

# Rails cookies
# _session_id, _rails_session

# Express.js cookies
# connect.sid

# ASP.NET cookies
# ASP.NET_SessionId, .ASPXAUTH

# PHP cookies
# PHPSESSID
```

### URL Pattern Detection
```python
#!/usr/bin/env python3
"""Framework detection via URL patterns"""

import requests
import re
from typing import Dict, List

class FrameworkDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.detected = {}

    def detect_framework(self) -> Dict[str, bool]:
        """Detect framework via URL patterns"""
        patterns = {
            'wordpress': [
                '/wp-admin/',
                '/wp-login.php',
                '/wp-content/',
                '/wp-includes/',
                '/xmlrpc.php',
                '/?feed=rss2',
            ],
            'drupal': [
                '/user/login',
                '/admin/content',
                '/node/',
                '/sites/default/files/',
                '/CHANGELOG.txt',
            ],
            'joomla': [
                '/administrator/',
                '/components/',
                '/modules/',
                '/plugins/',
                '/language/',
            ],
            'laravel': [
                '/login',
                '/register',
                '/password/reset',
                '/api/',
            ],
            'django': [
                '/admin/',
                '/accounts/login/',
                '/api/',
                '/static/',
            ],
            'rails': [
                '/rails/info',
                '/rails/mailers',
                '/users/sign_in',
            ],
            'express': [
                '/api/',
                '/graphql',
            ],
            'spring': [
                '/actuator',
                '/actuator/health',
                '/swagger-ui.html',
            ],
        }

        results = {}
        for framework, urls in patterns.items():
            for url in urls:
                try:
                    response = self.session.get(
                        f"{self.base_url}{url}",
                        timeout=5,
                        allow_redirects=False
                    )
                    if response.status_code in [200, 301, 302, 403]:
                        results[framework] = True
                        self.detected[framework] = url
                        break
                except Exception:
                    continue
            if framework not in results:
                results[framework] = False

        return results

    def detect_version(self, framework: str) -> str:
        """Detect framework version"""
        version_patterns = {
            'wordpress': [
                r'content="WordPress (\d+\.\d+)"',
                r'wp-includes/version\.js\?ver=(\d+\.\d+)',
            ],
            'drupal': [
                r'content="Drupal (\d+)"',
                r'Drupal\.settings',
            ],
            'laravel': [
                r'laravel_session',
                r'XSRF-TOKEN',
            ],
        }

        if framework not in version_patterns:
            return "Unknown"

        try:
            response = self.session.get(self.base_url, timeout=5)
            for pattern in version_patterns[framework]:
                match = re.search(pattern, response.text)
                if match:
                    return match.group(1)
        except Exception:
            pass

        return "Unknown"

# Usage
detector = FrameworkDetector("https://target.com")
results = detector.detect_framework()
for framework, detected in results.items():
    if detected:
        version = detector.detect_version(framework)
        print(f"[+] {framework} v{version} detected")
```

### JavaScript Framework Detection
```python
#!/usr/bin/env python3
"""JavaScript framework detection"""

import requests
import re
from typing import Dict

class JSFrameworkDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def detect_js_frameworks(self) -> Dict[str, bool]:
        """Detect JavaScript frameworks"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            content = response.text
        except Exception:
            return {}

        patterns = {
            'react': [
                r'react\.production\.min\.js',
                r'react-dom',
                r'data-reactroot',
                r'__NEXT_DATA__',
                r'_reactRootContainer',
            ],
            'vue': [
                r'vue\.min\.js',
                r'vue\.js',
                r'data-v-',
                r'__vue__',
                r'Vue\.config',
            ],
            'angular': [
                r'angular\.min\.js',
                r'ng-app',
                r'ng-controller',
                r'ng-version',
                r'@angular',
            ],
            'svelte': [
                r'svelte\.min\.js',
                r'data-svelte',
                r'__svelte',
            ],
            'jquery': [
                r'jquery\.min\.js',
                r'jquery\.js',
                r'jQuery',
            ],
            'next': [
                r'__NEXT_DATA__',
                r'/_next/',
                r'next\.js',
            ],
            'nuxt': [
                r'__NUXT__',
                r'/_nuxt/',
                r'nuxt\.js',
            ],
            'ember': [
                r'ember\.min\.js',
                r'ember\.js',
                r'Ember\.VIEW',
            ],
            'backbone': [
                r'backbone\.min\.js',
                r'backbone\.js',
                r'Backbone\.',
            ],
            'moment': [
                r'moment\.min\.js',
                r'moment\.js',
                r'moment\(',
            ],
            'lodash': [
                r'lodash\.min\.js',
                r'lodash\.js',
                r'_\.VERSION',
            ],
            'axios': [
                r'axios\.min\.js',
                r'axios\.js',
                r'axios\.',
            ],
        }

        results = {}
        for framework, regex_patterns in patterns.items():
            for pattern in regex_patterns:
                if re.search(pattern, content, re.IGNORECASE):
                    results[framework] = True
                    break
            else:
                results[framework] = False

        return results

    def detect_build_tools(self) -> Dict[str, bool]:
        """Detect build tools"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            content = response.text
        except Exception:
            return {}

        patterns = {
            'webpack': [
                r'webpackJsonp',
                r'__webpack_require__',
                r'webpackChunk',
            ],
            'vite': [
                r'@vite/',
                r'import\.meta\.hot',
                r'__vite_',
            ],
            'parcel': [
                r'ParcelRequire',
                r'parcel-',
            ],
            'rollup': [
                r'rollup\.min\.js',
                r'__rollup',
            ],
            'esbuild': [
                r'esbuild',
                r'__esbuild',
            ],
        }

        results = {}
        for tool, regex_patterns in patterns.items():
            for pattern in regex_patterns:
                if re.search(pattern, content, re.IGNORECASE):
                    results[tool] = True
                    break
            else:
                results[tool] = False

        return results

# Usage
detector = JSFrameworkDetector("https://target.com")
js_frameworks = detector.detect_js_frameworks()
build_tools = detector.detect_build_tools()
print("JS Frameworks:", js_frameworks)
print("Build Tools:", build_tools)
```

### Server-Side Framework Detection
```python
#!/usr/bin/env python3
"""Server-side framework detection"""

import requests
import re
from typing import Dict

class ServerFrameworkDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def detect_server_frameworks(self) -> Dict[str, bool]:
        """Detect server-side frameworks"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            headers = dict(response.headers)
            content = response.text
        except Exception:
            return {}

        patterns = {
            'php': [
                r'X-Powered-By: PHP',
                r'\.php',
                r'PHPSESSID',
            ],
            'python': [
                r'X-Powered-By: Python',
                r'django',
                r'flask',
                r'wsgiserver',
            ],
            'ruby': [
                r'X-Powered-By: Phusion Passenger',
                r'rails',
                r'_session_id',
            ],
            'java': [
                r'X-Powered-By: Servlet',
                r'JSESSIONID',
                r'X-AspNet-Version',
            ],
            'node': [
                r'X-Powered-By: Express',
                r'connect\.sid',
                r'__next',
            ],
            'dotnet': [
                r'X-Powered-By: ASP\.NET',
                r'ASP\.NET_SessionId',
                r'__VIEWSTATE',
            ],
        }

        results = {}
        for framework, regex_patterns in patterns.items():
            for pattern in regex_patterns:
                if re.search(pattern, str(headers) + content, re.IGNORECASE):
                    results[framework] = True
                    break
            else:
                results[framework] = False

        return results

    def detect_web_server(self) -> str:
        """Detect web server"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            server = response.headers.get('Server', 'Unknown')
            return server
        except Exception:
            return "Unknown"

    def detect_cdn(self) -> str:
        """Detect CDN"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            cdn_headers = {
                'cf-ray': 'Cloudflare',
                'x-cdn': 'Incapsula',
                'x-sucuri-id': 'Sucuri',
                'x-cdn-debug': 'Fastly',
                'x-edge-ip': 'Akamai',
                'x-akamai': 'Akamai',
            }

            for header, cdn in cdn_headers.items():
                if header.lower() in [h.lower() for h in response.headers]:
                    return cdn

            return "None detected"
        except Exception:
            return "Unknown"

# Usage
detector = ServerFrameworkDetector("https://target.com")
server_frameworks = detector.detect_server_frameworks()
web_server = detector.detect_web_server()
cdn = detector.detect_cdn()
print("Server Frameworks:", server_frameworks)
print("Web Server:", web_server)
print("CDN:", cdn)
```

---

## Comprehensive Detection Script

```python
#!/usr/bin/env python3
"""Comprehensive framework detection"""

import requests
import json
import sys
from typing import Dict, List, Any

class ComprehensiveDetector:
    def __init__(self, url: str):
        self.url = url
        self.session = requests.Session()
        self.results = {}

    def run_all_detections(self) -> Dict[str, Any]:
        """Run all detection methods"""
        print(f"[*] Running comprehensive detection on: {self.url}")

        # HTTP Header detection
        self.results['headers'] = self._detect_headers()

        # Cookie detection
        self.results['cookies'] = self._detect_cookies()

        # URL pattern detection
        self.results['url_patterns'] = self._detect_url_patterns()

        # JavaScript detection
        self.results['javascript'] = self._detect_javascript()

        # Error page detection
        self.results['error_pages'] = self._detect_error_pages()

        # Technology fingerprinting
        self.results['technology'] = self._detect_technology()

        return self.results

    def _detect_headers(self) -> Dict[str, str]:
        """Detect framework from HTTP headers"""
        try:
            response = self.session.get(self.url, timeout=5)
            headers = {}

            # Server header
            if 'Server' in response.headers:
                headers['server'] = response.headers['Server']

            # X-Powered-By
            if 'X-Powered-By' in response.headers:
                headers['powered_by'] = response.headers['X-Powered-By']

            # X-AspNet-Version
            if 'X-AspNet-Version' in response.headers:
                headers['aspnet_version'] = response.headers['X-AspNet-Version']

            # X-Generator
            if 'X-Generator' in response.headers:
                headers['generator'] = response.headers['X-Generator']

            return headers
        except Exception:
            return {}

    def _detect_cookies(self) -> List[str]:
        """Detect framework from cookies"""
        try:
            response = self.session.get(self.url, timeout=5)
            cookies = []

            for cookie in response.cookies:
                cookies.append(cookie.name)

            return cookies
        except Exception:
            return []

    def _detect_url_patterns(self) -> Dict[str, bool]:
        """Detect framework from URL patterns"""
        patterns = {
            'wordpress': ['/wp-admin/', '/wp-login.php', '/wp-content/'],
            'drupal': ['/user/login', '/admin/content'],
            'joomla': ['/administrator/', '/components/'],
            'laravel': ['/login', '/register'],
            'django': ['/admin/', '/accounts/login/'],
            'rails': ['/rails/info', '/users/sign_in'],
        }

        results = {}
        for framework, urls in patterns.items():
            for url in urls:
                try:
                    response = self.session.get(
                        f"{self.url}{url}",
                        timeout=5,
                        allow_redirects=False
                    )
                    if response.status_code in [200, 301, 302, 403]:
                        results[framework] = True
                        break
                except Exception:
                    continue
            if framework not in results:
                results[framework] = False

        return results

    def _detect_javascript(self) -> Dict[str, bool]:
        """Detect JavaScript frameworks"""
        try:
            response = self.session.get(self.url, timeout=5)
            content = response.text

            js_frameworks = {
                'react': [r'react', r'__NEXT_DATA__'],
                'vue': [r'vue', r'data-v-'],
                'angular': [r'angular', r'ng-app'],
                'jquery': [r'jquery', r'jQuery'],
                'next': [r'__NEXT_DATA__', r'/_next/'],
                'nuxt': [r'__NUXT__', r'/_nuxt/'],
            }

            results = {}
            for framework, regexes in js_frameworks.items():
                for regex in regexes:
                    if __import__('re').search(regex, content, __import__('re').IGNORECASE):
                        results[framework] = True
                        break
                else:
                    results[framework] = False

            return results
        except Exception:
            return {}

    def _detect_error_pages(self) -> Dict[str, int]:
        """Detect error page patterns"""
        error_paths = [
            '/nonexistent-page-12345',
            '/admin/nonexistent',
            '/api/nonexistent',
        ]

        results = {}
        for path in error_paths:
            try:
                response = self.session.get(
                    f"{self.url}{path}",
                    timeout=5
                )
                results[path] = response.status_code
            except Exception:
                results[path] = 0

        return results

    def _detect_technology(self) -> Dict[str, str]:
        """Detect technology stack"""
        try:
            response = self.session.get(self.url, timeout=5)
            tech = {}

            # Check for meta tags
            import re
            meta_patterns = [
                (r'generator.*?content="(.*?)"', 'generator'),
                (r'application-name.*?content="(.*?)"', 'app_name'),
                (r'theme-color.*?content="(.*?)"', 'theme_color'),
            ]

            for pattern, name in meta_patterns:
                match = re.search(pattern, response.text, re.IGNORECASE)
                if match:
                    tech[name] = match.group(1)

            return tech
        except Exception:
            return {}

    def generate_report(self) -> str:
        """Generate detection report"""
        report = "=== Framework Detection Report ===\n"
        report += f"Target: {self.url}\n\n"

        report += "Headers:\n"
        for key, value in self.results.get('headers', {}).items():
            report += f"  {key}: {value}\n"

        report += "\nCookies:\n"
        for cookie in self.results.get('cookies', []):
            report += f"  {cookie}\n"

        report += "\nURL Patterns:\n"
        for framework, detected in self.results.get('url_patterns', {}).items():
            status = "[+]" if detected else "[-]"
            report += f"  {status} {framework}\n"

        report += "\nJavaScript Frameworks:\n"
        for framework, detected in self.results.get('javascript', {}).items():
            status = "[+]" if detected else "[-]"
            report += f"  {status} {framework}\n"

        return report

# Usage
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    detector = ComprehensiveDetector(sys.argv[1])
    results = detector.run_all_detections()
    print(detector.generate_report())
```

---

## Reporting Templates

### Framework Detection Report
```
## Framework Detection Report

### Target: [url]

### Detected Frameworks
- Backend: [framework name and version]
- Frontend: [framework name and version]
- CMS: [CMS name and version]
- CDN: [CDN provider]
- Web Server: [server name and version]

### Detection Methods
1. HTTP Headers: [findings]
2. Cookies: [findings]
3. URL Patterns: [findings]
4. JavaScript: [findings]
5. Error Pages: [findings]

### Security Implications
1. [Implication 1]
2. [Implication 2]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
```

### Framework Risk Matrix
| Severity | Condition | Impact |
|----------|-----------|--------|
| High | Outdated framework | Known vulnerabilities |
| Medium | Default configuration | Security misconfig |
| Low | Information disclosure | Reconnaissance aid |

---

## Quick Reference Cheat Sheet

### Header Detection
```bash
curl -I https://target.com | grep -i "server\|x-powered-by\|x-aspnet"
```

### Cookie Detection
```bash
curl -I https://target.com | grep -i "set-cookie"
```

### URL Pattern Detection
```bash
curl -I https://target.com/wp-admin/
curl -I https://target.com/admin/
curl -I https://target.com/login
```

### JavaScript Detection
```bash
curl -s https://target.com | grep -i "react\|vue\|angular\|jquery"
```

---

## Resources and References
- Wappalyzer: https://www.wappalyzer.com/
- BuiltWith: https://builtwith.com/
- WhatWeb: https://www.morningstarsecurity.com/testing/whatweb
- Wappalyzer GitHub: https://github.com/AliasIO/wappalyzer
- WhatWeb GitHub: https://github.com/urbanadventurer/WhatWeb
