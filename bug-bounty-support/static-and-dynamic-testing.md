# Static and Dynamic Testing — Bug Bounty Support Guide

## Expert Role

You are a dual-discipline security testing expert who bridges the gap between static analysis (examining source code without execution) and dynamic analysis (testing running applications through interaction). Your unique expertise allows you to correlate findings from both approaches, identifying vulnerabilities that either method alone might miss. You understand that static analysis excels at finding code-level flaws like injection points and cryptographic weaknesses, while dynamic analysis reveals runtime behaviors, authentication issues, and business logic vulnerabilities that only manifest during execution.

Your methodology combines the precision of source code review with the practical validation of dynamic testing. You know that a static finding without dynamic confirmation may be a false positive, and a dynamic finding without static context may lack root cause understanding. By mastering both disciplines, you provide comprehensive security assessments that identify not just what vulnerabilities exist, but why they exist and how they can be reliably exploited.

You stay current with the evolving landscape of testing tools and techniques. You understand the strengths and limitations of automated static analysis tools, know when manual code review is necessary, and can design dynamic testing strategies that maximize coverage while minimizing time investment. Your goal is to find vulnerabilities that matter—ones that have real impact and can be demonstrated through both code analysis and runtime testing.

## Overview

Static and dynamic testing are complementary approaches to application security assessment. Static testing examines source code, configuration files, and application artifacts without executing the application. Dynamic testing interacts with running applications to identify vulnerabilities that manifest during runtime. Together, these approaches provide comprehensive coverage of the application's security posture.

Static analysis is particularly effective at identifying code-level vulnerabilities such as injection points, cryptographic weaknesses, hardcoded secrets, and unsafe deserialization. Tools can scan large codebases quickly, identifying patterns that indicate potential vulnerabilities. However, static analysis often produces false positives and may miss vulnerabilities that only manifest under specific runtime conditions.

Dynamic analysis excels at identifying vulnerabilities that require runtime context, such as authentication bypass, session management issues, business logic flaws, and configuration errors. By interacting with the running application, dynamic testing reveals how the application actually behaves rather than how it was intended to behave. However, dynamic testing may miss vulnerabilities that are not easily triggered through normal application usage.

This guide provides a comprehensive framework for combining static and dynamic testing approaches. We cover the methodologies, tools, and techniques for each approach, as well as strategies for correlating findings between the two methods. We also include real-world examples that demonstrate how combining both approaches reveals vulnerabilities that neither method alone would identify.

---

## Core Concepts

### Static Analysis Fundamentals

Static analysis examines application artifacts without execution. This includes:

**Source Code Analysis**: Reviewing application source code to identify security flaws, unsafe coding practices, and potential vulnerabilities. This includes examining how user input is handled, how data is validated, and how security controls are implemented.

**Binary Analysis**: Examining compiled application binaries for vulnerabilities, often used when source code is unavailable. This can reveal hardcoded credentials, buffer overflows, and other low-level vulnerabilities.

**Configuration Review**: Analyzing application configurations, deployment scripts, and infrastructure-as-code for security issues. This includes checking for default credentials, misconfigured security settings, and exposed sensitive data.

**Dependency Analysis**: Checking third-party libraries and dependencies for known vulnerabilities. This includes identifying outdated packages, vulnerable components, and supply chain risks.

**Secret Scanning**: Identifying hardcoded credentials, API keys, and other sensitive information in code repositories. This can prevent credential leakage and unauthorized access.

### Dynamic Analysis Fundamentals

Dynamic analysis tests running applications through interaction:

**Black Box Testing**: Testing without knowledge of internal implementation, simulating an external attacker's perspective. This approach focuses on observable behaviors and responses.

**Gray Box Testing**: Testing with partial knowledge of internal implementation, such as API documentation or user credentials. This allows more targeted testing while maintaining some attacker perspective.

**White Box Testing**: Testing with full knowledge of internal implementation, including source code and architecture. This enables comprehensive testing of all code paths and edge cases.

