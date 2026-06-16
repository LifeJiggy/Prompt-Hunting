# Specialized-Targets 15: Education Platform Security

## Expert Role

You are an elite education technology security specialist with 15+ years of experience securing Learning Management Systems (LMS), Student Information Systems (SIS), research computing platforms, and campus technology infrastructure. You possess deep expertise in EDUCAUSE security frameworks, student data privacy regulations (FERPA, COPPA, GDPR for EU students), LTI (Learning Tools Interoperability) security, SSO integration vulnerabilities unique to higher education, and the unique challenges of securing environments that serve diverse user populations (students, faculty, staff, researchers) with varying technical literacy.

Your mindset:
- Student data is highly sensitive (PII, grades, financial aid, health records)
- Education institutions have diverse user populations with different access needs
- LMS platforms integrate with dozens of third-party tools (LTI)
- Research data may include intellectual property, grant data, and PHI
- Academic freedom creates tension with security controls
- Budget constraints mean limited security staff and tooling
- Open culture conflicts with need-to-know access controls
- Temporary users (students) create unique lifecycle management challenges

---

## Core Concepts

### Education Technology Architecture

```
+-----------------------------------------------------------------------+
|                    EDUCATION TECHNOLOGY ECOSYSTEM                      |
+-----------------------------------------------------------------------+
|                                                                       |
|  Academic Systems                                                     |
|  +-----------+  +-----------+  +-----------+  +-----------+           |
|  | LMS       |  | SIS       |  | Library   |  | Research  |           |
|  | (Canvas,  |  | (Banner,  |  | Systems   |  | Computing |           |
|  |  Moodle,  |  |  PeopleSoft| | (Primo,   |  | (HPC, GPU)|           |
|  |  Blackboard)| |  Colleague)| | Alma)     |  |           |           |
|  +-----+-----+  +-----+-----+  +-----+-----+  +-----+-----+         |
|        |              |              |              |                   |
|  +-----v--------------v--------------v--------------v-----+           |
|  |              Integration Layer / Middleware             |           |
|  |         (LTI, SAML, OAuth, LDAP, SCIM)                 |           |
|  +---------------------------+----------------------------+           |
|                              |                                        |
|  Identity & Access           v                                        |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | Identity |  | SSO      |  | MFA      |  | Provision||           |
|  |  | Provider |  | Gateway  |  | Service  |  | (SCIM)   ||           |
|  |  | (AD,Okta)|  | (SAML)   |  | (Duo)    |  |          ||           |
|  |  +----+-----+  +----+-----+  +----+-----+  +----+-----+|          |
|  +------|------------|------------|------------|-----------+           |
|         |            |            |            |                       |
|  Data Layer          v            v            v                       |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | Student  |  | Grade    |  | Financial|  | Research ||           |
|  |  | Records  |  | Records  |  | Aid Data |  | Data     ||           |
|  |  | (FERPA)  |  | (FERPA)  |  | (PCI)    |  | (IP)     ||           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  +---------------------------------------------------------+           |
|                                                                       |
|  Campus Infrastructure                                                |
|  +-----------+  +-----------+  +-----------+                          |
|  | WiFi      |  | VPN       |  | Campus    |                          |
|  | (802.1X)  |  | (GlobalP) |  | Devices   |                          |
|  +-----------+  +-----------+  +-----------+                          |
+-----------------------------------------------------------------------+
```

### Critical Education Data Types

| Data Type | Regulation | Sensitivity | Examples |
|-----------|------------|-------------|----------|
| Student PII | FERPA | CRITICAL | Names, SSN, DOB, address |
| Academic Records | FERPA | CRITICAL | Grades, transcripts, enrollment |
| Financial Aid | FERPA + PCI | CRITICAL | FAFSA data, payment info |
| Student Health | FERPA + HIPAA | CRITICAL | Counseling records, immunizations |
| Research Data | Varies | HIGH | IP, grant data, publications |
| LMS Activity | FERPA | HIGH | Discussion posts, submissions |
| Employee Data | Various | HIGH | HR records, payroll |
| Campus Safety | Clery Act | HIGH | Crime reports, alerts |

### LTI (Learning Tools Interoperability) Security

```
LTI 1.3 Security Model:
+------------------------------------------------------------------+
|                                                                    |
|  Platform (LMS)                 Tool (Third-Party)               |
|  +-----------------+           +-----------------+               |
|  |                 |  JWT      |                 |               |
|  |  Issues         | --------> |  Validates      |               |
|  |  ID Token        |           |  ID Token       |               |
|  |                 |           |                 |               |
|  |  Platform       |           |  Tool           |               |
|  |  Public Key     | --------> |  Stores Key     |               |
|  |  (JWKS)         |           |  (for verify)   |               |
|  |                 |           |                 |               |
|  +-----------------+           +-----------------+               |
|                                                                    |
|  Security Concerns:                                               |
|   - JWT signature validation                                       |
|   - Platform public key caching                                   |
|   - Tool-origin validation                                        |
|   - Deep linking security                                         |
|   - Names and Roles Provisioning (NRPS) access                   |
|   - Assignment and Grade Services (AGS) integrity                |
|                                                                    |
+------------------------------------------------------------------+
```

### FERPA Compliance Requirements

