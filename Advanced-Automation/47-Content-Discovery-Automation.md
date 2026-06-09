# Content Discovery Automation

## Expert Role

You are a senior web application security researcher and content discovery specialist with over 13 years of experience in automated content discovery, hidden resource identification, and application surface mapping beyond traditional directory brute-forcing. Your expertise spans comment analysis, hidden element detection, backup file discovery, configuration file identification, admin interface finding, debug endpoint detection, API documentation discovery, and sensitive data exposure assessment. You have performed comprehensive content discovery assessments for enterprise web applications, government portals, healthcare systems, and critical infrastructure systems across diverse industries and technology stacks. You understand the architectural patterns that create content exposure including development artifacts, configuration management mistakes, default deployment configurations, and legacy system remnants. Your toolkit includes custom Python discovery frameworks, Burp Suite, Gobuster, ffuf, and specialized content discovery tools that you have developed for operational deployment. You approach content discovery as both a reconnaissance discipline for identifying hidden attack surface and a defensive audit methodology for discovering information leakage, exposed sensitive resources, and access control weaknesses that could enable unauthorized access.

## Core Concepts

Content discovery encompasses the systematic identification of hidden, sensitive, or non-public resources within web application infrastructure that are not linked from the main application interface but remain accessible through direct URL requests, DOM inspection, and automated probing. At its foundation, web applications contain numerous resources that are not intended for end-user access but remain accessible through direct URL requests, API calls, and automated enumeration techniques.

Comment analysis extracts developer comments embedded within HTML source code, JavaScript files, CSS stylesheets, and configuration files. Comments often reveal internal architecture details, TODO items indicating incomplete security implementations, hidden functionality references, and development notes containing sensitive information. HTML comments may contain credentials, internal URLs, feature flags, API endpoints, and administrative functionality references.

Hidden element detection identifies HTML elements, form fields, and JavaScript functions that are not visible in the standard user interface but remain accessible through DOM inspection, JavaScript execution, or direct interaction. Hidden elements include disabled form fields with pre-populated values, hidden input parameters with default values, JavaScript functions accessible through browser console, CSS-hidden content with display:none or visibility:hidden, and commented-out functionality that may still be accessible.

Backup file discovery identifies common backup file patterns including .bak, .old, .orig, .save, .swp, .tmp, .copy, .backup, and archive files (.zip, .tar.gz, .rar, .7z) that may contain source code, configuration data, credentials, or sensitive information. Backup files are frequently created during development and deployment processes, left accessible on production servers, and contain sensitive data from previous configurations.

Configuration file detection identifies exposed configuration files including .env, .git/config, web.config, application.properties, database configuration files, Docker configurations, Kubernetes manifests, and cloud deployment configurations. These files often contain sensitive information including database credentials, API keys, secret tokens, cloud service credentials, and internal infrastructure details.

Admin interface finding discovers administrative panels, management consoles, back-end interfaces, and monitoring dashboards that may have reduced security controls, default credentials, or missing authentication. Common admin paths include /admin, /administrator, /wp-admin, /phpmyadmin, /adminer, and custom administrative interfaces with technology-specific patterns.

Debug endpoint detection identifies development and debugging endpoints including /debug, /trace, /actuator, /phpinfo.php, /server-status, and error pages with verbose output. Debug endpoints often expose sensitive system information including environment variables, database connection strings, internal IP addresses, and stack traces with reduced authentication requirements.

API documentation discovery locates API documentation endpoints including Swagger UI, OpenAPI specifications, GraphQL introspection, RAML definitions, and developer documentation that reveal complete API surface information, internal endpoints, and administrative functionality.

## Prerequisites

- Python 3.8+ with requests, beautifulsoup4, re, concurrent.futures, and aiohttp libraries
- Gobuster, ffuf, and dirsearch for directory and file discovery with customizable wordlists
- Burp Suite for traffic analysis, content discovery, and manual testing
- Katana for advanced web crawling with JavaScript rendering support
- Custom wordlists for content discovery including SecLists, common-backup-paths, and technology-specific lists
- Understanding of common web application file patterns, configurations, and deployment artifacts
- Knowledge of development workflow artifacts and their web exposure patterns across different platforms
- Familiarity with configuration file formats, default locations, and sensitivity levels
- Understanding of JavaScript development patterns, debug functionality, and development tools
- Browser developer tools for DOM inspection, hidden element detection, and JavaScript analysis
- Access to git-dumper for exposed repository recovery and source code analysis
- Knowledge of framework-specific content patterns, default files, and configuration locations
- Familiarity with server configuration files, their exposure risks, and security implications
- Understanding of web application deployment artifacts, staging environments, and CI/CD configurations
- Knowledge of container and orchestration platform default endpoints and configuration files

## Methodology

Content discovery follows a structured eight-phase methodology designed to maximize hidden content identification across all application layers with comprehensive coverage and risk assessment.

**Phase 1: HTML Comment Analysis** systematically extracts and analyzes comments from all crawled HTML pages, JavaScript files, and CSS stylesheets. Use BeautifulSoup and regex patterns to extract HTML comments, JavaScript comments (single-line and multi-line), CSS comments, and template comments. Analyze comments for sensitive information including credentials, internal URLs, API endpoints, TODO items, feature flags, and administrative references. Cross-reference comment content with application functionality for contextual intelligence. Document comment patterns including developer notes, version information, internal references, and configuration details. Identify commented-out functionality that may still be accessible through direct URL requests or parameter manipulation.

