# API Endpoint Discovery

## Expert Role Definition
You are an expert in API endpoint discovery and enumeration, specializing in identifying, mapping, and analyzing Application Programming Interfaces across web applications and services. Your primary role involves systematically discovering all API endpoints, understanding their structure, authentication mechanisms, and potential vulnerabilities. You possess deep knowledge of REST, GraphQL, SOAP, and other API architectures, including their documentation standards, versioning schemes, and security implementations. You are proficient with tools like ffuf, Arjun, parameth, Kiterunner, and custom scripts for API fuzzing and enumeration. You can identify API endpoints through multiple vectors: path fuzzing, parameter discovery, documentation exposure, JavaScript analysis, and traffic interception. You understand that APIs represent high-value attack surfaces because they often bypass client-side security controls and provide direct access to backend functionality. You think like an attacker who knows that APIs frequently expose more functionality than intended, leading to broken access control, mass assignment, and injection vulnerabilities. You continuously evolve your techniques as API architectures evolve toward GraphQL, gRPC, and serverless patterns. Your methodology emphasizes comprehensive endpoint coverage, authentication analysis, and documentation mapping. You understand that thorough API discovery is the foundation for API security testing and vulnerability research.

## Core Concepts Deep Dive
API endpoint discovery involves multiple complementary approaches. REST API discovery uses path fuzzing with wordlists to find endpoints like /api/v1/users, /api/admin/config, /graphql. GraphQL endpoint discovery targets /graphql, /graphiql, and similar paths, then uses introspection queries to map the entire schema. SOAP/WSDL discovery targets /wsdl, /service.wsdl, and SOAP endpoints that expose web service definitions. API documentation exposure searches for Swagger, OpenAPI, RAML, and API Blueprint files that list all endpoints. API versioning detection identifies version patterns in URLs (/api/v1, /api/v2) or headers (Accept-Version). Authentication mechanism discovery identifies API keys, OAuth tokens, JWT, Basic Auth, and other authentication methods used by APIs. Hidden API endpoints are endpoints not listed in documentation but accessible through direct requests. API rate limiting detection identifies throttling mechanisms that may be vulnerable to bypass. API version deprecation analysis tracks endpoint evolution and identifies legacy versions with known vulnerabilities. The goal is to build a complete API inventory including endpoints, methods, parameters, authentication, and documentation, understanding both intended and unintended functionality.

## Pre-requisite Knowledge
Before conducting API endpoint discovery, you need understanding of HTTP protocol including methods (GET, POST, PUT, DELETE, PATCH), status codes, headers, and request/response formats. Knowledge of REST architectural principles and common API patterns is essential. Understanding of GraphQL schema language, queries, mutations, and introspection is required. Familiarity with SOAP, WSDL, and XML-based web services is important. Knowledge of API authentication mechanisms (OAuth 2.0, JWT, API keys, Basic Auth) is critical. Understanding of API documentation standards (OpenAPI/Swagger, RAML, API Blueprint) helps in discovery. Experience with JSON and XML data formats for API request/response analysis is necessary. Knowledge of HTTP debugging tools (Burp Suite, Postman, curl) is essential. Understanding of web application architectures and how APIs integrate with front-end applications is valuable. Familiarity with rate limiting, throttling, and API security controls is important. Knowledge of fuzzing techniques and wordlist development aids in comprehensive discovery. Experience with traffic interception and analysis tools helps in understanding API behavior.

## Step-by-Step Methodology

### Phase 1: Documentation Discovery
1. **Swagger/OpenAPI Discovery**: Check common paths for API documentation: /swagger.json, /swagger-ui.html, /api-docs, /openapi.json, /api/swagger, /docs/api.

2. **GraphQL Playground Discovery**: Look for GraphQL IDEs: /graphiql, /graphql-playground, /altair, /graphql-explorer.

3. **WSDL Discovery**: Search for SOAP service definitions: /wsdl, /service.wsdl, /api/service, /soap, /service?wsdl.

4. **API Documentation Sites**: Check /docs, /api-docs, /documentation, /developer, /developer-docs for developer portals.

5. **Postman Collections**: Search for exported Postman collections in public repositories or documentation sites.

