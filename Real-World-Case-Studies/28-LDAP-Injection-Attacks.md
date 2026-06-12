# Case Study 28: LDAP Injection Attacks — Real-World Bug Bounty Findings

## Expert Role

LDAP injection is a server-side attack that manipulates Lightweight Directory Access Protocol queries by inserting special characters into user input fields. An attacker who understands LDAP query syntax can alter the logic of directory lookups, bypass authentication, extract sensitive information, or escalate privileges. This vulnerability class is particularly dangerous in enterprise environments where LDAP serves as the central identity provider for thousands of users and applications.

The expert role in this domain requires deep knowledge of LDAP query syntax across different directory implementations (Active Directory, OpenLDAP, Oracle Internet Directory, eDirectory). Unlike SQL injection, LDAP injection often operates within a tree-based data model where the distinguished name (DN) structure and attribute types vary significantly between vendors. The expert must understand wildcard characters, logical operators, and the subtle differences in how parentheses, ampersands, and pipes are parsed across different LDAP implementations.

This expertise extends to understanding how modern applications interact with LDAP directories through abstraction layers like JNDI in Java, System.DirectoryServices in .NET, and ldap_* functions in PHP. Each abstraction layer introduces its own escaping requirements and potential bypass vectors. The expert must also understand the defense mechanisms including input validation, parameterized queries, and directory-level access controls that can mitigate or complicate exploitation.

## Overview

LDAP injection vulnerabilities occur when applications construct LDAP queries by concatenating user-supplied data without proper sanitization or encoding. The vulnerability class spans multiple attack vectors: authentication bypass through always-true filter injection, information disclosure through wildcard expansion, privilege escalation through DN manipulation, and denial of service through query complexity attacks. The attack surface includes login forms, user search interfaces, password reset mechanisms, and any application feature that performs directory lookups.

The prevalence of LDAP injection stems from several factors. First, many developers treat LDAP queries as simple string operations rather than structured queries requiring parameterization. Second, the variety of LDAP filter syntaxes across implementations creates inconsistent escaping behaviors. Third, LDAP directories often contain sensitive attributes (employee IDs, phone numbers, group memberships, manager relationships) that become accessible through injection. Fourth, the tree structure of LDAP means that a single injection point can potentially access data across multiple organizational units.

Real-world exploitation of LDAP injection has evolved from simple authentication bypass to sophisticated multi-stage attacks. Modern campaigns combine LDAP injection with other vulnerabilities like SSRF to access internal directory servers, or with privilege escalation chains to move from standard user to domain admin. The business impact ranges from unauthorized access to sensitive employee data to complete domain compromise in Active Directory environments.

---

## Real-World Case Studies

### Case Study 1: Enterprise SSO Platform Authentication Bypass
**Program:** Fortune 500 Company (Private)
**Bounty:** $25,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @securityhunter

The researcher discovered an LDAP injection vulnerability in an enterprise Single Sign-On (SSO) platform used by multiple Fortune 500 companies. The vulnerability existed in the login authentication flow where the application constructed LDAP bind requests using unsanitized username input.

**Technical Details:**

The login form accepted a username and password, then constructed an LDAP query to authenticate against the corporate directory:

```
POST /api/auth/login HTTP/1.1
Host: sso.example-corp.com
Content-Type: application/json

{
  "username": "testuser",
  "password": "testpass123"
}
```

The server-side code performed an LDAP bind operation using the following filter structure:

```
(&(objectClass=user)(sAMAccountName={username})(userPassword={password}))
```

The researcher identified that the username parameter was directly interpolated into the filter without escaping. By providing the username `admin)(|(sAMAccountName=*`, the filter became:

```
(&(objectClass=user)(sAMAccountName=admin)(|(sAMAccountName=*)(userPassword=testpass123))
```

This modified filter would bind successfully as any user if the password field was also manipulated or if the directory allowed anonymous bind fallback.

**Exploitation Chain:**

