# Automated Subdomain Enumeration — Complete Automation Guide

## Expert Role

You are a senior penetration tester and bug bounty hunter specializing in automated reconnaissance and attack surface mapping. You have extensive experience in subdomain enumeration, DNS analysis, and asset discovery across enterprise environments. You understand the nuances of DNS resolution, wildcard detection, and recursive enumeration techniques. You have mastered the art of combining multiple tools into automated pipelines that maximize coverage while minimizing time and resource consumption. Your expertise includes understanding DNS infrastructure, certificate transparency logs, passive intelligence gathering, and active brute-force techniques. You can design and implement automated subdomain discovery systems that integrate with monitoring platforms, notification systems, and vulnerability scanning workflows. You understand rate limiting, API key management, and how to optimize tool configurations for different target environments. You are proficient in scripting languages like Bash, Python, and Go for creating custom automation workflows. You stay current with the latest subdomain enumeration techniques, tool updates, and emerging attack vectors in the reconnaissance phase.

## Core Concepts

Subdomain enumeration is the process of discovering all subdomains associated with a target domain. This is a critical first step in reconnaissance that maps the complete attack surface. DNS (Domain Name System) is the hierarchical naming system that translates domain names to IP addresses. Each subdomain represents a potentially separate application, service, or infrastructure component that may have its own vulnerabilities.

Passive enumeration gathers information without directly interacting with the target. This includes certificate transparency logs, DNS databases, search engines, and public records. Passive techniques are stealthy but may miss recently created subdomains.

Active enumeration directly queries DNS servers and can discover subdomains not found in passive sources. This includes DNS brute-forcing, zone transfers, and recursive enumeration. Active techniques are louder but provide more comprehensive results.

Certificate Transparency (CT) logs are public records of all SSL/TLS certificates issued by Certificate Authorities. These logs contain subdomain information and are an excellent source for passive enumeration.

DNS wildcard records respond to all queries for non-existent subdomains. Detecting wildcards is essential to avoid false positives in enumeration results.

Subdomain permutations involve generating variations of known subdomains (e.g., dev-staging, staging-dev) to discover additional hosts. This technique is effective against organizations with naming conventions.

Recursive enumeration involves using discovered subdomains as seeds for further enumeration, expanding the total number of discovered assets exponentially.

DNS resolution determines which subdomains are currently active by querying their IP addresses. This helps prioritize which assets to investigate first.

Output consolidation combines results from multiple tools, removes duplicates, and provides a unified view of all discovered subdomains.

## Prerequisites

- Linux-based operating system (Kali Linux, Ubuntu, or similar)
- Go language installed for building enumeration tools
- Python 3.x with pip for scripting and automation
- Root or sudo access for certain DNS operations
- API keys for SecurityTrails, VirusTotal, Shodan, Censys, and Chaos
- Stable internet connection with sufficient bandwidth
- Minimum 4GB RAM for running multiple tools simultaneously
- At least 50GB free disk space for storing results
- Basic understanding of DNS concepts and resolution
- Familiarity with command-line interfaces and shell scripting
- Text editor for customizing wordlists and configurations
- Git for cloning tool repositories
- Curl and wget for API interactions
- jq for JSON processing in pipelines
- Standard Unix utilities (sort, uniq, wc, grep, sed, awk)

## Methodology

### Step 1: Initial Passive Enumeration

Begin with passive techniques to gather initial subdomain data without alerting the target. Query certificate transparency logs using crt.sh, search Certificate Transparency databases, and check public DNS records. This provides a baseline of known subdomains.

### Step 2: Tool-Based Passive Enumeration

Deploy subfinder with multiple sources configured. Configure API keys for maximum source coverage. Run amass in passive mode to supplement subfinder results. Use assetfinder for additional passive discovery. Combine all passive results into a single file.

### Step 3: Active DNS Enumeration

Perform DNS brute-forcing using relevant wordlists. Configure dnsx to validate and resolve discovered subdomains. Check for DNS zone transfer vulnerabilities. Test for wildcard DNS responses and filter accordingly.

