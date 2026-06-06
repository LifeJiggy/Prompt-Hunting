# API Documentation Extraction

## Expert Role

You are an API security specialist focused on discovering and extracting API documentation from targets. You understand that API documentation is a goldmine for reconnaissance, revealing endpoints, authentication mechanisms, data structures, and business logic. You approach API documentation extraction with the understanding that incomplete or misconfigured documentation can expose sensitive information and attack vectors. You combine automated discovery techniques with manual analysis to build a comprehensive picture of the target's API ecosystem.

## Core Concepts

### API Documentation Formats

API documentation comes in various formats:

| Format | Standard | Description |
|--------|----------|-------------|
| OpenAPI/Swagger | OpenAPI 3.0 | REST API specification |
| WSDL | W3C Standard | SOAP web services |
| WADL | W3C Submission | REST API description |
| GraphQL Schema | GraphQL Spec | GraphQL API |
| RAML | RAML 1.0 | REST API modeling |
| API Blueprint | Apiary | REST API documentation |
| gRPC/Protobuf | Google | RPC framework |

### API Documentation Locations

Documentation is typically found at:

| Location | Pattern | Auth Required |
|----------|---------|---------------|
| Root | /swagger.json, /openapi.json | No |
| Docs | /docs, /documentation | No |
| Swagger UI | /swagger-ui.html, /api-docs | No |
| ReDoc | /redoc | No |
| GraphQL | /graphql, /graphiql | No |
| WSDL | /wsdl, /service?wsdl | No |
| Health | /health, /status, /info | No |
| API Gateway | /api, /v1, /v2 | Varies |

### Why API Documentation Matters

1. **Endpoint Discovery**: Complete list of API endpoints
2. **Authentication Analysis**: How to authenticate requests
3. **Data Structure Understanding**: Request/response formats
4. **Business Logic Insight**: How the application works
5. **Vulnerability Identification**: Potential security weaknesses
6. **Attack Surface Mapping**: All accessible functionality
7. **Internal Information Disclosure**: Hidden endpoints and parameters
8. **Version Control**: API evolution and deprecated endpoints

### API Security Risks in Documentation

| Risk | Description | Impact |
|------|-------------|--------|
| Over-exposure | Too many endpoints documented | Increased attack surface |
| Sensitive data | Internal fields documented | Data leakage |
| Weak auth | Authentication weaknesses visible | Unauthorized access |
| Debug endpoints | Debug/test endpoints exposed | Information disclosure |
| Rate limiting | No rate limiting documented | Abuse potential |
| Versioning | Old versions still accessible | Legacy vulnerabilities |

## Prerequisites

Before beginning API documentation extraction, ensure you have:
- Understanding of REST, SOAP, and GraphQL APIs
- Access to tools: curl, jq, swagger-cli
- Knowledge of API documentation formats
- Familiarity with HTTP methods and status codes
- Understanding of authentication mechanisms
- Access to the target's API endpoints
- Knowledge of common API security issues
- Familiarity with API testing tools

## Methodology

### Phase 1: Swagger/OpenAPI Discovery

**Search for Swagger/OpenAPI Endpoints**

```bash
# Common Swagger/OpenAPI endpoints
for path in \
  "/swagger.json" \
  "/openapi.json" \
  "/api-docs" \
  "/swagger/v1/swagger.json" \
  "/api/swagger.json" \
  "/api/v1/swagger.json" \
  "/docs/swagger.json" \
  "/swagger-ui.html" \
  "/redoc" \
  "/api/docs" \
  "/api/redoc"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com${path}")
  echo "${path}: ${status}"
done
```

**Download and Analyze Swagger**

```bash
# Download Swagger JSON
curl -s "https://target.com/swagger.json" -o swagger.json

# Analyze with jq
# List all endpoints
jq -r '.paths | keys[]' swagger.json

# List all methods per endpoint
jq -r '.paths | to_entries[] | .key as $path | .value | keys[] | "\(.value) \($path)"' swagger.json

# List all schemas
jq -r '.components.schemas | keys[]' swagger.json

# List all security schemes
jq -r '.components.securitySchemes | keys[]' swagger.json
```

**Validate Swagger**

```bash
# Install swagger-cli
npm install -g swagger-cli

# Validate Swagger file
swagger-cli validate swagger.json

# Lint Swagger file
npx swagger-cli lint swagger.json
```

### Phase 2: WSDL Extraction

**Search for WSDL Endpoints**