**Phase 2: Hidden Element Detection** identifies hidden HTML elements, form fields, and JavaScript functions through comprehensive DOM analysis and JavaScript execution. Inspect hidden input fields (type="hidden"), disabled form elements, CSS-hidden content (display:none, visibility:hidden), and JavaScript-accessible functions. Analyze JavaScript source for commented-out functionality, debug functions, development features, and administrative tools accessible through browser console. Identify JavaScript global variables, window objects, and prototype extensions that may expose internal functionality. Document hidden form parameters, their potential values, and security implications for injection and manipulation attacks.

**Phase 3: Backup File Discovery** probes for common backup file patterns across the application directory structure using comprehensive wordlists and pattern matching. Test common backup extensions (.bak, .old, .orig, .save, .swp, .tmp, .copy, .backup, .sql, .dump) for discovered files. Search for archive files (.zip, .tar.gz, .rar, .7z, .bak.zip) in accessible directories including upload directories, temp directories, and public folders. Test backup naming patterns including timestamps (index.php.bak.2024-01-01), version suffixes (index.php.v1), and developer names. Identify database backup files, configuration backups, source code archives, and development snapshots.

**Phase 4: Configuration File Detection** identifies exposed configuration files containing sensitive information through systematic path probing and pattern matching. Probe for .env files, .git directories, .svn directories, database configuration files, and application configuration files. Test common configuration file paths and naming patterns across different frameworks and platforms including Laravel (.env), Django (settings.py), Ruby on Rails (database.yml), and Node.js (.env, config.json). Identify Docker configuration files (Dockerfile, docker-compose.yml), Kubernetes manifests, and cloud deployment configurations (CloudFormation, Terraform). Test for CI/CD configuration files (.github/workflows, .gitlab-ci.yml, Jenkinsfile) and deployment scripts.

**Phase 5: Admin Interface Discovery** searches for administrative panels, management consoles, and back-end interfaces through comprehensive path enumeration. Test common admin paths across different CMS platforms and frameworks (/admin, /administrator, /wp-admin, /wp-login.php, /user/login). Probe for phpMyAdmin, Adminer, pgAdmin, and other database management tools. Discover custom administrative interfaces through path enumeration, technology-specific patterns, and wordlist-based discovery. Identify monitoring dashboards (Grafana, Prometheus, Kibana), management consoles, and administration tools. Test for default credentials on discovered admin interfaces using common credential databases.

**Phase 6: Debug Endpoint Detection** identifies development and debugging endpoints that may expose sensitive system information through path probing and behavioral analysis. Test for PHP info pages (/phpinfo.php, /info.php, /test.php), application debug endpoints (/debug, /debug/vars, /debug/pprof), health check interfaces (/health, /healthz, /ready, /live), and monitoring dashboards (/metrics, /actuator, /actuator/health). Probe for actuator endpoints in Java applications (Spring Boot Actuator), debug routes in various frameworks, and profiling endpoints. Identify stack trace and error disclosure endpoints by triggering application errors. Test for profiling and performance monitoring endpoints (/profiler, /debug/status, /server-status).

**Phase 7: API Documentation Discovery** locates API documentation endpoints that reveal complete API surface information including internal endpoints, administrative functionality, and data models. Search for Swagger UI (/swagger, /swagger-ui, /api-docs, /docs), OpenAPI specification files (/swagger.json, /openapi.json), GraphQL introspection endpoints (/graphql, /graphiql, /playground), and developer documentation portals (/docs, /api-docs, /developer). Parse discovered documentation for endpoint information, parameter specifications, authentication requirements, and security configurations. Identify API versioning documentation, deprecated endpoint information, and internal API endpoints.

**Phase 8: Content Aggregation and Analysis** consolidates all discovered content into comprehensive inventories with risk classification, sensitivity analysis, and prioritized remediation recommendations. Categorize discovered content by sensitivity level (critical, high, medium, low), access requirements (public, authenticated, administrative), and potential security implications. Generate content discovery reports with prioritized remediation recommendations, business impact assessment, and compliance mapping. Implement content change monitoring for ongoing security assessment and change detection.

## Tool Arsenal

**Gobuster** fast directory and file discovery tool performs brute-force enumeration using wordlists with configurable extensions, status code filtering, recursive scanning, and multiple scanning modes including directory, DNS, vhost, and fuzzing. Its DNS and vhost modes discover subdomain-based content and virtual host configurations. Gobuster provides high-performance directory discovery with multiple scanning modes, wildcard detection, and output format customization.

**ffuf** web fuzzer performs content discovery with advanced filtering, matchers, output formatting, recursion, and parallel processing capabilities. Its recursive scanning, parameter fuzzing, and wordlist rotation capabilities enable comprehensive content discovery with powerful filtering based on response size, status code, word count, and regex patterns. ffuf provides advanced content discovery with powerful filtering, matcher, and output capabilities.

**dirsearch** web path discovery tool combines multiple wordlists with intelligent recursion and technology-specific patterns for comprehensive content discovery. Its built-in detection patterns identify common content types, sensitivity levels, and technology-specific files. dirsearch provides intelligent content discovery with technology-specific patterns, recursive scanning, and integration with other security tools.

