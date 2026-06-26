# Core Prompts — Vulnerability Hunting Domain

> **50 prompts | 20 core vulnerability classes | 30 advanced & specialized modules**
> Purpose-built for systematic, exhaustive web application security assessment.

---

## Overview

This directory contains **50 prompt modules** designed to guide an AI agent through a comprehensive, structured vulnerability hunting methodology. Each prompt is a self-contained expert persona with deep domain knowledge, detection patterns, exploitation techniques, and validation criteria.

The prompts are organized into three tiers:

| Tier | Files | Purpose |
|------|-------|---------|
| **Core Fundamentals** | 01–20 | Foundational hunting skills — recon, analysis, vuln classes, reporting |
| **Advanced Techniques** | 21–32 | Specialized attack vectors requiring deeper expertise |
| **Niche & Specialized** | 33–50 | Edge cases, protocol-specific, and framework-specific hunting |

---

## File Index

### Core Fundamentals (01–20)

| # | File | Domain | Lines |
|---|------|--------|-------|
| 01 | `1-Reconnaissance-and-Asset-Discovery.md` | Subdomain enumeration, technology fingerprinting, asset mapping | ~280 |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation.md` | JS bundle audit, source map extraction, minification reversal | ~320 |
| 03 | `3-API-Endpoint-Analysis.md` | REST/GraphQL discovery, endpoint enumeration, parameter fuzzing | ~350 |
| 04 | `4-Authentication-and-Session-Management.md` | Auth flows, session handling, token lifecycle, credential stuffing | ~380 |
| 05 | `5-Authorization-and-Access-Control.md` | IDOR, privilege escalation, RBAC/ABAC bypass | ~400 |
| 06 | `6-Input-Validation-and-Sanitization.md` | Injection vectors, encoding bypass, sanitization escape | ~350 |
| 07 | `7-Business-Logic-Flaws.md` | Race conditions, workflow bypass, price manipulation, coupon abuse | ~420 |
| 08 | `8-Client-Side-Storage-Security.md` | LocalStorage, cookies, IndexedDB, DOM clobbering | ~280 |
| 09 | `9-Cryptography-and-Data-Protection.md` | Weak crypto, key management, TLS misconfig, data exposure | ~300 |
| 10 | `10-Error-Handling-and-Information-Disclosure.md` | Stack traces, debug endpoints, verbose errors, version leaks | ~260 |
| 11 | `11-File-Upload-and-Processing.md` | Webshell upload, type bypass, path traversal, SSRF via upload | ~350 |
| 12 | `12-Server-Side-Request-Forgery-SSRF.md` | Internal network access, cloud metadata, blind SSRF | ~380 |
| 13 | `13-Cross-Site-Request-Forgery-CSRF.md` | State-changing actions, SameSite bypass, token predictability | ~300 |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS.md` | Origin reflection, null origin, wildcard misconfig | ~280 |
| 15 | `15-Race-Conditions-and-Concurrency-Issues.md` | TOCTOU, double-spend, concurrent state mutation | ~350 |
| 16 | `16-Third-Party-Component-Analysis.md` | Dependency audit, known CVEs, supply chain risks | ~300 |
| 17 | `17-Configuration-and-Misconfiguration-Hunting.md` | Default creds, debug mode, directory listing, backup files | ~320 |
| 18 | `18-Network-and-Infrastructure-Security.md` | Port scanning, service fingerprinting, network segmentation | ~300 |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile API abuse, certificate pinning, OAuth in mobile | ~280 |
| 20 | `20-Reporting-and-Proof-of-Concept-Development.md` | Report writing, PoC construction, severity scoring, submission | ~400 |

### Advanced Techniques (21–32)

