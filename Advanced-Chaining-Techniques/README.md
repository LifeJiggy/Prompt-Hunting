# Advanced Vulnerability Chaining Techniques

## Domain Overview

This domain contains **49 comprehensive files** covering the art and science of vulnerability chaining — the practice of combining multiple individual vulnerabilities to achieve impact far greater than any single flaw alone. Chaining transforms low-severity findings into critical attack paths, turning "informational" bugs into account takeovers, RCE, and full system compromise.

## Expert Role

You are an **Advanced Vulnerability Chain Architect** — a specialist who sees attack paths where others see isolated bugs. You think in graph terms: entry points, transition primitives, escalation nodes, and impact sinks. You understand that modern applications are complex systems where the interaction between flaws creates emergent attack surfaces.

**Core competencies:**
- Identifying primitive transitions (e.g., XSS → cookie theft → session hijack → ATO)
- Mapping multi-hop attack chains across application boundaries
- Combining client-side and server-side vulnerabilities
- Escalating through application trust boundaries
- Exploiting race conditions within larger chain contexts
- Leveraging misconfigurations as chain enablers

## Scope

This domain covers chaining techniques across:

### Web Application Security
- Client-side vulnerability chains (XSS, CSRF, Clickjacking)
- Server-side vulnerability chains (SQLi, SSRF, XXE, Deserialization)
- Authentication and authorization chain exploitation
- Business logic chain abuse
- Session management attack chains

### API and Modern Architecture
- GraphQL exploitation chains
- WebSocket security chains
- API rate limit and abuse chains
- REST API chaining patterns

### Infrastructure and Cloud
- SSRF to internal network compromise
- Cloud misconfiguration chains
- Container escape and Kubernetes attack chains
- DNS rebinding and network-level chains

### Advanced Persistent Threats
- Supply chain attack chains
- Zero-day chaining strategies
- Multi-platform attack chains
- APT-style persistent access chains

### Specialized Attack Vectors
- Prototype pollution exploitation
- HTTP request smuggling chains
- Cache poisoning chains
- Mobile API chains

---

## File Index

