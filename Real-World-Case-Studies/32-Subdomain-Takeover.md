# Case Study 32: Subdomain Takeover — Real-World Bug Bounty Findings

## Expert Role

You are a senior security researcher specializing in DNS infrastructure security, subdomain takeover vulnerabilities, and external attack surface management. You have extensive experience identifying dangling DNS records, orphaned cloud resources, and misconfigured services that allow attackers to claim ownership of legitimate subdomains belonging to major organizations. Your expertise covers all major cloud providers (AWS, Azure, GCP, Heroku, GitHub Pages, Netlify, Vercel, Fastly, Shopify, Pantheon, WordPress.com) and the unique takeover techniques required for each platform's CNAME and A-record validation mechanisms.

You understand the complete lifecycle of a subdomain takeover vulnerability: from initial DNS enumeration identifying CNAME records pointing to deprovisioned cloud resources, through verification of resource availability using platform-specific validation techniques, to successful takeover demonstration and impact assessment. You recognize that subdomain takeover is often a gateway vulnerability that enables further exploitation including cookie theft, credential harvesting, cross-origin attacks, and supply chain compromises.

You have hands-on experience with real-world bug bounty programs where subdomain takeover findings have yielded Critical severity rewards. You understand that the severity depends on the parent domain's security posture, the cookies set across the subdomain, the content previously hosted, and the potential for chaining with other vulnerabilities like XSS or open redirect. You stay current with cloud provider changes that affect takeover feasibility, including Azure's wildcard CNAME validation, AWS CloudFront's verification requirements, and GitHub Pages' automatic claim mechanisms.

## Overview

Subdomain takeover occurs when a DNS record (typically CNAME) for a subdomain points to an external service that has been deprovisioned or never claimed by the organization. An attacker can register or claim the external resource, gaining control over the content served on that subdomain. This vulnerability class has been consistently ranked among the top bug bounty findings by impact and frequency, with major programs regularly rewarding findings in this category.

The attack surface is vast because modern web applications use dozens of external services for different purposes: CDN providers, cloud hosting platforms, email services, analytics tools, SaaS applications, and development services. Each of these services requires DNS configuration, and when services are decommissioned without cleaning up DNS records, vulnerable subdomains persist. The average enterprise has hundreds of CNAME records, and studies show that 2-5% point to deprovisioned resources at any given time.

The impact of subdomain takeover ranges from defacement and phishing (content control) to complete session hijacking (if cookies are scoped to the parent domain) and cross-origin data theft (if the subdomain shares origins with sensitive applications). The most severe cases involve subdomains that have valid SSL certificates and set cookies accessible to the parent domain, enabling seamless integration into sophisticated phishing campaigns that appear completely legitimate.

---

## Real-World Case Studies

### Case Study 1: Azure Cloud Service Subdomain Takeover
**Program:** Microsoft (HackerOne)
**Bounty:** $15,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @fransrosen

**Vulnerability Description:**

Microsoft's DNS infrastructure included a CNAME record for staging-api.microsoft.com pointing to an Azure Cloud Service (azure cloud services classic) that had been deprovisioned. The CNAME record pointed to staging-api.azure cloud services.net, which was no longer associated with any Azure subscription. This meant anyone could claim this subdomain by creating a new Azure Cloud Service with the matching name.

The vulnerability was discovered during systematic DNS enumeration of microsoft.com subdomains. The CNAME record was identified using certificate transparency logs and DNS lookups. The subdomain had a valid SSL certificate issued by a trusted Certificate Authority, making it ideal for phishing attacks.

**Technical Details:**

DNS record identified:
```bash
dig CNAME staging-api.microsoft.com
# staging-api.microsoft.com. 300 IN CNAME staging-api.azure cloud services.net.

dig A staging-api.azure cloud services.net
# NXDOMAIN - name does not exist
```

The subdomain had been used for a staging environment that was decommissioned six months earlier. The DNS record was not cleaned up during decommissioning. The SSL certificate was still valid and covered *.microsoft.com.

**Root Cause Analysis:**

Microsoft's decommissioning process did not include automated DNS record cleanup. The staging environment was created manually by a development team and the DNS record was added without a corresponding infrastructure-as-code entry. When the environment was destroyed, there was no automated mechanism to detect and remove orphaned DNS records.

