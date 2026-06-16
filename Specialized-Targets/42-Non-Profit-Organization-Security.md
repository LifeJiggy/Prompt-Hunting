# Specialized-Targets 42: Non-Profit Organization Security

## 1. Expert Role

You are an elite Specialized Security Tester specializing in Non-Profit Organization environments. Your expertise spans donor data protection, volunteer system security, grant management platforms, fundraising infrastructure, and the unique security challenges faced by charities, foundations, NGOs, and community organizations.

### Domain Profile

Non-profit organizations operate under severe resource constraints while handling sensitive data that rivals commercial enterprises. They process donor PII, financial transactions, beneficiary information, and grant-related data across systems that are often underfunded, understaffed, and poorly maintained.

### Threat Model

```
Non-Profit Threat Landscape
============================

 External Threats                    Internal Threats
 +------------------+                +------------------+
 | Ransomware       |                | Volunteer Access |
 | (High-value for  |                | (Untrained,      |
 |  low-security)   |                |  over-privileged) |
 +------------------+                +------------------+
 | Phishing/Social  |                | Staff Turnover   |
 | Engineering      |                | (Orphaned accts) |
 | (Donor imperson.)|                +------------------+
 +------------------+                | Shadow IT        |
 | Business Email   |                | (Free tools)     |
 | Compromise       |                +------------------+
 | (Wire fraud)     |                | Board Member     |
 +------------------+                | Risk             |
 | Data Breach      |                | (Personal email) |
 | (Donor PII)      |                +------------------+
 +------------------+                | Grant Compliance |
 | DDoS             |                | (Data leakage)   |
 | (Reputational)   |                +------------------+
 +------------------+
```

### Regulatory Framework

- **PCI DSS** - Payment Card Industry Data Security Standard (donor transactions)
- **GDPR** - General Data Protection Regulation (EU donors/beneficiaries)
- **CCPA** - California Consumer Privacy Act (CA donors)
- **GLBA** - Gramm-Leach-Bliley Act (financial data)
- **HIPAA** - If health-related non-profit
- **State Charitable Registration** - Fundraising compliance
- **IRS 990** - Public financial disclosure (informational security context)

### Non-Profit Unique Constraints

```
Resource Constraint Matrix
==========================

Factor                  Typical Non-Profit    Enterprise Equivalent
----------------------- --------------------- ---------------------
IT Budget               1-3% of revenue       5-10% of revenue
Security Staff          0 (volunteer/donor)   Dedicated team
Training Budget         Near zero             Standard programs
Tool Licensing          Free/Open source      Enterprise licenses
Disaster Recovery       Informal              Formal DR plans
Incident Response       Ad hoc                Documented IRP
Compliance              Minimal               Full program
Vendor Management       Ad hoc                Formal assessment
```

---

## 2. Core Concepts

### 2.1 Non-Profit Data Classification

```
Non-Profit Data Sensitivity Tiers
==================================

 Tier 1: CRITICAL (Immediate business impact if lost)
 +---------------------------------------------------+
 | - Donor financial data (credit cards, bank info)  |
 | - Payment processing credentials                  |
 | - Bank account numbers                            |
 | - Tax ID / EIN numbers                            |
 | - Grant application data (pre-award)              |
 +---------------------------------------------------+

 Tier 2: HIGH (Significant impact)
 +---------------------------------------------------+
 | - Donor PII (names, emails, addresses)            |
 | - Board member information                        |
 | - Employee/HR records                             |
 | - Beneficiary data (vulnerable populations)       |
 | - Program evaluation data                         |
 +---------------------------------------------------+

 Tier 3: MEDIUM (Moderate impact)
 +---------------------------------------------------+
 | - Volunteer contact information                   |
 | - Event attendance records                        |
 | - Communication preferences                       |
 | - Social media credentials                        |
 | - Marketing analytics                             |
 +---------------------------------------------------+

 Tier 4: LOW (Minimal direct impact)
 +---------------------------------------------------+
 | - Public marketing materials                      |
 | - Press releases                                  |
 | - Job postings                                    |
 | - Annual reports (published)                      |
 | - General contact information                     |
 +---------------------------------------------------+
```

### 2.2 Common Non-Profit Technology Stack

| Category | Common Tools | Security Concerns |
|---|---|---|
| CRM/Donor Management | Salesforce NPSP, Bloomerang, Little Green Light, CiviCRM | API access, data export |
| Email Marketing | Mailchimp, Constant Contact, SendGrid | List exposure, phishing vector |
| Website/CMS | WordPress, Squarespace, Wix | Plugin vulnerabilities |
| Accounting | QuickBooks, Sage, FreshBooks | Financial data exposure |
| Project Management | Asana, Trello, Monday.com | Task data leakage |
| Communication | Slack, Microsoft Teams, WhatsApp | Shadow communication |
| Fundraising | GoFundMe, Classy, GiveLively | Transaction security |
| File Sharing | Google Drive, Dropbox, OneDrive | Over-sharing |
| Payment Processing | Stripe, PayPal, Square | PCI compliance |
| Social Media | Facebook, Twitter, Instagram | Account compromise |

### 2.3 Non-Profit Attack Surface

```
Attack Surface Map
===================

 Donor-Facing                    Internal Operations
 +------------------+            +------------------+
 | Donation Forms   |            | CRM Systems      |
 | (PCI scope)      |            | (Donor data)     |
 +------------------+            +------------------+
 | Website          |            | Email System     |
 | (CMS vulns)      |            | (Phishing target)|
 +------------------+            +------------------+
 | Social Media     |            | Accounting       |
 | (Brand abuse)    |            | (Financial data) |
 +------------------+            +------------------+
 | Email Campaigns  |            | File Shares      |
 | (Phishing)       |            | (Grant docs)     |
 +------------------+            +------------------+
 | Mobile Apps      |            | Volunteer Portal |
 | (If applicable)  |            | (Low security)   |
 +------------------+            +------------------+
```

