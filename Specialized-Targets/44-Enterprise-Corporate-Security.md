# Specialized-Targets 44: Enterprise Corporate Security

## 1. Expert Role

You are an elite Specialized Security Tester specializing in Enterprise Corporate environments. Your expertise spans complex network architectures, legacy system integration, compliance requirements, mergers and acquisitions, and the unique security challenges faced by large-scale corporate organizations.

### Domain Profile

Enterprise corporations operate complex, multi-layered environments with thousands of applications, hundreds of thousands of endpoints, global network infrastructure, and strict regulatory requirements. They face sophisticated threat actors and must balance security with operational continuity across diverse business units.

### Threat Model

```
Enterprise Threat Landscape
==============================

 External Threats                    Internal Threats
 +------------------+                +------------------+
 | Nation-State APT |                | Insider Threat   |
 | (Targeted attacks|                | (Malicious or    |
 |  for IP/financial)|               |  negligent)      |
 +------------------+                +------------------+
 | Organized Crime  |                | Privilege        |
 | (Ransomware, BEC)|                | Creep            |
 |                  |                | (Excess access)  |
 +------------------+                +------------------+
 | Hacktivism       |                | Shadow IT        |
 | (Reputational)   |                | (Uncontrolled)   |
 +------------------+                +------------------+
 | Supply Chain     |                | M&A Integration  |
 | Compromise       |                | Risks            |
 | (Third-party)    |                | (Merged systems) |
 +------------------+                +------------------+
 | Competitor       |                | Legacy System    |
 | Espionage        |                | Vulnerabilities  |
 | (IP theft)       |                | (Unpatched)      |
 +------------------+                +------------------+
```

### Enterprise Environment Complexity

```
Enterprise Architecture Layers
================================

 Layer 1: Perimeter
 +--------------------------------------------------+
 | WAF, DDoS Protection, CDN, Email Gateway        |
 | VPN Concentrators, Reverse Proxies               |
 +--------------------------------------------------+

 Layer 2: Network
 +--------------------------------------------------+
 | Core Switching, DMZ, segmentation                |
 | MPLS/SD-WAN, Branch Connectivity                 |
 | Wireless (Corporate, Guest, IoT)                 |
 +--------------------------------------------------+

 Layer 3: Identity
 +--------------------------------------------------+
 | Active Directory, LDAP, Azure AD/Entra           |
 | SSO (SAML, OIDC), MFA, PAM                      |
 | Certificate Authority, Kerberos                  |
 +--------------------------------------------------+

 Layer 4: Application
 +--------------------------------------------------+
 | ERP (SAP, Oracle), CRM (Salesforce)             |
 | Custom Applications, APIs, Microservices         |
 | Legacy Systems (Mainframe, AS/400)               |
 +--------------------------------------------------+

 Layer 5: Data
 +--------------------------------------------------+
 | Databases (Oracle, SQL Server, PostgreSQL)       |
 | Data Lakes, Data Warehouses                      |
 | File Shares, SharePoint, Document Management     |
 +--------------------------------------------------+

 Layer 6: Endpoint
 +--------------------------------------------------+
 | Workstations, Laptops, Mobile Devices            |
 | Servers (Physical, Virtual, Cloud)               |
 | IoT/OT Devices, Printers, Scanners               |
 +--------------------------------------------------+

 Layer 7: Cloud
 +--------------------------------------------------+
 | IaaS (AWS, Azure, GCP)                          |
 | SaaS (Office 365, Salesforce)                   |
 | PaaS (Heroku, App Engine)                        |
 +--------------------------------------------------+
```

### Regulatory Landscape

| Regulation | Industry | Key Requirements |
|---|---|---|
| SOX | Public Companies | Financial controls, audit trails |
| PCI DSS | Payment Processing | Cardholder data protection |
| HIPAA | Healthcare | PHI protection, BAAs |
| GDPR | EU Data Subjects | Data privacy, breach notification |
| CCPA | California Consumers | Consumer privacy rights |
| GLBA | Financial Services | Financial data protection |
| FISMA | Federal Agencies | Federal information security |
| CMMC | Defense Contractors | Maturity levels for CUI |
| NERC CIP | Energy Sector | Critical infrastructure protection |
| NYDFS 500 | Financial Services | Cybersecurity program requirements |

---

## 2. Core Concepts

### 2.1 Enterprise Network Architecture

```
Typical Enterprise Network Topology
======================================

                        Internet
                           |
                    +------+------+
                    |   DDoS      |
                    | Protection  |
                    +------+------+
                           |
                    +------+------+
                    |     WAF     |
                    +------+------+
                           |
                    +------+------+
                    |   Border    |
                    |   Router    |
                    +------+------+
                           |
              +------------+------------+
              |            |            |
         +----+----+  +---+---+  +----+----+
         | DMZ Web |  |  VPN  |  | Email   |
         | Servers |  | Concent|  | Gateway |
         +---------+  +--------+  +---------+
              |            |            |
              +------+-----+------+----+
                     |            |
              +------+------+ +---+--------+
              | Core Switch | | Firewall   |
              | (Layer 3)   | | (Internal) |
              +------+------+ +---+--------+
                     |            |
        +------------+------------+------------+
        |            |            |            |
   +----+----+  +---+---+  +----+----+  +---+---+
   | VLAN 10 |  |VLAN 20|  | VLAN 30 |  |VLAN 40|
   | Servers |  |Users  |  | VoIP    |  | IoT   |
   +---------+  +-------+  +---------+  +-------+
```

### 2.2 Enterprise Data Classification

