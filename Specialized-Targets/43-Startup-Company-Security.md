# Specialized-Targets 43: Startup Company Security

## 1. Expert Role

You are an elite Specialized Security Tester specializing in Startup Company environments. Your expertise spans cloud-native architectures, rapid development cycles, API-first design, MVP security, and the unique security challenges faced by early-stage and growth-stage technology startups.

### Domain Profile

Startups operate under extreme pressure to ship fast, iterate quickly, and secure funding. Security is often deprioritized in favor of product-market fit. They typically run cloud-native stacks, use managed services extensively, and have small (or nonexistent) security teams.

### Threat Model

```
Startup Threat Landscape
=========================

 External Threats                    Internal Threats
 +------------------+                +------------------+
 | Competitor       |                | Developer Error  |
 | (IP theft,       |                | (Hardcoded       |
 |  sabotage)       |                |  secrets)        |
 +------------------+                +------------------+
 | Founder/Investor |                | Rapid Code       |
 | Disputes         |                | Changes (No      |
 | (Data access)    |                |  review)         |
 +------------------+                +------------------+
 | Supply Chain     |                | Third-Party      |
 | Attack           |                | Service Risk     |
 | (npm/PyPI)       |                | (SaaS sprawl)    |
 +------------------+                +------------------+
 | Ransomware       |                | Departing        |
 | (High-value for  |                | Employees        |
 |  low defense)    |                | (Access removal) |
 +------------------+                +------------------+
 | Cloud Account    |                | Shadow IT        |
 | Takeover         |                | (Uncontrolled)   |
 +------------------+                +------------------+
```

### Startup Stage Security Profile

```
Stage          Security Maturity     Typical Stack          Budget
-----------    -------------------   ---------------------  --------
Pre-Seed       Minimal               SaaS + personal        $0-500/mo
Seed           Ad hoc                Basic cloud + SaaS     $500-2K/mo
Series A       Forming               Managed services       $2K-10K/mo
Series B       Defined               Hybrid cloud           $10K-50K/mo
Series C+      Mature                Enterprise cloud       $50K+/mo
IPO            Comprehensive         Full stack             $100K+/mo
```

### Key Risk Factors

- **Speed vs. Security Tradeoff**: Ship fast means skip security
- **Minimal Team**: One person wears many hats
- **Cloud Dependency**: All infrastructure in cloud equals single point of failure
- **API-First**: More endpoints equals more attack surface
- **Third-Party Sprawl**: Dozens of SaaS integrations
- **Funding Pressure**: Security not a revenue generator
- **Technical Debt**: Rapid iteration equals accumulated vulnerabilities
- **Founder Access**: Root access for everyone

---

## 2. Core Concepts

### 2.1 Cloud-Native Architecture Security

```
Typical Startup Cloud Stack
============================

 Frontend                    Backend
 +------------------+       +------------------+
 | React/Next.js    |       | Node.js/Python   |
 | (Vercel/Netlify) |       | (AWS Lambda/     |
 |                  |       |  ECS/Cloud Run)  |
 +--------+---------+       +--------+---------+
          |                          |
          v                          v
 +--------+---------+       +--------+---------+
 | CDN                |       | API Gateway       |
 | (CloudFront/       |       | (AWS API GW/      |
 |  Cloudflare)       |       |  Kong/APIGee)    |
 +--------+---------+       +--------+---------+
          |                          |
          v                          v
 +--------+---------+       +--------+---------+
 | DNS                |       | Database           |
 | (Route53/CF)       |       | (RDS/DynamoDB/     |
 |                    |       |  Supabase/PS)      |
 +--------------------+       +-------------------+

 Supporting Services
 +------------------+------------------+
 | Auth             | Storage          |
 | (Auth0/Clerk/    | (S3/R2/         |
 |  Supabase Auth)  |  GCS/Blob)      |
 +------------------+------------------+
 | Message Queue    | Caching          |
 | (SQS/RabbitMQ/  | (Redis/ElastiCache|
 |  Redis Streams)  |  Upstash)       |
 +------------------+------------------+
 | CI/CD            | Monitoring       |
 | (GitHub Actions/ | (Datadog/Sentry/ |
 |  GitLab CI)      |  LogRocket)     |
 +------------------+------------------+
```

### 2.2 Startup Data Classification

```
Startup Data Sensitivity Tiers
===============================

 Tier 1: CRITICAL (Existential if lost)
 +---------------------------------------------------+
 | - Source code repositories                        |
 | - Customer database (PII)                         |
 | - Payment processing credentials                  |
 | - API keys and secrets                            |
 | - Authentication credentials                      |
 | - Business logic / algorithms                     |
 | - Funding/investor data                           |
 +---------------------------------------------------+

 Tier 2: HIGH (Significant business impact)
 +---------------------------------------------------+
 | - Customer usage analytics                        |
 | - Internal communications (Slack, email)          |
 | - Employee data (HR, payroll)                     |
 | - Vendor contracts and agreements                 |
 | - Marketing strategies                            |
 | - Financial records                               |
 +---------------------------------------------------+

 Tier 3: MEDIUM (Moderate impact)
 +---------------------------------------------------+
 | - Product roadmap                                 |
 | - Design files                                    |
 | - Meeting notes                                   |
 | - Internal documentation                          |
 | - Job postings                                    |
 +---------------------------------------------------+

 Tier 4: LOW (Public information)
 +---------------------------------------------------+
 | - Marketing website content                       |
 | - Press releases                                  |
 | - Public API documentation                        |
 | - Open source contributions                       |
 +---------------------------------------------------+
```

