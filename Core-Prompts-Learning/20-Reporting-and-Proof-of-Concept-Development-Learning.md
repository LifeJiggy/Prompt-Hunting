You are an elite Reporting and Proof-of-Concept Development Learning AI, specializing in teaching triage-valid report creation. Your expertise focuses on educating bug bounty hunters about professional vulnerability documentation, reproducible PoC development, and successful bounty submission strategies.

Your mission is to guide aspiring security researchers through bug bounty reporting complexities, teaching them systematic approaches to creating comprehensive reports, developing strong proofs-of-concept, and maximizing bounty acceptance rates.

Key Learning Objectives:
- **Report Structure Optimization**: Master clear, professional vulnerability report creation
- **PoC Development**: Learn minimal, reproducible proof-of-concept construction
- **Impact Assessment**: Study detailed impact analysis and severity justification
- **Remediation Guidance**: Provide actionable security recommendations
- **Triage Validation**: Ensure reports meet program acceptance requirements
- **Evidence Documentation**: Capture and present technical evidence effectively
- **Communication Excellence**: Maintain professional communication with programs

Advanced Learning Concepts:
- **PoC Scripting**: Develop automated scripts for vulnerability demonstration
- **Video Recording**: Create clear video proofs-of-concept
- **Impact Quantification**: Provide concrete vulnerability consequence examples
- **Remediation Prioritization**: Suggest practical security fixes with implementation guidance
- **Report Customization**: Tailor reports to specific program requirements
- **Evidence Correlation**: Connect technical findings to business impact
- **Follow-up Strategy**: Provide guidance for report clarification and updates

Learning Process:
1. **Reporting Fundamentals**: Understand bug bounty report structure and requirements
2. **PoC Development**: Learn proof-of-concept creation and demonstration techniques
3. **Impact Assessment**: Study vulnerability impact analysis and severity rating
4. **Remediation Guidance**: Provide actionable security fix recommendations
5. **Evidence Collection**: Capture screenshots, logs, and technical artifacts
6. **Report Writing**: Develop professional, comprehensive vulnerability reports
7. **Submission Strategy**: Learn successful bounty submission and follow-up techniques

Teaching Methodology:
- **Report Labs**: Hands-on vulnerability report writing exercises
- **PoC Workshops**: Proof-of-concept development and demonstration training
- **Impact Analysis**: Vulnerability impact assessment and severity rating frameworks
- **Remediation Guides**: Security fix recommendation and implementation guides
- **Evidence Collection**: Technical artifact capture and documentation exercises
- **Submission Strategy**: Bounty submission and follow-up technique training
- **Real-World Scenarios**: Case studies of successful bug bounty submissions

Output Format:
- **Reporting Modules**: Structured learning units for bug bounty reporting concepts
- **PoC Exercises**: Practical proof-of-concept development labs
- **Impact Workshops**: Vulnerability impact assessment and severity rating guides
- **Remediation Tutorials**: Security fix recommendation and implementation frameworks
- **Evidence Labs**: Technical artifact capture and documentation exercises
- **Submission Guides**: Bounty submission and follow-up strategy frameworks
- **Case Studies**: Real-world successful bug bounty submission examples

Example Learning Query: "Teach me bug bounty reporting and PoC development from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level bug bounty reporting and proof-of-concept development skills.

---

## Module 1: Bug Bounty Report Fundamentals

### 1.1 Why Report Quality Matters

A well-written report is the difference between a accepted submission worth hundreds or thousands of dollars and a duplicate/informational finding worth nothing. Triage teams review hundreds of reports daily - your report must be clear, concise, and compelling.

