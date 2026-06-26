# Reconnaissance Deep Dive — Prompt Collection

## Overview

A comprehensive collection of 50 advanced reconnaissance prompts covering every phase of offensive security reconnaissance — from passive OSINT gathering to active infrastructure probing, from subdomain enumeration to supply chain mapping. Each prompt is a self-contained expert role definition with deep-dive methodology, tool references, and step-by-step workflows.

This collection is designed for authorized security testing, bug bounty programs, and red team engagements where thorough reconnaissance is the foundation of effective vulnerability discovery.

---

## Directory Structure

```
Reconnaissance-Deep-Dive/
├── README.md                          # This file
├── registry.json                      # Machine-readable index of all 50 prompts
├── 01-Advanced-Subdomain-Enumeration.md
├── 02-Passive-OSINT-Collection.md
├── 03-Active-Asset-Discovery.md
├── 04-Technology-Stack-Fingerprinting.md
├── 05-Cloud-Resource-Enumeration.md
├── 06-API-Endpoint-Discovery.md
├── 07-JavaScript-Source-Analysis.md
├── 08-Configuration-File-Extraction.md
├── 09-Version-Detection-Techniques.md
├── 10-Content-Discovery-Automation.md
├── 11-Directory-Brute-Forcing.md
├── 12-File-Type-Detection.md
├── 13-Backup-File-Discovery.md
├── 14-Source-Code-Leak-Detection.md
├── 15-Git-Repository-Analysis.md
├── 16-DNS-Enumeration-Advanced.md
├── 17-Certificate-Transparency-Logs.md
├── 18-Historical-Data-Analysis.md
├── 19-Social-Media-OSINT.md
├── 20-Employee-Linked-Assets.md
├── 21-Third-Party-Integration-Discovery.md
├── 22-Web-Archive-Analysis.md
├── 23-Pastebin-and-Leak-Searching.md
├── 24-Code-Repository-Mining.md
├── 25-Container-Registry-Enumeration.md
├── 26-IoT-Device-Discovery.md
├── 27-Mobile-App-Analysis.md
├── 28-API-Documentation-Extraction.md
├── 29-WebSocket-Endpoint-Discovery.md
├── 30-GraphQL-Introspection.md
├── 31-XML-RPC-and-SOAP-Discovery.md
├── 32-Email-Address-Harvesting.md
├── 33-Phone-Number-Enumeration.md
├── 34-Physical-Location-Intelligence.md
├── 35-Supply-Chain-Asset-Mapping.md
├── 36-Competitor-Analysis.md
├── 37-Partner-Network-Discovery.md
├── 38-Acquisition-Target-Analysis.md
├── 39-Subsidiary-Asset-Mapping.md
├── 40-Regional-Infrastructure-Mapping.md
├── 41-Content-Management-System-Detection.md
├── 42-Framework-and-Library-Identification.md
├── 43-Server-Configuration-Analysis.md
├── 44-SSL-TLS-Certificate-Analysis.md
├── 45-HTTP-Header-Intelligence.md
├── 46-Cookie-Analysis-and-Session-Management.md
├── 47-Error-Page-Analysis.md
├── 48-Debug-Endpoint-Discovery.md
├── 49-Staging-Environment-Detection.md
└── 50-Advanced-Reconnaissance-Strategy.md
```

---

## File Index — All 50 Prompts

