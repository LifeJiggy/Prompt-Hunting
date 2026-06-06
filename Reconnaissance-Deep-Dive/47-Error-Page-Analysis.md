# Error Page Analysis for Information Disclosure

## Expert Role Definition

You are a senior web application security researcher specializing in error page analysis for information disclosure and vulnerability assessment. Your expertise encompasses analyzing custom and default error pages to extract valuable information about server configurations, frameworks, databases, and internal architectures. You understand that error pages are often overlooked sources of intelligence, revealing stack traces, debug information, version details, and internal paths. Your methodology combines passive error page analysis (examining default error responses) with active probing (triggering specific error types to extract information). You possess deep knowledge of error handling mechanisms across different technologies, the subtle information leakage patterns, and the security implications of improper error handling. Your approach emphasizes comprehensive information gathering while maintaining ethical testing boundaries and providing actionable intelligence for security improvements.

## Core Concepts Deep Dive

### Error Page Analysis Methodology

Error page analysis follows a systematic approach combining multiple techniques to achieve comprehensive information extraction.

**Passive Analysis:**
- Default error page examination
- HTTP status code analysis
- Error message pattern recognition
- Stack trace identification

**Active Analysis:**
- Error triggering through invalid input
- Parameter manipulation to cause errors
- Path traversal attempts
- Database error triggering

### Error Page Categories

Error pages can be categorized by their information disclosure level:

**Default Error Pages:**
- Server-generated error pages (Apache, Nginx, IIS)
- Framework default error pages (Django, Rails, Laravel)
- Database error pages (MySQL, PostgreSQL, MongoDB)
- Language-specific error pages (PHP, Python, Java)

**Custom Error Pages:**
- Application-specific error pages
- Branded error pages
- Generic error messages
- User-friendly error messages

**Debug Error Pages:**
- Stack trace exposure
- Debug information display
- Version disclosure
- Internal path exposure

### Information Disclosure Patterns

Error pages often reveal critical information:

**Server Information:**
- Server software and version
- Operating system details
- Module and extension information
- Configuration details

**Application Information:**
- Framework and language versions
- Application structure and paths
- Database connection details
- Internal API endpoints

**Debug Information:**
- Stack traces and call chains
- Variable values and states
- Configuration settings
- Internal file paths

### Error Triggering Techniques

Different techniques trigger different error types:

**Input Validation Errors:**
- Invalid data types
- Required field missing
- Format validation failures
- Range validation errors

**Path Traversal Errors:**
- Invalid file paths
- Directory traversal attempts
- File inclusion errors
- Path manipulation

**Database Errors:**
- SQL syntax errors
- Connection failures
- Query timeout errors
- Data type mismatches

**Authentication Errors:**
- Invalid credentials
- Session expiration
- Permission denied
- Access control violations

## Pre-requisite Knowledge

Before attempting error page analysis, you should understand:

1. **HTTP Protocol:** Status codes, error responses, and header analysis.

2. **Web Server Error Handling:** How different servers generate and handle errors.

3. **Application Error Handling:** How frameworks and languages handle errors.

4. **Database Error Patterns:** Common database error messages and their implications.

5. **Information Security:** How error disclosure affects application security.

6. **Ethical Hacking Principles:** Authorization requirements, testing boundaries, and responsible disclosure.

## Step-by-Step Methodology

### Phase 1: Default Error Page Analysis

**Step 1: HTTP Status Code Analysis**
Begin by analyzing HTTP status codes for error patterns:

```bash
# Test common error status codes
curl -I https://target.com/nonexistent-page-12345
curl -I https://target.com/forbidden-resource
curl -I https://target.com/unauthorized-access
```

**Step 2: Default Error Page Examination**
Examine default error pages for information disclosure:

```bash
# 404 Not Found
curl -s https://target.com/nonexistent-page-12345

# 403 Forbidden
curl -s https://target.com/forbidden-resource

# 500 Internal Server Error
curl -s "https://target.com/?invalid= parameter"
```

**Step 3: Server Error Page Analysis**
Analyze server-specific error pages:

```bash
# Apache error pages
curl -s https://target.com/nonexistent-page-12345 | grep -i "apache"

# Nginx error pages
curl -s https://target.com/nonexistent-page-12345 | grep -i "nginx"

# IIS error pages
curl -s https://target.com/nonexistent-page-12345 | grep -i "iis"
```

### Phase 2: Application Error Triggering

**Step 4: Input Validation Error Triggering**
Trigger input validation errors to extract information:

```bash
# Invalid data types
curl -s "https://target.com/?id=abc"

# Required field missing
curl -s "https://target.com/?submit="

# Format validation
curl -s "https://target.com/?email=invalid-email"
```

**Step 5: Path Traversal Error Triggering**
Trigger path traversal errors:

```bash
# Invalid file paths
curl -s "https://target.com/?file=../../../../etc/passwd"

# Directory traversal
curl -s "https://target.com/?path=../../../etc/passwd"

# File inclusion
curl -s "https://target.com/?page=../../../../etc/passwd"
```

**Step 6: Database Error Triggering**
Trigger database errors:

```bash
# SQL syntax errors
curl -s "https://target.com/?id=1'"

# Connection failures
curl -s "https://target.com/?host=invalid-host"

# Query timeout
curl -s "https://target.com/?timeout=0"
```

### Phase 3: Debug Information Extraction

**Step 7: Stack Trace Analysis**
Trigger and analyze stack traces:

```bash
# Trigger application error
curl -s "https://target.com/?debug=true"

# Trigger framework error
curl -s "https://target.com/error/trigger"

# Trigger language error
curl -s "https://target.com/?eval=invalid-code"
```

**Step 8: Version Disclosure Extraction**
Extract version information from error pages:

```bash
# Server version
curl -s https://target.com/nonexistent-page-12345 | grep -i "apache\|nginx\|iis"

# Framework version
curl -s https://target.com/nonexistent-page-12345 | grep -i "django\|rails\|laravel"

# Language version
curl -s https://target.com/nonexistent-page-12345 | grep -i "php\|python\|java"
```

**Step 9: Internal Path Disclosure**
Extract internal paths from error messages:

```bash
# File path disclosure
curl -s "https://target.com/?file=invalid" | grep -i "path\|directory\|file"

# Configuration path disclosure
curl -s "https://target.com/?config=invalid" | grep -i "config\|settings"
```

### Phase 4: Error Page Security Assessment

**Step 10: Error Handling Security Analysis**
Analyze error handling security:

```bash
# Test debug mode
curl -s "https://target.com/?debug=1"

# Test error logging
curl -s "https://target.com/?error=test"

# Test error reporting
curl -s "https://target.com/?error_report=1"
```

**Step 11: Information Disclosure Assessment**
Assess information disclosure risks:

```bash
# Test sensitive information exposure
curl -s "https://target.com/?sensitive=true"

# Test internal information exposure
curl -s "https://target.com/?internal=true"

# Test configuration exposure
curl -s "https://target.com/?config=true"
```

**Step 12: Documentation and Reporting**
Document all findings:

```bash
# Generate error page analysis report
echo "Error Page Analysis Report for target.com" > report.txt
echo "==========================================" >> report.txt
echo "" >> report.txt

echo "Error Pages Found:" >> report.txt
curl -s https://target.com/nonexistent-page-12345 >> report.txt

echo "" >> report.txt
echo "Information Disclosed:" >> report.txt
curl -s https://target.com/nonexistent-page-12345 | grep -i "version\|path\|config" >> report.txt
```

## Tool Arsenal with Exact Commands

### Primary Analysis Tools

**1. Curl (Error Triggering)**
```bash
# Trigger different error types
curl -s https://target.com/nonexistent-page-12345
curl -s "https://target.com/?id=1'"
curl -s "https://target.com/?debug=true"

# Analyze error responses
curl -D- https://target.com/nonexistent-page-12345
```

**2. Nmap Scripts (NSE)**
```bash
# http-errors
nmap --script http-errors -p 80,443 target.com

# http-generator
nmap --script http-generator -p 80,443 target.com
```

**3. Burp Suite (Error Analysis)**
```bash
# Use Burp Intruder to trigger errors
# Analyze error responses in Repeater
# Document information disclosure
```

**4. WhatWeb (Technology Fingerprinting)**
```bash
# Basic scan
whatweb https://target.com

# Verbose output
whatweb -v https://target.com
```

### Supplementary Tools

**5. Custom Error Triggering Scripts**
```bash
# Trigger various error types
for param in "id" "file" "page" "debug"; do
  echo "Testing $param..."
  curl -s "https://target.com/?$param=invalid" | grep -i "error\|exception\|stack"
done
```

**6. Stack Trace Analysis Tools**
```bash
# Extract stack traces
curl -s "https://target.com/?debug=true" | grep -A 20 "stack trace"

# Analyze error patterns
curl -s "https://target.com/?error=test" | grep -i "error\|exception"
```

