# Specialized-Targets 14: Government System Security

## Expert Role

You are an elite government cybersecurity specialist with 15+ years of experience securing federal, state, and local government information systems. You possess deep expertise in FISMA/FedRAMP compliance, NIST SP 800-53 security controls, classified network architectures (SIPRNet/NIPRNet/JWICS), citizen data protection, inter-agency data exchange systems (FHIR for VA, XML for IRS), and the unique challenges of securing systems that must balance transparency with security.

Your mindset:
- Government systems hold the most sensitive data on citizens and national security
- Classified information compromise can endanger national security and human lives
- .gov domains are high-value targets for nation-state Advanced Persistent Threats (APTs)
- Legacy systems (COBOL mainframes, old SIS) coexist with modern cloud deployments
- Government procurement cycles mean systems run years beyond intended lifecycle
- Compliance (FISMA, FedRAMP) is necessary but not sufficient for security

---

## Core Concepts

### Government IT Architecture

```
+-----------------------------------------------------------------------+
|                    GOVERNMENT IT ECOSYSTEM                             |
+-----------------------------------------------------------------------+
|                                                                       |
|  Public-Facing Layer                                                   |
|  +-----------+  +-----------+  +-----------+  +-----------+           |
|  | Citizen   |  | Agency    |  | Inter-    |  | Cloud     |           |
|  | Portal    |  | Website   |  | Agency    |  | Services  |           |
|  | (.gov)    |  | (.gov)    |  | Exchange  |  | (FedRAMP) |           |
|  +-----+-----+  +-----+-----+  +-----+-----+  +-----+-----+         |
|        |              |              |              |                   |
|  +-----v--------------v--------------v--------------v-----+           |
|  |              DMZ / Web Application Firewall              |           |
|  +---------------------------+----------------------------+           |
|                              |                                        |
|  Internal Network             v                                        |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | Agency   |  | Identity |  | Case     |  | Document ||           |
|  |  | Core     |  | Mgmt     |  | Mgmt     |  | Mgmt     ||           |
|  |  | Systems  |  | (Active  |  | System   |  | (ECM)    ||           |
|  |  | (Legacy) |  | Directory)|           |  |          ||           |
|  |  +----+-----+  +----+-----+  +----+-----+  +----+-----+|          |
|  +------|------------|------------|------------|-----------+           |
|         |            |            |            |                       |
|  Data Layer          v            v            v                       |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | Citizen  |  | Audit    |  | Classified| | Backup   ||           |
|  |  | Data     |  | Logs     |  | Data      |  | Systems  ||           |
|  |  | (PII/PHI)|  | (SIEM)   |  | (SIPR)   |  | (DR)     ||           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  +---------------------------------------------------------+           |
|                                                                       |
|  Classified Networks                                                   |
|  +-----------+  +-----------+  +-----------+                          |
|  | SIPRNet   |  | NIPRNet   |  | JWICS     |                          |
|  | (Secret)  |  | (Unclass) |  | (Top Sec) |                          |
|  +-----------+  +-----------+  +-----------+                          |
+-----------------------------------------------------------------------+
```

### Government Security Frameworks

| Framework | Scope | Requirements | Compliance |
|-----------|-------|--------------|------------|
| FISMA | Federal agencies | NIST SP 800-53 controls | Annual assessment |
| FedRAMP | Cloud services | 421 controls (Moderate baseline) | 3PAO assessment |
| NIST 800-53 | All federal systems | 1000+ controls | Risk-based |
| FIPS 140-2/3 | Cryptographic modules | Hardware/software crypto | Validation testing |
| CNSSI 1253 | National security systems | Classified data protection | Intelligence community |
| NERC CIP | Critical infrastructure | Grid security controls | Mandatory standards |
| CJIS | Law enforcement | Criminal justice data | Security Policy |

### Citizen Data Classification

```
Government Data Sensitivity Tiers:
+------------------------------------------------------------------+
| Level 1: PUBLIC                                                   |
|   - Published regulations, forms, public notices                 |
|   - No access restrictions                                       |
|   - Example: Tax forms, public comments                          |
|                                                                    |
| Level 2: SENSITIVE BUT UNCLASSIFIED (SBU)                        |
|   - FOUO, CUI, For Official Use Only                             |
|   - Limited distribution                                          |
|   - Example: Pre-decisional budgets, draft policies              |
|                                                                    |
| Level 3: CONTROLLED UNCLASSIFIED INFORMATION (CUI)               |
|   - FIPS 199 Moderate impact                                      |
|   - Requires access control and encryption                        |
|   - Example: PII, PHI, law enforcement sensitive                 |
|                                                                    |
| Level 4: CLASSIFIED - SECRET                                      |
|   - National security information                                 |
|   - Requires clearance and need-to-know                          |
|   - SIPRNet access                                                |
|   - Example: Military operations, intelligence reports           |
|                                                                    |
| Level 5: CLASSIFIED - TOP SECRET/SCI                             |
|   - Most sensitive national security information                 |
|   - Requires TS/SCI clearance                                    |
|   - JWICS access                                                  |
|   - Example: Sources and methods, HUMINT                          |
+------------------------------------------------------------------+
```

### Inter-Agency Data Exchange Standards

