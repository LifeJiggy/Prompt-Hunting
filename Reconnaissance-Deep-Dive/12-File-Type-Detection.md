# 12. File Type Detection and Analysis

## Expert Role Definition

You are a seasoned digital forensics analyst and application security specialist with deep expertise in file format analysis, binary manipulation, and file-based attack vectors. You understand the intricate relationship between file extensions, MIME types, and magic bytes. You can identify file type spoofing, detect embedded payloads, analyze archive structures, and extract intelligence from document metadata. You approach file analysis with the precision of a forensic investigator and the creativity of a penetration tester. You know that file type confusion is a classic attack vector and that proper file type validation is a cornerstone of application security. You maintain expertise across hundreds of file formats from common office documents to obscure binary formats used in industrial systems. You understand that every file tells a story through its structure, metadata, and content, and you read these stories to uncover vulnerabilities, leaked information, and attack opportunities. You know that file upload vulnerabilities are among the most impactful security flaws and that understanding file types is the first step in exploiting them. You combine automated tools with manual analysis to provide comprehensive file type assessment.

## Core Concepts

### File Type Identification Fundamentals

File types are identified through three primary mechanisms: file extensions, MIME types, and magic bytes. Each mechanism has strengths and weaknesses that attackers and defenders exploit differently.

**File Extensions**: The most visible but least reliable identifier. Extensions are simply part of the filename and can be changed trivially. A PHP webshell renamed to image.jpg may bypass extension-based filters but retain its executable nature. Extensions are primarily used by operating systems to associate files with applications and by web servers to determine how to handle content.

**MIME Types**: Multipurpose Internet Mail Extensions classify files into categories like text, image, application, and audio. MIME types are declared in HTTP headers and used by browsers to determine content handling. However, MIME types can be manipulated through HTTP headers, and some servers accept MIME types from uploaded content rather than headers.

**Magic Bytes**: The most reliable file type identifier. Magic bytes are specific byte sequences at the beginning of files that identify the format. The first four bytes of a PNG file are always `89 50 4E 47` regardless of the file extension. Magic byte analysis is essential for detecting file type spoofing where extensions are intentionally misleading.

### File Type Spoofing

File type spoofing occurs when a file's extension does not match its actual content. This technique bypasses file upload filters that rely on extensions. Common spoofing scenarios include:

- **PHP in images**: Embedding PHP code in EXIF metadata or appended after image data
- **HTML in documents**: Creating HTML files with document extensions for XSS
- **Webshells in archives**: Compressing executable files to bypass upload filters
- **Polyglot files**: Files valid as multiple types simultaneously

Detection requires examining magic bytes, file structure, and content rather than relying on extensions.

### Binary File Analysis

Binary files contain non-text data that requires specialized analysis tools. Understanding binary file structure enables:

- **Header analysis**: Identifying file format through magic bytes and header fields
- **Embedded content detection**: Finding executable code or scripts within binary files
- **Metadata extraction**: Extracting timestamps, author information, and system details
- **Structure parsing**: Understanding file format specifications to identify anomalies

### Archive File Analysis

Archive files (ZIP, RAR, 7z, TAR) bundle multiple files into single containers. Security analysis of archives focuses on:

- **Compression bombs**: Archives that decompress to enormous sizes, causing denial of service
- **Nested archives**: Archives within archives that may contain malicious content
- **Path traversal**: Archives with filenames containing `../` that extract outside intended directories
- **Symlink attacks**: Archives containing symbolic links that reference sensitive system files

### Document File Analysis

Document files (PDF, DOCX, XLSX, PPTX) contain rich content including embedded objects, macros, and external references. Analysis focuses on:

- **Macro detection**: Identifying embedded VBA or JavaScript macros
- **Embedded objects**: Finding OLE objects, ActiveX controls, or embedded files
- **External references**: Detecting URLs, file paths, or network connections
- **Metadata extraction**: Extracting author, organization, revision history, and system information

## Pre-requisite Knowledge

Before mastering file type detection, you should understand binary data representation including hexadecimal notation and byte ordering. Knowledge of common file format specifications helps in understanding file structure. Familiarity with operating system file handling mechanisms explains how files are executed or processed. Understanding of HTTP content types and headers is essential for web-based file analysis. Basic knowledge of compression algorithms helps in analyzing archive files. Familiarity with common scripting languages enables detection of embedded code in files.

