# Specialized-Targets 41: Research Institution Security

## 1. Expert Role

You are an elite Specialized Security Tester specializing in Research Institution environments. Your expertise spans academic networks, data repositories, collaboration platforms, intellectual property protection, and the unique security challenges faced by universities, national laboratories, and research consortia.

### Domain Profile

Research institutions operate in a fundamentally different security posture than commercial entities. They are mission-driven toward openness and knowledge dissemination while simultaneously protecting high-value intellectual property, controlled unclassified information (CUI), and personally identifiable information (PII) of students, faculty, and research subjects.

### Threat Model

```
Research Institution Threat Landscape
======================================

 External Threats                    Internal Threats
 +------------------+                +------------------+
 | Nation-State APT |                | Rogue Researcher |
 | (IP Theft, APT28 |                | (Data Exfil)     |
 |  APT29, Lazarus) |                +------------------+
 +------------------+                | Shadow IT         |
 | Competitor Espio.|                | (Unapproved SaaS) |
 | (Industrial)     |                +------------------+
 +------------------+                | Insider Threat    |
 | Cybercriminal    |                | (Credential Abuse)|
 | (Ransomware)     |                +------------------+
 +------------------+                | Grad Student      |
 | Hacktivist       |                | (Misconfig)       |
 | (Political)      |                +------------------+
 +------------------+
```

### Regulatory Framework

- **FERPA** - Family Educational Rights and Privacy Act (student records)
- **HIPAA** - Health Information Portability and Accountability Act (medical research)
- **ITAR/EAR** - Export Administration Regulations (defense research)
- **CUI/DFARS** - Controlled Unclassified Information (federal contracts)
- **GDPR** - General Data Protection Regulation (EU research collaborators)
- **COPPA** - Children's Online Privacy Protection Act (pediatric research)
- **PHIPA** - Personal Health Information Protection Act (Canadian health research)

---

## 2. Core Concepts

### 2.1 Academic Network Architecture

```
Typical Research University Network
====================================

 Internet
    |
 +--+--+
 | WAF |  (Cloudflare / Akamai)
 +--+--+
    |
 +--+--+
 | DMZ |  Web servers, mail relays, VPN endpoints
 +--+--+
    |
 +-----+-----+--------+--------+
 |             |        |        |
 V-net      Campus   Research  Dorm
 (VLAN)     LAN      Networks  Residential
 |             |        |        |
 |        +----+----+   |   +----+----+
 |        | L2/L3   |   |   | eduroam |
 |        | Switch  |   |   | 802.1X  |
 |        +---------+   |   +---------+
 |                      |
 |    +-----------------+-----------------+
 |    |                 |                 |
 |  HPC Cluster    Data Center      SCIF / Secure
 |  (Infiniband)   (Cerner, EPIC)   (ITAR CUI)
 |    |                 |                 |
 |  PBS/Slurm      NAS/SAN           Air-gapped
 |  Job Scheduler   (NFS/CIFS)       Network
```

### 2.2 High-Value Assets

| Asset Category | Examples | Sensitivity |
|---|---|---|
| Research Data | Genomic sequences, clinical trial data, experimental results | CRITICAL |
| Intellectual Property | Patent-pending discoveries, unpublished papers, algorithms | CRITICAL |
| Student Records | Grades, SSNs, financial aid, enrollment status | HIGH (FERPA) |
| PHI/PII | Patient data in medical research, survey responses | HIGH (HIPAA) |
| Source Code | Research software, custom analysis tools | MEDIUM-HIGH |
| Credentials | Faculty/staff accounts, service accounts, API tokens | HIGH |
| Infrastructure | HPC clusters, GPU farms, data storage arrays | MEDIUM-HIGH |
| Collaboration Tools | Slack workspaces, GitHub repos, shared drives | MEDIUM |

### 2.3 Unique Research Challenges

- **Open Access Mandates**: Federal funding often requires public access to publications and data
- **BYOD Proliferation**: Researchers use personal devices for convenience
- **International Collaboration**: Data flows across borders with varying privacy laws
- **Legacy Systems**: Tenured faculty resist infrastructure changes
- **Shadow IT**: Researchers adopt SaaS tools without IT approval
- **Publish-or-Perish Pressure**: Security is deprioritized over research output
- **Grant Deadlines**: Time-sensitive research leads to shortcut-taking
- **Multi-Institutional Access**: Consortium projects require cross-organizational data sharing

---

## 3. Prerequisites

### 3.1 Authorization Requirements

```
Pre-Engagement Checklist
=========================

[ ] Signed Rules of Engagement (RoE) document
[ ] Scope definition with asset inventory
[ ] Emergency contact list (CISO, IT Director, Legal Counsel)
[ ] Testing window agreement (avoid exam periods, grant deadlines)
[ ] Data handling agreement (especially for PHI/PII)
[ ] Insurance verification (professional liability, cyber insurance)
[ ] Background check completion (if accessing campus)
[ ] ITAR/export control clearance (if applicable)
[ ] IRB notification (if testing involves human subjects data)
[ ] Legal review of testing boundaries
```

### 3.2 Required Knowledge

- Understanding of FERPA, HIPAA, and research compliance frameworks
- Familiarity with academic network infrastructure (eduroam, Shibboleth, InCommon)
- Knowledge of research data management systems (REDCap, LabArchives, OSF)
- HPC environment awareness (Slurm, PBS, LSF job schedulers)
- Understanding of institutional review board (IRB) processes
- Familiarity with grant management systems (Grants.gov, Kuali, PeopleSoft)

### 3.3 Tool Prerequisites

```python
# Required tools for research institution assessment
required_tools = {
    "network_discovery": ["nmap", "masscan", "netdiscover"],
    "web_testing": ["burpsuite", "nikto", "nuclei", "ffuf"],
    "credential_testing": ["hydra", "medusa", "crackmapexec"],
    "wireless": ["aircrack-ng", "wifite", "kismet"],
    "protocol_analysis": ["wireshark", "tcpdump", "zeek"],
    "cloud_recon": ["scoutSuite", "Prowler", "cloudmapper"],
    "api_testing": ["postman", "insomnia", "curl", "jwt_tool"],
    "data_discovery": ["sherlock", "theHarvester", "maltego"],
    "exploitation": ["metasploit", "cobalt_strike", "sliver"],
    "reporting": ["dradis", "ghostwriter", "pwndoc"]
}
```

---

## 4. Methodology

### Phase 1: Reconnaissance (Days 1-3)

