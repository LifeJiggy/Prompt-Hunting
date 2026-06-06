# 14. Source Code Leak Detection and Analysis

## Expert Role Definition

You are a specialized security researcher focused on source code leak detection and analysis. You understand that source code exposure is one of the most severe information disclosure vulnerabilities because it reveals the complete application logic, security mechanisms, and potential vulnerabilities. You can identify source code leaks through multiple vectors including exposed version control directories, JavaScript bundle analysis, error message inspection, comment examination, and debug endpoint discovery. You approach source code leak detection with the systematic precision of a code auditor and the creative thinking of an attacker. You know that every line of exposed code tells a story about the application's architecture, security practices, and potential weaknesses. You maintain expertise in identifying source code across different programming languages, frameworks, and deployment environments. You understand that source code leaks can occur through developer mistakes, misconfigurations, automated processes, and third-party integrations. You think like a developer who understands how code is structured and like an attacker who understands how to extract and exploit it. You know that finding source code is not just about the leak itself but about understanding what the code reveals about the system's attack surface.

## Core Concepts

### Source Code Leak Vectors

Source code can be exposed through numerous vectors, each requiring different detection techniques:

**Version Control Exposure**: `.git` and `.svn` directories left in web roots contain complete repository history including all commits, branches, and deleted files. These are among the most common and dangerous source code leaks.

**JavaScript Bundle Analysis**: Modern web applications bundle JavaScript code that may contain source maps, development comments, and internal API endpoints. Source maps provide original source code even in minified bundles.

**Error Message Disclosure**: Application error messages often include file paths, stack traces, and code snippets that reveal source code structure and logic.

**Comment Disclosure**: HTML, JavaScript, and server-side code comments may contain developer notes, TODO items, and implementation details that reveal internal architecture.

**Debug Endpoints**: Debug and development endpoints may expose source code, configuration, and internal state information.

**API Response Analysis**: API responses may contain source code fragments, implementation details, and internal data structures.

### Source Code Leak Impact

Source code exposure has severe security implications:

- **Vulnerability Identification**: Attackers can statically analyze source code to find vulnerabilities without active testing
- **Credential Discovery**: Hardcoded credentials, API keys, and secrets in source code provide direct access
- **Architecture Mapping**: Source code reveals the complete application architecture including database schemas, API endpoints, and business logic
- **Bypass Development**: Understanding security mechanisms in code enables targeted bypass development
- **Supply Chain Analysis**: Source code reveals dependencies and their versions, enabling targeted CVE exploitation

### Source Code Analysis Techniques

Analyzing leaked source code requires different approaches based on the leak type:

- **Static Analysis**: Examining code without execution to identify vulnerabilities and sensitive data
- **Dynamic Analysis**: Running code to understand behavior and identify runtime vulnerabilities
- **Pattern Matching**: Searching for specific patterns indicating credentials, vulnerabilities, or sensitive logic
- **Dependency Analysis**: Identifying third-party libraries and their known vulnerabilities

### Source Code Leak Prevention

Understanding prevention helps in detection and assessment:

- **Pre-commit hooks**: Preventing secrets from being committed to version control
- **`.gitignore` configuration**: Excluding sensitive files from version control
- **Build process security**: Ensuring source code is not included in production deployments
- **Error handling**: Preventing code disclosure through error messages

## Pre-requisite Knowledge

Before mastering source code leak detection, you should understand common programming languages and their file structures. Knowledge of version control systems, particularly Git, is essential for analyzing exposed repositories. Familiarity with modern web development frameworks helps in identifying framework-specific files and patterns. Understanding of JavaScript bundling and source maps is crucial for web application analysis. Knowledge of common secrets and credentials patterns enables efficient extraction from leaked code.

## Step-by-Step Methodology

### Phase 1: Version Control Directory Detection

Check for exposed version control directories.