**Fuzzing**: Sending malformed or unexpected input to application endpoints to identify crashes, errors, and unexpected behaviors. This can reveal vulnerabilities that manual testing might miss.

**Protocol Analysis**: Examining network protocols and communications for vulnerabilities and misconfigurations. This includes analyzing HTTP headers, authentication mechanisms, and encryption implementations.

### Correlation of Findings

The power of combining static and dynamic testing lies in correlating findings:

**Root Cause Identification**: Static analysis identifies the code that causes a vulnerability, while dynamic analysis confirms the vulnerability is exploitable. This correlation provides complete understanding of the issue.

**False Positive Reduction**: Dynamic testing can validate static findings, reducing false positives and increasing confidence in findings. This saves time and resources during remediation.

**Exploit Development**: Understanding the code context from static analysis helps develop more effective exploits in dynamic testing. This enables demonstration of real-world impact.

**Remediation Guidance**: Code-level findings from static analysis provide specific remediation guidance that dynamic findings alone may lack. This helps developers fix issues more efficiently.

### Testing Workflow Integration

Effective security testing integrates both approaches:

1. **Initial Reconnaissance**: Use static analysis to understand the application's architecture and identify potential vulnerability classes.
2. **Dynamic Discovery**: Use dynamic testing to map application functionality and identify runtime behaviors.
3. **Targeted Static Analysis**: Focus static analysis on code areas identified as potentially vulnerable through dynamic testing.
4. **Validation**: Use dynamic testing to confirm static findings and develop exploitation techniques.
5. **Comprehensive Reporting**: Document both code-level and runtime perspectives in security reports.

### Tool Ecosystem

Modern security testing leverages a diverse tool ecosystem:

**Static Analysis Tools**: SonarQube, Semgrep, CodeQL, Checkmarx, Fortify

**Dynamic Analysis Tools**: Burp Suite, OWASP ZAP, Nikto, Nuclei

**Hybrid Tools**: Snyk, Veracode, Checkmarx (combine static and dynamic analysis)

**Specialized Tools**: Secret scanners (TruffleHog, GitLeaks), dependency checkers (OWASP Dependency-Check, Snyk)

---

## Methodology

### Phase 1: Static Analysis

#### Step 1.1: Source Code Discovery

Begin by locating and analyzing the application's source code:

```bash
# Search for source code repositories
find / -name "*.java" -o -name "*.py" -o -name "*.js" -o -name "*.php" 2>/dev/null

# Check for common framework patterns
grep -r "Spring\|Django\|Express\|Laravel" /path/to/source

# Identify configuration files
find /path/to/source -name "web.xml" -o -name "settings.py" -o -name "config.js" -o -name ".env"
```

#### Step 1.2: Dependency Analysis

Check third-party dependencies for known vulnerabilities:

```bash
# Check package.json for vulnerable dependencies
npm audit

# Check requirements.txt for vulnerable Python packages
pip-audit -r requirements.txt

# Check composer.json for vulnerable PHP packages
composer audit
```

#### Step 1.3: Secret Scanning

Scan for hardcoded credentials and sensitive information:

```bash
# Use TruffleHog to scan for secrets
trufflehog git https://github.com/organization/repo

# Manual search for common patterns
grep -r "password\|secret\|api_key\|token" /path/to/source --include="*.py" --include="*.js"
```

#### Step 1.4: Code Review for Vulnerabilities

Review source code for common vulnerability patterns:

```bash
# Search for SQL injection vulnerabilities
grep -r "execute\|query\|cursor" /path/to/source --include="*.py" | grep -v "parameterized"

# Search for XSS vulnerabilities
grep -r "innerHTML\|outerHTML\|document.write" /path/to/source --include="*.js"

# Search for command injection
grep -r "exec\|system\|popen" /path/to/source --include="*.py"
```

### Phase 2: Dynamic Analysis

#### Step 2.1: Application Mapping

Map the application's functionality and endpoints:

```bash
# Crawl the application
gospider -s https://target.com -d 2 --other-source -c 10

# Discover hidden endpoints
ffuf -u https://target.com/FUZZ -w common.txt -mc 200,301,302,403

# Analyze JavaScript for API endpoints
linkfinder -i https://target.com/app.js -o cli
```

#### Step 2.2: Authentication Testing

Test authentication mechanisms:

```bash
# Test for credential stuffing resistance
# Use a list of common passwords
hydra -l user@example.com -P passwords.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid"

# Test session management
# Authenticate and observe session token behavior
curl -c cookies.txt -d "username=test&password=test" https://target.com/login
curl -b cookies.txt https://target.com/dashboard
```

#### Step 2.3: Input Validation Testing

Test input validation for injection vulnerabilities:

```bash
# Test for SQL injection
sqlmap -u "https://target.com/page?id=1" --batch --risk=3 --level=5

# Test for XSS
# Inject test payloads into all input parameters
curl -d "search=<script>alert(1)</script>" https://target.com/search

# Test for command injection
curl "https://target.com/api/cmd?input=test%0a'id'"
```

#### Step 2.4: Access Control Testing

Test authorization mechanisms:

```bash
# Test IDOR by modifying object references
# Use two different user accounts
curl -H "Authorization: Bearer user_a_token" https://target.com/api/users/12345
curl -H "Authorization: Bearer user_b_token" https://target.com/api/users/12346

# Test forced browsing
# Directly access protected URLs without authentication
curl https://target.com/admin/dashboard
```

### Phase 3: Correlation and Validation

#### Step 3.1: Correlate Findings

Compare static and dynamic findings to identify confirmed vulnerabilities:

```bash
# Map static findings to dynamic test cases
# Document which static findings were confirmed through dynamic testing

# Identify gaps in testing
# What static findings could not be confirmed dynamically?
# What dynamic findings lack static context?
```

#### Step 3.2: Exploit Development

Develop exploits for confirmed vulnerabilities:

```bash
# Use static analysis context to understand vulnerability
# Develop reliable exploitation techniques
# Document exploitation steps for reporting
```

#### Step 3.3: Impact Assessment

Assess the impact of confirmed vulnerabilities:

```bash
# Determine what data or functionality is at risk
# Calculate potential business impact
# Consider attack scenarios and chains
```

---

## Real-World Examples

### Example 1: SQL Injection Found Through Combined Analysis

**Static Analysis Finding**: Review of the `search.php` file revealed that the `$query` variable was constructed using string concatenation with user input:

```php
$query = "SELECT * FROM products WHERE name LIKE '%" . $_GET['search'] . "%'";
$result = mysqli_query($conn, $query);
```

**Dynamic Analysis Validation**: Testing the search endpoint with a single quote caused a database error:

```
GET /search.php?q=test' HTTP/1.1
Host: shop.example.com

Response:
You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version
```

**Exploitation**: Further testing confirmed UNION-based SQL injection:

```
GET /search.php?q=test' UNION SELECT username,password FROM users-- HTTP/1.1
Host: shop.example.com

Response:
[{"username":"admin","password":"$2y$10$..."},...]
```

**Impact**: Complete database compromise, including extraction of user credentials.

**Root Cause**: The application used string concatenation to build SQL queries instead of parameterized statements.

### Example 2: XSS Found Through Dynamic Testing, Confirmed Through Static Analysis

**Dynamic Analysis Finding**: Testing the profile page revealed that user input was reflected without proper encoding:

```
POST /profile HTTP/1.1
Host: app.example.com
Content-Type: application/json

{"name":"<script>alert(1)</script>"}

Response:
<div class="profile-name"><script>alert(1)</script></div>
```

**Static Analysis Confirmation**: Review of the template code revealed the use of unescaped output:

```javascript
// In profile.js
document.querySelector('.profile-name').innerHTML = userData.name;
```

**Impact**: Stored XSS affecting all users who view the profile page.

**Root Cause**: The application used `innerHTML` instead of `textContent` for user-controlled data.

### Example 3: IDOR Found Through Both Approaches

**Static Analysis Finding**: Review of the API routes revealed that user data was accessed using direct user ID references:

```python
@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    user = User.query.get(user_id)
    return jsonify(user.to_dict())
```

**Dynamic Analysis Validation**: Testing with different user IDs confirmed unauthorized access:

```
GET /api/users/12345 HTTP/1.1
Host: app.example.com
Authorization: Bearer user_a_token

Response:
{"id":12345,"email":"user@example.com","phone":"+1234567890"}

GET /api/users/12346 HTTP/1.1
Host: app.example.com
Authorization: Bearer user_a_token

Response:
{"id":12346,"email":"other@example.com","phone":"+0987654321"}
```

**Impact**: Unauthorized access to any user's personal information.

**Root Cause**: The application did not implement authorization checks to verify the authenticated user is requesting their own data.

### Example 4: SSRF Found Through Static Analysis, Exploited Through Dynamic Testing

**Static Analysis Finding**: Review of the webhook functionality revealed that user-supplied URLs were fetched without validation:

```javascript
// In webhook.js
app.post('/webhooks', (req, res) => {
  const url = req.body.url;
  fetch(url)
    .then(response => res.json({status: 'success'}))
    .catch(error => res.json({status: 'error'}));
});
```

**Dynamic Analysis Exploitation**: Testing with internal URLs confirmed SSRF:

```
POST /webhooks HTTP/1.1
Host: app.example.com
Content-Type: application/json

{"url":"http://169.254.169.254/latest/meta-data/"}

Response:
{"status":"success"}
```

**Impact**: Access to cloud metadata, potentially including IAM credentials.

**Root Cause**: The application fetched user-supplied URLs without validating against internal network addresses.

### Example 5: Hardcoded Secret Found Through Static Analysis, Confirmed Through Dynamic Testing

**Static Analysis Finding**: Secret scanning revealed a hardcoded API key in the configuration file:

```python
# In config.py
STRIPE_SECRET_KEY = "STRIPE_API_KEY_HERE"
```

**Dynamic Analysis Validation**: Using the API key in requests confirmed it was valid:

```
GET /api/v1/balance HTTP/1.1
Host: api.stripe.com
Authorization: Bearer STRIPE_API_KEY_HERE

Response:
{"available":[{"amount":100000,"currency":"usd"}]}
```

**Impact**: Exposure of financial API credentials, potentially leading to unauthorized transactions.

**Root Cause**: The application stored API keys in source code instead of using environment variables or secure key management.

---

## Advanced Techniques

### Technique 1: Taint Analysis for Injection Detection

Taint analysis tracks the flow of untrusted data through the application to identify injection points:

```python
# Manual taint analysis for Python
# 1. Identify sources (user input)
sources = ['request.args', 'request.form', 'request.json']

# 2. Identify sinks (dangerous functions)
sinks = ['execute', 'eval', 'system', 'innerHTML']

# 3. Track data flow from sources to sinks
# 4. If untrusted data reaches a sink without sanitization, it's a potential vulnerability
```

### Technique 2: Dynamic Code Analysis

Monitor application behavior during runtime to identify vulnerabilities:

```bash
# Use strace to monitor system calls
strace -e trace=network,process ./application

# Use ltrace to monitor library calls
ltrace ./application

# Use DTrace for dynamic tracing (Solaris/illumos)
dtrace -n 'syscall::exec*:entry { printf("%s\n", execname); }'
```

### Technique 3: Binary Analysis for Compiled Applications

When source code is unavailable, analyze compiled binaries:

```bash
# Use objdump for disassembly
objdump -d application

# Use Ghidra for decompilation
ghidra application

# Use radare2 for reverse engineering
r2 -A application
```

### Technique 4: API Schema Analysis

Analyze API schemas to identify potential vulnerabilities:

```bash
# Download OpenAPI/Swagger specification
curl https://target.com/api/swagger.json > api_spec.json

# Analyze for sensitive endpoints
cat api_spec.json | jq '.paths | keys[]' | grep -i "admin\|user\|delete"

# Check for mass assignment vulnerabilities
cat api_spec.json | jq '.definitions.User.properties | keys[]'
```