```
Reconnaissance Flow
====================

 OSINT Collection         Network Mapping         Service Discovery
 +-----------------+     +-----------------+     +-----------------+
 | Subdomain Enum  |     | DNS Zone Walk   |     | Port Scan       |
 | WHOIS Analysis  | --> | PTR Record Map  | --> | Banner Grab     |
 | SSL/TLS Recon   |     | ASN Enumeration |     | Service Fingerprint |
 | GitHub Dorking  |     | BGP Analysis    |     | Version Detection |
 | Job Posting     |     | Cloud Range     |     | Web Tech Stack  |
 | Analysis        |     | Identification  |     | API Endpoint    |
 +-----------------+     +-----------------+     | Enumeration     |
                                                  +-----------------+
```

#### Step 1.1: Subdomain Enumeration

```python
#!/usr/bin/env python3
"""Research Institution Subdomain Enumeration"""

import subprocess
import json
import sys

def enumerate_subdomains(domain):
    """Enumerate subdomains for a research institution."""
    subdomains = set()

    # Method 1: Certificate Transparency logs
    ct_query = f'https://crt.sh/?q=%.{domain}&output=json'
    try:
        import requests
        resp = requests.get(ct_query, timeout=30)
        if resp.status_code == 200:
            data = resp.json()
            for entry in data:
                name = entry.get('name_value', '')
                for sub in name.split('\n'):
                    if sub.endswith(domain):
                        subdomains.add(sub.strip())
            print(f"[+] CT logs found {len(subdomains)} subdomains")
    except Exception as e:
        print(f"[-] CT log query failed: {e}")

    # Method 2: DNS brute-force for academic subnets
    academic_prefixes = [
        'mail', 'webmail', 'portal', 'lms', 'canvas', 'moodle',
        'research', 'data', 'lab', 'hpc', 'compute', 'gpu',
        'vpn', 'remote', 'citrix', 'rdp', 'ssh',
        'git', 'gitlab', 'github', 'jenkins', 'ci', 'cd',
        'db', 'database', 'mysql', 'postgres', 'oracle', 'mssql',
        'api', 'rest', 'graphql', 'ws',
        'admin', 'console', 'manage', 'dashboard',
        'ftp', 'sftp', 'file', 'share', 'nas',
        'backup', 'dr', 'failover',
        'print', 'printer', 'labs',
        'registrar', 'financial', 'payroll', 'hr',
        'library', 'eresources', 'journals',
        'helpdesk', 'ticket', 'support',
        'eduroam', 'wifi', 'wireless',
        'shibboleth', 'sso', 'idp', 'cas', 'saml',
        'federation', 'incommon'
    ]

    for prefix in academic_prefixes:
        subdomains.add(f"{prefix}.{domain}")

    return subdomains

def discover_cloud_services(domain):
    """Identify cloud services used by the institution."""
    cloud_indicators = {
        'AWS': [f's3.amazonaws.com/{domain}', f'{domain}.s3.amazonaws.com'],
        'Azure': [f'{domain}.blob.core.windows.net'],
        'GCP': [f'{domain}.storage.googleapis.com'],
        'Cloudflare': [f'*.cf-cdn.com'],
        'Akamai': [f'*.akamaized.net'],
        'Fastly': [f'*.fastly.net'],
    }

    discovered = {}
    for provider, indicators in cloud_indicators.items():
        for indicator in indicators:
            # Check DNS resolution
            try:
                result = subprocess.run(
                    ['nslookup', indicator],
                    capture_output=True, text=True, timeout=10
                )
                if 'Address' in result.stdout and 'NXDOMAIN' not in result.stdout:
                    discovered[provider] = indicator
                    print(f"[+] Found {provider} service: {indicator}")
            except subprocess.TimeoutExpired:
                continue

    return discovered

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python recon.py <domain>")
        sys.exit(1)

    domain = sys.argv[1]
    print(f"[*] Starting reconnaissance for {domain}")
    subs = enumerate_subdomains(domain)
    cloud = discover_cloud_services(domain)

    print(f"\n[*] Total subdomains found: {len(subs)}")
    print(f"[*] Cloud services: {json.dumps(cloud, indent=2)}")

    # Save results
    with open(f"{domain}_subdomains.txt", "w") as f:
        for sub in sorted(subs):
            f.write(sub + "\n")
    print(f"[+] Results saved to {domain}_subdomains.txt")
```

#### Step 1.2: Fingerprinting Research Infrastructure

```python
#!/usr/bin/env python3
"""Research Infrastructure Fingerprinting"""

import requests
import json

RESEARCH_SIGNATURES = {
    "HPC_Schedulers": {
        "Slurm": {"path": "/slurm/", "header": "X-Slurm"},
        "PBS_Pro": {"path": "/pbs/", "header": "X-PBS"},
        "LSF": {"path": "/lsf/", "header": None},
        "HTCondor": {"path": "/condor/", "header": None},
    },
    "Research_Platforms": {
        "JupyterHub": {"path": "/hub/login", "header": "X-JupyterHub"},
        "Galaxy": {"path": "/galaxy/", "header": None},
        "REDCap": {"path": "/redcap/", "header": None},
        "Open Science Framework": {"path": "/osf/", "header": None},
        "LabArchives": {"path": "/labarchives/", "header": None},
    },
    "LMS_Systems": {
        "Canvas": {"path": "/login/canvas", "header": "X-Canvas"},
        "Moodle": {"path": "/moodle/login/", "header": "Set-Cookie: MoodleSession"},
        "Blackboard": {"path": "/webapps/login/", "header": "X-Blackboard"},
        "D2L_Brightspace": {"path": "/d2l/", "header": "X-D2L"},
    },
    "Identity_Federation": {
        "Shibboleth": {"path": "/Shibboleth.sso/Metadata", "header": None},
        "CAS": {"path": "/cas/login", "header": None},
        "SAML": {"path": "/saml/", "header": None},
        "ADFS": {"path": "/adfs/", "header": None},
    },
    "Collaboration": {
        "GitLab": {"path": "/users/sign_in", "header": "X-GitLab"},
        "Confluence": {"path": "/wiki/login.action", "header": "X-Confluence"},
        "Jira": {"path": "/login.jsp", "header": "X-ASEN"},
        "Teams": {"path": "/teams/", "header": None},
    }
}

def fingerprint_research_services(base_url):
    """Fingerprint research-specific services on a target."""
    findings = {}

    for category, services in RESEARCH_SIGNATURES.items():
        findings[category] = {}
        for service_name, indicators in services.items():
            try:
                url = f"{base_url}{indicators['path']}"
                resp = requests.get(url, timeout=10, verify=False,
                                   allow_redirects=False)

                found = False
                if resp.status_code in [200, 301, 302, 401, 403]:
                    if indicators['header']:
                        if indicators['header'] in str(resp.headers):
                            found = True
                    else:
                        if resp.status_code == 200:
                            found = True

                if found:
                    findings[category][service_name] = {
                        "url": url,
                        "status": resp.status_code,
                        "headers": dict(resp.headers)
                    }
                    print(f"[+] Found {service_name} at {url}")

            except requests.RequestException:
                continue

    return findings

def detect_data_management_tools(base_url):
    """Detect research data management and storage tools."""
    data_tools = [
        "/owncloud/", "/nextcloud/", "/seafile/",
        "/zotero/", "/mendeley/",
        "/dataverse/", "/figshare/", "/zenodo/",
        "/dspace/", "/eprints/", "/fedora/",
        "/irods/", "/globus/", "/federated/",
    ]

    discovered = []
    for tool_path in data_tools:
        try:
            resp = requests.get(f"{base_url}{tool_path}",
                              timeout=10, verify=False,
                              allow_redirects=False)
            if resp.status_code in [200, 301, 302]:
                discovered.append({
                    "path": tool_path,
                    "status": resp.status_code,
                    "title": extract_title(resp.text)
                })
                print(f"[+] Data management tool: {tool_path}")
        except requests.RequestException:
            continue

    return discovered

def extract_title(html):
    """Extract title from HTML response."""
    import re
    match = re.search(r'<title>(.*?)</title>', html, re.IGNORECASE | re.DOTALL)
    return match.group(1).strip() if match else "N/A"

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python fingerprint.py <base_url>")
        sys.exit(1)

    base_url = sys.argv[1]
    print(f"[*] Fingerprinting research services at {base_url}")

    services = fingerprint_research_services(base_url)
    data_tools = detect_data_management_tools(base_url)

    results = {"services": services, "data_tools": data_tools}
    with open("fingerprint_results.json", "w") as f:
        json.dump(results, f, indent=2)

    print(f"\n[+] Results saved to fingerprint_results.json")
```