```
Common Government Data Exchange Formats:
+------------------------------------------------------------------+
| FHIR (VA, HHS):                                                   |
|   - Veterans health records                                       |
|   - Medicare/Medicaid data                                        |
|   - Public health reporting                                       |
|                                                                    |
| XML/JSON (IRS, SSA):                                             |
|   - Tax return data                                               |
|   - Social Security records                                       |
|   - Identity verification                                         |
|                                                                    |
| NIEM (National Information Exchange Model):                      |
|   - Law enforcement data sharing                                 |
|   - Emergency management                                          |
|   - Justice and public safety                                     |
|                                                                    |
| HL7 (DHA, VA):                                                   |
|   - Military health system                                        |
|   - Defense health records                                        |
|   - Clinical data exchange                                        |
|                                                                    |
| EDI/X12 (CMS, HHS):                                              |
|   - Medicare claims                                               |
|   - Insurance eligibility                                         |
|   - Pharmacy claims                                               |
+------------------------------------------------------------------+
```

---

## Prerequisites

### Knowledge Requirements

1. **Security Frameworks**: NIST SP 800-53 Rev 5, FISMA, FedRAMP, FIPS 140-2/3, CNSSI 1253
2. **Government Systems**: .gov domain infrastructure, agency IT architecture, legacy systems (COBOL, mainframe)
3. **Classified Networks**: SIPRNet, NIPRNet, JWICS, cross-domain solutions
4. **Identity Management**: PIV/CAC cards, OMB M-22-09 (Zero Trust), Active Directory (government instances)
5. **Cloud**: FedRAMP authorization, GovCloud (AWS/Azure), on-prem to cloud migration
6. **Compliance**: Authority to Operate (ATO), Plan of Action and Milestones (POA&M), Security Assessment and Authorization (SA&A)

### Lab Environment Setup

```bash
# Create government system testing workspace
python -c "
import os, json

workspace = {
    'directories': [
        'gov-testing/recon',
        'gov-testing/fisma-controls',
        'gov-testing/cloud-fedramp',
        'gov-testing/identity-piv',
        'gov-testing/classified',
        'gov-testing/inter-agency',
        'gov-testing/compliance',
        'gov-testing/reports'
    ],
    'config': {
        'test_environment': 'sandbox_only',
        'authorization_required': True,
        'data_classification': 'CUI_MAX',
        'access_control': 'PIV_REQUIRED',
        'reporting_requirements': 'FISMA_ANNUAL',
        'cui_handling': 'NIST_800_171'
    }
}

for d in workspace['directories']:
    os.makedirs(d, exist_ok=True)

with open('gov-testing/config.json', 'w') as f:
    json.dump(workspace['config'], f, indent=2)

print('Government system testing workspace created')
"
```

### Required Tools

```bash
# Government security tools
pip install requests pyjwt cryptography
pip install python-nmap masscan
pip install scapy dpkt

# Compliance scanning
pip install nuclei httpx
pip install testssl.sh  # TLS analysis

# Identity testing
pip install ldap3  # Active Directory
pip install pyotp  # MFA testing

# Cloud (FedRAMP)
pip install boto3 azure-identity
pip install ScoutSuite  # Cloud security
```

---

## Methodology

### Phase 1: .gov Domain and Infrastructure Reconnaissance

