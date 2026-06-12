# Case Study 15: Information Disclosure — Real-World Bug Bounty Findings

## Expert Role

Information disclosure vulnerabilities represent one of the most prevalent and consistently rewarded bug classes in modern bug bounty programs. As a specialist in this domain, you must understand that information leakage extends far beyond simple verbose error messages. The modern attack surface includes API metadata exposure, debug endpoints left in production, sensitive data in HTTP headers, misconfigured CORS policies, directory listing on cloud storage, and unintended data exposure through legitimate application features.

The discipline requires mastery of both automated scanning techniques and manual analysis. You need to understand how applications handle error conditions, how APIs return data, how caching mechanisms work, and how cloud storage configurations can be misconfigured. The expert must be able to distinguish between intentional functionality and accidental exposure, quantify the real-world risk of disclosed information, and chain partial information leaks into more severe attack paths.

Your role encompasses understanding the full spectrum of information disclosure: from low-severity username enumeration to critical exposure of authentication tokens, internal system architecture details, or personally identifiable information (PII) of other users. The key differentiator is understanding the business context—what data is sensitive, who should have access, and what an attacker could achieve with the disclosed information.

## Overview

Information disclosure vulnerabilities occur when an application reveals sensitive data to unauthorized users. This data exposure can happen through various mechanisms including verbose error messages, debug endpoints, API responses, HTTP headers, cached pages, source code comments, metadata in files, and misconfigured access controls on cloud resources.

The severity of information disclosure varies dramatically based on context. Leaking a public username is low severity, while exposing authentication tokens, internal IP addresses, or other users' PII can be critical. Modern web applications are particularly susceptible because they rely on complex API architectures where each endpoint may return different levels of detail based on the request parameters.

Key categories of information disclosure include: server and technology fingerprinting, internal system details (IP addresses, file paths, database versions), user data exposure (PII, financial data, authentication credentials), business logic leaks (internal API documentation, administrative endpoints), and configuration disclosure (API keys, database connection strings, cloud credentials). Each category requires different detection techniques and carries different risk levels.

The impact of information disclosure often extends beyond the immediate data exposure. Attackers use disclosed information for reconnaissance, building attack chains, and targeting other vulnerabilities. A leaked internal IP address can lead to SSRF, a disclosed API version can point to unpatched endpoints, and exposed user data can enable account takeover attacks. Understanding these chains is essential for proper risk assessment.

---

## Real-World Case Studies

### Case Study 1: Uber API Token Leakage Through JavaScript Bundle
**Program:** Uber (HackerOne)
**Bounty:** $15,000
**Severity:** High (CVSS 7.5)
**Researcher:** @samwcyo

**Vulnerability Description:**
The researcher discovered that Uber's web application was leaking internal API tokens through its JavaScript bundle. The tokens were embedded in the compiled JavaScript files served to all users, providing access to internal Uber APIs used for driver management and trip data.

**Technical Details:**
```
GET /static/js/main.bundle.js HTTP/1.1
Host: rider.uber.com

Response includes:
var config = {
  apiToken: "uber_internal_xxxxx",
  baseUrl: "https://internal.uber.com/api/v1",
  environment: "production"
};
```

**Root Cause Analysis:**
The tokens were hardcoded in the JavaScript source code during the build process. The development team had embedded the tokens directly in configuration files that were compiled into the production bundle. The CI/CD pipeline did not include steps to strip or rotate these tokens before deployment.

**Exploitation Chain:**
1. Download the JavaScript bundle from the production web application
2. Search for API keys using regex patterns: `/api[_-]?key['":\s]*['"][a-zA-Z0-9]+/`
3. Extract the tokens and identify the associated API endpoints
4. Use the tokens to access internal APIs and retrieve driver/trip data

**Impact Assessment:**
- Access to internal API endpoints not intended for public use
- Potential exposure of driver personal information and trip history
- Ability to modify driver settings and availability status
- Bypassing rate limits and access controls on public API endpoints