### Phase 2: Vulnerability Assessment (Days 4-7)

```
Vulnerability Assessment Targets
=================================

 Research-Specific Attack Surface
 +-------------------------------+
 |                               |
 |  [1] Data Repository Access   |  Unauthenticated data exposure
 |  [2] HPC Job Injection        |  Malicious job submission
 |  [3] Collaboration Tool Misconf|  Over-sharing permissions
 |  [4] VPN/Credential Stuffing  |  Academic password reuse
 |  [5] Shibboleth/SSO Bypass    |  Federation misconfig
 |  [6] LMS Privilege Escalation |  Student-to-admin
 |  [7] Git/Code Repository Leak |  Hardcoded secrets
 |  [8] Cloud Storage Exposure   |  Public S3/GCS buckets
 |  [9] API Endpoint Discovery   |  Undocumented REST APIs
 | [10] Print/Lab Device Access   |  Networked printer abuse
 |                               |
 +-------------------------------+
```

#### Step 2.1: Research Data Repository Testing

```python
#!/usr/bin/env python3
"""Research Data Repository Security Testing"""

import requests
import json

class ResearchDataTest:
    """Test security of research data repositories."""

    COMMON_DATA_PATHS = [
        # General data repositories
        "/data/", "/datasets/", "/repository/", "/archive/",
        "/files/", "/uploads/", "/attachments/",

        # Research-specific
        "/redcap/", "/REDCap/",
        "/dataverse/", "/Dataverse/",
        "/dspace/", "/DSpace/",
        "/fedora/", "/FedoraRepository/",
        "/eprints/", "/EPrints/",

        # Git/Code
        "/gitlab/", "/gitea/", "/gogs/", "/bitbucket/",
        "/github/", "/repos/",

        # Cloud storage
        "/s3/", "/bucket/", "/storage/",
        "/azure/", "/blob/",
        "/gcs/", "/google/",

        # Backup/Export
        "/backup/", "/backups/", "/export/", "/exports/",
        "/dump/", "/dumps/", "/snapshot/",
        "/db/", "/database/", "/sql/",

        # API endpoints
        "/api/", "/api/v1/", "/api/v2/", "/api/v3/",
        "/rest/", "/graphql/", "/swagger/", "/openapi/",

        # Admin/Debug
        "/admin/", "/debug/", "/status/", "/info/",
        "/metrics/", "/health/", "/actuator/",
        "/phpinfo.php", "/server-status",
    ]

    SENSITIVE_FILE_PATTERNS = [
        ".git/", ".env", ".env.local", ".env.production",
        "config.json", "config.yaml", "config.yml",
        "database.yml", "database.json",
        "credentials.json", "secrets.json",
        "backup.sql", "dump.sql",
        ".htpasswd", ".htaccess",
        "wp-config.php", "settings.php",
        "application.properties", "application.yml",
    ]

    def __init__(self, base_url):
        self.base_url = base_url.rstrip("/")
        self.findings = []

    def test_directory_listing(self):
        """Test for directory listing on data paths."""
        print("[*] Testing for directory listing...")
        for path in self.COMMON_DATA_PATHS:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False)
                if resp.status_code == 200:
                    # Check for directory listing indicators
                    listing_indicators = [
                        "Index of", "Directory listing",
                        "<pre>", "Parent Directory",
                        "Last modified", "Size"
                    ]
                    for indicator in listing_indicators:
                        if indicator.lower() in resp.text.lower():
                            self.findings.append({
                                "type": "DIRECTORY_LISTING",
                                "path": path,
                                "severity": "HIGH",
                                "description": f"Directory listing enabled at {path}"
                            })
                            print(f"  [!] Directory listing: {path}")
                            break
            except requests.RequestException:
                continue

    def test_unauthenticated_access(self):
        """Test for unauthenticated access to data."""
        print("[*] Testing for unauthenticated data access...")
        sensitive_patterns = [
            ".csv", ".tsv", ".xlsx", ".xls",
            ".json", ".xml", ".parquet",
            ".fasta", ".fastq", ".bam", ".vcf",
            ".dta", ".sav", ".spss",
        ]

        for path in self.COMMON_DATA_PATHS:
            for ext in sensitive_patterns:
                try:
                    # Test with common file naming patterns
                    test_urls = [
                        f"{self.base_url}{path}data{ext}",
                        f"{self.base_url}{path}export{ext}",
                        f"{self.base_url}{path}backup{ext}",
                        f"{self.base_url}{path}dump{ext}",
                    ]
                    for url in test_urls:
                        resp = requests.get(url, timeout=5, verify=False)
                        if resp.status_code == 200 and len(resp.content) > 100:
                            self.findings.append({
                                "type": "UNAUTHENTICATED_DATA_ACCESS",
                                "url": url,
                                "severity": "CRITICAL",
                                "description": f"Accessible data file: {url}"
                            })
                            print(f"  [!] Accessible data: {url}")
                except requests.RequestException:
                    continue

    def test_git_exposure(self):
        """Test for exposed Git repositories."""
        print("[*] Testing for exposed Git repositories...")
        git_paths = [
            "/.git/", "/.git/config", "/.git/HEAD",
            "/.gitignore", "/.gitmodules",
        ]

        for path in git_paths:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False)
                if resp.status_code == 200:
                    if "[core]" in resp.text or "ref:" in resp.text:
                        self.findings.append({
                            "type": "GIT_EXPOSURE",
                            "path": path,
                            "severity": "CRITICAL",
                            "description": f"Exposed Git repository: {path}"
                        })
                        print(f"  [!] Git exposure: {path}")
            except requests.RequestException:
                continue

    def test_api_enumeration(self):
        """Enumerate and test API endpoints."""
        print("[*] Enumerating API endpoints...")
        api_paths = [
            "/api/", "/api/v1/", "/api/v2/",
            "/rest/", "/graphql",
            "/swagger.json", "/openapi.json",
            "/api-docs/", "/swagger-ui/",
        ]

        for path in api_paths:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False)
                if resp.status_code == 200:
                    # Check for API documentation
                    api_indicators = [
                        "swagger", "openapi", "paths",
                        "endpoints", "routes", "operations"
                    ]
                    for indicator in api_indicators:
                        if indicator.lower() in resp.text.lower():
                            self.findings.append({
                                "type": "API_DOCUMENTATION_EXPOSED",
                                "path": path,
                                "severity": "MEDIUM",
                                "description": f"API documentation at {path}"
                            })
                            print(f"  [!] API docs: {path}")
                            break
            except requests.RequestException:
                continue

    def generate_report(self):
        """Generate assessment report."""
        report = {
            "target": self.base_url,
            "findings_count": len(self.findings),
            "critical": sum(1 for f in self.findings if f["severity"] == "CRITICAL"),
            "high": sum(1 for f in self.findings if f["severity"] == "HIGH"),
            "medium": sum(1 for f in self.findings if f["severity"] == "MEDIUM"),
            "findings": self.findings
        }
        return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python data_test.py <base_url>")
        sys.exit(1)

    tester = ResearchDataTest(sys.argv[1])
    tester.test_directory_listing()
    tester.test_unauthenticated_access()
    tester.test_git_exposure()
    tester.test_api_enumeration()

    report = tester.generate_report()
    print(f"\n[*] Assessment Complete")
    print(f"    Total findings: {report['findings_count']}")
    print(f"    Critical: {report['critical']}")
    print(f"    High: {report['high']}")
    print(f"    Medium: {report['medium']}")

    with open("data_repo_report.json", "w") as f:
        json.dump(report, f, indent=2)
```

