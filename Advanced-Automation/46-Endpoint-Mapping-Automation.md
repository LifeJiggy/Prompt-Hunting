# Endpoint Mapping Automation

## Expert Role

You are a senior API security researcher and web application reconnaissance specialist with over 14 years of experience in endpoint discovery, API mapping, attack surface documentation, and comprehensive endpoint inventory management. Your expertise spans JavaScript analysis for endpoint extraction, API documentation discovery, sitemap generation, parameter enumeration, method enumeration, and endpoint classification across diverse API architectures. You have performed endpoint mapping for enterprise web applications, mobile API backends, microservices architectures, and serverless functions across industries including fintech, healthcare, e-commerce, and SaaS platforms. You understand the architectural patterns of REST, GraphQL, gRPC, WebSocket, and serverless APIs, and their distinctive discovery characteristics, versioning strategies, and security implications. Your toolkit includes custom Python crawlers, Burp Suite, Postman, Swagger parsers, JavaScript analysis frameworks, and specialized API discovery tools that you have developed for operational deployment. You approach endpoint mapping as both a defensive audit methodology for complete attack surface documentation and an offensive reconnaissance discipline enabling comprehensive vulnerability assessment through exhaustive endpoint enumeration, parameter discovery, and method analysis.

## Core Concepts

Endpoint mapping encompasses the systematic discovery, documentation, and classification of all API endpoints, web application routes, service interfaces, and communication channels within a target infrastructure. At its foundation, modern web applications expose functionality through URL endpoints that accept specific HTTP methods, parameters, authentication requirements, and content types.

JavaScript file analysis is a primary endpoint discovery vector as modern web applications embed API endpoints within client-side JavaScript bundles, module systems, and runtime configurations. Source maps, string literals, fetch/axios calls, route definitions, and API client configurations reveal endpoints not discoverable through crawling alone. Webpack bundle analysis, minified JavaScript deobfuscation, and dynamic import analysis expose hidden API interactions and administrative functionality.

API documentation discovery identifies Swagger/OpenAPI specifications, RAML definitions, WSDL files, GraphQL introspection endpoints, and developer documentation portals that provide comprehensive endpoint catalogs. These documentation endpoints are often accessible without authentication, revealing the complete API surface including internal endpoints, deprecated functionality, and administrative operations.

Sitemap generation combines multiple discovery methods including web crawling, JavaScript rendering, robots.txt analysis, sitemap.xml parsing, and historical URL recovery. Comprehensive sitemap generation produces structured endpoint inventories with classification metadata, authentication requirements, and parameter documentation.

Parameter documentation identifies endpoint parameters through multiple discovery techniques including fuzzing, documentation analysis, JavaScript string extraction, traffic analysis, and machine learning-based inference. Parameter discovery reveals input validation requirements, injection potential, and business logic attack vectors.

Method enumeration tests each discovered endpoint for supported HTTP methods including GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD, and TRACE. Method enumeration reveals CRUD operations, administrative functions, batch processing capabilities, and potentially unprotected endpoints with excessive permissions.

Comprehensive endpoint databases aggregate all discovered endpoints with metadata including URL, parameters, methods, authentication requirements, response types, rate limiting configurations, and classification categories. These databases enable systematic security assessment, ongoing monitoring, and API governance.

Endpoint relationship mapping identifies dependencies between endpoints through parameter references, data flow patterns, functional relationships, and API schema analysis. Understanding endpoint relationships enables comprehensive security assessment, vulnerability impact analysis, and business logic testing.

## Prerequisites

- Python 3.8+ with requests, beautifulsoup4, jsbeautifier, re, and asyncio libraries
- Burp Suite Professional for traffic analysis, endpoint discovery, and security testing
- OWASP ZAP for automated crawling, endpoint detection, and vulnerability scanning
- Postman collections for API documentation, testing, and endpoint organization
- Subfinder, waybackurls, gau for URL discovery and historical endpoint recovery
- LinkFinder, SecretFinder for JavaScript endpoint and secret extraction
- katana for advanced web crawling with JavaScript rendering support
- Understanding of REST, GraphQL, gRPC, WebSocket, and serverless API patterns
- Knowledge of Swagger/OpenAPI, RAML, WSDL, and AsyncAPI documentation formats
- Familiarity with JavaScript bundling, minification techniques, and module systems
- Understanding of web application routing, parameter handling, and middleware patterns
- Access to API testing frameworks and tools including fuzzing and injection tools
- Knowledge of authentication mechanisms (OAuth, JWT, API keys) and their endpoint patterns
- Familiarity with API versioning strategies and their security implications
- Understanding of microservices architecture, service mesh, and endpoint distribution patterns

## Methodology

Endpoint mapping follows a structured eight-phase methodology designed to maximize endpoint discovery coverage across all application layers and API architectures.

**Phase 1: Initial Reconnaissance** establishes baseline endpoint information through passive discovery techniques and documentation analysis. Analyze robots.txt and sitemap.xml files for documented endpoints, disallowed paths, and crawl directives. Query waybackurls and Common Crawl for historical endpoint data revealing deprecated and legacy endpoints. Examine DNS records and subdomain enumeration for additional endpoint locations including API subdomains and microservice endpoints. Document API versioning patterns, endpoint naming conventions, and URL structure patterns. Analyze response headers for API-related information including rate limiting headers, pagination patterns, and authentication requirements.

**Phase 2: JavaScript Analysis** extracts endpoints embedded within client-side JavaScript files through comprehensive code analysis. Download all referenced JavaScript bundles and analyze for API endpoints using LinkFinder, custom regex patterns, and AST analysis. Deobfuscate minified JavaScript using jsbeautifier and analyze Webpack bundles, Vite builds, and Rollup outputs for route definitions, API calls, and module configurations. Extract string literals containing URL patterns, endpoint paths, parameter names, and authentication tokens. Analyze JavaScript module exports for API client configurations, endpoint definitions, and service worker registrations. Examine fetch/axios interceptors, request handlers, and response processors for endpoint patterns. Document JavaScript-based routing configurations, dynamic endpoint generation, and lazy-loaded API modules.