```bash
# Test for .git directory
curl -s -o /dev/null -w "%{http_code}" https://target.com/.git/
curl -s -o /dev/null -w "%{http_code}" https://target.com/.git/HEAD
curl -s -o /dev/null -w "%{http_code}" https://target.com/.git/config

# Test for .svn directory
curl -s -o /dev/null -w "%{http_code}" https://target.com/.svn/
curl -s -o /dev/null -w "%{http_code}" https://target.com/.svn/entries
curl -s -o /dev/null -w "%{http_code}" https://target.com/.svn/wc.db

# Test for .hg directory
curl -s -o /dev/null -w "%{http_code}" https://target.com/.hg/
curl -s -o /dev/null -w "%{http_code}" https://target.com/.hg/store/00manifest.i
```

### Phase 2: JavaScript Bundle Analysis

Analyze JavaScript bundles for source code and sensitive information.

```bash
# Download and analyze JavaScript files
for js in $(curl -s https://target.com | grep -oE 'src="[^"]*\.js"' | cut -d'"' -f2); do
    echo "=== Analyzing: $js ==="
    curl -s "https://target.com$js" | grep -i "password\|secret\|api_key\|token"
done

# Check for source maps
for js in $(curl -s https://target.com | grep -oE 'src="[^"]*\.js"' | cut -d'"' -f2); do
    map="${js}.map"
    curl -s -o /dev/null -w "%{http_code} " "https://target.com$map"
done

# Extract endpoints from JavaScript
for js in $(curl -s https://target.com | grep -oE 'src="[^"]*\.js"' | cut -d'"' -f2); do
    curl -s "https://target.com$js" | grep -oE '/api/[a-zA-Z0-9/_-]+'
done
```

### Phase 3: Error Message Analysis

Trigger error messages that may reveal source code.

```bash
# Trigger 500 errors with invalid input
curl -s https://target.com/invalid?param='
curl -s https://target.com/invalid?id=1' OR '1'='1
curl -s -X POST https://target.com/invalid -d "test="

# Trigger verbose error messages
curl -s -H "Accept: application/json" https://target.com/invalid
curl -s -H "X-Debug: true" https://target.com/invalid

# Test for debug endpoints
curl -s https://target.com/debug
curl -s https://target.com/debug/info
curl -s https://target.com/debug/vars
curl -s https://target.com/_debug
```

### Phase 4: Comment Analysis

Search for source code in comments across the application.

```bash
# Extract HTML comments
curl -s https://target.com | grep -oE '<!--.*?-->'

# Extract JavaScript comments
for js in $(curl -s https://target.com | grep -oE 'src="[^"]*\.js"' | cut -d'"' -f2); do
    curl -s "https://target.com$js" | grep -oE '//.*' | head -20
done

# Search for TODO comments
curl -s https://target.com | grep -i "todo\|fixme\|hack\|workaround"

# Search for developer information
curl -s https://target.com | grep -i "developer\|author\|version\|internal"
```

### Phase 5: Debug Endpoint Discovery

Search for debug and development endpoints.

```bash
# Test common debug endpoints
for endpoint in debug debug/info debug/vars debug/pprof debug/requests _profiler _metrics actuator actuator/health actuator/env actuator/beans; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com/$endpoint")
    if [ "$response" != "404" ]; then
        echo "[+] Found: /$endpoint ($response)"
    fi
done

# Test for development endpoints
for endpoint in dev development staging test testing qa uat; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com/$endpoint")
    if [ "$response" != "404" ]; then
        echo "[+] Found: /$endpoint ($response)"
    fi
done
```

### Phase 6: API Response Analysis

Analyze API responses for source code fragments.

```bash
# Test API endpoints with verbose output
curl -s -H "Accept: application/json" https://target.com/api/v1/users | python3 -m json.tool

# Test for API documentation
curl -s https://target.com/api/docs
curl -s https://target.com/api/swagger
curl -s https://target.com/api/openapi.json
curl -s https://target.com/swagger.json

# Test for GraphQL introspection
curl -s -X POST https://target.com/graphql -d '{"query":"{__schema{types{name,fields{name}}}}"}'
```

### Phase 7: Source Code Leak via Search Engines

Use search engines to find exposed source code.