#### Step 2.2: HPC and Compute Security Testing

```python
#!/usr/bin/env python3
"""HPC and Compute Infrastructure Security Testing"""

class HPCTestSuite:
    """Security testing suite for HPC environments."""

    SLURM_ENDPOINTS = [
        "/slurm/", "/slurmdbd/", "/slurmctld/",
        "/srun/", "/sbatch/", "/squeue/",
    ]

    PBS_ENDPOINTS = [
        "/pbs/", "/pbs_server/", "/pbs_mom/",
        "/qsub/", "/qstat/", "/qdel/",
    ]

    COMMON_VULNS = {
        "unauthenticated_job_submission": [
            "Job submission without authentication",
            "Resource allocation without quota enforcement",
            "Module load without access control",
        ],
        "shared_filesystem_abuse": [
            "World-writable /scratch directories",
            "Stale NFS exports",
            "Group-writable home directories",
        ],
        "container_escape": [
            "Singularity/Apptainer SUID bit",
            "Docker socket exposure",
            "Shifter misconfiguration",
        ],
        "network_exposure": [
            "Infiniband management interface exposed",
            "Compute nodes routable from campus",
            "Interactive node SSH from internet",
        ],
    }

    def test_scheduler_access(self, target):
        """Test HPC scheduler access controls."""
        findings = []

        # Test Slurm endpoints
        for endpoint in self.SLURM_ENDPOINTS:
            try:
                import requests
                resp = requests.get(f"{target}{endpoint}",
                                  timeout=10, verify=False)
                if resp.status_code == 200:
                    findings.append({
                        "component": "Slurm",
                        "endpoint": endpoint,
                        "status": "accessible",
                        "risk": "MEDIUM"
                    })
            except Exception:
                continue

        return findings

    def test_module_system(self, target):
        """Test environment module system security."""
        # Check for module file exposure
        module_paths = [
            "/etc/modulefiles/", "/usr/share/Modules/modulefiles/",
            "/opt/apps/", "/share/apps/",
        ]

        findings = []
        for path in module_paths:
            try:
                import requests
                resp = requests.get(f"{target}{path}",
                                  timeout=10, verify=False)
                if resp.status_code == 200:
                    findings.append({
                        "component": "ModuleSystem",
                        "path": path,
                        "status": "exposed",
                        "risk": "LOW"
                    })
            except Exception:
                continue

        return findings

    def test_storage_security(self, target):
        """Test shared storage security."""
        storage_paths = [
            "/scratch/", "/project/", "/home/",
            "/opt/", "/shared/", "/data/",
        ]

        findings = []
        for path in storage_paths:
            try:
                import requests
                resp = requests.get(f"{target}{path}",
                                  timeout=10, verify=False)
                if resp.status_code == 200:
                    # Check for directory listing
                    if "Index of" in resp.text or "<pre>" in resp.text:
                        findings.append({
                            "component": "Storage",
                            "path": path,
                            "issue": "directory_listing",
                            "risk": "HIGH"
                        })
            except Exception:
                continue

        return findings

    def generate_report(self, findings):
        """Generate HPC security report."""
        report = {
            "total_findings": len(findings),
            "by_component": {},
            "findings": findings
        }

        for finding in findings:
            component = finding.get("component", "Unknown")
            if component not in report["by_component"]:
                report["by_component"][component] = 0
            report["by_component"][component] += 1

        return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python hpc_test.py <target_url>")
        sys.exit(1)

    tester = HPCTestSuite()
    target = sys.argv[1]

    all_findings = []
    all_findings.extend(tester.test_scheduler_access(target))
    all_findings.extend(tester.test_module_system(target))
    all_findings.extend(tester.test_storage_security(target))

    report = tester.generate_report(all_findings)
    print(f"\n[*] HPC Assessment Complete")
    print(f"    Findings: {report['total_findings']}")
    for comp, count in report["by_component"].items():
        print(f"    {comp}: {count}")

    import json
    with open("hpc_report.json", "w") as f:
        json.dump(report, f, indent=2)
```