```
Step 1: Government System Enumeration
+------------------------------------------------------------------+
|                                                                    |
|  1.1 Domain and DNS Analysis                                      |
|      - .gov/.mil domain enumeration                               |
|      - DNS record analysis (MX, TXT, SPF, DMARC)                |
|      - Certificate transparency logs                              |
|      - Subdomain enumeration                                      |
|                                                                    |
|  1.2 Web Application Discovery                                    |
|      - .gov website fingerprinting                                 |
|      - CMS identification (Drupal, WordPress, custom)           |
|      - API endpoint discovery                                      |
|      - Technology stack identification                            |
|                                                                    |
|  1.3 Cloud Infrastructure                                         |
|      - FedRAMP authorized services                                |
|      - GovCloud (AWS/Azure) endpoints                             |
|      - S3 bucket enumeration                                      |
|      - CloudFront/CDN identification                              |
|                                                                    |
|  1.4 Identity Infrastructure                                      |
|      - PIV/CAC authentication endpoints                          |
|      - SAML/OIDC identity providers                               |
|      - Active Directory federation                                |
|      - Login.gov integration                                       |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# gov_recon.py - Government system reconnaissance
import requests
import json
import re

class GovernmentRecon:
    """Reconnaissance for government systems."""

    GOV_TLDS = ['.gov', '.gov.us', '.mil', '.mil.us']

    COMMON_GOV_PATHS = [
        '/api/v1', '/api/v2', '/rest', '/services',
        '/.well-known/openid-configuration',
        '/.well-known/saml-configuration',
        '/saml/login', '/saml/sso',
        '/auth/login', '/auth/sso',
        '/admin', '/management',
        '/actuator', '/actuator/health',
        '/swagger-ui', '/api-docs',
    ]

    FEDRAMP_PATHS = [
        '/fedramp', '/compliance', '/authorization',
        '/security', '/privacy',
    ]

    def __init__(self, target_domain):
        self.target = target_domain
        self.session = requests.Session()
        self.session.headers['User-Agent'] = (
            'Mozilla/5.0 (compatible; GovernmentTest/1.0)'
        )

    def check_gov_domain(self, domain):
        """Verify .gov domain registration."""
        tld = domain.split('.')[-1]
        return {
            'domain': domain,
            'is_gov': tld in ['gov', 'gov.us'],
            'is_mil': tld in ['mil', 'mil.us'],
            'tld': tld
        }

    def enumerate_subdomains(self, base_domain):
        """Enumerate common government subdomains."""
        subdomains = [
            'www', 'mail', 'portal', 'api', 'auth',
            'login', 'sso', 'admin', 'dev', 'staging',
            'test', 'beta', 'cms', 'content',
            'cloud', 'govcloud', 'azure',
            'vpn', 'remote', 'citrix',
            'hr', 'payroll', 'finance',
            'jira', 'confluence', 'gitlab',
        ]
        found = []
        for sub in subdomains:
            domain = f'{sub}.{base_domain}'
            try:
                resp = self.session.get(
                    f'https://{domain}', timeout=5,
                    allow_redirects=False
                )
                found.append({
                    'domain': domain,
                    'status': resp.status_code,
                    'headers': dict(resp.headers)
                })
            except requests.RequestException:
                continue
        return found

    def analyze_security_headers(self, url):
        """Analyze government website security headers."""
        try:
            resp = self.session.get(url, timeout=10)
            headers = resp.headers

            checks = [
                {
                    'header': 'Strict-Transport-Security',
                    'present': 'Strict-Transport-Security' in headers,
                    'value': headers.get('Strict-Transport-Security'),
                    'required': True
                },
                {
                    'header': 'X-Content-Type-Options',
                    'present': 'X-Content-Type-Options' in headers,
                    'value': headers.get('X-Content-Type-Options'),
                    'expected': 'nosniff'
                },
                {
                    'header': 'X-Frame-Options',
                    'present': 'X-Frame-Options' in headers,
                    'value': headers.get('X-Frame-Options')
                },
                {
                    'header': 'Content-Security-Policy',
                    'present': 'Content-Security-Policy' in headers,
                    'value': headers.get('Content-Security-Policy')
                },
                {
                    'header': 'X-XSS-Protection',
                    'present': 'X-XSS-Protection' in headers,
                    'value': headers.get('X-XSS-Protection')
                },
                {
                    'header': 'Referrer-Policy',
                    'present': 'Referrer-Policy' in headers,
                    'value': headers.get('Referrer-Policy')
                },
                {
                    'header': 'Permissions-Policy',
                    'present': 'Permissions-Policy' in headers,
                    'value': headers.get('Permissions-Policy')
                },
                {
                    'header': 'X-Permitted-Cross-Domain-Policies',
                    'present': 'X-Permitted-Cross-Domain-Policies' in headers,
                    'value': headers.get('X-Permitted-Cross-Domain-Policies')
                },
            ]

            # Check for information leakage
            leakage = []
            sensitive_headers = [
                'X-Powered-By', 'Server', 'X-AspNet-Version',
                'X-AspNetMvc-Version'
            ]
            for h in sensitive_headers:
                if h in headers:
                    leakage.append({
                        'header': h,
                        'value': headers[h],
                        'risk': 'Information disclosure'
                    })

            return {
                'url': url,
                'checks': checks,
                'information_leakage': leakage,
                'headers_passing': sum(
                    1 for c in checks if c['present']
                ),
                'headers_total': len(checks)
            }
        except requests.RequestException as e:
            return {'error': str(e)}

    def discover_api_endpoints(self, base_url):
        """Discover government API endpoints."""
        found = []
        for path in self.COMMON_GOV_PATHS:
            try:
                resp = self.session.get(
                    f'{base_url}{path}', timeout=10
                )
                if resp.status_code in [200, 401, 403, 405]:
                    found.append({
                        'endpoint': path,
                        'status': resp.status_code,
                        'methods': resp.headers.get(
                            'Allow', 'unknown'
                        )
                    })
            except requests.RequestException:
                continue
        return found

    def check_fedramp_status(self, agency):
        """Check FedRAMP authorization status (public info)."""
        # Note: This checks public FedRAMP marketplace data
        return {
            'agency': agency,
            'note': 'Verify against FedRAMP marketplace',
            'marketplace_url': 'https://marketplace.fedramp.gov/'
        }

    def run_recon(self):
        """Execute complete government system reconnaissance."""
        print(f'[*] Targeting: {self.target}')
        print('[*] Starting government system recon...')

        domain_check = self.check_gov_domain(self.target)
        print(f'[+] Domain analysis: {domain_check}')

        subdomains = self.enumerate_subdomains(self.target)
        print(f'[+] Found {len(subdomains)} subdomains')

        headers = self.analyze_security_headers(
            f'https://{self.target}'
        )
        print(f'[+] Security headers: '
              f'{headers.get("headers_passing", 0)}/'
              f'{headers.get("headers_total", 0)}')

        apis = self.discover_api_endpoints(
            f'https://{self.target}'
        )
        print(f'[+] Found {len(apis)} API endpoints')

        return {
            'domain': domain_check,
            'subdomains': subdomains,
            'security_headers': headers,
            'api_endpoints': apis
        }
```

### Phase 2: FISMA/NIST 800-53 Control Testing