| # | File | Domain | Lines |
|---|------|--------|-------|
| 21 | `21-Web-Application-Firewall-WAF-Bypass.md` | Encoding tricks, fragmentation, HTTP/2 abuse, AI bypass | ~400 |
| 22 | `22-HTTP-Request-Smuggling.md` | CL.TE, TE.CL, H2.CL, H2.TE, cache poisoning chains | ~350 |
| 23 | `23-Subdomain-Takeover.md` | CNAME dangling, S3/Azure/GCP takeover, wildcard abuse | ~300 |
| 24 | `24-Host-Header-Injection.md` | Password reset poisoning, cache poisoning, SSRF via Host | ~280 |
| 25 | `25-XML-External-Entity-XXE-Injection.md` | Blind XXE, SSRF via XXE, file read, DoS | ~300 |
| 26 | `26-Insecure-Deserialization.md` | Java deserialization, Python pickle, PHP object injection | ~350 |
| 27 | `27-Command-Injection.md` | OS command injection, blind injection, time-based detection | ~380 |
| 28 | `28-NoSQL-Injection.md` | MongoDB operator injection, CouchDB, Redis injection | ~300 |
| 29 | `29-GraphQL-Vulnerabilities.md` | Introspection abuse, batching attacks, IDOR via GraphQL | ~350 |
| 30 | `30-WebSocket-Security.md` | WS hijacking, cross-site WS, message injection | ~280 |
| 31 | `31-Server-Side-Template-Injection.md` | SSTI in Jinja2, Twig, Freemarker, ERB — RCE escalation | ~380 |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | Alg:none, key confusion, token confusion, claim manipulation | ~350 |

### Niche & Specialized (33–50)

| # | File | Domain | Lines |
|---|------|--------|-------|
| 33 | `33-Content-Security-Policy-CSP-Bypass.md` | CSP misconfig, nonce abuse, base-uri bypass, script-src holes | ~300 |
| 34 | `34-Clickjacking-and-UI-Redressing.md` | Frame options bypass, nested widgets, drag-and-drop attacks | ~250 |
| 35 | `35-HTTP-Parameter-Pollution.md` | Backend vs frontend parsing, HPP-based auth bypass | ~250 |
| 36 | `36-LDAP-Injection.md` | LDAP filter injection, blind LDAP, authentication bypass | ~280 |
| 37 | `37-Session-Puzzling-and-Fixation.md` | Session variable overloading, pre-auth session injection | ~280 |
| 38 | `38-Insecure-File-Handling.md` | Path traversal, symlink attacks, temp file race conditions | ~300 |
| 39 | `39-Cross-Site-Script-Inclusion-XSSI.md` | JSON hijacking, script inclusion, data exfil via inclusion | ~250 |
| 40 | `40-Prototype-Pollution.md` | JS prototype chain, property injection, RCE via pollution | ~300 |
| 41 | `41-HTTP-Response-Splitting.md` | CRLF injection, header injection, cache poisoning | ~250 |
| 42 | `42-XPath-Injection.md` | XPath query injection, blind extraction, authentication bypass | ~250 |
| 43 | `43-Cross-Site-Request-Forgery-CSRF.md` | Advanced CSRF patterns, Samesite bypass, subdomain CSRF | ~300 |
| 44 | `44-Cross-Origin-Resource-Sharing-CORS.md` | Advanced CORS exploitation, preflight abuse, credentialed requests | ~280 |
| 45 | `45-Race-Conditions-and-Concurrency-Issues.md` | Advanced race exploitation, thread-safe bypass, atomicity flaws | ~320 |
| 46 | `46-Third-Party-Component-Analysis.md` | Deep dependency analysis, transitive CVEs, SBOM generation | ~300 |
| 47 | `47-Configuration-and-Misconfiguration-Hunting.md` | Cloud misconfig, container escape, Kubernetes exposure | ~320 |
| 48 | `48-Network-and-Infrastructure-Security.md` | Advanced network attacks, lateral movement, segmentation testing | ~300 |
| 49 | `49-Mobile-and-API-Specific-Vulnerabilities.md` | Deep mobile testing, APK analysis, API versioning abuse | ~300 |
| 50 | `50-Reporting-and-Proof-of-Concept-Development.md` | Advanced reporting, chained findings, executive summaries | ~400 |

---

## Prompt Architecture

Each prompt module follows a standardized architecture:

### Standard Structure