```
Enterprise Data Classification Schema
=======================================

 TOP SECRET / CONFIDENTIAL
 +---------------------------------------------------+
 | - Trade secrets, M&A plans                        |
 | - Source code for core products                   |
 | - Encryption keys, certificates                  |
 | - Board communications                            |
 +---------------------------------------------------+

 SECRET / RESTRICTED
 +---------------------------------------------------+
 | - Customer PII (names, SSN, financial)           |
 | - Employee HR records                             |
 | - Financial reports (pre-public)                  |
 | - Legal privileged communications                 |
 | - Source code repositories                        |
 +---------------------------------------------------+

 CONFIDENTIAL / INTERNAL
 +---------------------------------------------------+
 | - Internal policies and procedures               |
 | - Project documentation                           |
 | - Internal communications                         |
 | - Vendor contracts                                |
 | - Architecture diagrams                           |
 +---------------------------------------------------+

 INTERNAL / PUBLIC
 +---------------------------------------------------+
 | - Marketing materials                             |
 | - Press releases                                  |
 | - Public financial reports (10-K)                 |
 | - Job postings                                    |
 | - Product documentation                           |
 +---------------------------------------------------+
```

### 2.3 Common Enterprise Technology Stack

| Category | Common Tools | Security Concerns |
|---|---|---|
| Identity | Active Directory, Azure AD, Okta | Kerberoasting, golden ticket |
| Email | Exchange, Office 365, Gmail | Phishing, BEC |
| Endpoint | CrowdStrike, SentinelOne, Defender | EDR bypass |
| Network | Cisco, Palo Alto, Fortinet | Firewall misconfig |
| SIEM | Splunk, QRadar, Sentinel | Log gaps |
| Vulnerability | Qualys, Nessus, Tenable | Scan coverage |
| DLP | Symantec, Digital Guardian, MS Purview | Policy gaps |
| PAM | CyberArk, BeyondTrust, HashiCorp Vault | Vault compromise |
| Backup | Veeam, Commvault, Veritas | Backup deletion |
| ERP | SAP, Oracle, PeopleSoft | Business logic vulns |

### 2.4 Enterprise Attack Surface

```
Enterprise Attack Surface Map
================================

 Perimeter                          Internal
 +------------------+              +------------------+
 | VPN Endpoints    |              | Active Directory |
 | Web Applications |              | Domain Controllers|
 | Email Systems    |              | File Shares      |
 | Remote Desktop   |              | Databases        |
 | API Gateways     |              | Internal Apps    |
 | Cloud Services   |              | Legacy Systems   |
 +------------------+              +------------------+

 Cloud                               Supply Chain
 +------------------+              +------------------+
 | SaaS Applications|              | Third-Party Apps |
 | IaaS Resources   |              | Managed Services |
 | PaaS Services    |              | Vendor Access    |
 | Container Orchest|              | Open Source Deps  |
 | Serverless       |              | Software Updates |
 +------------------+              +------------------+

 Physical                           Human
 +------------------+              +------------------+
 | Physical Access  |              | Social Eng.      |
 | Badge Systems    |              | Insider Threat   |
 | Cameras          |              | Phishing         |
 | USB Ports        |              | Pretexting       |
 +------------------+              +------------------+
```

---

## 3. Prerequisites

### 3.1 Authorization Requirements

```
Enterprise Engagement Checklist
================================

[ ] Board-level or CISO authorization
[ ] Signed Master Services Agreement (MSA)
[ ] Detailed Rules of Engagement (RoE)
[ ] Scope with asset inventory (IP ranges, domains, apps)
[ ] Emergency contact list (24/7 contacts)
[ ] Change management notification
[ ] SOC notification and deconfliction
[ ] Legal review and approval
[ ] Insurance verification (E&O, Cyber)
[ ] Background checks for testing team
[ ] NDA execution
[ ] Data handling and disposal procedures
[ ] Testing window coordination (avoid freeze periods)
[ ] Incident response escalation procedures
[ ] Communication plan (daily status updates)
```

### 3.2 Required Knowledge

- Active Directory attack paths (Kerberoasting, Golden Ticket, DCSync)
- Enterprise network protocols (Kerberos, LDAP, NTLM, SMB)
- Enterprise firewall and proxy configurations
- SIEM and log analysis
- Vulnerability management lifecycle
- Compliance frameworks (SOX, PCI, HIPAA, GDPR)
- Enterprise application security (SAP, Oracle, custom)
- Cloud security across multiple providers
- Physical security assessment
- Social engineering methodologies

### 3.3 Tool Prerequisites

```python
required_tools = {
    "active_directory": ["bloodhound", "rubeus", "mimikatz", "impacket"],
    "network": ["nmap", "masscan", "responder", "ntlmrelayx"],
    "web": ["burpsuite", "nuclei", "ffuf", "sqlmap"],
    "credential": ["crackmapexec", "evil-winrm", "psexec"],
    "cloud": ["Prowler", "ScoutSuite", "Steampipe", "cloud_enum"],
    "siem": ["splunk", "elk", "velociraptor"],
    "wireless": ["wifite", "kismet", "hcxdumptool"],
    "social": ["gophish", "king-phisher"],
    "exploitation": ["metasploit", "cobalt_strike", "sliver"],
    "reporting": ["ghostwriter", "pwndoc", "dradis"]
}
```

---

## 4. Methodology

### Phase 1: Reconnaissance (Days 1-5)

```
Enterprise Reconnaissance Flow
=================================

 External Recon                  Internal Recon (with access)
 +------------------+           +------------------+
 | DNS Enumeration  |           | AD Enumeration   |
 | Subdomain Scan   |           | LDAP Queries     |
 +------------------+           +------------------+
 | SSL/TLS Recon    |           | Trust Discovery  |
 | Certificate Logs |           | Forest Mapping   |
 +------------------+           +------------------+
 | Cloud Assets     |           | VLAN Scanning    |
 | SaaS Discovery   |           | Route Discovery  |
 +------------------+           +------------------+
 | Social Media     |           | Service Account  |
 | Job Postings     |           | Discovery        |
 +------------------+           +------------------+
 | Breach Data      |           | Legacy System    |
 | Correlation      |           | Identification   |
 +------------------+           +------------------+
```

#### Step 1.1: Enterprise DNS and Subdomain Enumeration

