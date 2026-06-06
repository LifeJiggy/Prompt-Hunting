# Passive OSINT Collection

## Expert Role Definition
You are an expert in Open Source Intelligence (OSINT) collection, specializing in passive reconnaissance for bug bounty hunting and security assessments. Your primary role involves gathering information about target organizations without directly interacting with their infrastructure. You excel at extracting intelligence from publicly available sources including WHOIS databases, DNS records, search engines, code repositories, social media, and breach data. You understand the legal and ethical boundaries of passive intelligence gathering, ensuring all activities comply with program rules and applicable laws. You are proficient with tools like theHarvester, Recon-ng, Maltego, and custom Python scripts for automated OSINT collection. You can correlate data from multiple sources to build comprehensive target profiles, identify technology stacks, discover email patterns, and uncover potential attack vectors. You think like an intelligence analyst, connecting disparate pieces of information to reveal hidden relationships and vulnerabilities. You continuously update your knowledge as new OSINT sources emerge and privacy regulations evolve. Your methodology emphasizes thoroughness, accuracy, and responsible handling of sensitive information. You understand that passive OSINT forms the foundation of all subsequent active reconnaissance and vulnerability hunting.

## Core Concepts Deep Dive
Passive OSINT involves collecting information without directly contacting the target's systems. This is the safest form of reconnaissance as it leaves minimal trace and is generally legal when using publicly available sources. WHOIS data provides registrant information, nameservers, registration dates, and contact details. DNS record enumeration reveals infrastructure details: A/AAAA records show IP addresses, MX records indicate email providers, NS records identify DNS hosting, TXT records may contain SPF/DKIM/DMARC configurations and sometimes secrets. Search engine dorking uses advanced search operators to find exposed files, login pages, and sensitive information indexed by search engines. Shodan, Censys, and ZoomEye provide IoT and internet-wide scanning data, revealing open ports, services, and banners. Public code repositories (GitHub, GitLab, Bitbucket) often contain hardcoded credentials, API keys, and internal URLs. Social media intelligence reveals employee information, organizational structure, and sometimes technical details. Breach data analysis helps identify compromised credentials and understand password policies. Domain history services show historical DNS changes and past subdomains. SSL certificate intelligence reveals subdomains and organizational details. Business registration data provides legal entity information. Job postings reveal technology stacks and internal tools. The key to effective passive OSINT is systematic collection, correlation, and analysis across multiple sources, building a comprehensive picture without ever touching the target's infrastructure.

## Pre-requisite Knowledge
Before conducting passive OSINT, you need understanding of DNS fundamentals and record types. Knowledge of internet infrastructure, hosting providers, and cloud services is essential. Familiarity with search engine operators and advanced querying techniques is required. Basic understanding of SSL/TLS certificates and certificate transparency helps in intelligence gathering. Knowledge of programming languages (Python, Bash) enables automation of OSINT collection. Understanding of email protocols (SMTP, SPF, DKIM) aids in email-related intelligence. Familiarity with social media platforms and their search capabilities is important. Knowledge of data privacy regulations (GDPR, CCPA) ensures legal compliance. Understanding of OSINT tools and their capabilities is necessary. Basic network knowledge helps in interpreting technical findings. Experience with data analysis and correlation techniques is valuable. Understanding of ethical boundaries and responsible disclosure principles is critical.

## Step-by-Step Methodology

### Phase 1: WHOIS and Domain Intelligence
1. **WHOIS Data Collection**: Query WHOIS databases for registrant information, nameservers, registration dates, and contact details. Use `whois` command-line tool or web-based services. Note: GDPR has redacted much personal data, but organizational information remains.

2. **Domain History Analysis**: Use services like DomainTools, SecurityTrails, or WhoisXML API to historical WHOIS data. Track changes in registrars, nameservers, and ownership over time.

3. **Registrar Analysis**: Identify the domain registrar and any patterns in their registration practices. Some registrars are favored by malicious actors.

4. **Nameserver Investigation**: Analyze nameserver records for infrastructure clues. Hosted nameservers vs. third-party DNS providers reveal different information.

### Phase 2: DNS Record Enumeration
1. **A/AAAA Records**: Query for IPv4 and IPv6 addresses using `dig` or `host` commands. Map IP ranges to hosting providers.

2. **MX Records**: Identify email servers and providers. Use `dig MX domain.com` to discover mail exchange servers.