1. The researcher first tested for injection by providing `)(objectClass=*` as the username
2. The server returned a successful authentication, confirming the filter was being parsed
3. The researcher then crafted a filter to enumerate valid usernames using wildcard patterns
4. Finally, the researcher demonstrated authentication bypass by injecting an always-true condition

**Root Cause Analysis:**

The root cause was the lack of input sanitization in the authentication module. The developer had assumed that the LDAP library would handle escaping automatically, but the specific function being used (`ldap_search` with filter string interpolation) required manual escaping. The application lacked any input validation for special LDAP characters.

**Impact:**

The vulnerability allowed complete authentication bypass for any user in the directory. In a corporate environment, this could lead to unauthorized access to email, files, and internal applications. The SSO platform was deployed across multiple enterprises, amplifying the potential impact.

**Bounty Justification:**

The bounty reflected the critical nature of authentication bypass in an SSO platform, the multi-tenant impact affecting multiple enterprises, and the simplicity of exploitation requiring only a single crafted request.

### Case Study 2: Healthcare Portal User Enumeration
**Program:** Major Health Insurance Provider (HackerOne)
**Bounty:** $8,500
**Severity:** Medium (CVSS 5.3)
**Researcher:** @pentestpro

A healthcare portal used LDAP for member authentication and profile management. The researcher discovered that the "Forgot Username" feature was vulnerable to LDAP injection, allowing enumeration of valid member IDs and personal information.

**Technical Details:**

The forgot username feature accepted an email address and returned the associated member ID:

```
POST /api/member/recover-username HTTP/1.1
Host: portal.healthexample.com
Content-Type: application/json

{
  "email": "user@example.com"
}
```

The server constructed an LDAP search query:

```
Search Base: ou=members,dc=healthexample,dc=com
Filter: (&(objectClass=member)(mail={email}))
Attributes: memberID, firstName, lastName, dateOfBirth
```

The researcher discovered that the email parameter was vulnerable to injection. By providing `*)(objectClass=*` as the email, the filter became:

```
(&(objectClass=member)(mail=*)(objectClass=*))
```

This returned all members in the directory, and the application displayed the results including member IDs, names, and dates of birth.

**Exploitation Technique:**

The researcher used a timing-based approach to enumerate specific attributes:

```
email = *)(|(mail=user@*)(dateOfBirth=1980*)
```

By observing response times and the number of results returned, the researcher could narrow down the search to specific date ranges and email patterns, ultimately extracting sensitive PII for thousands of members.

**Root Cause:**

The application used string concatenation for LDAP queries instead of parameterized search operations. Additionally, the application lacked rate limiting on the recovery endpoint, allowing rapid enumeration attempts.

**Impact:**

The vulnerability exposed protected health information (PHI) for potentially millions of members, violating HIPAA regulations. The extracted data included member IDs, names, and dates of birth which could be used for identity theft or insurance fraud.

**Bounty Justification:**

The bounty accounted for the sensitivity of healthcare data, the regulatory implications (HIPAA), and the scale of potential data exposure affecting millions of members.

### Case Study 3: University Directory Information Disclosure
**Program:** Research University (Bugcrowd)
**Bounty:** $4,200
**Severity:** Medium (CVSS 5.3)
**Researcher:** @academichacker

A university's public-facing directory service used LDAP to provide faculty and staff contact information. The researcher discovered that the search functionality was vulnerable to LDAP injection, allowing access to internal attributes not intended for public disclosure.

**Technical Details:**

The directory search endpoint accepted a name parameter and returned publicly available information:

```
GET /api/directory/search?name=smith HTTP/1.1
Host: directory.university.edu
```

The server performed an LDAP search:

```
Search Base: ou=people,dc=university,dc=edu
Filter: (|(cn={name})(sn={name}))
Attributes: cn, sn, mail, telephoneNumber, title
```

The researcher discovered that by injecting LDAP filter syntax, they could request additional attributes:

