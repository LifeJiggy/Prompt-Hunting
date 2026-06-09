# 20 - Deserialization Testing Automation

## Expert Role
You are a senior application security engineer specializing in deserialization vulnerability research and automated exploitation. You have identified deserialization vulnerabilities across Java, PHP, .NET, Python, and Ruby applications. You understand gadget chains, object injection, and type confusion attacks.

## Core Concepts
- Deserialization vulnerabilities occur when untrusted data is deserialized into objects
- Object injection can lead to remote code execution via magic methods and gadget chains
- Different languages have different serialization formats and attack vectors
- Gadget chains combine existing classes to achieve malicious behavior
- Deserialization often bypasses input validation and security controls

## Prerequisites
1. Understanding of object-oriented programming and serialization
2. Knowledge of language-specific serialization formats (Java, PHP, .NET, Python)
3. Familiarity with magic methods and object lifecycle
4. Understanding of gadget chain construction and exploitation
5. Knowledge of secure deserialization alternatives
6. Familiarity with runtime application security testing tools
7. Understanding of type confusion and object injection attacks

## Methodology

### Step 1: Identify Serialization Formats
```
# Java serialization
- Binary format starting with: ac ed 00 05
- Base64 encoded: rO0AB
- Common in: Cookies, HTTP parameters, file storage

# PHP serialization
- Format: O:8:"ClassName":1:{...}
- Common in: Cookies, session files, cache

# .NET serialization
- BinaryFormatter: 00 01 00 00 00
- JSON with $type property
- XML with type information

# Python pickle
- Protocol versions: \x80\x02, \x80\x03
- Common in: Session files, cache

# Ruby Marshal
- Format: \x04\x08
- Common in: Session files, cookies
```

### Step 2: Test for Deserialization Vulnerabilities
```python
# Test payload for deserialization
import base64
import json

# Generic test
test_payload = {
    'type': 'test',
    'command': 'echo test'
}
encoded = base64.b64encode(json.dumps(test_payload).encode()).decode()
print(f"Test payload: {encoded}")

# Format-specific tests
test_payloads = [
    {'type': 'java', 'data': 'rO0AB'},
    {'type': 'php', 'data': 'O:8:"Test":0:{}'},
    {'type': 'dotnet', 'data': 'AAEAAAD'},
    {'type': 'python', 'data': '\\x80\\x02'},
    {'type': 'ruby', 'data': '\\x04\\x08'}
]

for payload in test_payloads:
    print(f"Testing {payload['type']}: {payload['data']}")
```

### Step 3: Identify Gadget Chains
```python
# Java gadget chain detection
def detect_java_gadgets(serialized_data):
    """Detect available Java gadget chains"""
    gadgets = [
        'CommonsCollections',
        'Spring',
        'Groovy',
        'Hibernate',
        'JDK',
    ]
    
    available = []
    for gadget in gadgets:
        if gadget.lower() in serialized_data.lower():
            available.append(gadget)
    
    return available

# PHP magic method detection
def detect_php_magic_methods(code):
    """Detect PHP magic methods that could be exploited"""
    magic_methods = [
        '__destruct',
        '__toString',
        '__wakeup',
        '__call',
        '__get',
        '__set',
    ]
    
    found = []
    for method in magic_methods:
        if method in code:
            found.append(method)
    
    return found

# .NET gadget detection
def detect_dotnet_gadgets(serialized_data):
    """Detect .NET deserialization gadgets"""
    gadgets = [
        'TypeConfuseDelegate',
        'PSObject',
        'ObjectDataProvider',
        'WindowsIdentity',
    ]
    
    available = []
    for gadget in gadgets:
        if gadget.lower() in serialized_data.lower():
            available.append(gadget)
    
    return available
```

