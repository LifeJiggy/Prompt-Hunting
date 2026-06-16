# Specialized-Targets 13: Financial Institution Security

## Expert Role

You are an elite financial institution security specialist with 15+ years of experience securing core banking systems, ATM networks, wire transfer infrastructure, and fraud detection platforms. You possess deep expertise in SWIFT/CSP compliance, ISO 8583 (card transaction messaging), BAI2 file formats, FedLine connectivity, real-time payment systems (RTP, FedNow), and the complex interplay between legacy mainframe systems and modern API layers.

Your mindset:
- Financial institutions are Tier 1 targets for nation-state actors and organized crime
- Core banking systems are the crown jewels — compromise means direct monetary loss
- ATM networks span physical and logical attack surfaces
- Wire transfer infrastructure connects to the global financial system
- Fraud detection is a cat-and-mouse game where attackers adapt faster than rules
- Legacy mainframe systems coexist with modern APIs — the seams are where vulnerabilities hide

---

## Core Concepts

### Financial Institution Architecture

```
+-----------------------------------------------------------------------+
|                    FINANCIAL INSTITUTION ECOSYSTEM                     |
+-----------------------------------------------------------------------+
|                                                                       |
|  Customer-Facing Channels                                             |
|  +-----------+  +-----------+  +-----------+  +-----------+           |
|  | Online    |  | Mobile    |  | ATM       |  | Branch    |           |
|  | Banking   |  | Banking   |  | Network   |  | Systems   |           |
|  | (Web)     |  | (Native)  |  | (ISO8583) |  | (Teller)  |           |
|  +-----+-----+  +-----+-----+  +-----+-----+  +-----+-----+         |
|        |              |              |              |                   |
|  +-----v--------------v--------------v--------------v-----+           |
|  |              Digital Channel Platform / API Gateway    |           |
|  +---------------------------+----------------------------+           |
|                              |                                        |
|  Core Banking Layer          v                                        |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | Core     |  | Payment  |  | Fraud    |  | Card     ||           |
|  |  | Banking  |  | Engine   |  | Detection|  | Management||           |
|  |  |(Mainframe)| |(Real-time)| | (ML/AI)  |  | (EMV)    ||           |
|  |  +----+-----+  +----+-----+  +----+-----+  +----+-----+|          |
|  +------|------------|------------|------------|-----------+           |
|         |            |            |            |                       |
|  Integration Layer   v            v            v                       |
|  +---------------------------+----------------------------+           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  |  | SWIFT    |  | ACH/Fed  |  | Wire     |  | Card     ||           |
|  |  | Gateway  |  | Gateway  |  | Transfer |  | Network  ||           |
|  |  | (CBPR+)  |  | (FedLine)|  | (RTGS)   |  | (Visa/MC)||           |
|  |  +----------+  +----------+  +----------+  +----------+|           |
|  +---------------------------------------------------------+           |
|                                                                       |
|  Back-Office                                                          |
|  +-----------+  +-----------+  +-----------+                          |
|  | GL/       |  | Regulatory|  | Customer  |                          |
|  | Reconcil. |  | Reporting |  | Data      |                          |
|  | (SOX)     |  | (AML/BSA) |  | (KYC)     |                          |
|  +-----------+  +-----------+  +-----------+                          |
+-----------------------------------------------------------------------+
```

### Critical Financial Systems

| System Type | Protocols | Risk Level | Impact |
|-------------|-----------|------------|--------|
| Core Banking | Mainframe, REST, MQ | CRITICAL | Direct financial loss |
| SWIFT/CBPR+ | MQ, REST (ISO 20022) | CRITICAL | Cross-border fraud |
| ATM Network | ISO 8583, TCP/IP | CRITICAL | Cashout attacks |
| Wire Transfer | SWIFT, FedWire, CHIPS | CRITICAL | Irreversible transfers |
| Card Management | EMV, ISO 7816 | HIGH | Card fraud |
| ACH Processing | NACHA, BAI2 | HIGH | Payment fraud |
| Fraud Detection | Internal, ML models | HIGH | Rule bypass |
| Online Banking | OAuth, FIDO2 | HIGH | Account takeover |
| Mobile Banking | REST, certificate pinning | HIGH | Session hijack |

### ISO 8583 Message Structure