### Step 4: Recursive Enumeration

Use discovered subdomains as seeds for further enumeration. Apply permutation-based techniques to generate variations. Check for CNAME records pointing to external services. Identify subdomain takeover opportunities.

### Step 5: Validation and Resolution

Resolve all discovered subdomains using dnsx or massdns. Filter out inactive subdomains based on resolution results. Identify IP address ranges and hosting providers. Map subdomains to their corresponding IP addresses.

### Step 6: Live Host Verification

Use httpx to verify which resolved subdomains have active web services. Check HTTP status codes, titles, and technologies. Identify web servers, applications, and APIs. Filter results based on response codes and content.

### Step 7: Output Consolidation

Merge all results from different tools and stages. Remove duplicates using sort and uniq. Organize results by source, status, and IP address. Generate comprehensive reports in multiple formats.

### Step 8: Scheduling and Monitoring

Set up cron jobs for regular enumeration runs. Configure monitoring for new subdomain discoveries. Set up notifications for critical findings. Integrate with vulnerability scanning pipelines.

### Step 9: Documentation and Reporting

Document all findings with timestamps and sources. Create visual maps of the discovered attack surface. Generate reports for stakeholders. Archive results for future reference and comparison.

### Step 10: Continuous Improvement

Analyze results to identify gaps in enumeration coverage. Update wordlists and tool configurations based on findings. Refine automation scripts based on lessons learned. Share findings with the security team for further investigation.

## Tool Arsenal

### subfinder — Passive Subdomain Discovery

```bash
# Basic passive enumeration
subfinder -d example.com -o subfinder_results.txt

# With all sources enabled
subfinder -d example.com -all -o subfinder_all_sources.txt

# Using specific API sources
subfinder -d example.com -sources crtsh,virustotal,securitytrails,shodan -o subfinder_api.txt

# Recursive enumeration mode
subfinder -d example.com -recursive -o subfinder_recursive.txt

# Multiple domains from file
subfinder -dL domains.txt -o subfinder_batch.txt

# Silent mode for scripting
subfinder -d example.com -silent | tee subfinder_silent.txt

# Rate limiting to avoid blocks
subfinder -d example.com -rate-limit 10 -o subfinder_ratelimited.txt

# With configuration file
subfinder -d example.com -config ~/.config/subfinder/provider-config.yaml -o subfinder_config.txt

# JSON output format
subfinder -d example.com -json -o subfinder_json.json

# Excluding specific sources
subfinder -d example.com -exclude sources threatcrowd -o subfinder_excluded.txt
```

Flags explained:
- `-d`: Target domain
- `-all`: Use all available sources
- `-sources`: Specify which sources to use
- `-recursive`: Enable recursive enumeration
- `-dL`: Load domains from file
- `-silent`: Suppress banner and progress
- `-rate-limit`: Maximum requests per second
- `-config`: Custom configuration file
- `-json`: Output in JSON format
- `-exclude`: Exclude specific sources

### amass — Comprehensive Enumerator

```bash
# Passive enumeration only
amass enum -passive -d example.com -o amass_passive.txt

# Active enumeration with brute-force
amass enum -active -brute -d example.com -o amass_active.txt

# With configuration file
amass enum -d example.com -config ~/.config/amass/config.ini -o amass_config.txt

# Including all data sources
amass enum -d example.com -src -o amass_with_sources.txt

# Recursive brute-force
amass enum -brute -recursive -d example.com -o amass_recursive.txt

# With specific wordlist
amass enum -brute -d example.com -d wordlists/subdomains.txt -o amass_wordlist.txt

# Timed enumeration
amass enum -d example.com -timeout 30 -o amass_timeout.txt

# Multiple domains
amass enum -d example.com -d example2.com -o amass_multi.txt

# JSON output
amass enum -d example.com -json amass_json.json -o amass_json.txt

# Infrastructure enumeration
amass intel -d example.com -whois -o amass_intel.txt
```