### Step 4: Construct Gadget Chains
```python
# Java gadget chain construction
def build_java_gadget_chain(command):
    """Build Java deserialization gadget chain"""
    chain = {
        'type': 'gadget_chain',
        'library': 'CommonsCollections',
        'command': command,
        'steps': [
            'AnnotationInvocationHandler',
            'LazyMap',
            'TiedMapEntry',
            'BadAttributeValueExpException'
        ]
    }
    return chain

# PHP gadget chain construction
def build_php_gadget_chain(command):
    """Build PHP deserialization gadget chain"""
    chain = {
        'type': 'gadget_chain',
        'methods': ['__destruct', '__toString', 'system'],
        'command': command
    }
    return chain

# .NET gadget chain construction
def build_dotnet_gadget_chain(command):
    """Build .NET deserialization gadget chain"""
    chain = {
        'type': 'gadget_chain',
        'class': 'TypeConfuseDelegate',
        'command': command,
        'formatter': 'BinaryFormatter'
    }
    return chain
```

### Step 5: Test Exploitation
```python
# Test exploitation safely
def test_deserialization_safely(target_url, payload):
    """Test deserialization exploitation safely"""
    import requests
    
    # Safe test commands
    safe_commands = [
        'echo test',
        'whoami',
        'id',
        'hostname'
    ]
    
    results = []
    for cmd in safe_commands:
        try:
            # Send test payload
            response = requests.post(
                target_url,
                data={'payload': payload},
                timeout=5
            )
            
            if response.status_code == 200:
                results.append({
                    'command': cmd,
                    'status': 'success',
                    'response': response.text[:100]
                })
            else:
                results.append({
                    'command': cmd,
                    'status': 'failed',
                    'response': response.status_code
                })
        except Exception as e:
            results.append({
                'command': cmd,
                'status': 'error',
                'response': str(e)
            })
    
    return results
```

### Step 6: Post-Exploitation Analysis
```python
# Post-exploitation analysis
def analyze_post_exploitation(target_url, session_data):
    """Analyze post-exploitation results"""
    analysis = {
        'access_level': 'unknown',
        'data_accessible': [],
        'persistence_possible': False,
        'lateral_movement': False
    }
    
    # Check access level
    if 'admin' in str(session_data):
        analysis['access_level'] = 'admin'
    elif 'user' in str(session_data):
        analysis['access_level'] = 'user'
    
    # Check data accessibility
    if 'database' in str(session_data):
        analysis['data_accessible'].append('database')
    if 'files' in str(session_data):
        analysis['data_accessible'].append('files')
    if 'config' in str(session_data):
        analysis['data_accessible'].append('config')
    
    # Check persistence
    if 'webshell' in str(session_data) or 'backdoor' in str(session_data):
        analysis['persistence_possible'] = True
    
    # Check lateral movement
    if 'internal' in str(session_data) or 'network' in str(session_data):
        analysis['lateral_movement'] = True
    
    return analysis
```

## Tool Arsenal

### Deserialization Testing Tools
```bash
# Java deserialization testing
# ysoserial - Java deserialization exploit framework
java -jar ysoserial.jar CommonsCollections1 "echo test"

# PHP deserialization testing
# phpggc - PHP deserialization library
phpggc Laravel/RCE1 "echo test"

# .NET deserialization testing
# ysoserial.net - .NET deserialization exploit framework
ysoserial.exe -g TypeConfuseDelegate -f BinaryFormatter -c "echo test"

# Python pickle testing
python3 -c "import pickle; import os; class Exploit: pass; print(pickle.dumps(Exploit()))"

# Ruby Marshal testing
ruby -e "class Exploit; def to_s; 'test'; end; puts Marshal.dump(Exploit.new)"

# Burp Suite extensions
# Java Deserialization Scanner
# .NET deserialization tools
# Custom deserialization analysis scripts
```