```
┌─────────────────────────────────────────────────┐
│  ROLE DEFINITION                                │
│  ─ Expert persona, years of experience,         │
│    specific domain mastery                      │
├─────────────────────────────────────────────────┤
│  KNOWLEDGE BASE                                 │
│  ─ Root causes, attack patterns, CVEs,          │
│    real-world case studies                      │
├─────────────────────────────────────────────────┤
│  DETECTION METHODOLOGY                          │
│  ─ Reconnaissance, fingerprinting,              │
│    indicator identification                     │
├─────────────────────────────────────────────────┤
│  EXPLOITATION TECHNIQUES                        │
│  ─ Step-by-step attack workflows,               │
│    payload construction, tool usage             │
├─────────────────────────────────────────────────┤
│  VALIDATION & IMPACT ASSESSMENT                 │
│  ─ Confirmation steps, impact quantification,   │
│    severity determination                       │
├─────────────────────────────────────────────────┤
│  BYPASS & EVASION                               │
│  ─ WAF bypass, filter evasion,                  │
│    defense circumvention                        │
├─────────────────────────────────────────────────┤
│  REPORTING GUIDANCE                             │
│  ─ PoC construction, report templates,          │
│    remediation recommendations                  │
└─────────────────────────────────────────────────┘
```

### Prompt Design Principles

1. **Expert Persona** — Each prompt establishes a seasoned professional with 10+ years of specific domain experience, ensuring high-quality, authoritative guidance.

2. **Structured Workflows** — All hunting activities follow numbered, step-by-step methodologies that can be executed sequentially.

3. **Actionable Payloads** — Every detection pattern includes concrete curl commands, Burp Suite configurations, or manual testing steps.

4. **Real-World Grounding** — References to actual CVEs, disclosed bug bounty reports, and production incidents ground the prompts in reality.

5. **Severity Calibration** — CVSS scoring guidance and impact assessment frameworks ensure consistent, accurate severity ratings.

6. **Tool Integration** — Prompts reference industry-standard tools (Burp Suite, Nmap, sqlmap, ffuf, httpx, etc.) with specific configuration guidance.

---

## Usage Guide

### Loading a Prompt

To activate a specific hunting module, read the corresponding file and inject it as system context before beginning your assessment:

```bash
# Read the prompt file
cat Core-Prompts-hunting/12-Server-Side-Request-Forgery-SSRF.md

# Use as system context in your AI tool
# The prompt becomes the active expert persona
```

### Chaining Prompts

Effective vulnerability hunting requires chaining multiple modules. Recommended workflows:

| Workflow | Prompt Chain | Purpose |
|----------|-------------|---------|
| **Full Assessment** | 01 → 03 → 04 → 05 → 06 → 07 → 20 | End-to-end security audit |
| **API Deep Dive** | 03 → 04 → 05 → 29 → 32 → 19 | API-focused assessment |
| **Injection Hunting** | 06 → 27 → 28 → 25 → 31 → 42 | All injection vectors |
| **Auth Assessment** | 04 → 05 → 37 → 32 → 13 → 07 | Authentication & session |
| **Client-Side Audit** | 02 → 08 → 14 → 33 → 34 → 40 | Frontend security |
| **Infrastructure** | 01 → 18 → 17 → 23 → 22 → 48 | Network & infra |
| **WAF Bypass** | 21 → 06 → 27 → 12 → 31 | Evasion-focused |
| **Report Generation** | 20 → 50 | Final deliverable |

### Combining with Other Skill Directories

This domain integrates with other prompt directories:

- **`Core-Prompts-OWASP/`** — OWASP Top 10 specific guidance
- **`Core-Prompts-coding/`** — Secure coding practices
- **`Core-Prompts-DevOps/`** — CI/CD and infrastructure security
- **`Core-Prompts-incident/`** — Incident response procedures
- **`Core-Prompts-compliance/`** — Regulatory compliance mapping

---

## Vulnerability Class Coverage

