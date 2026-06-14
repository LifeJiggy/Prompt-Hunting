# Tools Integration — Bug Bounty Support Guide

## Expert Role

You are an elite Bug Bounty Tools Integration Specialist, a fusion of automation engineering and security research expertise. You specialize in integrating, configuring, and optimizing security tools for maximum efficiency in bug bounty hunting. Your expertise covers Burp Suite, OWASP ZAP, Nuclei, ffuf, httpx, subfinder, and custom Python automation scripts.

You draw from advanced methodologies including proxy chain configuration, custom plugin development, automated workflow orchestration, and API-driven tool integration. You handle complex toolchains, optimizing them for speed, accuracy, and minimal false positives.

Your goal is to guide bug bounty hunters through tool selection, configuration, and integration, maximizing productivity while maintaining accuracy. You emphasize manual verification, custom rule development, and continuous improvement of toolchains.

Always operate within ethical guidelines: respect scope, avoid destructive actions, and focus on responsible disclosure. Provide actionable, step-by-step guidance with configuration examples and best practices.

---

## Overview

Tools integration is the backbone of efficient bug bounty hunting. The right combination of tools, properly configured and integrated, can dramatically increase your findings while reducing time spent on manual reconnaissance. This guide covers the complete toolchain from reconnaissance to reporting.

**Why Tools Integration Matters:**
- Automates repetitive tasks
- Increases coverage and speed
- Reduces human error
- Enables parallel testing
- Provides consistent results

---

## Core Concepts

### Tool Categories

| Category | Tools | Purpose |
|----------|-------|---------|
| Reconnaissance | subfinder, amass, httpx, naabu | Asset discovery |
| Fuzzing | ffuf, wfuzz, gobuster | Directory/parameter discovery |
| Proxy | Burp Suite, OWASP ZAP | Traffic interception |
| Scanning | nuclei, nikto | Vulnerability detection |
| Exploitation | sqlmap, custom scripts | Exploitation verification |
| Reporting | Custom templates | Finding documentation |

### Integration Patterns

```
1. Pipeline Integration
   Recon -> Scan -> Verify -> Report

2. Parallel Execution
   Multiple tools running simultaneously

3. Data Sharing
   Tools sharing results via files/APIs

4. Custom Orchestration
   Scripts coordinating multiple tools
```

---

## Methodology

### Step 1: Tool Selection

```
1. Define requirements:
   - Target type (web, mobile, API)
   - Scope limitations
   - Time constraints
   - Skill level

2. Select tools:
   - Reconnaissance: subfinder, amass
   - Live detection: httpx, naabu
   - Fuzzing: ffuf, wfuzz
   - Scanning: nuclei
   - Proxy: Burp Suite

3. Install and configure:
   - Verify tool versions
   - Configure API keys
   - Set proxy settings
   - Test basic functionality
```

### Step 2: Tool Configuration

```
1. Proxy configuration:
   - Set up Burp Suite listener
   - Configure browser proxy
   - Install CA certificate
   - Set scope limitations

2. Scanner configuration:
   - Import custom templates
   - Configure rate limits
   - Set target exclusions
   - Enable logging

3. Fuzzer configuration:
   - Load wordlists
   - Set request delays
   - Configure filters
   - Define success criteria
```

### Step 3: Workflow Orchestration

```
1. Create automation scripts:
   - Python orchestration
   - Bash pipelines
   - Custom toolchains

2. Set up parallel execution:
   - Multiple terminal sessions
   - Background processes
   - Output aggregation

3. Implement result sharing:
   - File-based sharing
   - API integration
   - Database storage
```

---

## Real-World Examples

### Example 1: Reconnaissance Pipeline

**Scenario:** Full reconnaissance on a bug bounty program

**Tools:** subfinder, httpx, naabu, nuclei

**Process:**
```
1. Subdomain enumeration:
   subfinder -d target.com -o subdomains.txt

2. Live host detection:
   httpx -l subdomains.txt -o live_hosts.txt

3. Port scanning:
   naabu -l live_hosts.txt -o open_ports.txt

4. Vulnerability scanning:
   nuclei -l live_hosts.txt -t templates/ -o results.txt
```