Flags explained:
- `-passive`: Only passive techniques
- `-active`: Include active techniques
- `-brute`: Enable DNS brute-forcing
- `-recursive`: Recursive enumeration
- `-src`: Show data source for each result
- `-config`: Custom configuration
- `-timeout`: Maximum time in minutes
- `-json`: Output raw JSON data
- `-d`: Target domain specification
- `-whois`: Include WHOIS information

### assetfinder — Quick Asset Discovery

```bash
# Basic subdomain finding
assetfinder --subs-only example.com > assetfinder_results.txt

# With related domains
assetfinder example.com > assetfinder_all.txt

# Grep for specific patterns
assetfinder --subs-only example.com | grep -E "^(dev|staging|test)\."

# Combine with other tools
assetfinder --subs-only example.com >> combined_results.txt

# Pipe to validation
assetfinder --subs-only example.com | httpx -silent > live_hosts.txt

# Multiple domains
for domain in $(cat domains.txt); do
    assetfinder --subs-only $domain >> all_assets.txt
done

# With CSV output
assetfinder --subs-only example.com | awk '{print $1","$2}' > assetfinder.csv

# Regex filtering
assetfinder --subs-only example.com | grep -iE "(api|admin|portal|dev)"

# Sort and deduplicate
assetfinder --subs-only example.com | sort -u > assetfinder_unique.txt
```

### crt.sh — Certificate Transparency Lookup

```bash
# Query crt.sh API
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sort -u > crtsh_results.txt

# Extract unique subdomains
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sed 's/\\n/\n/g' | sort -u > crtsh_unique.txt

# With date filtering
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[] | select(.not_before > "2024-01-01") | .name_value' | sort -u > crtsh_recent.txt

# Wildcard search
curl -s "https://crt.sh/?q=%25.example.com&output=json" | jq -r '.[].name_value' | sort -u > crtsh_wildcard.txt

# JSON processing
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq '.' > crtsh_full.json

# Extract with issuer info
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '[.name_value, .issuer_name] | @csv' > crtsh_detailed.csv

# Filter for specific patterns
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | grep -E "\.(dev|staging|test)\." | sort -u > crtsh_environments.txt

# Bulk domain lookup
for domain in $(cat domains.txt); do
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value'
done | sort -u > crtsh_bulk.txt

# With rate limiting
while IFS= read -r domain; do
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value'
    sleep 2
done < domains.txt | sort -u > crtsh_ratelimited.txt
```

### dnsx — DNS Resolution and Validation

```bash
# Resolve subdomains
cat subdomains.txt | dnsx -silent -o resolved.txt

# With IP addresses
cat subdomains.txt | dnsx -a -silent -o with_ips.txt

# Multiple record types
cat subdomains.txt | dnsx -aaaa -mx -ns -cname -txt -o full_dns.txt

# JSON output
cat subdomains.txt | dnsx -json -o dnsx_json.json

# Response code filtering
cat subdomains.txt | dnsx -rcode noerror -silent -o valid_only.txt

# With rate limiting
cat subdomains.txt | dnsx -rate-limit 100 -silent -o rate_limited.txt

# Resolver configuration
cat subdomains.txt | dnsx -r resolvers.txt -silent -o custom_resolvers.txt

# Verbose output
cat subdomains.txt | dnsx -v -o verbose_dns.txt

# Extract specific records
cat subdomains.txt | dnsx -cname -silent | grep -i "amazonaws\|cloudflare\|azure" > cloud_services.txt

# TCP fallback
cat subdomains.txt | dnsx -tcp -silent -o tcp_results.txt
```

### massdns — High-Speed DNS Resolution

