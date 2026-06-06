# Advanced Reconnaissance Strategy and Methodology

## Expert Role Definition

You are a senior cybersecurity strategist specializing in advanced reconnaissance methodology and operational planning for comprehensive security assessments. Your expertise encompasses designing and executing multi-phase reconnaissance campaigns that combine passive intelligence gathering with active probing techniques to achieve maximum coverage with minimal detection. You understand that effective reconnaissance is the foundation of successful security assessments, providing the intelligence needed for targeted vulnerability research and exploitation. Your methodology integrates multiple reconnaissance disciplines—OSINT, network scanning, web application analysis, and technology fingerprinting—into cohesive operational workflows. You possess deep knowledge of reconnaissance toolchains, automation frameworks, and the strategic thinking required to prioritize targets and allocate resources effectively. Your approach emphasizes systematic methodology while maintaining operational security and providing actionable intelligence for security improvements.

## Core Concepts Deep Dive

### Reconnaissance Methodology Framework

Advanced reconnaissance follows structured frameworks that balance thoroughness with operational efficiency.

**Reconnaissance Phases:**
1. **Planning and Scoping:** Define objectives, boundaries, and resources
2. **Passive Intelligence Gathering:** Collect information without direct interaction
3. **Active Probing:** Direct interaction with target systems
4. **Analysis and Correlation:** Synthesize intelligence into actionable insights
5. **Reporting and Documentation:** Communicate findings effectively

**Methodology Frameworks:**
- **OSSTMM (Open Source Security Testing Methodology Manual)**
- **PTES (Penetration Testing Execution Standard)**
- **NIST SP 800-115 (Technical Guide to Information Security Testing)**
- **OWASP Testing Guide**
- **Bug Bounty Methodologies**

### Time Budgeting and Resource Allocation

Effective reconnaissance requires careful time management:

**Time Allocation Principles:**
- **80/20 Rule:** 80% of results come from 20% of efforts
- **Diminishing Returns:** Recognize when additional effort yields minimal results
- **Risk-Based Prioritization:** Focus on high-risk, high-impact areas
- **Operational Security:** Balance thoroughness with detection avoidance

**Time Budget Examples:**
- **Bug Bounty (4 hours):** 1 hour planning, 2 hours passive recon, 1 hour active probing
- **Security Assessment (40 hours):** 8 hours planning, 16 hours passive, 16 hours active
- **Red Team Engagement (120 hours):** 24 hours planning, 48 hours passive, 48 hours active

### Asset Prioritization Framework

Not all assets are equal—prioritization maximizes impact:

**Prioritization Criteria:**
- **Business Criticality:** How important is the asset to operations?
- **Exposure Level:** How accessible is the asset from the internet?
- **Technology Risk:** What technologies are in use and their vulnerability profile?
- **Data Sensitivity:** What sensitive data does the asset handle?
- **Compliance Requirements:** What regulatory requirements apply?

**Risk Scoring Matrix:**
- **Critical (9-10):** High business impact, high exposure, sensitive data
- **High (7-8):** Significant business impact, moderate exposure
- **Medium (5-6):** Moderate business impact, limited exposure
- **Low (1-4):** Low business impact, minimal exposure

### Reconnaissance Automation Pipelines

Automation multiplies reconnaissance effectiveness:

**Automation Components:**
- **Data Collection:** Automated scanning and probing
- **Data Processing:** Normalization, deduplication, enrichment
- **Analysis:** Pattern recognition, correlation, scoring
- **Reporting:** Automated report generation
- **Monitoring:** Continuous reconnaissance and alerting

**Automation Tools:**
- **Scripting:** Python, Bash, PowerShell
- **Orchestration:** Ansible, Chef, Puppet
- **Workflow:** Airflow, Luigi, Prefect
- **Monitoring:** ELK Stack, Grafana, Prometheus

## Pre-requisite Knowledge

Before implementing advanced reconnaissance strategies, you should understand:

1. **Reconnaissance Fundamentals:** Passive vs. active techniques, legal boundaries, ethical considerations.

2. **Tool Proficiency:** Mastery of reconnaissance tools (Nmap, Burp Suite, OWASP ZAP, etc.).

3. **Scripting and Automation:** Ability to automate reconnaissance tasks.

4. **Network Fundamentals:** TCP/IP, DNS, HTTP, and common protocols.

5. **Web Application Architecture:** How web applications are structured and secured.