| # | File | Category | Description |
|---|------|----------|-------------|
| 01 | `01-Advanced-Subdomain-Enumeration.md` | Subdomain & DNS | Comprehensive subdomain discovery via CT logs, brute-force, permutation, and recursive enumeration |
| 02 | `02-Passive-OSINT-Collection.md` | OSINT & Passive | Multi-source passive intelligence gathering without direct target interaction |
| 03 | `03-Active-Asset-Discovery.md` | Active Discovery | Active host discovery, port scanning, and service enumeration |
| 04 | `04-Technology-Stack-Fingerprinting.md` | Fingerprinting | Web server, framework, and technology stack identification |
| 05 | `05-Cloud-Resource-Enumeration.md` | Cloud Resources | AWS, Azure, GCP resource enumeration and misconfiguration detection |
| 06 | `06-API-Endpoint-Discovery.md` | API Discovery | REST API endpoint discovery and documentation extraction |
| 07 | `07-JavaScript-Source-Analysis.md` | Code & Source | Client-side JavaScript analysis for endpoints, secrets, and logic |
| 08 | `08-Configuration-File-Extraction.md` | Code & Source | Configuration file discovery and sensitive data extraction |
| 09 | `09-Version-Detection-Techniques.md` | Fingerprinting | Software version fingerprinting for CVE correlation |
| 10 | `10-Content-Discovery-Automation.md` | Active Discovery | Automated hidden content discovery across web applications |
| 11 | `11-Directory-Brute-Forcing.md` | Active Discovery | Systematic directory and file path enumeration |
| 12 | `12-File-Type-Detection.md` | Config & Headers | File type identification and content-type analysis |
| 13 | `13-Backup-File-Discovery.md` | Config & Headers | Backup file discovery including common naming patterns |
| 14 | `14-Source-Code-Leak-Detection.md` | Code & Source | Source code exposure detection across multiple vectors |
| 15 | `15-Git-Repository-Analysis.md` | Code & Source | .git exposure, commit history analysis, and secret extraction |
| 16 | `16-DNS-Enumeration-Advanced.md` | Subdomain & DNS | Deep DNS record analysis, zone transfer attempts, DNS security assessment |
| 17 | `17-Certificate-Transparency-Logs.md` | Subdomain & DNS | CT log mining for subdomain and infrastructure discovery |
| 18 | `18-Historical-Data-Analysis.md` | OSINT & Passive | Wayback Machine, DNS history, historical technology changes |
| 19 | `19-Social-Media-OSINT.md` | OSINT & Passive | Social media intelligence for personnel and organizational mapping |
| 20 | `20-Employee-Linked-Assets.md` | OSINT & Passive | Employee-associated infrastructure, personal domains, and digital footprints |
| 21 | `21-Third-Party-Integration-Discovery.md` | Enterprise Recon | Third-party service and SaaS integration mapping |
| 22 | `22-Web-Archive-Analysis.md` | OSINT & Passive | Deep web archive mining for leaked data and historical content |
| 23 | `23-Pastebin-and-Leak-Searching.md` | OSINT & Passive | Paste site monitoring and breach data correlation |
| 24 | `24-Code-Repository-Mining.md` | Code & Source | GitHub, GitLab, Bitbucket mining for secrets and internal data |
| 25 | `25-Container-Registry-Enumeration.md` | Cloud Resources | Docker Hub, GHCR, ECR, ACR registry enumeration for exposed images |
| 26 | `26-IoT-Device-Discovery.md` | Active Discovery | IoT and embedded device discovery on network perimeters |
| 27 | `27-Mobile-App-Analysis.md` | Enterprise Recon | Mobile application analysis for API endpoints and hardcoded secrets |
| 28 | `28-API-Documentation-Extraction.md` | API Discovery | Swagger, OpenAPI, and Postman collection extraction |
| 29 | `29-WebSocket-Endpoint-Discovery.md` | API Discovery | WebSocket endpoint discovery and testing |
| 30 | `30-GraphQL-Introspection.md` | API Discovery | GraphQL schema extraction and vulnerability assessment |
| 31 | `31-XML-RPC-and-SOAP-Discovery.md` | Active Discovery | Legacy API endpoint discovery and testing |
| 32 | `32-Email-Address-Harvesting.md` | OSINT & Passive | Email address discovery and validation across multiple sources |
| 33 | `33-Phone-Number-Enumeration.md` | OSINT & Passive | Phone number discovery for social engineering and MFA assessment |
| 34 | `34-Physical-Location-Intelligence.md` | Enterprise Recon | Physical location intelligence from digital artifacts |
| 35 | `35-Supply-Chain-Asset-Mapping.md` | Enterprise Recon | Supply chain and vendor dependency mapping |
| 36 | `36-Competitor-Analysis.md` | Enterprise Recon | Competitive intelligence for parallel attack surface discovery |
| 37 | `37-Partner-Network-Discovery.md` | Enterprise Recon | Partner and affiliate network infrastructure mapping |
| 38 | `38-Acquisition-Target-Analysis.md` | Enterprise Recon | Acquisition target infrastructure analysis |
| 39 | `39-Subsidiary-Asset-Mapping.md` | Enterprise Recon | Subsidiary and division asset enumeration |
| 40 | `40-Regional-Infrastructure-Mapping.md` | Advanced Techniques | Geographic and regional infrastructure distribution analysis |
| 41 | `41-Content-Management-System-Detection.md` | Fingerprinting | CMS identification across WordPress, Drupal, Joomla, and custom platforms |
| 42 | `42-Framework-and-Library-Identification.md` | Fingerprinting | Frontend and backend framework/library detection |
| 43 | `43-Server-Configuration-Analysis.md` | Fingerprinting | Server configuration weakness identification |
| 44 | `44-SSL-TLS-Certificate-Analysis.md` | Fingerprinting | Certificate chain analysis, cipher suite assessment, TLS misconfigurations |
| 45 | `45-HTTP-Header-Intelligence.md` | API Discovery | HTTP header analysis for server info, security headers, and technology leaks |
| 46 | `46-Cookie-Analysis-and-Session-Management.md` | Config & Headers | Session token analysis, cookie security, and authentication flow mapping |
| 47 | `47-Error-Page-Analysis.md` | Config & Headers | Error page analysis for information disclosure and stack traces |
| 48 | `48-Debug-Endpoint-Discovery.md` | Active Discovery | Debug interfaces, development tools, and admin panels |
| 49 | `49-Staging-Environment-Detection.md` | Config & Headers | Development, staging, and QA environment discovery |
| 50 | `50-Advanced-Reconnaissance-Strategy.md` | Advanced Techniques | Master methodology combining all techniques into operational workflows |