**Bounty Justification:**
The bounty reflected the severity of exposing internal API tokens that could access sensitive business data. The tokens provided privileged access beyond what the public API offered, with potential for data modification rather than just read access.

---

### Case Study 2: GitLab Internal Path Disclosure via Error Pages
**Program:** GitLab (HackerOne)
**Bounty:** $4,000
**Severity:** Medium (CVSS 5.3)
**Researcher:** @jobertabma

**Vulnerability Description:**
GitLab's error handling exposed internal file paths and system configuration through detailed error messages. When malformed requests were sent to certain endpoints, the application returned stack traces containing full server file paths and internal system information.

**Technical Details:**
```
POST /api/v4/projects/invalid HTTP/1.1
Host: gitlab.com
Content-Type: application/json

{"name": null}

Response:
{
  "error": "InternalServerError",
  "message": "PG::UndefinedTable: ERROR: relation \"projects\" does not exist\n LINE 1: SELECT * FROM projects\n ^\n\n/app/models/project.rb:42:in `find'\n/lib/gitlab/middleware/multipart/handler.rb:15:in `call'"
}
```

**Root Cause Analysis:**
The error handler was configured in development mode, which included full stack traces in error responses. The PostgreSQL error messages revealed table structures, and the Ruby stack traces showed internal application file paths and code structure.

**Exploitation Chain:**
1. Send malformed requests to API endpoints to trigger database errors
2. Parse error responses for internal file paths and database information
3. Map the application architecture using revealed file structure
4. Use file paths to identify potential path traversal or local file inclusion targets

**Impact:**
- Disclosure of server file system structure
- Database schema information leakage
- Application framework version disclosure
- Potential pivot point for more targeted attacks

**Bounty Justification:**
The bounty recognized the reconnaissance value of the disclosed information. While not directly exploitable, the internal paths and database details significantly reduce the effort required for further attacks.

---

### Case Study 3: HackerOne Reporter PII Exposure via Profile Export
**Program:** HackerOne (Internal)
**Bounty:** $8,000
**Severity:** Critical (CVSS 8.6)
**Researcher:** @fransrosen

**Vulnerability Description:**
The researcher discovered that the profile export feature on HackerOne returned additional user data beyond what was displayed in the UI. The JSON response included private fields such as tax identification numbers, payment details, and internal account metadata that should not have been accessible.

**Technical Details:**
```
GET /export/profile HTTP/1.1
Host: hackerone.com
Cookie: session=xxxxx

Response (truncated):
{
  "username": "researcher123",
  "email": "researcher@email.com",
  "tax_id": "XXX-XX-XXXX",
  "payment_method": {
    "type": "paypal",
    "email": "paypal@email.com",
    "internal_account_id": "H1-98765"
  },
  "internal_metadata": {
    "trust_level": 7,
    "bypass_rate_limit": true,
    "admin_notes": "Trusted reporter - fast track"
  }
}
```

**Root Cause Analysis:**
The profile export function used a database query that selected all columns from the user table rather than only the columns displayed in the user interface. The internal metadata fields were intended for admin use only but were included in the query results.

**Exploitation Impact:**
- Exposure of reporter tax identification numbers
- Revelation of payment details and internal account IDs
- Access to internal trust levels and administrative notes
- Potential for targeted phishing using verified personal information

**Bounty Justification:**
The critical severity reflected the direct exposure of PII and financial information. The bounty accounted for the regulatory implications of exposing tax identification numbers and payment data.

---

### Case Study 4: Cloudflare Cache Leak Exposing Origin Server IP
**Program:** Cloudflare (Bugcrowd)
**Bounty:** $5,000
**Severity:** High (CVSS 7.1)
**Researcher:** @edyson

**Vulnerability Description:**
A cache poisoning vulnerability allowed the researcher to bypass Cloudflare's CDN and retrieve responses containing the origin server's actual IP address. The leak occurred through specific cache key handling on certain paths.

**Technical Details:**
```
GET /cdn-cgi/trace HTTP/1.1
Host: target.com