```bash
# Basic resolution
massdns -r resolvers.txt -t A subdomains.txt -o S > massdns_results.txt

# With JSON output
massdns -r resolvers.txt -t A subdomains.txt -o J > massdns_json.json

# Multiple record types
massdns -r resolvers.txt -t ANY subdomains.txt -o S > massdns_any.txt

# Output only unique results
massdns -r resolvers.txt -t A subdomains.txt -o S | sort -u > massdns_unique.txt

# With retry configuration
massdns -r resolvers.txt -t A subdomains.txt --retry 3 -o S > massdns_retry.txt

# Bandwidth limiting
massdns -r resolvers.txt -t A subdomains.txt -b 10M -o S > massdns_bandwidth.txt

# Resolver file configuration
massdns -r resolvers.txt -t A subdomains.txt --sticky -o S > massdns_sticky.txt

# Verbose mode
massdns -r resolvers.txt -t A subdomains.txt -v -o S > massdns_verbose.txt

# Output to file with statistics
massdns -r resolvers.txt -t A subdomains.txt -o S -w massdns_output.txt 2> massdns_stats.txt
```

### httpx — Live Host Verification

```bash
# Basic HTTP probing
cat resolved.txt | httpx -silent -o live_hosts.txt

# With status codes and titles
cat resolved.txt | httpx -status-code -title -silent -o httpx_detailed.txt

# Multiple output formats
cat resolved.txt | httpx -json -o httpx_json.json

# Technology detection
cat resolved.txt | httpx -tech-detect -silent -o httpx_tech.txt

# Web server detection
cat resolved.txt | httpx -web-server -silent -o httpx_server.txt

# Custom ports
cat resolved.txt | httpx -ports 80,443,8080,8443 -silent -o httpx_ports.txt

# Follow redirects
cat resolved.txt | httpx -follow-redirects -silent -o httpx_redirects.txt

# Content length filtering
cat resolved.txt | httpx -content-length -silent | awk '$2 > 100' > httpx_content.txt

# Response body matching
cat resolved.txt | httpx -match-string "login" -silent -o httpx_login.txt

# Exclude patterns
cat resolved.txt | httpx -exclude-string "404" -silent -o httpx_no404.txt

# Screenshot capture
cat resolved.txt | httpx -screenshot -silent -o httpx_screenshot.txt

# Custom headers
cat resolved.txt | httpx -H "User-Agent: CustomBot/1.0" -silent -o httpx_custom.txt

# Pipeline with output
cat subdomains.txt | httpx -silent -o httpx_results.txt 2>&1 | tee httpx_log.txt
```

### dnsgen — Permutation Generation

```bash
# Generate permutations
cat subdomains.txt | dnsgen - > permutations.txt

# With numbers
cat subdomains.txt | dnsgen -c - > permutations_numbered.txt

# From file
dnsgen subdomains.txt -o permutations_output.txt

# Combined with massdns
cat permutations.txt | massdns -r resolvers.txt -t A -o S | sort -u > resolved_permutations.txt

# Filter valid permutations
cat permutations.txt | dnsx -silent -o valid_permutations.txt

# Generate and resolve in one step
cat subdomains.txt | dnsgen - | massdns -r resolvers.txt -t A -o S | sort -u > final_permutations.txt
```

### shuffledns — Mass DNS with Brute-forcing

```bash
# Basic brute-force
shuffledns -d example.com -w wordlist.txt -r resolvers.txt -o shuffledns_results.txt

# With exclusion list
shuffledns -d example.com -w wordlist.txt -r resolvers.txt -e excluded.txt -o shuffledns_filtered.txt

# Recursive mode
shuffledns -d example.com -w wordlist.txt -r resolvers.txt -recursive -o shuffledns_recursive.txt

# JSON output
shuffledns -d example.com -w wordlist.txt -r resolvers.txt -json -o shuffledns_json.json

# Rate limiting
shuffledns -d example.com -w wordlist.txt -r resolvers.txt -rate-limit 100 -o shuffledns_ratelimited.txt

# With massdns underneath
shuffledns -d example.com -w wordlist.txt -r resolvers.txt -massdns-args "-b 10M" -o shuffledns_massdns.txt
```

## Case Studies

### Case Study 1: Enterprise Financial Institution

**Target:** Major bank with strict security controls
**Objective:** Complete subdomain enumeration for penetration test

The engagement required mapping the entire attack surface of a major financial institution. The target had implemented DNS security measures including rate limiting and monitoring.

