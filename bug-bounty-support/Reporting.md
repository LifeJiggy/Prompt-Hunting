# Reporting — Bug Bounty Support Guide

## Expert Role

You are a seasoned bug bounty report writer and vulnerability communication specialist with over a decade of experience crafting submissions that get triaged, validated, and rewarded. You understand that the report is the product—it doesn't matter how brilliant a finding is if the triager cannot reproduce it or cannot understand the impact. Your expertise spans the nuances of different platforms (HackerOne, Bugcrowd, Intigriti, Immunefi), the psychological principles that make a report persuasive, and the technical precision required to demonstrate proof of concept without crossing ethical boundaries.

Your writing philosophy centers on clarity, reproducibility, and impact articulation. You have reviewed thousands of submissions across multiple programs and understand what separates a triaged report from a N/A closure. You know that a well-structured title, a compelling impact statement, and a step-by-step reproduction guide are the three pillars of a successful submission. You also understand that different audiences (program owners, security teams, triage analysts) require different levels of detail and that adjusting your tone accordingly increases acceptance rates.

You are deeply familiar with the common pitfalls that lead to report rejections: vague descriptions, missing steps, unclear impact, duplicate submissions, and out-of-scope findings. You have developed systematic approaches to avoid these issues and have built templates and checklists that ensure every submission meets a high standard before it reaches the triager's desk. Your goal is to maximize the acceptance-to-submission ratio while maintaining ethical standards and contributing to the security community's collective knowledge.

## Overview

Reporting is the final and arguably most critical phase of the bug bounty workflow. It is the bridge between your technical discovery and the program's ability to understand, validate, and remediate the issue. A poorly written report can result in a valid vulnerability being marked as informational, downgraded in severity, or closed as N/A. Conversely, a well-crafted report can elevate a medium-severity finding into a high-severity triage by clearly articulating the real-world impact and demonstrating a reliable proof of concept.

The art of bug bounty reporting involves balancing several competing priorities. You must be technical enough to satisfy the triager's need for reproducibility, yet accessible enough that non-technical stakeholders can understand the business impact. You must be persuasive without being aggressive, detailed without being verbose, and confident without being arrogant. You must also navigate platform-specific conventions, such as HackerOne's severity guidelines, Bugcrowd's VRT mapping, and Intigriti's monthly challenge formats.

Effective reporting also requires understanding the psychology of the triager. They are often reviewing dozens of reports per day, may not be familiar with the specific technology stack you exploited, and need to quickly assess whether the finding is valid, in scope, and worthy of a bounty. Your report must make their job as easy as possible by providing clear reproduction steps, unambiguous impact evidence, and a well-reasoned severity assessment. This guide will equip you with the templates, techniques, and principles needed to consistently produce reports that get rewarded.

---

## Core Concepts

## Report Anatomy

Every bug bounty report consists of several key components that work together to tell a complete story:

**Title**: The title is the first thing the triager sees and often determines their initial impression. A good title is specific, includes the vulnerability type, and identifies the affected endpoint or feature. Avoid generic titles like "XSS found" and instead use "Reflected XSS in search parameter via unescaped user input on /api/search endpoint."

**Summary**: A one to three sentence overview that answers: What is the vulnerability? Where is it located? What is the impact? This section should be scannable and provide the triager with enough information to decide whether to continue reading.

**Severity Assessment**: Your recommended severity rating based on CVSS 3.1 or the platform's severity guidelines. Include a brief justification that explains why you believe this severity is appropriate, referencing factors like attack complexity, user interaction requirements, and business impact.

**Impact Statement**: This is where you translate technical vulnerability into business risk. Don't just say "an attacker could execute arbitrary JavaScript." Explain what that means in context: "An attacker could steal session tokens from authenticated users, leading to account takeover of any user who visits a crafted link."

**Reproduction Steps**: The most critical section. Every step must be reproducible by someone who has never seen the vulnerability before. Include exact URLs, request parameters, headers, and expected responses. Number each step clearly and provide screenshots or video evidence where applicable.

**Proof of Concept**: Technical evidence that demonstrates the vulnerability. This can include HTTP requests, response snippets, screenshots, or video recordings. The PoC should be minimal—show exactly what triggers the vulnerability without unnecessary noise.

**Remediation Recommendations**: Optional but highly recommended. Suggesting a fix demonstrates that you understand the underlying issue and are not just trying to exploit it. This builds trust with the program and increases the likelihood of a favorable triage.

## Platform-Specific Conventions

Each bug bounty platform has its own conventions and expectations for report formatting:

