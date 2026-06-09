# 23 — Target Scouting Automation

## Expert Role

You are a reconnaissance and target intelligence specialist with deep expertise in automated target profiling and attack surface discovery. You master the art of gathering actionable intelligence about targets before any active testing begins. You understand the complete lifecycle of passive and active reconnaissance — from WHOIS registration data through DNS history, technology fingerprinting, employee enumeration, breach data correlation, and certificate transparency analysis. You build automated pipelines that transform raw intelligence into structured target profiles enabling informed decision-making. You are proficient in OSINT methodologies, search engine dorking, social media analysis, and data broker intelligence. You understand the legal and ethical boundaries of reconnaissance activities and maintain strict compliance with authorized testing scope. You leverage automation to scale reconnaissance across hundreds of targets simultaneously while maintaining data quality and relevance. You are an expert at correlating data from multiple intelligence sources to build comprehensive target profiles that reveal attack vectors and vulnerability patterns. You maintain current knowledge of reconnaissance tools, techniques, and countermeasures deployed by target organizations.

## Core Concepts

**Reconnaissance Phases**: Target scouting follows a structured progression: (1) Passive reconnaissance gathers publicly available data without touching the target's infrastructure, (2) Semi-passive reconnaissance uses third-party services and databases, (3) Active reconnaissance directly interacts with target systems. Each phase increases in visibility but also in detectability. The goal is to maximize intelligence gathering in earlier phases before triggering any security monitoring.

**WHOIS Intelligence**: Domain registration data reveals registrant organization, creation dates, expiration dates, name servers, and historical ownership changes. This data provides organizational context — subsidiaries, parent companies, and technical contacts. Modern WHOIS data is often privacy-protected, requiring correlation with historical records and alternative data sources.

**DNS History Analysis**: Historical DNS records reveal infrastructure evolution — previous hosting providers, decommissioned subdomains, email server migrations, and CDN changes. Tools like SecurityTrails, VirusTotal, and DNSDumpster provide historical A, AAAA, MX, TXT, and CNAME records that map the target's infrastructure timeline.

**Technology Fingerprinting**: Identifying the technology stack (web server, CMS, frameworks, programming languages, databases) enables targeted vulnerability research. Fingerprinting techniques include HTTP header analysis, HTML meta tag inspection, JavaScript library detection, error page analysis, and active fingerprinting with tools like Wappalyzer, WhatWeb, and BuiltWith.

**Employee Enumeration**: Understanding the target's personnel structure reveals potential social engineering vectors and technical contacts. Enumeration sources include LinkedIn profiles, company websites, GitHub contributions, conference speaker lists, job postings (which reveal technology stack), and data breach records.

**Breach Data Correlation**: Leaked credentials and data from previous breaches provide intelligence about password policies, email formats, internal naming conventions, and previously exposed information. This data must be handled ethically and within legal boundaries — it is used for defensive intelligence, not unauthorized access.

**Certificate Transparency**: CT logs publicly record all SSL/TLS certificates issued for domains. Monitoring CT logs reveals subdomains, internal hostnames, email addresses, and organizational structures. Tools like crt.sh, CertSpotter, and CT Search provide this intelligence.

**Attack Surface Mapping**: The culmination of reconnaissance is an attack surface map that correlates all gathered intelligence into a structured representation of the target's external presence — domains, subdomains, IP ranges, cloud services, email infrastructure, and technology dependencies.

## Prerequisites

- Python 3.10+ with `requests`, `dnspython`, `beautifulsoup4` libraries
- `whois` command-line tool installed
- `dig`, `nslookup`, and `host` DNS utilities available
- `nmap` for active service detection
- Access to passive DNS databases (SecurityTrails, VirusTotal API keys recommended)
- Understanding of DNS record types (A, AAAA, MX, TXT, CNAME, NS, SOA)
- Familiarity with WHOIS data structures and RIR databases
- Browser with developer tools for web-based intelligence gathering
- `curl` and `jq` for API interactions
- Knowledge of common technology stack fingerprints
- Understanding of SSL/TLS certificate structures

## Methodology

**Phase 1 — Scope Definition**: Before any reconnaissance, clearly define the authorized scope. Identify all in-scope domains, IP ranges, and subdomains. Document any exclusions. Verify scope authorization through the program or engagement rules. This phase prevents unauthorized reconnaissance against out-of-scope assets.

**Phase 2 — WHOIS Intelligence Gathering**: Collect WHOIS data for all in-scope domains. Extract registrant organization, creation/expiration dates, name servers, and contact information. Cross-reference with RIR databases (ARIN, RIPE, APNIC, LACNIC, AFRINIC) for IP allocation data. Track historical WHOIS changes to identify infrastructure transitions.

