# Prompt-Hunting

**A Comprehensive Bug Bounty Hunting Framework**

An advanced AI-powered prompt library and structured learning framework for bug bounty hunters, security researchers, and penetration testers. Built for practical, real-world vulnerability discovery across web, mobile, cloud, IoT, and blockchain targets.

---

## What's Inside

| Folder | Files | Lines | Description |
|--------|-------|-------|-------------|
| `Core-Prompts-Learning/` | 50 | 661-1802 | Structured learning modules covering 50 security topics from XSS to cloud security |
| `Core-Prompts-hunting/` | 50 | 504-1528 | Practical hunting prompts for specific vulnerability classes |
| `Reconnaissance-Deep-Dive/` | 50 | 480-1297 | Advanced recon — subdomain enum, OSINT, fingerprinting, asset discovery, API mapping |
| `Advanced-Chaining-Techniques/` | 50 | 399-1120 | Vulnerability chaining for maximum impact — 200+ documented attack chains |
| `Report-Writing-Mastery/` | 54 | 400-1200 | High-acceptance report writing — templates, impact framing, triage strategy |
| `Automation-Efficiency/` | 50 | 531-1643 | Workflow automation — tool chaining, scripting, monitoring, CI/CD integration |
| `Advanced-Automation/` | 49 | 531-1643 | Advanced automation — CI/CD pipelines, custom tooling, scaling operations |
| `Specialized-Targets/` | 50 | 600+ | Target-specific playbooks — IoT, mobile, cloud, Kubernetes, blockchain, DeFi |
| `Real-World-Case-Studies/` | 50 | 440-1038 | Analyzed disclosed reports from HackerOne, Bugcrowd, and other platforms |
| `High-Level-World-Case-Studies/` | 46 | 600-938 | Major breach analysis — incident patterns, impact assessment, lessons learned |
| `Bug-Bounty-Program-Strategy/` | 50 | 600-1176 | Program selection, ROI optimization, time management, career development |
| `bug-bounty-support/` | 23 | 253-1068 | Reference prompts — master prompts, vulnerability detection, exploitation, PoC |

**Total: 572 files** across 12 specialized categories.

---

## Depth Guarantee

Every prompt in the expanded folders follows a strict structure:

- **Expert Role** — Who you're talking to
- **Core Concepts** — Foundational knowledge
- **Prerequisites** — What you need before starting
- **Methodology** — Step-by-step workflow with ASCII attack flow diagrams
- **Tool Arsenal** — Exact commands and tool configurations
- **Case Studies** — Real-world examples with detailed walkthroughs
- **Bypass Techniques** — How defenses are circumvented
- **Advanced Techniques** — Expert-level strategies
- **Detection Indicators** — What defenders look for
- **Impact Assessment** — Business and technical impact
- **Common Pitfalls** — Mistakes to avoid
- **Integration Points** — How topics chain together
- **Reporting Templates** — Ready-to-use submission formats
- **Practice Labs** — Hands-on exercises
- **Ethics** — Responsible disclosure guidelines
- **Quick Reference** — Cheat sheets and command tables

---

## Folder Deep Dive

### Core Learning & Hunting

| Folder | Focus | Key Topics |
|--------|-------|------------|
| `Core-Prompts-Learning/` | Education | Modules with exercises, assessments, progressive learning |
| `Core-Prompts-hunting/` | Practice | 50 vulnerability classes with hunting methodologies |
| `Reconnaissance-Deep-Dive/` | Recon | Subdomains, OSINT, fingerprinting, API discovery |

### Advanced Techniques

| Folder | Focus | Key Topics |
|--------|-------|------------|
| `Advanced-Chaining-Techniques/` | Chaining | 200+ attack chains, multi-step exploits |
| `Advanced-Automation/` | Automation | CI/CD, custom tools, scaling operations |
| `Automation-Efficiency/` | Efficiency | Workflow optimization, tool integration |

### Real-World Analysis

| Folder | Focus | Key Topics |
|--------|-------|------------|
| `Real-World-Case-Studies/` | Cases | 50 analyzed vulnerability reports |
| `High-Level-World-Case-Studies/` | Breaches | Major incident analysis, lessons learned |

### Strategy & Reporting

| Folder | Focus | Key Topics |
|--------|-------|------------|
| `Bug-Bounty-Program-Strategy/` | Strategy | Program selection, ROI, career development |
| `Report-Writing-Mastery/` | Reporting | Templates, impact framing, triage |

### Specialized & Support

| Folder | Focus | Key Topics |
|--------|-------|------------|
| `Specialized-Targets/` | Targets | IoT, mobile, cloud, blockchain, DeFi |
| `bug-bounty-support/` | Support | Master prompts, detection, exploitation |

---

## Who This Is For