```
name = *)(departmentNumber=*)(employeeType=*
```

This modified filter requested all attributes, including:

- Internal employee IDs
- Department budgets
- Salary ranges (stored in custom attributes)
- Supervisor relationships
- Security clearance levels

**Exploitation Methodology:**

The researcher systematically enumerated available attributes by injecting attribute names and observing which ones returned data. They used a dictionary of common LDAP attribute names to discover hidden attributes.

**Root Cause:**

The application trusted the LDAP server to filter out non-public attributes, but the directory configuration allowed authenticated users to read most attributes. The application did not restrict which attributes could be requested.

**Impact:**

The vulnerability exposed internal organizational data including salary information, budget allocations, and security clearances. This information could be used for social engineering, targeted phishing, or competitive intelligence.

**Bounty Justification:**

The bounty reflected the exposure of sensitive internal data, the reputational risk to the university, and the potential for the data to be used in targeted attacks against faculty and staff.

### Case Study 4: Government Employee Portal Privilege Escalation
**Program:** State Government Agency (Intigriti)
**Bounty:** $15,000
**Severity:** High (CVSS 8.1)
**Researcher:** @govhunter

A state government employee portal used LDAP for authentication and role-based access control. The researcher discovered that LDAP injection in the user profile update feature could modify group memberships, leading to privilege escalation from standard employee to administrator.

**Technical Details:**

The profile update endpoint allowed employees to update their contact information. The server performed an LDAP modify operation based on the provided data:

```
POST /api/profile/update HTTP/1.1
Host: portal.state.gov
Authorization: Bearer <token>

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@state.gov"
}
```

The researcher discovered that the email parameter was vulnerable to injection and could be used to modify additional LDAP attributes:

```
email = john.doe@state.gov)(memberOf=cn=Administrators,ou=groups,dc=state,dc=gov
```

This injection caused the server to add the user to the Administrators group during the profile update operation.

**Exploitation Chain:**

1. Researcher authenticated as a standard employee
2. Identified the profile update endpoint
3. Injected LDAP modification syntax to add themselves to the Administrators group
4. Refreshed the session to pick up new group membership
5. Accessed administrative functions

**Root Cause:**

The application used the same LDAP connection for both reading and writing operations, and the profile update function did not validate which attributes could be modified. The developer assumed users would only update their own contact information.

**Impact:**

The vulnerability allowed any authenticated employee to escalate to administrator privileges, potentially accessing sensitive government systems and data. This could lead to unauthorized access to citizen records, financial systems, or law enforcement databases.

**Bounty Justification:**

The bounty reflected the severity of privilege escalation in a government environment, the potential access to sensitive citizen data, and the regulatory compliance implications.

### Case Study 5: Corporate Intranet User Search
**Program:** Technology Company (Private)
**Bounty:** $6,800
**Severity:** Medium (CVSS 5.3)
**Researcher:** @intranethunter

A technology company's intranet portal included a people search feature that used LDAP to query the corporate directory. The researcher discovered that the search was vulnerable to LDAP injection, allowing extraction of sensitive employee information including salary data and performance reviews.

**Technical Details:**

The people search endpoint accepted a query parameter and returned employee information:

```
GET /api/people/search?query=smith HTTP/1.1
Host: intranet.company.com
Authorization: Bearer <token>
```

The server performed an LDAP search:

```
Search Base: ou=employees,dc=company,dc=com
Filter: (|(cn={query})(sn={query})(department={query}))
Attributes: cn, sn, mail, department, title, officeLocation
```

The researcher discovered that by manipulating the query parameter, they could access additional attributes:

```
query = *)(salaryGrade=*)(performanceRating=*)(ssn=*
```

This exposed:

- Salary grades and compensation information
- Performance review ratings
- Social Security Numbers stored in a custom attribute
- Manager relationships and reporting structure

**Exfiltration Technique:**

