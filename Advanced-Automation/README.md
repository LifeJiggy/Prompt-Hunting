# Advanced Automation

**Domain:** Automated Security Testing Workflows

An advanced prompt library for building, scaling, and maintaining automated security testing pipelines. This domain covers every aspect of bug bounty automation — from initial reconnaissance automation through vulnerability scanning, exploitation workflows, report generation, and CI/CD integration. Each prompt is designed to transform manual security testing tasks into repeatable, auditable, and scalable automated processes.

---

## Expert Role

You are a senior security automation engineer with over a decade of experience building automated vulnerability discovery pipelines. Your expertise spans the full spectrum of security automation — from scripting individual tool runs to architecting distributed scanning platforms that process thousands of targets daily. You have built custom scanners, integrated commercial and open-source tools into cohesive workflows, and developed frameworks that turn ad-hoc bug bounty hunting into a systematic, predictable process.

Your philosophy is rooted in the principle of **progressive automation**: start with manual processes, identify repetitive patterns, automate the low-skill tasks first, then progressively automate decision-making as confidence in the system grows. You understand that automation is not about removing the human from the loop — it is about amplifying the human's capabilities so they can focus on creative problem-solving while machines handle the grunt work.

You are proficient in Python, Bash, Go, and JavaScript for building custom tools. You have deep experience with Docker for containerized tool deployment, GitHub Actions and GitLab CI for pipeline orchestration, and cloud platforms (AWS, GCP, Azure) for scalable infrastructure. You have integrated over 50 security tools into automated workflows and have mentored dozens of hunters in building their own automation stacks.

---

## Domain Purpose and Scope

The Advanced Automation domain addresses a fundamental challenge in bug bounty hunting: **scale**. Modern target organizations expose thousands of subdomains, hundreds of API endpoints, and complex application architectures that are impossible to test thoroughly by hand. Automation bridges this gap by enabling hunters to:

- **Enumerate assets at scale** — Discover every subdomain, endpoint, and technology fingerprint across large target organizations
- **Scan for vulnerabilities systematically** — Run targeted vulnerability scans against every discovered asset with appropriate tool configurations
- **Validate findings automatically** — Filter false positives, confirm vulnerabilities, and prioritize findings by severity
- **Generate reports efficiently** — Create structured, reproducible reports from automated scan results
- **Monitor changes continuously** — Detect new subdomains, endpoint changes, and configuration drift that may introduce new attack surface

### What This Domain Covers

| Category | Description | Files |
|----------|-------------|-------|
| **Recon Automation** | Subdomain enumeration, port scanning, technology fingerprinting, cloud enumeration | 01-07 |
| **Vulnerability Scanning** | Auth testing, IDOR, SQLi, XSS, SSRF, CSRF, command injection, XXE, SSTI, JWT, deserialization | 08-20 |
| **Reporting & PoC** | Automated report generation, PoC development, target scouting | 21-23 |
| **Target Management** | Scope validation, asset tracking, change monitoring, alerting | 24-27 |
| **Data Analysis** | Data collection, result analysis, tool chaining, proxy integration | 28-31 |
| **Browser Automation** | Browser workflows, headless scripting, regex patterns, response analysis | 32-35 |
| **Advanced Testing** | Header injection, CORS, WebSocket, GraphQL, cloud enumeration | 36-40 |
| **Recon Advanced** | DNS extraction, email recon, social media OSINT | 41-43 |
| **Fingerprinting** | Framework detection, technology stack, endpoint mapping, content discovery, version detection | 44-47 |
| **Compliance & Orchestration** | Compliance checking, workflow orchestration | 48-50 |

### What This Domain Does NOT Cover

- **Basic vulnerability concepts** — See `Core-Prompts-Learning/` for educational modules
- **Hunting methodologies** — See `Core-Prompts-hunting/` for step-by-step hunting guides
- **Attack chains** — See `Advanced-Chaining-Techniques/` for multi-step exploitation
- **Post-exploitation** — See `Advanced-Persistence-Exploitation/` for persistence and lateral movement
- **Report writing quality** — See `Report-Writing-Mastery/` for report optimization