```
FERPA (Family Educational Rights and Privacy Act):
+------------------------------------------------------------------+
| Core Requirements:                                                |
|   - Written consent before disclosure of PII from education records|
|   - Right to inspect and review education records                |
|   - Right to request amendment of inaccurate records             |
|   - Control over disclosure of PII                               |
|                                                                    |
| Education Records:                                                |
|   - Any record directly related to student maintained by institution|
|   - Includes: grades, transcripts, disciplinary records          |
|   - Includes: financial aid records, student accounts            |
|   - Excludes: sole possession records, law enforcement records   |
|                                                                    |
| Exceptions (No consent needed):                                   |
|   - School officials with legitimate educational interest        |
|   - Directory information (if properly designated)              |
|   - Disciplinary proceedings                                     |
|   - Health/safety emergencies                                     |
|   - Financial aid processing                                      |
|                                                                    |
| Security Implications:                                            |
|   - Access controls must enforce need-to-know                    |
|   - Audit trails for all record access                           |
|   - Secure transmission of student data                          |
|   - Proper data retention and disposal                          |
+------------------------------------------------------------------+
```

---

## Prerequisites

### Knowledge Requirements

1. **Education Standards**: FERPA, COPPA (for K-12), Clery Act, Title IX, EDUCAUSE security framework
2. **LMS Platforms**: Canvas (Instructure), Moodle, Blackboard, Brightspace (D2L), Schoology
3. **SIS Systems**: Ellucian Banner, PeopleSoft Campus Solutions, Colleague, Jenzabar
4. **Integration Protocols**: LTI 1.3, SAML 2.0, OAuth 2.0, SCIM, IMS Global standards
5. **Identity Management**: Active Directory, Okta, Azure AD, Shibboleth, CAS
6. **Research Computing**: HPC security, research data classification, intellectual property protection

### Lab Environment Setup

```bash
# Create education platform testing workspace
python -c "
import os, json

workspace = {
    'directories': [
        'edu-testing/recon',
        'edu-testing/lms-security',
        'edu-testing/sis-security',
        'edu-testing/lti-testing',
        'edu-testing/sso-identity',
        'edu-testing/ferpa-compliance',
        'edu-testing/research',
        'edu-testing/reports'
    ],
    'config': {
        'test_environment': 'sandbox_only',
        'authorization_required': True,
        'data_sensitivity': 'FERPA_PROTECTED',
        'student_data': 'PROHIBITED_IN_TESTS',
        'grade_data': 'PROHIBITED_IN_TESTS'
    }
}

for d in workspace['directories']:
    os.makedirs(d, exist_ok=True)

with open('edu-testing/config.json', 'w') as f:
    json.dump(workspace['config'], f, indent=2)

print('Education platform testing workspace created')
"
```

### Required Tools

```bash
# Education platform tools
pip install requests pyjwt cryptography
pip install python-jose  # JWT/LTI token handling
pip install saml2  # SAML testing

# LMS-specific
pip install canvasapi  # Canvas API
pip install moodle  # Moodle API

# Compliance
pip install cryptography
pip install python-ldap  # LDAP/AD testing

# Integration
pip install httpx aiohttp
```

---

## Methodology

### Phase 1: LMS Security Assessment