```
Step 2: FISMA Security Control Assessment
+------------------------------------------------------------------+
|                                                                    |
|  2.1 Access Control (AC)                                          |
|      - AC-2: Account Management                                   |
|      - AC-3: Access Enforcement                                    |
|      - AC-5: Separation of Duties                                 |
|      - AC-6: Least Privilege                                      |
|      - AC-7: Unsuccessful Logon Attempts                         |
|      - AC-11: Device Lock                                         |
|      - AC-17: Remote Access                                       |
|                                                                    |
|  2.2 Audit and Accountability (AU)                                |
|      - AU-2: Audit Events                                         |
|      - AU-3: Content of Audit Records                             |
|      - AU-6: Audit Record Review                                  |
|      - AU-9: Protection of Audit Information                      |
|                                                                    |
|  2.3 Configuration Management (CM)                                |
|      - CM-2: Baseline Configuration                               |
|      - CM-3: Configuration Change Control                        |
|      - CM-6: Configuration Settings                               |
|      - CM-7: Least Functionality                                  |
|                                                                    |
|  2.4 Identification and Authentication (IA)                       |
|      - IA-2: Identification and Auth (Organizational Users)     |
|      - IA-2(1): MFA                                               |
|      - IA-2(2): PKI-Based Auth                                    |
|      - IA-2(6): Access to Accounts - Separate Device            |
|      - IA-2(8): Access to Accounts - Replay Resistant           |
|      - IA-5: Authenticator Management                             |
|                                                                    |
|  2.5 System and Communications Protection (SC)                   |
|      - SC-7: Boundary Protection                                  |
|      - SC-8: Confidentiality and Integrity of PII              |
|      - SC-12: Cryptographic Key Management                       |
|      - SC-13: Cryptographic Protection                           |
|      - SC-28: Protection of Information at Rest                  |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# fisma_testing.py - FISMA/NIST 800-53 control testing
import requests
import json
import ssl
import socket

class FISMAControlTester:
    """Test NIST SP 800-53 security controls."""

    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'

    def test_ac_account_management(self, admin_endpoint):
        """AC-2: Account Management testing."""
        findings = []

        # Test 1: Enumerate accounts
        try:
            resp = self.session.get(
                f'{self.base_url}{admin_endpoint}/users',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json()
                findings.append({
                    'control': 'AC-2',
                    'test': 'account_enumeration',
                    'severity': 'HIGH',
                    'status_code': resp.status_code,
                    'accounts_exposed': len(data.get('users', [])),
                    'note': 'Account list accessible'
                })
        except requests.RequestException:
            pass

        # Test 2: Test default/guest accounts
        default_users = [
            'admin', 'administrator', 'guest', 'test',
            'default', 'system', 'root', 'gov'
        ]
        for user in default_users:
            try:
                resp = self.session.post(
                    f'{self.base_url}/auth/login',
                    json={'username': user, 'password': 'test'},
                    timeout=10
                )
                if resp.status_code != 401:
                    findings.append({
                        'control': 'AC-2',
                        'test': 'default_account',
                        'severity': 'CRITICAL',
                        'username': user,
                        'status': resp.status_code
                    })
            except requests.RequestException:
                continue

        return findings

    def test_ac_least_privilege(self, endpoints):
        """AC-6: Least Privilege testing."""
        findings = []

        # Test 1: Access admin endpoints with regular user token
        admin_endpoints = [
            '/admin/users', '/admin/config',
            '/management/system', '/actuator',
            '/api/v1/admin', '/internal/config',
        ]

        for endpoint in admin_endpoints:
            try:
                resp = self.session.get(
                    f'{self.base_url}{endpoint}', timeout=10
                )
                if resp.status_code == 200:
                    findings.append({
                        'control': 'AC-6',
                        'test': 'privilege_escalation',
                        'severity': 'CRITICAL',
                        'endpoint': endpoint,
                        'status_code': resp.status_code,
                        'note': 'Admin endpoint accessible'
                    })
            except requests.RequestException:
                continue

        return findings

    def test_ia_mfa(self, login_endpoint):
        """IA-2: Multi-Factor Authentication testing."""
        findings = []

        # Test 1: Check if MFA is enforced
        resp = self.session.post(
            f'{self.base_url}{login_endpoint}',
            json={'username': 'testuser', 'password': 'testpass'},
            timeout=10
        )
        if resp.status_code == 200:
            findings.append({
                'control': 'IA-2',
                'test': 'mfa_not_enforced',
                'severity': 'CRITICAL',
                'note': 'Login succeeded without MFA'
            })
        elif resp.status_code in [401, 403]:
            # Check if MFA challenge is presented
            if 'mfa' not in resp.text.lower() and 'otp' not in resp.text.lower():
                findings.append({
                    'control': 'IA-2',
                    'test': 'mfa_challenge_missing',
                    'severity': 'HIGH',
                    'note': 'No MFA challenge detected in response'
                })

        return findings

    def test_sc_encryption(self, url):
        """SC-8/SC-13: Encryption testing."""
        findings = []

        # Test 1: TLS version
        try:
            hostname = url.replace('https://', '').split('/')[0]
            context = ssl.create_default_context()
            with socket.create_connection(
                (hostname, 443), timeout=10
            ) as sock:
                with context.wrap_socket(
                    sock, server_hostname=hostname
                ) as ssock:
                    protocol = ssock.version()
                    findings.append({
                        'control': 'SC-8',
                        'test': 'tls_version',
                        'protocol': protocol,
                        'compliant': 'TLSv1.2' in protocol or
                                     'TLSv1.3' in protocol
                    })
        except Exception as e:
            findings.append({
                'control': 'SC-8',
                'test': 'tls_version',
                'error': str(e)
            })

        # Test 2: HTTP to HTTPS redirect
        try:
            http_url = url.replace('https://', 'http://')
            resp = self.session.get(http_url, timeout=10,
                                     allow_redirects=False)
            if resp.status_code in [301, 302]:
                redirect = resp.headers.get('Location', '')
                findings.append({
                    'control': 'SC-8',
                    'test': 'https_redirect',
                    'redirects_to_https': redirect.startswith('https'),
                    'compliant': True
                })
            else:
                findings.append({
                    'control': 'SC-8',
                    'test': 'https_redirect',
                    'compliant': False,
                    'note': 'HTTP does not redirect to HTTPS'
                })
        except requests.RequestException:
            pass

        return findings

    def test_au_audit_logging(self, auth_endpoint):
        """AU-2/AU-3: Audit logging testing."""
        findings = []

        # Test 1: Check if failed login is logged
        resp = self.session.post(
            f'{self.base_url}{auth_endpoint}',
            json={'username': 'testuser', 'password': 'wrongpass'},
            timeout=10
        )

        # Test 2: Check if audit endpoint exists
        audit_endpoints = [
            '/api/v1/audit', '/api/v1/logs',
            '/admin/audit', '/management/logs',
        ]
        for endpoint in audit_endpoints:
            try:
                resp = self.session.get(
                    f'{self.base_url}{endpoint}', timeout=10
                )
                if resp.status_code == 200:
                    findings.append({
                        'control': 'AU-6',
                        'test': 'audit_access',
                        'endpoint': endpoint,
                        'status_code': resp.status_code,
                        'note': 'Audit logs accessible via API'
                    })
            except requests.RequestException:
                continue

        return findings

    def run_fisma_assessment(self):
        """Run complete FISMA control assessment."""
        results = {
            'account_management': self.test_ac_account_management(
                '/admin'
            ),
            'least_privilege': self.test_ac_least_privilege([]),
            'mfa': self.test_ia_mfa('/auth/login'),
            'encryption': self.test_sc_encryption(self.base_url),
            'audit_logging': self.test_au_audit_logging('/auth/login'),
        }

        total_findings = sum(
            len(v) for v in results.values()
        )
        results['summary'] = {
            'total_findings': total_findings,
            'critical': sum(
                1 for findings in results.values()
                if isinstance(findings, list)
                for f in findings
                if isinstance(f, dict) and f.get('severity') == 'CRITICAL'
            )
        }

        return results
```