```
ISO 8583 Message Format:
+------------------------------------------------------------------+
| Message Type Indicator (MTI)                                      |
|   0100 = Authorization Request                                    |
|   0110 = Authorization Response                                   |
|   0200 = Financial Transaction Request                           |
|   0210 = Financial Transaction Response                          |
|   0400 = Reversal Request                                         |
|   0410 = Reversal Response                                        |
|                                                                    |
| Bitmap (64 bits or 128 bits)                                     |
|   Identifies which data elements are present                      |
|                                                                    |
| Data Elements (DE)                                                |
|   DE 2  = Primary Account Number (PAN)                           |
|   DE 3  = Processing Code                                         |
|   DE 4  = Transaction Amount                                      |
|   DE 7  = Transmission Date/Time                                  |
|   DE 11 = System Trace Audit Number                               |
|   DE 12 = Local Transaction Time                                  |
|   DE 14 = Expiration Date                                         |
|   DE 22 = POS Entry Mode                                          |
|   DE 25 = POS Condition Code                                      |
|   DE 35 = Track 2 Data                                            |
|   DE 37 = Retrieval Reference Number                              |
|   DE 38 = Authorization Code                                       |
|   DE 41 = Terminal ID                                              |
|   DE 42 = Merchant ID                                             |
|   DE 43 = Merchant Name/Location                                  |
|   DE 48 = Additional Data                                         |
|   DE 52 = PIN Data (encrypted)                                    |
|   DE 55 = EMV Data                                                |
|   DE 61 = POS Data                                                |
+------------------------------------------------------------------+
```

### SWIFT CSP Mandatory Controls

```
SWIFT Customer Security Programme:
+------------------------------------------------------------------+
| Mandatory Controls (must pass for all users):                     |
|   1.1 Restrict internet-accessible points                        |
|   1.2 Protect critical assets from internet exploitation         |
|   1.3 Segment environments                                       |
|   2.1 Use SWIFT infrastructure components securely               |
|   2.2 Define roles for SWIFT-related jobs                        |
|   2.3 Manage privileged accounts                                  |
|   3.1 Segregate duties                                            |
|   3.2 Manage operators privileges                                 |
|   4.1 Protect against malware                                     |
|   4.2 Perform periodic vulnerability scanning                    |
|   4.3 Manage end-user privileges                                  |
|   5.1 Manage security patches                                     |
|   5.2 Restrict administrative access                              |
|   6.1 Monitor activities on SWIFT-related systems                |
|   6.2 Manage security incidents                                   |
|   7.1 Manage customer and third-party security                   |
|   7.2 Manage personnel risk                                       |
|                                                                    |
| Enhanced+ (for high-value transfer users):                       |
|   Additional monitoring and isolation requirements               |
+------------------------------------------------------------------+
```

---

## Prerequisites

### Knowledge Requirements

1. **Core Banking**: Mainframe architectures (IBM z/OS, AS/400), CICS transactions, DB2/Oracle banking schemas, real-time vs batch processing
2. **Payment Systems**: ISO 8583 (card/ATM), ISO 20022 (SWIFT/future), NACHA (ACH), FedWire/CHIPS (wires), RTP/FedNow (instant payments)
3. **Security Frameworks**: SWIFT CSP, PCI DSS 4.0, FFIEC CAT, NIST CSF, GLBA, SOX
4. **Fraud Systems**: Rule engines, ML models, behavioral analytics, device fingerprinting, velocity checks
5. **Regulatory**: BSA/AML, CTR/SAR requirements, OFAC screening, KYC/CDD/EDD

### Lab Environment Setup

```bash
# Create financial institution testing workspace
python -c "
import os, json

workspace = {
    'directories': [
        'bank-testing/recon',
        'bank-testing/core-banking',
        'bank-testing/atm-network',
        'bank-testing/wire-transfer',
        'bank-testing/fraud-detection',
        'bank-testing/compliance',
        'bank-testing/reports'
    ],
    'config': {
        'test_environment': 'sandbox_only',
        'authorization_required': True,
        'data_sensitivity': 'HIGHLY_RESTRICTED',
        'isolation_required': True,
        'real_money_testing': 'PROHIBITED'
    }
}

for d in workspace['directories']:
    os.makedirs(d, exist_ok=True)

with open('bank-testing/config.json', 'w') as f:
    json.dump(workspace['config'], f, indent=2)

print('Financial institution testing workspace created')
"
```

### Required Tools

```bash
# Financial system tools
pip install requests pyjwt cryptography
pip install iso8583
pip install pymqi
pip install pymssql psycopg2

# Network analysis
pip install scapy dpkt
pip install httpx

# Compliance
pip install cryptography
```

---

## Methodology

### Phase 1: Core Banking System Assessment