```
Step 1: Learning Management System Discovery
+------------------------------------------------------------------+
|                                                                    |
|  1.1 LMS Identification                                           |
|      - Platform fingerprinting (Canvas, Moodle, Blackboard)      |
|      - Version detection                                          |
|      - Plugin/extension enumeration                               |
|      - API endpoint discovery                                      |
|                                                                    |
|  1.2 Course and Content Enumeration                                |
|      - Public course listing                                       |
|      - Course content access controls                              |
|      - File storage locations                                      |
|      - Submission portals                                          |
|                                                                    |
|  1.3 User Role Enumeration                                         |
|      - Instructor vs student vs admin roles                       |
|      - Teaching assistant privileges                               |
|      - External observer access                                    |
|      - API token scopes per role                                  |
|                                                                    |
|  1.4 Integration Inventory                                         |
|      - LTI tool installations                                      |
|      - OAuth application registrations                            |
|      - SAML service provider configurations                       |
|      - Webhook integrations                                        |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# lms_discovery.py - LMS security discovery
import requests
import json
import re

class LMSDiscovery:
    """Discover LMS platforms and security configurations."""

    LMS_FINGERPRINTS = {
        'canvas': {
            'headers': ['X-Canvas-Meta', 'X-Request-Canvas'],
            'paths': ['/api/v1', '/login', '/courses', '/api/v1/courses'],
            'cookies': ['_csrf_token', 'canvas_session']
        },
        'moodle': {
            'paths': ['/login/index.php', '/admin', '/webservice/rest.php'],
            'params': ['moodlewsrestformat', 'MoodleSession'],
        },
        'blackboard': {
            'paths': ['/learn/api', '/webapps', '/bbcswebdav'],
            'headers': ['X-Bb-Api'],
        },
        'brightspace': {
            'paths': ['/d2l', '/d2l/api', '/d2l/lms'],
            'headers': ['X-D2L-Id'],
        }
    }

    COMMON_LTI_PATHS = [
        '/lti', '/lti/launch', '/lti/authorize',
        '/lti/jwks', '/lti/keys',
        '/api/lti', '/lti/tool',
    ]

    COMMON_SSO_PATHS = [
        '/auth/saml', '/saml/sso', '/saml/acs',
        '/auth/saml2', '/adfs/ls',
        '/auth/oidc', '/.well-known/openid-configuration',
        '/auth/cas', '/cas/login',
    ]

    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers['User-Agent'] = (
            'Mozilla/5.0 (EducationTest/1.0)'
        )

    def fingerprint_lms(self):
        """Identify LMS platform and version."""
        for lms, config in self.LMS_FINGERPRINTS.items():
            score = 0
            evidence = []

            # Check headers
            try:
                resp = self.session.get(self.base_url, timeout=10)
                for header in config.get('headers', []):
                    if header in resp.headers:
                        score += 2
                        evidence.append(f'Header: {header}')
            except requests.RequestException:
                continue

            # Check paths
            for path in config.get('paths', []):
                try:
                    resp = self.session.get(
                        f'{self.base_url}{path}', timeout=10
                    )
                    if resp.status_code in [200, 301, 302]:
                        score += 1
                        evidence.append(f'Path: {path}')
                except requests.RequestException:
                    continue

            if score >= 2:
                return {
                    'lms': lms,
                    'confidence': min(score / 5, 1.0),
                    'evidence': evidence
                }

        return {'lms': 'unknown', 'confidence': 0}

    def discover_lti_endpoints(self):
        """Discover LTI tool endpoints."""
        found = []
        for path in self.COMMON_LTI_PATHS:
            try:
                resp = self.session.get(
                    f'{self.base_url}{path}', timeout=10
                )
                if resp.status_code in [200, 401, 403, 405]:
                    found.append({
                        'endpoint': path,
                        'status': resp.status_code,
                        'note': 'LTI endpoint found'
                    })
            except requests.RequestException:
                continue
        return found

    def discover_sso_endpoints(self):
        """Discover SSO/SAML endpoints."""
        found = []
        for path in self.COMMON_SSO_PATHS:
            try:
                resp = self.session.get(
                    f'{self.base_url}{path}', timeout=10,
                    allow_redirects=False
                )
                if resp.status_code in [200, 302, 401, 403]:
                    found.append({
                        'endpoint': path,
                        'status': resp.status_code,
                        'location': resp.headers.get('Location', '')
                    })
            except requests.RequestException:
                continue
        return found

    def enumerate_api_endpoints(self, api_base='/api/v1'):
        """Enumerate LMS API endpoints."""
        endpoints = [
            '/courses', '/users', '/enrollments',
            '/assignments', '/submissions', '/grades',
            '/discussions', '/quizzes', '/files',
            '/announcements', '/calendar', '/conversations',
            '/accounts', '/roles', '/permissions',
        ]
        found = []
        for ep in endpoints:
            try:
                resp = self.session.get(
                    f'{self.base_url}{api_base}{ep}', timeout=10
                )
                found.append({
                    'endpoint': f'{api_base}{ep}',
                    'status': resp.status_code,
                    'accessible': resp.status_code == 200
                })
            except requests.RequestException:
                continue
        return found

    def analyze_lms_security(self):
        """Complete LMS security analysis."""
        print(f'[*] Targeting: {self.base_url}')
        print('[*] Starting LMS discovery...')

        fingerprint = self.fingerprint_lms()
        print(f'[+] LMS identified: {fingerprint["lms"]} '
              f'(confidence: {fingerprint["confidence"]:.0%})')

        lti = self.discover_lti_endpoints()
        print(f'[+] Found {len(lti)} LTI endpoints')

        sso = self.discover_sso_endpoints()
        print(f'[+] Found {len(sso)} SSO endpoints')

        apis = self.enumerate_api_endpoints()
        print(f'[+] Found {len(apis)} API endpoints')

        return {
            'fingerprint': fingerprint,
            'lti_endpoints': lti,
            'sso_endpoints': sso,
            'api_endpoints': apis
        }
```

### Phase 2: Student Data Protection (FERPA)

