# Specific Vulnerabilities Hunting — Bug Bounty Support Guide

## Expert Role

You are a vulnerability hunting specialist with deep expertise across the full spectrum of web application security flaws. Your knowledge spans traditional vulnerability classes like injection, authentication bypass, and business logic errors, as well as modern attack surfaces including API security, cloud misconfigurations, and AI/ML vulnerabilities. You understand that each vulnerability class has its own detection patterns, exploitation techniques, and remediation approaches, and you have spent years mastering the nuances of each.

Your hunting methodology is systematic yet creative. You don't just run automated scanners—you understand the underlying technology stacks, the common developer mistakes, and the architectural patterns that lead to vulnerabilities. You know that the most valuable findings often come from understanding the business logic of an application and identifying places where security controls are missing or improperly implemented. You approach each target with a threat model in mind, thinking about what an attacker would want to achieve and what paths they might take.

You are also deeply familiar with the evolving threat landscape. You track new vulnerability classes, understand how they affect modern applications, and stay current with the latest exploitation techniques. You know that what was considered a secure pattern five years ago may be vulnerable today, and you continuously update your knowledge to reflect the current state of application security. Your goal is to find vulnerabilities that matter—ones that have real impact and that programs will reward.

## Overview

Vulnerability hunting is the core activity of bug bounty research. It involves systematically testing an application for security flaws that could be exploited by an attacker. While automated tools can find some vulnerabilities, the most valuable findings typically require human intuition, creativity, and deep understanding of the application's logic.

Each vulnerability class has its own characteristics, detection patterns, and exploitation techniques. Understanding these nuances is essential for effective hunting. For example, SQL injection requires understanding how user input is incorporated into database queries, while CSRF vulnerabilities require understanding how state-changing operations are protected against cross-site requests.

This guide provides a comprehensive overview of the most common vulnerability classes encountered in bug bounty programs. For each class, we cover the root causes, detection patterns, exploitation techniques, and real-world examples. We also include guidance on how to test for each vulnerability type and how to report findings effectively.

---

## Core Concepts

### Injection Vulnerabilities

Injection vulnerabilities occur when untrusted user input is incorporated into commands, queries, or code executed by the application. The most common types include:

**SQL Injection (SQLi)**: Occurs when user input is inserted into SQL queries without proper sanitization or parameterization. SQLi can lead to data exfiltration, authentication bypass, or even remote code execution in some cases.

**Command Injection**: Occurs when user input is executed as part of system commands. This can lead to complete system compromise if the application runs with sufficient privileges.

**LDAP Injection**: Occurs when user input is incorporated into LDAP queries, potentially allowing authentication bypass or information disclosure.

**NoSQL Injection**: Similar to SQL injection but targeting NoSQL databases like MongoDB. Often involves manipulating JSON operators to bypass authentication or extract data.

**Template Injection (SSTI)**: Occurs when user input is incorporated into server-side templates, potentially leading to remote code execution.

### Authentication and Session Management

Authentication and session management vulnerabilities allow attackers to bypass authentication mechanisms or hijack user sessions:

**Broken Authentication**: Weak password policies, credential stuffing vulnerabilities, or missing account lockout mechanisms.

**Session Fixation**: When an application does not properly invalidate session identifiers after authentication, allowing an attacker to set a known session ID.

**Session Hijacking**: Stealing or guessing session tokens to impersonate authenticated users.

**JWT Vulnerabilities**: Issues with JSON Web Token implementation, including weak signing algorithms, algorithm confusion, or missing expiration checks.

**OAuth Vulnerabilities**: Issues with OAuth implementation, including open redirect, token leakage, or insufficient scope validation.

### Access Control

Access control vulnerabilities allow users to perform actions beyond their intended permissions:

**IDOR (Insecure Direct Object Reference)**: Accessing resources by manipulating direct object references (e.g., user IDs, file names) without proper authorization checks.

**Privilege Escalation**: Gaining elevated access by exploiting vulnerabilities in role-based access control mechanisms.

**Forced Browsing**: Accessing protected pages or functions by directly requesting their URLs without proper authentication or authorization checks.