### 2.3 Common Startup Technology Stack

| Category | Common Tools | Security Concerns |
|---|---|---|
| Frontend | React, Next.js, Vue, Vite | XSS, dependency vulns |
| Backend | Node.js, Python, Go, Ruby | Injection, auth bypass |
| Database | PostgreSQL, MongoDB, DynamoDB | Injection, exposure |
| Auth | Auth0, Clerk, Supabase Auth | Misconfiguration |
| Storage | S3, R2, GCS | Bucket exposure |
| CI/CD | GitHub Actions, GitLab CI | Secret leaks |
| Monitoring | Sentry, Datadog, LogRocket | PII in logs |
| Communication | Slack, Discord, Notion | Data leakage |
| Payment | Stripe, Paddle | PCI compliance |
| Email | SendGrid, Postmark, Resend | Credential exposure |

---

## 3. Prerequisites

### 3.1 Authorization Requirements

```
Startup Engagement Checklist
=============================

[ ] CEO/CTO authorization (often same person at early stage)
[ ] Signed Rules of Engagement
[ ] Scope definition (all cloud resources)
[ ] Cloud provider access (read-only for assessment)
[ ] API documentation and credentials
[ ] Emergency contact information
[ ] Insurance verification
[ ] Data processing agreement
[ ] Source code access (if whitebox)
[ ] Investor notification (if required)
```

### 3.2 Required Knowledge

- Cloud provider security (AWS, GCP, Azure)
- Container security (Docker, Kubernetes, ECS)
- Serverless security (Lambda, Cloud Functions)
- API security (REST, GraphQL)
- CI/CD pipeline security
- Authentication/Authorization frameworks
- Database security and encryption
- Secret management (Vault, AWS Secrets Manager)
- Supply chain security (npm, PyPI, Docker Hub)

### 3.3 Tool Prerequisites

```python
required_tools = {
    "cloud_scanning": ["Prowler", "ScoutSuite", "CloudSploit", "Steampipe"],
    "container": ["trivy", "grype", "syft", "docker-bench"],
    "secrets": ["truffleHog", "gitleaks", "git-secrets"],
    "api": ["burpsuite", "postman", "nuclei"],
    "web": ["nuclei", "ffuf", "httpx"],
    "sca": ["snyk", "npm-audit", "pip-audit", "trivy"],
    "dast": ["OWASP ZAP", "nikto"],
    "iam": ["enumerate-iam", "pacu", "cloud_enum"],
    "k8s": ["kube-hunter", "kubeaudit", "polaris"],
    "reporting": ["ghostwriter", "pwndoc", "dradis"]
}
```

---

## 4. Methodology

### Phase 1: Reconnaissance (Days 1-2)

```
Startup Reconnaissance Flow
=============================

 Public Information              Technical Discovery
 +------------------+           +------------------+
 | GitHub/GitLab    |           | DNS Enumeration  |
 | (Code, commits,  |           | Subdomain Scan   |
 |  contributors)   |           |                  |
 +------------------+           +------------------+
 | LinkedIn Profiles|           | Cloud Asset      |
 | (Team, tech      |           | Discovery        |
 |  stack)          |           |                  |
 +------------------+           +------------------+
 | Product Hunt     |           | API Endpoint     |
 | (Product info)   |           | Enumeration      |
 +------------------+           +------------------+
 | Crunchbase       |           | Technology       |
 | (Funding, stage) |           | Fingerprinting   |
 +------------------+           +------------------+
 | Job Postings     |           | Third-Party      |
 | (Tech stack      |           | Service Discovery|
 |  hints)          |           |                  |
 +------------------+           +------------------+
```

#### Step 1.1: GitHub/Code Repository Recon