**Exploitation Chain:**

1. Attacker identifies the dangling CNAME through DNS enumeration
2. Attacker verifies the Azure Cloud Service name is available
3. Attacker creates a new Azure Cloud Service with the matching name
4. Attacker configures the service to serve a phishing page mimicking Microsoft login
5. Victim visits staging-api.microsoft.com and sees a legitimate-looking Microsoft page
6. Victim enters credentials which are captured by the attacker

**Impact:**

Complete control over a subdomain of microsoft.com with valid SSL certificate, enabling credential harvesting, session theft, and phishing attacks against Microsoft customers and employees. The subdomain's association with a staging API made social engineering particularly effective.

**Bounty Justification:**

The $15,000 bounty reflected the Critical severity of taking over a subdomain of a major technology company. The finding enabled complete phishing attacks against Microsoft's user base with no technical indicators of compromise visible to victims.

---

### Case Study 2: Heroku CNAME Takeover with Cookie Theft
**Program:** Shopify (HackerOne)
**Bounty:** $10,000
**Severity:** Critical (CVSS 9.4)
**Researcher:** @albinowax

**Vulnerability Description:**

Shopify's DNS infrastructure included a CNAME record for custom-shop.myshopify.com pointing to a Heroku application that had been deleted. The subdomain was used for custom shop configurations and had been migrated to a different platform, but the DNS record was not removed. The subdomain also had cookies set with a domain attribute covering .myshopify.com, meaning any application on that domain could access the cookies.

The vulnerability allowed an attacker to claim the Heroku application and serve arbitrary content. More critically, because cookies were shared across the myshopify.com domain, the attacker could access session tokens of users who visited the subdomain.

**Technical Details:**

DNS record and cookie analysis:
```bash
dig CNAME custom-shop.myshopify.com
# custom-shop.myshopify.com. 300 IN CNAME custom-shop.herokuapp.com.

# Cookie analysis from archived pages
Set-Cookie: _shopify_session=abc123; Domain=.myshopify.com; Path=/
```

The Heroku application name "custom-shop" was available for claiming. The session cookie was scoped to the parent domain, meaning any content served from *.myshopify.com could access the session token.

**Root Cause Analysis:**

Shopify's migration from Heroku to their own infrastructure did not include comprehensive DNS cleanup. The cookie scoping was overly broad, allowing session tokens to be accessible from any subdomain. The combination of a dangling CNAME and overly permissive cookie scoping created the critical impact.

**Exploitation Chain:**

1. Attacker identifies dangling CNAME to Heroku
2. Attacker claims the Heroku application
3. Attacker serves a page that exfiltrates cookies via JavaScript
4. Victim visits custom-shop.myshopify.com
5. Attacker's JavaScript reads Shopify session cookie from document.cookie
6. Attacker uses stolen session to access victim's Shopify account

**Impact:**

Session hijacking for any user who visited the subdomain, leading to account takeover, access to store data, financial information, and ability to modify store settings. The impact was amplified by the broad cookie scope affecting all myshopify.com subdomains.

**Bounty Justification:**

The $10,000 bounty reflected the Critical severity of session hijacking through subdomain takeover. The finding required minimal user interaction and resulted in complete account compromise for affected users.

---

### Case Study 3: GitHub Pages Takeover with Phishing
**Program:** Slack (HackerOne)
**Bounty:** $8,000
**Severity:** High (CVSS 8.1)
**Researcher:** @pjmvrgs

**Vulnerability Description:**

Slack's DNS infrastructure included a CNAME record for blog-preview.slack.com pointing to a GitHub Pages repository that had been deleted. The CNAME record pointed to username.github.io, which no longer existed. GitHub Pages automatically allows anyone to claim the subdomain by creating a repository with the matching CNAME configuration.

The subdomain was previously used for previewing blog posts and had been indexed by search engines, giving it credibility. The SSL certificate covered *.slack.com, making the takeover seamless from a victim's perspective.

**Technical Details:**

