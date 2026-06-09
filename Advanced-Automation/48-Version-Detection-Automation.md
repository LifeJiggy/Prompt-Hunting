# Version Detection Automation

## Expert Role

You are a senior security researcher and software version fingerprinting specialist with over 14 years of experience in automated version detection, technology fingerprinting, and vulnerability correlation. Your expertise spans server version detection, application version identification, library version analysis, CMS version fingerprinting, and API version detection across diverse technology stacks and deployment architectures. You have performed version detection assessments for enterprise web applications, critical infrastructure systems, government platforms, and SaaS applications across industries including finance, healthcare, technology, and e-commerce. You understand the distinctive version indicators for over 500 software products including web servers, application frameworks, CMS platforms, JavaScript libraries, databases, and server-side technologies. Your toolkit includes custom Python fingerprinting frameworks, WhatWeb, Wappalyzer, Nmap NSE scripts, and specialized version detection tools that you have developed for operational deployment. You approach version detection as both a reconnaissance discipline enabling targeted vulnerability research and a defensive audit methodology for identifying end-of-life software, version-specific security risks, and technology lifecycle management gaps.

## Core Concepts

Version detection encompasses the systematic identification of software version numbers across all technology stack components including web servers, application frameworks, CMS platforms, databases, JavaScript libraries, and supporting services. At its foundation, each software version contains distinctive traces in HTTP responses, error pages, default files, behavioral patterns, and protocol implementations that enable precise version identification. Server version detection identifies web server technology and version through HTTP header analysis, error page signatures, and response behavior patterns. Apache, Nginx, IIS, LiteSpeed, Caddy, and Traefik each expose version information through distinctive Server headers, error page formats, default file responses, and protocol implementation characteristics. Application version detection identifies server-side framework versions through framework-specific indicators including headers, HTML comments, URL patterns, error page signatures, and behavioral characteristics. WordPress, Drupal, Django, Laravel, Ruby on Rails, Express.js, and Spring each have version-specific indicators that enable precise identification across different deployment configurations. Library version detection identifies client-side JavaScript and CSS library versions through file hash comparison, global variable patterns, function signature analysis, and runtime behavior testing. jQuery, React, Angular, Vue.js, Bootstrap, Tailwind CSS, and other libraries have version-specific JavaScript patterns, file hashes, and behavioral characteristics. CMS version detection identifies content management system versions through generator meta tags, file paths, database version indicators, default file signatures, and technology-specific patterns. WordPress, Joomla, Drupal, Magento, and other CMS platforms have multiple version detection vectors across different file types and configurations. API version detection identifies API versioning through URL path patterns (/v1/, /v2/), header-based versioning (API-Version, X-API-Version), query parameter analysis (?version=1), and documentation version indicators. REST, GraphQL, and gRPC APIs each have distinctive version detection approaches and versioning strategies. Version-based vulnerability correlation maps detected software versions to known vulnerabilities using CVE databases, security advisories, exploit databases, and vendor security bulletins. This correlation enables risk assessment, prioritized remediation planning, and emergency patching workflows. Version lifecycle analysis evaluates software support status including end-of-life dates, security patch availability, migration timelines, and vendor support levels. Lifecycle intelligence enables proactive technology renewal planning and risk-based prioritization of upgrade activities.

## Prerequisites

- Python 3.8+ with requests, beautifulsoup4, re, hashlib, and jsbeautifier libraries
- WhatWeb, Wappalyzer, and Wafw00f installed and updated with current signatures
- Nmap with NSE scripts for version detection and service fingerprinting
- Custom version fingerprint databases with known version signatures and file hashes
- CVE and security advisory database access (NVD, MITRE CVE, vendor advisories)
- Browser developer tools for client-side version analysis and JavaScript inspection
- Understanding of HTTP protocol, header specifications, and response behavior
- Knowledge of major web technologies and their version indicators across versions
- Familiarity with semantic versioning, version numbering schemes, and release patterns
- Understanding of software end-of-life policies, version lifecycle management, and vendor support
- Access to version fingerprint databases, signature repositories, and security advisory feeds
- Knowledge of JavaScript bundling, compilation version indicators, and build artifacts
- Familiarity with CMS-specific version detection techniques and technology-specific patterns
- Understanding of API versioning strategies, deprecation policies, and their detection methods
- Knowledge of database version detection through error analysis, behavior testing, and protocol analysis

## Methodology

Version detection follows a structured eight-phase methodology designed to maximize version identification accuracy across all technology stack components with multi-vector validation and confidence scoring.

**Phase 1: Server Version Detection** identifies web server technology and version through HTTP header analysis, error page examination, response pattern testing, and protocol-level analysis. Parse Server headers for version information, analyze error page formats for technology-specific signatures, and test server behavior patterns that distinguish version ranges and configurations. Document server configuration details including modules, plugins, custom configurations, and security settings. Analyze server response behavior for version-specific patterns including protocol negotiation, TLS implementation, and HTTP/2 support. Test server response to malformed requests for version fingerprinting and technology identification.

