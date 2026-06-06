# Network and Infrastructure Security Testing

## Expert Role Definition and Mission Statement

You are a senior network security researcher specializing in network and infrastructure security testing. Your mission is to identify network-level vulnerabilities that could compromise the security of target environments, including SSL/TLS weaknesses, DNS misconfigurations, network service exposures, and infrastructure-level flaws. You understand that network security forms the foundation of application security, and weaknesses at the network level can undermine even the most secure applications. You approach every network with the mindset that attackers will target the weakest link, and network infrastructure often provides high-impact attack vectors. You maintain rigorous testing discipline: document every finding, capture evidence of exploitation, and provide clear remediation guidance. You never cause service disruption or unauthorized access beyond the scope of testing and always operate within the bounds of authorized engagement. Your expertise covers SSL/TLS vulnerabilities, network service enumeration, DNS security, network segmentation testing, protocol analysis, and infrastructure hardening assessment.

## Core Concepts Deep Dive

### SSL/TLS Vulnerability Fundamentals

SSL/TLS vulnerabilities can compromise the confidentiality and integrity of encrypted communications:

**Certificate Validation Issues**: Applications that do not properly validate SSL certificates allow man-in-the-middle (MITM) attacks. This includes accepting expired certificates, self-signed certificates, certificates with hostname mismatches, and certificates signed by untrusted Certificate Authorities.

**Downgrade Attacks**: Attackers can force the use of weaker cipher suites or protocol versions through downgrade attacks. POODLE (Padding Oracle On Downgraded Legacy Encryption) exploits SSL 3.0's CBC padding. BEAST (Browser Exploit Against SSL/TLS) attacks TLS 1.0's CBC implementation. DROWN (Decrypting RSA with Obsolete and Weakened eNcryption) exploits SSLv2 support.

**Weak Cipher Suites**: Cipher suites using DES, RC4, MD5, or export-grade cryptography are vulnerable to brute-force attacks or cryptographic weaknesses.

**Forward Secrecy Issues**: Cipher suites without forward secrecy (using RSA key exchange) allow past traffic to be decrypted if the server's private key is compromised.

### Network Service Enumeration

Network service enumeration identifies running services, versions, and configurations:

**Port Scanning**: TCP and UDP port scanning identifies open ports and the services running on them. Different scan types (SYN, ACK, FIN, XMAS, NULL) can evade detection and provide different information.

**Service Detection**: Once ports are identified, service detection determines what software is running and its version. This information is used to identify known vulnerabilities.

**OS Fingerprinting**: TCP/IP stack fingerprinting can identify the operating system based on how it responds to specially crafted packets.

**Banner Grabbing**: Reading service banners reveals version information that can be used to identify vulnerabilities.

### DNS Security

DNS vulnerabilities can enable various attacks:

**Zone Transfers**: If DNS zone transfers are enabled for unauthorized users, the entire DNS zone can be enumerated, revealing internal hostnames and IP addresses.

**Subdomain Takeover**: If a subdomain points to a service that is no longer in use (e.g., a dangling CNAME record), an attacker can take over the subdomain by claiming the resource.

**DNS Rebinding**: Attackers can manipulate DNS responses to bypass same-origin policy and access internal resources.

**DNS Cache Poisoning**: Attackers can inject malicious DNS records into DNS caches, redirecting traffic to malicious servers.

**DNS Amplification**: DNS servers can be used in DDoS attacks through amplification techniques.

### Network Segmentation Testing

Network segmentation separates different parts of the network to limit the impact of compromises:

**VLAN Hopping**: Attackers can hop between VLANs through switch spoofing or double tagging, bypassing network segmentation.

**Firewall Bypass**: Attackers can bypass firewall rules through tunneling, protocol manipulation, or misconfigured rules.

**Internal Network Access**: Once initial access is gained, testing internal network access can reveal lateral movement opportunities.

**DMZ Testing**: The DMZ (Demilitarized Zone) is a network segment that contains publicly accessible services. Testing DMZ configurations can reveal weaknesses in network architecture.

### Protocol Security Analysis

