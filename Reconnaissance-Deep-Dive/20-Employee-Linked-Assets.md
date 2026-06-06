# 20. Employee-Linked Asset Discovery

## Expert Role Definition

You are a specialized security researcher focusing on employee-linked asset discovery for comprehensive reconnaissance. You understand that employees are often the weakest link in an organization's security posture and that their personal assets, professional profiles, and digital footprints can reveal significant information about the organization's infrastructure and security practices. You can discover employee email addresses, analyze their GitHub and GitLab activity, examine their social media presence, fingerprint their devices, and identify personal domains they own. You approach employee-linked asset discovery with the systematic precision of an intelligence analyst and the creative thinking of an attacker. You know that employees often use corporate credentials for personal accounts, reuse passwords across services, and inadvertently expose internal information through public profiles. You maintain expertise in OSINT techniques, email enumeration, code repository analysis, and device fingerprinting. You understand that employee-linked assets are not just individual endpoints but interconnected components of the organization's attack surface. You think like a security researcher who maps human-related attack vectors and like a privacy-conscious individual who understands the implications of employee information disclosure.

## Core Concepts

### Employee Email Discovery

Employee email addresses are the foundation of employee-linked asset discovery.

**Email Format Patterns**: Organizations typically use predictable email formats:
- **First.Last**: john.doe@target.com
- **FirstLast**: johndoe@target.com
- **First.LastInitial**: john.d@target.com
- **FLast**: jdoe@target.com
- **First**: john@target.com

**Email Discovery Techniques**: Multiple techniques exist for discovering employee emails:
- **Social media profiles**: LinkedIn, Twitter, and other platforms often contain email addresses
- **Code repositories**: GitHub and GitLab profiles may contain email addresses in commits
- **Public documents**: Presentations, papers, and documents may contain contact information
- **Email verification services**: Services that verify email address existence

### GitHub/GitLab Analysis

Code repositories reveal significant information about employee activities and organizational infrastructure.

**Repository Analysis**: Employee repositories may contain:
- **Source code**: Application code revealing technology stack and vulnerabilities
- **Configuration files**: Environment files, API keys, and credentials
- **Commit history**: Development patterns, working hours, and internal processes
- **README files**: Documentation revealing project details and dependencies

**Organization Mapping**: GitHub organizations and teams reveal:
- **Team structures**: Developer teams and their responsibilities
- **Project relationships**: Dependencies between projects and repositories
- **Access patterns**: Who has access to which repositories

### Employee Social Media Analysis

Social media profiles reveal personal and professional information.

**Profile Analysis**: Social media profiles contain:
- **Employment history**: Current and previous employers
- **Skills and expertise**: Technical skills and specializations
- **Connections**: Professional and personal networks
- **Activity patterns**: Posting times, topics of interest, and engagement patterns

**Content Analysis**: Social media content reveals:
- **Technology mentions**: Tools, frameworks, and platforms used
- **Security discussions**: Vulnerability discoveries and security practices
- **Project information**: Work projects and achievements
- **Personal interests**: Hobbies, locations, and relationships

### Employee Device Fingerprinting

Employee devices may be identifiable through various techniques.

**Browser Fingerprinting**: Web browsers reveal:
- **User-Agent strings**: Browser version, operating system, and plugins
- **Canvas fingerprinting**: Unique visual rendering characteristics
- **WebGL fingerprinting**: Graphics card and driver information
- **Font fingerprinting**: Installed fonts revealing system configuration

**Network Fingerprinting**: Network characteristics reveal:
- **IP addresses**: Corporate and personal IP addresses
- **DNS requests**: Domain resolution patterns
- **Certificate information**: SSL/TLS certificate details
- **HTTP headers**: Client information and configurations

### Employee-Owned Domains

Employees may own personal domains that reveal additional information.

**Domain Ownership**: Personal domains may reveal:
- **Contact information**: Email addresses and contact details
- **Technology preferences**: Hosting providers, frameworks, and tools
- **Project information**: Personal projects and interests
- **Security practices**: Domain security configurations