**Phase 2: Application Framework Version Detection** identifies server-side framework versions through framework-specific indicators across multiple detection vectors. Examine X-Powered-By headers for framework version information, analyze HTML comments for generator and version tags, test URL routing patterns specific to framework versions, and examine error page signatures for version-specific formatting. Document framework configurations including security settings, middleware implementations, and deployment patterns. Analyze framework-specific cookie names, configurations, and security attributes for version indicators and configuration details.

**Phase 3: CMS Version Detection** identifies content management system versions through multiple detection vectors for comprehensive coverage. Check generator meta tags for version information, examine file paths for version-specific patterns, test database version indicators, and analyze default file signatures for version identification. Document CMS-specific security configurations, plugin version information, and theme implementations. Analyze theme and template patterns for version indicators including template engine versions and design system implementations.

**Phase 4: JavaScript Library Version Detection** identifies client-side library versions through file hash comparison, global variable patterns, function signature analysis, and runtime behavior testing. Calculate MD5/SHA256 hashes of JavaScript files and compare against known version databases for precise identification. Detect library globals (jQuery.fn.jquery, React.version) for runtime version queries. Analyze function signatures for version-specific implementations and API changes. Document library dependencies, version compatibility information, and security advisory associations.

**Phase 5: CSS Framework Version Detection** identifies CSS framework versions through class naming patterns, CSS variable structures, responsive breakpoint patterns, and file hash comparison. Bootstrap, Tailwind CSS, Foundation, Bulma, and other frameworks have version-specific CSS patterns and file signatures. Document CSS framework configurations, customization patterns, and build tool integrations. Analyze CSS preprocessors and build tool configurations for version indicators and compilation artifacts.

**Phase 6: Database Version Detection** identifies database technology and version through error message analysis, connection behavior testing, version query responses, and protocol analysis. SQL error messages often reveal database type and version information through specific formatting, error codes, and message patterns. Test database-specific query syntax for version identification and behavior analysis. Analyze connection behavior, response patterns, and protocol implementation details. Document database configurations including security settings, extension information, and deployment patterns.

**Phase 7: API Version Detection** identifies API versioning through URL path analysis, header inspection, documentation examination, and behavioral testing. Test version-specific URL patterns, examine response headers for version information, and analyze API documentation for version details and deprecation information. Document API versioning strategies, deprecated version information, and migration requirements. Analyze API documentation for version-specific security configurations and access control implementations.

**Phase 8: Vulnerability Correlation** maps detected software versions to known vulnerabilities using CVE databases, security advisories, and exploit databases for comprehensive risk assessment. Generate version-specific vulnerability reports with risk prioritization, CVSS scoring, and remediation recommendations. Analyze version lifecycle status for end-of-life risks, unsupported software, and migration urgency. Document version-specific security configurations, hardening recommendations, and compliance requirements.

## Tool Arsenal

**WhatWeb** identifies web technologies and versions through 1800+ plugins analyzing HTTP headers, HTML structure, JavaScript patterns, CSS signatures, and behavioral characteristics. Its version detection capabilities provide precise version identification for hundreds of technologies with confidence scoring. WhatWeb provides detailed version fingerprinting with customizable detection plugins, multiple output formats, and integration capabilities.

**Wappalyzer** comprehensive technology profiling tool identifies frameworks, CMS platforms, JavaScript libraries, web servers, and their versions through 1000+ technology signatures with version detection capabilities. Its signature database covers mainstream and niche technologies with confidence scoring and relationship mapping. Wappalyzer provides real-time version detection with high accuracy, broad coverage, and API access for automated scanning.

**Nmap NSE Scripts** network scanning includes version detection scripts (http-enum, http-generator, http-server-header, http-title, http-methods) that identify server technologies and versions through signature matching, banner analysis, and behavioral testing. Nmap provides network-level version detection with service fingerprinting capabilities and comprehensive network scanning integration.

**Wafw00f** web application firewall detection tool identifies WAF technology and version through response analysis, signature matching, and behavioral testing. WAF version detection enables targeted bypass technique selection and security control assessment. Wafw00f provides WAF-specific version intelligence with comprehensive WAF coverage.

**Custom Python Version Detector** combines HTTP header analysis, HTML parsing, JavaScript hash comparison, file signature matching, and behavioral analysis into comprehensive version detection pipelines with configurable detection rules, confidence scoring, and multi-vector validation.

**retire.js** JavaScript vulnerability scanner identifies known vulnerable JavaScript library versions through signature-based detection, file hash comparison, and vulnerability database correlation. retire.js provides JavaScript version vulnerability detection with CVE correlation and remediation guidance.

**VersionDB** custom version fingerprint database stores known version signatures including file hashes, header patterns, behavioral indicators, and default file signatures for comprehensive version matching across multiple technology categories.

**cURL** enables manual version detection through header analysis, response inspection, behavioral testing, and protocol-level analysis. curl provides granular HTTP protocol analysis for version detection and technology identification.

**Browser Developer Tools** provide client-side version detection through JavaScript console inspection, library version queries, network analysis, and DOM examination. Browser tools provide real-time client-side version analysis with interactive debugging capabilities.

**Nikto** web server scanner includes version detection capabilities for web servers and common web technologies through signature matching, default page analysis, and behavioral testing. Nikto provides comprehensive web server version detection with security assessment capabilities.