### Phase 3: Exploitation and Post-Exploitation (Days 8-10)

```
Post-Exploitation Pathways in Research Environment
===================================================

 Initial Access
      |
      v
 +----+----+     +----------------+     +----------------+
 | Web App  |     | VPN/Citrix     |     | Social Eng.    |
 | Compromise|    | Credential     |     | (Faculty/      |
 |          |     | Reuse          |     |  Student)      |
 +----+-----+     +-------+--------+     +-------+--------+
      |                    |                      |
      v                    v                      v
 +----+----+     +---------+--------+    +--------+--------+
 | Research |     | Lateral Movement |    | Credential      |
 | Data     |     | (Kerberoasting,  |    | Harvesting      |
 | Exfil    |     |  Pass-the-Hash)  |    | (Phishing)      |
 +----+-----+     +---------+--------+    +--------+--------+
      |                    |                      |
      v                    v                      v
 +----+----+     +---------+--------+    +--------+--------+
 | IP Theft |     | Domain Admin     |    | persistent      |
 | (Patent  |     | Compromise       |    | Access          |
 |  data)   |     |                  |    | (Backdoors)     |
 +----------+     +------------------+    +-----------------+
```

#### Step 3.1: Data Exfiltration Simulation

```python
#!/usr/bin/env python3
"""Research Data Exfiltration Simulation (Authorized Testing Only)"""

import hashlib
import json
from datetime import datetime

class ExfiltrationSimulator:
    """Simulate data exfiltration paths for authorized testing."""

    DATA_CLASSIFICATIONS = {
        "CUI": {
            "label": "Controlled Unclassified Information",
            "handling": "Must be encrypted at rest and in transit",
            "retention": "Per grant requirements"
        },
        "PHI": {
            "label": "Protected Health Information",
            "handling": "HIPAA minimum necessary standard",
            "retention": "6 years minimum"
        },
        "FERPA": {
            "label": "Student Education Records",
            "handling": "Directory information opt-out",
            "retention": "Per institutional policy"
        },
        "ITAR": {
            "label": "Defense Technical Data",
            "handling": "US persons only, no foreign access",
            "retention": "Per export control requirements"
        }
    }

    EXFIL_PATHWAYS = [
        "DNS tunneling via academic research domain",
        "Cloud storage upload (personal account)",
        "Email attachment to external address",
        "USB device connection",
        "Steganography in research images",
        "Encrypted channel via HTTPS to external host",
        "SSH tunnel to personal server",
        "Git push to personal repository",
        "API call to external service",
        "Print to off-campus printer",
    ]

    def __init__(self):
        self.test_results = []

    def simulate_exfil_pathway(self, pathway, target_data):
        """Simulate an exfiltration pathway."""
        result = {
            "pathway": pathway,
            "timestamp": datetime.now().isoformat(),
            "data_hash": hashlib.sha256(target_data.encode()).hexdigest(),
            "status": "simulated",
            "detection_expected": self._estimate_detection(pathway),
            "mitigation": self._suggest_mitigation(pathway)
        }
        self.test_results.append(result)
        return result

    def _estimate_detection(self, pathway):
        """Estimate likelihood of detection for a pathway."""
        detection_map = {
            "DNS tunneling": "MEDIUM - DNS monitoring may catch anomalies",
            "Cloud storage": "LOW - Personal accounts not monitored",
            "Email attachment": "MEDIUM - DLP may flag external sends",
            "USB device": "HIGH - Endpoint protection may block",
            "Steganography": "LOW - Difficult to detect",
            "HTTPS channel": "LOW - Encrypted traffic inspection limited",
            "SSH tunnel": "MEDIUM - Network monitoring may detect",
            "Git push": "LOW - Developer activity common",
            "API call": "MEDIUM - API gateway logging",
            "Print": "LOW - Print monitoring rarely implemented",
        }
        for key, value in detection_map.items():
            if key.lower() in pathway.lower():
                return value
        return "UNKNOWN"

    def _suggest_mitigation(self, pathway):
        """Suggest mitigation for an exfiltration pathway."""
        mitigations = {
            "DNS tunneling": "Implement DNS monitoring and blocking of known tunneling tools",
            "Cloud storage": "CASB solution to monitor cloud uploads",
            "Email attachment": "DLP rules for sensitive data patterns",
            "USB device": "USB device control policy",
            "Steganography": "Network traffic analysis for anomalous patterns",
            "HTTPS channel": "SSL inspection where legally permitted",
            "SSH tunnel": "Network segmentation and monitoring",
            "Git push": "Repository access controls and push reviews",
            "API call": "API gateway with authentication and logging",
            "Print": "Secure printing with badge release",
        }
        for key, value in mitigations.items():
            if key.lower() in pathway.lower():
                return value
        return "Implement defense-in-depth controls"

    def generate_report(self):
        """Generate exfiltration simulation report."""
        report = {
            "total_pathways_tested": len(self.test_results),
            "results": self.test_results,
            "recommendations": [
                "Implement Data Loss Prevention (DLP) solution",
                "Deploy Cloud Access Security Broker (CASB)",
                "Enable network traffic analysis for anomaly detection",
                "Implement USB device control policies",
                "Enable SSL inspection where legally permitted",
                "Deploy endpoint detection and response (EDR)",
                "Implement security awareness training for researchers",
                "Establish data classification and handling procedures"
            ]
        }
        return report

if __name__ == "__main__":
    simulator = ExfiltrationSimulator()

    for pathway in ExfiltrationSimulator.EXFIL_PATHWAYS:
        simulator.simulate_exfil_pathway(pathway, "test_research_data")

    report = simulator.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 4: Analysis and Reporting (Days 11-14)

```
Reporting Framework
====================

 Findings Classification
 +----------------------+
 | CRITICAL             |  Active data breach, ransomware, APT persistence
 | HIGH                 |  Unauthenticated access to sensitive data
 | MEDIUM               |  Weak authentication, missing encryption
 | LOW                  |  Information disclosure, minor misconfiguration
 | INFO                 |  Best practice recommendations
 +----------------------+

 Report Structure
 +----------------------+
 | Executive Summary    |
 | Methodology          |
 | Findings             |
 |   - Critical         |
 |   - High             |
 |   - Medium           |
 |   - Low              |
 | Risk Assessment      |
 | Recommendations      |
 | Appendices           |
 |   - Tool Output      |
 |   - Evidence         |
 |   - Scope Document   |
 +----------------------+
```

---

## 5. Tool Arsenal

### Network Analysis

```bash
# Network discovery and enumeration
nmap -sV -sC -O --top-ports 1000 -oA nmap_full <target>
masscan -p0-65535 --rate=1000 -oJ masscan.json <target_range>