### Phase 2: Path Fuzzing and Enumeration
1. **API Path Discovery**: Use wordlists to fuzz common API paths: /api/, /v1/, /v2/, /graphql, /rest/, /service/.

2. **Method Testing**: Test discovered endpoints with different HTTP methods (GET, POST, PUT, DELETE) to identify allowed operations.

3. **Recursive Discovery**: Use discovered endpoints as seeds for further enumeration (e.g., /api/v1/users -> /api/v1/users/{id}/posts).

4. **Technology-Specific Paths**: Fuzz paths specific to detected frameworks: /wp-json/wp/v2/ (WordPress), /api/health (common health check).

5. **Status Code Analysis**: Analyze HTTP status codes to distinguish between valid endpoints (200, 301, 405) and non-existent paths (404).

### Phase 3: Parameter Discovery
1. **GET Parameter Discovery**: Use parameter fuzzing tools to discover URL parameters: ?id=1, ?page=1, ?search=test.

2. **POST Parameter Discovery**: Discover form data and JSON body parameters through fuzzing.

3. **Header Parameter Discovery**: Test for API key headers, custom authentication headers, and other header-based parameters.

4. **Cookie-Based Parameters**: Identify session tokens and other cookie-based parameters.

5. **GraphQL Variable Discovery**: Analyze GraphQL queries for variable definitions and input types.

### Phase 4: Authentication Mechanism Discovery
1. **Authentication Detection**: Identify authentication methods by analyzing error responses (401 Unauthorized, 403 Forbidden).

2. **Token Analysis**: Analyze JWT tokens, session tokens, and API keys for structure and potential weaknesses.

3. **OAuth Flow Detection**: Identify OAuth authorization and token endpoints.

4. **API Key Patterns**: Detect API key patterns in URLs, headers, and request bodies.

5. **Authentication Bypass Testing**: Test for authentication bypass through parameter manipulation or method changes.

### Phase 5: Versioning and Deprecation Analysis
1. **Version Pattern Detection**: Identify versioning patterns in URLs (/api/v1, /api/v2) and headers (Accept-Version).

2. **Legacy Version Discovery**: Search for older API versions that may have known vulnerabilities.

3. **Deprecation Headers**: Check for deprecation warnings in response headers.

4. **Version Comparison**: Compare functionality between API versions to identify security improvements or regressions.

5. **Sunset Header Analysis**: Look for Sunset headers indicating endpoint deprecation timelines.

### Phase 6: Rate Limiting and Security Control Analysis
1. **Rate Limit Detection**: Send multiple requests to identify rate limiting thresholds and mechanisms.

2. **Throttling Bypass Testing**: Test for rate limiting bypass techniques (header manipulation, IP rotation).

3. **Input Validation Analysis**: Analyze API responses to understand input validation mechanisms.

4. **Error Handling Analysis**: Study error responses for information disclosure and debug information.

5. **CORS Configuration**: Analyze Cross-Origin Resource Sharing configurations for misconfigurations.

### Phase 7: Comprehensive API Mapping
1. **Endpoint Inventory**: Compile complete list of all discovered endpoints with methods and parameters.

2. **Authentication Map**: Document authentication requirements for each endpoint.

3. **Data Flow Analysis**: Map data flow between endpoints and identify sensitive data exposure.

4. **Documentation Gaps**: Identify endpoints not covered by official documentation.

5. **Security Assessment**: Prioritize endpoints for security testing based on functionality and access requirements.

## Tool Arsenal with Exact Commands

### Path Fuzzing Tools
```
ffuf - Fast web fuzzer:
  ffuf -u https://TARGET_URL/api/FUZZ -w wordlists/api-paths.txt -mc 200,301,302,405
  ffuf -u https://TARGET_URL/api/v1/FUZZ -w wordlists/api-endpoints.txt -fs 4242
  ffuf -u https://TARGET_URL -H "Host: FUZZ.api.target.com" -w wordlists/subdomains.txt

gobuster - Directory and DNS brute-forcer:
  gobuster dir -u https://TARGET_URL -w wordlists/api-paths.txt -x json,xml,api
  gobuster dir -u https://TARGET_URL/api -w wordlists/api-endpoints.txt

dirsearch - Web path scanner:
  dirsearch -u https://TARGET_URL -e php,asp,aspx,jsp,api
  dirsearch -u https://TARGET_URL/api -w wordlists/api-paths.txt
```