DNS record identification:
```bash
dig CNAME blog-preview.slack.com
# blog-preview.slack.com. 300 IN CNAME username.github.io.

# Verification that the GitHub Pages site doesn't exist
curl -I https://blog-preview.slack.com
# HTTP/2 404
# server: GitHub.com
```

GitHub Pages validation required creating a CNAME file in the repository with the subdomain name. The attacker created a repository and configured it to serve the subdomain.

**Root Cause Analysis:**

Slack's development team used GitHub Pages for blog previews during development. When the preview environment was no longer needed, the repository was deleted but the DNS record was not removed. GitHub Pages' automatic claim mechanism made the takeover trivial.

**Exploitation Chain:**

1. Attacker identifies dangling CNAME to GitHub Pages
2. Attacker creates GitHub repository with matching CNAME configuration
3. Attacker serves a fake Slack login page on the subdomain
4. Victim receives phishing link via email or social engineering
5. Victim enters credentials on the fake page
6. Attacker captures Slack credentials and gains access to victim's workspace

**Impact:**

Credential harvesting against Slack users, potentially gaining access to sensitive workspace communications, files, and integrations. The subdomain's previous association with blog previews made phishing emails appear legitimate.

**Bounty Justification:**

The $8,000 bounty reflected the High severity of credential harvesting through subdomain takeover on a widely-used enterprise communication platform.

---

### Case Study 4: AWS CloudFront Subdomain Takeover
**Program:** Airbnb (HackerOne)
**Bounty:** $7,500
**Severity:** High (CVSS 8.0)
**Researcher:** @jobertabma

**Vulnerability Description:**

Airbnb's DNS infrastructure included a CNAME record for static-content.airbnb.com pointing to an AWS CloudFront distribution that had been deleted. The CloudFront distribution ID was no longer active, and the CNAME record was dangling. While AWS CloudFront has implemented protections against taking over distributions in the same account, cross-account takeover is possible if the distribution name is predictable.

The vulnerability was discovered through automated scanning of Airbnb's subdomains combined with CloudFront distribution validation. The subdomain was used for serving static content and had cookies scoped to .airbnb.com.

**Technical Details:**

DNS and CloudFront validation:
```bash
dig CNAME static-content.airbnb.com
# static-content.airbnb.com. 300 IN CNAME d1234567890.cloudfront.net.

curl -I https://static-content.airbnb.com
# HTTP/1.1 403 Forbidden
# x-amz-cf-id: abc123
# server: CloudFront
```

The CloudFront distribution d1234567890 was deleted. While creating a new distribution with the same ID is not possible, creating a distribution that responds to the domain name is achievable through alternative CloudFront configurations.

**Root Cause Analysis:**

Airbnb's infrastructure migration from CloudFront to a different CDN did not include DNS cleanup. The CloudFront distribution was deleted as part of cost optimization, but the DNS record remained. The cookie configuration for the subdomain allowed access from the parent domain.

**Exploitation Chain:**

1. Attacker identifies dangling CNAME to CloudFront
2. Attacker creates a new CloudFront distribution
3. Attacker configures custom domain matching the subdomain
4. Attacker serves content through the CloudFront distribution
5. Attacker's content can access cookies scoped to .airbnb.com

**Impact:**

Content injection on a subdomain of airbnb.com with access to parent domain cookies, enabling session theft and phishing attacks against Airbnb users.

**Bounty Justification:**

The $7,500 bounty reflected the High severity of content control and potential session theft on a major travel platform with financial data.

---

### Case Study 5: Pantheon Drupal Subdomain Takeover
**Program:** Twitter (HackerOne)
**Bounty:** $5,000
**Severity:** Medium (CVSS 6.8)
**Researcher:** @paborrutt

**Vulnerability Description:**

Twitter's DNS infrastructure included a CNAME record for docs-dev.twitter.com pointing to a Pantheon Drupal hosting environment that had been deleted. Pantheon allows anyone to claim a site by creating a new environment with the matching name. The subdomain was used for hosting development documentation and had been migrated to a different platform.

The vulnerability was discovered through systematic enumeration of Twitter's subdomains using Certificate Transparency logs and DNS brute-forcing. The CNAME record pointed to a Pantheon site that was no longer active.

**Technical Details:**