| # | Filename | Title | Focus Area |
|---|----------|-------|------------|
| 01 | `01-Basic-Vulnerability-Chaining.md` | Basic Vulnerability Chaining | Foundational concepts and methodology |
| 02 | `02-Information-Disclosure-to-RCE.md` | Information Disclosure to RCE | Leak exploitation chains |
| 03 | `03-XSS-to-Account-Takeover.md` | XSS to Account Takeover | Client-side to account compromise |
| 04 | `04-IDOR-to-Mass-Data-Extraction.md` | IDOR to Mass Data Extraction | Authorization bypass scaling |
| 05 | `05-SQL-Injection-to-Shell-Access.md` | SQL Injection to Shell Access | Database to OS escalation |
| 06 | `06-SSRF-to-Internal-Network-Compromise.md` | SSRF to Internal Network Compromise | Server-side pivot chains |
| 07 | `07-CORS-Misconfiguration-Chains.md` | CORS Misconfiguration Chains | Cross-origin exploitation |
| 08 | `08-CSRF-to-Privilege-Escalation.md` | CSRF to Privilege Escalation | Request forgery escalation |
| 09 | `09-File-Upload-to-Web-Shell.md` | File Upload to Web Shell | Upload to RCE chains |
| 10 | `10-XXE-to-Sensitive-Data-Access.md` | XXE to Sensitive Data Access | XML parser exploitation |
| 11 | `11-Deserialization-to-RCE.md` | Deserialization to RCE | Object injection chains |
| 12 | `12-JWT-Manipulation-Chains.md` | JWT Manipulation Chains | Token exploitation chains |
| 13 | `13-SSTI-to-Complete-Compromise.md` | SSTI to Complete Compromise | Template injection escalation |
| 14 | `14-Open-Redirect-Chains.md` | Open Redirect Chains | Redirect abuse patterns |
| 15 | `15-NoSQL-Injection-to-Data-Breach.md` | NoSQL Injection to Data Breach | Non-relational DB exploitation |
| 16 | `16-GraphQL-Abuse-Chains.md` | GraphQL Abuse Chains | API query exploitation |
| 17 | `17-WebSocket-Security-Chains.md` | WebSocket Security Chains | Real-time protocol exploitation |
| 18 | `18-Prototype-Pollution-Exploitation.md` | Prototype Pollution Exploitation | JavaScript prototype abuse |
| 19 | `19-HTTP-Request-Smuggling-Chains.md` | HTTP Request Smuggling Chains | Protocol-level confusion |
| 20 | `20-Host-Header-Injection-Chains.md` | Host Header Injection Chains | Header manipulation exploitation |
| 21 | `21-DNS-Rebinding-Attacks.md` | DNS Rebinding Attacks | DNS-based exploitation |
| 22 | `22-Race-Condition-Exploitation.md` | Race Condition Exploitation | Concurrency vulnerability chains |
| 23 | `23-Subdomain-Takeover-Chains.md` | Subdomain Takeover Chains | Domain-level exploitation |
| 24 | `24-Open-Redirect-to-Phishing.md` | Open Redirect to Phishing | Redirect to credential theft |
| 25 | `25-Content-Spoofing-Chains.md` | Content Spoofing Chains | Content injection exploitation |
| 26 | `26-WebCache-Poisoning-Chains.md` | WebCache Poisoning Chains | Cache-based exploitation |
| 27 | `27-Clickjacking-to-Account-Compromise.md` | Clickjacking to Account Compromise | UI redress attacks |
| 28 | `28-Parameter-Pollution-Attacks.md` | Parameter Pollution Attacks | HTTP parameter manipulation |
| 29 | `29-LDAP-Injection-Chains.md` | LDAP Injection Chains | Directory service exploitation |
| 30 | `30-XPath-Injection-Exploitation.md` | XPath Injection Exploitation | XML path language injection |
| 31 | `31-Session-Puzzling-Techniques.md` | Session Puzzling Techniques | Session manipulation chains |
| 32 | `32-Insecure-File-Handling-Chains.md` | Insecure File Handling Chains | File system exploitation |
| 33 | `33-Cross-Site-Script-Inclusion.md` | Cross-Site Script Inclusion | Script include exploitation |
| 34 | `34-HTTP-Response-Splitting.md` | HTTP Response Splitting | Header injection exploitation |
| 35 | `35-Client-Side-Storage-Abuse.md` | Client-Side Storage Abuse | localStorage/cookie exploitation |
| 36 | `36-Cryptography-Weakness-Chains.md` | Cryptography Weakness Chains | Crypto flaw exploitation |
| 37 | `37-Third-Party-Component-Chains.md` | Third-Party Component Chains | Dependency exploitation |
| 38 | `38-Configuration-Misconfiguration-Chains.md` | Configuration Misconfiguration Chains | Config flaw chaining |
| 39 | `39-Network-Infrastructure-Chains.md` | Network Infrastructure Chains | Network-level exploitation |
| 40 | `40-Mobile-API-Chains.md` | Mobile API Chains | Mobile backend exploitation |
| 41 | `41-Cloud-Misconfiguration-Chains.md` | Cloud Misconfiguration Chains | Cloud service exploitation |
| 42 | `42-Container-Escape-Chains.md` | Container Escape Chains | Container breakout exploitation |
| 43 | `43-Kubernetes-Attack-Chains.md` | Kubernetes Attack Chains | K8s cluster exploitation |
| 44 | `44-Blockchain-Exploit-Chains.md` | Blockchain Exploit Chains | Blockchain/smart contract exploitation |
| 45 | `45-IoT-Device-Compromise-Chains.md` | IoT Device Compromise Chains | IoT exploitation patterns |
| 46 | `46-Supply-Chain-Attack-Chains.md` | Supply Chain Attack Chains | Dependency/vendor exploitation |
| 47 | `47-Zero-Day-Chaining-Strategies.md` | Zero-Day Chaining Strategies | Unknown vulnerability chaining |
| 48 | `48-Multi-Platform-Attack-Chains.md` | Multi-Platform Attack Chains | Cross-platform exploitation |
| 49 | `49-Advanced-Persistent-Threat-Chains.md` | Advanced Persistent Threat Chains | APT-style attack patterns |
| 50 | `50-Master-Chaining-Framework.md` | Master Chaining Framework | Comprehensive chaining methodology |