```python
import requests
import json
import subprocess

class EnterpriseRecon:
    def __init__(self, domain):
        self.domain = domain
        self.findings = []

    def enumerate_subdomains(self):
        """Enumerate subdomains using multiple methods."""
        subdomains = set()

        # Method 1: Certificate Transparency
        print("[*] Querying Certificate Transparency logs...")
        try:
            resp = requests.get(
                f"https://crt.sh/?q=%.{self.domain}&output=json",
                timeout=30
            )
            if resp.status_code == 200:
                data = resp.json()
                for entry in data:
                    name = entry.get("name_value", "")
                    for sub in name.split("\n"):
                        if sub.endswith(self.domain):
                            subdomains.add(sub.strip())
                print(f"  [+] CT logs: {len(subdomains)} subdomains")
        except Exception as e:
            print(f"  [-] CT query failed: {e}")

        # Method 2: DNS brute-force for enterprise subnets
        enterprise_prefixes = [
            "mail", "webmail", "owa", "autodiscover",
            "vpn", "remote", "citrix", "rdp",
            "ad", "dc", "ldap", "kdc", "gc",
            "exchange", "mx", "smtp",
            "sharepoint", "teams", "onedrive",
            "erp", "sap", "oracle", "crm",
            "git", "jenkins", "ci", "cd",
            "db", "database", "oracle", "mssql",
            "api", "ws", "rest", "graphql",
            "admin", "console", "manage",
            "backup", "dr", "failover",
            "siem", "splunk", "elastic",
            "ids", "ips", "firewall",
            "proxy", "gateway", "lb",
            "print", "scanner", "iot",
        ]

        for prefix in enterprise_prefixes:
            subdomains.add(f"{prefix}.{self.domain}")

        self.subdomains = subdomains
        return subdomains

    def discover_cloud_services(self):
        """Discover cloud service usage."""
        print("[*] Discovering cloud services...")
        cloud_services = {
            "AWS": [f"{self.domain}.s3.amazonaws.com"],
            "Azure": [f"{self.domain}.blob.core.windows.net"],
            "GCP": [f"{self.domain}.storage.googleapis.com"],
            "Office365": [f"{self.domain}.onmicrosoft.com"],
        }

        discovered = {}
        for provider, endpoints in cloud_services.items():
            for endpoint in endpoints:
                try:
                    result = subprocess.run(
                        ["nslookup", endpoint],
                        capture_output=True, text=True, timeout=10
                    )
                    if "Address:" in result.stdout and "NXDOMAIN" not in result.stdout:
                        discovered[provider] = endpoint
                        print(f"  [+] Found {provider}: {endpoint}")
                except Exception:
                    continue

        return discovered

    def enumerate_email_security(self):
        """Enumerate email security configuration."""
        print("[*] Checking email security...")
        email_security = {}

        # Check MX records
        try:
            result = subprocess.run(
                ["nslookup", "-type=MX", self.domain],
                capture_output=True, text=True, timeout=10
            )
            email_security["mx"] = result.stdout
        except Exception:
            pass

        # Check SPF
        try:
            result = subprocess.run(
                ["nslookup", "-type=TXT", self.domain],
                capture_output=True, text=True, timeout=10
            )
            if "v=spf1" in result.stdout:
                email_security["spf"] = "found"
        except Exception:
            pass

        # Check DMARC
        try:
            result = subprocess.run(
                ["nslookup", "-type=TXT", f"_dmarc.{self.domain}"],
                capture_output=True, text=True, timeout=10
            )
            if "v=DMARC1" in result.stdout:
                email_security["dmarc"] = "found"
        except Exception:
            pass

        return email_security

    def enumerate_vpn_endpoints(self):
        """Discover VPN endpoints."""
        print("[*] Discovering VPN endpoints...")
        vpn_paths = [
            "/+CSCOE+/logon.html",
            "/+webvpn+/index.html",
            "/dana-na/auth/url_default/welcome.cgi",
            "/dana-na/auth/url_admin/welcome.cgi",
            "/dana-na/auth/url/welcome.cgi",
            "/remote/login",
            "/ssl-vpn/login.esp",
        ]

        found_vpn = []
        for path in vpn_paths:
            try:
                resp = requests.get(
                    f"https://{self.domain}{path}",
                    timeout=10, verify=False,
                    allow_redirects=False
                )
                if resp.status_code in [200, 301, 302]:
                    found_vpn.append({
                        "path": path,
                        "status": resp.status_code,
                        "headers": dict(resp.headers)
                    })
                    print(f"  [+] VPN endpoint: {path}")
            except requests.RequestException:
                continue

        return found_vpn

    def generate_report(self):
        return {
            "domain": self.domain,
            "findings": self.findings,
            "subdomains_count": len(self.subdomains) if hasattr(self, "subdomains") else 0,
            "recommendations": [
                "Review all exposed subdomains",
                "Verify email security (SPF/DKIM/DMARC)",
                "Audit VPN endpoint security",
                "Review cloud service configurations",
                "Implement DNS monitoring"
            ]
        }

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python enterprise_recon.py <domain>")
        sys.exit(1)
    recon = EnterpriseRecon(sys.argv[1])
    recon.enumerate_subdomains()
    recon.discover_cloud_services()
    recon.enumerate_email_security()
    recon.enumerate_vpn_endpoints()
    report = recon.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 2: Active Directory Assessment (Days 6-10)

```
Active Directory Attack Path Analysis
========================================

 Initial Access
      |
      v
 +----+----+     +----------------+     +----------------+
 | Creds    |     | Kerberoasting  |     | AS-REP Roasting|
 | from     |     | (SPN accounts) |     | (No preauth)   |
 | Phishing |     +-------+--------+     +-------+--------+
 +----+-----+             |                      |
      |                   v                      v
      v            +------+-------+       +------+-------+
 +----+----+       | Service      |       | Offline      |
 | LLMNR   |       | Account      |       | Cracking     |
 | Poison  |       | Abuse        |       |              |
 +----+-----+      +------+-------+       +--------------+
      |                   |
      v                   v
 +----+----+       +------+-------+       +--------------+
 | NTLM    |       | Delegation   |       | Golden Ticket|
 | Relay   |       | Abuse        |       | (Domain Own) |
 +----+-----+      +------+-------+       +--------------+
      |                   |
      v                   v
 +----+----+       +------+-------+
 | Domain  |       | Resource     |
 | Admin   |       | Constrained  |
 | Compromise|     | Delegation   |
 +---------+       +--------------+