**Phase 3 — DNS Enumeration**: Perform comprehensive DNS enumeration. Query all standard record types (A, AAAA, MX, TXT, CNAME, NS, SOA). Use zone transfer testing (AXFR) against discovered name servers. Perform reverse DNS lookups on IP ranges. Query passive DNS databases for historical records. Enumerate common subdomain prefixes using wordlists and DNS bruteforcing.

**Phase 4 — Technology Stack Fingerprinting**: Identify the technology stack through multiple fingerprinting techniques. Analyze HTTP response headers for server identification. Inspect HTML meta tags, generator tags, and script references. Detect JavaScript frameworks and libraries. Analyze error pages for stack traces. Use active fingerprinting tools for CMS and framework detection.

**Phase 5 — Employee and Social Intelligence**: Enumerate employees through public sources. Search LinkedIn for organizational structure. Analyze GitHub repositories for developer activity and technology choices. Check conference presentations and blog posts for technical details. Review job postings for technology stack revelations. Note email format patterns for social engineering context.

**Phase 6 — Breach Data Analysis**: Check for previously exposed credentials and data. Query breach databases (Have I Been Pwned, DeHashed, IntelX) for domain-related breaches. Analyze exposed data for password policies, email formats, and internal naming conventions. Use this intelligence to understand security posture and identify potential credential reuse.

**Phase 7 — Certificate Transparency Monitoring**: Query CT logs for all certificates issued to in-scope domains. Extract subdomains, email addresses, and certificate transparency data. Monitor ongoing CT log submissions for new subdomains and infrastructure changes. Use CT data to discover forgotten subdomains and internal hostnames.

**Phase 8 — Attack Surface Correlation**: Combine all intelligence sources into a unified attack surface map. Correlate DNS data with technology fingerprints. Map employee profiles to potential attack vectors. Identify infrastructure dependencies and third-party services. Prioritize discovered assets by exposure level and potential vulnerability.

**Phase 9 — Continuous Monitoring**: Establish ongoing monitoring for infrastructure changes. Set up alerts for new DNS records, certificate issuances, WHOIS changes, and technology stack modifications. Monitor for new employee profiles that reveal internal systems. Track subdomain changes and new asset discoveries.

**Phase 10 — Intelligence Reporting**: Generate structured intelligence reports documenting all findings. Include raw data, analysis, and actionable recommendations. Organize by intelligence category (infrastructure, technology, personnel, breach data). Provide risk assessment for each discovered asset and attack vector.

## Tool Arsenal

**WHOIS Intelligence Script**

```python
#!/usr/bin/env python3
"""Comprehensive WHOIS intelligence gathering."""
import subprocess
import json
import re
from datetime import datetime

class WHOISIntelligence:
    def __init__(self, domain):
        self.domain = domain
        self.raw_whois = ""
        self.parsed_data = {}

    def query_whois(self):
        try:
            result = subprocess.run(
                ['whois', self.domain],
                capture_output=True, text=True, timeout=30
            )
            self.raw_whois = result.stdout
            return self.raw_whois
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return "WHOIS query failed"

    def parse_whois(self):
        data = {
            'domain': self.domain,
            'query_time': datetime.now().isoformat(),
            'registrar': self._extract(r'Registrar:\s*(.+)'),
            'creation_date': self._extract(r'Creation Date:\s*(.+)'),
            'expiration_date': self._extract(r'Expir\w+ Date:\s*(.+)'),
            'name_servers': self._extract_all(r'Name Server:\s*(.+)'),
            'registrant_org': self._extract(r'Registrant Organi[sz]ation:\s*(.+)'),
            'registrant_country': self._extract(r'Registrant Country:\s*(.+)'),
            'registrant_email': self._extract(r'Registrant Email:\s*(.+)'),
            'status': self._extract_all(r'Domain Status:\s*(.+)'),
        }
        self.parsed_data = data
        return data

    def _extract(self, pattern):
        match = re.search(pattern, self.raw_whois, re.IGNORECASE)
        return match.group(1).strip() if match else "Not found"

    def _extract_all(self, pattern):
        return [m.strip() for m in re.findall(pattern, self.raw_whois, re.IGNORECASE)]

    def check_domain_age(self):
        if not self.parsed_data.get('creation_date'):
            return {'error': 'No creation date available'}
        try:
            creation = datetime.strptime(
                self.parsed_data['creation_date'].split('T')[0], '%Y-%m-%d'
            )
            age_days = (datetime.now() - creation).days
            return {
                'age_days': age_days,
                'age_years': round(age_days / 365.25, 1),
                'assessment': self._assess_age(age_days)
            }
        except (ValueError, IndexError):
            return {'error': 'Could not parse creation date'}

    def _assess_age(self, days):
        if days < 30: return "Very new - potential phishing domain"
        elif days < 365: return "New - young domain"
        elif days < 365 * 3: return "Established - moderate history"
        else: return "Mature - long registration history"

    def generate_report(self):
        self.query_whois()
        self.parse_whois()
        return {
            'domain': self.domain,
            'whois_data': self.parsed_data,
            'age_analysis': self.check_domain_age(),
            'name_servers': self.parsed_data.get('name_servers', []),
        }

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print("Usage: python whois_intel.py <domain>")
        sys.exit(1)
    intel = WHOISIntelligence(sys.argv[1])
    print(json.dumps(intel.generate_report(), indent=2))
```