**Subdomain Discovery**: Personal domains may contain subdomains revealing:
- **Services**: Email, web hosting, and other services
- **Development environments**: Code repositories and development tools
- **Personal applications**: Home automation, media servers, and other applications

## Pre-requisite Knowledge

Before mastering employee-linked asset discovery, you should understand OSINT techniques and their ethical implications. Knowledge of email protocols and verification methods is essential. Familiarity with code repository platforms and their data structures helps in analysis. Understanding of browser fingerprinting techniques and their limitations is important for device identification.

## Step-by-Step Methodology

### Phase 1: Employee Email Discovery

Discover employee email addresses through multiple sources.

```bash
# Search for email patterns
site:linkedin.com "john.doe@target.com"
site:twitter.com "john.doe@target.com"
site:github.com "john.doe@target.com"

# Search for email formats
site:target.com "@target.com"
filetype:pdf "@target.com"

# Verify email addresses
python3 -c "
import smtplib
import dns.resolver

def verify_email(email):
    domain = email.split('@')[1]
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        mx_host = str(mx_records[0].exchange).rstrip('.')
        server = smtplib.SMTP(mx_host)
        server.ehlo()
        server.mail('test@example.com')
        code, message = server.rcpt(email)
        server.quit()
        return code == 250
    except:
        return False

emails = ['john.doe@target.com', 'jane.smith@target.com']
for email in emails:
    if verify_email(email):
        print(f'[+] Valid: {email}')
    else:
        print(f'[-] Invalid: {email}')
"
```

### Phase 2: GitHub/GitLab Analysis

Analyze employee code repositories for sensitive information.

```bash
# Search for employee repositories
curl -s "https://api.github.com/search/repositories?q=user:john_doe" | jq -r '.items[].full_name'

# Analyze repository contents
curl -s "https://api.github.com/repos/john_doe/repo_name/contents/" | jq -r '.[].name'

# Search for sensitive files
curl -s "https://api.github.com/search/code?q=user:john_doe+filename:.env" | jq -r '.items[].path'

# Analyze commit history
curl -s "https://api.github.com/repos/john_doe/repo_name/commits" | jq -r '.[].commit.message'

# Search for organization members
curl -s "https://api.github.com/orgs/target/members" | jq -r '.[].login'
```

### Phase 3: Employee Social Media Analysis

Analyze employee social media profiles for intelligence.

```bash
# LinkedIn profile analysis
curl -s "https://www.linkedin.com/in/johndoe" -H "User-Agent: Mozilla/5.0"

# Twitter profile analysis
curl -s "https://twitter.com/johndoe" -H "User-Agent: Mozilla/5.0"

# GitHub profile analysis
curl -s "https://api.github.com/users/johndoe" | jq -r '.bio, .company, .location'

# Reddit profile analysis
curl -s "https://www.reddit.com/user/johndoe.json" | jq -r '.data.children[].data'
```

### Phase 4: Employee Device Fingerprinting

Fingerprint employee devices through web interactions.

```bash
# Browser fingerprinting
python3 -c "
import requests
import json

def fingerprint_browser(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    r = requests.get(url, headers=headers)
    return {
        'user_agent': r.headers.get('User-Agent'),
        'server': r.headers.get('Server'),
        'x_powered_by': r.headers.get('X-Powered-By')
    }

result = fingerprint_browser('https://target.com')
print(json.dumps(result, indent=2))
"

# Network fingerprinting
python3 -c "
import socket
import ssl

def fingerprint_network(hostname):
    ip = socket.gethostbyname(hostname)
    context = ssl.create_default_context()
    with socket.create_connection((hostname, 443)) as sock:
        with context.wrap_socket(sock, server_hostname=hostname) as ssock:
            cert = ssock.getpeercert()
            return {
                'ip': ip,
                'certificate': cert
            }

result = fingerprint_network('target.com')
print(result)
"
```