```

#### Step 2.1: Active Directory Security Assessment

```python
import subprocess
import json

class ADAssessment:
    def __init__(self, domain, dc_ip):
        self.domain = domain
        self.dc_ip = dc_ip
        self.findings = []

    def run_impacket_command(self, cmd):
        """Run Impacket command and return output."""
        try:
            result = subprocess.run(
                cmd, shell=True, capture_output=True,
                text=True, timeout=120
            )
            return result.stdout, result.returncode
        except subprocess.TimeoutExpired:
            return "", 1

    def test_kerberoasting(self, username, password):
        """Test for Kerberoasting vulnerabilities."""
        print("[*] Testing Kerberoasting...")
        cmd = (
            f"GetUserSPNs.py {self.domain}/{username}:{password} "
            f"-dc-ip {self.dc_ip} -request"
        )
        stdout, rc = self.run_impacket_command(cmd)
        if rc == 0 and "ServicePrincipalName" in stdout:
            self.findings.append({
                "test": "Kerberoasting",
                "status": "VULNERABLE",
                "severity": "HIGH",
                "detail": "SPN accounts found that can be Kerberoasted",
                "output_snippet": stdout[:500]
            })
            print("  [!] Kerberoasting vulnerability found")
        return stdout

    def test_asrep_roasting(self, username, password):
        """Test for AS-REP Roasting vulnerabilities."""
        print("[*] Testing AS-REP Roasting...")
        cmd = (
            f"GetNPUsers.py {self.domain}/{username}:{password} "
            f"-dc-ip {self.dc_ip} -usersfile users.txt -format hashcat"
        )
        stdout, rc = self.run_impacket_command(cmd)
        if rc == 0 and " krb5asrep " in stdout:
            self.findings.append({
                "test": "AS-REP Roasting",
                "status": "VULNERABLE",
                "severity": "HIGH",
                "detail": "Users without preauth found"
            })
            print("  [!] AS-REP Roasting vulnerability found")
        return stdout

    def test_dcsync(self, username, password):
        """Test for DCSync vulnerability."""
        print("[*] Testing DCSync...")
        cmd = (
            f"secretsdump.py {self.domain}/{username}:{password} "
            f"-dc-ip {self.dc_ip} -just-dc-ntlm"
        )
        stdout, rc = self.run_impacket_command(cmd)
        if rc == 0 and "SAM" in stdout:
            self.findings.append({
                "test": "DCSync",
                "status": "VULNERABLE",
                "severity": "CRITICAL",
                "detail": "DCSync attack successful - full domain compromise"
            })
            print("  [!] DCSync vulnerability found")
        return stdout

    def test_delegation(self, username, password):
        """Test for delegation vulnerabilities."""
        print("[*] Testing delegation settings...")
        cmd = (
            f"findDelegation.py {self.domain}/{username}:{password} "
            f"-dc-ip {self.dc_ip}"
        )
        stdout, rc = self.run_impacket_command(cmd)
        if rc == 0 and " delegation " in stdout.lower():
            self.findings.append({
                "test": "Delegation",
                "status": "FINDINGS",
                "severity": "MEDIUM",
                "detail": "Delegation configurations found",
                "output": stdout
            })
        return stdout

    def test_ntlm_relay(self):
        """Test for NTLM relay vulnerabilities."""
        print("[*] Testing NTLM relay possibilities...")
        self.findings.append({
            "test": "NTLM Relay",
            "status": "REVIEW",
            "severity": "MEDIUM",
            "detail": "Check SMB signing, LDAP signing, HTTP NTLM",
            "checks": [
                "SMB signing on all DCs",
                "LDAP signing and channel binding",
                "HTTP NTLM authentication endpoints",
                "WPAD configuration"
            ]
        })

    def generate_report(self):
        return {
            "domain": self.domain,
            "dc_ip": self.dc_ip,
            "total_findings": len(self.findings),
            "critical": sum(1 for f in self.findings if f.get("severity") == "CRITICAL"),
            "high": sum(1 for f in self.findings if f.get("severity") == "HIGH"),
            "medium": sum(1 for f in self.findings if f.get("severity") == "MEDIUM"),
            "findings": self.findings,
            "recommendations": [
                "Implement Group Managed Service Accounts (gMSA)",
                "Enable Kerberos AES encryption",
                "Remove unnecessary SPNs",
                "Implement LAPS for local admin passwords",
                "Enable Protected Users security group",
                "Monitor for Kerberoasting activity",
                "Implement tiered administration model",
                "Regular AD security assessments"
            ]
        }

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 4:
        print("Usage: python ad_test.py <domain> <dc_ip> <username:password>")
        sys.exit(1)
    assessor = ADAssessment(sys.argv[1], sys.argv[2])
    creds = sys.argv[3]
    username, password = creds.split(":")
    assessor.test_kerberoasting(username, password)
    assessor.test_asrep_roasting(username, password)
    assessor.test_dcsync(username, password)
    assessor.test_delegation(username, password)
    assessor.test_ntlm_relay()
    report = assessor.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 3: Enterprise Application Assessment (Days 11-15)

```
Enterprise Application Attack Surface
========================================

 ERP Systems                    Collaboration
 +------------------+          +------------------+
 | SAP              |          | SharePoint       |
 | Oracle EBS       |          | Exchange/OWA     |
 | PeopleSoft       |          | Teams            |
 +------------------+          +------------------+

 Custom Applications           Cloud Applications
 +------------------+          +------------------+
 | Internal Web Apps|          | Office 365       |
 | APIs             |          | Salesforce       |
 | Microservices    |          | Workday          |
 +------------------+          +------------------+

 Legacy Systems                Databases
 +------------------+          +------------------+
 | Mainframe        |          | Oracle           |
 | AS/400           |          | SQL Server       |
 | Legacy Unix      |          | PostgreSQL       |
 +------------------+          +------------------+
```

#### Step 3.1: Enterprise Application Security Testing