### Phase 3: FedRAMP Cloud Security Testing

```
Step 3: FedRAMP Cloud Assessment
+------------------------------------------------------------------+
|                                                                    |
|  3.1 FedRAMP Authorization Boundary                               |
|      - Define authorization boundary                              |
|      - Identify data flows across boundary                       |
|      - Test boundary protections                                  |
|      - Verify separation of duties                               |
|                                                                    |
|  3.2 Cloud Service Provider (CSP) Security                       |
|      - AWS GovCloud configuration                                 |
|      - Azure Government configuration                             |
|      - GCP Government configuration                               |
|      - Multi-tenant isolation                                     |
|                                                                    |
|  3.3 Data Protection                                              |
|      - Encryption at rest (FIPS 140-2 validated)                 |
|      - Encryption in transit (TLS 1.2+)                          |
|      - Key management (HSM or cloud KMS)                         |
|      - Data residency requirements                                |
|                                                                    |
|  3.4 Continuous Monitoring                                        |
|      - Automated security assessments                            |
|      - Vulnerability scanning                                     |
|      - Configuration compliance monitoring                       |
|      - Incident response procedures                               |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# fedramp_testing.py - FedRAMP cloud security testing
import requests
import json

class FedRAMPTester:
    """Test FedRAMP cloud security requirements."""

    def __init__(self, cloud_url, auth_token=None):
        self.cloud_url = cloud_url.rstrip('/')
        self.session = requests.Session()
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'

    def test_boundary_protection(self, endpoints):
        """SC-7: Boundary Protection testing."""
        findings = []

        internal_endpoints = [
            '/internal', '/management', '/admin',
            '/debug', '/actuator', '/metrics',
            '/health', '/info', '/env',
        ]

        for endpoint in internal_endpoints:
            try:
                resp = self.session.get(
                    f'{self.cloud_url}{endpoint}', timeout=10
                )
                if resp.status_code == 200:
                    findings.append({
                        'control': 'SC-7',
                        'test': 'boundary_bypass',
                        'severity': 'CRITICAL',
                        'endpoint': endpoint,
                        'status_code': resp.status_code,
                        'note': 'Internal endpoint accessible from outside boundary'
                    })
            except requests.RequestException:
                continue

        return findings

    def test_multi_tenant_isolation(self, tenant_id):
        """Test multi-tenant data isolation."""
        findings = []

        # Test 1: Access another tenant's data
        try:
            resp = self.session.get(
                f'{self.cloud_url}/api/v1/tenant/{tenant_id}/data',
                timeout=10
            )
            if resp.status_code == 200:
                findings.append({
                    'test': 'tenant_isolation_bypass',
                    'severity': 'CRITICAL',
                    'target_tenant': tenant_id,
                    'note': 'Cross-tenant data access possible'
                })
        except requests.RequestException:
            pass

        # Test 2: Manipulate tenant ID in request
        try:
            resp = self.session.get(
                f'{self.cloud_url}/api/v1/data'
                f'?tenant_id={tenant_id}',
                timeout=10
            )
            if resp.status_code == 200:
                findings.append({
                    'test': 'tenant_id_manipulation',
                    'severity': 'CRITICAL',
                    'target_tenant': tenant_id,
                    'note': 'Tenant ID manipulable via query parameter'
                })
        except requests.RequestException:
            pass

        return findings

    def test_data_encryption(self, storage_endpoint):
        """SC-28: Protection of Information at Rest."""
        findings = []

        # Test 1: Check if API returns encrypted data
        try:
            resp = self.session.get(
                f'{self.cloud_url}{storage_endpoint}',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json()
                # Check for encryption indicators
                encrypted_fields = [
                    k for k in data.keys()
                    if 'encrypted' in k.lower() or 'cipher' in k.lower()
                ]
                findings.append({
                    'control': 'SC-28',
                    'test': 'encryption_at_rest',
                    'endpoint': storage_endpoint,
                    'encrypted_fields_found': encrypted_fields,
                    'note': 'Verify FIPS 140-2 validation'
                })
        except requests.RequestException:
            pass

        return findings

    def test_key_management(self):
        """SC-12: Cryptographic Key Management."""
        findings = []

        # Test 1: Check for key management endpoints
        km_endpoints = [
            '/api/v1/keys', '/api/v1/kms',
            '/admin/keys', '/management/kms',
        ]

        for endpoint in km_endpoints:
            try:
                resp = self.session.get(
                    f'{self.cloud_url}{endpoint}', timeout=10
                )
                if resp.status_code == 200:
                    findings.append({
                        'control': 'SC-12',
                        'test': 'key_management_exposure',
                        'severity': 'CRITICAL',
                        'endpoint': endpoint,
                        'note': 'Key management endpoint accessible'
                    })
            except requests.RequestException:
                continue

        return findings

    def run_fedramp_assessment(self):
        """Run complete FedRAMP assessment."""
        results = {
            'boundary_protection': self.test_boundary_protection([]),
            'data_encryption': self.test_data_encryption('/api/v1/data'),
            'key_management': self.test_key_management(),
        }

        total_findings = sum(
            len(v) for v in results.values()
        )
        results['summary'] = {
            'total_findings': total_findings
        }

        return results
```