### Phase 5: Employee-Owned Domains Discovery

Discover domains owned by employees.

```bash
# Search for personal domains
site:linkedin.com "john.doe.com"
site:twitter.com "johndoe.com"
site:github.com "johndoe.com"

# Verify domain ownership
python3 -c "
import whois
import socket

def check_domain(domain):
    try:
        w = whois.whois(domain)
        return {
            'domain': domain,
            'registrar': w.registrar,
            'creation_date': w.creation_date,
            'emails': w.emails
        }
    except:
        return None

domains = ['johndoe.com', 'johndoe.net']
for domain in domains:
    result = check_domain(domain)
    if result:
        print(result)
"

# Discover subdomains of personal domains
subfinder -d johndoe.com -o personal_subdomains.txt
```

### Phase 6: Employee Shadow IT Discovery

Discover unauthorized technology usage by employees.

```bash
# Search for personal cloud storage
site:drive.google.com "target.com"
site:dropbox.com "target.com"
site:onedrive.live.com "target.com"

# Search for personal development tools
site:heroku.com "target.com"
site:vercel.com "target.com"
site:netlify.com "target.com"

# Search for personal code repositories
site:github.com "target.com"
site:gitlab.com "target.com"
site:bitbucket.org "target.com"
```

### Phase 7: Employee Asset Correlation

Correlate employee assets across multiple platforms.

```bash
# Correlate email and GitHub
python3 -c "
import requests
import json

# Employee emails
emails = ['john.doe@target.com', 'jane.smith@target.com']

# GitHub search
for email in emails:
    url = f'https://api.github.com/search/users?q={email}'
    r = requests.get(url)
    data = json.loads(r.text)
    for item in data.get('items', []):
        print(f'{email} -> GitHub: {item[\"login\"]}')
"

# Correlate LinkedIn and GitHub
python3 -c "
import requests
import json

# LinkedIn profiles
linkedin_profiles = [
    {'name': 'John Doe', 'github': 'johndoe'},
    {'name': 'Jane Smith', 'github': 'janesmith'}
]

# GitHub analysis
for profile in linkedin_profiles:
    url = f'https://api.github.com/users/{profile[\"github\"]}'
    r = requests.get(url)
    data = json.loads(r.text)
    print(f'{profile[\"name\"]}: {data.get(\"public_repos\", 0)} repos, {data.get(\"followers\", 0)} followers')
"
```

### Phase 8: Employee-Linked Asset Discovery Script

Create comprehensive employee-linked asset discovery script.

```bash
#!/bin/bash
# employee_assets.sh - Employee-linked asset discovery
TARGET=$1
echo "=== Employee-Linked Asset Discovery for $TARGET ==="

# Discover employee emails
echo -e "\n[*] Discovering employee emails..."
curl -s "https://www.google.com/search?q=%40$TARGET+email&num=100" | grep -oE "[a-zA-Z0-9._%+-]+@$TARGET" | sort -u > /tmp/employee_emails.txt
echo "[+] Found $(wc -l < /tmp/employee_emails.txt) unique email addresses"

# Analyze GitHub repositories
echo -e "\n[*] Analyzing GitHub repositories..."
while read email; do
    username=$(echo $email | cut -d'@' -f1)
    curl -s "https://api.github.com/users/$username" | jq -r '.login, .public_repos, .followers' 2>/dev/null
done < /tmp/employee_emails.txt > /tmp/github_analysis.txt

# Search for personal domains
echo -e "\n[*] Searching for personal domains..."
while read email; do
    username=$(echo $email | cut -d'@' -f1)
    curl -s "https://www.google.com/search?q=$username+domain" | grep -oE "https?://$username\.[a-z]+" | sort -u
done < /tmp/employee_emails.txt > /tmp/personal_domains.txt

# Correlate assets
echo -e "\n[*] Correlating assets..."
python3 -c "
import json
emails = open('/tmp/employee_emails.txt').read().splitlines()
domains = open('/tmp/personal_domains.txt').read().splitlines()
print(f'Emails: {len(emails)}')
print(f'Personal domains: {len(domains)}')
"
```

