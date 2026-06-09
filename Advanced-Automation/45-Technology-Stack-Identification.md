# Technology Stack Identification

## Expert Role

You are a senior systems architect and technology intelligence specialist with over 15 years of experience in comprehensive technology stack identification, infrastructure profiling, and architectural analysis across enterprise environments. Your expertise spans server configuration analysis, hosting environment detection, CDN identification, JavaScript library fingerprinting, CSS framework recognition, database technology detection, and full-stack technology profiling for diverse deployment architectures. You have performed technology stack assessments for enterprise organizations, cloud migrations, security evaluations, and competitive intelligence operations across industries including finance, healthcare, technology, government, and e-commerce. You understand the distinctive signatures of web servers, application frameworks, databases, message queues, caching layers, container orchestration platforms, and deployment platforms. Your toolkit includes Wappalyzer, Netcraft, Shodan, Censys, custom Python analysis frameworks, and specialized infrastructure detection tools that you have developed for operational deployment. You approach technology stack identification as both a defensive audit methodology for infrastructure documentation and an offensive reconnaissance discipline enabling targeted attack planning based on precise technology intelligence across the complete application stack.

## Core Concepts

Technology stack identification encompasses the systematic detection and analysis of all technologies comprising a web application's infrastructure, from client-side libraries and frameworks to server-side applications, databases, caching layers, message queues, hosting platforms, and supporting services. At its foundation, each technology layer leaves distinctive traces in network communications, HTTP responses, client-side code, infrastructure configurations, and behavioral patterns that enable comprehensive technology profiling.

Server header analysis examines HTTP response headers for web server identification including Apache, Nginx, IIS, LiteSpeed, Caddy, and Traefik. Server banners often reveal version information, module configurations, operating system details, and deployment patterns that inform security assessment priorities. Server header analysis provides immediate technology intelligence for initial reconnaissance phases and technology baseline establishment.

Cookie-based detection identifies framework-specific session cookies and their security configurations. ASP.NET uses ASP.NET_SessionId and .AspNetCore.Identity cookies with configurable security attributes. PHPSESSID identifies PHP-based applications with default naming patterns. Rails sessions use _rails_session cookies with signed and encrypted values. Cookie attributes including SameSite, Secure, HttpOnly, Domain, and Path settings reveal security configuration details and technology choices. Cookie analysis provides framework identification and security configuration assessment.

JavaScript library fingerprinting detects client-side frameworks and libraries through global variable detection, function signature analysis, library hash comparison, and runtime behavior analysis. jQuery, React, Angular, Vue.js, Svelte, and other libraries have distinctive JavaScript patterns that enable precise identification including version information and configuration details. JavaScript fingerprinting provides client-side technology intelligence for comprehensive stack profiling.

CSS framework detection identifies design systems including Bootstrap, Tailwind CSS, Material UI, Foundation, Bulma, and custom design systems through class naming conventions, CSS variable patterns, stylesheet structure analysis, and responsive breakpoint patterns. CSS fingerprinting reveals frontend technology choices, design system implementations, and component library usage.

CDN identification detects content delivery network usage through HTTP headers (cf-ray for Cloudflare, X-Varnish for Varnish, X-Cache for AWS CloudFront, X-Served-By for Fastly), IP address ownership analysis, DNS CNAME patterns, and ASN identification. CDN detection reveals infrastructure architecture, performance optimization strategies, and security control implementations. CDN identification provides infrastructure layer intelligence for security assessment and architecture analysis.

Hosting provider detection identifies cloud and hosting platforms through IP address ownership, ASN analysis, DNS records, HTTP headers, and platform-specific service fingerprints. AWS, Azure, GCP, DigitalOcean, Linode, and traditional hosting providers have distinctive network ranges, configuration patterns, and service signatures. Hosting detection provides infrastructure context for security assessment, compliance validation, and architecture analysis.

Comprehensive technology stack profiling combines all detection vectors into complete infrastructure maps showing relationships between technologies, versions, deployment configurations, and architectural patterns. Stack integration provides holistic infrastructure intelligence for security assessment, architecture analysis, technology migration planning, and competitive intelligence.

## Prerequisites

- Python 3.8+ with requests, beautifulsoup4, dns.resolver, socket, and ssl libraries
- Wappalyzer, WhatWeb, BuiltWith CLI tools installed and updated with current signatures
- Shodan and Censys API keys for infrastructure enumeration and service discovery
- Netcraft API access for technology profiling and hosting intelligence
- Browser automation tools (Selenium, Playwright) for client-side analysis and JavaScript rendering
- Understanding of HTTP protocol, headers, cookie specifications, and response behavior
- Knowledge of major web servers, frameworks, databases, and hosting platforms including default configurations
- Familiarity with CDN architectures, detection methods, and bypass techniques
- JavaScript and CSS analysis capabilities including deobfuscation and pattern matching
- Network analysis tools including nmap, masscan for IP and service investigation
- Understanding of cloud service provider architectures, signatures, and service endpoints
- Access to technology fingerprint databases and signature repositories for detection updates
- Knowledge of containerization technologies (Docker, Kubernetes) and orchestration platforms
- Familiarity with load balancer configurations, detection methods, and bypass techniques
- Understanding of database technologies, connection patterns, and detection signatures

## Methodology

Technology stack identification follows a structured eight-phase methodology designed to provide comprehensive infrastructure profiling across all technology layers with multi-vector validation.