```python
import requests
import json
import re

class StartupCodeRecon:
    def __init__(self, org_name):
        self.org_name = org_name
        self.findings = []

    def enumerate_github_repos(self, github_token=None):
        print(f"[*] Enumerating GitHub repos for {self.org_name}...")
        headers = {"Accept": "application/vnd.github.v3+json"}
        if github_token:
            headers["Authorization"] = f"token {github_token}"

        repos = []
        page = 1
        while True:
            url = f"https://api.github.com/orgs/{self.org_name}/repos?page={page}&per_page=100"
            try:
                resp = requests.get(url, headers=headers, timeout=30)
                if resp.status_code == 200:
                    data = resp.json()
                    if not data:
                        break
                    repos.extend(data)
                    page += 1
                else:
                    break
            except requests.RequestException:
                break

        print(f"  [+] Found {len(repos)} repositories")
        for repo in repos:
            self.findings.append({
                "type": "REPOSITORY",
                "name": repo["name"],
                "url": repo["html_url"],
                "visibility": repo.get("visibility", "unknown"),
                "language": repo.get("language"),
                "stars": repo.get("stargazers_count", 0),
                "forks": repo.get("forks_count", 0),
                "last_push": repo.get("pushed_at"),
            })
        return repos

    def scan_for_secrets(self, repos):
        print("[*] Scanning for exposed secrets...")
        secret_patterns = {
            "AWS Key": r"AKIA[0-9A-Z]{16}",
            "Stripe Key": r"sk_live_[0-9a-zA-Z]{24,}",
            "GitHub Token": r"ghp_[0-9a-zA-Z]{36}",
            "Slack Token": r"xoxb-[0-9]{11,}-[0-9a-zA-Z]{24}",
            "Private Key": r"-----BEGIN (RSA |EC )?PRIVATE KEY-----",
            "Database URL": r"(?i)(postgres|mysql|mongodb)://[^\s]+",
            "JWT Token": r"eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_.+/=]+",
        }

        for repo in repos[:10]:
            print(f"  Scanning {repo['name']}...")
            self.findings.append({
                "type": "SECRET_SCAN",
                "repository": repo["name"],
                "status": "completed",
                "note": "Use truffleHog or gitleaks for actual scanning"
            })

    def check_dependabot_alerts(self):
        print("[*] Checking for dependency vulnerabilities...")
        self.findings.append({
            "type": "DEPENDENCY_AUDIT",
            "recommendation": "Enable Dependabot alerts and security updates",
            "tools": ["snyk", "npm audit", "pip-audit", "trivy"]
        })

    def generate_report(self):
        return {
            "organization": self.org_name,
            "total_repos": len([f for f in self.findings if f["type"] == "REPOSITORY"]),
            "findings": self.findings,
            "recommendations": [
                "Enable branch protection rules",
                "Enable Dependabot alerts",
                "Implement secret scanning",
                "Review repository visibility",
                "Audit contributor access",
                "Enable 2FA for all organization members",
                "Implement CODEOWNERS files",
                "Regular access reviews"
            ]
        }

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python github_recon.py <github_org>")
        sys.exit(1)
    recon = StartupCodeRecon(sys.argv[1])
    repos = recon.enumerate_github_repos()
    recon.scan_for_secrets(repos)
    recon.check_dependabot_alerts()
    report = recon.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 2: Cloud Security Assessment (Days 3-5)

```
Cloud Security Assessment Flow
================================

 Identity and Access            Storage and Data
 +------------------+          +------------------+
 | IAM Policy       |          | S3 Bucket        |
 | Audit            |          | Enumeration      |
 +------------------+          +------------------+
 | MFA Status       |          | RDS Encryption   |
 | Check            |          | Check            |
 +------------------+          +------------------+
 | Service Account  |          | EBS Encryption   |
 | Review           |          | Check            |
 +------------------+          +------------------+

 Network and Compute            Monitoring and Logging
 +------------------+          +------------------+
 | Security Group   |          | CloudTrail       |
 | Audit            |          | Enabled          |
 +------------------+          +------------------+
 | VPC Config       |          | GuardDuty        |
 | Review           |          | Enabled          |
 +------------------+          +------------------+
 | Lambda Security  |          | Log Retention    |
 | Review           |          | Policy           |
 +------------------+          +------------------+
```

#### Step 2.1: AWS Security Assessment

```python
import json
import subprocess

class AWSSecurityAssessment:
    def __init__(self, profile="default"):
        self.profile = profile
        self.findings = []

    def run_aws_command(self, command):
        try:
            result = subprocess.run(
                ["aws"] + command.split() + ["--profile", self.profile],
                capture_output=True, text=True, timeout=30
            )
            return result.stdout, result.stderr, result.returncode
        except Exception as e:
            return None, str(e), 1

    def check_iam_security(self):
        print("[*] Checking IAM security...")
        stdout, stderr, rc = self.run_aws_command("iam get-account-summary")
        if rc == 0:
            data = json.loads(stdout)
            users = data.get("SummaryMap", {}).get("Users", 0)
            if users > 0:
                self.findings.append({
                    "check": "IAM Users Exist",
                    "status": "INFO",
                    "detail": f"{users} IAM users found"
                })

        self.findings.append({
            "check": "Root Account MFA",
            "status": "REVIEW",
            "detail": "Verify root account has MFA enabled"
        })

        self.findings.append({
            "check": "Access Key Rotation",
            "status": "REVIEW",
            "detail": "Review access key age and rotation policy"
        })

    def check_s3_security(self):
        print("[*] Checking S3 bucket security...")
        stdout, stderr, rc = self.run_aws_command("s3api list-buckets")
        if rc == 0:
            data = json.loads(stdout)
            for bucket in data.get("Buckets", []):
                name = bucket["Name"]
                stdout2, stderr2, rc2 = self.run_aws_command(
                    f"s3api get-bucket-policy --bucket {name}"
                )
                if rc2 == 0:
                    policy = json.loads(stdout2)
                    policy_str = json.dumps(policy)
                    if '"Principal": "*"' in policy_str:
                        self.findings.append({
                            "check": "S3 Public Access",
                            "bucket": name,
                            "status": "HIGH",
                            "detail": "Bucket may have public access"
                        })

                stdout3, stderr3, rc3 = self.run_aws_command(
                    f"s3api get-bucket-acl --bucket {name}"
                )
                if rc3 == 0:
                    acl = json.loads(stdout3)
                    for grant in acl.get("Grants", []):
                        uri = grant.get("Grantee", {}).get("URI", "")
                        if "AllUsers" in uri:
                            self.findings.append({
                                "check": "S3 Public ACL",
                                "bucket": name,
                                "status": "CRITICAL",
                                "detail": "Bucket has public read ACL"
                            })

    def check_security_services(self):
        print("[*] Checking security services...")
        stdout, stderr, rc = self.run_aws_command("cloudtrail describe-trails")
        if rc == 0:
            data = json.loads(stdout)
            if not data.get("trailList"):
                self.findings.append({
                    "check": "CloudTrail",
                    "status": "HIGH",
                    "detail": "No CloudTrail trails configured"
                })

        stdout, stderr, rc = self.run_aws_command("guardduty list-detectors")
        if rc == 0:
            data = json.loads(stdout)
            if not data.get("DetectorIds"):
                self.findings.append({
                    "check": "GuardDuty",
                    "status": "MEDIUM",
                    "detail": "GuardDuty not enabled"
                })

    def generate_report(self):
        return {
            "cloud_provider": "AWS",
            "total_findings": len(self.findings),
            "critical": sum(1 for f in self.findings if f.get("status") == "CRITICAL"),
            "high": sum(1 for f in self.findings if f.get("status") == "HIGH"),
            "medium": sum(1 for f in self.findings if f.get("status") == "MEDIUM"),
            "findings": self.findings,
            "recommendations": [
                "Enable MFA for all IAM users",
                "Implement least-privilege IAM policies",
                "Enable CloudTrail for all regions",
                "Enable GuardDuty for threat detection",
                "Enable AWS Config for compliance monitoring",
                "Review and restrict S3 bucket policies",
                "Enable encryption at rest for all data stores",
                "Implement VPC flow logs",
                "Regular access reviews and key rotation",
                "Enable AWS Security Hub"
            ]
        }

