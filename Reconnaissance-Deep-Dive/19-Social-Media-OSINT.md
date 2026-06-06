# 19. Social Media OSINT for Bug Bounty Recon

## Expert Role Definition

You are a specialized Open Source Intelligence (OSINT) researcher focusing on social media intelligence gathering for bug bounty reconnaissance. You understand that social media platforms contain a wealth of information about organizations, employees, technology choices, and security practices. You can analyze LinkedIn profiles, Twitter activity, Facebook pages, Instagram posts, Reddit discussions, and YouTube content to extract actionable intelligence for security assessments. You approach social media OSINT with the systematic precision of an intelligence analyst and the creative thinking of an attacker. You know that social media platforms reveal information that organizations do not intend to disclose publicly including internal tools, development practices, and security incidents. You maintain expertise in social media platform APIs, search techniques, data correlation methods, and privacy considerations. You understand that social media OSINT is not just about collecting data but about correlating information from multiple sources to build a comprehensive picture of the target. You think like a security researcher who uses social media for reconnaissance and like a privacy-conscious individual who understands the implications of information disclosure.

## Core Concepts

### Social Media OSINT Fundamentals

Social media platforms are structured databases of human activity that reveal organizational information through multiple vectors.

**Platform Diversity**: Different platforms reveal different information:
- **LinkedIn**: Professional profiles, job postings, company information, technology stack
- **Twitter**: Real-time discussions, security announcements, developer activity
- **Facebook**: Company pages, employee connections, event information
- **Instagram**: Visual content, office locations, employee activities
- **Reddit**: Technical discussions, security concerns, developer opinions
- **YouTube**: Technical tutorials, product demonstrations, employee presentations

**Information Categories**: Social media reveals multiple categories of information:
- **Employee Information**: Names, roles, skills, connections, activities
- **Technology Stack**: Tools, frameworks, platforms mentioned in posts
- **Security Practices**: Security policies, incidents, vulnerabilities discussed
- **Infrastructure Details**: Hosting providers, cloud services, internal tools
- **Business Intelligence**: Partnerships, clients, projects, roadmap

### Social Media Intelligence Gathering

Intelligence gathering from social media requires systematic approaches:

**Platform-Specific Techniques**: Each platform has unique search capabilities and data structures. Understanding these differences enables targeted intelligence gathering.

**Advanced Search Operators**: Social media platforms support advanced search queries that filter results by date, location, content type, and other criteria.

**API Access**: Many platforms provide APIs for programmatic access to data, enabling automated intelligence gathering at scale.

**Data Correlation**: Combining information from multiple platforms creates a more complete picture than analyzing any single platform.

### Social Media Privacy Considerations

Social media OSINT must balance intelligence gathering with privacy considerations:

**Public vs Private Data**: Only publicly available information should be collected and analyzed. Private information requires explicit authorization.

**Data Protection Laws**: Regulations like GDPR and CCPA restrict how personal data can be collected and used. Understanding these restrictions is essential.

**Ethical Boundaries**: OSINT should be performed ethically, respecting individual privacy and organizational boundaries.

**Responsible Disclosure**: Information discovered through social media OSINT should be reported responsibly through appropriate channels.

### Social Media Analysis Techniques

Analyzing social media data requires specialized techniques:

**Temporal Analysis**: Tracking changes over time reveals patterns and trends.

**Network Analysis**: Mapping connections between individuals and organizations reveals relationships.

**Sentiment Analysis**: Understanding opinions and attitudes provides context for findings.

**Content Analysis**: Extracting specific information from posts, comments, and interactions.

## Pre-requisite Knowledge

Before mastering social media OSINT, you should understand social media platform structures and their data models. Knowledge of search engine operators and advanced search techniques is essential. Familiarity with data analysis and correlation methods helps in processing collected information. Understanding of privacy laws and ethical considerations ensures responsible OSINT practices.

## Step-by-Step Methodology

### Phase 1: LinkedIn Intelligence Gathering

Analyze LinkedIn for professional information about the target organization.

```bash
# Search for company employees
curl -s "https://www.linkedin.com/company/target-corp/people/" -H "User-Agent: Mozilla/5.0"

# Search for specific job titles
site:linkedin.com "target.com" "security engineer"
site:linkedin.com "target.com" "developer"
site:linkedin.com "target.com" "admin"

# Search for technology mentions
site:linkedin.com "target.com" "aws" OR "azure" OR "gcp"
site:linkedin.com "target.com" "python" OR "java" OR "javascript"

# Search for job postings
site:linkedin.com/jobs "target.com"
```

### Phase 2: Twitter Intelligence Gathering

Analyze Twitter for real-time discussions and security information.