**Phase 1: Server Infrastructure Detection** identifies the underlying web server and operating system through HTTP header analysis, banner grabbing, response pattern examination, and protocol-level analysis. Query Server headers, analyze error page patterns, and examine response timing characteristics to identify server technology and version. Document server configuration details including modules, plugins, custom configurations, and security settings. Analyze server response behavior for operating system inference through TCP/IP stack analysis and TTL patterns. Test server response to malformed requests for technology fingerprinting including protocol negotiation behavior and error handling patterns. Document server infrastructure including reverse proxy, load balancer, and caching configurations.

**Phase 2: Application Framework Identification** detects server-side frameworks through HTTP header analysis, URL pattern examination, error page signatures, cookie analysis, and behavioral testing. Identify framework-specific headers (X-Powered-By, X-AspNet-Version, X-Application-Context), test framework-specific URL paths, and analyze error response patterns for technology identification. Examine framework-specific cookie names, configurations, and security attributes. Test URL routing patterns for framework identification including path parameter handling, query string processing, and redirect behavior. Analyze error page formatting, content, and debug information for framework signatures. Document framework configurations including security settings, middleware implementations, and deployment patterns.

**Phase 3: Client-Side Technology Analysis** examines HTML source, JavaScript files, CSS stylesheets, and browser console output for framework and library signatures. Detect JavaScript frameworks through global variable patterns, library hash comparison, component structure analysis, and runtime behavior testing. Identify CSS frameworks through class naming patterns, CSS variable structures, responsive breakpoint patterns, and stylesheet organization. Analyze JavaScript module bundling patterns, build tool configurations, and source map availability. Examine client-side routing, state management, and application architecture implementations. Document client-side technology dependencies, version information, and security configurations.

**Phase 4: Database Layer Detection** identifies database technologies through error message patterns, URL parameters, application behavior analysis, and connection pattern testing. SQL error messages reveal database type (MySQL, PostgreSQL, SQL Server, Oracle, SQLite) through specific error formatting, error codes, and message patterns. ORM patterns indicate database abstraction layers including Sequelize, SQLAlchemy, ActiveRecord, and Entity Framework. Test database-specific query syntax for identification through parameter handling and response patterns. Analyze connection behavior, response timing, and query patterns. Document database configurations including connection pooling, security settings, encryption, and access control implementations.

**Phase 5: Caching and Performance Layer Identification** detects caching technologies through HTTP headers, response timing patterns, header analysis, and behavioral testing. Identify Varnish through X-Varnish and Age headers, Redis through response patterns and connection behavior, Memcached through configuration indicators and connection patterns, and CDN caching through cache-control headers and cache hit/miss indicators. Analyze cache control headers, caching behavior patterns, and cache invalidation mechanisms. Document caching configurations including TTL settings, cache invalidation strategies, and cache hierarchy.

**Phase 6: CDN and Edge Computing Detection** identifies content delivery networks and edge computing platforms through HTTP headers, IP address analysis, DNS configuration, and behavioral analysis. Cloudflare, AWS CloudFront, Akamai, Fastly, and other CDN providers have distinctive header patterns, IP ranges, and network signatures. Analyze CDN-specific security header implementations including WAF rules, DDoS protection, and bot management. Document CDN configurations including caching rules, security features, origin server protection, and edge computing capabilities.

**Phase 7: Hosting and Cloud Platform Detection** identifies hosting infrastructure through IP address ownership analysis, DNS records, platform-specific headers, and service endpoint detection. AWS, Azure, GCP, DigitalOcean, Linode, and traditional hosting providers have identifiable network ranges, ASN assignments, and configuration patterns. Analyze cloud service integrations, platform-specific services, and managed service indicators. Document hosting configurations including scaling strategies, security groups, network configurations, and infrastructure-as-code patterns.

**Phase 8: Comprehensive Stack Integration** combines all detected technologies into complete infrastructure profiles with relationship mapping and dependency analysis. Map technology dependencies, version relationships, architectural patterns, and deployment configurations. Generate technology intelligence reports with security assessment recommendations, migration planning guidance, and competitive intelligence insights. Create technology stack visualizations for stakeholder communication including architecture diagrams and dependency maps. Document technology relationships, dependency chains, and security implications for comprehensive infrastructure understanding.

## Tool Arsenal

**Wappalyzer** provides comprehensive technology identification across 1000+ technology categories including frameworks, CMS platforms, JavaScript libraries, web servers, hosting providers, analytics tools, marketing platforms, and enterprise applications. Its signature database covers mainstream and niche technologies with version detection capabilities and confidence scoring. Wappalyzer provides real-time technology detection with high accuracy, broad coverage, and API access for automated scanning.

**WhatWeb** identifies web technologies through 1800+ plugins analyzing HTTP headers, HTML structure, JavaScript patterns, CSS signatures, and default page responses. Its aggressive mode enables deeper technology detection through linked resource analysis, default page identification, and technology-specific probing. WhatWeb provides detailed technology fingerprinting with customizable detection plugins, multiple output formats, and integration capabilities.

**BuiltWith** offers comprehensive technology profiling including framework detection, analytics tracking, advertising technologies, hosting infrastructure, technology trends, and market analysis. Its historical tracking enables technology change analysis over time and technology adoption pattern identification. BuiltWith provides enterprise technology intelligence with historical tracking capabilities, market analysis, and competitive intelligence features.

