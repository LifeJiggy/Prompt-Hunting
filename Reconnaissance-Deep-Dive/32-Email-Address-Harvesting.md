# 32 - Email Address Harvesting and Analysis

## Expert Role Definition

You are an expert open-source intelligence (OSINT) analyst specializing in email address discovery, validation, and correlation. Your expertise spans passive reconnaissance techniques for gathering email addresses from public sources, DNS records, web scraping, social media platforms, data breach repositories, and dark web forums. You understand email format conventions across industries, email verification methodologies, and how harvested email addresses serve as pivots for broader reconnaissance including credential stuffing, phishing vector identification, account enumeration, and social engineering attack surface mapping.

Your methodology prioritizes passive collection over active probing, minimizing detection while maximizing yield. You understand the legal and ethical boundaries of email harvesting, including CAN-SPAM, GDPR, and platform-specific terms of service. You maintain proficiency with specialized OSINT tools including theHarvester, holehe, Infoga, and custom scripts for bulk email validation and correlation. Every email address you harvest is cross-referenced across multiple sources for confidence scoring and attribution linkage.

---

## Core Concepts Deep Dive

### Email Address Structure

An email address follows the format `local-part@domain` where:
- **Local-part:** Up to 64 characters, case-sensitive in theory (RFC 5321), commonly case-insensitive in practice. Supports letters, digits, dots, hyphens, underscores, plus signs, and other special characters.
- **@ symbol:** Separator between local-part and domain
- **Domain:** The mail server hostname, must resolve to an MX record or have an A/AAAA record as fallback. Case-insensitive.

**Common Email Formats by Organization:**
```
firstname.lastname@company.com    - Most common corporate format
first.last@company.com            - Same, abbreviated
flast@company.com                 - First initial + last name
firstl@company.com                - First name + last initial
last.first@company.com            - Last name first (some European companies)
firstname@company.com             - First name only (small companies)
first.last+tag@company.com        - Plus addressing (Gmail-style)
f.last@company.com                - First initial dot last initial
```

**Email Address Types:**
1. **Corporate/Business:** Primary email for employees, tied to domain (user@company.com)
2. **Personal:** Free email providers (Gmail, Outlook, Yahoo)
3. **Transactional:** System-generated (noreply@, alerts@, billing@)
4. **Alias/Forwarding:** Virtual addresses forwarding to primary (alias@domain.com → real@other.com)
5. **Role-based:** Department addresses (admin@, info@, support@, sales@)
6. **Disposable:** Temporary addresses (guerrillamail.com, tempmail.com)
7. **Catch-all:** Accepts any local-part (@company.com accepts anything@company.com)

### Email Discovery Vectors

Email addresses appear in numerous public locations:

**Technical Sources:**
- DNS records (MX, SPF, DKIM, DMARC)
- SSL/TLS certificates (SAN fields)
- HTTP headers (From, Server, Contact)
- Web server configuration files
- Database dumps and backups
- API responses and error messages
- Git repositories and version control
- Source code and configuration files
- Log files exposed via misconfigurations

**Web Sources:**
- Contact pages and team directories
- About pages and company profiles
- Blog posts and author bylines
- Documentation and README files
- Terms of service and privacy policies
- Job postings (often contain recruiter emails)
- Press releases and media contacts

**Social Media Sources:**
- LinkedIn profiles and company pages
- Twitter/X profiles and tweets
- GitHub commit history and profile
- Facebook pages and groups
- Professional forums and communities
- Conference speaker listings
- Conference attendee lists (if leaked)

**Data Sources:**
- Public data breaches (HIBP, IntelX)
- Paste sites (pastebin, ghostbin)
- Dark web forums and marketplaces
- WHOIS records (historical)
- Domain registration data
- Marketing databases
- Company filings and regulatory documents

### Email Format Identification

**Pattern Recognition:**
```bash
# Common corporate patterns
firstname.lastname@domain.com     - Pattern: {first}.{last}@domain
flast@domain.com                  - Pattern: {f}{last}@domain
first@domain.com                  - Pattern: {first}@domain
last.first@domain.com             - Pattern: {last}.{first}@domain
first_last@domain.com             - Pattern: {first}_{last}@domain
first-last@domain.com             - Pattern: {first}-{last}@domain
```

**Heuristic Analysis:**
- Examine existing known emails from the organization
- Look for consistency in format across multiple employees
- Consider cultural conventions (some countries use different formats)
- Account for role-based addresses (support@, info@, admin@)
- Check for plus addressing or catch-all configurations

### Email Verification Levels

1. **Syntax Validation:** Check format against RFC 5321 (does it match `user@domain` pattern?)
2. **Domain Validation:** Verify domain exists (DNS MX or A record resolution)
3. **Mailbox Validation:** Verify mailbox exists on mail server (SMTP RCPT TO check)
4. **Deliverability Validation:** Confirm email can receive messages (full SMTP conversation)
5. **Activity Validation:** Confirm email is actively used (social media login, forum activity)
6. **Ownership Validation:** Confirm email belongs to target individual (cross-reference sources)

---

## Pre-requisite Knowledge