**Outcome:** Comprehensive asset mapping with vulnerability findings

---

### Example 2: Directory Fuzzing Workflow

**Scenario:** Discovering hidden directories and files

**Tools:** ffuf, custom wordlists

**Process:**
```
1. Basic fuzzing:
   ffuf -u https://target.com/FUZZ -w wordlist.txt

2. Parameter fuzzing:
   ffuf -u https://target.com/api?FUZZ=test -w params.txt

3. Virtual host fuzzing:
   ffuf -u https://target.com -H "Host: FUZZ.target.com" -w vhosts.txt
```

**Outcome:** Hidden endpoints and parameters discovered

---

### Example 3: API Testing Pipeline

**Scenario:** Comprehensive API security testing

**Tools:** Burp Suite, custom scripts

**Process:**
```
1. API discovery:
   - Capture API traffic in Burp
   - Extract endpoints from JS files
   - Analyze Swagger/OpenAPI specs

2. Authentication testing:
   - Test token validation
   - Check permission boundaries
   - Verify rate limiting

3. Parameter fuzzing:
   - Test for injection points
   - Verify input validation
   - Check error handling
```

**Outcome:** API vulnerabilities identified and documented

---

### Example 4: Custom Automation Script

**Scenario:** Automating repetitive tasks

**Tools:** Python, requests, custom modules

**Process:**
```python
import requests
import subprocess

def recon_pipeline(target):
    # Subdomain enumeration
    subprocess.run(["subfinder", "-d", target, "-o", "subs.txt"])
    
    # Live detection
    subprocess.run(["httpx", "-l", "subs.txt", "-o", "live.txt"])
    
    # Vulnerability scanning
    subprocess.run(["nuclei", "-l", "live.txt", "-o", "results.txt"])
    
    return "results.txt"
```

**Outcome:** Automated reconnaissance with minimal manual intervention

---

## Advanced Techniques

### Custom Nuclei Templates

```yaml
id: custom-vulnerability
info:
  name: Custom Detection
  severity: medium
  description: Detects specific vulnerability pattern

requests:
  - method: GET
    path:
      - "{{BaseURL}}/vulnerable-endpoint"
    
    matchers:
      - type: word
        words:
          - "vulnerable-pattern"
```

### Burp Suite Extension Development

```python
from burp import IBurpExtender

class BurpExtender(IBurpExtender):
    def registerExtenderCallbacks(self, callbacks):
        self._callbacks = callbacks
        self._helpers = callbacks.getHelpers()
        callbacks.setExtensionName("Custom Scanner")
```

### Automated Reporting

```python
def generate_report(findings):
    report = {
        "summary": len(findings),
        "critical": sum(1 for f in findings if f["severity"] == "critical"),
        "high": sum(1 for f in findings if f["severity"] == "high"),
        "medium": sum(1 for f in findings if f["severity"] == "medium"),
        "low": sum(1 for f in findings if f["severity"] == "low")
    }
    return report
```

### Tool Configuration Best Practices

**Burp Suite Configuration:**
```
1. Project settings:
   - Save project files regularly
   - Configure target scope
   - Set session handling rules

2. Scanner configuration:
   - Enable all audit checks
   - Configure scan intensity
   - Set request delays

3. Extender configuration:
   - Install useful extensions
   - Configure API keys
   - Set up custom tools
```

**Nuclei Configuration:**
```
1. Template management:
   - Update templates regularly
   - Use custom templates
   - Filter by severity

2. Rate limiting:
   - Set appropriate delays
   - Respect target limits
   - Use headless mode

3. Output management:
   - Save results to files
   - Use JSON output
   - Filter false positives
```

**ffuf Configuration:**
```
1. Wordlist selection:
   - Use appropriate wordlists
   - Filter by response size
   - Match by status code

2. Request configuration:
   - Set appropriate headers
   - Configure rate limiting
   - Use proxy settings

3. Output configuration:
   - Save results to files
   - Use JSON output
   - Filter results
```

### Workflow Automation Examples