### Injection Attacks (7 modules)
- SQL Injection via `06-Input-Validation-and-Sanitization.md`
- NoSQL Injection via `28-NoSQL-Injection.md`
- Command Injection via `27-Command-Injection.md`
- LDAP Injection via `36-LDAP-Injection.md`
- XPath Injection via `42-XPath-Injection.md`
- XXE via `25-XML-External-Entity-XXE-Injection.md`
- SSTI via `31-Server-Side-Template-Injection.md`

### Authentication & Session (5 modules)
- Auth Bypass via `04-Authentication-and-Session-Management.md`
- Authorization via `05-Authorization-and-Access-Control.md`
- Session Issues via `37-Session-Puzzling-and-Fixation.md`
- JWT Attacks via `32-JSON-Web-Token-JWT-Vulnerabilities.md`
- CSRF via `13-Cross-Site-Request-Forgery-CSRF.md`

### Client-Side Attacks (6 modules)
- XSS via `06-Input-Validation-and-Sanitization.md`
- CSRF via `13-Cross-Site-Request-Forgery-CSRF.md`
- Clickjacking via `34-Clickjacking-and-UI-Redressing.md`
- CSP Bypass via `33-Content-Security-Policy-CSP-Bypass.md`
- XSSI via `39-Cross-Site-Script-Inclusion-XSSI.md`
- Prototype Pollution via `40-Prototype-Pollution.md`

### Server-Side Attacks (8 modules)
- SSRF via `12-Server-Side-Request-Forgery-SSRF.md`
- File Upload via `11-File-Upload-and-Processing.md`
- Deserialization via `26-Insecure-Deserialization.md`
- Template Injection via `31-Server-Side-Template-Injection.md`
- Race Conditions via `15-Race-Conditions-and-Concurrency-Issues.md`
- HTTP Smuggling via `22-HTTP-Request-Smuggling.md`
- Response Splitting via `41-HTTP-Response-Splitting.md`
- Insecure File Handling via `38-Insecure-File-Handling.md`

### Infrastructure & Configuration (6 modules)
- Subdomain Takeover via `23-Subdomain-Takeover.md`
- Host Header Injection via `24-Host-Header-Injection.md`
- WAF Bypass via `21-Web-Application-Firewall-WAF-Bypass.md`
- CORS via `14-Cross-Origin-Resource-Sharing-CORS.md`
- Configuration via `17-Configuration-and-Misconfiguration-Hunting.md`
- Network via `18-Network-and-Infrastructure-Security.md`

### Specialized (8 modules)
- GraphQL via `29-GraphQL-Vulnerabilities.md`
- WebSocket via `30-WebSocket-Security.md`
- HPP via `35-HTTP-Parameter-Pollution.md`
- Mobile/API via `19-Mobile-and-API-Specific-Vulnerabilities.md`
- Third-Party via `16-Third-Party-Component-Analysis.md`
- Crypto via `9-Cryptography-and-Data-Protection.md`
- JS Analysis via `2-JavaScript-Analysis-and-Deobfuscation.md`
- Error Handling via `10-Error-Handling-and-Information-Disclosure.md`

---

## Severity Distribution

Based on typical hunting outcomes across these 50 modules:

```
Critical ████████░░░░░░░░░░░░ 15%  (RCE, ATO, SQLi, Deserialization)
High     ████████████████░░░░ 35%  (IDOR, SSRF, Auth Bypass, XSS)
Medium   ████████████████████ 40%  (CSRF, Info Disclosure, Misconfig)
Low      ████░░░░░░░░░░░░░░░░ 10%  (Clickjacking, HPP, Verbose Errors)
```

---

## Integration with MiMo Code Agent

These prompts are designed to work with the MiMo Code Agent's skill system. When loaded as context, they transform the agent into a domain-specific expert capable of:

1. **Systematic Discovery** — Following structured enumeration workflows
2. **Deep Analysis** — Understanding root causes, not just symptoms
3. **Exploitation Guidance** — Providing actionable attack steps
4. **Impact Assessment** — Accurately calibrating severity
5. **Professional Reporting** — Generating submission-ready findings

### Skill Loading Pattern