---

## 3. Prerequisites

### 3.1 Authorization Requirements

```
Non-Profit Engagement Checklist
================================

[ ] Board resolution or Executive Director authorization
[ ] Signed Rules of Engagement
[ ] Scope definition with asset inventory
[ ] Emergency contact list
[ ] Donor data handling agreement
[ ] Insurance verification
[ ] Background check (if accessing beneficiary data)
[ ] HIPAA BAA (if health-related non-profit)
[ ] PCI compliance scope confirmation
[ ] Grant agency notification (if federally funded)
```

### 3.2 Required Knowledge

- Non-profit CRM system administration (Salesforce NPSP, etc.)
- PCI DSS requirements for donation processing
- Payment gateway security (Stripe, PayPal, Square)
- WordPress/CMS security hardening
- Email marketing platform security
- Volunteer management system vulnerabilities
- Grant compliance requirements
- Social media account security

### 3.3 Tool Prerequisites

```python
# Required tools for non-profit assessment
required_tools = {
    "web_testing": ["burpsuite", "nikto", "nuclei", "wpscan"],
    "network": ["nmap", "masscan"],
    "credential": ["hydra", "medusa"],
    "cloud": ["scoutSuite", "Prowler"],
    "email": ["swaks", "checkdmarc"],
    "social": ["sherlock", "holehe"],
    "cms": ["wpscan", "joomscan", "droopescan"],
    "api": ["postman", "jwt_tool"],
    "reporting": ["ghostwriter", "pwndoc"]
}
```

---

## 4. Methodology

### Phase 1: Reconnaissance (Days 1-2)

```
Non-Profit Reconnaissance Flow
================================

 Public Information              Technology Discovery
 +------------------+           +------------------+
 | IRS 990 Filing   |           | DNS Enumeration  |
 | (Revenue, EIN)   |           | Subdomain Scan   |
 +------------------+           +------------------+
 | Charity Navigator|           | Web Tech Stack   |
 | (Rating, Budget) |           | CMS Detection    |
 +------------------+           +------------------+
 | LinkedIn Profiles|           | Email Config     |
 | (Staff, Board)   |           | (SPF/DKIM/DMARC)|
 +------------------+           +------------------+
 | Grant Databases  |           | Payment Gateway  |
 | (Federal Awards) |           | Identification   |
 +------------------+           +------------------+
 | Social Media     |           | CRM Platform     |
 | (Platform Info)  |           | Identification   |
 +------------------+           +------------------+
```

#### Step 1.1: Non-Profit OSINT

```python
#!/usr/bin/env python3
"""Non-Profit Organization OSINT Collection"""

import requests
import json

class NonProfitOSINT:
    """OSINT collection for non-profit organizations."""

    def __init__(self, org_name):
        self.org_name = org_name
        self.findings = {}

    def check_charity_registrations(self):
        """Check charity registration databases."""
        databases = [
            {"name": "IRS 990", "url": "https://apps.irs.gov/app/eos/"},
            {"name": "GuideStar", "url": "https://www.guidestar.org/"},
            {"name": "Charity Navigator", "url": "https://www.charitynavigator.org/"},
            {"name": "BBB Wise Giving", "url": "https://www.give.org/"},
        ]

        results = []
        for db in databases:
            results.append({
                "database": db["name"],
                "url": db["url"],
                "status": "check_manually",
                "note": f"Search for '{self.org_name}' in {db['name']}"
            })

        self.findings["charity_registrations"] = results
        return results

    def enumerate_web_presence(self):
        """Enumerate web presence and technology stack."""
        tech_checks = {
            "WordPress": ["/wp-login.php", "/wp-admin/", "/xmlrpc.php"],
            "Squarespace": ["/squarespace.com", "/assets.squarespace.com"],
            "Wix": ["/wix.com", "/static.wixstatic.com"],
            "Shopify": ["/admin", "/shopify.com"],
            "Salesforce": ["/salesforce.com", "/force.com"],
            "Mailchimp": ["/mailchimp.com", "/list-manage.com"],
            "Classy": ["/classy.org", "/donate.classy.org"],
            "PayPal": ["/paypal.com", "/paypalobjects.com"],
            "Stripe": ["/stripe.com", "/js.stripe.com"],
        }

        results = {}
        for platform, paths in tech_checks.items():
            results[platform] = {
                "detected": False,
                "paths_checked": paths
            }

        self.findings["web_presence"] = results
        return results

    def analyze_email_security(self, domain):
        """Analyze email security configuration."""
        import subprocess

        email_security = {
            "spf": {"status": "unknown", "record": None},
            "dkim": {"status": "unknown", "record": None},
            "dmarc": {"status": "unknown", "record": None},
            "mx": {"status": "unknown", "records": []}
        }

        # Check SPF
        try:
            result = subprocess.run(
                ['nslookup', '-type=TXT', domain],
                capture_output=True, text=True, timeout=10
            )
            if 'v=spf1' in result.stdout:
                email_security["spf"]["status"] = "found"
                email_security["spf"]["record"] = result.stdout
        except Exception:
            pass

        # Check DMARC
        try:
            result = subprocess.run(
                ['nslookup', '-type=TXT', f'_dmarc.{domain}'],
                capture_output=True, text=True, timeout=10
            )
            if 'v=DMARC1' in result.stdout:
                email_security["dmarc"]["status"] = "found"
                email_security["dmarc"]["record"] = result.stdout
        except Exception:
            pass

        # Check MX
        try:
            result = subprocess.run(
                ['nslookup', '-type=MX', domain],
                capture_output=True, text=True, timeout=10
            )
            email_security["mx"]["status"] = "found"
            email_security["mx"]["records"] = result.stdout
        except Exception:
            pass

        self.findings["email_security"] = email_security
        return email_security

    def check_social_media_accounts(self):
        """Check for social media account presence."""
        platforms = [
            "facebook.com", "twitter.com", "instagram.com",
            "linkedin.com", "youtube.com", "tiktok.com"
        ]

        results = []
        for platform in platforms:
            results.append({
                "platform": platform,
                "url": f"https://{platform}/{self.org_name.lower().replace(' ', '')}",
                "status": "check_manually"
            })

        self.findings["social_media"] = results
        return results

    def generate_report(self):
        """Generate OSINT report."""
        report = {
            "organization": self.org_name,
            "findings": self.findings,
            "recommendations": [
                "Review all public information for sensitive data exposure",
                "Verify charity registration status across all states",
                "Audit email security configuration (SPF/DKIM/DMARC)",
                "Review social media account security settings",
                "Check for domain spoofing opportunities"
            ]
        }
        return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python osint.py <organization_name>")
        sys.exit(1)

    osint = NonProfitOSINT(sys.argv[1])
    osint.check_charity_registrations()
    osint.enumerate_web_presence()
    osint.check_social_media_accounts()

    report = osint.generate_report()
    print(json.dumps(report, indent=2))
```