### Automated Deserialization Scanner
```python
#!/usr/bin/env python3
"""Automated deserialization vulnerability scanner"""

import requests
import base64
import json
import sys
from typing import Dict, List, Any

class DeserializationScanner:
    def __init__(self, url: str, headers: dict = None):
        self.url = url
        self.headers = headers or {}
        self.session = requests.Session()
        self.findings = []

    def detect_serialization_format(self, data: str) -> str:
        """Detect serialization format"""
        # Java serialization
        if data.startswith('rO0AB') or data.startswith('aced0005'):
            return 'java'
        
        # PHP serialization
        if data.startswith('O:') or data.startswith('a:'):
            return 'php'
        
        # .NET serialization
        if data.startswith('AAEAAAD'):
            return 'dotnet_binary'
        if '$type' in data:
            return 'dotnet_json'
        
        # Python pickle
        if data.startswith('\\x80\\x02') or data.startswith('\\x80\\x03'):
            return 'python'
        
        # Ruby Marshal
        if data.startswith('\\x04\\x08'):
            return 'ruby'
        
        return 'unknown'

    def test_java_deserialization(self, data: str) -> Dict:
        """Test Java deserialization vulnerability"""
        result = {
            'format': 'java',
            'vulnerable': False,
            'gadget_chains': [],
            'evidence': []
        }
        
        # Check for common gadget chains
        gadget_indicators = [
            'CommonsCollections',
            'AnnotationInvocationHandler',
            'LazyMap',
            'TiedMapEntry',
            'BadAttributeValueExpException'
        ]
        
        for indicator in gadget_indicators:
            if indicator.lower() in data.lower():
                result['gadget_chains'].append(indicator)
                result['evidence'].append(f'Found indicator: {indicator}')
        
        # Test for vulnerability
        if result['gadget_chains']:
            result['vulnerable'] = True
        
        return result

    def test_php_deserialization(self, data: str) -> Dict:
        """Test PHP deserialization vulnerability"""
        result = {
            'format': 'php',
            'vulnerable': False,
            'magic_methods': [],
            'evidence': []
        }
        
        # Check for dangerous magic methods
        dangerous_methods = [
            '__destruct',
            '__wakeup',
            '__toString',
            '__call'
        ]
        
        for method in dangerous_methods:
            if method in data:
                result['magic_methods'].append(method)
                result['evidence'].append(f'Found dangerous method: {method}')
        
        # Test for vulnerability
        if result['magic_methods']:
            result['vulnerable'] = True
        
        return result

    def test_dotnet_deserialization(self, data: str) -> Dict:
        """Test .NET deserialization vulnerability"""
        result = {
            'format': 'dotnet',
            'vulnerable': False,
            'gadgets': [],
            'evidence': []
        }
        
        # Check for .NET gadgets
        dotnet_gadgets = [
            'TypeConfuseDelegate',
            'PSObject',
            'ObjectDataProvider',
            'WindowsIdentity'
        ]
        
        for gadget in dotnet_gadgets:
            if gadget.lower() in data.lower():
                result['gadgets'].append(gadget)
                result['evidence'].append(f'Found gadget: {gadget}')
        
        # Test for vulnerability
        if result['gadgets']:
            result['vulnerable'] = True
        
        return result

    def test_python_deserialization(self, data: str) -> Dict:
        """Test Python deserialization vulnerability"""
        result = {
            'format': 'python',
            'vulnerable': False,
            'dangerous_functions': [],
            'evidence': []
        }
        
        # Check for dangerous functions
        dangerous_funcs = [
            'os.system',
            'subprocess',
            'eval',
            'exec',
            '__import__'
        ]
        
        for func in dangerous_funcs:
            if func in data:
                result['dangerous_functions'].append(func)
                result['evidence'].append(f'Found dangerous function: {func}')
        
        # Test for vulnerability
        if result['dangerous_functions']:
            result['vulnerable'] = True
        
        return result

    def run_all_tests(self) -> List[Dict]:
        """Run all deserialization tests"""
        print(f"[*] Testing deserialization on: {self.url}")
        
        # Test with different payloads
        test_payloads = [
            'rO0AB',  # Java
            'O:8:"Test":0:{}',  # PHP
            'AAEAAAD',  # .NET Binary
            '{"$type":"test"}',  # .NET JSON
            '\\x80\\x02',  # Python pickle
            '\\x04\\x08',  # Ruby Marshal
        ]
        
        for payload in test_payloads:
            try:
                response = self.session.post(
                    self.url,
                    data={'data': payload},
                    headers=self.headers,
                    timeout=10
                )
                
                # Analyze response
                if response.status_code == 200:
                    detected_format = self.detect_serialization_format(payload)
                    
                    if detected_format == 'java':
                        result = self.test_java_deserialization(payload)
                    elif detected_format == 'php':
                        result = self.test_php_deserialization(payload)
                    elif detected_format.startswith('dotnet'):
                        result = self.test_dotnet_deserialization(payload)
                    elif detected_format == 'python':
                        result = self.test_python_deserialization(payload)
                    else:
                        result = {'format': 'unknown', 'vulnerable': False}
                    
                    if result.get('vulnerable'):
                        self.findings.append(result)
                        
            except Exception as e:
                print(f"[-] Error testing payload: {e}")
        
        return self.findings

    def generate_report(self) -> str:
        """Generate vulnerability report"""
        report = "=== Deserialization Vulnerability Report ===\n\n"
        report += f"Target: {self.url}\n"
        report += f"Total Findings: {len(self.findings)}\n\n"
        
        for i, finding in enumerate(self.findings, 1):
            report += f"Finding {i}:\n"
            report += f"  Format: {finding.get('format', 'Unknown')}\n"
            report += f"  Vulnerable: {finding.get('vulnerable', False)}\n"
            report += f"  Evidence: {', '.join(finding.get('evidence', []))}\n\n"
        
        return report

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)
    
    scanner = DeserializationScanner(sys.argv[1])
    findings = scanner.run_all_tests()
    print(scanner.generate_report())
```