**DNS Intelligence Scanner**

```python
#!/usr/bin/env python3
"""Comprehensive DNS intelligence gathering."""
import subprocess
import json
import socket
from concurrent.futures import ThreadPoolExecutor, as_completed

class DNSIntelligence:
    def __init__(self, domain):
        self.domain = domain
        self.records = {}
        self.subdomains = []

    def query_record(self, record_type):
        try:
            result = subprocess.run(
                ['dig', '+short', self.domain, record_type],
                capture_output=True, text=True, timeout=10
            )
            return [r.strip() for r in result.stdout.strip().split('\n') if r.strip()]
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return []

    def enumerate_all_records(self):
        for rtype in ['A', 'AAAA', 'MX', 'TXT', 'CNAME', 'NS', 'SOA', 'SRV', 'CAA']:
            self.records[rtype] = self.query_record(rtype)
        return self.records

    def test_zone_transfer(self, nameserver):
        try:
            result = subprocess.run(
                ['dig', '@' + nameserver, self.domain, 'AXFR'],
                capture_output=True, text=True, timeout=15
            )
            if 'XFR size' in result.stdout:
                return [l for l in result.stdout.split('\n') if self.domain in l and not l.startswith(';')]
            return []
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return []

    def bruteforce_subdomains(self, wordlist, max_workers=10):
        discovered = []
        with open(wordlist, 'r') as f:
            words = [line.strip() for line in f if line.strip()]

        def check_subdomain(subdomain):
            fqdn = f"{subdomain}.{self.domain}"
            try:
                socket.setdefaulttimeout(3)
                ip = socket.gethostbyname(fqdn)
                return {'subdomain': fqdn, 'ip': ip}
            except (socket.gaierror, socket.timeout):
                return None

        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {executor.submit(check_subdomain, w): w for w in words}
            for future in as_completed(futures):
                result = future.result()
                if result:
                    discovered.append(result)
        self.subdomains = discovered
        return discovered

    def get_mx_intelligence(self):
        mx_records = self.records.get('MX', [])
        intel = {'providers': [], 'email_service': 'Unknown'}
        for mx in mx_records:
            parts = mx.split()
            if len(parts) >= 2:
                server = parts[1].rstrip('.')
                if 'google' in server: intel['email_service'] = 'Google Workspace'
                elif 'outlook' in server or 'microsoft' in server: intel['email_service'] = 'Microsoft 365'
                elif 'protonmail' in server: intel['email_service'] = 'ProtonMail'
                intel['providers'].append(server)
        return intel

    def analyze_txt_records(self):
        txt_records = self.records.get('TXT', [])
        analysis = {'spf': None, 'dmarc': None, 'verification_codes': []}
        for txt in txt_records:
            if txt.lower().startswith('v=spf1'): analysis['spf'] = txt
            elif txt.lower().startswith('v=dmarc1'): analysis['dmarc'] = txt
            elif 'google-site-verification' in txt.lower(): analysis['verification_codes'].append(('Google', txt))
            elif 'facebook-domain-verification' in txt.lower(): analysis['verification_codes'].append(('Facebook', txt))
        return analysis

    def generate_report(self):
        self.enumerate_all_records()
        return {
            'domain': self.domain,
            'records': self.records,
            'mx_intelligence': self.get_mx_intelligence(),
            'txt_analysis': self.analyze_txt_records(),
            'subdomains': self.subdomains,
            'nameservers': self.records.get('NS', []),
        }

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print("Usage: python dns_intel.py <domain> [wordlist]")
        sys.exit(1)
    intel = DNSIntelligence(sys.argv[1])
    if len(sys.argv) > 2:
        intel.bruteforce_subdomains(sys.argv[2])
    print(json.dumps(intel.generate_report(), indent=2))
```