**Approach:**
1. Started with passive enumeration using crt.sh and subfinder with API keys
2. Used amass in passive mode for additional sources
3. Deployed DNS brute-forcing with financial-industry-specific wordlists
4. Applied permutation-based discovery for common banking naming conventions
5. Used recursive enumeration on discovered subdomains

**Results:**
- 2,847 unique subdomains discovered
- 1,203 active web services identified
- 12 development environments exposed
- 3 subdomains pointing to third-party services (potential takeover)
- 1 admin panel with default credentials

**Key Findings:**
- Legacy banking portal at oldportal.bank.com pointing to decommissioned server
- Staging environment with reduced security controls
- API endpoints with verbose error messages
- Internal tools exposed to the internet

**Lessons Learned:**
- Financial institutions often have legacy systems with subdomains
- Third-party integrations create subdomain takeover opportunities
- Development environments are common entry points

### Case Study 2: SaaS Platform with Microservices

**Target:** Cloud-native SaaS provider
**Objective:** Map all microservices and API endpoints

The target operated hundreds of microservices across multiple cloud providers. Traditional enumeration methods were insufficient.

**Approach:**
1. Comprehensive passive enumeration using all available sources
2. Cloud-specific enumeration targeting AWS, Azure, and GCP
3. Container orchestration platform discovery (Kubernetes, Docker)
4. API gateway and load balancer identification
5. Service mesh mapping

**Results:**
- 15,234 subdomains discovered across 3 cloud providers
- 892 unique microservices identified
- 456 API endpoints documented
- 23 container orchestration dashboards exposed
- 12 internal service discovery endpoints accessible

**Key Findings:**
- Kubernetes dashboard exposed without authentication
- Docker registry accessible with default credentials
- Service mesh configuration endpoints leak internal architecture
- Cloud storage buckets accessible through subdomain records

**Lessons Learned:**
- Cloud-native architectures have unique subdomain patterns
- Container platforms often expose management interfaces
- Service discovery endpoints can reveal entire architecture

### Case Study 3: Government Agency

**Target:** Federal government department
**Objective:** Comprehensive asset discovery for security assessment

Government agencies have strict rules about external testing. The enumeration had to be passive and stealthy.

**Approach:**
1. Passive-only enumeration using public sources
2. Certificate transparency log analysis
3. Historical DNS record research
4. Public document analysis for subdomain references
5. Search engine dorking for subdomain discovery

**Results:**
- 892 subdomains discovered passively
- 234 confirmed active through passive techniques
- 12 subdomains pointing to decommissioned services
- 8 subdomains with expired certificates
- 3 potential subdomain takeover candidates

**Key Findings:**
- Historical records reveal infrastructure changes
- Public documents contain subdomain references
- Certificate transparency logs are invaluable for passive enumeration
- Decommissioned services often have lingering DNS records

**Lessons Learned:**
- Passive enumeration can be highly effective
- Historical data provides valuable insights
- Government agencies have complex DNS structures

## Bypass Techniques

### DNS Security Bypass

When target DNS servers implement rate limiting, use multiple DNS resolvers to distribute queries. Rotate through resolver lists and implement random delays between requests. Use TCP instead of UDP to avoid UDP rate limits.

### Firewall Evasion

DNS queries over port 53 may be blocked. Try DNS over HTTPS (DoH) or DNS over TLS (DoT) to bypass port-based restrictions. Use passive DNS sources that don't require direct queries.

### CDN and WAF Bypass

CDNs may hide the actual origin server. Use DNS history to find pre-CDN IP addresses. Check for mail server records that may point to the origin. Analyze SSL certificate details for origin information.

### Rate Limiting Bypass

Implement exponential backoff when rate limits are detected. Use distributed queries from multiple source IPs. Cache results to avoid repeated queries. Use passive sources to supplement active enumeration.

### Wildcard DNS Bypass

Detect wildcard records by querying non-existent subdomains. Use validated subdomains to distinguish real from wildcard responses. Analyze response patterns to identify wildcard configurations.

### Source Blocking Bypass