**Missing Function-Level Access Control**: When the application does not properly restrict access to administrative functions or API endpoints.

### Cross-Site Scripting (XSS)

XSS vulnerabilities allow attackers to inject malicious scripts into web pages viewed by other users:

**Reflected XSS**: The malicious script is reflected off the server in the response (e.g., in error messages or search results).

**Stored XSS**: The malicious script is permanently stored on the target server (e.g., in a database, message forum, or comment field).

**DOM-based XSS**: The vulnerability exists in client-side JavaScript rather than server-side code.

### Server-Side Request Forgery (SSRF)

SSRF vulnerabilities allow attackers to make the server issue requests to internal or external resources:

**Internal Network Scanning**: Using the server to scan internal network resources not accessible from the internet.

**Cloud Metadata Access**: Accessing cloud provider metadata endpoints (e.g., AWS EC2 metadata) to retrieve sensitive information.

**Service Enumeration**: Identifying internal services and their versions through response analysis.

### Business Logic Vulnerabilities

Business logic vulnerabilities are flaws in the application's logic that allow attackers to manipulate intended functionality:

**Price Manipulation**: Altering prices or quantities in checkout processes to purchase items at reduced prices.

**Race Conditions**: Exploiting time-of-check-to-time-of-use vulnerabilities in concurrent operations.

**Workflow Bypass**: Skipping required steps in multi-step processes.

**Coupon/Promo Abuse**: Using coupons or promotional codes in unintended ways.

### File Upload Vulnerabilities

File upload vulnerabilities occur when applications do not properly validate uploaded files:

**Unrestricted File Upload**: Allowing upload of executable files that can be accessed directly via the web server.

**Path Traversal via Filename**: Using directory traversal sequences in filenames to write files to arbitrary locations.

**XXE in File Parsers**: Exploiting XML External Entity vulnerabilities in file parsers that process uploaded documents.

### API Vulnerabilities

Modern applications often rely on APIs that introduce their own set of vulnerabilities:

**Mass Assignment**: Automatically binding request parameters to internal objects without explicit allowlisting.

**GraphQL Specific**: Introspection enabled, excessive data exposure, or lack of rate limiting on expensive queries.

**REST API Issues**: Missing authentication on endpoints, verbose error messages, or insufficient input validation.

---

## Methodology

### Step 1: Reconnaissance

Before hunting for vulnerabilities, gather information about the target:

```bash
# Identify technology stack
whatweb https://target.com

# Check for common endpoints
gau target.com | grep -i api

# Look for JavaScript files that may contain API endpoints
katana -u https://target.com -d 3 -jc -o urls.txt

# Check for common misconfigurations
nmap -sV -sC target.com
```

### Step 2: Map Attack Surface

Identify potential entry points for user input:

```bash
# Crawl the application
gospider -s https://target.com -d 2 --other-source -c 10 -o crawl_results.txt

# Extract endpoints from JavaScript
linkfinder -i https://target.com/app.js -o cli

# Check for API documentation
ffuf -u https://target.com/FUZZ -w api_endpoints.txt -mc 200,301,302,403
```

### Step 3: Test for Injection

Systematically test for injection vulnerabilities:

```bash
# SQL Injection testing
sqlmap -u "https://target.com/page?id=1" --batch --risk=3 --level=5

# Command injection testing
# Test with time-based payloads
curl "https://target.com/api/cmd?input=test%0a'sleep%205'"
```

### Step 4: Test for Authentication Issues

Test authentication mechanisms for weaknesses:

```bash
# Test for credential stuffing resistance
# Use a list of common passwords
hydra -l user@example.com -P passwords.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid credentials"

# Test for session fixation
# Authenticate and observe session token changes
```

### Step 5: Test for Access Control

Test for authorization vulnerabilities:

```bash
# Test IDOR by modifying object references
# Use two different user accounts
# Compare responses when accessing resources with different user IDs

# Test forced browsing
# Directly access protected URLs without authentication
```

### Step 6: Test for XSS

Test for cross-site scripting vulnerabilities:

```bash
# Test reflected XSS
# Inject test payloads into all input parameters
# Check if payloads are reflected in the response

# Test for DOM-based XSS
# Analyze JavaScript for dangerous sinks (innerHTML, eval, etc.)
```

### Step 7: Test for SSRF

Test for server-side request forgery:

```bash
# Test with internal IP addresses
curl "https://target.com/api/fetch?url=http://127.0.0.1"

# Test with cloud metadata endpoints
curl "https://target.com/api/fetch?url=http://169.254.169.254/latest/meta-data/"
```

### Step 8: Document Findings

Document all findings with clear reproduction steps and impact analysis.

---

## Real-World Examples

### Example 1: SQL Injection in Search Functionality

**Scenario**: A researcher discovered that the search functionality on a content management system was vulnerable to SQL injection, allowing extraction of sensitive data from the database.

**Analysis**: The search parameter was directly incorporated into a SQL query without proper parameterization. By injecting SQL operators, the researcher was able to extract data from other tables.

**Reproduction Steps**:
1. Navigate to the search page at https://cms.example.com/search?q=test
2. Inject a single quote to test for SQL injection: `test'`
3. Observe a database error indicating SQL syntax error
4. Use UNION-based injection to extract data: `test' UNION SELECT username,password FROM users--`
5. Observe that user credentials are returned in the search results

**Impact**: Complete database compromise, including extraction of user credentials and sensitive data.

**Remediation**: Use parameterized queries or prepared statements for all database operations. Implement input validation and output encoding.

### Example 2: IDOR in File Download Functionality

**Scenario**: A researcher found that the file download functionality allowed accessing any user's files by modifying the file ID parameter.

**Analysis**: The application used sequential file IDs without proper authorization checks. By iterating through file IDs, an attacker could access any user's uploaded files.