1. **DNS fundamentals** — MX, SPF, DKIM, DMARC, TXT record structure and querying methods
2. **SMTP protocol** — HELO, MAIL FROM, RCPT TO commands; understanding of SMTP response codes (250, 550, 452, etc.)
3. **Email validation standards** — RFC 5321 (SMTP), RFC 5322 (message format), RFC 6854 (Mail From address)
4. **Web scraping basics** — HTML parsing, regex for email extraction, JavaScript-rendered content handling
5. **OSINT methodology** — Passive reconnaissance principles, source prioritization, confidence scoring
6. **Data breach understanding** — How breaches are structured, HIBP API, breach correlation techniques
7. **Social media OSINT** — LinkedIn scraping, GitHub commit analysis, Twitter advanced search
8. **Privacy and legal frameworks** — CAN-SPAM Act, GDPR, CCPA, and their implications for email harvesting
9. **Email security technologies** — SPF, DKIM, DMARC, MTA-STS, DANE — how they affect verification
10. **Regex and pattern matching** — Email address regex patterns, bulk extraction techniques, deduplication

---

## Step-by-Step Methodology

### Phase 1: DNS-Based Email Discovery

**Step 1: MX Record Analysis**

```bash
# Discover mail servers for target domain
dig MX target.com +short
dig MX target.com ANY +noall +answer

# Detailed MX record with priority
host -t MX target.com
nslookup -type=MX target.com

# Bulk MX discovery for multiple domains
for domain in target.com target.io target.co; do
  echo "=== $domain ==="
  dig MX $domain +short | sort -n
done
```

**Step 2: SPF Record Analysis**

```bash
# Extract SPF record to find authorized mail senders
dig TXT target.com +short | grep "v=spf1"
host -t TXT target.com | grep "spf"

# Parse SPF for include domains (potential email sources)
dig TXT target.com +short | grep "v=spf1" | grep -oP 'include:\K[^ ]+' | while read inc; do
  echo "Include: $inc"
  dig TXT $inc +short 2>/dev/null
done

# Check for redirect modifiers
dig TXT target.com +short | grep "v=spf1" | grep -oP 'redirect=\K[^ ]+'
```

**Step 3: DMARC Record Analysis**

```bash
# Find DMARC policy (reveals email handling practices)
dig TXT _dmarc.target.com +short

# Extract DMARC policy details
dmarc_record=$(dig TXT _dmarc.target.com +short)
echo "$dmarc_record" | grep -oP 'p=\K[a-z]+'        # Policy (none/quarantine/reject)
echo "$dmarc_record" | grep -oP 'rua=\K[^;]+'       # Reporting URI for aggregate
echo "$dmarc_record" | grep -oP 'ruf=\K[^;]+'       # Reporting URI for forensic
```

**Step 4: DKIM Record Discovery**

```bash
# Try common DKIM selector names
for selector in default google dkim mail selector1 selector2 s1 s2 k1 k2
  sig1 dkim1;
do
  result=$(dig TXT ${selector}._domainkey.target.com +short 2>/dev/null)
  if [ -n "$result" ]; then
    echo "DKIM selector found: ${selector}"
    echo "$result"
  fi
done

# Bulk DKIM discovery
for sel in $(cat /usr/share/seclists/Discovery/DNS/dkim-selectors.txt); do
  result=$(dig TXT ${sel}._domainkey.target.com +short 2>/dev/null)
  if [ -n "$result" ]; then
    echo "DKIM selector: ${sel}"
    echo "  Record: $result"
  fi
done
```

### Phase 2: Web-Based Email Harvesting

**Step 5: Website Email Extraction**

```bash
# Extract emails from target website using regex
curl -s https://target.com | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u

# Recursive crawl for emails
python3 -c "
import re
import requests
from urllib.parse import urljoin, urlparse

def extract_emails(url, depth=0, max_depth=3, visited=None):
    if visited is None:
        visited = set()
    if depth > max_depth or url in visited:
        return set()
    
    visited.add(url)
    emails = set()
    
    try:
        resp = requests.get(url, timeout=10)
        # Extract emails via regex
        found = set(re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', resp.text))
        emails.update(found)
        
        # Find links to crawl
        links = re.findall(r'href=[\"\'](https?://target\.com[^\"\']*)[\"\']\ ', resp.text)
        for link in links[:10]:  # Limit links per page
            emails.update(extract_emails(link, depth+1, max_depth, visited))
    except:
        pass
    
    return emails

emails = extract_emails('https://target.com')
for e in sorted(emails):
    print(e)
"
```

**Step 6: JavaScript-Rendered Email Extraction**

```bash
# Use Playwright for JavaScript-rendered pages
cat > js_email_extractor.py << 'PYEOF'
import asyncio
from playwright.async_api import async_playwright
import re

async def extract_emails_js(url):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto(url, wait_until='networkidle')
        
        # Extract from rendered DOM
        content = await page.content()
        emails = set(re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', content))
        
        # Also check for email links
        mailto_links = await page.eval_on_selector_all('a[href^="mailto:"]', 
            'els => els.map(e => e.href.replace("mailto:", "").split("?")[0])')
        emails.update(mailto_links)
        
        await browser.close()
        return emails

emails = asyncio.run(extract_emails_js('https://target.com/team'))
for e in sorted(emails):
    print(e)
PYEOF
python3 js_email_extractor.py
```