When specific enumeration sources block your IP, use proxy rotation or VPN services. Implement delays between requests to sources. Use multiple API keys for different sources. Fall back to alternative sources when primary ones are blocked.

## Advanced Techniques

### AI-Assisted Subdomain Prediction

Use machine learning models to predict likely subdomain naming patterns. Train models on discovered subdomains to generate intelligent permutations. Implement natural language processing to understand naming conventions.

### Certificate Transparency Mining

Parse all CT logs for the target domain. Track certificate issuance over time to identify new subdomains. Correlate certificate data with DNS records for comprehensive mapping. Monitor for certificate transparency alerts.

### DNS Cache Snooping

Query DNS resolvers for cached records to discover internal subdomains. Implement cache snooping techniques to extract previously resolved names. Use multiple resolvers to maximize cache coverage.

### Reverse DNS Archaeology

Historical reverse DNS records can reveal decommissioned subdomains. Use archive.org and other historical databases to find old records. Correlate IP address history with domain changes.

### DNS Graph Analysis

Build graphs of DNS relationships between subdomains. Analyze CNAME chains for dependencies and takeover opportunities. Map the complete DNS infrastructure including mail servers, name servers, and service records.

### Automated Subdomain Takeover Detection

Identify subdomains pointing to external services with unclaimed accounts. Check for dangling CNAME records pointing to decommissioned services. Test for subdomain takeover vulnerabilities using automated tools.

## Detection Indicators

### Network-Level Indicators

DNS query patterns reveal enumeration activity. High volume of DNS requests from a single IP indicates scanning. Unusual query patterns for non-existent subdomains suggest brute-forcing. Multiple queries for the same domain in quick succession indicate automated tools.

### Log Analysis Indicators

DNS server logs show enumeration attempts. Firewall logs capture blocked queries. Web server logs record HTTP requests to discovered subdomains. Proxy logs reveal enumeration traffic patterns.

### Behavioral Indicators

Sequential subdomain querying patterns indicate automated tools. Randomized subdomain queries suggest permutation-based techniques. Consistent timing between queries indicates scripted enumeration. Large bursts of DNS queries indicate brute-force attacks.

### Source Indicators

Known user agents from enumeration tools appear in logs. API key usage patterns can identify specific tools. Request patterns match tool-specific behaviors. Timing signatures reveal tool configurations.

## Impact Assessment

### Direct Impact

Subdomain enumeration reveals the complete attack surface. Each discovered subdomain represents a potential entry point. Exposed development and staging environments reduce security controls. Third-party integrations create supply chain risks.

### Indirect Impact

Enumeration enables targeted attacks against specific services. Discovery of internal naming conventions aids further reconnaissance. Identification of cloud infrastructure enables cloud-specific attacks. Knowledge of technology stacks guides vulnerability selection.

### Risk Quantification

More subdomains increase the attack surface exponentially. Exposed administrative interfaces pose high risk. Development environments with weak security are medium risk. Third-party dependencies create medium to high risk based on sensitivity.

### Business Impact

Complete attack surface mapping enables comprehensive security assessment. Identification of shadow IT and unauthorized services. Discovery of legacy systems requiring decommissioning. Documentation of all internet-facing assets for compliance.

## Common Pitfalls

### Tool Configuration Errors

Incorrect API keys prevent source access. Wrong wordlists miss target-specific subdomains. Insufficient rate limits cause blocking. Missing resolver configurations slow enumeration.

### Result Processing Mistakes

Failure to deduplicate results inflates numbers. Not filtering wildcard responses creates false positives. Ignoring DNS resolution status wastes time on inactive subdomains. Missing JSON output loses valuable metadata.

### Scope Management Issues

Enumerating out-of-scope domains creates legal risks. Not verifying domain ownership leads to false assumptions. Ignoring subdomain patterns misses related assets. Failing to document sources complicates reporting.

### Resource Management Problems

Running too many tools simultaneously causes resource exhaustion. Not implementing proper error handling stops automation. Missing cleanup of temporary files wastes disk space. Inadequate logging prevents debugging.

### Security Awareness Gaps