```python
import requests
import json

class EnterpriseAppTest:
    COMMON_ENTERPRISE_PATHS = [
        # SAP
        "/sap/bc/gui/sap/itlogon",
        "/sap/bc/gui/sap/adt/login",
        "/sap/public/ping",
        "/sap/bc/adt/core/start",
        # Oracle
        "/ords/",
        "/apex/",
        "/em/",
        "/console",
        # SharePoint
        "/_layouts/15/view.aspx",
        "/_api/web/siteusers",
        "/_vti_bin/",
        # Exchange
        "/owa/auth/logon.aspx",
        "/EWS/Exchange.asmx",
        "/autodiscover/autodiscover.xml",
        "/mapi/emsmdb/",
        # PeopleSoft
        "/psc/ps/",
        "/PSIGW/IntegrationConnector",
    ]

    def __init__(self, base_url):
        self.base_url = base_url.rstrip("/")
        self.findings = []

    def test_enterprise_applications(self):
        """Discover and test enterprise applications."""
        print("[*] Discovering enterprise applications...")
        for path in self.COMMON_ENTERPRISE_PATHS:
            try:
                resp = requests.get(
                    f"{self.base_url}{path}",
                    timeout=10, verify=False,
                    allow_redirects=False
                )
                if resp.status_code in [200, 301, 302, 401, 403]:
                    self.findings.append({
                        "type": "ENTERPRISE_APP",
                        "path": path,
                        "status": resp.status_code,
                        "severity": "INFO"
                    })
                    print(f"  [+] Enterprise app: {path} ({resp.status_code})")
            except requests.RequestException:
                continue

    def test_legacy_systems(self):
        """Test for legacy system exposure."""
        print("[*] Testing for legacy system exposure...")
        legacy_paths = [
            "/cgi-bin/", "/cgi-sys/",
            "/phpinfo.php", "/server-status",
            "/server-info", "/.env",
            "/web.config", "/config.php",
            "/wp-admin/", "/wp-login.php",
            "/joomla/", "/administrator/",
            "/tomcat/", "/manager/",
            "/jmx-console/", "/web-console/",
        ]

        for path in legacy_paths:
            try:
                resp = requests.get(
                    f"{self.base_url}{path}",
                    timeout=10, verify=False
                )
                if resp.status_code == 200:
                    self.findings.append({
                        "type": "LEGACY_SYSTEM",
                        "path": path,
                        "status": resp.status_code,
                        "severity": "MEDIUM",
                        "detail": "Legacy system or configuration exposed"
                    })
                    print(f"  [!] Legacy system: {path}")
            except requests.RequestException:
                continue

    def test_api_endpoints(self):
        """Discover and test API endpoints."""
        print("[*] Discovering API endpoints...")
        api_paths = [
            "/api/", "/api/v1/", "/api/v2/", "/api/v3/",
            "/rest/", "/graphql",
            "/swagger.json", "/openapi.json", "/swagger-ui/",
            "/api-docs/", "/redoc/",
            "/api/swagger", "/api/docs",
        ]

        for path in api_paths:
            try:
                resp = requests.get(
                    f"{self.base_url}{path}",
                    timeout=10, verify=False
                )
                if resp.status_code in [200, 401, 403]:
                    self.findings.append({
                        "type": "API_ENDPOINT",
                        "path": path,
                        "status": resp.status_code,
                        "severity": "MEDIUM" if resp.status_code == 200 else "LOW"
                    })
                    print(f"  [!] API endpoint: {path} ({resp.status_code})")
            except requests.RequestException:
                continue

    def test_sharepoint_security(self):
        """Test SharePoint-specific vulnerabilities."""
        print("[*] Testing SharePoint security...")
        sharepoint_checks = [
            ("/_api/web/siteusers", "User enumeration"),
            ("/_api/web/lists", "List enumeration"),
            ("/_vti_bin/", "Frontpage extensions"),
            ("/_layouts/15/", "Layout disclosure"),
            ("/_api/web/GetFileByServerRelativeUrl('/web.config')", "Config access"),
        ]

        for path, check_name in sharepoint_checks:
            try:
                resp = requests.get(
                    f"{self.base_url}{path}",
                    timeout=10, verify=False
                )
                if resp.status_code == 200:
                    self.findings.append({
                        "type": "SHAREPOINT_ISSUE",
                        "check": check_name,
                        "path": path,
                        "severity": "MEDIUM"
                    })
                    print(f"  [!] SharePoint: {check_name}")
            except requests.RequestException:
                continue

    def test_exchange_security(self):
        """Test Exchange-specific vulnerabilities."""
        print("[*] Testing Exchange security...")
        exchange_paths = [
            "/owa/auth/logon.aspx",
            "/EWS/Exchange.asmx",
            "/autodiscover/autodiscover.xml",
            "/mapi/emsmdb/",
            "/Microsoft-Server-ActiveSync/",
            "/ews/exchange.asmx",
            "/ecp/",
            "/powershell/",
        ]

        for path in exchange_paths:
            try:
                resp = requests.get(
                    f"{self.base_url}{path}",
                    timeout=10, verify=False,
                    allow_redirects=False
                )
                if resp.status_code in [200, 301, 302, 401]:
                    self.findings.append({
                        "type": "EXCHANGE_ENDPOINT",
                        "path": path,
                        "status": resp.status_code,
                        "severity": "INFO"
                    })
                    print(f"  [+] Exchange endpoint: {path}")
            except requests.RequestException:
                continue

    def generate_report(self):
        return {
            "target": self.base_url,
            "total_findings": len(self.findings),
            "critical": sum(1 for f in self.findings if f.get("severity") == "CRITICAL"),
            "high": sum(1 for f in self.findings if f.get("severity") == "HIGH"),
            "medium": sum(1 for f in self.findings if f.get("severity") == "MEDIUM"),
            "findings": self.findings,
            "recommendations": [
                "Implement application whitelisting",
                "Deploy WAF for all public-facing applications",
                "Regular vulnerability scanning and patching",
                "Implement API gateway with authentication",
                "Review SharePoint/Exchange security configurations",
                "Decommission legacy systems",
                "Implement network segmentation for legacy apps"
            ]
        }

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python enterprise_app_test.py <base_url>")
        sys.exit(1)
    tester = EnterpriseAppTest(sys.argv[1])
    tester.test_enterprise_applications()
    tester.test_legacy_systems()
    tester.test_api_endpoints()
    tester.test_sharepoint_security()
    tester.test_exchange_security()
    report = tester.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 4: Compliance and Configuration Assessment (Days 16-18)

```
Compliance Assessment Framework
==================================

 PCI DSS                          HIPAA
 +------------------+            +------------------+
 | Cardholder Data  |            | PHI Protection   |
 | Environment      |            | BAAs             |
 | Network Segment. |            | Access Controls  |
 | Encryption       |            | Audit Trails     |
 +------------------+            +------------------+

 SOX                              GDPR
 +------------------+            +------------------+
 | Financial Controls|           | Data Privacy     |
 | Audit Trails     |            | Breach Notify    |
 | Access Reviews   |            | Data Subject     |
 | Change Management|            | Rights           |
 +------------------+            +------------------+
