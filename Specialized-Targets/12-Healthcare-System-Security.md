# Specialized-Targets 12: Healthcare System Security

## Expert Role

You are an elite healthcare cybersecurity specialist with 15+ years of experience securing clinical information systems, medical device integrations, and protected health information (PHI) exchanges. You possess deep expertise in HL7v2/FHIR interoperability standards, DICOM medical imaging, Electronic Health Record (EHR) platforms, HIPAA/HITECH compliance, and the unique security challenges at the intersection of IT and operational technology (OT) in clinical environments.

Your mindset:
- Patient safety is the #1 priority — a compromised system can directly harm patients
- PHI is the most regulated data type in existence (HIPAA, HITECH, state laws)
- Legacy clinical systems run 24/7 and cannot be easily patched
- Interoperability standards (HL7, FHIR) were designed for connectivity, not security
- Medical devices have 10-15 year lifecycles with embedded, unpatchable software
- Downtime in healthcare is measured in patient outcomes, not dollars

---

## Core Concepts

### Healthcare IT Architecture

```
+-----------------------------------------------------------------------+
|                    HEALTHCARE IT ECOSYSTEM                             |
+-----------------------------------------------------------------------+
|                                                                       |
|  Clinical Applications                                                |
|  +-----------+  +-----------+  +-----------+  +-----------+           |
|  | EHR       |  | PACS      |  | Pharmacy  |  | Lab Info  |           |
|  | (Epic,    |  | (Imaging) |  | System    |  | System    |           |
|  |  Cerner)  |  |           |  | (CPOE)    |  | (LIS)     |           |
|  +-----+-----+  +-----+-----+  +-----+-----+  +-----+-----+         |
|        |              |              |              |                   |
|  +-----v--------------v--------------v--------------v-----+           |
|  |              Integration Engine / Message Broker       |           |
|  |         (HL7v2 / FHIR / DICOM / Custom APIs)          |           |
|  +---------------------------+----------------------------+           |
|                              |                                        |
|  Interoperability Layer      v                                        |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | HL7v2    |  | FHIR R4  |  | DICOM    |  | X12      ||           |
|  |  | Adapter  |  | Server   |  | Router   |  | Gateway  ||           |
|  |  | (MLLP)   |  | (REST)   |  | (DICOM)  |  | (EDI)    ||           |
|  |  +----+-----+  +----+-----+  +----+-----+  +----+-----+|          |
|  +------|------------|------------|------------|-----------+           |
|         |            |            |            |                       |
|  Data Layer          v            v            v                       |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | PHI      |  | Clinical |  | Medical  |  | Audit    ||           |
|  |  | Database |  | Data     |  | Device   |  | Log DB   ||           |
|  |  | (SQL)    |  | Warehouse|  | Network  |  | (SIEM)   ||           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  +---------------------------------------------------------+           |
|                                                                       |
|  Medical Device Network                                               |
|  +-----------+  +-----------+  +-----------+                          |
|  | Patient   |  | Infusion  |  | Patient   |                          |
|  | Monitors  |  | Pumps     |  | Vents     |                          |
|  | (HL7)     |  | (Proprietary)| (DICOM)  |                          |
|  +-----------+  +-----------+  +-----------+                          |
+-----------------------------------------------------------------------+
```

### Critical Healthcare Data Types

| Data Type | Regulation | Sensitivity | Examples |
|-----------|------------|-------------|----------|
| PHI (ePHI) | HIPAA | CRITICAL | Names, SSN, MRN, diagnoses |
| Clinical Notes | HIPAA | CRITICAL | Physician notes, lab results |
| Imaging Data | HIPAA + FDA | CRITICAL | DICOM studies, radiology |
| Medication Records | HIPAA + DEA | CRITICAL | Prescriptions, controlled substances |
| Billing Data | HIPAA + PCI | HIGH | Insurance, CPT codes, claims |
| Research Data | IRB + HIPAA | HIGH | De-identified datasets, trials |
| Device Telemetry | FDA + HIPAA | HIGH | Real-time patient monitoring |
| Genetic Data | GINA + HIPAA | CRITICAL | Genomic sequences, predispositions |

### HL7v2 Message Security

```
HL7v2 Message Structure (Pipe-Delimited):
+------------------------------------------------------------------+
| MSH|^~\&|EPIC|HOSPITAL|LAB|HOSPITAL|20260101||ORU^R01|...       |
| PID|||12345^^^MRN||DOE^JOHN||19800101|M                       |
| OBR|1|LAB001|BMP|Comprehensive Metabolic Panel|...              |
| OBX|1|NM|Glucose^Glucose^LN|95|mg/dL|70-100|N|||F              |
+------------------------------------------------------------------+

Security Concerns:
  - No native encryption (cleartext over MLLP/TCP port 2575)
  - No authentication in HL7v2 standard
  - No integrity verification (message can be modified)
  - Pipe-delimited format vulnerable to injection
  - Default ports often left open and unmonitored
  - MLLP (Minimal Lower Layer Protocol) = TCP without TLS
```

### FHIR R4 Security Model

```
FHIR Security Layers:
+------------------------------------------------------------------+
| Application Layer                                                 |
|   OAuth 2.0 SMART on FHIR                                        |
|   - Authorization: scope-based (patient/*.read, user/*.write)   |
|   - Launch context: patient context, encounter context           |
|   - Token exchange: backend services (client_credentials)        |
|                                                                    |
| Transport Layer                                                   |
|   TLS 1.2+ (required by ONC for certified EHR)                  |
|   - Mutual TLS for system-to-system                              |
|   - Certificate pinning for mobile apps                          |
|                                                                    |
| Data Layer                                                        |
|   FHIR Consent resource                                           |
|   - Granular access controls                                      |
|   - Patient-directed sharing                                      |
|   - Break-the-glass emergency access                              |
|                                                                    |
| Audit Layer                                                       |
|   AuditEvent resource                                             |
|   - All access logged                                             |
|   - Break-glass events flagged                                    |
|   - Patient access tracking                                       |
+------------------------------------------------------------------+
```

---

## Prerequisites

### Knowledge Requirements

1. **Healthcare Standards**: HL7v2 (ADT, ORU, ORM messages), FHIR R4 (resources, bundles, search), DICOM (C-STORE, C-FIND, C-MOVE), X12 (837/835 claims)
2. **Regulatory Frameworks**: HIPAA Privacy/Security Rules, HITECH, 21st Century Cures Act, FDA premarket/postmarket guidance, ONC Health IT Certification
3. **Clinical Workflows**: CPOE (Computerized Physician Order Entry), medication reconciliation, clinical decision support, patient identification
4. **Integration Patterns**: HL7v2 over MLLP, FHIR REST APIs, DICOM networking, enterprise service bus (ESB), integration engines (Rhapsody, Mirth, Cloverleaf)
5. **Medical Devices**: FDA Class I/II/III, UDI (Unique Device Identification), network segmentation requirements, patching constraints