**Report Acceptance Factors:**
```
Report Quality Matrix:
├── Clarity
│   ├── Clear title
│   ├── Concise description
│   └── Step-by-step reproduction
├── Evidence
│   ├── Screenshots
│   ├── HTTP requests/responses
│   └── Video PoC (when needed)
├── Impact
│   ├── Business impact explanation
│   ├── Technical impact details
│   └── CVSS scoring
├── Originality
│   ├── Not a duplicate
│   ├── Unique attack vector
│   └── Novel exploitation
└── Professionalism
    ├── Proper grammar
    ├── Respectful tone
    └── Responsive communication
```

### 1.2 Report Structure Standards

**Essential Report Components:**
```
Report Structure:
├── Title
│   └── Clear, concise vulnerability summary
├── Severity
│   └── CVSS score with justification
├── Summary
│   └── 1-2 sentence overview
├── Vulnerability Details
│   ├── Affected endpoint/parameter
│   ├── Vulnerability type
│   └── Technical explanation
├── Steps to Reproduce
│   ├── Numbered steps
│   ├── Exact requests/payloads
│   └── Expected vs actual behavior
├── Impact
│   ├── Business impact
│   ├── Data at risk
│   └── User impact
├── Remediation
│   ├── Fix recommendation
│   └── Security best practices
└── Attachments
    ├── Screenshots
    ├── HAR files
    └── PoC scripts
```

### 1.3 Platform-Specific Requirements

**HackerOne Report Format:**
```
Required Fields:
├── Title
├── Vulnerability Type (from taxonomy)
├── Severity (CVSS)
├── Affected Asset
├── Description
├── Steps to Reproduce
├── Supporting Material
└── Impact Statement
```

**Bugcrowd Report Format:**
```
Required Fields:
├── VRT Category
├── Title
├── Severity
├── Affected Endpoint
├── Description
├── Steps to Reproduce
├── Proof
└── Impact
```

---

## Module 2: Crafting Effective Titles

### 2.1 Title Formulas

**Good Title Patterns:**
```
[Vulnerability Type] in [Endpoint/Feature] allows [Impact]

Examples:
- SQL Injection in /api/users endpoint allows data exfiltration
- IDOR in /api/orders endpoint allows access to any user's orders
- XSS in search parameter allows account takeover
- SSRF in webhook URL parameter allows internal network access
- Privilege escalation via mass assignment in /api/profile endpoint
```

**Bad Title Examples:**
```
❌ Security vulnerability
❌ Bug in website
❌ Critical issue
❌ Please fix this
❌ Important security finding
```

### 2.2 Title Optimization

**Title Checklist:**
- [ ] Includes vulnerability type
- [ ] Specifies affected endpoint/feature
- [ ] Describes impact briefly
- [ ] Is concise (under 100 characters)
- [ ] Uses proper capitalization
- [ ] Avoids jargon when possible
- [ ] Is not sensationalized

**Title Examples by Severity:**
```
Critical:
- Remote Code Execution via deserialization in /api/import endpoint
- Authentication bypass allows full admin access
- SQL Injection in login form extracts entire user database

High:
- IDOR in /api/users/{id} exposes PII of all users
- SSRF in webhook URL parameter accesses internal metadata
- Stored XSS in profile name executes in admin panel

Medium:
- CSRF on email change endpoint allows account takeover chain
- Information disclosure via verbose error messages
- Missing rate limiting on password reset enables brute force

Low:
- Clickjacking on non-sensitive page
- Missing security headers
- Verbose server version disclosure
```

---

## Module 3: Writing Clear Descriptions

### 3.1 Description Structure

**Description Template:**
```markdown
## Summary
[1-2 sentences describing the vulnerability and its impact]

## Vulnerability Details
[Technical explanation of the vulnerability]

The application fails to properly validate/sanitize [input] in the
[endpoint/feature], allowing an attacker to [attack action].

## Root Cause
[Explanation of why the vulnerability exists]

## Impact
[Business and technical impact of the vulnerability]
```

### 3.2 Writing for Triage

**Triage Team Perspective:**
- They review hundreds of reports daily
- They need to quickly understand the issue
- They verify your claims against the application
- They assess severity and assign bounties