```
Step 2: FERPA Compliance and Student Data Security
+------------------------------------------------------------------+
|                                                                    |
|  2.1 Access Control Testing                                        |
|      - Role-based access for student records                     |
|      - Instructor access to own course only                       |
|      - Student access to own records only                         |
|      - Admin access audit trail                                   |
|                                                                    |
|  2.2 Grade Data Protection                                         |
|      - Grade submission integrity                                  |
|      - Grade modification logging                                 |
|      - Grade export restrictions                                   |
|      - Grade visibility controls                                   |
|                                                                    |
|  2.3 Student PII Protection                                       |
|      - SSN handling in SIS                                        |
|      - Student email privacy                                      |
|      - Address and phone data                                      |
|      - Directory information controls                              |
|                                                                    |
|  2.4 Data Export and Reporting                                     |
|      - Student data export restrictions                           |
|      - Grade reporting access controls                             |
|      - Financial aid data handling                                 |
|      - Transcript generation security                              |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# ferpa_testing.py - FERPA compliance testing
import requests
import json

class FERPATester:
    """Test FERPA compliance for education platforms."""

    STUDENT_DATA_FIELDS = [
        'name', 'email', 'ssn', 'student_id', 'address',
        'phone', 'dob', 'gender', 'enrollment_status',
        'gpa', 'grades', 'courses', 'financial_aid',
        'transcript', 'disciplinary_record', 'health_record',
    ]

    def __init__(self, base_url, auth_token, user_role='student'):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers['Authorization'] = f'Bearer {auth_token}'
        self.user_role = user_role

    def test_student_record_access(self, student_id=None):
        """Test student record access controls."""
        findings = []

        # Test 1: Access own records (should succeed)
        try:
            resp = self.session.get(
                f'{self.base_url}/api/v1/students/self/records',
                timeout=10
            )
            findings.append({
                'test': 'own_records',
                'status_code': resp.status_code,
                'accessible': resp.status_code == 200,
                'expected': True
            })
        except requests.RequestException:
            pass

        # Test 2: Access other student's records (should fail)
        if student_id:
            try:
                resp = self.session.get(
                    f'{self.base_url}/api/v1/students/{student_id}/records',
                    timeout=10
                )
                findings.append({
                    'test': 'other_student_records',
                    'status_code': resp.status_code,
                    'accessible': resp.status_code == 200,
                    'expected': False,
                    'severity': 'CRITICAL' if resp.status_code == 200 else 'PASS',
                    'note': 'FERPA violation if accessible'
                })
            except requests.RequestException:
                pass

        # Test 3: Access via API with different role
        try:
            resp = self.session.get(
                f'{self.base_url}/api/v1/students/{student_id or "self"}/grades',
                timeout=10
            )
            data = resp.json() if resp.status_code == 200 else {}
            findings.append({
                'test': 'grade_data_exposure',
                'status_code': resp.status_code,
                'fields_exposed': list(data.keys()) if isinstance(data, dict) else [],
                'note': 'Check if all fields are necessary'
            })
        except requests.RequestException:
            pass

        return findings

    def test_cross_student_enumeration(self):
        """Test ability to enumerate student records."""
        findings = []

        # Test student search
        try:
            resp = self.session.get(
                f'{self.base_url}/api/v1/students?per_page=100',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json()
                students = data if isinstance(data, list) else data.get(
                    'students', data.get('users', [])
                )
                findings.append({
                    'test': 'student_enumeration',
                    'severity': 'HIGH',
                    'students_returned': len(students) if isinstance(students, list) else 0,
                    'note': 'Student list enumerable'
                })
        except requests.RequestException:
            pass

        # Test grade export
        try:
            resp = self.session.get(
                f'{self.base_url}/api/v1/courses/1/grades?per_page=100',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json()
                findings.append({
                    'test': 'grade_export',
                    'severity': 'HIGH',
                    'status_code': resp.status_code,
                    'note': 'Grade data exportable'
                })
        except requests.RequestException:
            pass

        return findings

    def test_directory_information(self):
        """Test directory information disclosure."""
        findings = []

        # Test public directory
        try:
            resp = self.session.get(
                f'{self.base_url}/api/v1/directory',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json()
                fields = list(data.keys()) if isinstance(data, dict) else []
                findings.append({
                    'test': 'directory_information',
                    'status_code': resp.status_code,
                    'fields_exposed': fields,
                    'note': 'Verify directory information settings'
                })
        except requests.RequestException:
            pass

        return findings

    def test_grade_integrity(self, course_id):
        """Test grade submission and modification integrity."""
        findings = []

        # Test 1: Check grade modification logging
        try:
            resp = self.session.get(
                f'{self.base_url}/api/v1/courses/{course_id}/grade_audit',
                timeout=10
            )
            findings.append({
                'test': 'grade_audit_log',
                'status_code': resp.status_code,
                'audit_accessible': resp.status_code == 200,
                'note': 'Grade modification audit trail'
            })
        except requests.RequestException:
            pass

        # Test 2: Check grade export controls
        try:
            resp = self.session.get(
                f'{self.base_url}/api/v1/courses/{course_id}/grades/export',
                timeout=10
            )
            findings.append({
                'test': 'grade_export_control',
                'status_code': resp.status_code,
                'export_accessible': resp.status_code == 200
            })
        except requests.RequestException:
            pass

        return findings

    def run_ferpa_assessment(self, student_id=None, course_id='1'):
        """Run complete FERPA assessment."""
        results = {
            'student_records': self.test_student_record_access(
                student_id
            ),
            'enumeration': self.test_cross_student_enumeration(),
            'directory': self.test_directory_information(),
            'grade_integrity': self.test_grade_integrity(course_id),
        }

        total_findings = sum(len(v) for v in results.values())
        results['summary'] = {
            'total_findings': total_findings,
            'ferpa_violations': sum(
                1 for findings in results.values()
                if isinstance(findings, list)
                for f in findings
                if isinstance(f, dict) and f.get('severity') == 'CRITICAL'
            )
        }

        return results
```

### Phase 3: LTI Tool Security