**Netcraft** provides web server and hosting infrastructure intelligence including server technology, hosting history, SSL certificate information, and technology adoption trends. Its survey data offers industry-wide technology adoption insights and market share analysis. Netcraft provides comprehensive infrastructure intelligence, technology trend analysis, and hosting provider comparison.

**Shodan** internet-connected device search engine identifies server technologies, hosting platforms, infrastructure components, and service configurations through banner analysis, port scanning, and service fingerprinting. Its API enables programmatic infrastructure enumeration with advanced search queries and filtering. Shodan provides internet-wide infrastructure intelligence, technology detection, and service discovery capabilities.

**Censys** internet-wide scanning platform provides detailed technology profiling including web server identification, certificate analysis, infrastructure fingerprinting, and service discovery across millions of hosts. Its search capabilities enable complex technology queries and infrastructure analysis. Censys provides comprehensive internet-wide technology intelligence with structured data access.

**Custom Python Stack Profiler** combines HTTP header analysis, HTML parsing, JavaScript detection, CSS pattern matching, DNS investigation, and behavioral analysis into comprehensive technology identification pipelines with configurable detection rules and confidence scoring.

**curl** enables detailed HTTP header analysis and response inspection for technology detection with verbose protocol information including TLS negotiation, HTTP/2 implementation, header ordering, and connection behavior. curl provides granular HTTP protocol analysis for technology detection and infrastructure investigation.

**Browser Developer Tools** provide client-side technology detection through JavaScript console inspection, network analysis, DOM examination, and performance profiling. Use console commands to detect library versions, framework globals, component structures, and runtime behavior. Browser tools provide real-time client-side technology analysis with interactive debugging capabilities.

**Nmap** HTTP technology detection scripts (http-enum, http-generator, http-server-header, http-title, http-methods) identify server technologies through signature matching, default page analysis, and behavioral testing. Nmap provides network-level technology detection with service fingerprinting capabilities and integration with comprehensive network scanning workflows.

**SecurityHeaders.com** API analyzes HTTP security header configurations revealing technology-specific security implementations, hardening levels, and compliance status. SecurityHeaders.com provides security header compliance analysis with industry benchmarking and remediation guidance.

**SSL/TLS Analysis tools** (testssl.sh, SSLyze) identify TLS configuration details that reveal technology choices including cipher suite preferences, protocol implementations, certificate configurations, and security feature support. SSL/TLS analysis provides technology intelligence through cryptographic configuration patterns.

## Case Studies

**Case Study 1: Enterprise Stack Assessment** - Comprehensive technology stack identification for a financial services platform revealed a complex multi-tier architecture including Nginx reverse proxy with custom modules, Apache Tomcat application server, Oracle Database with RAC clustering, Redis caching layer with sentinel configuration, and AWS CloudFront CDN with custom security policies. Version analysis identified Apache Tomcat 8.5.61 with known CVEs requiring immediate patching, Oracle Database 12c with deprecated support creating compliance risks, and Redis 6.0 with authentication bypass vulnerabilities requiring urgent remediation. Technology intelligence enabled prioritized remediation, architecture modernization planning, and compliance gap analysis. Additional analysis identified 12 custom middleware components with security vulnerabilities and 8 legacy integrations using deprecated protocols.

**Case Study 2: Cloud Migration Technology Mapping** - Technology stack profiling during a cloud migration assessment identified 847 web applications across 12 business units with diverse technology stacks requiring migration planning. Analysis revealed 23% running end-of-life PHP versions creating security and compliance risks, 34% using deprecated JavaScript libraries with known vulnerabilities, and 18% running unsupported CMS versions requiring immediate upgrade. Comprehensive technology inventory enabled migration prioritization, compatibility assessment, and resource allocation planning. The assessment also identified 67 applications with outdated SSL configurations and 34 applications with missing security headers.

**Case Study 3: E-Commerce Platform Analysis** - Technology detection for a major e-commerce platform identified a headless architecture with React frontend, Node.js API layer, PostgreSQL database, Elasticsearch search engine, and Kubernetes orchestration with custom operators. Version analysis revealed Elasticsearch 7.10 with known vulnerabilities and multiple outdated npm packages with security advisories. The analysis also identified 15 microservices with outdated Docker images and 23 Kubernetes pods with excessive privileges creating security risks.

**Case Study 4: CDN and Edge Computing Detection** - Infrastructure analysis identified a complex CDN architecture with Cloudflare for DDoS protection and WAF, AWS CloudFront for static content delivery, and Fastly for API acceleration and edge computing. Technology intelligence revealed CDN misconfigurations including origin server exposure through DNS leaks, cache poisoning vulnerabilities through header manipulation, and inconsistent security header implementation across CDN layers. The analysis also identified 8 origin servers with direct IP exposure bypassing CDN protection and security controls.

**Case Study 5: Legacy Technology Discovery** - Deep technology analysis for a healthcare organization discovered shadow IT infrastructure including 23 unauthorized WordPress installations with outdated plugins, 7 PHP applications running on outdated servers with deprecated extensions, and 4 Java applications with deprecated frameworks creating security and compliance risks. Technology intelligence enabled security governance improvements, infrastructure consolidation planning, and regulatory compliance remediation. The investigation also identified 12 internal tools with public internet exposure and 34 applications with missing security patches.

## Bypass Techniques