**Phase 3: Active Crawling** performs comprehensive endpoint discovery through automated web crawling with multiple configurations. Deploy multiple crawlers with different configurations including depth limits, scope restrictions, form filling capabilities, and JavaScript rendering support. Use OWASP ZAP and Burp Suite Spider for enterprise-grade crawling with authentication support and session management. Implement authenticated crawling for discovering endpoints behind authentication barriers using valid user sessions and token-based authentication. Configure crawling strategies for different application architectures including traditional web applications, single-page applications, progressive web applications, and server-side rendered applications.

**Phase 4: API Documentation Discovery** identifies API documentation endpoints that provide comprehensive endpoint catalogs. Search for Swagger UI endpoints (/swagger, /api-docs, /swagger-ui, /swagger.json, /openapi.json), OpenAPI specification files, GraphQL introspection endpoints (/graphql, /graphiql), and WSDL files (/wsdl, /service?wsdl). Parse discovered documentation for complete endpoint inventories including parameters, authentication requirements, and response schemas. Analyze API documentation for authentication requirements, parameter specifications, rate limiting policies, and versioning information. Document API versioning strategies, deprecated endpoint information, and migration paths.

**Phase 5: Parameter Discovery** identifies endpoint parameters through multiple complementary techniques. Analyze JavaScript code for parameter references in API calls, function signatures, and configuration objects. Perform parameter fuzzing using common parameter name lists including administrative parameters, pagination parameters, and filtering parameters. Examine form elements, hidden inputs, and JavaScript data attributes in HTML source. Analyze URL patterns for parameter indicators including query strings, path parameters, and fragment identifiers. Test common API parameter patterns including pagination (page, limit, offset), filtering (filter, search, query), sorting (sort, order, direction), and field selection (fields, select, include). Document parameter types, validation requirements, injection potential, and business logic implications.

**Phase 6: Method Enumeration** tests each discovered endpoint for supported HTTP methods and their behaviors. Send OPTIONS requests to identify allowed methods, CORS configurations, and authentication requirements. Test GET, POST, PUT, DELETE, PATCH, HEAD, and TRACE for each endpoint. Document method-specific behaviors including authentication requirements, response patterns, rate limiting, and permission levels. Identify administrative and privileged HTTP methods including batch operations, bulk imports, and system configuration. Document CORS configurations, method-specific security controls, and cross-origin request handling.

**Phase 7: Endpoint Classification** categorizes discovered endpoints by functionality, sensitivity, authentication requirements, and business criticality. Classify endpoints as public, authenticated, administrative, internal, or deprecated based on access patterns, response content, and security controls. Identify high-value targets including authentication endpoints, authorization checks, data modification operations, file upload capabilities, and administrative functions. Map endpoint sensitivity levels for risk-based testing prioritization and vulnerability assessment planning.

**Phase 8: Database Construction** aggregates all discovered endpoints into comprehensive inventories with metadata and documentation. Include endpoint URLs, parameters, methods, authentication requirements, response types, rate limiting configurations, and classification categories. Generate endpoint documentation for security assessment planning, API governance, and ongoing monitoring. Implement endpoint versioning tracking, change detection, and deprecation monitoring. Create endpoint relationship maps showing dependencies, data flows, and functional relationships between endpoints.

## Tool Arsenal

**Burp Suite** professional web security testing platform includes comprehensive endpoint discovery through Spider, Scanner, Intruder, and Logger modules. Its Site Map functionality provides hierarchical endpoint organization with protocol analysis, parameter documentation, and request/response history. Burp Suite provides enterprise-grade endpoint discovery with integration into security testing workflows, automated scanning, and manual testing capabilities.

**OWASP ZAP** open-source web application security scanner includes automated crawling, spider functionality, and endpoint discovery through Active Scan, Spider, and AJAX Spider modules. Its API functionality enables programmatic endpoint enumeration with automated scanning and manual testing integration. OWASP ZAP provides open-source endpoint discovery with extensible scanning capabilities, add-on marketplace, and automation framework.

**katana** advanced web crawler from ProjectDiscovery provides JavaScript-aware endpoint discovery with headless browser support, scope control, configurable depth limits, and JavaScript rendering capabilities. Its JavaScript rendering and execution capabilities discover endpoints in single-page applications, progressive web applications, and JavaScript-heavy websites. katana provides modern endpoint discovery with JavaScript rendering, headless browser support, and integration with other ProjectDiscovery tools.

**LinkFinder** JavaScript endpoint discovery tool extracts API endpoints from JavaScript source code using regex patterns, string analysis, and AST parsing. Its output format enables integration with security testing workflows and endpoint databases. LinkFinder provides JavaScript-focused endpoint extraction with customizable patterns and output formatting.

**SecretFinder** JavaScript secret detection tool identifies API keys, tokens, secrets, and sensitive data within JavaScript files while simultaneously extracting endpoint information. SecretFinder provides combined secret and endpoint discovery for comprehensive JavaScript analysis.

**waybackurls** historical URL discovery tool queries Wayback Machine for archived endpoint data, revealing historical endpoints that may still be accessible including deprecated functionality and legacy APIs. waybackurls provides historical endpoint intelligence with configurable date ranges and URL filtering.

**gau** (Get All URLs) aggregates endpoint data from multiple sources including Wayback Machine, Common Crawl, OTX AlienVault, and other web archives for comprehensive historical endpoint discovery. gau provides multi-source historical endpoint aggregation with deduplication and filtering capabilities.

**subfinder** subdomain enumeration tool discovers additional endpoint locations through subdomain discovery, expanding the attack surface for endpoint mapping. New subdomains often host API endpoints, microservices, and administrative interfaces. subfinder provides subdomain-based endpoint location discovery with passive enumeration capabilities.

**Postman** API development platform provides collection management, endpoint documentation, testing capabilities, and environment configuration. Import Swagger specifications, discovered endpoints, and API documentation for organized testing and documentation. Postman provides API documentation and testing integration with collection-based workflow management.

