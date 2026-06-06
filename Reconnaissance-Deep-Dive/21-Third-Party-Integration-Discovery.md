# Third-Party Integration Discovery

## Expert Role

You are a senior reconnaissance specialist focused on third-party integration discovery and supply-chain intelligence. You understand that modern web applications are not monolithic — they are assemblies of dozens of external services stitched together through JavaScript, APIs, and server-side integrations. Each integration point represents an expanded attack surface: leaked API keys, misconfigured service permissions, vulnerable SDKs, and data leakage channels. You approach third-party integration discovery with the mindset that every external service connected to a target is a potential entry point, data exfiltration vector, or privilege escalation path.

## Core Concepts

### Third-Party Integration Taxonomy

Modern web applications integrate with dozens of external services. Understanding the categories helps prioritize discovery efforts and risk assessment.

**Payment Processors**
- Stripe: JS library (stripe.js), API endpoints (api.stripe.com), webhook URLs
- PayPal: JS SDK, REST API endpoints, IPN (Instant Payment Notification) URLs
- Braintree: Client-side SDK, server-side API, drop-in UI components
- Square: Web Payments SDK, OAuth endpoints
- Adyen: Drop-in component, API endpoints
- Purpose: Financial data handling, PCI DSS scope implications

**Analytics and Tracking**
- Google Analytics: GA4 (gtag.js, analytics.js), Universal Analytics (ga.js)
- Mixpanel: mixpanel.js, API endpoint (api.mixpanel.com)
- Amplitude: amplitude.js, API endpoint (api.amplitude.com)
- Segment: analytics.js, CDN-hosted snippet
- Heap: Auto-capture JS, event API
- Hotjar: Recording script, heatmaps, feedback widgets
- FullStory: Session replay script
- Purpose: User behavior tracking, potential PII leakage

**Content Delivery Networks**
- Cloudflare: cdnjs.cloudflare.com, challenge pages, cf-ray headers
- AWS CloudFront: *.cloudfront.net domains
- Akamai: *.akamaized.net, *.edgekey.net
- Fastly: *.fastly.net, surrogate-key headers
- KeyCDN, MaxCDN, StackPath
- Purpose: Performance, DDoS protection, origin masking

**Email Services**
- SendGrid: API (api.sendgrid.com), SMTP relay
- Mailgun: API (api.mailgun.net), SMTP
- Amazon SES: AWS API endpoints
- Mandril (Mailchimp): API endpoints
- Postmark: API, webhook endpoints
- Purpose: Transactional email, marketing campaigns

**CRM and Marketing**
- Salesforce: Connected app OAuth, API endpoints (*.salesforce.com)
- HubSpot: API (api.hubspot.com), tracking code
- Marketo: Munchkin tracking code, API endpoints
- Pardot: Tracking code, form handlers
- Purpose: Lead management, customer data

**Chat and Communication**
- Intercom: widget.intercom.io, api.intercom.io
- Zendesk: Chat widget, Help Center
- Drift: Chat widget, API
- LiveChat: Widget script, API
- Twilio: Voice/SMS SDK, Programmable API
- Purpose: Customer support, potential data leakage

**A/B Testing Platforms**
- Optimizely: cdn-pci.optimizely.com, project JS
- VWO: dev.visualwebsiteoptimizer.com
- Google Optimize: optimize.google.com
- LaunchDarkly: Feature flag SDK
- Purpose: Experimentation, feature flag exposure

**Social Media Widgets**
- Facebook: connect.facebook.net, Graph API
- Twitter: platform.twitter.com, embed widgets
- LinkedIn: platform.linkedin.com, Insight Tag
- Instagram: Embed widgets
- Purpose: Social proof, tracking, cross-site data

**Font and Icon Libraries**
- Google Fonts: fonts.googleapis.com
- Adobe Fonts (Typekit): use.typekit.com
- Font Awesome: cdnjs.cloudflare.com/ajax/libs/font-awesome
- Bootstrap Icons, Feather Icons
- Purpose: Typography, CDN dependency

### Integration Attack Surface

Each integration introduces specific risks:
1. API Key Exposure — Hardcoded keys in JavaScript or source code
2. Over-Permissioned Scopes — OAuth tokens with excessive access
3. Data Leakage — PII sent to third-party analytics
4. Supply Chain Risk — Vulnerable SDK versions
5. Subdomain Takeover — Abandoned CNAME records pointing to third-party services
6. Webhook Abuse — Unauthenticated webhook endpoints
7. Account Takeover — Compromised third-party credentials granting access