**Server Header Obfuscation Bypass** identifies web servers that have removed or modified standard technology indicators through behavioral analysis and alternative detection methods. Use response timing analysis, error page patterns, protocol behavior testing, and HTTP/2 implementation details to identify servers despite header obfuscation. TLS fingerprinting reveals server technology through cipher suite selection, protocol negotiation, and certificate characteristics without header analysis. Implement behavioral analysis for technology identification through response patterns, interaction behaviors, and protocol-level characteristics.

**CDN Origin Discovery** identifies origin servers behind CDN layers through direct IP access, DNS investigation, historical records, and behavioral analysis. Subdomain enumeration often reveals origin server hostnames bypassing CDN protection through DNS records and SSL certificate analysis. Historical DNS records may expose pre-CDN infrastructure and original server configurations. Implement CDN bypass techniques including cache poisoning, origin server probing, and DNS manipulation for comprehensive origin discovery.

**Client-Side Technology Obfuscation** detects JavaScript frameworks that have been obfuscated, minified, or bundled with technology-removing plugins through advanced analysis techniques. Use library hash comparison against known version databases, function signature analysis through AST parsing, and runtime behavior monitoring to identify technologies despite obfuscation attempts. Implement JavaScript deobfuscation techniques including AST analysis, control flow reconstruction, and string decryption for technology identification.

**Proxy and Load Balancer Fingerprinting** identifies intermediate infrastructure layers through header analysis, timing patterns, protocol behavior, and connection pattern analysis. HAProxy, Nginx, AWS ALB, GCP Load Balancer, and Azure Application Gateway leave distinctive fingerprints in request handling, response patterns, and connection behavior. Implement load balancer detection through behavioral analysis, response pattern testing, and network-level fingerprinting.

**Container and Orchestration Detection** identifies Docker, Kubernetes, and container orchestration platforms through service discovery endpoints, health check patterns, container-specific headers, and orchestration API endpoints. Kubernetes dashboard endpoints, Docker socket exposure, and container registry access reveal container infrastructure and configuration details. Implement container technology detection through endpoint probing, behavioral analysis, and API discovery.

**Database Technology Detection** bypasses error message suppression through SQL syntax testing, ORM pattern analysis, connection behavior fingerprinting, and response pattern analysis. Different database systems respond differently to specific SQL syntax variations, connection parameters, and query patterns. Implement database technology identification through behavioral analysis, query pattern testing, and response characteristic analysis.

## Advanced Techniques

**Machine Learning Stack Classification** applies supervised learning models to technology detection data for improved accuracy, automated classification, and scalable analysis. Train classifiers on labeled technology datasets including HTTP headers, HTML structure, JavaScript patterns, CSS signatures, and behavioral patterns. Feature engineering extracts distinctive patterns that enable reliable technology classification across different deployment configurations. Implement ensemble methods combining multiple classification approaches for improved accuracy and reduced false positive rates.

**Technology Relationship Mapping** constructs dependency graphs connecting detected technologies including version dependencies, compatibility requirements, security advisory associations, and upgrade paths. Graph analysis reveals technology stack consistency, upgrade path requirements, vulnerability impact chains, and architectural patterns. Implement graph visualization for stakeholder communication, technology relationship analysis, and security impact assessment.

**Passive Technology Identification** identifies technologies through network-level traffic analysis without directly probing web servers for stealth technology detection. TLS certificate analysis, HTTP/2 implementation patterns, TCP behavior inference, and network timing analysis reveal technology choices from network characteristics. Implement passive network analysis for stealth technology detection using network taps, traffic capture, and protocol analysis.

**Real-Time Technology Monitoring** implements continuous technology tracking that detects infrastructure changes including version updates, technology additions, technology removals, and configuration modifications. Change detection alerts enable proactive security assessment of technology modifications and compliance monitoring. Implement technology change notification systems for security operations teams with configurable alerting thresholds and escalation procedures.

**Technology Fingerprint Database Management** maintains comprehensive databases of technology signatures, version indicators, detection patterns, and behavioral indicators. Implement automated signature updates, accuracy validation, coverage analysis, and community contribution for fingerprint databases. Use machine learning for automated signature generation, validation, and accuracy improvement across technology categories and deployment environments.

**Infrastructure-as-Code Detection** identifies infrastructure configuration through Terraform state files, CloudFormation templates, Kubernetes manifests, Docker Compose files, and CI/CD pipeline configurations exposed through misconfigured access controls or public repositories. Infrastructure configuration reveals technology choices, security configurations, and deployment patterns. Implement infrastructure configuration analysis for technology intelligence and security assessment.

## Detection Indicators

Technology stack identification activities generate detectable indicators across web server monitoring, network infrastructure, and application security systems. Web server logs capture technology probing requests including systematic URL testing, header analysis, version detection attempts, and technology-specific path access patterns. Network monitoring tools identify technology enumeration traffic through request patterns, user-agent analysis, access frequency anomalies, and technology-specific probing behaviors.

Security Information and Event Management (SIEM) systems correlate technology detection activities with other reconnaissance indicators including port scanning, subdomain enumeration, and service discovery to identify coordinated reconnaissance campaigns. Application monitoring systems detect technology probing through error response analysis, unusual request patterns, automated access detection, and technology-specific path access.

CDN and hosting platform analytics identify technology detection activities through cache bypass requests, origin server probing, technology-specific path access patterns, and unusual traffic patterns indicating systematic enumeration.

## Impact Assessment