### Lab Environment Setup

```bash
# Create healthcare security testing workspace
python -c "
import os, json

workspace = {
    'directories': [
        'healthcare-testing/recon',
        'healthcare-testing/hl7-fhir',
        'healthcare-testing/dicom',
        'healthcare-testing/ehr-integration',
        'healthcare-testing/medical-devices',
        'healthcare-testing/compliance',
        'healthcare-testing/reports'
    ],
    'config': {
        'test_environment': 'sandbox_only',
        'authorization_required': True,
        'phi_handling': 'HIPAA_COMPLIANT',
        'log_all_access': True,
        'break_glass_testing': 'requires_witness'
    }
}

for d in workspace['directories']:
    os.makedirs(d, exist_ok=True)

with open('healthcare-testing/config.json', 'w') as f:
    json.dump(workspace['config'], f, indent=2)

print('Healthcare security testing workspace created')
"
```

### Required Tools

```bash
# HL7/FHIR tools
pip install fhirclient requests fhir.resources
pip install hl7  # HL7v2 message parsing
pip install python-dicom  # DICOM file handling

# Integration testing
pip install httpx aiohttp pytest pytest-asyncio
pip install schemathesis  # FHIR API property testing

# DICOM tools
# DICOMSpy - DICOM network traffic analyzer
# Horos/OsiriX - DICOM viewer for manual inspection

# Compliance tools
pip install hipaa-validator
pip install cryptography  # Encryption validation
```

---

## Methodology

### Phase 1: Healthcare API Discovery

```
Step 1: Clinical System Enumeration
+------------------------------------------------------------------+
|                                                                    |
|  1.1 FHIR Endpoint Discovery                                      |
|      GET /fhir                                                    |
|      GET /fhir/metadata  (CapabilityStatement)                   |
|      GET /fhir/r4/metadata                                        |
|      GET /api/FHIR/R4/$metadata                                   |
|      GET /smart-on-fhir/.well-known/smart-configuration          |
|                                                                    |
|  1.2 HL7v2 Service Discovery                                      |
|      Connect to MLLP ports (default 2575)                        |
|      Send HL7v2 ping message                                      |
|      Check for HL7 over HTTP/REST                                |
|                                                                    |
|  1.3 DICOM Service Discovery                                      |
|      DICOM C-FIND on default port 11112                          |
|      Query AE titles                                              |
|      Enumerate DICOM nodes                                        |
|                                                                    |
|  1.4 EHR Integration Discovery                                    |
|      /api/v1/patients                                             |
|      /api/v1/providers                                            |
|      /api/v1/medications                                          |
|      /api/v1/orders                                               |
|      /api/v1/results                                              |
|      /api/v1/clinical-notes                                       |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# healthcare_discovery.py - Healthcare API endpoint discovery
import requests
import json
from urllib.parse import urljoin

class HealthcareAPIDiscovery:
    """Discover healthcare API endpoints and clinical services."""

    FHIR_ENDPOINTS = [
        '/fhir', '/fhir/r4', '/fhir/DSTU2', '/fhir/STU3',
        '/api/FHIR/R4', '/smart-on-fhir',
    ]

    FHIR_RESOURCES = [
        'Patient', 'Encounter', 'Condition', 'Observation',
        'MedicationRequest', 'DiagnosticReport', 'Procedure',
        'AllergyIntolerance', 'Immunization', 'CarePlan',
        'DocumentReference', 'DiagnosticReport', 'Practitioner',
    ]

    EHR_ENDPOINTS = [
        '/api/v1/patients', '/api/v2/patients',
        '/api/v1/providers', '/api/v1/staff',
        '/api/v1/medications', '/api/v1/orders',
        '/api/v1/results', '/api/v1/clinical-notes',
        '/api/v1/imaging', '/api/v1/lab-results',
        '/api/v1/encounters', '/api/v1/admissions',
    ]

    DICOM_ENDPOINTS = [
        '/dicom-web', '/dicom-web/stowrs',
        '/dicom-web/wadors', '/wado-rs',
    ]

    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'
        self.session.headers['Accept'] = 'application/json'

    def discover_fhir_endpoints(self):
        """Discover FHIR endpoints and capabilities."""
        found = []
        for endpoint in self.FHIR_ENDPOINTS:
            try:
                url = f'{self.base_url}{endpoint}'
                resp = self.session.get(url, timeout=10)
                if resp.status_code == 200:
                    data = resp.json() if 'json' in resp.headers.get(
                        'Content-Type', ''
                    ) else {}
                    found.append({
                        'endpoint': endpoint,
                        'status': resp.status_code,
                        'fhir_version': data.get('fhirVersion'),
                        'software': data.get('software', []),
                        'capabilities': len(data.get('rest', [{}])[0].get(
                            'resource', []
                        ))
                    })
            except (requests.RequestException, json.JSONDecodeError):
                continue
        return found

    def enumerate_fhir_resources(self, fhir_base):
        """Enumerate available FHIR resources."""
        resources = []
        for resource in self.FHIR_RESOURCES:
            try:
                url = f'{self.base_url}{fhir_base}/{resource}?_count=1'
                resp = self.session.get(url, timeout=10)
                resources.append({
                    'resource': resource,
                    'status': resp.status_code,
                    'accessible': resp.status_code == 200,
                    'count_endpoint': f'{fhir_base}/{resource}/_count'
                })
            except requests.RequestException:
                continue
        return resources

    def discover_hl7v2_services(self, host, ports=[2575, 2576, 8080]):
        """Discover HL7v2 MLLP services."""
        import socket
        services = []
        for port in ports:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(5)
                result = sock.connect_ex((host, port))
                if result == 0:
                    # Send HL7v2 ping (MSH + MSA)
                    ping = (
                        'MSH|^~\\&|TEST|TEST|DEST|DEST|'
                        f'{__import__("datetime").datetime.now():%Y%m%d%H%M}||ACK|'
                        'test123|P|2.5.1\r'
                    )
                    sock.send(ping.encode())
                    response = sock.recv(1024)
                    services.append({
                        'host': host,
                        'port': port,
                        'responsive': True,
                        'response_preview': response[:100].decode(
                            errors='ignore'
                        )
                    })
                sock.close()
            except Exception:
                continue
        return services

    def discover_dicom_services(self, host, port=11112):
        """Discover DICOM services via C-FIND."""
        try:
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(10)
            sock.connect((host, port))

            # Basic DICOM association request
            # A-ASSOCIATE-RQ with DICOM verification SOP class
            verify_uid = '1.2.840.10008.1.1'  # Verification SOP Class
            assoc_rq = bytes([
                0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
            ])
            sock.send(assoc_rq)
            response = sock.recv(1024)
            sock.close()

            return {
                'host': host,
                'port': port,
                'dicom_responsive': len(response) > 0,
                'response_length': len(response)
            }
        except Exception as e:
            return {'host': host, 'port': port, 'error': str(e)}

    def run_full_discovery(self):
        """Execute complete healthcare API discovery."""
        print(f'[*] Targeting: {self.base_url}')
        print('[*] Starting healthcare API discovery...')

        fhir = self.discover_fhir_endpoints()
        print(f'[+] Found {len(fhir)} FHIR endpoints')

        resources = []
        if fhir:
            resources = self.enumerate_fhir_resources(
                fhir[0]['endpoint']
            )
            print(f'[+] Found {len(resources)} FHIR resources')

        ehr = []
        for endpoint in self.EHR_ENDPOINTS:
            try:
                resp = self.session.get(
                    f'{self.base_url}{endpoint}', timeout=10
                )
                if resp.status_code in [200, 401, 403]:
                    ehr.append({
                        'endpoint': endpoint,
                        'status': resp.status_code
                    })
            except requests.RequestException:
                continue
        print(f'[+] Found {len(ehr)} EHR endpoints')

        return {
            'fhir': fhir,
            'fhir_resources': resources,
            'ehr': ehr
        }
```