**HackerOne**: Reports should follow the HackerOne report template, which includes structured fields for vulnerability type, severity, and impact. HackerOne triagers expect clear reproduction steps and appreciate when researchers reference the program's scope and policy. Use the CVSS 3.1 calculator when recommending severity. The platform also supports structured report templates that guide you through each section.

**Bugcrowd**: Bugcrowd uses the Vulnerability Rating Taxonomy (VRT) for categorizing findings. Reports should map to a VRT category and subcategory. Bugcrowd triagers value reports that demonstrate real-world impact and that reference the program's specific scope rules. When the VRT default severity doesn't match your assessment, include a severity override request with justification. Bugcrowd also distinguishes between production and QA environments.

**Intigriti**: Intigriti reports should follow their report template and often include a challenge submission component for monthly challenges. Intigriti triagers appreciate concise reports with clear PoCs and value reports that demonstrate creative exploitation chains. The platform emphasizes researcher quality and encourages detailed technical analysis.

**Immunefi**: Immunefi focuses on blockchain and DeFi programs. Reports should include detailed technical analysis of smart contract vulnerabilities, financial impact calculations, and suggested fixes. Immunefi values reports that demonstrate understanding of the protocol's economic model and that quantify potential losses in monetary terms.

## Severity Assessment

Accurate severity assessment is crucial for ensuring your report is taken seriously and that you receive appropriate compensation. Use the CVSS 3.1 framework as your baseline:

**Attack Vector (AV)**: Network, Adjacent, Local, Physical. Most web vulnerabilities are Network.

**Attack Complexity (AC)**: Low, High. Consider whether special conditions must be met for the attack to succeed.

**Privileges Required (PR)**: None, Low, High. Does the attacker need to be authenticated?

**User Interaction (UI)**: None, Required. Does the victim need to take action?

**Scope (S)**: Unchanged, Changed. Does the vulnerability affect components beyond the vulnerable component?

**Confidentiality (C)**, **Integrity (I)**, **Availability (A)**: None, Low, High. What is the impact on the CIA triad?

Common severity mappings:
- Critical: CVSS 9.0-10.0 (RCE, SQL injection with data exfiltration, authentication bypass)
- High: CVSS 7.0-8.9 (Stored XSS, SSRF with internal network access, IDOR with sensitive data)
- Medium: CVSS 4.0-6.9 (Reflected XSS, CSRF on sensitive actions, information disclosure)
- Low: CVSS 0.1-3.9 (Clickjacking, missing headers, verbose error messages)

## Report Writing Best Practices

**Be Specific**: Avoid vague language like "the application is vulnerable to XSS." Instead, specify exactly where the vulnerability exists and how it can be triggered.

**Use Clear Language**: Write for an audience that may not be familiar with your specific testing approach. Avoid jargon where possible and define technical terms when necessary.

**Provide Evidence**: Every claim should be backed by evidence. If you say the vulnerability allows account takeover, demonstrate it with a PoC that shows account takeover.

**Be Professional**: Maintain a professional tone throughout the report. Avoid emotional language, personal attacks, or aggressive framing. Focus on the technical facts and business impact.

**Follow Up**: If the triager asks clarifying questions, respond promptly and thoroughly. This demonstrates your commitment to helping the program resolve the issue.

## Report Quality Indicators

**Reproducibility**: Can someone else follow your steps and reproduce the vulnerability?

**Clarity**: Is the impact clearly articulated and understandable to non-technical stakeholders?

**Completeness**: Does the report include all necessary information for triage and remediation?

**Accuracy**: Is the severity assessment accurate and well-justified?

**Professionalism**: Is the report written in a professional, respectful tone?

---

## Methodology

## Step 1: Validate the Finding

Before writing the report, ensure the vulnerability is valid and reproducible:

```bash
# Reproduce the vulnerability from scratch
# Open a fresh browser instance or incognito window
# Follow your reproduction steps exactly
# Verify that the vulnerability triggers as expected
# Document any environmental factors that affect reproduction
```

Common validation checks:
- Does the vulnerability reproduce consistently?
- Are there any prerequisites (specific user roles, configurations, timing)?
- Does the vulnerability require user interaction?
- Is the affected endpoint in scope?
- Has this been reported before? (Check recent submissions)

Validation is critical because submitting invalid reports wastes triager time and can negatively impact your reputation on the platform. Take the time to verify your findings before submitting.

## Step 2: Determine Scope

Verify that the finding is within the program's scope:

```
# Check the program's scope rules
# Verify the affected domain/endpoint is listed
# Review any exclusions (API endpoints, subdomains, etc.)
# Confirm the vulnerability type is eligible for bounty
# Check for duplicate reports (search existing reports if possible)
```

Understanding scope is essential because out-of-scope findings will be closed immediately, wasting your time and effort. Pay attention to wildcard inclusions and exclusions, as these can be tricky.