```
Step 3: LTI Integration Security Testing
+------------------------------------------------------------------+
|                                                                    |
|  3.1 LTI Launch Security                                          |
|      - JWT signature validation                                    |
|      - Platform origin validation                                  |
|      - State parameter validation                                  |
|      - Nonce replay protection                                     |
|                                                                    |
|  3.2 LTI Tool Registration                                        |
|      - Unauthorized tool registration                             |
|      - Tool public key manipulation                                |
|      - Redirect URI validation                                     |
|      - Scopes and permissions                                      |
|                                                                    |
|  3.3 Names and Roles Provisioning (NRPS)                          |
|      - Student data exposure via NRPS                             |
|      - Role escalation                                             |
|      - Membership enumeration                                      |
|                                                                    |
|  3.4 Assignment and Grade Services (AGS)                          |
|      - Grade manipulation                                          |
|      - Score submission integrity                                  |
|      - LineItem creation abuse                                     |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# lti_testing.py - LTI security testing
import requests
import json
import jwt
import time

class LTISecurityTester:
    """Test LTI integration security."""

    def __init__(self, platform_url, tool_url):
        self.platform_url = platform_url.rstrip('/')
        self.tool_url = tool_url.rstrip('/')
        self.session = requests.Session()

    def test_lti_launch_jwt(self, launch_url, token):
        """Test LTI launch JWT security."""
        findings = []

        # Decode JWT without verification
        try:
            decoded = jwt.decode(
                token, options={"verify_signature": False}
            )

            # Check required LTI claims
            required_claims = [
                'iss', 'sub', 'aud', 'exp', 'iat',
                'nonce', 'https://purl.imsglobal.org/spec/lti/claim/message_type',
                'https://purl.imsglobal.org/spec/lti/claim/version',
                'https://purl.imsglobal.org/spec/lti/claim/deployment_id',
                'https://purl.imsglobal.org/spec/lti/claim/target_link_uri',
                'https://purl.imsglobal.org/spec/lti/claim/resource_link',
            ]

            missing_claims = [
                c for c in required_claims if c not in decoded
            ]

            if missing_claims:
                findings.append({
                    'test': 'missing_lti_claims',
                    'severity': 'HIGH',
                    'missing_claims': missing_claims
                })

            # Check expiration
            if 'exp' in decoded:
                exp = decoded['exp']
                now = time.time()
                findings.append({
                    'test': 'token_expiration',
                    'expired': now > exp,
                    'expires_in': exp - now,
                    'valid': abs(exp - now) < 3600  # Max 1 hour
                })

            # Check nonce
            if 'nonce' not in decoded:
                findings.append({
                    'test': 'missing_nonce',
                    'severity': 'HIGH',
                    'note': 'Nonce required for replay protection'
                })

            # Check deployment_id
            deployment_claim = 'https://purl.imsglobal.org/spec/lti/claim/deployment_id'
            if deployment_claim in decoded:
                findings.append({
                    'test': 'deployment_id',
                    'value': decoded[deployment_claim],
                    'note': 'Verify deployment_id is valid'
                })

        except jwt.DecodeError as e:
            findings.append({
                'test': 'jwt_decode_error',
                'severity': 'MEDIUM',
                'error': str(e)
            })

        return findings

    def test_tool_registration(self, registration_endpoint):
        """Test LTI tool registration security."""
        findings = []

        # Test 1: Unauthorized registration attempt
        try:
            resp = self.session.post(
                f'{self.platform_url}{registration_endpoint}',
                json={
                    'client_name': 'malicious_tool',
                    'redirect_uris': ['https://evil.com/callback'],
                    'jwks_uri': 'https://evil.com/jwks'
                },
                timeout=10
            )
            findings.append({
                'test': 'unauthorized_registration',
                'status_code': resp.status_code,
                'allowed': resp.status_code in [200, 201],
                'severity': 'CRITICAL' if resp.status_code in [200, 201] else 'PASS'
            })
        except requests.RequestException:
            pass

        # Test 2: Redirect URI validation
        try:
            resp = self.session.post(
                f'{self.platform_url}{registration_endpoint}',
                json={
                    'client_name': 'test_tool',
                    'redirect_uris': [
                        'https://evil.com/callback',
                        'javascript:alert(1)',
                    ],
                },
                timeout=10
            )
            if resp.status_code in [200, 201]:
                findings.append({
                    'test': 'redirect_uri_bypass',
                    'severity': 'CRITICAL',
                    'note': 'Malicious redirect URIs accepted'
                })
        except requests.RequestException:
            pass

        return findings

    def test_nrps_data_exposure(self, nrps_endpoint):
        """Test Names and Roles Provisioning Service data exposure."""
        findings = []

        try:
            resp = self.session.get(
                f'{self.tool_url}{nrps_endpoint}',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json()
                members = data.get('members', [])

                # Check for PII exposure
                pii_fields = ['email', 'name', 'lis_person_sourcedid']
                exposed_pii = []
                for member in members[:5]:
                    for field in pii_fields:
                        if field in member:
                            exposed_pii.append(field)

                findings.append({
                    'test': 'nrps_data_exposure',
                    'severity': 'HIGH',
                    'members_count': len(members),
                    'pii_exposed': list(set(exposed_pii)),
                    'note': 'NRPS exposes student PII'
                })
        except requests.RequestException:
            pass

        return findings

    def test_ags_grade_manipulation(self, ags_endpoint):
        """Test Assignment and Grade Services manipulation."""
        findings = []

        # Test 1: Unauthorized grade submission
        try:
            resp = self.session.post(
                f'{self.tool_url}{ags_endpoint}/scores',
                json={
                    'userId': 'test_user',
                    'scoreGiven': 100,
                    'activityProgress': 'Completed',
                    'gradingProgress': 'FullyGraded',
                    'timestamp': '2026-01-01T00:00:00Z'
                },
                timeout=10
            )
            findings.append({
                'test': 'unauthorized_grade_submission',
                'status_code': resp.status_code,
                'allowed': resp.status_code in [200, 201],
                'note': 'Grade submission without proper authorization'
            })
        except requests.RequestException:
            pass

        # Test 2: Score value manipulation
        try:
            resp = self.session.post(
                f'{self.tool_url}{ags_endpoint}/scores',
                json={
                    'userId': 'test_user',
                    'scoreGiven': 999999,  # Impossible score
                    'activityProgress': 'Completed',
                    'gradingProgress': 'FullyGraded',
                },
                timeout=10
            )
            if resp.status_code in [200, 201]:
                findings.append({
                    'test': 'score_value_manipulation',
                    'severity': 'CRITICAL',
                    'note': 'Impossible score accepted'
                })
        except requests.RequestException:
            pass

        return findings

    def run_lti_assessment(self, launch_url, token,
                            nrps_endpoint='/names-roles',
                            ags_endpoint='/scores'):
        """Run complete LTI assessment."""
        results = {
            'jwt_security': self.test_lti_launch_jwt(launch_url, token),
            'tool_registration': self.test_tool_registration(
                '/lti/registration'
            ),
            'nrps': self.test_nrps_data_exposure(nrps_endpoint),
            'ags': self.test_ags_grade_manipulation(ags_endpoint),
        }

        total_findings = sum(len(v) for v in results.values())
        results['summary'] = {
            'total_findings': total_findings
        }

        return results
```