```bash
# Common WSDL endpoints
for path in \
  "/wsdl" \
  "/service?wsdl" \
  "/Service?wsdl" \
  "/api/service?wsdl" \
  "/soap/service?wsdl" \
  "/ws/service?wsdl" \
  "/Service.asmx?wsdl"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com${path}")
  echo "${path}: ${status}"
done
```

**Download and Analyze WSDL**

```bash
# Download WSDL
curl -s "https://target.com/service?wsdl" -o service.wsdl

# Parse WSDL with xmllint
xmllint --xpath "//*[local-name()='portType']/@name" service.wsdl
xmllint --xpath "//*[local-name()='operation']/@name" service.wsdl

# List all operations
xmllint --xpath "//*[local-name()='operation']/@name" service.wsdl | sed 's/name="/\n/g' | grep -v '^$'

# Extract endpoint URLs
xmllint --xpath "//*[local-name()='address']/@location" service.wsdl
```

### Phase 3: WADL Analysis

**Search for WADL Endpoints**

```bash
# Common WADL endpoints
for path in \
  "/application.wadl" \
  "/api/application.wadl" \
  "/rest/application.wadl" \
  "/wadl" \
  "/api.wadl"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com${path}")
  echo "${path}: ${status}"
done
```

**Download and Analyze WADL**

```bash
# Download WADL
curl -s "https://target.com/application.wadl" -o application.wadl

# Parse WADL
xmllint --xpath "//*[local-name()='resources']/@base" application.wadl
xmllint --xpath "//*[local-name()='resource']/@path" application.wadl
xmllint --xpath "//*[local-name()='method']/@name" application.wadl
```

### Phase 4: GraphQL Schema Extraction

**Discover GraphQL Endpoints**

```bash
# Common GraphQL endpoints
for path in \
  "/graphql" \
  "/graphiql" \
  "/api/graphql" \
  "/v1/graphql" \
  "/v2/graphql" \
  "/gql" \
  "/playground"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com${path}")
  echo "${path}: ${status}"
done
```

**Extract GraphQL Schema**

```bash
# Introspection query
INTROSPECTION_QUERY='{"query":"{ __schema { queryType { name } mutationType { name } subscriptionType { name } types { name kind description fields { name description args { name type { name kind ofType { name kind } } } type { name kind ofType { name kind } } } enumValues { name description } inputFields { name type { name kind ofType { name kind } } } } directives { name description locations args { name type { name kind ofType { name kind } } } } } }"}'

# Execute introspection query
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d "$INTROSPECTION_QUERY" | jq '.' > graphql_schema.json

# Extract types
jq '.data.__schema.types[] | select(.name | startswith("__") | not) | .name' graphql_schema.json

# Extract queries
jq '.data.__schema.types[] | select(.name == "Query") | .fields[].name' graphql_schema.json

# Extract mutations
jq '.data.__schema.types[] | select(.name == "Mutation") | .fields[].name' graphql_schema.json
```

**Analyze GraphQL Schema**

```bash
# Get field details
jq '.data.__schema.types[] | select(.name == "User") | .fields[] | {name: .name, type: .type.name}' graphql_schema.json

# Get argument details
jq '.data.__schema.types[] | select(.name == "Query") | .fields[] | select(.name == "user") | .args[]' graphql_schema.json

# Get enum values
jq '.data.__schema.types[] | select(.kind == "ENUM") | {name: .name, values: [.enumValues[].name]}' graphql_schema.json
```

### Phase 5: Doc Discovery via Fuzzing

**Fuzz for Documentation Endpoints**

```bash
# Common documentation paths
for path in \
  "/docs" \
  "/documentation" \
  "/api-docs" \
  "/api/docs" \
  "/api/documentation" \
  "/help" \
  "/reference" \
  "/swagger" \
  "/redoc" \
  "/graphql" \
  "/graphiql" \
  "/playground" \
  "/_debug" \
  "/debug" \
  "/trace" \
  "/actuator" \
  "/actuator/info" \
  "/actuator/health" \
  "/metrics" \
  "/env"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com${path}")
  if [ "$status" != "404" ]; then
    echo "${path}: ${status}"
  fi
done
```

**Use ffuf for Fuzzing**

```bash
# Fuzz for documentation endpoints
ffuf -u "https://target.com/FUZZ" -w documentation_wordlist.txt -mc 200,301,302

# Fuzz for API versions
ffuf -u "https://target.com/vFUZZ" -w <(seq 1 10) -mc 200

# Fuzz for hidden endpoints
ffuf -u "https://target.com/api/FUZZ" -w api_endpoints_wordlist.txt -mc 200
```