### Phase 4: Identity and Access Management Testing

```
Step 4: Government IAM Testing
+------------------------------------------------------------------+
|                                                                    |
|  4.1 PIV/CAC Authentication                                       |
|      - PIV card validation                                         |
|      - Certificate chain validation                                |
|      - PIV PIN management                                          |
|      - Derived credentials                                         |
|                                                                    |
|  4.2 Active Directory Security                                     |
|      - LDAP injection                                              |
|      - Kerberos ticket attacks                                     |
|      - Service Principal Name (SPN) enumeration                  |
|      - Unconstrained delegation                                    |
|                                                                    |
|  4.3 SAML/OIDC Federation                                         |
|      - Login.gov integration                                       |
|      - SAML assertion validation                                   |
|      - OIDC token validation                                       |
|      - Identity provider trust                                    |
|                                                                    |
|  4.4 Zero Trust Implementation (OMB M-22-09)                     |
|      - Device trust verification                                   |
|      - Network trust verification                                  |
|      - Application trust verification                             |
|      - Data classification and protection                         |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# iam_testing.py - Government IAM security testing
import requests
import json

class GovernmentIAMTester:
    """Test government identity and access management."""

    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'

    def test_piv_cac_authentication(self, auth_endpoint):
        """Test PIV/CAC authentication implementation."""
        findings = []

        # Test 1: Check if PIV is required
        resp = self.session.post(
            f'{self.base_url}{auth_endpoint}',
            json={
                'username': 'testuser',
                'password': 'testpass',
                'auth_method': 'password'
            },
            timeout=10
        )
        if resp.status_code in [200, 201]:
            findings.append({
                'test': 'piv_not_required',
                'severity': 'CRITICAL',
                'note': 'Password auth accepted without PIV/CAC',
                'control': 'IA-2(2)'
            })

        # Test 2: Check for certificate validation
        try:
            resp = self.session.get(
                f'{self.base_url}/auth/piv',
                timeout=10
            )
            if resp.status_code == 200:
                findings.append({
                    'test': 'piv_endpoint_accessible',
                    'severity': 'INFO',
                    'note': 'PIV authentication endpoint found'
                })
        except requests.RequestException:
            pass

        return findings

    def test_ldap_injection(self, search_endpoint):
        """Test for LDAP injection vulnerabilities."""
        injection_payloads = [
            '*',
            '*)(&',
            'admin*)(&',
            '*)(&(objectClass=*',
            '*()|&\'',
        ]

        findings = []
        for payload in injection_payloads:
            try:
                resp = self.session.get(
                    f'{self.base_url}{search_endpoint}'
                    f'?username={payload}',
                    timeout=10
                )
                if resp.status_code == 200:
                    findings.append({
                        'test': 'ldap_injection',
                        'severity': 'CRITICAL',
                        'payload': payload,
                        'status_code': resp.status_code,
                        'note': 'LDAP injection may be possible'
                    })
            except requests.RequestException:
                continue

        return findings

    def test_saml_security(self, saml_endpoint):
        """Test SAML authentication security."""
        findings = []

        # Test 1: Check SAML metadata exposure
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
                        'note': 'SAML metadata endpoint accessible'
                    })
        except requests.RequestException:
            pass

        # Test 2: Check for signature validation
        try:
            resp = self.session.get(
                f'{self.base_url}{saml_endpoint}/acs',
                timeout=10
            )
            findings.append({
                'test': 'saml_acs_access',
                'status_code': resp.status_code,
                'note': 'SAML Assertion Consumer Service endpoint'
            })
        except requests.RequestException:
            pass

        return findings

    def test_zero_trust_controls(self, endpoints):
        """Test Zero Trust implementation (OMB M-22-09)."""
        findings = []

        # Test 1: Device trust verification
        for endpoint in endpoints[:5]:
            try:
                resp = self.session.get(
                    f'{self.base_url}{endpoint}',
                    timeout=10
                )
                # Check for device trust headers
                device_trust = resp.headers.get(
                    'X-Device-Trust', 'none'
                )
                findings.append({
                    'endpoint': endpoint,
                    'device_trust': device_trust,
                    'note': 'Verify device trust is enforced'
                })
            except requests.RequestException:
                continue

        return findings

    def run_iam_assessment(self):
        """Run complete IAM assessment."""
        results = {
            'piv_cac': self.test_piv_cac_authentication('/auth'),
            'ldap_injection': self.test_ldap_injection('/api/search'),
            'saml': self.test_saml_security('/saml'),
            'zero_trust': self.test_zero_trust_controls([
                '/api/v1/data', '/api/v1/users'
            ]),
        }

        total_findings = sum(
            len(v) for v in results.values()
        )
        results['summary'] = {
            'total_findings': total_findings
        }

        return results
```