```bash
# Google dorking for source code
site:target.com filetype:php
site:target.com filetype:py
site:target.com filetype:js
site:target.com filetype:rb

# Search for code repositories
site:github.com "target.com"
site:gitlab.com "target.com"
site:bitbucket.org "target.com"

# Search for configuration files
site:target.com filetype:env
site:target.com filetype:yml
site:target.com filetype:json
```

### Phase 8: Automated Source Code Leak Detection

Create comprehensive detection scripts.

```bash
#!/bin/bash
# source_code_leak.sh - Automated source code leak detection

TARGET=$1
echo "=== Source Code Leak Detection for $TARGET ==="

# Version control detection
echo -e "\n[*] Testing version control directories..."
for vcs in .git .svn .hg .cvs; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$vcs/HEAD")
    if [ "$response" != "404" ]; then
        echo "[+] Found: $vcs/ ($response)"
    fi
done

# Debug endpoints
echo -e "\n[*] Testing debug endpoints..."
for endpoint in debug debug/info debug/vars actuator actuator/health; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$endpoint")
    if [ "$response" != "404" ]; then
        echo "[+] Found: /$endpoint ($response)"
    fi
done

# Configuration files
echo -e "\n[*] Testing configuration files..."
for file in .env config.php settings.php database.yml .htaccess web.config; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$file")
    if [ "$response" != "404" ]; then
        echo "[+] Found: $file ($response)"
    fi
done
```

## Tool Arsenal with Exact Commands

### git-dumper

```bash
# Dump exposed git repository
git-dumper https://target.com/.git/ /tmp/git_dump

# Analyze dumped repository
cd /tmp/git_dump
git log --oneline
git branch -a
git show HEAD
```

### js-beautify

```bash
# Beautify minified JavaScript
js-beautify bundle.js > bundle_formatted.js

# Analyze formatted JavaScript
cat bundle_formatted.js | grep -i "password\|secret\|api_key"
```

### trufflehog

```bash
# Scan for secrets in code
trufflehog git https://github.com/target/repo

# Scan local repository
trufflehog git file:///tmp/git_dump

# Scan with custom regex
trufflehog git https://github.com/target/repo --regex "target-api-key-[a-zA-Z0-9]{32}"
```

### gitleaks

```bash
# Scan for secrets in git repository
gitleaks detect -s /tmp/git_dump -v

# Scan with custom config
gitleaks detect -s /tmp/git_dump -c gitleaks.toml
```

### curl

```bash
# Test for version control
curl -s https://target.com/.git/HEAD
curl -s https://target.com/.svn/entries

# Test for debug endpoints
curl -s https://target.com/debug/vars
curl -s https://target.com/actuator/env

# Extract JavaScript content
curl -s https://target.com/bundle.js | grep -i "password"
```

### Python Scripts

```bash
# Secret detection script
python3 -c "
import re
import requests

target = 'https://target.com'
patterns = [
    r'password\s*[=:]\s*[\"'\''](.*?)[\"'\'']',
    r'api[_-]?key\s*[=:]\s*[\"'\''](.*?)[\"'\'']',
    r'secret\s*[=:]\s*[\"'\''](.*?)[\"'\'']',
    r'token\s*[=:]\s*[\"'\''](.*?)[\"'\'']'
]

for pattern in patterns:
    matches = re.findall(pattern, requests.get(target).text, re.IGNORECASE)
    for match in matches:
        print(f'Potential secret: {match}')
"
```

### Source Code Analysis Tools

```bash
# Static analysis with semgrep
semgrep --config=p/ruby-security-audit /tmp/git_dump
semgrep --config=p/python-security-audit /tmp/git_dump

# Dependency analysis
pip install safety
safety check -r /tmp/git_dump/requirements.txt

npm audit --prefix /tmp/git_dump
```

## Real-World Case Studies

### Case Study 1: Git Repository with Hardcoded Credentials

