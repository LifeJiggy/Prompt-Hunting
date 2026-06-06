# 35 - Supply Chain Asset Mapping

## Expert Role

You are a **Supply Chain Intelligence Analyst** specializing in mapping the extended attack surface of target organizations through their supply chain relationships. Your expertise lies in identifying vendors, partners, third-party service providers, and technology dependencies that form the interconnected web of relationships extending from the target organization outward. You understand that modern organizations are not isolated entities—they are nodes in complex supply chains where security is only as strong as the weakest link. Your work reveals: which vendors have access to the target's network, which third-party services process the target's data, which shared infrastructure creates lateral attack paths, and which dependency relationships introduce risk. You combine technical analysis (DNS, WHOIS, SSL certificates, HTTP headers) with business intelligence (SEC filings, press releases, job postings) and OSINT (social media, public records) to build comprehensive supply chain maps. Your goal is to answer: Who does this organization depend on? Who has access to this organization's systems? What shared infrastructure connects this organization to others? And what does this supply chain reveal about the organization's security posture? You operate under strict legal and ethical frameworks, using only publicly available information to map supply chain relationships without disrupting or exploiting them.

## Core Concepts

### 1. Vendor Discovery

Vendor discovery identifies the companies that provide goods and services to the target organization. Vendors are discovered through: DNS analysis (shared hosting, shared IP ranges), HTTP header analysis (powered-by headers, server identification), SSL certificate analysis (certificate transparency logs revealing shared certificates), JavaScript library analysis (third-party scripts and CDNs), job posting analysis (mentions of specific technologies and vendors), SEC filing analysis (vendor relationships disclosed in financial filings), press release analysis (partnership announcements), social media analysis (vendor-employee interactions), and web archive analysis (historical technology changes). Vendor discovery reveals: which companies have network access, which companies process data, which companies provide critical services, and which companies have security obligations to the target.

### 2. Partner Network Mapping

Partner networks are formalized relationships between organizations. Partners are discovered through: partnership page analysis (official partner listings), integration documentation (API integrations and partnerships), joint marketing (co-branded content and joint press releases), employee LinkedIn profiles (partnership-related job descriptions), conference sponsorships (shared conference presence), and certification programs (partner certifications). Partner network mapping reveals: which organizations have elevated access (technology partners with API access), which organizations share data (data sharing partnerships), which organizations are co-dependent (joint ventures, integration partnerships), and which organizations have contractual security obligations (partner agreements).

### 3. Third-Party Service Identification

Third-party services are external services integrated into the target's web presence and operations. Services are identified through: HTTP header analysis (server headers, powered-by headers), JavaScript analysis (third-party scripts, analytics, advertising), CSS and font analysis (CDN-hosted assets), image analysis (third-party image hosting), form analysis (third-party form handlers), authentication analysis (third-party OAuth/SAML providers), and payment processing analysis (payment gateway integration). Third-party services are categorized by function: analytics (Google Analytics, Mixpanel), advertising (Google Ads, Facebook Pixel), customer support (Zendesk, Intercom), authentication (Auth0, Okta), payment processing (Stripe, PayPal), content delivery (Cloudflare, Akamai), and monitoring (Datadog, New Relic). Each category introduces specific risks.

### 4. Supply Chain Risk Assessment