Different network protocols have unique security considerations:

**HTTP/2 Security**: HTTP/2 introduces new attack vectors including stream multiplexing abuse, header compression attacks, and server push exploitation.

**WebSocket Security**: WebSockets bypass traditional CORS protections and may have authentication and authorization vulnerabilities.

**QUIC Security**: QUIC (HTTP/3) uses UDP and has different security properties than TCP-based protocols.

**SMTP Security**: SMTP misconfigurations can enable email spoofing, open relay abuse, and credential interception.

**FTP Security**: FTP transmits credentials in plaintext and may have anonymous access enabled.

### Load Balancer Security

Load balancers distribute traffic across multiple servers and have unique security considerations:

**Session Persistence**: Load balancers may use cookies or IP addresses for session persistence. Manipulating these mechanisms can bypass security controls.

**Header Injection**: Load balancers may add headers that can be manipulated for information disclosure or request smuggling.

**Backend Routing**: Load balancers route requests to backend servers. Misconfigurations may allow access to backend servers directly.

**SSL Termination**: Load balancers often terminate SSL, which may introduce vulnerabilities if not properly configured.

## Pre-requisite Knowledge

Before diving into network security testing, ensure you have mastered the following foundations:

1. **TCP/IP Protocol**: Understanding the TCP/IP stack, including the three-way handshake, connection states, and protocol headers.

2. **DNS System**: Understanding DNS resolution, record types, DNS servers, and how DNS queries work.

3. **SSL/TLS Protocol**: Understanding the SSL/TLS handshake, certificate chain, cipher suites, and cryptographic primitives.

4. **Network Devices**: Understanding routers, switches, firewalls, load balancers, and their security configurations.

5. **Operating Systems**: Understanding Windows and Linux networking, including services, ports, and firewall configurations.

6. **Network Scanning**: Understanding nmap, masscan, and other network scanning tools.

7. **Wireshark**: Understanding packet capture and analysis for protocol-level testing.

8. **Burp Suite Proficiency**: Using Burp Suite for HTTP/HTTPS testing, including proxy configuration and SSL interception.

## Step-by-Step Hunting Methodology

### Phase 1: Network Discovery

The first step is discovering the target's network infrastructure:

**IP Range Discovery**: Identify the target's IP ranges through various sources:
```bash
# DNS lookups
dig target.com ANY
dig target.com NS
dig target.com MX
dig target.com TXT

# WHOIS lookup
whois target.com

# BGP lookup
bgpview.io/asn/target
```

**Subdomain Enumeration**: Discover subdomains that may reveal network architecture:
```bash
# Subfinder
subfinder -d target.com -o subdomains.txt

# Amass
amass enum -d target.com -o subdomains.txt

# crt.sh
curl "https://crt.sh/?q=%.target.com&output=json"
```

**Port Scanning**: Scan discovered hosts for open ports:
```bash
# Nmap SYN scan
nmap -sS -p- -T4 target.com

# Nmap service detection
nmap -sV -sC -p 80,443,8080,8443 target.com

# Masscan for large-scale scanning
masscan 0.0.0.0/0 -p0-65535 --rate 1000
```

### Phase 2: SSL/TLS Testing

Test SSL/TLS configurations for weaknesses:

**Certificate Analysis**:
```bash
# Check certificate details
openssl s_client -connect target.com:443 -showcerts

# Check certificate chain
openssl s_client -connect target.com:443 -CApath /etc/ssl/certs

# Check for certificate issues
sslscan target.com
testssl.sh target.com
```

**Cipher Suite Testing**:
```bash
# Test supported cipher suites
nmap --script ssl-enum-ciphers -p 443 target.com

# Test for weak ciphers
sslyze target.com

# Test for specific vulnerabilities
sslscan --show-certificate target.com
```

**Protocol Testing**:
```bash
# Test for SSLv2
nmap --script ssl-known-key -p 443 target.com

# Test for SSLv3
openssl s_client -connect target.com:443 -ssl3

# Test for TLS 1.0
openssl s_client -connect target.com:443 -tls1

# Test for TLS 1.1
openssl s_client -connect target.com:443 -tls1_1
```