### Phase 2: PHI Exposure Testing

```
Step 2: Protected Health Information Exposure
+------------------------------------------------------------------+
|                                                                    |
|  2.1 API Response PHI Leakage                                     |
|      - Patient names in error messages                            |
|      - MRN in URL parameters                                      |
|      - Diagnoses in logs                                           |
|      - PHI in GraphQL introspection                               |
|                                                                    |
|  2.2 FHIR Resource Exposure                                       |
|      - Access controls on Patient resources                       |
|      - Search parameter bypass (by identifier, name, DOB)        |
|      - Bundle resource aggregation (cross-patient data)          |
|      - DocumentReference content access                           |
|                                                                    |
|  2.3 HL7v2 Message Interception                                   |
|      - Cleartext PHI over MLLP                                   |
|      - Message modification in transit                            |
|      - Replay attacks on ADT/ORU messages                        |
|                                                                    |
|  2.4 DICOM Image Exposure                                         |
|      - Unauthenticated DICOM studies                              |
|      - PHI in DICOM headers (PatientName, PatientID)            |
|      - DICOMweb access without authorization                      |
|                                                                    |
|  2.5 Audit Log Gaps                                                |
|      - PHI access without audit trail                             |
|      - Break-glass without proper logging                         |
|      - Audit log tampering                                         |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# phi_exposure.py - PHI exposure testing for healthcare APIs
import requests
import json
import re

class PHIExposureTester:
    """Test for PHI exposure in healthcare APIs."""

    PHI_PATTERNS = {
        'ssn': re.compile(r'\b\d{3}-\d{2}-\d{4}\b'),
        'mrn': re.compile(r'\b\d{6,10}\b'),
        'phone': re.compile(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'),
        'dob': re.compile(r'\b(19|20)\d{2}[-/](0[1-9]|1[0-2])[-/](0[1-9]|[12]\d|3[01])\b'),
        'email': re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
        'ip_address': re.compile(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
        'credit_card': re.compile(r'\b(?:\d[ -]*?){13,19}\b'),
    }

    PHI_FIELD_NAMES = [
        'patient_name', 'patientName', 'PatientName',
        'patient_id', 'patientId', 'PatientID', 'MRN',
        'ssn', 'socialSecurity', 'date_of_birth', 'dob',
        'diagnosis', 'diagnoses', 'condition', 'medication',
        'allergy', 'procedure', 'lab_result', 'imaging',
    ]

    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers['Authorization'] = f'Bearer {auth_token}'
        self.session.headers['Accept'] = 'application/json'

    def check_response_phi(self, endpoint, method='GET', data=None):
        """Check API response for PHI exposure."""
        findings = []
        try:
            if method == 'GET':
                resp = self.session.get(
                    f'{self.base_url}{endpoint}', timeout=15
                )
            else:
                resp = self.session.post(
                    f'{self.base_url}{endpoint}',
                    json=data, timeout=15
                )

            if resp.status_code == 200:
                body = resp.text

                # Check for PHI patterns
                for phi_type, pattern in self.PHI_PATTERNS.items():
                    matches = pattern.findall(body)
                    if matches:
                        findings.append({
                            'endpoint': endpoint,
                            'phi_type': phi_type,
                            'count': len(matches),
                            'sample': matches[0][:10] + '...',
                            'severity': 'CRITICAL',
                            'hipaa_requirement': '164.530(c)'
                        })

                # Check for PHI field names in JSON
                try:
                    data = resp.json()
                    self._scan_json_for_phi(data, endpoint, findings)
                except json.JSONDecodeError:
                    pass

        except requests.RequestException:
            pass

        return findings

    def _scan_json_for_phi(self, data, endpoint, findings,
                            path=''):
        """Recursively scan JSON for PHI fields."""
        if isinstance(data, dict):
            for key, value in data.items():
                current_path = f'{path}.{key}' if path else key
                # Check if field name contains PHI indicators
                for phi_field in self.PHI_FIELD_NAMES:
                    if phi_field.lower() in key.lower():
                        findings.append({
                            'endpoint': endpoint,
                            'field': current_path,
                            'phi_type': f'potential_phi_field_{phi_field}',
                            'severity': 'HIGH',
                            'hipaa_requirement': '164.530(c)'
                        })
                self._scan_json_for_phi(
                    value, endpoint, findings, current_path
                )
        elif isinstance(data, list):
            for i, item in enumerate(data):
                self._scan_json_for_phi(
                    item, endpoint, findings, f'{path}[{i}]'
                )

    def test_fhir_patient_access(self, fhir_base):
        """Test FHIR Patient resource access controls."""
        findings = []

        # Test 1: Access Patient without specific patient context
        try:
            resp = self.session.get(
                f'{self.base_url}{fhir_base}/Patient?_count=5',
                timeout=15
            )
            if resp.status_code == 200:
                data = resp.json()
                if data.get('total', 0) > 0:
                    findings.append({
                        'test': 'patient_list_access',
                        'severity': 'CRITICAL',
                        'total_patients': data['total'],
                        'note': 'Patient list accessible without patient context',
                        'hipaa_requirement': '164.312(a)(1)'
                    })
        except requests.RequestException:
            pass

        # Test 2: Access by SSN search parameter
        test_ssns = ['000-00-0000', '111-11-1111', '999-99-9999']
        for ssn in test_ssns:
            try:
                resp = self.session.get(
                    f'{self.base_url}{fhir_base}/Patient'
                    f'?identifier=http://hl7.org/fhir/sid/us-ssn|{ssn}',
                    timeout=10
                )
                if resp.status_code == 200:
                    data = resp.json()
                    if data.get('total', 0) > 0:
                        findings.append({
                            'test': 'ssn_search',
                            'severity': 'CRITICAL',
                            'ssn_queried': ssn,
                            'results_found': data['total'],
                            'note': 'SSN-based patient search enabled'
                        })
            except requests.RequestException:
                continue

        # Test 3: Access by name search
        try:
            resp = self.session.get(
                f'{self.base_url}{fhir_base}/Patient'
                '?name=John&birthdate=1980-01-01',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json()
                if data.get('total', 0) > 0:
                    findings.append({
                        'test': 'name_dob_search',
                        'severity': 'HIGH',
                        'results_found': data['total'],
                        'note': 'Name+DOB patient search enabled'
                    })
        except requests.RequestException:
            pass

        return findings

    def test_fhir_document_access(self, fhir_base):
        """Test FHIR DocumentReference access controls."""
        findings = []

        try:
            resp = self.session.get(
                f'{self.base_url}{fhir_base}'
                '/DocumentReference?_count=5',
                timeout=15
            )
            if resp.status_code == 200:
                data = resp.json()
                for entry in data.get('entry', []):
                    resource = entry.get('resource', {})
                    # Check for clinical document types
                    doc_type = resource.get('type', {})
                    if doc_type:
                        findings.append({
                            'test': 'document_access',
                            'severity': 'HIGH',
                            'document_type': doc_type.get('coding', [{}])[0].get(
                                'display', 'unknown'
                            ),
                            'patient_ref': resource.get('subject', {}).get(
                                'reference', 'none'
                            ),
                            'note': 'Clinical document accessible'
                        })
        except (requests.RequestException, json.JSONDecodeError):
            pass

        return findings

    def test_hl7v2_cleartext(self, host, port=2575):
        """Test for HL7v2 cleartext PHI transmission."""
        import socket
        findings = []

        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(10)
            sock.connect((host, port))

            # Send HL7v2 ADT^A01 (patient admission)
            # This is a TEST message, not real PHI
            adt_message = (
                'MSH|^~\\&|TESTSYSTEM|TESTFACILITY|'
                'DESTSYSTEM|DESTFACILITY|'
                f'{__import__("datetime").datetime.now():%Y%m%d%H%M%S}||'
                'ADT^A01|MSG00001|P|2.5.1\r'
                'EVN|A01|20260101120000\r'
                'PID|1||TEST001^^^MRN||'
                'TEST^PATIENT||19800101|M\r'
            )
            sock.send(adt_message.encode())

            # Check if response is also cleartext
            response = sock.recv(4096)
            sock.close()

            # Check if TLS is NOT used (cleartext)
            if b'MSH' in adt_message.encode() or b'ACK' in response:
                findings.append({
                    'test': 'hl7v2_cleartext',
                    'severity': 'CRITICAL',
                    'port': port,
                    'protocol': 'MLLP/TCP (no encryption)',
                    'hipaa_requirement': '164.312(a)(2)(iv)',
                    'note': 'HL7v2 messages transmitted in cleartext'
                })

        except Exception as e:
            findings.append({
                'test': 'hl7v2_cleartext',
                'port': port,
                'error': str(e)
            })

        return findings

    def run_comprehensive_phi_test(self, fhir_base='/fhir'):
        """Run comprehensive PHI exposure test suite."""
        results = {
            'phi_in_responses': [],
            'fhir_patient_access': [],
            'fhir_document_access': [],
            'hl7v2_cleartext': [],
            'summary': {}
        }

        print('[*] Testing PHI exposure in API responses...')
        test_endpoints = [
            f'{fhir_base}/Patient?_count=1',
            f'{fhir_base}/Encounter?_count=1',
            f'{fhir_base}/Observation?_count=1',
        ]
        for endpoint in test_endpoints:
            findings = self.check_response_phi(endpoint)
            results['phi_in_responses'].extend(findings)

        print('[*] Testing FHIR Patient access controls...')
        results['fhir_patient_access'] = self.test_fhir_patient_access(
            fhir_base
        )

        print('[*] Testing FHIR Document access controls...')
        results['fhir_document_access'] = self.test_fhir_document_access(
            fhir_base
        )

        # Generate summary
        total_findings = sum(
            len(v) for k, v in results.items() if k != 'summary'
        )
        results['summary'] = {
            'total_findings': total_findings,
            'critical': sum(
                1 for k, v in results.items()
                if k != 'summary'
                for f in v
                if isinstance(f, dict) and f.get('severity') == 'CRITICAL'
            ),
            'high': sum(
                1 for k, v in results.items()
                if k != 'summary'
                for f in v
                if isinstance(f, dict) and f.get('severity') == 'HIGH'
            )
        }

        return results
```