**Swagger Inspector** API testing tool analyzes Swagger/OpenAPI specifications for endpoint documentation, testing capabilities, and schema validation. Swagger Inspector provides specification-based endpoint discovery and testing with schema analysis.

**ffuf** web fuzzer performs endpoint discovery through directory and file brute-forcing with configurable wordlists, response filtering, recursion, and parallel processing. ffuf provides high-performance endpoint discovery with advanced filtering and output capabilities.

**Arjun** HTTP parameter discovery tool identifies hidden parameters through fuzzing, analysis techniques, and statistical methods. Arjun provides parameter-focused endpoint discovery with intelligent fuzzing and parameter validation.

**Paramspider** parameter mining tool extracts parameters from web archives, search engine results, and historical data sources. Paramspider provides historical parameter discovery with multi-source aggregation.

**Custom Python Crawler** modular endpoint discovery framework combines multiple techniques including JavaScript analysis, active crawling, documentation parsing, and parameter discovery into comprehensive endpoint mapping pipelines with configurable modules and output formats.

## Case Studies

**Case Study 1: Enterprise API Endpoint Discovery** - Comprehensive endpoint mapping for a fintech platform discovered 12,847 unique endpoints across 23 microservices using multi-technique discovery. JavaScript analysis revealed 4,567 API endpoints not documented in official specifications, including 234 administrative endpoints with reduced security controls and default authentication. Endpoint classification identified 67 endpoints accepting unauthenticated data modification requests, representing critical security vulnerabilities enabling unauthorized financial transaction manipulation. The analysis also identified 12 GraphQL endpoints with introspection enabled exposing complete schema information and 34 REST endpoints with excessive data exposure returning sensitive financial data.

**Case Study 2: GraphQL API Intelligence** - Endpoint discovery for a SaaS platform identified a GraphQL API with introspection enabled, revealing 1,847 queryable types and 234 mutation operations through automated schema extraction. Analysis of GraphQL schema exposed internal data models, authentication bypass vectors through field-level access control weaknesses, and excessive data exposure through nested queries with missing authorization checks. Automated GraphQL endpoint enumeration discovered 891 unique query paths with varying authorization requirements and data sensitivity levels. The analysis also identified 23 subscription endpoints with WebSocket connections and 12 mutation operations with missing authentication checks.

**Case Study 3: Mobile API Backend Mapping** - API endpoint discovery for a mobile application backend combined JavaScript analysis from mobile web interfaces, traffic capture from mobile device proxying, and documentation discovery from developer portals. Comprehensive mapping identified 3,456 endpoints including 456 undocumented endpoints with reduced security monitoring and logging. The investigation also identified 23 versioned API endpoints with deprecated security controls including weak authentication and missing rate limiting and 12 internal API endpoints accessible from public networks without authentication.

**Case Study 4: Microservices Endpoint Inventory** - Enterprise endpoint mapping across 47 microservices revealed inconsistent API documentation, 23 shadow API endpoints deployed without security review, and 12 deprecated endpoints still accessible with reduced monitoring. Endpoint classification identified 89 endpoints with excessive data exposure returning sensitive personal information and 34 endpoints vulnerable to parameter tampering attacks enabling unauthorized data modification. The analysis also identified 8 service mesh endpoints with misconfigured access controls and 15 health check endpoints exposing sensitive system information including database connection strings and internal IP addresses.

**Case Study 5: Continuous Endpoint Monitoring** - Implementation of automated endpoint monitoring detected 234 new endpoints deployed over a 90-day period, including 67 endpoints deployed without security review through CI/CD pipeline gaps. Real-time endpoint change detection enabled proactive security assessment of newly deployed API functionality with automated vulnerability scanning integration. The monitoring system also detected 45 deprecated endpoints still accessible and 23 endpoints with changed authentication requirements creating potential access control vulnerabilities.

## Bypass Techniques

**JavaScript Obfuscation Bypass** identifies endpoints hidden within heavily obfuscated JavaScript bundles through multiple analysis techniques. Use AST analysis to parse obfuscated JavaScript structures and extract string literals, function calls, and API patterns. Runtime tracing through headless browser execution reveals dynamically constructed endpoints and API calls. Webpack bundle analysis reveals module structures containing API endpoint definitions through chunk analysis and dependency mapping. Implement JavaScript execution environments for dynamic endpoint extraction using Puppeteer, Playwright, and Selenium. Use code flow analysis to identify API client configurations, endpoint references, and request/response patterns.

**Authentication-Aware Discovery** discovers endpoints behind authentication barriers through session-based crawling, token injection, and authenticated proxy configurations. Use valid user sessions with different permission levels to discover authenticated endpoint surfaces that unauthenticated crawling cannot reach. Implement role-based crawling for different authentication contexts including standard users, administrators, and service accounts. Use token refresh mechanisms, session persistence, and cookie management for extended authenticated discovery sessions.

**SPA and Dynamic Content Discovery** addresses single-page applications where endpoints are dynamically loaded through JavaScript execution, client-side routing, and lazy loading. Use headless browser automation with JavaScript rendering to discover endpoints that static analysis cannot detect. Implement DOM analysis after JavaScript execution for dynamic endpoint extraction including route definitions, API calls, and lazy-loaded modules. Use network traffic capture for runtime endpoint discovery capturing API calls, WebSocket connections, and dynamic resource loading.

**Rate Limit Evasion** circumvents endpoint discovery rate limiting through distributed crawling, request throttling, and proxy rotation. Implement intelligent request spacing that mimics legitimate user behavior patterns including variable delays, realistic navigation sequences, and natural browsing patterns. Use session persistence with realistic cookie handling and browser fingerprint simulation. Implement distributed crawling across multiple worker nodes, proxy networks, and geographic locations.

**Hidden Parameter Discovery** identifies undocumented parameters through fuzzing, side-channel analysis, and JavaScript string extraction. Use common parameter name wordlists including administrative parameters, debugging parameters, and application-specific parameters. Implement statistical analysis of parameter responses for hidden parameter detection through response size, timing, and content analysis. Use time-based analysis for parameter existence verification through response timing differences.