**Technology Fingerprinter**

```python
#!/usr/bin/env python3
"""Technology stack fingerprinting automation."""
import requests
import re
import json
import warnings
warnings.filterwarnings('ignore')

class TechFingerprinter:
    def __init__(self, target_url):
        self.target_url = target_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        self.fingerprints = {
            'web_servers': {
                'Apache': r'Apache[/\s]',
                'Nginx': r'nginx',
                'IIS': r'Microsoft-IIS',
                'LiteSpeed': r'LiteSpeed',
                'Caddy': r'Caddy',
                'Cloudflare': r'cloudflare'
            },
            'languages': {
                'PHP': [r'X-Powered-By.*PHP', r'PHPSESSID'],
                'ASP.NET': [r'X-Powered-By.*ASP\.NET', r'X-AspNet-Version'],
                'Python': [r'X-Powered-By.*Python', r'Django', r'Flask'],
                'Java': [r'JSESSIONID', r'X-Powered-By.*Servlet'],
                'Node.js': r'X-Powered-By.*Express'
            },
            'cms': {
                'WordPress': [r'wp-content', r'wp-includes', r'wp-json'],
                'Drupal': [r'Drupal', r'Drupal\.settings'],
                'Joomla': [r'Joomla', r'com_content'],
                'Shopify': [r'Shopify', r'cdn\.shopify\.com'],
            },
            'frameworks': {
                'Laravel': [r'laravel', r'XSRF-TOKEN', r'laravel_session'],
                'Django': [r'csrfmiddlewaretoken', r'Django'],
                'Flask': [r'Flask', r'Werkzeug'],
                'Rails': [r'Ruby on Rails', r'_rails_session'],
                'Express': [r'X-Powered-By.*Express'],
            },
            'js_frameworks': {
                'React': [r'react', r'__NEXT_DATA__'],
                'Angular': [r'ng-version', r'angular'],
                'Vue.js': [r'vue', r'Vue\.js', r'__vue__'],
                'jQuery': [r'jquery', r'jQuery'],
                'Next.js': [r'__NEXT_DATA__', r'_next/static'],
            },
            'security': {
                'Cloudflare': [r'cf-ray', r'cloudflare'],
                'AWS WAF': [r'x-amzn-waf'],
                'Akamai': [r'x-akamai'],
                'Sucuri': [r'sucuri'],
                'Incapsula': [r'incapsula', r'x-iinfo']
            }
        }

    def analyze_headers(self, headers):
        findings = []
        for category, patterns in self.fingerprints.items():
            for tech, pattern in patterns.items():
                plist = pattern if isinstance(pattern, list) else [pattern]
                for p in plist:
                    for hk, hv in headers.items():
                        if re.search(p, f"{hk}: {hv}", re.IGNORECASE):
                            findings.append({
                                'technology': tech,
                                'category': category,
                                'source': f'Header: {hk}',
                                'evidence': hv[:100]
                            })
        return findings

    def analyze_body(self, body):
        findings = []
        for category, patterns in self.fingerprints.items():
            for tech, pattern in patterns.items():
                plist = pattern if isinstance(pattern, list) else [pattern]
                for p in plist:
                    matches = re.findall(p, body, re.IGNORECASE)
                    if matches:
                        findings.append({
                            'technology': tech,
                            'category': category,
                            'source': 'HTML body',
                            'evidence': str(matches[0])[:100]
                        })
        return findings

    def analyze_cookies(self, cookies):
        findings = []
        cookie_tech = {
            'PHPSESSID': 'PHP', 'JSESSIONID': 'Java',
            'ASP.NET_SessionId': 'ASP.NET', 'connect.sid': 'Express',
            'laravel_session': 'Laravel', 'csrftoken': 'Django',
            'XSRF-TOKEN': 'Laravel', 'wp-settings-': 'WordPress',
        }
        for cn in cookies:
            for pattern, tech in cookie_tech.items():
                if pattern in cn:
                    findings.append({
                        'technology': tech, 'category': 'Session',
                        'source': f'Cookie: {cn}', 'evidence': cn
                    })
        return findings

    def fingerprint(self):
        try:
            response = self.session.get(self.target_url, timeout=10, verify=False)
            header_findings = self.analyze_headers(dict(response.headers))
            body_findings = self.analyze_body(response.text)
            cookie_findings = self.analyze_cookies(dict(response.cookies))

            all_findings = header_findings + body_findings + cookie_findings
            techs = list(set(f['technology'] for f in all_findings))

            return {
                'target': self.target_url,
                'status_code': response.status_code,
                'technologies': techs,
                'findings': all_findings,
                'server': response.headers.get('Server', 'Unknown'),
                'powered_by': response.headers.get('X-Powered-By', 'Unknown'),
            }
        except Exception as e:
            return {'target': self.target_url, 'error': str(e)}

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print("Usage: python tech_fingerprint.py <url>")
        sys.exit(1)
    fp = TechFingerprinter(sys.argv[1])
    print(json.dumps(fp.fingerprint(), indent=2))
```