**Step 7: Specialized Page Targeting**

```bash
# Common pages containing email addresses
for path in /contact /contact-us /about /about-us /team /our-team /staff \
            /people /leadership /company /support /help /legal /privacy \
            /terms /imprint /impressum /security /responsible-disclosure; do
  result=$(curl -s "https://target.com${path}" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u)
  if [ -n "$result" ]; then
    echo "=== ${path} ==="
    echo "$result"
  fi
done

# Check robots.txt for disallowed paths that may contain emails
curl -s https://target.com/robots.txt | grep -i "disallow" | awk '{print $2}'
```

### Phase 3: Social Media Email Harvesting

**Step 8: LinkedIn Email Discovery**

```bash
# Use theHarvester for LinkedIn email discovery
theHarvester -d target.com -b linkedin -l 200

# Manual LinkedIn search for email patterns
# Google dork: site:linkedin.com/in "target.com" "@" "target.com"

# LinkedIn company employee enumeration
curl -s "https://www.linkedin.com/company/target-com/people/" \
  -H "User-Agent: Mozilla/5.0" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
```

**Step 9: GitHub Email Discovery**

```bash
# Search GitHub commits for target.com emails
curl -s "https://api.github.com/search/commits?q=author-email:@target.com" \
  -H "Accept: application/vnd.github.cloak-preview+json" | \
  jq '.items[] | {author: .commit.author.name, email: .commit.author.email}'

# Search GitHub for email patterns in code
curl -s "https://api.github.com/search/code?q=@target.com+filename:.env" \
  -H "Accept: application/vnd.github.v3+json" | jq '.items[] | {path: .path, url: .html_url}'

# Use gh CLI for broader search
gh search commits "@target.com" --limit 100 --json author,email
gh search code "@target.com" --limit 100 --json path,repository

# Search git logs locally if repository is cloned
git log --all --format='%ae' | sort -u | grep "target.com"
git log --all --format='%an <%ae>' | grep "target.com" | sort -u
```

**Step 10: Other Social Platforms**

```bash
# Twitter/X advanced search for email patterns
# Google dork: site:twitter.com "@target.com" "email"

# Google dorks for email discovery
site:target.com "@target.com"
site:target.com inurl:contact email
site:target.com filetype:pdf "@target.com"
site:target.com "email" "@" "target.com"
"target.com" "@target.com" -site:target.com

# Use holehe for email account discovery
holehe target-employee@gmail.com --no-unsafe

# Check if email is associated with social media accounts
cat > email_check.py << 'PYEOF'
import requests
import hashlib

def check_email_services(email):
    services = {
        'github': f'https://api.github.com/users/{email.split("@")[0]}',
        'gravatar': f'https://www.gravatar.com/{hashlib.md5(email.encode()).hexdigest()}.json',
    }
    
    for service, url in services.items():
        try:
            resp = requests.get(url, timeout=5)
            if resp.status_code == 200:
                print(f"[+] {service}: {email} - exists")
        except:
            pass

# Check multiple emails
emails = ['employee@target.com', 'admin@target.com']
for email in emails:
    check_email_services(email)
PYEOF
```

### Phase 4: Data Breach Email Discovery

**Step 11: Breach Database Searches**

```bash
# Have I Been Pwned API (requires API key)
curl -H "hibp-api-key: YOUR_API_KEY" \
  "https://haveibeenpwned.com/api/v3/breachedaccount/target-employee@gmail.com"

# Check multiple emails against HIBP
while IFS= read -r email; do
  result=$(curl -s -H "hibp-api-key: YOUR_API_KEY" \
    "https://haveibeenpwned.com/api/v3/breachedaccount/${email}" \
    -G --data-urlencode "truncateResponse=false")
  if [ "$result" != "[]" ] && [ -n "$result" ]; then
    echo "[+] BREACH FOUND: $email"
    echo "$result" | jq '.[].Name' 2>/dev/null
  fi
  sleep 1.5  # Rate limit: 1 request per 1.5 seconds
done < harvested_emails.txt

# IntelX search for emails
python3 -c "
import requests
# Search for target.com emails in IntelX
resp = requests.get('https://2.intelx.io/intelligent/search',
    params={'q': '@target.com', 'maxresults': 100},
    headers={'x-key': 'YOUR_INTELX_API_KEY'})
print(resp.json())
"

# Dehashed search for target.com emails
# Use dehashed API or web interface
```

**Step 12: Paste Site Monitoring**

```bash
# Search paste sites for target.com emails
curl -s "https://pastebin.com/search?q=target.com" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

# Search GitHub gists
curl -s "https://api.github.com/search/code?q=%22target.com%22+@target.com" \
  -H "Accept: application/vnd.github.v3+json" | jq '.items[].html_url'

# Search for leaked credentials
grep -r "target.com" /path/to/breach/databases/ | grep -oP '[a-zA-Z0-9._%+-]+@target\.com[a-zA-Z0-9:/]*' | sort -u
```