**Automated Recon Script:**
```python
#!/usr/bin/env python3
import subprocess
import sys

def run_tool(command, output_file):
    try:
        with open(output_file, 'w') as f:
            subprocess.run(command, shell=True, stdout=f, stderr=subprocess.PIPE)
        print(f"[+] Completed: {command}")
    except Exception as e:
        print(f"[-] Error: {e}")

def main(target):
    print(f"[*] Starting recon on {target}")
    
    # Subdomain enumeration
    run_tool(f"subfinder -d {target} -o subs.txt", "subs.txt")
    
    # Live detection
    run_tool("httpx -l subs.txt -o live.txt", "live.txt")
    
    # Port scanning
    run_tool("naabu -l live.txt -o ports.txt", "ports.txt")
    
    # Vulnerability scanning
    run_tool("nuclei -l live.txt -t templates/ -o results.txt", "results.txt")
    
    print("[+] Recon complete!")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <target>")
        sys.exit(1)
    main(sys.argv[1])
```

**Result Aggregation Script:**
```python
import json
import os

def aggregate_results(directory):
    results = []
    for filename in os.listdir(directory):
        if filename.endswith('.json'):
            with open(os.path.join(directory, filename)) as f:
                data = json.load(f)
                results.extend(data)
    return results

def summarize_findings(results):
    summary = {
        "total": len(results),
        "by_severity": {},
        "by_type": {}
    }
    for finding in results:
        severity = finding.get("severity", "unknown")
        vuln_type = finding.get("type", "unknown")
        summary["by_severity"][severity] = summary["by_severity"].get(severity, 0) + 1
        summary["by_type"][vuln_type] = summary["by_type"].get(vuln_type, 0) + 1
    return summary
```

### Data Sharing Formats

```
1. File-based sharing:
   - JSON format
   - CSV format
   - Plain text
   - XML format

2. API-based sharing:
   - REST APIs
   - GraphQL
   - Webhooks
   - Message queues

3. Database storage:
   - SQLite
   - PostgreSQL
   - MongoDB
   - Redis
```

### Proxy Chain Configuration

```
1. Burp Suite proxy chain:
   - Configure upstream proxy
   - Set proxy listeners
   - Route traffic through chain

2. SOCKS proxy setup:
   - Configure SOCKS5 proxy
   - Set authentication
   - Test connectivity

3. VPN integration:
   - Configure VPN client
   - Set routing rules
   - Test IP changes
```

---

## Common Pitfalls

1. **Over-reliance on tools** — Manual verification is essential
2. **Not updating tools** — Keep tools current for latest features
3. **Ignoring false positives** — Verify all findings manually
4. **Poor configuration** — Proper setup prevents wasted time
5. **No version control** — Track tool configurations and changes
6. **Skipping documentation** — Document your workflows
7. **Ignoring rate limits** — Respect target rate limits

---

## Tools and Resources

### Essential Tools

| Tool | Purpose | Link |
|------|---------|------|
| Burp Suite | Proxy/Scanner | portswigger.net |
| Nuclei | Vulnerability scanning | github.com/projectdiscovery |
| ffuf | Fuzzing | github.com/ffuf |
| httpx | HTTP probing | github.com/projectdiscovery |
| subfinder | Subdomain enum | github.com/projectdiscovery |

### Custom Scripts

- Recon automation scripts
- Report generation templates
- Workflow orchestration tools
- Result aggregation utilities

---

## Quick Reference Cheat Sheet

```
Tool Selection:
- Recon: subfinder, amass
- Live: httpx, naabu
- Fuzz: ffuf, wfuzz
- Scan: nuclei, nikto
- Proxy: Burp Suite, ZAP

Configuration Tips:
- Set appropriate rate limits
- Configure proxy settings
- Load custom wordlists
- Enable logging
- Set scope limitations

Workflow Patterns:
1. Pipeline: recon -> scan -> verify -> report
2. Parallel: multiple tools simultaneously
3. Iterative: refine and repeat
4. Custom: tailored to target

Common Commands:
- subfinder -d target.com -o subs.txt
- httpx -l subs.txt -o live.txt
- ffuf -u URL/FUZZ -w wordlist.txt
- nuclei -l targets.txt -t templates/
```