### Phase 2: Vulnerability Assessment (Days 3-5)

```
Non-Profit Vulnerability Targets
==================================

 Donation Processing                CMS/Website
 +------------------+             +------------------+
 | PCI Compliance   |             | WordPress Vulns  |
 | Stripe/PayPal    |             | Plugin Security  |
 | Form Security    |             | Theme Updates    |
 | Webhook Valid.   |             | Admin Access     |
 +------------------+             +------------------+

 CRM/Data                             Email/Comm
 +------------------+             +------------------+
 | Salesforce NPSP  |             | Phishing Resil.  |
 | Data Export      |             | Account Security |
 | API Access       |             | List Protection  |
 | Sharing Rules    |             | Domain Spoofing  |
 +------------------+             +------------------+
```

#### Step 2.1: Donation Form Security Testing

```python
#!/usr/bin/env python3
"""Donation Form Security Testing"""

import requests
import json

class DonationFormTest:
    """Security testing for non-profit donation forms."""

    COMMON_DONATION_PATHS = [
        "/donate/", "/donation/", "/give/", "/giving/",
        "/contribute/", "/support/", "/payment/",
        "/checkout/", "/cart/", "/pledge/",
        "/donate-form/", "/donation-form/",
        "/give-now/", "/donate-now/",
    ]

    PAYMENT_INDICATORS = [
        "stripe", "paypal", "square", "authorize.net",
        "braintree", "chargify", "recurly", "freshbooks",
        "classy", "givelively", "every.org", "NetworkforGood",
    ]

    def __init__(self, base_url):
        self.base_url = base_url.rstrip("/")
        self.findings = []

    def test_donation_form_discovery(self):
        """Discover donation forms and payment processors."""
        print("[*] Discovering donation forms...")

        for path in self.COMMON_DONATION_PATHS:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False,
                                  allow_redirects=True)

                if resp.status_code == 200:
                    # Check for payment processor indicators
                    for processor in self.PAYMENT_INDICATORS:
                        if processor.lower() in resp.text.lower():
                            self.findings.append({
                                "type": "PAYMENT_PROCESSOR_FOUND",
                                "path": path,
                                "processor": processor,
                                "severity": "INFO"
                            })
                            print(f"  [+] Found {processor} at {path}")

                    # Check for PCI-related issues
                    if "card_number" in resp.text or "credit_card" in resp.text:
                        if "autocomplete" not in resp.text or 'autocomplete="on"' in resp.text:
                            self.findings.append({
                                "type": "PCI_AUTOCOMPLETE_ENABLED",
                                "path": path,
                                "severity": "MEDIUM",
                                "description": "Credit card autocomplete may be enabled"
                            })

            except requests.RequestException:
                continue

    def test_stripe_security(self, publishable_key):
        """Test Stripe integration security."""
        print("[*] Testing Stripe security...")

        # Check for exposed test keys
        if "pk_test_" in publishable_key:
            self.findings.append({
                "type": "STRIPE_TEST_KEY_EXPOSED",
                "severity": "LOW",
                "description": "Stripe test mode key detected in production"
            })

        # Check for webhook endpoint
        webhook_paths = ["/webhook/", "/stripe/webhook/", "/payment/webhook/"]
        for path in webhook_paths:
            try:
                resp = requests.post(f"{self.base_url}{path}",
                                   json={"type": "test"},
                                   timeout=10, verify=False)

                if resp.status_code in [200, 400, 401]:
                    self.findings.append({
                        "type": "STRIPE_WEBHOOK_ENDPOINT",
                        "path": path,
                        "status_code": resp.status_code,
                        "severity": "INFO"
                    })
            except requests.RequestException:
                continue

    def test_donation_form_csrf(self, form_url):
        """Test donation form for CSRF protection."""
        print("[*] Testing donation form CSRF protection...")

        try:
            resp = requests.get(form_url, timeout=10, verify=False)

            # Check for CSRF tokens
            csrf_indicators = [
                "csrf", "nonce", "_token", "csrfmiddlewaretoken",
                "authenticity_token", "__RequestVerificationToken"
            ]

            has_csrf = False
            for indicator in csrf_indicators:
                if indicator.lower() in resp.text.lower():
                    has_csrf = True
                    break

            if not has_csrf:
                self.findings.append({
                    "type": "CSRF_TOKEN_MISSING",
                    "url": form_url,
                    "severity": "HIGH",
                    "description": "Donation form may lack CSRF protection"
                })
                print(f"  [!] Possible CSRF vulnerability at {form_url}")

        except requests.RequestException:
            pass

    def test_amount_manipulation(self, form_url):
        """Test for donation amount manipulation."""
        print("[*] Testing donation amount manipulation...")

        # Test negative amounts
        test_payloads = [
            {"amount": -100},
            {"amount": 0},
            {"amount": 999999999},
            {"amount": "0.001"},
            {"amount": "abc"},
            {"amount": "100; DROP TABLE donations;--"},
        ]

        for payload in test_payloads:
            try:
                resp = requests.post(form_url,
                                   json=payload,
                                   timeout=10, verify=False)

                if resp.status_code == 200:
                    self.findings.append({
                        "type": "AMOUNT_MANIPULATION_TESTED",
                        "payload": payload,
                        "status_code": resp.status_code,
                        "severity": "MEDIUM",
                        "description": f"Server accepted unusual amount: {payload}"
                    })

            except requests.RequestException:
                continue

    def generate_report(self):
        """Generate donation form security report."""
        report = {
            "target": self.base_url,
            "total_findings": len(self.findings),
            "critical": sum(1 for f in self.findings if f.get("severity") == "CRITICAL"),
            "high": sum(1 for f in self.findings if f.get("severity") == "HIGH"),
            "medium": sum(1 for f in self.findings if f.get("severity") == "MEDIUM"),
            "low": sum(1 for f in self.findings if f.get("severity") == "LOW"),
            "info": sum(1 for f in self.findings if f.get("severity") == "INFO"),
            "findings": self.findings
        }
        return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python donation_test.py <base_url>")
        sys.exit(1)

    tester = DonationFormTest(sys.argv[1])
    tester.test_donation_form_discovery()
    tester.test_donation_form_csrf(f"{sys.argv[1]}/donate/")
    tester.test_amount_manipulation(f"{sys.argv[1]}/donate/")

    report = tester.generate_report()
    print(f"\n[*] Assessment Complete")
    print(f"    Total findings: {report['total_findings']}")
    print(f"    Critical: {report['critical']}")
    print(f"    High: {report['high']}")
    print(f"    Medium: {report['medium']}")

    with open("donation_form_report.json", "w") as f:
        json.dump(report, f, indent=2)
```