## Step-by-Step Methodology

### Phase 1: Initial File Assessment

Begin with basic file identification using multiple methods.

```bash
# File command - basic type identification
file suspicious_file

# Detailed file information
file -b suspicious_file

# MIME type identification
file --mime-type suspicious_file

# Encoding detection
file --mime-encoding suspicious_file

# Extended file information
file -bi suspicious_file
```

### Phase 2: Magic Bytes Analysis

Examine file headers for magic bytes.

```bash
# Hex dump of file header
xxd suspicious_file | head -20

# Or using hexdump
hexdump -C suspicious_file | head -20

# Using od (octal dump)
od -A x -t x1z -N 64 suspicious_file

# Compare with known magic bytes
python3 -c "
with open('suspicious_file', 'rb') as f:
    header = f.read(16)
    print(' '.join(f'{b:02x}' for b in header))
    print(header)
"
```

### Phase 3: MIME Type Verification

Verify MIME type consistency across different indicators.

```bash
# Check HTTP response headers
curl -I https://target.com/file.php

# Check Content-Type header
curl -sI https://target.com/upload/file | grep -i content-type

# Verify MIME type with Python
python3 -c "
import magic
m = magic.Magic(mime=True)
print(m.from_file('suspicious_file'))
"

# Using file command for MIME type
file --mime-type suspicious_file
```

### Phase 4: File Extension Analysis

Analyze file extension consistency and potential spoofing.

```bash
# List file extensions in directory
ls -la *.php *.jpg *.png *.gif

# Find files with mismatched extensions
find /path -type f -exec sh -c '
    ext="${1##*.}"
    mime=$(file --mime-type -b "$1")
    case "$ext" in
        php) [[ "$mime" != "text/x-php" ]] && echo "MISMATCH: $1 ($ext -> $mime)";;
        jpg|jpeg) [[ "$mime" != "image/jpeg" ]] && echo "MISMATCH: $1 ($ext -> $mime)";;
        png) [[ "$mime" != "image/png" ]] && echo "MISMATCH: $1 ($ext -> $mime)";;
    esac
' _ {} \;

# Using Python for extension analysis
python3 -c "
import os
for f in os.listdir('.'):
    ext = f.split('.')[-1] if '.' in f else 'none'
    print(f'{f}: extension={ext}')
"
```

### Phase 5: Binary Content Inspection

Inspect binary content for embedded code or anomalies.

```bash
# Search for embedded scripts
strings suspicious_file | grep -i "<script"
strings suspicious_file | grep -i "eval("
strings suspicious_file | grep -i "exec("

# Search for URLs
strings suspicious_file | grep -i "http"
strings suspicious_file | grep -i "ftp://"

# Search for file paths
strings suspicious_file | grep -i "/etc/passwd"
strings suspicious_file | grep -i "c:\\windows"

# Search for encoded content
strings suspicious_file | grep -i "base64"
strings suspicious_file | grep -i "\\x"
```

### Phase 6: Archive Analysis

Analyze archive files for security risks.

```bash
# List archive contents
unzip -l archive.zip
rar l archive.rar
7z l archive.7z
tar -tvf archive.tar

# Test archive integrity
unzip -t archive.zip
rar t archive.rar
7z t archive.7z

# Extract to temporary directory for analysis
mkdir /tmp/archive_analysis
unzip archive.zip -d /tmp/archive_analysis
rar x archive.rar /tmp/archive_analysis
7z x archive.7z -o/tmp/archive_analysis

# Check for path traversal
unzip -l archive.zip | grep "\.\./"

# Check archive size (compression bomb detection)
ls -la archive.zip
unzip -l archive.zip | tail -1
```

### Phase 7: Document Analysis

Analyze document files for embedded content and metadata.

```bash
# PDF analysis
pdfinfo document.pdf
pdftotext document.pdf - | head -20
pdfimages -list document.pdf
pdfdetach -list document.pdf

# Extract PDF metadata with Python
python3 -c "
import PyPDF2
reader = PyPDF2.PdfReader('document.pdf')
info = reader.metadata
for key, value in info.items():
    print(f'{key}: {value}')
"

# Office document analysis (unzip and inspect)
unzip -o document.docx -d /tmp/docx_analysis
cat /tmp/docx_analysis/word/document.xml | head -20

# Check for macros
olevba document.doc 2>/dev/null || echo "No macros found"

# Using exiftool for metadata
exiftool document.pdf
exiftool document.docx
```