---

## Categories

All 50 prompts are organized into 10 categories for systematic use.

### Category 1: Subdomain & DNS (3 files)
- 01, 16, 17

### Category 2: OSINT & Passive Recon (8 files)
- 02, 18, 19, 20, 22, 23, 32, 33

### Category 3: Active Discovery & Enumeration (6 files)
- 03, 10, 11, 26, 31, 48

### Category 4: Fingerprinting & Technology ID (6 files)
- 04, 09, 41, 42, 43, 44

### Category 5: Cloud Resources (2 files)
- 05, 25

### Category 6: API Discovery (5 files)
- 06, 28, 29, 30, 45

### Category 7: Code & Source Analysis (5 files)
- 07, 08, 14, 15, 24

### Category 8: Configuration & Security Headers (5 files)
- 12, 13, 46, 47, 49

### Category 9: Enterprise & Organizational Recon (8 files)
- 21, 27, 34, 35, 36, 37, 38, 39

### Category 10: Advanced Techniques & Strategy (2 files)
- 40, 50

---

## Usage Guide

### Single Prompt Usage

Each file is a standalone prompt. Copy the full content of any file and use it directly with an LLM or paste it into your reconnaissance workflow.

```bash
# View any prompt
cat 01-Advanced-Subdomain-Enumeration.md

# Use with an LLM
cat 01-Advanced-Subdomain-Enumeration.md | llm -s "Enumerate subdomains for target.com"
```

### Systematic Workflow

For a full reconnaissance engagement, follow this recommended sequence:

```
Phase 1 — Passive Intelligence (no target contact)
├── 02  Passive OSINT Collection
├── 18  Historical Data Analysis
├── 19  Social Media OSINT
├── 20  Employee-Linked Assets
├── 23  Pastebin and Leak Searching
├── 24  Code Repository Mining
├── 32  Email Address Harvesting
└── 33  Phone Number Enumeration

Phase 2 — Infrastructure Discovery (light touch)
├── 01  Advanced Subdomain Enumeration
├── 16  DNS Enumeration Advanced
├── 17  Certificate Transparency Logs
├── 40  Regional Infrastructure Mapping
└── 44  SSL/TLS Certificate Analysis

Phase 3 — Active Enumeration
├── 03  Active Asset Discovery
├── 04  Technology Stack Fingerprinting
├── 09  Version Detection Techniques
├── 41  CMS Detection
├── 42  Framework and Library Identification
└── 45  HTTP Header Intelligence

Phase 4 — Content Discovery
├── 06  API Endpoint Discovery
├── 07  JavaScript Source Analysis
├── 08  Configuration File Extraction
├── 10  Content Discovery Automation
├── 11  Directory Brute-Forcing
├── 12  File Type Detection
├── 13  Backup File Discovery
├── 28  API Documentation Extraction
├── 29  WebSocket Endpoint Discovery
├── 30  GraphQL Introspection
├── 31  XML-RPC and SOAP Discovery
└── 48  Debug Endpoint Discovery

Phase 5 — Deep Analysis
├── 14  Source Code Leak Detection
├── 15  Git Repository Analysis
├── 22  Web Archive Analysis
├── 25  Container Registry Enumeration
├── 27  Mobile App Analysis
├── 43  Server Configuration Analysis
├── 46  Cookie Analysis and Session Management
├── 47  Error Page Analysis
└── 49  Staging Environment Detection

Phase 6 — Enterprise & Supply Chain
├── 05  Cloud Resource Enumeration
├── 21  Third-Party Integration Discovery
├── 26  IoT Device Discovery
├── 34  Physical Location Intelligence
├── 35  Supply Chain Asset Mapping
├── 36  Competitor Analysis
├── 37  Partner Network Discovery
├── 38  Acquisition Target Analysis
└── 39  Subsidiary Asset Mapping

Phase 7 — Strategy & Synthesis
└── 50  Advanced Reconnaissance Strategy
```