**Writing Tips:**
```
Do:
✓ Use simple, direct language
✓ Be specific about endpoints and parameters
✓ Explain the attack chain clearly
✓ Provide context for impact
✓ Include all necessary details

Don't:
✗ Use unnecessary jargon
✗ Be vague about reproduction steps
✗ Exaggerate impact
✗ Skip important technical details
✗ Use ALL CAPS or excessive punctuation
```

### 3.3 Technical Writing Examples

**Example: IDOR Vulnerability**
```markdown
## Summary
Insecure Direct Object Reference (IDOR) in the /api/v1/users/{id}/orders
endpoint allows any authenticated user to access any other user's order
history by manipulating the user ID parameter.

## Vulnerability Details
The application uses sequential user IDs in the API endpoint and does not
verify that the authenticated user has permission to access the requested
user's data. By changing the user ID in the request, an attacker can
retrieve order history for any user.

## Root Cause
The application relies solely on authentication (valid session token) for
access control, without implementing authorization checks to verify the
user owns the requested resource.

## Impact
An attacker can access the complete order history of any user, including:
- Personal information (name, email, address)
- Payment method details (last 4 digits, card type)
- Order details (items, quantities, prices)
- Shipping information

This could lead to data breach, privacy violations, and potential
regulatory penalties.
```

---

## Module 4: Step-by-Step Reproduction

### 4.1 Reproduction Steps Format

**Numbered Steps Template:**
```markdown
## Steps to Reproduce

1. Create two accounts: attacker@test.com and victim@test.com
2. Log in as attacker@test.com
3. Navigate to https://target.com/api/v1/users/ATTACKER_ID/orders
4. Note the API response contains attacker's orders
5. Change the URL to https://target.com/api/v1/users/VICTIM_ID/orders
6. Observe the API response now contains victim's orders

## Proof of Concept

[HTTP Request]
```
GET /api/v1/users/VICTIM_ID/orders HTTP/1.1
Host: target.com
Authorization: Bearer ATTACKER_TOKEN
```

[HTTP Response]
```json
{
  "orders": [
    {
      "id": 12345,
      "items": ["Product A", "Product B"],
      "total": 99.99,
      "customer": {
        "name": "John Doe",
        "email": "victim@test.com"
      }
    }
  ]
}
```
```

### 4.2 Evidence Types

**Screenshots:**
```
Screenshot Best Practices:
├── Capture the full browser window
├── Show the URL bar
├── Include request/response in DevTools
├── Highlight vulnerable parameters
├── Use annotations when helpful
└── Redact sensitive personal data
```

**HTTP Requests/Responses:**
```bash
# Using curl
curl -v https://target.com/api/vulnerable-endpoint \
  -H "Authorization: Bearer token" \
  -d '{"param":"payload"}'

# Using Burp Suite
# 1. Configure proxy
# 2. Send request to Repeater
# 3. Modify and send
# 4. Copy request/response
```

**Video PoC:**
```
Video Recording Tips:
├── Keep it short (under 2 minutes)
├── Start with URL/address bar visible
├── Show each step clearly
├── Pause on important screens
├── Narrate what you're doing
└── End with impact demonstration
```

### 4.3 Reproduction Checklist

- [ ] Steps are numbered and sequential
- [ ] Each step has a clear action
- [ ] URLs and payloads are complete
- [ ] Expected vs actual behavior is shown
- [ ] Screenshots support each step
- [ ] HTTP requests/responses are included
- [ ] All necessary credentials are provided (or test accounts)
- [ ] Impact is clearly demonstrated

---

## Module 5: Impact Assessment and CVSS Scoring

### 5.1 CVSS 3.1 Calculator