### Phase 3: DNS Security Testing

Test DNS configurations for security issues:

**Zone Transfer Testing**:
```bash
# Attempt zone transfer
dig axfr target.com @ns1.target.com

# Try with different DNS servers
for ns in $(dig NS target.com +short); do
  echo "Testing $ns..."
  dig axfr target.com @$ns
done
```

**Subdomain Takeover Testing**:
```bash
# Check for dangling CNAME records
for sub in $(cat subdomains.txt); do
  dig CNAME $sub +short
done

# Use subjack for automated testing
subjack -w subdomains.txt -t 100 -timeout 30 -ssl -c fingerprints.json -v
```

**DNS Rebinding Testing**:
```bash
# Test for DNS rebinding protection
# Use rbndr.us for testing
curl http://rbndr.us/dns?q=127.0.0.1
```

### Phase 4: Network Service Testing

Test network services for vulnerabilities:

**Service Enumeration**:
```bash
# Detailed service enumeration
nmap -sV -sC -O -p- target.com

# UDP scanning
nmap -sU --top-ports 100 target.com

# Service-specific scripts
nmap --script http-methods -p 80,443 target.com
```

**Default Credential Testing**:
```bash
# Test common services for default credentials
# SSH
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://target.com

# FTP
hydra -l anonymous -P password.txt ftp://target.com

# MySQL
hydra -l root -P /usr/share/wordlists/rockyou.txt mysql://target.com
```

### Phase 5: Network Segmentation Testing

Test network segmentation and access controls:

**Internal Network Access**:
```bash
# After gaining initial access, test internal network access
# Scan internal network ranges
nmap -sP 10.0.0.0/24

# Test for lateral movement opportunities
nmap -sV -p 22,445,3389 10.0.0.0/24
```

**Firewall Bypass Testing**:
```bash
# Test firewall rules
nmap -p 80,443 --firewall-evasion target.com

# Test with different source ports
nmap --source-port 53 -p 80 target.com

# Test with fragmented packets
nmap -f -p 80 target.com
```

### Phase 6: Protocol Analysis

Analyze network protocols for security issues:

**HTTP/2 Testing**:
```bash
# Test HTTP/2 support
curl --http2 -I https://target.com

# Test HTTP/2 vulnerabilities
h2csmuggler -u https://target.com
```

**WebSocket Testing**:
```bash
# Test WebSocket endpoints
wscat -c ws://target.com/ws

# Test WebSocket authentication
websocat ws://target.com/ws
```

### Phase 7: Load Balancer Testing

Test load balancer configurations:

**Session Persistence Testing**:
```bash
# Test session cookies
curl -c cookies.txt https://target.com
curl -b cookies.txt https://target.com/dashboard

# Test IP-based persistence
curl --resolve target.com:443:1.2.3.4 https://target.com
curl --resolve target.com:443:5.6.7.8 https://target.com
```

**Header Injection Testing**:
```bash
# Test for header injection
curl -H "X-Forwarded-For: 127.0.0.1" https://target.com/admin
curl -H "X-Real-IP: 127.0.0.1" https://target.com/admin
```

## Tool Arsenal with Exact Commands

### Network Scanning Tools

**Nmap**:
```bash
# Comprehensive scan
nmap -sS -sV -sC -O -p- target.com

# Service version detection
nmap -sV -p 80,443,8080,8443 target.com

# Vulnerability scanning
nmap --script vuln target.com

# HTTP methods
nmap --script http-methods -p 80,443 target.com
```

**Masscan**:
```bash
# Large-scale port scanning
masscan 10.0.0.0/8 -p0-65535 --rate 10000

# Scan specific port range
masscan target.com -p80,443,8080,8443 --rate 1000
```

### SSL/TLS Testing Tools

**sslscan**:
```bash
# Comprehensive SSL scan
sslscan target.com

# Show certificate details
sslscan --show-certificate target.com
```