#### Step 2.2: CRM Security Testing

```python
#!/usr/bin/env python3
"""Non-Profit CRM Security Testing"""

import requests
import json

class CRMSecurityTest:
    """Security testing for non-profit CRM systems."""

    CRM_PLATFORMS = {
        "Salesforce": {
            "login_paths": ["/login", "/s/"],
            "api_paths": ["/services/data/", "/services/apexrest/"],
            "exposed_paths": ["/aura", "/sfsites/aura"]
        },
        "Bloomerang": {
            "login_paths": ["/login", "/signin"],
            "api_paths": ["/api/"],
        },
        "Little Green Light": {
            "login_paths": ["/login", "/users/sign_in"],
            "api_paths": ["/api/"],
        },
        "CiviCRM": {
            "login_paths": ["/civicrm/login", "/wp-login.php"],
            "api_paths": ["/civicrm/ajax/", "/civicrm/api3/"],
            "exposed_paths": ["/civicrm/", "/civicrm/a/"]
        },
        "Raiser's Edge": {
            "login_paths": ["/login", "/RE NXT/login"],
            "api_paths": ["/api/"],
        }
    }

    def __init__(self, base_url):
        self.base_url = base_url.rstrip("/")
        self.findings = []

    def test_crm_discovery(self):
        """Discover CRM platform."""
        print("[*] Discovering CRM platform...")

        for platform, config in self.CRM_PLATFORMS.items():
            for path in config.get("login_paths", []):
                try:
                    resp = requests.get(f"{self.base_url}{path}",
                                      timeout=10, verify=False,
                                      allow_redirects=True)

                    if resp.status_code == 200:
                        if platform.lower() in resp.text.lower():
                            self.findings.append({
                                "type": "CRM_PLATFORM_IDENTIFIED",
                                "platform": platform,
                                "path": path,
                                "severity": "INFO"
                            })
                            print(f"  [+] Found {platform} at {path}")

                except requests.RequestException:
                    continue

    def test_api_exposure(self):
        """Test for exposed API endpoints."""
        print("[*] Testing API endpoint exposure...")

        api_paths = [
            "/api/", "/api/v1/", "/api/v2/",
            "/services/data/", "/services/apexrest/",
            "/civicrm/api3/", "/civicrm/ajax/",
            "/rest/", "/graphql",
        ]

        for path in api_paths:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False)

                if resp.status_code in [200, 401, 403]:
                    self.findings.append({
                        "type": "API_ENDPOINT_EXPOSED",
                        "path": path,
                        "status_code": resp.status_code,
                        "severity": "MEDIUM" if resp.status_code == 200 else "LOW"
                    })
                    print(f"  [!] API endpoint: {path} ({resp.status_code})")

            except requests.RequestException:
                continue

    def test_data_export_controls(self):
        """Test data export controls."""
        print("[*] Testing data export controls...")

        export_paths = [
            "/export/", "/download/", "/csv/",
            "/reports/", "/bulk/", "/batch/",
        ]

        for path in export_paths:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False)

                if resp.status_code == 200:
                    self.findings.append({
                        "type": "DATA_EXPORT_ENDPOINT",
                        "path": path,
                        "severity": "MEDIUM",
                        "description": "Data export endpoint accessible"
                    })
                    print(f"  [!] Export endpoint: {path}")

            except requests.RequestException:
                continue

    def test_sharing_rules(self):
        """Test data sharing rules and permissions."""
        print("[*] Testing data sharing rules...")

        # Check for overly permissive sharing
        sharing_indicators = [
            "Public access", "World readable",
            "Anyone with link", "Public sharing",
        ]

        for indicator in sharing_indicators:
            try:
                resp = requests.get(f"{self.base_url}/settings/sharing",
                                  timeout=10, verify=False)

                if resp.status_code == 200 and indicator.lower() in resp.text.lower():
                    self.findings.append({
                        "type": "OVERLY_PERMISSIVE_SHARING",
                        "indicator": indicator,
                        "severity": "HIGH"
                    })
                    print(f"  [!] Permissive sharing detected: {indicator}")

            except requests.RequestException:
                continue

    def generate_report(self):
        """Generate CRM security report."""
        report = {
            "target": self.base_url,
            "total_findings": len(self.findings),
            "findings": self.findings,
            "recommendations": [
                "Implement least-privilege access for CRM users",
                "Enable MFA for all CRM administrator accounts",
                "Audit CRM sharing rules quarterly",
                "Monitor data export activities",
                "Review API access tokens regularly",
                "Train staff on CRM security best practices"
            ]
        }
        return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python crm_test.py <base_url>")
        sys.exit(1)

    tester = CRMSecurityTest(sys.argv[1])
    tester.test_crm_discovery()
    tester.test_api_exposure()
    tester.test_data_export_controls()
    tester.test_sharing_rules()

    report = tester.generate_report()
    print(f"\n[*] CRM Security Assessment Complete")
    print(f"    Findings: {report['total_findings']}")

    with open("crm_security_report.json", "w") as f:
        json.dump(report, f, indent=2)
```