### Phase 8: Image File Analysis

Analyze image files for metadata and steganography.

```bash
# EXIF metadata extraction
exiftool image.jpg
exiftool -a -u -g1 image.jpg

# Image dimensions and format
identify -verbose image.jpg 2>/dev/null | head -30
python3 -c "
from PIL import Image
img = Image.open('image.jpg')
print(f'Size: {img.size}')
print(f'Mode: {img.mode}')
print(f'Format: {img.format}')
"

# Check for embedded files
binwalk image.jpg

# Steganography detection
steghide info image.jpg 2>/dev/null
stegseek image.jpg 2>/dev/null

# Extract strings from images
strings image.jpg | head -50
```

## Tool Arsenal with Exact Commands

### file Command

```bash
# Basic file identification
file suspicious_file

# Detailed output
file -d suspicious_file

# MIME type only
file --mime-type suspicious_file

# MIME encoding
file --mime-encoding suspicious_file

# Check all files in directory
file *

# Check files recursively
find . -type f -exec file {} \;

# Check specific file types
find . -type f -name "*.php" -exec file {} \;
```

### exiftool

```bash
# Extract all metadata
exiftool file.jpg

# Extract specific tags
exiftool -Author -CreateDate -ModifyDate file.pdf

# Extract all metadata including duplicates
exiftool -a -u -g1 file.jpg

# Write metadata to file
exiftool -json file.jpg > metadata.json

# Remove all metadata
exiftool -all= file.jpg

# Copy metadata between files
exiftool -TagsFromFile source.jpg target.jpg
```

### binwalk

```bash
# Analyze file for embedded content
binwalk suspicious_file

# Extract embedded files
binwalk -e suspicious_file

# Recursively extract
binwalk -eM suspicious_file

# Scan for signatures
binwalk -B suspicious_file

# Entropy analysis
binwalk -E suspicious_file
```

### strings

```bash
# Extract printable strings
strings suspicious_file

# Minimum string length
strings -n 8 suspicious_file

# Extract strings with encoding
strings -e l suspicious_file  # 16-bit little-endian
strings -e b suspicious_file  # 16-bit big-endian

# Extract strings and count
strings suspicious_file | wc -l

# Extract and sort unique strings
strings suspicious_file | sort -u
```

### Python Magic

```bash
# Install python-magic
pip install python-magic

# Basic MIME type detection
python3 -c "
import magic
print(magic.from_file('suspicious_file'))
print(magic.from_file('suspicious_file', mime=True))
"

# Batch file type detection
python3 -c "
import magic
import os
for f in os.listdir('.'):
    if os.path.isfile(f):
        mime = magic.from_file(f, mime=True)
        print(f'{f}: {mime}')
"
```

### ImageMagick

```bash
# Identify image format and properties
identify -verbose image.jpg

# Get image dimensions
identify -format '%wx%h' image.jpg

# Convert between formats
convert image.jpg image.png

# Extract EXIF data
identify -verbose image.jpg | grep -i exif

# Check for image anomalies
identify -verbose image.jpg 2>&1 | grep -i "error\|warning"
```

### PDF Tools

```bash
# PDF information
pdfinfo document.pdf

# Extract text
pdftotext document.pdf output.txt

# List images
pdfimages -list document.pdf

# Extract embedded files
pdfdetach -list document.pdf
pdfdetach -saveall document.pdf -output /tmp/pdf_extracted

# Check for JavaScript
pdfjavascript document.pdf

# Repair corrupted PDF
qpdf --replace-input document.pdf
```

## Real-World Case Studies

### Case Study 1: PHP Webshell in Image EXIF Data

During a web application assessment, I discovered a file upload vulnerability that validated file types using only the Content-Type header. The application accepted image uploads and checked the MIME type in the request. By setting the Content-Type to `image/jpeg` and embedding PHP code in the EXIF metadata, I uploaded a functional PHP webshell. The file was stored with a `.jpg` extension and served as an image, but when accessed through a PHP include vulnerability, the embedded PHP code executed. The detection method was examining the file with `exiftool` which revealed the suspicious PHP code in the EXIF fields, and `php -l` which confirmed the code was valid PHP syntax.