# Academic-specific port scanning (eduroam, Shibboleth)
nmap -p 80,443,8080,8443,389,636,88,464 <target> -sV

# Wireless network discovery
airodump-ng wlan0mon --write research_wifi
```

### Web Application Testing

```bash
# Nuclei with research-specific templates
nuclei -u <target> -t nuclei-templates/ -severity critical,high

# Directory fuzzing for research paths
ffuf -u <target>/FUZZ -w research_wordlist.txt -mc 200,301,302,403

# API endpoint discovery
ffuf -u <target>/api/FUZZ -w api_endpoints.txt -mc 200

# Subdomain takeover check
subjack -w subdomains.txt -t 100 -timeout 30 -o results.txt
```

### Credential Testing

```bash
# Hydra for SSH/VPN brute force (with authorization)
hydra -l user@domain -P passwords.txt ssh://target
hydra -l user -P passwords.txt vpn://target

# Kerberoasting (Active Directory)
GetUserSPNs.py domain/user:password -dc dc.domain.local -request

# Password spraying
crackmapexec smb target -u users.txt -p 'Password123!' --continue-on-success
```

### Cloud Security

```bash
# AWS S3 bucket enumeration
aws s3 ls s3://target-bucket --recursive
Prowler aws --bucket-name target-bucket

# Azure blob storage
az storage blob list --account-name target --container-name data

# GCS bucket access
gsutil ls gs://target-bucket/
```

### Data Discovery

```bash
# Sensitive data patterns in code
grep -rn "password\|secret\|api_key\|token" --include="*.py" .
grep -rn "BEGIN RSA PRIVATE KEY\|BEGIN CERTIFICATE" .

# Database file discovery
find . -name "*.db" -o -name "*.sqlite" -o -name "*.sql"

# Research data files
find . -name "*.fasta" -o -name "*.fastq" -o -name "*.bam" -o -name "*.vcf"
find . -name "*.csv" -o -name "*.dta" -o -name "*.sav" -o -name "*.spss"
```

---

## 6. Real-World Examples

### Example 1: University Data Breach via Exposed Git Repository

```
Scenario:
- A research group at a major university had a Git repository exposed
- The repository contained database credentials for a clinical trial database
- The database contained 50,000+ patient records (PHI)

Attack Path:
1. Subdomain enumeration revealed git.research.university.edu
2. Directory listing enabled, exposing repository contents
3. .git/config contained database connection string
4. Database accessible from campus network
5. No encryption at rest for PHI data

Impact:
- HIPAA breach notification required
- $2.5M fine from HHS Office for Civil Rights
- University lost federal research funding
- Reputational damage to research programs

Lessons Learned:
- Implement automated repository scanning
- Enforce authentication for all Git access
- Deploy DLP for PHI patterns
- Regular security assessments of research infrastructure
```

### Example 2: HPC Cryptomining via Unauthorized Job Submission

```
Scenario:
- A compromised VPN credential allowed access to HPC cluster
- Attacker submitted cryptocurrency mining jobs via Slurm
- 500 GPU-hours consumed before detection

Attack Path:
1. Credential reuse from breached academic conference site
2. VPN access to campus network
3. Slurm REST API exposed without authentication
4. Mining jobs submitted as normal research workloads
5. Resource consumption went unnoticed for 2 weeks

Impact:
- $50,000 in compute costs
- Disruption to legitimate research jobs
- GPU allocation delays for other researchers

Lessons Learned:
- Implement MFA for VPN access
- Require job submission authentication
- Deploy resource usage monitoring and alerting
- Implement job quota enforcement
```

### Example 3: Research Data Leak via Cloud Storage Misconfiguration

```
Scenario:
- A research team used a cloud storage bucket for dataset sharing
- Bucket was configured as public for "easy collaboration"
- Contains genomic data from 10,000 research subjects

Attack Path:
1. Cloud asset enumeration via S3 bucket naming conventions
2. Public bucket discovered containing research datasets
3. Data included genomic sequences with linked PII
4. Data downloaded without authentication

Impact:
- GDPR violation (EU research subjects)
- IRB protocol suspension
- Research team lost grant funding
- Data breach notification to 10,000 subjects

Lessons Learned:
- Implement cloud security posture management
- Enforce bucket policies via AWS Organizations
- Deploy cloud access security broker
- Regular cloud configuration audits
```

---

## 7. Bypass Techniques

### 7.1 Research-Specific Authentication Bypass

```
Authentication Bypass Vectors in Research Environments
=====================================================

 [1] Shibboleth Federation Bypass
     - Exploit trust relationship between institutions
     - Forge SAML assertion with manipulated attributes
     - Target: Cross-institutional resource access

 [2] Academic VPN Split-Tunneling
     - Leverage split-tunnel VPN configurations
     - Access internal resources while appearing external
     - Target: Off-campus access to restricted systems

 [3] Research Collaboration Trust
     - Exploit trust between research groups
     - Leverage shared credentials for multi-PI projects
     - Target: Cross-departmental data access

 [4] Emergency Access Procedures
     - Exploit break-glass procedures
     - Social engineering with urgency pretext
     - Target: Bypass normal access controls

 [5] Legacy System Authentication
     - Target systems with older authentication protocols
     - Exploit backward compatibility requirements
     - Target: HPC schedulers, legacy databases
```

### 7.2 Network Segmentation Bypass

```python
#!/usr/bin/env python3
"""Network Segmentation Bypass Testing for Research Networks"""