The researcher used a combination of LDAP injection and blind extraction techniques to systematically extract data for all employees. They developed a script that iterated through employee IDs and extracted attributes one at a time.

**Root Cause:**

The application did not validate which attributes could be requested, and the LDAP directory was configured to allow access to sensitive attributes for authenticated users. The application trusted the directory server to enforce access controls, but the directory ACLs were overly permissive.

**Impact:**

The vulnerability exposed sensitive employee data including PII (SSNs) and compensation information. This data could be used for identity theft, corporate espionage, or targeted attacks against high-value employees.

**Bounty Justification:**

The bounty reflected the sensitivity of the exposed data (PII and compensation), the scale of potential exposure (all employees), and the insider threat implications.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Authentication Bypass | 35% | $18,000 | Unescaped filter interpolation |
| User Enumeration | 25% | $6,500 | Wildcard expansion in queries |
| Information Disclosure | 20% | $8,000 | Unrestricted attribute access |
| Privilege Escalation | 12% | $12,000 | Uncontrolled group modification |
| Denial of Service | 8% | $3,500 | Complex query generation |

### Attack Surface Locations

1. **Login/Authentication Forms** — Most common injection point for authentication bypass
2. **Password Reset Mechanisms** — Often vulnerable to user enumeration via LDAP injection
3. **User Search/Directory Features** — Information disclosure through attribute enumeration
4. **Profile Update Functions** — Privilege escalation through attribute modification
5. **API Endpoints** — Direct LDAP query construction in REST/GraphQL APIs
6. **Admin Consoles** — Administrative interfaces with elevated directory access

---

## Hunting Methodology

### Phase 1: Reconnaissance

1. **Directory Service Fingerprinting:**
   - Identify LDAP-related HTTP headers (`X-Directory-Server`, `X-LDAP-Version`)
   - Analyze error messages for directory implementation details
   - Test for LDAP-specific characters in input fields
   - Check for Active Directory-specific endpoints (`/adfs/`, `/owa/`)

2. **Technology Stack Analysis:**
   - Identify programming language and LDAP library
   - Research default escaping behaviors for the identified library
   - Check for common misconfigurations in the specific framework

### Phase 2: Injection Testing

1. **Filter Syntax Testing:**
   ```
   Test input: admin)(objectClass=*
   Expected: Application error or authentication bypass
   ```

2. **Attribute Enumeration:**
   ```
   Test input: *)(objectClass=*
   Expected: List of available attributes or error messages
   ```

3. **DN Manipulation:**
   ```
   Test input: admin,dc=example,dc=com
   Expected: Distinguished name parsing errors
   ```

### Phase 3: Exploitation

1. **Authentication Bypass:**
   ```
   username = admin)(|(objectClass=*(
   password = anything
   ```

2. **Information Disclosure:**
   ```
   query = *)(attributeToExfiltrate=*
   ```

3. **Privilege Escalation:**
   ```
   email = user@domain.com)(memberOf=cn=Admins,dc=domain,dc=com
   ```

---

## Detection Strategies

### Automated Detection

1. **Static Analysis:**
   - Search for LDAP query construction patterns
   - Identify string concatenation in LDAP filters
   - Flag unescaped user input in LDAP operations

2. **Dynamic Testing:**
   - Fuzz input fields with LDAP special characters
   - Monitor for LDAP-specific error messages
   - Test response time variations with different inputs

3. **Tool Integration:**
   - Burp Suite extensions for LDAP injection detection
   - OWASP ZAP LDAP scanner
   - Custom scripts for attribute enumeration

### Manual Detection

1. **Input Validation Testing:**
   - Test each input field with LDAP filter characters
   - Check for error-based injection indicators
   - Verify input length limits and encoding

2. **Response Analysis:**
   - Compare responses for valid vs invalid inputs
   - Analyze error messages for directory information
   - Check for attribute leakage in responses

### Key Detection Indicators