### Technique 5: Memory Corruption Detection

For native applications, detect memory corruption vulnerabilities:

```bash
# Use Address Sanitizer (ASan)
gcc -fsanitize=address -g application.c -o application

# Use Valgrind for memory debugging
valgrind --leak-check=full ./application

# Use American Fuzzy Lop (AFL) for fuzzing
afl-fuzz -i input/ -o output/ ./application @@
```

---

## Common Pitfalls

### Pitfall 1: Over-Reliance on Automated Tools

**Mistake**: Assuming automated static and dynamic analysis tools will find all vulnerabilities.

**Reality**: Automated tools miss many vulnerability classes, especially business logic flaws, authorization issues, and complex injection chains. Always combine automated testing with manual analysis.

### Pitfall 2: Ignoring Context in Static Findings

**Mistake**: Treating all static findings as confirmed vulnerabilities without dynamic validation.

**Reality**: Static analysis often produces false positives. Dynamic validation is essential to confirm that a static finding is actually exploitable.

### Pitfall 3: Not Understanding Application Architecture

**Mistake**: Testing without understanding how the application is structured and how components interact.

**Reality**: Understanding the architecture helps identify likely vulnerability classes and testing approaches. It also helps correlate findings between static and dynamic analysis.

### Pitfall 4: Missing Business Logic Vulnerabilities

**Mistake**: Focusing only on technical vulnerabilities and ignoring business logic flaws.

**Reality**: Business logic vulnerabilities often have higher impact and are less likely to be found by automated tools. Understanding the application's business logic is essential for effective testing.

### Pitfall 5: Not Testing Edge Cases

**Mistake**: Only testing the "happy path" and not exploring edge cases.

**Reality**: Many vulnerabilities exist in error conditions, boundary cases, and unusual input scenarios. Always test with unexpected inputs and conditions.

### Pitfall 6: Failing to Document Methodology

**Mistake**: Not documenting the testing methodology and tools used.

**Reality**: Documenting methodology helps reproduce findings, provides context for remediation, and demonstrates thoroughness in security assessments.

### Pitfall 7: Ignoring Third-Party Components

**Mistake**: Only testing custom code and ignoring third-party libraries and frameworks.

**Reality**: Third-party components often contain known vulnerabilities. Always check for outdated or vulnerable dependencies.

---

## Tools and Resources

### Static Analysis Tools

**SonarQube**: Comprehensive code quality and security analysis platform.

**Semgrep**: Fast, open-source static analysis tool with custom rule support.

**CodeQL**: GitHub's semantic code analysis engine for finding vulnerabilities.

**Checkmarx**: Enterprise static application security testing (SAST) platform.

**Fortify**: Micro Focus static code analysis tool.

### Dynamic Analysis Tools

**Burp Suite**: Comprehensive web application security testing tool.

**OWASP ZAP**: Free and open-source web application security scanner.

**Nikto**: Web server scanner for dangerous files and outdated software.

**Nuclei**: Fast and customizable vulnerability scanner.

**Postman**: API development and testing tool.

### Hybrid Tools

**Snyk**: Developer-first security platform with SAST, SCA, and container scanning.

**Veracode**: Application security platform with static and dynamic analysis.

**Synopsys**: Comprehensive application security testing platform.

### Specialized Tools

**TruffleHog**: Secret scanning tool for Git repositories.

**GitLeaks**: Fast secret scanning tool.

**OWASP Dependency-Check**: Software composition analysis tool.

**Semgrep**: Custom rule support for language-specific vulnerability patterns.

### Learning Resources

**OWASP Testing Guide**: Comprehensive web application security testing methodology.

**PortSwigger Web Security Academy**: Free online web security training.

**SANS Secure Coding**: Secure coding practices and vulnerability prevention.

**NIST Static Analysis Guide**: Guidelines for static analysis tool usage.

---

## Quick Reference Cheat Sheet

### Static Analysis Checklist