### Parameter Discovery Tools
```
Arjun - HTTP parameter discovery:
  arjun -u https://TARGET_URL/api/endpoint
  arjun -u https://TARGET_URL/api/endpoint -m POST
  arjun -u https://TARGET_URL/api/endpoint -m JSON

parameth - Hidden parameter discovery:
  python parameth.py -u https://TARGET_URL/api/endpoint
  python parameth.py -u https://TARGET_URL/api/endpoint -m GET

x8 - Hidden parameter discovery:
  x8 -u https://TARGET_URL/api/endpoint -w wordlists/params.txt
```

### GraphQL Discovery Tools
```
GraphQL Scanner:
  python graphql_scanner.py -u https://TARGET_URL/graphql
  python graphql_introspection.py -u https://TARGET_URL/graphql

Clairvoyance - GraphQL schema recovery:
  clairvoyance -u https://TARGET_URL/graphql -o schema.graphql

catenum - GraphQL endpoint enumeration:
  catenum -u https://TARGET_URL -w wordlists/graphql-paths.txt
```

### API Documentation Discovery
```
Swagger Scanner:
  python swagger_scanner.py -u https://TARGET_URL
  curl -s https://TARGET_URL/swagger.json | jq .

OpenAPI Discovery:
  curl -s https://TARGET_URL/openapi.json | jq .
  curl -s https://TARGET_URL/api-docs | jq .

WSDL Discovery:
  curl -s https://TARGET_URL/service?wsdl
  curl -s https://TARGET_URL/wsdl
```

### Authentication Analysis
```
JWT Analysis:
  python jwt_tool.py -d TOKEN
  python jwt_tool.py -X a -k KEY -t TOKEN

API Key Detection:
  grep -r "api_key\|apikey\|api-key" TARGET_URL
  curl -H "X-API-Key: test" https://TARGET_URL/api/endpoint

OAuth Discovery:
  curl -s https://TARGET_URL/.well-known/oauth-authorization-server
  curl -s https://TARGET_URL/oauth/authorize
```

### Custom API Discovery Scripts
```
API endpoint discovery bash script:
#!/bin/bash
URL=$1
OUTPUT_DIR="api_$URL"
mkdir -p $OUTPUT_DIR

echo "[*] Checking for API documentation..."
for doc in swagger.json openapi.json api-docs docs/api swagger-ui.html; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/$doc")
  echo "$doc: $STATUS" >> $OUTPUT_DIR/documentation.txt
done

echo "[*] Fuzzing API paths..."
for path in api v1 v2 graphql rest service wsdl; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/$path")
  echo "/$path: $STATUS" >> $OUTPUT_DIR/paths.txt
done

echo "[*] Testing methods on discovered endpoints..."
while read -r endpoint; do
  for method in GET POST PUT DELETE OPTIONS; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X $method "$URL$endpoint")
    echo "$method $endpoint: $STATUS" >> $OUTPUT_DIR/methods.txt
  done
done < $OUTPUT_DIR/valid_endpoints.txt

echo "[+] API discovery complete. Results in $OUTPUT_DIR/"
```

## Real-World Case Studies

### Case Study 1: GraphQL Introspection Exploitation
A GraphQL endpoint was discovered at /graphql. Using introspection query, the researcher mapped the entire schema including hidden mutations for user management. The introspection revealed:
- Admin-only mutations accessible without authentication
- Internal user fields including password hashes
- Deprecated fields with weaker access controls
- Subscription endpoints for real-time data access
This led to a complete account takeover vulnerability through GraphQL mutation abuse.

### Case Study 2: API Versioning Vulnerability
REST API enumeration revealed multiple versions: /api/v1/, /api/v2/, /api/v3/. The older v1 version had:
- Weaker input validation enabling SQL injection
- Missing rate limiting on authentication endpoints
- Deprecated authentication method with known weaknesses
- Administrative functions accessible without proper authorization
Testing the deprecated v1 API revealed critical vulnerabilities patched in newer versions.

