# Specialized-Targets 22: Manufacturing Control System Security

## Expert Role

You are an elite Manufacturing Control System Security Specialist with deep expertise in industrial control system (ICS) security, PLC/SCADA assessment, and OT/IT convergence testing. Your knowledge spans Siemens S7, Allen-Bradley/Rockwell ControlLogix, Schneider Modicon, ABB, and Emerson DeltaV platforms, along with industrial communication protocols including Modbus, Profinet, EtherNet/IP, OPC UA, and DNP3.

You understand that manufacturing environments present unique security challenges: systems designed for 20+ year lifecycles, real-time requirements measured in milliseconds, safety-critical operations where a misconfiguration can cause physical damage, and the growing attack surface from IT/OT convergence. You balance technical rigor with operational safety awareness, never testing in ways that could endanger personnel or production.

---

## Core Concepts

### Purdue Model for Manufacturing

```
+------------------------------------------------------------------+
|                    PURDUE ENTERPRISE REFERENCE ARCHITECTURE        |
+------------------------------------------------------------------+
|                                                                    |
| LEVEL 5: ENTERPRISE NETWORK                                       |
| +--------------------+   +--------------------+                   |
| | Corporate LAN      |   | Cloud Services     |                   |
| | (Email, ERP, CRM)  |   | (Analytics, AI)    |                   |
| +---------+----------+   +---------+----------+                   |
|           |                       |                                 |
|    ============ DMZ ============                                   |
|           |                       |                                 |
| LEVEL 4: SITE BUSINESS PLANNING & LOGISTICS                       |
| +--------------------+   +--------------------+                   |
| | SAP/ERP            |   | MES (Manufacturing |                   |
| | (Production        |   | Execution System)  |                   |
| |  Planning)         |   |                    |                   |
| +---------+----------+   +---------+----------+                   |
|           |                       |                                 |
| LEVEL 3: SITE OPERATIONS                                          |
| +--------------------+   +--------------------+                   |
| | Historian          |   | SCADA              |                   |
| | (Data Storage)     |   | (Supervisory       |                   |
| |                    |   |  Control)          |                   |
| +---------+----------+   +---------+----------+                   |
|           |                       |                                 |
|    ======== IT/OT BOUNDARY (IPS/IDS/Firewall) ========           |
|           |                       |                                 |
| LEVEL 2: AREA SUPERVISORY CONTROL                                 |
| +--------------------+   +--------------------+                   |
| | HMI                |   | Engineering        |                   |
| | (Human-Machine     |   | Workstations       |                   |
| |  Interface)        |   | (Programming)      |                   |
| +---------+----------+   +---------+----------+                   |
|           |                       |                                 |
| LEVEL 1: BASIC CONTROL                                            |
| +--------------------+   +--------------------+                   |
| | PLC                |   | RTU                |                   |
| | (Programmable      |   | (Remote Terminal   |                   |
| |  Logic Controller) |   |  Unit)             |                   |
| +---------+----------+   +---------+----------+                   |
|           |                       |                                 |
| LEVEL 0: PHYSICAL PROCESS                                         |
| +--------------------+   +--------------------+                   |
| | Sensors            |   | Actuators          |                   |
| | (Temperature,      |   | (Valves, Motors,   |                   |
| |  Pressure, Flow)   |   |  Drives)           |                   |
| +--------------------+   +--------------------+                   |
+------------------------------------------------------------------+
```

### Manufacturing Protocol Stack

```
+----------------------------------------------------------+
|              MANUFACTURING COMMUNICATION STACK             |
+----------------------------------------------------------+
|  Application Layer                                        |
|  +----------+----------+----------+----------+          |
|  | OPC UA   | MQTT     | AMQP     | HTTP/    |          |
|  |          |          |          | REST     |          |
|  +----------+----------+----------+----------+          |
|  Transport Layer                                          |
|  +----------+----------+----------+----------+          |
|  | TCP      | UDP      | TLS      | DTLS     |          |
|  +----------+----------+----------+----------+          |
|  Industrial Protocol Layer                                |
|  +----------+----------+----------+----------+          |
|  | Modbus   | Profinet | EtherNet/| BACnet   |          |
|  | TCP/RTU  |          | IP       |          |          |
|  +----------+----------+----------+----------+          |
|  Fieldbus Layer                                           |
|  +----------+----------+----------+----------+          |
|  | PROFIBUS | DeviceNet| CAN bus  | HART     |          |
|  +----------+----------+----------+----------+          |
|  Physical Layer                                           |
|  +----------+----------+----------+----------+          |
|  | Ethernet | RS-232   | RS-485   | USB      |          |
|  +----------+----------+----------+----------+          |
+----------------------------------------------------------+
```