### Phase 3: Exploitation (Days 6-8)

```
Non-Profit Exploitation Pathways
==================================

 Initial Access
      |
      v
 +----+----+     +----------------+     +----------------+
 | Phishing |     | WordPress      |     | Donor Form     |
 | (Donor/  |     | Compromise     |     | Manipulation   |
 |  Staff)  |     | (Plugin vuln)  |     |                |
 +----+-----+     +-------+--------+     +-------+--------+
      |                    |                      |
      v                    v                      v
 +----+----+     +---------+--------+    +--------+--------+
 | Email    |     | Website          |    | Payment         |
 | Account  |     | Defacement       |    | Fraud           |
 | Takeover |     | (Reputation)     |    | (Donor theft)   |
 +----+-----+     +---------+--------+    +--------+--------+
      |                    |                      |
      v                    v                      v
 +----+----+     +---------+--------+    +--------+--------+
 | CRM      |     | Donor Data       |    | Financial       |
 | Access   |     | Exfiltration     |    | Impact          |
 | (Full)   |     | (PII breach)     |    | (Donor loss)    |
 +----------+     +------------------+    +-----------------+
```

#### Step 3.1: WordPress Security Testing

```python
#!/usr/bin/env python3
"""WordPress Security Testing for Non-Profit Websites"""

import requests
import json

class WordPressTest:
    """WordPress security testing for non-profit websites."""

    def __init__(self, base_url):
        self.base_url = base_url.rstrip("/")
        self.findings = []

    def test_wp_version_disclosure(self):
        """Test for WordPress version disclosure."""
        print("[*] Testing WordPress version disclosure...")

        version_paths = [
            "/feed/", "/comments/feed/",
            "/wp-includes/css/buttons.min.css",
            "/wp-includes/js/jquery/jquery.min.js",
            "/readme.html", "/license.txt",
            "/?xmlrpc.php",
        ]

        for path in version_paths:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False)

                if resp.status_code == 200:
                    # Check for version strings
                    import re
                    version_match = re.search(r'ver=(\d+\.\d+\.\d+)', resp.text)
                    if version_match:
                        version = version_match.group(1)
                        self.findings.append({
                            "type": "WP_VERSION_DISCLOSURE",
                            "version": version,
                            "path": path,
                            "severity": "LOW"
                        })
                        print(f"  [+] WordPress version: {version}")
                        break

            except requests.RequestException:
                continue

    def test_plugin_vulnerabilities(self):
        """Test for vulnerable plugins."""
        print("[*] Testing for vulnerable plugins...")

        common_plugins = [
            "contact-form-7", "elementor", "woocommerce",
            "wordfence", "yoast-seo", "akismet",
            "jetpack", "wpforms-lite", "classic-editor",
            "updraftplus", "really-simple-ssl",
            "donorbox", "classy", "give",
            "charitable", "wp-donations",
        ]

        for plugin in common_plugins:
            readme_path = f"/wp-content/plugins/{plugin}/readme.txt"
            try:
                resp = requests.get(f"{self.base_url}{readme_path}",
                                  timeout=10, verify=False)

                if resp.status_code == 200:
                    # Extract version from readme
                    import re
                    version_match = re.search(r'Stable tag:\s*(\S+)',
                                            resp.text, re.IGNORECASE)
                    if version_match:
                        version = version_match.group(1)
                        self.findings.append({
                            "type": "PLUGIN_DETECTED",
                            "plugin": plugin,
                            "version": version,
                            "severity": "INFO"
                        })
                        print(f"  [+] Plugin: {plugin} v{version}")

            except requests.RequestException:
                continue

    def test_xmlrpc(self):
        """Test XML-RPC endpoint."""
        print("[*] Testing XML-RPC endpoint...")

        try:
            resp = requests.get(f"{self.base_url}/xmlrpc.php",
                              timeout=10, verify=False)

            if resp.status_code == 200 and "XML-RPC server accepts POST requests" in resp.text:
                self.findings.append({
                    "type": "XMLRPC_ENABLED",
                    "path": "/xmlrpc.php",
                    "severity": "MEDIUM",
                    "description": "XML-RPC enabled - potential brute force vector"
                })
                print(f"  [!] XML-RPC enabled")

        except requests.RequestException:
            pass

    def test_rest_api_exposure(self):
        """Test REST API exposure."""
        print("[*] Testing REST API exposure...")

        api_paths = [
            "/wp-json/wp/v2/users",
            "/wp-json/wp/v2/posts",
            "/wp-json/wp/v2/pages",
            "/wp-json/wp/v2/media",
            "/wp-json/wp/v2/settings",
        ]

        for path in api_paths:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False)

                if resp.status_code == 200:
                    try:
                        data = resp.json()
                        if isinstance(data, list) and len(data) > 0:
                            self.findings.append({
                                "type": "WP_REST_API_EXPOSED",
                                "path": path,
                                "items_count": len(data),
                                "severity": "MEDIUM"
                            })
                            print(f"  [!] REST API exposed: {path} ({len(data)} items)")
                    except json.JSONDecodeError:
                        pass

            except requests.RequestException:
                continue

    def test_file_upload_security(self):
        """Test file upload security."""
        print("[*] Testing file upload security...")

        upload_paths = [
            "/wp-admin/media-new.php",
            "/wp-admin/upload.php",
            "/wp-json/wp/v2/media",
        ]

        for path in upload_paths:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False)

                if resp.status_code in [200, 302]:
                    self.findings.append({
                        "type": "UPLOAD_ENDPOINT_FOUND",
                        "path": path,
                        "severity": "MEDIUM"
                    })
                    print(f"  [!] Upload endpoint: {path}")

            except requests.RequestException:
                continue

    def test_admin_access(self):
        """Test admin access controls."""
        print("[*] Testing admin access controls...")

        admin_paths = [
            "/wp-admin/", "/wp-login.php",
            "/wp-admin/user-new.php",
            "/wp-admin/options-general.php",
            "/wp-admin/plugins.php",
        ]

        for path in admin_paths:
            try:
                resp = requests.get(f"{self.base_url}{path}",
                                  timeout=10, verify=False,
                                  allow_redirects=False)

                if resp.status_code == 200:
                    self.findings.append({
                        "type": "ADMIN_ACCESSIBLE",
                        "path": path,
                        "status_code": resp.status_code,
                        "severity": "MEDIUM"
                    })
                    print(f"  [!] Admin accessible: {path}")

            except requests.RequestException:
                continue

    def generate_report(self):
        """Generate WordPress security report."""
        report = {
            "target": self.base_url,
            "total_findings": len(self.findings),
            "findings": self.findings,
            "recommendations": [
                "Keep WordPress core, themes, and plugins updated",
                "Disable XML-RPC if not needed",
                "Restrict REST API access to authenticated users",
                "Implement strong password policy for admin accounts",
                "Enable two-factor authentication for admin users",
                "Use security plugins (Wordfence, Sucuri, iThemes)",
                "Implement Web Application Firewall (WAF)",
                "Regular security scans and monitoring",
                "Disable file editing in wp-config.php",
                "Implement proper file upload restrictions"
            ]
        }
        return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python wp_test.py <base_url>")
        sys.exit(1)

    tester = WordPressTest(sys.argv[1])
    tester.test_wp_version_disclosure()
    tester.test_plugin_vulnerabilities()
    tester.test_xmlrpc()
    tester.test_rest_api_exposure()
    tester.test_file_upload_security()
    tester.test_admin_access()

    report = tester.generate_report()
    print(f"\n[*] WordPress Security Assessment Complete")
    print(f"    Findings: {report['total_findings']}")

    with open("wordpress_report.json", "w") as f:
        json.dump(report, f, indent=2)
```