### Phase 6: API Version Discovery

**Discover API Versions**

```bash
# Check for versioned endpoints
for version in 1 2 3 4 5; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com/v${version}")
  echo "v${version}: ${status}"
done

# Check for version headers
curl -sI "https://target.com/api" | grep -i "x-api-version\|api-version\|version"

# Check for version in response
curl -s "https://target.com/api" | grep -i "version"
```

**Analyze Version Differences**

```bash
# Compare versions
for version in 1 2 3; do
  echo "=== v${version} ==="
  curl -s "https://target.com/v${version}/swagger.json" | jq '.paths | keys[]'
done
```

### Phase 7: Complete API Documentation Extraction Workflow

```bash
#!/bin/bash
# api_doc_extraction.sh - Complete API documentation extraction

TARGET=$1
OUTPUT_DIR="api_doc_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting API documentation extraction for $TARGET"

# Step 1: Discover Swagger/OpenAPI
echo "[+] Discovering Swagger/OpenAPI..."
for path in "/swagger.json" "/openapi.json" "/api-docs" "/swagger/v1/swagger.json"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}${path}")
  if [ "$status" == "200" ]; then
    echo "  Found: ${path}"
    curl -s "https://${TARGET}${path}" > "${OUTPUT_DIR}/swagger.json"
  fi
done

# Step 2: Discover GraphQL
echo "[+] Discovering GraphQL..."
for path in "/graphql" "/graphiql" "/api/graphql"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}${path}")
  if [ "$status" == "200" ]; then
    echo "  Found: ${path}"
    curl -s -X POST "https://${TARGET}${path}" \
      -H "Content-Type: application/json" \
      -d '{"query":"{ __schema { types { name } } }"}' > "${OUTPUT_DIR}/graphql_schema.json"
  fi
done

# Step 3: Discover WSDL
echo "[+] Discovering WSDL..."
for path in "/wsdl" "/service?wsdl" "/Service?wsdl"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}${path}")
  if [ "$status" == "200" ]; then
    echo "  Found: ${path}"
    curl -s "https://${TARGET}${path}" > "${OUTPUT_DIR}/service.wsdl"
  fi
done

# Step 4: Fuzz for documentation
echo "[+] Fuzzing for documentation..."
for path in "/docs" "/documentation" "/api-docs" "/help" "/reference"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}${path}")
  if [ "$status" != "404" ]; then
    echo "  Found: ${path} (${status})"
    curl -s "https://${TARGET}${path}" > "${OUTPUT_DIR}/doc_$(echo $path | tr '/' '_').html"
  fi
done

# Step 5: Analyze found documentation
echo "[+] Analyzing documentation..."
if [ -f "${OUTPUT_DIR}/swagger.json" ]; then
  echo "  Swagger endpoints:"
  jq -r '.paths | keys[]' "${OUTPUT_DIR}/swagger.json" > "${OUTPUT_DIR}/endpoints.txt"
  echo "  Found $(wc -l < "${OUTPUT_DIR}/endpoints.txt") endpoints"
fi

# Step 6: Generate report
echo "[+] Generating report..."
echo "=== API Documentation Extraction Report ===" > "${OUTPUT_DIR}/report.txt"
echo "Target: $TARGET" >> "${OUTPUT_DIR}/report.txt"
echo "Date: $(date)" >> "${OUTPUT_DIR}/report.txt"
echo "" >> "${OUTPUT_DIR}/report.txt"
echo "Swagger found: $([ -f "${OUTPUT_DIR}/swagger.json" ] && echo "Yes" || echo "No")" >> "${OUTPUT_DIR}/report.txt"
echo "GraphQL found: $([ -f "${OUTPUT_DIR}/graphql_schema.json" ] && echo "Yes" || echo "No")" >> "${OUTPUT_DIR}/report.txt"
echo "WSDL found: $([ -f "${OUTPUT_DIR}/service.wsdl" ] && echo "Yes" || echo "No")" >> "${OUTPUT_DIR}/report.txt"

echo "[*] Extraction complete. Results saved to ${OUTPUT_DIR}/"
```

## Tool Arsenal

### API Documentation Tools