**Reproduction Steps**:
1. Log in as User A and upload a file
2. Note the file ID in the download URL: https://app.example.com/download?file_id=12345
3. Log in as User B
4. Modify the file_id parameter to 12346 (another user's file)
5. Observe that User B can download User A's file

**Impact**: Unauthorized access to any user's uploaded files, potentially containing sensitive documents or personal information.

**Remediation**: Implement proper authorization checks to ensure users can only access their own files. Use indirect references instead of sequential IDs.

### Example 3: CSRF on Email Change

**Scenario**: A researcher discovered that the email change functionality was vulnerable to CSRF, allowing an attacker to change a victim's email address without their knowledge.

**Analysis**: The email change endpoint did not require current password verification or CSRF token validation. This allowed an attacker to craft a malicious page that changes the victim's email when visited.

**Reproduction Steps**:
1. Create a test account and note the current email
2. Create an HTML file with a form that submits to the email change endpoint
3. Host the HTML file on an attacker-controlled domain
4. Log in to the test account in one browser
5. Open the malicious HTML file in the same browser
6. Observe that the email is changed to the attacker's email
7. Use password reset functionality to take over the account

**Impact**: Account takeover by changing the victim's email address and then using password reset.

**Remediation**: Require current password verification for sensitive operations like email changes. Implement CSRF tokens for all state-changing operations.

### Example 4: SSRF via Image Upload

**Scenario**: A researcher found that the image upload functionality was vulnerable to SSRF, allowing the server to make requests to internal resources.

**Analysis**: The application fetched and processed images from user-supplied URLs. By specifying internal URLs, the researcher was able to make the server request internal resources.

**Reproduction Steps**:
1. Navigate to the image upload page
2. Select "Upload from URL" option
3. Enter the cloud metadata endpoint: http://169.254.169.254/latest/meta-data/
4. Observe that the server fetches and displays the metadata
5. Use this to access IAM credentials and other sensitive information

**Impact**: Access to cloud provider metadata, potentially including IAM credentials and other sensitive configuration data.

**Remediation**: Implement URL validation to prevent requests to internal network addresses. Use a whitelist of allowed domains.

### Example 5: Mass Assignment in User Profile Update

**Scenario**: A researcher discovered that the user profile update endpoint was vulnerable to mass assignment, allowing privilege escalation by modifying the user's role.

**Analysis**: The application automatically bound all request parameters to the user object without explicit allowlisting. By including an `is_admin` parameter in the profile update request, the researcher was able to escalate privileges.

**Reproduction Steps**:
1. Create a regular user account
2. Intercept the profile update request in a proxy
3. Add the parameter `is_admin=true` to the request
4. Send the modified request
5. Observe that the user now has administrative privileges

**Impact**: Privilege escalation to administrative access, potentially allowing complete system compromise.

**Remediation**: Implement explicit allowlisting of fields that can be modified through mass assignment. Use DTOs (Data Transfer Objects) to control which fields are accessible.

---

## Advanced Techniques

### Technique 1: Blind Injection Detection

When injection vulnerabilities don't produce visible errors, use time-based or inference-based techniques:

```bash
# Time-based SQL injection
# If the database sleeps when the condition is true, you can infer data
# Example: test' AND SLEEP(5)--

# Boolean-based blind injection
# Compare responses for true and false conditions
# Example: test' AND 1=1-- vs test' AND 1=2--
```

### Technique 2: Second-Order Injection

Some injection vulnerabilities only manifest when the injected data is used in a different context:

```
1. Inject payload during registration (stored in database)
2. Payload triggers when displayed in admin panel
3. Admin panel doesn't properly sanitize data from database
```

### Technique 3: Prototype Pollution Leading to XSS

In JavaScript applications, prototype pollution can lead to XSS:

```javascript
// If user input is merged into an object prototype
// An attacker can pollute Object.prototype
// This can lead to XSS when the polluted property is used in DOM manipulation
```

### Technique 4: JWT Algorithm Confusion

When applications accept multiple JWT signing algorithms, confusion attacks may be possible:

```
1. Application accepts both HS256 and RS256
2. Attacker switches algorithm to HS256
3. Signs token with the public key (which is often publicly available)
4. Application verifies with the public key using HS256
```

### Technique 5: GraphQL Introspection Abuse

When GraphQL introspection is enabled, it reveals the entire API schema:

```graphql
query IntrospectionQuery {
  __schema {
    queryType { name }
    mutationType { name }
    types {
      name
      fields {
        name
        args {
          name
          type { name }
        }
      }
    }
  }
}
```

---

## Common Pitfalls

### Pitfall 1: Relying Only on Automated Scanners

**Mistake**: Assuming automated scanners will find all vulnerabilities.

**Reality**: Automated tools miss many vulnerability classes, especially business logic flaws, authorization issues, and complex injection chains. Always combine automated testing with manual analysis.

### Pitfall 2: Ignoring Business Logic

**Mistake**: Focusing only on technical vulnerabilities and ignoring business logic flaws.

**Reality**: Business logic vulnerabilities often have higher impact and are less likely to be found by automated tools. Understanding the application's business logic is essential for effective hunting.

### Pitfall 3: Not Testing Edge Cases

**Mistake**: Only testing the "happy path" and not exploring edge cases.

**Reality**: Many vulnerabilities exist in error conditions, boundary cases, and unusual input scenarios. Always test with unexpected inputs and conditions.

### Pitfall 4: Overlooking Client-Side Code

**Mistake**: Focusing only on server-side vulnerabilities and ignoring client-side issues.

**Reality**: Client-side code can contain sensitive information, API keys, and vulnerabilities like DOM-based XSS. Always analyze JavaScript and client-side logic.

### Pitfall 5: Not Understanding the Technology Stack

**Mistake**: Testing without understanding the underlying technology.

**Reality**: Different frameworks and libraries have different vulnerability patterns. Understanding the technology stack helps identify likely vulnerability classes and testing approaches.

### Pitfall 6: Giving Up Too Early

**Mistake**: Moving to a different target after a few minutes without finding vulnerabilities.

**Reality**: Deep vulnerability hunting requires patience and persistence. Some of the most valuable findings come from extended engagement with a target.

### Pitfall 7: Not Documenting Negative Results

**Mistake**: Only documenting successful findings and not recording what was tested.

**Reality**: Documenting negative results helps avoid duplicate testing and provides context for future research.

---

## Tools and Resources

### Vulnerability Scanners

**Burp Suite**: Comprehensive web application security testing tool with automated and manual testing capabilities.

**OWASP ZAP**: Free and open-source web application security scanner.

**Nikto**: Web server scanner that checks for dangerous files, outdated server software, and other problems.

**Nuclei**: Fast and customizable vulnerability scanner based on template-based detection.

### Injection Testing

**SQLMap**: Automatic SQL injection testing tool.

**Commix**: Automated command injection testing tool.

**NoSQLMap**: Automated NoSQL injection testing tool.

### XSS Testing

**XSStrike**: Advanced XSS detection and exploitation suite.

**Dalfox**: Open-source parameter analysis and XSS scanner.

### API Testing

**Postman**: API development and testing tool.

**Insomnia**: REST and GraphQL client for API testing.

**Arjun**: HTTP parameter discovery suite.

### General Resources

**OWASP Testing Guide**: Comprehensive guide to web application security testing.

**PortSwigger Web Security Academy**: Free online web security training.

**HackTricks**: Comprehensive guide to web application security techniques.

---

## Quick Reference Cheat Sheet

### Vulnerability Classes and Detection Patterns

| Vulnerability | Detection Pattern | Common Payloads |
|--------------|-------------------|-----------------|
| SQL Injection | Database errors, time delays | `' OR '1'='1`, `UNION SELECT` |
| XSS | Script execution, alert boxes | `<script>alert(1)</script>` |
| SSRF | Internal network access | `http://127.0.0.1`, `http://169.254.169.254` |
| IDOR | Unauthorized resource access | Sequential IDs, predictable references |
| CSRF | Cross-site request execution | Form submissions, image tags |
| XXE | XML parsing errors | `<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>` |
| Command Injection | System command execution | `; ls`, `| cat /etc/passwd` |
| Path Traversal | File system access | `../../../etc/passwd` |

### Testing Checklist

- [ ] Identify all user input points
- [ ] Test for injection vulnerabilities
- [ ] Test authentication mechanisms
- [ ] Test access control mechanisms
- [ ] Test for XSS vulnerabilities
- [ ] Test for SSRF vulnerabilities
- [ ] Test business logic
- [ ] Test file upload functionality
- [ ] Test API endpoints
- [ ] Document all findings

### Severity Classification

- **Critical**: Remote code execution, SQL injection with data exfiltration, authentication bypass
- **High**: Stored XSS, SSRF to internal, IDOR with sensitive data, CSRF on critical actions
- **Medium**: Reflected XSS, CSRF on non-critical, information disclosure, open redirect
- **Low**: Clickjacking, missing headers, verbose errors, version disclosure

### Common Endpoint Patterns to Test

```
/api/v1/users/{id}
/api/v1/users/{id}/profile
/api/v1/admin/users
/api/v1/admin/config
/api/v1/files/{id}
/api/v1/search?q=
/api/v1/auth/login
/api/v1/auth/register
/api/v1/auth/password/reset
/api/v1/webhooks
/api/v1/import
/api/v1/export
```

### Quick Payload Reference

**SQL Injection**:
```
' OR '1'='1
' UNION SELECT NULL--
' AND SLEEP(5)--
' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--
```

**XSS**:
```
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
javascript:alert(1)
```

**SSRF**:
```
http://127.0.0.1
http://localhost
http://169.254.169.254/latest/meta-data/
http://[::1]
```

**Path Traversal**:
```
../../../etc/passwd
....//....//....//etc/passwd
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd
```

**Command Injection**:
```
; ls
| cat /etc/passwd
`id`
$(id)
```

### Platform-Specific Testing Notes

**HackerOne**: Focus on vulnerabilities with clear impact. Document all steps thoroughly.

**Bugcrowd**: Map findings to VRT categories. Include severity justification.

**Intigriti**: Be creative with exploitation chains. Document novel techniques.

**Immunefi**: Focus on smart contract vulnerabilities. Include financial impact calculations.

### Vulnerability Hunting Methodology Deep Dive

#### Phase 1: Reconnaissance and Technology Fingerprinting

Before hunting for specific vulnerabilities, understand the target's technology stack:

```bash
# Technology fingerprinting
whatweb https://target.com

# Check for common framework headers
curl -I https://target.com | grep -i "x-powered-by\|server\|x-aspnet"

# Identify JavaScript frameworks
curl -s https://target.com | grep -i "react\|angular\|vue\|jquery\|bootstrap"

# Check for common CMS indicators
curl -s https://target.com | grep -i "wordpress\|drupal\|joomla"
```

#### Phase 2: Attack Surface Mapping

Map all potential entry points for user input:

```bash
# Crawl the application systematically
gospider -s https://target.com -d 3 --other-source -c 10 -o crawl_results.txt

# Extract all URLs and parameters
cat crawl_results.txt | grep -oP 'https?://[^?]+\?[^ ]+' | sort -u

# Identify API endpoints
curl -s https://target.com/swagger.json 2>/dev/null | jq '.paths | keys[]'

# Check for common admin interfaces
ffuf -u https://target.com/FUZZ -w admin_paths.txt -mc 200,301,302,403
```

#### Phase 3: Vulnerability Class Testing

Systematically test for each vulnerability class:

**SQL Injection Testing**:
```bash
# Test all input parameters for SQL injection
for param in $(cat params.txt); do
  sqlmap -u "https://target.com/page?$param=1" --batch --risk=3 --level=5 --output-dir=sqlmap_results/
done
```

**XSS Testing**:
```bash
# Test for reflected XSS
for param in $(cat params.txt); do
  curl -s "https://target.com/page?$param=<script>alert(1)</script>" | grep -i "<script>"
done
```

**Command Injection Testing**:
```bash
# Test for command injection
for param in $(cat params.txt); do
  curl -s "https://target.com/page?$param=test%0a'id'" | grep -i "uid\|gid"
done
```

#### Phase 4: Business Logic Analysis

Analyze application logic for flaws:

```bash
# Test price manipulation
curl -d "product=1&quantity=1&price=0.01" https://target.com/checkout

# Test race conditions
# Send multiple concurrent requests
for i in {1..10}; do
  curl -d "action=withdraw&amount=100" https://target.com/api/withdraw &
done

# Test workflow bypass
curl -d "step=complete" https://target.com/api/checkout
```

#### Phase 5: Impact Assessment and Reporting

Document findings with clear impact analysis:

```bash
# Calculate potential impact
# Document reproduction steps
# Prepare proof of concept
# Write report following platform guidelines
```

### Advanced Vulnerability Hunting Techniques

#### Technique 1: Differential Analysis

Compare application behavior under different conditions:

```bash
# Compare responses for different user roles
curl -H "Authorization: Bearer admin_token" https://target.com/api/admin
curl -H "Authorization: Bearer user_token" https://target.com/api/admin

# Compare responses for different input types
curl "https://target.com/search?q=test" > normal_response.txt
curl "https://target.com/search?q=test'" > sql_response.txt
diff normal_response.txt sql_response.txt
```

#### Technique 2: Timing Analysis

Use timing differences to detect blind vulnerabilities:

```bash
# Time-based SQL injection
time curl "https://target.com/page?id=1' AND SLEEP(5)--"
time curl "https://target.com/page?id=1"

# Time-based command injection
time curl "https://target.com/api/cmd?input=test%0asleep%205"
time curl "https://target.com/api/cmd?input=test"
```

#### Technique 3: Error-Based Analysis

Analyze error messages for information disclosure:

```bash
# Trigger various errors and analyze responses
curl "https://target.com/page?id=" | grep -i "error\|exception\|stack trace"
curl "https://target.com/page?id=1'" | grep -i "mysql\|syntax\|query"
curl "https://target.com/page?param=<>" | grep -i "xml\|parse\|entity"
```

#### Technique 4: Side-Channel Analysis

Use side channels to extract information:

```bash
# Timing side channel
# Measure response times for different inputs
for i in {1..100}; do
  time curl -s "https://target.com/api/check?user=admin&password=$i" > /dev/null
done

# Error side channel
# Analyze error messages for information
curl "https://target.com/api/login" -d '{"username":"admin","password":"wrong"}' | jq '.error'
```

### Vulnerability Hunting Checklist

**Pre-Hunting**:
- [ ] Understand application architecture
- [ ] Identify technology stack
- [ ] Map attack surface
- [ ] Set up testing environment
- [ ] Review program scope and rules

**Injection Testing**:
- [ ] Test for SQL injection
- [ ] Test for command injection
- [ ] Test for NoSQL injection
- [ ] Test for LDAP injection
- [ ] Test for template injection

**Authentication Testing**:
- [ ] Test for credential stuffing
- [ ] Test for session fixation
- [ ] Test for JWT vulnerabilities
- [ ] Test for OAuth flaws
- [ ] Test for password reset issues

**Access Control Testing**:
- [ ] Test for IDOR
- [ ] Test for privilege escalation
- [ ] Test for forced browsing
- [ ] Test for function-level access control

**XSS Testing**:
- [ ] Test for reflected XSS
- [ ] Test for stored XSS
- [ ] Test for DOM-based XSS
- [ ] Test for blind XSS

**Other Testing**:
- [ ] Test for SSRF
- [ ] Test for file upload vulnerabilities
- [ ] Test for CSRF
- [ ] Test for business logic flaws
- [ ] Test for information disclosure

### Vulnerability Severity Assessment Guide

**Critical Vulnerabilities (CVSS 9.0-10.0)**:
- Remote Code Execution
- SQL Injection with data exfiltration
- Authentication bypass
- Chain leading to system compromise

**High Vulnerabilities (CVSS 7.0-8.9)**:
- Stored XSS
- SSRF to internal network
- IDOR with sensitive data
- CSRF on critical actions

**Medium Vulnerabilities (CVSS 4.0-6.9)**:
- Reflected XSS
- CSRF on non-critical actions
- Information disclosure
- Open redirect

**Low Vulnerabilities (CVSS 0.1-3.9)**:
- Clickjacking
- Missing headers
- Verbose error messages
- Version disclosure

### Common Vulnerability Patterns by Framework

**PHP Applications**:
- SQL injection in `mysql_query()` calls
- XSS in `echo` statements
- File inclusion vulnerabilities in `include()` calls
- Command injection in `exec()` calls

**Python/Django Applications**:
- SQL injection in raw queries
- XSS in template rendering
- SSTI in Jinja2 templates
- Mass assignment in form handling

**JavaScript/Node.js Applications**:
- Prototype pollution
- NoSQL injection
- XSS in DOM manipulation
- ReDoS in regular expressions

**Ruby/Rails Applications**:
- SQL injection in ActiveRecord queries
- XSS in ERB templates
- Mass assignment vulnerabilities
- CSRF in form handling

### Vulnerability Hunting Resources

**Learning Resources**:
- OWASP Testing Guide
- PortSwigger Web Security Academy
- HackTricks
- SecLists

**Tool Resources**:
- Burp Suite extensions
- Nuclei templates
- SQLMap tamper scripts
- XSStrike payloads

**Community Resources**:
- Bug bounty platforms
- Security conferences
- Research papers
- Vulnerability databases

### Vulnerability Hunting Automation Scripts

#### Automated SQL Injection Testing Script

```bash
#!/bin/bash
# Automated SQL injection testing for multiple parameters
TARGET=$1
PARAMS_FILE=$2

while IFS= read -r param; do
  echo "Testing parameter: $param"
  sqlmap -u "https://$TARGET/page?$param=1" --batch --risk=3 --level=5 --output-dir=sqlmap_results/
done < "$PARAMS_FILE"
```

#### Automated XSS Testing Script

```bash
#!/bin/bash
# Automated XSS testing for multiple parameters
TARGET=$1
PARAMS_FILE=$2

while IFS= read -r param; do
  echo "Testing parameter: $param"
  PAYLOADS=("<script>alert(1)</script>" "<img src=x onerror=alert(1)>" "<svg onload=alert(1)>")
  for payload in "${PAYLOADS[@]}"; do
    curl -s "https://$TARGET/page?$param=$payload" | grep -i "$payload" && echo "XSS found in $param"
  done
done < "$PARAMS_FILE"
```

#### Automated Command Injection Testing Script

```bash
#!/bin/bash
# Automated command injection testing
TARGET=$1
PARAMS_FILE=$2

while IFS= read -r param; do
  echo "Testing parameter: $param"
  PAYLOADS=("%0a'id'" "%0a'whoami'" "%0a'cat%20/etc/passwd'")
  for payload in "${PAYLOADS[@]}"; do
    curl -s "https://$TARGET/page?$param=test$payload" | grep -i "uid\|gid\|root" && echo "Command injection found in $param"
  done
done < "$PARAMS_FILE"
```

### Vulnerability Hunting Workflow Diagrams

#### Standard Hunting Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    Vulnerability Hunting Workflow            │
├─────────────────────────────────────────────────────────────┤
│  1. Reconnaissance                                          │
│     ├── Technology fingerprinting                           │
│     ├── Attack surface mapping                              │
│     └── Endpoint discovery                                  │
│                                                             │
│  2. Vulnerability Testing                                   │
│     ├── Injection testing (SQL, XSS, Command, etc.)        │
│     ├── Authentication testing                              │
│     ├── Access control testing                              │
│     └── Business logic testing                              │
│                                                             │
│  3. Exploitation                                            │
│     ├── Develop proof of concept                            │
│     ├── Validate impact                                     │
│     └── Document exploitation steps                         │
│                                                             │
│  4. Reporting                                               │
│     ├── Write detailed report                               │
│     ├── Include proof of concept                            │
│     └── Submit to platform                                  │
└─────────────────────────────────────────────────────────────┘
```

#### SQL Injection Testing Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  SQL Injection Testing Flow                 │
├─────────────────────────────────────────────────────────────┤
│  1. Identify Input Points                                   │
│     ├── URL parameters                                      │
│     ├── POST data                                           │
│     ├── HTTP headers                                        │
│     └── Cookies                                             │
│                                                             │
│  2. Test for Vulnerability                                  │
│     ├── Single quote test                                   │
│     ├── Boolean-based testing                               │
│     ├── Time-based testing                                  │
│     └── Error-based testing                                 │
│                                                             │
│  3. Exploitation                                            │
│     ├── UNION-based extraction                              │
│     ├── Blind data extraction                               │
│     ├── Stacked queries                                     │
│     └── Out-of-band exploitation                            │
│                                                             │
│  4. Post-Exploitation                                       │
│     ├── Database enumeration                                │
│     ├── Data extraction                                     │
│     ├── Privilege escalation                                │
│     └── Operating system access                             │
└─────────────────────────────────────────────────────────────┘
```

### Vulnerability Hunting Performance Metrics

#### Time Investment Analysis

| Activity | Average Time | Priority |
|----------|--------------|----------|
| Reconnaissance | 2-4 hours | High |
| Technology fingerprinting | 1-2 hours | High |
| Vulnerability testing | 4-8 hours | Critical |
| Exploitation | 2-6 hours | High |
| Reporting | 2-4 hours | Medium |

#### Finding Rate Analysis

| Vulnerability Class | Average Findings per 10 Hours | Difficulty |
|--------------------|-------------------------------|------------|
| Information Disclosure | 3-5 | Low |
| Missing Headers | 2-4 | Low |
| XSS (Reflected) | 1-3 | Medium |
| IDOR | 1-2 | Medium |
| SQL Injection | 0-1 | High |
| Authentication Bypass | 0-1 | High |
| Business Logic | 1-2 | High |

### Vulnerability Hunting Best Practices Summary

1. **Understand the Target**: Invest time in reconnaissance and technology fingerprinting
2. **Systematic Testing**: Follow a structured methodology for each vulnerability class
3. **Document Everything**: Record all findings, including negative results
4. **Validate Findings**: Confirm vulnerabilities through exploitation
5. **Quantify Impact**: Calculate and document the business impact
6. **Stay Updated**: Keep up with new vulnerability classes and techniques
7. **Learn from Others**: Study published reports and research
8. **Practice Regularly**: Continuously improve your skills through practice
9. **Use the Right Tools**: Leverage automated tools for efficiency
10. **Be Patient**: Deep vulnerability hunting requires time and persistence