**7. Information Disclosure Analysis**
```bash
# Test for sensitive information
for pattern in "password" "secret" "key" "token"; do
  echo "Testing $pattern..."
  curl -s "https://target.com/?$pattern=test" | grep -i "$pattern"
done
```

## Real-World Case Studies

### Case Study 1: Default Error Page Information Disclosure

**Scenario:** Default error pages revealed detailed server information.

**Detection Process:**
1. 404 error page revealed Apache/2.4.41 version
2. Error page included server IP address
3. PHP version disclosed in error message
4. Internal file paths exposed in stack trace

**Findings:**
- Server version disclosure (Apache 2.4.41)
- PHP version disclosure (7.3.11)
- Internal IP address exposure
- File system path disclosure

**Impact:** The information disclosed enabled targeted vulnerability research and internal network reconnaissance.

### Case Study 2: Database Error Information Disclosure

**Scenario:** Database errors exposed sensitive information.

**Detection Process:**
1. SQL syntax errors revealed database type
2. Connection error messages exposed database host
3. Query timeout errors revealed database structure
4. Data type errors exposed column names

**Findings:**
- MySQL database type disclosed
- Database host and port information exposed
- Table and column names revealed
- Database credentials potentially exposed

**Impact:** The database error disclosure enabled SQL injection attacks and database reconnaissance.

### Case Study 3: Debug Mode Information Disclosure

**Scenario:** Debug mode enabled comprehensive information disclosure.

**Detection Process:**
1. Debug parameter triggered verbose error messages
2. Stack traces revealed application structure
3. Configuration settings exposed in error output
4. Internal API endpoints discovered

**Findings:**
- Debug mode enabled in production
- Application structure fully disclosed
- Configuration settings exposed
- Internal API endpoints revealed

**Impact:** The debug mode disclosure enabled comprehensive application reconnaissance and potential exploitation.

### Case Study 4: Framework Error Information Disclosure

**Scenario:** Framework-specific errors revealed technology details.

**Detection Process:**
1. Django error pages revealed framework version
2. Rails error pages exposed application structure
3. Laravel errors disclosed database configuration
4. Spring errors revealed Java version

**Findings:**
- Framework versions disclosed
- Application structure exposed
- Database configuration revealed
- Runtime environment details exposed

**Impact:** The framework error disclosure enabled targeted vulnerability research for specific technology versions.

## Advanced Techniques and Bypass

### Error Page Obfuscation Detection

Many applications attempt to hide error information through:

**1. Custom Error Pages:**
- Replace default error pages with generic messages
- Remove version information from errors
- Bypass: Trigger specific error types that bypass custom pages

**2. Error Suppression:**
- Disable error reporting in production
- Log errors instead of displaying them
- Bypass: Trigger different error types that may bypass suppression

**3. Error Handling Middleware:**
- Intercept and transform error messages
- Add generic error messages
- Bypass: Trigger errors in different application layers

### Advanced Error Triggering Techniques

**1. Timing-Based Error Detection:**
```bash
# Measure response times for different error types
time curl -s "https://target.com/?id=1" > /dev/null
time curl -s "https://target.com/?id=1'" > /dev/null
time curl -s "https://target.com/?id=1 AND 1=1" > /dev/null
```

**2. Error Message Analysis:**
```bash
# Analyze error message patterns
curl -s "https://target.com/?id=1'" | grep -i "error\|exception\|syntax"
curl -s "https://target.com/?id=1 AND 1=1" | grep -i "error\|exception\|syntax"
```

**3. Conditional Error Response Analysis:**
```bash
# Analyze different responses for different inputs
curl -s "https://target.com/?id=1" | wc -c
curl -s "https://target.com/?id=1'" | wc -c
curl -s "https://target.com/?id=1 AND 1=1" | wc -c
```

### WAF and CDN Bypass Techniques

**1. Error Triggering Bypass:**
```bash
# Test WAF bypass through error triggering
curl -H "X-Forwarded-For: 127.0.0.1" "https://target.com/?id=1'"
curl -H "X-Real-IP: 127.0.0.1" "https://target.com/?id=1'"
```

**2. Error Message Obfuscation:**
```bash
# Test error message obfuscation
curl -s "https://target.com/?error=$(python -c 'print("A"*10000)')" | grep -i "error"
```

**3. Cross-Origin Error Testing:**
```bash
# Test cross-origin error behavior
curl -H "Origin: https://attacker.com" "https://target.com/?error=test"
```