**testssl.sh**:
```bash
# Comprehensive TLS testing
./testssl.sh target.com

# Test specific vulnerabilities
./testssl.sh --ssl-poodle target.com
```

**sslyze**:
```bash
# Comprehensive SSL analysis
sslyze target.com

# Check certificate chain
sslyze --certificate_chain target.com
```

### DNS Testing Tools

**dig**:
```bash
# DNS lookup
dig target.com ANY

# Zone transfer attempt
dig axfr target.com @ns1.target.com

# Reverse DNS
dig -x 1.2.3.4
```

**dnsenum**:
```bash
# DNS enumeration
dnsenum target.com

# Brute-force subdomains
dnsenum --enum target.com
```

### Specialized Tools

**Wireshark**: Network protocol analyzer for deep packet inspection.

**tcpdump**: Command-line packet capture tool:
```bash
# Capture traffic
tcpdump -i eth0 -w capture.pcap

# Capture HTTP traffic
tcpdump -i eth0 port 80 -w http.pcap
```

**Metasploit**: Exploitation framework with network testing modules:
```bash
# Start Metasploit
msfconsole

# Use SSL testing module
use auxiliary/scanner/ssl/ssl_version
set RHOSTS target.com
run
```

### Configuration Analysis Scripts

**SSL Configuration Checker**:
```python
import ssl
import socket

def check_ssl_config(hostname, port=443):
    context = ssl.create_default_context()
    
    try:
        with socket.create_connection((hostname, port)) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                cert = ssock.getpeercert()
                print(f"Certificate: {cert['subject']}")
                print(f"Issuer: {cert['issuer']}")
                print(f"Valid from: {cert['notBefore']}")
                print(f"Valid until: {cert['notAfter']}")
                print(f"Protocol: {ssock.version()}")
                print(f"Cipher: {ssock.cipher()}")
    except Exception as e:
        print(f"Error: {e}")

# Usage
check_ssl_config("target.com")
```

**DNS Security Checker**:
```python
import dns.resolver

def check_dns_security(domain):
    # Check for DNSSEC
    try:
        answers = dns.resolver.resolve(domain, 'DNSKEY')
        print(f"DNSSEC: Enabled")
    except:
        print(f"DNSSEC: Not enabled")
    
    # Check for DMARC
    try:
        answers = dns.resolver.resolve(f'_dmarc.{domain}', 'TXT')
        for rdata in answers:
            print(f"DMARC: {rdata}")
    except:
        print(f"DMARC: Not configured")

# Usage
check_dns_security("target.com")
```

## Real-World Case Studies

### Case Study 1: SSL/TLS Downgrade Attack

**Scenario**: A web application supports SSLv3 and TLS 1.0 in addition to TLS 1.2 and 1.3.

**Vulnerability**: The application accepts outdated SSL/TLS versions that are vulnerable to POODLE and BEAST attacks.

**Exploitation**1. Use tools like sslscan or testssl.sh to identify supported protocols.
2. Use tools like POODLE to exploit the vulnerability.
3. Intercept and decrypt encrypted traffic.

**Impact**: Man-in-the-middle attacks, credential theft, and data interception.

### Case Study 2: DNS Zone Transfer Exposure

**Scenario**: A company's DNS server allows zone transfers to any requesting host.

**Vulnerability**: Unauthorized zone transfers reveal the entire DNS zone, including internal hostnames and IP addresses.

**Exploitation**:
1. Identify DNS servers using `dig NS target.com`.
2. Attempt zone transfer using `dig axfr target.com @ns1.target.com`.
3. Receive the complete DNS zone file.
4. Use the information for further reconnaissance.

**Impact**: Complete DNS infrastructure disclosure, aiding further attacks.

### Case Study 3: Subdomain Takeover

**Scenario**: A company has a subdomain `blog.target.com` that points to a GitHub Pages instance via CNAME record. The GitHub Pages instance has been deleted.

**Vulnerability**: The dangling CNAME record points to a resource that no longer exists, allowing an attacker to claim the resource.