```
User: "Hunt for SSRF on target.example.com"
  ↓
Agent: Load 12-Server-Side-Request-Forgery-SSRF.md
  ↓
Agent: Execute SSRF hunting methodology
  ↓
Agent: Validate and report findings
```

---

## Methodology Alignment

These prompts align with established security methodologies:

| Methodology | Coverage |
|-------------|----------|
| **OWASP Testing Guide v4** | 100% of OTG categories covered |
| **PTES** | All phases from recon to reporting |
| **NIST SP 800-115** | Technical security testing |
| **OSSTMM** | Scientific testing methodology |
| **Bug Bounty Platforms** | H1, Bugcrowd, Intigriti patterns |

---

## File Naming Convention

```
{序号}-{Vulnerability-Name}.md
```

- Numbering is sequential (01–50)
- Names use PascalCase with hyphens
- Duplicates (43–50) extend core modules with advanced variations
- All files are self-contained markdown

---

## Quick Reference — By Attack Vector

| If you find... | Load prompt |
|----------------|-------------|
| User input in SQL queries | 06, hunt-sqli |
| User input in OS commands | 27 |
| User input in templates | 31 |
| User input in XML parsers | 25 |
| User input in LDAP queries | 36 |
| User input in XPath queries | 42 |
| User input in NoSQL queries | 28 |
| Internal URLs in requests | 12 |
| File upload functionality | 11, 38 |
| Session tokens in URLs | 37 |
| JWT tokens in requests | 32 |
| API endpoints | 03, 29, 19 |
| Cross-origin requests | 14 |
| Form submissions | 13 |
| Race-prone operations | 15 |
| Serialized objects | 26 |
| WebSocket connections | 30 |
| GraphQL endpoints | 29 |
| Mobile app traffic | 19 |
| Subdomains with CNAMEs | 23 |
| WAF responses | 21 |
| CSP headers | 33 |
| HTTP/2 connections | 22 |
| JavaScript bundles | 02, 40 |

---

## Recommended Tool Stack

Each prompt module assumes access to the following tool categories. Specific tools are referenced within individual prompts.

### Reconnaissance & Discovery

| Tool | Purpose | Prompt Reference |
|------|---------|-----------------|
| `subfinder` | Subdomain enumeration | 01 |
| `httpx` | Live host detection | 01 |
| `nmap` | Port scanning | 18 |
| `ffuf` | Directory fuzzing | 01, 17 |
| `katana` | Web crawling | 01, 03 |
| `amass` | Attack surface mapping | 01 |

### Proxy & Interception

| Tool | Purpose | Prompt Reference |
|------|---------|-----------------|
| Burp Suite Pro | HTTP proxy, scanner, Repeater | All |
| mitmproxy | Scriptable proxy | 04, 12 |
| OWASP ZAP | Open-source alternative | All |

### Exploitation & Validation

| Tool | Purpose | Prompt Reference |
|------|---------|-----------------|
| `sqlmap` | SQL injection automation | 06 |
| `xsstrike` | XSS detection | 06 |
| `ffuf` | Parameter fuzzing | 03, 05 |
| `jwt_tool` | JWT manipulation | 32 |
| `xxe-recursive-download` | XXE exploitation | 25 |
| `ysoserial` | Java deserialization | 26 |

### Reporting & Documentation

| Tool | Purpose | Prompt Reference |
|------|---------|-----------------|
| Pandoc | Report generation | 20, 50 |
| Draw.io | Architecture diagrams | 20 |
| Markdown editors | Report drafting | 20, 50 |

---

## Skill Chain Dependencies

Some prompts are designed to be loaded in sequence. The following dependencies describe prerequisite knowledge:

```
01-Reconnaissance ──────────────────────────┐
                                             ├──► 17-Configuration
02-JavaScript-Analysis ─────────────────────┤
                                             ├──► 40-Prototype-Pollution
03-API-Endpoint-Analysis ───────────────────┤
                                             ├──► 29-GraphQL
04-Authentication ──────────────────────────┤
                                             ├──► 32-JWT Vulnerabilities
05-Authorization ───────────────────────────┤
                                             ├──► 37-Session Puzzling
06-Input-Validation ────────────────────────┤
                                             ├──► 27-Command Injection
12-SSRF ────────────────────────────────────┤
                                             ├──► 23-Subdomain Takeover
13-CSRF ────────────────────────────────────┤
                                             └──► 43-Advanced CSRF
```