Successful technology stack identification provides attackers with precise infrastructure intelligence enabling targeted vulnerability research, exploit selection, and attack planning with high efficiency. Version-specific vulnerability data enables immediate identification of known security issues, available exploits, and attack vectors across the entire technology stack. From a defensive perspective, technology stack identification audits document infrastructure assets, identify technology exposure, assess version-specific vulnerabilities, and enable architecture security improvements.

Quantified risk assessment considers the number of detected technologies, version-specific vulnerability exposure, end-of-life technology usage, technology stack complexity, and attack surface implications. Critical findings include outdated frameworks with known CVEs requiring immediate remediation, deprecated technology usage creating security and compliance risks, and technology stack inconsistencies creating security gaps and architectural vulnerabilities.

## Common Pitfalls

Incomplete technology coverage results from relying on single detection methods as each detection technique has inherent limitations and technology-specific blind spots. Comprehensive technology identification requires multiple complementary approaches across all stack layers including server, application, client, database, caching, and infrastructure layers. Version detection accuracy varies significantly across technologies as production deployments often suppress version indicators for security hardening. Multiple version detection approaches and cross-validation improve identification reliability.

Technology stack complexity can overwhelm analysis capabilities when detecting multiple interacting technologies across distributed architectures. Prioritize detection based on attack surface impact, security relevance, and business criticality. False positive results occur when detection patterns match multiple technologies or when custom implementations deviate significantly from default configurations. Cross-validation across multiple detection vectors and behavioral analysis reduces false positive rates.

## Integration Points

Technology stack identification integrates with vulnerability scanning workflows to provide technology context for targeted vulnerability validation and prioritization. Feed detected technology information into vulnerability scanners to focus scanning on relevant vulnerability checks and CVE data. Connect technology detection with asset management systems to maintain accurate infrastructure inventories, technology dependency maps, and lifecycle tracking. Integrate with patch management platforms for version-specific vulnerability tracking, patch prioritization, and remediation scheduling.

Technology stack information feeds into security assessment planning by identifying technology-specific attack vectors, testing methodologies, and security controls. Connect with compliance frameworks for technology-specific regulatory compliance assessment and audit evidence collection. Integrate technology detection with cloud security posture management for cloud infrastructure technology assessment and compliance monitoring. Feed technology stack data into risk assessment models for quantified security analysis and risk prioritization.

## Reporting Templates

**Technology Stack Assessment Report** documents all detected technologies organized by stack layer with version information, security implications, dependency mapping, and architecture visualization. Include technology dependency maps, version vulnerability analysis, and prioritized remediation recommendations with business impact assessment.

**Technology Exposure Dashboard** presents detected technologies with risk classification, version status, security advisory tracking, and compliance status. Designed for operational teams with filtering capabilities, change tracking, and integration with vulnerability management systems.

**Technology Migration Planning Report** details current technology stack with end-of-life analysis, compatibility assessment, upgrade path recommendations, and migration timeline planning. Format for technical leadership with architecture diagrams, resource requirements, and risk assessment.

## Practice Labs

**Lab 1: Full-Stack Technology Identification** - Build a comprehensive technology identification pipeline that detects technologies across all stack layers including server, framework, database, CDN, caching, and hosting. Test against diverse target applications with different technology stacks.

**Lab 2: Version Detection Challenge** - Implement version detection techniques for 20+ different technologies including those with obfuscated version indicators, custom builds, and modified configurations. Measure accuracy across detection methods and technology categories.

**Lab 3: CDN Origin Discovery** - Practice CDN bypass techniques to identify origin servers behind Cloudflare, AWS CloudFront, Fastly, and Akamai. Develop automated origin discovery tools using DNS analysis, subdomain enumeration, and historical records.

**Lab 4: Technology Stack Monitoring** - Build continuous technology monitoring that detects infrastructure changes over time including version updates, technology additions, and configuration modifications. Implement alerting for technology updates and security-relevant changes.

## Ethics

Technology stack identification must be performed within authorized boundaries respecting target organization consent and applicable laws. Obtain proper authorization before performing technology profiling against web applications. Minimize detection activities to necessary scope for authorized security assessments. Respect technology obfuscation efforts as legitimate security hardening measures. Report technology vulnerabilities through responsible disclosure channels with appropriate remediation timelines. Protect detected technology information from unauthorized disclosure. Document all technology identification activities for accountability, compliance verification, and audit trail requirements.

## Quick Reference