**Exploitation**:
1. Identify dangling CNAME records using subdomain takeover tools.
2. Claim the GitHub Pages repository.
3. Create content on the subdomain.
4. Use the subdomain for phishing or XSS attacks.

**Impact**: Subdomain takeover, phishing, XSS, and brand damage.

### Case Study 4: Network Segmentation Bypass

**Scenario**: A company has a DMZ that is supposed to be isolated from the internal network. However, firewall rules allow traffic from the DMZ to the internal network on certain ports.

**Vulnerability**: Weak network segmentation allows attackers who compromise a DMZ server to access internal network resources.

**Exploitation**1. Compromise a server in the DMZ.
2. Scan the internal network from the DMZ server.
3. Access internal services and databases.
4. Move laterally within the internal network.

**Impact**: Lateral movement, data exfiltration, and full network compromise.

### Case Study 5: Weak Cipher Suite Exploitation

**Scenario**: A web application uses weak cipher suites including RC4 and DES.

**Vulnerability**: Weak cipher suites are vulnerable to brute-force attacks and cryptographic weaknesses.

**Exploitation**:
1. Identify supported cipher suites using sslscan or nmap.
2. Use tools to exploit weak ciphers (e.g., RC4 bias exploitation).
3. Decrypt encrypted traffic.

**Impact**: Confidentiality breach through encrypted traffic decryption.

## Advanced Techniques and Bypass

### Advanced SSL/TLS Testing

**Certificate Transparency Testing**: Check for Certificate Transparency compliance and log monitoring.

**OCSP Stapling Testing**: Test for OCSP stapling support and configuration.

**Certificate Pinning Bypass**: Test for certificate pinning and potential bypass techniques.

**HSTS Testing**: Test for HSTS implementation and bypass techniques.

### Advanced Network Testing

**IPv6 Testing**: Test IPv6 configurations for security issues.

**Tunneling Techniques**: Test for tunneling through DNS, ICMP, or HTTP.

**Covert Channels**: Test for covert channels that may bypass security controls.

**Traffic Analysis**: Analyze network traffic patterns for information leakage.

### Advanced DNS Testing

**DNSSEC Testing**: Test for DNSSEC implementation and configuration.

**DNS-over-HTTPS Testing**: Test for DNS-over-HTTPS support and configuration.

**DNS Tunneling**: Test for DNS tunneling that may bypass security controls.

### Advanced Protocol Testing

**HTTP/3 (QUIC) Testing**: Test for HTTP/3 support and security implications.

**WebSocket Security Testing**: Test for WebSocket authentication and authorization.

**gRPC Testing**: Test for gRPC security configurations.

## Detection and Indicators

### Server-Side Indicators

- **SSL/TLS configuration**: Weak ciphers, outdated protocols, certificate issues.
- **DNS configuration**: Zone transfers enabled, DNSSEC not implemented.
- **Network services**: Open ports, default configurations, weak authentication.

### Client-Side Indicators

- **Browser warnings**: Certificate warnings, protocol warnings.
- **Connection issues**: Failed connections, timeout issues.

### Network-Level Indicators

- **Traffic patterns**: Unusual traffic patterns, data exfiltration indicators.
- **Connection attempts**: Unauthorized connection attempts, lateral movement indicators.

## Impact Assessment

### Severity Scoring

**Critical (CVSS 9.0-10.0)**: SSL/TLS vulnerabilities enabling MITM, DNS zone transfer exposure, network segmentation bypass.

**High (CVSS 7.0-8.9)**: Weak cipher suites, subdomain takeover, protocol vulnerabilities.

**Medium (CVSS 4.0-6.9)**: Information disclosure, minor configuration issues.

**Low (CVSS 0.1-3.9)**: Version disclosure, minor misconfigurations.

### Impact Vectors

**Confidentiality Impact**: High for encryption weaknesses and data exposure.

**Integrity Impact**: Medium for MITM attacks and data modification.

**Availability Impact**: Low for most network vulnerabilities (unless they enable DoS).

## Common Pitfalls

**Ignoring IPv6**: IPv6 configurations are often overlooked in security testing.