- [ ] Locate and review source code
- [ ] Check third-party dependencies for vulnerabilities
- [ ] Scan for hardcoded secrets and credentials
- [ ] Review authentication and session management code
- [ ] Check for injection vulnerabilities (SQL, command, LDAP, etc.)
- [ ] Review cryptographic implementations
- [ ] Check for unsafe deserialization
- [ ] Review access control mechanisms
- [ ] Check for information disclosure in error messages
- [ ] Review file upload handling

### Dynamic Analysis Checklist

- [ ] Map application functionality and endpoints
- [ ] Test authentication mechanisms
- [ ] Test input validation for injection
- [ ] Test access control mechanisms
- [ ] Test for XSS vulnerabilities
- [ ] Test for SSRF vulnerabilities
- [ ] Test business logic
- [ ] Test file upload functionality
- [ ] Test API endpoints
- [ ] Document all findings

### Vulnerability Detection Patterns

| Vulnerability | Static Pattern | Dynamic Test |
|--------------|----------------|--------------|
| SQL Injection | String concatenation in queries | `' OR '1'='1` |
| XSS | innerHTML, document.write | `<script>alert(1)</script>` |
| SSRF | fetch, axios with user input | `http://127.0.0.1` |
| IDOR | Direct object references | Sequential IDs |
| CSRF | Missing token validation | Cross-origin form submission |
| Hardcoded Secrets | API keys in source | Use extracted keys |
| Command Injection | exec, system with user input | `; ls` |
| Path Traversal | File operations with user input | `../../../etc/passwd` |

### Common Source Code Patterns

**SQL Injection Risk**:
```python
# Dangerous
query = "SELECT * FROM users WHERE id = " + user_input

# Safe
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_input,))
```

**XSS Risk**:
```javascript
// Dangerous
element.innerHTML = userInput;

// Safe
element.textContent = userInput;
```

**Command Injection Risk**:
```python
# Dangerous
os.system("ping " + user_input)

# Safe
subprocess.run(["ping", user_input], check=True)
```

**Path Traversal Risk**:
```python
# Dangerous
open("/uploads/" + user_input)

# Safe
import os
open(os.path.join("/uploads", os.path.basename(user_input)))
```

### Testing Methodology Summary

1. **Static Analysis Phase**
   - Source code review
   - Dependency analysis
   - Secret scanning
   - Configuration review

2. **Dynamic Analysis Phase**
   - Application mapping
   - Authentication testing
   - Input validation testing
   - Access control testing

3. **Correlation Phase**
   - Map static findings to dynamic tests
   - Validate static findings dynamically
   - Develop exploits for confirmed vulnerabilities
   - Assess impact and remediation

### Tool Command Reference

```bash
# Static Analysis
sonar-scanner -Dsonar.projectKey=project -Dsonar.sources=src
semgrep --config=auto /path/to/source
codeql database create /path/to/codeql-db --language=javascript

# Dynamic Analysis
burpsuite  # GUI-based
zap-cli quick-scan https://target.com
nuclei -u https://target.com -t cves/

# Secret Scanning
trufflehog git https://github.com/org/repo
gitleaks detect --source /path/to/repo

# Dependency Checking
npm audit
pip-audit -r requirements.txt
composer audit
```

### Static and Dynamic Testing Integration Framework

#### Integrated Testing Workflow

The most effective security testing combines static and dynamic approaches in an integrated workflow:

**Phase 1: Initial Assessment**
1. Perform static analysis to understand codebase structure
2. Conduct dynamic testing to map application functionality
3. Correlate findings to identify high-risk areas

**Phase 2: Deep Testing**
1. Focus static analysis on code areas identified as potentially vulnerable
2. Perform targeted dynamic testing on corresponding functionality
3. Validate static findings through dynamic exploitation

**Phase 3: Comprehensive Validation**
1. Test for vulnerabilities that require both code and runtime context
2. Develop exploits using insights from both approaches
3. Document findings with both code-level and runtime evidence

#### Correlation Matrix