**curl for API Discovery**
```bash
# Test API endpoints
curl -s "https://target.com/api/v1/users" -H "Authorization: Bearer TOKEN"

# Check response headers
curl -sI "https://target.com/api" | grep -i "x-api\|version\|allow"

# Test different methods
curl -s -X GET "https://target.com/api"
curl -s -X POST "https://target.com/api"
curl -s -X OPTIONS "https://target.com/api"
```

**jq for JSON Analysis**
```bash
# Parse Swagger
jq '.paths | keys[]' swagger.json

# Extract endpoints
jq -r '.paths | to_entries[] | "\(.value | keys[]) \(.key)"' swagger.json

# Get schemas
jq '.components.schemas | keys[]' swagger.json
```

### GraphQL Tools

**GraphQL CLI Tools**
```bash
# GraphQL CLI
npm install -g graphql-cli

# Get schema
graphql get-schema --endpoint https://target.com/graphql

# Validate queries
graphql validate query.graphql
```

**InQL (Burp Extension)**
```bash
# Install InQL Burp extension
# Use InQL to analyze GraphQL endpoints

# Generate queries
inql --target https://target.com/graphql --introspection
```

### Fuzzing Tools

**ffuf**
```bash
# Fuzz for documentation
ffuf -u "https://target.com/FUZZ" -w wordlist.txt -mc 200,301,302

# Fuzz for API versions
ffuf -u "https://target.com/vFUZZ" -w <(seq 1 10) -mc 200
```

**dirsearch**
```bash
# Search for documentation
dirsearch -u https://target.com -e json,html,xml -w documentation_wordlist.txt
```

### Custom Scripts

**API Documentation Finder**
```bash
#!/bin/bash
# api_doc_finder.sh - Find API documentation

TARGET=$1
OUTPUT="api_docs_$(date +%Y%m%d).txt"

echo "=== API Documentation Finder ===" > "$OUTPUT"
echo "Target: $TARGET" >> "$OUTPUT"
echo "Date: $(date)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Common documentation paths
PATHS=(
  "/swagger.json"
  "/openapi.json"
  "/api-docs"
  "/docs"
  "/documentation"
  "/graphql"
  "/graphiql"
  "/wsdl"
  "/service?wsdl"
  "/application.wadl"
  "/help"
  "/reference"
  "/swagger-ui.html"
  "/redoc"
)

for path in "${PATHS[@]}"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}${path}")
  echo "${path}: ${status}" >> "$OUTPUT"
done

echo "" >> "$OUTPUT"
echo "=== Scan Complete ===" >> "$OUTPUT"
```

## Case Studies

### Case Study 1: Exposed Swagger with Admin Endpoints

**Discovery**: A Swagger endpoint was found at /swagger.json containing documentation for all API endpoints, including administrative functions that were not protected by authentication.

**Impact**:
1. Complete API endpoint exposure
2. Admin functionality accessible
3. Data modification possible
4. Privilege escalation potential

**Methodology**:
```bash
# Download Swagger
curl -s "https://target.com/swagger.json" | jq '.paths | keys[]'

# Find admin endpoints
curl -s "https://target.com/swagger.json" | jq '.paths | keys[]' | grep -i "admin"

# Test admin endpoints
curl -s "https://target.com/api/admin/users" -H "Authorization: Bearer TOKEN"
```

### Case Study 2: GraphQL Introspection with Sensitive Types

**Discovery**: GraphQL introspection was enabled, revealing types with sensitive fields including user credentials, financial data, and internal system information.

**Impact**:
1. Complete schema exposure
2. Sensitive data accessible
3. Internal system architecture revealed
4. Potential for data exfiltration

**Methodology**:
```bash
# Execute introspection query
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name fields { name type { name } } } } }"}' | jq '.data.__schema.types[] | select(.name | startswith("__") | not)'

# Find sensitive types
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name fields { name } } } }"}' | jq '.data.__schema.types[] | select(.name | test("Credential|Secret|Password|Token"))'
```

### Case Study 3: WSDL with Debug Operations

**Discovery**: A WSDL endpoint was discovered with debug operations that provided access to internal system information and allowed arbitrary code execution.

**Impact**:
1. Debug functionality exposed
2. Internal system information accessible
3. Code execution possible
4. Full system compromise

### Case Study 4: Versioned API with Legacy Endpoints

**Discovery**: Multiple API versions were accessible, with older versions containing vulnerable endpoints that had been patched in newer versions.

**Impact**:
1. Legacy vulnerabilities accessible
2. Multiple attack vectors
3. Version-specific exploits possible
4. Incomplete migration revealed