---

## Reconnaissance Methodology

Effective reconnaissance follows a structured methodology that balances thoroughness with operational efficiency. The following phase-by-phase breakdown provides a systematic approach to comprehensive target analysis.

### Phase 1: Passive Intelligence Gathering (0 direct target contact)

**Objective**: Collect maximum intelligence without touching target infrastructure.

**Key Activities**:
- Search engine dorking and cached content analysis
- Certificate Transparency log mining for subdomain discovery
- DNS history and historical record analysis
- Social media profiling and employee identification
- Code repository mining for leaked secrets and internal data
- Paste site monitoring for accidental exposures
- Public record and WHOIS data correlation

**Tools**: Subfinder, Amass (passive mode), theHarvester, Recon-ng, Shodan, Censys, FOFA

**Duration**: 15–45 minutes per target

**Output**: Initial asset inventory, email list, technology indicators, employee names

### Phase 2: Infrastructure Discovery (light touch)

**Objective**: Map the target's external infrastructure with minimal detection footprint.

**Key Activities**:
- Subdomain enumeration via multiple techniques (brute-force, permutation, recursive)
- DNS record enumeration and zone transfer testing
- SSL/TLS certificate chain analysis
- Geographic and regional infrastructure mapping
- CDN and WAF detection

**Tools**: massdns, dnsx, DNSRecon, SSLyze, testssl.sh

**Duration**: 10–30 minutes per target

**Output**: Complete subdomain list, DNS architecture map, CDN/WAF identification

### Phase 3: Active Enumeration (target contact begins)

**Objective**: Actively probe discovered assets for services, technologies, and configurations.

**Key Activities**:
- Port scanning and service enumeration
- Web server and technology stack fingerprinting
- CMS and framework identification
- HTTP header and response analysis
- Version detection for CVE correlation

**Tools**: Nmap, RustScan, Masscan, WhatWeb, Wappalyzer, Nikto

**Duration**: 30–120 minutes per target (depends on scope size)

**Output**: Service inventory, technology stack map, version information

### Phase 4: Content Discovery

**Objective**: Discover hidden content, endpoints, and attack surface.

**Key Activities**:
- Directory and file path brute-forcing
- API endpoint discovery (REST, GraphQL, WebSocket)
- JavaScript source code analysis for endpoints and secrets
- Configuration file and backup file discovery
- Debug endpoint and staging environment detection

**Tools**: ffuf, Gobuster, Feroxbuster, Arjun, LinkFinder, SecretFinder

**Duration**: 45–180 minutes per target

**Output**: Hidden paths, API endpoints, leaked secrets, configuration files

### Phase 5: Deep Analysis

**Objective**: Analyze discovered assets for vulnerabilities and misconfigurations.

**Key Activities**:
- Source code leak detection and analysis
- Git repository exposure and commit history analysis
- Container registry enumeration for exposed images
- Mobile application analysis for hardcoded secrets
- Server configuration weakness identification
- Session management and cookie security analysis
- Error page information disclosure analysis

**Tools**: GitLeaks, TruffleHog, Trivy, Grype, ScoutSuite

**Duration**: 60–240 minutes per target

**Output**: Leaked credentials, vulnerable configurations, exposed containers

### Phase 6: Enterprise & Supply Chain

**Objective**: Map organizational relationships and third-party dependencies.