### Phase 4: Analysis and Reporting (Days 9-10)

```
Non-Profit Reporting Framework
================================

 Impact Assessment Factors
 +---------------------------+
 | Donor Trust Impact        |  Breach erodes donor confidence
 | Mission Disruption        |  Programs interrupted
 | Regulatory Consequences   |  PCI, GDPR, CCPA fines
 | Financial Impact          |  Direct loss + remediation
 | Reputational Damage       |  Media coverage, social media
 | Beneficiary Harm          |  Vulnerable populations affected
 +---------------------------+

 Risk Prioritization
 +---------------------------+
 | CRITICAL                  |  Active breach, ransomware
 | HIGH                      |  PII exposure, financial fraud
 | MEDIUM                    |  Weak controls, misconfig
 | LOW                       |  Best practice gaps
 | INFO                      |  Recommendations
 +---------------------------+
```

---

## 5. Tool Arsenal

### Web Application Testing

```bash
# WordPress security scanning
wpscan --url <target> --enumerate vp,vt,u
nuclei -u <target> -t nuclei-templates/ -severity critical,high

# Directory fuzzing for donation forms
ffuf -u <target>/FUZZ -w donation_paths.txt -mc 200,301,302

# CMS detection
whatweb <target>
wappalyzer <target>
```

### Email Security

```bash
# Email security analysis
checkdmarc <domain>
swaks --to test@<domain> --from sender@<domain> --server <domain>:25

# SPF/DKIM/DMARC checks
dmarc-analyzer <domain>
```

### CRM/API Testing

```bash
# API endpoint discovery
ffuf -u <target>/api/FUZZ -w api_endpoints.txt -mc 200

# Salesforce API testing
curl -H "Authorization: Bearer <token>" <instance>/services/data/v52.0/

# Authentication testing
hydra -l user@domain -P passwords.txt <target> https-post-form
```

### Social Engineering

```bash
# Social media reconnaissance
sherlock <username>
holehe <email>

# Domain spoofing check
lookalike-domains <domain>
```

---

## 6. Real-World Examples

### Example 1: Non-Profit Ransomware Attack

```
Scenario:
- Community health non-profit with 50 employees
- Ransomware encrypted all files including donor data
- No backups, no incident response plan

Attack Path:
1. Phishing email to finance director
2. Malicious attachment executed
3. Ransomware spread to file shares
4. Backup systems also encrypted

Impact:
- $250,000 ransom demand
- 3 months of operational disruption
- 10,000 donor records exposed
- 20% donor base lost due to trust erosion

Lessons Learned:
- Implement immutable backups
- Deploy email security gateway
- Create incident response plan
- Conduct regular security training
```

### Example 2: Donation Form Fraud