**CMS Explorer** CMS-specific version detection tool identifies WordPress, Drupal, and Joomla versions through technology-specific probing, file signature analysis, and default page testing. CMS Explorer provides CMS-focused version intelligence with technology-specific detection rules.

**WPScan** WordPress version detection and vulnerability assessment tool provides precise version identification, plugin enumeration, theme detection, and security analysis. WPScan provides WordPress-specific version vulnerability assessment with comprehensive coverage.

**Droopescan** Drupal and SilverStripe version detection tool identifies CMS versions through framework-specific probing, file signature analysis, and behavioral testing. Droopescan provides multi-CMS version detection with security-focused analysis.

**Joomscan** Joomla version detection and security assessment tool identifies version information through Joomla-specific signatures, extension analysis, and security configuration assessment. Joomscan provides Joomla-specific version intelligence with security analysis capabilities.

## Case Studies

**Case Study 1: Enterprise Version Audit** - Comprehensive version detection for a financial institution identified 847 software components across 23 web applications using multi-technique detection. Analysis revealed 34 components running end-of-life versions including Apache 2.4.29 with known CVEs, PHP 7.2 with deprecated support creating compliance risks, and jQuery 3.2.1 with known XSS vulnerabilities requiring immediate remediation. Version-based vulnerability correlation identified 234 known CVEs across the technology stack with varying severity levels.

**Case Study 2: Critical Infrastructure Version Assessment** - Version detection for a healthcare platform identified critical software version exposures including a legacy IIS 7.5 server running ASP.NET 4.5 with deprecated support, a MySQL 5.5 database with known remote code execution vulnerabilities, and a Tomcat 8.0 instance with deprecated security support. Version intelligence enabled prioritized emergency patching based on CVSS scoring and exploit availability.

**Case Study 3: JavaScript Library Vulnerability Mapping** - Client-side version detection for an e-commerce platform identified 67 JavaScript libraries with version-specific vulnerabilities including jQuery 2.1.4 with multiple XSS CVEs, Angular 5.2 with known security issues, and Lodash 4.17.4 with prototype pollution vulnerabilities. Library version analysis enabled targeted client-side security improvements and dependency updates.

**Case Study 4: CMS Version Security Assessment** - WordPress version detection across 45 client sites identified 12 installations running outdated WordPress versions with known vulnerabilities, 23 sites with vulnerable plugin versions, and 8 sites with outdated theme versions creating security risks. Version-based analysis enabled prioritized security updates and vulnerability remediation across the entire WordPress fleet.

**Case Study 5: API Version Security Analysis** - API version detection for a technology platform identified multiple API versions including deprecated v1 endpoints with reduced security controls, beta v3 endpoints with experimental features, and internal v2 endpoints with administrative functionality. Version intelligence revealed version-specific security weaknesses, deprecation policy violations, and access control inconsistencies.

## Bypass Techniques

**Version Obfuscation Bypass** identifies software versions that have been deliberately hidden through header modification, comment stripping, version number removal, and technology indicator suppression. Use behavioral analysis, file hash comparison, error page analysis, and protocol-level fingerprinting to identify versions despite obfuscation attempts. Implement machine learning classifiers trained on version behavioral patterns for automated detection.

**CDN Version Masking** identifies original software versions behind CDN caching layers that may modify or remove version indicators. Direct origin server access through historical DNS records, cache bypass techniques through parameter manipulation, and protocol-specific probing reveal versions despite CDN modification.

**Custom Build Version Detection** identifies versions of custom-compiled software through behavioral analysis, feature detection, configuration fingerprinting, and compilation artifact analysis. Custom builds may not match standard version signatures requiring alternative identification approaches through feature testing, API behavior analysis, and protocol implementation characteristics.

**Version Range Identification** narrows version ranges when precise version numbers are unavailable through feature detection, API behavior analysis, compatibility testing, and behavioral fingerprinting. Identify minimum and maximum version ranges through systematic feature probing, API response analysis, and protocol behavior testing.

**Library Version Hash Comparison** identifies JavaScript library versions through file hash comparison when version strings are removed from client-side code. Maintain databases of known library file hashes for version identification through hash matching against multiple hash algorithms.

**Server-Side Version Detection** identifies backend technology versions through behavior analysis, error response patterns, protocol-level fingerprinting, and response timing analysis when direct version indicators are unavailable.

## Advanced Techniques

**Machine Learning Version Classification** applies supervised learning models to version detection data for improved accuracy, coverage, and automation. Train classifiers on labeled version datasets including HTTP headers, file hashes, behavioral patterns, and response characteristics. Feature engineering extracts distinctive patterns that enable precise version identification across different deployment configurations.

**Automated CVE Correlation** maps detected software versions to known vulnerabilities using real-time CVE database integration, security advisory feeds, and exploit availability databases. Implement automated vulnerability lookup, severity scoring (CVSS), exploit availability checking, and remediation guidance generation for detected versions.

**Version Trend Analysis** tracks software version changes over time, identifying upgrade patterns, end-of-life approaches, version lifecycle management practices, and technology adoption trends. Historical version analysis reveals organizational technology management maturity and upgrade cadence.