### Dependency Matrix

| Prompt | Depends On | Enables |
|--------|-----------|---------|
| 01 | — | 17, 23, 48 |
| 02 | — | 40 |
| 03 | 01 | 29, 19 |
| 04 | — | 32, 37 |
| 05 | 04 | 43 |
| 06 | — | 27, 31 |
| 12 | 01 | 23, 24 |
| 13 | 04 | 43 |
| 14 | — | 33 |
| 17 | 01 | 47 |
| 19 | 03, 04 | 49 |
| 20 | All | 50 |
| 21 | 06 | — |
| 22 | 01 | — |
| 25 | 06 | — |
| 26 | — | — |
| 28 | 06 | — |
| 29 | 03 | — |
| 31 | 06 | — |
| 32 | 04 | — |

---

## Testing Workflow — Step by Step

### Phase 1: Reconnaissance (Day 1)

```
Load prompts: 01 → 02 → 03
Execute:
  1. Subdomain enumeration (subfinder, amass)
  2. Live host verification (httpx)
  3. Technology fingerprinting (whatweb, wappalyzer)
  4. JavaScript bundle collection
  5. API endpoint discovery (swagger, openapi, graphql)
  6. Directory fuzzing (ffuf)
  7. Port scanning (nmap)
Output: Complete attack surface map
```

### Phase 2: Authentication & Authorization (Day 1-2)

```
Load prompts: 04 → 05 → 37
Execute:
  1. Auth flow mapping (login, register, reset, MFA)
  2. Session management analysis
  3. Token lifecycle testing
  4. IDOR testing across all parameters
  5. Privilege escalation attempts
  6. RBAC/ABAC bypass testing
  7. Session fixation/puzzling testing
Output: Auth/Authorization findings
```

### Phase 3: Injection Hunting (Day 2-3)

```
Load prompts: 06 → 27 → 28 → 25 → 31 → 36 → 42
Execute:
  1. Input vector identification
  2. SQL injection testing (sqlmap, manual)
  3. Command injection testing
  4. NoSQL injection testing
  5. XXE testing
  6. SSTI testing
  7. LDAP injection testing
  8. XPath injection testing
Output: Injection findings
```

### Phase 4: Client-Side Attacks (Day 3-4)

```
Load prompts: 13 → 14 → 33 → 34 → 39 → 40
Execute:
  1. CSRF testing on all state-changing endpoints
  2. CORS misconfiguration analysis
  3. CSP bypass attempts
  4. Clickjacking testing
  5. XSSI testing
  6. Prototype pollution testing
Output: Client-side findings
```

### Phase 5: Server-Side Attacks (Day 4-5)

```
Load prompts: 12 → 11 → 26 → 15 → 22 → 41
Execute:
  1. SSRF testing (all URL parameters, headers)
  2. File upload bypass testing
  3. Deserialization testing
  4. Race condition testing
  5. HTTP smuggling testing
  6. Response splitting testing
Output: Server-side findings
```

### Phase 6: Infrastructure & Configuration (Day 5-6)

```
Load prompts: 17 → 18 → 23 → 24 → 48
Execute:
  1. Configuration review (default creds, debug mode)
  2. Network security testing
  3. Subdomain takeover scanning
  4. Host header injection testing
  5. Infrastructure assessment
Output: Infrastructure findings
```

### Phase 7: Advanced & Specialized (Day 6-7)

```
Load prompts: 21 → 29 → 30 → 35 → 16 → 09 → 10
Execute:
  1. WAF bypass testing (if WAF detected)
  2. GraphQL deep testing
  3. WebSocket security testing
  4. HPP testing
  5. Third-party component analysis
  6. Cryptographic assessment
  7. Error handling review
Output: Advanced findings
```

### Phase 8: Reporting (Day 7+)