---

## Key Concepts

### 1. Chain Primitives

A **chain primitive** is a reusable building block that enables transition between vulnerability classes:

| Primitive | Description | Common Chains |
|-----------|-------------|---------------|
| **Input Control** | Ability to inject data into application flow | XSS, SQLi, SSTI, XXE |
| **Information Leak** | Access to sensitive data or system details | Recon → targeted exploitation |
| **Authentication Bypass** | Access without proper credentials | Privilege escalation chains |
| **Authorization Bypass** | Access beyond permitted scope | IDOR, privilege escalation |
| **Code Execution** | Ability to run arbitrary code | Full system compromise |
| **Request Forgery** | Ability to make requests on behalf of others | CSRF, SSRF chains |
| **Redirect Control** | Ability to control user navigation | Phishing, OAuth theft |
| **Cache Control** | Ability to poison or manipulate caches | Content injection, XSS |

### 2. Chain Taxonomy

Chains are classified by their structure:

```
┌─────────────────────────────────────────────────────────────┐
│                    CHAIN TAXONOMY                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  LINEAR CHAINS                                              │
│  A → B → C → Impact                                         │
│  Example: XSS → Cookie Theft → Session Hijack → ATO        │
│                                                             │
│  BRANCHING CHAINS                                           │
│           ┌─ B1 → C1 → Impact                              │
│  A → B ──┤                                                  │
│           └─ B2 → C2 → Impact                              │
│  Example: SSRF → Internal Host ─┬─ Database Access          │
│                                 └─ Admin Panel Access       │
│                                                             │
│  CONVERGENT CHAINS                                          │
│  A1 ─┐                                                     │
│  A2 ─┼─→ C → Impact                                        │
│  A3 ─┘                                                     │
│  Example: XSS + CSRF + Open Redirect → ATO                 │
│                                                             │
│  CYCLICAL CHAINS                                            │
│  A → B → C → A' (elevated)                                 │
│  Example: Info Leak → Targeted XSS → More Info → Better XSS│
│                                                             │
│  PARALLEL CHAINS                                            │
│  A₁ → B₁ → C₁ ─┐                                          │
│                   ├─→ Combined Impact                       │
│  A₂ → B₂ → C₂ ─┘                                          │
│  Example: RCE on Server + XSS on Client → Full Control     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. Impact Multipliers

When combining vulnerabilities, impact multiplies:

| Single Bug Impact | Chain Component | Combined Impact |
|-------------------|-----------------|-----------------|
| Information Disclosure (Low) | + SQL Injection (High) | Data Breach (Critical) |
| XSS (Medium) | + CSRF (Medium) | Account Takeover (High) |
| Open Redirect (Low) | + OAuth Misconfig (Medium) | Account Takeover (High) |
| SSRF (High) | + Cloud Metadata (Critical) | Full Cloud Compromise (Critical) |
| File Upload (Medium) | + Path Traversal (Medium) | Remote Code Execution (Critical) |
| Race Condition (Low) | + IDOR (Medium) | Mass Data Modification (High) |
| Clickjacking (Low) | + Password Change (Medium) | Account Takeover (High) |

### 4. Chain Complexity Levels

```
Level 1: Simple Chains (2 vulnerabilities)
├── Single transition primitive
├── Direct cause-effect relationship
└── Examples: XSS → Session Theft, SQLi → Data Dump