### Case Study 3: Swagger Documentation Exposure
API documentation was publicly accessible at /swagger-ui.html. The documentation listed:
- 150+ endpoints including internal admin APIs
- Detailed parameter schemas and response formats
- Authentication mechanisms and token formats
- Example values including test credentials
The exposed documentation provided a complete roadmap for attack, leading to multiple vulnerabilities including broken access control and mass assignment.

### Case Study 4: Parameter Pollution Attack
Parameter discovery revealed a search endpoint accepting multiple parameters. By manipulating parameter order and values, the researcher achieved:
- SQL injection through parameter pollution
- Authentication bypass by adding duplicate parameters
- Privilege escalation through parameter manipulation
- Data exfiltration via parameter-based blind injection
This demonstrated how parameter handling vulnerabilities can bypass security controls.

### Case Study 5: OAuth Misconfiguration Chain
OAuth endpoint discovery identified custom OAuth implementation flaws:
- Open redirect in authorization endpoint
- Token leakage through referrer headers
- Refresh token reuse without proper revocation
- Scope escalation through parameter manipulation
These vulnerabilities chained together enabled account takeover through OAuth token theft.

## Advanced Techniques and Bypass

### WAF Bypass for API Fuzzing
When WAFs block API fuzzing attempts:
- Use HTTP method variations (PATCH, OPTIONS, TRACE)
- Manipulate Content-Type headers
- Use encoding techniques for payloads
- Rotate User-Agent strings and source IPs
- Use timing variations to avoid rate limiting

### GraphQL-Specific Attacks
Advanced GraphQL attack techniques:
- Query batching to bypass rate limiting
- Alias abuse to execute multiple operations
- Directive injection for access control bypass
- Introspection denial bypass techniques

### API Mass Assignment Testing
Testing for mass assignment vulnerabilities:
- Add extra parameters in PUT/POST requests
- Include administrative fields (is_admin, role, id)
- Manipulate JSON structures to inject unexpected fields
- Test parameter pollution techniques

### Authentication Bypass Techniques
Common API authentication bypass methods:
- HTTP method override (X-HTTP-Method-Override)
- Path traversal in API endpoints
- Parameter pollution in authentication tokens
- JWT algorithm confusion attacks

### Rate Limiting Bypass
Techniques to bypass API rate limiting:
- IP rotation through proxies or VPNs
- Header manipulation (X-Forwarded-For, X-Real-IP)
- Distributed requests across multiple endpoints
- Timing attacks using request delays

### Server-Side Request Forgery (SSRF) via APIs
APIs that accept URLs or callbacks may be vulnerable to SSRF:
- Test URL parameters for internal network access
- Manipulate callback URLs to access internal services
- Use DNS rebinding to bypass network restrictions
- Exploit URL parsing inconsistencies

## Detection and Indicators

### API Discovery Detection Indicators
- Unusual path patterns indicating fuzzing activity
- High volume of 404 responses from single source
- Requests to common API documentation paths
- Parameter manipulation attempts in requests

### Rate Limiting and Throttling Indicators
- 429 Too Many Requests responses
- Progressive response delays
- CAPTCHA challenges on API endpoints
- Temporary IP blocking

### Security Control Indicators
- WAF logs showing blocked API requests
- Authentication failure patterns
- Input validation error responses
- CORS preflight request anomalies

### Behavioral Indicators
- Sequential endpoint enumeration patterns
- Systematic parameter testing
- API version probing
- Documentation discovery attempts

## Impact Assessment

### Attack Surface Exposure
- **Complete API Inventory**: Every discovered endpoint expands attack surface
- **Authentication Bypass**: Unprotected endpoints enable unauthorized access
- **Data Exposure**: API responses may leak sensitive information
- **Functionality Abuse**: Excessive functionality leads to business logic vulnerabilities

### Security Risk Factors
- **Broken Access Control**: APIs often have weak authorization checks
- **Mass Assignment**: Unintended parameters may be accepted and processed
- **Injection Vulnerabilities**: API inputs may not be properly sanitized
- **Information Disclosure**: Error messages and documentation reveal system details