### Key Indicators of Third-Party Integrations

| Indicator | What It Reveals |
|-----------|-----------------|
| External JS files | Service libraries loaded client-side |
| CNAME DNS records | Hosted services (Shopify, Heroku, etc.) |
| HTTP headers | CDN/provider identification |
| Cookie names | Third-party session management |
| Meta tags | Verification tokens, app IDs |
| Inline scripts | Initialization code with API keys |

## Prerequisites

Before beginning third-party integration discovery, ensure you have:
- Proficiency with browser developer tools (Network, Sources, Elements tabs)
- Understanding of HTTP request/response analysis
- Familiarity with JavaScript analysis
- Access to tools: curl, grep, find, nmap
- Understanding of DNS (CNAME, A records)
- Familiarity with HTTP headers and cookies
- Access to the target website (at least homepage)
- Understanding of OAuth and API authentication flows
- Basic knowledge of package managers (npm, pip, composer)
- Familiarity with subdomain enumeration tools

## Methodology

### Phase 1: JavaScript Library Discovery

The most reliable way to identify third-party integrations is through JavaScript analysis.

**Step 1: Collect all JavaScript sources**

```bash
# Extract all JS file URLs from homepage
curl -s https://target.com | grep -oP 'src="[^"]*\.js[^"]*"' | sort -u

# More comprehensive extraction
curl -s https://target.com | grep -oP '(https?://[^"'"'"'> ]*\.js[^"'"'"'> ]*)' | sort -u

# Save to file for analysis
curl -s https://target.com | grep -oP '(https?://[^"'"'"'> ]*\.js[^"'"'"'> ]*)' | sort -u > js_urls.txt
```

**Step 2: Analyze JS files for third-party service signatures**

```bash
# Search for known service identifiers in JS files
for url in $(cat js_urls.txt); do
  echo "=== $url ==="
  curl -s "$url" | grep -i -E "(stripe|paypal|google.analytics|mixpanel|amplitude|segment|hotjar|fullstory|intercom|zendesk|drift|optimizely|vwo|facebook|twitter|linkedin)"
done
```

**Step 3: Check for inline script blocks**

```bash
# Extract inline scripts from HTML
curl -s https://target.com | grep -oP '<script[^>]*>.*?</script>' | grep -v 'src='

# Look for tracking initialization code
curl -s https://target.com | grep -oP 'gtag\([^)]*\)|ga\([^)]*\)|mixpanel\.[^;]*|analytics\.[^;]*'
```

**Step 4: Identify CDN-hosted libraries**

```bash
# Check for CDN references
curl -s https://target.com | grep -oP 'https?://[^"'"'"'> ]*(cdn|cloudflare|cloudfront|akamai|fastly|jsdelivr|unpkg|cdnjs)[^"'"'"'> ]*' | sort -u
```

### Phase 2: Payment Processor Detection

Payment integrations are high-value targets due to financial data exposure.

**Stripe Detection**

```bash
# Check for Stripe.js
curl -s https://target.com | grep -i 'stripe'

# Look for Stripe publishable key (pk_live_ or pk_test_)
curl -s https://target.com | grep -oP 'pk_(live|test)_[a-zA-Z0-9]+'

# Search across all common pages
for page in / /checkout /payment /pricing /subscribe; do
  curl -s "https://target.com$page" | grep -oP 'pk_(live|test)_[a-zA-Z0-9]+'
done

# Check JS files for Stripe integration
for url in $(cat js_urls.txt); do
  curl -s "$url" | grep -i 'stripe\|Stripe('
done
```

**PayPal Detection**

```bash
# Check for PayPal JS SDK
curl -s https://target.com | grep -i 'paypal'

# Look for PayPal client ID
curl -s https://target.com | grep -oP 'client-id=[^"&]*|data-client-id="[^"]*"'

# Check for PayPal buttons
curl -s https://target.com | grep -i 'paypal-button\|paypal\.Buttons'
```

**Braintree Detection**

```bash
# Check for Braintree client SDK
curl -s https://target.com | grep -i 'braintree'

# Look for Braintree tokenization
curl -s https://target.com | grep -oP 'client_token|authorizationFingerprint'
```