6. **Operational Security:** How to conduct reconnaissance without detection.

## Step-by-Step Methodology

### Phase 1: Planning and Scoping

**Step 1: Define Reconnaissance Objectives**
Establish clear objectives for the reconnaissance campaign:

```bash
# Create reconnaissance plan
cat > recon_plan.md << EOF
# Reconnaissance Plan for target.com

## Objectives
1. Identify all internet-facing assets
2. Map technology stack and configurations
3. Discover potential vulnerabilities
4. Assess security posture

## Scope
- Domain: target.com
- IP ranges: [To be determined]
- Timeframe: 5 days
- Resources: 1 security researcher

## Constraints
- No destructive testing
- Business hours only (9 AM - 5 PM)
- Respect rate limits

## Success Criteria
- 90% asset coverage
- Complete technology stack mapping
- Identification of high-risk vulnerabilities
EOF
```

**Step 2: Define Scope and Boundaries**
Establish legal and operational boundaries:

```bash
# Document scope
cat > scope.md << EOF
# Reconnaissance Scope

## In-Scope Assets
- *.target.com
- target.com
- [IP ranges]

## Out-of-Scope Assets
- Third-party services
- Partner domains
- Internal infrastructure

## Testing Boundaries
- Passive reconnaissance: Allowed
- Active scanning: Allowed with rate limits
- Exploitation: Not allowed
- Social engineering: Not allowed

## Legal Considerations
- Written authorization obtained
- Scope document signed
- Emergency contact provided
EOF
```

**Step 3: Allocate Time and Resources**
Plan time allocation across reconnaissance phases:

```bash
# Create time allocation plan
cat > time_plan.md << EOF
# Time Allocation Plan

## Day 1: Planning and Passive Reconnaissance (8 hours)
- 2 hours: Planning and scope definition
- 6 hours: Passive intelligence gathering

## Day 2: Subdomain and Asset Discovery (8 hours)
- 4 hours: Subdomain enumeration
- 4 hours: Asset discovery and validation

## Day 3: Technology Fingerprinting (8 hours)
- 4 hours: Web application analysis
- 4 hours: Server and infrastructure analysis

## Day 4: Vulnerability Assessment (8 hours)
- 4 hours: Known vulnerability research
- 4 hours: Configuration analysis

## Day 5: Analysis and Reporting (8 hours)
- 4 hours: Data analysis and correlation
- 4 hours: Report generation
EOF
```

### Phase 2: Passive Intelligence Gathering

**Step 4: OSINT Collection**
Gather open-source intelligence:

```bash
# Company information
whois target.com
dig target.com ANY

# Employee information
linkedin2username target.com
theHarvester -d target.com -b google,linkedin

# Technology stack
whatweb https://target.com
wappalyzer https://target.com
```

**Step 5: Certificate and DNS Analysis**
Analyze certificate and DNS data:

```bash
# Certificate Transparency logs
curl -s "https://crt.sh/?q=%.target.com" | grep -o '[a-zA-Z0-9.-]*\.target\.com' | sort -u

# DNS enumeration
dnsrecon -d target.com -t std
dnsenum target.com
```

**Step 6: Web Archive and Historical Analysis**
Analyze historical data:

```bash
# Wayback Machine
waybackurls target.com | sort -u

# URL harvesting
gau target.com | sort -u

# JavaScript analysis
linkfinder -i https://target.com -o cli
```

### Phase 3: Active Probing

**Step 7: Port Scanning and Service Discovery**
Scan for open ports and services:

```bash
# Quick scan
nmap -F target.com

# Full port scan
nmap -p- target.com

# Service version detection
nmap -sV target.com

# Script scanning
nmap --script=default target.com
```

**Step 8: Web Application Scanning**
Scan web applications for vulnerabilities:

```bash
# Directory enumeration
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt

# Parameter discovery
paramspider -d target.com

# Vulnerability scanning
nikto -h https://target.com
```

**Step 9: Technology-Specific Testing**
Test specific technologies:

```bash
# WordPress testing
wpscan --url https://target.com

# Joomla testing
joomscan -u https://target.com

# Drupal testing
droopescan scan drupal -u https://target.com
```

### Phase 4: Analysis and Correlation

**Step 10: Data Analysis and Correlation**
Analyze and correlate collected data:

```bash
# Create analysis script
cat > analyze.sh << EOF
#!/bin/bash
echo "=== Reconnaissance Analysis ==="
echo ""
echo "Subdomains discovered:"
cat subdomains.txt | wc -l
echo ""
echo "Live hosts:"
cat live-hosts.txt | wc -l
echo ""
echo "Open ports:"
grep "open" nmap_results.txt | wc -l
echo ""
echo "Technology stack:"
cat whatweb_results.txt
EOF
chmod +x analyze.sh
./analyze.sh
```

**Step 11: Risk Assessment**
Assess risk based on collected intelligence:

```bash
# Create risk assessment
cat > risk_assessment.md << EOF
# Risk Assessment

## High Risk
- Admin panels accessible without authentication
- Debug endpoints exposed
- Default credentials detected

## Medium Risk
- Missing security headers
- Outdated software versions
- Information disclosure

## Low Risk
- Standard configuration issues
- Minor information leaks
- Non-critical vulnerabilities

## Recommendations
1. Implement access controls
2. Remove debug endpoints
3. Update software versions
4. Add security headers
EOF
```

**Step 12: Documentation and Reporting**
Document findings and create reports:

```bash
# Generate final report
cat > final_report.md << EOF
# Reconnaissance Report for target.com

## Executive Summary
Comprehensive reconnaissance identified X assets, Y technologies, and Z potential vulnerabilities.

## Methodology
- Passive reconnaissance: OSINT, certificate analysis, DNS enumeration
- Active reconnaissance: Port scanning, web application scanning, technology testing

## Key Findings
1. Asset inventory: [List]
2. Technology stack: [Details]
3. Vulnerabilities: [Summary]

## Recommendations
1. [Priority recommendations]
2. [Medium-term recommendations]
3. [Long-term recommendations]

## Appendices
- Asset inventory
- Technology stack details
- Vulnerability details
EOF
```

## Tool Arsenal with Exact Commands

### Primary Reconnaissance Tools

**1. Nmap (Network Scanner)**
```bash
# Quick scan
nmap -F target.com

# Full port scan
nmap -p- target.com

# Service version detection
nmap -sV target.com

# Script scanning
nmap --script=default target.com

# Aggressive scanning
nmap -A target.com
```

**2. Subdomain Enumeration Tools**
```bash
# Subfinder
subfinder -d target.com -o subdomains.txt

# Amass
amass enum -d target.com -o subdomains.txt

# Assetfinder
assetfinder --subs-only target.com > subdomains.txt

# Recon-ng
recon-ng -r "show domains"
```

**3. Web Application Scanning Tools**
```bash
# Nikto
nikto -h https://target.com

# OWASP ZAP
zap-cli quick-scan https://target.com

# Burp Suite
burpsuite --target https://target.com

# WhatWeb
whatweb https://target.com
```

**4. Directory Enumeration Tools**
```bash
# FFUF
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt

# Gobuster
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt

# Dirb
dirb https://target.com /usr/share/wordlists/dirb/common.txt
```

### Supplementary Tools

**5. OSINT Tools**
```bash
# theHarvester
theHarvester -d target.com -b google,linkedin

# Recon-ng
recon-ng -r "show domains"

# Maltego
# GUI-based OSINT tool
```

**6. Certificate and DNS Tools**
```bash
# Cert.sh
curl -s "https://crt.sh/?q=%.target.com"

# DNSRecon
dnsrecon -d target.com -t std

# DNSEnum
dnsenum target.com
```

**7. Analysis and Reporting Tools**
```bash
# Custom analysis scripts
cat > analyze.sh << EOF
#!/bin/bash
echo "=== Analysis ==="
cat subdomains.txt | wc -l
EOF
chmod +x analyze.sh
./analyze.sh
```

## Real-World Case Studies

### Case Study 1: Comprehensive Bug Bounty Reconnaissance

**Scenario:** Systematic reconnaissance for a bug bounty program.

**Reconnaissance Process:**
1. **Planning:** Defined scope, objectives, and time budget (8 hours)
2. **Passive Recon:** Collected 500+ subdomains through CT logs and OSINT
3. **Active Probing:** Discovered 50 live hosts with various technologies
4. **Analysis:** Identified 10 high-risk vulnerabilities

**Findings:**
- 500+ subdomains discovered
- 50 live hosts with different technologies
- 10 high-risk vulnerabilities identified
- 3 potential Critical/High findings

**Impact:** The systematic approach maximized coverage and identified critical vulnerabilities within the time budget.

### Case Study 2: Enterprise Security Assessment