**Bug Bounty Hunters** — Structured methodology for finding and reporting vulnerabilities across all major programs.

**Penetration Testers** — Comprehensive attack playbooks, tool configurations, and chaining strategies for engagement work.

**Security Engineers** — Defensive perspective — understanding attack patterns to build better defenses.

**Students & Career Changers** — Progressive learning path from fundamentals to expert-level exploitation.

---

## Quick Start

### New to Bug Bounty
1. Start with `Core-Prompts-Learning/` — work through all 50 modules
2. Move to `Core-Prompts-hunting/` — practice hunting specific vuln classes
3. Study `Real-World-Case-Studies/` — learn from disclosed reports
4. Use `Report-Writing-Mastery/` — write reports that get accepted

### Experienced Hunters
1. Use `Reconnaissance-Deep-Dive/` — expand your attack surface mapping
2. Study `Advanced-Chaining-Techniques/` — chain low-severity into critical
3. Specialize with `Specialized-Targets/` — IoT, cloud, blockchain, mobile
4. Optimize with `Automation-Efficiency/` — scale your operations

### Specialization Paths
| Path | Folders |
|------|---------|
| **Offensive Specialist** | Advanced-Chaining-Techniques + Advanced-Automation |
| **Recon Master** | Reconnaissance-Deep-Dive + Real-World-Case-Studies |
| **Automation Builder** | Automation-Efficiency + Advanced-Automation |
| **Strategic Hunter** | Bug-Bounty-Program-Strategy + Specialized-Targets |
| **Report Pro** | Report-Writing-Mastery + Real-World-Case-Studies |
| **Target Specialist** | Specialized-Targets + High-Level-World-Case-Studies |

---

## Supported Platforms

| Platform | Coverage |
|----------|----------|
| Web Applications | Full coverage — XSS, SQLi, SSRF, CSRF, IDOR, auth bypass, business logic |
| Mobile (iOS/Android) | API testing, deeplink analysis, local storage, certificate pinning |
| Cloud (AWS/Azure/GCP) | IAM misconfiguration, metadata abuse, S3/GCS exposure |
| Kubernetes | API server exposure, pod escape, RBAC bypass, etcd access |
| Blockchain/DeFi | Smart contract audit, reentrancy, flash loans, oracle manipulation |
| IoT | Firmware analysis, network protocols, hardware interfaces |
| GraphQL | Schema introspection, injection, authorization, batching attacks |
| API Security | REST, gRPC, WebSocket — auth, rate limiting, mass assignment |

---

## Tool Integration

These prompts work with:

- **Burp Suite** — Proxy, Repeater, Intruder, Scanner, custom extensions
- **Browser DevTools** — Network tab, Console, Sources, Application
- **VS Code** — Static analysis, regex search, extensions
- **CLI Tools** — subfinder, httpx, nuclei, ffuf, katana, sqlmap
- **AI Assistants** — Claude, ChatGPT, custom GPTs, Copilot
- **Custom Scripts** — Python, Bash automation

---

## Vulnerability Coverage

| Category | Classes Covered |
|----------|-----------------|
| Injection | SQLi, NoSQLi, Command, LDAP, XPath, Template |
| XSS | Stored, Reflected, DOM, Mutation XSS |
| Authentication | Bypass, MFA bypass, Session fixation, OAuth flaws |
| Authorization | IDOR, Privilege escalation, JWT manipulation |
| Server-Side | SSRF, XXE, SSTI, Deserialization, Race conditions |
| Client-Side | CSRF, Clickjacking, Open redirect, CORS misconfiguration |
| Cryptography | Weak algorithms, Key exposure, Padding oracle |
| Business Logic | Price manipulation, Workflow bypass, Race conditions |
| Infrastructure | Subdomain takeover, DNS rebinding, Cache poisoning |
| Cloud | S3 exposure, IAM misconfiguration, Metadata service |
| Mobile | Insecure storage, Certificate pinning, Deep links |
| API | Mass assignment, BOLA, GraphQL introspection |

---

## Repository Statistics

```
Total Files:       572
Deep Content:      572 files (253-1802 lines each)
Total Lines:       ~350,000+ of security content
Categories:        12 specialized domains
Vuln Classes:      50+ vulnerability types covered
Attack Chains:     200+ documented chaining strategies
Case Studies:      100+ analyzed real-world reports
Tool Configs:      50+ tool integration guides
```

---

## Contributing

Contributions welcome. Open an issue or submit a pull request.

**Priority areas:**
- New vulnerability classes and attack techniques
- Real-world case study analysis
- Tool integration guides
- Automation scripts and workflows
- Report templates for emerging platforms

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

**Author:** [ArkhAngelLifeJiggy](https://github.com/LifeJiggy)