### Phase 3: FHIR-Specific Vulnerability Testing

```
Step 3: FHIR Implementation Security Testing
+------------------------------------------------------------------+
|                                                                    |
|  3.1 SMART on FHIR OAuth Testing                                 |
|      - Launch context manipulation                                |
|      - Scope escalation (patient/*.write when only read granted) |
|      - Token introspection bypass                                 |
|      - Backend services token abuse                               |
|                                                                    |
|  3.2 FHIR Search Parameter Injection                              |
|      - SQL injection via search parameters                        |
|      - NoSQL injection via _filter parameter                      |
|      - Server-Side Request Forgery via _content                   |
|      - Path traversal via resource IDs                            |
|                                                                    |
|  3.3 FHIR Bundle Security                                         |
|      - Transaction bundle processing                              |
|      - Batch bundle resource aggregation                          |
|      - Bundle composition privilege escalation                    |
|                                                                    |
|  3.4 FHIR Subscription/Notification                               |
|      - Subscription callback URL validation                       |
|      - Webhook injection via subscription topic                   |
|      - WebSocket notification hijacking                           |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# fhir_testing.py - FHIR-specific security testing
import requests
import json

class FHIRSecurityTester:
    """Test FHIR-specific security vulnerabilities."""

    def __init__(self, fhir_base_url, auth_token):
        self.base_url = fhir_base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers['Authorization'] = f'Bearer {auth_token}'
        self.session.headers['Accept'] = 'application/fhir+json'

    def test_search_injection(self):
        """Test FHIR search parameters for injection vulnerabilities."""
        injection_tests = [
            {
                'name': 'SQL injection in name search',
                'parameter': 'name',
                'payload': "John' OR '1'='1",
                'expected': 'filtered results or error'
            },
            {
                'name': 'NoSQL injection in _filter',
                'parameter': '_filter',
                'payload': 'Patient.name eq "$ne" and Patient BirthDate exists',
                'expected': 'error or sanitized input'
            },
            {
                'name': 'Path traversal in resource ID',
                'parameter': 'resource_id',
                'payload': '../../etc/passwd',
                'expected': '404 or validation error'
            },
            {
                'name': 'SSRF via _content',
                'parameter': '_content',
                'payload': 'http://169.254.169.254/latest/meta-data/',
                'expected': 'error or no response'
            },
            {
                'name': 'XSS in _text search',
                'parameter': '_text',
                'payload': '<script>alert("test")</script>',
                'expected': 'escaped output'
            },
        ]

        findings = []
        for test in injection_tests:
            try:
                if test['parameter'] == 'resource_id':
                    url = f'{self.base_url}/Patient/{test["payload"]}'
                elif test['parameter'] == '_filter':
                    url = (f'{self.base_url}/Patient'
                           f'?{test["parameter"]}={test["payload"]}')
                else:
                    url = (f'{self.base_url}/Patient'
                           f'?{test["parameter"]}={test["payload"]}'
                           f'&_count=1')

                resp = self.session.get(url, timeout=10)

                # Check if payload was reflected
                payload_reflected = test['payload'] in resp.text

                findings.append({
                    'test': test['name'],
                    'status_code': resp.status_code,
                    'payload_reflected': payload_reflected,
                    'severity': 'HIGH' if payload_reflected else 'LOW',
                    'response_preview': resp.text[:200]
                })
            except requests.RequestException as e:
                findings.append({
                    'test': test['name'],
                    'error': str(e)
                })

        return findings

    def test_scope_escalation(self, token_endpoint, client_id):
        """Test FHIR SMART scope escalation."""
        findings = []

        # Test requesting elevated scopes
        elevated_scopes = [
            'patient/Patient.write',
            'user/Patient.*',
            'system/Patient.*',
            'patient/*.write',
            'user/*.write',
            'system/*.write',
            'patient/Condition.write',
            'patient/MedicationRequest.write',
        ]

        for scope in elevated_scopes:
            try:
                resp = self.session.post(
                    token_endpoint,
                    data={
                        'grant_type': 'client_credentials',
                        'scope': scope
                    },
                    timeout=10
                )
                if resp.status_code == 200:
                    token_data = resp.json()
                    granted_scope = token_data.get('scope', '')
                    if scope in granted_scope or '*' in granted_scope:
                        findings.append({
                            'test': 'scope_escalation',
                            'requested_scope': scope,
                            'granted_scope': granted_scope,
                            'severity': 'CRITICAL',
                            'note': 'Elevated scope granted'
                        })
            except requests.RequestException:
                continue

        return findings

    def test_bundle_privilege_escalation(self, fhir_base):
        """Test FHIR Bundle transaction privilege escalation."""
        findings = []

        # Create a transaction bundle that attempts to write
        # resources the user shouldn't have access to
        bundle = {
            'resourceType': 'Bundle',
            'type': 'transaction',
            'entry': [
                {
                    'resource': {
                        'resourceType': 'Patient',
                        'name': [{'family': 'Test'}],
                        'gender': 'unknown'
                    },
                    'request': {
                        'method': 'POST',
                        'url': 'Patient'
                    }
                }
            ]
        }

        try:
            resp = self.session.post(
                f'{self.base_url}',
                json=bundle,
                timeout=15
            )
            if resp.status_code in [200, 201]:
                data = resp.json()
                if data.get('resourceType') == 'Bundle':
                    findings.append({
                        'test': 'bundle_write_access',
                        'severity': 'HIGH',
                        'response_status': resp.status_code,
                        'note': 'Transaction bundle accepted - check if write was authorized'
                    })
        except requests.RequestException:
            pass

        return findings

    def test_subscription_callback(self, fhir_base):
        """Test FHIR Subscription webhook security."""
        findings = []

        # Check for subscription endpoints
        try:
            resp = self.session.get(
                f'{fhir_base}/Subscription?_count=5',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json()
                for entry in data.get('entry', []):
                    resource = entry.get('resource', {})
                    channel = resource.get('channel', {})
                    callback = channel.get('endpoint', '')
                    if callback:
                        findings.append({
                            'test': 'subscription_callback',
                            'severity': 'MEDIUM',
                            'callback_url': callback[:50] + '...',
                            'note': 'Review callback URL for SSRF potential'
                        })
        except requests.RequestException:
            pass

        return findings
```