Normal Response (Cloudflare):
fl=xxxxx
h=target.com
ip=104.xx.xx.xx
ts=1234567890
visit_scheme=http
uag=curl/7.68.0
colo=SFO
...

After cache poisoning:
GET /%00/cdn-cgi/trace HTTP/1.1
Host: target.com

Response (Origin):
fl=xxxxx
h=target.com
ip=203.0.113.42  ← Origin Server IP
ts=1234567890
visit_scheme=http
uag=curl/7.68.0
colo=  ← Empty, direct connection
```

**Root Cause Analysis:**
The null byte in the path caused Cloudflare's cache to treat the request differently, bypassing the CDN header rewriting. The origin server responded with its actual IP address in the trace output, which was then cached and served to subsequent requests.

**Impact Assessment:**
- Origin server IP address exposed to attackers
- Bypass of DDoS protection provided by CDN
- Direct access to origin server for targeted attacks
- Potential for IP-based access control bypass

---

### Case Study 5: GitHub Enterprise Server Log File Information Disclosure
**Program:** GitHub (HackerOne)
**Bounty:** $10,000
**Severity:** High (CVSS 7.5)
**Researcher:** @mlinkletter

**Vulnerability Description:**
GitHub Enterprise Server included verbose logging that captured sensitive request data. Under certain error conditions, these logs were accessible through the web interface, exposing authentication tokens, internal API keys, and user session data.

**Technical Details:**
```
GET /stafftools/logs/system/production.log HTTP/1.1
Host: github-enterprise.example.com

Response includes:
[2024-01-15 10:23:45] INFO  Started POST "/api/v3/user/sessions"
[2024-01-15 10:23:45] DEBUG Token: ghp_xxxxxxxxxxxxxxxxxxxx
[2024-01-15 10:23:45] DEBUG User-Agent: github-enterprise-admin/2.1
[2024-01-15 10:23:45] DEBUG X-GitHub-Enterprise-Version: 2.1.10
```

**Root Cause Analysis:**
The staff tools logging endpoint was intended for internal use only but lacked proper access control. The logging configuration included debug-level output that captured sensitive authentication data in plaintext.

**Impact:**
- Access to administrative authentication tokens
- Exposure of internal API credentials
- Version information disclosure for targeted CVE exploitation
- Potential for full administrative takeover

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Verbose error messages | Very High | $500-$2,000 | Debug mode in production |
| API metadata exposure | High | $1,000-$5,000 | Incomplete API response filtering |
| JavaScript bundle leaks | High | $3,000-$15,000 | Hardcoded secrets in client code |
| Cache poisoning leads | Medium | $2,000-$8,000 | Improper cache key handling |
| Log file exposure | Medium | $1,000-$5,000 | Missing access controls on logs |
| Source code comments | High | $200-$1,000 | No pre-deployment code review |
| Version disclosure | Very High | $100-$500 | Missing header configuration |
| Internal IP exposure | Medium | $1,000-$5,000 | Improper network configuration |
| Directory listing | Medium | $200-$1,000 | Default server configuration |
| Backup file access | Low | $500-$2,000 | Improper file placement |

### Attack Surface Locations

**HTTP Headers:**
- Server
- X-Powered-By
- X-AspNet-Version
- X-Debug-Token
- X-Runtime
- Via
- X-Cache

**Error Responses:**
- 4xx client errors with stack traces
- 5xx server errors with debug information
- Database error messages
- Validation error details

**API Endpoints:**
- /api/v1/config
- /api/debug
- /api/metrics
- /graphql (introspection)
- /swagger.json
- /api-docs

**Client-Side Code:**
- JavaScript bundles
- Source maps (.map files)
- Configuration objects
- API endpoint definitions

**Cloud Resources:**
- S3 bucket listings
- Azure blob directories
- GCS bucket permissions
- CDN origin headers

**Application Features:**
- Export functions
- Profile downloads
- Report generation
- File preview endpoints

---

## Hunting Methodology

### Step 1: Technology Fingerprinting

Identify the target's technology stack through header analysis and response patterns:

```
# Header Analysis
HEAD / HTTP/1.1
Host: target.com