| Layer | Detection Method | Key Indicators |
|-------|-----------------|----------------|
| Web Server | Header analysis | Server, X-Powered-By |
| Application Framework | Headers, URL patterns | X-AspNet-Version, generator |
| JavaScript Libraries | JS analysis | Global variables, function patterns |
| CSS Frameworks | CSS class analysis | Class naming patterns |
| Database | Error analysis | SQL error messages, ORM patterns |
| Caching Layer | Header analysis | X-Varnish, cache headers |
| CDN | Headers, DNS | cf-ray, CNAME records |
| Hosting Platform | IP analysis | ASN, IP ranges |
| Operating System | Banner analysis | Server headers, TTL patterns |
| SSL/TLS | Certificate analysis | Issuer, SAN, protocols |
| DNS Infrastructure | DNS records | NS, SOA, MX records |
| Load Balancer | Header analysis | X-Forwarded-For, timing |
| Container Platform | Endpoint detection | Docker, Kubernetes signatures |
| Message Queue | Protocol analysis | RabbitMQ, Kafka patterns |
| Search Engine | API patterns | Elasticsearch, Solr endpoints |
| Analytics | JS patterns | Google Analytics, Mixpanel |
| Advertising | JS patterns | Ad scripts, tracking pixels |
| Security WAF | Header analysis | WAF-specific headers |
| Email Service | MX records | SendGrid, Mailgun patterns |
| CMS Platform | Meta tags, paths | WordPress, Drupal signatures |
| E-Commerce | Path patterns | Shopify, Magento signatures |
| Forum Software | Path patterns | phpBB, vBulletin signatures |
| Wiki Software | Path patterns | MediaWiki, Confluence |
| CRM Platform | Path patterns | Salesforce, HubSpot |
| CI/CD Platform | Path patterns | Jenkins, GitLab CI |
| Monitoring | Headers, paths | Prometheus, Grafana patterns |
| Orchestration | Endpoints | Kubernetes, Docker Swarm |
| API Gateway | Headers | Kong, AWS API Gateway |
| Service Mesh | Headers | Istio, Linkerd patterns |
| Feature Flags | JS patterns | LaunchDarkly, Split.io |
| A/B Testing | JS patterns | Optimizely, VWO patterns |
| Error Tracking | JS patterns | Sentry, Bugsnag patterns |
| Logging | Headers, paths | ELK, Loki patterns |
| Task Queue | Patterns | Celery, Sidekiq patterns |
| WebSocket | Protocol patterns | Socket.io, ws patterns |
| GraphQL | Endpoint patterns | Apollo, graphql-yoga |
| gRPC | Protocol patterns | grpc-web, protobuf |
| Serverless | Headers, paths | Lambda, Cloudflare Workers |
| Edge Computing | Headers | Edge runtime signatures |
| CMS Headless | API patterns | Strapi, Contentful |
| Static Site | File patterns | Gatsby, Hugo, Jekyll |
| Jamstack | Patterns | Netlify, Vercel signatures |
| Low-Code | Path patterns | Bubble, Webflow |
| No-Code | Path patterns | Retool, Appsmith |
| DatabaseaaS | Headers | Supabase, PlanetScale |
| CacheaaS | Headers | Upstash, Redis Cloud |
| Storage | Headers | S3, Cloudflare R2 |

---

## Deep Dive: Technology Stack Fingerprinting

### Server Technology Detection
```bash
# Server header analysis
curl -I https://target.com | grep -i "server"

# X-Powered-By analysis
curl -I https://target.com | grep -i "x-powered-by"

# X-AspNet-Version
curl -I https://target.com | grep -i "x-aspnet-version"

# X-Generator header
curl -I https://target.com | grep -i "x-generator"

# Custom headers
curl -I https://target.com | grep -i "x-request-id\|x-runtime\|x-upstream"

# Complete header dump
curl -s -I https://target.com -D - -o /dev/null
```

### Programming Language Detection
```python
#!/usr/bin/env python3
"""Programming language detection"""

import requests
import re
from typing import Dict

class LanguageDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def detect_language(self) -> Dict[str, bool]:
        """Detect programming language"""
        patterns = {
            'php': [
                r'X-Powered-By: PHP',
                r'\.php',
                r'PHPSESSID',
                r'phpinfo',
            ],
            'python': [
                r'X-Powered-By: Python',
                r'django',
                r'flask',
                r'wsgiserver',
                r'__pycache__',
            ],
            'ruby': [
                r'X-Powered-By: Phusion Passenger',
                r'rails',
                r'_session_id',
                r'ruby',
            ],
            'java': [
                r'X-Powered-By: Servlet',
                r'JSESSIONID',
                r'X-AspNet-Version',
                r'java',
            ],
            'node': [
                r'X-Powered-By: Express',
                r'connect\.sid',
                r'__next',
                r'node',
            ],
            'dotnet': [
                r'X-Powered-By: ASP\.NET',
                r'ASP\.NET_SessionId',
                r'__VIEWSTATE',
                r'dotnet',
            ],
        }

        results = {}
        for language, regex_patterns in patterns.items():
            for pattern in regex_patterns:
                try:
                    response = self.session.get(self.base_url, timeout=5)
                    if re.search(pattern, str(response.headers) + response.text, re.IGNORECASE):
                        results[language] = True
                        break
                except Exception:
                    continue
            if language not in results:
                results[language] = False

        return results

# Usage
detector = LanguageDetector("https://target.com")
languages = detector.detect_language()
print("Detected Languages:", languages)
```

### Database Detection
```python
#!/usr/bin/env python3
"""Database technology detection"""

import requests
import re
from typing import Dict

class DatabaseDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def detect_database(self) -> Dict[str, bool]:
        """Detect database technology"""
        patterns = {
            'mysql': [
                r'mysql',
                r'MySQL',
                r'mysql_',
                r'mysqli',
            ],
            'postgresql': [
                r'postgresql',
                r'postgres',
                r'pg_',
                r'psql',
            ],
            'mongodb': [
                r'mongodb',
                r'mongo',
                r'MongoClient',
            ],
            'redis': [
                r'redis',
                r'Redis',
                r'REDIS_',
            ],
            'sqlite': [
                r'sqlite',
                r'SQLite',
                r'\.db',
            ],
            'oracle': [
                r'oracle',
                r'Oracle',
                r'OCI_',
            ],
            'mssql': [
                r'mssql',
                r'SQL Server',
                r'SQLServer',
            ],
        }

        results = {}
        for database, regex_patterns in patterns.items():
            for pattern in regex_patterns:
                try:
                    response = self.session.get(self.base_url, timeout=5)
                    if re.search(pattern, response.text, re.IGNORECASE):
                        results[database] = True
                        break
                except Exception:
                    continue
            if database not in results:
                results[database] = False

        return results

# Usage
detector = DatabaseDetector("https://target.com")
databases = detector.detect_database()
print("Detected Databases:", databases)
```