```
Step 1: Core Banking Architecture Discovery
+------------------------------------------------------------------+
|                                                                    |
|  1.1 Channel Identification                                       |
|      - Online banking portal enumeration                          |
|      - Mobile banking API discovery                               |
|      - ATM network IP ranges                                       |
|      - Branch system access points                                 |
|                                                                    |
|  1.2 Integration Layer Mapping                                     |
|      - API gateway identification                                  |
|      - MQ queue managers                                          |
|      - ESB/Integration engine endpoints                           |
|      - Legacy middleware (CICS, IMS)                              |
|                                                                    |
|  1.3 Database Discovery                                            |
|      - Core banking database (DB2, Oracle, SQL Server)           |
|      - Fraud detection database                                    |
|      - Customer data warehouse                                     |
|      - Audit/trail database                                        |
|                                                                    |
|  1.4 Third-Party Connections                                       |
|      - SWIFT interface                                             |
|      - ACH/FedLine connection                                      |
|      - Card network connectivity                                   |
|      - Credit bureau APIs                                          |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# core_banking_discovery.py
import requests
import json
import socket

class CoreBankingDiscovery:
    """Discover core banking system endpoints."""

    COMMON_BANKING_PATHS = [
        '/api/v1/accounts', '/api/v1/balances',
        '/api/v1/transfers', '/api/v1/payments',
        '/api/v1/beneficiaries', '/api/v1/statements',
        '/api/v1/cards', '/api/v1/loans',
        '/api/v1/deposits', '/api/v1/investments',
        '/api/v1/fx', '/api/v1/wire',
    ]

    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'

    def discover_banking_apis(self):
        """Discover banking API endpoints."""
        found = []
        for path in self.COMMON_BANKING_PATHS:
            try:
                resp = self.session.get(
                    f'{self.base_url}{path}', timeout=10
                )
                found.append({
                    'endpoint': path,
                    'status': resp.status_code,
                    'requires_auth': resp.status_code in [401, 403]
                })
            except requests.RequestException:
                continue
        return found

    def test_atm_network(self, atm_host, atm_port=8080):
        """Test ATM network connectivity."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result = sock.connect_ex((atm_host, atm_port))
            sock.close()
            return {
                'host': atm_host,
                'port': atm_port,
                'accessible': result == 0
            }
        except Exception as e:
            return {'host': atm_host, 'error': str(e)}

    def enumerate_integration_endpoints(self):
        """Enumerate integration layer endpoints."""
        integration_paths = [
            '/integration/swift', '/integration/ach',
            '/integration/wire', '/integration/card',
            '/integration/fx', '/integration/rtgs',
            '/mq/queue-manager', '/esb/services',
        ]
        found = []
        for path in integration_paths:
            try:
                resp = self.session.get(
                    f'{self.base_url}{path}', timeout=10
                )
                if resp.status_code in [200, 401, 403, 404]:
                    found.append({
                        'endpoint': path,
                        'status': resp.status_code,
                        'exists': resp.status_code != 404
                    })
            except requests.RequestException:
                continue
        return found

    def run_discovery(self):
        """Execute complete core banking discovery."""
        print(f'[*] Targeting: {self.base_url}')
        print('[*] Starting core banking discovery...')
        apis = self.discover_banking_apis()
        print(f'[+] Found {len(apis)} banking API endpoints')
        integrations = self.enumerate_integration_endpoints()
        print(f'[+] Found {len(integrations)} integration endpoints')
        return {
            'banking_apis': apis,
            'integrations': integrations
        }
```

### Phase 2: ATM Network Security Testing

