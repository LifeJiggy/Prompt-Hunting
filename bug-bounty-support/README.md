# Bug Bounty Support Domain

> Master frameworks, foundational guides, and the complete knowledge base for bug bounty hunting and security research.

## Overview

The **bug-bounty-support** domain is the backbone of the Prompt-Hunting repository. It provides 23 comprehensive documents covering every phase of bug bounty hunting — from reconnaissance through reporting. This domain is designed for security researchers, penetration testers, and bug bounty hunters who want structured, actionable guidance at every stage of their workflow.

Unlike domain-specific prompt collections, this support domain is **framework-oriented**. It establishes core methodologies, vulnerability analysis patterns, exploitation techniques, and reporting standards that underpin all other hunting activities.

---

## Table of Contents

1. [Domain Philosophy](#domain-philosophy)
2. [File Inventory](#file-inventory)
3. [Category Breakdown](#category-breakdown)
4. [Usage Patterns](#usage-patterns)
5. [Recommended Reading Order](#recommended-reading-order)
6. [Integration with Other Domains](#integration-with-other-domains)
7. [File Details](#file-details)
8. [Glossary](#glossary)

---

## Domain Philosophy

This domain follows three principles:

1. **Progressive Depth** — Documents build from foundational concepts (Core Aspects, Ethical Guidelines) to advanced exploitation (Chaining, Advanced Techniques). Start at the foundations and escalate.

2. **Tool-Agnostic Methodology** — While specific tools are referenced (Burp Suite, browser devtools, VSCode), the core methodologies apply regardless of toolchain. The `Tools-Integration.md` document bridges methodology to tooling.

3. **Actionable Output** — Every document is structured to produce actionable results: checklists, templates, PoC patterns, and decision frameworks. Passive reading is not the goal — active application is.

---

## File Inventory

| # | File | Lines | Category | Purpose |
|---|------|-------|----------|---------|
| 1 | `Advanced-Bug-Bounty-Prompt.md` | ~800 | Core Frameworks | Advanced prompt engineering for bug bounty workflows |
| 2 | `Advanced-Bug-Security-Hunting-Prompt.md` | ~900 | Vulnerability Analysis | Advanced security hunting prompt patterns |
| 3 | `Advanced-Information-Disclosure-Analysis-Prompt.md` | ~950 | Vulnerability Analysis | Information disclosure deep-dive methodology |
| 4 | `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` | ~900 | Vulnerability Analysis | JS-specific vulnerability patterns and analysis |
| 5 | `Advanced-Techniques.md` | ~1000 | Methodology | Advanced hunting techniques and bypass methods |
| 6 | `Burp-AI.md` | ~900 | Tools | Burp Suite + AI integration workflows |
| 7 | `Chaining.md` | ~900 | Methodology | Vulnerability chaining strategies and attack paths |
| 8 | `Core-Aspects-for-Bug-Security-Hunting.md` | ~850 | Core Frameworks | Foundational bug hunting principles and methodology |
| 9 | `debuging-using-browser-console-and-vscode-for-hunting.md` | ~950 | Tools | Browser console and VSCode debugging for hunting |
| 10 | `Ethical-Guidelines.md` | ~700 | Scope & Ethics | Ethical boundaries, responsible disclosure, legal considerations |
| 11 | `Exploitation.md` | ~650 | Methodology | Exploitation techniques and proof-of-concept development |
| 12 | `JavaScript-Identification-Deobfuscation.md` | ~600 | Vulnerability Analysis | JS identification, analysis, and deobfuscation |
| 13 | `manual-testing-scope.md` | ~1100 | Scope & Ethics | Manual testing scope definition and boundaries |
| 14 | `parameters.md` | ~1000 | Vulnerability Analysis | Parameter analysis, mutation, and injection testing |
| 15 | `PoC-Development.md` | ~1000 | Reporting | Proof-of-concept development and documentation |
| 16 | `Reconnaissance.md` | ~850 | Methodology | Reconnaissance techniques and asset discovery |
| 17 | `Reporting.md` | ~1100 | Reporting | Report writing, severity assessment, and submission |
| 18 | `Specific-Vulnerabilities-Hunting.md` | ~1000 | Vulnerability Analysis | Targeted hunting for specific vulnerability classes |
| 19 | `static-and-dynamic-testing.md` | ~900 | Methodology | Static and dynamic analysis methodologies |
| 20 | `to-identify-injection-and-reflected-point-during-testing.md` | ~800 | Vulnerability Analysis | Injection point identification and reflection analysis |
| 21 | `Tools-Integration.md` | ~350 | Tools | Tool integration patterns and workflows |
| 22 | `user-functionality.md` | ~250 | Scope & Ethics | User functionality mapping and attack surface |
| 23 | `Vulnerability-Detection.md` | ~250 | Vulnerability Analysis | Vulnerability detection patterns and signatures |

**Total: 23 files, ~18,000+ lines of comprehensive security research content**

---

## Category Breakdown

### Core Frameworks (2 files)
The foundational documents that establish the overall methodology and approach to bug bounty hunting.

| File | Focus |
|------|-------|
| `Advanced-Bug-Bounty-Prompt.md` | Prompt engineering techniques tailored for bug bounty workflows — structuring AI-assisted research, crafting effective queries, and leveraging AI for vulnerability discovery |
| `Core-Aspects-for-Bug-Security-Hunting.md` | The essential principles every hunter must understand — methodology, mindset, systematic approach, and the mental models that separate effective hunters from casual testers |

### Vulnerability Analysis (8 files)
Deep-dive analysis of specific vulnerability classes and testing methodologies.

| File | Focus |
|------|-------|
| `Advanced-Bug-Security-Hunting-Prompt.md` | Advanced prompt patterns for security hunting — structured approaches to complex vulnerability discovery using AI assistance |
| `Advanced-Information-Disclosure-Analysis-Prompt.md` | Information disclosure methodology — error handling analysis, verbose output, debug information leakage, and sensitive data exposure patterns |
| `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` | JavaScript-specific vulnerability patterns — prototype pollution, DOM XSS, client-side logic flaws, and JS framework-specific issues |
| `JavaScript-Identification-Deobfuscation.md` | JavaScript identification and deobfuscation techniques — analyzing minified code, identifying obfuscation patterns, and reverse-engineering client-side logic |
| `parameters.md` | Parameter analysis and mutation — IDOR testing, parameter pollution, type confusion, and injection point discovery through parameter manipulation |
| `Specific-Vulnerabilities-Hunting.md` | Targeted hunting for specific vulnerability classes — structured approaches to XSS, SQLi, SSRF, XXE, and other high-impact findings |
| `to-identify-injection-and-reflected-point-during-testing.md` | Injection point identification — discovering where user input enters application logic, reflection analysis, and context-aware injection testing |
| `Vulnerability-Detection.md` | Vulnerability detection patterns and signatures — automated and manual techniques for identifying common vulnerability indicators |

### Methodology (5 files)
Strategic approaches to the hunting process, from reconnaissance through exploitation.

| File | Focus |
|------|-------|
| `Advanced-Techniques.md` | Advanced hunting techniques — bypass methods, WAF evasion, rate limit circumvention, and edge-case exploitation strategies |
| `Chaining.md` | Vulnerability chaining — combining low/medium findings into critical attack paths, privilege escalation chains, and multi-step exploitation |
| `Exploitation.md` | Exploitation techniques — moving from discovery to proof-of-concept, impact demonstration, and practical exploitation of identified vulnerabilities |
| `Reconnaissance.md` | Reconnaissance methodology — asset discovery, subdomain enumeration, technology fingerprinting, and attack surface mapping |
| `static-and-dynamic-testing.md` | Static and dynamic analysis — source code review, SAST patterns, DAST approaches, and hybrid testing methodologies |

### Tools (3 files)
Tool-specific guidance and integration workflows.

| File | Focus |
|------|-------|
| `Burp-AI.md` | Burp Suite + AI integration — using AI to enhance Burp workflows, automated scanning patterns, and intelligent request crafting |
| `debuging-using-browser-console-and-vscode-for-hunting.md` | Browser console and VSCode debugging — JavaScript debugging techniques, breakpoints, network analysis, and code inspection for vulnerability discovery |
| `Tools-Integration.md` | Tool integration patterns — connecting various security tools into cohesive workflows, automation strategies, and toolchain optimization |

### Reporting (2 files)
Documentation, proof-of-concept development, and submission guidance.

| File | Focus |
|------|-------|
| `PoC-Development.md` | Proof-of-concept development — creating reproducible demonstrations, impact evidence, and compelling vulnerability proofs |
| `Reporting.md` | Report writing and submission — severity assessment, report structure, impact articulation, and platform-specific submission guidance |

### Scope & Ethics (3 files)
Boundaries, legal considerations, and responsible hunting practices.

| File | Focus |
|------|-------|
| `Ethical-Guidelines.md` | Ethical boundaries — responsible disclosure, legal considerations, scope limitations, and professional conduct standards |
| `manual-testing-scope.md` | Manual testing scope — defining testing boundaries, authorization requirements, and systematic scope analysis |
| `user-functionality.md` | User functionality mapping — understanding application features, user flows, and attack surface through functionality analysis |

---

## Usage Patterns

### Pattern 1: New Target Engagement
When starting a new bug bounty target, follow this sequence:

1. **Scope & Ethics** — Read `Ethical-Guidelines.md` and `manual-testing-scope.md` to establish boundaries
2. **Reconnaissance** — Apply `Reconnaissance.md` for asset discovery
3. **Core Framework** — Reference `Core-Aspects-for-Bug-Security-Hunting.md` for methodology
4. **Hunting** — Use `Specific-Vulnerabilities-Hunting.md` and `parameters.md` for targeted testing

### Pattern 2: Deep Vulnerability Analysis
When focusing on a specific vulnerability class:

1. **Identification** — `to-identify-injection-and-reflected-point-during-testing.md`
2. **Analysis** — Relevant vulnerability-specific file (e.g., `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md`)
3. **Exploitation** — `Exploitation.md` and `Chaining.md`
4. **Documentation** — `PoC-Development.md` and `Reporting.md`

### Pattern 3: Tool-Assisted Hunting
When leveraging AI and tools:

1. **Prompt Engineering** — `Advanced-Bug-Bounty-Prompt.md`
2. **Burp Integration** — `Burp-AI.md`
3. **Debugging** — `debuging-using-browser-console-and-vscode-for-hunting.md`
4. **Tool Orchestration** — `Tools-Integration.md`

### Pattern 4: Report Writing
When documenting findings:

1. **PoC Creation** — `PoC-Development.md`
2. **Report Structure** — `Reporting.md`
3. **Severity Assessment** — Reference `Core-Aspects-for-Bug-Security-Hunting.md` for impact framework

---

## Recommended Reading Order

For security researchers new to bug bounty hunting:

### Beginner Track (Week 1-2)
1. `Ethical-Guidelines.md` — Understand boundaries first
2. `Core-Aspects-for-Bug-Security-Hunting.md` — Learn the fundamentals
3. `Reconnaissance.md` — Start with recon basics
4. `manual-testing-scope.md` — Define your testing scope

### Intermediate Track (Week 3-4)
5. `parameters.md` — Master parameter analysis
6. `to-identify-injection-and-reflected-point-during-testing.md` — Find injection points
7. `Specific-Vulnerabilities-Hunting.md` — Hunt specific classes
8. `Exploitation.md` — Learn exploitation techniques

### Advanced Track (Week 5+)
9. `Advanced-Techniques.md` — Advanced bypass methods
10. `Chaining.md` — Chain vulnerabilities
11. `Advanced-Bug-Bounty-Prompt.md` — AI-assisted hunting
12. `Burp-AI.md` — Tool integration

### Specialist Track (Ongoing)
13. `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` — JS specialization
14. `JavaScript-Identification-Deobfuscation.md` — Deobfuscation skills
15. `Advanced-Information-Disclosure-Analysis-Prompt.md` — Info disclosure focus
16. `static-and-dynamic-testing.md` — Analysis methodology

---

## Integration with Other Domains

This support domain provides the foundational knowledge that enhances all other Prompt-Hunting domains:

### Web2 Vulnerability Domains
- **XSS Hunting** — Use `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` for DOM XSS patterns
- **SQL Injection** — Reference `parameters.md` for injection point discovery
- **SSRF** — Apply `Chaining.md` for SSRF-to-RCE chains
- **Authentication** — Use `manual-testing-scope.md` for auth boundary testing

### Specialized Hunting Domains
- **Cloud Security** — Foundation from `Reconnaissance.md` applies to cloud asset discovery
- **API Security** — `parameters.md` directly applicable to API parameter testing
- **Mobile Security** — `static-and-dynamic-testing.md` covers mobile analysis patterns

### Reporting Domains
- **Report Writing** — `Reporting.md` and `PoC-Development.md` are prerequisites
- **Triage Understanding** — `Core-Aspects-for-Bug-Security-Hunting.md` covers impact assessment

---

## File Details

### Advanced-Bug-Bounty-Prompt.md
**Category:** Core Frameworks | **Lines:** ~800

Comprehensive guide to prompt engineering for bug bounty workflows. Covers structuring AI queries for maximum effectiveness, crafting multi-turn research conversations, and leveraging AI capabilities for vulnerability discovery. Includes templates for common hunting scenarios and patterns for AI-assisted code review.

Key sections:
- Prompt architecture for security research
- Multi-turn conversation patterns
- AI-assisted vulnerability discovery
- Template library for common scenarios
- Error handling and edge cases

### Advanced-Bug-Security-Hunting-Prompt.md
**Category:** Vulnerability Analysis | **Lines:** ~900

Advanced prompt patterns specifically designed for security hunting workflows. Builds on the core framework to address complex vulnerability discovery scenarios. Includes patterns for hunting logic flaws, business logic vulnerabilities, and multi-step attack chains.

Key sections:
- Complex scenario prompting
- Logic flaw discovery patterns
- Business logic analysis
- Multi-step attack chain discovery
- Advanced enumeration techniques

### Advanced-Information-Disclosure-Analysis-Prompt.md
**Category:** Vulnerability Analysis | **Lines:** ~950

Deep-dive methodology for information disclosure vulnerabilities. Covers error handling analysis, verbose output patterns, debug information leakage, and sensitive data exposure. Includes systematic approaches to identifying information leakage across the entire application stack.

Key sections:
- Error message analysis
- Debug information discovery
- Stack trace extraction
- Sensitive data exposure patterns
- Cross-origin information leakage
- Server configuration disclosure

### Advanced-JavaScript-Vulnerability-Analysis-Prompt.md
**Category:** Vulnerability Analysis | **Lines:** ~900

JavaScript-specific vulnerability patterns and analysis techniques. Covers prototype pollution, DOM XSS, client-side logic flaws, and framework-specific issues in React, Angular, Vue, and other popular frameworks. Includes patterns for identifying vulnerable JavaScript libraries.

Key sections:
- Prototype pollution exploitation
- DOM-based vulnerability patterns
- Framework-specific analysis
- Client-side logic flaws
- JavaScript library vulnerability identification

### Advanced-Techniques.md
**Category:** Methodology | **Lines:** ~1000

Advanced hunting techniques that go beyond basic testing. Covers WAF bypass methods, rate limit circumvention, edge-case exploitation, and unconventional attack vectors. Includes real-world examples and practical techniques for bypassing common security controls.

Key sections:
- WAF bypass techniques
- Rate limit circumvention
- Edge-case exploitation
- Unconventional attack vectors
- Advanced encoding techniques
- Time-based blind exploitation

### Burp-AI.md
**Category:** Tools | **Lines:** ~900

Integration of Burp Suite with AI capabilities. Covers using AI to enhance Burp workflows, automated scanning patterns, intelligent request crafting, and AI-assisted analysis of Burp results. Includes practical examples and workflow templates.

Key sections:
- AI-enhanced Burp scanning
- Intelligent request crafting
- Automated analysis workflows
- Custom extensions with AI
- Result interpretation and prioritization

### Chaining.md
**Category:** Methodology | **Lines:** ~900

Vulnerability chaining strategies for combining low/medium findings into critical attack paths. Covers privilege escalation chains, multi-step exploitation, and how to maximize impact from individual findings. Includes chain templates and decision frameworks.

Key sections:
- Chain identification methodology
- Privilege escalation paths
- Multi-step exploitation
- Impact amplification techniques
- Chain documentation and presentation

### Core-Aspects-for-Bug-Security-Hunting.md
**Category:** Core Frameworks | **Lines:** ~850

The foundational document for bug bounty hunting methodology. Establishes the core principles, mental models, and systematic approaches that every hunter should internalize. Covers the hunting mindset, methodology overview, and quality standards.

Key sections:
- Hunting mindset and philosophy
- Systematic methodology
- Quality standards and metrics
- Common pitfalls and how to avoid them
- Continuous improvement framework

### debuging-using-browser-console-and-vscode-for-hunting.md
**Category:** Tools | **Lines:** ~950

Comprehensive guide to using browser developer tools and VSCode for security hunting. Covers JavaScript debugging techniques, breakpoint strategies, network analysis, DOM inspection, and code analysis for vulnerability discovery.

Key sections:
- Browser console debugging
- Network request analysis
- DOM inspection techniques
- VSCode debugging workflows
- Source code analysis
- Performance profiling for security

### Ethical-Guidelines.md
**Category:** Scope & Ethics | **Lines:** ~700

Essential ethical boundaries and responsible hunting practices. Covers legal considerations, scope limitations, responsible disclosure requirements, and professional conduct standards. Must be read before engaging any target.

Key sections:
- Legal framework and boundaries
- Scope definition and respect
- Responsible disclosure process
- Professional conduct standards
- Documentation requirements

### Exploitation.md
**Category:** Methodology | **Lines:** ~650

Techniques for moving from vulnerability discovery to practical exploitation. Covers proof-of-concept development, impact demonstration, and exploitation methodology. Bridges the gap between finding a vulnerability and proving its impact.

Key sections:
- Exploitation methodology
- Proof-of-concept development
- Impact demonstration
- Privilege escalation
- Data access techniques

### JavaScript-Identification-Deobfuscation.md
**Category:** Vulnerability Analysis | **Lines:** ~600

Techniques for identifying and analyzing obfuscated JavaScript code. Covers deobfuscation methods, code analysis patterns, and reverse-engineering client-side logic. Essential for understanding modern web applications.

Key sections:
- Obfuscation pattern identification
- Deobfuscation techniques
- Code flow analysis
- Client-side logic mapping
- Minified code analysis

### manual-testing-scope.md
**Category:** Scope & Ethics | **Lines:** ~1100

Comprehensive guide to defining and understanding testing scope. Covers scope analysis, boundary identification, authorization requirements, and systematic approach to scope-limited testing. The longest document in the domain, reflecting its importance.

Key sections:
- Scope analysis methodology
- Boundary identification techniques
- Authorization and permissions
- Systematic scope-limited testing
- Scope documentation and verification

### parameters.md
**Category:** Vulnerability Analysis | **Lines:** ~1000

Deep-dive into parameter analysis, mutation, and injection testing. Covers IDOR testing, parameter pollution, type confusion, and injection point discovery. Includes systematic approaches to parameter manipulation and response analysis.

Key sections:
- Parameter enumeration techniques
- IDOR testing methodology
- Parameter pollution patterns
- Type confusion exploitation
- Injection point identification
- Response analysis patterns

### PoC-Development.md
**Category:** Reporting | **Lines:** ~1000

Comprehensive guide to proof-of-concept development. Covers creating reproducible demonstrations, impact evidence, and compelling vulnerability proofs. Includes templates and best practices for different vulnerability classes.

Key sections:
- PoC structure and format
- Reproducibility requirements
- Impact evidence collection
- Different PoC types by vulnerability class
- Documentation best practices

### Reconnaissance.md
**Category:** Methodology | **Lines:** ~850

Reconnaissance methodology and asset discovery techniques. Covers subdomain enumeration, technology fingerprinting, attack surface mapping, and passive/active reconnaissance approaches. Foundation for all hunting activities.

Key sections:
- Passive reconnaissance techniques
- Active reconnaissance methods
- Asset discovery and enumeration
- Technology fingerprinting
- Attack surface mapping

### Reporting.md
**Category:** Reporting | **Lines:** ~1100

Report writing, severity assessment, and submission guidance. Covers report structure, impact articulation, severity calculation, and platform-specific submission requirements. The most comprehensive reporting guide in the domain.

Key sections:
- Report structure and format
- Severity assessment methodology
- Impact articulation techniques
- Platform-specific guidance (HackerOne, Bugcrowd, Intigriti)
- Common report mistakes and how to avoid them

### Specific-Vulnerabilities-Hunting.md
**Category:** Vulnerability Analysis | **Lines:** ~1000

Targeted hunting approaches for specific vulnerability classes. Covers XSS, SQLi, SSRF, XXE, CSRF, and other high-impact vulnerabilities with structured testing methodologies for each.

Key sections:
- XSS hunting methodology
- SQL injection techniques
- SSRF discovery and exploitation
- XXE testing approaches
- CSRF bypass methods
- Other vulnerability classes

### static-and-dynamic-testing.md
**Category:** Methodology | **Lines:** ~900

Static and dynamic analysis methodologies. Covers source code review (SAST), dynamic testing (DAST), and hybrid approaches. Includes tool recommendations and workflow integration patterns.

Key sections:
- Static analysis techniques
- Dynamic analysis approaches
- Hybrid testing methodologies
- Tool integration patterns
- Code review for security

### to-identify-injection-and-reflected-point-during-testing.md
**Category:** Vulnerability Analysis | **Lines:** ~800

Injection point identification and reflection analysis. Covers discovering where user input enters application logic, how reflections occur, and context-aware injection testing. Critical for all injection-based vulnerabilities.

Key sections:
- Input point discovery
- Reflection analysis techniques
- Context-aware injection
- Encoding and sanitization analysis
- Automated vs manual testing

### Tools-Integration.md
**Category:** Tools | **Lines:** ~350

Tool integration patterns and workflow optimization. Covers connecting various security tools into cohesive workflows, automation strategies, and toolchain optimization. The shortest document, focused on practical integration.

Key sections:
- Tool chain architecture
- Automation patterns
- Workflow optimization
- Custom tool development
- Integration best practices

### user-functionality.md
**Category:** Scope & Ethics | **Lines:** ~250

User functionality mapping and attack surface analysis. Covers understanding application features, user flows, and attack surface through systematic functionality analysis. Short but focused document.

Key sections:
- Functionality enumeration
- User flow mapping
- Attack surface identification
- Feature-based testing approaches

### Vulnerability-Detection.md
**Category:** Vulnerability Analysis | **Lines:** ~250

Vulnerability detection patterns and signatures. Covers automated and manual techniques for identifying common vulnerability indicators. Short reference document for quick pattern lookup.

Key sections:
- Detection patterns by vulnerability class
- Automated detection techniques
- Manual detection approaches
- Pattern library

---

## Glossary

| Term | Definition |
|------|------------|
| **ATO** | Account Takeover — gaining unauthorized access to another user's account |
| **CSRF** | Cross-Site Request Forgery — forcing authenticated users to execute unwanted actions |
| **DAST** | Dynamic Application Security Testing — testing running applications |
| **DOM XSS** | DOM-based Cross-Site Scripting — XSS payload executed entirely in the browser |
| **IDOR** | Insecure Direct Object Reference — accessing unauthorized resources via predictable identifiers |
| **PoC** | Proof of Concept — demonstration that a vulnerability can be exploited |
| **SAST** | Static Application Security Testing — analyzing source code without execution |
| **SSRF** | Server-Side Request Forgery — forcing the server to make unintended requests |
| **SQLi** | SQL Injection — inserting SQL code into application queries |
| **SSTI** | Server-Side Template Injection — injecting template code into server-side templates |
| **WAF** | Web Application Firewall — security device that filters malicious traffic |
| **XSS** | Cross-Site Scripting — injecting malicious scripts into web pages |
| **XXE** | XML External Entity — exploiting XML parsers to access internal resources |

---

## Contributing

When adding new documents to this domain:

1. **Categorize correctly** — Use the 6 established categories
2. **Follow naming conventions** — Use descriptive, hyphenated names
3. **Cross-reference** — Link to related documents where applicable
4. **Maintain quality** — Ensure content is actionable and well-structured
5. **Update this README** — Add new entries to the inventory and category sections

---

## Version History

- **v1.0** — Initial release with 23 core documents
- **Domain:** bug-bounty-support
- **Maintained by:** Prompt-Hunting Project

---

*This domain provides the foundational knowledge for all bug bounty hunting activities. Start here before moving to specialized vulnerability domains.*