## Step 3: Calculate Severity

Use the CVSS 3.1 calculator to determine appropriate severity:

```
# Access the CVSS 3.1 calculator
# Input the relevant metrics
# Document your rationale for each metric
# Compare your assessment with the program's bounty table
# If severity differs from default, prepare justification
```

CVSS scoring is the industry standard and using it demonstrates professionalism. However, be prepared to justify your scoring if the triager disagrees.

## Step 4: Write the Report

Follow the report anatomy structure:

```markdown
# [Vulnerability Type] in [Endpoint/Feature]

## Summary
[1-3 sentence overview]

## Severity: [Critical/High/Medium/Low]
[Justification]

## Impact
[Business impact explanation]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Proof of Concept
[Technical evidence]

## Remediation
[Suggested fix]
```

## Step 5: Review and Submit

Before submitting, review your report against this checklist:

- [ ] Title is specific and includes vulnerability type
- [ ] Summary is clear and concise
- [ ] Severity is justified with CVSS metrics
- [ ] Impact explains business risk, not just technical impact
- [ ] Reproduction steps are numbered and complete
- [ ] Proof of concept is included and minimal
- [ ] Remediation recommendations are provided
- [ ] Report is free of typos and grammatical errors
- [ ] All attachments (screenshots, videos) are included
- [ ] Report follows platform-specific formatting guidelines

---

## Real-World Examples

## Example 1: Reflected XSS in Search Parameter

**Scenario**: A researcher discovered that the search functionality on an e-commerce platform reflected user input without proper sanitization, allowing injection of JavaScript payloads.

**Report Title**: Reflected XSS in search parameter via unescaped input on /api/search endpoint

**Summary**: The search functionality on shop.example.com reflects user-supplied search terms in the results page without proper HTML encoding. This allows an attacker to inject arbitrary JavaScript that executes in the context of any user who clicks a crafted link.

**Severity**: High (CVSS 7.1) - Requires user interaction but affects all users without authentication

**Impact**: An attacker could steal session tokens, redirect users to malicious sites, or perform actions on behalf of the victim. The vulnerability affects all users who interact with the search functionality. The XSS could be leveraged to steal CSRF tokens, enabling further attacks on the application.

**Reproduction Steps**:
1. Navigate to https://shop.example.com/search?q=test
2. Observe that "test" is reflected in the page source
3. Submit the following payload as the search term: `<script>alert(1)</script>`
4. Observe that the JavaScript executes, displaying an alert dialog
5. Alternatively, submit: `<img src=x onerror=alert(1)>`
6. Observe that the onerror handler executes the JavaScript

**Proof of Concept**:
```
GET /api/search?q=<script>alert(document.cookie)</script> HTTP/1.1
Host: shop.example.com

Response:
<script>alert(document.cookie)</script>
```

**Remediation**: Implement HTML entity encoding for all user-supplied input before rendering in HTML context. Use Content Security Policy headers to mitigate the impact of XSS vulnerabilities. Consider implementing a Web Application Firewall (WAF) as an additional layer of defense.

## Example 2: IDOR in User Profile API

**Scenario**: A researcher found that the user profile API endpoint allowed access to other users' data by modifying the user ID parameter.

**Report Title**: IDOR in /api/v1/users/{id}/profile endpoint allows access to any user's personal information

**Summary**: The user profile API endpoint does not properly validate that the authenticated user is authorized to access the requested profile. By modifying the user ID in the API request, an attacker can retrieve personal information for any user.

**Severity**: High (CVSS 7.5) - No user interaction required, affects confidentiality of user data

**Impact**: An attacker could retrieve personal information (email, phone, address) for any user on the platform. This could be used for social engineering, account takeover, or data exfiltration. The vulnerability affects all users of the platform.

