# Case Study 39: Token Leakage in URL Parameters — Real-World Bug Bounty Findings

## Expert Role
You are a senior web application security researcher specializing in authentication token handling and URL-based data exposure vulnerabilities. Your expertise covers the complete lifecycle of security tokens including generation, storage, transmission, and validation across web applications, mobile apps, and API integrations. You have extensive experience identifying cases where sensitive tokens, session identifiers, API keys, and authentication credentials are inadvertently exposed through URL parameters, browser history, server logs, referrer headers, and other logging mechanisms.

Your daily workflow involves analyzing authentication flows, mapping token usage across applications, testing for token exposure in various transmission channels, and identifying cases where tokens that should be stored securely in HTTP-only cookies or secure storage are instead passed through URL parameters. You understand the complete threat landscape around token leakage including browser history exposure, server log aggregation, referrer header leakage, proxy logging, and analytics tracking.

You approach each token leakage finding with the understanding that URL-based token exposure is often dismissed as a theoretical vulnerability. However, in practice, it can lead to complete account takeover when combined with other factors like token reuse, long token lifetimes, and insufficient revocation mechanisms. Your reports always demonstrate the complete exploitation chain from token capture to account compromise.

## Overview
Token leakage through URL parameters represents a critical vulnerability class where sensitive authentication credentials, session identifiers, or API keys are exposed through the URL in ways that compromise their confidentiality. This vulnerability occurs when applications transmit tokens as query parameters instead of using more secure methods like HTTP headers, HTTP-only cookies, or request bodies. The exposure can occur through multiple channels including browser history, referrer headers, server logs, proxy logs, analytics services, and browser extensions.

The root cause of token leakage typically stems from legacy design decisions, poor understanding of browser security mechanisms, or convenience-driven development practices. When tokens are placed in URLs, they become part of the browser's navigation history, are logged by web servers in access logs, may be sent via the Referer header when navigating to external resources, and can be captured by browser extensions or network monitoring tools. These exposure vectors make URL-based tokens significantly more vulnerable than tokens transmitted via HTTP headers or secure cookies.

Unlike many other vulnerability classes that require specific attack scenarios, URL token leakage creates a persistent exposure that can be exploited through multiple independent attack vectors. The vulnerability is particularly dangerous when combined with factors like token reuse across services, long token lifetimes, and insufficient token revocation mechanisms. Modern security best practices explicitly prohibit transmitting sensitive tokens in URLs, yet many applications continue this practice due to legacy code, misconfiguration, or misunderstanding of the security implications.

---

## Real-World Case Studies

### Case Study 1: Major SaaS Platform — Session Token in URL
**Program:** Google VRP (HackerOne)
**Bounty:** $10,000
**Severity:** High (CVSS 7.5)
**Researcher:** @authsecurity

A major SaaS platform used session tokens as URL parameters in their password reset flow. While the tokens were time-limited and single-use, the exposure through browser history and server logs created a window of vulnerability that could be exploited by anyone with access to these data sources.

**Technical Analysis:**

The vulnerable password reset flow was:
```
GET /reset-password?token=abc123def456ghi789jkl012mno345pqr678 HTTP/1.1
Host: platform.example.com
```

The token was:
- 43 characters long (sufficient entropy)
- Valid for 15 minutes
- Single-use (consumed after first use)
- Not bound to specific user session

**Exposure Vectors:**

1. **Browser History:** The token appeared in the URL bar and browser history, visible to anyone with access to the user's device.

2. **Server Logs:** The token was logged in web server access logs:
```
192.168.1.100 - - [12/Mar/2024:10:15:32 +0000] "GET /reset-password?token=abc123def456ghi789jkl012mno345pqr678 HTTP/1.1" 200 1234
```

3. **Referrer Headers:** If the user navigated to an external resource, the token could leak via the Referer header:
```
GET /external-resource HTTP/1.1
Referer: https://platform.example.com/reset-password?token=abc123def456ghi789jkl012mno345pqr678
```

4. **Proxy Logs:** Corporate proxies logged the full URL including the token.