### Phase 3: Analytics and Tracking Detection

**Google Analytics Detection**

```bash
# GA4 detection
curl -s https://target.com | grep -oP 'G-[A-Z0-9]+|GTM-[A-Z0-9]+|UA-[0-9]+-[0-9]+|AW-[0-9]+'

# Check for gtag.js
curl -s https://target.com | grep -i 'gtag\|googletagmanager'

# Extract GA measurement ID
curl -s https://target.com | grep -oP 'G-[A-Z0-9]{8,}'
```

**Mixpanel Detection**

```bash
# Check for Mixpanel token
curl -s https://target.com | grep -oP 'mixpanel\.init\([^)]*\)|"token":"[^"]*"'

# Look for Mixpanel distinct_id
curl -s https://target.com | grep -i 'mixpanel'
```

**Hotjar Detection**

```bash
# Check for Hotjar
curl -s https://target.com | grep -i 'hotjar\|hj\('

# Extract Hotjar site ID
curl -s https://target.com | grep -oP 'hjid:\s*[0-9]+|hotjar\.com/[0-9]+'
```

### Phase 4: Email Service Detection

```bash
# Check for email service API endpoints
curl -s https://target.com | grep -i 'sendgrid\|mailgun\|postmark\|ses\.'

# Look for email tracking pixels
curl -s https://target.com | grep -oP 'https?://[^"'"'"'> ]*(sendgrid|mailgun|postmark|ses)[^"'"'"'> ]*'

# Check for SMTP configuration in source
curl -s https://target.com | grep -i 'smtp\|mail\('
```

### Phase 5: CRM and Marketing Automation

```bash
# HubSpot detection
curl -s https://target.com | grep -oP 'hs-[a-zA-Z0-9]+|hubspot\.com|_hsq|hs-analytics'

# Salesforce detection
curl -s https://target.com | grep -i 'salesforce\|force\.com\|sfdc'

# Marketo detection
curl -s https://target.com | grep -oP 'mkto|Munchkin|marketo'
```

### Phase 6: Chat Widget Detection

```bash
# Intercom detection
curl -s https://target.com | grep -i 'intercom\|intercomSettings'

# Zendesk detection
curl -s https://target.com | grep -i 'zendesk\|zE\('

# Drift detection
curl -s https://target.com | grep -i 'drift\|driftt'

# LiveChat detection
curl -s https://target.com | grep -i 'livechat\|__lc'
```

### Phase 7: A/B Testing Platform Detection

```bash
# Optimizely detection
curl -s https://target.com | grep -i 'optimizely'

# VWO detection
curl -s https://target.com | grep -i 'vwo\|visualwebsiteoptimizer'

# Google Optimize detection
curl -s https://target.com | grep -i 'googleoptimize\|optimize'
```

### Phase 8: Social Media Widget Detection

```bash
# Facebook detection
curl -s https://target.com | grep -oP 'facebook\.net|fbq\(|fbevents\.js'

# Twitter detection
curl -s https://target.com | grep -i 'platform\.twitter\|twttr\|twitter.*widget'

# LinkedIn detection
curl -s https://target.com | grep -i 'linkedin.*insight\|linkedin\.com.*tag'
```

### Phase 9: Font and Icon Library Detection

```bash
# Google Fonts
curl -s https://target.com | grep -oP 'fonts\.googleapis\.com[^"'"'"'> ]*|fonts\.gstatic\.com[^"'"'"'> ]*'

# Font Awesome
curl -s https://target.com | grep -i 'font-awesome\|fontawesome'

# Adobe Fonts
curl -s https://target.com | grep -oP 'use\.typekit\.com[^"'"'"'> ]*'
```

### Phase 10: Complete Integration Mapping