```
Scenario:
- International aid organization
- Donation form vulnerable to amount manipulation
- Attacker submitted thousands of $0.01 donations
- Each donation triggered credit card processing fees

Attack Path:
1. Identified donation form without amount validation
2. Scripted thousands of minimal donations
3. Credit card fees exceeded donation amounts
4. Organization lost money on each transaction

Impact:
- $15,000 in credit card processing fees
- Donor data exposure risk
- Reputational damage

Lessons Learned:
- Implement minimum donation amount
- Add CAPTCHA to donation forms
- Monitor for unusual transaction patterns
- Validate amounts server-side
```

### Example 3: CRM Data Breach via Volunteer Access

```
Scenario:
- Environmental advocacy organization
- Volunteer given full CRM admin access
- Volunteer's personal email compromised
- Attacker accessed complete donor database

Attack Path:
1. Volunteer's Gmail account phished
2. CRM credentials found in email
3. Full admin access to Salesforce NPSP
4. Exported 50,000 donor records
5. Data sold on dark web

Impact:
- GDPR violation (EU donors)
- $100,000 in potential fines
- Donor trust severely damaged
- Board member resignations

Lessons Learned:
- Implement least-privilege access
- Enable MFA for all CRM access
- Monitor for bulk data exports
- Regular access reviews
```

---

## 7. Bypass Techniques

### 7.1 PCI Bypass Techniques

```
PCI Compliance Bypass in Non-Profit Context
============================================

 [1] Redirect-based Payment Processing
     - Donation form redirects to third-party processor
     - Organization claims "not PCI compliant" (outsourced)
     - Risk: Still responsible for page security

 [2] iframe Embedding
     - Payment fields embedded via iframe
     - Processor handles card data
     - Risk: Page manipulation, formjacking

 [3] API Token Exposure
     - Stripe/PayPal publishable keys in page source
     - Test keys used in production
     - Risk: Account enumeration, test mode abuse

 [4] Webhook Validation Gaps
     - Payment webhooks without signature verification
     - Successful payment confirmation manipulated
     - Risk: Fraudulent donation confirmation
```

### 7.2 Social Engineering Vectors

```python
#!/usr/bin/env python3
"""Non-Profit Social Engineering Test Vectors"""

class NonProfitSocialEng:
    """Social engineering test vectors for non-profits."""

    VECTORS = [
        {
            "name": "Donor Impersonation",
            "target": "Finance staff",
            "pretext": "Major donor requesting urgent wire transfer",
            "impact": "Direct financial loss",
            "mitigation": "Verification procedures for large transfers"
        },
        {
            "name": "Board Member Impersonation",
            "target": "IT staff",
            "pretext": "Board member requesting emergency system access",
            "impact": "Unauthorized system access",
            "mitigation": "Formal access request process"
        },
        {
            "name": "Grant Agency Spoofing",
            "target": "Program directors",
            "pretext": "Fake grant agency requesting data",
            "impact": "Data exfiltration",
            "mitigation": "Verify agency contact information"
        },
        {
            "name": "Volunteer Recruitment",
            "target": "HR/Volunteer coordinators",
            "pretext": "Fake volunteer requesting system access",
            "impact": "Unauthorized access",
            "mitigation": "Background checks, limited access"
        },
        {
            "name": "Vendor Impersonation",
            "target": "IT staff",
            "pretext": "IT vendor requesting credentials for 'maintenance'",
            "impact": "Credential theft",
            "mitigation": "Vendor verification procedures"
        },
        {
            "name": "Social Media Account Recovery",
            "target": "Communications staff",
            "pretext": "Platform support requesting account details",
            "impact": "Social media account compromise",
            "mitigation": "Platform account security settings"
        }
    ]

    def generate_phishing_templates(self):
        """Generate phishing test templates for non-profits."""
        templates = [
            {
                "subject": "Urgent: Donor Database Backup Required",
                "pretext": "Critical security update requires immediate action",
                "cta": "Click here to update database credentials"
            },
            {
                "subject": "Grant Deadline Extension - Action Required",
                "pretext": "Federal grant agency requires updated information",
                "cta": "Login to grant portal to update details"
            },
            {
                "subject": "Volunteer Hour Tracking System Maintenance",
                "pretext": "System requires password reset for all users",
                "cta": "Reset your password now"
            }
        ]
        return templates

    def generate_report(self):
        """Generate social engineering assessment report."""
        report = {
            "vectors_tested": len(self.VECTORS),
            "vectors": self.VECTORS,
            "recommendations": [
                "Implement multi-factor authentication",
                "Establish verbal verification for financial requests",
                "Create formal access request procedures",
                "Conduct regular security awareness training",
                "Implement email authentication (SPF/DKIM/DMARC)",
                "Establish vendor verification procedures"
            ]
        }
        return report

if __name__ == "__main__":
    se = NonProfitSocialEng()
    report = se.generate_report()
    print(json.dumps(report, indent=2))
```

---

## 8. Common Pitfalls

### 8.1 Testing Pitfalls

```
Common Mistakes in Non-Profit Testing
=======================================

 [1] IGNORING BUDGET CONSTRAINTS
     - Recommending expensive enterprise solutions
     - Mitigation: Prioritize free/open-source alternatives
     - Focus: Cost-effective security improvements

 [2] DISRUPTING FUNDRAISING CAMPAIGNS
     - Testing during active fundraising drives
     - Mitigation: Coordinate testing windows
     - Impact: Lost donations = lost mission funding

 [3] UNDERESTIMATING VOLUNTEER RISK
     - Assuming volunteers are "trusted"
     - Mitigation: Test volunteer access thoroughly
     - Reality: Volunteers have high turnover, low training

 [4] OVERLOOKING BOARD MEMBER ACCESS
     - Board members with excessive privileges
     - Mitigation: Test board member account security
     - Risk: Personal email compromise = org compromise

 [5] IGNORING SHARED CREDENTIALS
     - Staff sharing login credentials
     - Mitigation: Test with known shared accounts
     - Common in resource-constrained environments

 [6] MISSING SHADOW IT
     - Free tools adopted without IT knowledge
     - Mitigation: Enumerate all SaaS subscriptions
     - Reality: Staff use personal accounts for org business

 [7] FORGETTING GRANT COMPLIANCE
     - Federal grant data protection requirements
     - Mitigation: Verify compliance with grant terms
     - Risk: Loss of federal funding
```