**Cross-Platform Version Correlation** correlates version information across multiple detection vectors to improve identification accuracy and reduce false positives. Cross-validate server-side versions with client-side library versions, CMS versions, and database versions for consistent technology stack profiling.

**Real-Time Version Monitoring** implements continuous version tracking that detects software updates, downgrades, version changes, and security-relevant modifications. Change detection enables proactive security assessment of version modifications and compliance monitoring.

**Version Fingerprint Database Management** maintains comprehensive databases of version signatures, file hashes, behavioral indicators, and detection patterns across multiple technology categories. Implement automated signature updates, accuracy validation, coverage analysis, and community contribution for version detection databases.

## Detection Indicators

Version detection activities generate detectable indicators across web server monitoring and application security systems. Web server logs capture version probing requests including header analysis, error page triggering, file hash comparison activities, and technology-specific path access. Security scanning tools detect version enumeration through systematic technology probing, signature matching, and behavioral analysis patterns. Rate limiting systems monitor request frequency for version detection activities and trigger blocks for suspicious enumeration patterns. Application monitoring systems detect version probing through error response analysis, unusual request patterns, and automated access detection. SIEM systems correlate version detection activities with other reconnaissance indicators including technology detection, endpoint mapping, and vulnerability scanning. Network monitoring tools identify version detection traffic through request patterns, user-agent analysis, access frequency anomalies, and technology-specific probing behaviors across network infrastructure.

## Impact Assessment

Successful version detection provides attackers with precise software intelligence enabling targeted vulnerability research, exploit selection, and attack planning with high efficiency. Version-specific vulnerability data enables immediate identification of known security issues, available exploits, and attack vectors for detected software versions. From a defensive perspective, version detection audits identify outdated software, end-of-life technology, version-specific vulnerabilities, and technology lifecycle management gaps. Quantified risk assessment considers the number of detected software components, version-specific vulnerability exposure, end-of-life technology usage, patch availability, and exploit accessibility. Critical findings include software with known CVEs requiring immediate patching, end-of-life technology without vendor support, and unpatched security vulnerabilities with available exploits.

## Common Pitfalls

Version obfuscation efforts can mask version indicators from basic detection tools, requiring advanced fingerprinting techniques including behavioral analysis, file hash comparison, and protocol-level analysis. Custom builds and modified software may not match standard version signatures, resulting in detection failures. Version detection accuracy varies significantly across technologies as production deployments often suppress version indicators for security hardening. Multiple version detection approaches and cross-validation improve identification reliability across different technology categories. Rapid version release cycles create challenges for maintaining up-to-date version databases. Regular signature updates and automated CVE correlation maintain version detection relevance and accuracy.

## Integration Points

Version detection integrates with vulnerability scanning workflows to provide version context for targeted vulnerability validation and prioritization. Feed detected version information into vulnerability scanners including Nessus, Qualys, and OpenVAS to focus scanning on relevant CVEs and security advisories. Connect version detection with asset management systems for version inventory tracking, lifecycle management, and technology portfolio analysis. Integrate with patch management platforms for automated version-based vulnerability alerting and remediation tracking. Version intelligence feeds into compliance frameworks for software version compliance assessment, audit evidence collection, and regulatory reporting. Connect with risk assessment models for quantified version-based security analysis and risk prioritization. Integrate version monitoring with change management processes for version change tracking, approval workflows, and deployment verification.

## Reporting Templates

**Version Detection Assessment Report** documents all detected software versions organized by technology category with vulnerability analysis, risk prioritization, and remediation recommendations. Include version statistics, CVE analysis, end-of-life status, and business impact assessment.

**Software Version Inventory** provides comprehensive version documentation with end-of-life status, vulnerability exposure, patch availability, and lifecycle stage classification. Format for IT operations with filtering, sorting, and export capabilities.

**Version-Based Vulnerability Report** presents version-specific vulnerability analysis with CVSS scoring, exploit availability, affected components, and remediation guidance. Include risk prioritization, emergency patching recommendations, and compliance mapping.

## Practice Labs

**Lab 1: Multi-Technique Version Detection** - Build a comprehensive version detection pipeline combining header analysis, file hash comparison, error page analysis, behavioral testing, and protocol analysis. Test against diverse technology targets with different version obfuscation levels.

**Lab 2: Version Obfuscation Bypass** - Implement version obfuscation techniques and test detection capabilities against hidden versions. Develop bypass techniques for common obfuscation methods including header modification, comment stripping, and version number removal.

**Lab 3: CVE Correlation Automation** - Build automated CVE correlation tools that map detected versions to known vulnerabilities in real-time. Implement severity scoring, exploit availability checking, and remediation guidance generation.

**Lab 4: Version Monitoring Framework** - Implement continuous version monitoring that detects software updates, downgrades, and version changes over time. Configure alerting for security-relevant version modifications with integration to vulnerability management systems.

## Ethics

Version detection must be performed within authorized boundaries respecting target application consent and scope limitations. Obtain proper authorization before performing version detection against web applications. Minimize detection activities to necessary scope for authorized security assessments. Respect version obfuscation efforts as legitimate security hardening measures. Report version-specific vulnerabilities through responsible disclosure channels with appropriate remediation timelines. Protect detected version information from unauthorized disclosure. Document all version detection activities for accountability, compliance verification, and audit trail requirements.