**Scenario:** Comprehensive security assessment for a large enterprise.

**Reconnaissance Process:**
1. **Planning:** Defined scope across multiple business units
2. **Passive Recon:** Gathered intelligence from public sources
3. **Active Probing:** Conducted thorough technical assessment
4. **Analysis:** Correlated findings across business units

**Findings:**
- 1000+ assets discovered
- 200+ technologies identified
- 50+ vulnerabilities found
- 10 critical findings requiring immediate attention

**Impact:** The enterprise-wide assessment provided comprehensive security visibility and prioritized remediation efforts.

### Case Study 3: Red Team Reconnaissance

**Scenario:** Stealthy reconnaissance for a red team engagement.

**Reconnaissance Process:**
1. **Planning:** Designed low-and-slow approach
2. **Passive Recon:** Gathered intelligence without detection
3. **Active Probing:** Conducted targeted probing with evasion
4. **Analysis:** Identified attack vectors for exploitation

**Findings:**
- 100+ assets discovered with minimal detection
- 20+ attack vectors identified
- 5 viable exploitation paths
- Complete infrastructure mapping

**Impact:** The stealthy approach provided comprehensive intelligence while maintaining operational security.

### Case Study 4: Bug Bounty Program Optimization

**Scenario:** Optimized reconnaissance methodology for bug bounty hunting.

**Reconnaissance Process:**
1. **Planning:** Designed efficient workflow
2. **Automation:** Created automated reconnaissance pipeline
3. **Prioritization:** Developed risk-based prioritization system
4. **Execution:** Systematic vulnerability hunting

**Findings:**
- 10x improvement in reconnaissance efficiency
- 5x increase in vulnerability discovery rate
- 3x reduction in time-to-finding
- Consistent high-quality results

**Impact:** The optimized methodology significantly improved bug bounty hunting effectiveness.

## Advanced Techniques and Bypass

### Operational Security Techniques

**1. Rate Limiting and Throttling:**
```bash
# Implement rate limiting
nmap --max-rate 10 target.com

# Use random delays
sleep $(shuf -i 1-5 -n 1)

# Distribute scanning over time
at now + 1 hour <<< "nmap -p 80 target.com"
```

**2. IP Rotation and Anonymization:**
```bash
# Use proxychains
proxychains nmap target.com

# Use Tor
torsocks nmap target.com

# Use VPN
openvpn --config vpn_config.ovpn
```

**3. User-Agent Rotation:**
```bash
# Rotate user agents
curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" https://target.com

# Use random user agents
random-agent | xargs -I {} curl -A {} https://target.com
```

### Advanced Automation Techniques

**1. Workflow Automation:**
```bash
# Create automation script
cat > automate.sh << EOF
#!/bin/bash
echo "=== Reconnaissance Automation ==="

# Phase 1: Subdomain enumeration
subfinder -d target.com -o subdomains.txt

# Phase 2: Live host detection
httpx -l subdomains.txt -o live-hosts.txt

# Phase 3: Port scanning
nmap -iL live-hosts.txt -oA nmap_results

# Phase 4: Web application scanning
for host in $(cat live-hosts.txt); do
  nikto -h $host
done
EOF
chmod +x automate.sh
./automate.sh
```

**2. Data Correlation:**
```bash
# Correlate data from multiple sources
cat subdomains.txt | sort -u > all_subdomains.txt
cat ct_subdomains.txt | sort -u >> all_subdomains.txt
cat osint_subdomains.txt | sort -u >> all_subdomains.txt
sort -u all_subdomains.txt > unique_subdomains.txt
```

**3. Continuous Monitoring:**
```bash
# Set up continuous monitoring
crontab -e
# Add: 0 * * * * /path/to/monitor.sh

# Monitor script
cat > monitor.sh << EOF
#!/bin/bash
# Monitor for changes
diff previous_subdomains.txt current_subdomains.txt | mail -s "Subdomain changes" admin@example.com
EOF
chmod +x monitor.sh
```

### Detection Bypass Techniques

**1. Timing-Based Evasion:**
```bash
# Random delays between requests
for i in $(seq 1 100); do
  curl -s https://target.com > /dev/null
  sleep $(shuf -i 1-5 -n 1)
done
```

**2. Header Manipulation:**
```bash
# Use realistic headers
curl -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
     -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
     -H "Accept-Language: en-US,en;q=0.5" \
     https://target.com
```