---

## Tool Arsenal

### Primary Tools

```bash
# Government security scanning
nuclei -u https://target.gov -tags cve,fisma,fedramp
httpx -u https://target.gov -sc -title -tech-detect
nikto -h https://target.gov

# Compliance scanning
python -c "
import requests

def fisma_quick_check(url):
    checks = []
    resp = requests.get(url, timeout=10, verify=True)

    # TLS check
    checks.append(('TLS', resp.url.startswith('https://')))

    # HSTS check
    hsts = resp.headers.get('Strict-Transport-Security')
    checks.append(('HSTS', hsts is not None))

    # Security headers
    headers_check = [
        'X-Content-Type-Options',
        'X-Frame-Options',
        'Content-Security-Policy',
    ]
    for h in headers_check:
        checks.append((h, h in resp.headers))

    for name, passed in checks:
        status = 'PASS' if passed else 'FAIL'
        print(f'  [{status}] {name}')

fisma_quick_check('https://target.gov')
"
```

```bash
# Active Directory security testing
python -c "
from ldap3 import Server, Connection, ALL

def test_ldap_bind(host, port=389):
    try:
        server = Server(host, port, get_info=ALL)
        conn = Connection(server, auto_bind=True)
        print(f'Anonymous bind: {conn.result}')
        conn.unbind()
    except Exception as e:
        print(f'LDAP bind error: {e}')

# Test anonymous LDAP bind (authorization required)
# test_ldap_bind('dc.target.gov')
"
```

---

## Real-World Examples

### Example 1: Federal Agency .gov Website Information Disclosure

**Scenario**: A federal agency's website exposed internal configuration.

**Discovery**:
```
GET /actuator/env
Response: 200 OK
{
  "activeProfiles": ["production"],
  "propertySources": [{
    "name": "application.properties",
    "properties": {
      "db.password": "encrypted_db_password",
      "api.key": "internal_api_key",
      "ldap.password": "ldap_bind_password"
    }
  }]
}
```

**Root Cause**: Spring Boot Actuator endpoints exposed in production without authentication.

**Impact**: Disclosure of internal configuration, potential credential exposure.

### Example 2: FedRAMP Cloud Multi-Tenant Isolation Failure

**Scenario**: A FedRAMP-authorized SaaS platform allowed cross-tenant data access.

**Discovery**:
```
GET /api/v1/tenants/OTHER_AGENCY/data
Authorization: Bearer <OUR_TENANT_TOKEN>

Response: 200 OK
{
  "data": [...other agency's data...],
  "tenant": "OTHER_AGENCY"
}
```

**Root Cause**: API did not validate tenant ID against the token's tenant claim.

**Impact**: Cross-agency data exposure. Violation of FedRAMP data isolation requirements.

### Example 3: SAML Authentication Bypass via Comment Injection

**Scenario**: A government portal used SAML for SSO with Login.gov.

**Discovery**:
```
SAML Response with comment injection:
<NameID>admin@agency.gov<!--evil-->@attacker.com</NameID>

Parser sees: admin@agency.gov
Signature verification: passes (comment is outside signed element)
```

**Root Cause**: SAML parser accepted comments within the NameID field.

**Impact**: Authentication bypass, admin account impersonation.

---

## Bypass Techniques

### FISMA Control Bypass

```
Technique 1: Actuator Endpoint Bypass
+------------------------------------------------------------------+
| If WAF/IPS blocks /actuator:                                     |
|   Try: /manage/health                                            |
|   Try: /internal/metrics                                         |
|   Try: /debug/pprof                                              |
|   Try: /env (Spring Boot 1.x)                                   |
|   Try: /jolokia (JMX over HTTP)                                 |
+------------------------------------------------------------------+

Technique 2: PIV/CAC Bypass
+------------------------------------------------------------------+
| If PIV is required but implementation is weak:                   |
|   1. Test if password fallback exists                            |
|   2. Test if derived credentials are accepted                    |
|   3. Test if PIV certificate is validated properly              |
|   4. Test if expired PIV certificates are accepted              |
+------------------------------------------------------------------+

Technique 3: Cloud Boundary Bypass
+------------------------------------------------------------------+
| If FedRAMP boundary blocks certain requests:                     |
|   1. Test via cloud metadata endpoints                          |
|   2. Test via cloud service APIs (S3, Lambda)                   |
|   3. Test via cloud management console                          |
|   4. Test cross-region access                                    |
+------------------------------------------------------------------+
```

---

## Common Pitfalls

### 1. Confusing Compliance with Security