### Case Study 2: Polyglot File for XSS

A web application displayed uploaded images directly in the browser without Content-Disposition headers. By creating a polyglot file that was valid as both a JPEG image and an HTML file, I achieved stored XSS. The file started with JPEG magic bytes but contained an HTML comment followed by a script tag after the image data. When the browser interpreted the file as HTML, it executed the JavaScript. The detection involved examining the file with `binwalk` which revealed the HTML content after the image data, and testing in a browser with Content-Type override.

### Case Study 3: Compression Bomb in Document Upload

An application accepted ZIP file uploads for document processing. By creating a ZIP file containing a 10MB file that compressed to 100 bytes due to repetitive content, I caused a denial of service when the server attempted to decompress the archive. The compressed file was 100 bytes but decompressed to 10GB, consuming all available disk space. The detection method involved checking the compression ratio with `unzip -l` which showed the extreme size difference, and analyzing the archive structure with `7z l` which revealed the decompressed size.

### Case Study 4: Macro-Enabled Document Disguised as PDF

During a phishing simulation, I discovered that the organization's email security filtered `.doc` and `.docm` files but not PDFs. By creating a PDF file containing an embedded JavaScript action that displayed a dialog asking the user to "enable content," I bypassed the email filter. The PDF was valid and passed through the security gateway, but when opened in Adobe Reader, it executed the JavaScript. The detection involved using `pdfinfo` which revealed the JavaScript action, and `pdftotext` which showed the social engineering text.

### Case Study 5: Archive Path Traversal

A web application extracted uploaded ZIP files to a temporary directory for processing. By creating a ZIP file with filenames containing `../../` path components, I was able to write files outside the intended extraction directory. This allowed overwriting configuration files and achieving remote code execution. The detection involved using `unzip -l` which revealed the path traversal in filenames, and testing extraction in a controlled environment to verify the vulnerability.

## Advanced Techniques and Bypass

### Double Extension Bypass

Some applications check only the last extension while the web server executes based on the first extension. A file named `image.php.jpg` may pass upload filters but be executed as PHP on Apache with certain configurations.

```bash
# Create files with double extensions
cp webshell.php image.php.jpg
cp webshell.php document.php.pdf

# Test Apache configuration for handling
curl -v https://target.com/uploads/image.php.jpg
```

### Null Byte Injection

Some legacy applications truncate filenames at null bytes. A file named `shell.php%00.jpg` may be processed as `shell.php` by vulnerable code while appearing as a JPEG to validation logic.

```bash
# Create file with null byte in name (Linux)
touch "shell.php$'\x00'.jpg"

# URL-encoded null byte
curl -F "file=@shell.php%00.jpg" https://target.com/upload
```

### Content-Type Manipulation

Modify Content-Type headers to bypass MIME type validation while maintaining actual file content.

```bash
# Upload PHP file with image MIME type
curl -F "file=@shell.php;type=image/jpeg" https://target.com/upload

# Upload with multiple Content-Type headers
curl -H "Content-Type: image/jpeg" -F "file=@shell.php" https://target.com/upload
```

### Magic Bytes Spoofing

Modify file headers to match expected magic bytes while maintaining executable content.

```bash
# Add PNG magic bytes to PHP file
printf '\x89\x50\x4e\x47' > shell.php.png
cat shell.php >> shell.php.png

# Add JPEG magic bytes to PHP file
printf '\xff\xd8\xff\xe0' > shell.php.jpg
cat shell.php >> shell.php.jpg
```

### Nested Archive Bypass

Embed malicious files within multiple archive layers to bypass scanning tools.

```bash
# Create nested archive
zip inner.zip shell.php
zip outer.zip inner.zip

# Extract recursively
unzip outer.zip -d /tmp/outer
unzip /tmp/outer/inner.zip -d /tmp/inner
```

### Unicode and Encoding Bypass

Use Unicode characters and encoding transformations to bypass file name filters.

```bash
# URL encode special characters
curl -F "file=@shell.php" https://target.com/upload?name=%73%68%65%6c%6c%2e%70%68%70

# Double URL encoding
curl -F "file=@shell.php" https://target.com/upload?name=%2573%2568%2565%256c%256c%252e%2570%2568%2570
```

## Detection and Indicators

### File Type Spoofing Detection

Monitor for the following indicators of file type manipulation:

- Mismatch between file extension and MIME type
- Unusual file headers for the declared type
- Embedded content that does not match the file format
- Extreme compression ratios in archive files
- Unusual metadata content in image or document files

### Server-Side Detection Methods

Applications can detect file type spoofing through:

- Magic byte validation regardless of extension
- Content-based analysis rather than header-based analysis
- Sandboxing file processing in isolated environments
- Using antivirus or malware scanning on uploaded files
- Implementing Content Security Policy headers

## Impact Assessment

### Finding Severity Classification

File type detection findings should be classified based on the potential impact:

- **Critical**: Executable code upload leading to remote code execution
- **High**: Cross-site scripting through document or image manipulation
- **Medium**: Information disclosure through metadata or embedded content
- **Low**: Denial of service through compression bombs or resource exhaustion
- **Informational**: Metadata exposure or file format inconsistencies

## Common Pitfalls

### Over-Reliance on Extensions

Many applications validate file types using only extensions, which can be trivially changed. Always validate file content using magic bytes and structural analysis.

### Ignoring MIME Type Headers

MIME types in HTTP headers can be manipulated. Never trust the Content-Type header alone for file validation.

### Not Testing for Polyglot Files

Polyglot files that are valid as multiple types can bypass many validation mechanisms. Test file handling with files that are valid as both images and scripts.

### Forgetting About Embedded Content

File formats like PDF and DOCX can contain embedded objects, scripts, and macros. Always examine the complete file structure, not just the primary content.

### Not Considering Context

The impact of file type detection varies based on context. A file uploaded to a web server has different implications than a file received via email or downloaded from a trusted source.

## Integration with Other Recon Areas

File type detection integrates with other reconnaissance activities:

- **Technology Stack Fingerprinting**: Understanding file handling reveals server configuration
- **Source Code Leak Detection**: Analyzing exposed files for sensitive content
- **Backup File Discovery**: Identifying backup file formats and contents
- **API Endpoint Discovery**: Understanding file upload and processing endpoints
- **Configuration File Extraction**: Analyzing configuration file formats and contents

## Reporting Template

### File Type Detection Report

**Executive Summary**: Overview of file type analysis activities and findings.

**Methodology**: Description of analysis techniques, tools used, and files examined.

**Findings Summary**:
- Total files analyzed
- Files with mismatched types
- Files containing embedded content
- Files with suspicious metadata

**Critical/High Findings**:
For each finding:
- File name and path
- Declared type vs actual type
- Embedded content description
- Potential security implications
- Recommended remediation

## Practice Labs

### Lab 1: Magic Bytes Identification

Practice identifying file types using magic bytes without relying on extensions. Create files with different extensions but incorrect magic bytes.

### Lab 2: File Type Spoofing

Practice creating spoofed files that bypass extension-based validation. Test against applications that validate file types.

### Lab 3: Archive Analysis

Practice analyzing archive files for security risks including compression bombs, path traversal, and nested archives.

### Lab 4: Document Metadata Extraction

Practice extracting metadata from various document formats and identifying sensitive information.

### Lab 5: Image Steganography Detection

Practice detecting steganography in image files using various analysis tools.

## Ethical Guidelines

File type detection should only be performed on files you own or have authorization to analyze. Extracting metadata from files without authorization may violate privacy laws. File type analysis should be used for security assessment purposes only, not for unauthorized access or data theft.

## Quick Reference Cheat Sheet

### File Type Commands
```bash
file suspicious_file                    # Basic type identification
file --mime-type suspicious_file        # MIME type only
xxd suspicious_file | head -5           # Magic bytes
strings suspicious_file                 # Extract strings
binwalk suspicious_file                 # Embedded content
exiftool suspicious_file                # Metadata
```

### Common Magic Bytes
```
89 50 4E 47    PNG image
FF D8 FF       JPEG image
25 50 44 46    PDF document
50 4B 03 04    ZIP archive
52 61 72 21    RAR archive
37 7A BC AF    7z archive
50 4B 03 04    Office Open XML
D0 CF 11 E0    OLE2 (DOC, XLS, PPT)
```

### Analysis Workflow
```bash
file -b <file>                          # Identify type
xxd -l 16 <file>                        # View header
strings <file> | head -20               # Extract strings
binwalk <file>                          # Find embedded
exiftool <file>                         # Read metadata
```