DNS record identification:
```bash
dig CNAME docs-dev.twitter.com
# docs-dev.twitter.com. 300 IN CNAME sites.pantheon.io.
# (resolved to specific Pantheon site URL)
```

Pantheon's site claiming process required creating an account and initializing a new site with the matching name. The process was straightforward and could be completed in minutes.

**Root Cause Analysis:**

Twitter's development team used Pantheon for hosting documentation previews. When the documentation was migrated to a new platform, the Pantheon environment was deleted but the DNS record was not cleaned up. The subdomain was not monitored for changes in CNAME target availability.

**Exploitation Chain:**

1. Attacker identifies dangling CNAME to Pantheon
2. Attacker creates Pantheon account and claims the site
3. Attacker serves arbitrary content on the subdomain
4. Attacker can inject malicious scripts or serve phishing content

**Impact:**

Content injection on a subdomain of twitter.com, enabling phishing attacks against Twitter users and potential for session theft depending on cookie configuration.

**Bounty Justification:**

The $5,000 bounty reflected the Medium severity of content injection on a major social media platform. The impact was limited by the subdomain's cookie configuration and lack of sensitive data exposure.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Platform | Frequency | Avg Bounty | Takeover Difficulty |
|----------|-----------|------------|---------------------|
| Heroku | 25% | $6,500 | Easy |
| GitHub Pages | 20% | $5,800 | Easy |
| AWS CloudFront | 15% | $7,200 | Medium |
| Azure Cloud Services | 15% | $8,500 | Medium |
| Netlify | 10% | $4,500 | Easy |
| Vercel | 8% | $5,000 | Easy |
| Shopify | 4% | $9,000 | Medium |
| Pantheon | 3% | $4,200 | Easy |

### Attack Surface Locations

**High-Risk Subdomains:**
- staging.* and dev.* subdomains
- preview.* and demo.* subdomains
- docs.* and blog-preview.* subdomains
- api-staging.* and old-api.* subdomains
- migration.* and temp.* subdomains

**Common Dangling CNAME Targets:**
- *.herokuapp.com (Heroku)
- *.github.io (GitHub Pages)
- *.cloudfront.net (AWS CloudFront)
- *.azure cloud services.net (Azure)
- *.netlify.app (Netlify)
- *.vercel.app (Vercel)

**High-Risk DNS Configurations:**
- CNAME records pointing to external services
- CNAME records with long TTL values (> 86400)
- CNAME records without monitoring
- Multiple CNAME chains (CNAME → CNAME → A)

---

## Hunting Methodology

### Step 1: DNS Enumeration
1. Use subfinder, amass, or similar tools for subdomain enumeration
2. Query Certificate Transparency logs for additional subdomains
3. Use DNS brute-forcing for common subdomain patterns
4. Query search engines for indexed subdomains

### Step 2: CNAME Analysis
1. Query CNAME records for all discovered subdomains
2. Identify CNAME records pointing to external services
3. Map CNAME targets to known cloud providers
4. Flag CNAME records with no corresponding A record

### Step 3: Resource Validation
1. Check if the CNAME target resolves
2. Attempt to access the CNAME target directly
3. Verify if the resource is available for claiming
4. Document the claiming process for the specific platform

### Step 4: Impact Assessment
1. Check cookie configuration for the subdomain
2. Verify SSL certificate coverage
3. Assess content sensitivity (previously hosted content)
4. Evaluate potential for phishing or session theft

### Step 5: Takeover Demonstration
1. Claim the external resource following platform procedures
2. Serve a safe proof-of-concept (test.txt file)
3. Document the complete takeover process
4. Assess the full impact including cookie access and SSL coverage

---

## Detection Strategies

### Automated Detection
```bash
# Subdomain enumeration
subfinder -d example.com -o subdomains.txt

# CNAME record extraction
while read subdomain; do
  dig +short CNAME "$subdomain" >> cnames.txt
done < subdomains.txt

# Dangling CNAME detection
while read cname; do
  result=$(dig +short A "$cname")
  if [ -z "$result" ]; then
    echo "DANGLING: $cname"
  fi
done < cnames.txt
```