### Phase 4: SSO and Identity Security

```
Step 4: SSO and Authentication Security
+------------------------------------------------------------------+
|                                                                    |
|  4.1 SAML SSO Security                                            |
|      - SAML assertion signature validation                       |
|      - NameID format validation                                    |
|      - Audience restriction validation                            |
|      - Assertion expiration checking                               |
|                                                                    |
|  4.2 OAuth/OIDC Security                                          |
|      - Redirect URI validation                                    |
|      - State parameter enforcement                                 |
|      - PKCE implementation                                         |
|      - Token validation                                            |
|                                                                    |
|  4.3 Password and MFA                                              |
|      - Password policy enforcement                                |
|      - MFA bypass testing                                         |
|      - Session management                                          |
|      - Account lockout                                             |
|                                                                    |
|  4.4 Provisioning Security                                        |
|      - SCIM endpoint protection                                    |
|      - Attribute mapping validation                               |
|      - De-provisioning verification                                |
|      - Role mapping integrity                                      |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# sso_testing.py - SSO and identity security testing
import requests
import json

class SSOSecurityTester:
    """Test SSO and identity security for education platforms."""

    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'

    def test_saml_security(self, saml_endpoint):
        """Test SAML SSO security."""
        findings = []

        # Test 1: Metadata exposure
        try:
            resp = self.session.get(
                f'{self.base_url}{saml_endpoint}/metadata',
                timeout=10
            )
            if resp.status_code == 200:
                content = resp.text
                if 'entityID' in content:
                    findings.append({
                        'test': 'saml_metadata_exposure',
                        'severity': 'MEDIUM',
                        'note': 'SAML metadata accessible'
                    })
                # Check for signed metadata
                if 'md:SPSSODescriptor' in content:
                    findings.append({
                        'test': 'saml_sp_metadata',
                        'severity': 'INFO',
                        'note': 'SP metadata found'
                    })
        except requests.RequestException:
            pass

        # Test 2: ACS endpoint access
        try:
            resp = self.session.get(
                f'{self.base_url}{saml_endpoint}/acs',
                timeout=10
            )
            findings.append({
                'test': 'saml_acs_access',
                'status_code': resp.status_code,
                'note': 'ACS endpoint accessible'
            })
        except requests.RequestException:
            pass

        # Test 3: SAML request injection
        try:
            resp = self.session.post(
                f'{self.base_url}{saml_endpoint}/acs',
                data={'SAMLResponse': 'test_invalid'},
                timeout=10
            )
            findings.append({
                'test': 'saml_invalid_response',
                'status_code': resp.status_code,
                'note': 'Server response to invalid SAML'
            })
        except requests.RequestException:
            pass

        return findings

    def test_password_policy(self, registration_endpoint):
        """Test password policy enforcement."""
        findings = []

        weak_passwords = [
            'password', '123456', 'qwerty', 'student',
            'password123', 'changeme',
        ]

        for password in weak_passwords:
            try:
                resp = self.session.post(
                    f'{self.base_url}{registration_endpoint}',
                    json={
                        'username': 'testuser',
                        'password': password,
                        'email': 'test@test.com'
                    },
                    timeout=10
                )
                if resp.status_code in [200, 201]:
                    findings.append({
                        'test': 'weak_password_accepted',
                        'severity': 'HIGH',
                        'password': password[:3] + '***',
                        'note': 'Weak password accepted'
                    })
            except requests.RequestException:
                continue

        return findings

    def test_account_enumeration(self, login_endpoint):
        """Test account enumeration via login."""
        findings = []

        # Test with non-existent user
        try:
            resp1 = self.session.post(
                f'{self.base_url}{login_endpoint}',
                json={'username': 'nonexistent_user_xyz', 'password': 'wrong'},
                timeout=10
            )
            resp2 = self.session.post(
                f'{self.base_url}{login_endpoint}',
                json={'username': 'admin', 'password': 'wrong'},
                timeout=10
            )

            if resp1.status_code != resp2.status_code:
                findings.append({
                    'test': 'account_enumeration',
                    'severity': 'HIGH',
                    'nonexistent_status': resp1.status_code,
                    'existing_status': resp2.status_code,
                    'note': 'Different responses for valid/invalid users'
                })
            elif resp1.text != resp2.text:
                findings.append({
                    'test': 'account_enumeration_content',
                    'severity': 'MEDIUM',
                    'note': 'Different response content for valid/invalid users'
                })
        except requests.RequestException:
            pass

        return findings

    def test_scim_endpoints(self):
        """Test SCIM provisioning endpoints."""
        findings = []

        scim_paths = [
            '/scim/v2/Users', '/scim/v2/Groups',
            '/scim/v2/ServiceProviderConfig',
            '/scim/v2/Schemas',
        ]

        for path in scim_paths:
            try:
                resp = self.session.get(
                    f'{self.base_url}{path}', timeout=10
                )
                findings.append({
                    'endpoint': path,
                    'status_code': resp.status_code,
                    'accessible': resp.status_code == 200,
                    'severity': 'HIGH' if resp.status_code == 200 else 'INFO'
                })
            except requests.RequestException:
                continue

        return findings

    def run_sso_assessment(self):
        """Run complete SSO assessment."""
        results = {
            'saml': self.test_saml_security('/saml'),
            'password_policy': self.test_password_policy('/register'),
            'account_enumeration': self.test_account_enumeration('/login'),
            'scim': self.test_scim_endpoints(),
        }

        total_findings = sum(len(v) for v in results.values())
        results['summary'] = {
            'total_findings': total_findings
        }

        return results
```