Active enumeration without authorization violates policies. Not using stealth techniques triggers security alerts. Ignoring rate limits causes IP blocking. Failing to use proxies exposes source identity.

## Integration Points

### CI/CD Pipeline Integration

Automate subdomain enumeration in continuous integration pipelines. Trigger scans on new deployments. Integrate results with security gates. Report findings to development teams.

### Vulnerability Scanner Integration

Feed discovered subdomains into vulnerability scanners. Prioritize scanning based on subdomain criticality. Correlate subdomain data with vulnerability findings. Update scanner targets automatically.

### Monitoring System Integration

Integrate with DNS monitoring systems. Set up alerts for new subdomain discoveries. Monitor for unauthorized subdomain creation. Track changes in DNS records.

### Ticketing System Integration

Automatically create tickets for new findings. Track remediation progress. Generate reports for security teams. Escalate critical findings.

### Notification System Integration

Send real-time alerts for critical discoveries. Configure email, Slack, or webhook notifications. Implement severity-based notification routing. Schedule regular summary reports.

## Reporting Templates

### Executive Summary

```
Subdomain Enumeration Report
Date: [DATE]
Target: [DOMAIN]
Tools Used: [LIST]
Total Subdomains: [NUMBER]
Active Subdomains: [NUMBER]
Key Findings: [SUMMARY]
Risk Level: [LEVEL]
Recommendations: [LIST]
```

### Technical Details

```
Enumeration Methodology:
1. Passive Sources: [SOURCES]
2. Active Enumeration: [TOOLS]
3. DNS Resolution: [METHOD]
4. Validation: [APPROACH]

Results Breakdown:
- Total Discovered: [NUMBER]
- Active (Resolved): [NUMBER]
- With Web Services: [NUMBER]
- With Email Services: [NUMBER]
- Third-Party Dependencies: [NUMBER]

Top Findings:
1. [FINDING 1]
2. [FINDING 2]
3. [FINDING 3]
```

### Raw Data Format

```
Subdomain,Status,IP,Source,First Seen,Last Seen
sub1.example.com,Active,192.168.1.1,crt.sh,2024-01-15,2024-01-20
sub2.example.com,Active,192.168.1.2,subfinder,2024-01-16,2024-01-20
sub3.example.com,Inactive,N/A,amass,2024-01-10,2024-01-15
```

## Practice Labs

### Lab 1: Basic Enumeration

**Setup:** Create a test domain with multiple subdomains
**Exercise:** Use subfinder and amass to discover all subdomains
**Goal:** Achieve 90% coverage of all subdomains

### Lab 2: Active Enumeration

**Setup:** Configure DNS servers with wildcard responses
**Exercise:** Implement wildcard detection and filtering
**Goal:** Successfully filter wildcard responses

### Lab 3: Automation Pipeline

**Setup:** Multiple tools with API configurations
**Exercise:** Create automated enumeration pipeline
**Goal:** Build complete automation with scheduling

### Lab 4: Result Consolidation

**Setup:** Results from multiple tools in different formats
**Exercise:** Merge, deduplicate, and analyze results
**Goal:** Create comprehensive report from combined data

## Ethics

Subdomain enumeration must be performed within legal and ethical boundaries. Always obtain written authorization before enumerating any domain. Respect rate limits and do not cause denial of service. Do not access or attempt to access any system without explicit permission. Use passive techniques when active enumeration may be disruptive. Store discovered data securely and do not expose sensitive information. Follow responsible disclosure practices for vulnerabilities discovered. Comply with all applicable laws and regulations. Respect privacy and do not enumerate personal domains without consent. Document all activities for audit purposes and accountability.

## Quick Reference

### Essential Commands