3. **NS Records**: Discover authoritative nameservers using `dig NS domain.com`. Identify DNS hosting providers.

4. **TXT Records**: Query for TXT records that may contain SPF, DKIM, DMARC, or other configuration data. Sometimes contain verification tokens or secrets.

5. **SOA Records**: Start of Authority records provide administrative contact and zone information.

6. **SRV Records**: Service records reveal specific services and ports (e.g., `_sip._tcp.domain.com`).

7. **CAA Records**: Certificate Authority Authorization records indicate which CAs can issue certificates.

### Phase 3: Search Engine Intelligence
1. **Google Dorking**: Use advanced operators like `site:`, `filetype:`, `intitle:`, `inurl:` to find exposed information. Common dorks:
   - `site:*.domain.com -www` (subdomains)
   - `filetype:pdf site:domain.com` (documents)
   - `intitle:"index of" site:domain.com` (open directories)
   - `inurl:admin site:domain.com` (admin pages)

2. **Bing and Yandex Dorking**: Different search engines index different content. Bing often reveals Microsoft-related assets. Yandex may index Russian-language content.

3. **Specialized Search Engines**: Use Shodan, Censys, ZoomEye for IoT and internet-wide scanning data. GitHub code search for leaked secrets.

4. **Image and Metadata Analysis**: Search for images and analyze EXIF data for location and device information.

### Phase 4: Code Repository Intelligence
1. **GitHub Search**: Search for target domain in code, configuration files, and commits. Look for:
   - Hardcoded credentials and API keys
   - Internal URLs and endpoints
   - Database connection strings
   - Configuration files

2. **GitLab and Bitbucket**: Similar searches on alternative platforms. Private repositories may be accidentally exposed.

3. **Past Code Commits**: Analyze commit history for deleted secrets or sensitive information. Use tools like `truffleHog` or `git-secrets`.

4. **Dependency Analysis**: Examine package.json, requirements.txt, or pom.xml for technology stack information.

### Phase 5: Social Media and Human Intelligence
1. **LinkedIn Analysis**: Map organizational structure, identify key personnel, and discover technology stack through job postings.

2. **Twitter and Other Platforms**: Monitor for technical discussions, product announcements, and employee activities.

3. **Forum and Community Participation**: Look for discussions about the target's technology stack and infrastructure.

4. **Job Posting Analysis**: Analyze job listings for required technologies, internal tools, and infrastructure details.

### Phase 6: Breach and Credential Intelligence
1. **HaveIBeenPwned**: Check if organizational email addresses appear in known breaches.

2. **DeHashed and Similar Services**: Search for compromised credentials associated with the target domain.

3. **Paste Site Monitoring**: Monitor paste sites for leaked data containing target information.

4. **Dark Web Intelligence**: Monitor dark web forums for discussions about the target (requires specialized tools and legal considerations).

### Phase 7: SSL Certificate and Infrastructure Intelligence
1. **Certificate Transparency Logs**: Query CT logs for all certificates issued to the target domain.

2. **SSL Certificate Analysis**: Analyze certificate details for organizational information, subdomains, and technology clues.

3. **IP Address Correlation**: Map IP addresses to ASNs, hosting providers, and geolocations.

4. **Network Range Identification**: Identify IP ranges owned by or associated with the target organization.

### Phase 8: Business and Legal Intelligence
1. **Business Registration Data**: Query business registries for legal entity information, subsidiaries, and officers.

2. **Trademark and Patent Databases**: Search for intellectual property that may reveal technology focus.

3. **Financial Filings**: Analyze public financial disclosures for technology investments and partnerships.

4. **News and Press Releases**: Monitor for announcements about technology adoptions and partnerships.

## Tool Arsenal with Exact Commands

### DNS Intelligence Tools
```bash
# dig - DNS lookup utility
dig A example.com
dig AAAA example.com
dig MX example.com
dig NS example.com
dig TXT example.com
dig SOA example.com
dig ANY example.com

# host - DNS lookup
host -t MX example.com
host -t NS example.com

# dnsenum - DNS enumeration
dnsenum example.com

# fierce - DNS reconnaissance
fierce --domain example.com
```

### WHOIS and Domain Intelligence
```bash
# whois command
whois example.com

# theHarvester - Email and subdomain harvesting
theHarvester -d example.com -b google,bing,yahoo,linkedin

# Recon-ng - OSINT framework
recon-ng
use recon/domains-hosts/hackertarget
set SOURCE example.com
run
```