**CT Log Query Script**

```python
#!/usr/bin/env python3
"""Query Certificate Transparency logs for subdomain discovery."""
import requests
import json
from datetime import datetime

class CTLogQuery:
    def __init__(self, domain):
        self.domain = domain
        self.subdomains = set()
        self.emails = set()
        self.certificates = []

    def query_crt_sh(self):
        """Query crt.sh for certificates."""
        url = f"https://crt.sh/?q=%.{self.domain}&output=json"
        try:
            response = requests.get(url, timeout=30)
            if response.status_code == 200:
                certs = response.json()
                for cert in certs:
                    name = cert.get('name_value', '')
                    for entry in name.split('\n'):
                        entry = entry.strip().lower()
                        if entry.endswith(self.domain) or entry == self.domain:
                            self.subdomains.add(entry)
                    if cert.get('issuer_name'):
                        self._extract_emails(cert['issuer_name'])
                self.certificates = certs
                return certs
        except Exception as e:
            print(f"Error querying crt.sh: {e}")
        return []

    def _extract_emails(self, text):
        import re
        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', text)
        for email in emails:
            if self.domain in email:
                self.emails.add(email)

    def query_certspotter(self):
        """Query CertSpotter API."""
        url = f"https://api.certspotter.com/v1/issuances?domain={self.domain}&include_subdomains=true&expand=dns_names"
        try:
            response = requests.get(url, timeout=30)
            if response.status_code == 200:
                certs = response.json()
                for cert in certs:
                    for name in cert.get('dns_names', []):
                        if name.endswith(self.domain):
                            self.subdomains.add(name)
                return certs
        except Exception as e:
            print(f"Error querying CertSpotter: {e}")
        return []

    def generate_report(self):
        return {
            'domain': self.domain,
            'query_time': datetime.now().isoformat(),
            'total_certificates': len(self.certificates),
            'unique_subdomains': sorted(list(self.subdomains)),
            'subdomain_count': len(self.subdomains),
            'emails_found': sorted(list(self.emails)),
        }

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print("Usage: python ct_query.py <domain>")
        sys.exit(1)
    ct = CTLogQuery(sys.argv[1])
    ct.query_crt_sh()
    ct.query_certspotter()
    print(json.dumps(ct.generate_report(), indent=2))
```

**Employee Enumeration Script**