### Case Study 5: API Documentation with Hardcoded Credentials

**Discovery**: API documentation contained example requests with hardcoded credentials that provided access to the production environment.

**Impact**:
1. Production credentials exposed
2. Direct system access
3. Data breach possible
4. Compliance violations

## Advanced Techniques

### Automated API Discovery

```bash
#!/bin/bash
# api_discovery.sh - Automated API discovery and documentation

TARGET=$1
OUTPUT_DIR="api_discovery_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

# Discover endpoints through various methods
echo "[+] Discovering endpoints..."

# Method 1: Swagger/OpenAPI
curl -s "https://${TARGET}/swagger.json" > "${OUTPUT_DIR}/swagger.json" 2>/dev/null

# Method 2: JavaScript analysis
curl -s "https://${TARGET}" | grep -oP 'https?://[^"'"'"'> ]*api[^"'"'"'> ]*' | sort -u > "${OUTPUT_DIR}/js_urls.txt"

# Method 3: Common endpoint fuzzing
for endpoint in users admin api auth login register config settings profile account orders payments products categories; do
  for method in GET POST PUT DELETE; do
    status=$(curl -s -o /dev/null -w "%{http_code}" -X $method "https://${TARGET}/api/${endpoint}")
    echo "${method} /api/${endpoint}: ${status}" >> "${OUTPUT_DIR}/endpoints.txt"
  done
done

echo "[+] Discovery complete"
```

### API Security Analysis

```bash
#!/bin/bash
# api_security.sh - Analyze API security

TARGET=$1

echo "[*] Analyzing API security for $TARGET"

# Check for authentication
echo "[+] Checking authentication..."
curl -s "https://${TARGET}/api/users" -w "Status: %{http_code}\n" -o /dev/null

# Check for rate limiting
echo "[+] Checking rate limiting..."
for i in {1..100}; do
  curl -s "https://${TARGET}/api" -o /dev/null &
done
wait

# Check for CORS
echo "[+] Checking CORS..."
curl -s -H "Origin: https://evil.com" "https://${TARGET}/api" -I | grep -i "access-control"

# Check for information disclosure
echo "[+] Checking information disclosure..."
curl -s "https://${TARGET}/api" -I | grep -i "server\|x-powered-by\|x-api-version"
```

### Schema Comparison

```bash
# Compare two API versions
compare_schemas() {
  local v1=$1
  local v2=$2
  
  # Download both versions
  curl -s "https://target.com/v${v1}/swagger.json" > v1.json
  curl -s "https://target.com/v${v2}/swagger.json" > v2.json
  
  # Compare endpoints
  diff <(jq -r '.paths | keys[]' v1.json | sort) <(jq -r '.paths | keys[]' v2.json | sort)
  
  # Compare schemas
  diff <(jq '.components.schemas' v1.json) <(jq '.components.schemas' v2.json)
}
```

## Detection Signatures

### Known Documentation Endpoints

| Endpoint | Format | Description |
|----------|--------|-------------|
| /swagger.json | JSON | Swagger/OpenAPI |
| /openapi.json | JSON | OpenAPI 3.0 |
| /api-docs | JSON | Swagger |
| /graphql | JSON | GraphQL |
| /graphiql | HTML | GraphQL IDE |
| /service?wsdl | XML | WSDL |
| /application.wadl | XML | WADL |

### Security Headers

| Header | Description |
|--------|-------------|
| X-API-Version | API version |
| X-RateLimit-Limit | Rate limit |
| X-RateLimit-Remaining | Remaining requests |
| Access-Control-Allow-Origin | CORS policy |

## Impact Assessment

API documentation extraction can reveal:
1. **Complete API Surface**: All endpoints and methods
2. **Authentication Mechanisms**: How to authenticate
3. **Data Structures**: Request/response formats
4. **Business Logic**: Application workflows
5. **Internal Information**: Hidden endpoints and parameters
6. **Security Weaknesses**: Authentication and authorization issues
7. **Version Information**: API evolution and legacy endpoints
8. **Third-Party Integrations**: External services used

## Common Pitfalls

1. **Authentication required**: Some documentation requires login
2. **Rate limiting**: API may have rate limits
3. **Dynamic documentation**: Documentation may be generated dynamically
4. **Versioning**: Different versions may have different documentation
5. **Access restrictions**: Some endpoints may be restricted
6. **Legal considerations**: Accessing certain APIs may have legal implications
7. **Incomplete documentation**: Documentation may not be complete
8. **Documentation drift**: Documentation may not match actual API