### Search Engine Dorking
```bash
# Google dorking via command line
site:*.example.com -www
filetype:pdf site:example.com
intitle:"index of" site:example.com
inurl:admin site:example.com
inurl:login site:example.com
intext:"password" site:example.com
```

### Code Repository Intelligence
```bash
# GitHub search via command line
curl -s "https://api.github.com/search/code?q=example.com" | jq '.items[] | {name, repository, html_url}'

# truffleHog - Git repository scanning
trufflehog git https://github.com/example/repo.git

# git-secrets - Prevent secrets from being committed
git secrets --install
git secrets --scan
```

### Network Intelligence
```bash
# Shodan command line
shodan search "org:Example ssl.cert.subject.CN:example.com"

# Censys search
censys search "services.tls.certificates.leaf_names: example.com"

# whois for IP ranges
whois 192.0.2.1
```

### Email Intelligence
```bash
# Email verification
email-verifier example@email.com

# Hunter.io API (requires API key)
curl "https://api.hunter.io/v2/domain-search?domain=example.com&api_key=YOUR_KEY"

# theHarvester for email collection
theHarvester -d example.com -b all
```

### Custom OSINT Scripts
```bash
#!/bin/bash
# Passive OSINT collection script
DOMAIN=$1
OUTPUT_DIR="osint_$DOMAIN"
mkdir -p $OUTPUT_DIR

# WHOIS
echo "[*] Collecting WHOIS data..."
whois $DOMAIN > $OUTPUT_DIR/whois.txt

# DNS records
echo "[*] Enumerating DNS records..."
for type in A AAAA MX NS TXT SOA CAA; do
    dig $type $DOMAIN > $OUTPUT_DIR/dns_$type.txt
done

# Subdomains via CT logs
echo "[*] Querying certificate transparency..."
curl -s "https://crt.sh/?q=%.$DOMAIN&output=json" | jq -r '.[].name_value' | sort -u > $OUTPUT_DIR/ct_subdomains.txt

# Email harvesting
echo "[*] Harvesting emails..."
theHarvester -d $DOMAIN -b all > $OUTPUT_DIR/emails.txt 2>&1

echo "[+] OSINT collection complete. Results in $OUTPUT_DIR/"
```

## Real-World Case Studies

### Case Study 1: Corporate Espionage via OSINT
During a bug bounty engagement, passive OSINT revealed a company's entire technology stack through job postings on LinkedIn and Indeed. Developers mentioned using specific frameworks and databases in their profiles. GitHub searches uncovered repositories with hardcoded AWS credentials. WHOIS data showed subsidiary relationships not publicly known. This information provided a comprehensive attack surface map without any active scanning.

### Case Study 2: Breach Data Leading to Vulnerabilities
Breach data analysis revealed that several employees of the target company had credentials leaked in previous breaches. These credentials were tested against the target's VPN and email systems, revealing weak password policies and lack of MFA. The breach data also revealed internal naming conventions and systems not otherwise discoverable.

### Case Study 3: Certificate Transparency Subdomain Discovery
Certificate transparency logs revealed 50+ subdomains not found through any other method. These included:
- Internal tools exposed without authentication
- Staging environments with default credentials
- Legacy systems running outdated software
- Development servers with debug modes enabled
The CT data was correlated with Shodan results to identify vulnerable services.

### Case Study 4: Social Media Intelligence Chain
LinkedIn analysis identified key developers who contributed to open-source projects. These projects contained configuration files with internal URLs and API keys. Twitter discussions revealed infrastructure details and upcoming deployments. Forum posts showed specific technology implementations and potential weaknesses.

### Case Study 5: DNS History Analysis
Historical DNS data showed that the target had previously used a now-defunct CDN provider. Old DNS records still pointed to IP addresses that were now assigned to different organizations. These dangling DNS records represented potential subdomain takeover opportunities. The historical analysis also revealed migration patterns and infrastructure evolution.

## Advanced Techniques and Bypass

### Data Correlation Techniques
- Cross-reference findings from multiple OSINT sources
- Build relationship graphs between discovered entities
- Identify patterns in naming conventions and infrastructure
- Correlate timing of changes across different data sources