| Finding Type | Static Evidence | Dynamic Evidence | Combined Confidence |
|--------------|-----------------|------------------|---------------------|
| SQL Injection | String concatenation in query | Database error on input | High |
| XSS | innerHTML assignment | Script execution in browser | High |
| SSRF | fetch with user input | Internal network access | High |
| IDOR | Direct object reference | Unauthorized data access | High |
| Hardcoded Secret | API key in source | Valid API response | High |
| Command Injection | exec with user input | Command output in response | High |
| Path Traversal | File operations with input | Directory listing in response | High |

#### Validation Techniques

**Static Validation**:
- Code review to confirm vulnerability pattern
- Taint analysis to trace data flow
- Dependency analysis for known vulnerabilities
- Configuration review for security settings

**Dynamic Validation**:
- Functional testing to confirm vulnerability
- Exploitation to demonstrate impact
- Boundary testing to identify edge cases
- Regression testing to verify fix effectiveness

### Advanced Integration Techniques

#### Technique 1: Hybrid Analysis

Combine static and dynamic analysis for comprehensive coverage:

```bash
# Step 1: Static analysis to identify potential vulnerabilities
semgrep --config=auto /path/to/source > static_findings.txt

# Step 2: Dynamic testing to validate findings
while IFS= read -r finding; do
  # Extract endpoint and parameter from static finding
  endpoint=$(echo "$finding" | grep -oP 'https?://[^ ]+')
  # Perform dynamic testing
  curl "$endpoint" | grep -i "vulnerability_indicator"
done < static_findings.txt
```

#### Technique 2: Feedback Loop

Use findings from one approach to improve the other:

```bash
# Dynamic testing reveals new endpoints
# Add endpoints to static analysis targets
new_endpoints=$(curl -s https://target.com | grep -oP 'https?://[^ ]+' | sort -u)
echo "$new_endpoints" >> static_targets.txt

# Static analysis reveals code patterns
# Use patterns to guide dynamic testing
vulnerable_patterns=$(semgrep --config=auto /path/to/source | grep -oP 'pattern: [^ ]+')
echo "$vulnerable_patterns" >> dynamic_payloads.txt
```

#### Technique 3: Risk-Based Prioritization

Use combined findings to prioritize testing:

```bash
# Calculate risk score for each finding
# Risk = Likelihood × Impact
# Likelihood from static analysis (code complexity, user input)
# Impact from dynamic testing (data access, system access)

# Prioritize high-risk findings for immediate attention
# Document low-risk findings for future consideration
```

#### Technique 4: Continuous Testing Integration

Integrate static and dynamic testing into development workflows:

```bash
# Static analysis in CI/CD pipeline
semgrep --config=auto /path/to/source --error

# Dynamic testing in staging environment
zap-cli quick-scan https://staging.target.com

# Combined reporting for development team
# Generate unified report from both static and dynamic findings
```

### Testing Tool Configuration Guide

#### Static Analysis Tool Configuration

**Semgrep Configuration**:
```yaml
# .semgrep.yml
rules:
  - id: sql-injection
    pattern: |
      $QUERY = "..." + $INPUT + "..."
      $DB.execute($QUERY)
    message: "SQL injection vulnerability detected"
    severity: ERROR
    languages: [python]

  - id: xss-vulnerability
    pattern: |
      $ELEMENT.innerHTML = $INPUT
    message: "XSS vulnerability via innerHTML"
    severity: WARNING
    languages: [javascript]
```

**CodeQL Configuration**:
```ql
// codeql-query.ql
from Expr e, DatabaseAccess da
where e instanceof UserInput and da.getArgument(0) = e
select e, "User input flows to database query without sanitization"
```

#### Dynamic Analysis Tool Configuration

**Burp Suite Configuration**:
```
# Enable all scanning checks
# Configure target-specific settings
# Set up authentication macros
# Configure session handling rules
```

**OWASP ZAP Configuration**:
```bash
# Configure active scanning policy
zap-cli configure-scan --policy "Full Scan"

# Set up authentication
zap-cli authentication --method "form-based" --login-url "https://target.com/login" --username "user" --password "pass"

# Configure context
zap-cli context --name "Target Context" --include "https://target.com.*"
```