### Phase 5: Email Verification

**Step 13: Syntax and Domain Verification**

```bash
# Python email syntax validation
python3 -c "
import re
import dns.resolver

def validate_email(email):
    # RFC 5322 compliant regex
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(pattern, email):
        return False, 'Invalid syntax'
    
    domain = email.split('@')[1]
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        return True, f'Valid - MX: {mx_records[0].exchange}'
    except dns.resolver.NoAnswer:
        try:
            dns.resolver.resolve(domain, 'A')
            return True, 'Valid - A record exists (no MX)'
        except:
            return False, 'Domain has no MX or A record'

# Test emails
emails = ['valid@target.com', 'invalid@nonexistent12345.com', 'badformat@']
for email in emails:
    valid, reason = validate_email(email)
    print(f'{email}: {valid} - {reason}')
"
```

**Step 14: SMTP Verification**

```bash
# SMTP RCPT TO verification (use carefully - may trigger rate limits)
cat > smtp_verify.py << 'PYEOF'
import smtplib
import socket

def verify_email_smtp(email, smtp_server='mx.target.com'):
    try:
        server = smtplib.SMTP(smtp_server, 25, timeout=10)
        server.ehlo('verify.test.com')
        server.mail('verify@test.com')
        code, message = server.rcpt(email)
        server.quit()
        
        if code == 250:
            return True, 'Mailbox exists'
        elif code == 550:
            return False, 'Mailbox does not exist'
        elif code == 452:
            return False, 'Insufficient storage (likely exists)'
        else:
            return None, f'Unknown response: {code} {message}'
    except Exception as e:
        return None, f'Connection error: {str(e)}'

# Verify emails
emails = ['user1@target.com', 'user2@target.com', 'nonexistent@target.com']
for email in emails:
    exists, message = verify_email_smtp(email)
    print(f'{email}: {exists} - {message}')
PYEOF
python3 smtp_verify.py
```

**Step 15: Email Cross-Reference Validation**

```bash
# Cross-reference email across multiple sources
cat > cross_reference.py << 'PYEOF'
import requests
import hashlib

def cross_reference_email(email):
    results = {}
    
    # Gravatar check
    md5_hash = hashlib.md5(email.lower().encode()).hexdigest()
    resp = requests.get(f'https://www.gravatar.com/avatar/{md5_hash}?d=404')
    results['gravatar'] = resp.status_code == 200
    
    # GitHub check
    username = email.split('@')[0]
    resp = requests.get(f'https://api.github.com/users/{username}')
    results['github'] = resp.status_code == 200
    
    # Twitter check (via search)
    # Note: requires authentication for reliable results
    
    # Google search for email presence
    resp = requests.get(f'https://www.google.com/search?q=%22{email}%22',
        headers={'User-Agent': 'Mozilla/5.0'})
    results['google'] = email.lower() in resp.text.lower()
    
    return results

email = 'john.doe@target.com'
results = cross_reference_email(email)
print(f'Email: {email}')
for source, found in results.items():
    print(f'  {source}: {"FOUND" if found else "not found"}')
PYEOF
```

### Phase 6: Bulk Email Collection and Analysis

**Step 16: Automated Email Collection**

```bash
# theHarvester comprehensive scan
theHarvester -d target.com -b all -l 500 -f /tmp/email_report.html

# holehe for email verification against services
while IFS= read -r email; do
  holehe "$email" --no-unsafe 2>/dev/null | grep -i "exists"
done < emails.txt > verified_accounts.txt

# Custom collection script
cat > harvest_emails.sh << 'BASH'
#!/bin/bash
DOMAIN=$1
OUTPUT="emails_${DOMAIN}.txt"

echo "=== Harvesting emails for ${DOMAIN} ==="

# DNS
echo "--- DNS Sources ---"
dig MX $DOMAIN +short | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' >> $OUTPUT
dig TXT $DOMAIN +short | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' >> $OUTPUT

# Web
echo "--- Web Sources ---"
curl -s "https://${DOMAIN}" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' >> $OUTPUT
curl -s "https://${DOMAIN}/contact" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' >> $OUTPUT
curl -s "https://${DOMAIN}/about" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' >> $OUTPUT

# Google dorks
echo "--- Google Dorks ---"
curl -s "https://www.google.com/search?q=site:${DOMAIN}+email+@${DOMAIN}" \
  -H "User-Agent: Mozilla/5.0" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' >> $OUTPUT

# Deduplicate and sort
sort -u $OUTPUT -o $OUTPUT
echo "Total unique emails: $(wc -l < $OUTPUT)"
BASH
chmod +x harvest_emails.sh
./harvest_emails.sh target.com
```

**Step 17: Email Pattern Analysis**