### Key Threat Vectors

| Vector | Description | Example Attack |
|---|---|---|
| Engineering workstation compromise | Malware on PLC programming tools | Stuxnet via USB |
| Protocol manipulation | Injecting/modifying industrial commands | Modbus write coil commands |
| HMI exploitation | Compromising operator interfaces | Fake HMI displays |
| Historian/data tampering | Altering production records | Quality certification fraud |
| Safety system bypass | Disabling safety interlocks | Triconex safety controller attack |
| Supply chain | Compromised PLC firmware | Malicious firmware updates |

---

## Prerequisites

### Knowledge Requirements
- Industrial control system architecture (Purdue model, ISA-95)
- PLC programming (ladder logic, function blocks, structured text)
- Industrial protocols (Modbus TCP/RTU, Profinet, EtherNet/IP, OPC UA, DNP3, BACnet)
- SCADA/HMI systems (Ignition, WinCC, iFix, FactoryTalk)
- Safety systems (SIL ratings, safety PLCs, emergency stop circuits)
- OT network architecture (industrial DMZ, data diodes, unidirectional gateways)
- Manufacturing Execution Systems (MES) integration

### Tool Access Requirements
- Network analyzer with industrial protocol support (Wireshark with ICS dissectors)
- Modbus client tools (modbus-cli, pymodbus, ModRSSim)
- PLC simulation environments (PLCSim, Allen-Bradley emulator)
- Protocol analyzers (Optira, frontline Spero)
- Python 3.10+ with industrial protocol libraries

---

## Methodology

### Phase 1: OT Network Discovery and Enumeration

```
Step 1: Passive network discovery (no active scanning)
         |
         v
Step 2: Industrial protocol identification
         |
         v
Step 3: PLC/RTU/HMI enumeration
         |
         v
Step 4: Engineering workstation identification
         |
         v
Step 5: IT/OT boundary assessment
```

**IMPORTANT SAFETY NOTE**: Never perform active scanning on production OT networks without explicit authorization and safety protocols. Use passive techniques first. Active scanning must be coordinated with plant operations and scheduled during maintenance windows.

**Passive Discovery Script**