# Look for:
# - Server header (nginx/1.18.0)
# - X-Powered-By (Express)
# - X-AspNet-Version (4.0.30319)
# - X-Debug-Token
# - X-Runtime
```

Document all technology indicators and research known vulnerabilities for each identified component.

### Step 2: Error Condition Mapping

Systematically trigger error conditions to reveal information:

```
# Invalid Parameters
GET /api/users?id=abc HTTP/1.1
GET /api/users?id[]=1 HTTP/1.1

# Authentication Errors
GET /api/admin HTTP/1.1
POST /api/login HTTP/1.1
Content-Type: application/json
{"username":"test","password":"wrong"}

# Path Manipulation
GET /../../../etc/passwd HTTP/1.1
GET /api/../../../etc/passwd HTTP/1.1
```

Document every unique error message and the conditions that triggered it.

### Step 3: Source Code and Configuration Analysis

Review all client-side code for embedded secrets:

```javascript
// Search patterns for JavaScript analysis
/api[_-]?key['":\s]*['"][a-zA-Z0-9]+/
/token['":\s]*['"][a-zA-Z0-9]+/
/password['":\s]*['"][^'"]+/
/secret['":\s]*['"][a-zA-Z0-9]+/
/aws[_-]?access[_-]?key[_-]?id['":\s]*['"][A-Z0-9]+/
```

Check for source maps, configuration files, and backup files.

### Step 4: API Endpoint Enumeration

Map all API endpoints and analyze response data:

```
# Common API Discovery Paths
/api/v1/
/api/v2/
/api/internal/
/graphql
/swagger.json
/api-docs
/openapi.json
/.well-known/
/robots.txt
/sitemap.xml
```

Compare authenticated vs. unauthenticated responses, and identify fields returned only to specific user roles.

### Step 5: Cache and CDN Analysis

Test caching behavior for sensitive responses:

```
# Cache Bypass Techniques
GET /page?%20=1 HTTP/1.1
GET /page HTTP/1.1
X-Forwarded-For: 127.0.0.1

# CDN Origin Detection
GET /cdn-cgi/trace HTTP/1.1
GET /.cdn-cgi/trace HTTP/1.1
```

Analyze cache headers and test for cache poisoning opportunities.

---

## Detection Strategies

### Automated Detection

**Header Disclosure Scanner:**
```python
HEADERS_TO_CHECK = [
    'Server', 'X-Powered-By', 'X-AspNet-Version',
    'X-AspNetMvc-Version', 'X-Debug-Token',
    'X-Runtime', 'X-Request-Id', 'X-Upstream-Id'
]

def scan_headers(response):
    findings = []
    for header in HEADERS_TO_CHECK:
        if header.lower() in [h.lower() for h in response.headers]:
            findings.append({
                'header': header,
                'value': response.headers[header],
                'severity': 'info'
            })
    return findings
```

**Error Message Analysis:**
```python
ERROR_PATTERNS = [
    r'Exception in thread',
    r'Stack Trace:',
    r'at com\.\w+\.\w+',
    r'PG::\w+Error',
    r'MySQLSyntaxErrorException',
    r'ORA-\d{5}',
    r'System\.Data\.SqlClient'
]

def detect_error_disclosure(response_text):
    import re
    findings = []
    for pattern in ERROR_PATTERNS:
        matches = re.findall(pattern, response_text)
        if matches:
            findings.append({
                'pattern': pattern,
                'matches': matches,
                'severity': 'medium'
            })
    return findings
```

**JavaScript Secret Scanner:**
```python
SECRET_PATTERNS = [
    r'api[_-]?key["\s:=]+["\']([a-zA-Z0-9]{20,})',
    r'token["\s:=]+["\']([a-zA-Z0-9]{20,})',
    r'secret["\s:=]+["\']([a-zA-Z0-9]{20,})',
    r'password["\s:=]+["\']([^"\'\s]{8,})',
    r'aws[_-]?access[_-]?key[_-]?id["\s:=]+["\']([A-Z0-9]{16,})'
]

def scan_javascript_content(js_text):
    import re
    findings = []
    for pattern in SECRET_PATTERNS:
        matches = re.findall(pattern, js_text, re.IGNORECASE)
        for match in matches:
            findings.append({
                'type': 'embedded_secret',
                'value': match[:10] + '...',  # Truncate for safety
                'pattern': pattern
            })
    return findings
```

### Manual Detection

**Checklist for Manual Testing:**

1. **Error Handling Analysis**
   - Submit malformed input to all form fields
   - Test SQL syntax characters in input fields
   - Send invalid JSON to API endpoints
   - Trigger 404, 500, and other error conditions

2. **Source Code Review**
   - View page source for comments
   - Check JavaScript files for debug code
   - Look for source map references
   - Analyze inline scripts for configuration data

3. **API Testing**
   - Compare authenticated vs. unauthenticated responses
   - Test different user roles and permissions
   - Check for IDOR in data access patterns
   - Analyze response schemas for extra fields

4. **Cache Analysis**
   - Test cache control headers
   - Attempt cache poisoning with header injection
   - Check for cached error responses
   - Test CDN origin bypass techniques

### Key Detection Indicators

| Indicator | Severity | Action |
|-----------|----------|--------|
| Server version in headers | Low | Report as informational |
| Stack traces in errors | Medium | Document and report |
| API keys in JavaScript | High | Immediate report, key rotation |
| Internal IP addresses | High | Assess network exposure |
| Database credentials | Critical | Immediate report |
| Authentication tokens | Critical | Immediate report with PoC |
| PII in responses | Critical | Report with data samples |

---

## Impact Assessment

### CVSS 3.1 Scoring

**Low Severity (CVSS 3.1: 3.1-3.9)**
- Technology version disclosure only
- Public information leakage
- Non-sensitive configuration details

**Medium Severity (CVSS 3.1: 4.0-6.9)**
- Internal file paths disclosed
- Database schema information
- Debug endpoints accessible
- Non-admin user data exposure

**High Severity (CVSS 3.1: 7.0-8.9)**
- Authentication tokens leaked
- Internal API access exposed
- PII of other users
- Administrative configuration access

**Critical Severity (CVSS 3.1: 9.0-10.0)**
- Database credentials exposed
- Root/admin access tokens
- Complete user database access
- Financial data exposure

### Business Impact

Information disclosure impacts multiple business dimensions:

1. **Regulatory Compliance:** Exposure of PII may trigger GDPR, CCPA, or other privacy regulation requirements
2. **Reputational Damage:** Public disclosure of security weaknesses affects customer trust
3. **Financial Loss:** Direct bounty costs plus remediation and potential breach response costs
4. **Competitive Advantage:** Internal business data exposure may reveal strategic information

### Bounty Range

| Severity | Typical Range | Factors Affecting Bounty |
|----------|---------------|-------------------------|
| Low | $100-$500 | Type of data, ease of exploitation |
| Medium | $500-$2,500 | Scope of disclosure, data sensitivity |
| High | $2,500-$10,000 | PII exposure, authentication impact |
| Critical | $10,000-$25,000+ | Full system compromise potential |

---

## Advanced Variations

### Variation 1: GraphQL Introspection Abuse

GraphQL APIs often expose complete schema information through introspection queries:

```graphql
query IntrospectionQuery {
  __schema {
    queryType { name }
    mutationType { name }
    types {
      name
      kind
      fields {
        name
        type {
          name
          kind
        }
      }
    }
  }
}
```

This reveals all available queries, mutations, and types, including internal fields not exposed in documentation.

### Variation 2: Response Schema Mismatch

Applications may return different data structures based on request parameters:

```json
// Normal request
GET /api/user/123
{
  "id": 123,
  "name": "John",
  "email": "john@example.com"
}

// With debug parameter
GET /api/user/123?debug=true
{
  "id": 123,
  "name": "John",
  "email": "john@example.com",
  "_internal": {
    "database_id": "usr_abc123",
    "created_at": "2024-01-15T10:23:45Z",
    "role_id": 5,
    "api_key": "sk_xxxxx",
    "last_ip": "192.168.1.100"
  }
}
```

### Variation 3: Backup File Discovery

Automated tools may create backup files that are accessible:

```
# Common backup patterns
/index.php.bak
/index.php~
/index.php.old
/index.php.save
/.index.php.swp
/index.php#  (Emacs backup)
/.config.php~
/db_backup.sql.gz
/backup_2024.zip
/dump.sql
```

### Variation 4: Metadata File Exposure

Document metadata can reveal sensitive information:

- PDF files may contain author names, email addresses, and internal paths
- Office documents may include revision history and comments
- Image files may contain GPS coordinates and device information
- Source code repositories may include commit history and contributor information

---

## Chain Integration

Information disclosure vulnerabilities are often most valuable when chained with other findings:

**Chain 1: Version Disclosure → CVE Exploitation**
Disclosed version numbers enable targeted exploitation of known vulnerabilities in specific software versions.

**Chain 2: Internal IP → SSRF**
Leaked internal IP addresses become targets for Server-Side Request Forgery attacks.

**Chain 3: API Token → Account Takeover**
Exposed authentication tokens can enable unauthorized access to user accounts.

**Chain 4: Source Code Leak → Logic Bypass**
Code review of disclosed source code may reveal authentication bypass or privilege escalation vulnerabilities.

**Chain 5: Database Credentials → Data Breach**
Leaked database connection strings can provide direct access to backend data stores.

---

## Prevention Recommendations

1. **Error Handling:** Implement generic error messages for production, log detailed errors server-side only
2. **Header Configuration:** Remove version headers, customize error pages
3. **API Design:** Implement response filtering to exclude internal fields
4. **Source Code:** Remove comments and debug code before deployment, implement pre-commit hooks
5. **Cloud Configuration:** Audit bucket permissions, disable directory listing
6. **Cache Management:** Implement proper cache control headers, test for cache poisoning
7. **Code Review:** Include information disclosure checks in security code review
8. **Monitoring:** Implement alerts for unusual data access patterns

---

## Common Pitfalls

1. **Assuming Low Severity:** Even version disclosure can enable targeted attacks
2. **Missing Chained Impacts:** A single disclosure may be benign but dangerous when combined with other findings
3. **Incomplete Testing:** Only testing main functionality, missing edge cases and error conditions
4. **Ignoring Caching:** Failing to consider that sensitive data may be cached by CDNs or browsers
5. **Overlooking Metadata:** PDFs, images, and documents often contain overlooked metadata
6. **Development Mode:** Forgetting to disable debug features when deploying to production
7. **Inadequate Scoping:** Not checking all subdomains and related applications for the same issues

---

## Real-World References

1. HackerOne: Information Disclosure Reports - https://hackerone.com
2. OWASP Testing Guide v4: Information Leakage - https://owasp.org/www-project-web-security-testing-guide/
3. PortSwigger Web Security Academy: Information Disclosure - https://portswigger.net/web-security
4. Bugcrowd University: Reconnaissance and Information Gathering - https://bugcrowd.com/university
5. NIST SP 800-115: Information Security Testing and Assessment

---

## Quick Reference Cheat Sheet

**Immediate Report Items:**
- API keys or tokens in JavaScript
- Database credentials in error messages
- Authentication tokens in URLs or headers
- PII of other users in responses
- Internal IP addresses disclosed

**Common Testing Commands:**
```bash
# Header analysis
curl -I https://target.com

# Source code review
view-source:https://target.com
curl -s https://target.com | grep -i "api\|token\|key\|secret"

# JavaScript analysis
curl -s https://target.com/app.js | grep -oP '(api|token|key|secret)["\s:=]+["\'][^"\' ]+'

# Error testing
curl -X POST https://target.com/api -H "Content-Type: application/json" -d "{invalid"
```

**Severity Decision Matrix:**

| Data Type | Exposure Level | Severity |
|-----------|---------------|----------|
| Version numbers | Public | Low |
| Internal paths | Server error | Medium |
| API documentation | Authenticated | Medium |
| User PII | Any | High |
| Auth tokens | Any | Critical |
| Database creds | Any | Critical |


---

## Appendix: Extended Testing Scripts

### Automated Header Disclosure Scanner (Python)

```python
#!/usr/bin/env python3
"""
Information Disclosure Header Scanner
Scans web applications for sensitive header information
"""

import requests
import json
import sys
from datetime import datetime

class HeaderDisclosureScanner:
    def __init__(self, target_url):
        self.target_url = target_url
        self.findings = []
        
        self.sensitive_headers = {
            'Server': {'severity': 'low', 'description': 'Server version disclosure'},
            'X-Powered-By': {'severity': 'low', 'description': 'Technology disclosure'},
            'X-AspNet-Version': {'severity': 'medium', 'description': 'ASP.NET version'},
            'X-AspNetMvc-Version': {'severity': 'medium', 'description': 'MVC version'},
            'X-Debug-Token': {'severity': 'high', 'description': 'Debug token exposed'},
            'X-Debug-Token-Link': {'severity': 'high', 'description': 'Debug endpoint exposed'},
            'X-Request-Id': {'severity': 'info', 'description': 'Request tracking ID'},
            'X-Runtime': {'severity': 'low', 'description': 'Execution time disclosure'},
            'X-Upstream-Id': {'severity': 'medium', 'description': 'Upstream server info'},
            'Via': {'severity': 'low', 'description': 'Proxy information'},
            'X-Cache': {'severity': 'info', 'description': 'Cache status'},
            'X-Generated-By': {'severity': 'low', 'description': 'Generator disclosure'},
        }
    
    def scan(self):
        try:
            response = requests.get(self.target_url, timeout=10)
            
            for header, info in self.sensitive_headers.items():
                if header.lower() in [h.lower() for h in response.headers]:
                    self.findings.append({
                        'header': header,
                        'value': response.headers.get(header),
                        'severity': info['severity'],
                        'description': info['description']
                    })
            
            return self.findings
            
        except requests.RequestException as e:
            return {'error': str(e)}
    
    def generate_report(self):
        report = {
            'target': self.target_url,
            'scan_time': datetime.now().isoformat(),
            'findings': self.findings,
            'summary': {
                'total_findings': len(self.findings),
                'high_severity': sum(1 for f in self.findings if f['severity'] == 'high'),
                'medium_severity': sum(1 for f in self.findings if f['severity'] == 'medium'),
                'low_severity': sum(1 for f in self.findings if f['severity'] == 'low'),
            }
        }
        return json.dumps(report, indent=2)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        scanner = HeaderDisclosureScanner(sys.argv[1])
        findings = scanner.scan()
        print(scanner.generate_report())
```

### Error Message Analysis Script

```python
#!/usr/bin/env python3
"""
Error Message Disclosure Analyzer
Tests error conditions and analyzes information leakage
"""

import requests
import re
import json

class ErrorDisclosureAnalyzer:
    def __init__(self, target_url):
        self.target_url = target_url
        self.error_patterns = [
            r'Exception in thread',
            r'Stack Trace:',
            r'at com\.\w+\.\w+\.\w+',
            r'PG::\w+Error',
            r'MySQLSyntaxErrorException',
            r'ORA-\d{5}',
            r'System\.Data\.SqlClient',
            r'Microsoft\.AspNetCore',
            r'Traceback \(most recent call last\)',
            r'Fatal error:',
            r'Warning:',
        ]
        
        self.test_payloads = [
            {'name': 'SQL Injection', 'payload': "' OR '1'='1"},
            {'name': 'Path Traversal', 'payload': "../../../etc/passwd"},
            {'name': 'Null Byte', 'payload': "%00"},
            {'name': 'Invalid JSON', 'payload': "{invalid}"},
            {'name': 'Array Input', 'payload': "[]"},
        ]
    
    def analyze_response(self, response):
        findings = []
        content = response.text
        
        for pattern in self.error_patterns:
            matches = re.findall(pattern, content)
            if matches:
                findings.append({
                    'pattern': pattern,
                    'matches': matches[:5],  # Limit to 5 matches
                    'severity': 'medium'
                })
        
        return findings
    
    def test_error_conditions(self):
        results = []
        
        for test in self.test_payloads:
            try:
                response = requests.post(
                    self.target_url,
                    json={'input': test['payload']},
                    timeout=10
                )
                
                findings = self.analyze_response(response)
                
                if findings:
                    results.append({
                        'test': test['name'],
                        'status_code': response.status_code,
                        'findings': findings
                    })
                    
            except requests.RequestException:
                continue
        
        return results
```

### JavaScript Source Code Analyzer

```python
#!/usr/bin/env python3
"""
JavaScript Source Code Secret Scanner
Scans JS files for embedded secrets and sensitive data
"""

import re
import requests
import sys

class JavaScriptSecretScanner:
    def __init__(self):
        self.secret_patterns = [
            {
                'name': 'API Key',
                'pattern': r'(?:api[_-]?key|apikey)["\s:=]+["\']([a-zA-Z0-9]{20,})',
                'severity': 'high'
            },
            {
                'name': 'Secret Key',
                'pattern': r'(?:secret|secretkey)["\s:=]+["\']([a-zA-Z0-9]{20,})',
                'severity': 'high'
            },
            {
                'name': 'Access Token',
                'pattern': r'(?:access[_-]?token|auth[_-]?token)["\s:=]+["\']([a-zA-Z0-9]{20,})',
                'severity': 'high'
            },
            {
                'name': 'Password',
                'pattern': r'(?:password|passwd|pwd)["\s:=]+["\']([^"\'\s]{8,})',
                'severity': 'critical'
            },
            {
                'name': 'AWS Key',
                'pattern': r'AKIA[0-9A-Z]{16}',
                'severity': 'critical'
            },
            {
                'name': 'Private Key Marker',
                'pattern': r'-----BEGIN (?:RSA |EC )?PRIVATE KEY-----',
                'severity': 'critical'
            },
        ]
    
    def scan_content(self, content):
        findings = []
        
        for secret in self.secret_patterns:
            matches = re.findall(secret['pattern'], content, re.IGNORECASE)
            for match in matches:
                findings.append({
                    'type': secret['name'],
                    'value': match[:10] + '...' if len(match) > 10 else match,
                    'severity': secret['severity']
                })
        
        return findings
    
    def scan_url(self, url):
        try:
            response = requests.get(url, timeout=10)
            return self.scan_content(response.text)
        except requests.RequestException as e:
            return {'error': str(e)}

if __name__ == '__main__':
    if len(sys.argv) > 1:
        scanner = JavaScriptSecretScanner()
        results = scanner.scan_url(sys.argv[1])
        print(json.dumps(results, indent=2))
```

## Appendix: Bug Report Template

### Information Disclosure Report Template

```markdown
**Title:** [Platform] Information Disclosure via [Mechanism]

**Summary:**
[Brief description of the information disclosure vulnerability]

**Vulnerability Details:**
- **Endpoint:** [URL/Endpoint]
- **Method:** [HTTP Method]
- **Parameter:** [Affected parameter if applicable]
- **Data Exposed:** [Type of data disclosed]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. Observe [disclosed information]

**Impact:**
[Description of what an attacker could achieve with the disclosed information]

**Remediation:**
[Specific recommendations to fix the issue]

**Severity Justification:**
[Explanation of severity rating based on CVSS 3.1]
```

## Appendix: Severity Classification Guide

| Data Type | Base Severity | Modified Severity Factors |
|-----------|---------------|--------------------------|
| Technology version | Low | +Medium if known CVE exists |
| Internal file paths | Medium | +High if paths enable traversal |
| Debug information | Medium | +High if contains credentials |
| User PII | High | +Critical if financial/health data |
| Authentication tokens | Critical | Always Critical |
| Database credentials | Critical | Always Critical |
| API keys | High | +Critical if admin access |