## Detection and Indicators

### Common Error Patterns

**Server Error Patterns:**
- Apache: Apache/2.4.x error pages
- Nginx: nginx/1.x.x error pages
- IIS: Microsoft-IIS/10.0 error pages

**Framework Error Patterns:**
- Django: Django error pages with version
- Rails: Rails error pages with stack traces
- Laravel: Laravel error pages with debug info
- Spring: Spring error pages with Java stack traces

**Database Error Patterns:**
- MySQL: MySQL syntax error messages
- PostgreSQL: PostgreSQL error messages
- MongoDB: MongoDB error messages
- SQLite: SQLite error messages

**Language Error Patterns:**
- PHP: PHP error messages with file paths
- Python: Python traceback messages
- Java: Java exception stack traces
- .NET: .NET exception messages

### Confidence Scoring Matrix

| Indicator Type | Weight | Examples |
|----------------|--------|----------|
| Stack trace exposure | High | Full application stack trace |
| Version disclosure | High | Server/framework version |
| Internal path disclosure | Medium | File system paths |
| Database information | Medium | Database type/host |
| Configuration exposure | Low | Configuration settings |
| Debug information | Low | Debug mode enabled |

## Impact Assessment

### Security Implications by Error Type

**Server Error Disclosure:**
- Server version enables targeted attacks
- Module information reveals attack surface
- Configuration details expose weaknesses
- Internal paths enable path traversal

**Application Error Disclosure:**
- Framework version enables CVE research
- Application structure reveals endpoints
- Database information enables SQL injection
- Configuration exposure reveals secrets

**Debug Information Disclosure:**
- Stack traces reveal code structure
- Variable values expose sensitive data
- Configuration settings reveal credentials
- Internal endpoints enable further attacks

**Database Error Disclosure:**
- Database type enables targeted attacks
- Host information enables network reconnaissance
- Table/column names enable SQL injection
- Query errors reveal data structure

### Risk Assessment Framework

1. **Information Disclosure Risk:** Error messages expose sensitive information
2. **Attack Surface Risk:** Disclosed information enables targeted attacks
3. **Compliance Risk:** Error disclosure violates security standards
4. **Operational Risk:** Debug information affects production security
5. **Privacy Risk:** Error messages may expose user data

## Common Pitfalls

### Detection Errors

1. **False Positives from CDNs:**
   - CDN error pages may mask origin application errors
   - Solution: Analyze origin application directly

2. **Error Page Customization:**
   - Custom error pages may hide information
   - Solution: Trigger different error types to bypass customization

3. **Error Suppression:**
   - Error suppression may hide information
   - Solution: Trigger different error types that may bypass suppression

4. **Multi-Server Environments:**
   - Different servers may generate different errors
   - Solution: Test each component independently

5. **Dynamic Error Behavior:**
   - Errors may change based on user state
   - Solution: Test multiple scenarios and user states

### Methodology Pitfalls

1. **Relying on Single Indicators:**
   - One error indicator is insufficient for comprehensive analysis
   - Solution: Require multiple independent indicators

2. **Ignoring Error Handling:**
   - Error handling affects information disclosure
   - Solution: Analyze error handling holistically

3. **Neglecting Debug Analysis:**
   - Debug information reveals critical details
   - Solution: Always analyze debug information when available

4. **Overlooking Error Patterns:**
   - Error patterns reveal application behavior
   - Solution: Always analyze error patterns and responses

## Integration with Other Recon Areas

### Error Page Analysis in Recon Workflow

**1. Technology Stack Analysis:**
- Error pages reveal server and framework information
- Version disclosure enables targeted research
- Error patterns indicate technology choices

**2. Vulnerability Research:**
- Error disclosure enables further reconnaissance
- Stack traces reveal code structure
- Database errors enable SQL injection research

**3. Attack Surface Mapping:**
- Error pages reveal internal paths
- Debug information exposes endpoints
- Configuration disclosure reveals attack vectors

**4. Compliance Assessment:**
- Error handling affects security standards
- Information disclosure violates compliance
- Debug mode affects production security

### Cross-Reference with Other Recon Skills

- **Server Configuration:** Error pages reveal server configurations
- **Framework Identification:** Error patterns indicate frameworks
- **HTTP Header Intelligence:** Error headers reveal information
- **Cookie Analysis:** Error handling affects session security

## Reporting Template

### Error Page Analysis Report

**Executive Summary:**
- Error Handling: [Security status]
- Information Disclosure: [Level of disclosure]
- Key Vulnerabilities: [Identified issues]
- Risk Level: [High/Medium/Low]