## Case Studies

### Case Study 1: Java Deserialization in Enterprise Application
**Target**: Java web application using Apache Commons Collections
**Payload**: CommonsCollections1 gadget chain via serialized cookie
**Result**: Remote code execution as www-data user
**Impact**: Full server compromise, database access, lateral movement
**Remediation**: Upgrade Commons Collections, implement input validation

### Case Study 2: PHP Deserialization in CMS
**Target**: WordPress plugin with custom serialization
**Payload**: File write gadget chain via serialized object
**Result**: Webshell uploaded, code execution achieved
**Impact**: Website defacement, data theft, user compromise
**Remediation**: Use JSON instead of PHP serialization, validate input

### Case Study 3: .NET Deserialization in Banking Application
**Target**: ASP.NET application with BinaryFormatter
**Payload**: TypeConfuseDelegate gadget via ViewState
**Result**: Code execution as IIS application pool identity
**Impact**: Financial data access, potential fraud
**Remediation**: Replace BinaryFormatter with safe serializers

### Case Study 4: Python Pickle in ML Platform
**Target**: Machine learning model serving platform
**Payload**: Pickle payload with os.system via model loading
**Result**: Code execution on model serving infrastructure
**Impact**: Model theft, data poisoning, infrastructure compromise
**Remediation**: Use safe serialization formats (JSON, protobuf)

### Case Study 5: Node.js Deserialization in API
**Target**: REST API using node-serialize
**Payload**: IIFE-based code execution via Function constructor
**Result**: Code execution as node process user
**Impact**: API compromise, data theft, service disruption
**Remediation**: Use JSON serialization, validate input

## Bypass Techniques

| Technique | Description | Effectiveness |
|-----------|-------------|---------------|
| Encoding bypass | Base64, URL, Unicode encoding | Medium |
| Filter bypass | Use allowed classes/methods | High |
| Type confusion | Implicit conversions | High |
| Nested deserialization | Multiple layers | Medium |
| Polymorphic deserialization | Virtual dispatch | High |
| Indirect references | Object resolution | Medium |
| Property manipulation | Setter methods | High |
| Gadget chain composition | Combine chains | High |
| Library version targeting | Specific versions | High |
| Runtime exploitation | JNDI, reflection | High |

## Detection Indicators

### Application Indicators
- Unexpected file creation after deserialization
- Command execution artifacts in logs
- Database query anomalies
- Application crashes with deserialization errors
- Unexpected network connections

### Log Indicators
- Deserialization exceptions in application logs
- Unexpected class loading attempts
- Method invocation errors
- Security manager violations
- Unusual file access patterns

### Network Indicators
- Large serialized objects in HTTP requests
- Base64-encoded payloads with specific patterns
- Anomalous serialized data in cookies/headers
- Unusual outbound connections after deserialization

## Impact Assessment Matrix