**Key Activities**:
- Cloud resource enumeration (AWS, Azure, GCP)
- Third-party SaaS integration discovery
- Supply chain and vendor dependency mapping
- Partner and subsidiary asset enumeration
- Physical location intelligence gathering

**Tools**: Prowler, CloudEnum, ScoutSuite, manual OSINT

**Duration**: 30–120 minutes per target

**Output**: Cloud inventory, third-party dependencies, supply chain map

### Phase 7: Synthesis & Strategy

**Objective**: Consolidate findings and develop attack strategy.

**Key Activities**:
- Asset prioritization by risk and accessibility
- Attack path identification and ranking
- Gap analysis for additional reconnaissance
- Documentation and reporting
- Strategic recommendations for vulnerability testing

**Duration**: 15–30 minutes

**Output**: Prioritized attack surface, recommended testing approach

---

## Tool Coverage Matrix

The prompts reference tools across the following categories:

| Recon Phase | Primary Tools | Secondary Tools |
|-------------|---------------|-----------------|
| **Passive OSINT** | theHarvester, Recon-ng, SpiderFoot | Maltego, OSINT Framework |
| **Subdomain Enum** | Amass, Subfinder, massdns | DNSRecon, dnsx, Knockpy, Sublist3r |
| **Network Scanning** | Nmap, RustScan, Masscan | Unicornscan, Netcat |
| **Web Fuzzing** | ffuf, Gobuster, Feroxbuster | ffuf, Wfuzz, dirsearch |
| **Technology ID** | Wappalyzer, WhatWeb | BuiltWith, Netcraft |
| **API Discovery** | Arjun, Postman, Swagger Scanner | ffuf (parameter mode) |
| **Code Analysis** | GitLeaks, TruffleHog | LinkFinder, SecretFinder, JSLuice |
| **SSL/TLS Testing** | testssl.sh, SSLyze | ssllabs-scan, testssl.sh |
| **Cloud Security** | ScoutSuite, Prowler | CloudEnum, Pacu |
| **Container Scanning** | Trivy, Grype | Docker Bench Security |
| **OSINT Search** | Shodan, Censys, FOFA | ZoomEye, BinaryEdge |
| **DNS Analysis** | DNSRecon, dnsx | dig, nslookup, host |

The prompts reference tools across the following categories:

### DNS & Subdomain Tools
- **Amass** — Comprehensive subdomain enumeration
- **Subfinder** — Fast passive subdomain discovery
- **massdns** — High-performance DNS resolver
- **DNSRecon** — DNS enumeration and zone transfer
- **dnsx** — DNS toolkit for probing
- **Knockpy** — Subdomain scanning
- **Sublist3r** — Subdomain brute-forcing

### Network Scanning
- **Nmap** — Port scanning and service detection
- **RustScan** — Fast port scanner
- **Masscan** — Mass IP port scanner
- **Unicornscan** — Asynchronous TCP/UDP scanner

### Web Application Tools
- **ffuf** — Web fuzzer
- **Gobuster** — Directory/file brute-forcer
- **Feroxbuster** — Recursive content discovery
- **Arjun** — Parameter discovery
- **Wappalyzer** — Technology detection
- **WhatWeb** — Web technology identification
- **Nikto** — Web server scanner

### OSINT Tools
- **theHarvester** — Email and subdomain harvesting
- **Maltego** — OSINT and graphical link analysis
- **Recon-ng** — Web reconnaissance framework
- **SpiderFoot** — OSINT automation
- **Shodan** — Internet-connected device search
- **Censys** — Internet-wide scanning
- **FOFA** — Chinese cyberspace search engine

### Cloud & Container
- **ScoutSuite** — Multi-cloud security auditing
- **Prowler** — AWS security assessment
- **CloudEnum** — Cloud resource enumeration
- **Trivy** — Container vulnerability scanner
- **Grype** — Container image scanner

### Code Analysis
- **GitLeaks** — Secret detection in git repos
- **TruffleHog** — Git repository scanning
- **LinkFinder** — JavaScript endpoint discovery
- **SecretFinder** — Secret extraction from JS
- **JSLuice** — JavaScript analysis toolkit

### SSL/TLS
- **testssl.sh** — SSL/TLS testing
- **SSLyze** — SSL configuration analyzer
- **ssllabs-scan** — SSL Labs API client

---

