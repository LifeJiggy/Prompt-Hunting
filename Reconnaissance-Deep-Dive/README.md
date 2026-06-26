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

## Categories

All 50 prompts are organized into 10 categories for systematic use.

### Category 1: Subdomain & DNS (3 files)

| # | File | Description |
|---|------|-------------|
| 01 | `01-Advanced-Subdomain-Enumeration.md` | Comprehensive subdomain discovery via CT logs, brute-force, permutation, and recursive enumeration |
| 16 | `16-DNS-Enumeration-Advanced.md` | Deep DNS record analysis, zone transfer attempts, DNS security assessment |
| 17 | `17-Certificate-Transparency-Logs.md` | CT log mining for subdomain and infrastructure discovery |

### Category 2: OSINT & Passive Recon (8 files)

| # | File | Description |
|---|------|-------------|
| 02 | `02-Passive-OSINT-Collection.md` | Multi-source passive intelligence gathering without direct target interaction |
| 18 | `18-Historical-Data-Analysis.md` | Wayback Machine, DNS history, historical technology changes |
| 19 | `19-Social-Media-OSINT.md` | Social media intelligence for personnel and organizational mapping |
| 20 | `20-Employee-Linked-Assets.md` | Employee-associated infrastructure, personal domains, and digital footprints |
| 22 | `22-Web-Archive-Analysis.md` | Deep web archive mining for leaked data and historical content |
| 23 | `23-Pastebin-and-Leak-Searching.md` | Paste site monitoring and breach data correlation |
| 32 | `32-Email-Address-Harvesting.md` | Email address discovery and validation across multiple sources |
| 33 | `33-Phone-Number-Enumeration.md` | Phone number discovery for social engineering and MFA assessment |

### Category 3: Active Discovery & Enumeration (6 files)

| # | File | Description |
|---|------|-------------|
| 03 | `03-Active-Asset-Discovery.md` | Active host discovery, port scanning, and service enumeration |
| 10 | `10-Content-Discovery-Automation.md` | Automated hidden content discovery across web applications |
| 11 | `11-Directory-Brute-Forcing.md` | Systematic directory and file path enumeration |
| 26 | `26-IoT-Device-Discovery.md` | IoT and embedded device discovery on network perimeters |
| 31 | `31-XML-RPC-and-SOAP-Discovery.md` | Legacy API endpoint discovery and testing |
| 48 | `48-Debug-Endpoint-Discovery.md` | Debug interfaces, development tools, and admin panels |

### Category 4: Fingerprinting & Technology ID (6 files)

| # | File | Description |
|---|------|-------------|
| 04 | `04-Technology-Stack-Fingerprinting.md` | Web server, framework, and technology stack identification |
| 09 | `09-Version-Detection-Techniques.md` | Software version fingerprinting for CVE correlation |
| 41 | `41-Content-Management-System-Detection.md` | CMS identification across WordPress, Drupal, Joomla, and custom platforms |
| 42 | `42-Framework-and-Library-Identification.md` | Frontend and backend framework/library detection |
| 43 | `43-Server-Configuration-Analysis.md` | Server configuration weakness identification |
| 44 | `44-SSL-TLS-Certificate-Analysis.md` | Certificate chain analysis, cipher suite assessment, TLS misconfigurations |

### Category 5: Cloud Resources (2 files)

| # | File | Description |
|---|------|-------------|
| 05 | `05-Cloud-Resource-Enumeration.md` | AWS, Azure, GCP resource enumeration and misconfiguration detection |
| 25 | `25-Container-Registry-Enumeration.md` | Docker Hub, GHCR, ECR, ACR registry enumeration for exposed images |

### Category 6: API Discovery (5 files)

| # | File | Description |
|---|------|-------------|
| 06 | `06-API-Endpoint-Discovery.md` | REST API endpoint discovery and documentation |
| 28 | `28-API-Documentation-Extraction.md` | Swagger, OpenAPI, and Postman collection extraction |
| 29 | `29-WebSocket-Endpoint-Discovery.md` | WebSocket endpoint discovery and testing |
| 30 | `30-GraphQL-Introspection.md` | GraphQL schema extraction and vulnerability assessment |
| 45 | `45-HTTP-Header-Intelligence.md` | HTTP header analysis for server info, security headers, and technology leaks |

### Category 7: Code & Source Analysis (5 files)

| # | File | Description |
|---|------|-------------|
| 07 | `07-JavaScript-Source-Analysis.md` | Client-side JavaScript analysis for endpoints, secrets, and logic |
| 08 | `08-Configuration-File-Extraction.md` | Configuration file discovery and sensitive data extraction |
| 14 | `14-Source-Code-Leak-Detection.md` | Source code exposure detection across multiple vectors |
| 15 | `15-Git-Repository-Analysis.md` | .git exposure, commit history analysis, and secret extraction |
| 24 | `24-Code-Repository-Mining.md` | GitHub, GitLab, Bitbucket mining for secrets and internal data |

### Category 8: Configuration & Security Headers (5 files)

| # | File | Description |
|---|------|-------------|
| 12 | `12-File-Type-Detection.md` | File type identification and content-type analysis |
| 13 | `13-Backup-File-Discovery.md` | Backup file discovery including common naming patterns |
| 46 | `46-Cookie-Analysis-and-Session-Management.md` | Session token analysis, cookie security, and authentication flow mapping |
| 47 | `47-Error-Page-Analysis.md` | Error page analysis for information disclosure and stack traces |
| 49 | `49-Staging-Environment-Detection.md` | Development, staging, and QA environment discovery |

### Category 9: Enterprise & Organizational Recon (8 files)

| # | File | Description |
|---|------|-------------|
| 21 | `21-Third-Party-Integration-Discovery.md` | Third-party service and SaaS integration mapping |
| 27 | `27-Mobile-App-Analysis.md` | Mobile application analysis for API endpoints and hardcoded secrets |
| 34 | `34-Physical-Location-Intelligence.md` | Physical location intelligence from digital artifacts |
| 35 | `35-Supply-Chain-Asset-Mapping.md` | Supply chain and vendor dependency mapping |
| 36 | `36-Competitor-Analysis.md` | Competitive intelligence for parallel attack surface discovery |
| 37 | `37-Partner-Network-Discovery.md` | Partner and affiliate network infrastructure mapping |
| 38 | `38-Acquisition-Target-Analysis.md` | Acquisition target infrastructure analysis |
| 39 | `39-Subsidiary-Asset-Mapping.md` | Subsidiary and division asset enumeration |

### Category 10: Advanced Techniques & Strategy (3 files)

| # | File | Description |
|---|------|-------------|
| 40 | `40-Regional-Infrastructure-Mapping.md` | Geographic and regional infrastructure distribution analysis |
| 50 | `50-Advanced-Reconnaissance-Strategy.md` | Master methodology combining all techniques into operational workflows |

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

## Tool Coverage Matrix

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

## Customization

### Adding New Prompts

Follow the existing numbering convention: `XX-Topic-Name.md`. Update `registry.json` with the new entry.

### Modifying Existing Prompts

Each prompt is designed to be self-contained. Modify the methodology, tools, or workflow as needed for your specific use case.

### Combining Prompts

Prompts can be chained. For example, output from `01-Advanced-Subdomain-Enumeration.md` feeds directly into `03-Active-Asset-Discovery.md` for live host verification.

---

## Ethical Guidelines

This collection is designed for **authorized security testing only**:

- Always obtain written authorization before testing
- Follow bug bounty program rules and scope
- Respect rate limits and do not cause denial of service
- Do not access or modify data without permission
- Report findings responsibly through proper channels
- Comply with all applicable laws and regulations

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