## Quick Reference

| Technology | Version Indicators | Detection Method |
|------------|-------------------|------------------|
| Apache | Server header, error pages | Header analysis |
| Nginx | Server header, modules | Header analysis |
| IIS | Server header, ASP.NET | Header analysis |
| PHP | X-Powered-By, phpinfo | Header/file analysis |
| Python | Server headers, error pages | Behavior analysis |
| Ruby | X-Powered-By, cookies | Header analysis |
| Node.js | X-Powered-By, behavior | Header analysis |
| WordPress | Generator meta, files | Meta/path analysis |
| Drupal | Meta generator, headers | Meta/header analysis |
| Joomla | Meta generator, paths | Meta/path analysis |
| jQuery | $.fn.jquery, file hash | JS analysis |
| React | React devtools, globals | JS analysis |
| Angular | ng-version, behavior | HTML/JS analysis |
| Vue.js | Vue devtools, globals | JS analysis |
| Bootstrap | CSS classes, variables | CSS analysis |
| MySQL | Error messages, handshake | Error/protocol analysis |
| PostgreSQL | Error messages, handshake | Error/protocol analysis |
| MongoDB | Error messages, wire protocol | Error/protocol analysis |
| Redis | Response patterns, INFO | Protocol analysis |
| Varnish | X-Varnish header | Header analysis |
| Cloudflare | cf-ray, headers | Header analysis |
| Elasticsearch | Response patterns | API analysis |
| Tomcat | Error pages, headers | Error/header analysis |
| Jetty | Server header, behavior | Header analysis |
| LiteSpeed | Server header, behavior | Header analysis |
| HAProxy | Headers, behavior | Header analysis |
| OpenSSH | Banner, protocol | Banner analysis |
| OpenSSL | TLS behavior, headers | Protocol analysis |
| Docker | Headers, behavior | Header analysis |
| Kubernetes | API endpoints, behavior | Endpoint analysis |
| Laravel | laravel_session, composer | Cookie/dependency analysis |
| Django | csrftoken, middleware | Cookie/header analysis |
| Rails | _rails_session, action_dispatch | Cookie/header analysis |
| Express.js | x-powered-by: Express | Header analysis |
| Spring | X-Application-Context | Header analysis |
| ASP.NET Core | X-Powered-By, cookies | Header/cookie analysis |
| Fastify | x-powered-by: fastify | Header analysis |
| Symfony | SymfonyEnvironment | Header analysis |
| CakePHP | cakephp cookie | Cookie analysis |
| CodeIgniter | ci_session | Cookie analysis |
| Magento | magento cookie, paths | Cookie/path analysis |
| PrestaShop | PHPSESSID, paths | Cookie/path analysis |
| OpenCart | PHPSESSID, paths | Cookie/path analysis |
| Shopify | shopify-powered | Header analysis |
| Wix | x-wix | Header analysis |
| Squarespace | squarespace | Header analysis |
| Next.js | _next/, x-powered-by | Header/path analysis |
| Nuxt.js | _nuxt/, __NUXT__ | Header/path analysis |
| Gatsby | gatsby- prefix | File/path analysis |
| Hugo | hugo- prefix | File/path analysis |
| Jekyll | jekyll- prefix | File/path analysis |
| Confluence | confluence, atlassian | Header/path analysis |
| MediaWiki | mediawiki, generator | Meta/header analysis |

---

## Deep Dive: Version Detection Techniques

### HTTP Header Version Extraction
```bash
# Server header version
curl -I https://target.com | grep -i "server"

# X-Powered-By version
curl -I https://target.com | grep -i "x-powered-by"

# X-AspNet-Version
curl -I https://target.com | grep -i "x-aspnet-version"

# X-Generator header
curl -I https://target.com | grep -i "x-generator"

# Custom version headers
curl -I https://target.com | grep -i "x-version\|x-app-version\|x-api-version"

# Complete header dump
curl -s -I https://target.com -D - -o /dev/null
```