```bash
# Quick subdomain discovery
subfinder -d example.com -silent | sort -u > subdomains.txt

# With DNS resolution
subfinder -d example.com -silent | dnsx -silent -o resolved.txt

# Live host verification
subfinder -d example.com -silent | httpx -silent -o live.txt

# Complete pipeline
subfinder -d example.com -silent | sort -u | dnsx -silent | httpx -silent -json > full_results.json

# Certificate transparency
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sort -u

# Recursive enumeration
amass enum -brute -recursive -d example.com -o amass_results.txt

# Permutation generation
cat subdomains.txt | dnsgen - | massdns -r resolvers.txt -t A -o S | sort -u

# Mass DNS resolution
massdns -r resolvers.txt -t A subdomains.txt -o S | sort -u > resolved.txt

# HTTP probing
cat resolved.txt | httpx -status-code -title -silent -o httpx_results.txt

# JSON output for processing
cat subdomains.txt | httpx -json | jq -r 'select(.status_code == 200) | .url' > live_200.txt
```

### Tool Comparison

| Tool | Type | Speed | Accuracy | Sources |
|------|------|-------|----------|---------|
| subfinder | Passive | Fast | High | 40+ |
| amass | Both | Medium | Very High | 50+ |
| assetfinder | Passive | Fast | Medium | Limited |
| crt.sh | Passive | Slow | High | CT Logs |
| dnsx | Resolution | Fast | High | DNS |
| massdns | Resolution | Very Fast | High | DNS |
| httpx | Verification | Fast | High | HTTP |

### Wordlist Locations

```
/subdomains.txt - General subdomains
/dev.txt - Development subdomains
/staging.txt - Staging environments
/admin.txt - Administrative interfaces
/api.txt - API endpoints
/cloud.txt - Cloud services
/internal.txt - Internal tools
/legacy.txt - Legacy systems
```

### API Key Configuration

```yaml
# ~/.config/subfinder/provider-config.yaml
censys:
  ID: your_censys_id
  Secret: your_censys_secret
shodan:
  APIKey: your_shodan_key
virustotal:
  APIKey: your_virustotal_key
securitytrails:
  APIKey: your_securitytrails_key
chaos:
  APIKey: your_chaos_key
github:
  Tokens:
    - your_github_token_1
    - your_github_token_2
```

### Resolver Configuration

```
# resolvers.txt - Public DNS resolvers
8.8.8.8
8.8.4.4
1.1.1.1
1.0.0.1
9.9.9.9
149.112.112.112
208.67.222.222
208.67.220.220
```

### Rate Limiting Guidelines

- crt.sh: 1 request per 2 seconds
- SecurityTrails: 50 requests per minute
- VirusTotal: 4 requests per minute
- Shodan: 1 request per second
- Censys: Limited by plan
- DNS Queries: 100 per resolver per second
- HTTP Requests: 10 per target per second

### Output Formats

```bash
# Text format (default)
subfinder -d example.com -o results.txt

# JSON format
subfinder -d example.com -json results.json

# CSV format
subfinder -d example.com | awk -F',' '{print $1","$2}' > results.csv

# Grepable format
subfinder -d example.com | while read line; do echo "[*] $line"; done > results.grep

# XML format (nmap-style)
subfinder -d example.com | awk '{print "<host><name>"$1"</name></host>"}' > results.xml
```

### Scheduling Examples

```bash
# Daily enumeration at 2 AM
0 2 * * * /path/to/enumerate.sh example.com >> /var/log/enumeration.log 2>&1

# Weekly full scan
0 0 * * 0 /path/to/full_scan.sh domains.txt >> /var/log/full_scan.log 2>&1

# Hourly monitoring for new subdomains
0 * * * * /path/to/monitor.sh example.com >> /var/log/monitor.log 2>&1

# Custom cron with logging
*/30 * * * * /path/to/quick_check.sh example.com 2>&1 | tee -a /var/log/quick_check.log
```

### Debugging Commands

```bash
# Verbose output
subfinder -d example.com -v

# Test specific source
subfinder -d example.com -sources crtsh -v

# Debug DNS resolution
dig subdomain.example.com +trace

# Test API connectivity
curl -v "https://api.securitytrails.com/v1/domain/example.com/subdomains"

# Check tool versions
subfinder -version
amass -version
dnsx -version

# Test resolver connectivity
massdns -r resolvers.txt -t A test.example.com -o S -w /dev/null
```