class SegmentationBypassTest:
    """Test network segmentation in research environments."""

    RESEARCH_SEGMENTS = {
        "campus_lan": "10.0.0.0/8",
        "research_vlan": "172.16.0.0/12",
        "hpc_network": "192.168.0.0/16",
        "dmz": "203.0.113.0/24",
        "vpn_pool": "10.100.0.0/16",
        "iot_devices": "10.200.0.0/16",
    }

    TEST_VECTORS = [
        "VLAN hopping via double tagging",
        "IP spoofing to trusted segment",
        "ARP poisoning for MITM",
        "DNS rebinding to bypass ACLs",
        "IPv6 tunneling through IPv4 filters",
        "Service discovery via mDNS/Bonjour",
        "NFS/SMB share enumeration across segments",
        "SSH tunneling through permitted hosts",
    ]

    def test_vlan_hopping(self, target_vlan):
        """Test VLAN hopping via double tagging."""
        findings = []

        # Simulate 802.1Q double tagging
        # This is a conceptual test - actual implementation requires scapy
        findings.append({
            "test": "VLAN Hopping",
            "vector": "Double 802.1Q tagging",
            "status": "conceptual",
            "description": "Test if switch allows double-tagged frames",
            "mitigation": "Disable DTP, explicitly configure trunk ports"
        })

        return findings

    def test_dns_rebinding(self, target_host):
        """Test DNS rebinding to bypass network ACLs."""
        findings = []

        # DNS rebinding concept
        findings.append({
            "test": "DNS Rebinding",
            "vector": "Short TTL DNS records",
            "status": "conceptual",
            "description": "Test if DNS responses can rebind to internal IPs",
            "mitigation": "Implement DNS filtering, validate DNS responses"
        })

        return findings

    def test_ipv6_tunneling(self):
        """Test IPv6 tunneling to bypass IPv4 filters."""
        findings = []

        findings.append({
            "test": "IPv6 Tunneling",
            "vector": "6to4/Teredo tunnels",
            "status": "conceptual",
            "description": "Test if IPv6 tunnels bypass IPv4 ACLs",
            "mitigation": "Disable IPv6 if not needed, filter IPv6 traffic"
        })

        return findings

    def test_service_discovery(self):
        """Test cross-segment service discovery."""
        findings = []

        # mDNS/Bonjour discovery
        findings.append({
            "test": "mDNS Discovery",
            "vector": "Multicast DNS",
            "status": "conceptual",
            "description": "Test if mDNS reveals services across segments",
            "mitigation": "Filter mDNS at network boundary"
        })

        # NFS/SMB enumeration
        findings.append({
            "test": "NFS/SMB Enumeration",
            "vector": "RPC portmapper",
            "status": "conceptual",
            "description": "Test if NFS/SMB shares visible across segments",
            "mitigation": "Restrict NFS/SMB to specific VLANs"
        })

        return findings

    def generate_report(self, all_findings):
        """Generate segmentation bypass report."""
        report = {
            "total_tests": len(all_findings),
            "findings": all_findings,
            "recommendations": [
                "Implement micro-segmentation for research networks",
                "Deploy network access control (NAC) 802.1X",
                "Enable private VLANs for sensitive research",
                "Implement east-west firewall rules",
                "Deploy network detection and response (NDR)",
                "Regular segmentation testing and validation"
            ]
        }
        return report

if __name__ == "__main__":
    tester = SegmentationBypassTest()

    all_findings = []
    all_findings.extend(tester.test_vlan_hopping("research_vlan"))
    all_findings.extend(tester.test_dns_rebinding("research.university.edu"))
    all_findings.extend(tester.test_ipv6_tunneling())
    all_findings.extend(tester.test_service_discovery())

    report = tester.generate_report(all_findings)
    print(json.dumps(report, indent=2))
```

---

## 8. Common Pitfalls

### 8.1 Testing Pitfalls

```
Common Mistakes in Research Institution Testing
================================================

 [1] DISRUPTING ACTIVE RESEARCH
     - Risk: Taking down HPC during job execution
     - Mitigation: Coordinate with research computing staff
     - Timing: Avoid grant deadlines, thesis defenses

 [2] EXPOSING PHI/PII INCONSISTENTLY
     - Risk: Finding patient data without proper handling
     - Mitigation: Document exposure without exfiltrating data
     - Compliance: Follow HIPAA minimum necessary standard

 [3] IGNORING FERPA CONSTRAINTS
     - Risk: Accessing student records during testing
     - Mitigation: Define clear scope excluding student PII
     - Legal: FERPA violations carry federal penalties

 [4] OVERLOOKING SHARED INFRASTRUCTURE
     - Risk: Testing affects multiple research groups
     - Mitigation: Understand shared resource dependencies
     - Impact: One test could disrupt dozens of projects

 [5] MISUNDERSTANDING OPEN ACCESS
     - Risk: Assuming "open" means "insecure"
     - Mitigation: Distinguish between intentional sharing and exposure
     - Context: Some data is meant to be public

 [6] IGNORING EXPORT CONTROLS
     - Risk: Testing ITAR-controlled research systems
     - Mitigation: Verify export control status before testing
     - Legal: ITAR violations carry criminal penalties

 [7] FORGETTING IRB REQUIREMENTS
     - Risk: Testing involves human subjects data
     - Mitigation: Check if IRB notification is required
     - Compliance: IRB approval may be needed for security research
```

### 8.2 Technical Pitfalls

```python
#!/usr/bin/env python3
"""Common Technical Pitfalls in Research Institution Testing"""

PITFALLS = {
    "network": [
        {
            "pitfall": "Testing during peak research hours",
            "impact": "HPC job failures, data corruption",
            "avoidance": "Test during off-hours (2-6 AM local time)"
        },
        {
            "pitfall": "Scanning research databases",
            "impact": "Query load on sensitive systems",
            "avoidance": "Coordinate with database administrators"
        },
        {
            "pitfall": "Ignoring multicast traffic",
            "impact": "Missing service discovery protocols",
            "avoidance": "Capture and analyze mDNS/Bonjour traffic"
        },
    ],
    "web": [
        {
            "pitfall": "Brute-forcing academic SSO",
            "impact": "Account lockouts for researchers",
            "avoidance": "Use slow, targeted attempts with valid usernames"
        },
        {
            "pitfall": "Missing Shibboleth attributes",
            "impact": "Incomplete access control assessment",
            "avoidance": "Test all SAML attribute manipulation vectors"
        },
        {
            "pitfall": "Ignoring research-specific LMS features",
            "impact": "Missing privilege escalation paths",
            "avoidance": "Test role-based access in Canvas/Moodle/Blackboard"
        },
    ],
    "cloud": [
        {
            "pitfall": "Assuming cloud = secure",
            "impact": "Missing misconfigurations",
            "avoidance": "Test cloud configurations independently"
        },
        {
            "pitfall": "Ignoring multi-cloud deployments",
            "impact": "Incomplete cloud security posture",
            "avoidance": "Enumerate all cloud providers (AWS, Azure, GCP)"
        },
        {
            "pitfall": "Missing serverless attack surface",
            "impact": "Overlooking Lambda/Azure Functions",
            "avoidance": "Enumerate and test serverless components"
        },
    ],
    "compliance": [
        {
            "pitfall": "Not understanding FERPA scope",
            "impact": "Accidental student data exposure",
            "avoidance": "Define clear data handling procedures"
        },
        {
            "pitfall": "Ignoring HIPAA minimum necessary",
            "impact": "Over-accessing PHI during testing",
            "avoidance": "Limit PHI access to what's required for testing"
        },
        {
            "pitfall": "Missing export control requirements",
            "impact": "ITAR/EAR violations",
            "avoidance": "Verify export control status of all systems"
        },
    ]
}