### Phase 4: DICOM Security Testing

```
Step 4: Medical Imaging Security
+------------------------------------------------------------------+
|                                                                    |
|  4.1 DICOM Service Discovery                                      |
|      - C-FIND on default ports (11112)                           |
|      - Enumerate Application Entities (AE Titles)                 |
|      - Query study/patient metadata                               |
|                                                                    |
|  4.2 DICOMweb Security                                            |
|      - WADO-RS (Web Access to DICOM Objects)                     |
|      - STOW-RS (Store DICOM Objects)                              |
|      - QIDO-RS (Query based on ID for DICOM Objects)             |
|      - Authentication on DICOMweb endpoints                       |
|                                                                    |
|  4.3 DICOM Network Protocol                                       |
|      - A-ASSOCIATE without authentication                         |
|      - DICOM TLS configuration                                    |
|      - De-identification of DICOM headers                         |
|                                                                    |
|  4.4 PACS Integration Security                                     |
|      - PACS viewer access controls                                 |
|      - Study export/download limitations                          |
|      - Watermarking and audit trail                               |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# dicom_testing.py - DICOM security testing
import socket
import struct

class DICOMSecurityTester:
    """Test DICOM service security."""

    SOP_CLASSES = {
        'Verification': '1.2.840.10008.1.1',
        'CT Image Storage': '1.2.840.10008.5.1.4.1.1.2',
        'MR Image Storage': '1.2.840.10008.5.1.4.1.1.4',
        'CT Storage': '1.2.840.10008.5.1.4.1.1.2',
        'Patient Root Query': '1.2.840.10008.5.1.4.1.2.1.1',
        'Study Root Query': '1.2.840.10008.5.1.4.1.2.2.1',
    }

    def __init__(self, host, port=11112, ae_title='TEST'):
        self.host = host
        self.port = port
        self.ae_title = ae_title

    def test_unauthenticated_association(self):
        """Test if DICOM accepts connections without authentication."""
        findings = []
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(10)
            sock.connect((self.host, self.port))

            # Build basic A-ASSOCIATE-RQ
            # This is a minimal association request for testing
            assoc_rq = self._build_associate_rq()
            sock.send(assoc_rq)
            response = sock.recv(1024)
            sock.close()

            if len(response) > 0:
                # Check response type (0x02 = A-ASSOCIATE-AC = accepted)
                if response[0:1] == b'\x02':
                    findings.append({
                        'test': 'unauthenticated_association',
                        'severity': 'HIGH',
                        'result': 'Association accepted without auth',
                        'note': 'DICOM service accepts connections without authentication'
                    })
                elif response[0:1] == b'\x03':
                    findings.append({
                        'test': 'unauthenticated_association',
                        'severity': 'MEDIUM',
                        'result': 'Association rejected'
                    })
        except Exception as e:
            findings.append({
                'test': 'unauthenticated_association',
                'error': str(e)
            })

        return findings

    def test_dicomweb_access(self, dicomweb_base):
        """Test DICOMweb endpoint security."""
        import requests
        findings = []

        endpoints = [
            '/dicom-web/studies',
            '/dicom-web/studies?limit=5',
            '/wado-rs/studies',
            '/stow-rs/studies',
        ]

        session = requests.Session()
        for endpoint in endpoints:
            try:
                resp = session.get(
                    f'{dicomweb_base}{endpoint}',
                    timeout=10,
                    headers={'Accept': 'application/dicom+json'}
                )
                findings.append({
                    'endpoint': endpoint,
                    'status_code': resp.status_code,
                    'accessible': resp.status_code == 200,
                    'severity': 'HIGH' if resp.status_code == 200 else 'INFO'
                })
            except requests.RequestException:
                continue

        return findings

    def test_pacs_unauthorized_access(self, pacs_url):
        """Test PACS system access controls."""
        import requests
        findings = []

        # Test unauthenticated access to PACS viewer
        try:
            resp = requests.get(pacs_url, timeout=10)
            if resp.status_code == 200:
                findings.append({
                    'test': 'pacs_unauthenticated_viewer',
                    'severity': 'CRITICAL',
                    'url': pacs_url,
                    'note': 'PACS viewer accessible without authentication'
                })
        except requests.RequestException:
            pass

        # Test study list endpoint
        try:
            resp = requests.get(
                f'{pacs_url}/api/studies',
                timeout=10
            )
            if resp.status_code == 200:
                data = resp.json() if 'json' in resp.headers.get(
                    'Content-Type', ''
                ) else {}
                findings.append({
                    'test': 'pacs_study_list',
                    'severity': 'CRITICAL',
                    'status_code': resp.status_code,
                    'studies_accessible': len(data.get('studies', []))
                })
        except requests.RequestException:
            pass

        return findings

    def _build_associate_rq(self):
        """Build minimal A-ASSOCIATE-RQ for testing."""
        # This is a simplified DICOM association request
        # In production, use pydicom library
        ae_title = self.ae_title.encode()
        called_ae = b'TESTSCP'

        # Build presentation context for Verification SOP
        presentation_context = bytes([
            0x30,  # Presentation Context Item
            0x00, 0x00,  # Length placeholder
            0x01,  # Context ID
            0x00, 0x00, 0x00,  # Reserved
            0x01,  # Number of abstract syntaxes
        ])

        # Abstract Syntax UID (Verification)
        sop_class = b'1.2.840.10008.1.1'
        uid_bytes = bytes([len(sop_class)]) + sop_class
        presentation_context += uid_bytes

        # Transfer Syntax (Implicit VR Little Endian)
        transfer_syntax = b'1.2.840.10008.1.2'
        ts_bytes = bytes([len(transfer_syntax)]) + transfer_syntax
        presentation_context += ts_bytes

        # Fix length
        length = len(presentation_context) - 4
        presentation_context = (
            presentation_context[:2] +
            struct.pack('>H', length) +
            presentation_context[4:]
        )

        # Build A-ASSOCIATE-RQ
        associate_rq = bytes([
            0x01, 0x01,  # PDU type, reserved
            0x00, 0x00,  # Length placeholder
            0x00, 0x01,  # Protocol version
            0x00, 0x00,  # Reserved
        ])

        # Called AE Title
        associate_rq += called_ae.ljust(16, b'\x00')
        # Calling AE Title
        associate_rq += ae_title.ljust(16, b'\x00')
        # Reserved bytes
        associate_rq += b'\x00' * 32

        # Add presentation context
        associate_rq += presentation_context

        # Fix total length
        total_length = len(associate_rq) - 6
        associate_rq = (
            associate_rq[:2] +
            struct.pack('>I', total_length)[1:] +
            associate_rq[6:]
        )

        return associate_rq
```

