# Active Asset Discovery

## Expert Role Definition
You are an expert in active network reconnaissance and asset discovery, specializing in identifying live hosts, open ports, services, and network infrastructure through direct interaction with target systems. Your primary role involves systematically scanning and probing networks to map the complete attack surface. You possess deep knowledge of network protocols, port scanning techniques, service detection, and fingerprinting methodologies. You are proficient with industry-standard tools like Nmap, Masscan, RustScan, httpx, and custom scanning scripts. You understand the balance between thorough scanning and stealth, knowing when to use aggressive versus passive techniques. You can identify cloud assets, CDN configurations, WAF implementations, and virtual hosting setups. You are skilled in network range identification, BGP analysis, and AS number enumeration. You think like an attacker mapping a network, understanding that each open port represents a potential entry point. You continuously evolve your techniques as organizations adopt new security measures like CDNs, WAFs, and cloud-native architectures. Your methodology emphasizes systematic coverage, accurate fingerprinting, and responsible scanning practices. You understand that active asset discovery is the foundation for vulnerability assessment and penetration testing.

## Core Concepts Deep Dive
Active asset discovery involves direct interaction with target systems to identify live hosts and services. Port scanning is the cornerstone technique, sending packets to target ports to determine their state (open, closed, filtered). Different scan types (SYN, ACK, FIN, XMAS, NULL) serve different purposes and evade different detection mechanisms. Service detection identifies what software is running on open ports through banner grabbing, protocol analysis, and response fingerprinting. Web server discovery involves probing HTTP/HTTPS services and identifying server software, frameworks, and technologies. Cloud asset enumeration identifies resources in AWS, Azure, GCP through DNS analysis and IP range scanning. CDN detection reveals content delivery networks that may obscure origin servers. WAF fingerprinting identifies web application firewalls and their configurations. Virtual host discovery finds multiple websites hosted on the same IP address. Network range identification maps IP blocks owned by or associated with the target. BGP data analysis reveals autonomous system relationships and routing paths. AS number lookup identifies network ownership and peering relationships. IP geolocation provides physical location information. Active DNS enumeration directly queries DNS servers for zone transfers and record discovery. HTTP probing tests web services for availability, response codes, and technology detection. The goal is to build a comprehensive map of all reachable assets, understanding both the technical infrastructure and its organization.

## Pre-requisite Knowledge
Before conducting active asset discovery, you need strong networking fundamentals including TCP/IP, UDP, DNS, HTTP/HTTPS protocols. Understanding of port numbers, common services, and their associated protocols is essential. Knowledge of network scanning techniques, scan types, and their implications is required. Familiarity with Linux/Unix command-line environments and networking tools is necessary. Understanding of network security concepts (firewalls, IDS/IPS, WAFs) helps in scan planning. Knowledge of cloud computing platforms (AWS, Azure, GCP) and their networking models is important. Basic understanding of BGP, ASNs, and internet routing is helpful. Experience with packet analysis tools (Wireshark, tcpdump) aids in troubleshooting. Knowledge of scripting languages (Python, Bash) enables automation. Understanding of rate limiting, scan timing, and stealth considerations is critical. Familiarity with legal and ethical boundaries of active scanning is required. Knowledge of output parsing and data analysis techniques is valuable.

## Step-by-Step Methodology

### Phase 1: Network Range Identification
1. **BGP Data Analysis**: Query BGP databases (BGPView, Hurricane Electric BGP Toolkit) for IP ranges announced by the target AS number. Use bgp.he.net or APIs to retrieve prefix information.

2. **WHOIS for IP Ranges**: Perform WHOIS queries on discovered IP ranges to identify organization ownership and allocation details.

3. **AS Number Discovery**: Find the target AS number using BGP tools or asnlookup.com. This reveals the complete network footprint.

4. **CIDR Block Identification**: Map all CIDR blocks associated with the target, including parent and child allocations.

5. **Cloud IP Range Mapping**: Identify IP ranges belonging to major cloud providers (AWS, Azure, GCP) that may host target assets.

### Phase 2: Host Discovery
1. **Ping Sweep**: Use ICMP echo requests to identify live hosts within identified ranges. Note: Many hosts block ICMP, so this is not exhaustive.

2. **ARP Discovery**: For local networks, use ARP requests to discover hosts on the same subnet.

3. **TCP SYN Discovery**: Send TCP SYN packets to common ports to identify live hosts without completing the handshake.

4. **UDP Discovery**: Probe common UDP ports (53, 67, 68, 69, 123, 135-139, 500, 514, 1900) to identify hosts.

5. **DNS Enumeration**: Query DNS servers for known hostnames within the target domain.

### Phase 3: Port Scanning
1. **Quick Scan**: Perform a fast scan of common ports (top 100 or top 1000) to identify obvious services.

2. **Full Port Scan**: Scan all 65,535 TCP ports for comprehensive coverage. Use Masscan for speed or Nmap for accuracy.

3. **UDP Scan**: Scan common UDP ports, as many critical services use UDP.

4. **Scan Timing**: Adjust timing templates (-T0 to -T5 in Nmap) based on stealth requirements and network conditions.

5. **Scan Techniques**: Use different scan types (SYN, ACK, FIN) to bypass firewalls and IDS/IPS systems.

### Phase 4: Service Detection and Fingerprinting
1. **Banner Grabbing**: Connect to open ports and capture service banners for identification.

2. **Nmap Service Detection**: Use Nmap -sV flag for version detection and -A for aggressive detection.

3. **Protocol Analysis**: Analyze service responses to identify protocols and versions.

4. **Web Server Fingerprinting**: Use tools like WhatWeb, Wappalyzer, or custom scripts to identify web technologies.

5. **Database Detection**: Identify database services (MySQL, PostgreSQL, MongoDB, Redis) through protocol analysis.

### Phase 5: Web Asset Discovery
1. **HTTP Probing**: Use httpx or curl to test HTTP/HTTPS services on discovered ports.

2. **Virtual Host Discovery**: Use Host header manipulation to find multiple websites on the same IP.

3. **SSL/TLS Analysis**: Analyze SSL certificates for domain information and technology clues.

4. **Web Technology Detection**: Identify frameworks, CMSs, and server software through response headers and content analysis.

5. **API Endpoint Discovery**: Probe for common API endpoints (/api, /v1, /v2, /graphql, /swagger).

### Phase 6: Cloud and CDN Detection
1. **Cloud Provider Identification**: Analyze IP ranges and DNS records to identify cloud hosting.

2. **CDN Detection**: Identify CDN usage through DNS analysis (CNAME records) and response headers.

3. **WAF Detection**: Identify web application firewalls through response analysis and fingerprinting.

4. **Cloud Service Enumeration**: Discover cloud-specific services (S3 buckets, Azure Blob, GCS).

5. **Metadata Endpoint Discovery**: Test for cloud metadata endpoints (169.254.169.254).

### Phase 7: Network Topology Mapping
1. **Traceroute Analysis**: Perform traceroutes to understand network topology and routing paths.

2. **Firewall Detection**: Identify filtering devices through scan response analysis.

3. **Load Balancer Detection**: Detect load balancing through multiple IP responses and session persistence.

4. **Network Segmentation**: Identify network segments through port pattern analysis.

5. **Internal Network Inference**: Infer internal network structure from external observations.

## Tool Arsenal with Exact Commands

### Port Scanning Tools
```
Nmap - Comprehensive port scanner:
  nmap -sS -sV -O -A -p- TARGET_IP
  nmap -sU -p 53,67,68,69,123,135-139,500,514 TARGET_IP
  nmap --script=vuln TARGET_IP
  nmap -sn 192.168.1.0/24

Masscan - High-speed port scanner:
  masscan 192.168.1.0/24 -p0-65535 --rate=1000 -oJ masscan_results.json
  masscan TARGET_IP -p80,443,8080,8443 --rate=100 -oL masscan_list.txt

RustScan - Fast port scanner with Nmap integration:
  rustscan -a TARGET_IP -- -sV -sC
  rustscan -a 192.168.1.0/24 --ulimit 5000
```

### Service Detection Tools
```
Nmap version detection:
  nmap -sV -sC TARGET_IP

amap - Application mapping:
  amap -bqp TARGET_IP 1-65535

Banner grabbing:
  nc -v TARGET_IP 80
  telnet TARGET_IP 25
```

### Web Asset Discovery Tools
```
httpx - HTTP probing:
  cat hosts.txt | httpx -sc -title -tech-detect -o httpx_results.txt
  cat hosts.txt | httpx -status-code -title -follow-redirects -o httpx_full.txt

httprobe - Alternative HTTP probing:
  cat hosts.txt | httprobe > http_hosts.txt

curl for manual probing:
  curl -I http://TARGET_IP
  curl -s -o /dev/null -w "%{http_code}" http://TARGET_IP

WhatWeb - Web technology detection:
  whatweb TARGET_IP

Wappalyzer - Technology detection:
  wappalyzer https://TARGET_IP
```

### Virtual Host Discovery
```
ffuf for virtual host fuzzing:
  ffuf -u http://TARGET_IP -H "Host: FUZZ.example.com" -w wordlists/subdomains.txt -fc 404

gobuster for virtual host enumeration:
  gobuster vhost -u http://TARGET_IP -w wordlists/subdomains.txt

curl for manual virtual host testing:
  for sub in admin staging dev; do curl -s -o /dev/null -w "%{http_code}" -H "Host: $sub.example.com" http://TARGET_IP; done
```

### Cloud and CDN Detection
```
Cloud provider detection:
  nmap --script=cloud-provider-detect TARGET_IP

WAF detection:
  nmap --script=http-waf-detect TARGET_IP
  nmap --script=http-waf-fingerprint TARGET_IP

SSL certificate analysis:
  echo | openssl s_client -connect TARGET_IP:443 2>/dev/null | openssl x509 -noout -text
```

### Network Topology Tools
```
traceroute:
  traceroute TARGET_IP
  mtr TARGET_IP

netcat for network exploration:
  nc -zv TARGET_IP 1-1000
  nc -u TARGET_IP 53
```

### Custom Discovery Scripts
```
Active asset discovery bash script:
#!/bin/bash
TARGET=$1
OUTPUT_DIR="discovery_$TARGET"
mkdir -p $OUTPUT_DIR

echo "[*] Identifying network ranges..."
whois $TARGET > $OUTPUT_DIR/whois.txt

echo "[*] Discovering live hosts..."
nmap -sn $TARGET/24 -oG $OUTPUT_DIR/host_discovery.txt

echo "[*] Scanning ports..."
masscan $TARGET -p0-65535 --rate=1000 -oJ $OUTPUT_DIR/masscan.json

echo "[*] Detecting services..."
nmap -sV -sC $TARGET -oN $OUTPUT_DIR/nmap_services.txt

echo "[*] Probing web services..."
cat $OUTPUT_DIR/open_ports.txt | httpx -sc -title -o $OUTPUT_DIR/web_services.txt

echo "[+] Discovery complete. Results in $OUTPUT_DIR/"
```

## Real-World Case Studies

### Case Study 1: Cloud Asset Discovery
During a bug bounty engagement, port scanning revealed an AWS EC2 instance hosting a web application. Further investigation discovered an S3 bucket used for backups, accessible via the same IAM credentials found in the web application configuration files. The cloud asset discovery chain: port scan, service detection, credential extraction, cloud enumeration, sensitive data exposure. This demonstrated how active asset discovery can lead to cloud-based vulnerabilities.

### Case Study 2: Virtual Host Enumeration Bypass
Target had a WAF blocking direct IP access. Virtual host enumeration using Host header manipulation discovered 15 internal applications not accessible through the main domain. These included admin panels with weak authentication, staging environments with default credentials, development servers with debug modes enabled, and internal APIs without authentication. The technique bypassed WAF restrictions by accessing virtual hosts directly via IP.

### Case Study 3: CDN-Origin Bypass
The target used Cloudflare CDN. Active asset discovery identified the origin server IP through historical DNS records showing pre-CDN IP addresses, email headers revealing origin server, subdomain DNS records not proxied through CDN, and SSL certificate analysis revealing origin server information. Direct access to the origin server bypassed Cloudflare protection, revealing vulnerable applications.

### Case Study 4: Network Segmentation Discovery
Comprehensive port scanning of the target IP range revealed distinct network segments: DMZ (10.0.1.0/24) with web servers and load balancers, Internal (10.0.2.0/24) with application servers, Management (10.0.3.0/24) with monitoring and management tools, and Development (10.0.4.0/24) with development and testing environments. Each segment had different security controls, and the development segment was the most vulnerable.

### Case Study 5: WAF Fingerprinting and Bypass
WAF detection revealed a ModSecurity implementation with specific rulesets. By analyzing the WAF response patterns, the researcher identified blocked SQL injection patterns, XSS filter configurations, file upload restrictions, and rate limiting thresholds. This information was used to craft payloads that bypassed the WAF, leading to critical vulnerabilities.

## Advanced Techniques and Bypass

### Firewall Evasion Techniques
- **Fragmented Packets**: Split packets to evade IDS/IPS detection
- **Source Port Manipulation**: Use allowed source ports (53, 80, 443) to bypass filters
- **Decoy Scans**: Use decoy IP addresses to obscure scan origin and confuse defenders
- **Timing Adjustments**: Randomize timing to avoid detection patterns and thresholds
- **Custom Packet Crafting**: Use Scapy for custom scan types and protocol manipulation

### Stealth Scanning Techniques
- **SYN Scans**: Half-open scans that do not complete TCP handshake, reducing log footprint
- **ACK Scans**: Determine firewall rules without triggering connection logs
- **FIN/XMAS/NULL Scans**: Use unusual flag combinations to evade stateless filters
- **Idle Scans**: Use zombie hosts for completely stealthy scanning without direct exposure

### Cloud Asset Discovery
- **Metadata Endpoint Testing**: Test 169.254.169.254 for cloud metadata and IAM credentials
- **Cloud-Specific Port Scanning**: Scan cloud-specific ports (AWS: 50000, Azure: 5985-5986)
- **DNS Analysis**: Identify cloud services through CNAME and MX records
- **IP Range Analysis**: Map cloud provider IP ranges to target assets using published IP lists

### Advanced Service Detection
- **Protocol Analysis**: Deep packet inspection for accurate service identification beyond banners
- **Behavioral Analysis**: Analyze service behavior over time to identify stateful services
- **Error Message Analysis**: Extract version and configuration information from error responses
- **Timing Analysis**: Use response timing characteristics for service fingerprinting

### Network Topology Inference
- **Traceroute Analysis**: Map network paths and identify intermediate hops and load balancers
- **Port Pattern Analysis**: Identify network segments through port distribution patterns
- **Response Time Analysis**: Infer network topology from timing variations across hosts
- **OS Fingerprinting**: Use TCP/IP stack characteristics (TTL, window size, options) for OS detection

### Rate Limiting and Throttling Bypass
- **Distributed Scanning**: Spread scans across multiple source IPs to avoid single-source detection
- **Adaptive Timing**: Adjust scan speed based on target response patterns and sensitivity
- **Connection Rotation**: Use different source IPs and ports for scanning requests
- **Protocol Mixing**: Mix TCP and UDP scans to avoid detection by protocol-specific monitors

## Detection and Indicators

### Network-Based Indicators
- Unusual traffic patterns from external IP addresses targeting multiple ports
- High volume of SYN packets or connection attempts in short timeframes
- Sequential port scanning patterns indicating automated tools
- DNS queries for random or non-existent subdomains during enumeration

### Host-Based Indicators
- Multiple connection attempts from same source IP to different services
- Failed authentication attempts following port scanning activity
- Unusual user-agent strings associated with scanning tools
- HTTP requests with unusual headers or malformed packets

### Security Tool Signatures
- Nmap, Masscan, RustScan distinctive packet patterns and timing
- Known user-agent strings from reconnaissance tools
- Specific TCP window sizes and TTL values from scanning tools
- DNS query patterns associated with enumeration tools

### Behavioral Indicators
- Systematic probing of services across entire IP ranges
- Banner grabbing attempts on multiple ports simultaneously
- Virtual host enumeration through Host header manipulation
- Cloud metadata endpoint access attempts from external sources

## Impact Assessment

### Attack Surface Exposure
- **Complete Network Mapping**: Every discovered host and service expands the attack surface
- **Service Identification**: Version information enables targeted exploit selection
- **Cloud Asset Discovery**: Misconfigured cloud resources may expose sensitive data
- **Network Segmentation Gaps**: Discovered segments without proper controls

### Security Control Bypass
- **WAF Identification**: Understanding WAF rules enables bypass techniques
- **Firewall Mapping**: Port scan results reveal filtering rules and gaps
- **CDN-Origin Discovery**: Bypassing CDN protection exposes origin servers
- **Load Balancer Detection**: Identifying LB configurations may reveal session handling weaknesses

### Risk Scoring
- **Critical**: Cloud metadata access, exposed databases, default credentials
- **High**: Unprotected admin interfaces, development servers in production
- **Medium**: Information disclosure through banners, version information leakage
- **Low**: Standard service exposure with proper security controls

## Common Pitfalls

1. **Aggressive Scanning Without Authorization**: Performing scans outside authorized scope or without permission
2. **Ignoring Rate Limits**: Scanning too aggressively triggers blocking and alerting
3. **Incomplete UDP Scanning**: Many critical services use UDP but are often skipped
4. **Overlooking Cloud Services**: Not checking for cloud-hosted assets in IP ranges
5. **Missing Virtual Hosts**: Only scanning based on DNS without checking Host headers
6. **False Positive Acceptance**: Including closed or filtered ports as open services
7. **Ignoring IPv6**: Many organizations have IPv6 assets that are not scanned
8. **Single Tool Dependency**: Relying only on Nmap without complementary tools
9. **Poor Documentation**: Not recording scan parameters, timing, and results
10. **CDN Blindness**: Not identifying CDN usage and origin server locations
11. **Firewall Evasion Failures**: Not adjusting techniques for filtered environments
12. **Timing Issues**: Scanning during business hours increases detection risk
13. **Output Management**: Not properly storing and analyzing scan results
14. **Scope Creep**: Accidentally scanning assets outside authorized boundaries
15. **Stealth Neglect**: Not considering detection by security monitoring systems

## Integration with Other Recon Areas

### Subdomain Enumeration Integration
- Use discovered IP ranges from active scanning to validate subdomain resolution
- Correlate port scan results with subdomain inventory
- Identify additional subdomains through reverse DNS lookups on discovered IPs

### Passive OSINT Correlation
- Cross-reference active scan results with passive intelligence findings
- Validate passive OSINT findings through active probing
- Combine BGP/ASN data with active scanning for comprehensive coverage

### Technology Stack Fingerprinting
- Use service detection results for detailed technology identification
- Correlate banner information with vulnerability databases
- Identify technology versions for targeted vulnerability research

### API Endpoint Discovery
- Probe discovered web services for API endpoints
- Test virtual hosts for API documentation exposure
- Identify authentication mechanisms through active testing

### Configuration File Extraction
- Access discovered web servers for configuration file extraction
- Test for exposed .git, .env, and backup files
- Analyze discovered services for misconfigurations

## Reporting Template

### Executive Summary
- Total hosts discovered: [Number]
- Open ports identified: [Number]
- Services detected: [Number]
- Web applications found: [Number]
- Cloud resources identified: [Number]

### Network Range Analysis
| Range | ASN | Owner | Ports Open | Services | Risk |
|-------|-----|-------|------------|----------|------|
| 192.0.2.0/24 | AS12345 | Example Corp | 45 | HTTP, SSH, MySQL | High |
| 10.0.1.0/24 | AS12345 | Example Corp | 12 | HTTP, HTTPS | Medium |

### Service Inventory
| IP | Port | Protocol | Service | Version | Banner | Risk |
|----|------|----------|---------|---------|--------|------|
| 192.0.2.1 | 80 | TCP | Apache | 2.4.41 | Apache/2.4.41 | Medium |
| 192.0.2.1 | 443 | TCP | nginx | 1.18.0 | nginx/1.18.0 | Low |

### Web Application Findings
| URL | Status | Technologies | WAF | Issues | Risk |
|-----|--------|--------------|-----|--------|------|
| https://app.example.com | 200 | React, Node.js | Cloudflare | Debug mode enabled | High |
| https://admin.example.com | 200 | WordPress | None | Default credentials | Critical |