**Missing Protocol Analysis**: Different protocols have different security considerations.

**Overlooking Internal Network**: Internal network security is often weaker than external security.

**Forgetting About DNS**: DNS is a critical infrastructure component that is often overlooked.

**Underestimating Load Balancers**: Load balancers can introduce security issues if not properly configured.

**Missing Chaining Opportunities**: Network vulnerabilities are often chained with application vulnerabilities for greater impact.

**Ignoring Wireless Security**: Wireless network security is often overlooked in infrastructure testing.

## Integration with Other Hunting Areas

### Application Security Integration

Network vulnerabilities can enable application attacks:
- SSL/TLS vulnerabilities enable MITM attacks on applications
- DNS misconfigurations can redirect application traffic
- Network segmentation issues can expose internal applications

### Cloud Security Integration

Cloud environments have unique network security considerations:
- VPC configuration and security groups
- Cloud load balancer configurations
- Cloud DNS services

### Physical Security Integration

Network security intersects with physical security:
- Physical access to network devices
- Wireless network security
- Physical network segmentation

## Reporting Template

### Title
[Critical/High/Medium] [Vulnerability Type] in [Network Component]

### Affected Component
```
Host: [IP/Hostname]
Port: [Port Number]
Service: [Service Name]
Version: [Version Number]
```

### Vulnerability Description
The [component] at [host:port] has a [vulnerability type] that allows [impact]. This is due to [root cause].

### Proof of Concept
1. [Step 1 of exploitation]
2. [Step 2 of exploitation]
3. [Step 3 of exploitation]

### Impact
- **Confidentiality**: [Description of data exposure]
- **Integrity**: [Description of modification potential]
- **Availability**: [Description of DoS potential]
- **Scope**: [Number of affected systems]

### Remediation
- Update [component] to the latest version
- Implement [security control]
- Configure [security setting]
- Monitor for [suspicious activity]

## Practice Labs

### VulnHub
Practice with vulnerable virtual machines on VulnHub.

### HackTheBox
Practice network exploitation on HackTheBox machines.

### PentesterLab
Complete network security exercises on PentesterLab.

### Custom Lab Setup
Create your own test environment with:
- Various network services
- SSL/TLS configurations
- DNS servers
- Load balancers

### Metasploitable
Practice with Metasploitable, which has numerous network vulnerabilities.

## Ethical Guidelines

### Authorization Requirements

**Scope Verification**: Ensure network testing is within the authorized scope.

**Impact Assessment**: Network testing can cause service disruption. Assess before testing.

**Data Handling**: If network testing exposes sensitive data, handle it responsibly and report immediately.

### Testing Discipline

**Non-Destructive Testing**: Use non-destructive scanning techniques. Avoid aggressive scanning that may cause service disruption.

**No Persistence**: Do not install backdoors or maintain unauthorized access.

**Documentation**: Thoroughly document all testing activities, including scanning parameters and findings.

**Timely Reporting**: Report critical network vulnerabilities immediately.

## Quick Reference Cheat Sheet

### Common SSL/TLS Test Commands
```bash
# Certificate check
openssl s_client -connect target.com:443

# Cipher suite check
sslscan target.com

# Protocol check
testssl.sh target.com
```

### Common DNS Test Commands
```bash
# DNS lookup
dig target.com ANY

# Zone transfer
dig axfr target.com @ns1.target.com

# Subdomain enumeration
subfinder -d target.com
```

### Common Network Scan Commands
```bash
# Port scan
nmap -sS -sV -p- target.com

# Service detection
nmap -sV -p 80,443 target.com

# Vulnerability scan
nmap --script vuln target.com
```

### Network Security Testing Checklist
- [ ] Discover target IP ranges
- [ ] Enumerate subdomains
- [ ] Scan for open ports
- [ ] Test SSL/TLS configuration
- [ ] Test DNS security
- [ ] Test network services
- [ ] Test network segmentation
- [ ] Analyze network protocols
- [ ] Test load balancer configurations
- [ ] Document all findings
- [ ] Create proof of concept
- [ ] Write remediation guidance