```

#### Step 4.1: Compliance Configuration Check

```python
import json

class ComplianceCheck:
    def __init__(self, environment):
        self.environment = environment
        self.findings = []

    def check_pci_dss(self):
        """Check PCI DSS compliance indicators."""
        print("[*] Checking PCI DSS compliance...")
        pci_checks = [
            {
                "requirement": "Req 1: Firewall Configuration",
                "check": "Restrict inbound/outbound traffic",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 2: Default Configurations",
                "check": "Change vendor-supplied defaults",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 3: Stored Cardholder Data",
                "check": "Protect stored cardholder data",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 4: Encryption in Transit",
                "check": "Encrypt transmission of CHD",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 6: Secure Systems",
                "check": "Develop and maintain secure systems",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 7: Access Restriction",
                "check": "Restrict access on need-to-know",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 8: Authentication",
                "check": "Assign unique ID to each person",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 10: Logging",
                "check": "Track and monitor all access",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 11: Testing",
                "check": "Regularly test security systems",
                "status": "REVIEW"
            },
            {
                "requirement": "Req 12: Policy",
                "check": "Maintain information security policy",
                "status": "REVIEW"
            },
        ]

        for check in pci_checks:
            self.findings.append({
                "framework": "PCI DSS",
                "requirement": check["requirement"],
                "check": check["check"],
                "status": check["status"]
            })

    def check_hipaa(self):
        """Check HIPAA compliance indicators."""
        print("[*] Checking HIPAA compliance...")
        hipaa_checks = [
            {
                "requirement": "Administrative Safeguards",
                "check": "Security management process",
                "status": "REVIEW"
            },
            {
                "requirement": "Physical Safeguards",
                "check": "Facility access controls",
                "status": "REVIEW"
            },
            {
                "requirement": "Technical Safeguards",
                "check": "Access control, audit controls",
                "status": "REVIEW"
            },
            {
                "requirement": "Breach Notification",
                "check": "Notification procedures",
                "status": "REVIEW"
            },
        ]

        for check in hipaa_checks:
            self.findings.append({
                "framework": "HIPAA",
                "requirement": check["requirement"],
                "check": check["check"],
                "status": check["status"]
            })

    def check_sox(self):
        """Check SOX compliance indicators."""
        print("[*] Checking SOX compliance...")
        sox_checks = [
            {
                "requirement": "Section 302",
                "check": "CEO/CFO certification of financial reports",
                "status": "REVIEW"
            },
            {
                "requirement": "Section 404",
                "check": "Internal controls over financial reporting",
                "status": "REVIEW"
            },
            {
                "requirement": "IT General Controls",
                "check": "Change management, access controls",
                "status": "REVIEW"
            },
        ]

        for check in sox_checks:
            self.findings.append({
                "framework": "SOX",
                "requirement": check["requirement"],
                "check": check["check"],
                "status": check["status"]
            })

    def generate_report(self):
        return {
            "environment": self.environment,
            "total_checks": len(self.findings),
            "findings": self.findings,
            "recommendations": [
                "Implement automated compliance monitoring",
                "Conduct regular internal audits",
                "Document all security controls",
                "Implement continuous compliance validation",
                "Maintain compliance evidence repository",
                "Regular third-party assessments"
            ]
        }

if __name__ == "__main__":
    checker = ComplianceCheck("enterprise")
    checker.check_pci_dss()
    checker.check_hipaa()
    checker.check_sox()
    report = checker.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 5: Analysis and Reporting (Days 19-21)

```
Enterprise Reporting Framework
================================

 Findings Classification
 +---------------------------+
 | CRITICAL                  |  Domain compromise, data breach
 | HIGH                      |  Privilege escalation, data exposure
 | MEDIUM                    |  Weak controls, misconfiguration
 | LOW                       |  Best practice gaps
 | INFO                      |  Recommendations
 +---------------------------+

 Business Impact Analysis
 +---------------------------+
 | Financial Impact          |  Direct costs, fines, lawsuits
 | Operational Impact       |  Business disruption
 | Reputational Impact      |  Brand damage, customer loss
 | Regulatory Impact        |  Compliance violations
 | Strategic Impact         |  M&A, competitive advantage
 +---------------------------+
```

---

## 5. Tool Arsenal

### Active Directory Testing

```bash
# Bloodhound enumeration
bloodhound-python -u user -p pass -d domain.local -dc dc.domain.local -c All

# Kerberoasting
GetUserSPNs.py domain/user:password -dc-ip dc_ip -request

# AS-REP Roasting
GetNPUsers.py domain/user:password -usersfile users.txt -format hashcat

# DCSync
secretsdump.py domain/user:password -dc-ip dc_ip -just-dc-ntlm

# Pass-the-Hash
psexec.py -hashes :ntlm_hash domain/user@target

# Evil-WinRM
evil-winrm -i target -u user -p password
```

### Network Testing

```bash
# Comprehensive port scan
nmap -sV -sC -O -p- --min-rate 10000 -oA full_scan target

# SMB enumeration
enum4linux -a target
smbclient -L //target -U user

# SNMP enumeration
snmpwalk -v2c -c public target

# Kerberos enumeration
nmap -p 88 --script krb5-enum-users --script-args krb5-enum-users.realm=DOMAIN target
```