### Risk Scoring
- **Critical**: Authentication bypass, SQL injection, remote code execution
- **High**: Broken access control, mass assignment, SSRF
- **Medium**: Information disclosure, rate limiting bypass, CORS misconfiguration
- **Low**: Version disclosure, documentation exposure, verbose errors

## Common Pitfalls

1. **Documentation Reliance**: Only testing endpoints listed in documentation, missing undocumented APIs
2. **Method Neglect**: Not testing all HTTP methods on discovered endpoints
3. **Parameter Blindness**: Not discovering hidden parameters that may be accepted
4. **Version Ignorance**: Not checking older API versions with weaker security
5. **Authentication Oversight**: Not properly analyzing authentication mechanisms
6. **GraphQL Underestimation**: Not performing comprehensive GraphQL schema analysis
7. **Rate Limit Blindness**: Not detecting and testing rate limiting mechanisms
8. **CORS Neglect**: Not analyzing Cross-Origin Resource Sharing configurations
9. **Error Analysis Gap**: Not analyzing error responses for information disclosure
10. **Documentation Exposure**: Not checking for publicly accessible API documentation
11. **Token Analysis**: Not properly analyzing JWT tokens and API keys
12. **WebSocket Ignorance**: Not discovering WebSocket endpoints and their security
13. **gRPC Blindness**: Not identifying gRPC services and their protobuf definitions
14. **Serverless Oversight**: Not discovering serverless function endpoints
15. **Scope Management**: Not properly scoping API testing within authorized boundaries

## Integration with Other Recon Areas

### Subdomain Enumeration Integration
- Discover API endpoints on all discovered subdomains
- Identify API-specific subdomains (api., graphql., wsdl.)
- Correlate subdomain findings with API endpoint discovery

### Technology Stack Fingerprinting
- Identify API frameworks and their specific vulnerabilities
- Detect API gateways and their configurations
- Correlate technology detection with API endpoint patterns

### JavaScript Source Analysis
- Extract API endpoints from JavaScript source code
- Identify API calls in minified JavaScript bundles
- Discover API endpoints through JavaScript analysis

### Configuration File Extraction
- Extract API keys and tokens from configuration files
- Identify API endpoint configurations in application settings
- Detect API documentation files in exposed directories

### Version Detection
- Identify API versions through endpoint patterns
- Detect version-specific vulnerabilities
- Track API evolution and deprecation patterns

## Reporting Template

### Executive Summary
- Total API endpoints discovered: [Number]
- Authentication mechanisms identified: [Number]
- Documentation exposure: [Yes/No]
- Critical API vulnerabilities: [Number]

### API Endpoint Inventory
| Endpoint | Method | Parameters | Authentication | Response Format | Risk |
|----------|--------|------------|----------------|-----------------|------|
| /api/v1/users | GET, POST | page, limit | JWT | JSON | Medium |
| /api/v1/admin/config | GET, PUT | config_key | API Key | JSON | High |
| /graphql | POST | query, variables | None | JSON | Critical |

### Authentication Analysis
| Mechanism | Type | Strength | Vulnerabilities | Risk |
|-----------|------|----------|-----------------|------|
| JWT | Token | Medium | Algorithm confusion | High |
| API Key | Header | Low | Predictable pattern | Medium |
| OAuth 2.0 | Code Flow | High | Open redirect | Low |

### Documentation Exposure
| Path | Content | Sensitive Info | Access Control | Risk |
|------|---------|----------------|----------------|------|
| /swagger.json | OpenAPI spec | Endpoints, params | None | High |
| /graphiql | GraphQL IDE | Schema, mutations | None | Critical |

### Vulnerability Findings
| Endpoint | Vulnerability | Impact | CVSS | Remediation |
|----------|--------------|--------|------|-------------|
| /api/v1/search | SQL Injection | Data breach | 9.8 | Input validation |
| /graphql | Broken Access | Privilege escalation | 8.5 | Authorization checks |
| /api/v1/users | Mass Assignment | Account takeover | 7.2 | Input filtering |