```bash
# Create comprehensive integration report
echo "=== Third-Party Integration Report ===" > integration_report.txt
echo "Target: https://target.com" >> integration_report.txt
echo "Date: $(date)" >> integration_report.txt
echo "" >> integration_report.txt

echo "--- Payment Processors ---" >> integration_report.txt
curl -s https://target.com | grep -oP '(pk_(live|test)_[a-zA-Z0-9]+|paypal|braintree|stripe)' | sort -u >> integration_report.txt

echo "--- Analytics ---" >> integration_report.txt
curl -s https://target.com | grep -oP '(G-[A-Z0-9]+|GTM-[A-Z0-9]+|UA-[0-9]+-[0-9]+|mixpanel|hotjar|amplitude|segment)' | sort -u >> integration_report.txt

echo "--- Email Services ---" >> integration_report.txt
curl -s https://target.com | grep -oP '(sendgrid|mailgun|postmark|ses)' | sort -u >> integration_report.txt

echo "--- Chat/Support ---" >> integration_report.txt
curl -s https://target.com | grep -oP '(intercom|zendesk|drift|livechat)' | sort -u >> integration_report.txt

echo "--- CRM/Marketing ---" >> integration_report.txt
curl -s https://target.com | grep -oP '(hubspot|salesforce|marketo|pardot)' | sort -u >> integration_report.txt

echo "--- A/B Testing ---" >> integration_report.txt
curl -s https://target.com | grep -oP '(optimizely|vwo|googleoptimize)' | sort -u >> integration_report.txt

echo "--- Social Media ---" >> integration_report.txt
curl -s https://target.com | grep -oP '(facebook\.net|platform\.twitter|linkedin\.com)' | sort -u >> integration_report.txt

echo "--- CDN/Fonts ---" >> integration_report.txt
curl -s https://target.com | grep -oP '(cloudflare|cloudfront|akamai|fastly|fonts\.googleapis|font-awesome)' | sort -u >> integration_report.txt
```

## Tool Arsenal

### Manual Analysis Tools

**Browser Developer Tools**
- Network tab: All external requests visible in real time
- Sources tab: JavaScript file analysis and breakpoints
- Elements tab: Script tag inspection and DOM analysis
- Console: Dynamic variable inspection and API calls
- Application tab: Service workers, cookies, storage

**curl for Server-Side Analysis**
```bash
# Fetch with specific headers
curl -s -H "User-Agent: Mozilla/5.0" https://target.com

# Follow redirects to see where integrations lead
curl -sL -o /dev/null -w "%{url_effective}" https://target.com

# Check specific paths for integration endpoints
curl -s https://target.com/api/webhooks/stripe
curl -s https://target.com/api/webhooks/paypal
```

### Automated Discovery Tools

**Custom Integration Scanner**

```bash
#!/bin/bash
# integration_scanner.sh - Comprehensive third-party integration scanner

TARGET=$1
OUTPUT="integration_report_$(date +%Y%m%d).json"

echo '{"target":"'$TARGET'","scan_date":"'$(date)'","integrations":[' > $OUTPUT

# Payment processors
echo '  {"category":"payment_processors","found":[' >> $OUTPUT
for service in stripe paypal braintree square adyen; do
  if curl -s "https://$TARGET" | grep -qi "$service"; then
    echo "    \"$service\"," >> $OUTPUT
  fi
done
echo '  ]},' >> $OUTPUT

# Analytics
echo '  {"category":"analytics","found":[' >> $OUTPUT
for service in "google.analytics" "gtm" mixpanel amplitude segment hotjar fullstory heap; do
  if curl -s "https://$TARGET" | grep -qi "$service"; then
    echo "    \"$service\"," >> $OUTPUT
  fi
done
echo '  ]},' >> $OUTPUT

# Chat widgets
echo '  {"category":"chat_widgets","found":[' >> $OUTPUT
for service in intercom zendesk drift livechat crisp tawk; do
  if curl -s "https://$TARGET" | grep -qi "$service"; then
    echo "    \"$service\"," >> $OUTPUT
  fi
done
echo '  ]},' >> $OUTPUT

echo '],"scan_complete":true}' >> $OUTPUT
echo "[+] Integration scan complete: $OUTPUT"
```

### DNS-Based Integration Discovery

```bash
# Check CNAME records for third-party services
dig target.com CNAME +short
dig www.target.com CNAME +short

# Common CNAME patterns indicating third-party services
# *.squarespace.com - Squarespace
# *.shopify.com - Shopify
# *.cloudfront.net - AWS CloudFront
# *.herokuapp.com - Heroku
# *.azurewebsites.net - Azure
# *.firebaseapp.com - Firebase
# *.netlify.com - Netlify
# *.vercel.app - Vercel
# *.pages.dev - Cloudflare Pages
```

### HTTP Header Analysis