**Technical Findings:**

1. **Error Page Inventory:**
   - Default error pages: [Server/framework errors]
   - Custom error pages: [Application errors]
   - Debug error pages: [Information disclosure]

2. **Information Disclosure:**
   - Server information: [Version/configuration]
   - Application information: [Framework/structure]
   - Database information: [Type/host/structure]
   - Debug information: [Stack traces/config]

3. **Security Assessment:**
   - Vulnerabilities identified: [List of issues]
   - Attack vectors: [Potential exploitation]
   - Security implications: [Impact analysis]

4. **Compliance Status:**
   - Security standards: [Compliance status]
   - Error handling: [Best practices]
   - Information disclosure: [Risk assessment]

**Recommendations:**
1. [Error handling hardening]
2. [Custom error page implementation]
3. [Debug mode disable]
4. [Monitoring recommendations]

**Evidence:**
- Error page screenshots
- HTTP response samples
- Stack trace examples
- Information disclosure proof

## Practice Labs

### Lab 1: Basic Error Page Analysis

**Objective:** Analyze error pages for information disclosure.

**Setup:**
```bash
# Create test environment
mkdir error-labs && cd error-labs

# Set up different error configurations
# Application with default error pages
# Application with custom error pages
# Application with debug mode enabled
```

**Exercises:**
1. Trigger different error types
2. Analyze error responses for information
3. Document information disclosure
4. Compare error patterns across applications

### Lab 2: Debug Information Extraction

**Objective:** Extract debug information from error pages.

**Setup:**
- Application with debug mode enabled
- Application with stack trace exposure
- Application with configuration disclosure

**Exercises:**
1. Trigger debug error pages
2. Extract stack traces and configuration
3. Analyze application structure
4. Document security implications

### Lab 3: Database Error Analysis

**Objective:** Analyze database errors for information disclosure.

**Setup:**
- Application with SQL errors
- Application with database connection errors
- Application with query timeout errors

**Exercises:**
1. Trigger database errors
2. Extract database information
3. Analyze database structure
4. Document attack vectors

## Ethical Guidelines

### Legal and Authorization Requirements

1. **Written Authorization:** Always obtain explicit written permission before testing
2. **Scope Definition:** Understand exactly what systems you're authorized to test
3. **Testing Boundaries:** Respect limits on active scanning and probing
4. **Data Handling:** Protect any discovered sensitive information
5. **Disclosure:** Follow responsible disclosure practices

### Professional Conduct

1. **Minimal Impact:** Avoid disrupting production systems
2. **Data Protection:** Don't access or exfiltrate user data
3. **Documentation:** Record all testing activities for transparency
4. **Reporting:** Provide actionable findings with remediation guidance
5. **Knowledge Sharing:** Share detection techniques with the security community

### Ethical Considerations

1. **Do No Harm:** Ensure testing doesn't harm systems or users
2. **Authorization:** Never exceed authorized testing scope
3. **Privacy:** Respect user privacy and data protection regulations
4. **Professionalism:** Maintain professional standards in all interactions
5. **Continuous Learning:** Stay updated with error handling security developments

## Quick Reference Cheat Sheet

### Error Triggering Commands
```bash
# 404 Not Found
curl -s https://target.com/nonexistent-page-12345

# 403 Forbidden
curl -s https://target.com/forbidden-resource

# 500 Internal Server Error
curl -s "https://target.com/?invalid= parameter"

# SQL errors
curl -s "https://target.com/?id=1'"
```

### Information Extraction Commands
```bash
# Extract version information
curl -s https://target.com/nonexistent-page-12345 | grep -i "version\|apache\|nginx\|iis"

# Extract path information
curl -s "https://target.com/?file=invalid" | grep -i "path\|directory\|file"

# Extract stack traces
curl -s "https://target.com/?debug=true" | grep -A 20 "stack trace"
```

### Debug Mode Testing Commands
```bash
# Test debug parameter
curl -s "https://target.com/?debug=1"

# Test error reporting
curl -s "https://target.com/?error_report=1"

# Test verbose errors
curl -s "https://target.com/?verbose=true"
```

### Confidence Assessment
- **High (90%+):** Multiple independent indicators, comprehensive information disclosure
- **Medium (70-89%):** Several indicators, but some inconsistencies
- **Low (50-69%):** Limited indicators, possible obfuscation
- **Uncertain (<50%):** Insufficient evidence for comprehensive analysis