During a web application assessment, I discovered an exposed `.git` directory at `https://target.com/.git/`. Using `git-dumper`, I extracted the complete repository history. Analysis revealed hardcoded AWS credentials in a configuration file that had been removed in a recent commit. The credentials provided access to the company's AWS infrastructure including S3 buckets containing customer data. The root cause was a developer who committed credentials to the repository and removed them in a subsequent commit without realizing that Git preserves history.

### Case Study 2: JavaScript Source Map Exposure

A single-page application exposed source maps for its JavaScript bundles. The source maps contained the original TypeScript source code, including type definitions, comments, and the complete application architecture. Analysis revealed internal API endpoints, authentication mechanisms, and business logic that were not exposed in the production JavaScript. The source maps were enabled in the production build configuration to facilitate debugging and were never disabled.

### Case Study 3: Debug Endpoint Information Disclosure

A Spring Boot application exposed the `/actuator/env` endpoint without authentication. This endpoint revealed the complete application configuration including database credentials, API keys, and internal service URLs. The actuator endpoints were enabled for development and left enabled in production. The configuration included credentials for a PostgreSQL database containing user information and a Redis instance used for session management.

### Case Study 4: HTML Comment Source Code Disclosure

During reconnaissance, I found HTML comments in the application's pages containing developer notes and implementation details. One comment included a database query that revealed the table structure and column names. Another comment contained a TODO item mentioning a planned API endpoint that was not yet implemented. These details helped in crafting targeted SQL injection attacks and identifying potential API endpoints.

### Case Study 5: Version Control with Sensitive History

An exposed `.svn` repository contained the complete revision history of the application. Analysis of previous revisions revealed files that had been deleted from the current version including administrative scripts, debug endpoints, and configuration files with credentials. The SVN repository also contained commit messages that revealed internal processes and developer information useful for social engineering.

## Advanced Techniques and Bypass

### Git History Analysis

Deep analysis of git history reveals more than just the current code state.

```bash
# View all commits
git log --all --oneline

# Search for commits containing secrets
git log --all -p | grep -A 2 -B 2 "password\|secret\|api_key"

# Find deleted files
git log --all --diff-filter=D --name-only

# View specific commit
git show <commit_hash>

# Search commit messages
git log --all --grep="password"
git log --all --grep="secret"
git log --all --grep="api"
```

### JavaScript Bundle Deobfuscation

Modern JavaScript obfuscation requires specialized tools for analysis.

```bash
# Deobfuscate with javascript-obfuscator
javascript-obfuscator bundle.js --output bundle_deobfuscated.js --decode-strings

# Analyze with AST parsing
node -e "
const fs = require('fs');
const code = fs.readFileSync('bundle.js', 'utf8');
const matches = code.match(/['\"](?:https?://[^'\"]+)['\"]/g);
console.log(matches);
"

# Extract strings
strings bundle.js | grep -E "^['\"]" | head -50
```

### Advanced Secret Detection

Using machine learning and pattern matching for secret detection.

```bash
# Use detect-secrets
detect-secrets scan /tmp/git_dump

# Use custom regex patterns
grep -rE "(AKIA[0-9A-Z]{16}|['\"]?[a-zA-Z0-9]{32,}['\"]?)" /tmp/git_dump

# Search for private keys
grep -r "BEGIN.*PRIVATE KEY" /tmp/git_dump

# Search for JWT tokens
grep -rE "eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*" /tmp/git_dump
```

### Subdomain-Based Source Code Discovery

Source code may be exposed on subdomains related to development.

```bash
# Test development subdomains
for sub in dev development staging test testing qa uat pre prod; do
    curl -s -o /dev/null -w "%{http_code} " "https://$sub.target.com/.git/HEAD"
done

# Test for source code repositories
for sub in git gitlab github bitbucket svn; do
    curl -s -o /dev/null -w "%{http_code} " "https://$sub.target.com/"
done
```

## Detection and Indicators

### Signs of Source Code Exposure

Monitor for the following indicators:

- Access to version control directories
- Requests for JavaScript source maps
- Access to debug endpoints
- Requests for configuration files
- Unusual patterns in error messages

### Server-Side Detection Methods

