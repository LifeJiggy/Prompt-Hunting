# Prompt-Hunting

**A Comprehensive Bug Bounty Hunting Framework**

An advanced AI-powered prompt library and structured learning framework for bug bounty hunters, security researchers, and penetration testers. Built for practical, real-world vulnerability discovery across web, mobile, cloud, IoT, and blockchain targets.

This repository contains **572 files** with **400,000+ lines** of security content spanning **12 specialized categories**. Every prompt is designed to be immediately actionable with step-by-step methodologies, tool configurations, real-world case studies, and reporting templates.

---

## Table of Contents

- [Repository Overview](#repository-overview)
- [Folder Structure](#folder-structure)
- [Detailed Folder Breakdown](#detailed-folder-breakdown)
- [Who This Is For](#who-this-is-for)
- [Learning Paths](#learning-paths)
- [Quick Start](#quick-start)
- [Vulnerability Coverage](#vulnerability-coverage)
- [Tool Integration](#tool-integration)
- [Supported Platforms](#supported-platforms)
- [Content Structure](#content-structure)
- [Repository Statistics](#repository-statistics)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## Repository Overview

```
Prompt-Hunting/
├── Core-Prompts-Learning/          # 50 files  | 661-1802 lines | Educational modules
├── Core-Prompts-hunting/           # 50 files  | 504-1528 lines | Hunting methodologies
├── Reconnaissance-Deep-Dive/       # 50 files  | 480-1297 lines | Advanced recon techniques
├── Advanced-Chaining-Techniques/   # 50 files  | 399-1120 lines | 200+ attack chains
├── Report-Writing-Mastery/         # 54 files  | 400-1200 lines | Report templates
├── Automation-Efficiency/          # 50 files  | 293-2331 lines | Workflow automation
├── Advanced-Automation/            # 49 files  | 531-1643 lines | CI/CD, custom tools
├── Specialized-Targets/            # 50 files  | 499-1698 lines | Target-specific guides
├── Real-World-Case-Studies/        # 50 files  | 440-1038 lines | Disclosed report analysis
├── High-Level-World-Case-Studies/  # 46 files  | 600-938 lines  | Major breach analysis
├── Bug-Bounty-Program-Strategy/    # 50 files  | 600-1176 lines | Strategy guides
├── bug-bounty-support/             # 23 files  | 253-1068 lines | Support prompts
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

---

## Folder Structure

### Core Learning & Hunting

| Folder | Files | Lines | Focus | Key Topics |
|--------|-------|-------|-------|------------|
| `Core-Prompts-Learning/` | 50 | 661-1802 | Education | Structured learning modules with exercises, assessments, progressive difficulty |
| `Core-Prompts-hunting/` | 50 | 504-1528 | Practice | 50 vulnerability classes with step-by-step hunting methodologies |
| `Reconnaissance-Deep-Dive/` | 50 | 480-1297 | Recon | Subdomain enumeration, OSINT, fingerprinting, API discovery, asset mapping |

### Advanced Techniques

| Folder | Files | Lines | Focus | Key Topics |
|--------|-------|-------|-------|------------|
| `Advanced-Chaining-Techniques/` | 50 | 399-1120 | Chaining | 200+ documented attack chains, multi-step exploits, impact escalation |
| `Advanced-Automation/` | 49 | 531-1643 | Automation | CI/CD pipelines, custom tooling, scaling operations, infrastructure as code |
| `Automation-Efficiency/` | 50 | 293-2331 | Efficiency | Workflow optimization, tool chaining, monitoring, deployment, database automation |

### Real-World Analysis

| Folder | Files | Lines | Focus | Key Topics |
|--------|-------|-------|-------|------------|
| `Real-World-Case-Studies/` | 50 | 440-1038 | Cases | 50 analyzed disclosed reports from HackerOne, Bugcrowd, and other platforms |
| `High-Level-World-Case-Studies/` | 46 | 600-938 | Breaches | Major incident analysis, impact assessment, lessons learned |

### Strategy & Reporting

| Folder | Files | Lines | Focus | Key Topics |
|--------|-------|-------|-------|------------|
| `Bug-Bounty-Program-Strategy/` | 50 | 600-1176 | Strategy | Program selection, ROI optimization, time management, career development |
| `Report-Writing-Mastery/` | 54 | 400-1200 | Reporting | Templates, impact framing, triage strategy, acceptance optimization |

### Specialized & Support

| Folder | Files | Lines | Focus | Key Topics |
|--------|-------|-------|-------|------------|
| `Specialized-Targets/` | 50 | 499-1698 | Targets | IoT, mobile, cloud, Kubernetes, blockchain, DeFi, healthcare, industrial |
| `bug-bounty-support/` | 23 | 253-1068 | Support | Master prompts, vulnerability detection, exploitation, PoC generation |

---

## Detailed Folder Breakdown

### Core-Prompts-Learning/ (50 files, 661-1802 lines)

Educational modules designed for progressive learning. Each file covers a specific security topic with:

- **Learning Objectives** — What you'll master
- **Prerequisites** — Required knowledge
- **Concepts** — Foundational theory
- **Exercises** — Hands-on practice
- **Assessment** — Knowledge verification
- **Advanced Topics** — Expert-level material

**Topics covered:** XSS, SQLi, SSRF, CSRF, IDOR, authentication bypass, authorization flaws, race conditions, file upload, deserialization, XXE, SSTI, command injection, business logic, subdomain takeover, cloud security, API security, and more.

### Core-Prompts-hunting/ (50 files, 504-1528 lines)

Practical hunting prompts for each vulnerability class. Each file includes:

- **Attack Surface** — Where to find the vulnerability
- **Detection Patterns** — How to identify vulnerable endpoints
- **Exploitation Steps** — Step-by-step exploitation methodology
- **Tool Configurations** — Exact commands for Burp Suite, sqlmap, nuclei, etc.
- **Bypass Techniques** — How to evade WAFs and security controls
- **Real-World Examples** — Analyzed disclosed reports
- **Impact Assessment** — Business and technical impact
- **Reporting Templates** — Ready-to-use submission formats

### Reconnaissance-Deep-Dive/ (50 files, 480-1297 lines)

Advanced reconnaissance techniques for mapping attack surfaces:

- **Subdomain Enumeration** — subfinder, amass, assetfinder, DNS brute-forcing
- **OSINT** — Google dorking, GitHub dorking, Shodan, Censys
- **Fingerprinting** — Technology detection, WAF identification, version detection
- **API Discovery** — Swagger/OpenAPI enumeration, GraphQL introspection
- **Asset Discovery** — Live host detection, port scanning, service enumeration
- **Source Code Analysis** — Git history, exposed config files, secret scanning

### Advanced-Chaining-Techniques/ (50 files, 399-1120 lines)

Vulnerability chaining for maximum impact:

- **XSS Chains** — XSS + CSRF → account takeover, XSS + SSRF → data exfiltration
- **IDOR Chains** — IDOR + auth bypass → admin access, IDOR + info leak → PII exposure
- **SSRF Chains** — SSRF + cloud metadata → credential theft, SSRF + internal services → RCE
- **Business Logic Chains** — Price manipulation + race condition → free purchases
- **Authentication Chains** — Password reset + host header injection → account takeover
- **200+ documented attack chains** with real-world examples

### Report-Writing-Mastery/ (54 files, 400-1200 lines)

High-acceptance report writing:

- **Report Structure** — Title, impact statement, steps to reproduce, impact
- **Impact Framing** — Business impact language, severity justification
- **Triage Strategy** — Understanding triager psychology, common rejection reasons
- **Platform-Specific** — HackerOne, Bugcrowd, Intigriti, Immunefi templates
- **CVSS Scoring** — Accurate severity assessment
- **Resubmission** — How to handle rejections and downgrades

### Automation-Efficiency/ (50 files, 293-2331 lines)

Workflow automation and tool integration:

| Sub-Category | Files | Key Topics |
|--------------|-------|------------|
| **Workflow Design** | 01-10 | Task orchestration, tool chaining, API integration, notifications, dashboards |
| **Management** | 11-15 | Target management, deduplication, false positive reduction, parallel processing |
| **Reliability** | 16-20 | Error handling, performance monitoring, scalability, testing, deployment |
| **Configuration** | 21-26 | Config management, version control, collaboration, knowledge base, learning |
| **Data & Security** | 27-31 | Rate limiting, storage, backup, security, cost optimization |
| **Maintenance** | 32-35 | Updates, documentation, testing workflows, debugging |
| **Operations** | 36-40 | Benchmarking, security assessment, compliance, disaster recovery, metrics |
| **Integration** | 41-45 | Optimization, tool integration, custom APIs, database, network |
| **Infrastructure** | 46-50 | Cloud automation, containers, orchestration, standards, architecture |

### Advanced-Automation/ (49 files, 531-1643 lines)

Advanced automation capabilities:

- **CI/CD Pipelines** — GitHub Actions, GitLab CI, Jenkins for security testing
- **Custom Tool Development** — Building custom scanners and analysis tools
- **Scaling Operations** — Distributed scanning, parallel processing, resource management
- **Infrastructure as Code** — Terraform, Ansible for security infrastructure
- **Monitoring & Alerting** — Real-time dashboards, anomaly detection, incident response

### Specialized-Targets/ (50 files, 499-1698 lines)

Target-specific security testing playbooks:

| Category | Files | Targets |
|----------|-------|---------|
| **IoT & Embedded** | 01, 23-32 | Smart devices, firmware, RTOS, embedded systems |
| **Mobile** | 02 | iOS/Android application testing |
| **Cloud & Containers** | 03-05 | AWS/Azure/GCP, Docker, Kubernetes |
| **Blockchain & DeFi** | 06-10 | Smart contracts, DeFi protocols, NFTs, Web3 |
| **Finance** | 11, 13 | Traditional finance APIs, banking systems |
| **Healthcare** | 12, 27 | Medical systems, healthcare platforms |
| **Government & Enterprise** | 14, 44-45 | Government systems, enterprise security |
| **Education** | 15, 19 | LMS platforms, educational institutions |
| **E-commerce & Social** | 16-17 | Online stores, social media platforms |
| **Industrial & Infrastructure** | 22, 26, 36-40 | ICS, SCADA, power grids, transportation |
| **Emerging Tech** | 24-25, 33-35 | Connected vehicles, autonomous systems, satellite |

### Real-World-Case-Studies/ (50 files, 440-1038 lines)

Analyzed disclosed vulnerability reports:

- **Vulnerability Analysis** — Root cause, exploitation technique, impact
- **Timeline** — Discovery to fix to bounty
- **Lessons Learned** — What hunters can learn
- **Reproduction Steps** — Detailed walkthrough
- **Severity Assessment** — CVSS scoring and justification

### High-Level-World-Case-Studies/ (46 files, 600-938 lines)

Major breach and incident analysis:

- **Incident Patterns** — Common attack vectors and methodologies
- **Impact Assessment** — Business, financial, and reputational impact
- **Lessons Learned** — Defensive takeaways
- **Prevention Strategies** — How to prevent similar incidents
- **Detection Indicators** — IOC patterns and detection rules

### Bug-Bounty-Program-Strategy/ (50 files, 600-1176 lines)

Strategic approach to bug bounty hunting:

- **Program Selection** — Finding programs with high ROI
- **Time Management** — Allocating time across programs
- **Skill Development** — Building expertise in specific areas
- **Financial Planning** — Maximizing earnings
- **Career Development** — Building a reputation
- **Community** — Networking and collaboration

### bug-bounty-support/ (23 files, 253-1068 lines)

Reference prompts and support materials:

- **Master Prompts** — Comprehensive hunting frameworks
- **Vulnerability Detection** — Pattern recognition and identification
- **Exploitation** — Proof-of-concept development
- **PoC Generation** — Creating reproduction steps
- **Reporting** — Submission templates and strategies

---

## Who This Is For

### Bug Bounty Hunters
Structured methodology for finding and reporting vulnerabilities across all major programs. From beginner to expert, this framework provides the knowledge and tools needed to succeed.

### Penetration Testers
Comprehensive attack playbooks, tool configurations, and chaining strategies for professional engagement work. Ready-to-use methodologies for common assessment types.

### Security Engineers
Defensive perspective — understanding attack patterns to build better defenses. Learn how attackers think to create more resilient systems.

### Students & Career Changers
Progressive learning path from fundamentals to expert-level exploitation. Structured curriculum with exercises and assessments.

---

## Learning Paths

### Path 1: Complete Beginner
```
Core-Prompts-Learning/ → Core-Prompts-hunting/ → Real-World-Case-Studies/ → Report-Writing-Mastery/
```

**Timeline:** 3-6 months
**Goal:** Submit your first valid report

### Path 2: Experienced Hunter
```
Reconnaissance-Deep-Dive/ → Advanced-Chaining-Techniques/ → Specialized-Targets/ → Automation-Efficiency/
```

**Timeline:** 2-4 months
**Goal:** Increase submission quality and volume

### Path 3: Offensive Specialist
```
Advanced-Chaining-Techniques/ → Advanced-Automation/ → High-Level-World-Case-Studies/
```

**Timeline:** 2-3 months
**Goal:** Master advanced exploitation and chaining

### Path 4: Recon Master
```
Reconnaissance-Deep-Dive/ → Real-World-Case-Studies/ → Core-Prompts-hunting/
```

**Timeline:** 3-5 months
**Goal:** Master attack surface mapping and discovery

### Path 5: Automation Builder
```
Automation-Efficiency/ → Advanced-Automation/ → Bug-Bounty-Program-Strategy/
```

**Timeline:** 2-4 months
**Goal:** Build scalable automation infrastructure

### Path 6: Strategic Hunter
```
Bug-Bounty-Program-Strategy/ → Specialized-Targets/ → High-Level-World-Case-Studies/
```

**Timeline:** 2-3 months
**Goal:** Optimize program selection and maximize earnings

### Path 7: Report Pro
```
Report-Writing-Mastery/ → Real-World-Case-Studies/ → Core-Prompts-hunting/
```

**Timeline:** 1-2 months
**Goal:** Write reports that get accepted

### Path 8: Target Specialist
```
Specialized-Targets/ → High-Level-World-Case-Studies/ → Reconnaissance-Deep-Dive/
```

**Timeline:** 3-6 months
**Goal:** Develop deep expertise in specific target types

---

## Quick Start

### Installation

```bash
git clone https://github.com/LifeJiggy/Prompt-Hunting.git
cd Prompt-Hunting
```

### Using with AI Assistants

1. Choose a prompt file based on your current task
2. Copy the entire prompt content
3. Paste into Claude, ChatGPT, or other AI assistant
4. Follow the structured methodology

### Using for Self-Study

1. Start with your chosen learning path
2. Work through files sequentially
3. Complete exercises and assessments
4. Practice on real targets (authorized only)

---

## Vulnerability Coverage

### Injection Attacks
| Type | Detection | Exploitation | Bypass |
|------|-----------|--------------|--------|
| SQL Injection | Error-based, blind, time-based | Data extraction, privilege escalation | WAF bypass, encoding tricks |
| NoSQL Injection | MongoDB, CouchDB, Redis | Data extraction, authentication bypass | Operator injection |
| Command Injection | OS command execution | System compromise | Filter evasion, encoding |
| LDAP Injection | Directory service manipulation | Authentication bypass | Special character encoding |
| XPath Injection | XML query manipulation | Data extraction | Parameter entity injection |
| SSTI | Template engine detection | Remote code execution | Context escape |

### XSS
| Type | Vector | Impact | Bypass |
|------|--------|--------|--------|
| Stored | Database persistence | Account takeover, data theft | DOM clobbering, mutation XSS |
| Reflected | URL parameters | Session hijacking, phishing | Filter bypass, encoding |
| DOM | Client-side JavaScript | Data exfiltration, keylogging | Sink analysis, prototype pollution |
| Mutation XSS | HTML parser quirks | Filter bypass, persistent XSS | mXSS vectors |

### Authentication & Authorization
| Type | Vector | Impact | Bypass |
|------|--------|--------|--------|
| IDOR | Direct object reference | Data exposure, account takeover | Parameter manipulation |
| Privilege Escalation | Role manipulation | Admin access | Token manipulation |
| OAuth Flaws | Redirect URI manipulation | Account takeover | State parameter bypass |
| JWT Attacks | Algorithm confusion | Authentication bypass | Key injection |
| Session Fixation | Session token injection | Account takeover | Cookie manipulation |

### Server-Side
| Type | Vector | Impact | Bypass |
|------|--------|--------|--------|
| SSRF | Internal service access | Cloud metadata, internal APIs | IP filtering bypass |
| XXE | XML parsing | Data extraction, SSRF | Blind XXE, OOB data exfil |
| Deserialization | Object manipulation | Remote code execution | Class gadget chains |
| Race Conditions | Concurrent requests | Double-spending, privilege escalation | Time-of-check to time-of-use |

### Infrastructure
| Type | Vector | Impact | Bypass |
|------|--------|--------|--------|
| Subdomain Takeover | DNS misconfiguration | Domain hijacking | CNAME verification |
| DNS Rebinding | DNS TTL manipulation | Internal network access | Multiple A records |
| Cache Poisoning | Cache key manipulation | Victim redirect, XSS | Header injection |

### Cloud
| Type | Vector | Impact | Bypass |
|------|--------|--------|--------|
| S3 Exposure | Bucket misconfiguration | Data theft | ACL manipulation |
| IAM Misconfiguration | Role assumption | Privilege escalation | Cross-account access |
| Metadata Service | SSRF to 169.254.169.254 | Credential theft | IMDSv2 bypass |

### API Security
| Type | Vector | Impact | Bypass |
|------|--------|--------|--------|
| Mass Assignment | Parameter binding | Privilege escalation | Hidden field injection |
| BOLA | Object reference manipulation | Data exposure | IDOR in API endpoints |
| GraphQL Introspection | Schema discovery | Full API mapping | Query batching |

---

## Tool Integration

### Primary Tools
| Tool | Purpose | Integration |
|------|---------|-------------|
| **Burp Suite** | Web application testing | Proxy, Repeater, Intruder, Scanner, custom extensions |
| **Nuclei** | Vulnerability scanning | Custom templates, severity filtering, targeted scans |
| **Subfinder** | Subdomain enumeration | Passive DNS, certificate transparency |
| **httpx** | HTTP probing | Technology detection, status code analysis |
| **ffuf** | Directory fuzzing | Custom wordlists, filter rules |
| **sqlmap** | SQL injection testing | Automated exploitation, database enumeration |
| **katana** | Web crawling | JavaScript analysis, form discovery |
| **Naabu** | Port scanning | Service discovery, technology fingerprinting |

### AI Assistants
| Assistant | Best For | Usage |
|-----------|----------|-------|
| **Claude** | Complex analysis, report writing | Long context, detailed reasoning |
| **ChatGPT** | Quick questions, code generation | Fast responses, broad knowledge |
| **Custom GPTs** | Specialized tasks | Domain-specific expertise |
| **Copilot** | Code assistance | Inline suggestions, automation |

### Development Tools
| Tool | Purpose | Integration |
|------|---------|-------------|
| **VS Code** | Code editing, analysis | Extensions, regex search, debugging |
| **Python** | Scripting, automation | Custom tools, API integration |
| **Git** | Version control | Collaboration, history tracking |
| **Docker** | Containerization | Isolated testing environments |

---

## Supported Platforms

### Web Applications
Full coverage of OWASP Top 10 and beyond:
- **Frontend:** XSS, DOM manipulation, client-side validation bypass
- **Backend:** SQLi, SSRF, deserialization, file upload
- **Authentication:** Session management, OAuth, JWT, MFA bypass
- **Authorization:** IDOR, privilege escalation, access control

### Mobile (iOS/Android)
- **API Testing:** REST/GraphQL endpoint analysis
- **Local Storage:** Sensitive data exposure
- **Certificate Pinning:** Bypass techniques
- **Deep Links:** URL scheme exploitation
- **Binary Analysis:** Reverse engineering, hardcoded secrets

### Cloud (AWS/Azure/GCP)
- **IAM:** Misconfiguration, privilege escalation
- **Storage:** S3/GCS/Azure Blob exposure
- **Metadata:** SSRF to credential theft
- **Serverless:** Lambda/Functions security
- **Containers:** ECS/EKS/GKE security

### Kubernetes
- **API Server:** Unauthenticated access, RBAC bypass
- **Pod Escape:** Container breakout techniques
- **Secrets:** ETCD access, secret extraction
- **Network:** Service mesh, network policy bypass
- **Supply Chain:** Image vulnerability, registry exposure

### Blockchain/DeFi
- **Smart Contracts:** Reentrancy, overflow, access control
- **DeFi Protocols:** Flash loans, oracle manipulation
- **NFTs:** Metadata manipulation, ownership bypass
- **Web3:** Wallet injection, transaction manipulation
- **Governance:** Voting manipulation, proposal hijacking

### IoT
- **Firmware:** Extraction, analysis, hardcoded credentials
- **Network:** Protocol analysis, traffic interception
- **Hardware:** JTAG, UART, debug interfaces
- **Cloud:** Backend API analysis, device management
- **Protocols:** MQTT, CoAP, Zigbee, BLE

---

## Content Structure

Every prompt in the expanded folders follows a consistent structure:

```
1. Expert Role          — Who you're talking to and their expertise
2. Core Concepts        — Foundational knowledge and theory
3. Prerequisites        — What you need before starting
4. Methodology          — Step-by-step workflow with ASCII attack flow diagrams
5. Tool Arsenal         — Exact commands and tool configurations
6. Real-World Examples  — Analyzed case studies with detailed walkthroughs
7. Bypass Techniques    — How defenses are circumvented
8. Advanced Techniques  — Expert-level strategies
9. Detection Indicators — What defenders look for
10. Impact Assessment   — Business and technical impact
11. Common Pitfalls     — Mistakes to avoid
12. Integration Points  — How topics chain together
13. Reporting Templates — Ready-to-use submission formats
14. Practice Labs       — Hands-on exercises
15. Ethics              — Responsible disclosure guidelines
16. Quick Reference     — Cheat sheets and command tables
```

---

## Repository Statistics

```
Total Files:           572
Expanded Content:      572 files (293-2331 lines each)
Total Lines:           ~400,000+ of security content
Categories:            12 specialized domains
Vuln Classes:          50+ vulnerability types covered
Attack Chains:         200+ documented chaining strategies
Case Studies:          100+ analyzed real-world reports
Tool Configs:          50+ tool integration guides
Learning Paths:        8 structured career paths
Platform Coverage:     Web, Mobile, Cloud, IoT, Blockchain, ICS, Telecom, Space
```

---

## Contributing

Contributions welcome. Open an issue or submit a pull request.

### Priority Areas
- New vulnerability classes and attack techniques
- Real-world case study analysis
- Tool integration guides
- Automation scripts and workflows
- Report templates for emerging platforms
- Specialized target playbooks

### Quality Standards
- **Depth:** Minimum 600 lines for new content
- **Structure:** Follow the established prompt template
- **Accuracy:** All technical information must be correct
- **Ethics:** Include responsible disclosure guidelines
- **Formatting:** Consistent markdown formatting

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## Disclaimer

This repository is for **authorized security testing and educational purposes only**. All techniques must be used:

- Only on systems you own or have explicit written permission to test
- In compliance with applicable laws and regulations
- Within the scope of authorized bug bounty programs
- Following responsible disclosure practices

The author assumes no liability for misuse of this material.

---

## License

MIT License

---

## Author

**ArkhAngelLifeJiggy** — [GitHub](https://github.com/LifeJiggy)

---

*Built with passion for the security community.*