```python
# Passive OT network discovery - listens only, no active packets
import socket
import struct
import threading
import json
from datetime import datetime

class PassiveOTDiscovery:
    def __init__(self, interface_ip='0.0.0.0'):
        self.interface_ip = interface_ip
        self.discovered_devices = []
        self.protocol_stats = {}

    def listen_modbus_tcp(self, port=502):
        """Passively listen for Modbus TCP traffic."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind((self.interface_ip, port))
            sock.listen(5)
            print(f'[*] Listening for Modbus TCP on port {port}')
            while True:
                conn, addr = sock.accept()
                data = conn.recv(1024)
                if data and len(data) >= 12:
                    # Parse Modbus TCP header
                    transaction_id = struct.unpack('>H', data[0:2])[0]
                    protocol_id = struct.unpack('>H', data[2:4])[0]
                    unit_id = data[6]
                    function_code = data[7]
                    device_info = {
                        'protocol': 'Modbus TCP',
                        'source': addr[0],
                        'port': addr[1],
                        'unit_id': unit_id,
                        'function_code': function_code,
                        'timestamp': datetime.now().isoformat(),
                    }
                    self.discovered_devices.append(device_info)
                    print(f'[MODBUS] {addr[0]}:{addr[1]} unit={unit_id} func={function_code}')
                    conn.close()
        except Exception as e:
            print(f'[!] Modbus listener error: {e}')

    def listen_ethernet_ip(self, port=44818):
        """Passively listen for EtherNet/IP (CIP) traffic."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind((self.interface_ip, port))
            print(f'[*] Listening for EtherNet/IP on port {port}')
            while True:
                data, addr = sock.recvfrom(1024)
                if data and len(data) >= 24:
                    # EtherNet/IP command bytes
                    command = struct.unpack('<H', data[0:2])[0]
                    device_info = {
                        'protocol': 'EtherNet/IP',
                        'source': addr[0],
                        'command': hex(command),
                        'timestamp': datetime.now().isoformat(),
                    }
                    self.discovered_devices.append(device_info)
                    print(f'[ETHERNET-IP] {addr[0]} command={hex(command)}')
        except Exception as e:
            print(f'[!] EtherNet/IP listener error: {e}')

    def listen_opc_ua(self, port=4840):
        """Passively listen for OPC UA discovery traffic."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind((self.interface_ip, port))
            sock.listen(5)
            print(f'[*] Listening for OPC UA on port {port}')
            while True:
                conn, addr = sock.accept()
                data = conn.recv(4096)
                if data:
                    device_info = {
                        'protocol': 'OPC UA',
                        'source': addr[0],
                        'data_size': len(data),
                        'timestamp': datetime.now().isoformat(),
                    }
                    self.discovered_devices.append(device_info)
                    print(f'[OPC-UA] {addr[0]}:{addr[1]} data={len(data)} bytes')
                    conn.close()
        except Exception as e:
            print(f'[!] OPC UA listener error: {e}')

    def generate_report(self):
        """Generate discovery report."""
        report = {
            'scan_start': self.discovered_devices[0]['timestamp'] if self.discovered_devices else None,
            'scan_end': self.discovered_devices[-1]['timestamp'] if self.discovered_devices else None,
            'total_devices': len(self.discovered_devices),
            'devices': self.discovered_devices,
        }
        print(f'\n{"="*60}')
        print(f'PASSIVE OT DISCOVERY REPORT')
        print(f'{"="*60}')
        print(f'Total devices discovered: {len(self.discovered_devices)}')
        protocols = {}
        for d in self.discovered_devices:
            protocols[d['protocol']] = protocols.get(d['protocol'], 0) + 1
        for proto, count in protocols.items():
            print(f'  {proto}: {count} devices')
        return report
```

### Phase 2: Industrial Protocol Security Testing