Level 2: Intermediate Chains (3-4 vulnerabilities)
├── Multiple transition points
├── Requires specific conditions at each step
└── Examples: Open Redirect → OAuth Theft → ATO → Data Exfil

Level 3: Advanced Chains (5+ vulnerabilities)
├── Complex branching or convergence
├── May span multiple trust boundaries
└── Examples: Recon → Custom XSS → Cookie Theft → SSRF → RCE

Level 4: Expert Chains (6+ vulnerabilities)
├── Multi-stage with feedback loops
├── Exploits architectural weaknesses
└── Examples: Supply Chain → Initial Access → Persistence → Lateral Movement → Exfil
```

---

## Chain Taxonomy by Attack Vector

### Client-Side Chains
| Chain | Entry Point | Transition | Impact |
|-------|-------------|------------|--------|
| XSS → Cookie Theft | Reflected/Stored XSS | `document.cookie` exfil | Session Hijack |
| XSS → CSRF | XSS in target domain | Forge authenticated requests | Account Modification |
| Clickjacking → ATO | UI Redress | Trick user action | Password Change/OAuth |
| Open Redirect → OAuth | Malicious redirect_uri | Authorization code interception | Account Takeover |
| Prototype Pollution → RCE | `__proto__` injection | Code execution sink | System Compromise |

### Server-Side Chains
| Chain | Entry Point | Transition | Impact |
|-------|-------------|------------|--------|
| SQLi → File Read | Union/Delay injection | `LOAD_FILE()` / `INTO OUTFILE` | Data Exfil / RCE |
| SSRF → Cloud Metadata | URL parameter injection | IMDS endpoint access | Cloud Credentials |
| XXE → SSRF | XML entity injection | Internal network scan | Internal Access |
| Deserialization → RCE | Object injection | Gadget chain execution | System Compromise |
| SSTI → RCE | Template injection | Engine-specific RCE payload | System Compromise |

### Infrastructure Chains
| Chain | Entry Point | Transition | Impact |
|-------|-------------|------------|--------|
| DNS Rebinding → Internal | DNS manipulation | Bypass CORS/SOP | Internal Service Access |
| Subdomain Takeover → XSS | Unclaimed subdomain | Host header injection | Targeted XSS |
| HTTP Smuggling → Cache Poison | CL.TE/TE.CL confusion | Cache key manipulation | Mass XSS |
| Cache Poisoning → XSS | URL parameter in cache key | Reflected XSS in cached response | Mass Session Theft |

### Cloud and Container Chains
| Chain | Entry Point | Transition | Impact |
|-------|-------------|------------|--------|
| SSRF → K8s API | Service-side request | K8s API access | Cluster Compromise |
| SSRF → IAM Credentials | EC2 metadata service | AssumeRole | Full Cloud Access |
| Container Escape → Host | Kernel exploit | Namespace breakout | Host RCE |
| Supply Chain → CI/CD | Compromised dependency | Build pipeline access | Code Injection |

---

## Learning Path

### Phase 1: Foundations (Files 01-14)
Master the core chaining primitives:

```
Start Here
    │
    ▼
┌─────────────────────────────────┐
│ 01-Basic-Vulnerability-Chaining │ ← Concepts and methodology
└─────────────┬───────────────────┘
              │
    ┌─────────┴─────────┐
    ▼                   ▼
┌──────────────┐  ┌──────────────┐
│ Client-Side  │  │ Server-Side  │
│ Chains       │  │ Chains       │
│ (03,07,08)   │  │ (05,06,10)   │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ Info → RCE   │  │ SSTI → RCE   │
│ (02)         │  │ (13)         │
└──────┬───────┘  └──────┬───────┘
       │                 │
       └────────┬────────┘
                ▼
┌─────────────────────────────┐
│ File Upload → Web Shell (09)│
└─────────────┬───────────────┘
              ▼
        Phase 2 Ready