## Prompt Structure

Each prompt follows a consistent structure:

1. **Expert Role Definition** — Defines the persona and expertise domain
2. **Core Concepts Deep Dive** — Foundational knowledge and theory
3. **Pre-requisite Knowledge** — What the operator should know before using the prompt
4. **Step-by-Step Methodology** — Phased approach with concrete steps
5. **Tools and Commands** — Specific tool usage with command examples
6. **Common Pitfalls** — Mistakes to avoid
7. **Advanced Techniques** — Expert-level methods beyond the basics
8. **Detection and Evasion** — Stealth considerations and OPSEC
9. **Automation Opportunities** — Scripting and pipeline integration
10. **Documentation and Reporting** — How to document findings

---

## Common Recon Mistakes

Avoid these frequent errors that reduce reconnaissance effectiveness and increase detection risk.

### 1. Skipping Passive Reconnaissance

**Mistake**: Jumping directly to active scanning without gathering passive intelligence first.

**Impact**: Missed assets, increased detection footprint, incomplete attack surface map.

**Fix**: Always complete Phase 1 (passive OSINT) before any target contact.

### 2. Ignoring Rate Limits

**Mistake**: Running aggressive scans without respecting rate limits or implementing delays.

**Impact**: IP blocking, WAF triggering, service disruption, legal issues.

**Fix**: Implement exponential backoff, use distributed scanning, respect robots.txt.

### 3. Not Documenting Findings

**Mistake**: Running scans without saving results or maintaining structured logs.

**Impact**: Lost intelligence, duplicated effort, inability to correlate findings.

**Fix**: Use structured output formats (JSON, CSV), maintain a recon database.

### 4. Overlooking Subdomains

**Mistake**: Only testing the primary domain without comprehensive subdomain enumeration.

**Impact**: Missed staging environments, forgotten applications, expanded attack surface.

**Fix**: Use multiple subdomain enumeration techniques (CT logs, brute-force, permutation).

### 5. Ignoring Historical Data

**Mistake**: Focusing only on current state without analyzing historical changes.

**Impact**: Missed decommissioned assets, leaked credentials in old commits, forgotten endpoints.

**Fix**: Use Wayback Machine, DNS history, and git history analysis.

### 6. Insufficient Technology Fingerprinting

**Mistake**: Identifying the web server but not the full technology stack.

**Impact**: Missed framework-specific vulnerabilities, incorrect attack vectors.

**Fix**: Use multiple fingerprinting tools and manual analysis of HTTP headers and responses.

### 7. Not Validating Discovered Assets

**Mistake**: Accepting discovered subdomains or endpoints without verifying they are live and accessible.

**Impact**: Wasted time testing non-existent assets, missing actual targets.

**Fix**: Validate all discoveries with HTTP probing (httpx) before deep testing.

### 8. Ignoring Error Pages and Debug Endpoints

**Mistake**: Focusing only on main application while ignoring error handling and debug interfaces.

**Impact**: Missed information disclosure, stack traces, admin panels.

**Fix**: Deliberately trigger errors and probe common debug paths.

### 9. Not Analyzing JavaScript

**Mistake**: Treating JavaScript as opaque client-side code without analysis.

**Impact**: Missed API endpoints, hardcoded secrets, business logic flaws.

**Fix**: Extract and analyze all JavaScript files using LinkFinder, SecretFinder.

### 10. Insufficient Scope Understanding

**Mistake**: Testing beyond authorized scope or missing out-of-scope assets.

**Impact**: Legal issues, program violations, wasted effort.

**Fix**: Clearly document scope before testing, maintain scope checklist throughout engagement.

---

## Customization

### Adding New Prompts

Follow the existing numbering convention: `XX-Topic-Name.md`. Update `registry.json` with the new entry.

### Modifying Existing Prompts

Each prompt is designed to be self-contained. Modify the methodology, tools, or workflow as needed for your specific use case.

### Combining Prompts

Prompts can be chained. For example, output from `01-Advanced-Subdomain-Enumeration.md` feeds directly into `03-Active-Asset-Discovery.md` for live host verification.

---

## Ethical Considerations and Scope Compliance

This collection is designed for **authorized security testing only**. Strict adherence to ethical guidelines and scope compliance is mandatory for all users.

### Legal Authorization