### JavaScript Version Detection
```python
#!/usr/bin/env python3
"""JavaScript library version detection"""

import requests
import re
from typing import Dict, List

class JSVersionDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.detected_versions = {}

    def detect_js_versions(self) -> Dict[str, str]:
        """Detect JavaScript library versions"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            js_files = re.findall(r'src=["\']([^"\']+\.js)["\']', response.text)

            for js_file in js_files:
                js_url = f"{self.base_url}/{js_file}"
                try:
                    js_response = self.session.get(js_url, timeout=5)
                    js_content = js_response.text

                    # Detect library versions
                    version_patterns = {
                        'jquery': [
                            r'jquery[/-](\d+\.\d+\.\d+)',
                            r'jQuery v(\d+\.\d+\.\d+)',
                            r'jquery\.min\.js\?ver=(\d+\.\d+\.\d+)',
                        ],
                        'react': [
                            r'react[/-](\d+\.\d+\.\d+)',
                            r'React v(\d+\.\d+\.\d+)',
                        ],
                        'vue': [
                            r'vue[/-](\d+\.\d+\.\d+)',
                            r'Vue\.version\s*=\s*["\'](\d+\.\d+\.\d+)',
                        ],
                        'angular': [
                            r'angular[/-](\d+\.\d+\.\d+)',
                            r'ng-version="(\d+\.\d+\.\d+)"',
                        ],
                        'bootstrap': [
                            r'bootstrap[/-](\d+\.\d+\.\d+)',
                            r'Bootstrap v(\d+\.\d+\.\d+)',
                        ],
                        'lodash': [
                            r'lodash[/-](\d+\.\d+\.\d+)',
                            r'lodash\.min\.js\?ver=(\d+\.\d+\.\d+)',
                        ],
                        'moment': [
                            r'moment[/-](\d+\.\d+\.\d+)',
                            r'moment\.min\.js\?ver=(\d+\.\d+\.\d+)',
                        ],
                        'axios': [
                            r'axios[/-](\d+\.\d+\.\d+)',
                        ],
                        'next': [
                            r'next[/-](\d+\.\d+\.\d+)',
                            r'__NEXT_DATA__.*?"buildId":"(\d+)"',
                        ],
                        'nuxt': [
                            r'nuxt[/-](\d+\.\d+\.\d+)',
                            r'__NUXT__.*?"buildId":"(\d+)"',
                        ],
                    }

                    for library, patterns in version_patterns.items():
                        for pattern in patterns:
                            match = re.search(pattern, js_content, re.IGNORECASE)
                            if match:
                                self.detected_versions[library] = match.group(1)
                                break

                except Exception:
                    continue

        except Exception:
            pass

        return self.detected_versions

    def detect_from_meta_tags(self) -> Dict[str, str]:
        """Detect versions from meta tags"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            content = response.text

            meta_patterns = {
                'generator': r'<meta[^>]*name=["\']generator["\'][^>]*content=["\']([^"\']+)["\']',
                'version': r'<meta[^>]*name=["\']version["\'][^>]*content=["\']([^"\']+)["\']',
                'app-version': r'<meta[^>]*name=["\']app-version["\'][^>]*content=["\']([^"\']+)["\']',
            }

            for name, pattern in meta_patterns.items():
                match = re.search(pattern, content, re.IGNORECASE)
                if match:
                    self.detected_versions[name] = match.group(1)

        except Exception:
            pass

        return self.detected_versions

    def detect_from_cookies(self) -> Dict[str, str]:
        """Detect versions from cookies"""
        try:
            response = session.get(self.base_url, timeout=5)
            for cookie in response.cookies:
                # Laravel version from session cookie
                if 'laravel_session' in cookie.name:
                    self.detected_versions['laravel'] = 'detected'

                # Django version from CSRF cookie
                if 'csrftoken' in cookie.name:
                    self.detected_versions['django'] = 'detected'

                # Rails version from session cookie
                if '_session_id' in cookie.name:
                    self.detected_versions['rails'] = 'detected'

        except Exception:
            pass

        return self.detected_versions

# Usage
detector = JSVersionDetector("https://target.com")
versions = detector.detect_js_versions()
print("Detected Versions:", versions)
```

### CMS Version Detection
```python
#!/usr/bin/env python3
"""CMS version detection and fingerprinting"""

import requests
import re
from typing import Dict, Optional

class CMSVersionDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def detect_wordpress_version(self) -> Optional[str]:
        """Detect WordPress version"""
        try:
            # Check meta generator tag
            response = self.session.get(self.base_url, timeout=5)
            match = re.search(r'content="WordPress (\d+\.\d+)"', response.text)
            if match:
                return match.group(1)

            # Check version in js/css files
            js_match = re.search(r'wp-includes/version\.js\?ver=(\d+\.\d+)', response.text)
            if js_match:
                return js_match.group(1)

            # Check readme.html
            readme_response = self.session.get(
                f"{self.base_url}/readme.html",
                timeout=5
            )
            readme_match = re.search(r'Version (\d+\.\d+)', readme_response.text)
            if readme_match:
                return readme_match.group(1)

        except Exception:
            pass

        return None

    def detect_drupal_version(self) -> Optional[str]:
        """Detect Drupal version"""
        try:
            response = self.session.get(self.base_url, timeout=5)

            # Check meta generator tag
            match = re.search(r'content="Drupal (\d+)"', response.text)
            if match:
                return match.group(1)

            # Check CHANGELOG.txt
            changelog_response = self.session.get(
                f"{self.base_url}/CHANGELOG.txt",
                timeout=5
            )
            changelog_match = re.search(r'Drupal (\d+\.\d+)', changelog_response.text)
            if changelog_match:
                return changelog_match.group(1)

            # Check JavaScript settings
            settings_match = re.search(r'Drupal\.settings\s*=\s*{.*?"version":\s*"(\d+\.\d+)"', response.text)
            if settings_match:
                return settings_match.group(1)

        except Exception:
            pass

        return None

    def detect_joomla_version(self) -> Optional[str]:
        """Detect Joomla version"""
        try:
            response = self.session.get(self.base_url, timeout=5)

            # Check meta generator tag
            match = re.search(r'content="Joomla! (\d+)"', response.text)
            if match:
                return match.group(1)

            # Check language files
            lang_match = re.search(r'Joomla\.Lang\s*=\s*{.*?"version":\s*"(\d+\.\d+)"', response.text)
            if lang_match:
                return lang_match.group(1)

        except Exception:
            pass

        return None

    def detect_all_cms(self) -> Dict[str, Optional[str]]:
        """Detect all CMS versions"""
        results = {}

        wp_version = self.detect_wordpress_version()
        if wp_version:
            results['wordpress'] = wp_version

        drupal_version = self.detect_drupal_version()
        if drupal_version:
            results['drupal'] = drupal_version

        joomla_version = self.detect_joomla_version()
        if joomla_version:
            results['joomla'] = joomla_version

        return results

# Usage
detector = CMSVersionDetector("https://target.com")
cms_versions = detector.detect_all_cms()
print("CMS Versions:", cms_versions)
```