```bash
# Analyze response headers for CDN/provider info
curl -sI https://target.com | grep -i 'server\|x-powered-by\|cf-ray\|x-cache\|x-amz\|x-fastly\|via\|x-cdn'

# Check for provider-specific headers
curl -sI https://target.com | grep -i 'cloudflare\|akamai\|cloudfront\|fastly\|varnish'
```

### Cookie Analysis for Third-Party Services

```bash
# Extract cookies that may reveal third-party services
curl -sI https://target.com | grep -i 'set-cookie' | grep -oP '[a-zA-Z_-]+=' | sort -u

# Known cookie patterns:
# _ga, _gid - Google Analytics
# _fbp - Facebook Pixel
# mp_* - Mixpanel
#ajs_* - Segment
# intercom-* - Intercom
# __hssc, __hstc - HubSpot
```

## Case Studies

### Case Study 1: Stripe API Key Exposure via JavaScript

**Discovery**: During reconnaissance of an e-commerce platform, analysis of JavaScript files revealed a Stripe publishable key (pk_live_...) embedded in client-side code. While publishable keys are intended for client use, they confirmed live Stripe integration and revealed the Stripe account ID.

**Impact**: The publishable key was used to:
1. Confirm the target accepts real payments (not test mode)
2. Enumerate the Stripe account structure
3. Test for Stripe-specific vulnerabilities (charge amount manipulation)
4. Identify potential for payment amount tampering in checkout flow

**Methodology**:
```bash
# Extract Stripe keys
curl -s https://target.com/checkout | grep -oP 'pk_(live|test)_[a-zA-Z0-9]+'

# Test for amount manipulation
curl -X POST https://target.com/api/checkout \
  -H "Content-Type: application/json" \
  -d '{"amount":100,"currency":"usd","token":"tok_test"}'
```

### Case Study 2: Third-Party Analytics Data Leakage

**Discovery**: Analysis of network requests revealed that Google Analytics was configured to send custom dimensions containing user email addresses and internal user IDs, violating privacy policies and potentially GDPR requirements.

**Impact**:
1. PII (emails) sent to Google Analytics servers
2. Internal user IDs exposed in analytics data
3. Potential GDPR/CCPA violation
4. Data available in Google Analytics dashboard to anyone with access

**Methodology**:
```bash
# Monitor GA requests for custom dimensions
curl -s https://target.com | grep -oP 'ga\([^)]*\)|gtag\([^)]*\)'

# Check for PII in URL parameters sent to GA
curl -s "https://www.google-analytics.com/collect?" | grep -i 'email\|user_id'
```

### Case Study 3: Abandoned Intercom Widget on Staging Subdomain

**Discovery**: A staging subdomain (staging.target.com) was found to have an active Intercom widget but was publicly accessible. The Intercom app ID was extracted from the page source.

**Impact**:
1. Public access to staging environment
2. Intercom conversations potentially accessible
3. Staging data (test users, test orders) exposed
4. Could be used for social engineering via chat widget

### Case Study 4: CDN-Hosted JavaScript Supply Chain Risk

**Discovery**: The target loaded jQuery from a third-party CDN (cdn.example-cdn.com) rather than a well-known CDN. The custom CDN domain was expired and available for registration.

**Impact**:
1. Attacker could register the expired CDN domain
2. Serve malicious JavaScript to all target users
3. Steal session cookies and credentials
4. Perform XSS attacks on all visitors

**Methodology**:
```bash
# Extract all CDN references
curl -s https://target.com | grep -oP 'https?://[^"'"'"'> ]*(cdn|assets|static)[^"'"'"'> ]*' | sort -u

# Check domain registration status
whois cdn.example-cdn.com
```

### Case Study 5: Webhook Endpoint Discovery via Integration Mapping

**Discovery**: Third-party integration mapping revealed Stripe and PayPal integrations. Further investigation found webhook endpoints that were publicly accessible and lacked authentication verification.

**Impact**:
1. Could send forged webhook events
2. Potentially trigger unauthorized order status changes
3. Information disclosure via webhook responses
4. Potential for replay attacks against webhook handlers

## Advanced Techniques

### Subdomain Enumeration for Third-Party Discovery

```bash
# Find subdomains that point to third-party services
subfinder -d target.com -silent | while read sub; do
  dig +short "$sub" CNAME
done | sort | uniq -c | sort -rn

# Look for abandoned CNAMEs (subdomain takeover candidates)
subfinder -d target.com -silent | xargs -I{} dig +short {} CNAME | grep -i 'heroku\|amazonaws\|azure\|github\|shopify\|pantheon\|fastly\|surge\|ghost\|zendesk'
```