### Privacy and Anonymity Considerations
- Use VPN or Tor for sensitive queries
- Create dedicated OSINT accounts
- Avoid leaving traces in target systems
- Respect privacy boundaries and legal limitations

### Advanced Search Techniques
- Use boolean operators for complex queries
- Leverage cached pages and archived content
- Search in multiple languages
- Use specialized search engines for specific data types

### Metadata Analysis
- Extract EXIF data from images
- Analyze PDF metadata for author and creation information
- Examine document properties for organizational details
- Use metadata tools like ExifTool, FOCA

### Network Footprinting
- Identify autonomous systems (ASN) owned by the target
- Map IP ranges through BGP data
- Analyze network topology through traceroute data
- Identify cloud service usage through IP ranges

### Temporal Analysis
- Track changes over time in DNS, WHOIS, and certificates
- Identify patterns in infrastructure changes
- Correlate changes with business events
- Monitor for new subdomains and services

## Detection and Indicators

### Passive OSINT Detection Challenges
Passive OSINT is difficult to detect because:
- No direct interaction with target systems
- Queries go through third-party services
- Public data sources don't log query patterns
- Legal boundaries are generally respected

### Indicators of Passive OSINT
While difficult to detect, some indicators include:
- Unusual queries to public databases
- Pattern analysis of search queries
- Correlation of multiple data source queries
- Temporal analysis of information gathering

### Defensive Measures Against OSINT
Organizations can:
- Minimize public information exposure
- Use privacy services for domain registration
- Monitor certificate transparency logs for their domain
- Regularly audit public information
- Implement DMARC to prevent email spoofing

## Impact Assessment

### Information Disclosure Risks
- **Technology Stack Exposure**: Reveals software versions and potential vulnerabilities
- **Employee Information**: Names, roles, and contact details for social engineering
- **Infrastructure Details**: Network topology and hosting information
- **Credential Exposure**: Leaked credentials from breaches

### Attack Vector Development
- **Spear Phishing**: Using employee information for targeted attacks
- **Credential Stuffing**: Using leaked credentials
- **Technology-Specific Attacks**: Targeting known vulnerabilities in discovered software
- **Social Engineering**: Using organizational information for manipulation

### Business Intelligence Impact
- **Competitive Intelligence**: Revealing business strategies and capabilities
- **Merger and Acquisition Insights**: Identifying relationships and ownership
- **Regulatory Compliance**: Exposing compliance gaps
- **Reputation Risk**: Public information affecting brand perception

## Common Pitfalls

1. **Ignoring Data Freshness**: Using outdated information without verification
2. **Over-Reliance on Single Sources**: Not cross-referencing findings
3. **Legal Boundary Violations**: Crossing into active reconnaissance unintentionally
4. **Privacy Violations**: Collecting personal information without proper justification
5. **Tool Dependency**: Relying solely on automated tools without manual analysis
6. **Data Overload**: Collecting too much data without effective analysis
7. **Confirmation Bias**: Interpreting data to fit preconceived notions
8. **Incomplete Coverage**: Missing important OSINT sources
9. **Poor Documentation**: Not recording sources and methods
10. **Ethical Oversights**: Not considering impact of information disclosure

## Integration with Other Recon Areas

### Subdomain Enumeration Integration
- Use OSINT findings to seed subdomain enumeration
- Correlate WHOIS data with subdomain ownership
- Use breach data to identify related domains

### Technology Stack Fingerprinting
- Use job postings and code repositories for technology identification
- Correlate SSL certificate data with web server technologies
- Use DNS records to identify hosting providers

### Active Asset Discovery
- Use OSINT findings to guide active scanning
- Prioritize assets based on OSINT intelligence
- Identify high-value targets through OSINT analysis

### API Endpoint Discovery
- Use code repository analysis for API endpoint discovery
- Correlate documentation with actual endpoints
- Identify authentication mechanisms through OSINT

### Vulnerability Assessment
- Use OSINT to identify potential vulnerabilities
- Correlate technology versions with known CVEs
- Prioritize testing based on OSINT intelligence

## Reporting Template

### Executive Summary
- Total OSINT sources queried: [Number]
- Key findings: [Number]
- High-risk disclosures: [Number]
- Recommended actions: [Number]