if __name__ == "__main__":
    import sys
    profile = sys.argv[1] if len(sys.argv) > 1 else "default"
    assessor = AWSSecurityAssessment(profile)
    assessor.check_iam_security()
    assessor.check_s3_security()
    assessor.check_security_services()
    report = assessor.generate_report()
    print(json.dumps(report, indent=2))
```

#### Step 2.2: Secret Management Testing

```python
import requests
import json
import re

class SecretManagementTest:
    COMMON_ENV_FILES = [
        ".env", ".env.local", ".env.development", ".env.production",
        ".env.staging", ".env.test",
    ]

    def __init__(self, org_name):
        self.org_name = org_name
        self.findings = []

    def test_env_file_exposure(self, base_url):
        print("[*] Testing for exposed .env files...")
        for env_file in self.COMMON_ENV_FILES:
            try:
                resp = requests.get(f"{base_url}/{env_file}", timeout=10, verify=False)
                if resp.status_code == 200:
                    secrets_found = self._scan_for_secrets(resp.text)
                    if secrets_found:
                        self.findings.append({
                            "type": "ENV_FILE_EXPOSED",
                            "file": env_file,
                            "secrets": secrets_found,
                            "severity": "CRITICAL"
                        })
                        print(f"  [!] Exposed .env file: {env_file}")
            except requests.RequestException:
                continue

    def test_config_file_exposure(self, base_url):
        print("[*] Testing for exposed config files...")
        config_files = [
            "config.json", "config.yaml", "config.yml",
            "database.yml", "settings.json", "application.yml",
        ]
        for config in config_files:
            try:
                resp = requests.get(f"{base_url}/{config}", timeout=10, verify=False)
                if resp.status_code == 200:
                    secrets_found = self._scan_for_secrets(resp.text)
                    if secrets_found:
                        self.findings.append({
                            "type": "CONFIG_FILE_EXPOSED",
                            "file": config,
                            "secrets": secrets_found,
                            "severity": "HIGH"
                        })
                        print(f"  [!] Exposed config: {config}")
            except requests.RequestException:
                continue

    def test_debug_endpoints(self, base_url):
        print("[*] Testing for debug endpoints...")
        debug_paths = [
            "/debug/", "/debug/vars", "/debug/pprof/",
            "/actuator/", "/actuator/env", "/actuator/configprops",
            "/metrics", "/health", "/info",
        ]
        for path in debug_paths:
            try:
                resp = requests.get(f"{base_url}{path}", timeout=10, verify=False)
                if resp.status_code == 200:
                    keywords = ["password", "secret", "key", "token", "credential"]
                    if any(kw in resp.text.lower() for kw in keywords):
                        self.findings.append({
                            "type": "DEBUG_ENDPOINT_SECRETS",
                            "path": path,
                            "severity": "HIGH",
                            "detail": "Debug endpoint may expose secrets"
                        })
                        print(f"  [!] Debug endpoint with secrets: {path}")
            except requests.RequestException:
                continue

    def _scan_for_secrets(self, content):
        patterns = {
            "AWS Key": r"AKIA[0-9A-Z]{16}",
            "Stripe Key": r"sk_live_[0-9a-zA-Z]{24,}",
            "GitHub Token": r"ghp_[0-9a-zA-Z]{36}",
            "Database URL": r"(?i)(postgres|mysql|mongodb)://[^\s]+",
            "JWT Token": r"eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_.+/=]+",
        }
        found = []
        for name, pattern in patterns.items():
            matches = re.findall(pattern, content)
            if matches:
                found.append({"type": name, "count": len(matches)})
        return found

    def generate_report(self):
        return {
            "organization": self.org_name,
            "total_findings": len(self.findings),
            "critical": sum(1 for f in self.findings if f.get("severity") == "CRITICAL"),
            "high": sum(1 for f in self.findings if f.get("severity") == "HIGH"),
            "findings": self.findings,
            "recommendations": [
                "Implement secret management solution (Vault, AWS Secrets Manager)",
                "Never commit secrets to version control",
                "Use environment variables for configuration",
                "Implement secret scanning in CI/CD pipeline",
                "Rotate all exposed secrets immediately",
                "Implement pre-commit hooks for secret detection",
                "Regular secret rotation policy"
            ]
        }

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python secrets_test.py <org_name> <base_url>")
        sys.exit(1)
    tester = SecretManagementTest(sys.argv[1])
    tester.test_env_file_exposure(sys.argv[2])
    tester.test_config_file_exposure(sys.argv[2])
    tester.test_debug_endpoints(sys.argv[2])
    report = tester.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 3: API Security Testing (Days 6-8)