### Package Manager Analysis

```bash
# If source code is accessible, check package dependencies
# npm
cat package.json | grep -i 'stripe\|paypal\|analytics\|intercom\|segment'

# Python
cat requirements.txt | grep -i 'stripe\|paypal\|sendgrid\|twilio'

# Ruby
cat Gemfile | grep -i 'stripe\|paypal\|sendgrid\|twilio'
```

### GraphQL Schema Analysis for Integrations

```bash
# If GraphQL is available, query for integration-related types
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}' | jq '.data.__schema.types[].name' | grep -i 'payment\|stripe\|paypal\|analytics'
```

### Service Worker Analysis

```bash
# Check for service workers that may load third-party scripts
curl -s https://target.com/sw.js | grep -oP 'https?://[^"'"'"' ]+' | sort -u
curl -s https://target.com/service-worker.js | grep -oP 'https?://[^"'"'"' ]+' | sort -u

# Check manifest.json for additional service references
curl -s https://target.com/manifest.json | grep -oP 'https?://[^"'"'"' ]+' | sort -u
```

### Browser Extension Fingerprinting

```bash
# Check if the target detects common browser extensions
# This can reveal integration awareness
curl -s https://target.com | grep -i 'adblock\|adblocker\|ublock\|ghostery\|privacy.*badger'

# Some integrations serve different content based on extension detection
```

### API Endpoint Discovery via Integration Endpoints

```bash
# Common API paths for known integrations
for path in /api/webhooks/stripe /api/webhooks/paypal /api/webhooks/square \
  /api/stripe/create-payment-intent /api/paypal/create-order \
  /api/analytics/events /api/tracking/pageview; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "https://target.com$path")
  echo "$path: $code"
done
```

## Detection Signatures

### Known Integration Domains

| Service | Domain Pattern |
|---------|---------------|
| Stripe | api.stripe.com, js.stripe.com |
| PayPal | paypal.com, paypalobjects.com |
| Google Analytics | google-analytics.com, googletagmanager.com |
| Mixpanel | mixpanel.com, cdn.mxpnl.com |
| Hotjar | static.hotjar.com |
| Intercom | widget.intercom.io, api.intercom.io |
| Zendesk | static.zdassets.com |
| HubSpot | js.hs-scripts.com |
| Segment | cdn.segment.com |
| Cloudflare | cdnjs.cloudflare.com |

### HTTP Header Signatures

```
Server: cloudflare
Server: Apache/2.4 (Ubuntu)
X-Powered-By: Express
X-Cache: HIT
X-Varnish: 12345678
Via: 1.1 cloudfront (CloudFront)
CF-RAY: 1234567890-XYZ-SFO
X-Fastly-Request-ID: abc123
```

### Cookie Fingerprints

| Cookie Pattern | Service |
|----------------|---------|
| _ga, _gid, _gat | Google Analytics |
| _fbp, _fbc | Facebook Pixel |
| mp_* | Mixpanel |
|ajs_* | Segment |
| intercom-* | Intercom |
| __hssc, __hstc | HubSpot |
| _hj* | Hotjar |
| AMCV_* | Adobe Analytics |

## Impact Assessment

Third-party integration discovery directly impacts security posture:

1. **Expanded Attack Surface**: Each integration adds potential entry points
2. **Data Leakage**: PII may be sent to third-party services without user consent
3. **Supply Chain Risk**: Vulnerable SDK versions can affect all users
4. **Compliance Risk**: Unauthorized integrations may violate regulations
5. **Financial Risk**: Payment processor misconfigurations can lead to fraud
6. **Reputation Risk**: Compromised third-party scripts damage user trust
7. **Privilege Escalation**: Over-permissioned API keys enable lateral movement

## Common Pitfalls

1. **Ignoring server-side integrations**: Not all integrations are visible in client-side code
2. **Missing API key rotations**: Old keys may still be valid even if rotated
3. **Overlooking webhook endpoints**: These are often less protected than main APIs
4. **Forgetting mobile apps**: Integration patterns may differ between web and mobile
5. **Not checking staging/dev environments**: These often have more integrations enabled
6. **Ignoring CNAME records**: DNS can reveal hosted services not visible in code
7. **Missing image/resource CDNs**: Not just JavaScript — images and CSS may use CDNs
8. **Overlooking email service integrations**: These may only be visible in server responses