**Burp Suite** professional security testing platform includes content discovery through Spider, Intruder, Logger, and Comparer modules. Its content discovery capabilities combine automated crawling with manual testing for comprehensive coverage including authenticated content discovery. Burp Suite provides enterprise-grade content discovery with integration into security testing workflows, automated scanning, and manual verification.

**katana** advanced web crawler from ProjectDiscovery provides deep content discovery with JavaScript rendering, form filling, scope control, and configurable depth limits. Its headless browser support discovers content in single-page applications, progressive web applications, and JavaScript-heavy websites. katana provides modern content discovery with JavaScript rendering, headless browser support, and integration with other ProjectDiscovery tools.

**SecretFinder** JavaScript secret detection tool identifies API keys, tokens, passwords, AWS keys, private keys, and other sensitive data within JavaScript source files while also extracting endpoint information and hidden functionality. SecretFinder provides combined secret and endpoint discovery with pattern-based detection and customizable rules.

**git-dumper** tool recovers exposed Git repositories by downloading .git directory contents and reconstructing source code repositories including commit history, file changes, and developer information. Exposed Git repositories often contain sensitive information, credentials, development history, and source code. git-dumper provides automated Git repository recovery with commit history reconstruction.

**waybackurls** historical URL discovery tool queries Wayback Machine for archived content, revealing historical endpoints, deprecated functionality, and content that may still be accessible on the target infrastructure. waybackurls provides historical content intelligence with date range filtering and URL pattern matching.

**Arjun** HTTP parameter discovery tool identifies hidden parameters through fuzzing, analysis techniques, and statistical methods that may reveal additional content access points and API functionality. Arjun provides parameter-focused discovery with intelligent fuzzing and validation.

**LinkFinder** JavaScript endpoint discovery tool extracts URLs, endpoints, and API paths from JavaScript source code, revealing hidden API endpoints, content paths, and administrative functionality. LinkFinder provides JavaScript-focused endpoint and content discovery with customizable extraction patterns.

**Custom Python Content Discovery Framework** combines multiple discovery techniques including comment analysis, hidden element detection, backup file probing, configuration file detection, and admin interface discovery into comprehensive content discovery pipelines with parallel processing, progress tracking, and result aggregation.

**Wfuzz** web application fuzzer performs content discovery through wordlist-based enumeration with payload processing, recursion, encoding, and advanced filtering capabilities. Wfuzz provides content discovery with advanced payload processing, encoding bypass, and recursive scanning.

**Nikto** web server scanner includes content discovery capabilities for default pages, common files, misconfigurations, and security issues across multiple web server platforms. Nikto provides comprehensive web server content discovery with security assessment capabilities.

**Photon** web crawler extracts emails, social media links, URLs, and other contact information from target websites for comprehensive content discovery and information gathering. Photon provides web-based content extraction and contact information discovery.

## Case Studies

**Case Study 1: Configuration File Exposure Discovery** - Content discovery for a SaaS platform identified 34 exposed configuration files including .env files containing database credentials, API keys, and cloud service tokens. .git directories with full source code history were exposed containing 847 commits revealing the complete development history including committed secrets, internal architecture details, and developer credentials. Application configuration files with API keys, OAuth client secrets, and webhook URLs were discovered in publicly accessible directories. Additional analysis identified 12 Docker configuration files with container orchestration details and 8 CI/CD configuration files with deployment credentials and infrastructure-as-code configurations.

**Case Study 2: Backup File Security Assessment** - Comprehensive backup file discovery for a financial institution revealed 234 backup files including database dumps (.sql.bak, database.dump), configuration backups (web.config.bak, application.properties.old), and application backups (.zip, .tar.gz). Analysis of backup files revealed 12 database credentials, 7 API keys, and 3 OAuth client secrets that were not present in the current production configuration. The backup analysis also identified 45 source code backups with hardcoded credentials and 23 configuration backups with outdated security settings including disabled authentication and weak encryption configurations.

**Case Study 3: Admin Interface Mapping** - Admin interface discovery for a healthcare portal identified 23 administrative interfaces including standard CMS admin panels, custom management consoles, debugging endpoints, and monitoring dashboards. Five admin interfaces had reduced authentication controls including missing multi-factor authentication and weak password policies. Three debug endpoints exposed sensitive system information including database connection strings, server configuration details, and internal IP addresses. The investigation also identified 8 monitoring dashboards with public access and 12 management consoles with default credentials.

**Case Study 4: JavaScript Comment Intelligence** - Analysis of JavaScript comments across a web application revealed 156 developer comments containing internal architecture information, TODO items indicating incomplete security implementations, and 23 commented-out API endpoints that remained accessible through direct URL requests. Comment analysis provided intelligence for targeted vulnerability assessment including endpoint discovery and configuration analysis. The analysis also identified 34 API keys in JavaScript comments and 12 internal URLs exposing development infrastructure and staging environments.

**Case Study 5: API Documentation Exposure** - Discovery of exposed Swagger UI and GraphQL introspection endpoints for a technology platform revealed the complete API surface including 2,347 endpoints, 156 types, and 89 mutations. Documentation analysis identified 67 endpoints with excessive data exposure, 23 endpoints with missing authentication requirements, and 34 deprecated endpoints with reduced security controls. The documentation also revealed 12 internal API endpoints accessible from public networks and administrative functionality with default access controls.

## Bypass Techniques