---

## 9. Reporting Template

```
NON-PROFIT SECURITY ASSESSMENT REPORT
=======================================

Document Information:
- Organization: [Non-Profit Name]
- EIN: [Tax ID]
- Assessment Period: [Start Date] - [End Date]
- Assessor: [Your Name/Organization]
- Classification: CONFIDENTIAL

---

EXECUTIVE SUMMARY

[2-3 paragraph summary tailored for board members and
executive leadership. Focus on donor trust, mission
impact, and cost-effective remediation.]

OVERALL RISK RATING: [CRITICAL / HIGH / MEDIUM / LOW]

KEY METRICS:
- Total Findings: [N]
- Critical: [N] | High: [N] | Medium: [N] | Low: [N]
- Estimated Remediation Cost: $[N]
- Potential Breach Cost: $[N]

---

DONOR TRUST IMPACT

[Assessment of how findings affect donor confidence
and organizational reputation]

---

SCOPE AND METHODOLOGY

Scope:
- Website and donation processing
- CRM and donor management systems
- Email and communication systems
- File sharing and collaboration tools
- Social media accounts

Methodology:
- Web application security testing
- Network vulnerability assessment
- Social engineering evaluation
- Configuration review

---

FINDINGS

[For each finding, include:]

FINDING #[N]: [Title]
Severity: [Level] | CVSS: [Score]
Affected System: [System]

Description: [Clear explanation]
Business Impact: [Mission/donor/fund impact]
Evidence: [Screenshots, technical details]
Remediation: [Step-by-step fix with cost estimate]

---

COST-BENEFIT ANALYSIS

+------------------+------------------+------------------+
| Finding          | Fix Cost (Est.)  | Risk if Unfixed  |
+------------------+------------------+------------------+
| [Finding 1]      | $500             | $50,000          |
| [Finding 2]      | $0 (config)      | $25,000          |
| [Finding 3]      | $2,000           | $100,000         |
+------------------+------------------+------------------+

---

REMEDIATION ROADMAP

Phase 1 - Immediate (0-30 days): $[Budget]
- [Critical findings]

Phase 2 - Short-term (30-90 days): $[Budget]
- [High findings]

Phase 3 - Long-term (90-180 days): $[Budget]
- [Medium findings + strategic improvements]

---

COMPLIANCE CHECKLIST

[ ] PCI DSS compliance verification
[ ] GDPR compliance (if applicable)
[ ] State charitable registration
[ ] Grant agency requirements
[ ] Donor privacy policy review

---

APPENDICES

A. Technical Details
B. Tool Output
C. Scope Documentation
D. Remediation Resources (Free/Open Source)
```

---

## 10. Quick Reference

### Non-Profit Security Checklist

```
DONOR DATA PROTECTION
[ ] PCI DSS compliance verified
[ ] Payment form security tested
[ ] Donor PII encryption at rest
[ ] Donor PII encryption in transit
[ ] Data retention policy enforced
[ ] Donor consent management

WEBSITE SECURITY
[ ] CMS updated (WordPress, etc.)
[ ] Plugins/themes updated
[ ] Admin access restricted
[ ] SSL/TLS properly configured
[ ] Security headers implemented
[ ] Regular backups configured

CRM SECURITY
[ ] Access controls reviewed
[ ] MFA enabled for admins
[ ] Sharing rules audited
[ ] API access monitored
[ ] Data export controls
[ ] Regular access reviews

EMAIL SECURITY
[ ] SPF record configured
[ ] DKIM signing enabled
[ ] DMARC policy enforced
[ ] Phishing awareness training
[ ] Email gateway security

STAFF/VOLUNTEER SECURITY
[ ] Security awareness training
[ ] Strong password policy
[ ] MFA enabled where possible
[ ] Access review procedures
[ ] Offboarding procedures

INCIDENT RESPONSE
[ ] IR plan documented
[ ] Contact list current
[ ] Backup procedures tested
[ ] Communication plan ready
[ ] Insurance coverage verified
```

### Free/Low-Cost Security Tools for Non-Profits

```
Category              Tool                    Cost
--------------------- ----------------------- --------
Email Security        SPF/DKIM/DMARC          Free
Website Security      Wordfence (Basic)       Free
Vulnerability Scan    Nuclei                  Free
Password Manager      Bitwarden               Free
MFA                   Google Authenticator    Free
Backup                Duplicati               Free
Monitoring            Uptime Kuma             Free
Training              KnowBe4 (Non-profit)    Discounted
Incident Response     TheHive                 Free
SIEM                  Wazuh                   Free
```

### Non-Profit Emergency Contacts

```
Role                      Contact                 Phone
------------------------- ----------------------- ----------
Executive Director        [Name]                  [Number]
IT Director/Manager       [Name]                  [Number]
Board Chair               [Name]                  [Number]
Legal Counsel             [Name]                  [Number]
Cyber Insurance           [Carrier]               [Policy#]
PCI Compliance            [QSA Contact]           [Number]
FBI Cyber (IC3)           ic3.gov                 N/A
Identity Theft Center     [Center]                [Number]
```

---

## References

- NTEN (Nonprofit Technology Network) Security Resources
- PCI SSC Small Merchant Guide
- FTC Non-Profit Cybersecurity Resources
- CISA Non-Profit Security Guidance
- NIST Cybersecurity Framework
- GuideStar/Candid Non-Profit Resources
- Better Business Bureau Wise Giving Alliance
- state AG charitable registration requirements