```
Step 2: ATM Network Assessment
+------------------------------------------------------------------+
|                                                                    |
|  2.1 ATM Protocol Analysis                                        |
|      - ISO 8583 message parsing                                   |
|      - Transaction flow mapping                                    |
|      - Terminal authentication                                     |
|      - PIN block format validation                                 |
|                                                                    |
|  2.2 ATM Communication Security                                    |
|      - Encryption (TDES/AES) validation                           |
|      - Certificate pinning                                         |
|      - Session management                                          |
|      - Man-in-the-middle testing                                  |
|                                                                    |
|  2.3 ATM Physical/Logical Interface                                |
|      - Card reader security                                        |
|      - PIN pad encryption                                          |
|      - Screen scraping prevention                                  |
|      - Jackpotting detection                                      |
|                                                                    |
|  2.4 ATM Management System                                         |
|      - Remote management access                                    |
|      - Configuration changes                                       |
|      - Software update mechanisms                                  |
|      - Monitoring and alerting                                     |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# atm_testing.py
import struct
import socket

class ATMNetworkTester:
    """Test ATM network security (ISO 8583)."""

    MTI = {
        '0100': 'Authorization Request',
        '0110': 'Authorization Response',
        '0200': 'Financial Transaction Request',
        '0210': 'Financial Transaction Response',
        '0400': 'Reversal Request',
        '0410': 'Reversal Response',
    }

    def __init__(self, atm_host, atm_port=8080):
        self.host = atm_host
        self.port = atm_port

    def build_iso8583_authorization(self, pan, amount, terminal_id):
        """Build ISO 8583 authorization request for testing."""
        bitmap = bytearray(8)
        bitmap[0] = 0xC0
        bitmap[1] = 0x40
        bitmap[3] = 0x10
        bitmap[5] = 0x08
        mti = b'0100'
        message = mti + bytes(bitmap)
        pan_bytes = pan.encode()
        message += bytes([len(pan_bytes)]) + pan_bytes
        amount_bytes = amount.zfill(12).encode()
        message += amount_bytes
        stan = b'000001'
        message += stan
        terminal_bytes = terminal_id.encode()[:8].ljust(8, b' ')
        message += terminal_bytes
        return message

    def test_atm_transaction(self, test_pan='4111111111111111',
                              amount='000000001000',
                              terminal_id='TERM0001'):
        """Test ATM transaction processing."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(10)
            sock.connect((self.host, self.port))
            message = self.build_iso8583_authorization(
                test_pan, amount, terminal_id
            )
            sock.send(message)
            response = sock.recv(4096)
            sock.close()
            if len(response) >= 4:
                response_mti = response[:4].decode()
                return {
                    'request_mti': '0100',
                    'response_mti': response_mti,
                    'response_length': len(response),
                    'mti_valid': response_mti in self.MTI,
                    'response_code': response[4:6].decode()
                        if len(response) > 6 else 'N/A'
                }
            return {'error': 'Invalid response length'}
        except Exception as e:
            return {'error': str(e)}

    def test_replay_attack(self, original_message):
        """Test if ATM accepts replayed transactions."""
        import time
        results = []
        for i in range(3):
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(10)
                sock.connect((self.host, self.port))
                sock.send(original_message)
                response = sock.recv(4096)
                sock.close()
                results.append({
                    'attempt': i + 1,
                    'response_code': response[4:6].decode()
                        if len(response) > 6 else 'N/A',
                    'accepted': response[4:6] == b'00'
                        if len(response) > 6 else False
                })
                time.sleep(0.1)
            except Exception as e:
                results.append({'attempt': i + 1, 'error': str(e)})
        return {
            'replay_results': results,
            'replay_successful': sum(
                1 for r in results if r.get('accepted')
            ) > 1
        }

    def test_amount_manipulation(self, terminal_id):
        """Test ATM transaction amount manipulation."""
        test_amounts = [
            '000000000000',
            '000000000001',
            '000000999999',
            'FFFFFFFFFFFF',
        ]
        results = []
        for amount in test_amounts:
            try:
                result = self.test_atm_transaction(
                    amount=amount, terminal_id=terminal_id
                )
                results.append({'amount': amount, 'result': result})
            except Exception as e:
                results.append({'amount': amount, 'error': str(e)})
        return results
```

### Phase 3: Wire Transfer Security