```bash
# Analyze email patterns from known emails
cat > analyze_patterns.py << 'PYEOF'
from collections import Counter
import re

def analyze_email_pattern(emails):
    patterns = []
    for email in emails:
        local, domain = email.split('@')
        # Detect pattern
        if '.' in local:
            parts = local.split('.')
            if len(parts) == 2:
                if len(parts[0]) == 1:
                    patterns.append(f'{parts[0]}{{last}}@{domain}')
                elif len(parts[1]) == 1:
                    patterns.append(f'{{first}}{parts[1]}@{domain}')
                else:
                    patterns.append(f'{{first}}.{{last}}@{domain}')
        elif '_' in local:
            parts = local.split('_')
            patterns.append(f'{{first}}_{{last}}@{domain}')
        elif '-' in local:
            parts = local.split('-')
            patterns.append(f'{{first}}-{{last}}@{domain}')
        else:
            patterns.append(f'{{username}}@{domain}')
    
    counter = Counter(patterns)
    print("Email patterns detected:")
    for pattern, count in counter.most_common():
        print(f"  {pattern}: {count} occurrences")

# Example usage
known_emails = [
    'john.doe@target.com',
    'jane.smith@target.com',
    'bob.jones@target.com',
    'support@target.com',
    'info@target.com'
]
analyze_email_pattern(known_emails)
PYEOF
python3 analyze_patterns.py
```

---

## Tool Arsenal with Exact Commands

### theHarvester

```bash
# Basic email harvesting
theHarvester -d target.com -b google,linkedin,github -l 200

# Full scan with all sources
theHarvester -d target.com -b all -l 500 -f report.html

# Specific source targeting
theHarvester -d target.com -b bing -l 100
theHarvester -d target.com -b crtsh -l 100
theHarvester -d target.com -b dnsdumpster -l 100

# Limit results
theHarvester -d target.com -b google -l 50 -S "prefix"
```

### holehe

```bash
# Check if email is registered on various services
holehe email@target.com --no-unsafe

# Bulk email checking
while IFS= read -r email; do
  holehe "$email" --no-unsafe 2>/dev/null
done < emails.txt

# Check against specific service
holehe email@target.com --only github,linkedin,twitter
```

### Infoga

```bash
# Email OSINT gathering
python3 infoga.py -t target.com -b google,bing,pgp -f csv -o results.csv

# Specific source
python3 infoga.py -t target.com -b google -v
```

### h8mail

```bash
# Check emails against breach databases
h8mail -t emails.txt -b breach_directory_api_key

# With custom config
h8mail -t emails.txt -c config.yaml
```

### Sherlock

```bash
# Find accounts associated with email username
sherlock username_from_email --timeout 10 --print-found
```

### Custom Scripts

```bash
# Email extractor regex patterns
grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt | sort -u

# Bulk email validation
cat > validate_bulk.py << 'PYEOF'
import re
import dns.resolver
import concurrent.futures

def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(pattern, email):
        return email, 'invalid_syntax'
    
    domain = email.split('@')[1]
    try:
        dns.resolver.resolve(domain, 'MX')
        return email, 'valid'
    except:
        try:
            dns.resolver.resolve(domain, 'A')
            return email, 'valid_no_mx'
        except:
            return email, 'invalid_domain'

with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
    emails = [line.strip() for line in open('emails.txt')]
    results = list(executor.map(validate_email, emails))
    
for email, status in results:
    print(f'{email}: {status}')
PYEOF
```

---

## Real-World Case Studies

### Case Study 1: Corporate Email Enumeration via LinkedIn and Data Breaches

**Scenario:** Bug bounty target with no public email addresses on their website. Goal was to identify employee email format for account enumeration.

**Discovery Process:**
1. Used LinkedIn Sales Navigator (free trial) to identify 47 employees at target company
2. Extracted first names and last names from LinkedIn profiles
3. Checked data breaches via HIBP for known employees (found 12 compromised emails)
4. Analyzed email formats from breach data: discovered `{first}.{last}@target.com` format
5. Verified format with email verification tool — 94% of generated emails accepted by mail server
6. Used verified email format for password reset testing — discovered 3 accounts with weak passwords

**Impact:** Account enumeration leading to 3 compromised accounts. CVSS 7.5.

**Key Finding:** The target company used `firstname.lastname@target.com` format consistently. Data breaches from third-party services (LinkedIn, Adobe) contained employee emails in this format, enabling reliable email generation.

### Case Study 2: Email Harvesting from GitHub Commit History

**Scenario:** Technology company with private GitHub repositories. Goal was to discover internal email addresses for social engineering assessment.

**Discovery Process:**
1. Searched GitHub for public repositories belonging to target organization
2. Used `git log --all --format='%ae %an'` on cloned repositories
3. Found 89 unique email addresses in commit history across 12 repositories
4. Discovered 23 emails using non-corporate domains (personal Gmail addresses of employees)
5. Cross-referenced personal emails with HIBP — found 8 employees with breached passwords
6. Used personal email addresses for targeted phishing campaign (authorized test)

**Impact:** Employee enumeration and credential exposure via personal email accounts. CVSS 6.5.

### Case Study 3: Email Format Discovery via Error Messages

**Scenario:** Web application with registration form and login page. No email format visible in public sources.

**Discovery Process:**
1. Tested registration form with various email formats
2. Discovered that registering with existing email returns "email already exists"
3. Used this oracle to enumerate valid email addresses
4. Tried common names: john@, admin@, test@, etc.
5. Found 5 valid email prefixes by observing different error messages
6. Discovered email format: `{first}.{last}@target.com` by combining LinkedIn names with format

**Impact:** Email enumeration enabling targeted attacks. CVSS 5.3.

### Case Study 4: Catch-All Domain Configuration Bypass

**Scenario:** Target domain configured as catch-all (accepts all emails). Standard SMTP verification returned positive for all addresses.

**Discovery Process:**
1. Observed catch-all configuration via SMTP RCPT TO — all addresses returned 250
2. Switched to web-based email discovery (contact pages, team pages)
3. Found 23 emails on the /team page
4. Analyzed email format from known emails
5. Cross-referenced with LinkedIn for employee names
6. Generated email list using discovered format

**Impact:** Bypassed catch-all configuration to discover valid employee emails. CVSS 4.3.

### Case Study 5: Email Breach Correlation for Credential Stuffing

**Scenario:** Large enterprise with multiple acquired companies. Goal was to identify which employees reused passwords across services.

**Discovery Process:**
1. Harvested 500+ email addresses from all subsidiary domains
2. Checked all emails against 15 breach databases via HIBP API
3. Found 127 employees with breached credentials
4. Identified 23 employees with breached passwords on corporate SSO
5. Attempted credential stuffing with breached passwords — 8 successful logins
6. Gained access to internal systems through compromised accounts

**Impact:** Multi-factor authentication bypass via credential reuse. CVSS 8.1.

---

## Advanced Techniques and Bypass

### Catch-All Domain Bypass

```bash
# Detect catch-all configuration
python3 -c "
import smtplib

def is_catch_all(domain, smtp_server=None):
    if not smtp_server:
        smtp_server = f'mx.{domain}'
    
    server = smtplib.SMTP(smtp_server, 25, timeout=10)
    server.ehlo('test.com')
    server.mail('test@test.com')
    
    # Test with random address
    random_email = f'test12345@{domain}'
    code, msg = server.rcpt(random_email)
    server.quit()
    
    return code == 250

if is_catch_all('target.com'):
    print('[!] Domain is catch-all - SMTP verification unreliable')
else:
    print('[+] Domain is not catch-all - SMTP verification reliable')
"

# Alternative: Use email verification services that detect catch-all
# Hunter.io, NeverBounce, ZeroBounce APIs
```

### Email Header Analysis for Discovery

```bash
# Extract emails from email headers (if you have access to email traffic)
cat > parse_headers.py << 'PYEOF'
import email
import re

def extract_from_headers(header_file):
    with open(header_file, 'r') as f:
        msg = email.message_from_string(f.read())
    
    emails = set()
    
    # From header
    from_header = msg.get('From', '')
    found = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', from_header)
    emails.update(found)
    
    # To header
    to_header = msg.get('To', '')
    found = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', to_header)
    emails.update(found)
    
    # Received headers
    for header in msg.get_all('Received', []):
        found = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', header)
        emails.update(found)
    
    # X-headers
    for key, val in msg.items():
        if key.startswith('X-'):
            found = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', val)
            emails.update(found)
    
    return emails

emails = extract_from_headers('email_sample.txt')
print('Emails found:')
for e in sorted(emails):
    print(f'  {e}')
PYEOF
```

### Email Verification via Social Login

```bash
# Check if email is used for social media accounts (without sending emails)
cat > check_social.py << 'PYEOF'
import requests

def check_social_accounts(email):
    username = email.split('@')[0]
    domain = email.split('@')[1]
    
    checks = {
        'GitHub': f'https://api.github.com/users/{username}',
        'Twitter': f'https://api.twitter.com/1.1/users/show.json?screen_name={username}',
        'Gravatar': f'https://www.gravatar.com/avatar/{__import__("hashlib").md5(email.encode()).hexdigest()}?d=404',
    }
    
    results = {}
    for service, url in checks.items():
        try:
            resp = requests.get(url, timeout=5, allow_redirects=False)
            results[service] = resp.status_code == 200
        except:
            results[service] = None
    
    return results

email = 'johndoe@target.com'
results = check_social_accounts(email)
for service, exists in results.items():
    status = 'EXISTS' if exists else ('NOT FOUND' if exists is False else 'ERROR')
    print(f'{service}: {status}')
PYEOF
```

### Advanced Regex Patterns

```bash
# Comprehensive email extraction regex
grep -oP '(?:[a-zA-Z0-9._%+-]+)@(?:[a-zA-Z0-9.-]+)\.(?:[a-zA-Z]{2,})' file.txt

# Exclude common false positives
grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt | \
  grep -vP '\.(png|jpg|gif|css|js|svg|woff|ttf|eot)$' | \
  grep -vP 'example\.(com|org|net)$' | \
  grep -vP 'localhost$' | \
  sort -u

# Extract emails with context
grep -B2 -A2 -P '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt

# Count emails per domain
grep -oP '@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt | sort | uniq -c | sort -rn
```

### Email Verification Service APIs

```bash
# Hunter.io API
curl "https://api.hunter.io/v2/account?api_key=YOUR_KEY"
curl "https://api.hunter.io/v2/email-verifier?email=test@target.com&api_key=YOUR_KEY"

# ZeroBounce API
curl -X POST "https://api.zerobounce.net/v2/validate" \
  -d "email=test@target.com&api_key=YOUR_KEY"

# NeverBounce API
curl -X POST "https://api.neverbounce.com/v4.2/single" \
  -d "key=YOUR_KEY&email=test@target.com"
```

---

## Detection and Indicators

### Indicators of Email Harvesting Activity

| Activity | Detection Method | Indicator |
|----------|-----------------|-----------|
| Bulk MX queries | DNS logs | High volume of MX lookups from single source |
| Website crawling for emails | Web server logs | Rapid requests to contact/about pages |
| LinkedIn scraping | LinkedIn monitoring | Automated access patterns |
| GitHub commit search | GitHub audit logs | API queries for commit authors |
| SMTP verification | Mail server logs | RCPT TO commands for multiple addresses |
| HIBP API queries | API monitoring | Multiple account checks in short period |

### Defensive Indicators

```bash
# Check if your email harvesting is being detected
# Monitor for:
# - Rate limiting on web requests
# - CAPTCHA challenges
# - IP blocking
# - Account suspension on social platforms
# - HIBP API rate limit responses (429 status)

# Implement backoff strategy
cat > safe_harvest.sh << 'BASH'
#!/bin/bash
DELAY=5  # seconds between requests
MAX_RETRIES=3

safe_request() {
    local url=$1
    local retries=0
    
    while [ $retries -lt $MAX_RETRIES ]; do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        
        if [ "$response" = "200" ] || [ "$response" = "301" ] || [ "$response" = "302" ]; then
            curl -s "$url"
            return 0
        elif [ "$response" = "429" ]; then
            echo "[!] Rate limited, waiting..."
            sleep $((DELAY * 2))
            retries=$((retries + 1))
        else
            return 1
        fi
    done
    
    return 1
}
BASH
```

---

## Impact Assessment

| Technique | Impact Level | Detection Difficulty | Value for Recon |
|-----------|-------------|---------------------|-----------------|
| DNS MX/SPF/DMARC Analysis | Low | Very Low | High — reveals mail infrastructure |
| Website Email Harvesting | Low | Low | High — direct employee contact |
| LinkedIn Email Discovery | Medium | Medium | Very High — employee enumeration |
| GitHub Commit Analysis | Low | Low | Very High — personal and work emails |
| Data Breach Correlation | Medium | Medium | Critical — credentials and PII |
| SMTP Verification | Medium | High | High — confirms valid mailboxes |
| Catch-All Bypass | High | High | Very High — validates email format |
| Social Media Cross-Reference | Low | Low | Medium — account linkage |
| Error Message Enumeration | Medium | Medium | High — validates email prefixes |

---

## Common Pitfalls

1. **Assuming all domains have MX records** — Some domains use A records for mail delivery or rely on third-party email services. Always check for A record fallback.

2. **Over-relying on SMTP verification** — Catch-all configurations make SMTP verification unreliable. Use multiple verification methods.

3. **Ignoring disposable email services** — Employees may use disposable emails for testing. Filter out known disposable domains.

4. **Not respecting rate limits** — HIBP, LinkedIn, and other platforms have strict rate limits. Implement delays and respect 429 responses.

5. **Confusing email existence with ownership** — Just because an email exists doesn't mean it belongs to the target person. Cross-reference across sources.

6. **Missing role-based addresses** — Support, admin, and info addresses are often overlooked but may be accessible or have weaker security.

7. **Forgetting email forwarding** — Some emails forward to other addresses. Test forwarding chains for additional discovery.

8. **Not accounting for internationalized emails** — Some domains use internationalized email addresses (IDN). Check for punycode domains.

9. **Overlooking email in metadata** — PDFs, Word documents, and images may contain email addresses in metadata. Use exiftool and pdfparser.

10. **Not validating email format before use** — Generating emails without validating format leads to false negatives. Always verify format consistency.

---

## Integration with Other Recon Areas

### Connection Points

- **21-Subdomain-Discovery** — Each subdomain may have different email formats or catch-all configurations
- **23-Web-Application-Fingerprinting** — CMS and framework detection reveals email handling patterns
- **31-XML-RPC-and-SOAP-Discovery** — XML-RPC methods like `wp.getAuthors` leak email addresses
- **33-Phone-Number-Enumeration** — Email addresses often linked to phone numbers in social profiles
- **35-Supply-Chain-Asset-Mapping** — Partner and vendor emails reveal supply chain relationships
- **37-Partner-Network-Discovery** — Partner email domains and formats differ from primary target
- **39-Subsidiary-Asset-Mapping** — Subsidiary email domains and formats may vary

### Workflow Integration

```
Email Harvesting Pipeline:
1. 21-Subdomain-Discovery → Enumerate all domains
2. 32-Email-Address-Harvesting → Collect emails per domain
3. 33-Phone-Number-Enumeration → Link emails to phone numbers
4. 38-Acquisition-Target-Analysis → Verify emails across acquired companies
5. 39-Subsidiary-Asset-Mapping → Map email formats per subsidiary
```

---

## Reporting Template

### Finding: Email Address Harvesting Results

**Target:** [Organization Name]
**Scope:** [Authorized testing scope]
**Date:** [Testing date]

**Summary:**
- Total unique emails harvested: [N]
- Domains analyzed: [N]
- Valid mailboxes confirmed: [N]
- Breached accounts identified: [N]
- Email format pattern: [pattern]

**Sources Used:**
1. DNS records (MX, SPF, DKIM, DMARC): [N] emails
2. Website scraping: [N] emails
3. Social media (LinkedIn, GitHub): [N] emails
4. Data breaches: [N] emails
5. Other sources: [N] emails

**Email Format Analysis:**
```
Primary format: {first}.{last}@domain.com
Secondary format: {f}{last}@domain.com
Role-based: support@, info@, admin@
```

**Risk Assessment:**
- Email enumeration risk: [High/Medium/Low]
- Credential reuse risk: [High/Medium/Low]
- Social engineering risk: [High/Medium/Low]

**Recommendations:**
- [Specific recommendations based on findings]

---

## Practice Labs

### Lab 1: Email Harvesting Practice

```bash
# Create practice environment
mkdir email_harvest_lab
cd email_harvest_lab

# Create sample website with emails
cat > index.html << 'EOF'
<html>
<body>
<h1>Contact Us</h1>
<p>Email: info@example.com</p>
<p>Support: support@example.com</p>
<p>Security: security@example.com</p>
</body>
</html>
EOF

# Start local server
python3 -m http.server 8080

# Practice extraction
curl -s http://localhost:8080 | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
```

### Lab 2: DNS Email Discovery

```bash
# Practice DNS email discovery on test domains
# Use dig to query MX, SPF, DKIM, DMARC records
dig MX gmail.com +short
dig TXT gmail.com +short | grep spf
dig TXT _dmarc.gmail.com +short
```

### Lab 3: Email Verification Pipeline

```bash
# Create email verification script
cat > verify_pipeline.py << 'PYEOF'
import re
import dns.resolver

def full_verify(email):
    # Step 1: Syntax check
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(pattern, email):
        return 'invalid_syntax'
    
    # Step 2: Domain check
    domain = email.split('@')[1]
    try:
        mx = dns.resolver.resolve(domain, 'MX')
        print(f'  MX: {mx[0].exchange}')
    except:
        return 'invalid_domain'
    
    # Step 3: (Optional) SMTP check
    # Note: This may trigger rate limits in real environments
    
    return 'valid'

emails = ['test@gmail.com', 'invalid@fake12345.com', 'badformat@']
for email in emails:
    print(f'{email}: {full_verify(email)}')
PYEOF
python3 verify_pipeline.py
```

---

## Ethical Guidelines

1. **Scope verification** — Only harvest emails from domains and sources within authorized testing scope.

2. **Passive collection priority** — Prefer passive methods (DNS, public web pages) over active methods (SMTP verification, error message enumeration).

3. **Rate limiting** — Implement strict rate limits when querying APIs, web servers, or mail servers. Respect platform terms of service.

4. **Data handling** — Harvested email addresses contain PII. Handle according to applicable privacy regulations (GDPR, CCPA).

5. **No unsolicited contact** — Do not send emails to harvested addresses unless explicitly authorized as part of social engineering testing.

6. **Breach data usage** — When using breach databases, document the source and ensure usage complies with platform terms and applicable laws.

7. **Social media scraping** — Respect platform terms of service. Do not create fake accounts or use automation that violates platform policies.

8. **Data minimization** — Only collect email addresses necessary for the assessment. Do not harvest beyond scope requirements.

9. **Storage and disposal** — Store harvested emails securely and dispose of them after the assessment is complete.

10. **Disclosure** — Report all findings, including email enumeration vulnerabilities, to the target organization. Include recommendations for protecting employee email addresses.

---

## Quick Reference Cheat Sheet

### DNS Commands
```bash
dig MX domain.com +short              # MX records
dig TXT domain.com +short | grep spf  # SPF record
dig TXT _dmarc.domain.com +short      # DMARC record
dig TXT default._domainkey.domain.com # DKIM record
```

### Email Extraction Patterns
```bash
# Basic extraction
grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt

# With context
grep -B2 -A2 -P '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt

# Count by domain
grep -oP '@[a-zA-Z0-9.-]+' file.txt | sort | uniq -c | sort -rn
```

### theHarvester Commands
```bash
theHarvester -d target.com -b all -l 500 -f report.html
theHarvester -d target.com -b google,linkedin,github -l 200
```

### SMTP Verification
```python
import smtplib
server = smtplib.SMTP('mx.domain.com', 25)
server.ehlo('test.com')
server.mail('test@test.com')
code, msg = server.rcpt('target@domain.com')
print(f'{code}: {msg}')
server.quit()
```

### Google Dorks for Email
```
site:domain.com "@domain.com"
site:domain.com inurl:contact email
site:domain.com filetype:pdf "@domain.com"
"@domain.com" -site:domain.com
```

---

*Document Version: 1.0 | Last Updated: 2026 | Author: Recon Deep Dive Series*