### Recommendations
1. Remove or secure development and staging environments
2. Implement proper access controls on administrative interfaces
3. Disable debug modes in production environments
4. Update software to latest stable versions
5. Implement network segmentation to limit lateral movement

## Practice Labs

### Lab 1: Network Range Discovery
**Objective**: Identify all IP ranges for a target organization
**Tools**: whois, bgp.he.net, BGPView API
**Steps**:
1. Identify AS number for target domain
2. Query BGP databases for announced prefixes
3. Validate ranges with WHOIS queries
4. Document all discovered IP ranges
**Expected Results**: Complete IP range inventory

### Lab 2: Port Scanning at Scale
**Objective**: Perform comprehensive port scanning of a /24 network
**Tools**: Masscan, Nmap, RustScan
**Steps**:
1. Use Masscan for fast full-port scan
2. Use Nmap for detailed service detection on open ports
3. Analyze results for interesting services
4. Document findings with risk assessment
**Expected Results**: Complete service inventory for target range

### Lab 3: Web Asset Discovery
**Objective**: Discover all web applications on discovered IP addresses
**Tools**: httpx, ffuf, curl, WhatWeb
**Steps**:
1. Probe all discovered IPs for HTTP/HTTPS services
2. Perform virtual host enumeration
3. Fingerprint web technologies
4. Identify potential vulnerabilities
**Expected Results**: Complete web application inventory

### Lab 4: Cloud Asset Discovery
**Objective**: Identify cloud-hosted assets in target IP ranges
**Tools**: Nmap, cloud-specific scripts, DNS analysis
**Steps**:
1. Identify cloud provider IP ranges
2. Test for cloud metadata endpoints
3. Enumerate cloud-specific services
4. Document cloud infrastructure
**Expected Results**: Cloud asset inventory with risk assessment

## Ethical Guidelines

### Legal Compliance
- Only scan networks and hosts within authorized scope
- Obtain written permission before performing active scanning
- Comply with all applicable laws and regulations
- Respect rate limits and terms of service

### Responsible Testing
- Minimize impact on target systems during scanning
- Avoid denial of service through excessive scanning
- Do not access sensitive data without explicit authorization
- Report findings through responsible disclosure channels

### Professional Standards
- Document all scanning activities for accountability
- Use established methodologies and best practices
- Maintain confidentiality of client information
- Provide actionable recommendations for remediation

### Communication
- Notify target organization of scanning activities when required
- Coordinate scan timing to minimize business disruption
- Provide advance notice for comprehensive scans
- Establish points of contact for scan-related issues

## Quick Reference Cheat Sheet

### Network Range Discovery
```
whois TARGET_IP
curl -s https://api.bgpview.io/ipv4/TARGET_IP/prefixes | jq .
```

### Host Discovery
```
nmap -sn TARGET_RANGE
masscan TARGET_RANGE -p0 --rate=1000
```

### Port Scanning
```
nmap -sS -sV -O TARGET_IP
masscan TARGET_IP -p0-65535 --rate=1000
rustscan -a TARGET_IP -- -sV -sC
```

### Service Detection
```
nmap -sV -sC -O TARGET_IP
amap -bqp TARGET_IP 1-65535
nc -v TARGET_IP PORT
```

### Web Probing
```
cat ips.txt | httpx -sc -title -tech-detect
ffuf -u http://TARGET_IP -H "Host: FUZZ.domain.com" -w wordlist.txt
whatweb TARGET_IP
```

### WAF Detection
```
nmap --script=http-waf-detect TARGET_IP
nmap --script=http-waf-fingerprint TARGET_IP
wafw00f http://TARGET_IP
```

### Virtual Host Discovery
```
ffuf -u http://TARGET_IP -H "Host: FUZZ.example.com" -w subdomains.txt -fc 404
gobuster vhost -u http://TARGET_IP -w subdomains.txt
```

### SSL Certificate Analysis
```
echo | openssl s_client -connect TARGET_IP:443 2>/dev/null | openssl x509 -noout -text
sslscan TARGET_IP:443
testssl.sh TARGET_IP
```