---

## Tool Arsenal

### Primary Healthcare Security Tools

```bash
# FHIR Security Testing
# SMART on FHIR Launch Simulator
python -c "
import requests

# Test FHIR metadata endpoint
fhir_url = 'http://sandbox.fhir.org/r4/metadata'
resp = requests.get(fhir_url, timeout=10)
if resp.status_code == 200:
    data = resp.json()
    print('FHIR Version:', data.get('fhirVersion'))
    print('Software:', data.get('software'))
    rest = data.get('rest', [{}])[0]
    resources = rest.get('resource', [])
    print(f'Resources: {len(resources)}')
    for r in resources[:5]:
        print(f'  - {r.get(\"type\")}')
"
```

```bash
# HL7v2 Message Testing
python -c "
import socket

def send_hl7v2_test(host, port, message):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(10)
    try:
        sock.connect((host, port))
        sock.send(message.encode())
        response = sock.recv(4096)
        return response.decode(errors='ignore')
    finally:
        sock.close()

# Test HL7v2 connection (TEST environment only)
host = 'test-hl7-server.local'
port = 2575
test_msg = (
    'MSH|^~\\\\&|TEST|TESTFACILITY|DEST|DESTFACILITY|'
    '20260101120000||ACK|TEST001|P|2.5.1\r'
    'MSA|AA|TEST001|Test successful\r'
)
# response = send_hl7v2_test(host, port, test_msg)
print('HL7v2 test tool ready')
"
```

```bash
# DICOM Security Scanner
python -c "
import socket

def dicom_scan(host, port=11112):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        result = sock.connect_ex((host, port))
        sock.close()
        return {'port': port, 'open': result == 0}
    except Exception as e:
        return {'port': port, 'error': str(e)}

# Scan for DICOM services
targets = [
    ('test-pacs.local', 11112),
    ('test-dicom.local', 104),
]
for host, port in targets:
    result = dicom_scan(host, port)
    status = 'OPEN' if result.get('open') else 'CLOSED'
    print(f'{host}:{port} - {status}')
"
```

### Compliance Validation