**Web Server Access Restriction Bypass** discovers content behind access controls through path traversal techniques, URL encoding variations, and HTTP method manipulation. Use double URL encoding, null byte injection, case variation, and Unicode normalization to bypass basic access restrictions. Implement IP address manipulation, X-Forwarded-For header injection, and HTTP method override techniques for restricted endpoint access. Use path traversal sequences (../, ..%2f, %2e%2e/) and encoding variations to bypass directory-based access controls.

**WAF and Filter Evasion** circumvents web application firewall protections during content discovery through payload encoding, fragmentation, and timing manipulation. Use Unicode normalization, case variation, parameter pollution, and payload splitting to evade WAF detection. Implement distributed discovery across multiple source IPs and user agents. Use chunked transfer encoding, request splitting, and protocol-level manipulation for WAF bypass. Implement randomized request patterns and timing to avoid behavioral detection.

**JavaScript-Based Content Discovery** identifies content accessible only through JavaScript execution using headless browser automation and dynamic analysis. Single-page applications often load content dynamically, lazy-load routes, and execute API calls that static content discovery tools cannot detect. Implement JavaScript execution environments including Puppeteer, Playwright, and Selenium for dynamic content extraction. Use DOM analysis after JavaScript execution for comprehensive content discovery including dynamically rendered content, lazy-loaded components, and API-driven interfaces.

**Recursive Content Discovery** explores discovered directories and paths for nested content that initial enumeration may miss through intelligent recursion strategies. Implement intelligent recursion that adapts discovery strategies based on discovered content types, directory structures, and technology patterns. Use recursive scanning with technology-specific wordlists, custom patterns, and depth-limited traversal for comprehensive coverage without excessive scanning duration.

**Technology-Specific Discovery** applies framework-specific, CMS-specific, and platform-specific content discovery patterns for targeted enumeration. WordPress, Drupal, Joomla, Laravel, Django, Ruby on Rails, and other platforms have distinctive content structures, configuration locations, and default files that enable targeted discovery. Implement technology-specific wordlists, path patterns, and discovery techniques for improved coverage and reduced false positives.

**Historical Content Recovery** discovers archived content through Wayback Machine, Google Cache, and other archival services that may still be accessible on the target infrastructure or provide intelligence for current content discovery. Implement historical content analysis for comprehensive coverage of legacy endpoints, deprecated functionality, and content that may have been removed but remains accessible through caching and archival services.

## Advanced Techniques

**Machine Learning Content Classification** applies supervised learning to discovered content for automated sensitivity classification, risk assessment, and prioritization. Train classifiers on labeled content datasets including file types, URL patterns, response characteristics, and content analysis results. Feature engineering extracts patterns that distinguish public, internal, and sensitive content based on multiple characteristics. Implement ensemble methods combining multiple classification approaches for improved accuracy and reduced false positive rates.

**Content Relationship Mapping** constructs dependency graphs connecting discovered content through links, references, functional relationships, and API calls. Graph analysis reveals critical content paths, sensitive data flows, information leakage chains, and access control bypass opportunities. Implement graph visualization for stakeholder communication and content relationship analysis.

**Automated Sensitive Data Detection** integrates data loss prevention techniques into content discovery for automated identification of sensitive information including credentials, PII, financial data, and proprietary information within discovered content. Implement regex-based sensitive data detection for comprehensive exposure assessment across discovered content repositories.

**Content Change Monitoring** implements continuous content discovery that detects new content, modified content, and removed content through baseline comparison and change detection. Change detection enables proactive security assessment of content modifications and new exposure events. Implement content change notification systems for security operations teams with configurable alerting thresholds.

**Content Security Assessment** evaluates discovered content for security implications including information disclosure, access control weaknesses, and data exposure risks. Automated assessment prioritizes content by security risk level and business criticality. Implement content risk scoring for security assessment prioritization and remediation planning.

**Developer Artifact Analysis** identifies development artifacts including source maps, test files, staging configurations, development documentation, and build artifacts that expose internal implementation details. Implement automated artifact detection for comprehensive development exposure assessment and information leakage identification.

## Detection Indicators

Content discovery activities generate detectable indicators across web server monitoring and application security systems. Web server logs capture content discovery requests including systematic path testing, file extension probing, hidden element access patterns, and backup file enumeration. Application monitoring tools detect content enumeration through unusual request patterns, automated access detection, and content access anomalies.

Security Information and Event Management (SIEM) systems correlate content discovery activities with other reconnaissance indicators including technology detection, version scanning, and endpoint mapping. Web application firewalls detect content discovery through signature-based request analysis, rate limiting, and behavioral pattern detection. File access monitoring identifies systematic backup file and configuration file probing. Intrusion detection systems identify content discovery traffic through pattern matching, request frequency analysis, and user-agent fingerprinting.

## Impact Assessment

Successful content discovery provides attackers with sensitive information including credentials, source code, configuration data, internal architecture details, and development artifacts. Exposed backup files and configuration files enable credential theft, source code analysis, and infrastructure exploitation. From a defensive perspective, content discovery audits identify information leakage, exposed sensitive resources, and access control weaknesses. Findings enable remediation of content exposure, access control implementation, and sensitive data protection.

Quantified risk assessment considers the sensitivity of discovered content, access control status, and potential exploitation impact. Critical findings include exposed credentials, source code repositories, configuration files with sensitive data, and administrative interfaces with default access controls.