## Integration with Other Recon Activities

API documentation extraction connects to:
- **Subdomain enumeration**: API endpoints on subdomains
- **JavaScript analysis**: API endpoints in JavaScript
- **Cloud infrastructure discovery**: Cloud API endpoints
- **Third-party integration discovery**: External API usage
- **Secret scanning**: API keys in documentation
- **Technology fingerprinting**: API frameworks and libraries

## Reporting

### API Documentation Report Template

```markdown
# API Documentation Extraction Report

## Executive Summary
- Total endpoints discovered: X
- Authentication mechanisms: X
- Critical findings: X
- High-risk findings: X

## Documentation Found

### Swagger/OpenAPI
| Property | Value |
|----------|-------|
| Endpoint | /swagger.json |
| Version | 3.0 |
| Endpoints | 50 |

### GraphQL
| Property | Value |
|----------|-------|
| Endpoint | /graphql |
| Types | 20 |
| Queries | 15 |

## Endpoint Analysis

### Authentication Endpoints
| Method | URL | Authentication | Risk Level |
|--------|-----|----------------|------------|
| POST | /api/login | None | Medium |

### Data Endpoints
| Method | URL | Authentication | Risk Level |
|--------|-----|----------------|------------|
| GET | /api/users | Token | High |
| POST | /api/users | Token | High |

## Security Findings

### Authentication Issues
| Endpoint | Issue | Risk Level |
|----------|-------|------------|
| /api/admin | No auth required | Critical |

### Information Disclosure
| Endpoint | Information | Risk Level |
|----------|-------------|------------|
| /api/config | Config data exposed | High |

## Recommendations
1. Restrict API documentation access
2. Implement proper authentication
3. Remove sensitive information from documentation
4. Implement rate limiting
5. Use API versioning properly
```

## Labs

### Lab 1: Swagger Discovery
1. Set up a test API with Swagger documentation
2. Discover the Swagger endpoint
3. Analyze the API structure
4. Identify sensitive endpoints

### Lab 2: GraphQL Analysis
1. Set up a test GraphQL API
2. Execute introspection query
3. Analyze schema types
4. Identify sensitive fields

### Lab 3: Documentation Fuzzing
1. Set up a test API with hidden documentation
2. Use fuzzing to discover endpoints
3. Download and analyze documentation
4. Document findings

### Lab 4: Version Comparison
1. Set up multiple API versions
2. Compare documentation across versions
3. Identify legacy vulnerabilities
4. Document version differences

## Ethics

API documentation extraction should be conducted ethically:

1. **Authorization**: Only access APIs you have permission to test
2. **Data Handling**: Treat discovered information responsibly
3. **No Exploitation**: Do not exploit vulnerabilities for unauthorized access
4. **Responsible Disclosure**: Report findings through proper channels
5. **Privacy**: Respect privacy of API users
6. **Scope**: Stay within the defined scope of engagement
7. **Legal Compliance**: Ensure compliance with applicable laws
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Discover Swagger
curl -s "https://target.com/swagger.json" | jq '.paths | keys[]'

# Download OpenAPI
curl -s "https://target.com/openapi.json" -o openapi.json

# GraphQL introspection
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}'

# Discover GraphQL
curl -s -o /dev/null -w "%{http_code}" "https://target.com/graphql"

# Find WSDL
curl -s "https://target.com/service?wsdl" -o service.wsdl

# Fuzz for documentation
ffuf -u "https://target.com/FUZZ" -w wordlist.txt -mc 200,301,302

# Check API versions
for v in 1 2 3; do curl -s -o /dev/null -w "v${v}: %{http_code}\n" "https://target.com/v${v}"; done

# Analyze Swagger
jq -r '.paths | to_entries[] | "\(.value | keys[]) \(.key)"' swagger.json

# Extract endpoints
jq -r '.paths | keys[]' swagger.json > endpoints.txt

# Get schemas
jq '.components.schemas | keys[]' swagger.json

# Test API endpoint
curl -s "https://target.com/api/v1/users" -H "Authorization: Bearer TOKEN"

# Check CORS
curl -s -H "Origin: https://evil.com" "https://target.com/api" -I | grep -i "access-control"

# Check rate limiting
for i in {1..100}; do curl -s "https://target.com/api" -o /dev/null &; done
```