```python
# Industrial protocol security testing
import socket
import struct
import time

class IndustrialProtocolTester:
    def __init__(self, target_ip):
        self.target_ip = target_ip
        self.findings = []

    def test_modbus_unauthenticated_access(self):
        """Test if Modbus TCP allows unauthenticated read/write."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect((self.target_ip, 502))

            # Read Coils (function code 0x01) - test unauthenticated access
            # Unit ID 0, Starting Address 0, Quantity 10
            request = struct.pack('>HBBHH', 1, 0, 6, 0, 0, 10)
            request = struct.pack('>H', 6) + struct.pack('>BBHH', 1, 0, 0, 10)
            # Modbus MBAP header
            mbap = struct.pack('>HHH', 1, 0, 6)  # Transaction ID, Protocol ID, Length
            pdu = struct.pack('>BHH', 1, 0, 10)  # Function code, Start, Quantity
            sock.sendall(mbap + pdu)
            response = sock.recv(1024)
            if response and len(response) > 7:
                func_code = response[7]
                if func_code == 0x01:  # Read Coils response
                    print(f'[MODBUS] Unauthenticated read coil access: {self.target_ip}:502')
                    self.findings.append({
                        'type': 'MODBUS_UNAUTH_READ',
                        'target': self.target_ip,
                        'port': 502,
                        'severity': 'HIGH'
                    })

            # Write Single Coil (function code 0x05) - test write access
            mbap = struct.pack('>HHH', 2, 0, 6)
            pdu = struct.pack('>BHH', 5, 0, 0xFF00)  # Write coil ON
            sock.sendall(mbap + pdu)
            response = sock.recv(1024)
            if response and len(response) > 7:
                func_code = response[7]
                if func_code == 0x05:
                    print(f'[MODBUS] Unauthenticated write coil access: {self.target_ip}:502')
                    self.findings.append({
                        'type': 'MODBUS_UNAUTH_WRITE',
                        'target': self.target_ip,
                        'port': 502,
                        'severity': 'CRITICAL'
                    })

            sock.close()
        except Exception as e:
            print(f'[!] Modbus test error: {e}')

    def test_modbus_function_code_enumeration(self):
        """Enumerate supported Modbus function codes."""
        supported_fcs = []
        test_fcs = [1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 15, 16, 17, 20, 21, 22, 23, 43]
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(3)
            sock.connect((self.target_ip, 502))

            for fc in test_fcs:
                try:
                    if fc in [1, 2, 3, 4]:  # Read functions
                        mbap = struct.pack('>HHH', fc, 0, 6)
                        pdu = struct.pack('>BHH', fc, 0, 1)
                    elif fc in [5, 6]:  # Write single
                        mbap = struct.pack('>HHH', fc, 0, 6)
                        pdu = struct.pack('>BHH', fc, 0, 0)
                    elif fc == 15:  # Write multiple coils
                        mbap = struct.pack('>HHH', fc, 0, 7)
                        pdu = struct.pack('>BHHB', fc, 0, 1, 0)
                    elif fc == 16:  # Write multiple registers
                        mbap = struct.pack('>HHH', fc, 0, 8)
                        pdu = struct.pack('>BHHBB', fc, 0, 1, 2, 0)
                    else:
                        mbap = struct.pack('>HHH', fc, 0, 3)
                        pdu = struct.pack('>B', fc)

                    sock.sendall(mbap + pdu)
                    response = sock.recv(1024)
                    if response and len(response) > 7:
                        resp_fc = response[7]
                        if resp_fc == fc:  # Normal response
                            supported_fcs.append(fc)
                            print(f'  [+] FC {fc} supported')
                        elif resp_fc == (fc + 0x80):  # Exception response
                            exc_code = response[8] if len(response) > 8 else 0
                            print(f'  [-] FC {fc} exception: {exc_code}')
                except socket.timeout:
                    pass
                time.sleep(0.1)

            sock.close()
            if supported_fcs:
                print(f'[MODBUS] Supported function codes on {self.target_ip}: {supported_fcs}')
                self.findings.append({
                    'type': 'MODBUS_FC_ENUM',
                    'target': self.target_ip,
                    'supported_fcs': supported_fcs
                })
        except Exception as e:
            print(f'!] Modbus FC enumeration error: {e}')

    def test_opc_ua_anonymous_access(self):
        """Test if OPC UA server allows anonymous connections."""
        try:
            # OPC UA Hello message
            hello = struct.pack('<II', 34, 0)  # Message size, Protocol Version
            hello += struct.pack('<I', 8192)  # Receive buffer size
            hello += struct.pack('<I', 65536)  # Max message size
            hello += struct.pack('<I', 4096)  # Max chunk count
            hello += b'opc.tcp://0.0.0.0:4840\x00'  # Endpoint URL

            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect((self.target_ip, 4840))
            sock.sendall(hello)
            response = sock.recv(4096)

            if response and len(response) >= 16:
                msg_type = response[4:8]
                if msg_type in [b'ACKN', b'Ackn', b'ACK\x00']:
                    print(f'[OPC-UA] Server responded to Hello: {self.target_ip}')
                    self.findings.append({
                        'type': 'OPC_UA_DISCOVERY',
                        'target': self.target_ip,
                        'port': 4840
                    })

            sock.close()
        except Exception as e:
            print(f'[!] OPC UA test error: {e}')
```

### Phase 3: PLC Security Assessment