```

### Phase 2: Advanced Techniques (Files 15-30)
Expand to modern attack surfaces:

- GraphQL and WebSocket exploitation
- Prototype pollution chains
- Protocol-level attacks (HTTP smuggling, response splitting)
- Session manipulation techniques
- LDAP/XPath injection chains

### Phase 3: Infrastructure Chains (Files 31-45)
Move beyond web applications:

- Cloud misconfiguration exploitation
- Container and Kubernetes attack chains
- Network infrastructure exploitation
- Mobile API chains
- IoT device compromise patterns

### Phase 4: Expert Techniques (Files 46-50)
Master advanced persistent threats:

- Supply chain attack orchestration
- Zero-day chaining strategies
- Multi-platform attack chains
- APT-style persistent access
- Master chaining framework

---

## Tool Integrations

### Reconnaissance Tools
| Tool | Use Case in Chains |
|------|-------------------|
| **Subfinder** | Subdomain discovery for takeover chains |
| **httpx** | Live host detection for SSRF targets |
| **nuclei** | Template-based vulnerability scanning |
| **ffuf** | Directory fuzzing for hidden endpoints |
| **katana** | Deep crawling for XSS/CSRF injection points |

### Exploitation Tools
| Tool | Use Case in Chains |
|------|-------------------|
| **Burp Suite** | Request manipulation, Repeater, Intruder |
| **SQLMap** | Automated SQL injection exploitation |
| **Metasploit** | Post-exploitation and pivot chains |
| **Commix** | Command injection exploitation |
| **tplmap** | SSTI exploitation framework |

### Chain Validation Tools
| Tool | Use Case in Chains |
|------|-------------------|
| **Interactsh** | OOB interaction detection |
| **Burp Collaborator** | Out-of-band vulnerability confirmation |
| **Canarytokens** | Data exfiltration detection |
| **webhook.site** | Request interception for chain validation |

### Post-Exploitation Tools
| Tool | Use Case in Chains |
|------|-------------------|
| **Chisel** | SOCKS proxy for internal pivoting |
| **ligolo-ng** | Tunneling for network access |
| **Impacket** | Windows protocol exploitation |
| **Rubeus** | Kerberos abuse for AD chains |

---

## Usage Guide

### Reading Order for Beginners
1. Start with `01-Basic-Vulnerability-Chaining.md` — understand core concepts
2. Pick ONE chain type (e.g., `03-XSS-to-Account-Takeover.md`) and master it
3. Practice combining two chains (e.g., XSS chain + CSRF chain)
4. Move to Level 2 and 3 chains

### Reading Order for Intermediate
1. Review `50-Master-Chaining-Framework.md` for methodology
2. Focus on gaps in your knowledge (cloud? container? mobile?)
3. Study advanced techniques in Phase 2-3 files
4. Practice chain construction in bug bounty programs

### Reading Order for Advanced
1. Jump to `47-Zero-Day-Chaining-Strategies.md`
2. Study `49-Advanced-Persistent-Threat-Chains.md`
3. Review `48-Multi-Platform-Attack-Chains.md`
4. Master the full framework in `50-Master-Chaining-Framework.md`

### Practical Exercise Framework
```markdown
## Exercise Template

**Target:** [Application/Service]
**Goal:** [Achieve X impact]

**Step 1: Reconnaissance**
- [ ] Identify potential entry points
- [ ] Map application architecture
- [ ] Identify trust boundaries

**Step 2: Primitive Discovery**
- [ ] List individual vulnerabilities found
- [ ] Categorize by primitive type
- [ ] Identify potential transitions

**Step 3: Chain Construction**
- [ ] Map entry → transition → impact
- [ ] Verify each step is achievable
- [ ] Document prerequisites

**Step 4: Chain Validation**
- [ ] Test each link independently
- [ ] Test full chain end-to-end
- [ ] Document success/failure conditions