```bash
# Search for company mentions
curl -s "https://twitter.com/search?q=target.com&src=typed_query"

# Search for security discussions
site:twitter.com "target.com" security
site:twitter.com "target.com" vulnerability
site:twitter.com "target.com" breach

# Search for developer activity
site:twitter.com "target.com" developer
site:twitter.com "target.com" api
site:twitter.com "target.com" github

# Search for technology mentions
site:twitter.com "target.com" aws
site:twitter.com "target.com" kubernetes
site:twitter.com "target.com" docker
```

### Phase 3: Facebook Intelligence Gathering

Analyze Facebook for company information and employee connections.

```bash
# Search for company page
site:facebook.com "target corp" OR "target company"

# Search for employee posts
site:facebook.com "works at target"
site:facebook.com "target employee"

# Search for technology discussions
site:facebook.com "target.com" technology
site:facebook.com "target.com" security

# Search for events
site:facebook.com "target" event
site:facebook.com "target" conference
```

### Phase 4: Instagram Intelligence Gathering

Analyze Instagram for visual content and location information.

```bash
# Search for company hashtags
site:instagram.com #target
site:instagram.com #targetcorp

# Search for office locations
site:instagram.com target office
site:instagram.com target headquarters

# Search for employee content
site:instagram.com "works at target"
site:instagram.com "target employee"

# Search for technology events
site:instagram.com target hackathon
site:instagram.com target meetup
```

### Phase 5: Reddit Intelligence Gathering

Analyze Reddit for technical discussions and security concerns.

```bash
# Search for company discussions
site:reddit.com "target.com"
site:reddit.com "target corp"

# Search for security discussions
site:reddit.com "target.com" security
site:reddit.com "target.com" vulnerability
site:reddit.com "target.com" bug bounty

# Search for technology discussions
site:reddit.com "target.com" api
site:reddit.com "target.com" developer
site:reddit.com "target.com" stack

# Search for employee discussions
site:reddit.com "works at target"
site:reddit.com "target employee"
```

### Phase 6: YouTube Intelligence Gathering

Analyze YouTube for technical content and presentations.

```bash
# Search for company channel
site:youtube.com "target corp" OR "target company"

# Search for technical presentations
site:youtube.com "target.com" presentation
site:youtube.com "target.com" conference
site:youtube.com "target.com" talk

# Search for product demonstrations
site:youtube.com "target" demo
site:youtube.com "target" tutorial

# Search for employee content
site:youtube.com "target employee"
site:youtube.com "works at target"
```

### Phase 7: Social Media Account Discovery

Discover social media accounts associated with the target organization.

```bash
# Search for social media profiles
site:twitter.com "target.com"
site:linkedin.com/company "target"
site:facebook.com "target corp"
site:instagram.com "target"

# Search for employee social media
site:twitter.com "works at target"
site:linkedin.com "target" "engineer"

# Search for technology accounts
site:github.com "target.com"
site:gitlab.com "target.com"
site:bitbucket.org "target.com"
```

### Phase 8: Social Media Data Correlation

Correlate information from multiple social media sources.

```bash
# Combine LinkedIn and Twitter data
python3 -c "
import json

# Load LinkedIn data
linkedin_data = {
    'employees': ['John Doe - Security Engineer', 'Jane Smith - Developer'],
    'technology': ['AWS', 'Python', 'React']
}

# Load Twitter data
twitter_data = {
    'mentions': ['@target discussing security', '@target posting about API'],
    'technology': ['AWS', 'Kubernetes', 'Docker']
}

# Correlate technology mentions
common_tech = set(linkedin_data['technology']) & set(twitter_data['technology'])
print(f'Common technology mentions: {common_tech}')

# Correlate employee information
for employee in linkedin_data['employees']:
    print(f'Employee: {employee}')
"
```

## Tool Arsenal with Exact Commands

### LinkedIn Tools

```bash
# LinkedIn search operators
site:linkedin.com "target.com" "security"
site:linkedin.com "target.com" "developer"
site:linkedin.com/company "target" "employees"

# LinkedIn profile analysis
curl -s "https://www.linkedin.com/in/johndoe" -H "User-Agent: Mozilla/5.0"

# LinkedIn company analysis
curl -s "https://www.linkedin.com/company/target" -H "User-Agent: Mozilla/5.0"
```

### Twitter Tools

```bash
# Twitter search operators
site:twitter.com "target.com" security
site:twitter.com "target.com" api
site:twitter.com "target.com" github

# Twitter API access
curl -s "https://api.twitter.com/2/tweets/search/recent?query=target.com" -H "Authorization: Bearer TOKEN"

# Twitter profile analysis
curl -s "https://twitter.com/target" -H "User-Agent: Mozilla/5.0"
```

### Reddit Tools