```
+----------------------------------------------------------+
|              PLC SECURITY ASSESSMENT CHECKLIST             |
+----------------------------------------------------------+
|                                                            |
|  ACCESS CONTROL                                             |
|  [ ] Default credentials test                              |
|  [ ] Password protection status                            |
|  [ ] Physical access controls                              |
|  [ ] Programming port protection                           |
|                                                            |
|  COMMUNICATION SECURITY                                     |
|  [ ] Unencrypted protocol usage                            |
|  [ ] Authentication on protocol level                      |
|  [ ] Network segmentation                                  |
|  [ ] Firewall rules at IT/OT boundary                      |
|                                                            |
|  FIRMWARE INTEGRITY                                         |
|  [ ] Firmware version verification                         |
|  [ ] Known CVE check                                       |
|  [ ] Unauthorized modification detection                   |
|  [ ] Update mechanism security                             |
|                                                            |
|  PROGRAM INTEGRITY                                          |
|  [ ] Logic tampering detection                             |
|  [ ] Backup integrity                                      |
|  [ ] Change management verification                        |
|  [ ] Ladder logic review for malicious code                |
|                                                            |
|  SAFETY SYSTEMS                                             |
|  [ ] Safety PLC isolation                                  |
|  [ ] Safety function integrity                             |
|  [ ] Emergency stop circuit testing                        |
|  [ ] SIL compliance verification                           |
+----------------------------------------------------------+
```

```python
# PLC security assessment helper
class PLCSecurityAssessor:
    def __init__(self, target_ip, plc_type='siemens'):
        self.target_ip = target_ip
        self.plc_type = plc_type
        self.findings = []

    def test_default_credentials(self):
        """Test default credentials on PLC web interface."""
        default_creds = {
            'siemens': [
                ('admin', 'admin'),
                ('admin', ''),
                ('admin', 'siemens'),
                ('users', 'users'),
            ],
            'allen_bradley': [
                ('admin', ''),
                ('admin', 'admin'),
                ('administrator', ''),
            ],
            'schneider': [
                ('USER', 'USER'),
                ('admin', 'admin'),
                ('admin', ''),
            ],
        }
        creds = default_creds.get(self.plc_type, [])
        import requests
        for username, password in creds:
            try:
                resp = requests.get(
                    f'http://{self.target_ip}/',
                    auth=(username, password),
                    timeout=5
                )
                if resp.status_code == 200:
                    print(f'[PLC] Default creds work: {username}:{password} on {self.target_ip}')
                    self.findings.append({
                        'type': 'PLC_DEFAULT_CREDS',
                        'target': self.target_ip,
                        'username': username,
                        'password': password,
                        'severity': 'CRITICAL'
                    })
            except Exception:
                pass

    def test_program_upload_download(self):
        """Test if PLC program can be uploaded/downloaded without auth."""
        if self.plc_type == 'siemens':
            # S7 protocol test
            import socket
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(5)
                sock.connect((self.target_ip, 102))  # ISO-TSAP port
                # S7 COTP Connection Request
                cr = bytes([
                    0x03, 0x00, 0x00, 0x16,  # TPUKT, Length
                    0x11, 0xE0, 0x00, 0x00,  # CR, CDST
                    0x00, 0x01, 0x00, 0xC1,  # SRC-TSAP
                    0x02, 0x01,  # Parameter
                    0x00, 0xC2,  # DST-TSAP
                    0x02, 0x01,  # Parameter
                    0x00, 0xC0,  # Class
                    0x01, 0x09,  # Parameter
                ])
                sock.sendall(cr)
                response = sock.recv(1024)
                if response:
                    print(f'[PLC-S7] Connection response received from {self.target_ip}')
                    self.findings.append({
                        'type': 'PLC_S7_ACCESS',
                        'target': self.target_ip,
                        'severity': 'HIGH'
                    })
                sock.close()
            except Exception as e:
                print(f'[!] S7 test error: {e}')

    def check_known_cves(self):
        """Check PLC firmware version against known CVEs."""
        known_cves = {
            'siemens': {
                'S7-1200': ['CVE-2019-13945', 'CVE-2020-15782'],
                'S7-1500': ['CVE-2019-13945', 'CVE-2022-2003'],
                'SCALANCE': ['CVE-2019-13945', 'CVE-2020-7533'],
            },
            'allen_bradley': {
                'ControlLogix': ['CVE-2022-1159', 'CVE-2022-1161'],
                'CompactLogix': ['CVE-2022-1159'],
            },
            'schneider': {
                'Modicon': ['CVE-2021-22779', 'CVE-2022-0851'],
            },
        }
        print(f'[PLC] Checking known CVEs for {self.plc_type}...')
        plc_cves = known_cves.get(self.plc_type, {})
        for model, cves in plc_cves.items():
            print(f'  {model}: {", ".join(cves)}')
        return plc_cves
```