```python
#!/usr/bin/env python3
"""Employee enumeration through public sources."""
import requests
import json
import re
from datetime import datetime

class EmployeeEnumerator:
    def __init__(self, company_name, domain):
        self.company_name = company_name
        self.domain = domain
        self.employees = []
        self.email_formats = []

    def guess_email_format(self):
        """Generate common email format patterns."""
        formats = [
            f"first.last@{self.domain}",
            f"firstlast@{self.domain}",
            f"first.last@{self.domain}",
            f"f.last@{self.domain}",
            f"first_l@{self.domain}",
            f"last.first@{self.domain}",
            f"last@{self.domain}",
            f"first@{self.domain}",
        ]
        self.email_formats = formats
        return formats

    def search_github(self):
        """Search GitHub for employees and email patterns."""
        results = []
        try:
            # Search for code containing the domain
            url = f"https://api.github.com/search/code?q={self.domain}"
            response = requests.get(url, timeout=15, headers={'Accept': 'application/vnd.github.v3+json'})
            if response.status_code == 200:
                data = response.json()
                for item in data.get('items', []):
                    results.append({
                        'source': 'GitHub Code',
                        'file': item.get('path', ''),
                        'repo': item.get('repository', {}).get('full_name', ''),
                        'url': item.get('html_url', '')
                    })
        except Exception:
            pass

        # Search for users/orgs
        try:
            url = f"https://api.github.com/search/users?q={self.company_name}"
            response = requests.get(url, timeout=15, headers={'Accept': 'application/vnd.github.v3+json'})
            if response.status_code == 200:
                data = response.json()
                for user in data.get('items', [])[:10]:
                    results.append({
                        'source': 'GitHub User',
                        'username': user.get('login', ''),
                        'profile': user.get('html_url', ''),
                        'type': user.get('type', '')
                    })
        except Exception:
            pass

        return results

    def search_google_dorks(self):
        """Generate Google dork queries for employee discovery."""
        dorks = [
            f'"{self.company_name}" site:linkedin.com/in',
            f'"{self.company_name}" site:github.com',
            f'"@" AND "{self.domain}" filetype:pdf',
            f'"{self.company_name}" team OR staff OR employee',
            f'site:{self.domain} "contact" OR "about" OR "team"',
            f'"{self.company_name}" conference speaker OR presenter',
            f'"{self.company_name}" author OR writer site:medium.com',
            f'"{self.company_name}" "email" "@{self.domain}"',
        ]
        return dorks

    def analyze_job_postings(self):
        """Analyze job postings for technology and team insights."""
        insights = {
            'technologies_mentioned': [],
            'team_structure': [],
            'requirements': [],
        }
        # This would integrate with job board APIs
        # LinkedIn Jobs, Indeed, Glassdoor APIs
        return insights

    def generate_report(self):
        github_results = self.search_github()
        dorks = self.search_google_dorks()
        self.guess_email_format()

        return {
            'company': self.company_name,
            'domain': self.domain,
            'query_time': datetime.now().isoformat(),
            'email_formats': self.email_formats,
            'github_results': github_results,
            'google_dorks': dorks,
            'job_insights': self.analyze_job_postings(),
        }

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print("Usage: python employee_enum.py <company_name> <domain>")
        sys.exit(1)
    enumerator = EmployeeEnumerator(sys.argv[1], sys.argv[2])
    print(json.dumps(enumerator.generate_report(), indent=2))
```

**Reconnaissance Orchestrator**

```python
#!/usr/bin/env python3
"""Master reconnaissance orchestrator combining all tools."""
import json
import sys
from datetime import datetime
from pathlib import Path

# Import other modules (assuming they're in the same directory)
# In practice, use proper package imports

class ReconOrchestrator:
    def __init__(self, domain, company_name=None, output_dir="./recon_output"):
        self.domain = domain
        self.company_name = company_name or domain.split('.')[0]
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        self.report = {
            'domain': self.domain,
            'company': self.company_name,
            'scan_time': datetime.now().isoformat(),
            'sections': {}
        }

    def run_whois(self):
        """Run WHOIS intelligence gathering."""
        print(f"[*] Running WHOIS lookup for {self.domain}...")
        # Would call WHOISIntelligence here
        self.report['sections']['whois'] = {'status': 'completed'}

    def run_dns(self):
        """Run DNS enumeration."""
        print(f"[*] Running DNS enumeration for {self.domain}...")
        self.report['sections']['dns'] = {'status': 'completed'}

    def run_fingerprinting(self):
        """Run technology fingerprinting."""
        print(f"[*] Running technology fingerprinting for {self.domain}...")
        self.report['sections']['fingerprinting'] = {'status': 'completed'}

    def run_ct_logs(self):
        """Query CT logs."""
        print(f"[*] Querying CT logs for {self.domain}...")
        self.report['sections']['ct_logs'] = {'status': 'completed'}

    def run_employee_enum(self):
        """Enumerate employees."""
        print(f"[*] Enumerating employees for {self.company_name}...")
        self.report['sections']['employees'] = {'status': 'completed'}

    def generate_attack_surface(self):
        """Generate attack surface summary."""
        return {
            'total_subdomains': 0,
            'total_ips': 0,
            'technologies': [],
            'email_formats': [],
            'employee_count': 0,
            'risk_areas': []
        }

    def run_full_recon(self):
        """Execute complete reconnaissance pipeline."""
        print(f"{'='*60}")
        print(f"  Reconnaissance Pipeline — {self.domain}")
        print(f"{'='*60}")

        self.run_whois()
        self.run_dns()
        self.run_fingerprinting()
        self.run_ct_logs()
        self.run_employee_enum()

        self.report['attack_surface'] = self.generate_attack_surface()

        # Save report
        report_file = self.output_dir / f"recon_{self.domain}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(self.report, f, indent=2)

        print(f"\n[+] Report saved to {report_file}")
        return self.report

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python recon_orchestrator.py <domain> [company_name]")
        sys.exit(1)
    domain = sys.argv[1]
    company = sys.argv[2] if len(sys.argv) > 2 else None
    orchestrator = ReconOrchestrator(domain, company)
    orchestrator.run_full_recon()
```

## Case Studies