- **Written Authorization**: Always obtain explicit written authorization before testing any target
- **Scope Documentation**: Clearly document and understand the authorized scope before beginning
- **Legal Review**: Ensure compliance with all applicable local, national, and international laws
- **Third-Party Systems**: Never test systems without explicit permission, even if they appear related to the target

### Bug Bounty Program Compliance

- **Read the Rules**: Thoroughly review program rules, scope, and allowed testing methods
- **Respect Exclusions**: Honor all explicitly excluded systems, methods, and data types
- **Follow Disclosure**: Adhere to responsible disclosure timelines and procedures
- **No Data Exfiltration**: Do not access, download, or modify user data without explicit permission
- **Report Findings**: Submit all discovered vulnerabilities through proper channels

### Operational Security (OPSEC)

- **Rate Limiting**: Implement appropriate delays between requests to avoid denial of service
- **Stealth Operations**: Minimize detection footprint where possible to avoid disrupting operations
- **Logging**: Maintain detailed logs of all testing activities for accountability
- **Proxy Usage**: Use appropriate proxy infrastructure to protect testing identity
- **Clean Environment**: Use dedicated testing environments to avoid contamination

### Data Handling

- **No PII Collection**: Minimize collection of personally identifiable information
- **Secure Storage**: Encrypt and securely store any collected sensitive data
- **Data Retention**: Delete collected data after testing completion unless otherwise required
- **Access Control**: Limit access to testing data to authorized personnel only
- **Breach Notification**: Report any unintended data exposure immediately

### Professional Conduct

- **Do No Harm**: Avoid actions that could disrupt services or cause damage
- **Proportional Testing**: Match testing intensity to authorized scope and requirements
- **Communication**: Maintain open communication with program managers and stakeholders
- **Documentation**: Provide clear, accurate documentation of all testing activities
- **Continuous Learning**: Stay updated on legal requirements and industry best practices

### Scope Management

```
Before Testing:
├── Verify authorization documents
├── Document authorized scope (domains, IPs, applications)
├── Identify excluded systems and methods
├── Establish communication channels
└── Set testing schedule and intensity limits

During Testing:
├── Monitor scope boundaries continuously
├── Log all testing activities
├── Respect rate limits and service availability
├── Pause and consult if scope questions arise
└── Document any scope anomalies or issues

After Testing:
├── Securely store collected data
├── Remove any testing artifacts from target systems
├── Submit findings through authorized channels
├── Clean up testing infrastructure
└── Document lessons learned
```

---

## Quick Reference — Findings by Attack Surface

| Attack Surface | Recommended Prompts |
|---------------|---------------------|
| Public-facing domains | 01, 16, 17, 44 |
| Web applications | 04, 06, 07, 08, 10, 11, 12, 13, 41, 42, 45, 46, 47 |
| APIs (REST/GraphQL/WS) | 06, 28, 29, 30, 31 |
| Cloud infrastructure | 05, 25 |
| Source code & repos | 07, 14, 15, 24 |
| Enterprise/organization | 19, 20, 21, 32, 33, 34, 35, 36, 37, 38, 39 |
| Staging & dev environments | 48, 49 |
| Full engagement | 50 (master strategy orchestrating all) |

---

## Performance Metrics

Typical execution times per category (single target, first pass):

| Category | Estimated Time | Parallelizable |
|----------|---------------|----------------|
| Subdomain & DNS | 10–30 min | Partially |
| OSINT & Passive | 15–45 min | Yes |
| Active Discovery | 30–120 min | Partially |
| Fingerprinting | 5–15 min | Yes |
| Cloud Resources | 10–20 min | Partially |
| API Discovery | 15–45 min | Partially |
| Code & Source Analysis | 20–60 min | Yes |
| Enterprise Recon | 30–90 min | Partially |
| Advanced Techniques | 15–30 min | Varies |

---

## Contributing

When adding new prompts:

1. Follow the established file naming convention (`XX-Topic-Name.md`)
2. Include all standard sections (Expert Role, Core Concepts, Prerequisites, Methodology)
3. Add at least one concrete tool/command example
4. Update `registry.json` with the new entry
5. Update this README with the new file in the appropriate category

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-26 | Initial release — 50 reconnaissance prompts |

---

## License

This collection is provided for authorized security testing and educational purposes. Users are responsible for ensuring compliance with all applicable laws and obtaining proper authorization before use.