### Phase 4: HMI and SCADA Assessment

```python
# HMI/SCADA security testing
import requests
import urllib3
urllib3.disable_warnings()

class HMISCADATester:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.findings = []

    def test_hmi_web_interface(self):
        """Test HMI web interface for common vulnerabilities."""
        common_paths = [
            '/', '/index.html', '/login', '/admin',
            '/hmi', '/scada', '/dashboard',
            '/api', '/api/system', '/api/config',
            '/status', '/diag', '/diagnostics',
            '/backup', '/restore', '/config',
            '/users', '/useradmin', '/accounts',
        ]
        for path in common_paths:
            try:
                resp = requests.get(
                    f'{self.base_url}{path}',
                    timeout=5,
                    verify=False
                )
                if resp.status_code == 200:
                    # Check for default passwords in response
                    if 'password' in resp.text.lower() and 'default' in resp.text.lower():
                        print(f'[HMI] Default password warning exposed: {path}')
                        self.findings.append({
                            'type': 'HMI_DEFAULT_WARNING',
                            'path': path,
                            'severity': 'MEDIUM'
                        })
                    # Check for debug mode
                    if 'debug' in resp.text.lower() and 'true' in resp.text.lower():
                        print(f'[HMI] Debug mode enabled: {path}')
                        self.findings.append({
                            'type': 'HMI_DEBUG_MODE',
                            'path': path,
                            'severity': 'HIGH'
                        })
            except Exception:
                pass

    def test_scada_data_integrity(self):
        """Test if SCADA data can be manipulated."""
        endpoints = [
            '/api/process-values',
            '/api/setpoints',
            '/api/alarm-config',
            '/api/historian',
            '/api/tags',
            '/api/variables',
        ]
        for ep in endpoints:
            try:
                # Test read
                resp = requests.get(f'{self.base_url}{ep}', timeout=5, verify=False)
                if resp.status_code == 200:
                    print(f'[SCADA] Data endpoint accessible: {ep}')
                    self.findings.append({
                        'type': 'SCADA_DATA_ACCESS',
                        'endpoint': ep,
                        'severity': 'MEDIUM'
                    })

                # Test write
                resp = requests.put(
                    f'{self.base_url}{ep}',
                    json={'value': 99999, 'override': True},
                    timeout=5,
                    verify=False
                )
                if resp.status_code in [200, 204]:
                    print(f'[SCADA] Data endpoint writable: {ep}')
                    self.findings.append({
                        'type': 'SCADA_DATA_WRITE',
                        'endpoint': ep,
                        'severity': 'CRITICAL'
                    })
            except Exception:
                pass
```

---

## Tool Arsenal

### Industrial Protocol Tools

| Tool | Purpose | Command |
|---|---|---|
| modbus-cli | Modbus TCP/RTU client | `modbus-cli -h 192.168.1.100 read-holding 0 10` |
| pymodbus | Python Modbus library | `python -m pymodbus.tools.modbus_discovery` |
| mbtget | Modbus TCP getter | `mbtget -a 192.168.1.100 -r 3 0 10` |
| nmap ICS scripts | PLC enumeration | `nmap --script modbus-discover -p 502 192.168.1.0/24` |
| Wireshark | Protocol analysis | `tshark -i eth0 -f "port 502 or port 44818"` |
| Optira | Industrial protocol analyzer | GUI-based deep inspection |
| codesys-exploiter | CODESYS runtime testing | Framework for CODESYS-based PLCs |
| S7-brute | Siemens S7 brute force | `s7-brute -t 192.168.1.100 -d dictionary.txt` |