### CMS Detection
```python
#!/usr/bin/env python3
"""CMS detection and version fingerprinting"""

import requests
import re
from typing import Dict, Optional

class CMSDetector:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def detect_cms(self) -> Dict[str, Optional[str]]:
        """Detect CMS and version"""
        cms_patterns = {
            'wordpress': {
                'urls': ['/wp-admin/', '/wp-login.php', '/wp-content/'],
                'version_patterns': [
                    r'content="WordPress (\d+\.\d+)"',
                    r'wp-includes/version\.js\?ver=(\d+\.\d+)',
                ],
                'meta_pattern': r'generator.*WordPress',
            },
            'drupal': {
                'urls': ['/user/login', '/admin/content', '/node/'],
                'version_patterns': [
                    r'content="Drupal (\d+)"',
                    r'Drupal\.settings',
                ],
                'meta_pattern': r'generator.*Drupal',
            },
            'joomla': {
                'urls': ['/administrator/', '/components/'],
                'version_patterns': [
                    r'content="Joomla! (\d+)"',
                    r'Joomla!',
                ],
                'meta_pattern': r'generator.*Joomla',
            },
            'shopify': {
                'urls': ['/admin', '/cart'],
                'version_patterns': [
                    r'Shopify\.theme',
                    r'cdn\.shopify\.com',
                ],
                'meta_pattern': r'Shopify',
            },
            'magento': {
                'urls': ['/admin', '/magento'],
                'version_patterns': [
                    r'Magento',
                    r'magento',
                ],
                'meta_pattern': r'Magento',
            },
        }

        results = {}
        for cms, config in cms_patterns.items():
            version = self._detect_version(cms, config)
            if version or self._check_urls(config['urls']):
                results[cms] = version or "Unknown"
            else:
                results[cms] = None

        return results

    def _detect_version(self, cms: str, config: Dict) -> Optional[str]:
        """Detect CMS version"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            for pattern in config['version_patterns']:
                match = re.search(pattern, response.text)
                if match:
                    return match.group(1)
        except Exception:
            pass
        return None

    def _check_urls(self, urls: list) -> bool:
        """Check if CMS-specific URLs exist"""
        for url in urls:
            try:
                response = self.session.get(
                    f"{self.base_url}{url}",
                    timeout=5,
                    allow_redirects=False
                )
                if response.status_code in [200, 301, 302, 403]:
                    return True
            except Exception:
                continue
        return False

# Usage
detector = CMSDetector("https://target.com")
cms_results = detector.detect_cms()
for cms, version in cms_results.items():
    if version:
        print(f"[+] {cms} v{version} detected")
```

---

## Comprehensive Technology Stack Identification