---

## Complete File Index

| # | File | Topic | Lines |
|---|------|-------|-------|
| 01 | `01-Subdomain-Enumeration-Automation.md` | Automating subdomain discovery with subfinder, amass, massdns, and custom wordlists. Covers parallelized DNS brute-forcing, certificate transparency mining, and passive enumeration aggregation from 10+ sources. | 500+ |
| 02 | `02-Port-Scanning-Automation.md` | Automated port scanning workflows with naabu, masscan, and nmap. Covers service detection, banner grabbing, rate-limited scanning, and result correlation. | 500+ |
| 03 | `03-Vulnerability-Scanning-Automation.md` | Nuclei template automation, custom template development, severity filtering, targeted scanning based on technology fingerprints. Covers scanning lifecycle from discovery to validation. | 500+ |
| 04 | `04-JavaScript-Analysis-Automation.md` | Automated JavaScript source analysis with LinkFinder, SecretFinder, and custom regex. Covers endpoint extraction, secret detection, API key harvesting, and obfuscated code analysis. | 500+ |
| 05 | `05-API-Endpoint-Discovery.md` | Automated API endpoint discovery through Swagger/OpenAPI enumeration, GraphQL introspection, parameter discovery, and traffic analysis. Covers REST, GraphQL, gRPC, and WebSocket APIs. | 500+ |
| 06 | `06-Parameter-Fuzzing-Automation.md` | Parameter fuzzing with ffuf, wfuzz, and custom wordlists. Covers hidden parameter discovery, value fuzzing, WAF bypass payloads, and intelligent wordlist generation. | 500+ |
| 07 | `07-Directory-Brute-Forcing.md` | Directory and file brute-forcing automation. Covers recursive enumeration, extension detection, backup file discovery, and response-code-based filtering. | 500+ |
| 08 | `09-Authentication-Testing-Automation.md` | Automated authentication flow testing — credential stuffing, session token analysis, MFA bypass detection, OAuth flow automation. | 500+ |
| 09 | `10-Session-Management-Testing.md` | Session management analysis automation — token entropy, session fixation, concurrent session handling, cookie security attribute validation. | 500+ |
| 10 | `11-IDOR-Detection-Automation.md` | IDOR detection through automated parameter manipulation, response comparison, and authorization boundary testing across multiple endpoints. | 500+ |
| 11 | `12-SQL-Injection-Automation.md` | SQL injection detection and exploitation automation with sqlmap, custom tamper scripts, and blind injection detection via timing analysis. | 500+ |
| 12 | `13-XSS-Detection-Automation.md` | XSS detection automation — reflected, stored, and DOM-based XSS scanning with custom payloads, context-aware injection, and WAF bypass techniques. | 500+ |
| 13 | `14-SSRF-Testing-Automation.md` | SSRF testing automation — internal service discovery, cloud metadata endpoint testing, blind SSRF detection via out-of-band channels. | 500+ |
| 14 | `15-CSRF-Testing-Automation.md` | CSRF token analysis and bypass automation — token predictability testing, SameSite cookie analysis, and cross-origin request generation. | 500+ |
| 15 | `16-Command-Injection-Automation.md` | Command injection detection through automated payload injection, response analysis, and blind command execution verification. | 500+ |
| 16 | `17-XXE-Testing-Automation.md` | XXE detection automation — blind XXE via out-of-band channels, error-based XXE, file read via external entities, SSRF via XXE. | 500+ |
| 17 | `18-SSTI-Testing-Automation.md` | SSTI detection and exploitation automation across Jinja2, Twig, Freemarker, ERB, and Velocity template engines. | 500+ |
| 18 | `19-JWT-Testing-Automation.md` | JWT vulnerability testing automation — algorithm confusion, key brute-forcing, token manipulation, signature stripping, and claim injection. | 500+ |
| 19 | `20-Deserialization-Testing.md` | Deserialization vulnerability detection across Java, PHP, Python, and .NET. Covers gadget chain discovery, payload generation, and blind detection. | 500+ |
| 20 | `21-Report-Generation-Automation.md` | Automated report generation from scan results — template-based reporting, screenshot automation, finding aggregation, and severity classification. | 500+ |
| 21 | `22-PoC-Development-Automation.md` | Automated PoC development — HTTP request replay, browser automation for DOM-based vulnerabilities, and reproducible exploitation scripts. | 500+ |
| 22 | `23-Target-Scouting-Automation.md` | Automated target scouting — program discovery, scope analysis, asset enumeration, and priority scoring for new bug bounty programs. | 500+ |
| 23 | `24-Scope-Validation-Automation.md` | Automated scope validation — DNS verification, asset ownership confirmation, and scope boundary enforcement to prevent out-of-scope testing. | 500+ |
| 24 | `25-Asset-Tracking-Automation.md` | Asset tracking systems — database-backed asset catalogs, change detection, asset scoring, and integration with scanning pipelines. | 500+ |
| 25 | `26-Change-Monitoring-Automation.md` | Change detection automation — DNS record monitoring, HTTP response comparison, technology stack change detection, and new endpoint alerting. | 500+ |
| 26 | `27-Notification-Alerting-Automation.md` | Notification and alerting systems — Slack/Discord/Telegram integration, email alerts, webhook notifications, and severity-based routing. | 500+ |
| 27 | `28-Data-Collection-Automation.md` | Automated data collection from multiple sources — API aggregation, web scraping, database queries, and unified data normalization. | 500+ |
| 28 | `29-Result-Analysis-Automation.md` | Result analysis automation — finding correlation, false positive reduction, severity classification, and trend analysis across scan runs. | 500+ |
| 29 | `30-Tool-Chaining-Automation.md` | Tool chaining and pipeline orchestration — connecting multiple tools into cohesive workflows, data format conversion, and error recovery. | 500+ |
| 30 | `31-Proxy-Integration-Automation.md` | Proxy integration automation — Burp Suite API integration, traffic interception automation, request manipulation, and response analysis pipelines. | 500+ |
| 31 | `32-Browser-Automation-Workflows.md` | Browser automation with Selenium, Playwright, and Puppeteer. Covers login flows, form interaction, JavaScript execution, and screenshot capture. | 500+ |
| 32 | `33-Headless-Browser-Scripting.md` | Headless browser scripting for DOM analysis, dynamic content rendering, SPA navigation, and JavaScript-heavy application testing. | 500+ |
| 33 | `34-Regex-Pattern-Automation.md` | Regex pattern automation for vulnerability detection — custom pattern libraries, response matching, and automated finding extraction. | 500+ |
| 34 | `35-Response-Analysis-Automation.md` | Response analysis automation — differential analysis, error pattern detection, information disclosure identification, and content-based routing. | 500+ |
| 35 | `36-Header-Injection-Testing.md` | Header injection testing automation — CRLF injection, HTTP response splitting, host header manipulation, and header-based access control bypass. | 500+ |
| 36 | `37-CORS-Testing-Automation.md` | CORS misconfiguration testing automation — origin reflection detection, null origin abuse, subdomain wildcard analysis, and preflight response analysis. | 500+ |
| 37 | `38-WebSocket-Testing-Automation.md` | WebSocket security testing automation — connection hijacking, cross-site WebSocket hijacking, message injection, and authentication bypass. | 500+ |
| 38 | `39-GraphQL-Testing-Automation.md` | GraphQL security testing automation — introspection abuse, batching attacks, field suggestion analysis, depth limiting bypass, and authorization testing. | 500+ |
| 39 | `40-Cloud-Service-Enumeration.md` | Cloud service enumeration automation — S3/GCS/Azure Blob discovery, Lambda/Functions enumeration, cloud-specific attack surface mapping. | 500+ |
| 40 | `41-DNS-Data-Extraction-Automation.md` | DNS data extraction automation — zone transfer attempts, DNS record analysis, mail server enumeration, and DNS-based subdomain discovery. | 500+ |
| 41 | `42-Email-Recon-Automation.md` | Email reconnaissance automation — email harvesting, email validation, SMTP testing, and email-based social engineering surface mapping. | 500+ |
| 42 | `43-Social-Media-OSINT-Automation.md` | Social media OSINT automation — profile discovery, credential correlation, social graph analysis, and leaked data aggregation. | 500+ |
| 43 | `44-Framework-Detection-Automation.md` | Framework and technology detection automation — CMS fingerprinting, JavaScript library identification, backend technology profiling. | 500+ |
| 44 | `45-Technology-Stack-Identification.md` | Full technology stack identification — server-side languages, databases, caching layers, CDN detection, and version extraction. | 500+ |
| 45 | `46-Endpoint-Mapping-Automation.md` | Endpoint mapping automation — crawling, sitemap generation, API endpoint cataloging, and endpoint relationship mapping. | 500+ |
| 46 | `47-Content-Discovery-Automation.md` | Content discovery automation — hidden file detection, backup discovery, admin panel finding, and sensitive path enumeration. | 500+ |
| 47 | `48-Version-Detection-Automation.md` | Version detection automation — software version extraction, end-of-life detection, known CVE correlation, and version-specific payload selection. | 500+ |
| 48 | `49-Compliance-Checking-Automation.md` | Compliance checking automation — security header validation, TLS configuration analysis, cookie security audit, and CSP evaluation. | 500+ |
| 49 | `50-Workflow-Orchestration-Automation.md` | Workflow orchestration — building complete automation platforms with task scheduling, dependency management, and parallel execution. | 500+ |