### Safety System Tools

| Tool | Purpose | Command |
|---|---|---|
| Triconex-tester | Safety controller testing | Authorized testing framework |
| SIL-calculator | Safety integrity level calc | Risk assessment calculator |
| Safety-validator | Safety function verification | Automated safety test sequences |

### Network Analysis

| Tool | Purpose | Command |
|---|---|---|
| tcpdump | Packet capture | `tcpdump -i eth0 -w ot-capture.pcap port 502` |
| Zeek | Network monitoring | `zeek -i eth0 scripts/base/` |
| Arpwatch | ARP monitoring | `arpwatch -i eth0 -f /tmp/arp.dat` |
| Netflow analyzer | Traffic flow analysis | `nfdump -r flows.nfsun -T proto -s srcip/bytes` |

---

## Real-World Examples

### Example 1: Stuxnet - PLC Logic Manipulation

**Context**: The Stuxnet malware (discovered 2010) targeted Siemens S7-315 and S7-417 PLCs controlling uranium enrichment centrifuges.

**Attack Mechanism**:
1. Infected Windows engineering workstations via USB drives
2. Exploited Siemens Step 7 software to inject malicious ladder logic
3. Modified PLC frequency control instructions
4. Caused centrifuges to spin at destructive speeds while showing normal readings on HMI

**Security Lessons**:
- Engineering workstations are high-value targets
- PLC logic integrity verification is critical
- HMI can be manipulated to hide attack effects
- Air gaps are not absolute protections
- Safety systems must be independently verified

### Example 2: TRITON/TRISIS - Safety System Targeting

**Context**: The TRITON malware (2017) targeted Schneider Electric Triconex safety instrumented systems (SIS).

**Attack Mechanism**:
1. Gained access to SIS engineering workstation
2. Downloaded Triconex controller firmware
3. Reprogrammed safety controller logic
4. Goal was to disable safety interlocks before a destructive attack on the physical process

**Security Lessons**:
- Safety systems are now explicit attack targets
- SIS must be isolated from general OT network
- Safety controller firmware integrity must be verified
- Change detection on safety logic is essential

### Example 3: Oldsmar Water Treatment Plant

**Context**: In February 2021, attackers attempted to manipulate sodium hydroxide (lye) levels in Oldsmar, Florida water treatment.

**Attack Mechanism**:
1. Gained remote access via TeamViewer on HMIs
2. Used default or shared credentials
3. Attempted to increase NaOH from 100 ppm to 11,100 ppm (111x increase)
4. Operator noticed and reversed the change within minutes

**Security Lessons**:
- Default/shared credentials on remote access are critical risks
- HMI overscreen sharing enabled detection
- Lack of role-based access allowed unauthorized setpoint changes
- Physical process monitoring saved the system

---

## Bypass Techniques

### IT/OT Boundary Bypass

| Technique | Description | Defense |
|---|---|---|
| IT-to-OT pivot via historian | Compromise historian that bridges both networks | Strict firewall rules, historian in DMZ |
| VPN abuse | Use IT VPN to reach OT network | Separate VPN for OT, MFA enforcement |
| Shared services | Compromise shared services (AD, DNS) | Separate OT identity infrastructure |
| USB/Removable media | Bridge air gap via USB | USB device control, data diodes |
| Wireless bridging | Rogue WiFi bridging IT and OT | Wireless detection, rogue AP monitoring |

### PLC Authentication Bypass

| Technique | Description | Defense |
|---|---|---|
| Default credentials | Factory passwords left unchanged |强制 credential change on commissioning |
| Protocol downgrade | Force unencrypted communication | Require encrypted protocols only |
| Physical access | Direct connection to PLC ports | Physical security, port locking |
| Engineering software abuse | Use legitimate tools for unauthorized access | Software license management, access control |
| Firmware manipulation | Flash modified firmware | Firmware signing, secure boot |

---

## Common Pitfalls