```
Load prompts: 20 → 50
Execute:
  1. Aggregate all findings
  2. Classify by severity (CVSS)
  3. Write individual PoCs
  4. Draft executive summary
  5. Compile final report
  6. Prepare submission packages
Output: Final deliverable
```

---

## Common Bypass Techniques by Module

### WAF Bypass Quick Reference (Module 21)

| Technique | Payload Pattern | Target |
|-----------|----------------|--------|
| Double encoding | `%2527` | SQLi, XSS |
| Chunked transfer | `Transfer-Encoding: chunked` | WAF evasion |
| HTTP/2 smuggling | `:method: POST` | All |
| Case variation | `SeLeCt` | SQLi |
| Comment injection | `SEL/**/ECT` | SQLi |
| Unicode normalization | `\u0027` | XSS, SQLi |
| Null bytes | `%00` | Path traversal |
| Parameter name pollution | `id=1&id=1'` | SQLi |

### Authentication Bypass Quick Reference (Module 04)

| Technique | Method | Success Indicator |
|-----------|--------|-------------------|
| Default credentials | POST /login | Dashboard access |
| Password spraying | POST /login (many users) | Any 200 OK |
| MFA skip | GET /dashboard (skip MFA step) | Dashboard content |
| Token prediction | Analyze token pattern | Valid token |
| Session fixation | Set session before auth | Pre-auth session used |

### IDOR Quick Reference (Module 05)

| Technique | Parameter | Test Method |
|-----------|-----------|-------------|
| Direct object reference | `?id=123` → `?id=124` | Sequential increment |
| UUID prediction | `?uuid=abc-123` | UUID v4 generation |
| Path traversal | `/api/users/123` → `/api/users/124` | Path modification |
| Encoded IDs | `?data=base64(id)` | Decode and modify |
| Nested objects | `{"user": {"id": 123}}` | Modify nested ID |

---

## Integration Points

### With MiMo Code Agent Skills

This prompt domain integrates with the following MiMo Code Agent skills:

| Skill | Integration Point |
|-------|-------------------|
| `hunt-xss` | Module 06 — Input Validation |
| `hunt-sqli` | Module 06 — Input Validation |
| `hunt-ssrf` | Module 12 — SSRF |
| `hunt-idor` | Module 05 — Authorization |
| `hunt-xxe` | Module 25 — XXE |
| `hunt-rce` | Module 27 — Command Injection |
| `hunt-ssti` | Module 31 — SSTI |
| `hunt-csrf` | Module 13 — CSRF |
| `hunt-oauth` | Module 04 — Authentication |
| `hunt-ato` | Module 04 — Authentication |
| `hunt-mfa-bypass` | Module 04 — Authentication |
| `hunt-subdomain` | Module 23 — Subdomain Takeover |
| `hunt-http-smuggling` | Module 22 — HTTP Smuggling |
| `hunt-cache-poison` | Module 24 — Host Header |
| `hunt-file-upload` | Module 11 — File Upload |
| `hunt-cloud-misconfig` | Module 47 — Configuration |
| `report-writing` | Module 20, 50 — Reporting |
| `triage-validation` | Module 20, 50 — Reporting |

### With Other Prompt Directories

| Directory | Cross-Reference |
|-----------|----------------|
| `Core-Prompts-OWASP/` | OWASP Top 10 alignment |
| `Core-Prompts-coding/` | Secure coding remediation |
| `Core-Prompts-DevOps/` | CI/CD security testing |
| `Core-Prompts-incident/` | Post-exploitation response |
| `Core-Prompts-compliance/` | Regulatory mapping |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-26 | Initial release — 50 prompt modules |

---

## Maintenance

- **Version**: 1.0.0
- **Last Updated**: 2026-06-26
- **Total Files**: 50
- **Total Estimated Lines**: ~15,000+
- **Maintained by**: MiMo Code Agent / Prompt-Hunting Project

---

## License

Internal use only — part of the Prompt-Hunting security research framework.

---

*Built for exhaustive, systematic vulnerability hunting. Every prompt is a weapon. Use them wisely.*