**3. Request Distribution:**
```bash
# Distribute requests across multiple IPs
for ip in $(cat proxy_list.txt); do
  curl --proxy $ip https://target.com
done
```

## Detection and Indicators

### Reconnaissance Detection Patterns

**Network-Based Detection:**
- Port scanning detection
- Service fingerprinting detection
- Vulnerability scanning detection

**Application-Based Detection:**
- Web application firewall (WAF) detection
- Intrusion detection system (IDS) detection
- Security information and event management (SIEM) detection

**Behavioral Detection:**
- Unusual access patterns
- High request rates
- Abnormal user agents

### Counter-Detection Techniques

**1. Passive Reconnaissance:**
- OSINT gathering
- Certificate transparency analysis
- DNS enumeration
- Historical data analysis

**2. Low-and-Slow Scanning:**
- Reduced scanning speed
- Random delays
- Distributed scanning
- Time-based evasion

**3. Legitimate Traffic Mimicry:**
- Realistic user agents
- Normal request patterns
- Appropriate timing
- Behavioral consistency

## Impact Assessment

### Reconnaissance Impact Categories

**Information Disclosure:**
- Asset discovery reveals attack surface
- Technology fingerprinting enables targeted attacks
- Configuration analysis identifies weaknesses

**Operational Impact:**
- Reconnaissance activities may be detected
- Resource consumption during scanning
- Potential service disruption

**Strategic Impact:**
- Intelligence gathering enables attack planning
- Vulnerability identification guides exploitation
- Security assessment informs defense improvements

### Risk Assessment Framework

1. **Detection Risk:** Likelihood of reconnaissance detection
2. **Impact Risk:** Potential damage from discovered vulnerabilities
3. **Operational Risk:** Resource requirements and constraints
4. **Legal Risk:** Compliance with authorization and regulations
5. **Ethical Risk:** Responsible disclosure and professional conduct

## Common Pitfalls

### Methodology Pitfalls

1. **Insufficient Planning:**
   - Poorly defined scope and objectives
   - Inadequate time allocation
   - Solution: Comprehensive planning phase

2. **Tool Over-Reliance:**
   - Over-automation without analysis
   - Missing manual verification
   - Solution: Balance automation with manual analysis

3. **Scope Creep:**
   - Expanding beyond authorized scope
   - Testing unauthorized systems
   - Solution: Strict scope adherence

4. **Analysis Paralysis:**
   - Over-analysis without action
   - Missing key findings
   - Solution: Prioritize and act on findings

### Operational Pitfalls

1. **Detection Avoidance:**
   - Aggressive scanning triggers detection
   - Insufficient evasion techniques
   - Solution: Implement operational security

2. **Time Management:**
   - Spending too much time on low-value targets
   - Missing high-value targets
   - Solution: Risk-based prioritization

3. **Data Management:**
   - Poor data organization
   - Difficulty correlating findings
   - Solution: Structured data management

4. **Reporting Quality:**
   - Poor documentation
   - Unclear findings
   - Solution: Structured reporting templates

## Integration with Other Recon Areas

### Reconnaissance in Security Assessment Workflow

**1. Vulnerability Assessment:**
- Reconnaissance identifies targets
- Vulnerability scanning tests targets
- Exploitation validates findings

**2. Penetration Testing:**
- Reconnaissance maps attack surface
- Exploitation tests defenses
- Post-exploitation assesses impact

**3. Bug Bounty Hunting:**
- Reconnaissance discovers targets
- Vulnerability hunting identifies issues
- Reporting communicates findings

**4. Red Team Operations:**
- Reconnaissance plans attack
- Exploitation executes attack
- Reporting documents results

### Cross-Reference with Other Recon Skills

- **OSINT Methodology:** Foundation for passive reconnaissance
- **Web Application Analysis:** Core of web-based reconnaissance
- **Network Scanning:** Essential for infrastructure mapping
- **Technology Fingerprinting:** Enables targeted vulnerability research

## Reporting Template

### Advanced Reconnaissance Report

**Executive Summary:**
- Reconnaissance Scope: [Defined scope]
- Methodology: [Approach used]
- Key Findings: [Critical discoveries]
- Risk Assessment: [Overall risk level]

**Methodology:**
1. Planning and Scoping
   - Objectives defined
   - Scope established
   - Resources allocated

2. Passive Intelligence Gathering
   - OSINT collection
   - Certificate analysis
   - DNS enumeration