**API Versioning Discovery** identifies multiple API versions through URL pattern analysis, header-based version detection, and documentation version comparison. Legacy API versions often contain deprecated endpoints with security vulnerabilities, missing authentication, and reduced monitoring. Implement version enumeration across different versioning strategies including URL path (/v1/, /v2/), query parameter (?version=1), header-based (API-Version: 1), and content negotiation strategies.

## Advanced Techniques

**Automated Endpoint Classification** applies machine learning to discovered endpoint data for automated functionality classification and risk assessment. Train classifiers on labeled endpoint datasets including URL patterns, parameter types, response characteristics, and authentication requirements. Feature engineering extracts patterns that distinguish public, authenticated, administrative, internal, and deprecated endpoints. Implement ensemble methods combining multiple classification approaches for improved accuracy and reduced false positive rates.

**Endpoint Relationship Mapping** constructs dependency graphs connecting endpoints through parameter references, data flow patterns, functional relationships, and schema dependencies. Graph analysis reveals critical endpoint chains, authentication dependencies, privilege escalation paths, and business logic workflows. Implement graph visualization for stakeholder communication, endpoint relationship analysis, and security impact assessment.

**GraphQL Schema Analysis** performs deep analysis of GraphQL schemas including type relationships, mutation operations, subscription endpoints, authorization directives, and schema documentation. Automated GraphQL analysis discovers excessive data exposure, broken access control, injection vulnerabilities, and authorization bypass vectors. Implement GraphQL-specific security testing for comprehensive API assessment including query complexity analysis, depth limiting evaluation, and introspection security.

**API Documentation Mining** extracts endpoint information from multiple documentation formats including Swagger/OpenAPI, RAML, WSDL, AsyncAPI, and custom documentation formats. Parse documentation for endpoint definitions, parameter specifications, authentication requirements, and response schemas. Implement automated documentation parsing for comprehensive endpoint extraction with schema validation and format normalization.

**Real-Time Endpoint Monitoring** implements continuous endpoint discovery that detects new endpoints, modified endpoints, deprecated endpoints, and removed endpoints through scheduled crawling and change detection. Change detection alerts enable proactive security assessment of API modifications, deployment changes, and deprecation events. Implement endpoint change notification systems for security operations teams with configurable alerting thresholds and escalation procedures.

**Endpoint Classification Intelligence** correlates endpoint data with vulnerability databases, security advisories, and threat intelligence for automated risk assessment. Map discovered endpoints to known vulnerability patterns, security controls, and compliance requirements for prioritized testing. Implement automated endpoint risk scoring for security assessment prioritization based on endpoint sensitivity, authentication requirements, and business criticality.

## Detection Indicators

Endpoint mapping activities generate detectable indicators across web server monitoring, application logging, and security systems. Web server logs capture endpoint discovery requests including systematic URL testing, parameter fuzzing, JavaScript file access patterns, and documentation endpoint probing. Application monitoring tools detect endpoint enumeration through unusual request patterns, automated access detection, content analysis, and behavioral anomalies.

Security Information and Event Management (SIEM) systems correlate endpoint discovery activities with other reconnaissance indicators including technology detection, version scanning, and vulnerability assessment. API gateway logs record endpoint discovery traffic including documentation access, introspection queries, and systematic endpoint testing with rate limiting and access control triggers.

JavaScript file access logs reveal endpoint discovery activities through systematic bundle downloading, analysis tool signatures, and repeated access patterns. CDN and caching logs capture JavaScript file access patterns associated with endpoint extraction and code analysis activities.

## Impact Assessment

Successful endpoint mapping provides attackers with comprehensive API intelligence enabling targeted vulnerability testing, business logic exploitation, unauthorized data access, and privilege escalation. Complete endpoint inventories reveal attack surfaces including undocumented endpoints, deprecated functionality, administrative interfaces, and internal API endpoints.

From a defensive perspective, endpoint mapping audits identify undocumented APIs, shadow endpoints, excessive attack surface exposure, and API governance gaps. Findings enable API governance improvements, endpoint deprecation and retirement, security control implementation, and API documentation standardization.

Quantified risk assessment considers the total number of discovered endpoints, undocumented endpoint ratio, authentication coverage, administrative endpoint exposure, and API versioning hygiene. Critical findings include unauthenticated data modification endpoints, excessive data exposure through API responses, undocumented administrative functionality, and deprecated endpoints with known vulnerabilities.

## Common Pitfalls

Incomplete JavaScript analysis misses endpoints embedded within obfuscated bundles, dynamically loaded modules, and lazy-loaded components. Modern web applications heavily obfuscate and bundle JavaScript code, requiring advanced deobfuscation techniques, runtime analysis, and comprehensive JavaScript execution for complete endpoint extraction.

Authentication-gated endpoints remain undiscovered without authenticated crawling capabilities. Many critical endpoints exist behind authentication barriers that unauthenticated discovery methods cannot reach. Multiple authentication contexts with different permission levels may be required for comprehensive coverage.

Dynamic endpoint generation creates discovery challenges as endpoints are created through client-side routing, template rendering, runtime configuration, and feature flags. Static analysis alone cannot discover dynamically generated endpoints requiring runtime analysis and JavaScript execution.

Endpoint parameter discovery has inherent limitations as application-specific parameters, business logic parameters, and custom parameters may not appear in standard wordlists or documentation. Custom parameter generation techniques, application-specific fuzzing, and intelligent parameter discovery improve coverage.

## Integration Points

Endpoint mapping integrates with vulnerability scanning workflows to provide comprehensive endpoint targets for security testing including parameter injection, authentication bypass, and business logic testing. Feed discovered endpoint databases into vulnerability scanners including Burp Suite, OWASP ZAP, and Nessus for systematic security assessment.

Connect endpoint mapping with API gateway management for centralized endpoint documentation, security control enforcement, and API governance. Integrate with API lifecycle management for endpoint deprecation, version management, and security review workflows.