## Integration with Other Recon Activities

Third-party integration discovery connects to:
- **Subdomain enumeration**: Finding subdomains pointing to third-party services
- **JavaScript analysis**: Deeper analysis of discovered third-party scripts
- **API documentation discovery**: Third-party API endpoints
- **Secret scanning**: API keys in discovered integrations
- **Cloud infrastructure discovery**: Services hosted on cloud platforms
- **Technology fingerprinting**: SDK versions and frameworks used

## Reporting

### Integration Discovery Report Template

```markdown
# Third-Party Integration Discovery Report

## Executive Summary
- Total integrations discovered: X
- Critical findings: X
- High-risk findings: X

## Payment Processors
| Service | Key/ID Found | Mode | Risk Level |
|---------|-------------|------|------------|
| Stripe | pk_live_... | Live | Medium |

## Analytics and Tracking
| Service | ID/Token | Data Collected | Risk Level |
|---------|----------|----------------|------------|
| Google Analytics | G-XXXXXXX | Page views | Low |

## Communication Tools
| Service | App ID | Accessibility | Risk Level |
|---------|--------|---------------|------------|
| Intercom | abc123 | Public | High |

## Recommendations
1. Rotate exposed API keys
2. Audit integration permissions
3. Implement CSP to restrict third-party scripts
4. Review data collection practices for compliance
```

## Labs

### Lab 1: Basic Integration Discovery
1. Set up a local test website with Stripe.js, Google Analytics, and Intercom
2. Use curl to extract all JavaScript references
3. Identify each integration from the JS files
4. Document all found API keys and IDs

### Lab 2: DNS-Based Discovery
1. Create a test domain with CNAME records pointing to third-party services
2. Use dig to enumerate all CNAME records
3. Map CNAMEs to specific third-party services
4. Identify abandoned CNAME records

### Lab 3: Webhook Endpoint Discovery
1. Set up a test application with Stripe and PayPal webhooks
2. Discover the webhook endpoints through integration mapping
3. Test webhook endpoint authentication
4. Document any security weaknesses

### Lab 4: Supply Chain Risk Assessment
1. Find a website using a custom CDN domain
2. Check domain registration status
3. Identify the risk if the domain expires
4. Propose mitigations (Subresource Integrity, CSP)

## Ethics

Third-party integration discovery should be conducted ethically:

1. **Authorization**: Only scan targets you have permission to test
2. **Data Handling**: Treat discovered API keys and credentials responsibly
3. **Responsible Disclosure**: Report findings through proper channels
4. **No Abuse**: Do not exploit discovered integrations for unauthorized access
5. **Privacy**: Respect user privacy when analyzing analytics and tracking
6. **Scope**: Stay within the defined scope of engagement
7. **Documentation**: Record all findings for the client security team
8. **Minimal Impact**: Do not disrupt third-party services during testing

## Cheat Sheet

```bash
# Extract all JS URLs
curl -s https://target.com | grep -oP 'https?://[^"'"'"'> ]*\.js' | sort -u

# Find Stripe keys
curl -s https://target.com | grep -oP 'pk_(live|test)_[a-zA-Z0-9]+'

# Find GA IDs
curl -s https://target.com | grep -oP 'G-[A-Z0-9]+|GTM-[A-Z0-9]+|UA-[0-9]+-[0-9]+'

# Check for chat widgets
curl -s https://target.com | grep -i 'intercom\|zendesk\|drift\|livechat'

# Find CDN references
curl -s https://target.com | grep -oP 'https?://[^"'"'"'> ]*(cdn|cloudflare|cloudfront|akamai)[^"'"'"'> ]*'

# Check CNAME records
dig target.com CNAME +short

# Analyze HTTP headers
curl -sI https://target.com | grep -i 'server\|x-powered-by\|cf-ray\|via'

# Extract cookies
curl -sI https://target.com | grep -i 'set-cookie'

# Check for payment processor JS
curl -s https://target.com | grep -i 'stripe\|paypal\|braintree'

# Find analytics IDs
curl -s https://target.com | grep -oP '(G-[A-Z0-9]+|mixpanel|hotjar|segment|amplitude)'
```