```bash
# HIPAA Security Rule quick check
python -c "
def hipaa_security_check(system_info):
    checks = []

    # 164.312(a)(1) - Access Control
    checks.append({
        'requirement': '164.312(a)(1) - Access Control',
        'description': 'Implement technical policies for ePHI access',
        'check': 'Unique user identification required',
        'status': 'REQUIRES_MANUAL_VERIFICATION'
    })

    # 164.312(a)(2)(iv) - Encryption
    checks.append({
        'requirement': '164.312(a)(2)(iv) - Encryption',
        'description': 'Encrypt ePHI at rest and in transit',
        'check': 'TLS 1.2+ enforced, data encrypted at rest',
        'status': 'REQUIRES_MANUAL_VERIFICATION'
    })

    # 164.312(b) - Audit Controls
    checks.append({
        'requirement': '164.312(b) - Audit Controls',
        'description': 'Record and examine activity in ePHI systems',
        'check': 'All ePHI access logged with user, timestamp, action',
        'status': 'REQUIRES_MANUAL_VERIFICATION'
    })

    # 164.312(c)(1) - Integrity
    checks.append({
        'requirement': '164.312(c)(1) - Integrity Controls',
        'description': 'Protect ePHI from improper alteration',
        'check': 'Data integrity verification (hash, checksum)',
        'status': 'REQUIRES_MANUAL_VERIFICATION'
    })

    # 164.312(d) - Authentication
    checks.append({
        'requirement': '164.312(d) - Authentication',
        'description': 'Verify identity of persons seeking ePHI access',
        'check': 'MFA for clinical system access',
        'status': 'REQUIRES_MANUAL_VERIFICATION'
    })

    for check in checks:
        print(f\"\"\"  [{check['status']}] {check['requirement']}
    {check['description']}
    Check: {check['check']}
\"\"\")

hipaa_security_check({})
"
```

---

## Real-World Examples

### Example 1: FHIR Patient Search Enabled Unrestricted Access

**Scenario**: A hospital's FHIR R4 API allowed patient search by name and date of birth.

**Discovery**:
```
GET /fhir/Patient?family=Doe&birthdate=1980-01-01
Authorization: Bearer <limited_token>

Response: 200 OK
{
  "resourceType": "Bundle",
  "total": 3,
  "entry": [
    {
      "resource": {
        "resourceType": "Patient",
        "name": [{"family": "Doe", "given": ["John"]}],
        "birthDate": "1980-01-01",
        "identifier": [{"system": "http://hospital.org/mrn", "value": "123456"}]
      }
    }
  ]
}
```

**Root Cause**: FHIR search endpoints did not enforce patient-level access controls (SMART on FHIR scopes not validated at search level).

**Impact**: Mass enumeration of patient records using common names and DOBs. Violation of HIPAA minimum necessary standard.

**Fix**: Implement patient-level scoping, restrict search parameters based on OAuth scopes, require specific patient context for most queries.

### Example 2: HL7v2 Cleartext PHI Transmission

**Scenario**: An integration engine transmitted HL7v2 messages over unencrypted MLLP.

**Discovery**:
```
Network capture on port 2575:
MSH|^~\&|Epic|Hospital|Lab|Hospital|20260101||ORU^R01|MSG001|P|2.5.1
PID|||123456^^^MRN||Smith^Jane||19750515|F
OBR|1|LAB001|BMP|Metabolic Panel|...
OBX|1|NM|Glucose|95|mg/dL|70-100|N
```

**Root Cause**: Legacy HL7v2 integration used MLLP (TCP) without TLS encryption. Clinical lab results transmitted in cleartext.

**Impact**: PHI exposure on network segment. Man-in-the-middle could capture/modify clinical data. HIPAA violation (164.312(a)(2)(iv)).

**Fix**: Implement HL7 over TLS (MLLPS), or migrate to FHIR REST APIs with OAuth 2.0 over HTTPS.

### Example 3: DICOM Studies Accessible Without Authentication

**Scenario**: A PACS system exposed DICOMweb endpoints without authentication.

**Discovery**:
```
GET /dicom-web/studies
Accept: application/dicom+json

Response: 200 OK
[
  {
    "0020000D": {"vr": "UI", "Value": ["1.2.3.4.5.6.7.8.9"]},
    "00100010": {"vr": "PN", "Value": [{"Alphabetic": "DOE^JOHN"}]},
    "00080020": {"vr": "DA", "Value": ["20260101"]}
  }
]
```

**Root Cause**: PACS system deployed with default configuration that did not enforce authentication on DICOMweb endpoints.

**Impact**: Full access to patient medical images and metadata. Exposure of sensitive DICOM headers (PatientName, PatientID, DOB). Potential for image manipulation.

**Fix**: Implement OAuth 2.0 authentication on DICOMweb endpoints, enforce TLS, add audit logging for all study access.

---

## Bypass Techniques

### FHIR Access Control Bypass

```
Technique 1: Resource Type Confusion
+------------------------------------------------------------------+
| Original request:                                                 |
|   GET /fhir/Patient?_count=1                                     |
|   Authorization: Bearer <patient_read_only>                      |
|                                                                    |
| Bypass attempt:                                                   |
|   GET /fhir/Group?_count=100  (Group contains patient refs)     |
|   GET /fhir/Encounter?_count=100 (Encounter links to patients)  |
|   GET /fhir/DocumentReference (links to clinical documents)     |
|                                                                    |
| Rationale: Scopes may limit Patient resource but not related     |
| resources that contain PHI                                       |
+------------------------------------------------------------------+

Technique 2: Search Parameter Manipulation
+------------------------------------------------------------------+
| If _filter parameter is supported:                               |
|   GET /fhir/Patient?_filter=Patient.name co "a"                 |
|   (Returns ALL patients with 'a' in name - broad query)         |
|                                                                    |
| If _sort parameter leaks info:                                   |
|   GET /fhir/Patient?_sort=-birthdate                            |
|   (Returns patients sorted by birth date - info disclosure)      |
+------------------------------------------------------------------+

Technique 3: Bundle Aggregation
+------------------------------------------------------------------+
| Create a transaction bundle requesting multiple resources:        |
|   POST /fhir                                                     |
|   { "type": "transaction", "entry": [                           |
|       {"resource": "Patient", "request": {"method": "GET"}},   |
|       {"resource": "Encounter", "request": {"method": "GET"}}  |
|     ]                                                             |
|                                                                    |
| If server processes all entries in bundle without per-resource   |
| authorization check, bundle becomes privilege escalation vector  |
+------------------------------------------------------------------+
```

### HL7v2 Injection Techniques

```
Technique 1: HL7v2 Field Injection
+------------------------------------------------------------------+
| Normal HL7v2 message:                                             |
|   PID|||12345||Smith^John||19800101|M                            |
|                                                                    |
| Injected field (pipe delimiter abuse):                           |
|   PID|||12345||Smith^John||19800101|M\rOBX|1|ST|injected|val   |
|                                                                    |
| If parser doesn't validate field count, injected OBX is         |
| processed as a separate observation                              |
+------------------------------------------------------------------+

Technique 2: HL7v2 Segmentation Bypass
+------------------------------------------------------------------+
| If system uses HL7v2 message for billing decisions:              |
|   PID|||12345||Smith^John||19800101|M                            |
|   IN1|||Insurance^Aetna||Policy123                               |
|                                                                    |
| Modify IN1 segment to change insurance provider                  |
| (tests billing logic integrity)                                  |
+------------------------------------------------------------------+
```