---

## Tool Arsenal

### Primary Tools

```bash
# LMS security testing
python -c "
import requests

def lms_security_check(base_url):
    checks = []

    # Security headers
    resp = requests.get(base_url, timeout=10)
    headers = resp.headers

    required = [
        'Strict-Transport-Security',
        'X-Content-Type-Options',
        'X-Frame-Options',
        'Content-Security-Policy',
    ]
    for h in required:
        checks.append((h, h in headers))

    for name, passed in checks:
        status = 'PASS' if passed else 'FAIL'
        print(f'  [{status}] {name}')

lms_security_check('https://lms.university.edu')
"
```

```bash
# SAML security testing
python -c "
import requests

def saml_check(base_url, saml_path='/saml'):
    endpoints = [
        f'{saml_path}/metadata',
        f'{saml_path}/acs',
        f'{saml_path}/login',
    ]
    for ep in endpoints:
        try:
            resp = requests.get(f'{base_url}{ep}', timeout=10)
            print(f'  {ep}: {resp.status_code}')
        except Exception as e:
            print(f'  {ep}: Error - {e}')

saml_check('https://sso.university.edu')
"
```

```bash
# FERPA compliance check
python -c "
def ferpa_quick_check():
    requirements = [
        'Role-based access to student records',
        'Audit trail for all record access',
        'Encryption for student PII in transit',
        'Data retention and disposal policy',
        'Directory information opt-out mechanism',
        'Annual FERPA training for staff',
    ]
    for i, req in enumerate(requirements, 1):
        print(f'  [{i}] {req} - REQUIRES_MANUAL_VERIFICATION')

ferpa_quick_check()
"
```

---

## Real-World Examples

### Example 1: Canvas LMS API Student Record Exposure

**Scenario**: A university's Canvas LMS API allowed students to access other students' grade data.

**Discovery**:
```
GET /api/v1/courses/12345/enrollments
Authorization: Bearer <student_token>

Response: 200 OK
{
  "enrollments": [
    {
      "id": 1,
      "user_id": 1001,
      "grades": {
        "current_score": 85.5,
        "final_score": 82.3
      }
    },
    {
      "id": 2,
      "user_id": 1002,
      "grades": {
        "current_score": 92.1,
        "final_score": 89.7
      }
    }
  ]
}
```

**Root Cause**: Canvas API endpoint did not enforce student-level data filtering.

**Impact**: FERPA violation — students could view other students' grades.

### Example 2: LTI Tool Grade Manipulation

**Scenario**: An LTI tool could submit grades without proper validation.

**Discovery**:
```
POST /lti/grade/score
{
  "userId": "student_123",
  "scoreGiven": 100,
  "activityProgress": "Completed",
  "gradingProgress": "FullyGraded"
}

Response: 200 OK
```

**Root Cause**: LTI tool did not validate score ranges or submission authority.

**Impact**: Students could submit perfect scores for themselves via LTI tool.

### Example 3: SAML Assertion Comment Injection

**Scenario**: A university's SAML SSO implementation was vulnerable to comment injection.

**Discovery**:
```
SAML Assertion:
<NameID>admin@university.edu<!--evil-->@attacker.com</NameID>

Parser sees: admin@university.edu
Signature: Valid (comment outside signed element)
```

**Root Cause**: SAML parser accepted comments within the NameID field.

**Impact**: Authentication bypass, admin account impersonation.

---

## Bypass Techniques

### FERPA Bypass

```
Technique 1: Role Confusion
+------------------------------------------------------------------+
| If student records are accessed via API:                         |
|   1. Change user_id parameter to another student                |
|   2. Use enrollment_id instead of user_id                       |
|   3. Access via course context instead of student context       |
|   4. Use batch/gradebook endpoints                               |
+------------------------------------------------------------------+

Technique 2: LTI Tool as Proxy
+------------------------------------------------------------------+
| If LTI tool has elevated access:                                |
|   1. Register as LTI tool                                        |
|   2. Use NRPS to enumerate students                             |
|   3. Use AGS to access grade data                               |
|   4. Tool may have broader access than individual user         |
+------------------------------------------------------------------+

Technique 3: Export Endpoint Bypass
+------------------------------------------------------------------+
| If grade export requires instructor role:                        |
|   1. Access grade API directly (not export endpoint)           |
|   2. Use course gradebook endpoint                              |
|   3. Access via assignment submission endpoint                  |
|   4. Use rubric/assessment endpoint                             |
+------------------------------------------------------------------+
```

---

## Common Pitfalls

### 1. FERPA Compliance Confusion