### Web Application Testing

```bash
# Nuclei with enterprise templates
nuclei -u <target> -t nuclei-templates/ -severity critical,high

# Burp Suite Enterprise
# Use automated scanning + manual testing

# API testing
ffuf -u <target>/api/FUZZ -w enterprise_api.txt -mc 200

# SQL injection
sqlmap -u "target/?id=1" --batch --level 5 --risk 3
```

### Cloud Security

```bash
# Multi-cloud assessment
Prowler aws --profile <profile>
Prowler gcp --project-id <project>
Prowler azure --cli-auth

# Azure AD
AzureADRecon -TenantID <tenant> -Username <user> -Password <pass>

# O365
o365creeper.py -u user@domain.com
```

---

## 6. Real-World Examples

### Example 1: Enterprise Ransomware via VPN

```
Scenario:
- Manufacturing company, 5000 employees
- Ransomware deployed via compromised VPN credentials
- No MFA on VPN, flat network architecture

Attack Path:
1. Credential stuffing against VPN
2. VPN credentials reused from breach
3. No MFA, direct network access
4. Lateral movement via SMB
5. Domain admin compromise
6. Ransomware deployment via GPO

Impact:
- $5M ransom (not paid)
- $20M in recovery costs
- 3 weeks of operational downtime
- 2000 employees idle
- Regulatory notification required

Lessons Learned:
- Implement MFA on all remote access
- Network segmentation critical
- Implement Privileged Access Management
- Regular backup testing
```

### Example 2: M&A Integration Security Gap

```
Scenario:
- Acquisition of smaller company
- IT systems integrated without security review
- Attacker compromised acquired company first

Attack Path:
1. Compromised acquired company email
2. Used trust relationship to access parent
3. Moved laterally through integrated network
4. Exfiltrated intellectual property

Impact:
- $50M in IP theft
- Competitive advantage lost
- Board-level investigation
- Acquisition deal value reduced

Lessons Learned:
- Security due diligence before M&A
- Network segmentation during integration
- Trust relationship audit
- Assume breach posture
```

### Example 3: Insider Threat Data Exfiltration

```
Scenario:
- Financial services employee leaving for competitor
- Used privileged access to download customer data
- DLP not configured for cloud storage

Attack Path:
1. Employee gave notice of departure
2. Continued normal work activities
3. Downloaded customer database via approved tool
4. Uploaded to personal cloud storage
5. Left company with data

Impact:
- 100,000 customer records stolen
- Regulatory investigation
- $10M in potential fines
- Competitive damage

Lessons Learned:
- Implement UEBA for anomaly detection
- Monitor privileged user activity
- DLP for all storage locations
- Enhanced monitoring during notice period
```

---

## 7. Bypass Techniques

### 7.1 Enterprise Network Bypass

```
Enterprise Network Bypass Vectors
====================================

 [1] VLAN Hopping
     - Double 802.1Q tagging
     - Switch spoofing via DTP
     - Impact: Cross-VLAN access

 [2] IPv6 Tunneling
     - 6to4 tunnels through IPv4 filters
     - Teredo tunneling
     - Impact: Bypass IPv4 ACLs

 [3] DNS Rebinding
     - Short TTL DNS records
     - Bypass host-based access controls
     - Impact: Internal network access

 [4] SSL/TLS Inspection Bypass
     - Certificate pinning in applications
     - Custom cipher suites
     - Impact: Traffic inspection bypass

 [5] Proxy Chaining
     - Multiple proxy hops
     - Residential proxy networks
     - Impact: Source attribution bypass
```

### 7.2 Active Directory Bypass

```python
class ADBypassTest:
    def test_kerberos_encryption_downgrade(self):
        """Test Kerberos encryption downgrade."""
        findings = []
        findings.append({
            "technique": "RC4 Downgrade",
            "description": "Force RC4 encryption for Kerberos",
            "impact": "Weaker encryption easier to crack",
            "detection": "Monitor for RC4 ticket requests"
        })
        return findings

    def test_cloud_sync_bypass(self):
        """Test Azure AD sync bypass."""
        findings = []
        findings.append({
            "technique": "Azure AD Direct Auth",
            "description": "Authenticate directly to Azure AD",
            "impact": "Bypass on-premises controls",
            "detection": "Monitor Azure AD sign-in logs"
        })
        return findings

    def test_certificate_abuse(self):
        """Test certificate-based authentication abuse."""
        findings = []
        findings.append({
            "technique": "Shadow Credentials",
            "description": "Add certificates to AD objects",
            "impact": "Persistent authentication bypass",
            "detection": "Monitor certificate enrollment events"
        })
        findings.append({
            "technique": "Golden Certificate",
            "description": "Forge certificate for any user",
            "impact": "Complete domain compromise",
            "detection": "Monitor certificate template changes"
        })
        return findings
```

---

## 8. Common Pitfalls

### 8.1 Enterprise Testing Pitfalls

```
Common Enterprise Testing Mistakes
=====================================

 [1] DISRUPTING PRODUCTION SYSTEMS
     - Scanning production databases
     - Brute-forcing production accounts
     - Mitigation: Test in staging, coordinate with ops

 [2] MISSING CHANGE MANAGEMENT
     - Testing without change request
     - Running scans during freeze period
     - Mitigation: Follow enterprise change process

 [3] UNDERESTIMATING SEGMENTATION
     - Assuming flat network
     - Missing microsegmentation
     - Mitigation: Map network before testing

 [4] IGNORING LEGACY SYSTEMS
     - Overlooking AS/400, mainframe
     - Missing legacy protocols
     - Mitigation: Comprehensive asset discovery

 [5] FORGETTING CLOUD HYBRID
     - Testing only on-premises
     - Missing cloud-connected resources
     - Mitigation: Test hybrid environment holistically

 [6] MISSING PHYSICAL SECURITY
     - Focusing only on digital
     - Ignoring badge access, tailgating
     - Mitigation: Include physical assessment

 [7] OVERLOOKING OPERATIONAL TECHNOLOGY
     - Ignoring OT/ICS systems
     - Different protocols and risks
     - Mitigation: Separate OT assessment methodology

 [8] NOT COORDINATING WITH SOC
     - SOC alerts during testing
     - False positive fatigue
     - Mitigation: SOC notification and deconfliction
```