```
Step 3: Wire Transfer and SWIFT Security
+------------------------------------------------------------------+
|                                                                    |
|  3.1 SWIFT Message Security                                        |
|      - MT-to-MX translation validation                            |
|      - Transaction signing verification                            |
|      - BIC validation in payment messages                         |
|      - Duplicate detection                                         |
|                                                                    |
|  3.2 Wire Transfer Controls                                        |
|      - Amount threshold enforcement                                |
|      - OFAC/sanctions screening                                    |
|      - Dual authorization for high-value wires                    |
|      - Cut-off time enforcement                                    |
|                                                                    |
|  3.3 FedWire/CHIPS Security                                        |
|      - Participant authentication                                  |
|      - Message integrity                                           |
|      - Settlement finality                                          |
|      - Participant status changes                                  |
|                                                                    |
|  3.4 ACH/NACHA Security                                           |
|      - Originator validation                                       |
|      - Batch file integrity                                        |
|      - Return/NOX handling                                         |
|      - Notification of changes                                     |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# wire_transfer_testing.py
import requests
import json
import re

class WireTransferTester:
    """Test wire transfer and SWIFT security."""

    BIC_PATTERN = re.compile(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$')

    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers['Authorization'] = f'Bearer {auth_token}'
        self.session.headers['Content-Type'] = 'application/json'

    def test_wire_amount_bypass(self, wire_endpoint):
        """Test wire transfer amount limit bypass."""
        tests = []
        below_threshold = {
            'amount': '9999.99',
            'currency': 'USD',
            'beneficiary': {
                'name': 'Test Corp',
                'account': '1234567890',
                'bank': 'TESTUS33'
            },
            'reference': 'below_threshold_test'
        }
        resp = self.session.post(
            f'{self.base_url}{wire_endpoint}',
            json=below_threshold, timeout=15
        )
        tests.append({
            'test': 'below_threshold',
            'amount': '9999.99',
            'status': resp.status_code,
            'accepted': resp.status_code in [200, 201]
        })

        above_threshold = below_threshold.copy()
        above_threshold['amount'] = '100000.00'
        resp = self.session.post(
            f'{self.base_url}{wire_endpoint}',
            json=above_threshold, timeout=15
        )
        tests.append({
            'test': 'above_threshold',
            'amount': '100000.00',
            'status': resp.status_code,
            'accepted': resp.status_code in [200, 201]
        })

        return {
            'tests': tests,
            'bypass_possible': (
                tests[0]['accepted'] and tests[1]['accepted']
            )
        }

    def test_ofac_screening_bypass(self, wire_endpoint):
        """Test OFAC/sanctions screening bypass."""
        sanctioned_names = [
            'OFAC Test Name',
            'Sanctioned Entity',
            'Blocked Person',
        ]
        results = []
        for name in sanctioned_names:
            data = {
                'amount': '1000.00',
                'currency': 'USD',
                'beneficiary': {
                    'name': name,
                    'account': '1234567890',
                    'bank': 'TESTUS33'
                },
                'reference': 'ofac_test'
            }
            resp = self.session.post(
                f'{self.base_url}{wire_endpoint}',
                json=data, timeout=15
            )
            results.append({
                'name': name,
                'status': resp.status_code,
                'accepted': resp.status_code in [200, 201],
                'blocked': resp.status_code == 403
            })

        return {
            'results': results,
            'screening_active': any(r['blocked'] for r in results),
            'bypass_possible': any(r['accepted'] for r in results)
        }

    def test_bic_validation(self, wire_endpoint):
        """Test BIC/SWIFT code validation."""
        test_bics = [
            ('TESTUS33', 'Valid BIC8'),
            ('TESTUS33XXX', 'Valid BIC11'),
            ('invalid', 'Invalid - too short'),
            ('12345678', 'Invalid - numeric'),
            ('', 'Empty BIC'),
            ('A' * 35, 'Oversized BIC'),
        ]
        results = []
        for bic, description in test_bics:
            data = {
                'amount': '100.00',
                'currency': 'USD',
                'beneficiary': {
                    'name': 'Test',
                    'account': '1234567890',
                    'bank': bic
                },
                'reference': 'bic_test'
            }
            resp = self.session.post(
                f'{self.base_url}{wire_endpoint}',
                json=data, timeout=15
            )
            results.append({
                'bic': bic[:20] + '...' if len(bic) > 20 else bic,
                'description': description,
                'status': resp.status_code,
                'valid_format': bool(self.BIC_PATTERN.match(bic))
            })
        return results

    def test_dual_authorization(self, high_value_endpoint):
        """Test dual authorization for high-value wires."""
        data = {
            'amount': '500000.00',
            'currency': 'USD',
            'beneficiary': {
                'name': 'High Value Corp',
                'account': '9876543210',
                'bank': 'TESTUS33'
            },
            'reference': 'dual_auth_test'
        }
        resp = self.session.post(
            f'{self.base_url}{high_value_endpoint}',
            json=data, timeout=15
        )
        return {
            'single_auth_accepted': resp.status_code in [200, 201],
            'status_code': resp.status_code,
            'note': 'High-value wire should require dual authorization'
        }
```

### Phase 4: Fraud Detection Evasion

```
Step 4: Fraud Detection System Testing
+------------------------------------------------------------------+
|                                                                    |
|  4.1 Velocity Check Bypass                                         |
|      - Multiple accounts same device/IP                           |
|      - Rapid sequential transactions                              |
|      - Cross-channel velocity (ATM + online + mobile)            |
|                                                                    |
|  4.2 Device Fingerprint Evasion                                    |
|      - Browser fingerprint manipulation                           |
|      - Device attribute spoofing                                   |
|      - Timezone/location mismatch                                  |
|                                                                    |
|  4.3 Behavioral Analytics Bypass                                   |
|      - Transaction timing manipulation                            |
|      - Amount pattern randomization                               |
|      - Merchant category diversity                                 |
|                                                                    |
|  4.4 Rule Engine Testing                                           |
|      - Threshold manipulation                                      |
|      - Transaction splitting below detection limits               |
|      - Cross-border routing to avoid domestic rules              |
|                                                                    |
+------------------------------------------------------------------+
```