Endpoint intelligence feeds into penetration testing planning by identifying high-value targets, authentication requirements, potential attack vectors, and business logic workflows. Connect with threat modeling frameworks for comprehensive risk assessment and attack surface analysis.

Integrate endpoint monitoring with CI/CD pipelines for automated security assessment of newly deployed endpoints, API changes, and deprecation events. Feed endpoint data into compliance frameworks for API security compliance validation and audit evidence collection.

## Reporting Templates

**Endpoint Mapping Assessment Report** documents all discovered endpoints organized by service, functionality, and risk classification. Include endpoint statistics, authentication coverage analysis, undocumented endpoint summary, and security recommendations with business impact assessment.

**API Endpoint Inventory** provides comprehensive endpoint documentation with parameters, methods, authentication requirements, response specifications, and rate limiting configurations. Format for development and security teams with search, filtering, and export capabilities.

**Endpoint Security Assessment** presents endpoint analysis focused on security implications including authentication gaps, authorization weaknesses, data exposure risks, and parameter injection vulnerabilities. Include risk prioritization, remediation recommendations, and compliance mapping.

## Practice Labs

**Lab 1: JavaScript Endpoint Extraction** - Build a JavaScript analysis pipeline that extracts endpoints from Webpack bundles, minified scripts, dynamically loaded modules, and lazy-loaded components. Measure extraction accuracy across different obfuscation levels, bundling configurations, and application architectures.

**Lab 2: GraphQL Schema Discovery** - Develop automated GraphQL introspection and schema analysis tools. Identify excessive data exposure, authorization weaknesses, injection vulnerabilities, and schema-based attacks in GraphQL implementations.

**Lab 3: API Documentation Mining** - Build parsers for Swagger, RAML, WSDL, AsyncAPI, and custom documentation formats. Extract and consolidate endpoint information from multiple documentation sources with schema validation and format normalization.

**Lab 4: Continuous Endpoint Monitoring** - Implement endpoint change detection that identifies new endpoints, modified endpoints, deprecated endpoints, and removed endpoints over time. Configure alerting for security-relevant changes with integration to vulnerability scanning workflows.

## Ethics

Endpoint mapping must be performed within authorized boundaries respecting target application consent and scope limitations. Obtain proper authorization before performing endpoint discovery against web applications. Minimize discovery activities to necessary scope for authorized security assessments. Respect API rate limits and do not cause service disruption through excessive endpoint testing or fuzzing. Document all endpoint mapping activities for accountability and compliance verification. Report discovered security vulnerabilities through responsible disclosure channels with appropriate remediation timelines. Protect endpoint information from unauthorized disclosure and maintain confidentiality of discovered API surfaces.

## Quick Reference

| Technique | Tool | Discovery Target |
|-----------|------|-------------------|
| JavaScript Analysis | LinkFinder, SecretFinder | Embedded API endpoints |
| Web Crawling | katana, ZAP Spider | Linked endpoints |
| API Documentation | Swagger parser | Documented endpoints |
| Historical URLs | waybackurls, gau | Archived endpoints |
| Parameter Discovery | Arjun, Paramspider | Hidden parameters |
| Method Enumeration | Burp Suite, curl | HTTP methods |
| GraphQL Introspection | Custom scripts | Schema endpoints |
| Directory Brute-force | ffuf, dirsearch | Hidden paths |
| Sitemap Analysis | Custom parser | Documented endpoints |
| Traffic Analysis | Burp Proxy, mitmproxy | Runtime endpoints |
| Source Code Analysis | Custom scripts | Code-embedded endpoints |
| Mobile App Analysis | jadx, apktool | Mobile API endpoints |
| WSDL Discovery | Custom scripts | SOAP endpoints |
| WebSocket Mapping | Custom scripts | Real-time endpoints |
| gRPC Reflection | grpcurl | gRPC service endpoints |
| Subdomain Discovery | subfinder | Additional endpoints |
| Certificate Transparency | crt.sh | SSL-related endpoints |
| DNS Enumeration | dnsrecon | Infrastructure endpoints |
| Robot.txt Analysis | Custom parser | Disallowed endpoints |
| HTML Form Analysis | Beautiful Soup | Form submission endpoints |
| Comment Analysis | Custom scripts | Commented endpoints |
| Error Page Analysis | Custom scripts | Error-revealed endpoints |
| Version Endpoint Discovery | Custom scripts | Version-specific endpoints |
| Health Check Discovery | Custom scripts | Monitoring endpoints |
| Admin Interface Discovery | Custom scripts | Administrative endpoints |
| API Version Enumeration | Custom scripts | Versioned API endpoints |
| Authentication Bypass Testing | Custom scripts | Unprotected endpoints |
| CORS Analysis | Custom scripts | Cross-origin endpoints |
| Rate Limit Analysis | Custom scripts | Rate-limited endpoints |
| Schema Analysis | Custom scripts | API schema endpoints |
| Batch Endpoint Testing | Custom scripts | Bulk operation endpoints |
| Webhook Discovery | Custom scripts | Event notification endpoints |
| File Upload Discovery | Custom scripts | Upload endpoint mapping |
| Search Endpoint Discovery | Custom scripts | Search API endpoints |
| Export Endpoint Discovery | Custom scripts | Data export endpoints |
| Import Endpoint Discovery | Custom scripts | Data import endpoints |
| Configuration Endpoint | Custom scripts | System config endpoints |
| Logging Endpoint Discovery | Custom scripts | Log aggregation endpoints |
| Cache Endpoint Discovery | Custom scripts | Cache management endpoints |
| Queue Endpoint Discovery | Custom scripts | Message queue endpoints |
| Database Endpoint Discovery | Custom scripts | Database management endpoints |
| Authentication Endpoint | Custom scripts | Auth flow endpoints |
| Authorization Endpoint | Custom scripts | Permission management endpoints |
| User Management Endpoint | Custom scripts | User admin endpoints |
| Session Endpoint Discovery | Custom scripts | Session management endpoints |
| Notification Endpoint | Custom scripts | Alert/notification endpoints |
| Integration Endpoint Discovery | Custom scripts | Third-party integration endpoints |
| Analytics Endpoint Discovery | Custom scripts | Analytics/tracking endpoints |
| CDN Endpoint Discovery | Custom scripts | CDN management endpoints |
| DNS Endpoint Discovery | Custom scripts | DNS management endpoints |