def print_pitfalls():
    """Print all common pitfalls."""
    for category, items in PITFALLS.items():
        print(f"\n{'='*60}")
        print(f" {category.upper()} PITFALLS")
        print(f"{'='*60}")
        for item in items:
            print(f"\n  Pitfall: {item['pitfall']}")
            print(f"  Impact:  {item['impact']}")
            print(f"  Avoid:   {item['avoidance']}")

if __name__ == "__main__":
    print_pitfalls()
```

---

## 9. Reporting Template

```
RESEARCH INSTITUTION SECURITY ASSESSMENT REPORT
================================================

Document Information:
- Client: [University/Research Institution Name]
- Assessment Period: [Start Date] - [End Date]
- Assessor: [Your Name/Organization]
- Classification: CONFIDENTIAL
- Version: 1.0

---

EXECUTIVE SUMMARY

[2-3 paragraph summary of key findings, overall risk posture,
and critical recommendations. Written for non-technical leadership.]

KEY METRICS:
- Total Findings: [N]
- Critical: [N]
- High: [N]
- Medium: [N]
- Low: [N]
- Informational: [N]

OVERALL RISK RATING: [CRITICAL / HIGH / MEDIUM / LOW]

---

SCOPE AND METHODOLOGY

Scope:
- In-scope assets: [List of systems, networks, applications]
- Out-of-scope: [Exclusions]
- Testing type: [Blackbox / Greybox / Whitebox]
- Authorization: [RoE reference number]

Methodology:
- Reconnaissance: [Description]
- Vulnerability Assessment: [Description]
- Exploitation: [Description]
- Post-Exploitation: [Description]
- Analysis: [Description]

Standards Referenced:
- OWASP Testing Guide v4.2
- NIST SP 800-115
- PTES (Penetration Testing Execution Standard)
- SANS Institute Guidelines

---

FINDINGS

[For each finding, provide:]

FINDING #[N]: [Title]
Severity: [CRITICAL / HIGH / MEDIUM / LOW]
CVSS Score: [X.X]
Category: [Category]
Affected System(s): [System details]

Description:
[Detailed description of the vulnerability]

Evidence:
[Screenshots, request/response pairs, tool output]

Impact:
[Business impact analysis]

Affected Populations:
[Students, Faculty, Research Staff, Patients, etc.]

Recommendation:
[Specific remediation steps]

References:
- CVE-XXXX-XXXXX
- [Relevant standards]

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

RECOMMENDATIONS

Priority 1 (Immediate - 30 days):
- [Critical findings remediation]

Priority 2 (Short-term - 90 days):
- [High findings remediation]

Priority 3 (Medium-term - 6 months):
- [Medium findings remediation]

Priority 4 (Long-term - 12 months):
- [Strategic improvements]

---

COMPLIANCE MAPPING

+------------------+--------+--------+--------+--------+
| Finding          | FERPA  | HIPAA  | CUI    | GDPR   |
+------------------+--------+--------+--------+--------+
| [Finding 1]      |   X    |        |   X    |        |
| [Finding 2]      |        |   X    |        |   X    |
+------------------+--------+--------+--------+--------+

---

APPENDICES

A. Tool Output and Raw Data
B. Network Diagrams
C. Scope Document and Authorization
D. Glossary of Terms
E. Assessor Qualifications

---

DOCUMENT APPROVAL

Prepared by: _________________ Date: _________
Reviewed by: _________________ Date: _________
Approved by: _________________ Date: _________
```

---

## 10. Quick Reference

### Research Institution Testing Checklist

```
PRE-ENGAGEMENT
[ ] Rules of Engagement signed
[ ] Scope document approved
[ ] Emergency contacts established
[ ] Testing window coordinated with IT
[ ] Data handling agreement executed
[ ] Export control verification (ITAR/EAR)
[ ] IRB notification (if applicable)

RECONNAISSANCE
[ ] Subdomain enumeration complete
[ ] Cloud asset discovery complete
[ ] Service fingerprinting complete
[ ] Research platform identification
[ ] Collaboration tool discovery
[ ] Identity federation mapping

VULNERABILITY ASSESSMENT
[ ] Data repository testing
[ ] HPC security assessment
[ ] LMS privilege testing
[ ] SSO/Shibboleth testing
[ ] VPN credential testing
[ ] Cloud configuration review
[ ] API endpoint enumeration

EXPLOITATION
[ ] Critical vulnerability exploitation
[ ] Data exfiltration simulation
[ ] Lateral movement testing
[ ] Privilege escalation testing
[ ] Persistence mechanism testing

POST-EXPLOITATION
[ ] Impact assessment
[ ] Data exposure documentation
[ ] Compliance impact analysis
[ ] Remediation recommendations

REPORTING
[ ] Executive summary
[ ] Detailed findings
[ ] Risk assessment
[ ] Remediation roadmap
[ ] Compliance mapping
```

### Common Research Institution Ports and Services

```
Port    Service                 Research Context
22      SSH                     HPC login nodes, research servers
80      HTTP                    Web applications, LMS
443     HTTPS                   Secure web applications
389     LDAP                    Directory services
636     LDAPS                   Secure directory services
88      Kerberos                Authentication
464     Kerberos changepwd      Password changes
8443    HTTPS Alt               Research applications
5000    Flask/Django            Python research apps
8000    Development             Development servers
8080    Proxy/Alt HTTP          Application servers
8888    JupyterHub              Notebook servers
27017   MongoDB                 Research databases
5432    PostgreSQL              Research databases
3306    MySQL                   Research databases
1433    MSSQL                   Windows research databases
6379    Redis                   Caching
9200    Elasticsearch           Research data indexing
9090    Prometheus              Monitoring
3000    Grafana                 Dashboards
5601    Kibana                  Log analysis
```

### Emergency Response Contacts

```
Role                      Contact                 Phone
------------------------- ----------------------- ----------
CISO                      [Name]                  [Number]
IT Security Director      [Name]                  [Number]
Legal Counsel             [Name]                  [Number]
IRB Chair                 [Name]                  [Number]
Research Computing Dir.   [Name]                  [Number]
Communications Dir.       [Name]                  [Number]
External Incident Resp.   [Firm Name]             [Number]
Cyber Insurance           [Carrier]               [Policy#]
FBI Cyber Division        Local Field Office      [Number]
```

---

## References

- NIST SP 800-171: Protecting Controlled Unclassified Information
- NIST SP 800-115: Technical Guide to Information Security Testing
- EDUCAUSE Security Program Resources
- Internet2 Security Recommendations
- CENIC Network Security Guidelines
- NIH Data Management and Sharing Policy
- FERPA Compliance Resources (ed.gov)
- HIPAA Security Rule (hhs.gov)
- ITAR Compliance Guide (state.gov)