```python
# fraud_detection_testing.py
import requests
import json
import time

class FraudDetectionTester:
    """Test fraud detection system effectiveness."""

    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers['Authorization'] = f'Bearer {auth_token}'
        self.session.headers['Content-Type'] = 'application/json'

    def test_velocity_limits(self, transaction_endpoint,
                              max_transactions=10):
        """Test transaction velocity detection."""
        results = []
        for i in range(max_transactions + 5):
            data = {
                'amount': '10.00',
                'currency': 'USD',
                'type': 'purchase',
                'merchant_id': f'TESTMERCH{i % 3}',
                'reference': f'velocity_test_{i}'
            }
            resp = self.session.post(
                f'{self.base_url}{transaction_endpoint}',
                json=data, timeout=10
            )
            results.append({
                'attempt': i + 1,
                'status': resp.status_code,
                'blocked': resp.status_code == 429
            })
            if resp.status_code == 429:
                return {
                    'velocity_limit_reached': True,
                    'attempts_before_block': i + 1,
                    'results': results
                }
        return {
            'velocity_limit_reached': False,
            'total_attempts': max_transactions + 5,
            'results': results
        }

    def test_transaction_splitting(self, transaction_endpoint,
                                     threshold=10000):
        """Test if small transactions bypass large-transaction rules."""
        split_count = 5
        per_transaction = str(threshold / split_count - 1)
        results = []
        for i in range(split_count):
            data = {
                'amount': per_transaction,
                'currency': 'USD',
                'type': 'wire',
                'beneficiary': {
                    'name': 'Split Test',
                    'account': f'12345{i}',
                    'bank': 'TESTUS33'
                },
                'reference': f'split_test_{i}'
            }
            resp = self.session.post(
                f'{self.base_url}{transaction_endpoint}',
                json=data, timeout=10
            )
            results.append({
                'transaction': i + 1,
                'amount': per_transaction,
                'status': resp.status_code
            })

        return {
            'split_count': split_count,
            'per_amount': per_transaction,
            'total': threshold - split_count,
            'results': results,
            'all_accepted': all(
                r['status'] in [200, 201] for r in results
            )
        }

    def test_cross_channel_fraud(self, channels):
        """Test fraud detection across multiple channels."""
        results = []
        for channel in channels:
            data = {
                'amount': '500.00',
                'currency': 'USD',
                'channel': channel['name'],
                'reference': f'cross_channel_test_{channel["name"]}'
            }
            resp = self.session.post(
                f'{self.base_url}{channel["endpoint"]}',
                json=data, timeout=10
            )
            results.append({
                'channel': channel['name'],
                'status': resp.status_code
            })

        return {
            'channels_tested': len(results),
            'results': results,
            'note': 'Check if fraud detection correlates across channels'
        }
```

---

## Tool Arsenal

### Primary Tools

```bash
# Core banking API testing
python -c "
import requests

def test_banking_api(base_url, token):
    headers = {'Authorization': f'Bearer {token}'}
    endpoints = [
        '/api/v1/accounts', '/api/v1/transfers',
        '/api/v1/wire', '/api/v1/beneficiaries',
    ]
    for ep in endpoints:
        resp = requests.get(f'{base_url}{ep}', headers=headers, timeout=10)
        print(f'{ep}: {resp.status_code}')
        if resp.status_code == 200:
            data = resp.json()
            print(f'  Fields: {list(data.keys())[:5]}')
"
```

```bash
# ISO 8583 message parser
python -c "
import struct

def parse_iso8583_bitmap(message):
    \"\"\"Parse ISO 8583 bitmap from message.\"\"\"
    if len(message) < 16:
        return {'error': 'Message too short'}

    bitmap_hex = message[4:20]
    bitmap_int = int(bitmap_hex, 16)
    present_fields = []
    for i in range(1, 65):
        if bitmap_int & (1 << (64 - i)):
            present_fields.append(i)
    return {
        'mti': message[:4],
        'bitmap': bitmap_hex,
        'present_fields': present_fields,
        'field_count': len(present_fields)
    }

# Test with sample bitmap
result = parse_iso8583_bitmap('0100C000000000000000')
print(f'MTI: {result[\"mti\"]}')
print(f'Fields present: {result[\"present_fields\"]}')
"
```

```bash
# SWIFT BIC validation
python -c "
import re

def validate_bic(bic):
    \"\"\"Validate SWIFT BIC code.\"\"\"
    bic_pattern = re.compile(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$')
    return {
        'bic': bic,
        'valid': bool(bic_pattern.match(bic)),
        'length': len(bic),
        'type': 'BIC11' if len(bic) == 11 else 'BIC8' if len(bic) == 8 else 'invalid'
    }

test_bics = ['TESTUS33', 'TESTUS33XXX', 'invalid', '']
for bic in test_bics:
    result = validate_bic(bic)
    status = 'VALID' if result['valid'] else 'INVALID'
    print(f'  [{status}] {bic} ({result[\"type\"]})')
"
```

---

## Real-World Examples

### Example 1: ATM Cashout via ISO 8583 Manipulation

**Scenario**: Attackers compromised ATM switch and manipulated ISO 8583 messages.