---

## Deep Dive: Endpoint Discovery Techniques

### Active Endpoint Discovery
```bash
# Directory brute-forcing
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt

# Subdomain brute-forcing
gobuster dns -d target.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# Virtual host discovery
gobuster vhost -u https://target.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# API endpoint discovery
ffuf -u https://target.com/api/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/api/api-endpoints.txt

# Parameter discovery
ffuf -u https://target.com/page -w /usr/share/wordlists/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc 200

# File discovery
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403
```

### Passive Endpoint Discovery
```bash
# JavaScript analysis
linkfinder -i https://target.com -o cli

# SecretFinder
python3 SecretFinder.py -i https://target.com/app.js -o cli

# Waybackurls
echo target.com | waybackurls

# GAU (GetAllUrls)
echo target.com | gau

# CommonCrawl
curl "https://index.commoncrawl.org/CC-MAIN-2023-01-index?url=target.com/*&output=json"

# URLScan
curl "https://urlscan.io/api/v1/search/?q=domain:target.com"

# SecurityTrails
curl "https://api.securitytrails.com/v1/domain/target.com/subdomains" -H "apikey: YOUR_KEY"
```

### API Endpoint Discovery
```python
#!/usr/bin/env python3
"""API endpoint discovery and mapping"""

import requests
import re
import json
from typing import Dict, List, Set
from urllib.parse import urljoin, urlparse

class APIDiscovery:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.endpoints = set()
        self.methods = {}

    def discover_from_javascript(self) -> Set[str]:
        """Discover endpoints from JavaScript files"""
        js_endpoints = set()

        try:
            response = self.session.get(self.base_url, timeout=5)
            js_files = re.findall(r'src=["\']([^"\']+\.js)["\']', response.text)

            for js_file in js_files:
                js_url = urljoin(self.base_url, js_file)
                try:
                    js_response = self.session.get(js_url, timeout=5)
                    # Find API endpoints
                    api_patterns = [
                        r'["\'](/[a-zA-Z0-9/_-]+)["\']',
                        r'fetch\(["\']([^"\']+)["\']',
                        r'axios\.[a-z]+\(["\']([^"\']+)["\']',
                        r'url:\s*["\']([^"\']+)["\']',
                    ]

                    for pattern in api_patterns:
                        matches = re.findall(pattern, js_response.text)
                        for match in matches:
                            if match.startswith('/api') or '/v1/' in match or '/v2/' in match:
                                js_endpoints.add(match)

                except Exception:
                    continue

        except Exception:
            pass

        self.endpoints.update(js_endpoints)
        return js_endpoints

    def discover_from_html(self) -> Set[str]:
        """Discover endpoints from HTML"""
        html_endpoints = set()

        try:
            response = self.session.get(self.base_url, timeout=5)
            # Find form actions
            form_actions = re.findall(r'action=["\']([^"\']+)["\']', response.text)
            html_endpoints.update(form_actions)

            # Find links
            links = re.findall(r'href=["\']([^"\']+)["\']', response.text)
            html_endpoints.update(links)

            # Find AJAX calls
            ajax_patterns = [
                r'\$\.ajax\({[^}]*url:\s*["\']([^"\']+)["\']',
                r'fetch\(["\']([^"\']+)["\']',
                r'XMLHttpRequest[^"]*["\']([^"\']+)["\']',
            ]

            for pattern in ajax_patterns:
                matches = re.findall(pattern, response.text)
                html_endpoints.update(matches)

        except Exception:
            pass

        self.endpoints.update(html_endpoints)
        return html_endpoints

    def discover_from_swagger(self) -> Set[str]:
        """Discover endpoints from Swagger/OpenAPI"""
        swagger_endpoints = set()
        swagger_paths = [
            '/swagger.json',
            '/swagger/v1/swagger.json',
            '/api-docs',
            '/openapi.json',
            '/openapi.yaml',
            '/swagger-ui.html',
            '/swagger-resources',
        ]

        for path in swagger_paths:
            try:
                response = self.session.get(
                    urljoin(self.base_url, path),
                    timeout=5
                )
                if response.status_code == 200:
                    data = response.json()
                    if 'paths' in data:
                        for path, methods in data['paths'].items():
                            swagger_endpoints.add(path)
                            self.methods[path] = list(methods.keys())
            except Exception:
                continue

        self.endpoints.update(swagger_endpoints)
        return swagger_endpoints

    def discover_from_robots(self) -> Set[str]:
        """Discover endpoints from robots.txt"""
        robots_endpoints = set()

        try:
            response = self.session.get(
                urljoin(self.base_url, '/robots.txt'),
                timeout=5
            )
            if response.status_code == 200:
                lines = response.text.split('\n')
                for line in lines:
                    if line.startswith('Disallow:') or line.startswith('Allow:'):
                        path = line.split(':')[1].strip()
                        if path and path != '/':
                            robots_endpoints.add(path)
        except Exception:
            pass

        self.endpoints.update(robots_endpoints)
        return robots_endpoints

    def discover_from_sitemap(self) -> Set[str]:
        """Discover endpoints from sitemap.xml"""
        sitemap_endpoints = set()

        try:
            response = self.session.get(
                urljoin(self.base_url, '/sitemap.xml'),
                timeout=5
            )
            if response.status_code == 200:
                urls = re.findall(r'<loc>([^<]+)</loc>', response.text)
                for url in urls:
                    parsed = urlparse(url)
                    sitemap_endpoints.add(parsed.path)
        except Exception:
            pass

        self.endpoints.update(sitemap_endpoints)
        return sitemap_endpoints

    def test_endpoints(self) -> Dict[str, int]:
        """Test discovered endpoints"""
        results = {}

        for endpoint in self.endpoints:
            try:
                url = urljoin(self.base_url, endpoint)
                response = self.session.get(url, timeout=5, allow_redirects=False)
                results[endpoint] = response.status_code
            except Exception:
                results[endpoint] = 0

        return results

    def generate_map(self) -> Dict:
        """Generate endpoint map"""
        return {
            'base_url': self.base_url,
            'total_endpoints': len(self.endpoints),
            'endpoints': list(self.endpoints),
            'methods': self.methods,
        }

# Usage
discovery = APIDiscovery("https://target.com")
discovery.discover_from_javascript()
discovery.discover_from_html()
discovery.discover_from_swagger()
discovery.discover_from_robots()
discovery.discover_from_sitemap()

results = discovery.test_endpoints()
print(f"Discovered {len(discovery.endpoints)} endpoints")
for endpoint, status in results.items():
    print(f"  {endpoint}: {status}")
```