```bash
# Reddit search operators
site:reddit.com "target.com" security
site:reddit.com "target.com" api
site:reddit.com "target.com" bug bounty

# Reddit API access
curl -s "https://www.reddit.com/search.json?q=target.com"

# Reddit profile analysis
curl -s "https://www.reddit.com/user/target_employee" -H "User-Agent: Mozilla/5.0"
```

### Social Media Analysis Tools

```bash
# Sherlock for username discovery
sherlock target_employee

# SpiderFoot for OSINT
spiderfoot -s target.com -m sfp_socialmedia

# Maltego for social media analysis
maltego -t Company -p target.com
```

### Python Scripts

```bash
# Social media OSINT script
python3 -c "
import requests
import json

target = 'target.com'
platforms = {
    'twitter': f'https://twitter.com/search?q={target}',
    'linkedin': f'https://www.linkedin.com/company/{target}',
    'reddit': f'https://www.reddit.com/search.json?q={target}'
}

for platform, url in platforms.items():
    try:
        r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        print(f'{platform}: {r.status_code}')
    except Exception as e:
        print(f'{platform}: {e}')
"

# Username discovery script
python3 -c "
import requests
target = 'target_employee'
platforms = [
    f'https://twitter.com/{target}',
    f'https://github.com/{target}',
    f'https://reddit.com/user/{target}'
]
for url in platforms:
    try:
        r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        if r.status_code == 200:
            print(f'[+] Found: {url}')
    except:
        pass
"
```

## Real-World Case Studies

### Case Study 1: LinkedIn Employee Enumeration

During a bug bounty engagement, LinkedIn analysis revealed 47 employees of the target organization. By analyzing their profiles, I discovered that 12 employees had GitHub profiles with public repositories. Analysis of these repositories revealed code samples that contained internal API endpoints and development patterns. Three repositories contained hardcoded credentials that were still valid. The LinkedIn profiles also revealed the technology stack used by the organization including specific frameworks, libraries, and tools.

### Case Study 2: Twitter Security Discussion Analysis

Twitter analysis revealed that the target organization had experienced a security incident in the previous year. The incident was discussed by security researchers and employees, revealing details about the vulnerability exploited and the response process. The discussion revealed that the organization had a bug bounty program but had not addressed all reported vulnerabilities. The Twitter analysis also revealed that the organization used specific security tools and services, providing targets for further investigation.

### Case Study 3: Reddit Developer Discussion

Reddit analysis revealed discussions by developers who had worked at the target organization. These discussions included technical details about the organization's infrastructure, development practices, and security policies. One discussion revealed that the organization had deprecated an API endpoint but had not fully removed it from production. This information was used to discover and test the deprecated endpoint, which contained a SQL injection vulnerability.

### Case Study 4: YouTube Technical Presentation

YouTube analysis revealed a technical presentation by a senior developer at the target organization. The presentation included architectural diagrams, code samples, and infrastructure details. The presentation revealed the organization's use of specific cloud services, database systems, and security configurations. This information was used to identify potential attack vectors and tailor security testing to the organization's specific technology stack.

### Case Study 5: Instagram Location Intelligence

Instagram analysis revealed photos from the target organization's office locations. The photos included badges, equipment, and office layouts that provided physical security information. The Instagram analysis also revealed employee activities and events that provided timing information for social engineering attacks. The location data from Instagram posts revealed the organization's office locations and potential remote work arrangements.

## Advanced Techniques and Bypass

### Social Media API Automation

Use APIs for automated social media intelligence gathering.

```bash
# Twitter API v2
curl -s "https://api.twitter.com/2/tweets/search/recent?query=target.com&max_results=100" -H "Authorization: Bearer TOKEN"

# Reddit API
curl -s "https://www.reddit.com/search.json?q=target.com&limit=100"

# LinkedIn API (limited access)
curl -s "https://api.linkedin.com/v2/people?q==target.com" -H "Authorization: Bearer TOKEN"
```

### Social Media Correlation Analysis

Correlate information from multiple social media platforms.

```bash
# Correlate LinkedIn and GitHub
python3 -c "
import requests
import json

# LinkedIn employees
employees = ['john_doe', 'jane_smith']

# Check GitHub profiles
for employee in employees:
    url = f'https://api.github.com/users/{employee}'
    r = requests.get(url)
    if r.status_code == 200:
        data = json.loads(r.text)
        print(f'{employee}: {data.get(\"public_repos\", 0)} public repos')
"

# Correlate Twitter and LinkedIn
python3 -c "
import requests
import json

# Twitter mentions
twitter_url = 'https://twitter.com/search?q=target.com'
# LinkedIn company
linkedin_url = 'https://www.linkedin.com/company/target'

# Analyze correlation
print('Correlating Twitter and LinkedIn data...')
"
```