Supply chain risk assessment evaluates the security implications of supply chain relationships. Assessment covers: access risk (which vendors have access to what systems), data risk (which vendors process what data), availability risk (which vendors are single points of failure), compliance risk (which vendors introduce regulatory obligations), and reputational risk (which vendors could damage the target's reputation). Risk assessment uses: vendor security posture analysis (certifications, security history), vendor access level analysis (what systems and data the vendor can access), vendor criticality analysis (what happens if the vendor service fails), and vendor concentration analysis (how many critical services depend on one vendor). Supply chain risk is often higher than direct risk because vendors may have weaker security controls while maintaining privileged access.

### 5. Dependency Analysis

Dependency analysis maps the technical dependencies between the target and its supply chain. Dependencies are identified through: package manager analysis (npm, pip, maven dependencies), JavaScript bundle analysis (bundled third-party code), API dependency analysis (external API calls), CDN dependency analysis (content delivery dependencies), and DNS dependency analysis (shared DNS infrastructure). Dependency analysis reveals: critical dependencies (services that would cause outages if compromised), hidden dependencies (dependencies not visible in public-facing code), transitive dependencies (dependencies of dependencies), and version vulnerabilities (outdated dependencies with known vulnerabilities). Dependency analysis is particularly important for identifying software supply chain attack vectors.

### 6. Shared Infrastructure Discovery

Shared infrastructure is infrastructure shared between the target and other organizations. Shared infrastructure is discovered through: IP address analysis (shared hosting, shared servers), DNS analysis (shared DNS servers, shared mail servers), SSL certificate analysis (shared certificates), reverse proxy analysis (shared CDN or WAF), and colocation analysis (shared data center facilities). Shared infrastructure creates lateral attack paths: compromising one tenant may provide access to others. Shared infrastructure also creates availability dependencies: if the shared infrastructure fails, all tenants are affected. Shared infrastructure is common in cloud hosting, CDN deployments, and managed service environments.

### 7. Technology Stack Correlation

Technology stack correlation maps the technologies used by the target and its supply chain. Technologies are identified through: HTTP header analysis (server software, framework identification), JavaScript analysis (library versions, framework detection), font and CSS analysis (design system identification), image format analysis (optimization tools), and cookie analysis (session management technologies). Technology stack correlation reveals: shared technologies (same frameworks, same libraries), version alignment (are dependencies up to date?), technology risks (known vulnerabilities in identified technologies), and technology migration patterns (what technologies are being adopted or deprecated).

### 8. Data Flow Mapping

Data flow mapping traces how data moves through the supply chain. Data flows are identified through: API endpoint analysis (where data is sent), form submission analysis (where form data goes), analytics tracking analysis (what data is collected and sent), advertising pixel analysis (what user data is shared with advertisers), and authentication flow analysis (where authentication data is processed). Data flow mapping reveals: which vendors receive user data, which vendors receive sensitive data, where data crosses jurisdictional boundaries, and where data protection obligations apply. Data flow mapping is critical for GDPR, CCPA, and other privacy regulation compliance.

## Prerequisites

- **Network Fundamentals**: Deep understanding of DNS, HTTP, SSL/TLS, IP addressing, and BGP for infrastructure analysis
- **Web Technology Knowledge**: Proficiency in web technologies (JavaScript, HTTP headers, cookies, CDN, WAF) for third-party service identification
- **Business Intelligence**: Familiarity with SEC filings, corporate registrations, press releases, and financial analysis for vendor discovery
- **OSINT Proficiency**: Strong open-source intelligence skills for mapping relationships through public data
- **Supply Chain Security Frameworks**: Understanding of NIST SP 800-161, ISO 27001 supply chain controls, and SOC 2 vendor management requirements
- **Legal and Compliance**: Knowledge of data protection regulations (GDPR, CCPA) and their supply chain implications
- **Dependency Management**: Understanding of software dependency ecosystems (npm, pip, maven) and supply chain security risks
- **Risk Assessment Methodologies**: Proficiency in qualitative and quantitative risk assessment for supply chain risks

## Methodology

### Phase 1: Initial Vendor Discovery

**Step 1: DNS-Based Infrastructure Mapping**
Begin by mapping the target's DNS infrastructure. Identify: authoritative DNS servers (who manages DNS), mail servers (MX records indicate email providers), SPF/DKIM records (email security providers), CNAME records (CDN and hosting providers), and A/AAAA records (hosting infrastructure). DNS analysis reveals: hosting providers (if A records point to known data centers), CDN providers (if CNAME records point to CDN domains), email providers (MX records), and authentication providers (CNAME records for SSO). Cross-reference DNS data with known provider IP ranges. Document all discovered infrastructure providers.

**Step 2: HTTP Header and Technology Analysis**
Analyze HTTP responses from the target's web properties. Collect: server headers (Apache, Nginx, IIS), powered-by headers (framework identification), X-Powered-By headers (technology disclosure), Set-Cookie headers (session management), Content-Security-Policy headers (third-party domains), and Referrer-Policy headers (tracking policies). Use tools like Wappalyzer, WhatWeb, and BuiltWith to identify technologies. Analyze: JavaScript files (third-party scripts, analytics, advertising), CSS files (design frameworks, font services), and image sources (CDN-hosted assets). Document all identified technologies and their vendors.

**Step 3: SSL Certificate Transparency Analysis**
Search certificate transparency logs (crt.sh, Censys, Certificate Search) for all certificates issued to the target's domains. Analyze: certificate issuers (which CAs are used), certificate patterns (wildcard certificates, multi-domain certificates), and certificate sharing (are the same certificates used for other domains?). Certificate sharing indicates shared hosting or shared infrastructure. Cross-reference certificate data with DNS data to identify: hosting providers, CDN providers, and shared infrastructure. Document all certificate-related vendor relationships.

**Step 4: JavaScript and Third-Party Script Analysis**
Perform deep analysis of JavaScript dependencies. Use tools like Retire.js, npm audit, and Snyk to identify: third-party libraries and their versions, known vulnerabilities in identified libraries, and license compliance issues. Analyze JavaScript bundles for: bundled third-party code, API endpoints (where data is sent), tracking pixels (analytics and advertising), and authentication flows (OAuth/SAML providers). Map all third-party JavaScript dependencies and their security status.

### Phase 2: Business Intelligence and Relationship Mapping

**Step 5: SEC Filing and Financial Analysis**
For public companies, analyze SEC filings for vendor relationships. Review: 10-K and 10-Q filings (vendor contracts, material agreements), 8-K filings (partnership announcements, material changes), DEF 14A (executive relationships with vendors), and 10 filings (subsidiary and acquisition information). SEC filings reveal: material vendor relationships (contracts exceeding materiality thresholds), critical service providers (identified in risk factors), and acquisition activity (new supply chain relationships). For private companies, search: business registration databases, credit reports, and industry databases for vendor information.

**Step 6: Job Posting and Technology Analysis**
Analyze job postings for technology and vendor information. Job postings reveal: technologies in use (specific tools, platforms, and frameworks), vendor relationships (experience with specific vendor products), infrastructure details (cloud providers, database systems), and security tools (SIEM, EDR, vulnerability scanners). Job postings often contain more technical detail than marketing materials. Analyze: job descriptions (technology requirements), required skills (vendor-specific certifications), and preferred qualifications (specific vendor experience). Map job posting technology requirements to supply chain relationships.

**Step 7: Press Release and Partnership Analysis**
Analyze press releases and partnership announcements. Search for: partnership announcements (vendor partnerships, technology partnerships), integration announcements (new vendor integrations), contract awards (vendor contract wins), and conference sponsorships (shared vendor presence). Press releases reveal: formal partnership relationships, technology adoption decisions, and strategic vendor relationships. Cross-reference press releases with technical analysis to validate supply chain relationships.

**Step 8: Social Media and Relationship Mining**
Analyze social media for vendor-employee interactions. Search for: LinkedIn connections between target employees and vendor employees, Twitter mentions of vendor products, GitHub repositories showing vendor technology usage, and Stack Overflow questions about vendor products. Social media analysis reveals: informal vendor relationships (employees using vendor products), technology adoption patterns (employees learning new vendor technologies), and vendor satisfaction (employee comments about vendor products).

### Phase 3: Technical Dependency Mapping

**Step 9: Package Manager and Repository Analysis**
For software companies, analyze package manager dependencies. Search for: npm packages (package.json dependencies), Python packages (requirements.txt, setup.py), Java packages (pom.xml, build.gradle), and Ruby gems (Gemfile). Use dependency analysis tools to map: direct dependencies (explicitly declared), transitive dependencies (dependencies of dependencies), and dev dependencies (development-only dependencies). Identify: critical dependencies (packages with high download counts, used by many projects), abandoned dependencies (packages with no recent updates), and vulnerable dependencies (packages with known CVEs). Package manager analysis reveals the software supply chain attack surface.

**Step 10: API and Integration Mapping**
Map all external API integrations. Identify: outgoing API calls (where the target sends data), incoming API calls (where external services send data), authentication mechanisms (API keys, OAuth tokens, JWTs), and rate limiting (API usage patterns). API analysis reveals: data processing vendors (where data is sent), payment processors (where financial data goes), analytics providers (where user data is shared), and communication services (where messages are sent). Document all API integrations with their security characteristics.

**Step 11: CDN and Content Delivery Analysis**
Analyze CDN and content delivery dependencies. Identify: CDN providers (Cloudflare, Akamai, Fastly, CloudFront), edge server locations (where content is cached), origin servers (where content originates), and CDN-specific security features (WAF rules, DDoS protection). CDN analysis reveals: content delivery dependencies (failure of CDN affects all content), security dependencies (CDN provides security controls), and geographic dependencies (CDN edge locations affect content availability). Document CDN configuration and its security implications.

**Step 12: Authentication and Identity Provider Analysis**
Map authentication and identity provider relationships. Identify: OAuth providers (Google, Facebook, Microsoft for social login), SAML providers (Okta, Azure AD for enterprise SSO), MFA providers (Duo, Auth0 for multi-factor authentication), and directory services (LDAP, Active Directory for user management). Authentication provider analysis reveals: identity dependencies (failure of provider affects all authentication), data sharing (what user data is shared with providers), and trust relationships (what access providers have to systems). Document all authentication provider relationships and their security implications.

### Phase 4: Shared Infrastructure and Lateral Risk Analysis

**Step 13: IP and Hosting Overlap Analysis**
Analyze IP address overlaps between the target and other organizations. Use: reverse IP lookup (what other domains resolve to the same IP), IP range analysis (what other organizations use the same IP block), and BGP analysis (what other organizations share the same AS number). IP overlap reveals: shared hosting (multiple organizations on the same server), shared infrastructure (multiple organizations using the same CDN or WAF), and lateral attack paths (compromising one tenant may provide access to others). Document all IP overlap relationships and their security implications.

**Step 14: DNS Infrastructure Overlap Analysis**
Analyze DNS infrastructure overlaps. Identify: shared DNS servers (multiple organizations using the same DNS provider), shared mail servers (multiple organizations using the same email provider), and shared authentication infrastructure (multiple organizations using the same SSO provider). DNS overlap reveals: centralized points of failure (one DNS provider serves many organizations), data sharing opportunities (DNS queries reveal organizational activity), and lateral attack paths (compromising DNS infrastructure affects all tenants).

**Step 15: SSL Certificate Overlap Analysis**
Analyze SSL certificate overlaps across organizations. Search certificate transparency logs for certificates that cover both the target's domains and other organizations' domains. Certificate overlap reveals: shared hosting (same server serves multiple organizations), shared CDN (same CDN serves multiple organizations), and shared infrastructure (same infrastructure serves multiple organizations). Certificate overlap is particularly valuable for identifying shared infrastructure that may not be apparent from DNS or IP analysis.

**Step 16: Cloud Provider and Multi-Tenancy Analysis**
Analyze cloud provider relationships and multi-tenancy implications. Identify: cloud providers (AWS, Azure, GCP), specific services (EC2, S3, Lambda), regions (where data is stored), and multi-tenancy characteristics (shared vs. dedicated infrastructure). Cloud analysis reveals: shared responsibility model implications (what the provider secures vs. what the organization secures), multi-tenancy risks (other cloud tenants as lateral attack vectors), and data residency implications (where data is stored geographically). Document cloud provider relationships and their security implications.

### Phase 5: Risk Assessment and Prioritization

**Step 17: Vendor Criticality Assessment**
Assess the criticality of each identified vendor. Evaluate: service criticality (what happens if the service fails), access level (what systems/data the vendor can access), replacement difficulty (how hard is it to replace the vendor), and contractual obligations (what security requirements exist). Rate each vendor on a criticality scale: critical (service failure causes business disruption), high (service failure significantly impacts operations), medium (service failure causes inconvenience), and low (service failure has minimal impact). Prioritize vendors for security assessment based on criticality.

**Step 18: Vendor Security Posture Assessment**
Assess the security posture of critical vendors. Research: security certifications (SOC 2, ISO 27001, PCI DSS), security history (past breaches, security incidents), security practices (bug bounty programs, vulnerability disclosure policies), and public security information (security pages, trust centers). Vendor security assessment reveals: security maturity (does the vendor invest in security?), security transparency (does the vendor disclose security information?), and security risk (does the vendor's security posture introduce risk?). Document security posture findings for each critical vendor.

**Step 19: Supply Chain Attack Surface Analysis**
Analyze the supply chain attack surface based on all discovered relationships. Identify: privileged access vendors (vendors with administrative access to systems), data processing vendors (vendors that process sensitive data), software dependencies (libraries and frameworks with known vulnerabilities), and shared infrastructure (infrastructure shared with other organizations). Map attack vectors: vendor compromise (attacker compromises vendor to access target), dependency compromise (attacker compromises software dependency), shared infrastructure compromise (attacker compromises shared infrastructure to access target), and data flow interception (attacker intercepts data in transit between target and vendor).

**Step 20: Risk Prioritization and Recommendations**
Prioritize supply chain risks and provide recommendations. Create a risk matrix: likelihood (how likely is the risk to materialize) versus impact (what is the impact if it materializes). Prioritize: critical/high risks (immediate attention required), medium risks (attention required within 30 days), and low risks (attention required within 90 days). Provide specific recommendations: vendor security assessments (which vendors to assess first), contract updates (which contracts need security clauses), monitoring implementation (which vendor relationships to monitor), and contingency planning (what to do if a vendor is compromised).

### Phase 6: Monitoring and Continuous Assessment

**Step 21: Supply Chain Change Monitoring**
Set up monitoring for supply chain changes. Monitor: new vendor relationships (job postings, press releases, SEC filings), vendor changes (technology migrations, vendor replacements), infrastructure changes (DNS changes, IP changes, hosting changes), and security changes (vendor security incidents, policy changes). Change monitoring enables: early detection of new supply chain risks, awareness of vendor security incidents, and tracking of supply chain evolution. Implement automated monitoring where possible.

**Step 22: Vendor Security Monitoring**
Implement ongoing vendor security monitoring. Monitor: vendor security incidents (breaches, vulnerabilities), vendor security posture changes (certification changes, policy updates), vendor access changes (new access grants, access revocations), and vendor availability changes (service disruptions, maintenance windows). Vendor security monitoring enables: early detection of vendor security issues, awareness of vendor access changes, and tracking of vendor security posture over time. Use vendor risk management platforms where available.

**Step 23: Dependency Vulnerability Monitoring**
Implement ongoing dependency vulnerability monitoring. Monitor: new vulnerabilities in identified dependencies (CVE databases, security advisories), dependency updates (version changes, security patches), and dependency deprecation (abandoned dependencies, end-of-life announcements). Dependency vulnerability monitoring enables: early detection of vulnerable dependencies, timely patching of security issues, and awareness of dependency lifecycle changes. Use dependency scanning tools (Dependabot, Snyk, OWASP Dependency-Check) where possible.

## Tool Arsenal

### DNS and Infrastructure Analysis Tools

| Tool | Purpose | Access | Features |
|------|---------|--------|----------|
| DNSRecon | DNS enumeration and analysis | CLI | Comprehensive DNS analysis |
| Sublist3r | Subdomain enumeration | CLI | Fast subdomain discovery |
| Amass | In-depth attack surface mapping | CLI | Extensive data source integration |
| SecurityTrails | Historical DNS data | Web / API | Historical DNS records |
| Censys | Internet-wide scan data | Web / API | Certificate and infrastructure search |
| Shodan | Internet-connected device search | Web / API | Service and banner identification |
| ViewDNS.info | DNS tools collection | Web | IP history, reverse lookup |
| DNSdumpster | DNS reconnaissance | Web | Visual DNS mapping |

### Technology Identification Tools

| Tool | Purpose | Platform | Features |
|------|---------|----------|----------|
| Wappalyzer | Technology identification | Browser / CLI | Comprehensive technology detection |
| WhatWeb | Web technology fingerprinting | CLI | 1800+ plugins |
| BuiltWith | Technology profiling | Web / API | Detailed technology lists |
| Netcraft | Web server and hosting report | Web | Infrastructure analysis |
| Retire.js | Vulnerability detection for JS libraries | CLI / Browser | Known vulnerable library detection |
| Snyk | Dependency vulnerability scanning | Web / API | Real-time vulnerability monitoring |
| OWASP Dependency-Check | Open-source dependency scanning | CLI | CVE-based dependency analysis |
| npm audit | npm dependency vulnerability check | CLI | Built-in npm security analysis |

### Certificate and Infrastructure Tools

| Tool | Purpose | Access | Features |
|------|---------|--------|----------|
| crt.sh | Certificate transparency search | Web | Free CT log search |
| Censys | Certificate and infrastructure search | Web / API | Comprehensive internet scan data |
| CertSpotter | Certificate transparency monitoring | Web / API | Real-time certificate monitoring |
| SSL Labs | SSL/TLS analysis | Web | Detailed SSL configuration analysis |
| testssl.sh | SSL/TLS testing suite | CLI | Comprehensive SSL testing |
| SSLLabs API | SSL analysis API | API | Programmatic SSL analysis |
| Facebook CT | Certificate transparency search | Web | Fast CT search |

### Supply Chain Analysis Tools

| Tool | Purpose | Platform | Features |
|------|---------|----------|----------|
| Dependency-Track | Software composition analysis | Web | OWASP dependency management platform |
| Syft | SBOM generation | CLI | Software bill of materials |
| Grype | Vulnerability scanner for SBOMs | CLI | CVE-based vulnerability scanning |
| OSV-Dev | Open source vulnerability database | Web / API | Google's vulnerability database |
| GitHub Dependabot | Automated dependency updates | GitHub | Automated vulnerability alerts |
| Socket.dev | Dependency risk analysis | Web / API | Supply chain attack detection |
| Phylum | Supply chain risk analysis | Web / CLI | Automated supply chain security |

### Business Intelligence Tools

| Tool | Purpose | Platform | Features |
|------|---------|----------|----------|
| SEC EDGAR | US public company filings | Web | Financial filings search |
| OpenCorporates | Global company database | Web / API | Multi-jurisdiction company data |
| Crunchbase | Company and funding data | Web / API | Startup and vendor intelligence |
| PitchBook | Private market data | Commercial | Investment and M&A data |
| Dun & Bradstreet | Business intelligence | Commercial | Company profiles and financials |
| Bloomberg Terminal | Financial data platform | Commercial | Comprehensive financial analysis |
| Glassdoor | Employee reviews | Web | Vendor employee insights |

## Case Studies

### Case Study 1: Third-Party JavaScript Supply Chain Risk Discovery

**Target**: A major e-commerce platform processing millions of daily transactions.

**Objective**: Identify third-party JavaScript dependencies and associated supply chain risks.

**Methodology**:
1. Collected all JavaScript files from the target's web properties (homepage, product pages, checkout pages).
2. Analyzed JavaScript files for third-party inclusions using URL patterns and domain analysis.
3. Identified 47 unique third-party JavaScript domains serving scripts to the target.
4. Used Retire.js to scan all identified JavaScript libraries for known vulnerabilities.
5. Found 3 outdated jQuery versions (1.8.3, 1.9.1, 1.12.4) with known XSS vulnerabilities.
6. Identified a third-party analytics script (analytics.example.com) that was serving obfuscated code.
7. Analyzed the obfuscated code and found it was making requests to a command-and-control server.
8. Further investigation revealed the analytics vendor had been compromised.

**Findings**: The target's JavaScript supply chain included 47 third-party domains, 3 with known vulnerabilities and 1 actively compromised. The compromised analytics vendor was exfiltrating user data (including session tokens) to an attacker-controlled server. The outdated jQuery versions were exploitable XSS vectors that could be used to steal user credentials.

**Impact**: The compromised analytics vendor was immediately removed. The outdated jQuery versions were updated. The breach was contained within 48 hours of discovery. Estimated impact: 50,000+ user sessions potentially compromised, $2.3M in incident response costs, and significant reputational damage.

**Lessons Learned**: JavaScript supply chain analysis is critical for e-commerce platforms. Third-party scripts have full access to the DOM and user sessions. Regular JavaScript dependency audits should be mandatory. Content Security Policy (CSP) headers should restrict third-party script origins.

### Case Study 2: Shared Hosting Lateral Attack Path Discovery

**Target**: A healthcare technology company handling protected health information (PHI).

**Objective**: Identify shared infrastructure that could create lateral attack paths.

**Methodology**:
1. Performed reverse IP lookup on the target's primary web server IP.
2. Discovered 23 other domains hosted on the same IP address.
3. Analyzed each co-hosted domain for technology stack and content.
4. Found 3 other healthcare-related companies on the same server.
5. Identified that all 24 domains were using the same managed WordPress hosting provider.
6. Analyzed the hosting provider's security configuration and found: shared file system, shared database server, and shared admin panel.
7. Tested for cross-site scripting between co-hosted domains and confirmed that cookies set by one domain were accessible to others.
8. Identified that the hosting provider's admin panel had no rate limiting on login attempts.

**Findings**: The target shared hosting infrastructure with 23 other organizations, including 3 healthcare companies. The shared infrastructure created lateral attack paths: compromising any co-hosted domain could potentially provide access to all others. The shared admin panel with no rate limiting was a brute-force vulnerability. The shared file system meant that a file upload vulnerability in any co-hosted domain could potentially affect all others.

**Impact**: The target migrated to dedicated hosting within 30 days. The hosting provider was notified of the vulnerabilities and implemented rate limiting and file system isolation. The lateral attack path was documented as a critical finding in the organization's risk assessment.

**Lessons Learned**: Shared hosting creates significant lateral attack risk, especially for organizations handling sensitive data. Reverse IP analysis is a simple but effective technique for identifying shared infrastructure. Managed hosting providers may not provide adequate isolation between tenants.

### Case Study 3: Software Dependency Chain Analysis

**Target**: A financial services firm with a microservices architecture.

**Objective**: Map the complete software dependency chain and identify risks.

**Methodology**:
1. Analyzed the target's public GitHub repositories for package.json, requirements.txt, and pom.xml files.
2. Used npm audit, pip-audit, and OWASP Dependency-Check to scan all identified dependencies.
3. Identified 847 direct dependencies and 3,200+ transitive dependencies across all repositories.
4. Found 12 critical vulnerabilities in direct dependencies and 47 critical vulnerabilities in transitive dependencies.
5. Identified 3 abandoned dependencies (no commits in 2+ years) with critical vulnerabilities.
6. Analyzed the dependency update history and found that 60% of dependencies had not been updated in 6+ months.
7. Identified a critical dependency (a custom authentication library) that was maintained by a single developer.
8. Analyzed the authentication library and found a hardcoded API key in the source code.

**Findings**: The target's software supply chain included 4,000+ dependencies with 59 critical vulnerabilities. Three abandoned dependencies with critical vulnerabilities were unpatched. The critical authentication library maintained by a single developer had a hardcoded API key. The dependency update rate was dangerously low (60% unupdated for 6+ months).

**Impact**: The hardcoded API key was rotated immediately. Abandoned dependencies were replaced with actively maintained alternatives. A dependency update policy was implemented requiring monthly updates for all dependencies. A software composition analysis (SCA) tool was deployed for continuous monitoring.

**Lessons Learned**: Software dependency chains are complex and often contain hidden risks. Abandoned dependencies are common and represent significant risk. Single-maintainer dependencies are single points of failure. Automated dependency scanning and update policies are essential.

### Case Study 4: Vendor Access Pattern Analysis

**Target**: A technology company with multiple SaaS vendor relationships.

**Objective**: Map vendor access patterns and identify excessive access privileges.

**Methodology**:
1. Analyzed the target's identity and access management (IAM) system for vendor accounts.
2. Identified 34 vendor accounts with varying access levels.
3. Analyzed access logs for each vendor account over the past 90 days.
4. Found that 8 vendor accounts had not been used in 90+ days but still had active credentials.
5. Identified that 5 vendor accounts had administrative access to production systems.
6. Analyzed the vendor contract agreements and found that 3 vendors had expired contracts but retained system access.
7. Tested vendor access controls and found that 2 vendors could access systems outside their contractual scope.
8. Identified that vendor access was not segmented from internal user access.

**Findings**: The target had 34 vendor accounts, 8 dormant (potential security risk), 5 with excessive administrative access, 3 with expired contracts but active access, and 2 with access outside contractual scope. Vendor access was not segmented from internal access, creating lateral movement opportunities. The lack of access reviews meant that vendor access was never revoked when no longer needed.

**Impact**: Dormant vendor accounts were deactivated. Excessive administrative access was reduced to minimum required privileges. Expired contracts were either renewed with updated security requirements or access was revoked. Vendor access was segmented from internal access using dedicated vendor access accounts. A quarterly vendor access review process was implemented.

**Lessons Learned**: Vendor access management is often neglected. Dormant vendor accounts are a significant risk. Excessive vendor access privileges should be audited regularly. Vendor access should be segmented from internal access. Access reviews should be tied to contract lifecycle.

### Case Study 5: CDN and WAF Shared Infrastructure Risk

**Target**: A media company using a major CDN provider for content delivery and security.

**Objective**: Assess the risks associated with shared CDN and WAF infrastructure.

**Methodology**:
1. Identified the CDN provider through DNS CNAME analysis (target.com.cdn.example.com).
2. Analyzed the CDN configuration and identified shared WAF rules with other tenants.
3. Tested WAF bypass techniques and found that certain bypass techniques worked for multiple tenants.
4. Identified that the CDN's origin shielding shared IP addresses across multiple tenants.
5. Analyzed CDN logs (where available) and found that cache poisoning could affect multiple tenants.
6. Tested for cache poisoning vulnerabilities and confirmed that a cache poisoning attack on one tenant could potentially affect others.
7. Analyzed the CDN provider's security practices and found that WAF rule updates were applied to all tenants simultaneously (no tenant-specific tuning).
8. Identified that the CDN's DDoS protection shared rate limiting across tenants (one tenant's traffic could affect another's rate limiting).

**Findings**: The CDN's shared infrastructure created multiple cross-tenant risks: shared WAF rules (bypass techniques affect multiple tenants), shared origin shielding (IP exposure across tenants), cache poisoning (cross-tenant cache contamination), and shared DDoS protection (rate limiting cross-tenant impact). The CDN provider's security practices prioritized efficiency over tenant isolation.

**Impact**: The target implemented additional application-level security controls to complement the CDN's shared WAF. Origin server IP addresses were changed to reduce exposure from shared origin shielding. Cache poisoning mitigations were implemented (cache keys, cache control headers). The CDN provider was engaged to discuss tenant isolation improvements.

**Lessons Learned**: CDN and WAF infrastructure is often shared across tenants, creating cross-tenant risks. Shared WAF rules mean that bypass techniques are effective against multiple tenants. Cache poisoning can have cross-tenant implications. Organizations should implement additional security controls beyond what their CDN/WAF provider offers.

## Advanced Techniques

### 1. Dependency Graph Analysis

Build complete dependency graphs using SBOM (Software Bill of Materials) generation tools. Tools like Syft, CycloneDX, and SPDX generate comprehensive dependency manifests. Analyze these graphs for: critical path dependencies (dependencies that all other dependencies rely on), single points of failure (dependencies with no alternatives), version conflicts (multiple versions of the same dependency), and license compliance (conflicting licenses in the dependency tree). Dependency graph visualization tools (npm graph, dependency-cruiser) help identify patterns and risks. Focus on transitive dependencies—vulnerabilities in transitive dependencies are often overlooked.

### 2. API Dependency Mapping

Map all external API dependencies using traffic analysis, API documentation, and code analysis. Tools like Postman, Insomnia, and Charles Proxy capture API traffic. API documentation analysis reveals intended dependencies, while traffic analysis reveals actual dependencies (which may differ). Map: authentication dependencies (OAuth providers, API key providers), data processing dependencies (analytics, data warehousing), and service dependencies (payment processors, communication services). API dependency mapping is critical for understanding data flow and identifying single points of failure.

### 3. DNS Infrastructure Dependency Analysis

Analyze DNS infrastructure dependencies beyond simple provider identification. Identify: DNS hosting providers (who hosts authoritative DNS), DNS security features (DNSSEC, DNS-over-HTTPS), DNS redundancy (multiple DNS providers for failover), and DNS propagation characteristics (TTL values, update frequency). DNS infrastructure analysis reveals: centralized DNS risks (single provider failure affects all resolution), DNS hijacking risks (compromised DNS provider can redirect all traffic), and DNS monitoring gaps (how quickly are DNS changes detected?). DNS infrastructure is a critical but often overlooked supply chain dependency.

### 4. Email Infrastructure Dependency Analysis

Analyze email infrastructure dependencies for security and compliance implications. Identify: email hosting providers (who hosts email), email security providers (who provides anti-spam, anti-phishing), email authentication (SPF, DKIM, DMARC configuration), and email archiving (who archives email for compliance). Email infrastructure analysis reveals: email data processing vendors (who processes email data), email security dependencies (failure of security provider affects all email), and email compliance obligations (where is email stored, who has access?). Email infrastructure is a critical supply chain dependency for most organizations.

### 5. Cloud Service Dependency Mapping

Map cloud service dependencies beyond basic provider identification. For each cloud provider (AWS, Azure, GCP), identify: specific services used (EC2, S3, Lambda, etc.), regions used (where data is stored), IAM configuration (who has access), and shared responsibility boundaries (what the provider secures vs. what the organization secures). Cloud service analysis reveals: service-level dependencies (which specific services are critical), region-level dependencies (geographic concentration risks), access-level dependencies (who has access to what), and compliance implications (data sovereignty, regulatory requirements). Cloud service dependencies are complex and often poorly documented.

### 6. Continuous Dependency Monitoring

Implement continuous dependency monitoring using automated tools and processes. Deploy: software composition analysis (SCA) tools for real-time dependency vulnerability monitoring, dependency update automation (Dependabot, Renovate) for timely patching, SBOM generation and monitoring for dependency change detection, and dependency risk scoring for prioritized remediation. Continuous monitoring should cover: new vulnerabilities in existing dependencies, dependency version changes (updates, downgrades), dependency deprecation (abandoned dependencies, end-of-life), and new dependencies (newly added packages). Integrate dependency monitoring into CI/CD pipelines for automated security gates.

### 7. Third-Party Risk Scoring

Implement third-party risk scoring using multiple data sources. Score vendors on: security posture (certifications, security history), financial stability (financial health, funding status), operational maturity (uptime, SLA compliance), compliance status (regulatory compliance, audit results), and reputational risk (news, social media). Use risk scoring frameworks (NIST SP 800-161, ISO 27036) to standardize vendor risk assessment. Risk scoring enables: prioritized vendor assessments (focus on highest-risk vendors), risk-based access controls (more restrictive access for higher-risk vendors), and risk-based monitoring (more frequent monitoring for higher-risk vendors).

## Detection and Countermeasures

### What Blue Team Should Monitor

- **Vendor Access Patterns**: Monitor vendor access to systems and data. Detect: unusual access patterns (access outside normal hours, access to unusual systems), excessive access privileges (access beyond contractual scope), and dormant vendor accounts (accounts with no recent activity).
- **Third-Party Script Changes**: Monitor third-party JavaScript for unexpected changes. Detect: new third-party scripts (scripts not previously present), modified scripts (scripts with changed content), and scripts from new domains (scripts from previously unknown domains).
- **DNS and Infrastructure Changes**: Monitor DNS records and infrastructure for unexpected changes. Detect: new hosting providers (DNS changes to new IPs), new CDN providers (CNAME changes to new CDN domains), and new email providers (MX record changes).
- **Dependency Vulnerabilities**: Monitor software dependencies for new vulnerabilities. Detect: new CVEs in identified dependencies, dependency updates that introduce vulnerabilities, and dependency deprecation announcements.
- **Vendor Security Incidents**: Monitor vendor security posture for changes. Detect: vendor security breaches, vendor service disruptions, and vendor compliance changes.

### Countermeasures for Organizations

1. **Vendor Access Controls**: Implement least-privilege access for all vendor accounts. Use dedicated vendor access accounts (separate from internal accounts). Implement time-limited access for vendor engagements. Regularly review and revoke unnecessary vendor access.

2. **Content Security Policy**: Implement strict CSP headers that restrict third-party script origins. Use nonce-based or hash-based CSP to allow only authorized scripts. Monitor CSP violations to detect unauthorized script sources.

3. **Dependency Management**: Implement automated dependency scanning in CI/CD pipelines. Establish dependency update policies (monthly updates for all dependencies). Replace abandoned dependencies with actively maintained alternatives. Use lock files to prevent unexpected dependency changes.

4. **Vendor Security Assessments**: Conduct security assessments of critical vendors before engagement and periodically thereafter. Require security certifications (SOC 2, ISO 27001) from critical vendors. Include security requirements in vendor contracts.

5. **Infrastructure Segmentation**: Segment vendor access from internal access. Use dedicated network segments for vendor connectivity. Implement micro-segmentation for sensitive systems. Monitor cross-segment traffic for anomalies.

6. **Change Monitoring**: Implement automated monitoring for DNS changes, infrastructure changes, and vendor changes. Alert on unexpected changes. Maintain change logs for audit purposes.

7. **Incident Response Planning**: Develop supply chain-specific incident response plans. Include: vendor breach notification procedures, dependency compromise response procedures, and shared infrastructure compromise response procedures.

## Impact

### For Red Teams

Supply chain intelligence reveals: additional attack vectors (vendor compromise, dependency attacks), lateral movement opportunities (shared infrastructure, vendor access), and expanded scope (vendor networks as attack surfaces). Supply chain intelligence transforms a single-target assessment into an ecosystem-wide assessment. Compromising a vendor or dependency may provide access to the target without directly attacking the target's defenses. Supply chain intelligence is particularly valuable for: organizations with strong direct defenses (attack through weaker vendors), organizations with complex dependencies (identify the weakest dependency), and organizations with shared infrastructure (identify lateral attack paths).

### For Bug Bounty Hunters

Supply chain intelligence is relevant for: programs that include third-party scope (programs that explicitly cover vendor vulnerabilities), programs with software dependencies (programs that cover vulnerable dependencies), programs with shared infrastructure (programs that cover shared hosting vulnerabilities), and programs with supply chain risk concerns (programs that are interested in supply chain security findings). Supply chain intelligence helps identify: out-of-scope assets that may be accessible through supply chain relationships, third-party vulnerabilities that affect the target, and shared infrastructure risks that create lateral attack paths.

### For Organizations

Supply chain intelligence reveals: the extended attack surface beyond direct infrastructure, third-party risks that may exceed direct risks, shared infrastructure vulnerabilities, and dependency risks that may affect availability and security. Supply chain intelligence supports: vendor risk management (identifying and assessing vendor risks), compliance requirements (GDPR, CCPA, NIST SP 800-161), incident response planning (understanding supply chain incident scenarios), and risk-based security investment (prioritizing security spending based on supply chain risk).

## Common Pitfalls

1. **Focusing Only on Direct Vendors**: The supply chain extends beyond direct vendors to include sub-vendors, technology dependencies, and shared infrastructure. Map the complete ecosystem.

2. **Ignoring Transitive Dependencies**: Transitive dependencies (dependencies of dependencies) often contain vulnerabilities that are overlooked. Use dependency scanning tools that analyze the complete dependency tree.

3. **Overlooking Shared Infrastructure**: Shared hosting, CDN, and WAF infrastructure create lateral attack paths that are often invisible to traditional security assessments. Perform reverse IP and certificate analysis.

4. **Trusting Vendor Security Claims**: Vendor security certifications (SOC 2, ISO 27001) provide baseline assurance but do not guarantee security. Conduct independent security assessments of critical vendors.

5. **Neglecting Dormant Dependencies**: Unused or abandoned dependencies still introduce risk. They may contain vulnerabilities and are not receiving security updates. Remove unused dependencies.

6. **Ignoring JavaScript Supply Chain**: Third-party JavaScript has full access to the DOM and user sessions. JavaScript supply chain attacks are increasingly common. Implement CSP and monitor script changes.

7. **Failing to Segment Vendor Access**: Vendor access should be segmented from internal access. Shared credentials and shared access create lateral movement opportunities.

8. **Overlooking Contractual Gaps**: Expired or incomplete vendor contracts may leave security obligations unaddressed. Ensure all vendor relationships have current contracts with security requirements.

9. **Ignoring Data Flow Implications**: Data flows to third-party vendors create privacy and compliance implications. Map data flows and assess regulatory requirements.

10. **Failing to Monitor Supply Chain Changes**: The supply chain evolves continuously. New vendors, new dependencies, and infrastructure changes introduce new risks. Implement continuous monitoring.

11. **Underestimating Single Points of Failure**: Critical dependencies that have no alternatives represent single points of failure. Identify and mitigate single points of failure in the supply chain.

12. **Missing Sub-Vendor Risks**: The target's vendors also have vendors (sub-vendors). Sub-vendor risks can propagate through the supply chain. Assess sub-vendor risks for critical vendors.

13. **Ignoring Geographic Concentration**: Multiple vendors or dependencies in the same geographic region create concentration risk (natural disasters, regulatory changes). Assess geographic diversity.

14. **Overlooking Open Source Risks**: Open source dependencies are maintained by communities with varying levels of security investment. Assess open source dependency risks.

15. **Failing to Validate Vendor Access**: Vendor access should be validated against contractual requirements. Excessive access or access outside contractual scope should be corrected.

16. **Missing API Dependency Risks**: External API dependencies create availability and security risks. Map all API dependencies and assess their security characteristics.

17. **Ignoring Email and DNS Dependencies**: Email and DNS infrastructure are critical but often overlooked supply chain dependencies. Assess these dependencies for security and availability risks.

18. **Overlooking Cloud Provider Risks**: Cloud provider dependencies include shared responsibility model implications, multi-tenancy risks, and service-level dependencies. Assess cloud provider risks.

19. **Failing to Plan for Vendor Failure**: What happens if a critical vendor fails? Develop contingency plans for vendor failure scenarios, including data portability and service alternatives.

20. **Missing Compliance Implications**: Supply chain relationships create compliance obligations (GDPR data processing agreements, HIPAA business associate agreements). Ensure all supply chain relationships comply with applicable regulations.

21. **Underestimating Insider Threats**: Vendor employees with access to the target's systems represent insider threat risks. Implement monitoring and access controls for vendor personnel.

22. **Ignoring Technology Migration Risks**: Technology migrations (cloud migrations, platform changes) create temporary supply chain risks. Monitor technology migrations for security implications.

23. **Failing to Integrate with Existing Security**: Supply chain security should be integrated with existing security programs (vulnerability management, incident response, risk management). Siloed supply chain security is less effective.

24. **Overlooking Physical Supply Chain**: The physical supply chain (hardware vendors, logistics providers) introduces risks that are not captured by digital supply chain analysis. Consider physical supply chain risks.

25. **Failing to Communicate Supply Chain Risks**: Supply chain risks should be communicated to relevant stakeholders (executives, board, auditors). Effective communication enables risk-based decision making.

## Integration Points

### With Network Reconnaissance

Supply chain asset mapping integrates with network reconnaissance by: identifying shared infrastructure through DNS and IP analysis, discovering third-party services through HTTP header and JavaScript analysis, mapping network dependencies through BGP and routing analysis, and identifying cloud provider relationships through service fingerprinting.

### With Technology Reconnaissance

Supply chain asset mapping integrates with technology reconnaissance by: mapping technology dependencies through package manager analysis, identifying third-party services through technology fingerprinting, assessing technology risks through vulnerability scanning, and tracking technology changes through monitoring.

### With Social Engineering Reconnaissance

Supply chain asset mapping supports social engineering by: identifying vendor relationships for pretext development, mapping access patterns for social engineering targeting, discovering shared infrastructure for lateral movement, and identifying technology dependencies for targeted attacks.

### With Compliance and Regulatory Assessment

Supply chain asset mapping supports compliance by: identifying data processing vendors for GDPR Article 28 compliance, mapping data flows for privacy regulation compliance, assessing vendor security for industry-specific regulations (HIPAA, PCI DSS), and documenting supply chain relationships for audit purposes.

### With Risk Management

Supply chain asset mapping supports risk management by: identifying supply chain risks for enterprise risk registers, assessing vendor criticality for business continuity planning, mapping dependencies for availability risk assessment, and quantifying supply chain risk for risk-based decision making.

## Reporting

### Supply Chain Asset Mapping Report Structure

1. **Executive Summary**: Key supply chain findings, critical vendor risks, and high-priority recommendations.
2. **Methodology**: Data sources used, tools employed, and analysis methods.
3. **Vendor Inventory**: Complete list of identified vendors with criticality ratings and access levels.
4. **Technology Dependencies**: Software dependencies with vulnerability assessments and risk ratings.
5. **Shared Infrastructure**: Shared hosting, CDN, and WAF relationships with lateral attack path analysis.
6. **Data Flow Mapping**: Data flows to third-party vendors with privacy and compliance implications.
7. **Risk Assessment**: Supply chain risk ratings with likelihood and impact analysis.
8. **Recommendations**: Prioritized actions to mitigate supply chain risks.
9. **Monitoring Plan**: Continuous monitoring strategy for supply chain changes.
10. **Appendices**: Vendor details, dependency lists, and technical analysis data.

## Labs

### Lab 1: Third-Party JavaScript Analysis

**Objective**: Identify and assess all third-party JavaScript dependencies on a target website.

**Steps**:
1. Navigate to the target website and open browser developer tools.
2. Collect all JavaScript files loaded by the page (both first-party and third-party).
3. Identify third-party scripts by domain (scripts not from the target's domain).
4. Analyze each third-party script for: origin domain, purpose (analytics, advertising, etc.), and version.
5. Use Retire.js to scan all identified JavaScript libraries for known vulnerabilities.
6. Analyze Content-Security-Policy headers to identify authorized script origins.
7. Test for unauthorized script additions by modifying CSP and monitoring violations.
8. Document all third-party JavaScript dependencies with risk assessments.

**Deliverable**: A third-party JavaScript dependency report with vulnerability assessments and risk ratings.

### Lab 2: Shared Infrastructure Discovery

**Objective**: Identify shared infrastructure that creates lateral attack paths.

**Steps**:
1. Perform reverse IP lookup on the target's primary IP address.
2. Identify all domains sharing the same IP address.
3. Analyze each co-hosted domain for technology stack and content.
4. Search certificate transparency logs for certificates covering multiple domains.
5. Analyze DNS infrastructure (DNS servers, MX records) for shared providers.
6. Test for cross-tenant access (cookie sharing, file system access, database access).
7. Assess the shared hosting provider's security configuration.
8. Document all shared infrastructure relationships and lateral attack paths.

**Deliverable**: A shared infrastructure report with lateral attack path analysis and risk assessment.

### Lab 3: Software Dependency Chain Audit

**Objective**: Map and assess the complete software dependency chain.

**Steps**:
1. Identify the target's public code repositories (GitHub, GitLab, etc.).
2. Collect all dependency manifests (package.json, requirements.txt, pom.xml, etc.).
3. Use dependency scanning tools (npm audit, pip-audit, OWASP Dependency-Check) to identify vulnerabilities.
4. Map direct and transitive dependencies using SBOM generation tools.
5. Identify abandoned dependencies (no commits in 2+ years).
6. Analyze dependency update history and compliance with update policies.
7. Identify single-maintainer dependencies and assess bus factor risk.
8. Document all dependency risks with remediation recommendations.

**Deliverable**: A software dependency chain audit report with vulnerability assessments and risk ratings.

### Lab 4: Vendor Access Review

**Objective**: Assess vendor access patterns and identify excessive privileges.

**Steps**:
1. Identify all vendor accounts in the target's identity management system.
2. Analyze access logs for each vendor account over the past 90 days.
3. Identify dormant accounts (no access in 90+ days).
4. Identify excessive access privileges (administrative access, access to unrelated systems).
5. Compare actual access patterns against contractual scope.
6. Test for access control weaknesses (rate limiting, segmentation, monitoring).
7. Assess vendor access lifecycle management (onboarding, offboarding, reviews).
8. Document all vendor access findings with risk assessments and recommendations.

**Deliverable**: A vendor access review report with excessive privilege findings and remediation recommendations.

### Lab 5: CDN and WAF Risk Assessment

**Objective**: Assess the risks associated with shared CDN and WAF infrastructure.

**Steps**:
1. Identify the CDN provider through DNS and HTTP header analysis.
2. Analyze CDN configuration for shared versus dedicated resources.
3. Test WAF bypass techniques and assess cross-tenant impact.
4. Analyze cache behavior for potential cache poisoning vulnerabilities.
5. Assess origin shielding and origin IP exposure.
6. Test DDoS protection and rate limiting configuration.
7. Analyze CDN provider's security practices and tenant isolation.
8. Document all CDN/WAF risks with mitigation recommendations.

**Deliverable**: A CDN/WAF risk assessment report with cross-tenant risk analysis and mitigation recommendations.

## Ethics and Legal Considerations

### Authorization Boundaries

Supply chain asset mapping must be conducted within authorized boundaries. This means: only analyzing publicly available information (DNS records, HTTP headers, public certificates, public code repositories), not accessing private systems or data, not exploiting discovered vulnerabilities without authorization, not conducting denial-of-service testing against vendor infrastructure, and complying with all applicable laws and regulations. Supply chain mapping is reconnaissance—it identifies relationships and risks but does not exploit them. Exploitation of supply chain vulnerabilities requires separate authorization and legal review.

### Privacy Considerations

Supply chain asset mapping may involve personal data (employee information, vendor employee information). Handle personal data with care: minimize data collection to what is necessary for the assessment, anonymize personal data in reports where possible, do not share personal data with unauthorized parties, and comply with data protection regulations (GDPR, CCPA). Vendor employee information discovered through social media or public records should be handled with the same care as target employee information.

### Ethical Guidelines

Follow these ethical guidelines for supply chain asset mapping: never exploit discovered supply chain vulnerabilities without explicit authorization, never access private vendor systems or data, never disrupt vendor services during testing, never share supply chain intelligence with unauthorized parties, always document your methods and sources, always obtain proper authorization before testing supply chain controls, and always respect the privacy and rights of all organizations in the supply chain. Supply chain intelligence supports security assessment—it does not justify unauthorized access or exploitation.

### Legal Compliance

Supply chain asset mapping must comply with: computer fraud and abuse laws (CFAA, Computer Misuse Act), privacy laws (GDPR, CCPA), industry-specific regulations (HIPAA, PCI DSS), and contractual obligations (vendor agreements, non-disclosure agreements). Supply chain analysis may reveal confidential business relationships that are protected by contractual obligations. Consult legal counsel before conducting supply chain asset mapping, especially when: analyzing vendor relationships, assessing vendor security, or disclosing supply chain risks. Legal compliance is a fundamental requirement of professional security assessment.

## Cheat Sheet

### Quick Reference: Supply Chain Discovery Methods

| Method | Data Source | Risk Level | Speed | Depth |
|--------|-------------|------------|-------|-------|
| DNS Analysis | DNS records | Low | Fast | Infrastructure |
| HTTP Header Analysis | HTTP responses | Low | Fast | Technology |
| SSL Certificate Analysis | CT logs | Low | Fast | Infrastructure |
| JavaScript Analysis | Web pages | Low | Medium | Dependencies |
| Reverse IP Lookup | IP databases | Low | Fast | Shared Hosting |
| Package Manager Analysis | Code repositories | Low | Medium | Dependencies |
| SEC Filing Analysis | Financial filings | Low | Slow | Business Relations |
| Job Posting Analysis | Job boards | Low | Medium | Technology |
| Social Media Analysis | Social platforms | Low | Medium | Relationships |
| API Traffic Analysis | Network traffic | Medium | Slow | Integrations |

### Key Commands

```bash
# DNS Infrastructure Analysis
dig target.com ANY
dig target.com MX
dig target.com NS
dig target.com TXT

# Reverse IP Lookup
dig -x <IP_ADDRESS>
host <IP_ADDRESS>

# Certificate Transparency Search
curl "https://crt.sh/?q=%.target.com"

# HTTP Header Analysis
curl -I https://target.com
curl -s -D- https://target.com | head -50

# JavaScript Dependency Analysis
npm audit
pip-audit
safety check

# Package.json Analysis
cat package.json | jq '.dependencies'
cat package.json | jq '.devDependencies'

# Reverse Whois Lookup
whois <IP_ADDRESS>

# Subdomain Enumeration
sublist3r -d target.com
amass enum -d target.com
```

### Supply Chain Risk Assessment Checklist

- [ ] All direct vendors identified and categorized
- [ ] Third-party JavaScript dependencies cataloged
- [ ] Shared infrastructure identified (hosting, CDN, WAF)
- [ ] Software dependencies scanned for vulnerabilities
- [ ] Vendor access patterns reviewed
- [ ] Data flows to third-party vendors mapped
- [ ] Vendor security posture assessed
- [ ] Critical dependencies identified and risk-rated
- [ ] Single points of failure identified
- [ ] Compliance implications assessed
- [ ] Monitoring plan established for supply chain changes
- [ ] Incident response procedures updated for supply chain scenarios