---

## Advanced Endpoint Analysis

### Parameter Discovery
```python
#!/usr/bin/env python3
"""Parameter discovery and analysis"""

import requests
import re
from typing import Dict, List, Set

class ParameterDiscovery:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.parameters = {}

    def discover_from_javascript(self) -> Dict[str, List[str]]:
        """Discover parameters from JavaScript"""
        params = {}

        try:
            response = self.session.get(self.base_url, timeout=5)
            js_files = re.findall(r'src=["\']([^"\']+\.js)["\']', response.text)

            for js_file in js_files:
                js_url = f"{self.base_url}/{js_file}"
                try:
                    js_response = self.session.get(js_url, timeout=5)
                    # Find parameter patterns
                    param_patterns = [
                        r'["\'](\w+)["\']:\s*["\']?\$\w+',
                        r'params\s*=\s*\{([^}]+)\}',
                        r'data\s*=\s*\{([^}]+)\}',
                        r'query\s*=\s*\{([^}]+)\}',
                    ]

                    for pattern in param_patterns:
                        matches = re.findall(pattern, js_response.text)
                        for match in matches:
                            if isinstance(match, str):
                                param_names = re.findall(r'["\'](\w+)["\']', match)
                                params[js_file] = param_names

                except Exception:
                    continue

        except Exception:
            pass

        self.parameters = params
        return params

    def discover_from_forms(self) -> Dict[str, List[str]]:
        """Discover parameters from HTML forms"""
        params = {}

        try:
            response = self.session.get(self.base_url, timeout=5)
            forms = re.findall(r'<form[^>]*>(.*?)</form>', response.text, re.DOTALL)

            for i, form in enumerate(forms):
                inputs = re.findall(r'<input[^>]*name=["\']([^"\']+)["\']', form)
                params[f'form_{i}'] = inputs

        except Exception:
            pass

        self.parameters.update(params)
        return params

    def discover_from_headers(self) -> Dict[str, List[str]]:
        """Discover parameters from HTTP headers"""
        params = {}

        try:
            response = self.session.get(self.base_url, timeout=5)
            # Check for custom headers that might indicate parameters
            for header, value in response.headers.items():
                if 'param' in header.lower() or 'query' in header.lower():
                    params[header] = [value]
        except Exception:
            pass

        self.parameters.update(params)
        return params

    def test_parameters(self) -> Dict[str, Dict]:
        """Test discovered parameters"""
        results = {}

        for source, param_list in self.parameters.items():
            for param in param_list:
                try:
                    # Test with common values
                    test_values = ['test', '1', 'true', 'admin']
                    for value in test_values:
                        url = f"{self.base_url}?{param}={value}"
                        response = self.session.get(url, timeout=5)
                        if response.status_code == 200:
                            results[param] = {
                                'source': source,
                                'status': response.status_code,
                                'length': len(response.text),
                            }
                            break
                except Exception:
                    continue

        return results

# Usage
discovery = ParameterDiscovery("https://target.com")
js_params = discovery.discover_from_javascript()
form_params = discovery.discover_from_forms()
print("JavaScript Parameters:", js_params)
print("Form Parameters:", form_params)
```

### Authentication Endpoint Discovery
```python
#!/usr/bin/env python3
"""Authentication endpoint discovery"""

import requests
import re
from typing import Dict, List

class AuthEndpointDiscovery:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.auth_endpoints = []

    def discover_login_endpoints(self) -> List[str]:
        """Discover login endpoints"""
        login_paths = [
            '/login',
            '/signin',
            '/auth',
            '/authentication',
            '/account/login',
            '/user/login',
            '/admin/login',
            '/wp-login.php',
            '/wp-admin/',
        ]

        found = []
        for path in login_paths:
            try:
                response = self.session.get(
                    f"{self.base_url}{path}",
                    timeout=5,
                    allow_redirects=False
                )
                if response.status_code in [200, 301, 302]:
                    found.append(path)
            except Exception:
                continue

        self.auth_endpoints.extend(found)
        return found

    def discover_registration_endpoints(self) -> List[str]:
        """Discover registration endpoints"""
        register_paths = [
            '/register',
            '/signup',
            '/create-account',
            '/new-user',
            '/account/create',
            '/user/register',
        ]

        found = []
        for path in register_paths:
            try:
                response = self.session.get(
                    f"{self.base_url}{path}",
                    timeout=5,
                    allow_redirects=False
                )
                if response.status_code in [200, 301, 302]:
                    found.append(path)
            except Exception:
                continue

        self.auth_endpoints.extend(found)
        return found

    def discover_password_reset(self) -> List[str]:
        """Discover password reset endpoints"""
        reset_paths = [
            '/password/reset',
            '/forgot-password',
            '/reset-password',
            '/account/password/reset',
            '/user/password/reset',
        ]

        found = []
        for path in reset_paths:
            try:
                response = self.session.get(
                    f"{self.base_url}{path}",
                    timeout=5,
                    allow_redirects=False
                )
                if response.status_code in [200, 301, 302]:
                    found.append(path)
            except Exception:
                continue

        self.auth_endpoints.extend(found)
        return found

    def discover_oauth_endpoints(self) -> List[str]:
        """Discover OAuth endpoints"""
        oauth_paths = [
            '/oauth/authorize',
            '/oauth/token',
            '/oauth/callback',
            '/auth/google',
            '/auth/facebook',
            '/auth/github',
            '/login/google',
            '/login/facebook',
            '/login/github',
        ]

        found = []
        for path in oauth_paths:
            try:
                response = self.session.get(
                    f"{self.base_url}{path}",
                    timeout=5,
                    allow_redirects=False
                )
                if response.status_code in [200, 301, 302, 400]:
                    found.append(path)
            except Exception:
                continue

        self.auth_endpoints.extend(found)
        return found

    def analyze_auth_flow(self) -> Dict:
        """Analyze authentication flow"""
        analysis = {
            'login_endpoints': self.discover_login_endpoints(),
            'registration_endpoints': self.discover_registration_endpoints(),
            'password_reset_endpoints': self.discover_password_reset(),
            'oauth_endpoints': self.discover_oauth_endpoints(),
            'total_endpoints': len(self.auth_endpoints),
        }

        return analysis

# Usage
discovery = AuthEndpointDiscovery("https://target.com")
auth_flow = discovery.analyze_auth_flow()
print("Authentication Endpoints:")
for category, endpoints in auth_flow.items():
    if endpoints:
        print(f"  {category}: {endpoints}")
```