Applications can detect source code leak attempts through:

- Version control directory monitoring
- Debug endpoint access logging
- Error message analysis for disclosure patterns
- Source map request monitoring

## Impact Assessment

### Finding Severity Classification

Source code leak findings should be classified based on content:

- **Critical**: Hardcoded credentials, API keys, private keys in source code
- **High**: Complete application source code, database schemas, internal architecture
- **Medium**: Partial source code, comments revealing implementation details
- **Low**: Framework-specific files, public library code
- **Informational**: Source code comments without sensitive information

## Common Pitfalls

### Not Analyzing Git History

Many testers find an exposed `.git` directory but do not analyze the complete history. Deleted files and previous versions may contain more sensitive information than the current code.

### Ignoring JavaScript Source Maps

Source maps provide original source code even in minified bundles. Always check for `.map` files alongside JavaScript bundles.

### Overlooking HTML Comments

HTML comments often contain developer notes and implementation details that reveal sensitive information. Systematic comment analysis is essential.

### Not Testing Development Subdomains

Source code is often exposed on development subdomains that are not in the main application scope. Testing subdomains like `dev.target.com` and `staging.target.com` is essential.

### Forgetting About Error Messages

Error messages can reveal source code through stack traces and error details. Triggering errors with various inputs reveals more information.

## Integration with Other Recon Areas

Source code leak detection integrates with other reconnaissance activities:

- **Version Control Analysis**: Deep analysis of exposed repositories
- **JavaScript Source Analysis**: Analyzing bundles for sensitive information
- **Configuration File Extraction**: Finding configuration files in source code
- **API Endpoint Discovery**: Identifying endpoints from source code analysis
- **Technology Stack Fingerprinting**: Understanding the technology stack from source code

## Reporting Template

### Source Code Leak Report

**Executive Summary**: Overview of source code leak findings and potential impact.

**Methodology**: Description of detection techniques, tools used, and analysis performed.

**Findings Summary**:
- Total source code leaks discovered
- Breakdown by type (version control, JavaScript, comments, debug)
- Sensitive data exposed
- Potential security implications

**Critical/High Findings**:
For each finding:
- Leak vector and location
- Type of source code exposed
- Sensitive data discovered
- Potential attack scenarios
- Recommended remediation

## Practice Labs

### Lab 1: Git Repository Extraction

Practice extracting and analyzing exposed Git repositories.

### Lab 2: JavaScript Source Map Analysis

Practice analyzing JavaScript source maps for source code extraction.

### Lab 3: Debug Endpoint Discovery

Practice finding and analyzing debug endpoints for information disclosure.

### Lab 4: Secret Detection

Practice using automated tools to detect secrets in source code.

### Lab 5: Comment Analysis

Practice analyzing comments for sensitive information disclosure.

## Ethical Guidelines

Source code leak detection should only be performed on applications you own or have authorization to test. Extracting and analyzing source code without authorization may violate intellectual property laws and terms of service. Report all discovered source code leaks through responsible disclosure channels.

## Quick Reference Cheat Sheet

### Version Control Detection
```bash
curl -s https://target.com/.git/HEAD
curl -s https://target.com/.svn/entries
curl -s https://target.com/.hg/store/00manifest.i
```

### Debug Endpoint Testing
```bash
curl -s https://target.com/debug
curl -s https://target.com/debug/vars
curl -s https://target.com/actuator
curl -s https://target.com/actuator/env
```

### Secret Detection Patterns
```bash
grep -rE "password\s*=\s*['\"].*['\"]" .
grep -rE "api[_-]?key\s*=\s*['\"].*['\"]" .
grep -r "BEGIN.*PRIVATE KEY" .
grep -rE "eyJ[a-zA-Z0-9_-]*\.eyJ" .
```

### JavaScript Analysis
```bash
curl -s https://target.com/bundle.js | grep -i "password"
curl -s https://target.com/bundle.js.map
curl -s https://target.com/bundle.js | grep -oE '/api/[a-zA-Z0-9/_-]+'
```