```python
#!/usr/bin/env python3
"""Comprehensive technology stack identification"""

import requests
import json
import sys
from typing import Dict, List, Any
from dataclasses import dataclass

@dataclass
class TechStack:
    server: str
    programming_language: str
    database: str
    cms: str
    frontend_framework: str
    cdn: str
    web_server: str
    operating_system: str
    security_tools: List[str]

class TechnologyStackIdentifier:
    def __init__(self, url: str):
        self.url = url
        self.session = requests.Session()
        self.stack = TechStack(
            server="Unknown",
            programming_language="Unknown",
            database="Unknown",
            cms="Unknown",
            frontend_framework="Unknown",
            cdn="Unknown",
            web_server="Unknown",
            operating_system="Unknown",
            security_tools=[]
        )

    def identify_all(self) -> TechStack:
        """Identify complete technology stack"""
        print(f"[*] Identifying technology stack for: {self.url}")

        # Server detection
        self.stack.server = self._detect_server()

        # Programming language
        self.stack.programming_language = self._detect_language()

        # Database
        self.stack.database = self._detect_database()

        # CMS
        self.stack.cms = self._detect_cms()

        # Frontend framework
        self.stack.frontend_framework = self._detect_frontend()

        # CDN
        self.stack.cdn = self._detect_cdn()

        # Web server
        self.stack.web_server = self._detect_web_server()

        # Operating system
        self.stack.operating_system = self._detect_os()

        # Security tools
        self.stack.security_tools = self._detect_security_tools()

        return self.stack

    def _detect_server(self) -> str:
        """Detect server technology"""
        try:
            response = self.session.get(self.url, timeout=5)
            server = response.headers.get('Server', 'Unknown')
            return server
        except Exception:
            return "Unknown"

    def _detect_language(self) -> str:
        """Detect programming language"""
        try:
            response = self.session.get(self.url, timeout=5)
            headers = str(response.headers)
            content = response.text

            if 'X-Powered-By' in headers:
                return headers.split('X-Powered-By: ')[1].split('\n')[0]

            if 'PHPSESSID' in headers:
                return 'PHP'
            if 'JSESSIONID' in headers:
                return 'Java'
            if 'ASP.NET_SessionId' in headers:
                return 'ASP.NET'
            if 'connect.sid' in headers:
                return 'Node.js'
            if '_session_id' in headers:
                return 'Ruby'

            return 'Unknown'
        except Exception:
            return "Unknown"

    def _detect_database(self) -> str:
        """Detect database technology"""
        # Database detection typically requires more advanced techniques
        return "Unknown (requires deeper analysis)"

    def _detect_cms(self) -> str:
        """Detect CMS"""
        try:
            response = self.session.get(self.url, timeout=5)
            content = response.text

            if 'WordPress' in content or 'wp-content' in content:
                return 'WordPress'
            if 'Drupal' in content or 'drupal.js' in content:
                return 'Drupal'
            if 'Joomla' in content or '/administrator/' in content:
                return 'Joomla'
            if 'Shopify' in content or 'cdn.shopify.com' in content:
                return 'Shopify'
            if 'Magento' in content or 'magento' in content.lower():
                return 'Magento'

            return 'Unknown'
        except Exception:
            return "Unknown"

    def _detect_frontend(self) -> str:
        """Detect frontend framework"""
        try:
            response = self.session.get(self.url, timeout=5)
            content = response.text

            if 'react' in content.lower() or '__NEXT_DATA__' in content:
                return 'React'
            if 'vue' in content.lower() or 'data-v-' in content:
                return 'Vue.js'
            if 'angular' in content.lower() or 'ng-app' in content:
                return 'Angular'
            if 'jquery' in content.lower():
                return 'jQuery'

            return 'Unknown'
        except Exception:
            return "Unknown"

    def _detect_cdn(self) -> str:
        """Detect CDN"""
        try:
            response = self.session.get(self.url, timeout=5)
            headers = response.headers

            if 'cf-ray' in headers:
                return 'Cloudflare'
            if 'x-cdn' in headers:
                return 'Incapsula'
            if 'x-sucuri-id' in headers:
                return 'Sucuri'
            if 'x-akamai' in headers:
                return 'Akamai'
            if 'x-edge-ip' in headers:
                return 'Fastly'

            return 'Unknown'
        except Exception:
            return "Unknown"

    def _detect_web_server(self) -> str:
        """Detect web server"""
        try:
            response = self.session.get(self.url, timeout=5)
            return response.headers.get('Server', 'Unknown')
        except Exception:
            return "Unknown"

    def _detect_os(self) -> str:
        """Detect operating system"""
        # OS detection typically requires more advanced techniques
        return "Unknown (requires deeper analysis)"

    def _detect_security_tools(self) -> List[str]:
        """Detect security tools"""
        tools = []
        try:
            response = self.session.get(self.url, timeout=5)
            headers = response.headers

            if 'X-Frame-Options' in headers:
                tools.append('Clickjacking Protection')
            if 'X-Content-Type-Options' in headers:
                tools.append('MIME Type Protection')
            if 'X-XSS-Protection' in headers:
                tools.append('XSS Protection')
            if 'Content-Security-Policy' in headers:
                tools.append('Content Security Policy')
            if 'Strict-Transport-Security' in headers:
                tools.append('HSTS')

        except Exception:
            pass

        return tools

    def generate_report(self) -> str:
        """Generate technology stack report"""
        report = "=== Technology Stack Report ===\n"
        report += f"Target: {self.url}\n\n"

        report += f"Server: {self.stack.server}\n"
        report += f"Programming Language: {self.stack.programming_language}\n"
        report += f"Database: {self.stack.database}\n"
        report += f"CMS: {self.stack.cms}\n"
        report += f"Frontend Framework: {self.stack.frontend_framework}\n"
        report += f"CDN: {self.stack.cdn}\n"
        report += f"Web Server: {self.stack.web_server}\n"
        report += f"Operating System: {self.stack.operating_system}\n"
        report += f"Security Tools: {', '.join(self.stack.security_tools)}\n"

        return report

# Usage
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    identifier = TechnologyStackIdentifier(sys.argv[1])
    stack = identifier.identify_all()
    print(identifier.generate_report())
```

---

## Reporting Templates

### Technology Stack Report
```
## Technology Stack Report

### Target: [url]

### Server Infrastructure
- Server: [server name and version]
- CDN: [CDN provider]
- Web Server: [web server name]
- Operating System: [OS if detected]

### Application Stack
- Programming Language: [language and version]
- Database: [database type]
- CMS: [CMS name and version]
- Frontend Framework: [framework name]

### Security Tools
[List detected security tools and configurations]

### Findings
1. [Finding 1]
2. [Finding 2]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
```

### Technology Risk Matrix
| Severity | Condition | Impact |
|----------|-----------|--------|
| High | Outdated components | Known vulnerabilities |
| Medium | Default configurations | Security misconfig |
| Low | Information disclosure | Reconnaissance aid |

---

## Quick Reference Cheat Sheet

### Server Detection
```bash
curl -I https://target.com | grep -i "server\|x-powered-by"
```

### CMS Detection
```bash
curl -s https://target.com | grep -i "wordpress\|drupal\|joomla"
```

### Framework Detection
```bash
curl -s https://target.com | grep -i "react\|vue\|angular\|jquery"
```

### CDN Detection
```bash
curl -I https://target.com | grep -i "cf-ray\|x-cdn\|x-sucuri"
```

---

## Resources and References
- Wappalyzer: https://www.wappalyzer.com/
- BuiltWith: https://builtwith.com/
- WhatWeb: https://github.com/urbanadventurer/WhatWeb
- Webanalyze: https://github.com/rverton/webanalyze
- Retire.js: https://github.com/RetireJS/retire.js