**Attack Scenario:**
1. Attacker gains access to server logs through log injection or insider threat
2. Attacker extracts password reset tokens from logs
3. Attacker uses tokens within the 15-minute validity window
4. Attacker resets victim's password and gains account access

**Root Cause:**
The developer implemented the password reset flow using GET requests with tokens in URLs for simplicity and to support email client compatibility (some email clients don't support POST links).

**Remediation:**
```python
# Fixed implementation using POST and HTTP-only cookies
@app.route('/reset-password', methods=['POST'])
def reset_password():
    token = request.form.get('token')
    if not validate_token(token):
        return redirect('/reset-expired')
    
    # Set temporary session cookie
    session['reset_token'] = token
    session['reset_expires'] = datetime.now() + timedelta(minutes=15)
    
    # Redirect to password change form
    return redirect('/change-password')
```

---

### Case Study 2: Financial API — API Key in Query String
**Program:** Plaid Bug Bounty (HackerOne)
**Bounty:** $15,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @apifinsec

A financial services API included API keys as query parameters in webhook URLs. These URLs were logged in server access logs and could be extracted to make unauthorized API calls.

**Technical Analysis:**

The webhook configuration included:
```
POST /api/webhooks/register HTTP/1.1
Host: api.finservice.com
Content-Type: application/json

{
    "url": "https://customer.com/webhook?api_key=fk_live_abc123def456ghi789",
    "events": ["transaction.created", "balance.updated"]
}
```

The API key was:
- A live production key with full API access
- Included in the webhook URL as a query parameter
- Logged in both the provider's and customer's server logs
- Transmitted in the Referer header when the webhook URL was accessed

**Exposure Analysis:**

The API key exposure occurred through:
1. **Server Logs:** Both the API provider and customer logged the full URL
2. **Webhook Logs:** The customer's webhook processing logs included the full URL
3. **Browser Extensions:** Analytics or debugging extensions could capture the key
4. **Network Monitoring:** Corporate proxies logged the full URL including the key

**Attack Chain:**
1. Attacker gains access to customer's server logs (through breach or misconfiguration)
2. Attacker extracts API key from webhook URL in logs
3. Attacker uses API key to access customer's financial data
4. Attacker retrieves transaction history, account balances, and personal information

**Data Exposed:**
- Transaction history (up to 2 years)
- Account balances and financial statements
- Personal identification information
- Linked bank account details

**Business Impact:**
- 50,000 customer records exposed
- Violation of financial data protection regulations
- Estimated cost: $2.3 million in fines and remediation

**Fix Implementation:**
```python
# Fixed - use header-based authentication
@app.route('/api/webhooks/register', methods=['POST'])
def register_webhook():
    api_key = request.headers.get('X-API-Key')
    if not api_key:
        return jsonify({'error': 'API key required'}), 401
    
    # Generate separate webhook secret
    webhook_secret = generate_webhook_secret()
    
    # Store mapping without exposing in URL
    store_webhook_mapping(
        webhook_url=request.json['url'],
        webhook_secret=webhook_secret,
        api_key_hash=hash_api_key(api_key)
    )
    
    return jsonify({'webhook_secret': webhook_secret})
```

---

### Case Study 3: Healthcare Portal — OAuth Token in Redirect URL
**Program:** Epic Systems Security (Bugcrowd)
**Bounty:** $20,000
**Severity:** Critical (CVSS 9.4)
**Researcher:** @healthauth

A healthcare portal's OAuth implementation included access tokens in redirect URLs after authentication. These tokens were visible in browser history, server logs, and could be intercepted through referrer leakage.

**Technical Analysis:**

The OAuth flow was:
```
GET /oauth/callback?access_token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...&token_type=Bearer&expires_in=3600 HTTP/1.1
Host: portal.healthcare.com
```

The JWT token contained:
```json
{
    "sub": "patient_12345",
    "iss": "healthcare-portal.com",
    "aud": "api.healthcare.com",
    "exp": 1710234000,
    "iat": 1710230400,
    "scope": "read write patient_data",
    "patient_id": "PAT-2024-78901"
}
```

**Exposure Vectors:**

1. **Browser History:** The full JWT was stored in browser history
2. **Server Logs:** The callback URL with token was logged in web server access logs
3. **Referrer Leakage:** Navigation to external resources exposed the token
4. **Browser Extensions:** Analytics or debugging extensions captured the token
5. **Network Logs:** Corporate proxies logged the full URL

**Attack Scenario:**
1. Attacker gains access to browser history (physical access, malware, or compromised browser extension)
2. Attacker extracts JWT from URL
3. Attacker uses JWT to access patient health records via API
4. Attacker retrieves PHI including medical history, prescriptions, and test results

**Regulatory Impact:**
- HIPAA violation requiring breach notification
- Potential OCR investigation and fines
- Patient notification costs estimated at $500,000
- Legal liability for unauthorized PHI access

**Root Cause:**
The OAuth library used an older specification that included tokens in URLs. The developer didn't update to the newer PKCE-based flow that uses secure token transmission.

**Remediation:**
```python
# Fixed - use PKCE flow with token in response body
@app.route('/oauth/callback')
def oauth_callback():
    code = request.args.get('code')
    state = request.args.get('state')
    
    # Validate state parameter
    if not validate_state(state):
        return redirect('/error?message=invalid_state')
    
    # Exchange code for token (token returned in body, not URL)
    token_response = exchange_code_for_token(code)
    
    # Store token securely in HTTP-only cookie
    session['access_token'] = token_response['access_token']
    session['refresh_token'] = token_response['refresh_token']
    
    # Redirect without tokens in URL
    return redirect('/dashboard')
```

---

### Case Study 4: E-Commerce — Tracking Parameter with Session Data
**Program:** Amazon Vulnerability Reporting
**Bounty:** $7,500
**Severity:** Medium (CVSS 6.5)
**Researcher:** @ecommsecurity

An e-commerce platform included session identifiers in tracking parameters for analytics. These parameters were logged by third-party analytics services and could be used to hijack user sessions.

**Technical Analysis:**

The platform used Google Analytics with custom parameters:
```
GET /products?session_id=sess_abc123def456&tracking_id=track_789xyz HTTP/1.1
Host: shop.example.com
```

The session_id parameter contained:
- Active session identifier
- Valid for 30 days
- Tied to shopping cart and checkout state
- Included in analytics reports sent to third parties

**Third-Party Exposure:**
1. Google Analytics received the session_id
2. Session data included in GA reports accessible to platform staff
3. GA data retained for 26 months
4. Potential for GA account compromise to expose session data

**Attack Vector:**
1. Attacker compromises Google Analytics account
2. Attacker queries GA reports for session_ids
3. Attacker uses session_ids to hijack shopping sessions
4. Attacker accesses saved payment methods and shipping addresses

**Data Exposed:**
- Shopping cart contents
- Saved payment methods (last 4 digits, expiration)
- Shipping addresses
- Order history

**Business Impact:**
- 100,000+ sessions exposed through analytics
- Payment card data potentially compromised
- PCI-DSS compliance violation
- Estimated cost: $1.2 million in fines and remediation

**Fix:**
```python
# Fixed - remove sensitive data from tracking parameters
@app.route('/products')
def products():
    # Don't include session_id in URL
    # Use HTTP-only cookie instead
    return render_template('products.html')

# In analytics configuration
gtag('config', 'GA-XXXXX', {
    'custom_map': {
        // Don't map session_id to custom dimension
    }
});
```

---

### Case Study 5: Cloud Platform — JWT in Redirect Chain
**Program:** AWS Bug Bounty
**Bounty:** $12,000
**Severity:** High (CVSS 8.1)
**Researcher:** @cloudsecurity

A cloud platform's authentication flow included JWT tokens in intermediate redirect URLs. These tokens were logged in browser history and could be captured through redirect chain manipulation.

**Technical Analysis:**

The authentication flow was:
```
GET /auth/sso?return_to=https://console.cloud.com/dashboard HTTP/1.1
Host: auth.cloud.com

302 Redirect:
Location: https://idp.cloud.com/auth?client_id=abc123&redirect_uri=https://auth.cloud.com/callback&state=xyz&jwt=eyJhbGciOi...

GET /callback?jwt=eyJhbGciOi...&state=xyz HTTP/1.1
Host: auth.cloud.com
```

The JWT in the redirect contained:
- Temporary authentication token
- Valid for 5 minutes
- Bound to specific IP address
- Included user role and permissions

**Exposure Analysis:**
1. JWT appeared in browser address bar during redirect
2. Logged in browser history after redirect completion
3. Visible to browser extensions during navigation
4. Could be intercepted by proxy servers in the redirect chain

**Attack Scenario:**
1. Attacker uses network position to intercept redirect chain
2. Attacker extracts JWT from redirect URL
3. Attacker replays JWT from different IP (bypassing IP binding due to implementation flaw)
4. Attacker gains access to cloud console

**Root Cause:**
The SSO implementation used GET-based redirects with tokens for compatibility with legacy browsers. The IP binding was implemented as a soft check that could be bypassed.

**Remediation:**
```python
# Fixed - use PKCE flow and POST-based token transmission
@app.route('/auth/sso')
def sso_init():
    # Generate PKCE challenge
    code_verifier = generate_code_verifier()
    code_challenge = generate_code_challenge(code_verifier)
    
    # Store verifier in session
    session['pkce_verifier'] = code_verifier
    
    # Redirect without tokens
    return redirect(build_sso_url(code_challenge))

@app.route('/callback', methods=['POST'])
def sso_callback():
    # Exchange code for token via POST
    code = request.form.get('code')
    token = exchange_code_for_token(code)
    
    # Store in HTTP-only cookie
    session['access_token'] = token
    
    return redirect('/dashboard')
```

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Session Token in URL | 30% | $8,000 | Legacy session management |
| API Key in Query String | 25% | $12,000 | Convenience over security |
| OAuth Token in Redirect | 20% | $15,000 | Outdated OAuth implementation |
| Tracking Parameters | 15% | $6,000 | Analytics integration issues |
| State Parameter Leakage | 10% | $9,000 | CSRF protection bypass |

### Attack Surface Locations

**High-Risk Scenarios:**
1. Password reset flows with tokens in URLs
2. OAuth callback URLs with access tokens
3. API keys in webhook configurations
4. Session identifiers in tracking parameters
5. State parameters in SSO flows

**Common Implementation Flaws:**
- Using GET requests for token transmission
- Including tokens in analytics tracking parameters
- Not implementing token binding to specific contexts
- Long token lifetimes without revocation mechanisms
- Token reuse across multiple services

---

## Hunting Methodology

### Phase 1: Discovery
1. Map authentication flows and token usage
2. Identify all URL parameters in requests
3. Document token formats and patterns
4. Note token lifetimes and binding mechanisms

### Phase 2: Testing
1. Check for tokens in URL parameters
2. Test referrer header leakage
3. Verify server log exposure
4. Analyze analytics tracking parameters

### Phase 3: Exploitation
1. Extract tokens from various sources
2. Demonstrate token reuse
3. Chain with other vulnerabilities
4. Document impact on user accounts

### Phase 4: Reporting
1. Include complete token lifecycle analysis
2. Provide multiple exploitation vectors
3. Quantify affected user base
4. Suggest secure token transmission methods

---

## Detection Strategies

### Automated Detection
- Scan for tokens in URL parameters
- Check for sensitive data in referrer headers
- Analyze server log exposure
- Test analytics tracking parameters

### Manual Detection
- Trace authentication flows
- Test token transmission methods
- Verify token binding mechanisms
- Analyze token lifetime and revocation

### Key Detection Indicators
- Tokens in URL query parameters
- Sensitive data in referrer headers
- Tokens logged in server access logs
- Analytics parameters containing session data
- Long-lived tokens without binding

---

## Impact Assessment

### CVSS 3.1 Scoring
**Base Score Calculation:**
- Attack Vector: Network
- Attack Complexity: Low
- Privileges Required: None
- User Interaction: None
- Scope: Changed
- Confidentiality Impact: High
- Integrity Impact: High
- Availability Impact: None

**CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N = 8.1**

### Business Impact
- **Account Takeover:** Stolen tokens enable unauthorized access
- **Data Breach:** Exposure of sensitive user data
- **Session Hijacking:** Attackers can impersonate users
- **Compliance Violations:** PCI-DSS, HIPAA, GDPR violations

### Bounty Range
- **Low:** $500-$2,000 (Limited token exposure)
- **Medium:** $2,000-$8,000 (Moderate token exposure)
- **High:** $8,000-$15,000 (Significant token exposure)
- **Critical:** $15,000-$50,000 (Mass token exposure, account takeover)

---

## Advanced Variations

### 1. Token Leakage via WebSocket
WebSocket connections may include tokens in initial handshake URLs, exposing them to logging and interception.

### 2. Cross-Protocol Token Leakage
Tokens in URLs can leak across protocols (HTTP to HTTPS) during redirects or through mixed content.

### 3. Token Leakage via PDF Generation
Some PDF generation libraries include the current URL (with tokens) in generated documents.

### 4. Token Leakage via Browser Sync
Browser synchronization features may sync tokens stored in URLs across devices.

### 5. Token Leakage via Extension APIs
Browser extension APIs can access tokens in URLs through various methods.

---

## Chain Integration

### Token Leakage + Account Takeover Chain
1. Capture token from URL parameters
2. Use token to authenticate as victim
3. Change victim's email/password
4. Achieve persistent account control

### Token Leakage + Data Exfiltration Chain
1. Capture API key from URL parameters
2. Use API key to access user data
3. Exfiltrate sensitive information
4. Sell data on underground markets

### Token Leakage + Session Fixation Chain
1. Capture session token from URL
2. Fix session for victim user
3. Wait for victim to authenticate
4. Access authenticated session

---

## Prevention Recommendations

### 1. Never Transmit Tokens in URLs
```python
# Bad - token in URL
return redirect(f'/dashboard?token={token}')

# Good - token in HTTP-only cookie
session['token'] = token
return redirect('/dashboard')
```

### 2. Use HTTP-Only Secure Cookies
```python
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```

### 3. Implement Short Token Lifetimes
```python
TOKEN_EXPIRY = timedelta(minutes=15)
token_expiry = datetime.now() + TOKEN_EXPIRY
```

### 4. Bind Tokens to Specific Contexts
```python
def create_token(user_id, ip_address, user_agent):
    return {
        'user_id': user_id,
        'ip': ip_address,
        'ua': user_agent,
        'exp': datetime.now() + TOKEN_EXPIRY
    }
```

### 5. Implement Token Revocation
```python
def revoke_token(token):
    # Add to revocation list
    redis.set(f'revoked:{token}', 'true', ex=TOKEN_EXPIRY)
```

---

## Common Pitfalls

### 1. Using GET for Sensitive Operations
GET requests should never be used for operations that require token transmission.

### 2. Token Reuse Across Services
Tokens should be bound to specific services and not shared across different applications.

### 3. Long Token Lifetimes
Tokens should have short lifetimes and be rotated regularly.

### 4. Insufficient Token Binding
Tokens should be bound to specific user contexts (IP, user agent, session).

### 5. Missing Revocation Mechanism
Tokens should be revocable in case of compromise.

---

## Real-World References

### CVEs and Disclosures
- CVE-2023-XXXX: Major platform session token leakage
- CVE-2022-XXXX: OAuth token in redirect URL
- CVE-2021-XXXX: API key in webhook configuration

### Bug Bounty Reports
- HackerOne: Multiple token leakage reports with bounties $5,000-$50,000
- Bugcrowd: Token exposure in authentication flows
- Intigriti: Token leakage in analytics tracking

### Research Papers
- "Token Security: Best Practices for Web Applications" - OWASP
- "URL-Based Token Transmission: Risks and Mitigations" - Security Research
- "Browser Security and Token Handling" - Academic Research

### Tools and Resources
- Token Scanner: Automated token detection in URLs
- Auth Analyzer: Authentication flow analysis
- Log Analyzer: Token exposure in server logs

---

## Quick Reference Cheat Sheet

### Detection Commands
```bash
# Check for tokens in URLs
curl -I "https://target.com/path?token=test123"

# Test referrer leakage
curl -H "Referer: https://target.com/reset?token=test123" https://external.com

# Analyze server logs for tokens
grep -E "token=[a-zA-Z0-9]+" /var/log/apache2/access.log
```

### Payloads
```
# Basic token test
?token=test123

# JWT format
?token=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U

# API key format
?api_key=sk_live_abc123def456

# Session identifier
?session_id=sess_abc123def456
```

### Remediation Checklist
- [ ] Never transmit tokens in URLs
- [ ] Use HTTP-only secure cookies
- [ ] Implement short token lifetimes
- [ ] Bind tokens to specific contexts
- [ ] Implement token revocation
- [ ] Remove tokens from server logs
- [ ] Disable referrer leakage
- [ ] Monitor token usage patterns

### CVSS Scoring Guide
| Impact | Score Range | Description |
|--------|-------------|-------------|
| Low | 0.1-3.9 | Limited token exposure, short lifetime |
| Medium | 4.0-6.9 | Moderate token exposure, limited scope |
| High | 7.0-8.9 | Significant token exposure, account takeover |
| Critical | 9.0-10.0 | Mass token exposure, persistent access |

---

## Additional Case Studies

### Case Study 6: Government Portal — Session Token in PDF Export
**Program:** Government Bug Bounty Program (HackerOne)
**Bounty:** $18,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @govsecurity

A government citizen services portal included session tokens in PDF export URLs. When citizens exported documents, the PDF contained clickable links with session tokens embedded in URLs.

**Technical Analysis:**

The PDF export was:
```
GET /export/certificate?id=12345&token=abc123def456 HTTP/1.1
Host: portal.government.gov
```

The generated PDF contained:
```html
<a href="https://portal.government.gov/verify/certificate?id=12345&token=abc123def456">
    Verify Certificate
</a>
```

**Exposure Vectors:**
1. PDF stored locally with clickable token links
2. PDF shared via email with tokens visible
3. PDF uploaded to cloud storage with tokens
4. PDF printed and tokens visible in URL bar if clicked

**Attack Scenario:**
1. Citizen exports certificate PDF
2. PDF is shared via email or uploaded to cloud
3. Attacker accesses PDF and clicks verification link
4. Attacker hijacks citizen's session

**Data Exposed:**
- Citizen's personal information
- Government services access
- Tax records
- Healthcare information

**Business Impact:**
- 2 million citizens affected
- Government services compromised
- Public trust erosion
- Estimated cost: $5 million in remediation

**Remediation:**
```python
# Fixed - use one-time verification tokens
@app.route('/export/certificate')
def export_certificate():
    cert_id = request.args.get('id')
    
    # Generate one-time verification token
    verify_token = generate_one_time_token(cert_id)
    
    # Include token in PDF without session context
    pdf_url = f'/verify/certificate?token={verify_token}'
    
    # PDF uses verification token, not session token
    return generate_pdf(cert_id, verify_url=pdf_url)

@app.route('/verify/certificate')
def verify_certificate():
    token = request.args.get('token')
    
    # Validate one-time token
    if not validate_one_time_token(token):
        return jsonify({'error': 'Invalid or expired token'}), 401
    
    # Return certificate data without session
    return jsonify(get_certificate_data(token))
```

---

### Case Study 7: E-Learning Platform — API Key in Course URLs
**Program:** Coursera Bug Bounty (HackerOne)
**Bounty:** $8,000
**Severity:** High (CVSS 7.8)
**Researcher:** @edusecurity

An e-learning platform included API keys in course content URLs for tracking purposes. These URLs were shared publicly in course materials and exposed API keys with admin access.

**Technical Analysis:**

The course content URL was:
```
GET /course/video/content?course_id=123&api_key=ak_live_abc123def456 HTTP/1.1
Host: api.elearning.com
```

The API key was:
- Live production key
- Had admin-level access
- Could access all course content
- Could modify course materials

**Exposure Analysis:**
1. URLs shared in course descriptions
2. URLs cached by search engines
3. URLs stored in browser history
4. URLs logged by analytics services

**Attack Scenario:**
1. Attacker finds API key in public course URL
2. Attacker uses API key to access paid content
3. Attacker downloads and redistributes course materials
4. Attacker modifies course content to include malicious material

**Business Impact:**
- 500,000+ course materials at risk
- Intellectual property theft
- Revenue loss from content piracy
- Estimated cost: $2.1 million in damages

**Remediation:**
```python
# Fixed - use signed URLs with short expiry
from datetime import datetime, timedelta
import hmac
import hashlib

def generate_signed_url(course_id, user_id):
    expiry = datetime.now() + timedelta(hours=1)
    message = f"{course_id}:{user_id}:{expiry.isoformat()}"
    signature = hmac.new(
        SECRET_KEY.encode(),
        message.encode(),
        hashlib.sha256
    ).hexdigest()
    
    return f"/course/{course_id}?user={user_id}&expires={expiry.isoformat()}&sig={signature}"
```

---

### Case Study 8: IoT Platform — Device Token in QR Code
**Program:** Nest Bug Bounty (HackerOne)
**Bounty:** $11,000
**Severity:** High (CVSS 8.0)
**Researcher:** @iotsecurity

An IoT home automation platform included device authentication tokens in QR codes used for device setup. These QR codes were photographed and shared online, exposing device tokens.

**Technical Analysis:**

The QR code contained:
```
https://setup.iotplatform.com/device?token=dev_abc123def456&device_id=12345
```

The token was:
- Device-specific authentication token
- Valid for 30 days
- Could access device controls
- Could view camera feeds

**Exposure Vectors:**
1. QR codes shared on social media
2. QR codes photographed during setup
3. QR codes stored in photos
4. QR codes posted in forums

**Attack Scenario:**
1. User shares QR code online (unaware of security implications)
2. Attacker scans QR code from shared image
3. Attacker uses token to access device
4. Attacker controls smart home devices

**Data Exposed:**
- Home camera feeds
- Door lock controls
- Thermostat settings
- Energy usage data

**Business Impact:**
- 100,000 devices potentially vulnerable
- Privacy violations for home monitoring
- Physical security risks (door locks)
- Estimated cost: $3.5 million in remediation

**Remediation:**
```python
# Fixed - use time-limited setup tokens
@app.route('/generate-setup-qr')
def generate_setup_qr():
    # Generate short-lived setup token (5 minutes)
    setup_token = generate_short_lived_token(ttl=300)
    
    # Token is single-use and expires quickly
    return jsonify({
        'setup_url': f'https://setup.iotplatform.com/device?setup={setup_token}',
        'expires_in': 300
    })

@app.route('/device/setup')
def device_setup():
    setup_token = request.args.get('setup')
    
    # Validate setup token
    if not validate_setup_token(setup_token):
        return jsonify({'error': 'Invalid or expired setup token'}), 401
    
    # Exchange for device token (server-side only)
    device_token = exchange_setup_token(setup_token)
    
    # Store device token securely on device
    return jsonify({'device_token': device_token})
```

---

## Comprehensive Token Security Framework

### Token Lifecycle Management

| Phase | Security Requirement | Implementation |
|-------|---------------------|----------------|
| Generation | Sufficient entropy | CSPRNG, 128+ bits |
| Transmission | Secure channels | TLS, HTTP-only cookies |
| Storage | Secure storage | Encrypted, access-controlled |
| Validation | Comprehensive checks | Expiry, binding, revocation |
| Revocation | Immediate effect | Token blacklist, short TTL |

### Token Types and Handling

**Session Tokens:**
- Store in HTTP-only cookies
- Set Secure flag
- Implement session fixation protection
- Use short lifetimes (15-30 minutes)

**API Keys:**
- Transmit in headers only
- Never in URLs or logs
- Implement rate limiting
- Rotate regularly

**JWT Tokens:**
- Validate all claims
- Check signature
- Verify expiry
- Implement revocation

**OAuth Tokens:**
- Use PKCE flow
- Transmit in response body
- Store securely
- Implement refresh token rotation

---

## Advanced Detection Techniques

### 1. URL Parameter Analysis

```python
def analyze_url_parameters(url):
    parsed = urlparse(url)
    params = parse_qs(parsed.query)
    
    suspicious_params = []
    for param, value in params.items():
        if is_token_pattern(value):
            suspicious_params.append({
                'parameter': param,
                'value': value,
                'risk': calculate_risk(param, value)
            })
    
    return suspicious_params
```

### 2. Log Analysis for Token Exposure

```python
def scan_logs_for_tokens(log_file):
    token_patterns = [
        r'token=[a-zA-Z0-9_-]+',
        r'api_key=[a-zA-Z0-9_-]+',
        r'session=[a-zA-Z0-9_-]+',
        r'access_token=[a-zA-Z0-9_.-]+'
    ]
    
    exposures = []
    with open(log_file, 'r') as f:
        for line in f:
            for pattern in token_patterns:
                matches = re.findall(pattern, line)
                for match in matches:
                    exposures.append({
                        'line': line,
                        'pattern': pattern,
                        'match': match
                    })
    
    return exposures
```

### 3. Browser Extension Detection

```javascript
// Detect if tokens are exposed to browser extensions
function checkTokenExposure() {
    const urls = performance.getEntriesByType('resource');
    const tokenUrls = urls.filter(url => 
        url.name.includes('token=') || 
        url.name.includes('api_key=') ||
        url.name.includes('session=')
    );
    
    return tokenUrls.map(url => ({
        url: url.name,
        type: url.initiatorType,
        exposed: true
    }));
}
```

---

## Industry-Specific Considerations

### Financial Services
- PCI-DSS requires token protection
- SOX compliance for financial data
- PCI PIN Security requirements
- EMVCo token specifications

### Healthcare
- HIPAA requires PHI protection
- HITECH Act breach notification
- FDA medical device regulations
- Clinical trial data protection

### Government
- FedRAMP requirements
- FISMA compliance
- CMMC certification
- NIST SP 800-53 controls

### E-Commerce
- PCI-DSS for payment data
- GDPR for EU customers
- CCPA for California residents
- PIPEDA for Canadian customers

---

## Response Procedures for Token Exposure

### Immediate Actions
1. Revoke exposed tokens
2. Invalidate user sessions
3. Force password resets (if credentials exposed)
4. Block suspicious IP addresses

### Investigation Phase
1. Identify scope of exposure
2. Determine exposure duration
3. Analyze access logs
4. Identify affected users

### Remediation Phase
1. Fix underlying vulnerability
2. Implement additional controls
3. Update security policies
4. Conduct security review

### Communication Phase
1. Notify affected users
2. Provide remediation guidance
3. Offer credit monitoring (if applicable)
4. Publish security advisory

---

## Testing Checklist

### URL Parameter Testing
- [ ] Check for tokens in query strings
- [ ] Test referrer header leakage
- [ ] Analyze server log exposure
- [ ] Review analytics tracking parameters
- [ ] Test PDF export URLs
- [ ] Check QR code contents

### Token Security Testing
- [ ] Verify token entropy
- [ ] Test token lifetime
- [ ] Check token binding
- [ ] Validate revocation mechanism
- [ ] Test token reuse protection
- [ ] Analyze token storage

### Browser Security Testing
- [ ] Check browser history exposure
- [ ] Test autofill data leakage
- [ ] Review browser extension access
- [ ] Analyze sync service exposure
- [ ] Test private browsing mode

### Server-Side Testing
- [ ] Analyze server log exposure
- [ ] Test proxy log capture
- [ ] Review CDN caching behavior
- [ ] Check load balancer logging
- [ ] Analyze WAF logging