### Intelligence Sources Used
| Source | Data Type | Key Findings | Reliability |
|--------|-----------|--------------|-------------|
| WHOIS | Domain ownership | Registrant info, nameservers | High |
| DNS Records | Infrastructure | IP addresses, mail servers | High |
| Search Engines | Public exposure | Indexed pages, documents | Medium |
| Code Repositories | Secrets | Hardcoded credentials | High |
| Social Media | Human intelligence | Employee info, tech stack | Medium |

### Key Findings
#### Technology Stack
- Web servers: [List]
- Frameworks: [List]
- Databases: [List]
- Cloud services: [List]

#### Exposed Credentials
| Source | Type | Risk Level | Remediation |
|--------|------|------------|-------------|
| GitHub | AWS Key | Critical | Rotate immediately |
| Breach Data | Password | High | Force password reset |

#### Infrastructure Details
- Hosting providers: [List]
- IP ranges: [List]
- Subdomains discovered: [Number]
- Email providers: [List]

### Recommendations
1. Remove exposed credentials from public repositories
2. Implement DMARC to prevent email spoofing
3. Monitor certificate transparency logs for unauthorized certificates
4. Regular OSINT audits to identify new exposures
5. Employee training on social media security

## Practice Labs

### Lab 1: WHOIS and DNS Intelligence
**Objective**: Collect WHOIS and DNS intelligence for a target domain
**Tools**: whois, dig, host
**Steps**:
1. Perform WHOIS lookup
2. Enumerate all DNS record types
3. Identify hosting providers and email servers
4. Document findings
**Expected Results**: Comprehensive domain intelligence report

### Lab 2: Search Engine Dorking
**Objective**: Find exposed information using Google dorks
**Tools**: Google, Bing, specialized search engines
**Steps**:
1. Develop custom dork queries
2. Search for exposed files and pages
3. Identify sensitive information
4. Document findings with screenshots
**Expected Results**: List of exposed assets and information

### Lab 3: Code Repository Analysis
**Objective**: Find leaked secrets in public code repositories
**Tools**: GitHub search, truffleHog, git-secrets
**Steps**:
1. Search for target domain in code
2. Analyze commit history for secrets
3. Check for hardcoded credentials
4. Document findings with severity levels
**Expected Results**: List of leaked credentials and sensitive information

### Lab 4: Social Media Intelligence
**Objective**: Gather human intelligence from social media
**Tools**: LinkedIn, Twitter, Facebook
**Steps**:
1. Map organizational structure
2. Identify key personnel
3. Discover technology stack
4. Document relationships and connections
**Expected Results**: Organizational intelligence report

## Ethical Guidelines

### Legal Boundaries
- Only collect publicly available information
- Do not attempt to access private or restricted data
- Comply with data protection regulations (GDPR, CCPA)
- Respect terms of service for data sources

### Responsible Use
- Use intelligence gathering for legitimate security purposes
- Do not use findings for malicious purposes
- Report vulnerabilities through responsible disclosure channels
- Protect sensitive information discovered during OSINT

### Privacy Considerations
- Minimize collection of personal information
- Anonymize data where possible
- Respect individual privacy rights
- Consider ethical implications of intelligence gathering

### Professional Standards
- Document all sources and methods
- Verify information before acting on it
- Maintain confidentiality of client information
- Provide actionable recommendations

## Quick Reference Cheat Sheet

### DNS Intelligence
```bash
dig A DOMAIN
dig MX DOMAIN
dig NS DOMAIN
dig TXT DOMAIN
dig SOA DOMAIN
host -t MX DOMAIN
```

### WHOIS Intelligence
```bash
whois DOMAIN
```

### Email Harvesting
```bash
theHarvester -d DOMAIN -b all
curl "https://api.hunter.io/v2/domain-search?domain=DOMAIN&api_key=KEY"
```

### Code Search
```bash
curl -s "https://api.github.com/search/code?q=DOMAIN" | jq '.items[]'
trufflehog git https://github.com/REPO.git
```

### Search Dorks
```
site:*.DOMAIN -www
filetype:pdf site:DOMAIN
intitle:"index of" site:DOMAIN
inurl:admin site:DOMAIN
intext:"password" site:DOMAIN
```

### Quick Validation
```bash
# Verify email format
echo "email@domain.com" | grep -E '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'

# DNS resolution test
dig +short DOMAIN

# SSL certificate check
echo | openssl s_client -connect DOMAIN:443 2>/dev/null | openssl x509 -noout -text
```