## Tool Arsenal with Exact Commands

### Email Discovery Tools

```bash
# theHarvester
theHarvester -d target.com -b google,linkedin,twitter

# Hunter.io
curl -s "https://api.hunter.io/v2/domain-search?domain=target.com&api_key=YOUR_API_KEY"

# Email format discovery
curl -s "https://www.google.com/search?q=%40target.com+email" | grep -oE "[a-zA-Z0-9._%+-]+@target.com"
```

### GitHub Analysis Tools

```bash
# GitHub API
curl -s "https://api.github.com/search/repositories?q=user:john_doe" | jq -r '.items[].full_name'
curl -s "https://api.github.com/search/code?q=user:john_doe+filename:.env" | jq -r '.items[].path'
curl -s "https://api.github.com/orgs/target/members" | jq -r '.[].login'

# trufflehog for secret scanning
trufflehog git https://github.com/john_doe/repo_name

# gitleaks for secret scanning
gitleaks detect -s /path/to/repo -v
```

### Social Media Analysis Tools

```bash
# Sherlock for username discovery
sherlock john_doe

# SpiderFoot for OSINT
spiderfoot -s target.com -m sfp_socialmedia

# Maltego for social media analysis
maltego -t Person -p "John Doe"
```

### Device Fingerprinting Tools

```bash
# Browser fingerprinting
python3 -c "
import requests
headers = {'User-Agent': 'Mozilla/5.0'}
r = requests.get('https://target.com', headers=headers)
print(f'Server: {r.headers.get(\"Server\")}')
print(f'X-Powered-By: {r.headers.get(\"X-Powered-By\")}')
"

# Network fingerprinting
nmap -sV -p 443 target.com
```

### Domain Discovery Tools

```bash
# Subdomain discovery
subfinder -d johndoe.com -o personal_subdomains.txt

# WHOIS lookup
whois johndoe.com

# DNS enumeration
dig johndoe.com ANY
```

### Python Scripts

```bash
# Employee asset correlation script
python3 -c "
import requests
import json

target = 'target.com'
emails = ['john.doe@target.com', 'jane.smith@target.com']

for email in emails:
    username = email.split('@')[0]
    
    # Check GitHub
    github_url = f'https://api.github.com/users/{username}'
    r = requests.get(github_url)
    if r.status_code == 200:
        data = json.loads(r.text)
        print(f'{email}: GitHub repos={data.get(\"public_repos\", 0)}')
    
    # Check Twitter
    twitter_url = f'https://twitter.com/{username}'
    r = requests.get(twitter_url, headers={'User-Agent': 'Mozilla/5.0'})
    if r.status_code == 200:
        print(f'{email}: Twitter found')
"
```

## Real-World Case Studies

### Case Study 1: Employee GitHub Repository Exposure

During a bug bounty engagement, I discovered that an employee of the target organization had a public GitHub repository containing a clone of the company's internal tool. The repository included configuration files with database credentials and API keys. The employee had accidentally pushed the internal tool to a public repository while trying to create a personal backup. The credentials found in the repository provided access to the company's internal database containing customer information.

### Case Study 2: Employee Email Enumeration Leading to Account Takeover

By analyzing LinkedIn profiles, I discovered the email format used by the target organization. The email format was `firstname.lastname@target.com`. Using this format, I enumerated employee email addresses and attempted password resets on various services. One employee had reused their corporate password on a third-party service that had been compromised. The password reuse allowed access to the employee's corporate email account, which contained sensitive company information.

### Case Study 3: Employee Personal Domain Discovery

Analysis of employee social media profiles revealed that several employees owned personal domains. One employee's personal domain contained a development server with a clone of the company's web application. The development server had debug mode enabled and contained test credentials that were also valid in the production environment. The personal domain was not protected by the company's security infrastructure and was vulnerable to attacks.

### Case Study 4: Employee Shadow IT Discovery