## Common Pitfalls

Incomplete wordlist coverage limits content discovery effectiveness as application-specific content may not appear in standard wordlists. Custom wordlist generation based on application analysis improves discovery coverage significantly. JavaScript-heavy applications require headless browser rendering for complete content discovery as static tools cannot execute dynamic content loading. Missing JavaScript rendering results in incomplete content discovery for modern web applications.

Access control testing limitations prevent discovery of content behind authentication barriers without authenticated crawling capabilities. Multiple authentication contexts may be needed for comprehensive coverage across different user roles and permission levels. Content discovery rate limiting and blocking can interrupt enumeration activities without proper evasion techniques and distributed crawling strategies.

## Integration Points

Content discovery integrates with vulnerability scanning workflows to provide discovered content targets for security assessment. Feed content discovery results into vulnerability scanners for systematic security testing. Connect content discovery with source code analysis for security assessment of discovered code repositories. Integrate with configuration management for exposure identification and remediation tracking.

Content discovery results feed into penetration testing planning by identifying sensitive resources, potential information leakage, and high-value targets. Connect with threat intelligence for credential exposure monitoring and breach data correlation. Integrate content discovery with compliance frameworks for sensitive data exposure assessment. Feed content discovery data into risk assessment models for quantified security analysis.

## Reporting Templates

**Content Discovery Assessment Report** documents all discovered content organized by category, sensitivity, and risk classification. Include content statistics, exposure analysis, and remediation recommendations with business impact assessment.

**Sensitive Content Exposure Report** presents discovered sensitive content including credentials, configuration data, and source code with risk prioritization and immediate remediation guidance.

**Content Security Monitoring Dashboard** displays ongoing content discovery tracking including new content discoveries, content changes, and security alerts. Designed for operational teams with configurable alerting and escalation procedures.

## Practice Labs

**Lab 1: Multi-Technique Content Discovery** - Build a comprehensive content discovery pipeline combining comment analysis, hidden element detection, backup file probing, and configuration file discovery. Test against diverse web application targets with different technology stacks.

**Lab 2: JavaScript Comment Intelligence** - Develop JavaScript comment analysis tools that extract sensitive information including credentials, internal URLs, and TODO items from developer comments across different JavaScript frameworks and libraries.

**Lab 3: Exposed Git Repository Recovery** - Practice recovering exposed Git repositories using git-dumper and analyzing recovered source code for sensitive information, credentials, and security vulnerabilities.

**Lab 4: Content Monitoring Framework** - Implement continuous content monitoring that detects new content, modified content, and security-relevant content changes over time with configurable alerting thresholds.

## Ethics

Content discovery must be performed within authorized boundaries respecting target application consent and scope limitations. Obtain proper authorization before performing content discovery against web applications. Minimize discovery activities to necessary scope for authorized security assessments. Respect access controls and do not attempt to bypass security measures beyond assessment scope. Document all content discovery activities for accountability and compliance verification. Report discovered sensitive information through responsible disclosure channels while protecting data from unauthorized access.

## Quick Reference

| Content Type | Discovery Method | Risk Level |
|-------------|-----------------|------------|
| HTML Comments | Source analysis | Medium |
| Hidden Form Fields | DOM inspection | Medium |
| Backup Files | Extension probing | High |
| .env Files | Path probing | Critical |
| .git Directories | Path probing | Critical |
| Config Files | Path probing | Critical |
| Admin Panels | Path enumeration | High |
| Debug Endpoints | Path probing | High |
| API Documentation | Path probing | Medium |
| JavaScript Comments | JS analysis | Medium |
| Source Maps | Path probing | High |
| Test Files | Path probing | Medium |
| Log Files | Path probing | High |
| Database Dumps | Extension probing | Critical |
| Archive Files | Extension probing | High |
| Old Versions | Path probing | Medium |
| Error Pages | Trigger errors | Medium |
| Health Endpoints | Path probing | Low |
| Monitoring Dashboards | Path probing | Medium |
| Internal APIs | JS analysis | High |
| Hidden Parameters | Fuzzing | Medium |
| Disabled Elements | DOM inspection | Low |
| CSS Hidden Content | CSS analysis | Low |
| JavaScript Functions | Console analysis | Medium |
| Staging Environments | Subdomain enum | High |
| Docker Files | Path probing | High |
| CI/CD Configs | Path probing | Critical |
| Kubernetes Manifests | Path probing | Critical |
| Terraform Files | Path probing | High |
| Source Code Repos | git-dumper | Critical |
| Web Config Files | Path probing | High |
| PHP Info Pages | Path probing | High |
| Server Status | Path probing | Medium |
| Debug Logs | Path probing | High |
| Database Schemas | Path probing | Critical |
| API Keys in JS | JS analysis | Critical |
| Backup SQL Files | Extension probing | Critical |
| Environment Files | Path probing | Critical |
| Secret Files | Path probing | Critical |
| Internal DNS | Path probing | Medium |
| Cache Files | Path probing | Medium |
| Temp Files | Path probing | Medium |
| Upload Directories | Path probing | High |
| XML Config Files | Path probing | High |
| YAML Config Files | Path probing | High |
| JSON Config Files | Path probing | High |
| INI Config Files | Path probing | High |
| Properties Files | Path probing | High |
| Certificate Files | Path probing | Critical |
| Private Keys | Path probing | Critical |
| Password Files | Path probing | Critical |