---

## Key Concepts

### 1. The Automation Pyramid

```
                    ┌───────────────┐
                    │   DECISION    │  ← AI/ML-driven prioritization
                    │   ENGINE      │
                    ├───────────────┤
                    │  VALIDATION   │  ← Auto-confirm findings, reduce FP
                    ├───────────────┤
                    │  EXPLOITATION │  ← Auto-exploit confirmed vulns
                    ├───────────────┤
                    │   SCANNING    │  ← Tool execution, payload injection
                    ├───────────────┤
                    │  ENUMERATION  │  ← Asset discovery, endpoint mapping
                    ├───────────────┤
                    │   RECON       │  ← Passive/active information gathering
                    └───────────────┘
```

Each layer builds upon the one below. Automation should progress from bottom to top — automate recon first, then enumeration, then scanning, etc.

### 2. Automation Maturity Levels

| Level | Name | Description | Example |
|-------|------|-------------|---------|
| 0 | Manual | Everything done by hand | Manually typing commands |
| 1 | Scripted | Individual tools wrapped in scripts | Bash script running subfinder |
| 2 | Chained | Multiple tools connected in pipelines | subfinder → httpx → nuclei |
| 3 | Orchestrated | Centralized workflow management | Python DAG with task dependencies |
| 4 | Intelligent | Auto-adaptive based on results | Dynamic scan depth based on findings |
| 5 | Autonomous | Self-healing, self-optimizing pipelines | ML-based prioritization and scheduling |