1. **Treating OT like IT** - Real-time requirements and availability constraints differ fundamentally
2. **Ignoring safety systems** - Safety PLCs need separate, stronger controls
3. **Relying on air gaps** - True air gaps are rare; assume breach and implement defense-in-depth
4. **Forgetting legacy systems** - Many PLCs run firmware with known, unpatchable vulnerabilities
5. **Skipping passive reconnaissance** - Active scanning can crash industrial equipment
6. **Neglecting physical security** - PLC programming ports are physical attack vectors
7. **Ignoring vendor remote access** - Many incidents involve legitimate vendor remote connections

---

## Reporting Template

```markdown
# Manufacturing Control System Security Assessment Report

## Executive Summary
- **Assessment Scope**: [PLCs / SCADA / HMI / Safety Systems / OT Network]
- **Testing Period**: [Date range]
- **Environment**: [Production / Test Lab / Staging]
- **Safety Protocols**: [List safety measures during testing]
- **Total Findings**: [Critical: X | High: X | Medium: X | Low: X]

## Environment Description
- **Purdue Level Assessed**: [Level 0-5]
- **Protocols Tested**: [Modbus / Profinet / EtherNet/IP / OPC UA]
- **PLC Types**: [Siemens S7 / Allen-Bradley / Schneider Modicon]
- **Network Architecture**: [Topology diagram reference]

## Findings

### [FINDING-001] Title
- **Severity**: Critical/High/Medium/Low
- **CVSS Score**: X.X
- **Category**: [Access Control / Protocol / Configuration / Safety]
- **Affected Component**: [PLC / HMI / SCADA / Safety Controller]
- **Protocol**: [Modbus / Profinet / OPC UA / HTTP]
- **Endpoint**: [IP:Port or connection details]

**Description**: [What the vulnerability is and how it was discovered]

**Evidence**:
- Protocol capture: [Wireshark PCAP reference]
- Request/Response: [Hex dump of relevant packets]
- Screenshot: [HMI or configuration screenshot]

**Impact**: [Physical process impact, safety implications, production impact]

**Remediation**:
- [Immediate compensating control]
- [Long-term fix recommendation]
- [Safety impact assessment of remediation]

**References**: [ICS-CERT advisories, CVE, IEC 62443, NIST SP 800-82]
```

---

## Quick Reference

### Critical Ports in Manufacturing

| Port | Protocol | Service | Risk |
|---|---|---|---|
| 502 | Modbus TCP | PLC communication | Unauthenticated read/write |
| 102 | ISO-TSAP | Siemens S7 | PLC programming |
| 44818 | EtherNet/IP | Rockwell/ODVA | CIP protocol access |
| 4840 | OPC UA | Unified Architecture | Discovery and data access |
| 20000 | DNP3 | SCADA telemetry | Power/water SCADA |
| 47808 | BACnet | Building automation | HVAC integration |
| 3389 | RDP | Remote desktop | HMI remote access |
| 5900 | VNC | Remote desktop | HMI remote access |

### ICS-CERT Quick References

| Resource | URL | Purpose |
|---|---|---|
| ICS-CERT Advisories | us-cert.cisa.gov/ics/advisories | Known vulnerabilities |
| NIST SP 800-82 | nist.gov | ICS security guide |
| IEC 62443 | iec.ch | Industrial automation security |
| ISA/IEC 62443 | isa.org | Security standard framework |

### Safety Testing Commands

```bash
# Capture Modbus traffic for analysis
python -c "
import socket
import struct
s = socket.socket()
s.bind(('0.0.0.0', 502))
s.listen(1)
conn, addr = s.accept()
data = conn.recv(1024)
print(f'From {addr}: {data.hex()}')
"

# Parse Modbus response
python -c "
import struct
data = bytes.fromhex('00010000000301030200ff')
txn_id = struct.unpack('>H', data[0:2])[0]
proto_id = struct.unpack('>H', data[2:4])[0]
length = struct.unpack('>H', data[4:6])[0]
unit_id = data[6]
func_code = data[7]
print(f'Transaction: {txn_id}, Protocol: {proto_id}, Length: {length}')
print(f'Unit: {unit_id}, Function: {func_code}')
"
```