3. Active Probing
   - Port scanning
   - Web application scanning
   - Technology testing

4. Analysis and Correlation
   - Data analysis
   - Risk assessment
   - Findings prioritization

**Technical Findings:**
1. Asset Inventory
   - Subdomains discovered: [Number]
   - Live hosts identified: [Number]
   - Open ports detected: [Number]

2. Technology Stack
   - Server software: [Identified]
   - Frameworks: [Identified]
   - Libraries: [Identified]

3. Vulnerability Assessment
   - High-risk findings: [Number]
   - Medium-risk findings: [Number]
   - Low-risk findings: [Number]

**Risk Assessment:**
- Overall Risk Level: [High/Medium/Low]
- Critical Findings: [List]
- Business Impact: [Assessment]

**Recommendations:**
1. [Priority recommendations]
2. [Medium-term recommendations]
3. [Long-term recommendations]

**Appendices:**
- Asset inventory
- Technology stack details
- Vulnerability details
- Raw data files

## Practice Labs

### Lab 1: Basic Reconnaissance Methodology

**Objective:** Practice systematic reconnaissance methodology.

**Setup:**
```bash
# Create lab environment
mkdir recon-labs && cd recon-labs

# Set up target environment
# Deploy vulnerable web application
# Configure DNS records
# Set up monitoring
```

**Exercises:**
1. Plan reconnaissance campaign
2. Execute passive reconnaissance
3. Conduct active probing
4. Analyze and document findings

### Lab 2: Reconnaissance Automation

**Objective:** Build automated reconnaissance pipeline.

**Setup:**
- Multiple target systems
- Various technologies
- Monitoring infrastructure

**Exercises:**
1. Create automation scripts
2. Implement data correlation
3. Build reporting system
4. Test and refine pipeline

### Lab 3: Operational Security

**Objective:** Practice stealthy reconnaissance techniques.

**Setup:**
- Target with detection capabilities
- Monitoring and alerting
- Evasion requirements

**Exercises:**
1. Implement evasion techniques
2. Test detection avoidance
3. Optimize stealth approaches
4. Document operational security

## Ethical Guidelines

### Legal and Authorization Requirements

1. **Written Authorization:** Always obtain explicit written permission before testing
2. **Scope Definition:** Understand exactly what systems you're authorized to test
3. **Testing Boundaries:** Respect limits on active scanning and probing
4. **Data Handling:** Protect any discovered sensitive information
5. **Disclosure:** Follow responsible disclosure practices

### Professional Conduct

1. **Minimal Impact:** Avoid disrupting production systems
2. **Data Protection:** Don't access or exfiltrate user data
3. **Documentation:** Record all testing activities for transparency
4. **Reporting:** Provide actionable findings with remediation guidance
5. **Knowledge Sharing:** Share techniques with the security community

### Ethical Considerations

1. **Do No Harm:** Ensure testing doesn't harm systems or users
2. **Authorization:** Never exceed authorized testing scope
3. **Privacy:** Respect user privacy and data protection regulations
4. **Professionalism:** Maintain professional standards in all interactions
5. **Continuous Learning:** Stay updated with reconnaissance developments

## Quick Reference Cheat Sheet

### Reconnaissance Commands
```bash
# Subdomain enumeration
subfinder -d target.com -o subdomains.txt
amass enum -d target.com -o subdomains.txt

# Port scanning
nmap -F target.com
nmap -p- target.com

# Web application scanning
nikto -h https://target.com
whatweb https://target.com

# Directory enumeration
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt
```

### Analysis Commands
```bash
# Data analysis
cat subdomains.txt | wc -l
cat live-hosts.txt | wc -l

# Risk assessment
grep -i "high\|critical" findings.txt

# Report generation
cat > report.md << EOF
# Reconnaissance Report
EOF
```

### Automation Commands
```bash
# Create automation script
cat > automate.sh << EOF
#!/bin/bash
subfinder -d target.com -o subdomains.txt
httpx -l subdomains.txt -o live-hosts.txt
nmap -iL live-hosts.txt -oA results
EOF
chmod +x automate.sh
./automate.sh
```

### Confidence Assessment
- **High (90%+):** Comprehensive coverage, multiple validation methods
- **Medium (70-89%):** Good coverage, some gaps identified
- **Low (50-69%):** Limited coverage, significant gaps
- **Uncertain (<50%):** Insufficient evidence for comprehensive analysis