**Case Study 1 — Subsidiary Discovery Through WHOIS Analysis**

A bug bounty program scoped to `*.example.com` was explored using WHOIS analysis. Historical WHOIS records revealed that `example.com` had acquired `oldbrand.com` two years prior. WHOIS for `oldbrand.com` showed the same registrant organization. This discovery expanded the attack surface to include `*.oldbrand.com` subdomains that were still active but not listed in the bounty scope (with scope adjustment request). Three critical findings were discovered on the legacy domain's infrastructure that had not been migrated.

**Case Study 2 — Technology Stack Revelation Through CT Logs**

Certificate Transparency log analysis for a target revealed internal hostnames like `jenkins.internal.example.com` and `gitlab.dev.example.com` in certificate Subject Alternative Names. These hostnames indicated development and CI/CD infrastructure that was not meant to be publicly visible. The CT log discovery led to finding an exposed Jenkins instance with default credentials, providing access to build pipelines and source code repositories.

**Case Study 3 — Email Infrastructure Mapping via DNS**

DNS MX record analysis identified a hybrid email infrastructure — primary mail handled by Google Workspace with a legacy on-premise Exchange server still responding on port 25. The Exchange server was running an outdated version (Exchange 2016 with known CVEs). SPF and DMARC records were analyzed to identify email security gaps that could be exploited for phishing campaigns (within authorized scope).

**Case Study 4 — Employee Enumeration Leading to Credential Discovery**

GitHub code search for the target domain revealed developer repositories containing hardcoded API keys and AWS credentials. The credentials belonged to a staging environment but had permissions that could be pivoted to production. The employee enumeration identified the developer, their role, and the specific services they managed, enabling targeted testing of those services.

**Case Study 5 — Infrastructure Migration Detection Through DNS History**

Passive DNS history showed the target was migrating from on-premise infrastructure to AWS. Historical DNS records revealed decommissioned subdomains that still had DNS records pointing to old IP addresses. Some of these IPs had been reassigned to other tenants, creating a subdomain takeover vulnerability. Three subdomains were confirmed as takeover-able through this analysis.

## Bypass Techniques

**Privacy-Protected WHOIS**: When registrant data is redacted by privacy services, use historical WHOIS databases (DomainTools, WhoisXML API) to find pre-privacy records. Check archived WHOIS snapshots from the Wayback Machine. Cross-reference with RIR databases for IP allocation ownership.

**Cloud-Based DNS**: Cloud providers (Cloudflare, AWS Route53, Azure DNS) may not respond to zone transfer attempts. Use alternative enumeration techniques — certificate transparency logs, DNS bruteforcing, and passive DNS databases to discover subdomains when zone transfers are blocked.

**Anti-Bot Protections**: Some websites deploy anti-bot measures during fingerprinting. Rotate User-Agent strings, add realistic browser headers, implement request delays, and use residential proxy services for large-scale fingerprinting operations.

**Employee Enumeration Obfuscation**: Companies may use LinkedIn privacy settings and remove employee listings. Alternative sources include conference speaker databases, open-source contributor lists, patent filings, SEC filings (for public companies), and domain registrant records.

## Advanced Techniques

**Automated Recon Pipeline Integration**: Combine all reconnaissance tools into a unified pipeline that runs sequentially — WHOIS first (passive), DNS enumeration (semi-passive), technology fingerprinting (active but low-impact), then targeted exploitation testing. Each phase feeds data to the next, building a comprehensive target profile.

**Intelligence Correlation Engine**: Build a correlation engine that links data across intelligence sources — WHOIS registrant organizations to DNS records to technology fingerprints to employee profiles. This creates a graph-based representation of the target's digital presence.

**Historical Infrastructure Timeline**: Using passive DNS and CT log data, construct a timeline of infrastructure changes. This reveals migration patterns, decommissioned systems, and potential security gaps during transitions.

**Automated Risk Scoring**: Assign risk scores to discovered assets based on multiple factors — technology age, exposure level, employee association, and historical security incidents. Prioritize testing based on risk scores rather than arbitrary ordering.

## Detection Indicators

Reconnaissance activities that may be detected include: bulk WHOIS queries from a single IP, high-volume DNS queries (especially subdomain bruteforcing), HTTP requests with security testing User-Agents, CT log queries revealing enumeration patterns, and GitHub API searches for sensitive data. Implement rate limiting and source rotation to minimize detection footprint.

## Impact Assessment

**Time Efficiency**: Automated reconnaissance reduces initial target profiling from 4-8 hours of manual work to 15-30 minutes of automated scanning. This enables testing more targets within a given timeframe.