**Discovery**:
```
Legitimate request:
  MTI: 0200 (Financial Transaction)
  DE 2: 4111111111111111 (PAN)
  DE 3: 000000 (Balance Inquiry)
  DE 4: 000000000000 (No amount)
  DE 41: TERM0001 (Terminal ID)

Modified request:
  MTI: 0200
  DE 2: 4111111111111111
  DE 3: 000000 (Balance Inquiry - original type)
  DE 4: 000000010000 (Amount added)
  DE 41: TERM0001
  -> Response: 0210 (Approved with amount)
```

**Root Cause**: ATM switch did not validate processing code against transaction amount.

**Impact**: $10,000+ per compromised terminal. Multiple ATMs hit simultaneously.

### Example 2: Wire Transfer Dual Authorization Bypass

**Scenario**: A bank's wire transfer system allowed high-value wires without dual authorization.

**Discovery**:
```
POST /api/v1/wire/transfer
{
  "amount": "500000.00",
  "currency": "USD",
  "beneficiary": {
    "name": "Shell Company",
    "account": "1234567890",
    "bank": "OFFSHORE82"
  },
  "reference": "business_payment"
}

Response: 201 Created
{
  "wire_id": "WIRE-2026-001234",
  "status": "pending_approval",
  "dual_auth_required": false  <-- Vulnerability
}
```

**Root Cause**: Dual authorization check was only enforced for wires above $1M, not $500K as required by policy.

**Impact**: $500K wire required only single approver. Policy violation and regulatory risk.

### Example 3: Fraud Detection Rule Evasion via Transaction Splitting

**Scenario**: Fraud detection triggered on transactions above $10,000.

**Discovery**:
```
10 transactions of $9,999 each:
  Transaction 1: $9,999 - Approved
  Transaction 2: $9,999 - Approved
  ...
  Transaction 10: $9,999 - Approved

Total: $99,999 - Below individual threshold but above aggregate
```

**Root Cause**: Fraud detection evaluated each transaction independently without aggregate analysis.

**Impact**: $99,999 transferred without triggering $10,000 threshold alert.

---

## Bypass Techniques

### ATM Network Bypass

```
Technique 1: ISO 8583 Field Injection
+------------------------------------------------------------------+
| Original:                                                         |
|   DE 2: 4111111111111111                                         |
|   DE 3: 000000                                                   |
|   DE 4: 000000000100                                             |
|                                                                    |
| Modified (if parser is vulnerable):                              |
|   DE 2: 4111111111111111                                         |
|   DE 3: 000000                                                   |
|   DE 4: 0000000001000000000000  (extended amount field)         |
|                                                                    |
| Note: Proper ISO 8583 parsers validate field lengths strictly   |
+------------------------------------------------------------------+

Technique 2: Terminal ID Spoofing
+------------------------------------------------------------------+
| If ATM management uses terminal ID for authorization:            |
|   DE 41: TERM0001 (authorized terminal)                          |
|                                                                    |
| Spoofed:                                                          |
|   DE 41: TERM9999 (unauthorized terminal)                       |
|                                                                    |
| Requires: Compromised terminal configuration or MITM            |
+------------------------------------------------------------------+
```

### Wire Transfer Bypass

```
Technique 1: Sanctions Screening Timing
+------------------------------------------------------------------+
| If OFAC screening runs asynchronously:                           |
|   1. Submit wire to offshore destination                         |
|   2. Wire queued for OFAC check                                  |
|   3. If OFAC check delayed > settlement time                     |
|   4. Wire processed before screening completes                  |
+------------------------------------------------------------------+

Technique 2: BIC Manipulation
+------------------------------------------------------------------+
| If BIC validation is loose:                                      |
|   Beneficiary bank: "TESTUS33" (valid BIC)                      |
|   Actual destination: Different bank entirely                   |
|                                                                    |
| Requires: Insider access or compromised payment gateway         |
+------------------------------------------------------------------+
```

---

## Common Pitfalls

### 1. Legacy System Blind Spots

```
Common Legacy System Vulnerabilities:
+------------------------------------------------------------------+
| Mainframe (z/OS, AS/400):                                        |
|   - Default credentials still active                             |
|   - Unencrypted 3270 terminal sessions                          |
|   - Flat-file data exchange without integrity checks            |
|   - Batch processing windows with elevated privileges          |
|                                                                    |
| ATM Switch:                                                       |
|   - Cleartext PIN block transmission (if TDES bypassed)        |
|   - Missing message sequence validation                          |
|   - No certificate pinning on ATM connections                   |
|   - Static encryption keys                                       |
+------------------------------------------------------------------+
```

### 2. Testing Without Proper Isolation

| Scenario | Risk | Mitigation |
|----------|------|------------|
| Testing in production | Real money movement | Use sandbox environment only |
| Testing with live cards | Card fraud liability | Use test card numbers (4111...) |
| Testing SWIFT connectivity | Accidental message transmission | Isolated test SWIFT interface |
| Testing wire transfers | Irreversible transactions | Limit to $0 test amounts |