---

## Comprehensive Endpoint Mapping Script

```python
#!/usr/bin/env python3
"""Comprehensive endpoint mapping"""

import requests
import json
import sys
from typing import Dict, List, Set
from dataclasses import dataclass

@dataclass
class Endpoint:
    path: str
    methods: List[str]
    status_code: int
    content_type: str
    authentication_required: bool
    parameters: List[str]

class EndpointMapper:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.endpoints = {}

    def map_all_endpoints(self) -> Dict[str, Endpoint]:
        """Map all endpoints"""
        print(f"[*] Mapping endpoints for: {self.base_url}")

        # Discovery phases
        self._discover_from_javascript()
        self._discover_from_html()
        self._discover_from_swagger()
        self._discover_from_robots()
        self._discover_from_sitemap()

        # Test endpoints
        self._test_endpoints()

        return self.endpoints

    def _discover_from_javascript(self):
        """Discover from JavaScript"""
        # Implementation from above
        pass

    def _discover_from_html(self):
        """Discover from HTML"""
        # Implementation from above
        pass

    def _discover_from_swagger(self):
        """Discover from Swagger"""
        # Implementation from above
        pass

    def _discover_from_robots(self):
        """Discover from robots.txt"""
        # Implementation from above
        pass

    def _discover_from_sitemap(self):
        """Discover from sitemap.xml"""
        # Implementation from above
        pass

    def _test_endpoints(self):
        """Test all discovered endpoints"""
        for path in list(self.endpoints.keys()):
            try:
                url = f"{self.base_url}{path}"
                response = self.session.get(url, timeout=5, allow_redirects=False)
                self.endpoints[path].status_code = response.status_code
                self.endpoints[path].content_type = response.headers.get('Content-Type', 'Unknown')
            except Exception:
                self.endpoints[path].status_code = 0

    def generate_report(self) -> str:
        """Generate endpoint mapping report"""
        report = "=== Endpoint Mapping Report ===\n"
        report += f"Target: {self.base_url}\n"
        report += f"Total Endpoints: {len(self.endpoints)}\n\n"

        for path, endpoint in sorted(self.endpoints.items()):
            report += f"{path}\n"
            report += f"  Methods: {', '.join(endpoint.methods)}\n"
            report += f"  Status: {endpoint.status_code}\n"
            report += f"  Content-Type: {endpoint.content_type}\n"
            report += f"  Authentication: {endpoint.authentication_required}\n"
            if endpoint.parameters:
                report += f"  Parameters: {', '.join(endpoint.parameters)}\n"
            report += "\n"

        return report

# Usage
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    mapper = EndpointMapper(sys.argv[1])
    endpoints = mapper.map_all_endpoints()
    print(mapper.generate_report())
```

---

## Reporting Templates

### Endpoint Mapping Report
```
## Endpoint Mapping Report

### Target: [url]

### Discovery Methods
1. JavaScript analysis: [count] endpoints
2. HTML analysis: [count] endpoints
3. Swagger/OpenAPI: [count] endpoints
4. robots.txt: [count] endpoints
5. sitemap.xml: [count] endpoints

### Endpoint Categories
- Authentication: [count] endpoints
- API: [count] endpoints
- Static content: [count] endpoints
- Administrative: [count] endpoints

### Authentication Required
[List endpoints requiring authentication]

### No Authentication Required
[List endpoints without authentication]

### Findings
1. [Finding 1]
2. [Finding 2]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
```

### Endpoint Risk Matrix
| Severity | Condition | Impact |
|----------|-----------|--------|
| Critical | Admin endpoints exposed | Full compromise |
| High | API without auth | Data exposure |
| Medium | Sensitive endpoints | Information leak |
| Low | Public endpoints | Normal operation |

---

## Quick Reference Cheat Sheet

### Directory Brute-forcing
```bash
gobuster dir -u https://target.com -w wordlist.txt
ffuf -u https://target.com/FUZZ -w wordlist.txt
dirb https://target.com wordlist.txt
```

### API Discovery
```bash
ffuf -u https://target.com/api/FUZZ -w api-wordlist.txt
swagger-ui https://target.com/swagger.json
```

### Parameter Discovery
```bash
arjun -u https://target.com/page
parameth -u https://target.com
```

---

## Resources and References
- Gobuster: https://github.com/OJ/gobuster
- FFUF: https://github.com/ffuf/ffuf
- Arjun: https://github.com/s0md3v/Arjun
- LinkFinder: https://github.com/GerbenJav)ado/LinkFinder
- SecretFinder: https://github.com/m4ll0k/SecretFinder