---

## Deep Dive: Content Discovery Techniques

### Directory and File Brute-Forcing
```bash
# Gobuster - Directory brute-forcing
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -t 50

# FFUF - Fast web fuzzer
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403

# Dirsearch - Web path scanner
dirsearch -u https://target.com -e php,html,js,txt

# Feroxbuster - Recursive content discovery
feroxbuster -u https://target.com -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt

# Dirb - Web content scanner
dirb https://target.com /usr/share/wordlists/dirb/common.txt

# Wfuzz - Web application fuzzer
wfuzz -c -z file,/usr/share/wordlists/dirb/common.txt https://target.com/FUZZ
```

### Sensitive File Discovery
```python
#!/usr/bin/env python3
"""Sensitive file discovery"""

import requests
from typing import List, Dict

class SensitiveFileDiscovery:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.found_files = []

    def discover_sensitive_files(self) -> List[Dict]:
        """Discover sensitive files"""
        sensitive_paths = [
            # Configuration files
            '/.env',
            '/config.php',
            '/config.json',
            '/config.yml',
            '/wp-config.php',
            '/database.yml',
            '/settings.py',
            '/application.properties',
            '/web.config',

            # Backup files
            '/backup.zip',
            '/backup.tar.gz',
            '/db.sql',
            '/database.sql',
            '/dump.sql',

            # Source code
            '/.git/config',
            '/.git/HEAD',
            '/.svn/entries',
            '/.hg/',
            '/.bzr/',

            # Server files
            '/server-status',
            '/server-info',
            '/phpinfo.php',
            '/info.php',
            '/test.php',

            # Logs
            '/access.log',
            '/error.log',
            '/debug.log',
            '/application.log',

            # API documentation
            '/swagger.json',
            '/api-docs',
            '/openapi.json',
            '/graphql',

            # Admin interfaces
            '/admin/',
            '/administrator/',
            '/phpmyadmin/',
            '/adminer.php',

            # User data
            '/users.json',
            '/members.json',
            '/customers.json',

            # Security files
            '/.htaccess',
            '/.htpasswd',
            '/robots.txt',
            '/sitemap.xml',
            '/security.txt',
        ]

        for path in sensitive_paths:
            try:
                response = self.session.get(
                    f"{self.base_url}{path}",
                    timeout=5,
                    allow_redirects=False
                )

                if response.status_code == 200:
                    self.found_files.append({
                        'path': path,
                        'status': response.status_code,
                        'size': len(response.text),
                        'content_type': response.headers.get('Content-Type', 'Unknown'),
                        'sensitivity': self._assess_sensitivity(path)
                    })
            except Exception:
                continue

        return self.found_files

    def _assess_sensitivity(self, path: str) -> str:
        """Assess file sensitivity level"""
        high_sensitivity = [
            '.env', 'config.php', 'wp-config.php', 'database.yml',
            '.git/config', '.git/HEAD', 'server-status', 'phpinfo.php',
            'backup.zip', 'db.sql', '.htpasswd'
        ]

        medium_sensitivity = [
            'robots.txt', 'sitemap.xml', 'swagger.json', 'api-docs',
            'admin/', 'administrator/', 'phpmyadmin/'
        ]

        for item in high_sensitivity:
            if item in path:
                return 'high'

        for item in medium_sensitivity:
            if item in path:
                return 'medium'

        return 'low'

    def analyze_file_content(self, path: str) -> Dict:
        """Analyze file content for sensitive information"""
        try:
            response = self.session.get(
                f"{self.base_url}{path}",
                timeout=5
            )

            analysis = {
                'path': path,
                'contains_credentials': False,
                'contains_api_keys': False,
                'contains_internal_paths': False,
                'contains_database_info': False,
            }

            content = response.text.lower()

            # Check for credentials
            credential_patterns = [
                'password', 'passwd', 'pwd', 'secret',
                'api_key', 'apikey', 'api-key',
                'token', 'access_token', 'refresh_token',
                'private_key', 'private-key',
            ]

            for pattern in credential_patterns:
                if pattern in content:
                    analysis['contains_credentials'] = True
                    break

            # Check for API keys
            api_key_patterns = [
                'sk-', 'pk-', 'ak_', 'rk_',
                'ghp_', 'gho_', 'github_pat_',
                'xoxb-', 'xoxp-', 'xoxa-',
                'AKIA', 'ASIA',
            ]

            for pattern in api_key_patterns:
                if pattern in content:
                    analysis['contains_api_keys'] = True
                    break

            # Check for internal paths
            internal_patterns = [
                '/var/www/', '/home/', '/opt/', '/etc/',
                'C:\\', 'D:\\',
                '/usr/local/', '/usr/share/',
            ]

            for pattern in internal_patterns:
                if pattern in content:
                    analysis['contains_internal_paths'] = True
                    break

            # Check for database info
            db_patterns = [
                'mysql', 'postgresql', 'mongodb', 'redis',
                'sqlite', 'oracle', 'mssql',
                'database', 'db_name', 'db_host', 'db_user',
            ]

            for pattern in db_patterns:
                if pattern in content:
                    analysis['contains_database_info'] = True
                    break

            return analysis

        except Exception:
            return {}

# Usage
discovery = SensitiveFileDiscovery("https://target.com")
files = discovery.discover_sensitive_files()
for file in files:
    print(f"[{file['sensitivity'].upper()}] {file['path']} ({file['size']} bytes)")
```