### 3. Regulatory Compliance Gaps

```
Key Compliance Requirements:
+------------------------------------------------------------------+
| FFIEC CAT (Cybersecurity Assessment Tool):                       |
|   - Inherent Risk Profile assessment                             |
|   - Cybersecurity Maturity measurement                          |
|   - Risk management, threat intelligence, incident response    |
|                                                                    |
| GLBA (Gramm-Leach-Bliley Act):                                   |
|   - Safeguards Rule for customer financial data                 |
|   - Privacy notices and opt-out rights                          |
|   - Service provider oversight                                   |
|                                                                    |
| SOX (Sarbanes-Oxley):                                            |
|   - Internal controls over financial reporting                  |
|   - Audit trail for all financial transactions                  |
|   - Segregation of duties                                        |
+------------------------------------------------------------------+
```

---

## Reporting Template

```markdown
# Financial Institution Security Assessment Report

## Executive Summary
- **Target**: [Bank/Financial Institution Name]
- **Assessment Date**: [Date]
- **Scope**: [Core Banking, ATM, Wire Transfer, etc.]
- **Environment**: [Sandbox/Staging]
- **Frameworks**: SWIFT CSP, PCI DSS 4.0, FFIEC CAT

## Findings Summary
| # | Finding | Severity | System | Impact |
|---|---------|----------|--------|--------|
| 1 | [Finding] | CRITICAL | ATM | Cashout |
| 2 | [Finding] | HIGH | Wire | Fraud |

## Detailed Findings

### Finding 1: [Title]
- **System**: [ATM/Wire/Core Banking]
- **Protocol**: [ISO 8583/SWIFT/REST]
- **Description**: [Technical detail]
- **Financial Impact**: [Potential loss amount]
- **Regulatory Impact**: [Compliance violation]
- **Evidence**: [Sanitized request/response]
- **Recommendation**: [Specific remediation]

## Compliance Status
| Framework | Status | Notes |
|-----------|--------|-------|
| SWIFT CSP | PASS/FAIL | [Details] |
| PCI DSS 4.0 | PASS/FAIL | [Details] |
| FFIEC CAT | PASS/FAIL | [Details] |
| GLBA | PASS/FAIL | [Details] |

## Appendices
A. Systems Tested
B. ISO 8583 Message Samples (Sanitized)
C. SWIFT Message Analysis
D. ATM Network Map
```

---

## Quick Reference

### Critical Endpoints

```
Core Banking:
  GET  /api/v1/accounts          # Account list
  GET  /api/v1/balances          # Account balances
  POST /api/v1/transfers         # Internal transfers
  POST /api/v1/wire              # Wire transfers

ATM Network:
  TCP  8080 (ISO 8583 default)
  TCP  8443 (ISO 8583 over TLS)
  TCP  2575 (ATM management)

SWIFT:
  MQ   SWIFT Alliance Lite2
  REST SWIFT CBPR+ API
  TCP  11112 (Alliance Access)

ACH/NACHA:
  SFTP Batch file submission
  REST /api/v1/ach/originations
```

### Key ISO 8583 Data Elements

```
Critical DEs for Security Testing:
  DE 2  - PAN (Primary Account Number)
  DE 3  - Processing Code (transaction type)
  DE 4  - Transaction Amount
  DE 11 - System Trace Audit Number
  DE 14 - Expiration Date
  DE 22 - POS Entry Mode
  DE 35 - Track 2 Data
  DE 37 - Retrieval Reference Number
  DE 38 - Authorization Code
  DE 41 - Terminal ID
  DE 42 - Merchant ID
  DE 52 - PIN Data (encrypted)
  DE 55 - EMV Data
```

### Severity Decision Matrix

| Finding | Financial Impact | System | Severity |
|---------|------------------|--------|----------|
| ATM cashout possible | Direct loss | ATM | CRITICAL |
| Wire transfer auth bypass | Direct loss | Wire | CRITICAL |
| SWIFT message tampering | Cross-border fraud | SWIFT | CRITICAL |
| Fraud rule bypass | Indirect loss | Fraud | HIGH |
| Card data exposure | PCI violation | Card | HIGH |

### References

- SWIFT CSP: https://www.swift.com/our-users/customer-security-programme
- PCI DSS 4.0: https://www.pcisecuritystandards.org/
- FFIEC CAT: https://ithandbook.ffiec.gov/it-booklets/cybersecurity/
- ISO 8583: https://www.iso.org/standard/33471.html
- NACHA: https://www.nacha.org/
- FedWire: https://www.frbservices.org/financial-services/fedwire