```
API Security Testing Flow
===========================

 Authentication               Authorization
 +------------------+        +------------------+
 | API Key Testing  |        | Endpoint Access  |
 | JWT Validation   |        | Control          |
 +------------------+        +------------------+
 | OAuth Flow       |        | Role-Based       |
 | Testing          |        | Access           |
 +------------------+        +------------------+
 | Token Expiration |        | Resource-Level   |
 | Check            |        | Permissions      |
 +------------------+        +------------------+

 Input Validation              Rate Limiting
 +------------------+        +------------------+
 | SQL Injection    |        | Brute Force      |
 | XSS Testing      |        | Protection       |
 +------------------+        +------------------+
 | XXE Testing      |        | DDoS             |
 | SSRF Testing     |        | Protection       |
 +------------------+        +------------------+
 | Mass Assignment  |        | API Quota        |
 | Testing          |        | Enforcement      |
 +------------------+        +------------------+
```

#### Step 3.1: API Security Testing

```python
import requests
import json

class APISecurityTest:
    def __init__(self, base_url, api_key=None):
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key
        self.headers = {}
        if api_key:
            self.headers["Authorization"] = f"Bearer {api_key}"
        self.findings = []

    def test_authentication_bypass(self, endpoint):
        print(f"[*] Testing auth bypass on {endpoint}...")
        try:
            resp = requests.get(f"{self.base_url}{endpoint}", timeout=10, verify=False)
            if resp.status_code == 200:
                self.findings.append({
                    "type": "AUTH_BYPASS",
                    "endpoint": endpoint,
                    "severity": "CRITICAL",
                    "detail": "Endpoint accessible without authentication"
                })
                print(f"  [!] Auth bypass: {endpoint}")
        except requests.RequestException:
            pass

    def test_mass_assignment(self, endpoint):
        print(f"[*] Testing mass assignment on {endpoint}...")
        test_payloads = [
            {"role": "admin", "is_admin": True},
            {"price": 0, "discount": 100},
            {"approved": True, "verified": True},
        ]
        for payload in test_payloads:
            try:
                resp = requests.post(
                    f"{self.base_url}{endpoint}",
                    json=payload,
                    headers=self.headers,
                    timeout=10, verify=False
                )
                if resp.status_code in [200, 201]:
                    self.findings.append({
                        "type": "MASS_ASSIGNMENT",
                        "endpoint": endpoint,
                        "payload": payload,
                        "severity": "HIGH",
                        "detail": f"Server accepted admin fields: {payload}"
                    })
                    print(f"  [!] Mass assignment: {endpoint}")
                    break
            except requests.RequestException:
                continue

    def test_rate_limiting(self, endpoint):
        print(f"[*] Testing rate limiting on {endpoint}...")
        responses = []
        for i in range(150):
            try:
                resp = requests.get(
                    f"{self.base_url}{endpoint}",
                    headers=self.headers,
                    timeout=5, verify=False
                )
                responses.append(resp.status_code)
                if resp.status_code == 429:
                    print(f"  [+] Rate limit triggered at request {i+1}")
                    break
            except requests.RequestException:
                continue

        if 429 not in responses:
            self.findings.append({
                "type": "NO_RATE_LIMIT",
                "endpoint": endpoint,
                "severity": "MEDIUM",
                "detail": "No rate limiting detected after 150 requests"
            })
            print(f"  [!] No rate limiting: {endpoint}")

    def test_sql_injection(self, endpoint):
        print(f"[*] Testing SQL injection on {endpoint}...")
        payloads = ["'", "1 OR 1=1", "1' OR '1'='1", "1; SELECT 1--"]
        for payload in payloads:
            try:
                resp = requests.get(
                    f"{self.base_url}{endpoint}?id={payload}",
                    headers=self.headers,
                    timeout=10, verify=False
                )
                sql_errors = [
                    "sql syntax", "mysql_fetch", "ORA-01756",
                    "SQLite3::", "PostgreSQL", "Microsoft OLE DB"
                ]
                for error in sql_errors:
                    if error.lower() in resp.text.lower():
                        self.findings.append({
                            "type": "SQL_INJECTION",
                            "endpoint": endpoint,
                            "payload": payload,
                            "severity": "CRITICAL",
                            "detail": f"SQL error leaked: {error}"
                        })
                        print(f"  [!] SQLi found: {endpoint}")
                        return
            except requests.RequestException:
                continue

    def test_cors_configuration(self):
        print("[*] Testing CORS configuration...")
        origins_to_test = [
            "https://evil.com", "null", "https://attacker.com",
            f"https://{self.base_url.split('//')[1].split('/')[0]}",
        ]
        for origin in origins_to_test:
            try:
                resp = requests.get(
                    self.base_url,
                    headers={"Origin": origin},
                    timeout=10, verify=False
                )
                acao = resp.headers.get("Access-Control-Allow-Origin", "")
                if acao == "*" or acao == origin:
                    self.findings.append({
                        "type": "CORS_MISCONFIGURATION",
                        "origin": origin,
                        "severity": "HIGH" if acao == "*" else "MEDIUM",
                        "detail": f"ACAO header reflects: {acao}"
                    })
                    print(f"  [!] CORS issue: {acao}")
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
                "Implement API authentication for all endpoints",
                "Add rate limiting to all API endpoints",
                "Validate and sanitize all user input",
                "Implement proper CORS policies",
                "Use parameterized queries to prevent SQLi",
                "Implement mass assignment protection",
                "Add API versioning and deprecation policy",
                "Enable API logging and monitoring"
            ]
        }

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python api_test.py <base_url> [api_key]")
        sys.exit(1)
    api_key = sys.argv[2] if len(sys.argv) > 2 else None
    tester = APISecurityTest(sys.argv[1], api_key)
    tester.test_authentication_bypass("/api/users")
    tester.test_mass_assignment("/api/profile")
    tester.test_rate_limiting("/api/login")
    tester.test_sql_injection("/api/items")
    tester.test_cors_configuration()
    report = tester.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 4: Supply Chain Security (Days 9-10)

```
Supply Chain Attack Surface
==============================

 Dependencies                  CI/CD Pipeline
 +------------------+         +------------------+
 | npm packages     |         | GitHub Actions   |
 | PyPI packages    |         | Workflow Config  |
 | Go modules       |         |                  |
 +------------------+         +------------------+
 | Docker images    |         | Build Secrets    |
 | Base images      |         | Exposure         |
 +------------------+         +------------------+

 Third-Party Services           Container Registry
 +------------------+         +------------------+
 | SaaS APIs        |         | Docker Hub       |
 | Webhooks         |         | GHCR             |
 | OAuth Providers  |         | ECR              |
 +------------------+         +------------------+