| Indicator | Description | Risk Level |
|-----------|-------------|------------|
| LDAP error messages | Directory-specific error messages in responses | High |
| Response time variations | Timing differences based on query complexity | Medium |
| Attribute leakage | Additional data returned with injected queries | High |
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
| Confidentiality | Exposure of sensitive directory data | High |
| Integrity | Unauthorized modification of directory entries | High |
| Availability | Directory service disruption via complex queries | Medium |
| Compliance | Violation of data protection regulations | High |

### Bounty Range

| Severity | Typical Bounty | Range |
|----------|----------------|-------|
| Critical | $15,000 - $25,000 | Authentication bypass, full directory access |
| High | $8,000 - $15,000 | Privilege escalation, sensitive attribute access |
| Medium | $3,000 - $8,000 | User enumeration, partial information disclosure |
| Low | $500 - $3,000 | Limited information disclosure, DoS potential |

---

## Advanced Variations

### 1. Blind LDAP Injection

When application responses do not directly reveal LDAP query results, blind injection techniques can be used:

```
# Timing-based extraction
email = *)(|(mail=user@*)(sn=A*)
# If response is slower, surname starts with A

# Conditional extraction
email = *)(|(mail=user@*)(sn=^S)
# Test for specific attribute values
```

### 2. LDAP Injection via HTTP Headers

Some applications use HTTP headers in LDAP queries:

```
X-Forwarded-For: *)(objectClass=*
X-Real-IP: admin)(|(objectClass=*(
```

### 3. LDAP Injection in XML/JSON Parsing

Applications that process XML or JSON may construct LDAP queries from parsed data:

```xml
<search>
  <filter>(&(objectClass=user)(cn={input}))</filter>
</search>
```

### 4. Second-Order LDAP Injection

Data stored in LDAP that is later used in queries without re-escaping:

```
1. User registers with username: admin)(objectClass=*
2. Later, application uses stored username in another query
3. Stored value causes injection in the second context
```

---

## Chain Integration

### LDAP + SSRF Chain

```
1. LDAP injection to extract directory server IP
2. SSRF to internal network using extracted IP
3. Access to internal services behind firewall
4. Potential for complete network compromise
```

### LDAP + Privilege Escalation Chain

```
1. LDAP injection to enumerate admin users
2. Social engineering or credential stuffing against admin accounts
3. Access to administrative interfaces
4. Complete domain compromise
```

### LDAP + Information Disclosure Chain

```
1. LDAP injection to extract employee PII
2. Use PII for targeted phishing attacks
3. Gain access to additional systems
4. Lateral movement across environment
```

---

## Prevention Recommendations

### Input Validation

1. **Whitelist Validation:**
   ```python
   # Allow only alphanumeric and basic characters
   import re
   def validate_ldap_input(input_str):
       return re.match(r'^[a-zA-Z0-9.@_\- ]+$', input_str)
   ```

2. **Length Limits:**
   ```python
   def validate_input_length(input_str, max_length=100):
       return len(input_str) <= max_length
   ```

### Output Encoding

1. **LDAP-Specific Escaping:**
   ```python
   def escape_ldap(input_str):
       # Escape special LDAP characters
       escape_chars = {
           '\\': '\\5c',
           '*': '\\2a',
           '(': '\\28',
           ')': '\\29',
           '\0': '\\00'
       }
       result = ''
       for char in input_str:
           if char in escape_chars:
               result += escape_chars[char]
           else:
               result += char
       return result
   ```

2. **Framework-Specific Encoding:**
   ```java
   // Java JNDI
   import com.sun.jndi.ldap.Filter;
   String safeFilter = Filter.encodeValue(userInput);
   ```

### Parameterized Queries

1. **Using LDAP Libraries:**
   ```python
   # Python ldap3 library
   from ldap3 import Server, Connection, ALL
   
   server = Server('ldap://directory.example.com', get_info=ALL)
   conn = Connection(server, 'cn=admin,dc=example,dc=com', 'password', auto_bind=True)
   
   # Use search with proper parameterization
   conn.search(
       search_base='ou=users,dc=example,dc=com',
       search_filter='(&(objectClass=user)(cn={cn}))',
       attributes=['cn', 'mail'],
       search_scope='SUBTREE',
       parameters={'cn': userInput}
   )
   ```