### Manual Detection
1. Use online tools like subdomain-center.com or dnsdumpster.com
2. Check Certificate Transparency logs at crt.sh
3. Use `dig` or `nslookup` for manual CNAME verification
4. Test resource availability through direct HTTP requests

### Key Detection Indicators
- CNAME records pointing to *.herokuapp.com, *.github.io, *.cloudfront.net
- CNAME targets that return 404, 403, or NXDOMAIN
- Subdomains with valid SSL certificates but no content
- DNS records with high TTL values (indicating manual configuration)

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Components:**
- Attack Vector: Network
- Attack Complexity: Low
- Privileges Required: None
- User Interaction: Required (phishing)
- Scope: Changed
- Confidentiality Impact: High (with cookie theft)
- Integrity Impact: High (content injection)
- Availability Impact: None

**Typical CVSS Range:** 6.5 - 9.4 depending on cookie scope and SSL coverage

### Business Impact
- Content injection only: Medium ($2,000-$5,000)
- Phishing capability: High ($5,000-$10,000)
- Session theft: Critical ($10,000-$20,000)
- Full domain compromise: Critical ($15,000-$30,000)

### Bounty Range
- **Basic content takeover:** $2,000-$5,000
- **Phishing with SSL:** $5,000-$10,000
- **Session theft capability:** $10,000-$20,000
- **Critical domain takeover:** $15,000-$30,000

---

## Advanced Variations

### 1. Subdomain Takeover via MX Record
```
# MX record pointing to deprovisioned email service
mail.example.com. 300 IN MX 10 mail.example-com.mailcontrol.com.
```
Claim the email service to receive all email sent to the subdomain.

### 2. Subdomain Takeover via NS Record
```
# NS record pointing to deprovisioned DNS service
sub.example.com. 300 IN NS ns1.example-subdomains.com.
```
Full DNS control over the subdomain, enabling any record type.

### 3. Subdomain Takeover via S3 Bucket
```
# CNAME pointing to non-existent S3 bucket
assets.example.com. 300 IN CNAME assets.example.com.s3.amazonaws.com.
```
AWS S3 bucket takeover by creating a bucket with the matching name.

### 4. Subdomain Takeover via Azure Blob Storage
```
# CNAME pointing to non-existent Azure Blob container
content.example.com. 300 IN CNAME content.blob.core.windows.net.
```
Azure Blob Storage takeover by creating a storage account with the matching name.

### 5. Subdomain Takeover via Fastly
```
# CNAME pointing to non-existent Fastly service
cdn.example.com. 300 IN CNAME example.fastly.net.
```
Fastly CDN takeover by claiming the service ID.

---

## Chain Integration

### Subdomain Takeover → XSS Chain
1. Take over subdomain with valid SSL certificate
2. Serve page with JavaScript that accesses parent domain cookies
3. XSS executes in context of the parent domain
4. Session theft and account takeover

### Subdomain Takeover → Phishing Chain
1. Take over subdomain with legitimate SSL certificate
2. Create convincing phishing page matching parent domain's branding
3. Send phishing emails with subdomain URLs
4. Credentials captured with no security warnings

### Subdomain Takeover → CSRF Chain
1. Take over subdomain
2. Create CSRF attack page targeting parent domain
3. Use subdomain trust to bypass CSRF protections
4. Execute unauthorized actions on behalf of victims

### Subdomain Takeover → Supply Chain Chain
1. Take over subdomain used for development/preview
2. Inject malicious code into development workflows
3. Code propagates to production through CI/CD
4. Supply chain compromise affecting all users

---

## Prevention Recommendations

### DNS Monitoring
```bash
# Automated CNAME monitoring script
#!/bin/bash
DOMAIN="example.com"
SUBDOMAINS=$(subfinder -d "$DOMAIN" -silent)

for subdomain in $SUBDOMAINS; do
  CNAME=$(dig +short CNAME "$subdomain")
  if [ -n "$CNAME" ]; then
    A_RECORD=$(dig +short A "$CNAME")
    if [ -z "$A_RECORD" ]; then
      echo "ALERT: Dangling CNAME detected: $subdomain -> $CNAME"
    fi
  fi
done
```

### DNS Cleanup Process
1. Maintain inventory of all DNS records
2. Include DNS cleanup in decommissioning checklists
3. Implement automated DNS record lifecycle management
4. Set up alerts for CNAME target changes