```

#### Step 4.1: Dependency Vulnerability Scanning

```python
import subprocess
import json

class SupplyChainAudit:
    def __init__(self, project_path):
        self.project_path = project_path
        self.findings = []

    def run_command(self, cmd):
        try:
            result = subprocess.run(
                cmd, shell=True, capture_output=True,
                text=True, timeout=120
            )
            return result.stdout, result.returncode
        except subprocess.TimeoutExpired:
            return "", 1

    def audit_npm_dependencies(self):
        print("[*] Auditing npm dependencies...")
        stdout, rc = self.run_command("npm audit --json")
        if rc == 0 or stdout:
            try:
                data = json.loads(stdout)
                vulns = data.get("vulnerabilities", {})
                for name, details in vulns.items():
                    self.findings.append({
                        "type": "NPM_VULNERABILITY",
                        "package": name,
                        "severity": details.get("severity", "unknown"),
                        "title": details.get("title", "N/A"),
                    })
                print(f"  [+] Found {len(vulns)} npm vulnerabilities")
            except json.JSONDecodeError:
                pass

    def audit_python_dependencies(self):
        print("[*] Auditing Python dependencies...")
        stdout, rc = self.run_command("pip-audit --format=json")
        if rc == 0 or stdout:
            try:
                data = json.loads(stdout)
                for vuln in data.get("vulnerabilities", []):
                    self.findings.append({
                        "type": "PIP_VULNERABILITY",
                        "package": vuln.get("name"),
                        "severity": vuln.get("fix_versions", []),
                        "title": vuln.get("id", "N/A"),
                    })
            except json.JSONDecodeError:
                pass

    def scan_docker_images(self):
        print("[*] Scanning Docker images...")
        stdout, rc = self.run_command(
            "trivy image --format json --severity HIGH,CRITICAL"
        )
        if rc == 0 or stdout:
            try:
                data = json.loads(stdout)
                for result in data.get("Results", []):
                    for vuln in result.get("Vulnerabilities", []):
                        self.findings.append({
                            "type": "CONTAINER_VULNERABILITY",
                            "package": vuln.get("PkgName"),
                            "severity": vuln.get("Severity"),
                            "cve": vuln.get("VulnerabilityID"),
                        })
            except json.JSONDecodeError:
                pass

    def check_secrets_in_code(self):
        print("[*] Scanning for secrets in code...")
        stdout, rc = self.run_command(
            "trufflehog git file://. --json"
        )
        if stdout:
            try:
                data = json.loads(stdout)
                for item in data.get("results", []):
                    self.findings.append({
                        "type": "SECRET_IN_CODE",
                        "file": item.get("SourceMetadata", {}).get("Data", {}).get("Git", {}).get("file"),
                        "severity": "CRITICAL",
                        "detector": item.get("DetectorName"),
                    })
            except json.JSONDecodeError:
                pass

    def generate_report(self):
        return {
            "project_path": self.project_path,
            "total_findings": len(self.findings),
            "critical": sum(1 for f in self.findings if f.get("severity") == "CRITICAL"),
            "high": sum(1 for f in self.findings if f.get("severity") == "HIGH"),
            "findings": self.findings,
            "recommendations": [
                "Enable Dependabot or Renovate for automated updates",
                "Implement SBOM generation in CI/CD",
                "Use pinned versions for all dependencies",
                "Scan container images before deployment",
                "Implement pre-commit hooks for secret detection",
                "Use only verified Docker base images",
                "Implement dependency lockfiles",
                "Regular security audits of third-party services"
            ]
        }

if __name__ == "__main__":
    import sys
    path = sys.argv[1] if len(sys.argv) > 1 else "."
    auditor = SupplyChainAudit(path)
    auditor.audit_npm_dependencies()
    auditor.audit_python_dependencies()
    auditor.scan_docker_images()
    auditor.check_secrets_in_code()
    report = auditor.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 5: Analysis and Reporting (Days 11-12)