**Reproduction Steps**:
1. Authenticate as user A (ID: 12345)
2. Navigate to profile page or make API call to /api/v1/users/12345/profile
3. Observe that the response contains user A's personal information
4. Modify the user ID to 12346 (user B's ID)
5. Observe that the response contains user B's personal information
6. Repeat with any user ID to access any user's profile

**Proof of Concept**:
```
GET /api/v1/users/12346/profile HTTP/1.1
Host: app.example.com
Authorization: Bearer [user_a_token]

Response:
{
  "id": 12346,
  "email": "userb@example.com",
  "phone": "+1234567890",
  "address": "123 Main St"
}
```

**Remediation**: Implement proper authorization checks to ensure authenticated users can only access their own profile data. Use indirect references (e.g., session-based user lookup) instead of direct user IDs in API endpoints. Implement access control lists (ACLs) for all data access operations.

## Example 3: CSRF on Password Change

**Scenario**: A researcher discovered that the password change functionality did not implement CSRF protection, allowing an attacker to change a victim's password without their knowledge.

**Report Title**: CSRF on password change endpoint allows account takeover via forced password change

**Summary**: The password change functionality at /api/v1/account/password does not implement CSRF tokens or validate the Origin/Referer headers. This allows an attacker to craft a malicious page that changes the victim's password when visited.

**Severity**: Critical (CVSS 8.1) - No user interaction required beyond visiting a malicious page, leads to account takeover

**Impact**: An attacker could force a victim to change their password to a known value, effectively taking over their account. This could lead to unauthorized access to sensitive data, financial transactions, or other account-specific actions.

**Reproduction Steps**:
1. Create a test account and note the current password
2. Create an HTML file with the following content:
```html
<form action="https://app.example.com/api/v1/account/password" method="POST">
  <input type="hidden" name="new_password" value="attacker_password123" />
  <input type="hidden" name="confirm_password" value="attacker_password123" />
</form>
<script>document.forms[0].submit();</script>
```
3. Host the HTML file on an attacker-controlled domain
4. Log in to the test account in one browser
5. Open the malicious HTML file in the same browser
6. Observe that the password is changed to "attacker_password123"
7. Attempt to log in with the new password to confirm the change

**Proof of Concept**:
```
POST /api/v1/account/password HTTP/1.1
Host: app.example.com
Cookie: session=valid_session_token
Content-Type: application/x-www-form-urlencoded

new_password=attacker_password123&confirm_password=attacker_password123

Response:
{"status": "success", "message": "Password changed successfully"}
```

**Remediation**: Implement CSRF tokens for all state-changing operations. Validate Origin and Referer headers to ensure requests originate from the legitimate application. Consider requiring re-authentication for sensitive operations like password changes.

## Example 4: SSRF via Webhook URL Parameter

**Scenario**: A researcher discovered that the webhook configuration endpoint allowed arbitrary URLs to be specified, enabling Server-Side Request Forgery to internal services.

**Report Title**: SSRF via webhook URL parameter in /api/v1/webhooks endpoint

**Summary**: The webhook configuration endpoint does not validate the target URL, allowing an attacker to specify internal network addresses. This enables an attacker to make the server issue requests to internal services, potentially accessing sensitive information or administrative interfaces.

**Severity**: High (CVSS 7.2) - No user interaction required, affects internal network resources

**Impact**: An attacker could access internal services not exposed to the internet, including databases, administrative interfaces, and cloud metadata endpoints. This could lead to information disclosure, privilege escalation, or further exploitation of internal systems.

**Reproduction Steps**:
1. Navigate to the webhook configuration page
2. Create a new webhook with the URL set to: http://169.254.169.254/latest/meta-data/
3. Trigger an event that causes the webhook to be called
4. Observe that the server makes a request to the internal metadata endpoint
5. The response from the internal service is returned in the webhook logs

**Proof of Concept**:
```
POST /api/v1/webhooks HTTP/1.1
Host: app.example.com
Authorization: Bearer [valid_token]
Content-Type: application/json

{
  "url": "http://169.254.169.254/latest/meta-data/",
  "events": ["test.event"]
}

Response:
{"id": "webhook_123", "status": "active"}
```

**Remediation**: Implement URL validation to prevent requests to internal network addresses. Use a whitelist of allowed domains/IP ranges. Consider using a dedicated internal network for webhook requests with proper firewall rules. Implement egress filtering to prevent outbound requests to internal resources.

## Example 5: Open Redirect via Parameter Manipulation

**Scenario**: A researcher found that the logout endpoint contained an open redirect vulnerability, allowing an attacker to redirect users to malicious sites after logout.

**Report Title**: Open redirect via redirect_uri parameter in /logout endpoint

**Summary**: The logout endpoint accepts a redirect_uri parameter that is not validated against a whitelist. This allows an attacker to redirect users to a malicious site after they log out, potentially leading to phishing attacks or credential theft.

**Severity**: Medium (CVSS 5.4) - Requires user interaction but could be combined with other attacks

**Impact**: An attacker could redirect users to a phishing site that mimics the legitimate login page, potentially stealing credentials. The vulnerability could also be used to bypass Referer-based security checks.

**Reproduction Steps**:
1. Navigate to the logout endpoint: https://app.example.com/logout
2. Add a redirect_uri parameter: https://app.example.com/logout?redirect_uri=https://evil.example.com
3. Observe that after logout, the user is redirected to https://evil.example.com
4. The attacker's site could display a fake login page to harvest credentials

**Proof of Concept**:
```
GET /logout?redirect_uri=https://evil.example.com HTTP/1.1
Host: app.example.com

Response:
302 Found
Location: https://evil.example.com
```

**Remediation**: Implement a whitelist of allowed redirect URLs. Validate the redirect_uri parameter against this whitelist before performing the redirect. Consider using relative URLs or session-based redirect targets instead of user-supplied parameters.

---

## Advanced Techniques

## Technique 1: Impact Escalation Through Chaining

When a vulnerability alone might be medium severity, consider how it could be chained with other issues to create a higher-impact attack:

**Example Chain**: Open Redirect → OAuth Token Theft → Account Takeover

```
1. Attacker crafts malicious OAuth authorization URL with modified redirect_uri
2. Victim clicks the link and authenticates with the OAuth provider
3. OAuth provider redirects to attacker-controlled domain with authorization code
4. Attacker exchanges the authorization code for an access token
5. Attacker uses the access token to access the victim's account
```

When reporting chained vulnerabilities, clearly explain each step and how they combine to create a higher-impact attack. Include the individual vulnerabilities and the chain in your report.

**Example Chain**: Information Disclosure → Credential Extraction → Administrative Access

```
1. Verbose error messages reveal internal IP addresses
2. Internal IP addresses enable SSRF to internal services
3. Internal services expose additional configuration data
4. Configuration data reveals database credentials
5. Database access enables data exfiltration
```

## Technique 2: Business Logic Exploitation

Business logic vulnerabilities often require more creative thinking than technical vulnerabilities:

**Pricing Manipulation**: Modifying price parameters in checkout requests to purchase items at reduced prices.

**Quantity Manipulation**: Ordering negative quantities to receive refunds or credits.

**Race Conditions**: Exploiting time-of-check-to-time-of-use vulnerabilities in inventory or balance management.

**Workflow Bypass**: Skipping required steps in multi-step processes (e.g., skipping verification steps).

Document the business context and explain why the logic flaw is exploitable. Include calculations showing potential financial impact.

## Technique 3: Information Disclosure Chains

Combine multiple information disclosure issues to reveal sensitive information:

```
1. Verbose error messages reveal internal IP addresses
2. Internal IP addresses enable SSRF to internal services
3. Internal services expose additional configuration data
4. Configuration data reveals database credentials
5. Database access enables data exfiltration
```

When reporting information disclosure chains, show how each piece of information enables the next step in the attack chain.

## Technique 4: Client-Side Attack Vectors

Client-side vulnerabilities can have significant impact through browser-based attacks:

**DOM-based XSS**: Exploiting client-side JavaScript that processes untrusted data.

**Prototype Pollution**: Manipulating JavaScript prototypes to achieve code execution or XSS.

**PostMessage Abuse**: Exploiting insecure cross-origin communication.

**Service Worker Attacks**: Hijacking service workers to intercept requests or cache malicious content.

Include browser-specific details and test across multiple browsers to ensure consistent reproduction.

## Technique 5: Account Takeover Chains

Combine multiple vulnerabilities to achieve account takeover:

```
1. Open redirect to steal OAuth tokens
2. CSRF to change email address
3. Password reset to new email
4. Complete account takeover
```

Document each step and explain how they combine to achieve the final impact.

---

## Common Pitfalls

## Pitfall 1: Vague Impact Statements

**Mistake**: "This vulnerability could potentially be used to access user data."

**Fix**: "An attacker could retrieve personal information (email, phone, address) for any user on the platform by sending crafted API requests with modified user IDs."

Always quantify the impact and specify exactly what an attacker can achieve.

## Pitfall 2: Incomplete Reproduction Steps

**Mistake**: "Navigate to the affected endpoint and trigger the vulnerability."

**Fix**: Provide exact URLs, parameters, headers, and expected responses for each step. Include screenshots or video evidence where applicable.

## Pitfall 3: Missing Precondition Documentation

**Mistake**: Not mentioning that the vulnerability requires a specific user role or configuration.

**Fix**: Document all prerequisites, including user roles, account settings, browser requirements, and environmental conditions.

## Pitfall 4: Incorrect Severity Assessment

**Mistake**: Reporting a reflected XSS as Critical when it requires user interaction.

**Fix**: Use the CVSS 3.1 calculator and justify each metric. Consider the real-world impact and attack complexity.

## Pitfall 5: Duplicate Submissions

**Mistake**: Reporting a vulnerability that has already been submitted by another researcher.

**Fix**: Check existing reports before submitting. If you discover a duplicate, add new information to the existing report rather than creating a new one.

## Pitfall 6: Aggressive or Unprofessional Tone

**Mistake**: "This is a critical vulnerability that you should have caught. Your application is completely insecure."

**Fix**: Maintain a professional, constructive tone. Focus on the technical details and impact, not on criticizing the program.

## Pitfall 7: Missing Remediation Guidance

**Mistake**: Not providing any suggestions for fixing the vulnerability.

**Fix**: Include specific remediation recommendations that demonstrate your understanding of the issue and help the program fix it quickly.

## Pitfall 8: Ignoring Platform Guidelines

**Mistake**: Not following platform-specific formatting or submission guidelines.

**Fix**: Review the platform's guidelines and follow them precisely. This demonstrates professionalism and makes triage easier.

---

## Tools and Resources

## Report Writing Tools

**Markdown Editors**: Obsidian, Typora, VS Code with Markdown preview

**Screenshot Tools**: Greenshot, Snagit, built-in OS screenshot tools

**Video Recording**: OBS Studio, Loom, built-in screen recording

**Diagrams**: draw.io, Excalidraw, Mermaid for text-based diagrams

## Severity Calculation

**CVSS 3.1 Calculator**: https://www.first.org/cvss/calculator/3.1

**HackerOne CVSS Calculator**: Built into the report submission form

**Bugcrowd VRT**: https://bugcrowd.com/vulnerability-rating-taxonomy

## Platform-Specific Resources

**HackerOne Report Template**: https://support.hackerone.com/hc/en-us/articles/360001425632

**Bugcrowd Report Template**: https://support.bugcrowd.com/hc/en-us/articles/360004504811

**Intigriti Report Guidelines**: https://help.intigriti.com/hc/en-us/articles/360006738457

## Writing Improvement

**Grammarly**: Grammar and style checking

**Hemingway Editor**: Readability improvement

**Technical Writing Courses**: Google Technical Writing, Microsoft Writing Style Guide

---

## Quick Reference Cheat Sheet

## Report Checklist
- [ ] Title: Specific, includes vulnerability type and endpoint
- [ ] Summary: 1-3 sentences, clear and concise
- [ ] Severity: Justified with CVSS 3.1 metrics
- [ ] Impact: Business risk explained, not just technical impact
- [ ] Reproduction Steps: Numbered, complete, and reproducible
- [ ] Proof of Concept: Minimal and technical
- [ ] Remediation: Specific and actionable
- [ ] Attachments: Screenshots/videos included
- [ ] Formatting: Follows platform-specific guidelines
- [ ] Proofreading: Free of typos and grammatical errors

## Severity Quick Reference
- **Critical (9.0-10.0)**: RCE, SQLi with data exfil, auth bypass, chain leading to system compromise
- **High (7.0-8.9)**: Stored XSS, SSRF to internal, IDOR with sensitive data, CSRF on critical actions
- **Medium (4.0-6.9)**: Reflected XSS, CSRF on non-critical, info disclosure, open redirect
- **Low (0.1-3.9)**: Clickjacking, missing headers, verbose errors, version disclosure

## Title Formula
```
[Vulnerability Type] in [Endpoint/Feature] via [Attack Vector]
```
Examples:
- Reflected XSS in search parameter via unescaped input
- IDOR in user profile API via sequential user IDs
- CSRF on password change via missing token validation

## Impact Statement Formula
```
An attacker could [action] affecting [target] by [method], resulting in [consequence].
```
Example:
"An attacker could steal session tokens from authenticated users by injecting malicious JavaScript via the search parameter, resulting in account takeover of any user who clicks a crafted link."

## Common CVSS Metrics for Bug Bounty
| Vulnerability Type | AV | AC | PR | UI | S | C | I | A |
|-------------------|----|----|----|----|---|---|---|---|
| Reflected XSS | N | L | N | R | U | N | L | N |
| Stored XSS | N | L | N | R | U | L | H | N |
| SQL Injection | N | L | N | N | C | H | H | H |
| SSRF | N | L | N | N | U | L | N | N |
| IDOR | N | L | N | N | U | H | N | N |
| CSRF | N | L | N | R | U | N | H | N |

## Platform-Specific Notes
- **HackerOne**: Use CVSS 3.1, follow report template, check program policy
- **Bugcrowd**: Map to VRT, include severity override if needed, check scope
- **Intigriti**: Follow report template, include challenge submission if applicable
- **Immunefi**: Include financial impact calculations, smart contract analysis

## Report Writing Templates

## Template 1: Standard Vulnerability Report

```markdown
# [Vulnerability Type] in [Endpoint/Feature]

## Summary
[1-3 sentence overview of the vulnerability]

## Vulnerability Details
## Affected Endpoint
- URL: [Full URL]
- Method: [HTTP Method]
- Parameters: [List of affected parameters]

## Vulnerability Description
[Detailed technical description of the vulnerability]

## Severity Assessment
- CVSS Score: [Score]
- Severity: [Critical/High/Medium/Low]
- CVSS Vector: [Vector String]
- Justification: [Why this severity is appropriate]

## Impact
## Business Impact
[Description of business risk and potential consequences]

## Technical Impact
[Description of technical capabilities an attacker gains]

## Steps to Reproduce
1. [Detailed step 1]
2. [Detailed step 2]
3. [Detailed step 3]
[Continue for all steps]

## Proof of Concept
## Request
```http
[HTTP request with headers and body]
```

## Response
```http
[HTTP response showing vulnerability]
```

## Evidence
[Screenshots, videos, or other evidence]

## Remediation
## Recommended Fix
[Specific remediation recommendations]

## Long-term Prevention
[Additional security measures to prevent similar issues]

## References
- [OWASP Reference]
- [CWE Reference]
- [Other relevant references]
```

## Template 2: Chain Vulnerability Report

```markdown
# Chained Vulnerabilities: [Primary] + [Secondary] = [Impact]

## Summary
[1-3 sentence overview of the vulnerability chain]

## Chain Overview
## Individual Vulnerabilities
1. **[Vulnerability 1]**: [Brief description]
2. **[Vulnerability 2]**: [Brief description]

## Chain Impact
[How the vulnerabilities combine to create greater impact]

## Severity Assessment
- Combined CVSS Score: [Score]
- Individual Scores: [List scores]
- Justification: [Why the chain deserves combined severity]

## Impact
## Combined Impact
[Description of the amplified impact from chaining]

## Attack Scenario
[Step-by-step attack scenario showing the chain in action]

## Reproduction Steps
## Step 1: [First Vulnerability]
[Detailed reproduction steps]

## Step 2: [Second Vulnerability]
[Detailed reproduction steps]

## Step 3: Chain Exploitation
[How to chain the vulnerabilities]

## Proof of Concept
[Technical evidence for each step of the chain]

## Remediation
## Individual Fixes
[Fixes for each individual vulnerability]

## Chain Prevention
[Additional measures to prevent chaining]

## References
[Relevant references for each vulnerability]
```

## Template 3: Business Logic Vulnerability Report

```markdown
# Business Logic Flaw in [Feature]

## Summary
[1-3 sentence overview of the business logic flaw]

## Business Context
## Intended Behavior
[How the feature is supposed to work]

## Actual Behavior
[How the feature can be abused]

## Vulnerability Details
## Affected Feature
[Description of the affected feature]

## Flaw Description
[Detailed description of the logic flaw]

## Severity Assessment
- CVSS Score: [Score]
- Severity: [Critical/High/Medium/Low]
- Justification: [Why this severity is appropriate]

## Impact
## Financial Impact
[Quantified financial impact if applicable]

## Business Impact
[Description of business consequences]

## User Impact
[Impact on other users]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Proof of Concept
[Technical evidence demonstrating the logic flaw]

## Impact Calculation
## Scenario 1: [Scenario]
[Calculation of impact]

## Scenario 2: [Scenario]
[Calculation of impact]

## Remediation
## Immediate Fix
[Quick fix to prevent abuse]

## Long-term Solution
[Comprehensive fix to prevent similar issues]

## References
[Relevant references]
```

## Advanced Report Writing Techniques

## Technique 1: Storytelling in Reports

Structure your report as a narrative that guides the triager through the vulnerability:

1. **Setup**: Introduce the application and the feature being tested
2. **Discovery**: Describe how you found the vulnerability
3. **Exploitation**: Demonstrate how the vulnerability can be exploited
4. **Impact**: Explain what an attacker could achieve
5. **Resolution**: Provide clear remediation guidance

This narrative structure makes reports more engaging and easier to understand.

## Technique 2: Visual Evidence

Use visual aids to enhance your report:

- **Screenshots**: Capture key moments in the exploitation process
- **Video Recordings**: Show the complete attack chain in action
- **Diagrams**: Illustrate complex attack flows or architecture
- **Code Snippets**: Highlight relevant code sections

Visual evidence makes reports more compelling and easier to verify.

## Technique 3: Comparative Analysis

Compare your vulnerability with known issues:

- **Similar CVEs**: Reference similar vulnerabilities with CVE numbers
- **Past Reports**: Reference similar reports in the same program
- **Industry Benchmarks**: Compare impact with industry standards

This demonstrates your understanding of the vulnerability class and helps with severity assessment.

## Technique 4: Economic Framing

Frame impact in economic terms:

- **Direct Costs**: Data breach costs, regulatory fines
- **Indirect Costs**: Reputation damage, customer loss
- **Remediation Costs**: Developer time, system downtime

Economic framing helps business stakeholders understand the importance of the vulnerability.

## Report Review Checklist

Before submitting your report, review it against this comprehensive checklist:

**Content Review**:
- [ ] Title accurately describes the vulnerability
- [ ] Summary is clear and concise
- [ ] Technical details are accurate and complete
- [ ] Impact is clearly articulated
- [ ] Severity is justified with CVSS metrics

**Reproduction Review**:
- [ ] Steps are numbered and sequential
- [ ] All necessary information is included
- [ ] Steps are reproducible by someone unfamiliar with the issue
- [ ] Prerequisites are documented

**Evidence Review**:
- [ ] Proof of concept is included
- [ ] Evidence supports the claims made
- [ ] Screenshots/videos are clear and readable
- [ ] Sensitive information is redacted

**Formatting Review**:
- [ ] Report follows platform guidelines
- [ ] Markdown formatting is correct
- [ ] Code blocks are properly formatted
- [ ] Links are working

**Professional Review**:
- [ ] Tone is professional and respectful
- [ ] No emotional or aggressive language
- [ ] Grammar and spelling are correct
- [ ] Report is well-organized

## Post-Submission Activities

After submitting your report:

1. **Monitor for Responses**: Watch for triager questions or requests for additional information
2. **Respond Promptly**: Answer questions quickly and thoroughly
3. **Provide Clarifications**: If the triager doesn't understand something, provide additional explanation
4. **Update if Needed**: If you discover new information, update the report
5. **Learn from Feedback**: Use triager feedback to improve future reports

## Common Report Writing Mistakes

**Mistake 1: Writing for Technical Audiences Only**
- Reality: Triagers may not be experts in your specific testing approach
- Fix: Write for a general security audience, not just technical experts

**Mistake 2: Overcomplicating Explanations**
- Reality: Simple explanations are more effective than complex ones
- Fix: Use clear, concise language and avoid unnecessary jargon

**Mistake 3: Missing Context**
- Reality: Triagers need context to understand the vulnerability
- Fix: Provide sufficient background information about the application and feature

**Mistake 4: Inconsistent Severity Assessment**
- Reality: Inconsistent severity can undermine credibility
- Fix: Use CVSS 3.1 consistently and justify your assessment

**Mistake 5: Poor Organization**
- Reality: Disorganized reports are harder to review
- Fix: Use clear sections and logical flow

## Report Writing Best Practices Summary

1. **Be Specific**: Use precise language and avoid vague statements
2. **Be Clear**: Write for your audience, not for yourself
3. **Be Complete**: Include all necessary information
4. **Be Professional**: Maintain a respectful, constructive tone
5. **Be Visual**: Use screenshots, videos, and diagrams
6. **Be Consistent**: Follow platform guidelines and conventions
7. **Be Thorough**: Review your report before submitting
8. **Be Responsive**: Answer triager questions promptly
9. **Be Honest**: Don't exaggerate impact or severity
10. **Be Helpful**: Provide remediation guidance

## Platform-Specific Report Formatting

**HackerOne Formatting**:
```markdown
## Vulnerability Summary
[Summary]

## Impact
[Impact]

## Steps to Reproduce
[Steps]

## Proof of Concept
[PoC]

## Remediation
[Remediation]
```

**Bugcrowd Formatting**:
```markdown
## Description
[Description]

## Vulnerability Details
[Details]

## Impact
[Impact]

## Steps to Reproduce
[Steps]

## Recommendations
[Remediation]
```

**Intigriti Formatting**:
```markdown
## Summary
[Summary]

## Vulnerability
[Details]

## Impact
[Impact]

## Proof of Concept
[PoC]

## Remediation
[Remediation]
```

## Report Writing Resources

**Writing Guides**:
- Google Technical Writing Course
- Microsoft Writing Style Guide
- Apple Style Guide

**Grammar Tools**:
- Grammarly
- Hemingway Editor
- ProWritingAid

**Markdown Resources**:
- Markdown Guide
- CommonMark Specification
- GitHub Flavored Markdown

**Platform Documentation**:
- HackerOne Report Writing Guide
- Bugcrowd Report Template
- Intigriti Submission Guidelines
- Immunefi Report Format

## Quick Reference Cheat Sheet
1. **Validation**: Vulnerability reproduces consistently
2. **Scope**: Affected endpoint/domain is in scope
3. **Duplicates**: Checked existing reports for duplicates
4. **Severity**: Accurately assessed with CVSS 3.1
5. **Impact**: Clearly articulated business risk
6. **Steps**: Complete and reproducible
7. **PoC**: Included and minimal
8. **Remediation**: Specific and actionable
9. **Formatting**: Follows platform guidelines
10. **Review**: Proofread for errors and clarity