**Step 5: Impact Assessment**
- [ ] Determine maximum impact
- [ ] Consider defensive measures
- [ ] Estimate effort/reward ratio
```

---

## Cross-References

### By Vulnerability Class

| Vulnerability | Primary File | Related Chains |
|---------------|--------------|----------------|
| **XSS** | 03 | 07, 14, 18, 24, 25, 26, 33 |
| **SQL Injection** | 05 | 02, 10, 15 |
| **SSRF** | 06 | 10, 21, 39, 41, 42, 43 |
| **CSRF** | 08 | 03, 12, 07 |
| **File Upload** | 09 | 32, 42 |
| **XXE** | 10 | 06, 30 |
| **Deserialization** | 11 | 18, 05 |
| **JWT** | 12 | 08, 11 |
| **SSTI** | 13 | 05, 11 |
| **Open Redirect** | 14/24 | 03, 07, 23 |
| **Race Condition** | 22 | 04, 28 |
| **Smuggling** | 19 | 26, 34 |
| **Cache Poisoning** | 26 | 19, 03 |
| **Prototype Pollution** | 18 | 11, 03 |

### By Target Environment

| Environment | Relevant Files |
|-------------|----------------|
| **Web Applications** | 01-14, 15-30, 31-38 |
| **APIs** | 06, 16, 17, 40 |
| **Cloud** | 06, 41, 42, 43 |
| **Containers** | 42, 43 |
| **Mobile** | 40 |
| **IoT** | 45 |
| **Blockchain** | 44 |
| **Supply Chain** | 37, 46 |
| **Enterprise** | 39, 48, 49 |

---

## Severity Escalation Guide

### How Chains Increase Severity

| Individual Bugs | Chain Result | Why It Escalates |
|-----------------|--------------|------------------|
| Open Redirect (Low) | → ATO (Critical) | Enables OAuth theft or phishing |
| Clickjacking (Low) | → Account Change (High) | Bypasses user awareness |
| Info Disclosure (Low) | → Targeted Attack (High) | Reveals attack surface |
| IDOR (Medium) | → Data Breach (Critical) | Scales to mass extraction |
| XSS (Medium) | → RCE (Critical) | Via admin panel chain |
| SSRF (High) | → Cloud Compromise (Critical) | Accesses internal metadata |
| Race Condition (Low) | → Fund Theft (Critical) | Bypasses business logic |
| CSRF (Medium) | → Admin Takeover (Critical) | Combined with privilege chain |

### Severity Assessment Formula

```
Chain Severity = max(Individual Severities) × Chain Complexity Bonus × Impact Multiplier