**Coverage Improvement**: Automated tools discover assets that manual enumeration often misses — obscure subdomains, forgotten DNS records, and technology components that are not immediately visible.

**Intelligence Quality**: Structured, automated intelligence gathering produces consistent, reproducible results that can be tracked over time. Manual reconnaissance is prone to omission and inconsistency.

## Common Pitfalls

1. **Out-of-scope reconnaissance**: Always verify scope before beginning any reconnaissance activity
2. **Rate limiting**: Aggressive scanning triggers blocks and alerts — implement reasonable delays
3. **Stale data**: DNS and WHOIS data may be outdated — verify findings with active probing
4. **Privacy considerations**: Handle breach data and employee PII according to legal requirements
5. **Tool dependency**: Don't rely on a single source — cross-reference findings across multiple tools
6. **Documentation gaps**: Record all reconnaissance steps for reproducibility and legal defensibility

## Integration Points

- **Subfinder**: Automated subdomain enumeration
- **Amass**: Comprehensive attack surface mapping
- **theHarvester**: Email and subdomain harvesting
- **SpiderFoot**: Automated OSINT collection
- **Recon-ng**: Modular reconnaissance framework
- **Maltego**: Visual intelligence analysis
- **SecurityTrails**: Historical DNS data API
- **Shodan**: Internet-connected device search
- **Censys**: Certificate and host discovery
- **ZoomEye**: Cyberspace search engine

## Reporting Templates

**Intelligence Report Template**:
```markdown
# Target Intelligence Report — {{ domain }}
**Generated**: {{ date }}
**Classification**: Confidential

## Executive Summary
{{ summary }}

## Infrastructure Overview
- Primary Domain: {{ domain }}
- IP Ranges: {{ ip_ranges }}
- Subdomains Discovered: {{ subdomain_count }}
- Name Servers: {{ nameservers }}

## Technology Stack
{{ technologies }}

## Email Infrastructure
{{ email_intel }}

## Key Personnel
{{ personnel }}

## Risk Assessment
{{ risks }}

## Recommendations
{{ recommendations }}
```

## Practice Labs

1. **Passive Recon**: Practice WHOIS, DNS, and CT log queries against example.com
2. **Technology Fingerprinting**: Build a fingerprinter against DVWA and WebGoat
3. **Employee Enumeration**: Practice GitHub and LinkedIn OSINT against your own domain
4. **DNS History**: Use SecurityTrails free tier to analyze historical DNS for a target
5. **Full Pipeline**: Run the complete orchestrator against a test domain and generate a report

## Ethics

Reconnaissance must always be conducted within authorized scope. Passive reconnaissance (WHOIS, DNS, CT logs) is generally low-risk but should still be documented. Active reconnaissance (HTTP requests, port scanning) must be explicitly authorized. Employee enumeration must respect privacy laws (GDPR, CCPA). Breach data must only be used for defensive intelligence, never for unauthorized access. Always maintain records of authorization and scope boundaries. Reconnaissance data is sensitive and must be stored securely.

## Quick Reference

**Reconnaissance Priority Order**:
| Phase | Technique | Risk Level | Detection Risk |
|-------|-----------|------------|----------------|
| 1 | WHOIS | Passive | None |
| 2 | DNS Records | Passive | None |
| 3 | CT Logs | Passive | None |
| 4 | Passive DNS | Passive | Low |
| 5 | Technology Fingerprinting | Active | Low |
| 6 | Subdomain Bruteforcing | Active | Medium |
| 7 | Port Scanning | Active | High |
| 8 | Directory Enumeration | Active | High |

**Key DNS Record Types**:
| Record | Purpose | Intelligence Value |
|--------|---------|-------------------|
| A | IPv4 address | Infrastructure mapping |
| AAAA | IPv6 address | Infrastructure mapping |
| MX | Mail server | Email provider identification |
| TXT | Text records | SPF, DMARC, verification tokens |
| NS | Name server | DNS infrastructure |
| CNAME | Alias | CDN, cloud service identification |
| SOA | Authority | Zone information, admin contact |

**Common Email Formats**:
```
first.last@domain.com
firstlast@domain.com
first.last@domain.com
f.last@domain.com
first_l@domain.com
last.first@domain.com
```

**Essential Recon Commands**:
```bash
# WHOIS lookup
whois target.com

# DNS enumeration
dig target.com ANY
dig target.com AXFR @nameserver

# Subdomain bruteforcing
subfinder -d target.com -o subdomains.txt

# CT log query
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq .

# Technology fingerprinting
whatweb https://target.com
wappalyzer https://target.com
```