```
Startup Reporting Framework
==============================

 Risk Prioritization
 +---------------------------+
 | CRITICAL                  |  Active breach, secret exposure
 | HIGH                      |  Auth bypass, data exposure
 | MEDIUM                    |  Weak controls, misconfig
 | LOW                       |  Best practice gaps
 | INFO                      |  Recommendations
 +---------------------------+

 Business Context
 +---------------------------+
 | Funding Impact            |  Investor confidence
 | Customer Trust            |  Churn risk
 | Regulatory Risk           |  Compliance gaps
 | Technical Debt            |  Future cost
 +---------------------------+
```

---

## 5. Tool Arsenal

### Cloud Security

```bash
# AWS security assessment
Prowler aws --profile <profile> --checks check11 check12
ScoutSuite aws --profile <profile>

# GCP security
Prowler gcp --project-id <project>

# Azure security
Prowler azure --cli-auth
```

### Container Security

```bash
# Image scanning
trivy image <image_name>:<tag> --severity HIGH,CRITICAL
grype <image_name>:<tag>

# Container benchmark
docker-bench-security

# SBOM generation
syft <image_name>:<tag> -o spdx-json
```

### Secret Detection

```bash
# Repository secret scanning
trufflehog git file://. --json
gitleaks detect --source . --report-format json

# Pre-commit hook
pip install pre-commit
# Add gitleaks to .pre-commit-config.yaml
```

### API Testing

```bash
# Nuclei API templates
nuclei -u <target> -t nuclei-templates/http/exposures/

# ffuf API fuzzing
ffuf -u <target>/api/FUZZ -w api_endpoints.txt -mc 200

# JWT testing
jwt_tool <token> -T -k <key>
```

### Software Composition Analysis

```bash
# npm audit
npm audit --audit-level=high

# pip audit
pip-audit --severity high

# Snyk test
snyk test --severity-threshold=high
```

---

## 6. Real-World Examples

### Example 1: S3 Bucket Data Breach

```
Scenario:
- Series A fintech startup
- Customer financial data in misconfigured S3 bucket
- Discovered by security researcher

Attack Path:
1. S3 bucket named after company found via DNS
2. Bucket policy allowed public read
3. 50,000 customer records exposed
4. Records included SSN and bank account numbers

Impact:
- $500K in incident response costs
- $2M in customer notifications and credit monitoring
- Series B funding delayed 6 months
- CEO resignation

Lessons Learned:
- Implement S3 Block Public Access at account level
- Use AWS Config rules for continuous monitoring
- Implement data classification before cloud migration
```

### Example 2: GitHub Actions Secret Leak

```
Scenario:
- B2B SaaS startup
- Secrets printed in CI/CD logs
- Attacker gained access to production database

Attack Path:
1. Developer used echo to debug GitHub Actions workflow
2. AWS credentials logged in plain text
3. Attacker found credentials in public workflow logs
4. Accessed production RDS instance

Impact:
- Complete customer database exfiltrated
- GDPR breach notification required
- $300K in remediation costs
- Lost 3 enterprise customers

Lessons Learned:
- Implement GitHub Actions secret masking
- Never echo secrets in workflows
- Use OIDC for cloud authentication
- Implement workflow approval for sensitive operations
```

### Example 3: Supply Chain Attack via npm

```
Scenario:
- Developer tools startup
- Compromised npm package in dependency tree
- Cryptominer deployed to production servers

Attack Path:
1. Popular npm package compromised
2. Malicious code injected into dependency
3. Startup application pulled updated dependency
4. Cryptominer executed in production environment

Impact:
- $25K in cloud compute costs
- Production performance degradation
- 3-day incident response
- Customer trust damaged

Lessons Learned:
- Implement dependency lockfiles
- Use npm audit in CI/CD
- Pin exact dependency versions
- Implement runtime monitoring for anomaly detection
```

---

## 7. Bypass Techniques

### 7.1 Authentication Bypass in Startup APIs

```
Common Startup Auth Bypass Vectors
====================================

 [1] JWT Algorithm Confusion
     - Change algorithm from RS256 to HS256
     - Use public key as HMAC secret
     - Impact: Token forgery

 [2] API Key in URL
     - API keys passed as URL parameters
     - Logged in server access logs
     - Impact: Credential exposure

 [3] OAuth Redirect URI Manipulation
     - Open redirect in redirect_uri
     - Impact: Authorization code theft

 [4] Magic Link Abuse
     - No expiration on magic links
     - No rate limiting on link generation
     - Impact: Account takeover

 [5] Webhook Signature Bypass
     - Missing webhook signature validation
     - Impact: Data manipulation
```

### 7.2 Cloud Misconfiguration Bypass

```python
class CloudBypassTest:
    def test_iam_privilege_escalation(self):
        """Test IAM privilege escalation paths."""
        escalation_paths = [
            "iam:CreateRole + iam:AttachRolePolicy",
            "lambda:CreateFunction + iam:PassRole",
            "ec2:RunInstances + iam:PassRole",
            "glue:CreateDevEndpoint",
            "datapipeline:CreatePipeline",
        ]
        findings = []
        for path in escalation_paths:
            findings.append({
                "path": path,
                "test": "Check if current IAM policy allows",
                "severity": "CRITICAL"
            })
        return findings

    def test_metadata_service(self):
        """Test IMDSv1 vs IMDSv2 configuration."""
        findings = []
        findings.append({
            "check": "IMDS Version",
            "test": "Check if IMDSv1 is still enabled",
            "impact": "SSRF to credential theft",
            "severity": "HIGH"
        })
        return findings

    def test_lambda_function_url(self):
        """Test Lambda function URL security."""
        findings = []
        findings.append({
            "check": "Lambda Function URLs",
            "test": "Enumerate and test public Lambda URLs",
            "impact": "Serverless endpoint exposure",
            "severity": "MEDIUM"
        })
        return findings
```