### Hidden Content Discovery
```python
#!/usr/bin/env python3
"""Hidden content discovery via JavaScript analysis"""

import requests
import re
from typing import Dict, List, Set

class HiddenContentDiscovery:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.hidden_content = {
            'comments': [],
            'disabled_fields': [],
            'hidden_fields': [],
            'javascript_functions': [],
            'api_endpoints': [],
            'internal_urls': [],
        }

    def discover_from_html(self) -> Dict:
        """Discover hidden content from HTML"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            content = response.text

            # HTML comments
            comments = re.findall(r'<!--(.*?)-->', content, re.DOTALL)
            self.hidden_content['comments'] = comments

            # Disabled fields
            disabled_fields = re.findall(r'<input[^>]*disabled[^>]*>', content)
            self.hidden_content['disabled_fields'] = disabled_fields

            # Hidden fields
            hidden_fields = re.findall(r'<input[^>]*type=["\']hidden["\'][^>]*>', content)
            self.hidden_content['hidden_fields'] = hidden_fields

        except Exception:
            pass

        return self.hidden_content

    def discover_from_javascript(self) -> Dict:
        """Discover hidden content from JavaScript"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            js_files = re.findall(r'src=["\']([^"\']+\.js)["\']', response.text)

            for js_file in js_files:
                js_url = f"{self.base_url}/{js_file}"
                try:
                    js_response = self.session.get(js_url, timeout=5)
                    js_content = js_response.text

                    # Find function definitions
                    functions = re.findall(r'function\s+(\w+)\s*\(', js_content)
                    self.hidden_content['javascript_functions'].extend(functions)

                    # Find API endpoints
                    api_endpoints = re.findall(r'["\'](/api/[^"\']+)["\']', js_content)
                    self.hidden_content['api_endpoints'].extend(api_endpoints)

                    # Find internal URLs
                    internal_urls = re.findall(r'["\']https?://[^"\']*target\.com[^"\']*["\']', js_content)
                    self.hidden_content['internal_urls'].extend(internal_urls)

                except Exception:
                    continue

        except Exception:
            pass

        return self.hidden_content

    def discover_from_css(self) -> Dict:
        """Discover hidden content from CSS"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            css_files = re.findall(r'href=["\']([^"\']+\.css)["\']', response.text)

            for css_file in css_files:
                css_url = f"{self.base_url}/{css_file}"
                try:
                    css_response = self.session.get(css_url, timeout=5)
                    css_content = css_response.text

                    # Find display:none elements
                    display_none = re.findall(r'display:\s*none[^}]*}', css_content)
                    self.hidden_content['hidden_elements'] = display_none

                    # Find visibility:hidden elements
                    visibility_hidden = re.findall(r'visibility:\s*hidden[^}]*}', css_content)
                    self.hidden_content['invisible_elements'] = visibility_hidden

                except Exception:
                    continue

        except Exception:
            pass

        return self.hidden_content

    def generate_report(self) -> str:
        """Generate hidden content report"""
        report = "=== Hidden Content Discovery Report ===\n"
        report += f"Target: {self.base_url}\n\n"

        report += f"HTML Comments: {len(self.hidden_content['comments'])}\n"
        for comment in self.hidden_content['comments'][:5]:
            report += f"  - {comment[:100]}...\n"

        report += f"\nDisabled Fields: {len(self.hidden_content['disabled_fields'])}\n"
        report += f"Hidden Fields: {len(self.hidden_content['hidden_fields'])}\n"
        report += f"JavaScript Functions: {len(self.hidden_content['javascript_functions'])}\n"
        report += f"API Endpoints: {len(self.hidden_content['api_endpoints'])}\n"
        report += f"Internal URLs: {len(self.hidden_content['internal_urls'])}\n"

        return report

# Usage
discovery = HiddenContentDiscovery("https://target.com")
discovery.discover_from_html()
discovery.discover_from_javascript()
discovery.discover_from_css()
print(discovery.generate_report())
```

---

## Content Discovery Automation Pipeline