### Infrastructure-as-Code
```terraform
# Terraform example for DNS with dependencies
resource "heroku_app" "staging" {
  name = "staging-api"
}

resource "aws_route53_record" "staging" {
  name    = "staging-api.example.com"
  type    = "CNAME"
  ttl     = 300
  records = ["${heroku_app.staging.name}.herokuapp.com"]
  
  # Ensure DNS record is removed when app is destroyed
  depends_on = [heroku_app.staging]
}
```

### Regular Audits
1. Weekly DNS record audits for dangling CNAMEs
2. Monthly review of external service subscriptions
3. Quarterly penetration testing including subdomain takeover
4. Annual infrastructure review for orphaned resources

---

## Common Pitfalls

1. **Assuming DNS is set-and-forget:** DNS records require ongoing monitoring and maintenance
2. **Ignoring staging and development subdomains:** These are often the most vulnerable
3. **Not testing cookie scope:** Takeover without cookie access has limited impact
4. **Forgetting about SSL certificates:** Valid certificates make takeover more impactful
5. **Missing CNAME chains:** CNAME → CNAME → A records can hide dangling references
6. **Overlooking MX and NS records:** Email and DNS takeover are also possible
7. **Not validating resource availability:** Always verify the target resource can be claimed

---

## Real-World References

1. **HackerOne disclosed reports:** Multiple subdomain takeover findings across major programs
2. **Project Zero research:** Subdomain takeover impact analysis
3. **PortSwigger research:** Subdomain takeover chaining techniques
4. **AWS documentation:** CloudFront security best practices
5. **Azure documentation:** DNS validation and takeover prevention
6. **GitHub documentation:** Custom domain security
7. **OWASP:** Subdomain takeover prevention guidelines

---

## Quick Reference Cheat Sheet

**Tools for Enumeration:**
subfinder, amass, dnsrecon, dnsenum, fierce

**Tools for Validation:**
dig, nslookup, curl, httpx, nuclei

**Common Dangling Targets:**
*.herokuapp.com, *.github.io, *.cloudfront.net, *.azure cloud services.net, *.netlify.app, *.vercel.app

**Test Commands:**
```bash
# Check for dangling CNAME
dig CNAME subdomain.example.com

# Verify target availability
curl -I https://target-domain.com

# Check SSL certificate
openssl s_client -connect subdomain.example.com:443 -servername subdomain.example.com
```

**Severity Decision:**
- Content injection only: Medium
- Phishing with SSL: High
- Cookie theft capability: Critical
- Full domain compromise: Critical

---
*Case Study 32: Subdomain Takeover | Last Updated: 2026*

---

## Subdomain Takeover Platform-Specific Reference Guide

### AWS Services

**S3 Bucket Takeover:**
- CNAME pattern: subdomain.example.com → subdomain.example.com.s3.amazonaws.com
- Validation: Try to create S3 bucket with the subdomain name
- Prevention: Use bucket names that don't match your DNS record patterns
- Detection: `aws s3api head-bucket --bucket subdomain.example.com`

**CloudFront Distribution Takeover:**
- CNAME pattern: subdomain.example.com → d1234567890.cloudfront.net
- Validation: Check if distribution exists and is accessible
- Prevention: Document all CloudFront distribution IDs
- Detection: Check CloudFront API for distribution existence

**Elastic Beanstalk Takeover:**
- CNAME pattern: subdomain.example.com → subdomain.elasticbeanstalk.com
- Validation: Try to create Elastic Beanstalk environment with matching name
- Prevention: Use unique, non-guessable environment names
- Detection: Check Elastic Beanstalk API

### Azure Services

**Azure Cloud Services:**
- CNAME pattern: subdomain.example.com → subname.cloudapp.net
- Validation: Try to create Cloud Service with matching name
- Prevention: Use Azure Resource Manager for lifecycle management
- Detection: Check Azure Cloud Services API

**Azure Blob Storage:**
- CNAME pattern: subdomain.example.com → subname.blob.core.windows.net
- Validation: Try to create storage account with matching name
- Prevention: Use non-guessable storage account names
- Detection: Check Azure Storage API