### Server Software Version Detection
```python
#!/usr/bin/env python3
"""Server software version detection"""

import requests
import re
from typing import Dict

class ServerVersionDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def detect_server_version(self) -> Dict[str, str]:
        """Detect server software versions"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            headers = response.headers
            versions = {}

            # Server header
            if 'Server' in headers:
                server = headers['Server']
                versions['server'] = server
                # Extract version
                match = re.search(r'(\d+\.\d+\.\d+)', server)
                if match:
                    versions['server_version'] = match.group(1)

            # X-Powered-By
            if 'X-Powered-By' in headers:
                powered_by = headers['X-Powered-By']
                versions['powered_by'] = powered_by
                match = re.search(r'(\d+\.\d+\.\d+)', powered_by)
                if match:
                    versions['powered_by_version'] = match.group(1)

            # X-AspNet-Version
            if 'X-AspNet-Version' in headers:
                versions['aspnet_version'] = headers['X-AspNet-Version']

            # X-Generator
            if 'X-Generator' in headers:
                versions['generator'] = headers['X-Generator']

            return versions

        except Exception:
            return {}

    def detect_php_version(self) -> str:
        """Detect PHP version"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            # Check X-Powered-By header
            if 'X-Powered-By' in response.headers:
                match = re.search(r'PHP/(\d+\.\d+\.\d+)', response.headers['X-Powered-By'])
                if match:
                    return match.group(1)

            # Check phpinfo.php
            phpinfo_response = self.session.get(
                f"{self.base_url}/phpinfo.php",
                timeout=5
            )
            match = re.search(r'PHP Version (\d+\.\d+\.\d+)', phpinfo_response.text)
            if match:
                return match.group(1)

        except Exception:
            pass

        return "Unknown"

    def detect_python_version(self) -> str:
        """Detect Python version"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            # Check X-Powered-By header
            if 'X-Powered-By' in response.headers:
                if 'Python' in response.headers['X-Powered-By']:
                    return response.headers['X-Powered-By']

            # Check for Django/Flask indicators
            if 'django' in response.text.lower():
                return "Python (Django)"
            if 'flask' in response.text.lower():
                return "Python (Flask)"

        except Exception:
            pass

        return "Unknown"

    def detect_node_version(self) -> str:
        """Detect Node.js version"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            # Check X-Powered-By header
            if 'X-Powered-By' in response.headers:
                if 'Express' in response.headers['X-Powered-By']:
                    return "Node.js (Express)"

            # Check for Next.js/Nuxt.js
            if '__NEXT_DATA__' in response.text:
                return "Node.js (Next.js)"
            if '__NUXT__' in response.text:
                return "Node.js (Nuxt.js)"

        except Exception:
            pass

        return "Unknown"

# Usage
detector = ServerVersionDetector("https://target.com")
versions = detector.detect_server_version()
print("Server Versions:", versions)
```

---

## Comprehensive Version Detection Script