### Recommendations
1. Implement comprehensive API inventory and documentation
2. Enforce authentication and authorization on all API endpoints
3. Deploy API gateway with rate limiting and input validation
4. Implement API versioning with proper deprecation policies
5. Regular API security assessments and penetration testing

## Practice Labs

### Lab 1: REST API Discovery
**Objective**: Discover and enumerate REST API endpoints
**Tools**: ffuf, Arjun, curl
**Steps**:
1. Check for API documentation
2. Fuzz common API paths
3. Discover parameters
4. Test authentication mechanisms
**Expected Results**: Complete REST API inventory

### Lab 2: GraphQL Schema Mapping
**Objective**: Map complete GraphQL schema and identify vulnerabilities
**Tools**: GraphQL introspection, Clairvoyance, custom scripts
**Steps**:
1. Discover GraphQL endpoint
2. Perform introspection query
3. Map types, queries, mutations
4. Identify authorization issues
**Expected Results**: Complete GraphQL schema with security assessment

### Lab 3: API Authentication Testing
**Objective**: Test API authentication mechanisms for weaknesses
**Tools**: jwt_tool, custom scripts, Burp Suite
**Steps**:
1. Identify authentication mechanism
2. Analyze token structure
3. Test for bypass techniques
4. Document vulnerabilities
**Expected Results**: Authentication security assessment

### Lab 4: Rate Limiting Analysis
**Objective**: Analyze and test API rate limiting mechanisms
**Tools**: curl, custom scripts, Burp Suite
**Steps**:
1. Identify rate limiting thresholds
2. Test bypass techniques
3. Document rate limiting configuration
4. Assess security implications
**Expected Results**: Rate limiting security assessment

## Ethical Guidelines

### Legal Compliance
- Only test APIs within authorized scope
- Obtain explicit permission before API security testing
- Comply with API terms of service and rate limits
- Respect data privacy in API responses

### Responsible Testing
- Minimize impact on API availability during testing
- Do not exfiltrate sensitive data without authorization
- Report API vulnerabilities through responsible disclosure
- Do not disrupt API services through excessive testing

### Professional Standards
- Document all API testing activities for accountability
- Use established tools and methodologies for API assessment
- Provide actionable recommendations for API security improvement
- Maintain confidentiality of API vulnerability information

### Data Handling
- Do not store sensitive API data outside authorized environments
- Anonymize API data in reports where possible
- Securely delete API testing artifacts after engagement
- Comply with data retention policies for API assessments

## Quick Reference Cheat Sheet

### Documentation Discovery
```
curl -s https://TARGET_URL/swagger.json | jq .
curl -s https://TARGET_URL/openapi.json | jq .
curl -s https://TARGET_URL/api-docs | jq .
curl -s https://TARGET_URL/swagger-ui.html
```

### Path Fuzzing
```
ffuf -u https://TARGET_URL/api/FUZZ -w wordlists/api-paths.txt -mc 200,301,405
gobuster dir -u https://TARGET_URL/api -w wordlists/endpoints.txt -x json,api
dirsearch -u https://TARGET_URL -e api,php,json
```

### Parameter Discovery
```
arjun -u https://TARGET_URL/api/endpoint
arjun -u https://TARGET_URL/api/endpoint -m POST
parameth.py -u https://TARGET_URL/api/endpoint
```

### GraphQL Testing
```
curl -s -X POST https://TARGET_URL/graphql -d '{"query":"{__schema{types{name}}}"}'
curl -s -X POST https://TARGET_URL/graphql -d '{"query":"{__type(name:\"User\"){fields{name}}}"}'
```

### JWT Analysis
```
python jwt_tool.py -d TOKEN
python jwt_tool.py -X a -k KEY -t TOKEN
echo TOKEN | cut -d. -f2 | base64 -d 2>/dev/null
```

### API Method Testing
```
for method in GET POST PUT DELETE OPTIONS TRACE; do
  curl -s -o /dev/null -w "%{http_code}" -X $method https://TARGET_URL/api/endpoint
done
```

### Rate Limit Testing
```
for i in $(seq 1 100); do
  curl -s -o /dev/null -w "%{http_code}\n" https://TARGET_URL/api/endpoint
done
```