```
FISMA/FedRAMP Compliance vs Actual Security:
+------------------------------------------------------------------+
| Compliance:                                                       |
|   - POA&M items tracked                                          |
|   - Annual assessments completed                                  |
|   - Security controls documented                                  |
|   - Continuous monitoring reported                                |
|                                                                    |
| Actual Security:                                                  |
|   - Controls actually implemented and tested                     |
|   - Vulnerabilities remediated in timely manner                  |
|   - Security operations effective                                 |
|   - Incident response practiced                                   |
|                                                                    |
| Finding: Systems can be FISMA compliant but still vulnerable    |
+------------------------------------------------------------------+
```

### 2. Legacy System Challenges

| System Age | Challenge | Risk |
|------------|-----------|------|
| 20+ years | COBOL mainframe, no API | Limited testing surface |
| 15-20 years | Windows Server 2008 | Unpatched OS |
| 10-15 years | Custom .NET applications | Deprecated frameworks |
| 5-10 years | Early cloud migration | Misconfigured cloud |

### 3. Reporting to Government Auditors

```
FISMA Audit Reporting Requirements:
+------------------------------------------------------------------+
| POA&M (Plan of Action and Milestones):                           |
|   - Item description                                             |
|   - Weakness description                                         |
|   - Expected remediation date                                    |
|   - Milestones                                                    |
|   - Resources required                                           |
|                                                                    |
| Annual Security Assessment:                                      |
|   - FISMA metrics (CM effectiveness, etc.)                      |
|   - Vulnerability scan results                                   |
|   - Penetration test findings                                    |
|   - Incident response metrics                                    |
+------------------------------------------------------------------+
```

---

## Reporting Template

```markdown
# Government System Security Assessment Report

## Executive Summary
- **Agency**: [Agency Name]
- **System**: [System Name and Authorization Boundary]
- **Assessment Date**: [Date]
- **Framework**: FISMA / FedRAMP / NIST 800-53
- **Authorization Status**: [ATO / Pending / Expired]

## Findings Summary
| # | Finding | NIST Control | Severity | POA&M |
|---|---------|--------------|----------|-------|
| 1 | [Finding] | AC-6 | CRITICAL | Yes |

## Detailed Findings

### Finding 1: [Title]
- **NIST 800-53 Control**: [Control ID]
- **Assessment Method**: [Test/Interview/Examine]
- **Description**: [Technical detail]
- **Risk Level**: [Critical/High/Medium/Low]
- **Citizen Impact**: [How this affects citizens]
- **Recommendation**: [Remediation]
- **Remediation Timeline**: [30/60/90 days]

## Compliance Status
| NIST Control | Status | Notes |
|--------------|--------|-------|
| AC-2 Account Mgmt | PASS/FAIL | |
| AC-6 Least Privilege | PASS/FAIL | |
| IA-2 MFA | PASS/FAIL | |
| SC-8 Encryption | PASS/FAIL | |
| AU-2 Audit Events | PASS/FAIL | |

## POA&M Items
| ID | Weakness | Target Date | Owner | Status |
|----|----------|-------------|-------|--------|
| POA&M-001 | [Weakness] | [Date] | [Team] | Open |

## Appendices
A. Systems Tested
B. Security Control Assessment Results
C. Vulnerability Scan Results
D. Penetration Test Methodology
```

---

## Quick Reference

### Critical .gov Endpoints

```
Public APIs:
  GET  /api/v1/public/data         # Public data
  GET  /api/v1/agency/info         # Agency information

Admin Endpoints:
  GET  /admin/dashboard            # Admin panel
  GET  /admin/users                # User management
  GET  /admin/config               # Configuration

Cloud Endpoints:
  GET  /actuator                   # Spring Boot actuator
  GET  /actuator/env               # Environment variables
  GET  /actuator/health            # Health check
  GET  /metrics                    # Application metrics

Identity:
  POST /auth/piv                   # PIV authentication
  POST /saml/acs                   # SAML ACS
  GET  /oidc/authorize             # OIDC authorization
  GET  /.well-known/openid-configuration
```

### NIST 800-53 Critical Controls

```
Access Control (AC):
  AC-2: Account Management
  AC-3: Access Enforcement
  AC-6: Least Privilege
  AC-7: Unsuccessful Logon Attempts
  AC-17: Remote Access

Identification (IA):
  IA-2: Identification and Auth
  IA-2(1): MFA
  IA-2(2): PKI-Based Auth
  IA-5: Authenticator Management

Audit (AU):
  AU-2: Audit Events
  AU-3: Content of Audit Records
  AU-6: Audit Record Review

System Protection (SC):
  SC-7: Boundary Protection
  SC-8: Confidentiality/Integrity
  SC-13: Cryptographic Protection
  SC-28: Protection at Rest
```

### Severity Decision Matrix

| Finding | FISMA Impact | Citizen Impact | Severity |
|---------|-------------|----------------|----------|
| PIV bypass possible | IA-2 violation | Identity compromise | CRITICAL |
| Cross-tenant data leak | SC-7 violation | Privacy breach | CRITICAL |
| Actuator exposed | SC-7 violation | Config disclosure | HIGH |
| Missing HSTS | SC-8 violation | Data interception | MEDIUM |
| Info leakage headers | CM-7 violation | Reconnaissance aid | LOW |

### References

- NIST SP 800-53 Rev 5: https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
- FISMA: https://www.cisa.gov/federal-information-security-modernization-act
- FedRAMP: https://www.fedramp.gov/
- NIST 800-171 (CUI): https://csrc.nist.gov/publications/detail/sp/800-171/rev-2/final
- OMB M-22-09 (Zero Trust): https://www.whitehouse.gov/wp-content/uploads/2022/01/M-22-09.pdf
- Login.gov: https://login.gov/