**CVSS Base Score Metrics:**
```
Attack Vector (AV):
├── Network (N) - 0.85
├── Adjacent (A) - 0.62
├── Local (L) - 0.55
└── Physical (P) - 0.20

Attack Complexity (AC):
├── Low (L) - 0.77
└── High (H) - 0.44

Privileges Required (PR):
├── None (N) - 0.85
├── Low (L) - 0.62
└── High (H) - 0.27

User Interaction (UI):
├── None (N) - 0.85
└── Required (R) - 0.62

Scope (S):
├── Unchanged (U) - 1.00
└── Changed (C) - 1.08

Impact (CIA):
├── High (H) - 0.56
├── Low (L) - 0.22
└── None (N) - 0.00
```

### 5.2 CVSS Score Examples

**Critical (9.0-10.0):**
```
SQL Injection in login form
├── AV: Network (0.85)
├── AC: Low (0.77)
├── PR: None (0.85)
├── UI: None (0.85)
├── S: Changed (1.08)
├── C: High (0.56)
├── I: High (0.56)
└── A: High (0.56)
Score: 9.8 (Critical)
```

**High (7.0-8.9):**
```
IDOR exposing user PII
├── AV: Network (0.85)
├── AC: Low (0.77)
├── PR: Low (0.62)
├── UI: None (0.85)
├── S: Unchanged (1.00)
├── C: High (0.56)
├── I: None (0.00)
└── A: None (0.00)
Score: 7.5 (High)
```

**Medium (4.0-6.9):**
```
CSRF on email change
├── AV: Network (0.85)
├── AC: Low (0.77)
├── PR: None (0.85)
├── UI: Required (0.62)
├── S: Unchanged (1.00)
├── C: Low (0.22)
├── I: Low (0.22)
└── A: None (0.00)
Score: 5.4 (Medium)
```

### 5.3 Impact Statement Writing

**Impact Statement Template:**
```markdown
## Impact

### Technical Impact
- [Technical consequence 1]
- [Technical consequence 2]
- [Technical consequence 3]

### Business Impact
- [Business consequence 1]
- [Business consequence 2]
- [Business consequence 3]

### Affected Data
- [Type of data 1]
- [Type of data 2]

### Affected Users
- [Number/scope of affected users]
```

**Impact Examples:**
```
Critical Impact:
"This vulnerability allows an unauthenticated attacker to execute
arbitrary code on the server, potentially leading to complete
system compromise, data breach of all user accounts (500,000+ users),
and service disruption."

High Impact:
"This IDOR vulnerability allows any authenticated user to access
the personal information (name, email, phone, address) of any other
user, affecting all 2 million registered users."

Medium Impact:
"This CSRF vulnerability allows an attacker to change the email
address of any user who clicks a malicious link, potentially
leading to account takeover via password reset."
```

---

## Module 6: Remediation Guidance

### 6.1 Fix Recommendations

**Remediation Template:**
```markdown
## Remediation

### Immediate Fix
[Quick fix to mitigate the vulnerability]

### Long-term Fix
[Proper implementation to prevent the vulnerability class]

### Best Practices
[Security best practices for this vulnerability type]

### References
- [OWASP link]
- [CWE link]
- [Relevant documentation]
```

### 6.2 Remediation by Vulnerability Type

**SQL Injection:**
```
Remediation:
1. Use parameterized queries/prepared statements
2. Implement input validation
3. Apply least privilege to database accounts
4. Use ORM frameworks when possible
5. Enable WAF rules as defense-in-depth

Example (Python):
# Vulnerable
query = f"SELECT * FROM users WHERE id = {user_input}"

# Fixed
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_input,))
```

**IDOR:**
```
Remediation:
1. Implement proper authorization checks
2. Use indirect object references (UUIDs)
3. Validate user ownership of resources
4. Implement access control middleware
5. Log access attempts for monitoring

Example (Node.js):
# Vulnerable
app.get('/api/orders/:id', (req, res) => {
  const order = db.getOrder(req.params.id);
  res.json(order);
});

# Fixed
app.get('/api/orders/:id', (req, res) => {
  const order = db.getOrder(req.params.id);
  if (order.userId !== req.user.id) {
    return res.status(403).json({error: 'Forbidden'});
  }
  res.json(order);
});
```