Where:
- Complexity Bonus: 1.0 (2 bugs), 1.5 (3 bugs), 2.0 (4+ bugs)
- Impact Multiplier: 1.5 (data access), 2.0 (data modification), 3.0 (code execution)
```

### When to Report as Critical

Report as Critical when:
1. Chain achieves Remote Code Execution
2. Chain achieves Account Takeover on admin accounts
3. Chain bypasses authentication entirely
4. Chain accesses sensitive data at scale (PII, financial)
5. Chain persists across sessions (persistent backdoor)
6. Chain affects multiple users simultaneously

---

## Common Chain Patterns

### Pattern 1: Recon → Entry → Escalation → Impact
```
Passive Recon → Active Recon → Vulnerability Discovery → Primitive Collection → Chain Construction → Exploitation → Impact Delivery
```

### Pattern 2: Low → High Escalation
```
Low-Severity Bug (Entry) → Information Gathering → Medium-Severity Primitive → Chaining → High/Critical Impact
```

### Pattern 3: Cross-Boundary Pivot
```
External Access → SSRF/XXE → Internal Network → Internal Service Exploitation → Lateral Movement → Crown Jewels
```

### Pattern 4: Authentication Chain
```
Credential Leak → Session Fixation/Hijack → Privilege Escalation → Admin Access → Full Control
```

### Pattern 5: Client-Side → Server-Side
```
XSS/Clickjacking → User Action Manipulation → Server-Side Request Forgery → Internal Access → RCE
```

### Pattern 6: Supply Chain → Production
```
Dependency Compromise → Malicious Code in Package → Build Pipeline Injection → Production Deployment → Backdoor Access
```

---

## Tips for Chain Construction

### 1. Think in Graphs, Not Lines
Map vulnerabilities as nodes and transitions as edges. Look for paths from entry points to impact sinks.

### 2. Identify Transition Primitives
Every chain requires a way to move between vulnerability classes. The most powerful primitives:
- Cookie/session theft (enables session hijacking)
- Request forgery (enables SSRF/CSRF)
- Code execution (enables everything)
- Information disclosure (enables targeted attacks)

### 3. Don't Dismiss Low-Severity Bugs
Low-severity bugs are often the entry point for critical chains:
- Open Redirect → OAuth Theft (Critical)
- Clickjacking → Password Change (High)
- Information Disclosure → Targeted XSS (High)

### 4. Consider Defense Layers
Map the application's defenses:
- WAF rules (bypass techniques)
- Rate limiting (race conditions, distributed attacks)
- Input validation (encoding tricks, alternative syntax)
- Authentication (session manipulation, token reuse)

### 5. Document Every Step
Document:
- Preconditions for each step
- Exact payloads used
- Success indicators
- Failure conditions
- Impact at each stage

### 6. Practice Methodically
- Start with CTF challenges
- Progress to bug bounty programs
- Document all chains found
- Build a personal chain library

---

## Defensive Considerations

### Mitigation Strategies by Chain Type

| Chain Type | Primary Defense | Secondary Defense |
|------------|-----------------|-------------------|
| XSS Chains | Input validation + CSP | Output encoding + HttpOnly cookies |
| SSRF Chains | Allowlist outbound | Network segmentation + IMDSv2 |
| SQLi Chains | Parameterized queries | WAF + least privilege DB access |
| Deserialization | Input validation | Content-type restrictions |
| Race Conditions | Atomic operations | Idempotency keys |
| Cache Poisoning | Normalize cache keys | Disable caching sensitive data |
| Supply Chain | Pin dependencies | SBOM + vulnerability scanning |

### Defense-in-Depth Principles

1. **Never rely on single defense** — assume each layer can be bypassed
2. **Minimize attack surface** — fewer features = fewer chain components
3. **Segment trust boundaries** — limit lateral movement potential
4. **Monitor and alert** — detect chain construction attempts
5. **Assume breach** — design for containment, not just prevention

---

## Quick Reference

### Chain Speed Run (Common Chains)

| Goal | Minimum Chain |
|------|---------------|
| Account Takeover | XSS → Cookie Theft → Session Hijack |
| Data Breach | SQLi → Database Dump |
| RCE | File Upload → Web Shell |
| Cloud Access | SSRF → IMDS → IAM Credentials |
| Internal Access | SSRF → Internal Network Scan |
| Privilege Escalation | IDOR → Admin Function Access |
| Phishing | Open Redirect → Credential Harvest |

### Emergency Chain Analysis

When time-limited, prioritize:
1. **Entry points**: What can we reach?
2. **Primitives**: What can we control?
3. **Transitions**: How do we move between bugs?
4. **Impact**: What's the maximum damage?
5. **Feasibility**: Can this chain work end-to-end?

---

## Contributing

When adding new chain documentation:
1. Follow the naming convention: `XX-Descriptive-Name.md`
2. Include real-world examples where possible
3. Document both attack and defense perspectives
4. Cross-reference related files
5. Include severity assessment
6. Provide actionable payloads and techniques

---

*This domain provides comprehensive coverage of vulnerability chaining techniques across web applications, APIs, cloud infrastructure, and enterprise environments. Master these patterns to identify attack paths that others miss and achieve impact that individual vulnerabilities cannot deliver alone.*