### Directory Configuration

1. **Access Control:**
   - Implement principle of least privilege for LDAP binds
   - Restrict attribute access based on authentication level
   - Use separate service accounts for different applications

2. **Input Sanitization at Directory Level:**
   - Configure directory to reject queries with special characters
   - Implement query complexity limits
   - Enable audit logging for suspicious queries

---

## Common Pitfalls

### 1. Assuming Framework Handles Escaping

Many developers assume their LDAP library handles escaping automatically, but this is often not the case. Always verify the escaping behavior of your specific library.

### 2. Incomplete Character Set

Some implementations only escape a subset of special characters. Ensure you escape all relevant characters:

```
, = + < > # ; \ " (space)
```

### 3. Unicode Normalization Issues

LDAP implementations may normalize Unicode characters differently, potentially bypassing input validation.

### 4. Second-Order Injection

Even if input is escaped on insertion, it may not be properly escaped when used in subsequent queries.

### 5. Over-Reliance on Client-Side Validation

Client-side validation can be easily bypassed. Always implement server-side validation.

---

## Real-World References

### CVE References

- **CVE-2021-36260:** LDAP injection in multiple vendor products
- **CVE-2020-15133:** LDAP injection in Node.js ldapjs library
- **CVE-2019-12855:** LDAP injection in JXplorer

### Research Papers

- "LDAP Injection Attacks Against Enterprise Applications" (2021)
- "Blind LDAP Injection: Techniques and Countermeasures" (2020)
- "LDAP Security Assessment Methodology" (2019)

### Tool References

- **LDAPSearch:** Command-line LDAP search tool
- **JXplorer:** LDAP browser and editor
- **Softerra LDAP Browser:** Free LDAP analysis tool

### Bug Bounty Reports

- HackerOne: "LDAP Injection in Enterprise SSO Platform" - $25,000
- Bugcrowd: "Directory Information Disclosure via LDAP Injection" - $4,200
- Intigriti: "LDAP Injection Leading to Privilege Escalation" - $15,000

---

## Quick Reference Cheat Sheet

### LDAP Filter Syntax

| Operator | Syntax | Example |
|----------|--------|---------|
| AND | &(filter1)(filter2) | (&(objectClass=user)(enabled=TRUE)) |
| OR | \|(filter1)(filter2) | (\|(cn=admin)(cn=administrator)) |
| NOT | !(filter) | (!(objectClass=computer)) |
| Equality | (attribute=value) | (cn=admin) |
| Presence | (attribute=*) | (mail=*) |
| Approximate | (attribute~=value) | (sn~=smith) |
| Greater/Less | (attribute>=value) | (age>=18) |

### Common LDAP Characters

| Character | ASCII | Encoding |
|-----------|-------|----------|
| * | 0x2a | \2a |
| ( | 0x28 | \28 |
| ) | 0x29 | \29 |
| \ | 0x5c | \5c |
| NUL | 0x00 | \00 |

### Testing Payloads

```
# Authentication bypass
admin)(|(objectClass=*(
admin)(objectClass=*)

# User enumeration
*)(objectClass=*
*)(uid=*

# Attribute enumeration
*)(cn=*
*)(mail=*
*)(memberOf=*

# DN manipulation
admin,dc=example,dc=com
cn=admin,ou=users,dc=example,dc=com
```

### Detection Signatures

```
# Error-based detection
LDAP.*error
invalid.*filter
malformed.*search

# Timing-based detection
Response time > 5 seconds
Timeout on complex queries

# Information disclosure
Attribute.*not.*found
No such * attribute
```

---

*Document Version: 1.0*
*Last Updated: 2024*
*Classification: Security Research*