GitHub analysis revealed that employees were using unauthorized third-party services for development. Several repositories contained references to personal cloud storage accounts where company code was being backed up. These accounts were not monitored by the company's security team and contained sensitive source code and configuration files. The shadow IT usage created an unmonitored attack surface outside the company's security controls.

### Case Study 5: Employee Device Fingerprinting

Through careful analysis of HTTP headers and browser fingerprinting, I identified specific employees based on their unique browser configurations. This technique revealed that employees were accessing the company's web application from personal devices that were not managed by the company's IT department. The personal devices had outdated software and security configurations, creating potential entry points for attacks.

## Advanced Techniques and Bypass

### Advanced Email Discovery

Use advanced techniques to discover employee email addresses.

```bash
# Email permutation generation
python3 -c "
import itertools

first_names = ['john', 'jane']
last_names = ['doe', 'smith']
domain = 'target.com'

patterns = [
    '{first}.{last}@{domain}',
    '{first}{last}@{domain}',
    '{first}.{last[0]}@{domain}',
    '{f}{last}@{domain}'
]

for first in first_names:
    for last in last_names:
        for pattern in patterns:
            email = pattern.format(
                first=first,
                last=last,
                f=first[0],
                domain=domain
            )
            print(email)
"

# Email verification
python3 -c "
import smtplib
import dns.resolver

def verify_email(email):
    domain = email.split('@')[1]
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        mx_host = str(mx_records[0].exchange).rstrip('.')
        server = smtplib.SMTP(mx_host)
        server.ehlo()
        server.mail('test@example.com')
        code, message = server.rcpt(email)
        server.quit()
        return code == 250
    except:
        return False
"
```

### Advanced GitHub Analysis

Use advanced techniques to analyze GitHub repositories.

```bash
# Search for sensitive files across all repositories
curl -s "https://api.github.com/search/code?q=org:target+filename:.env" | jq -r '.items[].path'

# Search for credentials in code
curl -s "https://api.github.com/search/code?q=org:target+password" | jq -r '.items[].path'

# Analyze commit history for secrets
trufflehog git https://github.com/target/repo_name

# Search for internal APIs
curl -s "https://api.github.com/search/code?q=org:target+api_key" | jq -r '.items[].path'
```

### Advanced Device Fingerprinting

Use advanced techniques to fingerprint employee devices.

```bash
# Canvas fingerprinting
python3 -c "
import hashlib

def canvas_fingerprint(user_agent):
    return hashlib.md5(user_agent.encode()).hexdigest()

ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
print(f'Canvas fingerprint: {canvas_fingerprint(ua)}')
"

# WebGL fingerprinting
python3 -c "
import hashlib

def webgl_fingerprint(renderer):
    return hashlib.md5(renderer.encode()).hexdigest()

renderer = 'Intel Inc. Intel Iris OpenGL Engine'
print(f'WebGL fingerprint: {webgl_fingerprint(renderer)}')
"
```

### Advanced Employee Asset Correlation

Use advanced techniques to correlate employee assets.

```bash
# Correlate email, GitHub, and LinkedIn
python3 -c "
import requests
import json

# Employee data
employees = [
    {'email': 'john.doe@target.com', 'github': 'johndoe', 'linkedin': 'johndoe'}
]

for emp in employees:
    # GitHub analysis
    github_url = f'https://api.github.com/users/{emp[\"github\"]}'
    r = requests.get(github_url)
    if r.status_code == 200:
        data = json.loads(r.text)
        emp['github_repos'] = data.get('public_repos', 0)
        emp['github_followers'] = data.get('followers', 0)
    
    print(f'{emp[\"email\"]}: {emp}')
"
```

## Detection and Indicators

### Signs of Employee-Linked Asset Discovery

Monitor for the following indicators:
- Queries for employee email addresses
- Analysis of employee code repositories
- Social media profile analysis
- Device fingerprinting attempts

### Detection Methods