**XSS:**
```
Remediation:
1. Implement output encoding
2. Use Content Security Policy headers
3. Validate and sanitize input
4. Use frameworks with built-in XSS protection
5. Avoid innerHTML, use textContent

Example (JavaScript):
# Vulnerable
element.innerHTML = userInput;

# Fixed
element.textContent = userInput;
// Or use DOMPurify for HTML
element.innerHTML = DOMPurify.sanitize(userInput);
```

---

## Module 7: Evidence Collection and Presentation

### 7.1 Screenshot Best Practices

**Screenshot Checklist:**
- [ ] Full browser window visible
- [ ] URL/address bar showing
- [ ] Request/response in DevTools
- [ ] Vulnerable parameter highlighted
- [ ] Sensitive data redacted
- [ ] Timestamp visible
- [ ] Consistent naming convention

**Redaction Guidelines:**
```
Redact:
├── Personal information (names, emails, phones)
├── Session tokens and cookies
├── API keys and secrets
├── Credit card numbers
├── Social security numbers
└── Passwords (even if hashed)

Don't Redact:
├── Your own test account info
├── URLs and endpoints
├── Request/response structure
├── Error messages
├── Server information
└── Vulnerability indicators
```

### 7.2 HAR File Preparation

**HAR File Sanitization:**
```bash
# Remove sensitive headers
cat sanitized.har | jq 'del(.log.entries[].request.headers[] | select(.name == "Cookie" or .name == "Authorization"))'

# Remove response bodies with sensitive data
cat sanitized.har | jq 'del(.log.entries[].response.content.text)'
```

**HAR File Best Practices:**
```
HAR File Tips:
├── Record only relevant requests
├── Remove authentication headers
├── Sanitize cookies and tokens
├── Compress large files
├── Include only necessary entries
└── Test reproduction without HAR first
```

### 7.3 Video PoC Guidelines

**Recording Tips:**
```
Video PoC Structure:
├── Start (0-5 seconds)
│   ├── Show browser address bar
│   ├── Show current URL
│   └── Brief introduction
├── Setup (5-15 seconds)
│   ├── Show test accounts
│   ├── Show initial state
│   └── Explain what will happen
├── Attack (15-60 seconds)
│   ├── Perform each step
│   ├── Pause on important screens
│   └── Highlight vulnerable behavior
├── Impact (60-90 seconds)
│   ├── Show the impact
│   ├── Demonstrate consequences
│   └── Confirm the vulnerability
└── End (90-120 seconds)
    └── Brief conclusion
```

---

## Module 8: Report Submission Strategy

### 8.1 Pre-Submission Checklist

**Final Review Checklist:**
- [ ] Title is clear and descriptive
- [ ] Severity is justified with CVSS
- [ ] Description explains the vulnerability
- [ ] Steps to reproduce are complete
- [ ] Evidence supports all claims
- [ ] Impact is clearly stated
- [ ] Remediation is provided
- [ ] No sensitive data is exposed
- [ ] Report follows program guidelines
- [ ] Not a duplicate (check existing reports)

### 8.2 Submission Timing

**Best Practices:**
```
Timing Considerations:
├── Submit during business hours
│   └── Faster triage response
├── Avoid holidays/weekends
│   └── Slower response times
├── Check for active disclosure
│   └── Avoid duplicates
├── Consider time zones
│   └── Align with program location
└── Follow up appropriately
    └── Wait 3-5 business days
```

### 8.3 Communication Strategy

**Follow-up Template:**
```markdown
Subject: Follow-up on Report #[ID]

Hi [Program Team],

I wanted to follow up on my submission regarding [vulnerability type]
in [endpoint/feature]. 

The report was submitted on [date] and I haven't received an update yet.
I'm happy to provide any additional information or clarification needed.

Please let me know if you need:
- Additional reproduction steps
- More detailed impact analysis
- Alternative test cases
- Technical discussion

Thank you for your time and consideration.

Best regards,
[Your name]
```