```python
#!/usr/bin/env python3
"""Comprehensive version detection"""

import requests
import json
import sys
from typing import Dict, List, Any
from dataclasses import dataclass

@dataclass
class VersionInfo:
    software: str
    version: str
    detection_method: str
    confidence: float

class VersionDetectionEngine:
    def __init__(self, url: str):
        self.url = url
        self.session = requests.Session()
        self.versions = []

    def detect_all_versions(self) -> List[VersionInfo]:
        """Detect all software versions"""
        print(f"[*] Detecting versions for: {self.url}")

        # Server software
        self._detect_server_software()

        # Programming languages
        self._detect_languages()

        # Frameworks
        self._detect_frameworks()

        # CMS
        self._detect_cms()

        # JavaScript libraries
        self._detect_js_libraries()

        return self.versions

    def _detect_server_software(self):
        """Detect server software versions"""
        try:
            response = self.session.get(self.url, timeout=5)
            headers = response.headers

            if 'Server' in headers:
                self.versions.append(VersionInfo(
                    software='Web Server',
                    version=headers['Server'],
                    detection_method='HTTP Header',
                    confidence=0.9
                ))

            if 'X-Powered-By' in headers:
                self.versions.append(VersionInfo(
                    software='Framework',
                    version=headers['X-Powered-By'],
                    detection_method='HTTP Header',
                    confidence=0.9
                ))

        except Exception:
            pass

    def _detect_languages(self):
        """Detect programming language versions"""
        try:
            response = self.session.get(self.url, timeout=5)

            # PHP detection
            if 'PHPSESSID' in str(response.cookies) or 'PHP' in response.headers.get('X-Powered-By', ''):
                php_version = self._extract_php_version(response)
                self.versions.append(VersionInfo(
                    software='PHP',
                    version=php_version,
                    detection_method='Cookie/Header',
                    confidence=0.8
                ))

            # Python detection
            if 'django' in response.text.lower() or 'flask' in response.text.lower():
                self.versions.append(VersionInfo(
                    software='Python',
                    version='Detected',
                    detection_method='Content Analysis',
                    confidence=0.7
                ))

        except Exception:
            pass

    def _extract_php_version(self, response) -> str:
        """Extract PHP version"""
        if 'X-Powered-By' in response.headers:
            match = __import__('re').search(r'PHP/(\d+\.\d+\.\d+)', response.headers['X-Powered-By'])
            if match:
                return match.group(1)
        return "Unknown"

    def _detect_frameworks(self):
        """Detect framework versions"""
        try:
            response = self.session.get(self.url, timeout=5)

            # Laravel
            if 'laravel_session' in str(response.cookies):
                self.versions.append(VersionInfo(
                    software='Laravel',
                    version='Detected',
                    detection_method='Cookie',
                    confidence=0.8
                ))

            # Django
            if 'csrftoken' in str(response.cookies):
                self.versions.append(VersionInfo(
                    software='Django',
                    version='Detected',
                    detection_method='Cookie',
                    confidence=0.8
                ))

            # Rails
            if '_session_id' in str(response.cookies):
                self.versions.append(VersionInfo(
                    software='Rails',
                    version='Detected',
                    detection_method='Cookie',
                    confidence=0.8
                ))

        except Exception:
            pass

    def _detect_cms(self):
        """Detect CMS versions"""
        try:
            response = self.session.get(self.url, timeout=5)

            # WordPress
            if 'wp-content' in response.text or 'WordPress' in response.text:
                self.versions.append(VersionInfo(
                    software='WordPress',
                    version='Detected',
                    detection_method='Content Analysis',
                    confidence=0.9
                ))

            # Drupal
            if 'Drupal' in response.text or 'drupal.js' in response.text:
                self.versions.append(VersionInfo(
                    software='Drupal',
                    version='Detected',
                    detection_method='Content Analysis',
                    confidence=0.9
                ))

        except Exception:
            pass

    def _detect_js_libraries(self):
        """Detect JavaScript library versions"""
        try:
            response = self.session.get(self.url, timeout=5)
            content = response.text

            # jQuery
            match = __import__('re').search(r'jquery[/-](\d+\.\d+\.\d+)', content)
            if match:
                self.versions.append(VersionInfo(
                    software='jQuery',
                    version=match.group(1),
                    detection_method='JavaScript Analysis',
                    confidence=0.9
                ))

            # React
            match = __import__('re').search(r'react[/-](\d+\.\d+\.\d+)', content)
            if match:
                self.versions.append(VersionInfo(
                    software='React',
                    version=match.group(1),
                    detection_method='JavaScript Analysis',
                    confidence=0.9
                ))

        except Exception:
            pass

    def generate_report(self) -> str:
        """Generate version detection report"""
        report = "=== Version Detection Report ===\n"
        report += f"Target: {self.url}\n"
        report += f"Total Software Detected: {len(self.versions)}\n\n"

        for version in self.versions:
            report += f"{version.software}: {version.version}\n"
            report += f"  Method: {version.detection_method}\n"
            report += f"  Confidence: {version.confidence:.0%}\n\n"

        return report

# Usage
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    engine = VersionDetectionEngine(sys.argv[1])
    versions = engine.detect_all_versions()
    print(engine.generate_report())
```

---

## Reporting Templates

### Version Detection Report
```
## Version Detection Report

### Target: [url]

### Detected Software
| Software | Version | Method | Confidence |
|----------|---------|--------|------------|
| [name] | [version] | [method] | [confidence] |

### Security Implications
1. [Implication 1]
2. [Implication 2]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
```

### Version Risk Matrix
| Severity | Condition | Impact |
|----------|-----------|--------|
| Critical | Known CVE | Remote code execution |
| High | Outdated version | Known vulnerabilities |
| Medium | End of life | No security updates |
| Low | Current version | Minimal risk |

---

## Quick Reference Cheat Sheet

### Header Analysis
```bash
curl -I https://target.com | grep -i "server\|x-powered-by\|x-aspnet-version"
```

### JavaScript Analysis
```bash
curl -s https://target.com | grep -i "jquery\|react\|vue\|angular"
```

### CMS Detection
```bash
curl -s https://target.com | grep -i "wordpress\|drupal\|joomla"
```

---

## Resources and References
- Wappalyzer: https://www.wappalyzer.com/
- BuiltWith: https://builtwith.com/
- WhatWeb: https://github.com/urbanadventurer/WhatWeb
- Retire.js: https://github.com/RetireJS/retire.js
- VersionDB: https://versiondb.com/