### Social Media Network Analysis

Map social media networks to identify key individuals and relationships.

```bash
# Analyze Twitter followers
curl -s "https://api.twitter.com/2/users/FOLLOWERS_ID/followers" -H "Authorization: Bearer TOKEN"

# Analyze LinkedIn connections
curl -s "https://api.linkedin.com/v2/connections" -H "Authorization: Bearer TOKEN"

# Map social network
python3 -c "
import networkx as nx
import matplotlib.pyplot as plt

# Create social network graph
G = nx.Graph()
G.add_edge('John', 'Jane')
G.add_edge('John', 'Target Corp')
G.add_edge('Jane', 'Target Corp')

# Visualize network
nx.draw(G, with_labels=True)
plt.show()
"
```

## Detection and Indicators

### Signs of Social Media OSINT

Monitor for the following indicators:
- Repeated queries to social media platforms
- Automated access patterns
- Unusual search queries for employee information
- Analysis of company social media accounts

### Platform Detection Methods

Social media platforms can detect OSINT activities through:
- API rate limiting and access controls
- User-agent analysis for automated tools
- Query pattern analysis
- IP-based blocking and throttling

## Impact Assessment

### Finding Severity Classification

Social media OSINT findings should be classified based on information disclosed:
- **High**: Exposed credentials, internal API endpoints, security vulnerabilities
- **Medium**: Technology stack details, employee information, infrastructure patterns
- **Low**: Public company information, general technology mentions
- **Informational**: Social media activity patterns, public discussions

## Common Pitfalls

### Not Respecting Platform Terms of Service

Social media platforms have terms of service that restrict automated access and data collection. Always respect these terms and use official APIs when available.

### Overlooking Privacy Settings

Some social media information may be private or restricted. Only collect and analyze publicly available information.

### Ignoring Data Protection Laws

Data protection regulations like GDPR restrict how personal data can be collected and used. Understand and comply with these regulations.

### Not Correlating Multiple Sources

Single-source intelligence is less reliable than correlated multi-source intelligence. Always combine information from multiple social media platforms.

### Forgetting About Ethical Boundaries

Social media OSINT should be performed ethically, respecting individual privacy and organizational boundaries. Avoid intrusive or harmful intelligence gathering.

## Integration with Other Recon Areas

Social media OSINT integrates with other reconnaissance activities:
- **Employee-Linked Assets**: Social media reveals employee information and assets
- **Technology Stack Fingerprinting**: Social media mentions reveal technology choices
- **Source Code Leak Detection**: Social media may contain references to exposed code
- **Configuration File Extraction**: Social media discussions may reveal configuration details
- **API Endpoint Discovery**: Social media may contain API documentation and endpoints

## Reporting Template

### Social Media OSINT Report

**Executive Summary**: Overview of social media OSINT activities and findings.

**Methodology**: Description of social media platforms analyzed, tools used, and data collected.

**Findings Summary**:
- Total social media accounts analyzed
- Employee information discovered
- Technology stack details revealed
- Security information exposed

**Critical/High Findings**:
For each finding:
- Social media source
- Information discovered
- Potential security implications
- Recommended remediation

## Practice Labs

### Lab 1: LinkedIn Employee Enumeration

Practice analyzing LinkedIn for employee information and technology details.

### Lab 2: Twitter Security Analysis

Practice analyzing Twitter for security discussions and vulnerability information.

### Lab 3: Reddit Developer Intelligence

Practice analyzing Reddit for developer discussions and technical details.

### Lab 4: Social Media Account Discovery

Practice discovering social media accounts associated with the target organization.

### Lab 5: Social Media Data Correlation

Practice correlating information from multiple social media sources.

## Ethical Guidelines

Social media OSINT should only be performed on organizations you own or have authorization to test. Only collect and analyze publicly available information. Respect platform terms of service and data protection regulations. Report all discovered vulnerabilities through responsible disclosure channels.

## Quick Reference Cheat Sheet

### LinkedIn Search Commands
```bash
site:linkedin.com "target.com" "security"
site:linkedin.com "target.com" "developer"
site:linkedin.com/company "target" "employees"
```

### Twitter Search Commands
```bash
site:twitter.com "target.com" security
site:twitter.com "target.com" api
site:twitter.com "target.com" github
```

### Reddit Search Commands
```bash
site:reddit.com "target.com" security
site:reddit.com "target.com" api
site:reddit.com "target.com" bug bounty
```

### Social Media Analysis Commands
```bash
sherlock target_employee
spiderfoot -s target.com -m sfp_socialmedia
python3 -c "import requests; print(requests.get('https://twitter.com/target').status_code)"
```