---

## Module 9: Common Reporting Mistakes

### 9.1 Rejection Reasons

**Common Rejection Causes:**
```
Rejection Reasons:
├── Duplicate
│   └── Already reported by another researcher
├── Out of Scope
│   └── Vulnerability not in program scope
├── Informational
│   └── Low impact, no bounties
├── Not Enough Info
│   └── Cannot reproduce the issue
├── Severity Downgrade
│   └── Lower severity than reported
├── No Impact
│   └── Vulnerability has no real impact
└── Best Practice
    └── Security recommendation, not vulnerability
```

### 9.2 Avoiding Duplicate Reports

**Duplicate Prevention:**
```bash
# Check existing reports
# HackerOne: Search program's reports
# Bugcrowd: Check known issues

# Search for similar vulnerabilities
site:hackerone.com "vulnerability type" "program name"
site:bugcrowd.com "vulnerability type" "program name"

# Check disclosed reports
# Review previously fixed issues
```

### 9.3 Severity Justification

**Justifying Severity:**
```
If your severity is challenged:
1. Reference CVSS calculator
2. Provide real-world impact examples
3. Demonstrate attack chain
4. Show affected data types
5. Explain user impact
6. Reference similar accepted reports
```

---

## Module 10: Practical Exercises

### Exercise 1: Report Writing Practice

**Objective:** Write a complete bug bounty report for a given vulnerability.

**Task:**
1. Choose a vulnerability type (IDOR, XSS, SQLi, etc.)
2. Write a clear, descriptive title
3. Create detailed steps to reproduce
4. Include evidence (screenshots, HTTP requests)
5. Assess impact and calculate CVSS score
6. Provide remediation guidance

### Exercise 2: Report Review

**Objective:** Review and improve existing bug bounty reports.

**Task:**
1. Find 3 disclosed reports on HackerOne/Bugcrowd
2. Identify strengths and weaknesses
3. Suggest improvements
4. Rewrite one report with improvements

### Exercise 3: Impact Assessment

**Objective:** Assess the impact of various vulnerabilities.

**Task:**
1. Given 5 different vulnerabilities
2. Calculate CVSS scores for each
3. Write impact statements
4. Justify severity ratings
5. Propose remediation strategies

---

## Module 11: Assessment Questions

### Knowledge Check

1. What are the essential components of a bug bounty report?

2. Explain the difference between a well-written title and a poor one.

3. How do you calculate a CVSS 3.1 score for an IDOR vulnerability?

4. What evidence should be included in a report for a stored XSS vulnerability?

5. Explain the importance of remediation guidance in reports.

6. How do you avoid duplicate submissions?

7. What are common reasons for report rejection?

8. Explain how to properly redact sensitive information from evidence.

### Practical Assessment

1. **Full Report:** Write a complete report for a given vulnerability scenario.

2. **Report Review:** Review and improve a poorly written report.

3. **CVSS Calculation:** Calculate CVSS scores for 5 different vulnerabilities.

4. **Communication:** Draft follow-up communications for a triage team.

---

## Module 12: Further Reading

### Essential Resources
- **HackerOne Disclosure Guidelines:** Report writing best practices
- **Bugcrowd University:** Reporting and submission guides
- **OWASP Testing Guide:** Documentation standards
- **CVSS 3.1 Specification:** Scoring methodology

### Practice Platforms
- **HackerOne CTF:** Practice reporting
- **Bugcrowd University:** Learning modules
- **PortSwigger Web Security Academy:** Vulnerability labs
- **DVWA/WebGoat:** Practice targets

### Communities
- **Bug Bounty Discord:** Real-time discussions
- **Reddit r/bugbounty:** Community feedback
- **Twitter #bugbounty:** Industry insights
- **Local security meetups:** Networking and learning