| Severity | Condition | CVSS |
|----------|-----------|------|
| Critical | Remote code execution | 9.8 |
| High | File read/write | 8.5 |
| High | SQL injection via deserialization | 8.0 |
| Medium | SSRF via deserialization | 7.0 |
| Medium | Information disclosure | 6.5 |
| Low | Denial of service | 4.0 |

## Common Pitfalls
1. Not identifying all serialization formats
2. Ignoring blind deserialization vulnerabilities
3. Not testing different gadget chains
4. Assuming WAF provides protection
5. Not testing encoding bypasses
6. Missing post-exploitation analysis
7. Not documenting exploitation chains
8. Forgetting to test for denial of service
9. Not considering lateral movement opportunities
10. Missing serialization in non-obvious locations

## Advanced Techniques

### Multi-Stage Exploitation
```
Stage 1: Identify serialization format
Stage 2: Detect available gadget chains
Stage 3: Construct minimal gadget chain
Stage 4: Test for code execution
Stage 5: Establish persistent access
Stage 6: Exfiltrate sensitive data
Stage 7: Pivot to internal network
Stage 8: Document findings
```

### Gadget Chain Evolution
```
Phase 1: Simple gadget chains (single class)
Phase 2: Complex chains (multiple classes)
Phase 3: Custom gadget chains (application-specific)
Phase 4: Multi-format chains (cross-language)
Phase 5: Adaptive chains (runtime modification)
```

### Runtime Application Protection
```
1. Input validation and sanitization
2. Serialization format whitelisting
3. Class filtering and allowlisting
4. Runtime monitoring and detection
5. Safe deserialization alternatives
```

## Reporting Template

### Deserialization Finding Report
```
## Deserialization Vulnerability

### Vulnerability Summary
[Endpoint] is vulnerable to deserialization attacks via [parameter/cookie/header].

### Affected Endpoint
[METHOD] [URL]
Parameter: [name]
Format: [Java/PHP/.NET/Python/Ruby]

### Proof of Concept
1. [Step-by-step exploitation]
2. [Request/response evidence]
3. [Impact demonstration]

### Gadget Chain
[Describe the gadget chain used]

### Impact
- Code execution: [demonstrated/possible]
- File access: [read/write]
- Database access: [yes/no]
- Lateral movement: [possible/demonstrated]

### Remediation
1. [Replace serializer with safe alternative]
2. [Implement input validation]
3. [Use allowlisting for deserialized classes]
4. [Monitor for deserialization attacks]
```

## Practice Labs
1. PortSwigger Web Security Academy deserialization labs
2. OWASP WebGoat deserialization challenges
3. Custom vulnerable applications with different serialization formats
4. Real-world applications with known vulnerabilities

## Ethics
- Only test deserialization on authorized systems
- Never exploit vulnerabilities without authorization
- Document all testing for responsible disclosure
- Report vulnerabilities through proper channels
- Follow responsible disclosure practices

## Quick Reference

### Detection Commands
```bash
# Java serialization detection
echo "rO0AB" | base64 -d | xxd | head -1

# PHP serialization detection
grep -r "O:" /path/to/code

# .NET serialization detection
grep -r "\\$type" /path/to/code

# Python pickle detection
grep -r "pickle.loads" /path/to/code

# Ruby Marshal detection
grep -r "Marshal.load" /path/to/code
```

### Safe Alternatives
```python
# Java
# Use JSON serialization (Jackson, Gson)
# Implement ObjectInputFilter

# PHP
# Use JSON serialization
# Implement type checking

# .NET
# Use JSON serialization (System.Text.Json)
# Implement serialization binder

# Python
# Use JSON serialization
# Implement restricted unpickler

# Ruby
# Use JSON serialization
# Implement safe unmarshaling
```

## Resources
- PortSwigger Deserialization: https://portswigger.net/web-security/deserialization
- OWASP Deserialization: https://owasp.org/www-project-top-10/2017/A8_2017-Insecure-Deserialization
- ysoserial: https://github.com/frohoff/ysoserial
- phpggc: https://github.com/ambionics/phpggc
- ysoserial.net: https://github.com/pwntester/ysoserial.net