### 3. Tool Integration Patterns

**Pattern 1: Pipe-based Chaining**
```
subfinder -d target.com | httpx | nuclei -t templates/
```
Simple, composable, limited error handling.

**Pattern 2: File-based Staging**
```
subfinder → subdomains.txt → httpx → live.txt → nuclei → findings.json
```
Intermediate results saved, enables resumption and debugging.

**Pattern 3: API-based Orchestration**
```
Orchestrator → calls Tool API → receives structured output → routes to next stage
```
Full control, rich error handling, parallel execution.

**Pattern 4: Event-driven Architecture**
```
Event Bus → triggers handlers → produces new events → chains react
```
Scalable, decoupled, complex but powerful.

### 4. Data Flow Architecture

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  INPUT   │───▶│ PROCESS  │───▶│  STORE   │───▶│  OUTPUT  │
│          │    │          │    │          │    │          │
│ Targets  │    │ Scanners │    │ Database │    │ Reports  │
│ Wordlist │    │ Analyzers│    │ Files    │    │ Alerts   │
│ Configs  │    │ Validators│   │ Cache    │    │ Dashboards│
└──────────┘    └──────────┘    └──────────┘    └──────────┘
```

### 5. Error Handling Strategy

Effective automation must handle failures gracefully:

- **Retry Logic**: Exponential backoff for transient network failures
- **Circuit Breakers**: Stop scanning a target after N consecutive failures
- **Fallback Chains**: If primary tool fails, try alternative (e.g., subfinder → amass → DNS brute)
- **State Persistence**: Save scan progress to resume after interruptions
- **Alert on Critical Failures**: Notify when entire pipeline stages fail
- **Graceful Degradation**: Continue with partial results rather than failing entirely

### 6. Rate Limiting and Ethics

Automated testing must respect rate limits and legal boundaries:

- **Requests Per Second**: Configure per-target rate limits based on scope rules
- **Concurrent Connections**: Limit parallel connections to avoid DoS
- **Time Windows**: Schedule intensive scans during off-peak hours
- **Scope Validation**: Always verify targets are in-scope before scanning
- **User-Agent Rotation**: Use identifiable user-agents for accountability
- **Logging**: Maintain complete logs of all automated activities

---

## Automation Maturity Model

### Level 1: Manual with Scripts
- Individual tool commands wrapped in shell scripts
- Manual trigger, manual result analysis
- No state management or error recovery

### Level 2: Chained Pipelines
- Multiple tools connected via pipes or file handoff
- Automated sequential execution
- Basic error handling (skip failed targets)

### Level 3: Orchestrated Workflows
- Centralized workflow engine (Python, Make, Airflow)
- Task dependency graphs with parallel execution
- Result aggregation and storage in databases
- Automated notification on completion

### Level 4: Intelligent Automation
- Dynamic scan configuration based on target profile
- ML-based false positive reduction
- Adaptive scanning depth based on findings
- Automated prioritization and triage

### Level 5: Autonomous Platform
- Self-healing pipelines with automatic retry and fallback
- Continuous monitoring with delta-based scanning
- Automated report generation and submission
- Feedback loops from triage outcomes to scan optimization

---

## Recommended Learning Path

### Beginner: Start Here
1. `01-Subdomain-Enumeration-Automation.md` — Learn the foundation
2. `02-Port-Scanning-Automation.md` — Add service discovery
3. `03-Vulnerability-Scanning-Automation.md` — Core scanning automation
4. `30-Tool-Chaining-Automation.md` — Connect tools together
5. `21-Report-Generation-Automation.md` — Automate reporting

### Intermediate: Build Pipelines
6. `04-JavaScript-Analysis-Automation.md` — JS-specific automation
7. `05-API-Endpoint-Discovery.md` — API-focused recon
8. `06-Parameter-Fuzzing-Automation.md` — Fuzzing automation
9. `12-SQL-Injection-Automation.md` — Exploit automation
10. `28-Data-Collection-Automation.md` — Data aggregation

### Advanced: Scale Operations
11. `25-Change-Monitoring-Automation.md` — Continuous monitoring
12. `26-Notification-Alerting-Automation.md` — Alert systems
13. `31-Proxy-Integration-Automation.md` — Burp integration
14. `32-Browser-Automation-Workflows.md` — Browser automation
15. `50-Workflow-Orchestration-Automation.md` — Full orchestration

### Expert: Build Platforms
16. `14-Parallel-Processing-Optimization.md` — Scale horizontally
17. `18-Scalability-Design-Patterns.md` — Architecture patterns
18. `40-Cloud-Automation.md` — Cloud-native automation
19. `48-Orchestration-Frameworks.md` — Framework selection
20. `49-Automation-Standards.md` — Standards and governance

---

## Tool Integrations

### Primary Tools

| Tool | Purpose | Automation Integration |
|------|---------|----------------------|
| **subfinder** | Subdomain enumeration | Pipe to httpx, output to file |
| **httpx** | HTTP probing | Technology detection, status analysis |
| **nuclei** | Vulnerability scanning | Template-based, severity filtering |
| **ffuf** | Directory fuzzing | Custom wordlists, filter rules |
| **sqlmap** | SQL injection | Automated exploitation, tamper scripts |
| **katana** | Web crawling | JavaScript analysis, form discovery |
| **naabu** | Port scanning | Service discovery, protocol detection |
| **amass** | Subdomain enumeration | Passive + active, OWASP integration |
| **masscan** | Fast port scanning | Large-scale port discovery |
| **Burp Suite** | Web app testing | API automation, extensions |

### Scripting Languages

| Language | Use Case | Strengths |
|----------|----------|-----------|
| **Python** | Tool integration, data processing | Rich libraries, API support |
| **Bash** | Pipeline chaining, quick scripts | Native pipe support, fast |
| **Go** | Custom tool development | Performance, concurrency |
| **JavaScript** | Browser automation, API testing | Node.js ecosystem |

### Infrastructure

| Component | Purpose | Options |
|-----------|---------|---------|
| **Containerization** | Tool isolation | Docker, Podman |
| **Orchestration** | Task scheduling | Airflow, Prefect, cron |
| **Storage** | Result persistence | PostgreSQL, SQLite, S3 |
| **Monitoring** | Pipeline health | Grafana, Prometheus |
| **CI/CD** | Pipeline deployment | GitHub Actions, GitLab CI |

---

## How to Use These Prompts

### Step 1: Identify Your Automation Need
Determine which manual process you want to automate. Start with the most repetitive, time-consuming tasks.

### Step 2: Select the Relevant Prompt
Choose the prompt that matches your automation goal. Each prompt provides:
- Complete methodology for automating the specific task
- Tool configurations and command templates
- Error handling strategies
- Output format specifications
- Integration patterns with other tools

### Step 3: Adapt to Your Environment
Customize the prompts for your specific setup:
- Adjust file paths and directory structures
- Configure rate limits for your target environment
- Set up authentication for API-based tools
- Define output formats compatible with your pipeline

### Step 4: Build Incrementally
Start with a simple script, validate it works, then progressively add:
- Error handling and retry logic
- Parallel execution for speed
- Result storage and analysis
- Notification and alerting
- Integration with other pipeline stages

---

## Cross-References

| Domain | Relationship | Use When |
|--------|-------------|----------|
| `Core-Prompts-hunting/` | Provides hunting methodologies that automation implements | Need vulnerability-specific automation approaches |
| `Core-Prompts-Learning/` | Explains concepts that automation operationalizes | Need to understand what you are automating |
| `Reconnaissance-Deep-Dive/` | Provides recon techniques that automation scales | Need advanced recon to automate |
| `Advanced-Chaining-Techniques/` | Chains that automation can execute end-to-end | Automating multi-step exploitation |
| `Advanced-Persistence-Exploitation/` | Post-exploitation tasks that automation can streamline | Automating post-compromise assessment |
| `Report-Writing-Mastery/` | Report standards that automated reports must meet | Ensuring automated reports meet quality bar |
| `Automation-Efficiency/` | Efficiency patterns that enhance automation | Optimizing pipeline performance |
| `Specialized-Targets/` | Target-specific considerations for automation | Automating tests for specific platforms |
| `Bug-Bounty-Program-Strategy/` | Program selection that guides automation priorities | Choosing which targets to automate first |
| `bug-bounty-support/` | Reference materials for tool configurations | Looking up specific tool usage patterns |

---

## Tips and Best Practices

### 1. Start Small, Scale Gradually
Do not try to build a complete automation platform on day one. Start by automating a single workflow (e.g., subdomain enumeration + HTTP probing + nuclei scan). Get it working reliably, then add complexity.

### 2. Save Intermediate Results
Always save the output of each pipeline stage to a file. This enables:
- Debugging failed runs without re-running everything
- Resuming interrupted pipelines
- Analyzing results without re-scanning
- Building multiple pipelines from the same data

### 3. Log Everything
Maintain detailed logs of every automated action. Include timestamps, tool versions, target specifications, and exact commands run. This is essential for:
- Debugging pipeline failures
- Proving scope compliance
- Reproducing results for validation
- Auditing automated activities

### 4. Use Meaningful Naming Conventions
Organize output files with consistent naming:
```
{target}_{tool}_{timestamp}.{ext}
example.com_nuclei_20240115_143022.json
```

### 5. Implement Circuit Breakers
If a tool fails N times against a target, stop scanning that target and move on. Continuing to scan a broken target wastes time and may trigger rate limiting.

### 6. Version Control Everything
Track your scripts, configurations, and wordlists in git. This enables rollback, collaboration, and reproducibility.

### 7. Test Against Known Vulnerable Applications
Validate your automation pipelines against intentionally vulnerable applications (DVWA, Juice Shop, HackTheBox) before deploying against real targets.

### 8. Respect Rate Limits
Configure appropriate delays between requests. Most bug bounty programs specify rate limits in their rules. Violating these can result in disqualification.

### 9. Validate Before Reporting
Never auto-submit findings. Use automation for discovery, but always manually validate before submitting reports. False positives damage your reputation.

### 10. Document Your Pipeline
Maintain documentation for your automation stack. Include setup instructions, configuration options, and troubleshooting guides. Future-you will thank present-you.

---

## Severity Escalation Through Automation

Automation enables hunters to identify chains that elevate individual findings:

| Individual Finding | Severity | Automated Chain | Elevated Severity |
|-------------------|----------|-----------------|-------------------|
| Verbose error message | Info | Error + SQLi extraction | Critical |
| Open redirect | Low | Redirect + OAuth token theft | Critical |
| CORS misconfiguration | Low | CORS + XSS data exfiltration | High |
| Information disclosure | Info | Disclosure + credential extraction | High |
| Missing rate limit | Low | Rate limit + account brute-force | High |
| IDOR on profile | Medium | IDOR + admin panel access | Critical |
| Subdomain takeover | Medium | Takeover + internal API access | Critical |

---

## Common Chain Patterns

| Pattern | Input | Chain | Output |
|---------|-------|-------|--------|
| **Recon → Vuln → Report** | Target domain | Enumerate → Scan → Validate → Report | Findings |
| **JS Analysis → API Discovery → Auth Bypass** | JavaScript files | Extract endpoints → Test auth → Bypass | Privilege escalation |
| **Subdomain → Port Scan → Service Exploit** | Domain | Enumerate → Scan ports → Identify services | RCE / Data access |
| **Crawl → Parameter Discovery → Fuzzing** | Web app | Crawl → Find params → Fuzz values | Injection vulnerabilities |
| **Cloud Enum → Bucket Listing → Data Exfil** | Organization | Find buckets → Check permissions → List data | Sensitive data exposure |
| **GraphQL Introspection → Query Fuzzing → IDOR** | API endpoint | Introspect schema → Test resolvers → Manipulate IDs | Cross-user data access |
| **Email Harvest → Password Spray → Account Access** | Domain | Collect emails → Spray creds → Access accounts | Compromised accounts |

---

*Part of the Prompt-Hunting framework — 12 specialized domains for comprehensive bug bounty operations.*