---

## Common Pitfalls

### 1. Confusing HITRUST with HIPAA

```
HITRUST CSF is a FRAMEWORK, not a regulation:
+------------------------------------------------------------------+
| HIPAA = Federal law (mandatory for covered entities)             |
| HITRUST = Voluntary framework (certification program)            |
|                                                                    |
| A HITRUST certification does NOT automatically equal HIPAA       |
| compliance. HITRUST maps to HIPAA but includes additional        |
| controls. Always verify HIPAA-specific requirements.            |
+------------------------------------------------------------------+
```

### 2. Not Understanding Clinical Context

| Finding | Technical Impact | Clinical Impact |
|---------|------------------|-----------------|
| FHIR Patient search unrestricted | Data breach | Patient privacy violation, potential discrimination |
| HL7v2 cleartext PHI | Network sniffing | Clinical data modification → patient harm |
| DICOM unauth access | Image exposure | Misdiagnosis if images manipulated |
| EHR API rate limit missing | Account takeover | Unauthorized medication orders |
| Break-glass bypass | Audit gap | Undetected unauthorized access |

### 3. Forgetting About Legacy Systems

```
Common Legacy Healthcare Systems:
+------------------------------------------------------------------+
| HL7v2 over MLLP (1990s technology)                              |
| DICOM without TLS (DICOM standard from 1993)                    |
| SOAP-based clinical web services (2000s)                        |
| Proprietary medical device protocols                             |
| Fax-based workflows (still common in 2026)                      |
|                                                                    |
| These systems:                                                    |
|   - Cannot support modern authentication (OAuth, MFA)           |
|   - Often lack encryption capabilities                           |
|   - Run on unpatchable operating systems                        |
|   - Are directly connected to clinical networks                 |
|   - Cannot be taken offline for patching                        |
+------------------------------------------------------------------+
```

---

## Reporting Template

```markdown
# Healthcare System Security Assessment Report

## Executive Summary
- **Target System**: [EHR/PACS/Integration Engine]
- **Assessment Date**: [Date]
- **Environment**: [Sandbox/Staging/Production]
- **Regulatory Framework**: HIPAA, HITECH, FDA (if medical devices)
- **Clinical Context**: [Department/Workflow affected]

## PHI Exposure Summary
| # | Finding | Severity | HIPAA Req | Patient Impact |
|---|---------|----------|-----------|----------------|
| 1 | [Finding] | CRITICAL | 164.312(a)(1) | [Impact] |

## Detailed Findings

### Finding 1: [Title]
- **HIPAA Security Rule**: 164.XXX(X)(X)
- **Endpoint/System**: [API endpoint or system name]
- **PHI Type Exposed**: [ePHI type - names, MRN, diagnoses, etc.]
- **Clinical Impact**: [How this affects patient care/safety]
- **Regulatory Impact**: [HIPAA violation, OCR investigation risk]
- **Evidence**: [Sanitized request/response]
- **Recommendation**: [Specific remediation with clinical workflow consideration]

## Compliance Matrix
| HIPAA Requirement | Status | Notes |
|-------------------|--------|-------|
| 164.312(a)(1) - Access Control | PASS/FAIL | |
| 164.312(a)(2)(iv) - Encryption | PASS/FAIL | |
| 164.312(b) - Audit Controls | PASS/FAIL | |
| 164.312(c)(1) - Integrity | PASS/FAIL | |
| 164.312(d) - Authentication | PASS/FAIL | |

## Medical Device Considerations
| Device/System | FDA Class | Network Segment | Patch Status |
|---------------|-----------|-----------------|--------------|
| [Device] | Class II | Isolated | Up to date/Behind |

## Appendices
A. Systems and Endpoints Tested
B. FHIR CapabilityStatement Analysis
C. HL7v2 Message Samples (Sanitized)
D. DICOM Service Inventory
E. PHI Exposure Evidence (Redacted)
```

---

## Quick Reference

### Critical Healthcare Endpoints

```
FHIR Endpoints:
  GET  /fhir/metadata              # CapabilityStatement
  GET  /fhir/Patient               # Patient search
  GET  /fhir/Patient/{id}          # Patient read
  GET  /fhir/Encounter             # Encounter search
  GET  /fhir/Observation           # Clinical observations
  GET  /fhir/MedicationRequest     # Prescriptions
  GET  /fhir/DocumentReference     # Clinical documents

HL7v2 Ports:
  TCP  2575 (MLLP default)
  TCP  2576 (MLLP alternate)
  TCP  8080 (HL7 over HTTP)

DICOM Ports:
  TCP  11112 (DICOM default)
  TCP  104 (DICOM alternate)
  TCP  4242 (DICOMweb/HTTP)

PACS Systems:
  /pacs/viewer                    # Web viewer
  /pacs/api/studies               # Study list
  /dicom-web/studies              # DICOMweb
```

### Key HIPAA Security Rule Requirements

```
Technical Safeguards (164.312):
  (a)(1) - Access Control (unique user ID, emergency access)
  (a)(2)(i) - Emergency Access Procedure
  (a)(2)(ii) - Automatic Logoff
  (a)(2)(iv) - Encryption and Decryption
  (b) - Audit Controls
  (c)(1) - Integrity (mechanism to authenticate ePHI)
  (d) - Person or Entity Authentication
  (e)(1) - Transmission Security
  (e)(2)(i) - Integrity Controls
  (e)(2)(ii) - Encryption
```

### Severity Decision Matrix

| Finding | HIPAA Impact | Patient Safety | Severity |
|---------|-------------|----------------|----------|
| Unrestricted Patient search | 164.312(a)(1) violation | Privacy breach | CRITICAL |
| Cleartext PHI transmission | 164.312(a)(2)(iv) violation | Data interception | CRITICAL |
| Unauthenticated DICOM access | 164.312(d) violation | Image tampering | CRITICAL |
| Missing audit logs | 164.312(b) violation | Undetected breach | HIGH |
| Weak authentication | 164.312(d) violation | Account takeover | HIGH |

### References

- HIPAA Security Rule: https://www.hhs.gov/hipaa/for-professionals/security/index.html
- HITECH Act: https://www.hhs.gov/hipaa/for-professionals/special-topics/hitech-act/index.html
- FHIR Security: https://www.hl7.org/fhir/security.html
- SMART on FHIR: https://www.hl7.org/fhir/smart-app-launch/
- DICOM Security: https://www.dicomstandard.org/security
- FDA Cybersecurity: https://www.fda.gov/medical-devices/digital-health-center-excellence/cybersecurity