---

## 8. Common Pitfalls

### 8.1 Startup-Specific Pitfalls

```
Common Startup Testing Mistakes
================================

 [1] IGNORING VELOCITY PRESSURE
     - Recommending processes that slow development
     - Mitigation: Security as code, automated scanning
     - Focus: Developer-friendly security tools

 [2] OVERLOOKING FOUNDATIONAL ACCESS
     - Everyone has admin access
     - Mitigation: Implement RBAC from day one
     - Reality: Founder access is root

 [3] MISSING SaaS INTEGRATIONS
     - Dozens of SaaS tools with data
     - Mitigation: SaaS inventory and security review
     - Reality: Shadow IT is the norm

 [4] FORGETTING FUNDING IMPACT
     - Security incidents affect valuation
     - Mitigation: Frame security as business enabler
     - Reality: Investors check security posture

 [5] UNDERESTIMATING DATA VALUE
     - Startup assumes data has no value
     - Mitigation: Data classification exercise
     - Reality: Customer data is the product

 [6] IGNORING DEVELOPER ENVIRONMENTS
     - Local dev machines have production access
     - Mitigation: Implement development environment isolation
     - Reality: Developers work from anywhere

 [7] MISSING INCIDENT RESPONSE
     - No IR plan exists
     - Mitigation: Create basic IR plan
     - Reality: First incident is always chaotic
```

---

## 9. Reporting Template

```
STARTUP SECURITY ASSESSMENT REPORT
====================================

Document Information:
- Company: [Startup Name]
- Stage: [Pre-Seed/Seed/Series A/B/C]
- Assessment Period: [Dates]
- Assessor: [Name/Org]
- Classification: CONFIDENTIAL

---

EXECUTIVE SUMMARY

[2-3 paragraphs for founders/investors. Focus on business
risk, funding implications, and quick wins.]

OVERALL RISK RATING: [CRITICAL / HIGH / MEDIUM / LOW]

KEY METRICS:
- Total Findings: [N]
- Critical: [N] | High: [N] | Medium: [N] | Low: [N]
- Estimated Fix Time: [N] days
- Funding Impact: [Assessment]

---

TECHNOLOGY STACK SUMMARY

[Overview of discovered technology stack]

- Frontend: [Technologies]
- Backend: [Technologies]
- Database: [Technologies]
- Cloud: [Provider and services]
- CI/CD: [Platform]
- Auth: [Provider]

---

FINDINGS

[For each finding:]

FINDING #[N]: [Title]
Severity: [Level] | CVSS: [Score]
Affected System: [System]

Description: [Clear explanation]
Business Impact: [Startup-specific impact]
Evidence: [Technical details]
Remediation: [Quick fix for startup context]

---

REMEDIATION ROADMAP

Phase 1 - Quick Wins (1-2 weeks):
- [Critical findings with low effort]

Phase 2 - Foundation (1-2 months):
- [High findings with moderate effort]

Phase 3 - Maturity (3-6 months):
- [Medium findings and strategic improvements]

---

INVESTOR READINESS

[Assessment of security posture for due diligence]

- Data Protection: [Status]
- Access Controls: [Status]
- Incident Response: [Status]
- Compliance: [Status]

---

APPENDICES

A. Cloud Architecture Diagram
B. Technology Stack Details
C. Tool Output
D. Remediation Resources
```

---

## 10. Quick Reference

### Startup Security Checklist

```
FOUNDATION (Day 1)
[ ] Enable MFA for all cloud accounts
[ ] Implement secret management
[ ] Set up automated backups
[ ] Enable logging (CloudTrail, etc.)
[ ] Basic incident response plan

CODE SECURITY
[ ] Branch protection rules
[ ] Secret scanning in CI/CD
[ ] Dependency vulnerability scanning
[ ] Code review requirements
[ ] Pre-commit hooks for secrets

CLOUD SECURITY
[ ] S3 bucket public access blocked
[ ] IAM least-privilege policies
[ ] Security groups restrictive
[ ] Encryption at rest enabled
[ ] VPC flow logs enabled

API SECURITY
[ ] Authentication on all endpoints
[ ] Rate limiting implemented
[ ] Input validation
[ ] CORS properly configured
[ ] API versioning

MONITORING
[ ] Error tracking (Sentry)
[ ] Uptime monitoring
[ ] Security alerting
[ ] Log aggregation
[ ] Anomaly detection
```

### Startup Security Budget Guide

```
Stage        Monthly Budget   Priority Tools
-----------  ---------------  ----------------------------------
Pre-Seed     $0-100           GitHub free tier, CloudTrail
Seed         $100-500         Snyk, Sentry, WAF basic
Series A     $500-2K          Prowler, Trivy, Secret scanning
Series B     $2K-10K          Full security tooling, pentest
Series C+    $10K+            Security team, compliance tools
```

---

## References

- OWASP Top 10 for Cloud-Native Applications
- NIST Cybersecurity Framework for Small Business
- CIS Benchmarks for Cloud Providers
- SANS Institute Security Guide for Startups
- Y Combinator Security Best Practices
- TechCrunch Startup Security Guide
- Cloud Security Alliance (CSA) Guidance