```python
#!/usr/bin/env python3
"""Automated content discovery pipeline"""

import asyncio
import aiohttp
import json
import sys
from typing import Dict, List, Set
from dataclasses import dataclass

@dataclass
class ContentResult:
    path: str
    status_code: int
    size: int
    content_type: str
    sensitivity: str
    category: str

class ContentDiscoveryPipeline:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.results = []

    async def discover_content(self) -> List[ContentResult]:
        """Run content discovery pipeline"""
        print(f"[*] Starting content discovery for: {self.base_url}")

        # Phase 1: Common paths
        common_paths = await self._discover_common_paths()

        # Phase 2: Sensitive files
        sensitive_files = await self._discover_sensitive_files()

        # Phase 3: API endpoints
        api_endpoints = await self._discover_api_endpoints()

        # Phase 4: Hidden content
        hidden_content = await self._discover_hidden_content()

        # Combine results
        self.results = common_paths + sensitive_files + api_endpoints + hidden_content

        return self.results

    async def _discover_common_paths(self) -> List[ContentResult]:
        """Discover common paths"""
        common_paths = [
            '/admin', '/login', '/register', '/dashboard',
            '/api', '/api/v1', '/api/v2',
            '/users', '/user', '/account',
            '/settings', '/config',
            '/backup', '/export', '/import',
            '/upload', '/download',
            '/search', '/help', '/support',
        ]

        results = []
        async with aiohttp.ClientSession() as session:
            for path in common_paths:
                try:
                    async with session.get(
                        f"{self.base_url}{path}",
                        timeout=aiohttp.ClientTimeout(total=5)
                    ) as response:
                        if response.status in [200, 301, 302, 403]:
                            results.append(ContentResult(
                                path=path,
                                status_code=response.status,
                                size=0,
                                content_type=response.headers.get('Content-Type', 'Unknown'),
                                sensitivity=self._assess_sensitivity(path),
                                category='common'
                            ))
                except Exception:
                    continue

        return results

    async def _discover_sensitive_files(self) -> List[ContentResult]:
        """Discover sensitive files"""
        sensitive_paths = [
            '/.env', '/config.php', '/wp-config.php',
            '/.git/config', '/.git/HEAD',
            '/server-status', '/phpinfo.php',
            '/backup.zip', '/db.sql',
            '/robots.txt', '/sitemap.xml',
        ]

        results = []
        async with aiohttp.ClientSession() as session:
            for path in sensitive_paths:
                try:
                    async with session.get(
                        f"{self.base_url}{path}",
                        timeout=aiohttp.ClientTimeout(total=5)
                    ) as response:
                        if response.status == 200:
                            results.append(ContentResult(
                                path=path,
                                status_code=response.status,
                                size=0,
                                content_type=response.headers.get('Content-Type', 'Unknown'),
                                sensitivity='high',
                                category='sensitive'
                            ))
                except Exception:
                    continue

        return results

    async def _discover_api_endpoints(self) -> List[ContentResult]:
        """Discover API endpoints"""
        api_paths = [
            '/api', '/api/v1', '/api/v2',
            '/graphql', '/swagger', '/api-docs',
            '/rest', '/soap',
        ]

        results = []
        async with aiohttp.ClientSession() as session:
            for path in api_paths:
                try:
                    async with session.get(
                        f"{self.base_url}{path}",
                        timeout=aiohttp.ClientTimeout(total=5)
                    ) as response:
                        if response.status in [200, 400, 401, 403]:
                            results.append(ContentResult(
                                path=path,
                                status_code=response.status,
                                size=0,
                                content_type=response.headers.get('Content-Type', 'Unknown'),
                                sensitivity='medium',
                                category='api'
                            ))
                except Exception:
                    continue

        return results

    async def _discover_hidden_content(self) -> List[ContentResult]:
        """Discover hidden content"""
        # Implementation for hidden content discovery
        return []

    def _assess_sensitivity(self, path: str) -> str:
        """Assess sensitivity level"""
        high_sensitivity = ['.env', 'config', 'backup', '.git', 'db.sql']
        for item in high_sensitivity:
            if item in path:
                return 'high'
        return 'medium'

    def generate_report(self) -> str:
        """Generate discovery report"""
        report = "=== Content Discovery Report ===\n"
        report += f"Target: {self.base_url}\n"
        report += f"Total Content Found: {len(self.results)}\n\n"

        # Group by category
        categories = {}
        for result in self.results:
            if result.category not in categories:
                categories[result.category] = []
            categories[result.category].append(result)

        for category, items in categories.items():
            report += f"\n--- {category.upper()} ({len(items)} items) ---\n"
            for item in items:
                report += f"  [{item.sensitivity.upper()}] {item.path} ({item.status_code})\n"

        return report

# Usage
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    pipeline = ContentDiscoveryPipeline(sys.argv[1])
    results = asyncio.run(pipeline.discover_content())
    print(pipeline.generate_report())
```

---

## Reporting Templates

### Content Discovery Report
```
## Content Discovery Report

### Target: [url]

### Discovery Summary
- Total content found: [count]
- High sensitivity: [count]
- Medium sensitivity: [count]
- Low sensitivity: [count]

### Sensitive Files Found
[List sensitive files with paths]

### Hidden Content
[List hidden content findings]

### API Endpoints
[List discovered API endpoints]

### Findings
1. [Finding 1]
2. [Finding 2]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
```

### Content Sensitivity Matrix
| Severity | Condition | Impact |
|----------|-----------|--------|
| Critical | Credentials exposed | Account compromise |
| High | Source code leaked | Full compromise |
| Medium | Configuration disclosed | Reconnaissance aid |
| Low | Public content | Normal operation |

---

## Quick Reference Cheat Sheet

### Directory Brute-forcing
```bash
gobuster dir -u https://target.com -w wordlist.txt
ffuf -u https://target.com/FUZZ -w wordlist.txt
feroxbuster -u https://target.com -w wordlist.txt
```

### Sensitive File Discovery
```bash
# Common sensitive files
.env, config.php, wp-config.php
.git/config, .git/HEAD
server-status, phpinfo.php
backup.zip, db.sql
```

### JavaScript Analysis
```bash
linkfinder -i https://target.com -o cli
SecretFinder.py -i https://target.com/app.js -o cli
```

---

## Resources and References
- Gobuster: https://github.com/OJ/gobuster
- FFUF: https://github.com/ffuf/ffuf
- Feroxbuster: https://github.com/epi052/feroxbuster
- LinkFinder: https://github.com/GerbenJav)ado/LinkFinder
- SecretFinder: https://github.com/m4ll0k/SecretFinder