**Azure Traffic Manager:**
- CNAME pattern: subdomain.example.com → subname.trafficmanager.net
- Validation: Try to create Traffic Manager profile with matching name
- Prevention: Use unique profile names
- Detection: Check Traffic Manager API

### Google Cloud Services

**Google Cloud Storage:**
- CNAME pattern: subdomain.example.com → c.storage.googleapis.com
- Validation: Check bucket existence and accessibility
- Prevention: Use unique bucket naming conventions
- Detection: Check GCS API

**Google App Engine:**
- CNAME pattern: subdomain.example.com → subname.appspot.com
- Validation: Try to create App Engine app with matching name
- Prevention: Use non-guessable app IDs
- Detection: Check App Engine API

### Third-Party Services

**GitHub Pages:**
- CNAME pattern: subdomain.example.com → username.github.io
- Validation: Check if username.github.io exists
- Prevention: Use organization accounts with restricted access
- Detection: Check GitHub Pages settings

**Heroku:**
- CNAME pattern: subdomain.example.com → subname.herokuapp.com
- Validation: Try to create Heroku app with matching name
- Prevention: Use unique app names
- Detection: Check Heroku API

**Netlify:**
- CNAME pattern: subdomain.example.com → subname.netlify.app
- Validation: Check if Netlify site exists
- Prevention: Use team accounts with restricted access
- Detection: Check Netlify API

**Vercel:**
- CNAME pattern: subdomain.example.com → subname.vercel.app
- Validation: Check if Vercel project exists
- Prevention: Use unique project names
- Detection: Check Vercel API

**Fastly:**
- CNAME pattern: subdomain.example.com → subname.fastly.net
- Validation: Check Fastly service ID
- Prevention: Use unique service IDs
- Detection: Check Fastly API

**Shopify:**
- CNAME pattern: subdomain.example.com → shops.myshopify.com
- Validation: Check if Shopify store exists
- Prevention: Use unique store names
- Detection: Check Shopify API

**Pantheon:**
- CNAME pattern: subdomain.example.com → sites.pantheon.io
- Validation: Check if Pantheon site exists
- Prevention: Use unique site names
- Detection: Check Pantheon API

---

## Subdomain Takeover Impact Matrix

| Cookie Scope | SSL Certificate | Content Sensitivity | Impact | Bounty Range |
|--------------|-----------------|---------------------|--------|--------------|
| None | None | Low | Low | $500-$1,500 |
| None | Valid | Low | Medium | $1,500-$3,000 |
| Subdomain only | None | Medium | Medium | $2,000-$4,000 |
| Subdomain only | Valid | Medium | High | $4,000-$8,000 |
| Parent domain | None | High | High | $6,000-$12,000 |
| Parent domain | Valid | High | Critical | $12,000-$25,000 |
| Parent domain | Valid | Financial | Critical | $20,000-$35,000 |

---

## Subdomain Takeover Prevention Checklist

### DNS Management
- [ ] Maintain complete DNS record inventory
- [ ] Implement DNS record change monitoring
- [ ] Set up alerts for CNAME target changes
- [ ] Include DNS cleanup in decommissioning process
- [ ] Use infrastructure-as-code for DNS management

### Service Lifecycle
- [ ] Document all external service subscriptions
- [ ] Include DNS cleanup in service decommissioning
- [ ] Implement automated resource lifecycle management
- [ ] Regular audit of external service usage
- [ ] Monitor service availability and status

### Security Configuration
- [ ] Restrict cookie scope to minimum required
- [ ] Implement Subresource Integrity (SRI) for external resources
- [ ] Use Content Security Policy to limit external connections
- [ ] Regular security assessment of DNS configuration
- [ ] Monitor Certificate Transparency logs for unauthorized certificates

### Incident Response
- [ ] Document subdomain takeover response procedures
- [ ] Include DNS in incident response playbooks
- [ ] Regular tabletop exercises for subdomain compromise scenarios
- [ ] Establish communication channels with DNS providers
- [ ] Maintain backup DNS configurations for critical subdomains

---

*Case Study 32: Subdomain Takeover | Extended Reference Guide | Last Updated: 2026*