---

## 9. Reporting Template

```
ENTERPRISE SECURITY ASSESSMENT REPORT
=======================================

Document Information:
- Company: [Enterprise Name]
- Industry: [Industry]
- Assessment Period: [Dates]
- Assessor: [Name/Org]
- Classification: CONFIDENTIAL
- Version: [Version]

---

EXECUTIVE SUMMARY

[2-3 paragraphs for C-suite and Board. Focus on business
risk, regulatory implications, and strategic recommendations.]

OVERALL RISK RATING: [CRITICAL / HIGH / MEDIUM / LOW]

KEY METRICS:
- Total Findings: [N]
- Critical: [N] | High: [N] | Medium: [N] | Low: [N]
- Estimated Remediation: $[N] and [N] months
- Regulatory Risk: [Assessment]

---

BUSINESS UNIT IMPACT

[Impact analysis by business unit]

- Finance: [Impact]
- Operations: [Impact]
- IT: [Impact]
- Legal: [Impact]
- Human Resources: [Impact]

---

SCOPE AND METHODOLOGY

Scope:
- Network ranges: [List]
- Domains: [List]
- Applications: [List]
- Cloud resources: [List]

Methodology:
- Reconnaissance: [Description]
- Vulnerability Assessment: [Description]
- Exploitation: [Description]
- Post-Exploitation: [Description]
- Compliance Review: [Description]

Standards Referenced:
- OWASP Testing Guide v4.2
- NIST SP 800-115
- PTES (Penetration Testing Execution Standard)
- CIS Benchmarks

---

FINDINGS

[For each finding:]

FINDING #[N]: [Title]
Severity: [Level] | CVSS: [Score]
Business Unit: [Affected]
Affected System(s): [Details]

Description: [Detailed explanation]
Business Impact: [Business-focused impact]
Regulatory Impact: [Compliance implications]
Evidence: [Technical details]
Remediation: [Detailed fix with timeline]

---

COMPLIANCE MAPPING

+------------------+--------+--------+--------+--------+
| Finding          | PCI    | HIPAA  | SOX    | GDPR   |
+------------------+--------+--------+--------+--------+
| [Finding 1]      |   X    |        |   X    |        |
| [Finding 2]      |        |   X    |        |   X    |
+------------------+--------+--------+--------+--------+

---

REMEDIATION ROADMAP

Phase 1 - Immediate (0-30 days): $[Budget]
- [Critical findings]

Phase 2 - Short-term (30-90 days): $[Budget]
- [High findings]

Phase 3 - Medium-term (90-180 days): $[Budget]
- [Medium findings]

Phase 4 - Long-term (180-365 days): $[Budget]
- [Strategic improvements]

---

RISK ASSESSMENT MATRIX

+------------------+------------------+------------------+
|                  |   LIKELIHOOD     |                  |
|   IMPACT         | Low  | Med  |High|                  |
+------------------+------+------+----+                  |
| High             | Med  | High | Crit|                  |
| Medium           | Low  | Med  | High|                  |
| Low              | Info | Low  | Med |                  |
+------------------+------+------+----+                  |

---

APPENDICES

A. Detailed Network Diagrams
B. Asset Inventory
C. Tool Output and Raw Data
D. Compliance Evidence
E. Assessor Qualifications
F. Scope and Authorization Documents

---

DOCUMENT APPROVAL

Prepared by: _________________ Date: _________
Reviewed by: _________________ Date: _________
Approved by: _________________ Date: _________
```

---

## 10. Quick Reference

### Enterprise Testing Checklist

```
PRE-ENGAGEMENT
[ ] CISO/Board authorization
[ ] MSA and RoE signed
[ ] SOC notification
[ ] Change management approved
[ ] Emergency contacts established
[ ] Background checks completed
[ ] NDA executed

ACTIVE DIRECTORY
[ ] Domain enumeration
[ ] Kerberoasting testing
[ ] AS-REP Roasting testing
[ ] Delegation analysis
[ ] Trust relationship mapping
[ ] GPO analysis
[ ] Certificate services audit

NETWORK
[ ] Internal/external scanning
[ ] Segmentation testing
[ ] VLAN hopping testing
[ ] Wireless assessment
[ ] VPN security testing
[ ] DNS security review

APPLICATIONS
[ ] ERP security testing
[ ] SharePoint assessment
[ ] Exchange security review
[ ] Custom app testing
[ ] API security testing
[ ] Legacy system review

CLOUD
[ ] Multi-cloud assessment
[ ] Hybrid identity testing
[ ] SaaS security review
[ ] Container security
[ ] Serverless security

COMPLIANCE
[ ] PCI DSS assessment
[ ] HIPAA compliance check
[ ] SOX controls review
[ ] GDPR compliance check

REPORTING
[ ] Executive summary
[ ] Detailed findings
[ ] Compliance mapping
[ ] Remediation roadmap
[ ] Business impact analysis
```

### Enterprise Emergency Response Contacts

```
Role                      Contact                 Phone
------------------------- ----------------------- ----------
CISO                      [Name]                  [Number]
VP of Security            [Name]                  [Number]
SOC Manager               [Name]                  [Number]
IT Operations Director    [Name]                  [Number]
Legal Counsel             [Name]                  [Number]
PR/Communications         [Name]                  [Number]
External IR Firm          [Firm]                  [Number]
Cyber Insurance           [Carrier]               [Policy#]
FBI Cyber Division        Local Office            [Number]
Secret Service (financial)| Local Office           [Number]
```

---

## References

- NIST SP 800-115: Technical Guide to Information Security Testing
- NIST SP 800-53: Security and Privacy Controls
- MITRE ATT&CK Framework
- CIS Benchmarks
- OWASP Testing Guide v4.2
- SANS Institute Security Guidelines
- ISO 27001/27002 Standards
- COBIT Framework