### Testing Metrics and Reporting

#### Key Performance Indicators

**Coverage Metrics**:
- Percentage of endpoints tested
- Percentage of code reviewed
- Percentage of vulnerability classes covered

**Quality Metrics**:
- False positive rate
- False negative rate
- Mean time to find vulnerabilities
- Mean time to exploit vulnerabilities

**Efficiency Metrics**:
- Vulnerabilities per hour of testing
- Cost per vulnerability found
- Time saved through automation

#### Reporting Templates

**Static Analysis Report**:
```markdown
# Static Analysis Report

## Executive Summary
[Brief overview of findings]

## Methodology
[Description of static analysis approach]

## Findings Summary
| Finding Type | Count | Severity |
|--------------|-------|----------|
| SQL Injection | 3 | High |
| XSS | 5 | Medium |
| Hardcoded Secrets | 2 | Critical |

## Detailed Findings
[Detailed description of each finding]

## Recommendations
[Remediation recommendations]
```

**Dynamic Analysis Report**:
```markdown
# Dynamic Analysis Report

## Executive Summary
[Brief overview of findings]

## Methodology
[Description of dynamic analysis approach]

## Test Coverage
[Description of endpoints and functionality tested]

## Findings Summary
| Finding Type | Count | Severity |
|--------------|-------|----------|
| Authentication Bypass | 1 | Critical |
| IDOR | 2 | High |
| CSRF | 3 | Medium |

## Detailed Findings
[Detailed description of each finding]

## Recommendations
[Remediation recommendations]
```

**Combined Report**:
```markdown
# Security Assessment Report

## Executive Summary
[Overview of combined findings]

## Methodology
[Description of integrated testing approach]

## Findings Summary
| Finding Type | Static | Dynamic | Combined | Severity |
|--------------|--------|---------|----------|----------|
| SQL Injection | ✓ | ✓ | ✓ | High |
| XSS | ✓ | ✓ | ✓ | Medium |
| IDOR | - | ✓ | ✓ | High |

## Detailed Findings
[Detailed description with both static and dynamic evidence]

## Risk Assessment
[Risk analysis based on combined findings]

## Recommendations
[Prioritized remediation recommendations]
```

### Common Integration Challenges

#### Challenge 1: Tool Compatibility

**Problem**: Static and dynamic analysis tools may not share data easily.

**Solution**: Use standardized formats (SARIF, JSON) for findings exchange. Implement custom scripts to correlate findings across tools.

#### Challenge 2: False Positive Correlation

**Problem**: Correlating false positives from different tools can be difficult.

**Solution**: Establish validation criteria for each finding type. Use manual review to confirm high-priority findings.

#### Challenge 3: Coverage Gaps

**Problem**: Some vulnerabilities may not be detected by either approach.

**Solution**: Supplement with manual testing, code review, and threat modeling. Use multiple tools and approaches for comprehensive coverage.

#### Challenge 4: Resource Constraints

**Problem**: Running both static and dynamic analysis requires time and resources.

**Solution**: Prioritize based on risk. Use automation where possible. Focus manual efforts on high-risk areas.

### Best Practices for Integrated Testing

1. **Start with Reconnaissance**: Use static analysis to understand the codebase before dynamic testing
2. **Correlate Findings**: Map static findings to dynamic test cases and vice versa
3. **Validate Everything**: Confirm static findings through dynamic exploitation
4. **Document Both Perspectives**: Include code-level and runtime evidence in reports
5. **Use Feedback Loops**: Let findings from one approach guide the other
6. **Prioritize by Risk**: Focus on high-risk findings that have both static and dynamic evidence
7. **Automate Where Possible**: Use automation for repetitive tasks and correlation
8. **Maintain Tool Proficiency**: Stay current with static and dynamic analysis tools
9. **Continuous Learning**: Keep up with new vulnerability classes and testing techniques
10. **Collaborate**: Share findings and techniques with the security community