```
Common FERPA Misconceptions:
+------------------------------------------------------------------+
| Myth: FERPA only applies to grades                               |
| Truth: FERPA covers ALL education records                        |
|                                                                    |
| Myth: Students can't see other students' data                    |
| Truth: Without proper controls, API access may expose data      |
|                                                                    |
| Myth: LTI tools are automatically FERPA compliant               |
| Truth: LTI tools must implement their own controls             |
|                                                                    |
| Myth: SSO = FERPA compliance                                     |
| Truth: SSO only handles authentication, not authorization       |
+------------------------------------------------------------------+
```

### 2. Budget and Resource Constraints

| Challenge | Impact | Mitigation |
|-----------|--------|------------|
| Limited security staff | Slower response | Prioritize high-risk systems |
| Legacy LMS versions | Unpatched vulnerabilities | Plan migration timeline |
| Multiple SIS platforms | Inconsistent controls | Standardize where possible |
| Third-party LTI tools | Supply chain risk | Vet tools before integration |

### 3. Academic Freedom vs Security

```
Tension Points:
+------------------------------------------------------------------+
| Academic Freedom:                                                |
|   - Open discussion and collaboration                            |
|   - Free exchange of ideas                                       |
|   - Student content creation                                      |
|   - Research data sharing                                         |
|                                                                    |
| Security Requirements:                                            |
|   - Access controls on student data                              |
|   - Audit trails for compliance                                  |
|   - Data protection for PII                                      |
|   - Incident response procedures                                 |
|                                                                    |
| Balance:                                                          |
|   - Enforce controls at data level, not content level          |
|   - Log access without restricting legitimate use              |
|   - Protect PII while allowing open discussion                 |
+------------------------------------------------------------------+
```

---

## Reporting Template

```markdown
# Education Platform Security Assessment Report

## Executive Summary
- **Institution**: [University/School Name]
- **System**: [LMS/SIS/Platform Name]
- **Assessment Date**: [Date]
- **Framework**: FERPA, EDUCAUSE, LTI Standards
- **User Population**: [Students, Faculty, Staff]

## Findings Summary
| # | Finding | Regulation | Severity | Users Affected |
|---|---------|------------|----------|----------------|
| 1 | [Finding] | FERPA | CRITICAL | All students |

## Detailed Findings

### Finding 1: [Title]
- **Regulation**: FERPA/COPPA/Other
- **System**: [LMS/SIS/Platform]
- **Data Type**: [Grades/PII/Financial]
- **Description**: [Technical detail]
- **Student Impact**: [Privacy breach, grade manipulation, etc.]
- **Recommendation**: [Remediation]
- **Timeline**: [Immediate/30/60/90 days]

## FERPA Compliance Matrix
| Requirement | Status | Notes |
|-------------|--------|-------|
| Access Controls | PASS/FAIL | |
| Audit Logging | PASS/FAIL | |
| Data Encryption | PASS/FAIL | |
| Directory Info Controls | PASS/FAIL | |
| Consent Management | PASS/FAIL | |

## LTI Security Assessment
| LTI Tool | Version | JWT Security | NRPS Access | AGS Access |
|----------|---------|--------------|-------------|------------|
| [Tool] | 1.3 | PASS/FAIL | PASS/FAIL | PASS/FAIL |

## Appendices
A. Systems Tested
B. API Endpoint Inventory
C. LTI Tool Registry
D. SSO Configuration
E. Student Data Flow Diagrams
```

---

## Quick Reference

### Critical Education Endpoints

```
LMS APIs:
  GET  /api/v1/courses              # Course list
  GET  /api/v1/courses/{id}/enrollments  # Enrollments
  GET  /api/v1/courses/{id}/grades  # Grade data
  POST /api/v1/courses/{id}/assignments  # Create assignment

LTI Endpoints:
  POST /lti/launch                  # LTI launch
  GET  /lti/jwks                    # LTI public keys
  GET  /lti/names-roles             # NRPS
  POST /lti/scores                  # AGS grades

SSO Endpoints:
  GET  /saml/metadata               # SAML metadata
  POST /saml/acs                    # SAML ACS
  GET  /auth/oidc                   # OIDC authorization
  GET  /.well-known/openid-configuration

SIS Endpoints:
  GET  /api/v1/students             # Student records
  GET  /api/v1/grades               # Grade records
  GET  /api/v1/enrollments          # Enrollment data
  GET  /api/v1/financial-aid        # Financial aid
```

### FERPA Key Requirements

```
Access Control:
  - Unique user identification
  - Role-based access to student records
  - Least privilege principle
  - Emergency access procedures

Audit:
  - Log all access to student records
  - Track who accessed what and when
  - Protect audit logs from tampering
  - Regular audit log review

Data Protection:
  - Encrypt PII in transit and at rest
  - Secure data transmission methods
  - Proper data retention and disposal
  - Directory information opt-out
```

### Severity Decision Matrix

| Finding | FERPA Impact | Student Impact | Severity |
|---------|-------------|----------------|----------|
| Cross-student grade access | Violation | Privacy breach | CRITICAL |
| LTI grade manipulation | Violation | Academic integrity | CRITICAL |
| SAML auth bypass | Violation | Identity compromise | CRITICAL |
| Student enumeration | Violation | Privacy breach | HIGH |
| Weak password policy | Violation | Account takeover | HIGH |

### References

- FERPA: https://www.law.cornell.edu/uscode/text/20/1232g
- EDUCAUSE Security: https://www.educause.edu/focus-areas/cybersecurity
- LTI 1.3: https://www.imsglobal.org/spec/lti/v1p3/
- Canvas API: https://canvas.instructure.com/doc/api/
- Moodle Security: https://docs.moodle.org/403/en/Security
- COPPA (K-12): https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa
