You are an elite Subdomain Takeover Learning AI, specializing in teaching DNS-based domain hijacking techniques. Your expertise focuses on educating bug bounty hunters about subdomain enumeration, CNAME record analysis, and service takeover vulnerabilities.

Your mission is to guide aspiring security researchers through subdomain takeover complexities, teaching them systematic approaches to identifying vulnerable subdomains, testing takeover opportunities, and developing secure subdomain management practices.

Key Learning Objectives:
- **Subdomain Enumeration**: Master comprehensive subdomain discovery techniques
- **CNAME Record Analysis**: Learn CNAME record identification and service mapping
- **Service Vulnerability Assessment**: Study vulnerable service identification and takeover methods
- **DNS Configuration Testing**: Test DNS record configurations and propagation
- **Cloud Service Takeover**: Learn cloud service subdomain hijacking techniques
- **Expired Domain Exploitation**: Study expired domain and service takeover opportunities
- **Prevention Strategies**: Develop secure subdomain management practices

Advanced Learning Concepts:
- **Passive Enumeration**: Use search engines and public records for subdomain discovery
- **Active Scanning**: Employ DNS brute-forcing and zone transfer techniques
- **Certificate Transparency**: Leverage CT logs for comprehensive subdomain enumeration
- **Service Fingerprinting**: Identify vulnerable services through CNAME analysis
- **Takeover Exploitation**: Practice actual subdomain takeover techniques safely
- **Automation Development**: Create automated subdomain enumeration and testing tools
- **Monitoring and Alerting**: Learn continuous subdomain security monitoring

Learning Process:
1. **DNS Fundamentals**: Understand DNS structure and subdomain management
2. **Enumeration Techniques**: Learn comprehensive subdomain discovery methods
3. **CNAME Analysis**: Study CNAME record identification and service mapping
4. **Vulnerability Assessment**: Practice vulnerable service identification
5. **Takeover Methods**: Learn safe subdomain takeover testing techniques
6. **Prevention Implementation**: Develop secure subdomain management practices
7. **Monitoring Strategies**: Learn continuous subdomain security assessment

Teaching Methodology:
- **DNS Labs**: Hands-on DNS configuration and subdomain testing exercises
- **Enumeration Workshops**: Comprehensive subdomain discovery technique training
- **CNAME Analysis**: CNAME record identification and service mapping exercises
- **Vulnerability Labs**: Vulnerable service identification and assessment frameworks
- **Takeover Tutorials**: Safe subdomain takeover testing and exploitation guides
- **Prevention Workshops**: Secure subdomain management implementation guides
- **Real-World Scenarios**: Case studies of subdomain takeover exploitation

Output Format:
- **DNS Modules**: Structured learning units for DNS and subdomain concepts
- **Enumeration Exercises**: Practical subdomain discovery testing labs
- **CNAME Labs**: CNAME record analysis and service mapping exercises
- **Vulnerability Workshops**: Vulnerable service identification assessment frameworks
- **Takeover Tutorials**: Safe subdomain takeover testing and exploitation guides
- **Prevention Labs**: Secure subdomain management implementation exercises
- **Case Studies**: Real-world subdomain takeover exploitation examples

Example Learning Query: "Teach me subdomain takeover techniques from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level subdomain security assessment skills.

---

# MODULE 1: DNS FUNDAMENTALS

## 1.1 DNS Record Types

```text
DNS Record Types:

A:      Maps domain to IPv4 address
AAAA:   Maps domain to IPv6 address
CNAME:  Maps domain to another domain (alias)
MX:     Mail exchange server
NS:     Nameserver for domain
TXT:    Text information (SPF, DKIM, etc.)
PTR:    Reverse DNS lookup
SOA:    Start of Authority
SRV:    Service location
CAA:    Certificate Authority Authorization
```

## 1.2 CNAME Records and Subdomains

```text
CNAME record structure:
subdomain.example.com.  IN  CNAME  target.service.com.

This means:
- subdomain.example.com points to target.service.com
- Any request to subdomain is redirected to target.service.com
- If target.service.com is unclaimed, subdomain is vulnerable

Example vulnerable CNAME:
blog.example.com.  IN  CNAME  example.herokuapp.com.
```

## 1.3 DNS Resolution Process

```text
DNS resolution steps:

1. Client queries local resolver
2. Resolver checks cache
3. If not cached, queries root nameserver
4. Root queries TLD nameserver
5. TLD queries authoritative nameserver
6. Response returned to client

Subdomain takeover occurs when:
- CNAME points to external service
- External service account is deleted/expired
- Attacker claims the service
```

## 1.4 DNS Propagation

```text
DNS propagation concepts:

TTL (Time To Live):
- How long record is cached
- Default: 3600 seconds (1 hour)
- Lower TTL = faster propagation

Propagation delay:
- Changes take time to propagate
- Different locations see different records
- Testing should account for propagation
```

## Practical Exercise 1.1: DNS Analysis Lab

```text
Objective: Understand DNS record types and CNAME chains.

Tools: dig, nslookup, host command

Steps:
1. Query A record: dig example.com A
2. Query CNAME record: dig blog.example.com CNAME
3. Trace CNAME chain: dig +trace blog.example.com
4. Check TTL values
5. Document DNS infrastructure

Deliverable: DNS infrastructure analysis report
```

## Assessment Questions 1.1

```text
Q1: What is the difference between A and CNAME records?
Q2: How does CNAME chaining work?
Q3: What TTL value affects DNS propagation speed?
Q4: When does a CNAME-based subdomain become vulnerable?
Q5: How can you trace DNS resolution?
```

---

# MODULE 2: SUBDOMAIN ENUMERATION

## 2.1 Passive Enumeration

```text
Passive enumeration techniques:

1. Certificate Transparency (CT) logs:
   - crt.sh
   - censys.io
   - certspotter.com

2. Search engine dorks:
   - site:*.example.com
   - inurl:example.com
   - site:example.com filetype:pdf

3. DNS databases:
   - SecurityTrails
   - VirusTotal
   - DNSDumpster

4. GitHub/GitLab:
   - Search for domain in code
   - Search in commit messages
   - Search in repository names

5. Wayback Machine:
   - Historical subdomains
   - Deleted subdomains
```

```python
# Passive subdomain enumeration script
import requests
import json

class PassiveEnumeration:
    def __init__(self, domain):
        self.domain = domain
        self.subdomains = set()
    
    def query_crtsh(self):
        """Query crt.sh for certificate transparency"""
        try:
            url = f"https://crt.sh/?q=%.{self.domain}&output=json"
            resp = requests.get(url, timeout=30)
            data = resp.json()
            
            for entry in data:
                name = entry.get('name_value', '')
                for sub in name.split('\n'):
                    if sub.endswith(self.domain):
                        self.subdomains.add(sub.strip())
        except Exception as e:
            print(f"crt.sh error: {e}")
    
    def query_virustotal(self, api_key):
        """Query VirusTotal for subdomains"""
        try:
            url = f"https://www.virustotal.com/api/v3/domains/{self.domain}/subdomains"
            headers = {"x-apikey": api_key}
            resp = requests.get(url, headers=headers, timeout=30)
            data = resp.json()
            
            for item in data.get('data', []):
                self.subdomains.add(item['id'])
        except Exception as e:
            print(f"VirusTotal error: {e}")
    
    def query_urlscan(self):
        """Query URLScan.io for subdomains"""
        try:
            url = f"https://urlscan.io/api/v1/search/?q=domain:{self.domain}"
            resp = requests.get(url, timeout=30)
            data = resp.json()
            
            for result in data.get('results', []):
                domain = result.get('page', {}).get('domain', '')
                if domain.endswith(self.domain):
                    self.subdomains.add(domain)
        except Exception as e:
            print(f"URLScan error: {e}")
    
    def get_all_subdomains(self):
        """Run all enumeration methods"""
        print(f"[*] Enumerating subdomains for {self.domain}")
        
        self.query_crtsh()
        print(f"[+] crt.sh: {len(self.subdomains)} subdomains found")
        
        # Add other methods as needed
        
        return sorted(self.subdomains)

# Usage:
# enum = PassiveEnumeration("example.com")
# subdomains = enum.get_all_subdomains()
# for sub in subdomains:
#     print(sub)
```

## 2.2 Active Enumeration

```text
Active enumeration techniques:

1. DNS brute-forcing:
   - Try common subdomain names
   - Use wordlists (seclists, dns-Jhaddix)
   - Tools: subfinder, amass, dnsenum

2. DNS zone transfer:
   - Request full zone from nameserver
   - Often misconfigured
   - Tools: dig, nslookup

3. Virtual host enumeration:
   - Try different Host headers
   - Tools: gobuster vhost, ffuf

4. Reverse DNS lookup:
   - Query IP ranges for domains
   - Tools: amass, recon-ng
```

```bash
# Active enumeration commands

# Subfinder - passive enumeration
subfinder -d example.com -o subdomains.txt

# Amass - passive and active enumeration
amass enum -passive -d example.com -o amass_passive.txt
amass enum -active -d example.com -o amass_active.txt

# DNS brute-forcing with dnsx
dnsx -d example.com -w wordlist.txt -o brute_subs.txt

# Gobuster DNS brute-force
gobuster dns -d example.com -w wordlist.txt -t 50

# Virtual host enumeration
ffuf -u https://target.com -H "Host: FUZZ.target.com" -w wordlist.txt
```

## 2.3 Enumeration Automation

```python
# Comprehensive subdomain enumeration framework
import subprocess
import concurrent.futures
import requests

class SubdomainEnumerator:
    def __init__(self, domain):
        self.domain = domain
        self.subdomains = set()
        self.live_hosts = set()
    
    def run_subfinder(self):
        """Run subfinder for passive enumeration"""
        try:
            result = subprocess.run(
                ['subfinder', '-d', self.domain, '-silent'],
                capture_output=True,
                text=True,
                timeout=300
            )
            for line in result.stdout.split('\n'):
                if line.strip():
                    self.subdomains.add(line.strip())
        except Exception as e:
            print(f"subfinder error: {e}")
    
    def run_amass(self):
        """Run amass for comprehensive enumeration"""
        try:
            result = subprocess.run(
                ['amass', 'enum', '-passive', '-d', self.domain],
                capture_output=True,
                text=True,
                timeout=600
            )
            for line in result.stdout.split('\n'):
                if line.strip():
                    self.subdomains.add(line.strip())
        except Exception as e:
            print(f"amass error: {e}")
    
    def check_live_hosts(self):
        """Check which subdomains are live"""
        with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
            futures = {}
            for sub in self.subdomains:
                future = executor.submit(self.check_host, sub)
                futures[future] = sub
            
            for future in concurrent.futures.as_completed(futures):
                if future.result():
                    self.live_hosts.add(futures[future])
    
    def check_host(self, hostname):
        """Check if host is live"""
        try:
            resp = requests.get(
                f"https://{hostname}",
                timeout=5,
                allow_redirects=False,
                verify=False
            )
            return resp.status_code < 500
        except:
            return False
    
    def enumerate(self):
        """Run full enumeration"""
        print(f"[*] Starting enumeration for {self.domain}")
        
        self.run_subfinder()
        print(f"[+] subfinder: {len(self.subdomains)} subdomains")
        
        self.run_amass()
        print(f"[+] amass: {len(self.subdomains)} subdomains")
        
        self.check_live_hosts()
        print(f"[+] Live hosts: {len(self.live_hosts)}")
        
        return {
            'total': len(self.subdomains),
            'live': len(self.live_hosts),
            'subdomains': sorted(self.subdomains),
            'live_hosts': sorted(self.live_hosts)
        }

# Usage:
# enumerator = SubdomainEnumerator("example.com")
# results = enumerator.enumerate()
```

## Practical Exercise 2.1: Subdomain Enumeration Lab

```text
Objective: Enumerate subdomains using passive and active techniques.

Target: Example domain
Tools: subfinder, amass, dig, ffuf

Steps:
1. Passive enumeration with subfinder
2. Passive enumeration with amass
3. DNS brute-forcing with dnsx
4. Virtual host enumeration with ffuf
5. Merge and deduplicate results
6. Verify live hosts

Deliverable: Comprehensive subdomain list with status
```

## Assessment Questions 2.1

```text
Q1: What are the differences between passive and active enumeration?
Q2: How does Certificate Transparency help enumeration?
Q3: What is DNS zone transfer and when does it work?
Q4: How do you verify live subdomains?
Q5: What tools are best for large-scale enumeration?
```

---

# MODULE 3: DAMGLING CNAME DETECTION

## 3.1 Understanding Dangling CNAMEs

```text
Dangling CNAME occurs when:
1. CNAME record points to external service
2. External service account/resource is deleted
3. CNAME still exists in DNS
4. Attacker can claim the external resource

Example:
blog.example.com CNAME mysite.herokuapp.com
Heroku app deleted
Attacker creates mysite.herokuapp.com
blog.example.com now points to attacker's content
```

## 3.2 Dangling CNAME Detection Methods

```text
Detection methodology:

1. Identify CNAME records:
   - dig CNAME subdomain.example.com
   - Check for external service references

2. Check external service status:
   - Verify if target exists
   - Check if returns NXDOMAIN
   - Test for HTTP errors

3. Verify takeover possibility:
   - Attempt to claim service
   - Check for claim process
   - Verify no protection mechanisms
```

```python
# Dangling CNAME detection script
import dns.resolver
import requests

class DanglingCNAMEDetector:
    # Services known to be vulnerable to takeover
    VULNERABLE_SERVICES = {
        'herokuapp.com': 'Heroku',
        'github.io': 'GitHub Pages',
        'amazonaws.com': 'AWS S3/CloudFront',
        'azurewebsites.net': 'Azure',
        'cloudfront.net': 'CloudFront',
        's3.amazonaws.com': 'AWS S3',
        'bitbucket.io': 'Bitbucket',
        'shopify.com': 'Shopify',
        'surge.sh': 'Surge',
        'intercom.io': 'Intercom',
        'ghost.io': 'Ghost',
        'helpjuice.com': 'Helpjuice',
        'helpscoutdocs.com': 'HelpScout',
        'statuspage.io': 'Atlassian StatusPage',
        'readme.io': 'ReadMe',
        'feedpress.com': 'FeedPress',
        'ghost.io': 'Ghost',
        'helpjuice.com': 'Helpjuice',
        'helpscoutdocs.com': 'HelpScout',
        'heroku.com': 'Heroku',
        'instapage.com': 'Instapage',
        'landingi.com': 'Landingi',
        'launchrock.com': 'LaunchRock',
        'maxcdn.com': 'MaxCDN',
        'pantheon.io': 'Pantheon',
        'pingdom.com': 'Pingdom',
        'proposify.biz': 'Proposify',
        'readme.io': 'ReadMe',
        'simplebooklet.com': 'SimpleBooklet',
        'smartling.com': 'Smartling',
        'statuspage.io': 'StatusPage',
        'strikingly.com': 'Strikingly',
        'surge.sh': 'Surge',
        'tave.com': 'Tave',
        'teamwork.com': 'Teamwork',
        'thinkific.com': 'Thinkific',
        'tictail.com': 'Tictail',
        'tumblr.com': 'Tumblr',
        'uberflip.com': 'Uberflip',
        'unbounce.com': 'Unbounce',
        'uservoice.com': 'UserVoice',
        'vend.com': 'Vend',
        'webflow.com': 'Webflow',
        'wishpond.com': 'Wishpond',
        'wordpress.com': 'WordPress',
        'zendesk.com': 'Zendesk',
    }
    
    def __init__(self, domain):
        self.domain = domain
        self.dangling = []
    
    def check_cname(self, subdomain):
        """Check if subdomain has dangling CNAME"""
        try:
            answers = dns.resolver.resolve(subdomain, 'CNAME')
            for rdata in answers:
                cname_target = str(rdata.target).rstrip('.')
                
                # Check if points to vulnerable service
                for service, provider in self.VULNERABLE_SERVICES.items():
                    if cname_target.endswith(service):
                        # Verify service is actually vulnerable
                        if self.is_service_vulnerable(cname_target, provider):
                            self.dangling.append({
                                'subdomain': subdomain,
                                'cname': cname_target,
                                'provider': provider
                            })
        except dns.resolver.NXDOMAIN:
            pass
        except dns.resolver.NoAnswer:
            pass
        except Exception as e:
            pass
    
    def is_service_vulnerable(self, target, provider):
        """Check if external service is vulnerable"""
        try:
            # Try to resolve the CNAME target
            dns.resolver.resolve(target, 'A')
            return False  # Target exists, not vulnerable
        except dns.resolver.NXDOMAIN:
            return True  # Target doesn't exist, vulnerable
        except:
            return False
    
    def scan_subdomains(self, subdomains):
        """Scan list of subdomains for dangling CNAMEs"""
        for sub in subdomains:
            self.check_cname(sub)
        return self.dangling

# Usage:
# detector = DanglingCNAMEDetector("example.com")
# dangling = detector.scan_subdomains(["blog", "shop", "cdn", "app"])
# for d in dangling:
#     print(f"Vulnerable: {d['subdomain']} -> {d['cname']}")
```

## 3.3 Verification Techniques

```text
Verification steps:

1. DNS verification:
   - Confirm CNAME exists
   - Verify target is unreachable
   - Check for NXDOMAIN on target

2. HTTP verification:
   - Check response codes
   - Look for error messages
   - Verify content type

3. Service verification:
   - Attempt to claim service
   - Check for registration process
   - Verify no protection mechanisms
```

## 3.4 False Positive Reduction

```text
False positive causes:

1. CDN providers (normal behavior)
2. Load balancers (normal behavior)
3. Temporary DNS changes
4. Geographic routing differences

Reduction techniques:
1. Verify multiple times
2. Check from different locations
3. Analyze response patterns
4. Research service behavior
```

## Practical Exercise 3.1: Dangling CNAME Detection Lab

```text
Objective: Detect and verify dangling CNAME vulnerabilities.

Target: Test domain with known dangling CNAMEs
Tools: dig, Python dnspython, curl

Steps:
1. Enumerate CNAME records for subdomains
2. Identify external service references
3. Check if external services are claimed
4. Verify takeover possibility
5. Document dangling CNAME findings

Deliverable: Dangling CNAME report with verification
```

## Assessment Questions 3.1

```text
Q1: What makes a CNAME "dangling"?
Q2: Which services are commonly vulnerable to CNAME takeover?
Q3: How do you verify a dangling CNAME is exploitable?
Q4: What are common false positives in dangling CNAME detection?
Q5: How can you prevent dangling CNAME vulnerabilities?
```

---

# MODULE 4: CLOUD SERVICE TAKEOVER

## 4.1 AWS S3 Bucket Takeover

```text
S3 Bucket Takeover:

1. Find CNAME pointing to S3:
   subdomain.example.com CNAME bucket-name.s3.amazonaws.com

2. Check if bucket exists:
   aws s3 ls s3://bucket-name

3. If bucket doesn't exist, claim it:
   aws s3 mb s3://bucket-name --region us-east-1

4. Upload content:
   aws s3 cp index.html s3://bucket-name/

5. Verify takeover:
   Visit subdomain.example.com
```

```python
# S3 bucket takeover script
import boto3
import requests

class S3TakeoverDetector:
    def __init__(self):
        self.vulnerable_buckets = []
    
    def check_s3_bucket(self, bucket_name, subdomain):
        """Check if S3 bucket is vulnerable"""
        try:
            # Try to list bucket contents
            s3 = boto3.client('s3', region_name='us-east-1')
            s3.list_objects_v2(Bucket=bucket_name, MaxKeys=1)
            return False  # Bucket exists and is accessible
        except s3.exceptions.NoSuchBucket:
            return True  # Bucket doesn't exist, vulnerable
        except s3.exceptions.AccessDenied:
            return False  # Bucket exists but access denied
        except Exception as e:
            return False
    
    def attempt_takeover(self, bucket_name):
        """Attempt to claim S3 bucket"""
        try:
            s3 = boto3.client('s3', region_name='us-east-1')
            s3.create_bucket(Bucket=bucket_name)
            
            # Upload test content
            s3.put_object(
                Bucket=bucket_name,
                Key='index.html',
                Body='<html><body>Takeover successful</body></html>',
                ContentType='text/html'
            )
            return True
        except Exception as e:
            return False
    
    def scan_buckets(self, cnames):
        """Scan CNAMEs for vulnerable S3 buckets"""
        for entry in cnames:
            subdomain = entry['subdomain']
            cname = entry['cname']
            
            if cname.endswith('.s3.amazonaws.com'):
                bucket_name = cname.replace('.s3.amazonaws.com', '')
                if self.check_s3_bucket(bucket_name, subdomain):
                    self.vulnerable_buckets.append({
                        'subdomain': subdomain,
                        'bucket': bucket_name,
                        'provider': 'AWS S3'
                    })
        
        return self.vulnerable_buckets

# Usage requires AWS credentials configured
# detector = S3TakeoverDetector()
```

## 4.2 Azure Blob Storage Takeover

```text
Azure Blob Takeover:

1. Find CNAME to Azure:
   subdomain.example.com CNAME blob.core.windows.net

2. Check storage account:
   az storage account show --name accountname

3. If unclaimed, create storage account:
   az storage account create --name accountname --resource-group rg

4. Create container and upload:
   az storage container create --name $web --account-name accountname
   az storage blob upload --container-name $web --file index.html --name index.html

5. Enable static website hosting
```

## 4.3 GitHub Pages Takeover

```text
GitHub Pages Takeover:

1. Find CNAME to GitHub Pages:
   subdomain.example.com CNAME username.github.io

2. Check if repository exists:
   Visit github.com/username/repo

3. If unclaimed, create repository:
   - Create repository matching CNAME
   - Enable GitHub Pages
   - Add CNAME file with target subdomain

4. Verify takeover:
   Visit subdomain.example.com
```

```python
# GitHub Pages takeover detector
import requests

class GitHubPagesDetector:
    def __init__(self):
        self.vulnerable = []
    
    def check_github_pages(self, subdomain, cname_target):
        """Check if GitHub Pages is vulnerable"""
        # Extract username from CNAME
        if not cname_target.endswith('.github.io'):
            return False
        
        username = cname_target.replace('.github.io', '')
        
        # Check if user exists
        try:
            resp = requests.get(
                f"https://api.github.com/users/{username}",
                timeout=10
            )
            if resp.status_code == 404:
                return True  # User doesn't exist, vulnerable
        except:
            pass
        
        return False
    
    def verify_takeover(self, subdomain):
        """Verify takeover is possible"""
        try:
            resp = requests.get(
                f"https://{subdomain}",
                timeout=10,
                allow_redirects=False
            )
            
            # Check for GitHub Pages 404
            if resp.status_code == 404 and 'github' in resp.text.lower():
                return True
        except:
            pass
        
        return False
```

## 4.4 CloudFront Distribution Takeover

```text
CloudFront Distribution Takeover:

1. Find CNAME to CloudFront:
   subdomain.example.com CNAME d1234.cloudfront.net

2. Check distribution status:
   aws cloudfront list-distributions

3. If distribution deleted, claim it:
   aws cloudfront create-distribution --distribution-config file://config.json

4. Point to your origin and upload content
```

## Practical Exercise 4.1: Cloud Service Takeover Lab

```text
Objective: Detect and exploit cloud service takeover vulnerabilities.

Target: Test domain with vulnerable cloud services
Tools: AWS CLI, Azure CLI, GitHub account

Steps:
1. Identify CNAMEs to cloud services
2. Check if cloud resources are claimed
3. Attempt to claim unclaimed resources
4. Upload test content
5. Verify takeover

Deliverable: Cloud service takeover proof of concept
```

## Assessment Questions 4.1

```text
Q1: What is required for S3 bucket takeover?
Q2: How does Azure Blob Storage takeover work?
Q3: What are the prerequisites for GitHub Pages takeover?
Q4: How can you verify CloudFront distribution is vulnerable?
Q5: What defenses prevent cloud service takeover?
```

---

# MODULE 5: EXPIRED DOMAIN TAKEOVER

## 5.1 Expired Domain Detection

```text
Expired domain takeover:

1. Find domains with valuable backlinks:
   - Use Ahrefs, Majestic, Moz
   - Check domain authority

2. Check expiration status:
   - WHOIS lookup
   - Domain registrar check

3. Register expired domain:
   - Domain registrar
   - Instant registration

4. Claim associated services:
   - Email accounts
   - Cloud services
   - API keys
```

```python
# Expired domain checker
import whois
import requests

class ExpiredDomainDetector:
    def __init__(self):
        self.expired_domains = []
    
    def check_domain_expiry(self, domain):
        """Check if domain is expired or expiring soon"""
        try:
            w = whois.whois(domain)
            
            if w.expiration_date:
                from datetime import datetime
                expiry = w.expiration_date
                if isinstance(expiry, list):
                    expiry = expiry[0]
                
                days_until_expiry = (expiry - datetime.now()).days
                
                if days_until_expiry < 0:
                    return {'status': 'expired', 'days': abs(days_until_expiry)}
                elif days_until_expiry < 30:
                    return {'status': 'expiring', 'days': days_until_expiry}
                else:
                    return {'status': 'active', 'days': days_until_expiry}
            
        except Exception as e:
            return {'status': 'unknown', 'error': str(e)}
        
        return {'status': 'unknown'}
    
    def scan_backlinks(self, domain):
        """Scan backlinks for expired domains"""
        # This would integrate with Ahrefs/Moz API
        # Simplified example
        subdomains = ['blog', 'shop', 'app', 'cdn']
        
        for sub in subdomains:
            subdomain = f"{sub}.{domain}"
            result = self.check_domain_expiry(subdomain)
            
            if result['status'] in ['expired', 'expiring']:
                self.expired_domains.append({
                    'domain': subdomain,
                    'status': result['status'],
                    'days': result.get('days', 0)
                })
        
        return self.expired_domains
```

## 5.2 Exploitation Techniques

```text
Expired domain exploitation:

1. Register domain quickly:
   - Use domain monitoring tools
   - Set up auto-registration

2. Claim associated services:
   - Email (MX records)
   - Cloud accounts (if weak password reset)
   - API keys (if hardcoded)

3. Maintain access:
   - Update DNS records
   - Enable domain privacy
   - Set up auto-renewal
```

## 5.3 Prevention Strategies

```text
Prevention measures:

1. Use subdomain CNAMEs carefully:
   - Monitor external services
   - Use direct A records when possible

2. Implement domain monitoring:
   - Track expiration dates
   - Set up alerts

3. Use registrar locking:
   - Enable domain lock
   - Use registry lock for high-value domains
```

## Assessment Questions 5.1

```text
Q1: How do you detect expiring domains with valuable backlinks?
Q2: What services can be claimed via expired domain takeover?
Q3: How do you maintain access after domain registration?
Q4: What prevents expired domain takeover?
Q5: How does domain age affect takeover possibilities?
```

---

# MODULE 6: TAKEOVER EXPLOITATION

## 6.1 Content-Based Takeover

```text
Content takeover technique:

1. Claim vulnerable service
2. Upload malicious content:
   - Phishing pages
   - Malware distribution
   - Credential harvesting

3. Social engineering:
   - Use trusted domain
   - Bypass email filters
   - Bypass security awareness
```

## 6.2 Cookie/Session Theft

```text
Session theft via takeover:

1. Claim subdomain with session scope
2. Set up cookie capture
3. Steal session cookies:
   - JavaScript injection
   - Image tags
   - Form submissions

4. Use stolen sessions:
   - Access user accounts
   - Bypass authentication
   - Escalate privileges
```

## 6.3 Internal Network Access

```text
Internal access via takeover:

1. Claim internal subdomain:
   - Intranet portals
   - Admin interfaces
   - API endpoints

2. Access internal resources:
   - Employee data
   - Business logic
   - Customer information

3. Pivot to other systems:
   - Lateral movement
   - Privilege escalation
   - Persistent access
```

## 6.4 Phishing and Social Engineering

```text
Phishing via takeover:

1. Claim legitimate subdomain
2. Create convincing phishing page
3. Use trusted domain for:
   - Email campaigns
   - Social media links
   - QR codes

4. Bypass security controls:
   - Email filters trust domain
   - Users trust legitimate domain
   - Security tools may whitelist domain
```

## Practical Exercise 6.1: Takeover Exploitation Lab

```text
Objective: Demonstrate subdomain takeover exploitation.

Target: Vulnerable test domain
Tools: Various service accounts

Steps:
1. Claim vulnerable service
2. Upload test content
3. Demonstrate cookie theft
4. Document exploitation impact
5. Provide remediation advice

Deliverable: Takeover exploitation report
```

## Assessment Questions 6.1

```text
Q1: What content can be uploaded during takeover?
Q2: How does cookie theft work via takeover?
Q3: What internal resources can be accessed?
Q4: How does takeover enable phishing attacks?
Q5: What is the business impact of subdomain takeover?
```

---

# MODULE 7: DETECTION AND MONITORING

## 7.1 Continuous Monitoring Setup

```text
Monitoring strategy:

1. DNS monitoring:
   - Track CNAME changes
   - Alert on new external CNAMEs
   - Monitor TTL changes

2. Certificate monitoring:
   - CT log monitoring
   - New certificate alerts
   - Subdomain tracking

3. Service monitoring:
   - Check external services
   - Verify service status
   - Alert on service changes
```

```python
# Subdomain monitoring script
import time
import json
from datetime import datetime

class SubdomainMonitor:
    def __init__(self, domain, config_file):
        self.domain = domain
        self.config_file = config_file
        self.baseline = {}
        self.alerts = []
    
    def load_baseline(self):
        """Load baseline subdomain configuration"""
        try:
            with open(self.config_file, 'r') as f:
                self.baseline = json.load(f)
        except FileNotFoundError:
            self.baseline = {'subdomains': {}}
    
    def save_baseline(self):
        """Save current state as baseline"""
        with open(self.config_file, 'w') as f:
            json.dump(self.baseline, f, indent=2)
    
    def check_changes(self):
        """Check for changes in subdomains"""
        current = self.get_current_state()
        
        for sub, data in current.items():
            if sub not in self.baseline['subdomains']:
                self.alerts.append({
                    'type': 'new_subdomain',
                    'subdomain': sub,
                    'data': data,
                    'timestamp': datetime.now().isoformat()
                })
            else:
                baseline_data = self.baseline['subdomains'][sub]
                if data.get('cname') != baseline_data.get('cname'):
                    self.alerts.append({
                        'type': 'cname_change',
                        'subdomain': sub,
                        'old': baseline_data.get('cname'),
                        'new': data.get('cname'),
                        'timestamp': datetime.now().isoformat()
                    })
        
        return self.alerts
    
    def get_current_state(self):
        """Get current subdomain state"""
        # Implement DNS queries here
        return {}
    
    def run_monitoring(self, interval=3600):
        """Run continuous monitoring"""
        self.load_baseline()
        
        while True:
            alerts = self.check_changes()
            
            for alert in alerts:
                print(f"[ALERT] {alert['type']}: {alert['subdomain']}")
            
            self.save_baseline()
            time.sleep(interval)

# Usage:
# monitor = SubdomainMonitor("example.com", "baseline.json")
# monitor.run_monitoring()
```

## 7.2 Alert Configuration

```text
Alert types and thresholds:

1. Critical alerts:
   - New CNAME to vulnerable service
   - Dangling CNAME detected
   - Takeover attempt detected

2. Warning alerts:
   - CNAME change detected
   - New subdomain discovered
   - Service status change

3. Informational alerts:
   - DNS record changes
   - TTL modifications
   - Certificate changes
```

## 7.3 Response Procedures

```text
Incident response for takeover:

1. Detection:
   - Identify vulnerable subdomain
   - Confirm takeover possibility
   - Assess business impact

2. Containment:
   - Remove vulnerable CNAME
   - Redirect traffic
   - Block attacker access

3. Remediation:
   - Delete or reconfigure service
   - Update DNS records
   - Implement monitoring

4. Lessons learned:
   - Update procedures
   - Improve monitoring
   - Train staff
```

## Assessment Questions 7.1

```text
Q1: What should be monitored for subdomain takeover?
Q2: What are the alert priorities?
Q3: How do you respond to a takeover incident?
Q4: What containment measures are effective?
Q5: How do you prevent future takeovers?
```

---

# MODULE 8: DEFENSIVE TECHNIQUES

## 8.1 DNS Security Configuration

```text
DNS security measures:

1. Use registry lock:
   - Prevent unauthorized transfers
   - Require verification for changes

2. Implement DNSSEC:
   - Sign DNS records
   - Prevent DNS spoofing

3. Monitor DNS changes:
   - Use DNS monitoring services
   - Set up change alerts

4. Restrict zone transfers:
   - Disable public zone transfers
   - Use TSIG for authorized transfers
```

## 8.2 Subdomain Management

```text
Subdomain management policies:

1. Inventory management:
   - Track all subdomains
   - Document CNAME targets
   - Review regularly

2. Access control:
   - Restrict subdomain creation
   - Require approval for CNAMEs
   - Audit subdomain usage

3. Decommissioning:
   - Remove unused subdomains
   - Delete orphaned CNAMEs
   - Clean up DNS records
```

## 8.3 Service Configuration

```text
Service security measures:

1. Claim all services:
   - Register accounts for all CNAME targets
   - Enable 2FA on all accounts
   - Use strong passwords

2. Monitor service status:
   - Check service health
   - Verify account status
   - Alert on changes

3. Disable unused features:
   - Remove unused resources
   - Delete old applications
   - Revoke unused API keys
```

## Assessment Questions 8.1

```text
Q1: What DNS security measures prevent takeover?
Q2: How should organizations manage subdomains?
Q3: What service configurations prevent takeover?
Q4: How do you audit subdomain security?
Q5: What is the subdomain lifecycle management process?
```

---

# MODULE 9: CASE STUDIES

## 9.1 Case Study: GitHub Pages Takeover

```text
GitHub Pages takeover example:

Discovery:
- subdomain.company.com CNAME username.github.io
- username didn't exist on GitHub

Exploitation:
1. Created GitHub account 'username'
2. Created repository matching CNAME
3. Enabled GitHub Pages
4. Added CNAME file with subdomain.company.com
5. Uploaded phishing page

Impact:
- Credential theft from employees
- Brand reputation damage
- Customer data exposure

Remediation:
- Removed CNAME record
- Implemented subdomain monitoring
- Added CNAME approval process
```

## 9.2 Case Study: S3 Bucket Takeover

```text
S3 Bucket takeover example:

Discovery:
- cdn.company.com CNAME old-cdn.s3.amazonaws.com
- S3 bucket didn't exist

Exploitation:
1. Created S3 bucket 'old-cdn'
2. Uploaded malicious JavaScript
3. Accessed via cdn.company.com

Impact:
- Malware distribution to visitors
- Session hijacking
- Crypto mining in browsers

Remediation:
- Removed CNAME record
- Implemented S3 bucket policies
- Added monitoring for S3 changes
```

## 9.3 Case Study: Heroku Takeover

```text
Heroku takeover example:

Discovery:
- api.company.com CNAME old-api.herokuapp.com
- Heroku app was deleted

Exploitation:
1. Created Heroku account
2. Created app 'old-api'
3. Deployed API capturing credentials
4. Accessed via api.company.com

Impact:
- API key theft
- Customer data exposure
- Business logic abuse

Remediation:
- Removed CNAME record
- Implemented Heroku access controls
- Added service monitoring
```

## Assessment Questions 9.1

```text
Q1: What was the root cause in the GitHub Pages case?
Q2: How did S3 bucket takeover impact the business?
Q3: What API security measures would have prevented Heroku takeover?
Q4: What are common themes in these case studies?
Q5: How would you improve the remediation in each case?
```

---

# MODULE 10: FINAL ASSESSMENT

## 10.1 Practical Exam

```text
Subdomain takeover certification exam:

Part 1: Enumeration (25 points)
- Enumerate subdomains
- Identify CNAME records
- Document findings

Part 2: Detection (25 points)
- Detect dangling CNAMEs
- Identify vulnerable services
- Verify takeover possibility

Part 3: Exploitation (25 points)
- Demonstrate takeover
- Document exploitation
- Assess business impact

Part 4: Defense (25 points)
- Recommend preventive measures
- Implement monitoring
- Document defense strategy

Total: 100 points, 80% to pass
```

## 10.2 Certification Requirements

```text
Subdomain Takeover Certification:

1. Complete all 10 modules
2. Pass practical exam
3. Submit 3 takeover reports
4. Demonstrate responsible disclosure
5. Contribute to subdomain security
```

## 10.3 Career Pathways

```text
Career roles for subdomain specialists:

1. Security Researcher
2. Cloud Security Engineer
3. Red Team Operator
4. Application Security Engineer
5. Bug Bounty Hunter
6. DNS Security Specialist
```

---

# APPENDIX A: TOOLS AND RESOURCES

## A.1 Subdomain Takeover Tools

```text
Essential tools:

1. subfinder - Subdomain enumeration
2. amass - Comprehensive enumeration
3. dnsx - DNS resolution
4. httpx - HTTP probing
5. nuclei - Vulnerability scanning
6. Can-I-Take-Over-XYZ - Takeover checks
7. S3Scanner - S3 bucket enumeration
```

## A.2 Online Resources

```text
Learning resources:

1. GitHub: edoverflow/can-i-take-over-xyz
2. OWASP Subdomain Takeover
3. HackTricks Subdomain Takeover
4. Bug bounty reports on takeover
5. Conference talks on DNS security
```

## A.3 Practice Platforms

```text
Hands-on practice:

1. TryHackMe subdomain takeover rooms
2. HackTheBox challenges
3. Custom vulnerable domains
4. Bug bounty programs with subdomains
```

---

# APPENDIX B: GLOSSARY

```text
Key terms:

- CNAME: Canonical Name record
- Dangling CNAME: CNAME pointing to non-existent service
- TTL: Time To Live (DNS cache duration)
- DNSSEC: DNS Security Extensions
- CT: Certificate Transparency
- NXDOMAIN: Non-Existent Domain
- Zone Transfer: DNS replication
- Subdomain Takeover: Hijacking subdomain via CNAME
```

---

*Last Updated: 2026-06-10*
*Version: 2.0*
*Classification: Educational Use Only*