Organizations can detect employee-linked asset discovery through:
- Monitoring for email enumeration attempts
- Tracking access to employee public profiles
- Analyzing patterns of employee information queries
- Monitoring for unauthorized device access

## Impact Assessment

### Finding Severity Classification

Employee-linked asset findings should be classified based on information disclosed:
- **High**: Exposed credentials, internal API endpoints, sensitive source code
- **Medium**: Employee email addresses, technology stack details, device information
- **Low**: Public employee information, general technology mentions
- **Informational**: Social media activity patterns, public discussions

## Common Pitfalls

### Not Respecting Employee Privacy

Employee-linked asset discovery must respect employee privacy and legal boundaries. Only collect and analyze publicly available information.

### Ignoring Corporate Policies

Corporate policies may restrict how employee information can be collected and used. Always comply with organizational policies and guidelines.

### Overlooking Data Protection Laws

Data protection regulations like GDPR and CCPA restrict how personal data can be collected and used. Understand and comply with these regulations.

### Not Correlating Multiple Sources

Single-source intelligence is less reliable than correlated multi-source intelligence. Always combine information from multiple sources.

### Forgetting About Ethical Boundaries

Employee-linked asset discovery should be performed ethically, respecting individual privacy and organizational boundaries. Avoid intrusive or harmful intelligence gathering.

## Integration with Other Recon Areas

Employee-linked asset discovery integrates with other reconnaissance activities:
- **Social Media OSINT**: Social media reveals employee information and activities
- **Source Code Leak Detection**: Employee repositories may contain exposed source code
- **Configuration File Extraction**: Employee repositories may contain configuration files
- **API Endpoint Discovery**: Employee code may reveal API endpoints and patterns
- **Technology Stack Fingerprinting**: Employee activities reveal technology choices

## Reporting Template

### Employee-Linked Asset Report

**Executive Summary**: Overview of employee-linked asset discovery activities and findings.

**Methodology**: Description of discovery techniques, tools used, and data collected.

**Findings Summary**:
- Total employees analyzed
- Employee assets discovered
- Sensitive information exposed
- Potential security implications

**Critical/High Findings**:
For each finding:
- Employee information
- Asset type and location
- Sensitive data exposed
- Recommended remediation

## Practice Labs

### Lab 1: Employee Email Discovery

Practice discovering employee email addresses through multiple sources.

### Lab 2: GitHub Repository Analysis

Practice analyzing employee GitHub repositories for sensitive information.

### Lab 3: Social Media Profile Analysis

Practice analyzing employee social media profiles for intelligence.

### Lab 4: Device Fingerprinting

Practice fingerprinting employee devices through web interactions.

### Lab 5: Employee Asset Correlation

Practice correlating employee assets across multiple platforms.

## Ethical Guidelines

Employee-linked asset discovery should only be performed on organizations you own or have authorization to test. Only collect and analyze publicly available information. Respect employee privacy and legal boundaries. Understand and comply with data protection regulations. Report all discovered vulnerabilities through responsible disclosure channels.

## Quick Reference Cheat Sheet

### Email Discovery Commands
```bash
site:linkedin.com "@target.com"
site:twitter.com "@target.com"
site:github.com "@target.com"
```

### GitHub Analysis Commands
```bash
curl -s "https://api.github.com/search/repositories?q=user:john_doe"
curl -s "https://api.github.com/search/code?q=user:john_doe+filename:.env"
curl -s "https://api.github.com/orgs/target/members"
```

### Social Media Analysis Commands
```bash
sherlock john_doe
spiderfoot -s target.com -m sfp_socialmedia
site:linkedin.com "john.doe@target.com"
```

### Device Fingerprinting Commands
```bash
python3 -c "import requests; r = requests.get('https://target.com'); print(r.headers)"
nmap -sV -p 443 target.com
```

### Employee Asset Correlation Commands
```bash
python3 -c "import requests; print(requests.get('https://api.github.com/users/john_doe').json())"
curl -s "https://api.github.com/search/code?q=org:target+password"
```